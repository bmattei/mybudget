json.extract! entry, :id, :account_id, :entry_date, :check_number, :payee, :amount, :transfer_account_id, :transfer_entry_id, :category_id, :created_at, :updated_at
json.url entry_url(entry, format: :json)
