module ApplicationHelper
  def sort_link(label, column)
    path_helper = params[:controller] + '_path'
    if column == params[:column]
      link_to(label, send(path_helper, column: column, direction: next_direction))
    else
      link_to(label, send(path_helper, column: column, direction: 'asc'))
    end
  end

  def next_direction
    params[:direction] == 'asc' ? 'desc' : 'asc'
  end

  def sort_indicator
    tag.div(class: "sort sort-#{params[:direction]}")
  end
end
