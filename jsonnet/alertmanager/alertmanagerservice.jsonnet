( import "../common/service.jsonnet" ) {
  // global variables
  _alertmanagerprefix:: "",

  // override super global variables
  _mname: "alertmanager",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "port1:9093",
    
  ],
}
