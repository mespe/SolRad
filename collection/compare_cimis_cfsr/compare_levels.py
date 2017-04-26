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
    downward_solar_flux_ground = fh.variables["CSDSF_L1_Avg_1"][:, 0, 0]
                            #(fh.variables["SHTFL_L1_Avg_1"][:,0,0] + fh.variables["LHTFL_L1_Avg_1"][:,0,0] + 
                             #fh.variables["DSWRF_L1_Avg_1"][:,0,0] + fh.variables["DLWRF_L1_Avg_1"][:,0,0] -  
                             #fh.variables["USWRF_L1_Avg_1"][:,0,0] - fh.variables["ULWRF_L1_Avg_1"][:,0,0] + 
                             #fh.variables["GFLUX_L1_Avg_1"][:,0,0]  )
                            
    downward_solar_flux_atm = fh.variables["DSWRF_L8_Avg_1"][:, 0, 0]
    
    
    
    #print(downward_solar_flux_np.shape)
    
    
    

    df = pd.DataFrame({'datetime': time_np, 'solar rad': downward_solar_flux_ground})

    #plt.plot(df['time'][:100], df['solar'][:100])
    
    # save to a pickle file
    df.to_pickle('pes_ground_sf.pkl')

    #'CSDSF_L1_Avg_1'
    df = pd.DataFrame({'datetime': time_np, 'solar rad': downward_solar_flux_atm})
    
    df.to_pickle('pes_atm_sf.pkl')

    
    
    for key in fh.variables.keys():
        variable = fh.variables[key]      
        #variable = fh.variables[key][:]
        print(variable) 
        print()

        




def compare():

    ground = pd.read_pickle('pes_ground_sf.pkl')
    
    
    atm = pd.read_pickle('pes_atm_sf.pkl')
    
    
    plt.plot(ground['datetime'][:1500], ground['solar rad'][:1500], label = "gournd", alpha = 0.5)
    plt.plot(atm['datetime'][:1500], atm['solar rad'][:1500], label = "atm", alpha = 0.5)
    
    plt.legend()
    
    #for i in range(10):
    #    print(cfsr['datetime'][i], cimis['datetime'][i])
        #print(cimis['datetime'][i])
        
        
#load_CFSR_data()
compare()