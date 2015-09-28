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
use UserAdmin;
use Centconf;
use Centconfig;
use DBI;
use DBD::mysql;
#use File::stat;

###### DB connection details ##############
#connection details
my $hash_ref=Centconfig::config_parse;
my $db=${$hash_ref}{database};
my $host=${$hash_ref}{db_host};
my $user=${$hash_ref}{db_user};
my $password=${$hash_ref}{db_password};
my $domain_name=${$hash_ref}{domain};

### Header
########################
my $page = CGI->new();
##### check authentication 
my $login_name=Login::is_authen($page);
our $client_ip = $ENV{'REMOTE_ADDR'};
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
#-- Categories list --
print "<div class='grid_9'>";
###########################################

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

####
sub useradmin_body 
{
  my ($status, $choice, $h, $d, $u, $pwd)=(@_); my $what_modified="9b09-f9a3336c2ded";
  ## to findout who is modified - user/dept
  ($choice,$what_modified)=split('#',$choice) if ($choice=~m/modify#(user|dept)/);
  if($choice eq "user") { UserAdmin::user_admin($status,$h, $d, $u, $pwd);
  }elsif ($choice eq "dept") { UserAdmin::add_department($status,$h, $d, $u, $pwd);
  }else{
	 ## check success status and type=modify
	 my($user_status,$dept_status) = ("unknown","unknown");
	 if ($what_modified eq "user") { $user_status=$status;} 
	 elsif ($what_modified eq "dept") {$dept_status=$status;}
	 UserAdmin::print_user_details($user_status,$h,$d,$u,$pwd);
	 UserAdmin::print_department_details($dept_status,$h,$d,$u,$pwd);
  }
	Centconf::side_panel($h, $d, $u, $pwd);
	Centconf::user_profile($client_ip,$login_name);
}
##########################
if ($ENV{REQUEST_METHOD} eq "GET")
{
   my %GET;
   $GET{type}="213f1180-fda8-4d79";
   my $query = $ENV{'QUERY_STRING'};
   my @pairs = split(/&/, $query);
   foreach my $pair (@pairs)
   {
        (my $name,my $value) = split(/=/, $pair);
        $value =~ tr/+/ /;
        $value =~ s/%(..)/pack("C", hex($1))/eg;
        $GET{$name} = $value;
   }
   ###############
   ## call func-useradmin_body
   if (($GET{type} eq "modify") && (($GET{user_id} ne "") or ($GET{dept_name} ne "")))
   {
	my $myreturn="unknown";
	if($GET{status}){ $myreturn=$GET{status};}
        if($GET{user_id}) { UserAdmin::modify_user($myreturn,$GET{user_id},$host, $db, $user, $password);}
        if($GET{dept_name}) { UserAdmin::modify_dept($myreturn,$GET{dept_name},$host, $db, $user, $password);}
        Centconf::side_panel($host, $db, $user, $password);Centconf::user_profile($client_ip,$login_name);
   } else { useradmin_body("unknown",$GET{type},$host,$db,$user,$password);}
   ###############
}
###
if ( $ENV{REQUEST_METHOD} eq "POST" )
{
   my %GET;
   my $query = $ENV{'QUERY_STRING'};
   my @pairs = split(/&/, $query);
   foreach my $pair (@pairs)
   {
        (my $name,my $value) = split(/=/, $pair);
        $value =~ tr/+/ /;
        $value =~ s/%(..)/pack("C", hex($1))/eg;
        $GET{$name} = $value;
   }
    ####
    my %form; my @multi_choice;
    foreach my $key (param()) {
	$form{$key} = trim(param($key)); 
        ## print "$key = $form{$key}<br>\n"; ##
    }
    ####
    my $insert_or_not="goahead"; my $passme="input_value_missing";
    if (($GET{type} eq "user") && ($form{user_id} eq "")) {$insert_or_not="stophere";}
    if (($GET{type} eq "dept") && ($form{dept_name} eq "")) {$insert_or_not="stophere";}
    if (($GET{type} eq "modify") && ($form{dept_name} eq "") && ($form{user_id} eq "")) {$insert_or_not="stophere";}
    #### validate email_id / $form{user_id}
    if ($form{user_id}){
     if ($form{user_id} =~ /^.*@(.*)$/){
	if ($1 ne $domain_name) {$insert_or_not="stophere";}
        if ($form{user_id} !~ /^(\w|\-|\_|\.)+\@((\w|\-|\_)+\.)+[a-zA-Z]{2,}$/) {$insert_or_not="stophere";}
     } else {$insert_or_not="stophere";}}
    ####
    if ($form{submit} eq "Submit") {
    if ($insert_or_not ne "stophere")
    {
	my $dbconn   = DBI->connect ("DBI:mysql:database=$db:host=$host",$user,$password) or die "Can't connect to database: $DBI::errstr\n";
	my $myquery = $dbconn->prepare("SELET * FROM mytable3345");
   	if ($GET{type} eq "user"){ $form{user_id}=~y/A-Z/a-z/; 
	$myquery = $dbconn->prepare( "INSERT INTO users VALUES ('$form{user_id}','$form{user_name}',MD5('$form{password}'),'$form{dept_name}','$form{user_status}');"); }
   	elsif ( $GET{type} eq "dept"){ $form{dept_name}=~y/A-Z/a-z/;
	$myquery = $dbconn->prepare( "INSERT INTO user_department VALUES ('$form{dept_name}','$form{dept_desc}','$form{dept_status}');");}
####################### * Modify * ########################
if ($GET{change} eq "dept"){ $GET{type}="modify#dept";
 $myquery=$dbconn->prepare("UPDATE user_department SET dept_desc='$form{dept_desc}',status='$form{dept_status}' WHERE dept_name='$form{dept_name}';");}
elsif ($GET{change} eq "user"){ $GET{type}="modify#user"; 
  if ($form{password} eq "") { $myquery=$dbconn->prepare("UPDATE users SET name='$form{user_name}',status='$form{user_status}',dept_name='$form{dept_name}' WHERE user_id='$form{user_id}';");
  } else { $myquery=$dbconn->prepare("UPDATE users SET name='$form{user_name}',status='$form{user_status}',dept_name='$form{dept_name}',password=MD5('$form{password}') WHERE user_id='$form{user_id}';");}
}
###########################################################
	#execute the query
	my $qry_status=$myquery->execute();
	if ($qry_status) { useradmin_body("successful",$GET{type},$host,$db,$user,$password);;}
  	else { useradmin_body("failed",$GET{type},$host,$db,$user,$password); }
	# close mysql connection
	$myquery->finish;
	$dbconn->disconnect;
    } else { useradmin_body($passme,$GET{type},$host,$db,$user,$password); }
    } else { useradmin_body("Cancel",$GET{type},$host,$db,$user,$password); }

} ## if POST
###########################################

print "<div style='clear: both;'></div>";
print "</div>"; 
#-- Categories list / grid_8 end --

#################################################################
print "</div> <div style='clear: both;'></div>";
#
# Footer
Admin::print_footer();
print $page->end_html; 
#DONE

