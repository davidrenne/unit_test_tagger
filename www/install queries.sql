
-- --------------------------------------------------------

-- 
-- Table structure for table `unit_test_screenshots`
-- 
CREATE TABLE IF NOT EXISTS `unit_test_screenshots` (
  `unit_test_id` int(11) NOT NULL AUTO_INCREMENT,
  `developer` varchar(20) NOT NULL,
  `task_pk` int(11) NOT NULL,
  `functionality` varchar(255) NOT NULL,
  `file_name` varchar(500) NOT NULL,
  `revision` int(11) NOT NULL,
  `unit_test_expected_result` mediumtext NOT NULL,
  `unit_test_actual_result` mediumtext NOT NULL,
  `unit_test_inputs` mediumtext NOT NULL,
  `unit_test_remarks` mediumtext NOT NULL,
  `unit_test_pass_fail` varchar(20) NOT NULL,
  `unit_test_time` datetime NOT NULL,
  PRIMARY KEY (`unit_test_id`),
  KEY `developer` (`developer`,`task_pk`)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=latin1 AUTO_INCREMENT=0 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `unit_test_screenshots_tasks`
-- 

CREATE TABLE IF NOT EXISTS `unit_test_screenshots_tasks` (
  `task_pk` int(11) NOT NULL AUTO_INCREMENT,
  `task_desc` varchar(255) NOT NULL,
  PRIMARY KEY (`task_pk`)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=latin1 AUTO_INCREMENT=0 ;


INSERT INTO `unit_test_screenshots` (`developer`, `task_pk`, `functionality`, `file_name`, `revision`, `unit_test_expected_result`, `unit_test_actual_result`, `unit_test_inputs`, `unit_test_remarks`, `unit_test_pass_fail`, `unit_test_time`) VALUES 
('ALL', 1, 'Using The Unit Test Tagger', 'Unit Test Screen Tagger.exe', 0, 'First download this executable into a folder (also click the other two buttons for the dependent DLL file and ini file).', 'Double Click on the executable', 'Double Click on the executable to get started', '', 'Pass', '2010-02-19 14:24:54'),
('ALL', 1, 'Using The Unit Test Tagger', 'screenshot_02-19-2010_14-21-28.png', 1, 'When you first run the program, a popup will tell you that you can take new screenshots by holding CTRL plus clicking the middle click.\r\n\r\nBut in reality you can either HOLD ALT,WIN or SHIFT while doing this action.', 'Program is booting up as expected.\r\n\r\nThe program will install a short cut link inside your Startup folder so that the program runs when you restart.', 'Double Click on the executable', 'Double Click on the executable to get started', 'Pass', '2010-02-19 14:24:56'),
('ALL', 1, 'Using The Unit Test Tagger', 'screenshot_02-19-2010_14-26-30.png', 2, 'Here is the popup that was expected in this unit test.', 'Results Were As Expected', 'Typical Input For Screen', '', 'Pass', '2010-02-19 14:27:18'),
('ALL', 1, 'Using The Unit Test Tagger', 'screenshot_02-19-2010_14-32-42.png', 3, 'You can right or left click this icon to get the menu of things to do:\r\n\r\nIf you compiled your instance to be a web-based MYSQL (Recomended).  You can view the web instance at the top of this menu.\r\n\r\nEmbed a file will upload your selected file to the unit test documentor website or will embed it inside the Rich Text Document.\r\n\r\nCopy last file to clipboard is useful when you dont want to tag the item, so you close the Functionality/Unit Test information and just copy it.\r\n\r\nCapture entire screen you can do through the context, or can press CTRL or SHIFT or WIN and the PRINT SCREEN button.', 'Menu showed when I clicked it', 'Right or Left Click', 'You can right or left click this icon to get the menu of things to do', 'Pass', '2010-02-19 14:36:55'),
('ALL', 1, 'Using The Unit Test Tagger', 'screenshot_02-19-2010_14-37-21.png', 4, 'Start from the TOP LEFT hand corner of the region on your desktop.  And then drag your mouse diagonally downward toward the bottom right hand corner of the monitor.\r\n\r\nYou will notice the screen will have a transparent overlay with the dimensions of your screenshot.\r\n\r\nUpon letting go this form will popup.\r\n\r\nThe required fields are (Project/Functionality and Expected Result).\r\n\r\nYou can set the additional data as well as Pass/Fail/Set the task to In Work', 'Form pops up after taking a screen shot', 'Fill out the unit test form', 'After clicking Add To Database or Add to Daily document, a success popup will show up.', 'Pass', '2010-02-19 14:42:56'),
('ALL', 1, 'Using The Unit Test Tagger', 'screenshot_02-19-2010_14-47-48.png', 5, 'Each day, your screenshots go into a new folder inside of:\r\n\r\nC:\\UnitTests\r\n\r\nA Temp folder is created when you have your program compiled for local screenshots only.\r\n\r\nA tasks.txt file is loaded through the InetGet call to your webserver which serves up your project listings via line ending delimited projects. (This will be fetched each time you take a screenshot)\r\n\r\nThe UnitTestsScreenCaptures.ini file contains all your settings, screenshot history and functional sections of a project that you are organizing these screens and unit tests.\r\n\r\nThese screenshots are uploaded to the FTP you define when you compile your version of the program.\r\n\r\nMySQL records are inserted as you take the screenshot.', 'Files and folders are organized into C:\\UnitTests', 'None, windows takes care of the inputs', 'C:\\UnitTests stores all of your local copies of the files', 'Pass', '2010-02-19 14:51:37'),
('ALL', 1, 'Using the Web Interface', 'screenshot_02-19-2010_14-56-39.png', 1, 'The web interface (when you click from within the menu on the system tray).\r\n\r\nIt will pass a USER to the index.php.  This essentially logs you in automatically.\r\n\r\nThere are no passwords in this system as these documents are mostly public anyways.\r\n\r\nJust click on your project to view the full unit test document.', 'I got logged in just fine.', 'Your username that matches your current windows login.', 'This is the home page which is just a simple listing of all the distinct projects that have screenshots.', 'Pass', '2010-02-19 15:11:46'),
('ALL', 1, 'Using the Web Interface', 'screenshot_-_using_the_web_interface__-_drenne_-_1.2_02-19-2010_15-1204.png', 2, 'If you go directly to the interface you will be asked for your username.', 'Results Were As Expected', 'Your username', 'Enter your username if you just try to go to the interface.  YES JAVASCRIPT POPUPS are ghetto, but you gotta give em some love....', 'Pass', '2010-02-19 15:12:56'),
('ALL', 1, 'Using the Web Interface', 'screenshot_-_using_the_web_interface__-_drenne_-_1.3_02-19-2010_15-1310.png', 3, 'The main content shows all your information you posted in the popup.', 'The link got me to the detailed document', 'Click the damn link', 'Detailed view of website', 'Pass', '2010-02-19 15:13:56'),
('ALL', 1, 'Using the Web Interface', 'screenshot_02-19-2010_15-34-14.png', 4, 'If you do not have any screenshots matching the username you will see this screen where you can download the program or view this help file', 'Page showed up.', 'Click the buttons', 'If you do not have any screenshots matching the username you will see this screen where you can download the program or view this help file', 'Pass', '2010-02-19 15:35:21'),
('ALL', 1, 'Using the Web Interface', 'screenshot_02-19-2010_15-36-15.png', 5, 'As you can see in the Table of Contents, it fetches the unique listing of Functionalities that are a part of your project and groups them.\r\n\r\nThese links are click-a-ble to jump to each section.', 'Sections grouped accordingly', 'Click the anchor', 'Sections grouped accordingly', 'Pass', '2010-02-19 15:37:25'),
('ALL', 1, 'Using the Web Interface', 'screenshot_-_using_the_web_interface__-_drenne_-_1.6_02-19-2010_15-3734.png', 6, 'Embedded files show up as a button to download.', 'Results Were As Expected', 'Embedded files show up as a button to download.', 'Embedded files show up as a button to download.', 'Pass', '2010-02-19 15:37:51'),
('ALL', 1, 'Using the Web Interface', 'screenshot_02-19-2010_16-26-48.png', 7, 'At the top of each document you have a tool section.  \r\n\r\nSimple 1 Column View will allow you to select a field to show in conjunction with the image in a more plain white document.\r\n\r\nExport,  pops up a sny remark.\r\n\r\nHide a Column, will allow multiple fields to be selected and hidden from the current view.\r\n\r\nPrint, obvious\r\n\r\nHide, hides the toolbar from the view', 'Tools displays on each document.', 'Click a button', 'Tools displays on each document.', 'Pass', '2010-02-19 16:29:48'),
('ALL', 1, 'Using the Web Interface', 'screenshot_02-19-2010_16-31-05.png', 8, 'Selecting the Simple 1 Column View button will not stylize the document and is useful for copying and pasting the tables into word.', 'Results Were As Expected', 'Click Plain  W/1 Field', '', 'Pass', '2010-02-19 16:32:01'),
('ALL', 1, 'Using the Web Interface', 'screenshot_02-19-2010_16-33-11.png', 9, 'When you do copy and paste the document into word.\r\n\r\nUsually you need to pull the margin of the document all the way to the LEFT.\r\n\r\nSo that the full image can be shown up.\r\n\r\nYou may need to re-adjust the dimensions of the images because the web interface does not auto-size them less than 7 inches yet. ', 'Pastes into word beautifully!', 'COPY and PASTE into WORD', 'COPY and PASTE into WORD', 'Pass', '2010-02-19 16:36:07'),
('ALL', 1, 'Using the Web Interface', 'unittestscreentagger.doc', 10, 'Check out the sweet word document pasted from the HTML.', 'Results Were As Expected', 'Word', 'Word Doc', 'Pass', '2010-02-19 16:39:21'),
('ALL', 1, 'Using the Web Interface', 'screenshot_02-19-2010_16-40-58.png', 11, 'If you dont like this program or use it every day you FAIL.', 'FAIL', 'FAIL', 'FAIL', 'Fail', '2010-02-19 16:42:20');

INSERT INTO `unit_test_screenshots_tasks` ( `task_pk` , `task_desc` )
VALUES (
'1', 'Unit Test Screen Tagger Help'
);
