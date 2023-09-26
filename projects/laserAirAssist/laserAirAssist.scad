use <MCAD/boxes.scad>

$fa = $preview ? 12 : 1;
$fs = $preview ? 1 : 0.1;

tolerance = 0.001;
fullRender = true;                        // don't use stl file for improved render performance

baseWidth = 49.75;                         // total outer side width, x/y axis
baseThickness = 2.5;                       // thickness, z axis
wallThickness = 2;                         // difference between inner cutout and outer side width
boltHoleRadius = 3.5 / 2; 
boltHoleSpacing = 43.65;                   // outer edge to outer edge
tubeRadius = 20 / 2;
tubeOuterRadius = 23.85 / 2;
tubeHeight = 14;
rampToTubeTransitionHeight = 5;
capWidth = 32;
topOfCapHeight = 15.2;
capTopHoleRadius = 24 / 2;
topOfFirstTransition = 16.4;
radiusAfterFirstTransition = 29.8 / 2;
topOfSecondTransition = 21;
topOfThinTube = 19;
countersinkDepth = 0.5;
countersinkRadius = 4 / 2;
feederTubeOuterRadius = 4.2 / 2;
ductWallThickness = 1;
feederTubeOverlap = 1.75;
nozzleRadius = 1;
nozzleLength = 7;
nozzleAngle = 15;

rampHeight = 13.5 - baseThickness;
boltHoleWallRadius = boltHoleRadius + wallThickness * 1.5;
wallOverlap = wallThickness - ((baseWidth - boltHoleSpacing) / 2 - (boltHoleWallRadius - boltHoleRadius));
roundingBlockLength = boltHoleWallRadius * 2 - wallOverlap;
capThickness = topOfCapHeight - rampHeight - baseThickness;
firstTransitionThickness = topOfFirstTransition - topOfCapHeight;
thinTubeThickness = topOfThinTube - topOfFirstTransition;
secondTransitionThickness = topOfSecondTransition - topOfThinTube;

module stockNozzle() {
	module boltHole() {
		module positiveBlock() {
			cylinder(baseThickness, r=boltHoleWallRadius, center=true);
			translate([-1 * boltHoleWallRadius / 2, roundingBlockLength / 2, 0])
				cube([
					boltHoleWallRadius,
					roundingBlockLength,
					baseThickness,
				], center=true);
			translate([roundingBlockLength / 2, -1 * boltHoleWallRadius / 2, 0])
				cube([
					roundingBlockLength,
					boltHoleWallRadius,
					baseThickness,
				], center=true);
		}

		module negativeBlock() {
			translate([0, 0, baseThickness / 2 - countersinkDepth + tolerance])
			linear_extrude(countersinkDepth, scale=countersinkRadius / boltHoleRadius)
				circle(boltHoleRadius);
			cylinder(baseThickness + tolerance, r=boltHoleRadius, center=true);
			translate([boltHoleWallRadius * 2 - wallOverlap, 0, 0])
				cylinder(baseThickness + tolerance, r=boltHoleWallRadius - wallOverlap, center=true);
			translate([0, boltHoleWallRadius * 2 - wallOverlap, 0])
				cylinder(baseThickness + tolerance, r=boltHoleWallRadius - wallOverlap, center=true);
		}

		difference() { positiveBlock(); negativeBlock(); }
	}

	module boltHoles() {
		for (i=[[-1, -1, 0], [-1, 1, 270], [1, -1, 90], [1, 1, 180]]) {
			translate([
				i[0] * (boltHoleSpacing / 2 - boltHoleRadius),
				i[1] * (boltHoleSpacing / 2 - boltHoleRadius),
				0,
			]) {
				rotate([0, 0, i[2]]) boltHole();
			}
		}
	}

	module base() {
		translate([0, 0, baseThickness / 2]) {
			difference() {
				roundedBox([baseWidth, baseWidth, baseThickness], baseThickness, sidesonly=true);
				roundedBox([
					baseWidth - 2 * wallThickness,
					baseWidth - 2 * wallThickness,
					baseThickness * 2,
				], baseThickness, sidesonly=true);
			}
			boltHoles();
		}
	}

	module boltHoleCutouts() {
		boltHoleCutoutBlockWidth = 2 * ((baseWidth - boltHoleSpacing) / 2 + boltHoleRadius * 2 + 1.5);
		for (i=[-1, 1], j=[-1, 1])
		translate([
			i * (baseWidth / 2),
			j * (baseWidth / 2),
			rampHeight / 2 - tolerance,
		])
			roundedBox([
				boltHoleCutoutBlockWidth,
				boltHoleCutoutBlockWidth,
				rampHeight,
			], boltHoleRadius, sidesonly=true);
	}

	module bodyPositiveBlock() {
		linear_extrude(rampHeight, scale=capWidth / baseWidth)
			square(baseWidth, center=true);
		translate([0, 0, capThickness / 2 + rampHeight])
			cube([capWidth, capWidth, capThickness], center=true);
		translate([0, 0, rampHeight + capThickness - tolerance])
			cylinder(firstTransitionThickness + tolerance, capWidth / 2, radiusAfterFirstTransition);
		translate([0, 0, rampHeight + capThickness + firstTransitionThickness - tolerance])
			cylinder(thinTubeThickness + tolerance, r=radiusAfterFirstTransition);
		translate([
			0,
			0,
			rampHeight + capThickness + firstTransitionThickness + thinTubeThickness - tolerance,
		])
			cylinder(secondTransitionThickness + tolerance, radiusAfterFirstTransition, tubeOuterRadius);
		translate([
			0,
			0,
			rampHeight + capThickness + firstTransitionThickness + thinTubeThickness + secondTransitionThickness - tolerance,
		])
			cylinder(tubeHeight + tolerance, r=tubeOuterRadius);
	}

	module bodyNegativeBlock(includeBoltHoleCutouts=true) {
		if (includeBoltHoleCutouts) boltHoleCutouts();

		hull() {
			translate([0, 0, -1 * tolerance])
			linear_extrude(tolerance)
				square(baseWidth - wallThickness * 2, center=true);
			translate([0, 0, rampHeight])
			linear_extrude(tolerance)
				circle(capTopHoleRadius);
		}
		translate([0, 0, rampHeight - tolerance])
		linear_extrude(rampToTubeTransitionHeight + tolerance, scale=tubeRadius / capTopHoleRadius)
			circle(capTopHoleRadius);
		translate([0, 0, rampHeight + rampToTubeTransitionHeight - tolerance])
			cylinder(tubeHeight * 1.5, r=tubeRadius);
	}

	module body() {
		translate([0, 0, baseThickness - tolerance]) {
			difference() { bodyPositiveBlock(); bodyNegativeBlock(); }
			intersection() {
				bodyNegativeBlock(includeBoltHoleCutouts=false);
				translate([0, 0, rampHeight / 2]) scale([1, 1, 10]) difference() {
					boltHoles();
					translate([0, 0, -1 * rampHeight / 2]) boltHoleCutouts();
				}
			}
		}
	}

	if (fullRender) {
		base();
		body();
	} else {
		echo ("using stock nozzle stl to improve performance");
		import("../STL/laserAirAssistStockNozzle.stl");
	}

}

module circularDuctInnerCrossSection() {
	circle(feederTubeOuterRadius);
}

module circularDuctOuterCrossSection() {
	circle(feederTubeOuterRadius + ductWallThickness);
}

module nozzleRing() {
	translate([
		0,
		0,
		topOfSecondTransition + feederTubeOuterRadius + 5,
	])
	rotate_extrude(angle=360)
	translate([tubeRadius + (tubeOuterRadius - tubeRadius) / 2, 0, 0])
		children();
}

module nozzleInnerCrossSection() {
	circle(nozzleRadius);
}

module nozzleOuterCrossSection() {
	circle(nozzleRadius + ductWallThickness);
}

module nozzles() {
	translateRadius = tubeRadius + 0.1;

	translate([0, 0, topOfSecondTransition + tubeHeight - nozzleLength - 0.3]) {
		translate([cos(60) * translateRadius, sin(60) * translateRadius, 0])
		rotate([nozzleAngle * sin(60), -1 * nozzleAngle * cos(60), 0])
		linear_extrude(nozzleLength)
			children();

		translate([cos(60) * translateRadius, -1 * sin(60) * translateRadius, 0])
		rotate([-1 * nozzleAngle * sin(60), -1 * nozzleAngle * cos(60), 0])
		linear_extrude(nozzleLength)
			children();

		translate([-1 * translateRadius, 0, 0])
		rotate([0, nozzleAngle, 0])
		linear_extrude(nozzleLength)
			children();
	}
}

module feederTubePort() {
	translate([
		tubeRadius + (tubeOuterRadius - tubeRadius) / 2,
		0,
		topOfSecondTransition + feederTubeOuterRadius + 5,
	])
	rotate([0, 90, 0])
	linear_extrude(feederTubeOverlap + feederTubeOuterRadius)
		children();
}

module airDuctOuterShell(
) {
	nozzleRing() difference() { circularDuctOuterCrossSection(); circularDuctInnerCrossSection(); }
	nozzles() difference() { nozzleOuterCrossSection(); nozzleInnerCrossSection(); }
	feederTubePort() difference() { circularDuctOuterCrossSection(); circularDuctInnerCrossSection(); }

	portSupportHeight = 5 + secondTransitionThickness;
	portSupportWidth = feederTubeOverlap + ductWallThickness + (tubeOuterRadius - tubeRadius) / 2;
	translate([
		tubeRadius + (tubeOuterRadius - tubeRadius) / 2 + feederTubeOverlap + feederTubeOuterRadius
			- portSupportWidth / 2,
		0,
		topOfSecondTransition + 5 - portSupportHeight / 2,
	])
		cube([portSupportWidth, wallThickness, portSupportHeight], center=true);
}

module airDuctCutout() {
	if (fullRender) {
		nozzleRing() circularDuctInnerCrossSection();
		nozzles() nozzleInnerCrossSection();
		feederTubePort() circularDuctInnerCrossSection();
	} else {
		echo ("using duct cutout stl to improve performance");
		import("../STL/laserAirAssistDuctCutout.stl");
	}
}

module airDuct() {
	if (fullRender) {
		difference() { airDuctOuterShell(); airDuctCutout(); }
	} else {
		echo ("using duct stl to improve performance");
		import("../STL/laserAirAssistDuct.stl");
	}
}

module nozzle() {
	if (fullRender) {
		difference() { stockNozzle(); airDuctCutout(); }
		airDuct();
	} else {
		echo ("using nozzle stl to improve performance");
		import("../STL/laserAirAssistNozzle.stl");
	}
}

//stockNozzle();
//airDuct();
//airDuctCutout();
nozzle();
