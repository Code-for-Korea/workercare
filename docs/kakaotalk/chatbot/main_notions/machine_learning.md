> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/machine_learning.md).

# 머신러닝

챗봇 서비스를 운영하다보면 사용자로부터 다양한 유형의 발화가 들어오고, 이 발화는 크게 2 가지로 구분됩니다. 첫 번째 유형은 **숏-헤드** 유형으로 많은 사용자로부터 높은 빈도로 유입되는 주요 발화들이 있습니다. 두 번째 유형은 **롱-테일** 유형으로 낮은 빈도로 유입되는 다양한 발화가 있습니다.

좋은 봇 서비스를 만들기 위해서는 두 가지 유형의 발화를 모두 커버할 수 있어야 합니다. 하지만 사용자가 롱-테일 유형의 질문까지 모두 블록으로 만들어 응대하기는 쉽지 않습니다.

그래서 챗봇 관리자센터에서는 인입 질문의 유형에 따라 패턴 매칭, 머신러닝, [**지식베이스**](/main/tool/chatbot/main_notions/knowledge_base.md)를 적절히 사용하여 쉽게 양질의 봇을 만드는 방식을 제공하고 있습니다.\
이중 **머신러닝은 숏-헤드 유형의 발화에 대해 보다 정확하게 응대할 수 있도록 도와주는 기능**입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FSGv9iXy1BSX4UTjtIdKk%2Farm-01.png?alt=media&amp;token=491a04ef-3830-4213-b972-220f06026139" alt=""><figcaption><p>챗봇에 유입되는 질의 유형 구분 (숏헤드 &#x26; 롱테일형 구분, edited by Kakao)</p></figcaption></figure>

챗봇 관리자센터에서 제공하는 머신러닝을 사용하면, 적은 예상 발화문 입력으로 **폭 넓은 사용자 의도 파악이 가능**하다는 장점이 있습니다.\
즉, **적은 발화를 학습해도 종전보다 더 똑똑한 봇을 만들 수 있게 되었습니다!**

{% hint style="warning" %}
**Definition.**\
사용자 발화는 크게 두 가지가 있으며, 아래와 같습니다.

* **패턴 발화**: 패턴 매칭을 위한 발화로 입력된 예상 발화를 기준으로 어순 일치, 엔티티와 조사, 어미의 변형에 한정하여 동일한 패턴으로 간주하여 의도를 파악합니다.<br>
* **머신러닝 발화**: 기계가 의도를 파악하기 위해 학습에 사용될 발화입니다. 문장의 의미를 파악하기 때문에 패턴 발화보다 더 넓은 적용 범위를 가집니다.
  {% endhint %}

또한, 머신러닝을 사용한 챗봇은 패턴 매칭만 사용하는 챗봇에 비해 훨씬 똑똑한데요. 아래 그림에서 보실 수 있듯이 머신러닝 발화와 패턴 발화를 같이 입력한 봇은 패턴 발화만 입력한 봇에 비해 사용자 발화에 대한 대응 범위가 넓어집니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FHhpw4sfongyOGi6y6paj%2Fml-01%402x.png?alt=media&amp;token=d1a14d8e-f1bd-4c84-8415-ba6b2aa61c46" alt=""><figcaption><p>머신러닝 유무에 따른 사용자 발화 대응 범위</p></figcaption></figure>

이렇게 유용한 머신러닝을 사용하는 방법은 어렵지 않습니다! 자세한 사용법은 이후 튜토리얼의 주요 기능 사용법 중 '[**머신러닝 사용하기**](#use_machine_learning)'에서 볼 수 있습니다.

## 머신러닝 사용하기 <a href="#use_machine_learning" id="use_machine_learning"></a>

머신러닝을 사용하여 똑똑한 챗봇을 만들기 위해서는 크게 4가지 단계를 거쳐야 합니다. 그럼 아래에서 하나씩 살펴볼까요?

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FQKFYLDKKnD8bvZ8NIBlj%2Ftutorial-ml-01%402x2.png?alt=media&amp;token=91b2847b-a843-409c-9483-441813b9c3dd" alt=""><figcaption></figcaption></figure>

### 머신러닝 발화 입력 <a href="#input_utterance" id="input_utterance"></a>

머신러닝을 하기 위해서는 머신러닝 발화가 필요합니다. 그리고 머신러닝 발화를 입력하는 방법은 아래 3가지가 있습니다.

#### Step 1. 직접 입력

우선 머신러닝 발화를 직접 입력하는 방식이 있습니다. 이 방식을 사용하기 위한 방법은 아래와 같습니다.

1.1 블록 상세에서 머신러닝 발화 관리 버튼을 눌러주세요.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F4ls3vTTrt370GOZbTGrq%2Ftutorial-ml-02%402x2.png?alt=media&amp;token=10d9b30a-9c89-4cb5-8962-31e9d73a8597" alt=""><figcaption></figcaption></figure>

1.2 머신러닝 발화 관리 팝업에서 머신러닝 발화를 입력해주세요.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FDfipH7ceayXJLm35NUBK%2Ftutorial-ml-03%402x2.png?alt=media&amp;token=cc79d3c5-306b-4b5b-b872-72816192d17c" alt=""><figcaption></figcaption></figure>

#### Step 2. 패턴 발화 복사

머신러닝 발화를 따로 입력하시는게 귀찮고, 번거로우시다면 패턴 발화에 입력된 발화를 복사하여 머신러닝 발화에 붙여넣는 기능이 있습니다. 패턴 발화와 머신러닝 발화를 따로 관리하지 않아도 된다는 것이 장점인 기능입니다. 사용 방법은 아래와 같습니다.

2.1 머신러닝 발화 관리 팝업에서 ‘패턴 발화를 머신러닝 발화로 복사’ 기능을 ON으로 바꿔주세요.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FEDOIMwrPfPOpnZM9ufZH%2Ftutorial-ml-04%402x2.png?alt=media&amp;token=8d10a2aa-64ff-49cb-8e38-4dd29dab793a" alt=""><figcaption></figcaption></figure>

2.2 패턴 발화가 머신러닝 발화로 복사된 것을 확인하실 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F5NVRR2sFEZti4XftCIaC%2Ftutorial-ml-05%402x2.png?alt=media&amp;token=605f4dd4-7d70-4f9d-8eb0-ed337b57fc62" alt=""><figcaption></figcaption></figure>

{% hint style="danger" %}
**Caution.**

* 패턴 발화 복사는 최신 입력순으로 **최대 2000개**까지만 복사됩니다.
* 기능을 해제하면 복사되었던 **모든 패턴 발화가 삭제**됩니다.
  {% endhint %}

#### Step 3. 업로드

혹시 서비스를 위한 사용자 예상 발화를 엑셀로 관리하고 계셨나요? 많은 발화를 한번에 업로드할 수 있는 방식도 있습니다. 사용법은 아래와 같습니다.

3.1 머신러닝 발화 관리 팝업에서 기능 탭의 ‘파일 업로드’를 눌러주세요.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F0gwK7fJANCelx4dHykZy%2Ftutorial-ml-06%402x2.png?alt=media&amp;token=8fec0840-96df-4008-9e42-6588d67c064f" alt=""><figcaption></figcaption></figure>

3.2 utf-8로 인코딩된 CSV로 발화를 업로드해주세요.

{% file src="/files/EPbZHBO44wlH9131ZaAG" %}

{% hint style="danger" %}
**Caution.**

* 업로드 파일은 **CSV utf-8**만 지원합니다.
* 업로드는 한번에 **최대 2000개**까지 지원합니다.
  {% endhint %}

**머신러닝 발화 작성 시, 똑똑한 챗봇을 만들기 위한 몇 가지 팁을 다음과 같이 알려드립니다.**

{% hint style="success" %}
**TIP**

1. 서술어를 다양하게 쓰기\
   예) 노래 틀어줘, 노래 불러봐, 노래 시작 등
2. 엔트리를 다양하게 쓰기\
   예) 아이유 노래, 방탄 노래, 너바나 노래, 스탄 게츠 노래 등
3. 어순을 다양하게 쓰기\
   예) 노래 틀어줘, 틀어줘 노래 등
   {% endhint %}

{% hint style="danger" %}
**Caution.**

동일한 서술어, 어순, 엔트리를 많이 입력할 경우, 오버피팅 현상이 발생하여 챗봇의 인탠트 구분 정확도가 떨어질 수 있습니다.
{% endhint %}

### 머신러닝 실행 <a href="#excute_machine_learning" id="excute_machine_learning"></a>

머신러닝 발화를 모두 입력했다면 이제 학습 모델을 만들기 위하여 머신러닝을 실행하셔야 합니다! 그 전에 머신러닝을 실행하기 위한 조건이 충족되었는지 확인 한 번 해볼까요?

머신러닝 실행 조건은 아래와 같습니다

(1) 2개 이상의 머신러닝 대상 블록\
(2) 각 블록당 패턴 발화 1개 이상, 머신러닝 발화 20개 이상 존재

만약 실행 조건을 충족시키셨다면 실행 방법은 간단합니다. 아래를 참조해주세요.

1. 오른쪽 상단의 머신러닝 실행 버튼을 눌러주세요.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FINZG5kfaqdsClKGxAJY1%2Ftutorial-ml-07%402x2.png?alt=media&amp;token=07eb577d-9474-4f6c-ba63-41438977606e" alt=""><figcaption></figcaption></figure>

2. 머신러닝 대상 블록과 예상 소요 시간을 확인하고, ‘실행’ 버튼을 눌러주세요.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FogjFKJW0kY9hSVSjzUPc%2Ftutorial-ml-08%402x2.png?alt=media&amp;token=4cb5638a-c508-4aef-aba8-4338e3258884" alt=""><figcaption></figcaption></figure>

3. 머신러닝 예상 소요 시간을 확인할 수 있으며, 예상 소요 시간이 길 경우에는 ‘확인’ 버튼을 눌러 머신러닝 진행과 병행하여 작업을 할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FnRILxxEhIm0RlBPxunf1%2Ftutorial-ml-09%402x2.png?alt=media&amp;token=eb6e6923-4795-4e9c-9c17-c12feb932195" alt=""><figcaption></figcaption></figure>

### 성능 테스트 및 최소 답변 정확도 조절 <a href="#test_and_correction" id="test_and_correction"></a>

한 번의 머신러닝 실행이 끝났다고 챗봇이 완벽해지기는 힘듭니다. 그래서 학습 모델의 완성도를 측정하기 위해 테스트를 진행해야 합니다.\
\
테스트를 위해서는 우선 테스트 발화 세트를 구성해야합니다. 구성 방법은 아래와 같습니다.

1. 기존의 패턴 발화, 머신러닝 발화에 입력된 발화 말고, 새로운 발화를 모읍니다.
2. 간단한 발화로 작동하는 블록은 5\~10개, 복잡한 발화로 작동될 수 있는 블록은 20\~30개정도를 준비합니다.

\
테스트 발화가 준비되었다면, 이제 챗봇에 테스트 발화를 입력하시면 됩니다.

테스트를 진행해보면 발화를 입력하고 연결된 블록이 적절하지 않거나, 틀린 경우가 발생할 수 있습니다. 이럴 경우에는 최소 답변의 정확도를 설정하여 정확도가 낮은 발화에 대해 블록이 연결되지 않게 설정할 수 있습니다.

최소 답변 정확도 설정은 '머신러닝' 페이지에서 할 수 있으며, 설정값이 높을수록 정확도가 높은 발화에 대해서만 블록을 연결합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FCLatKOtk0GFN18Zvu48c%2Ftutorial-ml-10%402x2.png?alt=media&amp;token=a66e7ff4-f440-4d9b-849d-0539a8c45dc8" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
**최소 답변 정확도**

* 답변 제공의 기준이 되는 최소 정확도를 의미합니다. 예를 들어, 최소 답변 정확도가 100이라면 정확도가 100인 답변만 제공하며, 최소 답변 정확도가 60이면 정확도가 60 이상인 경우에만 답변을 제공합니다.
* 머신러닝의 최소 답변 정확도는 머신러닝 페이지에서 설정이 가능하며, 지식베이스의 최소 답변 정확도는 즉문즉답형 응답에서 설정할 수 있습니다.
  {% endhint %}

### 오매칭 발화 추가 입력 <a href="#additional_input_mismatching_utterance" id="additional_input_mismatching_utterance"></a>

챗봇이 모든 테스트 발화에 제대로 작동하나요? 만약 생각보다 정답률이 낮다면 아래의 방법으로 챗봇을 튜닝해주세요.

1. 오매칭 발화와 비슷한 발화를 머신러닝 발화에 입력
2. 오매칭 발화를 패턴발화에 입력

\
이 방법을 반복하시면, 정말 똑똑한 봇을 만드실 수 있습니다!


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/machine_learning.md
