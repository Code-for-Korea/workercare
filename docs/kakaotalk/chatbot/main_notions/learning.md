> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/learning.md).

# 학습

**학습**이란 봇이 파악하지 못한 사용자 발화 목록들을 이용해 봇의 정확성을 높여 잘 답변할 수 있도록 도와주는 보조도구입니다. 블록에 정의되지 않은 사용자 발화들이 입력되었을 경우, 이 목록들을 확인하고 무시하거나 기존에 정의해 둔 블록으로 매칭시켜 봇을 학습시킬 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fogb655eLw58hAk4ATTzx%2Ffeedback-menu-01.png?alt=media&amp;token=48f7ff9a-273a-44d2-9258-7c1ee1358327" alt=""><figcaption><p>학습메뉴는 상단 메뉴 탭에 있습니다</p></figcaption></figure>

## 학습대기 <a href="#wait_learning" id="wait_learning"></a>

**학습대기** 목록에는 어제까지 수집된 데이터 중 설정된 기간동안의 발화 및 빈도가 노출됩니다. 조회 날짜를 수정하여 좀 더 긴 범위(최대 30일)의 데이터를 확인하거나 검색 필터를 추가하여 단어, 빈도, 길이 별로 목록을 필터링 할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F1ZCIZMaRtFzK20AEPw0g%2Ffeedback-pending-01.png?alt=media&amp;token=5d4de023-8649-4a57-9826-6c97f45ff6d2" alt=""><figcaption><p>2018년 11월 14일에 들어온 폴백 발화들이 보입니다</p></figcaption></figure>

## 학습이력 <a href="#learning_history" id="learning_history"></a>

**학습이력** 목록에는 학습대기에서 업데이트한 발화들의 목록이 매칭한 블록명과 함께 발화 업데이트 일시, 학습상태가 표기됩니다.

학습한 발화의 매칭블록을 변경하거나 학습한 발화를 ‘무시’ 상태로 변경할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FSP8vQOvUFZlJVlHDp03P%2Ffeedback-logs-01.png?alt=media&amp;token=3b58bc6d-d84f-4c6e-94d2-6b967dbe4b66" alt=""><figcaption><p>선택된 기간동안 학습했던 이력들</p></figcaption></figure>

## 봇 학습시키기 <a href="#bot_learning" id="bot_learning"></a>

### 학습대기에서 발화를 학습 하는 방법 <a href="#learning_utterance_in_stanby_status" id="learning_utterance_in_stanby_status"></a>

#### Step 1. 학습대기 목록에서 블록에 매칭시킬 발화를 선택합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FRbJNaSPV9WrnX0O0bfoQ%2Fbot-train-standby-01.png?alt=media&amp;token=7a353f5f-6dc6-44db-8466-ced555d42041" alt=""><figcaption><p>학습대기 목록에 노출된 2018년 11월 14일에 들어온 폴백 발화들</p></figcaption></figure>

학습대기 목록은 설정된 기간동안 들어온 폴백 발화들을 빈도가 높은 순으로 정렬하여 노출합니다.

#### Step 2. 발화 학습 상세화면에서 매칭 블록을 지정하거나 엔티티를 태깅 후 학습을 누릅니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FktKCAF1utn2JhS9ydkBx%2Fbot-train-standby-02.png?alt=media&amp;token=51494567-fd2c-4a5f-8c1e-b2389199b1c8" alt=""><figcaption><p>학습대기목록에서 <strong>빠히바게트에서 빵이요</strong> 발화를 선택하고 엔티티 태깅 후 <strong>베이커리 주문</strong> 블록으로 연결</p></figcaption></figure>

연결블록을 지정하지 않으면 **무시**만 가능하고 연결블록을 지정해야 **학습** 버튼이 활성화 됩니다.

#### Step 3. 학습한 발화는 매칭한 블록으로 등록되고 학습대기에서 학습이력으로 이동됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F2WmbPh7Lf23RYN7jnHBX%2Fbot-train-standby-03.png?alt=media&amp;token=3ac961bd-9fe5-4b24-8817-16e515914430" alt=""><figcaption><p><strong>베이커리 주문 블록</strong>에 학습대기에서 매칭했던 <strong>빠히바게트 빵이요</strong> 발화 및 엔티티 추가된 화면</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FCcReIXxNvDFemgiBnPPa%2Fbot-train-standby-04.png?alt=media&amp;token=88a910a6-18c3-4f09-9e74-c19b57ee7a5c" alt=""><figcaption><p>학습이력에서 학습시킨 발화는 학습이력으로 이동되고 업데이트일, 학습상태가 목록에 노출</p></figcaption></figure>

### 학습이력에서 이미 학습한 발화를 변경하는 방법 <a href="#change_utterance_already_learned" id="change_utterance_already_learned"></a>

#### Step 1. 이미 학습한 발화를 선택하기 위해 학습이력 목록을 들어갑니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FIZjUKD7VTwVYESrjxS8u%2Fbot-train-edit-01-1.png?alt=media&amp;token=3ca4ae0c-1179-4c6d-894f-57a3c92623e9" alt=""><figcaption><p>11월 11일 에서 11월 15일까지 학습한 이력들</p></figcaption></figure>

#### Step 2. 학습이력 목록에서 학습한 빠히바게트에서 빵이요를 선택하고 연결 블록을 변경합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fcl3qeWqruiDz8vWQv9qV%2Fbot-train-edit-02.png?alt=media&amp;token=5c45d20a-f427-4c7f-80ce-2f34d72c46cf" alt=""><figcaption><p>학습이력 팝업에서 <strong>빠히바게트에서 빵이요</strong> 발화가 <strong>베이커리 주문 블록</strong>에서 <strong>빠히바게트 블록</strong> 으로 변경된 화면</p></figcaption></figure>

학습이력의 상세화면에선 선택한 발화를 업데이트 한 일시, 작업자ID가 표기되고 발화 연결블록과 엔티티 정보가 함께 노출됩니다. 학습이력에서 무시한 문장은 블록에 매칭될 경우 매칭되었던 블록에서 발화가 삭제되고 다시 폴백 블록으로 매칭되어, 사용자가 해당 발화를 다시 입력한 경우에도 학습대기 목록에 노출되지 않습니다.

#### **Step 3. 변경한 발화는 기존 블록에서 삭제되고 매칭한 블록에 새롭게 등록됩니다.**

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FJ7TmRPGUIIZJDyDjw7w2%2Fbot-train-edit-03.png?alt=media&amp;token=d248a487-f810-4fd3-b3cd-712e11fbb302" alt=""><figcaption><p><strong>빠히바게트에서 빵이요</strong> 발화가 <strong>베이커리 주문 블록</strong>에서 <strong>빠히바게트 블록</strong> 으로 변경된 화면</p></figcaption></figure>

### 학습 대기 목록 필터링 하기 <a href="#filtering_waitlist_for_learning" id="filtering_waitlist_for_learning"></a>

#### 기간 변경 <a href="#change_period" id="change_period"></a>

**학습대기** 에선 어제까지의 날짜, **학습이력**에선 오늘을 포함한 어제 날짜를 선택할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FTB73qshFD6Fcltg2oyM2%2Fbot-train-list-01.png?alt=media&amp;token=ab24ac4a-494b-4b36-851e-0b7290235995" alt=""><figcaption><p><strong>기간</strong> 탭에서 어제를 선택하면 현재일 전날의 날짜가 지정됩니다. 학습이력에서 어제를 선택하면 어제부터 오늘까지의 날짜가 선택됩니다</p></figcaption></figure>

학습대기 목록은 설정된 기간동안 들어온 폴백 발화들을 빈도가 높은 순으로 정렬하여 노출합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FfUvBem6FMhIWfrbi1qKJ%2Fbot-train-list-02.png?alt=media&amp;token=d6cdf8e8-45d6-4625-854a-e7ea5eb6a79c" alt=""><figcaption><p><strong>날짜</strong> 탭을 선택하여 직접 조회할 날짜를 선택할 수 있습니다.</p></figcaption></figure>

달력에서 날짜를 직접 지정할 경우 목록조회 시작 날짜와 종료 날짜를 지정할 수 있습니다. 설정할 수 있는 기간은 최대 30일 입니다.

#### 검색필터 추가 <a href="#add_search_filter" id="add_search_filter"></a>

**학습대기** 목록에서 검색필터를 추가하여 목록을 필터링 할 수 있습니다. 검색 필터 추가 버튼을 누른 후 **텍스트** 메뉴에서 **발화포함** 혹은 **발화제외**를 지정하면 검색할 단어(최대 12자)를 입력할 수 있습니다. **발화 값**에서 **발화빈도** 혹은 **발화길이**를 선택하면 일정 숫자 이상 혹은 이하의 숫자(최대 99,999,999)를 입력하여 필터링 할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FJ3OHSvKl9gKA1lBPlLGd%2Fbot-train-list-03.png?alt=media&amp;token=57d3e65b-0b7c-4417-8599-e6412e19f612" alt=""><figcaption><p>학습대기에서 텍스트 검색필터 조건을 <strong>발화포함</strong> 으로 하고 <strong>아니</strong> 라는 단어를 입력</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FtT7eDgbs9WjzFO1s0ki2%2Fbot-train-list-04.png?alt=media&amp;token=1b2578f2-2120-43bf-97a4-b483d9e5c4d3" alt=""><figcaption><p>설정된 기간동안 발화에 <strong>아니</strong> 가 포함된 목록과 빈도</p></figcaption></figure>


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/learning.md
