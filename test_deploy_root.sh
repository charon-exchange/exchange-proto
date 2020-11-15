
if [ -f ./inited ]; then
    echo "Already inited"
    exit 1
fi

. ./envs.sh

tvm_linker test $ROOT1_ADDRESS \
--abi-json RootTokenContract.abi \
--abi-method constructor \
--abi-params '{"name":"'$NAME1_HEX'","symbol":"'$SYMBOL1_HEX'", "decimals":"'$DECIMALS1'","root_public_key":"0x'$ROOT1_PK'","wallet_code":"'$TVM_WALLET_CODE'","total_supply":"'$SUPPLY1'"}' \
--sign root1_key

tvm_linker test $ROOT2_ADDRESS \
--abi-json RootTokenContract.abi \
--abi-method constructor \
--abi-params '{"name":"'$NAME2_HEX'","symbol":"'$SYMBOL2_HEX'", "decimals":"'$DECIMALS2'","root_public_key":"0x'$ROOT2_PK'","wallet_code":"'$TVM_WALLET_CODE'","total_supply":"'$SUPPLY2'"}' \
--sign root2_key

tvm_linker test $ROOT3_ADDRESS \
--abi-json RootTokenContract.abi \
--abi-method constructor \
--abi-params '{"name":"'$NAME3_HEX'","symbol":"'$SYMBOL3_HEX'", "decimals":"'$DECIMALS3'","root_public_key":"0x'$PAIR_ADDRESS'","wallet_code":"'$TVM_WALLET_CODE'","total_supply":"'$SUPPLY3'"}' \
--sign root3_key
