NAME1=Test1
SYMBOL1=TST1
DECIMALS1=6
SUPPLY1=1000000000000

NAME2=Test2
SYMBOL2=TST2
DECIMALS2=9
SUPPLY2=1000000000000000

NAME3=PoolLiqToken
SYMBOL3=LT
DECIMALS3=18
SUPPLY3=0

LIST_NAME="Charon"
LIST_DESCRIPTION="Charon Default List"
LIST_LOGO="http://"

export NAME1_HEX=`echo -n "$NAME1" | xxd -p`
export SYMBOL1_HEX=`echo -n "$SYMBOL1" | xxd -p`

export NAME2_HEX=`echo -n "$NAME2" | xxd -p`
export SYMBOL2_HEX=`echo -n "$SYMBOL2" | xxd -p`

export NAME3_HEX=`echo -n "$NAME3" | xxd -p`
export SYMBOL3_HEX=`echo -n "$SYMBOL3" | xxd -p`

export ROOT1_ADDRESS=`cat RootTokenContract1.address`
export ROOT2_ADDRESS=`cat RootTokenContract2.address`
export ROOT3_ADDRESS=`cat RootTokenContract3.address`

export TVM_WALLET_CODE=`cat TONTokenWallet.code`

export PAIR_ADDRESS=`cat CharonPair.address`
export PAIR_LIST_ADDRESS=`cat CharonPairList.address`

export ROOT1_PK=`cat root1_key.pub | xxd -l 32 -p -c 32`
export ROOT2_PK=`cat root2_key.pub | xxd -l 32 -p -c 32`
export ROOT3_PK=`cat root3_key.pub | xxd -l 32 -p -c 32`

export LIST_NAME_HEX=`echo -n "$LIST_NAME" | xxd -p`
export LIST_DESCRIPTION_HEX=`echo -n "$LIST_DESCRIPTION" | xxd -p`
export LIST_LOGO_HEX=`echo -n "$LIST_LOGO" | xxd -p`

export USER1_ADDRESS=`cat TONTokenWalletUser1.address`
export USER1_ADDRESS_TOKEN1=`cat TONTokenWalletUser1_1.address`
export USER1_ADDRESS_TOKEN2=`cat TONTokenWalletUser1_2.address`
export USER1_ADDRESS_TOKEN3=`cat TONTokenWalletUser1_3.address`
export USER1_PK=`cat user1_key.pub | xxd -l 32 -p -c 32`

export USER2_ADDRESS=`cat TONTokenWalletUser2.address`
export USER2_ADDRESS_TOKEN1=`cat TONTokenWalletUser2_1.address`
export USER2_ADDRESS_TOKEN2=`cat TONTokenWalletUser2_2.address`
export USER2_ADDRESS_TOKEN3=`cat TONTokenWalletUser2_3.address`
export USER2_PK=`cat user2_key.pub | xxd -l 32 -p -c 32`

export USER3_ADDRESS=`cat TONTokenWalletUser3.address`
export USER3_ADDRESS_TOKEN1=`cat TONTokenWalletUser3_1.address`
export USER3_ADDRESS_TOKEN2=`cat TONTokenWalletUser3_2.address`
export USER3_ADDRESS_TOKEN3=`cat TONTokenWalletUser3_3.address`
export USER3_PK=`cat user3_key.pub | xxd -l 32 -p -c 32`


function runTest {
    echo
    MSG=`tvm_linker test $2 \
    --abi-json $3 \
    --abi-method $4 \
    --abi-params $5 \
    --src "0:$6" \
    --internal $7 \
    --decode-c6`
    CODE=`echo "$MSG" | grep "TVM terminated"`
    GAS=`echo "$MSG" | grep "Gas used:"`
    if [[ "$CODE" == "TVM terminated with exit code 0" ]]; then
        echo -e "$1 OK:\n$CODE\n$GAS\n"
    else
        echo -e "$1 NOK:\n$MSG\n"
    fi
}

function run_expect_code {
    echo
    MSG=`tvm_linker test $2 \
    --abi-json $3 \
    --abi-method $4 \
    --abi-params $5 \
    --src "0:$6" \
    --internal $7 \
    --decode-c6`
    CODE=`echo "$MSG" | grep "TVM terminated"`
    GAS=`echo "$MSG" | grep "Gas used:"`
    if [[ "$CODE" == "TVM terminated with exit code $8" ]]; then
        echo -e "$1 OK:\n$CODE\n$GAS\n"
    else
        echo -e "$1 NOK:\n$MSG\n"
        echo "TEST FAILED"
        exit 1
    fi
}
