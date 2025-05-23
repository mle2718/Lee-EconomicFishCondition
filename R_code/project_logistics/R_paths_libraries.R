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

my_projdir<- "/home/mlee/Documents/projects/EconomicFishCondition"
my_projdir<-"C:/Users/Min-Yang.Lee/Documents/EconomicFishCondition"

stata_codedir<-file.path(my_projdir,"stata_code")
R_codedir <-file.path(my_projdir, "R_code")

extraction_code<-file.path(my_projdir,"data_extraction_processing")
analysis_code <-file.path(R_codedir, "analysis")
my_adopath <-file.path(R_codedir, "aceprice_ado")


# setup data folder
my_datadir <-file.path(my_projdir, "data_folder")
data_raw <-file.path(my_datadir, "raw")

data_internal <-file.path(my_datadir, "internal")
data_external<-file.path(my_datadir, "external")

data_main <-file.path(my_datadir, "main")
data_intermediate <-file.path(my_datadir, "intermediate")



# setup results folders 
  
my_results <-file.path(my_projdir, "results")

# setup images folders 

my_images <-file.path(my_projdir, "images")
exploratory <-file.path(my_images, "exploratory")


my_tables <-file.path(my_projdir, "tables")







# https://github.com/Hemken/Statamarkdown/blob/master/R/find_stata.r
# Search through places that stata is usually installed.
# I think it searches smallest to highest, which means if you have StataIC and stataMP-64, it will stop at StataIC
# and not pick up StataMP-64 
stataexe <- ""

for (d in c("C:/Program Files","C:/Program Files (x86)")) {
  if (stataexe=="" & dir.exists(d)) {
    for (v in seq(20,11,-1)) {
      dv <- paste(d,paste0("Stata",v), sep="/")
      if (dir.exists(dv)) {
        for (f in c("Stata", "StataIC", "StataSE", "StataMP",
                    "Stata-64", "StataIC-64", "StataSE-64", "StataMP-64")) {
          dvf <- paste(paste(dv, f, sep="/"), "exe", sep=".")
          if (file.exists(dvf)) {
            stataexe <- dvf
          }
          if (stataexe != "") break
        }
      }
      if (stataexe != "") break
    }
  }
  if (stataexe != "") break
}
rm(list=c("d","f", "dv","v", "dvf"))
stataexe<-shQuote(stataexe)
