// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function handleIndexButton() {
    var f=document.forms["actions"];
    if (f["stops"] != undefined) {
        f.action = "<%= url_for :action => 'stops', 
    } else if (f["route"] != undefined) {
    }
}