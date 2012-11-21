require 'test/unit'
require 'ipc_transit'
require 'ipc_transit/test'

class TestIPCTransit < Test::Unit::TestCase
    def test_yaml_typical
        drain_test_queue()
        IPCTransit.send('message' => { 'foo' => 'bar' }, 'e' => 'yaml', 'qname' => 'test_qname')
        ret = IPCTransit.receive('qname' => 'test_qname', 'nowait' => 1)
        assert(ret, 'IPCTransit.receive returned true')
        assert_equal(ret['foo'], 'bar')
    end

    def test_yaml_wire_raw
        drain_test_queue()
        IPCTransit.send('message' => { 'foo' => 'bar' }, 'qname' => 'test_qname', 'e' => 'yaml', 'c' => 'none')
        ret = IPCTransit.receive('qname' => 'test_qname', 'raw' => 1, 'nowait' => 1)
        assert(ret, 'IPCTransit.receive returned true')
        assert(ret['serialized_message'] =~ /^---/, 'data verified as YAML')
        assert_equal(ret['message']['foo'], 'bar')
        assert_equal(ret['wire_headers']['e'], 'yaml')
        assert_equal(ret['wire_headers']['c'], 'none')
    end
    def test_yaml_message_meta
        drain_test_queue()
        IPCTransit.send( 'qname' => 'test_qname',
                'message' => { 'foo' => 'bar' },
                'e' => 'json',
                'c' => 'none',
                'something' => 'else',
                'x' => { 'this' => 'that' },
                'once' => ['more',2]
        )
        ret = IPCTransit.receive('qname' => 'test_qname', 'e' => 'yaml', 'nowait' => 1)
        assert(ret, 'IPCTransit.receive returned true')
        assert_equal(ret['foo'], 'bar')
        assert_equal(ret['.ipc_transit_meta']['something'], 'else')
        assert_equal(ret['.ipc_transit_meta']['x']['this'], 'that')
        assert_equal(ret['.ipc_transit_meta']['once'][0], 'more')
        assert_equal(ret['.ipc_transit_meta']['once'][1], 2)
    end
end
