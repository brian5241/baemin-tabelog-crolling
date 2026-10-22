@echo off
chcp 65001 >nul
echo ================================================
echo   배민 수집기 - 패키지 설치
echo ================================================
echo.

echo [1/2] PyTorch (CPU 전용) 설치 중...
echo       (GPU 없이 돌아가는 가벼운 버전입니다)
py -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu

echo.
echo [2/2] OCR, 화면제어, 엑셀 패키지 설치 중...
py -m pip install easyocr pyautogui pygetwindow openpyxl numpy Pillow

echo.
echo ================================================
echo   설치 완료!
echo   run.cmd 를 실행하면 수집을 시작합니다.
echo ================================================
pause
