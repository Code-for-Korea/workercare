# 소개 페이지 숫자 산출 방법

소개 페이지(`/about`)의 "알아 두면 좋은 자료"에 쓰인 숫자는 요청마다 계산하지 않고 `config/locales/ko.yml`·`en.yml`의 `about.facts`에 고정 문구로 둔다. 기준일은 2026-11-11이고 기준 데이터는 개발 DB의 판정서 61,815건(`disease_cases`)이다. 정책은 AGENTS.md의 "승인 가능성을 예측하지 않는다"를 따르므로 직업·근무 형태별 인정률은 싣지 않고 전체 분포만 싣는다.

갱신하려면 적재 뒤 아래를 돌려 값을 locale에 옮기고 기준일도 함께 고친다. 읽기만 하는 쿼리다.

```ruby
# bin/rails runner
DiseaseCase.count                              # 전체 건수
DiseaseCase.group(:result).count               # 심의결과 분포
DiseaseCase.minimum(:decided_on)               # 판정일 범위(결측 197건은 DiseaseCase.where(decided_on: nil).count)
DiseaseCase.maximum(:decided_on)
DiseaseCase.group(:year).count                 # 연도별 건수
DiseaseCase.group(:death_status).count         # Y = 사망 관련 결정, nil은 비어 있는 값
DiseaseCase.group(:disease_category).count     # 질병군
DiseaseCase.group(:body_part).count            # 신체 부위(arm=팔, lower_back=허리, leg=다리, other=기타, neck=목)
```

비율은 전체 건수에 대한 값이다. 질병군·신체 부위가 비어 있는(nil) 사례는 분류별 건수에 들지 않는다.

2026-11-11 값: 인정 30,357(49.11%), 일부인정 6,826(11.04%), 변경인정 1,030(1.67%), 불인정 23,602(38.18%), 사망 관련 4,587(7.42%), 근골격계 42,596, 뇌심혈관계 12,547, 기타질병 381, 팔 18,466, 허리 13,805, 다리 4,378, 기타 2,501, 목 2,081.

질병군·신체 부위·사망 여부 같은 추출 컬럼은 LLM이 판정서 본문에서 뽑은 값이라 틀릴 수 있다.
