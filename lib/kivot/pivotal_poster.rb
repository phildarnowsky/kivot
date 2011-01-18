require 'httparty'
require 'builder'

module Kivot
  class PivotalPoster
    def initialize(token, project_id)
      @token = token
      @project_id = project_id
    end

    def post_story(name, args={})
      headers = {
        'X-TrackerToken' => @token,
        'Content-Type'   => 'text/xml'
      }

      body = Builder::XmlMarkup.new.story do |s|
        s.name name

        s.description(args[:description]) if args[:description]
        s.owned_by(args[:owner]) if args[:owner]
        s.requested_by(args[:requester]) if args[:requester]
      end

      HTTParty.post(story_path, :headers => headers, :body => body)
    end

    private

    def story_path
      "http://www.pivotaltracker.com/services/v3/projects/#{@project_id}/stories"
    end
  end
end
