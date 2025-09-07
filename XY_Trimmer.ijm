//Modified by Nicholas Condon (n.condon@uq.edu.au)

/*
 * Script: IPP Batch 4D Cropping
 * 
 * Description: Takes a folder of images and performs 4D Cropping (X/Y/Z/T).
 * 
 * Input Requirements:
 *    input (string to file location) - AUTOPOPULATED
 *    output (string to file location) - AUTOPOPULATED
 *    suffix (string of file extension) - E.G .tif / .czi / .lif
 *    trimSize (string for crop offset from image border) - E.G 12
 */


//Written to run on the Institute for Molecular Bioscience & Research Computing Centre's Image Processing Portal
//see ipp.rcc.uq.edu.au for more info



// Original ImageJ Macro Script that loops through files in a directory written by Adam Dimech
// https://code.adonline.id.au/imagej-batch-process-headless/

// Specify global variables/
#@ String input
#@ String output
#@ String suffix
#@ String (value="12") trimSize

fs = File.separator;


// Add trailing slashes
input=input+fs;
//output = input+fs+"Output"+fs;
outputDir =output
File.makeDirectory(outputDir);

print("\\Clear");
print("");print("");print("");
print("* * * * * * * * * * * * * * * * * * * * * * *");
print("");
print("IPP: Batch XY Trimmer");
print("");
print("* * * * * * * * * * * * * * * * * * * * * * *");
print("");print("");print("");


processFolder(input);


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
run("Bio-Formats Importer", "open=["+input+file+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
//open(input+file);
windowtitle = getTitle();
windowtitlenoext = replace(windowtitle, suffix, "");
getDimensions(width, height, channels, slices, frames);
    makeRectangle(trimSize, trimSize, width-(2*trimSize), height-(2*trimSize));
    run("Crop");
	

saveAs("Tiff", output+fs+windowtitlenoext+"_Trimmed_"+trimSize+"pix_.tif"); 
while(nImages>0){selectImage(nImages);close();}
print (timestamp + ": Processing " + input + file); 
}
// A final statement to confirm the task is complete...
print("Task complete.");
