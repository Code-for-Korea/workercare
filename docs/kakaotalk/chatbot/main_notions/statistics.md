> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/statistics.md).

# 통계

## 통계란? <a href="#what_is_statistics" id="what_is_statistics"></a>

통계에서는 제작된 봇의 사용자 활용성을 평가할 수 있는 화면이 제공되고, 이를 통해 관리자는 챗봇 서비스 운영과 관련된 인사이트를 발견할 수 있습니다. 통계메뉴에 노출되는 데이터는 \[설정 > 카카오톡 채널 연결 > 운영 채널] 에 연결된 챗봇에 전송된 데이터를 기준으로 노출합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F8fyzZJSmiB7c4yC5Tcmi%2Fanalysis-dash-1.png?alt=media&amp;token=007d4f70-d17b-4df6-8f78-7b149125e3ce" alt=""><figcaption><p>통계는 좌측 메뉴 탭에서 분석 하위에 있습니다.</p></figcaption></figure>

## 대시보드 <a href="#dashboard" id="dashboard"></a>

대시보드에선 통계에서 제공하는 항목들을 한화면에서 빠르게 확인할 수 있습니다. 상세한 지표는 상세보기 버튼으로 선택한 항목의 데이터를 자세하게 확인할 수 있는 페이지로 연결됩니다. 최대 90일까지 조회기간을 설정할 수 있습니다.

### 블록 호출 수 및 기간별 블록 순위 <a href="#block_calls_and_ranking" id="block_calls_and_ranking"></a>

현재 운영중인 봇에 대해서 가장 많이 사람들이 찾게되는 ‘블록(=사용자의도)’ 순위 정보 및 블록 호출 트렌드를 볼 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FQSmZo872QHEM8jN7HSfj%2Fanalysis-dash-2.png?alt=media&amp;token=5b68450a-ee31-4381-8cd6-bbabfd01a27b" alt=""><figcaption><p>블록 호출 수 그래프 및 기간별 블록순위 차트</p></figcaption></figure>

### 사용자 정보 <a href="#user_infomation" id="user_infomation"></a>

활성중인 현재 봇에 대해서 전체 사용자 유입 트렌드, 신규 방문자 차지 비중 정보를 볼 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FzHyzVrkV1VR0WTcFFcLw%2Fanalysis-dash-3.png?alt=media&amp;token=7389efbd-c64a-4391-80cd-70568be5406a" alt=""><figcaption><p>사용자 정보 그래프</p></figcaption></figure>

### 잔존율 <a href="#retention_rate" id="retention_rate"></a>

신규방문자들에 대해서 첫 봇을 방문한 이후, 얼마나 재방문하는지를 정량적 비율 정보를 볼 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FG7rC6LEv9kqs5nVmKpwF%2Fanalysis-dash-4.png?alt=media&amp;token=79359318-1c96-4142-a7eb-c838de2461a1" alt=""><figcaption><p>재방문율 통계 그래프</p></figcaption></figure>

### 세션 <a href="#session" id="session"></a>

세션의 발생 현황에 대한 트렌드를 확인할 수 있습니다. 세션은 일정한 기간 내에 발생한 사용자 발화의 집합으로 사용자 발화(봇 호출) 후 10분 이상 추가 호출이 없으면 하나의 세션이 종료됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FwvvrhYB8jB4DB9n3hDaM%2Fanalysis-dash-5.png?alt=media&amp;token=c03d0a7d-c172-4a74-8b07-a7d2dff82b82" alt=""><figcaption><p>세션 통계 그래프</p></figcaption></figure>

## 사용자 <a href="#user" id="user"></a>

### 활성사용자 <a href="#active_user" id="active_user"></a>

활성사용자 메뉴에서 현재일을 기준으로 설정된 기간 동안 누적 사용자, 활성 사용자, 재방문 사용자, 신규 사용자 수치를 확인할 수 있습니다.

* 누적 사용자 : 챗봇 생성일로부터 선택일까지 한 번 이상 봇을 호출한 유니크 사용자 수
* 신규방문자 : 해당 기간에 처음 봇을 호출한 사용자
* 활성사용자 : 해당 기간에 한번 이상 봇을 호출한 사용자
* 활성사용자(웰컴 및 Event 수신 제외) : 해당 기간에 한번 이상 봇을 호출한 사용자 중에서 웰컴 및 Event를 통해서 봇의 블록을 호출산 사용자를 제외
* 재방문사용자 : 활성사용자에서 신규사용자를 제외한 수

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F7cM3z5SmF9OXfst5xKKG%2Fanalysis-dash-6.png?alt=media&amp;token=e4350200-8fa4-4f68-9811-e62aa401c681" alt=""><figcaption><p>활성 사용자 현황 그래프 및 도표</p></figcaption></figure>

### 사용자 세션 <a href="#user_session" id="user_session"></a>

'세션'이란 일정한 기간 내에 발생한 사용자 발화의 집합으로 사용자 발화(봇 호출) 후 10분 이상 추가 호출이 없으면 하나의 세션이 종료됩니다. 10분 이후 추가로 봇이 호출되면 다시 새로운 세션이 시작됩니다.

* 전체 세션 수 : 해당일에 발생된 전체 세션
* 사용자당 평균 세션 수 : 전체 세션을 활성사용자 수로 나눈 평균값
* 사용자당 평균 세션 길이 : 해당일의 누적 세션 길이를 활성사용자 수로 나눈 평균값 \[sec]
* 세션당 평균 메시지 수 : 해당일의 누적 메시지 수를 전체 세션수로 나눈 값

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FCnBo8uGDCwTgX9UJJl9S%2Fanalysis-dash-7.png?alt=media&amp;token=e491c210-3c58-4dd5-adba-c6982962d6fa" alt=""><figcaption><p>세션 현황 그래프 및 도표</p></figcaption></figure>

### 잔존율 <a href="#retention_rate" id="retention_rate"></a>

'잔존율'은 특정일의 신규 사용자 및 활성 사용자를 기준으로 해당 사용자들이 계속해서 봇을 호출하고 있는지 확인할 수 있는 지표입니다.

특정일에 들어온 신규사용자수를 Day0의 모수로 잡고, 이후 기간의 누적 잔존율을 계산하여 표기합니다. 예를 들어 Day0에 1,000명의 신규사용자가 들어왔고 Day1의 잔존율이 1%인 경우, Day0의 신규사용자들 중 10명이 다음날에도 봇을 호출했다는 의미입니다. 현재 잔존율 현황 그래프는 최대 30일까지 조회할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FWe6kGnepe3gHDSAb8MYt%2Fanalysis-dash-8.png?alt=media&amp;token=12e5e391-08e4-4d8f-a3d6-31e1f5bd0e29" alt=""><figcaption><p>재방문율 현황 그래프 및 도표</p></figcaption></figure>

## 챗봇 <a href="#chatbot" id="chatbot"></a>

사용자들이 봇에 등록된 블록을 호출한 수와 전체 블록대비 각 블록의 사용비율 데이터를 확인할 수 있습니다. 블록 호출 수 목록은 가장 호출 수가 높은 블록부터 순서대로 노출됩니다.

각 항목을 클릭하면 상세화면 지표가 노출되는 화면으로 이동할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FpVEmTSWAuPMGBguzmEgi%2Fanalysis-dash-9.png?alt=media&amp;token=b81c0bd2-b946-4ae9-8e56-59aa9780d65d" alt=""><figcaption><p>블록 호출 수 목록</p></figcaption></figure>

전체블록 상세화면에선 봇에 호출된 블록의 전체 사용량과 관련된 지표를 확인할 수 있습니다.

* 전체 블록 : 해당 기간동안 호출된 블록의 수
* 전체 블록(웰컴 메시지 제외) : 해당 기간동안 호출된 블록의 수에서 웰컴 블록이 호출된 수를 제외
* Event 메시지 : Event API를 통해서 전송에 성공한 블록 호출 수
* 지식+ : 지식+ 블록 호출수

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FwmuAWvEXlIFLZu6Ub8SI%2Fanalysis-dash-10.png?alt=media&amp;token=163cc837-c153-455c-8f04-82632d42c249" alt=""><figcaption><p>전체 블록 호출 수 그래프 및 도표</p></figcaption></figure>

특정 블록을 선택해서 상세화면으로 이동하면 선택된 블록이 호출된 사용량과 관련된 지표를 확인할 수 있습니다. 블록사용정보에선 블록 호출 수를 일별로 확인할 수 있고 발화매칭 정보에선 선택된 기간동안 블록에 매칭된 발화 목록을 확인할 수 있습니다.

{% hint style="info" %}
**Information.**

* 전화번호와 같은 개인정보를 포함하고 있는 발화는 마스킹처리(\*표기)되어 노출됩니다.
  {% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FwBDENCsJb5s87UACenQ4%2Fanalysis-dash-11.png?alt=media&amp;token=50542692-8cc9-4add-ae49-413126ec1693" alt=""><figcaption><p>전체 블록 호출 수 그래프 및 도표</p></figcaption></figure>

## 보고서 <a href="#report" id="report"></a>

봇에 적재되어 있는 사용자가 호출한 블록 및 사용자 기반의 Raw data를 CSV 또는 XLSX 형태로 선택해서 다운로드 받을 수 있습니다. 최대로 설정가능한 기간은 90일이며, 발화가 포함된 보고서는 하루 단위로만 설정할 수 있습니다.

* 블록별 발화 : 블록을 호출하기 위해 유입된 발화내역, 보고서로 보고 싶은 블록타입을 선택할 수 있습니다.
* 블록 호출 수 : 블록이 호출된 수 (Block usage)
* 사용자 수 : 봇을 방문하여 블록을 호출한 사용자의 수
* 활성채팅방 및 이벤트API 사용량 : 활성채팅방이 개설된 수 및 이벤트API가 호출된 수

### 기준 설정 <a href="#setting_standard" id="setting_standard"></a>

사용자가 호출한 블록을 기준으로 할지 Event를 기반으로 사용자에게 먼저 전송된 메시지를 기준으로 할지 선택할 수 있습니다.

### 발화 빈도 설정 <a href="#setting_utterance_frequency" id="setting_utterance_frequency"></a>

보고서에 담을 블록을 선정할 때, 최소 몇 회이상 호출된 블록을 대상으로 할 것인지를 설정할 수 있습니다.

{% hint style="danger" %}
**Caution.**

보고서로 담을수 있는 데이터의 기간 설정은 1 Day기준으로만 가능합니다. Daily report로만 데이터를 다운로드 받을수 있으니, 필요하신 기간을 옮겨가면서 다운로드 해주시길 바랍니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FDl6kySABeRwyea7mr4tF%2Fanalysis-dash-12.png?alt=media&amp;token=3664fb7d-ef5c-412b-8079-5558c9d70ca2" alt=""><figcaption><p>보고서 페이지</p></figcaption></figure>


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/statistics.md
