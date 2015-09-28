#!/usr/bin/perl

sub BEGIN
{
        unshift (@INC, '/home/centconf/module/');
        unshift (@INC, '/usr/lib/perl5/');
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

### Header
########################
my $page = CGI->new();
## delete cookies and session variable 'login_user'
my $sid = $page->cookie("WORLD_SID") || undef;
my $session = CGI::Session->load(undef,$sid); 
$session->clear(["login_user", "group"]);
$session->delete(); 
$session->close();
my $cookie = $page->cookie(-name=>'WORLD_SID',-value=>"",-expires=>'-1',-path=>'/');
print $page->redirect(-location => 'index.pl?login=logout', -cookie=>$cookie);
#DONE
