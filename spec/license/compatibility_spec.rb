require 'spec_helper'

describe License::Compatibility do
  it 'has a version number' do
    expect(License::Compatibility::VERSION).not_to be nil
  end

  it 'GPL-3.0 software can be built on MIT software' do
    expect(License::Compatibility.forward_compatiblity('MIT', 'GPL-3.0')).to eq(true)
  end

  it 'MIT software cannot be built on GPL-3.0 software' do
    expect(License::Compatibility.forward_compatiblity('GPL-3.0', 'MIT')).to eq(false)
  end

  it 'MIT software can be built on Public Domain software' do
    expect(License::Compatibility.forward_compatiblity('Unlicense', 'MIT')).to eq(true)
  end

  it 'MIT software can be built on LGPL software' do
    expect(License::Compatibility.forward_compatiblity('LGPL-2.0', 'MIT')).to eq(true)
  end

  it 'Public Domain software software cannot be built on AGPL software' do
    expect(License::Compatibility.forward_compatiblity('AGPL-3.0','Unlicense')).to eq(false)
  end
end
