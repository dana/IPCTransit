require 'test/unit'
require 'ipc_transit'

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

class TestIPCTransit < Test::Unit::TestCase
    def test_basic_remote
        drain_test_queue()
        IPCTransit.send('message' => { 'foo' => 'bar' }, 'qname' => 'test_qname', 'd' => '127.0.0.1')
        ret = IPCTransit.receive('qname' => 'transitd', 'nowait' => 1)
        assert(ret, 'IPCTransit.receive returned true')
        assert_equal(ret['foo'], 'bar')
    end

    def test_full_remote
        drain_test_queue()
        begin
            trserver_pid = run_daemon('trserver')
            transitd_pid = run_daemon('transitd')
            sleep 1
            IPCTransit.send('message' => { 'foo' => 'bar' }, 'qname' => 'test_qname', 'd' => '127.0.0.1')
            ret = IPCTransit.receive('qname' => 'test_qname', 'nowait' => 1)
            assert(ret, 'IPCTransit.receive returned true')
            assert_equal(ret['foo'], 'bar')
        rescue Exception => msg
            puts "Exception: #{msg}"
        end
        kill_daemon(transitd_pid)
        kill_daemon(trserver_pid)
    end
end

