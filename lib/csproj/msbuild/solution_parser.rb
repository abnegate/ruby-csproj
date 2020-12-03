require "csproj/msbuild/solution"

module CsProj
  module Msbuild
    class SolutionParser
      def self.parse(filename)
        solution = Solution.new

        File.open(filename) do |f|
          f.read.split("\n").each do |line|
            if line.start_with? "Project"
              options = parse_line line
              solution.add_project Project.new(options)
            end
          end
        end

        solution
      end

      def self.parse_line(line)
        name = get_project_name line
        project_file = get_project_file line
        {project_name: name, project_path: project_file}
      end

      def self.get_project_name(project_line)
        project_line.split("\"")[3]
      end

      def self.get_project_file(project_line)
        project_line.split("\"")[5].tr('\\', "/")
      end
    end
  end
end
