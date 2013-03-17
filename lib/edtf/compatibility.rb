
class DateTime
  def iso8601
    to_time.iso8601
  end unless method_defined?(:iso8601)
end
