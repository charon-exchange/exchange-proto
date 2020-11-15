if [ ! -f ./inited ]; then
    echo "Not inited"
    exit 1
fi

. ./envs.sh

TOKENS1=1000000
TOKENS2=10000000
MSG_BALANCE=100000000

echo
echo "State before exchange:"
echo
./test_deposit_check.sh
./test_deposit_check.sh $USER1_PK
./test_deposit_check.sh $USER2_PK

run_expect_code "Deposit 1MM $SYMBOL1 by user1" $PAIR_ADDRESS CharonPair.abi.json transferNotifyWithData '{"tokens":"1000000","pubkey":"0x'$USER1_PK'","workchain_id":"0","data":""}' $USER3_ADDRESS_TOKEN1 $MSG_BALANCE 0
run_expect_code "Deposit 10MM $SYMBOL2 by user1 and mint" $PAIR_ADDRESS CharonPair.abi.json transferNotifyWithData '{"tokens":"10000000","pubkey":"0x'$USER1_PK'","workchain_id":"0","data":"02"}' $USER3_ADDRESS_TOKEN2 $MSG_BALANCE 0

echo
echo "State after deposit and mint:"
echo
./test_deposit_check.sh
./test_deposit_check.sh $USER1_PK
./test_deposit_check.sh $USER2_PK

echo
echo "Get exchange rate:"
echo
./test_deposit_check.sh 0 1000 0x00

run_expect_code "Deposit 1000 $SYMBOL1 by user2 and exchange" $PAIR_ADDRESS CharonPair.abi.json transferNotifyWithData '{"tokens":"1000","pubkey":"0x'$USER2_PK'","workchain_id":"0","data":"0100000000000000000000000000000001"}' $USER3_ADDRESS_TOKEN1 $MSG_BALANCE 0

echo
echo "State after exchange 1->2:"
echo
./test_deposit_check.sh
./test_deposit_check.sh $USER1_PK
./test_deposit_check.sh $USER2_PK

echo
echo "Get exchange rate:"
echo
./test_deposit_check.sh 0 9960 0x10

run_expect_code "Exchange back" $PAIR_ADDRESS CharonPair.abi.json transferNotifyWithData '{"tokens":"0","pubkey":"0x'$USER2_PK'","workchain_id":"0","data":"1100000000000000000000000000000001"}' $USER3_ADDRESS_TOKEN1 $MSG_BALANCE 0

echo
echo "State after exchange 2->1:"
echo
./test_deposit_check.sh
./test_deposit_check.sh $USER1_PK
./test_deposit_check.sh $USER2_PK

run_expect_code "Burn ALL by user1" $PAIR_ADDRESS CharonPair.abi.json transferNotifyWithData '{"tokens":"0","pubkey":"0x'$USER1_PK'","workchain_id":"0","data":"03"}' $USER3_ADDRESS_TOKEN1 $MSG_BALANCE 0

echo
echo "State after burn:"
echo
./test_deposit_check.sh
./test_deposit_check.sh $USER1_PK
./test_deposit_check.sh $USER2_PK


exit 0