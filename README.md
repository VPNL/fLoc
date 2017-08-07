# fLoc
Functional localizer experiment used to define category-selective cortical regions

* * *
*Notes:*

The code in this repository calls functions from [Psychtoolbox-3](http://psychtoolbox.org/) and is compatible with [MATLAB](https://www.mathworks.com/) R2013a and later versions.
* * *

*Contents:*

1. [Experimental Design](#experimental-design)
    1. [Stimulus Conditions](#stimulus-conditions)
    2. [Example images](#example-images)
    3. [Task](#task)

2. [Instructions](#instructions)
    1. [Setup](#setup)
    2. [Execution](#execution)
    3. [Debugging](#debugging)

3. [Code](#code)

4. [Analysis](#analysis)

5. [Citation](#citation)

* * *

## Experimental Design

This repository contains stimuli and presentation code for a functional localizer experiment used to define category-selective cortical regions that respond preferentially to faces (e.g., fusiform face area), places (e.g., parahippocampal place area), bodies (e.g., extrastriate body area), or printed characters (e.g., visual word form area). 

The localizer uses a mini-block design in which 12 stimuli of the same category are presented in each **6 second block** (500 ms/image). For each **4 minute run**, a novel stimulus sequence is generated that randomizes the order of five stimulus conditions (faces, places, bodies, characters, and objects) and a blank baseline condition. We recommend collecting at least **4 runs of data** per subject (16 minutes total) to have sufficient power to define these and other regions of interest.

### Stimulus Conditions

Each of the five stimulus conditions in the localizer is associated with two related stimulus sets (144 images per set):

- Bodies
    + body — whole bodies with cropped heads
    + limb — isolated arms, legs, hands, and feet
- Characters
    + word - pronounceable English pseudowords
    + number - uncommon numbers
- Faces
    + adult - portraits of adult faces
    + child - portraits of child faces
- Objects
    + car - four-wheel motor vehicles
    + instrument - musical string instruments
- Places
    + house - outdoor views of buildings
    + corridor - indoor views of hallways

### Example Images

|                |             |             |             |             |             |             |
| -------------- |:-----------:|:-----------:|:-----------:|:-----------:|:-----------:| :----------:|
| **Bodies**     |             |             |             |             |             |             |
| body           | ![bo1][bo1] | ![bo2][bo2] | ![bo3][bo3] | ![bo4][bo4] | ![bo5][bo5] | ![bo6][bo6] |
| limb           | ![li1][li1] | ![li1][li2] | ![li3][li3] | ![li4][li4] | ![li5][li5] | ![li6][li6] |
|                |             |             |             |             |             |             |
| **Characters** |             |             |             |             |             |             |
| word           | ![wo1][wo1] | ![wo2][wo2] | ![wo3][wo3] | ![wo4][wo4] | ![wo5][wo5] | ![wo6][wo6] |
| number         | ![nu1][nu1] | ![nu2][nu2] | ![nu3][nu3] | ![nu4][nu4] | ![nu5][nu5] | ![nu6][nu6] |
|                |             |             |             |             |             |             |
| **Faces**      |             |             |             |             |             |             |
| adult          | ![ad1][ad1] | ![ad2][ad2] | ![ad3][ad3] | ![ad4][ad4] | ![ad5][ad5] | ![ad6][ad6] |
| child          | ![ch1][ch1] | ![ch2][ch2] | ![ch3][ch3] | ![ch4][ch4] | ![ch5][ch5] | ![ch6][ch6] |
|                |             |             |             |             |             |             |
| **Objects**    |             |             |             |             |             |             |
| car            | ![ca1][ca1] | ![ca2][ca2] | ![ca3][ca3] | ![ca4][ca4] | ![ca5][ca5] | ![ca6][ca6] |
| instrument     | ![in1][in1] | ![in2][in2] | ![in3][in3] | ![in4][in4] | ![in5][in5] | ![in6][in6] |
|                |             |             |             |             |             |             |
| **Places**     |             |             |             |             |             |             |
| house          | ![ho1][ho1] | ![ho2][ho2] | ![ho3][ho3] | ![ho4][ho4] | ![ho5][ho5] | ![ho6][ho6] |
| corridor       | ![co1][co1] | ![co2][co2] | ![co3][co3] | ![co4][co4] | ![co5][co5] | ![co6][co6] |
|                |             |             |             |             |             |             |

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

To ensure that participants remain alert and attentive throughout the experiment, a task is selected while executing the localizer. Three options are available:

- 1-back - detect back-to-back image repetition
- 2-back - detect image repetition with one intervening stimulus
- Oddball - detect replacement of a stimulus with scrambled image

Task probes (i.e., image repetitions or oddballs) are inserted randomly in half of the stimulus blocks. By default participants are alloted 1 second to respond to a task probe, and responses outside of this time window are counted as false alarms. Behavioral data displayed at the end of each run summarize the hit rate (percentage of task probes detected within the time limit) and the false alarm count (number of responses outside of task-relevant time windows).

## Instructions

Follow the instructions below to (1) setup the localizer code for your computers/equipment and (2) execute the experiment.

### Setup

1. Navigate to the functions directory (`~/fLoc/functions/`)
2. Modify input registration functions for keyboard, button box, and trigger:
    - *get_keyboard_num.m* - Change value of `keyboard_id` to the "Product ID number" of your local keyboard (line 9)
    - *get_box_num.m* - Change value of `box_id` to the "Product ID number" of the button box used at your scanner facilities (line 9)
    - *start_scan.m* - Change specifications to be compatible with your local trigger box (line 6)
3. Add Psychtoolbox to your MATLAB path.

### Execution

1. Navigate to base experiment directory in MATLAB (`~/fLoc/`).
2. Execute the `runme.m` wrapper function.
3. Enter subject initials when prompted.
4. Select triggering option:
    - Enter `0` if not attempting to trigger scanner (e.g., while debugging)
    - Enter `1` to automatically trigger scanner at onset of experiment
5. Select stimulus set:
    - Enter `1` for the standard set (body, word, adult, car, house)
    - Enter `2` for the alternate set (limb, number, child, instrument, corridor)
    - Enter `3` for both sets (presented in alternation in separate runs)
6. Specify the numebr of runs to execute.
7. Select task for participant:
    - Enter `1` for 1-back image repetition detection
    - Enter `2` for 2-back image repetition detection
    - Enter `3` for oddball detection
5. Wait for task instructions screen to display.
6. Press `g` to start experiment (and trigger scanner if option is selected).
7. Wait for behavioral performance to display after each run.
8. Press `g` to continue experiment and start execution of next run.

### Debugging

- Press `[Command + period]` to halt experiment.
- Enter sca to return to MATLAB command line.
- Please report bugs on GitHub.

## Code

The *runme.m* wrapper function generates an object of the class `fLocSession` that is used to both run the experiment and also store information about the participant, stimulus, and experiment. A custom stimulus sequence is created for each run of the experiment and stored in an object of the class `fLocSequence`. 

### Using the runme function

The `runme.m` function will prompt the experimenter for session information when called without input arguements. However, you can also specify this information upfront by including following input arguements in the specified order:

1. *name* — session-specific identifier (e.g., participant initials)
2. *trigger* - option to trigger scanner (0 = no, 1 = yes)
3. *stim_set* - stimulus set to use (1 = standard, 2 = alternate, 3 = both)
4. *num_runs* - number of runs (stimuli repeat after two runs per set)
5. *task_num* - which task to use (1 = 1-back, 2 = 2-back, 3 = oddball)
6. *start_run* - run number to begin with (if experiment is interrupted)

The `fLocSession` and `fLocSequence` objects for each participant are saved session-specific subdirectories in the repository data directory (`~/fLoc/data/*`). Stimulus parameter (`*.par`) files used for analysis of fMRI data are written for each run and are also stored in data subdirectories. 

### Using fLocSequence methods

### Using fLocSession methods

## Analysis

## Citation
