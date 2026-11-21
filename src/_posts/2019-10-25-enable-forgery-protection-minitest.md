---
layout: post
title: "Enable Protect Against Forgery on MiniTest"
description: "How to enable Protect Against Forgery on Ruby on Rails tests using MiniTest"
tags: [ruby, rails, minitest]
---


By default, protection against forgery is disabled on test environment for Rails applications.

{% highlight console %}
config.action_controller.allow_forgery_protection = false
{% endhighlight  %}

If you have few test cases that need protection against forgery to be enabled, instead of changing the default option to true, you can enable it by mocking the `ActionController::Base` instance.
Since there is no out of box solution to mock any instance of a given class the solutions presented will depend on external gems.


# Mocking using Mocha

Make sure you have installed [Mocha](https://github.com/freerange/mocha) and then add the following line in the beginning of your test on in `before` block:


{% highlight ruby %}
ActionController::Base
  .any_instance
  .expects(:protect_against_forgery?)
  .at_least_once
  .returns(true)
{% endhighlight  %}

# Mocking using minitest-stub_any_instance


Install the [minitest-stub_any_instance gem](https://github.com/codeodor/minitest-stub_any_instance) and include your test inside the following block:


{% highlight ruby %}
ActionController::Base.stub_any_instance(:protect_against_forgery?, true) do
  # add your test here
end
{% endhighlight  %}

###### Source
 - This post is based on the RSpec solution for this problem presented on <https://blog.tomoyukikashiro.me/post/test-csrf-in-feature-test-using-capybara>.

