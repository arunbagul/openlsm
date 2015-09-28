#!/usr/bin/perl

sub BEGIN
{
        unshift (@INC, '/home/centconf/module/');
        unshift (@INC, '/usr/lib/perl5/');
}

use strict;
use warnings;
use GraphViz;
use Admin;
use Centconfig;
use DBI;
use DBD::mysql;
use SVN::Client;
use CGI qw(:standard);
use CGI::Session;
use Login;
use File::Basename;
use File::Util;
use SVN::Client;


###### DB connection details ##############
#connection details
my $hash_ref=Centconfig::config_parse;
my $db=${$hash_ref}{database};
my $host=${$hash_ref}{db_host};
my $user=${$hash_ref}{db_user};
my $password=${$hash_ref}{db_password};
my $SVN_SERVER=${$hash_ref}{svn_server_url};
my $svn_user=${$hash_ref}{svn_user};
my $svn_password=${$hash_ref}{svn_password};
our $wc_path=${$hash_ref}{working_copy};

our ($svn_error_status,$svn_error_msg) = ("no","no_error");
our $log_message = "CommitLog: ";

## trim func to remove 
#white space
sub trim($)
{
        my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
}

### Header
########################
my $page = CGI->new( );
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
print "<div class='container_12'>";
#########################################################

############### svn function start ######################
sub svn_error_msg 
{
        my $svn_error_t = $_[0];
        if (SVN::Error::is_error($svn_error_t)) { $svn_error_status="yes"; } else { $svn_error_status="no"; }
        $svn_error_msg="SVNErr:". $svn_error_t -> message();
        ## Free the memory used by $svn_error_t
        SVN::Error::clear($svn_error_t);
}
##############
sub commit_msg {
    my $stringptr = shift;
    $$stringptr = $log_message;
    return 1;
}
#############
sub get_from_svn 
{
        my ($svn_url,$svn_number)=@_;
        $SVN::Error::handler = \&svn_error_msg;
        my $client = new SVN::Client(
              auth => [SVN::Client::get_simple_provider(),
              SVN::Client::get_simple_prompt_provider(\&simple_prompt,2),
              SVN::Client::get_username_provider()]
              );
        ################## check if url exist or not ##################
        ## remove '/' from end of the svn url
        $svn_url =~ s/\/$//;
        $client->log(["$svn_url"],'HEAD',0,0,0,\&log_receiver);
        ################## check if url exist - end  ##################
        if ($svn_error_status eq "no")
        {
            open (MYFILE, ">/tmp/arun-$$.txt") or die $!;
            $client->cat (\*MYFILE, "$svn_url","$svn_number");
            ## close the file
            close (MYFILE);
            ## open file and store file in array ##
            open (MYFILE, "/tmp/arun-$$.txt") or die $!;
            my @lines = <MYFILE>;
            close (MYFILE);
            return(\@lines);
            ## delete file
            unlink("/tmp/arun-$$.txt");
        }else { my @lines ="".$svn_error_msg; return(\@lines);}
}
######
sub simple_prompt {
      (my $cred, my $realm, my $default_username, my $may_save, my $pool ) = (@_);
      $cred->username($svn_user); $cred->password($svn_password);
}
############### svn function end ######################

if ($ENV{REQUEST_METHOD} eq "POST")
{
   my %form;
   foreach my $key (param()) { 
	$form{$key} = trim(param($key));
   	##print "$key = $form{$key}<br>\n"; 
   }
   ############# commit file ###################
    my $base_commit_dir=$wc_path."/".$form{grp_name}."".dirname("$form{file_path}");
    my $file_name = $wc_path."/".$form{grp_name}."".$form{file_path};
    print "<br/>Base dir  - '$base_commit_dir'....";
    if (($form{submit} eq "Save") && ( -d "$base_commit_dir"))
    {
	print "<br/>Base dir exist - '$base_commit_dir'....";
 	print "<br/><font color='green'><b>Commit operation started....</b></font>";
	######################
	open (MYFILE, "+>$file_name") or "<br/><font color='red'>Can't create file '$file_name'".$!."</font>";
	if ( -f $file_name)
	{
	  $form{file_data} =~ s///g;
	  print MYFILE $form{file_data}."\n";
	  close (MYFILE);
	  print "<br/><font color='green'>Data written to file - '$file_name'</font>";
	  ######## Schedule file for commit ########
	  my $recursive = 0; ## non-recursive
	  $SVN::Error::handler = \&svn_error_msg;
           my $client = new SVN::Client(
		auth => [SVN::Client::get_simple_provider(),
                SVN::Client::get_simple_prompt_provider(\&simple_prompt,2),
                SVN::Client::get_username_provider()]
               );
	   #### check if we need to schedule
	   my $svn_path=$SVN_SERVER."/".$form{grp_name}."".$form{file_path};
	   print "<br/>Is in svn? - $svn_path";
	   ###
	   $client->ls($svn_path,'HEAD',1,);
	   if ($svn_error_status eq "yes") {
	   	print "<br/>Need to Schedule"; 
	   	($svn_error_status,$svn_error_msg) = ("no","no_error");
	   	$client->add($file_name, $recursive,);
	     	if ($svn_error_status eq "no") {print "<br/><font color='green'><b>'$file_name' - schedule for Commit.</b></font>";} 
	   	else { print "<br/><font color='red'><b>'$file_name' - schedule for Commit Failed- $svn_error_msg </b></font>";}
	   }
	   else { print "<br/>No need to Schedule";}  
	   ######## Commit now ########
	   ($svn_error_status,$svn_error_msg) = ("no","no_error");
	   $log_message = $log_message." ".$form{commit_msg};
	   print "<br/>Now commiting the file to svn...";
	   $client->log_msg(\&commit_msg);
	   $client->commit($file_name, 1); ## 1 for non-recursive
	   if ($svn_error_status eq "no") {print "<br/><font color='green'><b>'$file_name' - Committed successfully!</b></font>";}
	   else { print "<br/><font color='red'><b>'$file_name' - Commit Failed- $svn_error_msg </b></font>"; }
	  #### Schedule and Commit end ########
	}else { print "<br/><font color='red'><b>Commit operation failed - can't write to file.</b></font>"; close (MYFILE);}
	#####################	
    } else { print "<br/><font color='red'><b>Commit operation failed as basedir doesn't exist or illegal commit.</b></font>";}
   ############# commit file ###################
   print "<br/><br/>";
} 

################### Svn editor Div start ###################

######### logout ##########
print "<div class='float-right'>";
print "<a href='logout.pl' class='button'> <span>".$login_name." (logout) <img src='../images/user.gif' alt='' height='9' width='12'></span></a>";         
print "</div>";
####### logout end #######

print "<div class='module'>";
print "<h2><span>Centconf Repository</span></h2>";
print "<div class='module-body'>";
print "<form method='POST' action='svnweb.pl'>";
        ##########
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
                print "</select>";
        print "</p>";
        $myquery->finish;
        $dbconn->disconnect;
        ##########
        print "<p>";
		print "<label>Select File</label>";
                print "<span id='cmb_file_list'><select name='file_path' id='file_path' class='input-medium'></select></span>";
		print "<span id='revision_number' style='display:none;'><fieldset><label>Revision Number</label><select name='revision_number' class='input-short' onchange='javascript:revision_number_svn(this.value)'><option value='HEAD'>HEAD</option></select></fieldset></span>";
	print "<div id='file_revision_number' style='display:none;'><span class='notification n-attention'>http://svn.server/group/file_name</span></div>";
        print "</p>";
        print "<fieldset>";
		print "<label>Commit Message</label><input type='text' name='commit_msg' id='commit_msg' class='input-short'><br/><br/>";
                print "<label>Centconf File Editor (cvs/svn)</label>";
                print "<textarea style='display:;' id='wysiwyg_svn' rows='30' cols='140' name='file_data'></textarea>";
        print "</fieldset>";
        print "<fieldset>";
                print "<input class='submit-green' value='Save' type='submit' name='submit'>"; 
                print "<input class='submit-gray' value='Cancel' type='submit' name='cancel'>";
        print "</fieldset>";
print "</form>";
print "</div></div></div>";
################### Svn editor Div end

#################################################################
print "</div> <div style='clear: both;'></div>";
#
# Footer
Admin::print_footer();
print $page->end_html; 
#DONE

