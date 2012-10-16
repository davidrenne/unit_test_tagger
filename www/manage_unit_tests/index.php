<?php
//-- more information about cruddy_mysql can be found here, I am lazy and this manages all the crud you will need with your screenshots
//-- http://sourceforge.net/projects/cruddymysql/

ob_start();
include("../settings.php");
include("cruddy_mysql/cruddy_mysql.php");
echo 
'	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
	<title>Manage Your Unit Tests</title>
	<meta http-equiv="Content-Language" content="English" />
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<link rel="stylesheet" type="text/css" href="../build_document_style.css" media="screen" />
	<body>
';
$crudAdmin = new cruddyMysqlAdmin();
//$crudAdmin->cruddyAdministrator = true;
$crudAdmin->paint('unit_test_screenshots',$mysqlServer,$mysqlUser,$mysqlPass,$mysqlDatabase,'unittestscreenshots');
echo 
'
</body>
</html>
';
ob_end_flush();

?>