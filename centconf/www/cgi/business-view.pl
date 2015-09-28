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
use GraphViz;
use Admin;
use Centconfig;
##use DBI;
##use DBD::mysql;

###### DB connection details ##############
#connection details
my $hash_ref=Centconfig::config_parse;
my $db=${$hash_ref}{database};
my $host=${$hash_ref}{db_host};
my $user=${$hash_ref}{db_user};
my $password=${$hash_ref}{db_password};

### Header
########################
my $page = CGI->new( );
##### check authentication 
my $login_name=Login::is_authen($page);
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
Admin::print_header("Business");
#
print "<div class='container_12'>";

######################################################################
## Business view started here
######################################################################
#Draw the graph
my $graph = GraphViz->new(
	 name => 'business_view',
	 label => 'Business View',
	 directed => 1 ,
	 layout => 'dot', ratio => 'compress',
	 rankdir  =>1,
	 #width => 300, height => 500
	);
# Default attributes
my @default_attrs = (
	shape => 'box',
        fontname  =>'arial',
        fontsize  =>'10',	
	style => 'filled',
	color => 'blue',
);

my @cluster_attrs = (
        style     =>'filled',
        fontname  =>'arial',
        fontsize  =>'10',
);
# 
my $label;my $fillcolor='lavender'; my $nolabel;
################ ADE start ##########################
## ADE Group 
my $ADE = {
    	name      =>'ADE',
	label 	  =>'WorldAdapt-ADE',
    	fillcolor =>'lavender',
    	#fillcolor =>"$fillcolor",
	@cluster_attrs,
	rankdir => 0
};
## ADM/LAM Group 
my $ADM = {
        name      =>'ADM',
        label     =>'ADM-LAM',
        fillcolor =>'lavender',
        #fillcolor =>"$fillcolor",
        @cluster_attrs
};
## 
my $AIP = {
        name      =>'AIP',
        label     =>'AIP-ASE',
        fillcolor =>'lavender',
        @cluster_attrs
};

###################
$graph->add_node(
         name =>'web_gui',
         label =>"Web Interface",
         fillcolor =>'lavender',
         URL => 'business-view.pl?host=user_input',
         @default_attrs,
	 shape => 'house',
        );
##### haproxy
$graph->add_node(
         name =>'haproxy',
         label =>"HA Proxy\n(load balancer)",
         fillcolor =>'pink',
	 cluster => $ADE,
         URL => 'business-view.pl?host=haproxy',
         @default_attrs,
	 fontsize  =>'07',
        );
##### app-server/ app110
$graph->add_node(
         name =>'app_app110',
         label =>"app110\n(app server)",
         fillcolor =>'yellow',
         cluster => $ADE,
         URL => 'business-view.pl?host=app_server',
         @default_attrs
        );
#####  app-server/ app128 
$graph->add_node(
         name =>'app_app128',
         label =>"app128\n(app server)",
         fillcolor =>'yellow',
         cluster => $ADE,
         URL => 'business-view.pl?host=app_server',
         @default_attrs
        );
#####  db-server/db02
$graph->add_node(
         name =>'db_db02',
         label =>"db02\n(ADE_DATA\@GED1)",
         fillcolor =>'green',
         cluster => $ADE,
         URL => 'business-view.pl?host=db_server',
         @default_attrs,
	 fontsize  =>'07',
        );
################ ADM start ##########################
$graph->add_node(
         name =>'db_adm_db02',
         label =>"db02\n(ADM_DATA\@SGA1)",
         fillcolor =>'green',
         cluster => $ADM,
         URL => 'business-view.pl?host=db_server',
         @default_attrs,
	 fontsize  =>'07',
	);
##
$graph->add_node(
         name =>'db_db03',
         label =>"db03\n(ADM_DATA\@SGA2)",
         fillcolor =>'green',
         cluster => $ADM,
         URL => 'business-view.pl?host=db_server',
         @default_attrs,
	 fontsize  =>'07',
        );
##
$graph->add_node(
         name =>'adm_daemon',
         label =>"DaemonADM.sh\n(app140)",
         fillcolor =>'darkorchid2',
         #cluster => $ADM,
         URL => 'business-view.pl?host=process_app140',
         @default_attrs,
	 shape =>'circle',
	 fontsize  =>'07',
        );
##
$graph->add_node(
         name =>'dm_daemon',
         label =>"DaemonADm.sh\n(app140)",
         fillcolor =>'darkorchid2',
         #cluster => $ADM,
         URL => 'business-view.pl?host=process_app140',
         @default_attrs,
         shape =>'circle',
	 fontsize  =>'07',
        );

################ AIP start ##########################
$graph->add_node(
         name =>'aip_db02',
         label =>"db02\n(AIP_DATA\@SGA1)",
         #fillcolor =>'lavender',
         fillcolor =>'green',
         cluster => $AIP,
         URL => 'business-view.pl?host=aip_db02',
         @default_attrs,
	 fontsize  =>'07',
        );
##
$graph->add_node(
         name =>'aip_db03',
         label =>"db03\n(ADM_DATA\@SGA2)",
         fillcolor =>'green',
         cluster => $AIP,
         URL => 'business-view.pl?host=aip_db03',
         @default_attrs,
	 fontsize  =>'07',
        );
##
$graph->add_node(
         name =>'aip_daemon',
         label =>"Daemon Agg & AIP\n(app140)",
         fillcolor =>'darkorchid2',
         #cluster => $AIP,
         URL => 'business-view.pl?host=process_app140',
         @default_attrs,
         shape =>'circle',
	 fontsize  =>'07',
        );
##
$graph->add_node(
         name =>'file_sync',
         label =>"File Sync\n(r/w)",
         fillcolor =>'darkorchid2',
         #cluster => $AIP,
         URL => 'business-view.pl?host=file_sync',
         @default_attrs,
         shape =>'circle'
        );

##
$graph->add_node(
         name =>'memcache',
         label =>"memcache",
         fillcolor =>'darkseagreen4',
         cluster => $AIP,
         URL => 'business-view.pl?host=memcache',
         @default_attrs,
        );
##
$graph->add_node(
         name =>'serialized_file',
         label =>"Serialized File",
         fillcolor =>'darkseagreen4',
	 cluster => $AIP,
         URL => 'business-view.pl?host=serialized_file',
         @default_attrs,
        );
##
$graph->add_node(
         name =>'ads1',
         label =>"AD Server",
         fillcolor =>'deeppink2',
         #cluster => $AIP,
         URL => 'business-view.pl?host=ads1',
         @default_attrs,
        );
##
$graph->add_node(
         name =>'ads2',
         label =>"AD Server",
         fillcolor =>'deeppink2',
         #cluster => $AIP,
         URL => 'business-view.pl?host=ads2',
         @default_attrs,
        );
##
$graph->add_node(
         name =>'ads3',
         label =>"AD Server",
         fillcolor =>'deeppink2',
         #cluster => $AIP,
         URL => 'business-view.pl?host=ads3',
         @default_attrs,
        );
##
$graph->add_node(
         name =>'end_network1',
         label =>"Internet",
         fillcolor =>'lavender',
         shape => 'none',
	 fontsize =>07,
        );
##
$graph->add_node(
         name =>'end_network2',
         label =>"Internet",
         fillcolor =>'lavender',
         shape => 'none',
	 fontsize =>07,
        );
##
$graph->add_node(
         name =>'end_network3',
         label =>"Internet",
         fillcolor =>'lavender',
         shape => 'none',
	 fontsize =>07,
        );

####################### start of edges ############################
###### ADE edge start
my $gui_haproxy=$graph->add_edge(
        'web_gui' => 'haproxy',
	fontsize =>07,
	label => ' user info',
        color => 'brown',
	
        );
##
my $haproxy_app1=$graph->add_edge(
        'haproxy' => 'app_app110',
        color => 'brown'
        );
##
my $haproxy_app2=$graph->add_edge(
        'haproxy' => 'app_app128',
        color => 'brown'
        );

##
my $app1_db2=$graph->add_edge(
        'app_app110' => 'db_db02',
        color => 'brown'
        );
##
my $app2_db2=$graph->add_edge(
        'app_app128' => 'db_db02',
        color => 'brown'
        );

############ ADM edge 
my $adm_then_dm=$graph->add_edge(
        'adm_daemon' => 'dm_daemon',
        color => 'brown'
        );
##
my $db2_to_adm=$graph->add_edge(
        'db_db02' => 'adm_daemon',
        color => 'brown'
        );
##
my $adm_proc_to_db2_adm=$graph->add_edge(
        'adm_daemon' => 'db_adm_db02',
        color => 'brown'
        );
##
my $adm_db02_readby_dm_proc=$graph->add_edge(
        'db_adm_db02' => 'dm_daemon',
        color => 'brown'
        );
##
my $dm_proc_writeto_db03=$graph->add_edge(
        'dm_daemon' => 'db_db03',
        color => 'brown'
        );

############ AIP start

my $db02_aipdaemon=$graph->add_edge(
        'db_adm_db02' => 'aip_daemon',
        color => 'brown'
        );
##
my $aipdaemon_aipdb02=$graph->add_edge(
        'aip_daemon' => 'aip_db02',
        color => 'brown'
        );
##
my $aggdaemon_aipdb03=$graph->add_edge(
        'aip_daemon' => 'aip_db03',
        color => 'brown'
        );

##
my $db03_aggdaemon=$graph->add_edge(
        'db_db03' => 'aip_daemon',
        color => 'brown'
        );

##
my $db02_filesync=$graph->add_edge(
        'aip_db02' => 'file_sync',
        color => 'brown'
        );
##
my $db03_filesync=$graph->add_edge(
        'aip_db03' => 'file_sync',
        color => 'brown'
        );

##
my $filesync_serial=$graph->add_edge(
        'file_sync' => 'serialized_file',
        color => 'brown'
        );
##
my $filesync_mem=$graph->add_edge(
        'file_sync' => 'memcache',
        color => 'brown'
        );
####
my $mem_ads1=$graph->add_edge(
        'memcache' => 'ads1',
        color => 'brown'
        );
##
my $mem_ads2=$graph->add_edge(
        'memcache' => 'ads2',
        color => 'brown'
        );
##
my $mem_ads3=$graph->add_edge(
        'memcache' => 'ads3',
        color => 'brown'
        );


####
my $serial_ads1=$graph->add_edge(
        'serialized_file' => 'ads1',
        color => 'brown'
        );

##
my $serial_ads2=$graph->add_edge(
        'serialized_file' => 'ads2',
        color => 'brown'
        );

##
my $serial_ads3=$graph->add_edge(
        'serialized_file' => 'ads3',
        color => 'brown'
        );


#########################
my $end_network1=$graph->add_edge(
        'ads1' => 'end_network1',
        color => 'brown'
        );
##
##
my $end_network2=$graph->add_edge(
        'ads2' => 'end_network2',
        color => 'brown'
        );
##
##
my $end_network3=$graph->add_edge(
        'ads3' => 'end_network3',
        color => 'brown'
        );

############ AIP end
#my $edge_invis2=$graph->add_edge(
#        'file_sync' => 'app_app110',
#        color => 'brown',
      #style => 'invis',
#        );

my $edge_invis4=$graph->add_edge(
        'aip_daemon' => 'haproxy',
        color => 'brown',
        style => 'invis',
        );

###################### end of edges #############################
#### generate graph
$graph->as_png("/home/centconf/www/graph/business_view.png"); 
print "<img src='../graph/business_view.png' USEMAP='#business_view' style='border:none;' />"; 
my @map=$graph->as_cmapx(); 
print @map;
open (MYMAP, ">/home/centconf/www/graph/business_view.map");
print MYMAP @map;
close (MYMAP);	
######################################################################
print "<div style='clear: both;'></div></div>"; #-- container_12 end
##################
# Footer
Admin::print_footer();
print $page->end_html; 
#DONE

