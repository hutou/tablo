require "debug"

# You can use `debug!(...)` in expressions:
def factorial(n : Int)
  return debug!(1) if debug!(n <= 1)
  debug!(n * factorial(n - 1))
end

message = "hello"
debug!(message)

a = 2
b = debug!(3 * a) + 1

numbers = {b, 13, 42}
debug!(numbers)

debug!("this line is executed")

factorial(4)
