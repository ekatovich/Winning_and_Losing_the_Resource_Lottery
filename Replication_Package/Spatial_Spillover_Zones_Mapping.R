#Plotting Spatial Spillover Samples 

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

#Import spillover indicators
simple_spillovers <- read_dta("Treatment Variables/Near_Discoveries_SimpleDistance.dta")
exclusive_spillovers <- read_dta("Treatment Variables/Near_Discoveries_ExclusiveDistance.dta")
combined_spillovers <- read_dta("Treatment Variables/Near_Discovery_forMapping_Combined.dta")

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

#Merge spillover codes with muni to map 
simple_spillovers_mapping <- merge(muni, simple_spillovers, by=c('code_muni'))
exclusive_spillovers_mapping <- merge(muni, exclusive_spillovers, by=c('code_muni'))
combined_spillovers_mapping <- merge(muni, combined_spillovers, by=c('code_muni'))

#Merge treatment indicators with muni 
treatment_unit_mapping <- merge(muni, treatment_units, by=c('code_muni'))

#Keep only disappointed munics (now with geometry attached)
disappointed_with_geom <- treatment_unit_mapping[(treatment_unit_mapping$disappointed_pc_med==1),]

#Repeat for satisfied munics 
satisfied_with_geom <- treatment_unit_mapping[(treatment_unit_mapping$disappointed_pc_med==2),]

#Keep both 
combined_with_geom <- treatment_unit_mapping[(treatment_unit_mapping$disappointed_pc_med==1 | treatment_unit_mapping$disappointed_pc_med==2),]

###################################################################
#Mapping 
#Simple disappointed near and far
ggplot() +
  geom_sf(data=muni[which(muni$abbrev_state == "RS" | muni$abbrev_state == "SC" | muni$abbrev_state == "PR" | muni$abbrev_state == "SP" | muni$abbrev_state == "RJ" | muni$abbrev_state == "ES" | muni$abbrev_state == "MG" | muni$abbrev_state == "BA" | muni$abbrev_state == "SE" | muni$abbrev_state == "AL" | muni$abbrev_state == "PE"| muni$abbrev_state == "PB"| muni$abbrev_state == "RN"| muni$abbrev_state == "CE" | muni$abbrev_state == "PI" | muni$abbrev_state == "MA"),], color="black", fill="white", size=.01, show.legend = FALSE) +
  geom_sf(data=simple_spillovers_mapping[which(simple_spillovers_mapping$near_disappointed==1),], color="black", fill="red", size=.15, show.legend = FALSE) +
  geom_sf(data=simple_spillovers_mapping[which(simple_spillovers_mapping$near_disappointed==2),], color="black", fill="pink", size=.15, show.legend = FALSE) +
  geom_sf(data=disappointed_with_geom[which(disappointed_with_geom$disappointed_pc_med==1),], color="black", fill="firebrick4", size=.01, show.legend = FALSE) 
filename = paste("C:/Users/17637/Dropbox/PhD/Research/Presource Curse/Texts/SpilloverZones_Simple_Disappointed.png")
ggsave(filename, width = 11, height = 11)

#Simple satisfied near and far
ggplot() +
  geom_sf(data=muni[which(muni$abbrev_state == "RS" | muni$abbrev_state == "SC" | muni$abbrev_state == "PR" | muni$abbrev_state == "SP" | muni$abbrev_state == "RJ" | muni$abbrev_state == "ES" | muni$abbrev_state == "MG" | muni$abbrev_state == "BA" | muni$abbrev_state == "SE" | muni$abbrev_state == "AL" | muni$abbrev_state == "PE"| muni$abbrev_state == "PB"| muni$abbrev_state == "RN"| muni$abbrev_state == "CE" | muni$abbrev_state == "PI" | muni$abbrev_state == "MA"),], color="black", fill="white", size=.01, show.legend = FALSE) +
  geom_sf(data=simple_spillovers_mapping[which(simple_spillovers_mapping$near_satisfied==1),], color="black", fill="mediumseagreen", size=.15, show.legend = FALSE) +
  geom_sf(data=simple_spillovers_mapping[which(simple_spillovers_mapping$near_satisfied==2),], color="black", fill="lightgreen", size=.15, show.legend = FALSE) +
  geom_sf(data=satisfied_with_geom[which(satisfied_with_geom$disappointed_pc_med==2),], color="black", fill="darkgreen", size=.01, show.legend = FALSE) 
filename = paste("C:/Users/17637/Dropbox/PhD/Research/Presource Curse/Texts/SpilloverZones_Simple_Satisfied.png")
ggsave(filename, width = 11, height = 11)



#Combined disappointed and satisfied 
ggplot() +
  geom_sf(data=muni[which(muni$abbrev_state == "RS" | muni$abbrev_state == "SC" | muni$abbrev_state == "PR" | muni$abbrev_state == "SP" | muni$abbrev_state == "RJ" | muni$abbrev_state == "ES" | muni$abbrev_state == "MG" | muni$abbrev_state == "BA" | muni$abbrev_state == "SE" | muni$abbrev_state == "AL" | muni$abbrev_state == "PE"| muni$abbrev_state == "PB"| muni$abbrev_state == "RN"| muni$abbrev_state == "CE" | muni$abbrev_state == "PI" | muni$abbrev_state == "MA"),],
          color="black", fill="white", size=.01, show.legend = FALSE) +
  geom_sf(data=combined_spillovers_mapping[which(combined_spillovers_mapping$near_discovery==1),], color="black", fill="red", size=.15, show.legend = FALSE) +
  geom_sf(data=combined_spillovers_mapping[which(combined_spillovers_mapping$near_discovery==2),], color="black", fill="pink1", size=.15, show.legend = FALSE) +
  geom_sf(data=combined_spillovers_mapping[which(combined_spillovers_mapping$near_discovery==3),], color="black", fill="mediumseagreen", size=.15, show.legend = FALSE) +
  geom_sf(data=combined_spillovers_mapping[which(combined_spillovers_mapping$near_discovery==4),], color="black", fill="lightgreen", size=.15, show.legend = FALSE) +
  geom_sf(data=combined_spillovers_mapping[which(combined_spillovers_mapping$near_discovery==5),], color="black", fill="royalblue1", size=.15, show.legend = FALSE) +
  geom_sf(data=combined_spillovers_mapping[which(combined_spillovers_mapping$near_discovery==6),], color="black", fill="skyblue1", size=.15, show.legend = FALSE) +
  geom_sf(data=combined_with_geom[which(combined_with_geom$disappointed_pc_med==1),], color="black", fill="red4", size=.01, show.legend = FALSE)+ 
  geom_sf(data=combined_with_geom[which(combined_with_geom$disappointed_pc_med==2),], color="black", fill="darkgreen", size=.01, show.legend = FALSE)+
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.title.y=element_blank(),
        axis.ticks.y=element_blank(),
        legend.title = element_text(color = "black", size = 13),
        legend.text = element_text(color = "black", size = 11.5),
        #panel.background = element_rect(fill = 'white', colour = 'white')
  ) +
  coord_sf(xlim = c(-58, -34), ylim = c(-34, 0), expand = FALSE)
filename = paste("Texts/SpilloverZones_Combined.png")
ggsave(filename, width = 11, height = 11)
