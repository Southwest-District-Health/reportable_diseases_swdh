# Reportable Diseases Dashboard
This Shiny app allows users to see incidence rates of different diseases by county, as well as the disease definition, symptoms, and seasonality. 

## Getting Started
If you have already done what the below paragraph says, make sure every time you go to update the app you run the command `git pull` from within the project. This will check the online version of the repository on Github and if your local version is not up to date, it will update it. 

To be able to update this app, you will need a local copy of the repository on your computer. First, open git bash and navigate to the folder you want your local copy to be stored in by using the `cd FOLDER` or `cd 'FULL/FILE/PATH'` approach. Once there, go to the Github [homepage](https://github.com/Southwest-District-Health/reportable_diseases_swdh), though you may already be there if you are reading this. Once, there, click on the code button toward the top of the page. You will see a web address. Copy this address. Then, within git bash, run `git clone https://github.com/Southwest-District-Health/reportable_diseases_swdh.git`. This will make a copy of the entire project at the location you navigated to. Finally, within the `reportable_diseases_swdh` that was just created when you ran `git clone`, create a folder called `data`, and grab a copy of the all disease definitions spreadsheet from the `processed_data` folder and place it in the `data` folder.

### Prerequisites
Prerequisites will be listed at the top of every script you use as `library(package_name)` calls. At some point, renv will be added so that you can automatically have the packages installed but for now this feature is not available.  

## Updating the App
The app relies on four different datasets:
1. `All Disease Data.xlsx`, located in the processed_data folder
2. `All Disease Definitions`.xlsx, located in the processed_data folder
3. `co-est2019-annres-16.xlsx`, located in the raw_data folder
4. `co-est2021-pop-16.xlsx`, located in the raw_data folder.

### Step 1
Download the data from NBS and save it as `All Disease Data.xlsx` in the processed data folder. 

### Step 2
Make sure that either of the two co-est spreadsheets have populations for the years you are interested in. If not, if the year that is missing is after 2021, the population from 2021 will be used. I would make sure that you are okay with this or find an updated county population estimates spreadsheet from the census website. 

### Step 3
Open up the project by double clicking on the `reportable_diseases_swdh.Rproj` file. Then, in the console, run `source('update_app.R')`. This does a lot of things that used to be separate steps. First, it runs the `create_count_datasets.R` script that creates a new data set called `disease_count.csv` in the `data` folder. When this is running you will see in the R console that it asks you to select the General folder. What it has done is open a little folder explorer box (even if your task bar does not show it). Select the General folder and it will keep runing. Second, it runs the `create_county_population.R` script that creates the `county_population.csv` file in the `data` folder. This will again ask you to select the general folder a couple of times. Third, it will update the renv.lock file to match the packages you have on your local computer. It will ask you to type 'Y" to update the lockfile. Just do this and press enter. Fourth, as much as possible, it styles the `app.R` file to conform to the tidyverse style guide. Don't rely on this and try to write the code using this [style guide](https://style.tidyverse.org/). Fifth, it takes the current date and time on your machine and edits the `app.R` file so that the app will display when it was last updated. Sixth, it deploys the app to the shinyapps server. 

### Step 4
Go to (https://swdh.shinyapps.io/reportable_diseases_swdh/) and make sure that the app is working like it did when you checked it locally.

### Step 5
Commit the changes to git and push to Github. To do this, click on `Terminal` at the bottom of RStudio. Type `git add .` This stages all the files in the repository. To make sure it worked, type `git status`. This should tell you which files were changed. Then, type `git commit -m 'INSERT MESSAGE HERE'`. Make sure the message is at least somewhat informative of what you did. You can just say something like 'Updated NBS data up to March 31st 2023.' This commits the changes to the local repository, but now you need to push the changes to github. Do this by typing `git push -u origin master`. You can check whether it worked by going to the repository on github. At the very least, the `app.R` file should have the message you typed in for the commit next to it, along with the date. 

## Authors
Austin Gallyer, Lekshmi Venugopal, Cate Lewis, and Andy Nutting.

## License
This project is licensed under the GNU General Public License v3.0 - see COPYING.txt for details.