# Enlarge logical volume by 10G
lvresize -L +10G vg-name/lv-name

# Create a new volume on thin pool with virtual size 1G
lvcreate -V1G -T vg-main/microvm-pool --name foo

# Create a snapshot
lvcreate -s -n foo-snapshot vg-main/foo

# Restore from snapshot
lvconvert --merge vg-main/foo-snapshot

