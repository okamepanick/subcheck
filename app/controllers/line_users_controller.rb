class LineUsersController < ApplicationController
  def index
    @line_users = LineUser.all
  end
end
