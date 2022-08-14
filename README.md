## Holier than Thou: Partisan Gap in Consumption of Adult Content

Both the parties claim the higher ground when it comes to women--- one's case for morality is steepled in religion, another's in enduring concern for women. Using passively collected browsing data from 1200 respondents, we test whether Republicans consume more pornography than Democrats. 

### Analysis

#### Measuring Porn

1. Measure domain level porn using the model (piedomains and pydomains) and using default output from YG. Keyword classifier using just domain names + tld gives 82\%.
2. Validation: Look up top 10 porn sites and make sure they are in every list. This is assuming that there is a sharp skew.

#### Outcome Variables

1. Total time spent on porn sites 
2. Total number of visits to porn sites
3. Proportion of time spent on porn sites
4. Proportion of visits to porn sites 
5. What kind of porn

#### Outputs

1. Distributions of 1, 2, 3 and 4
2. When is porn consumed (night or day, weekday/weekend)?
3. Split by party, region/state, etc. and show the density plot. Plus tables --- old + poisson/quantile regression, given skew---though proportions should be reasonably behaved as DVs.

### Future

* Build a ML model to predict PID + sociodem. (categorized the same way as comScore) from domain visits, etc. 
	- comScore data: Use the Flaxman, Goel strategy of calling Republicans who consume more R than D and vice-versa and doing analysis. We can eventually scale the users' ideology using consumption of news.
* Use it to extend the analysis to comScore data
* Appendix table comparing means of critical variables to population (CPS, ANES etc.) (will add weighted col. later) 
	* age (split in few cats - 3-4), education (split in few cats - 3-4), gender, marital status (again 3-4 cats), census region, urban, rural 
		* depending on the extent of concern, we can also compare demographics by party (DONE -AG)
* Post-stratify

### Authors

Lucas Shen and Gaurav Sood
