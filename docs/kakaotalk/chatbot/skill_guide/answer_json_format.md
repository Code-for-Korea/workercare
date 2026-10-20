> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/answer_json_format.md).

# 응답 타입별 JSON 포맷

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FWURZdD6iXR81EETqYBnH%2Fskill-json-format-intro.png?alt=media&amp;token=71d54b9d-0211-4e31-833f-2cc75dc29751" alt=""><figcaption></figcaption></figure>

스킬을 통해 카카오톡의 유려한 말풍선을 직접 그려내실 수도 있습니다.

빠른 한걸음을 위해 말풍선의 응답 타입별 JSON 포맷을 공유해 드리겠습니다. 여러분의 사용자 응대 시나리오에 맞게 간편하게 수정해서 쓰시면 많은 도움이 될 것입니다. 텍스트형/이미지형/카드형/커머스형/리스트형까지 말풍선을 그리기 위한 JSON 샘플 코드를 빠르게 참고해보세요!

## SkillPayload

### 구성 <a href="#composition" id="composition"></a>

스킬 payload는 스킬 실행시 봇 시스템이 스킬 서버에게 전달하는 정보입니다. payload는 사용자의 정보, 발화, 실행 블록, 파라미터 등의 정보를 포함합니다.

* intent
* userRequest
* bot
* action
* flow

### intent

발화와 일치하는 블록의 정보를 담고 있는 필드입니다. 발화가 지식+에 일치하는 경우, 일치하는 지식의 목록을 포함합니다.

#### 상세 필드 <a href="#detail_field" id="detail_field"></a>

<table><thead><tr><th width="116.33333333333331">필드명</th><th width="159">타입</th><th>설명</th></tr></thead><tbody><tr><td>id</td><td>String</td><td>블록 id입니다.</td></tr><tr><td>name</td><td>String</td><td>블록명이며, 지식의 경우 “지식+”로 노출합니다.</td></tr></tbody></table>

### intent.extra.knowledges

#### 상세 필드 <a href="#detail_field" id="detail_field"></a>

| 필드명               | 타입                 | 설명                |
| ----------------- | ------------------ | ----------------- |
| matchedKnowledges | Array\<Knowledges> | 발화에 일치한 지식 목록입니다. |

### knowledge

#### 상세 필드 <a href="#detail_field" id="detail_field"></a>

<table><thead><tr><th width="238">필드명</th><th width="225.33333333333331">타입</th><th>설명</th></tr></thead><tbody><tr><td>answer</td><td>String</td><td>지식의 답변입니다.</td></tr><tr><td>question</td><td>String</td><td>지식의 질문입니다.</td></tr><tr><td>categories</td><td>Array&#x3C;String></td><td>QA의 카테고리입니다.</td></tr><tr><td>landingUrl</td><td>String</td><td>지식 답변에서 링크 더보기입니다.</td></tr><tr><td>imageUrl</td><td>String</td><td>지식 답변에서 썸네일 이미지입니다.</td></tr></tbody></table>

#### 예제 코드 <a href="#example_code" id="example_code"></a>

```
{
    "bot": {
        "id": "<봇 id>",
        "name": "<봇 이름>"
    },
    "intent": {
        "id": "<블록 id>",
        "name": "지식+",
        "extra": {
            "reason": {
                "code": 1,
                "message": "OK"
            },
            "knowledge": {
                "responseType": "skill",
                "matchedKnowledges": [
                    {
                        "categories": [
                            "<카테고리 1>",
                            "<카테고리 2>",
                            "<카테고리 3>",
                            "<카테고리 4>"
                        ],
                        "question": "<질문>",
                        "answer": "<답변>",
                        "imageUrl": "<이미지 url>",
                        "landingUrl": "<랜딩 url>"
                    },
                    {
                        "categories": [
                            "<카테고리 1>",
                            "<카테고리 2>",
                            "<카테고리 3>",
                            "<카테고리 4>"
                        ],
                        "question": "<질문>",
                        "answer": "<답변>",
                        "imageUrl": "<이미지 url>",
                        "landingUrl": "<랜딩 url>"
                    }
                ]
            }
        }
    },
    "action": {
        "id": "<액션 id>",
        "name": "<액션 이름>",
        "params": {},
        "detailParams": {},
        "clientExtra": {}
    },
    "userRequest": {
        "block": {
            "id": "<블록 id>",
            "name": "<블록 이름>"
        },
        "user": {
            "id": "<사용자 botUserKey>",
            "type": "botUserKey",
            "properties": {
                "botUserKey": "<사용자 botUserKey>"
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
    "contexts": []
}
```

### userRequest

사용자의 정보를 담고 있는 필드입니다. 사용자의 발화와 반응한 블록의 정보를 추가적으로 포함합니다.

#### 상세 필드 <a href="#detail_field" id="detail_field"></a>

<table><thead><tr><th width="126">필드명</th><th width="87.33333333333331">타입</th><th>설명</th></tr></thead><tbody><tr><td>timezone</td><td>string</td><td>사용자의 시간대를 반환합니다.한국에서 보낸 요청이라면 “Asia/Seoul”를 갖습니다.</td></tr><tr><td>block</td><td>Block</td><td><ul><li>사용자의 발화에 반응한 블록의 정보입니다.</li><li>블록의 id와 name을 포함합니다.</li></ul></td></tr><tr><td>utterance</td><td>string</td><td>봇 시스템에 전달된 사용자의 발화입니다.</td></tr><tr><td>lang</td><td>string</td><td><ul><li>사용자의 언어를 반환합니다.</li><li>한국에서 보낸 요청이라면 “ko”를 갖습니다.</li></ul></td></tr><tr><td>user</td><td>User</td><td>사용자의 정보입니다.</td></tr></tbody></table>

### bot

사용자의 발화를 받은 봇의 정보를 담고 있는 필드입니다.

#### 상세 필드 <a href="#detail_field" id="detail_field"></a>

| 필드명  | 타입     | 설명             |
| ---- | ------ | -------------- |
| id   | String | 봇의 고유한 식별자입니다. |
| name | String | 설정된 봇의 이름입니다.  |

### action

실행되는 스킬의 정보를 담고있는 필드입니다. 사용자의 발화로부터 추출한 엔티티의 값을 추가적으로 포함합니다.

#### 상세 필드 <a href="#detail_field" id="detail_field"></a>

<table><thead><tr><th width="160.33333333333331">필드명</th><th width="242">타입</th><th>설명</th></tr></thead><tbody><tr><td>id</td><td>String</td><td>스킬의 고유한 식별자입니다.</td></tr><tr><td>name</td><td>String</td><td>설정된 스킬의 이름입니다.</td></tr><tr><td>params</td><td>Map&#x3C;String, String></td><td><p></p><ul><li>사용자의 발화로부터 추출한 파라미터 정보입니다.</li><li>엔티티의 이름을 키로, 추출한 정보를 상세 값으로 가집니다.</li></ul></td></tr><tr><td>detailParams</td><td>Map&#x3C;String, DetailParam></td><td><p></p><ul><li>사용자의 발화로부터 추출한 엔티티의 상세 정보입니다.</li><li>params 필드와 유사하지만, params에서 제공하지 않은 추가적인 정보들을 제공합니다.</li></ul></td></tr><tr><td>clientExtra</td><td>Map&#x3C;String, Any></td><td><p></p><ul><li>사용자의 발화가 추가적인 정보를 제공하는 경우가 있습니다 (예. 바로가기 응답)</li><li>그 값들이 clientExtra 필드를 통해서 스킬 서버에 전달됩니다.</li></ul></td></tr></tbody></table>

#### 예제 코드 <a href="#example_code" id="example_code"></a>

```
{
 "userRequest": {
    "timezone": "Asia/Seoul",
    "params": {},
    "block": {
      "id": "<블록 id>",
      "name": "<블록 이름>"
    },
    "utterance": "<사용자 발화>",
    "lang": "ko",
    "user": {
      "id": "<사용자 botUserKey>",
      "type": "botUserKey",
      "properties": {
        "plusfriendUserKey": "<카카오톡 채널 사용자 id>"
      }
    }
  },
  "contexts": [],
  "bot": {
    "id": "<봇 id>",
    "name": "<봇 이름>"
  },
  "action": {
    "name": "<스킬 이름>",
    "clientExtra": null,
    "params": {},
    "id": "<스킬 id>",
    "detailParams": {}
  }
}
```

### user

#### 상세 필드 <a href="#detail_field" id="detail_field"></a>

Skill Request에서 사용자에 대한 정보를 userRequest.user에 담아서 제공하고 있습니다.

<table><thead><tr><th width="137.33333333333334">필드</th><th width="103">타입</th><th>설명</th></tr></thead><tbody><tr><td><em>id</em></td><td>string</td><td><p></p><ul><li>사용자를 식별할 수 있는 key로 최대 70자의 값을 가지고 있습니다.</li><li>이 값은 특정한 bot에서 사용자를 식별할 때 사용할 수 있습니다.</li><li>동일한 사용자더라도, 봇이 다르면 다른 id가 발급됩니다.</li></ul></td></tr><tr><td>type</td><td>string</td><td>현재는 botUserKey만 제공합니다.</td></tr><tr><td>properties</td><td>Object</td><td>추가적으로 제공하는 사용자의 속성 정보입니다.</td></tr></tbody></table>

### user.properties

#### 상세 필드 <a href="#detail_field" id="detail_field"></a>

<table><thead><tr><th width="195">속성</th><th width="104.33333333333334">타입</th><th>설명</th></tr></thead><tbody><tr><td>plusfriendUserKey</td><td>string</td><td><p></p><ul><li>카카오톡 채널에서 제공하는 사용자 구분키(비식별) 입니다.</li><li>카카오톡 채널의 자동응답 API에서 제공하던 user_key와 같습니다. (<a href="https://github.com/plusfriend/auto_reply#specification-1">https://github.com/plusfriend/auto_reply#specification-1</a>)</li><li>모든 사용자에게 제공되는 값으로, botUserKey와 마찬가지로 봇에서 사용자를 식별하는데 사용할 수 있습니다.</li></ul></td></tr><tr><td>appUserId</td><td>string</td><td><p></p><ul><li>봇 설정에서 앱키를 설정한 경우에만 제공되는 사용자 정보입니다.</li><li>앱키를 설정하기 위해서는 카카오 디벨로퍼스 사이트에서 앱을 생성해야 합니다.</li><li>카카오 디벨로퍼스 앱 생성하기 : (<a href="https://developers.kakao.com/docs/latest/ko/tutorial/start#create">https://developers.kakao.com/docs/latest/ko/tutorial/start#create</a>)</li><li>앱 키가 정상적으로 등록된 경우, 카카오 로그인으로 받는 값과 동일한 값을 얻을 수 있습니다.</li></ul></td></tr><tr><td>isFriend</td><td>Boolean</td><td><p></p><ul><li>사용자가 봇과 연결된 카카오톡 채널을 추가한 경우 제공되는 구분키(비식별) 입니다.</li><li>채널을 추가한 경우만 True 값이 전달되며, 채널을 추가하지 않은 경우/차단한 경우에는 값이 전달되지 않습니다.</li></ul></td></tr><tr><td>botUserKey</td><td>string</td><td><ul><li>사용자가 봇에게 발화한 경우 제공하는 구분키(비식별) 입니다.</li></ul></td></tr></tbody></table>

#### 예제 코드 <a href="#example_code" id="example_code"></a>

```
{
  ...,
  "userRequest": {
    ...
    "user": {
      "id": "<사용자 botUserKey>",
      "type": "botUserKey",
      "properties": {
        "plusfriendUserKey": "<카카오톡 채널 사용자 id>",
        "appUserId": "<app user id>",
        "isFriend" : true
      }
    }
  },
  ...
}
```

### DetailParams

블록의 발화에서 설정한 파라미터를 추출하면 추출값 뿐만 아니라 추가적인 정보를 얻을 수 있습니다. 그 예로, 요일을 sys.date 라는 시스템 엔티티로 추출하면 단순히 ‘금요일’ 이라는 요일 뿐만 아니라 구체적인 날짜까지 포함합니다.

**파라미터 등록 예제**

‘1 금요일 강남’ 이라는 발화를 사용하면 실제로 아래의 params, detailParams 값이 스킬 서버로 전달됩니다.

```
{
  ...,
  "action": {
    "name": "예제 스킬",
    "id": "...",
    "params": {
      "sys_date": "{\"dateTag\": \"Friday\", \"dateHeadword\": null, \"year\": null, \"month\": null, \"day\": null, \"date\": \"2023-03-31\", \"polynomial\": \"define_weekday({4})\", \"calendar_type\": \"solar\"}",
      "sys_location": "강남",
      "sys_number": "{\"amount\": 1, \"unit\": null}"
    },
    "detailParams": {
      "sys_date": {
        "origin": "금요일",
        "value": "{\"dateTag\": \"Friday\", \"dateHeadword\": null, \"year\": null, \"month\": null, \"day\": null, \"date\": \"2023-03-31\", \"polynomial\": \"define_weekday({4})\", \"calendar_type\": \"solar\"}",
        "groupName": ""
      },
      "sys_location": {
        "origin": "강남",
        "value": "강남",
        "groupName": ""
      },
      "sys_number": {
        "origin": "1",
        "value": "{\"amount\": 1, \"unit\": null}",
        "groupName": ""
      }
    }
  }
}
```

params은 봇 시스템에서 분석하여 추가적인 정보를 채운 값입니다. detailParams는 봇 시스템에서 분석한 값 뿐만 아니라, 원래 발화에 담겨 있었던 origin을 포함합니다.

### flow

사용자와 챗봇의 대화 흐름을 담고 있는 필드로 trigger와 lastBlock으로 구성됩니다.\
이 필드는 사용자 발화를 발생시킨 트리거 정보와 직전에 실행된 블록 정보를 포함합니다.

#### 상세 필드 <a href="#detail_field" id="detail_field"></a>

<table><thead><tr><th width="160">필드명</th><th width="100">타입</th><th>설명</th></tr></thead><tbody><tr><td>trigger</td><td>Trigger</td><td><ul><li>사용자 발화를 생성시킨 트리거 정보를 담고 있습니다.</li><li>발화 입력, 버튼 클릭 등을 구분할 수 있는 Trigger Type과 <br>사용자가 상호작용한 블록 정보가 포함됩니다.</li></ul></td></tr><tr><td>lastBlock</td><td>Block</td><td><ul><li>직전에 실행된 블록 정보로 id와 name을 포함합니다.</li></ul></td></tr></tbody></table>

### flow\.trigger

사용자 발화를 발생시킨 트리거 정보입니다. \
type은 블록 호출 유형을 나타내며 referrerBlock은 사용자가 상호작용한 블록의 정보를 포함합니다.

#### 상세 필드 <a href="#detail_field" id="detail_field"></a>

<table><thead><tr><th width="181">필드명</th><th width="109">타입</th><th>설명</th></tr></thead><tbody><tr><td>type</td><td>String</td><td><ul><li>사용자 발화를 발생시킨 Trigger Type에 대한 정보입니다.</li></ul></td></tr><tr><td>referrerBlock</td><td>Block</td><td><ul><li>사용자 발화가 발생할 때 상호작용이 일어난 블록의 정보로<br>해당 블록의 id와 name을 포함합니다.</li></ul></td></tr></tbody></table>

#### Trigger Type 유형

trigger.type 값은 Output Type과 Action Type의 조합으로 이루어지며\
각 상황에 맞는 Trigger Type은 다음과 같습니다.

#### 상세 필드 <a href="#detail_field" id="detail_field"></a>

<table><thead><tr><th width="278">구분</th><th width="292">Trigger Type</th><th width="151">Output Type</th><th>Action Type</th></tr></thead><tbody><tr><td>발화 입력</td><td>TEXT_INPUT</td><td>INPUT</td><td>TEXT</td></tr><tr><td>일반카드의 버튼-메시지 전송</td><td>CARD_BUTTON_MESSAGE</td><td>CARD_BUTTON</td><td>MESSAGE</td></tr><tr><td>일반카드의 버튼-블록 연결</td><td>CARD_BUTTON_BLOCK</td><td>CARD_BUTTON</td><td>BLOCK</td></tr><tr><td><p>리스트 카드의 버튼-메시지 </p><p>전송</p></td><td>LIST_ITEM_MESSAGE</td><td>LIST_ITEM</td><td>MESSAGE</td></tr><tr><td>리스트 카드의 버튼-블록 연결</td><td>LIST_ITEM_BLOCK</td><td>LIST_ITEM</td><td>BLOCK</td></tr><tr><td>리스트 메뉴의 버튼-메시지 전송</td><td>LISTMENU_MESSAGE</td><td>LISTMENU</td><td>MESSAGE</td></tr><tr><td>리스트 메뉴의 버튼-블록 연결</td><td>LISTMENU_BLOCK</td><td>LISTMENU</td><td>BLOCK</td></tr><tr><td>바로연결의 버튼-블록 연결</td><td>QUICKREPLY_BUTTON_MESSAGE</td><td>QUICKREPLY</td><td>MESSAGE</td></tr><tr><td>바로연결의 버튼-메시지 전송</td><td>QUICKREPLY_BUTTON_BLOCK</td><td>QUICKREPLY</td><td>BLOCK</td></tr></tbody></table>

#### 예제 코드 <a href="#example_code" id="example_code"></a>

```
{
    ...,
    "flow": {
        "trigger": {
            "type": "<Trigger Type>",
            "referrerBlock": {
                "id": "<참조 블록 ID>",
                "name": "<참조 블록 이름>"
            }
        },
        "lastBlock": {
            "id": "<이전 블록 ID>",
            "name": "<이전 블록 이름>"
        }
    }
}
```

## SkillResponse

### 구성 <a href="#composition" id="composition"></a>

스킬 응답은 크게 version/template/context/data 총 4가지 부분으로 구성됩니다.

#### Version

* 스킬 응답의 version을 나타냅니다. \<major-version>.\<minor-version>의 모습을 갖습니다.
* **현재 스킬 응답의 version은 2.0만 지원됩니다.**

{% hint style="danger" %}
**Caution.**

version이 없다면 구 버전의 응답으로 간주하기 때문에, 항상 version을 포함해야 합니다.
{% endhint %}

#### Template

* 스킬 응답의 출력 모양을 담고 있는 항목입니다. 출력으로 사용할 요소 그룹, 바로가기 응답 그룹 등을 포함합니다.
* [**자세히 보기**](#skilltemplate)
* [**스킬 개발 가이드 > 응답 설정을 스킬로 사용하기**](/main/tool/chatbot/skill_guide/apply_skill_to_block.md#use_response_settings_as_skill)

#### Context Control

* 블록의 context 설정을 제어할 수 있습니다.
* [**자세히 보기**](#contextcontrol)

#### Data

* 필요에 따라 커스텀한 데이터를 넣을 수 있는 항목입니다.
* [**스킬 개발 가이드 > 응답 설정을 값으로 사용하기**](/main/tool/chatbot/skill_guide/apply_skill_to_block.md#use_response_settings_as_values)

### 필드 및 예제 <a href="#field_and_example" id="field_and_example"></a>

#### 상세 필드 <a href="#field_and_example" id="field_and_example"></a>

<table><thead><tr><th width="138.33333333333334">이름</th><th width="248">타입</th><th>필수 여부</th></tr></thead><tbody><tr><td>version</td><td>string</td><td>O</td></tr><tr><td>template</td><td>SkillTemplate</td><td>응답을 <code>스킬데이터로 사용</code> 체크시 필수<br>(<a href="/main/tool/chatbot/skill_guide/apply_skill_to_block.md#use_response_settings_as_skill"><strong>더 알아보기</strong></a>)</td></tr><tr><td>context</td><td>ContextControl</td><td>X</td></tr><tr><td>data</td><td>Map&#x3C;String, Any></td><td>X</td></tr></tbody></table>

#### 예제 코드 <a href="#example_code" id="example_code"></a>

```
{
  "version": "2.0",
  "template": {
    ...
  },
  "context": {
    ...
  },
  "data": {
    ...
  }
}
```

## SkillTemplate

### 구성 <a href="#composition" id="composition"></a>

<table><thead><tr><th>이름</th><th>타입</th><th width="119">필수 여부</th><th>제한</th></tr></thead><tbody><tr><td>outputs</td><td>Array&#x3C;Component></td><td>y</td><td>1개 이상 3개 이하</td></tr><tr><td>quickReplies</td><td>Array&#x3C;QuickReply></td><td>n</td><td>10개 이하</td></tr></tbody></table>

### outputs(출력 그룹)

출력 그룹(outputs)은 여러 종류의 출력 요소(component)를 포함합니다. 이를 통하여 종류가 다르거나 구분해야 할 필요가 있는 콘텐츠를 여러 출력 요소로 나눠서 표현할 수 있습니다. 출력 요소는 텍스트, 음성, 주소, 카드형 등 다양한 모습을 갖습니다.

| 이름           | 설명     | \*캐로셀 가능 여부 |
| ------------ | ------ | ----------- |
| simpleText   | 간단 텍스트 | X           |
| simpleImage  | 간단 이미지 | X           |
| basicCard    | 기본 카드  | O           |
| commerceCard | 커머스 카드 | O           |
| listCard     | 리스트 카드 | X           |

{% hint style="warning" %}
**Definition.**

케로셀은 여러 개의 출력 요소를 묶어서 제공하는 형태입니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Ftg9ppUmScr4zCrL0g4WA%2Fskill-outputs-carousel-example-1%20(1)%20(1).jpg?alt=media&amp;token=935ebbb7-f0b3-46c9-b76e-163d7dec51ef" alt=""><figcaption><p>기본 카드형 케로셀 예제</p></figcaption></figure>

### quickReplies(바로가기 그룹)

바로가기 그룹(quickReplies)은 여러 개의 바로가기 요소(quickReply)를 포함합니다. 바로가기 응답을 이용하면, 유저는 직접 발화를 텍스트로 입력하지 않더라도 메세지를 출력하거나, 다른 블록을 호출할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fwnp0l1UoCGpm5Np2aJi3%2Fskill-quickreplies-example%20(1).png?alt=media&amp;token=397a475c-380b-45ba-8074-f81efaab3f74" alt=""><figcaption></figcaption></figure>

이를 통해 사용자는 발화를 직접 입력해야 하는 번거로움을 줄이고, 다음 발화에 대한 힌트를 얻을 수 있습니다.

## ContextControl

context control 필드는 블록에서 생성한 outputContext의 lifeSpan, params 등을 제어할 수 있습니다.

### 상세 필드 <a href="#field_details" id="field_details"></a>

| 이름     | 타입           | 필수 여부 | 제한 |
| ------ | ------------ | ----- | -- |
| values | ContextValue | O     |    |

### ContextValue 상세 필드 <a href="#contextvalue_field_details" id="contextvalue_field_details"></a>

<table><thead><tr><th width="115">이름</th><th width="191">타입</th><th width="98">필수 여부</th><th>설명</th></tr></thead><tbody><tr><td>name</td><td>string</td><td>O</td><td>수정하려는 output 컨텍스트의 이름</td></tr><tr><td>lifeSpan</td><td>int</td><td>O</td><td>수정하려는 ouptut 컨텍스트의 lifeSpan</td></tr><tr><td>params</td><td>Map &#x3C;string, string></td><td>X</td><td>output 컨텍스트에 저장하는 추가 데이터</td></tr></tbody></table>

### 예제 코드 <a href="#example_code" id="example_code"></a>

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

## SimpleText

간단한 텍스트형 출력 요소입니다.

### 상세 필드 <a href="#field_details" id="field_details"></a>

<table><thead><tr><th width="88">이름</th><th width="82">타입</th><th width="106">필수 여부</th><th>설명</th><th>제한</th></tr></thead><tbody><tr><td>text</td><td>string</td><td>O</td><td>전달하고자 하는 텍스트입니다</td><td>1000자</td></tr></tbody></table>

* text가 500자가 넘는 경우, 500자 이후의 글자는 생략되고 `전체 보기` 버튼을 통해서 전체 내용을 확인할 수 있습니다.

### 예제코드 <a href="#example_code" id="example_code"></a>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fgq9izBbY5exoNvSVd1ja%2Fskill-simpletext-example.png?alt=media&amp;token=3a41f9e9-d138-4fda-a88a-50e55a28377d" alt=""><figcaption></figcaption></figure>

```
{
    "version": "2.0",
    "template": {
        "outputs": [
            {
                "simpleText": {
                    "text": "간단한 텍스트 요소입니다."
                }
            }
        ]
    }
}
```

## SimpleImage

간단한 이미지형 출력 요소입니다. 이미지 링크 주소를 포함하면 이를 스크랩하여 사용자에게 전달합니다.

### 상세 필드 <a href="#field_details" id="field_details"></a>

<table><thead><tr><th width="153">이름</th><th>타입</th><th>필수 여부</th><th>설명</th><th>제한</th></tr></thead><tbody><tr><td>imageUrl</td><td>string</td><td>O</td><td>전달하고자 하는 이미지의 url입니다</td><td>URL 형식</td></tr><tr><td>altText</td><td>string</td><td>X</td><td>디바이스에 스크린 리더 기능이 켜져있을 때 재생되는 대체텍스트입니다</td><td>최대 50자</td></tr></tbody></table>

### 예제 코드 <a href="#example_code" id="example_code"></a>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F7sWAD0KeR3bEMdnGcYKY%2Fskill-simpleimage-example.png?alt=media&amp;token=45478293-f429-47c7-90c2-913cc92944fa" alt=""><figcaption></figcaption></figure>

```
{
    "version": "2.0",
    "template": {
        "outputs": [
            {
                "simpleImage": {
                    "imageUrl": "https://t1.kakaocdn.net/openbuilder/sample/lj3JUcmrzC53YIjNDkqbWK.jpg",
                    "altText": "보물상자가 모래사장 위에 놓여 있습니다"
                }
            }
        ]
    }
}
```

## TextCard

텍스트 카드형 출력 요소입니다. 텍스트 카드는 간단한 텍스트에 버튼을 추가하거나, 텍스트를 케로셀형으로 전달하고자 할 때 사용됩니다.

### 상세 필드 <a href="#field_details" id="field_details"></a>

<table><thead><tr><th width="148">필드명</th><th width="136">타입</th><th width="100">필수 여부</th><th width="218">설명</th><th>제한</th></tr></thead><tbody><tr><td>title</td><td>string</td><td>title, description 중 최소 하나 필수</td><td>카드의 제목입니다.</td><td>최대 50자</td></tr><tr><td>description</td><td>string</td><td>title, description 중 최소 하나 필수</td><td>카드에 대한 상세 설명입니다.</td><td>단일형인 경우, 최대 400자 (title에 따라 달라짐) 케로셀인 경우, 최대 128자</td></tr><tr><td>buttons</td><td>Array               &#x3C;<a href="https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/answer_json_format#button"><strong>Button</strong></a>>                  </td><td>X</td><td>카드의 버튼들을 포함합니다.</td><td>가로 정렬 시 최대 2개, 세로 정렬 시 최대 3개</td></tr><tr><td><a href="https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/answer_json_format#buttonlayout"><strong>buttonLayout</strong></a></td><td>string</td><td>X</td><td>버튼 정렬 정보입니다.</td><td></td></tr></tbody></table>

{% hint style="info" %}
**Information.**

* 단일형인 경우, title과 description을 합쳐 최대 400자까지 노출됩니다.
* title과 description이 모두 사용될 경우 title은 검은색 description은 회색으로 노출됩니다.

  만약 title과 description중 1개만 사용된 경우 검은색으로 노출됩니다.
  {% endhint %}

### 예제 코드 <a href="#example_code" id="example_code"></a>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F87kwNT7kDDtWtcwyNZNl%2Fskill-textcard-example2.png?alt=media&amp;token=86d22a57-798c-41ec-877e-c6903a4ae5ca" alt=""><figcaption></figcaption></figure>

```
{
  "version": "2.0",
  "template": {
    "outputs": [
      {
        "textCard": {
          "title": "챗봇 관리자센터에 오신 것을 환영합니다.",
          "description": "챗봇 관리자센터로 챗봇을 제작해 보세요. \n카카오톡 채널과 연결하여, 이용자에게 챗봇 서비스를 제공할 수 있습니다.",
          "buttons": [
            {
              "action": "webLink",
              "label": "소개 보러가기",
              "webLinkUrl": "https://chatbot.kakao.com/docs/getting-started-overview/"
            },
            {
              "action": "webLink",
              "label": "챗봇 만들러 가기",
              "webLinkUrl": "https://chatbot.kakao.com/"
            }
          ]
        }
      }
    ]
  }
}
```

## BasicCard

기본 카드형 출력 요소입니다. 기본 카드는 소셜, 썸네일, 프로필 등을 통해서 사진이나 글, 인물 정보 등을 공유할 수 있습니다. 기본 카드는 제목과 설명 외에 썸네일 그룹, 프로필, 버튼 그룹, 소셜 정보를 추가로 포함합니다.

### 상세 필드 <a href="#field_details" id="field_details"></a>

<table><thead><tr><th width="140">필드명</th><th>타입</th><th width="106">필수 여부</th><th width="172">설명</th><th>제한</th></tr></thead><tbody><tr><td>title</td><td>string</td><td>X</td><td>카드의 제목입니다.</td><td>최대 50자 (케로셀인 경우, 최대 2줄)</td></tr><tr><td>description</td><td>string</td><td>X</td><td>카드에 대한 상세 설명입니다.</td><td>최대 230자 (케로셀인 경우, 최대 2줄)</td></tr><tr><td>thumbnail</td><td><a href="#thumbnail"><strong>Thumbnail</strong></a></td><td>O</td><td>카드의 상단 이미지입니다.</td><td></td></tr><tr><td>buttons</td><td>Array<br>&#x3C;<a href="#button"><strong>Button</strong></a>></td><td>X</td><td>카드의 버튼들을 포함합니다.</td><td>가로 정렬 시 최대 2개, 세로 정렬 시 최대 3개</td></tr><tr><td><a href="https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/answer_json_format#buttonlayout"><strong>buttonLayout</strong></a></td><td>string</td><td>X </td><td>버튼 정렬 정보입니다.</td><td></td></tr></tbody></table>

{% hint style="info" %}
**Information.**&#x20;

* 클라이언트에 따라 기준 글자수보다 적게 노출될 수도 있습니다.
* title과 description이 모두 사용될 경우 title은 검은색 description은 회색으로 노출됩니다.

  만약 title과 description중 1개만 사용된 경우 검은색으로 노출됩니다.
  {% endhint %}

### 예제 코드 <a href="#example_code" id="example_code"></a>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FWFarRwj8P8gVsldXsIbi%2Fskill-basiccard-example.png?alt=media&amp;token=58fdf23d-7dc5-401b-acc1-383b20f5062d" alt=""><figcaption></figcaption></figure>

```
{
  "version": "2.0",
  "template": {
    "outputs": [
      {
        "basicCard": {
          "title": "보물상자",
          "description": "보물상자 안에는 뭐가 있을까",
          "thumbnail": {
            "imageUrl": "https://t1.kakaocdn.net/openbuilder/sample/lj3JUcmrzC53YIjNDkqbWK.jpg"
          },
          "buttons": [
            {
              "action": "message",
              "label": "열어보기",
              "messageText": "짜잔! 우리가 찾던 보물입니다"
            },
            {
              "action":  "webLink",
              "label": "구경하기",
              "webLinkUrl": "https://e.kakao.com/t/hello-ryan"
            }
          ]
        }
      }
    ]
  }
}
```

## CommerceCard

커머스 카드형 출력 요소입니다. 커머스 카드는 제품에 대한 소개, 구매 안내 등을 사용자에게 전달할 수 있습니다. 커머스 카드는 제목과 설명 외에 썸네일 그룹, 프로필, 버튼 그룹, 가격 정보를 추가로 포함합니다.

### 상세 필드 <a href="#field_details" id="field_details"></a>

<table><thead><tr><th width="167">필드명</th><th>타입</th><th width="118">필수 여부</th><th width="154">설명</th><th>제한</th></tr></thead><tbody><tr><td>title</td><td>string</td><td>X</td><td>제품의 이름입니다.</td><td>최대 30자</td></tr><tr><td>description</td><td>string</td><td>X</td><td>제품에 대한 상세 설명입니다.</td><td>최대 40자</td></tr><tr><td>price</td><td>int</td><td>O</td><td>제품의 가격입니다.</td><td></td></tr><tr><td>currency</td><td>string</td><td>X</td><td>제품의 가격에 대한 통화입니다.</td><td>현재 <code>won</code>만 가능</td></tr><tr><td>discount</td><td>int</td><td>X</td><td>제품의 가격에 대한 할인할 금액입니다.</td><td></td></tr><tr><td>discountRate</td><td>int</td><td>X</td><td>제품의 가격에 대한 할인율입니다.</td><td></td></tr><tr><td>dicountedPrice</td><td>int</td><td>X (discountRate을 쓰는 경우 필수)</td><td>제품의 가격에 대한 할인가(할인된 가격)입니다.</td><td></td></tr><tr><td>thumbnails</td><td>Array<br>&#x3C;<a href="#thumbnail"><strong>Thumbnail</strong></a>></td><td>O</td><td>제품에 대한 사진입니다.</td><td>현재 1개만 가능</td></tr><tr><td>profile</td><td><a href="#profile"><strong>Profile</strong></a></td><td>X</td><td>제품을 판매하는 프로필 정보입니다.</td><td></td></tr><tr><td>buttons</td><td>Array<br>&#x3C;<a href="#button"><strong>Button</strong></a>></td><td>X</td><td>다양한 액션을 수행할 수 있는 버튼입니다.</td><td>가로 정렬 시 최대 2개, 세로 정렬 시 최대 3개</td></tr><tr><td><a href="https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/answer_json_format#buttonlayout"><strong>buttonLayout</strong></a></td><td>string</td><td>X</td><td>버튼 정렬 정보입니다.</td><td></td></tr></tbody></table>

{% hint style="info" %}
**Information.** **price, discount, discountedPrice 의 동작 방식**

* `discountedPrice` 가 존재하면 `price`, `discount`, `discountRate` 과 관계 없이 무조건 해당 값이 사용자에게 노출됩니다.
  * 예) `price`: 10000, `discount`: 7000, `discountedPrice`: 2000 인 경우, 3000 (10000 - 7000)이 아닌 2000이 사용자에게 노출
  * 위의 예에서 `discountedPrice`가 없는 경우, 3000이 사용자에게 노출
  * 예) `price`: 10000, `discountRate`: 70, `discountedPrice`: 2000 인 경우, 3000 (10000 \* 0.3)이 아닌 2000이 사용자에게 노출
* `discountRate`은 `discountedPrice`를 필요로 합니다. `discountedPrice`가 주어지지 않으면 사용자에게 >`discountRate`을 노출하지 않습니다.
* `discountRate`과 `discount`가 동시에 있는 경우, `discountRate`을 우선적으로 노출합니다.
  {% endhint %}

### 예제 코드 <a href="#example_code" id="example_code"></a>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FeLddoKxLWK6llXIE6pCp%2Fskill-commercecard-example.png?alt=media&amp;token=a3e1cae1-84ab-49b4-8126-e7bbd8224fac" alt=""><figcaption></figcaption></figure>

```
{
  "version": "2.0",
  "template": {
    "outputs": [
      {
        "commerceCard": {
          "title": "빈티지 목재 보물 상자 (Medium size)",
          "description": "이 보물 상자 안에는 무엇이 들어있을까요?",
          "price": 10000,
          "discount": 1000,
          "currency": "won",
          "thumbnails": [
            {
              "imageUrl": "https://t1.kakaocdn.net/openbuilder/sample/lj3JUcmrzC53YIjNDkqbWK.jpg",
              "link": {
                "web": "https://store.kakaofriends.com/kr/products/1542"
              }
            }
          ],
          "profile": {
            "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT4BJ9LU4Ikr_EvZLmijfcjzQKMRCJ2bO3A8SVKNuQ78zu2KOqM",
            "nickname": "라이언 스토어"
          },
          "buttons": [
            {
              "label": "구매하기",
              "action": "webLink",
              "webLinkUrl": "https://store.kakaofriends.com/kr/products/1542"
            },
            {
              "label": "전화하기",
              "action": "phone",
              "phoneNumber": "354-86-00070"
            },
            {
              "label": "공유하기",
              "action": "share"
            }
          ]
        }
      }
    ]
  }
}
```

{% hint style="warning" %}
**Tip.**

* '전화하기' 버튼은 PC 톡에서는 보이지 않습니다.
* 모든 말풍선을 제대로 확인하기 위해서는 모바일에서 확인하길 권장합니다.
  {% endhint %}

## ListCard

리스트 카드형 출력 요소입니다. 리스트 카드는 표현하고자 하는 대상이 다수일 때, 이를 효과적으로 전달할 수 있습니다. 헤더와 아이템을 포함하며, 헤더는 리스트 카드의 상단에 위치합니다. 리스트 상의 아이템은 각각의 구체적인 형태를 보여주며, 제목과 썸네일, 상세 설명을 포함합니다.

### 상세 필드 <a href="#field_details" id="field_details"></a>

<table><thead><tr><th width="145">필드명</th><th>타입</th><th>필수 여부</th><th width="119">설명</th><th>제한</th></tr></thead><tbody><tr><td>header</td><td><a href="#listitem_field_details"><strong>ListItem</strong></a></td><td>O</td><td>카드의 상단 항목</td><td></td></tr><tr><td>items</td><td>Array<br>&#x3C;<a href="#listitem_field_details"><strong>ListItem</strong></a>></td><td>O</td><td>카드의 각각 아이템</td><td><p>최대 5개 </p><p>케로셀형 : 최대 4개</p></td></tr><tr><td>buttons</td><td>Array<br>&#x3C;<a href="#button"><strong>Button</strong></a>></td><td>X</td><td></td><td>가로 정렬 시 최대 2개, 세로 정렬 시 최대 3개</td></tr><tr><td><a href="https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/answer_json_format#buttonlayout"><strong>buttonLayout</strong></a></td><td>string</td><td>X</td><td>버튼 정렬 정보입니다.</td><td></td></tr></tbody></table>

### ListItem 상세 필드 <a href="#listitem_field_details" id="listitem_field_details"></a>

<table><thead><tr><th width="141">필드명</th><th width="84">타입</th><th width="104">필수 여부</th><th>설명</th></tr></thead><tbody><tr><td>title</td><td>string</td><td>O</td><td><p></p><ul><li>header에 들어가는 경우, listCard의 제목이 됩니다.</li><li>items에 들어가는 경우, 해당 항목의 제목이 됩니다.</li></ul></td></tr><tr><td>description</td><td>string</td><td>X</td><td><p></p><ul><li>header에 들어가는 경우, 아무런 작동을 하지 않습니다.</li><li>items에 들어가는 경우, 해당 항목의 설명이 됩니다.</li></ul></td></tr><tr><td>imageUrl</td><td>string</td><td>X</td><td><p></p><ul><li>header에 들어가는 경우, 아무런 작동을 하지 않습니다.</li><li>items에 들어가는 경우, 해당 항목의 우측 안내 사진이 됩니다.</li></ul></td></tr><tr><td>link</td><td><a href="#link"><strong>Link</strong></a></td><td>X</td><td>클릭시 작동하는 링크입니다.</td></tr><tr><td>action</td><td>string</td><td>X</td><td><p></p><p>클릭시 수행될 작업입니다.</p><ul><li>action 종류: <code>block</code> or <code>message</code></li></ul></td></tr><tr><td>blockId</td><td>string</td><td>action: <code>block</code></td><td><p></p><ul><li>blockId를 갖는 블록을 호출합니다. (바로가기 응답의 블록 연결 기능과 동일)</li><li>items의 title이 사용자의 발화로 나가게 됩니다.</li></ul></td></tr><tr><td>messageText</td><td>string</td><td>action: <code>message</code></td><td><p></p><ul><li>사용자의 발화로 messageText를 내보냅니다. (바로가기 응답의 메세지 연결 기능과 동일)</li></ul></td></tr><tr><td>extra</td><td>Map&#x3C;String, Any></td><td>X</td><td><p></p><ul><li><code>block</code>이나 <code>message</code> action으로 블록 호출시, 스킬 서버에 추가적으로 제공하는 정보</li></ul></td></tr></tbody></table>

### 예제 코드 <a href="#example_code" id="example_code"></a>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FKsHXXLwOgKZvRVaKoNy9%2Fskill-listcard-example_02.jpg?alt=media&amp;token=6ae3db42-f40a-4339-9ffc-1844c2c2e36a" alt=""><figcaption></figcaption></figure>

```
{
  "version": "2.0",
  "template": {
    "outputs": [
      {
        "listCard": {
          "header": {
            "title": "챗봇 관리자센터를 소개합니다."
          },
          "items": [
            {
              "title": "챗봇 관리자센터",
              "description": "새로운 AI의 내일과 일상의 변화",
              "imageUrl": "https://t1.kakaocdn.net/openbuilder/sample/img_001.jpg",
              "link": {
                "web": "https://namu.wiki/w/%EB%9D%BC%EC%9D%B4%EC%96%B8(%EC%B9%B4%EC%B9%B4%EC%98%A4%ED%94%84%EB%A0%8C%EC%A6%88)"
              }
            },
            {
              "title": "챗봇 관리자센터",
              "description": "카카오톡 채널 챗봇 만들기",
              "imageUrl": "https://t1.kakaocdn.net/openbuilder/sample/img_002.jpg",
              "action": "block",
              "blockId": "62654c249ac8ed78441532de",
              "extra": {
                "key1": "value1",
                "key2": "value2"
              }
            },
            {
              "title": "Kakao i Voice Service",
              "description": "보이스봇 / KVS 제휴 신청하기",
              "imageUrl": "https://t1.kakaocdn.net/openbuilder/sample/img_003.jpg",
              "action": "message",
              "messageText": "Kakao i Voice Service",
              "extra": {
                "key1": "value1",
                "key2": "value2"
              }
            }
          ],
          "buttons": [
            {
              "label": "구경가기",
              "action": "block",
              "blockId": "62654c249ac8ed78441532de",
              "extra": {
                "key1": "value1",
                "key2": "value2"
              }
            }
          ]
        }
      }
    ]
  }
}
```

## ItemCard

itemCard (아이템 말풍선)는 메시지 목적에 따른 유관 정보들을 (가격 정보 포함) 사용자에게 일목요연한 리스트 형태로 전달할 수 있습니다. itemCard는 아이템리스트, 제목, 설명 외에 썸네일, 프로필, 헤드, 이미지타이틀, 버튼 그룹을 추가로 포함합니다.

케로셀 형태로 itemCard를 구현하기 위해서는 [**Carousel 도움말**](#carousel)을 함께 참조해주세요.

### 상세 필드 <a href="#field_details" id="field_details"></a>

<table><thead><tr><th width="143">필드명</th><th width="139">타입</th><th width="94">필수 여부</th><th width="154">설명</th><th>제한</th></tr></thead><tbody><tr><td>thumbnail</td><td><a href="#thumbnail_field_details"><strong>thumbnail</strong></a></td><td>X</td><td>상단 이미지입니다.</td><td><p></p><ul><li>단일형: 이미지 비율 2:1 (800*400), 1:1 (800*800)사용 가능</li><li>케로셀형: 이미지 비율 2:1 (800*400)만 사용 가능</li></ul></td></tr><tr><td>head</td><td><a href="#head_field_details"><strong>head</strong></a></td><td>X</td><td>헤드 정보입니다.</td><td><p></p><ul><li>head와 profile 두 필드를 동시에 노출할 수 없음</li><li>케로셀형: 카드별로 head와 profile을 섞어서 사용할 수 없음</li></ul></td></tr><tr><td>profile</td><td><a href="#profile_field_details"><strong>profile</strong></a></td><td>X</td><td>프로필 정보입니다.</td><td><p></p><ul><li>head와 profile 두 필드를 동시에 노출할 수 없음</li><li>케로셀형: 카드별로 head와 profile을 섞어서 사용할 수 없음</li></ul></td></tr><tr><td>imageTitle</td><td><a href="#imagetitle_field_details"><strong>imageTitle</strong></a></td><td>X</td><td>이미지를 동반하는 제목 및 설명 정보입니다.</td><td><p></p><ul><li>이미지 우측 정렬 고정 (위치 변경 불가)</li></ul></td></tr><tr><td>itemList</td><td>Array &#x3C;<a href="#itemlist_field_details"><strong>itemList</strong></a>></td><td>O</td><td>아이템 목록 정보입니다.</td><td><p></p><ul><li>좌측 정렬 디폴트</li><li>단일형: 최대 10개까지 사용 가능</li><li>케로셀형: 최대 5개까지 사용 가능</li></ul></td></tr><tr><td>itemListAlignment</td><td>string</td><td>X</td><td>itemList 및 itemListAlignment 정렬 정보입니다.</td><td><p></p><ul><li>"left" 혹은 "right"만 입력 가능</li></ul></td></tr><tr><td>itemListSummary</td><td><a href="#itemlistsummary_field_details"><strong>itemListSummary</strong></a></td><td>X</td><td>아이템 가격 정보입니다.</td><td><p></p><ul><li>itemListSummary 사용 시 itemListAlignment 우측 정렬을 권장</li></ul></td></tr><tr><td>title</td><td>string</td><td>X</td><td>타이틀 정보입니다.</td><td><p></p><ul><li>title과 description 합쳐서 글자수 제한</li></ul><p> - 단일형: 최대 200자&#x26;12줄</p><p> - 케로셀형: 최대 100자&#x26;12줄</p><ul><li>description을 넣는 경우, title이 필수 항목</li></ul></td></tr><tr><td>description</td><td>string</td><td>X</td><td>설명 정보입니다.</td><td><p></p><p></p><ul><li>title과 description 합쳐서 글자수 제한</li></ul><p> - 단일형: 최대 200자&#x26;12줄</p><p> - 케로셀형: 최대 100자&#x26;12줄</p><ul><li>description을 넣는 경우, title이 필수 항목</li></ul></td></tr><tr><td>buttons</td><td>Array&#x3C; <a href="#button"><strong>Button</strong></a>></td><td>X</td><td>다양한 액션을 수행할 수 있는 버튼 정보입니다.</td><td>가로 정렬 시 최대 2개, 세로 정렬 시 최대 3개</td></tr><tr><td><a href="https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/answer_json_format#buttonlayout"><strong>buttonLayout</strong></a></td><td>string</td><td>X</td><td>버튼 정렬 정보입니다.</td><td></td></tr></tbody></table>

### thumbnail 상세 필드 <a href="#thumbnail_field_details" id="thumbnail_field_details"></a>

<table><thead><tr><th width="135">필드명</th><th width="118">타입</th><th width="96">필수 여부</th><th>설명</th><th>제한</th></tr></thead><tbody><tr><td>imageUrl</td><td>string</td><td>O</td><td>이미지의 url 정보입니다.</td><td>URL 형식</td></tr><tr><td>altText</td><td>string</td><td>X</td><td>디바이스에 스크린 리더 기능이 켜져있을 때 재생되는 대체텍스트입니다.</td><td>최대 50자</td></tr><tr><td>width</td><td>int</td><td>X</td><td>이미지의 넓이 정보입니다.</td><td><p>설정하지 않은 경우 이미지가 1:1 비율로 노출됩니다.</p><ol><li>단일형: 이미지 비율 2:1 (800*400), 1:1 (800*800)사용 가능</li><li>케로셀형: 이미지 비율 2:1 (800*400)만 사용 가능</li></ol></td></tr><tr><td>height</td><td>int</td><td>X</td><td>이미지의 높이 정보입니다.</td><td><p>설정하지 않은 경우 이미지가 1:1 비율로 노출됩니다.</p><ol><li>단일형: 이미지 비율 2:1 (800*400), 1:1 (800*800)사용 가능</li><li>케로셀형: 이미지 비율 2:1 (800*400)만 사용 가능</li></ol></td></tr><tr><td>link</td><td><a href="#link"><strong>Link</strong></a></td><td>X</td><td>이미지 클릭 시 작동하는 link입니다.</td><td></td></tr></tbody></table>

### head 상세 필드 <a href="#head_field_details" id="head_field_details"></a>

<table><thead><tr><th width="134">필드명</th><th width="120">타입</th><th width="96">필수 여부</th><th>설명</th><th>제한</th></tr></thead><tbody><tr><td>title</td><td>string</td><td>O</td><td>헤드의 타이틀 정보입니다.</td><td><p></p><ul><li>최대 1 줄 (한 줄에 들어갈 수 있는 글자수는 기기 별로 상이)</li></ul></td></tr></tbody></table>

### profile 상세 필드 <a href="#profile_field_details" id="profile_field_details"></a>

<table><thead><tr><th width="135">필드명</th><th>타입</th><th>필수 여부</th><th>설명</th><th>제한</th></tr></thead><tbody><tr><td>imageUrl</td><td>string</td><td>X</td><td>프로필 이미지 정보입니다.</td><td><p></p><ul><li>URL 형식</li></ul></td></tr><tr><td>width</td><td>int</td><td>X</td><td>프로필 이미지의 넓이 정보입니다.</td><td><p></p><ul><li>1:1 비율에 맞게 입력 필요</li><li>실제 이미지 사이즈와 다른 값일 경우 원본 이미지와 다르게 표현될 수 있음</li></ul></td></tr><tr><td>height</td><td>int</td><td>X</td><td>프로필 이미지의 높이 정보입니다.</td><td><p></p><ul><li>1:1 비율에 맞게 입력 필요</li><li>실제 이미지 사이즈와 다른 값일 경우 원본 이미지와 다르게 표현될 수 있음</li></ul></td></tr><tr><td>title</td><td>string</td><td>O</td><td>프로필 타이틀 정보입니다.</td><td><p></p><ul><li>최대 15글자</li></ul></td></tr></tbody></table>

### imageTitle 상세 필드 <a href="#imagetitle_field_details" id="imagetitle_field_details"></a>

<table><thead><tr><th width="142">필드명</th><th>타입</th><th>필수 여부</th><th>설명</th><th>제한</th></tr></thead><tbody><tr><td>title</td><td>string</td><td>O</td><td>이미지타이틀의 제목 정보입니다.</td><td><p></p><ul><li>최대 2줄 (한 줄에 들어갈 수 있는 글자수는 기기 별로 상이)</li></ul></td></tr><tr><td>description</td><td>string</td><td>X</td><td>이미지타이틀의 설명 정보입니다.</td><td><p></p><ul><li>최대 1줄 (한 줄에 들어갈 수 있는 글자수는 기기 별로 상이)</li></ul></td></tr><tr><td>imageUrl</td><td>string</td><td>X</td><td>이미지타이틀의 이미지 URL입니다.</td><td><p></p><ul><li>URL 형식</li><li>최적이미지 사이즈 iOS 108 x 108, 안드로이드 98 x 98 (맞지 않는 경우 센터크롭됨)</li></ul></td></tr></tbody></table>

### itemList 상세 필드 <a href="#itemlist_field_details" id="itemlist_field_details"></a>

<table><thead><tr><th width="143">필드명</th><th>타입</th><th>필수 여부</th><th>설명</th><th>제한</th></tr></thead><tbody><tr><td>title</td><td>string</td><td>O</td><td>아이템 제목 정보입니다.</td><td><p></p><ul><li>최대 6자</li></ul></td></tr><tr><td>description</td><td>string</td><td>O</td><td>아이템 설명 정보입니다.</td><td><p></p><ul><li>최대 2줄 (한 줄에 들어갈 수 있는 글자수는 기기 별로 상이)</li></ul></td></tr></tbody></table>

### itemListSummary 상세 필드 <a href="#itemlistsummary_field_details" id="itemlistsummary_field_details"></a>

<table><thead><tr><th width="144"> 필드명</th><th>타입</th><th>필수 여부</th><th>설명</th><th>제한</th></tr></thead><tbody><tr><td>title</td><td>string</td><td>O</td><td>아이템리스트 전체에 대한 제목 정보입니다.</td><td><p></p><ul><li>최대 6자</li></ul></td></tr><tr><td>description</td><td>string</td><td>O</td><td>아이템리스트 전체에 대한 설명 정보입니다.</td><td><p></p><ul><li>최대 14자 (통화기호/문자, 숫자, 콤마, 소수점, 띄어쓰기 포함)</li></ul><p> - 문자는 통화 문자만 사용 가능</p><p> - 소수점 두자리까지 사용 가능</p></td></tr></tbody></table>

### ItemCard 유의사항 <a href="#example_code" id="example_code"></a>

※ 도움말에서 제공하는 제한 및 유의사항을 확인 및 준수하여 말풍선을 구성해주시길 바랍니다. 이에 맞지 않게 말풍선을 사용하는 경우, 말풍선이 정상적으로 발송되지 않거나 챗봇 이용제한이 이루어질 수 있습니다.

**\* ItemCard 케로셀형에서는 thumbnail, head, profile, imageTitle 필드에 한해 몇몇 케로셀 카드에만 필드를 선택 적용하는 것이 불가능하며 일괄 적용해야 합니다. 다음 이미지를 참고해주세요.**

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FhTFpdvlsoOov9PAXGixO%2FitemCard_carousel.png?alt=media&amp;token=4c45701a-7ecd-4313-b7bc-2efb14f16e01" alt=""><figcaption></figcaption></figure>

**\* itemCard에서** [**share action**](https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/answer_json_format#button)**을 사용하는 경우, 일부 필드만이 공유됩니다.**&#x20;

> &#x20;\- [head](https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/answer_json_format#head_field_details)와 [itemList](https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/answer_json_format#itemlist_field_details) 필드는 전달되지 않습니다.\
> &#x20;\- [imageTitle](https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/answer_json_format#imagetitle_field_details) 필드와 [title 및 description](https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/answer_json_format#field_details-7:~:text=%EC%9A%B0%EC%B8%A1%20%EC%A0%95%EB%A0%AC%EC%9D%84%20%EA%B6%8C%EC%9E%A5-,title,-string) 필드는 동시에 공유될 수 없습니다. 두 필드가 함께 존재하는 경우에는 [title 및 description](https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/answer_json_format#field_details-7:~:text=%EC%9A%B0%EC%B8%A1%20%EC%A0%95%EB%A0%AC%EC%9D%84%20%EA%B6%8C%EC%9E%A5-,title,-string) 필드가 공유됩니다.&#x20;
>
> \- [imageTitle](https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/answer_json_format#imagetitle_field_details) 필드가 공유되는 경우, imageTitle 내 thumbnail은 공유되지 않습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F0zTxVWXDQqXHHTrkIpPD%2FitemCard_share.png?alt=media&amp;token=06dbacb7-e32c-469f-9774-c7d825628cbb" alt=""><figcaption></figcaption></figure>

### 예제코드 <a href="#example_code" id="example_code"></a>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fjd0TFmGNEu6SZFAd6W9b%2F%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%90%E1%85%A6%E1%86%B7%E1%84%83%E1%85%A1%E1%86%AB%E1%84%8B%E1%85%B5%E1%86%AF.png?alt=media&amp;token=14e4b7cd-76d5-4379-94e7-7f211b364b8e" alt=""><figcaption><p>아이템 단일형 말풍선 예제</p></figcaption></figure>

```
{
    "version": "2.0",
    "template": {
        "outputs": [
            {
                "itemCard": {
                    "imageTitle": {
                        "title": "DOFQTK",
                        "description": "Boarding Number"
                    },
                    "title": "",
                    "description": "",
                    "thumbnail": {
                        "imageUrl": "http://dev-mk.kakao.com/dn/bot/scripts/with_barcode_blue_1x1.png",
                        "width": 800,
                        "height": 800
                    },
                    "profile": {
                        "title": "AA Airline",
                        "imageUrl": "https://t1.kakaocdn.net/openbuilder/docs_image/aaairline.jpg"
                    },
                    "itemList": [
                        {
                            "title": "Flight",
                            "description": "KE0605"
                        },
                        {
                            "title": "Boards",
                            "description": "8:50 AM"
                        },
                        {
                            "title": "Departs",
                            "description": "9:50 AM"
                        },
                        {
                            "title": "Terminal",
                            "description": "1"
                        },
                        {
                            "title": "Gate",
                            "description": "C24"
                        }
                    ],
                    "itemListAlignment" : "right",
                    "itemListSummary": {
                        "title": "Total",
                        "description": "$4,032.54"
                    },
                    "buttons": [
                        {
                            "label": "View Boarding Pass",
                            "action": "webLink",
                            "webLinkUrl": "https://namu.wiki/w/%EB%82%98%EC%97%B0(TWICE)"
                        }
                    ],
                    "buttonLayout" : "vertical"
                }
            }
        ]
    }
}
```

## Carousel

케로셀은 여러 장의 카드를 하나의 메세지에 일렬로 포함하는 타입입니다.

※ 하나의 케로셀 내에서는 모든 이미지를 동일 크기로 설정해야 합니다. 즉, 케로셀 내 모든 이미지가 정사각형 (1:1) 혹은 모든 이미지가 와이드형 (2:1)으로 통일되어야 합니다.

### 상세 필드 <a href="#field_details" id="field_details"></a>

<table><thead><tr><th width="105">필드명</th><th width="227">타입</th><th width="96">필수 여부</th><th width="126">설명</th><th>제한</th></tr></thead><tbody><tr><td>type</td><td>string</td><td>O</td><td>케로셀의 타입입니다.</td><td>basicCard 혹은 commerceCard, listCard, itemCard</td></tr><tr><td>items</td><td><p>Array&#x3C;<a href="#textcard"><strong>TextCard</strong></a>>, </p><p>Array&#x3C;<a href="#basiccard"><strong>BasicCard</strong></a>>, </p><p>Array&#x3C;<a href="#commercecard"><strong>CommerceCard</strong></a>>, Array&#x3C;<a href="#listcard"><strong>ListCard</strong></a>>, Array&#x3C;<a href="#itemcard"><strong>itemCard</strong></a>></p></td><td>O</td><td>케로셀 아이템입니다.</td><td>최대 10개 *ListCard는 최대 5개</td></tr><tr><td>header</td><td><a href="#carouselheader"><strong>CarouselHeader</strong></a></td><td>X</td><td>케로셀의 커버를 제공합니다.</td><td>*TextCard 및 ListCard는 케로셀헤더를 지원하지 않습니다.</td></tr></tbody></table>

※ 카드별 자세한 제한사항은 각 카드 설명 내 제한/ 유의사항을 확인해주세요. 제한 및 유의사항을 따르지 않는 경우, 말풍선이 정상적으로 동작하지 않을 수 있습니다.

* [**TextCard**](#textcard)
* [**BasicCard**](#basiccard)
* [**CommerceCard**](#commercecard)
* [**ListCard**](#listcard)
* [**itemCard**](#itemcard)&#x20;

### 예제 코드 <a href="#example_code" id="example_code"></a>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FFNozuocVu1AlkUQbT56Z%2Fskill-outputs-carousel-example-1.jpg?alt=media&amp;token=11ae0946-5e16-423e-af66-8bf2934d4206" alt=""><figcaption><p>기본 카드형 케로셀 예제</p></figcaption></figure>

```
{
  "version": "2.0",
  "template": {
    "outputs": [
      {
        "carousel": {
          "type": "basicCard",
          "items": [
            {
              "title": "보물상자",
              "description": "보물상자 안에는 뭐가 있을까",
              "thumbnail": {
                "imageUrl": "https://t1.kakaocdn.net/openbuilder/sample/lj3JUcmrzC53YIjNDkqbWK.jpg"
              },
              "buttons": [
                {
                  "action": "message",
                  "label": "열어보기",
                  "messageText": "짜잔! 우리가 찾던 보물입니다"
                },
                {
                  "action":  "webLink",
                  "label": "구경하기",
                  "webLinkUrl": "https://e.kakao.com/t/hello-ryan"
                }
              ]
            },
            {
              "title": "보물상자2",
              "description": "보물상자2 안에는 뭐가 있을까",
              "thumbnail": {
                "imageUrl": "https://t1.kakaocdn.net/openbuilder/sample/lj3JUcmrzC53YIjNDkqbWK.jpg"
              },
              "buttons": [
                {
                  "action": "message",
                  "label": "열어보기",
                  "messageText": "짜잔! 우리가 찾던 보물입니다"
                },
                {
                  "action":  "webLink",
                  "label": "구경하기",
                  "webLinkUrl": "https://e.kakao.com/t/hello-ryan"
                }
              ]
            },
            {
              "title": "보물상자3",
              "description": "보물상자3 안에는 뭐가 있을까",
              "thumbnail": {
                "imageUrl": "https://t1.kakaocdn.net/openbuilder/sample/lj3JUcmrzC53YIjNDkqbWK.jpg"
              },
              "buttons": [
                {
                  "action": "message",
                  "label": "열어보기",
                  "messageText": "짜잔! 우리가 찾던 보물입니다"
                },
                {
                  "action":  "webLink",
                  "label": "구경하기",
                  "webLinkUrl": "https://e.kakao.com/t/hello-ryan"
                }
              ]
            }
          ]
        }
      }
    ]
  }
}
```

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FWVILJL47NhGyQVnwswAm%2F%E1%84%85%E1%85%B5%E1%84%89%E1%85%B3%E1%84%90%E1%85%B3%E1%84%8F%E1%85%A6%E1%84%85%E1%85%A9%E1%84%89%E1%85%A6%E1%86%AF.png?alt=media&amp;token=4c276c13-2173-400e-8aaf-efe15dbaf97a" alt=""><figcaption><p>리스트형 케로셀 예제</p></figcaption></figure>

```
{
  "version": "2.0",
  "template": {
    "outputs": [
      {
        "carousel": {
          "type": "listCard",
          "items": [
            {
              "header": {
                "title": "샌드위치"
              },
              "items": [
                {
                  "title": "햄치즈",
                  "description": "4,500원",
                  "imageUrl": "https://t1.kakaocdn.net/openbuilder/docs_image/02_img_01.jpg"
                },
                {
                  "title": "베이컨 아보카도",
                  "description": "5,500원",
                  "imageUrl": "https://t1.kakaocdn.net/openbuilder/docs_image/02_img_02.jpg"
                },
                {
                  "title": "에그 포테이토",
                  "description": "5,300원",
                  "imageUrl": "https://t1.kakaocdn.net/openbuilder/docs_image/02_img_03.jpg"
                },
                {
                  "title": "갈릭 베이컨 토마토",
                  "description": "5,800원",
                  "imageUrl": "https://t1.kakaocdn.net/openbuilder/docs_image/02_img_04.jpg"
                }
              ],
              "buttons": [
                {
                  "label": "더보기",
                  "action": "message",
                  "messageText" : "샌드위치 더보기"
                }
              ]
            },
            {
              "header": {
                "title": "커피"
              },
              "items": [
                {
                  "title": "아메리카노",
                  "description": "1,800원",
                  "imageUrl": "https://t1.kakaocdn.net/openbuilder/docs_image/02_img_05.jpg"
                },
                {
                  "title": "카페라떼",
                  "description": "2,000원",
                  "imageUrl": "https://t1.kakaocdn.net/openbuilder/docs_image/02_img_06.jpg"
                },
                {
                  "title": "카페모카",
                  "description": "2,500원",
                  "imageUrl": "https://t1.kakaocdn.net/openbuilder/docs_image/02_img_07.jpg"
                },
                {
                  "title": "소이라떼",
                  "description": "2,200원",
                  "imageUrl": "https://t1.kakaocdn.net/openbuilder/docs_image/02_img_08.jpg"
                }
              ],
              "buttons": [
                {
                  "label": "더보기",
                  "action": "message",
                  "messageText" : "커피 더보기"
                }
              ]
            }
          ]
        }
      }
    ],
    "quickReplies": [
      {
        "messageText": "인기 메뉴",
        "action": "message",
        "label": "인기 메뉴"
      },
      {
        "messageText": "최근 주문",
        "action": "message",
        "label": "최근 주문"
      },
      {
        "messageText": "장바구니",
        "action": "message",
        "label": "장바구니"
      }
    ]
  }
}
```

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FbLe5JP6U97Z82c4RlE0S%2F%E1%84%8B%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%90%E1%85%A6%E1%86%B7%E1%84%8F%E1%85%A6%E1%84%85%E1%85%A9%E1%84%89%E1%85%A6%E1%86%AF.png?alt=media&amp;token=43cf0a04-864a-4e44-8fad-de91ad880267" alt=""><figcaption><p>아이템형 케로셀 예제</p></figcaption></figure>

```
{
  "version": "2.0",
  "template": {
    "outputs": [
        {
            "simpleText": {
                "text": "총 2개의 예약 내역이 있습니다. 취소할 예약을 선택해 주세요."
            }
          },
      {
        "carousel": {
          "type": "itemCard",
          "items": [
            {
              "imageTitle": {
                "title": "예약 완료",
                "imageUrl" : "https://t1.kakaocdn.net/openbuilder/docs_image/wine.jpg"
              },
              "itemList": [
                {
                  "title": "매장명",
                  "description": "판교 A스퀘어점"
                },
                {
                  "title": "예약 일시",
                  "description": "2022.12.25, 19:30"
                },
                {
                  "title" : "예약 인원",
                  "description" : "4명"
                },
                {
                  "title" : "예약금",
                  "description" : "40,000원 (결제 완료)"
                }
              ],
              "itemListAlignment": "left",
              "buttons": [
                {
                  "label": "예약 정보",
                  "action": "message",
                  "messageText" : "예약 정보"
                },
                {
                  "label": "예약 취소",
                  "action": "message",
                  "messageText": "예약 취소"
                }
              ]
            },
            {
              "imageTitle": {
                "title": "결제 대기",
                "imageUrl": "https://t1.kakaocdn.net/openbuilder/docs_image/pizza.jpg"
              },
              "itemList": [
                {
                  "title": "매장명",
                  "description": "정자역점"
                },
                {
                  "title": "예약 일시",
                  "description": "2022.12.25, 19:25"
                },
                {
                  "title" : "예약 인원",
                  "description" : "3명"
                },
                {
                  "title" : "예약금",
                  "description" : "30,000원 (결제 대기)"
                }
              ],
              "itemListAlignment": "left",
              "buttons": [
                {
                  "label": "예약 취소",
                  "action": "message",
                  "messageText" : "예약 취소"
                },
                {
                  "label": "결제",
                  "action": "message",
                  "messageText": "결제"
                }
              ]
            }
          ]
        }
      }
    ],
    "quickReplies": [
      {
        "messageText": "인기 메뉴",
        "action": "message",
        "label": "인기 메뉴"
      },
      {
        "messageText": "최근 주문",
        "action": "message",
        "label": "최근 주문"
      },
      {
        "messageText": "장바구니",
        "action": "message",
        "label": "장바구니"
      }
    ]
  }
}
```

## 공통 <a href="#in_common" id="in_common"></a>

### Thumbnail

<table><thead><tr><th width="162">필드명</th><th width="136">타입</th><th width="123">필수 여부</th><th>설명</th></tr></thead><tbody><tr><td>imageUrl</td><td>string</td><td>O</td><td>이미지의 url입니다.</td></tr><tr><td>altText</td><td>string</td><td>X</td><td>디바이스에 스크린 리더 기능이 켜져있을 때 재생되는 대체텍스트입니다. (최대 50자)</td></tr><tr><td>link</td><td><a href="#link"><strong>Link</strong></a></td><td>X</td><td>이미지 클릭시 작동하는 link입니다.</td></tr><tr><td>fixedRatio</td><td>boolean</td><td>X</td><td><ul><li>true: 이미지 영역을 1:1 비율로 두고 이미지의 원본 비율을 유지합니다. 이미지가 없는 영역은 흰색으로 노출합니다. 버튼이 가로로 배열되며 최대 2개로 제한됩니다.</li><li>false: 이미지 영역을 2:1 비율로 두고 이미지의 가운데를 크롭하여 노출합니다. 버튼이 세로로 배열되며 최대 3개 노출됩니다. 기본값: false</li></ul><p>※ 케로셀 내에서는 모든 이미지가 정사각형 (1:1) 혹은 모든 이미지가 와이드형 (2:1)으로 통일되어야 합니다.</p></td></tr></tbody></table>

### Button

<table><thead><tr><th width="129">필드명</th><th>타입</th><th>필수 여부</th><th>설명</th><th>제한</th></tr></thead><tbody><tr><td>label</td><td>string</td><td>O</td><td>버튼에 적히는 문구입니다.</td><td><p></p><p>버튼 14자(가로배열 2개 8자)</p><ul><li>썸네일이 1:1이면 버튼이 가로배열 됩니다.</li></ul></td></tr><tr><td>action</td><td>string</td><td>O</td><td>버튼 클릭시 수행될 작업입니다.</td><td></td></tr><tr><td>webLinkUrl</td><td>string</td><td>action: <code>webLink</code></td><td>웹 브라우저를 열고 webLinkUrl 의 주소로 이동합니다.</td><td>URL</td></tr><tr><td>messageText</td><td>string</td><td>action: <code>message</code> or <code>block</code></td><td><p></p><ul><li>message: 사용자의 발화로 messageText를 내보냅니다. (바로가기 응답의 메세지 연결 기능과 동일)</li><li>block: 블록 연결시 사용자의 발화로 노출됩니다.</li></ul></td><td></td></tr><tr><td>phoneNumber</td><td>string</td><td>action: <code>phone</code></td><td>phoneNumber에 있는 번호로 전화를 겁니다.</td><td>전화번호</td></tr><tr><td>blockId</td><td>string</td><td>action: <code>block</code></td><td>blockId를 갖는 블록을 호출합니다. (바로가기 응답의 블록 연결 기능과 동일)</td><td>존재하는 블록 id</td></tr><tr><td>extra</td><td>Map&#x3C;String, Any></td><td></td><td><code>block</code>이나 <code>message</code> action으로 블록 호출시, 스킬 서버에 추가적으로 제공하는 정보</td><td></td></tr></tbody></table>

{% hint style="info" %}
**Information.** **action 종류**

* `webLink`: 웹 브라우저를 열고 webLinkUrl 의 주소로 이동합니다.
* `message`: 사용자의 발화로 messageText를 실행합니다. (바로가기 응답의 메세지 연결 기능과 동일)
* `phone`: phoneNumber에 있는 번호로 전화를 겁니다.
* `block`: blockId를 갖는 블록을 호출합니다. (바로가기 응답의 블록 연결 기능과 동일)
* messageText가 있다면, 해당 messageText가 사용자의 발화로 나가게 됩니다.
* messageText가 없다면, button의 label이 사용자의 발화로 나가게 됩니다.
* `share`: 말풍선을 다른 유저에게 공유합니다. share action은 특히 케로셀을 공유해야 하는 경우 유용합니다.
* `operator` : 상담 연결 기능을 제공합니다.

  &#x20;링크: [**상담 연결 플러그인**](/main/tool/chatbot/main_notions/plugin.md#contact_staff)
  {% endhint %}

### **buttonLayout**

<table><thead><tr><th>필드명</th><th width="149">타입</th><th width="149">필수 여부</th><th width="150">설명</th><th>제한</th></tr></thead><tbody><tr><td>buttonLayout</td><td>string</td><td>X</td><td>버튼 정렬 정보입니다.</td><td><p></p><ul><li>"vertical": 최대 3개 &#x26; 세로 배치</li><li>"horizontal": 최대 2개 &#x26; 가로 배치</li></ul></td></tr></tbody></table>

#### 예제 코드

```
{
  "version": "2.0",
  "template": {
    "outputs": [
      {
        "textCard": {
          "title": "챗봇 관리자센터에 오신 것을 환영합니다.",
          "description": "챗봇 관리자센터로 챗봇을 제작해 보세요. \n카카오톡 채널과 연결하여, 이용자에게 챗봇 서비스를 제공할 수 있습니다.",
          "buttons": [
            {
              "action": "webLink",
              "label": "소개 보러가기",
              "webLinkUrl": "https://chatbot.kakao.com/docs/getting-started-overview/"
            },
            {
              "action": "webLink",
              "label": "챗봇 만들러 가기",
              "webLinkUrl": "https://chatbot.kakao.com/"
            }
          ],
          "buttonLayout": "horizontal"
        }
      }
    ]
  }
}
```

{% hint style="info" %}
**Information.**

* buttonLayout 필드와 Thumbnail의 fixedRatio 필드를 동시에 사용하는 경우, 버튼 정렬은 buttonLayout 값을 따릅니다.

예) BasicCard에서 fixedRatio: true & buttonLayout: vertical로 설정한 경우, 이미지가 정방형으로 노출되고 버튼이 세로로 정렬됨.
{% endhint %}

### Forwardable

<table><thead><tr><th width="143">필드명</th><th>타입</th><th width="109">필수 여부</th><th>설명</th><th>제한</th></tr></thead><tbody><tr><td>forwardable</td><td>boolean</td><td>X</td><td>말풍선에 전달하기 아이콘을 노출합니다.</td><td><p><a href="/main/tool/chatbot/main_notions/setup_answer.md#setting_deliver_function"><strong>전달하기 아이콘</strong></a>다음 조건에서는 <a href="broken://pages/YmqLI19IYcbXFWKokyK1#setting_deliver_function"><strong>전달하기 아이콘</strong></a>이 노출되지 않습니다.<br></p><p>-케로셀인 경우</p><p>-버튼이 포함된 경우</p><p>-listCard의 Listitem에 link 또는 action을 사용한 경우</p></td></tr></tbody></table>

#### 예제 코드

```
{
  "version": "2.0",
  "template": {
    "outputs": [
      {
        "basicCard": {
          "title": "보물상자",
          "description": "보물상자 안에는 뭐가 있을까",
          "thumbnail": {
            "imageUrl": "https://t1.kakaocdn.net/openbuilder/sample/lj3JUcmrzC53YIjNDkqbWK.jpg"
          },
          "profile": {
            "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT4BJ9LU4Ikr_EvZLmijfcjzQKMRCJ2bO3A8SVKNuQ78zu2KOqM",
            "nickname": "보물상자"
          },
          "forwardable": true
        }
      }
    ]
  }
}
```

### Link

<table><thead><tr><th width="112">필드명</th><th width="104">타입</th><th width="108">필수 여부</th><th>설명</th></tr></thead><tbody><tr><td>pc</td><td>string</td><td>X</td><td>pc의 웹을 실행하는 link입니다.</td></tr><tr><td>mobile</td><td>string</td><td>X</td><td>mobile의 웹을 실행하는 link입니다.</td></tr><tr><td>web</td><td>string</td><td>X</td><td>모든 기기에서 웹을 실행하는 link입니다.</td></tr></tbody></table>

{% hint style="info" %}
**Information.** **링크 우선순위** 링크는 다음과 같은 우선순위를 갖습니다.

* pc: pc < web
* 모바일: mobile < web

예를 들면, pc에 대하여 링크 값이 webURL, pcURL를 가지면 위 규칙에 따라 webURL이 노출됩니다.\
모바일 기기에 대하여 Link의 값이 webURL, mobileURL를 가지면 위 규칙에 따라 webURL이 노출됩니다.
{% endhint %}

### CarouselHeader

#### 상세 필드 <a href="#detail_field" id="detail_field"></a>

<table><thead><tr><th width="138">필드명</th><th width="123">타입</th><th width="113">필수 여부</th><th>설명</th><th>제한</th></tr></thead><tbody><tr><td>title</td><td>string</td><td>O</td><td>케로셀 헤드 제목</td><td>최대 2줄 (한 줄에 들어갈 수 있는 글자 수는 기기에 따라 달라집니다.)</td></tr><tr><td>description</td><td>string</td><td>O</td><td>케로셀 헤드 제목</td><td>최대 3줄 (한 줄에 들어갈 수 있는 글자 수는 기기에 따라 달라집니다.)</td></tr><tr><td>thumbnail</td><td><a href="#thumbnail"><strong>Thumbnail</strong></a></td><td>O</td><td>케로셀 헤드 배경 이미지</td><td>현재 imageUrl 값만 지원합니다.</td></tr></tbody></table>

#### 예제 코드 <a href="#example_code" id="example_code"></a>

```
{
  "version": "2.0",
  "template": {
    "outputs": [
      {
        "carousel": {
          "type": "commerceCard",
          "header": {
            "title": "커머스 카드\n케로셀 헤드 예제",
            "description": "케로셀 헤드 예제입니다.",
            "thumbnail": {
              "imageUrl": "https://t1.kakaocdn.net/openbuilder/sample/lj3JUcmrzC53YIjNDkqbWK.jpg"
            }
          },
          "items": [
            {
              "description": "따끈따끈한 보물 상자 팝니다",
              "price": 10000,
              "discount": 1000,
              "currency": "won",
              "thumbnails": [
                {
                  "imageUrl": "https://t1.kakaocdn.net/openbuilder/sample/lj3JUcmrzC53YIjNDkqbWK.jpg",
                  "link": {
                    "web": "https://store.kakaofriends.com/kr/products/1542"
                  }
                }
              ],
              "profile": {
                "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT4BJ9LU4Ikr_EvZLmijfcjzQKMRCJ2bO3A8SVKNuQ78zu2KOqM",
                "nickname": "보물상자 팝니다"
              },
              "buttons": [
                {
                  "label": "구매하기",
                  "action": "webLink",
                  "webLinkUrl": "https://store.kakaofriends.com/kr/products/1542"
                },
                {
                  "label": "전화하기",
                  "action": "phone",
                  "phoneNumber": "354-86-00070"
                },
                {
                  "label": "공유하기",
                  "action": "share"
                }
              ]
            },
            {
              "description": "따끈따끈한 보물 상자 팝니다",
              "price": 10000,
              "discount": 1000,
              "currency": "won",
              "thumbnails": [
                {
                  "imageUrl": "https://t1.kakaocdn.net/openbuilder/sample/lj3JUcmrzC53YIjNDkqbWK.jpg",
                  "link": {
                    "web": "https://store.kakaofriends.com/kr/products/1542"
                  }
                }
              ],
              "profile": {
                "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT4BJ9LU4Ikr_EvZLmijfcjzQKMRCJ2bO3A8SVKNuQ78zu2KOqM",
                "nickname": "보물상자 팝니다"
              },
              "buttons": [
                {
                  "label": "구매하기",
                  "action": "webLink",
                  "webLinkUrl": "https://store.kakaofriends.com/kr/products/1542"
                },
                {
                  "label": "전화하기",
                  "action": "phone",
                  "phoneNumber": "354-86-00070"
                },
                {
                  "label": "공유하기",
                  "action": "share"
                }
              ]
            }
          ]
        }
      }
    ]
  }
}
```

### Profile

<table><thead><tr><th width="138">필드명</th><th>타입</th><th>필수 여부</th><th>설명</th><th>제한</th></tr></thead><tbody><tr><td>nickname</td><td>string</td><td>O</td><td>프로필 이름</td><td></td></tr><tr><td>imageUrl</td><td>string</td><td>X</td><td>프로필 이미지</td><td></td></tr></tbody></table>

{% hint style="success" %}
**TIP!**

이미지 사이즈는 180px X 180px 추천합니다.
{% endhint %}

## QuickReplies

바로가기 응답은 발화와 동일합니다. 대신, 사용자가 직접 발화를 입력하지 않아도 선택을 통해서 발화를 전달하거나 다른 블록을 호출할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F3RsOqdAR729DdCKFoNCG%2Fskill-quickreplies-example-02.webp?alt=media&amp;token=c39d6b12-4a68-4bc7-8943-f029739c653a" alt=""><figcaption><p>바로가기 응답 예시</p></figcaption></figure>

제한적 선택지를 가진 응답이거나, 다음 발화에 대한 힌트를 줄 필요가 있을 때 바로가기 응답을 사용하면 유용합니다.

### 종류 <a href="#type" id="type"></a>

바로가기 응답은 현재 두 가지 기능을 제공합니다.

#### 메세지 연결 기능 <a href="#connect_message_function" id="connect_message_function"></a>

바로가기 응답에서 메시지 연결 기능은 발화를 입력하는 것과 동일합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FwdcQnZiBtVTzy4kRSsa9%2Fskill-quickreplies-message-example-01.png?alt=media&amp;token=b5b1cda7-efe5-4d81-bed4-8fd1aed399b4" alt=""><figcaption><p>바로가기 응답(메시지 기능)을 이용한 간단한 메시지형 응답</p></figcaption></figure>

라이언 ‘바로가기 응답’은 버튼 위에 ‘라이언’이라는 문자가 적혀있지만, 실제 클릭시 ‘라이언 알아보기’라는 발화로 대화창에 나가게 됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fc4TxyPgxNrbM8W5QOI2X%2Fskill-quickreplies-message-example-02.webp?alt=media&amp;token=54297aa1-8250-4781-8648-3dafea09b3bc" alt=""><figcaption><p>바로가기 응답을 이용하여 블록을 호출한 경우</p></figcaption></figure>

바로가기 응답을 사용하지 않고 사용자가 직접 ‘라이언 알아보기’를 입력해도, 해당 발화를 인식하는 블록이 실제로 존재하기 때문에 동일한 출력이 노출됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fg6b1QpUCHlLoaz0TM4PR%2Fskill-quickreplies-message-example-03.png?alt=media&amp;token=97685d03-a4c3-4e34-b645-01ce7a4f79bb" alt=""><figcaption><p>사용자가 직접 타이핑한 발화를 이용하여 블록을 호출한 경우</p></figcaption></figure>

봇 사용자는 바로가기 응답 ‘라이언’을 눌렀을 때, ‘라이언 알아보기’ 발화가 전송되고 연결된 블록의 출력 값이 어떻게 나오는지 경험하게 됩니다. 이를 바탕으로 앞으로 발화 ‘라이언 알아보기’를 입력 전송하면 바로가기 응답을 눌렀을 때와 동일한 응답을 받을 수 있다는 것을 예측할 수 있습니다. 그러므로 메시지 연결 기능을 가진 바로가기 응답은 사용자에게 더욱 직관적인 흐름을 제공합니다.

**블록 연결 기능**

두 번째는 블록 연결 기능입니다. 블록을 연결하면 사용자 측에서 나가는 발화와 상관없이 blockId로 명시된 블록을 무조건 호출하게 됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F6URqL2Zl6jTnJ0cFQuT9%2Fskill-quickreplies-block-example-01.png?alt=media&amp;token=1485dfd1-66de-4877-bc19-298769f03fdd" alt=""><figcaption><p>바로가기 응답(블록 연결 기능)을 이용한 간단한 메시지형 응답</p></figcaption></figure>

블록 연결 기능도 외형은 메시지 연결과 상당히 유사합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FtXXFIAC4NyOspNAmDPqf%2Fskill-quickreplies-block-example-02.webp?alt=media&amp;token=cdc4d082-9680-477b-9c3e-e6f25ebfdc0a" alt=""><figcaption><p>사용자가 직접 ‘반응할 수 없는 발화’를 입력하여 전송한 경우</p></figcaption></figure>

‘라이언’이라는 바로가기 응답을 선택하면, ‘반응할 수 없는 발화’ 라는 발화가 사용자 측에서 노출됩니다. 그리고 연결한 블록이 발화와 상관없이 강제로 실행됩니다. 따라서 그 이후에 동일한 발화를 입력하더라도, ‘반응할 수 없는 발화’를 발화로 등록한 블록이 없기 때문에 폴백 블록이 실행됩니다.

{% hint style="danger" %}
**Caution.**

메시지 기능을 사용한 바로가기 응답의 경우, 그 흐름이 매우 직관적이라 언급했습니다. 손수 발화를 입력하지 않고, 클릭을 통해서 선택지 중 하나를 골랐다는 차이만 있기 때문입니다. 봇 사용자는 추후에도 노출 되었던 발화를 직접 입력하여 전송하여도, 같은 응답을 받을 수 있다는 보장을 받습니다.

하지만 블록 연결 기능을 사용한 바로가기 응답의 경우, 어떠한 발화가 사용자 측에 노출되어도 결국 호출되는 블록은 동일합니다. 추후에 사용자가 동일한 발화를 다시 동일하게 입력해도 해당 블록이 노출되지 않을 수 있습니다. 그렇기 때문에 바로가기 응답에서 블록 연결 기능을 사용할 때는 봇 사용자의 직관적인 흐름을 훼손하지 않도록 주의하여야 합니다.
{% endhint %}

### 상세 필드 <a href="#field_details" id="field_details"></a>

바로연결 버튼의 extra 필드 하위로 원하는 파라미터를 입력하는 경우 연결된 다음 블록에서 페이로드의 client Extra로 해당 값을 확인할 수 있습니다. 다만 바로연결 버튼을 통해 입력된 발화에서 별도로 엔티티를 추출하여 파라미터로 전달하지는 않습니다.

<table><thead><tr><th width="150">이름</th><th width="91">타입</th><th width="243">설명</th><th>제한</th></tr></thead><tbody><tr><td>label</td><td>String</td><td>사용자에게 노출될 바로가기 응답의 표시</td><td></td></tr><tr><td>action</td><td>String</td><td>바로가기 응답의 기능</td><td>‘Message’ 혹은 ‘block’</td></tr><tr><td>messageText</td><td>String</td><td>사용자 측으로 노출될 발화</td><td></td></tr><tr><td>blockId</td><td>String</td><td>바로가기 응답이 ‘블록연결’ 기능일 때, 연결될 블록의 id</td><td>Action이 ‘block’ 일 때, 필수값</td></tr><tr><td>extra</td><td>Any</td><td>블록을 호출 시 추가적으로 제공하는 정보</td><td></td></tr></tbody></table>


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/answer_json_format.md
