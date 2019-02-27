( import "../common/service.jsonnet" ) {
  // global variables
  _mockserverprefix:: "",

  // override super global variables
  _mname: "mockserver",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "port1:8001",
    
  ],
}
