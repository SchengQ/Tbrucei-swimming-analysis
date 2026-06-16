function [Xp, Up] = get_shape_t_3D_xy_bodyaxis2(tin, grid, params, Points, unique_id)

    dt = 0.001;

    Xp = get_shape_t_3D_xy_bodyaxis_new(tin, grid, params, Points, unique_id);
    Xp_dt = get_shape_t_3D_xy_bodyaxis_new(tin + dt, grid, params, Points, unique_id);

    Up = (Xp_dt - Xp) / dt;

end
