<?php

/*
 * @file:    fetch_projects.php
 * @usage:   just either hard code a list of projects and add a new line ending between each one
 * @example: in this example, this integrates with billwerx invoices used as a task list
 */

/*
	# Include session check and database connection:
	include("../inc/dbconfig.php");

	# Get invoice data:
	$get_invoice = mysql_query("SELECT * FROM invoices");

	while($row = mysql_fetch_array($get_invoice)) {
		$get_client = mysql_query("SELECT * FROM clients WHERE client_id = " . $row['client_id'] . "");
		$show_client = mysql_fetch_array($get_client);
		echo $row['invoice_id']." - ".$row['purpose']." (".$show_client['company_name'].")\n";
	}
*/
	include("settings.php");

	$unitTestQuery =
	"
	SELECT
		DISTINCT
		tasks.task_desc
	FROM
		unit_test_screenshots units,
		unit_test_screenshots_tasks tasks
	WHERE
		units.task_pk = tasks.task_pk AND
		tasks.task_desc <> 'Unit Test Screen Tagger Help'
	ORDER BY
		units.functionality, units.unit_test_time
	";
	$results = mysql_query($unitTestQuery);
	while($row = mysql_fetch_array($results)) {
		echo $row['task_desc']."\n";
	}
	mysql_data_seek($results,0);
?>