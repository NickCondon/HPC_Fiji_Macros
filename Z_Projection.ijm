//Modified by Nicholas Condon (n.condon@uq.edu.au)

/*
 * Script: IPP Batch Z-projection
 * 
 * Description: Takes a folder of images and performs Z-projection with optional directory concatenation.
 * 
 * Input Requirements:
 *    input (string to file location) - AUTOPOPULATED
 *    output (string to file location) - AUTOPOPULATED
 *    suffix (string of file extension) - E.G .tif / .czi / .lif
 *    projectiontype List of available Z-projection options
 *    conc (radio button for concatenation or not)
 *    fps (integer for .avi fps) - E.G. the frame rate of the output video file
 */


//Written to run on the Institute for Molecular Bioscience & Research Computing Centre's Image Processing Portal
//See ipp.rcc.uq.edu.au for more info



// Original ImageJ Macro Script that loops through files in a directory written by Adam Dimech
// https://code.adonline.id.au/imagej-batch-process-headless/

// Specify global variables
print("\\Clear");


#@ String input
#@ String output
#@ String suffix
#@ String (choices={"Max Intensity", "Min Intensity", "Average Intensity", "Sum Slices", "Standard Deviation", "Median ", "No Projection"}, style="listBox") projectiontype
#@ String (choices={"Concatenate", "Do not concatenate"}, style="radioButtonHorizontal") conc
#@ Integer (value=10) fps
#@ Boolean(label="Kill Fiji on Finish?") exitFiji


if (conc=="Concatenate"){conc="1";}
if (conc=="Do not concatenate"){conc="0";}
fps = toString(fps);

fs = File.separator;
run("Bio-Formats Macro Extensions");

print("");print("");print("");
print("* * * * * * * * * * * * * * * * * * * * * * *");
print("");
print("IPP: Batch Z-projection");
print("");
print("* * * * * * * * * * * * * * * * * * * * * * *");
print("");print("");print("");


// Add trailing slashes
input=input+fs;
//output = input+fs+"Output"+fs;
outputDir =output;
File.makeDirectory(outputDir);

processFolder(input);
concFile(input,conc,fps);
compression="None";
tif="1";


// Scan folders/subfolders/files to locate files with the correct suffix

function processFolder(input) {
	list = getFileList(input);
	for (i = 0; i < list.length; i++) {
		//if(File.isDirectory(input + list[i]))
		//	processFolder("" + input + list[i]);
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

Ext.openImagePlus(input+file)
windowtitle = getTitle();
windowtitlenoext = replace(windowtitle, suffix, "");

if (projectiontype!="No Projection") {
		print("Performing Z-Projection");
		run("Z Project...", "projection=["+projectiontype+"] all");
		print("Saving .tif  (Z-Projection Type = "+projectiontype+")");
		saveAs("Tiff", output+fs+ windowtitlenoext+"_" +projectiontype);
		
}

if (projectiontype=="No Projection") {
	print("Saving .tif  (Z-Projection Type = "+projectiontype+")");
	saveAs("Tiff", output+fs+ windowtitlenoext+"_" +"converted");
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
	run("AVI... ", "compression="+compression+" frame="+fps+" save=[" + output+fs+"Concatenated-MOVIE__.avi"+ "]");
}}


// A final statement to confirm the task is complete...

print("Task complete.");

if (exitFiji) {
    eval("script", "System.exit(0);")
}

