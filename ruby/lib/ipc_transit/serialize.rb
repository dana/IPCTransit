require 'rubygems'
require 'json'

def transit_freeze(args)
    return args['message'].to_json
end

def transit_thaw(args)
    return JSON.parse(args['serialized_message'])
end

