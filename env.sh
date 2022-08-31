set -e

# https://stackoverflow.com/a/28776166
is_sourced() {
    if [ -n "$ZSH_VERSION" ]; then
        case $ZSH_EVAL_CONTEXT in *:file:*) return 0;; esac
    else  # Add additional POSIX-compatible shell names here, if needed.
        case ${0##*/} in dash|-dash|bash|-bash|ksh|-ksh|sh|-sh) return 0;; esac
    fi
    return 1  # NOT sourced.
}

if ! is_sourced || ! [ -f $PWD/env.sh ] ; then
    echo "This script is meant to be sourced from its own directory"
    exit 2
fi

CURRENT=$(pwd)
ROOT="$CURRENT/.."

. $CURRENT/locate_cuda_root.sh >/dev/null

export GPR_PROJECT_PATH="$ROOT/cuda/api/:$ROOT/uwrap/lang_template/build:$ROOT/uwrap/lang_test/build:$ROOT/gnat-llvm/share/gpr:$GPR_PROJECT_PATH"
export PYTHONPATH="$ROOT/uwrap/lang_template/build/python:$ROOT/uwrap/lang_test/build/python:$PYTHONPATH"
export LD_LIBRARY_PATH="$ROOT/uwrap/lang_template/build/lib/relocatable/dev:$ROOT/uwrap/lang_test/build/lib/relocatable/dev:$ROOT/gnat-llvm/lib:$LD_LIBRARY_PATH"
export PATH="$ROOT/llvm-ads/bin:$ROOT/uwrap/bin:$ROOT/uwrap/lang_template/build/lib/relocatable/dev:$ROOT/uwrap/lang_template/build/obj-mains:$ROOT/uwrap/lang_template/build/scripts:$ROOT/uwrap/lang_test/build/lib/relocatable/dev:$ROOT/uwrap/lang_test/build/obj-mains:$ROOT/uwrap/lang_test/build/scripts:$ROOT/gnat-llvm/bin:$PATH"
export C_INCLUDE_PATH="$ROOT/uwrap/lang_template/build:$ROOT/uwrap/lang_test/build:$C_INCLUDE_PATH"
export DYLD_LIBRARY_PATH="$ROOT/uwrap/lang_template/build/lib/relocatable/dev:$ROOT/uwrap/lang_test/build/lib/relocatable/dev:$DYLD_LIBRARY_PATH"
export MYPYPATH="$ROOT/uwrap/lang_template/build/python:$ROOT/uwrap/lang_test/build/python:$MYPYPATH"
