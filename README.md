# MeltShiny Documentation

## Purpose
The MeltShiny open-source program was designed and implemented to solve the following problem. Researchers are currently using a legacy program called MeltWin to analyze DNA absorbance data. MeltWin was designed over 20 years ago, and as such, is not optimized for modern systems, and is only capable of running on Windows. Furthermore, a lack of source code makes modification impossible. Therefore, there is a need for a program that both includes the functions of MeltWin, is capable of taking advantage of major modern operating systems, introduces new features, and provides an intuitive user interface. The end result is a program that provides researchers with the best possible work flow, reducing the time they have to spend interacting with a computer and increasing the time they have for research and analysis.

## Research
Researchers hope to understand the function of different DNA and RNA molecules. One way to achieve this is to shine light through these molecules and record the absorbtion data. Due to intricate baseparing and folding patterns, the absorption data for specific RNA and DNA molecules will be unique. This data can mathematically be translated into the strengths of the bonds formed by the nucletides of the DNA or RNA molecules being tested. Knowing the strength of bonds is important for determining the shape and stability of the whole molecule. Critically, in biological applications, knowing the structure of a molecule allows for the understanding of its function. 

## Introduction to MeltR
MeltShiny's backend functionality relies on an existing open-source software called MeltR. MeltR is a R package, written by Jacob Sieg-Penn, a chemistry department faculty member at Penn State University. This program is written entirely in R and possesses many of the same calculation and fitting abilities as its predecessor, MeltWin. Specifically, both MeltR and MeltWin provide easy and consistant fitting of nucleic acid folding data to obtain thermodynamic parameters. However, the features in MeltR are more robust and require less input from the user. 

## Benefits of MeltShiny
The downside of MeltR is that users must interact with it via the R console, whereas MeltWin has a graphical user interface. The process of typing in commands into the console can be time consuming, tedius, and requires some technical knowledge. MeltShiny eliminates the need for the console, as it provides an intuitive graphical user interface that can be used by individuals of all skill levels. Relying on the robust and reliable calculations of MeltR, MeltShiny's benefits also extend to its functionality. Users are provided with automated processing of input files, as well as the automated removal of outliers from both the Van't Hoff plot and the results table. 

## MeltShiny Installation Instructions
### Installing R and RStudio
To run MeltShiny you need to download R. Go to the RStudio website, https://posit.co/download/rstudio-desktop/. There, you will see two download options, one for R, and the other for RSTudio. Download R according to your system. RStudio is not necessary.

### Downloading the MeltShiny Repository
Go to the following website https://github.com/oss-slu/MeltWin2.0. This link will take you to the MeltShiny GitHub repository where you can download the MeltShiny application. To download from the repository, click the green button that says "clone" and click download ZIP. Once downloaded, extract the folder. Move the extracted folder to whereever you so choose. Open opening this folder, you will find three folders: code, Windows_Scripts, and MacOS_Scripts. The code folder should not be touched. Depending on your system, you will be using either the Windows or MacOS script folders. Note, that after initial deployment of the project, updates may be made. To obtain the latest version, you can delete the previous installation by deleting the MeltShiny folder in your selected location and following the sames steps as before to download the new version from the MeltShiny page. 

### Installing R Packages
MeltShiny has some dependencies which will need to be installed for the program to run. The MeltShiny team has developed a way to install packages without the need to open the R console. This method relies on a package installer file, with the names MeltShinyDependenciesInstaller.command and MeltShinyDependenciesInstaller.bat for MacOS and Windows, respectively. These files are found within the MacOS_Scripts and Windows_Scripts folders found within your MeltShiny application bundle.

Note, that in order for the Windows versions to work, you must add the R bin folder to your PATH variable. The following steps will guide you through this process. This process only needs to be done once.

1. Using Windows search, type environment. A search option will appear titled "Edit the system environment variables". Click this.

2. When the System Properties popup opens, click on the Environment Variables button at the bottom.

3. In the window that pops up, select the “PATH” variable (either per user or for the whole system) and click the “Edit” button below it.

4. In the next window that pops up, click the “Browse” button. Using the file explorer that pops up, locate your R bin folder. If you chose to install R in the default location during R installation process, the path will follow the format: "C:\Program Files\R\R-version\bin", where the R-version will depend on the version of R you have installed. For example, a user who has an R version of 4.2.2 will have a path of "C:\Program Files\R\R-4.2.2\bin". Once you have added the R bin folder to your PATH variable, you are free to use the MeltShinyDependenciesInstaller.bat file. 

To use these installer files, enter the appropriate script folder for your system and double click the installer file like you would any application. Doing so will open up a terminal. The terminal will display the progress of each package as they are installed. In the end, all the packages will be shown in a list with either a check or an x next to them. All packages with a check next to them were successfully installed. If there are no x's, you can close the terminal by pressing any key. All packages with an x next to them were unsucessful. In this case, the terminal will display the lines of code needed to install these packages manually. Enter the lines in the R console one by one, pressing enter each time. 

### Issues With Installing MeltR?
If you are having issues installing MeltR on your computer, the MeltR repository states you may need to run R as an administrator for installing devtools and MeltR on Windows. For MacOS, you may need to install the Xcode toolbox from the app store to install devtools.

### Running MeltShiny
The MeltShiny team has developed a way to run the program without the need to open RStudio. This method relies on a program execution file, titled MeltShiny.command and MeltShiny.bat for Mac and Windows, respectively. These files are found within the MacOS_Scripts and Windows_Scripts folders found within your MeltShiny application bundle. The Windows scripts will require that the R bin folder has been added to your path. If you followed the steps for adding the R bin folder to your PATH variable earlier, you do not need to repeat them to utilize the Meltshiny.bat file. 

To use these installer files, enter the appropriate script folder for your system and double click the installer file like you would any application. Doing so will open a terminal, which which indicate the status of loading necessary libraries and starting the MeltShiny application. The terminal will then automatically open the program in your default web browser. Should the application not open automatically, copy the numbers at the bottom of the terminal into a browser tab. Note, the terminal must remain open for the MeltShiny application to run. Once you are done with your MeltShiny session, close out of the tab and close the terminal. 

### MeltShiny Input Instructions
For now, you can use the following arguments to fill the inputs. Note, there should be no spaces in any of the inputs. 
```
Pathlength: 1,1,1,1,1,1,1,1,1,1 
Sequence info: RNA,CGAAAGGU,ACCUUUCG. 
Wavelength: 260
```
All other input defaults are fine. Once the inputs are filled, click the browse button to upload the file test.csv. The file is included in the MeltShiny application bundle.
