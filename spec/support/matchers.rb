RSpec::Matchers.define :convert do |*from|
  from_description = from
  from_description = nil if from.empty?
  from_description = from.first if from.size == 1
  
  diffable

  define_method :actual do
    @real_actual ||= @actual.call(*from)
  end

  def expected
    [@to]
  end

  match do |method|
    actual == @to
  end

  description do
    "convert #{from_description.inspect} to #{@to.inspect}"
  end

  failure_message_for_should do |method|
    <<MESSAGE
expected #{from_description.inspect}
      to #{@to.inspect}
     got #{actual.inspect}
MESSAGE
  end

  failure_message_for_should_not do |method|
    <<MESSAGE
expected #{from_description.inspect}
  not to #{@to.inspect}
     got #{actual.inspect}
MESSAGE
  end

  chain :to do |to|
    @to = to
  end
end
