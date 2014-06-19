#!/usr/bin/perl

# name:	emscanConfig.pl
# author: Danny Frencham
# description:	reads configuration data from your
#				config file. Config data is stored in emscan.cfg by
#				default.
#

use Config::Simple;
use File::Path qw(make_path);

my $emscan_version = "v1.0.0";

# loads configuration 
sub load_config
{
	my ($config_file) = @_;
	
	if (!(-e $config_file))
	{
		die "Could not find configuration at path: $config_path";
	}
	
	$cfg = new Config::Simple($config_file);
	my @configParams = ("SSOCRPath",
						"PhotoDir",
						"PhotoSleepPause",
						"PhotoCount",
						"OCRCmd",
						"OCRMinusCmd",
						"MeterCSVPath",
						"UVCCapturePath",
						"UVCCaptureArgs",
						"PVOutputAPIKey",
						"DeletePhotosAfterOCR");
	
	foreach $cfg_item (@configParams)
	{
		if (!(defined $cfg->param($cfg_item)))
		{
			die "Parameter missing from configuration file: $cfg_item\n";
		}
		if ($cfg->param($cfg_item) eq "changeme")
		{
			die "You need to set a value for configuration item: $cfg_item\n";
		}
	}
	if (!(-e $cfg->param("SSOCRPath"))) 
	{
		die "SSOCR does not exist (or I don't have permissions) at path: ".$cfg->param('SSOCRPath')." $!";
	}
	if (!(-e $cfg->param("UVCCapturePath"))) 
	{
		die "UVC does not exist (or I don't have permissions) at path: ".$cfg->param('UVCCapturePath')." $!";
	}
	if (!(-d $cfg->param("PhotoDir"))) 
	{
		make_path($cfg->param("PhotoDir"), {
      		verbose => 1,
      		mode => 0711,
  		}) or die "Could not create photo directory: ".$cfg->param("PhotoDir")." $!";
	}
	if (!(-e $cfg->param("MeterCSVPath"))) 
	{
		open HANDLE, ">>$cfg->param('MeterCSVPath')" or die "Could not create Meter CSV file at path: ".$cfg->param('MeterCSVPath')." $!\n"; 
		close HANDLE; 
	}
	
	printf("%s config parameters loaded\n",scalar(@configParams));  
	return $cfg;
}

sub get_version()
{
	return $emscan_version;
}

1;