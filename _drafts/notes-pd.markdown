---
layout: "post"
title: "notes.pd"
date: "2022-06-02 06:27"
---
# ETL
## Ynab

## Discover
### What
  - I want import discover data from downloaded files into my database.
  - I also need to verify the data I loaded from Ynab
    - It did not sum correctly I think I may be missing and entry or two
### How
  - I have manually download csv files into etl/discover
  - I have started an etl that reads the files and attempts to select the best category for each entry.
  - Download all the discover statement for 2021 and 2022
  - Create a model for the discover data
  - Write a class to Download the data as is except for negating the amounts into the DB
  - Write a class to verify Sums by statement period
