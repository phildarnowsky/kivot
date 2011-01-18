module PostMacros
  def self.included(other)
    other.extend(ClassMethods)
  end

  def expect_body_element(selector, expected_contents)
    HTTParty.should_receive(:post) do |received_url, received_args|
      body = Nokogiri::XML(received_args[:body])
      body.at(selector).inner_text.should == expected_contents
    end
  end

  def expect_request_header(header_name, expected_value)
    HTTParty.should_receive(:post) do |received_url, received_args|
      received_args[:headers][header_name].should == expected_value
    end
  end

  module ClassMethods
    def should_post_option(option_name, element_name)
      context "when the \"#{option_name}\" option is passed" do
        it "should include that option in an <#{element_name}> element" do
          poster = Kivot::PivotalPoster.new(double('token').as_null_object, double('project_id').as_null_object)
          value = rand(1000000000).to_s
          expect_body_element("/story/#{element_name}", value)
          poster.post_story("", option_name => value)
        end
      end
    end

  end
end
