# frozen_string_literal: true

module SolarExtraction
  # 추출 과제 목록. 이름으로 과제 인스턴스를 찾는다.
  module Tasks
    REGISTRY = {
      "comorbidity" => "SolarExtraction::Tasks::Comorbidity",
      "prior_career" => "SolarExtraction::Tasks::PriorCareer"
    }.freeze

    def self.names
      REGISTRY.keys
    end

    def self.fetch(name)
      class_name = REGISTRY[name.to_s] or raise ArgumentError, "알 수 없는 과제입니다: #{name} (가능: #{names.join(', ')})"
      class_name.constantize.new
    end
  end
end
