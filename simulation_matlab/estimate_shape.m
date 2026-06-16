function [Np, Points, params] = estimate_shape(grid, params)

ds = grid.ds;

L1 = params.L1; L2 = params.L2; L3 = params.L3; L4 = params.L4; L5 = params.L5;
T1 = params.T1; T2 = params.T2; T3 = params.T3; T4 = params.T4;
D1 = params.D1; D2 = params.D2; D3 = params.D3; D4 = params.D4; D5 = params.D5; D6 = params.D6;
O1 = params.O1; O2 = params.O2; O3 = params.O3; O4 = params.O4; O5 = params.O5; O6 = params.O6;
B1 = params.B1; B2 = params.B2; B3 = params.B3; B4 = params.B4; B5 = params.B5; B6 = params.B6;

Nl1 = round(sqrt(L1^2 + (D2 - D1)^2) / ds);
Nl2 = round(sqrt(L2^2 + (D3 - D2)^2) / ds);
Nl3 = round(sqrt(L3^2 + (D4 - D3)^2) / ds);
Nl4 = round(sqrt(L4^2 + (D5 - D4)^2) / ds);
Nl5 = round(sqrt(L5^2 + (D6 - D5)^2) / ds);

Nl = Nl1 + Nl2 + Nl3 + Nl4 + Nl5 + 1;
NL = linspace(1, Nl, Nl);

params.Nl1 = Nl1 + 1;
params.Nl2 = Nl2;
params.Nl3 = Nl3;
params.Nl4 = Nl4;
params.Nl5 = Nl5;

Lz1 = L1;
Lz2 = L2 * cos(T1);
Lz3 = L3 * cos(T1 + T2);
Lz4 = L4 * cos(T1 + T2 + T3);
Lz5 = L5 * cos(T1 + T2 + T3 + T4);

Lx1 = 0;
Lx2 = L2 * sin(T1);
Lx3 = L3 * sin(T1 + T2);
Lx4 = L4 * sin(T1 + T2 + T3);
Lx5 = L5 * sin(T1 + T2 + T3 + T4);

params.z1 = -Lz1;
params.z2 = -Lz1 - Lz2;
params.z3 = -Lz1 - Lz2 - Lz3;
params.z4 = -Lz1 - Lz2 - Lz3 - Lz4;
params.z5 = -Lz1 - Lz2 - Lz3 - Lz4 - Lz5;

params.x1 = Lx1;
params.x2 = Lx1 + Lx2;
params.x3 = Lx1 + Lx2 + Lx3;
params.x4 = Lx1 + Lx2 + Lx3 + Lx4;
params.x5 = Lx1 + Lx2 + Lx3 + Lx4 + Lx5;

Z1 = linspace(0, Lz1, Nl1 + 1);
Z2 = linspace(Lz1, Lz1 + Lz2, Nl2 + 1); Z2 = Z2(2:end);
Z3 = linspace(Lz1 + Lz2, Lz1 + Lz2 + Lz3, Nl3 + 1); Z3 = Z3(2:end);
Z4 = linspace(Lz1 + Lz2 + Lz3, Lz1 + Lz2 + Lz3 + Lz4, Nl4 + 1); Z4 = Z4(2:end);
Z5 = linspace(Lz1 + Lz2 + Lz3 + Lz4, Lz1 + Lz2 + Lz3 + Lz4 + Lz5, Nl5 + 1); Z5 = Z5(2:end);
Zc = -[Z1, Z2, Z3, Z4, Z5];

X1 = linspace(0, Lx1, Nl1 + 1);
X2 = linspace(Lx1, Lx1 + Lx2, Nl2 + 1); X2 = X2(2:end);
X3 = linspace(Lx1 + Lx2, Lx1 + Lx2 + Lx3, Nl3 + 1); X3 = X3(2:end);
X4 = linspace(Lx1 + Lx2 + Lx3, Lx1 + Lx2 + Lx3 + Lx4, Nl4 + 1); X4 = X4(2:end);
X5 = linspace(Lx1 + Lx2 + Lx3 + Lx4, Lx1 + Lx2 + Lx3 + Lx4 + Lx5, Nl5 + 1); X5 = X5(2:end);
Xc = [X1, X2, X3, X4, X5];

R1 = linspace(D1, D2, Nl1 + 1);
R2 = linspace(D2, D3, Nl2 + 1); R2 = R2(2:end);
R3 = linspace(D3, D4, Nl3 + 1); R3 = R3(2:end);
R4 = linspace(D4, D5, Nl4 + 1); R4 = R4(2:end);
R5 = linspace(D5, D6, Nl5 + 1); R5 = R5(2:end);
Rc = [R1, R2, R3, R4, R5];

Lnp = round((2 * pi * Rc) / ds);
Np = sum(Lnp);

o1 = linspace(O1, O2, Nl1 + 1);
o2 = linspace(O2, O3, Nl2 + 1); o2 = o2(2:end);
o3 = linspace(O3, O4, Nl3 + 1); o3 = o3(2:end);
o4 = linspace(O4, O5, Nl4 + 1); o4 = o4(2:end);
o5 = linspace(O5, O6, Nl5 + 1); o5 = o5(2:end);
O = [o1, o2, o3, o4, o5];

b1 = linspace(B1, B2, Nl1 + 1);
b2 = linspace(B2, B3, Nl2 + 1); b2 = b2(2:end);
b3 = linspace(B3, B4, Nl3 + 1); b3 = b3(2:end);
b4 = linspace(B4, B5, Nl4 + 1); b4 = b4(2:end);
b5 = linspace(B5, B6, Nl5 + 1); b5 = b5(2:end);
B = [b1, b2, b3, b4, b5];

repeated_nl = arrayfun(@(x, y) repmat(y, 1, x), Lnp, NL, 'UniformOutput', false);
Points_NL = [repeated_nl{:}];

repeated_zc = arrayfun(@(x, y) repmat(y, 1, x), Lnp, Zc, 'UniformOutput', false);
Points_Zc = [repeated_zc{:}];

repeated_rc = arrayfun(@(x, y) repmat(y, 1, x), Lnp, Rc, 'UniformOutput', false);
Points_Rc = [repeated_rc{:}];

repeated_xc = arrayfun(@(x, y) repmat(y, 1, x), Lnp, Xc, 'UniformOutput', false);
Points_Xc = [repeated_xc{:}];

repeated_o = arrayfun(@(x, y) repmat(y, 1, x), Lnp, O, 'UniformOutput', false);
Points_O = [repeated_o{:}];

repeated_b = arrayfun(@(x, y) repmat(y, 1, x), Lnp, B, 'UniformOutput', false);
Points_B = [repeated_b{:}];

sub_points_ph = arrayfun(@(x) 2 * (1:x) * pi / x, Lnp, 'UniformOutput', false);
Points_Ph = [sub_points_ph{:}];

Points = struct('NL', num2cell(Points_NL), ...
                'Zc', num2cell(Points_Zc), ...
                'Rc', num2cell(Points_Rc), ...
                'Xc', num2cell(Points_Xc), ...
                'O', num2cell(Points_O), ...
                'B', num2cell(Points_B), ...
                'Ph', num2cell(Points_Ph));

end
