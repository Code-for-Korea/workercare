# 메인 화면의 부담 신체 부위 필터 옵션이 burden_body_part 한 컬럼만 읽는데, 인덱스가 없어
# 긴 본문 컬럼을 지나 테이블 전체(약 800MB)를 스캔했다. 커버링 인덱스로 인덱스(약 1MB)만 읽게 한다.
class AddIndexToDiseaseCasesBurdenBodyPart < ActiveRecord::Migration[8.1]
  def change
    add_index :disease_cases, :burden_body_part
  end
end
