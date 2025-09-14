require 'rails_helper'

RSpec.describe ProcessLineWebhookJob, type: :job do
  it "perform_laterでキューに積まれる" do
    expect {
      ProcessLineWebhookJob.perform_later
    }.to have_enqueued_job(ProcessLineWebhookJob)
  end
end
