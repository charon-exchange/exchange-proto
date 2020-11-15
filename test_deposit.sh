
if [ ! -f ./inited ]; then
    echo "Not inited"
    exit 1
fi

. ./envs.sh

./test_deposit_one.sh $USER1_ADDRESS_TOKEN1 $USER3_ADDRESS_TOKEN1 1 user1_key $USER1_PK ff
./test_deposit_check.sh $USER1_PK

#./test_deposit_one.sh $USER1_ADDRESS_TOKEN2 $USER3_ADDRESS_TOKEN2 5 user1_key
