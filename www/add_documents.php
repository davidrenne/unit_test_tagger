<?

/*
 * @file:    add_documents.php
 * @info:    an example page that the Unit Test Screen Tagger passes all its data to where you integrate other things to
 * @also:    if you dont want your desktops to have to install mySQL ODBC connector, this is a way that the program can insert mySQL data with out the thick client app doing it
 */

include("settings.php");
echo "start transaction\r\n\r\n";
error_log(print_r($_GET,true));
print_r($_GET);
echo "\r\n\r\n";
echo "Running Queries:";
echo "\r\n\r\n";
$theQuery = "SELECT * FROM `unit_test_screenshots_tasks` WHERE task_desc = '" . mysql_real_escape_string(str_replace("My Projects:","",$_REQUEST['project'])) . "'";
$findProjectDesc = mysql_query($theQuery);
$results = mysql_fetch_array($findProjectDesc);
echo "Find desc:".$theQuery ."\r\n\r\n";
if (empty($results)) {
	$theQuery = "INSERT INTO `unit_test_screenshots_tasks` (`task_desc`) VALUES ('" . mysql_real_escape_string($_REQUEST['project']) . "')";
	mysql_query($theQuery);
	echo "None found Insert:".$theQuery ."\r\n\r\n";
	$findProjectDesc = mysql_query("SELECT * FROM `unit_test_screenshots_tasks` WHERE task_desc = '" . mysql_real_escape_string($_REQUEST['project']) . "'");
	$results = mysql_fetch_array($findProjectDesc);
	echo "Selecting new inserted record:".$theQuery ."\r\n\r\n";
}
$taskId = $results['task_pk'];
$theQuery = "INSERT INTO `unit_test_screenshots` (`task_pk`,`developer`,`functionality`,`unit_test_expected_result`,`unit_test_remarks`,`unit_test_actual_result`,`unit_test_inputs`,`unit_test_pass_fail`,`revision`,`file_name`,`unit_test_time`) VALUES ($taskId,'" . mysql_real_escape_string($_REQUEST['user']) . "','" . mysql_real_escape_string($_REQUEST['functionality']) . "','" . mysql_real_escape_string(str_replace("{LINE}","\n",$_REQUEST['unit_test_expected_result'])) . "','" . mysql_real_escape_string($_REQUEST['unit_test_remarks']) . "','" . mysql_real_escape_string($_REQUEST['unit_test_actual_result']) . "','" . mysql_real_escape_string($_REQUEST['unit_test_inputs']) . "','" . mysql_real_escape_string($_REQUEST['unit_test_pass_fail']) . "','" . mysql_real_escape_string($_REQUEST['revision']) . "','" . mysql_real_escape_string($_REQUEST['file_name']) . "',NOW())";
mysql_query($theQuery);
echo "Inserting screenshot:".$theQuery ."\r\n\r\n";
// -- billwerx integration
/*list($invoiceID,$invoiceDescs) = explode(" - ", $_REQUEST['project']);
# Get invoice data:
$invoiceID = trim($invoiceID);
$get_invoices = mysql_query("SELECT * FROM invoices WHERE invoice_id = '$invoiceID'");
echo "SELECT * FROM invoices WHERE invoice_id = '$invoiceID'";
while($show_invoice = mysql_fetch_array($get_invoices)) {
	$get_client = mysql_query("SELECT * FROM clients WHERE client_id = " . $show_invoice['client_id'] . "");
	$show_client = mysql_fetch_array($get_client);
	$get_invoice_items = mysql_query("SELECT * FROM invoice_items WHERE invoice_id = '$invoiceID' AND description = '".mysql_real_escape_string($_REQUEST['functionality'])."'");
	var_dump(mysql_num_rows($get_invoice_items));
	if (mysql_num_rows($get_invoice_items) == 0) {
		$query = "INSERT INTO `invoice_items` (`invoice_id`,`category_id`,`name`,`description`,`cost`,`price`) VALUES ('$invoiceID','2','CODING - ".date('m-d-Y')."','".mysql_real_escape_string($_REQUEST['functionality'])."',30,".number_format($show_client['payment_terms'],2).")";
		mysql_query($query);
	}
	if ($_REQUEST['unit_test_pass_fail'] != 'None') {
		// -- update hours and prices

		$get_invoice_items = mysql_query("SELECT * FROM invoice_items WHERE invoice_id = '$invoiceID' AND description = '".mysql_real_escape_string($_REQUEST['functionality'])."'");
		$show_invoice_items = mysql_fetch_array($get_invoice_items);
		$newQuantity = $show_invoice_items['quantity'] + $_REQUEST['unit_test_pass_fail'];
		$newPrice = $show_invoice_items['price'] * $newQuantity + $show_invoice_items['extended'];
		$query = "UPDATE `invoice_items` SET quantity = $newQuantity, extended=$newPrice WHERE invoice_item_id = '{$show_invoice_items['invoice_item_id']}'";
		mysql_query($query);


		# Calulate invoice amounts:
		$subtotal = $show_invoice['subtotal'] + $newPrice;
		$total =  $subtotal;
		$due = $total - $show_invoice['received'];

		# Update the balance of the invoice table:
		$doSQL = "UPDATE invoices SET subtotal = '$subtotal', total = '$total', total_cost = '$total_cost', due = '$due' WHERE invoice_id = '$invoiceID'";
		mysql_query($doSQL);

	}

}*/
?>