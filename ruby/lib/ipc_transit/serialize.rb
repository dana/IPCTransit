require 'rubygems'
require 'json'
require 'yaml'
require 'ipc_transit/compress'

def transit_freeze(args)
    if args['e'].nil?
        serialize_type = 'json'
    else
        serialize_type = args['e']
    end
    case serialize_type
    when 'json'
        args['frozen'] = args['message'].to_json
    when 'yaml'
        args['frozen'] = YAML.dump(args['message'])
    end
    return transit_deflate(args)
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
    begin
        inflated = transit_inflate(args)
    rescue Exception => msg
        puts "transit_thaw exception: #{e}"
    end
    case serialize_type
    when 'json'
        args['thawed'] = JSON.parse(inflated)
    when 'yaml'
        args['thawed'] = YAML.load(inflated)
    end
    return args['thawed']
end

