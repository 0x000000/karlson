module Kernel
  def __k__without_warnings__
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end
end

module Karlson
  module Readers
    class EmptyObject < BasicObject
      def initialize(*args)
        @fields ||= []
        @fields.push [:initialize, args] if args.size > 0
      end

      def method_missing(*args)
        first_arg = args[0]

        case first_arg
        when ::Symbol
          @fields.push [first_arg, args[1..-1]]
        when ::Integer
          @fields.push [:method_missing, args]
        else
          #unsupported
        end
      end

      def __id__(*args)
        @fields.push [:__id__, args] if args.size > 0
        super()
      end

      ::Kernel.__k__without_warnings__ do
        def __send__(*args)
          first_arg = args[0]

          case first_arg
          when ::Symbol
            super
          when ::Integer
            @fields.push [:__send__, args]
          else
            #unsupported
          end
        end
      end

      def instance_eval(*args, &block)
        if block
          super &block
        elsif args.size > 0
          @fields.push [:instance_eval, args]
        end
      end

      def instance_exec(*args)
        @fields.push [:instance_exec, args] if args.size > 0
        args
      end

      def singleton_method_added(*args)
        @fields.push [:singleton_method_added, args] if args.size > 0
      end

      def singleton_method_removed(*args)
        @fields.push [:singleton_method_removed, args] if args.size > 0
      end

      def singleton_method_undefined(*args)
        @fields.push [:singleton_method_undefined, args] if args.size > 0
      end
    end
  end
end
