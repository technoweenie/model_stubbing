module ActiveReload
  module FixtureMocking
    class Definition
      attr_reader :current_time
      attr_reader :tables
      attr_reader :fixtures

      def time(*args)
        @current_time = Time.utc(*args)
      end
      
      def table(table_name, options = {}, &block)
        @tables[table_name] = Table.new(self, table_name, options, &block)
      end
      
      def initialize(&block)
        @tables   = {}
        @fixtures = {}
        instance_eval &block if block
      end
      
      def setup_on(klass)
        klass.class_eval do
          def fixtures(key, attributes = {})
            self.class.definition.retrieve_record(key, attributes)
          end
        end
        klass.class_eval tables.values.collect { |table| table.fixture_method_definition }.join("\n")
        (class << klass ; self ; end).send :attr_accessor, :definition
        klass.definition = self
      end
      
      def retrieve_record(key, attributes = {})
        @fixtures[key].record(attributes)
      end
      
      def inspect
        "FixtureMocking::Definition(:tables => [#{@tables.keys.collect { |k| k.to_s }.sort.join(", ")}])"
      end
    end
  end
end