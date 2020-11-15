if [ ! -f ./inited ]; then
    echo "Not inited"
    exit 1
fi

. ./envs.sh

./test_grant.sh $ROOT1_ADDRESS $USER1_ADDRESS_TOKEN1 10 root1_key
./test_grant.sh $ROOT2_ADDRESS $USER1_ADDRESS_TOKEN2 10 root2_key

./test_transfer.sh $USER1_ADDRESS_TOKEN1 $USER2_ADDRESS_TOKEN1 5 user1_key
./test_transfer.sh $USER1_ADDRESS_TOKEN2 $USER2_ADDRESS_TOKEN2 5 user1_key

echo "User 1:"
./test_wallet_getters.sh $USER1_ADDRESS_TOKEN1
./test_wallet_getters.sh $USER1_ADDRESS_TOKEN2
./test_wallet_getters.sh $USER1_ADDRESS_TOKEN3

echo "User 2:"
./test_wallet_getters.sh $USER2_ADDRESS_TOKEN1
./test_wallet_getters.sh $USER2_ADDRESS_TOKEN2
./test_wallet_getters.sh $USER2_ADDRESS_TOKEN3

echo "Pair:"
./test_wallet_getters.sh $USER3_ADDRESS_TOKEN1
./test_wallet_getters.sh $USER3_ADDRESS_TOKEN2
