// Blank ImageJ Macro Script that loops through files in a directory
// Written by Adam Dimech
// https://code.adonline.id.au/imagej-batch-process-headless/


// Specify global variables

#@ String input
#@ String output
#@ String suffix
#@ String (choices={"Max Intensity", "Average Intensity"}, style="listbox") projectiontype
#@ String conc
#@ String fps


//Input = getArgument();

//print (Input); 

//input = Input.input;
//#@String output
//suffix = Input.suffix;
//projectiontype = Input.projectiontype;
//conc = Input.conc;
//fps = Input.fps;

// Add trailing slashes

fs = File.separator;

input=input+fs;
output=output+fs";
print(input)
outputDir = output+"Output"+fs;
File.makeDirectory(outputDir);
output=outputDir;
print(output)
//output=input+"Output"+"\\"; // This can be changed to a separate variable if need-be
processFolder(input);
concFile(input,conc,fps);
compression="None";
tif="1";
fps=fps;


// Scan folders/subfolders/files to locate files with the correct suffix

function processFolder(input) {
	list = getFileList(input);
	for (i = 0; i < list.length-1; i++) {
		if(File.isDirectory(input + list[i]))
			processFolder("" + input + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

// Loop through each file

function processFile(input, output, file) {

// Define all variables

Months = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"); // Generate month names
DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat"); // Generate day names
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
timestamp ="";
if (dayOfMonth<10) {timestamp = timestamp+"0";}
timestamp = ""+DayNames[dayOfWeek]+" "+Months[month]+" "+dayOfMonth+" "+year+", "+timestamp;
if (hour<10) {timestamp = timestamp+"0";}
timestamp = timestamp+""+hour;
if (minute<10) {timestamp = timestamp+"0";}
timestamp = timestamp+":"+minute+"";
if (second<10) {timestamp = timestamp+"";}
timestamp = timestamp+":"+msec;

// Do something to each file
//run("Bio-Formats Importer", "open=["+input+file+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
open(input+file);
windowtitle = getTitle();
windowtitlenoext = replace(windowtitle, suffix, "");

if (projectiontype!="No Projection") {
		print("Performing Z-Projection");
		run("Z Project...", "projection=["+projectiontype+"] all");
		print("Saving .tif  (Z-Projection Type = "+projectiontype+")");
		saveAs("Tiff", output+ windowtitlenoext+"_" +projectiontype);
		
}


while(nImages>0){selectImage(nImages);close();}

// Print log of activities for reference...

print (timestamp + ": Processing " + input + file); 
}


function concFile(input,conc,fps) {
	if (conc=="1"){
		compression="None";
	//output=input+"Output"+"/";
	print("");
	print("Opening files for concatenation");
	File.openSequence(output);
	run("AVI... ", "compression="+compression+" frame="+fps+" save=[" + output +"Concatenated-MOVIE__.avi"+ "]");
}}


// A final statement to confirm the task is complete...

print("Task complete.");

