class TermController < ApplicationController
  skip_before_action :require_login, only: %i[show]
  skip_before_action :redirect_if_incomplete_profile, only: %i[show]

  def show
  end
end
