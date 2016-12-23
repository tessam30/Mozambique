import arcpy, os

arcpy.Intersect_analysis(in_features="MZGE61FL #;Mozambique_Livelihoods2013 #",out_feature_class="C:/Users/tessam/Documents/Mozambique/GIS/MozambiqueLAM.gdb/MZGE61FL_FEWSNet_livelihoods",join_attributes="ALL",cluster_tolerance="#",output_type="INPUT")
