unless defined? Motion::Project::Config
  raise '"motion.h" must be required within a RubyMotion project Rakefile.'
end

class Motion::Project::Config
  def include(header_file, output_dir=nil)
    MotionHeader.new(header_file, self, output_dir).integrate
  end
end

class MotionHeader

  BRIDGESUPPORT_DIR = 'build'

  # @param [String] header_file Requested C header file.
  # @param [Motion::Project::Config] config RubyMotion config provided in App.setup.
  # @param [String] bridgesupport_dir Path where the generated bridgesupport file is saved. Defaults to ./build.
  def initialize(header_file, config, bridgesupport_dir=BRIDGESUPPORT_DIR)
    @header_file = header_file
    @config = config
    @bridgesupport_dir = bridgesupport_dir || BRIDGESUPPORT_DIR
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
    `/usr/bin/gen_bridge_metadata --format complete --no-64-bit --cflags '-I#{include_path}' #{@header_file} > #{bridgesupport_file}`
  end

  def include_path
    "#{@config.xcode_dir}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS#{@config.sdk_version}.sdk/usr/include"
  end

  def bridgesupport_file
    file_name = @header_file.tr('/', '_').chomp('.h')
    "#{@bridgesupport_dir}/#{file_name}.bridgesupport"
  end

end
