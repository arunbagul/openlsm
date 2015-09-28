#!/usr/bin/perl

sub BEGIN
{
        unshift (@INC, '/home/centconf/module/');
        unshift (@INC, '/usr/lib/perl5/');
}

use strict;
use warnings;
use DBI;
use DBD::mysql;
use Login;
use CGI qw(:standard);
use CGI::Session;
use HAproxy;
use Centconfig;
use File::Basename;
use Switch;

###### DB connection details ##############
#connection details
my $hash_ref=Centconfig::config_parse;
my $db=${$hash_ref}{database};
my $host=${$hash_ref}{db_host};
my $user=${$hash_ref}{db_user};
my $password=${$hash_ref}{db_password};

### Header
########################
my $page = CGI->new( );
##### check authentication 
 my $sid = $page->cookie("WORLD_SID") || undef;
 my $session = CGI::Session->load(undef,$sid);
 if ( $session->is_expired ) { print $page->redirect(-location => 'index.pl');}
 elsif ( $session->is_empty) { print $page->redirect(-location => 'index.pl');}
 my $login_name=$session->param('login_user');
 #my $login_name=Login::is_authen($page);
print $page->header();
###########################
sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
###########################################
if ( $ENV{REQUEST_METHOD} eq "GET" )
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
   ################################ haproxy template start ################################
   switch($GET{tab})
   {
	### server
	case "ha_server"
	{
		print "<div id='HA_WindoW'> <table width='68%' class='tablesorter' id='myTable'>";
    		print "<thead><tr>";
        		print "<th width='5%' class='header' style='width: 2%;'>#</th>";
        		print "<th width='16%' class='header' style='width: 20%;'><span class='header'>Instance Name</span></th>";
        		print "<th width='25%' class='header' style='width: 25%;'><span class='header'>Description</span></th>";
        		print "<th width='13%' class='header' style='width: 20%;'>Domain Names</th>";
			print "<th width='13%' class='header' style='width: 10%;'>Status</th>";
    		print "</tr></thead>";
	    	print "<tbody>";
			print "<tr class='even'>";
			 print "<td>1</td>";
			 print "<td><a href='haproxy.pl'>world.com</a></td>";
			 print "<td>World web site</td>";
			 print "<td>id.world.com,blog.world.com,uk.world.com</td>";
			 print "<td>Enabled</td>";
			print "</tr>";

			print "<tr class='odd'>";
			 print "<td>2</td>";
			 print "<td><a href='haproxy.pl'>world.de</a></td>";
			 print "<td>World web German site</td>";
			 print "<td>blog.world.de,world.de</td>";
			 print "<td>Enabled</td>";
			print "</tr>";

		print "</tbody>";
		print "</table>";

		print "<fieldset>";
		print "	<a href='#' style='text-decoration:none'>";
		print "<input type='image'  src='../images/button/add_ha_instance.png' value='Add HA Server' /></a>";
		print "</fieldset></div>"; ## closing 'HA_WindoW' div
	}
	### instance
	case "ha_instance"
	{
	}
	### domain
	case "ha_domain"
	{
	}
   } #end of swithc	
   ################################ haproxy template end ##################################

}

##done
