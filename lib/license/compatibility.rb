require 'json'
require 'optparse'
require 'license/compatibility/version'

module License
  EXEC = File.basename($PROGRAM_NAME)
  USAGE = "Usage: #{EXEC} [-h] [-v] [-l] [-r file] [args]"

  module Compatibility
    def self.forward_compatibility(source_license, derivative_license)
      source_type = license_type(source_license)
      derivative_type = license_type(derivative_license)
      case source_type
      when :public_domain
        return true
      when :permissive, :weak_copyleft
        [:public_domain, :permissive, :weak_copyleft, :copyleft, :strong_copyleft, :network_copyleft].include? derivative_type
      when :strong_copyleft
        [:weak_copyleft, :strong_copyleft, :network_copyleft].include? derivative_type
      when :network_copyleft
        [:network_copyleft].include? derivative_type
      else
        raise "Unknown license compatibility: #{source_license} and #{derivative_license}"
      end
    end

    def self.license_data
      @@license_data ||= JSON.load(File.read(File.expand_path('../licenses.json', __FILE__)))
    end

    def self.license_type(license)
      license = license.delete('+')
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
        raise "Unknown license type: #{license}"
      end
    end

    def self.filter_known_licenses(list)
      known = []
      list.each { |license |
        begin
          self.license_type(license)
          unless known.include? license
            known.push(license)
          end
        rescue => e
          STDERR.puts e
        end
      }
      return known
    end

    def self.check_license_list(list)
      result = true
      self.filter_known_licenses(list).permutation(2).to_a.each { |couple|
        intermediate_result = self.forward_compatibility(couple[0], couple[1])
        puts "#{couple[0]} is not forward-compatible with #{couple[1]}" unless intermediate_result
        result &= intermediate_result
      }
      puts "Licenses are compatible" if result
      result
    end

    def self.check_package_licence_list(list)
      result = true
      known_licenses = self.filter_known_licenses(list.map { |x| x[1] })
      list.select { |x| known_licenses.include? x[1] }.permutation(2).to_a.each { |couple|
        intermediate_result = self.forward_compatibility(couple[0][1], couple[1][1])
        puts "#{couple[0][0]} (#{couple[0][1]}) is not forward-compatible with #{couple[1][0]} (#{couple[1][1]})" unless intermediate_result
        result &= intermediate_result
      }
      puts "Licenses are compatible" if result
      result
    end
  end

  module CommandLine
    def self.parse(args)
      options = {}
      option_parser = OptionParser.new do |opts|
        opts.banner = "#{USAGE}\n\n"
        opts.banner += "Arguments:\n"
        opts.banner += "    List of licenses or list of package:license couples (separated by ':').\n"
        opts.banner += "    Example: 'MIT' 'GPL-3.0' or 'my_package:ISC' 'other_pkg:BSD-2-Clause'.\n"
        opts.banner += "    Mixing the two formats is not allowed.\n"
        opts.banner += "    Additional args after a --read option are accepted.\n\n"
        opts.banner += "Options:"

        opts.on('-l', '--list', 'Print the list of supported licenses.') do
          options[:list] = License::Compatibility.license_data
          return options
        end

        opts.on('-r', '--read FILE', 'Read arguments from file.') do |file|
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

        opts.on('-h', '--help', 'Print this help.') do
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

      if packages
        return 'packages', prepared
      elsif licenses
        return 'licenses', prepared
      else
        return 'unknown', prepared
      end
    end
  end
end
