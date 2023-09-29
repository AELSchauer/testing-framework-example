require "./lib/split/custom_session_adapter"

Split.configure do |config|
  config.persistence = Split::CustomSessionAdapter
  # config.persistence = :cookie
  # config.persistence_cookie_length = 2592000 # 30 days
  config.experiments = {
    "donor_covered_payment_processing" => {
      "alternatives" => [
        {
          "name" => "exploit",
          "percent" => 50
        },
        {
          "name" => "explore__show",
          "percent" => 25
        },
        {
          "name" => "explore__hide",
          "percent" => 25
        }
      ],
      "metadata" => {
        "exploit" => {
          "cohort" => "exploit",
          "experience" => "show"
        },
        "explore__show" => {
          "cohort" => "explore",
          "experience" => "show"
        },
        "explore__hide" => {
          "cohort" => "explore",
          "experience" => "hide"
        }
      }
    },
    "recurring_gift_nudge" => {
      "alternatives" => [
        {
          "name" => "exploit",
          "percent" => 50
        },
        {
          "name" => "explore__show",
          "percent" => 25
        },
        {
          "name" => "explore__hide",
          "percent" => 25
        }
      ],
      "metadata" => {
        "exploit" => {
          "cohort" => "exploit",
          "experience" => "show"
        },
        "explore__show" => {
          "cohort" => "explore",
          "experience" => "show"
        },
        "explore__hide" => {
          "cohort" => "explore",
          "experience" => "hide"
        }
      }
    }
  }
  config.on_trial = :log_trial
  config.on_trial_complete = :log_trial_complete
  config.allow_multiple_experiments = true
  config.store_override = true if Rails.env.test? || Rails.env.development?
end
