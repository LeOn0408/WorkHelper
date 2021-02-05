#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <File.au3>
#include <String.au3>
#include <Crypt.au3>

;~ #RequireAdmin ;требуем права администратора. Удали если хочешь
$ver= ""
$build = "Not supported"
$setup = "Config/setup"
$buttonFile = "Config/button"

$butSection = IniReadSectionNames ( $buttonFile )

$NameSection = IniReadSectionNames ( $buttonFile )
$b = $NameSection[0]
;загружаем настройки
$Admin = IniRead ( $setup, 'General', "Admin", "default" );грузим имя администратора
$Pass = IniRead ( $setup, 'General', "Pass", "default" );грузим зашифрованный пароль
$hKey = _Crypt_DeriveKey(StringToBinary("FlvbyYN"), $CALG_RC4);создаем ключ

$Pass = BinaryToString( _Crypt_DecryptData ( $Pass, $hKey, $CALG_USERKEY)); расшифровываем и переводим в строку
$KEY = IniRead ( $setup, 'General', "Pass", "default" );грузим ключ
$KEYActivation = "01032020" ;люч для сверки
$KEY = BinaryToString( _Crypt_DecryptData ( $KEY, $hKey, $CALG_USERKEY))


AutoItSetOption ( "TrayIconHide" , 1);скрываем иконку в трее

GUICreate("WorkHelper " & $ver & " " & $build & "", 400, 400, -1, -1, $WS_OVERLAPPEDWINDOW + $WS_POPUP) ; Создаёт окно в центре экрана
GUISetIcon('shell32.dll', -173)
GUISetState(@SW_SHOW) ; показывает окно
Global $button[100]

For $i = 1 To $b Step 1
   $Name = IniRead ( $buttonFile, $NameSection[$i], "Name", "default" )
   $left = IniRead ( $buttonFile, $NameSection[$i], "left", "default" )
   $top = IniRead ( $buttonFile, $NameSection[$i], "top", "default" )
   $width = IniRead ( $buttonFile, $NameSection[$i], "width", "default" )
   $height = IniRead ( $buttonFile, $NameSection[$i], "height", "default" )
   $button[$i] = GUICtrlCreateButton($Name, $left,$top, $width,$height)
Next
 ;меню
;~ $Connect = GUICtrlCreateButton("Remote Control", ,$top, $width,$height)
$fileMenu = GUICtrlCreateMenu("&Файл")
$mSetup = GUICtrlCreateMenuItem("Настройка", $fileMenu)
$mExit = GUICtrlCreateMenuItem("Выход", $fileMenu)
$utilMenu = GUICtrlCreateMenu("&Утилиты")
$CMD_BUT = GUICtrlCreateMenuItem("Командная строка", $utilMenu)
$Ping_BUT = GUICtrlCreateMenuItem("Проверка адреса", $utilMenu)

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
		 $Run= @ScriptDir &"/Utilities/ping.exe" ;нет поддержки. исходный код утерян)
		 ShellExecute($Run)
	  Case  $msg = $GUI_EVENT_CLOSE Or $msg = $mExit
		 ExitLoop
   EndSelect
WEnd
GUIDelete()

Func CMD();выполняем команду
   RunAs($Admin,@ComputerName,$Pass, 0, @ComSpec & " /c " & $CMD_INP, "",@SW_HIDE)
EndFunc

Func Util ()

EndFunc

Func Debug($DebMSG);для ошибок
   MsgBox(0,"Отладка", $DebMSG)
EndFunc

Func Setup();настройки
   GUICreate("Настройки", 400, 200, -1, -1, $WS_OVERLAPPEDWINDOW + $WS_POPUP)
   $tab = GUICtrlCreateTab(0, 0, 400, 200)
   GUICtrlCreateTabItem ( "Доступ" )
   GUICtrlCreateLabel("Администратор:", 120, 30)
   GUICtrlCreateLabel("Введите новый логин:", 70, 60)
   GUICtrlCreateLabel("Введите новый пароль:", 70, 90)
   $iLog = GUICtrlCreateInput($Admin, 200, 57,130)
   $iPass = GUICtrlCreateInput("", 200, 87,130,20,0x0020)
   $SaveLP = GUICtrlCreateButton("Записать", 170, 140)
   ;Debug($Pass)
   GUISetState(@SW_SHOW)
   While 1
	  Switch GUIGetMsg()
	  Case $SaveLP
		 $Admin = GUICtrlRead($iLog) ;считываем данные с окна ввода и записываем в переменную логина
		 IniWrite ( $setup, 'General', "Admin", $Admin ) ;записываем ее в наш ини
		 $Pass = GUICtrlRead($iPass);считываем данные с окна ввода и записываем в переменную пароля
		 $dEncrypted = _Crypt_EncryptData($Pass, $hKey, $CALG_USERKEY);шифруем пароль нашим ключом
		 IniWrite ( $setup, 'General', "Pass", $dEncrypted );записываем пароль в  ини
		 MsgBox(0,"Успешно","Пароль для " & $Pass & " успешно заменен")
	  Case $GUI_EVENT_CLOSE
		 ExitLoop
	  EndSwitch
   WEnd
GUIDelete()
EndFunc