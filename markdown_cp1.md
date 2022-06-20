---
title: "Activity monitoring data - CP1"
author: "Oscar Nieto G"
date: '2022-06-20'
output: 
  html_document: 
    keep_md: yes
---





## Load and process the data

First, the data set was loaded and processed.


Table: First ten rows of the data set

| steps |    date    | interval |
|:-----:|:----------:|:--------:|
|  NA   | 2012-10-01 |    0     |
|  NA   | 2012-10-01 |    5     |
|  NA   | 2012-10-01 |    10    |
|  NA   | 2012-10-01 |    15    |
|  NA   | 2012-10-01 |    20    |
|  NA   | 2012-10-01 |    25    |
|  NA   | 2012-10-01 |    30    |
|  NA   | 2012-10-01 |    35    |
|  NA   | 2012-10-01 |    40    |
|  NA   | 2012-10-01 |    45    |

## Number of steps taken per day

The distribution of the total number of steps by day is described on the following histogram:

<img src="markdown_cp1_files/figure-html/unnamed-chunk-3-1.png" style="display: block; margin: auto;" />



The mean of the total number of steps taken per day is **9354**, while the median is **10395**.

## Average daily activity pattern

The daily activity pattern of the average number of steps taken, averaged across all days is presented on the following graph.

<img src="markdown_cp1_files/figure-html/unnamed-chunk-5-1.png" style="display: block; margin: auto;" />

On average, the 5-minute interval with the maximum number of steps is **835** with **206.17** steps.

## Imputing missing values



The presence of missing days may introduce bias into some calculations or summaries of the data. For that reason, it is important to fill this missing values, according to the data that is available.

In this case, the number of missing values (coded as NA) is **2304**.

Since we have many values per 5-minute interval, we can use the median of the measures values to imputing the missing values on the same 5-minutes interval. We can see that by filling this values, there are some changes on the distribution of the number of steps, increasing some the number of observations in some lower range of the number of steps taken by day, increasing the mean but maintaining the median.

<img src="markdown_cp1_files/figure-html/unnamed-chunk-7-1.png" style="display: block; margin: auto;" />

The mean of the total number of steps taken per day is **9504**, while the median is **10395**.

## Activity patterns between weekdays and weekends

It is also analyzed the difference in the activity pattern between weekdays and weekends, creating a new variable in the data set that allows to create individual plots for each period.

<img src="markdown_cp1_files/figure-html/unnamed-chunk-8-1.png" style="display: block; margin: auto;" />
