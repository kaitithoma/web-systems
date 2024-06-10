Rails.application.config.to_prepare do
  Dir[Rails.root.join('app/jobs/**/*.rb')].each { |file| require_dependency file }
end
