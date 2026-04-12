module HumanEnumerable
  extend ActiveSupport::Concern

  included do
    def human_attribute_enum(attribute, variant = nil, options = {})
      self.class.human_attribute_enum(attribute, self[attribute], variant, **options)
    end
  end

  class_methods do
    def human_attribute_enum(attribute, key, variant = nil, options = {})
      value_options = options.dup
      attribute = "#{attribute}_enum"
      if value_options[:default].blank?
        default_options = value_options.dup
        default_options[:default] = key
        value_options[:default] = human_attribute_name([ attribute, variant, :undefined ].compact_blank.join("."), **default_options)
      end
      human_attribute_name([ attribute, variant, key ].compact_blank.join("."), **value_options)
    end

    def enum_options_for_select(attribute, options = {})
      onlys    = (options.delete(:only)    || []).compact.map!(&:to_s)
      excludes = (options.delete(:exclude) || []).compact.map!(&:to_s)
      send(attribute.to_s.pluralize).keys.filter_map do |key|
        next if onlys.present?    && onlys.exclude?(key)
        next if excludes.present? && excludes.include?(key)
        [ human_attribute_enum(attribute, key, **options), key ]
      end.to_h
    end
  end
end
