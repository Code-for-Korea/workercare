# DESIGN.md — 화면 디자인 규칙

산재상담실 화면의 원칙, 토큰, 컴포넌트, 접근성 규칙을 정한다. 겉모습만 보고는 디자인 의도를 알 수 없으므로 규칙을 먼저 적는다. 새 화면이나 컴포넌트를 더하기 전에 읽는다.

## 1. 원칙

- **최소 디자인.** 장식을 더하지 않는다. 읽고, 찾고, 누르는 데 필요한 것만 둔다.
- **토큰 우선.** 색, 간격, 글자 크기, 모서리는 `tokens.css`의 변수만 쓴다. 컴포넌트 CSS에 `#hex`, `px`, 임의의 `rem` 값을 직접 쓰지 않는다. 필요한 값이 없으면 토큰을 먼저 더한다.
- **컴포넌트는 고정 변형만.** 버튼은 기본과 `.btn-secondary` 두 가지다. 높이·색을 화면마다 바꾸지 않는다. 변형이 필요하면 이 문서에 먼저 적는다.
- **Tailwind를 쓰지 않는다.**
  - 화면은 erb 25개, 클래스 종류 약 40개다. 직접 쓰는 CSS 500줄 안팎이면 충분하다.
  - `tailwindcss-rails`는 빌드 바이너리, `bin/dev` watcher, Docker 빌드 단계를 늘린다. 지금은 importmap + propshaft로 빌드가 없다.
  - Tailwind **이름 규칙**(`flex`, `items-center`, `gap-2`, `sr-only`, `text-sm`, `whitespace-nowrap`)만 빌려, **실제로 쓰는 유틸리티만** 토큰 기반으로 다시 정의한다.
- 판정 결과(인정·불인정)는 색으로 구분하지 않는다. 승인 가능성을 예측하지 않는다는 서비스 원칙이다.

## 2. CSS 구조

`app/assets/stylesheets/` 아래에 둔다. `stylesheet_link_tag :app`이 모두 싣는다.

| 파일 | 내용 |
|---|---|
| `tokens.css` | 색(밝은 화면, 고대비), 간격, 글자 크기, 모서리, `--control-h`, 큰 글씨 |
| `base.css` | 최소 리셋, 본문·링크·포커스, 폼 요소·표·`details`·`progress` 기본 스타일 |
| `layout.css` | `.container`, `.container-narrow`, 헤더·메뉴·푸터, `.display-settings`, `.grid-auto` |
| `components.css` | 4장의 컴포넌트. 페이지네이션 포함 |
| `utilities.css` | `sr-only`(`visually-hidden` 별칭 포함), `text-muted`, `text-sm`, `whitespace-*`, `flex`, `items-center`, `gap-*` 등 쓰는 것만 |
| `application.css` | 유지한다. 내용을 바꾸지 않고 지우지 않는다 |

모든 파일의 첫 줄은 똑같다. 파일 순서와 상관없이 층 순서가 정해진다.

```css
@layer reset, tokens, base, layout, components, utilities;
```

### 쓰지 않는 CSS 문법

| 금지 | 이유 |
|---|---|
| CSS 중첩(`&`, 규칙 안의 규칙) | 클래스 추출기가 중괄호 깊이로 선택자를 읽는다 |
| 이스케이프된 클래스 이름(`md\:grid-cols-4` 등) | `\`가 들어간 이름은 추출기가 읽지 못한다 |
| `md:` 같은 반응형 접두어 | 대신 `@media` 안에서 컴포넌트 클래스를 바꾼다 |
| `@import` | 파일은 `stylesheet_link_tag`가 싣는다 |

렌더된 HTML과 CSS의 클래스를 맞춰 보는 검사(`test/support/css_class_extractor.rb`, `test/integration/css_classes_test.rb`)가 위 문법을 쓰지 않는다는 전제로 CSS를 읽는다. 금지 문법이 있으면 테스트가 실패한다.

### 정의만 있는 클래스를 두지 않는다

- CSS의 모든 클래스 선택자는 렌더된 HTML 어딘가에서 쓰여야 한다. 렌더된 클래스가 CSS에 없어도 실패한다.
- 정적 grep으로 판단하지 않는다. 헬퍼가 붙이는 클래스와 Pagy가 만드는 HTML이 있다.
- 예외는 `test/support/css_class_allowlist.yml` 하나다. 항목마다 **이유**를 적는다.
  - `unstyled`: HTML에는 있지만 스타일이 없는 클래스(테스트·JS 훅용).
  - `dynamic`: CSS에는 있지만 서버 HTML에 나오지 않는 클래스(JS가 붙이는 `is-active` 등).
- 허용 목록에 더하기 전에 클래스를 지울 수 있는지 먼저 본다.
- 허용 목록에 있는데 더는 필요 없는 항목(이미 스타일이 생겼거나 서버가 그리게 된 클래스)도 테스트가 실패시킨다.
- `application.css`는 매니페스트 주석만 있어 검사에서 빼고, 클래스를 정의하지 않는지만 확인한다.

## 3. 토큰

이름은 고정이다. `tokens.css`가 이 이름을 그대로 구현하고, `test/design/contrast_test.rb`가 이 이름으로 색을 읽는다. 이름을 바꾸면 테스트와 이 문서를 함께 고친다.

### 색

| 토큰 | 밝은 화면(기본) | 고대비 `:root[data-contrast="high"]` | 쓰임 |
|---|---|---|---|
| `--color-bg` | `#ffffff` | `#000000` | 페이지 바탕 |
| `--color-surface` | `#f3f6fb` | `#14181f` | 카드·표 머리글·필터 상자 |
| `--color-text` | `#14181f` | `#ffffff` | 본문 |
| `--color-muted` | `#3b4452` | `#d5dae2` | 보조 글자, 메타 정보 |
| `--color-link` | `#0b3d91` | `#ffe14d` | 링크 |
| `--color-accent` | `#0b3d91` | `#ffe14d` | 기본 버튼 바탕, 강조 |
| `--color-on-accent` | `#ffffff` | `#000000` | 강조색 위의 글자 |
| `--color-border` | `#5b6676` | `#9aa4b2` | 입력·버튼·구분선 |
| `--color-focus` | `#1d4ed8` | `#66d9ff` | 포커스 외곽선 |
| `--color-error` | `#9b1c1c` | `#ff9a9a` | 오류 문구·오류 테두리 |

고대비는 같은 이름의 색 토큰만 바꾼다. 간격·크기는 바꾸지 않는다.

### 간격(0.25rem 단위, 쓰는 단계만)

| 토큰 | 값 | 토큰 | 값 |
|---|---|---|---|
| `--space-1` | 0.25rem | `--space-6` | 1.5rem |
| `--space-2` | 0.5rem | `--space-8` | 2rem |
| `--space-3` | 0.75rem | `--space-12` | 3rem |
| `--space-4` | 1rem | | |

중간 단계가 필요하면 `--space-5`(1.25rem), `--space-10`(2.5rem)를 더한다. 쓰는 곳이 없으면 정의하지 않는다.

### 글자 크기

| 토큰 | 값 | 쓰임 |
|---|---|---|
| `--text-sm` | 0.875rem | 표, 메타 정보 |
| `--text-base` | 1rem | 본문 |
| `--text-lg` | 1.0625rem | h3 |
| `--text-xl` | 1.25rem | h2 |
| `--text-2xl` | 1.5rem | h1. 폭 48rem 이상에서 1.75rem |

### 그 밖의 토큰

| 토큰 | 값 | 쓰임 |
|---|---|---|
| `--radius` | 0.375rem | 버튼·입력·카드 |
| `--control-h` | 2.75rem | 버튼·입력의 높이(44px) |
| `--focus-width` | 3px | 포커스 외곽선 굵기 |

### 큰 글씨

`html { font-size: 100% }`로 고정한다(화면 폭에 따라 커지지 않는다). `:root[data-size="large"] { font-size: 125% }`이면 rem을 쓰는 모든 값이 1.25배가 된다. 그래서 크기는 px이 아니라 rem으로 쓴다.

### 실측 대비(WCAG 2.x 상대 휘도 공식)

기준: 본문·보조 글자·링크·버튼 글자·오류 글자 7:1 이상, 포커스·테두리 3:1 이상. 아래 값은 Ruby 스크립트로 계산했다. 두 테마 모두 모든 조합이 기준을 넘는다.

`test/design/contrast_test.rb`는 아래 조합에 더해 오류 글자 / 표면(7:1)도 두 테마에서 확인한다.

**밝은 화면**

| 전경 / 배경 | 대비 | 기준 |
|---|---|---|
| 글자 / 바탕 | 17.79 | 7:1 |
| 글자 / 표면 | 16.43 | 7:1 |
| 보조 글자 / 바탕 | 9.84 | 7:1 |
| 보조 글자 / 표면 | 9.08 | 7:1 |
| 링크 / 바탕 | 10.04 | 7:1 |
| 링크 / 표면 | 9.27 | 7:1 |
| 버튼 글자 / 강조 | 10.04 | 7:1 |
| 포커스 / 바탕 | 6.70 | 3:1 |
| 테두리 / 바탕 | 5.82 | 3:1 |
| 오류 / 바탕 | 8.15 | 7:1 |

**고대비**

| 전경 / 배경 | 대비 | 기준 |
|---|---|---|
| 글자 / 바탕 | 21.00 | 7:1 |
| 글자 / 표면 | 17.79 | 7:1 |
| 보조 글자 / 바탕 | 14.96 | 7:1 |
| 보조 글자 / 표면 | 12.67 | 7:1 |
| 링크 / 바탕 | 16.13 | 7:1 |
| 링크 / 표면 | 13.67 | 7:1 |
| 버튼 글자 / 강조 | 16.13 | 7:1 |
| 포커스 / 바탕 | 12.93 | 3:1 |
| 테두리 / 바탕 | 8.33 | 3:1 |
| 오류 / 바탕 | 10.34 | 7:1 |

표면 위의 포커스·테두리·오류도 기준을 넘는다(밝은 화면 6.19·5.37·7.52, 고대비 10.96·7.06·8.76). 색을 바꾸면 이 표를 다시 계산해 고친다.

## 4. 컴포넌트

| 컴포넌트 | 언제 쓰나 |
|---|---|
| 버튼 `button`, `[type=submit]` | 채운 강조색. 화면의 주된 동작 하나에 쓴다. 높이는 `--control-h` 하나뿐이다. |
| `.btn-secondary` | 테두리만 있는 버튼. 되돌리기, 초기화 같은 보조 동작이다. |
| 선택 버튼 `ul.choices` | 단계별 사례 찾기의 보기 선택. 흰 바탕 2px 테두리, 왼쪽 정렬, 높이 3rem, 최소 10rem 칸 auto-fill. hover·focus-visible은 테두리와 배경을 함께 바꾼다. `.btn-secondary`(해당 없음·모르겠어요·건너뛰기)는 같은 모양에 점선 테두리라 색 없이도 구분된다. forced-colors에서도 테두리가 보인다. |
| 입력, `.field` | 라벨 위, 입력 아래. 오류는 `[aria-invalid=true]`에 빨간 테두리와 **문구**를 함께 둔다. 라벨 전체를 클릭 영역으로 쓴다. |
| `.search-row` | 검색창 한 줄(단계별 사례 찾기 직접 입력도 같은 줄을 쓴다). 입력은 `flex: 1 1 12rem; min-width: 0`, 버튼은 줄어들지 않는다. 좁거나 글씨가 크면 버튼이 다음 줄로 내려간다. |
| `.notice` | 정보 안내. 왼쪽 굵은 테두리. 상태 알림은 `role="status"`를 붙인다. |
| `.error-summary` | 폼 오류 요약. `role="alert"`. 각 오류 항목은 해당 입력으로 연결한다. |
| `.table-scroll` | 표를 감싸는 가로 스크롤 영역. `role="region"`, `tabindex="0"`, `aria-label`이 반드시 있다. 가로로만 스크롤한다(세로 스크롤 영역을 중첩하지 않는다). 행 구분선만 쓴다. |
| 외부 링크 | 새 창으로 열리는 원문 링크. 아이콘 옆에 `<span class="sr-only">(새 창, 외부 사이트)</span>`를 둔다. `rel="noopener noreferrer"`. |
| `.guide-topic` | 신청 가이드의 주제 하나(`details`). 안의 표는 좁은 화면에서 가로로 스크롤한다. 본문 HTML은 `ApplyGuide::HtmlRenderer`가 만든다. |
| `.case-list` | 사례 목록(검색 결과 아님, 단계별 사례 찾기 결과). 질병명이 제목(상세 링크)이고 나머지는 `text-muted` 한 줄 메타 정보다. 판정 결과를 색으로 구분하지 않는다. |
| `.case-summary` | 결과 화면 사례 목록 위의 쉬운 요약(AI 작성, 참고용) 상자. `turbo-frame#case_summary` 안에 들어가며 만드는 중·실패·요약 없음·완성 네 상태가 같은 상자를 쓴다. 안의 `.notice`는 "원문을 꼭 확인하세요" 고지다. 근거 사례 링크는 `data-turbo-frame="_top"`로 판정서 상세를 연다. 판정 결과를 색으로 구분하지 않는다. |
| `details`/`summary` 아코디언 | 가이드·필터처럼 길고 선택적인 내용. `summary` 안의 `h2`·`h3`는 인라인이고 펼침 표시는 CSS로 만든다. |
| `progress` | 단계별 사례 찾기 진행 표시. 높이 0.5rem. 옆에 "질문 5개 중 3번째" 같은 글자를 함께 둔다. |
| 로딩 오버레이 | 오래 걸리는 요청 중 표시. `prefers-reduced-motion`이면 스피너를 멈춘다. |
| 건너뛰기 링크 | 페이지 맨 앞. 포커스를 받을 때만 보이고 `main#main`으로 간다. |
| `.carried-filters` | `/`·`/search`에서 화면 필터에 입력칸이 없는 조건(직종 핵심어 `job_name_any`, 체크박스 목록 밖 신체부위 토큰)을 보여 주고, hidden 필드로 다시 검색해도 유지하며, [빼기] 링크를 둔다. 주로 단계별 사례 찾기의 '더 자세히 찾기'에서 넘어온다. |
| `.filters` | `/`·`/search`의 필터 묶음 `<details>`. 검색어·정렬·쪽 말고 값이 있는 조건이 있으면 `open`(`search_filters_open?`), 없으면 접어 둔다. 정렬은 이 안에 넣지 않고 바로 아래에 둔다. |
| `.case-meta` | 항목·값 `dl`(상세 머리 정보, 단계별 사례 찾기 확인 화면의 답과 [바꾸기]). 좁은 화면 1열, 40rem 이상 2열. |
| `.check-row` | 동의 체크박스 한 줄. 라벨 전체가 44px 이상 클릭 영역이고, 뒤따르는 안내와 버튼과 간격을 둔다. |
| `.case-text` | 상세 원문 문단. 읽기 폭 70ch, 줄바꿈 보존(`pre-wrap`), `overflow-wrap: anywhere`. |
| 페이지네이션 | Pagy `series_nav` 출력을 토큰으로 스타일한다. 현재 쪽은 `aria-current="page"`와 굵은 밑줄로 표시한다. |
| 화면 설정 `.display-settings` | 헤더의 [큰 글씨]·[고대비] 토글. `aria-pressed`로 상태를 알린다. 5장 참고. |
| 사이트 헤더·메뉴·푸터 | `.site-header`(사이트명, 주 메뉴, 화면 설정), `.site-nav`, `.site-footer`(참고용 고지, 데이터 출처 한 줄). 줄바꿈한다. |
| `.site-name` | 헤더의 사이트명 링크. 굵게, 밑줄 없음. 홈에서는 `aria-current="page"`가 붙는다. |
| `.checkbox-grid` | 체크박스·라디오 격자. 최소 8rem 칸으로 자동 채운다(auto-fill). 라벨 전체가 클릭 영역이다. |
| `.cell-wide` | 표에서 글이 긴 칸(직무 설명, 질병명). 최소 10rem, 최대 12rem이고 단어 중간에서 줄바꿈한다. |
| 컨테이너 | `.container`(최대 72rem), `.container-narrow`(40rem; 단계별 사례 찾기·가이드·소개). 좌우 여백 `--space-4`. |

## 5. 접근성 규칙

WCAG 2.2 AA를 바탕으로 하고 본문 대비만 AAA(7:1)를 목표로 한다. 준수나 인증을 주장하지 않는다.

- **대비.** 3장 표의 기준을 지킨다. `test/design/contrast_test.rb`가 두 테마를 검사한다.
- **포커스.** `:focus-visible`은 `--focus-width`(3px) 외곽선과 `outline-offset`을 쓴다. 어떤 요소에서도 `outline: none`으로 끄지 않는다.
- **터치 영역.** 버튼·입력·메뉴 링크는 높이 44px(`--control-h`) 이상이다.
- **색에만 기대지 않는다.** 현재 메뉴는 굵은 밑줄, 오류는 문구, 선택 상태는 테두리 굵기로도 알린다. 판정 결과는 색으로 구분하지 않는다.
- **움직임.** `prefers-reduced-motion: reduce`이면 스피너와 전환을 멈춘다.
- **OS 고대비.** `prefers-contrast: more`이면 토글과 별개로 고대비 토큰을 기본으로 쓴다.
- **강제 색상.** `forced-colors: active`이면 테두리를 `CanvasText`로 바꿔 경계를 지킨다. 아이콘·표시를 배경 이미지나 색에만 두지 않는다.
- **360px 리플로.** 가로 스크롤이 없어야 한다(표는 `.table-scroll` 안에서만 스크롤). 200% 확대와 [큰 글씨]에서도 같다.
- **긴 문자열.** `word-break: keep-all`(어절 유지)을 기본으로 하고, 넘칠 수 있는 곳에만 `overflow-wrap: anywhere`를 쓴다: `p`, `li`, `dd`, `.case-list`, 상세 본문, 산문 속 `a`, `code`, `.notice`, `.carried-filters`, `.site-footer`. **표 셀에는 쓰지 않는다**(열 최소 폭이 무너진다). 표의 긴 셀만 `overflow-wrap: break-word`. `flex` 자식에는 필요한 곳에 `min-width: 0`.
- **`aria-current`.** 값은 항상 `"page"` 하나다(`true` 금지). 헤더 안에 **최대 하나**다. 경로별 대상은 다음과 같다.

  | 경로 | 표시 |
  |---|---|
  | `/` | 사이트명 링크 |
  | `/search` | [검색] |
  | `/disease_cases/:case_no` | 없음 |
  | `/self-care-form` 및 하위 단계·확인·결과 | [단계별 사례 찾기] |
  | `/apply-guide` | [산재 신청 방법 안내] |
  | `/about` | [소개] |
  | `.md` 응답, 오류 페이지 | 없음 |

- **화면 설정(큰 글씨·고대비).**
  - 쿠키 `display_size`(`large`), `display_contrast`(`high`, `normal`). 1년, `same_site: :lax`, `httponly`. 허용값 외에는 무시한다.
  - 큰 글씨는 쿠키 없음 ⇄ `large`다. 눌러서 끄면 쿠키를 지운다.
  - 고대비는 상태가 셋이다. 쿠키 없음이면 속성이 없어서 OS의 `prefers-contrast: more`를 따른다. `high`는 `data-contrast="high"`, `normal`은 `data-contrast="normal"`이다. [고대비 화면]을 눌러 끄면 쿠키를 지우지 않고 `normal`로 바꾼다. 그래야 OS 설정을 쓰는 사람도 끌 수 있다. 버튼은 쿠키가 `high`일 때만 눌린 상태다.
  - 서버가 `<html data-size="large" data-contrast="high">`를 그린다. JS가 없고 깜빡임이 없다.
  - 눌린 버튼은 `aria-pressed="true"`에 더해 "✓" 표시와 굵은 테두리로 구분한다.
  - 헤더 `role="group" aria-label="화면 설정"` 안에 `POST /display-settings` 폼 둘. 버튼 이름은 고정이고 상태는 `aria-pressed`로 알린다.
  - 폼은 `data-turbo="false"`다. Turbo Drive가 `<html>` 속성을 바꾸지 않기 때문이다.
  - 이 쿠키는 단계별 사례 찾기 세션 쿠키와 별개다. 답은 여기에 두지 않는다. 폼은 `button_to`라서 `form.button_to`가 붙는다. `.display-settings .button_to`로 스타일한다.

## 6. 글꼴(Pretendard)

- **주소(v1.3.9 고정, OFL):**
  - `<link rel="preconnect" href="https://cdn.jsdelivr.net" crossorigin>`
  - `<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">`
- **글꼴 스택:** `"Pretendard Variable", Pretendard, "Apple SD Gothic Neo", "Malgun Gothic", system-ui, sans-serif`. 동적 서브셋이라 화면에 쓰인 글자의 woff2 조각만 받는다.
- **버전 올리기:** 주소의 `v1.3.9`를 바꾸고 화면을 확인한다. `latest`나 범위 표기는 쓰지 않는다.
- **CSP:** 지금 `config/initializers/content_security_policy.rb`는 전부 주석이다. 켜면 `style_src`와 `font_src` **둘 다**에 `https://cdn.jsdelivr.net`을 넣는다. 하나만 넣으면 글꼴이 막힌다.
- **개인정보·가용성 trade-off:** 방문자 브라우저가 jsDelivr에 IP, User-Agent, Referer를 보낸다. 단계별 사례 찾기 단계 주소에는 답이 실리지 않으므로(답은 세션) 주소로 답이 새지 않는다. Referer는 경로를 보내지 않는 `strict-origin-when-cross-origin`이다(Rails 기본과 같다). CDN이 막히면 글꼴만 시스템 글꼴로 바뀌고 기능은 그대로다.
- **자체 호스팅으로 바꾸려면:**
  1. Pretendard 패키지의 `packages/pretendard/dist/web/variable` 아래 `pretendardvariable-dynamic-subset.min.css`와 `woff2-dynamic-subset/`를 `app/assets/`에 둔다.
  2. CSS 안의 `url()` 경로를 propshaft 경로에 맞춘다.
  3. 레이아웃의 CDN `<link>` 두 개를 지운다. CSP를 켰다면 `cdn.jsdelivr.net` 항목도 뺀다.
  4. 라이선스(SIL OFL 1.1) 전문을 함께 둔다.

## 7. 참고

- Evil Martians 디자인 스킬: **design-system**(규칙을 문서에 두고 컴포넌트마다 "언제·어떻게 쓰나"를 적는다)과 **tailwind-best-practices**(임의 값 대신 토큰, 의미로 묶은 토큰, 고정 변형)의 **원칙만** 따른다. 스킬·스크립트는 설치하지 않는다.
- 모두의 키오스크(barrier-free-kiosk): **방식만** 참고한다(고대비·큰 글씨 토글, `aria-pressed`, 44px, 외부 링크 안내). 라이선스가 정해지지 않아 **코드는 가져오지 않는다.** 설정 저장은 `localStorage`가 아니라 쿠키와 서버 렌더링이다.
- 기준은 WCAG 2.2 AA다. 접근성 "준수"나 인증을 주장하지 않는다.
