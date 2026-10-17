> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/authority.md).

# 권한

**권한**이란 봇 작업자들이 사용할 수 있는 기능을 규정하고, 구분하여 제공하는 체제입니다. 흔히 카페에서 사용되는 ‘카페장’, ‘운영자’ 등의 구분과 같습니다. 챗봇 관리자센터에서는 기본적으로 **마스터 권한**과 **정식 작업자 권한**, 그리고 마스터가 생성할 수 있는 인스턴트성의 **커스텀 권한**이 있습니다.

{% hint style="info" %}
**Information.**

마스터, 정식 작업자 권한은 모든 봇에 기본적으로 존재합니다.
{% endhint %}

## 마스터 권한 <a href="#master_authority" id="master_authority"></a>

**마스터 권한**은 기본적으로 봇을 생성한 사람에게 부여됩니다. 봇을 삭제하거나 봇에 연결되는 APP Key 설정을 할 수 있습니다. 마스터 권한만이 가진 기능은 아래와 같습니다.

* 봇 삭제 및 삭제 취소
* APP key 설정
* 카카오톡 채널 연결 및 관리
* 커스텀 권한 생성/관리
* 하위 작업자 권한 관리 및 봇 강제 탈퇴

마스터는 봇 별로 한 명만 존재할 수 있습니다. 마스터가 탈퇴 하고싶은 경우에는 다른 정식 작업자에게 마스터 권한을 이양해야합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FwRhULyYVjMWRiPG3Y4Np%2F01%402x.png?alt=media&amp;token=52847abb-4da7-4507-a7f5-c7a5dff7cbf6" alt=""><figcaption><p>마스터가 다른 정식작업자에게 권한을 이양하는 팝업입니다</p></figcaption></figure>

만약 마스터 계정이 제재를 당하게 되는 경우에는 정식 작업자들이 다른 마스터를 임명하게 되고, 기존의 마스터 권한자는 정식 작업자로 강등됩니다.

## 정식 작업자 권한 <a href="#operator_authority" id="operator_authority"></a>

**정식 작업자 권한**은 기본적으로 봇을 제작하게 되는 작업자들에게 주어지는 권한이며, 대부분의 봇 설정 및 제작 기능을 가지고 있습니다. 다만 다른 정식 작업자간의 권한을 조정할 수는 없습니다. 만약 계정 제재 등의 이유로 마스터 권한자가 부재일 경우, 정식 작업자는 마스터 권한자를 임명할 수 있고 다른 작업자를 초대할 수도 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F3xGfHATvTv5sjPrw6kkL%2F02%402x.png?alt=media&amp;token=1c242aab-d748-4838-b64b-9235becc1144" alt=""><figcaption><p>관리자 메뉴의 상단 영역에서 관리자를 초대할 수 있습니다</p></figcaption></figure>

## 커스텀 권한 <a href="#custom_authority" id="custom_authority"></a>

**커스텀 권한**은 임시 작업자들에게 적합한 권한입니다. 마스터가 만들어낼 수 있는 권한으로, 봇 별로 용도에 맞게 설정할 수 있습니다. 예를 들어, 특정 단순작업을 위한 작업자가 팀에 합류했을 때 봇의 핵심적인 내용인 블록이나 출력 등에 대해 접근할 수 없도록 해당 기능의 읽기/쓰기 권한을 OFF할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FS6auMnzlkrX4jzALlkIE%2F03%402x.png?alt=media&amp;token=28959a7c-cacd-48ce-868a-dd08afe659f8" alt=""><figcaption><p>마스터가 커스텀 권한을 생성하고 관리하는 팝업입니다</p></figcaption></figure>

## 월렛 권한 <a href="#wallet_authority" id="wallet_authority"></a>

* 월렛 권한은 챗봇 마스터가 챗봇과 연결된 월렛을 사용할 수 있게 할 수 있는 권한입니다. 월렛 권한을 부여받은 사용자만 챗봇에 월렛을 연결할 수 있지만 이미 챗봇에 월렛이 연결된 경우에는 더 이상 월렛을 연결할 수 없습니다. 또한, 월렛 권한은 챗봇 월렛 최초 생성 시 노출되는 카카오 광고 통합서비스 이용약관에 가입한 사용자에게만 부여할 수 있습니다.
* 연결된 월렛이 없는 경우 월렛 작업 권한을 가진 관리자 모두 본인 소유의 월렛과 챗봇을 연결할 수 있으며, 연결 완료시 해당 월렛의 마스터가 월렛 관리 권한을 **자동**으로 부여 받습니다.
* 챗봇 관리자센터에서는 월렛 마스터 권한을 임의로 타 멤버에게 이전 시켜드리지 않습니다. 만일 월렛 마스터의 부재(퇴사, 부서이동 등)가 예상되는 경우, 사전에 마스터 권한 이전을 진행해 주시길 바랍니다. 부득이하게 월렛 마스터 부재로 마스터 권한 이전이 불가할 경우에는 챗봇 마스터가 월렛 연결 해제 후 새로운 월렛을 생성하여 운영하여 주시기 바랍니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FvKG4t9VgZ1CAJ9Kg3vtq%2Fpermissions-wallet.png?alt=media&amp;token=73ef23c6-e841-47db-b755-c25f1fe6f276" alt=""><figcaption><p>챗봇과 연결된 월렛의 마스터인 사용자의 권한 수정 팝업</p></figcaption></figure>

월렛 권한 별 가능한 작업목록

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FEQSD1J6xEAufdyV4ZE8Z%2Ffunc_wallet_list.png?alt=media&amp;token=c3a35860-7f6c-4100-b98e-d8786d70b1d2" alt=""><figcaption></figcaption></figure>


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/authority.md
