
if [ -f ./inited ]; then
    echo "Already inited"
    exit 1
fi

. ./envs.sh


echo "Call constructor in CharonPair $PAIR_ADDRESS"
MSGS=`tvm_linker test $PAIR_ADDRESS \
--abi-json CharonPair.abi.json \
--abi-method constructor \
--abi-params '{"token1":"0:'$USER3_ADDRESS_TOKEN1'","token2":"0:'$USER3_ADDRESS_TOKEN2'","tokenLiqRoot":"0:'$ROOT3_ADDRESS'","developerAddress":"0:0000000000000000000000000000000000000000000000000000000000000000","governanceAddress":"0:0000000000000000000000000000000000000000000000000000000000000000"}' \
--sign pair_key \
--decode-c6 | grep "body_hex:" | sed -e 's/body_hex: //g'`

MSG=`echo $MSGS | cut -d " " -f 1`
echo "Message is $MSG to $USER3_ADDRESS_TOKEN1"
tvm_linker test $USER3_ADDRESS_TOKEN1 \
--src "0:$PAIR_ADDRESS" \
--internal 100000000 \
--body $MSG \
--decode-c6

MSG=`echo $MSGS | cut -d " " -f 2`
echo "Message is $MSG to $USER3_ADDRESS_TOKEN2"
tvm_linker test $USER3_ADDRESS_TOKEN2 \
--src "0:$PAIR_ADDRESS" \
--internal 100000000 \
--body $MSG \
--decode-c6

MSG=`echo $MSGS | cut -d " " -f 3`
echo "Message is $MSG to $ROOT3_ADDRESS"
tvm_linker test $ROOT3_ADDRESS \
--src "0:$PAIR_ADDRESS" \
--internal 100000000 \
--body $MSG \
--decode-c6

echo "Call constructor in ChairPairList $PAIR_LIST_ADDRESS"
tvm_linker test $PAIR_LIST_ADDRESS \
--abi-json CharonPairList.abi.json \
--abi-method constructor \
--abi-params '{"name":"'$LIST_NAME_HEX'","description":"'$LIST_DESCRIPTION_HEX'","logoURI":"'$LIST_LOGO_HEX'","ownerEnabled":true,"governanceAddress":"0:1234000000000000000000000000000000000000000000000000000000000000"}' \
--sign pair_list_key \
--decode-c6

echo > ./inited
