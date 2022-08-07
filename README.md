## Holier than Thou: Partisan Gap in Consumption of Adult Content


Both the parties claim the higher ground --- one's case for morality steepled in religion, another's in enduring concern for women. 

#### Measuring Porn

1. Add multiple columns to the survey file, each matching a diff. source. For instance, we have data from Wakoopa, shalla, and then third would be a model. For shalla and Wakoopa, only output unique_porn_domains. And then use 'match' to add these columns.

2. We should look up top 10 porn sites and make sure they are in every list. So it should be shalla + top 10 or Wakoopa + top 10.

3. Keyword classifier using just domain names + tld gives 82\%. If we keep the template the same but add data on keyword features from text, it should work great.

### Analysis

* Density/box-plots of porn consumption by party, by religiosity, by region/state? -- can we mimic the patterns that were obtained by the previous papers? 

**Interpretation of #s:**

1. Depends on distribution 
2. If no info. on amount of time: Get correlation(frequency, time spent) via comScore for porno, plot, make some estimates
3. What kind of porn
I think we can have three dependent variables:
1. total time spent on porn sites 
2. porn_visits
3. total_time_on_porn/total_time_on_internet
4. visits_to_porn/total_visits

We should start with population estimates detailing fun things:
1. When is porn consumed (night or day) --- in fact give people fun estimates of across the day
2. Base numbers about 1,2,3 and 4
3. Skew in porn consumption. Most recently, it is said pornhub and I think a couple more sites cover a large chunk. This is the same old power law of consumption on Internet. We can even post the distribution of visitation. Cite Hindman.
4. Split by party, controlling for the usual and perhaps something like density plots by R and D and also perhaps quantile regression, given skew, though proportions should be reasonably behaved as DVs.

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
