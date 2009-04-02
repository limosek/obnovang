#!/bin/sh
# Script to copy obnova from server to local disc

# For all partitions which we want to refresh
foreach $partition in $op_list; do
  if [ -n "${op_fsck_${partition}}" ]
done
