#!/usr/bin/perl

sub BEGIN
{
        unshift (@INC, '/home/centconf/module/');
}

use strict;
use warnings;
use DBI;
use DBD::mysql;
use Login;
use CGI qw(:standard);
use CGI::Session;
use SVN::Client;
use Centconfig;
use File::Basename;
use File::Util;

######################
my $page = CGI->new();
print $page->header();
##### check authentication 
 my $sid = $page->cookie("WORLD_SID") || undef;
 my $session = CGI::Session->load(undef,$sid);
 if ( $session->is_expired ) { print $page->redirect(-location => 'index.pl');}
 elsif ( $session->is_empty) { print $page->redirect(-location => 'index.pl');}
 my $login_name=$session->param('login_user');
 #my $login_name=Login::is_authen($page);
###########################

## DB connection details
## connection details
my $hash_ref=Centconfig::config_parse;
my $db=${$hash_ref}{database};
my $host=${$hash_ref}{db_host};
my $user=${$hash_ref}{db_user};
my $password=${$hash_ref}{db_password};
our $SVN_SERVER=${$hash_ref}{svn_server_url};
our $svn_user=${$hash_ref}{svn_user};
our $svn_password=${$hash_ref}{svn_password};
our $wc_path=${$hash_ref}{working_copy};

our ($svn_error_status,$svn_error_msg) = ("no","no_error");

my $SVN_LOG = "<span id='revision_number'><fieldset><label>Revision Number</label><select name='revision_number' class='input-short' onchange='javascript:revision_number_svn(this.value)'><option value='HEAD'>HEAD</option>";

## trim func to remove 
#white space
sub trim($)
{
        my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
}

############### svn function start ######################
sub svn_error_msg 
{
        my $svn_error_t = $_[0];
        if (SVN::Error::is_error($svn_error_t)) { $svn_error_status="yes"; } else { $svn_error_status="no"; }
        $svn_error_msg="SVNErr:". $svn_error_t -> message();
        ## Free the memory used by $svn_error_t
        SVN::Error::clear($svn_error_t);
}
#################
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
	my $str = "";
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
	    $str = join('',@lines);
	    return($str);
	    ## delete file
	    unlink("/tmp/arun-$$.txt");
	}else { $str = "".$svn_error_msg; return($str);}
}
######
sub create_dir_in_svn_repo
{
    my ($group_name,$dir_path) = (@_);
    my @path_array=split('/',"$dir_path");
    $SVN::Error::handler = \&svn_error_msg;
        my $client = new SVN::Client(
              auth => [SVN::Client::get_simple_provider(),
              SVN::Client::get_simple_prompt_provider(\&simple_prompt,2),
              SVN::Client::get_username_provider()]
              );
    #####################
    ##print "<br/>Creating directory in svn...";
    my $grp_path = $SVN_SERVER."/".$group_name;
    ##print "<br/>Creating group dir => $grp_path";
    ##print "<br/>SVNErr-$svn_error_status";
    $client->ls($grp_path,'HEAD',1,);
    ##print "<br/>SVNErr-$svn_error_status";
    if ($svn_error_status eq "yes") { $client->mkdir($grp_path,); print "<br/>Creating dir - $grp_path  ...[done]";}
    ($svn_error_status,$svn_error_msg) = ("no","no_error");
    ##print "<br/>SVNErr-$svn_error_status";
    #####################
    my $previous_dir="";
    foreach my $pair (@path_array)
    {
     if($pair ne "")
     {
    	$previous_dir=$previous_dir."/".$pair;
	my $svn_path = $SVN_SERVER."/".$group_name.$previous_dir;
	##print "<br/>Creating dir => $svn_path";
    	$client->ls($svn_path,'HEAD',1,);
    	if ($svn_error_status eq "yes") { $client->mkdir($svn_path,); print "<br/>Creating dir - $svn_path  ...[done]";}
	($svn_error_status,$svn_error_msg) = ("no","no_error");	
     } # if-end
    }
    ######### update working copy############
    ($svn_error_status,$svn_error_msg) = ("no","no_error");
    $client->update($wc_path,'HEAD',1,);
    if ($svn_error_status eq "yes") { print "<br/>Working copy update  ...[fail]";} else { print "<br/>Working copy update ...[done]";}
    #####################
    ($svn_error_status,$svn_error_msg) = ("no","no_error"); ## reset errors
    ##return ("@path_array"); 
}
###################
sub simple_prompt {
      (my $cred, my $realm, my $default_username, my $may_save, my $pool ) = (@_);
      $cred->username($svn_user); $cred->password($svn_password);
}
######
## Gets called once for each $messege in history
sub log_receiver {
   my ($changed_paths, $revision, $author, $date, $message, $pool) = @_;
   ($date,my $mydate) = split('\.', $date);
   $date =~ tr/T/ /;
   $SVN_LOG = "$SVN_LOG"." <option value=\"$revision\"> $revision - $author - $date - $message"."</option>";
}

############### svn function end ######################

#####################################
if ( $ENV{REQUEST_METHOD} eq "POST" )
{
   my %form; my $output=undef; my $svn_url;
   foreach my $key (param()) { $form{$key} = trim(param($key));}
    
   ####### print output #######
   #print "<br/>svn_num=>$form{svn_num}";
   $svn_url=$SVN_SERVER."/".$form{groupid}."".$form{fileid};
   ###### call func to create dir in svn repo ######
   my $dir_path = dirname("$form{fileid}");
   if ($dir_path) { &create_dir_in_svn_repo("$form{groupid}","$dir_path");}
   ($svn_error_status,$svn_error_msg) = ("no","no_error");
   ############ end ############ 
   if($form{svn_num})
   {
   	if($form{fileid}){ $output=get_from_svn("$svn_url","$form{svn_num}");}
   	print "<div id='file_revision_number'><span class='notification n-attention'>SVN URL - $svn_url <br/> Rev. No -'$form{svn_num}' </span></div>"."{-!-}"."$output"."{-!-}"."$SVN_LOG"."</select></fieldset></span>";
   }
   else 
   {
   	if($form{fileid}){ $output=get_from_svn("$svn_url","HEAD");}
   	print "<div id='file_revision_number'><span class='notification n-attention'>SVN URL - $svn_url <br/> Rev. No -'HEAD' </span></div>"."{-!-}"."$output"."{-!-}"."$SVN_LOG"."</select></fieldset></span>";
   }
}
#####################################
exit;
