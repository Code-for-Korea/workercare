> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/event-api.md).

# Event API

## Event API란?

챗봇과 사용자 간의 대화는 기본적으로 사용자가 먼저 대화를 건내면 이에 대해서 챗봇이 응답하는 구조를 가지고 있습니다. 그러나 실생활에서의 대화가 항상 한 쪽으로부터만 시작되지 않는 것과 같이 챗봇이 먼저 사용자에게 말을 거는 것이 자연스러운 상황이 있습니다. Event API는 이와 같은 상황에서 챗봇이 먼저 대화를 시작할 수 있도록 도와주는 기능으로 특정 이벤트에 대한 알림, 안내 등의 목적으로 사용할 수 있습니다.

다만, 예상치 못한 메시지가 너무 빈번하게 오는 것은 사용자를 쉽게 피로하게 만들 수 있기 때문에 이를 고려하여야 사용자와의 관계를 오래 지속할 수 있을 것입니다!

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fr5145WquFKOyh1SmV9kO%2Feventapi01.png?alt=media&amp;token=5d1af234-8103-4061-bbfd-3d4c6b69d3b5" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
**Information.**\
운영채널 및 개발채널에서의 Event API 메시지 사용량은 모두 과금 대상이며, 메시지 1건당 15원(VAT 별도)씩 과금됩니다.

따라서 Event API를 통한 메시지를 전송하기 위해서는 [**월렛 생성 및 연결**](/main/tool/chatbot/main_notions/wallet.md#create_bussiness_wallet)이 선행되어야 합니다. 월렛에 대한 상세한 내용은 [**주요개념 > 월렛**](/main/tool/chatbot/main_notions/wallet.md)을 참고해주시기 바랍니다.
{% endhint %}

## Event API 활용 예시 <a href="#use_eventapi_example" id="use_eventapi_example"></a>

그렇다면 Event API는 어떤 상황에서 어떻게 사용할 수 있을까요? 위 Event API에 대한 간략한 설명만으로 감을 잡기 어려운 분들을 위해 몇 가지 시나리오 예시를 준비했습니다. 아래 예시 외 다양한 시나리오에서도 Event API를 적절히 사용해 사용자와의 대화를 더욱 풍성하게 만들어보세요!

### 정보성 메세지 예시 시나리오 <a href="#informative_message_scenario" id="informative_message_scenario"></a>

**1) 경기결과 알림**

사용자가 관심있는 경기정보에 대해 사전에 알림 설정을 해두면, 관련 경기가 종료된 후 경기 결과를 Event API로 발송하는 시나리오입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F0jCaXEgohqRiDhLcdb7o%2Feventapi02.png?alt=media&amp;token=3fb3b641-6f0c-46b0-a1e3-abacbc17a265" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
**알림설정**

사전 알림 설정은 Event API 사용을 위한 필수 요소는 아니며 사용자에게 적합한 정보를 정제하여 전달하기 위한 하나의 장치라고 볼 수 있습니다.
{% endhint %}

**2) 주문 상품 준비 완료 안내**

커피 주문 후 제조가 완료되면 Event API로 안내하는 시나리오입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FwNWAdHQbFBBp2ffGZ0zl%2Feventapi03.png?alt=media&amp;token=e8a69bc4-281d-462c-b7b8-ba13e34f6166" alt=""><figcaption></figcaption></figure>

**3) 재입고 알림**

사용자가 관심있는 상품에 대해 재입고 알림설정을 해두면, 상품이 재입고되었을 때 Event API로 안내 메시지를 발송하는 시나리오입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F4WVaNawj8kJ0SrBS7T6t%2Feventapi04.png?alt=media&amp;token=a552ab58-e844-400b-8eb0-5828eb6b91b1" alt=""><figcaption></figcaption></figure>

### 광고성 메시지 예시 시나리오 <a href="#a-dvertising_message_scenario" id="a-dvertising_message_scenario"></a>

{% hint style="info" %}
**광고성 내용 포함**\
발송하려는 메시지가 광고성 내용을 포함하는 경우 광고성 메시지임을 표기해야 합니다. 광고성 메시지 기준 및 광고성 메세지 표기 방법은 아래 [**Event API 광고표시 의무**](#eventapi_advertising_duty)를 확인해주세요.
{% endhint %}

**1) 프로모션 안내**

이벤트/특가판매 등 프로모션에 대해서 필요한 시각에 Event API로 광고 메시지를 발송하는 시나리오입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FXSTk5YQNLrlqifUvmpsp%2Feventapi05.png?alt=media&amp;token=50094f05-19ce-4d74-97f7-eb594142e1f0" alt=""><figcaption></figcaption></figure>

**2) 관심상품 알림**

사용자가 관심상품 키워드를 미리 등록해두면 관련 상품 판매 시작시 관련 Event API로 광고 메시지를 발송하는 시나리오입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FtOjrLOYjkNUfGqnSKDfx%2Feventapi06.webp?alt=media&amp;token=0b8a6e99-cd31-4785-8f4e-eb353deabf7d" alt=""><figcaption></figcaption></figure>

## Event API 메시지 전송 정책 <a href="#send_eventapi_policy" id="send_eventapi_policy"></a>

* Event API는 채널을 추가한 유저에게만 전송 가능하므로, 채널을 추가하지 않았거나 차단한 경우 전송은 실패합니다.
* Event API 요청 1회당 최대 발송 건수는 100건이며 유저아이디 중복은 허용되지 않습니다.
* Event를 발송할 대상인 유저아이디 타입은 아래 값 중 하나여야 합니다. 유효하지 않은 사용자에게 발송한 메시지는 전송 실패합니다.
* Event API 발송시 채널 추가한 유저의 전체 유저키를 한번에 조회하거나 업로드 하는 기능은 지원하지 않습니다.
  * appUserId (카카오 디벨로퍼스 앱유저 아이디)
  * plusfriendUserKey (skill서버에 전달되는 톡채널 유저 식별값)
  * botUserKey (skill 서버에 전달되는 봇 유저 식별값)

{% hint style="info" %}
**Information.**\
요청 성공 여부는 [**이벤트 블록 호출 API**](#api-1)의 status값에서 확인 가능하며, 전송 성공 여부는 [**이벤트 발송 성공여부 조회 API**](#response-1)를 통해 확인할 수 있습니다. 전송 성공된 메시지 건에 대해서만 과금 처리됩니다.
{% endhint %}

#### 이벤트 블록 호출 API

상세한 설정 방법은 [**Event API 사용하기**](#use_eventapi)를 참고하시길 바랍니다.

## Event API 사용하기 <a href="#use_eventapi" id="use_eventapi"></a>

### Event API 사전 설정 <a href="#preset_eventapi" id="preset_eventapi"></a>

Event API 메시지를 발송하기 위해서는 다음과 같은 사전 설정이 필요합니다.

**Step 1. 비즈니스 인증 채널과 디벨로퍼스 앱 연결하기**

비즈니스 인증을 받은 채널과 비즈니스 인증을 받은 앱을 연결해야 합니다. 비즈니스 인증 채널을 신청하실 때에는 실제 서비스에서 사용할 카카오톡 채널로 신청해야 합니다.

{% hint style="danger" %}
**Caution**&#x20;

이 때 디벨로퍼스 앱 사용자 설정에서 "카카오 로그인 활성화" ON 필수입니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FwxOL8JJcImWgi0cIRp4f%2F%E1%84%85%E1%85%A9%E1%84%80%E1%85%B3%E1%84%8B%E1%85%B5%E1%86%AB%E1%84%8B%E1%85%A9%E1%86%AB%202.png?alt=media&amp;token=b78693ae-bab0-4277-af43-b60350abf068" alt=""><figcaption></figcaption></figure>

봇을 제작하는 마스터가 [**카카오톡 채널 관리자센터**](https://accounts.kakao.com/login/kakaoforbusiness?continue=https://center-pf.kakao.com/)에서 비즈 카카오톡 채널 인증을 받고 [**카카오 디벨로퍼스**](https://developers.kakao.com/)에서 비즈앱 인증을 각각 받습니다. 그리고 [**카카오 디벨로퍼스**](https://developers.kakao.com/console/app?continue=/review)에서 위에서 만든 비즈니스 인증 채널 및 비즈 앱을 연결해줍니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FVzshaOGV6SJuWP9CO2BK%2Fp.22%2C%2023%2C%2025%2C%2027.png?alt=media&amp;token=df49e3e1-babb-4558-92cb-12deb9eef57a" alt=""><figcaption><p>디벨로퍼스 > 앱 > 추가 기능 신청 > 신청 가능 대상 > 추가 기능 > 카카오톡 채널 연결</p></figcaption></figure>

**Step2. 챗봇 관리자센터에 카카오톡 채널 연결하기**

Event API를 사용하기 위해서는 챗봇 관리자센터에 카카오톡 채널 연결해야 합니다.\
(운영채널과 개발채널 모두 Event API 발송을 지원하나 개발채널의 경우 이벤트 블록 호출 API url 내 파라미터값의 형태가 다릅니다. 자세한 내용은 [**개발가이드**](#eventapi_develope_guide)를 참고해주세요.)

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FIeiXXO62DS5pplQ0ILiN%2Feventapi09.webp?alt=media&amp;token=eebef302-4c86-469d-a3f7-ff00bd36513c" alt=""><figcaption></figcaption></figure>

### 챗봇 관리자센터 내 Event API 설정 <a href="#setting_eventapi_bot_center" id="setting_eventapi_bot_center"></a>

챗봇이 건낼 수 있는 다양한 메시지 중 정확히 어떤 메시지(블록)를 전송할 지 정의해야 합니다. 이를 정의하기 위해서는 해당하는 블록 내에서 이벤트 이름을 설정하는 과정이 필요합니다.

블록 > \[...] > 이벤트 설정 > 이벤트 설정 팝업 에서 이벤트 이름을 작성한 뒤 엔터를 누르고 확인 버튼을 눌러주세요.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Frfv2djcjquUiT3wl2sdr%2Feventapi10.webp?alt=media&amp;token=7ff05fdb-a528-4719-8a33-c14b1982dc8a" alt=""><figcaption></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FhkW70BSddx1W54RjXefP%2Feventapi11.png?alt=media&amp;token=49027195-79bf-4c80-b9f8-0797ae67a83f" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
**광고성 내용 포함**\
발송하려는 메시지가 광고성 내용을 포함하는 경우 이벤트 설정 팝업의 "광고성 내용 포함" 토글을 ON해야 합니다. 자세한 내용은 [**Event API 광고표시 의무**](#eventapi_advertising_duty)를 확인해주세요.
{% endhint %}

이벤트 이름은 중복되어 저장될 수 없습니다. 동일 봇에서 동일 이벤트명을 사용 중인 경우, 다음과 같은 경고 알림이 노출됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Ffa17XpEpu7yVSaFyowAO%2Feventapi12.png?alt=media&amp;token=1c1e5c6b-e7d2-49d2-ab68-83cc08c0b53c" alt=""><figcaption></figcaption></figure>

Event API 를 설정한 블록에서는 필수 파라미터를 지원하지 않습니다. 필수 파라미터가 설정된 경우, Event API 메시지가 발송되지 않으니 주의해주시길 바랍니다.

챗봇 관리자센터에서 Event API 설정 및 시나리오 수정을 완료한 뒤에는, 배포를 완료해야 Event API 메시지 발송이 가능합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FYtQaXl7XhPD2eE1mu8xo%2Feventapi13.webp?alt=media&amp;token=32e4d582-824b-403f-9e11-03b9c3d4e6c9" alt=""><figcaption></figcaption></figure>

### Event API 광고표시 의무 <a href="#eventapi_advertising_duty" id="eventapi_advertising_duty"></a>

#### &#xD;**한국 인터넷 진흥원 광고표시 가이드** <a href="#kisa_advertising_display_guide" id="kisa_advertising_display_guide"></a>

한국 인터넷 진흥원에서 배포한 불법 스팸 방지를 위한 정보통신망법 안내서에 따라 광고성 메시지 작성 시에는 하기 가이드를 준수하여야 합니다. 아래 내용을 참고하여 발송할 메시지가 광고성 내용을 포함할 경우, 말풍선 설정에서 광고성 내용 포함을 체크해야 합니다.

{% hint style="info" %}
**1. 광고표시**

* 광고성 내용이 포함된 메시지 맨 앞에 (광고)를 표시해야 합니다.
* 광고성 메시지에 대한 판단 기준\
  1\)특가/할인 상품 안내\
  2\)상품 및 서비스 홍보를 위한 프로모션 또는 이벤트\
  3\)정보를 ‘주’로 나타내더라도 \[위 1,2]의 내용이 혼재된 경우

**2. 전송자의 연락처 표시 의무사항**

* 전송자의 명칭, 전송자 연락처는 메시지 본문보다 상단에 작성되어야 합니다.
* 전송자 명칭과 전송자 연락처의 경우 채팅방 상단에 노출됩니다.
* 연락처의 경우 전화번호 또는 주소 중에서 하나를 선택하여 기입해 주셔야 합니다.

**3. 수신거부 의사표시를 쉽게 할 수 있는 조치 및 방법 표시 의무사항**

* 메시지에 수신의 거부 및 수신동의 철회의 의사표시를 쉽게 할 수 있는 조치 및 방법을 광고 본문에 표기하여 구체적으로 밝혀야 합니다. 동 조치 및 방법으로 수신의 거부 또는 수신동의 철회가 쉽게 이루어지지 않거나 불가능 할 경우에는 이를 표기하지 않는 것으로 간주합니다.
* 전자우편을 수신 거부하기 위하여 웹사이트에 로그인하도록 하는 등 별도의 추가적인 조치를 거쳐야 하는 것은 수신의 거부 또는 수신동의 철회를 어렵게 하는 것으로 법 위반에 해당합니다.
  {% endhint %}

**챗봇 관리자센터 광고성 메시지 전송 정책**

챗봇 관리자센터 챗봇을 이용해 Event API를 사용하여 광고성 메시지 발송 시 한국 인터넷 진흥원의 광고표시 가이드에 따라 다음 정책을 지켜야 합니다.

{% hint style="info" %}
**광고성 메시지 전송 정책**

1. 광고성 메시지 발송이 가능한 시간은 **오전 8시 \~ 오후 8시 50분** 입니다.
2. 광고성 메시지는 **톡채널과 친구를 맺은 사용자**에게만 발송이 가능합니다.
3. 카카오톡 채널 채팅방 상단에 **고객센터 연락처를 노출**해야 합니다.
   {% endhint %}

위 세 가지 중 한 가지라도 위반하는 경우 Event API 메시지 발송이 실패합니다.

3번 카카오톡 채널 채팅방 상단 고객센터 연락처 설정은 카카오톡 채널 관리자 센터에서 할 수 있으며 방법은 다음과 같습니다.

\[채널 > 관리 > 상세설정 > 채널정보 > 고객센터 연락처] 에서 고객센터 연락처를 작성한 뒤 확인 버튼을 눌러 저장합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FqehSpwDrh1z9zWEfT1U2%2Feventapi14.png?alt=media&amp;token=07d24ac4-ba31-4b54-b679-04efb306bfbf" alt=""><figcaption></figcaption></figure>

설정이 완료되면 채널 채팅방 내 프로필명 아래에 다음과 같이 고객센터 전화번호가 노출됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Ftgy1H91nsgfRAmIvVA0s%2Feventapi15.png?alt=media&amp;token=3aea4567-e333-4bd9-81e3-392a07d3769c" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
**사용자가 알림을 신청을 한 경우에 보내는 정보는 광고성 메시지에 해당되나요?**\
\
**'고객의 요청에 의해 발송하는 1회성 정보'**&#xC758; 경우, 영리목적 광고성 정보의 예외 사유에 해당되어 광고표시 가이드 제한 없이 발송할 수 있습니다.\
다만, 사용자의 요청이 있었다고 하더라도 1회가 아닌 지속적인 발송은 광고성 정보의 예외 사유에 해당하지 않아 광고표시 가이드를 준수하여 (광고 표시를 하여) 메시지를 전송해야 합니다.\
\
[**Event API 활용 예시**](#use_eventapi_example)를 살펴보면, 정보성 메시지 예시의 **3)재입고 알림 시나리오**는 '고객의 요청에 의해 발송하는 1회성 정보'에 해당하여 광고표시 가이드 제한 없이 발송이 가능합니다\
그러나, 광고성 메시지 예시의 **2)관심상품 알림 시나리오**의 경우, 1회가 아닌 해당 카테고리에 포함된 제품에 대해 지속적으로 메시지를 발송하는 경우에 해당하여 광고표시 가이드를 준수하여 Event API 메시지를 발송해야 합니다.
{% endhint %}

**챗봇 관리자센터 광고성 메시지 설정 방법**

광고성 메시지를 Event API로 전송하기 위해서는 챗봇 관리자센터에서 다음과 같은 설정이 필요합니다.

1. 블록 상세 > \[...] > 이벤트설정

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FfudpfTy4e2fdZYhT2G1o%2Feventapi16.png?alt=media&amp;token=d56a663b-d2ee-4b60-843d-dd701061e7d9" alt=""><figcaption></figcaption></figure>

2. 이벤트설정>광고성 내용 포함 ON

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FFXsD9Edx5rpRDjpT1UdI%2Feventapi17.png?alt=media&amp;token=4279970a-99fd-41ff-9958-0923facf8b68" alt=""><figcaption></figcaption></figure>

3. 광고성 내용 포함 설정 팝업 확인

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F4UzvSTcuaTMckYavUePy%2Feventapi18.png?alt=media&amp;token=6c073236-c8ae-4365-b87f-85c6441caeeb" alt=""><figcaption></figcaption></figure>

광고성 내용을 포함하는 Event API 메시지는 **다음과 같은 말풍선 형태**에서만 발송 가능합니다.

{% hint style="info" %}
**광고성 메시지 말풍선 사용 정책**\
\
Event API를 사용하여 광고성 메시지를 전송하고자 하는 경우 해당 메시지는 **아래 요건을 준수**하여야 합니다. Skill응답 생성 시 아래 요건을 만족하지 않는 메시지는 **발송되지 않습니다.**

1. 광고성 메시지는 말풍선 1개만 포함하여야 합니다.<br>
2. 광고성 메시지로 발송 가능한 말풍선 타입은 아래와 같습니다.\
   a. 커머스 (CommerceCard)\
   b. 카드 (BasicCard)\
   c. 리스트 (ListCard) (단일형만 지원)\
   d. 아이템형 (itemCard) (스킬 형태로만 지원하는 말풍선입니다)
   {% endhint %}

광고성 내용 포함 설정 ON 시, 챗봇 관리자센터에서는 다음과 같이 작성가능한 봇 응답 개수는 3개에서 1개로 변경되며 사용 가능한 말풍선 타입은 카드, 커머스, 리스트, 스킬데이터로 변경됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FKpvkJQDQKVECKgjp03dk%2Feventapi19.webp?alt=media&amp;token=35adcac8-83b9-4318-8cec-2a2a3ce7b855" alt=""><figcaption></figcaption></figure>

광고성 내용 포함 설정이 정상적으로 적용되어 Event API 메시지가 발송되면 다음과 같이 말풍선의 채널명 왼쪽에 (광고)가 노출되며, 말풍선 우측 하단에 수신거부 방법이 표기되어 발송됩니다.

수신거부 방법 표기는 말풍선이 단일형인 경우 해당 말풍선에, 말풍선이 케로셀형인 경우 케로셀헤드에 표기되어 발송됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F6QiUWtJTmLNa7hbLtmX9%2Feventapi20.png?alt=media&amp;token=947c10a0-cbdd-485b-923e-e6daaec83cce" alt=""><figcaption></figcaption></figure>

### Event API 개발 가이드 <a href="#eventapi_develope_guide" id="eventapi_develope_guide"></a>

#### 이벤트 블록 호출 API

앞의 사전설정이 모두 완료되었다면, 이벤트 블록 호출 API를 통해 이벤트 블록을 실행해 카카오톡 채널로 메시지를 전송할 수 있습니다.

#### **Request**

```
POST https://bot-api.kakao.com/v2/bots/{botId}/talk
```

* 운영채널로 Event API 발송 시 : botid
* 개발채널로 Event API 발송 시 : botid!

#### **Request Header**

```
Authorization: KakaoAK {Rest Api Key}
Content-Type: application/json
```

해당 rest api key 는 [**카카오 디벨로퍼스**](https://developers.kakao.com/)에서 생성한 앱의 앱키 중 REST API 키 로 보내주셔야 합니다.

#### **Request Payload**

| 키      | 설명                          | 타입                               | 필수여부 |
| ------ | --------------------------- | -------------------------------- | ---- |
| event  | 봇 이벤트 정보                    | JSON object                      | O    |
| user   | 유저 정보                       | JSON array of objects (max. 100) | O    |
| params | event param (skill 서버까지 전달) | JSON object                      | X    |
| option | Event API 사용 특수 옵션          | JSON object                      | X    |

#### 1. event(JSON object)

event name은 챗봇 관리자센터 > 블록상세 > 이벤트 설정에 정의한 이름과 동일해야 합니다.

| 키    | 설명                      | 타입                      | 필수여부 |
| ---- | ----------------------- | ----------------------- | ---- |
| name | 봇 이벤트 정보                | string                  | O    |
| data | 봇 이벤트 Custom parameters | JSON(\<string, string>) | X    |

챗봇 관리자센터의 봇 응답형식 설정(말풍선 설정)에서 event >data 의 파라미터 값을 텍스트 영역에 사용할 수 있습니다. {{#current.event.data.paramName}}을 말풍선에 넣어서 사용할 수 있습니다.

#### 2. user(JSON array of objects(max. 100))

이벤트를 발송할 대상 유저들에 대한 정보입니다. 유저 id 는 중복은 허용되지 않으며, list 의 size max (요청 한번당 최대 발송 건수)는 100개 입니다. 톡채널 정책 상 Event API는 친구관계인 경우에만 메시지를 전송할 수 있으므로, 톡채널과 해당 유저가 친구관계가 아닐 경우 전송은 실패합니다.

유저 아이디 타입은 appUserId (카카오 디벨로퍼스 앱유저 아이디), plusfriendUserKey (skill서버에 전달되는 톡채널 유저 식별값), botUserKey (skill 서버에 전달되는 봇 유저 식별값) 중 하나여야 합니다.

appUserId (카카오 디벨로퍼스 앱유저 아이디)으로 보내는 경우 개발 채널로 전송은 불가능 합니다.

유저 별로 추가적으로 skill 서버에 전달할 데이터가 있을 경우 properties 필드에 담긴 값이 skill payload 의 [**userRequest.user.properties**](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/pages/85J4rUuUTl7dM5DZPy2L#user.properties) 필드에 포함되어 전달됩니다.

| 키          | 설명                                                                                                          | 타입                      | 필수여부 |
| ---------- | ----------------------------------------------------------------------------------------------------------- | ----------------------- | ---- |
| type       | <p></p><p>유저 아이디 타입 (아래 값 중 하나)</p><ul><li>appUserId</li><li>plusfriendUserKey</li><li>botUserKey</li></ul> | String                  | O    |
| id         | 유저 아이디 값                                                                                                    | String                  | O    |
| properties | 유저 별 추가 페이로드                                                                                                | JSON(\<string, string>) | X    |

#### 3. params(JSON object)

params의 경우에는 type 에 제한이 없으면 skill server까지 값이 그대로 전달되며, skill 서버에서는 request body 의 userRequest -> params 로 그 값을 전달받을 수 있습니다.

챗봇 관리자센터의 봇 응답형식 설정(말풍선 설정)에서 params 의 파라미터 값을 텍스트 영역에 사용할 수 있습니다. {{#current.params.paramName}}을 말풍선에 넣어서 사용할 수 있습니다.

#### **Request Body Sample**

```
{
  "event": {
    "name": "bot_test_event",
    "data": {
      "text": "Hello World"
    }
  },
  "user": [
    {"type": "botUserKey", "id": "12345"},
    {"type": "botUserKey", "id": "12346"}
  ],
  "params":{
    "foo":"bar"
  }
}
```

#### **Response**

#### **Response Body**

이벤트 API 호출 실패시 전체가 FAIL된 경우 아래 FAIL - error Message 표와 같이 FAIL 메시지를 확인할 수 있습니다. (결과가 SUCCESS 가 아닌 FAIL케이스는 GET API 이벤트 발송 성공여부 조회가 되지 않습니다.)

<table><thead><tr><th width="147">키</th><th width="106">타입</th><th width="114">필수여부</th><th>설명</th></tr></thead><tbody><tr><td>taskId</td><td>String</td><td>O</td><td>해당 리퀘스트에 대한 uuid ( 결과조회를 위한 Id )</td></tr><tr><td>status</td><td>String</td><td>O</td><td>one of ["SUCCESS", "FAIL", "ERROR"]</td></tr><tr><td>message</td><td>String</td><td>X</td><td>상태에 대한 세부 메시지</td></tr><tr><td>timestamp</td><td>long</td><td>O</td><td>task 생성 unixtimestamp</td></tr></tbody></table>

#### 1. status

| STATUS  | message                   |
| ------- | ------------------------- |
| SUCCESS |                           |
| FAIL    | FAIL - error Message 표 참고 |
| ERROR   | \~\~\~                    |

#### **Request Sample**

```
curl -v -X POST https://bot-api.kakao.com/v2/bots/5b3c85911073e946641ebb6d/talk \
-H 'Authorization: KakaoAK {kakao developers rest api key}' \
-H 'Content-Type: application/json' \
-d $'{
  "event": {
    "name": "home"
  },
  "user": [
    {"type": "botUserKey", "id": "12345"},
    {"type": "botUserKey", "id": "12346"}
  ]
}'
```

※ cURL을 사용하여 개발채널에 이벤트 메시지를 발송하는 경우, {botid!}에 그냥 !만 붙이면 에러가 나기 때문에 다음과 같이 botid 전체를 ‘ ’ 로 감싸줘야 합니다.

```
POST https://bot-api.kakao.com/v2/bots/'5b3c85911073e946641ebb6d!'/talk 
```

#### FAIL - error Message

<table><thead><tr><th width="87.33333333333331">구분</th><th width="282">안내 문구</th><th>	설명</th></tr></thead><tbody><tr><td>FAIL</td><td>Invalid bot ID. Check your Bot ID.</td><td>봇ID가 유효하지 않은 상태로 봇ID를 점검하여 주시기 바랍니다.</td></tr><tr><td>FAIL</td><td>Invalid channel profile ID. Check your profile ID.</td><td>채널ID가 유효하지 않은 상태로 채널ID를 점검하여 주시기 바랍니다.</td></tr><tr><td>FAIL</td><td>Invalid Event name. Check your Event name.</td><td><p>유효하지 않은 Event name입니다.</p><p>Event name을 점검하여 주시기 바랍니다.</p></td></tr><tr><td>FAIL</td><td>API request limit exceeded. Please contact KakaoDevelopers technical support.</td><td>KakaoDevelopers app당 쿼터 제한이 초과된 경우로 KakaoDevelopers 고객센터로 문의하여 주시기 바랍니다.</td></tr><tr><td>FAIL</td><td>Skill server IP must be identical to the one set in the app.</td><td>app에 설정된 IP를 스킬서버로 사용하여 주시기 바랍니다.</td></tr><tr><td>FAIL</td><td>Invalid appKey. Check your appKey.</td><td><p>appKey가 잘못된 경우입니다. </p><p>appKey를 다시 확인하여 주시기 바랍니다.</p></td></tr><tr><td>FAIL</td><td>Request timed out. Please try again.</td><td>타임아웃 등으로 발송에 실패한 경우 입니다.</td></tr><tr><td>FAIL</td><td>Invalid DSP Account. Please sign in with your Kakao Business account.</td><td>카카오비즈니스에 가입 후 발송할 수 있습니다.</td></tr><tr><td>FAIL</td><td>App key not found.</td><td><p>appKey가 공란인 경우입니다. </p><p>appKey를 다시 확인하여 주시기 바랍니다.</p></td></tr><tr><td>FAIL</td><td>The channel is not connected.</td><td>채널이 봇에 연결되어 있지 않은 상태입니다. 발송하고자 하는 채널을 연결하여 주시기 바랍니다.</td></tr><tr><td>FAIL</td><td>Non-sufficient funds. Check your wallet balance.</td><td>월렛의 잔액이 없는 상태로 충전한 뒤 사용하여 주시기 바랍니다.</td></tr><tr><td>FAIL</td><td>Wallet not found. Bot must have an activated wallet to use the Event API.</td><td>월렛 미연결된 상태로 월렛을 연결하여 주시기 바랍니다.</td></tr></tbody></table>

## 이벤트 발송 성공여부 조회 API

이벤트 발송 결과를 조회하는 API입니다. 이벤트 블록 호출 API 응답에 있는 status 값이 SUCCESS일 경우에만 조회가 가능합니다.

status의 SUCCESS는 ‘요청'에 대한 성공/실패 결과값으로 실제 사용자에게 메시지가 발송되었는지 여부는 발급된 taskID로 이벤트 발송 성공여부 조회 GET API를 통해 확인할 수 있습니다.

(이벤트 블록 호출 API 응답에 있는 status 값이 SUCCESS이더라도 실제 발송 여부는 GET API를 통해 확인하시기 바랍니다.)

### Request

#### V1: 이벤트 발송 성공여부 API

```
GET https://bot-api.kakao.com/v1/tasks/{taskId}
```

| 키      | 설명                            | 타입     | 필수여부 |
| ------ | ----------------------------- | ------ | ---- |
| taskID | task POST 요청 response의 taskID | String | O    |

### **Request Header**

```
Authorization: KakaoAK {Rest Api Key}
Content-Type: application/json
```

해당 rest api key 는[ https://developers.kakao.com](https://developers.kakao.com/)에서 생성한 앱의 앱키 중 REST API 키로 보내주셔야 합니다.

### **Response**

#### **Response Body**

POST api 호출 결과가 SUCCESS 가 아닐 경우 결과 조회가 되지 않습니다.

<table><thead><tr><th width="172">키</th><th width="274">설명</th><th width="89">타입</th><th width="103">필수여부</th><th>V2 제공 필드 여부</th></tr></thead><tbody><tr><td>taskID</td><td>실행 결과를 조회하고자 하는 taskID</td><td>String</td><td>O</td><td></td></tr><tr><td>status</td><td>one of[“ALL SUCCESS, “N FAIL”] (N: Fail count)</td><td>String</td><td>O</td><td></td></tr><tr><td>allRequestCount</td><td>전체 요청 횟수 (POST request 시 user.ids의 size와 동일)</td><td>int</td><td>O</td><td></td></tr><tr><td>successCount</td><td>성공적으로 처리된 요청 횟수</td><td>int</td><td>O</td><td></td></tr><tr><td>fail</td><td>실패 결과에 대한 정보</td><td>JSON Object</td><td><p>X</p><p>(status=”ALL SUCCESS”가 아닌 경우 필수)</p></td><td></td></tr></tbody></table>

#### 1. fail

처리 결과 실패로 끝난 요청에 대한 정보

| 키     | 설명           | 타입          | 필수여부 |
| ----- | ------------ | ----------- | ---- |
| count | 처리 결과 실패 건수  | int         | O    |
| list  | 실패 요청에 대한 정보 | JSON Obejct | O    |

#### 2. list

| 키           | 설명                | 타입     | 필수여부 |
| ----------- | ----------------- | ------ | ---- |
| userID      | 실패 처리된 userID     | String | O    |
| reqUserType | 실패 처리된 userID의 종류 | String | O    |
| createdAt   | 실패 처리된 시각         | String | O    |
| errorMsg    | 실패 처리된 원인         | String | O    |

#### **error Message -taskid 표 참고**

<table><thead><tr><th width="130">errorType</th><th width="187">안내 문구</th><th>설명</th></tr></thead><tbody><tr><td>101</td><td>Request user is not a friend of talk channel's.</td><td>채널추가하지 않은 유저에게는 Event API 메시지 발송이 불가능합니다.</td></tr><tr><td>102</td><td>Message cannot be sent to this user.</td><td>발송할 수 없는 유저입니다.</td></tr><tr><td>103</td><td>Invalid user key.</td><td>올바른 user key가 아닙니다.</td></tr><tr><td>201</td><td>Bot skill server responded with an HTTP error : code #</td><td>스킬서버 문제일 가능성이 높은 에러로 스킬서버 내 이슈를 우선 점검하여 주시기 바랍니다.</td></tr><tr><td>202</td><td>Connection to skill server timed out.</td><td>스킬서버 문제일 가능성이 높은 에러로 스킬서버 내 이슈를 우선 점검하여 주시기 바랍니다.</td></tr><tr><td>203</td><td>Bot skill server responded error. Parameter value verification failed.</td><td>스킬서버 문제일 가능성이 높은 에러로 스킬서버 내 이슈를 우선 점검하여 주시기 바랍니다.</td></tr><tr><td>204</td><td>Invalid json response from bot-skill.</td><td>json format이 잘못된 경우로 말풍선 도움말 내 제한 및 유의사항을 참고하여 json format을 수정해주세요.</td></tr><tr><td>205</td><td>Invalid skill-json format. This talk bubble is not suitable for advertising.</td><td>광고용 Json format이 잘못된 경우로 말풍선 도움말 내 제한 및 유의사항을 참고하여 json format을 수정해주세요.</td></tr><tr><td>301</td><td>Bot Internal Error. Please contact technical support.</td><td>봇 내부 통신 에러로 문의하여 주시기 바랍니다.</td></tr><tr><td>302</td><td>Bot is not connected to an App while the receiver is set to "appuserId". Please connect your bot with an app.</td><td>발송 대상이 appUserId이지만 봇에 app이 연결되어 있지 않은 상태입니다. app을 연결하여 주시기 바랍니다.</td></tr><tr><td>311</td><td>Invalid bot event name. Check your event name.</td><td>유효하지 않은 Event name입니다. Event name을 점검하여 주시기 바랍니다.</td></tr><tr><td>401</td><td>There's Kakao Talk Channel long term limits</td><td>메시지 발송 제한 상태로 자세한 내용은 문의하여 주시기 바랍니다.</td></tr><tr><td>402</td><td>Long term limits on sending messages</td><td>메시지 발송 제한 상태로 자세한 내용은 문의하여 주시기 바랍니다.</td></tr><tr><td>403</td><td>Message delivery limited 180 days</td><td>메시지 발송 제한 상태로 자세한 내용은 문의하여 주시기 바랍니다.</td></tr><tr><td>404</td><td>Message delivery limited 90 days</td><td>메시지 발송 제한 상태로 자세한 내용은 문의하여 주시기 바랍니다.</td></tr><tr><td>405</td><td>Message delivery limited 60 days</td><td>메시지 발송 제한 상태로 자세한 내용은 문의하여 주시기 바랍니다.</td></tr><tr><td>406</td><td>Message delivery limited 30 days</td><td>메시지 발송 제한 상태로 자세한 내용은 문의하여 주시기 바랍니다.</td></tr><tr><td>407</td><td>Block turned off by operation policy.</td><td>메시지 발송 제한 상태로 자세한 내용은 문의하여 주시기 바랍니다.</td></tr><tr><td>999</td><td>Internal server error occured.</td><td>봇 내부 통신 에러일 가능성이 높은 케이스로, 스킬서버 등 이슈가 없는지 확인하신 뒤 문의하여 주시기 바랍니다.</td></tr></tbody></table>


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/event-api.md
