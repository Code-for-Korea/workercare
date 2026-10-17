> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/tutorial/make_chatbot/tutorial_2.md).

# 튜토리얼 2단계

**봇의 효율성을 더해주는 플러그인 사용하기**

튜토리얼 1단계를 통해 기본적인 챗봇의 구성을 마쳤다면 플러그인을 활용하여 사용자의 응답을 보다 효율적으로 받을 수 있는 플러그인을 소개해 드리겠습니다.

플러그인은 봇 작업자가 되묻기 질문을 설정하거나 원하는 출력을 설정하여 봇이 ‘별도로 정의 된 질문 혹은 답변'을 하기 위한 기능입니다. 플러그인은 **‘봇 응답 형식에서 사용할 수 있는 플러그인’**&#xACFC; **‘파라미터 설정을 통해 사용할 수 있는 플러그인’**&#xC73C;로 나누어져 있습니다.

**‘케이크 주문 챗봇’** 에서는 **1) 상담직원 연결, 2) 쿠폰 제공, 3) 주문서 작성**을 하기 위해 플러그인을 사용해 보겠습니다. 아래 내용들만 따라오신다면 편리하게 응답받는 플러그인을 포함한 챗봇을 만들 수 있을 것입니다.

## 봇 응답 형식에서 사용할 수 있는 플러그인 <a href="#bot_plugin" id="bot_plugin"></a>

### 상담직원 연결하기 <a href="#connect_staff" id="connect_staff"></a>

봇에 연결된 채널이 채널 관리자센터의 1:1 채팅 또는 상담 톡 기능을 사용할 경우, 상담원 연결 사용이 가능합니다.

버튼 기능에서 플러그인 기능 중 상담직원 연결 기능입니다.&#x20;

상담직원 연결 기능을 클릭하면 대화가 1:1 대화로 넘어가고 사장님은 **채널 관리자 센터 1:1 채팅에서 해당 메시지를 확인할 수 있습니다.**

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FxDieCUPkLjXo63bmy1Zd%2Fcontact_staff.png?alt=media&amp;token=90e70e45-e66a-4e1e-933f-9ffa3fdd07f0" alt=""><figcaption><p>상담직원 연결 플러그인</p></figcaption></figure>

{% hint style="success" %}
**Tip.**

사용자가 챗봇을 통해 원하는 답을 얻기 어려워 폴백으로 떨어지는 경우 폴백 블록에 심어두어 위 상담 플러그인을 이용해 직접 상담을 해주는 방식으로 대응해 줄 수도 있습니다.
{% endhint %}

### 할인 쿠폰 제공하기 <a href="#give_coupon" id="give_coupon"></a>

버튼을 눌렀을 때 카카오톡 채널에 등록된 카카오톡 채널 쿠폰을 연결해 주는 기능입니다. 챗봇에 쿠폰을 연결하기 위해서는 먼저 채널에서 쿠폰을 작성해야 합니다.&#x20;

**채널 관리자 센터에서 쿠폰을 만들 채널을 선택 후 비즈니스 도구 > 쿠폰 작성을 선택하여 쿠폰을 작성 합니다.**

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FbS94Z2AeXI6WG8pd1adu%2Fcoupon.png?alt=media&amp;token=774ab89e-f544-4bbe-ad13-8aff7dbfde27" alt=""><figcaption><p>채널 관리자 센터 쿠폰 작성하기</p></figcaption></figure>

채널 쿠폰 생성 후 버튼 설정에서 플러그인 기능 **‘카카오톡 채널 쿠폰' 을 선택하고 연결할 쿠폰을 적용해 주시면 됩니다.**

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FjqdJJpbnZxGA1HeHerPO%2Fcoupon2.png?alt=media&amp;token=edff6a9e-ba81-4b8f-a047-290d0fcc9f02" alt=""><figcaption><p>카카오톡 채널 쿠폰 플러그인 버튼 설정</p></figcaption></figure>

## 파라미터 설정을 통해 사용할 수 있는 플러그인 <a href="#parameter_plugin_setup" id="parameter_plugin_setup"></a>

파라미터 설정에서 사용할 수 있는 플러그인은 되묻기 질문에서 봇이 필수적으로 받아야 하는 파라미터를 사용자가 좀 더 편리하고 정확하게 입력하도록 돕는 보조 수단입니다.

케이크 주문 챗봇을 예로 들면 사용자가 케이크를 픽업하는 시간을 입력하게 하고 싶을 때 정해진 형식을 제공하지 않는다면 사용자들이 다양한 방식으로 입력할 수가 있습니다.&#x20;

이는 사용자에게 좋지 않은 경험을 제공할 수 있으므로 정확하고 쉽게 입력할 수 있는 ‘정의된 폼’을 플러그인 기능을 통해 제공할 수 있습니다.

### 날짜/시간 플러그인 적용하기 <a href="#day_time_plugin" id="day_time_plugin"></a>

케이크 픽업 시간을 설정하기 위해 필수 파라미터에 플러그인을 적용할 수 있습니다.&#x20;

플러그인을 적용하면 봇 사용자에게 응답을 편리하게 할 수 있도록 유도하고, 봇 작업자는 의도한 발화를 명확하게 전달받을 수 있다는 장점이 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FRVMv0inlVBWPt8ldkhbz%2Fdate_time_plugin.jpeg?alt=media&amp;token=716a97b9-20b7-4708-9238-cf1eb6d66fb4" alt="" width="375"><figcaption><p>날짜 시간 플러그인 적용 화면</p></figcaption></figure>

**필수 파라미터 오른쪽 상단에 플러스 버튼을** 클릭하면 파라미터 만들기 화면이 뜹니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FTseS6wQyVrtz8WTJHrRr%2Ftutorial_plugin_05.png?alt=media&amp;token=3f926230-96ce-4fe6-b1cc-c4491400bc09" alt=""><figcaption><p>필수 파라미터 설정</p></figcaption></figure>

‘플러그인' 버튼을 클릭하면 파라미터 명과 플러그인을 설정할 수 있는 리스트를 보여줍니다.&#x20;

이때 사용자가 원하는 플러그인을 선택할 수 있습니다. **케이크 픽업 시간**을 선택할 수 있는 파라미터가 필요하니 **‘sys.plugin.datetime’**&#xC744; 설정하겠습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FQOhbCSXK4wr2m84Qo5t3%2Ftutorial_plugin_06.png?alt=media&amp;token=2b8db5d4-af13-4175-aa55-7e642b08539b" alt=""><figcaption><p>파라미터 만들기</p></figcaption></figure>

케이크 픽업 시간 플러그인을 설정하고 **되묻기 질문**을 클릭하면

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FnNRdlflXuUBOQhO6ifUm%2Ftutorial_plugin_07.png?alt=media&amp;token=04a6a70c-913b-4baf-8f4d-794df9ae6f59" alt=""><figcaption><p>케이크 픽업 시간 필수 파라미터 설정 화면</p></figcaption></figure>

되묻기 질문의 말풍선을 꾸밀 수 있는 팝업에서 원하는 되묻기 질문을 작성할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F5OKxOC15wj6j8POqM9w8%2Ftutorial_plugin_08.png?alt=media&amp;token=18cb539b-8dbf-4fd7-a702-6ee5d684a4bb" alt=""><figcaption><p>되묻기 질문 작성</p></figcaption></figure>

버튼 명 설정하기를 클릭하면 플러그인의 상세 기능을 설정할 수 있습니다. 상세 설정에서 각 매장의 운영 시간에 맞는 시간과 범위를 선택해 주시면 됩니다!

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FLOi1NsInknT8UacSLwDN%2Ftutorial_plugin_09.png?alt=media&amp;token=6e09fb20-ba36-435b-9970-6b06cf4094cc" alt=""><figcaption><p>날짜/시간 플러그인 픽업 시간 설정하기</p></figcaption></figure>

## 주문서 작성하기 <a href="#make_order" id="make_order"></a>

### 되묻기 질문 설정 <a href="#setting_question" id="setting_question"></a>

되묻기 질문 버튼을 클릭하면 각 필수 파라미터에 올바른 값이 채워지도록 사용자를 유도하는 되묻기 질문을 설정할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FUVuDr9klsSZFzH024IPv%2Ftutorial_question_01.webp?alt=media&amp;token=5ae8f269-4dc0-47b3-9fe5-f7e42b01ec10" alt=""><figcaption><p>되묻기 질문 설정하기</p></figcaption></figure>

각 필수 파라미터에 대한 되묻기 질문 작성 예시를 보여드리겠습니다.&#x20;

cake\_design 파라미터에 대한 되묻기 질문입니다. **‘케이크 디자인을 선택해주세요!’ 라는 되묻기 질문**을 작성하였고

cake\_design 엔티티에는 **카카오 케이크에서 주문할 수 있는 모든 케이크 메뉴**를 입력해 놓았습니다.(플라워, 팔레트, 탄생화, 커스텀)

또한 **바로연결 응답에도** cake\_design 엔티티에 입력해둔 동일한  **카카오 케이크에서 주문할 수 있는 모든 케이크 메뉴**를 입력해 놓았습니다. (플라워, 팔레트, 탄생화, 커스텀)

되묻기 질문은 플라워, 팔레트, 탄생화, 커스텀 이라는 정답이 들어와야만 다음 질문으로 넘어갑니다.

따라서 바로 연결 응답에 예상 발화를 미리 입력해둔다면 사용자는 봇 디자이너의 의도대로 정확한 답변을 하는데 도움이 됩니다.

되묻기 질문 팝업은 되묻기 질문 응답, 바로 연결 응답, 되묻기 허용 횟수 설정, 되묻기 유효시간 설정으로 구성됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FJTe98oEGwEpRMU1KvACX%2Ftutorial_question_02.png?alt=media&amp;token=2d736e3c-99e1-4943-a174-7e5caccd6a92" alt=""><figcaption><p>케이크 디자인 되묻기 질문</p></figcaption></figure>

{% hint style="info" %}
**Information.**

* **되묻기 질문 응답 :** 되묻기 질문을 정의합니다. 총 3개 까지 정의할 수 있으며, 사용자에게 출력되는 허용 횟수 안에서 무작위로 출력됩니다.
* **바로 연결 응답 :** 사용자가 되묻기 상황에서 입력할 파라미터 값을 직접 ‘바로 연결' 버튼으로 클릭해서 보낼 수 있도록 세팅합니다.
* **되묻기 허용 횟수 설정 :** 되묻기 질문이 실행될 횟수를 선택합니다. 최대 허용 횟수가 끝나서 결국 원하는 파라미터 값을 획득하지 못했을 때, 사용자에게 출력할 안내메시지 또한 정의할 수 있습니다.
* **되묻기 유효시간 설정 :** 시나리오 공통에서 되묻기 유효시간을 10\~120분까지 자유롭게 설정할 수 있습니다. 되묻기 질문에서 응답까지 모두 완료되는 상황에서 유효시간이 존재하며 응답까지 완료된 뒤 상태의 되묻기 질문을 다시 사용하면 정상 응답이 되지 않습니다.
  {% endhint %}

### 되묻기 질문 확인 <a href="#check_question" id="check_question"></a>

모든 설정이 완료되었나요? 그렇다면 카카오톡 화면에서 최종 응답을 아래 이미지와 같이 확인할 수 있습니다.&#x20;

봇은 되묻기 질문을 통해 필수 **파라미터 값인 케이크 사이즈, 케이크 디자인, 케이크 맛, 케이크 문구**를 입력받고 최종 응답을 출력하였습니다.

되묻기 질문을 완료한 후, 주문을 확정하기 위해 생성한 응답입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F4glfhT9ZJ1Kj7VGmGlea%2Forder_cake.jpeg?alt=media&amp;token=db916bde-9790-47d5-b7dd-c9f82d45890d" alt="" width="375"><figcaption><p>되묻기 질문 최종 응답</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fao5VJj0hlrOrfxvXEsNu%2Ftutorial_question_04.png?alt=media&amp;token=8a21afd9-5ea9-458f-9b28-f5cb98034946" alt=""><figcaption><p>되묻기 질문 봇 응답 화면</p></figcaption></figure>

**‘확인 했습니다.’** 버튼을 누르면 봇을 통한 주문 프로세스가 완료되게 됩니다.

**'다음에 다시 주문하겠습니다.'** 를 누르면 주문 프로세스가 종료되는 답변이 출력되며&#x20;

마지막으로 **'주문서를 다시 작성할래요.'** 버튼을 클릭하면 케이크 메뉴 블록으로 넘어가며 사용자가 주문을 다시 할 수 있도록 유도할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FjjCiVqqv1DePV8NZEVzh%2Fbot_talk_1.jpeg?alt=media&amp;token=e8402a43-ad4e-4b92-9c10-a67c8140902c" alt="" width="375"><figcaption></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FwivR5mey32wlEaLvOCPQ%2Fbot_talk_2.jpeg?alt=media&amp;token=72b3e213-eae3-4766-b323-0df2130485b6" alt="" width="375"><figcaption></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FsJY1UGJL91q3v7E6hujZ%2Fbot_talk_3.jpeg?alt=media&amp;token=4ebb2650-124c-48f0-aceb-767f82b5f6eb" alt="" width="375"><figcaption></figcaption></figure>

마무리된 답변의 내용 확인은 연결된 스킬을 통해 확인이 가능합니다.

따라서 실제 판매/예약 등의 챗봇 제작을 위해서는 [스킬](https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide)을 연결하여 주시기 바랍니다.


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/tutorial/make_chatbot/tutorial_2.md
