# Trypanosoma brucei swimming analysis codes

This repository contains the simulation and tracking codes used for the analyses reported in our associated paper (xxxxxxx) on *Trypanosoma brucei* swimming dynamics.

The repository includes two main components:

1. Python tracking code for reconstructing 3D trajectories from microscopy image sequences.
2. MATLAB simulation code for calculating swimming dynamics of the model swimmer.

## Repository structure

```text
Tbrucei-swimming-analysis/
├── tracking_python/
│   ├── Tracking.py
│   ├── requirements.txt
│   ├── 2D centers.txt
│   ├── example video/
│   └── example calibration library/
│
└── simulation_matlab/
    ├── main.m
    ├── mainProgramA.m
    ├── cons_solve.m
    ├── estimate_shape.m
    ├── form_reg_stokes_matrix_3D.m
    ├── get_shape_t_3D_xy_bodyaxis_new.m
    ├── get_shape_t_3D_xy_bodyaxis2.m
    ├── Rotate_to_z.m
    └── other helper functions
```

## Python tracking code

The folder `tracking_python/` contains the Python script used to reconstruct 3D trajectories from microscopy image sequences.

To run the example:

```bash
cd tracking_python
pip install -r requirements.txt
python Tracking.py
```

The script uses the example image folders and the `2D centers.txt` file as input and generates reconstructed 3D trajectory coordinates.

See `tracking_python/README.md` for details.

## MATLAB simulation code

The folder `simulation_matlab/` contains the MATLAB simulation code used to calculate swimming dynamics for the model swimmer.

To run the default parameter scan:

```matlab
cd simulation_matlab
main
```

Running `main.m` generates simulation results, parameter records, and summary files.

See `simulation_matlab/README.md` for details.

## Data and example files

Representative example image sequences are included in `tracking_python/` to demonstrate the tracking workflow. The MATLAB simulation code does not require external input data for the default parameter scan.

## Citation

If you use this repository, please cite the associated paper (xxxxx).

## Notes

Numerical parameters used in the tracking and simulation analyses are defined near the beginning of the corresponding scripts and can be modified for different datasets or parameter sets.
