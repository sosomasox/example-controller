#!/bin/bash -x

set -o errexit
set -o nounset
set -o pipefail

# corresponding to go mod init <module>
MODULE=github.com/sosomasox/example-controller
# api package
APIS_PKG=apis
# group-version such as foo:v1alpha1
GROUP=example
VERSION=v1alpha1
GROUP_VERSION=${GROUP}:${VERSION}
# generated output package
OUTPUT_PKG=generated/${GROUP}


SCRIPT_ROOT=$(dirname "${BASH_SOURCE[0]}")/..
CODEGEN_PKG=${CODEGEN_PKG:-$(cd "${SCRIPT_ROOT}"; ls -d -1 ./vendor/k8s.io/code-generator 2>/dev/null || echo ../code-generator)}

# generate the code with:
# --output-base    because this script should also be able to run inside the vendor dir of
#                  k8s.io/kubernetes. The output-base is needed for the generators to output into the vendor dir
#                  instead of the $GOPATH directly. For normal projects this can be dropped.

rm -rf generated

bash "${CODEGEN_PKG}"/generate-groups.sh "client,lister,informer" \
  ${MODULE}/${OUTPUT_PKG} ${MODULE}/${APIS_PKG} \
  ${GROUP_VERSION} \
  --go-header-file "${SCRIPT_ROOT}"/hack/boilerplate.go.txt \
  --output-base "${SCRIPT_ROOT}"

mv ${MODULE}/generated generated
rm -rf `echo ${MODULE} | cut -d '/' -f 1`
rm -rf generated/${GROUP}/clientset/versioned/fake
rm -rf generated/${GROUP}/clientset/versioned/typed/${GROUP}/v1alpha1/fake

exit 0
