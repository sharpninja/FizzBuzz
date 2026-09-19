#!/usr/bin/env python3
"""Run FIZZBUZZ N=100 through Klippy batch mode and render the extruded path.

Uses the official Klipper host (fileoutput / simulated MCU dictionary), then
writes the expanded G0/G1 stream and a PNG of the 256x256 mm bed.
"""

from __future__ import annotations

import argparse
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SRC = ROOT.parent
REPO = SRC.parent.parent
REF = REPO / "FizzBuzz.txt"

PATH_RE = re.compile(
    r"^PATH G(?P<kind>[01])\s+(?P<body>.*)$"
)
WORD_RE = re.compile(r"([XYZEF])([-+]?(?:\d+\.?\d*|\.\d+))")
LABEL_RE = re.compile(r"^FIZZBUZZ (\d+) (.+)$")


def expected_labels(n: int) -> list[str]:
    out = []
    for i in range(1, n + 1):
        if i % 15 == 0:
            out.append("FizzBuzz")
        elif i % 3 == 0:
            out.append("Fizz")
        elif i % 5 == 0:
            out.append("Buzz")
        else:
            out.append(str(i))
    return out


def find_klipper(explicit: Path | None) -> Path:
    if explicit:
        return explicit
    for cand in (Path("/tmp/klipper"), Path.home() / "klipper"):
        if (cand / "klippy" / "klippy.py").is_file():
            return cand
    raise SystemExit(
        "Klipper source not found. Clone https://github.com/Klipper3d/klipper "
        "to /tmp/klipper or pass --klipper."
    )


def ensure_dict(klipper: Path, dest: Path) -> Path:
    built = klipper / "out" / "klipper.dict"
    if dest.is_file():
        return dest
    if built.is_file():
        shutil.copy(built, dest)
        return dest
    raise SystemExit(
        f"No MCU dictionary at {dest}. Build the linux-process MCU:\n"
        f"  cd {klipper} && cp test/configs/linuxprocess.config .config "
        f"&& make olddefconfig && make"
    )


def run_klippy(klipper: Path, dictionary: Path, n: int, work: Path) -> Path:
    work.mkdir(parents=True, exist_ok=True)
    gcode_in = work / "run.gcode"
    gcode_in.write_text(f"FIZZBUZZ N={n}\n")
    log = work / "klippy.log"
    serial = work / "mcu.serial"
    if log.exists():
        log.unlink()
    cmd = [
        sys.executable,
        str(klipper / "klippy" / "klippy.py"),
        str(ROOT / "printer.cfg"),
        "-i",
        str(gcode_in),
        "-o",
        str(serial),
        "-d",
        str(dictionary),
        "-l",
        str(log),
    ]
    print("Running:", " ".join(cmd), flush=True)
    proc = subprocess.run(cmd, cwd=str(klipper))
    if proc.returncode != 0:
        raise SystemExit(f"klippy exited {proc.returncode}; see {log}")
    return log


def parse_log(log: Path) -> tuple[list[tuple[int, str]], list[str]]:
    labels: list[tuple[int, str]] = []
    paths: list[str] = []
    for raw in log.read_text(errors="replace").splitlines():
        line = raw.strip()
        m = LABEL_RE.match(line)
        if m:
            labels.append((int(m.group(1)), m.group(2).strip()))
            continue
        if line.startswith("PATH G"):
            paths.append(line)
    return labels, paths


def paths_to_gcode(paths: list[str]) -> str:
    lines = [
        "; Expanded by Klippy from FIZZBUZZ N= (see simulate.py)",
        "G90",
        "G21",
        "M83",
    ]
    for p in paths:
        m = PATH_RE.match(p)
        if not m:
            continue
        lines.append(f"G{m.group('kind')} {m.group('body').strip()}")
    return "\n".join(lines) + "\n"


def collect_segments(paths: list[str]) -> list[tuple[float, float, float, float, bool]]:
    x = y = 0.0
    segs = []
    for p in paths:
        m = PATH_RE.match(p)
        if not m:
            continue
        words = {w.group(1): float(w.group(2)) for w in WORD_RE.finditer(m.group("body"))}
        nx = words.get("X", x)
        ny = words.get("Y", y)
        extrude = "E" in words and words["E"] > 0
        if (nx, ny) != (x, y) and ("X" in words or "Y" in words):
            segs.append((x, y, nx, ny, extrude))
        x, y = nx, ny
    return segs


def render_png(paths: list[str], dest: Path, bed: float = 256.0) -> None:
    from PIL import Image, ImageDraw, ImageFont

    scale = 5
    pad = 40
    px = int(bed * scale) + pad * 2
    img = Image.new("RGB", (px, px + 32), (17, 19, 24))
    draw = ImageDraw.Draw(img)

    def tx(x: float) -> float:
        return pad + x * scale

    def ty(y: float) -> float:
        return pad + (bed - y) * scale

    draw.rectangle([tx(0), ty(bed), tx(bed), ty(0)], fill=(27, 31, 39), outline=(139, 147, 167))
    draw.rectangle([tx(18), ty(238), tx(238), ty(18)], outline=(61, 154, 110))
    for seg in collect_segments(paths):
        x0, y0, x1, y1, extrude = seg
        color = (126, 231, 164) if extrude else (48, 56, 70)
        width = 3 if extrude else 1
        draw.line([(tx(x0), ty(y0)), (tx(x1), ty(y1))], fill=color, width=width)
    font = ImageFont.load_default()
    draw.text(
        (pad, px + 6),
        "Klippy batch: FIZZBUZZ N=100  |  green = extruded PLA+  |  256x256 mm, 18 mm margin",
        fill=(201, 209, 217),
        font=font,
    )
    dest.parent.mkdir(parents=True, exist_ok=True)
    img.save(dest)


def try_gcode_viewer(gcode: Path, dest: Path) -> bool:
    os.environ["PATH"] = str(Path.home() / ".local" / "bin") + os.pathsep + os.environ.get("PATH", "")
    exe = shutil.which("gcode-viewer")
    if not exe:
        return False
    cmd = [
        exe,
        str(gcode),
        "--export",
        str(dest),
        "--camera",
        "top",
        "--resolution",
        "1600x1600",
        "--show-travel",
    ]
    print("Running:", " ".join(cmd), flush=True)
    res = subprocess.run(cmd)
    return res.returncode == 0 and dest.is_file()


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--klipper", type=Path, default=None)
    ap.add_argument("-n", type=int, default=100)
    ap.add_argument("--work", type=Path, default=ROOT / "out")
    args = ap.parse_args()

    klipper = find_klipper(args.klipper)
    dictionary = ensure_dict(klipper, ROOT / "linuxprocess.dict")
    log = run_klippy(klipper, dictionary, args.n, args.work)
    labels, paths = parse_log(log)
    if not labels:
        print(log.read_text()[-4000:])
        raise SystemExit("No FIZZBUZZ labels in klippy.log — macro did not run")
    if not paths:
        raise SystemExit("No PATH G0/G1 lines in klippy.log — motion was not captured")

    got = [lab for _, lab in labels]
    exp = expected_labels(args.n)
    if got != exp:
        print("Label mismatch vs classic FizzBuzz:", file=sys.stderr)
        for i, (a, b) in enumerate(zip(got, exp), 1):
            if a != b:
                print(f"  n={i}: got {a!r} expected {b!r}", file=sys.stderr)
        return 1
    if args.n == 100 and REF.is_file() and got != REF.read_text().splitlines():
        raise SystemExit("Labels do not match FizzBuzz.txt")

    xs, ys, exs, eys = [], [], [], []
    for x0, y0, x1, y1, extrude in collect_segments(paths):
        # G28 starts at the origin; ignore that implicit first point.
        if x1 > 0.05 or y1 > 0.05:
            xs.append(x1)
            ys.append(y1)
        if extrude:
            exs += [x0, x1]
            eys += [y0, y1]
    if not exs:
        raise SystemExit("No extrusion moves — PLA+ path was not generated")
    if (
        min(exs) < 18 - 1e-6
        or max(exs) > 238 + 1e-6
        or min(eys) < 18 - 1e-6
        or max(eys) > 238 + 1e-6
        or min(xs) < 18 - 1e-6
        or max(xs) > 238 + 1e-6
        or min(ys) < 18 - 1e-6
        or max(ys) > 238 + 1e-6
    ):
        raise SystemExit(
            f"Work motion escaped [18,238]: dest X[{min(xs):.3f},{max(xs):.3f}] "
            f"Y[{min(ys):.3f},{max(ys):.3f}] extrude "
            f"X[{min(exs):.3f},{max(exs):.3f}] Y[{min(eys):.3f},{max(eys):.3f}]"
        )

    expanded = args.work / "fizzbuzz_expanded.gcode"
    expanded.write_text(paths_to_gcode(paths))
    preview = SRC / "fizzbuzz_preview.png"
    viewer_png = SRC / "fizzbuzz_preview_gcode_viewer.png"
    render_png(paths, preview)
    print(f"256x256 toolpath preview: {preview}")
    if try_gcode_viewer(expanded, args.work / "gcode_viewer.png"):
        shutil.copy(args.work / "gcode_viewer.png", viewer_png)
        print(f"gcode-viewer export: {viewer_png}")
    else:
        print("gcode-viewer not available; skipped second preview")

    artifact_dir = Path("/opt/cursor/artifacts")
    if artifact_dir.is_dir():
        shutil.copy(preview, artifact_dir / "klipper_fizzbuzz_klippy_preview.png")
        if viewer_png.is_file():
            shutil.copy(viewer_png, artifact_dir / "klipper_fizzbuzz_gcode_viewer.png")
        shutil.copy(expanded, artifact_dir / "klipper_fizzbuzz_expanded.gcode")

    print(f"labels={len(got)} paths={len(paths)}")
    print(
        f"dest X [{min(xs):.3f}, {max(xs):.3f}]  Y [{min(ys):.3f}, {max(ys):.3f}]"
    )
    print(
        f"extrude X [{min(exs):.3f}, {max(exs):.3f}]  Y [{min(eys):.3f}, {max(eys):.3f}]"
    )
    print(f"expanded={expanded}")
    print("OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
