#!/usr/bin/perl

sub BEGIN
{
        unshift (@INC, '/home/centconf/module/');
        unshift (@INC, '/usr/lib/perl5/');
}

use strict;
use warnings;
use Admin;
use DBI;
use DBD::mysql;
use CGI qw(:standard);
use Centconfig;

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

## trim func to remove 
#white space
sub trim($)
{
        my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
}
########################################
if ( $ENV{REQUEST_METHOD} eq "POST" )
{
    my %form; my $myquery =undef; my $browser = $ENV{'HTTP_USER_AGENT'};
    foreach my $key (param()) { $form{$key} = trim(param($key));}
 if (($browser eq "centconf/$form{host_name}") && ($form{submit} eq  "CentconFLog") && (($form{run_status} eq "Running") or ($form{run_status} eq "Successful") or ($form{run_status} eq "Failed") or ($form{run_status} eq "Unknown")))
 {
    my $dbconn = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
    my $qry_count = $dbconn->prepare( "SELECT COUNT(*) FROM host_log WHERE host_name='$form{host_name}' ;");
    $qry_count->execute(); my @row = $qry_count->fetchrow_array();my $row_count=$row[0];$qry_count->finish;
    if ($row_count == 1){
	$myquery = $dbconn->prepare("UPDATE host_log SET last_run_time=CURRENT_TIMESTAMP,last_run_status=\"$form{run_status}\",log_messagge=\"$form{log_msg}\" WHERE host_name=\"$form{host_name}\";");
    }elsif ($row_count == 0){ 
	$myquery = $dbconn->prepare("INSERT INTO host_log VALUES(\"$form{host_name}\",CURRENT_TIMESTAMP,\"$form{run_status}\",\"$form{log_msg}\");");
    } 
    #execute the query
    $myquery->execute();
    my $qry_status=$myquery->execute();
    if ($qry_status) { print "<logcent>Log update Successful</logsent>";} else { print "<logcent>Log update Failed</logsent>";}  
    $myquery->finish;     
    $dbconn->disconnect;
 }#browser if
} else 
{
   my %GET; my $mystatus = undef; my $output="";
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
        my $dbconn = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
        my $myquery = $dbconn->prepare( "SELECT * FROM host_log;");
	#execute the query
	$myquery->execute();
	##################
	chomp(my $mydate=`date +'%F %T %Z'`);
	print "<div class='module'><h2><span>Centconf Logs - $mydate</span></h2><div class='module-body'>";
   	print "<table width='95%' class='tablesorter' id='myTable'>";
   	print "<thead><tr>";
   	print "<th class='header' style='width: 2%;'>#</th>";
   	print "<th class='header' style='width: 10%;'><span class='header' style='width: 21%;'>Host Name</span></th>";
   	print "<th class='header' style='width: 14%;'><span class='header' style='width: 21%;'>Run Time</span></th>";
   	print "<th class='header' style='width: 8%;'><span class='header' style='width: 21%;'>Status</span></th>";
   	print "<th class='header' style='width: 60%;'><span class='header' style='width: 21%;'>Log Message</span></th>";
   	print "</tr></thead>";
   	print "<tbody>";
	##################
	my $tr_counter="even";my $row_counter=1;
	while ( my @row = $myquery->fetchrow_array() )
	{
        	if ($tr_counter eq "even") { print "<tr class='even'>";$tr_counter="odd";}else { print "<tr class='odd'>";$tr_counter="even";}
                print "<td class='align-center'>".$row_counter."</td>";
                my ($host_name,$run_time,$process_status, $log_msg) = (@row);
                print "<td><a href='centconf-log.pl?log=".$host_name."'>".$host_name."</a></td> <td>".$run_time."</td>";
                if ($process_status eq "Successful") { print "<td style='background-color:#33FF00;border: 1px solid #FFFFFF;'>".$process_status."</td>";} 
		elsif ($process_status eq "Failed") { print "<td  style='background-color:red;border: 1px solid #FFFFFF;'>".$process_status."</td>";}
		elsif ($process_status eq "Running") { print "<td style='background-color:blue;border: 1px solid #FFFFFF;'>".$process_status."</td>";}
		elsif ($process_status eq "Unknown") { print "<td style='background-color:#FFFF00;border: 1px solid #FFFFFF;'>".$process_status."</td>";}
		else { print "<td>".$process_status."</td>";}
		print "<td>".$log_msg."</td>";
                print "</tr>";
                ## increment row counter
                $row_counter = $row_counter + 1;
	}        
	$myquery->finish;
        $dbconn->disconnect;
        print "</tbody></table></div></div></div>";
	############## form here #################
    	print "<form action='centconf-log.pl' method='POST'>";
   	print "<input class='input-short' type='hidden' name='host_name'></p>";
    	print "<input class='input-short' type='hidden' name='run_status'></p>";
    	print "<input class='input-short' type='hidden' name='log_msg'></p>";
    	print "</form>";
	##########################################
} # end of GET method if

#################################################################
print "</div> <div style='clear: both;'></div>";
#
# Footer
Admin::print_footer();
print $page->end_html; 
#DONE
