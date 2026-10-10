> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/scenario.md).

# 시나리오

**시나리오(Scenario)** 는 봇 안에서 사용자가 경험할 수 있는 서비스 단위입니다.

예를 들어 금융과 관련된 서비스를 제공하는 봇이 있다고 가정하면 이 봇이 제공할 수 있는 서비스 단위, 즉 시나리오는 ‘예금’, ‘적금’, ‘대출’, ‘연금’, ‘방카슈랑스’ 등이 될 수 있습니다.

챗봇 관리자센터에서는 사용자의 의도(Intent)를 응대하는 가장 작은 단위를 블록(Block)이라고 하는데, 하나의 시나리오는 다양한 블록들이 모여서 이루어지게됩니다. 즉, 봇 작업자는 이러한 시나리오 단위로 다수의 블록들을 원하는 서비스 별로 그룹핑하여 체계적으로 관리할 수 있습니다.

## 시나리오의 종류 <a href="#scenario_type" id="scenario_type"></a>

### 기본 시나리오 <a href="#basic_scenario" id="basic_scenario"></a>

기본 시나리오는 모든 봇에 장착되어 있으며, 다음의 3개 블록을 항상 포함하고 있습니다.

<table><thead><tr><th width="193">기본 제공 블록</th><th>설명</th></tr></thead><tbody><tr><td>웰컴 블록(Welcome)</td><td>봇이 사용자를 처음 만날때 발송하는 웰컴메세지를 정의함</td></tr><tr><td>폴백 블록(Fallback)</td><td>봇이 사용자의 발화 의도를 이해하지 못할때 내뱉는 메시지를 정의함</td></tr><tr><td>탈출 블록(Exit)</td><td>봇의 되묻기 상황등에서 사용자가 대화를 초기화하거나 탈출하고 싶을때 쓰는 사용자 명령어를 정의함</td></tr></tbody></table>

### 커스텀 시나리오 <a href="#custom_scenario" id="custom_scenario"></a>

커스텀 시나리오는 봇 작업자가 서비스 단위 등으로 구분하며 지속 생성할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FiAiYQEZtFkItk5BS8Y0m%2Fscenario-adding-01.webp?alt=media&amp;token=09cfe6f2-f22d-4889-80cd-390a82a2d417" alt=""><figcaption><p>시나리오 대메뉴 이하에 위치한 '+ 시나리오' 버튼을 누르면 위와 같이 ‘커스텀 시나리오’를 계속해서 생성할 수 있습니다</p></figcaption></figure>

## 시나리오 설정 <a href="#scenario_setting" id="scenario_setting"></a>

시나리오 설정 메뉴에서 모든 시나리오에 공통적으로 적용할 수 있는 ‘속성’을 정의할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FyIdEre6xVAYuuydtKaPP%2Fscenario-configure-01.webp?alt=media&amp;token=bb3b2105-2425-4bf6-bb1a-35b2e8622bcb" alt=""><figcaption><p>시나리오 설정 메뉴 위치</p></figcaption></figure>

현재 봇 작업자는 다음과 같이 두 가지 시나리오 속성을 정의할 수 있습니다. (기능은 지속적으로 추가할 예정입니다.)

### 되묻기 질문 <a href="#ask_back_question" id="ask_back_question"></a>

대표적으로 봇 작업자가, 봇이 사용자로부터 특정 정보 (= ’파라미터값’ 이라고 합니다. [**파라미터 설정**](/main/tool/chatbot/main_notions/setting_parameter.md) 참조)를 획득까지 물어보는 질문을 ‘되묻기 질문’이라고 하며, 이를 본 설정 메뉴안에서 직접 정의할 수 있습니다.

* 최대 횟수(8회까지) 및 초과시 안내 메시지
* 되묻기 대기 시간 (10분/20분/30분/60분/120분) & 초과시 안내 메시지

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FGYs9ztlA53jyStPnh9mf%2F%E1%84%89%E1%85%B5%E1%84%82%E1%85%A1%E1%84%85%E1%85%B5%E1%84%8B%E1%85%A9%20%E1%84%89%E1%85%A5%E1%86%AF%E1%84%8C%E1%85%A5%E1%86%BC.png?alt=media&amp;token=659eabb8-0e20-4312-834b-ebea3d2de595" alt=""><figcaption><p>시나리오 설정 안에서, 블록 공통 되묻기 질문 속성을 각각 클릭하여 정의할 수 있습니다.</p></figcaption></figure>

### 봇 리스트 메뉴 <a href="#bot_generic_menu" id="bot_generic_menu"></a>

봇 리스트 메뉴는 챗봇 안에서 하단에 슬라이드 메뉴 형태로 존재하는 사용자 인터페이스를 의미합니다.

챗봇 사용자가 아래에서 위로 해당 공간을 쓸어 올려 언제나 중요 필수 메뉴를 쉽게 접근할 수 있습니다. 봇 작업자는 시나리오 설정 내 봇 리스트 메뉴 사용 여부를 ON/OFF 형태로 설정할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FfFbvkLhmHUuGsTcAWbla%2F%E1%84%87%E1%85%A9%E1%86%BA%20%E1%84%85%E1%85%B5%E1%84%89%E1%85%B3%E1%84%90%E1%85%B3.png?alt=media&amp;token=127e645a-1fbb-4130-a98b-3cbde789de4e" alt=""><figcaption><p>챗봇 관리자센터 내에서 봇 리스트 메뉴 설정의 모습. 스위치를 On하면 카카오톡 사용자 프론트 화면과 리스트 메뉴 예시가 나타납니다.</p></figcaption></figure>

* 챗봇 관리자센터의 봇 리스트 메뉴는 개발 채널을 연결해야 노출되며 수정을 한 뒤 배포를 해야 운영 채널의 리스트 메뉴에 반영됩니다.
* 리스트 메뉴는 설정 후 노출될 때까지 일정 시간이 필요합니다.

{% hint style="info" %}
**Information. 리스트 메뉴에서 ‘상담 연결’ 설정하기**

\
리스트 메뉴 내에서 '상담 연결' 버튼을 사용하기 위해서는 봇에 연결된 채널이 1)[**채널관리자센터의 1:1 채팅**](https://accounts.kakao.com/login/kakaoforbusiness?continue=https://center-pf.kakao.com/profiles) 혹은 2)[**상담톡**](https://business.kakao.com/info/bizmessage/) 기능을 사용하고 있어야 합니다.

\
’상담 연결’기능을 사용하기 위해서는 아래 조건을 충족해야 합니다.

1. 운영 채널과 개발 채널을 모두 연결해야 합니다.
2. 운영 채널과 개발 채널에의 1:1 채팅 혹은 상담톡이 모두 ON이 되어 있어야 합니다.

[**채널관리자센터의 1:1 채팅**](https://accounts.kakao.com/login/kakaoforbusiness?continue=https://center-pf.kakao.com/profiles)을 사용하는 경우 리스트 메뉴에 노출되며, 리스트 메뉴를 사용하지 않으면 채팅창 우측에 버튼으로 노출 됩니다.

\
상기 조건이 충족되는 경우 봇 리스트 메뉴에서 '상담 연결' 버튼을 최상단 또는 최하단으로 이동할 수 있습니다.\
해당 봇을 배포하면 챗봇 관리자센터에 연결한 운영 채널에도 동일한 봇 리스트 메뉴 설정이 적용됩니다. (단, 운영 채널에도 상담 연결 설정이 되어있어야 합니다.)
{% endhint %}

{% hint style="info" %}
**Information. 리스트 메뉴 내 '상담 연결' 버튼 ON/OFF 설정하기**

\
[**상담톡**](https://business.kakao.com/info/bizmessage/) 기능과 봇을 함께 사용하고 있을 경우 리스트 메뉴의 '상담 연결'은 [**채널 관리자센터**](https://accounts.kakao.com/login/kakaoforbusiness?continue=https://center-pf.kakao.com/profiles) **> 관리 > 상세설정** 에서 ON/OFF기능으로 노출여부를 제어할 수 있습니다.

\
\*상담 연결 메뉴는 해당 채널이 상담톡을 사용하거나 채널관리자센터의 1:1채팅을 이용하는 경우 노출됩니다.

\*상담 요일 노출은 상담톡일 경우에만 노출됩니다

\*챗봇 관리자센터 >시나리오 설정 > 리스트 메뉴에서 보이는 화면은 개발 채널과 연동된 내용으로, 운영 채널에서의 on/off 여부는 실제 카카오톡에서 확인 가능합니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F6RTblDslnwzE5SL0yyNo%2Fscenario-generic-settings2.png?alt=media&amp;token=5c229f66-1ceb-4e8a-9e53-89cda3491f9d" alt=""><figcaption><p>리스트 메뉴 적용의 모습 (예시 : 카카오고객센터 카카오톡 채널 챗봇)</p></figcaption></figure>

{% hint style="info" %}
**Information. 리스트 메뉴가 보이지 않을 경우**

1. \[[**챗봇 관리자센터**](https://chatbot.kakao.com/) > 시나리오 > 시나리오 설정]에서 ON으로 되어 있는지 확인해 주세요.
2. 봇 리스트 메뉴를 사용하고자 하시는 경우 \[[**채널 관리자센터**](https://accounts.kakao.com/login/?continue=https%3A%2F%2Fcenter-pf.kakao.com%2Fprofiles) > 비즈니스도구 > 채팅방 커스텀 메뉴]에서 각 설정을 OFF 해주세요.\
   \- 하단의 슬라이드 메뉴 형태는 챗봇 관리자센터의 "봇 리스트 메뉴"나 카카오톡채널 관리자센터의 "채팅방 커스텀 메뉴"로 설정 가능하며, 동시에 1가지 방법으로만 노출 가능합니다.
   {% endhint %}

상세한 설정 방법은 [**시나리오와 블록 만들기**](#make_scenario_block)를 참조하시길 바랍니다.

## 시나리오와 블록 만들기 <a href="#make_scenario_block" id="make_scenario_block"></a>

### 시나리오 설정하기 <a href="#setting_scenario" id="setting_scenario"></a>

봇 생성후 가장 먼저 해야할 일은 시나리오를 구성하는 것입니다. 블록을 구분하여 담아낼 수 있도록 계획을 세우고, 시나리오에 공통적으로 적용될 기능을 설정합니다. 시나리오 설정 메뉴는 다음 화면처럼 **시나리오** 메인 메뉴 아래 **톱니바퀴** 모양의 설정 아이콘으로 표시되어 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F1onAeSghyBdNAi7D4RnG%2Fscenario-config.png?alt=media&amp;token=6a6cd4f1-0e6c-47c4-8221-8ea27d17e9ef" alt=""><figcaption><p>시나리오 설정 메뉴 위치</p></figcaption></figure>

시나리오 설정 메뉴안에서 봇 작업자는 봇에서 만든 모든 시나리오에 공통적으로 적용할 수 있는 시나리오 속성, 즉 1) 봇의 **되묻기 기능**에 대한 기본 설정과 2) 챗봇 사용자를 위한 **봇 리스트 메뉴**를 설정할 수 있습니다.

**되묻기 기능 공통 설정**

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FikyxAMCKdS2CSbd2C97a%2F%E1%84%83%E1%85%AC%E1%84%86%E1%85%AE%E1%86%AE%E1%84%80%E1%85%B5%20%E1%84%80%E1%85%B5%E1%84%82%E1%85%B3%E1%86%BC%20%E1%84%80%E1%85%A9%E1%86%BC%E1%84%90%E1%85%A9%E1%86%BC%E1%84%89%E1%85%A5%E1%86%AF%E1%84%8C%E1%85%A5%E1%86%BC.png?alt=media&amp;token=be11ea7b-c8c8-4c86-a925-00b7593f82f2" alt=""><figcaption><p>시나리오 설정 메뉴안에 있는 되묻기 기능 설정 화면</p></figcaption></figure>

위와 같이 하나의 봇 안에서 쓰이는 모든 시나리오에 공통적으로 적용될 되묻기 기능에 대하여,

* 되묻기 최대 횟수
* 되묻기 최대 시간

를 간단하게 선택하고, 각각의 경우에 대하여 유효 조건을 초과할 때 출력될 안내 메시지를 임의로 작성할 수 있습니다. (필수로 작성되어야하는 영역입니다.)

\
리스트 메뉴를 추가하고 싶으면 '버튼 추가'를 누르면 되며, 버튼 설정은 '버튼 설정'을 통해 할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FZ7XSl3GAmepeTFuyN3Nu%2F%E1%84%8F%E1%85%B1%E1%86%A8%E1%84%89%E1%85%A5%E1%84%87%E1%85%B5%E1%84%89%E1%85%B3%E1%84%86%E1%85%A6%E1%84%82%E1%85%B21.png?alt=media&amp;token=51b84311-189c-455b-b0d6-8bd74fdd6ac7" alt=""><figcaption><p>봇 리스트 메뉴 내 버튼에 대한 사용자 설정 화면</p></figcaption></figure>

버튼 설정에서는 버튼명과 버튼 기능을 직접 지정할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F8oF5VKbjY7TTJVHMzb93%2F%E1%84%8F%E1%85%B1%E1%86%A8%E1%84%89%E1%85%A5%E1%84%87%E1%85%B5%E1%84%89%E1%85%B3%E1%84%86%E1%85%A6%E1%84%82%E1%85%B22.png?alt=media&amp;token=bfb3986f-c5a1-46e7-aecd-c7ffcbbb2337" alt=""><figcaption><p>'퀵서비스메뉴#1' 로 버튼명을 지정했습니다.</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FzB1cpqDL7fKKdPQM4ZSp%2F%E1%84%8F%E1%85%B1%E1%86%A8%E1%84%89%E1%85%A5%E1%84%87%E1%85%B5%E1%84%89%E1%85%B3%E1%84%86%E1%85%A6%E1%84%82%E1%85%B23.png?alt=media&amp;token=be0f90c1-58e7-4ad2-9d86-806d07ea5e5f" alt=""><figcaption><p>'퀵서비스메뉴#2' 로 버튼명을 지정했습니다.</p></figcaption></figure>

이때,

* 버튼명은 14자로 제한됩니다.
* 버튼 기능은 블록 연결 및 메시지 전송 두 가지만 제공됩니다.

블록 연결은 해당 버튼 클릭 시 원하는 블록으로 연결하는 것이며, 메시지 전송은 버튼을 클릭할 때 봇에게 해당 버튼명을 그대로 전송하는 것을 의미합니다.

봇 리스트 메뉴안의 필요한 내용을 모두 작성하고, 확인 버튼을 누르면 작업 내용들이 저장됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fx8T4zYdFYiYVR9mFDhaO%2F%E1%84%8F%E1%85%B1%E1%86%A8%E1%84%89%E1%85%A5%E1%84%87%E1%85%B5%E1%84%89%E1%85%B3%20%E1%84%80%E1%85%A7%E1%86%AF%E1%84%80%E1%85%AA.png?alt=media&amp;token=780f950c-fa08-4798-8e9c-51938f2915e3" alt=""><figcaption><p>봇 리스트 메뉴가 설정 완료된 모습입니다.</p></figcaption></figure>

위의 예시에서 작성된 리스트 메뉴가 카카오톡 채널 챗봇 화면에서 보여지는 모습은 아래와 같습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F0YhTGEXwXRGpNsdEO8vC%2Fscenario-config-generic-menu-06.webp?alt=media&amp;token=72225169-a62e-402d-9a80-f8cd17838101" alt=""><figcaption><p>카카오톡 채널 챗봇 하단에 사용자가 직접 클릭할 수 있는 버튼 두 개가 리스트 메뉴 안에 구현되어있는 모습입니다.</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FKieKA9UYltQt4lhKQVrR%2Fscenario-config-generic-menu-07.webp?alt=media&amp;token=69254e92-1bbf-4c29-bcdd-c16b721eb30e" alt=""><figcaption></figcaption></figure>

리스트 메뉴안의 각 버튼은 기존에 작성된 블록으로 연결될 수 있고, 사용자가 버튼을 누르면 리스트 메뉴 안의 버튼명이 그대로 출력되고 해당 블록의 출력으로 설정된 말풍선이 나타납니다.

### 시나리오 생성하기 <a href="#make_scenario" id="make_scenario"></a>

이제 시나리오를 생성해보겠습니다. 시나리오는 봇 생성 후 메인화면에서 **플러스(+) 버튼**을 클릭할 때 마다 시나리오1, 시나리오2… 순으로 생성됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fl6IXv00HilM4ukYwTHfr%2Fscenario-new.png?alt=media&amp;token=56259dcd-7baa-4c00-8bbd-cf12cfb14bd1" alt=""><figcaption><p>시나리오 추가 기능 위치</p></figcaption></figure>

시나리오의 이름 또한 손쉽게 수정할 수 있으며, 필요하면 삭제도 가능합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Ft1C1HTWt7hbSC2eOi0bT%2Fscenario-new-1.png?alt=media&amp;token=dcf03ff3-76be-4443-860a-c6a4f3174a33" alt=""><figcaption><p>시나리오명칭 우측에 있는 '더보기' 아이콘 클릭 후 '편집'을 클릭하면 이름 수정이 가능합니다</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FQzc98s17t1nyxDeEBtuh%2Fscenario-new-2.png?alt=media&amp;token=55225b1b-7d41-47b6-8d84-1b23c22db9f3" alt=""><figcaption><p>시나리오 명칭 변경 모습</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F3e0Bq0sXszEuoCtEOxfn%2Fscenario-new-3.png?alt=media&amp;token=434742eb-845a-4676-b64b-be958b556cb1" alt=""><figcaption><p>시나리오 명칭 우측에 있는 '더보기' 아이콘 클릭 후 '삭제'를 클릭하면 해당 시나리오가 삭제 됩니다.</p></figcaption></figure>

봇 작업자는 하나의 시나리오 안에는 사용자 의도를 나타내는 ‘블록’들을 \[+ 블록추가] 버튼을 눌러 여러개 작성할 수 있습니다.

### 시나리오 안에서 블록 만들기 <a href="#make_block_in_scenario" id="make_block_in_scenario"></a>

시나리오를 선택하면 기본적으로 우측 화면에 블록의 내용을 바로 채울 수 있는 화면을 볼 수 있습니다. 봇 작업자는 해당 화면의 위에서부터, **사용자 발화 패턴 설정 → 봇 응답형식 설정** 순으로 필요 내용을 작성할 수 있습니다.

이때 **파라미터 설정** 부분은 메뉴가 접혀있습니다. 봇 작업자가 필요에 따라 챗봇 관리자센터의 **스킬**이나 **플러그인** 기능을 이용해야 한다면, 해당 파라미터 설정 부분을 클릭하여 메뉴를 펼치고 필요한 내용을 채우면 됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FQ66rnm8Dd6bXeYxpkluO%2Fscenario-create-block-01-edit.png?alt=media&amp;token=70a451c6-c113-40ad-9de8-33a0245ba5a5" alt=""><figcaption><p>블록 만들기 디폴트 화면</p></figcaption></figure>

참고로, 하나의 봇 안에서 시나리오가 점차 많아지게 되면, 봇 작업자는 특정 시나리오 및 블록들의 콘텐츠 유지보수를 할 때 정확한 위치를 찾기가 어려워질 수 있습니다. 그럴때는 시나리오 메인 메뉴에 있는 검색 창에서 검색 희망 키워드를 입력하면, 그에 해당하는 시나리오 및 블록들이 즉시 하이라이트 되어 나타납니다. 이를 통해 봇 작업자는 필요 업데이트 작업을 빠르게 진행할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FHfw98RJIDlnhQSNtZbjR%2Fscenario-create-block-03.png?alt=media&amp;token=6dbffe61-2289-4ad8-aa71-31897135565f" alt=""><figcaption><p>키워드 검색에 따라 시나리오명이 하이라이트 된 모습</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FkxCDtFkNy3JpPTScbjxe%2Fscenario-create-block-04.png?alt=media&amp;token=d4d50355-7c5a-46d2-82d2-13b31e1f1eec" alt=""><figcaption><p>키워드 검색에 따라 블록명이 하이라이트 된 모습</p></figcaption></figure>

### 시나리오간 블록 이동하기 <a href="#moving_blocks_between_scenario" id="moving_blocks_between_scenario"></a>

봇 작업자는 시나리오안에서 작성된 블록을 타 시나리오로 직접 이동시킬수 있습니다. '블록 이동' 개념이므로, 사본이 생성되어 이동되는 것은 아님을 유의하여 주십시오.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FGtP3c4umjAkStUrayyOm%2Fmoving-block-img-01%402x.png?alt=media&amp;token=94742def-12e0-4ba6-accb-846d84d0bad1" alt=""><figcaption><p>타 시나리오로의 이동이 필요한 블록을 선택하시고, 우측의 '더보기' 버튼을 클릭하면, '이동' 메뉴가 나타납니다. 그리고, '이동' 메뉴를 클릭합니다.</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F6OWEkF5079GqoYR7gvDd%2Fmoving-block-img-02%402x.png?alt=media&amp;token=6895ba99-2f41-42ba-8cd4-ad92292f79f2" alt=""><figcaption><p>블록이동을 위한 안내 팝업을 확인하고, 블록을 이동시킬 시나리오명을 선택해줍니다.</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FqHa8aoDnphesa73OHTPX%2Fmoving-block-img-03%402x.png?alt=media&amp;token=98434bed-c201-4190-a2ef-7e03cc10e5f3" alt=""><figcaption><p>대상 블록이 기존 '시나리오01'에서, 새로운 '시나리오02'라는 지점으로 이동한 것을 알 수 있습니다.</p></figcaption></figure>


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/scenario.md
