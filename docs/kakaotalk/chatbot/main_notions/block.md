> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/block.md).

# 블록

**블록(Block)** 이란 사용자 의도의 기본 단위로, `인텐트(Intent)`라고도 불립니다. 1개의 블록은 1개의 의도를 표현하며, 사용자 발화가 봇으로 유입되면, 블록안에 사전에 등록된 발화내용을 기반으로 사용자 의도가 파악되어 1개 블록이 최종 추출됩니다.

이때 블록안에는 사용자 예상 발화, 그리고 봇이 수행할 액션과 응답할 내용이 설계됩니다.

예를 들면, 주로 ‘날씨 알려주기, 메시지 보내기, 지역 검색하기’ 와 같이 봇의 수행 미션(Task) 단위로 블록이 설계됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FMUfrhFcZN9D4pSfU2d1x%2Fblock-overview.png?alt=media&amp;token=305e0455-58df-4965-839a-f0456321fb34" alt=""><figcaption><p>블록 작동 원리 : 사용자 발화를 기반으로, 화자의 의도에 해당하는 블록이 추출되고 출력으로 이어져 실행되는 모습</p></figcaption></figure>

## 블록의 구성 <a href="#block_form" id="block_form"></a>

### 화면 구성 <a href="#display_form" id="display_form"></a>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FBrjE8pmC0cKKuoqGwFKk%2Fblock-configure-01.png?alt=media&amp;token=219148ed-779a-45d9-87c3-f0a76ccda399" alt=""><figcaption><p>블록 설정 화면 : 봇 작업자들은 위와 같은 블록 작성화면에서 사용자 예상발화 및 봇 응답 형식을 설정합니다</p></figcaption></figure>

### 주요 기능 구성 <a href="#main_function" id="main_function"></a>

* 사용자 발화 패턴
* 파라미터
* 봇 응답 형식
* 스킬
* 컨텍스트

## 블록의 종류 <a href="#block_type" id="block_type"></a>

### 기본 블록 <a href="#basic_block" id="basic_block"></a>

기본 블록은 봇이 구동할 때 필요한 최소한의 이벤트를 정의한 블록입니다. 봇 생성시 자동으로 생성되고 삭제가 불가능하며, 시나리오 메뉴에 있는 ‘시나리오 설정’ 에서 수정이 가능합니다.

* 웰컴 블록
* 폴백 블록
* 탈출 블록
* 인증 블록

#### 웰컴 블록(Welcome Block)

웰컴 블록은 사용자가 봇을 처음 사용할 때 받게되는 웰컴메시지를 설정하는 블록입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F0yXEGUrd7CDnINwkAyEj%2Fwelcome_block1-01.png?alt=media&amp;token=3627982c-cf3d-41d3-b399-2911ba024841" alt=""><figcaption><p>웰컴블록의 설정 모습</p></figcaption></figure>

'웰컴블록'이 '사용중'일 경우 사용자가 봇을 처음 사용할 때 웰컴블록에 설정된 응답이 전송되고, '미사용'일 경우 응답을 설정하는 부분이 비활성화 되고 OFF로 표기됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FhfVveDCO16FKkVGOOp0N%2Fwelcome_block2-01.png?alt=media&amp;token=6b42ac6a-bd01-4d4b-ba35-093e323c2437" alt=""><figcaption><p>웰컴블록이 '미사용'일 때 모습</p></figcaption></figure>

#### 폴백 블록(Fallback Block)

폴백 블록은 사용자의 발화 의도가 어떠한 블록과도 매칭이 되지 않을 때 (=봇이 사용자의 발화 의도를 이해하지 못할 때)의 응답을 설정하는 블록입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FRYzCkzCxomLUTJ4weers%2Fblock-fallback-01.png?alt=media&amp;token=675c08ad-25e8-4507-aa0d-07cc16139fc2" alt=""><figcaption><p>폴백 블록의 응답 설정 모습</p></figcaption></figure>

{% hint style="success" %}
**Tip.**

폴백 블록은 상황에 맞는 '응답 메시지'가 기본값으로 설정되어 있습니다. 하지만, 봇의 성격이나 서비스의 아이덴티티에 맞는 메시지로 수정하는 것을 권장합니다.
{% endhint %}

#### 탈출 블록(Exit Block)

탈출 블록은 봇의 되묻기 상황에서 사용자가 대화를 초기화하거나 탈출하고 싶을때 쓰는 사용자 명령어를 정의하는 블록입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F1iKWJpfqCYGoOtckUvib%2Fblock-escape-01.png?alt=media&amp;token=c1ed0f67-ec7e-4438-8402-96b68a76cab3" alt=""><figcaption><p>탈출 블록의 사용자 명령어 입력 설정 모습</p></figcaption></figure>

#### 인증 블록 <a href="#certification_block" id="certification_block"></a>

인증 블록은 플러그인을 사용하기 위한 블록입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FQwBSaW6QISlJAycEMLcO%2Fblock-confirmation-01.png?alt=media&amp;token=46fb305b-1f62-4c24-8b72-49f04a7c3d2f" alt=""><figcaption><p>인증 블록의 모습</p></figcaption></figure>

### 시나리오 블록 <a href="#scenario_block" id="scenario_block"></a>

봇 작업자가 설계한대로 봇을 제작할 수 있는 일반적인 블록입니다

상세한 설정 방법은 [**기본 블록 설정하기**](#setting_basic_block)를 참고하시길 바랍니다.

## 기본 블록 설정하기 <a href="#setting_basic_block" id="setting_basic_block"></a>

[**주요 개념 > 블록**](/main/tool/chatbot/main_notions/block.md)에서 설명한 것처럼, 챗봇 관리자센터가 봇을 생성 후 기본적으로 항시 제공하는 블록들을 **기본 블록**이라고 합니다.

기본 블록은 웰컴 블록, 폴백 블록, 탈출 블록 총 세 가지로 구성되어 있으며, 각 블록을 설정하는 방법은 다음의 그림을 참고해주시길 바랍니다.

작업자는 봇을 생성하고 나면 메인화면 좌측에서 **기본 블록**에 바로 접근할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FDEpsTcw8HJHil0hlRKBY%2Fdefault-block.png?alt=media&amp;token=cf014441-e1e8-4ab9-b613-659dc7e76f02" alt=""><figcaption></figcaption></figure>

봇 작업자가 봇을 생성하고 나면, 기본 블록은 기본 시나리오 메뉴 하단에 디폴트로 위치하게 됩니다. 봇 작업자는 봇을 만드는 중에 언제든 접근해서 필요한 세팅을 할 수 있습니다.

### 웰컴 블록(Welcome Block) 설정하기 <a href="#setting_welcome_block" id="setting_welcome_block"></a>

웰컴 블록은 봇 사용자가 봇을 처음 사용할 때 받게되는 응답을 설정하는 블록입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FwtPGtPkiIJUcT69ODGkU%2Fwelcome-block.png?alt=media&amp;token=c2995b6b-beba-4663-82bf-8f9f01b31fb0" alt=""><figcaption><p>웰컴 블록 내 메시지 꾸미기를 위한 말풍선 선택화면</p></figcaption></figure>

봇 응답 형식 설정 우측에 있는 **+ 버튼**을 클릭하면, 봇이 발송하는 웰컴 메시지를 어떤 말풍선에 담아서 꾸밀 것인지를 선택할 수 있습니다. 텍스트형, 이미지형, 카드형, 커머스형, 리스트형 또는 스킬을 연결하는 등 다양한 타입을 골라 메시지를 채울 수 있습니다. 단, 웰컴 블록의 담긴 메시지는 카카오톡 채널 챗봇을 이용하는 사용자의 경우

* 사용자가 카카오톡 채널을 봇과 연결한 다음 처음으로 대화방에 진입한 경우
* 사용자가 챗봇과 친구가 아니지만, **채팅하기**로 바로 대화방에 진입한 경우

최초 한 번만 사용자에게 전달됩니다. 동일한 사용자가 재입장할때마다 웰컴블록이 노출되기를 원하실 경우 일반 블록을 웰컴블록과 동일하게 생성하여 유도하는 방식으로 응용할 수 있습니다.

{% hint style="danger" %}
**Caution.**

만약 웰컴블록이 동작하지 않는 경우 아래 내용을 체크하여 주시기 바랍니다.

1. 웰컴블록은 ON/OFF를 설정할 수 있으며 OFF할 경우, 위 상황에 해당하는 경우에도 웰컴 블록의 메시지는 전송되지 않습니다.
2. 웰컴블록은 최초 1회 진입시에만 확인 가능합니다.
3. 알림톡과 함께 사용하는 채널인 경우 사용자가 채널추가를 한 경우에만 웰컴블록이 노출됩니다.
   {% endhint %}

### 폴백 블록(Fallback Block) 설정하기 <a href="#setting_fallback_block" id="setting_fallback_block"></a>

봇이 사용자의 말을 알아듣지 못하고, 이해할 수 없다는 의미의 메시지를 내뱉는 상황을 **폴백(fallback)** 상황이라고 합니다. 즉, 폴백 블록은 사용자의 입력(Input)이 어떠한 블록과도 매칭이 되지 않을 때의 응답을 설정하는 블록입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FO8n0kmhF3guNUi1ANYAQ%2Ffallback-block_2.png?alt=media&amp;token=6caf7f58-d3ba-4f8a-a0e7-0735b38adc2f" alt=""><figcaption><p>폴백 메시지 작성을 위한 텍스트형 말풍선 작성 공간의 모습. 폴백 말풍선에 필요한 버튼도 추가할 수 있습니다</p></figcaption></figure>

상기 화면처럼, 봇 작업자는 봇이 사용자의 말을 이해하지 못할 때 발송하는 첫 번째 메시지를 ‘텍스트형’ 말풍선 형태로 작성할 수 있습니다. 첫 번째 응답 부분의 **+ 버튼**을 누르면, 여러 개의 텍스트형 말풍선을 작성할 수 있습니다. 이렇게 작성된 말풍선들은 폴백 상황에서 랜덤으로 사용자에게 출력됩니다. 바로 연결 응답 및 기타 말풍선들을 추가로 폴백 내용 말풍선에 이어서 추가할 수도 있습니다.

### 탈출 블록(Exit Block) 설정하기 <a href="#setting_exit_block" id="setting_exit_block"></a>

탈출 블록은 사용자가 봇의 되묻기 상황에서, 강제적으로 빠져나가고자 할 때 쓰는 명령어를 정의하는 곳입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FW6qYa8oUIcC7BYYYVckC%2Fblock-escape.png?alt=media&amp;token=7a450b5b-5c6b-4c90-80d4-c971f16f5afb" alt=""><figcaption><p>탈출 블록 내에서 탈출 명령어로 쓰일 발화를 지정하는 모습</p></figcaption></figure>

되묻기 상황을 탈출하기 위한 임의의 명령어 발화를 입력해두는 곳으로 이해하면 좋습니다. 되묻기 상황에서 쓸 수 있는 사용자의 탈출 수단이니, 탈출 블록에 정의된 명령어를 봇의 응대 시나리오 내 적정 지점에서 사용자에게 안내하는 것이 좋습니다.

탈출 블록에 대한 응답은 수정할 수 없습니다.

### 인증 블록 설정하기 <a href="#setting_authentication_block" id="setting_authentication_block"></a>

인증 블록은 플러그인을 사용하기 위한 블록입니다. 처음 봇을 생성할 당시에는 인증 블록이 없으며 이후 채널 - 앱을 정상적으로 봇에 연결하시면 인증 블록이 생성됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FS37J703PgDxNTOoPpmoB%2Fblock-confirmation1.png?alt=media&amp;token=dda3650d-fe1c-4482-b5ea-fff365f4bcbe" alt=""><figcaption><p>인증 블록의 모습</p></figcaption></figure>

챗봇 관리자센터에서 인증 블록을 사용하시려면 아래와 같은 사전 설정이 필요합니다.

**Step 1. 채널-앱 설정하기**

인증 블록을 사용하기 위해서는 비즈니스 인증이 필수 입니다. 비즈 채널과 앱 을 연결 후 인증 블록을 사용할 수 있습니다.

{% hint style="info" %}
**Information.**

카카오톡 비즈니스 채널(인증된 프로필)과 디벨로퍼스 비즈 앱 생성 방법은 [**카카오싱크 공통 가이드**](https://developers.kakao.com/docs/latest/ko/kakaosync/common#table-of-contents)에서 상세하게 확인할 수 있습니다.
{% endhint %}

#### Step 2. 봇에 채널 설정하기

카카오비즈니스 관리자센터에서 운영, 개발 채널을 생성하고 동일한 앱에 연결을 완료하였다면 챗봇 관리자센터에서 해당 채널-앱을 설정 합니다. 상세한 설정 방법은 [**카카오톡 채널 연결하기**](/main/tool/chatbot/tutorial/make_chatbot/tutorial_1.md#connect_bot_channel)를 참고하시길 바랍니다.

챗봇 관리자센터 내 '인증블록'에서 필수 파라미터 설정 후 일반 블록과 연결하여 플러그인을 이용할 수 있습니다.

{% hint style="danger" %}
**Caution.**

만일, 인증블록 설정 후 채널/앱 정보에 변동사항이 있는 경우 플러그인이 정상 동작하지 않을 수 있습니다. 아래 사항을 확인한 후 반드시 인증블록을 초기화 및 재설정 해주시기 바랍니다. 또한 인증블록과 연결된 블록 버튼도 재설정이 필요합니다.\
\
**두 채널 모두 봇과 연결 필요**

* 운영 채널 또는 개발 채널만 연결되어 있는지 확인

**싱크, 회원가입 플러그인의 경우**

* 디벨로퍼스 앱 제품 설정에서 **'간편가입 사용 여부'가 ON으로 되어 있는지 확인**
* 디벨로퍼스의 '카카오싱크 플러그인 **리다이렉트 URI가 정상적으로 입력 되어 있는지 확인** - URI가 유효해야 함

**디벨로퍼스 앱과 봇이 연결된 경우**

* 봇 마스터가 채널과 연결된 **디벨로퍼스 앱에 권한이 있는지 확인** - 봇 마스터가 채널과 연결된 앱에 EDITOR 이상의 권한 필요
* **'카카오 로그인 활성화'가 ON으로 되어 있는지 확인**
* 두 채널이 모두 같은 앱에 연결되어 있는지 확인 - **두 채널이 같은 앱에 연결 필요** (운영, 개발채널 설정 탭에서 채널의 빨간색 글씨 및 느낌표가 출력되는것은 운영, 개발채널에 연결된 앱이 서로 다른 경우)

설정을 완료한 후에도 운영채널에서만 동작하지 않는다면 **'배포'를 시행했는지 확인**
{% endhint %}


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/block.md
