# frozen_string_literal: true

require "test_helper"

class ApiTest < Minitest::Test
  def setup
    OnPage.configure do |config|
      config.company = "company_name"
      config.api_token = "api_token"
    end
    OnPage::Api.reset_request_counter
  end

  def test_that_it_has_a_version_number
    refute_nil OnPage::VERSION
  end

  def test_project_information_tracks_query_number
    VCR.use_cassette("schema") do
      OnPage::Api.project_information
      assert_equal 1, OnPage::Api.request_count
    end
  end

  def test_project_information
    VCR.use_cassette("schema") do
      schema = OnPage::Api.project_information
      assert_instance_of OnPage::Schema, schema
      refute_empty schema.label
    end
  end

  def test_query_first_tracks_query_number
    VCR.use_cassette("first") do
      criteria = OnPage::Api::Criteria.new("rcapitoli").first
      OnPage::Api.query(criteria)
      assert_equal 1, OnPage::Api.request_count
    end
  end

  def test_query_first_return_single_result
    VCR.use_cassette("first") do
      criteria = OnPage::Api::Criteria.new("rcapitoli").first
      chapter = OnPage::Api.query(criteria)
      assert_instance_of OnPage::Thing, chapter
    end
  end

  def test_query_first_result
    VCR.use_cassette("check") do
      criteria = OnPage::Api::Criteria.new("rcapitoli").first
      chapter = OnPage::Api.query(criteria)
      check_first_chapter(chapter)

      # FIXME: cleanup & find a better way
      criteria = OnPage::Api::Criteria.new("rcapitoli").where("_id", chapter.id).first
      chapter_by_id = OnPage::Api.query(criteria)
      assert_equal chapter, chapter_by_id
    end
  end

  def test_query_non_existing_first
    VCR.use_cassette("non_existant") do
      criteria = OnPage::Api::Criteria.new("non_existant").first
      assert_raises(OnPage::ApiError, "Cannot find resource non_existant") do
        OnPage::Api.query(criteria)
      end
    end
  end

  def test_query_all_result
    VCR.use_cassette("query_all") do
      criteria = OnPage::Api::Criteria.new("rcapitoli").all
      chapters = OnPage::Api.query(criteria)
      assert_instance_of Array, chapters
      assert_equal 23, chapters.count
      check_first_chapter(chapters.first)
    end
  end

  def test_query_with_basic_filter
    VCR.use_cassette("filter_basic") do
      criteria = OnPage::Api::Criteria.new("rcapitoli").where("_id", 4_857_793).first
      chapters = OnPage::Api.query(criteria)
      assert_equal 4_857_793, chapters.id
    end
  end

  def test_query_with_complex_filter
    VCR.use_cassette("filter_complex") do
      criteria = OnPage::Api::Criteria.new("rcapitoli").where("fdescrizione", "like", "led").all
      chapters = OnPage::Api.query(criteria)
      assert_equal 11, chapters.count
      assert_equal 4_857_794, chapters.first.id
    end
  end

  def test_on_demand_relations
    VCR.use_cassette("relations") do
      criteria = OnPage::Api::Criteria.new("rcapitoli").first
      chapter = OnPage::Api.query(criteria)
      OnPage::Api.reset_request_counter
      check_argomenti(chapter)
      assert_equal 1, OnPage::Api.request_count
    end
  end

  def test_on_demand_nested_relations
    skip
    VCR.use_cassette("nested_relations") do
      criteria = OnPage::Api::Criteria.new("rcapitoli").first
      chapter = OnPage::Api.query(criteria)
      OnPage::Api.reset_request_counter
      articles = chapter.rel("fargomenti.fprodotti.farticoli")
      assert_equal 76, articles.count
      assert_equal 1, OnPage::Api.request_count
    end
  end

  def test_preloaded_things
    skip
    VCR.use_cassette("preload") do
      criteria = OnPage::Api::Criteria.new("rcapitoli").with("fargomenti.fprodotti").first
      thing = OnPage::Api.query(criteria)
      OnPage::Api.reset_request_counter
      check_argomenti(thing)
      # assert_equal 0, OnPage::Api.request_count

      criteria = OnPage::Api::Criteria.new("rcapitoli").with("fargomenti.fprodotti.farticoli").first
      thing = OnPage::Api.query(criteria)
      OnPage::Api.reset_request_counter
      articles = thing.rel("fargomenti.fprodotti.farticoli")
      assert_equal 0, OnPage::Api.request_count
      assert_equal 76, articles.count
    end
  end

  def test_image_download_direct
    VCR.use_cassette("download") do
      criteria = OnPage::Api::Criteria.new("rargomenti").first
      argument = OnPage::Api.query(criteria)
      image = argument.val("fdisegno1")
      assert_instance_of OnPage::Downloadable, image
      storage_path = "https://#{OnPage.configuration.company}.onpage.it/api/storage/"
      expected_url = URI("#{storage_path}PMWJiNp8eYn2Hy3TevNU")
      assert_equal image.download_url, expected_url
    end
  end

  def test_image_download_transformation
    VCR.use_cassette("download") do
      criteria = OnPage::Api::Criteria.new("rargomenti").first
      argument = OnPage::Api.query(criteria)
      image = argument.val("fdisegno1")
      assert_instance_of OnPage::Downloadable, image
      storage_path = "https://#{OnPage.configuration.company}.onpage.it/api/storage/"
      expected_url = URI("#{storage_path}PMWJiNp8eYn2Hy3TevNU.230x-contain.png?name=shutterstock_36442114-ok-NEW.jpg")
      transformation_options = { x: 230, ext: "png", original_name: true }
      assert_equal image.download_url(transformation_options), expected_url
    end
  end

  def test_query_with_offset_result
    VCR.use_cassette("offset") do
      criteria = OnPage::Api::Criteria.new("rcapitoli").offset(999_999_999).first
      result = OnPage::Api.query(criteria)
      assert_nil result
    end
  end

  def test_query_with_limit_result
    VCR.use_cassette("limit") do
      criteria = OnPage::Api::Criteria.new("rcapitoli").limit(5).all
      result = OnPage::Api.query(criteria)
      assert_equal 5, result.count
    end
  end

  def test_query_with_related_to
    skip("not yet implemented")
  end

  def check_first_chapter(chapter)
    refute_nil chapter
    assert_instance_of OnPage::Thing, chapter, "Cannot pull first chapter"
    assert_equal 4_857_793, chapter.id
    assert_equal "Profili alluminio", chapter.val("fdescrizione").first
  end

  def check_argomenti(thing)
    relations = thing.rel("fargomenti")
    assert_equal 1, relations.count
    argument = relations.first
    assert_equal "Architetturale;Domestico;Commerciale;Industriale;Arredamento;", argument.val("fnota10")
    relations.each { |a| a.val("fnota10") }
  end
end
