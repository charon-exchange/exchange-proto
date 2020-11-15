
if [ ! -f ./inited ]; then
    echo "Not inited"
    exit 1
fi

. ./envs.sh

export NAME=`tvm_linker test $ROOT_ADDRESS \
--abi-json RootTokenContract.abi \
--abi-method getName \
--abi-params '{}' \
--decode-c6 | grep "value0"`

export SYMBOL=`tvm_linker test $ROOT_ADDRESS \
--abi-json RootTokenContract.abi \
--abi-method getSymbol \
--abi-params '{}' \
--decode-c6 | grep "value0"`

export DECIMALS=`tvm_linker test $ROOT_ADDRESS \
--abi-json RootTokenContract.abi \
--abi-method getDecimals \
--abi-params '{}' \
--decode-c6 | grep "value0"`

export ROOT_KEY=`tvm_linker test $ROOT_ADDRESS \
--abi-json RootTokenContract.abi \
--abi-method getRootKey \
--abi-params '{}' \
--decode-c6 | grep "value0"`

export TOTAL_SUPPLY=`tvm_linker test $ROOT_ADDRESS \
--abi-json RootTokenContract.abi \
--abi-method getTotalSupply \
--abi-params '{}' \
--decode-c6 | grep "value0"`

export TOTAL_GRANTED=`tvm_linker test $ROOT_ADDRESS \
--abi-json RootTokenContract.abi \
--abi-method getTotalGranted \
--abi-params '{}' \
--decode-c6 | grep "value0"`

export WALLET_CODE=`tvm_linker test $ROOT_ADDRESS \
--abi-json RootTokenContract.abi \
--abi-method getWalletCode \
--abi-params '{}' \
--decode-c6 | grep "value0"`

echo "NAME=$NAME"
echo "SYMBOL=$SYMBOL"
echo "DECIMALS=$DECIMALS"
echo "ROOT_KEY=$ROOT_KEY"
echo "TOTAL_SUPPLY=$TOTAL_SUPPLY"
echo "TOTAL_GRANTED=$TOTAL_GRANTED"
echo "WALLET_CODE not shown"
