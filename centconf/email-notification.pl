#!/usr/bin/perl -w

# Author: Arun
# 2010

sub BEGIN
{
        unshift (@INC, '/home/centconf/module/');
}

use strict;
use warnings;
use Centconfig;
use DBI;
use DBD::mysql;
use XML::Parser;
use XML::Simple;
#use Data::Dumper;

###################### 
#DB connection details
#connection details
my $hash_ref=Centconfig::config_parse;
my $db=${$hash_ref}{database};
my $host=${$hash_ref}{db_host};
my $user=${$hash_ref}{db_user};
my $password=${$hash_ref}{db_password};
#####################
sub parse_xml_log
{
    my($log_msg) = (@_);
    my $xml = XML::Simple->new( SuppressEmpty => 1,ForceArray => 1);
    ############### is valid xml ###############
    my $data; 
    eval { $data = $xml->XMLin($log_msg);};
    if ($@) { return("Error: XML parsing error");}
    else
    {
	#print Dumper($data);
    	#print "\nInfo=>@{$data->{'info'}}\nFail=>@{$data->{'fail'}}\nSvnErr=>@{$data->{'svn_error'}}\nChange=>@{$data->{'change'}}\nReplace=>@{$data->{'replace'}}\nDiff=>@{$data->{'diff'}}\nNot_Found=>@{$data->{'not_found'}}";
    	return("\nInfo=>@{$data->{'info'}}\nFail=>@{$data->{'fail'}}\nSvnErr=>@{$data->{'svn_error'}}\nChange=>@{$data->{'change'}}\nReplace=>@{$data->{'replace'}}\nDiff=>@{$data->{'diff'}}\nNot_Found=>@{$data->{'not_found'}}");
    }  #if end
}


####################### parse 'host_log' table ##############
my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
my $myquery = $dbconn->prepare( "SELECT * FROM host_log;");
#execute the query
$myquery->execute();
while ( my @row = $myquery->fetchrow_array())
{ 
	my ($host_name,$last_run_time,$last_run_status,$log_messagge) = (@row);
	print "\n"."-" x 40;
	print "\nHost Name: $host_name";
	print "\nRun Status: $last_run_status";
	print "\nLast run time: $last_run_time";
	my $mylog=&parse_xml_log($log_messagge);
	print "\nLog Message:\n $mylog";

}
print "\n"."-" x 40;

## disconnect DB         
$myquery->finish;
$dbconn->disconnect;
######################### parse end #########################

#done
print "\n";

