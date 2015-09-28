#!/usr/bin/perl

sub BEGIN
{
        unshift (@INC, '/home/centconf/module/');
}

use strict;
use warnings;
use Login;
use Centconfig;
use CGI qw(:standard);
use CGI::Session;
use DBI;
use DBD::mysql;

###### DB connection details ##############
#connection details
my $hash_ref=Centconfig::config_parse;
my $db=${$hash_ref}{database};
my $host=${$hash_ref}{db_host};
my $user=${$hash_ref}{db_user};
my $password=${$hash_ref}{db_password};
my $session_dir=${$hash_ref}{session_dir};
my $admin_user=${$hash_ref}{admin_user};
my $admin_password=${$hash_ref}{admin_password};
### Header
########################
my $page = CGI->new();
### print $page->header();
## trim func to remove 
#white space
sub trim($)
{
        my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
}

##########
if ( $ENV{REQUEST_METHOD} eq "POST" )
{
  my %form; my @multi_choice;
  foreach my $key (param()) { $form{$key} = trim(param($key));}
  ##
  if (($form{username}) && ($form{password}))
  {
	############################
        my $dbconn = DBI->connect("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
        my $myquery = $dbconn->prepare( "SELECT password FROM users WHERE user_id='$form{username}';");
        #execute the query
        $myquery->execute();
        my @row = $myquery->fetchrow_array();
        ### print "<br/>Password=>$row[0]";
        ###########
        $myquery->finish;
	### get MD5 of password
	my $qry_md5 = $dbconn->prepare("SELECT MD5('$form{password}');");
	$qry_md5->execute();
	my @md5_password = $qry_md5->fetchrow_array();
	$qry_md5->finish;
        ### print "<br/>Password=>$md5_password[0]";
	###
        # close mysql connection
        $dbconn->disconnect;
	################ Session Details ############################
 	CGI::Session->name("WORLD_SID");	
	## Create new session
	##my $session = $session->new(undef, undef, {Directory=>$session_dir});
	my $session = new CGI::Session(undef, undef, {Directory=>$session_dir});
	## Set cookies
	my $cookie = $page->cookie(-name=>$session->name(),-value=>$session->id(),-expires=>'+2h',-path=>'/');
	## Store data in session variable and save it
	$session->param('login_user',$form{username}); # OR 
	##$session->param(-name=>'login_user',-value=>$form{username});
	$session->save_param($page, ["login_user"]); #$page->param(-name=>'login_user',-value=>$form{username});

	## Session and Cookie expiration time is SAME.
	$session->expire("+2h");
	################ Session Details ############################
	## if login successful redirect to admin.pl else login page
	if (($form{username} eq $admin_user) and ($form{password} eq $admin_password)) { print $page->redirect(-location => 'admin.pl',-cookie=>$cookie);}
	elsif ($row[0] eq $md5_password[0]) { print $page->redirect(-location => 'admin.pl',-cookie=>$cookie); }
	else { print $page->redirect(-location => 'index.pl?login=failed'); }
	### print $page->redirect(-location => 'admin.pl',-cookie=>$cookie);
	############################
 } else { print $page->redirect(-location => 'index.pl?login=failed'); } 
}
