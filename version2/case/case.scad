bottom_x = 120;
bottom_y = 93;
bottom_z = 9.7;

wall_thickness = 2;
inner_tolerance = 1;
inner_height = 45;

screw_d = 5;
screw_area = 12;

x = bottom_x + 2 * wall_thickness + 2 * inner_tolerance;
y = bottom_y + 2 * wall_thickness + 2 * inner_tolerance;
z = bottom_z + wall_thickness + inner_height;

$fa = 0.1;
$fs = 0.1;

module nut(){
    h = 3.1;
    w = 7.5;
    
    intersection(){
        cube([2*w, w, h], center=true);
        rotate([0, 0, 60]) cube([2*w, w, h], center=true);
        rotate([0, 0, 120]) cube([2*w, w, h], center=true);
    }
}

module nut_holder(){
    translate([0, 0, bottom_z + inner_tolerance])
    difference(){
        cube([
            inner_tolerance + screw_area,
            inner_tolerance + screw_area,
            z - bottom_z - inner_tolerance
        ]);
        
        translate([
            1 + screw_area / 2,
            1 + screw_area / 2,
            0
        ])
        cylinder(d = screw_d, center=true, h=40);
        
        translate([
            1 + screw_area / 2,
            1 + screw_area / 2,
            5
        ])
        nut();
    }
}


difference(){
    cube([x, y, z]);
    
    translate([wall_thickness, wall_thickness, -wall_thickness])
    cube([
        bottom_x + 2 * inner_tolerance,
        bottom_y + 2 * inner_tolerance,
        z
    ]);
    
    // usb cable hole
    translate([
        x - 50 - wall_thickness - inner_tolerance,
        y - wall_thickness - 1,
        15
    ])
    cube([25, wall_thickness + 2, 15]);
    
    // light sensor hole
    translate([
        wall_thickness + inner_tolerance + 26,
        -1,
        bottom_z + 5,
    ])
    cube([12, wall_thickness + 2, 20]);
    
    // air holes
    for(i = [-2:2]){
        echo(i);
        translate([-1, y / 2 + 12 * i - 2.5, bottom_z + 5])
        cube([x + 2, 5, z - bottom_z - 5 - wall_thickness - 5]);
    }
    
    for(i = [0:4]){
        echo(i);
        translate([52 + 12 * i, -1, bottom_z + 5])
        cube([5, wall_thickness + 2, z - bottom_z - 5 - wall_thickness - 5]);
    }
    
    for(i = [0:3]){
        echo(i);
        translate([22 + 12 * i, y - wall_thickness - 1, bottom_z + 5])
        cube([5, wall_thickness + 2, z - bottom_z - 5 - wall_thickness - 5]);
    }
}


// nut holders
translate([wall_thickness, wall_thickness, 0])
nut_holder();

translate([x-wall_thickness, wall_thickness, 0])
rotate([0, 0, 90])
nut_holder();

translate([wall_thickness, y-wall_thickness, 0])
rotate([0, 0, 270])
nut_holder();

translate([x-wall_thickness, y-wall_thickness, 0])
rotate([0, 0, 180])
nut_holder();

translate([
    0,
    8 + wall_thickness + inner_tolerance,
    bottom_z + 25 + inner_tolerance
])
cube([x, 7, z - bottom_z - 25 - inner_tolerance]);