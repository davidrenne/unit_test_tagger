<?php
/*
 * @file:    build_document_descs_only.php
 * @info:    is a plain document which needs to pass 1 field/column to show with the screenshots
 */
    require_once("settings.php");
    
    $asc = ($_GET['by_date']) ? "desc" : "";
    $by_task = ($_GET['by_date']) ? "units.unit_test_time BETWEEN '".date("Y-m-d",strtotime($_GET['by_date']))." 00:00:00' AND '".date("Y-m-d",strtotime($_GET['by_date']." +1 day"))." 00:00:00' AND " : "units.task_pk = '".$_GET['task_id']."' AND";
    
	$unitTestQuery = 
	"
	SELECT 
		units.*,
		tasks.task_desc,
		DATE_FORMAT(units.unit_test_time,'%r') as time
	FROM 
		unit_test_screenshots units,
		unit_test_screenshots_tasks tasks
	WHERE
		units.task_pk = tasks.task_pk AND
		$by_task
		units.developer = '".$_GET['user']."' $extraQs
	ORDER BY
		units.functionality, units.unit_test_time $asc
	";
	$results = mysql_query($unitTestQuery);
	$count = mysql_num_rows($results);
	if (empty($_GET['field'])) {
		die('No Field Passed');
	}
		
	ini_set('allow_url_fopen', 'on'); 
	header('Content-type: text/xml'); 
	
	while($row = mysql_fetch_array($results)) {
		$allRows[] = $row;
	}
	
	
    $title = ($_GET['by_date']) ? $_GET['user']."'s Screenshots for ".date("Y-m-d",strtotime($_GET['by_date'])) : "Unit Tests For Project '{$allRows[0]['task_desc']}'";

	echo '
	<rss version="2.0">
	<channel>
	<title>'.$title.'</title>
	<description>'.$title.'</description>
	<link>'.$pathToInstall.'</link>
	<copyright>Copyright '.date('Y').'</copyright>
	';
	
	if (is_array($allRows)) {
		foreach ($allRows as $key=>$row) {
			
			if ($funcSection != $row['functionality']) {
				$ii++;
			}
			if (!empty($row[$_GET['field']])) {
				if (!$_GET['by_date']) {
					$identifier = "$ii.".$row['revision'];
				} else {
					$identifier = $row['time'];
				}
				$remarks = "<span class=\"remark\">".$identifier.": <strong>".str_replace("\n","<br/>",$row[$_GET['field']])."</strong><span><br/>";
			} else {
				$remarks = "";
			}
	
			if (stristr($row['file_name'],"png") || stristr($row['file_name'],"jpg") || stristr($row['file_name'],"gif")) {
				$objectHTML = "<a href=\"".$pathToScreenshots.$row['file_name']."\"><img src=\"".$pathToScreenshots.$row['file_name']."\"/></a>";
			} else {
				$objectHTML = "<a href=\"".$pathToInstall."download.php?file=".$row['file_name']."\">Download ".$row['file_name']."\"></a>";
			}
			
			echo '	
		     <item>
		        <title>'.htmlentities(stripslashes(strip_tags($row['task_desc'].' - '.$row['functionality']))) .'</title>
		        <description><![CDATA['.$remarks.$objectHTML.']]></description>
		        <link>'.$pathToInstall.'manage_unit_tests/?action=update_unit_test_screenshots&amp;unit_test_id='.$row['unit_test_id'].'</link>
		        <pubDate>'.strftime( "%a, %d %b %Y %T %Z" , strtotime($row['unit_test_time'])).'</pubDate>
		     </item>';
			$funcSection = $row['functionality'];
		}
	}
	echo '
	</channel>
	</rss>';

?>