package Admin;

### Header section
sub print_header 
{

print <<"EOF_Admin_Header-1";
<!-- Header start-->
<div id="header">

<!-- adding menu here -->
<div id="header-main">
<div class="container_12">
EOF_Admin_Header-1

	(my $page_is)=(@_);
        print "<div class='grid_12'><div id='logo'>";
        print "<ul id='nav'>";
	if( $page_is eq "Dashboard" ){ print "<li id='current'><a href='admin.pl'>Dashboard</a></li>";
	} else { print "<li><a href='admin.pl'>Dashboard</a></li>";}
	if( $page_is eq "Network" ){ print "<li id='current'><a href='network-view.pl'>Network View</a></li>";
	} else { print "<li><a href='network-view.pl'>Network View</a></li>";}
	if( $page_is eq "Business" ){ print "<li id='current'><a href='business-view.pl'>Business View</a></li>";
	} else { print "<li><a href='business-view.pl'>Business View</a></li>";}
	if( $page_is eq "DB" ){ print "<li id='current'><a href='db-view.pl'>DB View</a></li>";
	} else { print "<li><a href='db-view.pl'>DB View</a></li>"; }
	if( $page_is eq "Centconf" ){ print "<li id='current'><a href='centconf.pl'>Centconf</a></li>";
	} else { print "<li><a href='centconf.pl'>Centconf</a></li>";}
	if( $page_is eq "HAproxy" ){ print "<li id='current'><a href='haproxy.pl'>HAproxy</a></li>";
        } else { print "<li><a href='haproxy.pl'>HAproxy</a></li>";}
	if( $page_is eq "Myops" ){ print "<li id='current'><a href='myops.pl'>Myops Details</a></li>";
	} else { print "<li><a href='myops.pl'>Myops Details</a></li>";}
	if( $page_is eq "Doc" ){ print "<li id='current'><a href='documentation.pl'>Documentations</a></li>";
	} else { print "<li><a href='documentation.pl'>Documentations</a></li>";}
        print "</ul></div></div>";
	#-- Logo & grid_12 end --

print <<"EOF_Admin_Header";
	<div style="clear: both;"></div>
</div></div>
<!-- container_12 & header-main end -->
<div style="clear: both;"></div>
<!-- sub-menu here -->
<!-- sub-menu end -->
<br/>

</div>
<!--  header end -->

EOF_Admin_Header
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
        <div style="clear: both;"></div>

</div>
<!-- Footer end -->
EOF_FOOTER

}

### Loging body

sub print_loginbody
{

print <<"LOGIN_BODY"
<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++  -->
<div class="container_12">
<div class="prefix_3 grid_6 suffix_3">
        <div class="module">
        <h2><span>Log in</span></h2>
        <div class="module-body">
        <div class="notification n-success">Please log in to access the administration panel.</div>
                <!-- Form start -->
                <form method="POST" action="admin.pl" class="login">
                                <label>Login</label>
                                <input class="input-medium" type="password" />
                                <label>Password</label>
                                <input type="password" class="input-medium" />
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
