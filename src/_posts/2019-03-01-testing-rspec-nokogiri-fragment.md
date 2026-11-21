---
layout: post
title: "Testing with Rspec and Nokogiri Fragment"
description: "Testing a web scraper with Rspec and Nokogiri fragment"
tags: [ruby, rspec, scraper, nokogiri]
---
A widely used approach to test web scrapers is to use the [VCR](https://github.com/vcr/vcr) gem to record the requests made to the target website and use the recorded response to test the parsers.

I had to test a class that depends on Nokogiri while building the [esaj](https://github.com/betogrun/esaj) scraper, but I could not use this procedure since the class being tested was initialized with a `Nokogiri::XML::Element` element:

{% highlight ruby %}
class ResultItem
  attr_reader :element

  def initialize(element)
    @element = element.children[1]
  end

  def attributes
    {
      code: code,
      date: date
    }
  end

  private

  def code
    element.at_css('a').text.strip
  end

  def date
    Date.parse(receipt_data.first[-10..-1])
  end

  def receipt_data
    element.children[children_count-2].text.split(' - ').map(&:strip)
  end

  def children_count
    element.children.count
  end
end
{% endhighlight  %}

No request would be performed in this scenario.

### Nokogiri::HTML::fragment

The chosen solution was to use the "Nokogiri::HTML::fragment" method to instantiate the element to be tested with the HTML fragment retrieved from a file fixture.

The fixture was created in `spec/fixture/result_item_fragment`<br> and the Nokogiri fragment method was wrapped in module created in `spec/helpers`:

{% highlight ruby %}
module Helpers
  def element_for(fragment_file_name)
    fragment_for(fragment_file_name)&.children[0]
  end

  def fragment_for(file_name)
    Nokogiri::HTML::fragment(File.read("spec/fixtures/#{file_name}"))
  end
end
{% endhighlight %}

The `spec_heper` was updated in order to make the above helper available for all specs.

{% highlight ruby %}
require_relative 'helpers'

RSpec.configure do |config|
  config.include Helpers
end
{% endhighlight %}

### Clean code
This approach allows a test class without doubles or stubs making the code lean and clean.

{% highlight ruby  %}
RSpec.describe ResultItem do
  subject { described_class.new(element)  }
  let(:element) { element_for('result_item_fragment')  }

  describe '#attributes' do
    it do
      expect(subject.attributes).to eq(
        {
          code: "0418538-39.1999.8.26.0053",
          date: Date.parse("1999-09-03")
        }
      )
    end
  end
end
{% endhighlight  %}

The full code is available [here](https://github.com/betogrun/esaj).

###### Sources
 - <https://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri%2FHTML.fragment>
 - <https://relishapp.com/rspec/rspec-core/v/3-8/docs/helper-methods/define-helper-methods-in-a-module>
