class DiseaseCase < ApplicationRecord
  include HumanEnumerable
  include DiseaseCases::Searchable

  enum :result, {
    approved: "approved",
    rejected: "rejected",
    partially_approved: "partially_approved",
    revised_approved: "revised_approved"
  }, prefix: true

  enum :disease_category, {
    musculoskeletal: "musculoskeletal",
    other_disease: "other_disease",
    hearing_loss: "hearing_loss",
    cardiovascular: "cardiovascular",
    cancer: "cancer",
    pneumoconiosis: "pneumoconiosis",
    respiratory: "respiratory"
  }, prefix: true

  enum :body_part, {
    chest_back: "chest_back",
    ear: "ear",
    other: "other",
    eye: "eye",
    leg: "leg",
    head: "head",
    neck: "neck",
    foot: "foot",
    abdomen: "abdomen",
    multiple: "multiple",
    urogenital: "urogenital",
    digestive: "digestive",
    hand: "hand",
    circulatory: "circulatory",
    nervous_system: "nervous_system",
    face: "face",
    hip: "hip",
    whole_body: "whole_body",
    arm: "arm",
    lower_back: "lower_back",
    respiratory_organ: "respiratory_organ"
  }, prefix: true

  # FTS5 fulltext 검색 (content table JOIN)
  scope :fulltext, ->(query) {
    return all if query.blank?
    joins("JOIN disease_cases_fts ON disease_cases_fts.rowid = disease_cases.id").where("disease_cases_fts MATCH ?", query)
  }

  scope :by_date_range, ->(from, to) {
    if from && to
      where(decided_on: from..to)
    elsif from
      where("decided_on >= ?", from)
    elsif to
      where("decided_on <= ?", to)
    end
  }

  def self.detail_sections
    %i[statement claim_purpose application_content applicant_claim
      medical_records recognized_facts related_laws committee_decision].map {
      [ it, DiseaseCase.human_attribute_name(it) ]
    }.to_h
  end

  def self.enum_options_for_select_with_blank(enum_name)
    [ [ "— #{I18n.t("search.all_results")} —", "" ] ] + DiseaseCase.enum_options_for_select(enum_name).to_a
  end

  def self.enum_options_for_select_multiple(enum_name)
    [ [ "— #{I18n.t("search.all_results")} —", "" ] ] + DiseaseCase.enum_options_for_select(enum_name).to_a
  end

  def to_param
    case_no
  end
end
