> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/check_skill_error_history.md).

# 스킬 오류 내역 확인하기

스킬로 그린 말풍선이 특정 오류로 인하여 사용자에게 발송되지 않을 수 있습니다.

이러한 경우 카카오톡 알림으로 오류 발생 사실을 수신하고, 챗봇 관리자센터의 스킬 오류 내역을 통해 상세 오류 내용을 확인할 수 있습니다.

카카오톡 알림은 오류가 발생한 봇, 블록, 오류 타입 정보를 주기적으로 발송합니다.\
챗봇 관리자센터의 오류 내역은 오류의 상세 원인과 발생 시각을 보여줍니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FHXU6ECMamp39XoDZawbT%2Fskill-error-alert-ex.png?alt=media&amp;token=9a6c1d93-c85f-4b34-bb29-1a0926be658a" alt=""><figcaption><p>카카오톡 알림 수신 예시</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F4JkCeTndzqwWqRTJ8ubt%2Fskill-error-ex.png?alt=media&amp;token=25a07e65-dfd1-42b1-adfd-49bda33800f2" alt=""><figcaption><p>챗봇 관리자센터 오류 내역 예시</p></figcaption></figure>

확인할 수 있는 오류의 종류는 크게 **스킬 서버 연결 오류**와 **말풍선 가이드 위반** 두 가지입니다.

* **스킬 서버 연결 오류**는 타임아웃 발생, 서버 연결 실패, 네트워크 접근 실패 등 사용자의 스킬 서버에서 발생하는 오류입니다.
* **말풍선 가이드 위반**은 사용자가 작성한 JSON 포맷이 [**스킬 가이드 형식**](/main/tool/chatbot/skill_guide/answer_json_format.md)과 어긋나서 발생하는 오류입니다.

일부 스킬 오류는 확인되지 않을 수 있습니다. 스킬 응답이 발송되지 않았으나 오류 내용을 확인할 수 없는 경우, 고객센터로 문의해 주시기 바랍니다.

{% hint style="info" %}
**Information.**

* **운영 채널**에서 발생한 스킬 오류만 확인 가능합니다. (봇 테스트 및 개발 채널에서 발생한 오류는 확인 불가능)
* **Event API**로 발송한 응답의 오류는 확인이 **불가능**합니다. [**이벤트 발송 성공여부 조회 API**](/main/tool/chatbot/main_notions/event-api.md#eventapi_develope_guide)를 이용하여 확인해 주세요.
* 스킬 v1 포맷을 사용 중 말풍선 가이드를 위반한 경우, 구체적인 오류를 제공하지 않습니다. 관련 [**공지**](https://chatbot.kakao.com/notice/6487d6739748dd5d86aafec3)를 확인해 주시기 바랍니다.
  {% endhint %}

## 카카오톡 채널로 알림 받기 <a href="#receive_notification_kakaotalk" id="receive_notification_kakaotalk"></a>

### 알림 수신 설정 <a href="#notification_reception_settings" id="notification_reception_settings"></a>

운영 채널의 스킬 응답에 오류가 발생할 때마다, 카카오톡 채널(‘챗봇 관리자센터')을 통해 오류 발생 사실을 수신할 수 있습니다. 알림 수신은 해당 챗봇의 관리자라면 누구나 가능합니다.\
\
챗봇 관리자센터 우측 상단의 ‘계정 > 알림 설정’을 클릭합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FCqhfN6gwck3oZ8jm6oCT%2Fskill-error-3.png?alt=media&amp;token=91a67dba-a003-4194-aa96-0d537a89b6df" alt=""><figcaption></figcaption></figure>

챗봇 목록에서 원하는 챗봇을 선택하여 알림 수신 설정을 바꿉니다. 알림 수단 ‘카카오톡 채널'을 ON해야만 ‘스킬 말풍선 오류 내역'을 ON할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FAJzFLD0B3yRlxxm6BdWG%2Fspaces_aAlIRje8gm7qrQZZCBzh_uploads_pcOAfJ1yR5GfXlnUkIsD_skill-error-4.webp?alt=media&amp;token=ef390a2b-12be-4b85-a3b6-4e6784d67880" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
**Information.**

* 신규 봇의 **마스터**인 경우, 스킬 말풍선 오류 내역은 **기본 ON 상태**로 설정됩니다.
* 위임봇은 스킬 오류 내역을 수신할 수 없습니다. 위임봇에서 발생한 오류 내역은 대행봇이 일괄 수신합니다.
  {% endhint %}

### 수신 주기 설정 <a href="#receiving_cycle_settings" id="receiving_cycle_settings"></a>

스킬 오류가 발생했을 때 알림을 얼마나 자주 수신할 것인지를 설정합니다.

10분으로 설정한 경우, 매 시간 00분/ 10분/ 20분/ 30분/ 40분/ 50분마다 카카오톡 메시지가 전송됩니다. 1시간으로 설정한 경우, 매 시간 00분마다 카카오톡 메시지가 전송됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F2sBHPtDuYYokQDL5dlgk%2Fspaces_aAlIRje8gm7qrQZZCBzh_uploads_B8FQXoV7fpI1zUPf547g_skill-error-5.webp?alt=media&amp;token=b1fcc9fc-fb0d-497d-bef6-3633d6e0624b" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
**Information.**

* **수신 주기**는 챗봇의 **마스터**만 설정 가능합니다. 작업자는 별도 설정이 불가능합니다.
  {% endhint %}

### 알림 내용 <a href="#notification_content" id="notification_content"></a>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FF1StK5ZWSTS8j1gDI6o5%2Fskill-error-6.png?alt=media&amp;token=43a1e169-c7b0-4a67-9d94-86e81ef24570" alt=""><figcaption></figcaption></figure>

알림에서 확인할 수 있는 정보는 크게 세 가지입니다.

#### **봇 정보** <a href="#bot_info" id="bot_info"></a>

지난 10분 또는 1시간 동안 스킬 오류가 한 번이라도 발생한 봇을 알려줍니다.\
\
한 말풍선에는 하나의 봇 정보만 담기게 됩니다. 따라서 n개의 봇에 대해 알림 수신을 ON했다면, 한 번에 최대 n개의 말풍선을 수신할 수 있습니다. 위 사진은 두 개의 봇에 대한 알림을 수신한 예시입니다.

#### **블록 정보** <a href="#block_info" id="block_info"></a>

지난 10분 또는 1시간 동안 스킬 오류가 발생한 블록을 오류 타입 별로 알려줍니다.\
블록 정보는 오류 타입 별로 각각 5개까지만 노출됩니다.

#### **오류 타입 정보** <a href="#error_type_info" id="error_type_info"></a>

지난 10분 또는 1시간 동안 발생한 스킬 오류 타입을 알려줍니다.\
\
오류 타입은 크게 ‘스킬 서버 연결 오류'와 ‘말풍선 가이드 위반'으로 나뉩니다. 스킬 서버 연결 오류는 타임아웃 발생, 서버 연결 실패, 네트워크 접근 실패 등 사용자의 스킬 서버에서 발생하는 오류입니다. 말풍선 가이드 위반은 사용자가 작성한 JSON 포맷이 [**스킬 가이드 형식**](/main/tool/chatbot/skill_guide/answer_json_format.md)과 어긋나서 발생하는 오류입니다.\
\
이외에도 말풍선 제한 사이즈를 초과하는 경우, ‘말풍선 사이즈 초과' 오류가 발생할 수 있습니다.\
\
챗봇 관리자센터의 스킬 오류 내역에서 더욱 상세한 원인을 확인할 수 있습니다.

## 챗봇 관리자센터에서 오류 내역 확인하기 <a href="#check_error_in_chatbot_admin" id="check_error_in_chatbot_admin"></a>

### 오류 내역 개요 <a href="#error_history_overview" id="error_history_overview"></a>

챗봇 관리자센터에서는 운영 채널의 스킬 오류 내역을 실시간에 가깝게 확인할 수 있습니다. 또한 카카오톡 알림보다 더욱 상세한 오류 원인을 제공합니다. 챗봇의 관리자라면 누구나 열람이 가능합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FMtjxitoy97bmMMjmDQW1%2Fskill-error-7.png?alt=media&amp;token=cff7ad78-7ddc-4262-af1d-9f753f570881" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
**Information.**

* 스킬 오류 내역은 **최대 100개**까지만 노출됩니다.
* 지식베이스로 스킬 응답을 사용하는 경우, 블록명이 ‘지식+’으로 노출됩니다.
* 블록명과 스킬명은 **오류 발생 시점을 기준**으로 기록되기에, 현재 정보와 차이가 있을 수 있습니다.
  {% endhint %}

### 오류 내역 상세 <a href="#error_history_details" id="error_history_details"></a>

#### **블록명 & 연결 스킬명** <a href="#block_and_connect_skill_name" id="block_and_connect_skill_name"></a>

스킬 응답 오류가 발생한 블록과 스킬의 이름입니다. 블록명이나 스킬명이 긴 경우, 최대 2줄까지만 노출됩니다. 오류 발생 시점을 기준으로 기록되므로, 현재의 이름 정보와 차이가 있을 수 있습니다.\
\
클릭하면 해당하는 블록 또는 스킬의 페이지로 이동할 수 있습니다.

#### **오류 타입** <a href="#error_type" id="error_type"></a>

스킬 응답에서 발생한 오류 타입으로, 크게 스킬 서버 연결 오류와 말풍선 가이드 위반이 있습니다.\
카카오톡 알림으로 전달되는 오류 타입과 동일합니다.

#### **세부 오류 메시지** <a href="#detailed_error_message" id="detailed_error_message"></a>

스킬 응답 오류의 구체적인 원인입니다.

#### **마지막 발생 시각** <a href="#last_occurrence_time" id="last_occurrence_time"></a>

스킬 응답 오류가 마지막으로 발생한 시각입니다.\
동일한 블록 & 동일한 스킬 & 동일한 원인으로 발생한 오류인 경우, 마지막 발생 시각만 업데이트됩니다.


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/check_skill_error_history.md
