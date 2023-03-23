# GBT-scripts
IDL scripts for the reduction of Green Bank Telescope data

Like every other radio telescope, the Green Bank Telescope in West Viginia (the world's largest steerable dish) has its own data reduction software. It uses a warpper to IDL (gbtidl), which can be very cumbersome to analyse wide-abd/high-resolution spectral line data. 

The script filters the data from a messy dateset (differnt frequnecies and different sources) and allows inspection of each scan before its addition to/rejection from the stack. The stack is then averaged and saved in a much more convenient and compact format (ascii file)
