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
print $page->header();
print $page->start_html( -title=>'WORLD ~ Monitoring Dashboard!', 
			 -style=>{
				-src=>[ '../css/reset.css','../css/grid.css','../css/styles.css',
					'../css/theme-blue.css'
				      ],-media => 'screen'
				 }
		      );
#########################
# call header 
Login::print_header();

###
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
   ###
   if ($GET{login} eq "logout") { Login::print_loginbody("logout");}
   elsif ($GET{login} eq "failed") { Login::print_loginbody("need_input");} else { Login::print_loginbody("not_login");}
}
#################

# Footer
Login::print_footer();
print $page->end_html; 
#DONE

