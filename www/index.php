<?php
/*
 * @file:    index.php
 * @usage:   pass user to it and select your project screenshots
 */ 
	require_once("settings.php");
	$unitTestQuery =
	"
	SELECT
		DISTINCT
		task.task_desc, scr.task_pk
	FROM
		unit_test_screenshots scr,
		unit_test_screenshots_tasks task
	WHERE
		scr.task_pk = task.task_pk AND
		scr.developer = '".$_GET['user']."'
	ORDER BY
		unit_test_time
	DESC
	";
	$results = mysql_query($unitTestQuery);

	while($row = mysql_fetch_array($results)) {
		$allRows[] = $row;
	}

	if (isset($_GET['user']) && isset($allRows)) {
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>My Unit Tests</title>
<meta http-equiv="Content-Language" content="English" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" type="text/css" href="index_style.css" media="screen" />
</head>
<body>
<div id="wrap">

<div id="top"></div>

<div id="content">

<div class="header">
<h1><a href="index.php">Unit Test Documentation</a></h1>
<h2>Generate Your Final Unit Test Documents</h2>
</div>

<div class="breadcrumbs">
<a>Home</a> &middot; You are here
</div>

<div class="middle">

	<h2>Welcome To Your Unit Tests</h2>

	Just click on your project to get started
	<ul>
		<?php
		if (sizeof($allRows) > 0) {
			foreach ($allRows as $k=>$v) {
				echo "
				<li>
						<a href=\"build_document.php?user=".$_GET['user']."&task_id=".$v['task_pk']."\">".$v['task_desc']."</a>

						<ul style=\"list-style-type:none;\">
								<li>
										&diams;&#160;<a href=\"build_document.php?user=".$_GET['user']."&task_id=".$v['task_pk']."\">Full Unit Test Info</a> &diams;&#160;<a href=\"build_document_descs_only.php?user=".$_GET['user']."&task_id=".$v['task_pk']."&field=unit_test_expected_result&wiki=1\">Wiki</a> &diams;&#160;<a href=\"build_document_descs_only.php?hide_edit&user=".$_GET['user']."&task_id=".$v['task_pk']."&field=unit_test_expected_result\">Descs Only</a>

								</li>
						</ul>
				</li>";
			}
		} else {
			echo "<li>No projects found.</li>";
		}
		?>

	</ul>
</div>

<div class="right">

<h2>Help</h2>
<h2><a href="build_document_descs_only.php?by_date=today&user=<?php=$_GET['user']?>&field=unit_test_expected_result">View <?php=$_GET['user']?>'s Current Screens From Today</h2>
<h2><a href="build_document.php?user=ALL&task_id=1">View The Unit Test Tagger Documentation</h2>
<h2><a href="download.php?file=Unit Test Screen Tagger.exe">Download The Program</h2>

</div>

<div id="clear"></div>

</div>

<div id="bottom"></div>

</div>

<div id="footer">
</div>
<?php
	} elseif (!isset($allRows) && isset($_GET['user'])) {
		echo "Please take some screenshots before using this web interface.
		We could not find any unit tests under this developer name you entered.
		<br/><br/>
		Please ensure you typed or passed your windows username exactly as it is in your system.
		<br/><br/>
		<input type='button' onclick='
		var UserName = window.prompt(\"Please enter your windows username\");
		document.location=\"".$_SERVER['PHP_SELF']."?user=\" + UserName;' value='Please Try Again'/>
		<input type='button' onclick='document.location=\"build_document.php?user=ALL&task_id=1\"' value='View The Help Document'/>
		<input type='button' onclick='document.location=\"download.php?file=Unit Test Screen Tagger.exe\"' value='Download The Program'/>
		";
	} else {
		echo "
		<script>
		var UserName = window.prompt('Please enter your windows username');
		document.location=document.location + '?user=' + UserName;
		</script>";
	}
?>

</body>
</html>