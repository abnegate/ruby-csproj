require "nokogiri"
require "csproj/msbuild/project"
require "csproj/msbuild/solution_parser"

module CsProj
  class DetectValues
    def self.set_additional_default_values
      config = CsProj.config

      if config[:platform] == Platform::ANDROID
        config[:build_platform] = "AnyCPU"
      end

      # Detect the project
      CsProj.project = Msbuild::Project.new(config)
      detect_solution
      detect_project

      doc_csproj = get_parser_handle config[:project_path]

      detect_output_path doc_csproj
      detect_manifest doc_csproj
      detect_info_plist
      detect_assembly_name doc_csproj

      config
    end

    # Helper Methods

    def self.detect_solution
      return if CsProj.config[:solution_path]

      sln = find_file("*.sln", 3)

      unless sln
        puts "Not able to find solution file automatically, try to specify it via `solution_path` parameter."
        exit
      end

      CsProj.config[:solution_path] = abs_path sln
    end

    def self.detect_project
      return if CsProj.config[:project_path]

      path = CsProj.config[:solution_path]
      projects = Msbuild::SolutionParser
        .parse(path)
        .get_platform(CsProj.config[:platform])

      unless projects.any?
        puts "Not able to find any project in solution, that matches the platform `#{CsProj.config[:platform]}`."
        exit
      end

      project = projects.first
      csproj = fix_path_relative project.project_path

      unless csproj
        puts "Not able to find project file automatically, try to specify it via `project_path` parameter."
        exit
      end

      CsProj.config[:project_name] = project.project_name
      CsProj.config[:project_path] = abs_path csproj
    end

    def self.detect_output_path(doc_csproj)
      return if CsProj.config[:output_path] ||
        !CsProj.config[:build_configuration]

      configuration = CsProj.config[:build_configuration]
      platform = CsProj.config[:build_platform]

      doc_node = doc_csproj.xpath("/*[local-name()='Project']/*[local-name()='PropertyGroup'][translate(@*[local-name() = 'Condition'],'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz') = \" '$(configuration)|$(platform)' == '#{configuration.downcase}|#{platform.downcase}' \"]/*[local-name()='OutputPath']/text()")
      output_path = doc_node.text

      unless output_path
        puts "Not able to find output path automatically, try to specify it via `output_path` parameter."
        exit
      end

      CsProj.config[:output_path] = abs_project_path output_path
    end

    def self.detect_manifest(doc_csproj)
      return if CsProj.config[:manifest_path] || (CsProj.config[:platform] != Platform::ANDROID)

      doc_node = doc_csproj.css("AndroidManifest").first

      CsProj.config[:manifest_path] = abs_project_path doc_node.text
    end

    def self.detect_info_plist
      return if CsProj.config[:plist_path] || (CsProj.config[:platform] != Platform::IOS)

      plist_path = abs_project_path find_file("Info.plist", 1)

      unless plist_path
        plist_path = abs_project_path "Info.plist"

        unless File.exist? plist_path
          puts "Not able to find Info.plist automatically, try to specify it via `plist_path` parameter."
          exit
        end
      end

      CsProj.config[:plist_path] = plist_path
    end

    def self.detect_assembly_name(doc_csproj)
      return if CsProj.config[:assembly_name]

      if [Platform::IOS, Platform::OSX].include? CsProj.config[:platform]
        CsProj.config[:assembly_name] = doc_csproj.css("PropertyGroup > AssemblyName").text
      elsif CsProj.config[:platform] == Platform::ANDROID
        doc = get_parser_handle CsProj.config[:manifest_path]
        CsProj.config[:assembly_name] = doc.xpath("string(//manifest/@package)")
      end
    end

    private_class_method

    def self.find_file(query, depth)
      itr = 0
      files = []

      loop do
        files = Dir.glob(query)
        query = "../#{query}"
        itr += 1
        break if files.any? || (itr > depth)
      end

      files.first
    end

    def self.get_parser_handle(filename)
      f = File.open(filename)
      doc = Nokogiri::XML(f)
      f.close

      doc
    end

    def self.fix_path_relative(path)
      root = File.dirname CsProj.config[:solution_path]
      path = "#{root}/#{path}"
      path
    end

    def self.abs_project_path(path)
      return nil if path.nil?

      path = path.tr('\\', "/")
      platform_path = CsProj.config[:project_path]
      "#{File.dirname(platform_path)}/#{path}"
    end

    def self.abs_path(path)
      return nil if path.nil?

      path = path.tr('\\', "/")
      File.expand_path(path)
    end
  end
end
