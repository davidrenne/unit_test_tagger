#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <SendMessage.au3>
Global Const $LoadAutoit_RichEditCtrl = WINAPILoadLibrary("Autoit_RichEditCtrl.dll")
Global Const  $Autoit_RichEditCtrl = DllOpen("Autoit_RichEditCtrl.dll")

;MFC Library Reference
;CRichEditCtrl Members
; http://msdn.microsoft.com/en-us/library/y4bx8s3h(VS.80).aspx


Func RichEditCreate($dwStyle, $L , $T , $W , $H , $hGUI, $nID)
If $dwStyle = 0 Then $dwStyle = BitOR($WS_CHILD,$WS_BORDER,$WS_VSCROLL,$WS_VISIBLE,$ES_MULTILINE,$ES_AUTOVSCROLL,$ES_WANTRETURN)
$DllCall = DllCall($Autoit_RichEditCtrl , "hwnd:cdecl" , "RichEditCreate" , "long" , $dwStyle , "int" ,$L _
, "int" , $T , "int" , $W , "int" , $H , "hwnd" , $hGUI , "int" , $nID)
Return $DllCall[0] ; Return EditSafeHwnd
EndFunc

Func LoadFile($EditSafeHwnd , $sFileName = "" , $nFormat = 2  )
;The value of nFormat must be one of the following
;SF_TEXT = 1  Indicates reading text only.
;SF_RTF  = 2 Indicates reading text and formatting.
; http://msdn.microsoft.com/en-us/library/h2hkhzhe.aspx

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "LoadFile" ,"hwnd" , $EditSafeHwnd , "str" ,$sFileName, "int" , $nFormat)
Return $DllCall[0] ; ; Return Number of characters read from the input stream

EndFunc

Func SaveFile($EditSafeHwnd , $sFileName = "" , $nFormat = 2  )
;The value of nFormat must be one of the following:
;SF_TEXT  = 1 Indicates writing text only.
;SF_RTF  = 2 Indicates writing text and formatting.
;SF_RTFNOOBJS   Indicates writing text and formatting, replacing OLE items with spaces.
;SF_TEXTIZED   Indicates writing text and formatting, with textual representations of OLE items
;http://msdn.microsoft.com/en-us/library/b0k0ywek.aspx

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "SaveFile" ,"hwnd" , $EditSafeHwnd , "str" ,$sFileName, "int" , $nFormat)
Return $DllCall[0] ; Return Number of characters written to the output stream

EndFunc

Func InsertObject($EditSafeHwnd ,$sFileName)
$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "InsertObject" ,"hwnd" , $EditSafeHwnd , "str" ,$sFileName)
Return $DllCall[0] ; Return BOLL
EndFunc




Func SetString($EditSafeHwnd , $String = "" , $flags = 0 , $codepage = 0)
$EM_SETTEXTEX = $WM_USER + 97
;$String ==> SF_RTF Or SF_TEXT
;flags
;Option flags. It can be any reasonable combination of the following flags.
;ST_DEFAULT = 0
;Deletes the undo stack, discards rich-text formatting, replaces all text.
;ST_KEEPUNDO
;Keeps the undo stack.
;ST_SELECTION
;Replaces selection and keeps rich-text formatting.
;codepage
;The code page used to translate the text to Unicode. If codepage is 1200 (Unicode code page),
;no translation is done. If codepage is CP_ACP, the system code page is used
; http://msdn.microsoft.com/en-us/library/bb787954(VS.85).aspx
; http://msdn.microsoft.com/en-us/library/bb787954(VS.85).aspx
$struct_settextex = "dword flags;int codepage;"
$structCreate = DllStructCreate($struct_settextex)
DllStructSetData($structCreate ,"flags",$flags)
DllStructSetData($structCreate ,"codepage",$codepage )
$tBuffer = DllStructCreate("char Text[" & StringLen($String) + 1 & "]")
DllStructSetData($tBuffer, 1, $String)
$pBuffer = DllStructGetPtr($tBuffer)
Return _SendMessage($EditSafeHwnd, $EM_SETTEXTEX , DllStructGetPtr($structCreate),$pBuffer)
EndFunc




Func GetString($EditSafeHwnd)
;String ==> SF_TEXT Only
;http://msdn.microsoft.com/en-us/library/ms632627(VS.85).aspx
$TextLength = GetTextLength($EditSafeHwnd)
$tBuffer = DllStructCreate("char Text[" & $TextLength + 1 & "]")
$pBuffer = DllStructGetPtr($tBuffer)
_SendMessage($EditSafeHwnd, $WM_GETTEXT , $TextLength + 1 ,$pBuffer)
Return DllStructGetData($tBuffer ,1)
EndFunc



;---------------------------------------------------------------------------------------------------------------------------------
;MFC Library Reference
;CRichEditCtrl Members
; http://msdn.microsoft.com/en-us/library/y4bx8s3h(VS.80).aspx

Func CanPaste($EditSafeHwnd , $UINT_nFormat = 0)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "CanPaste" ,"hwnd" , $EditSafeHwnd , "int" , $UINT_nFormat = 0)
Return $DllCall[0]

EndFunc


Func CanUndo($EditSafeHwnd)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "CanUndo" ,"hwnd" , $EditSafeHwnd)
Return $DllCall[0]

EndFunc


Func Clear($EditSafeHwnd)

$DllCall = DllCall( $Autoit_RichEditCtrl , "none:cdecl" , "Clear" ,"hwnd" , $EditSafeHwnd)


EndFunc


Func Copy($EditSafeHwnd)

$DllCall = DllCall( $Autoit_RichEditCtrl , "none:cdecl" , "Copy" ,"hwnd" , $EditSafeHwnd)


EndFunc


Func Cut($EditSafeHwnd)

$DllCall = DllCall( $Autoit_RichEditCtrl , "none:cdecl" , "Cut" ,"hwnd" , $EditSafeHwnd)


EndFunc


Func DisplayBand($EditSafeHwnd , $LPRECT_pDisplayRect)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "DisplayBand" ,"hwnd" , $EditSafeHwnd , "ptr" , $LPRECT_pDisplayRect)
Return $DllCall[0]

EndFunc


Func EmptyUndoBuffer($EditSafeHwnd)

$DllCall = DllCall( $Autoit_RichEditCtrl , "none:cdecl" , "EmptyUndoBuffer" ,"hwnd" , $EditSafeHwnd)


EndFunc


Func FindText($EditSafeHwnd , $DWORD_dwFlags , $FINDTEXTEX_pFindText)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "findText" ,"hwnd" , $EditSafeHwnd , "long" , $DWORD_dwFlags , "ptr" , $FINDTEXTEX_pFindText)
Return $DllCall

EndFunc


Func FormatRange($EditSafeHwnd , $FORMATRANGE_pfr , $BOOL_bDisplay = TRUE)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "ptr" ,"hwnd" , $EditSafeHwnd , "ptr" , $FORMATRANGE_pfr , "int" , $BOOL_bDisplay )
Return $DllCall[0]

EndFunc


Func GetEventMask($EditSafeHwnd)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "GetEventMask" ,"hwnd" , $EditSafeHwnd)
Return $DllCall[0]

EndFunc


Func GetFirstVisibleLine($EditSafeHwnd)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "GetFirstVisibleLine" ,"hwnd" , $EditSafeHwnd)
Return $DllCall[0]

EndFunc


Func GetLimitText($EditSafeHwnd)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "GetLimitText" ,"hwnd" , $EditSafeHwnd)
Return $DllCall[0]

EndFunc


Func GetLine($EditSafeHwnd , $int_nIndex , $LPTSTR_lpszBuffer , $int_nMaxLength)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "GetLine" ,"hwnd" , $EditSafeHwnd , "int" , $int_nIndex , "ptr" , $LPTSTR_lpszBuffer , "int" , $int_nMaxLength)
Return $DllCall[0]

EndFunc


Func GetLineCount($EditSafeHwnd)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "GetLineCount" ,"hwnd" , $EditSafeHwnd)
Return $DllCall[0]

EndFunc


Func GetModify($EditSafeHwnd)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "GetModify" ,"hwnd" , $EditSafeHwnd)
Return $DllCall[0]

EndFunc


Func GetParaFormat($EditSafeHwnd , $PARAFORMAT_pf)

$DllCall = DllCall( $Autoit_RichEditCtrl , "long:cdecl" , "GetParaFormat" ,"hwnd" , $EditSafeHwnd , "ptr" , $PARAFORMAT_pf)
Return $DllCall[0]

EndFunc


Func GetRect($EditSafeHwnd , $LPRECT_lpRect)

$DllCall = DllCall( $Autoit_RichEditCtrl , "none:cdecl" , "GetRect" ,"hwnd" , $EditSafeHwnd , "ptr" , $LPRECT_lpRect)


EndFunc


Func GetSel($EditSafeHwnd , $CHARRANGE_cr)

$DllCall = DllCall( $Autoit_RichEditCtrl , "none:cdecl" , "GetSel" ,"hwnd" , $EditSafeHwnd , "ptr" , $CHARRANGE_cr)


EndFunc


Func GetSelectionCharFormat($EditSafeHwnd , $CHARFORMAT_cf)

$DllCall = DllCall( $Autoit_RichEditCtrl , "long:cdecl" , "GetSelectionCharFormat" ,"hwnd" , $EditSafeHwnd , "ptr" , $CHARFORMAT_cf)
Return $DllCall[0]

EndFunc


Func GetSelectionType($EditSafeHwnd)

$DllCall = DllCall( $Autoit_RichEditCtrl , "long:cdecl" , "GetSelectionType" ,"hwnd" , $EditSafeHwnd)
Return $DllCall[0]

EndFunc


Func GetSelText($EditSafeHwnd)

$DllCall = DllCall( $Autoit_RichEditCtrl , "str:cdecl" , "GetSelText" ,"hwnd" , $EditSafeHwnd)
Return $DllCall[0]

EndFunc


Func GetTextLength($EditSafeHwnd)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "GetTextLength" ,"hwnd" , $EditSafeHwnd)
Return $DllCall[0]

EndFunc


Func HideSelection($EditSafeHwnd , $BOOL_bHide , $BOOL_bPerm)

$DllCall = DllCall( $Autoit_RichEditCtrl , "none:cdecl" , "HideSelection" ,"hwnd" , $EditSafeHwnd , "int" , $BOOL_bHide , "int" , $BOOL_bPerm)


EndFunc


Func LimitText($EditSafeHwnd , $long_nChars = 0)

$DllCall = DllCall( $Autoit_RichEditCtrl , "none:cdecl" , "LimitText" ,"hwnd" , $EditSafeHwnd , "long" , $long_nChars = 0)


EndFunc


Func LineFromChar($EditSafeHwnd , $long_nIndex)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "LineFromChar" ,"hwnd" , $EditSafeHwnd , "long" , $long_nIndex)
Return $DllCall[0]

EndFunc


Func LineIndex($EditSafeHwnd , $int_nLine = -1)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "LineIndex" ,"hwnd" , $EditSafeHwnd , "int" , $int_nLine)
Return $DllCall[0]

EndFunc


Func LineLength($EditSafeHwnd , $int_nLine = -1)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "LineLength" ,"hwnd" , $EditSafeHwnd , "int" , $int_nLine)
Return $DllCall[0]

EndFunc


Func LineScroll($EditSafeHwnd , $int_nLines , $int_nChars = 0)

$DllCall = DllCall( $Autoit_RichEditCtrl , "none:cdecl" , "LineScroll" ,"hwnd" , $EditSafeHwnd , "int" , $int_nLines , "int" , $int_nChars)


EndFunc


Func Paste($EditSafeHwnd)

$DllCall = DllCall( $Autoit_RichEditCtrl , "none:cdecl" , "Paste" ,"hwnd" , $EditSafeHwnd)


EndFunc


Func PasteSpecial($EditSafeHwnd , $UINT_nClipFormat , $DWORD_dvAspect = 0 , $HMETAFILE_hMF = 0)

$DllCall = DllCall( $Autoit_RichEditCtrl , "none:cdecl" , "PasteSpecial" ,"hwnd" , $EditSafeHwnd , "int" , $UINT_nClipFormat , "long" , $DWORD_dvAspect , "long" , $HMETAFILE_hMF)


EndFunc


Func ReplaceSel($EditSafeHwnd , $LPCTSTR_lpszNewText , $BOOL_bCanUndo = FALSE)

$DllCall = DllCall( $Autoit_RichEditCtrl , "none:cdecl" , "ReplaceSel" ,"hwnd" , $EditSafeHwnd , "str" , $LPCTSTR_lpszNewText , "int" , $BOOL_bCanUndo)


EndFunc


Func RequestResize($EditSafeHwnd)

$DllCall = DllCall( $Autoit_RichEditCtrl , "none:cdecl" , "RequestResize" ,"hwnd" , $EditSafeHwnd)


EndFunc


Func SetBackgroundColor($EditSafeHwnd , $BOOL_bSysColor , $COLORREF_cr)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "SetBackgroundColor" ,"hwnd" , $EditSafeHwnd , "int" , $BOOL_bSysColor , "int" , $COLORREF_cr)
Return $DllCall[0]

EndFunc


Func SetDefaultCharFormat($EditSafeHwnd , $CHARFORMAT_cf)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "SetDefaultCharFormat" ,"hwnd" , $EditSafeHwnd , "ptr" , $CHARFORMAT_cf)
Return $DllCall[0]

EndFunc


Func SetEventMask($EditSafeHwnd , $DWORD_dwEventMask)

$DllCall = DllCall( $Autoit_RichEditCtrl , "long:cdecl" , "SetEventMask" ,"hwnd" , $EditSafeHwnd , "long" , $DWORD_dwEventMask)
Return $DllCall[0]

EndFunc


Func SetModify($EditSafeHwnd , $BOOL_bModified = TRUE)

$DllCall = DllCall( $Autoit_RichEditCtrl , "none:cdecl" , "SetModify" ,"hwnd" , $EditSafeHwnd , "int" , $BOOL_bModified)


EndFunc


Func SetOLECallback($EditSafeHwnd , $IRichEditOleCallback_pCallback)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "SetOLECallback" ,"hwnd" , $EditSafeHwnd , "ptr" , $IRichEditOleCallback_pCallback)
Return $DllCall[0]

EndFunc


Func SetOptions($EditSafeHwnd , $WORD_wOp , $DWORD_dwFlags)

$DllCall = DllCall( $Autoit_RichEditCtrl , "none:cdecl" , "SetOptions" ,"hwnd" , $EditSafeHwnd , "long" , $WORD_wOp , "long" , $DWORD_dwFlags)


EndFunc


Func SetParaFormat($EditSafeHwnd , $PARAFORMAT_pf)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "SetParaFormat" ,"hwnd" , $EditSafeHwnd , "ptr" , $PARAFORMAT_pf)
Return $DllCall[0]

EndFunc


Func SetReadOnly($EditSafeHwnd , $BOOL_bReadOnly = TRUE)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "SetReadOnly" ,"hwnd" , $EditSafeHwnd , "int" , $BOOL_bReadOnly)
Return $DllCall[0]

EndFunc


Func SetRect($EditSafeHwnd , $LPCRECT_lpRect)

$DllCall = DllCall( $Autoit_RichEditCtrl , "none:cdecl" , "SetRect" ,"hwnd" , $EditSafeHwnd , "ptr" , $LPCRECT_lpRect)


EndFunc


Func SetSel($EditSafeHwnd , $CHARRANGE_cr)

$DllCall = DllCall( $Autoit_RichEditCtrl , "none:cdecl" , "SetSel" ,"hwnd" , $EditSafeHwnd , "ptr" , $CHARRANGE_cr)


EndFunc


Func SetSelectionCharFormat($EditSafeHwnd , $CHARFORMAT_cf)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "SetSelectionCharFormat" ,"hwnd" , $EditSafeHwnd , "ptr" , $CHARFORMAT_cf)
Return $DllCall[0]

EndFunc


Func SetTargetDevice($EditSafeHwnd , $CDC_dc , $long_lLineWidth)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "SetTargetDevice" ,"hwnd" , $EditSafeHwnd , "int" , $CDC_dc , "long" , $long_lLineWidth)
Return $DllCall[0]

EndFunc


Func SetWordCharFormat($EditSafeHwnd , $CHARFORMAT_cf)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "SetWordCharFormat" ,"hwnd" , $EditSafeHwnd , "ptr" , $CHARFORMAT_cf)
Return $DllCall[0]

EndFunc


Func StreamIn($EditSafeHwnd , $int_nFormat , $EDITSTREAM_es)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "StreamIn" ,"hwnd" , $EditSafeHwnd , "int" , $int_nFormat , "ptr" , $EDITSTREAM_es)
Return $DllCall[0]

EndFunc


Func StreamOut($EditSafeHwnd , $int_nFormat , $EDITSTREAM_es)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "StreamOut" ,"hwnd" , $EditSafeHwnd , "int" , $int_nFormat , "ptr" , $EDITSTREAM_es)
Return $DllCall[0]

EndFunc


Func Undo($EditSafeHwnd)

$DllCall = DllCall( $Autoit_RichEditCtrl , "int:cdecl" , "Undo" ,"hwnd" , $EditSafeHwnd)
Return $DllCall[0]

EndFunc

Func WINAPILoadLibrary($lpFileName)

$DllCall = DllCall( "Kernel32.dll" , "hwnd" , "LoadLibrary" ,"str" , $lpFileName)
Return $DllCall[0]

EndFunc

