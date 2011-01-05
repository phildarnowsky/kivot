require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
SCRIPT_PATH = File.expand_path(File.dirname(__FILE__) + '/../bin/kivot')

describe "kivot script" do
  def set_argv(new_argv)
    original_verbose = $VERBOSE
    $VERBOSE = nil
    Object.const_set(:ARGV, new_argv)
    $VERBOSE = original_verbose
  end

  def make_mock_poster
    mock_poster = mock(:post_story => nil)
    Kivot::PivotalPoster.stub!(:new).and_return(mock_poster)

    mock_poster
  end

  def run_script
    load SCRIPT_PATH
  end

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

      @current_path = Pathname.new("/data/projects/turnip_twaddler")
      Pathname.stub(:getwd).and_return(@current_path)
    end

    context "but a .kivot_token file is present" do
      # A lot of the setup below probably constitutes mock and stub abuse, but
      # it's hard to see how to do it with real Pathnames--we don't want to
      # make any assumptions about the user's filesystem.

      before(:each) do
        @alternate_fake_token = 'b123b123'
      end

      context "in the current directory" do
        before(:each) do
          @mock_path = mock
          @current_path.stub(:join).with('.kivot_token').and_return(@mock_path)
          @mock_path.stub(:file?).and_return(true)

          File.stub(:read).with(@mock_path).and_return(@alternate_fake_token)
        end

        it "should use the token in that file" do
          Kivot::PivotalPoster.should_receive(:new).with(@alternate_fake_token, anything).and_return(make_mock_poster)

          run_script
        end
      end

      context "in a parent directory" do
        before(:each) do
          @mock_found_path = mock(:file? => true)
          File.stub(:read).with(@mock_found_path).and_return(@alternate_fake_token)

          @mock_grandparent = mock(:join => @mock_found_path)
          @mock_parent = mock(:parent => @mock_grandparent, :join => mock(:file? => false), :root? => false)
          @mock_path = mock(:file? => false, :root? => false)

          @current_path.stub(:join).and_return(@mock_path)
          @current_path.stub(:parent).and_return(@mock_parent)
        end

        it "should use the token in that file" do
          Kivot::PivotalPoster.should_receive(:new).with(@alternate_fake_token, anything).and_return(make_mock_poster)

          run_script
        end
      end

      context "in the user's home directory" do
        before(:each) do
          @mock_found_path = mock(:file? => true)
          File.stub(:read).with(@mock_found_path).and_return(@alternate_fake_token)

          @mock_home_dirname = mock
          @mock_home_path = mock(:join => @mock_found_path)
          File.stub(:expand_path).with('~').and_return(@mock_home_dirname)
          Pathname.stub(:new).with(@mock_home_dirname).and_return(@mock_home_path)

          @mock_parent = mock(:join => mock(:file? => false), :root? => true)
          @mock_path = mock(:file? => false)

          @current_path.stub(:join).and_return(@mock_path)
          @current_path.stub(:parent).and_return(@mock_parent)
        end

        it "should use the token in that file" do
          Kivot::PivotalPoster.should_receive(:new).with(@alternate_fake_token, anything).and_return(make_mock_poster)

          run_script
        end
      end
    end

    context "and no .kivot_token file is present in an expected location" do
      before(:each) do
        stub(:find_file_in_home => nil)
      end

      it "should exit" do
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

  context "with valid arguments" do
    it "should attempt to post the story" do
      set_argv(@fake_args)

      mock_poster = make_mock_poster
      mock_poster.should_receive(:post_story)

      run_script
    end
  end
end
