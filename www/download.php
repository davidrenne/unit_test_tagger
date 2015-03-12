<?php

/*
 * @file:    download.php
 * @usage:   pass file name which is a file in your screenshots folder
 */
include("settings.php");
$doc_path = $relativePathToScreenshots.$_GET['file'];
if (file_exists($doc_path)) {
	if (($fp = @fopen($doc_path, 'r'))) {
		$name = str_replace(array('"',"'",'\\','/'), '', $_GET['file']);
		header('Content-Disposition: attachment; filename="'.$name.'"');
		header("Content-Type: application/octet-stream");
		header("Content-Type: application/force-download");
		header("Content-Type: application/download");
		header("Content-Transfer-Encoding: binary");
		header("Pragma: public");
		header("Expires: 0");
		header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
		header("Content-Description: File Transfer");
		header("Content-Length: " . filesize($doc_path));
		@fpassthru($fp);
		exit;
	} 
} else {
	echo 
	"<script>alert('The file ".$_GET['file']." does not exist in ".$relativePathToScreenshots." folder.');</script>";
}

?>