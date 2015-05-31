# class Ctrl
#   class << self
#     def interceptors (*arguments)

#       interceptor = arguments.shift

#       arguments.each do |method|
#         origin = :"origin_#{method}"
#         alias_method origin, method

#         define_method method do |*args|
#           interrupt = send(interceptor)

#           if interrupt
#             interrupt
#           else
#             send(origin, *args)
#           end
#         end
#       end
#     end
#   end
# end

class Ctrl
  class << self
    def interceptors interceptor, settings
      @__methods ||= {}

      @__methods[interceptor] = {
        :methods => settings[:only]
      }
    end

    def method_added name
      return if @__last_methods_added && @__last_methods_added == name

      @__methods.each do |interceptor, v|
        next unless v[:methods].include? name

        origin = :"origin_#{name}"
        alias_method origin, name

        @__last_methods_added = name

        define_method name do |*args|
          interrupt = send(interceptor)

          if interrupt
            interrupt
          else
            send(origin, *args)
          end
        end

        @__last_methods_added = nil
        # p "#{interceptor} interceptor for #{name}"
      end
    end
  end
end

class Test < Ctrl

  interceptors :access, only:[:yo, :hui]
  # interceptors :lol, only: [:bar]

  def yo
    "yo yo"
  end

  def hui name
    "hui hui hui #{name}"
  end

  def foo
    "FOoooooooooooo"
  end

  def bar
    "baaaaaar"
  end

  # interceptors(:access, :yo, :hui)

  private
  def access
    "Denied"
  end
end

t = Test.new

p t.yo
p t.hui "Shnur"
p t.foo
