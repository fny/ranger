require 'ranger/interval'

module Ranger
  # Left-open, right-closed interval: (x, y]
  class OCInterval
    include Interval

    # @param (see Ranger::Interval#cover?)
    def cover?(value)
      value > left_endpoint && value <= right_endpoint
    end

    def left_closed?
      false
    end

    def right_closed?
      true
    end
  end
end
