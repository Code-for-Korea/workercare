> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/tutorial/make_chatbot/tutorial_3.md).

# 튜토리얼 3단계

## 동적인 응답을 할 수 있는 스킬 사용하기 <a href="#use_skill" id="use_skill"></a>

### 블록과 스킬 연결하기 <a href="#connect_block_skill" id="connect_block_skill"></a>

블록에 스킬을 연결하면 더욱 동적인 응답을 만들 수 있습니다.

예를 들어 케이크 메뉴 블록에서 “오늘 추천메뉴 뭐야?” 와 같은 질문에 당일 홈페이지에 올라오는 추천메뉴로 응답을 주고 싶다면, 스킬 연결을 통해 구현할 수 있습니다.

스킬 연결을 위해서는 1) 파라미터 설정을 클릭하여 2) 스킬 선택 목록을 펼친 뒤 미리 등록한 스킬 이름을 선택하면 됩니다. 이렇게 스킬이 연결되면 블록이 실행될 때 스킬이 동작하게 되며 그 결과를 응답 형식 설정에서 이용함으로써 더욱 다양한 응답을 생성할 수 있습니다.

자세한 스킬 사용 방법은 [**스킬 만들기**](/main/tool/chatbot/skill_guide/make_skill.md)를 참고해주세요!

### 기본 카드형 캐로셀 응답 꾸미기 <a href="#make_card_carosel" id="make_card_carosel"></a>

스킬을 활용하여 1단계에서 만들었던 ‘처음으로’ 블록을 생성해 보겠습니다.

아래와 같은 코드로 손수 블록을 하나하나 생성 하는 것이 아닌, 스킬만으로도 응답하고 동작하는 말풍선을 제작할 수 있습니다.

더 자세한 방법은 [**응답 타입별 JSON 포맷**](/main/tool/chatbot/skill_guide/answer_json_format.md)을 참고해 주세요!

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FQUFtHs3nCqtvjPEqIjFP%2Fcake_order_bot_start.png?alt=media&amp;token=a2b2b2ef-c544-46e2-84d6-94be45037b1c" alt=""><figcaption></figcaption></figure>

```
{
    "version": "2.0",
    "template": {
        "outputs": [
            {
                "carousel": {
                    "type": "basicCard",
                    "items": [
                        {
                            "title": "케이크 메뉴",
                            "description": "카카오 케이크의 메뉴를 확인하실 수 있습니다.",
                            "thumbnail": {
                                "imageUrl": "http://k.kakaocdn.net/dn/vzsm1/btr0VKhyDxl/fKXWmwKeB3E8sEaRzGu480/2x1.jpg"
                            },
                            "buttons": [
                                {
                                    "action": "block",
                                    "label": "케이크 메뉴",
                                    "blockId": "63eb2c064a694c1be51a86e3"
                                }
                            ]
                        },
                        {
                            "title": "케이크 픽업",
                            "description": "케이크 픽업 장소가 궁금하신가요?",
                            "thumbnail": {
                                "imageUrl": "http://k.kakaocdn.net/dn/vzsm1/btr0VKhyDxl/fKXWmwKeB3E8sEaRzGu480/2x1.jpg"
                            },
                            "buttons": [
                                {
                                    "action": "weblink",
                                    "label": "케이크 픽업",
                                    "weblinkUrl": "https://place.map.kakao.com/1437795442"
                                }
                            ]
                        },
                        {
                            "title": "SNS",
                            "description": "SNS에서 다양한 카카오 케이크 디자인을 만나보세요!",
                            "thumbnail": {
                                "imageUrl": "http://k.kakaocdn.net/dn/vzsm1/btr0VKhyDxl/fKXWmwKeB3E8sEaRzGu480/2x1.jpg"
                            },
                            "buttons": [
                                {
                                    "action": "weblink",
                                    "label": "SNS",
                                    "weblinkUrl": "https://www.kakaocorp.com/page/"
                                }
                            ]
                        },         
                        {
                            "title": "매장 안내",
                            "description": "케이크 주문 챗봇 매장에 대해서 궁금하신가요?",
                            "thumbnail": {
                                "imageUrl": "http://k.kakaocdn.net/dn/vzsm1/btr0VKhyDxl/fKXWmwKeB3E8sEaRzGu480/2x1.jpg"
                            },
                            "buttons": [
                                {
                                    "action": "message",
                                    "label": "영업시간",
                                    "messageText": "영업시간은 오전 10시부터 오후 8시 입니다."
                                },
                                {
                                    "action": "block",
                                    "label": "자주 묻는 질문",
                                    "blockId": "블록 수정"
                                }
                            ]
                        }
                    ]
                }
            }
        ]
    }
}

```

## 봇이 먼저 톡을 보낼 수 있는 Event Api 활용하기 <a href="#use_eventapi" id="use_eventapi"></a>

### 월렛 <a href="#wallet" id="wallet"></a>

월렛은 챗봇 관리자 센터에서 Event API를 사용할 때 필요한 캐시를 관리할 수 있는 기능입니다. Event API를 통한 메시지를 전송할 때 월렛 생성 및 연결이 필수적입니다.

Event API를 사용하기 위해 월렛에 캐시를 충전하는 방법은 [**월렛**](/main/tool/chatbot/main_notions/wallet.md)을 참고해주세요.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fkn00sYttuGnszasrR2sK%2Ftutorial_eventapi_01.webp?alt=media&amp;token=d03bf3e9-a100-4035-a39b-7f37acf265d8" alt=""><figcaption><p>월렛 이미지</p></figcaption></figure>

### Event API <a href="#eventapi" id="eventapi"></a>

Event API란 일반적으로 사용자가 먼저 대화를 건네면 이에 응답하는 챗봇과는 다르게 **챗봇이 먼저 사용자에게 말을 걸 수 있도록 도와주는 기능**으로 **특정 이벤트에 대한 알림, 안내** 등의 목적으로 사용할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FwQTgXRbAenUrlq7j94hV%2Ftutorial_eventapi_02.webp?alt=media&amp;token=4a846d28-5724-4f07-a9a6-6de4143a69f8" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
**Information.**

Event API는 모두 과금 대상이며, 메시지 1건당 15원(VAT 별도)씩 과금됩니다.
{% endhint %}

Event API를 어떤 상황에 사용할 수 있을지 감을 잡기 어렵다면 [**Event API 활용 예시**](/main/tool/chatbot/main_notions/event-api.md#use_eventapi_example)를 참고하여 똑똑한 선톡을 보낼 수 있는 나만의 챗봇을 구성해 보세요!

## 봇에 맥락을 더해주는 컨텍스트 사용하기 <a href="#use_context" id="use_context"></a>

### 컨텍스트 <a href="#context" id="context"></a>

컨텍스트는 서로 다른 블록 간 ‘연결고리’를 만들고 싶을 때 사용합니다. 서로 다른 의도를 나타내는 블록들이 하나의 컨텍스트로 묶여서 연결될 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fi6ah9SGI527A76qbcEab%2Ftutorial_context_01.png?alt=media&amp;token=f6723683-1fd9-4057-826f-3271b99caf0c" alt=""><figcaption><p>컨텍스트 구조도 도식</p></figcaption></figure>

케이크 주문 챗봇에서 컨텍스트를 사용한다면 케이크 한 개를 먼저 주문하고 추가 주문을 하거나 문구 수정 등 주문 수정이 필요할 때 맥락을 연결하여 활용할 수 있을 것입니다.

더 자세한 내용은 [**컨텍스트**](/main/tool/chatbot/main_notions/context.md)를 참고해주세요!

## 사용자 정보를 편리하게 받기 위한 플러그인 사용하기 <a href="#use_plugin" id="use_plugin"></a>

카카오 싱크 플러그인을 활용하여 손쉽게 회원 가입 및 사용자의 정보를 이용하여 사용자별로 봇 응답을 다르게 내려줄 수 있습니다.

내 챗봇에 잘 적용하여 사용자에게 맞춤 서비스를 제공해 보세요!

### 인증 블록 설정하기 <a href="#use_authentication_block" id="use_authentication_block"></a>

#### Step 1. 채널 - 앱 설정하기

플러그인을 사용하기 위해서는 인증 블록을 설정해야 합니다.&#x20;

처음 봇을 생성할 당시에는 인증 블록이 없으며 이후 채널-앱을 정상적으로 연결하시면 인증 블록이 생성됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fpd7J8b0ffKFzNCXPfOmD%2Ftutorial_cfblock_01.png?alt=media&amp;token=30dcf8c0-8de6-44a4-8acb-e3375b239ebb" alt=""><figcaption><p>인증 블록의 모습</p></figcaption></figure>

인증 블록을 사용하기 위해서는 비즈니스 인증이 필수 입니다.&#x20;

비즈 채널과 앱을 연결 후 인증 블록을 사용할 수 있습니다.

{% hint style="info" %}
**Infornation.**

카카오톡 비즈니스 채널 (인증된 프로필)과 디벨로퍼스 비즈 앱 생성 방법은 [**카카오싱크 공통 가이드**](https://developers.kakao.com/docs/latest/ko/kakaosync/common#table-of-contents)에서 상세하게 확인할 수 있습니다.
{% endhint %}

#### Step 2. 봇에 채널 설정하기

카카오 비즈니스 관리자 센터에서 운영 개발 채널을 생성하고 동일한 앱에 연결을 완료했다면 챗봇 관리자센터에서 해당 채널-앱을 설정합니다. 상세한 설정 방법은 [**카카오톡 채널 연결하기**](/main/tool/chatbot/tutorial/make_chatbot/tutorial_1.md#connect_bot_channel)를 참고하시길 바랍니다.

챗봇 관리자 센터 내 ‘인증 블록'에서 필수 파라미터 설정 후 일반 블록과 연결하여 플러그인을 이용할 수 있습니다.

{% hint style="danger" %}
**Caution.**

만일, 인증 블록 설정 후 채널/앱 정보에 변동사항이 있는 경우 플러그인이 정상 동작하지 않을 수 있습니다. 아래 사항을 확인 후 반드시 인증 블록을 초기화 및 재설정해 주시기를 바랍니다. 또한 인증 블록과 연결된 블록 버튼도 재설정이 필요합니다.
{% endhint %}

{% hint style="info" %}
**Information**

**두 채널 모두 봇과 연결 필요**

* 운영 채널 또는 개발 채널만 연결되어 있는지 확인

**싱크, 회원가입 플러그인의 경우**

* \[디벨로퍼스 > 앱 > 제품 설정 > 카카오 로그인 > 간편 가입]에서 사용 설정 상태가 'ON'으로 되어 있는지 확인
* 디벨로퍼스의 '카카오싱크 플러그인 리다이렉트 URI'가 정상적으로 입력되어 있는지 확인 - URI가 유효해야 함

**디벨로퍼스 앱과 봇이 연결된 경우**

* 봇 마스터가 채널과 연결된 디벨로퍼스 앱에 권한이 있는지 확인 - 봇 마스터가 채널과 연결된 앱에 EDITOR 이상의 권한 필요
* \[디벨로퍼스 > 앱 > 제품 설정 > 카카오 로그인 > 간편 가입]에서 사용 설정 상태가 'ON'으로 되어 있는지 확인
* 두 채널이 모두 같은 앱에 연결되어 있는지 확인 - 두 채널이 같은 앱에 연결 필요 (운영, 개발 채널 설정 탭에서 채널의 빨간색 글씨 및 느낌표가 출력되는것은 운영, 개발 채널에 연결된 앱이 서로 다른 경우)
  {% endhint %}

설정을 완료한 후에도 운영 채널에서만 동작하지 않는다면 '배포'를 시행했는지 확인해 주세요.

### 카카오싱크 플러그인 <a href="#sync_plugin" id="sync_plugin"></a>

카카오톡 채널 채팅방에서 봇 서비스 제공 중 회원 가입 및 정보 연동이 필요할 때 카카오싱크 플러그인을 통해 화면 전환 없이 채널 채팅방 안에서 회원 가입 절차를 수행할 수 있습니다.&#x20;

카카오싱크 플러그인은 채팅방에서 자연스럽게 노출되는 형태로 사용자 정보 제공 및 약관 동의 팝업을 제공, 카카오 계정으로 서비스에 가입할 수 있는 카카오싱크의 간편 가입 기능을 카카오톡에서 봇과의 대화 중에도 사용할 수 있게 해줍니다.

카카오싱크 플러그인은 [**카카오싱크 플러그인**](/main/tool/chatbot/skill_guide/apply_skill_to_plugin.md#sync_plugin)을 참고해 주세요.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FUODLCaIEo4EVVIIjf8bq%2Ftutorial_sync_01.png?alt=media&amp;token=6b53e0b7-534c-4b95-b538-dd104367c13c" alt=""><figcaption><p>카카오싱크 플러그인</p></figcaption></figure>


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/tutorial/make_chatbot/tutorial_3.md
