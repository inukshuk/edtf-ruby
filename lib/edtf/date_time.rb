class DateTime

  alias edtf iso8601
  alias to_edtf edtf

  def values
    super().concat([hour,minute,second,offset])
  end
end
