# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

visit_tracking_event = UserBehaviorTrackingEvent.create(name: "Visit Donation Page")
donation_tracking_event = UserBehaviorTrackingEvent.create(name: "Create Donation")


user_1 = FactoryBot.create(:user, name: "User who makes contribution on first page visit")
user_session_1 = FactoryBot.create(:user_session, :backdate_1_week, user: user_1)

now = DateTime.now
UserBehaviorTracking.create(user_session: user_session_1, user_behavior_tracking_event: visit_tracking_event, created_at: 5.minutes.before(now), metadata: { url: "/campaigns/1234/donations/new" })
UserBehaviorTracking.create(user_session: user_session_1, user_behavior_tracking_event: donation_tracking_event, created_at: now, trackable: Contribution.create(user: user_1, amount: 2000))


user_2 = FactoryBot.create(:user, name: "User who makes contribution on second page visit")
user_session_2 = FactoryBot.create(:user_session, :backdate_1_week, user: user_2)

now = DateTime.now
UserBehaviorTracking.create(user_session: user_session_2, user_behavior_tracking_event: visit_tracking_event, created_at: 2.days.before(now), metadata: { url: "/campaigns/1234/donations/new" })
UserBehaviorTracking.create(user_session: user_session_2, user_behavior_tracking_event: visit_tracking_event, created_at: 5.minutes.before(now), metadata: { url: "/campaigns/1234/donations/new" })
UserBehaviorTracking.create(user_session: user_session_2, user_behavior_tracking_event: donation_tracking_event, created_at: now, trackable: Contribution.create(user: user_2, amount: 2000))


user_3 = FactoryBot.create(:user, name: "User who makes multiple contributions within 1 week")
user_session_3 = FactoryBot.create(:user_session, :backdate_1_week, user: user_3)

now = DateTime.now
UserBehaviorTracking.create(user_session: user_session_2, user_behavior_tracking_event: visit_tracking_event, created_at: 2.days.before(now), metadata: { url: "/campaigns/1234/donations/new" })
UserBehaviorTracking.create(user_session: user_session_2, user_behavior_tracking_event: donation_tracking_event, created_at: 5.minutes.after(2.days.before(now)), trackable: Contribution.create(user: user_3, amount: 2000))
UserBehaviorTracking.create(user_session: user_session_2, user_behavior_tracking_event: visit_tracking_event, created_at: 5.minutes.before(now), metadata: { url: "/campaigns/5678/donations/new" })
UserBehaviorTracking.create(user_session: user_session_2, user_behavior_tracking_event: donation_tracking_event, created_at: now, trackable: Contribution.create(user: user_3, amount: 2000))


user_4 = FactoryBot.create(:user, name: "User who visits once and doesn't make a contribution")
user_session_4 = FactoryBot.create(:user_session, :backdate_1_week, user: user_4)

now = DateTime.now
UserBehaviorTracking.create(user_session: user_session_2, user_behavior_tracking_event: visit_tracking_event, created_at: 2.days.before(now), metadata: { url: "/campaigns/1234/donations/new" })


user_4 = FactoryBot.create(:user, name: "User who visits multiple times and doesn't make a contribution")
user_session_4 = FactoryBot.create(:user_session, :backdate_1_week, user: user_4)

now = DateTime.now
UserBehaviorTracking.create(user_session: user_session_2, user_behavior_tracking_event: visit_tracking_event, created_at: 2.days.before(now), metadata: { url: "/campaigns/1234/donations/new" })
UserBehaviorTracking.create(user_session: user_session_2, user_behavior_tracking_event: visit_tracking_event, created_at: 5.days.before(now), metadata: { url: "/campaigns/1234/donations/new" })