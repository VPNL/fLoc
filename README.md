# fLoc
Functional localizer experiment used to define category-selective cortical regions (published in [Stigliani et al., 2015](http://www.jneurosci.org/content/35/36/12412))

* * *
*Notes:*

The code in this package uses functions from [Psychtoolbox-3](http://psychtoolbox.org/) and is compatible with [MATLAB](https://www.mathworks.com/) R2016b and later versions.
The repetition time (TR) of fMRI data for the localizer experiment must be a factor of its block duration (6 s by default).
* * *

*Contents:*

1. [Experimental Design](#experimental-design)
    1. [Stimulus Conditions](#stimulus-conditions)
    2. [Image Sets](#image-sets)
    3. [Task](#task)

2. [Instructions](#instructions)
    1. [Setup](#setup)
    2. [Execution](#execution)
    3. [Debugging](#debugging)

3. [Code](#code)
    1. [Using the runme fucntion](#using-the-runme-function)
    2. [Customizing the experiment](#custimizing-the-experiment)

4. [Analysis](#analysis)
    1. [Analysis with vistasoft](#analysis-with-vistasoft)
    2. [General Linear Model](#general-linear-model)
    3. [Regions of Interest](#regions-of-interest)

5. [Citation](#citation)

* * *

## Experimental design

This repository contains stimuli and presentation code for a functional localizer experiment used to define category-selective cortical regions that respond preferentially to faces (e.g., [fusiform face area](https://www.ncbi.nlm.nih.gov/pubmed/9151747)), places (e.g., [parahippocampal place area](https://www.ncbi.nlm.nih.gov/pubmed/9560155)), bodies (e.g., [extrastriate body area](https://www.ncbi.nlm.nih.gov/pubmed/11577239)), or printed characters (e.g., [visual word form area](https://www.ncbi.nlm.nih.gov/pubmed/10648437)). 

The localizer uses a mini-block design in which 12 stimuli of the same category are presented in each **6 second block** (500 ms/image). For each **4 minute run**, a novel stimulus sequence is generated that randomizes the order of five stimulus conditions (faces, places, bodies, characters, and objects) and a blank baseline condition. We recommend collecting at least **4 runs of data** per subject (16 minutes total) to have sufficient power to define regions of interest.

### Stimulus conditions

Each of the five stimulus conditions in the localizer is associated with two related image subcategories with 144 images per subcategory (see [`~/fLoc/stimuli/`](https://github.com/VPNL/fLoc/tree/master/stimuli) for entire database):

- Bodies
    + body — whole bodies with cropped heads
    + limb — isolated arms, legs, hands, and feet
- Characters
    + word — pronounceable pseudowords (adapted from [Glezer et al., 2009](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2706007/))
    + number — uncommon strings of digits
- Faces
    + adult — portraits of adult faces
    + child — portraits of child faces
- Objects
    + car — four-wheel motor vehicles
    + instrument — musical string instruments
- Places
    + house — outdoor views of buildings
    + corridor — indoor views of hallways

The specific image categories packaged with the localizer were selected to contain common sets of parts, such that all images from a given category are different configurations of the same basic components. This is intended to minimize differences in within-category similarity across image sets. 

To normalize the low-level properties of stimuli from different categories, we placed each exemplar on a phase-scrambled version of another randomly selected image from the database. We also matched the mean luminance and histograms of grayscale values of each image using the [SHINE toolbox](http://www.mapageweb.umontreal.ca/gosselif/SHINE/) (see [Stigliani et al. (2015)](http://www.jneurosci.org/content/35/36/12412) for more details).

### Image sets

The localizer code will prompt you to select which stimulus set to use when executing the experiment. You can further customize which image categories to include by editing the [`fLocSequence`](https://github.com/VPNL/fLoc/blob/master/functions/fLocSequence.m) class file (see below for more details). Three options are provided by default:

#### Option 1: 

| *Default* categories            |             |             |             |             |             |             |
| ------------------------------- |:-----------:|:-----------:|:-----------:|:-----------:|:-----------:| :----------:|
| **Bodies:** `body`              | ![bo1][bo1] | ![bo2][bo2] | ![bo3][bo3] | ![bo4][bo4] | ![bo5][bo5] | ![bo6][bo6] |
| **Characters:** `word`          | ![wo1][wo1] | ![wo2][wo2] | ![wo3][wo3] | ![wo4][wo4] | ![wo5][wo5] | ![wo6][wo6] |
| **Faces:** `adult`              | ![ad1][ad1] | ![ad2][ad2] | ![ad3][ad3] | ![ad4][ad4] | ![ad5][ad5] | ![ad6][ad6] |
| **Objects:** `car`              | ![ca1][ca1] | ![ca2][ca2] | ![ca3][ca3] | ![ca4][ca4] | ![ca5][ca5] | ![ca6][ca6] |
| **Places:** `house`             | ![ho1][ho1] | ![ho2][ho2] | ![ho3][ho3] | ![ho4][ho4] | ![ho5][ho5] | ![ho6][ho6] |

#### Option 2: 

| *Alternate* categories          |             |             |             |             |             |             |
| ------------------------------- |:-----------:|:-----------:|:-----------:|:-----------:|:-----------:| :----------:|
| **Bodies:** `limb`              | ![li1][li1] | ![li2][li2] | ![li3][li3] | ![li4][li4] | ![li5][li5] | ![li6][li6] |
| **Characters:** `number`        | ![nu1][nu1] | ![nu2][nu2] | ![nu3][nu3] | ![nu4][nu4] | ![nu5][nu5] | ![nu6][nu6] |
| **Faces:** `child`              | ![ch1][ch1] | ![ch2][ch2] | ![ch3][ch3] | ![ch4][ch4] | ![ch5][ch5] | ![ch6][ch6] |
| **Objects:** `instrument`       | ![in1][in1] | ![in2][in2] | ![in3][in3] | ![in4][in4] | ![in5][in5] | ![in6][in6] |
| **Places:** `corridor`          | ![co1][co1] | ![co2][co2] | ![co3][co3] | ![co4][co4] | ![co5][co5] | ![co6][co6] |

#### Option 3: 

| *Both* categories               |             |             |             |             |             |             |
| ------------------------------- |:-----------:|:-----------:|:-----------:|:-----------:|:-----------:| :----------:|
| **Bodies:** `body` `limb`       | ![bo1][bo1] | ![li1][li1] | ![bo2][bo2] | ![li2][li2] | ![bo3][bo3] | ![li3][li3] |
| **Characters:** `word` `number` | ![wo1][wo1] | ![nu1][nu1] | ![wo2][wo2] | ![nu2][nu2] | ![wo3][wo3] | ![nu3][nu3] |
| **Faces:** `adult` `child`      | ![ad1][ad1] | ![ch1][ch1] | ![ad2][ad2] | ![ch2][ch2] | ![ad3][ad3] | ![ch3][ch3] |
| **Objects:** `car` `instrument` | ![ca1][ca1] | ![in1][in1] | ![ca2][ca2] | ![in2][in2] | ![ca3][ca3] | ![in3][in3] |
| **Places:** `house` `corridor`  | ![ho1][ho1] | ![co1][co1] | ![ho2][ho2] | ![co2][co2] | ![ho3][ho3] | ![co3][co3] |

[bo1]: https://github.com/VPNL/fLoc/blob/master/stimuli/body/body-1.jpg "body-1.jpg"
[bo2]: https://github.com/VPNL/fLoc/blob/master/stimuli/body/body-2.jpg "body-2.jpg"
[bo3]: https://github.com/VPNL/fLoc/blob/master/stimuli/body/body-3.jpg "body-3.jpg"
[bo4]: https://github.com/VPNL/fLoc/blob/master/stimuli/body/body-4.jpg "body-4.jpg"
[bo5]: https://github.com/VPNL/fLoc/blob/master/stimuli/body/body-5.jpg "body-4.jpg"
[bo6]: https://github.com/VPNL/fLoc/blob/master/stimuli/body/body-6.jpg "body-6.jpg"

[li1]: https://github.com/VPNL/fLoc/blob/master/stimuli/limb/limb-1.jpg "limb-1.jpg"
[li2]: https://github.com/VPNL/fLoc/blob/master/stimuli/limb/limb-2.jpg "limb-2.jpg"
[li3]: https://github.com/VPNL/fLoc/blob/master/stimuli/limb/limb-3.jpg "limb-3.jpg"
[li4]: https://github.com/VPNL/fLoc/blob/master/stimuli/limb/limb-4.jpg "limb-4.jpg"
[li5]: https://github.com/VPNL/fLoc/blob/master/stimuli/limb/limb-5.jpg "limb-5.jpg"
[li6]: https://github.com/VPNL/fLoc/blob/master/stimuli/limb/limb-6.jpg "limb-6.jpg"

[wo1]: https://github.com/VPNL/fLoc/blob/master/stimuli/word/word-1.jpg "word-1.jpg"
[wo2]: https://github.com/VPNL/fLoc/blob/master/stimuli/word/word-2.jpg "word-2.jpg"
[wo3]: https://github.com/VPNL/fLoc/blob/master/stimuli/word/word-3.jpg "word-3.jpg"
[wo4]: https://github.com/VPNL/fLoc/blob/master/stimuli/word/word-4.jpg "word-4.jpg"
[wo5]: https://github.com/VPNL/fLoc/blob/master/stimuli/word/word-5.jpg "word-4.jpg"
[wo6]: https://github.com/VPNL/fLoc/blob/master/stimuli/word/word-6.jpg "word-6.jpg"

[nu1]: https://github.com/VPNL/fLoc/blob/master/stimuli/number/number-1.jpg "number-1.jpg"
[nu2]: https://github.com/VPNL/fLoc/blob/master/stimuli/number/number-2.jpg "number-2.jpg"
[nu3]: https://github.com/VPNL/fLoc/blob/master/stimuli/number/number-3.jpg "number-3.jpg"
[nu4]: https://github.com/VPNL/fLoc/blob/master/stimuli/number/number-4.jpg "number-4.jpg"
[nu5]: https://github.com/VPNL/fLoc/blob/master/stimuli/number/number-5.jpg "number-5.jpg"
[nu6]: https://github.com/VPNL/fLoc/blob/master/stimuli/number/number-6.jpg "number-6.jpg"

[ad1]: https://github.com/VPNL/fLoc/blob/master/stimuli/adult/adult-1.jpg "adult-1.jpg"
[ad2]: https://github.com/VPNL/fLoc/blob/master/stimuli/adult/adult-2.jpg "adult-2.jpg"
[ad3]: https://github.com/VPNL/fLoc/blob/master/stimuli/adult/adult-3.jpg "adult-3.jpg"
[ad4]: https://github.com/VPNL/fLoc/blob/master/stimuli/adult/adult-4.jpg "adult-4.jpg"
[ad5]: https://github.com/VPNL/fLoc/blob/master/stimuli/adult/adult-5.jpg "adult-4.jpg"
[ad6]: https://github.com/VPNL/fLoc/blob/master/stimuli/adult/adult-6.jpg "adult-6.jpg"

[ch1]: https://github.com/VPNL/fLoc/blob/master/stimuli/child/child-1.jpg "child-1.jpg"
[ch2]: https://github.com/VPNL/fLoc/blob/master/stimuli/child/child-2.jpg "child-2.jpg"
[ch3]: https://github.com/VPNL/fLoc/blob/master/stimuli/child/child-3.jpg "child-3.jpg"
[ch4]: https://github.com/VPNL/fLoc/blob/master/stimuli/child/child-4.jpg "child-4.jpg"
[ch5]: https://github.com/VPNL/fLoc/blob/master/stimuli/child/child-5.jpg "child-4.jpg"
[ch6]: https://github.com/VPNL/fLoc/blob/master/stimuli/child/child-6.jpg "child-6.jpg"

[ca1]: https://github.com/VPNL/fLoc/blob/master/stimuli/car/car-1.jpg "car-1.jpg"
[ca2]: https://github.com/VPNL/fLoc/blob/master/stimuli/car/car-2.jpg "car-2.jpg"
[ca3]: https://github.com/VPNL/fLoc/blob/master/stimuli/car/car-3.jpg "car-3.jpg"
[ca4]: https://github.com/VPNL/fLoc/blob/master/stimuli/car/car-4.jpg "car-4.jpg"
[ca5]: https://github.com/VPNL/fLoc/blob/master/stimuli/car/car-5.jpg "car-4.jpg"
[ca6]: https://github.com/VPNL/fLoc/blob/master/stimuli/car/car-6.jpg "car-6.jpg"

[in1]: https://github.com/VPNL/fLoc/blob/master/stimuli/instrument/instrument-1.jpg "instrument-1.jpg"
[in2]: https://github.com/VPNL/fLoc/blob/master/stimuli/instrument/instrument-2.jpg "instrument-2.jpg"
[in3]: https://github.com/VPNL/fLoc/blob/master/stimuli/instrument/instrument-3.jpg "instrument-3.jpg"
[in4]: https://github.com/VPNL/fLoc/blob/master/stimuli/instrument/instrument-4.jpg "instrument-4.jpg"
[in5]: https://github.com/VPNL/fLoc/blob/master/stimuli/instrument/instrument-5.jpg "instrument-4.jpg"
[in6]: https://github.com/VPNL/fLoc/blob/master/stimuli/instrument/instrument-6.jpg "instrument-6.jpg"

[ho1]: https://github.com/VPNL/fLoc/blob/master/stimuli/house/house-1.jpg "house-1.jpg"
[ho2]: https://github.com/VPNL/fLoc/blob/master/stimuli/house/house-2.jpg "house-2.jpg"
[ho3]: https://github.com/VPNL/fLoc/blob/master/stimuli/house/house-3.jpg "house-3.jpg"
[ho4]: https://github.com/VPNL/fLoc/blob/master/stimuli/house/house-4.jpg "house-4.jpg"
[ho5]: https://github.com/VPNL/fLoc/blob/master/stimuli/house/house-5.jpg "house-4.jpg"
[ho6]: https://github.com/VPNL/fLoc/blob/master/stimuli/house/house-6.jpg "house-6.jpg"

[co1]: https://github.com/VPNL/fLoc/blob/master/stimuli/corridor/corridor-1.jpg "corridor-1.jpg"
[co2]: https://github.com/VPNL/fLoc/blob/master/stimuli/corridor/corridor-2.jpg "corridor-2.jpg"
[co3]: https://github.com/VPNL/fLoc/blob/master/stimuli/corridor/corridor-3.jpg "corridor-3.jpg"
[co4]: https://github.com/VPNL/fLoc/blob/master/stimuli/corridor/corridor-4.jpg "corridor-4.jpg"
[co5]: https://github.com/VPNL/fLoc/blob/master/stimuli/corridor/corridor-5.jpg "corridor-4.jpg"
[co6]: https://github.com/VPNL/fLoc/blob/master/stimuli/corridor/corridor-6.jpg "corridor-6.jpg"

### Task

To ensure that participants remain alert throughout the experiment, a behavioral task is selected while executing the localizer code. Three options are available:

- 1-back — detect back-to-back image repetition
- 2-back — detect image repetition with one intervening stimulus
- Oddball — detect replacement of a stimulus with scrambled image

Task probes (i.e., image repetitions or oddballs) are inserted randomly in half of the stimulus blocks. By default participants are alloted 1 second to respond to a task probe, and responses outside of this time window are counted as false alarms. 

Behavioral data displayed at the end of each run summarize the hit rate (percentage of task probes detected within the time limit) and the false alarm count (number of responses outside of task-relevant time windows).

## Instructions

Follow the instructions below to setup the localizer code for your computer and equipment and then execute the experiment using the `runme` function ([`~/fLoc/runme.m`](https://github.com/VPNL/fLoc/blob/master/runme.m)).

### Setup

1. Clone fLoc repository on the computer you will use to present stimuli, and navigate to the functions directory (`~/fLoc/functions/`).
2. Modify the input registration functions for your local keyboard, button box, and trigger (optional):
    - *get_keyboard_num.m* — Change value of `keyboard_id` to the "Product ID number" of your local keyboard (line 9)
    - *get_box_num.m* — Change value of `box_id` to the "Product ID number" of the button box used at your scanner facilities (line 9)
    - *start_scan.m* — Change specifications to be compatible with your local trigger box (line 6)
3. Add Psychtoolbox to your MATLAB path.

### Execution

1. Navigate to base experiment directory in MATLAB (`~/fLoc/`).
2. Execute the `runme` wrapper function and enter the following information when prompted:
    1. Participant's initials or other session-specific identifier
    2. Triggering option:
      - Enter `0` if not attempting to trigger scanner (e.g., while debugging)
      - Enter `1` to automatically trigger scanner at onsets of experiments
    3. Stimulus set:
      - Enter `1` for the default set (body, word, adult, car, house)
      - Enter `2` for the alternate set (limb, number, child, instrument, corridor)
      - Enter `3` for both sets (presented in alternation in separate runs)
    4. Number of runs to execute
    5. Task for participant:
      - Enter `1` for 1-back image repetition detection
      - Enter `2` for 2-back image repetition detection
      - Enter `3` for oddball detection
3. Wait for task instructions screen to display.
4. Press `g` to start experiment (and trigger scanner if option is selected).
5. Wait for behavioral performance to display after each run.
6. Press `g` to continue experiment and start execution of next run.

### Debugging

- Press `[Command + period]` to halt experiment on a Mac or `[Ctrl + period]` on a PC.
- Enter `sca` to return to MATLAB command line.
- Please report bugs on GitHub.

## Code

The `runme` wrapper function generates an object `session` of the class `fLocSession` that is used to both run the experiment and store information about the participant, stimulus, and task performance. This generates a custom stimulus sequence for each run of the experiment that is stored in an object `seq` of the class `fLocSequence`.  Class files in [`~/fLoc/functions/`](https://github.com/VPNL/TemporalChannels/blob/master/functions) can be edited to customize the experimental design. 
 
Data files are saved in session-specific subdirectories in `~/fLoc/data/` that are labeled with ID strings concatenating the session name, date, task, and number of runs (e.g., `AS_09-Aug-2017_oddball_4runs`). 
- Each data subdirectory stores `.mat` files suffixed with `_fLocSession.mat` (which contain session information) and `_fLocSequence.mat` (which contain stimulus information). 
- Data subdirectories also contain stimulus parameter (`.par`) files that are used for analyzing fMRI data (`.par` files are written in a format compatible with [vistasoft](https://github.com/vistalab/vistasoft) by default). 


### Using the runme function

The `runme` function in the base experiment directory will prompt the experimenter for session information when called without input arguments. Alternatively, you can specify these settings in advance by including the following input arguments:

1. *name* — session-specific identifier (e.g., participant initials)
2. *trigger* — option to trigger scanner (0 = no, 1 = yes)
3. *stim_set* — stimulus set to use (1 = default, 2 = alternate, 3 = both)
4. *num_runs* — number of runs (stimuli repeat after two runs per set)
5. *task_num* — which task to use (1 = 1-back, 2 = 2-back, 3 = oddball)
6. *start_run* — run number to begin with (if experiment is interrupted)

As described in more detail below, if the experiment is interupted you can also load the participant's `*_fLocSession.mat` file from their data directory and enter `run_exp(session, start_run)` to execute all runs from *start_run* to *num_runs*. 

### Customizing the experiment

#### Using specific image categories

To customize which image subcategory is used for each stimulus condition, edit the `fLocSequence` class file as detailed below: 

1. Add a property to the `fLocSequence` class file called `stim_set3` that lists a one subcategory for each condition in the property `stim_conds`. For example:
```
stim_set3 = {'limb' 'word' 'adult' 'car' 'corridor'};
```
2. Insert an additional case switch in `fLocSequence`'s `get.run_sets` method for your custom selection of subcategories. For example:
```
case 4
    run_sets = repmat(seq.stim_set3, seq.num_runs, 1);
```
3. Modify the `stim_set` argument check in the `runme` function to include your custom option. For example:
```
while ~ismember(stim_set, 1:4)
    stim_set = input('Which stimulus set? (1 = standard, 2 = alternate, 3 = both, 4 = custom) : ');
end
```

#### Adding stimulus conditions

We strongly recommend including each of the five main stimulus conditions in the localizer (bodies, characters, faces, objects, places) regardless of the specific region/s you are interested in defining, as this provides a stronger test of selectivity compared to only comparing responses between a few categories. 

To include other stimulus conditions in the localizer, create a new fork of the repository and follow the instructions below: 

1. Add a new image category to the stimulus database: 
    1. Collect 144 examples of a new stimulus category of your choice (e.g., `hammer` for the condition *Tools*). 
    2. Control low-level image properties (luminance, contrast, visual field coverage, etc.) to minimize differences with existing categories. 
    3. Generate image filenames composed of a category label and image number delimited by a dash (e.g., `hammer-144.jpg`). 
    4. Place stimuli in a separate directory in `~/fLoc/stimuli/` named after the image category. 
2. If introducing a new stimulus condition to the localizer (e.g., *Tools*), append the name of the condition to the cell array of conditions labels in the `fLocSequence` property `stim_conds`. 
3. Include the name of the new image category (e.g., `hammer`) in the corresponding index of the cell arrays of image cagegory labels in the `fLocSequence` properties `stim_set1` and `stim_set2` (or create a new `stim_set3` property as described above). 
4. Note that changing the number of stimulus conditions will affect dependent properties of the `fLocSequence` class such as run duration (`run_dur`).

#### Customizing presentation parameters

Other aspects of the experimental design can be modified by changing constant properties in the `fLocSequence` class file.

- *Stimulus duty cycle* — the duration of each stimulus cycle (stimulus duration + interstimulus interval) is set in `stim_duty_cycle`.
- *Stimuli per block* — the number of stimuli in a block is set in `stim_per_block`. This parameter will also affect dependent properties such as run duration (`run_dur`).
- *Interstimulus inverval* — the duration of the interstimulus interval is set depending on task in `fLocSequence`'s `get.isi_dur` method.

## Analysis

### Analysis with vistasoft

To analyze fMRI data from the localizer experiment using functions from [vistasoft](https://github.com/vistalab/vistasoft):

1. Clone the [vistasoft](https://github.com/vistalab/vistasoft) and [fLoc](https://github.com/VPNL/fLoc) repositories on your machine and add to your MATLAB path.
2. Put all fMRI data files (`.nii.gz`) in the appropriate session directory in `~/fLoc/data/` with session-specific stimulus parameter (`.par`) files (e.g., `~/fLoc/data/s01/script_fLoc_run1.par`):
    1. fMRI data file names should end with `_run#.nii.gz` with run numbers incrementing from one (e.g., `~/fLoc/data/s01/fLoc_run1.nii.gz`).
    2. Stimulus parameter files should end with `_run#.par` with run numbers incrementing from one (e.g., `~/fLoc/data/s01/script_fLoc_run1.par`).
3. Optionally, put anatomical MRI scans (`.nii.gz`) in the same session directory:
    1. An anatomical inplane  scan named `*Inplane*.nii.gz` should be included if possible (e.g., `~/fLoc/data/s01/Inplane.nii.gz`). 
    2. A high-resolution whole-brain scan named `t1.nii.gz` can also be included in a `3Danatomy` subfolder (e.g., `~/fLoc/data/s01/3Danatomy/t1.nii.gz`). 
4. The function [`fLocAnalyis`](https://github.com/VPNL/fLoc/blob/master/functions/fLocAnalysis.m) automates the following data processing and analysis procedures for a single session:
    1. Initialize vistasoft session directory in `~/fLoc/data/[session]`.
    2. Perform slice timing correction (assuming interleaved slice acquisition). 
    3. Perform within-run motion compensation (and check for motion > 2 voxels). 
    4. Perform between-runs motion compensation (and check for motion > 2 voxels).
    5. Fit GLM in each voxel across all runs of the localizer.
    6. Generate vistasoft-compatible brain maps of the following model parameters:
        1. GLM betas (one map file per predictor in GLM design matrix)
        2. Residual variance of GLM (one map file per session)
        3. Proportion of variance explained (one map file per session)
        4. Default statistical contrasts comparing betas for each condition vs. all other conditions (one map per non-baseline condition). 
5. To run the automated fMRI data analysis pipeline for a single session, use `fLocAnalysis(session, init_params, glm_params, clip, stc)` with the following arguments:
    1. *session* — full path to session directory to analyze (char array).
    2. *init_params* — optional struct of initialization/preprocessing parameters (struct). 
    3. *glm_params* — optional struct of GLM analysis parameters (struct). 
    4. *clip* — number of TRs to clip from the beginning of each localizer run (int). 
    5. *stc* — flag controlling slice time correction (logical; default = 0, no correction). 
6. A log file named `fLocAnalysis_log.txt` is written in each session directory as the analysis progresses. This log file contains a high-level description of completed stages of the analysis. 
7. To run the automated analysis pipeline across a group of sessions, use `fLocGroupAnalysis(sessions, clip, stc)` with the following arguments:
    1. *session* — full path to session directory to analyze (char array).
    2. *clip* — number of TRs to clip from the beginning of each localizer run (int). 
    3. *stc* — flag controlling slice time correction (logical; default = 0, no correction). 
8. For group analysis, a log file named `vistasoft_log.txt` is also written in each session directory. This log file captures vistasoft outputs otherwise printed to the command line. 
9. To view a parameter map overlaid on the subject's anatomy:
    1. Navigate the to the appropriate session data directory.
    2. Enter `mrVista` in the command line to open a vistasoft inplane view.
    3. Change the *Data Type* (upper-right menu in GUI) from *Original* to *GLMs*.
    4. Click *File -> Parameter Map -> Load Parameter Map* and select a `.mat` file from the session GLMs directory (e.g., `~/fLoc/data/s01/Inplane/GLMs/face_vs_all.mat`).

*Note for VPNL users:* If analyzing MUX data from the CNI, always clip 2 TRs from beginning of each run. For non-MUX data, clip (countdown duration)/(TR duration) TRs from each run. In both cases, stimulus parameter files begin at the end of the countdown. 

### General linear model

Stimulus parameter (`.par`) files saved in session data subdirectories contain information needed to generate the design matrix for a General Linear Model (GLM):

1. Trial onset time (time relative to the start of the experiment in **seconds**)
2. Condition **number** (0 = baseline)
3. Condition **name**
4. Condition plotting **color** (RGB values from 0 to 1)

After acquiring and preprocessing functional data, a General Linear Model (GLM) is fit to the time series of each voxel to estimate *β* values of response amplitude to different stimulus categories (e.g., [Worsley et al., 2002](https://www.ncbi.nlm.nih.gov/pubmed/11771969)). For preprocessing we recommend performing motion correction, detrending, and transforming time series data to percent signal change without spatial smoothing.

### Regions of interest

Category-selective regions are defined by statistically contrasting *β* values of categories belonging to a given stimulus domain vs. all other categories in each voxel and thresholding resulting maps (e.g., t-value > 3):

- Character-selective regions
    + [`word` `number`] > [`body` `limb` `child` `adult` `corridor` `house car` `instrument`]
    + selective voxels typically clustered around the inferior occipital sulcus (IOS) and along the occipitotemporal sulcus (OTS)
    + ![Character selectivity map][charactermap]
- Body-selective regions
    + [`body` `limb`] > [`word` `number` `child` `adult` `corridor` `house` `car` `instrument`]
    + selective voxels typically clustered around the lateral occipital sulcus (LOS), inferior temporal gyrus (ITG), and occipitotemporal sulcus (OTS)
    + ![Body selectivity map][bodymap]
- Face-selective regions
    + [`child` `adult`] > [`word` `number` `body` `limb` `corridor` `house` `car` `instrument`]
    + selective voxels typically clustered around the inferior occipital gyrus (IOG), posterior fusiform gyrus (Fus), and mid-fusiform sulcus (MFS)
    + ![Face selectivity map][facemap]
- Place-selective regions
    + [`corridor` `house`] > [`word` `number` `body` `limb` `child` `adult` `car` `instrument`]
    + selective voxels typically clustered around the transverse occipital sulcus (TOS) and collateral sulcus (CoS)
    + ![Place selectivity map][placemap]
- Object-selective regions
    + [`car` `instrument`] > [`word` `number` `body` `limb` `child` `adult` `corridor` `house`]
    + selective voxels are not typically clustered in occipitotemporal cortex when contrasted against characters, bodies, faces, and places
    + object-selective regions in lateral occipital cortex can be defined in a separate experiment (contrasting objects > scrambled objects)
    + ![Object selectivity map][objectmap]

[charactermap]: https://github.com/VPNL/fLoc/blob/master/examples/characters_vs_all.png "characters_vs_all.png"
[bodymap]: https://github.com/VPNL/fLoc/blob/master/examples/bodies_vs_all.png "bodies_vs_all.png"
[facemap]: https://github.com/VPNL/fLoc/blob/master/examples/faces_vs_all.png "faces_vs_all.png"
[placemap]: https://github.com/VPNL/fLoc/blob/master/examples/places_vs_all.png "places_vs_all.png"
[objectmap]: https://github.com/VPNL/fLoc/blob/master/examples/objects_vs_all.png "objects_vs_all.png"


| Lateral Occipital Cortex | Posterior Ventral Temporal Cortex | Mid Ventral Temporal Cortex |
| ------------------------ |:---------------------------------:|:---------------------------:|
| ![lotc][lotc]            | ![pvtc][pvtc]                     | ![mvtc][mvtc]               |

[lotc]: https://github.com/VPNL/fLoc/blob/master/examples/LOTC_ROIs.png "LOTC_ROIs.png"
[pvtc]: https://github.com/VPNL/fLoc/blob/master/examples/pVTC_ROIs.png "pVTC_ROIs.png"
[mvtc]: https://github.com/VPNL/fLoc/blob/master/examples/mVTC_ROIs.png "mVTC_ROIs.png"

Category-selective regions defined in three anatomical sections of occipitotemporal cortex are shown above on the inflated cortical surface of a single subject with anatomical labels overlaid on significant sulci and gyri (see reference to labels above). *Green*: place-selective, *Blue*: body-selective, *Black*: character-selective, *Red*: face-selective. 

## Citation

To acknowledge using our localizer or stimulus set, you might include a sentence like one of the following:

"We defined regions of interest using the fLoc functional localizer (Stigliani et al., 2015)..."

"We used stimuli included in the fLoc functional localizer package (Stigliani et al., 2015)..."

### Article

Stigliani, A., Weiner, K. S., & Grill-Spector, K. (2015). Temporal processing capacity in high-level visual cortex is domain specific. *Journal of Neuroscience*, *35*(36), 12412-12424. 
[html](http://www.jneurosci.org/content/35/36/12412.short) | [pdf](http://vpnl.stanford.edu/papers/StiglianiJNS2015.pdf)

### Contact

Anthony Stigliani: astiglia [at] stanford [dot] edu

Kalanit Grill-Spector: kalanit [at] stanford [dot] edu
