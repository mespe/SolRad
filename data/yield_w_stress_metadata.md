# Meta-data for the yield_w_stress data set

Columns:

  + "planted": The date of planting (YYYY-MM-DD)
  + "site": RES = Rice Experiment Station
  + "plot": plot number in completely randomized block (not useful)
  + "rep": rep number (not useful)
  + "id": the cultivar (rice variety)
  + "dth": days to heading/flowering (following planting date)
  + "lodging": a score of the % of plants that lodged (fell over) at harvest
  + "height": the plant height in cm
  + "grain_type": the type of rice, determined by grain length (short,
    medium or long)
  + "moisture": moisture content at harvest, high numbers indicate
    rice might not have been fully mature at harvest
  + "year": year
  + "county": Butte
  + "trial_type": the RES plants multiple experiments per year, VE =
    very early maturing, E = early maturing, I/L = intermediate or
    late maturing varieties. Experiments are in different fields
    adjacent to eachother.
  + "yield_lb": final grain yield (before milling) corrected to 14%
    moisture content in lbs/acre.
  + "head_date": the date of heading/flowering (planted + dth)
  + "pi": the estimated date of panicle initiation (PI). PI is the
    transition point between the vegetative state and the flowering stage.
  + "vg_avg_tmin": avg. tmin during the period from planting to PI
  + "vg_avg_tmax": avg. tmax during the period from planting to PI
  + "fl_avg_tmin": avg. tmin during the period from PI to heading
  + "fl_avg_tmax": avg. tmax during the period from PI to heading
  + "gf_avg_tmin": avg. tmin during the period from heading to
    maturity (35d after heading/flowering)
  + "gf_avg_tmax": avg. tmax during the period from heading to
    maturity (35d after heading/flowering)
  + "se_avg_tmin": avg. tmin during the period from planting to maturity
  + "se_avg_tmax": avg. tmax during the period from planting to maturity
  + "veg_srad": sum solar radiation during the period from planting to PI
  + "rep_srad": sum solar radiation during the period from PI to flowering
  + "gf_srad": sum solar radiation during the period from flowering to
    maturity
  + "boot_cool": the aggregate score for cooling experienced during
  booting (pre-flower). More negative is more stress.
  + "boot_hot": aggregate score for heat stress during booting. More
  positive is more stress.
  + "fl_cool": aggregate score for cool stress during flowering. More
  negative is more stress.
  + "fl_hot": aggregate score for heat stress during flowering. More
  positive is more stress.
  + "yield_kg": Yield converted to kg/ha
   
  
All temperature data are from CIMIS. All solar radiation data are from CFSR.
