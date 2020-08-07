#Install packages if necessary
rm(list=ls())
if(!require(RODBC)) {  
  install.packages("RODBC")
  require(RODBC)}
if(!require(DBI)) {  
  install.packages("DBI")
  require(DBI)}
if(!require(foreign)) {  
  install.packages("foreign")
  require(foreign)}
 

# if(!require(ROracle)) {  
#   install.packages("ROracle")
#   require(ROracle)}

# Set up  variables to point to folders 

my_projdir<- "/home/mlee/Documents/projects/fishcondition"
my_projdir<-"C:/Users/Min-Yang.Lee/Documents/fishcondition"


my_codedir<-file.path(my_projdir,"R_code")
                    
extraction_code<-file.path(my_projdir,"data_extraction_processing")
analysis_code <-file.path(my_codedir, "analysis")
R_codedir <-file.path(my_projdir, "R_code")
my_adopath <-file.path(my_codedir, "aceprice_ado")


# setup data folder
my_datadir <-file.path(my_projdir, "data_folder")
data_raw <-file.path(my_datadir, "raw")

data_internal <-file.path(my_datadir, "internal")
data_external<-file.path(my_datadir, "external")

data_master <-file.path(my_datadir, "master")
data_intermediate <-file.path(my_datadir, "intermediate")



# setup results folders 
  
my_results <-file.path(my_projdir, "results")
hedonicR_results <-file.path(my_results, "hedonicR")

# setup images folders 

my_images <-file.path(my_projdir, "images")
exploratory <-file.path(my_images, "exploratory")