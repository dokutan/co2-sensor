tolerance = 1;
wall_t = 2;

side = 2; // 1 or 2

if(side == 1){

    difference(){
        cube([44 + tolerance + 2 * wall_t, 49 + tolerance + 2 * wall_t, 10 + wall_t]);
        translate([wall_t, wall_t, wall_t]) cube([44 + tolerance, 49 + tolerance, 10]);
        
        for(i = [0:3]){
            translate([10, 9.5 + i * 10, 0]) cube([44 + tolerance + 2 * wall_t - 20, 4, 4]);
        }
    }
    
} else {

    difference(){
        cube([44 + tolerance + 2 * wall_t, 49 + tolerance + 2 * wall_t, 10 + wall_t]);
        translate([wall_t, wall_t, wall_t]) cube([44 + tolerance, 49 + tolerance, 10]);
        
        translate([10, 9.5, 0]) cube([44 + tolerance + 2 * wall_t - 20, 4, 4]);
        translate([31, 9.5 + 10, 0]) cube([44 + tolerance + 2 * wall_t - 41, 4, 4]);
        translate([31, 9.5 + 20, 0]) cube([44 + tolerance + 2 * wall_t - 41, 4, 4]);
        translate([10, 9.5 + 30, 0]) cube([44 + tolerance + 2 * wall_t - 20, 4, 4]);
        
        
        translate([17, (44 + tolerance + 2 * wall_t) / 2 - 7 + wall_t, -1]) cube([7, 14, 4]);
    }
    
}