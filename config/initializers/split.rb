Rails.application.config.to_prepare do
  Split.configure do |config|
    config.experiments = {
      signup_header: {
        alternatives: [
          { name: "Sign Up Today!", percent: 50 },
          { name: "Create Your FREE Account!", percent: 50 }
        ],
        resettable: true
      },
      dcpp: {
        alternatives: [
          { name: "show", percent: 50 },
          { name: "hide", percent: 50, control: true }
        ],
        resettable: true
      }
    }
    config.on_trial = :log_trial
    config.on_trial_complete = :log_trial_complete
  end
end
