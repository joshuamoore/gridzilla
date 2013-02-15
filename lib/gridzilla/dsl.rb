module Gridzilla
  module Controller
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def gridzilla(&block)
        grid_builder = GridBuilder.new(self)
        block.bind(grid_builder).call
      end
    end

    class GridBuilder
      attr_accessor :context_object

      def initialize(context_object)
        @context_object = context_object
      end

      def method_missing(name, *args, &block)
        raise "No block given" unless block

        create_action("#{name}_grid") do
          block.bind(self).call
          unless performed?
            render :layout => false
          end
        end
      end

      private
      def create_action(name, &block)
        context_object.send(:define_method, name.to_sym, &block)
      end
    end
  end

  module View
    module InstanceMethods

      def grid(name, *args, &block)
        options    = args.extract_options!
        collection = args.shift

        raise ArgumentError, "Missing collection in grid definition" if !collection and block_given?

        grid_controller = params[:controller]

        if name =~ /\//
          name_parts      = name.split(/\//)
          grid_controller = name_parts.first
          name            = name_parts.last
        end
        grid_class = options[:class] || "gridzilla"
        data       = options[:data] || {}

        unless @gridzilla_script_loaded
          concat("<%= <script type='type/text' src='/javascripts/gridzilla.js'></script> %>")
          @gridzilla_script_loaded = true
        end

        concat(content_tag(:script, <<-SCRIPT, nil, false))
          gridzilla.set_data('#{name}', #{data.to_json});
          #{"gridzilla.set_option('#{name}', 'height', #{options[:height].to_json});" if options[:height]}
        #{"gridzilla.set_option('#{name}', 'form_var', #{options[:form_var].to_json});" if options[:form_var]}
        #{"gridzilla.set_option('#{name}', 'url', #{options[:url].to_json});" if options[:url]}
       SCRIPT

        if options[:form_var]
          concat("<input type='hidden' value='' id='#{options[:form_var]}' name='#{options[:form_var]}' />")
        end

        if block_given?
          @gridzilla ||= []
          @gridzilla.push({})
          @gridzilla.last[:grid_name]       = name
          @gridzilla.last[:grid_controller] = grid_controller
          @gridzilla.last[:collection]      = collection
          @gridzilla.last[:selected_items]  = options[:selected_items]

          concat(tag(:div, {:id => name, :class => grid_class}, true))
          view_dsl = Gridzilla::ViewDsl::Base.new(Gridzilla::View::Grid.new(self), self)
          view_dsl.instance_eval(&block)
          concat('</div>'.html_safe)

          concat(content_tag(:script, <<-SCRIPT,nil,false))
            setTimeout(function() {
              gridzilla.setup('#{name}');
              gridzilla.set_option('#{name}', 'controller', #{grid_controller.to_json});
              gridzilla.set_option('#{name}', 'params', #{request.query_parameters.to_json});
              gridzilla.set_option('#{name}', 'single_select', #{(!!@gridzilla.last[:single_select]).to_json});
              gridzilla.set_option('#{@gridzilla.last[:grid_name]}', 'multi_page_selected', false);
            }, 0);
          SCRIPT

          @gridzilla.pop
        else
          concat(content_tag(:div, "", :id => name, :class => grid_class))
          if options[:lazy]
            concat(content_tag(:script, <<-SCRIPT, nil, false))
              $(function() {
                gridzilla.set_option('#{name}', 'controller', #{grid_controller.to_json});
              });
            SCRIPT
          else
            concat(content_tag(:script, <<-SCRIPT, nil, false))
              $(function() {
                gridzilla.set_option('#{name}', 'controller', #{grid_controller.to_json});
                gridzilla.load('#{name}');
              });
            SCRIPT
          end

          if Rails.env.development?
            concat(content_tag(:div, content_tag(:a, 'reload grid', :href => '#', :onclick => "gridzilla.load('#{name}')", :class => 'reload_link'), :id => "#{name}_reloader"))
          end
        end
      end

      def ajax_grid(collection, *args, &block)
        options = args.extract_options!

        raise ArgumentError, "Missing block in ajax_grid definition" unless block_given?

        @gridzilla ||= []
        @gridzilla.push({})
        @gridzilla.last[:grid_controller] = params[:controller]
        @gridzilla.last[:grid_name]       = options[:grid_name] || params[:action][0..-6] # MAGIC_NUMBER(-6) removes the _grid on the action name
        @gridzilla.last[:collection]      = collection
        @gridzilla.last[:selected_items]  = options[:selected_items]
        @gridzilla.last[:multi_page_selector] = options[:multi_page_selector]
        view_dsl = Gridzilla::ViewDsl::Base.new(Gridzilla::View::AjaxGrid.new(self), self)
        view_dsl.instance_eval(&block)

        concat(content_tag(:script, <<-SCRIPT))
          gridzilla.set_option('#{@gridzilla.last[:grid_name]}', 'controller', #{@gridzilla.last[:grid_controller].to_json});
          gridzilla.set_option('#{@gridzilla.last[:grid_name]}', 'params', #{request.query_parameters.to_json});
          gridzilla.set_option('#{@gridzilla.last[:grid_name]}', 'single_select', #{(!!@gridzilla.last[:single_select]).to_json});
          gridzilla.set_option('#{@gridzilla.last[:grid_name]}', 'multi_page_selected', false);
        SCRIPT

        concat(content_tag(:script,<<-SCRIPT)) if options[:multi_page_selector]
          gridzilla.set_option('#{@gridzilla.last[:grid_name]}', 'multi_page_selector',#{options[:multi_page_selector].to_json});
          gridzilla.set_option('#{@gridzilla.last[:grid_name]}', 'total_records',#{collection.total_entries.to_json});
        SCRIPT

        @gridzilla.pop
      end

    end

    class Grid
      def initialize(view)
        @view      = view
        @gridzilla = @view.instance_variable_get('@gridzilla')
      end

      def title(*args, &block)
        options = args.extract_options!
        text    = args.shift

        raise ArgumentError, "Missing block or text in title definition" unless block_given? or text

        options[:class] = "#{Gridzilla::Css::Title} #{options[:class]}".strip

        if block_given?
          @view.concat(@view.tag(:div, options, true))
          yield
          @view.concat("</div>".html_safe)
        else
          @view.concat(@view.content_tag(:div, @view.content_tag(:h4, text), options))
        end
      end

      def panel(*args, &block)
        options = args.extract_options!

        options[:class] = "#{Gridzilla::Css::Panel} #{options[:class]}".strip

        raise ArgumentError, "Missing block in panel definition" unless block_given?

        view_dsl = Gridzilla::ViewDsl::Base.new(Gridzilla::View::Panel.new(@view), @view)

        @view.concat(@view.tag(:div, options, true))
        view_dsl.instance_eval(&block)
        @view.concat("<div class='clear'></div></div>".html_safe)
      end

      def rows(*args, &block)
        options = args.extract_options!

        raise ArgumentError, "Missing block in rows definition" unless block_given?

        view_dsl                     = Gridzilla::ViewDsl::Base.new(Gridzilla::View::Row.new(@view), @view)
        @gridzilla.last[:row_number] = if @gridzilla.last[:collection].respond_to? :total_pages
                                         @gridzilla.last[:collection].offset
                                       else
                                         0
                                       end

        if @gridzilla.last[:multi_page_selector] and @gridzilla.last[:collection].total_entries > @gridzilla.last[:collection].length
          @view.concat("<div class='#{Gridzilla::Css::Notice}' id='#{@gridzilla.last[:grid_name]}_multi_select'>")
          @view.concat("<span class='#{@gridzilla.last[:grid_name]}_multi_select'>#{@gridzilla.last[:collection].length} items on this page are selected. ")
          @view.concat("<span onclick='gridzilla.activate_multi_page_select(\"#{@gridzilla.last[:grid_name]}\")'")
          @view.concat(" class='link'>Select all #{@gridzilla.last[:collection].total_entries} items.</span>")
          @view.concat("</span>")
          @view.concat("<span class='#{@gridzilla.last[:grid_name]}_multi_select select_all'>")
          @view.concat("All #{@gridzilla.last[:collection].total_entries} items are selected. ")
          @view.concat("<span class='link gz_multi_clear'>Clear Selection.</span></span></div>")
        end
        @view.concat("<div class='#{Gridzilla::Css::TableContainer}'>".html_safe)
        @view.concat("<table class='#{Gridzilla::Css::Table}'>".html_safe)
        @view.concat("<thead>".html_safe)
        @view.concat("<tr>".html_safe)
        @gridzilla.last[:row_data] = nil
        if block.arity == 1
          view_dsl.instance_exec(Gridzilla::Gobbler.new, &block)
        else
          view_dsl.instance_exec(Gridzilla::Gobbler.new, @gridzilla.last[:collection], &block)
        end
        @view.concat("</tr>".html_safe)
        @view.concat("</thead>".html_safe)

        @view.concat("<tbody>".html_safe)

        row_css_class_option  = options[:class]
        row_css_id_option     = options[:id]

        options[:onmouseover] = "gridzilla.add_class(this, 'over');#{options[:onmouseover]}"
        options[:onmouseout]  = "gridzilla.remove_class(this, 'over');#{options[:onmouseout]}"
        options[:onclick]     = "gridzilla.row_click(this);#{options[:onclick]}"
        @gridzilla.last[:collection].each do |item|
          row_css_class = row_css_class_option.is_a?(Proc) ? row_css_class_option.call(item) : row_css_class_option
          row_css_id    = row_css_id_option.is_a?(Proc) ? row_css_id_option.call(item) : row_css_id_option

          if @gridzilla.last[:selected_items] and @gridzilla.last[:selected_items].include?(item)
            options[:class] = "#{row_css_class} ui-selected"
          else
            options[:class] = row_css_class
          end
          options[:id]    = row_css_id
          options[:class] = options[:class].to_s + @view.cycle(" alt", "")
          @view.concat(@view.tag(:tr, options, true).html_safe)
          @gridzilla.last[:row_data] = item
          if block.arity == 1
            view_dsl.instance_exec(item, &block)
          else
            view_dsl.instance_exec(item, @gridzilla.last[:collection], &block)
          end
          @view.concat("</tr>".html_safe)
        end
        @view.concat("</tbody>".html_safe)
        @view.concat("</table>".html_safe)
        @view.concat("</div>".html_safe)
        if @gridzilla.last[:collection].empty? and @gridzilla.last[:empty_block]
          empty_options         = @gridzilla.last[:empty_block_options] || {}
          empty_options[:class] = "#{Gridzilla::Css::Empty} #{empty_options[:class]}".strip

          @view.concat(@view.tag(:div, empty_options, true))
          @view.instance_eval &@gridzilla.last[:empty_block]
          @view.concat("</div>".html_safe)
        end
      end
    end

    class AjaxGrid < Gridzilla::View::Grid
    end

    class Panel
      def initialize(view)
        @view      = view
        @gridzilla = @view.instance_variable_get('@gridzilla')
      end

      def action_function(name, function_name, *args, &block)
        options = args.extract_options!

        options[:class] = "#{Gridzilla::Css::PanelAction} #{options[:class]}".strip

        json_options = {
          :empty_message        => options.delete(:empty_message) || Message::DefaultEmptySelection,
          :single_message       => options.delete(:single_message) || Message::DefaultSingleSelection,
          :selection_constraint => options.delete(:selection_constraint) || :multiple,
          :block_message        => options.delete(:block_message)
        }

        attribute_name = args.first

        @view.link_to_function name, "gridzilla.action_function(#{function_name.to_json}, #{@gridzilla.last[:grid_name].to_json}, #{attribute_name.to_json}, #{json_options.to_json})", options
      end

      def pagination_links(*args)
        options = args.extract_options!

        #SANSEI: WillPaginate::Collection ain't here no more, my hack asks if it quacks like a will_paginate
        if @gridzilla.last[:collection].respond_to? :total_pages
          @view.will_paginate(@gridzilla.last[:collection], renderer: PaginationLinkRenderer)
        end
      end
    end

    class Row
      def initialize(view)
        @view      = view
        @gridzilla = @view.instance_variable_get('@gridzilla')
      end

      def if_empty(*args, &block)
        options = args.extract_options!

        if @gridzilla.last[:row_data].nil?
          @gridzilla.last[:empty_block_options] = options
          @gridzilla.last[:empty_block]         = block
        end
      end

      def single_select_column(attribute, *args, &block)
        options = args.extract_options!
        options.merge!({:style => 'width: 12px;'})

        if @gridzilla.last[:row_data].nil?
          @view.concat(@view.tag(:th))
          @gridzilla.last[:single_select] = true
        elsif attribute.is_a?(Symbol)
          @view.concat(@view.content_tag(:td, @view.tag(:input, :type => "hidden", :name => "#{@gridzilla.last[:grid_name]}_select", :value => @gridzilla.last[:row_data].send(attribute).to_json, :id => nil)+@view.tag(:div, :class => Gridzilla::Css::RadioButton), options,false))
        else
          @view.concat(@view.content_tag(:td, @view.tag(:input, :type => "hidden", :name => "#{@gridzilla.last[:grid_name]}_select", :value => attribute.to_json, :id => nil)+@view.tag(:div, :class => Gridzilla::Css::RadioButton), options,false))
        end
      end

      def select_column(attribute, *args, &block)
        options = args.extract_options!
        options.merge!({:style => 'width: 12px;'})

        if @gridzilla.last[:row_data].nil?
          @view.concat(@view.content_tag(:th, @view.content_tag(:div, '', :class => Gridzilla::Css::Checkbox, :id => "#{@gridzilla.last[:grid_name]}_select_all")))
        elsif attribute.is_a?(Symbol)
          @view.concat(@view.content_tag(:td, @view.tag(:input, :type => "hidden", :name => "#{@gridzilla.last[:grid_name]}_select", :value => @gridzilla.last[:row_data].send(attribute).to_json, :id => nil)+@view.content_tag(:div, '', :class => Gridzilla::Css::Checkbox), options))
        else
          @view.concat(@view.content_tag(:td, @view.tag(:input, :type => "hidden", :name => "#{@gridzilla.last[:grid_name]}_select", :value => attribute.to_json, :id => nil)+@view.content_tag(:div, '', :class => Gridzilla::Css::Checkbox), options))
        end
      end

      def row_number_column(*args, &block)
        options = args.extract_options!

        if @gridzilla.last[:row_data].nil?
          @view.concat(@view.content_tag(:th, "&nbsp;", options,false))
        else
          @view.concat(@view.tag(:td, options, true))
          @view.concat("#{@gridzilla.last[:row_number] += 1}")
          @view.concat("</td>".html_safe)
        end
      end

      def column(name = "", *args, &block)
        options   = args.extract_options!
        attribute = args.shift

        sort_key = options.delete(:sort_key)

        raise ArgumentError, "Missing block or attribute in column definition" unless block_given? or attribute

        if @gridzilla.last[:row_data].nil?
          header_content = name
          if sort_key
            options[:class] = "#{Gridzilla::Css::Sortable} #{options[:class]}".strip
            header_content << @view.hidden_field_tag("sort_key", sort_key).html_safe

            if @view.params[:sort_key] == sort_key
              if @view.params[:sort_order] == "DESC"
                options[:class] = "#{Gridzilla::Css::SortDesc} #{options[:class]}".strip
              else
                options[:class] = "#{Gridzilla::Css::SortAsc} #{options[:class]}".strip
              end
            end
          end
          @view.concat(@view.content_tag(:th, header_content, options, false))
        else
          @view.concat(@view.tag(:td, options, true))
          if block_given?
            yield
          else
            @view.concat(@gridzilla.last[:row_data].send(attribute).to_s)
          end
          @view.concat("</td>".html_safe)
        end
      end
    end
  end
end

ActionView::Base.send :include, Gridzilla::View::InstanceMethods
ActionController::Base.send :include, Gridzilla::Controller
