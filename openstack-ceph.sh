#!/bin/bash

if [ $1 = config ];
then
# create kolla configs dirs
 if [ ! -d /etc/kolla/config/cinder ];
 then
 mkdir /etc/kolla/config/cinder -p
 fi

 if [ ! -d /etc/kolla/config/cinder/cinder-backup ];
 then
 mkdir /etc/kolla/config/cinder/cinder-backup -p
 fi

 if [ ! -d /etc/kolla/config/cinder/cinder-volume ];
 then
 mkdir /etc/kolla/config/cinder/cinder-volume -p
 fi

 if [ ! -d /etc/kolla/config/glance ];
 then
 mkdir /etc/kolla/config/glance -p
 fi

 if [ ! -d /etc/kolla/config/nova ];
 then
 mkdir /etc/kolla/config/nova -p
 fi
# cinder
scp oscpnode1:/etc/kolla/cinder-backup/ceph.client.cinder.keyring /etc/kolla/config/cinder/
scp oscpnode1:/etc/kolla/cinder-backup/ceph.client.cinder-backup.keyring /etc/kolla/config/cinder/
scp oscpnode1:/etc/kolla/cinder-backup/ceph.client.cinder.keyring /etc/kolla/config/cinder/cinder-backup/
scp oscpnode1:/etc/kolla/cinder-backup/ceph.client.cinder-backup.keyring /etc/kolla/config/cinder/cinder-backup/
scp oscpnode1:/etc/kolla/cinder-backup/ceph.client.cinder.keyring /etc/kolla/config/cinder/cinder-volume/
cat /etc/ceph/ceph.conf|grep -e "global" -e "mon\ initial" -e "mon\ host" -e "fsid" > /etc/kolla/config/cinder/ceph.conf
cat >> /etc/kolla/config/cinder/ceph.conf << EOF
keyring = /etc/kolla/cinder-backup/ceph.client.cinder.keyring
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
EOF
cat /etc/ceph/ceph.conf|grep -e "global" -e "mon\ initial" -e "mon\ host" -e "fsid" > /etc/kolla/config/cinder/cinder-backup/ceph.conf
cat >> /etc/kolla/config/cinder/cinder-backup/ceph.conf << EOF
keyring = /etc/kolla/cinder-backup/ceph.client.cinder-backup.keyring
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
EOF
cat /etc/ceph/ceph.conf|grep -e "global" -e "mon\ initial" -e "mon\ host" -e "fsid" > /etc/kolla/config/cinder/cinder-volume/ceph.conf
cat >> /etc/kolla/config/cinder/cinder-volume/ceph.conf << EOF
keyring = /etc/kolla/cinder-backup/ceph.client.cinder.keyring
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
EOF
cat > /etc/kolla/config/cinder/cinder.conf << EOF
[DEFAULT]
enabled_backends = rbd-1
[rbd-1]
volume_driver = cinder.volume.drivers.rbd.RBDDriver
volume_backend_name = rbd-1
rbd_pool = volumes
rbd_ceph_conf = /etc/ceph/ceph.conf
rbd_flatten_volume_from_snapshot = false
rbd_max_clone_depth = 5
rbd_store_chunk_size = 4
rados_connect_timeout = 5
rbd_user = cinder
report_discard_supported = True
image_upload_use_cinder_backend = True
EOF

cat > /etc/kolla/config/cinder/cinder-backup.conf << EOF
[DEFAULT]
backup_ceph_conf=/etc/ceph/ceph.conf
backup_ceph_user=cinder-backup
backup_ceph_chunk_size = 134217728
backup_ceph_pool=backups
backup_driver = cinder.backup.drivers.ceph.CephBackupDriver
backup_ceph_stripe_unit = 0
backup_ceph_stripe_count = 0
restore_discard_excess_bytes = true
EOF

cat > /etc/kolla/config/cinder/cinder-volume.conf << EOF
[DEFAULT]
enabled_backends = rbd-1
[rbd-1]
volume_driver = cinder.volume.drivers.rbd.RBDDriver
volume_backend_name = rbd-1
rbd_pool = volumes
rbd_ceph_conf = /etc/ceph/ceph.conf
rbd_flatten_volume_from_snapshot = false
rbd_max_clone_depth = 5
rbd_store_chunk_size = 4
rados_connect_timeout = 5
rbd_user = cinder
rbd_secret_uuid = {{ cinder_rbd_secret_uuid }}
report_discard_supported = True
image_upload_use_cinder_backend = True
EOF
cp /etc/kolla/config/cinder/cinder.conf /etc/kolla/config/cinder/cinder-backup/
cp /etc/kolla/config/cinder/cinder.conf /etc/kolla/config/cinder/cinder-volume/
sed -i $'s/\t//g' /etc/kolla/config/cinder/*.keyring
sed -i $'s/\t//g' /etc/kolla/config/cinder/cinder-backup/*.keyring
sed -i $'s/\t//g' /etc/kolla/config/cinder/cinder-volume/*.keyring
# glance
scp oscpnode1:/etc/kolla/glance-api/ceph.client.glance.keyring /etc/kolla/config/glance/
cat /etc/ceph/ceph.conf|grep -e "global" -e "mon\ initial" -e "mon\ host" -e "fsid" > /etc/kolla/config/glance/ceph.conf
cat >> /etc/kolla/config/glance/ceph.conf << EOF
keyring = /etc/kolla/glance-api/ceph.client.glance.keyring
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
EOF
cat > /etc/kolla/config/glance/glance-api.conf << EOF
[glance_store]
stores = rbd
default_store = rbd
rbd_store_pool = images
rbd_store_user = glance
rbd_store_ceph_conf = /etc/ceph/ceph.conf
EOF
sed -i $'s/\t//g' /etc/kolla/config/glance/*.keyring
# nova
scp oscpnode4:/etc/kolla/cinder-backup/ceph.client.cinder.keyring /etc/kolla/config/nova/
cat /etc/ceph/ceph.conf|grep -e "global" -e "mon\ initial" -e "mon\ host" -e "fsid" > /etc/kolla/config/nova/ceph.conf
cat >> /etc/kolla/config/nova/ceph.conf << EOF
keyring = /etc/kolla/cinder-backup/ceph.client.cinder.keyring
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
EOF
cat > /etc/kolla/config/nova/nova-compute.conf << EOF
[libvirt]
images_rbd_pool=vms
images_type=rbd
images_rbd_ceph_conf=/etc/ceph/ceph.conf
rbd_user=cinder
EOF
sed -i $'s/\t//g' /etc/kolla/config/nova/*.keyring
fi
