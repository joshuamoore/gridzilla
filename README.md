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

Check out the example app at https://github.com/joshuamoore/gridzilla\_app to
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

set\_loaded(grid\_name)
-------

set\_unloaded(grid\_name)
-------

get\_option(grid\_name, option\_name)
-------

set\_option(grid\_name, option\_name, value)
-------

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
