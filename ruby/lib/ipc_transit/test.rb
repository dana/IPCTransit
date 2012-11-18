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
        exec "bin/#{prog}"
        exit
    end
    return pid
end
def kill_daemon(pid)
    Process.kill(9, pid)
end

