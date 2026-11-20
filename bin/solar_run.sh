#!/bin/sh
# Solar 대량 추출을 서버에서 SSH와 분리해 돌리는 스크립트(POSIX sh). 비밀값은 다루지 않는다.
# UPSTAGE_API_KEY는 컨테이너 env(Kamal env 파일)에 이미 있어야 하고, 없으면 값 노출 없이 종료한다.
#
# 사용법(로컬에서. docs/solar-extraction-plan.md 6.4)
#   시작:      bin/kamal app exec --roles=web --detach "sh bin/solar_run.sh"
#              과제 지정: ... --detach "sh bin/solar_run.sh prior_career"
#              시험:      ... --detach "env LIMIT=20 sh bin/solar_run.sh comorbidity"
#              (--reuse와는 함께 못 쓴다. --roles=web 유지. kamal은 셸을 거치지 않으므로 환경변수는 env로 준다.)
#              이 파일이 이미지에 들어가는 다음 배포 전이라면 서버 볼륨에 올려 쓴다:
#                scp bin/solar_run.sh web01.workercare:/data/workercare/storage/solar_run.sh
#                bin/kamal app exec --roles=web --detach "sh /rails/storage/solar_run.sh"
#   진행 확인: ssh web01.workercare "tail -n 5 /data/workercare/storage/exports/solar/run.log"
#              ssh web01.workercare "docker ps --filter name=exec --format '{{.Names}} {{.Status}}'"
#              ssh web01.workercare "wc -l /data/workercare/storage/exports/solar/*/results.jsonl"
#   중단:      ssh web01.workercare "docker stop -t 240 <컨테이너 이름>"
#              (TERM을 rails에 넘겨 진행 중인 건만 마치고 멈춘다. 요청당 최대 180초라 -t를 넉넉히 준다.)
#   이어 받기: 같은 시작 명령을 다시 실행한다. 이미 끝난 건은 results.jsonl 기준으로 건너뛴다.
#              서버가 재부팅되면 컨테이너가 돌아오지 않는다(--restart 없음). 끝난 컨테이너는 docker rm으로 지운다.
#
# 환경변수: APPLY(기본 1) MODEL(기본 SOLAR_MODEL 또는 solar-mini-4-5-preview) CONCURRENCY(기본 4)
#           LIMIT RPM TPM OUT_DIR(주면 과제마다 $OUT_DIR/<과제>를 쓴다) LOG_FILE(기본 /rails/storage/exports/solar/run.log)
#
# 배포 때 영향: 별도 컨테이너라 kamal deploy가 작업을 죽이지 않는다. 그래도 실행 중에는 배포하지 않는다.
#   .kamal/hooks/post-deploy의 docker system prune -f가 종료된 컨테이너와 그 docker logs를 지우므로
#   로그는 LOG_FILE(볼륨)에서 본다. 메모리도 웹과 나눠 쓴다.
# 주의: 과제는 같은 API 키 한도를 공유하므로 병렬이 아니라 순차(comorbidity, prior_career)로 돌린다.
#   한 과제가 비정상 종료(코드 0이 아님: 한도 초과, 인증 오류 등)하면 다음 과제를 시작하지 않고 그 코드로 끝낸다.
#   운영 실행은 사용자가 직접 한다.
set -u

cd "$(dirname "$0")/.." || exit 1

APPLY=${APPLY:-1}
MODEL=${MODEL:-${SOLAR_MODEL:-solar-mini-4-5-preview}}
CONCURRENCY=${CONCURRENCY:-4}
export APPLY MODEL CONCURRENCY
[ -n "${LIMIT:-}" ] && export LIMIT
[ -n "${RPM:-}" ] && export RPM
[ -n "${TPM:-}" ] && export TPM
BASE_OUT_DIR=${OUT_DIR:-}
unset OUT_DIR

LOG=${LOG_FILE:-/rails/storage/exports/solar/run.log}
mkdir -p "$(dirname "$LOG")" || exit 1

if [ "$#" -gt 0 ]; then TASKS="$*"; else TASKS="comorbidity prior_career"; fi

now() { date -u +%Y-%m-%dT%H:%M:%SZ; }
log() { echo "[run] $(now) $*" >> "$LOG"; }

if [ "$APPLY" = "1" ] && [ -z "${UPSTAGE_API_KEY:-}" ]; then
  log "UPSTAGE_API_KEY 없음, 종료"
  echo "UPSTAGE_API_KEY 없음" >&2
  exit 1
fi

STOP=""
child=""
on_signal() {
  STOP=1
  [ -n "$child" ] && kill -TERM "$child" 2>/dev/null
  return 0
}
trap on_signal TERM INT

log "전체 시작 과제=[$TASKS] 모델=$MODEL APPLY=$APPLY CONCURRENCY=$CONCURRENCY LIMIT=${LIMIT:-없음} RPM=${RPM:-없음} TPM=${TPM:-없음}"
final=0
for t in $TASKS; do
  [ -n "$STOP" ] && { log "신호를 받아 ${t}부터 시작하지 않음"; break; }
  if [ -n "$BASE_OUT_DIR" ]; then OUT_DIR="$BASE_OUT_DIR/$t"; export OUT_DIR; fi
  log "시작 과제=$t 모델=$MODEL"
  bin/rails "solar:extract[$t]" >> "$LOG" 2>&1 &
  child=$!
  [ -n "$STOP" ] && kill -TERM "$child" 2>/dev/null
  wait "$child"; rc=$?
  # 신호로 wait가 먼저 돌아오면(128 초과) 자식이 끝날 때까지 다시 기다린다.
  while kill -0 "$child" 2>/dev/null; do wait "$child"; rc=$?; done
  child=""
  log "끝 과제=$t 모델=$MODEL 종료코드=$rc"
  if [ "$rc" -ne 0 ]; then final=$rc; log "비정상 종료라 이후 과제를 시작하지 않음"; break; fi
done
log "전체 종료 종료코드=$final${STOP:+ (신호로 중단)}"
exit "$final"
