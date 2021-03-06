# encoding: utf-8
require "test_helper"

class EditionChurnPresenterTest < ActionDispatch::IntegrationTest
  should "provide a CSV export of business support schemes" do
    hmrc = FactoryGirl.create(:live_tag,
                               tag_id: "hm-revenue-customs",
                               title: "HMRC",
                               tag_type: "organisation")
    document = FactoryGirl.create(:artefact,
      name: "Important document",
      organisations: [hmrc.tag_id],
      need_ids: ["123456","123321","654321"]
    )

    edition_1 = FactoryGirl.create(:edition,
      title: "Important document",
      browse_pages: [],
      primary_topic: "",
      additional_topics: [],
      panopticon_id: document.id
    )

    edition_2 = FactoryGirl.create(:edition,
      title: "Important tax document",
      browse_pages: ["business/support", "tax/vat"],
      primary_topic: "business-tax/vat",
      additional_topics: ["oil-and-gas/licensing", "environmental-management/boating"],
      panopticon_id: document.id
    )

    csv = EditionChurnPresenter.new(
      Edition.not_in(state: ["archived"]).order(:title.asc)).to_csv

    data = CSV.parse(csv, :headers => true)

    assert_equal 2, data.length

    assert_equal "Important document", data[0]["Name"]
    assert_equal "", data[0]["Browse pages"]
    assert_equal "", data[0]["Primary topic"]
    assert_equal "", data[0]["Additional topics"]
    assert_equal "HMRC", data[1]["Organisations"]
    assert_equal "123456,123321,654321", data[0]["Need ids"]
    assert_equal "1", data[0]["Version number"]
    assert_equal edition_1.created_at.iso8601, data[0]["Editioned on"]
    assert_equal document.id.to_s, data[0]["Panopticon"]

    assert_equal "Important tax document", data[1]["Name"]
    assert_equal "business/support,tax/vat", data[1]["Browse pages"]
    assert_equal "business-tax/vat", data[1]["Primary topic"]
    assert_equal "oil-and-gas/licensing,environmental-management/boating", data[1]["Additional topics"]
    assert_equal "HMRC", data[1]["Organisations"]
    assert_equal "123456,123321,654321", data[1]["Need ids"]
    assert_equal "2", data[1]["Version number"]
    assert_equal edition_2.created_at.iso8601, data[1]["Editioned on"]
    assert_equal document.id.to_s, data[1]["Panopticon"]
  end
end
