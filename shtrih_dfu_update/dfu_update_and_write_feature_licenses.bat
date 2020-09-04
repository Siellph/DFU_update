@echo off
setlocal
rem �ਬ�� �ਯ� ���������� �� �� DFU � ������� �㭪樮������ ��業���
rem � ��� � ࠡ�祩 ��४�ਨ �� ������ ���� �஡���� � ��㣨� ᯥ� ᨬ�����.
rem ���ਬ��, ����� �������� �ਯ� � C:\shtrih_dfu_update
rem ��४��� ������ ���� ����㯭� �� ������(���� ��࠭����� �६���� 䠩��)
rem �冷� � �ਯ⮬ ����室��� �������� dfu-util.exe � console_test_fr_drv_ng.exe, � 䠩� � �㭪樮����묨 ��業��ﬨ ��� ������ licenses.slf

echo ����� �ਯ� ������� ���������� ��� �१ ०�� dfu
pause
rem �᫨ �᪮�����஢��� ᫥������ ��ப� - �⫠��� �㤥� � ���᮫�, ���� � 䠩�� fr_drv.log � ࠡ�祩 ��४�ਨ
rem set /A FR_DRV_DEBUG_CONSOLE=1
rem ��� 䠩�� १�ࢭ�� ����� ⠡���
set SAVE_TABLES_PATH=tables_backup

cd /d %~dp0
echo %cd%>tmp
set /P PWD=<tmp
rem ���� �� �ᯮ��塞��� 䠩�� ���᮫쭮�� ���, ���ࠧ㬥������ �� �� ��室���� � ࠡ�祩 ��४�ਨ
set "FULL_EXE_PATH=%PWD%\console_test_fr_drv_ng.exe"

rem URI �裡 � ���, �� 㬮�砭�� �ᯮ������ TCP �࠭ᯮ��, ���� 192.168.137.111, ���� 7778, ⠩���� 10 ᥪ㭤� �� �������, �⠭����� ��⮪�� 
rem �᫨ �� ���� �ਯ� � ���㦥�� ��� FR_DRV_NG_CT_URL �����砥��� �⠭�����, ���� �� ���㦥���
echo �饬 ���...
console_test_fr_drv_ng discover > tmp
for /f %%i in ("tmp") do set TMP_SIZE=%%~zi
if %TMP_SIZE% EQU 0 echo "�� 㤠���� �����㦨�� ���ன�⢮" && EXIT /B 1

for /F "usebackq tokens=*" %%A in ("tmp") do (
set "FR_DRV_NG_CT_URL=%%A"
call :nextstep
)
goto continue
:nextstep

rem ��஫� ���. ����������� ���, �� 㬮�砭�� 30
rem �᫨ �� ���� �ਯ� � ���㦥�� ��� FR_DRV_NG_CT_PASSWORD �ᯮ������ �⠭�����, ���� �� ���㦥���
if "%FR_DRV_NG_CT_PASSWORD%" == "" set "FR_DRV_NG_CT_PASSWORD=30"
echo ���� ��������� ��� "%FR_DRV_NG_CT_URL%"
echo ��஫� ��������� ��� "%FR_DRV_NG_CT_PASSWORD%"
pause
echo ������� ���� ��࠭��� � 䠩� %SAVE_TABLES_PATH%
echo ����砥� ����� ���...
console_test_fr_drv_ng status>NUL
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
echo ��!
echo ����砥� �����᪮� �����...
console_test_fr_drv_ng read 18.1.1>tmp
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
set /P SERIAL=<tmp
echo �����᪮� �����: %SERIAL%
echo ����砥� UIN...
console_test_fr_drv_ng read 23.1.11>tmp
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
set /P UIN=<tmp
echo UIN: %UIN%
set FIRMWARE_FILENAME=upd_app.bin
IF "%UIN%"=="---" (
   echo UIN ���������
   set FIRMWARE_FILENAME=upd_app_for_old_frs.bin 
)
echo ��� ���������� �㤥� ����: "%FIRMWARE_FILENAME%"
echo|set /p= ���࠭塞 ⠡����...
console_test_fr_drv_ng save-tables > %SAVE_TABLES_PATH%
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
echo ��⮢�!

echo ��१���㦠���� � ०�� dfu...
console_test_fr_drv_ng reboot-dfu
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
rem ���諨 � ०�� DFU, ��� 3 ᥪ㭤� � ����᪠�� dfu-util, ��� ᠬ� ������ ���ன�⢮ � ��⠭���� ��訢��, �㦭� ⮫쪮 ��।��� ��� 䠩��
timeout /t 3 /nobreak > NUL
echo|set /p= ����᪠�� ���������� �� DFU...
dfu-util -D %FIRMWARE_FILENAME%
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
echo ��⮢�!
echo �������� 15 ᥪ㭤... ��� ��१���㦠����...

rem ᯨ� 15 ᥪ㭤, ��� ������ ���ன�⢠ � ��⥬� ��᫥ ����������
timeout /t 15 /nobreak > NUL
rem 㤠�塞 ��� �ࠢ��� 䠩�ࢮ���, ��� 蠣 �㦥� ��⮬� �� �� ��������� ��� � �ᯮ��塞��� 䠩�� ������� ࠡ���� � �ࠢ���. ���⮬� ����� ࠧ 㤠�塞 ���� �ࠢ��� � ������塞 ����.
netsh advfirewall firewall del rule name="console_test_fr_drv_ng_allow"
echo ������塞 �ࠢ��� firewall
netsh advfirewall firewall add rule name="console_test_fr_drv_ng_allow" program="%FULL_EXE_PATH%" protocol=udp dir=in enable=yes action=allow profile=private,public
netsh advfirewall firewall add rule name="console_test_fr_drv_ng_allow" program="%FULL_EXE_PATH%" protocol=tcp dir=in enable=yes action=allow profile=private,public

echo|set /p= �饬 ����������� ��� � �� � �� COM �����...
console_test_fr_drv_ng discover > tmp
for /f %%i in ("tmp") do set TMP_SIZE=%%~zi
if %TMP_SIZE% EQU 0 echo "�� 㤠���� �����㦨�� ���ன�⢮ ��᫥ ����������" && EXIT /B 1

for /F "usebackq tokens=*" %%A in ("tmp") do (
set "FR_DRV_NG_CT_URL=%%A"
call :nextkkt
)
goto continue
echo ������� ��� ��᫥ ����������: "%FR_DRV_NG_CT_URL%"
:nextkkt
echo "����⪠ ᮥ������� � %FR_DRV_NG_CT_URL%"
console_test_fr_drv_ng model>NUL
IF %ERRORLEVEL% NEQ 0 GOTO:EOF
echo ���ன�⢮ �����㦥��!

echo|set /p= �믮��塞 �审�㫥���...
console_test_fr_drv_ng tech-reset
IF %ERRORLEVEL% NEQ 0 GOTO:EOF
echo ��⮢�!

echo|set /p= ��⠭�������� ⥪���� ����-�६�...
console_test_fr_drv_ng setcurrentdatetime
IF %ERRORLEVEL% NEQ 0 GOTO:EOF
echo ��⮢�!

echo ����砥� �����᪮� ����� �����㦥����� ���ன�⢠...
console_test_fr_drv_ng read 18.1.1>tmp
IF %ERRORLEVEL% NEQ 0 GOTO:EOF
set /P NEW_SERIAL=<tmp
echo %SERIAL%
echo %NEW_SERIAL%
if not "%SERIAL%" == "%NEW_SERIAL%" echo "�����᪮� ����� �� ᮢ������ � ��������" && goto :EOF

echo|set /p= ����⠭�������� ⠡����...
type %SAVE_TABLES_PATH% | console_test_fr_drv_ng restore-tables
rem IF %ERRORLEVEL% NEQ 0 GOTO:EOF
echo ��⮢�! ������� ����⠭������

echo �饬 䠩� ��業���...
if not exist licenses.slf echo "䠩� ��業��� licenses.slf �� ������" && echo "��१���㦠����..." && console_test_fr_drv_ng reboot & exit /B 1
findstr /B %SERIAL% licenses.slf > tmp
for /f %%i in ("tmp") do set TMP_SIZE=%%~zi
if %TMP_SIZE% EQU 0 echo "��業��� ��� %NEW_SERIAL% �� �����㦥��" && echo "��१���㦠����..." && console_test_fr_drv_ng reboot & exit /B 1
set /P LICENSE_STRING=<tmp
set LICENSE=
set CRYPTO_SIGNATURE=
for /F "tokens=1,2,3" %%A in ("%LICENSE_STRING%") DO (
	echo %%B>tmp
	set /P LICENSE=<tmp
	echo %%C>tmp
	set /P CRYPTO_SIGNATURE=<tmp	
)
echo|set /p= ��⠭�������� �㭪樮����� ��業���...
console_test_fr_drv_ng write-feature-licenses %LICENSE% %CRYPTO_SIGNATURE%
IF %ERRORLEVEL% NEQ 0 echo "��१���㦠����..." && console_test_fr_drv_ng reboot & exit /B 1
echo ��⮢�! �㭪樮����� ��業��� ��⠭������

rem �᫨ ����室��� ������� ���� ��ࠬ����, � �㦭� �ய���� �� � ⠡��� newparam � �᪮�����஢��� ��� ��ப� ����
rem echo �����뢠�� ���� ��ࠬ���� ���...
rem type C:\shtrih_dfu_update\regional17 | console_test_fr_drv_ng restore-tables

echo|set /p= ��१���㦠����...
console_test_fr_drv_ng reboot
IF %ERRORLEVEL% NEQ 0 exit /b 1
echo ��⮢�! ���������� �����襭�!
del /f tmp
PAUSE
EXIT