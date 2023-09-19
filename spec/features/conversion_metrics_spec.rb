require "rails_helper"

feature "Conversion Metrics" do
  scenario "Starts a donation" do
    project = create(:project)

    visit new_project_contribution_path(project_id: project.id)

    fill_in "amount", with: "100"
    click_on "Go to Checkout"

    abtcc = AbTestContributionConversion.last
    expect(abtcc.project).to eq(project)
    expect(abtcc.contribution).to eq(nil)
    expect(abtcc.ab_test_name).to eq("dcpp")
    expect(abtcc.metadata["page_views"].count).to eq(1)
    expect(abtcc.status).to eq("unfulfilled")
  end

  scenario "Completes a donation" do
    project = create(:project)

    visit new_project_contribution_path(project_id: project.id)

    fill_in "amount", with: "100"
    click_on "Go to Checkout"
    click_on "Donate"

    abtcc = AbTestContributionConversion.last
    expect(abtcc.project).to eq(project)
    expect(abtcc.contribution).to eq(Contribution.last)
    expect(abtcc.ab_test_name).to eq("dcpp")
    expect(abtcc.metadata["page_views"].count).to eq(1)
    expect(abtcc.status).to eq("fulfilled")
  end

  scenario "Starts a donation twice" do
    project = create(:project)

    visit new_project_contribution_path(project_id: project.id)
    visit new_project_contribution_path(project_id: project.id)

    fill_in "amount", with: "100"
    click_on "Go to Checkout"
    click_on "Donate"

    abtcc = AbTestContributionConversion.last
    expect(abtcc.project).to eq(project)
    expect(abtcc.contribution).to eq(Contribution.last)
    expect(abtcc.ab_test_name).to eq("dcpp")
    expect(abtcc.metadata["page_views"].count).to eq(2)
    expect(abtcc.status).to eq("fulfilled")
  end

  scenario "Starts a donation for another campaign" do
    project_1 = create(:project)
    project_2 = create(:project)

    visit new_project_contribution_path(project_id: project_1.id)
    abtcc_1 = AbTestContributionConversion.last
    expect(abtcc_1.project).to eq(project_1)
    expect(abtcc_1.metadata["page_views"].count).to eq(1)
    expect(abtcc_1.status).to eq("unfulfilled")

    visit new_project_contribution_path(project_id: project_2.id)

    fill_in "amount", with: "100"
    click_on "Go to Checkout"
    click_on "Donate"

    expect(abtcc_1.project).to eq(project_1)
    expect(abtcc_1.metadata["page_views"].count).to eq(1)
    expect(abtcc_1.status).to eq("unfulfilled")

    abtcc_2 = AbTestContributionConversion.last
    expect(abtcc_2.project).to eq(project_2)
    expect(abtcc_2.metadata["page_views"].count).to eq(1)
    expect(abtcc_2.status).to eq("fulfilled")
  end

  scenario "Starts a donation while logged out and completes after log in" do
    project = create(:project)
    user = create(:user)

    visit new_project_contribution_path(project_id: project.id)

    abtcc = AbTestContributionConversion.last
    expect(abtcc.project).to eq(project)
    expect(abtcc.user).to eq(nil)
    expect(abtcc.metadata["page_views"].count).to eq(1)
    expect(abtcc.status).to eq("unfulfilled")

    visit login_path
    fill_in "user[email]", with: user.email
    fill_in "user[password]", with: "Testing123%"
    click_on "Log in"

    visit new_project_contribution_path(project_id: project.id)

    fill_in "amount", with: "100"
    click_on "Go to Checkout"
    click_on "Donate"

    abtcc.reload
    expect(abtcc).to eq(AbTestContributionConversion.last)
    expect(abtcc.project).to eq(project)
    expect(abtcc.user).to eq(user)
    expect(abtcc.metadata["page_views"].count).to eq(2)
    expect(abtcc.status).to eq("fulfilled")
  end

  scenario "Logs out during donation and completes while logged out" do
    project = create(:project)
    user = create(:user)

    visit login_path
    fill_in "user[email]", with: user.email
    fill_in "user[password]", with: "Testing123%"
    click_on "Log in"

    visit new_project_contribution_path(project_id: project.id)

    abtcc = AbTestContributionConversion.last
    expect(abtcc.project).to eq(project)
    expect(abtcc.user).to eq(user)
    expect(abtcc.metadata["page_views"].count).to eq(1)
    expect(abtcc.status).to eq("unfulfilled")

    click_on "Sign out"

    visit new_project_contribution_path(project_id: project.id)

    fill_in "amount", with: "100"
    click_on "Go to Checkout"
    click_on "Donate"

    abtcc.reload
    expect(abtcc).to eq(AbTestContributionConversion.last)
    expect(abtcc.project).to eq(project)
    expect(abtcc.user).to eq(user)
    expect(abtcc.metadata["page_views"].count).to eq(2)
    expect(abtcc.status).to eq("fulfilled")
  end

  scenario "Logs out during donation, logs into new account and completes" do
    project = create(:project)
    user_1 = create(:user)
    user_2 = create(:user)

    visit login_path
    fill_in "user[email]", with: user_1.email
    fill_in "user[password]", with: "Testing123%"
    click_on "Log in"

    visit new_project_contribution_path(project_id: project.id)

    abtcc_1 = AbTestContributionConversion.last
    expect(abtcc_1.project).to eq(project)
    expect(abtcc_1.user).to eq(user_1)
    expect(abtcc_1.metadata["page_views"].count).to eq(1)
    expect(abtcc_1.status).to eq("unfulfilled")

    click_on "Sign out"

    visit login_path
    fill_in "user[email]", with: user_2.email
    fill_in "user[password]", with: "Testing123%"
    click_on "Log in"

    visit new_project_contribution_path(project_id: project.id)

    fill_in "amount", with: "100"
    click_on "Go to Checkout"
    click_on "Donate"

    abtcc_2 = AbTestContributionConversion.last
    expect(abtcc_2).to_not eq(abtcc_1)
    expect(abtcc_2.user).to eq(user_2)
    expect(abtcc_2.metadata["page_views"].count).to eq(1)
    expect(abtcc_2.status).to eq("fulfilled")
  end

  scenario "Session expires before user starts another donation" do
    project = create(:project)
    user = create(:user)
    abtcc_1 = create(:ab_test_contribution_conversion, :unfulfilled, :backdate, user: user, project: project, backdate_interval: 2.week)

    visit login_path
    fill_in "user[email]", with: user.email
    fill_in "user[password]", with: "Testing123%"
    click_on "Log in"

    visit new_project_contribution_path(project_id: project.id)

    fill_in "amount", with: "100"
    click_on "Go to Checkout"
    click_on "Donate"

    abtcc_2 = AbTestContributionConversion.last
    expect(abtcc_2).to_not eq(abtcc_1)
    expect(abtcc_2.user).to eq(user)
    expect(abtcc_2.metadata["page_views"].count).to eq(1)
    expect(abtcc_2.status).to eq("fulfilled")
  end
end
