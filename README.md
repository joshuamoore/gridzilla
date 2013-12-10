Gridzilla
=========

Gridzilla is a griding dsl for Rails projects which allows users to
list and perform actions on rows of data.

Installation Steps
=======

Run the generator to place the images, javascript, stylesheet, and initializer in the
correct locations with this command:

rails g gridzilla:install

Next, add this line to your config/routes.rb file:

match '/gridzilla/:controller/:action' => '#index', :gridzilla => true

Last, add this line above the initialize! call to your config/environment.rb file:

require 'will\_paginate'

Examples
=======

    - grid "name_of_grid", collection do
      - title "This is a sample grid"
      - panel do
        != action_function 'Do Something', 'do_something_js_function'
      - rows do |collection_item|
        - select_column :item_attribute
        - row_number_column
        - column :item_attribute
        - column "Column Header", :class => "css_class" do
          = collection_item.attribute
        - if_empty do
          This collection contains no items!!!
      - panel do
        != pagination_links

Check out the example app at [https://github.com/joshuamoore/gridzilla\_app](https://github.com/joshuamoore/gridzilla_app) to
find usage examples.

Javascript API
=======
The Gridzilla API is namespaced under gridzilla.

get\_data(grid\_name)
-------
Get the data hash associated with the grid\_name. This data is used to provide 
context to the grid, especially for ajax grids when making subsequent requests.

set\_data(grid\_name, data)
-------
Set the data hash associated with the grid\_name. This data is used to provide 
context to the grid, especially for ajax grids when making subsequent requests.

is\_loaded(grid\_name)
-------
Indicates whether or not an AJAX grid is currently loaded.

get\_option(grid\_name, option\_name)
-------
Get options associated with the grid.
* grid\_name - the name of the grid to get options for.
* option\_name - the name of the option to retrieve a value for.

Gridzilla Options
* controller - the name of the controller associated with the grid.
* params - querystring parameters associated with the grid requests.
* single\_select - indicates whether or not the grid is restricted to single selection.
* multi\_page\_selected - indicates whether or not the user has performed a multi-page selection.
* height - the specified height of the grid in pixels.
* url - the url that requests are made for updates to the grid.

set\_option(grid\_name, option\_name, value)
-------
Set options associated with the grid.
* grid\_name - the name of the grid to set options for.
* option\_name - the name of the option to set a value for.
* value - the value to set the option to.

See get\_option for a list of Gridzilla specific otions.

setup(grid\_name)
-------

row\_click(element)
-------

select\_all\_adorning(grid\_jqo, grid\_name)
-------

deselect\_all(grid\_name)
-------

selected\_values(grid\_name, attribute)
-------

values(grid\_name, attribute)
-------

unload(grid\_name)
-------

block(grid\_name, message)
-------

load(grid\_name, options, callback)
-------

Copyright (c) 2013 GradesFirst, released under the MIT license
