require 'spec_helper'
require 'whelp'

class MockObject

  whelpable :yelp do
    version 2
    configuration :options => 1
  end

end

describe Whelp do
  let(:mock_object) { MockObject.new }

  it 'is whelpable' do
    mock_object.should be_whelpable
  end

  it 'assigns an adapter' do
    adapter = mock_object.adapter
    adapter.class.should be Whelp::Adapters::Yelp
  end

  it 'configures the adapter' do
    adapter = mock_object.adapter
    adapter.version.should be 2
    adapter.configuration.should == { :options => 1 }
  end

  it 'delegates search to the adapter' do
    adapter = mock_object.adapter
    adapter.should_receive :search
    mock_object.search
  end

  it 'delegates getting results to the adapter' do
    adapter = mock_object.adapter
    adapter.should_receive :results
    mock_object.search && mock_object.results
  end

end

describe Whelp::Adapters::Yelp do
  let(:mock_adapter) do
    proc = Proc.new { version(2); configuration(:options => 1) }
    Whelp::Adapter.build :yelp,proc
  end

  it 'searches with a custom query' do
    mock_adapter.access_token.should_receive(:get)
    mock_adapter.search("query")
  end

  it 'searches with a block' do
    mock_adapter.access_token.should_receive(:get).with('/v2/search?' << 'term=restaurants&location=new%20york')
    mock_adapter.search do
      term 'restaurants'
      location 'new york'
    end
  end

  it 'parses results as json' do
    mock_results = double
    mock_results.stub(:body).and_return(mock_results)
    mock_adapter.instance_variable_set :@results,mock_results

    JSON.should_receive(:parse).with(mock_results)

    mock_adapter.results
  end

end