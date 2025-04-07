.PHONY: test

anvil:
	anvil --code-size-limit 65000

deploy:
	forge script scripts/DeployDevelopment.s.sol --broadcast --fork-url $$ETH_RPC_URL --private-key $$PRIVATE_KEY --code-size-limit 60000 --verbosity 5

update-abis:
	cp out/UniswapV3Factory.sol/UniswapV3Factory.json ui/src/abi/Factory.json
	cp out/UniswapV3Manager.sol/UniswapV3Manager.json ui/src/abi/Manager.json
	cp out/UniswapV3Pool.sol/UniswapV3Pool.json ui/src/abi/Pool.json
	cp out/UniswapV3Quoter.sol/UniswapV3Quoter.json ui/src/abi/Quoter.json
test:
	forge test --ffi