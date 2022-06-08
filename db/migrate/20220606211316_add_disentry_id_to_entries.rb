class AddDisentryIdToEntries < ActiveRecord::Migration[7.0]
  def change
    add_reference :entries, :disentry, foreign_key: true
  end
end
