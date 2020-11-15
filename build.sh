#clang++ RootTokenContract.cpp -o RootTokenContract.tvc --linkerflags='"--genkey root_key"'

echo "Building CharonPair..."
solc CharonPair.sol

rm -f *.tvc
tvm_linker compile CharonPair.code -w 0 --abi-json CharonPair.abi.json --genkey pair_key

PAIR_ADDRESS=`ls *.tvc | cut -f 1 -d '.'`
echo $PAIR_ADDRESS > CharonPair.address
mv $PAIR_ADDRESS.tvc CharonPair._tvc

echo "Building CharonPairList..."
solc CharonPairList.sol

rm -f *.tvc
tvm_linker compile CharonPairList.code -w 0 --abi-json CharonPairList.abi.json --genkey pair_list_key

PAIR_LIST_ADDRESS=`ls *.tvc | cut -f 1 -d '.'`
echo $PAIR_LIST_ADDRESS > CharonPairList.address
mv $PAIR_LIST_ADDRESS.tvc CharonPairList._tvc

echo "Building RootTokenContract..."
clang++ -target tvm -export-json-abi -o RootTokenContract.abi RootTokenContract.cpp

rm -f *.tvc
tvm-build++.py --abi RootTokenContract.abi RootTokenContract.cpp --linkerflags="--genkey root1_key"

ROOT1_ADDRESS=`ls *.tvc | cut -f 1 -d '.'`
echo $ROOT1_ADDRESS > RootTokenContract1.address
mv $ROOT1_ADDRESS.tvc RootTokenContract1._tvc

rm -f *.tvc
tvm-build++.py --abi RootTokenContract.abi RootTokenContract.cpp --linkerflags="--genkey root2_key"

ROOT2_ADDRESS=`ls *.tvc | cut -f 1 -d '.'`
echo $ROOT2_ADDRESS > RootTokenContract2.address
mv $ROOT2_ADDRESS.tvc RootTokenContract2._tvc

rm -f *.tvc
tvm-build++.py --abi RootTokenContract.abi RootTokenContract.cpp --linkerflags="--genkey root3_key"

ROOT3_ADDRESS=`ls *.tvc | cut -f 1 -d '.'`
echo $ROOT3_ADDRESS > RootTokenContract3.address
mv $ROOT3_ADDRESS.tvc RootTokenContract3._tvc

#
echo "Building TONTokenWallet..."

clang++ TONTokenWallet.cpp -o TONTokenWallet.tvc
tvm_linker decode --tvc TONTokenWallet.tvc | grep "code:" | head -1 | sed -e 's/ code: //g' | tr -d '\n' > TONTokenWallet.code

rm -f *.tvc
tvm-build++.py --abi TONTokenWallet.abi TONTokenWallet.cpp --linkerflags="--genkey user1_key"

export USER1_ADDRESS=`ls *.tvc | cut -f 1 -d '.'`
echo $USER1_ADDRESS > TONTokenWalletUser1.address
mv $USER1_ADDRESS.tvc TONTokenWalletUser1._tvc

rm -f *.tvc
tvm-build++.py --abi TONTokenWallet.abi TONTokenWallet.cpp --linkerflags="--genkey user2_key"

export USER2_ADDRESS=`ls *.tvc | cut -f 1 -d '.'`
echo $USER2_ADDRESS > TONTokenWalletUser2.address
mv $USER2_ADDRESS.tvc TONTokenWalletUser2._tvc

rm -f *.tvc
tvm-build++.py --abi TONTokenWallet.abi TONTokenWallet.cpp --linkerflags="--genkey user3_key"

export USER3_ADDRESS=`ls *.tvc | cut -f 1 -d '.'`
echo $USER3_ADDRESS > TONTokenWalletUser3.address
mv $USER3_ADDRESS.tvc TONTokenWalletUser3._tvc


mv CharonPair._tvc $PAIR_ADDRESS.tvc
mv CharonPairList._tvc $PAIR_LIST_ADDRESS.tvc

mv RootTokenContract1._tvc $ROOT1_ADDRESS.tvc
mv RootTokenContract2._tvc $ROOT2_ADDRESS.tvc
mv RootTokenContract3._tvc $ROOT3_ADDRESS.tvc

mv TONTokenWalletUser1._tvc $USER1_ADDRESS.tvc
mv TONTokenWalletUser2._tvc $USER2_ADDRESS.tvc
mv TONTokenWalletUser3._tvc $USER3_ADDRESS.tvc

rm -f ./inited
