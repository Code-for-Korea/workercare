> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/wallet.md).

# 월렛

## 월렛이란? <a href="#what_is_wallet" id="what_is_wallet"></a>

* 월렛은 챗봇 관리자센터에서 Event API를 사용할 때 필요한 캐시를 관리할 수 있는 기능입니다.
* Event API를 통한 메시지를 전송할 때는 월렛 생성 및 연결이 필수입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FhmsRCPgMlfmgoMU51TGu%2Fwallet-definition.png?alt=media&amp;token=661d3821-8288-47c9-a0b5-f08632076e44" alt=""><figcaption><p>나의 월렛에서 권한을 가지고 있는 월렛 목록을 확인할 수 있습니다</p></figcaption></figure>

{% hint style="info" %}
**Information.**\
나의 월렛 목록에 표시되는 월렛 상태는 아래와 같습니다.

* 운영중 : 챗봇과 월렛이 연결되어 정상 과금이 이루어질 수 있는 상태입니다.
* 연결대기 : 챗봇과 월렛이 연결되지 않은 상태를 말합니다. 연결대기 상태의 월렛만 챗봇과 연결할 수 있습니다.
* 관리자 정지 : 챗봇 관리자센터 운영자에 의해 관리자 정지로 전환된 상태입니다.
* 잔액 부족 : 캐시 잔액 부족 또는 자동결제카드가 결제 실패하여 유료 차감액이 정상적으로 과금이 될 수 없는 상태입니다.
* 삭제 대기중 : 삭제 신청 완료하여 대기중인 상태입니다. 신청 후 7일이 지난 시점에 월렛이 최종 삭제되고 삭제 대기기간 중에는 삭제를 취소할 수 있습니다.
  {% endhint %}

## 기본정보 <a href="#basic_information" id="basic_information"></a>

* 월렛을 생성 시 입력한 정보 및 월렛의 상태를 기본정보 화면에서 확인할 수 있습니다.
* 월렛에 연결된 챗봇이 어떤 것인지 정보를 확인하거나 월렛의 연결/해제 기록을 확인할 수 있고, 월렛을 삭제할 수 있습니다.
* 월렛 마스터는 권한을 이관할 수 있습니다. 이때, 월렛이 챗봇과 연결되어 있고 월렛 작업 권한을 가진 봇 작업자가 1명 이상 있어야 이관이 가능합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FdAYFpHjMc93gnz1gPIiM%2Fwallet-basic-info.png?alt=media&amp;token=25e7cb24-125f-4d5a-abcb-c0dd75342d2c" alt=""><figcaption><p>월렛 상세 > 기본정보 화면에서 사업자 월렛으로 생성 후 연결된 챗봇이 있을 경우</p></figcaption></figure>

## 요금정보 <a href="#fee" id="fee"></a>

* 요금정보 화면에선 월렛에 연결된 챗봇을 통해서 사용된 유료 사용량을 기준으로 오늘 사용된 요금과 이번달에 사용된 누적 요금 정보를 확인할 수 있습니다.
* 오늘 사용요금은 당일 04:00 \~ 익일 03:59를 기준으로 Event API 사용요금이 누적되어 노출됩니다.
* 이번달 누적 사용요금은 당월 1일 04:00 \~ 익월 1일 03:59를 기준으로 사용요금이 누적되어 노출됩니다.
* 대기기간 중에는 삭제를 취소할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FjlChuckO7zL7Wm9t2l8t%2Fwallet-billing-new.jpg?alt=media&amp;token=692bcc5b-08f8-4ac5-ac6e-2402d5a70372" alt=""><figcaption><p>월렛 상세 > 요금정보 화면에서 오늘 사용요금 및 이번달에 사용한 유료 사용량이 있을 경우</p></figcaption></figure>

## 캐시관리 <a href="#cash" id="cash"></a>

* 유상캐시는 신용카드, 카카오페이, 무통장입금 방식을 이용해 충전 가능합니다. (최소 1천 원 이상)
* 캐시관리 화면에서 노출되는 총 잔액은 유상캐시와 무상캐시의 합산입니다. 총 잔액이 0원 이하이고 자동결제카드가 연결되어 있을경우에는 카드 자동결제 예정액만큼 -(마이너스) 금액으로 노출됩니다.
* 무상캐시는 지급받을 경우, 무상캐시 대기에 등록되며 잔액에 반영되지 않지만 '사용하기' 버튼을 클릭하여 잔액에 반영할 수 있습니다. 단, 무상캐시는 유효기간이 있으므로 유효기간이 지난 경우 소멸되며 환불할 수 없습니다.
* 환불계좌는 월렛 마스터 권한을 가진 사용자만 등록 및 삭제할 수 있으며, 환불 요청은 월렛 작업 권한을 가진 관리자라면 모두 가능합니다.
* 충전내역, 캐시 소진내역, 무상캐시 사용현황, 환불 처리현황 탭에서 각 항목을 최대 6개월까지 조회할 수 있으며, 조회결과를 엑셀파일로 다운로드 받을 수 있습니다.

{% hint style="info" %}
**Information.**\
무통장입금은 **사업자 월렛인 경우에만 이용 가능**하며 1회용 가상계좌를 발급하여 입금을 진행합니다.\
발급된 가상계좌번호는 입력한 핸드폰 번호로 전송 가능하며, 입금 후 해당 가상계좌는 초기화 됩니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FYVyMHCnXGK4DIctvoFQX%2Fwallet-cash-management.png?alt=media&amp;token=aaf18da7-ae23-4192-899f-10456ac50d2f" alt=""><figcaption></figcaption></figure>

## 결제카드 관리 <a href="#payment_card" id="payment_card"></a>

* 결제카드 관리 화면에선 월렛에서 사용할 자동결제카드를 등록하거나 삭제할 수 있습니다. 월렛 권한을 가지고 있는 사용자는 월렛 당 3장의 자동결제카드를 등록할 수 있으며, 등록된 자동결제카드는 등록자 본인 혹은 월렛 마스터 권한이 있을 경우 삭제할 수 있습니다.
* 등록할 결제카드 선택시, 먼저 추가된 순서대로 카드 선택 목록에 노출됩니다.
* 자동결제카드를 등록할 때 일 지출한도를 설정할 수 있으며 일지출한도는 최소 1,000원 \~ 최대 1억원 까지 설정 가능합니다.
* 예비카드가 등록된 상태에서 결제카드 삭제시 첫 번째 등록된 예비카드가 결제카드로 변경되며, 일 지출한도 및 결제 예정금액을 그대로 이어받게 됩니다.

{% hint style="info" %}
**Information.**

* 자동결제 카드의 결제 예정액은 잔액이 0원 이하이고, 자동결제카드가 연결되어 있을 때 유료 차감이 발생할 경우 누적 됩니다.
* 자동결제 카드 결제 예정액이 50만원 이하일 경우, 하루에 한번 매일 24:00 \~ 24:20 분 사이에 카드 자동결제가 이루어 집니다.
* 자동결제 카드 결제 예정액이 50만원 이상일 경우, 50만원에 도달하는 시점에 카드 자동결제가 이루어 집니다.
  {% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FyDky5E1ErGMrHUi4bjtz%2Fwallet-card_new.png?alt=media&amp;token=a0463f62-d979-4f69-b123-8d4457c8da49" alt=""><figcaption></figcaption></figure>

{% hint style="danger" %}
**Caution.**

* 자동결제카드는 일반 신용카드만 등록할 수 있습니다.\
  체크카드와 신용카드 기능이 결합된 '하이브리드' 카드는 결제 시점에 은행의 점검 시간 영향을 받아 결제에 실패하므로 등록을 권장하지 않습니다.
* 카카오페이 중 비정상적인 상태로 결제 불가능한 카드는 매일 시스템에서 자동으로 삭제처리 됩니다.\
  이를 예방하기 위해 예비카드를 등록하여 안정적인 운영을 할 수 있습니다.
  {% endhint %}

## 세금계산서 <a href="#tax_bill" id="tax_bill"></a>

* 세금계산서는 사업자 타입의 월렛에만 노출되며, 월렛을 생성할 때 입력된 사업자등록번호를 기준으로 유료 차감량이 있을 때 매월마다 발행되는 세금계산서 목록을 확인할 수 있습니다.
* 전자세금계산서는 세금계산서 수신용 이메일로 영업일 2\~3일내 발행됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FkVGy1NxCJTZERlbUQYMN%2Fwallet-tax.png?alt=media&amp;token=e241d9c9-bad9-4c6f-825a-a5067b369562" alt=""><figcaption></figcaption></figure>

## 월렛 설정하기 <a href="#setting_wallet" id="setting_wallet"></a>

우측 상단 계정 레이어 에서 '내 월렛'을 선택하여 월렛 화면으로 진입할 수 있습니다. 월렛 화면에서는 월렛을 생성하고 관리할 수 있으며, 월렛을 생성한 사람에게는 자동으로 월렛 마스터 권한이 부여됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FZDPmxkjrmCj4DedwHa57%2Fwallet-01.png?alt=media&amp;token=83ee0ea1-429d-4719-b609-13d04ebd34a0" alt=""><figcaption><p>나의 월렛 목록 화면</p></figcaption></figure>

### 사업자 월렛 생성하기 <a href="#create_bussiness_wallet" id="create_bussiness_wallet"></a>

#### Step 1. 월렛 생성 버튼 클릭

내 챗봇 월렛 목록 우측 상단에서 '새로운 월렛 생성' 버튼을 클릭합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FpZGn1oFpR1LZXEGneBjZ%2Fwallet-02.png?alt=media&amp;token=59f458d5-caf2-441f-ad02-ccfc4aab2ed9" alt=""><figcaption></figcaption></figure>

#### Step 2. 유형 선택

월렛 유형 선택시 사업자 월렛을 선택 후 다음 버튼을 클릭합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FV7h3I48NI30CsTvSXdk5%2Fwallet-03.png?alt=media&amp;token=672dbb19-4fec-4756-8be0-1496adae85e4" alt=""><figcaption></figcaption></figure>

#### Step 3. 사업자등록번호 입력

정보입력 단계에서 사업자등록번호를 입력 후 확인 버튼을 클릭합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F8Pwph5AEUJzW063EapPU%2Fwallet-04.png?alt=media&amp;token=0a1c99df-3bbf-41fc-a95e-4d3931fc2a16" alt=""><figcaption></figcaption></figure>

이미 카카오 서비스에서 비즈니스 채널 인증 등을 통해 비즈니스 정보를 등록한 경우 아래와 같이 조회됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FyTV9P9SwvdqsH8mK2gxK%2Fwallet-05.png?alt=media&amp;token=62af4138-8490-46f6-93be-9c9b646db137" alt=""><figcaption></figcaption></figure>

신규 등록이라면 사업자 이름, 대표자 이름, 업태, 종목, 사업자 주소를 필수로 입력 후 다음 버튼을 클릭합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FeykUj2mEZPWmwdCkJJgW%2Fwallet-06.png?alt=media&amp;token=aa1637cd-1be4-43ed-9502-1b964f1e370f" alt=""><figcaption></figcaption></figure>

#### Step 4. 월렛 이름 입력

원하는 월렛 이름을 입력 후 저장을 클릭해 월렛 생성을 완료합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fvw9XMPR3l9Uu7a3053n7%2Fwallet-07.png?alt=media&amp;token=27244232-fbdb-4461-b17a-6db21412d9c3" alt=""><figcaption></figcaption></figure>

사업자 월렛으로 생성하는 경우, 아래 기능을 추가로 이용할 수 있습니다.

* 무통장 입금을 통해 유상캐시를 충전할 수 있습니다.
* 세금계산서가 발급됩니다.

### 개인 월렛 생성하기 <a href="#create_individual_wallet" id="create_individual_wallet"></a>

#### Step 1. 내 챗봇 월렛 목록 우측 상단의 새로운 월렛 생성버튼 클릭

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FLDyfC6OAouxZ5gwS2yrc%2Fwallet-personal-step1.png?alt=media&amp;token=302e5a17-1eb6-4da0-a66f-e423d3a0fb58" alt=""><figcaption></figcaption></figure>

#### Step 2. 유형 선택시 '개인 월렛' 선택

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FIMBNx9MAcqNrMf45bL32%2Fwallet-personal-step2.png?alt=media&amp;token=b53600a4-b27e-4886-85ad-1579c7f0f80b" alt=""><figcaption></figcaption></figure>

#### Step 3. 본인 확인

'본인 확인' 버튼 클릭시 챗봇 관리자센터에 로그인한 카카오 계정을 통해 본인 확인이 자동으로 완료됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FvB9saYDdCbtANMsAfMTe%2Fwallet-personal-step3-1.png?alt=media&amp;token=b24ea2f7-0f51-4cdc-ab41-cf442c198278" alt=""><figcaption></figcaption></figure>

개인정보가 올바르게 입력되어 있는지 확인 후 개인정보 수집 및 이용에 동의합니다. 필수로 동의해야 월렛을 생성할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FxXEJwXqUnH0yJXIXmexL%2Fwallet-personal-step3-2.png?alt=media&amp;token=a635e6e4-8022-4eba-927e-aed19ecdbbe8" alt=""><figcaption></figcaption></figure>

#### Step 4. 월렛 이름 입력

원하는 월렛 이름을 입력 후 저장을 클릭해 월렛 생성을 완료합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FwvKabdiVrt0Ndj4K8cIH%2Fwallet-07(2).png?alt=media&amp;token=186fd8c1-3a4e-4c8f-b716-fb7f20338c58" alt=""><figcaption></figcaption></figure>

### 봇과 월렛 연결하기 <a href="#connect_bot_wallet" id="connect_bot_wallet"></a>

Event API 사용시 요금 납부를 위해서 챗봇과 월렛을 필수로 연결해야 합니다.\
월렛은 채널 연결과 마찬가지로 봇 설정 메뉴를 통해 연결할 수 있습니다.

설정 메뉴에 추가된 '지불 정보' 탭에서 월렛을 연결하거나 연결된 월렛 정보를 확인할 수 있습니다.\
생성된 월렛을 연결하는 방법은 아래와 같습니다.

#### Step 1. 월렛 연결하기 버튼 클릭

봇 설정 > 지불 정보 탭에서 '월렛 연결하기' 버튼을 클릭합니다.

월렛 미연결 상태라면 **월렛 작업 권한**을 가진 모든 챗봇 작업자는 본인이 생성한 월렛을 챗봇에 연결할 수 있습니다. 만일, 월렛 작업 권한을 보유하지 않은 작업자는 지불 정보 탭을 확인할 수 없습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FzqpQbUAdcV0UknrGktxb%2Fwallet-bot-step1.png?alt=media&amp;token=0d95f439-cbfc-428c-8659-1e0911b5ee14" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
**Information.**\
'새 월렛 만들기' 버튼을 이용해 나의 월렛 목록을 이동하지 않고도 월렛을 생성할 수 있습니다.
{% endhint %}

#### Step 2. 연결할 월렛 선택

연결하고자 하는 월렛을 선택 후 확인 버튼을 클릭합니다. 이때, '연결 대기중' 상태의 월렛만 챗봇에 연결할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F5bOU4GdscEQi1iMPEaRs%2Fwallet-bot-step2.png?alt=media&amp;token=a97be1b7-bb21-435e-9aa1-bcef711f0adf" alt=""><figcaption></figcaption></figure>

#### Step 3. 연결된 월렛 정보 확인

월렛 연결이 완료되었다면, 월렛 작업 권한을 보유한 모든 작업자가 지불 정보 탭에서 연결된 월렛 정보를 확인할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fc14bw2zL41cDwclxqfcP%2Fwallet-bot-step3.png?alt=media&amp;token=b1cbeec1-dc97-4d75-8e3c-66916e1dd355" alt=""><figcaption><p>월렛 이름, 캐시 잔액 클릭시 곧바로 상세 화면에 진입할 수 있습니다.</p></figcaption></figure>

'내 챗봇' 목록에서도 봇과 연결된 월렛 정보를 한 눈에 확인할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fajb67E4nEg0yOcBK2TgO%2Fbotsetting.png?alt=media&amp;token=55a8caef-79c0-4212-8e3f-960ed0300373" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
**Information.**\
**1. 월렛 해제**\
챗봇 관리자센터 내 \[설정 > 지불정보] 탭에서 챗봇과 월렛 간 연결을 해제할 수 있습니다.\
\
**2. 월렛 삭제**\
\[월렛 상세 > 기본정보] 탭 하단에 위치한 삭제 버튼을 통해 월렛을 삭제할 수 있습니다.\
\
**1) 삭제 신청 조건**

* 월렛 마스터만 월렛 삭제가 가능합니다.
* 월렛과 챗봇의 연결이 해제된 상태여야 합니다.
* 월렛에 유상캐시 잔액이 없어야 합니다.
* 환불 요청 중인 경우 삭제가 불가합니다. 전액 환불까지는 1일 정도 소요될 수 있습니다.
* 결제 예정 금액이 없어야 하여 미수 상환 후 삭제 가능합니다.
* 발행 예정인 세금계산서가 있다면 발행 후 삭제 가능합니다.(예를 들어 10/15일 매출이 있다면 11월 초 세금계산서 발행됩니다.)<br>

**2) 삭제 신청 후 처리 안내**

* 월렛 삭제 버튼 클릭 시 삭제 대기 상태로 전환되며, 7일 후 완전 삭제 처리 됩니다.
* 삭제 대기 상태에서는 삭제 신청 취소가 가능합니다.
* 7일 후 완전 삭제 처리될 시 복구가 불가합니다.
* 삭제 대기 상태 중에는 월렛 상세 페이지 진입이 불가합니다.
* 사용 중인 자동 결제카드 연결이 해제됩니다.
* 무상캐시는 모두 차감되며, 환불되지 않습니다.
* 7일 후 완전 삭제처리 시 복구가 불가합니다.
  {% endhint %}


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/wallet.md
