/* [Render Options] */
// number of fragments
$fn = 100; // [10,30,50,100]
part_to_render = 2; // [1:PartA, 2:PartB, 3:Container, 4:PartA_B, 5:All, 6:BLE, 7:AudioJack, 8:Test]

/* [Board Dimensions]  */
// Width
board_w = 32;
// Length
board_l = 32;
// Thickness
board_t = 2.1;

/* [USB Connector] */
usb_w = 8.4;
usb_l = 6.2;
usb_t = 3.6;
usb_l_offset = 2.5;
usb_w_offset = 6.2; // 8.8 from center

/* [AudioJack] */
j_w = 7;
j_l = 13;
j_t = 5;
j_l_offset = 29.5;
j_w_offset = -10;   // 5.0 from center
j_r = 2.51;         // radius
j_c = 5;            // cylinder height

/* [Container] */
gap_below_board = 1;
gap_above_board = 8;
// Wall Thickness
bb_t = 2.5;
// Fit_Tolerance
Fit_Tolerance = 0.1;
// lid position
split_lip_offset = 22;
split_lip_width = 5;
split_lip_grip_offset = split_lip_offset + split_lip_width/2;


/* Calculated Values */
lip_l = split_lip_width;
lip_offset = split_lip_grip_offset;
ibb_w = board_w;
ibb_l = board_l;
ibb_h = board_t + gap_below_board + gap_above_board; 

bb_w = ibb_w + 2*bb_t;
bb_l = board_l + 2*bb_t;
bb_h = ibb_h + 2*bb_t;// + con_t2;

module jack() {
    // audio jack containing volume
    translate([board_w/2-j_w/2+j_w_offset, 0,board_t+gap_below_board])
     union() {
         color("black")
         cube([j_w, j_l, j_t]);
         color("yellow")
         rotate([90,0,0])
         translate([j_w/2,j_t/2,0])
         cylinder(h=j_c,r=j_r, center = true);
     };
 }   
    

module ble (origin=[0,0,0]) {
  // object that creates volume presenting board dimension
  jack();
  color("purple")
    translate([board_w/2-usb_w/2+usb_w_offset, -usb_l_offset,board_t+gap_below_board])
    cube([usb_w, usb_l, usb_t]);
  cube([board_w, board_l, board_t+gap_below_board]);
  color("yellow", 0.15)
    translate([0,0,board_t+gap_below_board])
    cube([board_w, board_l, gap_above_board]);
  color("yellow")
    translate([0,0,0])
    cube([board_w, board_l, gap_below_board]);
}

module semi_rnd_cube(vec, rf=10, z_center=false) {
  f_r = vec.z/rf;
  x = vec.x - 2*f_r;
  y = vec.y - 2*f_r;
  z = vec.z;
  x_pos = x/2;
  y_pos = y/2;
  z_pos = z_center == false ? 0 : (-z/2);
            
  v = [f_r, z];
  translate([-x_pos, -y_pos, z_pos])
    cube([x, y, z]);

  translate([x_pos, 0,  z_pos])
    rotate([90,0,0])
    linear_extrude(height = y, center = true, convexity = 1, twist = 0, $fn=64)
    square(v);
            
  translate([x_pos,y_pos, z_pos])
    rotate_extrude(angle = 90, $fn=64)
    square(v);
            
  translate([0, y_pos, z_pos])
    rotate([90,0,90])
    linear_extrude(height = x, center = true, convexity = 1, twist = 0, $fn=64)
    square(v);
            
  rotate([0,0,90])
    translate([y_pos,x_pos,z_pos])
    rotate_extrude(angle = 90, $fn=64)
    square(v);
                        
  rotate([0,0,180]){
    translate([x_pos, 0, z_pos])
      rotate([90,0,0])
      linear_extrude(height = y, center = true, convexity = 1, twist = 0, $fn=64)
      square(v);
            
    translate([x_pos, y_pos, z_pos])
      rotate_extrude(angle = 90, $fn=64)
      square(v);
            
    translate([0, y_pos, z_pos])
      rotate([90,0,90])
      linear_extrude(height = x, center = true, convexity = 1, twist = 0, $fn=64)
      square(v);
            
    rotate([0,0,90])
      translate([y_pos, x_pos,z_pos])
      rotate_extrude(angle = 90, $fn=64)
      square(v);
  }
}

module r_cube(l, w, h) {
  r = 0.1*min(l,w,h);
  minkowski() {
    translate([r/2,r/2,r/2])
      cube([l-2*r,w-2*r,h-2*r]);    
    translate([r/2,r/2,r/2])
      sphere(r=r);
  }
}

module rod(d, h) {
  
  rotate([90,0,0])
    union() {
    translate([0,0,-(h-d)/2])
      sphere(r=d/2);
    cylinder(d=d, h=h-d,center=true);
    translate([0,0,(h-d)/2])
      sphere(r=d/2);
  } 
}

module snap_joint_lip(part=1) {
  if (part == 1) {
    // Cut lip internal
    translate([bb_l-lip_l-bb_t-split_lip_offset,bb_w/2,bb_h/2]) rotate([90,0,90])
      semi_rnd_cube([bb_w-bb_t+Fit_Tolerance, bb_h-bb_t+Fit_Tolerance, lip_l]);

    // cut unwanted section from render
    translate([0,0,0])
      rotate([0,0,0])
      cube([bb_l-lip_l-bb_t-split_lip_offset, bb_w, bb_h]);
  }

  if (part == 2) {
    // Cut exposed lip
    difference() {
      translate([bb_l-lip_l-bb_t-split_lip_offset,bb_w/2,bb_h/2]) rotate([90,0,90])
        semi_rnd_cube([bb_w, bb_h, lip_l]);
      translate([bb_l-lip_l-bb_t-split_lip_offset,bb_w/2,bb_h/2]) rotate([90,0,90])
        semi_rnd_cube([bb_w-bb_t-Fit_Tolerance, bb_h-bb_t-Fit_Tolerance, lip_l]);


    }
    // cut unwanted section from render
    translate([bb_l-bb_t-split_lip_offset,0,0])
      rotate([0,0,0])
      cube([bb_l, bb_w, bb_h]);

  }
}

module snap_joint_grips() {
  translate([bb_l-lip_l/2-bb_t-split_lip_offset, bb_w/4, bb_t/2])
    rod(bb_t/4, bb_w/4-bb_t-1 );
  translate([bb_l-lip_l/2-bb_t-split_lip_offset, bb_w/2, bb_t/2])
    rod(bb_t/4, bb_w/4-bb_t-1 );
  translate([bb_l-lip_l/2-bb_t-split_lip_offset, 3*bb_w/4, bb_t/2])
    rod(bb_t/4, bb_w/4-bb_t-1 );
  // Top grips
  translate([bb_l-lip_l/2-bb_t-split_lip_offset, bb_w/4, bb_h-bb_t/2])
    rod(bb_t/4, bb_w/4-bb_t-1 );
  translate([bb_l-lip_l/2-bb_t-split_lip_offset, bb_w/2, bb_h-bb_t/2])
    rod(bb_t/4, bb_w/4-bb_t-1 );
  translate([bb_l-lip_l/2-bb_t-split_lip_offset, 3*bb_w/4, bb_h-bb_t/2])
    rod(bb_t/4, bb_w/4-bb_t-1 );
}

module split_container(part=1) {
    
  union() {
    difference() {
      // main box
      r_cube(bb_l, bb_w , bb_h);
    
      // bounding object for board represeting cavity required to hold board
      translate([board_l+bb_t,bb_t,bb_t])
        rotate([0,0,90])
        ble();

      snap_joint_lip(part);
      
      if(part == 2) {
        snap_joint_grips();
      }
      // lip grips negative
      // Bottom grips
      
    }
      
    
  }
  if (part == 1) {
    // lip grips postive
    // Bottom grips
    snap_joint_grips();
  }
}   

// Select parts to render
if (part_to_render == 1) {
  split_container();
 }

if (part_to_render == 2) {
  split_container(part=2);
 }

if (part_to_render == 3) {
  split_container();
  split_container(part=2);
 }

if (part_to_render == 4) {
  split_container();
  translate([-10,0,0])
    split_container(part=2);
 }

if (part_to_render == 5) {
  split_container();
    
  translate([-5-bb_l,0,0])
    translate([board_l+bb_t,bb_t,bb_t])
    rotate([0,0,90])
    ble();
    
  translate([-25-bb_l,0,0])
    split_container(part=2);

 }
 
 if (part_to_render == 6) {
     ble();
 }

 if (part_to_render == 7) {
    jack();
 }
 
 if (part_to_render == 8) {
     union() {
        %snap_joint_lip(2);
        snap_joint_grips();
        translate([board_l+bb_t,bb_t,bb_t])
            rotate([0,0,90])
            ble();
     }
 }





