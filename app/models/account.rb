class Account < ApplicationRecord
  validates :bank, :name, :number, presence:true
  validates :name, uniqueness:true
  validates :number, uniqueness: {scope: :bank}

end
