class CreateBaseContributionMetrics < ActiveRecord::Migration[7.0]
  def change
    create_view :base_contribution_metrics
  end
end
