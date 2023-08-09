require "spec"

require "../src/tablo"
require "debug"

class Numbers
  include Enumerable(Int32)

  def each(&)
    # yield 0
    yield 1
    yield 7
    yield 10
    yield 13
    yield 42
    yield 43
    yield 59
    yield 66
  end
end
