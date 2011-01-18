module OptionalArgumentMacros
  require 'support/custom_macros/run_script'
  include RunScriptMacros

  def self.included(other)
    other.extend(ClassMethods)
  end

  module ClassMethods
    def should_honor_argument(switch, poster_option, fake_value=nil)
      context "when the #{switch} argument is set" do
        it "should honor it" do
          fake_value ||= rand(100000000).to_s

          set_argv([
            '-t', 'token',
            '-p', 'project_id',
            switch, fake_value,
            double('story name').as_null_object
          ])

          make_mock_poster.should_receive(:post_story).with(anything, hash_including(poster_option => fake_value))

          run_script
        end
      end
    end
  end
end
