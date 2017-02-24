require 'json'
require 'optparse'
require "license/compatibility/version"

module License

  EXEC = File.basename($PROGRAM_NAME)
  USAGE = "Usage: #{EXEC} -h | -v | -r FILE [LICENSE_LIST | PKG_LICENSE_LIST]"

  module Compatibility
    def self.forward_compatibility(source_license, derivative_license)
      souce_type = license_type(source_license)
      derivative_type = license_type(derivative_license)
      case souce_type
      when :public_domain
        return true
      when :permissive, :weak_copyleft
        [:public_domain, :permissive, :weak_copyleft, :copyleft, :strong_copyleft, :network_copyleft].include? derivative_type
      when :strong_copyleft
        [:weak_copyleft, :strong_copyleft, :network_copyleft].include? derivative_type
      when :network_copyleft
        [:network_copyleft].include? derivative_type
      else
        raise 'Unknown license compatiblity'
      end
    end

    def self.license_data
      @@license_data ||= JSON.load(File.read(File.expand_path('../licenses.json', __FILE__)))
    end

    def self.license_type(license)
      license = license.gsub('+', '')
      if license_data['public_domain'].include?(license)
        :public_domain
      elsif license_data['permissive'].include?(license)
        :permissive
      elsif license_data['weak_copyleft'].include?(license)
        :weak_copyleft
      elsif license_data['strong_copyleft'].include?(license)
        :strong_copyleft
      elsif license_data['network_copyleft'].include?(license)
        :network_copyleft
      else
        raise 'Unknown license type'
      end
    end

    def self.check_license_list(list)
      # filter unique licenses
      result = true
      list.permutation(2).to_a.each { |couple|
        intermediate_result = self.forward_compatibility(couple[0], couple[1])
        print couple[0], ' is not forward-compatible with ', couple[1], "\n" unless intermediate_result
        result &= intermediate_result
      }
      result
    end

    def self.check_package_licence_list(list)
      result = true
      list.permutation(2).to_a.each { |couple|
        intermediate_result = self.forward_compatibility(couple[0][1], couple[1][1])
        print couple[0][0], ' (', couple[0][1], ') is not forward-compatible with ', couple[1][0], ' (', couple[1][1], ")\n" unless intermediate_result
        result &= intermediate_result
      }
      result
    end
  end

  module CommandLine
    def self.parse(args)
      options = {}
      option_parser = OptionParser.new do |opts|
        opts.banner = USAGE

        opts.on('-r', '--read FILE', 'Read a file instead of passing arguments to the command line.') do |file|
          unless File.exist?(file)
            raise Errno::ENOENT, "#{file}"
          end
          unless File.file?(file)
            raise ArgumentError, "#{file} is a directory, you must specify a regular file"
          end
          options[:read] = file
        end

        opts.on('-v', '--version', "Show the program version (#{License::Compatibility::VERSION}).") do
          options[:version] = "license-compatibility v#{License::Compatibility::VERSION}"
          return options
        end

        opts.on("-h", "--help", "Print this help.") do
          options[:help] = opts.to_s
          return options
        end
      end
      option_parser.parse!(args)
      return options
    end

    def self.parse_positional(args)
      licenses = false
      packages = false
      prepared = []
      args.each { |arg|
        split = arg.split(':', 2)
        if split.length == 2
          prepared.push(split)
          packages = true
        else
          prepared += split
          licenses = true
        end
        raise ArgumentError, 'do not mix license and package:license arguments' if (licenses && packages)
      }
      return (if packages then 'packages' else 'licenses' end), prepared
    end

  end
end
