> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/knowledge_base.md).

# 지식베이스

## 지식베이스가 무엇인가요? <a href="#what_is_knowledge_base" id="what_is_knowledge_base"></a>

지식베이스는 고객의 자주 묻는 질문과 답변을 관리하는 카카오의 지식 데이터 솔루션으로 [**지식 관리자센터**](http://knowledge.kakao.com/)에서 생성할 수 있습니다. 자세한 설명은 [**카카오비즈니스 소개페이지**](https://business.kakao.com/info/knowledge)와 [**지식 도움말**](https://kakaobusiness.gitbook.io/main/tool/knowledge)에서 확인할 수 있습니다.

## 지식베이스 설정이 무엇인가요? <a href="#knowledgebase_setting" id="knowledgebase_setting"></a>

챗봇 서비스를 운영하다 보면 챗봇 사용자로부터 많은 질문을 받게 됩니다. 그리고 유입되는 수많은 질문에 대응하여 봇을 일일이 설계하는 것은 매우 힘든 작업입니다. **지식베이스 설정은 수많은 질문에 대해 봇 작업자가 손쉽고, 빠르게 응대할 수 있도록 도와주는 기능**입니다.

보통 봇을 만들기 위해서는 시나리오 메뉴에서 블록을 생성하여 발화를 입력하고 출력을 설정해야 합니다. 하지만 지식베이스를 연동하면 해당 과정을 생략하고 간단히 질문에 응답하는 봇을 운영할 수 있습니다.

지식베이스를 설정하는 방법은 간단합니다. **봇 작업자는 설정의 '지식베이스 정보'에서 자신이 마스터인 지식베이스를 선택하여 봇과 연동**할 수 있습니다. 자세한 사용 방법은 해당 [**지식베이스 설정**](#setting)을 참고하시길 바랍니다.

지식베이스를 연결한 봇은 외부에서 유입된 사용자 발화를 지식베이스에 전달하고, 지식베이스는 저장된 질문 정보에서 유사한 질문 정보를 찾고, 그에 연결된 답변을 봇에 전달하는 원리로 동작합니다. 시나리오에서 만든 블록처럼 사용자 발화 '의도'를 추출하지는 않지만, 지식베이스가 유사한 질문 형태를 찾아서, 바로 연결된 답변을 '검색 결과'처럼 보여주고 싶을 때 유용합니다.

## 지식베이스 설정은 어떤 질문에 적합한가요? <a href="#usecase" id="usecase"></a>

챗봇 서비스를 운영하다 보면 사용자로부터 다양한 유형의 발화가 들어오고, 이 발화는 크게 2 가지로 구분됩니다. 첫 번째 유형은 **숏-헤드 유형**으로 많은 사용자로부터 높은 빈도로 유입되는 주요 발화들이 있습니다. 두 번째 유형은 **롱-테일 유형**으로 낮은 빈도로 유입되는 다양한 발화가 있습니다.

좋은 봇 서비스를 만들기 위해서는 두 가지 유형의 발화를 모두 커버할 수 있어야 합니다. 높은 빈도의 숏-헤드 질문은 블록을 생성하고, 머신러닝을 통해 대처할 수 있지만 다양한 롱-테일 유형의 질문은 일일이 블록을 만들어 응대하기 쉽지 않습니다. **지식베이스는 이러한 롱-테일 유형 발화에 적합한 기능입니다.**

봇 작업자는 빈도가 높고 중요한 숏-헤드 질문에는 블록, 머신러닝을 활용하고, 빈도가 낮고 다양한 롱-테일 질문에는 지식베이스를 사용하여 외부 사용자의 예측불가능한 질문에 촘촘하게 응대할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FNG5QOtfkFFbLVz83cW0B%2Fknowledge1.png?alt=media&amp;token=72087d51-971c-49f9-8c20-a541d6c9ff81" alt=""><figcaption></figcaption></figure>

## 지식베이스 설정하기 <a href="#setting_knowledge_base" id="setting_knowledge_base"></a>

지식 관리자센터에서 지식 베이스를 생성하여 질문과 답변 데이터를 관리하고 있다면, 봇과 연동할 수 있습니다.

### 지식베이스 설정 <a href="#setting" id="setting"></a>

설정 메뉴의 지식 베이스 정보를 통해 봇 작업자는 지식 베이스를 설정할 수 있습니다. 봇 작업자는 자신이 마스터 권한으로 있는 지식 베이스를 선택하여 연동할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F3xZigglGYPuih6eB9Nos%2Fknowledgebase-2.png?alt=media&amp;token=7806df7b-9b57-459c-882a-09f4b1de069f" alt=""><figcaption></figcaption></figure>

지식 베이스를 선택하고, 지식 베이스의 버전을 선택하는 방식은 2가지가 있습니다.

(1) 수동 선택한 버전을 사용

봇 작업자가 특정 버전을 선택하여 사용할 수 있습니다. 설정 후, 봇 배포를 해야 운영 채널에도 설정한 지식 베이스 버전이 반영됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F9TPlOhG1ZfOnTRG8Mw7g%2Fknowledgebase-3.png?alt=media&amp;token=8180a7f8-7e45-4eae-b645-f3b6e47cf801" alt=""><figcaption></figcaption></figure>

(2) 최신 배포 버전을 사용

봇 작업자는 항상 지식 베이스의 최신 배포 버전을 사용할 수 있습니다. 단, '최신 배포 버전을 사용' 설정 후에 봇을 배포해야 운영 채널에 해당 설정이 반영됩니다. 설정 후, 1회의 봇 배포 이후에는 별도의 봇 배포 없이도 운영 채널에 지식 베이스의 최신 배포 버전이 적용됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FfWFolr8rWRsvTU5cUWcv%2Fknowledgebase-4.png?alt=media&amp;token=cd670d4b-5f08-45ff-8007-c4aabadecf45" alt=""><figcaption></figcaption></figure>

### 답변 출력 종류 <a href="#answer_type" id="answer_type"></a>

지식 베이스를 설정하셨다면, 카카오톡에서 답변의 출력 형태를 정해야 합니다.\
답변 출력 형태는 아래와 같이 3가지가 있으며, 용도에 맞게 답변 형태를 선택하시면 됩니다.

* 질의자의 질문형태에 가장 정확한 것으로 판단되는 답변하나만 전달하는 **즉문즉답형**
* 정확도순으로 Top3 유사질문 리스트를 보여주는 **답안추천형**
* 사용자가 스킬을 이용하여 자유롭게 답변을 구성하는 **스킬형**

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FMnM2A8GkISjdSzqykG9n%2Fimg_001.png?alt=media&amp;token=229f77f5-505d-4954-a930-f6d0bf06326f" alt=""><figcaption><p>답변출력 형태 예시 - (1) 즉문즉답형 (2) 답안추천형 (3) 스킬형</p></figcaption></figure>

### 답변 출력 설정 방법 <a href="#how_to_set_answer" id="how_to_set_answer"></a>

(1) 즉문즉답형 말풍선 설정

즉문즉답형 출력 말풍선에서는 다음의 3가지를 설정할 수 있습니다.

* 최소 답변 정확도
  * 답변 제공의 기준이 되는 최소 정확도를 설정하는 영역입니다.
  * 설정된 정확도 이상의 지식 베이스 답변을 제공합니다.
* 가이드 말풍선
  * 답변이 제시되기 전에 안내문구를 꾸미는 영역입니다.
  * 텍스트로 가이드문구를 넣어주거나, 또는 희망하시는 이미지를 넣어줄수 있습니다.
  * 이 부분을 선택적으로 On/Off할수도 있습니다.
* 피드백 버튼
  * 답변이 제공된후, '좋아요' 또는 '나빠요'에 해당하는 사용자 피드백 버튼을 넣어줄수 있습니다.
  * 이 부분도 선택적으로 On/Off할수 있습니다.

\*참고. 피드백 버튼으로부터 누적된 결과를 바탕으로 답변 검색 로직을 강화하고, 분석 메뉴에서 블록별로 현황을 보여주는 feature가 향후 데이터 누적후 제공될 예정입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FYgjM6ttoSV8VL6xwc7t8%2Farm-2-14%402x3.png?alt=media&amp;token=1d52224d-f361-4202-b4ec-aa2893a44266" alt=""><figcaption></figcaption></figure>

(2) 답안추천형 말풍선 설정

답안추천형 출력 말풍선에서는 다음의 4가지를 설정할 수 있습니다.

유사 질문이 1개일 경우 답안추천형을 사용하였더라도 즉문즉답형으로 답변됩니다.

* 가이드 말풍선
  * 즉문즉답형에서 꾸미는 방식과 동일합니다. 답변 출력전 안내문구를 넣어주거나 이미지를 넣어줄수 있습니다.
* 답변설정
  * 답안추천형에서는 사용자 질의 문장에 대해 유사한 것으로 판단되는 유사질문 Top3를 캐로셀 형태로 제공합니다. 이때, 봇작업자는 이미지를 첨부하여 카드형 말풍선으로 답변을 꾸밀수 있습니다.

{% hint style="info" %}
<사용법 참고>\
이미지가 필수로 들어가는 카드형 말풍선에서 봇 작업자가 기존에 저장해 둔 Q\&A 지식 정보 세트 정보 중에서

* image info (URL)에 해당하는 정보가 있다면 → 우선적으로 해당 image info 이미지가 보여집니다.
* image info (URL)가 없다면 → 위에서 사용자가 파일로 업로드한 이미지가 디폴트로 출력됩니다.

예시로, 추출된 Top3 유사질문 리스트에서, 1개만 image url 정보가 있었고 2개는 image url정보가 없었다면, 해당 2개의 이미지는 봇 작업자가 여기 말풍선 상세 메뉴에서 업로드 해 둔 디폴트 이미지가 출력되는 것입니다.
{% endhint %}

* 버튼명 설정
  * 답변을 보기 위한 버튼에 대해 '버튼명'을 정의할수 있습니다.
* 피드백 설정
  * 답변이 제공된후, '좋아요' 또는 '나빠요'에 해당하는 사용자 피드백 버튼을 넣어줄수 있습니다.
  * 선택적으로 On/Off할수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FeKzJBT1QoIrTyBkhJaeG%2Farm-2-15%402x.png?alt=media&amp;token=5b4d1829-e71a-4f2f-9da6-58e9944f788f" alt=""><figcaption></figcaption></figure>

(3) 스킬형형 말풍선 설정

스킬형을 선택하면 발화가 지식 베이스의 질문에 일치하는 경우, [**스킬 payload**](/main/tool/chatbot/skill_guide/answer_json_format.md#skillpayload)를 통하여 지식의 목록과 정보가 전달됩니다.

스킬형 출력 말풍선에서는 다음의 2가지를 설정할 수 있습니다.<br>

* 스킬 설정
  * 지식 정보를 전송할 스킬을 선택할 수 있습니다.
  * 스킬 선택을 위해서는 '스킬' 메뉴에서 스킬을 등록해야 합니다.
* 최소 답변 정확도
  * 답변 제공의 기준이 되는 최소 정확도를 설정하는 영역입니다.
  * 설정된 정확도 이상의 답변 정보를 제공합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FLbtQZMoY99OXrkD74mx9%2Fimg_002.png?alt=media&amp;token=fe6831f6-f948-43f5-8607-332bd0866595" alt=""><figcaption></figcaption></figure>

#### SkillPayload

스킬 payload는 스킬 실행시 봇 시스템이 스킬 서버에게 전달하는 정보입니다. payload는 사용자의 정보, 발화, 실행 블록, 파라미터 등의 정보를 포함합니다.

* intent
* userRequest
* bot
* action

#### intent

발화와 일치하는 블록의 정보를 담고 있는 필드입니다. 발화가 지식 베이스 질문과 일치하는 경우, 일치하는 지식의 목록을 포함합니다.

**상세필드**

<table><thead><tr><th width="140">이름</th><th width="149.33333333333331">타입</th><th>설명</th></tr></thead><tbody><tr><td>id</td><td>string</td><td>블록 id입니다.</td></tr><tr><td>name</td><td>string</td><td>블록명이며, 지식의 경우 “지식베이스”로 노출합니다.</td></tr></tbody></table>

#### intent.extra.knowledges

**상세필드**

<table><thead><tr><th width="210.33333333333331">이름</th><th width="72">타입</th><th>설명</th></tr></thead><tbody><tr><td>matchedKnowledges</td><td>array</td><td>발화에 일치한 지식 목록입니다.</td></tr></tbody></table>

#### knowledge

**상세필드**

<table><thead><tr><th width="132.33333333333331">이름</th><th width="95">타입</th><th>설명</th></tr></thead><tbody><tr><td>answer</td><td>string</td><td>지식의 답변입니다.</td></tr><tr><td>question</td><td>string</td><td>지식의 질문입니다.</td></tr><tr><td>categories</td><td>array</td><td>QA의 카테고리입니다.</td></tr><tr><td>landingUrl</td><td>string</td><td>지식 답변에서 링크 더보기입니다.</td></tr><tr><td>imageUrl</td><td>string</td><td>답안 추천형 지식 답변에서 썸네일 이미지입니다.</td></tr></tbody></table>

**예제 코드**

```
{
    "bot": {
        "id": "<봇 id>",
        "name": "<봇 이름>"
    },
    "intent": {
        "id": "<블록 id>",
        "name": "지식베이스",
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
                "botUserKey": "<사용자 botUserKey>",
            }
        },
        "utterance": "<사용자 발화>",
        "params": {
            "surface": "BuilderBotTest",
            "ignoreMe": "true"
        },
        "lang": "kr",
        "timezone": "Asia/Seoul"
    },
    "contexts": []
}
```

### 패턴발화가 등록된 블록과 연계한 응용 활용 방법 <a href="#how_to_apply_with_block" id="how_to_apply_with_block"></a>

**사용자 질의에 응대하기 위해 이미 패턴발화를 블록에 수없이 등록했는데, 본 메뉴에서도 지식정보 Q\&A 세트를 또 업로드해서 사용할 수 있는 것인가요? 두 개 메뉴에 해당하는 기능을 동시에 사용할 수 있나요?**

물론입니다.\
패턴발화를 등록한 블록들과, 지식 베이스 설정에 대한 '배포' 과정을 통해 하나의 봇을 만들수 있습니다. 단, 이때에는 사용자 질의에 대해, 우선적으로 패턴발화를 등록했던 블록 중에서 정확하다고 판단되는 블록이 선택되어 그에 연결된 답변이 출력됩니다.\
만약 사용자 의도가 추출이 되지 않는 질문이라고 하면 그 다음에 순차적으로 지식 베이스에서 유사 질문이 검색되어 연결된 답변이 출력됩니다. (즉, 챗봇이 질문을 이해하지 못하여 '폴백' 메시지를 내놓을수 있는 확률이 줄어듭니다.)

그러므로, 봇작업자께서는 보다 중요하고 의미있는 질문들을 처리하기 위한 내용들은 시나리오 메뉴의 '블록'들을 통해 답변 작성을 해두시고, 이외 기타 수많은 형태의 질문-답변 세트는 지식 베이스에 업로드하면, 사용자 질의에 대해서 보다 답변 응대력이 향상된 봇을 만들수 있습니다.

{% hint style="success" %}
**Tip.**

시간이 없고, 무조건 빨리 시일내 가장 기본적인 봇을 만들려고 한다면, 시나리오에 블록을 만들지 않고서도, **지식 베이스 설정**으로 **'간단 답변 검색형' 봇**을 만들수도 있습니다.
{% endhint %}


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/knowledge_base.md
