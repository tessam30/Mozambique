### Documenting the process to convert .do into .ado and move into a base directory.
1) Convert the .do file into an .ado file by adding the following to the beginning of the file:
* ```program define nameOfProgram```
* ```end``` -- placed at the end of the code chunk  

2) Create folders in your perdonal adopath directory found at:
* ```c:\ado\personal/```
* The folders should be a single letter that corresponds to the first letter of the program name
* run the following command in Stata : ```adopath + path_or_codeword``` -- this will add the directory to the end of the ado-path search list. Stata will first look in core folder structure, and then search the personal paths for additional files.

3) Call your program as you normally would.
4) To check if the file exists use the ```findfile``` command or use ```which commandName.ado``` to view the source code. ```help adopath``` provides guidance on how to use the adopath command syntax.

##### Happy Stata'ing!
