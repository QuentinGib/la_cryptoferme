# Francistan
0xF53920eaB4EC324Ff6d2dd826e351c530aA63cf6
Francistan est une ferme de coqs nft. Ces coqs ont 4 caractéristiques (la couleur des plumes, un poids, une taille et une aggressivité).

# Utilisation
Il faut etre enregistré en temps qu'éleveur par l'admin avant de pouvoir créer son coq.

# Détail des fonctions
## Générales
### declareAnimal
Permet d'enregistrer un nouvel animal, et de minter son token. Il faut renseigner l'adresse de son propriétaire (préalablement enregistré en tant que breeder), et les caractéristiques de l'animal (plumes, poids, taille, agresivité) qui seront enregistrés dans le struct `Animal`.

### deadAnimal
Cette fonction permet de declarer un animal mort, et donc de détruire son token avec la fonction `_burn`.

## Fight
### proposeFight
Cette fonction permet à un breeder de proposer un animal pour un combat. Il doit quel animal peut combattre parmi ceux qu'il possède, et envoyer un certain nombre d'ether correspondant à sa mise. Le `struct Fight` correspond à l'id de l'animal, la mise en jeu sur son combat et un boolean pour indiquer s'il est disponible pour combattre ou non.

### agreeToFight
Avec cette fonction un breeder peut accepter un combat et envoyer l'animal de son choix. Il doit pour cela mettre la même mise que son adversaire. Le combat a ensuite lieu, et le vainqueur remporte la mise des deux participants. Le perdant perd également son animal (le paramètre alive du struct de l'animal passe à false : `animals[otherTokenId].alive =false`), dont le token est détruit avec la fonction `_burn`.

### animalFighting
C'est une fonction internal qui détermine le vainqueur d'un combat. Les agressivités des adversaires sont additionnées et un nombre aléatoire est généré dans cet intervalle. Par exemple, supposons que le coq 1 a une agressivité de 3, et le coq 2 de 7. Si le nombre aléatoire est compris entre 1 et 3, le coq 1 gagne. Si il est entre 4 et 10, le coq 2 gagne.

