pcb_width = 71;
pcb_depth = 40;
pcb_height = 40;
wall_t = 2;

module scd30_holder(){
    difference(){
        cube([27, 5, 9]);
        translate([2, -1, 2]) cube([25, 7, 5]);
    }
}

module box(){
    difference(){
        cube([100, 45 + 2 * wall_t, 40 + 2 * wall_t]);
        translate([0, wall_t, wall_t]) #cube([100, 45, 40]);
    }
    
    cube([pcb_width, 4.5, 6]);
    translate([0, 44.5, 0]) cube([pcb_width, 4.5, 6]);
    translate([pcb_width, 0, 0]) cube([2, 45 + 2 * wall_t, 8]);
    translate([0, 0, 6]) cube([pcb_width, 8, 2]);
    translate([0, 41, 6]) cube([pcb_width, 8, 2]);
    
    translate([73, 0, 15]) scd30_holder();
    translate([73, 44, 15]) scd30_holder();
}

difference(){
    box();
    for(i = [0:3]){
        translate([15, 7.5 + i * 10, 41]) cube([70, 4, 4]);
    }
}