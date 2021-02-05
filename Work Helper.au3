#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <File.au3>
#include <String.au3>
#include <Crypt.au3>

;~ #RequireAdmin ;������� ����� ��������������. ����� ���� ������
$ver= ""
$build = "Not supported"
$setup = "Config/setup"
$buttonFile = "Config/button"

$butSection = IniReadSectionNames ( $buttonFile )

$NameSection = IniReadSectionNames ( $buttonFile )
$b = $NameSection[0]
;��������� ���������
$Admin = IniRead ( $setup, 'General', "Admin", "default" );������ ��� ��������������
$Pass = IniRead ( $setup, 'General', "Pass", "default" );������ ������������� ������
$hKey = _Crypt_DeriveKey(StringToBinary("FlvbyYN"), $CALG_RC4);������� ����

$Pass = BinaryToString( _Crypt_DecryptData ( $Pass, $hKey, $CALG_USERKEY)); �������������� � ��������� � ������
$KEY = IniRead ( $setup, 'General', "Pass", "default" );������ ����
$KEYActivation = "01032020" ;��� ��� ������
$KEY = BinaryToString( _Crypt_DecryptData ( $KEY, $hKey, $CALG_USERKEY))


AutoItSetOption ( "TrayIconHide" , 1);�������� ������ � ����

GUICreate("WorkHelper " & $ver & " " & $build & "", 400, 400, -1, -1, $WS_OVERLAPPEDWINDOW + $WS_POPUP) ; ������ ���� � ������ ������
GUISetIcon('shell32.dll', -173)
GUISetState(@SW_SHOW) ; ���������� ����
Global $button[100]

For $i = 1 To $b Step 1
   $Name = IniRead ( $buttonFile, $NameSection[$i], "Name", "default" )
   $left = IniRead ( $buttonFile, $NameSection[$i], "left", "default" )
   $top = IniRead ( $buttonFile, $NameSection[$i], "top", "default" )
   $width = IniRead ( $buttonFile, $NameSection[$i], "width", "default" )
   $height = IniRead ( $buttonFile, $NameSection[$i], "height", "default" )
   $button[$i] = GUICtrlCreateButton($Name, $left,$top, $width,$height)
Next
 ;����
;~ $Connect = GUICtrlCreateButton("Remote Control", ,$top, $width,$height)
$fileMenu = GUICtrlCreateMenu("&����")
$mSetup = GUICtrlCreateMenuItem("���������", $fileMenu)
$mExit = GUICtrlCreateMenuItem("�����", $fileMenu)
$utilMenu = GUICtrlCreateMenu("&�������")
$CMD_BUT = GUICtrlCreateMenuItem("��������� ������", $utilMenu)
$Ping_BUT = GUICtrlCreateMenuItem("�������� ������", $utilMenu)

While 1
   $msg = GUIGetMsg()
   Select
	  Case $msg >= $button[1] And $msg <= $button[$b]
		 $cmdVal1 = $msg - $button[1]
		 $CMD_INP = IniRead ( $buttonFile, 'But_' & $cmdVal1, "CMD", "default" )
		 CMD()
	  Case  $msg = $mSetup
		 Setup()
	  Case  $msg = $CMD_BUT
		 $handle = ShellExecute ("cmd.exe","","C:\")
		 WinActivate($handle)
	  Case  $msg = $Ping_BUT
		 $Run= @ScriptDir &"/Utilities/ping.exe" ;��� ���������. �������� ��� ������)
		 ShellExecute($Run)
	  Case  $msg = $GUI_EVENT_CLOSE Or $msg = $mExit
		 ExitLoop
   EndSelect
WEnd
GUIDelete()

Func CMD();��������� �������
   RunAs($Admin,@ComputerName,$Pass, 0, @ComSpec & " /c " & $CMD_INP, "",@SW_HIDE)
EndFunc

Func Util ()

EndFunc

Func Debug($DebMSG);��� ������
   MsgBox(0,"�������", $DebMSG)
EndFunc

Func Setup();���������
   GUICreate("���������", 400, 200, -1, -1, $WS_OVERLAPPEDWINDOW + $WS_POPUP)
   $tab = GUICtrlCreateTab(0, 0, 400, 200)
   GUICtrlCreateTabItem ( "������" )
   GUICtrlCreateLabel("�������������:", 120, 30)
   GUICtrlCreateLabel("������� ����� �����:", 70, 60)
   GUICtrlCreateLabel("������� ����� ������:", 70, 90)
   $iLog = GUICtrlCreateInput($Admin, 200, 57,130)
   $iPass = GUICtrlCreateInput("", 200, 87,130,20,0x0020)
   $SaveLP = GUICtrlCreateButton("��������", 170, 140)
   ;Debug($Pass)
   GUISetState(@SW_SHOW)
   While 1
	  Switch GUIGetMsg()
	  Case $SaveLP
		 $Admin = GUICtrlRead($iLog) ;��������� ������ � ���� ����� � ���������� � ���������� ������
		 IniWrite ( $setup, 'General', "Admin", $Admin ) ;���������� �� � ��� ���
		 $Pass = GUICtrlRead($iPass);��������� ������ � ���� ����� � ���������� � ���������� ������
		 $dEncrypted = _Crypt_EncryptData($Pass, $hKey, $CALG_USERKEY);������� ������ ����� ������
		 IniWrite ( $setup, 'General', "Pass", $dEncrypted );���������� ������ �  ���
		 MsgBox(0,"�������","������ ��� " & $Pass & " ������� �������")
	  Case $GUI_EVENT_CLOSE
		 ExitLoop
	  EndSwitch
   WEnd
GUIDelete()
EndFunc