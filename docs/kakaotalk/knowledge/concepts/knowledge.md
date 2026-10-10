> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/knowledge/concepts/knowledge.md).

# 지식

## 1. 지식이란?

사용자가 **지식 베이스에 업로드한 모든 데이터**를 말하며, 크게 **기본 정보와 질문과 답변 정보로 구분**됩니다. 지식은 지식 베이스당 최대 10000개까지 생성할 수 있습니다.&#x20;

![지식 관리 페이지](https://234308570-files.gitbook.io/~/files/v0/b/gitbook-legacy-files/o/assets%2F-MVZVmVOd-5LtENUPqdq%2F-MkBeycNx7gi9QqALD-R%2F-MkBiLgG8LbnHBYZHGbe%2Fimage.png?alt=media\&token=8c29af3c-08b5-4f86-b0c8-89f7f701fe48)

### **1.1 기본 정보**

* **업로드 일시**: 해당 지식이 업로드된 일시입니다.&#x20;
* **배포 상태**: 배포 상태를 보여주며, 배포 상태는 3가지 값을 갖습니다. \
  &#x20; *1. **배포 완료**: 배포가 완료되어 최신 버전에 반영된 지식입니다.* \
  &#x20; *2. **배포 미완료\_새로 추가**: 새로 추가되어 최신 버전에 반영되지 못한 지식입니다.*\
  &#x20; *3. **배포 미완료\_ 수정됨**: 지식이 수정되어 최신 버전에 반영되지 못한 지식입니다.*
* **최종 수정 일시**: 지식의 마지막 수정 시간을 표기하며, 히스토리를 통하여 일시와 변경한 관리자를 확인할 수 있습니다.
* **최종 편집자**: 마지막으로 지식을 수정한 관리자를 노출합니다.
* **카테고리**: 지식에 설정된 카테고리를 보여줍니다.
* **메모**: 관리자가 지식에 기입한 메모를 노출하며, 200자까지 입력 가능합니다.&#x20;

### **1.2 질문과 답변 정보**

* **질문**: 고객이 자주 묻는 질문으로 50자까지 입력 가능합나다.&#x20;
* **답변**: 질문에 대한 답변으로 1000자까지 입력 가능하며, Landing URL을 사용할 경우에는 400자까지만 사용 가능합니다.&#x20;
* **Landing URL**: 답변 응답과 함께 제공되는 URL입니다. 말풍선에서 버튼형식으로 제공되며, 버튼명은 14자까지 입력 가능합니다.&#x20;
* **Image URL**: 봇에서만 사용 가능하며, 지식베이스 응답 설정에서 '답안추천형'을 사용하면서 응답으로 카드형 말풍선을 설정한 경우에만 제공됩니다. (유사 질문이 1개일 경우 즉문즉답형 말풍선이 노출되어 image URL 적용이 반영되지 않습니다.)

## 2. 지식 생성

지식 베이스에서 지식을 업로드하는 방식은 3가지가 있습니다. 그 중 파일 업로드와 API 연결을 통하여 지식을 업로드할 경우에는 업로드 방식을 선택할 수 있습니다. 업로드 방식은 아래와 같습니다.

* **기존 리스트에 추가**: 기존 지식을 삭제하지 않고, 추가로 지식 데이터를 업로드합니다.&#x20;
* **덮어쓰기**: 기존 지식을 모두 삭제하고, 새로운 지식 데이터를 업로드합니다.

### 2-1. 지식 생성(1)\_직접 입력

관리자가 **수동으로 지식 데이터를 입력**하는 방식입니다. 지식 관리 페이지의 상단 **'지식 추가' 버튼을 눌러 지식을 추가**할 수 있습니다. 지식 추가를 하기 위해서는 권한 상세 중 지식(쓰기) 기능이 필요합니다.

!['지식 추가' 페이지](https://234308570-files.gitbook.io/~/files/v0/b/gitbook-legacy-files/o/assets%2F-MVZVmVOd-5LtENUPqdq%2F-MkBk3Uo4DK6zd2RiyR_%2F-MkBkcsbewuPE0i7qMnE%2Fimage.png?alt=media\&token=71749fa7-551a-4165-a2c2-92f20934d7c7)

### 2-2. 지식 생성(2)\_파일 업로드

관리자가 **CSV(UTF-8 인코딩), XLSX 파일을 이용하여 대량의 지식 데이터를 업로드**하는 방식입니다. 지식 관리 페이지의 '지식 업로드' 버튼을 눌러 파일 업로드를 할 수 있습니다. 파일 업로드를 하기 위해서는 권한 상세 중 지식(쓰기) 기능이 필요합니다. 업로드 시, 비고의 주의사항을 지키지 않을 경우, 파일 업로드가 실패합니다.

{% file src="/files/3qmm4XZlYGyvlWCrOzdv" %}

![지식 업로드 팝업(1)\_파일 업로드](https://234308570-files.gitbook.io/~/files/v0/b/gitbook-legacy-files/o/assets%2F-MVZVmVOd-5LtENUPqdq%2F-MkBk3Uo4DK6zd2RiyR_%2F-MkBkM-3ioGOZI4sLSKN%2Fimage.png?alt=media\&token=89150635-82ec-4682-8efd-4c5358b03fbd)

지식 파일은 아래의 정보를 담고 있습니다.

|   **컬럼명**   | **필수 여부** |                                                 **설명**                                                |                                            **비고**                                           |
| :---------: | :-------: | :---------------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------: |
|   FAQ\_No   |     선택    |                                             지식 데이터의 순번입니다.                                            |                                    -지식은 10000개를 초과할 수 없음                                    |
|  Category 1 |     선택    |                        <p>지식 데이터를 분류할 수 있는 </p><p>대/중/소1/소2/소3 카테고리 정보입니다.</p>                        | <p>-최대 글자수 20자 </p><p>-카테고리는 중간에 빈값을 </p><p>가질 수 없음 </p><p>-같은 뎁스에서는 같은 카테고리명을 사용할 수 없음</p> |
|  Category 2 |     선택    |                                                                                                       |                                                                                             |
|  Category 3 |     선택    |                                                                                                       |                                                                                             |
|  Category 4 |     선택    |                                                                                                       |                                                                                             |
|  Category 5 |     선택    |                                                                                                       |                                                                                             |
|   Question  |     필수    |                                               질문 내용입니다.                                               |                                         -최대 글자수 50자                                         |
|    Answer   |     필수    |                                               답변 내용입니다.                                               |                <p>-최대 글자수 1000자</p><p>-Landing URL 사용할 경우,<br>최대 글자수 400자</p>               |
| Landing URL |     선택    | <p>답변 응답과 함께 제공되는 URL로 말풍선에서 </p><p>버튼형으로 제공됩니다.</p><p>버튼명은 지식베이스의 지식 상세 페이지에서 </p><p>설정할 수 있습니다.</p> |                                                                                             |
|  Image URL  |     선택    |         <p>봇에서만 사용 가능하며, 지식베이스 응답 설정에서 </p><p>'답안추천형'을 사용하면서 응답으로 카드형 말풍선을 설정한 경우에만 제공됩니다.</p>        |                                                                                             |

{% hint style="info" %}
**파일의 지식 개수와 업로드된 지식 개수가 달라요**\
만약  지식의 모든 컬럼 정보가 일치할 경우, 중복처리 되어 1개의 지식만 업로드 됩니다.&#x20;
{% endhint %}

### 2-3. 지식 생성(3)\_API 연결

관리자가 **API를 연결하여 외부의 데이터 베이스의 지식 데이터를 풀링pulling하여 업로드**할 수 있습니다. 지식 관리 페이지의 '지식 업로드' 버튼을 눌러 API 연결 할 수 있습니다. 파일 업로드를 하기 위해서는 권한 상세 중 지식(쓰기) 기능이 필요합니다.

![지식 업로드 팝업(2)\_API 연결](https://234308570-files.gitbook.io/~/files/v0/b/gitbook-legacy-files/o/assets%2F-MVZVmVOd-5LtENUPqdq%2F-MkBk3Uo4DK6zd2RiyR_%2F-MkBkTOiE3szvNN1y4AQ%2Fimage.png?alt=media\&token=a2da31e7-53e1-486f-94a6-85ca0fb71a03)

**REQUEST**\
지식베이스는 GET Method를 사용하여 정보를 요청합니다.\
\
**RESPONSE**\
업로드를 위해서는 데이터 베이스에 JSON 형식으로 아래와 같이 페이로드payload를 구성하여 API 전송을 해야합니다.

|    **이름**    | **타입** | **필수 여부** |                                                                                                **설명**                                                                                                |
| :----------: | :----: | :-------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
|    values    | string |     필수    | <p>기존 CSV, XLSX 파일의 행row이 필드에 담기게 됩니다. </p><p>\[] 대괄호 안에 FAQ\_No, Category1, Category2, Category3, Category4, Category5 , Question, Answer,  Landing URL, Image URL을 </p><p>입력하며, 모든 값이 필수 입니다. </p> |
| schema\_type | string |     필수    |                                                                                         "1.0" 을 고정으로 입력해야합니다.                                                                                        |

```
{
  "values": [
    [
      "1",
      "Category1",
      "Category2",
      "Category3",
      "Category4",
      "Category5",
      "Question",
      "Answer",
      "Landing URL",
      "Image URL"
     ]
  ],
  "name":
  "schema_type": "1.0"
}
```


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/knowledge/concepts/knowledge.md
