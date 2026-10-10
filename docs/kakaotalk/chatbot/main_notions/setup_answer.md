> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/setup_answer.md).

# 응답 설정

**응답**은 사용자 발화가 특정 블록에 매칭될 경우 사용자에게 출력되는 답변입니다. 하나의 블록당 최대 3개의 연속된 응답을 노출할 수 있으며, 응답은 사용자의 기기에 따라 다양한 형태로 만들 수 있습니다.

## 응답의 종류 <a href="#response_type" id="response_type"></a>

챗봇 관리자센터에서의 응답은 봇 작업자가 목표로 하는 디바이스에 따라 카카오톡 응답과 카카오미니 응답으로 나누어집니다. **카카오톡** 의 응답 형태는 텍스트형, 이미지형, 카드형, 커머스형, 리스트형 중 원하는 말풍선 타입을 선택할 수 있고, 응답 개수에 따라 각각 기본형, 랜덤형, 케로셀형 등으로 출력할 수 있습니다. **카카오미니**는 텍스트형만 사용할 수 있고 여러 개의 응답을 등록할 경우 랜덤형으로 출력됩니다. 응답을 설정하지 않을 경우 봇에서 패턴발화를 입력하더라도 안읽음 처리됩니다. 만약 스킬을 응답으로 사용하는 경우 스킬데이터를 선택하여 주시고 이외의 경우에는 선택에 맞게 말풍선 응답을 설정하여 주시기 바랍니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FNcQ6Ido4avmSdBCmqm5V%2Fresponse-block-outputs-1-01.png?alt=media&amp;token=2c433457-f29e-4f9e-ae74-c57326deebff" alt=""><figcaption><p>카카오톡의 출력을 설정하는 영역</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FcaaGJfI3bhD7csHSGZm9%2Fresponse-block-outputs-2-01.png?alt=media&amp;token=7505f300-eb2f-4b95-a257-4095c3c53285" alt=""><figcaption><p>카카오 미니의 출력을 설정하는 영역</p></figcaption></figure>

{% hint style="warning" %}
**Definition.**

**말풍선이란?**\
카카오톡에서 사용자 혹은 봇과 주고받는 메시지를 지칭하는 단어입니다.
{% endhint %}

## 봇 응답 꾸미기 <a href="#decorate_bot_response" id="decorate_bot_response"></a>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F4RB9Wr1UOPdSuJ4fYMpz%2Fresponse-intro.png?alt=media&amp;token=05f8e3bb-318e-48c2-8e5e-58468caf7472" alt=""><figcaption></figcaption></figure>

카카오톡 채널 챗봇의 자랑이자 차별화 포인트는 바로 카카오 고유의 유려한 말풍선입니다. 챗봇 관리자센터에선 직접 봇 작업자가 되어 카카오의 모든 말풍선을 입맛에 맞게 구현할 수 있습니다.

어디선가 보았지만 멀리있는 듯 했던 그 화려한 말풍선들… 이제는 텍스트형/이미지형/카드형/커머스형/리스트형 그리고 단일형/가로케로셀/랜덤형 출력케이스도 모두 봇 작업자 여러분의 손끝에 달려있습니다.

더불어, 업계의 가장 핫한 아이템, 작고 귀여운 ‘바로연결(Quick Reply)’ 버튼도 말풍선 아래에 달아보세요. 챗봇 인터페이스가 깔끔해지고, 사용자들은 더욱 간편하게, 재밌게, 빠르게, 여러분의 챗봇을 경험할 수 있게 됩니다.

잘 만든 챗봇은 ‘살아있는 생물’과 같아서 사용자를 부르게 되고, 그에 따라 여러분의 서비스 활성도는 꾸준히 올라갈 것 입니다.

## 말풍선 타입 별 응답 만들기 <a href="#create_response_by_bubbble_type" id="create_response_by_bubbble_type"></a>

### 말풍선 설정하기 <a href="#setting_bubble" id="setting_bubble"></a>

블록 상세화면 하단의 봇 응답형식 설정 영역에서 **응답추가 버튼**을 눌러 말풍선의 타입을 선택합니다. 각 말풍선은 생성한 말풍선들 중 무작위로 하나만 전송되는 랜덤형, 생성한 말풍선들을 모두 사용자에게 보여주는 케로셀형으로 사용할 수 있습니다. 그리고 하나의 블록에서 최대 3개의 연속된 말풍선을 응답으로 설정할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F7rG5FaOb6viEIg8cqjRp%2Fbubble-setting.png?alt=media&amp;token=93dbbaeb-b03c-480c-aaef-d9c0d7231a54" alt=""><figcaption><p>응답 추가 버튼을 눌러 응답 영역 메뉴를 펼친 화면</p></figcaption></figure>

말풍선을 생성하기 위해서 확인해야 하는 상세한 스펙정보는 [**말풍선 제작 스펙 정보**](#bubble_spec_infomation)에서 확인하실 수 있습니다.

### 말풍선 타입 <a href="#bubble_type" id="bubble_type"></a>

* 텍스트형
* 이미지형
* 카드형
* 커머스형
* 리스트형

#### 텍스트형 <a href="#text_type" id="text_type"></a>

* 텍스트 전용 말풍선입니다.
* 필요에 따라 말풍선 안에서 최대 3개의 버튼을 추가하여 기능을 추가할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FWBdYZ2pn0AhHPJl9oBwo%2Fbubble-type-01.png?alt=media&amp;token=999d613f-3a70-4a5b-8780-0f0616f5617f" alt=""><figcaption><p>텍스트형 말풍선</p></figcaption></figure>

#### 이미지형 <a href="#image_type" id="image_type"></a>

* 이미지 전용 말풍선입니다.
* 내 컴퓨터에 저장된 이미지를 올리거나 이미 업로드된 이미지의 URL을 입력할 수 있습니다.
* 노출되는 섬네일 이미지를 클릭할 경우, 봇 작업자는 이미지 뷰어를 통해 올린 원본 이미지를 저장/확대/축소할 수 있습니다.
* 이미지에는 대체텍스트를 추가로 입력할 수 있습니다.

{% hint style="info" %}
**Information.** 이미지형은 등록된 이미지들 중 하나만 전송되는 랜덤형으로만 사용할 수 있습니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F6jn5TxREvCW85oj6bQ1M%2Fbubble-type-02.png?alt=media&amp;token=21d5c491-0333-42b2-adb9-900a217a31d1" alt=""><figcaption><p>이미지형 말풍선 : 랜덤형타입, 1:1비율 타입 / 1:2 비율 타입 / 세로로 긴 이미지의 미리보기 예시</p></figcaption></figure>

#### 카드형 <a href="#card_type" id="card_type"></a>

* 카드형 말풍선은 사용자에게 봇 작업자가 이미지, 이미지 / 텍스트, 이미지 / 텍스트 / 버튼으로 조합하여 구성할 수 있는 말풍선 입니다.
* 각 말풍선 내에서 버튼은 최대한 3개까지 추가할 수 있습니다.
* 이미지에는 대체텍스트를 추가로 입력할 수 있습니다.

{% hint style="info" %}
**Information.**

카드형에서 등록할 이미지는 와이드형과 정사각형 중 선택할 수 있습니다.

* 와이드형 이미지를 설정하면 버튼을 최대 3개까지 등록할 수 있습니다.
* 정사각형 이미지를 설정하면 버튼을 최대 2개까지만 등록가능하고, 버튼은 가로로 배열됩니다.
  {% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FKvceb5B8DFWq8WWMLBjw%2Fbubble-type-03.png?alt=media&amp;token=bf632b56-4032-4d7e-96d2-17153a6b3fb6" alt=""><figcaption><p>카드형 말풍선 : 와이드형 이미지 타입</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FKd80Jn8ZqmJb2kgn6MRC%2Fbubble-type-03(2).png?alt=media&amp;token=fcb7b9ad-3e23-40ca-a486-82b64367f373" alt=""><figcaption><p>카드형 말풍선 : 정사각형 이미지 타입</p></figcaption></figure>

#### 커머스형 <a href="#commerce_type" id="commerce_type"></a>

* 커머스형은 상품의 이미지와 가격정보, 상품명과 같은 사항을 표기해야 할 때 사용하는 말풍선입니다.
* 필요에 따라 버튼을 추가해 각 버튼에 기능을 설정할 수 있습니다.
* **상품 이미지와 가격**을 필수로 입력해야 합니다.
* 상품 가격은 정확한 정보가 중요하므로 가격 설정에서 할인이 적용될 경우 **할인금액/할인율** 중 하나를 선택하여 할인정보를 입력해야 합니다.
* 할인 계산 과정에서 소수점 이하 가격은 반올림 처리됩니다.
* 이미지에는 대체텍스트를 추가로 입력할 수 있습니다.

{% hint style="info" %}
**Information.**

커머스형 말풍선은 랜덤형으로 노출할 수 없습니다. 카드형 말풍선과 마찬가지로, 등록할 이미지는 와이드형과 정사각형 중 선택할 수 있습니다.

* 와이드형 이미지를 설정하면 버튼을 최대 3개까지 등록할 수 있습니다.
* 정사각형 이미지를 설정하면 버튼을 최대 2개까지만 등록가능하고, 버튼은 가로로 배열됩니다.
  {% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F18r7yElyi1nW1PNz4qam%2Fbubble-type-04.png?alt=media&amp;token=20d998e9-3882-41ac-8ab0-831adcedd783" alt=""><figcaption><p>커머스형 말풍선 : 와이드형 이미지 타입</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fn3R7EqMESYUm2xDoiwUo%2Fbubble-type-04(2).png?alt=media&amp;token=9d7632a5-c6a8-4348-9c3f-cf6dd9e20179" alt=""><figcaption><p>커머스형 말풍선 : 정사각형 이미지 타입</p></figcaption></figure>

#### **리스트형** <a href="#list_type" id="list_type"></a>

* 리스트형은 목록형태로 노출할 때 사용하는 말풍선입니다.
* 상단부터 헤더와 목록, 버튼 순으로 구성되어 있습니다.
* 목록은 **최소 1개**에서 최대 5개까지 설정할 수 있고, 각 목록의 대표 문구를 필수로 설정해야 합니다.
* 노출되는 목록을 사용자가 클릭 했을 경우 실행되는 기능을 Web 링크/블록 연결/메시지 전송 중에서 설정할 수 있습니다.
* 목록의 기능을 블록 연결이나 메시지 전송으로 설정한 경우, 추가 정보를 입력할 수 있습니다.
* 연결되는 블록에 스킬이 연결되어 있는 경우, 추가 정보에 입력한 값이 스킬 서버에 추가적으로 제공됩니다.
* 연결된 스킬 payload의 clientExtra 필드에서 해당 값을 확인할 수 있습니다.
* 버튼은 가로로 노출되며 최대 2개까지 설정할 수 있습니다.

{% hint style="info" %}
**Information.**\
리스트형 말풍선은 하나의 말풍선만 노출할 수 있습니다.
{% endhint %}

{% hint style="success" %}
**Tip.**

추가 정보에 입력한 값의 활용 예시 : 사용자 직접 입력 발화와 목록 클릭을 통해 발송되는 메시지(발화)가 동일한 경우, clientExtra 필드 내 값이 포함되어 있는지 여부를 확인하는 방법으로 구분할 수 있습니다.

* clientExtra 필드에 값 포함 : 목록 클릭을 통한 발화
* clientExtra 필드에 값 포함되지 않음 : 사용자 직접 입력 발화
  {% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FPCjBcLEIJNzD9Z09Iajf%2Fbubble-type-05.png?alt=media&amp;token=da0fc47b-42f1-48c4-95f9-9d0406340b83" alt=""><figcaption><p>리스트형 말풍선</p></figcaption></figure>

#### **스킬데이터로 활용** <a href="#apply_skill_data" id="apply_skill_data"></a>

각 말풍선의 응답은 스킬데이터를 활용하여 구성할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FJKIlXTEptaFyTCIoH6q2%2Fbubble-type-06.png?alt=media&amp;token=d135ba52-d0e5-4550-95a2-f61bdd7af5d3" alt=""><figcaption><p>파라미터 우측 상단의 스킬 및 버전 설정 셀렉트 박스</p></figcaption></figure>

스킬을 활용한 응답설정은 아래 페이지에서 상세하게 확인할 수 있습니다.

* [**SimpleText**](/main/tool/chatbot/skill_guide/answer_json_format.md#simpletext)
* [**SimpleImage**](/main/tool/chatbot/skill_guide/answer_json_format.md#simpleimage)
* [**TextCard**](/main/tool/chatbot/skill_guide/answer_json_format.md#textcard)
* [**BasicCard**](/main/tool/chatbot/skill_guide/answer_json_format.md#basiccard)
* [**CommerceCard**](/main/tool/chatbot/skill_guide/answer_json_format.md#commercecard)
* [**ListCard**](/main/tool/chatbot/skill_guide/answer_json_format.md#listcard)
* [**ItemCard**](/main/tool/chatbot/skill_guide/answer_json_format.md#itemcard)

### 말풍선별 출력 방식 <a href="#by_bubble_output_method" id="by_bubble_output_method"></a>

응답 말풍선을 선택하면 랜덤형/케로셀형 중 하나를 선택하여 출력 방식을 설정할 수 있습니다.

#### 랜덤형 <a href="#random_type" id="random_type"></a>

* 랜덤형은 생성한 말풍선들 중 하나의 말풍선만 무작위로 전송됩니다.
* 커머스형 및 리스트형 타입은 랜덤형을 사용할 수 없습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FZ0gJgDKtoYz1B1MOcuYN%2Fbubble-output-01.png?alt=media&amp;token=6925c06a-9db8-413e-ae4d-ea6db94df1c9" alt=""><figcaption><p>이미지형 말풍선 : 랜덤형을 적용했을 때</p></figcaption></figure>

#### 케로셀형 <a href="#carousel_type" id="carousel_type"></a>

* 케로셀형은 생성한 모든 말풍선을 사용자에게 보여줍니다.
* 사용자는 화면을 좌우로 밀어 모든 말풍선을 확인할 수 있습니다.
* 이미지형 및 리스트형 타입은 케로셀형을 사용할 수 없습니다.
* 케로셀형은 최대 10개까지 생성할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FRJyE0BBkig1Jnl8T34Rb%2Fbubble-output-02.png?alt=media&amp;token=a92269b6-c83b-432d-8b3a-fd84eda00851" alt=""><figcaption><p>커머스형 말풍선 : 케로셀형을 적용했을 때</p></figcaption></figure>

#### 케로셀헤드 설정 <a href="#setting_carousel_head" id="setting_carousel_head"></a>

* 케로셀형으로 설정할 경우 케로셀 말풍선의 가장 앞에 케로셀헤드 말풍선을 설정할 수 있습니다.
* 케로셀헤드는 등록된 말풍선에 2장 이상일 때만 사용가능하며 위치를 변경하거나 복사할 수 없습니다.
* 케로셀헤드의 전체 높이는 뒤에 등록된 말풍선에서 가장 긴 높이에 맞추어집니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F7J08nXJMGBLV4N9FvaE8%2Fcarouselheader.png?alt=media&amp;token=430fd714-f666-4cd6-a177-08f6b4111beb" alt=""><figcaption><p>케로셀헤드는 카드형, 커머스타입 말풍선을 설정하신 후 케로셀형을 사용할 때 사용하실 수 있습니다.</p></figcaption></figure>

#### 전달하기 설정 <a href="#setting_deliver_function" id="setting_deliver_function"></a>

* 말풍선을 전송할 때 전달하기 아이콘을 노출할지 설정할 수 있습니다.
* 전달가능 옵션은 출력이 단일형일 때 버튼이 없거나 버튼 기능 중 카카오톡 채널 포스트, 카카오톡 채널 쿠폰, 공유하기 플러그인이 포함된 경우에만 설정가능 합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FkD1nGFQ9EYCA2d6qczsw%2Fbubble-output-04.png?alt=media&amp;token=e6634149-6de6-43bf-acce-efcc7794a596" alt=""><figcaption><p>단일형 출력에서 버튼이 없을 경우 전달가능 옵션을 활성화 할 수 있습니다.</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FZZQxArB22Wg1sU5RqBBu%2Fbubble-output-05.webp?alt=media&amp;token=add885f4-745c-4474-8a89-9ca414090114" alt=""><figcaption></figcaption></figure>

### 버튼 기능 설정 <a href="#setting_button_function" id="setting_button_function"></a>

* 말풍선에 버튼을 추가할 경우 아래와 같은 기능을 사용할 수 있습니다.
* 말풍선 버튼에 들어가는 링크 타입은 webUrl 이며 http/ https 형식만 삽입 가능합니다.
* http의 경우 리다이렉트 되며 오랜딩이 발생하는 경우 https로 사용하시기 바랍니다.&#x20;

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fm7UwtV5ETHMuIjatoaAj%2Fbubble-func-01.png?alt=media&amp;token=8bd1c860-959c-4a7a-953b-9f6a980888c4" alt=""><figcaption><p>커머스형 말풍선의 버튼을 설정할 때 버튼의 기능을 설정하는 화면</p></figcaption></figure>

**블록연결**

* 사전에 만들어진 블록들이 노출되고 선택할 수 있습니다. 연결된 블록은 버튼 선택시 바로 실행이 됩니다.
* 연결되는 블록에 스킬이 연결되어 있는 경우, 추가 정보에 입력한 값이 스킬 서버에 추가적으로 제공됩니다.
* 연결된 스킬 payload의 clientExtra 필드에서 해당 값을 확인할 수 있습니다.

{% hint style="success" %}
**Tip.**

추가 정보에 입력한 값의 활용 예시 : 사용자 직접 입력 발화와 버튼 클릭을 통해 발송되는 메시지(발화)가 동일한 경우, clientExtra 필드 내 값이 포함되어 있는지 여부를 확인하는 방법으로 구분할 수 있습니다.

* clientExtra 필드에 값 포함 : 버튼 클릭을 통한 발화
* clientExtra 필드에 값 포함되지 않음 : 사용자 직접 입력 발화
  {% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FNXuR1hhvSglmrUhqNebT%2Fbubble-func-02_new.webp?alt=media&amp;token=46f5a888-dff8-4e4c-99ca-d36076fceaa0" alt=""><figcaption><p>버튼을 설정할 때 버튼기능 중 블록연결하는 화면</p></figcaption></figure>

**URL링크**

* 버튼 선택시 연결되는 URL 링크를 설정합니다.
* 설정한 URL 링크는 카카오톡 내 ‘인앱 브라우저’로 실행 됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F5VKs50JnW04uMpMM8e4D%2Fbubble-func-03.png?alt=media&amp;token=b1ef5649-8c2d-4cae-a47c-983d83fdbd04" alt=""><figcaption><p>버튼을 설정할 때 버튼기능 중 버튼을 클릭하면 연결할 URL을 입력하는 화면</p></figcaption></figure>

**전화**

* 해당 말풍선에서 연결되는 전화번호를 설정합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F52FmXrCALCxyxKLob1Km%2Fbubble-func-04.png?alt=media&amp;token=183208f8-1338-4845-ac2c-f3ca7f670015" alt=""><figcaption><p>버튼을 설정할 때 버튼기능 중 전화번호를 입력하는 화면</p></figcaption></figure>

**메시지 전송**

* 버튼 선택시 사용자 발화로 입력될 메시지를 설정합니다.
* 연결되는 블록에 스킬이 연결되어 있는 경우, 추가 정보에 입력한 값이 스킬 서버에 추가적으로 제공됩니다.
* 연결된 스킬 payload의 clientExtra 필드에서 해당 값을 확인할 수 있습니다.

{% hint style="success" %}
**Tip.**

추가 정보에 입력한 값의 활용 예시 : 사용자 직접 입력 발화와 버튼 클릭을 통해 발송되는 메시지(발화)가 동일한 경우, clientExtra 필드 내 값이 포함되어 있는지 여부를 확인하는 방법으로 구분할 수 있습니다.

* clientExtra 필드에 값 포함 : 버튼 클릭을 통한 발화
* clientExtra 필드에 값 포함되지 않음 : 사용자 직접 입력 발화
  {% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FW5K8HEPF7A6VpW8vA3hn%2Fbubble-func-05_new.png?alt=media&amp;token=1c4f8467-8dd8-4a09-87b2-b13f42f783b2" alt=""><figcaption><p>버튼을 설정할 때 버튼기능 중 버튼을 눌렀을 때 전송될 발화를 입력하는 화면</p></figcaption></figure>

**플러그인**

* 버튼 선택시 사용할 수 있는 플러그인을 설정합니다.
* 사용할 수 있는 플러그인 설명은 [**주요개념 > 플러그인**](/main/tool/chatbot/main_notions/plugin.md)에서 자세히 확인할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fms9FnRTaPT4v7WHvw0f2%2Fbubble-func-06.png?alt=media&amp;token=d905aaf7-964b-4414-a685-bd43f937915e" alt=""><figcaption><p>버튼을 설정할 때 버튼기능 중 응답에서 설정할 수 있는 플러그인 목록 화면</p></figcaption></figure>

## 바로연결 응답 만들기 <a href="#make_quickreply" id="make_quickreply"></a>

### 바로연결 응답이란? <a href="#quickreply" id="quickreply"></a>

바로연결이란 봇 디자이너의 자산 간 연결을 지원하는 기능입니다. 서로 다른 블록의 연결과 동일한 블록 내 엔트리들을 유저에게 노출하여 해당 봇의 다른 자산으로 쉽게 이동할 수 있도록 유도할 수 있습니다.

바로연결은 출력 영역의 가장 하단에 제공됩니다. 각 출력마다 바로연결을 제공할 수 없으며 한 블록에 하나의 바로연결만 설정 할 수 있습니다. 설정된 바로연결은 챗봇에서 발송되는 말풍선의 가장 하단에 노란색 타원형 버튼으로 제공됩니다. 버튼 당 최대 글자 수는 14글자, 최대 제공 버튼 개수는 10개입니다. 챗봇에서 바로연결 버튼을 클릭하면 메시지 형태로 발송되며, 바로연결 내에서 설정된 다음 액션을 연달아 수행합니다.

### 바로연결 설정 방법 <a href="#setting_quickreply" id="setting_quickreply"></a>

#### 엔티티 적용 방식 <a href="#entity_application_method" id="entity_application_method"></a>

{% hint style="success" %}
**Tip.**

* 나의 엔티티만 설정 가능하며 시스템 엔티티는 설정할 수 없습니다.
* 선택한 엔티티의 엔트리가 노출됩니다.
* 엔트리 목록 중 최대 10개의 엔트리를 선택할 수 있습니다.
* 전체 엔트리 목록에서 클릭으로 on/off 할 수 있습니다.
* 선택 엔트리 목록에서 드래그로 순서를 조정할 수 있습니다.
* 메시지를 입력하지 않으면 엔트리 선택 시 선택된 엔트리만 발화으로 전송됩니다.
* 메시지를 입력하면 엔트리 + 설정된 메시지로 발화가 전송됩니다.
* 14글자가 넘는 엔트리는 제외됩니다.
  {% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F7sQmZK35giSUCF76e5gV%2Fquickreply-01.png?alt=media&amp;token=d2c3ed00-4268-44b8-8345-632a8b8dd97f" alt=""><figcaption><p>바로연결 엔티티 적용 방식 설정 예시</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FryuMnTGeSxeiLH1wBCUc%2Fquickreply-02.png?alt=media&amp;token=d19ac2d3-68f0-49c4-ae84-895a1a6b5db5" alt=""><figcaption><p>바로 연결 엔티티 적용 완료 예시</p></figcaption></figure>

#### 블록 연결 방식 <a href="#block_connect_method" id="block_connect_method"></a>

{% hint style="success" %}
**Tip.**

* 버튼명의 경우 유저가 보는 바로연결의 버튼명과 버튼을 클릭 했을 때 발송되는 메시지가 동일합니다.
* 버튼 기능 설정은 특정 블록의 출력을 바로 호출하는 기능입니다.
* 버튼 기능을 설정하면 버튼 명에 상관없이 설정 한 블록의 출력을 호출합니다.
* 연결되는 블록에 스킬이 연결되어 있는 경우, 추가 정보에 입력한 값이 스킬 서버에 추가적으로 제공됩니다.\
  연결된 스킬 payload의 clientExtra 필드에서 해당 값을 확인할 수 있습니다.
* 추가 정보에 입력한 값의 활용 예시 : 사용자 직접 입력 발화와 버튼 클릭을 통해 발송되는 메시지(발화)가 동일한 경우, clientExtra 필드 내 값이 포함되어 있는지 여부를 확인하는 방법으로 구분할 수 있습니다.\
  clientExtra 필드에 값 포함 : 버튼 클릭을 통한 발화\
  clientExtra 필드에 값 포함되지 않음 : 사용자 직접 입력 발화
  {% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FesMdWqbBN2O9B5Jiy2WN%2Fquickreply-03_new.png?alt=media&amp;token=1cae6e88-4d89-4f46-8da3-f907f1ba1f20" alt=""><figcaption><p>바로연결 블록 전송 방식 설정 예시</p></figcaption></figure>

#### 발화 전송 방식 <a href="#utterance_transmission_method" id="utterance_transmission_method"></a>

{% hint style="success" %}
**Tip.**

* 버튼명과 전송할 메시지를 다르게 설정할 수 있습니다.
* 버튼명 클릭 시 설정된 메시지가 발송됩니다.
* 설정된 메시지가 발화로 등록되어 있지 않다면, 클릭 시 폴백 메시지를 받게 됩니다.
* 연결되는 블록에 스킬이 연결되어 있는 경우, 추가 정보에 입력한 값이 스킬 서버에 추가적으로 제공됩니다.\
  연결된 스킬 payload의 clientExtra 필드에서 해당 값을 확인할 수 있습니다.
* 추가 정보에 입력한 값의 활용 예시 : 사용자 직접 입력 발화와 버튼 클릭을 통해 발송되는 메시지(발화)가 동일한 경우, clientExtra 필드 내 값이 포함되어 있는지 여부를 확인하는 방법으로 구분할 수 있습니다.\
  clientExtra 필드에 값 포함 : 버튼 클릭을 통한 발화\
  clientExtra 필드에 값 포함되지 않음 : 사용자 직접 입력 발화
  {% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FRVtxfRGvhIIe9HMErR1x%2Fquickreply-04_new.png?alt=media&amp;token=242bf057-1d5f-4600-a949-72683859a82f" alt=""><figcaption><p>바로연결 발화 전송 방식 설정 예시</p></figcaption></figure>

## 대체 텍스트 입력하기 <a href="#alt-text" id="alt-text"></a>

### 대체텍스트 이해하기 <a href="#understand_alttext" id="understand_alttext"></a>

시각장애인 등 웹/앱 정보 접근 취약 계층의 이해도를 높이기 위해 시각적 이미지를 설명하는 문구입니다. \
스크린 리더 기능(VoiceOver, TalkBack)을 통해 입력된 문구가 소리로 표현됩니다.

챗봇의 이미지에 대체텍스트를 입력하면, 스크린 리더 기능이 활성화된 디바이스에서 카카오톡 말풍선 내 이미지 정보를 음성으로 재생할 수 있게 됩니다.<br>

### 대체텍스트 입력 가이드 <a href="#input_guide_alttext" id="input_guide_alttext"></a>

대체텍스트는 언제 작성해야 할까요? 제작자가 설정한 챗봇 말풍선에서, \
**이미지를 제거하였을 때 정보 전달에 문제가 생긴다면 대체텍스트를 작성해야 합니다.** \
반대로, 이미지가 없어도 이외 텍스트나 맥락을 통해 정보가 충분히 전달된다면 대체텍스트를 작성하지 않습니다.

대체텍스트를 작성해야 하는 경우, 아래 원칙을 준수하면 좋습니다.

1. **이미지의 정보와 동등한 내용을 제공합니다.**\
   이미지가 전달하는 정보를 대체텍스트로 동일하게 전달할 수 있도록 작성합니다.<br>
2. **간결하면서도 핵심 내용을 명확하게 전달합니다.**\
   입력된 대체텍스트는 음성으로 재생되는 점을 명심해 주세요. 불필요한 단어를 포함하지 않고, \
   가장 중요한 내용을 첫 부분에 배치합니다.<br>
3. **이미지의 맥락을 고려해 중복 설명을 피합니다.**\
   이미지 내 정보 중 일부가 이미 말풍선 내 텍스트로 제공된다면, 중복되는 내용은 대체텍스트로 입력하지 말아 주세요.

다음은 챗봇 말풍선으로 입력 가능한 대체텍스트 정보입니다.

<table><thead><tr><th width="187">구분</th><th width="334">지원 응답 종류</th><th>비고</th></tr></thead><tbody><tr><td>챗봇 관리자센터</td><td>이미지형, 카드형, 커머스형</td><td>최대 50자</td></tr><tr><td>스킬 서버</td><td>SimpleImage, BasicCard, CommerceCard, ItemCard</td><td>altText 필드, 최대 50자</td></tr></tbody></table>

{% hint style="info" %}
**Information.**

챗봇 관리자센터의 봇테스트 영역에는 대체텍스트를 입력하여도 기능이 활성화되지 않습니다.
{% endhint %}

## 응답 사이즈 <a href="#bubble_size" id="bubble_size"></a>

챗봇 관리자센터 내에서 설정한 응답, 또는 스킬 서버에서 설정한 응답의 사이즈(bytes)입니다.

\
**응답의 정확한 사이즈는 챗봇 관리자센터의** [**봇테스트**](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/bot_test#bot_test)**를 통해 확인할 수 있습니다.**

(스킬 응답의 경우, 사용자가 입력한 JSON 사이즈와 실제 발송되는 응답의 사이즈가 상이할 수 있습니다.)

\
각각의 응답 사이즈가 **30,720 bytes**를 넘으면 사용자에게 발송되지 않으므로, 배포 이전에 반드시 점검해 주시기 바랍니다.

### 응답 사이즈 이해하기 <a href="#understand_bubble_size" id="understand_bubble_size"></a>

응답 사이즈는 다음과 같은 상황에서 늘어나게 됩니다.

* **사용자가 직접 입력한 정보의 양이 절대적으로 많은 경우**

사용자가 직접 입력한 정보의 양이 절대적으로 많은 경우, 응답 사이즈도 자연스레 증가합니다.\
특히 리스트형 응답이나 아이템형 응답의 경우 많은 정보를 수용할 수 있기 때문에 주의가 필요합니다.

예를 들어 아래의 **리스트형 케로셀**은 5개의 카드를 포함합니다. 또한 리스트 목록(Listitem)마다, 클릭 시 이동이 가능한 ‘OS별 링크’가 입력되어 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fy4PSDnXpw2Y3OYHAFKrg%2Ftest-size.png?alt=media&amp;token=ab0da3eb-0c49-4d8f-8323-98acf9e1a7a3" alt=""><figcaption></figcaption></figure>

이러한 경우 응답 사이즈가 약 20,000 bytes까지 증가하게 됩니다.

* **‘메시지 전송(action:message)’이나 ‘블록 연결(action:block)’을 과도하게 사용하는 경우**

현재 챗봇에서는 리스트 목록이나 버튼을 통해 **메시지 전송 기능**과 **블록 연결 기능**을 사용할 수 있습니다.\
(스킬의 경우, [**Listitem**](broken://pages/G6rabZHmJaguW7pzZm13#listitem_field_details)이나 [**Button**](broken://pages/G6rabZHmJaguW7pzZm13#button) 에서 action: `message`/ `block`으로 사용)

이 기능을 사용하면, 내부 처리 방식에 의해 해당 리스트 목록이나 버튼의 사이즈가 사용자가 입력한 값보다 훨씬 커지게 됩니다.

예를 들어 아래의 텍스트형 케로셀은 모든 버튼에 메시지 전송과 블록 연결 기능을 포함하고 있습니다.\
(카드당 버튼 3개 X 카드 10장)

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FokGTJIUBIYH6NpjztYa8%2Ftest-size2.png?alt=media&amp;token=a2be7ce6-9461-4db4-9266-a0a2468ec7af" alt=""><figcaption></figcaption></figure>

이러한 경우 응답 사이즈가 약 37,000 bytes까지 증가하게 됩니다.

사용자가 직접 입력한 정보의 양은 적지만 실제 응답 사이즈는 훨씬 늘어나는 경우로, 각별한 주의가 필요합니다.

{% hint style="info" %}
**Information.**

한 번에 2개 또는 3개의 말풍선이 설정된 경우, 응답 사이즈는 각각의 말풍선에 대해 계산됩니다.

![](https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FK0mlZlvg77d1gWQBcgUI%2Ftest-size3.png?alt=media\&token=d6cbf7fb-03f2-43ab-875c-d114cc807078)
{% endhint %}

### 응답 사이즈 줄이기 <a href="#reduce_bubble_size" id="reduce_bubble_size"></a>

다음과 같은 방법으로 응답 사이즈를 줄일 수 있습니다.

* **한 말풍선 안에서 사용하는 메시지 전송(action:message) & 블록 연결(action:block) 기능의 총 개수를 줄여서 발송할 수 있습니다.**

응답 사이즈가 초과된 경우, 한 말풍선 안에서 사용하는 메시지 전송 / 블록 연결 기능을 덜어냄으로써 전체 응답 사이즈를 줄일 수 있습니다.

앞선 텍스트형 케로셀 예시에서 모든 버튼에 메시지 전송 및 블록 연결 기능을 사용한 결과 (도합 30개) 약 37,000 bytes가 되었습니다.

이 응답을 아래처럼 한 말풍선당 메시지 전송 / 블록 연결 기능을 2개씩만 사용하도록 수정할 수 있습니다.\
(도합 20개) 이 경우 전체 응답 사이즈는 약 26,000 bytes로 줄어들게 됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FZqKl08R3Jx2sohLfynpo%2Ftest-size4.png?alt=media&amp;token=e63c65a4-63c1-4161-9f9c-410262260c83" alt=""><figcaption></figcaption></figure>

* **특정 필드의 사이즈를 줄이거나, 케로셀을 사용하는 경우 한 말풍선 내 카드 개수를 줄여 발송할 수 있습니다.**

사용자가 직접 입력한 정보의 양이 많아 응답 사이즈가 초과되었다면

1. 많은 정보를 수용하는 일부 필드의 내용을 덜어낼 수 있습니다: 리스트 목록(ListItem), 타이틀/디스크립션, 링크(Link), 추가 정보(extra) 등의 필드.
2. 케로셀 내 카드의 개수를 줄일 수 있습니다.

* **하나의 말풍선을 두 개 또는 세 개로 나누어 발송할 수 있습니다.**

한 번에 2개 또는 3개의 말풍선이 설정되어 있더라도, 응답 사이즈는 각각의 말풍선에 대해 계산됩니다.

따라서 앞의 가이드대로 내용을 줄일 수 없는 경우라면, 한 말풍선을 두 개의 말풍선으로 나누어 발송할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F71HcssSeNHSfo7KjnT6d%2Ftest-size5.png?alt=media&amp;token=f10a08f0-78cc-4991-bd21-5e2ee23c4d1a" alt=""><figcaption></figcaption></figure>

### 응답 사이즈 정보 확인하기 <a href="#check_bubble_size_info" id="check_bubble_size_info"></a>

응답 사이즈 정보를 확인할 수 있는 방법은 크게 두 가지가 있습니다.

#### **1. 봇테스트** <a href="#bot_test" id="bot_test"></a>

챗봇 관리자센터에서 챗봇을 제작하거나 수정할 때, 봇테스트를 통해 응답의 사이즈 초과 여부를 확인할 수 있습니다. 봇테스트 기능에 대한 자세한 설명은 [봇테스트 > 제공 정보](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/bot_test#provided_information) 페이지를 참고해 주시기 바랍니다.

봇테스트에서는 챗봇 관리자센터에서 설정한 응답의 사이즈 정보와, 스킬로 설정한 응답의 사이즈 정보를 모두 확인할 수 있습니다.

응답 사이즈는 byte 단위로 표기됩니다.\
하나의 응답에 2개 또는 3개 말풍선이 설정된 경우, 각각의 말풍선을 클릭하여 응답 사이즈를 확인할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FEus6gL0RTF8ycGkHlsV2%2Ftest-size6.png?alt=media&amp;token=3681d63b-32bd-4460-b32f-312135972f44" alt=""><figcaption></figcaption></figure>

설정한 응답의 사이즈가 30,720 bytes를 넘어간다면 봇테스트에 아래와 같은 경고 말풍선이 노출됩니다.

경고 말풍선이 보여졌음에도 추가 수정 없이 챗봇을 배포한다면, 해당 응답은 실제 카카오톡 채팅방에서 정상적으로 발송

되지 않습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F4M49Er5j8riDSYRnJm8L%2Ftest-size7.png?alt=media&amp;token=e5202027-1662-4774-8acd-ff421cc97132" alt=""><figcaption></figcaption></figure>

**2. 블록 저장**

사용자가 챗봇 관리자센터에서 설정한 응답이 기준 사이즈를 초과한 경우, 블록 저장에 실패하며 아래와 같은 팝업이 노출됩니다. &#x20;

단, 스킬 데이터로 응답을 설정한 경우에는 응답이 기준 사이즈를 초과하여도 팝업이 노출되지 않습니다. 이 경우에는 봇테스트를 이용해 주시기 바랍니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FgHfE3uOZT7iQ6dr5LytB%2F%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202024-02-14%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%202.41.09%202.png?alt=media&amp;token=c3ff0afc-657c-4df9-b17b-eff087ce5e74" alt=""><figcaption></figcaption></figure>

#### 3. 스킬 오류 내역 <a href="#skill_error_history" id="skill_error_history"></a>

현재 동작하고 있는 **운영 채널**에서, 응답 사이즈가 초과되어 사용자에게 말풍선이 정상 발송되지 않는 상황이 발생할 수 있습니다.

만일 발송되지 않은 응답이 **스킬**로 설정된 응답이라면 [**오류 내역**](/main/tool/chatbot/skill_guide/check_skill_error_history.md)을 통해 확인할 수 있습니다.\
챗봇 관리자센터의 ‘스킬' > ‘오류 내역’ 페이지에 아래와 같이 오류 내용이 노출됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FXbXc9kJYZlqq2zHyvEOU%2Ftest-size8.png?alt=media&amp;token=370607a4-6eab-45da-8b12-e7656d74adaa" alt=""><figcaption></figcaption></figure>

## 말풍선 제작 스펙 정보 <a href="#bubble_spec_infomation" id="bubble_spec_infomation"></a>

본 스펙 정보는 모바일톡(IOS, Android) 환경에서 공백없는 한글 글자수를 기준으로 작성되었습니다. PC톡(Mac, Window) 환경이나 공백과 이모티콘을 사용한 문구에서는 차이가 발생할 수 있습니다.

<table><thead><tr><th width="144"></th><th>말풍선 타입</th><th>필수입력</th><th>선택입력</th><th>이미지 비율</th></tr></thead><tbody><tr><td>텍스트형</td><td><p>단일 </p><p>랜덤 </p><p>케로셀</p></td><td>텍스트</td><td>버튼</td><td>-</td></tr><tr><td>이미지형</td><td><p>단일 </p><p>랜덤</p></td><td>이미지</td><td>-</td><td>원본 비율대로 Resize</td></tr><tr><td>카드형</td><td><p>단일 </p><p>랜덤 </p><p>케로셀</p></td><td>이미지</td><td><p>타이틀 </p><p>설명 </p><p>이미지링크 </p><p>버튼</p></td><td><p>2:1 </p><p>1:1</p></td></tr><tr><td>커머스형</td><td><p>단일 </p><p>케로셀</p></td><td><p>이미지 </p><p>가격정보</p></td><td><p>이미지링크 </p><p>프로필 정보 </p><p>상품명 </p><p>상품 설명 </p><p>버튼</p></td><td><p>2:1 </p><p>1:1</p></td></tr><tr><td>리스트형</td><td>단일</td><td><p>헤더문구</p><p>리스트 1개 </p><p>(각 타이틀 필수)</p></td><td><p>헤더링크</p><p></p><p>타이틀을 제외한 설정 항목</p></td><td>-</td></tr></tbody></table>

<table><thead><tr><th width="137"></th><th width="181">버튼 수</th><th>최대 텍스트 수</th><th>액션(클릭)</th></tr></thead><tbody><tr><td>텍스트형</td><td>세로배열 최대 3개</td><td><p>단일(랜덤)</p><ul><li>텍스트(버튼X) 1,000자</li><li>텍스트(버튼O) 400자</li><li>버튼 14자       </li></ul><p>케로셀</p><ul><li>텍스트 128자</li><li>버튼 14자                                 </li></ul></td><td></td></tr><tr><td>이미지형</td><td>-</td><td>-</td><td>이미지 뷰어</td></tr><tr><td>카드형</td><td><p>세로배열 최대 3개 </p><p>가로배열 최대 2개</p></td><td><p>단일(랜덤)</p><ul><li>타이틀 50자 </li><li>설명 230자 </li><li>버튼 14자(가로배열 2개 8자)</li></ul></td><td>Web 링크</td></tr><tr><td>카드형</td><td><p>세로배열 최대 3개 </p><p>가로배열 최대 2개</p></td><td><p>케로셀</p><ul><li>타이틀 40자 </li><li>설명(타이틀X) 80자 </li><li>설명(타이틀O) 40자 </li><li>버튼 14자(가로배열 2개 8자)</li></ul></td><td>Web 링크</td></tr><tr><td>커머스형</td><td><p>세로배열 최대 3개 </p><p>가로배열 최대 2개</p></td><td><ul><li>프로필 타이틀 15자 </li><li>상품명 30자 </li><li>상품 설명 40자 </li><li>버튼 14자(가로배열 2개 8자)</li></ul></td><td>Web 링크</td></tr><tr><td>리스트형</td><td>가로배열 최대 2개</td><td><ul><li>헤더문구 15자 </li><li>타이틀(설명X) 35자 </li><li>타이틀(설명O) 30자 </li><li>설명 16자 </li><li>버튼 14자(가로배열 2개 8자)</li></ul></td><td>Web 링크 블록 연결 메시지 전송</td></tr></tbody></table>

{% hint style="info" %}
**Information.**

카드형과 커머스형 말풍선의 경우, 이미지 타입을 1:1(정사각형)로 변경시 버튼 배열이 가로형 배열로 변경됩니다.
{% endhint %}


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/setup_answer.md
