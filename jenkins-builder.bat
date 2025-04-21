@echo off
chcp 65001 >nul
color 0A
title 🛠️ Jenkins Derleyici
setlocal EnableDelayedExpansion

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                   █ 🛠️ JENKINS BUILDER  █                    ║
echo ║              	       erdincdegirmenci                        ║
echo ╚══════════════════════════════════════════════════════════════╝
echo ----------------------------------------------------------------

:: jenkins-config.bat yoksa kullanıcıdan bilgi al ve oluştur
if not exist jenkins-config.bat (
    echo ⚠️  jenkins-config.bat bulunamadı!
    echo 🔄 Yeni konfigürasyon oluşturuluyor...	
    echo.
    echo 📌 Jenkins API Token nasıl alınır?
	echo ➤ 1. Jenkins ana sayfasına giriş yap.
	echo ➤ 2. Sağ üst köşeden ismine tıkla ^> Configure tıkla.
	echo ➤ 3. "API Token" bölümünden yeni bir token oluştur veya kopyala.
    echo.
	
	
	:: Kullanıcı adı al
	set /p USER_NAME=Kullanıcı adınızı girin:
	if "!USER_NAME!"=="" (
		echo ❌ Kullanıcı adı boş bırakılamaz! Dosya oluşturulmadı.
		pause
		exit /b 1
	)

	:: API token al
	set /p USER_API_TOKEN=API Token girin:
	if "!USER_API_TOKEN!"=="" (
		echo ❌ API Token boş bırakılamaz! Dosya oluşturulmadı.
		pause
		exit /b 1
	)
	
	
	echo Kullanıcı Adı: !USER_NAME!
	echo API Token: !USER_API_TOKEN!

    > jenkins-config.bat (
        echo set USER_NAME=!USER_NAME!
        echo set USER_API_TOKEN=!USER_API_TOKEN!
    )


    echo ✅ jenkins-config.bat oluşturuldu.
)

:: jenkins-config.bat içeriğini yükle
call jenkins-config.bat


:: API_TOKEN değişkeni ata
set API_TOKEN=%USER_API_TOKEN%

:: Proje seçim ekranı
echo.
echo. Lütfen build almak istediğiniz projeyi seçin:
echo.
echo. [1] {Your_project_1}
echo. [2] {Your_project_2}
set /p PROJECT_CHOICE=Seçiminiz (1-5): 

:: Seçime göre proje adı ayarla
if "%PROJECT_CHOICE%"=="1" set "PROJECT_NAME=BI-{Your_project_1}"
if "%PROJECT_CHOICE%"=="2" set "PROJECT_NAME=BI-{Your_project_2}"
if not defined PROJECT_NAME (
    echo. ❌ Hatalı seçim yapıldı Script sonlandırılıyor...
    pause
    exit /b 1
)
echo.
echo ➡️ Seçilen proje: %PROJECT_NAME%
echo 🧑‍💻 Kullanıcı: %USER_NAME%
echo 🔑 Token: %API_TOKEN%

set "BASE_URL={your_jenkins_url}"
set "JENKINS_URL=%BASE_URL%/{you-job}/%PROJECT_NAME%"
echo.
echo 🔨 Build işlemleri başlatılıyor...
:: build komutlarını buraya ekle
:: Kullanıcıdan parametreleri al
set /p BUILDVERSION=Build versiyonu girin (örn: 3.25.00.00): 
set /p BRANCHNAME=Branch adı girin (Varsayılan: master): 
if "!BRANCHNAME!"=="" set "BRANCHNAME=master"
:: Varsayılan değerler
set "RUNOBFUSCATOR=false"
set "RUNSETUP=true"
set "ADDWIDGET=true"
set /p INPUT_RUNOBFUSCATOR=[RUNOBFUSCATOR] true/false girin (Varsayılan: false): 
if not "!INPUT_RUNOBFUSCATOR!"=="" set "RUNOBFUSCATOR=!INPUT_RUNOBFUSCATOR!"

set /p INPUT_RUNSETUP=[RUNSETUP] true/false girin (Varsayılan: true): 
if not "!INPUT_RUNSETUP!"=="" set "RUNSETUP=!INPUT_RUNSETUP!"

set /p INPUT_ADDWIDGET=[ADDWIDGET] true/false girin (Varsayılan: true): 
if not "!INPUT_ADDWIDGET!"=="" set "ADDWIDGET=!INPUT_ADDWIDGET!"
:: Parametreleri hazırla
set "PARAMS=BUILDVERSION=%BUILDVERSION%&BRANCHNAME=%BRANCHNAME%&RUNOBFUSCATOR=%RUNOBFUSCATOR%&RUNSETUP=%RUNSETUP%&ADDWIDGET=%ADDWIDGET%"
echo..
echo. 🔄 Jenkins Build tetikleniyor...

:: HTTP durum kodunu kontrol et
for /f %%H in ('curl -s -o nul -w "%%{http_code}" "%JENKINS_URL%/lastBuild/buildNumber" --user "%USER_NAME%:%API_TOKEN%"') do set HTTP_STATUS=%%H

:: Durum koduna göre kontrol
if "%HTTP_STATUS%" == "200" (
    echo 🌐 Jenkins erişimi başarılı.
    
    :: Şimdi build number'ı al
    for /f %%i in ('curl -s "%JENKINS_URL%/lastBuild/buildNumber" --user "%USER_NAME%:%API_TOKEN%"') do (
        set /a BUILD_NUMBER=%%i + 1
    )
) else (    
    echo ❌ Bağlantı hatası [%HTTP_STATUS%]: %BASE_URL% sunucusuna ulaşılamadı.
    echo Lütfen URL'yi ve ağ bağlantısını kontrol edin.
	echo Devam etmek için bir tuşa basın...
	pause >nul
	exit /b
)

curl -X POST "%JENKINS_URL%/buildWithParameters?%PARAMS%" --user "%USER_NAME%:%API_TOKEN%" >nul
echo. 🔁 Build isteği gönderildi...
:CHECK_STATUS
echo. 📦 Build numarası alındı: !BUILD_NUMBER!
echo. ⚙️ Derleme başlatıldı. Lütfen bekleyiniz...
echo. 🔄 İşlem devam ediyor...

:: Çalışan dizini al
set "WORKING_DIR=%CD%"

:: Geçici dosya yolunu çalışma dizinine göre ayarla
set "TEMP_FILE=%WORKING_DIR%\result.json"

:: "Build devam ediyor..." mesajını sadece bir kez yazdırmak için bayrak değişkeni
set "BUILD_RUNNING=false"

:WAIT_FOR_RESULT
timeout /t 5 >nul

:: JSON cevabını alıp geçici bir dosyaya yaz
curl -s "%JENKINS_URL%/%BUILD_NUMBER%/api/json" --user "%USER_NAME%:%API_TOKEN%" > "%TEMP_FILE%"

:: "result":null ise build devam ediyor
findstr /i "\"result\":null" "%TEMP_FILE%" >nul
if !errorlevel! equ 0 (
    if "!BUILD_RUNNING!"=="false" (
        echo ⏳ Build devam ediyor...
        set "BUILD_RUNNING=true"
    )
    goto :WAIT_FOR_RESULT
)

:: Build tamamlandıysa sonucu kontrol et
findstr /i "\"result\":\"SUCCESS\"" "%TEMP_FILE%" >nul
if !errorlevel! equ 0 (
    echo ✅ Build başarılı tamamlandı.
    goto :END
)

findstr /i "\"result\":\"FAILURE\"" "%TEMP_FILE%" >nul
if !errorlevel! equ 0 (
    echo ❌ Build başarısız oldu!
    goto :END
)

goto :WAIT_FOR_RESULT

:END
del "%TEMP_FILE%"
echo.
echo Çıkış yapmak için 'Q' tuşuna basın...
:: Eğer kullanıcı 'Q' tuşuna basarsa
if errorlevel 1 (	
	echo 🔚 Programdan sonlandırılıyor...
    timeout /t 2 >nul
    exit
)
endlocal
