require "parslet"

class Parser < Parslet::Parser
 root :expression

 rule :expression do
   infix | integer
 end

 rule :infix do
   integer.as(:left) >> space >> operator.as(:operator) >> space >>
     expression.as(:right)
 end

 rule :integer do
   digit.repeat(1).as(:integer)
 end

 rule :digit do
   match(/\d/)
 end

 rule :space do
   str(" ")
 end

 rule :operator do
   addition | multiplication
 end

 rule :addition do
   str("+").as(:addition)
 end

 rule :multiplication do
   str("*").as(:multiplication)
 end
end

IntegerLiteral = Struct.new(:string) do
  def eval
    Integer(string)
  end
end

Multiplication = Struct.new(:left, :right) do
  def eval
    left.eval * right.eval
  end
end

Addition = Struct.new(:left, :right) do
  def eval
    left.eval + right.eval
  end
end

class Transform < Parslet::Transform
  rule integer: simple(:integer) do
    IntegerLiteral.new(integer)
  end

  rule multiplication: simple(:addition) do
    Multiplication
  end

  rule addition: simple(:addition) do
    Addition
  end

  rule(
    left: simple(:left),
    operator: simple(:operator),
    right: simple(:right),
  ) do
    operator.new(left, right)
  end
end

parser = Parser.new
tree = p parser.parse("1 + 2 * 3")
transform = Transform.new
ast = p transform.apply(tree)
p ast.eval
