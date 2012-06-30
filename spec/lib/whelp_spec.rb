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

  it 'parses results as json' do
    mock_results = double
    mock_results.stub(:body).and_return(mock_results)
    mock_adapter.instance_variable_set :@results,mock_results

    JSON.should_receive(:parse).with(mock_results)

    mock_adapter.results
  end

  it 'instantiates results' do
    mock_results = {
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
        "mobile_url"=>"http://m.yelp.com/biz/rice-paper-falls-church",
        "rating_img_url"=>
         "http://media3.ak.yelpcdn.com/static/201206261235323114/img/ico/stars/stars_3_half.png",
        "review_count"=>70,
        "name"=>"Rice Paper",
        "snippet_image_url"=>
         "http://s3-media1.ak.yelpcdn.com/photo/7QMsdHHg7FuEZCkwoq5tSw/ms.jpg",
        "rating_img_url_small"=>
         "http://media3.ak.yelpcdn.com/static/201206263952475669/img/ico/stars/stars_small_3_half.png",
        "url"=>"http://www.yelp.com/biz/rice-paper-falls-church",
        "phone"=>"7035383888",
        "snippet_text"=>
         "We went for a late lunch - which is probably the only time you can go there without waiting in line. \n\nThe food was very good and the service friendly and...",
        "image_url"=>
         "http://s3-media2.ak.yelpcdn.com/bphoto/0cCJy061YzV77J0k9BmwOw/ms.jpg",
        "categories"=>[["Vietnamese", "vietnamese"]],
        "display_phone"=>"+1-703-538-3888",
        "rating_img_url_large"=>
         "http://media1.ak.yelpcdn.com/static/201206261161255655/img/ico/stars/stars_large_3_half.png",
         "review_count"=>70,
             "name"=>"Rice Paper",
             "snippet_image_url"=>
              "http://s3-media1.ak.yelpcdn.com/photo/7QMsdHHg7FuEZCkwoq5tSw/ms.jpg",
             "rating_img_url_small"=>
              "http://media3.ak.yelpcdn.com/static/201206263952475669/img/ico/stars/stars_small_3_half.png",
             "url"=>"http://www.yelp.com/biz/rice-paper-falls-church",
             "phone"=>"7035383888",
             "snippet_text"=>
              "We went for a late lunch - which is probably the only time you can go there without waiting in line. \n\nThe food was very good and the service friendly and...",
             "image_url"=>
              "http://s3-media2.ak.yelpcdn.com/bphoto/0cCJy061YzV77J0k9BmwOw/ms.jpg",
             "categories"=>[["Vietnamese", "vietnamese"]],
             "display_phone"=>"+1-703-538-3888",
             "rating_img_url_large"=>
              "http://media1.ak.yelpcdn.com/static/201206261161255655/img/ico/stars/stars_large_3_half.png",
             "id"=>"rice-paper-falls-church",
             "is_closed"=>false,
             "location"=>
              {
               "city"=>"Falls Church",
               "display_address"=>["6775 Wilson Blvd", "Falls Church, VA 22044"],
               "geo_accuracy"=>8,
               "postal_code"=>"22044",
               "country_code"=>"US",
               "address"=>["6775 Wilson Blvd"],
               "coordinate"=>{"latitude"=>38.872902, "longitude"=>-77.1532816},
               "state_code"=>"VA"
               }
      }]
    }

  end

end