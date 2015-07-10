Devise iOS Rails Backend
====================================

Gem that updates devise to work with external clients. Specially created to work with [devise for iOS][ios_devise].

It currently implements authentication only with a "simple token authentication".

Requirements
============

| Name |  Version |
| :--: | :---: |
| [Ruby][ruby] | 2.1.5 |
| [Rails][rails] | 4.1.8 |
| [Devise][devise] | |
| [Simple Token Authentication][simple_token_authentication] | |
| [Active Model Serializers][active_model_serializers] | |

Setup
=====

With a working devise environment, the only thing you need to do is:

- add gem to the Gemfile `gem 'devise-ios-rails'`
- run bundler to install the gem `bundle install`
- setup devise like you would normally do ([check the installation guide][devise])
- in your routes change `devise_for ModelName` with `devise_ios_rails_for ModelName` (ModelName is usually User)
- authentication is handled by user token which is generated for each user during the registration process. 

To make it work you need to run migration that adds `authentication_token` column to your Devise model.
If your ModelName is `User` then the migration should look like this:
```ruby
class AddUniqueTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :authentication_token, :string
    add_index :users, :authentication_token, unique: true
  end
end
```
Don't forget about `rake db:migrate`.

-To protect actions to only registered users, add `acts_as_token_authentication_handler_for User` in your controller:

```ruby
class SecretSpacesController < ApplicationController
  acts_as_token_authentication_handler_for User
end
```

- If you want to skip authentication for some actions add `skip_before_filter :authenticate_user_from_token!, only: [:action]` in your controller

```ruby
class SecretSpacesController < ApplicationController
  acts_as_token_authentication_handler_for User
  skip_before_filter :authenticate_user_from_token!, only: [:new]
end
```

Facebook
========

To sign in using Facebook include DeviseIosRails::Oauth in your model after the devise method:

```ruby
class User < ActiveRecord::Base
  acts_as_token_authenticatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  include DeviseIosRails::OAuth
end
```

Add required fields to the model (keep in mind that you might not get e-mail address from the provider):

```ruby
class AddOauthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :uid, :string
    add_column :users, :provider, :string
    add_column :users, :oauth_token, :string

    change_column :users, :email, :string, :null => true

    add_index :users, [:uid, :provider], unique: true
  end
end
```

And update routes:

```ruby
devise_scope :user do
  post 'users/auth/facebook', to: 'devise_ios_rails/oauth#facebook'
end
```

Example app
===========

- [Rails with devise and Simple Authentication Token authentication][rails_example_app]

Testing
=======

In order to run tests, first you need setup the gem locally.

* clone the repo to your machine `git clone https://github.com/netguru/devise-ios-rails.git`
* go inside gems directory `cd devise-ios-rails` and run bundle command `bundle install`
* now you need to setup your environment variables. You can simply just copy over `.env.sample` to `.env`. It should look more or less like this:

```
DOMAIN_NAME='localhost:3000'
DOMAIN_URL='http://localhost:3000'
SECRET_KEY_BASE='a_very_long_string'
DEFAULT_SENDER='no-reply@no-reply.com'
```

then you can run your tests by typing `rspec`.


Contribution
============

First, thank you for contributing!

Here's a few guidelines to follow:

- we follow [Ruby Style Guide][ruby_style_guides].
- you can use [rubocop][rubocop] which can be easily integrated with popular editors. ([our rubocop config][rubocop_config])
- write tests
- make sure the entire test suite passes
- make sure rubocop passes our config
- open a pull request on GitHub
- [squash your commits][squash_commits] after receiving feedback

You can also read our blog post [announcing devise-iOS for simplified auth](https://netguru.co/blog/open-source-announcing-devise-ios).

Copyright  2014-2015 © [Netguru][netguru_url], released under the New BSD License

[ios_devise]: https://github.com/netguru/devise-ios

[ruby]: https://www.ruby-lang.org
[rails]: http://www.rubyonrails.org
[devise]: https://github.com/plataformatec/devise
[simple_token_authentication]: https://github.com/gonzalo-bulnes/simple_token_authentication
[active_model_serializers]: https://github.com/rails-api/active_model_serializers
[ruby_style_guides]: https://github.com/bbatsov/ruby-style-guide
[rubocop]: https://github.com/bbatsov/rubocop
[rubocop_config]: https://github.com/netguru/hound/blob/master/config/rubocop.yml
[squash_commits]: http://blog.steveklabnik.com/posts/2012-11-08-how-to-squash-commits-in-a-github-pull-request
[netguru_url]: https://netguru.co
[rails_example_app]: https://github.com/netguru/devise-ios-rails-example
