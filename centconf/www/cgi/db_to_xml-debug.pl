#!/usr/bin/perl
sub BEGIN
{
        unshift (@INC, '/home/centconf/module/');
        unshift (@INC, '/usr/lib/perl5/');
}

use strict;
use warnings;
use Socket;
use strict;
use XML::Simple;
use DBI;
use DBD::mysql;
use CGI qw(:standard);
use Centconfig;
#use File::stat;

###### DB connection details ##############
#connection details
my $hash_ref=Centconfig::config_parse;
my $db=${$hash_ref}{database};
my $host=${$hash_ref}{db_host};
my $user=${$hash_ref}{db_user};
my $password=${$hash_ref}{db_password};

##################
my $page = CGI->new( );
my $browser = $ENV{'HTTP_USER_AGENT'};
my $client_ip = $ENV{'REMOTE_ADDR'}; 
#foreach my $key (keys %ENV) { print "<br/>$key = $ENV{$key}\n";}
##################
if ( $ENV{REQUEST_METHOD} eq "POST" )
{
    print "Content-type: text/xml\n\n";
    ######### Get form element ####
    my %form; my %file_hash;
    foreach my $key (param()) {
    	$form{$key} = param($key);
    }
    ######### end #################
    if (($form{host}) && ($form{hostcmd}))  #if-1
    {
        my $primary_grp = undef ; my @secondary_grp;
	## DB Connection 
my $dbconn = DBI->connect("DBI:mysql:database=$db:host=$host",$user,$password) or die "<xml><error>Can't connect to database: $DBI::errstr</error></xml>";
my $myquery = $dbconn->prepare("SELECT primary_group,secondary_group_list FROM host_details WHERE host_name='$form{host}' AND centconf_status='Enabled';");
        #execute the query
        $myquery->execute();
        my @row = $myquery->fetchrow_array();
        my $row_count=@row;
        if ($row_count == 2) { $primary_grp=$row[0]; @secondary_grp=split(',',$row[1]); }
        else { print "<xml><error>No Record found in Centconf Server for host [".$form{host}."]</error></xml>"; exit;}
        $myquery->finish;
    ####
    if ($primary_grp){
my $myquery_1 = $dbconn->prepare("SELECT group_name,file_path,uid,gid,permission,svn_resvision_no,action_on_update FROM file_list WHERE status='Enabled' AND group_name IN (SELECT group_name FROM group_details WHERE group_name='$primary_grp' AND status='Enabled');");
   	#execute the query
   	$myquery_1->execute();
   	while ( my @row = $myquery_1->fetchrow_array()){ 
		(my $group_name,my $file_path,my $uid,my $gid,my $permission,my $rev_no,my $action) =(@row);
		$file_hash{$file_path}="<group_name>$group_name</group_name> <uid>$uid</uid> <gid>$gid</gid> <permission>$permission</permission> <rev_no>$rev_no</rev_no> <action>$action</action>";
	}
  	$myquery_1->finish;
	## foreach my $key (keys %file_hash) { print "<br/>$key => $file_hash{$key}\n";}
    }
    else { print "<xml><error>Primary group not defined for host [".$form{host}."]</error></xml>"; exit;}
    ####
    my $size = @secondary_grp; my  $qryparam = " status='Enabled' AND ( ";
    if ($size != 0)
    {
        foreach(@secondary_grp){
	if ($size == 1) { $qryparam = $qryparam."group_name='".$_."' "; } else { $qryparam = $qryparam." group_name='".$_."' or "; } $size = $size - 1; }
	my $myquery_2=$dbconn->prepare("SELECT group_name,file_path,uid,gid,permission,svn_resvision_no,action_on_update FROM file_list WHERE status='Enabled' AND group_name IN (SELECT group_name FROM group_details WHERE $qryparam ));");
	#execute the query
	$myquery_2->execute();
	#################################
        while ( my @row = $myquery_2->fetchrow_array()){
                (my $group_name,my $file_path,my $uid,my $gid,my $permission,my $rev_no,my $action) =(@row);
		unless(exists($file_hash{$file_path})){
                $file_hash{$file_path}="<group_name>$group_name</group_name> <uid>$uid</uid> <gid>$gid</gid> <permission>$permission</permission> <rev_no>$rev_no</rev_no> <action>$action</action>";
        }}
	#################################
 	# close mysql connection
	$myquery_2->finish;
	########## print xml here ##################
	print "<xml>\n";
        foreach my $key (keys %file_hash)
	{ 
		print "\n<file_record>";
		print "\n<file_path>$key</file_path>";
		print "\n$file_hash{$key}";
		print "\n</file_record>";
	}
	print "\n</xml>";
	###########################################
    } else { print "<xml><error>No secondary record found</error></xml>";}
    ## end of sec grp if/else
	# disconnect DB
	$dbconn->disconnect;		
    } else { print "<xml><error>unknown error</error></xml>";} ##end of if-1
    # open file
    open (MYFILE,">/tmp/centconf_ip_log.txt") or die $!;
    my $str="Host=>".$form{host}."\nHostcmd=>".$form{hostcmd}."\nAction=>".$form{submit}."\nBrowser=>".$browser."\nClient IPaddr=>".$client_ip."\n";
    print MYFILE $str;
    close (MYFILE); 
}else
{
    print $page->header();
    print "<form action='db_to_xml-debug.pl' method='POST'>";
    print "<p><label>Host Name </label><input class='input-short' type='text' name=host></p>";
    print "<p><label>Host Id </label><input class='input-short' type='text' name=hostcmd></p>";
    print "<input class='submit-green' value='Submit' type='submit' name='submit'>";
    print "</form>";
}
##################
