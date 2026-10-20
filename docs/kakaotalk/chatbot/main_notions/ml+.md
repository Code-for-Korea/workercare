> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/ml+.md).

# ML+

**ML+**&#xB294; 문장 간의 의미론적인 유사성을 측정해 사용자의 다양한 의도를 하나의 의도로 해석하여 인텐트를 분류합니다.\
즉, 등록된 패턴 발화와 인입된 사용자 발화 간의 유사도를 측정하여 가장 유사한 블록으로 매칭하는 방식입니다.\
등록된 패턴 발화와 사용자 발화 텍스트는 벡터로 치환되어 패턴 발화와 의미적으로 가장 유사한 인텐트로 분류됩니다. 이때 ML+를 통해 의도에 적합한 답변 블록을 확인할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F3RJ5ZPGgVvQdNkkfZo04%2Fml%2B1.webp?alt=media&amp;token=6dc18c1b-726e-4de4-8100-36857b5ba0eb" alt=""><figcaption></figcaption></figure>

챗봇 관리자센터에서 제공하는 ML+는 블록별 머신러닝 발화 관리가 필요 없이 인텐트 목적에 맞는 최소한의 패턴 발화만으로 동작하여 보다 쉽게 챗봇을 디자인할 수 있습니다. 또한 사용자의 다양한 의도를 발화 유사도로 인텐트를 분류해내기 때문에 폴백 블록의 발생 비율도 줄어들게 됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FT6nV78IrEflZU42AgDz8%2Fml%2B2.png?alt=media&amp;token=969bef51-4137-4fea-9e1e-c1ffaa2ee70f" alt=""><figcaption></figcaption></figure>

이 과정에서 의미적으로 유사한 수치를 조절할 수 있는 기능이 제공됩니다. 머신러닝 페이지에서는 발화 유사도(문장 간 유사도의 스코어) 기능을 사용하여 블록의 매칭 범위를 조절할 수 있습니다. 각 유사도 단계에 따라 조정되는 패턴 발화 매칭 범위와 정확도를 참고하시어 발화 유사도를 조절해보세요.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FlvvzMD82ZNSFoE2KD1ly%2Fml%2B3.png?alt=media&amp;token=4f90e1e7-5376-46dc-bedf-17fffe617dc0" alt=""><figcaption></figcaption></figure>

{% hint style="danger" %}
**Caution.**

ML+는 순차적으로 적용될 예정입니다. 머신러닝 탭 또는 봇 목록에 ML+ 뱃지가 추가되었는지 확인해주세요.
{% endhint %}

{% hint style="info" %}
**Information.**\
ML+는 BERT Language Model을 활용하고 있습니다.\
\- BERT Language Model : Transformer를 기반으로 한 쌍방향 인코더 표현(Bidirectional Encoder Representations from Transformers)의 약자로, 문장 단위의 임베딩(Embedding)을 만들 수 있도록 파인튜닝(Fine Tuning)하여 사용자 발화 의도 분류에 사용되고 있습니다.
{% endhint %}

## ML+ 사용하기 <a href="#use_ml" id="use_ml"></a>

ML+를 사용하기 위해서는 아래 과정이 필요합니다. 한번 살펴볼까요?

### **Step 1. ML+ 적용여부 확인** <a href="#check_ml_whether_to_apply" id="check_ml_whether_to_apply"></a>

우선 ML+가 사용 가능한 상태인지 확인해주세요. ML+가 적용된 경우, 봇 목록과 머신러닝 탭에 ML+ 뱃지가 추가되어 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FfUXzPO1w6m4o1H1DcQeb%2Fmlbot1.png?alt=media&amp;token=4ec9546e-0c9c-4175-ac3f-ea52adcc55d1" alt=""><figcaption><p>봇 목록 > 봇 이름 우측 ML+뱃지</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FRYB5UR0sNygjQvlYJSFz%2Ftutorial-ml%2B-check02.png?alt=media&amp;token=dd66d07f-8dfc-482f-8d57-989f96aac593" alt=""><figcaption><p>머신러닝 탭 > 우측 ML+ 뱃지</p></figcaption></figure>

### **Step 2. ML+ 발화 관리** <a href="#manage_ml_utterance" id="manage_ml_utterance"></a>

ML+는 별도의 발화를 입력하고 관리하는 과정이 생략되었기 때문에 기본적으로 패턴 발화 입력이 필수적입니다.\
그렇기 때문에 각 블록에 패턴 발화 의미군집이 잘 모일 수 있도록 패턴 발화들을 관리하는 것이 가장 중요합니다.

패턴 발화 입력의 상세한 설정 방법은 [**주요 개념>발화 패턴**](/main/tool/chatbot/main_notions/utterance_pattern.md)을 참고하시길 바랍니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FbnR9lkiywi1wHfl9k8RU%2Ftutorial-ml%2B-utterence-example01.png?alt=media&amp;token=d188a5b9-6ba4-4dac-aaf7-c68444acd0f2" alt=""><figcaption></figcaption></figure>

{% hint style="success" %}
**Tip.**

위 사례의 경우, ‘배송 확인' 블록에 배송 정보의 의도를 가진 발화들이 등록된 것을 보실 수 있습니다. 이처럼 하나의 블록에는 동일한 의도(인텐트)의 패턴 발화가 모여있어야 합니다.

예를 들어, '주문내역 알려줘'와 같은 발화는 ‘배송 확인' 블록이 아니라, ‘주문 확인' 블록에 등록하시는 것이 더 적합할 것입니다.
{% endhint %}

### Step 3. ML+ 실행 <a href="#run_ml" id="run_ml"></a>

만약 머신러닝 사용이 불필요하다면 각 시나리오와 블록별로 머신러닝 기능을 끄고 켤 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F1IjTDg6S7u391KRgc0y9%2Ftutorial-ml%2B-start.png?alt=media&amp;token=1a4355c2-bf00-48fd-9965-a43658a19ce1" alt=""><figcaption></figcaption></figure>

{% hint style="danger" %}
**Caution.**

머신러닝 기능을 사용하지 않으실 경우 등록한 패턴 발화에 정확히 일치하는 발화문이 입력된 경우에만 블록으로 연결됩니다.
{% endhint %}

또한, ML+는 별도의 실행 과정이 없이 ‘봇 배포' 시 머신러닝 결과가 즉시 반영됩니다. 머신러닝 실행 후 봇에 반영하기 위해 봇 배포를 진행하던 과정이 한 단계 줄어들어 편리하게 머신러닝을 활용할 수 있습니다.

### Step 4. ML+ 발화 유사도 조절 <a href="#control_ml_similarity" id="control_ml_similarity"></a>

발화 유사도는 최초에 권장설정 구간인 ‘유사도 보통’ 으로 설정되어 있으며, 비권장 구간인 ‘유사도 낮음' 이하의 발화 유사도는 설정이 불가합니다.

봇 디자이너는 등록한 패턴 발화와 어느정도까지 유사한 발화가 인입되었을때 동일한 인텐트의 블록이 출력되는지 확인할 필요가 있습니다.\
\
기본적으로 등록된 패턴 발화와 완벽하게 동일한 사용자 발화는 매우 높은 유사도 점수를 갖게 되어 분류됩니다. 이외 어순 등의 변경으로 발생하는 문장의 경우는 ML+를 통하여 분류하게 됩니다.\
\
우리는 이러한 ML+의 완성도를 측정하기 위해 봇테스트를 진행해야 합니다. 테스트를 위해서는 우선 테스트 발화 세트를 구성해야하며, 구성 방법은 아래와 같습니다.\
\
기존의 패턴 발화와 의도가 비슷한 테스트 발화를 준비합니다.

{% hint style="success" %}
**Tip.**

아래 예시를 참고하시어 테스트 발화를 등록해 보세요.

1. 패턴 발화 : 카페라떼 가격 궁금해
2. 테스트 발화 : 카페라떼의 가격이 궁금합니다, 가격 라떼 궁금해 등
   {% endhint %}

테스트 발화가 준비되었다면, 이제 챗봇에 테스트 발화를 입력하시면 됩니다.

봇테스트를 진행해 보면 발화를 입력했을 때 연결된 블록이 적절하지 않거나, 틀린 경우가 발생할 수 있습니다. 이럴 경우에는 블록별 의미 군집이 잘 모여있는지 확인하시거나, ‘발화 유사도’를 조정하시면 됩니다.

{% hint style="info" %}
**발화 유사도 설정**

* **발화 유사도가 낮을수록** 등록한 패턴 발화로의 **매칭 범위가 넓어지며**, 입력한 패턴 발화와 **유사하지 않은 발화**도 블록으로 매칭될 수 있습니다.
* **발화 유사도가 높을수록** 등록한 패턴 발화로의 **매칭 범위가 좁아지며**, 입력한 패턴 발화와 **정확히 일치하는 발화**만 블록으로 매칭됩니다.
* 유사도 수준에 따라 어느 정도의 발화까지 인식하여 블록으로 연결할 수 있는지 예시를 제공하고 있으니 참고해 주세요.
  {% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fiyk5GtmsQqKNRY42thuj%2F%E1%84%8B%E1%85%B2%E1%84%89%E1%85%A1%E1%84%83%E1%85%A9.png?alt=media&amp;token=13bf0d71-974a-4c00-bdb6-6fb8b60ab145" alt=""><figcaption></figcaption></figure>


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/ml+.md
