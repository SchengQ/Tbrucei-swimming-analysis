# Simulation code

This folder contains the MATLAB simulation code used to calculate swimming dynamics for the model T. brucei described in the associated PNAS article.

## Folder structure

```text
simulation_matlab/
├── main.m
├── mainProgramA.m
├── cons_solve.m
├── estimate_shape.m
├── form_reg_stokes_matrix_3D.m
├── get_shape_t_3D_xy_bodyaxis_new.m
├── get_shape_t_3D_xy_bodyaxis2.m
├── Rotate_to_z.m
├── append_summary_to_excel.m
├── export_params_to_excel.m
├── flatten_struct.m
├── get_or_create_unique_id.m
├── is_summary_recorded.m
└── reconstruct_summary_from_saved_files.m
```

## Main entry point

Run:

```matlab
main
```

The script `main.m` defines the parameter ranges and calls `mainProgramA.m` to run the simulations. No external input data are required for the default parameter scan.

## Output files

Running `main.m` generates output files and folders including:

```text
params_table.mat
params_record.xlsx
results/
summary/summary.xlsx
```

The `results/` folder contains saved simulation outputs for each parameter set. The `summary/summary.xlsx` file records the main calculated quantities and parameter information.

## Code description

* `main.m`: main driver script for the parameter scan.
* `mainProgramA.m`: runs the simulation for a given parameter set and saves the results.
* `cons_solve.m`: solves the force- and torque-balance problem.
* `estimate_shape.m`: estimates geometric quantities of the model swimmer.
* `form_reg_stokes_matrix_3D.m`: constructs the regularized Stokes matrix.
* `get_shape_t_3D_xy_bodyaxis_new.m` and `get_shape_t_3D_xy_bodyaxis2.m`: generate the time-dependent swimmer geometry.
* `Rotate_to_z.m`: rotates the simulated swimming direction to the z-axis.
* `append_summary_to_excel.m`, `export_params_to_excel.m`, `flatten_struct.m`, `get_or_create_unique_id.m`, `is_summary_recorded.m`, and `reconstruct_summary_from_saved_files.m`: helper functions for saving parameters, outputs, and summary tables.

## Notes

The code was developed and tested in MATLAB. Simulation parameters are defined in main.m and can be modified to run additional simulations or reproduce specific parameter sets.
