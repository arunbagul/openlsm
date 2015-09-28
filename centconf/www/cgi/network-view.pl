#!/usr/bin/perl

sub BEGIN
{
        unshift (@INC, '/home/centconf/module/');
        unshift (@INC, '/usr/lib/perl5/');
}

use strict;
use warnings;
use GraphViz;
use Centconfig;
use CGI qw(:standard);
use CGI::Session;
use Login;
use Admin;
#use DBD::mysql;
#use Switch;
#use MainLima;
#use MainSLA;
#use File::stat;

###### DB connection details ##############
#connection details
my $hash_ref=Centconfig::config_parse;
my $db=${$hash_ref}{database};
my $host=${$hash_ref}{db_host};
my $user=${$hash_ref}{db_user};
my $password=${$hash_ref}{db_password};

### Header
########################
my $page = CGI->new();
##### check authentication 
Login::is_authen($page);
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
Admin::print_header("Network");
#
print "<div class='container_12'>";

######################################################################
## Network diagram code started here
######################################################################

#Draw the graph
my $graph = GraphViz->new(
         name => 'network_view',
         label => 'network View',
         #directed => 1,
         layout => 'neato', ratio => 'compress',
         rankdir  =>1,
         width => 400, height => 500
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
################ Firewall /Cisco switch 

# Rackspace
my $rs = {
        name      =>'rackspace',
        label     =>'RackSpace Colo',
        fillcolor =>'lavender',
        #fillcolor =>"$fillcolor",
        @cluster_attrs
};

################
## internet
$graph->add_node(
         name =>'start_network',
         label =>"Internet",
         fillcolor =>'lavender',
         shape => 'none',
        );

## firewall
$graph->add_node(
         name =>'firewall',
         label =>"Cisco Firewall",
         #fillcolor =>'lavender',
         fillcolor =>'indianred2',
         URL => 'network-view.pl?host=firewall',
         @default_attrs,
	 shape =>'box3d',
        );

##### switch
$graph->add_node(
         name =>'switch',
         label =>"Cisco Switch",
         fillcolor =>'cyan3',
         URL => 'network-view.pl?host=switch',
         @default_attrs,
         shape =>'component',
        ); 

## oracle-switch
$graph->add_node(
         name =>'ora_switch',
         label =>"Oracle Cisco Switch",
         fillcolor =>'cyan3',
         URL => 'network-view.pl?host=ora_switch',
         @default_attrs,
         shape =>'component',
        );
## haproxy
$graph->add_node(
         name =>'haproxy',
         label =>"HAproxy Servers",
         fillcolor =>'gold2',
         URL => 'network-view.pl?host=haproxy',
         @default_attrs,
         shape =>'hexagon',
        );

##
$graph->add_node(
         name =>'world_app',
         label =>"World App Servers",
         fillcolor =>'deepskyblue3',
         URL => 'network-view.pl?host=world_app',
         @default_attrs,
         shape =>'folder',
        );

##
$graph->add_node(
         name =>'myops_app',
         label =>"Myops App Servers",
         fillcolor =>'deepskyblue3',
         URL => 'network-view.pl?host=myops_app',
         @default_attrs,
         shape =>'folder',
        );

##
$graph->add_node(
         name =>'other_app',
         label =>"Other App Servers",
         fillcolor =>'deepskyblue3',
         URL => 'network-view.pl?host=other_app',
         @default_attrs,
         shape =>'folder',
        );

## MySQL DB
$graph->add_node(
         name =>'mysql_db',
         label =>"MySQL DB Servers",
         fillcolor =>'darkorange3',
         URL => 'network-view.pl?host=mysql',
         @default_attrs,
         shape =>'tab',
        );
## Oracle DB
$graph->add_node(
         name =>'ora_db',
         label =>"Oracle DB RAC",
         fillcolor =>'darkorange3',
         URL => 'network-view.pl?host=oracle',
         @default_attrs,
         shape =>'tab',
        );
##
$graph->add_node(
         name =>'rks',
         label =>"RackSpace Colo",
         fillcolor =>'darkslategray',
         URL => 'network-view.pl?host=rsk',
         @default_attrs,
         shape =>'doubleoctagon',
        );

################# edges started #############

##
my $firewall_switch=$graph->add_edge(
        'start_network' => 'firewall',
        color => 'brown',
        dir => 'both',
        len => '1.5',
        );

##
my $firewall_switch1=$graph->add_edge(
        'firewall' => 'switch',
        color => 'brown',
	fontcolor => 'brown2',
	label => 'Network Usage',
	URL => 'network-view.pl?host=firewall_switch',
	fontsize => '08',
	dir => 'both',
	len => '1.6',
        ); 

##
my $firewall_ora_switch=$graph->add_edge(
        'firewall' => 'ora_switch',
        color => 'brown',
        dir => 'both',
	len => '1.5',
        );

##
my $switch_haproxy=$graph->add_edge(
        'switch' => 'haproxy',
	color => 'brown',
	dir => 'both',
	len => '1.0',
        );
##
my $haproxy_app1=$graph->add_edge(
        'haproxy' => 'world_app',
	color => 'brown',
        dir => 'both',
        len => '1.6',
        );
##
my $haproxy_app2=$graph->add_edge(
        'haproxy' => 'myops_app',
	color => 'brown',
        dir => 'both',
        len => '1.5',
        );
#
my $haproxy_app3=$graph->add_edge(
        'haproxy' => 'other_app',
	color => 'brown',
        dir => 'both',
        len => '1.5',
        );
##
my $ora_switch_db=$graph->add_edge(
        'ora_switch' => 'ora_db',
        color => 'brown',
        dir => 'both',
        len => '1.5',
        );
##
my $switch_mysql=$graph->add_edge(
        'switch' => 'mysql_db',
        color => 'brown',
        dir => 'both',
        len => '1.5',
        );
##
my $firewall_rks=$graph->add_edge(
        'firewall' => 'rks',
        color => 'brown',
        dir => 'both',
        len => '1.5',
        );

###################### end of edges #############################
#### generate graph
$graph->as_png("/home/centconf/www/graph/network_view.png"); 
print "<img src='../graph/network_view.png' USEMAP='#network_view' style='border:none;' />"; 
my @map=$graph->as_cmapx(); 
print @map;
open (MYMAP, ">/home/centconf/www/graph/network_view.map");
print MYMAP @map;
close (MYMAP);  
######################################################################
print "<div style='clear: both;'></div></div>"; #-- container_12 end
##################
# Footer
Admin::print_footer();
print $page->end_html; 
#DONE

