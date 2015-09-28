package HAproxy;

### HAproxy details
sub print_haproxy_details
{
print <<"HAPROXY_DETAILS-1";
<!-- HAproxy Details Div start -->
<div class="module">
<h2><span>HAproxy Details</span></h2>
<div class="module-body">
	<table width="68%" class="tablesorter" id="myTable">                         
	    <thead>
		<tr>
			<th width="5%" class="header" style="width: 2%;">#</th>
                        <th width="16%" class="header" style="width: 20%;"><span class="header">Instance Name</span></th>
                        <th width="25%" class="header" style="width: 25%;"><span class="header">Description</span></th>
                        <th width="13%" class="header" style="width: 15%;"><span class="header">HA Server</span></th>
                        <th width="13%" class="header" style="width: 20%;">Domain Names</th>
                        <th width="13%" class="header" style="width: 10%;">Status</th>
		</tr>
	    </thead>
HAPROXY_DETAILS-1

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
                        print "<td><a href='haproxy.pl'>".$mygrp_name."</a></td>";
                       	print "<td>".$mygrp_desc."</td>";
                        print "<td>appha1.world.colo</td>";
                        print "<td>blogs.world.com,de.world.com,id.world.com</td>";
                        print "<td id='status_group_$mygrp_name'>".$mystatus."</td>";
                print "</tr>";
		## increment row counter
		$row_counter = $row_counter + 1;
        }
        $myquery->finish;
	$dbconn->disconnect;
	print "</tbody></table>";
################################################
print "<fieldset><a href='haproxy.pl?add=ha_server' > <img src='../images/button/add_ha_server.png'> </a></fieldset>";
print <<"HAPROXY_DETAILS";
</div>
</div> 
<!-- HAproxy Details Div end -->
HAPROXY_DETAILS
}

### Backend (web server) Details
sub print_backend_details
{

print <<"BACKEND_DETAILS-1";

<!-- Backend Details Div start -->
<div class="module">
<h2><span>Backend (web server) Details</span></h2>
<div class="module-body">
	<table width="68%" class="tablesorter" id="myTable">
	    <thead>
                <tr>         
                        <th class="header" style="width: 2%;">#</th>
                        <th class="header" style="width: 14%;"><span class="header" style="width: 21%;">Host Name</span></th>
                        <th class="header" style="width: 17%;"><span class="header" style="width: 13%;">Description</span></th>
                        <th class="header" style="width: 10%;"><span class="header" style="width: 13%;">IP Addr</span></th>
                        <th class="header" style="width: 8%;"><span class="header" style="width: 13%;">Port Number</span></th>
                        <th class="header" style="width: 20%;"><span class="header" style="width: 13%;">HAproxy Instances</span></th>
                        <th class="header" style="width: 10%;">Status</th>
                </tr>
            </thead>
BACKEND_DETAILS-1

################################################
        (my $host,my $db,my $user, my $password) =(@_);
        my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
        my $myquery = $dbconn->prepare( "SELECT backend_name,description,ip_addr,port_number,status  FROM ha_backend;");
        #execute the query
        $myquery->execute();
        my $tr_counter="even"; my $row_counter=1;
        print "<tbody>";
        while ( my @row = $myquery->fetchrow_array() )
        {
                if ($tr_counter eq "even") { print "<tr class='even'>";$tr_counter="odd";}else { print "<tr class='odd'>";$tr_counter="even";}
                print "<td class='align-center'>".$row_counter."</td>";
                my ($backend_name, $backend_desc,$ip_addr, $port_number,$mystatus) = (@row);
                        print "<td><a href='haproxy.pl?log=$backend_name'>".$backend_name."</a></td>";
                        print "<td>".$backend_desc."</td>";
                        print "<td>".$ip_addr."</td>";
                        print "<td>".$port_number."</td>";
                        print "<td>arun</td>";
                        print "<td id='status_host_$backend_name'>".$mystatus."</td>";
                print "</tr>";
                ## increment row counter
                $row_counter = $row_counter + 1;
        }
        $myquery->finish;
	$dbconn->disconnect;
        print "</tbody></table>";
################################################
print "<fieldset><a href='haproxy.pl?add=ha_backend' > <img src='../images/button/add_backend.png'> </a></fieldset>";
print <<"BACKEND_DETAILS";
</div>                
</div>
</div>
<!-- Backend Details Div End -->
BACKEND_DETAILS
}

### side panel HAproxy tree
sub haproxy_tree
{

	### -- Domain Tree  --
	print "<div class='grid_3'><div class='module'>";
	print "<h2><span><a href=''><img src='../images/haproxy/tree-ha.gif' height='16' width='16'/></a>Domain Tree</span></h2>";
	print "<div class='module-body'>";
	###
    	my ($server_name, $instance_name, $host, $db, $user, $password) =(@_); $log_total=undef;
	#############################
        my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
        #execute the query - total no of logging hosts/entries
        my $myquery = $dbconn->prepare( "SELECT host_name FROM ha_server;");
        $myquery->execute(); 
        while ( my @row = $myquery->fetchrow_array() )
        {
	  my ($ha_name) = (@row);
	  ########## haproxy tree here #########
	  print "<ul id='domain_tree_browser' class='filetree treeview-famfamfam'>";
	  print "<li><span class='folder'> <a href='haproxy.pl?server=".$ha_name."'>".$ha_name."</a> </span><ul>";
	  #print "<li><span class='guest_running'> <a class='selected' href='haproxy.pl?server=".$ha_name."&instance=world.com'>world.com</a> </span></li>";
	  print "<li><span class='guest_stop'> <a href='haproxy.pl?server=appha1.world.colo&instance=world.de'>world.de</a> </span></li>";
	  print "<li><span class='guest_running'> <a href='haproxy.pl?server=appha1.world.colo&instance=world.fr'>world.fr</a> </span></li>";
	  print "<li><span class='guest_stop'> <a href='haproxy.pl?server=appha1.world.colo&instance=brash.com'>brash.com</a> </span></li>";
print "</ul></li>";
	}
	$myquery->finish;
	### disconnecting DB
	$dbconn->disconnect;

########################### haproxy tree here ######################
print "<ul id='domain_tree_browser' class='filetree treeview-famfamfam'>";
print "<li><span class='folder'> <a href='haproxy.pl?server=appha1.world.colo'>appha1.world.colo</a> </span><ul>";
	print "<li><span class='guest_running'> <a class='selected' href='haproxy.pl?server=appha1.world.colo&instance=world.com'>world.com</a> </span></li>";
	print "<li><span class='guest_stop'> <a href='haproxy.pl?server=appha1.world.colo&instance=world.de'>world.de</a> </span></li>";
	print "<li><span class='guest_running'> <a href='haproxy.pl?server=appha1.world.colo&instance=world.fr'>world.fr</a> </span></li>";
	print "<li><span class='guest_stop'> <a href='haproxy.pl?server=appha1.world.colo&instance=brash.com'>brash.com</a> </span></li>";
print "</ul></li>";

##-- <li class='folder'><span class="folder">ruskapp1.world.com</span><ul> --
print "<li class='closed'><span class='folder'> <a href='haproxy.pl?server=ruskapp1.world.com'>ruskapp1.world.com</a> </span><ul>";
	print "<li><span class='guest_running'> <a href='haproxy.pl?server=ruskapp1&instance=cece.world.com'>cece.world.com</a> </span></li>";
	print "<li><span class='guest_running'> <a href='haproxy.pl?server=ruskapp1&instance=brash.uk'>brash.uk</a> </span></li>";
	print "<li><span class='guest_stop'> <a href='haproxy.pl?server=ruskapp1&instance=www17-orig.world.com'>www17-orig.world.com</a> </span></li>";
	print "<li><span class='guest_running'> <a href='haproxy.pl?server=ruskapp1&instance=world.uk'>world.uk</a> </span></li>";
        print "<li><span class='guest_paused'> <a href='haproxy.pl?server=ruskapp1&instance=brash.de'>brash.de</a> </span></li>";
print "</ul></li>";
print "</ul>";
########################### haproxy tree end ######################
##-- BASE div start --
print "</div>";
##-- BASE div end --
print "</div>";
print "</div></div>";
##-- Domain Tree /grid_4 end --
}

### HAproxy Log Message

sub print_log_message
{

   my ($is_new_wider,$host,$db,$user,$password) =(@_);
   ## container_12 div for log message start
   if ($is_new_wider eq "yes_wider") { print "<div class='container_12'>";}

print <<"LOG_MESSAGE-1";
<!-- Log message Div start -->
<div class="module">
<h2><span>Log Message</span></h2>
<div class="module-body">
        <table width="68%" class="tablesorter" id="myTable">
            <thead>
                <tr>         
                        <th class="header" style="width: 5%;"><span class="header">Job Id</span></th>
                        <th class="header" style="width: 20%;"><span class="header">Process Name</span></th>
                        <th class="header" style="width: 20%;"><span class="header">Server Name</span></th>
                        <th class="header" style="width: 10%;"><span class="header">Status</span></th>
                        <th class="header" style="width: 20%;"><span class="header">Date Created</span></th>
                        <th class="header" style="width: 20%;"><span class="header">Date Modified</span></th>
                </tr>
            </thead>
LOG_MESSAGE-1

################################################
        my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
        my $myquery = $dbconn->prepare( "SELECT host_name,description,host_ipaddr,primary_group,secondary_group_list,centconf_status FROM host_details;");
        #execute the query
        $myquery->execute();
        my $tr_counter="even"; my $row_counter=1;
        print "<tbody>";
        while ( my @row = $myquery->fetchrow_array() )
        {
                if ($tr_counter eq "even") { print "<tr class='even'>";$tr_counter="odd";}else { print "<tr class='odd'>";$tr_counter="even";}
                (my $myhost_name, my $myhost_desc, my $myip_addr,my $mypri_grp, my $mysec_grp,my $mystatus) = (@row);
                        print "<td><a href='haproxy.pl?log_id=$myhost_name'>1043</a></td>";
                        print "<td>start_ha</td>";
                        print "<td>".$myhost_name."</td>";
                        print "<td>Running<div class='indicator'><div style='width: 60%;'></div></div></td>";
                        print "<td>2010-08-04 19:10:57</td>";
                        print "<td>2010-08-04 19:12:57</td>";
                print "</tr>";
        }
        $myquery->finish;
        $dbconn->disconnect;
        print "</tbody></table>";
################################################

print <<"LOG_MESSAGE";
</div>                
</div>                
</div>
LOG_MESSAGE
## container_12 div for log message end
if ($is_new_wider eq "yes_wider") { print "<div class='container_12'>";}
## -- Log message Div End --
}


### HAproxy Window
sub print_haproxy_window
{
    #####
    my ($server_name,$instance_name,$host,$db,$user,$password) =(@_);

## -- HAproxy Window Div start -->
print "<div class='module'>";
print "<h2><span>";
print "<img src='../images/haproxy/home-icon.png' /><font color='green'> WorldHA:</font><img src='../images/haproxy/arrow.png'/>";
print "<a href='haproxy.pl?server=$server_name'><font color='brown'> $server_name </font></a>";
if ($instance_name) {   print "<img src='../images/haproxy/arrow.png'/>";
		  	print "<a href='haproxy.pl?server=$server_name&instance=$instance_name'><font color='blue'> $instance_name </font></a>";
}
print "</span></h2>";
print "<br style='clear:both;'/>";
print "<div class='module-body'>";

## -- HAproxy TAB --
	print "<div id='haproxy_jquery_tabs' style='margin:10px 0px 0px;'>";
		print "<ul>";
		print "<li><a href='haproxy-template.pl?tab=ha_server#remote-tab-1'><span>General Info</span></a></li>";
                print "<li><a href='../setting.html#remote-tab-2'><span>Setting</span></a></li>";
                print "<li><a href='../network.html#remote-tab-3'><span>Network</span></a></li>";
                print "<li><a href='../job.html#remote-tab-4'><span>Job</span></a></li>";
		print "<li><a href='../log.html#remote-tab-5'><span>Logs</span></a></li>";
		print "</ul>";
	print "</div>";
## -- HAproxy TAB end --
print "</div></div>";

}

#############
### Add HAproxy Server
sub add_ha_server
{

## -- HAproxy server Div start
print "<div class='module'>";
print "<h2><span><img src='../images/haproxy/home-icon.png' /><font color='green'> WorldHA:</font><img src='../images/haproxy/arrow.png'/>";
print "<font color='brown'>Add HAproxy Server</font></span></h2>";
print "<div class='module-body'>";
print "<form action='haproxy-modify.pl?type=ha_server' method='POST'>";

        ####
        (my $status, my $host, my $db, my $user, my $password) = (@_);
        if ($status eq "successful")
        { print "<div><span class='notification n-success'>Record successfully added!</span></div>";}
        elsif ($status eq "failed") { print "<div><span class='notification n-error'>Failed to add record? Please try again.</span></div>";}
        ####
         ####################### Get Host start #########################
         my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
	 my $myquery = $dbconn->prepare( "SELECT host_name,host_ipaddr FROM host_details WHERE host_status='up';");
         #execute the query
         $myquery->execute();
         print "<p>";
                print "<label>HA Server Name</label>";
                print "<select class='input-short' name='ha_server_name'>";
                        while ( my @row = $myquery->fetchrow_array())
                        { print "<option value='".$row[0]."'>".$row[0]." [".$row[1]."]</option>";}
                print "</select>";
                if ($status eq "errno5" ) { print "<span class='notification-input ni-error'>HA Server Name required!</span>";}
                print "</p>";
         $myquery->finish;
         $dbconn->disconnect;
        ####################### Get Host end ############################

print <<"HAPROXY_SERVER";
        <p>
                <label>Server Description</label>
                <input class="input-medium" type="text" name=ha_server_desc>
                <!-- span class="notification-input ni-correct">This is correct, thanks!</span -->
                <!-- span class="notification-input ni-error">Sorry, try again.</span -->
        </p>
HAPROXY_SERVER

	print "<p>";
                print "<label>Interface:1</label>";
                print "<input class='input-medium' type='text' name=interface1>";
		if ($status eq "errno5" ) { print "<span class='notification-input ni-error'>Interface:1 required!</span>";}
	print "</p>";
        print "<p>";
                print "<label>IP Address:1</label>";
                print "<input class='input-medium' type='text' name=ip_addr1>";
		if ($status eq "errno5" ) { print "<span class='notification-input ni-error'>IP Address:1 required!</span>";}
	print "</p>";

print <<"HAPROXY_SERVER-1";
        <p>
                <label>Interface:2</label>
                <input class="input-medium" type="text" name=interface2>
	</p>
        <p>
                <label>IP Address:2</label>
                <input class="input-medium" type="text" name=ip_addr2>
	</p>
        <p>
                <label>VIP Range (range like 192.168.0.1 - 192.168.0.150)</label>
                <input class="input-medium" type="text" name=vip_range>
	</p>

	<fieldset>
		<input class="submit-green" value="Submit" type="submit" name='submit'> 
		<input class="submit-gray" value="Cancel" type="submit" name='cancel'>
	</fieldset>
	              
</form>                     
</div>
</div></div>
<!-- HAproxy server Div end -->
HAPROXY_SERVER-1

}

#############
### Add Backend server
sub add_backend_server
{

## -- HAproxy backend Div start
print "<div class='module'>";
print "<h2><span><img src='../images/haproxy/home-icon.png' /><font color='green'> WorldHA:</font><img src='../images/haproxy/arrow.png'/>";
print "<font color='brown'>Add Backend Server</font></span></h2>";
print "<div class='module-body'>";
print "<form action='haproxy-modify.pl?type=ha_backend' method='POST'>";

        ####
        (my $status, my $host, my $db, my $user, my $password) = (@_);
        if ($status eq "successful")
        { print "<div><span class='notification n-success'>Record successfully added!</span></div>";}
        elsif ($status eq "failed") { print "<div><span class='notification n-error'>Failed to add record? Please try again.</span></div>";}
        ####
        ####################### Get Host start #########################
         my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
         my $myquery = $dbconn->prepare( "SELECT host_name,host_ipaddr FROM host_details WHERE host_status='up';");
         #execute the query
         $myquery->execute();
         print "<p>";
                print "<label>Backend Name</label>";
                print "<select class='input-short' name='backend_name'>";
                        while ( my @row = $myquery->fetchrow_array())
                        { print "<option value='".$row[0]."'>".$row[0]." [".$row[1]."]</option>";}
                print "</select>";
                if ($status eq "errno5" ) { print "<span class='notification-input ni-error'>Backend Name required!</span>";}
                print "</p>";
         $myquery->finish;
         $dbconn->disconnect;
        ####################### Get Host end ############################

print <<"HAPROXY_BACKEND";
        <p>
                <label>Backend Description</label>
                <input class="input-medium" type="text" name=backend_desc>
                <!-- span class="notification-input ni-correct">This is correct, thanks!</span -->
                <!-- span class="notification-input ni-error">Sorry, try again.</span -->
        </p>
HAPROXY_BACKEND
        print "<p>";
                print "<label>IP Address</label>";
                print "<input class='input-medium' type='text' name=ip_addr>";
		if ($status eq "errno5" ) { print "<span class='notification-input ni-error'>IP Address required!</span>";}
        print "</p>";

        print "<p>";
                print "<label>Port Number</label>";
                print "<input class='input-medium' type='text' name=port_number>";
		if ($status eq "errno5" ) { print "<span class='notification-input ni-error'>Port Number required!</span>";}
        print "</p>";

print <<"HAPROXY_BACKEND-1";
	<p>
		<label>Status</label>
		<select name="status" class="input-small">
			<option selected="selected" value="Enabled">Enabled</option>
			<option value="Disabled">Disabled</option>
		</select>
	</p>
        <fieldset>
                <input class="submit-green" value="Submit" type="submit" name='submit'> 
                <input class="submit-gray" value="Cancel" type="submit" name='cancel'>
        </fieldset>
                      
</form>                     
</div>
</div></div>
<!-- HAproxy backend Div end -->
HAPROXY_BACKEND-1
}

#done
1;
