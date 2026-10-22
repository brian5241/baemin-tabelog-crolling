@echo off
chcp 65001 >nul
echo 화면 한 번 캡처해서 OCR 결과만 확인합니다.
echo.
py "%~dp0scraper.py" --test
pause
