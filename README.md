# Reportable Diseases Dashboard
This Shiny app allows users to see incidence rates of different diseases by county, as well as the disease definition, symptoms, and seasonality. 

## Getting Started
There are two ways to test this app. The preferred method is that you log in to R2D2. Once in R2D2, navigate to projects/dashboards/reportable_diseases_swdh and open the `reportable_diseases_swdh.Rproj` file. When you do this, the package called renv should install the necessary packages to your rstudio session. Once that is completed, run the following `renv::restore()`. If none of this happens, you may need to install renv. Do so using `install.packages('renv')`.

Then, open the `app.R` file. Then ctrl+shift+enter or click the "Run App" button at the top of Rstudio. This will open a separate RStudio window. Sometimes the app will open within that window, but most of the time you will have to click "Open in Browser" and it will open the app in your browser. 

The second method requires downloading the entire project and its accompanying data locally to your machine. We want to avoid this unless absolutely necessary because it is better to keep sensitive data on the server, rather than on a local machine. If you want to do this, reach out to Austin Gallyer (austin.gallyer@phd3.idaho.gov).

### Prerequisites
All prerequisites should be installed by renv when you open the `.Rproj` file. 

## Updating the App
The app relies on four different datasets:
1. `All Disease Data.xlsx`, located in the processed_data folder
2. `All Disease Definitions`.xlsx, located in the processed_data folder
3. `co-est2019-annres-16.xlsx`, located in the raw_data folder
4. `co-est2021-pop-16.xlsx`, located in the raw_data folder.

The first step to updating the app will be downloading the data from NBS and saving it as `All Disease Data.xlsx` in the processed data folder. 

Second, based on the data you downloaded from NBS, make sure that either of the two co-est spreadsheets have populations for the years you are interested in. If not, if the year that is missing is after 2021, the population from 2021 will be used. I would make sure that you are okay with this or find an updated county population estimates spreadsheet from the census website. 

Third, you will want to create the count data set from the `All Disease Data.xlsx`. To do this, run the code in `create_count_dataset.R`. This will create an excel spreadsheet called `disease_count.csv` in the `data` folder. 
Fourth, you will want to create the county population data set. Run the code in `create_county_population.R` to do so. 

Fifth, open the `app.R` file. Then, check to make sure it works by using ctrl+shift+enter or by clicking "run app" button at the top of Rstudio. Click through the different tabs, change the years and so on and make sure the plots respond appropriately. Also make sure the years that you can click on on the left are what you expected. They are pulled from the All Disease file, so if you downloaded years you weren't interested in, they will show up here. 

Sixth, close all r scripts in R studio. Then, within the RStudio terminal, type `source('update_app.R')`. This does four things: First, it updates the renv.lock file to make sure all needed packages are installed in the renv when someone opens the project. Second, as much as possible, it styles the `app.R` file to conform to the tidyverse style guide. Don't rely on this and try to write the code using this [style guide](https://style.tidyverse.org/). Third, it takes the current date and time on your machine and edits the `app.R` file so that the app will display when it was last updated. Fourth, it deploys the app to the shinyapps server. 

Seventh, go to (https://swdh.shinyapps.io/reportable_diseases_swdh/) and make sure that the app is working like it did when you checked it locally.

Eighth, commit the changes to git and push to Github. To do this, click on `Terminal` at the bottom of RStudio. Type `git add .` This stages all the files in the repository. To make sure it worked, type `git status`. This should tell you which files were changed. Then, type `git commit -m 'INSERT MESSAGE HERE'`. Make sure the message is at least somewhat informative of what you did. You can just say something like 'Updated NBS data up to March 31st 2023.' This commits the changes to the local repository, but now you need to push the changes to github. Do this by typing `git push -u origin master`. You can check whether it worked by going to the repository on github. At the very least, the `app.R` file should have the message you typed in for the commit next to it, along with the date. 

## Authors
Austin Gallyer, Lekshmi Venugopal, Cate Lewis, and Andy Nutting.

## License
This project is licensed under the GNU General Public License v3.0 - see COPYING.txt for details.