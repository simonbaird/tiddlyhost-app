Tiddlyhost App
==============

A Ruby on Rails application for creating and saving
[TiddlyWikis](https://tiddlywiki.com/) online.

This is the web application that runs on
[Tiddlyhost](https://tiddlyhost.com/).


Prerequisites
-------------

* ruby and bundler
* npm
* yarn
* podman or docker
* make

Ruby version 3.1.2 is required.

I'm using rbenv but you could use rvm or even your system ruby if you have
version 3.1.2 available.


Getting started
---------------

Some gems require compilation and hence there are some devel dependencies
which are not documented here.

    bundle install
    echo n | rails webpacker:install
    rails db:create db:migrate
    rails test

Tiddlyhost uses wildcard subdomains. To simulate this for local development,
add some entries to your `/etc/hosts` file:

    127.0.0.1 tiddlyhost.local
    127.0.0.1 aaa.tiddlyhost.local
    127.0.0.1 bbb.tiddlyhost.local
    127.0.0.1 foo.tiddlyhost.local
    127.0.0.1 bar.tiddlyhost.local

You should now be able to start rails like this:

    rails s

Visit <http://tiddlyhost.local:3333/> in your browser and you should see a working
web application.

### Create an account and create a site

Click "Sign up" and enter some details. A fake email address is fine.

Emails won't be sent when running locally, but you can find the email
confirmation link by running this:

    make signup-link

Click "Create Site" to create a site. Note that you need to use a site name
that matches something that you added to your /etc/hosts file, `aaa` or `bbb` for
example.

Click on the site to open it. Click the save button and confirm your site was
able to be saved.

Give your local user admin permissions by running this:

    rails runner 'User.first.update(plan_id: 2)'

Now reload the Tiddlyhost page in your browser and you should see the "Admin"
link.

Create other sites or other local accounts as required.


See also
--------

* [tiddlyhost.com](https://tiddlyhost.com)
* [simonbaird/tiddlyhost](https://github.com/simonbaird/tiddlyhost)
