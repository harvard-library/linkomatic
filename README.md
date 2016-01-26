Link-o-matic
============

Description
-----------

This is a project to help automate the insertion of links to digitized records into
EAD finding aids.

Code Repository
---------------

[GitHub repo](https://github.com/harvard-library/linkomatic).

User Documentation
------------------

User documentation exists in the `doc` folder.

Requirements
------------

* Git
* Ruby >= 2
* Bundler
* PostgreSQL (including -dev packages)
* Redis server

Bundler should take care of the rest.

Setup
-----

* Install requirements (see above)
* Checkout the code
  * `git clone https://github.com/harvard-library/linkomatic`
  * `cd linkomatic`
* Install libraries
  * `bundle install`
* Configure the database
  * `cp config/database.yml.example config/database.yml`
  * Setup a postgres user and update `config/database.yml` accordingly
  * `rake db:create`
  * `rake db:setup`
* Configure the websockets server
  * If you're using Apache, you'll need to setup `config/initializers/websocket_rails.rb` according to [this](https://github.com/websocket-rails/websocket-rails/wiki/Standalone-Server-Mode)
  * Configure `config.websocket_url` somewhere in your app config, probably in the various `config/environments/`
  * Again, if you're using Apache, you'll need to run `rake websocket_rails:start_server`
* Start sidekiq workers
  * `sidekiq --daemon --concurrency 10 --logfile tmp/sidekiq.log`
  * In production systems, create a `.env` file for your environment.  Currently, the following variables are needed to run Link-o-matic:

    ```
    ROOT_URL=mybaseurl.com # Note: If not present, defaults to result of Socket.gethostname
    SECRET_TOKEN=ThirtyPlusCharStringOfRandomnessFromRakeSecretMaybe
    DEVISE_SECRET_KEY=anotherThirtyPlusCharsOfRandomness
    DEVISE_PEPPER=moreRandomnessGoesHere # Currently needed on production due to [devise issue](https://github.com/plataformatec/devise/issues/3565)
    REDIS_URL=redis://:password@localhost:6379/12 # Only needed if requirespassword
    OLIVIA_URL=http://location.of.olivia.harvard.edu:9001/olivia/servlet/OliviaServlet # If nor present, defaults to test olivia
    ```
* Update the devise configs
  * Update the `config.mailer_sender` in `config/initializers/devise.rb`
* Stand up the application. In development, `rails s` works fine
* Create an admin user via the application's web interface
  * Sign up for an account
  * Use the console (`rails c`) to set the admin attribute on that user, e.g.
    `User.find_by(:email => 'email.you.used@host.com').update_attribute('admin', true)`

Tested Configurations
---------------------

* Phusion Passenger, Ruby 2.1.2, Apache 2.2
* Phusion Passenger, Ruby 2.1.4, Apache 2.4

Issue Tracker
-------------

Any issues can be added to the [GitHub issue tracker](https://github.com/harvard-library/linkomatic/issues).

Built With
----------

The generous support of the [Harvard Library
Lab](http://lab.library.harvard.edu/), the [Harvard Library Office for
Scholarly Communication](https://osc.hul.harvard.edu), the [Berkman Center for
Internet &amp; Society](http://cyber.law.harvard.edu) and the [Arcadia
Fund](http://www.arcadiafund.org.uk)

Additional development and ongoing support courtesy of [Library Technology Services](http://hul.harvard.edu/ois/) at Harvard University, a division of HUIT.

### Technologies
* [Rails](http://rubyonrails.org/)
* [Bootstrap](http://getbootstrap.com/)
* [PostgreSQL](http://www.postgresql.org/)
* [Redis](http://redis.io/)

Contributors
------------
* [Justin Clark](https://github.com/jdcc)
* [Bobbi Fox](https://github.com/bobbi-SMR)
* [Dave Mayo](https://github.com/pobocks) (Primary dev/contact)

License
-------

Apache 2.0 - See the LICENSE file for details.

Copyright
---------

Copyright &copy; 2014 President and Fellows of Harvard College
