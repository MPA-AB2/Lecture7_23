# Lecture7 - IMAGE SEGMENTATION

[**Benchmark Results**](https://moodle.vut.cz/pluginfile.php/411642/mod_resource/content/1/L7_BenchmarkSegmentation.xlsx%20-%20List1.pdf)

## Preparation

1. Run Git bash.
2. Set username by: `$ git config --global user.name "name_of_your_GitHub_profile"`
3. Set email by: `$ git config --global user.email "email@example.com"`
4. Select some MAIN folder with write permision.
5. Clone the **Lecture7_23** repository from GitHub by: `$ git clone https://github.com/MPA-AB2/Lecture7_23.git`
6. In the MAIN folder should be new folder **Lecture7**.
7. In the **Lecture7_23** folder create subfolder **NAME_OF_YOUR_TEAM**.
8. Run Git bash in **Lecture7_23** folder (should be *main* branch active).
9. Create a new branch for your team by: `$ git checkout -b NAME_OF_YOUR_TEAM`
10. Check that  *NAME_OF_YOUR_TEAM* branch is active.
11. Continue to the task...

## Tasks to do

1. Download the histological data in a zip folder from [here](https://www.vut.cz/www_base/vutdisk.php?i=311673ad45). Extract the content of the zip folder OUTSIDE **Lecture7_23** folder. It contains folder **public** with 41 images *imXX.png* and 41 ground truth segmentation masks **maskXX.png**.
2. Use any automatic segmentation method to segment five categories in histologicla slices:
  * background,
  * tumour,
  * stroma,
  * necrosis,
  * fat.

3. Use the provided MATLAB function for evaluation of the results and submit the output to the provided [**Excel**](https://docs.google.com/spreadsheets/d/1eVXez4Z985BxftOCF1nldSYCXMIimW3E/edit?usp=sharing&ouid=105272487043795807825&rtpof=true&sd=true) table. The function *evaluate_segmentation.m* called as:
`[dice_scores] = evaluate_segmentation(gt_path, segmented_path)`,
has the following inputs:
  * gt_path – path into the **public** folder containing GT masks,
  * segmented_path - path into OTHER folder containing YOUR segmentation masks - grayscale **maskXX.png** images, uint8 with labels 0, 1, 2, 3, 4,
and outputs:
  * dice_scores – structure of results: mean Dice coefficient and its standard deviaton. Further, the structure contains detailed info about individual images and labels.
7. Store your implemented algorithm as a form of function `[] = segment_histo(pathToImages, pathOfResults)`, where:
  * *pathToImages* is the path to the **public/blind** folder containing images and GT masks,
  * *pathOfResults* is the path to the **results** folder containing your segmentations in the same format, data type and names as GT masks. The function will be used for evaluation of universality of your solution using another input images. **Push** your program implementations into GitHub repository **Lecture7_23** using the **branch of your team** (stage changed -> fill commit message -> sign off -> commit -> push -> select *NAME_OF_YOUR_TEAM* branch -> push -> manager-core -> web browser -> fill your credentials).
