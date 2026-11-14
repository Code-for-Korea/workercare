# frozen_string_literal: true

# 검색·상세를 마크다운으로 제공한다(.md 확장자 또는 Accept: text/markdown).
Mime::Type.register "text/markdown", :md

# public/ 의 .txt(llms.txt, robots.txt)를 정적 파일 서버가 UTF-8로 보내게 한다. charset이 없으면 브라우저가 한국어를 깨뜨린다.
Rack::Mime::MIME_TYPES[".txt"] = "text/plain; charset=utf-8"
