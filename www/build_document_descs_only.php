<?php

/*
 * @file:    build_document_descs_only.php
 * @info:    is a plain document which needs to pass 1 field/column to show with the screenshots
 */

   require_once("settings.php");

   $asc = ($_GET['by_date']) ? "desc" : "";
   $by_task = ($_GET['by_date']) ? "units.unit_test_time BETWEEN '".date("Y-m-d",strtotime($_GET['by_date']))." 00:00:00' AND '".date("Y-m-d",strtotime($_GET['by_date']." +1 day"))." 00:00:00' AND " : "units.task_pk = '".$_GET['task_id']."' AND";
   $title = ($_GET['by_date']) ? "Screenshots for ".date("Y-m-d",strtotime($_GET['by_date'])) : "Unit Tests For Project {$_GET['task_id']}";

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
      tasks.task_pk, units.unit_test_time, units.functionality $asc
   ";
   $results = mysql_query($unitTestQuery);
   $count = mysql_num_rows($results);
   if (empty($_GET['field'])) {
      die('No Field Passed');
   }

   $unitTestQuery =
   "
   SELECT
      distinct
      DATE_FORMAT(units.unit_test_time,'%Y-%m-%d') as days
   FROM
      unit_test_screenshots units,
      unit_test_screenshots_tasks tasks
   WHERE
      units.task_pk = tasks.task_pk AND
      units.developer = '".$_GET['user']."'
   ";
   $results2 = mysql_query($unitTestQuery);
   $reportDate = date("Y-m-d",strtotime($_GET['by_date']));
   $options = "<option value=\"\">Select a Date</option>";
   while($row2 = mysql_fetch_array($results2)) {
      $selected = "";
      if (strtotime($reportDate) == strtotime($row2['days'])) {
         $selected = "selected";
      }
      $options .= "<option $selected value=\"{$row2['days']}\">{$row2['days']}</option>";
   }
   $selectDates = '<select id="" onchange="if(this.value){document.location = \'build_document_descs_only.php?by_date=\' + this.value + \'&user='.$_GET['user'].'&field='.$_GET['field'].'\'};">'.$options.'</select>';

   if (!$count) {
      if ($_GET['by_date']) {
         die('No Screenshot descriptions found for '.$_GET['by_date'].' and user \''.$_GET['user'].'\' (View Other Dates '.$selectDates.')');
      } else {
         die('No data found');
      }
   }

   if ($_GET['task_id']) {
      $byDateOrTask = "task_id={$_GET['task_id']}";
   } else {
      $byDateOrTask = "by_date={$_GET['by_date']}";
   }

   echo <<<EOD
   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
   <html xmlns="http://www.w3.org/1999/xhtml">
   <head>
   <link rel="alternate" type="application/rss+xml" title="RSS-Feed" href="build_rss.php?{$byDateOrTask}&user={$_GET['user']}&field={$_GET['field']}" />
   <title>$title</title>
   <meta http-equiv="Content-Language" content="English" />
   <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
   <style type="text/css">
      hr {
         background-color:darkred;
         height:1px;
         width:100%;
         border-style:dotted;
      }
   </style>

   </style>
   </head>
   <body>
EOD;
   $i=1;
   $funcSection = "";
   $out .= (!isset($_GET['wiki'])) ? "" : "This wiki file was auto-generated by {$_GET['user']} on ".date("m/d/Y")." from the [[Unit Test Tagger Utility]] located here:\n\n[http://webdev.healthplan.com/unit_tests/build_document.php?user=ALL&task_id=1 View UnitTestTagger Info/Help]\n\n[http://webdev.healthplan.com/unit_tests/build_document.php?user={$_GET['user']}&task_id={$_GET['task_id']} View Full Document]\n\n";

   while($row = mysql_fetch_array($results)) {
      if ($i==1) {
         if (isset($_GET['appendix'])) {
            $desc1 = "Appendix A ";
            $desc2 = " for \"{$row['task_desc']}\"";
         }
         if ($_GET['by_date']) {
            $out .= (!isset($_GET['wiki'])) ? '<h2>Screenshots for '.$_GET['user'].' on '.$selectDates.'</h2>
            '.$desc1.'Table Of Contents'.$desc2.':<br/>
            <ul>' : "== ".$row['task_desc']." ==\n\n" ;
         } else {
            $out .= (!isset($_GET['wiki'])) ? '<h2>Project: <strong>"'.$row['task_desc'].'"</strong></h2>
            '.$desc1.'Table Of Contents'.$desc2.':<br/>
            <ul>' : "== ".$row['task_desc']." ==\n\n" ;
         }
      }
      $allRows[] = $row;
      if ($funcSection != $row['functionality']) {
         if (!$_GET['by_date']) {
            $section = "Section $i: ";
         }

         $functionality = ($_GET['by_date']) ? $row['task_desc'].' - '.$row['functionality'] : $row['functionality'];

         if (!isset($_GET['hide_edit'])) {
            $st = "<a href=\"#$i\">";
            $end = "</a>";
         }
         $out .= (!isset($_GET['wiki'])) ?  "
            <li>
               $section<strong>".$functionality."</strong>
            </li>" : "";
         $i++;
      }
      $funcSection = $row['functionality'];
   }
   $out .= (!isset($_GET['wiki'])) ? "</ul>" : "";
   $i=1;
   $funcSection = "";
   foreach ($allRows as $key=>$row) {
      if ($funcSection != $row['functionality']) {
         $ii++;
         if ($i!=1) {
            $out .= (!isset($_GET['wiki'])) ?  "</tbody>
            </table>" : "";
         }
         $out .= (!isset($_GET['wiki'])) ?  "<h1>".$row['functionality']."</h1>" : "== ".$row['functionality']." ==\n";

         $out .= (!isset($_GET['wiki'])) ?  "
            <a id=\"$ii\" name=\"$ii\"></a>
               <table summary=\"Unit Test Document\">" : "";
      }
      if (!empty($row[$_GET['field']])) {
         if (!$_GET['by_date']) {
            $identifier = "$ii.".$row['revision'];
         } else {
            $identifier = $row['time'];
         }
         if (!isset($_GET['hide_edit'])) {
            $editLink = "<a href=\"{$pathToInstall}manage_unit_tests/?action=update_unit_test_screenshots&unit_test_id={$row['unit_test_id']}\">(Edit)</a>";
         }
         $remarks = (!isset($_GET['wiki'])) ?  "<span class=\"remark\">".$identifier." $editLink : <strong>".str_replace("\n","<br/>",$row[$_GET['field']])."</strong><span><br/>" : "$ii.".$row['revision'].": <strong>".$row[$_GET['field']]."</strong>";
      } else {
         $remarks = "";
      }
      $trClass = ($i % 2) ? "class=\"odd\"" : "";
      if (stristr($row['file_name'],"png") || stristr($row['file_name'],"jpg") || stristr($row['file_name'],"gif")) {
         $objectHTML = (!isset($_GET['wiki'])) ?  "<img style=\"cursor:pointer;margin-left: 40px;\" onclick=\"window.open('".$pathToScreenshots.$row['file_name']."')\");\" src=\"".$pathToScreenshots.$row['file_name']."\"/>" : $pathToScreenshots.$row['file_name']."\n";
      } else {
         if (file_exists(dirname(__FILE__)."/".$relativePathToScreenshots.$row['file_name']) && !empty($row['file_name'])) {
         $objectHTML = (!isset($_GET['wiki'])) ?  "<input type=\"button\" onclick=\"document.location = '".$pathToInstall."download.php?file=".$row['file_name']."';\" value=\"Download ".$row['file_name']."\"/>" : "[{$pathToInstall}download.php?file={$row['file_name']} Download {$row['file_name']}]";
         }
      }


      if (!isset($_GET['hide_edit'])) {
         $hr = "<hr/>";
      }
      $out .= (!isset($_GET['wiki'])) ?
      "
      <tr $trClass>
         <td valign=\"top\" $trClass>
            $remarks
            $objectHTML
            $hr
            <br/><br/><br/><br/>
         </td>
      </tr>
      " : "$remarks\n\n$objectHTML\n";
      $i++;
      $funcSection = $row['functionality'];
   }

   if ($_GET['wiki']) {
      echo "<h2>Copy and Paste Wiki Code Into Article</h2><textarea style=\"width:95%;height:500px;border:2px black solid;\">$out</textarea>";
   } else {
      echo $out;
   }

   echo "
   </body>
   </html>";
?>