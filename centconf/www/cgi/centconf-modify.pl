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
use Centconfig;
use File::Basename;

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
###########################
sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
###########################################
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
    ####
    my $insert_or_not="goahead"; my $passme="input_value_missing"; my $mytype=undef;my $myupdate="don't know";
    my @multi_choice=split(',',$form{secondary_group_list}); my $sec_grp_size = @multi_choice;
    $form{secondary_group_list}=~ s/\s+//;
    ##############################
    if ( $form{submit_group} eq "Submit") {
	if ($form{grp_name} eq ""){ $insert_or_not="stophere";$mytype="group=".$form{grp_name};} 
	else { $mytype="group=".$form{grp_name}; $myupdate="group";}
    }
    elsif ($form{submit_host} eq "Submit") {
        if ($form{host_name} eq ""){ $insert_or_not="stophere";$mytype="host=".$form{host_name};}
        else { $mytype="host=".$form{host_name}; $myupdate="host";}
    }
    elsif ($form{submit_files} eq "Submit") {
	if ($form{file_path} eq "") { $insert_or_not="stophere"; $passme="errno2";$mytype="files=select";}
	else { $mytype="files=select"; $myupdate="files";}
	if ($form{grp_name} eq "") { $insert_or_not="stophere"; $passme="errno1";$mytype="files=select";}
	else { $mytype="files=select"; $myupdate="files";}
    }
    ##############################
    if ( ($form{submit_group} eq "Submit") || ($form{submit_host} eq "Submit") || ($form{submit_files} eq "Submit") ){
    if ($insert_or_not ne "stophere"){
    if ($sec_grp_size <= 5)
    {
	my $dbconn = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
	my $myquery = $dbconn->prepare("SELET * FROM mytablearun");
	if ($myupdate eq "group"){
		$myquery = $dbconn->prepare("UPDATE group_details SET description='$form{grp_desc}',dept='$form{grp_dept}',svn_resvision_no='$form{rev_no}',status='$form{grp_status}' WHERE group_name='$form{grp_name}';");
	}elsif ($myupdate eq "host"){
	   $myquery = $dbconn->prepare("UPDATE host_details SET description='$form{description}',host_ipaddr='$form{ip_addr}',secondary_group_list='$form{secondary_group_list}',host_status='$form{host_status}',host_category='$form{host_category}',centconf_status='$form{centconf_status}' WHERE host_name='$form{host_name}';");
	}elsif ($myupdate eq "files"){
		$myquery = $dbconn->prepare( "UPDATE file_list SET uid='$form{user_name}',gid='$form{grp_owner}',permission='$form{permission}',ctime=CURRENT_TIMESTAMP,action_on_update='$form{'action'}',svn_resvision_no='$form{rev_no}',status='$form{status}' WHERE group_name='$form{grp_name}' and file_path='$form{file_path}';");
}
	#execute the query
	my $qry_status=$myquery->execute();
	if ($qry_status) { print $page->redirect("centconf.pl?type=modify&$mytype&status=successful");}
  	else { print $page->redirect("centconf.pl?type=modify&$mytype&status=failed");}
	# close mysql connection
	$myquery->finish;
	$dbconn->disconnect;
    } else { print $page->redirect("centconf.pl?type=modify&$mytype&status=errno5");}
    } else { print $page->redirect("centconf.pl?type=modify&$mytype&status=$passme");}
    } else { print $page->redirect("centconf.pl");} 

} else { print $page->redirect("centconf.pl");} ## if POST
###########################################
