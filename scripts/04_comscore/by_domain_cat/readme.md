Calculate consumption of domains belonging to a particular category in ComScore Data
-------------------------------------------------------------------------------------

The script takes 4 arguments:

1. INTERNET_USAGE_FILE: path to comScore data file sorted by machine_id alone
2. URL_CATEGORY_FILE: path to [url category file](url_category.csv)
3. CATEGORY: pre-specified category. For instance, `CATEGORY = "Pornography"`
4. FINAL_OUTPUT_FILE: name of output file

You can also optionally pass the header column in the output file via `FINAL_OUTPUT_HEADER`.

The script produces a csv with each row carrying usage by a machine_id for a particular date and the columns being:

1. machine_id 
2. date
3. total_pages_viewed: total number of pages viewed
4. total_time_spent: total time spent
5. total_domain_category_pages_viewed: total number of pages of domains belonging to a particular category viewed
6. total_domain_category_time_spent: total time spent viewing pages of domains belonging to a particular category