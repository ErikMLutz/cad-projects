use <MCAD/boxes.scad>

$fa = $preview ? 12 : 1;
$fs = $preview ? 2 : 0.1;

tolerance = 0.001;
tileSideLength = 25.4;
pegBoardThickness = 4.1;
pegBoardHoleRadius = 3.1;
insetDepth = 1;
insetPinDepth = 2;
insetPinRadius = 2;
insetPadding = 0.25;
mountHoleRadius = 2;
offsetHeight = 15;

module peg(radius=pegBoardHoleRadius) { circle(r=radius); }

module closedTile() {
	difference() { square(tileSideLength + tolerance, center=true); peg(); }
}

module openTileBase(insetDepthCuts=false, pinDepthCuts=false) {
	if (!pinDepthCuts) difference() {
		closedTile();
		difference() {
			projection() roundedBox([
				tileSideLength - pegBoardHoleRadius / 2,
				tileSideLength - pegBoardHoleRadius / 2,
				insetDepth + tolerance,
			], pegBoardHoleRadius, sidesonly=true);
			peg(radius=pegBoardHoleRadius * 1.5);
		}
	}
	if (!insetDepthCuts || pinDepthCuts)
	for (i=[-1, 1], j=[-1, 1]) translate([i * tileSideLength / 3, j * tileSideLength / 3, 0])
		circle(r=insetPinRadius);
}

module openTile(insetDepthCuts=false, pinDepthCuts=false) {
	if (insetDepthCuts) difference() {
		square(tileSideLength, center=true);
		openTileBase(insetDepthCuts);
		peg(radius=pegBoardHoleRadius + tolerance);
	}
	
	else openTileBase(insetDepthCuts, pinDepthCuts);
}

module flowerBoard(fullDepthCuts=false, insetDepthCuts=false, pinDepthCuts=false, mask=false) {
	translate([0, 0, pegBoardThickness / 2]) difference() {
		for (i=[-5:5], j=[-5:5]) {
			if (i * i + j * j <= 29)
			translate([i * tileSideLength, j * tileSideLength, 0])
				if (mask) square(tileSideLength + tolerance, center=true);
				else if (fullDepthCuts) closedTile();
				else {
					if (i * i + j * j <= 3) openTile(insetDepthCuts, pinDepthCuts);
					else if (i * i + j * j <= 4) { if (!insetDepthCuts && !pinDepthCuts) closedTile(); }
					else if (i * i + j * j <= 9) openTile(insetDepthCuts, pinDepthCuts);
					else if (i * i + j * j <= 12) { if (!insetDepthCuts && !pinDepthCuts) closedTile(); }
					else if (i * i + j * j <= 16) openTile(insetDepthCuts, pinDepthCuts);
					else if (i * i + j * j <= 20) { if (!insetDepthCuts && !pinDepthCuts) closedTile(); }
					else if (i * i + j * j <= 24) openTile(insetDepthCuts, pinDepthCuts);
					else { if (!insetDepthCuts && !pinDepthCuts) closedTile(); };
				}
		}
		if (!mask) union() {
			for (i=[-1, 1], j=[-1, 1])
				translate([
					i * 5 * tileSideLength / 2,
					j * 5 * tileSideLength / 2,
					0
				])
					circle(r=mountHoleRadius);
		}
	}
}

module fullBoard() {
	flowerBoard(mask=true);
	translate([
		-22 * (tileSideLength + tolerance),
		-0 * (tileSideLength + tolerance),
	]) {
		scale([1 + tolerance, 1 + tolerance])
		color("green")
			flowerBoard(mask=true);
		translate([
			8 * (tileSideLength + tolerance),
			7 * (tileSideLength + tolerance),
		])
			scale([1 + tolerance, 1 + tolerance])
			color("green")
				flowerBoard(mask=true);
		translate([
			19 * (tileSideLength + tolerance),
			5 * (tileSideLength + tolerance),
		])
			scale([1 + tolerance, 1 + tolerance])
			color("green")
				flowerBoard(mask=true);
		if (false) translate([
			3 * (tileSideLength + tolerance),
			6 * (tileSideLength + tolerance),
		])
			scale([1 + tolerance, 1 + tolerance])
			color("red")
				flowerBoard(mask=true);
		translate([
			10 * (tileSideLength + tolerance),
			3 * (tileSideLength + tolerance),
		])
			scale([1 + tolerance, 1 + tolerance])
			color("yellow")
				flowerBoard(mask=true);
		if (false) translate([
			15 * (tileSideLength + tolerance),
			6 * (tileSideLength + tolerance),
		])
			scale([1 + tolerance, 1 + tolerance])
			color("blue")
				flowerBoard(mask=false);
	}
}

module wallOffset() {
	difference() {
		cylinder(offsetHeight, r=offsetHeight / 2);
		translate([0, 0, -offsetHeight / 2]) cylinder(offsetHeight * 2, r=offsetHeight / 4);
	}
}

module insetFill() {
	linear_extrude(insetDepth * 0.75)
	offset(r=-2 * insetPadding)
	difference() {
		projection() roundedBox([
			tileSideLength - pegBoardHoleRadius / 2,
			tileSideLength - pegBoardHoleRadius / 2,
			insetDepth + tolerance,
		], pegBoardHoleRadius, sidesonly=true);
		peg(radius=pegBoardHoleRadius * 1.5);
	}
}
