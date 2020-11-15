FROM_ADDRESS=$1
TO_ADDRESS=$2
AMOUNT=$3
KEY=$4
PUBKEY=$5
CMD=$6

if [ ! -f ./inited ]; then
    echo "Not inited"
    exit 1
fi

. ./envs.sh

TOKENS=$AMOUNT
MSG_BALANCE=100000000

echo "Deposit $TOKENS tokens from $FROM_ADDRESS to $TO_ADDRESS with data $CMD: "

echo "External message transferWithData to $FROM_ADDRESS"
tvm_linker test $FROM_ADDRESS \
--abi-json TONTokenWallet.abi \
--abi-method transferWithData \
--abi-params '{"dest":"0:'$TO_ADDRESS'","tokens":"'$TOKENS'","grams":"'$MSG_BALANCE'","data":"'$CMD'"}' \
--sign $KEY \
--decode-c6

echo "Internal message internalTransferWithData to $TO_ADDRESS"
tvm_linker test $TO_ADDRESS \
--abi-json TONTokenWallet.abi \
--abi-method internalTransferWithData \
--abi-params '{"tokens":"'$TOKENS'","pubkey":"0x'$PUBKEY'","data":"'$CMD'"}' \
--src "0:$FROM_ADDRESS" \
--internal $MSG_BALANCE \
--decode-c6

echo "Internal message transferNotifyWithData to $PAIR_ADDRESS"
tvm_linker test $PAIR_ADDRESS \
--abi-json CharonPair.abi.json \
--abi-method transferNotifyWithData \
--abi-params '{"tokens":"'$TOKENS'","pubkey":"0x'$PUBKEY'","workchain_id":"0","data":"'$CMD'"}' \
--src "0:$TO_ADDRESS" \
--internal $MSG_BALANCE \
--decode-c6

echo "Deposit done"
