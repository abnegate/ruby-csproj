module CsProj
  module Msbuild
    class Project
      attr_accessor :options

      def initialize(options)
        @options = options
      end

      def project_name
        @options[:project_name]
      end

      def project_path
        @options[:project_path]
      end

      def ios?
        is_platform? CsProj::Platform::IOS
      end

      def osx?
        is_platform? CsProj::Platform::OSX
      end

      def android?
        is_platform? CsProj::Platform::ANDROID
      end

      def is_platform?(platform)
        case platform
               when CsProj::Platform::IOS
            then project_name.downcase.include? "ios"
               when CsProj::Platform::OSX
            then project_name.downcase.include? "mac"
               when CsProj::Platform::ANDROID
            then project_name.downcase.include? "droid"
               else false
        end
      end
    end
  end
end
