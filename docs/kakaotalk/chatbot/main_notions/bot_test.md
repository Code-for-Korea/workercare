> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/bot_test.md).

# 봇테스트

챗봇 관리자센터에서 봇 작업자가 봇을 만들때 실제 카카오톡 채널이 아닌 웹 상에서 봇을 테스트할 수 있습니다. 간단하게 Ctrl+E 단축키나, 아래의 메뉴를 통해서 접근할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F1bOZ7msP3SVETKVcjQZn%2Ftest-menu.png?alt=media&amp;token=76d94451-7a1f-48b1-af3f-d1876093b76d" alt=""><figcaption><p>우측에 봇테스트 메뉴 또는 Ctrl+E 단축키로 봇테스트를 호출할 수 있습니다</p></figcaption></figure>

## 봇테스트 화면 <a href="#bot_test_screen" id="bot_test_screen"></a>

아래의 이미지처럼 기본적인 발화와 그에 따른 봇의 실제 응답 형태를 확인합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FXFqnLP36SI6dKdqoyAbL%2Ftest-view.png?alt=media&amp;token=4eab889d-bc33-4eb7-ba1f-9c82c04bc601" alt=""><figcaption><p>예상 발화에 이미 설정된 카드형태의 응답을 보여주는 화면입니다</p></figcaption></figure>

## 제공 정보 <a href="#provided_information" id="provided_information"></a>

### 기본 정보 <a href="#basic_information" id="basic_information"></a>

기본적으로는 아래와 같이 폴백 블록이나 일반 블록의 응답 설정 값들을 확인할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FJUKBBMLCMDQ6novjfWE0%2Ftest-examples.png?alt=media&amp;token=bf374460-7589-42d9-b76a-7a9e6e30d7d5" alt=""><figcaption><p>다양한 말풍선을 제작하고, 봇테스트에서 확인할 수 있습니다</p></figcaption></figure>

### 상세 정보 <a href="#detail_information" id="detail_information"></a>

작업자는 왼쪽의 상세 정보 영역에서 추가적인 정보를 확인할 수 있습니다.

**① 블록명** : 해당 발화/ 응답이 진행된 블록의 이름이 표기됩니다

**② 패턴** : 해당 발화를 인지했다면, 인식된 패턴이 표기됩니다.

**③ 컨텍스트** : 현재 발화로 인해 소비된 컨텍스트의 수명(lifespan) 횟수가 표기됩니다.

**④ 파라미터** : 해당 발화의 파라미터 정보가 표기됩니다.

**⑤ 스킬명** : 스킬로 연결된 블록인 경우, 연결된 스킬명이 노출됩니다.

**⑥ 응답 사이즈** : 설정된 응답의 사이즈 정보가 표기됩니다. 텍스트형 및 이미지형 응답의 경우, 응답 사이즈를 제공하지 않습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FNAaQ3gXOTl30ZJhK6AgZ%2Ftest-info.png?alt=media&amp;token=e3c29fc4-64dd-4994-93fe-6ca4ffea82b1" alt=""><figcaption><p>좌측에 상세정보 영역에서 정보를 확인할 수 있습니다</p></figcaption></figure>

상세 정보영역에서 스킬에 대한 요청/응답에 대해서도 JSON 형태로 조회가 가능합니다. **⑦ 더보기** 버튼을 클릭하면 추가적인 영역이 노출됩니다.

더보기 정보는 아래와 같습니다.

* **스킬응답** : 스킬응답에 대한 JSON 전문이 표기됩니다.
* **응답오류** : 응답 오류가 된 경우, 오류관련 코드가 표기됩니다.
* **Request** : 스킬서버로의 요청 전문이 표기됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FzdmL1e5tmtjQoHII4w7h%2Ftest-info2.png?alt=media&amp;token=ad9b3b21-9c8b-43fc-af80-5bdfe0f0b54b" alt=""><figcaption><p>상세 정보 내 더보기 영역</p></figcaption></figure>

## &#x20;<a href="#bubble_size" id="bubble_size"></a>


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/bot_test.md
