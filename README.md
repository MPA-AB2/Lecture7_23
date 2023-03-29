# Lecture7 - IMAGE SEGMENTATION

[**Benchmark Results**](https://moodle.vut.cz/pluginfile.php/411642/mod_resource/content/1/L7_BenchmarkSegmentation.xlsx%20-%20List1.pdf)

## Preparation

1. Run Git bash.
2. Set username by: `$ git config --global user.name "name_of_your_GitHub_profile"`
3. Set email by: `$ git config --global user.email "email@example.com"`
4. Select some MAIN folder with write permision.
5. Clone the **Lecture7** repository from GitHub by: `$ git clone https://github.com/MPC-AB2/Lecture7.git`
6. In the MAIN folder should be new folder **Lecture7**.
7. In the **Lecture7** folder create subfolder **NAME_OF_YOUR_TEAM**.
8. Run Git bash in **Lecture7** folder (should be *main* branch active).
9. Create a new branch for your team by: `$ git checkout -b NAME_OF_YOUR_TEAM`
10. Check that  *NAME_OF_YOUR_TEAM* branch is active.
11. Continue to the task...

## Tasks to do

1. Download the data in a zip folder from [here](https://www.vut.cz/www_base/vutdisk.php?i=286946a1bd). Extract the content of the zip folder into **Lecture7** folder. It contains folder **Cats** with 5 images *catX.jpg*.
2. Load all 5 images from folder **Cats**.
3. Optionally pre-process the images to a convenient form.
4. Use any automatic segmentation method to distinguish the image area of cat(s) and the background.
5. Optionally use post-processing (e.g. proper morphological operations) to refine the segmentation results 
6. Use the provided MATLAB function for evaluation of the results and submit the output to the provided [**Excel**](https://docs.google.com/spreadsheets/d/1eVXez4Z985BxftOCF1nldSYCXMIimW3E/edit?usp=sharing&ouid=105272487043795807825&rtpof=true&sd=true) table. The function *Eval_Segmentation.p.p* called as:
`[segmResults] = Eval_Segmentation(segmentedImage)`,
has the following inputs and outputs:
  * segmentedImage – cell array (1x5) of logical-type masks with value 1 for the area of the cat and value 0 for the background. The dataset consists of 5 cats; hence the size of the cell array is 1x5. The order of the masks must respect the order of the cat.
  * segmResults – structure of results: mean Dice coefficient and their standard deviaton. Further, the structure contains Dice coefficients for every image.
7. Store your implemented algorithm as a form of function `[segmentedImages] = TeamName(pathToImages)`; for *segmentedImages* see above; *pathToImages* is the path to the **Cats** folder with containing blind dataset of images. The function will be used for evaluation of universality of your solution using another input images. **Push** your program implementations into GitHub repository **Lecture7** using the **branch of your team** (stage changed -> fill commit message -> sign off -> commit -> push -> select *NAME_OF_YOUR_TEAM* branch -> push -> manager-core -> web browser -> fill your credentials).
