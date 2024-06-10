# frozen_string_literal: true

module Jobs
  module Tools
    GREEK_ACCENTS = {
      'Ί' => 'Ι', 'Ϊ' => 'Ι', 'Ύ' => 'Υ', 'Ϋ' => 'Υ',
      'Ά' => 'Α', 'Έ' => 'Ε', 'Ή' => 'Η', 'Ό' => 'Ο', 'Ώ' => 'Ω'
    }.freeze
    # The order here is important
    # e.g, "Nestle Manhattan Παγωτό Βανίλια-Φράουλα 757gr (1400ml)"
    # Longer strings should be first proper product name cleaning
    MEASUREMENT_UNIT = {
      'LT' => %w[LΤ LT L],
      'GR' => %w[ΓΡ GR G],
      'KG' => %w[ΚG KG],
      'ΤΜΧ' => %w[ΤΜΧ ΤΕΜ],
      'ML' => %w[ΜΛ ΜΛ ΜL ML],
      'ΜΕΖ' => %w[ΜΕΖΟΥΡΕΣ ΜΕΖ MEZ MΕΖ MΕZ ΜΕZ MEΖ ΜEZ M Μ]
    }.freeze

    class << self
      def remove_greek_accents(str)
        GREEK_ACCENTS.each { |k, v| str[k] &&= v }
        str
      end

      def get_alias_for_unit_measurement(name)
        MEASUREMENT_UNIT.each do |key, unit_strings|
          return key if name.match(/(\d+)(?:\s*)((#{unit_strings.join('|')})+)(?!\w)/)
        end
        nil
      end
    end
  end
end
