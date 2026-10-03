library(ggplot2)

mpg |> ggplot(aes(x = hwy, y = cty)) + 
  geom_point()
mpg |> ggplot(aes(x = hwy, y = cty)) + 
  geom_jitter()
mpg |> ggplot(aes(x = hwy, y = cty, colour = trans)) + 
  geom_jitter()

mpg |> ggplot(aes(x = hwy, y = cty, label=model)) + 
  geom_jitter()
library(plotly)
ggplotly()


mpg |> ggplot(aes(x = hwy, y = cty, colour=class)) + 
  geom_jitter()

mpg |> ggplot(aes(x = hwy, y = cty, colour=class)) + 
  geom_jitter() + facet_wrap(~class)

mpg |> ggplot(aes(x = class, y = cty, fill=factor(year))) + 
  geom_boxplot()

mpg |> ggplot(aes(x = class, y = hwy, fill=factor(year))) + 
  geom_boxplot()

library(tayloRswift)
mpg |> ggplot(aes(x = hwy, y = cty, colour = class)) + 
  geom_jitter() +scale_color_viridis_d()

mpg |> ggplot(aes(x = hwy, y = cty, colour = class)) + 
  geom_jitter() +scale_color_locuszoom()
mpg |> ggplot(aes(x = hwy, y = cty, colour = class)) + 
  geom_jitter() +scale_color_manual(values=c("red","maroon", "chartreuse", "darkred", "darkgreen", "orange", "forestgreen"))




R version 4.6.0 (2026-04-24) -- "Because it was There"
Copyright (C) 2026 The R Foundation for Statistical Computing
Platform: x86_64-apple-darwin20

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type 'license()' or 'licence()' for distribution details.

Natural language support but running in an English locale

R is a collaborative project with many contributors.
Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.

Loading required package: usethis
> library(leaflet)
> library(leaflet.providers)
> library(readr)
> library(tidyverse)
── Attaching core tidyverse packages ──────────────────────────── tidyverse 2.0.0 ──
✔ dplyr     1.2.1          ✔ purrr     1.2.2     
✔ forcats   1.0.1          ✔ stringr   1.6.0     
✔ ggplot2   4.0.3.9000     ✔ tibble    3.3.1     
✔ lubridate 1.9.5          ✔ tidyr     1.3.2     
── Conflicts ────────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
ℹ Use the conflicted package to force all conflicts to become errors
> library(htmlwidgets)
> library(plotly)

Attaching package: ‘plotly’

The following object is masked from ‘package:ggplot2’:
  
  last_plot

The following object is masked from ‘package:stats’:
  
  filter

The following object is masked from ‘package:graphics’:
  
  layout
> #files <- dir("data/stations", pattern="csv.gz",
  > #             full.names = TRUE )
  > files <- here::here("slides/data/stations/roosevelt.csv.gz")
> weather <- read_csv(files,
                      + col_names = c(
                        +       "id", "date", "element", "value",
                        +       "m_flag", "q_flag", "s_flag", "obs_time"
                        +     ),
                      +     col_types = cols(
                        +       id       = col_character(),
                        +       date     = col_date(format = "%Y%m%d"),
                        +       element  = col_character(),
                        +       value    = col_double(),
                        +       m_flag   = col_character(),
                        +       q_flag   = col_character(),
                        +       s_flag   = col_character(),
                        +       obs_time = col_character()
                        +     ),
                      +     na = c("", "-9999")
                      + )
> weather <- weather |> left_join(ut_stations |> select(id, name))
Error: object 'ut_stations' not found

> ut_stations <- read_csv(here::here("slides/data/ut_stations.csv")) |>
  +   mutate(id = gsub("GHCND:", "", id), 
             +          years = round((maxdate-mindate)/365)) |>
  +   mutate(
    +     file = sprintf("https://www.ncei.noaa.gov/pub/data/ghcn/daily/by_station/%s.csv.gz", id)
    +   )
Rows: 986 Columns: 7
── Column specification ────────────────────────────────────────────────────────────
Delimiter: ","
chr  (2): id, name
dbl  (3): lat, lon, elevation
date (2): maxdate, mindate

ℹ Use `spec()` to retrieve the full column specification for this data.
ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
> ut_stations |>
  +   filter(years > 30 ) |>
  +   leaflet() |> 
  +   addProviderTiles("OpenStreetMap") |>
  +   addCircleMarkers(lng = ~lon, lat=~lat, 
                       +                    label = ~paste(name, id, 
                                                           +                                   years, 
                                                           +                                   sep=" | "),
                       +                    layerId = ~file,
                       +                    radius = 5) |>
  +   onRender("
+     function(el, x) {
+       this.eachLayer(function(layer) {
+         if (layer instanceof L.CircleMarker) {
+           layer.on('click', function(e) {
+             var url = layer.options.layerId;
+ 
+             var a = document.createElement('a');
+             a.href = url;
+             a.download = '';
+             document.body.appendChild(a);
+             a.click();
+             document.body.removeChild(a);
+           });
+         }
+       });
+     }
+   ")
> weather <- weather |> left_join(ut_stations |> select(id, name))
Joining with `by = join_by(id)`
> ww <- weather |> select(id, name, date, element, value) |>
  +   filter(element %in% c("TMIN", "TMAX", "PRCP", "SNOW", "SNWD")) |>
  +   pivot_wider(names_from="element", values_from="value") 
> # assume that missing values in precipitation are 0s:
  > ww <- ww |> mutate(
    +   PRCP = ifelse(is.na(PRCP), 0, PRCP),
    +   SNOW = ifelse(is.na(SNOW), 0, SNOW),
    +   SNWD = ifelse(is.na(SNWD), 0, SNWD)
    + )
> ww_long <- ww |> pivot_longer(cols=TMAX:SNWD, names_to = "element", 
                                +                               values_to = "value")
> gg <- ww_long |> 
  +   filter(element == "PRCP") |>
  +   mutate(year = year(date)) |>
  +   ggplot(aes(x = year, y = value/254)) + 
  +   geom_point(aes(label = date)) +
  +   facet_wrap(~month(date, label=TRUE)) +
  +   geom_smooth(method="lm", aes(group = name)) + 
  +   theme(legend.position = "bottom") + 
  +   ggtitle("Daily Precipitation") + ylab("Precipitation (in inch)")
Warning in geom_point(aes(label = date)) :
  Ignoring unknown aesthetics: label

> 
  > ggplotly(gg, height = 540, width = 1000)
Error in `combine_vars()`:
  ! Faceting variables must have at least one value.
Run `rlang::last_trace()` to see where the error occurred.

> gg
Error in `combine_vars()`:
  ! Faceting variables must have at least one value.
Run `rlang::last_trace()` to see where the error occurred.

> rlang::last_trace()
<error/rlang_error>
  Error in `combine_vars()`:
  ! Faceting variables must have at least one value.
---
  Backtrace:
  ▆
1. ├─base (local) `<fn>`(x)
2. └─ggplot2 (local) `print.ggplot2::ggplot`(x)
3.   ├─ggplot2::ggplot_build(x)
4.   └─ggplot2 (local) `ggplot_build.ggplot2::ggplot`(x)
5.     └─layout$setup(data, plot@data, plot@plot_env)
6.       └─ggplot2 (local) setup(..., self = self)
7.         └─self$facet$compute_layout(data, self$facet_params)
8.           └─ggplot2 (local) compute_layout(..., self = self)
9.             └─ggplot2::combine_vars(data, params$plot_env, vars, drop = params$drop)
Run rlang::last_trace(drop = FALSE) to see 2 hidden frames.
> ww |> View()
> # assume that missing values in precipitation are 0s:
  > ww <- ww |> mutate(
    +   PRCP = ifelse(is.na(PRCP), 0, PRCP),
    +   SNOW = ifelse(is.na(SNOW), 0, SNOW),
    +   SNWD = ifelse(is.na(SNWD), 0, SNWD)
    + )
> ww_long <- ww |> pivot_longer(cols=TMAX:SNWD, names_to = "element", 
                                +                               values_to = "value")
> ww_long
# A tibble: 53,008 × 8
id          name                           date        PRCP  SNOW  TMIN element value
<chr>       <chr>                          <date>     <dbl> <dbl> <dbl> <chr>   <dbl>
  1 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-01     0     0    NA TMAX       NA
2 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-01     0     0    NA SNWD        0
3 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-02     0     0    NA TMAX       NA
4 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-02     0     0    NA SNWD        0
5 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-03     0     0    NA TMAX       NA
6 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-03     0     0    NA SNWD        0
7 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-04     8     0    NA TMAX       NA
8 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-04     8     0    NA SNWD        0
9 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-05     3     0    NA TMAX       NA
10 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-05     3     0    NA SNWD        0
# ℹ 52,998 more rows
# ℹ Use `print(n = ...)` to see more rows
> ww_long |> 
  +     filter(element == "PRCP") |>
  +     mutate(year = year(date)) |>
  +     ggplot(aes(x = year, y = value/254)) + 
  +     geom_point(aes(label = date))
Warning in geom_point(aes(label = date)) :
  Ignoring unknown aesthetics: label

> ww_long |> 
  +     filter(element == "PRCP") |>
  +     mutate(year = year(date)) |> View()
> ww_long |> summary()
id               name            date                 PRCP        
Length   :53008   Length   :53008   Min.   :1915-12-01   Min.   :  0.000  
N.unique :    1   N.unique :    1   1st Qu.:1970-08-05   1st Qu.:  0.000  
N.blank  :    0   N.blank  :    0   Median :1989-02-24   Median :  0.000  
Min.nchar:   11   Min.nchar:   30   Mean   :1986-06-01   Mean   :  5.781  
Max.nchar:   11   Max.nchar:   30   3rd Qu.:2007-07-25   3rd Qu.:  0.000  
Max.   :2026-09-27   Max.   :518.000  

SNOW              TMIN               element          value       
Min.   :  0.000   Min.   :-400.000   Length   :53008   Min.   :-228.0  
1st Qu.:  0.000   1st Qu.: -67.000   N.unique :    2   1st Qu.:   0.0  
Median :  0.000   Median :  11.000   N.blank  :    0   Median :   0.0  
Mean   :  1.243   Mean   :   2.681   Min.nchar:    4   Mean   :  97.8  
3rd Qu.:  0.000   3rd Qu.:  89.000   Max.nchar:    4   3rd Qu.: 200.0  
Max.   :267.000   Max.   : 372.000                     Max.   : 584.0  
NAs    :2174                         NAs    :1263    
> ww |> summary()
id               name            date                 PRCP        
Length   :26504   Length   :26504   Min.   :1915-12-01   Min.   :  0.000  
N.unique :    1   N.unique :    1   1st Qu.:1970-08-05   1st Qu.:  0.000  
N.blank  :    0   N.blank  :    0   Median :1989-02-24   Median :  0.000  
Min.nchar:   11   Min.nchar:   30   Mean   :1986-06-01   Mean   :  5.781  
Max.nchar:   11   Max.nchar:   30   3rd Qu.:2007-07-25   3rd Qu.:  0.000  
Max.   :2026-09-27   Max.   :518.000  

SNOW              SNWD             TMAX             TMIN         
Min.   :  0.000   Min.   :  0.00   Min.   :-228.0   Min.   :-400.000  
1st Qu.:  0.000   1st Qu.:  0.00   1st Qu.:  72.0   1st Qu.: -67.000  
Median :  0.000   Median :  0.00   Median : 189.0   Median :  11.000  
Mean   :  1.243   Mean   : 19.32   Mean   : 180.2   Mean   :   2.681  
3rd Qu.:  0.000   3rd Qu.:  0.00   3rd Qu.: 300.0   3rd Qu.:  89.000  
Max.   :267.000   Max.   :584.00   Max.   : 433.0   Max.   : 372.000  
NAs    :1263     NAs    :1087      
> ww_long <- ww |> pivot_longer(cols=PRCP:SNWD, names_to = "element", 
                                +                               values_to = "value")
> gg <- ww_long |> 
  +   filter(element == "PRCP") |>
  +   mutate(year = year(date)) |>
  +   ggplot(aes(x = year, y = value/254)) + 
  +   geom_point(aes(label = date)) +
  +   facet_wrap(~month(date, label=TRUE)) +
  +   geom_smooth(method="lm", aes(group = name)) + 
  +   theme(legend.position = "bottom") + 
  +   ggtitle("Daily Precipitation") + ylab("Precipitation (in inch)")
Warning in geom_point(aes(label = date)) :
  Ignoring unknown aesthetics: label

> ggplotly(gg, height = 540, width = 1000)
`geom_smooth()` using formula = 'y ~ x'
> #| echo: false
  > #| message: false
  > #| warning: false
  > knitr::opts_chunk$set(
    +   message = FALSE,
    +   warning = FALSE,
    +   error = FALSE, 
    +   collapse = TRUE,
    +   comment = "",
    +   fig.height = 5,
    +   fig.width = 8,
    +   fig.align = "center",
    +   cache = FALSE,
    +   echo=FALSE
    + )
> library(leaflet)
> library(leaflet.providers)
> library(readr)
> library(tidyverse)
> library(htmlwidgets)
> library(plotly)
> ut_stations <- read_csv(here::here("slides/data/ut_stations.csv")) |>
  +   mutate(id = gsub("GHCND:", "", id), 
             +          years = round((maxdate-mindate)/365)) |>
  +   mutate(
    +     file = sprintf("https://www.ncei.noaa.gov/pub/data/ghcn/daily/by_station/%s.csv.gz", id)
    +   )
Rows: 986 Columns: 7
── Column specification ────────────────────────────────────────────────────────────
Delimiter: ","
chr  (2): id, name
dbl  (3): lat, lon, elevation
date (2): maxdate, mindate

ℹ Use `spec()` to retrieve the full column specification for this data.
ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
> 
  > ut_stations |>
  +   filter(years > 30 ) |>
  +   leaflet() |> 
  +   addProviderTiles("OpenStreetMap") |>
  +   addCircleMarkers(lng = ~lon, lat=~lat, 
                       +                    label = ~paste(name, id, 
                                                           +                                   years, 
                                                           +                                   sep=" | "),
                       +                    layerId = ~file,
                       +                    radius = 5) |>
  +   onRender("
+     function(el, x) {
+       this.eachLayer(function(layer) {
+         if (layer instanceof L.CircleMarker) {
+           layer.on('click', function(e) {
+             var url = layer.options.layerId;
+ 
+             var a = document.createElement('a');
+             a.href = url;
+             a.download = '';
+             document.body.appendChild(a);
+             a.click();
+             document.body.removeChild(a);
+           });
+         }
+       });
+     }
+   ")
> 
  > #files <- dir("data/stations", pattern="csv.gz",
  > #             full.names = TRUE )
  > files <- here::here("slides/data/stations/roosevelt.csv.gz")
> weather <- read_csv(files,
                      + col_names = c(
                        +       "id", "date", "element", "value",
                        +       "m_flag", "q_flag", "s_flag", "obs_time"
                        +     ),
                      +     col_types = cols(
                        +       id       = col_character(),
                        +       date     = col_date(format = "%Y%m%d"),
                        +       element  = col_character(),
                        +       value    = col_double(),
                        +       m_flag   = col_character(),
                        +       q_flag   = col_character(),
                        +       s_flag   = col_character(),
                        +       obs_time = col_character()
                        +     ),
                      +     na = c("", "-9999")
                      + )
> 
  > weather <- weather |> left_join(ut_stations |> select(id, name))
Joining with `by = join_by(id)`
> # make the data wide to get an overview of which data is included
  > 
  > ww <- weather |> select(id, name, date, element, value) |>
  +   filter(element %in% c("TMIN", "TMAX", "PRCP", "SNOW", "SNWD")) |>
  +   pivot_wider(names_from="element", values_from="value") 
>   
  > # assume that missing values in precipitation are 0s:
  > ww <- ww |> mutate(
    +   PRCP = ifelse(is.na(PRCP), 0, PRCP),
    +   SNOW = ifelse(is.na(SNOW), 0, SNOW),
    +   SNWD = ifelse(is.na(SNWD), 0, SNWD)
    + )
> 
  > ww_long <- ww |> pivot_longer(cols=PRCP:SNWD, names_to = "element", 
                                  +                               values_to = "value")
> gg <- ww_long |> 
  +   filter(element == "PRCP") |>
  +   mutate(year = year(date)) |>
  +   ggplot(aes(x = year, y = value/254)) + 
  +   geom_point(aes(label = date)) +
  +   facet_wrap(~month(date, label=TRUE)) +
  +   geom_smooth(method="lm", aes(group = name)) + 
  +   theme(legend.position = "bottom") + 
  +   ggtitle("Daily Precipitation") + ylab("Precipitation (in inch)")
Warning in geom_point(aes(label = date)) :
  Ignoring unknown aesthetics: label

> 
  > ggplotly(gg, height = 540, width = 1000)
`geom_smooth()` using formula = 'y ~ x'
> prcp <- ww_long |> filter(element == "PRCP") |> mutate(
  +   year = year(date),
  +   month = month(date, label=TRUE)
  + ) |> group_by(id, name, year, element) |>
  +   summarize(
    +     n = sum(!is.na(value)),
    +     prcp_day = sum(value > 0, na.rm=TRUE),
    +     extreme = sum(value > 254, na.rm=TRUE),
    +     value = sum(value, na.rm=TRUE)/n*365,
    +     .groups = "drop_last"
    +   )
> prcp |> ggplot(aes(x = year, weight = value/254)) + geom_bar() + ggtitle("Amount of total precipitation by year") + ylab("sum(value)") + ylab("Precipitation [inch]")
> prcp |> ggplot(aes(x = year, weight = value/254)) + geom_bar(fill="grey") + ggtitle("Amount of total precipitation by year") + ylab("sum(value)") + 
  +   geom_point(aes(x = year, y = value/254)) +
  +   geom_smooth(aes(x = year, y = value/254), method="lm") + ylab("Precipitation [inch]")
> 
  > model <- lm(value/254 ~ year, data = prcp)
> prcp |> ggplot(aes(x = year, weight = value/254)) + geom_bar(fill="grey") + ggtitle("Amount of total precipitation by year") + ylab("sum(value)") + 
  +   geom_point(aes(x = year, y = value/254)) +
  +   geom_smooth(aes(x = year, y = value/254), method="lm") + ylab("Precipitation [inch]")
> 
  > model <- lm(value/254 ~ I(year-1905), data = prcp)
> summary(model)

Call:
  lm(formula = value/254 ~ I(year - 1905), data = prcp)

Residuals:
  Min      1Q  Median      3Q     Max 
-4.4624 -1.5869  0.2502  1.8144  5.6551 

Coefficients:
  Estimate Std. Error t value Pr(>|t|)    
(Intercept)     8.412605   0.730374  11.518   <2e-16 ***
  I(year - 1905) -0.002454   0.008739  -0.281     0.78    
---
  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 2.367 on 77 degrees of freedom
Multiple R-squared:  0.001023,	Adjusted R-squared:  -0.01195 
F-statistic: 0.07885 on 1 and 77 DF,  p-value: 0.7796

> temps <- ww_long |> mutate(
  +   year = year(date),
  +   month = month(date, label=TRUE)
  + ) |> group_by(id, name, year, month, element) |>
  +   summarize(
    +     n = sum(!is.na(value)),
    +     value = (mean(value, na.rm=TRUE)/10 + 32)*9/5,
    +     .groups = "drop_last"
    +   )
> temps |> 
  +     filter(element %in% c("TMIN", "TMAX"), n > 10) |>
  +     ggplot(aes(x = year, y = value)) + 
  +     geom_point(aes(colour = element)) +
  +     facet_wrap(~month) +
  +     geom_smooth(method="lm", aes(group = element), colour="grey20") + 
  +     theme(legend.position = "bottom") + 
  +     ggtitle("Monthly Averages of \nDaily Minimum and Maximum Temperatures") + 
  +   ylab("Degree F")
Error in `combine_vars()`:
  ! Faceting variables must have at least one value.
Run `rlang::last_trace()` to see where the error occurred.

> temps |> 
  +     filter(element %in% c("TMIN", "TMAX"), n > 10) |>
  +     ggplot(aes(x = year, y = value)) + 
  +     geom_point(aes(colour = element)) 
> temps |> count(element)
# A tibble: 2,628 × 6
# Groups:   id, name, year, month [876]
id          name                            year month element     n
<chr>       <chr>                          <dbl> <ord> <chr>   <int>
  1 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1915 Dec   PRCP        1
2 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1915 Dec   SNOW        1
3 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1915 Dec   SNWD        1
4 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Jan   PRCP        1
5 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Jan   SNOW        1
6 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Jan   SNWD        1
7 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Feb   PRCP        1
8 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Feb   SNOW        1
9 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Feb   SNWD        1
10 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Mar   PRCP        1
# ℹ 2,618 more rows
# ℹ Use `print(n = ...)` to see more rows
> ww |> summary()
id               name            date                 PRCP        
Length   :26504   Length   :26504   Min.   :1915-12-01   Min.   :  0.000  
N.unique :    1   N.unique :    1   1st Qu.:1970-08-05   1st Qu.:  0.000  
N.blank  :    0   N.blank  :    0   Median :1989-02-24   Median :  0.000  
Min.nchar:   11   Min.nchar:   30   Mean   :1986-06-01   Mean   :  5.781  
Max.nchar:   11   Max.nchar:   30   3rd Qu.:2007-07-25   3rd Qu.:  0.000  
Max.   :2026-09-27   Max.   :518.000  

SNOW              SNWD             TMAX             TMIN         
Min.   :  0.000   Min.   :  0.00   Min.   :-228.0   Min.   :-400.000  
1st Qu.:  0.000   1st Qu.:  0.00   1st Qu.:  72.0   1st Qu.: -67.000  
Median :  0.000   Median :  0.00   Median : 189.0   Median :  11.000  
Mean   :  1.243   Mean   : 19.32   Mean   : 180.2   Mean   :   2.681  
3rd Qu.:  0.000   3rd Qu.:  0.00   3rd Qu.: 300.0   3rd Qu.:  89.000  
Max.   :267.000   Max.   :584.00   Max.   : 433.0   Max.   : 372.000  
NAs    :1263     NAs    :1087      
> temps <- ww_long |> mutate(
  +   year = year(date),
  +   month = month(date, label=TRUE)
  + ) |> group_by(id, name, year, month, element) |>
  +   summarize(
    +     n = sum(!is.na(value)),
    +     value = (mean(value, na.rm=TRUE)/10 + 32)*9/5,
    +     .groups = "drop_last"
    +   )
> summary(temps)
id              name           year          month           element    
Length   :2628   Length   :2628   Min.   :1915   Jan    : 222   Length   :2628  
N.unique :   1   N.unique :   1   1st Qu.:1970   Feb    : 222   N.unique :   3  
N.blank  :   0   N.blank  :   0   Median :1989   Mar    : 222   N.blank  :   0  
Min.nchar:  11   Min.nchar:  30   Mean   :1986   Jul    : 222   Min.nchar:   4  
Max.nchar:  11   Max.nchar:  30   3rd Qu.:2007   Aug    : 222   Max.nchar:   4  
Max.   :2026   Apr    : 219                   
(Other):1299                   
n             value       
Min.   : 4.00   Min.   : 57.60  
1st Qu.:30.00   1st Qu.: 57.60  
Median :31.00   Median : 57.60  
Mean   :30.26   Mean   : 59.20  
3rd Qu.:31.00   3rd Qu.: 58.46  
Max.   :31.00   Max.   :140.05  

> temps |> count(element)
# A tibble: 2,628 × 6
# Groups:   id, name, year, month [876]
id          name                            year month element     n
<chr>       <chr>                          <dbl> <ord> <chr>   <int>
  1 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1915 Dec   PRCP        1
2 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1915 Dec   SNOW        1
3 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1915 Dec   SNWD        1
4 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Jan   PRCP        1
5 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Jan   SNOW        1
6 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Jan   SNWD        1
7 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Feb   PRCP        1
8 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Feb   SNOW        1
9 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Feb   SNWD        1
10 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Mar   PRCP        1
# ℹ 2,618 more rows
# ℹ Use `print(n = ...)` to see more rows
> temps |> ungroup() |> count(element)
# A tibble: 3 × 2
element     n
<chr>   <int>
  1 PRCP      876
2 SNOW      876
3 SNWD      876
> temps <- ww_long |> mutate(
  +   year = year(date),
  +   month = month(date, label=TRUE)
  + ) |> ungroup() |> group_by(id, name, year, month, element) |>
  +   summarize(
    +     n = sum(!is.na(value)),
    +     value = (mean(value, na.rm=TRUE)/10 + 32)*9/5,
    +     .groups = "drop_last"
    +   )
> temps |> 
  +     filter(element %in% c("TMIN", "TMAX"), n > 10) |>
  +     ggplot(aes(x = year, y = value)) + 
  +     geom_point(aes(colour = element)) +
  +     facet_wrap(~month) +
  +     geom_smooth(method="lm", aes(group = element), colour="grey20") + 
  +     theme(legend.position = "bottom") + 
  +     ggtitle("Monthly Averages of \nDaily Minimum and Maximum Temperatures") + 
  +   ylab("Degree F")
Error in `combine_vars()`:
  ! Faceting variables must have at least one value.
Run `rlang::last_trace()` to see where the error occurred.

> temps
# A tibble: 2,628 × 7
# Groups:   id, name, year, month [876]
id          name                            year month element     n value
<chr>       <chr>                          <dbl> <ord> <chr>   <int> <dbl>
  1 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1915 Dec   PRCP       31  58.6
2 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1915 Dec   SNOW       31  58.9
3 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1915 Dec   SNWD       31  63.9
4 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Jan   PRCP       31  61.3
5 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Jan   SNOW       31  62.0
6 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Jan   SNWD       31 116. 
7 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Feb   PRCP       29  58.8
8 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Feb   SNOW       29  59.1
9 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Feb   SNWD       29 140. 
10 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Mar   PRCP       31  59.3
# ℹ 2,618 more rows
# ℹ Use `print(n = ...)` to see more rows
> temps |> count(element)
# A tibble: 2,628 × 6
# Groups:   id, name, year, month [876]
id          name                            year month element     n
<chr>       <chr>                          <dbl> <ord> <chr>   <int>
  1 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1915 Dec   PRCP        1
2 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1915 Dec   SNOW        1
3 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1915 Dec   SNWD        1
4 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Jan   PRCP        1
5 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Jan   SNOW        1
6 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Jan   SNWD        1
7 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Feb   PRCP        1
8 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Feb   SNOW        1
9 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Feb   SNWD        1
10 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Mar   PRCP        1
# ℹ 2,618 more rows
# ℹ Use `print(n = ...)` to see more rows
> ww_long
# A tibble: 79,512 × 7
id          name                           date        TMAX  TMIN element value
<chr>       <chr>                          <date>     <dbl> <dbl> <chr>   <dbl>
  1 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-01    NA    NA PRCP        0
2 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-01    NA    NA SNOW        0
3 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-01    NA    NA SNWD        0
4 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-02    NA    NA PRCP        0
5 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-02    NA    NA SNOW        0
6 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-02    NA    NA SNWD        0
7 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-03    NA    NA PRCP        0
8 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-03    NA    NA SNOW        0
9 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-03    NA    NA SNWD        0
10 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-04    NA    NA PRCP        8
# ℹ 79,502 more rows
# ℹ Use `print(n = ...)` to see more rows
> temps |> filter(element =="TMAX")
# A tibble: 0 × 7
# Groups:   id, name, year, month [0]
# ℹ 7 variables: id <chr>, name <chr>, year <dbl>, month <ord>, element <chr>, n <int>,
#   value <dbl>
> ww
# A tibble: 26,504 × 8
id          name                           date        PRCP  SNOW  SNWD  TMAX  TMIN
<chr>       <chr>                          <date>     <dbl> <dbl> <dbl> <dbl> <dbl>
  1 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-01     0     0     0    NA    NA
2 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-02     0     0     0    NA    NA
3 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-03     0     0     0    NA    NA
4 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-04     8     0     0    NA    NA
5 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-05     3     0     0    NA    NA
6 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-06     0     0     0    NA    NA
7 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-07     0     0     0    NA    NA
8 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-08     0     0     0    NA    NA
9 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-09     0     0     0    NA    NA
10 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-10     0     0     0    NA    NA
# ℹ 26,494 more rows
# ℹ Use `print(n = ...)` to see more rows
> summary(ww)
id               name            date                 PRCP        
Length   :26504   Length   :26504   Min.   :1915-12-01   Min.   :  0.000  
N.unique :    1   N.unique :    1   1st Qu.:1970-08-05   1st Qu.:  0.000  
N.blank  :    0   N.blank  :    0   Median :1989-02-24   Median :  0.000  
Min.nchar:   11   Min.nchar:   30   Mean   :1986-06-01   Mean   :  5.781  
Max.nchar:   11   Max.nchar:   30   3rd Qu.:2007-07-25   3rd Qu.:  0.000  
Max.   :2026-09-27   Max.   :518.000  

SNOW              SNWD             TMAX             TMIN         
Min.   :  0.000   Min.   :  0.00   Min.   :-228.0   Min.   :-400.000  
1st Qu.:  0.000   1st Qu.:  0.00   1st Qu.:  72.0   1st Qu.: -67.000  
Median :  0.000   Median :  0.00   Median : 189.0   Median :  11.000  
Mean   :  1.243   Mean   : 19.32   Mean   : 180.2   Mean   :   2.681  
3rd Qu.:  0.000   3rd Qu.:  0.00   3rd Qu.: 300.0   3rd Qu.:  89.000  
Max.   :267.000   Max.   :584.00   Max.   : 433.0   Max.   : 372.000  
NAs    :1263     NAs    :1087      
> ww |> ggplot(aes(x = date, y = TMAX)) + geom_point()
Warning: Removed 1263 rows containing missing values or values outside the scale range
(`geom_point()`).

> temps <- ww_long |> filter(element %in% c("TMIN", "TMAX")) |> mutate(
  +   year = year(date),
  +   month = month(date, label=TRUE)
  + ) |> ungroup() |> group_by(id, name, year, month, element) |>
  +   summarize(
    +     n = sum(!is.na(value)),
    +     value = (mean(value, na.rm=TRUE)/10 + 32)*9/5,
    +     .groups = "drop_last"
    +   )
> temps
# A tibble: 0 × 7
# Groups:   id, name, year, month [0]
# ℹ 7 variables: id <chr>, name <chr>, year <dbl>, month <ord>, element <chr>, n <int>,
#   value <dbl>
> temps <- ww_long |> filter(element %in% c("TMIN", "TMAX"))
> temps
# A tibble: 0 × 7
# ℹ 7 variables: id <chr>, name <chr>, date <date>, TMAX <dbl>, TMIN <dbl>,
#   element <chr>, value <dbl>
> temps$date
Date of length 0
> ww_long |> filter(element %in% c("TMIN", "TMAX"))
> ww_long
# A tibble: 79,512 × 7
id          name                           date        TMAX  TMIN element value
<chr>       <chr>                          <date>     <dbl> <dbl> <chr>   <dbl>
  1 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-01    NA    NA PRCP        0
2 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-01    NA    NA SNOW        0
3 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-01    NA    NA SNWD        0
4 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-02    NA    NA PRCP        0
5 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-02    NA    NA SNOW        0
6 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-02    NA    NA SNWD        0
7 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-03    NA    NA PRCP        0
8 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-03    NA    NA SNOW        0
9 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-03    NA    NA SNWD        0
10 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-04    NA    NA PRCP        8
# ℹ 79,502 more rows
# ℹ Use `print(n = ...)` to see more rows
> temps <- ww_long |> filter(element %in% c("TMIN", "TMAX")) |> mutate(
  +   year = year(date),
  +   month = month(date, label=TRUE)
  + ) 
> temps
# A tibble: 0 × 9
# ℹ 9 variables: id <chr>, name <chr>, date <date>, TMAX <dbl>, TMIN <dbl>,
#   element <chr>, value <dbl>, year <dbl>, month <ord>
> #| echo: false
  > #| message: false
  > #| warning: false
  > knitr::opts_chunk$set(
    +   message = FALSE,
    +   warning = FALSE,
    +   error = FALSE, 
    +   collapse = TRUE,
    +   comment = "",
    +   fig.height = 5,
    +   fig.width = 8,
    +   fig.align = "center",
    +   cache = FALSE,
    +   echo=FALSE
    + )
> library(leaflet)
> library(leaflet.providers)
> library(readr)
> library(tidyverse)
> library(htmlwidgets)
> library(plotly)
> ut_stations <- read_csv(here::here("slides/data/ut_stations.csv")) |>
  +   mutate(id = gsub("GHCND:", "", id), 
             +          years = round((maxdate-mindate)/365)) |>
  +   mutate(
    +     file = sprintf("https://www.ncei.noaa.gov/pub/data/ghcn/daily/by_station/%s.csv.gz", id)
    +   )
Rows: 986 Columns: 7
── Column specification ────────────────────────────────────────────────────────────
Delimiter: ","
chr  (2): id, name
dbl  (3): lat, lon, elevation
date (2): maxdate, mindate

ℹ Use `spec()` to retrieve the full column specification for this data.
ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
> 
  > ut_stations |>
  +   filter(years > 30 ) |>
  +   leaflet() |> 
  +   addProviderTiles("OpenStreetMap") |>
  +   addCircleMarkers(lng = ~lon, lat=~lat, 
                       +                    label = ~paste(name, id, 
                                                           +                                   years, 
                                                           +                                   sep=" | "),
                       +                    layerId = ~file,
                       +                    radius = 5) |>
  +   onRender("
+     function(el, x) {
+       this.eachLayer(function(layer) {
+         if (layer instanceof L.CircleMarker) {
+           layer.on('click', function(e) {
+             var url = layer.options.layerId;
+ 
+             var a = document.createElement('a');
+             a.href = url;
+             a.download = '';
+             document.body.appendChild(a);
+             a.click();
+             document.body.removeChild(a);
+           });
+         }
+       });
+     }
+   ")
> 
  > #files <- dir("data/stations", pattern="csv.gz",
  > #             full.names = TRUE )
  > files <- here::here("slides/data/stations/roosevelt.csv.gz")
> weather <- read_csv(files,
                      + col_names = c(
                        +       "id", "date", "element", "value",
                        +       "m_flag", "q_flag", "s_flag", "obs_time"
                        +     ),
                      +     col_types = cols(
                        +       id       = col_character(),
                        +       date     = col_date(format = "%Y%m%d"),
                        +       element  = col_character(),
                        +       value    = col_double(),
                        +       m_flag   = col_character(),
                        +       q_flag   = col_character(),
                        +       s_flag   = col_character(),
                        +       obs_time = col_character()
                        +     ),
                      +     na = c("", "-9999")
                      + )
> 
  > weather <- weather |> left_join(ut_stations |> select(id, name))
Joining with `by = join_by(id)`
> # make the data wide to get an overview of which data is included
  > 
  > ww <- weather |> select(id, name, date, element, value) |>
  +   filter(element %in% c("TMIN", "TMAX", "PRCP", "SNOW", "SNWD")) |>
  +   pivot_wider(names_from="element", values_from="value") 
>   
  > # assume that missing values in precipitation are 0s:
  > ww <- ww |> mutate(
    +   PRCP = ifelse(is.na(PRCP), 0, PRCP),
    +   SNOW = ifelse(is.na(SNOW), 0, SNOW),
    +   SNWD = ifelse(is.na(SNWD), 0, SNWD)
    + )
> 
  > ww_long <- ww |> pivot_longer(cols=PRCP:SNWD, names_to = "element", 
                                  +                               values_to = "value")
> gg <- ww_long |> 
  +   filter(element == "PRCP") |>
  +   mutate(year = year(date)) |>
  +   ggplot(aes(x = year, y = value/254)) + 
  +   geom_point(aes(label = date)) +
  +   facet_wrap(~month(date, label=TRUE)) +
  +   geom_smooth(method="lm", aes(group = name)) + 
  +   theme(legend.position = "bottom") + 
  +   ggtitle("Daily Precipitation") + ylab("Precipitation (in inch)")
Warning in geom_point(aes(label = date)) :
  Ignoring unknown aesthetics: label

> 
  > ggplotly(gg, height = 540, width = 1000)
`geom_smooth()` using formula = 'y ~ x'
> prcp <- ww_long |> filter(element == "PRCP") |> mutate(
  +   year = year(date),
  +   month = month(date, label=TRUE)
  + ) |> group_by(id, name, year, element) |>
  +   summarize(
    +     n = sum(!is.na(value)),
    +     prcp_day = sum(value > 0, na.rm=TRUE),
    +     extreme = sum(value > 254, na.rm=TRUE),
    +     value = sum(value, na.rm=TRUE)/n*365,
    +     .groups = "drop_last"
    +   )
> prcp |> ggplot(aes(x = year, weight = value/254)) + geom_bar() + ggtitle("Amount of total precipitation by year") + ylab("sum(value)") + ylab("Precipitation [inch]")
> prcp |> ggplot(aes(x = year, weight = value/254)) + geom_bar(fill="grey") + ggtitle("Amount of total precipitation by year") + ylab("sum(value)") + 
  +   geom_point(aes(x = year, y = value/254)) +
  +   geom_smooth(aes(x = year, y = value/254), method="lm") + ylab("Precipitation [inch]")
> 
  > model <- lm(value/254 ~ year, data = prcp)
> prcp |> ggplot(aes(x = year, weight = value/254)) + geom_bar(fill="grey") + ggtitle("Amount of total precipitation by year") + ylab("sum(value)") + 
  +   geom_point(aes(x = year, y = value/254)) +
  +   geom_smooth(aes(x = year, y = value/254), method="lm") + ylab("Precipitation [inch]")
> 
  > model <- lm(value/254 ~ I(year-1905), data = prcp)
> summary(model)

Call:
  lm(formula = value/254 ~ I(year - 1905), data = prcp)

Residuals:
  Min      1Q  Median      3Q     Max 
-4.4624 -1.5869  0.2502  1.8144  5.6551 

Coefficients:
  Estimate Std. Error t value Pr(>|t|)    
(Intercept)     8.412605   0.730374  11.518   <2e-16 ***
  I(year - 1905) -0.002454   0.008739  -0.281     0.78    
---
  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 2.367 on 77 degrees of freedom
Multiple R-squared:  0.001023,	Adjusted R-squared:  -0.01195 
F-statistic: 0.07885 on 1 and 77 DF,  p-value: 0.7796

> temps <- ww_long |> filter(element %in% c("TMIN", "TMAX")) |> mutate(
  +   year = year(date),
  +   month = month(date, label=TRUE)
  + ) 
> 
  > 
  > temps |> ungroup() |> group_by(id, name, year, month, element) |>
  +   summarize(
    +     n = sum(!is.na(value)),
    +     value = (mean(value, na.rm=TRUE)/10 + 32)*9/5,
    +     .groups = "drop_last"
    +   )
> temps |> 
  +     filter(element %in% c("TMIN", "TMAX"), n > 10) |>
  +     ggplot(aes(x = year, y = value)) + 
  +     geom_point(aes(colour = element)) +
  +     facet_wrap(~month) +
  +     geom_smooth(method="lm", aes(group = element), colour="grey20") + 
  +     theme(legend.position = "bottom") + 
  +     ggtitle("Monthly Averages of \nDaily Minimum and Maximum Temperatures") + 
  +   ylab("Degree F")
Error in `filter()`:
  ℹ In argument: `n > 10`.
Caused by error in `n > 10`:
  ! comparison (>) is possible only for atomic and list types
Run `rlang::last_trace()` to see where the error occurred.

> temps
# A tibble: 0 × 9
# ℹ 9 variables: id <chr>, name <chr>, date <date>, TMAX <dbl>, TMIN <dbl>,
#   element <chr>, value <dbl>, year <dbl>, month <ord>
> temps <- ww_long |> filter(element %in% c("TMIN", "TMAX")) |> mutate(
  +   year = year(date),
  +   month = month(date, label=TRUE)
  + ) 
> temps
# A tibble: 0 × 9
# ℹ 9 variables: id <chr>, name <chr>, date <date>, TMAX <dbl>, TMIN <dbl>,
#   element <chr>, value <dbl>, year <dbl>, month <ord>
> ww_long |> count(element)
# A tibble: 3 × 2
element     n
<chr>   <int>
  1 PRCP    26504
2 SNOW    26504
3 SNWD    26504
> ww <- weather |> select(id, name, date, element, value) |>
  +   filter(element %in% c("TMIN", "TMAX", "PRCP", "SNOW", "SNWD")) |>
  +   pivot_wider(names_from="element", values_from="value") 
> # assume that missing values in precipitation are 0s:
  > ww <- ww |> mutate(
    +   PRCP = ifelse(is.na(PRCP), 0, PRCP),
    +   SNOW = ifelse(is.na(SNOW), 0, SNOW),
    +   SNWD = ifelse(is.na(SNWD), 0, SNWD)
    + )
> names(ww)
[1] "id"   "name" "date" "PRCP" "SNOW" "SNWD" "TMAX" "TMIN"
> ww_long <- ww |> pivot_longer(cols=-(1:3), names_to = "element", 
                                +                               values_to = "value")
> temps <- ww_long |> filter(element %in% c("TMIN", "TMAX")) |> mutate(
  +   year = year(date),
  +   month = month(date, label=TRUE)
  + ) 
> temps
# A tibble: 53,008 × 7
id          name                           date       element value  year month
<chr>       <chr>                          <date>     <chr>   <dbl> <dbl> <ord>
  1 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-01 TMAX       NA  1915 Dec  
2 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-01 TMIN       NA  1915 Dec  
3 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-02 TMAX       NA  1915 Dec  
4 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-02 TMIN       NA  1915 Dec  
5 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-03 TMAX       NA  1915 Dec  
6 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-03 TMIN       NA  1915 Dec  
7 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-04 TMAX       NA  1915 Dec  
8 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-04 TMIN       NA  1915 Dec  
9 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-05 TMAX       NA  1915 Dec  
10 USC00422173 DINOSAUR NM QUARRY AREA, UT US 1915-12-05 TMIN       NA  1915 Dec  
# ℹ 52,998 more rows
# ℹ Use `print(n = ...)` to see more rows
> temps <- ww_long |> filter(element %in% c("TMIN", "TMAX")) |> mutate(
  +   year = year(date),
  +   month = month(date, label=TRUE)
  + )  |> ungroup() |> group_by(id, name, year, month, element) |>
  +   summarize(
    +     n = sum(!is.na(value)),
    +     value = (mean(value, na.rm=TRUE)/10 + 32)*9/5,
    +     .groups = "drop_last"
    +   )
> temps
# A tibble: 1,752 × 7
# Groups:   id, name, year, month [876]
id          name                            year month element     n value
<chr>       <chr>                          <dbl> <ord> <chr>   <int> <dbl>
  1 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1915 Dec   TMAX        0 NaN  
2 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1915 Dec   TMIN        0 NaN  
3 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Jan   TMAX        0 NaN  
4 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Jan   TMIN        0 NaN  
5 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Feb   TMAX        0 NaN  
6 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Feb   TMIN        0 NaN  
7 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Mar   TMAX       31  77.7
8 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Mar   TMIN       31  43.4
9 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Apr   TMAX        0 NaN  
10 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Apr   TMIN        0 NaN  
# ℹ 1,742 more rows
# ℹ Use `print(n = ...)` to see more rows
> temps |> 
  +     filter(element %in% c("TMIN", "TMAX"), n > 10)
> temps |> 
  +     filter(element %in% c("TMIN", "TMAX"), n > 10) |>
  +     ggplot(aes(x = year, y = value)) + 
  +     geom_point(aes(colour = element)) +
  +     facet_wrap(~month) +
  +     geom_smooth(method="lm", aes(group = element), colour="grey20") + 
  +     theme(legend.position = "bottom") + 
  +     ggtitle("Monthly Averages of \nDaily Minimum and Maximum Temperatures") + 
  +   ylab("Degree F")
> temps |> filter(element == "TMAX") |> arrange(desc(value))
> model_tmax <- lm(value~I(year-1905), data = temps |> filter(element == "TMAX"))
> model_tmin <- lm(value~I(year-1905), data = temps |> filter(element == "TMIN"))
> summary(model_tmax)

Call:
  lm(formula = value ~ I(year - 1905), data = filter(temps, element == 
                                                       "TMAX"))

Residuals:
  Min      1Q  Median      3Q     Max 
-51.359 -19.007   1.149  20.202  39.334 

Coefficients:
  Estimate Std. Error t value Pr(>|t|)    
(Intercept)    86.31222    2.55648  33.762   <2e-16 ***
  I(year - 1905)  0.04303    0.02964   1.452    0.147    
---
  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 22.54 on 857 degrees of freedom
(17 observations deleted due to missingness)
Multiple R-squared:  0.002454,	Adjusted R-squared:  0.00129 
F-statistic: 2.108 on 1 and 857 DF,  p-value: 0.1469

> summary(model_tmax)

Call:
  lm(formula = value ~ I(year - 1905), data = filter(temps, element == 
                                                       "TMAX"))

Residuals:
  Min      1Q  Median      3Q     Max 
-51.359 -19.007   1.149  20.202  39.334 

Coefficients:
  Estimate Std. Error t value Pr(>|t|)    
(Intercept)    86.31222    2.55648  33.762   <2e-16 ***
  I(year - 1905)  0.04303    0.02964   1.452    0.147    
---
  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 22.54 on 857 degrees of freedom
(17 observations deleted due to missingness)
Multiple R-squared:  0.002454,	Adjusted R-squared:  0.00129 
F-statistic: 2.108 on 1 and 857 DF,  p-value: 0.1469

> summary(model_tmin)

Call:
  lm(formula = value ~ I(year - 1905), data = filter(temps, element == 
                                                       "TMIN"))

Residuals:
  Min      1Q  Median      3Q     Max 
-45.871 -13.014   0.844  15.350  34.485 

Coefficients:
  Estimate Std. Error t value Pr(>|t|)    
(Intercept)    54.44791    1.95690  27.824   <2e-16 ***
  I(year - 1905)  0.04182    0.02276   1.837   0.0665 .  
---
  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 17.69 on 863 degrees of freedom
(11 observations deleted due to missingness)
Multiple R-squared:  0.003896,	Adjusted R-squared:  0.002742 
F-statistic: 3.376 on 1 and 863 DF,  p-value: 0.06651

> ww_long |> filter(!is.na(value))
> ww_long |> filter(!is.na(value)) |>
  +   ggplot(aes(x = date, y = element)) + 
  +   geom_point()
> ww_long |> 
  +     filter(element == "SNWD") |>
  +     mutate(year = year(date)) |>
  +     ggplot(aes(x = year, y = value/254)) + 
  +     geom_point(aes(label = date)) +
  +     facet_wrap(~month(date, label=TRUE)) +
  +     geom_smooth(method="lm", aes(group = name)) + 
  +     theme(legend.position = "bottom") + 
  +     ggtitle("Daily Precipitation") + ylab("Precipitation (in inch)")
Warning in geom_point(aes(label = date)) :
  Ignoring unknown aesthetics: label

`geom_smooth()` using formula = 'y ~ x'
> ww_long |> 
  +     filter(element == "SNOW") |>
  +     mutate(year = year(date)) |>
  +     ggplot(aes(x = year, y = value/254)) + 
  +     geom_point(aes(label = date)) +
  +     facet_wrap(~month(date, label=TRUE)) +
  +     geom_smooth(method="lm", aes(group = name)) + 
  +     theme(legend.position = "bottom") + 
  +     ggtitle("Daily Precipitation") + ylab("Precipitation (in inch)")
Warning in geom_point(aes(label = date)) :
  Ignoring unknown aesthetics: label

`geom_smooth()` using formula = 'y ~ x'
> temps
# A tibble: 1,752 × 7
# Groups:   id, name, year, month [876]
id          name                            year month element     n value
<chr>       <chr>                          <dbl> <ord> <chr>   <int> <dbl>
  1 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1915 Dec   TMAX        0 NaN  
2 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1915 Dec   TMIN        0 NaN  
3 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Jan   TMAX        0 NaN  
4 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Jan   TMIN        0 NaN  
5 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Feb   TMAX        0 NaN  
6 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Feb   TMIN        0 NaN  
7 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Mar   TMAX       31  77.7
8 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Mar   TMIN       31  43.4
9 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Apr   TMAX        0 NaN  
10 USC00422173 DINOSAUR NM QUARRY AREA, UT US  1916 Apr   TMIN        0 NaN  
# ℹ 1,742 more rows
# ℹ Use `print(n = ...)` to see more rows
> snow <- ww_long |> filter(element %in% c("SNOW", "SNWD")) |>
  +   mutate(value = value/254,  # convert to inch
             +   year = year(date),
             +   month = month(date, label=TRUE)) |>
  +   group_by(name, id, year, month, element) |>
  +   summarize(snow_total = sum(SNOW, na.rm = T), 
                +             snow_on_ground = sum(SNWD > 0)/n(),
                +             n = n())
Error in `summarize()`:
  ℹ In argument: `snow_total = sum(SNOW, na.rm = T)`.
ℹ In group 1: `name = "DINOSAUR NM QUARRY AREA, UT US"`, `id = "USC00422173"`,
`year = 1915`, `month = Dec`, `element = "SNOW"`.
Caused by error:
  ! object 'SNOW' not found
Run `rlang::last_trace()` to see where the error occurred.

> snow <- ww_long |> filter(element %in% c("SNOW", "SNWD")) |>
  +   mutate(value = value/254,  # convert to inch
             +   year = year(date),
             +   month = month(date, label=TRUE)) |>
  +   pivot_wider(names_from="element", values_from = "value") |>
  +   group_by(name, id, year, month, element) |>
  +   summarize(snow_total = sum(SNOW, na.rm = T), 
                +             snow_on_ground = sum(SNWD > 0)/n(),
                +             n = n())
Error in `group_by()`:
  ! Must group by variables found in `.data`.
✖ Column `element` is not found.
Run `rlang::last_trace()` to see where the error occurred.

> snow <- ww_long |> filter(element %in% c("SNOW", "SNWD")) |>
  +   mutate(value = value/254,  # convert to inch
             +   year = year(date),
             +   month = month(date, label=TRUE)) |>
  +   pivot_wider(names_from="element", values_from = "value") |>
  +   group_by(name, id, year, month) |>
  +   summarize(snow_total = sum(SNOW, na.rm = T), 
                +             snow_on_ground = sum(SNWD > 0)/n(),
                +             n = n())
`summarise()` has regrouped the output.
ℹ Summaries were computed grouped by name, id, year, and month.
ℹ Output is grouped by name, id, and year.
ℹ Use `summarise(.groups = "drop_last")` to silence this message.
ℹ Use `summarise(.by = c(name, id, year, month))` for per-operation grouping
instead.
> snow |> View()
> snow |> ggplot(aes(x = date, y = snow_total)) + geom_point()
Don't know how to automatically pick scale for object of type <function>. Defaulting to
continuous.
Error in `geom_point()`:
! Problem while computing aesthetics.
ℹ Error occurred in the 1st layer.
Caused by error:
! Aesthetics are not valid data columns.
✖ The following aesthetics are invalid:
• `x = date`
ℹ Did you mistype the name of a data column or forget to add `after_stat()`?
Run `rlang::last_trace()` to see where the error occurred.

> snow |> ggplot(aes(x = year, y = snow_total)) + geom_point()
> snow |> ggplot(aes(x = year, y = snow_total)) + geom_point() + facet_wrap(~month)
> snow |> ggplot(aes(x = year, y = snow_on_ground)) + geom_point() + facet_wrap(~month)
> snow |> ggplot(aes(x = year, y = snow_on_ground)) + geom_point() + facet_wrap(~month) + geom_smooth()
`geom_smooth()` using method = 'loess' and formula = 'y ~ x'
> snow |> ggplot(aes(x = year, y = snow_on_ground)) + geom_point() + facet_wrap(~month) + geom_smooth(method="lm")
`geom_smooth()` using formula = 'y ~ x'
> snow |> filter(month %in% c("Nov", "Dec", "Jan", "Feb", "Mar"))
> winter <- snow |> filter(month %in% c("Nov", "Dec", "Jan", "Feb", "Mar"))
> model_sog <- lm(snow_on_ground~year, data = winter)
> summary(model_sog)

Call:
lm(formula = snow_on_ground ~ year, data = winter)

Residuals:
    Min      1Q  Median      3Q     Max 
-0.3481 -0.2712 -0.2380  0.2689  0.7516 

Coefficients:
              Estimate Std. Error t value Pr(>|t|)
(Intercept)  2.1693489  1.4359313   1.511    0.132
year        -0.0009496  0.0007229  -1.314    0.190

Residual standard error: 0.3788 on 363 degrees of freedom
Multiple R-squared:  0.004731,	Adjusted R-squared:  0.001989 
F-statistic: 1.725 on 1 and 363 DF,  p-value: 0.1898

> model_sog <- lm(snow_on_ground~year*month, data = winter)
> summary(model_sog)

Call:
lm(formula = snow_on_ground ~ year * month, data = winter)

Residuals:
     Min       1Q   Median       3Q      Max 
-0.50056 -0.27935 -0.06388  0.23310  0.69095 

Coefficients:
               Estimate Std. Error t value Pr(>|t|)
(Intercept)   1.787e+00  1.315e+00   1.359    0.175
year         -7.584e-04  6.620e-04  -1.146    0.253
month.L       6.684e-01  2.898e+00   0.231    0.818
month.Q       1.996e-02  2.902e+00   0.007    0.995
month.C       1.251e+00  2.996e+00   0.417    0.677
month^4       5.608e-02  2.965e+00   0.019    0.985
year:month.L -4.410e-04  1.459e-03  -0.302    0.763
year:month.Q  1.136e-04  1.461e-03   0.078    0.938
year:month.C -5.403e-04  1.508e-03  -0.358    0.720
year:month^4 -4.535e-05  1.492e-03  -0.030    0.976

Residual standard error: 0.3449 on 355 degrees of freedom
Multiple R-squared:  0.1931,	Adjusted R-squared:  0.1727 
F-statistic: 9.441 on 9 and 355 DF,  p-value: 6.618e-13

> model_sog <- lm(snow_on_ground~year*as.character(month), data = winter)
> model_sog <- lm(snow_on_ground~I(year-1910)*as.character(month), data = winter)
> summary(model_sog)

Call:
lm(formula = snow_on_ground ~ I(year - 1910) * as.character(month), 
    data = winter)

Residuals:
     Min       1Q   Median       3Q      Max 
-0.50056 -0.27935 -0.06388  0.23310  0.69095 

Coefficients:
                                        Estimate Std. Error t value Pr(>|t|)    
(Intercept)                            0.4208839  0.1185589   3.550 0.000437 ***
I(year - 1910)                        -0.0011529  0.0014705  -0.784 0.433545    
as.character(month)Feb                 0.0625367  0.1644128   0.380 0.703903    
as.character(month)Jan                 0.0817072  0.1644128   0.497 0.619522    
as.character(month)Mar                -0.2306646  0.1681642  -1.372 0.171035    
as.character(month)Nov                -0.3242407  0.1782577  -1.819 0.069762 .  
I(year - 1910):as.character(month)Feb  0.0001836  0.0020402   0.090 0.928353    
I(year - 1910):as.character(month)Jan  0.0008996  0.0020402   0.441 0.659518    
I(year - 1910):as.character(month)Mar  0.0003013  0.0020765   0.145 0.884724    
I(year - 1910):as.character(month)Nov  0.0005881  0.0021925   0.268 0.788682    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.3449 on 355 degrees of freedom
Multiple R-squared:  0.1931,	Adjusted R-squared:  0.1727 
F-statistic: 9.441 on 9 and 355 DF,  p-value: 6.618e-13

> model_sog <- lm(snow_on_ground~I(year-1910):as.character(month), data = winter)
> summary(model_sog)

Call:
lm(formula = snow_on_ground ~ I(year - 1910):as.character(month), 
    data = winter)

Residuals:
     Min       1Q   Median       3Q      Max 
-0.52477 -0.31135 -0.07364  0.24818  0.73083 

Coefficients:
                                        Estimate Std. Error t value Pr(>|t|)    
(Intercept)                            0.3544130  0.0536633   6.604 1.44e-10 ***
I(year - 1910):as.character(month)Dec -0.0003777  0.0008036  -0.470 0.638610    
I(year - 1910):as.character(month)Feb  0.0005298  0.0008001   0.662 0.508256    
I(year - 1910):as.character(month)Jan  0.0014686  0.0008001   1.836 0.067239 .  
I(year - 1910):as.character(month)Mar -0.0027526  0.0007952  -3.462 0.000602 ***
I(year - 1910):as.character(month)Nov -0.0035591  0.0008036  -4.429 1.26e-05 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.3473 on 359 degrees of freedom
Multiple R-squared:  0.1728,	Adjusted R-squared:  0.1613 
F-statistic:    15 on 5 and 359 DF,  p-value: 2.215e-13

> model_sog <- lm(snow_on_ground~as.character(month) + I(year-1910):as.character(month), data = winter)
> summary(model_sog)

Call:
lm(formula = snow_on_ground ~ as.character(month) + I(year - 
    1910):as.character(month), data = winter)

Residuals:
     Min       1Q   Median       3Q      Max 
-0.50056 -0.27935 -0.06388  0.23310  0.69095 

Coefficients:
                                        Estimate Std. Error t value Pr(>|t|)    
(Intercept)                            0.4208839  0.1185589   3.550 0.000437 ***
as.character(month)Feb                 0.0625367  0.1644128   0.380 0.703903    
as.character(month)Jan                 0.0817072  0.1644128   0.497 0.619522    
as.character(month)Mar                -0.2306646  0.1681642  -1.372 0.171035    
as.character(month)Nov                -0.3242407  0.1782577  -1.819 0.069762 .  
as.character(month)Dec:I(year - 1910) -0.0011529  0.0014705  -0.784 0.433545    
as.character(month)Feb:I(year - 1910) -0.0009693  0.0014142  -0.685 0.493526    
as.character(month)Jan:I(year - 1910) -0.0002533  0.0014142  -0.179 0.857958    
as.character(month)Mar:I(year - 1910) -0.0008516  0.0014661  -0.581 0.561701    
as.character(month)Nov:I(year - 1910) -0.0005648  0.0016263  -0.347 0.728567    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.3449 on 355 degrees of freedom
Multiple R-squared:  0.1931,	Adjusted R-squared:  0.1727 
F-statistic: 9.441 on 9 and 355 DF,  p-value: 6.618e-13

> model_sog <- lm(snow_on_ground~as.character(month)-1 + I(year-1910):as.character(month), data = winter)
> summary(model_sog)

Call:
lm(formula = snow_on_ground ~ as.character(month) - 1 + I(year - 
    1910):as.character(month), data = winter)

Residuals:
     Min       1Q   Median       3Q      Max 
-0.50056 -0.27935 -0.06388  0.23310  0.69095 

Coefficients:
                                        Estimate Std. Error t value Pr(>|t|)    
as.character(month)Dec                 0.4208839  0.1185589   3.550 0.000437 ***
as.character(month)Feb                 0.4834207  0.1139094   4.244 2.81e-05 ***
as.character(month)Jan                 0.5025911  0.1139094   4.412 1.36e-05 ***
as.character(month)Mar                 0.1902193  0.1192602   1.595 0.111603    
as.character(month)Nov                 0.0966432  0.1331150   0.726 0.468309    
as.character(month)Dec:I(year - 1910) -0.0011529  0.0014705  -0.784 0.433545    
as.character(month)Feb:I(year - 1910) -0.0009693  0.0014142  -0.685 0.493526    
as.character(month)Jan:I(year - 1910) -0.0002533  0.0014142  -0.179 0.857958    
as.character(month)Mar:I(year - 1910) -0.0008516  0.0014661  -0.581 0.561701    
as.character(month)Nov:I(year - 1910) -0.0005648  0.0016263  -0.347 0.728567    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.3449 on 355 degrees of freedom
Multiple R-squared:  0.4827,	Adjusted R-squared:  0.4682 
F-statistic: 33.13 on 10 and 355 DF,  p-value: < 2.2e-16

> model_sog <- lm(snow_on_ground~as.character(month)-1 + I(year-1910), data = winter)
> summary(model_sog)

Call:
lm(formula = snow_on_ground ~ as.character(month) - 1 + I(year - 
    1910), data = winter)

Residuals:
     Min       1Q   Median       3Q      Max 
-0.53477 -0.28644 -0.06853  0.23298  0.68264 

Coefficients:
                         Estimate Std. Error t value Pr(>|t|)    
as.character(month)Dec  0.3911593  0.0638668   6.125 2.39e-09 ***
as.character(month)Feb  0.4676994  0.0634835   7.367 1.21e-12 ***
as.character(month)Jan  0.5408526  0.0634835   8.520 4.48e-16 ***
as.character(month)Mar  0.1832609  0.0641053   2.859   0.0045 ** 
as.character(month)Nov  0.1118960  0.0654316   1.710   0.0881 .  
I(year - 1910)         -0.0007608  0.0006551  -1.161   0.2463    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.3431 on 359 degrees of freedom
Multiple R-squared:  0.4824,	Adjusted R-squared:  0.4737 
F-statistic: 55.76 on 6 and 359 DF,  p-value: < 2.2e-16

> install.packages("tidycensus")
trying URL 'https://cran.rstudio.com/bin/macosx/big-sur-x86_64/contrib/4.6/tidycensus_1.8.1.tgz'
Content type 'application/x-gzip' length 3634655 bytes (3.5 MB)
==================================================
downloaded 3.5 MB


The downloaded binary packages are in
	/var/folders/1x/tvy5cf5j4glg4_6g8cxvrcbm7qbgrn/T//RtmprBvvRq/downloaded_packages
> library(tidycensus)
> apropos("api")
  [1] ".rs.addApiFunction"                        
  [2] ".rs.api.addJob"                            
  [3] ".rs.api.addJobOutput"                      
  [4] ".rs.api.addJobProgress"                    
  [5] ".rs.api.addTheme"                          
  [6] ".rs.api.applyTheme"                        
  [7] ".rs.api.askForPassword"                    
  [8] ".rs.api.askForSecret"                      
  [9] ".rs.api.bugReport"                         
 [10] ".rs.api.buildToolsCheck"                   
 [11] ".rs.api.buildToolsExec"                    
 [12] ".rs.api.buildToolsInstall"                 
 [13] ".rs.api.bundledDictionariesPath"           
 [14] ".rs.api.closeAllSourceBuffersWithoutSaving"
 [15] ".rs.api.convertTheme"                      
 [16] ".rs.api.createRequest"                     
 [17] ".rs.api.diagnosticsReport"                 
 [18] ".rs.api.dictionariesPath"                  
 [19] ".rs.api.documentClose"                     
 [20] ".rs.api.documentContents"                  
 [21] ".rs.api.documentId"                        
 [22] ".rs.api.documentNew"                       
 [23] ".rs.api.documentOpen"                      
 [24] ".rs.api.documentPath"                      
 [25] ".rs.api.documentSave"                      
 [26] ".rs.api.documentSaveAll"                   
 [27] ".rs.api.eventTargets"                      
 [28] ".rs.api.eventTypes"                        
 [29] ".rs.api.executeCommand"                    
 [30] ".rs.api.executeJobAction"                  
 [31] ".rs.api.extraDictionariesPath"             
 [32] ".rs.api.filesPaneNavigate"                 
 [33] ".rs.api.getActiveDocumentContext"          
 [34] ".rs.api.getActiveProject"                  
 [35] ".rs.api.getConsoleEditorContext"           
 [36] ".rs.api.getConsoleHasColor"                
 [37] ".rs.api.getJobState"                       
 [38] ".rs.api.getLastActiveEditorContext"        
 [39] ".rs.api.getMode"                           
 [40] ".rs.api.getPackageDependencies"            
 [41] ".rs.api.getPersistentValue"                
 [42] ".rs.api.getSourceEditorContext"            
 [43] ".rs.api.getThemeInfo"                      
 [44] ".rs.api.getThemes"                         
 [45] ".rs.api.getVersion"                        
 [46] ".rs.api.highlightUi"                       
 [47] ".rs.api.initializeProject"                 
 [48] ".rs.api.insertText"                        
 [49] ".rs.api.isDesktop"                         
 [50] ".rs.api.listJobs"                          
 [51] ".rs.api.modifyRange"                       
 [52] ".rs.api.navigateToFile"                    
 [53] ".rs.api.openProject"                       
 [54] ".rs.api.previewRd"                         
 [55] ".rs.api.previewSql"                        
 [56] ".rs.api.readPreference"                    
 [57] ".rs.api.readRStudioPreference"             
 [58] ".rs.api.registerChunkCallback"             
 [59] ".rs.api.registerCommandCallback"           
 [60] ".rs.api.removeJob"                         
 [61] ".rs.api.removeTheme"                       
 [62] ".rs.api.restartSession"                    
 [63] ".rs.api.runScriptJob"                      
 [64] ".rs.api.savePlotAsImage"                   
 [65] ".rs.api.selectDirectory"                   
 [66] ".rs.api.selectFile"                        
 [67] ".rs.api.selectionGet"                      
 [68] ".rs.api.selectionSet"                      
 [69] ".rs.api.sendRequest"                       
 [70] ".rs.api.sendToConsole"                     
 [71] ".rs.api.setGhostText"                      
 [72] ".rs.api.setJobProgress"                    
 [73] ".rs.api.setJobState"                       
 [74] ".rs.api.setJobStatus"                      
 [75] ".rs.api.setPersistentValue"                
 [76] ".rs.api.setSelectionRanges"                
 [77] ".rs.api.showDialog"                        
 [78] ".rs.api.showEditSuggestion"                
 [79] ".rs.api.showMenu"                          
 [80] ".rs.api.showPrompt"                        
 [81] ".rs.api.showQuestion"                      
 [82] ".rs.api.sourceMarkers"                     
 [83] ".rs.api.stopJob"                           
 [84] ".rs.api.systemUsername"                    
 [85] ".rs.api.terminalActivate"                  
 [86] ".rs.api.terminalBuffer"                    
 [87] ".rs.api.terminalBusy"                      
 [88] ".rs.api.terminalClear"                     
 [89] ".rs.api.terminalContext"                   
 [90] ".rs.api.terminalCreate"                    
 [91] ".rs.api.terminalExecute"                   
 [92] ".rs.api.terminalExitCode"                  
 [93] ".rs.api.terminalKill"                      
 [94] ".rs.api.terminalList"                      
 [95] ".rs.api.terminalRunning"                   
 [96] ".rs.api.terminalSend"                      
 [97] ".rs.api.terminalVisible"                   
 [98] ".rs.api.translateLocalUrl"                 
 [99] ".rs.api.tutorialLaunchBrowser"             
[100] ".rs.api.tutorialRun"                       
[101] ".rs.api.tutorialStop"                      
[102] ".rs.api.unregisterChunkCallback"           
[103] ".rs.api.unregisterCommandCallback"         
[104] ".rs.api.updateDialog"                      
[105] ".rs.api.userDictionariesPath"              
[106] ".rs.api.userIdentity"                      
[107] ".rs.api.versionInfo"                       
[108] ".rs.api.viewer"                            
[109] ".rs.api.writePreference"                   
[110] ".rs.api.writeRStudioPreference"            
[111] ".rs.mapInt"                                
[112] ".rs.readApiPref"                           
[113] ".rs.rstudioapi.processRequest"             
[114] ".rs.rstudioapi.processRequestImpl"         
[115] ".rs.writeApiPref"                          
[116] "api"                                       
[117] "api_create"                                
[118] "api_download_grid"                         
[119] "api_download_plot"                         
[120] "census_api_key"                            
[121] "knit_print.api_grid"                       
[122] "knit_print.api_grid_local"                 
[123] "knit_print.api_plot"                       
[124] "shapiro.test"                              
> census_api_key()
To install your API key for use in future sessions, run this function with `install = TRUE`.
Error in census_api_key() : argument "key" is missing, with no default

> census_api_key
function (key, overwrite = FALSE, install = FALSE) 
{
    if (install) {
        home <- Sys.getenv("HOME")
        renv <- file.path(home, ".Renviron")
        if (file.exists(renv)) {
            file.copy(renv, file.path(home, ".Renviron_backup"))
        }
        if (!file.exists(renv)) {
            file.create(renv)
        }
        else {
            if (isTRUE(overwrite)) {
                message("Your original .Renviron will be backed up and stored in your R HOME directory if needed.")
                oldenv = read.table(renv, stringsAsFactors = FALSE)
                newenv <- oldenv[-grep("CENSUS_API_KEY", oldenv), 
                  ]
                write.table(newenv, renv, quote = FALSE, sep = "\n", 
                  col.names = FALSE, row.names = FALSE)
            }
            else {
                tv <- readLines(renv)
                if (any(grepl("CENSUS_API_KEY", tv))) {
                  stop("A CENSUS_API_KEY already exists. You can overwrite it with the argument overwrite=TRUE", 
                    call. = FALSE)
                }
            }
        }
        keyconcat <- paste0("CENSUS_API_KEY='", key, "'")
        write(keyconcat, renv, sep = "\n", append = TRUE)
        message("Your API key has been stored in your .Renviron and can be accessed by Sys.getenv(\"CENSUS_API_KEY\"). \nTo use now, restart R or run `readRenviron(\"~/.Renviron\")`")
        return(key)
    }
    else {
        message("To install your API key for use in future sessions, run this function with `install = TRUE`.")
        Sys.setenv(CENSUS_API_KEY = key)
    }
}
<bytecode: 0x7f7c89bc3038>
<environment: namespace:tidycensus>
> home <- Sys.getenv("HOME")
> renv <- file.path(home, ".Renviron")
> home
[1] "/Users/hofmann"
> renv
[1] "/Users/hofmann/.Renviron"
> edit(renv)
[1] "/Users/hofmann/.Renviron"
> file.edit(renv)
> census_api_key(key="7f784587c3918611ad6ca67188d9b269b3558dd4")
To install your API key for use in future sessions, run this function with `install = TRUE`.
> census_api_key(key="7f784587c3918611ad6ca67188d9b269b3558dd4", install = TRUE)
Error: A CENSUS_API_KEY already exists. You can overwrite it with the argument overwrite=TRUE

> library(tidycensus)
> total_population_10 <- get_decennial(
+   geography = "state", 
+   variables = "P001001",
+   year = 2010
+ )
Getting data from the 2010 decennial Census
Using Census Summary File 1
> total_population_10
# A tibble: 52 × 4
   GEOID NAME        variable    value
   <chr> <chr>       <chr>       <dbl>
 1 01    Alabama     P001001   4779736
 2 02    Alaska      P001001    710231
 3 04    Arizona     P001001   6392017
 4 05    Arkansas    P001001   2915918
 5 06    California  P001001  37253956
 6 22    Louisiana   P001001   4533372
 7 21    Kentucky    P001001   4339367
 8 08    Colorado    P001001   5029196
 9 09    Connecticut P001001   3574097
10 10    Delaware    P001001    897934
# ℹ 42 more rows
# ℹ Use `print(n = ...)` to see more rows
> total_population_20 <- get_decennial(
+   geography = "state", 
+   variables = "P001001",
+   year = 2020
+ )
Getting data from the 2020 decennial Census
Using the PL 94-171 Redistricting Data Summary File
Error in `get_decennial()`:
! Error : Your API call has errors.  The API message returned is error: unknown variable 'P001001'.
Run `rlang::last_trace()` to see where the error occurred.

> total_population_20 <- get_decennial(
+   geography = "state", 
+   #variables = "P001001",
+   year = 2020
+ )
Getting data from the 2020 decennial Census
Error: Either a vector of variables or an table must be specified.

> dec20 <- load_variables(year = 2020)
Error in get_dataset(dataset, year, key = key) : 
  API endpoint not found. Does this data set exist for the specified year? See https://api.census.gov/data.html for data availability.

> ?load_variables
> dec20 <- load_variables(year = 2020, dataset = "sf1")
Error in get_dataset(dataset, year, key = key) : 
  API endpoint not found. Does this data set exist for the specified year? See https://api.census.gov/data.html for data availability.

> dec20 <- load_variables(year = 2020, dataset = "ddhcb")
> dec20
# A tibble: 25 × 3
   name        label                                                     concept         
   <chr>       <chr>                                                     <chr>           
 1 T03001_001N !!Total                                                   HOUSEHOLD TYPE …
 2 T03002_001N !!Total:                                                  HOUSEHOLD TYPE …
 3 T03002_002N !!Total:!!Family households                               HOUSEHOLD TYPE …
 4 T03002_003N !!Total:!!Nonfamily households                            HOUSEHOLD TYPE …
 5 T03003_001N !!Total:                                                  HOUSEHOLD TYPE …
 6 T03003_002N !!Total:!!Family households:                              HOUSEHOLD TYPE …
 7 T03003_003N !!Total:!!Family households:!!Married couple family       HOUSEHOLD TYPE …
 8 T03003_004N !!Total:!!Family households:!!Other family                HOUSEHOLD TYPE …
 9 T03003_005N !!Total:!!Nonfamily households:                           HOUSEHOLD TYPE …
10 T03003_006N !!Total:!!Nonfamily households:!!Householder living alone HOUSEHOLD TYPE …
# ℹ 15 more rows
# ℹ Use `print(n = ...)` to see more rows
> dec20 |> View()
> dec20 <- load_variables(year = 2020, dataset = "dp")
> dec20
# A tibble: 320 × 3
   name      label                                                  concept              
   <chr>     <chr>                                                  <chr>                
 1 DP1_0001C Count!!SEX AND AGE!!Total population                   PROFILE OF GENERAL P…
 2 DP1_0001P Percent!!SEX AND AGE!!Total population                 PROFILE OF GENERAL P…
 3 DP1_0002C Count!!SEX AND AGE!!Total population!!Under 5 years    PROFILE OF GENERAL P…
 4 DP1_0002P Percent!!SEX AND AGE!!Total population!!Under 5 years  PROFILE OF GENERAL P…
 5 DP1_0003C Count!!SEX AND AGE!!Total population!!5 to 9 years     PROFILE OF GENERAL P…
 6 DP1_0003P Percent!!SEX AND AGE!!Total population!!5 to 9 years   PROFILE OF GENERAL P…
 7 DP1_0004C Count!!SEX AND AGE!!Total population!!10 to 14 years   PROFILE OF GENERAL P…
 8 DP1_0004P Percent!!SEX AND AGE!!Total population!!10 to 14 years PROFILE OF GENERAL P…
 9 DP1_0005C Count!!SEX AND AGE!!Total population!!15 to 19 years   PROFILE OF GENERAL P…
10 DP1_0005P Percent!!SEX AND AGE!!Total population!!15 to 19 years PROFILE OF GENERAL P…
# ℹ 310 more rows
# ℹ Use `print(n = ...)` to see more rows
> total_population_20 <- get_decennial(
+   geography = "state", 
+   variables = "DP1_0001C",
+   year = 2020
+ )
Getting data from the 2020 decennial Census
Using the PL 94-171 Redistricting Data Summary File
Error in `get_decennial()`:
! Error : Your API call has errors.  The API message returned is error: unknown variable 'DP1_0001C'.
Run `rlang::last_trace()` to see where the error occurred.

> dec20 <- load_variables(year = 2020, dataset = "pl")
> dec20
# A tibble: 301 × 3
   name    label                                                                  concept
   <chr>   <chr>                                                                  <chr>  
 1 H1_001N " !!Total:"                                                            OCCUPA…
 2 H1_002N " !!Total:!!Occupied"                                                  OCCUPA…
 3 H1_003N " !!Total:!!Vacant"                                                    OCCUPA…
 4 P1_001N " !!Total:"                                                            RACE   
 5 P1_002N " !!Total:!!Population of one race:"                                   RACE   
 6 P1_003N " !!Total:!!Population of one race:!!White alone"                      RACE   
 7 P1_004N " !!Total:!!Population of one race:!!Black or African American alone"  RACE   
 8 P1_005N " !!Total:!!Population of one race:!!American Indian and Alaska Nativ… RACE   
 9 P1_006N " !!Total:!!Population of one race:!!Asian alone"                      RACE   
10 P1_007N " !!Total:!!Population of one race:!!Native Hawaiian and Other Pacifi… RACE   
# ℹ 291 more rows
# ℹ Use `print(n = ...)` to see more rows
> total_population_20 <- get_decennial(
+   geography = "state", 
+   variables = "P1_001N ",
+   year = 2020
+ )
Getting data from the 2020 decennial Census
Using the PL 94-171 Redistricting Data Summary File
Error in `get_decennial()`:
! Error : Your API call has errors.  The API message returned is error: unknown variable ''.
Run `rlang::last_trace()` to see where the error occurred.

> total_population_20 <- get_decennial(
+   geography = "state", 
+   variables = "P1_001N",
+   year = 2020
+ )
Getting data from the 2020 decennial Census
Using the PL 94-171 Redistricting Data Summary File
Note: 2020 decennial Census data use differential privacy, a technique that
introduces errors into data to preserve respondent confidentiality.
ℹ Small counts should be interpreted with caution.
ℹ See https://www.census.gov/library/fact-sheets/2021/protecting-the-confidentiality-of-the-2020-census-redistricting-data.html for additional guidance.
This message is displayed once per session.
> utah_migration <- get_flows(
+   geography = "county",
+   state = "UT",
+   county = "*",
+   year = 2019
+ )
Using FIPS code '49' for state 'UT'
Error in `map_chr()`:
ℹ In index: 1.
Caused by error:
! Result must be length 1, not 0.
Run `rlang::last_trace()` to see where the error occurred.

> utah_migration <- get_flows(
+   geography = "county",
+   state = "UT",
+   year = 2019
+ )
Using FIPS code '49' for state 'UT'
> head(utah_migration)
# A tibble: 6 × 7
  GEOID1 GEOID2 FULL1_NAME          FULL2_NAME           variable estimate   moe
  <chr>  <chr>  <chr>               <chr>                <chr>       <dbl> <dbl>
1 49001  NA     Beaver County, Utah Central America      MOVEDIN        14    18
2 49001  NA     Beaver County, Utah Central America      MOVEDOUT       NA    NA
3 49001  NA     Beaver County, Utah Central America      MOVEDNET       NA    NA
4 49001  04007  Beaver County, Utah Gila County, Arizona MOVEDIN        38    57
5 49001  04007  Beaver County, Utah Gila County, Arizona MOVEDOUT        0    29
6 49001  04007  Beaver County, Utah Gila County, Arizona MOVEDNET       38    57
> utah_migration |> count(FULL1_NAME)
# A tibble: 29 × 2
   FULL1_NAME                 n
   <chr>                  <int>
 1 Beaver County, Utah       93
 2 Box Elder County, Utah   360
 3 Cache County, Utah       891
 4 Carbon County, Utah      198
 5 Daggett County, Utah      24
 6 Davis County, Utah      1260
 7 Duchesne County, Utah    198
 8 Emery County, Utah       102
 9 Garfield County, Utah    129
10 Grand County, Utah       144
# ℹ 19 more rows
# ℹ Use `print(n = ...)` to see more rows
> library(tigris)
To enable caching of data, set `options(tigris_use_cache = TRUE)`
in your R script or .Rprofile.
> ?counties
> ut_counties <- counties(state="UT")
Retrieving data for the year 2024
  |===============================================================================| 100%
Using FIPS code '49' for state 'UT'
> head(ut_counties)
Simple feature collection with 6 features and 18 fields
Geometry type: MULTIPOLYGON
Dimension:     XY
Bounding box:  xmin: -114.05 ymin: 38.57136 xmax: -109.9764 ymax: 42.0017
Geodetic CRS:  NAD83
    STATEFP COUNTYFP COUNTYNS GEOID        GEOIDFQ      NAME         NAMELSAD LSAD
25       49      033 01448030 49033 0500000US49033      Rich      Rich County   06
144      49      005 01448017 49005 0500000US49005     Cache     Cache County   06
272      49      013 01448021 49013 0500000US49013  Duchesne  Duchesne County   06
579      49      011 01448020 49011 0500000US49011     Davis     Davis County   06
650      49      003 01455966 49003 0500000US49003 Box Elder Box Elder County   06
846      49      027 01448027 49027 0500000US49027   Millard   Millard County   06
    CLASSFP MTFCC CSAFP CBSAFP METDIVFP FUNCSTAT       ALAND     AWATER    INTPTLAT
25       H1 G4020  <NA>  21740     <NA>        A  2664471792  149106409 +41.6275976
144      H1 G4020  <NA>  30860     <NA>        A  3016525068   21115037 +41.7341179
272      H1 G4020  <NA>   <NA>     <NA>        A  8379965573   38811228 +40.2893927
579      H1 G4020   482  36260     <NA>        A   841107033  804149067 +41.0375594
650      H1 G4020   482  14940     <NA>        A 14973507313 2455159793 +41.6226233
846      H1 G4020  <NA>   <NA>     <NA>        A 17574316027  133292861 +38.9567436
        INTPTLON                       geometry
25  -111.2402269 MULTIPOLYGON (((-111.512 41...
144 -111.7453936 MULTIPOLYGON (((-112.166 41...
272 -110.4295838 MULTIPOLYGON (((-110.9029 4...
579 -112.2019434 MULTIPOLYGON (((-112.0081 4...
650 -113.0602520 MULTIPOLYGON (((-112.1332 4...
846 -113.1330920 MULTIPOLYGON (((-112.1373 3...
> ut_counties |> ggplot() + geom_sf()
> ut_counties |> ggplot() + geom_sf() + theme_map()
Error in theme_map() : could not find function "theme_map"

> ut_counties |> ggplot() + geom_sf() + themes::theme_map()
Error in loadNamespace(x) : there is no package called ‘themes’

> ut_counties |> ggplot() + geom_sf() + ggthemes::theme_map()
> head(utah_migration)
# A tibble: 6 × 7
  GEOID1 GEOID2 FULL1_NAME          FULL2_NAME           variable estimate   moe
  <chr>  <chr>  <chr>               <chr>                <chr>       <dbl> <dbl>
1 49001  NA     Beaver County, Utah Central America      MOVEDIN        14    18
2 49001  NA     Beaver County, Utah Central America      MOVEDOUT       NA    NA
3 49001  NA     Beaver County, Utah Central America      MOVEDNET       NA    NA
4 49001  04007  Beaver County, Utah Gila County, Arizona MOVEDIN        38    57
5 49001  04007  Beaver County, Utah Gila County, Arizona MOVEDOUT        0    29
6 49001  04007  Beaver County, Utah Gila County, Arizona MOVEDNET       38    57
> ut_migrate <- utah_migration |> group_by(GEOID1, FULL1_NAME) |>
+   summarize(
+     move_in = sum(estimate[variable=="MOVEDIN"], na.rm=TRUE),
+     move_out = sum(estimate[variable=="MOVEDOUT"], na.rm=TRUE)
+   )
`summarise()` has regrouped the output.
ℹ Summaries were computed grouped by GEOID1 and FULL1_NAME.
ℹ Output is grouped by GEOID1.
ℹ Use `summarise(.groups = "drop_last")` to silence this message.
ℹ Use `summarise(.by = c(GEOID1, FULL1_NAME))` for per-operation grouping instead.
> head(ut_migrate)
# A tibble: 6 × 4
# Groups:   GEOID1 [6]
  GEOID1 FULL1_NAME             move_in move_out
  <chr>  <chr>                    <dbl>    <dbl>
1 49001  Beaver County, Utah        272      883
2 49003  Box Elder County, Utah    3655     3814
3 49005  Cache County, Utah       10982     9759
4 49007  Carbon County, Utah       1423      833
5 49009  Daggett County, Utah        44       39
6 49011  Davis County, Utah       26395    25046
> ut_migrate_plus <- ut_migrate |> left_join(ut_counties)
Error in `left_join()`:
! `by` must be supplied when `x` and `y` have no common variables.
ℹ Use `cross_join()` to perform a cross-join.
Run `rlang::last_trace()` to see where the error occurred.

> head(ut_counties)
Simple feature collection with 6 features and 18 fields
Geometry type: MULTIPOLYGON
Dimension:     XY
Bounding box:  xmin: -114.05 ymin: 38.57136 xmax: -109.9764 ymax: 42.0017
Geodetic CRS:  NAD83
    STATEFP COUNTYFP COUNTYNS GEOID        GEOIDFQ      NAME         NAMELSAD LSAD
25       49      033 01448030 49033 0500000US49033      Rich      Rich County   06
144      49      005 01448017 49005 0500000US49005     Cache     Cache County   06
272      49      013 01448021 49013 0500000US49013  Duchesne  Duchesne County   06
579      49      011 01448020 49011 0500000US49011     Davis     Davis County   06
650      49      003 01455966 49003 0500000US49003 Box Elder Box Elder County   06
846      49      027 01448027 49027 0500000US49027   Millard   Millard County   06
    CLASSFP MTFCC CSAFP CBSAFP METDIVFP FUNCSTAT       ALAND     AWATER    INTPTLAT
25       H1 G4020  <NA>  21740     <NA>        A  2664471792  149106409 +41.6275976
144      H1 G4020  <NA>  30860     <NA>        A  3016525068   21115037 +41.7341179
272      H1 G4020  <NA>   <NA>     <NA>        A  8379965573   38811228 +40.2893927
579      H1 G4020   482  36260     <NA>        A   841107033  804149067 +41.0375594
650      H1 G4020   482  14940     <NA>        A 14973507313 2455159793 +41.6226233
846      H1 G4020  <NA>   <NA>     <NA>        A 17574316027  133292861 +38.9567436
        INTPTLON                       geometry
25  -111.2402269 MULTIPOLYGON (((-111.512 41...
144 -111.7453936 MULTIPOLYGON (((-112.166 41...
272 -110.4295838 MULTIPOLYGON (((-110.9029 4...
579 -112.2019434 MULTIPOLYGON (((-112.0081 4...
650 -113.0602520 MULTIPOLYGON (((-112.1332 4...
846 -113.1330920 MULTIPOLYGON (((-112.1373 3...
> ut_migrate_plus <- ut_migrate |> left_join(ut_counties, by=c("GEOID1"="GEOID"))
> ut_migrate_plus |>
+   ggplot(aes(fill = moved_out)) + geom_sf()
Error in `geom_sf()`:
! Problem while computing aesthetics.
ℹ Error occurred in the 1st layer.
Caused by error:
! object 'moved_out' not found
Run `rlang::last_trace()` to see where the error occurred.

> ut_migrate_plus |>
+   ggplot(aes(fill = move_out)) + geom_sf()
Error in `geom_sf()`:
! Problem while computing stat.
ℹ Error occurred in the 1st layer.
Caused by error in `compute_layer()`:
! `stat_sf()` requires the following missing aesthetics: geometry.
Run `rlang::last_trace()` to see where the error occurred.

> ut_migrate_plus
# A tibble: 29 × 22
# Groups:   GEOID1 [29]
   GEOID1 FULL1_NAME    move_in move_out STATEFP COUNTYFP COUNTYNS GEOIDFQ NAME  NAMELSAD
   <chr>  <chr>           <dbl>    <dbl> <chr>   <chr>    <chr>    <chr>   <chr> <chr>   
 1 49001  Beaver Count…     272      883 49      001      01448015 050000… Beav… Beaver …
 2 49003  Box Elder Co…    3655     3814 49      003      01455966 050000… Box … Box Eld…
 3 49005  Cache County…   10982     9759 49      005      01448017 050000… Cache Cache C…
 4 49007  Carbon Count…    1423      833 49      007      01448018 050000… Carb… Carbon …
 5 49009  Daggett Coun…      44       39 49      009      01448019 050000… Dagg… Daggett…
 6 49011  Davis County…   26395    25046 49      011      01448020 050000… Davis Davis C…
 7 49013  Duchesne Cou…    1402     1801 49      013      01448021 050000… Duch… Duchesn…
 8 49015  Emery County…     536      742 49      015      01448022 050000… Emery Emery C…
 9 49017  Garfield Cou…     312      303 49      017      01448023 050000… Garf… Garfiel…
10 49019  Grand County…     226      886 49      019      01448024 050000… Grand Grand C…
# ℹ 19 more rows
# ℹ 12 more variables: LSAD <chr>, CLASSFP <chr>, MTFCC <chr>, CSAFP <chr>,
#   CBSAFP <chr>, METDIVFP <chr>, FUNCSTAT <chr>, ALAND <dbl>, AWATER <dbl>,
#   INTPTLAT <chr>, INTPTLON <chr>, geometry <MULTIPOLYGON [°]>
# ℹ Use `print(n = ...)` to see more rows
> ut_migrate_plus <- ut_counties |>  left_join(ut_migrate, by=c("GEOID"="GEOID1"))
> ut_migrate_plus |>
+   ggplot(aes(fill = move_out)) + geom_sf()
> ut_migrate_plus |>
+   ggplot(aes(fill = move_in)) + geom_sf()
> ut_migrate_plus |>
+   ggplot(aes(fill = move_in - move_out)) + geom_sf()
> head(ut_counties)
Simple feature collection with 6 features and 18 fields
Geometry type: MULTIPOLYGON
Dimension:     XY
Bounding box:  xmin: -114.05 ymin: 38.57136 xmax: -109.9764 ymax: 42.0017
Geodetic CRS:  NAD83
    STATEFP COUNTYFP COUNTYNS GEOID        GEOIDFQ      NAME         NAMELSAD LSAD
25       49      033 01448030 49033 0500000US49033      Rich      Rich County   06
144      49      005 01448017 49005 0500000US49005     Cache     Cache County   06
272      49      013 01448021 49013 0500000US49013  Duchesne  Duchesne County   06
579      49      011 01448020 49011 0500000US49011     Davis     Davis County   06
650      49      003 01455966 49003 0500000US49003 Box Elder Box Elder County   06
846      49      027 01448027 49027 0500000US49027   Millard   Millard County   06
    CLASSFP MTFCC CSAFP CBSAFP METDIVFP FUNCSTAT       ALAND     AWATER    INTPTLAT
25       H1 G4020  <NA>  21740     <NA>        A  2664471792  149106409 +41.6275976
144      H1 G4020  <NA>  30860     <NA>        A  3016525068   21115037 +41.7341179
272      H1 G4020  <NA>   <NA>     <NA>        A  8379965573   38811228 +40.2893927
579      H1 G4020   482  36260     <NA>        A   841107033  804149067 +41.0375594
650      H1 G4020   482  14940     <NA>        A 14973507313 2455159793 +41.6226233
846      H1 G4020  <NA>   <NA>     <NA>        A 17574316027  133292861 +38.9567436
        INTPTLON                       geometry
25  -111.2402269 MULTIPOLYGON (((-111.512 41...
144 -111.7453936 MULTIPOLYGON (((-112.166 41...
272 -110.4295838 MULTIPOLYGON (((-110.9029 4...
579 -112.2019434 MULTIPOLYGON (((-112.0081 4...
650 -113.0602520 MULTIPOLYGON (((-112.1332 4...
846 -113.1330920 MULTIPOLYGON (((-112.1373 3...
> utah_population_20 <- get_decennial(
+   geography = "county", 
+   state="UT",
+   variables = "P1_001N",
+   year = 2020
+ )
Getting data from the 2020 decennial Census
Using FIPS code '49' for state 'UT'
Using the PL 94-171 Redistricting Data Summary File
> utah_population_20
# A tibble: 29 × 4
   GEOID NAME                   variable  value
   <chr> <chr>                  <chr>     <dbl>
 1 49001 Beaver County, Utah    P1_001N    7072
 2 49003 Box Elder County, Utah P1_001N   57666
 3 49005 Cache County, Utah     P1_001N  133154
 4 49007 Carbon County, Utah    P1_001N   20412
 5 49009 Daggett County, Utah   P1_001N     935
 6 49011 Davis County, Utah     P1_001N  362679
 7 49013 Duchesne County, Utah  P1_001N   19596
 8 49015 Emery County, Utah     P1_001N    9825
 9 49017 Garfield County, Utah  P1_001N    5083
10 49019 Grand County, Utah     P1_001N    9669
# ℹ 19 more rows
# ℹ Use `print(n = ...)` to see more rows
> ut_migrate_plus <- ut_counties |>  left_join(ut_migrate, by=c("GEOID"="GEOID1")) |>
+   left_join(utah_population_20)
Joining with `by = join_by(GEOID, NAME)`
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out)/value)) + geom_sf()
> ut_migrate_plus <- ut_counties |>  left_join(ut_migrate, by=c("GEOID"="GEOID1")) |>
+   left_join(utah_population_20)
Joining with `by = join_by(GEOID, NAME)`
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out)/value)) + geom_sf()
> ut_migrate_plus
Simple feature collection with 29 features and 23 fields
Geometry type: MULTIPOLYGON
Dimension:     XY
Bounding box:  xmin: -114.0529 ymin: 36.99766 xmax: -109.0416 ymax: 42.0017
Geodetic CRS:  NAD83
First 10 features:
   STATEFP COUNTYFP COUNTYNS GEOID        GEOIDFQ      NAME         NAMELSAD LSAD
1       49      033 01448030 49033 0500000US49033      Rich      Rich County   06
2       49      005 01448017 49005 0500000US49005     Cache     Cache County   06
3       49      013 01448021 49013 0500000US49013  Duchesne  Duchesne County   06
4       49      011 01448020 49011 0500000US49011     Davis     Davis County   06
5       49      003 01455966 49003 0500000US49003 Box Elder Box Elder County   06
6       49      027 01448027 49027 0500000US49027   Millard   Millard County   06
7       49      029 01448028 49029 0500000US49029    Morgan    Morgan County   06
8       49      057 01448042 49057 0500000US49057     Weber     Weber County   06
9       49      025 01448026 49025 0500000US49025      Kane      Kane County   06
10      49      035 01448031 49035 0500000US49035 Salt Lake Salt Lake County   06
   CLASSFP MTFCC CSAFP CBSAFP METDIVFP FUNCSTAT       ALAND     AWATER    INTPTLAT
1       H1 G4020  <NA>  21740     <NA>        A  2664471792  149106409 +41.6275976
2       H1 G4020  <NA>  30860     <NA>        A  3016525068   21115037 +41.7341179
3       H1 G4020  <NA>   <NA>     <NA>        A  8379965573   38811228 +40.2893927
4       H1 G4020   482  36260     <NA>        A   841107033  804149067 +41.0375594
5       H1 G4020   482  14940     <NA>        A 14973507313 2455159793 +41.6226233
6       H1 G4020  <NA>   <NA>     <NA>        A 17574316027  133292861 +38.9567436
7       H1 G4020   482  36260     <NA>        A  1577814088    4437369 +41.0910273
8       H1 G4020   482  36260     <NA>        A  1582541439  126602101 +41.2703252
9       H1 G4020  <NA>   <NA>     <NA>        A 10344775613  292843946 +37.2750892
10      H1 G4020   482  41620     <NA>        A  1949876460  136855044 +40.6678828
       INTPTLON             FULL1_NAME move_in move_out variable value
1  -111.2402269      Rich County, Utah      49      202     <NA>    NA
2  -111.7453936     Cache County, Utah   10982     9759     <NA>    NA
3  -110.4295838  Duchesne County, Utah    1402     1801     <NA>    NA
4  -112.2019434     Davis County, Utah   26395    25046     <NA>    NA
5  -113.0602520 Box Elder County, Utah    3655     3814     <NA>    NA
6  -113.1330920   Millard County, Utah     644      595     <NA>    NA
7  -111.5778846    Morgan County, Utah     841     1171     <NA>    NA
8  -111.8768830     Weber County, Utah   18753    14759     <NA>    NA
9  -111.8153290      Kane County, Utah     933      385     <NA>    NA
10 -111.9242397 Salt Lake County, Utah   70859    61216     <NA>    NA
                         geometry
1  MULTIPOLYGON (((-111.512 41...
2  MULTIPOLYGON (((-112.166 41...
3  MULTIPOLYGON (((-110.9029 4...
4  MULTIPOLYGON (((-112.0081 4...
5  MULTIPOLYGON (((-112.1332 4...
6  MULTIPOLYGON (((-112.1373 3...
7  MULTIPOLYGON (((-111.8766 4...
8  MULTIPOLYGON (((-111.9758 4...
9  MULTIPOLYGON (((-112.9013 3...
10 MULTIPOLYGON (((-111.7376 4...
> utah_population_20 <- get_decennial(
+   geography = "county", 
+   state="UT",
+   variables = "P1_001N",
+   year = 2020
+ )
Getting data from the 2020 decennial Census
Using FIPS code '49' for state 'UT'
Using the PL 94-171 Redistricting Data Summary File
> utah_population_20
# A tibble: 29 × 4
   GEOID NAME                   variable  value
   <chr> <chr>                  <chr>     <dbl>
 1 49001 Beaver County, Utah    P1_001N    7072
 2 49003 Box Elder County, Utah P1_001N   57666
 3 49005 Cache County, Utah     P1_001N  133154
 4 49007 Carbon County, Utah    P1_001N   20412
 5 49009 Daggett County, Utah   P1_001N     935
 6 49011 Davis County, Utah     P1_001N  362679
 7 49013 Duchesne County, Utah  P1_001N   19596
 8 49015 Emery County, Utah     P1_001N    9825
 9 49017 Garfield County, Utah  P1_001N    5083
10 49019 Grand County, Utah     P1_001N    9669
# ℹ 19 more rows
# ℹ Use `print(n = ...)` to see more rows
> utah_population_20 <- get_decennial(
+   geography = "county", 
+   state="UT",
+   variables = "P1_001N",
+   year = 2020,
+   geometry = TRUE
+ )
Getting data from the 2020 decennial Census
Downloading feature geometry from the Census website.  To cache shapefiles for use in future sessions, set `options(tigris_use_cache = TRUE)`.
Using FIPS code '49' for state 'UT'
Using the PL 94-171 Redistricting Data Summary File
  |===============================================================================| 100%
> ut_migrate_plus <- utah_population_20 |>  left_join(ut_migrate, by=c("GEOID"="GEOID1"))
> ut_migrate_plus
Simple feature collection with 29 features and 7 fields
Geometry type: MULTIPOLYGON
Dimension:     XY
Bounding box:  xmin: -114.053 ymin: 36.99797 xmax: -109.0411 ymax: 42.0017
Geodetic CRS:  NAD83
# A tibble: 29 × 8
   GEOID NAME       variable  value                  geometry FULL1_NAME move_in move_out
   <chr> <chr>      <chr>     <dbl>        <MULTIPOLYGON [°]> <chr>        <dbl>    <dbl>
 1 49035 Salt Lake… P1_001N  1.19e6 (((-112.2602 40.76909, -… Salt Lake…   70859    61216
 2 49011 Davis Cou… P1_001N  3.63e5 (((-112.4516 41.08733, -… Davis Cou…   26395    25046
 3 49025 Kane Coun… P1_001N  7.67e3 (((-112.9014 37.296, -11… Kane Coun…     933      385
 4 49043 Summit Co… P1_001N  4.24e4 (((-111.648 40.7763, -11… Summit Co…    3820     3838
 5 49003 Box Elder… P1_001N  5.77e4 (((-114.0426 41.21092, -… Box Elder…    3655     3814
 6 49051 Wasatch C… P1_001N  3.48e4 (((-111.6207 40.45132, -… Wasatch C…    3973     2628
 7 49005 Cache Cou… P1_001N  1.33e5 (((-112.166 41.99618, -1… Cache Cou…   10982     9759
 8 49001 Beaver Co… P1_001N  7.07e3 (((-114.0505 38.49995, -… Beaver Co…     272      883
 9 49047 Uintah Co… P1_001N  3.56e4 (((-110.0476 39.53438, -… Uintah Co…    2117     3591
10 49019 Grand Cou… P1_001N  9.67e3 (((-110.179 38.9092, -11… Grand Cou…     226      886
# ℹ 19 more rows
# ℹ Use `print(n = ...)` to see more rows
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out)/value)) + geom_sf()
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out)/value*100)) + geom_sf()
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out)/value*100)) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_color_gradient2()
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out))) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_color_gradient2("Change in Population")
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out))) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_fill_gradient2("Change in Population")
> utah_migration <- get_flows(
+   geography = "county",
+   state = "UT",
+   year = 2025
+ )
Using FIPS code '49' for state 'UT'
Error: Your API call has errors.  The API message returned is <!doctype html><html lang="en"><head><title>HTTP Status 404 ? Not Found</title><style type="text/css">body {font-family:Tahoma,Arial,sans-serif;} h1, h2, h3, b {color:white;background-color:#525D76;} h1 {font-size:22px;} h2 {font-size:16px;} h3 {font-size:14px;} p {font-size:12px;} a {color:black;} .line {height:1px;background-color:#525D76;border:none;}</style></head><body><h1>HTTP Status 404 ? Not Found</h1></body></html>.

> utah_migration <- get_flows(
+   geography = "county",
+   state = "UT",
+   year = 2024
+ )
Using FIPS code '49' for state 'UT'
Error: Your API call has errors.  The API message returned is <!doctype html><html lang="en"><head><title>HTTP Status 404 ? Not Found</title><style type="text/css">body {font-family:Tahoma,Arial,sans-serif;} h1, h2, h3, b {color:white;background-color:#525D76;} h1 {font-size:22px;} h2 {font-size:16px;} h3 {font-size:14px;} p {font-size:12px;} a {color:black;} .line {height:1px;background-color:#525D76;border:none;}</style></head><body><h1>HTTP Status 404 ? Not Found</h1></body></html>.

> utah_migration <- get_flows(
+   geography = "county",
+   state = "UT",
+   year = 2023
+ )
Using FIPS code '49' for state 'UT'
Error: Your API call has errors.  The API message returned is <!doctype html><html lang="en"><head><title>HTTP Status 404 ? Not Found</title><style type="text/css">body {font-family:Tahoma,Arial,sans-serif;} h1, h2, h3, b {color:white;background-color:#525D76;} h1 {font-size:22px;} h2 {font-size:16px;} h3 {font-size:14px;} p {font-size:12px;} a {color:black;} .line {height:1px;background-color:#525D76;border:none;}</style></head><body><h1>HTTP Status 404 ? Not Found</h1></body></html>.

> utah_migration <- get_flows(
+   geography = "county",
+   state = "UT",
+   year = 2022
+ )
Using FIPS code '49' for state 'UT'
> ut_migrate <- utah_migration |> group_by(GEOID1, FULL1_NAME) |>
+   summarize(
+     move_in = sum(estimate[variable=="MOVEDIN"], na.rm=TRUE),
+     move_out = sum(estimate[variable=="MOVEDOUT"], na.rm=TRUE)
+   )
`summarise()` has regrouped the output.
ℹ Summaries were computed grouped by GEOID1 and FULL1_NAME.
ℹ Output is grouped by GEOID1.
ℹ Use `summarise(.groups = "drop_last")` to silence this message.
ℹ Use `summarise(.by = c(GEOID1, FULL1_NAME))` for per-operation grouping instead.
> ut_migrate_plus <- utah_population_20 |>  left_join(ut_migrate, by=c("GEOID"="GEOID1"))
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out))) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_fill_gradient2("Change in Population in 2022")
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out)/value*100)) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_color_gradient2("Pct fluctuation")
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out)/value*100)) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_fill_gradient2("Pct fluctuation")
> utah_migration <- get_flows(
+   geography = "county",
+   state = "UT",
+   year = 2021
+ )
Using FIPS code '49' for state 'UT'
> ut_migrate <- utah_migration |> group_by(GEOID1, FULL1_NAME) |>
+   summarize(
+     move_in = sum(estimate[variable=="MOVEDIN"], na.rm=TRUE),
+     move_out = sum(estimate[variable=="MOVEDOUT"], na.rm=TRUE)
+   )
`summarise()` has regrouped the output.
ℹ Summaries were computed grouped by GEOID1 and FULL1_NAME.
ℹ Output is grouped by GEOID1.
ℹ Use `summarise(.groups = "drop_last")` to silence this message.
ℹ Use `summarise(.by = c(GEOID1, FULL1_NAME))` for per-operation grouping instead.
> ut_migrate_plus <- utah_population_20 |>  left_join(ut_migrate, by=c("GEOID"="GEOID1"))
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out))) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_fill_gradient2("Change in Population in 2022")
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out)/value*100)) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_fill_gradient2("Pct fluctuation")
> utah_migration <- get_flows(
+   geography = "county",
+   state = "UT",
+   year = 2019
+ )
Using FIPS code '49' for state 'UT'
> utah_population_20 <- get_decennial(
+   geography = "county", 
+   state="UT",
+   variables = "P1_001N",
+   year = 2020,
+   geometry = TRUE
+ )
Getting data from the 2020 decennial Census
Downloading feature geometry from the Census website.  To cache shapefiles for use in future sessions, set `options(tigris_use_cache = TRUE)`.
Using FIPS code '49' for state 'UT'
Using the PL 94-171 Redistricting Data Summary File
> library(tigris)
> ut_migrate <- utah_migration |> group_by(GEOID1, FULL1_NAME) |>
+   summarize(
+     move_in = sum(estimate[variable=="MOVEDIN"], na.rm=TRUE),
+     move_out = sum(estimate[variable=="MOVEDOUT"], na.rm=TRUE)
+   )
`summarise()` has regrouped the output.
ℹ Summaries were computed grouped by GEOID1 and FULL1_NAME.
ℹ Output is grouped by GEOID1.
ℹ Use `summarise(.groups = "drop_last")` to silence this message.
ℹ Use `summarise(.by = c(GEOID1, FULL1_NAME))` for per-operation grouping instead.
> ut_migrate_plus <- utah_population_20 |>  left_join(ut_migrate, by=c("GEOID"="GEOID1"))
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out))) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_fill_gradient2("Change in Population in 2022")
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out)/value*100)) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_fill_gradient2("Pct fluctuation")
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out)/value*100)) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_fill_gradient2("Percent Change")
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out))) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_fill_gradient2("Change in Population in 2019")
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out)/value*100)) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_fill_gradient2("Percent Change")
> utah_migration <- get_flows(
+   geography = "county",
+   state = "UT",
+   year = 2019:2022
+ )
Error in if (year < 2010) { : the condition has length > 1

> utah_migration_19 <- get_flows(
+   geography = "county",
+   state = "UT",
+   year = 2019
+ )
Using FIPS code '49' for state 'UT'
> 
> utah_migration_20 <- get_flows(
+   geography = "county",
+   state = "UT",
+   year = 2020
+ )
Using FIPS code '49' for state 'UT'
> 
> utah_migration_21 <- get_flows(
+   geography = "county",
+   state = "UT",
+   year = 2021
+ )
Using FIPS code '49' for state 'UT'
> utah_migration <- rbind(utah_migration_19, utah_migration_20, utah_migration_21)
> utah_population_20 <- get_decennial(
+   geography = "county", 
+   state="UT",
+   variables = "P1_001N",
+   year = 2020,
+   geometry = TRUE
+ )
Getting data from the 2020 decennial Census
Downloading feature geometry from the Census website.  To cache shapefiles for use in future sessions, set `options(tigris_use_cache = TRUE)`.
Using FIPS code '49' for state 'UT'
Using the PL 94-171 Redistricting Data Summary File
> library(tigris)
> ut_migrate <- utah_migration |> group_by(GEOID1, FULL1_NAME) |>
+   summarize(
+     move_in = sum(estimate[variable=="MOVEDIN"], na.rm=TRUE),
+     move_out = sum(estimate[variable=="MOVEDOUT"], na.rm=TRUE)
+   )
`summarise()` has regrouped the output.
ℹ Summaries were computed grouped by GEOID1 and FULL1_NAME.
ℹ Output is grouped by GEOID1.
ℹ Use `summarise(.groups = "drop_last")` to silence this message.
ℹ Use `summarise(.by = c(GEOID1, FULL1_NAME))` for per-operation grouping instead.
> ut_migrate <- utah_migration |> group_by(GEOID1, FULL1_NAME, year) |>
+   summarize(
+     move_in = sum(estimate[variable=="MOVEDIN"], na.rm=TRUE),
+     move_out = sum(estimate[variable=="MOVEDOUT"], na.rm=TRUE)
+   )
Error in `group_by()`:
! Must group by variables found in `.data`.
✖ Column `year` is not found.
Run `rlang::last_trace()` to see where the error occurred.

> utah_migration <- rbind(utah_migration_19 |> mutate(year = 2019), 
+                         utah_migration_20 |> mutate(year = 2020),
+                         utah_migration_21|> mutate(year = 2021))
> utah_population_20 <- get_decennial(
+   geography = "county", 
+   state="UT",
+   variables = "P1_001N",
+   year = 2020,
+   geometry = TRUE
+ )
Getting data from the 2020 decennial Census
Downloading feature geometry from the Census website.  To cache shapefiles for use in future sessions, set `options(tigris_use_cache = TRUE)`.
Using FIPS code '49' for state 'UT'
Using the PL 94-171 Redistricting Data Summary File
> library(tigris)
> ut_migrate <- utah_migration |> group_by(GEOID1, FULL1_NAME, year) |>
+   summarize(
+     move_in = sum(estimate[variable=="MOVEDIN"], na.rm=TRUE),
+     move_out = sum(estimate[variable=="MOVEDOUT"], na.rm=TRUE)
+   )
`summarise()` has regrouped the output.
ℹ Summaries were computed grouped by GEOID1, FULL1_NAME, and year.
ℹ Output is grouped by GEOID1 and FULL1_NAME.
ℹ Use `summarise(.groups = "drop_last")` to silence this message.
ℹ Use `summarise(.by = c(GEOID1, FULL1_NAME, year))` for per-operation grouping instead.
> ut_migrate_plus <- utah_population_20 |>  left_join(ut_migrate, by=c("GEOID"="GEOID1"))
> dim(ut_migrate_plus)
[1] 87  9
> names(ut_migrate_plus)
[1] "GEOID"      "NAME"       "variable"   "value"      "geometry"   "FULL1_NAME"
[7] "year"       "move_in"    "move_out"  
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out))) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_fill_gradient2("Change in Population") + 
+   facet_grid(~year)
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out))) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_fill_gradient2("Change in Population") + 
+   facet_grid(~year) + 
+   theme(legend.position = "right")
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out))) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_fill_gradient2("Change in Population") + 
+   facet_grid(~year) + 
+   theme(legend.position = "bottom")
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out))) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_fill_gradient2("Change in Population") + 
+   facet_grid(~year) + 
+   theme(legend.position = "bottom") +
+   ggtitle("Change in Population")
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out)/value*100)) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_fill_gradient2("Percent Change") +
+   facet_grid(~year) + 
+   theme(legend.position = "bottom") +
+   ggtitle("Percent Change in Population")
> utah_migration_22 <- get_flows(
+   geography = "county",
+   state = "UT",
+   year = 2022
+ )
Using FIPS code '49' for state 'UT'
> utah_migration <- rbind(utah_migration_19 |> mutate(year = 2019), 
+                         utah_migration_20 |> mutate(year = 2020),
+                         utah_migration_21|> mutate(year = 2021),
+                         utah_migration_22|> mutate(year = 2022))
> ut_migrate <- utah_migration |> group_by(GEOID1, FULL1_NAME, year) |>
+   summarize(
+     move_in = sum(estimate[variable=="MOVEDIN"], na.rm=TRUE),
+     move_out = sum(estimate[variable=="MOVEDOUT"], na.rm=TRUE)
+   )
`summarise()` has regrouped the output.
ℹ Summaries were computed grouped by GEOID1, FULL1_NAME, and year.
ℹ Output is grouped by GEOID1 and FULL1_NAME.
ℹ Use `summarise(.groups = "drop_last")` to silence this message.
ℹ Use `summarise(.by = c(GEOID1, FULL1_NAME, year))` for per-operation grouping instead.
> ut_migrate_plus <- utah_population_20 |>  left_join(ut_migrate, by=c("GEOID"="GEOID1"))
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out))) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_fill_gradient2("Change in Population") + 
+   facet_grid(~year) + 
+   theme(legend.position = "bottom") +
+   ggtitle("Change in Population")
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out)/value*100)) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_fill_gradient2("Percent Change") +
+   facet_grid(~year) + 
+   theme(legend.position = "bottom") +
+   ggtitle("Percent Change in Population")
> source(here::here("census-api.R"))
Getting data from the 2010 decennial Census
Using Census Summary File 1
Getting data from the 2020 decennial Census
Using the PL 94-171 Redistricting Data Summary File
Using FIPS code '49' for state 'UT'
Using FIPS code '49' for state 'UT'
Using FIPS code '49' for state 'UT'
Using FIPS code '49' for state 'UT'
Getting data from the 2020 decennial Census
Downloading feature geometry from the Census website.  To cache shapefiles for use in future sessions, set `options(tigris_use_cache = TRUE)`.
Using FIPS code '49' for state 'UT'
Using the PL 94-171 Redistricting Data Summary File
`summarise()` has regrouped the output.
ℹ Summaries were computed grouped by GEOID1, FULL1_NAME, and year.
ℹ Output is grouped by GEOID1 and FULL1_NAME.
ℹ Use `summarise(.groups = "drop_last")` to silence this message.
ℹ Use `summarise(.by = c(GEOID1, FULL1_NAME, year))` for per-operation grouping
  instead.
old-style crs object detected; please recreate object with a recent sf::st_crs()
old-style crs object detected; please recreate object with a recent sf::st_crs()
> library(tidycensus)
> # total_population_10 <- get_decennial(
> #   geography = "state", 
> #   variables = "P001001",
> #   year = 2010
> # )
> # 
> # dec20 <- load_variables(year = 2020, dataset = "pl")
> # total_population_20 <- get_decennial(
> #   geography = "state", 
> #   variables = "P1_001N",
> #   year = 2020
> # )
> 
> state_fixed <- "UT"
> utah_migration_19 <- get_flows(
+   geography = "county",
+   state = state_fixed,
+   year = 2019
+ )
Using FIPS code '49' for state 'UT'
> 
> utah_migration_20 <- get_flows(
+   geography = "county",
+   state = state_fixed,
+   year = 2020
+ )
Using FIPS code '49' for state 'UT'
> 
> utah_migration_21 <- get_flows(
+   geography = "county",
+   state = state_fixed,
+   year = 2021
+ )
Using FIPS code '49' for state 'UT'
> 
> utah_migration_22 <- get_flows(
+   geography = "county",
+   state = state_fixed,
+   year = 2022
+ )
Using FIPS code '49' for state 'UT'
> 
> utah_migration <- rbind(utah_migration_19 |> mutate(year = 2019), 
+                         utah_migration_20 |> mutate(year = 2020),
+                         utah_migration_21|> mutate(year = 2021),
+                         utah_migration_22|> mutate(year = 2022))
> 
> utah_population_20 <- get_decennial(
+   geography = "county", 
+   state=state_fixed,
+   variables = "P1_001N",
+   year = 2020,
+   geometry = TRUE
+ )
Getting data from the 2020 decennial Census
Downloading feature geometry from the Census website.  To cache shapefiles for use in future sessions, set `options(tigris_use_cache = TRUE)`.
Using FIPS code '49' for state 'UT'
Using the PL 94-171 Redistricting Data Summary File
> 
> library(tigris)
> 
> #ut_counties <- counties(state="UT")
> 
> #ut_counties |> ggplot() + geom_sf() + ggthemes::theme_map()
> 
> 
> ut_migrate <- utah_migration |> group_by(GEOID1, FULL1_NAME, year) |>
+   summarize(
+     move_in = sum(estimate[variable=="MOVEDIN"], na.rm=TRUE),
+     move_out = sum(estimate[variable=="MOVEDOUT"], na.rm=TRUE)
+   )
`summarise()` has regrouped the output.
ℹ Summaries were computed grouped by GEOID1, FULL1_NAME, and year.
ℹ Output is grouped by GEOID1 and FULL1_NAME.
ℹ Use `summarise(.groups = "drop_last")` to silence this message.
ℹ Use `summarise(.by = c(GEOID1, FULL1_NAME, year))` for per-operation grouping instead.
> 
> ut_migrate_plus <- utah_population_20 |>  left_join(ut_migrate, by=c("GEOID"="GEOID1"))
> library(tidycensus)
> # total_population_10 <- get_decennial(
> #   geography = "state", 
> #   variables = "P001001",
> #   year = 2010
> # )
> # 
> # dec20 <- load_variables(year = 2020, dataset = "pl")
> # total_population_20 <- get_decennial(
> #   geography = "state", 
> #   variables = "P1_001N",
> #   year = 2020
> # )
> 
> state_fixed <- "IA"
> utah_migration_19 <- get_flows(
+   geography = "county",
+   state = state_fixed,
+   year = 2019
+ )
Using FIPS code '19' for state 'IA'
> 
> utah_migration_20 <- get_flows(
+   geography = "county",
+   state = state_fixed,
+   year = 2020
+ )
Using FIPS code '19' for state 'IA'
> 
> utah_migration_21 <- get_flows(
+   geography = "county",
+   state = state_fixed,
+   year = 2021
+ )
Using FIPS code '19' for state 'IA'
> 
> utah_migration_22 <- get_flows(
+   geography = "county",
+   state = state_fixed,
+   year = 2022
+ )
Using FIPS code '19' for state 'IA'
> 
> utah_migration <- rbind(utah_migration_19 |> mutate(year = 2019), 
+                         utah_migration_20 |> mutate(year = 2020),
+                         utah_migration_21|> mutate(year = 2021),
+                         utah_migration_22|> mutate(year = 2022))
> 
> utah_population_20 <- get_decennial(
+   geography = "county", 
+   state=state_fixed,
+   variables = "P1_001N",
+   year = 2020,
+   geometry = TRUE
+ )
Getting data from the 2020 decennial Census
Downloading feature geometry from the Census website.  To cache shapefiles for use in future sessions, set `options(tigris_use_cache = TRUE)`.
Using FIPS code '19' for state 'IA'
Using the PL 94-171 Redistricting Data Summary File
> 
> library(tigris)
> 
> #ut_counties <- counties(state="UT")
> 
> #ut_counties |> ggplot() + geom_sf() + ggthemes::theme_map()
> 
> 
> ut_migrate <- utah_migration |> group_by(GEOID1, FULL1_NAME, year) |>
+   summarize(
+     move_in = sum(estimate[variable=="MOVEDIN"], na.rm=TRUE),
+     move_out = sum(estimate[variable=="MOVEDOUT"], na.rm=TRUE)
+   )
`summarise()` has regrouped the output.
ℹ Summaries were computed grouped by GEOID1, FULL1_NAME, and year.
ℹ Output is grouped by GEOID1 and FULL1_NAME.
ℹ Use `summarise(.groups = "drop_last")` to silence this message.
ℹ Use `summarise(.by = c(GEOID1, FULL1_NAME, year))` for per-operation grouping instead.
> 
> ut_migrate_plus <- utah_population_20 |>  left_join(ut_migrate, by=c("GEOID"="GEOID1"))
> ut_migrate_plus |>
+     ggplot(aes(fill = (move_in - move_out)/value*100)) + geom_sf() + 
+     ggthemes::theme_map() + 
+     scale_fill_gradient2("Percent Change") +
+     facet_grid(~year) + 
+     theme(legend.position = "bottom") +
+     ggtitle("Percent Change in Population")
> ut_migrate_plus |>
+   ggplot(aes(fill = (move_in - move_out))) + geom_sf() + 
+   ggthemes::theme_map() + 
+   scale_fill_gradient2("Change in Population") + 
+   facet_grid(~year) + 
+   theme(legend.position = "bottom") +
+   ggtitle("Change in Population")
> ut_migrate_plus |>
+     ggplot(aes(fill = (move_in - move_out))) + geom_sf() + 
+     ggthemes::theme_map() + 
+     scale_fill_gradient2("Change in Population") + 
+     facet_grid(~year) + 
+     theme(legend.position = "bottom") +
+     ggtitle("Change in Population")
> ut_migrate_plus |>
+     ggplot(aes(fill = (move_in - move_out)/value*100)) + geom_sf() + 
+     ggthemes::theme_map() + 
+     scale_fill_gradient2("Percent Change") +
+     facet_grid(~year) + 
+     theme(legend.position = "bottom") +
+     ggtitle("Percent Change in Population")
> utah_migration_21 <- get_flows(
+   geography = "county",
+   state = state_fixed,
+   year = 2021
+ )
Using FIPS code '19' for state 'IA'
> utah_migration_21
# A tibble: 5,229 × 7
   GEOID1 GEOID2 FULL1_NAME   FULL2_NAME variable estimate   moe
   <chr>  <chr>  <chr>        <chr>      <chr>       <dbl> <dbl>
 1 19001  08     Adair County Colorado   MOVEDIN        35    30
 2 19001  08     Adair County Colorado   MOVEDOUT       NA    NA
 3 19001  08     Adair County Colorado   MOVEDNET       NA    NA
 4 19001  12     Adair County Florida    MOVEDIN         4     7
 5 19001  12     Adair County Florida    MOVEDOUT       NA    NA
 6 19001  12     Adair County Florida    MOVEDNET       NA    NA
 7 19001  19     Adair County Iowa       MOVEDIN       391   117
 8 19001  19     Adair County Iowa       MOVEDOUT       NA    NA
 9 19001  19     Adair County Iowa       MOVEDNET       NA    NA
10 19001  27     Adair County Minnesota  MOVEDIN         4     5
# ℹ 5,219 more rows
# ℹ Use `print(n = ...)` to see more rows
> utah_migration_21 |> summary()
       GEOID1           GEOID2         FULL1_NAME       FULL2_NAME        variable   
 Length   :5229   Length   :5229   Length   :5229   Length   :5229   Length   :5229  
 N.unique :  99   N.unique :  59   N.unique :  99   N.unique :  61   N.unique :   3  
 N.blank  :   0   N.blank  :   0   N.blank  :   0   N.blank  :   0   N.blank  :   0  
 Min.nchar:   5   Min.nchar:   2   Min.nchar:  10   Min.nchar:   4   Min.nchar:   7  
 Max.nchar:   5   Max.nchar:   2   Max.nchar:  20   Max.nchar:  20   Max.nchar:   8  
                                                                                     
                                                                                     
    estimate            moe         
 Min.   :    1.0   Min.   :   2.00  
 1st Qu.:    6.0   1st Qu.:  10.00  
 Median :   17.0   Median :  23.00  
 Mean   :  114.3   Mean   :  54.48  
 3rd Qu.:   54.5   3rd Qu.:  55.50  
 Max.   :14468.0   Max.   :1184.00  
 NAs    :3486      NAs    :3486     
> utah_migration_21 |> pivot_wider(names_from = "variable", values_from="estimate")
# A tibble: 3,486 × 8
   GEOID1 GEOID2 FULL1_NAME   FULL2_NAME   moe MOVEDIN MOVEDOUT MOVEDNET
   <chr>  <chr>  <chr>        <chr>      <dbl>   <dbl>    <dbl>    <dbl>
 1 19001  08     Adair County Colorado      30      35       NA       NA
 2 19001  08     Adair County Colorado      NA      NA       NA       NA
 3 19001  12     Adair County Florida        7       4       NA       NA
 4 19001  12     Adair County Florida       NA      NA       NA       NA
 5 19001  19     Adair County Iowa         117     391       NA       NA
 6 19001  19     Adair County Iowa          NA      NA       NA       NA
 7 19001  27     Adair County Minnesota      5       4       NA       NA
 8 19001  27     Adair County Minnesota     NA      NA       NA       NA
 9 19001  29     Adair County Missouri       4       2       NA       NA
10 19001  29     Adair County Missouri      NA      NA       NA       NA
# ℹ 3,476 more rows
# ℹ Use `print(n = ...)` to see more rows
> utah_migration_21 |> pivot_wider(names_from = "variable", values_from="estimate") |> summary()
       GEOID1           GEOID2         FULL1_NAME       FULL2_NAME        moe         
 Length   :3486   Length   :3486   Length   :3486   Length   :3486   Min.   :   2.00  
 N.unique :  99   N.unique :  59   N.unique :  99   N.unique :  61   1st Qu.:  10.00  
 N.blank  :   0   N.blank  :   0   N.blank  :   0   N.blank  :   0   Median :  23.00  
 Min.nchar:   5   Min.nchar:   2   Min.nchar:  10   Min.nchar:   4   Mean   :  54.48  
 Max.nchar:   5   Max.nchar:   2   Max.nchar:  20   Max.nchar:  20   3rd Qu.:  55.50  
                                                                     Max.   :1184.00  
                                                                     NAs    :1743     
    MOVEDIN           MOVEDOUT       MOVEDNET   
 Min.   :    1.0   Min.   : NA    Min.   : NA   
 1st Qu.:    6.0   1st Qu.: NA    1st Qu.: NA   
 Median :   17.0   Median : NA    Median : NA   
 Mean   :  114.3   Mean   :NaN    Mean   :NaN   
 3rd Qu.:   54.5   3rd Qu.: NA    3rd Qu.: NA   
 Max.   :14468.0   Max.   : NA    Max.   : NA   
 NAs    :1743      NAs    :3486   NAs    :3486  
> stations <- read_fwf(
+   here::here("data/ghcnd-stations.txt"),
+   fwf_positions(
+     start = c(1, 13, 22, 32, 39, 42, 73, 77, 81),
+     end   = c(11, 20, 30, 37, 40, 71, 75, 79, 85),
+     col_names = c(
+       "ID",
+       "LATITUDE",
+       "LONGITUDE",
+       "ELEVATION",
+       "STATE",
+       "NAME",
+       "GSN_FLAG",
+       "HCN_CRN_FLAG",
+       "WMO_ID"
+     )
+   ),
+   col_types = cols(
+     ID         = col_character(),
+     LATITUDE   = col_double(),
+     LONGITUDE  = col_double(),
+     ELEVATION  = col_double(),
+     STATE      = col_character(),
+     NAME       = col_character(),
+     GSN_FLAG   = col_character(),
+     HCN_CRN_FLAG = col_character(),
+     WMO_ID     = col_character()
+   ),
+   trim_ws = TRUE
+ )
                                                                                         
> head(stations)
# A tibble: 6 × 9
  ID          LATITUDE LONGITUDE ELEVATION STATE NAME        GSN_FLAG HCN_CRN_FLAG WMO_ID
  <chr>          <dbl>     <dbl>     <dbl> <chr> <chr>       <chr>    <chr>        <chr> 
1 ACW00011604     17.1     -61.8      10.1 NA    ST JOHNS C… NA       NA           NA    
2 ACW00011647     17.1     -61.8      19.2 NA    ST JOHNS    NA       NA           NA    
3 AE000041196     25.3      55.5      34   NA    SHARJAH IN… GSN      NA           41196 
4 AEM00041194     25.3      55.4      10.4 NA    DUBAI INTL  NA       NA           41194 
5 AEM00041217     24.4      54.7      26.8 NA    ABU DHABI … NA       NA           41217 
6 AEM00041218     24.3      55.6     265.  NA    AL AIN INTL NA       NA           41218 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> #| echo: false
> #| message: false
> #| warning: false
> #| include: false
> #| label: setup
> library(ggplot2)
> library(tidyr)
> library(dplyr)
> library(purrr)
> library(gridExtra)
> library(magrittr)
> library(stringr)
> library(readr)
> library(ragg)
> library(scales)
> library(ggsci)
> library(datasauRus)
> theme_set(theme_bw())
> #| label: plots-4
> #| fig-height: 3
> #| fig-width: 3.3
> #| layout-ncol: 3
> #| echo: false
> #| fig-alt:
> #|   - "A blank plot with x-axis labeled class and y-axis labeled hwy"
> #|   - "A set of boxplots, one for each class of vehicle, showing the highway mpg of each class."
> #|   - "A set of boxplots on top of points showing the actual data for highway mpg for each class of vehicles."
> ggplot(data = mpg, aes(x = class, y = hwy)) +
+   labs(title = "")
> ggplot(data = mpg, aes(x = class, y = hwy)) +
+   geom_boxplot() +
+   labs(title = "+ geom_boxplot()")
> ggplot(data = mpg, aes(x = class, y = hwy)) +
+   geom_jitter() +
+   geom_boxplot() +
+   labs(title = "+ geom_jitter() + geom_boxplot()")
> #| echo: false
> #| layout-ncol: 2
> #| fig-width: 5
> #| fig-height: 5
> #| out-width: 80%
> ggplot(data = mpg, aes(x = cty, y = hwy, colour = class)) +
+   geom_text(aes(label = class)) +
+   scale_color_locuszoom() +
+   labs(x = "city mpg", y = "highway mpg", title = "Geom Text")
> ggplot(data = mpg, aes(x = cty, y = hwy, colour = class)) +
+   geom_point() +
+   scale_color_locuszoom() +
+   labs(x = "city mpg", y = "highway mpg", title = "Geom Point")
> #| fig-width: 5
> #| fig-height: 4
> #| layout-ncol: 3
> #| echo: false
> #| fig-alt:
> #|   - "A jittered dotplot of vehicle class (2 seater, compact, midsize, minivan, pickup, subcompact, suv) compared to highway mpg"
> #|   - "A violin plot of vehicle class (2 seater, compact, midsize, minivan, pickup, subcompact, suv) compared to highway mpg"
> #|   - "A jittered dotplot overlaid with a violin plot, showing  vehicle class (2 seater, compact, midsize, minivan, pickup, subcompact, suv) compared to highway mpg"
> ggplot(data = mpg, aes(x = class, y = hwy, colour = class)) +
+   geom_jitter(width = 0.1) +
+   scale_fill_locuszoom() +
+   scale_color_locuszoom() +
+   guides(color = "none")
> ggplot(data = mpg, aes(x = class, y = hwy, colour = class)) +
+   geom_violin(aes(fill = class), alpha = 0.4) +
+   scale_fill_locuszoom() +
+   scale_color_locuszoom() +
+   guides(fill = "none", color = "none")
> ggplot(data = mpg, aes(x = class, y = hwy, colour = class)) +
+   geom_jitter(width = 0.1) +
+   geom_violin(aes(fill = class), alpha = 0.4) +
+   scale_fill_locuszoom() +
+   scale_color_locuszoom() +
+   guides(fill = "none", color = "none")
> #| echo: true
> #| fig-height: 4
> #| fig-width: 8
> #| purl: true
> ggplot(data = mpg, aes(x = class, y = hwy)) +
+   geom_jitter() +
+   geom_boxplot()
> library(tibble)
> candy <- tribble(~candy, ~dem, ~ind, ~rep, 
+                  "Reese's", 29, 29, 28, 
+                  "Snickers", 13, 13, 9, 
+                  "M&Ms", 7, 5, 10, 
+                  "Kit Kat", 7, 12, 7, 
+                  "Candy Corn", 6, 6, 10, 
+                  "Chocolate bars", 7, 4, 5, 
+                  "Twix", 6, 3, 5, 
+                  "Milky Way", 5, 1, 6, 
+                  "Almond Joy", 4, 7, 5, 
+                  "Sour Patch Kids", 4, 5, 3, 
+                  "Skittles", 3, 1, 2, 
+                  "Starburst", 2, 2, 2, 
+                  "Twizzlers", 2, 0, 1, 
+                  "Raisinets", 1, 1, 1, 
+                  "Other", 4, 11, 6)
> candy_types <-  candy$candy
> candy_types_min <- c("Reese's", "Snickers", "Kit Kat", "Candy Corn", "M&Ms", "Other")
> 
> library(ggplot2)
> candy_sum <- candy |>
+   # Average over political orientation (weighted by % alignment)
+   mutate(overall = .27*dem + .46*ind + .27*rep) |>
+   # Sort in descending order by proportion
+   arrange(desc(overall)) |>
+   # Set bar order and create labels that are single-decimal values with % sign
+   mutate(candy = factor(candy, levels = candy_types, ordered = T),
+          label = sprintf("%0.1f%%", overall))
> 
> candy_short <- candy_sum |>
+   # Collapse so that we have only a reasonable number of categories
+   mutate(candy = str_replace_all(candy, "Raisinets|Twizzlers|Starburst|Skittles|Sour.Patch.Kids|Milky.Way|Almond.Joy|Chocolate.bars|Twix", "Other")) |>
+   group_by(candy) |>
+   # Calculate "Other" total proportion
+   summarize(overall = sum(overall)) |>
+   # Order of categories by size, with other at the end
+   mutate(candy = factor(candy, levels = candy_types_min, ordered = T)) |>
+   # Arrange the table in descending order
+   arrange(desc(candy)) |>
+   # Calculate label position as (everything to that point) + 1/2 of label value
+   mutate(pos = overall / 2 + lag(cumsum(overall), 1, default = 0),
+          label = sprintf("%s %0.1f%%", candy, overall))
> #| label: halloween-all
> #| echo: false
> #| eval: true
> #| fig-width: 4
> #| fig-height: 5
> #| fig-alt: "A bar chart showing the favorite types of Halloween Candy reported by americans. Reese's (28.7%), Snickers (11.9%), Kit Kat (8.4%), M&Ms (7.3%), Candy Corn (7.1%), Chocolate bars (5.7%), Almond Joy (5.1%), Twix (4.9%), Milky Way (4.2%), Sour Patch Kids (4.0%), Skittles (2.2%), Starburst (2.0%), Twizzlers (1.2%), Raisinets (1.0%), Other (6.4%)"
> #| echo: true
> 
> base_plot <- candy_short |>
+   ggplot(aes(x = candy, 
+              y = overall, 
+              label = label,
+              fill = candy, 
+              color = candy)) 
> 
> 
> labels <- list(ylab("Percent"),
+                xlab(""),
+                ggtitle("Favorite US Halloween Candy"),
+                guides(fill = "none", color = "none"))
> 
> stack_extras <- list(theme(panel.grid = element_blank(),
+                            axis.text.x = element_blank(),
+                            axis.title.x = element_blank(),
+                            axis.ticks.x = element_blank())) 
> 
> polar_extras <- list(theme(axis.text = element_blank(), 
+                            axis.title = element_blank(), 
+                            axis.ticks = element_blank(), 
+                            panel.grid = element_blank()))
> 
> #| echo: true
> 
> base_plot + 
+   geom_col() + 
+   labels
> 
> #| label: halloween-bar
> #| echo: false
> #| eval: true
> #| fig-width: 4
> #| fig-height: 5
> #| fig-alt: "A stacked bar chart showing the favorite types of Halloween Candy reported by americans. Other (36.1%), M&Ms (6.9%), Candy Corn (7.1%), Kit Kat (9.3%), Snickers (11.9%), Reese's (28.7%)"
> #| label: halloween-stacked-bar
> #| echo: false
> #| eval: true
> #| fig-width: 4
> #| fig-height: 5
> #| fig-alt: "A stacked bar chart showing the favorite types of Halloween Candy reported by americans. Other (36.1%), M&Ms (6.9%), Candy Corn (7.1%), Kit Kat (9.3%), Snickers (11.9%), Reese's (28.7%)"
> #| label: halloween-pie
> #| echo: false
> #| eval: true
> #| fig-width: 4
> #| fig-height: 5
> #| fig-alt: "A pie chart showing the favorite types of Halloween Candy reported by americans. Other (36.1%), M&Ms (6.9%), Candy Corn (7.1%), Kit Kat (9.3%), Snickers (11.9%), Reese's (28.7%)"
> #| label: halloween-pie2
> #| echo: false
> #| eval: true
> #| fig-width: 4
> #| fig-height: 5
> #| fig-alt: "A pie chart showing the favorite types of Halloween Candy reported by americans. Other (36.1%), M&Ms (6.9%), Candy Corn (7.1%), Kit Kat (9.3%), Snickers (11.9%), Reese's (28.7%)"
> library(ggplot2)
> mpg |> View()
> ?mpg
> mpg |> ggplot(aes(x = hwy, y = cty)) + 
+   geom_points()
Error in geom_points() : could not find function "geom_points"

> mpg |> ggplot(aes(x = hwy, y = cty)) + 
+   geom_point()
> mpg |> ggplot(aes(x = hwy, y = cty)) + 
+   geom_jitter()
> mpg |> ggplot(aes(x = hwy, y = cty, colour = fl)) + 
+   geom_jitter()
> mpg |> ggplot(aes(x = hwy, y = cty, colour = tr)) + 
+   geom_jitter()
Error in `geom_jitter()`:
! Problem while computing aesthetics.
ℹ Error occurred in the 1st layer.
Caused by error:
! object 'tr' not found
Run `rlang::last_trace()` to see where the error occurred.

> mpg |> ggplot(aes(x = hwy, y = cty, colour = trans)) + 
+   geom_jitter()
> mpg |> ggplot(aes(x = hwy, y = cty, label=model)) + 
+   geom_jitter()
> library(plotly)
> ggplotly()
> mpg |> ggplot(aes(x = hwy, y = cty, colour=class)) + 
+   geom_jitter()
> mpg |> ggplot(aes(x = hwy, y = cty, colour=class)) + 
+   geom_jitter() + facet_wrp(~class)
Error in facet_wrp(~class) : could not find function "facet_wrp"

> mpg |> ggplot(aes(x = hwy, y = cty, colour=class)) + 
+   geom_jitter() + facet_wrap(~class)
> mpg |> ggplot(aes(x = class, y = cty)) + 
+   geom_boxplot()
> mpg |> ggplot(aes(x = class, y = cty, fill=year)) + 
+   geom_boxplot()
Warning: The following aesthetics were dropped during
statistical transformation: fill.
ℹ This can happen when ggplot fails to infer the
  correct grouping structure in the data.
ℹ Did you forget to specify a `group` aesthetic or
  to convert a numerical variable into a factor?

> mpg |> ggplot(aes(x = class, y = cty, fill=factor(year))) + 
+   geom_boxplot()
> mpg |> ggplot(aes(x = class, y = hwy, fill=factor(year))) + 
+   geom_boxplot()
> mpg |> ggplot(aes(x = hwy, y = cty, colour = class)) + 
+   geom_jitter()
> install.packages("taylorR")
Warning: package ‘taylorR’ is not available for this version of R

A version of this package for your version of R might be available elsewhere,
see the ideas at
https://cran.r-project.org/doc/manuals/r-patched/R-admin.html#Installing-packages

> install.packages("taylorRswift")
Warning: package ‘taylorRswift’ is not available for this version of R

A version of this package for your version of R might be available elsewhere,
see the ideas at
https://cran.r-project.org/doc/manuals/r-patched/R-admin.html#Installing-packages

> install.packages("tayloRswift")
trying URL 'https://cran.rstudio.com/bin/macosx/big-sur-x86_64/contrib/4.6/tayloRswift_0.1.0.tgz'
Content type 'application/x-gzip' length 309939 bytes (302 KB)
==================================================
downloaded 302 KB


The downloaded binary packages are in
	/var/folders/1x/tvy5cf5j4glg4_6g8cxvrcbm7qbgrn/T//RtmprBvvRq/downloaded_packages
> library(help=tayloRswift)
> library(tayloRswift)
> mpg |> ggplot(aes(x = hwy, y = cty, colour = class)) + 
+   geom_jitter() +scale_color_taylor()
> mpg |> ggplot(aes(x = hwy, y = cty, colour = class)) + 
+   geom_jitter() +scale_color_taylor()
> swift_palettes
$taylorSwift
[1] "#61b6cc" "#577f3f" "#e3e9f3" "#0a1605"
[5] "#fddac7" "#81a757"

$fearless
[1] "#b68f51" "#5b3617" "#f7eabe" "#ecd59f"
[5] "#825c2d"

$speakNow
[1] "#4b2671" "#5e291c" "#f3d8c4" "#f3bf73"
[5] "#ffffff"

$speakNowLive
[1] "#fce178" "#969696" "#871d20" "#090708"
[5] "#fafaf9"

$Red
[1] "#c2c2ae" "#26233b" "#7f6557" "#b4a382"
[5] "#eeeadf"

$taylorRed
[1] "#BFBCAA" "#A6836F" "#73564C" "#731803"
[5] "#400303"

$taylor1989
[1] "#b1532a" "#84697f" "#cbb593" "#a88f92"
[5] "#e8eadf" "#43475b"

$reputation
[1] "#060606" "#6e6e6e" "#fefefe" "#cacaca"
[5] "#060606" "#8c8c8c"

$lover
[1] "#b8396b" "#ffd1d7" "#fff5cc" "#76bae0"
[5] "#b28f81" "#54483e"

$folklore
[1] "#272727" "#5c5c5c" "#bababa" "#f8f8f8"

$evermore
[1] "#efefef" "#827d73" "#3d2620" "#e89264"
[5] "#474247"

> mpg |> ggplot(aes(x = hwy, y = cty, colour = class)) + 
  +   geom_jitter() +scale_color_viridis_d()
> mpg |> ggplot(aes(x = hwy, y = cty, colour = class)) + 
  +   geom_jitter() +scale_color_locuszoom()
> mpg |> ggplot(aes(x = hwy, y = cty, colour = class)) + 
  +   geom_jitter() +scale_color_manual(values=("red","darkred", "darkgreen", "orange", "forestgreen"))
Error: unexpected ',' in:
  "mpg |> ggplot(aes(x = hwy, y = cty, colour = class)) + 
  geom_jitter() +scale_color_manual(values=("red","

> mpg |> ggplot(aes(x = hwy, y = cty, colour = class)) + 
  +   geom_jitter() +scale_color_manual(values=c("red","darkred", "darkgreen", "orange", "forestgreen"))
Error in `palette()`:
  ! Insufficient values in manual scale. 7
needed but only 5 provided.
Run `rlang::last_trace()` to see where the error occurred.

> mpg |> ggplot(aes(x = hwy, y = cty, colour = class)) + 
  +   geom_jitter() +scale_color_manual(values=c("red","maroon", "chartreuse", "darkred", "darkgreen", "orange", "forestgreen"))
> colors()
[1] "white"                "aliceblue"           
[3] "antiquewhite"         "antiquewhite1"       
[5] "antiquewhite2"        "antiquewhite3"       
[7] "antiquewhite4"        "aquamarine"          
[9] "aquamarine1"          "aquamarine2"         
[11] "aquamarine3"          "aquamarine4"         
[13] "azure"                "azure1"              
[15] "azure2"               "azure3"              
[17] "azure4"               "beige"               
[19] "bisque"               "bisque1"             
[21] "bisque2"              "bisque3"             
[23] "bisque4"              "black"               
[25] "blanchedalmond"       "blue"                
[27] "blue1"                "blue2"               
[29] "blue3"                "blue4"               
[31] "blueviolet"           "brown"               
[33] "brown1"               "brown2"              
[35] "brown3"               "brown4"              
[37] "burlywood"            "burlywood1"          
[39] "burlywood2"           "burlywood3"          
[41] "burlywood4"           "cadetblue"           
[43] "cadetblue1"           "cadetblue2"          
[45] "cadetblue3"           "cadetblue4"          
[47] "chartreuse"           "chartreuse1"         
[49] "chartreuse2"          "chartreuse3"         
[51] "chartreuse4"          "chocolate"           
[53] "chocolate1"           "chocolate2"          
[55] "chocolate3"           "chocolate4"          
[57] "coral"                "coral1"              
[59] "coral2"               "coral3"              
[61] "coral4"               "cornflowerblue"      
[63] "cornsilk"             "cornsilk1"           
[65] "cornsilk2"            "cornsilk3"           
[67] "cornsilk4"            "cyan"                
[69] "cyan1"                "cyan2"               
[71] "cyan3"                "cyan4"               
[73] "darkblue"             "darkcyan"            
[75] "darkgoldenrod"        "darkgoldenrod1"      
[77] "darkgoldenrod2"       "darkgoldenrod3"      
[79] "darkgoldenrod4"       "darkgray"            
[81] "darkgreen"            "darkgrey"            
[83] "darkkhaki"            "darkmagenta"         
[85] "darkolivegreen"       "darkolivegreen1"     
[87] "darkolivegreen2"      "darkolivegreen3"     
[89] "darkolivegreen4"      "darkorange"          
[91] "darkorange1"          "darkorange2"         
[93] "darkorange3"          "darkorange4"         
[95] "darkorchid"           "darkorchid1"         
[97] "darkorchid2"          "darkorchid3"         
[99] "darkorchid4"          "darkred"             
[101] "darksalmon"           "darkseagreen"        
[103] "darkseagreen1"        "darkseagreen2"       
[105] "darkseagreen3"        "darkseagreen4"       
[107] "darkslateblue"        "darkslategray"       
[109] "darkslategray1"       "darkslategray2"      
[111] "darkslategray3"       "darkslategray4"      
[113] "darkslategrey"        "darkturquoise"       
[115] "darkviolet"           "deeppink"            
[117] "deeppink1"            "deeppink2"           
[119] "deeppink3"            "deeppink4"           
[121] "deepskyblue"          "deepskyblue1"        
[123] "deepskyblue2"         "deepskyblue3"        
[125] "deepskyblue4"         "dimgray"             
[127] "dimgrey"              "dodgerblue"          
[129] "dodgerblue1"          "dodgerblue2"         
[131] "dodgerblue3"          "dodgerblue4"         
[133] "firebrick"            "firebrick1"          
[135] "firebrick2"           "firebrick3"          
[137] "firebrick4"           "floralwhite"         
[139] "forestgreen"          "gainsboro"           
[141] "ghostwhite"           "gold"                
[143] "gold1"                "gold2"               
[145] "gold3"                "gold4"               
[147] "goldenrod"            "goldenrod1"          
[149] "goldenrod2"           "goldenrod3"          
[151] "goldenrod4"           "gray"                
[153] "gray0"                "gray1"               
[155] "gray2"                "gray3"               
[157] "gray4"                "gray5"               
[159] "gray6"                "gray7"               
[161] "gray8"                "gray9"               
[163] "gray10"               "gray11"              
[165] "gray12"               "gray13"              
[167] "gray14"               "gray15"              
[169] "gray16"               "gray17"              
[171] "gray18"               "gray19"              
[173] "gray20"               "gray21"              
[175] "gray22"               "gray23"              
[177] "gray24"               "gray25"              
[179] "gray26"               "gray27"              
[181] "gray28"               "gray29"              
[183] "gray30"               "gray31"              
[185] "gray32"               "gray33"              
[187] "gray34"               "gray35"              
[189] "gray36"               "gray37"              
[191] "gray38"               "gray39"              
[193] "gray40"               "gray41"              
[195] "gray42"               "gray43"              
[197] "gray44"               "gray45"              
[199] "gray46"               "gray47"              
[201] "gray48"               "gray49"              
[203] "gray50"               "gray51"              
[205] "gray52"               "gray53"              
[207] "gray54"               "gray55"              
[209] "gray56"               "gray57"              
[211] "gray58"               "gray59"              
[213] "gray60"               "gray61"              
[215] "gray62"               "gray63"              
[217] "gray64"               "gray65"              
[219] "gray66"               "gray67"              
[221] "gray68"               "gray69"              
[223] "gray70"               "gray71"              
[225] "gray72"               "gray73"              
[227] "gray74"               "gray75"              
[229] "gray76"               "gray77"              
[231] "gray78"               "gray79"              
[233] "gray80"               "gray81"              
[235] "gray82"               "gray83"              
[237] "gray84"               "gray85"              
[239] "gray86"               "gray87"              
[241] "gray88"               "gray89"              
[243] "gray90"               "gray91"              
[245] "gray92"               "gray93"              
[247] "gray94"               "gray95"              
[249] "gray96"               "gray97"              
[251] "gray98"               "gray99"              
[253] "gray100"              "green"               
[255] "green1"               "green2"              
[257] "green3"               "green4"              
[259] "greenyellow"          "grey"                
[261] "grey0"                "grey1"               
[263] "grey2"                "grey3"               
[265] "grey4"                "grey5"               
[267] "grey6"                "grey7"               
[269] "grey8"                "grey9"               
[271] "grey10"               "grey11"              
[273] "grey12"               "grey13"              
[275] "grey14"               "grey15"              
[277] "grey16"               "grey17"              
[279] "grey18"               "grey19"              
[281] "grey20"               "grey21"              
[283] "grey22"               "grey23"              
[285] "grey24"               "grey25"              
[287] "grey26"               "grey27"              
[289] "grey28"               "grey29"              
[291] "grey30"               "grey31"              
[293] "grey32"               "grey33"              
[295] "grey34"               "grey35"              
[297] "grey36"               "grey37"              
[299] "grey38"               "grey39"              
[301] "grey40"               "grey41"              
[303] "grey42"               "grey43"              
[305] "grey44"               "grey45"              
[307] "grey46"               "grey47"              
[309] "grey48"               "grey49"              
[311] "grey50"               "grey51"              
[313] "grey52"               "grey53"              
[315] "grey54"               "grey55"              
[317] "grey56"               "grey57"              
[319] "grey58"               "grey59"              
[321] "grey60"               "grey61"              
[323] "grey62"               "grey63"              
[325] "grey64"               "grey65"              
[327] "grey66"               "grey67"              
[329] "grey68"               "grey69"              
[331] "grey70"               "grey71"              
[333] "grey72"               "grey73"              
[335] "grey74"               "grey75"              
[337] "grey76"               "grey77"              
[339] "grey78"               "grey79"              
[341] "grey80"               "grey81"              
[343] "grey82"               "grey83"              
[345] "grey84"               "grey85"              
[347] "grey86"               "grey87"              
[349] "grey88"               "grey89"              
[351] "grey90"               "grey91"              
[353] "grey92"               "grey93"              
[355] "grey94"               "grey95"              
[357] "grey96"               "grey97"              
[359] "grey98"               "grey99"              
[361] "grey100"              "honeydew"            
[363] "honeydew1"            "honeydew2"           
[365] "honeydew3"            "honeydew4"           
[367] "hotpink"              "hotpink1"            
[369] "hotpink2"             "hotpink3"            
[371] "hotpink4"             "indianred"           
[373] "indianred1"           "indianred2"          
[375] "indianred3"           "indianred4"          
[377] "ivory"                "ivory1"              
[379] "ivory2"               "ivory3"              
[381] "ivory4"               "khaki"               
[383] "khaki1"               "khaki2"              
[385] "khaki3"               "khaki4"              
[387] "lavender"             "lavenderblush"       
[389] "lavenderblush1"       "lavenderblush2"      
[391] "lavenderblush3"       "lavenderblush4"      
[393] "lawngreen"            "lemonchiffon"        
[395] "lemonchiffon1"        "lemonchiffon2"       
[397] "lemonchiffon3"        "lemonchiffon4"       
[399] "lightblue"            "lightblue1"          
[401] "lightblue2"           "lightblue3"          
[403] "lightblue4"           "lightcoral"          
[405] "lightcyan"            "lightcyan1"          
[407] "lightcyan2"           "lightcyan3"          
[409] "lightcyan4"           "lightgoldenrod"      
[411] "lightgoldenrod1"      "lightgoldenrod2"     
[413] "lightgoldenrod3"      "lightgoldenrod4"     
[415] "lightgoldenrodyellow" "lightgray"           
[417] "lightgreen"           "lightgrey"           
[419] "lightpink"            "lightpink1"          
[421] "lightpink2"           "lightpink3"          
[423] "lightpink4"           "lightsalmon"         
[425] "lightsalmon1"         "lightsalmon2"        
[427] "lightsalmon3"         "lightsalmon4"        
[429] "lightseagreen"        "lightskyblue"        
[431] "lightskyblue1"        "lightskyblue2"       
[433] "lightskyblue3"        "lightskyblue4"       
[435] "lightslateblue"       "lightslategray"      
[437] "lightslategrey"       "lightsteelblue"      
[439] "lightsteelblue1"      "lightsteelblue2"     
[441] "lightsteelblue3"      "lightsteelblue4"     
[443] "lightyellow"          "lightyellow1"        
[445] "lightyellow2"         "lightyellow3"        
[447] "lightyellow4"         "limegreen"           
[449] "linen"                "magenta"             
[451] "magenta1"             "magenta2"            
[453] "magenta3"             "magenta4"            
[455] "maroon"               "maroon1"             
[457] "maroon2"              "maroon3"             
[459] "maroon4"              "mediumaquamarine"    
[461] "mediumblue"           "mediumorchid"        
[463] "mediumorchid1"        "mediumorchid2"       
[465] "mediumorchid3"        "mediumorchid4"       
[467] "mediumpurple"         "mediumpurple1"       
[469] "mediumpurple2"        "mediumpurple3"       
[471] "mediumpurple4"        "mediumseagreen"      
[473] "mediumslateblue"      "mediumspringgreen"   
[475] "mediumturquoise"      "mediumvioletred"     
[477] "midnightblue"         "mintcream"           
[479] "mistyrose"            "mistyrose1"          
[481] "mistyrose2"           "mistyrose3"          
[483] "mistyrose4"           "moccasin"            
[485] "navajowhite"          "navajowhite1"        
[487] "navajowhite2"         "navajowhite3"        
[489] "navajowhite4"         "navy"                
[491] "navyblue"             "oldlace"             
[493] "olivedrab"            "olivedrab1"          
[495] "olivedrab2"           "olivedrab3"          
[497] "olivedrab4"           "orange"              
[499] "orange1"              "orange2"             
[501] "orange3"              "orange4"             
[503] "orangered"            "orangered1"          
[505] "orangered2"           "orangered3"          
[507] "orangered4"           "orchid"              
[509] "orchid1"              "orchid2"             
[511] "orchid3"              "orchid4"             
[513] "palegoldenrod"        "palegreen"           
[515] "palegreen1"           "palegreen2"          
[517] "palegreen3"           "palegreen4"          
[519] "paleturquoise"        "paleturquoise1"      
[521] "paleturquoise2"       "paleturquoise3"      
[523] "paleturquoise4"       "palevioletred"       
[525] "palevioletred1"       "palevioletred2"      
[527] "palevioletred3"       "palevioletred4"      
[529] "papayawhip"           "peachpuff"           
[531] "peachpuff1"           "peachpuff2"          
[533] "peachpuff3"           "peachpuff4"          
[535] "peru"                 "pink"                
[537] "pink1"                "pink2"               
[539] "pink3"                "pink4"               
[541] "plum"                 "plum1"               
[543] "plum2"                "plum3"               
[545] "plum4"                "powderblue"          
[547] "purple"               "purple1"             
[549] "purple2"              "purple3"             
[551] "purple4"              "red"                 
[553] "red1"                 "red2"                
[555] "red3"                 "red4"                
[557] "rosybrown"            "rosybrown1"          
[559] "rosybrown2"           "rosybrown3"          
[561] "rosybrown4"           "royalblue"           
[563] "royalblue1"           "royalblue2"          
[565] "royalblue3"           "royalblue4"          
[567] "saddlebrown"          "salmon"              
[569] "salmon1"              "salmon2"             
[571] "salmon3"              "salmon4"             
[573] "sandybrown"           "seagreen"            
[575] "seagreen1"            "seagreen2"           
[577] "seagreen3"            "seagreen4"           
[579] "seashell"             "seashell1"           
[581] "seashell2"            "seashell3"           
[583] "seashell4"            "sienna"              
[585] "sienna1"              "sienna2"             
[587] "sienna3"              "sienna4"             
[589] "skyblue"              "skyblue1"            
[591] "skyblue2"             "skyblue3"            
[593] "skyblue4"             "slateblue"           
[595] "slateblue1"           "slateblue2"          
[597] "slateblue3"           "slateblue4"          
[599] "slategray"            "slategray1"          
[601] "slategray2"           "slategray3"          
[603] "slategray4"           "slategrey"           
[605] "snow"                 "snow1"               
[607] "snow2"                "snow3"               
[609] "snow4"                "springgreen"         
[611] "springgreen1"         "springgreen2"        
[613] "springgreen3"         "springgreen4"        
[615] "steelblue"            "steelblue1"          
[617] "steelblue2"           "steelblue3"          
[619] "steelblue4"           "tan"                 
[621] "tan1"                 "tan2"                
[623] "tan3"                 "tan4"                
[625] "thistle"              "thistle1"            
[627] "thistle2"             "thistle3"            
[629] "thistle4"             "tomato"              
[631] "tomato1"              "tomato2"             
[633] "tomato3"              "tomato4"             
[635] "turquoise"            "turquoise1"          
[637] "turquoise2"           "turquoise3"          
[639] "turquoise4"           "violet"              
[641] "violetred"            "violetred1"          
[643] "violetred2"           "violetred3"          
[645] "violetred4"           "wheat"               
[647] "wheat1"               "wheat2"              
[649] "wheat3"               "wheat4"              
[651] "whitesmoke"           "yellow"              
[653] "yellow1"              "yellow2"             
[655] "yellow3"              "yellow4"             
[657] "yellowgreen"


"#123456" "#ff0000" "#00ff00" 

