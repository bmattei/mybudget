module ApplicationHelper
  include Pagy::Frontend
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
    case to
    when :money
      number_to_currency(data)
    when :date
      "#{data.year}/#{data.month}/#{data.day}"
    else
      data
    end
  end
end
