# hack for rails 2.1 and below
config.after_initialize do
  unless ActiveRecord::Base.connection.respond_to?(:increment_open_transactions)
    class << ActiveRecord::Base.connection
      def increment_open_transactions
        ActiveRecord::Base.send(:increment_open_transactions)
      end
    end
  end
end