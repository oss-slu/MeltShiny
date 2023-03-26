# MeltShiny Documentation

## Purpose
The MeltShiny open-source program was designed and implemented to solve the following problem. Researchers are currently using a legacy program called MeltWin to analyze DNA absorbance data. MeltWin was designed over 20 years ago, and as such, is not optimized for modern systems. Furthermore, a lack of source code makes modification impossible. Therefore, there is a need for a program that both includes the functions of MeltWin, is capable of taking advantage of modern operating systems, introduces new features, and provides an intuitive user interface, all of which provide researchers with the best possible work flow. The end result is a program that reduces the time researchers have to spend interacting with a computer and increases the time they have for research and analysis.

## Research
Instances of DNA and RNA molecules absorb light differently due to intricate basepairing and folding patterns. The ability for these molecules to absorb light yields data that can mathematically be translated into the strengths of the bonds formed by the strands of the DNA or RNA molecules being tested. Knowing the strength of bonds is important for determining the shape and stability of the whole molecule. Critically, in biological applications, knowing the structure of a molecule allows for the understanding of its function. 

## Introduction to MeltR
MeltShiny's backend functionality relies on another open-source software called MeltR. MeltR is a R package, written by Jacob Sieg-Penn, a chemistry department faculty member at Penn State University. This program is written entirely in R and possesses many of the same calculation and fitting abilities as its predecessor, MeltWin. Specifically, both MeltR and MeltWin provide easy and consistant fitting of nucleic acid folding data to obtain thermodynamic parameters. However, the features in MeltR are more robust and require less input from the user. 

## Benefits of MeltShiny
The downside of MeltR is that users must interact with it via the R console, whereas MeltWin has a graphical user interface. The process of typing in commands into the console can be time consuming, tedius, and requires some technical knowledge. MeltShiny eliminates the need for the console, as it provides an intuitive graphical user interface that can be used by individuals of all skill levels. Relying on the robust and reliable calculations of MeltR, MeltShiny's benefits also extend to its functionality. Users are provided with automated processing of input files, as well as the automated removal of outliers from both the Van't Hoff plot and the results table. 

## MeltShiny Installation Instructions
### Installing R and RStudio
To run MeltShiny you need to download R and RStudio. Go to the RStudio website, https://posit.co/download/rstudio-desktop/. There, you will see two download options, one for R, and the other for RSTudio. Download them both according to your system. 

### Downloading the MeltShiny Repository
Go to the following website https://github.com/oss-slu/MeltWin2.0. This link will take you to the MeltShiny GitHub repository, where you can download the MeltShiny application. To do this, click the green button that says "clone" and click download ZIP. Once downloaded, extract the folder. Move the extracted folder to whereever you so choose. Note, that after initial deployment of the project, updates may be made. To obtain the latest version, you can delete the previous installation by deleting the MeltShiny folder in your selected location and following the aforementioned steps to download the new version from the MeltShiny page. 

### Installing R Packages
MeltShiny has some dependencies which will need to be installed for the program to run. There are two ways to do this. The traditional pathway involves opening RStudio and entering the following command in the console at the bottom and pressing enter. 

```
install.packages(c("dplyr", "DT", "ggplot2", "glue", "devtools", "openxlsx", "plotly", "shiny", "methods", "ggrepel", "tidyverse"))
```

The installation of MeltR requires an additional command.

```
devtools::install_github("JPSieg/MeltR")
```

The MeltShiny team also developed a way to install packages without the need to open RSTudio. This method relies on a package installer file, with the file extension of .command and .bat for MacOS and Windows, respectively. These are included alongside the MeltShiny application files.

Note, that in order for the Windows versions to work, you must add the R bin folder to your path. The following steps will guide you through this process. This process only needs to be done once.

1. Using Windows search, type environment. A popup will appear titled "Edit the system environment variables". Click this.

2. When the System Properties popup opens, click on the Environment Variables button at the bottom.

3. In the window that pops up, select the “PATH” variable (either per user or for the whole system) and click the “Edit” button below it.

4. In the next window that pops up, click the “Browse” button. Using the file explorer that pops up, locate your R bin folder. If you chose to install R in the default location during installation, the path will follow the format: C:\Program Files\R\R-version\bin, where R-version will depend on the version of R you have installed. For example, a user who has an R version of 4.2.2 will have a path of C:\Program Files\R\R-4.2.2\bin

Once you have added the R bin folder to your PATH variable, you are free to use the windows package installer file. Double click the appropriate file for your system like you would any .exe file. Doing so will open up a terminal. The terminal will display the status of each package as they are installed. All packages with a check next to them were successfully installed. In this case, you can close the terminal by pressing any key. All packages with an x next to them were unsucessful. In the case of the latter, the terminal will display the lines of code needed to install these packages. Enter the lines in RStudio's console one by one, pressing enter each time. 

### Issues With Installing MeltR?
If you are having issues installing MeltR on your computer, the MeltR repository states you may need to run R as an administrator for installing devtools and MeltR on Windows. On MacOS, you may need to install the Xcode toolbox from the app store to install devtools.

### Running MeltShiny
There are two ways to run MeltShiny. The traditional way involves open either the server or UI files and clicking Run App in the top right corner of the code view panel. However, be warned that because the program files needs to be open at runtime, it's possible to accidently modify them, thus breaking the code. For this reason, the MeltShiny team has developed a way to run the program without the need to open RStudio. This method relies on a program file, with the file extension of .command and .bat for Mac and Windows, respectively. These are included alongside the MeltShiny application files. Again, the windows scripts will require that the R bin folder has been added to your path. If you followed those steps earlier, you do not need to repeat them to utilize the Meltshiny.bat file. Double click the appropriate file for your system like you would any .exe file. Doing so will open a terminal, which which indicate the status of necessary librarys. The terminal will then automatically open the program in your default web browser. 

### MeltShiny Input Instructions
For now, you can use the following arguments to fill the inputs. Note, there should be no spaces in any of the inputs. 
```
Pathlength: 1,1,1,1,1,1,1,1,1,1 
Sequence info: RNA, CGAAAGGU, ACCUUUCG. 
Wavelength: 260
```
All other input defaults are fine. Once the inputs are filled, click the browse button to upload the file test.csv. The file is included in the MeltShiny application bundle.
