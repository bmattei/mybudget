require "application_system_test_case"

class CategoriesTest < ApplicationSystemTestCase
  setup do
    @category = categories(:auto_maintenance)
  end

  test "visiting the index" do
    visit categories_url
    assert_selector "h1", text: "Categories"
  end

  test "should create category" do
    visit categories_url
    click_on "New category"
    name = "tolls"
    fill_in "Name", with: name
    select categories(:transportation).name, from: "category[category_id]"
    click_on "Create Category"

    assert_text "Category was successfully created"
    assert current_url, categories_url
    assert_text name
  end

  test "should update 2nd level category" do
    visit categories_url
    rows = find_all(".table-row")
    category = categories(:auto_gas)
    gas_row = rows.detect {|r| r.text.include?(category.name) and r.text.include?(category.super)}
    gas_row.click_on("edit")
    assert_text category.name
    assert_text category.super
    name = "gasoline"
    new_cat = "misc"
    fill_in "Name", with: name
    select "misc", from: "category[category_id]"
    click_on "Update Category"

    assert_text "Category was successfully updated"
    assert current_url, categories
    assert_text "gasoline"
    rows = find_all(".table-row")
    updated_row = rows.detect {|r| r.text.include?(name) and r.text.include?(new_cat)}
    assert updated_row != nil

  end
  test "should update top level category" do
    visit categories_url
    rows = find_all(".table-row")
    category = categories(:misc)
    misc_row = rows.detect {|r| r.text.include?(category.name) }
    misc_row.click_on("edit")
    assert_text category.name, wait: 100
    assert_text "Category", count: 0
    name = "miscellaneous"

    fill_in "Name", with: name
    click_on "Update Category"

    assert_text "Category was successfully updated"
    assert current_url, categories
    assert_text "miscellaneous"

  end

  test "delete should put up an alert" do
    visit categories_url

    click_on "delete", match: :first
    accept_alert("Are you sure?") do
      click_on 'Cancel'
    end
  end

  test "should destroy Category" do
    skip "Capabara has problems with turbo"
    visit categories_url
    rows = find_all(".table-row")
    count = rows.count
    accept_alert do
      click_on "delete", match: :first
    end
    assert_text "Category was successfully destroyed"
    rows = find_all(".table-row")
    assert_equal rows.count, (count - 1)
    binding.break
    assert current_url, category_url
  end
end
