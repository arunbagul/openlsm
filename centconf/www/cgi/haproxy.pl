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
use Centconf;
use Centconfig;
use DBI;
use DBD::mysql;
#use File::stat;

###### DB connection details ##############
#connection details
my $hash_ref=Centconfig::config_parse;
my $db=${$hash_ref}{database};
my $host=${$hash_ref}{db_host};
my $user=${$hash_ref}{db_user};
my $password=${$hash_ref}{db_password};

############ Database Schema ###############
# HAproxy table structures
#
# mysql> desc ha_server;
# +-------------+--------------+------+-----+---------+-------+
# | Field       | Type         | Null | Key | Default | Extra |
# +-------------+--------------+------+-----+---------+-------+
# | host_name   | varchar(40)  | NO   | PRI | NULL    |       |
# | description | varchar(200) | NO   |     | NULL    |       |
# | interface1  | varchar(40)  | NO   |     | NULL    |       |
# | interface2  | varchar(40)  | NO   |     | NULL    |       |
# | ip_addr1    | varchar(40)  | NO   |     | NULL    |       |
# | ip_addr2    | varchar(40)  | NO   |     | NULL    |       |
# | vip_range   | varchar(200) | NO   |     | NULL    |       |
# +-------------+--------------+------+-----+---------+-------+
# 
# mysql> desc ha_instance;
# +---------------+----------------------------+------+-----+----------+-------+
# | Field         | Type                       | Null | Key | Default  | Extra |
# +---------------+----------------------------+------+-----+----------+-------+
# | instance_name | varchar(40)                | NO   | PRI | NULL     |       |
# | description   | varchar(200)               | NO   |     | NULL     |       |
# | ha_server     | varchar(40)                | NO   |     | NULL     |       |
# | base_xml_path | varchar(200)               | YES  |     | NULL     |       |
# | status        | enum('Enabled','Disabled') | NO   |     | Disabled |       |
# +---------------+----------------------------+------+-----+----------+-------+
# 
# mysql> desc ha_domain;
# +--------------+----------------------------+------+-----+----------+-------+
# | Field        | Type                       | Null | Key | Default  | Extra |
# +--------------+----------------------------+------+-----+----------+-------+
# | domain_name  | varchar(150)               | NO   | PRI | NULL     |       |
# | description  | varchar(200)               | NO   |     | NULL     |       |
# | ha_instance  | varchar(40)                | NO   |     | NULL     |       |
# | internal_vip | varchar(40)                | NO   |     | NULL     |       |
# | public_vip   | varchar(40)                | NO   |     | NULL     |       |
# | vinterface   | varchar(40)                | NO   |     | NULL     |       |
# | domain_port  | varchar(10)                | NO   |     | NULL     |       |
# | ha_mode      | varchar(40)                | YES  |     | NULL     |       |
# | backend_list | varchar(500)               | NO   |     | NULL     |       |
# | status       | enum('Enabled','Disabled') | NO   |     | Disabled |       |
# +--------------+----------------------------+------+-----+----------+-------+
#
# mysql> desc ha_backend;
# +--------------+----------------------------+------+-----+----------+-------+
# | Field        | Type                       | Null | Key | Default  | Extra |
# +--------------+----------------------------+------+-----+----------+-------+
# | backend_name | varchar(40)                | NO   | PRI | NULL     |       |
# | description  | varchar(200)               | NO   |     | NULL     |       |
# | ip_addr      | varchar(40)                | NO   |     | NULL     |       |
# | port_number  | varchar(10)                | NO   | PRI |          |       |
# | status       | enum('Enabled','Disabled') | NO   |     | Disabled |       |
# +--------------+----------------------------+------+-----+----------+-------+
#
#done 

### Header
########################
my $page = CGI->new();
##### check authentication 
my $login_name=Login::is_authen($page);
our $client_ip = $ENV{'REMOTE_ADDR'};
########################################
print $page->start_html( -title=>'WORLD ~ Monitoring Dashboard!', 
			 -style=>{
				-src=>[ '../css/reset.css','../css/grid.css','../css/styles.css',
					'../css/jquery.css','../css/tablesorter.css','../css/thickbox.css',
					'../css/theme-blue.css','../css/jquery.treeview.css',
					'../css/jquery.tabs.css','../css/jquery.tabs-ie.css'
				      ],-media => 'screen'
				 },
			  -script=>[
					{ -src=>'../javascript/jquery-1.js'},
					{ -src=>'../javascript/jquery_002.js'},
					{ -src=>'../javascript/jquery_003.js'},
					{ -src=>'../javascript/jquery_004.js'},
					{ -src=>'../javascript/thickbox.js'},
					{ -src=>'../javascript/jquery.js'},
					{ -src=>'../javascript/jquery.treeview.js'},
					{ -src=>'../javascript/jquery.tabs.js'},
					{ -src=>'../javascript/tree-tab.js'},
					{ -src=>'../javascript/ajax.js'},
				   ],
		      );
########################################

# call header 
Admin::print_header("HAproxy");
#
print "<div class='container_12'>";
#################################################################
#-- Categories list --
print "<div class='grid_9'>";
###########################################

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

####
sub haproxy_body 
{
  my ($h, $d, $u, $pwd)=(@_);
	HAproxy::print_haproxy_details($h,$d,$u,$pwd);
	HAproxy::print_backend_details($h,$d,$u,$pwd);
	HAproxy::haproxy_tree("No_seRveR","No_instAnce",$h, $d, $u, $pwd);
	Centconf::user_profile($client_ip,$login_name);
	HAproxy::print_log_message("yes_wider",$h,$d,$u,$pwd);
}
##########################
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
   ###############
   ## call func-haproxy_body
   if ($GET{server})
   {
        HAproxy::print_haproxy_window($GET{server},$GET{instance},$host,$db,$user,$password);
	HAproxy::print_log_message("no_wider",$host,$db,$user,$password);
        HAproxy::haproxy_tree($GET{server},$GET{instance},$host, $db, $user, $password);Centconf::user_profile($client_ip,$login_name);
   } elsif ($GET{add} eq "ha_server") { 
	my $get_status=undef; if ($GET{status}) {$get_status=$GET{status};} else {$get_status="unknown";};
	HAproxy::add_ha_server($get_status,$host,$db,$user,$password);
	HAproxy::haproxy_tree($GET{server},$GET{instance},$host, $db, $user, $password);Centconf::user_profile($client_ip,$login_name);
   } elsif ($GET{add} eq "ha_backend") {
        my $get_status=undef; if ($GET{status}) {$get_status=$GET{status};} else {$get_status="unknown";};	
        HAproxy::add_backend_server($get_status,$host,$db,$user,$password);
        HAproxy::haproxy_tree($GET{server},$GET{instance},$host, $db, $user, $password);Centconf::user_profile($client_ip,$login_name);
   }else { haproxy_body($host,$db,$user,$password);}
   ###############
}
###
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

} ## if POST
###########################################

print "<div style='clear: both;'></div>";
print "</div>"; 
#-- Categories list / grid_8 end --

#################################################################
print "</div> <div style='clear: both;'></div>";
#
# Footer
Admin::print_footer();
print $page->end_html; 
#DONE

