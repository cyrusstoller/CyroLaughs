module ApplicationHelper
  def title
    base_title = "Cyro Laughs (@cyrolaughs)"
    if @title.nil?
      base_title
    else
      "#{@title} | #{base_title}"
    end
  end
end
