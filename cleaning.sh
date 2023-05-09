#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Definitions
# Source, destination and log directories, even the archived log file
source_dir="/data"
dest_dir="/archived"
log_dir="/tmp/"
log_file="archived.log"
force_directories_creation=true

# Initial Checks
# Source directory exists??? or empty??
# Destination directory exists???
# Logs????

# Source directory
if [ ! -d "$source_dir" ]; then
  echo "ERROR: Source directory '$source_dir' does not exist."
  exit 1
fi

# The source directory is empty?
if [ -z "$(ls -A "$source_dir")" ]; then
  echo "ERROR: Source directory '$source_dir' is empty."
  exit 0
fi

# Destination directory
if [ ! -d "$dest_dir" ]; then
  # Create if force_directories_creation is true
  if [ "$force_directories_creation" = true ]; then
    mkdir -p "$dest_dir"
    echo "Destination directory '$dest_dir' created."
  else
    echo "ERROR: Destination directory '$dest_dir' does not exist."
    exit 1
  fi
fi

# Log directory
if [ ! -d "$log_dir" ]; then
  # Create if force_directories_creation is true
  if [ "$force_directories_creation" = true ]; then
    mkdir -p "$log_dir"
    echo "Log directory '$log_dir' created."
  else
    echo "ERROR: Log directory '$log_dir' does not exist."
    exit 1
  fi
fi

# Time to move some files and directories
# Older than 1 year
find "$source_dir" -type f -mtime +365 -print0 | while IFS= read -r -d '' file; do
    # Define destination path
    dest_path="$dest_dir/$(dirname "${file#$source_dir/}")"
    # Move the file to the destination directory ensuring that the destination directory exist
    mkdir -p "$dest_path"
    mv "$file" "$dest_path"
    # Name of the moved file to the log
    echo "${file#$dest_dir/}" >> "$log_dir/$log_file"
done

# Final message
echo "Files achieving the criteria moved"
echo "You can check the log file here: '$log_dir/$log_file'"
