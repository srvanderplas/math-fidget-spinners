// General Variables
// Call script with -D 'm=15;'
m=10;//insert-m-here
clearance = 0.24;   // clearance between teeth
center_text_multiple = 2; // size multiplier for center text
planet_text_multiples = [.7, .5];
$fn = 50;
myfont = "Atkinson Hyperlegible:style=Bold";
stext = [ "B", "l", "u", "e", "s", "t", "e", "m" ];
//stext = [];

include <gear-fns.scad>;

/*  Planetary Gear; uses the Modules "herringbone_gear" and "herringbone_ring_gear"
    modul = Height of the Tooth Tip over the Partial Cone
    sun_teeth = Number of Teeth of the Sun Gear
    planet_teeth = Number of Teeth of a Planet Gear
    number_planets = Number of Planet Gears. If null, the Function will calculate the Minimum Number
    width = tooth_width
    rim_width = Width of the Rim from the Root Circle
    bore = Diameter of the Center Hole
    pressure_angle = Pressure Angle, Standard = 20° according to DIN 867. Should not exceed 45°.
    helix_angle = Helix Angle to the Axis of Rotation, Standard = 0° (Spur Teeth)
    together_built =
    optimized = Create holes for Material-/Weight-Saving or Surface Enhancements where Geometry allows
    together_built = Components assembled for Construction or separated for 3D-Printing */
module planetary_gear(multiple=3, text_height = 2, text_size = 5, embed_text = stext, modul, sun_teeth, planet_teeth, number_planets, width, rim_width, bore, pressure_angle=20, helix_angle=20, together_built=true, optimized=true){

    // Dimension Calculations
    // Sun Pitch Circle Diameter
    d_sun = modul*sun_teeth;            
    // Planet Pitch Circle Diameter    
    d_planet = modul*planet_teeth;                      
    // Distance from Sun- or Ring-Gear Axis to Planet Axis
    center_distance = modul*(sun_teeth +  planet_teeth) / 2;        
    // Number of Teeth of the Ring Gear
    ring_teeth = sun_teeth + 2*planet_teeth;             
    // Ring Pitch Circle Diameter 
    d_ring = modul*ring_teeth;                                 

    // Does the Sun Gear need to be rotated?
    rotate = is_even(planet_teeth);                                

    // Number of Planet Gears: at most as many as possible without overlap
    n_max = floor(180/asin(modul*(planet_teeth)/(modul*(sun_teeth + planet_teeth))));
    echo(Max_Planets=n_max);
    number_planets = (number_planets==undef) ? n_max : number_planets;

    div_font_scale = multiple*12>100 ? planet_text_multiples[1] : planet_text_multiples[0];
    RADIUS=d_ring/2+rim_width;
    ARC_ANGLE=180;
    chars = len( embed_text );
    
    sun_text=[str("+    ", multiple), str("-    ", multiple)];

    // Sun Gear
    union(){
        difference(){
            
            // Drawing
            rotate([0,0,180/sun_teeth*rotate]){
                color("black")
                herringbone_gear (modul, sun_teeth, width, bore, pressure_angle, -helix_angle, optimized);
            }
           
            // text
            translate([0,0, width-text_height])
            linear_extrude(height = text_height)
            text(sun_text[0], size = text_size*center_text_multiple, font=myfont, halign="center", valign="center");
            
            rotate([180,0,180])
            translate([0, 0, -text_height])
            linear_extrude(height = text_height)
            text(sun_text[1], size = text_size*center_text_multiple, font=myfont,halign="center", valign="center");
           
        }

        // text
        // top side
        color("white")
        translate([0,0, width-text_height+0.001])
        linear_extrude(height = text_height)
            text(sun_text[0], size = text_size*center_text_multiple, font=myfont, halign="center", valign="center");
        
        // bottom side
        color("white")
        rotate([180,0,180])
        translate([0, 0, -text_height-0.001])
        linear_extrude(height = text_height)
        text(sun_text[1], size = text_size*center_text_multiple, font=myfont,halign="center", valign="center");
    }
    
    if (together_built){
        if(number_planets==0){
            list = [ for (n=[2 : 1 : n_max]) if ((((ring_teeth+sun_teeth)/n)==floor((ring_teeth+sun_teeth)/n))) n];
            number_planets = list[0];                                      // Determine Number of Planet Gears
             center_distance = modul*(sun_teeth + planet_teeth)/2;      // Distance from Sun- / Ring-Gear Axis
            for(n=[0:1:number_planets-1]){
                translate(sphere_to_cartesian([center_distance,90,360/number_planets*n]))
                    rotate([0,0,n*360*d_sun/d_planet])
                        herringbone_gear (modul, planet_teeth, width, bore, pressure_angle, helix_angle, optimized); // Planet Gears
            }
       }
       else{
            center_distance = modul*(sun_teeth + planet_teeth)/2;       // Distance from Sun- / Ring-Gear Axis
            for(n=[0:1:number_planets-1]){
                
                text = [str(n+1), str(multiple + (n+1))];
                translate(sphere_to_cartesian([center_distance,90,360/number_planets*n]))
                rotate([0,0,n*360*d_sun/(d_planet)])
                    union(){
                        difference(){
                                
                            // Planet Gears
                            color("black")
                            herringbone_gear (modul, planet_teeth, width, bore, pressure_angle, helix_angle, optimized);
                            union(){
                                // text
                                // top side -- addition
                                translate([0,0,width-text_height])
                                linear_extrude(height = text_height)
                                text(text[0], size = text_size, font=myfont,halign="center", valign="center");
                                
                                // bottom side -- subtraction
                                rotate([180,0,180])
                                translate([0, 0, -text_height])
                                linear_extrude(height = text_height)
                                text(text[1], size = text_size, font=myfont, halign="center", valign="center");
                            }
                            
                        }
                        
                        // text
                        // top side -- multiplication
                        color("white")
                        translate([0,0,width-text_height+0.001])
                        linear_extrude(height = text_height)
                        text(text[0], size = text_size, font=myfont,halign="center", valign="center");

                        // div text
                        rotate([180,0,180])
                        translate([0, 0, -text_height-0.001])
                        color("white")
                        linear_extrude(height = text_height)
                        text(text[1], size = text_size, font=myfont, halign="center", valign="center");
                    }
            }
        }
    }
    else{
        planet_distance = ring_teeth*modul/2+rim_width+d_planet;     // Distance between Planets
        for(i=[-(number_planets-1):2:(number_planets-1)]){
            translate([planet_distance, d_planet*i,0])
                herringbone_gear (modul, planet_teeth, width, bore, pressure_angle, helix_angle, optimized); // Planet Gears
        }
    }

    if ( chars > 0) {
        
        difference() {
            
        color("black")
        herringbone_ring_gear (modul, ring_teeth, width, rim_width, pressure_angle, helix_angle); // Ring Gear
        

        for(i=[0:1:chars]){
            rotate([0,0,i*ARC_ANGLE/chars]){
                translate( [RADIUS,0,width/2])
                  rotate([90,0,90])
                  linear_extrude(.7)
                  text(embed_text[i],size=text_size,font="Atkinson Hyperlegible",valign="center",halign="center");
                }
            }
        }
        
        for(i=[0:1:chars]){
        rotate([0,0,i*ARC_ANGLE/chars]){
            translate( [RADIUS,0,width/2])
              rotate([90,0,90])
              color("white")
              linear_extrude(.7)
              text(embed_text[i],size=text_size,font="Atkinson Hyperlegible",valign="center",halign="center");
            }
        }
    } else {
        color("black")
        herringbone_ring_gear (modul, ring_teeth, width, rim_width, pressure_angle, helix_angle); // Ring Gear
    }
}

scale([1.4, 1.4, 1.4])
difference() {
    planetary_gear(multiple = m, number_planets = 15, modul = 0.5, sun_teeth=100, planet_teeth=20, width = 10, helix_angle = 20, pressure_angle = 20, rim_width=2, optimized = false, bore = 0);
    
    translate([0, 0, -2])
    cylinder(r=3, h=12, $fn=6);
}

//rack(modul=1, length=60, height=5, width=20, pressure_angle=20, helix_angle=0);

//mountable_rack(modul=1, length=60, height=5, width=20, pressure_angle=20, helix_angle=0, profile=3, head="PH",fastners=3);

//herringbone_rack(modul=1, length=60, height=5, width=20, pressure_angle=20, helix_angle=45);

//mountable_herringbone_rack(modul=1, length=60, height=5, width=20, pressure_angle=20, helix_angle=45, profile=3, head="PH",fastners=3);

//spur_gear (modul=1, tooth_number=30, width=5, bore=4, pressure_angle=20, helix_angle=20, optimized=true);

//herringbone_gear (modul=1, tooth_number=30, width=5, bore=4, pressure_angle=20, helix_angle=30, optimized=true);

//rack_and_pinion (modul=1, rack_length=50, gear_teeth=30, rack_height=4, gear_bore=4, width=5, pressure_angle=20, helix_angle=0, together_built=true, optimized=true);

//ring_gear (modul=1, tooth_number=30, width=5, rim_width=3, pressure_angle=20, helix_angle=20);

//herringbone_ring_gear (modul=1, tooth_number=30, width=5, rim_width=3, pressure_angle=20, helix_angle=30);

//planetary_gear(modul=1, sun_teeth=16, planet_teeth=9, number_planets=5, width=5, rim_width=3, bore=4, pressure_angle=20, helix_angle=30, together_built=true, optimized=true);

//planetary_gear(modul=2, sun_teeth=16, planet_teeth=9, number_planets=5, width=5, rim_width=3, bore=4, pressure_angle=20, helix_angle=30, together_built=true, optimized=false);

//bevel_gear(modul=1, tooth_number=30,  partial_cone_angle=45, tooth_width=5, bore=4, pressure_angle=20, helix_angle=20);

//bevel_herringbone_gear(modul=1, tooth_number=30, partial_cone_angle=45, tooth_width=5, bore=4, pressure_angle=20, helix_angle=30);

//bevel_gear_pair(modul=1, gear_teeth=30, pinion_teeth=11, axis_angle=100, tooth_width=5, gear_bore=4, pinion_bore=4, pressure_angle = 20, helix_angle=20, together_built=true);

/*
bevel_herringbone_gear_pair(
    modul=1,
    gear_teeth=114,
    pinion_teeth=11,
    axis_angle=90,
    tooth_width=5,
    gear_bore=0,
    pinion_bore=4,
    pressure_angle=20,
    helix_angle=20,
    together_built=true);
*/

//worm(modul=1, thread_starts=2, length=15, bore=4, pressure_angle=20, lead_angle=10, together_built=true);

//worm_gear(modul=1, tooth_number=30, thread_starts=2, width=8, length=20, worm_bore=4, gear_bore=4, pressure_angle=20, lead_angle=10, optimized=1, together_built=1, show_spur=1, show_worm=1);
