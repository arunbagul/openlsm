package CentconfOps;

### Group details
sub add_group
{
print <<"GROUP_DETAILS-1";
<!-- Add Group Div start -->
<div class="module">
<h2><span>Add Group</span></h2>
<div class="module-body">
<form action="centconf.pl?type=group" method="POST">
GROUP_DETAILS-1

        ####
	(my $status, my $host, my $db, my $user, my $password) = (@_);
        if ($status eq "successful")
        { print "<div><span class='notification n-success'>Record successfully added!</span></div>";}
        elsif ($status eq "failed") { print "<div><span class='notification n-error'>Failed to add record? Please try again.</span></div>";}
        ####
	print "<p>";
		print "<label>Group Name </label>";
		print "<input class='input-short' type='text' name=grp_name>";
		if ($status eq "input_value_missing" ) { print "<span class='notification-input ni-error'>Group Name required!.</span>";}
	print "</p>";
print <<"GROUP_DETAILS-2";
	<p>
		<label>Group Description</label>
		<input class="input-medium" type="text" name=grp_desc>
		<!-- span class="notification-input ni-correct">This is correct, thanks!</span -->
		<!-- span class="notification-input ni-error">Sorry, try again.</span -->
	</p>
GROUP_DETAILS-2

	 ####################### Dept start #########################
         my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
         my $myquery = $dbconn->prepare( "SELECT dept_name,dept_desc FROM user_department WHERE status='Enabled';");
         #execute the query
         $myquery->execute();
         print "<p>";
                print "<label>Department</label>";
                print "<select class='input-short' name='grp_dept'>";
                        while ( my @row = $myquery->fetchrow_array())
                        { print "<option value='".$row[0]."'>".$row[1]."</option>";}
                print "</select>";
        	print "</p>";
         $myquery->finish;
         $dbconn->disconnect;
	####################### Dept end ############################

print <<"GROUP_DETAILS";
	<p>
		<label>Status</label>
		<select class="input-small" name=grp_status>
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
<!-- Group Details Div end -->
GROUP_DETAILS
}

### Host Details
sub add_host
{

print <<"HOST_DETAILS-1";
<!-- Add Host Div start -->
<div class="module">
<h2><span>Add Host</span></h2>
<div class="module-body">

<form action="centconf.pl?type=host" method="POST">
HOST_DETAILS-1

	####
	(my $status, my $host, my $db, my $user, my $password) = (@_);
	if ($status eq "successful") 
	{ print "<div><span class='notification n-success'>Record successfully added!</span></div>";}
	elsif ($status eq "failed") { print "<div><span class='notification n-error'>Failed to add record? Please try again.</span></div>";}
	####
	print "<p>";
		print "<label>Host Name</label>";
		print "<input class='input-short' type='text' name='host_name'>";
		if ($status eq "input_value_missing" ) { print "<span class='notification-input ni-error'>Host Name required!.</span>";}
	print "</p>";

print <<"HOST_DETAILS-2";
	<p>
		<label>IP Address</label>
		<input class="input-short" type="text" name=ip_addr>
		<!-- span class="notification-input ni-correct">This is correct, thanks!</span -->
	</p>

        <p>
                <label>Host Description</label>
                <input class="input-medium" type="text" name='description'>
                <!-- span class="notification-input ni-error">Sorry, try again.</span -->
        </p>
                            
	<p>
		<label>Primary Group</label>
		<input class="input-medium" type="text" name=primary_grp>
		<!-- span class="notification-input ni-error">Sorry, try again.</span -->
	</p>
HOST_DETAILS-2

	##########
	my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
	my $myquery = $dbconn->prepare( "SELECT group_name FROM group_details;");
	#execute the query
	$myquery->execute();
	print "<p>";
		print "<label>Secondary Group List (max 5 )</label>";
		print "<select class='input-short' name='secondary_group_list' multiple='multiple'>";
			#print "<option selected='selected' value=''>Select Groups</option>";
			while ( my @row = $myquery->fetchrow_array())
			{ print "<option value='".$row[0]."'>".$row[0]."</option>";}
		print "</select>";
		if ($status eq "more_than_five" ) { print "<span class='notification-input ni-error'>Sorry, try again.</span>";}
	print "</p>";
	$myquery->finish;
	$dbconn->disconnect;
	##########

print <<"HOST_DETAILS";
        <p>
		<label>Host Status</label>
		<select name="host_status" class="input-small">
			<option selected="selected" value="up">UP</option>
                        <option value="down">Down</option>
                        <option value="ofr">Out of Rotation</option>
                </select>
        </p>
        <p>
                <label>Host Category</label>
                <select name="host_category" class="input-small">
                        <option selected="selected" value="Production">Production</option>
                        <option value="QA">QA</option>
                        <option value="Testing">Testing</option>
                </select>
        </p>
        <p>
                <label>Centconf Status</label>
                <select name="centconf_status" class="input-small">
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
<!-- Host Details Div End -->
HOST_DETAILS
}

### Files Details
sub edit_file
{

print <<"EDIT_FILE-1";
<!-- Add Files Div start -->
<div class="module">
<h2><span>Centconf Repository</span></h2>
<div class="module-body">
<form action="centconf.pl?type=editor" method="POST">
EDIT_FILE-1

        ##########
	(my $status, my $host, my $db, my $user, my $password) = (@_);
        my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
        my $myquery = $dbconn->prepare( "SELECT group_name FROM group_details;");
        #execute the query
        $myquery->execute();
	print "<p>";
		print "<label>Select Group</label>";
		print "<select name='grp_name' id='grp_name' class='input-short' onchange='javascript:get_file_list(this.value)'>";
			print "<option value=''>Select Group</option>";
			while ( my @row = $myquery->fetchrow_array())
		 	{ print "<option value='".$row[0]."'>".$row[0]."</option>";}
			if ($status eq "more_than_five" ) { print "<span class='notification-input ni-error'>Sorry, try again.</span>";}
		print "</select>";
	print "</p>";
	$myquery->finish;
	$dbconn->disconnect;
	##########

print <<"EDIT_FILE";
	<p>
		<label>Select File</label>
		<span id='cmb_file_list'><select name="file_path" id='file_path' class="input-long"></select></span>
		<span id='revision_number' style='display:none;'><fieldset><label>Revision Number</label><select name='revision_number' class='input-short' onchange='javascript:get_fileinfo(this.value)'><option value='HEAD'>HEAD</option></select></fieldset></span>
		<div id='file_revision_number' style='display:none;'><span class='notification n-attention'>http://svn.server/group/file_name</span></div>
	</p>
	<fieldset>
		<label>Centconf File Editor (cvs/svn)</label>
		<textarea style="display:;" id="wysiwyg_svn" rows="30" cols="100" name="file_data"></textarea> 
	</fieldset>
	<fieldset>
		<!-- <input class="submit-green" value="Save" type="submit" name='submit'> -->
		<input class="submit-gray" value="Cancel" type="submit" name='cancel'>
		<a href="centconf.pl?type=files" style="text-decoration:none"><input type="image" class="submit-green" value="Add Files" /></a>
		<a href="centconf.pl?type=modify&files=select" style="text-decoration:none"><input type="image" class="submit-green" value="Modify Files" /></a>
	</fieldset>    
							             
</form>

</div>
</div></div>
<!-- Add File Details Div End -->
EDIT_FILE

}

### Files Details
sub add_files
{

print <<"ADD_FILES-1";
<!-- Add Files Div start -->
<div class="module">
<h2><span>Add Files</span></h2>
<div class="module-body">
<form action="centconf.pl?type=files" method="POST">
ADD_FILES-1

        ##########
        (my $status, my $host, my $db, my $user, my $password) = (@_);
        if ($status eq "successful")
        { print "<div><span class='notification n-success'>Record successfully added!</span></div>";}
        elsif ($status eq "failed") { print "<div><span class='notification n-error'>Failed to add record? Please try again.</span></div>";}
        ####
        my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
        my $myquery = $dbconn->prepare( "SELECT group_name FROM group_details;");
        #execute the query
        $myquery->execute();
	print "<p>";
		print "<label>Select Group</label>";
		print "<select name='grp_name' class='input-short'>";
                        while ( my @row = $myquery->fetchrow_array())
                        { print "<option value='".$row[0]."'>".$row[0]."</option>";}
                        if ($status eq "group_name_required" ) { print "<span class='notification-input ni-error'>Group name required!</span>";}
		print "</select>";
	print "</p>";
	$myquery->finish;
	$dbconn->disconnect;
	##########

	print "<p>";
		print "<label>File Path </label>";
		print "<input class='input-long' type='text' name='file_path'>";
		if ($status eq "file_name_required" ) { print "<span class='notification-input ni-error'>File Path required!.</span>";}
	print "</p>";

print <<"ADD_FILES";
	<p>
		<label>Username</label>
		<input class="input-short" type="text" name=user_name>
		<!-- span class="notification-input ni-error">Sorry, try again.</span -->
		</p>
        <p>
		<label>Group Name </label>
		<input name="grp_owner" type="text" class="input-short" />
        </p>
	<p>
		<label>Permission</label>
		<input name="permission" type="text" class="input-short" />
	</p>
	<p>
		<label>Action</label>
			<select name="action" class="input-short">
			<option selected="selected" value="0">Select Action</option>
			<option value="1">Apache</option>
			<option value="2">Mysql</option>
			<option value="3">Sendmail</option>
			<option value="4">Haproxy</option>
			<option value="5">Network</option>
			<option value="6">Haproxy</option>
			<option value="7">Syslog</option>
		</select>
	</p>
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
<!-- Add File Details Div End -->
ADD_FILES

}

#done
1;
