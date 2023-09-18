class ContributionsController < ApplicationController
  def new
    @dcpp = ab_test(:dcpp)
    @contribution = Contribution.new
  end

  def create
    @contribution = Contribution.new(contribution_params)
    if @contribution.save
      redirect_to edit_project_contribution_path(project_id: params[:project_id], id: @contribution.id)
    else
      render 'new'
    end
  end

  def show
    @contribution = Contribution.find(params[:id])
  end

  def edit
    @contribution = Contribution.find(params[:id])
  end

  def update
    @contribution = Contribution.find(params[:id])
    @contribution.update(paid: true)
    ab_finished(:dcpp, reset: true)
    redirect_to project_contribution_path(project_id: params[:project_id], id: @contribution.id)
  end

  private

  def contribution_params
    { amount: params[:amount], project_id: params[:project_id] }
  end

  # This is a hook for Split gem. https://github.com/splitrb/split
  def log_trial(trial)
    UserBehaviorTracking.create(event_name: :visit_donation_page, metadata: { project_id: params[:project_id], current_user: current_user&.id, session_id: session["session_id"], split_tests: { trial.experiment.name => { variant: trial.alternative.name, version: trial.experiment.version } } })
    create_ab_test_contribution_conversion(trial)
  end

  # This is a hook for Split gem. https://github.com/splitrb/split
  def log_trial_complete(trial)
    UserBehaviorTracking.create(event_name: :create_donation, metadata: { project_id: params[:project_id], current_user: current_user&.id, session_id: session["session_id"], split_tests: { trial.experiment.name => { variant: trial.alternative.name, version: trial.experiment.version } } })
    complete_ab_test_contribution_conversion(trial)
  end

  def create_ab_test_contribution_conversion(trial)
    abtcc = find_ab_test_contribution_conversion(trial)

    if abtcc.blank?
      abtcc = AbTestContributionConversion.new(
        user: current_user,
        session_id: session["session_id"],
        project_id: params[:project_id],
        ab_test_name: trial.experiment.name,
        ab_test_variant: trial.alternative.name,
        ab_test_version: trial.experiment.version,
        status: "unfulfilled",
        metadata: { page_views: [] }
      )
    elsif abtcc.user.blank?
      abtcc.user = current_user
    end

    abtcc.metadata["page_views"] << Time.now
    abtcc.save!
  end

  def complete_ab_test_contribution_conversion(trial)
    abtcc = find_ab_test_contribution_conversion(trial)

    abtcc.assign_attributes(contribution: @contribution, status: "fulfilled")
    abtcc.assign_attributes(user: current_user) if current_user.present?
    abtcc.save!
  end

  def find_ab_test_contribution_conversion(trial)
    abtcc = if current_user.present? 
      AbTestContributionConversion.matches_user_or_no_user(current_user)
    else
      AbTestContributionConversion
    end

    abtcc.where(session_id: session["session_id"], project_id: params[:project_id])
      .where(ab_test_name: trial.experiment.name, ab_test_variant: trial.alternative.name, ab_test_version: trial.experiment.version)
      .unfulfilled
      .not_expired
      .latest
      .first
  end
end
