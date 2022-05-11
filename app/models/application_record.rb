class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.filter_by(filters)
    re = /(.*)_(begins|ends|contains|matches|between)/
    filter = all
    filters.each_pair do |key, value|
      if value.length > 0
        re.match(key)
        column = Regexp.last_match(1)
        verb = Regexp.last_match(2)
        case verb
        when 'matches'
          filter = filter.where("#{column} = ?)", value)
        when 'begins'
          filter = filter.where("#{column} like ?", "#{value}%")
        when 'ends'
          filter = filter.where("#{column} like ?", "%#{value}")
        when 'between'
          filter = filter.where("#{column} >= ? and #{column} <= ?", value[0], value[1])
        when 'contains'
          filter = filter.where("#{column} like ?", "%#{value}%")
        end
      end
    end
   return filter
  end


end
