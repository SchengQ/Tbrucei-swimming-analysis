function [XL, U0, Omega, F] = cons_solve(Xp, Up, X0, R, epsilon, mu)

    Ns = size(Xp, 1);

    X0vec = repmat(X0, Ns, 1);
    XL = Xp * R' + X0vec;

    Z = zeros(Ns, 1);
    XmX0 = XL - X0vec;
    B = [ [ Z,          XmX0(:,3), -XmX0(:,2)];
          [-XmX0(:,3), Z,          XmX0(:,1)];
          [ XmX0(:,2), -XmX0(:,1), Z         ];
        ];

    S = [[ ones(Ns,1), zeros(Ns,1), zeros(Ns,1)];
         [zeros(Ns,1),  ones(Ns,1), zeros(Ns,1)];
         [zeros(Ns,1), zeros(Ns,1),  ones(Ns,1)];
        ];

    M = form_reg_stokes_matrix_3D(XL, epsilon, mu);

    Z3 = zeros(3);
    A = [ [ M,  -S, -B ];
          [ -S', Z3, Z3 ];
          [ -B', Z3, Z3 ];
        ];

    RU = Up * R';
    b = [RU(:); 0; 0; 0; 0; 0; 0];

    sol = A \ b;

    F = sol(1:3*Ns);
    F = reshape(F, Ns, 3);
    U0 = sol(end-5:end-3)';
    Omega = sol(end-2:end);

end
