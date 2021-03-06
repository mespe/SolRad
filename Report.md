##Running report

17 May
------

 - Priority:
   - Focus on completing analysis before end of quarter.
   - If possible, look into Docker, but not at the cost of delaying
     the results

 - We are going to start modeling the data using different techniques.
   - Need to think about how to compare the different models to
     eachother.
   - 

10 May
-------



3 May
-------

Solar radiation files: 
 - atm_sf: at top of atmosphere, short wave
 - ground_atm: mistake - deleted
 - res_ground_sf: Shortwave flux at ground level 

26 April
-------

Talked about steps forward - The solar radiation data is looking
really nice. Good differentiation between atmospheric and ground -
good job guys. 

We need to start thinking about the analysis - first step is to get
the data in a format that allows for modeling. Matt has this, just
needs to alter the code to handle solar radiation. Next week will be a
working meeting - we want to start building some models.

We still need to get the optical aerosol depth data - should not be
too difficult, but might require downloading a raster, and then
extracting the pixel of interest.

Lastly, we talked about setting this project up for
reproducibility. Matt talked about flagging file dependencies so we
can build a Makefile to control the building of the project from data
recovery to the final report. We also talked about using Docker to
handle dependencies. As companies want people with Docker and AWS experience,
we will look into it. 

19 April

-------

Not much was done last week:

- Solar radiation: Lumin thinks that we haven't been pulling data from one of our solar radation data sources correctly. He is going to look into this this week. Once he is satisfied with the data he is getting from this source, the team working from this data source will continue.

- Yield/Modeling: Nothing was done on this last week. Since Scott and Henry are available again, this part of the project should starting moving soon.

12 April
-------

Welcome back - 

We briefly chatted about what ground we have covered so far, including
some issues with using the State Average yields. Overall, it seems
using the State average is challenging because it only is 24 data
points, which makes it difficult to use.

We agreed to use the variety trial data for the Rice Experiment
Station to go forward, as this has roughly 8K obs., which should be
enough to actually test some of our questions. We are leaving open the
possibility to use the full data set (30K obs), but this opens up a
lot of complexities due to the different sites, etc.




23 March
--------

Low attendance due to confusion about meeting.

No meeting next week (Spring break)

Covariates on yield: Retrieved many covariates on yield, started some
basic analysis using linear regression. There are some unexpected
relationships which we need to check into. 

It would be good to be ready to jump into analysis the week following
Spring break (~ 3 - 6 Apr). Right now, we are close to being able to
do this, but using State average yields and average of CIMIS data for
temp and solar radiation. Designing such that future changes to these
data can be easily integrated.

Need update on the CFSR work. 

16 March
---------

CFSR: Downward shortwave (before clouds), clearsky downward shortwave
flux (after clouds). 

Big questions:
 - can we get a measure of our quantity of interest? 
 - Understand bias, disagreements between CIMIS.
 
 

CIMIS: Arizona time zone (no DST)

9 March 2017
-----

CARB: We only have weekly measurements for PM10, but there are not
large differences between years (roughly equal number of measurements
per year).
 
Yield:

Solar Radiation: Clear sky vs CIMIS - overall, the trends match fairly
well between the Clear sky vs observed. Look at data form 1980-2010,
see what relationship exists between the before atm and ground
flux. Depending on results (e.g., there are trends and etc.), we can
go forward  with these data. CFSv2 has data from 2010 -
today. Redundent info - use both CFSR and CIMIS

Look at data on smoke and dust [ MATT ]



2 March 2017
-----

More exploration of the CARB data (see CARB_perm.R):

 - Comparing the values for the weekly data (1999-2006) to the
   daily-ish values (2007-2015), it seems the weekly values are on
   average similar, but have fewer extreme values. This makes sense if
   we expect a 1/7 chance for observations to coincide with a high
   polution day. Henry brought up a good point that we should check
   the day of the week which is sampled, as there might be some trends
   within a week.
 - The mean is more highly affected by this compared to the median,
   but we might be interested in the extreme values.
 - Need to explore if the same trends observed in the PM2.5 data are
   similar in the PM10 data.

Solar radiation:
 - Plotting the solar by year shows some variation (see explore.R),
 within and between years. We need to understand this a bit better.
	 1. Compare to other stations, see if trends are seen in nearby
        areas.
	 2. Compare to clear-sky values (solar radiation without
        interception from clouds/pollution, etc). See if trends have
        anything to do with air conditions vs natural variation from
        sun.
	 3. Figure out how to fill in missing data
 
Yield:
 - State average yield with the week # of emergence (start) and
   harvest (end) have been added to github. Need to combine with solar
   radiation data and start exploring possible relationships.
   
   

23 Feb 2017
-----

Inspected the CARB data:

 - There are far more missing days for the data between
   1999-2006. After 2006, the missing days is much reduced. However,
   the two periods seem to be similar (see exploration/CARB.R).
	  - We will test this, and if the missingness does not have a large
      impact on the results of the data, we will move forward with
      using these data. This restricts our period of analysis for air
      quality -> solar radiation to 1999-2016.
 
 - We are planning to meet next week to so some permutation tests on
   the missingness in the CARB data - We will use the more complete
   data to estimate the impact of missing data. Look for email from
   Matt setting this up for next week (Feb 28-ish)
   
CIMIS/USDA data:

 - We are going to push forward on collecting solar radiation and
   yield data together so we can start plotting/analysis. 
   - use solar radiation data from Colusa CIMIS station as a proxy for
     the whole rice area (it is approx. central).
   - use state average yield data
   
 - We will keep open the option to use finer scale data (county level estimates), but for now
   will start looking at the big picture/simple.
 - For now use the average date of emergence, harvest for analysis.
   


15 Feb 2017
-----

We can break the project into two pieces/questions:

1. Is there a relationship between yield and solar radiation?
2. If #1, what is driving variability in solar radiation? Is
   variability natural or human driven?
   
   
Current status:

CARB data needs attention - What is the coverage? Do we have enough
data to address our questions. There is only data starting 1998, many
stations do not actually record data. Of the stations that do, only
report every 6 d. 

CFSR data - some questions: Why are there differences between CIMIS
and CFSR? Is it OK to use this data even though it only goes
to 2010. Do we gain additional useful info from separating the
different bands. 

Backup plan: Possibily use airport visibility as a proxy. 

How do we deal with missing data - differs by variable. Need to
record. Gap-filling vs dropping. Needs to be robust to different
methods. 





PM25 and PM10 files (Air quality)

We went through PM25 and PM10 files and found the following results.

PM25:

- They have (every 6 day) data starting from 1998 to 2014
- They have hourly data starting from 2012 to 2014
- They have data only for one Site in Colusa County

PM10:

- They have (every 6 day) data starting from 1998 to 2014 only one Colusa Site
- They have hourly data starting from 2013 to 2014 (NO data for Colusa Sites)

Although in the “Location.xlsx” file Colusa has 6 Sites, only 3 of them collected data. 
The rest did not have any ozone, pm25, or pm10 data.


9 Feb 2017
-----

Updates on CFSR:
	- Includes more variables:
	  - CIMIS does not include reflected solar radiation from clouds, soil,
        etc.
	  - Covers 1979 -- 2010: Grid system reanalysis of historical data.
	  - Only includes solar radiation.
	  - Includes total clear sky downward flux
		- reflection might be important with pollution - can directly
          compare with air pollution values
	  - 
	  
Current status:
	- USDA: returns all character vectors, need to munge data into
      useable form
	- CARB: 
		 - 6 sites originally, dropping NAs left only 3 sites, 
		 - also looked at CH4, 
		 - SO2, H2S have no data for colusa county
		 - Currently have 1980-2014 daily average for ozone.
		 - Need to save meta data for future reference
	- How do we go from daily/hourly to seasonal?
		- Do we weight only daylight hours?
		- take average, median, etc.
		- which pollutants will be handled which way.
		  - solar-radiation: sum over day/week/season
		  - ozone: daily average vs. max? Look into this more
		  - PM2.5/10: look at average for daylight hours and daily
		  - NOx, SO2, H2S?
		  
	  

2 Feb 2017
------

Updates from last week:

	- Rcimis package created: Please code review, test, etc.
	- Code written for USDA: 
	- Some web-scrapping done to recover CARB data for 2015--2016
	
CIMIS Data:
	- Only a few relevant vars: Solar rad., temp
	- Downloaded by hand (Durham)  
	- Get ETO - available energy: Check if it correlates with yield
	
CFSR data:
	- reanalysis data: between modeled and observed
	- 6 hour intervals back to 1980's-2010
	- Downloaded in 5d intervals: ftp, download script - bounding box,
      data range, they return script to query data
	- Includes: solar radiation, modeled data
	- LuM look into this further.
	
USDA: Check if existing package works

CARB data:
	- well structured, each file has 5yr intervals
	- each file has ~7mil rows, per hour per day for all sites
	- Files gives station info, gives city name, no lat/long
	- Will need to merge 
	
For Next week:
	- Pull USDA data:
	- Check CFSR
	- Pull CIMIS data
	  -compare variables against yield from USDA
	- CARB data
	  - Which pollutants important
	  - What stations are relevant
	  - Quick search for relationship to sol rad, crop yield
		- 
		
	- Mapping data between levels: 
	  - Yield at county, 
	- 
	
	- For now:
	  - Get small data set: One Station (Colusa), USDA state-level
        yields, 1992--2015
	  - In parallel, think about
		- Combining data from different sources, scales
		- reconstructing crop stages/timing
		- Mapping daily/hourly data to season
	  - Check for missing data
	  
- USDA 
	


26 Jan 2017
------

Organization:
	- List on Github (simplest, easiest to learn)
	-

Data
	
	- CARB: Lots of data, not everything needed. Relevant
	  parameters might be:
	  - PM2.5, PM10, ozone, aerosols
	  - Read the README with the DVDs - pick out relevant
		parts of the data.
	  - Webscrape CARB website needed for 2015-2016 data? Everything
				else is on DVDs. 

	- Crop data: Start simple: one crop, plateau period - build code with
		  flexibility for more crops
	  - Rice, 1992 - 1995, California.
	  - Available at county level from USDA
	  - Have experimental data from 1995-2015 (Open Science Foundation)				  
	- Alternate dataset might have both solar radiation and air
            quality: CERM (XXX will look at)
			
   	- Solar radiation: Many sources of data. 
	  - Look at the CIMIS data first 
	  - 4 stations in rice area, Davis, Colusa, Durham, and
		Nicolaus/Verona. 
	  - Colusa is likely the most representative.
	  
Other:

We did not explicitly talk about this during the meeting, but it is
really important that we look for existing functions to gather this
data if possible.

If there is an existing package out there, please use it rather than
writing your own code.

		

17 Jan 2017
------

First meeting of the group. Brief introductions and discussed some
general goals for the project.

Decisions:
	- We will use Slack for small communications within the group or
      between members of the same task
	- Group emails will be for big announcements
	- Weekly meetings will be to discuss status, adjust tasks, work
      through bottlenecks or difficult issues.

