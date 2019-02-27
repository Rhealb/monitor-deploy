#!/bin/bash
ENNCTL=`command -v ennctl`
JSONNET=`command -v jsonnet`
JQ=`command -v jq`
if [[ -z ${JQ} ]]; then
  echo "please install binary jq"
  exit 1
fi
if [[ -z ${ENNCTL} ]]; then
  echo "please install binary ennctl"
  exit 1
fi
if [[ -z ${JSONNET} ]]; then
  echo "please install binary jsonnet"
  exit 1
fi

display_help() {
    echo
    echo "Usage: $0 create [option...] {component_example.jsonnet}"
    echo "       $0 delete [option...] {component_example.jsonnet}"
    echo
    echo "   -s, --S3  download config file from s3"
    echo "   -p, --podcontainer  start component with a pod, which is mount fs storage, by use 'ennctl cp' copy local utils to fs"
    echo "   -c, --configmap     start component with configmap"
    echo "   -m, --mountfs       start component by use mount file system, mount file system to local, cp utils to fs, due to use mount command, should have root privileges"
    echo "   -h, --help          display command help info"
    echo
    echo "Example:"
    echo
    echo "       ./bigctl.sh create zookeeper_example.jsonnet <=> ./bigctl.sh create -p zookeeper_example.jsonnet"
    echo "       ./bigctl.sh create -c zookeeper_example.jsonnet"
    echo "       ./bigctl.sh create -s zookeeper_example.jsonnet"
    echo "       sudo ./bigctl.sh create -m zookeeper_example.jsonnet"
    echo "       ./bigctl.sh delete -c zookeeper_example.jsonnet"
    echo "       ./bigctl.sh delete zookeeper_example.jsonnet  <=>  ./bigctl.sh delete -p zookeeper_example.jsonnet  <=> ./bigctl.sh -m delete zookeeper_example.jsonnet"
    echo "       ./bigctl.sh delete -s zookeeper_example.jsonnet"
    echo
}
if [[ $# -lt 2 ]]; then
  display_help
  exit 1
fi
if [ $1 == "create" ] || [ $1 == "delete" ]; then
  createOrdelete=$1
  shift
else
  echo "Error: The first paramter spell Error(create or delete)"
  display_help
  exit 1
fi
utilsstoretype=""
while [[ true ]]; do
  case "$1" in
    -h | --help)
        display_help  # Call help display function
        exit 0
        ;;
    -p | --podcontainer)
        if [[ $utilsstoretype == "mountfs" ]]||[[ $utilsstoretype == "configmap" ]]||[[ $utilsstoretype == "s3" ]]; then
          echo "Error: [-p] cannot be used with [-m] [-c] [-s] at the same time"
          display_help
          exit 1
        fi
        utilsstoretype="podcontainer"
        shift
        ;;
    -m | --mountfs)
        if [[ ${utilsstoretype} == "podcontainer" ]]||[[ ${utilsstoretype} == "configmap" ]]||[[ $utilsstoretype == "s3" ]]; then
          echo "Error: [-m] cannot be used with [-p] [-s] [-c] at the same time"
          display_help
          exit 1
        fi
        utilsstoretype="mountfs"
        shift
        ;;
    -c | --configmap)
        if [[ ${utilsstoretype} = "podcontainer" ]]||[[ ${utilsstoretype} = "mountfs" ]]||[[ $utilsstoretype == "s3" ]]; then
          echo "Error: [-c] cannot be used with [-p] [-m] [-s] at the same time"
          display_help
          exit 1
        fi
        utilsstoretype="configmap"
        shift
        ;;
    -s | --s3)
        if [[ ${utilsstoretype} = "podcontainer" ]]||[[ ${utilsstoretype} = "mountfs" ]]||[[ $utilsstoretype == "configmap" ]]; then
          echo "Error: [-s] cannot be used with [-p] [-m] [-c] at the same time"
          display_help
          exit 1
        fi
        utilsstoretype="s3"
        shift
        ;;
    -*)
        echo "Error: Unknown option: $1"
        display_help
        exit 1
        ;;
    *)
        break
        ;;
  esac
done
if [[ ${utilsstoretype} == "" ]]; then
  utilsstoretype="podcontainer"
fi
if [[ $1 == "" ]]; then
  display_help
  exit 1
fi
if [ -f $1 ]; then
  deploy_file=$1
else
  echo "file $1 is not exist......"
  exit 1
fi

# if the deploy file is druid,mysql or tranquility,the globalconfigpath must be the parent directory
if [ $(echo "${deploy_file}" | grep -E "druid_|tranquility_|plyql_" | wc -l) != 0 ]; then
  globalconfigpath=$(dirname ${deploy_file})/../
else
  globalconfigpath=$(dirname ${deploy_file})
fi

src_conf_path=${globalconfigpath}/../../cephutils
utilspath=$(cd ${src_conf_path}; pwd)
global_config=${globalconfigpath}/global_config.jsonnet
depoly_file_name=$(basename ${deploy_file})
namespace=$(${JSONNET} ${global_config} | ${JQ} -r '.namespace')
location=$(${JSONNET} ${global_config} | ${JQ} -r '.location')
mountdevtype=$(${JSONNET} ${global_config} | ${JQ} -r '.mountdevtype')
cephaddress=$(${JSONNET} ${global_config} | ${JQ} -r '.cephaddress')
nfsaddress=$(${JSONNET} ${global_config} | ${JQ} -r '.nfsaddress')
suiteprefix=$(${JSONNET} ${global_config} | ${JQ} -r '.suiteprefix')
registry=$(${JSONNET} ${global_config} | ${JQ} -r '.registry')
appname=${suiteprefix}-$(basename $deploy_file | awk -F "." '{print $1}' | awk -F "_" '{print $1}')
temutilsstoretype=$(${JSONNET} ${global_config} | jq -r '.utilsstoretype')


function s3decode {
  type=$1
  key=$2
  if [ "x${key}" = "x" ]; then
    echo "Error: you access-key or secret key is empty..."
    exit 1
  fi
  config=$(cd `dirname ~/.s3cfg`; pwd)
  s3cfg=${config}/.s3cfg
  echo ${key} > /tmp/decode1
  openssl enc -base64 -d -in /tmp/decode1 -out /tmp/decode2
  echo "" >> /tmp/decode2
  if [ "${type}" != "host_base" ]; then
    openssl enc -base64 -d -in /tmp/decode2 -out /tmp/decode3
    openssl enc -d -p -des3 -pass pass:Maserati -S 88888888 -in /tmp/decode3 -out /tmp/decode4 > /dev/null
    access_or_secret=`cat /tmp/decode4`
  fi
  hostbase=`cat /tmp/decode2`

  if [ "${type}" = "host_base" ]; then
    if [ `cat ~/.s3cfg | grep -c ${hostbase}` -ne 2 ]; then
      sed -i '/host_bucket/d' ${s3cfg}
      sed -i '/host_base/d' ${s3cfg}
      echo "host_base=${hostbase}" >> ${s3cfg}
      echo "host_bucket=${hostbase}" >> ${s3cfg}
    fi
  elif [ "${type}" = "access_key" ]; then
    if [ `cat ~/.s3cfg | grep access_key | grep -c ${access_or_secret}` -eq 0 ]; then
      sed -i '/access_key/d' ${s3cfg}
      echo "access_key=${access_or_secret}" >> ${s3cfg}
    fi
  elif [ "${type}" = "secret_key" ]; then
    if [[ `cat ~/.s3cfg | grep secret_key | grep -c ${access_or_secret}` -eq 0 ]]; then
      sed -i '/secret_key/d' ${s3cfg}
      echo "secret_key=${access_or_secret}" >> ${s3cfg}
    fi
  fi
  if [ -f /tmp/decode1 ]; then
    rm /tmp/decode1
  fi
  if [ -f /tmp/decode2 ]; then
    rm /tmp/decode2
  fi
  if [ -f /tmp/decode3 ]; then
    rm /tmp/decode3
  fi
  if [ -f /tmp/decode4 ]; then
    rm /tmp/decode4
  fi
}

if [[ ${utilsstoretype} == "configmap" ]]; then
  if [[ ${temutilsstoretype} != "ConfigMap" ]]; then
    sed -i "s/utilsstoretype: \"${temutilsstoretype}\",/utilsstoretype: \"ConfigMap\",/g" ${global_config}
  fi
elif [[ ${utilsstoretype} == "s3" ]]; then
  if [[ ${temutilsstoretype} != "S3" ]]; then
    sed -i "s/utilsstoretype: \"${temutilsstoretype}\",/utilsstoretype: \"S3\",/g" ${global_config}
  fi
elif [[ ${utilsstoretype} == "podcontainer" ]] || [[ ${utilsstoretype} == "mountfs" ]]; then
  if [[ ${temutilsstoretype} != "FS" ]]; then
    sed -i "s/utilsstoretype: \"${temutilsstoretype}\",/utilsstoretype: \"FS\",/g" ${global_config}
  fi
fi

sed -i "s/deploytype: \"podservice\",/deploytype: \"storage\",/g" ${global_config}
$JSONNET ${deploy_file} > /tmp/${appname}storage.json
sed -i "s/deploytype: \"storage\",/deploytype: \"podservice\",/g" ${global_config}
$JSONNET ${deploy_file} > /tmp/${appname}podservice.json

if [[ ${utilsstoretype} == "configmap" ]]; then
  cm=$(cat /tmp/${appname}podservice.json | jq -r '.items[]|select((.kind == "Deployment") or (.kind == "StatefulSet"))|.spec.template.spec.volumes[0].configMap.name' | sed -n "1p")
  local_utils=$(echo "$cm" | awk -F "-" '{print $(NF-1)}')
  utilsdir=${suiteprefix}"-"${local_utils}

elif [[ ${utilsstoretype} == "s3" ]]; then
  utilsdir=$(cat /tmp/${appname}podservice.json | jq -r '.items[]|select((.kind == "Deployment") or (.kind == "StatefulSet"))|.spec.template.spec.initContainers[0].command[2]' | sed -n "1p")
  local_utils=$(echo ${utilsdir} | awk -F "-" '{print $NF}')

elif [[ ${utilsstoretype} == "podcontainer" ]] || [[ ${utilsstoretype} == "mountfs" ]]; then
  utilsdir=$(cat /tmp/${appname}storage.json | jq -r '.items[] | .metadata.name' | grep "utils")
  local_utils=$(echo $utilsdir | awk -F '-' '{print $NF}')
fi

# create storage and podservice
if [ $createOrdelete = "create" ]; then
  #create storage
  $ENNCTL create -f /tmp/${appname}storage.json

  # copy local cephutils config and entrypoint to cephfs
  # hdfs and yarn use same utils storage, which is points at hdfs storage jsonnet file, so when you deploy yarn alone, we will think you have already deployed hdfs. due to the ${utilsdir} is empty, so we will skip this process
  # if ${utilsdir} equal "", we think by default that we do not need this utils storage, and will skip ennctl copy utils file process
  if [[ ${utilsstoretype} == "podcontainer" ]] && [[ "x${utilsdir}" != "x"  ]]; then
    cp ${globalconfigpath}/podexample/cpcephutilspod.json /tmp/cpcephutilspod.json
    sed -i -e "s/%NAMESPACE%/${namespace}/g" -e "s/%COMPONENTCEPHUTILS%/${utilsdir}/g" -e "s/%NAME%/${utilsdir}/g" -e "s/%REGISTRY%/${registry}/g" /tmp/cpcephutilspod.json
    cppodname=$(cat /tmp/cpcephutilspod.json | ${JQ} -r .metadata.name)
    if [ $(${ENNCTL} -n ${namespace} get pod | awk '{print $1}' | grep -E "(^)${cppodname}($)" | wc -l) != 0 ]; then
      echo "pod ${cppodname} already exist, delete first"
      ${ENNCTL} -n ${namespace} delete pod ${cppodname}
      rmpodtime=0
      while [[ true ]]; do
        sleep 2
        if [[ $(${ENNCTL} -n ${namespace} get pod | awk '{print $1}' | grep -E "(^)${cppodname}($)" | wc -l) = 0 ]]; then
          break
        fi
        ((rmpodtime+=2))
        if [ $((rmpodtime % 120)) = 0 ]; then
          echo "Warning: pod ${cppodname} can not be deleted, if you want to stop bigctl.sh, please ctrl + c"
        fi
      done
    fi
    if [[ $($ENNCTL -n $namespace get app | awk '{print $1}' | grep -E  "(^)$appname($)" | wc -l) = 0 ]]; then
      $ENNCTL -n $namespace create app $appname
    fi

    $ENNCTL -a ${appname} create -f /tmp/cpcephutilspod.json
    while [[ true ]]; do
      sleep 2
      if [[ $(${ENNCTL} -n ${namespace} get pod | grep -w ${cppodname} | awk '{print $3}') == "Running" ]]; then
        break;
      fi
    done
    podname=$(${ENNCTL} -n ${namespace} get pod | grep -w ${cppodname} | awk '{print $1}')
    $ENNCTL -n ${namespace} cp $src_conf_path/${local_utils} ${podname}:/opt/mntcephutils
    sleep 10
    if [[ $(${ENNCTL} -n ${namespace} exec ${podname} ls /opt/mntcephutils | wc -l) -eq 0  ]]; then
      echo "copy utils failed"
      exit 1
    fi
    $ENNCTL delete -f /tmp/cpcephutilspod.json
    rm -rf /tmp/cpcephutilspod.json
  # if ${utilsdir} equal "",  we think by default that we do not need this utils storage, and will skip mount ceph to local process
  elif [[ ${utilsstoretype} == "mountfs" ]] && [[ "x${utilsdir}" != "x"  ]]; then
    if [ ! -d /mnt/${location} ]; then
        mkdir -p /mnt/${location}
    fi
    if [ ${mountdevtype} = "CephFS" ]; then
      ceph_username=${namespace}
      ceph_secret=$($ENNCTL -n ${namespace} get secret ${namespace} -o json | jq -r '.data.key' | base64 -d)
      /bin/mount -t ceph ${cephaddress}:/k8s/${namespace} /mnt/${location} -o name=${ceph_username},secret=${ceph_secret}
    elif [ ${mountdevtype} = "EFS" ] || [ ${mountdevtype} = "NFS" ] ; then
      /bin/mount -t nfs ${nfsaddress}:/k8s/${namespace} /mnt/${location}
    else
      echo "Unkown mountdevtype ${mountdevtype}"
      exit 1
    fi
    if [[ ! -d /mnt/${location}/${utilsdir} ]]; then
      echo "Error: /mnt/${location}/${utilsdir} is not exist"
      echo "Error: May be mount cephfs failed, the current user is $(whoami)"
      exit 1
    fi
    cp -rf $src_conf_path/${local_utils}/* /mnt/${location}/${utilsdir}
    # umount ceph path
    /bin/umount -l /mnt/${location}
  # if ${utilsdir} equal "", we think by default that we do not need this utils storage, and will skip create configmap process
  elif [[ ${utilsstoretype} == "configmap" ]] && [[ "x${utilsdir}" != "x"  ]]; then
    for absoluteutilsdir in $(find ${utilspath}/${local_utils}/* -type d); do
      if [[ $(ls -F ${absoluteutilsdir} | grep '/$' | wc -l) -ne $(ls ${absoluteutilsdir} | wc -l) ]] || [[ $(ls ${absoluteutilsdir} | wc -l) -eq 0 ]]; then
        suffix=$(echo ${absoluteutilsdir} | sed "s|${utilspath}/${local_utils}||g" | sed 's|/||g' | tr 'A-Z' 'a-z' | sed 's/_//g')
        ${ENNCTL} -n ${namespace} create configmap ${utilsdir}-${suffix} --from-file=${absoluteutilsdir}
      fi
    done
  elif [[ ${utilsstoretype} == "s3" ]] && [[ "x${utilsdir}" != "x"  ]]; then
    S3CMD=`command -v s3cmd`
    if [ "x${S3CMD}" = "x" ]; then
      echo "Error: please install binary s3cmd"
      exit 1
    fi
    if [ ! -f ~/.s3cfg ]; then
      echo "Error: s3cfg connot exist......"
      exit 1
    fi
    access_key=$(${ENNCTL} -n ${namespace} get secret ${namespace}-access-key -o json | jq -r .data.value)
    s3decode access_key ${access_key}

    secret_key=$(${ENNCTL} -n ${namespace} get secret ${namespace}-secret-key -o json | jq -r .data.value)
    s3decode secret_key ${secret_key}

    host_base=$(${ENNCTL} -n ${namespace} get secret ${namespace}-s3-host -o json | jq -r .data.value)
    s3decode host_base ${host_base}

    `${S3CMD} ls > /dev/null`
    if [ $? -ne 0 ]; then
      echo "Error: s3cdm config error..."
      exit 1
    fi
    ${S3CMD} sync $src_conf_path/${local_utils}/ s3://s3-${namespace}/${suiteprefix}-${local_utils}/ > /dev/null
    remotepath=$(${S3CMD} ls s3://s3-${namespace}/${suiteprefix}-${local_utils}/)
    if [ "x${remotepath}" = "x" ]; then
      echo "Error: s3cmd upload utilsconfig file failed......"
      exit 1
    fi
  fi

  #create podservice
  if [[ $($ENNCTL -n $namespace get app | awk '{print $1}' | grep -E  "(^)$appname($)" | wc -l) = 0 ]]; then
    $ENNCTL -n $namespace create app $appname
  fi
  $ENNCTL create -f /tmp/${appname}podservice.json -a $appname

elif [ ${createOrdelete} = "delete" ]; then
  # delete podservice
  $ENNCTL delete -f /tmp/${appname}podservice.json

  #check pod whether already deleted
  cat /tmp/${appname}podservice.json | jq -r '.items[] | select((.kind == "Deployment") or (.kind == "StatefulSet")) | .metadata.name' > /tmp/${appname}depnamelist
  lines=$(cat /tmp/${appname}depnamelist | wc -l)
  TIMEOUT=120
  starttime=$(date +%s)
  while [ true ] ; do
    podcount=0
    sleep 1
    for (( i=1; i<=${lines}; i++)); do
      ((podcount+=$($ENNCTL -n $namespace get pod | grep $(cat /tmp/${appname}depnamelist | sed -n "${i}p") | wc -l)))
    done
    if [ $podcount -eq 0 ]; then
      echo "pod already deleted......."
      break
    fi
    endtime=$(date +%s)
    if [ $((${endtime}-${starttime})) -ge ${TIMEOUT} ]; then
        echo "delete pod timeout......."
        echo "Forced to delete pod...... "
        for (( i=1; i<=${lines}; i++)); do
          $ENNCTL -n $namespace get pod | grep $(cat /tmp/${appname}depnamelist | sed -n "${i}p") | awk '{print $1}' | xargs -I {} $ENNCTL -n $namespace delete pod {} --grace-period=0 --force=true
        done
        echo "pod forced to be deleted......."
        break
    fi
  done

  # delete app if there is no pod in this app
  if [ $($ENNCTL -n $namespace get pod -a $appname | awk '{print $3}' | grep -c Running) -eq 0 ]; then
    $ENNCTL -n $namespace delete app $appname
  fi

  #delete storage
  $ENNCTL delete -f /tmp/${appname}storage.json

  # delete configmap if there is no pod in this app
  if [ $($ENNCTL -n $namespace get pod -a $appname | awk '{print $3}' | grep -c Running) -eq 0 ]; then
    if [[ ${utilsstoretype} == "configmap" ]]; then
      for absoluteutilsdir in $(find ${utilspath}/${local_utils}/* -type d); do
        if [[ $(ls -F ${absoluteutilsdir} | grep '/$' | wc -l) -ne $(ls ${absoluteutilsdir} | wc -l) ]] || [[ $(ls ${absoluteutilsdir} | wc -l) -eq 0 ]]; then
          suffix=$(echo ${absoluteutilsdir} | sed "s|${utilspath}/${local_utils}||g" | sed 's|/||g' | tr 'A-Z' 'a-z' | sed 's/_//g')
          ${ENNCTL} -n ${namespace} delete configmap ${utilsdir}-${suffix}
        fi
      done
    fi
  fi
fi
if [ -f /tmp/${appname}podservice.json ]; then
  rm -f /tmp/${appname}podservice.json
fi
if [ -f /tmp/${appname}storage.json ]; then
  rm -f /tmp/${appname}storage.json
fi
if [ -f /tmp/${appname}depnamelist ]; then
  rm -f /tmp/${appname}depnamelist
fi
