#/bin/bash

backup_dir="moneys_backup"
origin_file="/home/renatus/Desktop/moneys.origin.xhb"
stable_filename="moneys.stable.xhb"

function log(){
    echo "[NOTICE]:$(date +%F_%T) $1"
}
function warning(){
    echo "[WARNING]:$(date +%F_%T) $1"
}
function error(){
    echo "[ERROR]:$(date +%F_%T) $1"
}

# Checking backup dir existense and corrected storage
function check_backup_dir_exist(){
    local storage=$1 

    if [ -d "/mnt/$storage/$backup_dir" ]; then
        log "Found $storage storage"
    else
        if [ ! -d "/mnt/$storage" -o -z $storage ] ; then
            error "Uncorrect storage - /mnt/$storage"
            failed_storage=$storage
            storages=(${storages[@]/$failed_storage})
        else
            warning "Storage $storage found, but backup dir not, creating..."
            mkdir -p "/mnt/$storage/$backup_dir"
        fi
    fi
}

# Check if stable version exists
function check_stable_version_exists(){
    local storage=$1;
    
    log "Checking stable version of moneys file on storage:$storage"

    if [[ ! -f "/mnt/$storage/$backup_dir/$stable_filename" ]] ; then
        warning "Stable version does not found on storage:$storage. Copying from $origin_file"
        cp "$origin_file" "/mnt/$storage/$backup_dir/$stable_filename"
    else
        # Checking if stable file on storage differ and older than stable file in origin dir 
        if ! cmp -s "$origin_file" "/mnt/$storage/$backup_dir/$stable_filename" ; then
            warning "Stable file on storage:$storage and origin file $origin_file are differs, copying $origin_file to stable"
            rm "/mnt/$storage/$backup_dir/$stable_filename"
            cp "$origin_file" "/mnt/$storage/$backup_dir/$stable_filename"
            
            year="$(date +%Y)"
            month="$(date +%m)"
            day="$(date +%d)"

            save_dir="/mnt/$storage/$backup_dir/$year/$month/$day"

            log "Saving in history stable file with timestamp"
            mkdir -p $save_dir
            cp "$origin_file" $save_dir/moneys.$(date +%F_%T).xhb -v
        else
            log "Stable version found on storage:$storage"
        fi
    fi
}

storages=()

# Formatting storages array, using first argument of command
for strg in $(seq $(echo "$1" | wc -w)); do
    let index=$strg+1
    storages[$index]=$(echo $1 | cut -d " " -f $strg);
done

# We not sure if storage exists
for storage in "${storages[@]}"; do
    check_backup_dir_exist $storage
done


# Running main function for single storage, specified from $1
function main(){
    local storage=$1

    check_stable_version_exists $storage
}

for storage in "${storages[@]}"; do
    echo "--------------------------RUNNING FOR $storage-------------------------"
    log "Running script for storage:$storage"
    main $storage
done;