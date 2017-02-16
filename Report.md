##Running report

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

