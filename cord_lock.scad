/**
A cord lock, like on your blinds, the thing where
you pull it to raise the blinds, and depending on the
angle you let go it either lets the blinds down,
or catches.

Save each of the three pieces (gear, lid, body)
to their own STL; I don't think they're quite
z-aligned, and I had a print fail because
I didn't notice.

I added a cutout under the rack, to accomodate
elephant's foot on the gear.

Careful!  Make sure the lip is present on the body (if not DUMMY mode).
Flush caches and rerender if it's not present.
*/

use <deps.link/BOSL/nema_steppers.scad>
use <deps.link/BOSL/joiners.scad>
use <deps.link/erhannisScad/misc.scad>
use <deps.link/erhannisScad/auto_lid.scad>
use <deps.link/scadFluidics/common.scad>
use <deps.link/quickfitPlate/blank_plate.scad>
use <deps.link/getriebe/Getriebe.scad>
use <deps.link/gearbox/gearbox.scad>

$FOREVER = 1000;
DUMMY = false;
$fn = DUMMY ? 10 : 60;

WALL_T = 3;
BLOCK_T = 5;
BLOCK_H = 60;
RETURN_W = 10;
RACK_A = 15;
RACK_H = WALL_T*1.5;
SHELF_T = 1;

COVER_T = 1.5;

//ty(-20) circle(d=24.26);

TEETH = 11;

// Gear
rotate([0,0,-RACK_A]) translate([BLOCK_H-11,13-40,-COVER_T])
    stirnrad(modul=1, zahnzahl=TEETH, breite=BLOCK_T-0.2, bohrung=0, eingriffswinkel=20, schraegungswinkel=0, optimiert=false);
GEAR_DIMS = pfeilrad_dims(modul=1, zahnzahl=TEETH, breite=BLOCK_T, bohrung=0, eingriffswinkel=20, schraegungswinkel=0, optimiert=false);

LW = RETURN_W*(0.8+1)+(WALL_T)*2+2;
TOP_X = WALL_T/2;
MID_Y = LW-RETURN_W-WALL_T;
echo(LW,RETURN_W,WALL_T,MID_Y);
GEAR_IX0 = (RACK_H+GEAR_DIMS[0]*1.1)/cos(RACK_A);
GEAR_IX = -BLOCK_H*tan(RACK_A)+GEAR_IX0+WALL_T/2;


module shelf() {
    MEET_X = BLOCK_H-(MID_Y-GEAR_IX)/tan(RACK_A);
    channel([BLOCK_H,-BLOCK_H*tan(RACK_A)],[BLOCK_H,GEAR_IX],d=WALL_T,cap="circle");
    channel([BLOCK_H,GEAR_IX],[MEET_X,MID_Y],d=WALL_T,cap="circle");
}

module body() {
    difference() {
        rotate([0,0,-RACK_A]) difference() {
            zahnstange(modul=1, laenge=BLOCK_H/cos(RACK_A), hoehe=RACK_H, breite=BLOCK_T, eingriffswinkel=20, schraegungswinkel=0);
            RACK_DIMS = zahnstange_dims(modul=1, laenge=BLOCK_H/cos(RACK_A), hoehe=RACK_H, breite=BLOCK_T, eingriffswinkel=20, schraegungswinkel=0);
            // Hmm...I dunno, the dims seem wrong; had to hardcode a factor.
            ty(RACK_DIMS[3]-RACK_DIMS[2]*2.5) rotate([45,0,0]) OZm();
        }
        OXp([BLOCK_H,0,0]);
        linear_extrude(height=$FOREVER)shelf();
    }
    
    linear_extrude(height=BLOCK_T) {
        channel([TOP_X,0],[TOP_X,LW],d=WALL_T);
        channel([TOP_X,LW],[TOP_X,LW],d=WALL_T,cap="circle");
        channel([TOP_X,LW],[BLOCK_H,LW],d=WALL_T,cap="circle");
        channel([TOP_X+RETURN_W+WALL_T,MID_Y],[BLOCK_H,MID_Y],d=WALL_T,cap="circle");
    }
}

// Lid
if (!DUMMY) {
    translate([-10,0,BLOCK_T+4.5-COVER_T]) rotate([0,180,0]) autolid(lid=true,top_z=BLOCK_T,thick=COVER_T) {
        body();
    }
}

// Body
union() {
    if (DUMMY) {
        body();
    } else {
        autolid(lid=false,top_z=BLOCK_T,thick=COVER_T) {
            body();
        }
    }

    // Nail tabs
    rotate([0,0,90-RACK_A]) translate([0,-11*1.5/2,-COVER_T]) nailTab(t=COVER_T);
    rotate([0,0,90-RACK_A]) translate([0,-BLOCK_H-(-11*1.5/2),-COVER_T]) nailTab(t=COVER_T);
    translate([11*1.5/2+WALL_T/2,LW+WALL_T/2,-COVER_T]) rotate([0,0,-90]) nailTab(t=COVER_T);
    translate([BLOCK_H-11*1.5/2,LW+WALL_T/2,-COVER_T]) rotate([0,0,-90]) nailTab(t=COVER_T);

    translate([0,0,BLOCK_T/2]) cmirror([0,0,0]) translate([0,0,-BLOCK_T/2])
    {
        difference() {
            translate([0,0,-COVER_T]) scale([1,1,1000]) hull() union() {
                body();
                linear_extrude(height=SHELF_T) {
                    shelf();
                }
            }
            scale([1,1,20]) OZp();
        }
        difference() {
            linear_extrude(height=SHELF_T) {
                shelf();
            }
            body();
        }
    }
}
