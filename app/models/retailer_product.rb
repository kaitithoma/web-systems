# frozen_string_literal: true

class RetailerProduct < ShardRecord
  UNIT_STRINGS = {
    'LT' => 'Litre',
    'ML' => 'Litre',
    'GR' => 'Kilogram',
    'KG' => 'Kilogram',
    'ΤΜΧ' => 'Piece',
    'ΜΕΖ' => 'Metre'
  }
  validates :name, presence: true, uniqueness: { scope: :site_id }

  belongs_to :product, optional: true
  belongs_to :retailer_brand, optional: true
  belongs_to :site
  belongs_to :retailer_category, optional: true
  has_many :product_price_metrics

  delegate :name, to: :retailer_brand, prefix: true
  delegate :name, to: :product, prefix: true
  delegate :name, to: :site, prefix: true

  def last_price
    metric = product_price_metrics.order(date: :desc).first
    {
      name: name,
      site: site.name,
      price: metric.price,
      measurement_unit_price: measurement_unit_price(metric),
      url: url,
      retailer_product_id: id
    }
  end

  def price_history
    {
      dates: product_price_metrics.order(:date).pluck(:date).map { |date| date.strftime('%d/%m/%Y') },
      prices: product_price_metrics.order(:date).pluck(:price).map(&:to_f)
    }
  end

  private

  def unit_string(unit)
    UNIT_STRINGS[unit] || unit
  end

  def measurement_unit_price(metric)
    "#{metric.measurement_unit_price}/#{unit_string(measurement_unit)}"
  end
end
