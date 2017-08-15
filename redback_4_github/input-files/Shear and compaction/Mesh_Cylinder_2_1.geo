//Cylinder Mesh
//Height  : Width
//    1   :   1


//Parameters in meter:
width   = 1;
inner_cylinder	= width/2;
height  = 2;
outer_cylinder	= 0.03;
lc      = 0.1;
lc2      = 0.01;
number_layers	= 15;


//Mesh
mesh_type = 2; // 0 = triangles, 1 = non regular quads, 2 = regular quads

//Points inner cylinder
Point(1) = {(0), (0), 0, lc};
Point(2) = {0, -(inner_cylinder), 0, lc};
Point(3) = {0, (inner_cylinder), 0, lc};
Point(4) = {-(inner_cylinder), 0, 0, lc};
Point(5) = {(inner_cylinder), 0, 0, lc};

Circle(1) = {2,1,5};
Circle(2) = {5,1,3};
Circle(3) = {3,1,4};
Circle(4) = {4,1,2};

Line Loop(5) = {1,2,3,4};
Plane Surface(6) = {5};

//Extrude {0, 0, (height)} {
//  Surface {6};
//}

Extrude {0, 0, (height)} {
Surface{6};
Layers{number_layers};
Recombine;
}

// Transfinite Surface "*";
// Recombine Surface "*";
Transfinite Volume "*";
Point {1} In Surface {6};
Point {7} In Surface {28};


// Volume inner cylinder
Physical Volume(0) = {1}; //cylinder
Physical Surface(1) = {15, 19, 23, 27}; // mantle cylinder
Physical Surface(2) = {6}; // inner bottom
Physical Surface(3) = {28}; // inner top
Physical Point(4) = {1}; //Points middle bottom
Physical Point(5) = {7}; //Points middle top
