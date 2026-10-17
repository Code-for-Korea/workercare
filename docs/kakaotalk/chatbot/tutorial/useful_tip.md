> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/tutorial/useful_tip.md).

# 알아두면 유용한 팁!

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F0e7DU0oky1bEZWgFaI3G%2Fuseful-tips-intro.png?alt=media&amp;token=a97df5ef-74ae-4461-a94a-21eaec089a35" alt=""><figcaption></figcaption></figure>

알아두면 쓸 데 많고 신박한 잡학 팁!

챗봇 관리자센터를 쓸 때 여러분의 노고를 덜어줄 아주 유용한 팁들을 대공개합니다. 엔티티와 발화를 작성하는 법부터, 나아가 나의 봇을 누군가와 함께 만들때 필요한 효율적 프로세스까지.

봇 제작의 A to Z가 바로 여기에 준비되어 있습니다.

## 자연어처리 로직 가볍게 이해하기 <a href="#understand_logic" id="understand_logic"></a>

챗봇 관리자센터가 자연어 발화를 인식하는 방법을 아래 예시문을 통해 살펴보겠습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FDTalFYs89BQ0WIicaLQQ%2Fuseful-tips-nlp-overview.png?alt=media&amp;token=b70fb276-c865-48f8-98ed-1d71df6c63ab" alt=""><figcaption></figcaption></figure>

발화문 패턴 인식 로직안에서는 봇 작업자가 등록한 발화 패턴안의 특정 단어에 `{ }` 형태로 엔티티 태깅을 해두고 있습니다. 중괄호로 태깅된 부분은 발화문의 의도를 파악하기 위한 가장 중요한 정보가 되며, 챗봇 관리자센터 내의 **시스템 엔티티** 또는 **나만의 엔티티**와 연결되어 있습니다. 기계적으로는 이와 같이 패턴화된 형태 정보를 가지고, 사용자의 입력발화가 기 등록된 패턴에 맞게 들어왔다 아니다를 판단하게 되는것입니다.

챗봇 관리자센터의 자연어 인식 로직을 이해하고자할때, 봇 작업자가 참고해야하는 사항은 다음과 같습니다.

* 챗봇 사용자가 등록된 발화문과 동일하게 질문을 입력했다면, 그대로 해당 발화문이 포함된 블록이 실행됩니다.
* 챗봇에 인입된 발화문이 사전에 패턴으로 정의해 둔 발화문과 약간의 차이가 있더라도, 상기 예에서 {제주도}, {날씨} 엔티티 정보가 살아있는 이상, **날씨 알려달라**는 의도를 큰 차이없이 추출해 냅니다.
* 여기서, **좀**과 같은 부사등은 크게 의도를 찾는데 중요한 정보가 아니므로, 패턴을 만드실 때 많이 집착하실 필요는 없습니다. 챗봇 관리자센터안에 있는 형태소(우리말에서 의미를 갖는 최소의 단위) 분석기가 작동하면서, 크게 중요하지 않은 변형된 어미등은 원형을 추적하며 이해하고 있습니다.

## 엔티티 작성 팁 <a href="#make_entity_tip" id="make_entity_tip"></a>

봇 작업자가 더욱 손쉽게 엔티티를 작성할 수 있는 팁을 알려드립니다. 이를 참고하면 챗봇의 응답 품질을 향상시키고 작업 공수를 줄일 수 있습니다.

### 엔티티 신규 등록시 팁 <a href="#make_new_entity_tip" id="make_new_entity_tip"></a>

{% hint style="success" %}
**Tip.**

* 엔티티 명은 영어로 작성할 것을 권장합니다.\
  예) `coffee_menu` → 즉, **커피 메뉴**를 총칭하는 유형(category)으로 이해하시면 편합니다.<br>
* 엔티티 유형 안에서 **대표 낱말**을 **대표 엔트리**로 정의합니다.\
  예) 아메리카노, 카페라떼, 카페모카…<br>
* 동의어는 대표 엔트리와 같은 의미를 가진 낱말을 의미합니다. 이때, 해당 동의어에는 띄어쓰기, 영문 대소문자를 굳이 구분하지 않아도 됩니다. → 단어 간 공백 여부는 상관없습니다.<br>
* 엔티티 명을 등록할 때, **나의 엔티티** 명칭을 **시스템 엔티티**의 명칭과 같게 작성하지 않도록 유의합니다.\
  예) 나의 엔티티명 → `sys.date`, 시스템 엔티티명 → `sys.date`로 정의되어버린 경우\
  \
  만약 위 예시처럼 두 개의 엔티티 명이 동일하게 설정된다면, 자연어처리 과정에서 엔티티 인식(=태깅) 시에 **나의 엔티티**가 동일한 이름의 **시스템 엔티티**보다 먼저 태깅 우선순위를 가지게 됩니다.
  {% endhint %}

### 엔티티를 한꺼번에 업로드할 때 팁 <a href="#upload_entity_tip" id="upload_entity_tip"></a>

{% hint style="success" %}
**Tip.**\
CSV파일은 utf-8 로 인코딩 모드를 맞춰주세요.
{% endhint %}

#### **Step 1. 엔트리 파일 업로드 메뉴 클릭**

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FeJq6IA5PcxwMYpiZKr3j%2Fuseful-tips-entity-bulkupload.png?alt=media&amp;token=0849b971-6a56-494a-b11b-c130d26c4225" alt=""><figcaption><p>엔트리 파일 업로드 메뉴 위치</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FFfNtVSjIuvT6x2pdxAIK%2Fuseful-tips-entity-bulkupload-csv.png?alt=media&amp;token=ef95cecd-d410-48e1-80d3-46adace8be26" alt=""><figcaption><p>업로드 대상 CSV파일 내에 기록된 엔트리 및 동의어 리스트 모습</p></figcaption></figure>

#### Step 2. 파일 업로드 후, 아래와 같이 업로드된 사항 확인 완료

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FKlhpS0urzbSNDQQs9k59%2Fuseful-tips-entity-bulkupload-result.png?alt=media&amp;token=37556a3d-1985-4688-ac1c-9aa740b136e5" alt=""><figcaption><p>CSV파일 안의 엔티티들이 일괄 업로드 된 화면</p></figcaption></figure>

{% hint style="danger" %}
**Caution.**

CSV파일을 올릴 때, 데이터양에 따라 업로드를 하는데 수초의 리드 타임이 발생할 수도 있습니다. 모두 업로드 등록이 될 때까지 **저장** 버튼을 누르지 말아 주세요.
{% endhint %}

## 발화문 작성 팁 <a href="#make_utterance_stc_tip" id="make_utterance_stc_tip"></a>

봇 작업자가 **발화문**을 많이 등록하면 할수록 의도 추출 범위가 자연스럽게 넓어지게 되어, 봇 사용자의 입력 문의에 더욱 정확한 의도 추출이 가능해집니다.

그러나, 카카오 챗봇 관리자센터의 우리말 **발화 인식**이라는 개념을, 일반적으로 단순 키워드 매칭 방식의 **완전 매칭(Exact-Matching)** 원리로 오해하면, 챗봇 제작시 너무 많은 공수를 발화 등록 과정에 소모하게 되니 주의하셔야 합니다.

{% hint style="danger" %}
**Caution.**

챗봇 관리자센터는 사용자로부터의 인입 발화문을 패턴 형태로 이해하므로, 블록 안에 예상 발화문을 등록할 때 패턴 발화 형태로 작성하셔야 합니다.
{% endhint %}

따라서 사용자 예상 발화를 효과적으로 등록할 수 있는 몇 가지 팁을 다음과 같이 알려드립니다.

{% hint style="success" %}
**Tip.**

* 발화 입력은 블록당 수백, 수천 개 까지 등록할 수 있습니다. 다양한 사례를 고려하여 발화를 등록하면, 블록이 실행될 확률을 높일 수 있습니다.
* 패턴은 사용자 질의 의도를 추출하는 데 필요한 것이고, 즉 정확한 의도를 판단하는 데는 엔티티가 가장 중요합니다. 따라서 엔티티를 보다 상세하고, 정확한 형태로 작성하는 것을 유념해야 합니다.
* **좀, 너무** 등 불필요한 부사 어구 등은 패턴인식에 크게 중요하지 않은 요소이니 발화 안에 전부 등록할 필요는 없습니다.
* **'있어요?', '있나요?', '있나?'** 등과 같이 문장의 말미에 위치한 동사의 다양한 어미를 일일이 등록할 필요 없습니다. (상기 Tip 3과 같습니다.)
* 소위 **스몰톡** 이라고 해서 **'안녕?', '너 이름이 뭐니'** 등과 같은 대화를 처리하기 위한 발화를 등록할 때, 챗봇이 제공하는 주요 서비스의 본질을 해하지 않도록 해야합니다. 챗봇이 제공하는 서비스에 집중해서 예상 발화를 등록하는 것이 훨씬 효과적인 방향입니다.
  {% endhint %}

이러한 팁을 염두에 두고, 예상 발화문을 등록하면 모든 인입 예상 발화문을 처리하기 위해 불필요한 발화 문장 입력을 하는 실수와 노고를 줄일 수 있습니다.

## 봇 구현 표준 프로세스 맵 <a href="#make_bot_process_map" id="make_bot_process_map"></a>

### 세상에서 가장 엣지있는 봇 만들기 <a href="#make_bot_process" id="make_bot_process"></a>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FowMqRKjr2e4dCYXTZpmG%2Fworldclass-edgebot.png?alt=media&amp;token=00140110-b936-4e52-b84b-b0479c4c359f" alt=""><figcaption></figcaption></figure>

### 봇 제작 준비부터 개발, 그리고 고도화까지의 여정 <a href="#make_bot_journey_map" id="make_bot_journey_map"></a>

봇을 만드는 과정은 크게 4단계 **준비-설계-구현-고도화(유지보수)**&#xB85C; 이루어집니다. 봇 작업자가 개발을 전혀 모르더라도 이 4단계를 거치며 간단하고 의미있는 봇을 만들수 있습니다. 만약 봇 작업자가 개발자인 경우나 기획자와 개발자가 함께 협업하는 상황이라면 더욱 많은 사용자 응대 시나리오를 보유할 수 있으며, 응대력이 강화된 봇을 만들어 낼 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FfhoHCwFcHWeHj5hb81mP%2Fuseful-tips-processmap-02.png?alt=media&amp;token=672e48ca-a2c3-42d8-b15f-550cb5e2bae3" alt=""><figcaption></figcaption></figure>


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/tutorial/useful_tip.md
