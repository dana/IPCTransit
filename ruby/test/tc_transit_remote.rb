require 'test/unit'
require 'ipc_transit'
require 'ipc_transit/test'

class TestIPCTransit < Test::Unit::TestCase
    def teardown
        if not @transitd_pid.nil?
            kill_daemon(@transitd_pid)
            kill_daemon(@trserver_pid)
        end
    end

    def test_basic_remote
        clear_test_queue()
        IPCTransit.send('message' => { 'foo' => 'bar' }, 'qname' => 'tr_dist_test_qname', 'destination' => '127.0.0.1')
        ret = IPCTransit.receive('qname' => 'transitd', 'nowait' => 1)
        assert(ret, 'IPCTransit.receive returned true')
        assert_equal(ret['foo'], 'bar')
    end

    def test_full_remote
        clear_test_queue()
        begin
            @trserver_pid = run_daemon('trserver')
            @transitd_pid = run_daemon('transitd')
            sleep 2
            IPCTransit.send('message' => { 'foo' => 'bar' }, 'qname' => 'tr_dist_test_qname', 'destination' => '127.0.0.1')
            sleep 2
            ret = IPCTransit.receive('qname' => 'tr_dist_test_qname', 'nowait' => 1)
        rescue Exception => msg
            puts "Exception: #{msg}"
        end
        assert(ret, 'IPCTransit.receive returned true')
        assert_equal(ret['foo'], 'bar')
    end
end

