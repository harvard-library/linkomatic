# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Template.create([
  {
    name: 'Without Thumbnail',
    body: %q|<dao xmlns:xlink="http://www.w3.org/1999/xlink" linktype="simple" xlink:actuate="onRequest" xlink:show="new" href="{{ url }}">
  <daodesc>
    <p>{{ link_text }}</p>
  </daodesc>
</dao>|,
    public: true
  },
  {
    name: 'With Thumbnail',
    body: %q|<daogrp linktype="extended">
  <resource xmlns:xlink="http://www.w3.org/1999/xlink" linktype="resource" xlink:label="start"/>
  <daoloc xmlns:xlink="http://www.w3.org/1999/xlink" linktype="locator" xlink:label="resource-1" href="{{ thumbnail_url }}"/>
  <arc xmlns:xlink="http://www.w3.org/1999/xlink" linktype="arc" xlink:actuate="onLoad" xlink:from="start" xlink:show="embed" xlink:to="resource-1"/>
  <daoloc xmlns:xlink="http://www.w3.org/1999/xlink" linktype="locator" xlink:label="resource-2" href="{{ url }}"/>
  <arc xmlns:xlink="http://www.w3.org/1999/xlink" linktype="arc" xlink:from="start" xlink:show="new" xlink:to="resource-2"/>
</daogrp>|,
    public: true
  }
])

