# Klippy batch simulator

Proves `FIZZBUZZ N=100` by running it through official Klipper host software
(fileoutput / simulated linux-process MCU), then rendering the expanded moves.

```bash
git clone --depth 1 https://github.com/Klipper3d/klipper.git /tmp/klipper
pip install greenlet cffi pyserial pillow
# optional second renderer:
pip install gcode-viewer

# MCU dictionary (already committed as linuxprocess.dict), or rebuild:
#   cd /tmp/klipper && cp test/configs/linuxprocess.config .config && make olddefconfig && make

python3 src/GCode/sim/simulate.py --klipper /tmp/klipper -n 100
```

That:

1. Invokes Klippy with `FIZZBUZZ N=100` (same entry as the printer console)
2. Checks the 100 calculated labels against `FizzBuzz.txt`
3. Checks extruded XY stays inside `[18, 238]` mm on the 256×256 bed
4. Writes `src/GCode/fizzbuzz_preview.png` (true 256 mm bed)
5. If `gcode-viewer` is on `PATH`, also writes `src/GCode/fizzbuzz_preview_gcode_viewer.png`
