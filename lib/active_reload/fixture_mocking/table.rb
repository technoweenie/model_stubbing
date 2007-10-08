module ActiveReload
  module FixtureMocking
    class Table
      attr_reader   :definition
      attr_accessor :name
      attr_accessor :plural
      attr_accessor :singular
      attr_reader   :fixtures
      attr_reader   :records

      def fixture(name = nil, options = {})
        if name.is_a?(Hash)
          options = name
          name    = :default
        end

        global_key = (name == :default ? @singular : "#{name}_#{@singular}").to_sym
        all_fixtures[global_key] = @fixtures[name] = Fixture.new(self, name, options)
      end

      def initialize(definition, name, options = {}, &block)
        @definition = definition
        @name       = name
        @plural     = options[:plural]   || name
        @singular   = options[:singular] || name.to_s.singularize
        @model      = options[:model]
        @fixtures   = {}
        @records    = {}
        instance_eval &block if block
      end
      
      def model
        if @model.nil?
          @model = name.to_s.classify.constantize
          unless @model.respond_to?(:mock_id)
            class << @model
              define_method :mock_id do
                @mock_id ||= 999
                @mock_id  += 1
              end
            end
          end
        end
        @model
      end
      
      def default
        @fixtures[:default]
      end
      
      def current_time
        @definition.current_time
      end
      
      def all_fixtures(key = nil)
        key ? @definition.fixtures[key] : @definition.fixtures
      end

      def retrieve_record(key, attributes = {})
        @fixtures[key].record(attributes)
      end
      
      def fixture_method_definition
        "def #{@plural}(key, attributes = {}) self.class.definition.tables[#{@plural.inspect}].retrieve_record(key, attributes) end"
      end

      def inspect
        "FixtureMocking::Table(#{@name.inspect} => [#{@fixtures.keys.collect { |k| k.to_s }.sort.join(", ")}])"
      end
    end
  end
end