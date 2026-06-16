function Xp_rot = Rotate_to_z(Xp, a, b, c, px, py, pz)

    v = [a; b; c];
    v = v / norm(v);

    target = [0; 0; 1];
    axis = cross(v, target);
    axis_norm = norm(axis);

    if axis_norm < 1e-12
        axis = [1; 0; 0];
    else
        axis = axis / axis_norm;
    end

    theta = acos(max(min(dot(v, target), 1), -1));

    K = [0, -axis(3), axis(2); ...
         axis(3), 0, -axis(1); ...
        -axis(2), axis(1), 0];
    R = eye(3) + sin(theta) * K + (1 - cos(theta)) * K^2;

    P = [px, py, pz];
    Xp_shifted = Xp - P;
    Xp_rot = (R * Xp_shifted')' + P;

end
