{
  // alertmanager deploy global variables
  _alertmanagerinstancecount:: 1,
  _alertmanagerreplicas:: 1,
  _namespace:: "hadoop-jsonnet",
  _suiteprefix:: "pre",
  _alertmanagerdockerimage:: "10.19.248.12:30100/tools/dep-centos7-zookeeper:3.4.9",
  _alertmanagerrequestcpu:: "0",
  _alertmanagerrequestmem:: "0",
  _alertmanagerlimitcpu:: "0",
  _alertmanagerlimitmem:: "0",
  _externalips:: ["10.19.248.18", "10.19.248.19", "10.19.248.20"],
  _alertmanagerexternalports:: [],
  _alertmanagernodeports:: [],
  _alertmanagerexservicetype:: "ClusterIP",
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
  local externalport1s = $._alertmanagerexternalports.port1s,
  
  local nodeport1s = $._alertmanagernodeports.port1s,
  
  local externalips = $._externalips,
  local storageprefix = $._suiteprefix,
  local cephbasename = ["alertmanagerutils"],
  local cephstoragename = [storageprefix + "-" + name for name in cephbasename],
  kind: "List",
  apiVersion: "v1",
  items: (if $._alertmanagerexservicetype != "None" then
  [
    (import "../alertmanagerservice.jsonnet") + {
      // override alertmanagerservice global variables
      _alertmanagerprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._alertmanagerprefix + "-" + super._mname + num + "-ex",
      _sname: self._alertmanagerprefix + "-" + super._mname + num,
      _servicetype: $._alertmanagerexservicetype,
      spec+: if self._servicetype == "ClusterIP" then
               {
                 externalIPs: externalips,
               }
             else
               {},
      _nameports: [
        "port1" + utils.addcolonforport(externalport1s[num - 1]) + ":9093",
        
      ],
      _nodeports: [
        "port1" + utils.addcolonforport(nodeport1s[num - 1]) + ":9093",
        
      ],
    } for num in std.range(1, $._alertmanagerinstancecount)
  ]
  else
  []) + [
    (import "../alertmanagerservice.jsonnet") + {
      // override alertmanagerservice global variables
      _alertmanagerprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._alertmanagerprefix + "-" + super._mname + num,
    } for num in std.range(1, $._alertmanagerinstancecount)
  ] + [
    (import "../alertmanager.jsonnet") + {
      // override alertmanager global variables
      _alertmanagerprefix: $._suiteprefix,
      _mnamespace: $._namespace,
      _mname: self._alertmanagerprefix + "-" + super._mname + num,
      _dockerimage: $._alertmanagerdockerimage,
      _replicacount: $._alertmanagerreplicas,
      _containerrequestcpu:: $._alertmanagerrequestcpu,
      _containerrequestmem:: $._alertmanagerrequestmem,
      _containerlimitcpu:: $._alertmanagerlimitcpu,
      _containerlimitmem:: $._alertmanagerlimitmem,
      _envs: [
        "BD_SUITE_PREFIX:" + self._alertmanagerprefix,
        "MYSQLSERVER:" + $._mysql_server,
        "WECHATROBOT:" + $._wechat_robot,
      ],
      _volumemounts:: $._volumemountscommon,
      _storages:: $._storagescommon,
      _volumes:: $._volumescommon,
      _command:: [ "/opt/entrypoint.sh", "/opt/mntcephutils/entry/entrypoint.sh" ],
    } for num in std.range(1, $._alertmanagerinstancecount)
  ],
}
