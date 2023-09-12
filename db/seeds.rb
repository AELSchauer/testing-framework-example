# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

visit_tracking_event = UserBehaviorTrackingEvent.create(name: "Visit Donation Page")
donation_tracking_event = UserBehaviorTrackingEvent.create(name: "Create Donation")


user = FactoryBot.create(:user, name: "User who makes contribution on first page visit")
user_session = FactoryBot.create(:user_session, :backdate, user: user)
now = DateTime.now
UserBehaviorTracking.create(user_session: user_session, user_behavior_tracking_event: visit_tracking_event, created_at: 5.minutes.before(now), metadata: { url: "/campaigns/1234/donations/new" })
UserBehaviorTracking.create(user_session: user_session, user_behavior_tracking_event: donation_tracking_event, created_at: now, trackable: Contribution.create(user: user, amount: 2000))

user = FactoryBot.create(:user, name: "User who makes contribution on second page visit")
user_session = FactoryBot.create(:user_session, :backdate, user: user)
now = DateTime.now
UserBehaviorTracking.create(user_session: user_session, user_behavior_tracking_event: visit_tracking_event, created_at: 2.days.before(now), metadata: { url: "/campaigns/1234/donations/new" })
UserBehaviorTracking.create(user_session: user_session, user_behavior_tracking_event: visit_tracking_event, created_at: 5.minutes.before(now), metadata: { url: "/campaigns/1234/donations/new" })
UserBehaviorTracking.create(user_session: user_session, user_behavior_tracking_event: donation_tracking_event, created_at: now, trackable: Contribution.create(user: user, amount: 2000))

user = FactoryBot.create(:user, name: "User who makes multiple contributions within 1 week")
user_session = FactoryBot.create(:user_session, :backdate, user: user)
now = DateTime.now
UserBehaviorTracking.create(user_session: user_session, user_behavior_tracking_event: visit_tracking_event, created_at: 2.days.before(now), metadata: { url: "/campaigns/1234/donations/new" })
UserBehaviorTracking.create(user_session: user_session, user_behavior_tracking_event: donation_tracking_event, created_at: 5.minutes.after(2.days.before(now)), trackable: Contribution.create(user: user, amount: 2000))
UserBehaviorTracking.create(user_session: user_session, user_behavior_tracking_event: visit_tracking_event, created_at: 5.minutes.before(now), metadata: { url: "/campaigns/5678/donations/new" })
UserBehaviorTracking.create(user_session: user_session, user_behavior_tracking_event: donation_tracking_event, created_at: now, trackable: Contribution.create(user: user, amount: 2000))

user = FactoryBot.create(:user, name: "User who visits once and doesn't make a contribution")
user_session = FactoryBot.create(:user_session, :backdate, user: user)
now = DateTime.now
UserBehaviorTracking.create(user_session: user_session, user_behavior_tracking_event: visit_tracking_event, created_at: 2.days.before(now), metadata: { url: "/campaigns/1234/donations/new" })

user = FactoryBot.create(:user, name: "User who visits multiple times and doesn't make a contribution")
user_session = FactoryBot.create(:user_session, :backdate, user: user)
now = DateTime.now
UserBehaviorTracking.create(user_session: user_session, user_behavior_tracking_event: visit_tracking_event, created_at: 2.days.before(now), metadata: { url: "/campaigns/1234/donations/new" })
UserBehaviorTracking.create(user_session: user_session, user_behavior_tracking_event: visit_tracking_event, created_at: 5.days.before(now), metadata: { url: "/campaigns/1234/donations/new" })

user = FactoryBot.create(:user, name: "User who makes multiple contributions over multiple sessions")
user_session = FactoryBot.create(:user_session, :backdate, user: user)
now = DateTime.now
UserBehaviorTracking.create(user_session: user_session, user_behavior_tracking_event: visit_tracking_event, created_at: 2.days.before(now), metadata: { url: "/campaigns/1234/donations/new" })
UserBehaviorTracking.create(user_session: user_session, user_behavior_tracking_event: donation_tracking_event, created_at: now, trackable: Contribution.create(user: user, amount: 2000))
backdate_interval = 1.month
user_session = FactoryBot.create(:user_session, :backdate, user: user, backdate_interval: backdate_interval)
donation_created_at = 2.days.after(backdate_interval.ago)
UserBehaviorTracking.create(user_session: user_session, user_behavior_tracking_event: visit_tracking_event, created_at: 5.minutes.before(donation_created_at), metadata: { url: "/campaigns/1234/donations/new" })
UserBehaviorTracking.create(user_session: user_session, user_behavior_tracking_event: donation_tracking_event, created_at: donation_created_at, trackable: Contribution.create(user: user, amount: 2000))
backdate_interval = 3.months
donation_created_at = 2.days.after(backdate_interval.ago)
user_session = FactoryBot.create(:user_session, :backdate, user: user, backdate_interval: backdate_interval)
UserBehaviorTracking.create(user_session: user_session, user_behavior_tracking_event: visit_tracking_event, created_at: 5.minutes.before(donation_created_at), metadata: { url: "/campaigns/1234/donations/new" })
UserBehaviorTracking.create(user_session: user_session, user_behavior_tracking_event: donation_tracking_event, created_at: donation_created_at, trackable: Contribution.create(user: user, amount: 2000))
