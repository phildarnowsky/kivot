module PostMacros
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
end
