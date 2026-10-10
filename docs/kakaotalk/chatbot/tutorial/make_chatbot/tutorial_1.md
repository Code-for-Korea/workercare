> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/tutorial/make_chatbot/tutorial_1.md).

# 튜토리얼 1단계

## 새로운 봇 만들기 <a href="#make_new_bot" id="make_new_bot"></a>

챗봇 관리자센터에서는 간단하게 봇 이름만 입력하여 챗봇을 만들 수 있습니다. 챗봇을 생성하는 과정은 아래와 같습니다.

### Step 1. 로그인 후 아래 화면과 같이 비어있는 '나의 봇' 목록 확인합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FWc014EVvP54u6cEfskuo%2Fmakingbot.png?alt=media&amp;token=3e5a2460-ff8f-4b50-a739-709c207d09a0" alt=""><figcaption><p>비어 있는 봇 목록화면입니다.</p></figcaption></figure>

### Step 2. **우측 상단의 봇 만들기 버튼을 누르고, 카카오톡 챗봇을 선택합니다.**

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FPF4OYdyRa356QzKwvN4h%2Fkey-features-createbot-2.png?alt=media&amp;token=3d60a57f-60ad-42e8-993f-36c7f1c53eaf" alt=""><figcaption><p>카카오톡 챗봇과 보이스봇(Closed Beta Test) 선택 팝업</p></figcaption></figure>

### Step 3. **봇 이름을 적고 확인을 누르면 생성이 완료되고 제작 페이지로 이동하게 됩니다.**

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FMLtyM3cptzGDsrYSlF25%2Fcreate_cake_order_chatbot.png?alt=media&amp;token=91936e80-4c56-4e41-99f0-e08756bacf4d" alt=""><figcaption><p>공백 포함 최대 20자까지 한글, 영어, 숫자, 공백, 언더바('_'), 대쉬('-')만 입력 가능합니다.</p></figcaption></figure>

## 시나리오 <a href="#scenario" id="scenario"></a>

봇 생성 후 가장 먼저 해야 할 일은 시나리오를 만드는 일입니다. 시나리오는 블록을 담을 수 있는 서비스의 단위를 의미합니다.                                                  &#x20;

내 비즈니스에 필요한 것이 어떤 서비스인지 구상하고 시나리오를 생성하시면 됩니다.

### 시나리오 생성하기 <a href="#create_scenario" id="create_scenario"></a>

'+ 시나리오' 버튼을 클릭하면 ‘시나리오 01’, ‘시나리오 02’ … 순서로 시나리오가 추가됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FthDfxkMZ1ggIHQDgfv5o%2Fcreate_scenario.png?alt=media&amp;token=6c3b7c0b-482d-41ee-ab27-fb323ec09c41" alt=""><figcaption><p>+시나리오 버튼</p></figcaption></figure>

추가된 시나리오 오른쪽 더 보기 아이콘을 클릭하면 손쉽게 시나리오를 편집하고 삭제할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FuTCQOiQo8nGP3v20ZeFx%2Fedit_scenario.png?alt=media&amp;token=a9ce6ec5-dae7-4a23-b584-bd9df6ee7b8d" alt=""><figcaption><p>시나리오 편집 삭제 버튼</p></figcaption></figure>

케이크 주문 챗봇을 만드는 데 필요 시나리오로 정의 하였던 **‘처음으로', ‘케이크 주문하기', ‘케이크 메뉴 설명', ‘FAQ’, ‘매장 안내'** 시나리오를 추가합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FhEv9SsrLsrVCYJttj7ap%2Fadd_scenario.png?alt=media&amp;token=7647d238-6ad8-4bc5-8c29-871bd55ff0c8" alt=""><figcaption><p>시나리오 추가 완료 화면</p></figcaption></figure>

**되묻기 질문은 챗봇이 대화 중에 사용자가 하는 말을 알아듣지 못하여 거꾸로 질문을 던지는 액션을 의미합니다.**&#x20;

케이크 주문 챗봇을 예로 들면 케이크를 주문하려면 사용자가 주문하고 싶은 디자인, 케이크 사이즈 등등 모두 봇이 발화를 의도에 맞게 인식해야 올바른 주문을 할 수 있습니다.&#x20;

따라서 봇은 동작에 필요한 특정 값을 알아내기 위해 사용자에게 **역으로 질문을 던지는 액션**을 취해야 합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FawvftywAlPqRjyRUQgYH%2Fsetting_scenario.png?alt=media&amp;token=59f65cd8-2763-4fc2-ab0b-21adb9eb1758" alt=""><figcaption><p>시나리오 설정 > 되묻기 기능 공통 설정</p></figcaption></figure>

봇 안에서 쓰이는 모든 시나리오에 공통으로 적용할 되묻기 기능은 1) 되묻기 최대 횟수, 2) 되묻기 최대 시간을 선택하고 각각의 경우 유효 조건을 초과할 때 출력될 안내 메시지를 설정할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F5hzwnxGg98bhLr9xio59%2F%E1%84%89%E1%85%B5%E1%84%82%E1%85%A1%E1%84%85%E1%85%B5%E1%84%8B%E1%85%A9%E1%84%80%E1%85%A9%E1%86%BC%E1%84%89%E1%85%A5%E1%86%AF.png?alt=media&amp;token=dbc02088-ca9f-4e75-8c1a-1388b954094e" alt=""><figcaption><p>시나리오 설정</p></figcaption></figure>

## 블록 <a href="#block" id="block"></a>

블록은 사용자 의도의 기본 단위로 인텐트(intent)이며 사용자 예상 발화와 봇이 수행할 액션과 응답할 내용이 설계됩니다.

* **‘케이크 메뉴’ 블록 :** 케이크 주문 챗봇의 4가지 메뉴를 소개하는 블록
* **‘케이크 픽업’ 블록 :** 매장 위치를 카카오맵으로 보여주는 블록
* **‘SNS’ 블록 :** SNS 링크 연결 블록
* **‘매장 안내’, ‘FAQ’ 블록 :** 다른 블록과 연결할 블록

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F2zLTKXNgLAVQqrUI7zMW%2Fcake_order_bot_1.png?alt=media&amp;token=68cd7eea-cf2e-48a2-803a-6c31771d7965" alt=""><figcaption><p>케이크 주문 챗봇 블록 구성 화면</p></figcaption></figure>

### '처음으로' 블록 만들기 <a href="#make_start_block" id="make_start_block"></a>

‘처음으로' 블록은 봇의 메인 화면이라고 생각하시면 됩니다.&#x20;

사용자가 봇을 사용하다 길을 잃었을때 '처음으로'블록으로 보내주어 다시 봇을 사용할 수 있게 메인 화면을 제공할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FbO9QfsKwlkSYOF7BREcz%2Fcake_order_bot_start.png?alt=media&amp;token=59dc39fa-d290-4062-9903-29d5023c3fb8" alt=""><figcaption><p>‘처음으로' 블록</p></figcaption></figure>

### Step1. 연결할 블록 생성하기

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FI8J0Ck1sLN9vcCwTObjI%2Fcreate_block_for_connect.png?alt=media&amp;token=2fa8bd49-359a-4a64-8522-898eb212563a" alt=""><figcaption><p>이름만 설정하고 필요 시나리오에 블록을 추가한 이미지</p></figcaption></figure>

### Step2. 봇 응답 설정하기 - 카드형

아래 이미지처럼 ‘처음으로' 블록을 만들기 위해서는 카드형 봇 응답을 설정해야 합니다. 봇 응답에서 ‘카드형'을 선택하고

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FGHXnSpfCccE7SCxfBSgG%2Ftutorial_block_05.png?alt=media&amp;token=8fd10b11-8073-48da-ac14-dc219c4e43ec" alt=""><figcaption><p>봇 응답 이미지</p></figcaption></figure>

‘+’ 버튼을 눌러 카드를 추가합니다.&#x20;

그 후 ‘이미지 설정' 버튼을 눌러 원하는 이미지를 업로드 하고 타이틀과 설명을 입력하시면 됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FwwJhLyNpOcCU1Ta0DNMw%2Ftutorial_block_06.webp?alt=media&amp;token=53effd78-50de-4ebb-8927-4dc978c1978c" alt=""><figcaption><p>봇 응답 설정 이미지</p></figcaption></figure>

### Step3. 버튼에 블록 연결하기

**Step 1. 에서 만든 블록을 버튼에 연결할 차례입니다.**&#x20;

버튼 추가 > 버튼 설정에서 버튼 이름과 연결할 블록을 선택하고 ‘확인’을 누르면 버튼에 블록을 연결한 카드형 응답이 생성된 것을 확인할 수 있습니다.&#x20;

원하는 카드의 개수만큼 똑같이 작업해 주시면 ‘처음으로'와 같은 블록을 만들 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FR9mSXL65vsEKLkUFXoph%2Fconnect_button_to_block.png?alt=media&amp;token=488c14f8-fea1-4da4-852b-157221dacd55" alt=""><figcaption><p>버튼에 블록 연결 하기</p></figcaption></figure>

### '케이크 메뉴' 블록 만들기 <a href="#make_block_cakemenu" id="make_block_cakemenu"></a>

이제 기초가 되는 블록인 ‘처음으로' 블록을 생성했다면 조금 더 상세한 기능들이 포함된 블록들을 소개해 드리겠습니다.

케이크 주문 챗봇은 **팔레트, 플라워, 탄생화, 커스텀** 까지 총 4가지 종류의 케이크를 판매하고 있습니다.&#x20;

응답은 카드형에 이미지를 삽입하고 이미지 타입은 정사각형으로 설정하였고 아래 텍스트는 ‘팔레트 케이크' 라는 타이틀을 입력하고 설명에는 가격을 작성하였습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FgI7eVUKYJuRY4RDTcNc3%2Fimage_upload.png?alt=media&amp;token=58cdb5f4-b160-4c0f-9e34-7f822fc89b55" alt=""><figcaption><p>이미지 설정 업로드</p></figcaption></figure>

**케이크 메뉴 하단 버튼은 ‘메뉴 설명’과 ‘주문 하기’로 만들어 두고 케이크 메뉴 설명 시나리오에 팔레트 블록과 연결해 주었습니다.**&#x20;

‘주문 하기’는 주문 양식 블록과 연결하였습니다.&#x20;

팔레트 케이크를 성공적으로 작성하였다면 다른 메뉴들도 동일하게 추가하시면 됩니다.

{% hint style="success" %}
**Tip.**&#x20;

설명은 2줄 이하로 작성하는 것이 좋습니다. 2줄이 넘어갈 경우 챗봇에서 "…" 으로 표기됩니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F5UmTJMwGyX6E8NPGjtuH%2Fconnect_button.png?alt=media&amp;token=02810371-42f1-4889-a4cd-1b89762df0cf" alt=""><figcaption><p>케이크 메뉴 하단 버튼 연결</p></figcaption></figure>

### '메뉴 설명' 블록 만들기 <a href="#introduce_menu" id="introduce_menu"></a>

메뉴 설명 블록입니다.&#x20;

이미지형 응답에는 팔레트 케이크 사진을 추가하고, 텍스트형 응답에는 팔레트 케이크 설명과 ‘팔레트 케이크 주문하기’ 버튼을 추가하였습니다.&#x20;

팔레트 케이크 주문하기 버튼을 누르면 ‘주문 양식' 블록으로 이동합니다. ‘주문 양식’ 블록을 만드는 방법은 아래 주문서 작성하기에서 설명하겠습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FRyu0UqpQFqPYwA57IEnT%2Fpalette_1.png?alt=media&amp;token=cd7334ad-9f54-484a-ba96-a20141762241" alt=""><figcaption></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FjCI4lgSYuY8ECgEnLzLL%2Fpalette_cake_2.png?alt=media&amp;token=d62fc14d-488f-4cb0-b0bf-a2f58689fac0" alt=""><figcaption><p>메뉴 설명 블록</p></figcaption></figure>

### SNS 블록 만들기

SNS 블록은 URL 링크 버튼을 추가하였습니다.&#x20;

웹 뷰로 바로 연결되는 버튼으로 다른 URL로 넘어가는 사용자의 액션이 필요할 때 사용할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FeUrhnK32OPmRFptlhKeO%2FSNS.png?alt=media&amp;token=52646981-fcd0-4ccf-81ff-5b618871c2c1" alt=""><figcaption><p>SNS 블록 URL 링크 추가</p></figcaption></figure>

### 매장으로 연락하기 버튼 설정하기 <a href="#contact_store" id="contact_store"></a>

다른 블록으로 연결하는 것 이외에도 **버튼 기능은 블록 연결, 전화, 메시지 전송** 등 다양한 기능을 수행할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FasnKbTSgZAcFDRSfMiod%2Fcall_store.png?alt=media&amp;token=0a52d567-2149-44d7-a3ef-a4c8e541ed48" alt=""><figcaption><p>매장으로 연락하기 블록 설정</p></figcaption></figure>

‘전화’ 기능은 버튼 클릭 시에 전화를 걸 수 있는 기능입니다.&#x20;

버튼 기능 우측에 매장 전화번호를 추가하면 전화번호 제공이 가능합니다.

### 웰컴 블록 설정하기 <a href="#setting_welcome" id="setting_welcome"></a>

웰컴 블록은 사용자가 봇에 처음 진입했을 때 사용자를 환영하는 블록입니다. 최초 1회 진입했을 때만 나타나며 그 이후에는 사용자가 재진입하여도 웰컴 블록이 나타나지 않습니다.&#x20;

**웰컴 블록은 챗봇을 사용하는 채널의 첫인상 입니다. 채널의 소개나 요약을 압축해서 안내하면 채널의 목적을 사용자들에게 빠르게 인지시켜줄 수 있습니다.**

케이크 주문 챗봇 웰컴 블록입니다. 매장 이미지와 두 번째 텍스트, 마지막 카드형 케로셀을 설정하였습니다.&#x20;

{% hint style="danger" %}
**Caution.**

웰컴 메시지는 야간에도 발송될 수 있어, 광고성 내용이 포함되면 과태료가 부과될 수 있으니 주의해주세요.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FOEGFpOHnbPKnj0fxedQS%2Fcake_order_bot_1.png?alt=media&amp;token=725da091-743f-4789-91f3-ad10caab5a7b" alt=""><figcaption><p>케이크 주문 챗봇 웰컴 블록</p></figcaption></figure>

먼저 웰컴 블록을 사용하려면 왼쪽 웰컴 블록 메뉴에 들어가서 오른쪽 상단에 미사용 버튼을 사용 중으로 바꿔주어야 합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FkWma3IvX2RrISkg3Z8Am%2Fwelcome.png?alt=media&amp;token=f0498c55-ae26-4dbf-96e1-ce20014b7868" alt=""><figcaption><p>웰컴블록이 활성화 된 화면</p></figcaption></figure>

웰컴 블록이 활성화되면 웰컴 블록 페이지 하단에서 봇 응답을 꾸밀 수 있습니다.&#x20;

봇 응답은 최대 3개까지 선택하여 추가할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fypq1kOJOuc7WfG3Zwiaf%2Ftutorial_block_16.png?alt=media&amp;token=b9cd07b8-c418-49fc-bd3f-775e27acdeaa" alt=""><figcaption><p>웰컴블록 봇 응답 설정 화면</p></figcaption></figure>

**먼저 이미지형 응답 설정입니다.**&#x20;

이미지는 파일 업로드 또는 URL 업로드로 추가할 수 있으며 총 10개까지 추가 가능합니다.&#x20;

이미지를 2개 이상 추가하는 경우 설정한 이미지 중 랜덤 이미지가 전송됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FlBcnhIYWaDHmKxEp9UZ1%2Ftutorial_block_17.png?alt=media&amp;token=4393ab93-9e2d-4d15-b53f-d28987f87dc9" alt=""><figcaption><p>이미지형 응답 설정 화면 </p></figcaption></figure>

**두 번째 텍스트형 응답입니다.**&#x20;

텍스트형 응답은 버튼 생성을 하지 않을 때 1,000자까지 작성할 수 있으며 버튼 생성 시엔 400자로 입력이 제한됩니다. 여러 개의 텍스트형 응답을 만들 경우에는 128자까지 작성할 수 있습니다.

텍스트형 메시지는 챗봇의 사용 방법 또는 비즈니스 소개 글 등이 들어가면 좋습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fkn7vH0b03UB0mfCgVsxl%2Ftutorial_block_18.png?alt=media&amp;token=f77d7954-48b7-4383-8b75-d9da00d84da9" alt=""><figcaption><p>텍스트형 응답 화면</p></figcaption></figure>

**마지막으로 추가한 응답은 카드형 응답입니다.**&#x20;

카드형 응답은 이미지, 텍스트 그리고 버튼까지 한 번에 작성할 수 있다는 장점이 있습니다. 이미지 타입 또한 선택할 수 있으며 서로 다른 카드 10개까지 추가할 수 있습니다.

여기까지 전부 만드셨다면 오른쪽 상단 전송 타입 버튼을 통해 응답별로 전송 타입을 설정하실 수 있습니다. 전송 타입은 케로셀과 랜덤형으로 케로셀은 설정한 응답 전부가 슬라이딩 형태로 노출되는 것을 의미하며 랜덤형은 설정한 응답 중 랜덤하게 한 가지만 노출되는 것을 의미합니다.&#x20;

따라서 사용자에게 모든 정보를 보여줘야 할 땐 케로셀을 사용자에게 랜덤하게 다양성을 주고 싶을 땐 랜덤형을 사용하는 것이 좋습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fi3rGdeUx2K5ZPYHHe2TQ%2Ftutorial_block_19.png?alt=media&amp;token=19954fa3-7a3c-4c1f-bb98-acfde0a4ab4e" alt=""><figcaption><p>카드형 응답 설정 화면</p></figcaption></figure>

응답이 노출되는 순서는 왼쪽 화살표 버튼을 통해 변경할 수 있으며 응답을 삭제하고 싶을 때는 휴지통 버튼을 사용하실 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F3GbE5PWt6D19P5rr8S58%2Fchange_order.png?alt=media&amp;token=2ce509a3-dadd-4561-afee-099be21371d9" alt=""><figcaption><p>노출 순서 변경 버튼</p></figcaption></figure>

### 폴백 블록 설정하기 <a href="#setting_fallback" id="setting_fallback"></a>

폴백 블록은 봇이 사용자의 응답을 알아듣지 못했을 때 노출되는 블록입니다.&#x20;

폴백 블록에서 중요한 점은 봇이 알아듣지 못했다는 것을 사용자에게 인지시키는 것입니다. 따라서 봇 작업자는 봇이 알아듣지 못했다는 점을 사용자에게 인지시키고 다시 봇을 사용할 수 있게끔 폴백 블록을 구성해야 합니다.

따라서 첫 번째 응답으로 사용자에게 봇이 알아듣지 못한다는 것을 먼저 인지시키는 응답을 노출하겠습니다.

폴백블록은 세 가지 중 한 가지만 랜덤하게 노출할 수 있도록 전송 타입을 랜덤형으로 설정하였습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FT2vtK6lDJ0Z8qvwew0s4%2Ftutorial_block_21.webp?alt=media&amp;token=101b0bd1-0884-4953-8e5d-6422ebaea125" alt=""><figcaption><p>폴백 블록 텍스트형 응답</p></figcaption></figure>

텍스트형 답변 아래 선택할 수 있는 메뉴는 웰컴 블록 세 번째 응답과 동일하게 구성하였습니다.

**하나의 ‘홈' 블록을 만들어 놓는다는 것은 사용자에게 안정감을 주며 챗봇을 설계할 때도 그리고 사용자가 챗봇을 사용할때도 실수를 줄여줍니다.**

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F0NoL3xIXIcEsHfNaCpe1%2Ffallback_2.png?alt=media&amp;token=5a763eb4-bfa6-408e-a1e7-87f1261fe985" alt=""><figcaption><p>폴백 블록 두번째 응답 화면</p></figcaption></figure>

## 봇 테스트 <a href="#bot_test" id="bot_test"></a>

봇 테스트는 사용자가 구성한 봇이 어떻게 작동하는지 미리 볼 수 있는 기능입니다. 봇 작업자는 예상한 대로 봇이 잘 작동하는지 오른쪽 상단에 봇 테스트를 통해 확인하면서 봇을 만들어 나갈 수 있습니다.

{% hint style="success" %}
**Tip.**&#x20;

패턴 발화에 등록된 문장을 기준으로 점점 변형된 형태의 발화로 테스트를 진행하신 후 매칭에 실패한 답변을 등록하면 더욱 완성된 형태의 봇을 만들 수 있습니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F5Oph7zoROxtElyaCPlzq%2Fbot_test.png?alt=media&amp;token=7617cc3a-4e19-4600-8122-9c263bc5b1e3" alt=""><figcaption><p>봇 테스트</p></figcaption></figure>

## 발화 <a href="#utterance" id="utterance"></a>

봇 작업자가 사용자 발화패턴 설정란에 사용자 예상 발화를 입력한 후, 직접 태깅을 통해 필요한 대로 발화 패턴을 정의할 수 있습니다. 챗봇 관리자 센터에서는 태깅이 필요할 것으로 예상되는 엔티티 단어에 밑줄을 자체적으로 표시해 주는데, 이를 확인하고 봇 작업자는 밑줄이 가르치는 단어를 드래그하여 필요한 엔티티를 직접 부여할 수 있습니다. 물론, 밑줄은 없지만 작업자가 중요하다고 생각하는 엔티티에 직접 태깅 할 수도 있습니다.

아래 작업 예시를 확인 해주세요.

1. 발화 중 밑줄이 표시된 부분에 엔티티를 태깅하는 경우

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F788sPI2z55F2fj9DoV7z%2Ftutorial_utterance_01.webp?alt=media&amp;token=2a1a2e1b-c4a6-4753-b8d0-2851f6141a7a" alt=""><figcaption></figcaption></figure>

2. 발화 중 밑줄 표시가 없는 부분에 엔티티를 태깅하는 경우

‘예약'이라는 단어에 직접 드래그하여 별도의 엔티티를 강제 부여하는 모습입니다. 입력된 발화에 대해서 최종적으로 엔티티 태깅이 완료되고 나면 패턴 발화가 생성됩니다!

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FThxfGZUXHaG5sNa6erSd%2Ftutorial_utterance_02.webp?alt=media&amp;token=22a7f4aa-b392-42f0-9ae6-6f9a15233a91" alt=""><figcaption></figcaption></figure>

패턴이 잡힌 발화의 예시 모습입니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FWxuC05JbRAjr9fhWNgYL%2Ftutorial_utterance_03.png?alt=media&amp;token=94f068a6-f504-47a4-acce-8ebef9ebb093" alt=""><figcaption></figcaption></figure>

패턴 발화 : {케이크 종류} {케이크 주문} <하다>

위 같은 방식으로, 본 블록이 나타내고자 하는 의도에 알맞은 발화패턴을 입력하고 태깅하는 작업 과정을 이어서 하면 됩니다. 하나의 블록 안에서 패턴을 충분히 포함할수록 실제 사용자 발화에 블록이 대응할 수 있는 확률이 높아집니다.

발화를 통해 응답을 불러오는 과정을 보여드리겠습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FYhVYteKqd2ZrBQDWPXnI%2Fnatural_lang.webp?alt=media&amp;token=52815ac6-f072-46de-8091-df4420367e20" alt=""><figcaption></figcaption></figure>

‘영업시간 궁금해'라는 발화에 ‘영업시간', '운영시간' 등 동의어가 포함된 엔티티(store\_time)를 입력하고 봇 응답에 영업시간을 안내하는 블록을 생성하였습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F7HjQ3BAnNcduNJqoAcDX%2Ftutorial_utterance_03.png?alt=media&amp;token=ad468b34-9ad7-466a-8a5b-1c55d64ce7f4" alt=""><figcaption></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FmTSfneds1AIyZpfNbELA%2Ftutorial_utterance_04.png?alt=media&amp;token=82f1f925-6478-4aa9-ba3b-eea960122fa3" alt=""><figcaption></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fp0uPtNQa2YXYrCahsZGu%2Ftutorial_utterance_04.webp?alt=media&amp;token=54d42c5b-4d3c-4374-97f8-a9ce8884255c" alt=""><figcaption><p>‘영업 시간' 블록</p></figcaption></figure>

‘영업시간 궁금해’, ‘운영시간 궁금해’라는 발화를 <영업시간>+'궁금해' 라는 발화로 인식하여 동일한 응답을 한 것을 볼 수 있습니다.

아래처럼 블록에 발화를 입력하고 엔티티 설정 후 원하는 봇 응답을 꾸며주기만 하면 편리하게 나만의 챗봇을 제작할 수 있습니다!

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FnRrbY3TOX1i61XuICEUb%2Fbot_Test.webp?alt=media&amp;token=9610beac-db24-487d-b564-9cdbf2e824dc" alt=""><figcaption><p>봇테스트</p></figcaption></figure>

## 엔티티 <a href="#entity" id="entity"></a>

엔티티(Entity)란 봇이 이해할 수 있는 용어를 체계적으로 정리한 데이터 사전입니다.&#x20;

만약 엔티티가 없다면, 봇 제작자는 사용자가 할 법한 모든 발화를 직접 입력해야 합니다.&#x20;

케이크 주문 챗봇의 입장에선 **‘플라워 케이크 주문할게요’ 와 ‘팔레트 케이크 예약하고 싶어요' 가** 같은 의도를 가진 발화입니다. 모두 케이크를 주문하는 행위이기 때문입니다.&#x20;

이때, 엔티티가 없다면 **‘플라워 케이크 주문할게요', ‘팔레트 케이크 예약하고 싶어요', ‘플라워 케이크 예약하고 싶어요', ‘팔레트 케이크 주문할게요'** 등 모든 발화를 입력해야 합니다.&#x20;

키가 되는 **'플라워 케이크'** 라는 패턴발화 부분에 미리 정의해 둔 엔티티를 태깅하면 **'탄생화 케이크 주문할게요'** 라는 발화에도 응답할 수 있습니다.

하지만 엔티티를 먼저 정의해 둔다면 발화패턴을 만들 때도 훨씬 수월해집니다! ‘**@cake\_design @cake\_order'**&#xB77C;는 문장만 사용자 발화에 입력해 둔다면 아래 네 가지 동일한 의도를 가진 발화를 단 하나의 발화로 압축할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2ForZdTkwFQ9MC9jE1y8mH%2Ftutorial_entity_01.webp?alt=media&amp;token=a222393d-1618-4459-8f74-74f42bdc99c5" alt=""><figcaption><p>엔티티가 없을 때 예시 이미지</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FTyGLkTNBGEgozGeZBGby%2Ftutorial_entity_02.webp?alt=media&amp;token=70768562-00fe-4332-ab7f-5b0dedc111e3" alt=""><figcaption><p>엔티티가 있을 때 예시</p></figcaption></figure>

케이크 주문 챗봇에서 필요한 나의 엔티티를 작성한 것입니다.&#x20;

위 엔티티의 형식을 참고하여 내 챗봇에 필요한 엔티티를 구성해 보세요!

{% hint style="success" %}
**Tip.**

ML+를 사용하는 챗봇은 예약, 주문 등 우리가 흔히 비슷한 의미로 판단할 수 있는 서술어는 챗봇에서 자체적으로 학습을 하고 있습니다. 따라서, **ML+를 사용하는 챗봇들은 우리가 일반적으로 비슷한 의미라고 판단할 수 있는 서술어는 엔티티에 추가할 필요 없이 머신러닝 버튼을 활성화해 두는 것만으로도 똑똑한 챗봇을 만들 수 있답니다!**

예를 들면 **‘플라워 케이크 예약하기’**&#xB97C; 발화로 등록하였다면, **‘플라워 케이크 주문하기'**&#xB294; **발화나 동의어로 등록해 두지 않아도 똑똑한 ML+가 같은 의도를 가진 발화로 인식합니다.**&#x20;

**('예약하기'만 패턴발화로 등록해도 ML을 켜두면 '주문하기' 라고 입력이 들어와도 ML+는 해당 사용자는 주문=예약이라고 이해하고 '예약하기의 응답'이 노출합니다.)**

&#x20;ML+의 자세한 내용은 [**주요개념 > ML+**](/main/tool/chatbot/main_notions/ml+.md)를 참고해주세요.
{% endhint %}

{% hint style="success" %}
**Tip.**

엔티티를 설정할 때에는 포괄적인 엔티티명 안에 세부적인 엔티티 목록을 설정하는 것이 좋을 것 입니다.&#x20;

(ex. cake\_design 안에 개별 케이크 명)
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FMBw66n259fq5lhDN5B7Y%2Ftutorial_entity_03.png?alt=media&amp;token=90d6982e-4cfb-4de9-a709-30cf6c0db9cb" alt=""><figcaption><p>케이크 주문 챗봇 엔티티 목록</p></figcaption></figure>

## 더 알아보기 <a href="#more_information" id="more_information"></a>

### 리스트 메뉴 설정하기 <a href="#setting_generic" id="setting_generic"></a>

봇 리스트 메뉴는 챗봇 안에서 하단에 슬라이드 메뉴 형태로 존재하는 사용자 인터페이스를 의미합니다. 챗봇 사용자가 아래에서 위로 해당 공간을 쓸어 올려 언제나 중요 필수 메뉴를 쉽게 접근할 수 있습니다. 봇 작업자는 리스트 메뉴 사용 여부를 ON/OFF 형태로 설정할 수 있습니다.

리스트 메뉴를 사용하려면 봇과 채널이 연결되어 있어야 합니다. [**봇과 채널 연결**](#connect_bot_channel)을 연결 해주세요.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FS4JCl2rZOOQs3FClRPF5%2Ftutorial_more_01.png?alt=media&amp;token=c949098c-a627-4d98-a1ef-e60cd6347f4c" alt=""><figcaption><p>리스트 메뉴를 사용하기 위해서는 시나리오 설정 메뉴를 클릭하고,</p></figcaption></figure>

리스트 메뉴를 사용하기 위해서는 시나리오 설정 메뉴를 클릭하고,

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FPyNe2DZB5DvJJnqq7KAS%2Ftutorial_more_02.png?alt=media&amp;token=7a4564e8-75a2-4677-b775-df4004f25b46" alt=""><figcaption><p>시나리오 설정</p></figcaption></figure>

‘봇 리스트 메뉴 설정' 을 켜야 합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FfFbvkLhmHUuGsTcAWbla%2F%E1%84%87%E1%85%A9%E1%86%BA%20%E1%84%85%E1%85%B5%E1%84%89%E1%85%B3%E1%84%90%E1%85%B3.png?alt=media&amp;token=127e645a-1fbb-4130-a98b-3cbde789de4e" alt=""><figcaption><p>봇 리스트 메뉴 설정 ON</p></figcaption></figure>

봇 리스트 메뉴 설정을 켜고 나면 채팅방과 동일하게 생긴 리스트 메뉴의 버튼 명을 설정할 수 있는 화면이 나타납니다. 봇 리스트 메뉴는 챗봇의 채팅 방 하단에 항상 존재하며 봇 작업자는 사용자가 버튼을 누르면 ‘블록 연결' 또는 ‘메시지 전송'을 하도록 설정할 수 있습니다.

케이크 주문 챗봇에서는 리스트 메뉴를 **‘처음으로' 블록과 ‘케이크 주문하기' 블록으로 설정하였습니다.**&#x20;

이때 버튼 명은 20자로 제한되며 이모지를 사용할 수도 있습니다. 귀여운 이모지로 나만의 생동감 넘치는 리스트 메뉴를 구성해 보세요!

{% hint style="danger" %}
**Caution.**

‘블록 연결' 기능은 연결하려는 블록을 생성하고 저장해야 사용할 수 있습니다. 리스트 메뉴를 설정하기 전에 블록을 먼저 만들어 주세요. 자세한 내용은 [**튜토리얼 1단계 > '케이크 메뉴' 블록 만들기**](#make_block_cakemenu)를 참고해 주시길 바랍니다.
{% endhint %}

{% hint style="success" %}
**Tip.**

리스트 메뉴는 챗봇에서 가장 접근하기 쉬운 메뉴인 만큼 **핵심**이 되는 블록을 연결하는 것이 좋습니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FiGkwz58inzaUz7E4sg5M%2F%E1%84%8E%E1%85%A5%E1%84%8B%E1%85%B3%E1%86%B7%E1%84%8B%E1%85%B3%E1%84%85%E1%85%A9.png?alt=media&amp;token=59b88120-d8cb-4035-abbc-3e0a981b3da4" alt=""><figcaption><p>리스트 메뉴 블록 연결 설정</p></figcaption></figure>

## 일반 사용자 봇과 카카오톡 채널 연결하기 <a href="#connect_bot_channel" id="connect_bot_channel"></a>

이제 만든 봇을 사용자가 사용할 수 있게 카카오톡 채널과 연결해보겠습니다. 채널이 없는 경우, 카카오톡 채널을 만들어야 합니다. 카카오톡 채널은 [**카카오톡 채널 관리자센터**](https://business.kakao.com/info/kakaotalkchannel/)에서 생성할 수 있습니다.

### 카카오톡 채널은 카카오톡 채널 관리자센터에서 생성하기 <a href="#create_channel" id="create_channel"></a>

#### **Step 1.** [**카카오톡 채널 관리자센터**](https://business.kakao.com/info/plusfriend)**에서 '카카오톡 채널 시작하기' 클릭**

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FgONTY4DrTPZcTmJExlzs%2Fcreate_channel.webp?alt=media&amp;token=94e05c5b-2e96-44e6-afe1-afbf6fec376f" alt=""><figcaption></figcaption></figure>

#### Step 2. 인증 및 이용약관 동의

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FUY0iPC65TabG5N7ArnFr%2Fplus2.png?alt=media&amp;token=cb5bf318-226d-4192-b8f1-93953592afa7" alt=""><figcaption></figcaption></figure>

#### **Step 3. ‘새 채널 만들기’ 클릭**

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F8jfWW3cvPpIQlPQyUC4C%2Fplus3.png?alt=media&amp;token=6075f66d-bf95-479b-a196-2a0b88d7e7a1" alt=""><figcaption></figcaption></figure>

#### **Step 4. 채널 정보 입력하기**

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FpSaVQpfAg4ZPHEoYREBE%2Fplus4.png?alt=media&amp;token=19889e4b-5c7c-425e-a7fe-a838b5fa791b" alt=""><figcaption></figcaption></figure>

#### Step 5. 채널 개설 완료

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F6xyrXiYdheaYuxHWAZnk%2Fplus5.png?alt=media&amp;token=e5620da8-223e-46b2-a2cd-664219a3fe65" alt=""><figcaption></figcaption></figure>

### 카카오톡 채널 연결하기 <a href="#connect_channel" id="connect_channel"></a>

**카카오톡 채널 연결은 \[설정 > 챗봇 관리]에서 연결할 수 있습니다.**\
카카오톡 채널과 챗봇의 연결이 어려울 경우 아래 사항을 체크하여 주시기 바랍니다.

* **권한 소유 여부**
  * **챗봇과 카카오톡 채널 연결 시 봇의 마스터는 연결된 앱과 채널의 권한을 소유하여야 합니다.** 카카오톡 채널의 경우 매니저 이상, 카카오톡 채널과 앱이 연결되어 있을 경우에는 해당 앱의 EDITOR 이상의 권한이 필요합니다.\
    ※ 카카오톡 채널 권한은 \[카카오톡채널 관리자센터 > 관리 > 관리자] 메뉴에서 설정 가능하며, 앱 권한은 카카오 디벨로퍼스 접속 후 \[디벨로퍼스 > 앱 > 일반 > 멤버]에서 설정할 수 있습니다.<br>
* **다른 챗봇 연결 중**
  * 해당 채널이 이미 챗봇과 연결된 경우 '챗봇 연결'로 노출되며 다른 챗봇과 연결이 불가능합니다.
  * \[카카오톡채널 관리자센터 > 비즈니스 도구 > 챗봇]에서 연동된 챗봇을 확인해 주세요.
  * 챗봇 연결 해제는 \[챗봇 관리자센터 > 설정 > 챗봇 관리 > 카카오톡 채널 연결]에서 가능합니다.<br>
* **채팅방 메뉴 사용 중**
  * 해당 채널이 \[카카오톡채널 관리자센터 > 비즈니스 도구 > 채팅방 리스트 메뉴]의 설정이 ON으로 되어 있다면 "채팅방 메뉴 사용중"으로 노출됩니다.
  * 채널의 '채팅방 커스텀 메뉴', '채팅방 리스트 메뉴', '자동응답 메시지'는 챗봇과 동시 사용이 불가하므로, '채팅방 메뉴' 사용 설정을 OFF로 하면 채널이 챗봇과 연결 가능한 상태로 전환됩니다.

#### Step 1. 설정 메뉴의 '카카오톡 채널 연결' 영역으로 이동

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FWeGndLGMK6W9MJxv9zG1%2Fplusconnect1.png?alt=media&amp;token=ecdb0a02-73ad-4807-bd44-f39b3d69c32f" alt=""><figcaption></figcaption></figure>

#### Step 2. '운영 채널'의 선택 영역 클릭

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F4X3e4sjhel6uHvClUfMA%2Fplusconnect2-1.png?alt=media&amp;token=db7a3630-7401-412d-9bf0-0b1e46fa6a7e" alt=""><figcaption></figcaption></figure>

#### **Step 3. '개발 채널'의 선택 영역 클릭**

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FgeWpsnvdJWYjjiZ26twA%2Fplusconnect3-1.png?alt=media&amp;token=8318f44c-aa88-4ce9-b121-93df87a52633" alt=""><figcaption></figcaption></figure>

위의 단계를 거쳐 배포를 진행하신 후 챗봇 사용이 가능합니다.&#x20;


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/tutorial/make_chatbot/tutorial_1.md
