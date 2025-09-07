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
//see ipp.rcc.uq.edu.au for more info



// Original ImageJ Macro Script that loops through files in a directory written by Adam Dimech
// https://code.adonline.id.au/imagej-batch-process-headless/

// Specify global variables
print("\\Clear");


#@ String input
#@ String output
#@ String suffix
#@ Integer workingchannel
#@ Integer Xoffset
#@ Integer Yoffset
#@ String (choices={"Do Not Flip Horizontal", "Flip horizontal"}, style="radioButtonHorizontal") flipHorizontal
#@ String (choices={"Do Not Flip Vertical", "Flip vertical"}, style="radioButtonHorizontal") flipVertical
#@ Integer (value=0) rotation
#@ Boolean(label="Kill Fiji on Finish?") exitFiji


if(flipHorizontal=="Do Not Flip Horizontal"){flipH = 0;}
if(flipHorizontal=="Flip Horizontal"){flipH = 1;}
if(flipVertical=="Do Not Flip Vertical"){flipV = 0;}
if(flipVertical=="Flip Horizontal"){flipV = 1;}
testRoffset = rotation;
testXoffset = Xoffset;
testYoffset = Yoffset;
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


// Scan folders/subfolders/files to locate files with the correct suffix

function processFolder(input) {
	list = getFileList(input);
	for (i = 0; i < list.length; i++) {
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

Ext.openImagePlus(input+file)
windowtitle = getTitle();
windowtitlenoext = replace(windowtitle, suffix, "");
getDimensions(width, height, channels, slices, frames);
numChannels = channels;

run("Split Channels");																																		//Splits channels
    	selectWindow("C"+workingchannel+"-"+windowtitle);																								//Sets green working channel
    	
    	if (flipH == 1) {run("Flip Horizontally", "stack");}																										//Runs Horizontal flip if selected
    	if (flipV == 1) {run("Flip Vertically", "stack");}																											//Runs Vertical flip if selected
    	if (testRoffset != 0) {run("Rotate... ", "angle="+testRoffset+" grid=1 interpolation=Bilinear");}															//Runs image rotation if selected
		run("Translate...", "x="+testXoffset+" y="+testYoffset+" interpolation=None stack");																		//Runs XY translation if selected
		print("Running Corrections");																																//Reports to log running corrections
	  

	  
		if(numChannels==2){run("Merge Channels...", "c1=[C1-"+windowtitle+"] c2=[C2-"+windowtitle+"] create");}
		if(numChannels==3){run("Merge Channels...", "c1=[C1-"+windowtitle+"] c2=[C2-"+windowtitle+"] c3=[C3-"+windowtitle+"] create");}
		if(numChannels==4){run("Merge Channels...", "c1=[C1-"+windowtitle+"] c2=[C2-"+windowtitle+"] c3=[C3-"+windowtitle+"] c4=[C4-"+windowtitle+"] create");}
			
		saveAs("Tiff", output+fs+windowtitlenoext+"_2DCorrected.tif"); 

while(nImages>0){selectImage(nImages);close();}

// Print log of activities for reference...

print (timestamp + ": Processing " + input + file); 
}



// A final statement to confirm the task is complete...

print("Task complete.");

if (exitFiji) {
    eval("script", "System.exit(0);")
}
