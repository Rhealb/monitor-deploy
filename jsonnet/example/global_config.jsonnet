{
  namespace: "wst",
  suiteprefix: "prometheus",

  // location use "yancheng" or "shanghai" or "langfang" or "aws" or "aliyun"
  location: "shanghai",

  // deploytype use "podservice" or "storage"
  deploytype: "podservice",

  // exservicetype use "ClusterIP" or "NodePort" or "None"
  exservicetype: "NodePort",

  // utilsstoretype use "FS" or "ConfigMap" or "S3"
  utilsstoretype: "FS",

  // componentoramah use "component" or "amah" or "both"
  componentoramah: "component",

  // "CephFS" for ceph or "EFS" for aws or "NFS" for aliyun
  mountdevtype: "CephFS",

  // ceph address
  // yancheng ceph address: "10.19.248.27:6789,10.19.248.28:6789,10.19.248.29:6789,10.19.248.30:6789"
  // shanghai ceph address: "10.19.137.144:6789,10.19.137.145:6789,10.19.137.146:6789"
  // langfang ceph address: "10.38.240.29:6789,10.38.240.30:6789,10.38.240.31:6789,10.38.240.32:6789,10.38.240.33:6789"
  cephaddress: "10.19.248.27:6789,10.19.248.28:6789,10.19.248.29:6789,10.19.248.30:6789",

  // nfs address
  // aws nfs:"fs-df45b5a6.efs.us-east-2.amazonaws.com"
  // aliyun nfs: "398de48d04-qar32.cn-shanghai.nas.aliyuncs.com"
  nfsaddress: "fs-df45b5a6.efs.us-east-2.amazonaws.com",

  registry: if $.location == "shanghai" then
               "127.0.0.1:29006"
             else if $.location == "yancheng" then
               "10.19.248.12:30100"
             else if $.location == "langfang" then
               "10.38.240.34:30100"
             else if $.location == "aws" then
               "127.0.0.1:30100"
             else if $.location == "aliyun" then
               "127.0.0.1:30100"
             else
               error "error location type",

  externalips: if $.location == "shanghai" then
                 ["10.19.137.140", "10.19.137.141", "10.19.137.142"]
               else if $.location == "yancheng" then
                 ["10.19.248.13", "10.19.248.14", "10.19.248.15"]
               else
                 ["10.38.240.29", "10.38.240.30", "10.38.240.31"],

  // initcontainer image download configfile from s3
  initcontainerimage: $.registry + "/tools/init-container:1.0",

  elasticsearch: {
    image: $.registry + "/tools/centos7-elasticsearch-6.1.0:0.1-lbsheng",
    exservicetype: $.exservicetype,
    esdatastoragesize: "1Gi",
    externalports: {
      httpports: [29200 + i for i in std.range(0, $.elasticsearch.client.instancecount)],
      transports: [29300 + i for i in std.range(0, $.elasticsearch.client.instancecount)],
    },
    nodeports: {
      httpports: ["" for count in std.range(1, $.elasticsearch.client.instancecount)],
      transports: ["" for count in std.range(1, $.elasticsearch.client.instancecount)],
    },
    master: {
      instancecount: 3,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      javaxms: "1g",
      javaxmx: "1g",
    },

    data: {
      instancecount: 3,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      javaxms: "1g",
      javaxmx: "1g",
    },
    client: {
      instancecount: 3,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      javaxms: "1g",
      javaxmx: "1g",
    },
    componentoramah: $.componentoramah,
    amah: {
      image: $.registry + "/tools/amah-elasticsearch-6.1.0:0.0.2-snapshot",
      exservicetype: $.exservicetype,
      instancecount: 1,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      externalports: {
        amahports:[8084,],
      },
      nodeports: {
        amahports:["",],
      },
     },
  },

  haproxy: {
    image: $.registry + "/tools/dockerio-haproxy-1.7.0-alpine:0.3-lbsheng",
    exservicetype: $.exservicetype,
    instancecount: 1,
    requestcpu: "0",
    requestmem: "0",
    limitcpu: "0",
    limitmem: "0",
    externalports: {
      hawebports: [10800 + i for i in std.range(0, $.haproxy.instancecount - 1)],
      sparkuiports: [9999 + i for i in std.range(0, $.haproxy.instancecount - 1)],
      hdfsuiports: [9998 + i for i in std.range(0, $.haproxy.instancecount - 1)],
      hbaseuiports: [9997 + i for i in std.range(0, $.haproxy.instancecount - 1)],
      overlorduiports: [8090 + i for i in std.range(0, $.haproxy.instancecount - 1)],
      coordinatoruiports: [8081 + i for i in std.range(0, $.haproxy.instancecount - 1)],
    },
    nodeports: {
      hawebports: ["" for count in std.range(1, $.haproxy.instancecount)],
      sparkuiports: ["" for count in std.range(1, $.haproxy.instancecount)],
      hdfsuiports: ["" for count in std.range(1, $.haproxy.instancecount)],
      hbaseuiports: ["" for count in std.range(1, $.haproxy.instancecount)],
      overlorduiports: ["" for count in std.range(1, $.haproxy.instancecount)],
      coordinatoruiports: ["" for count in std.range(1, $.haproxy.instancecount)],
    },
  },

  mysql: {
    creatdbstart: "false",
    databases: ["druid",],
    image: $.registry + "/tools/dep-centos7-mysql-5.7.18:0.2-lbsheng",
    exservicetype: $.exservicetype,
    instancecount: 1,
    mysqldatapvcstoragesize: "1Gi",
    requestcpu: "500m",
    requestmem: "0.5Gi",
    limitcpu: "2",
    limitmem: "2000Mi",
    password: "enncloud",
    externalports: {
      mysqlports: [3306 + i for i in std.range(0, $.mysql.instancecount - 1)],
    },
     nodeports: {
      mysqlports: [""],
    },

    componentoramah: $.componentoramah,
    amah: {
      image: $.registry + "/tools/amah-mysql-5.7.18:0.0.2-snapshot",
      exservicetype: $.exservicetype,
      instancecount: 1,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      username: "root",
      password: "123456",
      externalports: {
        amahports:[8084],
      },
      nodeports: {
        amahports:[""],
      },
     },
  },

  druid: {
    plyql: {
      druidprefix: $.suiteprefix,
      image: $.registry + "/tools/dep-centos7-plyql-0.11.2:0.4-lbsheng",
      exservicetype: $.exservicetype,
      instancecount: 1,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      externalports: {
        mysqlgatewayports: [3306 + i for i in std.range(0, $.druid.plyql.instancecount - 1)],
      },
       nodeports: {
        mysqlgatewayports: ["" for count in std.range(1, $.druid.plyql.instancecount)],
      },
    },
    origin: {
      zkprefix: $.suiteprefix,
      mysqlprefix: $.suiteprefix,
      hdfsprefix: $.suiteprefix,
      mysqlusername: "root",
      mysqlpasswd: "123456",
      image: $.registry + "/tools/dep-centos7-druid-0.10.0:0.1-lbsheng",
      exservicetype: $.exservicetype,
      externalports: {
        brokerports: [8082 + i*2 for i in std.range(0, $.druid.origin.broker.instancecount - 1)],
        coordports: [8081 + i*2 for i in std.range(0, $.druid.origin.coordinator.instancecount - 1)],
        overlordports: [8090 + i for i in std.range(0, $.druid.origin.overlord.instancecount - 1)],
      },
      nodeports: {
        brokerports: ["" for count in std.range(1, $.druid.origin.broker.instancecount)],
        coordports: ["" for count in std.range(1, $.druid.origin.coordinator.instancecount)],
        overlordports: ["" for count in std.range(1, $.druid.origin.overlord.instancecount)],
      },
      broker: {
        instancecount: 1,
        requestcpu: "0.5",
        requestmem: "1Gi",
        limitcpu: "1",
        limitmem: "1Gi",
      },
      coordinator: {
        instancecount: 1,
        requestcpu: "0.5",
        requestmem: "512Mi",
        limitcpu: "0.5",
        limitmem: "512Mi",
      },
      historical: {
        histsegmentcachepvcstoragesize: "200Mi",
        instancecount: 1,
        requestcpu: "0.5",
        requestmem: "1Gi",
        limitcpu: "0.5",
        limitmem: "1Gi",
      },
      middlemanager: {
        mmsegmentsstoragesize: "200Mi",
        instancecount: 1,
        requestcpu: "0.5",
        requestmem: "1Gi",
        limitcpu: "0.5",
        limitmem: "1Gi",
      },
      overlord: {
        instancecount: 1,
        requestcpu: "0.5",
        requestmem: "512Mi",
        limitcpu: "0.5",
        limitmem: "512Mi",
      },

    componentoramah: $.componentoramah,
    amah: {
      image: $.registry + "/tools/amah-druid-0.10.0:0.0.2-snapshot",
      exservicetype: $.exservicetype,
      instancecount: 1,
      replicas: 1,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      externalports: {
        amahports:[8084],
      },
      nodeports: {
        amahports:[""],
      },
     },
    },
    tranquility: {
      image: $.registry + "/tools/dep-centos7-tranquility-0.8.2:0.1-lbsheng",
      instancecount: 1,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
    },
  },

  hadoop: {
    zkprefix: $.suiteprefix,
    zkinstancecount: $.zookeeper.instancecount,
    hdfs: {
      image: $.registry + "/tools/dep-centos7-hadoop-2.7.4:0.1-lbsheng",
      exservicetype: $.exservicetype,
      datadirpvcstoragesize: "500Mi",
      specusepvcstoragesize: "500Mi",
      datadirstoragecount:: 4,
      externalports: {
        nnhttpports: [52070 + i for i in std.range(0, $.hadoop.hdfs.namenode.instancecount - 1)],
      },
      nodeports: {
        nnhttpports: ["" for count in std.range(1, $.hadoop.hdfs.namenode.instancecount)],
      },
      namenode: {
        instancecount: 2,
        requestcpu: "0",
        requestmem: "0",
        limitcpu: "0",
        limitmem: "0",
      },
      journalnode: {
        instancecount: 3,
        requestcpu: "0",
        requestmem: "0",
        limitcpu: "0",
        limitmem: "0",
      },
      datanode: {
        instancecount: 3,
        requestcpu: "0",
        requestmem: "0",
        limitcpu: "0",
        limitmem: "0",
      },
    },
    yarn: {
      image: $.registry + "/tools/dep-centos7-hadoop-2.7.4:0.1-lbsheng",
      exservicetype: $.exservicetype,
      hostpathpvcstoragesize: "500Mi",
      rmtmpdirpvcstoragesize: "100Mi",
      nmtmpdirpvcstoragesize: "100Mi",
      tmpdirstoragecount:: 4,
      externalports: {
        yarnhttpports: [28088 + i for i in std.range(0, $.hadoop.yarn.resourcemanager.instancecount - 1)],
        jhshttpports: [29888 + i for i in std.range(0, $.hadoop.yarn.mrjobhistory.instancecount - 1)],
      },
      nodeports: {
        yarnhttpports: ["" for count in std.range(1, $.hadoop.yarn.resourcemanager.instancecount)],
        jhshttpports: ["" for count in std.range(1, $.hadoop.yarn.mrjobhistory.instancecount)],
      },
      resourcemanager: {
        instancecount: 2,
        requestcpu: "0",
        requestmem: "0",
        limitcpu: "0",
        limitmem: "0",
      },
      nodemanager: {
        instancecount: 3,
        requestcpu: "0",
        requestmem: "0",
        limitcpu: "0",
        limitmem: "0",
      },
      mrjobhistory: {
        instancecount: 1,
        requestcpu: "0",
        requestmem: "0",
        limitcpu: "0",
        limitmem: "0",
      },
    },
    componentoramah: $.componentoramah,
    amah: {
      image: $.registry + "/tools/amah-hadoop-2.7.4:0.0.2-snapshot",
      exservicetype: $.exservicetype,
      instancecount: 1,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      externalports: {
        amahports:[8084,],
      },
      nodeports: {
        amahports:["",],
      },

      // monitor_cluster_type: hadoop or hdfs or yarn
      monitor_cluster_type: "hadoop",
     },
  },

  hbase: {
    zkprefix: $.suiteprefix,
    hdfsprefix: $.suiteprefix,
    image: $.registry + "/tools/dep-centos7-hbase-1.2.6:0.1-lbsheng",
    exservicetype: $.exservicetype,
    tsdbttl: 2592000,
    zkinstancecount: $.zookeeper.instancecount,
    externalports: {
      masterhttpports: [36010 + i for i in std.range(0, $.hbase.master.instancecount - 1)],
    },
    nodeports: {
      masterhttpports: ["" for count in std.range(1, $.hbase.master.instancecount)],
    },
    master: {
      instancecount: 3,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      permsize: "128m",
      maxpermsize: "128m",
      javaxmx: "1g",
    },
    regionserver: {
      instancecount: 3,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      permsize: "128m",
      maxpermsize: "128m",
      javaxmx: "1g",
    },

    componentoramah: $.componentoramah,
    amah: {
      image: $.registry + "/tools/amah-hbase-1.2.6:0.0.3-snapshot",
      exservicetype: $.exservicetype,
      hbasemasterinstancecount: $.hbase.master.instancecount,
      instancecount: 1,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      externalports: {
        amahports:[8084,],
      },
      nodeports: {
        amahports:["",],
      },
    },

  },

  kafka: {
    zkprefix: $.suiteprefix,
    zkinstancecount: $.zookeeper.instancecount,
    image: $.registry + "/tools/dep-centos7-kafka-2.11-0.10.1.1:0.1-lbsheng",
    exservicetype: $.exservicetype,
    instancecount: 3,
    requestcpu: "0",
    requestmem: "0",
    limitcpu: "0",
    limitmem: "0",
    logpvcstoragesize: "50Mi",
    externalports: {
      brokerports: [29092 + i for i in std.range(0, $.kafka.instancecount - 1)],
      jmxports: [29999 + i for i in std.range(0, $.kafka.instancecount - 1)],
    },
    nodeportip: "10.19.248.200",
    nodeports: {
      brokerports: ["" for count in std.range(1, $.kafka.instancecount)],
      jmxports: ["" for count in std.range(1, $.kafka.instancecount)],
    },
    componentoramah: $.componentoramah,
    amah: {
      image: $.registry + "/tools/amah-kafka-2.11-0.10.1.1:0.0.2-snapshot",
      exservicetype: $.exservicetype,
      kafkainstancecount: $.kafka.instancecount,
      replicas: 1,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      externalports: {
        amahports:[8084,],
      },
      nodeports: {
        amahports:["",],
      },
     },
  },

  kafkamanager: {
    zkprefix: $.suiteprefix,
    zkinstancecount: $.zookeeper.instancecount,
    image: $.registry + "/tools/kafka-manager:0.1-lbsheng",
    exservicetype: $.exservicetype,
    instancecount: 1,
    requestcpu: "0",
    requestmem: "0",
    limitcpu: "0",
    limitmem: "0",
    externalports: {
      httpports: [9000 + i for i in std.range(0, $.kafkamanager.instancecount - 1)],
    },
    nodeports: {
      httpports: ["" for count in std.range(1, $.kafkamanager.instancecount)],
    },
  },

  opentsdb: {
    zkprefix: $.suiteprefix,
    hbaseprefix: $.suiteprefix,
    zkinstancecount: $.zookeeper.instancecount,
    image: $.registry + "/tools/opentsdb-2.3.0:beta-0.4",
    exservicetype: $.exservicetype,
    instancecount: 1,
    requestcpu: "0",
    requestmem: "0",
    limitcpu: "0",
    limitmem: "0",
    logpvcstoragesize: "50Mi",
    javaxmx: "2g",
    javaxms: "2g",
    externalports: {
      httpports: [33117 + i for i in std.range(0, $.opentsdb.instancecount - 1)],
      jmxports: [33218 + i for i in std.range(0, $.opentsdb.instancecount - 1)],
    },
    nodeports: {
      httpports: ["" for count in std.range(1, $.opentsdb.instancecount)],
      jmxports: ["" for count in std.range(1, $.opentsdb.instancecount)],
    },

    componentoramah: $.componentoramah,
    amah: {
      image: $.registry + "/tools/amah-opentsdb-2.3.0:0.0.2-snapshot",
      exservicetype: $.exservicetype,
      instancecount: 1,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      externalports: {
        amahports:[8084,],
      },
      nodeports: {
        amahports:["",],
      },
    },

  },

  spark: {
    zkprefix: $.suiteprefix,
    hadoopprefix: $.suiteprefix,
    zkinstancecount: $.zookeeper.instancecount,
    image: $.registry + "/tools/dep-centos7-spark-2.1.1-hadoop-2.7:0.1-lbsheng",
    exservicetype: $.exservicetype,
    workerworkdirpvcstoragesize: "200Mi",
    localdirpvcstoragesize: "200Mi",
    externalports: {
      masteruiports: [28080 + i for i in std.range(0, $.spark.master.instancecount - 1)],
      masterports: [27070 + i for i in std.range(0, $.spark.master.instancecount - 1)],
      applicationuiports: [24040 + i for i in std.range(0, $.spark.master.instancecount - 1)],
      restports: [6066 + i for i in std.range(0, $.spark.master.instancecount - 1)],
      historyuiports: [48080 + i for i in std.range(0, $.spark.historyserver.instancecount - 1)],
    },
    nodeports: {
      masteruiports: ["" for count in std.range(1, $.spark.master.instancecount)],
      masterports: ["" for count in std.range(1, $.spark.master.instancecount)],
      applicationuiports: ["" for count in std.range(1, $.spark.master.instancecount)],
      restports: ["" for count in std.range(1, $.spark.master.instancecount)],
      historyuiports: ["" for count in std.range(1, $.spark.historyserver.instancecount)],
    },
    master: {
      instancecount: 3,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
    },
    worker: {
      instancecount: 3,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      sparkworkercores: "4",
    },
    historyserver: {
      sparkeventlogdir: "hdfs://enncloud-hadoop/var/log/spark",
      instancecount: 1,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
    },

    componentoramah: $.componentoramah,
    amah: {
      image: $.registry + "/tools/amah-spark-2.1.1-hadoop2.7:0.0.2-snapshot",
      exservicetype: $.exservicetype,
      instancecount: 1,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      externalports: {
        amahports:[8084],
      },
      nodeports: {
        amahports:[""],
      },
     },
  },

  tensorflow: {
    exservicetype: $.exservicetype,
    externalports: {
      tfpsports: [22222 + i for i in std.range(0, $.tensorflow.psnum - 1)],
    },
    nodeports: {
      tfpsports: ["" for count in std.range(1, $.tensorflow.psnum)],
    },
    tfworkerrequestcpu: "1",
    tfworkerrequestmem: "1Gi",
    tfworkerlimitcpu: "1",
    tfworkerlimitmem: "1Gi",
    tfpsrequestcpu: "0.5",
    tfpsrequestmem: "1Gi",
    tfpslimitcpu: "0.5",
    tfpslimitmem: "1Gi",
    grpcimage: $.registry + "/tensorflow/tf_grpc_test_server-gpu:platform-py2-py3-tf1.1",
    jobname: "tf-gpu",
    setup_cluster_only: 1,
    modelname: "MNIST",
    workernum: 2,
    psnum: 1,
    existing_servers: false,
    output_path: "/tmp/output/",
    data_dir: "/tmp/data/",
    log_dir: "/tmp/log/",
    sync_replicas: 0,
    n_gpus: 2,
    train_steps: 120,
    cephfsstoragename: "tensorflow",
    containerpath: "/tmp",
    cephfsstoragesize: "1Gi",
  },

  zookeeper: {
    image: $.registry + "/tools/dep-centos7-zookeeper3.5.3:beta-lbsheng",
    instancecount: 3,
    exservicetype: $.exservicetype,
    datapvcstoragesize: "50Mi",
    datalogpvcstoragesize: "50Mi",
    requestcpu: "0",
    requestmem: "0",
    limitcpu: "0",
    limitmem: "0",
    externalports: {
      clientports: [22181 + i for i in std.range(0,$.zookeeper.instancecount - 1)],
      adminserverports: [38080 + i for i in std.range(0,$.zookeeper.instancecount - 1)],
    },
    nodeports: {
      clientports: ["" for count in std.range(1, $.zookeeper.instancecount)],
      adminserverports: ["" for count in std.range(1, $.zookeeper.instancecount)],
    },

    componentoramah: $.componentoramah,
    amah: {
      image: $.registry + "/tools/amah-zookeeper-3.5.3-beta:0.0.2-snapshot",
      exservicetype: $.exservicetype,
      zkinstancecount: $.zookeeper.instancecount,
      replicas: 1,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      externalports: {
        amahports:[8084,],
      },
      nodeports: {
        amahports:["",],
      },
     },
  },

  ping: {
    zkprefix: $.suiteprefix,
    kafkaprefix: $.suiteprefix,
    hdfsprefix: $.suiteprefix,
    zkinstancecount: $.zookeeper.instancecount,
    jninstancecount: $.hadoop.hdfs.journalnode.instancecount,
    kafkainstancecount: $.kafka.instancecount,
    image: $.registry + "/tools/ping:0.4-lbsheng",
    instancecount: 1,
    datastoragesize: "1Gi",
    requestcpu: "0",
    requestmem: "0",
    limitcpu: "0",
    limitmem: "0",
  },
  redis: {
    image: $.registry + "/tools/redis-cluster:2.2-ping",
    zkprefix: $.suiteprefix,
    zkinstancecount: $.zookeeper.instancecount,
    exservicetype: $.exservicetype,
    redisdatastoragesize: "100Mi",
    instancecount: 3,
    externalports: {
      redisports:["6379",],
    },
    nodeports: {
      redisports:["",],
    },
    master: {
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
    },
    slave: {
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
    },

    componentoramah: $.componentoramah,
    amah: {
      image: $.registry + "/tools/amah-redis-4.0.2:0.0.2-snapshot",
      exservicetype: $.exservicetype,
      instancecount: 1,
      requestcpu: "0",
      requestmem: "0",
      limitcpu: "0",
      limitmem: "0",
      externalports: {
        amahports:[8084,],
      },
      nodeports: {
        amahports:["",],
      },
    },
   },

   mongodb: {
     image: $.registry + "/tools/mongodb-3.6.4:0.1-lbsheng",
     exservicetype: $.exservicetype,
     instancecount: 3,
     requestcpu: "0",
     requestmem: "0",
     limitcpu: "0",
     limitmem: "0",
     mongodbrsname: "enn-mongodb-cluster",
     datastoragesize: "500Mi",
     logstoragesize: "100Mi",
     externalports: {
       clientports:[27017 + i for i in std.range(0,$.mongodb.instancecount - 1)],
     },
     nodeports: {
       clientports:["" for count in std.range(1, $.mongodb.instancecount)],
     },

     componentoramah: $.componentoramah,
     amah: {
       image: $.registry + "/tools/amah-mongodb-3.6.4:0.0.4-snapshot",
       exservicetype: $.exservicetype,
       instancecount: 1,
       requestcpu: "0",
       requestmem: "0",
       limitcpu: "0",
       limitmem: "0",
       externalports: {
         amahports:[8084],
       },
       nodeports: {
         amahports:[""],
       },
      },
    },
 
  redisstandalone: { 
    image: $.registry + "/tools/dep-debian-redisstandalone-4.0.11:0.1", 
    exservicetype: $.exservicetype, 
    datastoragesize: "1Gi",
    instancecount: 1, 
    replicas: 1, 
    requestcpu: "0", 
    requestmem: "0", 
    limitcpu: "0", 
    limitmem: "0", 
    externalports: { 
      httpports:[6379 + i for i in std.range(0,$.redisstandalone.instancecount - 1)],
       
    }, 
    nodeports: { 
      httpports:["" for count in std.range(1, $.redisstandalone.instancecount)],
       
    }, 
   },
 
  engine: { 
    image: $.registry + "/enncloud/prometheus-engine-s3:0.1", 
    initcontainerimage: $.registry + "/enncloud/init-container:1.0",
    exservicetype: $.exservicetype, 
    instancecount: 1, 
    replicas: 1, 
    requestcpu: "1", 
    requestmem: "1Gi", 
    limitcpu: "2", 
    limitmem: "2Gi",
    s3bucket: "s3-wst",
    GoMaxProcs: "8",
    RetainTime: "1440h",
    SyncInterval: "3600",
    Timeout: "120",
    externalports: { 
      port1s:[9090 + i for i in std.range(0,$.engine.instancecount - 1)],
      port2s:[8092 + i for i in std.range(0,$.engine.instancecount - 1)],
       
    }, 
    nodeports: { 
      port1s:[""],
      port2s:[""],
       
    }, 
   },
 
  admincenter: { 
    image: $.registry + "/enncloud/prometheus-admin-center-s3:0.1", 
    exservicetype: $.exservicetype, 
    instancecount: 1, 
    replicas: 1, 
    requestcpu: "0.5", 
    requestmem: "1Gi", 
    limitcpu: "1", 
    limitmem: "1.5Gi", 
    mysqlserver: "monitor-mysql1.wst:3306",
    consolegrpc: "10.19.140.200:32212,10.19.140.200:32312,10.19.140.200:32412",
    prometheus: "prometheus-engine1.wst:9090",
    prometheusamah: "prometheus-engine1.wst:8092",
    osticketswitch: "OFF",
    osticketserver: "http://10.19.138.165:8088",
    s3bucket: "s3-wst",
    Timeout: "120",
    externalports: { 
      port1s:[50052 + i for i in std.range(0,$.admincenter.instancecount - 1)],
      port2s:[50051 + i for i in std.range(0,$.admincenter.instancecount - 1)],
       
    }, 
    nodeports: { 
      port1s:[""],
      port2s:[""],
       
    }, 
   },
 
  scriptexporter: { 
    image: $.registry + "/enncloud/prometheus-script-exporter-s3:0.1", 
    exservicetype: $.exservicetype, 
    instancecount: 1, 
    replicas: 1, 
    requestcpu: "1", 
    requestmem: "1Gi", 
    limitcpu: "2", 
    limitmem: "2Gi",
    workspace: "/opt/script-exporter",
    cephpath: "/opt/mntcephutils/acw/scripts",
    mysqlserver: "prometheus-mysql1.wst:3306",
    s3bucket: "s3-wst",
    Timeout: "120",
    externalports: { 
      port1s:[9172 + i for i in std.range(0,$.scriptexporter.instancecount - 1)],
       
    }, 
    nodeports: { 
      port1s:[""],
       
    }, 
   },
 
  acw: { 
    image: $.registry + "/enncloud/prometheus-admin-center-web-s3:0.1", 
    exservicetype: $.exservicetype, 
    instancecount: 1, 
    replicas: 1, 
    requestcpu: "0.5", 
    requestmem: "1Gi", 
    limitcpu: "1", 
    limitmem: "1.5Gi", 
    scriptexporter: "prometheus-scriptexporter1.wst:9172",
    automation: "prometheus-automation1.wst:8091",
    alertmanager: "prometheus-alertmanager1.wst:9093",
    configserviceserver: "10.19.140.200:30136",
    s3bucket: "s3-wst",
    Timeout: "120",
    externalports: { 
      port1s:[8090 + i for i in std.range(0,$.acw.instancecount - 1)],
       
    }, 
    nodeports: { 
      port1s:[""],
       
    }, 
   },
 
  automation: { 
    image: $.registry + "/enncloud/prometheus-automation-s3:0.1", 
    exservicetype: $.exservicetype, 
    instancecount: 1, 
    replicas: 1, 
    requestcpu: "0.5", 
    requestmem: "1Gi", 
    limitcpu: "1", 
    limitmem: "1.5Gi",
    workspace: "/opt/automation",
    cephpath: "/opt/mntcephutils/acw/scripts",
    alertmanager: "prometheus-alertmanager1.wst:9093",
    mysqlserver: "prometheus-mysql1.wst:3306",
    s3bucket: "s3-wst",
    Timeout: "120",
    externalports: { 
      port1s:[8091 + i for i in std.range(0,$.automation.instancecount - 1)],
       
    }, 
    nodeports: { 
      port1s:[""],
       
    }, 
   },
 
  mockserver: { 
    image: $.registry + "/enncloud/mock-server:0.1", 
    exservicetype: $.exservicetype, 
    instancecount: 1, 
    replicas: 1, 
    requestcpu: "0.3", 
    requestmem: "200Mi", 
    limitcpu: "0.3", 
    limitmem: "300Mi",
    externalports: { 
      port1s:[8001 + i for i in std.range(0,$.mockserver.instancecount - 1)],
       
    }, 
    nodeports: { 
      port1s:[""],
       
    }, 
   },
 
  pushgateway: { 
    image: $.registry + "/enncloud/monitor-prometheus-pushgateway-s3:0.1", 
    exservicetype: $.exservicetype, 
    instancecount: 1, 
    replicas: 1, 
    requestcpu: "0.5", 
    requestmem: "300Mi", 
    limitcpu: "1", 
    limitmem: "1.5Gi", 
    externalports: { 
      port1s:[9091 + i for i in std.range(0,$.pushgateway.instancecount - 1)],
       
    }, 
    nodeports: { 
      port1s:[""],
       
    }, 
   },
 
  pushprom: { 
    image: $.registry + "/enncloud/prometheus-pushprom-s3:0.1", 
    exservicetype: $.exservicetype, 
    instancecount: 1, 
    replicas: 1, 
    requestcpu: "0.5", 
    requestmem: "300Mi", 
    limitcpu: "1", 
    limitmem: "1.5Gi", 
    externalports: { 
      port1s:[9092 + i for i in std.range(0,$.pushprom.instancecount - 1)],
       
    }, 
    nodeports: { 
      port1s:[""],
       
    }, 
   },
 
  alertmanager: { 
    image: $.registry + "/enncloud/prometheus-alertmanager:0.1", 
    exservicetype: $.exservicetype, 
    instancecount: 1, 
    replicas: 1, 
    requestcpu: "0.5", 
    requestmem: "800Mi", 
    limitcpu: "1", 
    limitmem: "1.5Gi", 
    mysqlserver: "prometheus-mysql1.wst:3306",
    wechatrobot: "10.19.140.200:29330",
    externalports: { 
      port1s:[9093 + i for i in std.range(0,$.alertmanager.instancecount - 1)],
       
    }, 
    nodeports: { 
      port1s:[""],
       
    }, 
   },
}
