package Login;

### is_login
sub is_authen
{
	my ($page_ref) = (@_);
	############### Session information #############
	my $sid = $page_ref->cookie("WORLD_SID") || undef;
	my $session = CGI::Session->load(undef,$sid);
	if ( $session->is_expired ) { print $page_ref->redirect(-location => 'index.pl');} 
	elsif ( $session->is_empty) { print $page_ref->redirect(-location => 'index.pl');}
	else { print $page_ref->header();}
	#$session = new CGI::Session(undef, $sid, {Directory=>'/tmp'});
	#################################################
        return($session->param('login_user'));
}
### Header section
sub print_header 
{
print <<"EOF_Login_Header";

<div id="header"></div>
<!-- Header. Main part -->

<div id="header-main">
        <div class="container_12">
        <div class="grid_12">
                <div id="logo"></div>
        </div>
        </div>
                <div class="clear"></div>
</div> <!-- header-main end -->
</div> <!-- End #header -->

EOF_Login_Header
}

### Footer section
sub print_footer
{

print <<"EOF_FOOTER"
<!-- Footer -->
<div id="footer">
        <div class="container_12">
        <div class="grid_12">
                <!-- You can change the copyright line for your own -->
                <p>&copy; 2010 World Myops Admin panel.</p>
        </div>
        </div>
</div>
<!-- Footer  end  -->
EOF_FOOTER

}

### Loging body

sub print_loginbody
{
	my ($status) = (@_);

print <<"LOGIN_BODY-1";
<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++  -->
<div class="container_12">
<div class="prefix_3 grid_6 suffix_3">
        <div class="module">
        <h2><span>Log in</span></h2>
        <div class="module-body">
LOGIN_BODY-1

	if ($status eq "need_input") {
        	print "<div class='notification n-attention'>Please enter username/password to access the administration panel.</div>";
	}elsif ($status eq "logout") {print "<div class='notification n-attention'>Logout Successfully.</div>";}

print <<"LOGIN_BODY";
                <!-- Form start -->
                <form method="POST" action="is_login.pl" class="login">
                                <label>Login</label>
                                <input class="input-medium" type="text" name='username' />
                                <label>Password</label>
                                <input type="password" class="input-medium" name='password' />
                                <label><input type="checkbox" /> remember me</label>
                                                                <input class="submit-green" type="submit" value="Submit"/>
                </form>

                <ul>
                        <li><a href="#">I forgot my password</a></li>
                </ul>
        </div> <!-- module-body end -->
        </div> <!-- module end -->

</div> <!-- grid_6 end -->
<div class="clear"></div>
</div> <!-- container_12 end -->
<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++  -->
LOGIN_BODY

}

#done
1;
