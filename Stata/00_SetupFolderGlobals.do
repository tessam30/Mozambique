/*-------------------------------------------------------------------------------
# Name:		00_SetupFolderGlobals
# Purpose:	Create series of folders Food Rwanda Stunting Analysis
# Author:	Tim Essam, Ph.D.
# Created:	2016/04/27
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	see below
#-------------------------------------------------------------------------------
*/

/* RUN/READ ME FIRST -- Make directories for the study.
 1. Requires root name for file folder structure
 2. Requires branch names for sub-folders
 3. Sets global macros for the study; These are used through the do files.
 4. TODO -- Script DOES NOT copy in raw data at this point.
 5. TODO -- Create program folder for calling custom programs.
*/
set more off
	
* install the confirm directory ado if not already installed
* list all known user-written .ados needed for project
local required_ados confirmdir mvfiles fs spatgsa  adolist labellist winsor2   
foreach x of local required_ados { 
	capture findfile `x'.ado
		if _rc==601 {
			cap ssc install `x'
		}
		else disp in yellow "`x' currently installed."
	}
*end

* Determine path for the study 
*global projectpath "U:/"
*global projectpath "C:/Users/t/Documents/"
global projectpath "C:/Users/Tim/Documents/"
*global projectpath "C:/Users/tessam/Documents"
cd "$projectpath"

* Run a macro to set up study folder (needs to be modified)
* Name the file path below -- replace "Bangladesh" with your folder name
local pFolder Mozambique
foreach dir in `pFolder' {
	confirmdir "`dir'"
	if `r(confirmdir)'==170 {
		mkdir "`dir'"
		display in yellow "Project directory named: `dir' created"
		}
	else disp as error "`dir' already exists, not created."
	cd "$projectpath/`dir'"
	}
* end

* Run initially to set up folder structure
* Choose your folders to set up as the local macro `folders'
local folders Rawdata Stata Datain Log Output Dataout Excel PDF Word Graph GIS Export R Python Programs Sensitive_Data FinalProducts
foreach dir in `folders' {
	confirmdir "`dir'"
	if `r(confirmdir)'==170 {
			mkdir "`dir'"
			disp in yellow "`dir' successfully created."
		}
	else disp as error "`dir' already exists. Skipped to next folder."
}
*end

/*---------------------------------
# Set Globals based on path above #
-----------------------------------*/
global date $S_DATE
local dir `c(pwd)'
global path "`dir'"

global pathdo "`dir'\Stata"


* DHS specific paths
global pathkids "`dir'/Datain/DHS2011/mzkr62dt"
global pathwomen "`dir'/Datain/DHS2011/mzir62dt"
global pathmen "`dir'/Datain/DHS2011/mzmr62dt"
global pathroster "`dir'/Datain/DHS2011/mzpr62dt"
global pathhh "`dir'/Datain/DHS2011/mzhr62dt"
global pathgit "C:/Users/tessam/Documents/Github/Mozambique"

global pathlog  "`dir'\Log"
global pathin "`dir'\Datain"
global pathout "`dir'\Dataout"
global pathgraph "`dir'\Graph"
global pathxls "`dir'\Excel"
global pathreg "`dir'\Output"
global pathgis "`dir'\GIS"
global pathraw "`dir'\Rawdata"
global pathexport "`dir'\Export"
global pathR "`dir'\R"
global pathProgram "`dir'/Program"
global pathSensitive "`dir'/Sensitive_Data"
global pathProducts "`dir'/FinalProducts"


* Project macros are defined as:
macro list 

* Add in subfolders for GIS and Final Products Folders
cd "$pathgis"
local gisfolders FeatureClass Shapefiles csv Layers mxd Rasters scratch
foreach dir in `gisfolders' {
	confirmdir "`dir'"
	if `r(confirmdir)'==170 {
			mkdir "`dir'"
			disp in yellow "`dir' successfully created."
		}
	else disp as error "`dir' already exists. Skipped to next folder."
}
*end

cd "$pathProducts"
local subfolders AI PDFs PosterJPG PPTJPG 
foreach dir in `subfolders' {
	confirmdir "`dir'"
	if `r(confirmdir)'==170 {
			mkdir "`dir'"
			disp in yellow "`dir' successfully created."
		}
	else disp as error "`dir' already exists. Skipped to next folder."
}
*end


/*------------------------------------------------------------
# Manually copy raw data  into Datain Folder #

