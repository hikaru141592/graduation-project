class PublicPagesController < ApplicationController
  skip_before_action :require_login, only: %i[about term privacy]
  skip_before_action :redirect_if_incomplete_profile, only: %i[about term privacy]

  def about; end
  def term; end
  def privacy; end
end
