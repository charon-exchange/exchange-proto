PUBKEY=$1
VALUE=$2
DIR=$3

if [ ! -f ./inited ]; then
    echo "Not inited"
    exit 1
fi

. ./envs.sh

if [ -z "$PUBKEY" ]
then

export RESERVES=`tvm_linker test $PAIR_ADDRESS \
--abi-json CharonPair.abi.json \
--abi-method getReserves \
--abi-params '{}' \
--decode-c6 | grep "token1Reserve"`

export FEES=`tvm_linker test $PAIR_ADDRESS \
--abi-json CharonPair.abi.json \
--abi-method getDeveloperBalance \
--abi-params '{}' \
--decode-c6 | grep "token1"`

echo "PAIR state:"
echo "  RESERVES=$RESERVES"
echo "  FEES=$FEES"

else

if [ ! -z "$VALUE" ]
then

export EXCHANGE=`tvm_linker test $PAIR_ADDRESS \
--abi-json CharonPair.abi.json \
--abi-method getExchangeRate \
--abi-params '{"valueToSwap":"'$VALUE'","direction":"'$DIR'"}' \
--decode-c6 | grep "dstValue"`

echo "EXCHANGE from $VALUE tokens:"
echo "  RATE=$EXCHANGE"

else

export BALANCE=`tvm_linker test $PAIR_ADDRESS \
--abi-json CharonPair.abi.json \
--abi-method getBalance \
--abi-params '{"pubkey":"0x'$PUBKEY'"}' \
--decode-c6 | grep "token1Balance"`

echo "Pubkey $PUBKEY info:"
echo "  BALANCE=$BALANCE"

fi

fi

