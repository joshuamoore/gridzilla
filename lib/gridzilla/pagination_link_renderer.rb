module Gridzilla
  class PaginationLinkRenderer < WillPaginate::LinkRenderer
    protected

    def page_link(page, text, attributes = {})
      extra_options = @template.instance_eval do
        options        = HashWithIndifferentAccess.new.merge(request.query_parameters.clone)
        options[:page] = page
        Gridzilla::PaginationLinkRenderer.to_flat_json(options)
      end

      grid_name = @template.instance_eval("@gridzilla.last[:grid_name].to_json")

      @template.link_to_function text, "gridzilla.set_data(#{grid_name}, $.extend(gridzilla.get_data(#{grid_name}), {page: #{page}})); gridzilla.load(#{grid_name}, {data: {#{extra_options}}})", attributes
    end

    class << self
      def to_flat_json(hash, parent_array = [])
        json = hash.map do |key, value|
          if value.is_a?(Hash)
            to_flat_json(value, parent_array + [key])
          else
            "#{array_to_json_key(key, parent_array.clone).to_json}: #{value.to_json}"
          end
        end.flatten.join(", ")
        json
      end

      def array_to_json_key(key, parent_array)
        unless parent_array.empty?
          response_string = parent_array.shift
          parent_array.each do |string|
            response_string << "[#{string}]"
          end
          "#{response_string}[#{key}]"
        else
          key
        end
      end
    end
  end
end
