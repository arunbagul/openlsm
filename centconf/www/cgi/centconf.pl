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
use Centconf;
use CentconfOps;
use CentconfModify;
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
# Database: world_mon
# mysql> show tables;
# +--------------------+
# | Tables_in_world_mon |
# +--------------------+
# | file_list          |
# | group_details      |
# | host_details       |
# | host_log           |
# | user_department    |
# | users              |
# +--------------------+
# 
# Storage ENGINE=InnoDB
# mysql> desc file_list;
# +------------------+----------------------------+------+-----+---------------------+-----------------------------+
# | Field            | Type                       | Null | Key | Default             | Extra                       |
# +------------------+----------------------------+------+-----+---------------------+-----------------------------+
# | group_name       | varchar(30)                | NO   | PRI | NULL                |                             |
# | file_path        | varchar(200)               | NO   | PRI |                     |                             |
# | uid              | varchar(15)                | YES  |     | NULL                |                             |
# | gid              | varchar(15)                | YES  |     | NULL                |                             |
# | permission       | int(11)                    | YES  |     | NULL                |                             |
# | ctime            | timestamp                  | NO   |     | CURRENT_TIMESTAMP   | on update CURRENT_TIMESTAMP |
# | mtime            | timestamp                  | NO   |     | 0000-00-00 00:00:00 |                             |
# | svn_resvision_no | int(11)                    | YES  |     | NULL                |                             |
# | action_on_update | varchar(100)               | YES  |     | NULL                |                             |
# | status           | enum('Enabled','Disabled') | YES  |     | NULL                |                             |
# +------------------+----------------------------+------+-----+---------------------+-----------------------------+
# 
# Storage ENGINE=InnoDB
# mysql> desc group_details;
# +------------------+----------------------------+------+-----+----------+-------+
# | Field            | Type                       | Null | Key | Default  | Extra |
# +------------------+----------------------------+------+-----+----------+-------+
# | group_name       | varchar(30)                | NO   | PRI | NULL     |       |
# | description      | varchar(200)               | NO   |     | NULL     |       |
# | dept             | varchar(20)                | YES  |     | myops  |       |
# | svn_resvision_no | int(11)                    | YES  |     | NULL     |       |
# | status           | enum('Enabled','Disabled') | NO   |     | Disabled |       |
# +------------------+----------------------------+------+-----+----------+-------+
# 
# Storage ENGINE=InnoDB
# mysql> desc host_details;
# +----------------------+-----------------------------------+------+-----+----------+-------+
# | Field                | Type                              | Null | Key | Default  | Extra |
# +----------------------+-----------------------------------+------+-----+----------+-------+
# | host_name            | varchar(40)                       | NO   | PRI | NULL     |       |
# | description          | varchar(200)                      | NO   |     | NULL     |       |
# | host_ipaddr          | varchar(40)                       | NO   |     | NULL     |       |
# | primary_group        | varchar(30)                       | YES  |     | NULL     |       |
# | secondary_group_list | varchar(200)                      | YES  |     | NULL     |       |
# | host_status          | enum('up','down','ofr')           | YES  |     | NULL     |       |
# | host_category        | enum('Production','QA','Testing') | YES  |     | NULL     |       |
# | centconf_status      | enum('Enabled','Disabled')        | NO   |     | Disabled |       |
# +----------------------+-----------------------------------+------+-----+----------+-------+
# 
# Storage ENGINE=MyISAM
# mysql> desc host_log;
# +-----------------+-------------------------------------------------+------+-----+-------------------+-----------------------------+
# | Field           | Type                                            | Null | Key | Default           | Extra                       |
# +-----------------+-------------------------------------------------+------+-----+-------------------+-----------------------------+
# | host_name       | varchar(40)                                     | NO   | PRI | NULL              |                             |
# | last_run_time   | timestamp                                       | NO   |     | CURRENT_TIMESTAMP | on update CURRENT_TIMESTAMP |
# | last_run_status | enum('Running','Failed','Successful','Unknown') | YES  |     | NULL              |                             |
# | log_messagge    | longtext                                        | YES  |     | NULL              |                             |
# +-----------------+-------------------------------------------------+------+-----+-------------------+-----------------------------+
# 
# Storage ENGINE=MyISAM
# mysql> desc user_department;
# +-----------+----------------------------+------+-----+---------+-------+
# | Field     | Type                       | Null | Key | Default | Extra |
# +-----------+----------------------------+------+-----+---------+-------+
# | dept_name | varchar(50)                | NO   | PRI | NULL    |       |
# | dept_desc | varchar(50)     	   | NO   |     | NULL    |       |
# | status    | enum('Enabled','Disabled') | NO   |     | NULL    |       |
# +-----------+----------------------------+------+-----+---------+-------+
# 
# Storage ENGINE=MyISAM
# mysql> desc users;
# +-----------+----------------------------+------+-----+---------+-------+
# | Field     | Type                       | Null | Key | Default | Extra |
# +-----------+----------------------------+------+-----+---------+-------+
# | user_id   | varchar(50)                | NO   | PRI | NULL    |       |
# | name      | varchar(250)               | NO   |     | NULL    |       |
# | password  | varchar(50)                | NO   |     | NULL    |       |
# | dept_name | varchar(255)               | NO   |     | NULL    |       |
# | status    | enum('Enabled','Disabled') | NO   |     | NULL    |       |
# +-----------+----------------------------+------+-----+---------+-------+
#
#
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
					'../css/theme-blue.css'
				      ],-media => 'screen'
				 },
			  -script=>[
					{ -src=>'../javascript/jquery-1.js'},
					{ -src=>'../javascript/jquery_002.js'},
					{ -src=>'../javascript/jquery_003.js'},
					{ -src=>'../javascript/jquery_004.js'},
					{ -src=>'../javascript/thickbox.js'},
					{ -src=>'../javascript/jquery.js'},
					{ -src=>'../javascript/ajax.js'},
				   ],
		      );
########################################

# call header 
Admin::print_header("Centconf");
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
sub centconf_body 
{
  my ($status, $choice, $h, $d, $u, $pwd)=(@_);
  if($choice eq "group") { CentconfOps::add_group($status,$h, $d, $u, $pwd);
  }elsif ($choice eq "host") { CentconfOps::add_host($status,$h, $d, $u, $pwd);
  }elsif ($choice eq "files") { CentconfOps::add_files($status,$h, $d, $u, $pwd);
  }elsif ($choice eq "editor") { CentconfOps::edit_file($status,$h, $d, $u, $pwd);
  }else{
	Centconf::print_group_details($h,$d,$u,$pwd);
	Centconf::print_host_details($h,$d,$u,$pwd);
  }
	Centconf::side_panel($h, $d, $u, $pwd);
	Centconf::user_profile($client_ip,$login_name);
}
##########################
if ($ENV{REQUEST_METHOD} eq "GET")
{
   my %GET;
   $GET{type}="213f1180-fda8-4d79";
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
   ## call func-centconf_body
   if (($GET{type} eq "modify") && (($GET{group} ne "") or ($GET{host} ne "") or ($GET{files} ne "")))
   {
	my $myreturn="unknown";
	if($GET{status}){ $myreturn=$GET{status};}
        if($GET{group}) { CentconfModify::modify_group($myreturn,$GET{group},$host, $db, $user, $password);}
        if($GET{host})  { CentconfModify::modify_host($myreturn,$GET{host},$host, $db, $user, $password);}
        if($GET{files}) { CentconfModify::modify_files($myreturn,$GET{files},$host, $db, $user, $password);}
        Centconf::side_panel($host, $db, $user, $password);Centconf::user_profile($client_ip,$login_name);
   } else { centconf_body("unknown",$GET{type},$host,$db,$user,$password);}
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
    ####
    my %form; my @multi_choice;
    foreach my $key (param()) {
	if ( $key eq "secondary_group_list") { @multi_choice = param('secondary_group_list'); } 
	else { $form{$key} = trim(param($key)); }
        ## print "$key = $form{$key}<br>\n"; ##
    }
    ####
    my $sec_grp_size = @multi_choice; my $insert_or_not="goahead"; my $passme="input_value_missing";
    my $sec_grp_list = trim(join(',',@multi_choice)); $sec_grp_list =~ s/\s+//;
    if (($GET{type} eq "group") && ($form{grp_name} eq "")) {$insert_or_not="stophere";}
    if (($GET{type} eq "host") && ($form{host_name} eq "")) {$insert_or_not="stophere";}
    	if (($GET{type} eq "files") && ($form{file_path} eq ""))   { $insert_or_not="stophere"; $passme="file_name_required";  }
    	elsif (($GET{type} eq "files") && ($form{grp_name} eq "")) { $insert_or_not="stophere"; $passme="group_name_required"; }
    ## check for valid file_path
    if ($GET{type} eq "files"){ 
	if (($form{file_path}!~m|^/|) || ($form{file_path}=~m|/$|)) {$insert_or_not="stophere"; $passme="file_name_required";} 
	if ($form{file_path}=~m|\s|) {$insert_or_not="stophere"; $passme="file_name_required";} 
    }
    ####
    if ($form{submit} eq "Submit") {
    if ($insert_or_not ne "stophere"){
    if ($sec_grp_size <= 5)
    {
	### print "\nsecondary_group_list=>$sec_grp_list"; ##
	my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
	my $myquery = $dbconn->prepare("SELET * FROM mytable");
   	if ($GET{type} eq "group"){ $form{grp_name}=~y/A-Z/a-z/; 
	$myquery = $dbconn->prepare( "INSERT INTO group_details VALUES ('$form{grp_name}','$form{grp_desc}','$form{grp_dept}','','$form{grp_status}');"); }
   	elsif ( $GET{type} eq "host"){$form{host_name}=~y/A-Z/a-z/;
	$myquery = $dbconn->prepare( "INSERT INTO host_details(host_name,description,host_ipaddr,primary_group,secondary_group_list,host_status,host_category,centconf_status) VALUES ('$form{host_name}','$form{description}','$form{ip_addr}','$form{host_name}','$sec_grp_list','$form{host_status}','$form{host_category}','$form{centconf_status}');");}
   	elsif ( $GET{type} eq "files"){
	$myquery = $dbconn->prepare( "INSERT INTO file_list(group_name,file_path,uid,gid,permission,ctime,action_on_update,status) VALUES ('$form{grp_name}','$form{file_path}','$form{user_name}','$form{grp_owner}','$form{permission}',CURRENT_TIMESTAMP,'$form{'action'}','$form{status}');");}
	#execute the query
	my $qry_status=$myquery->execute();
	if ($qry_status) { centconf_body("successful",$GET{type},$host,$db,$user,$password);;}
  	else { centconf_body("failed",$GET{type},$host,$db,$user,$password); }
	# close mysql connection
	$myquery->finish;
	$dbconn->disconnect;
    } else { centconf_body("more_than_five",$GET{type},$host,$db,$user,$password); }
    } else { centconf_body($passme,$GET{type},$host,$db,$user,$password); }
    } else { centconf_body("Cancel",$GET{type},$host,$db,$user,$password); }

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

