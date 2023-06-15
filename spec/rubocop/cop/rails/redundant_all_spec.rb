# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RedundantAll, :config do
  shared_examples 'register_offense_and_correct' do |source|
    it "registers an offense and corrects when using .all.#{source}" do
      expect_offense(<<~RUBY)
        User.all.#{source}
             ^^^ Redundant `all` detected
      RUBY

      expect_correction(<<~RUBY)
        User.#{source}
      RUBY
    end
  end

  sources = [
    'and(Use.where(age: 30))',
    'annotate("selecting id")',
    'any?',
    'average(:age)',
    'calculate(:average, :age)',
    'count',
    'create_or_find_by(name: name)',
    'create_or_find_by!(name: name)',
    'create_with(name: name)',
    'delete_all',
    'delete_by(id: id)',
    'destroy_all',
    'destroy_by(id: id)',
    'distinct',
    'eager_load(:posts)',
    'except(:order)',
    'excluding(user)',
    'exists?',
    'extending(Pagination)',
    'extract_associated(:posts)',
    'fifth',
    'fifth!',
    'find(id)',
    'find_by(name: name)',
    'find_by!(name: name)',
    'find_each(&:x)',
    'find_in_batches(&:x)',
    'find_or_create_by(name: name)',
    'find_or_create_by!(name: name)',
    'find_or_initialize_by(name: name)',
    'find_sole_by(name: name)',
    'first',
    'first!',
    'first_or_create(name: name)',
    'first_or_create!(name: name)',
    'first_or_initialize(name: name)',
    'forty_two',
    'forty_two!',
    'fourth',
    'fourth!',
    'from("users")',
    'group(:age)',
    'having("AVG(age) > 30")',
    'ids',
    'in_batches(&:x)',
    'in_order_of(:id, ids)',
    'includes(:posts)',
    'invert_where',
    'joins(:posts)',
    'last',
    'last!',
    'left_joins(:posts)',
    'left_outer_joins(:posts)',
    'limit(n)',
    'lock',
    'many?',
    'maximum(:age)',
    'merge(users)',
    'minimum(:age)',
    'none',
    'none?',
    'offset(n)',
    'one?',
    'only(:order)',
    'optimizer_hints("SeqScan(users)", "Parallel(users 8)")',
    'or(Use.where(age: 30))',
    'order(:created_at)',
    'pick(:id)',
    'pluck(:age)',
    'preload(:posts)',
    'readonly',
    'references(:posts)',
    'reorder(:created_at)',
    'reselect(:age)',
    'rewhere(id: ids)',
    'second',
    'second!',
    'second_to_last',
    'second_to_last!',
    'select(:age)',
    'sole',
    'strict_loading',
    'sum(:age)',
    'take(n)',
    'take!(n)',
    'third',
    'third!',
    'third_to_last',
    'third_to_last!',
    'touch_all',
    'unscope',
    'update_all(name: name)',
    'where(id: ids)',
    'without(user)'
  ]

  describe '::QUERYING_METHODS' do
    it 'contains all of the querying methods' do
      methods = sources.map { |s| s.split('(')[0].to_sym }
      expect(described_class::QUERYING_METHODS).to eq(methods)
    end
  end

  context 'with receiver' do
    sources.each do |source|
      it_behaves_like 'register_offense_and_correct', source
    end
  end

  context 'with no receiver' do
    it 'does not register an offense when not inheriting any class' do
      expect_no_offenses(<<~RUBY)
        class C
          all.order(:created_at)
        end
      RUBY
    end

    it 'does not register an offense when not inheriting `ApplicationRecord`' do
      expect_no_offenses(<<~RUBY)
        class C < Foo
          all.order(:created_at)
        end
      RUBY
    end

    it 'registers an offense when inheriting `ApplicationRecord`' do
      expect_offense(<<~RUBY)
        class C < ApplicationRecord
          all.order(:created_at)
          ^^^ Redundant `all` detected
        end
      RUBY
    end

    it 'registers an offense when inheriting `::ApplicationRecord`' do
      expect_offense(<<~RUBY)
        class C < ::ApplicationRecord
          all.order(:created_at)
          ^^^ Redundant `all` detected

        end
      RUBY
    end

    it 'registers an offense when inheriting `ActiveRecord::Base`' do
      expect_offense(<<~RUBY)
        class C < ActiveRecord::Base
          all.order(:created_at)
          ^^^ Redundant `all` detected
        end
      RUBY
    end

    it 'registers an offense when inheriting `::ActiveRecord::Base`' do
      expect_offense(<<~RUBY)
        class C < ::ActiveRecord::Base
          all.order(:created_at)
          ^^^ Redundant `all` detected
        end
      RUBY
    end
  end
end
