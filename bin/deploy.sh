#!/bin/bash
# Kamal 배포 래퍼. 어느 디렉터리에서 실행해도 저장소 루트에서 kamal을 돌린다.
#
# 사용법: bin/deploy.sh [kamal 명령...]   (인자가 없으면 deploy)
#   - 저장소 루트 .env에서 ENV_KEYS에 적힌 키만 읽는다(source 하지 않음). 셸에 이미 값이 있으면 셸 값을 쓴다.
#   - deploy / redeploy / setup / app boot는 빈 키가 있으면 멈춘다. 나머지 명령은 경고만 한다.
#   - Solar 추출 실행 중에 deploy/app boot를 하면 작업이 끊긴다. 추출이 끝난 뒤에 배포한다.
#   - Docker Hub 자격은 레지스트리를 쓰는 명령에서만 묻고, 셸에 KAMAL_REGISTRY_*가 있으면 묻지 않는다.
#   예: bin/deploy.sh app exec --roles=web --detach "sh /rails/storage/solar_run.sh"  (--reuse 없는 app exec는 레지스트리 로그인이 필요해 자격을 묻는다)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
ENV_FILE="$ROOT/.env"

# 컨테이너 환경변수로 넘길 키 목록(.kamal/secrets가 셸 변수로 참조하는 키). 필요하면 여기에 추가한다.
ENV_KEYS=(UPSTAGE_API_KEY)

# .env에서 KEY= 줄의 값만 꺼내 export한다. 이미 셸에 값이 있으면 건드리지 않는다.
load_env_key() {
  local key="$1" line value
  [ -f "$ENV_FILE" ] || return 0
  line="$(grep -m1 "^${key}=" "$ENV_FILE" || true)"
  [ -n "$line" ] || return 0
  value="${line#"${key}="}"
  value="${value%$'\r'}"
  if [ "${#value}" -ge 2 ]; then
    case "$value" in
      \"*\") value="${value:1:${#value}-2}" ;;
      \'*\') value="${value:1:${#value}-2}" ;;
    esac
  fi
  if [ -z "${!key:-}" ] && [ -n "$value" ]; then
    export "$key=$value"
  fi
}

for key in "${ENV_KEYS[@]}"; do
  load_env_key "$key"
done

if [ $# -eq 0 ]; then
  set -- deploy
fi
CMD="$1"
SUB="${2:-}"

# 컨테이너를 띄우는 명령인지, 레지스트리를 쓰는 명령인지 판정한다.
BOOTS=0
case "$CMD" in
  deploy|redeploy|setup) BOOTS=1 ;;
  app)
    if [ "$SUB" = boot ]; then
      BOOTS=1
    fi
    ;;
esac

REGISTRY=0
case "$CMD" in
  deploy|redeploy|build|push|setup) REGISTRY=1 ;;
esac
# app boot도 레지스트리에서 이미지를 받으므로 자격이 필요하다.
if [ "$BOOTS" = 1 ]; then
  REGISTRY=1
fi
# --reuse 없는 app exec는 kamal이 새 컨테이너를 띄우며 레지스트리 로그인을 하므로 자격이 필요하다.
if [ "$CMD" = app ] && [ "$SUB" = exec ]; then
  REUSE=0
  for arg in "$@"; do
    if [ "$arg" = --reuse ]; then
      REUSE=1
    fi
  done
  if [ "$REUSE" = 0 ]; then
    REGISTRY=1
  fi
fi

MISSING=0
for key in "${ENV_KEYS[@]}"; do
  if [ -n "${!key:-}" ]; then
    echo "$key: 설정됨"
  else
    echo "경고: $key가 비어 있습니다(.env 또는 셸 환경)"
    MISSING=1
  fi
done

if [ "$MISSING" = 1 ] && [ "$BOOTS" = 1 ]; then
  echo "중단: 빈 키가 있으면 컨테이너를 띄우지 않습니다. .env 또는 셸에 값을 넣고 다시 실행하세요." >&2
  exit 1
fi

if [ "$REGISTRY" = 1 ]; then
  if [ -z "${KAMAL_REGISTRY_USERNAME:-}" ]; then
    printf 'Docker Hub Username: '
    read -r KAMAL_REGISTRY_USERNAME
    printf '\n'
    if [ -z "$KAMAL_REGISTRY_USERNAME" ]; then
      echo "Docker Hub Username is blank" >&2
      exit 1
    fi
  fi
  if [ -z "${KAMAL_REGISTRY_PASSWORD:-}" ]; then
    printf 'Docker Hub Access Token: '
    read -r -s KAMAL_REGISTRY_PASSWORD
    printf '\n\n'
    if [ -z "$KAMAL_REGISTRY_PASSWORD" ]; then
      echo "Access Token is blank" >&2
      exit 1
    fi
  fi
  export KAMAL_REGISTRY_USERNAME KAMAL_REGISTRY_PASSWORD
fi

bin/kamal "$@"

if [ "$BOOTS" = 1 ]; then
  echo ""
  echo "배포 후 확인(값은 출력하지 않고 설정 여부만 봅니다):"
  for key in "${ENV_KEYS[@]}"; do
    printf '  bin/kamal app exec --roles=web --reuse "sh -c '\''test -n \\"\\$%s\\" && echo set || echo missing'\''"\n' "$key"
  done
fi

echo "Done"
