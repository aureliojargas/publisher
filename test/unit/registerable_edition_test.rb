require "test_helper"

class RegisterableEditionTest < ActiveSupport::TestCase

  def template_answer(version_number = 1)
    artefact = FactoryGirl.create(:artefact)
    AnswerEdition.create(state: 'ready', slug: "childcare", panopticon_id: artefact.id,
      title: 'Child care stuff', body: 'Lots of info', version_number: version_number)
  end

  def template_published_answer(version_number = 1)
    answer = template_answer(version_number)
    answer.publish
    answer.save
    answer
  end

  def template_transaction
    artefact = FactoryGirl.create(:artefact)
    TransactionEdition.create(title: 'One', introduction: 'introduction',
      more_information: 'more info', panopticon_id: artefact.id, slug: "childcare")
  end

  def template_unpublished_answer(version_number = 1)
    template_answer(version_number)
  end

  setup do
    stub_register_published_content
    @artefact = FactoryGirl.create(:artefact)
    @edition = FactoryGirl.create(:guide_edition, state: "published", panopticon_id: @artefact.id)
  end

  context "live" do
    should "always return true, because we only register something when it's published" do
      registerable = RegisterableEdition.new(@edition)
      assert_equal true, registerable.live
    end
  end

  context "description" do
    should "return the overview" do
      @edition.update_attribute(:overview, "Overviewiness")
      registerable = RegisterableEdition.new(@edition)
      assert_equal "Overviewiness", registerable.description
    end
  end

  context "indexable_content" do
    context "an answer" do
      should "include the body of the answer" do
        registerable = RegisterableEdition.new(template_published_answer)
        assert_equal registerable.indexable_content, "Lots of info"
      end
    end

    context "for a transaction" do
      should "should combine the introduction and more_information" do
        registerable = RegisterableEdition.new(template_transaction)
        assert_equal registerable.indexable_content, "introduction more info"
      end
    end

    context "for a single part thing" do
      should "have the normalised content of that part" do
        edition = FactoryGirl.create(:guide_edition, :state => 'ready', :title => 'one part thing', :alternative_title => 'alternative one part thing', panopticon_id: FactoryGirl.create(:artefact).id)
        edition.publish
        registerable = RegisterableEdition.new(edition)
        assert_equal registerable.indexable_content, "alternative one part thing"
      end
    end

    context "for a multi part thing" do
      should "have the normalised content of all parts" do
        edition = FactoryGirl.create(:guide_edition_with_two_parts, :state => 'ready', panopticon_id: FactoryGirl.create(:artefact).id)
        edition.publish
        registerable = RegisterableEdition.new(edition)
        assert_equal registerable.indexable_content, "PART ! This is some version text. PART !! This is some more version text."
      end
    end

    context "indexable_content would contain govspeak" do
      should "convert it to plaintext" do
        edition = FactoryGirl.create(:guide_edition_with_two_govspeak_parts, :state => 'ready', panopticon_id: FactoryGirl.create(:artefact).id)
        edition.publish

        expected = "Some Part Title! This is some version text. Another Part Title This is link text."
        registerable = RegisterableEdition.new(edition)
        assert_equal expected, registerable.indexable_content
      end
    end
  end
end
