FROM_ADDRESS=$1
TO_ADDRESS=$2
AMOUNT=$3
KEY=$4

if [ ! -f ./inited ]; then
    echo "Not inited"
    exit 1
fi

. ./envs.sh

TOKENS=$AMOUNT
MSG_BALANCE=100000000

echo "Transfer $TOKENS tokens from $FROM_ADDRESS to $TO_ADDRESS"

MSG=`tvm_linker test $FROM_ADDRESS \
--abi-json TONTokenWallet.abi \
--abi-method transfer \
--abi-params '{"dest":"0:'$TO_ADDRESS'","tokens":"'$TOKENS'","grams":"'$MSG_BALANCE'"}' \
--sign $KEY \
--decode-c6 | grep "body_hex:" | sed -e 's/body_hex: //g' | tr -d '\n'`

echo "Message is $MSG"

tvm_linker test $TO_ADDRESS \
--src "0:$FROM_ADDRESS" \
--internal $MSG_BALANCE \
--body $MSG \
--decode-c6

echo "Transfer done"
