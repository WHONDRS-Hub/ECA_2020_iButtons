# script to format iButton data for ESS-DIVE publishing

library(stringr)

dat.in.path = "//pnl/projects/SULI_Reed/iButtonData/ECA1_Processed_iButtonData/"
dat.out.path = "//pnl/projects/SULI_Reed/iButtonData/ECA1_Formatted_iButtonData/"

# loop across all files and format
# Use UTC in 24 hour time
# YYYY-MM-DD hh:mm is the date/time format

folders.for.loop = list.files(path = dat.in.path,pattern = "ECA1")

for (i in folders.for.loop) {
  
  temp.path.in = paste0(dat.in.path,i)
  temp.files = list.files(path = temp.path.in,pattern = "ECA1")
  
  for (j in temp.files) {
    
    dat.temp = read.csv(paste(temp.path.in,j,sep="/"),stringsAsFactors = F)
    dat.temp = dat.temp[,c('Date.Time.UTC','Value')]
    colnames(dat.temp)[which(colnames(dat.temp) == 'Value')] = 'Temperature'
    colnames(dat.temp)[which(colnames(dat.temp) == 'Date.Time.UTC')] = 'DateTime_UTC'
    
    dat.temp$DateTime_UTC = word(string = dat.temp$DateTime_UTC,start = 1,end = 2,sep = ":")
    
    dat.temp = rbind(colnames(dat.temp),dat.temp)
    
    ibutton.name = gsub(pattern = "iButton_Processed_",replacement = "",x = j)
    ibutton.name = gsub(pattern = ".csv",replacement = "",x = ibutton.name)
    
    header.rows = as.data.frame(matrix(c("# HeaderRows_5",
                           "# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary",
                           paste0("# DateTime_UTC; YYYY-MM-DD hh:mm UTC+0:00; ",ibutton.name,"; Thermochron iButton DS1921G-F50"),
                           paste0("# Temperature; degree_celsius; ",ibutton.name,"; Thermochron iButton DS1921G-F50"),"","","","")
      ,nrow=4,ncol=2))
    
    colnames(dat.temp) = colnames(header.rows)
    
    dat.temp = rbind(header.rows,dat.temp)
    
    file.name.out = gsub(pattern = "Processed",replacement = "Formatted",x = j)
    
    write.table(dat.temp,paste(dat.out.path,file.name.out,sep=""),row.names = F,quote=F,col.names = F,sep=",")
    
  }
  
}
