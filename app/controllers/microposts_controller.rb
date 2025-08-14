class MicropostsController < ApplicationController
  def index
    @microposts = Micropost.latest_first
  end
end
