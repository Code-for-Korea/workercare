> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/deploy.md).

# 배포

**배포**란 챗봇 관리자센터에서 봇을 설계 및 저장한 내용을 실제 서비스에 반영하는 기능입니다. 배포를 하지 않으면 저장한 모든 내용은 운영 채널에 반영되지 않습니다. 따라서 사전에 개발 채널에서 충분히 테스트를 한 후 배포하여 주시기 바랍니다.

배포는 한 번에 전체 내역을 배포할 수 있는 ‘전체 배포'와 필요한 내역만 선택하여 배포하는 ‘부분 배포'로 구성되어 있으며 필요에 따라 배포 형태를 선택할 수 있습니다.

배포가 시작되면 중지시킬 수 없으며, 봇의 발화 수나 블록 수 등에 따라서 최대 30분이 소요될 수 있습니다.

배포 메뉴는 읽기 또는 쓰기 권한을 가진 사람에게만 보이며, 기본적으로는 마스터 1인에게만 권한이 부여됩니다. 마스터는 권한 메뉴에서 특정 작업자에게 커스텀 권한으로 ‘배포’ 권한을 부여할 수 있습니다.

## 카카오톡 채널 챗봇 배포 <a href="#kakaotalk_channel_chatbot_deploy" id="kakaotalk_channel_chatbot_deploy"></a>

챗봇은 배포 메뉴에서 전체 배포, 부분 배포 중 한 가지를 선택한 후 배포가 가능합니다. 챗봇의 버전은 v1.0부터 시작하며, 배포 시마다 버전이 0.1씩 올라갑니다. 모든 배포 내역은 배포 히스토리에 기록되며 배포 일시, 배포한 사람, 배포 영역, 배포 내용 및 실패 사유를 확인하실 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FHJXoSdzujPsuCFmLEJXW%2Fimage.png?alt=media&amp;token=0f90f594-5c08-4045-ab43-bdfd49136aa7" alt=""><figcaption><p>배포 메뉴</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FrCCQFfhpvoqvhTnel7Zf%2Fimage.png?alt=media&amp;token=99f0577b-ee96-4ded-8a8c-28773ab17077" alt=""><figcaption><p>배포 완료 후 배포 히스토리</p></figcaption></figure>

## 전체 배포 <a href="#all_deploy" id="all_deploy"></a>

전체 배포는 배포 시점까지 편집된 봇의 전체 데이터를 배포하는 기능입니다. 배포 형태에서 전체 배포 선택 후 배포 버튼을 통해 실행할 수 있으며 추가적인 기록이 필요할 경우 하단의 배포 내용에 작성할 수 있습니다.

배포 시 배포 상황을 확인할 수 있습니다. 배포 완료 전 남은 단계 확인이 가능하며, 오류 발생 시 어떤 단계에서 에러가 발생했는지 파악할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F1d5VOsUcTVHmuix9RH8o%2Fimage.png?alt=media&amp;token=9882a7d3-04c6-4a07-917c-074ff059659b" alt=""><figcaption><p>전체 배포</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FYSo3zC9lemENvFiEdVrO%2Fimage.png?alt=media&amp;token=1493ecb1-3914-4974-bf0d-97d5f23bec54" alt=""><figcaption><p>전체 배포 진행</p></figcaption></figure>

## 부분 배포 <a href="#partial_deploy" id="partial_deploy"></a>

부분 배포는 배포가 필요한 특정 항목을 선택적으로 배포하는 기능으로 초기 1회 전체 배포 이후 사용할 수 있습니다. 배포 형태의 부분 배포를 선택하면 배포 항목 선택 메뉴가 생성됩니다. 선택할 수 있는 배포 항목으로는 블록, 엔티티, 스킬 총 3가지로 구성되며 각 항목별 10개 내역에 대한 부분 배포가 가능합니다.

배포 항목을 1개 이상 선택하면 우측 하단에 선택 내역 확인 버튼이 생성됩니다. 버튼 위에 마우스 커서를 올리면 항목 별로 선택한 개수를 확인할 수 있습니다.

{% hint style="danger" %}
**Caution.**

배포 읽기 권한이 있을 시 시나리오/엔티티/스킬에 대한 모든 권한이 없더라도 세부 내용에 대한 확인이 가능합니다. 이에 대한 방지를 위해서는 관련된 관리자의 배포 권한(읽기, 쓰기)을 모두 회수해야 합니다.
{% endhint %}

{% hint style="info" %}
**Information.**&#x20;

삭제한 내용에 대한 부분 배포는 현재 지원하고 있지 않습니다. 블록/엔티티/스킬 삭제 내용에 대한 배포를 위해서는 전체 배포를 이용해 주세요.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FuFaae32MgjMDeYmuOhJn%2F%E1%84%87%E1%85%A2%E1%84%91%E1%85%A9_%E1%84%89%E1%85%A5%E1%86%AB%E1%84%90%E1%85%A2%E1%86%A8%20%E1%84%82%E1%85%A2%E1%84%8B%E1%85%A7%E1%86%A8%20%E1%84%92%E1%85%AA%E1%86%A8%E1%84%8B%E1%85%B5%E1%86%AB%20%E1%84%87%E1%85%A5%E1%84%90%E1%85%B3%E1%86%AB.png?alt=media&amp;token=6b9f6de2-c801-4bb6-ba94-dac17d529d96" alt=""><figcaption><p>선택 내역 확인 버튼</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fk9Ze7IRi7D5cbUjGmRy6%2F%E1%84%87%E1%85%A2%E1%84%91%E1%85%A9_%E1%84%89%E1%85%A5%E1%86%AB%E1%84%90%E1%85%A2%E1%86%A8%20%E1%84%82%E1%85%A2%E1%84%8B%E1%85%A7%E1%86%A8%20%E1%84%92%E1%85%AA%E1%86%A8%E1%84%8B%E1%85%B5%E1%86%AB%20%E1%84%87%E1%85%A5%E1%84%90%E1%85%B3%E1%86%AB%20%E1%84%89%E1%85%A1%E1%86%BC%E1%84%89%E1%85%A6.png?alt=media&amp;token=27f2020a-4478-42b9-bf24-cbf9806567dd" alt=""><figcaption><p>선택 내역 확인 버튼 상세</p></figcaption></figure>

선택 내역 확인 버튼 클릭 시 블록, 엔티티, 스킬 메뉴에서 선택된 상세 항목을 확인할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FpDBDyeVfOE9QNS6N97g3%2F%E1%84%87%E1%85%A2%E1%84%91%E1%85%A9_%E1%84%87%E1%85%AE%E1%84%87%E1%85%AE%E1%86%AB%20%E1%84%87%E1%85%A2%E1%84%91%E1%85%A9%20%E1%84%83%E1%85%A2%E1%84%89%E1%85%A1%E1%86%BC%20%E1%84%92%E1%85%A1%E1%86%BC%E1%84%86%E1%85%A9%E1%86%A8.png?alt=media&amp;token=8ddb5040-ee70-45ee-90da-ee741b3d9d0c" alt=""><figcaption><p>부분 배포 대상 항목</p></figcaption></figure>

배포 시 배포 상황을 확인할 수 있습니다. 배포 완료 전 남은 단계 확인이 가능하며, 오류 발생 시 어떤 단계에서 에러가 발생했는지 파악할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fef6yuFhtbLtSgDnikPFp%2F%E1%84%87%E1%85%A2%E1%84%91%E1%85%A9_%E1%84%87%E1%85%AE%E1%84%87%E1%85%AE%E1%86%AB%20%E1%84%87%E1%85%A2%E1%84%91%E1%85%A9%20%E1%84%8C%E1%85%B5%E1%86%AB%E1%84%92%E1%85%A2%E1%86%BC%20%E1%84%8C%E1%85%AE%E1%86%BC.png?alt=media&amp;token=42e1cf05-05f7-4b8f-a89b-23bc19a97c23" alt=""><figcaption><p>부분 배포 진행 중</p></figcaption></figure>

배포 히스토리에서 배포 내용 및 배포 오류가 발생한 버전 및 사유를 확인하실 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fif0oc8ieQWDIognysQ02%2F%E1%84%87%E1%85%A2%E1%84%91%E1%85%A9_%E1%84%87%E1%85%A2%E1%84%91%E1%85%A9%20%E1%84%8B%E1%85%AA%E1%86%AB%E1%84%85%E1%85%AD%20%E1%84%92%E1%85%AE%20%E1%84%87%E1%85%A2%E1%84%91%E1%85%A9%20%E1%84%92%E1%85%B5%E1%84%89%E1%85%B3%E1%84%90%E1%85%A9%E1%84%85%E1%85%B5.png?alt=media&amp;token=bdb340c4-2248-489b-a70b-c6e28939ccee" alt=""><figcaption><p>배포 완료 후 배포 히스토리</p></figcaption></figure>

### 블록 <a href="#partial_deploy_block" id="partial_deploy_block"></a>

시나리오 하위 블록 단위의 배포를 지원합니다. 배포 회차 당 10개 항목에 대해 선택하여 부분 배포가 가능하며 초과 시 선택이 불가합니다. 블록 배포의 경우 블록 내에서 참조하고 있는 엔티티, 스킬 등은 함께 배포되지 않기 때문에 필요시에는 연관된 항목을 추가로 선택하여 배포해야 하고 머신러닝 사용 여부가 반영됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F9PA3Ivw2XfHV6orzT5Lu%2F%E1%84%87%E1%85%B3%E1%86%AF%E1%84%85%E1%85%A9%E1%86%A8%20%E1%84%87%E1%85%A2%E1%84%91%E1%85%A9.png?alt=media&amp;token=a8b165da-db71-4cfb-9d23-09b3176d90c3" alt=""><figcaption><p>블록 배포</p></figcaption></figure>

{% hint style="info" %}
**Information.**

머신러닝이 적용되어 있는 블록을 부분 배포 할 경우 배포되어 있는 발화 유사도가 적용됩니다. 발화 유사도 변경을 위해서는 전체 배포 진행이 필요하며 부분 배포 진행으로 유사도를 변경할 수 없습니다.
{% endhint %}

{% hint style="info" %}
**Information.**&#x20;

블록 답변에 연결된 스킬 변경 시(A블록에 연결되어 있는 B스킬을 C스킬로 변경)에는 해당 블록에 대한 부분 배포로 변경 사항 적용이 가능합니다. 하지만 해당 스킬에 대한 스킬명, URL, 헤더값, Test URL, 테스트 헤더값과 같은 스킬 정보를 변경하고 반영하기 위해서는 스킬에 대한 부분배포가 필요합니다.
{% endhint %}

### 엔티티 <a href="#partial_deploy_entity" id="partial_deploy_entity"></a>

엔티티 단위의 배포를 지원합니다. 하위 항목인 엔트리, 동의어가 함께 배포되며 배포 회차 당 10개 항목에 대해 선택하여 부분 배포가 가능하며 초과 시 선택이 불가합니다.&#x20;

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Frxm1FZbeYl4gQbc3kcgd%2F%E1%84%8B%E1%85%A6%E1%86%AB%E1%84%90%E1%85%B5%E1%84%90%E1%85%B5%20%E1%84%87%E1%85%A2%E1%84%91%E1%85%A9.png?alt=media&amp;token=804c4417-cff7-44f4-9f7c-b41481a21e49" alt=""><figcaption><p>엔티티 배포</p></figcaption></figure>

### 스킬 <a href="#partial_deploy_skill" id="partial_deploy_skill"></a>

스킬의 배포를 지원합니다. 스킬 데이터가 배포되며 배포 회차 당 10개 항목에 대해 선택이 가능하고 초과 시 선택이 불가합니다. 변경된 스킬 답변을 확인하기 위해서는 해당 스킬과 연결된 블록을 함께 배포해야 합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FnHOQMDDQoGFKZLkn4hT7%2F%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B5%E1%86%AF%20%E1%84%87%E1%85%A2%E1%84%91%E1%85%A9.png?alt=media&amp;token=e5d86628-c076-46de-8762-2ef5e1641846" alt=""><figcaption><p>스킬 배포</p></figcaption></figure>

{% hint style="info" %}
**Information.**&#x20;

해당 스킬에 대한 스킬명, URL, 헤더값, Test URL, 테스트 헤더값 변경 시에는 스킬 탭에서 해당 스킬을 선택하여 배포해야 운영 중인 챗봇 데이터에 반영할 수 있습니다.
{% endhint %}

## 배포 실패 <a href="#deploy_fail" id="deploy_fail"></a>

배포는 여러 가지 원인에 의해 실패할 수 있습니다. 배포 불가시 아래 사항을 체크하여 주시기 바랍니다.

{% hint style="info" %}
**Information. 배포 불가시 확인사항**

1. 카카오톡 채널 관리자센터에서 운영 채널과 개발 채널이 모두 동일한 비즈앱에 연결되어 있는지
2. 챗봇 관리자센터의 '설정' 메뉴에서 운영 채널과 개발 채널이 모두 연결되어 있는지
   {% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FeQuuSGuZ9oCvThN3ZhHv%2F%E1%84%87%E1%85%A2%E1%84%91%E1%85%A9%20%E1%84%8C%E1%85%AE%E1%86%BC%20%E1%84%87%E1%85%A2%E1%84%91%E1%85%A9%E1%84%89%E1%85%B5%E1%86%AF%E1%84%91%E1%85%A2.png?alt=media&amp;token=06523bf6-43e1-4b36-84b9-3b992978cc5e" alt=""><figcaption><p>배포 중 배포가 불가한 경우</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FL5VFCGRsivYDVh2RRGsv%2F%E1%84%87%E1%85%A2%E1%84%91%E1%85%A9%20%E1%84%89%E1%85%B5%E1%86%AF%E1%84%91%E1%85%A2%20%E1%84%89%E1%85%A1%E1%84%8B%E1%85%B2%20%E1%84%92%E1%85%AA%E1%86%A8%E1%84%8B%E1%85%B5%E1%86%AB.png?alt=media&amp;token=1a3cb4f6-7522-4e60-9580-954e1395c6e2" alt=""><figcaption><p>배포 불가 사유 확인</p></figcaption></figure>

배포 히스토리에서 배포 내용 및 배포 오류가 발생한 버전 및 사유를 확인하실 수 있습니다.

{% hint style="info" %}
**Information.**

부분 배포 진행 시 ‘발화', ‘이벤트 네임', ‘엔티티', ‘엔트리', ‘동의어' 항목에 대하여 운영 데이터와 신규 배포 데이터 간의 중복이 발생할 수 있습니다. 중복 발생 시 배포가 실패되며 중복 항목을 수정한 후 재배포가 진행되어야 합니다.(44012: 코드 설명 및 하이라이팅)

데이터 중복으로 인한 배포 실패 시 중복된 내용은 1000개까지 노출되며 초과 시에는 고객센터를 통해 확인할 수 있습니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FCRGg29hIcpc0Zy4alZxF%2F%E1%84%8C%E1%85%AE%E1%86%BC%E1%84%87%E1%85%A9%E1%86%A8%E1%84%8B%E1%85%B3%E1%84%85%E1%85%A9%20%E1%84%8B%E1%85%B5%E1%86%AB%E1%84%92%E1%85%A1%E1%86%AB%20%E1%84%87%E1%85%A2%E1%84%91%E1%85%A9%20%E1%84%89%E1%85%B5%E1%86%AF%E1%84%91%E1%85%A2.png?alt=media&amp;token=932a9cdb-59df-4b49-9863-024469d7ed4f" alt=""><figcaption><p>신규 배포 데이터 및 운영 데이터의 중복으로 인한 배포 실패</p></figcaption></figure>


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/main_notions/deploy.md
