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
    body: %q|<dao xlink:actuate="onRequest" xlink:href="{{ url }}" xlink:show="new" xlink:type="simple" xmlns:xlink="http://www.w3.org/1999/xlink">
  <daodesc>
      <p>{{ link_text }}</p>
  </daodesc>
</dao>|,
    public: true
  },
  {
    name: 'With Thumbnail',
    body: %q|<daogrp xlink:type="extended" xmlns:xlink="http://www.w3.org/1999/xlink">
  <resource xlink:label="start" xlink:type="resource"/>
  <daoloc xlink:href="{{ thumbnail_url }}" xlink:label="resource-1" xlink:type="locator"/>
  <arc xlink:from="start" xlink:show="embed" xlink:to="resource-1" xlink:type="arc"/>
  <daoloc xlink:href="{{ url }}" xlink:label="resource-2" xlink:type="locator">
    <daodesc>
      <p>{{ link_text }}</p>
    </daodesc>
  </daoloc>
  <arc xlink:from="start" xlink:show="new" xlink:to="resource-2" xlink:type="arc"/>
</daogrp>|,
    public: true
  }
])

