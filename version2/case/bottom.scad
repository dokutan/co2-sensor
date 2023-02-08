wall_thickness = 2;

screw_d = 5;
screw_area = 12;
screw_head = 3;

pcb_x = 92;
pcb_y = 71;
pcb_thickness = 1.7;
pcb_space = 4;

co2_sensor_slot = 4.7;
co2_sensor_x = 40.5;
co2_sensor_y = 20;
co2_sensor_z = 25;

light_sensor_slot = 3;
light_sensor_x = 14.2;
light_sensor_z = 19;

$fa = 0.1;
$fs = 0.1;

x = pcb_x + 2 * screw_area + 2 * wall_thickness;
y = pcb_y + wall_thickness + co2_sensor_y;
z = 2 * wall_thickness + pcb_thickness + pcb_space;

difference(){
    cube([
        x,
        y,
        z,
    ]);
    
    // screw areas + holes
    cube([
        screw_area,
        y,
        screw_head,
    ]);
    translate([x - screw_area, 0])
    cube([
        screw_area,
        y,
        screw_head,
    ]);
    
    translate([screw_area / 2, screw_area / 2]) cylinder(h = 20, d = screw_d);
    translate([x - screw_area / 2, screw_area / 2]) cylinder(h = 20, d = screw_d);
    translate([screw_area / 2, y - screw_area / 2]) cylinder(h = 20, d = screw_d);
    translate([x - screw_area / 2, y - screw_area / 2]) cylinder(h = 20, d = screw_d);
    
    // pcb slot
    translate([
        screw_area + wall_thickness + 5,
        0,
        wall_thickness,
        ])
    cube([
        pcb_x - 10,
        pcb_y - 2,
        20,
    ]);
    translate([
        screw_area + wall_thickness,
        0,
        wall_thickness + pcb_space,
        ])
    cube([
        pcb_x,
        pcb_y,
        pcb_thickness,
    ]);
}

// co2 sensor mount
difference(){
    translate([
        screw_area + 5,
        y - co2_sensor_y + wall_thickness,
        z,
    ])
    cube([
        2 * wall_thickness + co2_sensor_x,
        2 * wall_thickness + co2_sensor_slot,
        co2_sensor_z,
    ]);
    
    translate([
        screw_area + 5 + wall_thickness,
        y - co2_sensor_y + 2 * wall_thickness,
        z,
    ])
    cube([
        co2_sensor_x,
        co2_sensor_slot,
        co2_sensor_z,
    ]);
    
    translate([
        screw_area + 5 + wall_thickness + 4,
        y - co2_sensor_y,
        z,
    ])
    cube([
        co2_sensor_x - 8,
        20,
        co2_sensor_z,
    ]);
}

// light sensor mount
difference(){
    translate([
        x - screw_area - 30,
        y - co2_sensor_y + wall_thickness,
        z,
    ])
    cube([
        2 * wall_thickness + light_sensor_x,
        2 * wall_thickness + light_sensor_slot,
        co2_sensor_z,
    ]);
    
    translate([
        x - screw_area - 30 + wall_thickness,
        y - co2_sensor_y + 2 * wall_thickness,
        z + co2_sensor_z - light_sensor_z,
    ])
    cube([
        light_sensor_x,
        light_sensor_slot,
        light_sensor_z,
    ]);
    
    translate([
        x - screw_area - 30 + wall_thickness + 1,
        y - co2_sensor_y,
        z + co2_sensor_z - light_sensor_z,
    ])
    cube([
        light_sensor_x - 2,
        20,
        light_sensor_z,
    ]);
}