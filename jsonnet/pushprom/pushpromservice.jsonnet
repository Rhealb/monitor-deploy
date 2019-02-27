( import "../common/service.jsonnet" ) {
  // global variables
  _pushpromprefix:: "",

  // override super global variables
  _mname: "pushprom",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "port1:9092",
    
  ],
}
