# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Detect redundant `all` used as a receiver of Active Record query method.
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

        MSG = 'Redundant `all` detected'

        RESTRICT_ON_SEND = [:all].freeze

        # Defined methods in `ActiveRecord::Querying::QUERYING_METHODS` on activerecord 7.0.5.
        QUERYING_METHODS = %i[
          and
          annotate
          any?
          average
          calculate
          count
          create_or_find_by
          create_or_find_by!
          create_with
          delete_all
          delete_by
          destroy_all
          destroy_by
          distinct
          eager_load
          except
          excluding
          exists?
          extending
          extract_associated
          fifth
          fifth!
          find
          find_by
          find_by!
          find_each
          find_in_batches
          find_or_create_by
          find_or_create_by!
          find_or_initialize_by
          find_sole_by
          first
          first!
          first_or_create
          first_or_create!
          first_or_initialize
          forty_two
          forty_two!
          fourth
          fourth!
          from
          group
          having
          ids
          in_batches
          in_order_of
          includes
          invert_where
          joins
          last
          last!
          left_joins
          left_outer_joins
          limit
          lock
          many?
          maximum
          merge
          minimum
          none
          none?
          offset
          one?
          only
          optimizer_hints
          or
          order
          pick
          pluck
          preload
          readonly
          references
          reorder
          reselect
          rewhere
          second
          second!
          second_to_last
          second_to_last!
          select
          sole
          strict_loading
          sum
          take
          take!
          third
          third!
          third_to_last
          third_to_last!
          touch_all
          unscope
          update_all
          where
          without
        ].freeze

        def on_send(node)
          return if node.receiver.nil? && !inherit_active_record_base?(node)

          query_node = node.parent
          return unless QUERYING_METHODS.include?(query_node.method_name)

          all_range = node.loc.selector
          add_offense(all_range) do |collector|
            collector.remove(all_range)
            collector.remove(query_node.loc.dot)
          end
        end
      end
    end
  end
end
