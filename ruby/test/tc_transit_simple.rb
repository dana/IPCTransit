require 'test/unit'
require 'ipc_transit'
require 'ipc_transit/test'

class TestIPCTransit < Test::Unit::TestCase
    def test_typical
        drain_test_queue()
        IPCTransit.send('message' => { 'foo' => 'bar' }, 'qname' => 'tr_dist_test_qname')
        ret = IPCTransit.receive('qname' => 'tr_dist_test_qname', 'nowait' => 1)
        assert(ret, 'IPCTransit.receive returned true')
        assert_equal(ret['foo'], 'bar')
    end

    def test_wire_raw
        drain_test_queue()
        IPCTransit.send('message' => { 'foo' => 'bar' }, 'qname' => 'tr_dist_test_qname', 'encoding' => 'json', 'compression' => 'none')
        ret = IPCTransit.receive('qname' => 'tr_dist_test_qname', 'raw' => 1, 'nowait' => 1)
        assert(ret, 'IPCTransit.receive returned true')
        assert_equal(ret['message']['foo'], 'bar')
        assert_equal(ret['wire_headers']['e'], 'json')
        assert_equal(ret['wire_headers']['c'], 'none')
    end
    def test_message_meta
        drain_test_queue()
        IPCTransit.send( 'qname' => 'tr_dist_test_qname',
                'message' => { 'foo' => 'bar' },
                'encoding' => 'json',
                'compression' => 'none',
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

    def test_get_queue_info
        drain_test_queue()
        all_info = IPCTransit.all_queue_info()
        IPCTransit.send('message' => { 'foo' => 'bar' }, 'qname' => 'tr_dist_test_qname')
        assert(all_info, 'We received some queue info')

        assert(all_info['tr_dist_test_qname']['qname'] == 'tr_dist_test_qname', 'test queue is in all_queue_info')
        qid = all_info['tr_dist_test_qname']['qid']
        assert(qid, 'queue_id for tr_dist_test_qname exists')

        ret = IPCTransit.receive('qname' => 'tr_dist_test_qname', 'nowait' => 1)
        assert(ret, 'IPCTransit.receive returned true')
        assert_equal(ret['foo'], 'bar')
    end

    def test_all_queues
        drain_test_queue()
        IPCTransit.send('message' => { 'foo' => 'bar' }, 'qname' => 'tr_dist_test_qname')
        ret = IPCTransit.all_queues()
        assert(ret, 'IPCTransit.all_queues returned true')
        assert(ret['tr_dist_test_qname']['count'] == 1, 'exactly one message in tr_dist_test_qname')
        ret = IPCTransit.receive('qname' => 'tr_dist_test_qname', 'nowait' => 1)
        assert(ret, 'IPCTransit.receive returned true')
        assert_equal(ret['foo'], 'bar')
    end
end

