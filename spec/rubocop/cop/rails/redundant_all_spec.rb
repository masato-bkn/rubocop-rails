# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RedundantAll, :config do
  shared_examples 'register_offense_and_correct' do |source|
    it "registers an offense and correct when .all.#{source}" do
      offense_method = source.split('(')[0]

      expect_offense(<<~RUBY)
        User.all.#{source}
             ^^^ Use `.#{offense_method}(...)` instead of `.all.#{offense_method}(...)`
      RUBY

      expect_correction(<<~RUBY)
        User.#{source}
      RUBY
    end
  end

  it_behaves_like 'register_offense_and_correct', 'find(id)'
  it_behaves_like 'register_offense_and_correct', 'find_by(:name)'
  it_behaves_like 'register_offense_and_correct', 'order(:created_at)'
  it_behaves_like 'register_offense_and_correct', 'where(id: ids)'

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
          ^^^ Use `.order(...)` instead of `.all.order(...)`
        end
      RUBY
    end

    it 'registers an offense when inheriting `::ApplicationRecord`' do
      expect_offense(<<~RUBY)
        class C < ::ApplicationRecord
          all.order(:created_at)
          ^^^ Use `.order(...)` instead of `.all.order(...)`

        end
      RUBY
    end

    it 'registers an offense when inheriting `ActiveRecord::Base`' do
      expect_offense(<<~RUBY)
        class C < ActiveRecord::Base
          all.order(:created_at)
          ^^^ Use `.order(...)` instead of `.all.order(...)`
        end
      RUBY
    end

    it 'registers an offense when inheriting `::ActiveRecord::Base`' do
      expect_offense(<<~RUBY)
        class C < ::ActiveRecord::Base
          all.order(:created_at)
          ^^^ Use `.order(...)` instead of `.all.order(...)`
        end
      RUBY
    end
  end
end
