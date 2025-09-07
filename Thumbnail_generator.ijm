
//Modified by Nicholas Condon (n.condon@uq.edu.au)

/*
 * Script: IPP Batch Thumbnail Generator (Image Scaler)
 * 
 * Description: Takes a folder of images and creates scaled 2D composite png outputs for quick previewing datasets.
 * 
 * Input Requirements:
 *    input (string to file location) - AUTOPOPULATED
 *    output (string to file location) - AUTOPOPULATED
 *    suffix (string of file extension) - E.G .tif / .czi / .lif
 *    brightness (string for brightness/contrast adjustment) - Options [ 'auto' OR 'reset']
 *    scale (number for image scale adjustment) - E.G <1 for reduction > 1 for increase
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
#@ String (choices={"Auto Scale Brightness & Contrast", "Reset Brightness and Contrast"}, style="radioButtonHorizontal") brightness
#@ float (value=0.5) scale


fs = File.separator;
run("Bio-Formats Macro Extensions");

print("");print("");print("");
print("* * * * * * * * * * * * * * * * * * * * * * *");
print("");
print("IPP: Batch Thumbnail Generator (Image Scaler");
print("");
print("* * * * * * * * * * * * * * * * * * * * * * *");
print("");print("");print("");

// Add trailing slashes
input=input+fs;
//output = input+fs+"Output"+fs;
outputDir =output
File.makeDirectory(outputDir);

//output=input+"Output"+"\\"; // This can be changed to a separate variable if need-be

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

Ext.openImagePlus(input+file)


title = getTitle();
getDimensions(width, height, channels, slices, frames);
for (ch = 1; ch <=channels; ch++) {
	Stack.setChannel(ch);
	if(brightness == "Reset Brightness and Contrast"){setMinAndMax(0, 65535);}
	if(brightness == "Auto Scale Brightness & Contrast"){run("Enhance Contrast", "saturated=0.35");}
}

Stack.setDisplayMode("composite");
getDimensions(width, height, channels, slices, frames);
if(slices>1){
	Stack.setSlice(slices/2);
	}

run("Scale...", "x="+scale+" y="+scale+" interpolation=Bilinear average create");
run("RGB Color", "slices frames");



saveAs("png", output+fs+title+"_thumbnail_scaled"+scale+".png");
while(nImages>0){selectImage(nImages);close();}

// Print log of activities for reference...

print (timestamp + ": Processing " + input + file); 
}

// A final statement to confirm the task is complete...

print("Task complete.");
eval("script", "System.exit(0);");
