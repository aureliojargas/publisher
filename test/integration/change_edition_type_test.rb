require 'integration_test_helper'

class ChangeEditionTypeTest < JavascriptIntegrationTest
  setup do
    panopticon_has_metadata("id" => "2356")
    stub_collections
    %w(Alice Bob Charlie).each do |name|
      FactoryGirl.create(:user, name: name)
    end
  end

  teardown do
    GDS::SSO.test_user = nil
  end

  # tests for changing Guide, Programme and Transaction into Answer

  test "should be able to convert a GuideEdition into an AnswerEdition" do
    guide = FactoryGirl.create(:guide_edition, state: 'published')
    visit_edition guide

    within "div.tabbable" do
      click_on "Admin"
    end

    assert page.has_button?("Create as new Answer edition")

    click_on "Create as new Answer edition"

    assert page.has_content?(guide.title)
    assert page.has_content?("New edition created")
    assert page.has_content?(guide.whole_body)
  end

  test "should be able to convert a LicenceEdition into an AnswerEdition" do
    licence = FactoryGirl.create(:licence_edition, state: 'published', licence_overview: "Licence overview content", licence_short_description: "Short description content")
    visit_edition licence

    within "div.tabbable" do
      click_on "Admin"
    end

    assert page.has_button?("Create as new Answer edition")

    click_on "Create as new Answer edition"

    assert page.has_content?(licence.title)
    assert page.has_content?("New edition created")

    assert_field_contains("Licence overview content", "Body")
    assert_field_contains("Short description content", "Body")
  end

  test "should be able to convert a ProgrammeEdition into an AnswerEdition" do
    programme = FactoryGirl.create(:programme_edition, state: 'published')
    visit_edition programme

    within "div.tabbable" do
      click_on "Admin"
    end

    assert page.has_button?("Create as new Answer edition")

    click_on "Create as new Answer edition"

    assert page.has_content?(programme.title)
    assert page.has_content?("New edition created")

    assert_field_contains("Overview", "Body")
    assert_field_contains("What you'll get", "Body")
    assert_field_contains("Eligibility", "Body")
    assert_field_contains("How to claim", "Body")
    assert_field_contains("Further information", "Body")
  end

  test "should be able to convert a TransactionEdition into an AnswerEdition" do
    transaction = FactoryGirl.create(:transaction_edition, slug: "childcare", state: 'published')
    visit_edition transaction

    within "div.tabbable" do
      click_on "Admin"
    end

    assert page.has_button?("Create as new Answer edition")

    click_on "Create as new Answer edition"

    assert page.has_content?(transaction.title)
    assert page.has_content?("New edition created")
    assert_field_contains(transaction.more_information, "Body")
    assert_field_contains(transaction.alternate_methods, "Body")
  end

  test "should be able to convert a SimpleSmartAnswerEdition into an AnswerEdition" do
    simple_smart_answer = FactoryGirl.create(:simple_smart_answer_edition, state: 'published')
    visit_edition simple_smart_answer

    within "div.tabbable" do
      click_on "Admin"
    end

    assert page.has_button?("Create as new Answer edition")

    click_on "Create as new Answer edition"

    assert page.has_content?(simple_smart_answer.title)
    assert page.has_content?("Introduction to the smart answer")
    assert page.has_content?("New edition created")
  end

# tests for changing Answer, Guide, Programme into a Transaction

  test "should be able to convert an AnswerEdition into a TransactionEdition" do
    answer = FactoryGirl.create(:answer_edition, state: 'published')
    visit_edition answer

    within "div.tabbable" do
      click_on "Admin"
    end

    assert page.has_button?("Create as new Transaction edition")

    click_on "Create as new Transaction edition"

    assert page.has_content?(answer.title)
    assert page.has_content?("New edition created")
    assert page.has_content?("Introductory paragraph")
    assert page.has_content?("Will continue on")
    assert page.has_content?("Link to start of transaction")
    assert page.has_content?("More information")

    within :css, '#edition_more_information_input' do
      assert page.has_xpath?("//textarea[contains(text(), '#{answer.whole_body}')]"), "Expected to see: #{answer.whole_body}"
    end

  end

  test "should be able to convert an AnswerEdition into a SimpleSmartAnswerEdition" do
    answer = FactoryGirl.create(:answer_edition, state: 'published', body: "abcde")
    visit_edition answer

    within "div.tabbable" do
      click_on "Admin"
    end

    assert page.has_button?("Create as new Simple Smart Answer edition")

    click_on "Create as new Simple Smart Answer edition"

    assert page.has_content?(answer.title)
    assert page.has_content?("New edition created")
    assert page.has_content?("Question 1")

    within :css, '#edition_body_input' do
      assert page.has_xpath?("//textarea[contains(text(), '#{answer.whole_body}')]"), "Expected to see: #{answer.whole_body}"
    end
  end

  test "should be able to convert an GuideEdition into a TransactionEdition" do
    guide = FactoryGirl.create(:guide_edition, state: 'published')
    visit_edition guide

    within "div.tabbable" do
      click_on "Admin"
    end

    assert page.has_button?("Create as new Transaction edition")

    click_on "Create as new Transaction edition"

    assert page.has_content?(guide.title)
    assert page.has_content?("New edition created")
    assert page.has_content?("Introductory paragraph")
    assert page.has_content?("Will continue on")
    assert page.has_content?("Link to start of transaction")
    assert page.has_content?("More information")
    assert page.has_content?(guide.whole_body)
  end

  test "should be able to convert an ProgrammeEdition into a TransactionEdition" do
    programme = FactoryGirl.create(:programme_edition, state: 'published')
    visit_edition programme

    within "div.tabbable" do
      click_on "Admin"
    end

    assert page.has_button?("Create as new Transaction edition")

    click_on "Create as new Transaction edition"

    assert page.has_content?(programme.title)
    assert page.has_content?("New edition created")
    assert page.has_content?("Introductory paragraph")
    assert page.has_content?("Will continue on")
    assert page.has_content?("Link to start of transaction")
    assert page.has_content?("More information")

    assert_field_contains("Overview", "More information")
    assert_field_contains("What you'll get", "More information")
    assert_field_contains("Eligibility", "More information")
    assert_field_contains("How to claim", "More information")
    assert_field_contains("Further information", "More information")
  end


# tests for changing Answer and Programme into Guide
  test "should be able to convert an AnswerEdition into a GuideEdition" do
    answer = FactoryGirl.create(:answer_edition, slug: "childcare", title: "meh", body: "bleh", state: 'published')
    visit_edition answer

    within "div.tabbable" do
      click_on "Admin"
    end

    assert page.has_button?("Create as new Guide edition")

    click_on "Create as new Guide edition"

    assert page.has_content?(answer.title)
    assert page.has_content?("New edition created")

    within :css, '#parts div.fields:first-of-type' do
      assert page.has_xpath?("//textarea[contains(text(), '#{answer.whole_body}')]"), "Expected to see: #{answer.whole_body}"
    end
  end

  test "should be able to convert a ProgrammeEdition into a GuideEdition" do
    programme = FactoryGirl.create(:programme_edition, state: 'published')
    visit_edition programme

    within "div.tabbable" do
      click_on "Admin"
    end

    assert page.has_button?("Create as new Guide edition")

    click_on "Create as new Guide edition"

    assert page.has_content?(programme.title)
    assert page.has_content?("New edition created")

    within :css, '#parts div.fields:first-of-type' do
      assert page.has_field?("Title", :with => 'Overview')
      assert page.has_field?("Slug", :with => 'overview')
    end
    within :css, '#parts div.fields:nth-of-type(2)' do
      assert page.has_field?("Title", :with => "What you'll get")
      assert page.has_field?("Slug", :with => 'what-youll-get')
    end
  end

  test "should not be able to convert a GuideEdition into an AnswerEdition if not published" do
    guide = FactoryGirl.create(:guide_edition, state: 'ready')
    visit_edition guide

    within "div.tabbable" do
      click_on "Admin"
    end

    refute page.has_button?("Create as new Answer edition")
  end
end
