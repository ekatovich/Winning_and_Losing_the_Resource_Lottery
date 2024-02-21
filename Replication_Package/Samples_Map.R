#Load libraries

#Define working directory
setwd("C:/Users/17637/Dropbox/PhD/Research/Presource Curse/Data Directory")

library(geobr)
library(ggplot2)
library(sf)
library(sp)
library(dplyr)
library(rio)
library(geosphere)
library(foreign)
library(magick)
library(spData)
library(maptools)
library(ptinpoly)
library(ggsflabel)
library(data.table)
library(ggrepel)
library(viridis)


#####################
#Import required data
#####################

coastal_munic <- st_read("Brazil_GeodesicProjections/Inputs/Shapefiles/Mun_Linha_de_Costa_2018_20190308_Atrib.shp")
brazil <- read_country(year=2010)
state <- read_state(year=2010)

#Import samples 
samples <- read.csv("Treatment Variables/Samples_for_Mapping.csv")

#Import discovery locations 
discoveries <- read.csv("Discoveries/Discoveries_for_Mapping.csv")

#Change year to numeric
discoveries$announcement_year <- as.numeric(discoveries$announcement_year)


#####################
#Import optional data
#####################
#These datasets are not required in this script, but may be added to maps for illustrative purposes.

#Pre-sal polygon
pre_sal_polygon <- st_read("Brazil_GeodesicProjections/Inputs/Shapefiles/Poligono_Pre_Sal.shp")

#Bathimetric curves 
bath_curves <- st_read("Brazil_GeodesicProjections/Inputs/Shapefiles/rel_curva_batimetrica_l.shp")

#Oil fields
production_fields <- st_read("Brazil_GeodesicProjections/Inputs/Shapefiles/Campos_de_Producao.shp")

######################################
# Remove plot axis
no_axis <- theme(axis.title=element_blank(),
                 axis.text=element_blank(),
                 axis.ticks=element_blank())

##########################################################

#Merge samples with coastal_munic
coastal_samples <- merge(coastal_munic, samples, by=c('CD_GCMUN'), all.x=T) 

#coastal_samples$Sample <- as.character(coastal_samples$Sample)
#coastal_samples$Sample[is.na(coastal_samples$Sample)] <- "Coastal, No Oil Activity"
#coastal_samples[c("Sample")][is.na(coastal_samples[c("Sample")])] <- "Coastal, No Oil Activity"
#coastal_samples$Sample %>% replace_na("Coastal, No Oil Activity")

#Create subsample of southeast coast
southeast <- coastal_samples[coastal_samples$CD_RG_SIG == 'SE',]
south <- coastal_samples[coastal_samples$CD_RG_SIG == 'SU',]
north <- coastal_samples[coastal_samples$CD_RG_SIG == 'NO',]
northeast <- coastal_samples[coastal_samples$CD_RG_SIG == 'NE',]


###########################################################

#Add centroids for each municipality 
#Find centroid of every municipality in Brazil
centroid_se <- st_coordinates(st_centroid(southeast))
southeast_with_centroids <- cbind(southeast, centroid_se)

centroid_s <- st_coordinates(st_centroid(south))
south_with_centroids <- cbind(south, centroid_s)

centroid_n <- st_coordinates(st_centroid(north))
north_with_centroids <- cbind(north, centroid_n)

centroid_ne <- st_coordinates(st_centroid(northeast))
northeast_with_centroids <- cbind(northeast, centroid_ne)


##################################################
#Repeat with full map 
centroid <- st_coordinates(st_centroid(coastal_samples))
 munics_with_centroids <- cbind(coastal_samples, centroid)

########################
#Plot only discoveries
ggplot() +
  geom_sf(data=brazil, color="gray90", fill="gray90")+
  geom_sf(data=state, color="black", size=.3, show.legend = FALSE) +
  # geom_spoke(data = munic_points_2, aes(x = longitude, y = latitude, angle = radians_orthogonal, radius = length_orthogonal), size=.005)+
  coord_sf(xlim = c(-54, -34), ylim = c(-34, 5), expand = FALSE)+
  geom_point(data = discoveries, aes(x = longitude_base_dd, y = latitude_base_dd, size = imputed_volume_mmboe, color = announcement_year),
             shape = 21)+
  labs(color = "Announcement Year", size="Announced Discovery \nVolume (mmboe)")+
  #labs(colour="Announcement Year", fill= "Discovery")+
  scale_color_viridis(direction = 1, option = "D")+
  #scale_color_viridis(direction = -1, option = "B")+
  # geom_text_repel(data = munics_with_centroids, aes(x = X, y = Y, label = municipality), 
  #                  fontface = "bold", size=4, nudge_x = c(1, -1.5, 2, 2, -1), nudge_y = c(0.25, 
  #                                                                                          -0.25, 0.5, 0.5, -0.5))+
  #   geom_text_repel(data = discoveries, aes(x = longitude_base_dd, y = latitude_base_dd, label = field_label), 
  #                   fontface = "bold", size=4, nudge_x = c(1, -1.5, 2, 2, -1), nudge_y = c(0.25, 
  #                                                                                          -0.25, 0.5, 0.5, -0.5))+
  scale_size_continuous(range = c(2, 20))+
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.title.y=element_blank(),
        axis.ticks.y=element_blank(),
        legend.title = element_text(color = "black", size = 8),
        legend.text = element_text(color = "black", size = 8),
        panel.background = element_rect(fill = 'white', colour = 'white')
  )

filename = paste("Texts/Discoveries_Map_PDF.pdf")
ggsave(filename, width = 10, height = 16)



##########################################
#Now plot map with treated municipalities and offshore discoveries 

ggplot(data = munics_with_centroids) +
  geom_sf(data=brazil, color="gray90", fill="gray90")+
  geom_sf(data=state, color="black", size=.3, show.legend = FALSE) +
  geom_sf(aes(fill = Sample), size=0.001) +
  labs(fill = "Sample")+
  coord_sf(xlim = c(-54, -34), ylim = c(-34, 5), expand = FALSE)+
  geom_point(data = discoveries, aes(x = longitude_base_dd, y = latitude_base_dd, size = imputed_volume_mmboe, color = announcement_year),
             shape = 21)+
  labs(size="Announced Discovery Volume (mmboe)", color = "Announcement Year")+
  #labs(colour="Announcement Year", fill= "Discovery")+
  scale_color_viridis(direction = 1, option = "D")+
  #scale_color_viridis(direction = -1, option = "B")+
# geom_text_repel(data = munics_with_centroids, aes(x = X, y = Y, label = municipality), 
#                  fontface = "bold", size=4, nudge_x = c(1, -1.5, 2, 2, -1), nudge_y = c(0.25, 
#                                                                                          -0.25, 0.5, 0.5, -0.5))+
#   geom_text_repel(data = discoveries, aes(x = longitude_base_dd, y = latitude_base_dd, label = field_label), 
#                   fontface = "bold", size=4, nudge_x = c(1, -1.5, 2, 2, -1), nudge_y = c(0.25, 
#                                                                                          -0.25, 0.5, 0.5, -0.5))+
  scale_size_continuous(range = c(2, 20))+
  theme(axis.title.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.title.y=element_blank(),
        axis.ticks.y=element_blank(),
        legend.title = element_text(color = "black", size = 13),
        legend.text = element_text(color = "black", size = 11.5),
        panel.background = element_rect(fill = 'white', colour = 'white')
  )

  filename = paste("Texts/SampleMap_withDiscoveries.png")
  ggsave(filename, width = 11, height = 11)

  ###############################################################################
  #Plot separately for Southeast Region 
  ggplot(data = southeast_with_centroids) +
    geom_sf(data=brazil, color="gray90", fill="gray90")+
    geom_sf(data=state, color="black", size=.3, show.legend = FALSE) +
    geom_sf(aes(fill = Sample), size=0.001) +
    labs(fill = "Sample")+
    coord_sf(xlim = c(-48.5, -38), ylim = c(-26.25, -18), expand = FALSE)+
    geom_point(data = discoveries, aes(x = longitude_base_dd, y = latitude_base_dd, size = imputed_volume_mmboe, color = announcement_year),
               shape = 21)+
    labs(size="Announced Discovery Volume (mmboe)", color = "Announcement Year")+
    #labs(colour="Announcement Year", fill= "Discovery")+
    scale_color_viridis(direction = 1, option = "D")+
    #scale_color_viridis(direction = -1, option = "B")+
    # geom_text_repel(data = munics_with_centroids, aes(x = X, y = Y, label = municipality), 
    #                  fontface = "bold", size=4, nudge_x = c(1, -1.5, 2, 2, -1), nudge_y = c(0.25, 
    #                                                                                          -0.25, 0.5, 0.5, -0.5))+
    #   geom_text_repel(data = discoveries, aes(x = longitude_base_dd, y = latitude_base_dd, label = field_label), 
    #                   fontface = "bold", size=4, nudge_x = c(1, -1.5, 2, 2, -1), nudge_y = c(0.25, 
    #                                                                                          -0.25, 0.5, 0.5, -0.5))+
    scale_size_continuous(range = c(2, 20))+
    labs(title = "Southeast")+
    theme(axis.title.x=element_blank(),
          #axis.ticks.x=element_blank(),
          #axis.text.x=element_blank(),
          #axis.text.y=element_blank(),
          axis.title.y=element_blank(),
          #axis.ticks.y=element_blank(),
          legend.title = element_text(color = "black", size = 12),
          legend.text = element_text(color = "black", size = 10),
          panel.background = element_rect(fill = 'white', colour = 'white')
    )+ 
    annotate("text", label = "Within SLA", x = 4, y = 4, size=50)
  
  filename = paste("Texts/Southeast_withDiscoveries.png")
  ggsave(filename, width = 11, height = 11)
  
  
