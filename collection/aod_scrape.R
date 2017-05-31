library(RCurl)
library(XML)

url = "https://ladsweb.modaps.eosdis.nasa.gov/search/?si=Terra%20MODIS&si=Aqua%20MODIS/order/4/MOD09CMA--6/2017-05-10..2017-05-24/DNB/Tile:H8V5"

doc = getURL(url)
doc = htmlParse(doc)

doc2 = htmlParse("LAADS S&O [4]_ MOD09CMA--6_2017-05-10..2017-05-24_DNB_Tile_H8V5.html")

tbls = readHTMLTable(doc2)

oans = getHTMLLinks(doc2)

?download.file

lapply(links[4], function(x) download.file(url = x,
                                        destfile = gsub("https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/6/MOD09CMA/2017/142/", "", x)))

download.file(url = links[4],
              destfile = gsub("https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/6/MOD09CMA/2017/[0-9]+/", "", links[4]),
              )

################################################################################
#  Programmatically getting the links

library(RSelenium)

d = remoteDriver(port = 5556, browserName = "firefox")
d$open()
