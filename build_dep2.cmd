@echo on

:@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
:choco install windows-sdk-8.1 -y
:refreshenv

set ProjectFolder=%CD%
mkdir %CD%\win_depends
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x64 8.1 || goto :error
cd win_depends
git clone https://github.com/curl/curl
cd curl
call buildconf.bat || goto :error
cd winbuild
set RTLIBCFG=static
nmake /f Makefile.vc mode=static vc=16 debug=no ENABLE_WINSSL=yes || goto :error
nmake /f Makefile.vc mode=static vc=16 debug=yes ENABLE_WINSSL=yes || goto :error

:install
echo a |xcopy /e /h /c /i "../builds/libcurl-vc16-x64-release-static-ipv6-sspi-winssl/include" "%ProjectFolder%\includes"

: WHERE /R "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise" "msbuild"
: "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild" dapps_win.vcxproj
: "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild" subatomic.vcxproj

cd "%ProjectFolder%"
msbuild dapps_win.vcxproj || goto :error
msbuild subatomic.vcxproj || goto :error

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%
