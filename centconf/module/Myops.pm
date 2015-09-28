package Myops;

### Header section
sub world_details_header 
{
print <<"EOF_Myops";
<div id='subnav'>
    <ul>
     <li><a href="myops.pl?cmd=host" target="" title="List of all hosts">All Host List</a></li>
     <li><a href="myops.pl?cmd=host_by_group" target="" title="List of hosts by group">Host by Group</a></li>
     <li><a href="myops.pl?cmd=host_by_category" target="" title="List of hosts by Category">Host by Category</a></li>
     <li><a href="myops.pl?cmd=dbhost" target="" title="DB details">Database Details</a></li>
     <li><a href="myops.pl?cmd=all">All Process List</a></li>
     <li><a href="myops.pl?cmd=bygroup" target="" title='List process per process group'>Process by Group</a></li>
     <li><a href="myops.pl?cmd=byhost" target="" title="List process activated on hosts">Process by Host</a></li>
     <li><a href="myops.pl?cmd=update" target="" title="Update process details in table">Update Process Details</a></li>
    </ul>
    <br style="clear:left"/>
</div>
EOF_Myops
}

#done
1;
