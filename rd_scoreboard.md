## La base de données EU R&D Investment Scoreboard

La base de données *EU R&D Investment Scoreboard* (*Scoreboard R&D* ou *Scoreboard* par la suite) couvre la population mondiale des entreprises du secteur privé réalisant des activités de R&D.[^1] La base est <ins>non-exhaustive</ins>. Une variable importante de la base est le montant de R&D financée, qui correspond aux dépenses comptabilisées en frais plus celles activées. Les autres variables sont notamment le nom de l'entreprise, le pays du siège, l'année d'observation, le secteur NACE (rév. 2),[^2] etc. 

### L'exhaustivité de la base augmente avec le périmètre géographique

Le *Scoreboard* n'est pas exhaustif pour plusieurs raisons :

- Ne sont incluses que les entreprises qui financent un certain montant de R&D (en 2023, les montants les plus faibles sont de quelques centaines de milliers d'&euro;). Le <ins>défaut de couverture</ins> des petites entreprises de R&D est élevé. En 2023, on ne trouve pas de dépenses inférieures à 5 millions d'&euro; pour les &Eacute;tats-Unis (2 millions dans le cas France, 35 dans le cas de la Chine, etc.). Il n'y a pas de montant minimum fixé *a priori*, mais une règle de sélection. Les entreprises sont sélectionnées à l'issue d'un trie des dépenses de R&D. Dans le cas des entreprises ayant leur siège dans l'UE, elles sont d'abord classées par ordre de niveau de R&D décroissant, puis ne sont retenues que les 1000 premières. C'est la même chose pour les entreprises non-européennes, mais ce sont les 1500 premières qui sont retenues. 

- De grandes entreprises peuvent être exclues. En effet, lorsque l'on a affaire à un groupe d'entreprises, le montant de R&D reporté est celui consolidé par la *tête de groupe* (la maison mère). Les filiales du groupe et leurs dépenses, quelle que soit la taille de ces filiales, ne sont pas incluses (sauf quand l'information du montant de R&D consolidé par la tête n'est pas disponible).

- Les montants de R&D ne portant que sur les activités réalisées pour soi ou externalisées, les sous-traitants sont exclus de la base.

Toutefois, si l'on se place au niveau d'agrégation mondial, le financement total devrait être proche de l'exécution totale. La R&D exécutée est disponible sur Eurostat, base *rd_e_gerdfund* (dans le cas de la France, il s'agit des dépenses issues de l'enquête R&D).[^3] Nous voyons deux raisons à cette proximité :

- La R&D financée (hors aides directes) est nécessairement exécutée quelque part. 

- Parmi les entreprises sélectionnées, on constate une concentration de la R&D dans les derniers déciles, notamment parce qu'ils incluent les têtes de groupes : en 2023, le top 10 % représente 69,7 % (785 milliards d'&euro;).

Pour l'année 2019, on 986,6 milliards d'&euro; dans Eurostat et 962,1 milliards d'&euro; courants dans le *Scoreboard*, soit un taux de couverture des dépenses de 97,5 %.

### Producteur de la base *Scoreboard*

En 2020, les montants de R&D proviennent des comptes et rapports annuels des entreprises,  collectés par Bureau van Dijk Electronic Publishing GmbH (BvD). Les dépenses de R&D capitalisées sont intégrées, nettes des amortissements.

### Variables du *Scoreboard*

Nom de la société, le pays du siège, l'année d'observation à laquelle se rapporte la dépense de R&D, le secteur NACE (rév. 2) de la société,[^2] la dépense de R&D, l'investissement corporel, le chiffre d'affaires (net), la capitalisation boursière, une mesure de profit, le nombre de salarié&middot;e&middot;s.

### Unité de mesure des variables monétaires

 Les variables monétaires sont en &euro;, en monnaie du pays du siège, en valeurs courante et constante, ainsi que ppa. Selon l'étude à faire, les variables en &euro; suffisent.

[^1]: Nindl, E., Napolitano, L., Confraria, H., Rentocchini, F., Fako, P., Gavigan, J., Tuebke, A. et al., 2024, The 2024 EU Industrial R&D Investment Scoreboard, Publications Office of the European Union, 145 p.

[^2]: Nomenclature statistique des Activités économiques dans la Communauté Européenne. Voir le site de l'[Insee](https://www.insee.fr/fr/metadonnees/definition/c2073) pour plus de détails.

[^3]: Plus précisément, la dépense correspondant aux activités faites pour soi ou pour d'autres entreprises, financée seulement par des entreprises, hors aides directes. L'année d'observation est 2019, afin de comparer des chiffres définitifs.