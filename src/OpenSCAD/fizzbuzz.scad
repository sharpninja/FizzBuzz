/*
 * FizzBuzz Implementation in OpenSCAD
 * September 19, 2026
 *
 * "Write a program that prints the numbers from 1 to 100. But for multiples of three print
 * “Fizz” instead of the number and for the multiples of five print “Buzz”. For numbers which
 * are multiples of both three and five print “FizzBuzz”."
 *
 * This program does not print to a console.  Rendering it produces a 3D medallion of the
 * classic 1–100 sequence: ten concentric decade rings of extruded text.  Height (and color
 * in preview) encodes the word so a monochrome STL is still readable:
 *
 *     number  <  Fizz  <  Buzz  <  FizzBuzz
 *
 * Open `fizzbuzz.scad` in the OpenSCAD GUI (F5 preview / F6 render) or export from the CLI:
 *
 *     openscad -o fizzbuzz.stl fizzbuzz.scad
 *     openscad -o fizzbuzz.png --imgsize=1920,1080 --viewall --autocenter fizzbuzz.scad
 *
 * Uses Liberation Sans, which ships with official OpenSCAD builds and is also provided by
 * the `fonts-liberation` package on Debian/Ubuntu.  No font files are bundled in this repo.
 */

$fa = 8;
$fs = 0.45;

// Default camera: slight isometric tilt so both the labels and the height code read clearly.
$vpt = [0, -4, 6];
$vpr = [32, 0, 22];
$vpd = 520;

FONT = "Liberation Sans:style=Bold";

RINGS      = 10;
PER_RING   = 10;
INNER_R    = 26;
RING_STEP  = 8.4;
BASE_H     = 3.2;
RIM_H      = 5.0;
PAD        = 12;

function fb_label(n) =
    (n % 15 == 0) ? "FizzBuzz" :
    (n %  3 == 0) ? "Fizz" :
    (n %  5 == 0) ? "Buzz" :
    str(n);

function fb_kind(n) =
    (n % 15 == 0) ? "fizzbuzz" :
    (n %  3 == 0) ? "fizz" :
    (n %  5 == 0) ? "buzz" :
    "number";

// Distinct Z heights so Fizz vs Buzz stay distinguishable after STL export.
function fb_height(n) =
    (n % 15 == 0) ? 7.4 :
    (n %  5 == 0) ? 5.2 :
    (n %  3 == 0) ? 3.8 :
    2.2;

function fb_color(n) =
    (n % 15 == 0) ? [0.91, 0.20, 0.46] :
    (n %  5 == 0) ? [0.98, 0.72, 0.16] :
    (n %  3 == 0) ? [0.18, 0.76, 0.50] :
    [0.86, 0.89, 0.93];

function ring_radius(ring) = INNER_R + ring * RING_STEP;

function chord(ring) = 2 * ring_radius(ring) * sin(180 / PER_RING);

// Fit each label to the ring spacing.  Character width is an em-fraction of Liberation Bold.
function label_size(n, ring) =
    let (
        label = fb_label(n),
        room  = chord(ring) * 0.78,
        em    = 0.62 * max(1, len(label))
    )
    min(ring == 0 ? 4.0 : 5.2, room / em);

function outer_radius() = ring_radius(RINGS - 1) + PAD;

module rounded_rect(w, h, r) {
    if (r <= 0) {
        square([w, h], center = true);
    } else {
        offset(r = r)
            square([max(0.01, w - 2 * r), max(0.01, h - 2 * r)], center = true);
    }
}

module medallion() {
    r = outer_radius();

    color([0.16, 0.18, 0.22])
        cylinder(h = BASE_H, r = r);

    color([0.28, 0.31, 0.36])
        translate([0, 0, BASE_H])
            difference() {
                cylinder(h = RIM_H - BASE_H, r = r);
                translate([0, 0, -0.1])
                    cylinder(h = RIM_H, r = r - 3.2);
            }

    // Soft recessed well behind the rings.
    color([0.13, 0.14, 0.17])
        translate([0, 0, BASE_H - 0.35])
            cylinder(h = 0.4, r = ring_radius(RINGS - 1) + 4.5);
}

module title() {
    color([0.96, 0.97, 0.94])
        translate([0, 3.2, BASE_H])
            linear_extrude(height = 3.6, convexity = 8)
                text("FIZZBUZZ", size = 6.2, font = FONT,
                     halign = "center", valign = "center");

    color([0.70, 0.74, 0.80])
        translate([0, -5.6, BASE_H])
            linear_extrude(height = 2.2, convexity = 8)
                text("1 – 100", size = 3.6, font = FONT,
                     halign = "center", valign = "center");
}

module entry(n, ring, slot) {
    r   = ring_radius(ring);
    ang = slot * (360 / PER_RING) + ring * (180 / PER_RING);
    h   = fb_height(n);
    s   = label_size(n, ring);
    t   = fb_label(n);
    tw  = len(t) * s * 0.62 + 2.4;
    th  = s * 1.25 + 1.6;
    rad = (fb_kind(n) == "fizzbuzz") ? th * 0.48 :
          (fb_kind(n) == "fizz")     ? th * 0.42 :
          0.9;

    translate([r * cos(ang), r * sin(ang), BASE_H])
        color(fb_color(n))
            union() {
                linear_extrude(height = h * 0.42)
                    rounded_rect(tw, th, rad);

                translate([0, 0, h * 0.42])
                    linear_extrude(height = h * 0.58, convexity = 12)
                        text(t, size = s, font = FONT,
                             halign = "center", valign = "center");
            }
}

module decade_rings() {
    for (ring = [0 : RINGS - 1], slot = [0 : PER_RING - 1]) {
        n = ring * PER_RING + slot + 1;
        entry(n, ring, slot);
    }
}

module legend() {
    samples = [
        [1,  "number",   [0.86, 0.89, 0.93]],
        [3,  "Fizz",     [0.18, 0.76, 0.50]],
        [5,  "Buzz",     [0.98, 0.72, 0.16]],
        [15, "FizzBuzz", [0.91, 0.20, 0.46]]
    ];
    r = outer_radius() - 7.5;
    span = 118;
    for (i = [0 : len(samples) - 1]) {
        n = samples[i][0];
        ang = 250 + i * (span / (len(samples) - 1));
        translate([r * cos(ang), r * sin(ang), BASE_H + 0.2])
            rotate([0, 0, ang + 90])
                color(samples[i][2])
                    linear_extrude(height = 1.6, convexity = 8)
                        text(samples[i][1], size = 3.1, font = FONT,
                             halign = "center", valign = "center");
    }
}

union() {
    medallion();
    title();
    decade_rings();
    legend();
}
