> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/plugin.md).

# 플러그인

**플러그인(Plugin)** 은 봇 작업자가 되묻기 질문을 설정하거나 원하는 출력을 설정하여 봇이 ‘별도로 정의된 질문 혹은 답변’을 하기 위한 기능입니다.

플러그인은 **파라미터 설정** 을 통해서 사용할 수 있는 플러그인과 **봇 응답형식** 에서 사용할 수 있는 플러그인으로 나누어져 있습니다.

## '파라미터 설정' 플러그인 <a href="#setting_parameter_plugin" id="setting_parameter_plugin"></a>

파라미터 설정에서 사용할 수 있는 플러그인은 되묻기 질문에서 봇이 필수적으로 받아야하는 파라미터를 사용자가 좀 더 편리하고 정확하게 입력하도록 돕는 보조입력 수단입니다.

예를 들어 사용자의 주소지를 필수로 입력받고 싶을 때, 정해진 형식이 주어지지 않는다면 사용자들은 다양한 방식으로 입력할 수가 있습니다. 이는 사용자에게 좋지 않은 경험을 제공할 수 있으므로 정확하고 쉽게 입력할 수 있는 ‘정의된 폼’을 플러그인 기능을 통해 제공할 수 있는 것입니다. 플러그인을 사용하면 사용자는 편리하게 답변을 입력할 수 있고, 봇 작업자는 사용자에게 원하는 답변의 형태를 보다 정확한 파라미터의 형태로 정의할 수 있게 됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F5bxcWExTrRavSFli4Ee1%2Fplugin-list.png?alt=media&amp;token=a9c01bd0-c99d-4d3d-9f67-58b601108495" alt=""><figcaption><p>‘파라미터 설정’에서 사용할 수 있는 플러그인 목록입니다</p></figcaption></figure>

{% hint style="info" %}
**Information.**

개별 플러그인의 사용법은 아래 페이지에서 상세하게 확인할 수 있습니다.

* [**바코드(QR) 플러그인**](/main/tool/chatbot/skill_guide/apply_skill_to_plugin.md#qr_plugin)
* [**날짜/시간 플러그인**](/main/tool/chatbot/skill_guide/apply_skill_to_plugin.md#day_time_plugin)
* [**이미지 보안전송 플러그인**](/main/tool/chatbot/skill_guide/apply_skill_to_plugin.md#send_image_plugin)
* [**위치 전송 플러그인**](/main/tool/chatbot/skill_guide/apply_skill_to_plugin.md#send_location_plugin)
  {% endhint %}

## '봇 응답형식 설정' 플러그인 <a href="#bot_response_setting_plugin" id="bot_response_setting_plugin"></a>

봇 응답형식 설정에서의 플러그인은 버튼을 통해 사용자가 카카오톡 채널과 관련된 컨텐츠로 쉽게 연결할 수 있도록 돕는 보조수단입니다.

예를 들어, 사용자에게 카카오톡 채널에 등록된 쿠폰을 함께 노출하고 싶은 경우 추가 버튼을 통해 ‘카카오톡 채널 쿠폰’을 설정할 수 있습니다.

{% hint style="danger" %}
**Caution.**

이미지형 말풍선에는 적용할 수 없습니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FDsImJdEqhajNYxOuTalO%2Fplugin-buttons.png?alt=media&amp;token=8952d073-8a01-4136-b871-b73b264a2b4b" alt=""><figcaption><p>‘봇 응답형식 설정’ 탭의 버튼 설정에서 플러그인을 이용하면 다양한 기능을 사용할 수 있습니다</p></figcaption></figure>

### 공유하기 <a href="#sharing" id="sharing"></a>

공유하기 플러그인은 말풍선에서 플러그인이 설정된 버튼을 눌렀을 때, 해당 말풍선을 카카오톡 친구에게 공유할 수 있는 기능입니다. 공유하기 기능을 사용하면 목적에 따라 이벤트 홍보에 활용해 볼 수 있습니다.

{% hint style="danger" %}
**Caution.**

**가능 말풍선 :** 카드형, 커머스형, 리스트형, 아이템형 말풍선 (단일형만 가능)

**가능 조건 :**

* 단일형만 가능 (케로셀 불가능)
* 버튼이 없을 경우 가능 (단, 버튼에 플친 쿠폰/플친 포스트/공유하기 플러그인 포함되면 가능)
* 리스트형 말풍선의 경우 리스트 목록에 기능 설정이 없어야 가능
  {% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FLuyU1BQtloI7squOzliM%2Fplugin-share.png?alt=media&amp;token=50c98494-c27e-4e0c-8ab8-386b3c8e5466" alt=""><figcaption></figcaption></figure>

### 카카오톡 채널 포스트 <a href="#kakaotalk_channel_post" id="kakaotalk_channel_post"></a>

버튼을 눌렀을 때 카카오톡 채널에 등록되어 있는 카카오톡 채널 포스트로 이동할 수 있는 기능입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FRGqJqLgpw22QpwREEDAC%2Fplugin-plusfriend.png?alt=media&amp;token=1c8d8a73-8b40-4176-8f6c-b214dcb7fb2a" alt=""><figcaption></figcaption></figure>

### 카카오톡 채널 쿠폰 <a href="#kakaotalk_channel_coupon" id="kakaotalk_channel_coupon"></a>

버튼을 눌렀을 때 카카오톡 채널에 등록된 카카오톡 채널 쿠폰을 연결시켜주는 기능입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F7aATHXHtCZeaaKJEdcWp%2Fplugin-pf-coupon.png?alt=media&amp;token=5f9770ba-79f8-4878-bae3-6b6c4cecb9e1" alt=""><figcaption></figcaption></figure>

### 상담 연결 <a href="#contact_staff" id="contact_staff"></a>

버튼을 눌렀을 때 상담을 연결할 수 있는 기능입니다.

봇에 연결된 채널이 1)[**채널관리자센터의 1:1 채팅**](https://accounts.kakao.com/login/kakaoforbusiness?continue=https://center-pf.kakao.com/profiles) 혹은 2)[**상담톡**](https://business.kakao.com/info/bizmessage/) 기능을 사용할 경우 상담 연결 사용이 가능합니다. 봇 응답 형식 설정 플러그인 중 '상담 연결 플러그인'을 활용하여, 말풍선 버튼에 상담 연결기능을 추가할 수 있습니다.

특정 시나리오를 구현하다 상담이 필요한 경우 해당 블록 버튼에 상담 플러그인을 설정하여 상담으로 연결하도록 시나리오 구성을 할 수 있습니다.

* 웰컴블록 활용\
  챗봇에 진입한 경우 처음 진입한 사용자에게만 웰컴블록이 노출됩니다.\
  이때 웰컴블록 응답에 상담 플러그인을 사용하여 자동 노출되도록 설정 할 수 있습니다.
* 폴백블록 활용\
  사용자가 이해할 수 없는 발화를 입력한 경우\
  폴백블록 응답에 상담 플러그인을 사용하여 상담 연결을 유도 할 수 있습니다.
* 일반블록 활용\
  특정 발화는 무조건 상담 연결로 유도하도록\
  일반블록 응답에 상담 플러그인을 사용하여 상담 연결을 유도 할 수 있습니다.

{% hint style="danger" %}
**Caution.**

상담 연결이 가능한 카카오톡 프로필에서만 동작하는 버튼입니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F4mvqeTNmB9RnTKmzBRT5%2Fplugin-counsel.png.png?alt=media&amp;token=cc2b1f76-18c0-43d9-96ca-3151cae27f11" alt=""><figcaption></figcaption></figure>


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/plugin.md
