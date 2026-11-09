# 큰 글씨·고대비 화면 설정 쿠키. 허용값 외의 쿠키 값은 없는 것으로 본다. 규칙은 DESIGN.md 5장.
# 쿠키 jar는 [], []=, delete만 쓴다. 고대비의 "normal"은 OS의 prefers-contrast: more를 끄는 명시적 선택이다.
class DisplaySettings
  SETTINGS = {
    "size" => { cookie: :display_size, on: "large", values: %w[large] },
    "contrast" => { cookie: :display_contrast, on: "high", values: %w[high normal] }
  }.freeze

  def self.valid?(setting)
    SETTINGS.key?(setting)
  end

  def initialize(cookies)
    @cookies = cookies
  end

  # 허용값이면 그 값, 아니면 nil
  def value(setting)
    config = SETTINGS.fetch(setting)
    cookie = @cookies[config[:cookie]]
    cookie if config[:values].include?(cookie)
  end

  def size = value("size")
  def contrast = value("contrast")

  # 버튼이 눌린 상태인가. 쿠키가 없거나 normal이면 아니다(OS 설정은 서버가 모른다).
  def on?(setting)
    value(setting) == SETTINGS.fetch(setting)[:on]
  end

  def large_text? = on?("size")
  def high_contrast? = on?("contrast")

  # <html>에 붙일 속성. 쿠키가 없으면 속성도 없다.
  def html_attributes
    data = SETTINGS.keys.index_with { |setting| value(setting) }.compact
    data.empty? ? {} : { data: data }
  end

  # 허용된 설정만 바꾼다. 크기는 켜짐 ⇄ 쿠키 삭제, 고대비는 high ⇄ normal(쿠키를 지우지 않는다).
  def toggle(setting)
    return unless self.class.valid?(setting)

    config = SETTINGS.fetch(setting)
    if setting == "contrast"
      write(config[:cookie], on?(setting) ? "normal" : "high")
    elsif on?(setting)
      @cookies.delete(config[:cookie])
    else
      write(config[:cookie], config[:on])
    end
  end

  private

  def write(name, value)
    @cookies[name] = { value: value, expires: 1.year, same_site: :lax, httponly: true }
  end
end
