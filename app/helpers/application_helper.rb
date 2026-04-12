module ApplicationHelper
  def result_badge_class(result)
    case result
    when "approved"           then "bg-success"
    when "rejected"           then "bg-danger"
    when "partially_approved" then "bg-warning text-dark"
    when "revised_approved"   then "bg-info text-dark"
    else                           "bg-secondary"
    end
  end

  def years_for_select
    current_year = Date.today.year
    (2000..current_year).to_a.reverse.map { |y| [ y.to_s, y.to_s ] }
  end
end
