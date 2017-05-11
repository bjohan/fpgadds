module triplicate(){
     space = (100-12-21*3)/4;
    translate([0, space+10.5, 0]){
    translate([0, 0, 0])
        children();
    
    translate([0, 21+space, 0])
        children();

    translate([0, (21+space)*2, 0])
        children();
    }
}


module cooler(){
    translate([0,-21/2, 0]){
        color([0.5, 0.5, 0.5])
           cube([21, 21, 15]);
    }
}

module board(){
    //Subtract 12 to approximate usable board area
    cube([35, 100-12, 1]);
}

module quadCyl(sx, sy, sz, r){
    x = sx;
    y = sy;
    

    translate([x, y, 0])
        cylinder(sz, r, r);
    translate([x, -y, 0])
        cylinder(sz, r, r);
    translate([-x, y, 0])
        cylinder(sz, r, r);
    translate([-x, -y, 0])
        cylinder(sz, r, r);

}


module roundedPlate(sx, sy, sz, r){
    x = sx/2-r;
    y = sy/2-r;
    
    hull(){
        quadCyl(x, y, sz, r);
    }
}

module fanBody(){
    difference(){
        union(){
            roundedPlate(30, 30, 3, 3);
        
            translate([0,0,3])
                rotate([0,0,360/16])
                    cylinder(7, 16, 16, $fn=8);
            quadCyl(12,12,10,3);
        }
        translate([0, 0, -1])
            cylinder(15, 14.5, 14.5);
    }
}

module fanHoles(r, l){
           quadCyl(12,12,l,r);
}
module fan(){
    color([0,0,0])
        difference(){
            fanBody();
            translate([0, 0, -1]){
                fanHoles(1.5, 15);
            }
        }
        //cube([30, 30, 11]);
}

module coolers(){
    triplicate()
        cooler();
    
}

module to220term(){
    color([0.5, 0.5, 0.5])
        translate([-14, 0, 0])
            cube([14, 1, 0.5]);
}

module to220(){
    color([0.5, 0.5, 0.5])
    cube([15.5, 10.5, 1]);
    color([0, 0, 0])
    translate([0,0,1])
    cube([9, 10.5, 3]);
    translate([0,-0.3, 0]){
        translate([0, 2, 2])
            to220term();
        translate([0, 5, 2])
            to220term();
        translate([0, 8, 2])
            to220term();
    }
}

module to220c(){
    translate([20,0,5])
        translate([0, -10.5/2, 0])
            rotate([180,0,-180])
                to220();
}


module regulators(){
    triplicate()
        to220c();
}

module duct(){
    triplicate()
    translate([0,0,24])
        rotate([0,90,0])
            cylinder(21, 4, 4);
    translate([-9/2, 0, 0])
    %cube([30, 88, 30]);
}

duct();

module componentsAssembly(){
regulators();
translate([0,0,5])
coolers();
board();
translate([21/2,88/2,30])
fan();
}

componentsAssembly();
