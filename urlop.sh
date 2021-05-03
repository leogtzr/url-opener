#!/bin/bash
# set -x
#: @leogtzr <leogutierrezramirez@gmail.com>

readonly work_dir=$(dirname "$(readlink --canonicalize-existing "${0}" 2> /dev/null)")
readonly conf_file="${work_dir}/urlop.conf"
readonly error_conf_file_not_found=80
readonly error_reading_conf_file=81
readonly error_missing_env_bar=82
readonly error_missing_url_lst_file=83
readonly work_tmp_file="${work_dir}/url.tmp"

clean_up() {
	if [[ -f "${work_tmp_file}" ]]; then
		rm --force "${work_tmp_file}" > /dev/null >&2
	fi
}

trap clean_up ERR EXIT SIGINT SIGTERM

if [[ ! -f "${conf_file}" ]]; then
	echo "error: ${conf_file} not found" >&2
	exit ${error_conf_file_not_found}
fi

. "${conf_file}" || {
	echo "error: reading ${conf_file}" >&2
	exit ${error_reading_conf_file}
}

if [[ -z "${BROWSER}" ]]; then
	echo "error: BROWSER env variable not set" >&2
	exit ${error_missing_env_bar}
fi

if [[ -z "${url_list_file}" ]]; then
	echo "error: missing 'url_list_file'" >&2
	exit ${error_missing_env_bar}
fi

if [[ ! -f "${url_list_file}" ]]; then
	echo "error: ${url_list_file} not found" >&2
	exit ${error_missing_url_lst_file}
fi

for arg in ${@}; do
	echo "${arg}" >> "${work_tmp_file}"
done

readonly ocurrences_search_text=$(grep --ignore-case --file "${work_tmp_file}" "${url_list_file}" | \
	dmenu -l 30 -nb "#100" -nf "#b9c0af" -sb "#000" -sf "#afff2f" -i)

if [[ -z "${ocurrences_search_text}" ]]; then
	exit 0
fi

readonly url_to_open=$(awk '{print $1}' <<< $(echo "${ocurrences_search_text}"))
"${BROWSER}" "${url_to_open}" > /dev/null >&2

printf "Args n: %d\n" ${#}

exit 0