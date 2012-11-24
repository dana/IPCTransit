require 'rubygems'
require 'SysVIPC'
include SysVIPC
require 'ipc_transit/serialize'


##
# Fast, brokerless message queueing
#
# Author::    Dana M. Diederich (diederich@gmail.com)
# Copyright:: Copyright (c) 2012 Dana M. Diederich
# License::   Distributes under the same terms as Ruby

class IPCTransit
    @@queues = {}

    if $ipc_transit_config_path.nil?
        $ipc_transit_config_path = '/tmp/ipc_transit'
    end

    @@wire_header_arg_translate = {
        'destination' => 'd',
        'compression' => 'c',
        'encoding' => 'e'
    }
    @@wire_header_args = {
        'e' => { #encoding
            'json' => 1,
            'yaml' => 1,
        },
        'c' => { #compression
            'zlib' => 1,
            'snappy' => 1,
            'none' => 1,
        },
        'd' => 1, #destination address
        't' => 1, #hop TTL
        'q' => 1, #destination qname
    }
    @@std_args = {
        'message' => 1,
        'qname' => 1,
        'nowait' => 1,
    }


    ##
    #  Send message to a queue
    #
    # Arguments:
    #  message - hash reference
    #  qname - name of queue to send to
    #  nowait - do not block if the queue is full (optional)
    #  encoding - currently JSON and YAML are implemented (optional, defaults to JSON)
    #  compression - currently none and zlib are implemented (optional, defaults to none)
    #  destination - IP or name of remote destination (optional)

    def self.send(args)
        ret = nil
        flags = IPC_NOWAIT
        begin
            if args['destination']
                args['q'] = args['qname']
                args['qname'] = 'transitd'
                if not args['t']
                    args['t'] = 9
                end
            end
            key = self.get_queue_id(args)
            mq = MessageQueue.new(key, IPC_CREAT | 0666)
            if args['serialized_wire_data'].nil?
                pack_message(args)
            end
            ret = mq.snd(1, args['serialized_wire_data'], flags)
        rescue Exception => msg
            puts "Exception: #{msg}"
        end
        return ret
    end

    ##
    #  Remove a queue
    #
    # Arguments:
    #  qname - name of queue to remove

    def self.remove(args)
        qname = args['qname']
        key = self.get_queue_id(args)
        mq = MessageQueue.new(key, 0)
        mq.ipc_rmid
        File.delete("#{$ipc_transit_config_path}/#{qname}")
        @@queues.delete(qname)
    end


    ##
    #  Receive a message from a queue
    #
    # Arguments:
    #  qname - name of queue to send to
    #  nowait - do not block if the queue is full (optional)
    #  raw - return the full meta-data (optional)
    #
    #  Returns:
    #   Normally: message
    #   Raw: the message and its meta data
   
    def self.receive(args)
        ret = nil
        flags = 0
        if args['nowait']
            flags = IPC_NOWAIT
        end
        begin
            key = self.get_queue_id(args)
            mq = MessageQueue.new(key, IPC_CREAT | 0666)
            args['serialized_wire_data'] = mq.receive(0, 10000, flags)
            self.unpack_data(args)
            #at this point I need to see if this is a remote transit
            #if it is, then do not thaw the message proper
            args['message'] = transit_thaw(args)
        rescue Exception => msg
#            puts "Exception: #{msg}"
#            need to do something smarter with this
        end
        if args['raw']
            ret = args;
        else
            ret = args['message']
        end
        return ret
    end

    def self.all_queue_info()
        self.gather_queue_info()
        return @@queues
    end

    ##
    #  Return info about all of the queues on the system
    #
    # Arguments: none
    #
    # Returns: hash. key is qname, value contains:
    #   qid - integer queue ID
    #   count - number of messages in this queue

    def self.all_queues()
        ret = {}
        self.all_queue_info().each_pair do |qname,v|
            qid = v['qid']
            x = MessageQueue.new(qid, IPC_CREAT | 0666)
            y = x.ipc_stat
            ct = y.msg_qnum
            ret[qname] = {
                'qid' => qid,
                'count' => ct,
            }
        end
        return ret
    end

    ##
    #  Unpack the wire meta data from a message
    #
    # Arguments:
    #  serialized_wire_data - the serialized message
    #
    # Returns: (in the passed args)
    #   wire_headers - all of the wire headers
    #   serialized_message - the message itself, still serialized

    def self.unpack_data(args)
        stuff = args['serialized_wire_data'].split(':')
        offset = Integer(stuff.shift)
        header_and_message = stuff.join(':')
        if offset == 0
            args['serialized_header'] = ''
        else
            args['serialized_header'] = header_and_message[0..offset-1]
            self.thaw_wire_headers(args)
        end
        args['serialized_message'] = header_and_message[offset..header_and_message.length]
        return true
    end
#NB: I know this is all hideously inefficient.  I'm still learning Ruby,
#and I'm focusing on getting this correct first.
#
#returns a serialized_message and wire_meta_data
#takes serialized_wire_data


    private

    def self.get_queue_id(args)
        qname = args['qname']
        self.mk_queue_dir()
        if @@queues[qname]
            return @@queues[qname]['qid']
        end
        self.gather_queue_info()
        if @@queues[qname]
            return @@queues[qname]['qid']
        end
        begin
            self.lock_dir()
            File.umask(0000)
            file = File.open("#{$ipc_transit_config_path}/#{qname}", 'w', 0666)
            new_qid = ftok("#{$ipc_transit_config_path}/#{qname}", 1)
            file.puts("qid=#{new_qid}")
            file.puts("qname=#{qname}")
            file.close
            rescue Exception => msg
                self.unlock_dir()
            raise msg
        end
        self.unlock_dir()
        self.gather_queue_info()
        return @@queues[qname]['qid']
    end

    def self.lock_dir()
        File.umask(0000)
        File.open("#{$ipc_transit_config_path}/transit.lock", File::WRONLY|File::EXCL|File::CREAT, 0666)
    end
    def self.unlock_dir()
        File.delete("#{$ipc_transit_config_path}/transit.lock")
    end

    def self.gather_queue_info()
        self.mk_queue_dir()
        Dir.glob("#{$ipc_transit_config_path}/*").each do |filename|
            info = {}
            file = File.new(filename, 'r', 0666)
            while (line = file.gets)
                line.chomp!
                (key, value) = line.split('=')
                info[key] = value
            end
            if not info['qid']
                raise "required key 'qid' not found"
            end
            if not info['qname']
                raise "required key 'qname' not found"
            end
            info['qid'] = Integer(info['qid'])
            @@queues[info['qname']] = info
        end
    end

    def self.mk_queue_dir()
        begin
            Dir.mkdir($ipc_transit_config_path, 0777)
        rescue
        end
    end


#returns a scalar, ready to be sent on the wire
#it takes message and wire_meta_data
    def self.pack_message(args)
        args['message']['.ipc_transit_meta'] = {}
        @@wire_header_arg_translate.keys.each do |k|
            next unless args[k]
            args[@@wire_header_arg_translate[k]] = args[k]
        end
        args.keys.each do |k|
            next if @@wire_header_args[k]
            next if @@std_args[k]
            args['message']['.ipc_transit_meta'][k] = args[k]
        end
        args['serialized_message'] = transit_freeze(args)
        self.serialize_wire_meta(args)
        l = args['serialized_wire_meta_data'].length
        args['serialized_wire_data'] = "#{l}:#{args['serialized_wire_meta_data']}#{args['serialized_message']}"
        return args['serialized_wire_data']
    end

    def self.serialize_wire_meta(args)
        s = ''
        args.keys.each do |k|
            if @@wire_header_args[k]
                #make sure a valid value is passed in
                if @@wire_header_args[k] == 1
                    s = "#{s}#{k}=#{args[k]},"
                elsif @@wire_header_args[k][args[k]]
                    s = "#{s}#{k}=#{args[k]},"
                else
                    raise "passed wire argument #{k} had value #{args[k]} not of allowed type"
                end
            end
        end
        if s
            s = s[0..-2]  #teh google says this is the way to remove last character
        end
        args['serialized_wire_meta_data'] = s
    end


    def self.thaw_wire_headers(args)
        h = args['serialized_header']
        ret = {}
        h.split(',').each do |val|
            (k,v) = val.split('=')
            ret[k] = v
        end
        args['wire_headers'] = ret
    end
end
