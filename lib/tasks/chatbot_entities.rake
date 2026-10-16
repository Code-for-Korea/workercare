# frozen_string_literal: true

# 카카오 챗봇 엔티티 사전(config/chatbot/entities/*.yml) 도구.
#
#   ENTITY=disease_name bin/rails chatbot:entities:build      # CSV 생성 + 리포트
#   ENTITY=disease_name bin/rails chatbot:entities:discover   # 사전에 없는 용어 빈도순
#   bin/rails chatbot:entities:check                          # 모든 사전의 구조·엔티티 사이 중복 검증
namespace :chatbot do
  namespace :entities do
    def entity_name
      ENV.fetch("ENTITY") { abort "ENTITY를 지정하세요. 예: ENTITY=disease_name bin/rails #{Rake.application.top_level_tasks.first}" }
    end

    desc "엔티티 사전에서 업로드용 CSV를 만든다 (ENTITY=, OUT=)"
    task build: :environment do
      builder = Chatbot::EntityBuilder.load(entity_name)
      out = ENV.fetch("OUT") { Rails.root.join("docs/kakaotalk/entities/#{entity_name}.csv").to_s }
      builder.write_csv(out)
      puts "작성: #{out}"
      puts builder.report
    rescue Chatbot::EntityBuilder::InvalidDictionary => e
      abort e.message
    end

    desc "사전이 덮지 못하는 용어를 빈도순으로 보여 준다 (ENTITY=, LIMIT=, MIN=)"
    task discover: :environment do
      builder = Chatbot::EntityBuilder.load(entity_name)
      list = Chatbot::EntityDiscovery.new(builder).call(limit: ENV.fetch("LIMIT", 50).to_i, min_count: ENV.fetch("MIN", 10).to_i)
      puts "사전에 없는 #{builder.column} 조각 (건수 순)"
      list.each { |fragment, count| puts format("%6d  %s", count, fragment) }
    rescue Chatbot::EntityBuilder::InvalidDictionary => e
      abort e.message
    end

    desc "모든 엔티티 사전의 구조와 엔티티 사이 중복을 검증한다"
    task check: :environment do
      failed = false
      builders = {}
      Dir[Rails.root.join(Chatbot::EntityBuilder::CONFIG_DIR, "*.yml")].sort.each do |path|
        builder = Chatbot::EntityBuilder.from_file(path)
        builders[File.basename(path, ".yml")] = builder
        errors = builder.structural_errors
        puts "#{File.basename(path)}: #{errors.empty? ? 'OK' : "오류 #{errors.size}건"}"
        errors.each { |error| puts "  - #{error}" }
        failed ||= errors.any?
      end

      cross = Chatbot::EntityBuilder.cross_entity_errors(builders)
      puts "엔티티 사이 중복: #{cross.empty? ? 'OK' : "오류 #{cross.size}건"}"
      cross.each { |error| puts "  - #{error}" }
      failed ||= cross.any?

      abort "사전 검증 실패" if failed
    end
  end
end
