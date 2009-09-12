module GMoney
	class Transaction
		attr_reader :id, :updated, :title

		attr_accessor :type, :date, :shares, :notes, :commission, :price
	end
end
