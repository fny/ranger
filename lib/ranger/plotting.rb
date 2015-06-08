require 'ranger/interval'

puts "WARNING: `Ranger::Plotter` IS NOT INTENDED FOR PUBLIC CONSUMPTION"
puts "PROCEED AT YOUR OWN RISK. Specifically..."
puts " - The API is atrocious"
puts " - It's buggy as hell"
puts " - Semantic versioning does not apply"

# :nocov:
module Ranger
  # @private
  # Used to generate the map visualizations in the docs.
  #
  # Please forgive the insane code.
  module Plotting
    class IntervalPlot
      OPEN_MARKER = 'o'
      CLOSED_MARKER = 'x'
      attr_accessor :interval, :number_length, :interval_padding, :result_padding, :return_value, :spaces_to_start_of_interval

      def initialize(interval, number_length: 3, interval_padding: nil, result_padding: 0)
        @interval = interval
        @number_length = number_length
        @interval_padding = interval_padding ||
        @result_padding = result_padding
      end

      def interval_padding
        @interval_padding || (left_infinite? ? 1 : interval_str.length + 7)
      end

      def interval_str_size
        interval_str.size
      end

      def interval_str
        interval.to_s.gsub('Intv', '').gsub('Infinity', '∞')
      end

      def interval__
        interval_str.ljust(interval_padding)
      end

      def interval_start_marker
        interval.left_closed? ? CLOSED_MARKER : OPEN_MARKER
      end

      def interval_stop_marker
        interval.right_closed? ? CLOSED_MARKER : OPEN_MARKER
      end

      def spaces_to_start_of_interval
        if interval.left_endpoint.abs == Float::INFINITY
          ' '
        else
          ' ' * (@spaces_to_start_of_interval || (interval.left_endpoint * 3)+ 5)
        end
      end

      def interval_length_dashes
        if left_infinite? || right_infinite?
          '-...-'
        else
          '-' * (number_length * interval_length - 1)
        end
      end

      def left_infinite?
        interval.left_endpoint.abs == Float::INFINITY
      end

      def right_infinite?
        interval.right_endpoint == Float::INFINITY
      end

      def interval_length
        interval.right_endpoint - interval.left_endpoint
      end

      def finite?
        !left_infinite? && !right_infinite?
      end

      def middle_value(interval)
        lookup =
          if right_infinite?
            10000
          elsif left_infinite?
            -10000
          else
            interval.left_endpoint + 0.01
          end
        interval[lookup]
      end

      def output
        main = "#{interval__}#{spaces_to_start_of_interval}#{interval_start_marker}#{interval_length_dashes}#{interval_stop_marker}"
        "#{main.ljust(result_padding + 1, ' ')} # =>"
      end
    end

    class IntervalPlotter
      attr_accessor :intervals, :number_length
      def initialize(*intervals)
        @number_length = 3
        @intervals = intervals
      end

      def self.print_header(range, max_intv_length: 7, number_length: 3)
        start_spaces = ' ' * max_intv_length
        out = "#{start_spaces}-∞     "
        range.each do |n|
          out << "#{n}".ljust(number_length, ' ')
        end
        out <<"  -∞"
        out
      end

      def min
        @intervals.map(&:endpoints).flatten.reject { |x| x.abs == Float::INFINITY }.min
      end

      def max
        @intervals.map(&:endpoints).flatten.reject { |x| x == Float::INFINITY }.max
      end

      def max_plot_interval_str_size
        plots.map(&:interval_str_size).max
      end

      def plots
        @plots ||= @intervals.map { |interval| IntervalPlot.new(interval) }
      end

      def header
        @header ||= IntervalPlotter.print_header(min..max, max_intv_length: max_plot_interval_str_size, number_length: number_length)
      end

      def plot_strs
        plots.map { |plot|
          plot.number_length = number_length
          if plot.finite?
            plot.interval_padding = plot.interval_length - min - 10
          end
          if !plot.left_infinite?
            plot.spaces_to_start_of_interval = 3 * (plot.interval.left_endpoint - min) + 8
          end
          plot.result_padding = header.size;
          plot.output
        }
      end

      def print
        puts header
        puts plot_strs
      end
    end

  end
end
# :nocov:
