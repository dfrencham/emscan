#!/usr/bin/perl

# name:				emscanPVUpload.pl
# author: 			Danny Frencham
# description:		This script calculates daily import/export figures
#					from your meter csv file. 
# pre conditions:	Your meter.csv file has 2 or more rows of data.
#					Your pvoutput API Key and System Id are configured.
#

use HTTP::Request::Common qw(POST GET);
use LWP::UserAgent;
use DateTime::Format::Strptime;
use File::Basename;
use Scalar::Util qw(looks_like_number);
use Config::Simple;
require 'emscanConfig.pl';

################## Start Config ##################
my $config_path = "./emscan.cfg";
my $config_file = './emscanLastUpload.cfg';

################## Functions ##################
sub parse_file
{
	my ($config_settings,$last_submit) = @_;
	
	my $file = $config_settings->param("MeterCSVPath")."meter.csv";
	my @data;
	open(my $fh, '<', $file) or die "Can't read file '$file' [$!]\n";
	while (my $line = <$fh>) {
	    chomp $line;
		my @fields = split(/,/, $line);
	    push @data, \@fields;
	}
	close($fh);
	
	for (my $i=0;$i<=$#data;$i++)
	{
		my $date = $data[$i][0];
		if (looks_like_number($date) && ($date > $last_submit) && ($i > 0)){		
			#print "Date: $date LastSubmit: $last_submit\n";
			my $time = $data[$i][1];
			my $import = $data[$i][2] - $data[$i-1][2];
			my $export = ($data[$i][3]*-1) - ($data[$i-1][3]*-1);
			#print "Submit $date $import -$export\n";
			pvouput($config_settings,$import,$export,$date,$time);
		}
	}
}

sub	pvouput
{ 
	my ($config_settings,$import,$export,$date,$time) = @_; 
	my $pvoutput_apikey = $config_settings->param("PVOutputAPIKey"); 
	my $pvoutput_sysid = $config_settings->param("PVOutputSysId");
	
	printf("Submitting: Date %s, Time %s, Export %s, Import %s \n", $date, $time, $export, $import);
	#exit;
	
	my $ua = LWP::UserAgent->new;
	$ua->default_header(
					"X-Pvoutput-Apikey" => $pvoutput_apikey,
					"X-Pvoutput-SystemId" => $pvoutput_sysid,
					"Content-Type" => "application/x-www-form-urlencoded");

	my $pvoutput_url = "http://pvoutput.org/service/r2/addoutput.jsp";				
					

	# v1 export
	# v3 import
	# n net = 1
	my $request = POST $pvoutput_url, [ d => $date, e => ($export*1000), ip => ($import*1000) ];
	my $res = $ua->request($request);

	if (! $res->is_success) {
		die "Couldn't submit data to pvoutput.org:" . $res->status_line . "\n";
	}
	else
	{
		printf(" Response: ".$res->content."\n");
		$cfg->param("LastSubmit",$date);
		$cfg->write() or die "Could not write last submit date to file";
	}
}

################## Main ##################

print "Emscan PVOutput API Submission script loaded (".&get_version.")\n";

# read settings
my $settings;
$settings = load_config( $config_path ) or die "Could not load config file";

my $last_submit;
$cfg = new Config::Simple($config_file);
if (defined $cfg->param("LastSubmit")) {
	printf("Last Submit: %s\n",$cfg->param("LastSubmit"));  
}

&parse_file($settings,$cfg->param("LastSubmit"));
print "Execution complete.\n";
exit;
