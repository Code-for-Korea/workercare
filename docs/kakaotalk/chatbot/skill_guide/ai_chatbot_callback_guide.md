> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/ai_chatbot_callback_guide.md).

# 콜백 개발 가이드

## 개요 <a href="#overview" id="overview"></a>

콜백 옵션을 설정할 경우 카카오 챗봇 플랫폼의 스킬의 처리시간 SLA(skill timeout: 5sec) 초과될 때에도 응답을 받아올 수 있습니다.

콜백URL은 해당 스킬 처리 후 응답을 전달하기 위한 목적으로만 사용되어야 하며 일정시간(callbackUrl valid time: 5min)동안 유효하며 1회에 한하여 사용할 수 있습니다.

## Callback API 설정하기

### 블록에 콜백 설정 <a href="#setting_block_callback" id="setting_block_callback"></a>

블록 상세 > 더보기(...) 선택 시 Callback API 설정 기능이 나타납니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FW5JggKQWGiKE4fILW1uZ%2Fskill-callback-01.png?alt=media&amp;token=6943b5f1-24cd-4910-b9b7-9deefda39747" alt=""><figcaption></figcaption></figure>

### 해당 블록의 콜백 설정 활성화 <a href="#block_callback_activation" id="block_callback_activation"></a>

콜백 설정 화면에서 활성화를 한 후 기본응답메시지를 작성합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FYt4vnCSqv4utZCLWwkq3%2F%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202026-06-30%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%202.19.06.png?alt=media&amp;token=74ff49aa-b956-4759-ad7a-f2a5d0a49883" alt=""><figcaption></figcaption></figure>

### 스킬을 연결, 스킬 응답데이터 사용 <a href="#connect_skill_use_response" id="connect_skill_use_response"></a>

스킬 요청을 받을 스킬을 연결하고, 응답에서는 스킬데이터를 사용하도록 설정합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fz7MP04eqmGTDoZsMzBHu%2Fskill-callback-03.png?alt=media&amp;token=94b1a58b-ea52-488e-9ec0-28b0461839f5" alt=""><figcaption></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FqQnehU8CdYK0BbK73rbz%2Fskill-callback-04.png?alt=media&amp;token=93c9b171-bcc5-4b63-a1e9-f5303b620c3c" alt=""><figcaption></figcaption></figure>

## SkillPayload

특정 블록에 대해 콜백 옵션을 활성화하면 봇 엔진에서는 스킬 요청시 1회성 콜백URL을 발행하여 이를 요청(userRequest 부분)에 포함하여 스킬서버에 전달합니다. 기본적인 페이로드 구조는 동일하므로, 아래 개발 가이드를 참조 바랍니다.

[**스킬 개발 가이드 > 스킬 payload**](/main/tool/chatbot/skill_guide/answer_json_format.md#skillpayload)

### userRequest 상세 필드

<table><thead><tr><th width="136">필드명</th><th width="101.33333333333331">타입</th><th>설명</th></tr></thead><tbody><tr><td>callbackUrl</td><td>string</td><td>콜백 요청을 전송할 URL입니다.</td></tr><tr><td>timezone</td><td>string</td><td>한국 시간대인 “Asia/Seoul” 입니다.</td></tr><tr><td>block</td><td>Block</td><td><p></p><ul><li>사용자의 발화에 반응한 블록의 정보입니다.</li><li>블록의 id와 name을 포함합니다.</li></ul></td></tr><tr><td>utterance</td><td>string</td><td>봇 시스템에 전달된 사용자의 발화입니다.</td></tr><tr><td>lang</td><td>string</td><td>한국어인 “ko”를 지원합니다.</td></tr><tr><td>user</td><td>User</td><td>사용자의 정보입니다.</td></tr></tbody></table>

```
{
    "bot": ...,
    "intent": ...,
    "action": ...,
    "userRequest": {
        "callbackUrl": "<callback 호출시 사용할 url>",
        "block": {
            "id": "<블록 id>",
            "name": "<블록 이름>"
        },
        "user": {
            "id": "<사용자 botUserKey>",
            "type": "botUserKey",
            "properties": {
                "botUserKey": "<사용자 botUserKey>",
            }
        },
        "utterance": "<사용자 발화>",
        "params": {
            "surface": "BuilderBotTest",
            "ignoreMe": "true"
        },
        "lang": "ko",
        "timezone": "Asia/Seoul"
    },
    "contexts": ...
}
```

## SkillResponse

Callback 응답을 완료하기 위해선 응답 페이로드에 useCallback을 true로 명시해서 반환해야 합니다.\
(template 필드는 입력하지 않습니다.)

[**스킬 개발 가이드 > 응답 타입별 JSON 포맷**](/main/tool/chatbot/skill_guide/answer_json_format.md)

### SkillResponse 상세필드 <a href="#skillresponse_filed" id="skillresponse_filed"></a>

| 이름          | 타입                | 설명                       |
| ----------- | ----------------- | ------------------------ |
| version     | string            | 응답포맷버전 2.0으로 설정          |
| useCallback | boolean           | 콜백을 사용할 경우 true로 세팅해서 반환 |
| template    | SkillTemplate     | 무시                       |
| context     | ContextControl    | 컨텍스트 정보                  |
| data        | Map\<String, Any> | 데이터 설정                   |

```
{
  "version" : "2.0",
  "useCallback" : true,
  "context": {
    ...
  },
  "data": {
    ...
  }
}

```

ture를 반환하는 부분으로 template 필드는 사용하지 않으나 만약 data를 사용할 경우 아래와 같이 Callback 대기 부분에 문구를 삽입하여 응용할 수 있습니다.\
삽입은 응답 설정을 값으로 입력하는 부분을 참고하여 webhook 형태로 사용하여 주시기 바랍니다.<br>

[**블록에 스킬 적용하기 > 응답설정을 값으로 사용하기**](/main/tool/chatbot/skill_guide/apply_skill_to_block.md#use_response_settings_as_values)

#### 활용 예 <a href="#usecase" id="usecase"></a>

```
{
  "version" : "2.0",
  "useCallback" : true,
  "data": {
    "text" : "생각하고 있는 중이에요😘 \n15초 정도 소요될 거 같아요 기다려 주실래요?!"
  }
}
```

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F0ZfrO1TV9KyVdlTm54IU%2F%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202026-06-30%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%202.21.38.png?alt=media&amp;token=5f168fc7-3723-452f-8e1f-20f1cb856461" alt=""><figcaption></figcaption></figure>

## CallbackRequest

응답이 콜백으로 동작하기 위해서 Skill 페이로드로 전송된 callback\_url로 원하는 응답을 HTTP 프로토콜로 POST 방식으로(JSON 코드) 요청하여 주시기 바랍니다.

요청 포맷은 스킬 응답 포맷과 동일하며 사용자에게 최종 말풍선으로 응답됩니다.

[**스킬 개발 가이드 > 응답 타입별 JSON 포맷**](/main/tool/chatbot/skill_guide/answer_json_format.md)

## CallbackResponse

콜백 응답이 성공적으로 전송되면 아래와 같은 형태의 콜백 전송 응답이 반환됩니다.

콜백 호출이 FAIL된 경우 아래 FAIL - error Message 표와 같이 FAIL 메시지를 확인할 수 있습니다.

(FAIL요인에 대하여 메시지를 드리고 있으나 추가적인 문의가 필요하신 경우 taskId를 첨부하시어 고객센터로 문의하여 주시기 바랍니다.)

| 이름        | 타입     | 설명                                       |
| --------- | ------ | ---------------------------------------- |
| taskId    | string | 해당 리퀘스트에 대한 uuid                         |
| status    | string | 상태메시지 \["SUCCESS", "FAIL", "ERROR"] 중 하나 |
| message   | string | 상태에 대한 세부 메시지                            |
| timestamp | long   | task 생성 unixtimestamp                    |

```
{
  "taskId" : ...,
  "status" : "SUCCESS",
  "message" : ...,
  "timestamp" : ...
}
```

**error Message -표 참고**

| 안내 문구                                                                                  | 도움말 안내                                                                                                                                                         |
| -------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Invalid callback token for testing purposes.                                           | 테스트 환경(봇테스트, 채널 커스텀 유효성 테스트)의 callback token은 사용할 수 없습니다.                                                                                                      |
| Invalid callback token. Check your callback token.                                     | <p></p><p>callback token의 설정이 잘못되어 있는 상태로 아래 내용을 확인하여 주시기 바랍니다.<br></p><ol><li>callback token의 기입이 잘못된 경우</li><li>callback token이 만료된 상태(1분이내 요청 필요)</li></ol> |
| <p>The skill server settings are incorrect.<br>Use callback true setting required.</p> | <p>사용자의 스킬서버와 제대로 통신이 되지 않은 상태입니다.<br>usecallback true 처리가 되어 있는지 확인하여 주시기 바랍니다.</p>                                                                           |
| Invalid bot ID. Check your Bot ID.                                                     | 봇ID가 유효하지 않은 상태로 봇ID를 점검하여 주시기 바랍니다.                                                                                                                           |
| Invalid json response from bot-skill.                                                  | <p>json format이 잘못된 경우로 말풍선 도움말 내<br>제한 및 유의사항을 참고하여 json format을 수정해주세요.</p>                                                                                  |
| <p>Invalid skill-json format.<br>This talk bubble is not suitable for advertising.</p> | <p>광고용 json format이 잘못된 경우로 말풍선 도움말 내<br>제한 및 유의사항을 참고하여 json format을 수정해주세요.</p>                                                                              |
| Internal server error occured. Please contact technical support. 501                   | 봇 내부 통신 에러로 문의하여 주시기 바랍니다.                                                                                                                                     |
| Internal server error occured. Please contact technical support. 505                   | 봇 내부 통신 에러로 문의하여 주시기 바랍니다.                                                                                                                                     |
| Internal server error occured. Please contact technical support. 504                   | 봇 내부 통신 에러로 문의하여 주시기 바랍니다.                                                                                                                                     |
| Internal server error occured. Please contact technical support. 999                   | 봇 내부 통신 에러로 문의하여 주시기 바랍니다.                                                                                                                                     |

{% hint style="success" %}
**Tip. callback 설정 방법 요약**

1\. 챗봇 관리자센터 블록에 발화 입력 및 useCallback token 활성화

2\. 스킬 서버에서 useCallback true 입력

3\. 2번에 해당 하는 스킬서버를 챗봇 관리자센터의 블록에서 스킬 응답 설정으로 매칭

(응답에서 webhook을 사용하는 경우라면 텍스트 카드 사용 & 파라미터 옆 스킬 데이터 선택)

4\. 설정이 완료 되었다면 배포&#x20;

5\. 챗봇 관리자센터 콜백 블록에 있는 발화를 운영채널의 채팅창에서 발화 테스트

6\. 2번에 설정한 스킬 서버로 5번에서한 발화의 callbackUrl을 페이로드로 전송함

7\. 6번에서 받은 페이로드안에 있는 callbackUrl로  json 말풍선을 발송
{% endhint %}

## 주의사항 <a href="#precautions" id="precautions"></a>

봇테스트에서 콜백 기능을 완전히 지원하지 않기 때문에 봇배포를 수행하면서 테스트해주시기 바랍니다.


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/ai_chatbot_callback_guide.md
