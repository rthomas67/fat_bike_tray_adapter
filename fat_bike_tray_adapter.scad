// Thule Fat Bike Tray Adapter

 * color([1,0,0])
    translate([0,5,-5.5])  // offset for top/bottom compare
        import("fat_bike_tray_adapter_shape_test_print_02.stl");

testPrint=true;

overallLength= (testPrint) ? 5 : 110;

roundnessRadius=5;

tireDia=130;

topEdgeThickness=10;

fatTrayFullWidth=tireDia+topEdgeThickness*2;

trayInnerWidth=62;

thuleTraySideConcavityDia=100;

trayBottomWidth=22;
trayBottomCornerDia=4;
// exit angle of 90 would be vertical.  less than 90
// means the part needs to be sliced at the top and
// the next curve should be sliced off at the bottom
// to match the curve.
trayBottomCornerExitAngle=70;
trayBottomCornerTrimHeight=cos(trayBottomCornerExitAngle)
    *(trayBottomCornerDia/2);

// "tighness" of the convex curve
trayBottomConvexCurveDia=45;
// vertical size of the horizontal slice across the part where there
// is a convex curve in the tray wall, just above the channel
trayBottomConvexCurveHeight=7.5;

curveMatchOffset=4.2;

overhangThickness=16;
overhangDepth=8;
overhangWidth=30;
overhangFlairAngle=20;
// how much to push out the rotated notches so they mesh
// smoothly with the top edges of the "bowl"
overhangFlairAdjust=1.25;

overhangEdgeCurveDia=10;

// How much to cut off the top of the "bowl" part
// of the tray shape at the top (and move it up)
// to match blend smoothly with the flair angle
// This could probably be calculated with sin/cos
// based on the angle and the diameter of the bowl
// (which is currently / wrongly "trayInnerWidth")
topEdgeCurveMatchOffset=9;

trayEdgeThickness=5;


$fn=50;
overlap=0.01;

linear_extrude(height=overallLength) {
    completeShapeOutline();
    // TODO: "cut" slots for straps
}

module completeShapeOutline() {
    union() {
        translate([0,-trayInnerWidth/2
                -trayBottomConvexCurveHeight
                +topEdgeCurveMatchOffset])
            bottomShape();   
//        color([0,1,0])
            overhang();
        translate([0,overhangThickness/2-overlap])
            topShape(); 
    }
}

module topShape() {
    translate([0,tireDia/4])  // return it sitting on the x-axis
        union() {
            difference() {
                square([tireDia+2*topEdgeThickness,
                        tireDia/2], center=true);
                translate([0,tireDia/4])
                    circle(d=tireDia);
            }
            translate([tireDia/2+topEdgeThickness/2,tireDia/4-overlap])
                circle(d=topEdgeThickness);
            translate([-tireDia/2-topEdgeThickness/2,tireDia/4-overlap])
                circle(d=topEdgeThickness);
        }
}

module overhang() {
    difference() {
        hull() {
            square([overhangWidth*2+trayInnerWidth,overhangThickness], 
                    center=true);
            // end-pieces (transition for the overhang block)
            // Note: Full circle would add height or wouldn't be
            // tangent to the vertical edge.
            translate([fatTrayFullWidth/2-overhangEdgeCurveDia/2,
                    overhangThickness/2,0])
                lowerHalfCircle(overhangEdgeCurveDia);
            translate([-fatTrayFullWidth/2+overhangEdgeCurveDia/2,
                    overhangThickness/2,0])
                lowerHalfCircle(overhangEdgeCurveDia);
        
        }
        translate([trayInnerWidth/2+overhangFlairAdjust,
                -overhangThickness/2+overhangDepth/2])
            rotate([0,0,-overhangFlairAngle])
                square([trayEdgeThickness,overhangDepth*2], 
                    center=true);
        translate([-trayInnerWidth/2-overhangFlairAdjust,
                -overhangThickness/2+overhangDepth/2])
            rotate([0,0,overhangFlairAngle])
            square([trayEdgeThickness,overhangDepth*2], center=true);
    }
}

module bottomShape() {
    translate([0,0,0])
        centerBottomChannelShape();
    // "bowl" shape to match the concave inside of the tray
    // 1) Move up-y to sit on top of the centerBottomChannelShape
    // 2) Move back down so the curves with the curves mesh
    //    (note: This must include the amount cut off the bowl-top)
    translate([0,trayInnerWidth/2+trayBottomConvexCurveHeight
            -curveMatchOffset-topEdgeCurveMatchOffset])
        difference() {
            translate([0,topEdgeCurveMatchOffset,0])
                circle(d=trayInnerWidth);
            translate([0,trayInnerWidth/2+overlap])
                square([trayInnerWidth+overlap*2,
                        trayInnerWidth+overlap],
                        center=true);
        }
}

module centerBottomChannelShape() {
    centerBottomChannel();
    centerBottomTransition();
} 

module centerBottomChannel() {
    // center/bottom part
    hull() {
        translate([trayBottomWidth/2-trayBottomCornerDia/2,0])
            slicedCircle(trayBottomCornerDia,trayBottomCornerExitAngle);
        translate([-trayBottomWidth/2+trayBottomCornerDia/2,0])
            slicedCircle(trayBottomCornerDia,trayBottomCornerExitAngle);
*        translate([0,trayBottomCornerDia])
            polygon(points = [
                [-trayBottomWidth/2,0],
                [trayBottomWidth/2,0],
                [trayBottomWidth/2,trayBottomCornerDia],
                [-trayBottomWidth/2,trayBottomCornerDia]], center=true);
        // square([trayBottomWidth,trayBottomCornerDia],center=true);
    }
}

module centerBottomTransition() {
    // convex transition curve from bottom to concave side 
    difference() {
        translate([0,trayBottomConvexCurveHeight/2])
            square([trayBottomWidth+trayBottomConvexCurveDia,
                trayBottomConvexCurveHeight], center=true);
        // the circle cut doesn't start at the 90 / side of the circle
        // so it needs to be inset a bit to mesh.  This calculates
        // where that mesh point should be.
        meshPointOffset = (trayBottomConvexCurveDia/2 -
            sin(trayBottomCornerExitAngle)*trayBottomConvexCurveDia/2)
            + (trayBottomCornerDia/2 - 
            sin(trayBottomCornerExitAngle)*trayBottomCornerDia/2);
        translate([trayBottomWidth/2+trayBottomConvexCurveDia/2
                -meshPointOffset,0])
            rotate([0,0,180])
            slicedCircle(trayBottomConvexCurveDia,trayBottomCornerExitAngle);
        translate([-trayBottomWidth/2-trayBottomConvexCurveDia/2
                +meshPointOffset,0])
            rotate([0,0,180])
            slicedCircle(trayBottomConvexCurveDia,trayBottomCornerExitAngle);
    }
}

// sliceAngle is the tangent angle where the circle will be cut off
// parallel to the x-axis
module slicedCircle(circleDia, sliceAngle) {
    offset = cos(sliceAngle)*circleDia/2;
    difference() {
        translate([0,offset])
            circle(d=circleDia);
        translate([0,circleDia/2+overlap])
            square([circleDia+overlap*2,circleDia+overlap*2], center=true);
        
    }
}

module lowerHalfCircle(lowerHalfCircleDia) {
    difference() {
        circle(d=lowerHalfCircleDia);
        translate([0,lowerHalfCircleDia/2])
            square([lowerHalfCircleDia+overlap*2,lowerHalfCircleDia], 
                center=true);
    }
}