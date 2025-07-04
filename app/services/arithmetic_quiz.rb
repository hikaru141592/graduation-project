class ArithmeticQuiz
  def self.generate(seed: nil)
    rng = seed ? Random.new(seed.to_i) : Random.new
    operator = [ :+, :* ][rng.rand(0..1)]
    if operator == :+      
      x = rng.rand(101..999)
      y = rng.rand(11..99)
    else
      x = rng.rand(11..99)
      y = rng.rand(2..19)
    end
    question_text = "#{x} #{operator_symbol(operator)} #{y}"
    result = x.public_send(operator, y)
    dummy_result = result + rng.rand(1..9)
    distractors = [ result + 10, result - 10, dummy_result, dummy_result - 10 ].shuffle(random: rng).first(3)
    options = [ result ] + distractors
    [question_text, options]
  end

  def self.operator_symbol(op)
    op == :+ ? "+" : "×"
  end
  private_class_method :operator_symbol
end
