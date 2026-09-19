/*
 * FizzBuzz Implementation in OpenSCAD
 * September 19, 2026
 *
 * "Write a program that prints the numbers from 1 to 100. But for multiples of three print
 * “Fizz” instead of the number and for the multiples of five print “Buzz”. For numbers which
 * are multiples of both three and five print “FizzBuzz”."
 *
 * This program does not print to a console.  Rendering it produces a 3D plaque of the
 * classic 1–100 sequence: a 10×10 grid of extruded labels.  Tile height (and preview
 * color) encodes the word so a monochrome STL is still readable:
 *
 *     number  <  Fizz  <  Buzz  <  FizzBuzz
 *
 * Open `fizzbuzz.scad` in the OpenSCAD GUI (F5 preview / F6 render) or export from the CLI:
 *
 *     openscad -o fizzbuzz.stl fizzbuzz.scad
 *     openscad -o fizzbuzz.png --imgsize=1920,1080 fizzbuzz.scad
 *
 * Uses Liberation Sans, which ships with official OpenSCAD builds and is also provided by
 * the `fonts-liberation` package on Debian/Ubuntu.  No font files are bundled in this repo.
 */

$fa = 8;
$fs = 0.45;

// Default camera: isometric enough to show the height code, shallow enough to read the grid.
$vpt = [0, 10, 10];
$vpr = [55, 0, 22];
$vpd = 500;

FONT = "Liberation Sans:style=Bold";
TEXT_COLOR = [0.07, 0.08, 0.10];

COLS       = 10;
ROWS       = 10;
CELL_W     = 24.0;
CELL_D     = 9.6;
GAP        = 1.8;
TITLE_BAND = 30;
MARGIN     = 10;
FRAME      = 3.8;
BASE_H     = 3.2;

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
    (n % 15 == 0) ? 12.0 :
    (n %  5 == 0) ? 8.2 :
    (n %  3 == 0) ? 5.6 :
    2.5;

function fb_tile_color(n) =
    (n % 15 == 0) ? [0.91, 0.22, 0.48] :
    (n %  5 == 0) ? [0.98, 0.74, 0.18] :
    (n %  3 == 0) ? [0.18, 0.76, 0.52] :
    [0.90, 0.92, 0.95];

function text_size(n) =
    (n % 15 == 0) ? 2.70 :
    (n %  3 == 0 || n % 5 == 0) ? 3.80 :
    (n >= 100) ? 3.8 :
    (n >= 10) ? 4.4 :
    5.2;

function col_of(n) = (n - 1) % COLS;
function row_of(n) = floor((n - 1) / COLS);

function grid_w() = COLS * CELL_W + (COLS - 1) * GAP;
function grid_d() = ROWS * CELL_D + (ROWS - 1) * GAP;
function plaque_w() = grid_w() + 2 * MARGIN + 2 * FRAME;
function plaque_d() = grid_d() + TITLE_BAND + 2 * MARGIN + 2 * FRAME;
function plaque_shift_y() = TITLE_BAND / 2;

// Grid is centered on the origin.  Row 0 (1–10) sits at the top.
function cell_x(n) = (col_of(n) - (COLS - 1) / 2) * (CELL_W + GAP);
function cell_y(n) = ((ROWS - 1) / 2 - row_of(n)) * (CELL_D + GAP);

module rounded_rect(w, h, r) {
    if (r <= 0) {
        square([w, h], center = true);
    } else {
        offset(r = r)
            square([max(0.01, w - 2 * r), max(0.01, h - 2 * r)], center = true);
    }
}

module plaque() {
    w = plaque_w();
    d = plaque_d();

    translate([0, plaque_shift_y(), 0]) {
        color([0.15, 0.17, 0.20])
            linear_extrude(height = BASE_H)
                rounded_rect(w, d, 9);

        color([0.27, 0.30, 0.35])
            translate([0, 0, BASE_H])
                linear_extrude(height = 2.4)
                    difference() {
                        rounded_rect(w, d, 9);
                        rounded_rect(w - 2 * FRAME, d - 2 * FRAME, 6);
                    }
    }

    color([0.12, 0.13, 0.16])
        translate([0, 0, BASE_H - 0.25])
            linear_extrude(height = 0.3)
                rounded_rect(grid_w() + 3, grid_d() + 3, 2);
}

module title() {
    y0 = grid_d() / 2;

    color([0.96, 0.97, 0.94])
        translate([0, y0 + 22, BASE_H])
            linear_extrude(height = 3.4, convexity = 8)
                text("FIZZBUZZ", size = 7.6, font = FONT,
                     halign = "center", valign = "center");

    color([0.72, 0.76, 0.82])
        translate([0, y0 + 13.6, BASE_H])
            linear_extrude(height = 2.0, convexity = 8)
                text("1  –  100", size = 3.5, font = FONT,
                     halign = "center", valign = "center");
}

module legend() {
    y = grid_d() / 2 + 6.4;
    items = [
        [1,  "number"],
        [3,  "Fizz"],
        [5,  "Buzz"],
        [15, "FizzBuzz"]
    ];
    span = 130;
    for (i = [0 : len(items) - 1]) {
        n = items[i][0];
        x = -span / 2 + i * (span / (len(items) - 1));
        translate([x, y, BASE_H]) {
            color(fb_tile_color(n))
                linear_extrude(height = 1.5)
                    rounded_rect(28, 5.8, 1.5);
            color(TEXT_COLOR)
                translate([0, 0, 1.5])
                    linear_extrude(height = 1.2, convexity = 8)
                        text(items[i][1], size = 2.8, font = FONT,
                             halign = "center", valign = "center");
        }
    }
}

module cell(n) {
    h   = fb_height(n);
    s   = text_size(n);
    t   = fb_label(n);
    rad = (fb_kind(n) == "fizzbuzz") ? 1.8 :
          (fb_kind(n) == "fizz")     ? CELL_D * 0.34 :
          (fb_kind(n) == "buzz")     ? 1.2 :
          1.4;

    translate([cell_x(n), cell_y(n), BASE_H]) {
        color(fb_tile_color(n))
            linear_extrude(height = h * 0.40)
                rounded_rect(CELL_W - 0.5, CELL_D - 0.5, rad);

        color(TEXT_COLOR)
            translate([0, 0, h * 0.40])
                linear_extrude(height = h * 0.60, convexity = 12)
                    text(t, size = s, font = FONT,
                         halign = "center", valign = "center");
    }
}

module grid() {
    for (n = [1 : 100])
        cell(n);
}

union() {
    plaque();
    title();
    legend();
    grid();
}
