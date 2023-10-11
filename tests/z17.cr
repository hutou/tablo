module CellType
end

# class Array
#   include Tablo::CellType
# end

# ary = [1, -4, 8, nil, "abc", -33, 42]
# ar = ary.select &.is_a?(Number)
# p! ar

struct Int32
  include CellType
end

struct Float64
  include CellType
end

struct Nil
  include CellType
end

class String
  include CellType
end

ary : Array(Array(CellType)) = [[1.as(CellType),
                                 -4.as(CellType),
                                 8.2.as(CellType),
                                 nil.as(CellType)],
                                ["abc".as(CellType),
                                 -33.4.as(CellType),
                                 42.as(CellType)]]

ary.each do |a|
  a.each do |e|
    p! typeof(e)
    p! e.class
    p! ""
  end
end

ar = ary[0].select &.is_a?(Number)
# ar = ary.select(Int32 || Float64)
p! ar
