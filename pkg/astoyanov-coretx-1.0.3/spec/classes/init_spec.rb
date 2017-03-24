require 'spec_helper'
describe 'coretx' do
  context 'with default values for all parameters' do
    it { should contain_class('coretx') }
  end
end
