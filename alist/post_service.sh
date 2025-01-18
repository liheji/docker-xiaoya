#!/bin/bash

SETTING_API="http://127.0.0.1:5678/api/public/settings"
SCRIPT_DIR="/script"
LOG_FILE="${SCRIPT_DIR}/script.log"
FLAG_FILE="${SCRIPT_DIR}/script.flag"

check_setting() {
	local setting_resp
	setting_resp=$(curl --connect-timeout 2 --silent --location --request GET "$SETTING_API")
	if [ -z "$setting_resp" ]; then
		return 1
	fi

	if [ "$(echo "$setting_resp" | jq -r '.code')" -ne 200 ]; then
		return 1
	fi

	return 0
}

# Create file if it does not exist
if [ ! -f "$FLAG_FILE" ]; then
	touch "$FLAG_FILE"
fi
if [ ! -f "$LOG_FILE" ]; then
	touch "$LOG_FILE"
fi

# Call check_setting and exit if it fails
check_setting
if [ $? -ne 0 ]; then
	echo "$(date "+%Y-%m-%d %H:%M:%S"): 无法连接到xiaoya-alist" >>"$LOG_FILE"
	exit 1
fi

# Execute scripts
for script in "${SCRIPT_DIR}"/*.sh; do
  cur_hour=$(date "+%Y%m%d%H")
	if [ -f "$script" ] && ! grep -q "${cur_hour}${script}" "$FLAG_FILE"; then
		/bin/bash "$script" >>"$LOG_FILE"
		if [ $? -eq 0 ]; then
			# If script run result is 0, write flag
			echo "${cur_hour}${script}" >>"$FLAG_FILE"
		fi
		echo "$(date "+%Y-%m-%d %H:%M:%S"): 后置脚本 $script 执行结果: $?" >>"$LOG_FILE"
	fi
done
