> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/apply_skill_to_block.md).

# 블록에 스킬 적용하기

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FmbVSk0tZni0PLBNjDzhL%2Fskill-block-intro.png?alt=media&amp;token=4f3bafdf-b4e8-434e-aa92-6cf3235cab14" alt=""><figcaption></figcaption></figure>

내가 만든 스킬 기능을 챗봇 관리자센터의 블록에 바로 붙여봅시다.

스킬을 정의하고, API URL을 등록한 다음 블록의 파라미터 설정에서 연결하면 끝! 이보다 간편한 외부시스템과의 연결은 없습니다. 스킬 연동과 함께 내가 만든 블록의 기능을 200% 활용해보시기 바랍니다.

이제 더이상 모바일 앱을 개발하지 않아도 ‘봇’만으로 간단한 사용자 응대 서비스를 뚝딱 만들어낼 수 있게 되었습니다.

## 블록과 스킬 연결하기 <a href="#connect_skill_block" id="connect_skill_block"></a>

블록에 스킬을 연결하면 더욱 동적인 응답을 만들어낼 수 있습니다.

아래 화면과 같은 **환율블록**에서 “오늘 달러 환율 얼마야?”와 같은 질문에 실시간으로 변경되는 환율값으로 응답으로 주고 싶다면, 스킬 연결을 통해 구현할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FRaY80WheZNTYrbDEwtOq%2Fskill-block-example-01.png?alt=media&amp;token=1de683d5-e5c1-4aa9-9a08-da9ff665628a" alt=""><figcaption><p>오늘 달러 환율을 응대할 수 있는 간단한 블록 생성</p></figcaption></figure>

오늘의 환율을 얻어오는 **환율스킬**은 있다고 가정하겠습니다. ([<mark style="color:blue;">**스킬 개발 가이드>스킬만들기**</mark>](/main/tool/chatbot/skill_guide/make_skill.md)에서 자세히 확인할 수 있습니다.)

스킬 연결을 하기 위해서는 1) 파라미터 설정을 클릭하여 2) 스킬 선택 목록을 펼친 뒤 미리 등록한 스킬 이름을 선택하시면 됩니다. 스킬을 선택하시면 해당 스킬의 최신 버전이 자동으로 선택됩니다. 다른 버전을 원하시면 버전을 선택하실 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FB7TZx3QeVo02DV8bBSI8%2Fskill-block-example-02%20(1).png?alt=media&amp;token=76f76f05-3818-4740-908a-6264d9ccb5a9" alt=""><figcaption><p>블록에 미리 등록해 둔 환율스킬을 연결</p></figcaption></figure>

이렇게 스킬을 연결되면 블록이 실행될 때 스킬이 작동하게되며, 그것의 결과를 응답형식 설정에서 이용함으로써 더욱 다양한 응답을 생성할 수 있습니다.

스킬의 결과를 응답형식에서 이용하는 방법으로는 웹훅 객체(webhook)를 통한 방법([<mark style="color:blue;">**스킬 개발 가이드 > 응답 설정을 값으로 사용하기**</mark>](#use_response_settings_as_values))과 스킬에서 직접 말풍선을 구성해서 응답하는 방법([<mark style="color:blue;">**스킬 개발 가이드 > 응답 설정을 스킬로 사용하기**</mark>](#use_response_settings_as_skill))이 있습니다.

## 응답설정을 값으로 사용하기 <a href="#use_response_settings_as_values" id="use_response_settings_as_values"></a>

챗봇 관리자센터의 봇 응답형식 설정(말풍선 설정)에서 스킬 서버의 응답값을 텍스트 영역에 사용할 수 있습니다. 기본적으로 {{#webhook.\<json\_path>}}과 같은 형태로 사용합니다. 아래의 과정을 통해 적용 방법을 확인해봅시다.

### Step 1. 스킬 서버에서 응답값 설정

‘Ryan’이라는 유저에 대한 정보가 아래와 같은 값으로 스킬서버에서 응답하도록 설정합니다.

```
{
  "version": "2.0",
  "data": {
    "msg":"HI",
    "name":"Ryan",
    "position":"Senior Managing Director"
  }
}
```

### Step 2. 챗봇 관리자센터에서 응답형식(말풍선) 선택 및 값 입력

챗봇 관리자센터에서 원하는 봇 응답형식을 선택합니다. 스킬 응답값은 말풍선 종류에 상관없이 텍스트를 입력하는 부분에 적용 가능합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FM4u8LrWXJYVQoR7pS4Rw%2Fskill-as-data-example.png?alt=media&amp;token=686f12d9-a2f5-4c61-ae4b-b583b8e09cab" alt=""><figcaption><p>챗봇 관리자센터에서 응답형식을 값으로 입력한 예시</p></figcaption></figure>

### Step 3. 해당 블록을 호출하여 테스트

스킬 응답값이 적용 된 블록의 발화 패턴을 입력하여 결과를 확인해봅니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FNVy6cjzl5qxqao3imXWO%2Fskill-as-data-kakaotalk.webp?alt=media&amp;token=361fadd6-ac37-4527-9098-61abf0036e64" alt=""><figcaption><p>응답설정을 값으로 설정한 출력 화면 예시</p></figcaption></figure>

* List 형태는 지원하지 않습니다.
* 없는 값의 path를 지정하실 경우 비어있는 텍스트로 출력됩니다.

## 응답설정을 스킬로 사용하기 <a href="#use_response_settings_as_skill" id="use_response_settings_as_skill"></a>

텍스트형, 이미지형 등 기본 형식 외에 스킬데이터만을 이용해 응답형식을 설정할 수 있습니다. 아래 이미지와 같이 봇 응답형식을 추가할 때, 기본 제공형태가 아닌 **스킬데이터로 사용**을 클릭하면 스킬데이터를 응답형식으로 사용할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FQNXPVFIyex9Nlby4u0F0%2Fskill-as-response-example01.png?alt=media&amp;token=3db51b26-e5f1-4c59-a8a6-d67ad257160c" alt=""><figcaption><p>스킬값을 응답형식으로 사용하기 위해 '스킬 데이터로 사용'을 선택합니다.</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F5ETsFnNXiB2wAm3KFqHN%2Fskill-as-response-example02.png?alt=media&amp;token=c175c480-3355-4710-ae24-4dbb130032e5" alt=""><figcaption><p>스킬데이터 사용으로 응답형식을 설정한 화면</p></figcaption></figure>

상세한 포맷 및 세부 내용은 [<mark style="color:blue;">**스킬 개발 가이드 > 응답 타입별 JSON포맷**</mark>](/main/tool/chatbot/skill_guide/answer_json_format.md)에서 확인 가능합니다.

## 블록 Output 컨텍스트 스킬로 제어하기 <a href="#control_with_block_output_context_skill" id="control_with_block_output_context_skill"></a>

### 컨텍스트 정보를 스킬 응답(response)에서 활용하기 <a href="#use_context_information_in_skill_response" id="use_context_information_in_skill_response"></a>

스킬 응답에서 ‘Output 컨텍스트’의 정보를 직접 업데이트 할 수 있습니다. 예를 들어 다음과 같은 스킬 응답 포맷이 있다고 하겠습니다.

* 스킬 응답의 Structure 예시

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

**컨텍스트 갱신**

스킬 응답으로 컨텍스트를 수정하는 경우, 변경하려는 output 컨텍스트가 미리 블록에서 설정되어야 합니다. 스킬 응답의 context 필드는 값을 수정할 뿐, 새로운 output 컨텍스트를 만들 수는 없습니다.

{% hint style="success" %}
**Example.**

예를 들어 `abc` 라는 output 컨텍스트를 블록에서 생성했다면, 스킬 응답으로 `abc` name을 가지는 context의 lieSpan, params를 수정할 수 있습니다.\
하지만 `def` 라는 output 컨텍스트를 블록에서 생성하지 않은 상황에서, 스킬 응답으로 `def`라는 name을 가지는 context를 수정한다면 이는 반영되지 않습니다.
{% endhint %}

### ContextControl

context control 필드는 블록에서 생성한 outputContext의 lifeSpan, params 등을 제어할 수 있습니다.

#### 상세 필드 <a href="#detail_field" id="detail_field"></a>

| 이름     | 타입           | 필수 여부 | 제한 |
| ------ | ------------ | ----- | -- |
| values | ContextValue | O     |    |

#### ContextValue 상세 필드 <a href="#contextvalue_detail_field" id="contextvalue_detail_field"></a>

<table><thead><tr><th width="127">이름</th><th width="198">타입</th><th width="103">필수 여부</th><th>설명</th></tr></thead><tbody><tr><td>name</td><td>string</td><td>O</td><td>수정하려는 output 컨텍스트의 이름</td></tr><tr><td>lifeSpan</td><td>int</td><td>O</td><td>수정하려는 ouptut 컨텍스트의 lifeSpan</td></tr><tr><td>params</td><td>Map &#x3C;string, string></td><td>X</td><td>output 컨텍스트에 저장하는 추가 데이터</td></tr></tbody></table>

#### 예제 코드 <a href="#example_code" id="example_code"></a>

```
{
  "version": "2.0",
  "context": {
    "values": [
      {
        "name": "abc",
        "lifeSpan": 10,
        "ttl": 60,
        "params": {
          "key1": "val1",
          "key2": "val2"
        }
      },
      {
        "name": "def",
        "lifeSpan": 5,
        "params": {
          "key3": "1",
          "key4": "true",
          "key5": "{\"jsonKey\": \"jsonVal\"}"
        }
      },
      {
        "name": "ghi",
        "lifeSpan": 0
      }
    ]
  }
}
```

* `abc` output 컨텍스트의 lifeSpan을 10, ttl을 60로, params의 `key1`에 `val1`, `key2`에 `val2`를 추가합니다.
* `def` name을 갖는 ContextValue의 param처럼, 다른 타입들 또한 stringify 하여 저장할 수 있습니다.
* `ghi` name을 갖는 ContextValue처럼, lifeSpan을 0으로 바꿔서 삭제할 수 있습니다.


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/apply_skill_to_block.md
