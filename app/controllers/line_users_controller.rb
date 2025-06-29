class LineUsersController < ApplicationController
  before_action :authenticate_admin_user!
  def index
    @line_users = LineUser.all
  end
end
