--1.Nom des lieux qui finissent par 'um'.--

	SELECT *
	FROM lieu 
	WHERE nom_lieu LIKE '%um'

--2. Nombre de personnages par lieu (trié par nombre de personnages décroissant).--

	SELECT id_lieu,count(id_lieu)
	FROM personnage per
	GROUP BY id_lieu

--3. Nom des personnages + spécialité + adresse et lieu d'habitation, triés par lieu puis par nom de personnage.--

	SELECT per.nom_personnage,per.adresse_personnage,lie.nom_lieu,spe.nom_specialite
	FROM personnage per
	INNER JOIN lieu lie
	ON per.id_lieu = lie.id_lieu
	INNER JOIN specialite spe
	ON per.id_specialite = spe.id_specialite
	ORDER BY nom_lieu,nom_personnage


--4. Nom des spécialités avec nombre de personnages par spécialité (trié par nombre de personnages décroissant).--

	SELECT spe.nom_specialite,COUNT(per.id_specialite)
	FROM specialite spe
	INNER JOIN personnage per
	ON spe.id_specialite = per.id_specialite
	GROUP BY nom_specialite


--5. Nom, date et lieu des batailles, classées de la plus récente à la plus ancienne (dates affichées au format jj/mm/aaaa).--

	SELECT bat.nom_bataille, DATE_FORMAT(bat.date_bataille,"%d/%m/%Y"),lie.nom_lieu
	FROM bataille bat
	INNER JOIN lieu lie
	ON bat.id_lieu = lie.id_lieu


--6. Nom des potions + coût de réalisation de la potion (trié par coût décroissant).--

	SELECT pot.nom_potion,sum(com.qte * ing.cout_ingredient) AS prix_potion 
	FROM composer com
	INNER JOIN potion pot
	ON com.id_potion = pot.id_potion
	INNER JOIN ingredient ing 
	ON com.id_ingredient = ing.id_ingredient
	GROUP BY pot.nom_potion
	ORDER BY prix_potion desc


--7. Nom des ingrédients + coût + quantité de chaque ingrédient qui composent la potion 'Santé'.--

	SELECT nom_ingredient,qte,cout_ingredient
	FROM ingredient ing 
	INNER JOIN composer com
	ON ing.id_ingredient = com.id_ingredient
	WHERE id_potion = 3

--8. Nom du ou des personnages qui ont pris le plus de casques dans la bataille 'Bataille du village gaulois'.--

	SELECT per.nom_personnage, bat.nom_bataille,SUM(pca.qte)
	FROM personnage per
	JOIN prendre_casque pca ON per.id_personnage = pca.id_personnage
	JOIN bataille bat ON pca.id_bataille = bat.id_bataille
	WHERE bat.id_bataille = 1
	GROUP BY per.id_personnage, per.nom_personnage
	HAVING SUM(pca.qte) >= ALL (
		SELECT SUM(pca2.qte)
		FROM prendre_casque pca2
		JOIN bataille bat2 ON pca2.id_bataille = bat2.id_bataille
		WHERE bat2.id_bataille = 1
		GROUP BY pca2.id_personnage
		);

--9. Nom des personnages et leur quantité de potion bue (en les classant du plus grand buveur au plus petit).--

	SELECT per.nom_personnage,sum(boi.dose_boire)
	from personnage per
	INNER JOIN boire boi
	ON per.id_personnage = boi.id_personnage
	GROUP BY per.nom_personnage


--10. Nom de la bataille où le nombre de casques pris a été le plus important.--

	SELECT bat.nom_bataille, SUM(pca.qte) AS total_casque
	FROM bataille bat
	JOIN prendre_casque pca
	ON bat.id_bataille = pca.id_bataille
	GROUP BY bat.nom_bataille
	HAVING SUM(pca.qte) = (
		SELECT MAX(total_casque)
		FROM (
			SELECT SUM(pca2.qte) AS total_casque
			FROM prendre_casque pca2
			JOIN bataille bat2 ON pca2.id_bataille = bat2.id_bataille
			GROUP BY bat2.id_bataille
		) AS sous_requete
	);


--11. Combien existe-t-il de casques de chaque type et quel est leur coût total ? (classés par nombre décroissant)--

	SELECT tcas.nom_type_casque,sum(cas.cout_casque * pcas.qte) AS total_cout
	FROM type_casque tcas
	INNER JOIN casque cas
	ON tcas.id_type_casque = cas.id_type_casque
	INNER JOIN prendre_casque pcas
	ON cas.id_casque = pcas.id_casque
	GROUP BY tcas.nom_type_casque
	ORDER BY total_cout desc


--12. Nom des potions dont un des ingrédients est le poisson frais.--

	SELECT nom_potion
	FROM composer com
	INNER JOIN ingredient ing 
	ON com.id_ingredient = ing.id_ingredient
	INNER JOIN potion pot
	ON com.id_potion = pot.id_potion
	WHERE ing.id_ingredient = 24


--13. Nom du / des lieu(x) possédant le plus d'habitants, en dehors du village gaulois.--

	SELECT lie.nom_lieu, COUNT(per.id_personnage) AS nb_habitants
	FROM lieu lie
	INNER JOIN personnage per
	ON lie.id_lieu = per.id_lieu
	WHERE lie.id_lieu != 1
	GROUP BY lie.nom_lieu
	HAVING COUNT(per.id_personnage) >= ALL (
		SELECT COUNT(per2.id_personnage)
		FROM lieu lie2
		INNER JOIN personnage per2
		ON lie2.id_lieu = per2.id_lieu
		WHERE lie2.id_lieu != 1
		GROUP BY lie2.nom_lieu
	);


--14. Nom des personnages qui n'ont jamais bu aucune potion.--

	SELECT per.nom_personnage
	FROM personnage per
	LEFT JOIN boire boi ON per.id_personnage = boi.id_personnage
	GROUP BY per.nom_personnage
	HAVING COUNT(boi.id_personnage) = 0;

--15. Nom du / des personnages qui n'ont pas le droit de boire de la potion 'Magique'.--

	SELECT nom_personnage 
	FROM personnage
	WHERE id_personnage NOT IN (
		SELECT id_personnage
		FROM autoriser_boire
	)

--A. Ajoutez le personnage suivant : Champdeblix, agriculteur résidant à la ferme Hantassion de Rotomagus.--

INSERT INTO personnage (nom_personnage,adresse_personnage,image_personnage,id_lieu,id_specialite)
VALUES ('Champdeblix','Ferme Hantassion','indisponible.jpg',6,12)

--B. Autorisez Bonemine à boire de la potion magique, elle est jalouse d'Iélosubmarine...--


--C. Supprimez les casques grecs qui n'ont jamais été pris lors d'une bataille.--

DELETE FROM casque
WHERE id_casque IN (
    SELECT id_casque FROM (
        SELECT cas.id_casque
        FROM casque cas
        LEFT JOIN prendre_casque pcas
        ON cas.id_casque = pcas.id_casque
        WHERE id_type_casque = 2 AND qte IS NULL
    ) AS supp
);


--D. Modifiez l'adresse de Zérozérosix : il a été mis en prison à Condate.--

	UPDATE personnage 
	SET adresse_personnage = 'Prison' , id_lieu = 9
	WHERE id_personnage = 23


--E. La potion 'Soupe' ne doit plus contenir de persil.--

	DELETE FROM composer 
	WHERE id_ingredient IN (
		SELECT id_ingredient FROM(
		SELECT com.id_ingredient
		FROM composer com
		WHERE id_potion = 9 AND id_ingredient = 19
		)AS supp
	)

--F. Obélix s'est trompé : ce sont 42 casques Weisenau, et non Ostrogoths, qu'il a pris lors de la bataille 'Attaque de la banque postale'. Corrigez son erreur !

	UPDATE prendre_casque 
	SET id_casque = 10 , qte = 42
	WHERE id_bataille = 9 and id_personnage = 5