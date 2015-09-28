// IMP  jquery-tree function //

$(document).ready(function(){
        $("#domain_tree_browser").treeview({
                toggle: function() {
                        console.log("%s was toggled.", $(this).find(">span").text());
                }
        });
});

// end of jquery-tab function //


// IMP  jquery-tree function //
        
$(function(){
    $('#haproxy_jquery_tabs').tabs({
        remote: true,
	bookmarkable : false
    });
});

// end of jquery-tab function //
