<?
include "p01utility_functions.php";

$formtype = 'admin';
$sessionid =$_GET["sessionid"];
verify_session($sessionid, $formtype);
echo("<title>Admin page</title>");


// Here we can generate the content of the welcome page
echo("Admin Management Menu: <br />");
//echo("<UL><LI><A HREF=\"p01department.php?sessionid=$sessionid\">test</A></LI><LI><A HREF=\"p01employee.php?sessionid=$sessionid\">two</A></LI></UL>");

echo("<br />");
echo("<br />");
echo("Click <A HREF = \"p01logout_action.php?sessionid=$sessionid\">here</A> to Logout.");
echo("<br>");
echo("Click <A HREF = \"p01passChange.php?sessionid=$sessionid\">here</A> to Change Password.");
echo("<br>");
echo("Click <A HREF = \"p01manage.php?sessionid=$sessionid\">here</A> to manage accounts.");
?>