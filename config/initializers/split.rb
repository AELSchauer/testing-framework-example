Rails.application.config.to_prepare do
  Split.configure do |config|
    config.persistence = Split::CustomSessionAdapter
    config.experiments = YAML.load_file("config/experiments.yml")["experiments"]
    config.on_trial = :log_trial
    config.on_trial_complete = :log_trial_complete
    config.allow_multiple_experiments = true
    config.store_override = true if Rails.env.test? || Rails.env.development?
  end
end
