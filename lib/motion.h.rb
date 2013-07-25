unless defined? Motion::Project::Config
  raise '"motion.h" must be required within a RubyMotion project Rakefile.'
end

class Motion::Project::Config
  # @param [String] header_file Requested C header file.
  # @param [Hash] options Options for customizing BridgeSupport file generation
  # @option options [String] :prefix Subdirectory of /usr/include used for root of included header files.
  # @option options [String] :bridgesupport_dir Path where the generated bridgesupport file is saved. Defaults to ./build
  def include(header_file, options={})
    MotionHeader.new(header_file, self, options).integrate
  end
end

class MotionHeader

  BRIDGESUPPORT_DIR = 'build'

  # @param [String] header_file Requested C header file.
  # @param [Motion::Project::Config] config RubyMotion config provided in App.setup.
  # @param [Hash] options Options for customizing BridgeSupport file generation
  # @option options [String] :prefix Subdirectory of /usr/include used for root of included header files.
  # @option options [String] :bridgesupport_dir Path where the generated bridgesupport file is saved. Defaults to ./build
  def initialize(header_file, config, options={})
    @header_file = header_file
    @config = config
    @prefix = options[:prefix]
    @bridgesupport_dir = options[:bridgesupport_dir] || BRIDGESUPPORT_DIR
  end

  def integrate
    verify_header_file
    generate_bridgesupport_file
    @config.bridgesupport_files << bridgesupport_file
  end

  def verify_header_file
    path = "#{include_path}/#{@header_file}"
    File.exist?(path) or raise "Header file `#{@header_file}' does not exist (#{path})."
  end

  def generate_bridgesupport_file
    return if File.exist?(bridgesupport_file)
    Dir.mkdir(@bridgesupport_dir) unless Dir.exist?(@bridgesupport_dir)
    flag = begin
      case platform
      when :ios
        "--no-64-bit"
      when :osx
        "--64-bit"
      end
    end
    `/usr/bin/gen_bridge_metadata --format complete #{flag} --cflags '-I#{include_path}' #{@header_file} > #{bridgesupport_file}`
  end

  def include_path
    sdk_dir = sdk_dir(@config.sdk_version)
    path_components = [@config.xcode_dir, *sdk_dir, 'usr', 'include', @prefix].compact
    File.join(*path_components)
  end

  def sdk_dir(sdk_version)
    case platform
    when :ios
      ['Platforms', 'iPhoneOS.platform', 'Developer', 'SDKs', "iPhoneOS#{sdk_version}.sdk"]
    when :osx
      ['Platforms', 'MacOSX.platform', 'Developer', 'SDKs', "MacOSX#{sdk_version}.sdk"]
    end
  end

  def bridgesupport_file
    file_name = @header_file.tr('/', '_').chomp('.h')
    "#{@bridgesupport_dir}/#{file_name}.bridgesupport"
  end

  def platform
    Motion::Project::App.respond_to?(:template) ? Motion::Project::App.template : :ios
  end
end
