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

### Header
########################
my $page = CGI->new( );
print $page->header();
#print "Content-type: text/xml\n\n" ;
########################################
# call header 
#################################################################
print "<form action='db_to_xml-steps.pl' method='post'>";
print "<p><label>Host Name </label><input class='input-short' type='text' name=host></p>";
print "<p><label>Host Id </label><input class='input-short' type='text' name=hostcmd></p>";
print "<input class='submit-green' value='Submit' type='submit' name='submit'>";
print "</form>";

##################
sub give_me_ip {

  my (@bytes, @octets,
    $packedaddr,
    $raw_addr,
    $host_name,
    $ip
  );

  if($_[0] =~ /[a-zA-Z]/g) {
    $raw_addr = (gethostbyname($_[0]))[4];
    @octets = unpack("C4", $raw_addr);
    $host_name = join(".", @octets);
  } else {
    @bytes = split(/\./, $_[0]);
    $packedaddr = pack("C4",@bytes);
    $host_name = (gethostbyaddr($packedaddr, 2))[0];
  }
  return($host_name);
}
##################
my $browser = $ENV{'HTTP_USER_AGENT'};
my $client_ip = $ENV{'REMOTE_ADDR'}; 
print "<br/><hr>";
foreach my $key (keys %ENV) { print "<br/>$key = $ENV{$key}\n";}
print "<br/><hr>";
##################
if ( $ENV{REQUEST_METHOD} eq "POST" )
{
    ######### Get form element ####
    my %form; my %file_hash;
    foreach my $key (param()) {
    	$form{$key} = param($key);
        print "$key = $form{$key}<br>\n";
    }
    print "<br/>PTR Client IP Address (via give_me_ip) =>".give_me_ip($form{hostcmd});
    print "<br/>Client REMOTE_ADDR (via Browser) => $client_ip"."<br/>";
    ######### end #################
    if (($form{host}) && ($form{hostcmd}))  #if-1
    {
        my $primary_grp = undef ; my @secondary_grp;
	print "<br/><b>Step 1) SELECT primary_group,secondary_group_list FROM host_details WHERE host_name='$form{host}' AND centconf_status='Enabled';</b>";
	## DB Connection 
my $dbconn = DBI->connect("DBI:mysql:database=$db:host=$host",$user,$password) or die "<xml><error>Can't connect to database: $DBI::errstr</error></xml>";
my $myquery = $dbconn->prepare("SELECT primary_group,secondary_group_list FROM host_details WHERE host_name='$form{host}' AND centconf_status='Enabled';");
        #execute the query
        $myquery->execute();
        my @row = $myquery->fetchrow_array();
        my $row_count=@row;
        print "<br/>Row count from Host_details table=>".$row_count."<br/>";
        if ($row_count == 2) { $primary_grp=$row[0]; @secondary_grp=split(',',$row[1]); }
        else { print "<xml><error>No Record found in Centconf Server for host [".$form{host}."]</error></xml>"; exit;}
        $myquery->finish;
    ####
    if ($primary_grp){
	print "<br/><b>Step 2) SELECT group_name,file_path,uid,gid,permission,svn_resvision_no,action_on_update FROM file_list WHERE status='Enabled' AND group_name IN (SELECT group_name FROM group_details WHERE group_name='$primary_grp' AND status='Enabled');</b>";
my $myquery_1 = $dbconn->prepare("SELECT group_name,file_path,uid,gid,permission,svn_resvision_no,action_on_update FROM file_list WHERE status='Enabled' AND group_name IN (SELECT group_name FROM group_details WHERE group_name='$primary_grp' AND status='Enabled');");
   	#execute the query
   	$myquery_1->execute();
   	while ( my @row = $myquery_1->fetchrow_array()){ 
		(my $group_name,my $file_path,my $uid,my $gid,my $permission,my $rev_no,my $action) =(@row);
		$file_hash{$file_path}="<group_name>$group_name</group_name> <uid>$uid</uid> <gid>$gid</gid> <permission>$permission</permission> <rev_no>$rev_no</rev_no> <action>$action</action>";
	}
  	$myquery_1->finish;
	print "<br/>Fils list for primary group from 'file_list' table=>\n";
	foreach my $key (keys %file_hash) { print "<br/>$key => $file_hash{$key}\n";}
    }
    else { print "<xml><error>Primary group not defined for host [".$form{host}."]</error></xml>"; exit;}
    ####
    print "<br/><b>Step 3) Secondary Groups=>@secondary_grp</b>";
    my $size = @secondary_grp; my  $qryparam = " status='Enabled' AND ( ";
    if ($size != 0)
    {
        foreach(@secondary_grp){
	if ($size == 1) { $qryparam = $qryparam."group_name='".$_."' "; } else { $qryparam = $qryparam." group_name='".$_."' or "; } $size = $size - 1; }
 	print "<br/>Query options=>$qryparam";
 	print "<br/>SELECT group_name,file_path,uid,gid,permission,svn_resvision_no,action_on_update FROM file_list WHERE status='Enabled' AND group_name IN (SELECT group_name FROM group_details WHERE $qryparam ));<br/>";
	my $myquery_2=$dbconn->prepare("SELECT group_name,file_path,uid,gid,permission,svn_resvision_no,action_on_update FROM file_list WHERE status='Enabled' AND group_name IN (SELECT group_name FROM group_details WHERE $qryparam ));");
	#execute the query
	$myquery_2->execute();
	#################################
        while ( my @row = $myquery_2->fetchrow_array()){
                (my $group_name,my $file_path,my $uid,my $gid,my $permission,my $rev_no,my $action) =(@row);
		unless(exists($file_hash{$file_path})){
                $file_hash{$file_path}="<group_name>$group_name</group_name> <uid>$uid</uid> <gid>$gid</gid> <permission>$permission</permission> <rev_no>$rev_no</rev_no> <action>$action</action>";
        }}
        print "<br/>Files list for secondary groups from 'file_list' table=>\n";
        foreach my $key (keys %file_hash) { print "<br/>$key => $file_hash{$key}\n";}
	#################################
 	# close mysql connection
	$myquery_2->finish;
    } else { print "<xml><error>No secondary record found</error></xml>";}
    ## end of sec grp if/else
	# disconnect DB
	$dbconn->disconnect;		
    } ##end of if-1
}
##################
