require 'rails_helper'

RSpec.describe SeasonalNotificationJob, type: :job do
  it "perform_laterでキューに積まれる" do
    expect {
      SeasonalNotificationJob.perform_later
    }.to have_enqueued_job(SeasonalNotificationJob)
  end
end
