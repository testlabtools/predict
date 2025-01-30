#!/usr/bin/env bash
set -euo pipefail

pkg_name="record"
pkg_version="latest"

repo="${REPO_ROOT:-.}"
predicted_tests_file="${PREDICTED_TESTS_FILE:-/tmp/predicted-tests.json}"

trap "cleanup" EXIT

cleanup() {
	rm -rf "./${pkg_name}" "./${pkg_name}.tar.gz"
}

error() {
	local msg="$1"
	echo "error: $msg" >&2
	exit 1
}

if [[ -z "${TESTLAB_KEY}" ]]; then
	error "environment variable TESTLAB_KEY is empty"
fi

if [[ -z "${TESTLAB_GROUP}" ]]; then
	error "environment variable TESTLAB_GROUP is empty"
fi

os="$(uname -s)"
platform="$(uname -m)"

echo "::group::Prepare record"

set -x

if [[ ! (-f "./${pkg_name}") ]]; then
	curl --fail --location --retry 3 "https://github.com/testlabtools/${pkg_name}/releases/${pkg_version}/download/${pkg_name}_${os}_${platform}.tar.gz" -o "./${pkg_name}.tar.gz"
	tar -xvf "${pkg_name}.tar.gz"
fi
chmod +x "${pkg_name}"

set +x

echo "::endgroup::"

"./${pkg_name}" predict --repo "$repo" --predicted-tests-file "$predicted_tests_file"
