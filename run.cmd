@echo off
chcp 65001 >nul
py "%~dp0scraper.py" %*
pause
