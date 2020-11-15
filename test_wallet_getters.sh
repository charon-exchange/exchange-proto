ADDRESS=$1

if [ ! -f ./inited ]; then
    echo "Not inited"
    exit 1
fi

. ./envs.sh

export NAME=`tvm_linker test $ADDRESS \
--abi-json TONTokenWallet.abi \
--abi-method getName \
--abi-params '{}' \
--decode-c6 | grep "value0"`

export SYMBOL=`tvm_linker test $ADDRESS \
--abi-json TONTokenWallet.abi \
--abi-method getSymbol \
--abi-params '{}' \
--decode-c6 | grep "value0"`

export DECIMALS=`tvm_linker test $ADDRESS \
--abi-json TONTokenWallet.abi \
--abi-method getDecimals \
--abi-params '{}' \
--decode-c6 | grep "value0"`

export WALLET_KEY=`tvm_linker test $ADDRESS \
--abi-json TONTokenWallet.abi \
--abi-method getWalletKey \
--abi-params '{}' \
--decode-c6 | grep "value0"`

export BALANCE=`tvm_linker test $ADDRESS \
--abi-json TONTokenWallet.abi \
--abi-method getBalance \
--abi-params '{}' \
--decode-c6 | grep "value0"`

export ROOT_ADDRESS=`tvm_linker test $ADDRESS \
--abi-json TONTokenWallet.abi \
--abi-method getRootAddress \
--abi-params '{}' \
--decode-c6 | grep "value0"`

export NOTIFY_ADDRESS=`tvm_linker test $ADDRESS \
--abi-json TONTokenWallet.abi \
--abi-method getNotifyAddress \
--abi-params '{}' \
--decode-c6 | grep "value0"`

export ALLOWANCE=`tvm_linker test $ADDRESS \
--abi-json TONTokenWallet.abi \
--abi-method allowance \
--abi-params '{}' \
--decode-c6 | grep "remainingTokens"`

echo "Wallet $ADDRESS info:"
echo "  NAME=$NAME"
echo "  SYMBOL=$SYMBOL"
echo "  DECIMALS=$DECIMALS"
echo "  WALLET_KEY=$WALLET_KEY"
echo "  BALANCE=$BALANCE"
echo "  ROOT_ADDRESS=$ROOT_ADDRESS"
echo "  NOTIFY_ADDRESS=$NOTIFY_ADDRESS"
echo "  ALLOWANCE=$ALLOWANCE"
