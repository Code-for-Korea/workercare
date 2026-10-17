> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/setting_parameter.md).

# 파라미터 설정

**파라미터(Parameter)** 는 봇이 사용자의 의도를 정확히 이해하기 위해 필요로 하는 데이터를 일컫습니다. 봇과의 대화 대부분은 파라미터 데이터를 채우는 작업이라고 할 수 있습니다. 필요한 파라미터가 없으면 다시 되묻기도 합니다. API 형태로 구성된 스킬(Skill)은 데이터가 입력되면, 들어온 데이터에 맞는 다양한 결과값을 보내줍니다. 이때, 스킬에 보내지는 데이터 또한 파라미터입니다.

스킬을 제작하는 작업자는 필요한 파라미터 등에 대한 내용을 정의하게 됩니다. 예를 들어, ‘지역별 날씨를 알려주는 스킬’을 제작했다면, 지역명을 스킬로 보내게 되고 실제 날씨정보를 출력해서 보내주게됩니다. 여기에서 스킬로 보내지는 지역 정보를 ‘파라미터 데이터’로 볼 수 있습니다.

## 챗봇 관리자센터에 들어가는 파라미터 값 <a href="#parameter_for_bot_center" id="parameter_for_bot_center"></a>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FCkphzSF0Hx2PZWXnRRHS%2Fparameters-setup.png?alt=media&amp;token=4d576a63-2020-486c-84de-02cd92b30a36" alt=""><figcaption><p>파라미터 생성 및 수정 팝업</p></figcaption></figure>

## 파라미터 구성 요소 <a href="#parameter_component" id="parameter_component"></a>

### 파라미터 명 <a href="#parameter_name" id="parameter_name"></a>

파라미터를 구분하는 이름입니다.

### 엔티티 <a href="#entity" id="entity"></a>

발화에 매핑된 엔티티를 파라미터에 연결하는 역할을 합니다. 발화 입력시 유효한 엔티티가 있는 경우에는 추천 되고, 선택하여 태깅이 가능합니다.

### 값 <a href="#value" id="value"></a>

‘동작’영역에서 ‘값’은 ‘엔티티’를 통해서 채우거나 이전 또는 현재의 정보에 접근해서 값을 채울 수 있습니다. 이외에도 고정된 값을 지정해서 채울 수 있습니다. 값을 사용하기 위한 표현법은 다양합니다. 아래의 사용방법을 확인해 주세요.

* 엔티티 값
* 특정 값
* 고정된 값

**엔티티 값**

* ‘$’로 시작하는 이름으로 구성된 값
* 주로, 파라미터 이름과 동일하게 사용
* ex) $paramName1, $paramName2, …

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fv5A5ZboFAr68QPMvruif%2Fparameters-variable.png?alt=media&amp;token=b4c452c5-2a0c-434e-ab3f-76fcb2267e66" alt=""><figcaption></figcaption></figure>

**특정 값**

* 값 위치에 ‘#’으로 시작하는 이름으로 구성된 값
* ‘current’를 사용해서 접근할 수 있는 값은 현재 대화의 발화 내용
* ‘request payload’의 특정 path 값
* ex) #\[current|contextName].\[path].\[to]

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FwWHMJR5kxZuNGJb0O5sr%2Fparameters-value-path.png?alt=media&amp;token=0303003c-7983-4398-b861-9ba400820af1" alt=""><figcaption></figcaption></figure>

**고정된 값**

* ‘$’ 이나 ‘#’ 으로 시작하지 않는 값
* 값 자체가 실제 파라미터의 값으로 사용

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FWHtYcJVrGMIjiD6E70WG%2Fparameters-const-value.png?alt=media&amp;token=4821b6d2-f71c-4722-aca2-a0ec6eee8861" alt=""><figcaption></figcaption></figure>

### 기본값 <a href="#basic_value" id="basic_value"></a>

필수 파라미터로 지정되지 않고 사용자의 발화나 이전 또는 현재의 특정 값을 참조하거나, 고정된 값이 설정되어 있지 않을 경우에 ‘기본 값’으로 채택해 사용되는 기본적인 값입니다.

### 파라미터 검증 API <a href="#parameter_validation_api" id="parameter_validation_api"></a>

‘검증/변환’ 등의 작업을 스킬로 요청을 보내기 이전에 수행할 때 사용되는 항목입니다. 작업이 이루어질 때, 파라미터에 채워진 값이 ‘HTTP’요청의 ‘payload’로 사용되어 집니다.

응답의 ‘검증/변환’의 결과 값이 스킬의 요청에 활용되며, API를 검증하기 위해서는 호출할 API url과 검증 실패시 에러메시지를 등록해야 합니다. API를 통한 값의 ‘검증/변환’ 등의 작업은 대상이 되는 API url에 대해서 HTTP url 방식의 호출이 일어나게 되며, 정해진 형태의 결과값을 반환해주어야 정상적으로 동작합니다.

이외의 경우에는, 오류로 처리되며 ‘value’가 채워지지 않은 것과 같은 의미로 해석이 되어 현재 수행중이던 파라미터에 대해서 슬롯필링 과정을 다시 수행되게 됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FYbVgj78NU5EkaX0Wveg3%2Fparameters-validation.png?alt=media&amp;token=ffd33d66-3f94-4f9a-9d36-0c190d67f60e" alt=""><figcaption><p>파라미터 팝업 내 검증API 설정 영역</p></figcaption></figure>

### 그룹 파라미터 <a href="#group_parameter" id="group_parameter"></a>

기본적으로 하나의 파라미터는 하나의 엔티티와 연결되며 각 블록안에서 유일한 이름을 갖습니다. 그룹 파라미터는 동작을 수행하는 데 필요한 정보가 그룹 내 하나만 해당해도 실행하는데 문제가 없을 때 주로 사용됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FVfO7eurBYijfgCFdjR6r%2Fparameters-group.png?alt=media&amp;token=2849a807-b705-4de6-b3bd-1b3b511ec840" alt=""><figcaption><p>그룹 파라미터 대상 설정 팝업</p></figcaption></figure>

그룹을 생성하면 아래와 같이 파라미터가 묶이게 됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FwCNDUrLIDcNWEWwVjXye%2Fparameters-required.png?alt=media&amp;token=aa6fad4f-3b8c-49ac-9283-69473f049e4c" alt=""><figcaption><p>그룹 파라미터로 묶인 형태</p></figcaption></figure>

방식은 2개 이상의 파리미터의 집합으로 이루어지며 ‘그룹 파라미터’로 구성되어지는 순간, 해당 그룹은 ‘필수 파라미터’가 됩니다. 이 중에 하나 이상의 엔티티가 채워지면 슬롯필링이 완료됩니다.

‘검증 API’를 사용하는 파라미터가 그룹 파라미터인 경우에는 검증 결과가 성공하면 해당 그룹 파라미터는 슬롯필링이 완료되고, 실패하는 경우는 다음의 경우로 나뉩니다.

* 그룹 내 파라미터 중 슬롯필링이 된 경우가 없을 경우, 해당 그룹 파라미터는 슬롯필링을 수행합니다.
* 나머지 파라미터 중 하나 이상이 슬롯필링이 되었다면 슬롯필링이 완료되고 다른 파라미터에 대한 체크가 진행됩니다. 아직 값이 채워지지 않은 다른 필수 파라미터나 그룹 파라미터가 더 존재한다면 그 파라미터들에 대해서 다시 슬롯필링이 진행됩니다.

## 슬롯필링 <a href="#slot_filling" id="slot_filling"></a>

**슬롯필링** 이란 파라미터가 ‘필수’임에도 값이 채워지지 않았을 때, 해당 ‘파라미터 값’을 채우기 위해서 ‘되묻기 질문’을 사용하여 사용자와 대화를 시도하는 과정입니다. 이 과정이 존재하는 이유는 스킬별로 반드시 필요한 값들이 존재하는데 그 값을 채워 스킬을 호출하기 위해서 입니다.

슬롯필링이 진행되는 동안에는 누적되어 있던 ‘컨텍스트(Context)’의 ‘라이프스팬(Lifespan)’은 차감되지 않고, 값을 채우기 위한 시도만 진행됩니다. 그리고, 슬롯필링을 시도하는 횟수는 ‘시나리오 설정’이나 ‘되묻기 질문’에서 설정할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FxJvbOCKIHxn7MZrW94DX%2Fparameters-slot-filling.png?alt=media&amp;token=62120ded-7735-4b92-b9b7-57093c2b0fe0" alt=""><figcaption><p>되묻기 질문 설정 팝업</p></figcaption></figure>

## 파라미터에 연결된 스킬 실행 과정 <a href="#skill_process_connected_to_skill" id="skill_process_connected_to_skill"></a>

### Request payload 구성 <a href="#request_payload" id="request_payload"></a>

연결된 스킬의 실행은 모두 ‘HTTP request’로 이루어집니다. HTTP method 중 ‘POST’만을 지원하고 있으며, ‘request/response’값에 모두 JSON형태를 사용하고 있습니다. ‘Request payload’는 동작에서 정의한 파라미터들의 구성에 따라서 ‘JSON’의 구성이 달라집니다.

동작에서 구성한 파라미터 이외의 값들로는 사용자의 대화 request 안에 들어 있는 “user”, “params” 라는 예약된 필드의 값들이 그대로 전달됩니다. 그리고, 현재까지 누적되어 있는 컨텍스트의 목록 또한 “contexts” 라는 이름으로 전달 됩니다.

이외에 http header 에는 “X-Request-Id” 라는 형태로 하나의 대화에 부여된 유일한 값인 footprint id 값을 같이 전달하게 됩니다.

| HTTP Request Method | Response Format             | HTTP Header  |
| ------------------- | --------------------------- | ------------ |
| POST                | JSON(키 구성 등에 대한 고정된 스펙은 없음) | X-Request-Id |

### payload란?

HTTP 요청을 보낼 때, 포함되는 데이터를 payload라고 합니다. payload는 JSON 형태를 가지고 있으며 JSON을 구성하는 키는 파라미터 이름이고, 값은 추출된 값이 됩니다. HTTP 요청에 대한 응답도 JSON 의 형태를 갖고 출력 영역으로 전달되고 사용 되어질 수 있습니다. ‘Payload’는 파라미터들이 ‘key value’ 형태로 JSON을 기본 구성하고 여기에 ‘user request’의 일부 항목과 누적된 컨텍스트 정보입니다.

* **Skill request body**

```
{
  "userRequest": [REQUEST OBJECT],
  "bot": {
    "id": "bot id",
    "name": "bot name"
  },
  "action": {
    "id": "action id (uuid)",
    "name": "builder에서 등록한 이름",
    "params": {
      "param name" : "resolved value"
      ....
    }
    "detailParams": {
      "param name" : {
        "origin": "origin value in utterance",
        "resolved": "resolvedValue from NLU engine"
      },
      ...
    }
  }
}
```

```
{
    "userRequest": {
        "makerId": "june.kay",
        "user": {
            "id": "1",
            "type": "accountId"
        },
        "chatId": "chatchat",
        "utterance": "오늘 용띠 운세 좀",
        "device": null,
        "params": null
    },
    "bot": {
        "id": "f6a2a947-7b55-4bdb-b36e d9eac9fe9aca",
        "name": "노래봇"
    },
    "intent": {
        "id": "af5fb347-ce65-483e-ae2d-dedeb5f97a68",
        "name": "띠찾아"
    },
    "action": {
        "id": "88254013-1581-44bc-a4b2-ccfb69327ca9",
        "name": "fortune.desc",
        "params": {
            "entity_toTime": "2017-06-01T12:00:21+0900",
            "entity_zodiacName": "용띠",
            "entity_fromTime": "2017-06-01T12:00:21+0900",
            "intent": "informZodiacFortune"
        },
        "detailParams": {
            "entity_toTime": {
                "origin": "오늘",
                "value": "2017-06-01T12:00:21+0900"
            },
            "entity_zodiacName": {
                "origin": "용띠",
                "value": "용띠"
            },
            "entity_fromTime": {
                "origin": "오늘",
                "value": "2017-06-01T12:00:21+0900"
            },
            "intent": {
                "origin": "informZodiacFortune",
                "value": "informZodiacFortune"
            }
        }
    }
}
```

```
{
    "userRequest": {
        "makerId": "june.kay",
        "user": {
            "id": "1",
            "type": "accountId"
        },
        "chatId": "chatchat",
        "utterance": "오늘 용띠 운세 좀",
        "device": null,
        "params": null
    },
    "bot": {
        "id": "f6a2a947-7b55-4bdb-b36e d9eac9fe9aca",
        "name": "노래봇"
    },
    "intent": {
        "id": "af5fb347-ce65-483e-ae2d-dedeb5f97a68",
        "name": "띠찾아"
    },
    "action": {
        "id": "88254013-1581-44bc-a4b2-ccfb69327ca9",
        "name": "fortune.desc",
        "params": {
            "entity_toTime": "2017-06-01T12:00:21+0900",
            "entity_zodiacName": "용띠",
            "entity_fromTime": "2017-06-01T12:00:21+0900",
            "intent": "informZodiacFortune"
        },
        "detailParams": {
            "entity_toTime": {
                "origin": "오늘",
                "value": "2017-06-01T12:00:21+0900"
            },
            "entity_zodiacName": {
                "origin": "용띠",
                "value": "용띠"
            },
            "entity_fromTime": {
                "origin": "오늘",
                "value": "2017-06-01T12:00:21+0900"
            },
            "intent": {
                "origin": "informZodiacFortune",
                "value": "informZodiacFortune"
            }
        }
    }
}
```

## 개발자를 위한 심화단계 <a href="#advanced_steps_for_developer" id="advanced_steps_for_developer"></a>

### API 파라미터 설명 <a href="#introduce_api_parameter" id="introduce_api_parameter"></a>

파라미터들 중, AIU(NLU)를 통해서 resolve된 케이스와 컨텍스트를 통한 레퍼런스 접근, 그리고 사용자 발화(Utterence)에서 뽑힌 값들에 대해서 지정된 API를 통해서 스킬의 payload 로 만들어져 보내지기 전에 값을 확인 및 resolve/validation/transform 을 수행할 수 있는 기능을 제공합니다.

### 실제되는 형태 <a href="#actual_form" id="actual_form"></a>

값이 채워진 파라미터들 중, API 사용에 대한 메타 데이터(API URL, error message)가 등록된 파라미터에 대해서 아래의 미리 정해진 스펙으로 HTTP request / response 를 통해서 값을 변환하고 변환된 값을 사용하도록 처리합니다.

### Request payload 구조 <a href="#structure_request_payload" id="structure_request_payload"></a>

```
{
    "isInSlotFilling": true or false
    "utterance": "current request's utterance",
    "value": {
        "origin": "orignal value",
        "resolved": "resolved value(by AIU or etc.)"
    },
    "user": {
        // vsc 에서 전달된 data 그대로 전달
        "id": "id of user",
        "type": "type of id"
    }
}
```

### 예약된 Response JSON 구조 <a href="#booked_structure_response_json" id="booked_structure_response_json"></a>

```
{
    "status": "SUCCESS|FAIL|ERROR|IGNORE", // 현재는 SUCCESS 만 다룸.(SUCCESS - 성공, FAIL - 실패,
    ERROR - API 실행중 ERROR 발생, IGNORE - 그냥 이 결과를 무시)
    "value": "Action 에 의해서 해석된 value",
    "data": {
        // something to pass to client(API 가 Action 으로 전달하고자 하는 데이터를 담는 곳, 아직 구현되지 않음)
    },
    "message": "..." // String type
}
```

실제 스킬 요청으로 넘어가는 payload에서 detailparams의 value이 값이 validation 응답의 value로 그대로 전달됩니다.\
스킬 요청시 payload로 전송할때 그대로 전달하는 필드는 action.detailsParams\[n].value 입니다.

status 필드가 FAIL 이고, message 필드를 입력한 경우에는 검증 실패 에러 메시지가 message 필드의 값으로 대체됩니다.&#x20;

(챗봇 관리자센터 블록 내 파라미터 검증API 설정에 검증 실패 에러 메시지 가 있더라도 스킬의 message만 노출됩니다.)

되묻기 진행할때 유효성 검증에 실패한 경우 ‘검증 실패 에러 메시지’와 ‘되묻기질문’이 합해진 형태로 말풍선으로 노출되어 유효한 응답을 입력하게끔 유도합니다.

(EX : 검증에 실패 하였습니다 + 좋아하는 색상은 무엇인가요?)

실패 에러 메시지가 노출될때 위점을 고려하시어 자연스러운 응답이 되도록 설계하여 주시기 바랍니다.

파라미터를 이용한 되묻기 질문 설정 방법은 [**주문서 작성하기**](broken://pages/zRUjg8QM9vKZSZrqW0so#make_order)를, 파라미터를 이용한 스킬 연결 방법은 [**블록에 스킬 적용하기**](broken://pages/IIlBejAiBuCBzqqaga1s)를 참조하시길 바랍니다.


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/setting_parameter.md
