Link-o-matic
============

Description
-----------

This is a project to help automate the insertion of links to digitized records into 
EAD finding aids.

Code Repository
---------------

The code lives in the Berkman Center's [GitHub repo](https://github.com/berkmancenter/linkomatic).

User Documentation
------------------

We're in the process of finalizing user documentation, but once it's up this
will get updated with a pointer to it.

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
  * `git clone https://github.com/berkmancenter/linkomatic`
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
* Create an admin user
  * Sign up for an account
  * Use the console (`rails c`) to set the admin attribute on that user, e.g.
    `User.find(3).update_attribute('admin', true)`

Tested Configurations
---------------------

* Phusion Passenger, Ruby 2.1.2, Apache 2.2, Ubuntu 12.04 LTS
* Phusion Passenger, Ruby 2.1.4, Apache 2.4, Ubuntu 14.04 LTS

Issue Tracker
-------------

We maintain a closed-to-the-public [issue tracker](https://cyber.law.harvard.edu/projectmanagement/projects/linkomatic). Any additional issues can be added to the [GitHub issue tracker](https://github.com/berkmancenter/linkomatic/issues).

Built With
----------

The generous support of the [Harvard Library
Lab](http://lab.library.harvard.edu/), the [Harvard Library Office for
Scholarly Communication](https://osc.hul.harvard.edu), the [Berkman Center for
Internet &amp; Society](http://cyber.law.harvard.edu) and the [Arcadia
Fund](http://www.arcadiafund.org.uk)

### Technologies
* [Rails](http://rubyonrails.org/)
* [Bootstrap](http://getbootstrap.com/)
* [PostgreSQL](http://www.postgresql.org/)
* [Redis](http://redis.io/)

Contributors
------------

[Justin Clark](https://github.com/jdcc)

License
-------

Apache 2.0 - See the LICENSE file for details.

Copyright
---------

Copyright &copy; 2014 President and Fellows of Harvard College
