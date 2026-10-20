> For the complete documentation index, see [llms.txt](https://kakaobusiness.gitbook.io/main/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/make_skill.md).

# 스킬 만들기

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FnTbFuErQYwDfmq9RgEq7%2Fskill-intro.webp?alt=media&amp;token=6c8c1346-855e-4b31-80a5-36dfd3c96196" alt=""><figcaption></figcaption></figure>

챗봇 관리자센터에 ‘스킬’이 함께하면 마치 날개를 단 듯 봇의 서비스 역량이 배가됩니다.

개발자라면 사용자 응대 서비스에 알맞는 기능 단위 ‘스킬’을 만들어 API로 챗봇 관리자센터와 연동해보세요. 봇이 더욱 똑똑해지고, 그만큼 봇 사용자의 만족도도 올라갑니다.

그럼 먼저, 스킬을 만들기 위해 필요한 서버를 세팅하고 등록하는 방법부터 안내하겠습니다!

## 스킬 서버 이해하기 <a href="#understand_skill_server" id="understand_skill_server"></a>

### 스킬 서버란? <a href="#skill_server" id="skill_server"></a>

스킬 서버는 봇 시스템으로부터 스킬 요청을 받고 이에 담긴 정보를 분석하여 적절한 응답을 만듭니다. 각각의 요청은 HTTP POST를 통해서 전달되고, 요청과 응답 모두 JSON으로 구성된 body를 이용합니다.

이러한 구성은 HTTP API 서버를 만드는 것과 동일합니다. 단, 그 대상이 봇 시스템이라는 것을 유념해야 합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FXwUWa1ao43k7ceZDCTNw%2Fskill-server-intro.png?alt=media&amp;token=363f9730-32de-449c-b2fe-27bde94182c8" alt=""><figcaption><p>봇 시스템 요청과 스킬 서버 응답</p></figcaption></figure>

### 스킬 payload(봇 시스템 ->스킬 서버) <a href="#skill_payload" id="skill_payload"></a>

스킬 payload는 봇 시스템이 스킬 서버에 전달하는 요청입니다. 유저, 발화, 블록, 엔티티, 플러그인에 해당하는 정보를 포함합니다.

[<mark style="color:blue;">**스킬 개발 가이드 > 스킬 payload**</mark>](/main/tool/chatbot/skill_guide/answer_json_format.md#skillpayload)

플러그인을 사용하면 위치, 날짜 및 시간, 프로필과 같은 추가적인 정보를 payload에 포함할 수 있습니다.

[<mark style="color:blue;">**스킬 개발 가이드 > 플러그인에 스킬 적용하기**</mark>](/main/tool/chatbot/skill_guide/apply_skill_to_plugin.md)

### 스킬 response(스킬 서버 -> 봇 시스템) <a href="#skill_response" id="skill_response"></a>

스킬 response는 스킬 서버가 봇 시스템에게 전달하는 응답입니다. 스킬 template이나 data에 해당하는 정보를 포함합니다.

[<mark style="color:blue;">**스킬 개발 가이드 > 응답 타입별 JSON 포맷**</mark>](/main/tool/chatbot/skill_guide/answer_json_format.md)

## 예제 스킬 서버 만들기 <a href="#make_example_skill_server" id="make_example_skill_server"></a>

### 스킬 서버 세팅 <a href="#setting_skill_server" id="setting_skill_server"></a>

봇 시스템에 응답하는 간단한 http api 서버를 세팅합니다. 개발 환경은 아래와 같습니다.

* 언어: nodejs(<https://nodejs.org/en/>)
* 웹 프레임워크: expressjs(<http://expressjs.com/>)
* 실행 환경: ubuntu 16.04

스킬 서버에서는 두 개의 엔드포인트를 제공할 예정입니다.

* /api/sayHello

  ‘안녕’ 이라는 텍스트를 보여주는 간단한 텍스트형 응답을 돌려줍니다.
* /api/showHello

  라이언이 손을 흔드는 이미지를 보여주는 간단한 이미지형 응답을 돌려줍니다.

#### nvm 설치하기

{% hint style="info" %}
**Information.**

<https://github.com/creationix/nvm#installation>\
\[윈도우] <https://github.com/coreybutler/nvm-windows>
{% endhint %}

#### nodejs 설치하기

nvm의 설치가 끝났다면 이제 nodejs의 설치가 가능합니다. 안전한 개발을 위해서 lts(long term support) 버전을 설치하도록 하겠습니다.

```
$ nvm install --lts
Installing latest LTS version.
Downloading and installing node v18.15.0...
Downloading https://nodejs.org/dist/v18.15.0/node-v18.15.0-darwin-x64.tar.xz...
######################################################################### 100.0%
Computing checksum with shasum -a 256
Checksums matched!
Now using node v18.15.0 (npm v9.5.0)
```

node의 버전을 확인하면, nvm을 통해서 받은 버전으로 설치된 것을 확인할 수 있습니다.

```
$ node -v
v18.15.0
```

#### 프로젝트 구성 <a href="#project_configuration" id="project_configuration"></a>

nodejs에서는 npm(node package manager)을 통해서 패키지 관리가 가능합니다. npm을 사용하면 프로젝트 기본 정보를 담고 있는 package.json을 생성하고, 손쉽게 외부 라이브러리를 설치할 수 있습니다.

우선, 프로젝트 폴더를 생성합니다.

```
$ mkdir skill-server-example
$ cd skill-server-example
```

npm init을 이용하여 프로젝트를 초기화합니다.

```
$ npm init
This utility will walk you through creating a package.json file.
It only covers the most common items, and tries to guess sensible defaults.

See `npm help init` for definitive documentation on these fields
and exactly what they do.

Use `npm install <pkg>` afterwards to install a package and
save it as a dependency in the package.json file.

Press ^C at any time to quit.
package name: (skill-server-example)
version: (1.0.0) 0.0.1
description: skill server example
entry point: (index.js)
test command:
git repository:
keywords:
author:
license: (ISC) MIT
About to write to ~/packages/skill-server-example/package.json:

{
  "name": "skill-server-example",
  "version": "0.0.1",
  "description": "skill server example",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "MIT"
}


Is this OK? (yes)
```

스크립트를 수행한 후에 프로젝트의 최상단 경로에 package.json이 생성된 것을 확인할 수 있습니다.

#### expressjs 설치하기

{% hint style="warning" %}
**Definition.**

**expressjs란?**

express(<https://expressjs.com/ko/>)는 nodejs에서 제일 많이 사용되는 웹 프레임워크입니다. 간단한 코드로 높은 성능을 내고 다양한 기능을 가진 웹 서버를 생성할 수 있습니다.
{% endhint %}

프로젝트 구성이 끝났기 때문에 npm을 통해서 간단히 express를 설치할 수 있습니다.

```
$ npm i --save express
npm notice created a lockfile as package-lock.json. You should commit this file.

+ express@4.18.2
added 57 packages, and audited 58 packages in 1s
```

위의 명령어를 수행하고 package.json을 확인하면 dependencies에 express가 추가된 것을 확인할 수 있습니다.

```
$ cat package.json
{
  "name": "skill-server-example",
  "version": "0.0.1",
  "description": "skill server example",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

{% hint style="info" %}
**Information.** **추가 라이브러리**

morgan, body-parser 라이브러리를 추가합니다. morgan은 로깅을 담당하고 body-parser는 http 요청의 body를 추출합니다.
{% endhint %}

```
$ npm i --save morgan body-parser

+ morgan@1.10.0
+ body-parser@1.20.2
added 7 packages, changed 2 packages, and audited 65 packages in 666ms
found 0 vulnerabilities
```

#### 로직 추가하기 <a href="#adding_logic" id="adding_logic"></a>

코드를 추가할 차례입니다. index.js를 만들고 기본적인 express 설정을 추가합니다.

```
$ touch index.js
$ vi index.js
```

```
const express = require('express');
const app = express();
const logger = require('morgan');
const bodyParser = require('body-parser');

const apiRouter = express.Router();

app.use(logger('dev', {}));
app.use(bodyParser.json());
app.use('/api', apiRouter);
```

**Tip.**

express 4.16 버전 이후에는 body-parser 없이 실행 가능합니다. 아래의 예시를 참고해 주세요.

```
const express = require('express');
const app = express();
const logger = require('morgan');

const apiRouter = express.Router();

app.use(logger('dev', {}));
app.use(express.json());
app.use('/api', apiRouter);
```

express를 사용하여, app을 생성합니다. app은 스킬 응답을 받을 api 서버 인스턴스입니다. app의 use 메소드를 이용하여 morgan과 body-parser를 등록합니다. api를 담당하는 apiRouter를 생성하고, 이를 app의 ‘/api’ 경로에 붙입니다. 이 코드의 결과로, ‘/api/\*\*’로 시작하는 모든 요청은 apiRouter에게 전달됩니다.

api 서버에 두 개의 엔드포인트를 추가합니다. ‘/api/sayHello’, ‘/api/showHello’ 라우팅을 담당할 미들웨어 함수를 생성합니다.

```
apiRouter.post('/sayHello', function(req, res) {
  const responseBody = {
    version: "2.0",
    template: {
      outputs: [
        {
          simpleText: {
            text: "hello I'm Ryan"
          }
        }
      ]
    }
  };

  res.status(200).send(responseBody);
});

apiRouter.post('/showHello', function(req, res) {
  console.log(req.body);

  const responseBody = {
    version: "2.0",
    template: {
      outputs: [
        {
          simpleImage: {
            imageUrl: "https://t1.daumcdn.net/friends/prod/category/M001_friends_ryan2.jpg",
            altText: "hello I'm Ryan"
          }
        }
      ]
    }
  };

  res.status(200).send(responseBody);
});
```

apiRouter는 이미 ‘api’ 라는 경로를 가지고 있기 때문에, 추가적으로 api 경로를 붙이지 않습니다. POST 응답을 처리해야 하기 때문에, apiRouter의 POST 메소드를 이용합니다. 두 미들웨어 함수는 반환하는 body를 제외하고 비슷한 모습을 가지고 있습니다. 하지만 ‘/api/showHello’의 경우, 봇 시스템의 요청 body를 확인하기 위해서 그 body를 로그로 찍는 로직을 추가하였습니다. 응답 타입별 json 포맷은 응답 타입별 json 포맷 링크에서 확인할 수 있습니다.

마지막으로 설정한 express app을 특정 포트로 실행하는 부분입니다.

```
app.listen(3000, function() {
  console.log('Example skill server listening on port 3000!');
});
```

app은 3000번 포트로 뜨게 되고, ‘Example skill server listening on port 3000!’를 출력합니다.

전체 코드는 아래와 같습니다.

```
const express = require('express');
const app = express();
const logger = require('morgan');
const bodyParser = require('body-parser');

const apiRouter = express.Router();

app.use(logger('dev', {}));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
  extended: true
}));

app.use('/api', apiRouter);

apiRouter.post('/sayHello', function(req, res) {
  const responseBody = {
    version: "2.0",
    template: {
      outputs: [
        {
          simpleText: {
            text: "hello I'm Ryan"
          }
        }
      ]
    }
  };

  res.status(200).send(responseBody);
});

apiRouter.post('/showHello', function(req, res) {
  console.log(req.body);

  const responseBody = {
    version: "2.0",
    template: {
      outputs: [
        {
          simpleImage: {
            imageUrl: "https://t1.daumcdn.net/friends/prod/category/M001_friends_ryan2.jpg",
            altText: "hello I'm Ryan"
          }
        }
      ]
    }
  };

  res.status(200).send(responseBody);
});

app.listen(3000, function() {
  console.log('Example skill server listening on port 3000!');
});
```

### 스킬 서버 실행 <a href="#excute_skill_server" id="excute_skill_server"></a>

이렇게 생성한 스킬 서버는 node cli를 통해서 실행 가능합니다.

```
$ node index.js
Example skill server listening on port 3000!
```

curl cli를 통해서 3000번 포트에 실행된 서버가 제대로 작동하는지 확인합니다.

```
$ curl http://localhost:3000/api/sayHello \
-X POST \
-H "Content-type: application/json" \
-d '{"key1": "value1", "key2": "value2"}'

// result
{"version":"2.0","template":{"outputs":[{"simpleText":{"text":"hello I'm Ryan"}}]}
```

실제 서비스에서는 curl을 통해서 보내던 요청을 봇 시스템이 수행하게 됩니다. 그리고 실행 결과를 토대로 출력 모양을 결정합니다.

지금까지의 과정을 쭉 따라오면, 간단한 요청을 처리하는 스킬 서버가 생기게 됩니다. 하지만 아직 여러 작업들이 많이 남아있습니다. 스킬/블록 등록을 하지 않았고, 단순한 텍스트, 이미지 응답만 돌려주고 있습니다. 다음 페이지에서는 스킬을 어떻게 챗봇 관리자센터에 등록하는지 알아보겠습니다.

## 스킬 서버 등록하기 <a href="#resist_skill_server" id="resist_skill_server"></a>

챗봇 관리자센터는 봇 작업자가 여러 스킬을 등록하고 테스트할 수 있도록 다양한 툴을 제공합니다. 스킬 관리에서는 스킬을 조회하고 삭제, 추가, 테스트, 수정할 수 있습니다.

### 스킬 조회 <a href="#check_skill" id="check_skill"></a>

챗봇 관리자센터 스킬 메뉴에서 해당 봇의 모든 스킬을 확인할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2F2mPiyzUcYm60SYyQH3EB%2Fskill-list.png?alt=media&amp;token=ed793a50-b719-414b-9f6b-185e253c857b" alt=""><figcaption><p>스킬의 상세 정보가 제공되는 스킬 목록</p></figcaption></figure>

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FScj86oSjE6Wc33ZNBXXt%2Fskill-empty-list.png?alt=media&amp;token=c227d879-32e2-454f-85ea-ffcadc7e4313" alt=""><figcaption><p>스킬이 하나도 없는 경우 등장하는 문구</p></figcaption></figure>

### 스킬 삭제 <a href="#delete_skill" id="delete_skill"></a>

스킬 정보 줄 우측에 있는 버리기 아이콘을 클릭하면 **스킬 삭제 창**이 뜹니다. 삭제 버튼을 클릭시 완료 메세지와 함께 완전히 제거됩니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FOPPkOxu4ePScFKQwUvMv%2Fskill-delete-confirm.png?alt=media&amp;token=c772bb8e-9474-4149-8287-e532401077fb" alt=""><figcaption><p>스킬 삭제 확인 창</p></figcaption></figure>

{% hint style="danger" %}
**Caution.**

스킬 삭제시 적용된 블록에서 자동으로 제거되므로 주의해야 합니다.
{% endhint %}

### 스킬 추가 <a href="#add_skill" id="add_skill"></a>

스킬 페이지의 생성 버튼 클릭시 스킬 생성 페이지로 이동합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FZHDfX7wL0EShn6mLaDFX%2Fskill-add-button.webp?alt=media&amp;token=51ddda81-6f1f-4957-b9ce-92dfdc013d35" alt=""><figcaption><p>생성 버튼</p></figcaption></figure>

스킬 생성 페이지는 아래 화면과 같은 필드들을 갖습니다. 빨간 참조 별표(\*)를 가지고 있는 필드는 필수 값이기 때문에 해당 값을 입력하지 않는 경우, 저장되지 않습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FXZDfFTOJQ9sMp714B2Rg%2Fskill-detail.png?alt=media&amp;token=ed08033b-7459-4340-8019-177dd6eb829b" alt=""><figcaption><p>스킬 생성 모습</p></figcaption></figure>

#### 상세 필드 <a href="#detail_field" id="detail_field"></a>

<table><thead><tr><th width="183">이름</th><th width="110.33333333333331">필수 여부</th><th>설명</th></tr></thead><tbody><tr><td>스킬명</td><td>O</td><td>스킬 이름</td></tr><tr><td>설명</td><td>X</td><td>스킬에 대한 상세 설명</td></tr><tr><td>URL</td><td>O</td><td><p>스킬을 실행할 테스트 엔드포인트</p><p>배포가 완료되지 않은 봇은 Test URL을 이용하여 스킬 실행</p></td></tr><tr><td>Test URL</td><td>X</td><td><p>스킬을 실행할 테스트 엔드포인트</p><p>배포가 완료되지 않은 봇은 Test URL을 이용하여 스킬 실행</p></td></tr><tr><td>헤더값 입력</td><td>X</td><td>하단에서 추가 설명</td></tr><tr><td>테스트 헤더값 입력</td><td>X</td><td>하단에서 추가 설명</td></tr><tr><td>스킬 테스트</td><td>X</td><td>하단에서 추가 설명</td></tr></tbody></table>

#### 헤더값 입력, 테스트 헤더값 입력 <a href="#input_header_and_test_header" id="input_header_and_test_header"></a>

http 서버는 헤더를 필요로 하는 경우가 있습니다. aws의 lambda 서비스를 그 대표적인 예로 볼 수 있습니다. aws의 lambda를 실행할때, http 헤더에 `x-api-key`를 확인하여, 이 값이 등록된 key랑 동일한지 확인합니다. 같지 않다면, 403 http 응답이 돌아오면서 액션을 수행하지 않습니다.

이러한 상황이라면, 헤더값 입력, 테스트 헤더값 입력을 통해서 헤더 인증 문제를 해결할 수 있습니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FLi3Cj6tCJ6yKCpNjFCCc%2Fskill-headers.png?alt=media&amp;token=002072dd-19b9-46ec-b484-1149df6bd679" alt=""><figcaption><p>헤더값 입력 예시</p></figcaption></figure>

### 스킬 테스트 <a href="#test_skill" id="test_skill"></a>

스킬 요청이 스킬 서버로 정상적으로 전송 되는지, 스킬 서버가 제대로 응답을 하는지 확인을 하고 싶은 경우가 있습니다. 그리고 스킬 요청에 어떤 정보가 있는지 미리 보고 싶은 때도 있습니다. 스킬 페이지의 스킬 테스트 기능을 이용하여 이를 쉽게 수행할 수 있습니다. 제일 먼저 스킬 파라미터를 입력합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fi5RtQsmWghwQBcYC1DcG%2Fskill-test.png?alt=media&amp;token=06b19e8f-ed7a-4e8b-ad28-7f714689dde8" alt=""><figcaption><p>파라미터를 입력한 후 스킬 테스트 JSON</p></figcaption></figure>

왼쪽의 파라미터 표에 새로운 값을 추가하면 오른쪽 JSON 값에 자동으로 반영됩니다.

{% hint style="info" %}
**Information.** **파라미터를 입력하는 이유?**

수동으로 파라미터를 입력하는 이유는 어느 블록에서 스킬을 사용할지, 그리고 어느 발화가 들어올지 알 수 없기 때문입니다. 따라서 스킬 서버 개발자는 파라미터를 예상하여 값을 입력하고, 이를 토대로 테스트를 수행해야 합니다.
{% endhint %}

파라미터를 입력하여 만들어진 JSON을 직접 서버에 입력하고 싶은 케이스가 있습니다. **클립보드로 복사** 버튼을 누르면 현재 JSON 창에 있는 값이 클립보드에 복사됩니다. 이를 활용하여 더 수월하게 테스트를 진행할 수 있습니다.

파라미터를 입력하여 만들어진 JSON을 서버로 전송할 일만 남았습니다. **스킬 서버로 전송** 버튼을 누르면 스킬 요청 전송이 시작됩니다. 스킬 테스트는 입력된 URL 필드를 확인하여 해당 URL을 엔드포인트로, 그리고 JSON값을 body로 하여 post 요청을 전송합니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fhgf5Eg32tvJXkaqlMK6U%2Fskill-test-send-server.png?alt=media&amp;token=e7299adb-f438-4e24-9a0d-04fe3f9032e6" alt=""><figcaption><p><strong>스킬서버로 전송</strong> 버튼 클릭 후 성공 로그</p></figcaption></figure>

스킬 서버에서 제대로 된 JSON 응답을 돌려주면, 이를 **응답 미리보기** 부분에서 보여주고, **응답 결과 로그** 부분에 상세 결과를 남깁니다.

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FFKhR5qdgC9w95rW9K3Eu%2Fskill-test-result.png?alt=media&amp;token=2393a7d5-13e0-4fde-9811-0ccc7c9e4ba6" alt=""><figcaption><p><strong>스킬서버로 전송</strong> 버튼 클릭후 실패 로그</p></figcaption></figure>

문제가 발생하면, **응답 결과 로그**에서 원인을 확인할 수 있습니다.

스킬을 정상적으로 연결했음에도 아래 사유로 인해 봇이 동작하지 않을 수 있어 아래 내용을 체크하여 주시기 바랍니다.

* 봇 작업자의 스킬 서버가 로컬(local) 환경인 경우
* 스킬 기능은 동작했으나 출력할 값이 없는 경우
* JSON 포맷 구성이 올바르지 않은 경우
* 사용자의 서버에 이슈가 있는 경우 등
* 스킬 응답 속도 제한에 해당하는 경우

**스킬은 공인IP 또는 공중망 도메인만 사용 가능합니다.**\
또한 스킬 타임아웃 시간은 고정이므로, 별도로 조정이 어려우며 만약 타임아웃이 계속 될 경우 스킬과 연동한 서버에서 5초 안에 응답을 줄 수 있도록 추가 개발을 하여 주시기 바랍니다.

### 스킬 수정 <a href="#modify_skill" id="modify_skill"></a>

스킬 목록에서 스킬 정보 줄을 클릭하면 상세 스킬 페이지로 이동합니다. 스킬 생성과 유사하지만 스킬 수정은 이미 스킬 정보가 존재하기 때문에 값이 채워진 상태에서 작업하게 됩니다. 스킬 생성과 다르게 스킬 수정은 새 버전으로 저장이 가능하기도 합니다.

{% hint style="danger" %}
**Caution.**

'새 버전으로 저장' 버튼이 활성화되려면, 스킬의 값이 변경되어야 합니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2FCoEY7bkkMHVnEXA0CNdK%2Fskill-modify-name.png?alt=media&amp;token=cbbf2d41-812a-4af8-afa7-c12248bfe23b" alt=""><figcaption><p>스킬 이름 변경 팝업창</p></figcaption></figure>

{% hint style="info" %}
**Information.**

**새 버전으로 저장** 버튼 클릭시, 기존의 스킬은 수정하지 않고 올라간 버전을 가진 스킬이 생성됩니다. 이를 통해서 손쉽게 스킬의 버전 관리를 할 수 있습니다.
{% endhint %}

<figure><img src="https://234308570-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-MVZVmVOd-5LtENUPqdq%2Fuploads%2Fge3oA601FN44QO8Qg3yz%2Fskill-various-version.png?alt=media&amp;token=c9501b84-b520-4b9f-9a84-b95e2758c126" alt=""><figcaption><p>다른 버전을 가진 스킬이 존재</p></figcaption></figure>


---


---

> 출처: https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/make_skill.md
