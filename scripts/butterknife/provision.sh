#!/bin/sh

CURL="curl -s"
URL="https://mgmt.koodur.com/api"

TARGET_MOUNTPOINT=/mnt/target
TARGET_DIRECTORY=$TARGET_MOUNTPOINT/rootfs

# These Bashisms are insane
for chunk in $(cat /proc/cmdline); do
    case "$chunk" in
        butterknife_api_url=*)
        URL="${chunk#butterknife_api_url=}"
        ;;
    esac
done

$CURL $URL/container/ \
  | jq '.containers[] | .name + " \"" + .description + "\""' -r \
  > /tmp/available_templates
dialog --menu "Select template to deploy from $URL" 0 0 0 \
    --file /tmp/available_templates 2>/tmp/selected_template
TEMPLATE=$(cat /tmp/selected_template)

$CURL $URL/container/$TEMPLATE/snapshot/ \
  | jq '.snapshots[] | .name+" \""+.comment + "\""' -r \
  | sort -r \
  > /tmp/available_snapshots
dialog --menu "Select snapshot to deploy" 0 0 0 \
    --file /tmp/available_snapshots 2>/tmp/selected_snapshot
SNAPSHOT=$(cat /tmp/selected_snapshot)

STREAM="$URL/container/$TEMPLATE/snapshot/$SNAPSHOT/stream"

#exit 0

# Determine target disk
for disk in /dev/sd?; do
    slug=$(echo $disk | cut -d "/" -f 3)
    echo "$disk \"$(cat /sys/block/$slug/device/model | xargs) ($(expr $(cat /sys/block/$slug/size) \* $(cat /sys/block/$slug/queue/hw_sector_size) / 1000000000)G)\"";
done > /tmp/disks

dialog --menu "Target disk" 0 0 0 --file /tmp/disks 2> /tmp/selected_disk

DISK=$(cat /tmp/selected_disk)
DISK_SLUG=$(echo $DISK | cut -d "/" -f 3)

dialog --menu "Partitioning $DISK" 0 0 0 \
    purge           "Overwrite whole disk" \
    reformat        "Reformat partition" \
    receive         "Receive into existing btrfs filesystem" \
    unpartitioned   "Use unpartitioned area" 2> /tmp/partitioning_method

clear

# TODO: EFI way is not currently covered!
case $(cat /tmp/partitioning_method) in
    "unpartitioned")
        clear 
        echo "Attempting to create new partition in unpartitioned space"
        echo -e "n\np\n1\n\n\nw" | fdisk $DISK
        sleep 3
    ;;
    "purge")
        clear
        echo "Purging whole disk"
        echo -e "o\nn\np\n1\n\n\nw" | fdisk $DISK
        sleep 3
    ;;
esac

# Determine target partition
for partition in $DISK?; do
    partition_slug=$(echo $partition | cut -d "/" -f 3)
    echo "$partition \"$(cat /sys/block/$DISK_SLUG/$partition_slug/size)\"";
done > /tmp/partitions

dialog --menu "Target partition" 0 0 0 --file /tmp/partitions 2> /tmp/selected_partition
clear

PARTITION=$(cat /tmp/selected_partition)
PARTITION_SLUG=$(echo $PARTITION | cut -d "/" -f 3)

case $(cat /tmp/partitioning_method) in
    "receive") 
        echo "Skipping filesystem creation"
    ;;
    *)
        echo "Creating clean btrfs filesystem on $PARTITON"
        mkfs.btrfs -f $PARTITION
    ;;
esac

mkdir -p $TARGET_MOUNTPOINT
mount $PARTITION $TARGET_MOUNTPOINT
if [ $? -ne 0 ]; then
    dialog --msgbox "Mounting $PARTITION at $TARGET_MOUNTPOINT, are you sure kernel has btrfs support built-in?" 0 0
    exit 255
fi

mkdir -p $TARGET_DIRECTORY

echo "Mountpoints:"

# Determine transfer method
dialog --menu "Select transfer method" 0 0 0 \
    multicast "Multicast receive" \
    http "HTTP-only" \
    tee "HTTP and multicast" 2>/tmp/transfer_method
clear

TRANSFER_METHOD=$(cat /tmp/transfer_method)
	
case $TRANSFER_METHOD in
    multicast)
        udp-receiver | zcat | pv | btrfs receive $TARGET_DIRECTORY
    ;;
    http)
        $CURL $STREAM | zcat | pv | btrfs receive $TARGET_DIRECTORY
    ;;
    tee)
        $CURL $STREAM | tee '>(zcat | btrfs receive $TARGET_DIRECTORY)' | udp-sender
    ;;
esac

echo "Flushing buffers"
sync
sleep 1
echo "Rebooting machine"
reboot -f
