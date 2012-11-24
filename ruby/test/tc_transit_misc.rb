require 'test/unit'
require 'ipc_transit'
require 'ipc_transit/test'

class TestIPCTransit < Test::Unit::TestCase
    def test_remove_queue
        clear_test_queue()
        IPCTransit.send('message' => { 'foo' => 'bar' }, 'qname' => $ipc_transit_test_qname)
        all_info = IPCTransit.all_queue_info()
        assert(all_info, 'We received some queue info')

        assert(all_info[$ipc_transit_test_qname]['qname'] == $ipc_transit_test_qname, 'test queue is in all_queue_info')
        x = all_info['tr_dist_some_random_queue']
        assert(x.nil?, 'another, un-used qname is NOT in all info')
        qid = all_info[$ipc_transit_test_qname]['qid']
        assert(qid, 'queue_id for tr_dist_test_qname exists')

        ret = IPCTransit.receive('qname' => $ipc_transit_test_qname, 'nowait' => 1)
        assert(ret, 'IPCTransit.receive returned true')
        assert_equal(ret['foo'], 'bar')

        IPCTransit.remove('qname' => $ipc_transit_test_qname)
        all_info = IPCTransit.all_queue_info()
        x = all_info[$ipc_transit_test_qname]
        assert(x.nil?, 'tr_dist_test_qname successfully removed')
    end
end

