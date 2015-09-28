#!/usr/bin/perl

sub BEGIN
{
        unshift (@INC, '/home/centconf/module/');
}

use strict;
use warnings;
use DBI;
use DBD::mysql;
use Login;
use CGI qw(:standard);
use CGI::Session;
use Centconfig;
##use CGI::Ajax;

## DB connection details
## connection details
my $hash_ref=Centconfig::config_parse;
my $db=${$hash_ref}{database};
my $host=${$hash_ref}{db_host};
my $user=${$hash_ref}{db_user};
my $password=${$hash_ref}{db_password};

my $page = CGI->new( );
print $page->header();
##### check authentication 
 my $sid = $page->cookie("WORLD_SID") || undef;
 my $session = CGI::Session->load(undef,$sid);
 if ( $session->is_expired ) { print $page->redirect(-location => 'index.pl');}
 elsif ( $session->is_empty) { print $page->redirect(-location => 'index.pl');}
 my $login_name=$session->param('login_user');
 #my $login_name=Login::is_authen($page);
###########################

## trim func to remove 
#white space
sub trim($)
{
        my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
}

####### post method
if ($ENV{REQUEST_METHOD} eq "GET")
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
	###########
	my $output="";
        my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
        my $myquery = $dbconn->prepare( "SELECT file_path FROM file_list WHERE group_name='$GET{id}';");
        #execute the query
        $myquery->execute();
		while ( my @row = $myquery->fetchrow_array()){ 
		  $output="<option value=\"".$row[0]."\">".$row[0]."</option>".$output;
		}
        ## print "</select>";
	###########
        # close mysql connection
        $myquery->finish;
        $dbconn->disconnect;
if ($GET{type} eq "editor") {
print "<select name='file_path' id='file_path' class='input-long' onchange='javascript:get_file_from_svn(this.value)'><option value=''>Select File</option>".$output."</select>";
}elsif ($GET{type} eq "modify"){
print "<select name='file_path' id='file_path' class='input-long' onchange='javascript:get_fileinfo(this.value)'><option value=''>Select File</option>".$output."</select>";
}
} # end of GET method if
#####################################
if ( $ENV{REQUEST_METHOD} eq "POST" )
{
  my %form; my @multi_choice;
  foreach my $key (param()) { $form{$key} = trim(param($key));}
  ##
  if (($form{fileid}) && ($form{groupid}))
  {
        my $output="";
        my $dbconn = DBI->connect("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
	my $myquery = $dbconn->prepare( "SELECT uid,gid,permission,svn_resvision_no,action_on_update,status FROM file_list WHERE group_name='$form{groupid}' and file_path='$form{fileid}';");
	#execute the query
	$myquery->execute();
	my @row = $myquery->fetchrow_array();
	(my $uid,my $gid,my $permission,my $rev_no,my $action_on_update,my $status) = @row;
	#$output="<option value=\"".$row[0]."\">".$row[0]."</option>".$output;
	$output=$uid."{-!-}".$gid."{-!-}".$permission."{-!-}".$rev_no."{-!-}".$action_on_update."{-!-}".$status;
        ###########
        # close mysql connection
        $myquery->finish;
        $dbconn->disconnect;
	## print output
	print "$output";
  }
}
#####################################
exit;
