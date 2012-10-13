module Fe
  module FactoryGirlDslMethods
    def fe_factory(name, options = {})
      unless extract_name = options.delete(:extract_name)
        raise "Must specify extract_name (the fixture set name)"
      end
      unless fixture_name = options.delete(:fixture_name)
        raise "Must specify fixture_name" # TODO:Later, make this default to :first once impelmented in Fe
      end
      unless options.has_key?(:class)
        raise "Must specify the class when using with iron fixture extractor"
      end

      # CONTINUE HERE.  We need to figure out how to build a
      # block for Factory girl from the hash that lives in the yaml.
      #
      fe_hash = Fe.get_hash(extract_name, options[:class],fixture_name)

      the_block = Proc.new {
      }

      factory(name,options,&the_block)

      factory_inst = ::FactoryGirl.factory_by_name(name)
      # require 'debugger'; debugger; puts 'DSLExt'
    end
  end
end
