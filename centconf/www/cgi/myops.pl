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
use Centconfig;
use Myops;
use Switch;
use DBI;
use DBD::mysql;
use File::stat;

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
Login::is_authen($page);
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
Admin::print_header("Myops");
#
print "<div class='container_12'>";
Myops::world_details_header();

######################################################################
## Myops details started here
######################################################################

if ( $ENV{REQUEST_METHOD} eq "POST" ) 
{
    print "<h2>post</h3>";
    
}
elsif ($ENV{REQUEST_METHOD} eq "GET")
{ 
   #$ENV{REQUEST_METHOD} eq "GET"
   my %FORM;
   $FORM{cmd} = "4554e188-6697-41ca-9241";
   my $query = $ENV{'QUERY_STRING'};
   my @pairs = split(/&/, $query);
    foreach my $pair (@pairs)
    {
	my $name= undef;my $value= undef;
	( $name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%(..)/pack("C", hex($1))/eg;
	$FORM{$name} = $value;
    }
   #########################################
    if ($FORM{cmd} eq "4554e188-6697-41ca-9241" ){ 
	#print "<center><b><font color='red'>Request Not Found!</font></b></center>";
	my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
        my $myquery = $dbconn->prepare( "SELECT * FROM host_details;");
        #execute the query
	$myquery->execute();
        table_header("All Host List");
	my $tr_counter="odd"; my $row_counter=1;
        while ( my @row = $myquery->fetchrow_array() )
        {
        	if ($tr_counter eq "even") { print "<tr class='even'>";$tr_counter="odd";}else { print "<tr class='odd'>";$tr_counter="even";}
		my $counter=1;
		print "<td class='align-center'>".$row_counter."</td>";
                foreach (@row)
                {
                    my $record=$_ || " ";
                    if ($counter eq 1){
           print "<td align='center'><a href='http://10.0.0.5/nagios/cgi-bin/extinfo.cgi?type=1&host=".$record."'>".$record."</a></td>";}
                    else { print "<td align='center'>".$record."</td>";}
                    $counter = $counter + 1;
                }
                print "</tr>";
		## increment row counter
		$row_counter = $row_counter + 1;
	}
        $myquery->finish;
	$dbconn->disconnect;
        print "</tbody></table></div></div>";
    ######################
    }else {
  	#connect to MySQL database
  	my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
	switch($FORM{cmd})
	{
	  ## List process_list table
	   case "host" 
	   {
		my $myquery = $dbconn->prepare( "SELECT * FROM host_details;");
		#execute the query
		$myquery->execute();
		table_header("All Host List");my $tr_counter="odd";my $row_counter=1;
     		while ( my @row = $myquery->fetchrow_array() )
     		{
		  if ($tr_counter eq "even") { print "<tr class='even'>";$tr_counter="odd";}else { print "<tr class='odd'>";$tr_counter="even";}
		  my $counter=1;
		  print "<td class='align-center'>".$row_counter."</td>";
         	  foreach (@row)
         	  {
                     my $record=$_  || " ";
  		     if ($counter eq 1){
           print "<td align='center'><a href='http://10.0.0.5/nagios/cgi-bin/extinfo.cgi?type=1&host=".$record."'>".$record."</a></td>";}
           	     else { print "<td align='center'>".$record."</td>";}
		     $counter = $counter + 1;
         	  }
         	  print "</tr>";
		  ## increment row counter
		  $row_counter = $row_counter + 1;
     		}
     		$myquery->finish;
		$dbconn->disconnect;
		print "</tbody></table></div></div>";
	   }

	## List hosts by bygroup
	   case "host_by_group"
	   {
		print "<br/>";
     		my $myquery = $dbconn->prepare( "SELECT DISTINCT group_name FROM group_details;");
     		#execute the query
     		$myquery->execute();
     		while ( my @row = $myquery->fetchrow_array() )
     		{
       			print "<div class='module'>";
			print "<h2><span>Primary or Secondary Group - ".$row[0]."</span></h2>";
			print "<div class='module-table-body'>";
			print "<table width='95%' class='tablesorter' id='myTable'>";
       			print "<thead><tr>";
       			print "<td align='center'><b><font color='brown'>#</font></b></td>";
       			print "<td align='center'><b><font color='brown'>Host Name</font></b></td>";
       			print "<td align='center'><b><font color='brown'>Host Description</font></b></td>";
       			print "<td align='center'><b><font color='brown'>IP Address</font></b></td>";
       			print "<td align='center'><b><font color='brown'>Secondary Groups</font></b></td>";
       			print "<td align='center'><b><font color='brown'>Host Status</font></b></td>";
       			print "<td align='center'><b><font color='brown'>Location</font></b></td>";
       			print "<td align='center'><b><font color='brown'>Centconf</font></b></td>";
       			print "</tr></thead><tbody>";
 my $host_query=$dbconn->prepare("SELECT host_name,description,host_ipaddr,secondary_group_list,host_status,host_category,centconf_status FROM host_details WHERE primary_group='".$row[0]."' or secondary_group_list like '%".$row[0]."%';");
        		#execute the query
        		$host_query->execute();
			my $tr_counter="odd"; my $row_counter=1;
        		while ( my @host_row = $host_query->fetchrow_array())
        		{
				if ($tr_counter eq "even"){ print "<tr class='even'>";$tr_counter="odd";}else{ print "<tr class='odd'>";$tr_counter="even";}
				print "<td class='align-center'>".$row_counter."</td>";
         			foreach (@host_row)
         			{
           				my $record=$_  || " ";
           				print "<td align='center'>".$record."</td>";
         			}
         			print "</tr>";
				## increment row counter
				$row_counter = $row_counter + 1;
        		}
        		print "</tbody></table></div></div>";
        		$host_query->finish;
    		}
    		$myquery->finish;
		$dbconn->disconnect;
	   }   
	## List by host_by_category
           case "host_by_category"
           {
                print "<br/>";
                my $myquery = $dbconn->prepare( "SELECT DISTINCT host_category FROM host_details;");
                #execute the query
                $myquery->execute();
                while ( my @row = $myquery->fetchrow_array() )
                {    

       			print "<div class='module'>";
			print "<h2><span>Primary or Secondary Group - ".$row[0]."</span></h2>";
			print "<div class='module-table-body'>";
			print "<table width='95%' class='tablesorter' id='myTable'>";
       			print "<thead><tr>";
                        print "<td align='center'><b><font color='brown'>#</font></b></td>";
                        print "<td align='center'><b><font color='brown'>Host Name</font></b></td>";
                        print "<td align='center'><b><font color='brown'>Host Description</font></b></td>";
                        print "<td align='center'><b><font color='brown'>IP Address</font></b></td>";
                        print "<td align='center'><b><font color='brown'>Primary Group</font></b></td>";
                        print "<td align='center'><b><font color='brown'>Secondary Groups</font></b></td>";
                        print "<td align='center'><b><font color='brown'>Host Status</font></b></td>";
                        print "<td align='center'><b><font color='brown'>Centconf</font></b></td>";
                        print "</tr></<thead>";
 my $host_query=$dbconn->prepare("SELECT host_name,description,host_ipaddr,primary_group,secondary_group_list,host_status,centconf_status FROM host_details WHERE host_category='".$row[0]."';");
                        #execute the query
                        $host_query->execute();
			my $tr_counter="odd"; my $row_counter=1;
                        while ( my @host_row = $host_query->fetchrow_array())
                        {
                                if ($tr_counter eq "even"){ print "<tr class='even'>";$tr_counter="odd";}else{ print "<tr class='odd'>";$tr_counter="even";}
				print "<td class='align-center'>".$row_counter."</td>";
                                foreach (@host_row)
                                {
                                        my $record=$_  || " ";
                                        print "<td align='center'>".$record."</td>";
                                }
                                print "</tr>";
			 	## increment row counter
 				$row_counter = $row_counter + 1;
                        }
                        print "</tbody></table></div></div>";
                        $host_query->finish;
                }
                $myquery->finish;
		$dbconn->disconnect;
           }
        ## List by host_by_category
           case "dbhost"
           {
                print "<br/>";
                my $myquery = $dbconn->prepare( "SELECT DISTINCT group_name  FROM group_details WHERE group_name like '%database%' or group_name like '%oracle%' or group_name like '%mysql%' or group_name like '%db%';");
                #execute the query
                $myquery->execute();
                while ( my @row = $myquery->fetchrow_array() )
                {
       			print "<div class='module'>";
			print "<h2><span>Primary or Secondary Group - ".$row[0]."</span></h2>";
			print "<div class='module-table-body'>";
			print "<table width='95%' class='tablesorter' id='myTable'>";
       			print "<thead><tr>";
                        print "<td align='center'><b><font color='brown'>#</font></b></td>";
                        print "<td align='center'><b><font color='brown'>Host Name</font></b></td>";
                        print "<td align='center'><b><font color='brown'>Host Description</font></b></td>";
                        print "<td align='center'><b><font color='brown'>IP Address</font></b></td>";
                        print "<td align='center'><b><font color='brown'>Secondary Groups</font></b></td>";
                        print "<td align='center'><b><font color='brown'>Status</font></b></td>";
                        print "<td align='center'><b><font color='brown'>Location</font></b></td>";
                        print "<td align='center'><b><font color='brown'>Centconf</font></b></td>";
                        print "</tr></thead>";
 my $host_query=$dbconn->prepare("SELECT host_name,description,host_ipaddr,secondary_group_list,host_status,host_category,centconf_status FROM host_details WHERE secondary_group_list like '%".$row[0]."%';");
                        #execute the query
                        $host_query->execute();
			my $tr_counter="odd"; my $row_counter=1;
                        while ( my @host_row = $host_query->fetchrow_array())
                        {
				if ($tr_counter eq "even"){ print "<tr class='even'>";$tr_counter="odd";}else{ print "<tr class='odd'>";$tr_counter="even";}
				print "<td class='align-center'>".$row_counter."</td>";
                                foreach (@host_row)
                                {
                                        my $record=$_  || " ";
                                        print "<td align='center'>".$record."</td>";
                                }
                                print "</tr>";
				## increment row counter
				$row_counter = $row_counter + 1;
                        }
                        print "</tbody></table></div></div>";
                        $host_query->finish;
                }
                $myquery->finish;
		$dbconn->disconnect;
           }
	## end of case
       } # switch end
       ## disconnect DB
       $dbconn->disconnect or warn "Disconnection error: $DBI::errstr\n";
    }
} #end of get/post
##########################
sub table_header
{
 (my $table_header)=(@_);
#-- table --
print "<div class='module'>";
print "<h2><span>".$table_header."</span></h2>";
print <<"TABLE_HEADER";
<div class="module-table-body">
   <table width='95%' class="tablesorter" id="myTable">
    <thead>
   <tr>
   <td align='center'><b><font color='brown'>#</font></b></td>
   <td align='center'><b><font color='brown'>Host Name</font></b></td>
   <td align='center'><b><font color='brown'>Host Description</font></b></td>
   <td align='center'><b><font color='brown'>IP Address</font></b></td>
   <td align='center'><b><font color='brown'>Primary Group</font></b></td>
   <td align='center'><b><font color='brown'>Secondary Groups</font></b></td>
   <td align='center'><b><font color='brown'>Status</font></b></td>
   <td align='center'><b><font color='brown'>Location</font></b></td>
   <td align='center'><b><font color='brown'>Centconf</font></b></td>
   </tr>
   </thead>
   <tbody>
TABLE_HEADER
}

######################################################################
print "<div style='clear: both;'></div></div>"; #-- container_12 end
##################
# Footer
Admin::print_footer();
print $page->end_html; 
#DONE

