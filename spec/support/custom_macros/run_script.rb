module RunScriptMacros
  SCRIPT_PATH = File.expand_path(File.dirname(__FILE__) + '/../../../bin/kivot')

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


end
