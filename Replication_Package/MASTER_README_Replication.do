********************************************************************************
*Master do-file to replicate "Winning and losing the resource lottery: Governance after uncertain oil discoveries,"
*published in the Journal of Development Economics, Vol. 166 (2024), by Erik Katovich. 
*DOI: https://doi.org/10.1016/j.jdeveco.2023.103204

*Last modified date: February 20, 2024

*This replication package requires a combination of Stata and R scripts, 
*to be executed in the order defined in this Master do-file.

*First, install required packages as needed: 
*coefplot gtools grstyle grc1leg2 reghdfe outreg2 carryforward csdid rwolf egenmore coefplot 

********************************************************************************
*Setup 
version 16             // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
macro drop _all         // clear all macros

*DEFINE RELATIVE FILE PATHS HERE:
	global user "C:\Users\katovich\Dropbox\PhD\Research\Presource Curse"
	global replication "${user}\Do-Files\Replication_Package"
	global output "${user}\Output_Replication"
	
********************************************************************************
*1. DATA IMPORT, CLEANING, MERGING

*This section requires raw, publicly accessible datasets that are available for download online. 
*Refer to Replication_DataSources.pdf for a complete list of data references. 
*To clean individual public datasets of interest, download original data and save it in the 
*subfolder specified in Section 1 below. Then execute the associated script. 

	********************************************************
	*RUN R SCRIPT TO CONNET OFFSHORE WELLS TO MUNICIPALITIES
	*File Name: Geodesic_Projections_Construct.R 
	*Within this file, adjust working directory to location where Brazil_GeodesicProjections folder is saved on computer.
	********************************************************

	*Import well-level production data, clean, and append into well-year panel 
	do "${replication}\Wells_Production.do"

	*Import and clean data on well registry, hydrocarbon announcements, CVM announcements,
	*and well-municipality linkages (built in R)
	do "${replication}\Wells_Organizing.do"

	*Redo merging with wells from all years, rather than only wells from 2000-2017. 
	*This matters for getting production right, since wells before 2000 continue producing during sample period
	do "${replication}\Wells_Production_Merging_AllYears.do"

	*Collapse well-level panel to municipality level to create municipality treatment panel
	do "${replication}\Wells_Collapsing.do"

	*Import, clean, and organize RAIS panel on private sector outcomes (firm entry/exit, hires, oil-linked)
	do "${replication}\RAIS_PrivateSector.do"

	*Clean data from 2010 Demographic Census on in-migration into municipality-level panel 
	do "${replication}\Census_InMigration.do"

	*Import, clean, and organize panel on Federal to Municipality Transfers
	do "${replication}\Transfer_Panel.do"

	*Import, clean, and organize SUS data on health public goods 
	do "${replication}\Health_PublicGoods_Cleaning.do"

	*Import, clean, and organize Basic Education Census data on education public goods
	do "${replication}\Education_PublicGoods_Cleaning.do"

	*Clean Bolsa Familia data 
	do "${replication}\Welfare_Cleaning.do"

	*Import, clean, and organize data on school enrollment 
	do "${replication}\Matriculation.do"

	*Import, clean, and organize FIRJAN Municipal Development Index Public Goods data
	do "${replication}\FIRJAN_PublicGoods.do"

	*Import and clean population data from IBGE and FINBRA 
	do "${replication}\Population_Panel_Municipalities.do"

	*Merge municipality-level treatment panel with municipality-level outcomes, including
	*oil royalties and special participations, public finance from IPEA and FINBRA, baseline covariates
	*from the Census and IPEA, yearly data on oil prices, SELIC, exchange rate, etc., and public employment
	*data from RAIS.
	do "${replication}\Municipalities_Merging_Wells_Outcomes.do" 

	*Organize elections data for analysis (data imported from deforestation project, clean this up later)
	do "${replication}\Election_DataPrep.do"

	*Import and organize candidates data to create party alignment panel (municipality, state, and federal levels)
	do "${replication}\Political_Alignment.do"
	
	*Import and process data on field-level production delays
	o "${replication}\Field_Coordinates.do"

	
********************************************************************************
********************************************************************************

*Execution of the preceding do-files creates intermediate .dta files used in Sections 2-4.
*The Data_Directory_Replication folder already contains the necessary intermediate files
*to execute all subsequent do-files. Thus, Section 1 may be skipped unless you are specifically
*interested in cleaning original public datasets. 

********************************************************************************
********************************************************************************


*2. PERFORM INTERMEDIATE DATA PROCESSING AND ANALYSES

	*Calculate production and revenue expectations forecasts for each oil-affected municipality 
	*Use forecasts to categorize municipalities' disappointment 
	do "${replication}\Munics_Affected_by_Oil.do"

	do "${replication}\Revenue_Expectations_Forecast.do"

	*Prepare dataset for analysis (creates inputs for matching and affected by oil)
	do "${replication}\DataPrep_for_EventStudies.do"

	*Output data to R for Sant'Anna and Callaway event studies
	do "${replication}\SantAnna_EventStudy_Setup.do"

	*Perform main matching (CEM on 2000 characteristics)
	do "${replication}\Matching_RelativeTime.do"

	*Perform alternative matching (CEM on 2000, 2001 revenues and spending)
	do "${replication}\Matching_on_Revenues.do"


********************************************************************************
*3. EMPIRICAL ANALYSES 

	*****************************************
	*Generate MAIN RESULTS using CS estimator 
	do "${replication}\CS_EventStudies.do"
	*****************************************

	*Analyze matched data using CS estimator
	do "${replication}\CS_EventStudies_MatchedDataset.do"

	*Analyze election outcomes 
	do "${replication}\Analysis2_Elections.do" 
	*Note: results do not output automatically to table. 

	*Analyze reelection rates in disappointed municipalties
	do "${replication}\Reelections_Disappointment.do"
	*Note: results do not output automatically to table. 
	
	*Test for conditional random assignment of success/disappointment 
	do "${replication}\Conditional_Random_Assignment_Tests.do"
	*Note: results do not output automatically to table. 

	*Perform sensitivity/robustness checks for event studies
	do "${replication}\EventStudy_Robustness.do"

	*Graph parallel pre-trends 
	do "${replication}\Parallel_Trends_Graphs.do"

	*Graph panel balance across relative time indicators 
	do "${replication}\Balance_Graphs.do"

	*Create balance tables and calculate T-Tests for different samples 
	do "${replication}\Balance_Tables.do"
	*Note: results do not output automatically to table.

********************************************************************************
*4. GENERATE GRAPHS AND FIGURES 

	*Graph discoveries and revenues
	do "${replication}\Graphs_Discoveries_Revenues.do"
	*Note: figures do not output automatically.
	
	*Graph international oil prices and Brazilian discoveries
	do "${replication}\Graph_Discoveries_and_Prices.do"
	*Note: figures do not output automatically.
	
	*Graph FDI inflows, news coverage, and transfers
	do "${replication}\Graphs_FDI_News_Transfers_Delays.do"
	*Note: figures do not output automatically.
	
	*Graph scatterplot of years-to-production forecasts versus actual production dates
	do "${replication}\Years_to_Production_Forecasts.do"
	*Note: figures do not output automatically.
	
	*Graph forecasts of national production and realized national production 
	do "${replication}\Production_vs_Forecasts.do"
	*Note: figures do not output automatically.
	
	*******************************************
	*******************************************
	*Supplementary Spatial Analyses, requiring a combination of R and Stata scripts:

	*Output data on treatment and control samples for mapping in R 
	do "${replication}\Samples_Maps.do" 

	*Output data on treatment codes to R for spatial spillovers analysis 
	do "${replication}\TreatmentCodes_SpatialSpillovers.do"

	*RUN R SCRIPT TO GENERATE MAP OF TREATED AND CONTROL MUNICIPALITIES 
	*File Name: Samples_Maps.R
	*Within this file, adjust working directory to location where Data Directory folder is saved on computer.

	*RUN R SCRIPT TO IDENTIFY SPATIAL SPILLOVER MUNICIPALITIES 
	*File Name: Spatial_Spillovers_Discoveries.R
	*Within this file, adjust working directory to location where Data Directory folder is saved on computer.

	*Spatial spillovers 
	do "${replication}\Spatial_Spillovers.do"

	*RUN R SCRIPT TO MAP SPATIAL SPILLOVER MUNICIPALITIES 
	*File Name: Spatial_Spillovers_Zones_Mapping.R
	*Within this file, adjust working directory to location where Data Directory folder is saved on computer.