require 'ranger/interval'

module Ranger
  # Left-closed, right-closed interval: [x, y]
  class CCInterval
    include Interval

    # @param (see Ranger::Interval#cover?)
    def cover?(value)
      value >= left_endpoint && value <= right_endpoint
    end

    def left_closed?
      true
    end

    def right_closed?
      true
    end
  end
end
