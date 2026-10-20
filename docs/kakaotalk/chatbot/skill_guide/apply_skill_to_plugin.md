> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/apply_skill_to_plugin.md).

# 플러그인에 스킬 적용하기

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FCyDfFQDGj0uw7ubNXreG%2Fskill-plugin-intro.png?alt=media&amp;token=43afbc5a-ed4a-4c79-9253-b0aa322375cb" alt=""><figcaption></figcaption></figure>

챗봇 관리자센터의 또 하나의 자랑, 카카오톡 화면에 있었으면 했던 바로 그 기능을 ‘플러그인’과 함께 연동된 스킬이 대신할 수 있습니다.

사용자가 간편하게 날짜/시간 전송, 이미지 보안 전송, 바코드(QR) 전송까지 할 수 있는 챗봇 관리자센터의 초필살기 메뉴!

앞으로 더욱 다양한 기능을 가진 플러그인이 봇 작업자 여러분을 찾아갈 예정입니다.

내가 고른 플러그인을 간단히 설정하고 스킬서버와 연동까지! 한 번에 경험해보세요.

## 바코드(QR) 플러그인 <a href="#qr_plugin" id="qr_plugin"></a>

### 바코드(QR) 플러그인이란? <a href="#what_is_qr_plugin" id="what_is_qr_plugin"></a>

**바코드(QR) 플러그인**은 사용자가 코드 스캐너를 통해 봇에게 정확한 바코드(QR)값을 전송할 수 있도록 입력받는 역할을 합니다. 봇과의 대화중 사용자의 바코드(QR)입력이 필수로 필요한 경우, 봇 작업자가 설정해 둔 플러그인을 통해 코드 스캐너를 띄워 사용자가 정확한 코드값을 쉽게 입력할 수 있도록 도와줍니다.

{% hint style="success" %}
**Tip.** 바코드(QR) 플러그인을 통해서 호출되는 코드 스캐너는 QR코드와 바코드를 하나의 화면에서 구분없이 인식할 수 있습니다.
{% endhint %}

### 바코드(QR) 플러그인 설정 <a href="#setting_qr_plugin" id="setting_qr_plugin"></a>

#### **Step 1. 파라미터 설정 영역을 펼친 후 파라미터 만들기 눌러 팝업을 띄웁니다.**

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F2s18d6yuCzzCcNVze9Jl%2Fskill-plugin-qr-create-01.png?alt=media&amp;token=4b90be6f-549a-4551-af4d-de7370e4aaa0" alt=""><figcaption><p>파라미터 설정을 펼치고 파라미터 만들기를 선택하는 화면</p></figcaption></figure>

#### Step 2. 플러그인 및 필수 파라미터를 설정하고 확인을 누릅니다.

우측 상단에서 ‘플러그인’으로 변경한 다음 ‘필수 파라미터로 설정’을 체크합니다. (필수 파라미터로 체크하지 않을 경우, 되묻기 질문을 통해 코드 스캐너를 띄워주는 말풍선을 설정할 수 없습니다.)

그 후, 파라미터명을 입력하고 플러그인 목록에서 **\[sys.plugin.barcode]**&#xB97C; 선택하고 확인 버튼을 누릅니다.

{% hint style="success" %}
**Tip.** 바코드(QR) 플러그인을 사용하려면 '엔티티 메뉴 - 시스템 엔티티'에서 @sys.plugin.barcode 항목이 활성화되어있어야 합니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FS2phnSWgcrfP72lYGYfO%2Fskill-plugin-qr-create-02.png?alt=media&amp;token=202767aa-b472-47b9-846c-d1d34dbdb1df" alt=""><figcaption><p>파라미터 설정에서 플러그인을 선택하고 필수 파라미터로 설정하는 화면</p></figcaption></figure>

#### Step 3. 설정된 화면을 확인하고 되묻기 질문 버튼을 클릭합니다.

입력 완료 후 ‘확인’ 버튼을 누르면 아래와 같이 설정됩니다. 그 다음 \[되묻기 질문] 버튼을 클릭하여 설정 팝업을 띄웁니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FrPjbG3x0xQrWjUpITJIY%2Fskill-plugin-qr-create-03.png?alt=media&amp;token=3457ce0f-3ce2-42a2-8da1-243b8eff41a2" alt=""><figcaption><p>필수 파라미터로 설정이 되고 활성화된 되묻기 질문 버튼을 확인합니다</p></figcaption></figure>

#### Step 4. 되묻기 질문 설정 팝업에서 말풍선에 표시될 텍스트와 버튼명을 입력합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FfyIopDFVtXoP28DHOIAd%2Fskill-plugin-qr-create-04.png?alt=media&amp;token=eeba8e5b-bc19-41b8-81b7-8727e84d7463" alt=""><figcaption><p>되묻기 질문 설정에서 응답 말풍선 텍스트와 버튼명을 입력하는 화면</p></figcaption></figure>

#### Step 5. 플러그인 호출이 필요한 발화를 입력하게 되면 아래와 같이 말풍선이 출력됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F28n9uWvLPoh63yx1TBKy%2Fskill-plugin-qr-create-05.png?alt=media&amp;token=178d38a5-5727-43a5-863a-00997bbeec64" alt=""><figcaption><p>‘바코드(QR) 플러그인’을 통해 코드 입력을 완료한 화면</p></figcaption></figure>

바코드(QR) 인식이 완료되면 자동으로 코드 스캐너 화면이 닫히고 “바코드(QR) 전송 완료” 메시지가 전송됩니다. 메시지를 통해서 파라미터의 Value에 인식된 값을 받을 수 있고 스킬 API까지 아래와 같은 포맷으로 전송받을 수 있습니다.

<table><thead><tr><th width="196">타입</th><th width="177.33333333333331">포맷</th><th>예시</th></tr></thead><tbody><tr><td>QR/바코드</td><td>숫자 혹은 영문 조합</td><td><p>URL 형태 : https://kakao.ai/about</p><p>바코드 숫자 형태 : 8801236002224</p></td></tr></tbody></table>

### 스킬 호출값 <a href="#skill_call_value_qr" id="skill_call_value_qr"></a>

스킬명이 ‘바코드’이고 파라미터명을 ‘barcode’로 설정한 상태에서 사용자가 바코드를 전송했을 때 호출되는 payload는 아래와 같습니다.

```
{
  "action": {
    "id": "5ab1cb5c9418c22b668807d4",
    "name": "바코드",
    "clientExtra": {},
    "params": {
      "barcode": "{\"barcodeData\":\"8801236002224\"}"
    },
    "detailParams": {
      "barcode": {
        "origin": "바코드(QR)전송 완료",
        "value": "{\"barcodeData\":\"8801236002224\"}",
        "groupName": ""
      }
    }
  }
}
```

## 날짜/시간 플러그인 <a href="#day_time_plugin" id="day_time_plugin"></a>

### 날짜/시간 플러그인이란? <a href="#day_time_plugin" id="day_time_plugin"></a>

**날짜/시간 플러그인**은 봇 작업자가 설정한 제한값 안에서 사용자들에게 정확한 날짜와 시간 데이터를 입력받는 역할을 합니다. 봇 작업자가 설계한 말풍선에서 날짜/시간 플러그인 호출을 위한 버튼을 눌렀을 때, 해당 피커가 뜨게 되고 사용자는 그 안에서 원하는 값을 설정할 수 있습니다.

{% hint style="info" %}
**Information.** 날짜/시간 플러그인은 한국시간 기준(UTC+09:00)으로 피커가 노출됩니다.
{% endhint %}

### 날짜/시간 플러그인 설정하기 <a href="#setting_day_time_plugin" id="setting_day_time_plugin"></a>

#### Step 1. 파라미터 설정 영역을 펼친 후 파라미터 만들기 눌러 팝업을 띄웁니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FTqI5DyhX4Uq1SXQ40Xvk%2Fskill-plugin-date-create-01.png?alt=media&amp;token=00a23eb8-1e73-470e-b6a5-3b38c9756939" alt=""><figcaption><p>파라미터 설정을 펼치고 파라미터 만들기를 선택하는 화면</p></figcaption></figure>

#### Step 2. 플러그인 및 필수 파라미터를 설정하고 확인을 누릅니다.

우측 상단에서 ‘플러그인’으로 변경한 다음 ‘필수 파라미터로 설정’을 체크합니다. (필수 파라미터로 체크하지 않을 경우, 되묻기 질문을 통해 코드 스캐너를 띄워주는 말풍선을 설정할 수 없습니다.)

그 후, 파라미터명을 입력하고 목록에서 사용 목적에 따른 플러그인을 선택합니다.

{% hint style="success" %}
**Tip.**

날짜/시간 플러그인을 사용하려면 '엔티티 메뉴 - 시스템 엔티티'에서 아래의 엔티티가 활성화되어있어야 합니다.

* ‘날짜/시간’은 sys.plugin.datetime
* ‘날짜’는 sys.plugin.date
* ‘시간’은 sys.plugin.time
  {% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FNWKdGezJo9PUKWdVthmU%2Fskill-plugin-date-create-02.png?alt=media&amp;token=9d11f252-07c0-4de9-ab06-dbc799febb7c" alt=""><figcaption><p>파라미터 설정에서 플러그인을 선택하고 필수 파라미터로 설정하는 화면</p></figcaption></figure>

#### Step 3. 설정된 화면을 확인하고 되묻기 질문 버튼을 클릭합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Felc3hp3bN8wMtsbDAZeq%2Fskill-plugin-date-create-03.png?alt=media&amp;token=70a34334-9bd1-4c3f-bb05-9d5f127e9afb" alt=""><figcaption><p>필수 파라미터로 설정이 되고 활성화된 되묻기 질문 버튼을 확인합니다</p></figcaption></figure>

#### Step 4. 되묻기 질문을 설정 팝업에서 말풍선에 표시될 텍스트와 버튼명을 입력합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FNHHzffGpCHVtaSKwQb7w%2Fskill-plugin-date-create-04.png?alt=media&amp;token=79217991-f94c-40d6-ab0f-321b7510e17d" alt=""><figcaption><p>되묻기 질문 설정에서 날짜/시간 플러그인의 응답 말풍선 텍스트와 버튼명을 입력하는 화면</p></figcaption></figure>

#### Step 5. 플러그인 상세설정에서 버튼명과 원하는 날짜/시간 범위를 입력합니다.

{% hint style="info" %}
**Information.** ‘파라미터 만들기’ 화면에서 선택한 플러그인에 따라 sys.plugin.datetime은 날짜/시간, sys.plugin.date은 날짜, sys.plugin.time은 시간의 범위를 지정할 수 있습니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FcAsOZods42qojzEJPdjT%2Fskill-plugin-date-create-05.png?alt=media&amp;token=6b0d1867-2ec0-4a0e-998c-b76aa17bc9a8" alt=""><figcaption><p>‘날짜/시간 플러그인’에서 일정제한 타입을 범위지정으로 했을 경우</p></figcaption></figure>

‘범위 지정’ 방식은 사용자가 클라이언트에 노출된 말풍선 생성일을 기준으로 ‘오늘을 포함한 과거 혹은 미래의 범위 날짜값’을 노출하는 방식입니다. 선택가능한 범위는 현재일 기준으로 30일, 60일, 90일, 180일, 360일이며, 형태는 ‘미래’ 범위 노출, ‘과거’ 범위 노출, ‘과거부터 미래’ 범위로 설정 가능합니다.

{% hint style="success" %}
**Example.**

현재일이 3월 20일 경우, 미래 30일을 선택하면 3월 20일(D+1) , 3월 21일(D+2), …, 4월 18(D+30)일이 노출됩니다. 동일하게 현재일이 3월 20일 경우, 과거/미래 30일을 선택하면 D-30 \~ D+30 범위의 날짜가 노출됩니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FtySCFe9q7ehjXJ8IY5We%2Fskill-plugin-date-create-05-02.png?alt=media&amp;token=537b8c3b-eaa0-40f8-b307-2b8c8db6d4bd" alt=""><figcaption><p>‘날짜/시간 플러그인’에서 일정제한 타입을 직접지정으로 했을 경우</p></figcaption></figure>

‘직접지정’ 방식은 사용자가 클라이언트에 ‘시작일’ 과 ‘종료일’을 사용자가 직접 지정하여 노출하는 방식입니다. 직접 지정할 수 있는 날짜의 범위는 제한되어 있으며 올해를 기준으로 -100년, +100년 사이의 날짜범위를 지정할 수 있습니다. 사용자에게 노출하는 시간 제한값은 ‘선택 시간단위’, ‘시작 시간’, ‘종료 시간’ 을 설정하여 제한할 수 있습니다.

만약 ‘선택 가능 시간단위’를 20분으로 하고 ‘시작 시간’이 10시 40분, ‘종료 시간’이 19시 40분이면 사용자가 선택한 수 있는 값의 범위는 10시 40분부터 19시 40분 사이의 시간 중 20분 단위의 시간이 노출되고 이 중 하나를 선택할 수 있게 됩니다.

‘직접지정' 방식 중 만약 ‘종료 날짜'를 ‘현재까지’로 설정하면 사용자가 선택할 수 있는 날짜의 범위는 ‘시작 날짜'부터 사용자가 말풍선에서 플러그인 호출을 위한 버튼을 클릭한 시점의 날짜까지가 됩니다. (챗봇 대화 엔진이 ‘종료 날짜'가 ‘현재까지'로 설정된 것을 인식하면 챗봇 대화 엔진의 서버 시간 기준으로 ‘현재 날짜'를 ‘종료 날짜'로 설정해서 사용자의 카카오톡 클라이언트로 전송합니다. 한국시간 UTC+09:00 기준)

{% hint style="success" %}
**Example.** 10시 40분, 11시, 11시 20분, 11시 40분 … 19시, 19시 20분, 19시 40분
{% endhint %}

선택가능한 시간단위는 1분 / 5분 / 10분 /15분 / 20분 / 30분 이며, 시작시간과 종료시간에서 선택할 수 있는 ‘분 단위’는 선택 가능 시간 단위에 따라 달라집니다.

{% hint style="success" %}
**Example.**

시간단위를 15분으로하고 시작시간을 10시 10분으로 설정(X)

시간단위를 30분으로하고 시작시간을 9시 30분으로 설정(O)
{% endhint %}

{% hint style="success" %}
**Example.**

‘시작 날짜'를 ‘2024년 8월 1일’, ‘종료 날짜'를 ‘현재까지'로 설정하고 2024년 8월 5일에 사용자가 말풍선에서 플러그인 호출을 위한 버튼을 클릭하면 사용자가 선택할 수 있는 날짜의 범위는 2024년 8월 1일 \~ 2024년 8월 5일입니다. (8월 6일 클릭시 8월 6일로 늘어남)
{% endhint %}

### 타입별 노출 피커 형태 <a href="#exposure_picker_by_type" id="exposure_picker_by_type"></a>

사용자에게 노출되는 피커는 사용자가 설정한 플러그인의 타입에 따라 세 가지 방식으로 나누어 집니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FiqIhvYVsaAEKRkWCmZzw%2Fskill-plugin-date-picker.png?alt=media&amp;token=b5ef8175-c930-4762-b658-8990b2e2d647" alt=""><figcaption><p>‘날짜/시간 플러그인’을 통해서 제한한 범위값을 사용자가 선택하는 화면으로, 왼쪽부터 날짜/시간, 날짜, 시간 플러그인입니다</p></figcaption></figure>

**날짜/시간 플러그인**일 경우, 사용자가 선택할 수 있는 날짜의 범위는 일정제한에서 입력한 ‘시작일’ 부터 ‘종료일’ 혹은 ‘날짜 범위’이고, 시간제한에서 입력한 ‘시작 시간’ 부터 선택한 시간단위로 ‘종료 시간’까지의 범위로 노출됩니다.

{% hint style="success" %}
**Example.** YYYY년 MM월 DD일 HH : MM
{% endhint %}

**날짜 플러그인** 일 경우, 일정제한에서 입력한 ‘시작일’ 부터 ‘종료일’ 혹은 ‘날짜 범위’ 사이의 값들이 노출됩니다.

{% hint style="success" %}
**Example.** YYYY년 MM월 DD일
{% endhint %}

**시간 플러그인**일 경우, 시간제한에서 입력한 ‘시작 시간’ 부터 선택한 시간단위로 ‘종료 시간’까지의 범위로 노출됩니다.

{% hint style="success" %}
**Example.** HH : MM
{% endhint %}

{% hint style="success" %}
**Tip.**

사용자가 카카오톡에서 설정한 언어/위치에 따라 노출되는 피커가 달라집니다.

* 국문 : 2018년 11월 30일 / 오후 9:40
* 영문 : November 30, 2018 / 9:40PM
* 중문 : 2018年 11月 30日 / 午後 9:40
  {% endhint %}

사용자가 선택한 값은 되묻기 파라미터의 Value에 값을 받을 수 있고 스킬 API까지 아래와 같은 포맷으로 전송받을 수 있습니다.

| 타입    | 포맷                      | 예시                  |
| ----- | ----------------------- | ------------------- |
| 날짜/시간 | yyyy-mm-dd ’T’ hh:mm:ss | 2018-03-19T10:15:00 |
| 날짜    | yyyy-mm-dd              | 2018-03-19          |
| 시간    | hh:mm:ss                | 10:15:00            |

### 스킬 호출값 <a href="#skill_call_value_day_time" id="skill_call_value_day_time"></a>

#### 날짜/시간 <a href="#date_and_time" id="date_and_time"></a>

스킬명이 ‘날짜시간’이고 파라미터명을 ‘datetime’으로 설정한 상태에서 사용자가 3월 20일 10:15를 입력했을 때 스킬로 호출되는 payload는 아래와 같습니다.

```
{
  "action": {
    "name": "날짜시간",
    "clientExtra": null,
    "params": {
        "datetime": "{\"value\":\"2018-03-20T10:15:00\",\"userTimeZone\":\"UTC+9\"}"
    },
    "id": "5ab1cb5c9418c22b668807d4",
    "detailParams": {
      "datetime": {
          "origin": "2018-03-20T10:15:00",
          "value": "{\"value\":\"2018-03-20T10:15:00\",\"userTimeZone\":\"UTC+9\"}",
          "groupName": ""
      }
    }
  }
}
```

#### 날짜 <a href="#date" id="date"></a>

스킬명이 ‘날짜’고 파라미터명을 ‘date’로 설정한 상태에서 사용자가 3월 20일을 입력했을 때 스킬로 호출되는 payload는 아래와 같습니다.

```
{
  "action": {
    "name": "날짜",
    "clientExtra": null,
    "params": {
      "date": "{\"value\":\"2018-03-20\",\"userTimeZone\":\"UTC+9\"}"
    },
    "id": "5ab1cb5c9418c22b668807d4",
    "detailParams": {
      "date": {
        "origin": "2018-03-20",
        "value": "{\"value\":\"2018-03-20\",\"userTimeZone\":\"UTC+9\"}",
        "groupName": ""
      }
    }
  }
}
```

#### 시간 <a href="#time" id="time"></a>

스킬명이 ‘시간’이고 파라미터명을 ‘time’으로 설정한 상태에서 사용자가 15:30을 입력했을 때 스킬로 호출되는 payload는 아래와 같습니다.

```
{
  "action": {
    "name": "시간",
    "clientExtra": null,
    "params": {
      "time": "{\"value\":\"15:30:00\",\"userTimeZone\":\"UTC+9\"}"
    },
    "id": "5ab1cb5c9418c22b668807d4",
    "detailParams": {
        "time": {
            "origin": "15:30:00",
            "value": "{\"value\":\"15:30:00\",\"userTimeZone\":\"UTC+9\"}",
            "groupName": ""
        }
    }
  }
}
```

## 이미지 보안전송 플러그인 <a href="#send_image_plugin" id="send_image_plugin"></a>

### 이미지 보안전송 플러그인이란? <a href="#send_image_plugin" id="send_image_plugin"></a>

**이미지 보안전송 플러그인**은 사용자가 봇에게 개인정보가 포함된 이미지를 최대 10장까지 전송할 수 있는 플러그인입니다. 사용자가 전송한 이미지는 카카오 내부 보안정책에 의해서 안전하게 보관되며, 이미지의 URL은 최대 10분간 유지됩니다.

### 이미지 보안전송 플러그인 설정 <a href="#setting_send_image_plugin" id="setting_send_image_plugin"></a>

#### Step 1. 파라미터 설정 영역을 펼친 후 파라미터 만들기 눌러 팝업을 띄웁니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FL6KiP3nErZBOaDzlB8JH%2Fskill-plugin-secure-image-create-01.png?alt=media&amp;token=0e3cba20-9eea-499c-9ffc-80a026c9da09" alt=""><figcaption><p>파라미터 설정을 펼치고 파라미터 만들기를 선택하는 화면</p></figcaption></figure>

#### Step 2. 플러그인 및 필수 파라미터를 설정하고 확인을 누릅니다.

우측 상단에서 ‘플러그인’으로 변경한 다음 ‘필수 파라미터로 설정’을 체크합니다. (필수 파라미터로 체크하지 않을 경우, 되묻기 질문을 통해 코드 스캐너를 띄워주는 말풍선을 설정할 수 없습니다.)

그 후, 파라미터명을 입력하고 플러그인 목록에서 **@sys.plugin.secureimage**를 선택합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FueiKN7dIsbJcLooeO7JD%2Fskill-plugin-secure-image-create-02.png?alt=media&amp;token=102645e1-e2bf-4a52-bef9-03319b636185" alt=""><figcaption><p>파라미터 설정에서 플러그인을 선택하고 필수 파라미터로 설정하는 화면</p></figcaption></figure>

#### Step 3. 설정된 화면을 확인하고 되묻기 질문 버튼을 클릭합니다.

파라미터명을 입력하고 플러그인을 선택한 후, ‘확인’ 버튼을 누르면 아래와 같이 설정됩니다. 여기서 \[되묻기 질문] 버튼을 클릭하여 플러그인을 통해서 값을 전달받을 수 있는 버튼이 포함된 말풍선을 설정합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FFQJk1HfREgbil3OaUGFN%2Fskill-plugin-secure-image-create-03.png?alt=media&amp;token=184ce6dc-6bb4-484e-96df-a3cb502d09a6" alt=""><figcaption><p>필수 파라미터로 설정이 되고 활성화된 되묻기 질문 버튼을 확인합니다</p></figcaption></figure>

#### Step 4. 되묻기 질문 설정 팝업에서 말풍선에 표시될 텍스트와 버튼명을 입력합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FdcqvqXneyERl6sJswfiR%2Fskill-plugin-secure-image-create-04.png?alt=media&amp;token=051fa58b-e697-442c-9992-e400bfc2bb2c" alt=""><figcaption><p>되묻기 질문 설정에서 이미지 보안전송 플러그인의 응답 말풍선 텍스트와 버튼명을 입력하는 화면</p></figcaption></figure>

#### Step 5. 플러그인 상세설정에서 버튼명을 입력하고 이미지를 전송하는 사용자에게 보여줄 개인정보 동의 수집 항목을 입력합니다.

{% hint style="danger" %}
**Caution.**

수집하는 항목에 대한 내용을 정확하게 작성한 후 사용해주세요. 아래 내용에 동의하지 않으면 사용자는 이미지를 전송할 수 없습니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F6XUg0JAymvdrU2GCRm82%2Fskill-plugin-secure-image-create-05.png?alt=media&amp;token=cd560d83-917c-48dc-be9f-f8f7382254e7" alt=""><figcaption><p>이미지 보안전송 플러그인 버튼명과 개인정보 동의 수집항목 설정</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FV6GshwGkco5ARtkpxiR0%2Fskill-plugin-secure-image-create-06.png?alt=media&amp;token=e35ec53e-0b4e-4112-bbdf-b364f9077f3f" alt=""><figcaption><p>개인정보 수집 및 이용 동의 전문</p></figcaption></figure>

#### Step 6. 봇은 사용자가 보내는 이미지를 아래 순서에 따라 전송받을 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FWmSaxBSuSZqDHikMxQnY%2Fskill-plugin-secure-image-create-07.png?alt=media&amp;token=2bea2be1-f390-4905-8893-a545e0159127" alt=""><figcaption><p>이미지 보안 전송을 처리한 화면</p></figcaption></figure>

메시지를 통해서 파라미터의 Value에 인식된 값을 받을 수 있고 스킬 API까지 아래와 같은 포맷으로 전송받을 수 있습니다.

<table><thead><tr><th width="104.33333333333331">타입</th><th width="332">포맷</th><th>예시</th></tr></thead><tbody><tr><td>이미지</td><td><p>privacyAgreement : 개인정보 제공동의여부</p><p>imageQuantity : 이미지 수량</p><p>secureUrls : 이미지 URL목록</p></td><td><p>privacyAgreement : Y</p><p>imageQuantity : 1</p><p>secureUrls : http://secure.xxxxx.xxxx.xxxxx</p></td></tr></tbody></table>

### 스킬 호출값 <a href="#skill_call_value_send_image" id="skill_call_value_send_image"></a>

스킬명이 ‘이미지보안’이고 파라미터명을 ‘secureimage’로 설정한 상태에서 사용자가 이미지를 전송했을 때 호출되는 payload는 아래와 같습니다.

```
{
  "action": {
    "name": "이미지보안",
    "clientExtra": null,
    "params": {
      "secureimage": "{\"privacyAgreement\":\"Y\",\"imageQuantity\":\"1\",\"secureUrls\":\"List(http://secure.kakaocdn.net/dna/O5UOr/K6auLPnoAf/XXX/img.jpg?credential=Kq0eSbCrZgKIq51jh41Uf1jLsUh7VWcz&expires=1542358548&allow_ip=&allow_referer=&signature=fDuwSKWhQP%2FJdp0nKdunC4XDW%2BM%3D)\",\"expire\":\"1970-01-19T05:25:58+0900\"}"
    },
    "id": "5ab1cb5c9418c22b668807d4",
    "detailParams": {
      "secureimage": {
          "origin": "List(http://secure.kakaocdn.net/dna/O5UOr/K6auLPnoAf/XXX/img.jpg?credential=Kq0eSbCrZgKIq51jh41Uf1jLsUh7VWcz&expires=1542358548&allow_ip=&allow_referer=&signature=fDuwSKWhQP%2FJdp0nKdunC4XDW%2BM%3D)",
          "value": "{\"privacyAgreement\":\"Y\",\"imageQuantity\":\"1\",\"secureUrls\":\"List(http://secure.kakaocdn.net/dna/O5UOr/K6auLPnoAf/XXX/img.jpg?credential=Kq0eSbCrZgKIq51jh41Uf1jLsUh7VWcz&expires=1542358548&allow_ip=&allow_referer=&signature=fDuwSKWhQP%2FJdp0nKdunC4XDW%2BM%3D)\",\"expire\":\"1970-01-19T05:25:58+0900\"}",
          "groupName": ""
      }
    }
  }
}
```

## 위치전송 플러그인 <a href="#send_location_plugin" id="send_location_plugin"></a>

### 위치전송 플러그인이란? <a href="#send_location_plugin" id="send_location_plugin"></a>

위치전송 플러그인은 사용자가 봇 작업자에게 위치 정보를 전송할 수 있도록 지도를 통해 장소를 지정하여 입력받는 역할을 합니다. 봇 작업자가 설계한 말풍선에서 사용자가 위치 입력을 위한 버튼 클릭 시 지도가 뜨며, 사용자의 현재 위치 정보를 입력할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fj3ugBkLAFf1AstIxGwjA%2Fcurrent-loca-07_.png?alt=media&amp;token=4f86d013-ade7-4752-a55a-342c01da84ec" alt=""><figcaption><p>OS 및 버전에 따라 상기 이미지와 약간의 차이가 존재할 수 있습니다.</p></figcaption></figure>

### 사전 설정하기 <a href="#setting_preset" id="setting_preset"></a>

챗봇 관리자센터에서 위치전송 플러그인을 사용하시려면 아래와 같은 사전 설정이 필요합니다.

#### Step 1. 카카오싱크 설정하기

위치전송 플러그인을 사용하기 위해서는 비즈니스 인증을 통한 카카오싱크 설정이 필수입니다. 이때, 싱크1단계(비즈 채널-앱 연결)만으로 플러그인을 사용할 수 있습니다.

{% hint style="info" %}
**Information.**

카카오톡 비즈니스 채널(인증된 프로필)과 디벨로퍼스 비즈 앱 생성 방법 및 카카오싱크 신청하는 방법은 [**카카오싱크 공통 가이드**](https://developers.kakao.com/docs/latest/ko/kakaosync/common#table-of-contents)에서 상세하게 확인할 수 있습니다.
{% endhint %}

[**카카오 디벨로퍼스**](https://developers.kakao.com/console/app?continue=/review)에서 위에서 만든 비즈니스 인증을 받은 채널과 앱을 연결할 수 있습니다. 이때, 카카오 비즈니스 인증 채널을 신청하실 때에는 실제 서비스에서 사용할 카카오톡 채널로 신청해야 합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F3rLjI4NhmKwzd8a5CqrO%2Fp.15%2C16%2C%2018.png?alt=media&amp;token=8837261f-2c0f-4992-a7d7-f1ab59d76f6a" alt=""><figcaption><p>디벨로퍼스 > 앱 > 추가 기능 신청 > 신청 가능 대상 > 추가 기능 > 카카오톡 채널 연결</p></figcaption></figure>

#### Step 2. 디벨로퍼스 설정하기

제품 설정 > 카카오 로그인 메뉴에서 '활성화 설정' 상태를 반드시 ON으로 변경해주세요.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FwxOL8JJcImWgi0cIRp4f%2F%E1%84%85%E1%85%A9%E1%84%80%E1%85%B3%E1%84%8B%E1%85%B5%E1%86%AB%E1%84%8B%E1%85%A9%E1%86%AB%202.png?alt=media&amp;token=b78693ae-bab0-4277-af43-b60350abf068" alt=""><figcaption><p>디벨로퍼스 > 앱 > 카카오 로그인 > 일반</p></figcaption></figure>

#### Step 3. 비즈플러그인에서 위치전송 플러그인 등록하기

사전 설정이 완료되면 카카오비즈니스 관리자센터의 [**비즈플러그인 메뉴**](https://business.kakao.com/plugin)에서 위치전송 플러그인을 등록하여 플러그인ID를 발급받을 수 있습니다.

(1) 비즈플러그인 등록하기를 클릭합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FIG2qkJ2PzOhGmdMDY8dY%2FSinkplugin_0323_002.png?alt=media&amp;token=ec377460-4272-4b0e-b0bd-53b4ad8dde3a" alt=""><figcaption><p>생성된 플러그인이 없는 경우 진입 페이지 하단에 [비즈플러그인 등록하기] 버튼이 노출됩니다.</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F4r61ns6Jplm6lBS4aMWP%2FSinkplugin_0323_003.png?alt=media&amp;token=3ae73991-f62f-4765-b1db-62430c768856" alt=""><figcaption><p>기 생성된 플러그인이 있는 경우 플러그인 목록 상단에 [+등록하기] 버튼이 노출됩니다.</p></figcaption></figure>

(2) 위치전송 플러그인을 사용하고자하는 비즈앱을 선택합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F8lSxqoDCjcHsPrGGddMZ%2FSinkplugin_0323_004.png?alt=media&amp;token=ef2a0aac-4fb3-4a3e-bf25-dd1321d01887" alt=""><figcaption><p>플러그인을 등록할 비즈앱 선택 화면</p></figcaption></figure>

(3) 플러그인 목적 선택시 '위치 전송'를 선택합니다. 위치전송 플러그인은 **앱별로 1개 생성**이 가능합니다.

&#x20;

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FnndoW0jsnNO8xCLNZtqU%2Fimage.png?alt=media&amp;token=5ac1dbfd-3a12-42d6-a263-afd3035ea826" alt=""><figcaption><p>플러그인 목적 선택 화면</p></figcaption></figure>

{% hint style="danger" %}
**Caution.**\
아래 경우 위치전송 플러그인 선택이 불가능합니다.

* 이미 해당 앱에 생성된 위치전송 플러그인이 있는 경우
  {% endhint %}

(4) 플러그인 이름 및 사용 목적, 상세주소 노출 여부를 입력한 후 \[등록] 버튼을 클릭하면 위치전송 플러그인 등록 및 플러그인ID 발급이 완료됩니다. 입력한 사용목적은 카카오의 [**위치기반서비스 이용약관**](https://www.kakao.com/policy/location?lang=ko) 내 위치정보 제공 현황 자세히 보기 페이지에 노출됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fy6kq5KgnP01K1EqNqCZY%2FSinkplugin_0323_006.png?alt=media&amp;token=f88ead9c-f977-4f9f-80e0-34f4fa923dbc" alt=""><figcaption><p>위치전송 플러그인 내용 입력 화면</p></figcaption></figure>

{% hint style="info" %}
**Information.**\
이미 생성된 위치전송 플러그인에서 상세주소 기능을 설정하고 싶은 경우, 플러그인 상세 화면 > 플러그인 속성 편집에서 상세주소 ON/OFF 설정이 가능합니다.
{% endhint %}

#### Step 4. 챗봇 관리자센터와 채널 연결하기

위치전송 플러그인이 정상적으로 동작하기 위해서는 반드시 동일한 앱에 연결된 운영 채널과 개발 채널이 모두 봇과 연결되어 있어야 합니다. 이때, 채널 관리자 센터에서 개발자용 채널을 생성하면 더욱 쉽게 연결을 준비할 수 있습니다.

{% hint style="info" %}
**Information. 개발자용 채널 생성하기**\
개발자용 프로필은 카카오톡 채널 관리자 센터에서 제공하는 기능으로 기존 생성된 프로필의 친구들에게 영향을 주지 않고 비즈니스 인증 채널에 제공되는 다양한 기능을 테스트해 볼 수 있는 프로필을 신규 생성하는 기능입니다.\
[자세히보기](https://center-pf.kakao.com/notices/339)
{% endhint %}

(1) 카카오톡 채널 관리자 센터 > 내 채널 목록에서 개발자용 채널을 생성합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FYL4x2OGsLC92y4pxl6lY%2Ftutorial_syncplugin01.png?alt=media&amp;token=4c32dd52-cf61-46b0-8bd0-10f75c30fed4" alt=""><figcaption><p>'개발자용 채널 만들기' 버튼은 비즈니스 채널 인증을 완료한 채널의 마스터인 경우에만 노출됩니다.</p></figcaption></figure>

(2) 개발자용 프로필을 생성한 후, 카카오싱크 페이지에서 싱크 검수 완료된 비즈 앱과 추가로 연결합니다.

(3) 챗봇 관리자센터의 **설정 메뉴 > 기본 정보**에서 운영 채널과 개발 채널을 모두 연결합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FzBPooazper5S15r5GNd6%2Ftutorial_syncplugin02.png?alt=media&amp;token=d364385f-ab48-4ed4-a577-86d517332001" alt=""><figcaption><p>운영 채널과 개발 채널이 동일한 앱에 연결된 상태입니다. 채널이 앱과 연결되어있다면 인증블록이 자동으로 설정됩니다.</p></figcaption></figure>

### 챗봇 관리자센터 연동하기 <a href="#connect_bot_admin" id="connect_bot_admin"></a>

사전 설정을 완료한 후 일반블록의 필수 파라미터 생성을 통해 위치전송 플러그인을 설정할 수 있습니다.

#### Step 1. 인증블록 설정하기

(1) 파라미터 생성 팝업 내 플러그인 목록에서 **위치전송 플러그인(@sys.plugin.current\_location)**&#xC744; 선택한 후 파라미터 설정을 완료합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F1ue3sft6peuDMpZvasrY%2Fcurrent-loca-04_.png?alt=media&amp;token=dbd8b35f-38ce-4572-a43c-edc27ec75ae8" alt=""><figcaption><p>필수 파라미터 설정화면</p></figcaption></figure>

(2) 필수 파라미터가 지정된 상태에서 '되묻기 질문'을 클릭합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FK9RXlz4bpIrJ1V7Id4d2%2Fcurrent-loca-05_.png?alt=media&amp;token=1927d0be-b284-4741-b1bf-49d8614b69c4" alt=""><figcaption><p>플러그인은 필수 파라미터로 설정해야하며, 되묻기 상황을 정의해야 사용할 수 있습니다.</p></figcaption></figure>

(3) 되묻기 질문 작성 팝업에서 사용자들이 플러그인 실행을 위해 접하게 되는 말풍선의 가이드 문구와 버튼명을 설정할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FrNlazV7ZfVU0GZs42qM1%2Ftutorial_locationplugin_.png?alt=media&amp;token=4d9e9243-b10a-4285-b743-95383129213f" alt=""><figcaption><p>되묻기 질문 작성 팝업</p></figcaption></figure>

#### Step 2. 데이터 전달방식 확인하기

(1) 개인정보를 포함한 정보를 전달하기 때문에 OTP URL 전송방식을 이용합니다.

(2) appUserId는 plain text로 전달되며 위치정보는 OTP URL에 포함되어 있습니다.

(3) 전달된 OTP URL을 이용해 위치 정보를 조회하고자 하는 경우, [**위치전송 플러그인 개발 가이드**](https://t1.kakaocdn.net/kakao_biz_common/prod/cms/may.s/6c4a14f719a54b5b928c9584677d2604?x-content-disposition=inline#page=19\&zoom=100,96,264)를 참고해주시기 바랍니다.

\
OTP URL을 통해 위치 정보를 아래와 같은 포맷으로 전송받을 수 있습니다.

| 타입  | 포멧                                                                                                                                                                              | 예시                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 현위치 | <p>latitude : 위도 (좌표계 : WGS84)</p><p>longitude : 경도 (좌표계 : WGS84)</p><p>land\_address : 지번 주소 정보</p><p>road\_address : 도로명 주소 정보</p><p>detail : 상세주소(동/호수 등 사용자가 직접 입력한 정보)</p> | { "latitude": 37.40201073377386, "longitude": 127.10849451749681, "land\_address": { "address\_name": "경기 성남시 분당구 삼평동 681", "region\_1depth\_name": "경기", "region\_2depth\_name": "성남시 분당구", "region\_3depth\_name": "삼평동", "mountain\_yn": "N", "main\_address\_no": "681", "sub\_address\_no": "" }, "road\_address": { "address\_name": "경기도 성남시 분당구 판교역로 235", "region\_1depth\_name": "경기", "region\_2depth\_name": "성남시 분당구", "region\_3depth\_name": "", "road\_name": "판교역로", "underground\_yn": "N", "main\_building\_no": "235", "sub\_building\_no": "", "building\_name": "에이치스퀘어 엔동", "zone\_no": "13494" } "detail" : "8층 카카오" } |

※ OS 버전에 따라 주소 형식에 차이가 존재할 수 있습니다.

※ 상세주소("detail" 필드)는 위치전송 플러그인 상세설정 > **상세주소 ON** 일 경우에만 데이터가 전달됩니다.

※ 위치정보를 전달할 수 없는 경우 otp url에 x,y 좌표 대신 하기 내용이 포함됩니다.

{% hint style="success" %}
**Example.** "is\_usable\_user" : false
{% endhint %}

## 카카오싱크 플러그인 <a href="#sync_plugin" id="sync_plugin"></a>

### 카카오싱크 플러그인이란? <a href="#sync_plugin" id="sync_plugin"></a>

카카오톡 채널 채팅방에서 봇 서비스 제공 중 회원 가입 및 정보 연동이 필요한 경우, 카카오싱크 플러그인을 통해 화면 전환 없이 채널 채팅방 안에서 회원 가입 절차를 수행할 수 있습니다. 카카오싱크 플러그인(이하 싱크 플러그인)은 채팅방에 자연스럽게 노출되는 형태로 사용자 정보 제공 및 약관 동의 팝업을 제공, 카카오계정으로 서비스에 가입할 수 있는 카카오싱크의 간편가입 기능을 카카오톡에서 봇과의 대화 중에도 쓸 수 있도록 해 줍니다. REST API 방식의 카카오 로그인 기반으로 회원가입 연동이 가능하며, 이미 카카오 로그인이 구현된 서비스에서는 보다 쉽게 적용할 수 있습니다.

{% hint style="info" %}
**Information.**\
\[받을 수 있는 정보 종류]

* 사용자관리 제공 정보 : 프로필 정보, 이메일, 전화번호, 배송지정보, 성별, 연령대, 생일, 출생연도, \*CI\
  \*CI(연계정보)는 '회원비교식별' 목적으로 활용하며, 보유기간은 '제공목적(회원비교식별)'이 달성되면 지체없이 파기해야 합니다.

\[설정할 수 있는 약관 종류]

* 해당 서비스의 약관 : 필수 약관, 선택 약관 (필요시, 개정된 약관의 동의도 가능)
  {% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F4LIjN66LC8WHyOST7MSZ%2Fsync_plugin_main.png?alt=media&amp;token=2100d4f5-ad2f-4f32-97d1-ba2f24e387f0" alt=""><figcaption></figcaption></figure>

### 사전 설정하기 <a href="#setting_preset" id="setting_preset"></a>

챗봇 관리자센터에서 싱크 플러그인을 사용하시려면 아래와 같은 설정이 필요합니다.

#### Step 1. 카카오싱크 설정하기

싱크 플러그인을 사용하기 위해서는 비즈니스 인증을 통한 카카오싱크 설정이 필수입니다.

{% hint style="info" %}
**Information.**

서비스에서 로그인 리다이렉트 URI를 통해 정보 조회를 위한 'code' 값과 회원가입 완료 또는 추가 맵핑 등에 필요한 'continue URL' 값을 전달받게 되며, 자세한 내용은 [**카카오싱크 플러그인 개발가이드**](https://developers.kakao.com/docs/latest/ko/kakaosync/plugin)를 확인해주시기 바랍니다.\
\
리다이렉트 URI은 테스트앱을 사용해야 하는데 챗봇에서는 일반앱 등록이 필요합니다. 위와 같이 테스트앱을 사용해야 하는 경우 테스트용 봇을 하나 더 생성하시고 해당 봇에서 리다이렉트 URI를 테스트하신 후 문제없을 시 기존 앱에 적용할 수 있습니다.
{% endhint %}

(1) 비즈니스 채널과 앱 연결하기

[**카카오 디벨로퍼스**](https://developers.kakao.com/console/app?continue=/review)에서 위에서 만든 비즈니스 인증을 받은 채널과 앱을 연결할 수 있습니다. 이때, 카카오 비즈니스 인증 채널을 신청하실 때에는 실제 서비스에서 사용할 카카오톡 채널로 신청해야 합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F1zOuZQkB4yj4aXKR3v12%2Fp.15%2C16%2C%2018.png?alt=media&amp;token=23468c0d-2204-4552-97a3-988a6833b024" alt=""><figcaption><p>디벨로퍼스 > 앱 > 추가 기능 신청 > 신청 가능 대상 > 추가 기능 > 카카오톡 채널 연결</p></figcaption></figure>

(2) 카카오싱크 검수 신청하기

채널-앱 연결을 완료한 후, 싱크 검수를 요청합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FfbVqyhuM9FlmbZKReX8a%2Fp.16%2C%2019.png?alt=media&amp;token=b3e94b27-a607-42b5-bf45-75d0dc1b10e6" alt=""><figcaption><p>디벨로퍼스 > 내 애플리케이션 > 앱 설정 > 앱 권한 신청 개인정보 동의하기 화면</p></figcaption></figure>

#### Step 2. 디벨로퍼스 설정하기

(1) 제품 설정 > 카카오 로그인 메뉴에서 '사용 설정' 상태를 ON으로 변경해주세요.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FxNZPgzsN3C8Fzo7W8muA%2Fimg06.png?alt=media&amp;token=c57b7cae-194c-4a2d-afd3-748865a09ff4" alt=""><figcaption><p>디벨로퍼스 > 앱 > 카카오 로그인 > 일반</p></figcaption></figure>

(2) 제품 설정 > 카카오 로그인 > 간편가입 메뉴에서 '사용 설정' 상태를 ON으로 변경해주세요.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FFwOUjXZweEB3mMzl2zWv%2Fp.20.png?alt=media&amp;token=6bcb2e83-11e1-4837-acb4-925f74e33856" alt=""><figcaption><p>디벨로퍼스 > 앱 > 제품 설정 > 카카오 로그인 > 간편가입</p></figcaption></figure>

(3) 제품 설정 > 간편가입 메뉴에서 카카오싱크 플러그인 리다이렉트 URI를 입력해주세요.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FwOI8PrwFOUrGhXwODnFv%2Fp.17%2C%2021.png?alt=media&amp;token=636ee1a1-3285-4b27-a7e5-afdae4c70e01" alt=""><figcaption><p>디벨로퍼스 > 앱 > 제품 설정 > 카카오 로그인 > 고급 > 카카오싱크 플러그인 > 리다이렉트 URl</p></figcaption></figure>

{% hint style="info" %}
**Information.**\
서비스에서 로그인 리다이렉트 URI를 통해 정보 조회를 위한 'code' 값과 회원가입 완료 또는 추가 맵핑 등에 필요한 'continue URL' 값을 전달받게 되며, 자세한 내용은 [**카카오싱크 플러그인 개발가이드**](https://developers.kakao.com/docs/latest/ko/kakaosync/plugin)를 확인해주시기 바랍니다.
{% endhint %}

#### Step 3. 비즈플러그인에서 카카오싱크 플러그인 등록하기

사전 설정이 완료되면 카카오비즈니스 관리자센터의 [**비즈플러그인 메뉴**](https://business.kakao.com/plugin)에서 카카오싱크 플러그인을 등록하여 플러그인ID를 발급받을 수 있습니다.

(1) 비즈플러그인 등록하기를 클릭합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fbl9kLJQAQBVMwk6jxMEK%2FSinkplugin_0323_002%20(1).png?alt=media&amp;token=9fe35b16-e26e-4f14-8f28-badf91f7c240" alt=""><figcaption><p>생성된 플러그인이 없는 경우 진입 페이지 하단에 [비즈플러그인 등록하기] 버튼이 노출됩니다.</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FsWGt48E8XnxlMNKaO0kQ%2FSinkplugin_0323_003%20(1).png?alt=media&amp;token=40a06537-5895-4ccf-89b7-37ddc3432030" alt=""><figcaption><p>기 생성된 플러그인이 있는 경우 플러그인 목록 상단에 [+등록하기] 버튼이 노출됩니다.</p></figcaption></figure>

(2) 싱크 플러그인을 사용하고자하는 비즈앱을 선택합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FelwCNi3g6VI3gU40QYy4%2FSinkplugin_0323_004%20(1).png?alt=media&amp;token=610e2ef9-68d4-4890-9e94-8c9ee1650721" alt=""><figcaption><p>플러그인을 등록할 비즈앱 선택 화면</p></figcaption></figure>

(3) 플러그인 목적 선택시 '카카오싱크'를 선택합니다. 싱크 플러그인은 **앱별로 1개 생성**이 가능합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FP548VjoyggTa6DuKz4XU%2FSinkplugin_0323_007%20(1).png?alt=media&amp;token=cd8f555b-eb7e-408c-9a86-bd8a454e32b5" alt=""><figcaption><p>플러그인 목적 선택 화면</p></figcaption></figure>

{% hint style="danger" %}
**Caution.**\
아래 경우 카카오싱크 플러그인 선택이 불가능합니다.

* 카카오싱크 검수가 완료되지 않은 경우
* 디벨로퍼스 설정에 오류가 있는 경우
* 이미 해당 앱에 생성된 카카오싱크 플러그인이 있는 경우
  {% endhint %}

(4) 플러그인 이름을 설정한 후 \[등록] 버튼을 클릭하면 카카오싱크 플러그인 등록 및 플러그인ID 발급이 완료됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fqh2Ee0aKBCq9XBLbVM6B%2FSinkplugin_0323_008.png?alt=media&amp;token=1ec2969f-a400-41bf-a29c-7f8f1392ee9d" alt=""><figcaption><p>플러그인 이름 입력 화면</p></figcaption></figure>

#### Step 4. 챗봇 관리자센터와 채널 연결하기

인증블록에서 설정한 플러그인이 정상적으로 동작하기 위해서는 반드시 동일한 앱에 연결된 운영 채널과 개발 채널이 모두 봇과 연결되어 있어야 합니다. 이때, 채널 관리자 센터에서 개발자용 채널을 생성하면 더욱 쉽게 연결을 준비할 수 있습니다.

{% hint style="info" %}
**Information. 개발자용 채널 생성하기**\
개발자용 프로필은 카카오톡 채널 관리자 센터에서 제공하는 기능으로 기존 생성된 프로필의 친구들에게 영향을 주지 않고 비즈니스 인증 채널에 제공되는 다양한 기능을 테스트해 볼 수 있는 프로필을 신규 생성하는 기능입니다.\
[**자세히보기**](https://center-pf.kakao.com/notices/339)
{% endhint %}

(1) 카카오톡 채널 관리자 센터 > 내 채널 목록에서 개발자용 채널을 생성합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FV3HTGHXHM96B3614gPyJ%2Ftutorial_syncplugin01%20(2).png?alt=media&amp;token=b9eaf638-9b0b-4e9b-acb5-922c43d5689f" alt=""><figcaption><p>'개발자용 채널 만들기' 버튼은 비즈니스 채널 인증을 완료한 채널의 마스터인 경우에만 노출됩니다.</p></figcaption></figure>

(2) 개발자용 프로필을 생성한 후, 카카오싱크 페이지에서 싱크 검수 완료된 비즈 앱과 추가로 연결합니다.

(3) 챗봇 관리자센터의 **설정 메뉴 > 기본 정보**에서 운영 채널과 개발 채널을 모두 연결합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FCfqVMryV7uBKITLpWKDR%2Ftutorial_syncplugin02%20(2).png?alt=media&amp;token=9cb60bbd-2357-4396-9959-3cb589baab3e" alt=""><figcaption><p>운영 채널과 개발 채널이 동일한 앱에 연결되어있을 경우, 채널 연결 완료 시 자동으로 '인증블록 설정됨' 표시가 출력됩니다.</p></figcaption></figure>

(4) 위 설정까지 완료했다면, **시나리오 > 기본 시나리오**에 인증블록이 추가된 것을 확인하실 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FsFctw5nptLAytq4p6XUy%2Ftutorial_syncplugin03%20(1).png?alt=media&amp;token=35873c40-7195-4889-bf9c-107ba27f4445" alt=""><figcaption><p>시나리오 > 기본 시나리오에 인증블록이 추가된 화면</p></figcaption></figure>

### 챗봇 관리자센터 연동하기 <a href="#connect_bot_admin" id="connect_bot_admin"></a>

사전 설정을 완료한 후 인증블록의 필수 파라미터 생성을 통해 카카오싱크 플러그인을 설정할 수 있습니다.

#### Step 1. 인증블록 설정하기

(1) 파라미터 생성 팝업 내 플러그인 목록에서 **카카오싱크 플러그인(@sys.plugin.sync)**&#xC744; 선택한 후 파라미터 설정을 완료합니다. 플러그인 목록에는 싱크 플러그인 생성시 입력한 플러그인 이름이 노출됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FqHBxHBFZyrGu7ljOCGdd%2Ftutorial_syncplugin2.png?alt=media&amp;token=5d8faf46-f7cc-4ce6-b54c-b231f60f1905" alt=""><figcaption><p>필수 파라미터 설정화면</p></figcaption></figure>

(2) 필수 파라미터가 지정된 상태에서 '되묻기 질문'을 클릭합니다.

플러그인은 필수 파라미터로 설정해야하며, 되묻기 상황을 정의해야 사용할 수 있습니다.

(3) 되묻기 질문 작성 팝업에서 사용자들이 플러그인 실행을 위해 접하게 되는 말풍선의 가이드 문구와 버튼명을 설정할 수 있습니다. 이때, \[버튼명 입력] 버튼을 클릭하면 싱크 플러그인을 통해 수집할 수 있는 개인정보 제공 동의 항목을 확인할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FaiD4NARdOKv6En3cYbV9%2Ftutorial_syncplugin06(1).png?alt=media&amp;token=b1785617-2c75-463c-b1d5-8dbc23220e5d" alt=""><figcaption><p>되묻기 질문 작성 팝업</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FDkRrVx3pZy87H24FxxKb%2Ftutorial_syncplugin07(1).png?alt=media&amp;token=738536ef-9590-4c82-9200-342bac4f3ca6" alt=""><figcaption><p>플러그인 상세 기능 설정 화면</p></figcaption></figure>

{% hint style="info" %}
**Information.**\
개인정보 제공 동의 항목은 \[디벨로퍼스 > 앱 > 제품설정 > 카카오 로그인 > 고급] 에서 수정할 수 있습니다.
{% endhint %}

#### Step 2. 인증블록 연결하기

인증블록 설정 및 저장이 완료되면, 챗봇 시나리오 상 싱크 플러그인 실행이 필요한 블록에서 인증블록을 연결합니다. 봇 응답(말풍선) 내 버튼의 '블록연결' 기능을 통해 싱크 플러그인이 설정된 인증블록을 연결시킬 수 있습니다. 인증블록이 정상적으로 저장되지 않은 경우, 연결 가능한 블록 목록에 노출되지 않을 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FRdhPfsZhgUvkF8pccLV4%2Ftutorial_syncplugin08(1).png?alt=media&amp;token=a06dc6ef-b825-4e53-84de-5560ed4d55cf" alt=""><figcaption><p>예시 : 다른 블록에서 버튼 설정 > '블록연결' 기능을 통해 인증블록을 연결하는 화면</p></figcaption></figure>

### 싱크 플러그인 개발하기 <a href="#develope_sync_plugin" id="develope_sync_plugin"></a>

자세한 개발 스펙은 [**카카오싱크 플러그인 개발 가이드**](https://developers.kakao.com/docs/latest/ko/kakaosync/plugin)를 참고해주시기 바랍니다.


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/apply_skill_to_plugin.md
