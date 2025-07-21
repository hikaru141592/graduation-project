class LineWebhooksController < ApplicationController
  protect_from_forgery except: :callback
  skip_before_action :require_login, only: %i[callback]

  def callback
    raw_body = request.raw_post
    signature = request.env["HTTP_X_LINE_SIGNATURE"]
    head :ok
    ProcessLineWebhookJob.perform_later(raw_body, signature)
  end
end
