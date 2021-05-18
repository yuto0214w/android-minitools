@echo off

:init
where node >nul
if errorlevel 1 (
  setlocal enabledelayedexpansion
  echo Sorry, this program requires Node.js to run.

  :ask
  set /p installnow="Would you like to install it now? (Y/n)"
  for %%i in (n y) do set installnow=!installnow:%%i=%%i!
  if "!installnow!" == "y" (
    start https://nodejs.org/
    echo Opened the browser, download the installer and follow the installer instructions.
    echo then reopen this program.
    pause >nul
    exit /b
  ) else if "!installnow!" == "n" (
    exit /b
  ) else (
    set installnow=
    goto :ask
  )
)
set /a len = 0

:main
if "%1" == "help" (
  echo Available Commands:
  echo   power                  ^| Toggle Power
  echo.
  echo   home                   ^| Home Button
  echo.
  echo   brightness             ^| Brightness Control ^(Argument Required^)
  echo     - down               ^| Brightness Down
  echo       - longpress,long,l ^| Whether long press or not
  echo     - up                 ^| Brightness Up
  echo       - longpress,long,l ^| Whether long press or not
  echo.
  echo   special                ^| Open app such as calculator, mail, etc. ^(Argument Required^)
  echo     - calc               ^| Open Calculator
  echo     - calendar           ^| Open Calendar
  echo     - contacts           ^| Open Contacts
  echo     - mail               ^| Open Mail
  echo     - browser            ^| Open Browser such as Chrome
  echo     - music              ^| Open Music
  echo.
  echo   volume                 ^| Volume Control ^(Argument Required^)
  echo     - down               ^| Volume Down
  echo       - longpress,long,l ^| Whether long press or not
  echo     - mute               ^| Toggle Mute
  echo     - up                 ^| Volume Up
  echo       - longpress,long,l ^| Whether long press or not
  echo.
  echo   text                   ^| Type the text though PC ^(Argument Required^)
  echo     - text               ^| Alphabet and some symbols ^(excepts ^(, ^), and !^) only, set IME before run
  echo.
  echo   custom                 ^| Type the keycode manually ^(Argument Required^)
  echo     - keycode            ^| Format is KEYCODE_XXX
  echo       - longpress,long,l ^| These are listed on
  echo                          ^| https://tinyurl.com/android-keyevents
  echo.
  echo   version                ^| Show Program Version
) else if "%1" == "power" (
  call :apply KEYCODE_POWER
) else if "%1" == "home" (
  call :apply KEYCODE_HOME
) else if "%1" == "brightness" (
  if "%2" == "down" (
    call :apply KEYCODE_BRIGHTNESS_DOWN %3
  ) else if "%2" == "up" (
    call :apply KEYCODE_BRIGHTNESS_UP %3
  ) else (
    echo Argument Required
    echo   - down               ^| Brightness Down
    echo     - longpress,long,l ^| Whether long press or not
    echo   - up                 ^| Brightness Up
    echo     - longpress,long,l ^| Whether long press or not
    exit /b
  )
) else if "%1" == "special" (
  if "%2" == "calc" (
    call :apply KEYCODE_CALCULATOR
  ) else if "%2" == "calendar" (
    call :apply KEYCODE_CALENDAR
  ) else if "%2" == "contacts" (
    call :apply KEYCODE_CONTACTS
  ) else if "%2" == "mail" (
    call :apply KEYCODE_ENVELOPE
  ) else if "%2" == "browser" (
    call :apply KEYCODE_EXPLORER
  ) else if "%2" == "music" (
    call :apply KEYCODE_MUSIC
  ) else (
    echo Argument Required
    echo   - calc     ^| Open Calculator
    echo   - calendar ^| Open Calendar
    echo   - contacts ^| Open Contacts
    echo   - mail     ^| Open Mail
    echo   - browser  ^| Open Browser such as Chrome
    echo   - music    ^| Open Music
    exit /b
  )
) else if "%1" == "volume" (
  if "%2" == "down" (
    call :apply KEYCODE_VOLUME_DOWN %3
  ) else if "%2" == "mute" (
    call :apply KEYCODE_VOLUME_MUTE
  ) else if "%2" == "up" (
    call :apply KEYCODE_VOLUME_UP %3
  ) else (
    echo Argument Required
    echo   - down               ^| Volume Down
    echo     - longpress,long,l ^| Whether long press or not
    echo   - mute               ^| Toggle Mute
    echo   - up                 ^| Volume Up
    echo     - longpress,long,l ^| Whether long press or not
    exit /b
  )
) else if "%1" == "text" (
  if not "%2" == "" (
    setlocal enabledelayedexpansion
    set input=%*
    set input=!input:~5!
    for %%s in (!input!) do (
      if "%%s" == "\n" (
        adb shell input keyevent KEYCODE_ENTER
      ) else if "%%s" == "\s" (
        adb shell input keyevent KEYCODE_SPACE
      ) else if "%%s" == "\zh" (
        adb shell input keyevent KEYCODE_ZENKAKU_HANKAKU
      ) else if "%%s" == "\bksp" (
        adb shell input keyevent KEYCODE_DEL
      ) else (
        adb shell input text %%s
      )
    )
  ) else (
    echo Argument Required
    echo   - text ^| Alphabet and some symbols ^(excepts ^(, ^), and !^) only, set IME before run
    exit /b
  )
) else if "%1" == "custom" (
  if not "%2" == "" (
    setlocal enabledelayedexpansion
    set code=%2
    for %%i in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do set code=!code:%%i=%%i!
    call :apply !code! %3
  ) else (
    echo Argument Required
    echo   - keycode            ^| Format is KEYCODE_XXX
    echo     - longpress,long,l ^| These are listed on
    echo                        ^| https://tinyurl.com/android-keyevents
    exit /b
  )
) else if "%1" == "version" (
  echo android-minitools v1.0.0
) else (
  echo %cd%^>android help
  call :main help
)

goto :exit

:apply
node -e "console.log(Boolean('%1'.match(/^KEYCODE(?:_[A-Z]+)+$/)))" | findstr "true" >nul
if not errorlevel 1 (
  if not "%2" == "" (
    node -e "console.log(Boolean('%2'.toLowerCase().match(/^l(?:ong(?:press)?)?$/)))" | findstr "true" >nul
    if not errorlevel 1 (
      echo Running: adb shell input keyevent --longpress %1
      adb shell input keyevent --longpress %1
    ) else (
      echo Syntax Error: longpress isn't spelled correctly or typed something other.
      echo Aborted: adb shell input keyevent
    )
  ) else (
    echo Running: adb shell input keyevent %1
    adb shell input keyevent %1
  )
) else (
  echo Syntax Error: Keycode isn't specified correctly.
  echo Aborted: adb shell input keyevent
)
exit /b

:exit