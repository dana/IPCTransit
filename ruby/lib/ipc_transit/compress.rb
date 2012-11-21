require 'zlib'

def transit_deflate(args)
    if args['c'].nil?
        compression_type = 'none'
    else
        compression_type = args['c']
    end
    case compression_type
    when 'none'
        return args['frozen']
    when 'zlib'
        return Zlib::deflate(args['frozen'])
    end
end

def transit_inflate(args)
    if args['wire_headers'].nil?
        compression_type = 'none'
    else
        if args['wire_headers']['c'].nil?
            compression_type = 'none'
        else
            compression_type = args['wire_headers']['c']
        end
    end
    case compression_type
    when 'none'
        return args['serialized_message']
    when 'zlib'
        return Zlib::inflate(args['serialized_message'])
    end
end
