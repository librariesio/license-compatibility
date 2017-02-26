require 'spec_helper'

describe License::CommandLine do
  it 'parses correctly -v option' do
    options = License::CommandLine.parse(['-v'])
    expect(options[:version]).to match(/.*#{License::Compatibility::VERSION}.*/)
    expect(options[:help]).to be_nil
    expect(options[:read]).to be_nil
    expect(options[:list]).to be_nil
  end

  it 'parses correctly -h option' do
    options = License::CommandLine.parse(['-h'])
    expect(options[:help]).to match(/.*Print this help\..*/)
    expect(options[:version]).to be_nil
    expect(options[:read]).to be_nil
    expect(options[:list]).to be_nil
  end

  it 'parses correctly -l option' do
    options = License::CommandLine.parse(['-l'])
    expect(options[:list]).to match(License::Compatibility.license_data)
    expect(options[:version]).to be_nil
    expect(options[:read]).to be_nil
    expect(options[:help]).to be_nil
  end

  it 'parses correctly -r option with nonexistent file' do
    expect {
      License::CommandLine.parse(%w(-r its_gone))
    }.to raise_error(Errno::ENOENT, 'No such file or directory - its_gone')
  end

  it 'parses correctly -r option with existing file' do
    options = License::CommandLine.parse(%w(-r spec/license_list.txt))
    expect(options[:read]).to eq('spec/license_list.txt')
    options = License::CommandLine.parse(%w(--read spec/license_list.txt))
    expect(options[:read]).to eq('spec/license_list.txt')
    options = License::CommandLine.parse(['--read=spec/license_list.txt'])
    expect(options[:read]).to eq('spec/license_list.txt')
  end

  it 'parses correctly no option' do
    options = License::CommandLine.parse([])
    expect(options).to eq({})
    options = License::CommandLine.parse(%w(MIT ISC))
    expect(options).to eq({})
  end

  it 'fails when mixed args' do
    expect {
      License::CommandLine.parse_positional(%w(MIT PKG1:ISC))
    }.to raise_error(ArgumentError, 'do not mix license and package:license arguments')
  end

  it 'recognizes license list' do
    expect(License::CommandLine.parse_positional(%w(MIT ISC))).to eq(['licenses', %w(MIT ISC)])
  end

  it 'recognizes package:license list' do
    expect(License::CommandLine.parse_positional(%w(PKG1:MIT PKG2:ISC))).to eq(['packages', [%w(PKG1 MIT), %w(PKG2 ISC)]])
  end
end