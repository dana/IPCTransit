require 'rubygems'
require 'json'

def transit_freeze(args)
    if args['e'].nil?
        serialize_type = 'json'
    else
        serialize_type = args['e']
    end
    case serialize_type
    when 'json'
        return args['message'].to_json
    when 'yaml'
        puts 'yaml'
    end
end

def transit_thaw(args)
    if args['wire_headers'].nil?
        serialize_type = 'json'
    else
        if args['wire_headers']['e'].nil?
            serialize_type = 'json'
        else
            serialize_type = args['wire_headers']['e']
        end
    end
    case serialize_type
    when 'json'
        return JSON.parse(args['serialized_message'])
    when 'yaml'
        puts 'yaml'
    end
end

