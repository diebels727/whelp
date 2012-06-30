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

  it 'delegates results to the adapter' do
    mock_object.stub(:search).and_return(true)
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

  it 'creates results' do
    Whelp::Adapters::Result.should_receive(:new)
    mock_adapter.results
  end

end

describe Whelp::Adapters::Result do

  it 'parses content with JSON' do
    body = double
    subject.stub(:body).and_return(body)

    JSON.should_receive(:parse).with(body)

    subject.all
  end

  context 'with instantiated results' do
    before do
      all = {
        "region"=>
        {
          "span"=>
          {
            "latitude_delta"=>0.12593679999999097,
            "longitude_delta"=>0.2128833299999826
          },
          "center"=>
          {
            "latitude"=>38.885987,
            "longitude"=>-77.16956915
          }
        },
        "total"=>39,
        "businesses"=>
        [{
          "is_claimed"=>false,
          "rating"=>3.5,
          "mobile_url"=>"http://business",
           "review_count"=>70,
               "name"=>"Business",
               "location"=>
                {
                 "city"=>"City",
                 "display_address"=>["6775 Wilson Blvd", "Falls Church, VA 22044"],
                 "address"=>["6775 Wilson Blvd"],
                 "coordinate"=>
                  {
                    "latitude"=>38.872902,
                    "longitude"=>-77.1532816
                  },
                 }
        }]
      }

      subject.stub(:all).and_return(all)
      subject.instantiate_results!
    end

    it 'totals results' do
      subject.total.should be 39
    end

    it 'initializes businesses' do
      subject.businesses.count.should be 1
    end

  end


end