#!/usr/bin/perl

## Author - Arun
## 18th Feb 2010
## This is the 'HAproxy init script'
## Version = 1.0,r273
## Date 19th Aug 2010

use strict;
use Data::Dumper;
use Getopt::Long;
use LWP::Simple;
use LWP::UserAgent;
use Log::Log4perl qw(:easy);
use XML::Parser;
use XML::Simple;
use SVN::Client;
use File::Basename;
use File::Util;
use File::Compare;
use File::Copy;
use Shell qw(chown,chmod,chgrp,ls);

chomp(my $myhost=`hostname`);

### Get the HAproxy Instance XML file ###
my $user_agent = new LWP::UserAgent;$user_agent->timeout(30);
## download HAproxy base xml
my $res = $user_agent->get('http://localhost/haproxy-base.xml',':content_file' => '/tmp/1.xml');
if ($res ->is_success) { print "\nHAproxy base xml successfully received"; } else { print "\nFailed to receive base xml";}
## download HAproxy instance xml
my $response = $user_agent->get('http://localhost/arun-hacfg.xml',':content_file' => '/tmp/2.xml');
if ($response ->is_success) { print "\nHAproxy instance xml successfully received"; } else { print "\nFailed to receive instance xml";}
## end

################# process xml files #############################
print "\n"."-" x 40; print "\n";
my $xml = XML::Simple->new( SuppressEmpty=>1,ForceArray=>1,NoSort => 1);
## reading xml 
### 1) For base
my $data; eval { $data = $xml->XMLin("/tmp/1.xml");};
if ($@) { print "Error: XML parsing error";}
#print  Dumper($data);
### 
for my $record (@{$data->{'section'}}){
	####### get section name
	if (exists ${$record}{'name'}){print "\n${$record}{name}[0]";}
	## delete the hash
	delete ${$record}{'name'};
	while (my ($key,$value)=  each(%{$record})){  
		##my $arraySize = @{$value}; print "\n $key ($arraySize) => @{$value}"; 
		foreach(@{$value}){
			if ($key eq "comment") { print "\n\t$_";}
			else { print "\n\t".$key."\t".$_;}
		}
	}
}
### 2) instance
my $data; eval { $data = $xml->XMLin("/tmp/2.xml");};
if ($@) { print "Error: XML parsing error";}
print  Dumper($data);
### 
for my $record (@{$data->{'instance'}}){
        ####### get section name
        if (exists ${$record}{'name'}){print "\n${$record}{name}[0]";}
        ## delete the hash
        delete ${$record}{'name'};
        while (my ($key,$value)=  each(%{$record})){
                ##my $arraySize = @{$value}; print "\n $key ($arraySize) => @{$value}"; 
                foreach(@{$value}){
                        if ($key eq "comment") { print "\n\t$_";}
                        else { print "\n\t".$key."\t".$_;}
                }
        }
}
###

################# process xml end ###############################

#done
print "\n";
