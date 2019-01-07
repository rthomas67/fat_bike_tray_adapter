// Thule Fat Bike Tray Adapter

* color([1,0,0])
    translate([0,0,0.1])  // offset for top/bottom compare
        import("fat_bike_tray_adapter_shape_test_print_01.stl");

testPrint=true;

overallLength= (testPrint) ? 10 : 160;

roundnessRadius=5;

tireDia=130;

topEdgeThickness=10;

fatTrayFullWidth=tireDia+topEdgeThickness*2;

trayInnerWidth=62;

thuleTraySideConcavityDia=100;

trayBottomWidth=22;
trayBottomCornerDia=3;

// "tighness" of the convex curve
trayBottomConvexCurveDia=18;
// vertical size of the horizontal slice across the part where there
// is a convex curve in the tray wall, just above the channel
trayBottomConvexCurveHeight=7.5;

curveMatchOffset=4;

overhangThickness=12;
overhangDepth=5;
overhangWidth=30;
overhangFlairAngle=15;
// how much to push out the rotated notches so they mesh
// smoothly with the top edges of the "bowl"
overhangFlairAdjust=2.6;

overhangEdgeCurveDia=10;

// How much to cut off the top of the "bowl" part
// of the tray shape at the top (and move it up)
// to match blend smoothly with the flair angle
// This could probably be calculated with sin/cos
// based on the angle and the diameter of the bowl
// (which is currently / wrongly "trayInnerWidth")
topEdgeCurveMatchOffset=4;

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
        difference() {
            square([tireDia+2*topEdgeThickness,
                    tireDia/2], center=true);
            translate([0,tireDia/4])
                circle(d=tireDia);
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
    // center/bottom part
    hull() {
        translate([trayBottomWidth/2-trayBottomCornerDia/2,0])
            circle(d=trayBottomCornerDia);
        translate([-trayBottomWidth/2+trayBottomCornerDia/2,0])
            circle(d=trayBottomCornerDia);
        translate([0,trayBottomCornerDia])
            square([trayBottomWidth,trayBottomCornerDia],center=true);
    }
    // convex transition curve from bottom to concave side 
    difference() {
        translate([0,trayBottomConvexCurveHeight/2])
            square([trayBottomWidth+trayBottomConvexCurveDia,
                trayBottomConvexCurveHeight], center=true);
        translate([trayBottomWidth/2+trayBottomConvexCurveDia/2,0])
            circle(d=trayBottomConvexCurveDia);
        translate([-trayBottomWidth/2-trayBottomConvexCurveDia/2,0])
            circle(d=trayBottomConvexCurveDia);
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