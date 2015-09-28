<!-- Ajax code -->
function fnGetAJAXrequestobject() 
{
    var browser = navigator.appName;
    if(browser == "Microsoft Internet Explorer")
    {
        return new ActiveXObject("Microsoft.XMLHTTP");
    }
    else
    {
        return new XMLHttpRequest();
    }   
}

<!-- Get file list / GET method -->

function get_file_list(optionId)
{
        var ajax_request = fnGetAJAXrequestobject();
        strparams = "type=editor&id=" + optionId ; 
        var sUrl="get_by_ajax.pl?"+strparams;
        
        ajax_request.onreadystatechange = function() 
        { 
                if(ajax_request.readyState == 4)
                {
                        /* alert(ajax_request.responseText); */
			document.getElementById('file_revision_number').style.display='none';
			document.getElementById('revision_number').style.display='none';
			document.getElementById('wysiwyg_svn').value='';
			document.getElementById('cmb_file_list').innerHTML='';
			document.getElementById('cmb_file_list').innerHTML=ajax_request.responseText;
                }
        }
        ajax_request.open("GET", sUrl, true);
        ajax_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        ajax_request.send(); 
}

<!-- Get Group list / GET method -->

function get_group_list(optionId)
{
        var ajax_request = fnGetAJAXrequestobject();
        strparams = "type=modify&id=" + optionId ;
        var sUrl="get_by_ajax.pl?"+strparams;

        ajax_request.onreadystatechange = function()
        {
                if(ajax_request.readyState == 4)
                {
                        /* alert(ajax_request.responseText); */
                        document.getElementById('cmb_file_list').innerHTML='';
                        document.getElementById('cmb_file_list').innerHTML=ajax_request.responseText;
                }
        }
        ajax_request.open("GET", sUrl, true);
        ajax_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        ajax_request.send();
}

<!-- fileinfo / POST method -->

function get_fileinfo(fileid)
{
        var ajax_request = fnGetAJAXrequestobject();
	var grpid=document.getElementById('grp_name').value;
        strparams = "fileid=" + fileid + "&groupid=" + grpid ;
        var sUrl="get_by_ajax.pl";

        ajax_request.onreadystatechange = function()
        {
                if(ajax_request.readyState == 4)
                {
		 var result=ajax_request.responseText.split("{-!-}");
		 document.getElementById('user_name').value=result[0];
		 document.getElementById('grp_owner').value=result[1];
		 document.getElementById('permission').value=result[2];
		 document.getElementById('rev_no').value=result[3];
		 document.getElementById('action').value=result[4];
		 document.getElementById('status').value=result[5];
                }
        }
        ajax_request.open("POST", sUrl, true);
        ajax_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        ajax_request.send(unescape(strparams)); 
}

<!-- Get file from svn / POST method -->

function get_file_from_svn(fileid)
{
        //document.getElementById('file_revision_number').style.display='none';
        var ajax_request = fnGetAJAXrequestobject();
        var grpid=document.getElementById('grp_name').value;
        strparams = "fileid=" + fileid + "&groupid=" + grpid ;
        var sUrl="get_file_from_svn.pl";
	//alert(strparams);
        ajax_request.onreadystatechange = function()
        {
                if(ajax_request.readyState == 4)
                {
		 	var result_svn=ajax_request.responseText.split("{-!-}");
                 	document.getElementById('file_revision_number').innerHTML=result_svn[0];
                 	document.getElementById('file_revision_number').style.display='';
                 	document.getElementById('wysiwyg_svn').value=result_svn[1];
                 	document.getElementById('revision_number').style.display='';
                 	document.getElementById('revision_number').innerHTML='';
                 	document.getElementById('revision_number').innerHTML=result_svn[2];
                 	//alert(ajax_request.responseText);
			//document.getElementById('wysiwyg_svn').innerHTML='';
                        //document.getElementById('wysiwyg_svn').innerHTML=ajax_request.responseText; 
                }
        }
        ajax_request.open("POST", sUrl, true);
        ajax_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        ajax_request.send(unescape(strparams));
}


<!-- Get file from svn with revision_number / POST method -->

function revision_number_svn(svn_number)
{
        var ajax_request = fnGetAJAXrequestobject();
        var fileid=document.getElementById('file_path').value;
        var grpid=document.getElementById('grp_name').value;
        strparams = "svn_num=" + svn_number + "&groupid=" + grpid + "&fileid=" + fileid ;
        var sUrl="get_file_from_svn.pl";
        //alert(strparams);
        ajax_request.onreadystatechange = function()
        {
                if(ajax_request.readyState == 4)
                {
                        var result_from_svn=ajax_request.responseText.split("{-!-}");
                        //alert(ajax_request.responseText);
			document.getElementById('file_revision_number').innerHTML=result_from_svn[0];
			document.getElementById('file_revision_number').style.display='';
                        document.getElementById('wysiwyg_svn').value='';
                        document.getElementById('wysiwyg_svn').value=result_from_svn[1]; 
                }
        }
        ajax_request.open("POST", sUrl, true);
        ajax_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        ajax_request.send(unescape(strparams));
}

<!-- enable/disable group/host / GET method -->

function enable_disable(mytype,mystatus,myid)
{
        var ajax_request = fnGetAJAXrequestobject();
	var mystatus_variable ='hdn_'+mytype+'_'+myid;
	var mystatus=document.getElementById(mystatus_variable).value;
        strparams = "type="+ mytype + "&status="+ mystatus +"&id=" + myid;
        var sUrl="enable_disable.pl?"+strparams;

        ajax_request.onreadystatechange = function()
        {
                if(ajax_request.readyState == 4)
                {
			var str_img='img_'+mytype+'_'+myid;
			var str_status='status_'+mytype+'_'+myid;
			if (ajax_request.responseText == 'Enabled'){
                        	document.getElementById(str_status).innerHTML='Enabled';
                        	document.getElementById(str_img).src='../images/minus-circle.gif';
				document.getElementById(mystatus_variable).value='disable';
			}
			else if (ajax_request.responseText == 'Disabled'){ 
				document.getElementById(str_status).innerHTML='Disabled'; 
                        	document.getElementById(str_img).src='../images/tick-circle.gif';
				document.getElementById(mystatus_variable).value='enable';
			}
                }
        }
        ajax_request.open("GET", sUrl, true);
        ajax_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        ajax_request.send();
}

<!-- end of func -->

