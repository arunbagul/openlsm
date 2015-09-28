package CentconfModify;

### Group details
sub modify_group
{
print <<"GROUP_DETAILS-1";
<!-- Add Group Div start -->
<div class="module">
<h2><span>Modify Group</span></h2>
<div class="module-body">
<form action="centconf-modify.pl" method="POST">
GROUP_DETAILS-1

        ####
	(my $myreturn, my $grp_id, my $host, my $db, my $user, my $password) = (@_);
        if ($myreturn eq "successful")
	##
        { print "<div><span class='notification n-success'>Record successfully modified!</span></div>";}
        elsif ($myreturn eq "failed") { print "<div><span class='notification n-error'>Failed to modify record? Please try again.</span></div>";}
        ####
        my $dbconn = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
        my $count_qry = $dbconn->prepare( "SELECT count(*) FROM group_details WHERE group_name='$grp_id';");
        #execute the query
        $count_qry->execute();
	my @row_count = $count_qry->fetchrow_array();
	if ( $row_count[0] == 0 ) { print "<span class='notification-input ni-error'>Group doesn't exist!</span>"; die; }
	$count_qry->finish;
	##
	my $myquery = $dbconn->prepare( "SELECT * FROM group_details WHERE group_name='$grp_id';");        
	#execute the query
        $myquery->execute();
	my @row = $myquery->fetchrow_array();
	(my $grp_name,my $desc,my $dept,my $rev_no,my $status) = @row;
	$myquery->finish;
	$dbconn->disconnect;

	print "<p><label>Group Name </label><input class='input-short' type='text' value='$grp_id' name='grp_name' READONLY>";
	if ($myreturn eq "errno1" ) { print "<span class='notification-input ni-error'>Group Name required!.</span>";}
	print "</p>";
	print "<p><label>Group Description</label> <input class='input-medium' type='text' value='$desc' name=grp_desc></p>";
	####################### Dept start #########################
         my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
         my $myquery = $dbconn->prepare( "SELECT dept_name,dept_desc FROM user_department WHERE status='Enabled';");
         #execute the query
         $myquery->execute();
         print "<p>";
                print "<label>Department</label>";
                print "<select class='input-short' name='grp_dept'>";
			print "<option selected='selected' value='$dept'>$dept</option>";
                        while ( my @row = $myquery->fetchrow_array())
                        { print "<option value='".$row[0]."'>".$row[1]."</option>";}
                print "</select>";
                print "</p>";
         $myquery->finish;
         $dbconn->disconnect;
	####################### Dept end #########################
	print "<p><label>Resvision No</label> <input class='input-short' type='text' value='$rev_no' name='rev_no'></p>";

	print "<p><label>Status</label>";
		print "<select class='input-small' name=grp_status>";
                	print "<option selected='selected' value='$status'>$status</option>";
                	print "<option value='Enabled'>Enabled</option>";
                        print "<option value='Disabled'>Disabled</option>";
                print "</select></p>";
		print "<fieldset><input class='submit-green' value='Submit' type='submit' name='submit_group'></fieldset>";

print "</form></div>";
print "</div></div>";
#-- Group Details Div end --
}

### Host Details
sub modify_host
{

print <<"HOST_DETAILS-1";
<!-- Add Host Div start -->
<div class="module">
<h2><span>Modify Host</span></h2>
<div class="module-body">

<form action="centconf-modify.pl" method="POST">
HOST_DETAILS-1

	####
	(my $myreturn, my $host_id, my $host, my $db, my $user, my $password) = (@_);
	if ($myreturn eq "successful") 
	{ print "<div><span class='notification n-success'>Record successfully modified!</span></div>";}
	elsif ($myreturn eq "failed") { print "<div><span class='notification n-error'>Failed to modified record? Please try again.</span></div>";}
	####
        my $dbconn = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
        my $count_qry = $dbconn->prepare( "SELECT count(*) FROM host_details WHERE host_name='$host_id';");
        #execute the query
        $count_qry->execute();
        my @row_count = $count_qry->fetchrow_array();
        if ( $row_count[0] == 0 ) { print "<span class='notification-input ni-error'>Host doesn't exist!</span>"; die; }
        $count_qry->finish;
        ##
        my $myquery = $dbconn->prepare( "SELECT * FROM host_details WHERE host_name='$host_id';");
        #execute the query
        $myquery->execute();
        my @row = $myquery->fetchrow_array();
        (my $host_name,my $desc,my $host_ipaddr,my $primary_group,my $secondary_group_list,my $host_status,my $host_category,my $centconf_status) = @row;
        $myquery->finish;
        $dbconn->disconnect;
	####
	print "<p><label>Host Name</label><input class='input-short' type='text' value='$host_id' name='host_name' READONLY>";
		if ($myreturn eq "errno1" ) { print "<span class='notification-input ni-error'>Host Name required!.</span>";}
	print "</p>";

	print "<p><label>IP Address</label><input class='input-short' type='text' value='$host_ipaddr' name='ip_addr'></p>";
        print "<p><label>Host Description</label><input class='input-medium' type='text' value='$desc' name='description'></p>";
	print "<p><label>Primary Group</label><input class='input-medium' type='text' value='$primary_group'  name='primary_grp'></p>";
	###
	print "<p><label>Secondary Group (max 5)</label><input class='input-medium' type='text' value='$secondary_group_list' name='secondary_group_list'>";
	if ($myreturn eq "errno5" ) { print "<span class='notification-input ni-error'>Sorry, try again.</span>";}
	print "</p>";
	###
        print "<p><label>Host Status</label><select name='host_status' class='input-small'>";
			print "<option selected='selected' value='$host_status'>$host_status</option>";
			print "<option value='up'>UP</option>";
                        print "<option value='down'>Down</option>";
                        print "<option value='ofr'>Out of Rotation</option>";
        print "</select></p>";
        print "<p><label>Host Category</label><select name='host_category' class='input-small'>";
                        print "<option selected='selected' value='$host_category'>$host_category</option>";
                        print "<option value='Production'>Production</option>";
                        print "<option value='QA'>QA</option>";
                        print "<option value='Testing'>Testing</option>";
       print "</select></p>";
       print "<p><label>Centconf Status</label><select name='centconf_status' class='input-small'>";
                        print "<option selected='selected' value='$centconf_status'>$centconf_status</option>";
                        print "<option value='Enabled'>Enabled</option>";
                        print "<option value='Disabled'>Disabled</option>";
       print "</select></p>";

print <<"HOST_DETAILS";
		<fieldset>
			<input class="submit-green" value="Submit" type="submit" name='submit_host'> 
		</fieldset>                 
</form>
</div>
</div></div>
<!-- Host Details Div End -->
HOST_DETAILS
}

### Files Details
sub modify_files
{

print <<"ADD_FILES-1";
<!-- Add Files Div start -->
<div class="module">
<h2><span>Modify Files</span></h2>
<div class="module-body">
<form action="centconf-modify.pl" method="POST">
ADD_FILES-1

        ##########
        (my $myreturn, my $file_id, my $host, my $db, my $user, my $password) = (@_);
        if ($myreturn eq "successful")
        { print "<div><span class='notification n-success'>Record successfully modified!</span></div>";}
        elsif ($myreturn eq "failed") { print "<div><span class='notification n-error'>Failed to modify record? Please try again.</span></div>";}
        ####
        my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
        my $myquery = $dbconn->prepare( "SELECT group_name FROM group_details;");
        #execute the query
        $myquery->execute();
	print "<p>";
		print "<label>Select Group</label>";
		print "<select name='grp_name' id='grp_name' class='input-short' onchange='javascript:get_group_list(this.value)'>";
			print "<option value=''>Select Group</option>";
                        while ( my @row = $myquery->fetchrow_array())
                        { print "<option value='".$row[0]."'>".$row[0]."</option>";}
                        if ($myreturn eq "errno1" ) { print "<span class='notification-input ni-error'>Group name required!</span>";}
		print "</select>";
	print "</p>";
	$myquery->finish;
	$dbconn->disconnect;
	##########

	print "<p>";
		print "<label>File Name </label>";
		print "<span id='cmb_file_list'><select name='file_path' id='file_path' class='input-long' onchange='javascript:get_fileinfo(this.value)'></select></span>";
		if ($myreturn eq "errno2" ) { print "<span class='notification-input ni-error'>File Name(full path) required!.</span>";}
	print "</p>";

	print "<p><label>Username</label><input class='input-short' type='text' name='user_name' id='user_name'></p>";
        print "<p><label>Group Name </label><input name='grp_owner' id='grp_owner' type='text' class='input-short' /></p>";
	print "<p><label>Permission</label><input name='permission' id='permission' type='text' class='input-short' /></p>";
        print "<p><label>Resvision No</label> <input class='input-short' type='text' value='$rev_no' name='rev_no' id='rev_no'></p>";
	print "<p><label>Action</label><select name='action' class='input-short' id='action'>";
			print "<option selected='selected' value='0'>Select Action</option>";
			print "<option value='1'>Apache</option>";
			print "<option value='2'>Mysql</option>";
			print "<option value='3'>Sendmail</option>";
			print "<option value='4'>Haproxy</option>";
			print "<option value='5'>Network</option>";
			print "<option value='6'>Haproxy</option>";
			print "<option value='7'>Syslog</option>";
	print "</select></p>";
	print "<p><label>Status</label><select name='status' id='status' class='input-small'>";
			print "<option selected='selected' value='Enabled'>Enabled</option>";
			print "<option value='Disabled'>Disabled</option>";
	print "</select></p>";

print <<"ADD_FILES";
	<fieldset>
		<input class="submit-green" value="Submit" type="submit" name='submit_files'> 
	</fieldset>                 
</form>
</div>
</div></div>
<!-- Add File Details Div End -->
ADD_FILES

}

#done
1;
