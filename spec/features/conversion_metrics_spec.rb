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

    abtcc_2 = AbTestContributionConversion.last
    expect(abtcc_2.project).to eq(project_2)
    expect(abtcc_2.metadata["page_views"].count).to eq(1)
    expect(abtcc_2.status).to eq("fulfilled")
  end
end
