> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/bot_setting.md).

# 봇 설정

**봇 설정**이란 봇의 각종 정보를 변경/수정하는 메뉴이며, 봇의 타입에 따라서 설정 메뉴의 구성이 다릅니다. 챗봇은 한 개의 설정 메뉴를 제공하고 있습니다.

{% hint style="info" %}
**Information.**

본 페이지에서는 카카오톡 채널 챗봇의 '설정' 메뉴와 보이스봇의 '설정 > 관리' 메뉴에서 제공하는 공통 설정 기능을 설명합니다.
{% endhint %}

## 기본 정보 <a href="#basic_information" id="basic_information"></a>

봇 기본정보 영역에서는 봇의 이름, 운영 채널 연결, 개발 채널 연결, 봇ID를 확인할 수 있습니다.

* **봇 이름** : 필수 정보이며, 특수 기호 없이 최대 20자까지 작성하실 수 있습니다.
* **운영 채널** : 실 서비스 목적의 카카오톡 채널
* **개발 채널** : 개발 및 테스트 목적의 카카오톡 채널
* **운영 채널 연결** : 봇에 연결할 운영 채널을 선택하실 수 있습니다. 봇을 만든 후, 한 번이라도 배포해야 이 채널과 연결됩니다.
* **개발 채널 연결** : 봇을 배포하기 전에, 챗봇 관리자센터에서 설계 및 저장한 상태의 봇을 연결할 개발 채널을 선택하실 수 있습니다. 운영 채널과 동일하게 카카오톡 채널 관리자센터에서 생성하실 수 있으며, 내부 테스트를 위해서 사용할 카카오톡 채널을 연결하시면 됩니다.
* **봇 카테고리** : 연결된 카카오톡 채널의 카테고리로 자동 설정됩니다.
* **앱키 설정** : 기본 정보 영역에서는 마스터가 ‘앱키 설정’을 할 수 있습니다. 앱키 설정은 제 3자 정보제공 동의가 필요한 개인정보를 취급하는 봇 설계 시 필요하며 kakao developers를 통해 사용자의 특정 정보를 카카오에서 제공받는 기능을 설정합니다.

{% hint style="info" %}
**Information.**

상세한 설정 방법은 아래의 비즈니스 인증 채널과 디벨로퍼스 앱 연결하기를 참조하시길 바랍니다.
{% endhint %}

#### 비즈니스 인증 채널과 디벨로퍼스 앱 연결하기 <a href="#connect_bussiness_channel_and_app" id="connect_bussiness_channel_and_app"></a>

비즈니스 인증을 받은 채널과 비즈니스 인증을 받은 앱을 연결해야 합니다. 비즈니스 인증 채널을 신청하실 때에는 실제 서비스에서 사용할 카카오톡 채널로 신청해야 합니다.

{% hint style="danger" %}
**Caution**&#x20;

이 때 디벨로퍼스 앱 사용자 설정에서 "카카오 로그인 활성화" ON 필수입니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FBAcfjrd4iowcRDsusKnz%2Fimg06.png?alt=media&amp;token=70dbaeec-b6e8-4fcf-94aa-be7b13ed971e" alt=""><figcaption></figcaption></figure>

봇을 제작하는 마스터가 [**카카오톡 채널 관리자센터**](https://accounts.kakao.com/login/kakaoforbusiness?continue=https://center-pf.kakao.com/)에서 비즈 카카오톡 채널 인증을 받고 [**카카오 디벨로퍼스**](https://developers.kakao.com/)에서 비즈앱 인증을 각각 받습니다. 그리고 [**카카오 디벨로퍼스**](https://developers.kakao.com/console/app?continue=/review)에서 위에서 만든 비즈니스 인증 채널 및 비즈 앱을 연결해줍니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FSjV552mq1lNoS88rqQL4%2Fp.15%2C18.png?alt=media&amp;token=c9324c33-cb5c-404a-a81d-4323ab5cff1c" alt=""><figcaption><p>디벨로퍼스 > 앱 > 추가 기능 신청 > 신청 가능 대상 > 추가 기능 > 카카오톡 채널 연결</p></figcaption></figure>

* **봇 ID** : 봇이 가진 고유한 ID입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FaAksM2NpQxL4rGbNl70x%2Fbot_setting1.png?alt=media&amp;token=379560ce-a9df-43aa-867e-f2ef20582f9d" alt=""><figcaption><p>챗봇의 설정 중 기본 정보</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F3FG92qdG7KxjNS2iwb87%2Fbot_setting2.png?alt=media&amp;token=28ac7e32-9a56-434d-81cd-9a74541af216" alt=""><figcaption><p>보이스봇의 설정 > 관리 탭의 기본 정보</p></figcaption></figure>

## 봇 상태 <a href="#bot_status" id="bot_status"></a>

봇 상태 영역에서는 봇의 동작 상태를 확인할 수 있으며, 제재를 받거나 기타 문제가 생기게되면 해당 영역에 상태정보와 사유정보가 노출되게 됩니다.

* 봇 생성 후, 한 번도 배포한 적이 없는 경우: 준비 (정상)
* 첫 번째 배포 후, 정상적으로 봇이 작동하는 경우: 실행 (정상)
* 봇이 제재를 받아 정지 되었을 때: 차단

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FHs2IxQuxdevvE9IA6eF9%2Fsettings-bot-status.png?alt=media&amp;token=4f773e47-a086-44f9-84dc-d45b73e7ae3f" alt=""><figcaption><p>실행중인 봇 상태</p></figcaption></figure>

## 봇 설정 <a href="#setting_bot" id="setting_bot"></a>

### 이용제한 BLOCK-Bot <a href="#setting1" id="setting1"></a>

'카카오톡 채널'의 '이용 제한'으로 인해 봇이 차단된 상태입니다.

챗봇은 채널의 '이용제한' 조치는 위반 활동의 누적 정도에 따라 영구적으로 이용이 제한될 수 있습니다.

영구적으로 제재된 경우 봇 상태는 ‘차단’으로 변경되어 사용할 수 없습니다.

자체적으로 '봇차단 해제' 및 '채널 해제'는 불가능하며 이 경우 '카카오톡 채널' 고객센터로 '이용 제한'에&#x20;

대한 소명절차를 거쳐 해제를 요청하여 주시기 바랍니다.

이후 해제될 경우 봇은 차단 해제가 되어 다시 사용이 가능합니다.

### 이용제한 BLOCK-Message(Event API) <a href="#setting2" id="setting2"></a>

‘카카오톡 채널'의 ‘이용 제한'으로 인해 챗봇의 메시지 발송이 차단된 상태입니다.

챗봇은 채널의 '이용제한' 조치는 위반 활동의 누적 정도에 따라 이용이 제한될 수 있습니다.

위반 누적 정도에 따라 챗봇의 메시지 발송은 N일간 발송이 불가능합니다.

N일이 지나면 봇의 메시지 발송 차단 상태는 해제가 되어 다시 사용이 가능합니다.

만약 영구적 제한이 된 경우 메시지 발송 차단 해제는 불가능하며 이경우 '카카오톡 채널' 고객센터로 '이용 제한'에&#x20;

대한 소명절차를 거쳐 해제를 요청하여 주시기 바랍니다.

이후 해제될 경우 봇 메시지 차단 해제가 되어 다시 사용이 가능합니다.

### &#x20;이용제한 BLOCK-Block <a href="#setting3" id="setting3"></a>

가이드의 의무 위반으로 인해 챗봇의 '이용제한'으로 블록이 차단된 상태입니다.

블록이 차단된 경우 챗봇 블록의 응답은 제거(text, skill 포함) 됩니다.

이경우 해당 블록의 응답을 운영정책 가이드에 위배되지 않도록 수정하여 주시면 다시 정상 사용이 가능합니다.

'이용제한' 조치는 위반 활동이 누적 되며 누적 정도에 따라 최종적으로 봇의 이용이 영구적으로 제한될 수 있습니다.

궁금하신 사항은 '카카오톡 채널 챗봇' 고객센터로 문의하여 주시기 바랍니다.

## 봇 삭제 <a href="#delete_bot" id="delete_bot"></a>

봇 삭제영역은 마스터에게만 제공되는 기능으로 클릭시 확인 후, 봇을 삭제하게 됩니다. 삭제를 신청하면 7일 후 봇이 삭제됩니다. 이 기간동안 함께 봇을 제작한 공동 작업자들과 마스터는 봇 삭제에 대해서 협의하고 봇 삭제를 취소할 수 있습니다. 해당 기간이 지나면 봇은 완전 삭제되고 복구가 불가능합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FFwOvRIZQdtCwKM3Hai3P%2Fsettings-bot-deletion.png?alt=media&amp;token=176ec9c2-b500-47d2-b5b7-0f2f91dd5d2d" alt=""><figcaption><p>마스터가 봇 삭제를 클릭하면, 다시 한 번 확인 후 삭제를 진행합니다</p></figcaption></figure>

{% hint style="danger" %}
**Caution.**

봇 삭제가 안 되는 경우, 챗봇에 연결된 월렛이 해제되었는지 확인해주시길 바랍니다.
{% endhint %}

**연결된 월렛 정보 확인**

월렛 연결이 완료되었다면, 월렛 작업 권한을 보유한 모든 작업자가 지불 정보 탭에서 연결된 월렛 정보를 확인할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FjSc8nMpO4F9YzIvPWOCU%2Fwallet-bot-step3.png?alt=media&amp;token=c5b229ec-28ea-4bec-a222-d0376171043c" alt=""><figcaption><p>월렛 이름, 영업권, 캐시 잔액 클릭시 곧바로 상세 화면에 진입할 수 있습니다.</p></figcaption></figure>

'내 챗봇' 목록에서도 봇과 연결된 월렛 정보를 한 눈에 확인할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fajb67E4nEg0yOcBK2TgO%2Fbotsetting.png?alt=media&amp;token=55a8caef-79c0-4212-8e3f-960ed0300373" alt=""><figcaption></figcaption></figure>


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/bot_setting.md
