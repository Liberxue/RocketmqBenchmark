mkdir /cfg
cat>/opt/rocketmq-4.5.2/conf/broker.conf<<-EOF
brokerClusterName = RaftCluster
brokerName=RaftNode0${index}
brokerIP1=${broker_ip}
listenPort=30911
namesrvAddr=${nameSrv0}:9876;${nameSrv1}:9876;${nameSrv2}:9876
storePathRootDir=/data
storePathCommitLog=/data/commitlog
enableDLegerCommitLog=true
dLegerGroup=RaftNode00
dLegerPeers=n0-${broker0}:40911;n1-${broker1}:40911;n2-${broker2}:40911
dLegerSelfId=n${index}
sendMessageThreadPoolNums=16
clientCloseSocketIfTimeout=true
flushDiskType=ASYNC_FLUSH
transientStorePoolEnable=true
transferMsgByHeap=true
EOF
