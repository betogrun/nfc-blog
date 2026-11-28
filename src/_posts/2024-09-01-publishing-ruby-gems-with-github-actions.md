---
layout: post
title: "Publishing Ruby Gems with GitHub Actions"
description: "Automate the release of Ruby gems with GitHub Actions"
tags: [automation, ruby, git, github]
---

In this post, I will demonstrate how GitHub Actions can be used to automate the process of publishing gems whenever a new version is created.

###### We will cover the following topics:
- Creating and publishing gems
- Introduction to GitHub Actions
- Gem versioning and changelog management
- Setting up GitHub Actions for gem publishing
- Automating the publishing process through tag creation

### Creating and Publishing Gems

In Ruby, code libraries are called gems. They can be found and installed from a public repository called [RubyGems](https://rubygems.org/){:target="_blank"}, which is the main hosting and management service for gems in the Ruby community. 

To create a new gem, you can use the `bundle gem` command, which is provided by the `bundler` gem. 

```shell
$ bundle gem my_gem
```

This command will generate the necessary files and directories for the gem.

```shell
my_gem
├── Gemfile
├── README.md
├── Rakefile
├── lib
│   ├── my_gem
│   │   └── version.rb
│   └── my_gem.rb
├── my_gem.gemspec
└── spec
    ├── my_gem_spec.rb
    └── spec_helper.rb
```

Once the gem is ready, you can build it using the `gem build` command, which will create a `.gem` file that can be published to RubyGems.

```shell
$ gem build my_gem.gemspec
```

After building the gem, you can publish it to RubyGems using the `gem push` command.

```shell
$ gem push my_gem-0.1.0.gem
```

PS: You need to have a RubyGems account and be authenticated to publish gems.

### GitHub Actions

Similar to other CI/CD tools, GitHub Actions allows you to automate tasks like testing, linting, and deployments. The configuration is done through YAML files that define which processes will be executed based on specific events, such as a commit to a particular branch.

The example below shows a simple GitHub Actions workflow that will run the tests for a Ruby application whenever a new commit is pushed to the `main` branch:

```yaml
name: RSpec tests

on: 
  push:
    branches:
      - main

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up Ruby
      uses: actions/setup-ruby@v1
      with:
        ruby-version: '3.4'

    - name: Install dependencies
      run: bundle install

    - name: Run tests
      run: bundle exec rspec
```

### Gem versioning and changelog management

When we are satisfied with the gem code and want to release a new version, we need to follow some practices to ensure that the gem is correctly versioned and documented.

Let's use the [lean-microsoft-graph](https://github.com/betogrun/lean-microsoft-graph){:target="_blank"} gem as an example, where a new feature was added and some dependencies were updated in this [Pull Request](https://github.com/betogrun/lean-microsoft-graph/pull/58){:target="_blank"}.

After merging the code, we can create a new Pull Request changing the version number and updating the `CHANGELOG.md` file.

Before proceding, it is important to mention the [Semantic Versioning](https://semver.org/){:target="_blank"} guidelines, that follows the format `MAJOR.MINOR.PATCH`. 

###### The version number is incremented based on the type of changes made:
- **Major**: for incompatible API changes
- **Minor**: for new functionality in a backwards-compatible manner
- **Patch**: for backwards-compatible bug fixes

The version file is located at `lib/lean/microsoft/graph/version.rb`. A new feature without breaking changes calls for a minor bump, which would make it `0.4.0`; this release went out as a patch, `0.3.4`, so that is the version used from here on.

```ruby
module LeanMicrosoftGraph
  VERSION = "0.3.4"
end
```

Now we need to update the `CHANGELOG.md` file with the changes made in the new version.

```markdown
# Changelog

<!-- Additional logs omitted for brevity. -->

## [0.3.4] - 2024-08-30

### Added

- Ability to retrieve users by id with `client.users.get_by_id('id')`.

### Changed

- Upgrade dependencies: faraday, mocha and minitest.

<!-- Additional logs omitted for brevity. -->

[0.3.4]: https://github.com/betogrun/lean-microsoft-graph/releases/tag/v0.3.4
```

Please, take a look at the [Keep a Changelog](https://keepachangelog.com/){:target="_blank"} website for more information on how to document the changes in the `CHANGELOG.md` file.

At this point, we could build and publish the gem manually, but we want to automate this process using GitHub Actions.

### Setting up GitHub Actions for gem publishing

To automate the process, we need to create a GitHub Workflow, which is a YAML file located in the .github/workflows directory. If it doesn't already exist, we can create it manually or use GitHub to generate an initial file. In the case of the [lean-microsoft-graph](https://github.com/betogrun/lean-microsoft-graph){:target="_blank"} gem, there was already a ruby.yml file responsible for running unit tests, as seen in this [Pull Request](https://github.com/betogrun/lean-microsoft-graph/pull/19/files){:target="_blank"}.


Github actions will need an authentication token to publish the gem to RubyGems. This token should be stored in the repository secrets and passed to the workflow as an environment variable. The token can be obtained from RubyGems website.

###### Follow these steps to add the token to the repository secrets:
1. Go to `Settings` in the repository.
2. Navigate to `Secrets and variables` and click on `Actions`.
3. Click on `New repository secret`.
4. Name the secret RUBYGEMS_AUTH_TOKEN, paste the obtained token, and click `Add Secret`.

Now we need to add a new job to the existing YAML file to handle the steps required to publish the gem.
We could also handle the publication process in a separate workflow file, but in this case, we will add it to the existing file.

Let's add a new job called `publish` to the existing YAML file:

```yaml
jobs:
  publish:
    needs: test
    runs-on: ubuntu-latest
    if: startsWith(github.ref, 'refs/tags/v')
```

###### In the example above, we:
- Added the `needs` keyword to specify that the publish job should wait for the test job to complete successfully before running. This creates a dependency that ensures the tests are executed first.
- Specified the environment where the job will run. In this example, the job runs on the latest version of Ubuntu.
- Included a condition to the job to ensure that it only runs when a new tag starting with `v` is created, indicating a version release.

Now, we need to define the step to set up the environment. In this example, we set up Ruby and define the Ruby version to use:

```yaml
  steps:
    - uses: actions/checkout@v3  # Check out the repository code

    - name: Set up Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: '3.4'  # Specify the Ruby version to use
```

Lastly, we need to add the step to build and publish the gem.<br>
First, we create the `.gem` directory and the credentials file. Then, we set the permissions for the file and write the authentication token to it.

```yaml
    - name: Publish to RubyGems
      run: |
        mkdir -p $HOME/.gem
        touch $HOME/.gem/credentials
        chmod 0600 $HOME/.gem/credentials
        printf -- "---\n:rubygems_api_key: ${GEM_HOST_API_KEY}\n" > $HOME/.gem/credentials
```

Then we build the gem and push it to RubyGems:

```yaml
        gem build *.gemspec
        gem push *.gem
```

We can't forget to use the `env` keyword to pass the RubyGems authentication token from the repository secrets:

```yaml
      env:
        GEM_HOST_API_KEY: ${{ secrets.RUBYGEMS_AUTH_TOKEN  }}
```

The complete job for publishing the gem should look like this:

```yaml
publish:
    needs: test
    runs-on: ubuntu-latest
    if: startsWith(github.ref, 'refs/tags/v')
    steps:
      - uses: actions/checkout@v3
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.4'
      - name: Publish to RubyGems
        run: |
          mkdir -p $HOME/.gem
          touch $HOME/.gem/credentials
          chmod 0600 $HOME/.gem/credentials
          printf -- "---\n:rubygems_api_key: ${GEM_HOST_API_KEY}\n" > $HOME/.gem/credentials
          gem build *.gemspec
          gem push *.gem
        env:
          GEM_HOST_API_KEY: ${{ secrets.RUBYGEMS_AUTH_TOKEN  }}
```

### Automating the publishing process through tag creation

Finally, after merging the [Pull Request](https://github.com/betogrun/lean-microsoft-graph/pull/60){:target="_blank"} that updates the gem version and the changelog, the next step is to create a new tag for the new version by running the following command:

```shell
$ git tag -a v0.3.4 -m "Version 0.3.4"
```

The `-a` flag creates an annotated tag, and the `-m` flag adds a message to the tag. Both are optional.

After that, we need to push the tag to the remote repository on GitHub:

```shell
$ git push origin v0.3.4
```

After pushing the tag, the GitHub Actions workflow will be triggered, and the gem will be built and published to RubyGems.

The result of the workflow can be checked in the Actions tab of the repository.

![Github actions workflow](/images/post_2024_8_30/github-actions.png){: .zooming}

The new version of the gem will be available on RubyGems, and the changes will be reflected in the [gem page](https://rubygems.org/gems/lean-microsoft-graph){:target="_blank"}.

### Conclusion

This post demonstrated how to automate the process of publishing Ruby gems using GitHub Actions, and also covered the best practices for versioning and changelog management.<br>
Please fell free to share how you are using GitHub Actions to automate your workflows and your favorite approaches to gem versioning and publishing.

### References

- [RubyGems](https://rubygems.org/){:target="_blank"}
- [GitHub Actions](https://docs.github.com/en/actions){:target="_blank"}
- [Semantic Versioning](https://semver.org/){:target="_blank"}
- [Keep a Changelog](https://keepachangelog.com/){:target="_blank"}