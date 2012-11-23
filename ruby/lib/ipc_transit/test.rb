$ipc_transit_config_path = '/tmp/test_ipc_transit'

#kind of ghetto, but I don't have a better way right now
def drain_test_queue
    begin
        while ret = IPCTransit.receive('qname' => 'test_qname', 'nowait' => 1)
        end
    rescue Exception => msg
    end
end

def run_daemon(prog)
    pid = fork
    if pid.nil? #child
        exec "ruby -Ilib bin/#{prog} -p/tmp/test_ipc_transit"
        exit
    end
    return pid
end
def kill_daemon(pid)
    Process.kill(9, pid)
end

