module VideosHelper
  def sortable_link_to(column, title = nil)
    title ||= column.titleize
    direction = column == sort_column && sort_direction == "desc" ? "asc" : "desc"
    link_to title, {:sort => column, :direction => direction}
  end
end
