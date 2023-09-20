class ContributionsController < ApplicationController
  def new
    start_tests
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
    finish_tests
    redirect_to project_contribution_path(project_id: params[:project_id], id: @contribution.id)
  end

  private

  def contribution_params
    { amount: params[:amount], project_id: params[:project_id] }
  end

  def conflicting_test_names
    YAML.load_file("config/experiments.yml").dig("conflicts", "contributions") || []
  end

  def select_from_conflicting_tests
    params[:ab_test]&.keys&.find { |k| conflicting_test_names.include?(k) } || 
      active_experiments.keys.find { |k| conflicting_test_names.include?(k) } || 
      conflicting_test_names.sample
  end

  def start_tests
    selected_test_name = select_from_conflicting_tests
    instance_variable_set("@#{selected_test_name}", ab_test(selected_test_name))
  end

  def finish_tests
    selected_test_name = select_from_conflicting_tests
    ab_finished(selected_test_name, reset: true)
  end

  # This is a hook for Split gem. https://github.com/splitrb/split
  def log_trial(trial)
    create_ab_test_contribution_conversion(trial)
  end

  # This is a hook for Split gem. https://github.com/splitrb/split
  def log_trial_complete(trial)
    complete_ab_test_contribution_conversion(trial)
  end

  def create_ab_test_contribution_conversion(trial)
    abtcc = find_ab_test_contribution_conversion(trial)

    if abtcc.blank?
      abtcc = AbTestContributionConversion.new(
        user: current_user,
        session_id: session["split"]["id"],
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

    abtcc.where(session_id: session["split"]["id"], project_id: params[:project_id])
         .where(ab_test_name: trial.experiment.name, ab_test_variant: trial.alternative.name, ab_test_version: trial.experiment.version)
         .unfulfilled
         .not_expired
         .latest
         .first
  end
end
