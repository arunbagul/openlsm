#!/usr/bin/perl

## Author - Arun
## This is the client script for 'CentConf Server'
## Version = 1.0,r273
## Date 15th July 2010

use strict;
#use Sys::Hostname;
#use Data::Dumper;
use Getopt::Long;
use LWP::Simple;
use LWP::UserAgent;
use Log::Log4perl qw(:easy);
use XML::Parser;
use XML::Simple;
use SVN::Client;
use File::Basename;
use File::Util;
use File::Compare;
use File::Copy;
use Shell qw(chown,chmod,chgrp,ls);

our ($svn_error_status,$process_log) = ("no","<xml>");
chomp(my $myhost=`hostname`);

################################
my $total_argument = $#ARGV + 1 ;
if ( $total_argument == 0 ){
	print " * Usage: $0 [Options] --centconf <centconf server> --destination|-dest <destination server> \n"; exit 0;
}
################################
#my $repo_url="http://localhost/centconf_repo";
my $repo_url="http://10.0.4.215/centconf_repo";
## cmdline argument single value
my $cf_server = "";
my $destination_name = "";
my $result = "dontknow";
my $content_as_xml;
my $cachedir = "/var/cache/centconf.client/";
my $logfile="/var/log/centconf-${myhost}.log";

## cmdline option 
my ($help, $verbose, $enable, $disable, $run) = 0;

GetOptions ( 'help|h|info' => \$help, 'verbose|v|debug' => \$verbose,  'enable|on' => \$enable,'disable|off' => \$disable,  'centconf=s' => \$cf_server, 'destination=s' => \$destination_name, 'run' => \$run);

#######################################  function list #######################################
# Check Options and Argument supplied by user on command line
###########################
sub enable_disable_options
{
    ## take argument
    (my $enable, my $disable, my $cf_server,my $destination_name) = (@_);
    if ($enable == 1) {
        if (($disable == 1 ) or ($cf_server eq "") or ($destination_name ne ""))
        {return "Failed";} else { return "Enable"; }
    }       
    if ($disable == 1) {
        if (($enable == 1 ) or ($cf_server eq "") or ($destination_name ne ""))
        {return "Failed"} else { return "Disable"; }
    }
}
###
sub post_log {

   my ($myhostname, $centconf_server,$postme) = (@_);
   my $user_agent_log = new LWP::UserAgent;
   $user_agent_log->agent("centconf/$myhostname");
   $user_agent_log->timeout(30);
   my $logme = new HTTP::Request 'POST',"http://$centconf_server/cgi/centconf-log.pl";
   $logme->content_type('application/x-www-form-urlencoded');
   $logme->content($postme);
   $user_agent_log->request($logme);
}
###
sub simple_prompt {
      (my $cred, my $realm, my $default_username, my $may_save, my $pool ) = (@_);
      my $username = "centconf_client"; my $password = "CeN#123";
      $cred->username($username); $cred->password($password);
}
############ svn functions
sub svn_error_msg 
{
        my $svn_error_t = $_[0];
        if ($svn_error_t -> apr_err() == $SVN::Error::FS_NOT_FOUND) {
                ### print "SVN Error: File/Directory not found?\n";
                &display_svn_error($svn_error_t);
                ###SVN::Error::confess_on_error($svn_error_t);
        } else { &display_svn_error($svn_error_t); }
	## Free the memory used by $svn_error_t
	SVN::Error::clear($svn_error_t);
}
######
sub  display_svn_error()
{
        my $svn_error_t = $_[0];
	## logging initialization 
	my $logger = Log::Log4perl->get_logger();
        ###print "message: " . $svn_error_t -> message() . "\n";
        #print "apr_err: " . $svn_error_t -> apr_err() . "\n";
        if ($svn_error_t -> apr_err() == $SVN::Error::CLIENT_BAD_REVISION) 
	{ print "CLIENT_BAD_REVISION error\n"; }
        ###print "strerror: " . $svn_error_t -> strerror() . "\n";
        ##print "is_error: ";
        if (SVN::Error::is_error($svn_error_t)) { $svn_error_status="yes"; } else { $svn_error_status="no"; }
        $logger->warn("SVNErr: " . $svn_error_t -> expanded_message()." (ignore)");
	$process_log=$process_log."<svn_error>SVNErr: " . $svn_error_t -> expanded_message()."</svn_error>";
} # display_svn_error end

############ file diff

sub diff_or_replace
{
	my ($local_file,$svn_file,$rev_no,$run) = (@_);
	## logging initialization 
	my $logger = Log::Log4perl->get_logger();
	########### file comparision or replace ###########
	if (compare("$local_file","$svn_file") == 0) {
		$logger->warn("diff_or_replace [compare] - $local_file and svn_file,rev=$rev_no are same!");
		$process_log=$process_log."<diff>diff_or_replace [compare] - $local_file and svn_file,rev=$rev_no are same</diff>";
	} else {
	    if ($run == 1){
			## taking backup of local file before replacing it with svn_file,version
			if (copy("$local_file","${local_file}-centconf.bkup")== 1) {
			$logger->warn("diff_or_replace [local_backup] - $local_file backup is here ${local_file}-centconf.bkup");}
		if (copy("$svn_file","$local_file") == 1) {
			$logger->warn("diff_or_replace [replace] - $local_file with svn_file,rev=$rev_no Completed");
			$process_log=$process_log."<replace>diff_or_replace [replace] - $local_file with svn_file,rev=$rev_no Completed</replace>";
		} else {
			$logger->warn("diff_or_replace [replace] - $local_file with svn_file,rev=$rev_no Failed");
			$process_log=$process_log."<replace>diff_or_replace [replace] - $local_file with svn_file,rev=$rev_no Failed</replace>";
		}
	    } else {
		$logger->warn("diff_or_replace [compare] - $local_file and svn_file,rev=$rev_no are different!");
		$process_log=$process_log."<diff>diff_or_replace [compare] - $local_file and svn_file,rev=$rev_no are different</diff>";
	    }
	}
	###########
	# return value - match/fail/replace/email
	return("match");
}
####################################### function list end #####################################

###############################################
if ($help == 1) {
	print "\nUsage: $0 [Options] --centconf <centconf server> --destination|-dest <destination server> \n";
	print "\nOptions:\n";
	print "  --help|--info|-h\t: Help on all available commandline options\n  --verbose|--debug|-v\t: Verbose or debug mode";
	print "\n  --enable|--on\t\t: Enable Centconf client on localhost/server";
	print "\n  --disable|--off\t: Disable Centconf client on localhost/server";
	print "\n  --run\t\t\t: Run program without dry-run ie perform 'replace' operation\n";
	print "\nNote: By default program execute with dry-run mode.\n\n"; exit 0;
}
############ log4perl setting start ##########
if ( $verbose == 1)
{
Log::Log4perl->init(\<<"LOG4PERL");
      log4perl.category = DEBUG,MYLOG,Screen
      log4perl.appender.MYLOG = Log::Log4perl::Appender::File
      log4perl.appender.MYLOG.filename = /var/log/centconf-${myhost}.log
      log4perl.appender.MYLOG.mode = append
      log4perl.appender.MYLOG.layout = Log::Log4perl::Layout::PatternLayout
      log4perl.appender.MYLOG.layout.ConversionPattern = %d %p %F{1},%L [%P]: %m %n
      log4perl.appender.Screen = Log::Log4perl::Appender::Screen
      log4perl.appender.Screen.layout = Log::Log4perl::Layout::SimpleLayout
LOG4PERL
}else
{
Log::Log4perl->init(\<<"LOG4PERL");
      log4perl.category = DEBUG,MYLOG
      log4perl.appender.MYLOG = Log::Log4perl::Appender::File
      log4perl.appender.MYLOG.filename = /var/log/centconf-${myhost}.log
      log4perl.appender.MYLOG.mode = append
      log4perl.appender.MYLOG.layout = Log::Log4perl::Layout::PatternLayout
      log4perl.appender.MYLOG.layout.ConversionPattern = %d %p %F{1},%L [%P]: %m %n
LOG4PERL
}
############ log4perl setting end ###########
# Initialize log4perl here
my $logger = Log::Log4perl->get_logger();

###########################
if (($cf_server=~m/^-+?h.*|-i.*|-v.*|-d.*|-+?|^$/) or ($destination_name=~m/^-+?h.*|-i.*|-v.*|-d.*|-+?|^$/)){
	$result=enable_disable_options ($enable,$disable,$cf_server,$destination_name);
	if ($result=~m/Enable/){ 
		if ( -e "$cachedir/disable") { 
		     if (unlink("$cachedir/disable")){
			  $logger->info("'Centconf' is [Enabled] on localhost!.");
			  my $msg = "Centconf is [Enabled] on localhost";
			  $process_log=$process_log."<info>".join('',$msg)."</info>";
			  post_log($myhost,$cf_server,"host_name=$myhost&run_status=Unknown&log_msg=$msg&submit=CentconFLog");
		     }
		     else {$logger->fatal("Failed to [Enable] Centconf on localhost! - $!");
			  $process_log=$process_log."<fail>Failed to [Enable] Centconf on localhost! - $!</fail>";} 
		}
		else { $logger->warn("'Centconf' is already [Enabled] on localhost!.");}
	}
	elsif ($result=~m/Disable/){
		if ( -e "$cachedir/disable") {$logger->warn("'Centconf' is already [Disabled] on localhost!.");}
		else { open (myFILE, "+>", "$cachedir/disable") or $logger->fatal("Failed to [Disable] Centconf on localhost! - $!");
			printf myFILE "'Centconf' is [Disabled] on localhost - ".`date`;
			close(myFILE);	
			$logger->info("'Centconf' is [Disabled] on localhost!.");
			my $msg = "Centconf is [Disabled] on localhost";
			$process_log=$process_log."<info>".join('',$msg)."</info>";
			post_log($myhost,$cf_server,"host_name=$myhost&run_status=Failed&log_msg=$msg&submit=CentconFLog");
		}
	}
	else{ print " Invalid option or argument?\n"; exit 0;}
} 
else { 
	$result=enable_disable_options ($enable,$disable,$cf_server,$destination_name);				
	if ($result=~m/Failed/) 
	{ print " Invalid option or argument?\n"; exit 0;}
	else {	
		############ clean log ############
		if ( -f $logfile ){
    			my $filesize = -s $logfile;
			## truncate file if size is more than 5MB
			if ( $filesize >= 5242880) { open(TRUN_FILE,">$logfile");close(TRUN_FILE);}
		} 
		###################################
		$logger->info("Process started with options - $cf_server | $destination_name | --run is $run |");
		$process_log=$process_log."<info>Process started with options - $cf_server | $destination_name | --run is $run |</info>";
		if ( -e "$cachedir/disable") {$logger->info("Centconf is [status=Disabled] on localhost. Failed and EXIT");  
	    	   $process_log=$process_log."<fail>Centconf is [status=Disabled] on localhost. Failed and EXIT</fail>";exit 1;}
		## Call the function to connect to centconf server 
		## and get the file list with cvs/svn version number 
		## and compare them with version & file info stored in local cache
		if ( -d $cachedir) { $logger->info("Checking Cachedir ~ $cachedir , exist");} 
		else { $logger->info("Creating Cachedir ~ $cachedir"); mkdir($cachedir, 0775) || $logger->fatal("Can't create Cachedir ".$!);}
		my $user_agent = new LWP::UserAgent;
		$user_agent->agent("centconf/$myhost");
		$user_agent->timeout(30);
		my $req = new HTTP::Request 'POST',"http://$cf_server/cgi/db_to_xml.pl";
		$req->content_type('application/x-www-form-urlencoded');
		$req->content("host=$myhost&hostcmd=$destination_name&submit=CenTConF");
		my $res = $user_agent->request($req);
		if ($res->is_success) { 
			$logger->info("Connected sucessfully to server"); $content_as_xml=$res->content;
			## informing centconf that -i'm connected.
			 my $msg="Centconf process (pid - $$) running on host $myhost";
			 $process_log=$process_log."<info>".join('',$msg)."</info>";
			 post_log($myhost,$cf_server,"host_name=$myhost&run_status=Running&log_msg=$msg&submit=CentconFLog");
		}
		else { $logger->fatal($res->status_line." Failed and EXIT");
		       $process_log=$process_log."<fail>".$res->status_line." Failed and EXIT</fail>"; exit 1;}
		############## procecess xml start ##############
		if ($content_as_xml eq "") { $logger->fatal("XML is empty.  Failed and EXIT"); exit 1;
					     $process_log=$process_log."<fail>XML is empty. Failed and EXIT</fail>";}
		$logger->info("Parsing xml output..");
		$logger->info("$content_as_xml"); 
		my $xml = XML::Simple->new( SuppressEmpty=>1,ForceArray=>1);
		## readning xml from centconf 
                my $data; eval { $data = $xml->XMLin($content_as_xml);};
                if ($@) { print "Error: XML parsing error";}
                ## print  Dumper($data);
		#######################################
		for my $record (@{$data->{'file_record'}})
		{
			$logger->info("----------------------------------------");
		my ($file_path,$uid,$gid,$permission) = (${$record->{file_path}}[0],${$record->{uid}}[0],${$record->{gid}}[0],${$record->{permission}}[0]);
    			my ($group_name,$rev_no,$action ) = (${$record->{group_name}}[0],${$record->{rev_no}}[0],${$record->{action}}[0]);
			## check if rev_no is empty or not
			if ($rev_no eq ""){$rev_no='HEAD'}
    			$logger->info("$file_path,$uid,$gid,$permission,$group_name,$rev_no,$action");
			$logger->info("Repository URL - $repo_url/${group_name}${file_path}");
			########### repo access ##########
			  my $svn_client = new SVN::Client(
              				auth => [SVN::Client::get_simple_provider(),
              				SVN::Client::get_simple_prompt_provider(\&simple_prompt,2),
              				SVN::Client::get_username_provider()]
              		 );
			 ## most important
			 #$SVN::Error::ignore_error;
			 $SVN::Error::handler = \&svn_error_msg;
			## download file fron repository
			my $base_filename = basename("$file_path");
			my $svn_temp_file =$cachedir."".$group_name."_".$base_filename;
			$svn_error_status="no"; ## reset
			open (MYFILE, ">$svn_temp_file") or $logger->fatal("Can't create temp file in cachedir. errno - $!");
			        #$svn_client->cat (\*STDOUT,"$repo_url/${group_name}${file_path}",$rev_no);
        		        $svn_client->cat (\*MYFILE, "$repo_url/${group_name}${file_path}", $rev_no);
			close (MYFILE);
			########### get actual file details ###########
			my $run_cmd = Shell->new;
			if ( -e $file_path) {
			   my ($fdev,$ino,$file_mode,$nlink,$file_uid,$file_gid,$rdev,$fsize,$atime,$mtime,$ctime,$blksize,$blocks) = stat($file_path);
			   my ($file_user,$file_group,$file_perm) = ((getpwuid($file_uid))[0],(getgrgid($file_gid))[0],sprintf("%3o",$file_mode & 07777));
			   $logger->info("Actual Details - $file_path => $file_user,$file_group,$file_perm");
			   ## check file with svn copy - call diff_or_replace
			   if ($svn_error_status eq "no") { &diff_or_replace($file_path,$svn_temp_file,$rev_no,$run);}
			   ## check permission
                 	   if ($permission == $file_perm) { $logger->info("$file_path - Permission '$file_perm' is fine.");} 
			   else { $logger->warn("$file_path - Permission '$file_perm' is Wrong!");
			  	if ($run == 1){ $run_cmd->chmod($permission,$file_path); $logger->info("$file_path - permission changed to $permission");
					      $process_log=$process_log."<change> $file_path - permission changed to $permission</change>";}
			   }
			   ## check user
                           if ($uid eq $file_user) { $logger->info("$file_path - User ownership of '$file_user' is fine");}
                           else { $logger->warn("$file_path - User ownership of '$file_user' is Wrong!");
				if ($run == 1){ $run_cmd->chown($uid,$file_path) if ($run == 1); $logger->info("$file_path - user changed to $uid");
					      $process_log=$process_log."<change>$file_path - user changed to $uid</change>";}
			   }
			   ## check group
			   if ($gid eq $file_group) { $logger->info("$file_path - Group ownership of '$file_group' is fine");}
			   else { $logger->warn("$file_path - Group ownership of '$file_group' is Wrong!");
				if ($run == 1){ $run_cmd->chgrp($gid,$file_path); $logger->info("$file_path - group changed to $gid");
					      $process_log=$process_log."<change>$file_path - group changed to $gid</change>";}
			   }
			} else { 
			   $logger->warn("$file_path - File Not found?");
			   $process_log=$process_log."<not_found>$file_path - File Not found?</not_found>";
			} # if file_path end 
		} #for loop end
		############## procecess xml end ################
	} #if failed end
	## centconf process completed
	my $last_msg="Centconf process (pid - $$) on host $myhost is Completed.";
	my $empty="<info>:</info><svn_error>:</svn_error><fail>:</fail><change>:</change><not_found>:</not_found><replace>:</replace><diff>:</diff>";
	$process_log=$process_log."<info>".join('',$last_msg)."</info>".$empty."".$empty."</xml>";
	post_log($myhost,$cf_server,"host_name=$myhost&run_status=Successful&log_msg=$process_log&submit=CentconFLog");
}
########################################

#done
print "\n";

