require 'json'
require "license/compatibility/version"

module License
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
  end
end
