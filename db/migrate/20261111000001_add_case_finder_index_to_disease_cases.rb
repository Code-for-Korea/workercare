# 단계별 사례 찾기(CaseFinder)의 필터는 job_name·burden_body_part에 식(REPLACE·연결)을 걸고 LIKE '%…%'를 쓰기 때문에
# 인덱스를 탈 수 없어, 긴 본문 컬럼이 든 테이블 전체(약 800MB)를 읽었다(운영에서 약 28초).
# 필터가 읽는 컬럼과 정렬 키(year DESC, rowid)를 모두 담은 커버링 인덱스로, id만 찾는 쿼리가 인덱스(수 MB)만 읽게 한다.
class AddCaseFinderIndexToDiseaseCases < ActiveRecord::Migration[8.1]
  def change
    add_index :disease_cases, [ :year, :job_name, :burden_body_part, :result ],
      order: { year: :desc }, name: "idx_disease_cases_case_finder"
  end
end
