# frozen_string_literal: true

class Brand < ShardRecord
  has_many :retailer_brands
  has_many :retailer_products, through: :retailer_brands
  validates :name, presence: true, uniqueness: true
  before_save :init_aliases

  private

  def init_aliases
    self.aliases = [name.upcase] if aliases.empty?
  end
end
