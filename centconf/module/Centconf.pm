package Centconf;

### Group details
sub print_group_details
{
print <<"GROUP_DETAILS-1";
<!-- Group Details Div start -->
<div class="module">
<h2><span>Group Details</span></h2>
<div class="module-body">
	<table width="68%" class="tablesorter" id="myTable">                         
	    <thead>
		<tr>
			<th width="5%" class="header" style="width: 2%;">#</th>
                        <th width="16%" class="header" style="width: 20%;"><span class="header" style="width: 21%;">Group Name </span></th>
                        <th width="25%" class="header" style="width: 28%;"><span class="header" style="width: 13%;">Description</span></th>
                        <th width="13%" class="header" style="width: 13%;"><span class="header" style="width: 13%;">Dept</span></th>
                        <th width="13%" class="header" style="width: 10%;">SVN # </th>
                        <th width="13%" class="header" style="width: 12%;">Status</th>
                        <th width="15%" style="width: 15%;"></th>
		</tr>
	    </thead>
GROUP_DETAILS-1

################################################
	(my $host,my $db,my $user, my $password) =(@_);
        my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
        my $myquery = $dbconn->prepare( "SELECT * FROM group_details;");
	#execute the query
	$myquery->execute();
	my $tr_counter="even"; my $row_counter=1;
	print "<tbody>";
        while ( my @row = $myquery->fetchrow_array() )
        {
                if ($tr_counter eq "even") { print "<tr class='even'>";$tr_counter="odd";}else { print "<tr class='odd'>";$tr_counter="even";}
		print "<td class='align-center'>".$row_counter."</td>";
		(my $mygrp_name, my $mygrp_desc, my $mydept,my $mysvn_no, my $mystatus) = (@row);
                        print "<td><a href='centconf.pl?type=editor'>".$mygrp_name."</a></td>";
                       	print "<td>".$mygrp_desc."</td>";
                        print "<td>".$mydept."</td>";
                        print "<td>".$mysvn_no."</td>";
                        print "<td id='status_group_$mygrp_name'>".$mystatus."</td>";
if ($mystatus eq "Disabled") { 
print "<td><input name='checkbox' type='checkbox' /><input type='hidden' id='hdn_group_$mygrp_name' name='hdn_group_$mygrp_name' value='enable'> <a href='#'><img id='img_group_$mygrp_name' onclick=\"enable_disable('group','enable','$mygrp_name')\" src='../images/tick-circle.gif' height='16' width='16' title='Status' /></a><a href='centconf.pl?type=modify&group=".$mygrp_name."'><img src='../images/pencil.gif' alt='edit' height='16' width='16' /></a> <a href=''><img src='../images/balloon.gif' alt='comments' height='16' width='16' /></a> <a href=''><img src='../images/bin.gif' alt='delete' height='16' width='16' /></a></td>";} 
else {
print "<td><input name='checkbox' type='checkbox' /> <input type='hidden' id='hdn_group_$mygrp_name' name='hdn_group_$mygrp_name' value='disable'> <a href='#'><img id='img_group_$mygrp_name' onclick=\"enable_disable('group','disable','$mygrp_name')\" src='../images/minus-circle.gif' height='16' width='16' title='Status' /></a><a href='centconf.pl?type=modify&group=".$mygrp_name."'><img src='../images/pencil.gif' alt='edit' height='16' width='16' /></a> <a href=''><img src='../images/balloon.gif' alt='comments' height='16' width='16' /></a> <a href=''><img src='../images/bin.gif' alt='delete' height='16' width='16' /></a></td>";
}
                print "</tr>";
		## increment row counter
		$row_counter = $row_counter + 1;
        }
        $myquery->finish;
	$dbconn->disconnect;
	print "</tbody></table>";
################################################

print <<"GROUP_DETAILS";
<!-- form action="centconf.pl" -->
<fieldset>
	<a href="centconf.pl?type=group" style="text-decoration:none"><input type="image" class="submit-green" value="Add Group" /></a>
</fieldset>
                       
<!-- /form -->
</div>
</div> 
<!-- Group Details Div end -->
GROUP_DETAILS
}

### Host Details
sub print_host_details
{

print <<"HOST_DETAILS-1";

<!-- Host Details Div start -->
<div class="module">
<h2><span>Host Details</span></h2>
<div class="module-body">
	<table width="68%" class="tablesorter" id="myTable">
	    <thead>
                <tr>         
                        <th width="5%" class="header" style="width: 2%;">#</th>
                        <th width="20%" class="header" style="width: 14%;"><span class="header" style="width: 21%;">Host Name</span></th>
                        <th width="21%" class="header" style="width: 17%;"><span class="header" style="width: 13%;">Description</span></th>
                        <th width="21%" class="header" style="width: 10%;"><span class="header" style="width: 13%;">IP Addr</span></th>
                        <th width="15%" class="header" style="width: 8%;"><span class="header" style="width: 13%;">Primary Group</span></th>
                        <th width="13%" class="header" style="width: 16%;"><span class="header" style="width: 13%;">Secondary Groups</span></th>
                        <th width="13%" class="header" style="width: 8%;">Centconf Status</th>
                        <th width="13%" style="width: 18%;"></th>
                </tr>
            </thead>
HOST_DETAILS-1

################################################
        (my $host,my $db,my $user, my $password) =(@_);
        my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
        my $myquery = $dbconn->prepare( "SELECT host_name,description,host_ipaddr,primary_group,secondary_group_list,centconf_status FROM host_details;");
        #execute the query
        $myquery->execute();
        my $tr_counter="even"; my $row_counter=1;
        print "<tbody>";
        while ( my @row = $myquery->fetchrow_array() )
        {
                if ($tr_counter eq "even") { print "<tr class='even'>";$tr_counter="odd";}else { print "<tr class='odd'>";$tr_counter="even";}
                print "<td class='align-center'>".$row_counter."</td>";
                (my $myhost_name, my $myhost_desc, my $myip_addr,my $mypri_grp, my $mysec_grp,my $mystatus) = (@row);
                        print "<td><a href='centconf-log.pl?log=$myhost_name'>".$myhost_name."</a></td>";
                        print "<td>".$myhost_desc."</td>";
                        print "<td>".$myip_addr."</td>";
                        print "<td>".$mypri_grp."</td>";
                        print "<td>".$mysec_grp."</td>";
                        print "<td id='status_host_$myhost_name'>".$mystatus."</td>";
if ($mystatus eq "Disabled") { 
print "<td><input name='checkbox' type='checkbox' /><input type='hidden' id='hdn_host_$myhost_name' name='hdn_host_$myhost_name' value='enable'> <a href='#'><img id='img_host_$myhost_name' onclick=\"enable_disable('host','enable','$myhost_name')\" src='../images/tick-circle.gif' height='16' width='16' title='Status' /></a><a href='centconf.pl?type=modify&host=".$myhost_name."'><img src='../images/pencil.gif' alt='edit' height='16' width='16' /></a> <a href=''><img src='../images/balloon.gif' alt='comments' height='16' width='16' /></a> <a href=''><img src='../images/bin.gif' alt='delete' height='16' width='16' /></a></td>";}
else {
print "<td><input name='checkbox' type='checkbox' /><input type='hidden' id='hdn_host_$myhost_name' name='hdn_host_$myhost_name' value='disable'> <a href='#'><img id='img_host_$myhost_name' onclick=\"enable_disable('host','disable','$myhost_name')\" src='../images/minus-circle.gif' height='16' width='16' title='Status' /></a><a href='centconf.pl?type=modify&host=".$myhost_name."'><img src='../images/pencil.gif' alt='edit' height='16' width='16' /></a> <a href=''><img src='../images/balloon.gif' alt='comments' height='16' width='16' /></a> <a href=''><img src='../images/bin.gif' alt='delete' height='16' width='16' /></a></td>";
}
                print "</tr>";
                ## increment row counter
                $row_counter = $row_counter + 1;
        }
        $myquery->finish;
	$dbconn->disconnect;
        print "</tbody></table>";
################################################

print <<"HOST_DETAILS";
<!-- form action="centconf.pl" -->
<fieldset>
	<a href="centconf.pl?type=host" style="text-decoration:none"><input type="image" class="submit-green" value="Add Host" /></a>
</fieldset>
<!-- /form -->
</div>                
</div>
</div>
<!-- Host Details Div End -->
HOST_DETAILS
}

### sidepanel
sub side_panel
{

print <<"SIDE_PANEL";

<!-- Centconf Summary  -->
<div class="grid_3">
<div class="module">
<h2><span>Centconf Summary </span></h2>                     
<div class="module-body">   	
SIDE_PANEL
	#############################
        (my $host,my $db,my $user, my $password) =(@_); $log_total=undef;
        my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
        #execute the query - total no of logging hosts/entries
        my $myquery = $dbconn->prepare( "SELECT COUNT(*) as runn FROM host_log;");
        $myquery->execute(); my @row = $myquery->fetchrow_array();my $log_total=$row[0];$myquery->finish;
	## running
	$myquery = $dbconn->prepare( "SELECT COUNT(*) FROM host_log WHERE last_run_status='Running';");
	$myquery->execute(); @row = $myquery->fetchrow_array();my $log_running=$row[0];$myquery->finish;
	## completed 
        $myquery = $dbconn->prepare( "SELECT COUNT(*) FROM host_log WHERE last_run_status='Successful';");
        $myquery->execute(); @row = $myquery->fetchrow_array();my $log_completed=$row[0];$myquery->finish;
        ## failed
        $myquery = $dbconn->prepare( "SELECT COUNT(*) FROM host_log WHERE last_run_status='Failed';");
        $myquery->execute(); @row = $myquery->fetchrow_array();my $log_failed=$row[0];$myquery->finish;
	### disconnecting DB
	$dbconn->disconnect;
	## calculate percentage
	my $running_percentage = 0; my $completed_percentage = 0;
	if($log_total){
	    $running_percentage = ($log_running /$log_total) * 100; $running_percentage=sprintf("%.0f",$running_percentage);
	    $completed_percentage = ($log_completed /$log_total) * 100; $completed_percentage=sprintf("%.0f",$completed_percentage);
	}
	#############################
	chomp( my $myuptime=`uptime`);
	print "<p>";
		print "<strong>Host Logs : </strong> Total- $log_total , Running- $log_running , completed- $log_completed<br>";
		print "<strong>Failed On :<font color='red'> $log_failed hosts </font></strong><br>";
                print "<strong>Server Status: </strong>$myuptime";		
	print "</p>";
	    
	print "<div>";
		print "<div class='indicator'>";
		## <!-- change the width value (X%) to dynamically control your indicator -->
		print "<div style='width: $running_percentage%;'></div>";
		print "</div>";
		print "<p>$running_percentage% clients are running...</p>";
	print "</div>";
	print "<div>";
 	    	print "<div class='indicator'>";
		print "<div style='width: $completed_percentage%;'></div>";
	print "</div>";
        print "</div>";           
	     	print "<p>Completed on $completed_percentage% hosts </p>";
		print "<a href='centconf-log.pl' title='click here for Centconf Logs details' target='_new'>Centconf Logs</a>";
		print  "| <a href='svnweb.pl' target='_new'>SVN Web</a><br/>";
	print "</div>";

print <<"SIDE_PANEL-1";
</div>
</div></div>
<!-- Centconf Summary /grid_4 end -->
SIDE_PANEL-1
}

### User profile
sub user_profile 
{
	my ($client_ip,$login_name) = (@_);

print <<"USER_PROFILE-1";
<div class="container_12">
<!-- User Profile -->
<div class="grid_3">
<div class="module">
<h2><span>User Profile</span></h2>
<div class="module-body">
USER_PROFILE-1

	print "<p>";
		#print "<strong>User: </strong>$login_name<br>";
		print "<strong>User: </strong><a href='user_admin.pl?type=modify&user_id=$login_name'> <span>".$login_name." <img src='../images/user.gif' alt=''></span></a><br>";
		print "<strong>Your last visit was on: </strong>20 January 2010,<br>";
                print "<strong>From IP: </strong>$client_ip";
	print "</p>";

print <<"USER_PROFILE";
	<div>
		<p>Group Owner : World</p>
	</div>

	<div>
	     <p>Team Name: Myops </p>
	</div>
	<a href="user_admin.pl">Manage Profiles</a> | <a href="logout.pl">Logout</a><br/> 
</div>        
</div></div> 
<!-- User Profile /grid_4 end -->
<div style="clear: both;"></div>
</div>

USER_PROFILE
}

#done
1;
