module SugarCRM
  # Holds all the associations for a given class
  class Associations
    # Returns an array of Association objects
    class << self
      def register(owner)
        associations = Associations.new
        owner.link_fields.each_key do |link_field|
          associations << Association.new(owner,link_field)
        end
        associations
      end
    end

    attr :associations

    def initialize
      @associations = Set.new
      self
    end

    # Returns the proxy methods of all the associations in the collection
    def proxy_methods
      @associations.inject([]) { |pm,a|
        pm = pm | a.proxy_methods
      }
    end

    # Looks up an association by object, link_field, or method.
    # Raises an exception if not found
    def find!(target, association_field = nil)
      @associations.each do |a|

        if association_field
          association_found = a.include? target
          field_name_match  = a.link_field.to_sym == association_field.to_sym
          return a if association_found &&  field_name_match
        else
          return a if a.include? target
        end
      end
      raise InvalidAssociation, "Could not lookup association for: #{target}"
    end

    # Looks up an association by object, link_field, or method.
    # Returns false if not found
    def find(association)
      begin
        find!(association)
      rescue InvalidAssociation
        false
      end
    end
    alias :include? :find

    # delegate undefined methods to the @collection array
    # E.g. contact.cases should behave like an array and allow `length`, `size`, `each`, etc.
    def method_missing(method_name, *args, &block)
      @associations.send(method_name.to_sym, *args, &block)
    end

    # respond correctly for delegated methods
    def respond_to?(method_name)
      return true if @associations.respond_to? method_name
      super
    end
  end
end
