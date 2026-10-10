> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/entity.md).

# 엔티티

**엔티티(Entity)**&#xB780; 봇이 이해할 수 있는 용어를 체계적으로 정리한 데이터 사전입니다. 엔티티가 정의되어 있다면, 봇은 사용자 발화로부터 사용자의 의도에 맞는 동작 수행을 위한 주요 데이터를 추출할 수 있게 됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F4e3VOQoqsawtY8aPzR6S%2Fentity-tab.png?alt=media&amp;token=05c9726e-55e5-492c-8f78-6b892bd1d97c" alt=""><figcaption><p>'엔티티 설정'은 빠른 접근성과 쉬운 사용성을 위해 대메뉴 우측에 위치하고 있습니다</p></figcaption></figure>

{% hint style="warning" %}
**Definition.**

**사용자 발화란?**\
사용자가 봇과 커뮤니케이션하기 위해 내뱉는 말 또는 텍스트 등을 의미합니다. 챗봇의 경우에는 입력하는 텍스트 데이터이고, 스피커봇의 경우에는 실제 사용자의 음성일 수 있습니다. 사용자 발화는 블록 내 \[**사용자 발화 패턴 설정**] 영역을 통해 입력됩니다.
{% endhint %}

### 엔티티의 구조 <a href="#entity_structure" id="entity_structure"></a>

아래 그림처럼 엔티티 구조를 미리 설계한 후 발화등록 작업을 진행하시면 제작 과정이 훨씬 수월해집니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FTdWFjoJUdzIVQCTtSIEa%2Fentity-structure.png?alt=media&amp;token=e6f33f75-8cfc-42aa-9b7f-304351c1f1c1" alt=""><figcaption><p>'나의 엔티티' 구조 : 사용자가 정의할 수 있는 엔티티는 [엔티티명], [대표엔트리], [동의어] 총 세 가지 요소로 구성됩니다</p></figcaption></figure>

### 엔티티의 종류 <a href="#entity_type" id="entity_type"></a>

챗봇 관리자센터에서 엔티티는 작업자가 직접 정의하는 '나의 엔티티'와 자주 사용하는 엔티티를 미리 정의해놓은 '시스템 엔티티'로 나누어집니다. 특히, '나의 엔티티'에서는 봇이 알아 들어야 하는 주요 용어들을 대표 엔트리로 설정할 수 있으며, 동의어를 추가할 수도 있습니다. 엔티티의 동의어가 중복 등록될 경우 봇에서 판단하기가 어렵기 때문에 원하는 응답이 되지 않을 수 있습니다. 따라서 동의어가 중복되지 않도록 계획적인 설계가 필요합니다.

{% hint style="success" %}
**Tip.**

* 봇을 생성한 직후에는 '시스템 엔티티'만 설정되어 있기 때문에 알아들을 수 있는 용어가 제한적입니다.
* 봇의 특성에 맞도록 '나의 엔티티'를 잘 정의하여 많은 용어를 이해할 수 있도록 하는 것이 좋습니다.
* ‘시스템 엔티티’에 이미 등록되어 있고 ON처리 되어 있는 동의어를 ‘나의 엔티티’에서 추가로 등록할 경우 원하는 응답이 되지 않을 수 있습니다. 이 경우 ‘시스템 엔티티’를 사용하여 주시기 바랍니다.
  {% endhint %}

### 나의 엔티티 <a href="#my_entity" id="my_entity"></a>

'나의 엔티티'는 작업자가 직접 설정한 엔티티입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F9NHLkSFW1vqhJQBjIpqh%2Fentity-mine1.png?alt=media&amp;token=9ac165b3-71ae-4567-b129-b3d15a691abf" alt=""><figcaption><p>'나의 엔티티' 관리 화면: 작업자에 의해 등록된 엔티티 리스트가 나타납니다</p></figcaption></figure>

엔티티는 대표 엔트리를 입력한 후 '동의어'를 입력하는 방식으로 데이터를 완성합니다. 동의어는 필수가 아니지만, 추가로 등록할 경우 사용자 입력발화에서 봇이 인식하는 엔티티의 범위를 넓힐 수 있습니다. 동의어로 엔티티가 인식될 경우 해당 대표 엔트리가 최종값으로 인식되어, 발화 입력 화면에서 출력됩니다.

엔티티명은 공백 없이 입력 가능하며 자음만 입력하는 것은 불가합니다. 대표 엔트리와 동의어는 문자간 최대 1자의 공백 입력이 가능하며 자음만으로 구성할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F8uhAN1j9Gu3TKm78pSWb%2Fentity-mine2.png?alt=media&amp;token=c171fe34-865d-41c6-aaac-a8855ff89a52" alt=""><figcaption><p>'나의 엔티티' 상세 화면: 엔티티는 '대표 엔트리'와 '동의어'로 구성되어 있습니다</p></figcaption></figure>

또한, 정해진 구조의 CSV, xlsx 파일형식으로 대량의 엔트리를 손쉽게 등록할 수도 있습니다. 구성에 변경이 없다면 반복적으로 덮어쓰기가 가능하기 때문에 효율적으로 관리할 수 있습니다. 단, 입력 가능한 엔트리의 총개수는 13,000개입니다.

{% hint style="info" %}
**Information.**

엔트리 업로드 파일(샘플) 다운받기(CSV, xlsx)
{% endhint %}

{% file src="/files/7v0ggrBzuVmBdSqJERVz" %}

{% file src="/files/L3z3PB1tgnQf7IHSmsQz" %}

※ CSV파일은 utf-8로 인코딩 모드를 맞춰주어야 합니다.

### 시스템 엔티티 <a href="#sys_entity" id="sys_entity"></a>

챗봇 관리자센터에서는 날짜, 시간, 지명과 같이 일반적, 공통적으로 통용되는 개념들에 대해서는 작업자가 일일이 입력할 필요가 없도록 미리 정의해 둔 엔티티들을 제공하고 있습니다. 이를 ‘시스템 엔티티’라 부릅니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F6eDiJs5Hm0stQ2L4MaRQ%2F05%402x.png?alt=media&amp;token=31821e06-306a-4597-99ce-55adc3e3d52c" alt=""><figcaption><p>'시스템 엔티티' 리스트 화면: '시스템 엔티티'는 '나의 엔티티'와 마찬가지로 엔티티 설정 메뉴에서 찾을 수 있습니다. '시스템 엔티티'는 엔티티명 앞에 <code>sys.</code>라는 단어로 시작합니다</p></figcaption></figure>

아래는 시스템 엔티티 예시입니다.

<table><thead><tr><th width="228">엔티티명</th><th width="116">설명</th><th width="116">예시</th><th>발화 예시</th></tr></thead><tbody><tr><td>@sys.date</td><td>'날짜'에 해당하는 엔티티를 태깅합니다.</td><td>오늘, 내일, 어제, 2018년 1월15일, 1월 1일, 수요일</td><td><p>오늘 뉴스 들려줘 </p><p>1월 1일은 무슨 요일이야</p></td></tr><tr><td>@sys.date.period</td><td>날짜 중에서 '기간 범위'에 해당하는 엔티티를 태깅합니다.</td><td>이번주, 올해, 주말, 2019년, 1월, 1일부터 10일까지</td><td><p>이번주 사수자리 운세 알려줘 </p><p>올해 무슨 해야</p></td></tr><tr><td>@sys.date.lunar</td><td>날짜 중에서 '음력'에 해당하는 엔티티를 태깅합니다.</td><td>음력 1월1일, 음력 2019년 5월 5일, 올해 음력 5월 16일, 음력 설날</td><td><p>음력 1월 1일이 언제야 </p><p>음력 2019년 5월 5일 양력으로 며칠이야</p></td></tr><tr><td>@sys.date.period.lunar</td><td>날짜 중에서 '음력 기간'에 해당하는 엔티티를 태깅합니다.</td><td>음력 1월, 음력 6월, 음력 8월</td><td><p>정월은 음력 1월을 말합니다 </p><p>음력 8월은 음력에서 여덟 번째 달이다</p></td></tr><tr><td>@sys.time</td><td>'시간'에 해당하는 엔티티를 태깅합니다. ※시간흐름에 따른 date 정보 속성값도 포함됨</td><td>30분, 7시, 10분 뒤, 오전 6시, 30초, 정오</td><td><p>7시 알람 맞춰줘 </p><p>알람 정오 지워줘</p></td></tr><tr><td>@sys.time.period</td><td>시간 중에서 '시간대'에 해당하는 엔티티를 태깅합니다. ※시간흐름에 따른 date 정보 속성값도 포함됨</td><td>오전, 아침, 새벽, 저녁, 1시부터 2시까지</td><td><p>오전 알람 삭제해줘 </p><p>아침 뉴스 틀어줘</p></td></tr><tr><td>@sys.date.time</td><td>날짜 중에서 '날짜와 시간' 조합에 해당하는 엔티티를 태깅합니다.</td><td>내일 7시, 현재, 모레 오후 11시, 내일 오전 7시, 오늘 1시, 1월1일 오후 2시</td><td><p>내일 7시 알람 맞춰줘 </p><p>현재 상영작 알려줘</p></td></tr><tr><td>@sys.date.time.period</td><td>날짜 중에서 '기간 범위와 시간' 조합에 해당하는 엔티티를 태깅합니다.</td><td>오전, 아침, 새벽, 저녁, 1시부터 2시까지</td><td><p>오전 알람 삭제해줘 </p><p>아침 뉴스 틀어줘</p></td></tr><tr><td>@sys.number</td><td>'숫자'에 해당하는 엔티티를 태깅합니다.</td><td>1, 삼, 다섯, 열명, 30개</td><td><p>삼 더하기 삼 </p><p>볼륨 다섯 키 낮춰 줘</p></td></tr><tr><td>@sys.number.times</td><td>숫자 중에서 '회차'에 해당하는 엔티티를 태깅합니다.</td><td>11회차, 40회, 1화, 2부, 1편, 3차, 834회</td><td><p>미우새 1부 틀어줘 로또 당첨 번호 </p><p>제 834회 알려줘</p></td></tr><tr><td>@sys.number.percent</td><td>숫자 중에서 '퍼센트'에 해당하는 엔티티를 태깅합니다.</td><td>20퍼센트, 30프로, 백퍼센트, 50%</td><td><p>블라인드 20퍼센트 정도 열어줘 </p><p>블라인드 30프로만 내려줘</p></td></tr><tr><td>@sys.number.ordinal</td><td>숫자 중에서 '순서'에 해당하는 엔티티를 태깅합니다.</td><td>1번, 첫 번째, 열 번째, 백 번째</td><td><p>플레이리스트 1번 틀어줘 </p><p>네 번째 playlist 재생</p></td></tr><tr><td>@sys.number.age</td><td>숫자 중에서 '나이'에 해당하는 엔티티를 태깅합니다.</td><td>1살, 18세, 스무살, 20세</td><td><p>내 아이는 1살입니다 </p><p>스무살에 대학에 입학했어요</p></td></tr><tr><td>@sys.number.birthyear</td><td>숫자 중에서 '출생년도'에 해당하는 엔티티를 태깅합니다.</td><td>1995년생, 85년생, 72년도생</td><td><p>1996년생 운세 알려줘 </p><p>87년생 운세 알려줘</p></td></tr><tr><td>@sys.number.decade</td><td>숫자 중에서 '년대(~년대)'에 해당하는 엔티티를 태깅합니다.</td><td>1900년대, 2000년대, 80년대, 90년대</td><td><p>90년대 인기 팝 들려줘 </p><p>1990년대 발라드 틀어줘</p></td></tr><tr><td>@sys.number.album</td><td>숫자 중에서 '앨범(~집)'에 해당하는 엔티티를 태깅합니다.</td><td>1집, 2집, 3집, 10집</td><td><p>winner 2집 재생해줘 </p><p>자우림 10집 틀어줘</p></td></tr><tr><td>@sys.number.rank</td><td>단위 중에서 '순위'에 해당하는 엔티티를 태깅합니다.</td><td>1위, 100위, 1등</td><td><p>실시간 이슈 10위 알려줘 </p><p>멜론 차트 10위부터 틀어줘</p></td></tr><tr><td>@sys.unit.duration</td><td>단위 중에서 '기간/시간'을 의미하는 엔티티를 태깅합니다.</td><td>1시간, 1시간 반, 1개월, 4주, 일주일, 이주일, 5년 2개월, 5개월, 5개월 20일, 이틀, 30분 동안, 3일동안, 4분 30초동안</td><td><p>1시간 타이머 시작 </p><p>빗소리 10분 동안 틀어줘</p></td></tr><tr><td>@sys.unit.length</td><td>단위 중에서 '길이'에 해당하는 엔티티를 태깅합니다.</td><td>5mm, 1cm, 10cm, 1m, 1km, 100km, 1야드, 100피트, 20인치, 1마일</td><td><p>1m 간격으로 앉아주세요 </p><p>서울부터 부산까지 거리는 325km입니다</p></td></tr><tr><td>@sys.unit.area</td><td>단위 중에서 '넓이'에 해당하는 엔티티를 태깅합니다</td><td>1제곱미터, 25m², 100km², 1헥타아르, 200헥타아르, 1yd², 200ft², 25평, 30에이커</td><td><p>서울의 면적은 605.2km²입니다 </p><p>152 제곱미터는 몇 제곱킬로미터입니까</p></td></tr><tr><td>@sys.unit.weight</td><td>단위 중에서 '무게'에 해당하는 엔티티를 태깅합니다.</td><td>1g, 1kg, 10kg, 100mg, 100g, 1톤, 100파운드, 10온스, 7그레인, 1돈, 1근, 10냥, 10관</td><td><p>1kg 상자에 넣어주세요 </p><p>금 1돈은 정확히 3.75 그램입니다.</p></td></tr><tr><td>@sys.unit.volume</td><td>단위 중에서 '부피'에 해당하는 엔티티를 태깅합니다.</td><td>1세제곱미터, 1cc, 10ml, 500ml, 10데시리터, 1리터, 100cc, 1갤론, 100cm³, 10m³, 10in³, 10ft³, 1yd³, 1홉, 1되, 1말</td><td>물 1세제곱미터는 약 1 톤 물의 중량이다 1cc는 0.001 리터를 의미한다</td></tr><tr><td>@sys.unit.pressure</td><td>단위 중에서 '압력'에 해당하는 엔티티를 태깅합니다.</td><td>1기압, 20프사이, 20파스칼, 20헥토파스칼, 20킬로파스칼, 20메가파스칼, 100밀리바, 100바, 1수은주밀리미터, 1mmH₂O, 10inHg, 10inchH₂O</td><td>1기압은 몇 파스칼입니까? 1bar는 100kPa 입니다.</td></tr><tr><td>@sys.unit.temperature</td><td>단위 중에서 '온도'에 해당하는 엔티티를 태깅합니다.</td><td>17°c, 20도, 33.8°f</td><td><p>거실 난방 20도로 맞춰줘 </p><p>거실 난방 온도 22도로 맞춰줘</p></td></tr><tr><td>@sys.unit.speed</td><td>단위 중에서 '속도'에 해당하는 엔티티를 태깅합니다.</td><td>100m/s, 1마하, 10km/h, 1knot</td><td>100m/s는 0.1km/s 입니다 10000km/h는 8.17마하입니다..</td></tr><tr><td>@sys.unit.data</td><td>단위 중에서 '정보(데이터량)'에 해당하는 엔티티를 태깅합니다.</td><td>1바이트, 100기가바이트, 100GB, 1TB</td><td><p>1바이트는 8비트 입니다</p><p>1TB는 1024GB입니다.</p></td></tr><tr><td>@sys.unit.energy</td><td>단위 중에서 '에너지 단위'에 해당하는 엔티티를 태깅합니다.</td><td>1헤르츠, 1킬로헤르츠, 1메가헤르츠, 1기가헤르츠, 100데시벨, 10ampre, 10암페어, 10마력</td><td>1Mhz는 1000kHz 입니다</td></tr><tr><td>@sys.unit.currency</td><td>단위 중에서 '통화'에 해당하는 엔티티를 태깅합니다.</td><td>천원, 5천원, 1달러, 100엔, 100위안, 1유로, 오백 파운드, 1파운드, 10프랑, 10센트</td><td><p>1달러 환율이 어떻게 돼? </p><p>1파운드가 한화로 얼마야</p></td></tr><tr><td>@sys.text</td><td>되묻기 상황에서 '유저가 입력한 문장 전체'를 태깅합니다.</td><td></td><td></td></tr><tr><td>@sys.location</td><td>지역 중에서 '국내 지역'에 해당하는 엔티티를 태깅합니다.</td><td>제주도, 강원도, 서울, 송파구, 잠실동</td><td><p>제주도 날씨 알려줘 </p><p>내일 강원도 날씨</p></td></tr><tr><td>@sys.nation</td><td>'국가명'에 해당하는 엔티티를 태깅합니다.</td><td>대한민국, 프랑스, 일본, 영국, 미국</td><td><p>1월 7일 대한민국 날씨 알려줘 </p><p>지금 프랑스 파리 몇시야?</p></td></tr><tr><td>@sys.state</td><td>지역 중에서 '해외 주 단위'에 해당하는 엔티티를 태깅합니다.</td><td>캘리포니아, 버몬트, 뉴저지, 콜로라도</td><td>지금 캘리포니아 몇 시야 미국 뉴저지 시간은 어떻게 돼요</td></tr><tr><td>@sys.city</td><td>지역 중에서 '해외도시명'에 해당하는 엔티티를 태깅합니다.</td><td>뉴욕, 도쿄, 워싱턴 D.C., 베이징, 런던</td><td><p>오늘 뉴욕 날씨 좋아? </p><p>워싱턴 D.C.와 베이징의 시차 알려줘</p></td></tr><tr><td>@sys.fortune.starsign</td><td>'별자리 이름'에 해당하는 엔티티를 태깅합니다.</td><td>물병자리, 물고기자리, 게자리</td><td><p>이번주 물병자리 운세 알려줘 </p><p>1월 이달의 사자자리 운세 어때</p></td></tr><tr><td>@sys.fortune.zodiac</td><td>'띠 이름'에 해당하는 엔티티를 태깅합니다.</td><td>돼지띠, 쥐띠, 소띠</td><td><p>이번주 돼지띠 운세 알려줘 </p><p>토끼띠는 몇 년생이야</p></td></tr><tr><td>@sys.person.name</td><td>'인물 : 개인'에 해당하는 엔티티를 태깅합니다.</td><td>아이유, 박지성, 김광석</td><td><p>아이유 인기곡 들려줘 </p><p>박지성에 대해서 알려줘</p></td></tr><tr><td>@sys.person.group</td><td>'인물 : 그룹명'에 해당하는 엔티티를 태깅합니다.</td><td>엑소, exo, 퀸, queen, 블랙핑크, blackpink, 방탄소년단, bts</td><td><p>방탄소년단 최신 앨범 틀어줘 </p><p>퀸 1991년 앨범 틀어줘</p></td></tr><tr><td>@sys.currencyname</td><td>'통화명'에 해당하는 엔티티를 태깅합니다.</td><td>달러, 엔, 유로, 오스트레일리아달러, 베트남동, 파운드</td><td><p>미국의 통화는 달러입니다 </p><p>영국의 화폐단위는 파운드입니다.</p></td></tr><tr><td>@sys.currency.code</td><td>'통화 코드'에 해당하는 엔티티를 태깅합니다.</td><td>USD, JPY, EUR, AUD, VND, GBP, ZWD</td><td>일본 화폐인 '엔'의 통화코드는 JPY입니다.</td></tr><tr><td>@sys.sports.name</td><td>스포츠 정보 중에서 '종목명'에 해당하는 엔티티를 태깅합니다.</td><td>야구, 축구, 태니스, 태권도</td><td><p>오늘 축구 경기 있어? </p><p>내일 야구 일정 알려줘</p></td></tr><tr><td>@sys.sports.league</td><td>스포츠 정보 중에서 '리그명'에 해당하는 엔티티를 태깅합니다.</td><td>프리미어리그, NBA, KBO리그, mlb</td><td><p>작년 프리미어리그 순위 알려줘 </p><p>이번달 KBO리그 경기 있어?</p></td></tr><tr><td>@sys.sports.team</td><td>스포츠 정보 중에서 '팀명'에 해당하는 엔티티를 태깅합니다.</td><td>리버플, 토트넘, 맨체스터 유나이티드, KIA 타이거즈</td><td><p>2018년 1월15일 리버풀 경기 알려줘 </p><p>토트넘 경기에 손흥민 나왔어?</p></td></tr><tr><td>@sys.sports.stadium</td><td>스포츠 정보 중에서 '경기장'에 해당하는 엔티티를 태깅합니다.</td><td>잠실 종합 운동장 야구장, 수원 월드컵 경기장, 대구 스타디움, 문학 경기장</td><td><p>상암월드컵 경기장 축구 경기 있어? </p><p>대구 스타디움 경기장 오늘 일정 없어?</p></td></tr><tr><td>@sys.tv.name</td><td>TV 정보 중에서 '프로그램명'에 해당하는 엔티티를 태깅합니다.</td><td>무한도전, 라디오 스타, 런닝맨</td><td><p>오늘 라디오 스타에 누구 나와? </p><p>런닝맨 멤버 알려줘</p></td></tr><tr><td>@sys.tv.channelname</td><td>TV 정보 중에서 '채널명'에 해당하는 엔티티를 태깅합니다.</td><td>tvn, mbc, kbs 1tv, ocn, jtbc</td><td><p>지금 tvn에서 뭐 해? </p><p>mbc 편성표 알려줘</p></td></tr><tr><td>@sys.radio.name</td><td>라디오 정보 중에서 '프로그램명'에 해당하는 엔티티를 태깅합니다.</td><td>음악캠프, 정오의 희망곡, 별이 빛나는 밤에, 정지영 라디오</td><td>배철수의 음악캠프에 나온 노래 들려줘 정지영 라디오 선곡표 들려줘</td></tr><tr><td>@sys.radio.channelname</td><td>라디오 정보 중에서 '채널명'에 해당하는 엔티티를 태깅합니다.</td><td>MBC FM 4u, SBS 러브FM, kbs1 라디오</td><td><p>mbc fm 4u 틀어줘 </p><p>sbs 파워 fm 틀어줘</p></td></tr><tr><td>@sys.movie.name</td><td>콘텐츠 정보 중에서 '영화명'에 해당하는 엔티티를 태깅합니다.</td><td>신과 함께, 킹스맨, 어벤져스 인피니티 워</td><td><p>신과 함께 관객수 알려줘 </p><p>영화 킹스맨 장르 알려줘</p></td></tr><tr><td>@sys.organization.name</td><td>콘텐츠 정보 중에서 '제작사'에 해당하는 엔티티를 태깅합니다.</td><td>디즈니, 월트디즈니픽쳐스, 마블 스튜디오, 롯데엔터테인먼트</td><td><p>디즈니에서 제작한 영화 알려줘 </p><p>마블 스튜디오에서 만든 영화 뭐 있어?</p></td></tr><tr><td>@sys.theater.name</td><td>콘텐츠 정보 중에서 '극장명'에 해당하는 엔티티를 태깅합니다.</td><td>CGV천호점, 메가박스, 롯데시네마</td><td>cgv천호점 상영영화 알려줘 메가박스 개봉작 알려줘</td></tr><tr><td>@sys.broadcast.name</td><td>콘텐츠 정보 중에서 '방송사'에 해당하는 엔티티를 태깅합니다.</td><td>KBS, MBC, SBS, 극동방송, 불교방송</td><td>극동방송 틀어줘 불교방송 틀어 주세요</td></tr><tr><td>@sys.url</td><td>문장에서 'URL'에 해당하는 패턴을 태깅합니다.</td><td>https://www.kakaocorp.com, http://www.kakaocorp.com, www.kakaocorp.com</td><td>카카오의 공식사이트는 https://www.kakaocorp.com 입니다.</td></tr><tr><td>@sys.bussiness.number</td><td>문장에서 '사업자등록번호'에 해당하는 패턴을 태깅합니다.</td><td>120-81-47521</td><td>카카오의 사업자등록번호는 120-81-47521 입니다.</td></tr><tr><td>@sys.phone.number</td><td>문장에서 '전화번호'에 해당하는 패턴을 태깅합니다.</td><td>010-1234-5678, 02-2456-7890</td><td>전화번호는 010-1234-5678 입니다.</td></tr><tr><td>@sys.licenseplate.number</td><td>문장에서 '차량번호'에 해당하는 패턴을 태깅합니다.</td><td>12 가 1234, 123 가 1234</td><td><p>차량번호는 12 가 1234 입니다. </p><p>123 가 1234 번호가 제 차량입니다.</p></td></tr></tbody></table>

상세한 설정 방법은 [**엔티티 설정하기**](#setting_entity)를 참조하시길 바랍니다.

## 엔티티 설정하기 <a href="#setting_entity" id="setting_entity"></a>

### 엔티티 등록하기 <a href="#input_entity" id="input_entity"></a>

아래와 같이 두 가지 방법으로 챗봇 관리자센터에 엔티티를 등록할 수 있습니다.

#### 엔티티에서 등록하기 <a href="#input_in_entity" id="input_in_entity"></a>

**엔티티** 버튼을 눌러 엔티티를 미리 정의할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fq8d08CpBBjW7Qg1qSaPo%2Fentity-create-01.png?alt=media&amp;token=bea0b3b4-1d42-4022-bf45-b6c723402672" alt=""><figcaption><p>엔티티 설정 위치 : 봇 생성 후 우측 상단에서 확인 가능합니다.</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fs5zDYJoVYwYm4xcQvZAU%2Fentity-create-02.png?alt=media&amp;token=51aaa013-53d7-4c87-8986-eea9612ab2c5" alt=""><figcaption><p>엔티티 설정 팝업 화면: 엔티티 생성을 눌러 단어를 추가합니다.</p></figcaption></figure>

미리 정의해 둔 엔티티가 있다면, 발화를 입력할 때마다 손쉽게 해당 엔티티를 **사용자 발화 패턴**에서 **태깅**이 가능하도록 밑줄 하이라이트가 표시 됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FucC5evdPSRLr5ViXA3bm%2Fentity-create-03.png?alt=media&amp;token=31d45231-1d4d-46eb-be3c-297847a46756" alt=""><figcaption><p>밑줄 하이라이트 : 예상 발화를 입력하면, 엔티티로 태깅 될 수 있는 단어가 밑줄로 표시됩니다.</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FRAe4frNiTJHI24grsSvx%2Fentity-create-04.png?alt=media&amp;token=c9eded25-5d70-4874-b366-0c91cc0ceefd" alt=""><figcaption><p>엔티티 태깅: 밑줄로 하이라이트 된 단어를 마우스로 드래그 하면, 선택된 부분에 필요한 엔티티를 태깅할 수 있습니다. 봇 작업자가 부여할 수 있는 <strong>추천 엔티티</strong>, 또는 더 넓게 찾아볼수 있는 <strong>전체 엔티티</strong> 메뉴를 제공합니다.</p></figcaption></figure>

**엔티티 태깅 중 새 엔티티 추가하기 버튼을 통해 등록하기**

봇 작업자는 발화 입력 후 중요하게 생각하는 단어를 즉시 엔티티로 만들 수 있습니다. 입력된 발화 중 특정 단어를 드래그하면 태깅이 가능한 엔티티 메뉴를 볼 수 있습니다. 필요에 따라 팝업창 하단의 새 엔티티로 추가하기 버튼을 통해 추가 엔티티 설정이 가능합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FfUrGPxX7fy6pnwQK3QNb%2Fentity-create-05.png?alt=media&amp;token=1c6d02aa-24bd-47bb-87be-14b150201185" alt=""><figcaption><p>발화 작성시 특정 단어 드래그를 통한 추가 엔티티 작성 및 반영 모습</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FsmPd1ldVeqWCI3Q6SYYc%2Fentity-create-06.png?alt=media&amp;token=3b58e03f-a3ef-4820-874b-b4ca56c858fb" alt=""><figcaption><p>블록 내 ‘발화입력’ 화면 : ‘라떼’에 해당하는 ‘coffee_name’ 엔티티가 매핑되어 박스로 표시되는 모습</p></figcaption></figure>

### 나의 엔티티 작성 예시 <a href="#example_input_entity" id="example_input_entity"></a>

#### 엔티티 작성의 좋은 예 <a href="#good_example_of_entity" id="good_example_of_entity"></a>

엔티티를 잘 작성한다는 것은 사용자의 발화문에서 의미있는 단어를 추출해내는 기초 작업을 튼튼히 하는 것을 뜻합니다. 그래야 발화 패턴을 인식하는 자연어처리 로직을 십분 활용할 수 있고, 다양한 발화 형태 속에 존재하는 중요한 단어를 보다 정확히 발췌할 수 있습니다. 올바르게 작성된 엔티티 예시는 아래와 같습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FFjdaTMAWhiyAQYB7vLm9%2Fentity-good.png?alt=media&amp;token=9057afee-66c6-41d8-911c-60eeed9a5551" alt=""><figcaption><p>바람직한 엔티티 작성 예시</p></figcaption></figure>

{% hint style="success" %}
**Tip.**

* 의미있는 데이터 중심으로 엔티티를 구분 합니다. 예) cafe\_name(카페명), coffee\_name(커피메뉴), user\_action\_order(사용자행동패턴), service\_type(주문서비스방식))
* 엔티티 간 단어들이 중복되지 않고, 의미가 겹치지 않도록 합니다.
* 엔티티 목록만 보아도 누구나 의미를 쉽게 유추할 수 있도록, 엔티티명을 명확하게 정의합니다.
  {% endhint %}

**엔티티 작성의 나쁜 예**

봇 디자이너가 사용자 발화의 모든 형태를 **정확한 매칭(exact matching)**&#xC73C;로 잡아내겠다는 의지로 모든 발생 가능할 단어를 엔티티로 등록해버리면 발화 패턴이 매우 복잡해집니다. 뿐만 아니라 향후 엔티티 유지보수 또한 어려워지게 됩니다. 결국엔 하나의 등록으로 충분한 발화패턴을, 굳이 수십여개로 만들어내야하는 엔티티 작성 부담을 불필요하게 발생시킬수 있습니다. 엔티티 작성의 핵심 포인트는, 사용자 발화입력 패턴을 잡아내는데 있어서 가장 필수적인 단어(또한, 여러 형태로 변경 가능한 단어)를 엔티티로 일괄 등록하는 것 입니다.

부적절한 엔티티 작성 예시는 아래와 같습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fz0KNygouCYsv1ymqutrk%2Fentity-bad.png?alt=media&amp;token=2dd7c5a4-964b-465f-baf8-aee324870a6c" alt=""><figcaption><p>사용자가 엔티티 등록시 지양해야하는 작성 예시</p></figcaption></figure>

{% hint style="success" %}
**Tip.**

* '좀, 그렇게, 어떻게' 등 발화문장에서 큰 의미가 없는 모든 발생가능한 단어들을 엔티티로 등록하는 것은 피하도록 합니다. 엔티티 태깅을 통해 중요 정보를 추출해내는 관점에서 크게 중요하지 않기 때문입니다.
* 유의미한 데이터로 구성한 카테고리가 아닌, 사용자 발화 중 중요하지 않은 단어들을 모두 번거롭게 등록할 필요는 없습니다. 향후 의미없는 작업노고를 발생시키는 원인이 됩니다. 예) '네', '갑니다', '주세요', '안되겠네' 등과 같은 서술어미 종류
  {% endhint %}


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/entity.md
