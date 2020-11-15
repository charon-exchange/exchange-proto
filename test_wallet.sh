
if [ ! -f ./inited ]; then
    echo "Not inited"
    exit 1
fi

. ./envs.sh

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
