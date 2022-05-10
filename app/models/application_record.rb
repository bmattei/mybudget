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
          filter = filter.where("lower(#{column}) = ?)", value.downcase)
        when 'begins'
          filter = filter.where("lower(#{column}) like ?", "#{value.downcase}%")
        when 'ends'
          filter = filter.where("lower(#{column}) like ?", "%#{value.downcase}")
        when 'between'
          filter = filter.where("#{column} >= ? and #{column} <= ?", value[0], value[1])
        when 'contains'
          filter = filter.where("lower(#{column}) like ?", "%#{value.downcase}%")
        end
      end
    end
   return filter
  end


end
