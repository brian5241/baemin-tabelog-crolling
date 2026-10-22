# 배민 · 타베로그 프로젝트

## 타베로그

바탕화면 `tabelog` 프로젝트의 소개와 설계 문서를 별도 폴더에 보관합니다. 아래 배민 작업과는 별도의 기획이며, 현재 타베로그 자료는 실행 코드가 아닌 설계 문서입니다.

- [타베로그 프로젝트 소개](tabelog/README.md)
- [타베로그 설계 문서](tabelog/docs/design.md)

## 배민 업체 정보 → Excel : 집 PC 인계

작성일: 2026-10-08 (한국 시간)

## 현재 목표

배달의민족 가게 정보를 소량부터 수집하여 Excel로 정리할 수 있는지 검증한다. 지역·업종·최종 수량은 미정이다. 1곳 → 5곳 → 20곳으로 검증 범위를 늘린다. 실시간 추천 앱 구현은 현재 범위가 아니다.

**현재 상태는 인계 문서와 수동 이미지 판독 샘플만 준비된 단계다. 실행 가능한 크롤러, 기기 연결 테스트, 자동 추출, Excel 파일 생성은 아직 완료되지 않았다.**

- [집 PC 실행 순서와 대화 인계](docs/HANDOFF.md)
- [샘플 데이터와 Excel 설계](docs/DATA.md)

## 집에서 바로 시작

새 GitHub 저장소에 업로드가 완료되면 이 저장소를 집 PC에 clone하거나 ZIP으로 내려받는다. Codex에서 이 폴더를 열고 다음과 같이 요청한다.

> README.md와 docs/HANDOFF.md, docs/DATA.md를 읽고 이어서 작업해 주세요. 우선 환경을 읽기 전용으로 확인하고, 제가 연결한 안드로이드의 배민 가게 한 곳에서 화면 텍스트 추출이 가능한지 검증하고 싶습니다. 설치·USB 디버깅 권한 승인은 먼저 안내해 주세요. 주문이나 장바구니 변경, 개인정보 수집, 보안 우회는 하지 마세요. 확인되지 않은 작업을 성공했다고 표현하지 마세요.

## 자료 범위

배민 자료에는 원본 캡처, 계정 정보, 인증 토큰, 기기 식별자, 전체 대화 기록을 포함하지 않는다. 필요한 공개 업체 정보의 수동 전사와 작업 인계만 포함한다. 타베로그 소개·설계 문서는 `tabelog/` 폴더로 분리해 보관하며, 수집 DB는 포함하지 않는다.

---

# 배민 업체 수집기 (Baemin Scraper) v2.2

BlueStacks 에뮬레이터에서 실행 중인 배달의민족(배민) 앱 화면을 자동으로 캡처하고,
OCR로 업체명 / 평점 / 리뷰 수를 추출하여 엑셀·JSON 파일로 저장하는 도구입니다.

---

## 프로젝트 구조

```
baemin-scraper/
├── scraper.py        메인 스크립트 (캡처, OCR, 파싱, 스크롤, 저장)
├── config.json       설정 파일 (OCR 엔진, 스크롤 타이밍 등)
├── corrections.json  OCR 후처리 사전 (사용자 추가용)
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
| **카테고리 전환** | OCR로 탭바/아이콘 감지하여 자동 카테고리 변경 |
| **OCR 후처리** | 프랜차이즈/지역명 자동 교정 사전 |
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
py scraper.py                              # 기본 30개 수집
py scraper.py --count 50                   # 50개 수집
py scraper.py --test                       # 화면 한 번만 캡처하여 확인
py scraper.py --categories 양식 중식 한식    # 여러 카테고리 연속 수집
py scraper.py --schedule 14:30             # 매일 14:30에 자동 수집
py scraper.py --repeat 90                  # 90분 간격 반복 수집
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

## 주의사항

- 수집 중 마우스를 화면 **왼쪽 위 구석**으로 옮기면 긴급 중단됩니다 (pyautogui 안전장치)
- BlueStacks 창이 최소화되어 있으면 자동으로 복원합니다
- easyocr 첫 실행 시 모델 다운로드로 시간이 걸릴 수 있습니다
