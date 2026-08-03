**iGAMSI analysis pipeline**
The iGAMSI-related analysis pipeline can be found in the 'iGAMSI-analysis' folder
(or https://github.com/HoraceChan99/iGAMSI)

**NonRigid Registration**
---------
This Matlab code is designed for the analysis of expansion isotropy betweeen pre-expansion image and post-expansion image.

This readme file shows how to properly run the NonRigid Registration code 


**System requirements** 
--------

We have implemented this code using the following software items:

Matlab R2022a


**Installation guide** 
--------

Download the code and unzip the file to desktop. Put the path in the search path of Matlab. Installation time is less than 5 minutes. The code does not require any non-standard hardware to run.
	
**Instructions for use** 
--------

"NonRigidReg_MasterScript_ver202008.m" is the main file. Detailed operation can be found in the annotation of the code. Briefly, first change the parameter of code, then excute the code in Matlab. The code will automatically output the results. Add the folder 'NonRigidReg_version23_JY_local' to path in Matlab.

**Demo** 
--------
A folder containing the demo data is included. The registration points are indicated. The expected run time is about 30 minutes. The code is expected to generated one figure file showing the image registration results and one plot reporting r.m.s measurement vs measurement length.  

