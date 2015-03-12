<?php
/*
 * @file:    build_document.php
 * @info:    the goods
 */

    require_once("settings.php");
	
	if (isset($_GET['show_only']) && $_GET['show_only'] != 'All') {
		$extraQs = " AND units.unit_test_pass_fail = '{$_GET['show_only']}'";
	} else if (isset($_GET['show_only']) && $_GET['show_only'] == 'Other') {
		$extraQs = " AND units.unit_test_pass_fail NOT IN ('Pass','Fail')";
	}
	$unitTestQuery = 
	"
	SELECT 
		units.*,
		tasks.task_desc
	FROM 
		unit_test_screenshots units,
		unit_test_screenshots_tasks tasks
	WHERE
		units.task_pk = tasks.task_pk AND
		units.task_pk = '".$_GET['task_id']."' AND
		units.developer = '".$_GET['user']."' $extraQs
	ORDER BY
		units.functionality, units.unit_test_time
	";
	$results = mysql_query($unitTestQuery);

echo <<<EOD
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
	<title>Unit Tests For Project {$_GET['task_id']}</title>
	<link rel="alternate" type="application/rss+xml" title="RSS-Feed" href="build_rss.php?task_id={$_GET['task_id']}&user={$_GET['user']}&field=unit_test_expected_result" />
	<meta http-equiv="Content-Language" content="English" />
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<link rel="stylesheet" type="text/css" href="build_document_style.css" media="screen" />
	<script type="text/javascript">
		function changecss(theClass,element,value) {
			var cssRules;
			var added = false;
			for (var S = 0; S < document.styleSheets.length; S++){
	
		    if (document.styleSheets[S]['rules']) {
				cssRules = 'rules';
			} else if (document.styleSheets[S]['cssRules']) {
				cssRules = 'cssRules';
			}
			
			for (var R = 0; R < document.styleSheets[S][cssRules].length; R++) {
				if (document.styleSheets[S][cssRules][R].selectorText == theClass) {
					if(document.styleSheets[S][cssRules][R].style[element]){
						document.styleSheets[S][cssRules][R].style[element] = value;
						added=true;
						break;
					}
				}
			}
			if(!added){
				if(document.styleSheets[S].insertRule){
						document.styleSheets[S].insertRule(theClass+' { '+element+': '+value+'; }',document.styleSheets[S][cssRules].length);
					} else if (document.styleSheets[S].addRule) {
						document.styleSheets[S].addRule(theClass,element+': '+value+';');
					}
				}
			}	
		}	
	</script>
	</head>
	<body>
EOD;
	if (!isset($_GET['hide_tools'])) {
		echo "
		<span id=\"tools\">
		Tools:
			<button type='button' onclick=\"document.location='index.php?user={$_GET['user']}';\">&crarr; Back</button>
			<input type='button' onclick='document.getElementById(\"columnpasser\").style.display =\"inline\";this.style.display=\"none\";' value='Simple 1 Column View'/>
			<select style=\"display:none;\" id=\"columnpasser\" onchange=
			\"
				if (this.value != '') {
					document.location='build_document_descs_only.php?task_id={$_GET['task_id']}&user={$_GET['user']}&field=' + this.value;
				}
			\">
				<option value=\"\">Select A Field</option>
				<option value=\"functionality\">Functionality</option>
				<option value=\"developer\">Developer</option>
				<option value=\"file_name\">File Name</option>
				<option value=\"unit_test_pass_fail\">Pass/Fail</option>
				<option value=\"unit_test_expected_result\">Expected Result Description</option>
				<option value=\"unit_test_actual_result\">Actual Result Description</option>
				<option value=\"unit_test_inputs\">Inputs and Data</option>
				<option value=\"unit_test_remarks\">Remarks</option>
			</select>
			<input type='button' onclick='alert(\"Either print to PDF this page or\\n\\nHighlight the document and paste into word.\\n\\nYou lazy developer!!!\");' value='Export'/>
			<input type='button' onclick='document.getElementById(\"columnhider\").style.display =\"inline\";this.style.display=\"none\";' value='Hide A Column'/>
			<select style=\"display:none;\" id=\"columnhider\" onchange=
			\"
				if (this.value != '') {
					changecss('.col' + this.value,'display','none');
					alert('Removed ' + this.options[this.selectedIndex].text);
					this.options[this.selectedIndex] = null;
				}
			\">
				<option value=\"\">Select A Field</option>
				<option value=\"1\">Functionality</option>
				<option value=\"2\">Developer</option>
				<option value=\"3\">Functionality Number</option>
				<option value=\"4\">Pass/Fail</option>
				<option value=\"5\">Expected Result Description</option>
				<option value=\"6\">Actual Result Description</option>
				<option value=\"7\">Inputs and Data</option>
				<option value=\"8\">Screen Shot</option>
			</select>
			<input type='button' onclick='document.getElementById(\"columnpassfail\").style.display =\"inline\";this.style.display=\"none\";' value='View Pass/Fail' />
			<select style=\"display:none;\" id=\"columnpassfail\" onchange=
			\"
				if (this.value != '') {
					document.location='{$_SERVER['PHP_SELF']}?task_id={$_GET['task_id']}&user={$_GET['user']}&show_only=' + this.value;
				}
			\">
				<option value=\"\">Select A Status</option>
				<option value=\"All\">All</option>
				<option value=\"Pass\">Pass</option>
				<option value=\"Fail\">Fail</option>
				<option value=\"Other\">Other</option>
			</select>
			<input type='button' onclick='document.getElementById(\"columnwiki\").style.display =\"inline\";this.style.display=\"none\";' value='Generate Wiki'/>
			<select style=\"display:none;\" id=\"columnwiki\" onchange=
			\"
				if (this.value != '') {
					document.location='build_document_descs_only.php?task_id={$_GET['task_id']}&wiki=1&user={$_GET['user']}&field=' + this.value;
				}
			\">
				<option value=\"\">Select A Field</option>
				<option value=\"functionality\">Functionality</option>
				<option value=\"developer\">Developer</option>
				<option value=\"file_name\">File Name</option>
				<option value=\"unit_test_pass_fail\">Pass/Fail</option>
				<option value=\"unit_test_expected_result\">Expected Result Description</option>
				<option value=\"unit_test_actual_result\">Actual Result Description</option>
				<option value=\"unit_test_inputs\">Inputs and Data</option>
				<option value=\"unit_test_remarks\">Remarks</option>
			</select>
			<input type='button' onclick='document.getElementById(\"tools\").style.display = \"none\";window.print();' value='Print'/>
			<input type='button' onclick='document.getElementById(\"tools\").style.display = \"none\";' value='Hide'/>
		</span>
		<br/>
		<br/>
		";
	}
	$i=1;
	$funcSection = "";
	while($row = mysql_fetch_array($results)) {
		if ($i==1) {
			echo '<div class="title">Project: <strong>"'.$row['task_desc'].'"</strong></div>
			Table Of Contents:<br/>
			<ul>';
		}
		$allRows[] = $row;
		if ($funcSection != $row['functionality']) {
			echo "
				<li>
					<a href=\"#$i\">Section $i: <strong>".$row['functionality']."</strong></a>
				</li>";
			$i++;
		}
		$funcSection = $row['functionality'];
	}
	echo '</ul>';
	$i=1;
	$funcSection = "";
	
	if (is_array($allRows)) {
		foreach ($allRows as $key=>$row) {
			if ($funcSection != $row['functionality']) {
				$ii++;
				if ($i!=1) {
					echo "</tbody>
					</table><br/>";
				}
				
				echo "	<a id=\"$ii\" name=\"$ii\"></a>
						<table summary=\"Unit Test Document\">
							<caption>Testing: '".$row['functionality']."'</caption>
							<thead>
								<tr>
									<th scope=\"col\" class=\"col1\">Action</th>
									<th scope=\"col\" class=\"col1\">Functionality</th>
									<th scope=\"col\" class=\"col2\">Developer</th>
									<th scope=\"col\" class=\"col3\">Functionality<br/>Number</th>
									<th scope=\"col\" class=\"col4\">Pass/Fail</th>
									<th scope=\"col\" class=\"col5\">Expected Result Description</th>
									<th scope=\"col\" class=\"col6\">Actual Result Description</th>
									<th scope=\"col\" class=\"col7\">Inputs and Data</th>
									<th scope=\"col\" class=\"col8\">Screen Shot</th>
								</tr>
							</thead>
							<tbody>";
			}
			if (!empty($row['unit_test_remarks'])) {
				$remarks = "<span class=\"remark\">$ii.".$row['revision'].": <strong>\"".$row['unit_test_remarks']."\"</strong><span><br/>";
			} else {
				$remarks = "";
			}
			$trClass = ($i % 2) ? "class=\"odd\"" : "";
			if (stristr($row['file_name'],"png") || stristr($row['file_name'],"jpg") || stristr($row['file_name'],"gif")) {
				$objectHTML = "<img style=\"cursor:pointer\" onclick=\"window.open('".$pathToScreenshots.$row['file_name']."')\");\" src=\"".$pathToScreenshots.$row['file_name']."\"/>";
			} else {
				$objectHTML = "<input type=\"button\" onclick=\"document.location = 'download.php?file=".$row['file_name']."';\" value=\"Download ".$row['file_name']."\"/>";
			}
			
			if (strtoupper($row['unit_test_pass_fail']) == 'FAIL' || stristr($row['unit_test_pass_fail'],"fail")) {
				$extraCSS = "style=\"background-color:pink\"";
			} else {
				$extraCSS = "";
			}
			
			echo 
			"
			<tr $trClass $extraCSS>
				<th valign=\"top\" class=\"col1\" $extraCSS><a href=\"{$pathToInstall}manage_unit_tests/?action=update_unit_test_screenshots&unit_test_id={$row['unit_test_id']}\">(Edit)</a></th>
				<td scope=\"row\" class=\"col1\" id=\"r$i\" valign=\"top\" $extraCSS>".$row['functionality']."</td>
				<td valign=\"top\" class=\"col2\" $extraCSS>".$row['developer']."</td>
				<td valign=\"top\" class=\"col3\" $extraCSS>$ii.".$row['revision']."</td>
				<td valign=\"top\" class=\"col4\" $extraCSS>".str_replace("\n","<br/><br/>",$row['unit_test_pass_fail'])."</td>
				<td valign=\"top\" class=\"col5\" $extraCSS><strong style=\"font-weight:bold;font-size:11px;\">".str_replace("\n","<br/><br/>",$row['unit_test_expected_result'])."</strong></td>
				<td valign=\"top\" class=\"col6\" $extraCSS>".str_replace("\n","<br/><br/>",$row['unit_test_actual_result'])."</td>
				<td valign=\"top\" class=\"col7\" $extraCSS>".str_replace("\n","<br/><br/>",$row['unit_test_inputs'])."</td>
				<td valign=\"top\" class=\"col8\" $trClass  $extraCSS>
					$remarks
					$objectHTML
				</td>
			</tr>
			";
			$i++;
			$funcSection = $row['functionality'];
		}
	} else {
		echo "Nothing was found for this project and user combination";
	}
echo '
</body>
</html>
';
?>