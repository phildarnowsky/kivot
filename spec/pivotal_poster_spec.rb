require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'nokogiri'

describe "PivotalPoster" do
  include PostMacros

  before(:each) do
    @token = "52e468cfc0a87795f8f2230d6c8a42cb"
    @project_id = 666

    @poster = Kivot::PivotalPoster.new(@token, @project_id)
  end

  describe "#post_story" do
    before(:each) do
      HTTParty.stub!(:post)

      @story_name = "do a new thing"
      @story_description = "I do a new thing now: to do things"
    end

    it "should post to the correct URL" do
      HTTParty.should_receive(:post).with("http://www.pivotaltracker.com/services/v3/projects/#{@project_id}/stories", anything)
      @poster.post_story(@story_name)
    end

    it "should include the token when posting" do
      expect_request_header('X-TrackerToken', @token)
      @poster.post_story(@story_name)
    end

    it "should specify an XML Content-Type" do
      expect_request_header('Content-Type', 'text/xml')
      @poster.post_story(@story_name)
    end

    it "should include the story name in the body" do
      expect_body_element('/story/name', @story_name)
      @poster.post_story(@story_name)
    end

    context "when a description is passed" do
      it "should include the description in the body" do
        expect_body_element('/story/description', @story_description)
        @poster.post_story(@story_name, :description => @story_description)
      end
    end
  end
end
