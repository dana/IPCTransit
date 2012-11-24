require 'test/unit'
require 'ipc_transit'
require 'ipc_transit/test'

class TestIPCTransit < Test::Unit::TestCase
    def test_zlib_typical
        clear_test_queue()
        IPCTransit.send('message' => { 'foo' => 'bar' }, 'qname' => 'tr_dist_test_qname', 'compression' => 'zlib', 'encoding' => 'json')
        ret = IPCTransit.receive('qname' => 'tr_dist_test_qname', 'nowait' => 1)
        assert(ret, 'IPCTransit.receive returned true')
        assert_equal(ret['foo'], 'bar')
    end

    def test_zlib_wire_raw
        clear_test_queue()
        IPCTransit.send('message' => { 'foo' => 'bar' }, 'qname' => 'tr_dist_test_qname', 'compression' => 'zlib')
        ret = IPCTransit.receive('qname' => 'tr_dist_test_qname', 'raw' => 1, 'nowait' => 1)
        assert(ret, 'IPCTransit.receive returned true')
        assert_equal(ret['message']['foo'], 'bar')
        assert_equal(ret['wire_headers']['c'], 'zlib')
    end
    def test_zlib_message_meta
        clear_test_queue()
        IPCTransit.send( 'qname' => 'tr_dist_test_qname',
                'message' => { 'foo' => 'bar' },
                'encoding' => 'json',
                'compression' => 'zlib',
                'something' => 'else',
                'x' => { 'this' => 'that' },
                'once' => ['more',2]
        )
        ret = IPCTransit.receive('qname' => 'tr_dist_test_qname', 'nowait' => 1)
        assert(ret, 'IPCTransit.receive returned true')
        assert_equal(ret['foo'], 'bar')
        assert_equal(ret['.ipc_transit_meta']['something'], 'else')
        assert_equal(ret['.ipc_transit_meta']['x']['this'], 'that')
        assert_equal(ret['.ipc_transit_meta']['once'][0], 'more')
        assert_equal(ret['.ipc_transit_meta']['once'][1], 2)
    end
end

