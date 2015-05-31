class Ctrl
  class << self
    def interceptors interceptor, methods
      @__methods ||= {}
      @__methods[interceptor] = methods
    end

    def method_added name
      return unless @__methods
      return if @__last_methods_added && @__last_methods_added == name

      @__methods.each do |interceptor, methods|
        next unless methods.include? name

        origin = :"origin_#{name}"
        alias_method origin, name

        @__last_methods_added = name

        define_method name do |*args|
          interrupt = send(interceptor, args[0])

          if interrupt
            interrupt
          else
            send(origin, *args)
          end
        end

        @__last_methods_added = nil
      end
    end
  end

  def method_missing method, *args, &block
    ["Not found method", 404]
  end
end