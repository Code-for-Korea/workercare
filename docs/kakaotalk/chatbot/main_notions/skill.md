> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/skill.md).

# 스킬

**스킬**은 블록의 출력과 하는 일이 비슷합니다. 사용자에게 정보를 출력하는 것도, 특정 블록에 종속된다는 성질도 비슷합니다. 스킬도 해당 블록의 발화에 반응하여 응답을 돌려주게 됩니다.

이러한 사실을 종합해보면 스킬은 ‘블록에 종속되어 사용자에게 응답을 돌려주는 기능’으로 단순하게 정의할 수 있습니다. 이렇게만 보면 블록의 출력과 별다른 게 없을 것입니다. 하지만 다음과 같은 경우들을 생각해봅시다.

* 사용자가 어떤 야구팀을 좋아하는지 기록하고 이에 맞게 대답해야 한다면?
* 실시간으로 날씨를 알려줘야 한다면?
* 오늘 새로 입고된 상품을 보여줘야 한다면?

아무래도 블록의 출력만으로는 한계가 있을 것입니다. 이때 스킬을 이용한다면 한층 더 쉽게 문제를 해결할 수 있습니다.

## 스킬의 역할 <a href="#skill_role" id="skill_role"></a>

### 출력 <a href="#output" id="output"></a>

스킬은 출력으로 사용이 가능합니다. 발화에 따라서 출력의 큰 틀이 바뀌거나 많은 요소들이 바뀌는 상황이라면 일일이 데이터로 바꾸는 것보다 통째로 응답을 만들어서 주는 것이 낫습니다. 그리고 대화의 흐름을 조금 더 유연하게 제공해야 하는 상황에서도 출력으로써의 스킬은 빛을 발합니다.

예를 들어, 주문을 받는 봇이 있습니다. 주문 봇은 사용자의 주문 내역을 저장하고, 주문 끝이라는 발화가 들어오기 전까지 계속하여 주문을 진행합니다. (카트식 주문이라고 합니다.) 이 상황에서 주문 봇은 사용자가 주문하는 메뉴에 따라서 메뉴를 추천하거나, 사용자가 기입한 기록을 토대로 알레르기와 같은 경고를 중간에 추가할 수 있습니다. [**스킬 개발 가이드 > 응답 설정을 스킬로 사용하기**](/main/tool/chatbot/skill_guide/apply_skill_to_block.md#use_response_settings_as_skill)

### 데이터 <a href="#data" id="data"></a>

스킬은 데이터로 사용이 가능합니다. 출력의 큰 틀이 바뀌지 않고 구체적인 몇 가지 요소만 바뀌면 된다는 상황이라면, 굳이 모든 응답을 스킬을 통해서 만들 필요가 없습니다.

예를 들어, 실시간으로 환율을 보여주는 봇이라면 그 봇의 출력은 아래와 같을 것입니다.

{% hint style="success" %}
**Example.**

“hh시 mm분, 현재 환율은 xxx원입니다.
{% endhint %}

출력에서 필요로 하는 데이터는 ‘시간’, ‘분’, 그리고 ‘환율 수치’입니다. 그렇다면, 모든 내용을 스킬로 만들 필요 없이 데이터에 해당하는 값만 스킬 서버에서 반환하고, 이를 블록의 출력에서 이용하는 방식을 사용하면 됩니다. [**스킬 개발 가이드 > 응답 설정을 값으로 사용하기**](/main/tool/chatbot/skill_guide/apply_skill_to_block.md#use_response_settings_as_values)

## 스킬 한 눈에 보기 <a href="#skill_summary" id="skill_summary"></a>

이제 스킬을 등록하고 실행하는 과정을 한 번 살펴보겠습니다.

스킬 응답을 처리하는 스킬 서버를 생성합니다. [**스킬 개발 가이드 > 스킬 서버 이해하기**](/main/tool/chatbot/skill_guide/make_skill.md#understand_skill_server)

챗봇 관리자센터에서 스킬을 생성하여 생성한 스킬 서버의 \*엔드포인트를 등록합니다. [**스킬 개발 가이드 > 스킬 서버 등록하기**](/main/tool/chatbot/skill_guide/make_skill.md#resist_skill_server)

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FetAG24Wk1cR4G426wkPa%2Fskill-setup.png?alt=media&amp;token=a492dbe4-b39d-4ce8-b6a5-bf0630317e07" alt=""><figcaption></figcaption></figure>

{% hint style="warning" %}
**Definition.**

**엔드포인트란?**\
스킬 서버의 엔드포인트는 요청을 전송할 수 있는 창구를 의미합니다. 예를 들면, 스킬 서버의 주소를 i.kakao.com 이라 가정합니다. 그리고 ‘i.kakao.com/**a**‘, ‘i.kakao.com/**b**‘ 이렇게 두 개의 url에 요청을 전달하면 그 응답을 반환하도록 만들었습니다. 이 경우, ‘i.kakao.com/a’와 ‘i.kakao.com/b’는 각각 스킬 서버의 엔드포인트가 됩니다.
{% endhint %}

위에서 만든 스킬과 블록을 연결합니다. [**스킬 개발 가이드 > 블록과 스킬 연결하기**](/main/tool/chatbot/skill_guide/apply_skill_to_block.md#connect_skill_block)

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FHQ9bRY26ImiE164s2TAB%2Fskill-block-binding-01.png?alt=media&amp;token=c89e4985-e2c1-4c56-8d69-cba8e127311f" alt=""><figcaption></figcaption></figure>

스킬과 연결한 블록이 활성화되면(ex. 사용자가 블록에 등록된 발화로 봇에게 말을 건 경우), 봇 시스템은 스킬에 등록된 엔드포인트로 요청을 전송합니다.

스킬 서버에서 응답을 만들어 반환하면, 봇 시스템은 이를 토대로 사용자에게 전달할 출력 모습을 만들고 카카오톡에 그립니다. [**스킬 개발 가이드 > 응답 타입별 JSON포맷**](/main/tool/chatbot/skill_guide/answer_json_format.md)

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F4NLBb7ZQ6m3xZpbncWHG%2Fskill-test.png?alt=media&amp;token=7c9626ee-9829-4def-b523-aa1f5f714e81" alt=""><figcaption></figcaption></figure>

상세한 설정 방법은 [**스킬 개발 가이드**](/main/tool/chatbot/skill_guide.md)를 차례로 확인하시길 바랍니다.


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/skill.md
