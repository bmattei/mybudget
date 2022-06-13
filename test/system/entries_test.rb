require "application_system_test_case"

class EntriesTest < ApplicationSystemTestCase
  INFLOW_IDX = 5
  OUTFLOW_IDX = 6
  setup do
    @entry = entries(:discover_init)
    @account = accounts(:discover)
  end
end
