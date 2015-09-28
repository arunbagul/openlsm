package UserAdmin;

### User details
sub user_admin
{
print <<"USER_DETAILS-1";
<!-- Add User Div start -->
<div class="module">
<h2><span>Add User</span></h2>
<div class="module-body">
<form action="user_admin.pl?type=user" method="POST">
USER_DETAILS-1

        ####
	(my $cmd_status, my $host, my $db, my $user, my $password) = (@_);
        if ($cmd_status eq "successful")
        { print "<div><span class='notification n-success'>Record successfully added!</span></div>";}
        elsif ($cmd_status eq "failed") { print "<div><span class='notification n-error'>Failed to add record? Please try again.</span></div>";}
        ####
	print "<p>";
		print "<label>User Id (Email Id)</label>";
		print "<input class='input-short' type='text' name='user_id'>";
		if ($cmd_status eq "input_value_missing" ) { print "<span class='notification-input ni-error'>User Id required!.</span>";}
	print "</p>";
print <<"USER_DETAILS-2";
	<p>
		<label>Password </label>
		<input class='input-medium' type='password' name='password'>
		<label>User Name </label>
		<input class='input-medium' type='text' name='user_name'>
		<!-- span class="notification-input ni-correct">This is correct, thanks!</span -->
		<!-- span class="notification-input ni-error">Sorry, try again.</span -->
	</p>
USER_DETAILS-2

	 ####################### Dept start #########################
         my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
         my $myquery = $dbconn->prepare( "SELECT dept_name,dept_desc FROM user_department WHERE status='Enabled';");
         #execute the query
         $myquery->execute();
         print "<p>";
                print "<label>Department Name</label>";
                print "<select class='input-short' name='dept_name'>";
                        while ( my @row = $myquery->fetchrow_array())
                        { print "<option value='".$row[0]."'>".$row[1]."</option>";}
                print "</select>";
        	print "</p>";
         $myquery->finish;
         $dbconn->disconnect;
	####################### Dept end ############################

print <<"USER_DETAILS";
	<p>
		<label>Status</label>
		<select class="input-small" name=user_status>
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
<!-- User Details Div end -->
USER_DETAILS
}

### Host Details
sub add_department
{

print <<"DEPT_DETAILS-1";
<!-- Add Dept Div start -->
<div class="module">
<h2><span>Add Department</span></h2>
<div class="module-body">

<form action="user_admin.pl?type=dept" method="POST">
DEPT_DETAILS-1

	####
	(my $cmd_status, my $host, my $db, my $user, my $password) = (@_);
	if ($cmd_status eq "successful") 
	{ print "<div><span class='notification n-success'>Record successfully added!</span></div>";}
	elsif ($cmd_status eq "failed") { print "<div><span class='notification n-error'>Failed to add record? Please try again.</span></div>";}
	####
	print "<p>";
		print "<label>Department Name</label>";
		print "<input class='input-short' type='text' name='dept_name'>";
		if ($cmd_status eq "input_value_missing" ) { print "<span class='notification-input ni-error'>Dept Name required!.</span>";}
	print "</p>";
	####

print <<"DEPT_DETAILS-2";
        <p>
                <label>Department Description</label>
                <input class="input-medium" type="text" name='dept_desc'>
                <!-- span class="notification-input ni-error">Sorry, try again.</span -->
        </p>
        
	<p>
                <label>Dept Status</label>
                <select name="dept_status" class="input-small">
                        <option selected="selected" value="Enabled">Enabled</option>
                        <option value="Disabled">Disabled</option>
                </select> <br/><br/>
        </p>
	<p>
		<fieldset>
			<input class="submit-green" value="Submit" type="submit" name='submit'> 
                 	<input class="submit-gray" value="Cancel" type="submit" name='cancel'>
		</fieldset>
	</p>
</form>
</div>
</div></div>
<!-- Dept Details Div End -->
DEPT_DETAILS-2
}

################################
### List User and Department ###
################################

### User details
sub print_user_details
{
print <<"LIST_USER-1";
<!-- list user Div start -->
<div class="module">
<h2><span>User Details</span></h2>
<div class="module-body">
        <table width="68%" class="tablesorter" id="myTable">                         
            <thead>
                <tr>
                        <th width="5%" class="header" style="width: 2%;">#</th>
                        <th width="30%" class="header" style="width: 30%;"><span class="header" style="width: 30%;">User_Id</span></th>
                        <th width="25%" class="header" style="width: 25%;"><span class="header" style="width: 25%;">User Name</span></th>
                        <th width="20%" class="header" style="width: 20%;"><span class="header" style="width: 20%;">Dept Name</span></th>
                        <th width="15%" class="header" style="width: 15%;">Status</th>
			<th width="10%" style="width: 10%;"></th>
                </tr>
            </thead>
LIST_USER-1
################################################
        (my $change,my $host,my $db,my $user, my $password) =(@_);
        ###
        if ($change eq "successful")
        { print "<div><span class='notification n-success'>Record successfully modified!</span></div>";}
        elsif ($change eq "failed") { print "<div><span class='notification n-error'>Failed to modify record? Please try again.</span></div>";}
        ####
        my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
        my $myquery = $dbconn->prepare( "SELECT user_id,name,dept_name,status FROM users;");
        #execute the query
        $myquery->execute();
        my $tr_counter="even"; my $row_counter=1;
        print "<tbody>";
        while ( my @row = $myquery->fetchrow_array() )
        {
                if ($tr_counter eq "even") { print "<tr class='even'>";$tr_counter="odd";}else { print "<tr class='odd'>";$tr_counter="even";}
                print "<td class='align-center'>".$row_counter."</td>";
                (my $user_id, my $name, my $dept_name,my $mystatus) = (@row);
                        print "<td>".$user_id."</td>";
                        print "<td>".$name."</td>";
                        print "<td>".$dept_name."</td>";
                        print "<td id='status_user_$user_id'>".$mystatus."</td>";
if ($mystatus eq "Disabled") {
print "<td><input type='hidden' id='hdn_user_$user_id' name='hdn_user_$user_id' value='enable'> <a href='#'><img id='img_user_$user_id' onclick=\"enable_disable('user','enable','$user_id')\" src='../images/tick-circle.gif' height='16' width='16' title='Status' /></a><a href='user_admin.pl?type=modify&user_id=".$user_id."'><img src='../images/pencil.gif' alt='edit' height='16' width='16' /></a></td>";}
else {
print "<td><input type='hidden' id='hdn_user_$user_id' name='hdn_user_$user_id' value='disable'> <a href='#'><img id='img_user_$user_id' onclick=\"enable_disable('user','disable','$user_id')\" src='../images/minus-circle.gif' height='16' width='16' title='Status' /></a><a href='user_admin.pl?type=modify&user_id=".$user_id."'><img src='../images/pencil.gif' alt='edit' height='16' width='16'/></a> </td>";
}
                print "</tr>";
                ## increment row counter
                $row_counter = $row_counter + 1;
        }
        $myquery->finish;
        $dbconn->disconnect;
        print "</tbody></table>";
################################################

print <<"LIST_USER";
<!-- form action="user_admin.pl" -->
<fieldset>
        <a href="user_admin.pl?type=user" style="text-decoration:none"><input type="image" class="submit-green" value="Add User" /></a>
</fieldset>

<!-- /form -->
</div>
</div> 
<!-- list user Div end -->
LIST_USER

}

### Deparment details
sub print_department_details
{

print <<"LIST_DEPT-1";
<!-- list dept Div start -->
<div class="module">
<h2><span>Deparment Details</span></h2>
<div class="module-body">
        <table width="68%" class="tablesorter" id="myTable">                         
            <thead>
                <tr>
                        <th width="5%" class="header" style="width: 2%;">#</th>
                        <th width="25%" class="header" style="width: 25%;"><span class="header" style="width: 25%;">Department Name </span></th>
                        <th width="50%" class="header" style="width: 50%;"><span class="header" style="width: 50%;">Department Description</span></th>
                        <th width="15%" class="header" style="width: 15%;">Status</th>
			<th width="10%" style="width: 10%;"></th>
                </tr>
            </thead>
LIST_DEPT-1
################################################
        (my $change,my $host,my $db,my $user, my $password) =(@_);
	###
        if ($change eq "successful")
        { print "<div><span class='notification n-success'>Record successfully modified!</span></div>";}
        elsif ($change eq "failed") { print "<div><span class='notification n-error'>Failed to modify record? Please try again.</span></div>";}
        ####
        my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
        my $myquery = $dbconn->prepare( "SELECT dept_name,dept_desc,status FROM user_department;");
        #execute the query
        $myquery->execute();
        my $tr_counter="even"; my $row_counter=1;
        print "<tbody>";
        while ( my @row = $myquery->fetchrow_array() )
        {
                if ($tr_counter eq "even") { print "<tr class='even'>";$tr_counter="odd";}else { print "<tr class='odd'>";$tr_counter="even";}
                print "<td class='align-center'>".$row_counter."</td>";
                (my $dept_name, my $dept_desc,my $mystatus) = (@row);
                        print "<td>".$dept_name."</td>";
                        print "<td>".$dept_desc."</td>";
                        print "<td id='status_dept_$dept_name'>".$mystatus."</td>";
if ($mystatus eq "Disabled") {
print "<td><input type='hidden' id='hdn_dept_$dept_name' name='hdn_dept_$dept_name' value='enable'> <a href='#'><img id='img_dept_$dept_name' onclick=\"enable_disable('dept','enable','$dept_name')\" src='../images/tick-circle.gif' height='16' width='16' title='Status' /></a><a href='user_admin.pl?type=modify&dept_name=".$dept_name."'><img src='../images/pencil.gif' alt='edit' height='16' width='16' /></a></td>";}
else {
print "<td><input type='hidden' id='hdn_dept_$dept_name' name='hdn_dept_$dept_name' value='disable'> <a href='#'><img id='img_dept_$dept_name' onclick=\"enable_disable('dept','disable','$dept_name')\" src='../images/minus-circle.gif' height='16' width='16' title='Status' /></a><a href='user_admin.pl?type=modify&dept_name=".$dept_name."'><img src='../images/pencil.gif' alt='edit' height='16' width='16'/></a> </td>";
}
                print "</tr>";
                ## increment row counter
                $row_counter = $row_counter + 1;
        }
        $myquery->finish;
        $dbconn->disconnect;
        print "</tbody></table>";
################################################

print <<"LIST_DEPT";
<!-- form action="user_admin.pl" -->
<fieldset>
        <a href="user_admin.pl?type=dept" style="text-decoration:none"><input type="image" class="submit-green" value="Add Department" /></a>
</fieldset>
<!-- /form -->
</div>
</div> 
<!-- arun - important for alignment -->
</div> 
<!-- list dept Div end -->
LIST_DEPT

}

############################################################################################

################################
### Modify User and Department ###
################################

### User details
sub modify_user
{
print <<"USER_MODIFY-1";
<!-- Modify User Div start -->
<div class="module">
<h2><span>Modify User</span></h2>
<div class="module-body">
<form action="user_admin.pl?type=modify&change=user" method="POST">
USER_MODIFY-1

        ####
	(my $cmd_status, my $user_id, my $host, my $db, my $user, my $password) = (@_);
        if ($cmd_status eq "successful")
        { print "<div><span class='notification n-success'>Record successfully modified!</span></div>";}
        elsif ($cmd_status eq "failed") { print "<div><span class='notification n-error'>Failed to modify record? Please try again.</span></div>";}
        ####
        my $dbconn = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
        my $count_qry = $dbconn->prepare( "SELECT count(*) FROM users WHERE user_id='$user_id';");
        #execute the query
        $count_qry->execute();
        my @row_count = $count_qry->fetchrow_array();
        if ( $row_count[0] == 0 ) { print "<span class='notification-input ni-error'>User doesn't exist!</span>"; die; }
        $count_qry->finish;
        ##
        my $myquery = $dbconn->prepare( "SELECT * FROM users WHERE user_id='$user_id';");
        #execute the query
        $myquery->execute();
        my @row = $myquery->fetchrow_array();
        (my $user_id,my $name,my $user_password, my $dept_name,my $status) = @row;
        $myquery->finish;
        $dbconn->disconnect;
	##
	print "<p>";
		print "<label>User Id (Email Id)</label>";
		print "<input class='input-short' type='text' value='$user_id' name='user_id' READONLY>";
		if ($cmd_status eq "input_value_missing" ) { print "<span class='notification-input ni-error'>User Id required!.</span>";}
	print "</p>";
print <<"USER_MODIFY-2";
	<p>
		<label>Password </label>
		<input class='input-medium' type='password' value='' name='password'>
		<label>User Name </label>
		<input class='input-medium' type='text'  value='$name' name='user_name'>
		<!-- span class="notification-input ni-correct">This is correct, thanks!</span -->
		<!-- span class="notification-input ni-error">Sorry, try again.</span -->
	</p>
USER_MODIFY-2

	 ####################### Dept start #########################
         my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
         my $myquery = $dbconn->prepare( "SELECT dept_name,dept_desc FROM user_department WHERE status='Enabled';");
         #execute the query
         $myquery->execute();
         print "<p>";
                print "<label>Department Name</label>";
                print "<select class='input-short' name='dept_name'>";
			print "<option selected='selected' value='$dept_name'>$dept_name</option>";
                        while ( my @row = $myquery->fetchrow_array())
                        { print "<option value='".$row[0]."'>".$row[1]."</option>";}
                print "</select>";
        	print "</p>";
         $myquery->finish;
         $dbconn->disconnect;
	####################### Dept end ############################

print <<"USER_MODIFY";
	<p>
		<label>Status</label>
		<select class="input-small" name='user_status'>
			print "<option selected='selected' value='$status'>$status</option>";
                	<option value="Enabled">Enabled</option>
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
<!-- Modify User Div end -->
USER_MODIFY
}

#######################
### User details
sub modify_dept
{
print <<"DEPT_MODIFY-1";
<!-- Modify Dept Div start -->
<div class="module">
<h2><span>Modify Department</span></h2>
<div class="module-body">
<form action="user_admin.pl?type=modify&change=dept" method="POST">
DEPT_MODIFY-1

        ####
	(my $cmd_status, my $dept_name, my $host, my $db, my $user, my $password) = (@_);
        if ($cmd_status eq "successful")
        { print "<div><span class='notification n-success'>Record successfully modified!</span></div>";}
        elsif ($cmd_status eq "failed") { print "<div><span class='notification n-error'>Failed to modify record? Please try again.</span></div>";}
        ####
        my $dbconn = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
        my $count_qry = $dbconn->prepare( "SELECT count(*) FROM user_department WHERE dept_name='$dept_name';");
        #execute the query
        $count_qry->execute();
        my @row_count = $count_qry->fetchrow_array();
        if ( $row_count[0] == 0 ) { print "<span class='notification-input ni-error'>Dept doesn't exist!</span>"; die; }
        $count_qry->finish;
        ##
        my $myquery = $dbconn->prepare( "SELECT * FROM user_department WHERE dept_name='$dept_name';");
        #execute the query
        $myquery->execute();
        my @row = $myquery->fetchrow_array();
        (my $dept_name, my $dept_desc, my $status) = @row;
        $myquery->finish;
        $dbconn->disconnect;
	##
	print "<p>";
		print "<label>Department Name</label>";
		print "<input class='input-short' type='text' value='$dept_name' name='dept_name' READONLY>";
		if ($cmd_status eq "input_value_missing" ) { print "<span class='notification-input ni-error'>Dept Name required!.</span>";}
	print "</p>";
print <<"DEPT_MODIFY";
	<p>
		<label>Department Description</label>
		<input class='input-medium' type='text'  value='$dept_desc' name='dept_desc'>
		<!-- span class="notification-input ni-correct">This is correct, thanks!</span -->
		<!-- span class="notification-input ni-error">Sorry, try again.</span -->
	</p>
	<p>
		<label>Dept Status</label>
		<select class="input-small" name='dept_status'>
			print "<option selected='selected' value='$status'>$status</option>";
                	<option value="Enabled">Enabled</option>
                        <option value="Disabled">Disabled</option>
                </select>
	</p><p><br/><br/></p>
	<p>
		<fieldset>
			<input class="submit-green" value="Submit" type="submit" name='submit'> 
                        <input class="submit-gray" value="Cancel" type="submit" name='cancel'>
		</fieldset>
	</p>

</form>                     
</div>
</div></div>
<!-- Modify Dept Div end -->
DEPT_MODIFY
}

############################################################################################

#done
1;
