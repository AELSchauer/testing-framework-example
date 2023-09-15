Split.configure do |config|
  config.experiments = {
    signup_header: {
      alternatives: [
        { name: "Sign Up Today!", percent: 50 },
        { name: "Create Your FREE Account!", percent: 50 }
      ],
      resettable: true
    }
  }
end
