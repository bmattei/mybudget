json.extract! account, :id, :name, :number, :bank, :has_checking, :created_at, :updated_at
json.url account_url(account, format: :json)
