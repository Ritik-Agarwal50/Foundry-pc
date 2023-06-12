1. "EvmError: OutOfFund" 
--> This Error came aat the time making fake user using `makeAddr()` and `vm.prank()` cheatcode, This error states that the new user which is made it does not have enough fund to send transaction.
--> Solution : Use `vm.deal(USER,20e18)` this function to send some fake eth to the new user accounts.