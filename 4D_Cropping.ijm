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
 *    xcoords (string for X coordinates) - Format should be Xmin,Xmax (if not being used leave as 0-0)
 *    ycoords (string for Y coordinates) - Format should be Ymin,Ymax (if not being used leave as 0-0)
 *    zcoords (string for Z coordinates) - Format should be Zmin,Zmax (if not being used leave as 0-0)
 *    tcoords (string for T coordinates) - Format should be Tmin,Tmax (if not being used leave as 0-0)
 */


//Written to run on the Institute for Molecular Bioscience & Research Computing Centre's Image Processing Portal
//see ipp.rcc.uq.edu.au for more info



// Original ImageJ Macro Script that loops through files in a directory written by Adam Dimech
// https://code.adonline.id.au/imagej-batch-process-headless/

// Specify global variables/
#@ String input
#@ String output
#@ String suffix
#@ String (value="0-0") xcoords
#@ String (value="0-0") ycoords
#@ String (value="0-0") zcoords
#@ String (value="0-0") tcoords

fs = File.separator;
run("Bio-Formats Macro Extensions");


// Add trailing slashes
input=input+fs;
//output = input+fs+"Output"+fs;
outputDir =output
File.makeDirectory(outputDir);

print("\\Clear");
print("");print("");print("");
print("* * * * * * * * * * * * * * * * * * * * * * *");
print("");
print("IPP: Batch 4D Cropping");
print("");
print("* * * * * * * * * * * * * * * * * * * * * * *");
print("");print("");print("");


XcropExclude = 0;
YcropExclude = 0;
ZcropExclude = 0;
TcropExclude = 0;


if (xcoords=="0-0"){XcropExclude =1;xlist=newArray(2);}
	else{ xlist = split(xcoords,"-");}
if (ycoords=="0-0"){YcropExclude =1; ylist=newArray(2);}
	else{ ylist = split(ycoords,"-");}
if (zcoords=="0-0"){ZcropExclude =1; zlist=newArray(2);}
	else{ zlist = split(zcoords,"-");}
if (tcoords=="0-0"){TcropExclude =1; tlist=newArray(2);}
	else{ tlist = split(tcoords,",");}

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
windowtitle = getTitle();
windowtitlenoext = replace(windowtitle, suffix, "");
getDimensions(width, height, channels, slices, frames);
if (XcropExclude==1){xlist=newArray(0,width);}
if (YcropExclude==1){ylist=newArray(0,height);}
if (ZcropExclude==1){zlist=newArray(1,slices);}
if (TcropExclude==1){tlist=newArray(1,frames);}
run("Split Channels");
for (i = 1; i <= channels; i++) {
   	selectWindow("C"+i+"-"+windowtitle); 
    makeRectangle(xlist[0], ylist[0], xlist[1]-xlist[0], ylist[1]-ylist[0]);
    run("Crop");
	}
mergeChString = "";
for (k = 1; k<= channels; k++){
	mergeChString = mergeChString+"c"+k+"=["+"C"+k+"-"+windowtitle+"] ";
	}
run("Merge Channels...", mergeChString);
if(slices != 1){
	run("Make Substack...", "slices="+zlist[0]+"-"+zlist[1]+" frames="+tlist[0]+"-"+tlist[1]);
	}
saveAs("Tiff", output+fs+windowtitlenoext+"__cropped_X"+xlist[0]+"-"+xlist[1]+"_Y"+ylist[0]+"-"+ylist[1]+"_Z"+zlist[0]+"-"+zlist[1]+"_T"+tlist[0]+"-"+tlist[1]+".tif"); 
while(nImages>0){selectImage(nImages);close();}
print (timestamp + ": Processing " + input + file); 
}
// A final statement to confirm the task is complete...
print("Task complete.");
eval("script", "System.exit(0);");
