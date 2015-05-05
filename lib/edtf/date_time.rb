class DateTime

  def edtf
    date = super

    time =  strftime('%H:%M:%S')
    time << strftime('%Z') unless skip_timezone?

    [date, time].join('T')
  end

  alias to_edtf edtf

  def values
    super().concat([hour,minute,second,offset])
  end

end
