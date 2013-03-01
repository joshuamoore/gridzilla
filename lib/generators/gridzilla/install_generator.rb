module Gridzilla
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../', __FILE__)

      desc 'Creates a gridzilla initializer, copies images folder and stylesheet, and adds gridzilla route.'

      def copy_locale
        if Gridzilla.pipeline_enabled?
          copy_file "initializer/gridzilla.rb", "config/initializers/gridzilla.rb"
          copy_file "stylesheets/gridzilla.sass", "app/assets/stylesheets/gridzilla.sass"
          copy_file "javascripts/jquery.blockUI.js", "app/assets/javascripts/jquery.blockUI.js"
          directory "images/", "app/assets/images/gridzilla/"
        else
          copy_file "initializer/gridzilla.rb", "config/initializers/gridzilla.rb"
          copy_file "stylesheets/gridzilla.sass", "public/stylesheets/gridzilla.sass"
          copy_file "javascripts/jquery.blockUI.js", "public/javascripts/jquery.blockUI.js"
          directory "images/", "public/images/gridzilla/"
        end
      end
    end
  end
end
