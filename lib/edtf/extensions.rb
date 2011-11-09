
class Range
	
	def edtf
		[
			self.begin.respond_to?(:edtf) ? self.begin.edtf : self.begin.to_s,
			self.end.respond_to?(:edtf) ? self.end.edtf : self.end.to_s
		].join(exclude_end? ? '...' : '..')
	end
	
end