require 'ranger/interval'

module Ranger
  # Left-closed, right-open interval: [x, y)
  class COInterval
    include Interval

    # @param (see Ranger::Interval#cover?)
    def cover?(value)
      value >= left_endpoint && value < right_endpoint
    end

    def left_closed?
      true
    end

    def right_closed?
      false
    end
  end
end
