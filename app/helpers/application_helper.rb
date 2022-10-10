module ApplicationHelper
  include Pagy::Frontend
  def sort_link(label, column)
    #path_helper = params[:controller] + '_path'
    #path_helper = url_for
    params.permit!

    if column == params[:column]
      sort_indicator(label) +
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

  def sort_indicator(label)
    class_str = "float-right relative top-5 object-right h-0 w-0 border-x-8 border-x-transparent border-blue-600"

    if next_direction == 'asc'
      class_str += " border-b-8"
    else
      class_str += " border-t-8"
    end

      tag.div(class: class_str)

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
