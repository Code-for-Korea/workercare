> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/utterance_pattern.md).

# 발화 패턴

챗봇 관리자센터로 챗봇을 만들 때, 챗봇이 사용자 발화를 인식할 수 있도록 만드는 원리의 핵심은 **패턴(Pattern)** 입니다. 발화 패턴을 만드는 기본 과정은 다음과 같습니다.

* 봇 작업자가 외부 사용자들이 ‘이렇게 말할 것이다’라고 예상되는 발화문을 등록합니다.
* 발화는 선택하여 삭제 가능합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F4pD9s9OOIm2JEyyxr03b%2Futterance-configure-new-01.png?alt=media&amp;token=217d320d-1339-4d61-a4fe-3c1308a32a75" alt=""><figcaption><p>블록 내 ‘사용자 발화 패턴 설정’ 입력 공간</p></figcaption></figure>

* 그 후 해당 문장 안에서 중요한 의미(또는 정보)를 갖는 부분을 엔티티로 태깅합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FBh1tDZkoRaBDyPQoh6k8%2Futterance-pattern-extract.png?alt=media&amp;token=c5019f58-2fe0-461a-8ac1-d98f0520fbf3" alt=""><figcaption><p>입력된 발화에 패턴을 부여할 수 있는 상태</p></figcaption></figure>

이렇게 발화 패턴을 등록해주면, 챗봇은 사용자가 조금씩 다르게 말하더라도 각각의 ‘의도’에 해당하는 블록을 선택해 보여줄 수 있습니다.

특히, 챗봇이 사용자 의도를 이해하기 위해, 추출된 엔티티 정보는 가장 중요한 열쇠입니다. 또한, 같은 의미의 문장이라도 엔티티를 포함하여, 기타 어휘 순서가 변경되는 경우에는 서로 다른 발화 패턴으로 인식하기 때문에 추가로 등록을 해주어야 인식률 향상에 도움이 됩니다.

상세한 설정 방법은 [**튜토리얼 1단계>발화**](/main/tool/chatbot/tutorial/make_chatbot/tutorial_1.md#utterance)를 참고하시길 바랍니다.

## 발화 패턴 만들기 <a href="#make_utterance_pattern" id="make_utterance_pattern"></a>

봇 작업자가 사용자 발화 패턴 설정란에 사용자 예상 발화를 입력하고 난 후, 직접 태깅을 통해서 필요한대로 발화 패턴을 정의할 수 있습니다. 챗봇 관리자센터에서는 태깅이 필요할 것으로 예상하는 엔티티 단어에 대해서 밑줄(Underline)을 자체적으로 표시해주는데, 이를 확인하고 봇 작업자는 밑줄이 가르치는 단어를 드래그하여 필요한 엔티티를 직접 부여하실 수 있습니다.

다음과 같은 작업 순서 예시를 확인하십시오.

### **Step 1. 발화 중 밑줄이 표시된 ‘라이언’에 인물 엔티티를 태깅합니다. (엔티티명: `@sys.person.name`)**

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FZCSvEv3cTA9WDWt6TCBP%2Futterance-create-01.png?alt=media&amp;token=a18493bb-ed06-443e-b340-161e854bc0cb" alt=""><figcaption></figcaption></figure>

밑줄이 나타난 단어를 드래그하면, 엔티티를 고를수 있는 팝업이 나타납니다. 필요에 따라 봇 작업자는 추천 엔티티 또는 전체 엔티티 목록에서 희망하는 엔티티를 부여할 수 있습니다.

### **Step 2. 밑줄이 없더라도 ‘나이’처럼 특정 단어에 엔티티 태깅을 할 수 있습니다. (엔티티명 : `@age`)**

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FMCgidkGK7jLAsdt4CuZe%2Futterance-create-02.png?alt=media&amp;token=d7bbc27a-e887-4fd9-a662-6ce5cf7b11aa" alt=""><figcaption></figcaption></figure>

나이라는 단어에 직접 드래그 하여 별도의 엔티티를 강제 부여하는 모습입니다.

입력된 발화에 대해서 최종적으로 엔티티 태깅이 완료하고 나면 패턴 발화가 생성됩니다.

### **Step 3. 의도 확인에 중요한 정보는 `{sys.person.name}`, `{age}` 엔티티에 있음을 확인합니다.**

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F5Bhc08MGI6kwSmNWnTz8%2Futterance-create-03.png?alt=media&amp;token=27626967-c3a0-47e5-b971-e535dcf5a1a2" alt=""><figcaption></figcaption></figure>

패턴이 잡혀진 발화의 예시 모습입니다.

결론적으로 본 테스트 블록의 사용자 의도는 **나이 묻기**이며, 이러한 의도를 확인하기 위한 패턴은 아래와 같다는 것을 알 수 있습니다.

패턴 발화 : `{인물이름} {나이} <어떻게> <되다>`

위 같은 방식으로, 본 블록이 나타내고자 하는 의도에 알맞는 발화패턴을 입력하고 태깅하는 작업하는 과정을 이어서 하면 됩니다. 하나의 블록 안에서 패턴을 충분히 포함 할 수록, 실제 사용자 발화에 블록이 대응할 수 있는 확률이 높아집니다.


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/utterance_pattern.md
