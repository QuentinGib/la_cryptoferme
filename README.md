# Francistan
[0xF53920eaB4EC324Ff6d2dd826e351c530aA63cf6](https://rinkeby.etherscan.io/address/0xF53920eaB4EC324Ff6d2dd826e351c530aA63cf6)
Francistan est une ferme de coqs nft. Ces coqs ont 4 caractéristiques (la couleur des plumes, un poids, une taille et une agressivité).

# Utilisation
Il faut etre enregistré en temps qu'éleveur par l'admin avant de pouvoir créer son coq.

# Détail des fonctions
## Générales
### declareAnimal
Permet d'enregistrer un nouvel animal, et de minter son token. Il faut renseigner l'adresse de son propriétaire (préalablement enregistré en tant que breeder), et les caractéristiques de l'animal (plumes, poids, taille, agressivité) qui seront enregistrés dans le struct `Animal`.

### deadAnimal
Cette fonction permet de tuer un animal, et donc de détruire son token avec la fonction `_burn`.

## Fight
### proposeFight
Cette fonction permet à un breeder de proposer un animal pour un combat. Il doit quel animal peut combattre parmi ceux qu'il possède, et envoyer un certain nombre d'ether correspondant à sa mise. Le `struct Fight` correspond à l'id de l'animal, la mise en jeu sur son combat et un boolean pour indiquer s'il est disponible pour combattre ou non.

### agreeToFight
Avec cette fonction un breeder peut accepter un combat et envoyer l'animal de son choix. Il doit pour cela mettre la même mise que son adversaire. Le combat a ensuite lieu, et le vainqueur remporte la mise des deux participants. Le perdant perd également son animal (le paramètre alive du struct de l'animal passe à false : `animals[otherTokenId].alive =false`), dont le token est détruit avec la fonction `_burn`.

### animalFighting
C'est une fonction internal qui détermine le vainqueur d'un combat. Les agressivités des adversaires sont additionnées et un nombre aléatoire est généré dans cet intervalle. Par exemple, supposons que le coq 1 a une agressivité de 3, et le coq 2 de 7. Si le nombre aléatoire est compris entre 1 et 3, le coq 1 gagne. Si il est entre 4 et 10, le coq 2 gagne.

### createAuction
Cette fonction permet à un breeder de mettre aux enchères un de ses animaux et fixe le prix initial. Une enchère sera créée en utilisant le struct `Auction` qui 4 propriétés (le prix, la date de fin de l'enchère, si l'enchère est active et l'adresse du dernier enchérisseur).

### bidOnAuction
Cette fonction permet aux breeders d'enchérir. Elle mettra à jour la propriété `auctions[tokenId].breeder` et la propriété `auctions[tokenId].price`.

### acceptAuction
Le breeder qui a mis son animal aux enchères accepte la vente de son animal et approuve le transfer de son token au breeder qui a enchéri le plus. Cette fonction n'est utilisable qu'après la période de 2 jours et indiquera l'enchère comme inactive.

### claimAuction
Après avoir accepté l'enchère le breeder qui a vendu son animal peut effectuer le transfert de son token contre de l'eth.
