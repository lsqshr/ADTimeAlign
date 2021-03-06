# Install ADNIMERGE library to use this script
# ADNIMERGE contains a dxsum table which has the DXCHANGE column filled for all subjects 
# Pre-requisite code:
#'''
# install.packages("Hmisc") 
# install.packages("../your path/ADNIMERGE_0.0.1.tar.gz", repos=NULL, type="source") # this tar can be found in ADNI website 
#                                                                   #Study Data->Study Info->Data & Database-> Merged ADNI 1/GO/2 Packages for R
# install.packages("R.matlab")

library(ADNIMERGE)
library(R.matlab)

# Filter FS features only keep 'complete features'
fs1 <- read.csv("UCSFFSL_08_01_14.csv")
fs2 <- read.csv("UCSFFSL51Y1_08_01_14.csv")

#filteredFs1 <- fs1[fs1$OVERALLQC=='Pass',]
#filteredFs2 <- fs2[fs2$OVERALLQC=='Pass',]

filteredFs1 <- fs1
filteredFs2 <- fs2

# Merge the FS features with the DXSUM table
filteredFs1 <- filteredFs1[,names(filteredFs1) != "VISCODE"] # Drop the VISCODE column in FS table
filteredFs2 <- filteredFs2[,names(filteredFs2) != "VISCODE"] # Drop the VISCODE column in FS table

subdx <- subset(dxsum, select=c("RID", "VISCODE", "DXCHANGE"))

dxfs1 <- merge(subdx, filteredFs1, by.x=c("RID", "VISCODE"), by.y=c("RID", "VISCODE2"))
dxfs2 <- merge(subdx, filteredFs2, by.x=c("RID", "VISCODE"), by.y=c("RID", "VISCODE2"))

header1 = names(dxfs1)
header2 = names(dxfs2)
interheader = intersect(header1, header2)
dxfs1 = dxfs1[, names(dxfs1) %in% interheader]
dxfs2 = dxfs2[, names(dxfs2) %in% interheader]
dxfs = rbind(dxfs1,dxfs2)

hippo = subset(dxfs, select=c("RID","VISCODE", "ST29SV", "ST88SV", "DXCHANGE"));

# Export to csv
write.table(hippo, "LongtidudinalHippoADNI.csv", sep = "\t",)

writeMat('hippo+ventricle.mat', RID=hippo$RID, VISCODE=dxfs$VISCODE, 
         x=cbind(dxfs$ST29SV, dxfs$ST88SV, dxfs$ST30SV, dxfs$ST37SV,
             dxfs$ST89SV, dxfs$ST8SV, dxfs$ST96SV, dxfs$ST9SV, dxfs$ST127SV), 
         dxchange=hippo$DXCHANGE)
