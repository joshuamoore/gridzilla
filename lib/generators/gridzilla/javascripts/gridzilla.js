if (!gridzilla) {
  var gridzilla = {};

  (function(){

    var gridzilla_data = {};
    gridzilla.get_data = function(grid_name) {
      return gridzilla_data[grid_name];
    }
    gridzilla.set_data = function(grid_name, data) {
      gridzilla_data[grid_name] = data;
    }

    var gridzilla_is_loaded = {};
    gridzilla.is_loaded = function(grid_name) {
      return gridzilla_is_loaded[grid_name];
    }
    gridzilla.set_loaded = function(grid_name) {
      gridzilla_is_loaded[grid_name] = true;
    }
    gridzilla.set_unloaded = function(grid_name) {
      gridzilla_is_loaded[grid_name] = false;
    }


    var gridzilla_options = {};
    gridzilla.get_option = function(grid_name, option_name) {
      if (gridzilla_options[grid_name]) {
        return gridzilla_options[grid_name][option_name];
      }
    }
    gridzilla.set_option = function(grid_name, option_name, value) {
      if (!gridzilla_options[grid_name]) {
        gridzilla_options[grid_name] = {};
      }
      gridzilla_options[grid_name][option_name] = value;
    }

    gridzilla.setup = function(grid_name) {

      if (gridzilla.get_option(grid_name, 'height') && $("#"+grid_name).is(":not(div > .#{Gridzilla::Css::Empty})")) {
        if ($("#"+grid_name+" .#{Gridzilla::Css::Table}:first").height() > gridzilla.get_option(grid_name, 'height')) {
          $("#"+grid_name+" .#{Gridzilla::Css::TableContainer}:first").height(gridzilla.get_option(grid_name, 'height')).fixedHeaderTable();
          //$("#"+grid_name+" .#{Gridzilla::Css::Table}:first").Scrollable(gridzilla.get_option(grid_name, 'height'));
        }
      }

      //Handle Check Boxes
      $("#"+grid_name+"_select_all").click(function() {
        if ($("#"+grid_name+" thead:first tr.ui-selected").length == 0) {
          $("#"+grid_name+" tr").addClass("ui-selected").removeClass("ui-partial");
          gridzilla.popup_multi_page_select(grid_name);
        } else {
          $("#"+grid_name+" tr").removeClass("ui-selected ui-partial");
          gridzilla.deactivate_multi_page_select(grid_name);
        }

        if (gridzilla.get_option(grid_name, 'form_var')) {
          $('#'+gridzilla.get_option(grid_name, 'form_var')).val(gridzilla.selected_values(grid_name));
        }
      });


      $("#"+grid_name+" .#{Gridzilla::Css::TableContainer}:first thead:first .#{Gridzilla::Css::Sortable}").click(function() {
        var column_header = $(this);
        var sort_key      = $("input[name=sort_key]", this).val();

        if (column_header.hasClass("#{Gridzilla::Css::SortAsc}")) {
          var pagination_data = {sort_key: sort_key, sort_order: "DESC"};
        } else if (column_header.hasClass("#{Gridzilla::Css::SortDesc}")) {
          var pagination_data = {sort_key: "", sort_order: ""};
        } else {
          var pagination_data = {sort_key: sort_key, sort_order: "ASC", page: 1};
        }

        var new_gridzilla_data = $.extend(gridzilla.get_data(grid_name), pagination_data);

        gridzilla.set_data(grid_name, new_gridzilla_data);
        gridzilla.load(grid_name);
      });

      gridzilla.set_loaded(grid_name);
    };

    gridzilla.row_click = function(element) {
      grid_name = $(element).parents('.gridzilla').get(0).id;

      if ($(element).is("tr:has(.#{Gridzilla::Css::RadioButton})")) {
        $(element).closest('.gridzilla').find("tr").removeClass("ui-selected");
        $(element).addClass("ui-selected");
      } else {
        if ($(element).closest('tr').hasClass('ui-selected')){
          gridzilla.deactivate_multi_page_select(grid_name);
        }
        $(element).toggleClass('ui-selected');
        gridzilla.select_all_adorning($(element).closest('.gridzilla'), grid_name);
      }

      if (gridzilla.get_option(grid_name, 'form_var')) {
        $('#'+gridzilla.get_option(grid_name, 'form_var')).val(gridzilla.selected_values(grid_name));
      }
    };

    gridzilla.select_all_adorning = function(grid_jqo, grid_name) {
      if ($("tbody td .#{Gridzilla::Css::Checkbox}", grid_jqo).length == $("tbody tr.ui-selected td .#{Gridzilla::Css::Checkbox}", grid_jqo).length) {
        $("thead tr", grid_jqo).addClass('ui-selected');
        $("thead tr", grid_jqo).removeClass('ui-partial');
        gridzilla.popup_multi_page_select(grid_name);
      } else if ($("tbody tr.ui-selected td .#{Gridzilla::Css::Checkbox}", grid_jqo).length == 0) {
        $("thead tr", grid_jqo).removeClass('ui-selected');
        $("thead tr", grid_jqo).removeClass('ui-partial');
      } else {
        $("thead tr", grid_jqo).removeClass('ui-selected');
        $("thead tr", grid_jqo).addClass('ui-partial');
      }
    };

    gridzilla.deselect_all = function(grid_name) {
      $("#search_users .gz_table_container .fht_table_body .gz_table tbody tr").removeClass("ui-selected");
      $("tr",'#'+grid_name).removeClass('ui-partial ui-selected');
    };

    gridzilla.selected_values = function(grid_name, attribute) {
      if (gridzilla.get_option(grid_name,'multi_page_selected') && gridzilla.get_option(grid_name,'total_records') > 100){
        x=gridzilla.get_data(grid_name);
        a=[];
        for(key in x){
          if(x[key]!=''){
            if ($.isArray(x[key]) && !key.match(/.*\\[\\]$/)){
              a.push('"'+key+'[]":"'+x[key]+'"');
            }else{
              a.push('"'+key+'":"'+x[key]+'"');
            }
          }
        };
        return {"length":gridzilla.get_option(grid_name,'total_records'),join:function(charac){
          return "{current_user:"+current_user_id+",current_school:"+current_school_id+',count:'+gridzilla.get_option(grid_name,'total_records')+
            ",by:"+gridzilla.get_option(grid_name,'multi_page_selector')+",filters:{"+a.join(',')+'}}'
        }}
      } else {
        return $.map($("#"+grid_name+" tr.ui-selected input[name="+grid_name+"_select]"), function(d) {
          eval("var val = "+$(d).val());
          if (attribute) {
            return [val[attribute]];
          } else {
            return [val];
          }
        });
      }
    };

    gridzilla.popup_multi_page_select = function(grid_name){
      $("#"+grid_name+"_multi_select").show();
      $(".gz_multi_clear,"+grid_name).click(function(){
        gridzilla.deselect_all(grid_name);
        gridzilla.deactivate_multi_page_select(grid_name)
      });
    };

    gridzilla.activate_multi_page_select = function(grid_name){
      $("."+grid_name+"_multi_select").toggle();
      gridzilla.set_option(grid_name,'multi_page_selected',true);
      $(".gz_button").hide();
      $(".multi_page_button").show();
    };

    gridzilla.deactivate_multi_page_select = function(grid_name){
      gridzilla.set_option(grid_name,'multi_page_selected',false);
      $("."+grid_name+"_multi_select").show();
      $("."+grid_name+"_multi_select.select_all").hide();
      $("#"+grid_name+"_multi_select").hide();
      $(".gz_button").show();
    };

    gridzilla.values = function(grid_name, attribute) {
      return gridzilla.selected_values(grid_name, attribute);
    };

    gridzilla.unload = function(grid_name) {
      $('#'+grid_name).html('');
      gridzilla.set_unloaded(grid_name);
    };

    gridzilla.block = function(grid_name, message) {
      $("#"+grid_name).block({
        css: {
          border: 'none',
          padding: '10px',
          backgroundColor: '#000',
          '-webkit-border-radius': '5px',
          '-moz-border-radius': '5px',
          opacity: .7,
          color: '#fff'
        },
        message: '<div class="gz_load"><img src="/images/gridzilla/red_blk_loader.gif"/><h2>' + message + '</h2></div>'
      });
    }

    gridzilla.load = function(grid_name, options, callback) {
      if (!gridzilla.get_option(grid_name, "controller")) return;

      if (grid_name && $("#"+grid_name).length > 0) {
        options = options || {};
        var reload = true;

        if (options.passive) {
          if (gridzilla.is_loaded(grid_name)) {
            reload = false;
          } else {
            reload = true;
          }
        }

        if (reload) {
          if ($("#"+grid_name).is(':empty')) $("#"+grid_name).html('<div class="gz_load_spacer"></div>');
          gridzilla.block(grid_name, 'Loading');
          var grid_data = options.data || {};

          if (options.keep_params) {
            grid_data = merge(gridzilla.get_option(grid_name, "params"), grid_data);
          }

          for (attribute in gridzilla.get_data(grid_name)) {
            if (grid_data[attribute] == undefined) {
              grid_data[attribute] = gridzilla.get_data(grid_name)[attribute];
            }
          }

          var grid_url = gridzilla.get_option(grid_name, "url") || '/gridzilla/'+gridzilla.get_option(grid_name, "controller")+'/'+grid_name+'_grid';


          var data_str = (typeof(grid_data) === 'string') ? grid_data : $.param(grid_data, false);

          $.get(grid_url, data_str, function(data) {
            $('#'+grid_name).html(data);
            gridzilla.setup(grid_name);
            if (callback) callback();
          });
        }
      }
    };

    gridzilla.action_function = function(function_name, grid_name, attribute, options) {
      var selected_ids = gridzilla.values(grid_name, attribute);

      var constraint_range = [1, Infinity];
      if (options.selection_constraint == 'single') {
        constraint_range = [1, 1];
      } else if (options.selection_constraint instanceof Array) {
        constraint_range = options.selection_constraint;
      }

      if (selected_ids.length < constraint_range[0] || selected_ids.length > constraint_range[1]) {
        if (selected_ids.length == 0) {
          alert(options.empty_message);
        } else if (options.selection_constraint == 'single') {
          alert(options.single_message);
        } else if (constraint_range[1] == Infinity) {
          alert('You must select ' + constraint_range[0] + ' or more items.');
        } else {
          alert('You must select ' + constraint_range[0] + '..' + constraint_range[1] + ' items.');
        }
      } else {
        if (options.block_message) {
          gridzilla.block(grid_name, options.block_message);
        }

        if (constraint_range[1] == 1) {
          window[function_name](selected_ids[0]);
        } else {
          window[function_name](selected_ids);
        }
      }
    };

    gridzilla.add_class = function(element, css_class) {
      $(element).addClass(css_class);
    };

    gridzilla.remove_class = function(element, css_class) {
      $(element).removeClass(css_class);
    };

    var clone = function(obj) {
      var copy = {};

      for (attribute in obj) {
        copy[attribute] = obj[attribute];
      }

      return copy;
    };

    var merge = function(first, second) {
      var result = clone(first);

      for (attribute in second) {
        result[attribute] = second[attribute];
      }

      return result;
    };

  })();
}

