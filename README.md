## BURNINATOR

```
                                                 :::
                                             :: :::.
                       \/,                    .:::::
           \),          \`-._                 :::888
           /\            \   `-.             ::88888
          /  \            | .(                ::88
         /,.  \           ; ( `              .:8888
            ), \         / ;``               :::888
           /_   \     __/_(_                  :88
             `. ,`..-'      `-._    \  /      :8
               )__ `.           `._ .\/.
              /   `. `             `-._______m         _,
  ,-=====-.-;'                 ,  ___________/ _,-_,'"`/__,-.
 C   =--   ;                   `.`._    V V V       -=-'"#==-._
:,  \     ,|      UuUu _,......__   `-.__Ʌ_Ʌ_ -. ._ ,--._ ",`` `-
||  |`---' :    uUuUu,'          `'--...____/   `" `".   `
|`  :       \   UuUu:
:  /         \   UuUu`-._
 \(_          `._  uUuUu `-.
 (_3             `._  uUu   `._
                    ``-._      `.
                         `-._    `.
                             `.    \
                               )   ;
                              /   /
               `.        |\ ,'   /
                 ",_Ʌ_/\-| `   ,'
                   `--..,_|_,-'\
                          |     \
                          |      \__
                          |__
```

This smart contract allows a community to donate funds to make an offer on a specific ERC721 token. If the offer is accepted by the owner, the token is burned.

### How to Use

You'll need to use Etherscan directly for this one.

Click `Connect to Web3` first in order to take action on these functions.

**Donate ether to the _burnination_ of an ERC721 token:**

`donate(address tokenAddress, uint256 tokenId)`

1. Set payable field to how much ether you want to donate
2. Set `tokenAddress` to the contract address of the NFT collection
3. Set `tokenId` to the token of the NFT you hope to see burned
4. Click "Write"

**Withdraw your donation:**

If the offer hasn't been accepted, you can withdraw your donation.

`withdraw(address tokenAddress, uint256 tokenId)`

1. Set `tokenAddress` to the contract address of the NFT collection
2. Set `tokenId` to the token of the NFT
3. Click "Write"

**Accept an offer to _burninate_:**

Here are the steps to accept an outstanding offer & burn your NFT.

_Important:_ Before calling `burninate`, you must first approve the contract.

1. Go to the contract for the NFT collection you're going to burn
2. Call `approve` with your NFT (`tokenId`) and Burninator address (`to`)

`burninate(address tokenAddress, uint256 tokenId)`

1. Set `tokenAddress` to the contract address of the NFT collection
2. Set `tokenId` to the token of the NFT you're burning
3. Click "Write"
4. Rethink your life choices.
