# fLoc Flywheel Gear (vpnl/floc)

This Docker context creates a Flywheel Gear that can analyze data generated with the Functional localizer experiment used to define category-selective cortical regions (published in [Stigliani et al., 2015](http://www.jneurosci.org/content/35/36/12412)).

By default the Gear generates the following voxel-wise parameters maps: Beta values, model residual error, proportion of variance explained, and GLM contrasts (t-values). All parameter maps are saved as .mat and nifti files in `session/Inplane/GLMs/` and can be viewed in Vistasoft. The Gear also writes a file named `fLocAnalysis_log.txt` that logs progress and saves input and glm parameters as `fLocAnalysisParams.mat`. If there are 10 conditions specified, 15 contrast maps will be generated. 10 maps will contrast each individual condition versus all others. The other 5 maps will contrast conditions 1 and 2 vs all others, 3 and 4 versus all others, and so on. If there are not 10 conditions specified in the parfiles, then the maps generated will contrast each individual condition versus all others.

## Instructions

Follow the instructions below to build the Gear.

### Building

1. Make sure you have Matlabr2017b and Docker installed on your LINUX machine
2. Clone fLoc repository on the computer you will use to build the image.
3. Run the build function in Matlab - (`fLoc/gear/bin/fLocGearRun_Build.m`)
  ```bash
  cd fLoc/gear/bin/
  /software/matlab/r2017b/bin/matlab -nodesktop -r fLocGearRun_Build
  ```
4. Build the image
```bash
docker build -t vpnl/floc fLoc/Dockerfile
```

### Execution

Execution of this Gear is limited to a Flywheel instance. Below are some important notes to get the gear to run correctly on your data.

1. This gear is means to run at the session level (one Subject at a time).
2. Ensure that you have uploaded the PAR files for each of the acquisitions you wish to be analyzed.
3. Run the analysis gear and set your CLIP and Freesurfer_License config parameters
4. The Gear requires no input files, as it relies on the Flywheel SDK to gather the required data.
5. Inplane logic: In the case that multiple inplane files exist, the Gear will use the last inplane prior to the first BOLD scan.

### Results

The main analysis results are zipped in an archive using the convention of:
```
<subject_code>/<session>-fLoc.zip
```

An example output looks like this (subject_code=s181, session=8111):
```
├── s181_8111-fLocAnalysis_log.txt
├── s181_8111-fLoc.zip
├── s181_8111-input_data.json
└── s181_8111-Within_Scan_Motion_Est.jpg
```

The output archive contains the following directory structure:
```
s181/
└── 8111
    ├── Images
    └── Inplane
        ├── GLMs
        │   ├── NiftiMaps
        │   ├── RawMaps
        │   └── Scan1
        ├── MotionComp
        │   └── TSeries
        └── MotionComp_RefScan1
            └── TSeries

```
