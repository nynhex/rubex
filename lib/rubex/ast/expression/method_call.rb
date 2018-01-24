module Rubex
  module AST
    module Expression

      class MethodCall < Base
        attr_reader :method_name, :type

        def initialize(invoker, method_name, arg_list)
          @method_name = method_name
          @invoker = invoker
          @arg_list = arg_list
        end

        # local_scope - is the local method scope.
        def analyse_types(local_scope)
          @entry = local_scope.find(@method_name)
          if method_not_within_scope? local_scope
            raise Rubex::NoMethodError, "Cannot call #{@name} from this method."
          end
          super
        end

        def generate_evaluation_code(code, local_scope); end

        def generate_disposal_code(code); end

        private

        def type_check_arg_types(entry)
          @arg_list.map!.with_index do |arg, idx|
            Helpers.to_lhs_type(entry.type.base_type.arg_list[idx], arg)
          end
        end

        # Checks if method being called is of the same type of the caller. For
        # example, only instance methods can call instance methods and only
        # class methods can call class methods. C functions are accessible from
        # both instance methods and class methods.
        #
        # Since there is no way to determine whether methods outside the scope
        # of the compiled Rubex file are singletons or not, Rubex will assume
        # that they belong to the correct scope and will compile a call to those
        # methods anyway. Error, if any, will be caught only at runtime.
        def method_not_within_scope?(local_scope)
          caller_entry = local_scope.find local_scope.name
          if (caller_entry.singleton? &&  @entry.singleton?) ||
            (!caller_entry.singleton? && !@entry.singleton?) ||
            @entry.c_function?
            false
          else
            true
          end
        end
      end # class MethodCall
    end
  end
end
