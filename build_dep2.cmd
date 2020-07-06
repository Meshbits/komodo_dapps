@echo on
set ProjectFolder=%CD%
mkdir %CD%\win_depends
"C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x64 8.1
echo %errorlevel%
cd win_depends
git clone https://github.com/curl/curl
cd curl
buildconf.bat
echo %errorlevel%
cd winbuild
rem set RTLIBCFG=static
nmake /f Makefile.vc mode=static vc=16 debug=no ENABLE_WINSSL=yes
nmake /f Makefile.vc mode=static vc=16 debug=yes ENABLE_WINSSL=yes
:install
echo a |xcopy /e /h /c /i "../builds/libcurl-vc16-x64-release-static-ipv6-sspi-winssl/include" "%ProjectFolder%\includes"

msbuild dapps_win.vcxproj
msbuild subatomic.vcxproj
