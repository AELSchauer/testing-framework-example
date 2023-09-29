class ContributionsController < ApplicationController
  def new
    start_tests
    @contribution = Contribution.new
  end

  def create
    @contribution = Contribution.new(contribution_params)
    if @contribution.save
      debugger
      finish_tests
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
    redirect_to project_contribution_path(project_id: params[:project_id], id: @contribution.id)
  end

  private

  def contribution_params
    { amount: params[:amount], project_id: params[:project_id] }
  end

  def start_tests
    ab_test(:donor_covered_payment_processing) do |alternative, metadata|
      @donor_covered_payment_processing = metadata["experience"]
    end
    ab_test(:recurring_gift_nudge) do |alternative, metadata|
      @recurring_gift_nudge = metadata["experience"]
    end
  end

  def finish_tests
    ab_finished(:donor_covered_payment_processing, reset: true)
    ab_finished(:recurring_gift_nudge, reset: true)
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
    abtcc = find_ab_test_contribution_conversion

    if abtcc.blank?
      abtcc = AbTestContributionConversion.new(
        user: current_user,
        session_id: session["split"]["id"],
        project_id: params[:project_id],
        status: "unfulfilled",
        metadata: { page_views: [], features: {} }
      )
    elsif abtcc.user.blank?
      abtcc.user = current_user
    end

    if abtcc.metadata["features"][trial.experiment.name].blank?
      abtcc.metadata["features"][trial.experiment.name] = {
        "setting" => "xx_test",
        "version" => trial.experiment.version,
        **trial.metadata
      }
    end

    abtcc.metadata["page_views"] << Time.now
    abtcc.save!
  end

  def complete_ab_test_contribution_conversion(trial)
    abtcc = find_ab_test_contribution_conversion

    debugger

    return if abtcc.fulfilled?

    abtcc.metadata["features"]["donor_covered_payment_processing"]["result"] = params[:donor_covered_payment_processing] == "1" if params[:donor_covered_payment_processing].present?
    abtcc.metadata["features"]["recurring_gift_nudge"]["result"] = params[:recurring_gift_nudge] == "1" if params[:recurring_gift_nudge].present?
    abtcc.assign_attributes(contribution: @contribution, status: "fulfilled")
    abtcc.assign_attributes(user: current_user) if current_user.present?

    abtcc.save!
  end

  def find_ab_test_contribution_conversion
    AbTestContributionConversion
      .where(session_id: session["split"]["id"], project_id: params[:project_id])
      .and(AbTestContributionConversion.unfulfilled.not_expired)
      .or(AbTestContributionConversion.fulfilled.where("updated_at >= ?", 5.seconds.ago))
      .latest
      .first
  end
end
