use <MCAD/boxes.scad>
use <MCAD/triangles.scad>
include <pegBoard.scad>

$fa = $preview ? 12 : 1;
$fs = $preview ? 2 : 0.1;

pegRadius = pegBoardHoleRadius * 0.85;
pegLength = pegBoardThickness;

module hookPeg() {
	translate([0, pegLength, 0]) {
		difference() {
			translate([0, -1 * tolerance, 2 * pegRadius])
			rotate([0, 90, 0])
			rotate_extrude(angle=90)
			translate([pegRadius * 2, 0, 0])
				circle(pegRadius);
			translate([-1 * pegLength, pegRadius * 0.5, pegRadius * 1.1])
			rotate([30, 0, 0])
				cube(pegLength * 2);
		}
		rotate([90, 0, 0])
			cylinder(pegLength, r=pegRadius);
	}
}

module straightPeg() {
	translate([0, pegLength, 0])
	rotate([90, 0, 0])
		cylinder(pegLength, r=pegRadius);
}


caliperMountInnerGapWidth = 40;
caliperMountLeftToRightHeightDifference = 15;
caliperMountSlotThickness = 8;
caliperMountBackThickness = 2;

module caliperMount() {
	module hanger() {
		translate([0, -1 * caliperMountBackThickness + tolerance, 0]) {
			rotate([90, 0, 0])
				cylinder(caliperMountSlotThickness, r=pegRadius);
			translate([0, -1 * caliperMountSlotThickness + tolerance, pegRadius]) {
				translate([0, -1 * pegRadius, -1 * tolerance])
					cylinder(caliperMountSlotThickness / 2, r=pegRadius);
				rotate([-180, 90, 0])
				rotate_extrude(angle=90)
				translate([pegRadius, 0, 0])
					circle(pegRadius);
			}
		}
	}

	module mount() {
		for (i=[-1, 1])
		translate([i * caliperMountInnerGapWidth / 2, tolerance, i * caliperMountLeftToRightHeightDifference / 2])
			hanger();
		
		translate([
			-1 * caliperMountInnerGapWidth / 2,
			-1 * caliperMountBackThickness,
			caliperMountLeftToRightHeightDifference / 2,
		])
		rotate([-90, 0, 0])
		linear_extrude(caliperMountBackThickness)
		offset(r=pegRadius)
		projection()
			triangle(caliperMountLeftToRightHeightDifference, caliperMountInnerGapWidth, 1);
		for (i=[-1, 1])
		translate([i * tileSideLength / 2, -1 * tolerance, caliperMountLeftToRightHeightDifference / 2])
			hookPeg();
	}

	translate([0, 0, (caliperMountLeftToRightHeightDifference + caliperMountSlotThickness) / 2 + pegRadius])
	rotate([180, 0, 0])
		mount();

}

palleteKnifeMountPegLength = 15;
palleteKnifeMountPegAngle = 15;
palleteKnifeMountPegRadius = 5 / 2;

module palleteKnifeMount() {
	rotate([0, 90, -90])
	linear_extrude(caliperMountBackThickness)
	offset(r=pegRadius) { projection() {
		translate([0, -1 * tolerance / 2, 0]) triangle(tileSideLength / 2, tileSideLength / 2, 1);
		translate([0, tolerance / 2, 0]) mirror([0, -1, 0]) triangle(tileSideLength / 2, tileSideLength / 2, 1);
	} }

	for (i=[-1, 1])
	translate([i * tileSideLength / 2, -tolerance, 0])
		hookPeg();

	translate([
		0,
		-1 * palleteKnifeMountPegLength / 2 - caliperMountBackThickness + 1,
		-1 * tileSideLength / 2 + pegRadius,
	])
	rotate([90 - palleteKnifeMountPegAngle, 0, 0])
		cylinder(palleteKnifeMountPegLength, r=palleteKnifeMountPegRadius, center=true);
}

module snipsMount() { palleteKnifeMount(); }

cncBitBoxWidth = 12.65;
cncBitBoxHeight = 69.35;
cncBitBoxNoLabelHeight = 38.50;
cncBitMountSlots = 15;
cncBitMountSeparatorThickness = 1;
cncBitMountWallThickness = 1;
cncBitMountWallPadding = 1;
cncBitMountMaxTilt = 15;
cncBitMountBackThickness = 2;

cncBitMountExtraThicknessForTilt = sin(cncBitMountMaxTilt) * (cncBitBoxNoLabelHeight / 2);

cncBitMountFullWidth = (cncBitBoxWidth + 2 * cncBitMountWallPadding) * cncBitMountSlots
	+ cncBitMountSeparatorThickness * (cncBitMountSlots - 1)
	+ cncBitMountWallThickness * 2;
cncBitMountFullHeight = cncBitBoxNoLabelHeight / 2 + cncBitMountWallThickness;
cncBitMountFullThickness = (cncBitBoxWidth + 2 * cncBitMountWallPadding + cncBitMountExtraThicknessForTilt)
	+ cncBitMountWallThickness * 2;

cncBitMountSlotWidth = cncBitBoxWidth + 2 * cncBitMountWallPadding;
cncBitMountSlotThickness = cncBitBoxWidth + 2 * cncBitMountWallPadding + cncBitMountExtraThicknessForTilt; 
cncBitMountSlotHeight = cncBitBoxNoLabelHeight / 2;


module cncBitMount() {
	difference() {
		roundedBox([cncBitMountFullWidth, cncBitMountFullThickness, cncBitMountFullHeight], cncBitMountWallThickness, sidesonly=true);

		for (i=[0 : cncBitMountSlots - 1])
		translate([
			(cncBitMountFullWidth - cncBitMountSlotWidth) / 2 - cncBitMountWallThickness
				- i * (cncBitMountSlotWidth + cncBitMountSeparatorThickness),
			0,
			cncBitMountWallThickness / 2 + tolerance,
		])
			roundedBox([cncBitMountSlotWidth, cncBitMountSlotThickness, cncBitMountSlotHeight], cncBitMountWallThickness, sidesonly=true);
	}

	backHeight = tileSideLength + 2 * pegRadius;
	translate([0, -1 * cncBitMountFullThickness / 2, backHeight / 2 - cncBitMountFullHeight / 2])
		cube([
			cncBitMountFullWidth,
			caliperMountBackThickness,
			backHeight,
		], center=true);

	for (i=[-3, -2, 2, 3])
	translate([
		i * tileSideLength,
		-1 * (pegLength + cncBitMountFullThickness / 2 + caliperMountBackThickness / 2) + tolerance,
		-1 * cncBitMountFullHeight / 2 + pegRadius,
	])
		straightPeg();
	for (i=[-4, -1, 1, 4])
	translate([
		i * tileSideLength,
		-1 * (cncBitMountFullThickness + cncBitMountWallThickness) / 2 + tolerance,
		-1 * cncBitMountFullHeight / 2 + pegRadius + tileSideLength,
	])
		rotate([0, 0, 180]) hookPeg();
}

wrenchMountPegRadius = 3 / 2;
wrenchMountPegLength = 10;

module wrenchMount() {
	rotate([0, 90, -90])
	linear_extrude(caliperMountBackThickness)
	offset(r=pegRadius) { projection() {
		translate([0, -1 * tolerance / 2, 0]) triangle(tileSideLength / 2, tileSideLength / 2, 1);
		translate([0, tolerance / 2, 0]) mirror([0, -1, 0]) triangle(tileSideLength / 2, tileSideLength / 2, 1);
	} }

	for (i=[-1, 1])
	translate([i * tileSideLength / 2, -tolerance, 0])
		hookPeg();

	translate([
		0,
		-1 * wrenchMountPegLength / 2 - caliperMountBackThickness + 1,
		-1 * tileSideLength / 2 + pegRadius,
	])
	rotate([90 - palleteKnifeMountPegAngle, 0, 0])
		cylinder(wrenchMountPegLength, r=wrenchMountPegRadius, center=true);
}

module tray(
	width  = 40,
	depth  = 10,
	height = 30,
	wallThickness = 1,
	radius = 2,
) {
	numPegsWide = floor((width - 2 * (radius + pegRadius)) / tileSideLength) + 1;
	numPegsHigh = floor((height + wallThickness - 2 * pegRadius) / tileSideLength) + 1;

	numPegsWideIsEven = numPegsWide % 2 == 0 ? true : false;

	module roundedBoxCup(
		width  = width,
		depth  = depth,
		height = height,
		wallThickness = wallThickness,
		radius = radius,
	) {
		difference() {
			roundedBox(
				[width + 2 * wallThickness, depth + 2 * wallThickness, height + 1 * wallThickness],
				radius + wallThickness, sidesonly=true
			);
			translate([0, 0, wallThickness + tolerance]) roundedBox([width, depth, height], radius, sidesonly=true);
		}

	}

	roundedBoxCup();

	pegStartX = (numPegsWideIsEven ? 0.5 - numPegsWide / 2 : -1 * floor(numPegsWide / 2)) * tileSideLength;

	for (i=[0:numPegsWide - 1]) {
		translate([
			pegStartX + i * tileSideLength,
			-1 * (depth / 2 + wallThickness - tolerance),
			(height + wallThickness) / 2 - pegRadius,
		])
		rotate([0, 0, 180]) {
			hookPeg();
			if (numPegsHigh > 1) translate([0, 0, -1 * (numPegsHigh - 1) * tileSideLength]) straightPeg();
		}
	}
}

module miscellaneousBitsTray() {
	tray(
		width  = 120,
		depth  = 50,
		height = 15,
		wallThickness = 1,
		radius = 2
	);
}

module calibrationTargetTray() { tray(width = 90, depth = 15, height = 40); }

module tallToolsCup() {
	width = 30;
	height = 75;
	depth = 30;
	radius = 12;
	wallThickness = 2;

	difference() {
		union() {
			for (i=[-2, -1, 0, 1, 2]) translate([i * tileSideLength, 0, 0])
				tray(width = width, depth = depth, height = height, radius = radius, wallThickness = wallThickness);
		}
		union() {
			for (i=[-1, 1])
			translate([i * tileSideLength, 0, wallThickness + tolerance])
				roundedBox([width, depth, height], radius, sidesonly=true);
			rotate([0, 90, 0]) roundedBox([3 * height / 4, depth / 2, width * 5], radius / 2, sidesonly=true);
			for (i=[-2, -1, 0, 1, 2])
			translate([i * tileSideLength, (depth + wallThickness) / 2, 0])
			rotate([90, 0, 0])
				roundedBox([depth / 2, 3 * height / 4, wallThickness * 4], radius / 2, sidesonly=true);
		}
	}
}

module cncHolddownCup() { tray(width = 150, depth  = 50, height = 30, radius = 12); }

module laserHolddownCup() { tray(width = 100, depth  = 50, height = 25, radius = 12); }

tallToolsCup();
