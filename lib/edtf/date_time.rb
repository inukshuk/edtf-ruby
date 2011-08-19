class DateTime
  def to_edtf
    super
  end    

  def values
    super + [hour,minute,second,offset]
  end
end
