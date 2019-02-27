{
  // pushprom deploy global variables
  _pushprominstancecount:: 1,
  _pushpromreplicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _pushpromdockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _pushpromrequestcpu:: "0",
  _pushpromrequestmem:: "0",
  _pushpromlimitcpu:: "0",
  _pushpromlimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _pushpromexternalports:: [],
  _pushpromnodeports:: [],
  _pushpromexservicetype:: "ClusterIP",
  _utilsstoretype:: "ConfigMap",
  _volumemountscommon:: if $._utilsstoretype == "ConfigMap" then
                          [
                            "utilsconf:/opt/mntcephutils/conf:true",
                            "utilsentry:/opt/mntcephutils/entry:true",
                            "utilsscripts:/opt/mntcephutils/scripts:true",
                          ]
                        else if $._utilsstoretype == "FS" then
                          [
                            cephstoragename[0] + ":/opt/mntcephutils:true",
                          ],
  _storagescommon:: if $._utilsstoretype == "ConfigMap" then
                      []
                    else if $._utilsstoretype == "FS" then
                      [
                        cephstoragename[0],
                      ],
  _volumescommon:: if $._utilsstoretype == "ConfigMap" then
                     [
                       "utilsconf:configMap:" + storageprefix + "-" + cephbasename[0] + "-conf",
                       "utilsentry:configMap:" + storageprefix + "-" + cephbasename[0] + "-entry",
                       "utilsscripts:configMap:" + storageprefix + "-" + cephbasename[0] + "-scripts",
                     ]
                   else if $._utilsstoretype == "FS" then
                     [],
  local utils = import "../../common/utils/utils.libsonnet",
  local externalport1s = $._pushpromexternalports.port1s,
  
  local nodeport1s = $._pushpromnodeports.port1s,
  
  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["pushpromutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._pushpromexservicetype != "None" then
  [
    (import "../pushpromservice.jsonnet") + {
      // override pushpromservice global variables
      _pushpromprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._pushpromprefix + "-" + super._mname + num + "-ex",
      _sname: self._pushpromprefix + "-" + super._mname + num,
      _servicetype: $._pushpromexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "port1" + utils.addcolonforport(externalport1s[num - 1]) + ":9092",
        
      ],
      _nodeports: [
        "port1" + utils.addcolonforport(nodeport1s[num - 1]) + ":9092",
        
      ],
    } for num in std.range(1, $._pushprominstancecount)
  ]
  else
  []) + [
    (import "../pushpromservice.jsonnet") + {
      // override pushpromservice global variables
      _pushpromprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._pushpromprefix + "-" + super._mname + num,
    } for num in std.range(1, $._pushprominstancecount)
  ] + [
    (import "../pushprom.jsonnet") + {
      // override pushprom global variables
      _pushpromprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._pushpromprefix + "-" + super._mname + num,
      _dockerimage: $._pushpromdockerimage,
      _replicacount: $._pushpromreplicas,
      _containerrequestcpu:: $._pushpromrequestcpu,
      _containerrequestmem:: $._pushpromrequestmem,
      _containerlimitcpu:: $._pushpromlimitcpu,
      _containerlimitmem:: $._pushpromlimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._pushpromprefix,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/entrypoint.sh" ],
    } for num in std.range(1, $._pushprominstancecount)
  ],
}
