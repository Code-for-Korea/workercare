# frozen_string_literal: true

module SelfCareForm
  # 단계별 사례 찾기(단계형 자가진단)의 단계·허용값·순서를 한 곳에 둔다. 문서: docs/self-care-form.md
  #
  # 흐름: 시작(동의) → situation → body_part → job → decision → profile(통계 한 페이지) → 확인(review) → 결과(result)
  # 시작·확인·결과는 정적 경로이고, 질문 화면 5개만 STEP_KEYS(`/self-care-form/:step`)다.
  # 구글 폼으로 보내는 값은 여기의 라벨 문자열과 같다(라벨을 바꾸면 보내는 값도 바뀐다).
  module Flow
    STEP_KEYS = %w[situation body_part job decision profile].freeze
    FREE_TEXT_MAX = 30

    NEXT_STEP = { "situation" => "body_part", "body_part" => "job", "job" => "decision",
                  "decision" => "profile", "profile" => "review" }.freeze
    PREVIOUS_STEP = { "situation" => "start", "body_part" => "situation", "job" => "body_part",
                      "decision" => "job", "profile" => "decision", "review" => "profile" }.freeze

    SITUATIONS = {
      "ill" => "이미 아픈 곳이 있어요",
      "prevention" => "아직 아프지 않지만 예방하려고 알아봐요",
      "no_time" => "병원 갈 시간이 없어 먼저 알아보고 있어요"
    }.freeze

    # 판정 결과 선택. 라벨은 DB의 판정 결과 라벨(인정·불인정·…)을 그대로 쓰고 "모두 보기"만 더한다.
    DECISION_ALL = "all"
    DECISION_KEYS = (DiseaseCase.results.keys + [ DECISION_ALL ]).freeze

    PROFILE_FIELDS = {
      "respondent" => [ "본인", "유가족", "피해 노동자의 가족", "동료·지인", "기타" ],
      "application_experience" => [ "아직 안 함", "신청 중", "불승인을 받음", "승인받음" ],
      "age_band" => [ "10대", "20대", "30대", "40대", "50대", "60대 이상" ],
      "region" => %w[서울 부산 대구 인천 광주 대전 울산 세종 경기 강원 충북 충남 전북 전남 경북 경남 제주]
    }.freeze

    # 구글 폼으로 보낼 수 있는 값의 전체 키. 실제로 보내는 것은 설정(config/self_care_form.yml)의 entries에 id가
    # 있는 키뿐이다(전송 키 = SENDABLE_KEYS ∩ entries 키). 자유 입력 원문은 보내지 않는다(예외는 직종 직접 입력 한 칸뿐이고 가려서 30자까지).
    SENDABLE_KEYS = %w[body_part job decision age_band region application_experience respondent situation relaxed
                       result_count].freeze

    # 직종 버튼 소제목 묶음. 합집합은 챗봇 사전(config/chatbot/entities/job_name.yml)의 직종 54개와 같아야 한다(테스트).
    JOB_GROUPS = {
      "건설·현장" => [ "용접공", "목수", "석공", "도장공", "배관공", "철근공", "철골공", "미장공", "조적공", "타일공",
                    "방수공", "비계공", "전기공", "벌목공", "건설 일용직", "현장소장", "신호수", "광부" ],
      "운전·물류" => [ "택시기사", "버스기사", "운전기사", "택배기사", "배송기사", "지게차 운전원", "물류 노동자",
                    "포장원", "주유원", "주차관리원" ],
      "제조·정비" => [ "생산직", "자동차 조립원", "조립원", "프레스 작업자", "사상공", "조선소 노동자",
                    "자동차 정비원", "기계 정비원", "공장장" ],
      "서비스·돌봄" => [ "조리원", "홀서빙", "설거지", "제빵사", "환경미화원", "요양보호사", "경비원", "시설관리원",
                     "간호사", "간호조무사", "보육교사", "교사", "사회복지사" ],
      "사무·판매·연구" => [ "사무직", "영업직", "판매원", "연구원" ]
    }.freeze
    JOB_NAMES = JOB_GROUPS.values.flatten.freeze

    class << self
      def step?(key)
        STEP_KEYS.include?(key.to_s)
      end

      def next_step(key)
        NEXT_STEP.fetch(key.to_s)
      end

      def previous_step(key)
        PREVIOUS_STEP.fetch(key.to_s)
      end

      # 질문 화면 5개만 센다(시작·확인·결과에는 번호가 없다).
      def question_number(key)
        STEP_KEYS.index(key.to_s)&.succ
      end

      def question_count
        STEP_KEYS.size
      end

      def decision_label(key)
        key.to_s == DECISION_ALL ? "모두 보기" : DiseaseCase.human_attribute_enum(:result, key.to_s)
      end

      def situation_label(key)
        SITUATIONS[key.to_s]
      end

      def body_part_names
        Chatbot::EntityDictionary.concepts("body_part").keys
      end

      def job_name?(name)
        JOB_NAMES.include?(name.to_s)
      end
    end
  end
end
