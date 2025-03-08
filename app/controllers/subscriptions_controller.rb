class SubscriptionsController < ApplicationController
  def index
  end

  def new
    @subscription = Subscription.new
  end
end
