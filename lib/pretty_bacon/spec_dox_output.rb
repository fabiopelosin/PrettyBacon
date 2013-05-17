# coding: utf-8

module Bacon

  # Overrides the SpecDoxzRtput to provide colored output by default
  #
  # Based on https://github.com/zen-cms/Zen-Core and subsequently modified
  # which is available under the MIT License. Thanks YorickPeterse!
  #
  module SpecDoxOutput

    def handle_specification(name)
      if @needs_first_put
        @needs_first_put = false
        puts
      end
      @specs_depth = @specs_depth || 0
      puts spaces + name
      @specs_depth += 1

      yield

      @specs_depth -= 1
      puts if @specs_depth.zero?
    end

    #:nodoc:
    def handle_requirement(description, disabled = false)
      start_time = Time.now.to_f
      error = yield
      elapsed_time = ((Time.now.to_f - start_time) * 1000).round

      if !error.empty?
        puts PrettyBacon.color(:red, "#{spaces}- #{description} [FAILED]")
      elsif disabled
        puts PrettyBacon.color(:yellow, "#{spaces}- #{description} [DISABLED]")
      else
        time_color = case elapsed_time
          when 0..200
            :none
          when 200..500
            :yellow
          else
            :red
          end
        puts PrettyBacon.color(:green, "#{spaces}✓ ") + "#{description} " + PrettyBacon.color(time_color, "(#{elapsed_time} ms)")
      end
    end

    #:nodoc:
    def handle_summary
      print ErrorLog  if Backtraces
      unless Counter[:disabled].zero?
        puts PrettyBacon.color(:yellow, "#{Counter[:disabled]} disabled specifications\n")
      end
      puts "%d specifications (%d requirements), %d failures, %d errors" %
        Counter.values_at(:specifications, :requirements, :failed, :errors)
    end

    #:nodoc:
    def spaces
      return '  ' * @specs_depth
    end
  end
end
