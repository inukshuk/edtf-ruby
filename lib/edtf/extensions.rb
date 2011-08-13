
class DateTime
  include EDTF::ExtendedDateTime
  include EDTF::Seasons
end

class Date
  include EDTF::ExtendedDateTime
  include EDTF::Seasons
end