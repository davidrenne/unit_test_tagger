<?
/*
 * @file:    settings.php
 * @usage:   add your mysql server connection info as well as database
 */
$relativePathToScreenshots = 'screenshots/';
if (dirname($_SERVER['SCRIPT_NAME']) == '/') {
	$directory = "";
} else {
	$directory = dirname($_SERVER['SCRIPT_NAME']);
}
if ($_SERVER['SERVER_PORT']!=80) {
	$port = ":".$_SERVER['SERVER_PORT'];
}
$pathToScreenshots = 'http://'.$_SERVER['HTTP_HOST'].$port.$directory."/".$relativePathToScreenshots;
$pathToInstall     = 'http://'.$_SERVER['HTTP_HOST'].$port.$directory."/";

$mysqlServer   = "xxxx.mysqlserver.xxx";
$mysqlUser     = "xxxxUserxxxx";
$mysqlPass     = "xxxxPassxxxx";
$mysqlDatabase = "xxxxDataBasexxxx";
if ($conn = mysql_connect($mysqlServer,$mysqlUser,$mysqlPass) === false) {
	die('cannot connect to mysql');
}
mysql_select_db($mysqlDatabase);

?>