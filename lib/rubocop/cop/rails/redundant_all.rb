# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for `all` used as receiver in Active Record query method.
      #
      # @safety
      #   This cop is unsafe if the receiver object is not an Active Record object.
      #
      # @example
      #   # bad
      #   User.all.order(:created_at)
      #   User.all.find(:id)
      #
      #   # good
      #   User.order(:created_at)
      #   User.find(:id)
      class RedundantAll < Base
        include ActiveRecordHelper
        extend AutoCorrector

        MSG = 'Use `.%<query_method>s(...)` instead of `.all.%<query_method>s(...)`'

        RESTRICT_ON_SEND = [:all].freeze
        QUERY_METHODS = %i[find find_by order where].freeze

        def on_send(node)
          return if node.receiver.nil? && !inherit_active_record_base?(node)

          query_node = node.parent
          return unless QUERY_METHODS.include?(query_node.method_name)

          all_range = node.loc.selector
          add_offense(all_range, message: format(MSG, query_method: query_node.method_name)) do |collector|
            collector.remove(all_range)
            collector.remove(query_node.loc.dot)
          end
        end
      end
    end
  end
end
