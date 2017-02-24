require 'spec_helper'

describe License::CommandLine do
  it 'parses correctly -v option' do
    options = License::CommandLine.parse(['-v'])
    expect(options[:version]).to match(/.*#{License::Compatibility::VERSION}.*/)
    expect(options[:help]).to be_nil
    expect(options[:read]).to be_nil
  end

  it 'parses correctly -h option' do
    options = License::CommandLine.parse(['-h'])
    expect(options[:help]).to match(/.*Print this help\..*/)
    expect(options[:version]).to be_nil
    expect(options[:read]).to be_nil
  end

  it 'parses correctly -r option with nonexistent file' do
    expect {
      License::CommandLine.parse(['-r', 'its_gone'])
    }.to raise_error(ArgumentError, 'its_gone: no such file')
  end

  it 'parses correctly -r option with existing file' do
    options = License::CommandLine.parse(['-r', 'spec/license_list.txt'])
    expect(options[:read]).to eq('spec/license_list.txt')
    options = License::CommandLine.parse(['--read', 'spec/license_list.txt'])
    expect(options[:read]).to eq('spec/license_list.txt')
    options = License::CommandLine.parse(['--read=spec/license_list.txt'])
    expect(options[:read]).to eq('spec/license_list.txt')
  end

  it 'parses correctly no option' do
    options = License::CommandLine.parse([])
    expect(options).to eq({})
    options = License::CommandLine.parse(['MIT', 'ISC'])
    expect(options).to eq({})
  end

  # it 'fails when mixed args' do
  #   expect(License::CommandLine.check_positional_args(['MIT', 'PKG1:ISC'])).to raise_error
  # end
  #
  # it 'recognizes license list' do
  #   expect(License::CommandLine.check_positional_args(['MIT', 'ISC'])).to raise_error
  # end
  #
  # it 'recognizes package:license list' do
  #   expect(License::CommandLine.check_positional_args(['PKG1:MIT', 'PKG2:ISC'])).to raise_error
  # end
end