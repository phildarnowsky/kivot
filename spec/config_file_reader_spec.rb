require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../lib/kivot/config_file_reader')

describe "Kivot::ConfigFileReader" do
  describe "#read_from_config_file" do
    before(:each) do
      @fake_file_contents = 'b123b123'
      @fake_filename = "bazinga_count"

      @current_path = Pathname.new("/data/projects/turnip_twaddler")
    end

    context "when the expected file is present" do
      # A lot of the setup below probably constitutes mock and stub abuse, but
      # it's hard to see how to do it with real Pathnames--we don't want to
      # make any assumptions about the user's filesystem.

      context "in the current directory" do
        before(:each) do
          @mock_path = mock
          @current_path.stub(:join).with(@fake_filename).and_return(@mock_path)
          @mock_path.stub(:file?).and_return(true)

          File.stub(:read).with(@mock_path).and_return(@fake_file_contents)
        end

        it "should return the contents of that file" do
          Kivot::ConfigFileReader.read_from_config_file(@fake_filename, @current_path).should == @fake_file_contents
        end
      end

     context "in a parent directory" do
        before(:each) do
          @mock_found_path = mock(:file? => true)
          File.stub(:read).with(@mock_found_path).and_return(@fake_file_contents)

          @mock_grandparent = mock
          @mock_grandparent.stub(:join).with(@fake_filename).and_return(@mock_found_path)

          @mock_parent_file_path = mock(:file? => false)
          @mock_parent = mock(:parent => @mock_grandparent, :root? => false)
          @mock_parent.stub(:join).with(@fake_filename).and_return(@mock_parent_file_path)

          @mock_path = mock(:file? => false, :root? => false)

          @current_path.stub(:join).with(@fake_filename).and_return(@mock_path)
          @current_path.stub(:parent).and_return(@mock_parent)
        end

        it "should return the contents of that file" do
          Kivot::ConfigFileReader.read_from_config_file(@fake_filename, @current_path).should == @fake_file_contents
        end
      end

      context "in the user's home directory" do
        before(:each) do
          @mock_found_path = mock(:file? => true)
          File.stub(:read).with(@mock_found_path).and_return(@fake_file_contents)

          @mock_home_dirname = mock
          @mock_home_path = mock(:join => @mock_found_path)
          File.stub(:expand_path).with('~').and_return(@mock_home_dirname)
          Pathname.stub(:new).with(@mock_home_dirname).and_return(@mock_home_path)

          @mock_parent = mock(:join => mock(:file? => false), :root? => true)
          @mock_path = mock(:file? => false)

          @current_path.stub(:join).and_return(@mock_path)
          @current_path.stub(:parent).and_return(@mock_parent)
        end

        it "should return the contents of that file" do
          Kivot::ConfigFileReader.read_from_config_file(@fake_filename, @current_path).should == @fake_file_contents
        end
      end
    end

    context "and no file is present in an expected location" do
      before(:each) do
        stub(:find_file_in_home => nil)
      end

      it "should return nil" do
        Kivot::ConfigFileReader.read_from_config_file(@fake_filename, @current_path).should be_nil
      end
    end
  end
end
