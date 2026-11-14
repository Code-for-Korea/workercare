# 주 메뉴의 현재 위치 표시. 표와 규칙은 DESIGN.md의 aria-current 절에 있다.
module NavigationHelper
  # controller_path#action_name을 메뉴 구역으로 바꾼다. 메뉴가 대표하지 않는 화면(상세, 오류)은 nil이다.
  def nav_section
    case "#{controller_path}##{action_name}"
    when "disease_cases#index" then :home
    when "disease_cases#search" then :search
    when "pages#apply_guide" then :apply_guide
    when "pages#about" then :about
    when /\Aself_care_form#/ then :self_care_form
    end
  end

  # 현재 구역의 링크에만 aria-current="page"를 붙인다. 값은 항상 "page"다.
  def nav_link_to(label, path, section, **options)
    options[:aria] = { current: "page" } if nav_section == section
    link_to label, path, **options
  end
end
