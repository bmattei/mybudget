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
    select categories(:transportation).name, from: "category[parent_id]"
    click_on "Save"
    assert_text "Category was successfully created"
    assert current_url, categories_url
    assert_text name
  end
  test "Invalid create should display error" do
    visit categories_url
    click_on "New"
    find(:css, "#category_active").set(true)
    select categories(:transportation).name, from: "category[parent_id]"
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
    select categories(:transportation).name, from: "category[parent_id]"
    click_on "Save"
    assert_text "Category was successfully created"
    first_row = find_all(".table-row-group .table-row").first
    assert_match "#{name} true #{categories(:transportation).name}", first_row.text
  end

  test "should update 2nd level category" do
    visit categories_url
    category = categories(:auto_gas)
    name_field = find("#category_#{category.id}")
    new_name = "gasoline"
    new_cat = "misc"
    name_field.click
    name_field.fill_in(with: new_name)
    select new_cat, from: "category[parent_id]"
    click_on "Save"
    assert_text "Category was successfully updated"
    assert current_url, categories
    assert_text "gasoline"
    rows = find_all(".table-row")
    updated_row = rows.detect {|r| r.text.include?(new_name) and r.text.include?(new_cat)}
    assert updated_row != nil

  end
  test "should update top level category" do
    visit categories_url
    category = categories(:misc)
    find("#category_#{category.id}").click
    new_name = "miscellaneous"
    fill_in  "category[name]", with: new_name
    find("#category_active").click
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
