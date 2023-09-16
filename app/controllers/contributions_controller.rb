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
    UserBehaviorTracking.create(event_name: :visit_donation_page, metadata: { current_user: current_user.id, session_id: session["session_id"], split_tests: { trial.experiment.name => { variant: trial.alternative.name, version: trial.experiment.version } } })
  end

  # This is a hook for Split gem. https://github.com/splitrb/split
  def log_trial_complete(trial)
    UserBehaviorTracking.create(event_name: :create_donation, metadata: { current_user: current_user.id, session_id: session["session_id"], split_tests: { trial.experiment.name => { variant: trial.alternative.name, version: trial.experiment.version } } })
  end
end
