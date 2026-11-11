namespace :analysis do
  desc "판정서 분석 통계표를 DB 질의만으로 다시 만들어 마크다운으로 쓴다(읽기 전용, LLM·외부 API 없음).\n" \
       "  사용법: rails 'analysis:report'                          (tmp/analysis/report-YYYYMMDD.md)\n" \
       "          rails 'analysis:report[/path/to/report.md]'\n" \
       "  규칙이 문서에 없는 표(5.3, 6.1·6.2·6.4·6.5)는 \"재현 불가\"로 표시한다. 자세히는 docs/analysis-report.md."
  task :report, [ :out_path ] => :environment do |_, args|
    out = args[:out_path].presence || Rails.root.join("tmp/analysis/report-#{Date.today.strftime('%Y%m%d')}.md").to_s
    markdown = AnalysisReport.new.to_markdown
    FileUtils.mkdir_p(File.dirname(out))
    File.write(out, markdown)
    puts "분석 보고서를 썼습니다: #{out} (#{DiseaseCase.count}건 기준, #{markdown.lines.size}줄)"
  end
end
