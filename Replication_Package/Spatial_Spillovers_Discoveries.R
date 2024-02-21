
#Define working directory
setwd("C:/Users/17637/Dropbox/PhD/Research/Presource Curse/Data Directory")

#Load libraries
library(geobr)
library(ggplot2)
#library(gganimate)
#library(gifski)
library(sf)
library(sp)
library(dplyr)
library(rio)
library(geosphere)
library(foreign)
library(haven)
library(magick)
library(spData)
library(maptools)
library(ptinpoly)
library(ggsflabel)
library(data.table)
library(did)
library(viridis)
library(tibble)


#Import dataset from Stata that includes municipality-level treatment and outcomes
#First, try with no event dummies
treatment_units <- read_dta("Treatment Variables/Treatment_Codes_forDistance.dta")

#Create dataset of only controls and disappointed 
disappointed <- treatment_units[(treatment_units$disappointed_pc_med==1),]
satisfied <- treatment_units[(treatment_units$disappointed_pc_med==2),]

#Use GeoBR package to download required shapefiles (requires internet connection)
# Download all states in Brazil
state <- read_state(year=2010)
# Download all municipalities in Brazil
muni <- read_municipality(year=2010)

#Import discovery locations 
discoveries <- read.csv("Discoveries/Discoveries_for_Mapping.csv")

# Remove plot axis for later mapping appearance
no_axis <- theme(axis.title=element_blank(),
                 axis.text=element_blank(),
                 axis.ticks=element_blank())

#Merge disappointed indicators with muni using munic_code
muni_with_treat_indicators <- merge(muni, treatment_units, by=c('code_muni'))

#Keep only disappointed munics (now with geometry attached)
disappointed_with_geom <- muni_with_treat_indicators[(muni_with_treat_indicators$disappointed_pc_med==1),]
#Compute centroids for disappointed munics
coord_disappointed <- st_coordinates(st_centroid(disappointed_with_geom))

#Repeat for satisfied munics 
satisfied_with_geom <- muni_with_treat_indicators[(muni_with_treat_indicators$disappointed_pc_med==2),]
coord_satisfied <- st_coordinates(st_centroid(satisfied_with_geom))

#There are now two lists of all coordinate points of disappointed and satisfied municipalities.
#############################################################################

#Now find centroid coordinates for all municipalities
coord_brasil <- st_coordinates(st_centroid(muni))
muni_for_plot <- cbind(muni, coord_brasil)

#Find distance between each municipal centroid and each disappointed munic
muni_for_dist <- as.data.frame(cbind(muni, coord_brasil))
muni_for_dist$geom <- NULL

#################################################################################
#Disappointed 

#Compute centroids of disappointed units 
dist_centroids_disappointed <- distm(coord_disappointed[ ,c("X","Y")], muni_for_dist[ ,c("X","Y")])

#Attach municipal codes to each column
dist_centroids_disappointed <- data.frame(dist_centroids_disappointed)
colnames(dist_centroids_disappointed) <- muni$code_muni

#Attach municipal codes of disappointed munics to each row 
rownames(dist_centroids_disappointed) <- disappointed$code_muni

#Convert row names to new column
dist_centroids_disappointed$location = row.names(dist_centroids_disappointed)

#Now find minimum distance for each code_muni, which gives distance to nearest disappointed munic
min_dist_disappointed <- apply(dist_centroids_disappointed[,c(1:5567)],2,which.min)

distance_disappointed=NULL
for(i in 1:5567){
  di = dist_centroids_disappointed[min_dist_disappointed[i], c(i, 5568)]
  di$code_muni = colnames(di)[1]
  colnames(di)=c("distance","location","code_muni")
  distance_disappointed = rbind(distance_disappointed, di)
}

#Divide each of these distances by 1000 to convert from meters to kilometers
distance_disappointed$distance <- distance_disappointed$distance / 1000


######################################################################
#Now repeat for satisfied 
dist_centroids_satisfied <- distm(coord_satisfied[ ,c("X","Y")], muni_for_dist[ ,c("X","Y")])
dist_centroids_satisfied <- data.frame(dist_centroids_satisfied)
colnames(dist_centroids_satisfied) <- muni$code_muni
rownames(dist_centroids_satisfied) <- satisfied$code_muni
dist_centroids_satisfied$location = row.names(dist_centroids_satisfied)
min_dist_satisfied <- apply(dist_centroids_satisfied[,c(1:5567)],2,which.min)
distance_satisfied=NULL
for(i in 1:5567){
  di = dist_centroids_satisfied[min_dist_satisfied[i], c(i, 5568)]
  di$code_muni = colnames(di)[1]
  colnames(di)=c("distance","location","code_muni")
  distance_satisfied = rbind(distance_satisfied, di)
}
distance_satisfied$distance <- distance_satisfied$distance / 1000


###########################################################################

#Create subsample of only coastal states (mostly)
muni_coastalstates <- subset(muni, abbrev_state == "RS" | abbrev_state == "SC" | abbrev_state == "PR" | abbrev_state == "SP" | abbrev_state == "RJ" | abbrev_state == "ES" | abbrev_state == "MG" | abbrev_state == "BA" | abbrev_state == "SE" | abbrev_state == "AL" | abbrev_state == "PE"| abbrev_state == "PB"| abbrev_state == "RN"| abbrev_state == "CE" | abbrev_state == "PI" | abbrev_state == "MA" | abbrev_state == "PA" | abbrev_state == "AP")

############################################################################
#Merge minimum distances for each municipality into main municipality dataset 
muni_for_plot_disappointed <- merge(muni_for_plot, distance_disappointed, by=c("code_muni"),all.x=TRUE)
muni_for_plot_satisfied <- merge(muni_for_plot, distance_satisfied, by=c("code_muni"),all.x=TRUE)

#Finally, save these vectors to a csv file
write.csv(distance_disappointed, file = "Shapefiles/distance_disappointed.csv", row.names = FALSE)
#write.dta(min_dist_disappointed, file =  "C:/Users/17637/Dropbox/PhD/Research/Presource Curse/Data Directory/Shapefiles/distance_disappointed.dta")
write.csv(distance_satisfied, file = "Shapefiles/distance_satisfied.csv", row.names = FALSE)
#write.dta(min_dist_satisfied, file =  "C:/Users/17637/Dropbox/PhD/Research/Presource Curse/Data Directory/Shapefiles/distance_satisfied.dta")

############################################################################
#Mapping 
#Color municipalities according to their distance from a disappointed municipality
ggplot() +
  geom_sf(data=muni_for_plot_disappointed, aes(fill=distance_disappointed), color=NA, size=.15, show.legend = FALSE) +
  geom_sf(data=state, color="black", alpha=0, size=.3, show.legend = FALSE) +
  labs(subtitle="Brazilian Municipalities: Distance from Disappointed Municipality", size=8) +
  scale_fill_viridis(option = "viridis", limits = c(0,300)) +
  theme_minimal() + no_axis +
  geom_point(data = discoveries, aes(x = longitude_base_dd, y = latitude_base_dd, size = imputed_volume_mmboe),
             shape = 21)
 # geom_point(data = coord_disappointed, aes(x = X, y = Y), size = 2, 
          #   shape = 21, fill = "yellow2") 

#Color municipalities according to distance from satisfied municipality
ggplot() +
  geom_sf(data=muni_for_plot_satisfied, aes(fill=distance_satisfied), color=NA, size=.15, show.legend = FALSE) +
  labs(subtitle="Brazilian Municipalities: Distance from Satisfied Municipality", size=8) +
  scale_fill_viridis(option = "viridis", limits = c(0,300)) +
  theme_minimal() + no_axis +
  geom_point(data = discoveries, aes(x = longitude_base_dd, y = latitude_base_dd, size = imputed_volume_mmboe),
             shape = 21)
# geom_point(data = coord_disappointed, aes(x = X, y = Y), size = 2, 
#   shape = 21, fill = "yellow2") 

######################################################################
#Repeat maps only for coastal states (and MG)

#Color municipalities according to their distance from a disappointed municipality
ggplot() +
  geom_sf(data=muni_for_plot_disappointed[which(muni_for_plot_disappointed$abbrev_state == "RS" | muni_for_plot_disappointed$abbrev_state == "SC" | muni_for_plot_disappointed$abbrev_state == "PR" | muni_for_plot_disappointed$abbrev_state == "SP" | muni_for_plot_disappointed$abbrev_state == "RJ" | muni_for_plot_disappointed$abbrev_state == "ES" | muni_for_plot_disappointed$abbrev_state == "MG" | muni_for_plot_disappointed$abbrev_state == "BA" | muni_for_plot_disappointed$abbrev_state == "SE" | muni_for_plot_disappointed$abbrev_state == "AL" | muni_for_plot_disappointed$abbrev_state == "PE"| muni_for_plot_disappointed$abbrev_state == "PB"| muni_for_plot_disappointed$abbrev_state == "RN"| muni_for_plot_disappointed$abbrev_state == "CE" | muni_for_plot_disappointed$abbrev_state == "PI" | muni_for_plot_disappointed$abbrev_state == "MA"),],
          aes(fill=distance), color=NA, size=.15, show.legend = FALSE) +
  geom_sf(data=state[which(state$abbrev_state == "RS" | state$abbrev_state == "SC" | state$abbrev_state == "PR" | state$abbrev_state == "SP" | state$abbrev_state == "RJ" | state$abbrev_state == "ES" | state$abbrev_state == "MG" | state$abbrev_state == "BA" | state$abbrev_state == "SE" | state$abbrev_state == "AL" | state$abbrev_state == "PE"| state$abbrev_state == "PB"| state$abbrev_state == "RN"| state$abbrev_state == "CE" | state$abbrev_state == "PI" | state$abbrev_state == "MA"),],
          color="black", alpha=0, size=.3, show.legend = FALSE) +
  geom_sf(data=muni[which(muni$abbrev_state == "RS" | muni$abbrev_state == "SC" | muni$abbrev_state == "PR" | muni$abbrev_state == "SP" | muni$abbrev_state == "RJ" | muni$abbrev_state == "ES" | muni$abbrev_state == "MG" | muni$abbrev_state == "BA" | muni$abbrev_state == "SE" | muni$abbrev_state == "AL" | muni$abbrev_state == "PE"| muni$abbrev_state == "PB"| muni$abbrev_state == "RN"| muni$abbrev_state == "CE" | muni$abbrev_state == "PI" | muni$abbrev_state == "MA"),],
         color="black", alpha = 0, size=.01, show.legend = FALSE) +
  geom_sf(data=muni_for_plot_disappointed[which(muni_for_plot_disappointed$distance == 0 & (muni_for_plot_disappointed$abbrev_state == "RS" | muni_for_plot_disappointed$abbrev_state == "SC" | muni_for_plot_disappointed$abbrev_state == "PR" | muni_for_plot_disappointed$abbrev_state == "SP" | muni_for_plot_disappointed$abbrev_state == "RJ" | muni_for_plot_disappointed$abbrev_state == "ES" | muni_for_plot_disappointed$abbrev_state == "MG" | muni_for_plot_disappointed$abbrev_state == "BA" | muni_for_plot_disappointed$abbrev_state == "SE" | muni_for_plot_disappointed$abbrev_state == "AL" | muni_for_plot_disappointed$abbrev_state == "PE"| muni_for_plot_disappointed$abbrev_state == "PB"| muni_for_plot_disappointed$abbrev_state == "RN"| muni_for_plot_disappointed$abbrev_state == "CE" | muni_for_plot_disappointed$abbrev_state == "PI" | muni_for_plot_disappointed$abbrev_state == "MA")),],
          fill = "red", color="black", size=.15, show.legend = FALSE) +
  labs(subtitle="Brazilian Municipalities: Distance from Disappointed Municipality", size=8) +
  scale_fill_viridis(option = "viridis", limits = c(0,1070), direction=-1) +
  theme_minimal() + no_axis +
  geom_point(data = discoveries, aes(x = longitude_base_dd, y = latitude_base_dd, size = imputed_volume_mmboe),
             shape = 21, color = "blue")+
  scale_size_continuous(range = c(2, 20))
 # scale_colour_viridis_d(direction=-1)
# geom_point(data = coord_disappointed, aes(x = X, y = Y), size = 2, 
#   shape = 21, fill = "yellow2") 
filename = paste("Texts/Distance_Disappointed2.png")
ggsave(filename, width = 11, height = 11)

#Color municipalities according to distance from satisfied municipality
ggplot() +
  geom_sf(data=muni_for_plot_satisfied[which(muni_for_plot_satisfied$abbrev_state == "RS" | muni_for_plot_satisfied$abbrev_state == "SC" | muni_for_plot_satisfied$abbrev_state == "PR" | muni_for_plot_satisfied$abbrev_state == "SP" | muni_for_plot_satisfied$abbrev_state == "RJ" | muni_for_plot_satisfied$abbrev_state == "ES" | muni_for_plot_satisfied$abbrev_state == "MG" | muni_for_plot_satisfied$abbrev_state == "BA" | muni_for_plot_satisfied$abbrev_state == "SE" | muni_for_plot_satisfied$abbrev_state == "AL" | muni_for_plot_satisfied$abbrev_state == "PE"| muni_for_plot_satisfied$abbrev_state == "PB"| muni_for_plot_satisfied$abbrev_state == "RN"| muni_for_plot_satisfied$abbrev_state == "CE" | muni_for_plot_satisfied$abbrev_state == "PI" | muni_for_plot_satisfied$abbrev_state == "MA"),],
          aes(fill=distance), color=NA, size=.15, show.legend = FALSE) +
  geom_sf(data=state[which(state$abbrev_state == "RS" | state$abbrev_state == "SC" | state$abbrev_state == "PR" | state$abbrev_state == "SP" | state$abbrev_state == "RJ" | state$abbrev_state == "ES" | state$abbrev_state == "MG" | state$abbrev_state == "BA" | state$abbrev_state == "SE" | state$abbrev_state == "AL" | state$abbrev_state == "PE"| state$abbrev_state == "PB"| state$abbrev_state == "RN"| state$abbrev_state == "CE" | state$abbrev_state == "PI" | state$abbrev_state == "MA"),],
          color="black", alpha=0, size=.3, show.legend = FALSE) +
  geom_sf(data=muni[which(muni$abbrev_state == "RS" | muni$abbrev_state == "SC" | muni$abbrev_state == "PR" | muni$abbrev_state == "SP" | muni$abbrev_state == "RJ" | muni$abbrev_state == "ES" | muni$abbrev_state == "MG" | muni$abbrev_state == "BA" | muni$abbrev_state == "SE" | muni$abbrev_state == "AL" | muni$abbrev_state == "PE"| muni$abbrev_state == "PB"| muni$abbrev_state == "RN"| muni$abbrev_state == "CE" | muni$abbrev_state == "PI" | muni$abbrev_state == "MA"),],
          color="black", alpha = 0, size=.01, show.legend = FALSE) +
  geom_sf(data=muni_for_plot_satisfied[which(muni_for_plot_satisfied$distance == 0 & (muni_for_plot_satisfied$abbrev_state == "RS" | muni_for_plot_satisfied$abbrev_state == "SC" | muni_for_plot_satisfied$abbrev_state == "PR" | muni_for_plot_satisfied$abbrev_state == "SP" | muni_for_plot_satisfied$abbrev_state == "RJ" | muni_for_plot_satisfied$abbrev_state == "ES" | muni_for_plot_satisfied$abbrev_state == "MG" | muni_for_plot_satisfied$abbrev_state == "BA" | muni_for_plot_satisfied$abbrev_state == "SE" | muni_for_plot_satisfied$abbrev_state == "AL" | muni_for_plot_satisfied$abbrev_state == "PE"| muni_for_plot_satisfied$abbrev_state == "PB"| muni_for_plot_satisfied$abbrev_state == "RN"| muni_for_plot_satisfied$abbrev_state == "CE" | muni_for_plot_satisfied$abbrev_state == "PI" | muni_for_plot_satisfied$abbrev_state == "MA")),],
          fill = "green", color="black", size=.15, show.legend = FALSE) +
  labs(subtitle="Brazilian Municipalities: Distance from satisfied Municipality", size=8) +
  scale_fill_viridis(option = "viridis", limits = c(0,1420), direction=-1) +
  theme_minimal() + no_axis +
  geom_point(data = discoveries, aes(x = longitude_base_dd, y = latitude_base_dd, size = imputed_volume_mmboe),
             shape = 21, color = "blue")+
  scale_size_continuous(range = c(2, 20))
# scale_colour_viridis_d(direction=-1)
# geom_point(data = coord_satisfied, aes(x = X, y = Y), size = 2, 
#   shape = 21, fill = "yellow2") 
filename = paste("Texts/Distance_satisfied2.png")
ggsave(filename, width = 11, height = 11)



