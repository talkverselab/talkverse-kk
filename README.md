# 카자흐어유니버스 (kk)

한국어 화자를 위한 카자흐어(키릴) 학습 앱 — Flutter, Android + iOS.

- 앱 코드: `app/` — 규칙·이름·배포 방법은 **`app/CLAUDE.md`** 가 기준이다.
- 2026-11-08 초기 빌드: 몽골어앱 구조(메뉴·회화 리더·접사 사전·단어 화면·로그인)만 있고 학습 콘텐츠는 아직 없다.
- 배포: master 푸시 → GitHub Actions → `latest` 릴리스 → 앱 안 「앱 업데이트」. 무선 설치 Zealot(`app/tools/zealot_push.sh`), iOS TestFlight(`app/tools/ios_release.sh`).
