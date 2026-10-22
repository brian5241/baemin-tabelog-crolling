# 배민 업체 수집기 (Baemin Scraper) v2.0

BlueStacks 에뮬레이터에서 실행 중인 배달의민족(배민) 앱 화면을 자동으로 캡처하고,
OCR로 업체명 / 평점 / 리뷰 수를 추출하여 엑셀·JSON 파일로 저장하는 도구입니다.

---

## 프로젝트 구조

```
baemin-scraper/
├── scraper.py        메인 스크립트 (캡처, OCR, 파싱, 스크롤, 저장)
├── config.json       설정 파일 (OCR 엔진, 스크롤 타이밍 등)
├── install.cmd       패키지 한 번에 설치 (더블클릭)
├── run.cmd           수집 시작 (더블클릭)
├── test.cmd          화면 한 번 캡처하여 결과 확인
├── README.md         이 파일
└── output/           결과 저장 폴더
    ├── 배민_YYYYMMDD_HHMMSS.xlsx   수집 결과 (엑셀)
    ├── 배민_YYYYMMDD_HHMMSS.json   수집 결과 (JSON)
    ├── step_NNN.png                각 스크롤 단계 캡처 이미지
    └── test_capture.png            테스트 모드 캡처 이미지
```

---

## 주요 기능

| 기능 | 설명 |
|------|------|
| **자동 캡처** | BlueStacks 창을 자동 감지하여 스크린샷 촬영 |
| **OCR 엔진 선택** | `easyocr`(로컬, 무료) 또는 `anthropic`(Claude API, 유료) |
| **한국어 인식** | 한국어 + 영어 동시 인식 |
| **평점 재시도** | ★ 평점이 누락되면 해당 영역을 잘라서 3배 확대 후 재시도 |
| **사람처럼 스크롤** | 랜덤 대기, 불규칙 스와이프로 봇 감지 회피 |
| **중복 제거** | 80% 문자 유사도 기반 퍼지 매칭 |
| **엑셀 저장** | 파란 헤더 스타일 적용된 xlsx 파일 |

---

## 실행 방법

### 1. 사전 준비

- **Python 3.9+** 설치 필요
- **BlueStacks** 설치 후 배달의민족 앱 실행
- 배민 앱에서 원하는 카테고리의 업체 목록 화면을 띄워 놓기

### 2. 패키지 설치 (최초 1회)

`install.cmd`를 더블클릭하거나:

```
py -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu
py -m pip install easyocr pyautogui pygetwindow openpyxl numpy Pillow
```

### 3. 수집 시작

```
py scraper.py               # 기본 30개 수집
py scraper.py --count 50    # 50개 수집
py scraper.py --test        # 화면 한 번만 캡처하여 확인
```

또는 `run.cmd` / `test.cmd` 더블클릭.

---

## 설정 (config.json)

```jsonc
{
  "ocr": {
    "engine": "easyocr",       // "easyocr" 또는 "anthropic"
    "gpu": false,              // GPU 사용 여부 (easyocr)
    "mag_ratio": 0.85,         // 이미지 확대 비율 (easyocr)
    "languages": ["ko", "en"]  // 인식 언어
  },
  "anthropic": {
    "api_key": "",             // Claude API 키 (anthropic 엔진 사용 시)
    "model": "claude-sonnet-4-20250514"
  },
  "scroll": {
    "pause_min": 1.8,          // 스크롤 후 최소 대기 (초)
    "pause_max": 3.5,          // 스크롤 후 최대 대기 (초)
    "long_pause_chance": 0.12, // 긴 쉼 확률 (12%)
    "long_pause_min": 5.0,     // 긴 쉼 최소 (초)
    "long_pause_max": 9.0      // 긴 쉼 최대 (초)
  },
  "collect": {
    "max_no_new": 3,           // N번 연속 새 업체 없으면 종료
    "default_count": 30        // 기본 수집 목표
  }
}
```

### Claude API 엔진 사용

1. `config.json`의 `anthropic.api_key`에 API 키 입력
2. `ocr.engine`을 `"anthropic"`으로 변경
3. 실행 시 API 호출 비용 발생 (스크린샷 1장당 약 $0.01~0.02)

---

## 수집 결과 예시

| 번호 | 업체명 | 평점 | 리뷰 수 | 수집 시각 |
|------|--------|------|---------|-----------|
| 1 | 카페그리닝 샌드위치&샐러드 정발산점 | 4.8 | 48 | 2026-10-13 16:30 |
| 2 | 프로메사 | 4.9 | 129 | 2026-10-13 16:30 |

---

## 핵심 로직 요약

1. **BlueStacks 창 감지** → `pygetwindow`로 창 위치·크기 파악
2. **스크린샷 촬영** → `pyautogui.screenshot()`
3. **OCR 분석** → `easyocr.readtext()` 또는 Claude API
4. **텍스트 파싱** → Y좌표 기준 줄 묶기 → 정규식으로 업체명/평점/리뷰 추출
5. **평점 재시도** → 누락 시 해당 영역 크롭 + 3배 확대 + 재OCR
6. **중복 제거** → 한글 기준 80% 문자 겹침 체크
7. **스크롤** → 사람처럼 불규칙한 스와이프 + 랜덤 대기
8. **반복** → 목표 수 채우거나 3번 연속 새 업체 없을 때까지
9. **저장** → 엑셀(xlsx) + JSON

---

## 주의사항

- 수집 중 마우스를 화면 **왼쪽 위 구석**으로 옮기면 긴급 중단됩니다 (pyautogui 안전장치)
- BlueStacks 창이 최소화되어 있으면 자동으로 복원합니다
- easyocr 첫 실행 시 모델 다운로드로 시간이 걸릴 수 있습니다
