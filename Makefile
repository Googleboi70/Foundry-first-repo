-include .env

build:; forge build

deploy-anvil:;forge script script/DeployFundMe.s.sol --fork-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
deploy-sepolia:;forge script script/DeployFundMe.s.sol --fork-url $(SEPOLIA_RPC_URL) --private-key $(SEPOLIA_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv