class ContributionsController < ApplicationController
  def new
    start_test
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
    finish_test
    redirect_to project_contribution_path(project_id: params[:project_id], id: @contribution.id)
  end

  private

  def contribution_params
    { amount: params[:amount], project_id: params[:project_id] }
  end

  def start_test
    @dcpp = ab_test(:dcpp)
    UserBehaviorTracking.create(event_name: :visit_donation_page, metadata: { session_id: session["session_id"], split_tests: { dcpp: @dcpp }})
  end

  def finish_test
    @dcpp = ab_user[:dcpp]
    ab_finished(:dcpp, reset: true)
    UserBehaviorTracking.create(event_name: :create_donation, metadata: { session_id: session["session_id"], split_tests: { dcpp: @dcpp }})
  end
end
