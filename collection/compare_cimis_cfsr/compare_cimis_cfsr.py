import pandas as pd
import matplotlib.pyplot as plt
from netCDF4 import Dataset
import netCDF4




def load_CFSR_data():
    
    my_example_nc_file = 'RES.nc' # latitude, longitude = (39.5, -122)
    
    fh = Dataset(my_example_nc_file, mode='r')
    
    print(fh.variables.keys())

    print(help(fh.variables['time']))

    
    print(fh.variables['time'].name)
    
    ####time = fh['time'][:]    
    ####print(time)
    
    times = fh.variables['time']

    time_np = netCDF4.num2date(times[:],times.units) -pd.offsets.Hour(8)
    
    #print(time_np.shape)
    

    variables = {"SHTFL_L1_Avg_1" : "Sensible heat flux",
                 "DSWRF_L1_Avg_1" : "Downward shortwave radiation flux",
                 "CSDSF_L1_Avg_1" : "Clear sky downward solar flux",
                 "DSWRF_L1_Avg_1" : "Downward shortwave radiation flux",
                 "DLWRF_L1_Avg_1" : "Downward longwave radiation flux",
                 "CSULF_L1_Avg_1" : "Clear sky upward longwave flux",
                 
                 "GFLUX_L1_Avg_1" : "Ground heat flux"}

    
    
    #downward_solar_flux_np = fh.variables["DSWRF_L1_Avg_1"][:,0,0] + fh.variables["DLWRF_L1_Avg_1"][:,0,0]- fh.variables["USWRF_L1_Avg_1"][:,0,0] - fh.variables["ULWRF_L1_Avg_1"][:,0,0]
    downward_solar_flux_np = fh.variables["CSDLF_L1_Avg_1"][:, 0, 0]
                            #(fh.variables["SHTFL_L1_Avg_1"][:,0,0] + fh.variables["LHTFL_L1_Avg_1"][:,0,0] + 
                             #fh.variables["DSWRF_L1_Avg_1"][:,0,0] + fh.variables["DLWRF_L1_Avg_1"][:,0,0] -  
                             #fh.variables["USWRF_L1_Avg_1"][:,0,0] - fh.variables["ULWRF_L1_Avg_1"][:,0,0] + 
                             #fh.variables["GFLUX_L1_Avg_1"][:,0,0]  )
                            
    
    
    
    #print(downward_solar_flux_np.shape)
    
    
    

    df = pd.DataFrame({'datetime': time_np, 'solar rad': downward_solar_flux_np})

    #plt.plot(df['time'][:100], df['solar'][:100])
    
    # save to a pickle file
    df.to_pickle('cfsr_2005_2010.pkl')

    #'CSDSF_L1_Avg_1'
    
    
    for key in fh.variables.keys():
        variable = fh.variables[key]      
        #variable = fh.variables[key][:]
        print(variable) 
        print()

        




def compare():

    cimis = pd.read_pickle('cimis_2005_2010.pkl')
    
    
    cfsr = pd.read_pickle('cfsr_2005_2010.pkl')
    
    
    plt.plot(cfsr['datetime'][:250], cfsr['solar rad'][:250], label = "cfsr")
    plt.plot(cimis['datetime'][:1500], cimis['solar rad'][:1500], label = "cimis")
    
    plt.legend()
    
    #for i in range(10):
    #    print(cfsr['datetime'][i], cimis['datetime'][i])
        #print(cimis['datetime'][i])
        
        
load_CFSR_data()
#compare()