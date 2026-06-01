# 🚨 SECURITY.md — 비상 매뉴얼

> **키가 노출된 것 같을 때** 이 문서를 위에서부터 순서대로 따라 하세요.
> 당황하지 말고 **① 폐기 → ② 재발급 → ③ 교체 → ④ 이력 확인** 순서로 진행합니다.

---

## ⏱️ 가장 먼저 (1분 안에)

1. **숨을 고르고**, 어떤 키가 노출됐는지 확인하세요.
   - OpenRouter API 키? (`sk-or-v1-...`)
   - Oracle 서버 SSH 키? (`oracle-server.key`)
   - WordPress 비밀번호/토큰?
2. 노출 경로를 확인하세요. (실수로 공유? 스크린샷? Git 커밋? 공개 채팅?)
3. **즉시 폐기**가 원칙입니다. "아마 괜찮겠지"는 금물.

---

## 🔑 키 종류별 대응

### 1) OpenRouter API 키 (`sk-or-v1-***`)

1. **폐기:** https://openrouter.ai/keys 접속 → 노출된 키 **Delete(삭제)**
2. **재발급:** 새 키 **Create** → 안전한 곳에 복사
3. **교체:** `~/claude-workspace/.env` 파일 열어 `OPENROUTER_API_KEY=새키` 로 교체
4. **이력 확인:** https://openrouter.ai/activity 에서 이상 사용 내역 확인
   - 모르는 사용량/과금이 있으면 즉시 결제수단 점검

### 2) Oracle 서버 SSH 키 (`oracle-server.key`)

1. **폐기:** Oracle 서버에 접속해 `~/.ssh/authorized_keys` 에서 노출된 공개키 줄 삭제
   ```
   ssh oracle-server
   nano ~/.ssh/authorized_keys   # 해당 키 줄 삭제 후 저장
   ```
2. **재발급:** 로컬에서 새 키페어 생성
   ```
   ssh-keygen -t ed25519 -f ~/.ssh/oracle-server.key -C "oracle-server"
   ```
3. **등록:** 새 공개키(`oracle-server.key.pub`)를 서버 `authorized_keys` 에 추가
4. **이력 확인:** 서버 접속 로그 점검
   ```
   sudo last            # 로그인 이력
   sudo grep sshd /var/log/auth.log | tail -50   # SSH 접속 시도
   ```
   - 모르는 IP 접속이 있으면 방화벽/보안그룹 점검

### 3) WordPress 비밀번호/토큰

1. **폐기/변경:** WP 관리자 → 사용자 → 비밀번호 즉시 변경
2. **앱 비밀번호:** 사용자 → 응용 프로그램 비밀번호 → 노출된 항목 **취소(Revoke)**
3. **점검:** 새 관리자 계정이 생겼는지, 이상한 플러그인이 깔렸는지 확인

---

## 🛡️ 노출 예방 체크리스트

- [ ] 키는 **항상 `.env` 파일**에만 저장 (코드에 하드코딩 금지)
- [ ] `.env`, `*.key`, `*.pem`, `id_rsa`, `credentials` 는 **절대 Git에 올리지 않기**
- [ ] `.gitignore` 에 위 패턴이 들어있는지 확인
- [ ] 스크린샷·화면공유 전에 키가 화면에 떠 있지 않은지 확인
- [ ] 키를 채팅·이메일로 보내지 않기

---

## 📞 막힐 때

- 어떤 키인지 모르겠으면 → Claude Code 에게 **"키 노출 의심"** 이라고 말하면 이 매뉴얼대로 안내합니다.
- 절대 혼자 추측해서 서버를 지우거나 포맷하지 마세요. **먼저 물어보세요.**

---

*노출은 누구나 실수할 수 있습니다. 중요한 건 **빠른 폐기와 재발급**입니다.*
