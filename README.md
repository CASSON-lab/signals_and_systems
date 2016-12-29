# signals_and_systems
29.12.16

This repository contains files made avaiable as part of teaching the course "Signals and Systems" EEEN20027 for the School of Electrical and Electronic Engineering at the University of Manchester, UK.

GUI to show impulse responses due to different pole locations in the Laplace domain. 

Move the poles locations to see how these affect the system impulse response. Displays: 
 - The location of the poles in the s domain. (Plotting Re(s) as an x coordinate and Im(s) as a y coordinate). 
 - The transfer function this corresponds to in the Laplace domain, H(s). For simplicity this assumes no zeros are presenet. 
 - The inverse Laplace transform of H(s). That is, h(t) the impulse response. 
 - A plot of the impulse response h(t). 
Use this GUI to see how he imaginary part of the poles gives the oscillation frequency. The real part of the poles gives the amount of damping present. When the real part is >= 0 the system becomes unstable. 

All files were created in Matlab 2016a. They do not work correctly when run in earlier versions of Matlab. To run correctly the Control Systems toolbox is also required. 

To run the script you can either:
 - Use the .m file in the matlab_code folder.
 - Install the Matlab app by double clicking on the .mlappinstall file in the premade_app_files folder.
