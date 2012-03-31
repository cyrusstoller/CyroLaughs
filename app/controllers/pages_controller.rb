class PagesController < ApplicationController
  def home
    redirect_to about_path
  end

  def about
  end

  def recent
  end

  def liked
  end
end
