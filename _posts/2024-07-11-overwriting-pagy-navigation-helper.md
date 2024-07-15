---
layout: post
title:  "Overwriting the Pagy Navigation Helper"
description: "Discover how to seamlessly integrate DaisyUI's pagination component into your Rails app by customizing the Pagy navigation helper."
tags: [rails, pagy, tailwindcss, daisyui]
---

### Introduction
[Pagy](https://github.com/ddnexus/pagy){:target="_blank"} is a pagination gem for Rack frameworks like Ruby on Rails, Sinatra, Hanami, etc. It is faster than other pagination gems and it is very flexible to use.

For styling, the Pagy documentation suggests using CSS, which is also suitable for TailwindCSS. While this works well in most cases, if you are using a TailwindCSS component library like [DaisyUI](https://daisyui.com/){:target="_blank"}, you might want to utilize the pagination template provided by DaisyUI.

This post present an alternative solution where we will see how we can customize the pagination template by overwriting the Pagy navigation helper.

### Example

Let's consider a simple Rails application where we have a list of items and we want to paginate them. We will use the Pagy gem for pagination and DaisyUI for styling.

Assuming the Pagy gem is already installed in the Rails application, we can paginate the items in the controller as follows:

{% highlight ruby %}
class ItemsController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @items = pagy(Item.all, items: 10)
  end
end
{% endhighlight %}

Don't forget to include the Pagy module in the application helper:

{% highlight ruby %}
module ApplicationHelper
  include Pagy::Frontend
end
{% endhighlight %}

Now, in the view file, we can use the `pagy_nav` helper to render the pagination component:

{% highlight html %}
<%= pagy_nav(@pagy) if @pagy.pages > 1 %>
{% endhighlight %}

### DaisyUI Pagination component

From the [DaisyUI documentation](https://daisyui.com/components/pagination){:target="_blank"}, the pagination component is as follows:

{% include image.html path="post_2024_7_11/daisyui-pagination-sample" path-detail="post_2024_7_11/daisyui-pagination-sample" alt="DaisyUI Pagination component" %}


{% highlight html %}
<div class="join">
  <button class="join-item btn">1</button>
  <button class="join-item btn">2</button>
  <button class="join-item btn btn-disabled">...</button>
  <button class="join-item btn">99</button>
  <button class="join-item btn">100</button>
</div>
{% endhighlight %}

Let's use this pagination component in our Rails application to overwrite the Pagy navigation helper.

### The pagy object

The Pagy object offers methods to get the current page and the series of pages. We can use these methods to build our custom pagination component.


{% highlight ruby %}
#current page
pagy.page #=> 1

#series of pages
pagy.series #=> [1, 2, :gap, 99, 100]

#previous page
pagy.prev #=> 1

#next page
pagy.next #=> 2

#url for the page
pagy_url_for(pagy, 3) #=> "/items?page=3"
{% endhighlight %}

### Overwriting the Pagy navigation helper

The pagy documentation provides a static [example](https://ddnexus.github.io/pagy/docs/how-to/#using-your-pagination-templates){:target="_blank"} of the pagination component that complies with the [ARIA standard](https://www.w2.org/WAI/standards-guidelines/aria/){:target="_blank"}.

We will use this as a reference to build our custom pagination helper.

To overwrite the Pagy navigation helper, we need to create a new helper method in the `ApplicationHelper` module. This method will render the pagination component using the DaisyUI template.

{% highlight ruby %}
module ApplicationHelper
  include Pagy::Frontend

  def pagy_nav(pagy)
    html = %(<div class="join" aria-label="Pages">)

    if pagy.prev
      html << %(<a href="#{pagy_url_for(pagy, pagy.prev)}" class="join-item btn" aria-label="Previous">«</a>)
    else
      html << %(<button class="join-item btn" aria-disabled="true" aria-label="Previous">«</button>)
    end

    pagy.series.each do |item|
      if item.is_a? Integer
        html << %(<a href="#{pagy_url_for(pagy, item)}" class="join-item btn">#{item}</a>)
      elsif item.is_a? String
        html << %(<button class="join-item btn btn-active" aria-disabled="true" aria-current="page">#{item}</button>)
      elsif item == :gap
        html << %(<button class="join-item btn btn-disabled" aria-disabled="true">...</button>)
      end
    end

    if pagy.next
      html << %(<a href="#{pagy_url_for(pagy, pagy.next)}" class="join-item btn" aria-label="Next">»</a>)
    else
      html << %(<button class="join-item btn" aria-disabled="true" aria-label="Next">»</button>)
    end

    html << %(</div>)

    html.html_safe
  end
end
{% endhighlight %}

No changes are required in the controller or the view file. The pagination component will be rendered using the DaisyUI template and the result should look like this:

{% include image.html path="post_2024_7_11/custom-daisyui-pagination-sample" path-detail="post_2024_7_11/custom-daisyui-pagination-sample" alt="DaisyUI Pagination component" %}

### Conclusion

In this post, we have seen how we can overwrite the Pagy navigation helper to use a custom pagination component. We have used the DaisyUI pagination component as an example, but you can use any other pagination component by modifying the helper method accordingly. This approach allows you to customize the pagination component according to your needs.

#### References
- [Pagy](https://ddnexus.github.io/pagy/){:target="_blank"}
- [DaisyUI](https://daisyui.com/){:target="_blank"}
