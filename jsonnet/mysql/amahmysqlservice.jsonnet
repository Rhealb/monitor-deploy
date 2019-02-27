( import "../common/service.jsonnet" ) {
  // global variables
  _amahmysqlprefix:: "",

  // override super global variables
  _mname: "amahmysql",
  _mnamespace: "hadoop-jsonnet",
  _nameports: [
    "amahport:8084",
    
  ],
}
