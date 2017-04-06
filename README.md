# README #

This README is intended to summarize the development of the DocGenerator application.

### What is this repository for? ###

* This repository will be used mainly or development purposes, but also as a way to distribute the application it i'm able to make it work.
* 1.2 BETA
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)

### How do I get set up? ###

* For the moment (v1.2) it has to run from CMD. Just move to /src folder and run `'python.exe mdocGen.py [-i <inputdir>] [-o <outputdir>] [-l <projectlogo>] [-n <projectname>] [-r -u -c -v -h]'`
> -h -- Get usage hints CMD
> -i -- Specify input directory (default) ./ 		
> -o -- Specify output directory (default) ../doc 		
> -l -- Specify path to project logo			
> -n -- Specify project's name		
> -r -- Perform recursive scan (check subdirectories)		
> -u -- Check mutual ussage between files			
> -c -- Append source code to documentation		
> -v -- Verbose mode

EXAMPLE: assuming source files (.m) located in \MyFolder\src\,
1) open a cmd in \MyFolder
2) type: python {path to location of mdocGen.py}\mdocGen.py -i .\src -o .\doc -r -u -c -v
will parse recursively all files located in \MyFolder\src\ and all its subdirectories checking mutual usage between objects and
appending code to generated outputs while running in verbose mode.
Te generated documentation shall be found at \MyFolder\doc\

NOTE: the specify paths without quotes!!

* The configuration cannot be simpler:

It uses the Python's libraries Jinja2 (for HTML templating), time (for execution time and dates), os (for path operations), itertools (for mutual usage checking), re (for regular expressions searching and substitution), copy2 (for copying single files), copy_tree (for copying directories), sys (for command line arguments) and getopt (for argument parsing).

NOTE: Python version 3.6!!!!

### What is the header the .m files has to have? ###

* For functions
>
function [ nameofout1, nameofout2 ] = myfunc( namein1, namein2 )    
>%function summary of the function   
>%
>%%
>%   -@desc here an extended description of the function. It supports multi line: Lorem ipsum dolor      
>% sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore     			
>% magna aliqua. Ut enim ad minim veniam, quis nostrud xercitation ullamco laboris nisi ut aliquip  			
>% ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum    			
>% dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa   			
>% qui officia eserunt mollit anim id est laborum.			
>%			
>%%			
>% -@ref www.reference1.be		
>% -@ref www.refe2.be			
>% -@ref references has to be single line ones			
>%			
>%%			
>%   The inputs for this funtion are:			
>%			
>%   -@iparam [type] namein1:Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do err 			
>%   eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quisrrt 			
>%   nostrud			
>%   -@iparam [type] nameofin1: description of out 2. If for example it's an struture, you can 			
>%     expand it:			
>%        -> [type] nameofstructfield1: description of field			
>%        -> [type] nameofstructfield2: description of field. In again its soooooooo long, you can			
>%        -> continue this way			
>%			
>%%			
>%   The outputs for this function are:			
>%			
>%   -@oparam [type] nameofout1: description			
>%   -@oparam [type] nameofout2: description of out 2. If for example it's an struture, you can 			
>%     expand it:			
>%        -> [type] nameofstructfield1: description of field			
>%        -> [type] nameofstructfield2: description of field. In again its soooooooo long, you can			
>%        -> continue this way			
>%			
>%%			
>%   -@author me			
>%   -@company mine			
>%   -@date 28/03/17			
>%   -@version 1.1			
>%%			
>%%%			
>			

* For classes
>			
>classdef myclass			
>%myclass summary of the class			
>%			
>%%			
>%   -@desc here an extended description of the function. It supports multi line: Lorem ipsum dolor  			
>% sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore     			
>% magna aliqua. Ut enim ad minim veniam, quis nostrud >xercitation ullamco laboris nisi ut aliquip  			
>% ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum 			
>%			
>%%			
>%   -@ref www.reference1.be			
>%   -@ref www.refe2.be			
>%   -@ref references has to be single line ones			
>%			
>%%			
>%	  -@attribute name: value			
>%			
>%%			
>%   -@method [void] getDate: onedue methods are called so often!			
>%   -@method [type] method2: description of method 2. If for example returns an struture, you can 			
>%    expand it:			
>%        -> [type] nameofstructfield1: description of field			
>%        -> [type] nameofstructfield2: description of field. In again its soooooooo long, you can			
>%        -> continue this way. This struct field it's a struct itself, so:			
>%            --> [type] stru1: description			
>%            --> [type] stru2: description multi line Lorem ipsum dolor sit amet, consectetur       			
>%            --> adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna      			
>%            --> aliqua. Ut enim ad			
>%			
>%%			
>%   -@property [int] dbg: sooo boring			
>%   -@property [custom] me: the other is called dbg but it's a me, maario!!!			
>%			
>%%			
>%   -@author me			
>%   -@company mine			
>%   -@date 28/03/17			
>%   -@version 1.0			
>%%			
>%%%			
>			

* For Scripts
>			
>%   -@desc Script used for whatever			
>%			
>%%			
>%   -@author me			
>%   -@company mine			
>%   -@date 28/03/17			
>%   -@version 1.0			
>%			
>%%			
>%%%			

### In conclussion... ###

* Supported Tags

-@desc                            // description			
-@ref                             // reference(s)			
-@iparam [type] name: description // input params			
-@oparam [type] name: description // output params			
-@author                       			
-@company			
-@date			
-@version			
-@method [type] name: description // class method			
-@attribute name: description     // class attribute			
-@property [type] name: description // class property			
-%% delimiter used for sections (needed)			
- -> adds \t\t
Only on parameters description (iparams, oparams, methods, properties, attributes and events)!!
- --> adds \t\t\t\t
- ---> adds \t\t\t\t\t\t
### Who do I talk to? ###

* Andrés Ferreiro González
* andres.ferreiro.glez@gmail.com
