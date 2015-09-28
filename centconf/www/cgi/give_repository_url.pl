#!/usr/bin/perl

sub BEGIN
{
        unshift (@INC, '/home/centconf/module/');
        unshift (@INC, '/usr/lib/perl5/');
}

use strict;
use warnings;
use Centconfig;
use CGI qw(:standard);

###### DB connection details ##############
#connection details
my $hash_ref=Centconfig::config_parse;
my $svn_client_url=${$hash_ref}{svn_client_url};
my $svn_user=${$hash_ref}{svn_user};
my $svn_password=${$hash_ref}{svn_password};

### Header
#####################
my $page = CGI->new();
my $browser = $ENV{'HTTP_USER_AGENT'};
########################################

if ( $ENV{REQUEST_METHOD} eq "POST" )
{
    print "Content-type: text/xml\n\n";
    ######### Get form element ####
    my %form; my %file_hash;
    foreach my $key (param()) {
        $form{$key} = param($key);
    }
    ################
    print "<xml>";
    if (($form{submit} eq "CenTConF") && ($browser eq "centconf/CmDLiNe"))
    ##if ($form{submit} eq "CenTConF")
    {
	## generate xml output
	if ($form{identification_code} eq "c57800a2-fe13-4c60-9625-ac4b94d94512"){
	  print "<repository_url>";
	  print "<repo_url>$svn_client_url</repo_url> <user_name>$svn_user</user_name> <password>$svn_password</password>";
	  print "</repository_url>";
	}
    }
    print "</xml>";    
}else
{
    print $page->header();
    print "<form action='give_repository_url.pl' method='POST'>";
    print "<p><label>Identification Code </label><input class='input-short' type='text' name='identification_code'></p>";
    print "<input class='submit-green' value='CenTConF' type='submit' name='submit'>";
    print "</form>";
}

