# FROM https://github.com/johnmfarrell1/rails_index_filtering/blob/master/app/models/concerns/filterable.rb
#
module Filterable
  extend ActiveSupport::Concern

  included do
    @filter_scopes ||= []
    @filter_types ||= {}
  end

  class_methods do
    attr_reader :filter_scopes, :filter_types

    def filter_scope(name, filter_type, *args)
      scope name, *args
      filter_scopes << name
      filter_types[name] = filter_type
    end

    def filter_by(filtering_params)
      results = all
      filtering_params.each do |filter_scope, filter_value|
        filter_value = filter_value.select(&:present?) if filter_value.is_a?(Array)
        results = results.public_send(filter_scope, filter_value) if filter_value.present?
      end
      results
    end
  end
end
