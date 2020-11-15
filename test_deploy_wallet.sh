
if [ -f ./inited ]; then
    echo "Already inited"
    exit 1
fi

. ./envs.sh

#tonos-cli call 0:45ae69c26bf9d915e5401ffafaea0888cfbac1e07209efa62beb7c4028267e0a deployWallet '{"workchain_id":0, "pubkey":"0x9e8ab670fca3aa0048bbb545bd03828b893902813c32d7910fad8eeca846571d","tokens":"0","grams":"1000000000"}' --sign "volume payment moral height language crawl country piano congress cash robot damp" --abi RootTokenContract.abi
ADDR=`tvm_linker test $ROOT1_ADDRESS \
--abi-json RootTokenContract.abi \
--abi-method getWalletAddress \
--abi-params '{"workchain_id":0,"pubkey":"0x'$USER1_PK'"}' \
--decode-c6 | grep "value0" | sed -e 's/{\"value0\":\"0://g' | sed -e 's/\"}//g' | tr -d '\n'`

cp $USER1_ADDRESS.tvc $ADDR.tvc
echo $ADDR > TONTokenWalletUser1_1.address

ADDR=`tvm_linker test $ROOT2_ADDRESS \
--abi-json RootTokenContract.abi \
--abi-method getWalletAddress \
--abi-params '{"workchain_id":0,"pubkey":"0x'$USER1_PK'"}' \
--decode-c6 | grep "value0" | sed -e 's/{\"value0\":\"0://g' | sed -e 's/\"}//g' | tr -d '\n'`

cp $USER1_ADDRESS.tvc $ADDR.tvc
echo $ADDR > TONTokenWalletUser1_2.address

ADDR=`tvm_linker test $ROOT3_ADDRESS \
--abi-json RootTokenContract.abi \
--abi-method getWalletAddress \
--abi-params '{"workchain_id":0,"pubkey":"0x'$USER1_PK'"}' \
--decode-c6 | grep "value0" | sed -e 's/{\"value0\":\"0://g' | sed -e 's/\"}//g' | tr -d '\n'`

cp $USER1_ADDRESS.tvc $ADDR.tvc
echo $ADDR > TONTokenWalletUser1_3.address

ADDR=`tvm_linker test $ROOT1_ADDRESS \
--abi-json RootTokenContract.abi \
--abi-method getWalletAddress \
--abi-params '{"workchain_id":0,"pubkey":"0x'$USER2_PK'"}' \
--decode-c6 | grep "value0" | sed -e 's/{\"value0\":\"0://g' | sed -e 's/\"}//g' | tr -d '\n'`

cp $USER2_ADDRESS.tvc $ADDR.tvc
echo $ADDR > TONTokenWalletUser2_1.address

ADDR=`tvm_linker test $ROOT2_ADDRESS \
--abi-json RootTokenContract.abi \
--abi-method getWalletAddress \
--abi-params '{"workchain_id":0,"pubkey":"0x'$USER2_PK'"}' \
--decode-c6 | grep "value0" | sed -e 's/{\"value0\":\"0://g' | sed -e 's/\"}//g' | tr -d '\n'`

cp $USER2_ADDRESS.tvc $ADDR.tvc
echo $ADDR > TONTokenWalletUser2_2.address

ADDR=`tvm_linker test $ROOT3_ADDRESS \
--abi-json RootTokenContract.abi \
--abi-method getWalletAddress \
--abi-params '{"workchain_id":0,"pubkey":"0x'$USER2_PK'"}' \
--decode-c6 | grep "value0" | sed -e 's/{\"value0\":\"0://g' | sed -e 's/\"}//g' | tr -d '\n'`

cp $USER2_ADDRESS.tvc $ADDR.tvc
echo $ADDR > TONTokenWalletUser2_3.address


ADDR=`tvm_linker test $ROOT1_ADDRESS \
--abi-json RootTokenContract.abi \
--abi-method getWalletAddress \
--abi-params '{"workchain_id":0,"pubkey":"0x'$PAIR_ADDRESS'"}' \
--decode-c6 | grep "value0" | sed -e 's/{\"value0\":\"0://g' | sed -e 's/\"}//g' | tr -d '\n'`

cp $USER3_ADDRESS.tvc $ADDR.tvc
echo $ADDR > TONTokenWalletUser3_1.address

ADDR=`tvm_linker test $ROOT2_ADDRESS \
--abi-json RootTokenContract.abi \
--abi-method getWalletAddress \
--abi-params '{"workchain_id":0,"pubkey":"0x'$PAIR_ADDRESS'"}' \
--decode-c6 | grep "value0" | sed -e 's/{\"value0\":\"0://g' | sed -e 's/\"}//g' | tr -d '\n'`

cp $USER3_ADDRESS.tvc $ADDR.tvc
echo $ADDR > TONTokenWalletUser3_2.address

ADDR=`tvm_linker test $ROOT3_ADDRESS \
--abi-json RootTokenContract.abi \
--abi-method getWalletAddress \
--abi-params '{"workchain_id":0,"pubkey":"0x'$PAIR_ADDRESS'"}' \
--decode-c6 | grep "value0" | sed -e 's/{\"value0\":\"0://g' | sed -e 's/\"}//g' | tr -d '\n'`

cp $USER3_ADDRESS.tvc $ADDR.tvc
echo $ADDR > TONTokenWalletUser3_3.address

. ./envs.sh

# USER 1

echo "Call constructor in $USER1_ADDRESS_TOKEN1"
tvm_linker test $USER1_ADDRESS_TOKEN1 \
--abi-json TONTokenWallet.abi \
--abi-method constructor \
--abi-params '{"name":"'$NAME1_HEX'","symbol":"'$SYMBOL1_HEX'", "decimals":"'$DECIMALS1'","root_public_key":"0x'$ROOT1_PK'","wallet_public_key":"0x'$USER1_PK'","root_address":"0:'$ROOT1_ADDRESS'","code":"'$TVM_WALLET_CODE'"}' \
--sign user1_key

echo "Call constructor in $USER1_ADDRESS_TOKEN2"
tvm_linker test $USER1_ADDRESS_TOKEN2 \
--abi-json TONTokenWallet.abi \
--abi-method constructor \
--abi-params '{"name":"'$NAME2_HEX'","symbol":"'$SYMBOL2_HEX'", "decimals":"'$DECIMALS2'","root_public_key":"0x'$ROOT2_PK'","wallet_public_key":"0x'$USER1_PK'","root_address":"0:'$ROOT2_ADDRESS'","code":"'$TVM_WALLET_CODE'"}' \
--sign user1_key

echo "Call constructor in $USER1_ADDRESS_TOKEN3"
tvm_linker test $USER1_ADDRESS_TOKEN3 \
--abi-json TONTokenWallet.abi \
--abi-method constructor \
--abi-params '{"name":"'$NAME3_HEX'","symbol":"'$SYMBOL3_HEX'", "decimals":"'$DECIMALS3'","root_public_key":"0x'$ROOT3_PK'","wallet_public_key":"0x'$USER1_PK'","root_address":"0:'$ROOT3_ADDRESS'","code":"'$TVM_WALLET_CODE'"}' \
--sign user1_key

# USER 2

echo "Call constructor in $USER2_ADDRESS_TOKEN1"
tvm_linker test $USER2_ADDRESS_TOKEN1 \
--abi-json TONTokenWallet.abi \
--abi-method constructor \
--abi-params '{"name":"'$NAME1_HEX'","symbol":"'$SYMBOL1_HEX'", "decimals":"'$DECIMALS1'","root_public_key":"0x'$ROOT1_PK'","wallet_public_key":"0x'$USER2_PK'","root_address":"0:'$ROOT1_ADDRESS'","code":"'$TVM_WALLET_CODE'"}' \
--sign user2_key

echo "Call constructor in $USER2_ADDRESS_TOKEN2"
tvm_linker test $USER2_ADDRESS_TOKEN2 \
--abi-json TONTokenWallet.abi \
--abi-method constructor \
--abi-params '{"name":"'$NAME2_HEX'","symbol":"'$SYMBOL2_HEX'", "decimals":"'$DECIMALS2'","root_public_key":"0x'$ROOT2_PK'","wallet_public_key":"0x'$USER2_PK'","root_address":"0:'$ROOT2_ADDRESS'","code":"'$TVM_WALLET_CODE'"}' \
--sign user2_key

echo "Call constructor in $USER2_ADDRESS_TOKEN3"
tvm_linker test $USER2_ADDRESS_TOKEN3 \
--abi-json TONTokenWallet.abi \
--abi-method constructor \
--abi-params '{"name":"'$NAME3_HEX'","symbol":"'$SYMBOL3_HEX'", "decimals":"'$DECIMALS3'","root_public_key":"0x'$ROOT3_PK'","wallet_public_key":"0x'$USER2_PK'","root_address":"0:'$ROOT3_ADDRESS'","code":"'$TVM_WALLET_CODE'"}' \
--sign user2_key

# USER 3 (PAIR CONTRACT)

echo "Call constructor in $USER3_ADDRESS_TOKEN1"
tvm_linker test $USER3_ADDRESS_TOKEN1 \
--abi-json TONTokenWallet.abi \
--abi-method constructor \
--abi-params '{"name":"'$NAME1_HEX'","symbol":"'$SYMBOL1_HEX'", "decimals":"'$DECIMALS1'","root_public_key":"0x'$ROOT1_PK'","wallet_public_key":"0x'$PAIR_ADDRESS'","root_address":"0:'$ROOT1_ADDRESS'","code":"'$TVM_WALLET_CODE'"}' \
--sign user3_key

echo "Call constructor in $USER3_ADDRESS_TOKEN2"
tvm_linker test $USER3_ADDRESS_TOKEN2 \
--abi-json TONTokenWallet.abi \
--abi-method constructor \
--abi-params '{"name":"'$NAME2_HEX'","symbol":"'$SYMBOL2_HEX'", "decimals":"'$DECIMALS2'","root_public_key":"0x'$ROOT2_PK'","wallet_public_key":"0x'$PAIR_ADDRESS'","root_address":"0:'$ROOT2_ADDRESS'","code":"'$TVM_WALLET_CODE'"}' \
--sign user3_key

echo "Call constructor in $USER3_ADDRESS_TOKEN3"
tvm_linker test $USER3_ADDRESS_TOKEN3 \
--abi-json TONTokenWallet.abi \
--abi-method constructor \
--abi-params '{"name":"'$NAME3_HEX'","symbol":"'$SYMBOL3_HEX'", "decimals":"'$DECIMALS3'","root_public_key":"0x'$ROOT3_PK'","wallet_public_key":"0x'$PAIR_ADDRESS'","root_address":"0:'$ROOT3_ADDRESS'","code":"'$TVM_WALLET_CODE'"}' \
--sign user3_key

