class Ruby::SearchController < ApplicationController
  def show
    query
  end

  private
  def query
    param(:q)
  end
end
