# 📁 claude-workspace

> H님의 Claude Code 작업 공간입니다.
> Claude Code가 작업할 때 이 폴더를 기준으로 움직입니다.

---

## 🗂️ 폴더 구조

```
claude-workspace/
├── CLAUDE.md          # Claude Code 행동 지침서 (가장 중요 — 매번 자동으로 읽음)
├── README.md          # 이 파일 — 작업 공간 안내
├── SECURITY.md        # 🚨 키 노출 등 비상시 대응 매뉴얼
├── .gitignore         # Git 업로드 제외 목록 (민감 파일 차단)
├── portfolio.html     # 포트폴리오 웹페이지
├── tasks/             # 작업 기록
│   ├── todo.md        #   오늘 할 일 (체크리스트)
│   └── progress.md    #   한 일 기록 (append-only)
├── weather/           # 날씨 조회 스크립트 (PowerShell)
│   ├── weather.ps1    #   Open-Meteo 무료 API 사용 (키 불필요)
│   └── weather.txt    #   사용법 메모
│
└── docs/              # 🔒 개인정보·민감 문서 (.gitignore로 제외 — GitHub에 안 올라감)
    └── (이력서·매출 데이터·복구코드 등 → 로컬에만 보관)
```

> 🔒 `.env`, `docs/`, 각종 키·비밀번호 파일은 `.gitignore`로 막아 두어
> GitHub(private 레포 포함)에 **업로드되지 않습니다.**

---

## 📄 각 파일은 뭐 하는 곳?

| 파일 | 역할 | 언제 보나 |
|------|------|-----------|
| **CLAUDE.md** | Claude에게 주는 규칙·소통 방식·보안 규칙 | Claude가 작업할 때마다 자동 |
| **README.md** | 작업 공간 전체 안내도 | 처음 둘러볼 때 |
| **SECURITY.md** | 키 노출 등 비상 대응 절차 | 🚨 사고 의심될 때 |
| **.env** | API 키·비밀번호 같은 비밀 정보 | 키가 필요할 때 (열어보기만) |
| **tasks/todo.md** | 앞으로 할 일 목록 | 작업 **시작** 시 |
| **tasks/progress.md** | 끝낸 일 기록 | 작업 **종료** 시 |

---

## 🔄 기본 작업 흐름

1. **시작** — `tasks/todo.md` 에서 오늘 할 일 확인
2. **진행** — 큰 작업(3단계 이상)은 todo.md에 계획부터 적고 OK 받기
3. **확인** — "다 했다" 선언 전에 실제로 돌려보고 결과 확인
4. **기록** — `tasks/progress.md` 에 한 일 한 줄 남기기

---

## 🔒 보안 핵심 규칙 (자세한 건 CLAUDE.md / SECURITY.md)

- API 키·비밀번호는 항상 **마스킹**해서 표시 (`sk-or-v1-***`)
- `.env`, `*.key`, `*.pem` 등은 **절대 Git에 올리지 않기**
- 코드에 키 **하드코딩 금지** — 환경변수만 참조
- 키 노출 의심 → 즉시 **`SECURITY.md`** 순서대로 대응

---

## ⚠️ 위험한 작업은 항상 먼저 물어봄

파일 삭제 / DB 파괴 / Git 되돌리기 / 서버 재설치 등은
Claude가 실행 전에 **"이 작업은 되돌릴 수 없어요. 진행할까요?"** 라고 확인합니다.

---

## 🔗 관련 경로

- **메인 폴더:** `~/claude-workspace`
- **환경변수:** `~/claude-workspace/.env`
- **오라클 SSH 키:** `~/.ssh/oracle-server.key`
- **오라클 서버 별칭:** `oracle-server`

---

*이 작업 공간은 안전하고 단계적인 작업을 위해 만들어졌습니다. 천천히, 한 단계씩.*
