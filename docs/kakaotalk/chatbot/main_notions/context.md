> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/context.md).

# 컨텍스트

사람과 사람이 대화를 나눌 때를 생각해보면 언제나 특정 문맥적인 상황을 기반으로 이야기하듯이 (예를 들어, ‘날씨’ 등 한 가지 주제로 대화할 때처럼), 사람과 봇 사이에서도 대화를 나눌 때 이와 유사하게 문맥적 상황 공유를 할수 있습니다.

챗봇 관리자센터 안에서는 바로 **컨텍스트(Context)** 라는 기능을 통해서 봇 작업자가, 블록 안에서 직접 해당 컨텍스트를 정의하고, 블록간 연결 및 관리를 수행할 수 있습니다. 컨텍스트가 잘 정의되어 있다면, 봇은 사용자에게 보다 똑똑하고 매끄러운 대화를 경험할 수 있게 해줍니다.

## 컨텍스트를 언제 쓰나요? <a href="#use_context_situation" id="use_context_situation"></a>

컨텍스트는 서로 다른 블록 간 ‘연결고리’를 만들고 싶을 때 씁니다. 이 연결고리가 곧 컨텍스트입니다. 서로 다른 의도를 나타내는 블록들이 하나의 컨텍스트로 묶여서 연결될 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FCe4yOar7GLDjA28yqRrh%2Fcontext-concept.png?alt=media&amp;token=b109529b-16c8-4a1e-882b-b0dbac755510" alt=""><figcaption><p>챗봇 관리자센터에서의 컨텍스트 구조에 대한 도식</p></figcaption></figure>

{% hint style="info" %}
**Information.**

상기 도식처럼, 서로 다른 블록이 연결되기 위해서는 A라는 블록에서 컨텍스트를 내보내기 위한 '아웃풋(Output)' 컨텍스트가 설정되고, B라는 블록에서 컨텍스트를 받기 위한 '인풋(Input)' 컨텍스트가 반드시 설정되어야 합니다.
{% endhint %}

그럼, 컨텍스트를 활용한 아주 간단한 예시를 다음과 같이 들어보겠습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FHBILsH0Edsd0tkMswuNt%2Fcontext-example-01.webp?alt=media&amp;token=8a46e99d-8aee-4074-bb55-b955baa9d410" alt=""><figcaption><p>음료 주문 상황(Context)에서 주문 확정과 취소를 실행하는 블록 구성 예시</p></figcaption></figure>

본 예시에서는 구조적으로 2개의 서로 다른 블록이 존재합니다.

**1번 블록** 음료 주문을 확정하는 기본 블록(블록명 : Order\_confirm)

{% hint style="success" %}
**Example.**

* 패턴 발화 : 아메리카노 1잔
* 음료를 주문하는 대화 상황을 '주문상황(Ordering)'이라는 컨텍스트로 정의하고 내보냄(Output Context)
  {% endhint %}

**2번 블록** 음료를 취소하는 기본 블록 (블록명 : Order\_cancel)

{% hint style="success" %}
**Example.**

* 패턴 발화 : 취소해줘
* 이전 대화의 '주문상황(Ordering)'을 컨텍스트로 받아서 활용(Input Context)
  {% endhint %}

이러한 2개의 다른 블록은 ‘Ordering’이라는 컨텍스트, 즉 ‘문맥’을 서로 공유하는 형태로 챗봇 관리자센터 안에 연결되어 있습니다.

**1번 블록**에 해당하는 사용자 발화가 시작되면, 기 작성된 2개의 블록은 곧바로 ‘Ordering’이라는 컨텍스트를 공유하게 됩니다. (1번 블록이 컨텍스트를 내보내는 경우)\
컨텍스트가 일정 유효 시간(또는 일정 유효 횟수) 동안 유지되면서 대화 중간에 사용자가 봇에게 2번 블록에 해당하는 패턴발화를 말하면, 봇은 주문상황(Ordering) 문맥하에 앞서 실행된 대화안에서의 문맥 정보나 특정 파라미터값을 받아서 2번 블록에서 의도되었던 사용자 응답 메세지를 출력합니다.

본 주문상황(Ordering) 문맥하에 아래처럼 추가적인 3번 블록을 만들어서 수량을 변경하는 액션을 추가할 수도 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F0QRxu6utB1Dx43QWHyje%2Fcontext-example-02.png?alt=media&amp;token=75fd874e-e4b1-4bfb-a3b0-45567bf89768" alt=""><figcaption><p>음료 주문 상황(Context)에서 주문 확정과 수량변경을 실행하는 블록 구성 예시</p></figcaption></figure>

위 예시들의 2번 블록을 이용한 취소, 3번 블록을 이용한 변경에 따른 결과값(response)은 문맥 정보(Ordering)가 있기에 출력이 가능합니다. 만약, 문맥 정보가 내보내지지 않거나 2번, 3번 블록에서 문맥 정보를 받아두지 않았다면 봇은 문맥을 이해하지 못했기 때문에 폴백블록이 출력됩니다.

### 컨텍스트, 이것만 기억해요! <a href="#context_important_content" id="context_important_content"></a>

* 봇 작업자는 블록 정보를 주고받을 수 있습니다. 이때, 하나의 블록에서 다른 블록으로 전달 가능한 정보와 불가한 정보는 아래와 같습니다.

| 전달 가능 상황       | 전달 불가 상황              |
| -------------- | --------------------- |
| 현재 블록의 파라미터 정보 | 현재 블록을 실행시킨 사용자의 발화정보 |

단, 사용자의 발화정보는 스킬서버에서 처리하면 기능 구현이 가능합니다. '스킬서버'에서 응답을 줄 때 유저의 발화정보를 넣어주면 전달할 수 있습니다.

스킬 서버에 대한 자세한 내용은 [**스킬 개발 가이드 > 스킬 서버 이해하기**](/main/tool/chatbot/skill_guide/make_skill.md#understand_skill_server)를 참조하시길 바랍니다.

* 정보를 받는 블록은 연결이 유효할 때만 실행될 수 있습니다. (조건부임)

기본적으로 챗봇 관리자센터를 통해 만든 블록은, 사용자의 발화 또는 이벤트 정보가 블록안의 내용과 매칭되면 실행됩니다. 여기에 컨텍스트 조건을 부여하고 싶다면, 아래와 같이 블록 설정 버튼을 클릭한 후, ‘컨텍스트 설정’ 메뉴로 진입하여 간단하게 필요 구성값을 입력해주시기만 하면 됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FpZIL2h2UFwyN09r0C4iC%2Fcontext-settings-01.png?alt=media&amp;token=c6739e9d-c43d-4a7f-8020-c0fd2517f65b" alt=""><figcaption><p>컨텍스트 설정 메뉴 위치</p></figcaption></figure>

**컨텍스트 메뉴의 3가지 필요 구성값**

* 인풋(Input) 컨텍스트
* 아웃풋(Output) 컨텍스트
* 대화 문맥이 살아있는 '컨텍스트 수명(Lifespan)'과 '유효시간(TTL)'

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fi1FUHOZS3sEZqeVPOoCj%2Fcontext-ttl.png?alt=media&amp;token=68c0d833-dcc5-4ee6-b8c8-e057a7f62ad6" alt=""><figcaption><p>컨텍스트 설정 메뉴내 상세 컨텍스트 조건 설정 화면입니다. – Input 컨텍스트 / Output 컨텍스트 / 컨텍스트 수명 및 유효시간이 나타나 있습니다.</p></figcaption></figure>

## 컨텍스트 사용하기 <a href="#use_context" id="use_context"></a>

챗봇 관리자센터의 고급 기능 중에 하나인 **컨텍스트**를 손쉽게 쓸 수 있도록, 다음과 같이 세 가지 활용 방법을 안내합니다.

### 컨텍스트 조건 설정하기 <a href="#setting_context" id="setting_context"></a>

먼저, 시나리오 > 블록 > 컨텍스트 설정에서 컨텍스트 명칭을 등록합니다. 이때 컨텍스트 명칭 설정 개수에는 제한이 없습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FqQ3jmuMKap46A83S3xbA%2Fcontext-cond-01.png?alt=media&amp;token=5f1aedfb-943f-48ab-a546-f4c24a3eccaa" alt=""><figcaption><p>컨텍스트 설정 선택 팝업 위치</p></figcaption></figure>

다른 블록으로 컨텍스트를 내보낸다면, Output 컨텍스트에 명칭을 등록합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FHp9l1I6KVsuBPltgB1u5%2Fcontext-cond-02.png?alt=media&amp;token=d73bd360-c3f5-4232-90f4-0302fd323718" alt=""><figcaption><p>Output 컨텍스트에 <code>Ordering</code>이라는 컨텍스트 명칭을 등록중인 화면</p></figcaption></figure>

다른 블록에서 내보낸 컨텍스트를 받는다면, Input 컨텍스트에 명칭을 등록합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F8qLf7cimhknGGZNd1PCq%2Fcontext-cond-03.png?alt=media&amp;token=a57c1402-5eeb-4302-a999-8cbe6130889f" alt=""><figcaption></figcaption></figure>

Input 컨텍스트에 `Ordering`이라는 컨텍스트 명칭을 등록중인 화면

\
특히, Output 컨텍스트 부분은 봇 작업자들이 컨텍스트를 생성하여 연결할 때 가장 먼저 설정 작업을 하고, 주요 정보를 등록하는 중요한 공간입니다.\
Output 컨텍스트를 등록할 때는 필수로 다음 세 가지를 입력해야 합니다.

<table><thead><tr><th width="161">컨텍스트 구성 값</th><th width="199">의미</th><th>값</th><th>비고</th></tr></thead><tbody><tr><td>컨텍스트 명칭</td><td>컨텍스트 내용을 설명하는 이름</td><td></td><td></td></tr><tr><td>컨텍스트 수명</td><td>컨텍스트가 지속되는 블록 횟수</td><td>0/1/3/5/10 (회)</td><td>끝나면 컨텍스트가 만료됩니다. 0은 즉시 만료됩니다.(초기화)</td></tr><tr><td>유효시간</td><td>컨텍스트가 지속되는 시간</td><td>1/3/5/10/15/30/60 (분)</td><td>끝나면 컨텍스트가 만료됩니다.</td></tr></tbody></table>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FE5MehQ9N4VBbvuqILWLG%2Fcontext-cond-04.png?alt=media&amp;token=8d2f9948-ec93-42bd-be26-59a10af77013" alt=""><figcaption><p>Output 컨텍스트의 수명 정보 설정 모습</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FTBJIrNp6URg8xP1KrtJv%2Fcontext-cond-05.png?alt=media&amp;token=0e0557d6-ef26-4536-a03c-163c848b8de8" alt=""><figcaption><p>Output 컨텍스트의 유효 시간 정보 설정 모습</p></figcaption></figure>

### 컨텍스트 정보를 스킬 요청(request)에서 활용하기 <a href="#use_context_in_skill_request" id="use_context_in_skill_request"></a>

컨텍스트에 담겨진 정보는 스킬 요청시에도 사용할 수 있습니다. 아래 화면과 같이 블록 안의 파라미터 만들기 메뉴 안에서 ‘값’ 입력란에, 원하는 컨텍스트와 파라미터 명을 다음 형식을 따라 참조할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FSspjNEY2BcI9sz2Tvf1Q%2Fcontext-skill-req-01.png?alt=media&amp;token=ebf205e1-ec2f-49e1-9803-85b5b72152ac" alt=""><figcaption></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FS8rGD45k6s4lbaD0gM0F%2Fcontext-skill-req-02.png?alt=media&amp;token=697a1dc9-059d-430d-a97d-5ffccebc1dc9" alt=""><figcaption><p>파라미터 설정 안에서 파라미터 만들기 메뉴 안의 ‘값’ 설정 부분</p></figcaption></figure>

#### 형식 <a href="#form" id="form"></a>

`#[컨텍스트명].[파라미터명]`

반드시 참조한 컨텍스트를 내보내는(Output) 블록이 존재해야 하며, 설정중인 블록에서 해당 컨텍스트를 받아야(Input) 합니다. 이처럼 블록 간 컨텍스트가 설정되어 있지 않다면, 컨텍스트와 파라미터명을 참조해도 동작하지 않습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FzgdfDJCyqVW9JwIuDFk2%2Fcontext-skill-req-03.png?alt=media&amp;token=2d7153bc-1c3f-4ffa-9b39-165e68c65c84" alt=""><figcaption><p>형식 예시</p></figcaption></figure>

### 컨텍스트 정보를 스킬 응답(response)에서 활용하기 <a href="#use_context_in_skill_response" id="use_context_in_skill_response"></a>

스킬 응답에서 ‘Output 컨텍스트’의 정보를 직접 업데이트 할 수 있습니다. 예를 들어 다음과 같은 스킬 응답 포맷이 있다고 하겠습니다.

* **스킬 응답의 Structure 예시**

```
{
  "version": "2.0",
  "template": {
    ...
  },
  "context": {
    "values": [{
      "name": ...,
      "lifeSpan": ...,
      "params": ...
    },{
      "name": ...,
      "lifeSpan": ...,
      "params": ...
    },
    ...
    ]
  }
}
```

다음처럼,

* 복수의 Output 컨텍스트들 중 특정 컨텍스트만 Output 되도록 변경할 수 있습니다. → `name`
* 컨텍스트의 수명(lifespan)을 변경할 수 있습니다. → `lifeSpan`
* 컨텍스트와 관련해 전달하고 싶은 값을 추가할 수 있습니다. → `params`

스킬 응답의 Output 컨텍스트에 들어있는 내용이 현재 블록의 Output 컨텍스트란에 존재하는 경우에는, 스킬에 들어있는 값으로 현재 Output 컨텍스트를 덮어쓰기합니다.

{% hint style="info" %}
**Information.**

인풋(Input)으로 설정한 컨텍스트가 만료될 경우 해당 블록은 설정된 응답이 아닌 폴백 메시지로 응답하게 됩니다. 폴백 메시지가 설정되어 있지 않으면 빈 말풍선이 나가게 되므로 **기본 시나리오> 폴백블록** 에서 설정 상태를 확인해 주세요.
{% endhint %}

#### **컨텍스트 갱신** <a href="#renew_context" id="renew_context"></a>

스킬 응답으로 컨텍스트를 수정하는 경우, 변경하려는 output 컨텍스트가 미리 블록에서 설정되어야 합니다. 스킬 응답의 context 필드는 값을 수정할 뿐, 새로운 output 컨텍스트를 만들 수는 없습니다.

{% hint style="success" %}
**Example.**

예를 들어 `abc` 라는 output 컨텍스트를 블록에서 생성했다면, 스킬 응답으로 `abc` name을 가지는 context의 lieSpan, params를 수정할 수 있습니다.\
하지만 `def` 라는 output 컨텍스트를 블록에서 생성하지 않은 상황에서, 스킬 응답으로 `def`라는 name을 가지는 context를 수정한다면 이는 반영되지 않습니다.
{% endhint %}

[**응답 타입별 JSON 포맷 > ContextControl**](/main/tool/chatbot/skill_guide/answer_json_format.md#contextcontrol)


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/context.md
