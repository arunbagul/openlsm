#!/usr/bin/perl

sub BEGIN
{
        unshift (@INC, '/home/centconf/module/');
}

use strict;
use warnings;
use DBI;
use Login;
use DBD::mysql;
use CGI qw(:standard);
use CGI::Session;
use Centconfig;
##use CGI::Ajax;

my $page = CGI->new( );
print $page->header();

## DB connection details
## connection details
my $hash_ref=Centconfig::config_parse;
my $db=${$hash_ref}{database};
my $host=${$hash_ref}{db_host};
my $user=${$hash_ref}{db_user};
my $password=${$hash_ref}{db_password};

##### check authentication 
 my $sid = $page->cookie("WORLD_SID") || undef;
 my $session = CGI::Session->load(undef,$sid);
 if ( $session->is_expired ) { print $page->redirect(-location => 'index.pl');}
 elsif ( $session->is_empty) { print $page->redirect(-location => 'index.pl');}
 my $login_name=$session->param('login_user');
 #my $login_name=Login::is_authen($page);
###########################

####### GET method
if ($ENV{REQUEST_METHOD} eq "GET")
{
   my %GET; my $mystatus = undef; my $output="";
   my $query = $ENV{'QUERY_STRING'};
   my @pairs = split(/&/, $query);
   foreach my $pair (@pairs)
   {
        (my $name,my $value) = split(/=/, $pair);
        $value =~ tr/+/ /;
        $value =~ s/%(..)/pack("C", hex($1))/eg;
        $GET{$name} = $value;
   }
   ###########
   my $userstatus=undef;
   if($GET{id}){
   if ($GET{status} eq "enable") { $mystatus="Enabled";} elsif ($GET{status} eq "disable") { $mystatus="Disabled";}
        my $dbconn = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
	my $myquery = undef;
	if ($GET{type} eq "host"){ $myquery = $dbconn->prepare( "UPDATE host_details SET centconf_status='$mystatus' WHERE host_name='$GET{id}';"); }
	elsif ($GET{type} eq "group"){$myquery = $dbconn->prepare( "UPDATE group_details SET status='$mystatus' WHERE group_name='$GET{id}';"); }
	elsif ($GET{type} eq "user"){$myquery = $dbconn->prepare( "UPDATE users SET status='$mystatus' WHERE user_id='$GET{id}';"); }
	elsif ($GET{type} eq "dept"){$myquery = $dbconn->prepare( "UPDATE user_department SET status='$mystatus' WHERE dept_name='$GET{id}';"); }
        #execute the query
        my $qry_status=$myquery->execute();
        if ($qry_status) { print "$mystatus";} else { print "Failed";}
        # close mysql connection
        $myquery->finish;
        $dbconn->disconnect;
   } # end of id if

} # end of GET method if
exit;

