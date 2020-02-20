unless defined? Motion::Project::Config
  raise '"motion.h" must be required within a RubyMotion project Rakefile.'
end

module Motion::Project
  class Config
    # @param [String] header_file Requested C header file.
    # @param [Hash] options Options for customizing BridgeSupport file generation
    # @option options [String] :prefix Subdirectory of /usr/include used for root of included header files.
    # @option options [String] :bridgesupport_dir Path where the generated bridgesupport file is saved. Defaults to ./build
    def include(header_file, options={})
      motion_h << MotionHeader.new(header_file, self, options).integrate
    end

    def motion_h
      @motion_h ||= []
    end
  end

  class App
    class << self
      def build_with_motion_h(platform, opts = {})
        config.bridgesupport_files.concat(config.motion_h)
        build_without_motion_h(platform, opts)
      end

      alias_method "build_without_motion_h", "build"
      alias_method "build", "build_with_motion_h"
    end
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
    bridgesupport_file
  end

  def verify_header_file
    path = "#{include_path}/#{@header_file}"
    File.exist?(path) or raise "Header file `#{@header_file}' does not exist (#{path})."
  end

  def generate_bridgesupport_file
    return if File.exist?(bridgesupport_file)
    Dir.mkdir(@bridgesupport_dir) unless Dir.exist?(@bridgesupport_dir)
    cflags = [
      "-I#{include_path}",
      "-F#{frameworks_path}"
    ]
    if `sw_vers -productVersion` =~ /^10.15/ # Catalina
      cflags << "--isysroot #{isysroot_dir}"
    end
    Bundler.with_clean_env do
      `/Library/RubyMotion/bin/gen_bridge_metadata --format complete --64-bit --cflags '#{cflags.join(' ')}' #{@header_file} > #{bridgesupport_file}`
    end
  end

  def include_path
    sdk_dir = sdk_dir(@config.sdk_version)
    path_components = [@config.xcode_dir, *sdk_dir, 'usr', 'include', @prefix].compact
    File.join(*path_components)
  end

  def frameworks_path
    sdk_dir = sdk_dir(@config.sdk_version)
    path_components = [@config.xcode_dir, *sdk_dir, 'System', 'Library', 'Frameworks'].compact
    File.join(*path_components)
  end

  def isysroot_dir
    case platform
    when :ios then 'iPhoneOS'
    when :osx then 'MacOSX'
    end
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
