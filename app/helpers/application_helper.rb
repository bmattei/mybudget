module ApplicationHelper
  def sort_link(label, column)
    #path_helper = params[:controller] + '_path'
    #path_helper = url_for
    params.permit!

    if column == params[:column]
      link_to(label, url_for(params.merge({ column: column, direction: next_direction })))
      # link_to(label, send(path_helper, params.merge({ column: column, direction: next_direction })))
    else
      link_to(label, url_for(params.merge({ column: column, direction: 'asc' })))
      # link_to(label, send(path_helper, params.merge({ column: column, direction: 'asc' })))
    end
  end

  def next_direction
    params[:direction] == 'asc' ? 'desc' : 'asc'
  end

  def sort_indicator
    tag.div(class: "sort sort-#{params[:direction]}")
  end

  def as(data, to)
    convert_map = {money: number_to_currency(data),
                   nil => data }
    convert_map[to]
  end
end
