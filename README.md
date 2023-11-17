# Palmer Penguins Explorer App

**Link to Running Shiny App**: [Palmer Penguins Explorer](https://bc-liquor-xin-wang-stat545b-2023wt1.shinyapps.io/bc_liquor_xin_wang/)

**Assignment Choice**: Option B - Palmer Penguins Explorer app

## Description

The Palmer Penguins Explorer App allows users to interactively explore data about penguins at Palmer Station. It introduces several features to enhance user experience compared to the "basic" version.

**Key Features:**

1. **Bill Depth Filters**: Users can filter penguins based on bill depth, enabling the exploration of correlations between bill characteristics and other variables.

2. **Bill Length Slider**: Users can select a specific range of bill lengths, aiding research into the preferred bill length of specific penguin species.

3. **Island Selection**: Users can filter penguins based on the located island, providing insights into regional variations and geological differences influencing penguins.

4. **Year Filter**: Users can select a specific year to filter the data, allowing them to focus on penguin populations in a particular year of interest.

5. **Full Data Checkbox**: Users can choose to display only penguins with complete data, facilitating analysis when complete information is crucial.

6. **Downloadable Table**: Users can download the filtered penguin data as a .csv file, streamlining the extraction of specific information for further analysis.

7. **Species-specific Histogram**: The histogram displays the distribution of penguin body mass weight with distinct colors for each penguin species, offering a clearer visualization of the data.

**Dataset Source**

The dataset used in this app is the `palmerpenguins` dataset from the [palmerpenguins R package](https://github.com/allisonhorst/palmerpenguins). The package provides data on various penguin species, including information such as bill depth, bill length, body mass, and more.

The `palmerpenguins` package can be installed using:

```R
install.packages("palmerpenguins")
```

The data is publicly available and easily accessible through the R package, aligning with principles of transparency and reproducibility.

## Instructions
To run this Shiny app locally:

1. Clone this repository to your local machine.
2. Install the required R packages by running install.packages(c("shiny", "datateachr", "dplyr", "ggplot2", "DT", "palmerpenguins")) in your R console.
3. Open the R script (app.R) in RStudio.
4. Run the app by clicking the "Run App" button.