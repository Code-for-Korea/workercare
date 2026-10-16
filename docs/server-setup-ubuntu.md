# Ubuntu 서버 기본 설치 가이드

Kamal로 workercare를 배포할 Ubuntu 서버를 처음 준비하는 절차입니다. Kamal은 SSH로 서버에 접속해 Docker를 제어하므로, 서버에는 **SSH 접속 가능한 배포용 사용자**와 **Docker**만 있으면 됩니다.

- 대상 OS: Ubuntu 26.04 LTS (x64)
- 배포 설정: `config/deploy.yml`, `.kamal/secrets`
- 아래 명령의 `<서버IP>`, `<공개키>` 등 꺾쇠 값은 환경에 맞게 바꿉니다.

## 1. 서버 생성 체크리스트

클라우드 콘솔에서 서버를 만들 때 다음을 확인합니다.

1. 이미지: Ubuntu 26.04 LTS x64
2. 사양: 상황에 맞는 vCPU와 메모리 (메모리가 작으면 6. 스왑 설정을 합니다)
3. 자동 백업: 필요 여부를 정합니다
4. SSH 키: 관리자 공개키를 등록합니다
5. 호스트명: `web01.workercare`처럼 `서버구분 + 숫자 두 자리 + 프로젝트`로 정합니다 (`config/deploy.yml`의 `servers`와 맞춥니다)
6. 방화벽(보안 그룹): 인바운드 22(SSH), 80(HTTP), 443(HTTPS)만 엽니다. 22는 가능하면 관리자 IP로 제한합니다

## 2. 최초 접속과 업그레이드

생성 직후에는 root(또는 클라우드 기본 사용자)로 접속합니다.

```shell
ssh root@<서버IP> -i ~/.ssh/<관리자키>.pem
```

패키지를 업그레이드하고 재부팅합니다.

```shell
apt update
apt upgrade -y
reboot
```

재부팅 후 다시 접속합니다.

## 3. 배포용 ubuntu 사용자 추가

Kamal이 사용할 `ubuntu` 사용자를 만듭니다. 이미 `ubuntu` 사용자가 있는 이미지라면 사용자 생성은 건너뛰고 `.ssh` 설정부터 확인합니다.

```shell
# 사용자 생성 (비밀번호 없이)
adduser --disabled-password --gecos "" ubuntu

# SSH 디렉터리와 공개키 등록
install -d -m 700 -o ubuntu -g ubuntu /home/ubuntu/.ssh
echo '<공개키 한 줄: ssh-ed25519 AAAA... 주석>' >> /home/ubuntu/.ssh/authorized_keys
chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys
chmod 600 /home/ubuntu/.ssh/authorized_keys

# 비밀번호 로그인 차단 (잠금)
usermod -p '*' ubuntu
```

sudo 권한을 `/etc/sudoers.d/`에 별도 파일로 부여합니다. `sudo` 그룹에는 넣지 않고, 문법 오류로 sudo가 깨지지 않도록 반드시 `visudo -c`로 검증합니다.

```shell
echo 'ubuntu ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/90-ubuntu
chmod 0440 /etc/sudoers.d/90-ubuntu
visudo -c
```

> 새 터미널에서 `ssh ubuntu@<서버IP>` 접속과 `sudo -n true`가 되는지 확인한 뒤 다음 단계로 진행합니다. 이 확인 전에 root 접속을 끊거나 7. 보안 설정을 적용하지 않습니다.

## 4. 기본 패키지와 Docker 설치

이후는 `ubuntu` 사용자로 접속해서 실행합니다.

```shell
sudo apt update
sudo apt install -y docker.io curl git jq
```

Docker를 부팅 시 자동 시작하고, `ubuntu` 사용자가 `sudo` 없이 Docker를 쓰도록 `docker` 그룹에 추가합니다.

```shell
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu
```

그룹 변경은 **재접속해야 적용**됩니다. 로그아웃 후 다시 접속해서 확인합니다.

```shell
docker --version
docker ps
```

`docker ps`가 권한 오류 없이 빈 목록을 보여주면 정상입니다.

> `docker.io`는 Ubuntu 저장소 패키지입니다. 최신 Docker Engine이 필요하면 [Docker 공식 문서](https://docs.docker.com/engine/install/ubuntu/)의 apt 저장소 설치 방법을 사용합니다. 26.04 LTS 지원 여부와 패키지 이름은 설치 전에 공식 문서에서 확인합니다.

## 5. 데이터 디렉터리

`config/deploy.yml`의 `volumes`에서 컨테이너에 마운트하는 호스트 경로를 미리 만들어 둡니다.

```shell
sudo mkdir -p /data/workercare/storage
sudo chown -R 1000:1000 /data/workercare/storage
```

컨테이너는 `Dockerfile`의 `USER 1000:1000`(`rails`)으로 실행되므로 소유자는 이름이 아니라 **숫자 UID/GID 1000**으로 맞춥니다. 서버의 `ubuntu` 사용자 UID가 1000이 아닐 수 있고(클라우드 이미지에 `ubuntu`가 이미 있으면 새로 만든 사용자는 1001), 디렉터리를 만들지 않고 배포하면 Docker가 root 소유로 만듭니다. 둘 다 아래 오류의 원인입니다.

```
SQLite3::ReadOnlyException: attempt to write a readonly database
```

SQLite는 DB 파일뿐 아니라 WAL/SHM 파일을 만들기 위해 디렉터리에도 쓰기 권한이 필요합니다. 확인과 복구는 다음과 같습니다.

```shell
ls -lan /data/workercare/storage
sudo chown -R 1000:1000 /data/workercare/storage
bin/kamal app boot
```

## 6. 스왑 메모리 설정 (메모리가 부족할 때)

메모리가 작은 서버는 실제 메모리의 1/2 ~ 2배 정도로 스왑 파일을 만듭니다. 아래는 8GB 예시입니다.

```shell
swapon --show          # 이미 스왑이 있는지 확인
free -h                # 메모리 사용량
df -h                  # 디스크 남은 용량

sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 재부팅 후에도 유지
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

swapon --show
free -h
```

## 7. 보안 기본 설정

### 7.1 SSH 설정

`ubuntu` 접속이 확인된 뒤에만 적용합니다. root 로그인과 비밀번호 로그인을 막습니다.

```shell
sudo tee /etc/ssh/sshd_config.d/50-hardening.conf > /dev/null <<'EOF'
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AllowUsers ubuntu
EOF

sudo sshd -t && sudo systemctl restart ssh
```

> 설정 적용 후 **기존 세션을 닫지 말고** 새 터미널에서 `ssh ubuntu@<서버IP>`가 되는지 확인합니다. 실패하면 기존 세션에서 파일을 지워 복구합니다.
> 클라우드 이미지가 `/etc/ssh/sshd_config.d/50-cloud-init.conf`에 `PasswordAuthentication yes`를 넣어둔 경우 파일 이름 순서에 따라 먼저 읽힌 값이 우선합니다. `sudo sshd -T | grep -iE 'passwordauth|permitroot'`로 최종 값을 확인합니다.

### 7.2 방화벽 (UFW)

클라우드 방화벽을 쓰고 있다면 서버 방화벽은 생략할 수 있습니다. 서버에서도 막으려면 **SSH를 먼저 허용한 뒤** 활성화합니다.

```shell
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
sudo ufw status
```

> Docker는 게시한 포트를 UFW 규칙보다 먼저 iptables에 등록하므로, UFW만으로 컨테이너 포트 노출이 막히지 않습니다. 외부 노출 제어는 클라우드 방화벽(1번 체크리스트)을 기준으로 합니다.

### 7.3 IPv6 비활성화 (선택)

IPv6를 쓰지 않는 환경에서만 적용합니다.

```shell
sudo tee /etc/sysctl.d/99-disable-ipv6.conf > /dev/null <<'EOF'
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
sudo sysctl -p /etc/sysctl.d/99-disable-ipv6.conf
```

## 8. Kamal 연동

### 8.1 deploy.yml 설정

`config/deploy.yml`의 SSH 사용자를 `ubuntu`로 맞춥니다. 현재 파일은 `rocky`(Rocky Linux)로 되어 있습니다.

```yaml
ssh:
  user: ubuntu
```

`servers`의 호스트는 로컬 PC가 접속할 수 있는 이름이어야 합니다. DNS에 등록하지 않았다면 로컬 `~/.ssh/config`에 추가합니다.

```
Host web01.workercare
  HostName <서버IP>
  User ubuntu
  IdentityFile ~/.ssh/<관리자키>.pem
  IdentitiesOnly yes
```

> `IdentitiesOnly yes`가 없으면 SSH 에이전트의 키를 모두 시도하다가 `Too many authentication failures`로 끊깁니다. `deploy.yml`에서 `ssh.keys`와 `ssh.keys_only: true`로 지정해도 됩니다.

### 8.2 로컬에서 접속 확인

```shell
ssh web01.workercare docker ps
```

### 8.3 최초 설치와 배포

레지스트리 계정과 `RAILS_MASTER_KEY`는 `.kamal/secrets`에서 읽습니다. 값이 준비되었는지 확인한 뒤 실행합니다.

```shell
# 최초 1회: Docker 확인, 프록시(kamal-proxy) 설치, 앱 배포
bin/kamal setup

# 이후 배포
bin/kamal deploy
```

## 9. 초기 데이터 로드

서버에 SQLite 파일이 없으면 `bin/kamal setup` 때 컨테이너가 `db:prepare`로 **빈 DB**를 만듭니다. 판정서 데이터는 아래 두 방법 중 하나로 채웁니다. 어느 쪽이든 서버의 `/data/workercare/storage`가 컨테이너의 `/rails/storage`에 마운트되어 있다는 점을 이용합니다.

### 9.0 업로드 권한 (공통)

컨테이너 앱 사용자는 UID 1000인데, 서버의 `ubuntu` 사용자는 UID가 1001일 수 있습니다(`id ubuntu`로 확인). 이 경우 `ubuntu`는 소유자가 1000인 `/data/workercare/storage`에 직접 쓸 수 없습니다. 아래 `rsync`는 서버 쪽을 `sudo rsync`로 실행하고(`--rsync-path="sudo rsync"`) 올라온 파일의 소유자를 `1000:1000`으로 맞춥니다(`--chown=1000:1000`). 호스트에서 `storage` 안의 파일을 직접 지우거나 고칠 때도 `sudo`가 필요합니다.

### 9.1 방법 A: CSV 임포트 (권장)

rake task가 upsert하므로 재실행해도 중복되지 않고, 개발 DB에 섞인 테스트 데이터가 올라가지 않습니다. 순서가 중요합니다. 3번은 1·2번이 끝나야 합니다.

1. `import:ksco_codes`: KSCO 코드 (`wip/ksco-level-4-details.csv`)
2. `import:disease_cases`: 판정서 (`comwel_disease_cases.csv`, `comwel_list.csv`)
3. `import:extracted_disease_cases`: LLM 추출 데이터 (`wip/extract_disease_cases_details_cerebras-ksco.csv`)

CSV는 이미지에 들어 있지 않으므로 서버의 데이터 디렉터리에 올립니다.

```shell
# 로컬 (프로젝트 루트)
ssh web01.workercare 'sudo mkdir -p /data/workercare/storage/import && sudo chown 1000:1000 /data/workercare/storage/import'
rsync -avz --progress --rsync-path="sudo rsync" --chown=1000:1000 \
  comwel_disease_cases.csv comwel_list.csv \
  wip/ksco-level-4-details.csv \
  wip/extract_disease_cases_details_cerebras-ksco.csv \
  web01.workercare:/data/workercare/storage/import/
```

앱 컨테이너에서 rake task를 실행합니다. 컨테이너 안에서 경로는 `storage/import/...`입니다.

```shell
bin/kamal app exec -r web --reuse \
  "bin/rails 'import:ksco_codes[storage/import/ksco-level-4-details.csv]'"

bin/kamal app exec -r web --reuse \
  "bin/rails 'import:disease_cases[storage/import/comwel_disease_cases.csv,storage/import/comwel_list.csv]'"

bin/kamal app exec -r web --reuse \
  "bin/rails 'import:extracted_disease_cases[storage/import/extract_disease_cases_details_cerebras-ksco.csv]'"
```

- 2번과 3번은 끝날 때 FTS 인덱스를 자동으로 rebuild합니다. 따로 `fts:rebuild`를 실행할 필요는 없습니다.
- 데이터 양이 많으면 시간이 오래 걸립니다. SSH 연결이 끊길 수 있으니 서버에서 `tmux`나 `nohup`으로 `docker exec`를 실행하는 편이 안전합니다.
- 임포트가 끝나면 CSV는 지워도 됩니다. 개인정보가 있다면 `sudo rm -r /data/workercare/storage/import`로 정리합니다.

### 9.2 방법 B: 로컬 DB 파일 복사

로컬 `storage/development.sqlite3`(약 1.3GB)를 운영 `production.sqlite3`로 올립니다. 이미 임포트와 FTS 인덱스가 끝난 상태라 가장 빠르지만, 개발 중에 쌓인 데이터까지 그대로 올라갑니다.

운영 DB는 `production`, `production_cache`, `production_queue` 세 개입니다. 개발 DB에는 기본(primary) 테이블만 있으므로 **`production.sqlite3` 하나만** 올립니다. cache와 queue DB는 컨테이너가 시작할 때 `db:prepare`로 만듭니다.

```shell
# 1) 로컬: WAL 파일까지 반영된 일관된 복사본을 만듭니다 (원본 이름은 바꾸지 않습니다)
sqlite3 storage/development.sqlite3 ".backup /tmp/production.sqlite3"

# 2) 로컬: 서버로 업로드 (중단되면 같은 명령을 다시 실행하면 이어서 올라갑니다)
rsync -avz --partial --progress --rsync-path="sudo rsync" --chown=1000:1000 /tmp/production.sqlite3 \
  web01.workercare:/data/workercare/storage/production.sqlite3

# 3) 서버: 소유자를 확인합니다 (2번의 --chown으로 이미 1000:1000이어야 합니다)
ssh web01.workercare 'ls -ln /data/workercare/storage/production.sqlite3'

# 4) 컨테이너 재시작 (db:prepare가 cache/queue DB를 만들고 남은 마이그레이션을 적용합니다)
bin/kamal app boot
```

올리기 전에 확인합니다.

- 개발 DB의 `action_mcp_sessions`, `solid_mcp_messages` 같은 세션·메시지 테이블에 개발용 데이터가 있으면 올라갑니다. 필요하면 `/tmp/production.sqlite3`에서 `DELETE FROM ...`으로 비운 뒤 `VACUUM`합니다.
- 개발 DB의 마지막 마이그레이션(`schema_migrations`)이 코드의 마지막 마이그레이션과 같거나 이전이어야 합니다. 더 새로우면 앱이 시작되지 않습니다.
- 서버에 이미 `production.sqlite3`가 있으면 덮어씁니다. 데이터가 있는지 먼저 확인하고, 있다면 백업합니다.

### 9.3 로드 확인

```shell
bin/kamal app exec -r web --reuse \
  "bin/rails runner 'puts DiseaseCase.count; puts KscoCode.count; puts DiseaseCase.where.not(job_name: nil).count'"
```

로컬의 같은 값과 비교합니다. 검색이 되는지 FTS도 확인합니다.

```shell
bin/kamal app exec -r web --reuse \
  "bin/rails runner 'puts ActiveRecord::Base.connection.select_value(%q(SELECT count(*) FROM disease_cases_fts))'"
```

## 10. 검증 체크리스트

- [ ] `ssh ubuntu@<서버IP>` 키로 접속된다 (root, 비밀번호 로그인은 거부된다)
- [ ] `sudo -n true`가 성공한다
- [ ] `docker ps`가 `sudo` 없이 동작한다
- [ ] `swapon --show`에 스왑이 보인다 (필요한 경우)
- [ ] `/data/workercare/storage`가 존재하고 `ubuntu`가 쓸 수 있다
- [ ] 로컬에서 `ssh web01.workercare docker ps`가 성공한다
- [ ] `bin/kamal setup` 완료 후 `https://<deploy.yml의 proxy.host>`가 응답한다
- [ ] 초기 데이터를 로드했고 `DiseaseCase.count`가 로컬과 같다
