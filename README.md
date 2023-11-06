# MeltShiny Documentation

## Problem: MeltWin

Researchers are currently using a legacy program called MeltWin to fit DNA absorbance melting curves to obtain folding information in the form of thermodynamic parameters. MeltWin was designed over 20 years ago, and as such, is not optimized for modern systems, and is only capable of running on Windows. Furthermore, a lack of source code makes modification impossible. There is a need for a program that both includes the functions of MeltWin, is capable of taking advantage of major modern operating systems such as Windows and MacOS, introduces automation, and provides an intuitive user interface, all goals of the MeltShiny open-source program.

## Bridge: MeltR

MeltShiny's functionality relies on an existing open-source package written in the R programming language called MeltR. It was developed by Jacob Sieg of Penn State University. MeltR possesses many of the same calculation and fitting abilities as its predecessor, MeltWin. Specifically, both MeltR and MeltWin provide easy and consistent fitting of nucleic acid folding data to obtain thermodynamic parameters. MeltR’s features are more robust and require less user input compared to MeltWin. However, unlike MeltWin which has a graphical user interface, MeltR requires that users interact with it via the R console. Typing commands into a command line interface can be tedious and require technical knowledge.

## Solution: MeltShiny

MeltShiny eliminates the need for the console, as it provides an intuitive graphical user interface that can be used by individuals of all skill levels. Relying on the robust and reliable calculations of MeltR, MeltShiny's benefits also extend to its functionality. Users are provided with automated processing of input files, as well as the automated removal of outliers from both the Van't Hoff plot and the results table. The end result is a program that provides researchers with the best possible workflow, reducing the time they have to spend interacting with a computer and increasing the time they have for research and analysis.

## Research

Researchers hope to understand the function of different DNA and RNA molecules. Researchers shine light through these molecules and record the absorption data. Due to intricate baseparing and folding patterns, the absorption data for specific RNA and DNA molecules will be unique. This data can mathematically be translated through the fitting of absorbance melting curves into thermodynamic parameters to obtain folding information.

## MeltShiny Installation Instructions

### Installing R

To run MeltShiny you need to download R. Go to the RStudio website, https://posit.co/download/rstudio-desktop/. There, you will see two download options. Only R is required. Download R according to your system.

### Downloading the MeltShiny Repository

Go to the following website https://github.com/oss-slu/MeltWin2.0. This link will take you to the MeltShiny GitHub repository where you can download the MeltShiny application. To download from the repository, click the green button that says "clone" and click download ZIP. Once downloaded, extract the folder. Move the extracted folder to whereever you so choose. Upon opening this folder, you will find three folders: code, Windows_Scripts, and MacOS_Scripts. The code folder should not be touched. Depending on your system, you will be using either the Windows or MacOS script folders.

### Installing Dendencies

MeltShiny has some dependencies which will need to be installed for the program to run. R Package installer files have been included, with the names MeltShinyDependenciesInstaller.command and MeltShinyDependenciesInstaller.bat for MacOS and Windows, respectively. These files are found within the MacOS_Scripts and Windows_Scripts folders found within the MeltShiny application bundle.Note, that in order for the Windows version to work, you must add the R bin folder to your PATH variable. For MacOS, the script can be used without any additional work.

Double clicking MeltShinyDependenciesInstaller.command or MeltShinyDependenciesInstaller.bat for Mac and Windows, respectively, will open up a terminal. The terminal will display the progress of each package as they are installed. In the end, all the packages will be shown in a list format with either a check or an x next to them. All packages with a check next to them were successfully installed. You can then close the terminal.

### Adding R to Path (Windows Only)

The following steps will guide you through this process, which only needs to be done once.

1. Using Windows search, type environment. A search option will appear titled "Edit the system environment variables". Click this.

2. When the System Properties popup opens, click on the Environment Variables button at the bottom.

3. In the window that pops up, select the “PATH” variable (either per user or for the whole system) and click the “Edit” button below it.

4. Click on a blank row and ensure none of the rows are highlighted.

5. In the next window that pops up, click the “Browse” button. Using the file explorer that pops up, locate your R bin folder. If you chose to install R in the default location during R installation process, the path will follow the format: "C:\Program Files\R\R-version\bin", where the R-version will depend on the version of R you have installed. For example, a user who has an R version of 4.2.2 will have a path of "C:\Program Files\R\R-4.2.2\bin".

6. Once you have added the R bin folder to your PATH variable, press ok and ok again to close the environment manager.

Some users may have issues regarding the installation of R packages and dependencies, which means that the folder is not writable, and access needs to be given. Follow these steps if this is the case.

1. Navigate to the same folder that contains your R bin folder, as you found while adding R to your PATH variable

2. Right-Click on the library folder, and click Properties

3. Click Edit, and a new pop out with 2 scroll windows should open. In the top one, select Users, and in the bottom one, fill in the box under 'Allow' next to 'Write', and click Apply. Click 'OK' and re-run the DependenciesInstaller

## Running MeltShiny

Double clicking the MeltShiny.command and MeltShiny.bat for Mac and Windows, respectively, will open a terminal. The terminal will show some numbers before starting the MeltShiny application in your default web browser. This program uses a local host, so the contents you provide in the program are localized to your computer. Should the application not open automatically, copy the numbers at the bottom of the terminal into a browser tab. Note, the terminal must remain open for the MeltShiny application to run. Once you are done with your MeltShiny session, close out of the application tab and close the terminal.

### Updating the MeltShiny Program

To obtain the latest version of the MeltShiny program, update scripts have been included, with names MeltShinyUpdate.command and MeltShinyUpdate.bat for MacOS and Windows, respectively. These files are found within the MacOS_Scripts and Windows_Scripts folders within the MeltShiny application bundle. Per the nature of deleting and replacing directories, ensure that you have not changed the file structure of the MeltShiny package; the code and Mac/Windows script subdirectories should remain within the MeltWin2.0-man directory the package is wrapped in. Although checks have been put in place for any deviations to this, we recommend leaving the file structure as is to ensure there are no unforeseen consequences.

Double clicking MeltShinyUpdate.command or MeltShinyUpdate.bat for Mac and Windows, respectively, will open up a terminal. This terminal will display the progress of downloading the main zip file from the GitHub page as well as progress of downloading/extracting its contents. In the end, the contents of the code subdirectory will be replaced with updated versions and the terminal will state your program is up to date. Otherwise, the respective error message will appear as to what went wrong.
