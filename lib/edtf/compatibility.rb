
class DateTime
  def iso8601
    to_time.iso8601
  end unless method_defined?(:iso8601)
end

class Object
  def <=>(other)
    self === other ? 0 : nil
  end unless method_deined?(:'<=>')
end
