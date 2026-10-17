> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/insight.md).

# 인사이트

## 인사이트란? <a href="#insight" id="insight"></a>

인사이트에서는 봇 사용 데이터의 세분화된 측정을 통해 봇에 대한 인사이트를 발견할 수 있습니다. 인사이트 메뉴에 노출되는 데이터는 \[설정 > 카카오톡 채널 연결 > 운영 채널]에 연결된 챗봇에 전송된 데이터를 기준으로 노출됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FUkkVT4grBzwLFMP9KJyE%2Finsight-1.png?alt=media&amp;token=806f3674-560a-4246-88a2-5efa948bae63" alt=""><figcaption><p>인사이트는 좌측 메뉴 탭에서 분석 하위에 있습니다.</p></figcaption></figure>

## 사용자 <a href="#user" id="user"></a>

사용자 메뉴에서 현재일을 기준으로 설정된 기간 동안 설정된 사용자 세그먼트의 사용자 수를 확인할 수 있습니다. 조회 기간은 최대 지난 3년 이내 범위 내에서 최대 90일까지 설정할 수 있습니다.

{% hint style="info" %}
**Information.**

사용자 세그먼트는 특정 기준으로 추출된 사용자 집단입니다. (e.g. ‘남성’ 사용자 세그먼트, ‘여성’ 사용자 세그먼트’, ‘20\~29세’ 사용자 세그먼트)
{% endhint %}

### 사용자 세그먼트 설정 <a href="#setting_user_segment" id="setting_user_segment"></a>

사용자 수를 조회할 사용자 세그먼트를 설정할 수 있습니다. 특정 기준으로 추출되지 않은 ‘전체 사용자’ 세그먼트가 기본으로 설정되어 있고, 최대 3개의 사용자 세그먼트를 추가할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FbIAD8g2pUWfeoZboGEw6%2Finsight-2.png?alt=media&amp;token=a46f06bf-9300-44da-88e6-ee8f0e4bd577" alt=""><figcaption><p>사용자 세그먼트 설정</p></figcaption></figure>

‘세그먼트 추가’ 버튼을 클릭해서 추가할 사용자 세그먼트의 이름과 사용자 집단을 추출할 기준을 설정할 수 있습니다. 사용자 집단을 추출할 기준은 다음과 같습니다.

* 성별 : 카카오톡 회원 정보 기반으로 추정한 사용자의 성별(성별을 추정할 수 없는 사용자가 존재할 수 있습니다.)
* 연령대 : 카카오톡 회원 정보 기반으로 추정한 사용자의 연령대 (연령대를 추정할 수 없는 사용자가 존재할 수 있습니다.)
* 방문 : 봇 생성일 이후 해당 날짜 이전에 사용자의 방문 여부
* 웰컴 및 Event 수신 : 해당 날짜에 웰컴 및 Event 수신만 하고 발화하지 않은 사용자를 제외
* 블록 호출 : 해당 날짜에 특정 블록을 호출한 사용자를 포함 (기준이 되는 블록을 설정해야 합니다.)

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fjsf2PqkaIdWxuTnsHx6Z%2Finsight-3.png?alt=media&amp;token=77423bba-3b02-4ca1-b0e5-905666f33fe6" alt=""><figcaption><p>사용자 세그먼트 추가</p></figcaption></figure>

{% hint style="info" %}
**Information.**

* 추가된 사용자 세그먼트의 ‘설정’ 버튼을 클릭해서 해당 사용자 세그먼트의 설정을 편집하거나 ‘제거’ 버튼을 클릭해서 해당 사용자 세그먼트를 제거할 수 있습니다. (기본으로 설정된 ‘전체 사용자’ 세그먼트는 ‘설정’과 ‘제거’를 할 수 없습니다.)
* 추가된 사용자 세그먼트의 ‘다운로드’ 버튼을 클릭해서 해당 사용자 세그먼트의 설정된 기간 동안의 사용자 수 raw data를 CSV 또는 XLSX 형태로 선택해서 다운로드 받을 수 있습니다.
* 추가된 사용자 세그먼트를 저장하는 기능은 현재 제공하고 있지 않습니다.
  {% endhint %}

### 사용자 세그먼트 개요 <a href="#user_segment_outline" id="user_segment_outline"></a>

설정된 모든 사용자 세그먼트의 설정된 기간 동안의 일별 사용자 수를 그래프에서 확인할 수 있습니다.

{% hint style="info" %}
**Information.**

특정 날짜의 사용자 수가 공개 기준치 이하이면 사용자의 개인 정보 보호를 위해 해당 날짜의 사용자 수를 공개하지 않습니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FTz6gyjf2mHuXjntVlAX6%2Finsight-4.png?alt=media&amp;token=6ac8ef5b-de62-475d-971c-209cb654d619" alt=""><figcaption><p>사용자 세그먼트 개요 그래프</p></figcaption></figure>

### 사용자 세그먼트 상세 <a href="#user_segment_detail" id="user_segment_detail"></a>

설정된 사용자 세그먼트 중에서 특정 사용자 세그먼트의 일별 성별 / 연령대별 / 방문 유형별 사용자 수와 비율을 그래프와 도표에서 확인할 수 있습니다.

{% hint style="info" %}
**Information.**

특정 날짜의 사용자 수가 공개 기준치 이하이면 사용자의 개인 정보 보호를 위해 해당 날짜의 사용자 수와 비율을 공개하지 않습니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FDgtkivUxXS9swtIoRL3N%2Finsight-5.png?alt=media&amp;token=153570e1-3c46-4156-a2a6-67530dcf502d" alt=""><figcaption><p>사용자 세그먼트 상세 그래프 및 도표 (사용자 수)</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F1MHdWQcAcdbxbeZdrkZc%2Finsight-6.png?alt=media&amp;token=5920edfd-c696-4a6b-8699-7c6b6ab4334d" alt=""><figcaption><p>사용자 세그먼트 상세 그래프 및 도표 (사용자 비율)</p></figcaption></figure>

## 잔존율 <a href="#retension" id="retension"></a>

잔존율 메뉴에서 잔존율 측정 대상 / 조건 / 방법을 설정하여 특정 기간의 잔존율을 확인할 수 있습니다. 잔존율 조회 기간은 지난 3년 이내 범위 내에서 최대 30일까지 설정할 수 있습니다.

{% hint style="info" %}
**Information.**

**잔존율**은 ‘특정 날짜’에 ‘특정 행동’을 했던 ‘특정 사용자 집단’ 중 이후 ‘특정 시기’에 같은 행동을 다시 한 사용자 비율입니다.

* ‘1월 1일’에 ‘봇을 방문’한 ‘남성 사용자’ 중 ‘1월 4일에’ 다시 ‘봇을 방문’한 사용자 비율
* ‘1월 1일’에 ‘봇을 첫방문’한 ‘여성 사용자’ 중 ‘1월 4일까지 매일 연속으로’ 다시 ‘봇을 방문’한 사용자 비율
* ‘1월 1일’에 ‘봇의 A 블록을 호출’한 ‘20\~29세 사용자’ 중 ‘1월 4일부터 그 이후 한 번이라도’ 다시 ‘봇의 A 블록을 호출’한 사용자 비율

잔존율을 통해서 봇의 사용자들이 얼마나 이탈하지 않고 유지되고 있는지, 즉 사용자의 봇에 대한 충성도 관점으로 봇 사용 행태를 알 수 있습니다. 특히 특정 성별이나 연령대 등의 사용자 집단, 방문 (첫방문) 및 블록 호출 등의 사용자 행동, N-Day 및 Unbounded 등의 잔존율 측정 방법에 대한 다양한 세부 설정으로 잔존율을 측정하여 더욱 세분화된 봇 사용 행태를 알 수 있습니다.
{% endhint %}

### 잔존율 측정 설정 <a href="#setting_retension_measurement" id="setting_retension_measurement"></a>

잔존율 측정 대상 / 조건 / 방법을 설정할 수 있습니다. 잔존율 측정 대상으로 ‘전체 사용자’가, 잔존율 측정 조건으로 ‘방문 & 재방문’이, 잔존율 측정 방법으로 ‘N-Day’가 ‘기본 잔존율’로 설정되어 있고, 최대 3개의 잔존율 측정을 추가할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F9D37nbyYBK6WIlG2seNM%2Finsight-7.png?alt=media&amp;token=e2bccfbb-63ee-4d91-ab9b-0e9aca18a31d" alt=""><figcaption><p>잔존율 측정 설정</p></figcaption></figure>

‘잔존율 측정 추가’ 버튼을 클릭해서 추가할 잔존율 측정의 이름과 잔존율 측정 대상 / 조건 / 방법을 설정할 수 있습니다. 설정된 잔존율 측정 대상 / 조건 / 방법은 잔존율 측정 이름 아래에 표기됩니다. 같은 종류의 설정끼리 문구의 배경 색상이 동일하며, 설정을 변경하면 문구도 연동해서 변경됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FPjgpo6j19cduHPoZjndo%2Finsight-11.png?alt=media&amp;token=ea8ad738-938e-443f-afd7-99a5d0b0bdc9" alt=""><figcaption></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FNDZRx9wuNM1zGTFV1PhK%2Finsight-12.png?alt=media&amp;token=7eae9e6a-546b-4d3d-8ccc-a6b1617a8557" alt=""><figcaption><p>잔존율 측정 추가</p></figcaption></figure>

{% hint style="info" %}
**Information.**

* 추가된 잔존율 측정의 ‘설정’ 버튼을 클릭해서 해당 잔존율 측정의 설정을 편집하거나 ‘제거’ 버튼을 클릭해서 해당 잔존율 측정을 제거할 수 있습니다. (기본으로 설정된 ‘기본 잔존율’ 측정은 ‘설정’과 ‘제거’를 할 수 없습니다.)
* 추가된 잔존율 측정의 ‘다운로드’ 버튼을 클릭해서 해당 잔존율 측정의 설정된 기간 동안의 잔존율 raw data를 CSV 또는 XLSX 형태로 선택해서 다운로드 받을 수 있습니다.
* 추가된 잔존율 측정을 저장하는 기능은 현재 제공하고 있지 않습니다.
  {% endhint %}

잔존율 측정 설정을 하기 위해 각 항목별 정의를 알아보겠습니다. 잔존율 측정 대상 (Day 0 사용자 세그먼트) 정의는 다음과 같습니다.

* 성별 : 잔존율 측정 날짜 기준 (Day 0) 카카오톡 회원 정보 기반으로 추정한 사용자의 성별 (성별을 추정할 수 없는 사용자가 존재할 수 있습니다.)
* 연령대 : 잔존율 측정 날짜 기준 (Day 0) 카카오톡 회원 정보 기반으로 추정한 사용자의 연령대 (연령대를 추정할 수 없는 사용자가 존재할 수 있습니다.)
* 웰컴 및 Event 수신 : 잔존율 측정 날짜 기준 (Day 0) 웰컴 및 Event 수신만 하고 발화하지 않은 사용자를 제외

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FEt53rxtWi15PC35YA35q%2Finsight-11-1.png?alt=media&amp;token=63378e6a-b8c2-4c87-86d2-59f4130fcae8" alt=""><figcaption><p>잔존율 측정 설정 - 측정 대상</p></figcaption></figure>

잔존율 측정 조건 (Day 0 사용자 행동 & Day N 사용자 행동) 정의는 다음과 같습니다.

* 방문 & 재방문 : 잔존율 측정 날짜에 (Day 0) 봇을 방문한 잔존율 측정 대상 사용자 집단 중 이후 특정 시기에 (Day N) 다시 봇을 방문한 사용자를 잔존 사용자로 계산
* 첫방문 & 재방문 : 잔존율 측정 날짜에 (Day 0) 봇을 첫방문한 잔존율 측정 대상 사용자 집단 중 이후 특정 시기에 (Day N) 다시 봇을 방문한 사용자를 잔존 사용자로 계산
* 블록 호출 & 블록 호출 : 잔존율 측정 날짜에 (Day 0) 봇의 특정 블록을 호출한 잔존율 측정 대상 사용자 집단 중 이후 특정 시기에 (Day N) 다시 봇의 동일 블록을 호출한 사용자를 잔존 사용자로 계산

{% hint style="info" %}
**Information.**

* 잔존율 측정 조건의 Day 0 사용자 행동을 ‘방문’ 또는 ‘첫방문’으로 설정하면 Day N 사용자 행동은 ‘재방문’으로, Day 0 사용자 행동을 ‘블록 호출’로 설정하면 Day N 사용자 행동은 ‘블록 호출’로 자동 설정되며, Day N 사용자 행동의 별도 설정은 불가능합니다.
* 잔존율 측정 조건의 Day 0 사용자 행동을 ‘블록 호출’로 설정하면 기준이 되는 블록을 반드시 설정해야 하며, 설정된 블록이 Day N 사용자 행동에 동일하게 자동 설정됩니다. Day N 사용자 행동의 블록 별도 설정은 불가능합니다
  {% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F7i1e0ytSMms5E8s6XPSH%2Finsight-11-2.png?alt=media&amp;token=a702f410-04da-4292-a64c-6daa95851b86" alt=""><figcaption><p>잔존율 측정 설정 - 측정 조건</p></figcaption></figure>

잔존율 측정 방법 (Day N 측정 기준) 정의는 다음과 같습니다.

* N-Day : 잔존율 측정 날짜에 Day 0 사용자 행동을 했던 잔존율 측정 대상 사용자 집단 중 Day N에 Day N 사용자 행동을 한 사용자를 잔존 사용자로 계산
* N-Day (연속) : 잔존율 측정 날짜에 Day 0 사용자 행동을 했던 잔존율 측정 대상 사용자 집단 중 Day N까지 매일 연속으로 Day N 사용자 행동을 한 사용자를 잔존 사용자로 계산
* Unbounded : 잔존율 측정 날짜에 Day 0 사용자 행동을 했던 잔존율 측정 대상 사용자 집단 중 Day N부터 그 이후 한번이라도 Day N 사용자 행동을 한 사용자를 잔존 사용자로 계산

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F5bU03yuZ9HSA0A3EZYg3%2Finsight-11-3.png?alt=media&amp;token=4dbece5a-9c07-4de0-b4e5-b475fc5dda43" alt=""><figcaption><p>잔존율 측정 설정 - 측정 방법</p></figcaption></figure>

이번에는 잔존율 측정 설정에 따라 잔존율을 어떻게 계산하는지 확인하실 수 있게 예시를 보여드리겠습니다. 첫 번째 예시는 다음과 같이 잔존율 측정을 설정했습니다.

* 잔존율 측정 기간 : 1월 1일 \~ 1월 4일 (1월 5일에 측정)
* 잔존율 측정 대상 : 남성 사용자
* 잔존율 측정 조건 : 방문 & 재방문
* 잔존율 측정 방법 : N-Day

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FP6raBUu0FqQ3eEcP7Hh8%2Finsight-8.png?alt=media&amp;token=44b4ee3b-ff21-4dca-ac83-05f50c13c59c" alt=""><figcaption><p>잔존율 계산 방법 첫 번째 예시</p></figcaption></figure>

두 번째 예시는 다음과 같이 잔존율 측정을 설정했습니다.

* 잔존율 측정 기간 : 1월 1일 \~ 1월 4일 (1월 5일에 측정)
* 잔존율 측정 대상 : 여성 사용자
* 잔존율 측정 조건 : 첫방문 & 재방문
* 잔존율 측정 방법 : N-Day (연속)

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FtOvpehKshKyJgADkldGn%2Finsight-9.png?alt=media&amp;token=f424b573-ecdc-4845-be92-23220e2eee3a" alt=""><figcaption><p>잔존율 계산 방법 두 번째 예시</p></figcaption></figure>

세 번째 예시는 다음과 같이 잔존율 측정을 설정했습니다.

* 잔존율 측정 기간 : 1월 1일 \~ 1월 4일 (1월 5일에 측정)
* 잔존율 측정 대상 : 20\~29세 사용자
* 잔존율 측정 조건 : 블록 호출 (블록 A) & 블록 호출 (블록 A)
* 잔존율 측정 방법 : Unbounded

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fa6kiT41nCswMXrjqECrC%2Finsight-10.png?alt=media&amp;token=0500e09d-7d80-407e-99d1-979013d4cf39" alt=""><figcaption><p>잔존율 계산 방법 세 번째 예시</p></figcaption></figure>

### 잔존율 개요 <a href="#retension_outline" id="retension_outline"></a>

설정된 모든 잔존율 측정의 설정된 기간 동안의 합계 잔존율을 그래프에서 확인할 수 있습니다.

{% hint style="info" %}
**Information.**

특정 날짜의 사용자 수가 공개 기준치 이하이면 사용자의 개인 정보 보호를 위해 해당 날짜의 사용자를 제외하고 합계 잔존율을 계산합니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FUndMWKy11r6L8xNBGlmL%2Finsight-13.png?alt=media&amp;token=bbc02b61-18fe-4661-9874-d13f0c65437b" alt=""><figcaption><p>잔존율 개요 그래프</p></figcaption></figure>

### 잔존율 상세 <a href="#retension_detail" id="retension_detail"></a>

설정된 잔존율 측정 중에서 특정 잔존율 측정의 설정된 기간 동안의 합계 및 일별 잔존율을 도표에서 확인할 수 있습니다.

{% hint style="info" %}
**Information.**

특정 날짜의 사용자 수가 공개 기준치 이하이면 사용자의 개인 정보 보호를 위해 해당 날짜의 사용자 수와 잔존율을 공개하지 않으며, 비공개 날짜의 사용자를 제외하고 합계 잔존율을 계산합니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fy7yebhQ2cpUlcCGPkRiv%2Finsight-14.png?alt=media&amp;token=d3017167-2aef-461c-990a-adbf67a82cc7" alt=""><figcaption><p>잔존율 상세 도표</p></figcaption></figure>


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/insight.md
