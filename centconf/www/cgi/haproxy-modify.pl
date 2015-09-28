#!/usr/bin/perl

sub BEGIN
{
        unshift (@INC, '/home/centconf/module/');
        unshift (@INC, '/usr/lib/perl5/');
}

use strict;
use warnings;
use CGI qw(:standard);
use CGI::Session;
use Login;
use Admin;
use HAproxy;
use Centconfig;
use DBI;
use DBD::mysql;
use Switch;

###### DB connection details ##############
#connection details
my $hash_ref=Centconfig::config_parse;
my $db=${$hash_ref}{database};
my $host=${$hash_ref}{db_host};
my $user=${$hash_ref}{db_user};
my $password=${$hash_ref}{db_password};

############ Database Schema ###############

### Header
my $page = CGI->new( );
### check authentication 
 my $sid = $page->cookie("WORLD_SID") || undef;
 my $session = CGI::Session->load(undef,$sid);
 if ( $session->is_expired ) { print $page->redirect(-location => 'index.pl');}
 elsif ( $session->is_empty) { print $page->redirect(-location => 'index.pl');}
 my $login_name=$session->param('login_user');
 ##print $page->header();
###########################
sub trim($)
{
        my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
}
##########################

if ( $ENV{REQUEST_METHOD} eq "POST" )
{
   my %GET;
   my $query = $ENV{'QUERY_STRING'};
   my @pairs = split(/&/, $query);
   foreach my $pair (@pairs)
   {
        (my $name,my $value) = split(/=/, $pair);
        $value =~ tr/+/ /;
        $value =~ s/%(..)/pack("C", hex($1))/eg;
        $GET{$name} = $value;
   }
    ####
    my %form;
    foreach my $key (param()) {
        $form{$key} = trim(param($key));
        ## print "$key = $form{$key}<br>\n"; ##
    }

################################ haproxy operation start ################################
if ($form{submit} eq "Submit")
{
    ## DB Connection
    my $dbconn = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
    my $myquery = $dbconn->prepare("SELET * FROM mytablearun");
	
   switch($GET{type})
   {
	### server
	case "ha_server"
	{
		## This is HAproxy Server
		if (($form{ha_server_name}) && ($form{interface1}) && ($form{ip_addr1})) 
		{
		  $myquery = $dbconn->prepare( "INSERT INTO ha_server VALUES ('$form{ha_server_name}','$form{ha_server_desc}','$form{interface1}','$form{interface2}','$form{ip_addr1}','$form{ip_addr2}','$form{vip_range}');");
		  my $qry_status=$myquery->execute();
		  if ($qry_status) { print $page->redirect("haproxy.pl?add=ha_server&status=successful");}
		  else { print $page->redirect("haproxy.pl?add=ha_server&status=failed");}
		} else { print $page->redirect("haproxy.pl?add=ha_server&status=errno5");} ## end if-case
	}
	### backend
	case "ha_backend"
	{
		##This is HAproxy Backend
                if (($form{backend_name}) && ($form{ip_addr}) && ($form{port_number}))
                {
                  $myquery = $dbconn->prepare( "INSERT INTO ha_backend VALUES ('$form{backend_name}','$form{backend_desc}','$form{ip_addr}','$form{port_number}','$form{status}');");
                  my $qry_status=$myquery->execute();
                  if ($qry_status) { print $page->redirect("haproxy.pl?add=ha_backend&status=successful");}
                  else { print $page->redirect("haproxy.pl?add=ha_backend&status=failed");}
                } else { print $page->redirect("haproxy.pl?add=ha_backend&status=errno5");} ## end if-case
	}
	### instance
	case "ha_instance"
	{
		print "This is HAproxy Instance";
	}
	### domain
	case "ha_domain"
	{
		print "This is HAproxy Domain";
	}
   } #end of switch
   # close mysql connection
   $myquery->finish;
   $dbconn->disconnect;
} else { print $page->redirect("haproxy.pl?add=ha_server&status=errno5$GET{submit}");}
################################ haproxy operation end ##################################

} else { print $page->redirect("haproxy.pl");} ## if POST
#DONE

