<?php

$cruddyMysqlConfiguration  = array (
  'crud' => 
  array (
    'console_name' => '',
    'mysql_databases' => NULL,
    'completed_step' => 'All',
    'theme' => 'None',
    'functionsfile_mtime' => 1273455866,
    'drawfile_mtime' => 1273455866,
  ),
  'crudConfig' => 
  array (
    'unit_test_screenshots' => 
    array (
      'tableDef' => 
      array (
        'actions' => 
        array (
          'new' => 'new_',
          'delete' => 'delete_',
          'update' => 'update_',
          'read' => 'show_',
          'view' => 'view_',
          'order_field' => 'sort_by',
          'order_direction' => 'direction',
          'page' => 'page',
        ),
        'table' => 'unit_test_screenshots',
        'description' => 'Unit Tests',
        'primarykey' => 'unit_test_id',
        'editlink' => '?action=update_unit_test_screenshots&unit_test_id=%unit_test_id%',
        'deletelink' => '?action=delete_unit_test_screenshots&unit_test_id=%unit_test_id%',
        'otherlinks' => '',
        'configuredfields' => '1',
        'edittext' => 'Edit',
        'deletetext' => 'Delete',
        'hideviewlink' => '1',
        'pagingenabled' => '1',
        'requiredtext' => '*',
        'pagingrows' => '10',
        'pagingscroll' => '5',
      ),
      'unit_test_id' => 
      array (
        'caption' => 'Unit Test ID',
        'ronlyupdate' => '1',
        'inserthide' => '1',
        'sortable' => '1',
      ),
      'developer' => 
      array (
        'caption' => 'Dev Name',
        'showcolumn' => '1',
        'required' => '1',
        'lookuptable' => 'unit_test_screenshots',
        'lookupid' => '___distinct___lookup___developer',
        'lookuptext' => '___distinct___lookup___developer',
        'posttextc' => '(Add new by using different windows user accounts and using unit test screen tagger)',
        'sortable' => '1',
      ),
      'task_pk' => 
      array (
        'caption' => 'Task Description',
        'showcolumn' => '1',
        'required' => '1',
        'lookuptable' => 'unit_test_screenshots_tasks',
        'lookupid' => 'task_pk',
        'lookuptext' => 'task_desc',
        'sortable' => '1',
      ),
      'functionality' => 
      array (
        'caption' => 'Functionality Section',
        'showcolumn' => '1',
        'required' => '1',
        'lookuptable' => 'unit_test_screenshots',
        'lookupid' => '___distinct___lookup___functionality',
        'lookuptext' => '___distinct___lookup___functionality',
        'sortable' => '1',
      ),
      'file_name' => 
      array (
        'caption' => 'File Name',
        'showcolumn' => '1',
        'sortable' => '1',
      ),
      'revision' => 
      array (
        'caption' => 'Revision',
        'showcolumn' => '1',
        'sortable' => '1',
      ),
      'unit_test_expected_result' => 
      array (
        'caption' => 'Expected Result/Descripton',
        'showcolumn' => '1',
        'sortable' => '1',
      ),
      'unit_test_actual_result' => 
      array (
        'caption' => 'Actual Result',
        'sortable' => '1',
      ),
      'unit_test_inputs' => 
      array (
        'caption' => 'Inputs And Outputs',
        'sortable' => '1',
      ),
      'unit_test_remarks' => 
      array (
        'caption' => 'Remarks',
        'sortable' => '1',
      ),
      'unit_test_pass_fail' => 
      array (
        'caption' => 'Pass/Fail',
        'showcolumn' => '1',
        'lookuptable' => 'unit_test_screenshots',
        'lookupid' => '___distinct___lookup___unit_test_pass_fail',
        'lookuptext' => '___distinct___lookup___unit_test_pass_fail',
        'sortable' => '1',
      ),
      'unit_test_time' => 
      array (
        'caption' => 'Time',
        'showcolumn' => '1',
        'sortable' => '1',
      ),
      'unit_test_id_config' => 
      array (
        'TYPE' => 'text',
      ),
      'developer_config' => 
      array (
        'TYPE' => 'select',
      ),
      'task_pk_config' => 
      array (
        'TYPE' => 'select',
      ),
      'functionality_config' => 
      array (
        'TYPE' => 'select',
      ),
      'file_name_config' => 
      array (
        'TYPE' => 'file',
        'MOVE_TO' => '../screenshots/',
      ),
      'revision_config' => 
      array (
        'TYPE' => 'text',
      ),
      'unit_test_expected_result_config' => 
      array (
        'TYPE' => 'textarea',
      ),
      'unit_test_actual_result_config' => 
      array (
        'TYPE' => 'textarea',
        'VALUE' => 'Results Were As Expected',
      ),
      'unit_test_inputs_config' => 
      array (
        'TYPE' => 'textarea',
        'VALUE' => 'Typical Input For Screen',
      ),
      'unit_test_remarks_config' => 
      array (
        'TYPE' => 'textarea',
      ),
      'unit_test_pass_fail_config' => 
      array (
        'TYPE' => 'textarea',
        'VALUE' => 'Pass',
      ),
      'unit_test_time_config' => 
      array (
        'TYPE' => 'timestamp',
      ),
    ),
  ),
);

?>