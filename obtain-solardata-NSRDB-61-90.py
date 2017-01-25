#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 23 12:18:13 2017

@author: Henry Kvinge

File takes relevant solar radiation data from 1961-1990 from NSRDB website, 
puts it into a dataframe and saves it as a .csv file.
"""

from urllib.request import urlopen #To read text from url
import pandas as pd                #To use dataframes to store data


#Years to pull from, default is all years available. 
years = [str(i) for i in range(61,91)]
         
#Location codes for sites where solar radiation data was recorded in CA.
#24283		Arcata, CA
#23155		Bakersfield, CA
#23161		Dagget, CA
#93193		Fresno, CA
#23129		Long Beach, CA
#23174		Los Angeles, CA
#23232		Sacramento, CA
#23188		San Diego, CA
#23234		San Francisco, CA
#23273		Santa Maria, CA
locations = ['24283','23155','23161','93193','23129','23174','23232','23188','23234','23273']

#List of urls where data will be pulled from
urls = ['http://rredc.nrel.gov/solar/old_data/nsrdb/1961-1990/hourly/19'+ i 
        + '/'+ j + '_'+ i +'.txt' for i in years for j in locations]


#All columns that will go into dataframe.
columns = ['Year','Month','Day','Hour','City','Extraterrestial horizontal radiation',
           'Extraterrestial direct normal radiation', 'Global horizontal radation',
           'Direct normal radiation','Diffuse horizontal radiation']

df = pd.DataFrame(columns=columns)

#Loop goes through all urls and adds data from each into our dataframe.          
for i in urls:
    data = urlopen(i)
    roundOne = True
    print(i)
    for line in data: # Iterate over lines in textfile
        entries = str(line).split() #Split line up into list of words
        if (roundOne):
            city = entries[2]       #Grab the city name
        else:
            date = entries[1] + '-' + entries[2] + '-' + entries[3] + '-' + entries[4] + '-' + city
            df.loc[date] = [entries[1],entries[2],entries[3],entries[4],city,
                   entries[5],entries[6],entries[7],entries[9],entries[11]]
        roundOne = False
    roundOne = True

#Save dataframe as .csv file. 
df.to_csv('solarradiation61-90.csv')


