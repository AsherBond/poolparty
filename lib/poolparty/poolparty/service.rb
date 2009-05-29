module PoolParty
  
  class Service < PoolPartyBaseClass
    
    include PoolParty::DependencyResolverCloudExtensions
    
    def to_properties_hash
      { :pp_type => "plugin", :options => dsl_options, 
        # :name => self.class.to_s.top_level_class,
        :resources => ordered_resources.map {|a| a.to_properties_hash }}
    end
    
    def cloud
      2.upto(context_stack.size) do |i|
        return ::PoolParty.context_stack[-i] if ::PoolParty.context_stack[-i].is_a?(PoolParty::Cloud::Cloud)
      end
      nil
    end
    
    def self.add_has_and_does_not_have_methods_for(typ=:file)      
      meth = <<-EOM
        def __#{typ}(opts={}, &block)
          i = ::PoolParty::Plugin::#{typ.camelcase}.new(opts, &block)
          plugin_store << i if respond_to?(:plugin_store)
          i
        end
        alias :#{typ} :__#{typ}
      EOM
      
      PoolParty::PoolPartyBaseClass.module_eval meth
      PoolParty::PoolPartyBaseClass.add_has_and_does_not_have_methods_for(typ.to_sym)
    end
    
  end
  
end

Dir["#{::File.dirname(__FILE__)}/../services/*.rb"].each {|lib| require "#{lib}"}