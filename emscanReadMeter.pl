#!/usr/bin/perl

# name:				emscanReadMeter.pl
# author: 			Danny Frencham
# description:		Attempts to take snapshots of your meter, 
#					then OCR the results. You WILL need to fine tune
#					the x/y coordinates in OCRCmd, and OCRMinusCmd.
# pre conditions:	You have ssocr installed
#					You have UVCCapture installed
#

use Scalar::Util qw(looks_like_number);
use POSIX 'strftime';
use Path::Class;
use autodie; # die if problem reading or writing a file
use Config::Simple;
use strict;
use warnings;
require 'emscanConfig.pl';

################## Start Config ##################
my $config_path = "./emscan.cfg";

################## Functions ##################

sub log_to_csv()
{
	my ($meter_csv,$log_directory,$import_string,$export_string) = @_;
	my $date_string = strftime '%Y%m%d', localtime;
	my $time_string = strftime '%H:%M', localtime;

	print "Logging output to file ".$meter_csv."\n";
	my $dir = dir($log_directory); 
	my $file = $dir->file($meter_csv); 
	my $file_handle = $file->open('>>');
	my $line = $date_string.",".$time_string.",".$import_string.",".$export_string;
	$file_handle->print($line . "\n");
	undef $file_handle;
}

################## Main ##################

print "Emscan Read Meter script loaded (".&get_version.")\n";

# read settings
my $settings;
$settings = load_config( $config_path ) or die "Could not load config file";

#print config vars
#my %Config = $settings->vars();
#print "$_\n" for keys %Config;

my $now = strftime '%Y%m%d%H%M', localtime;
my $import = "";
my $export = "";
my @pics;

my $loopnum = $settings->param("PhotoCount");
looks_like_number($loopnum) or die "PhotoCount does not look like a number";
print "Capturing ";
for (my $i=0; $i<$loopnum; $i++)
{
	my $cmd = $settings->param("UVCCapturePath")." ".$settings->param("UVCCaptureArgs")." -o".$settings->param("PhotoDir").$now."_".$i.".jpg";
	my $output = `$cmd`;
	#print $cmd."\n".$output; exit;
	print ".";
	push(@pics,$settings->param("PhotoDir").$now."_".$i.".jpg");
	sleep($settings->param("PhotoSleepPause"));
}
print "\n";

my $item;
foreach $item (@pics)
{
	my $thresh = "40";
	my $ocr_cmd = $settings->param("OCRCmd");
	
	# set Threshhold value
	$ocr_cmd =~ s/THRESH/$thresh/;
	my $ocr = $settings->param("SSOCRPath")." ".$ocr_cmd;
	
	# attempt OCR
	my $ocrresult = `$ocr $item`;
	print "OCR result: $ocrresult";
	
	#print command string
	#print "$ocr $item \n";
	
	# sanity check ocr result
	if ((substr($ocrresult,0,1) eq "0") && (substr($ocrresult,0,2) ne "0b") 
		&& (length($ocrresult) == 7) && looks_like_number($ocrresult))
	{
		# check if negative. Do this as separate call due to lighting/threshold complexities
		$ocr = $settings->param("SSOCRPath")." ".$settings->param("OCRMinusCmd");
		my $ocrresult2 = `$ocr $item`;
		if ((substr($ocrresult2,0,1) eq "-"))
		{
			print " Corrected OCR result: -$ocrresult";
			chomp($export = "-$ocrresult");		
		}
		else
		{
			chomp($import = $ocrresult);
		}
	}
	if (($import ne "") && ($export ne ""))
	{
		# found results, exit
		print "Found values, exiting early\n";
		last;
	}
}

#clean up, delete photos now that we have result
if ($settings->param("DeletePhotosAfterOCR") eq "1")
{
	if (unlink(@pics)){ print "Screenshots cleaned up\n";}
	else { print "Clean up error, could not delete files\n"; }	
}
else
{
	print "Photos preservered (\"DeletePhotosAfterOCR has value other than 1\")\n";
}

if (($import ne "") && ($export ne ""))
{
	my $logPath = $settings->param("MeterCSVPath");
	#&log_to_csv("meter2.csv",$logPath,$import,$export);
	print "Success! Import: $import, Export: $export\n";
}
else
{
	print "Failed :(\n";
}




