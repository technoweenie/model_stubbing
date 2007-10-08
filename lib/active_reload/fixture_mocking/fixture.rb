module ActiveReload
  module FixtureMocking
    class Fixture
      attr_reader   :table
      attr_reader   :attributes
      attr_accessor :name
      
      def initialize(table, name, attributes)
        @table      = table
        @name       = name
        @attributes = 
          if default?
            attributes
          else
            table.default.attributes.merge(attributes)
          end
      end
      
      def default?
        @name == :default
      end
      
      def record(attributes = {})
        attributes.empty? && @table.records.key?(self) ? retrieve : instantiate(attributes)
      end
      
      def inspect
        "FixtureMocking::Fixture(#{@name.inspect} => #{attributes.inspect})"
      end
      
      private
        def instantiate(attributes)
          stubs = {}
          default_record = attributes.empty?
          
          @attributes.each do |key, value|
            stubs[key] = value if value.is_a?(Fixture)
          end
          
          attributes.each do |key, value|
            case value
              when Fixture
                stubs[key] = attributes.delete(key)
              when Hash
                stubs[key] = stubs[key].record(value)
            end
          end

          attributes = @attributes.merge(attributes)

          record = @table.model.new(attributes)
          meta   = class << record ; self ; end
          
          meta.send :attr_accessor, :id
          record.id = @table.model.mock_id

          stubs.each do |key, value|
            meta.send :attr_accessor, key
            record.send("#{key}=", value.is_a?(Fixture) ? value.record : value)
          end
          
          @table.records[self] = record if default_record
          record
        end
        
        def retrieve
          @table.records[self]
        end
    end
  end
end