require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "kivot script" do
  include OptionalArgumentMacros

  before(:each) do
    @original_argv = ARGV.dup

    @fake_token = "abcabcabc"
    @fake_project_id = "123123123"
    @fake_name = "The People's Glorious Story"

    @fake_args = ["-t", @fake_token, "-p", @fake_project_id, @fake_name]

    HTTParty.stub!(:post)
  end

  after(:each) do
    set_argv(@original_argv)
  end

  %w(-t --token).each do |token_arg|
    it "should honor the #{token_arg} argument" do
      @fake_args[0] = token_arg
      set_argv(@fake_args)

      Kivot::PivotalPoster.should_receive(:new).with(@fake_token, anything).and_return(stub(:post_story => nil))

      run_script
    end
  end

  context "when no token argument is present" do
    before(:each) do
      set_argv(["-p", @fake_project_id, @fake_name])
    end

    it "should go looking for a token file" do
      @current_path = mock
      Pathname.stub(:getwd).and_return(@current_path)

      Kivot::ConfigFileReader.should_receive(:read_from_config_file).with('.kivot_token', @current_path).and_return(@fake_token)
      run_script
    end

    context "and it doesn't find a token file" do
      before(:each) do
        Kivot::ConfigFileReader.stub(:read_from_config_file).and_return(nil)
      end

      it "should exit" do
        HTTParty.should_not_receive(:post)
        lambda{run_script}.should raise_exception(SystemExit)
      end
    end
  end

  context "when no project ID argument is present" do
    before(:each) do
      set_argv(["-t", @fake_token, @fake_name])
    end

    it "should go looking for a project ID file" do
      @current_path = mock
      Pathname.stub(:getwd).and_return(@current_path)

      Kivot::ConfigFileReader.should_receive(:read_from_config_file).with('.kivot_project_id', @current_path).and_return(@fake_project_id)
      run_script
    end

    context "and it doesn't find a project ID file" do
      before(:each) do
        Kivot::ConfigFileReader.stub(:read_from_config_file).and_return(nil)
      end

      it "should exit" do
        HTTParty.should_not_receive(:post)
        lambda{run_script}.should raise_exception(SystemExit)
      end
    end
  end

  %w(-p --project_id).each do |project_id_arg|
    it "should honor the #{project_id_arg} argument" do
      @fake_args[2] = project_id_arg
      set_argv(@fake_args)

      Kivot::PivotalPoster.should_receive(:new).with(anything, @fake_project_id).and_return(stub(:post_story => nil))

      run_script
    end
  end

  it "should require the name argument" do
    set_argv(['-t', @fake_token, '-p', @fake_project_id])

    HTTParty.should_not_receive(:post)
    lambda{run_script}.should raise_exception(SystemExit)
  end

  it "should honor the name argument" do
    set_argv(@fake_args)

    mock_poster = make_mock_poster
    mock_poster.should_receive(:post_story).with("The People's Glorious Story", kind_of(Hash))
    
    run_script
  end
  
  context "when a description argument is present" do
    it "should honor the description argument" do
      fake_description = "do a wonderful thing"
      set_argv(@fake_args + [fake_description])

      mock_poster = make_mock_poster
      mock_poster.should_receive(:post_story).with(anything, hash_including(:description => fake_description))

      run_script
    end
  end

  should_honor_argument('-o', :owner)
  should_honor_argument('--owner', :owner)

  should_honor_argument('-r', :requester)
  should_honor_argument('--requester', :requester)

  context "with valid arguments" do
    it "should attempt to post the story" do
      set_argv(@fake_args)

      mock_poster = make_mock_poster
      mock_poster.should_receive(:post_story)

      run_script
    end
  end
end
