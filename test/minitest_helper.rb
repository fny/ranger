$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/reporters'

require 'ranger/all'

reporter_options = { color: true }

# Adds the source of the error to the Minitest output
class Minitest::Reporters::DefaultReporter < Minitest::Reporters::BaseReporter
  def message_for(test)
    e = test.failure
    if test.skipped?
      if @detailed_skip
        "Skipped:\n#{test.class}##{test.name} [#{location(e)}]:\n#{e.message}"
      end
    elsif test.error?
      "Error:\n#{test.class}##{test.name}:\n#{e.message}"
    else
      "Failure:\n#{test.class}##{test.name} [#{test.failure.location}]\n#{e.class}: #{e.message}\n\n  #{get_line(test.failure.location)}"
    end
  end

  private

  def get_line(file_with_line_num)
    file_path, line = file_with_line_num.split(':')
    file = File.open(file_path)
    line.to_i.times { file.gets }
    out = $_
    file.close
    out.strip
  end
end

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]
