Gridzilla
=========

Gridzilla is a griding addition for Rails projects which allows users to
list and perform actions on rows.

Installation Steps
=======

Run the generator to place the images, javascript, stylesheet, and initializer in the
correct locations with this command:

rails g gridzilla:install

Next, add this line to your config/routes.rb file:

match '/gridzilla/:controller/:action' => '#index', :gridzilla => true

Last, add this line above the initialize! call to your config/environment.rb file:

require 'will_paginate'

Examples
=======

Check out the example app at https://github.com/joshuamoore/gridzilla_app to
find usage examples.

Copyright (c) 2013 GradesFirst, released under the MIT license
