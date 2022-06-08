class Disentry < ApplicationRecord
  include Filterable

  filter_scope :date_before, :date, -> (date) {where("post_date <= ?", date)}
  filter_scope :date_after, :date, -> (date) {where("post_date >= ?", date)}

end
