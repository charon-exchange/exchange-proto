if [ ! -f ./inited ]; then
    echo "Not inited"
    exit 1
fi

. ./envs.sh

export DESCRIPTION=`tvm_linker test $PAIR_LIST_ADDRESS \
--abi-json CharonPairList.abi.json \
--abi-method getDescription \
--abi-params '{}' \
--decode-c6 | grep "governanceAddress"`

tvm_linker test $PAIR_LIST_ADDRESS \
--abi-json CharonPairList.abi.json \
--abi-method addTokenOwner \
--abi-params '{"tokenAddress":"0:'$ROOT1_ADDRESS'","symbol":"'$SYMBOL1_HEX'","name":"'$NAME1_HEX'","logoURI":""}' \
--sign pair_list_key \
--decode-c6

tvm_linker test $PAIR_LIST_ADDRESS \
--abi-json CharonPairList.abi.json \
--abi-method addTokenOwner \
--abi-params '{"tokenAddress":"0:'$ROOT2_ADDRESS'","symbol":"'$SYMBOL2_HEX'","name":"'$NAME2_HEX'","logoURI":""}' \
--sign pair_list_key \
--decode-c6

tvm_linker test $PAIR_LIST_ADDRESS \
    --abi-json CharonPairList.abi.json \
    --abi-method addPairGov \
    --abi-params '{"pairAddress":"0:'$PAIR_ADDRESS'","token1Address":"0:'$ROOT1_ADDRESS'","token2Address":"0:'$ROOT2_ADDRESS'","tokenLiqAddress":"0:'$ROOT3_ADDRESS'"}' \
    --src "0:1234000000000000000000000000000000000000000000000000000000000000" \
    --internal 100000000 \
    --decode-c6

export TOKEN_LIST=`tvm_linker test $PAIR_LIST_ADDRESS \
--abi-json CharonPairList.abi.json \
--abi-method getTokenList \
--abi-params '{}' \
--decode-c6 | grep "tokenAddress"`

export PAIR_LIST=`tvm_linker test $PAIR_LIST_ADDRESS \
--abi-json CharonPairList.abi.json \
--abi-method getPairList \
--abi-params '{}' \
--decode-c6 | grep "pairAddress"`

echo $DESCRIPTION
echo $TOKEN_LIST
echo $PAIR_LIST
