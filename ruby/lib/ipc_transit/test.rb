$ipc_transit_config_path = '/tmp/test_ipc_transit'
$ipc_transit_test_qname = 'tr_dist_test_qname'

def clear_test_queue
    begin
        IPCTransit.remove('qname' => $ipc_transit_test_qname)
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
