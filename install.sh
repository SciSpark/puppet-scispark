#!/bin/bash

mods_dir=/etc/puppet/modules
cd $mods_dir

##########################################
# need to be root
##########################################

id=`whoami`
if [ "$id" != "root" ]; then
  echo "You must be root to run this script."
  exit 1
fi


##########################################
# check that puppet and git is installed
##########################################

git_cmd=`which git`
if [ $? -ne 0 ]; then
  yum -y install git
fi

puppet_cmd=`which puppet`
if [ $? -ne 0 ]; then
  yum -y install puppet
fi


##########################################
# git url
##########################################

git_url="https://github.com"


##########################################
# export scispark puppet module
##########################################

git_loc="${git_url}/pymonger/puppet-scispark"
mod_dir=$mods_dir/scispark
site_pp=$mod_dir/site.pp

# check that module is here; if not, export it
if [ ! -d $mod_dir ]; then
  $git_cmd clone $git_loc $mod_dir
fi


##########################################
# apply
##########################################

$puppet_cmd apply $site_pp
