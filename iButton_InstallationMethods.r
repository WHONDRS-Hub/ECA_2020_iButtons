# script to make the installation methods csv for the data package

dat.in.path = "//pnl/projects/SULI_Reed/iButtonData/ECA1_Formatted_iButtonData/"
dat.out.path = "//pnl/Projects/ECA_Project/ECA_Data_Packages/01_Data-Package-Folders/2021_ECA1_iButtons/2021_ECA1_iButtons_Data-Package/"


# all ibutton senson names
formatted.files = list.files(path = dat.in.path,pattern = "iButton_Formatted_")
formatted.files = gsub(pattern = "iButton_Formatted_",replacement = "",x = formatted.files)
ibutton.names = gsub(pattern = ".csv",replacement = "",x = formatted.files)

# setting up the template
col.headers = c("InstallationMethod_ID","InstallationMethod_Description","Latitude","Longitude","Site_ID","Depth","Depth_Reference","Elevation","Elevation_Reference","Site_Name","Water_Name","Site_Type","Configuration","DateTime_Start","DateTime_End","UTC_Offset")
installation.methods = as.data.frame(matrix(c(NA),ncol=length(col.headers),nrow=length(ibutton.names)))
colnames(installation.methods) = col.headers

# put sensor names into the template
installation.methods$InstallationMethod_ID = ibutton.names

# input text for the installationmethod_description
installation.methods$InstallationMethod_Description = "iButton temperature sensors were deployed on the sediment surface inside a protective metal covering and held in place with stakes or rocks at up to seven locations at each river. OUT iButtons were deployed with the intention to never be inundated by the river. IN iButtons were deployed with the intention to always be inundated by the river. In some cases rivers went dry during the deployment. The remaining five iButtons were intentionally deployed in variably inundated regions of sediment in a transect spanning Upstream and Upstream Mid-Point and Mid-Stream and Downstream Mid-Point and Downstream iButtons. A single Lat Long is given for all sensors at a site using the approximate mid point along the transect. Additional lat long resolution is possible based on measured distances among sensors. See  iButton_Deployment_Protocol.pdf in the data package for more detail."

# input the site level names
for (i in 1:nrow(installation.methods)) {
  
  installation.methods$Site_ID[i] = substr(x = installation.methods$InstallationMethod_ID[i],start = 1,stop = 9)
  
}


# put in site_type

installation.methods$Site_Type = "river [ENVO:00000022]"

# put in Configuration

installation.methods$Configuration = "Surface of sediment or soil"

# put in start and stop dates

for (i in 1:nrow(installation.methods)) {
  
  dat.temp = read.csv(paste0(dat.in.path,"iButton_Formatted_",installation.methods$InstallationMethod_ID[i],".csv"))
  installation.methods$DateTime_Start[i] = as.character(dat.temp[I(which(dat.temp[,1] == "DateTime_UTC") + 1),1])
  installation.methods$DateTime_End[i] = as.character(dat.temp[nrow(dat.temp),1])
  rm('dat.temp')
  
}

# times are in UTC so setting offset to 0

installation.methods$UTC_Offset = 0

# put in lat long. currently just using the sediment location 5 as the lat/long for all the sensors.
# we could get more resolution if needed based on the measured distances between each sensor, but not doing that for now
# also putting in the site name and water name

meta.data = read.csv("//pnl/Projects/ECA_Project/Sediment_Collection_2020/Metadata_IGSN/ECA2_SedimentMetadata_2021_8_17_VGC.csv",skip=1,stringsAsFactors = F)

for (i in 1:nrow(installation.methods)) {
  
 installation.methods$Latitude[i] = meta.data$Collection.location.5..Latitude..decimal.degrees.[which(meta.data$Unique.ID.assigned.to.site..ECA2_XXXX. == gsub(pattern = "ECA1",replacement = "ECA2",x = installation.methods$Site_ID[i]))]
 installation.methods$Longitude[i] = meta.data$Collection.location.5..Longitude..decimal.degrees.[which(meta.data$Unique.ID.assigned.to.site..ECA2_XXXX. == gsub(pattern = "ECA1",replacement = "ECA2",x = installation.methods$Site_ID[i]))]
  
 installation.methods$Site_Name[i] = meta.data$Site.name[which(meta.data$Unique.ID.assigned.to.site..ECA2_XXXX. == gsub(pattern = "ECA1",replacement = "ECA2",x = installation.methods$Site_ID[i]))]
 installation.methods$Water_Name[i] = meta.data$Stream.name[which(meta.data$Unique.ID.assigned.to.site..ECA2_XXXX. == gsub(pattern = "ECA1",replacement = "ECA2",x = installation.methods$Site_ID[i]))]
 
 
}

# write the file

write.csv(x = installation.methods,file = paste0(dat.out.path,"InstallationMethods.csv"),quote=F,row.names = F)
