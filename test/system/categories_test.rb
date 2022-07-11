require "application_system_test_case"

class CategoriesTest < ApplicationSystemTestCase
  setup do
    @category = categories(:auto_maintenance)
  end

  test "visiting the index" do
    visit categories_url
    assert_selector "h1", text: "Categories"
  end

  test "New should put form in first row" do
    visit categories_url
    click_on "New"
    assert_text "Cancel"
    first_row = find(".table-row-group .table-row:first-child")
    assert_match (/http:.*\/categories/) , first_row['action']
  end
  test "should create category" do
    visit categories_url
    click_on "New"
    name = "AAA"
    fill_in "category[name]", with: name
    find(:css, "#category_active").set(true)
    select categories(:transportation).name, from: "category[category_id]"
    click_on "Save"
    assert_text "Category was successfully created"
    assert current_url, categories_url
    assert_text name
  end
  test "Invalid create should display error" do
    visit categories_url
    click_on "New"
    find(:css, "#category_active").set(true)
    select categories(:transportation).name, from: "category[category_id]"
    click_on "Save"
    assert_text "Name can't be blank"
    assert current_url, categories_url
  end
  test "Newly created category should be at top of table" do
    visit categories_url
    click_on "New"
    name = "AAA"
    fill_in "category[name]", with: name
    find(:css, "#category_active").set(true)
    select categories(:transportation).name, from: "category[category_id]"
    click_on "Save"
    assert_text "Category was successfully created"
    first_row = find_all(".table-row-group .table-row").first
    assert_equal "#{name} true #{categories(:transportation).name} Show Edit Delete", first_row.text
  end

  test "should update 2nd level category" do
    visit categories_url
    rows = find_all(".table-row")
    category = categories(:auto_gas)
    gas_row = rows.detect {|r| r.text.include?(category.name) and r.text.include?(category.super)}
    gas_row.click_on("Edit")
    assert_equal category.name, find("#category_name").value
    assert_equal category.super, find('#category_category_id > option[selected="selected"').text
    name = "gasoline"
    new_cat = "misc"
    fill_in "category[name]", with: name
    select "misc", from: "category[category_id]"
    click_on "Save"

    assert_text "Category was successfully updated"
    assert current_url, categories
    assert_text "gasoline"
    rows = find_all(".table-row")
    updated_row = rows.detect {|r| r.text.include?(name) and r.text.include?(new_cat)}
    assert updated_row != nil

  end
  test "should update top level category" do
    visit categories_url
    rows = find_all(".table-row-group .table-row")
    category = categories(:misc)
    misc_row = rows.detect {|r| r.text.include?(category.name) }
    misc_row.click_on("Edit")
    find(:css, "#category_active").set(true)

    assert_equal find("#category_name").value, category.name
    assert_text "Category", count: 0
    name = "miscellaneous"

    fill_in  "category[name]", with: name
    click_on "Save"

    assert_text "Category was successfully updated"
    assert current_url, categories
    assert_text "miscellaneous"

  end

  test "delete should put up an alert" do
    visit categories_url
    skip "BROKEN"
    click_on "Delete", match: :first
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
      click_on "Delete", match: :first
    end
    assert_text "Category was successfully destroyed"
    rows = find_all(".table-row")
    assert_equal rows.count, (count - 1)
    assert current_url, category_url
  end
end
