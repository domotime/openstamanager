-- Aggiunta impostazione conto anticipi
INSERT INTO `co_pianodeiconti3` (`id`, `numero`, `descrizione`, `idpianodeiconti2`, `dir`, `percentuale_deducibile`) VALUES (NULL, '000011', 'Anticipo fornitori', '8', '', '100.00');

INSERT INTO `co_pianodeiconti3` (`id`, `numero`, `descrizione`, `idpianodeiconti2`, `dir`, `percentuale_deducibile`) VALUES (NULL, '000011', 'Anticipo clienti', '2', '', '100.00');

INSERT INTO `zz_settings` (`id`, `nome`, `valore`, `tipo`, `editable`, `sezione`, `order`, `help`) VALUES (NULL, 'Conto anticipo clienti', (SELECT `id` FROM `co_pianodeiconti3` WHERE `descrizione`='Anticipo clienti'), 'query=SELECT id, CONCAT_WS('' - '', numero, descrizione) AS descrizione FROM co_pianodeiconti3', '1', 'Fatturazione', NULL, NULL);

INSERT INTO `zz_settings` (`id`, `nome`, `valore`, `tipo`, `editable`, `sezione`, `order`, `help`) VALUES (NULL, 'Conto anticipo fornitori', (SELECT `id` FROM `co_pianodeiconti3` WHERE `descrizione`='Anticipo fornitori'), 'query=SELECT id, CONCAT_WS('' - '', numero, descrizione) AS descrizione FROM co_pianodeiconti3', '1', 'Fatturazione', NULL, NULL);

-- Allineamento tipo di campo con NULL se non valorizzato
ALTER TABLE `co_movimenti` CHANGE `idanagrafica` `id_anagrafica` INT(11) NULL;

-- Rimozione valori a 0
UPDATE `co_movimenti` SET `id_anagrafica` = NULL WHERE `id_anagrafica` = 0;

-- Spostamento conti transitori su stato patrimoniale
UPDATE `co_pianodeiconti2` SET `idpianodeiconti1` = 1 WHERE `descrizione` = 'Conti transitori';

-- Aggiunta quantità multipla
ALTER TABLE `mg_articoli` ADD `qta_multipla` DECIMAL(15,6) NOT NULL DEFAULT '0' AFTER `threshold_qta`;

-- Correzione riferimenti Articoli Interventi per Fatture
UPDATE `co_righe_documenti` SET `co_righe_documenti`.`original_id` = (SELECT `id` FROM `in_righe_interventi` WHERE `co_righe_documenti`.`original_id` = `in_righe_interventi`.`old_id`) WHERE `co_righe_documenti`.`original_type` = 'Modules\\Interventi\\Components\\Articolo';

--
-- Aggiornamento dati Interventi per Fatture
--
-- Collegamento Articoli
UPDATE `co_righe_documenti` INNER JOIN `in_righe_interventi` ON `co_righe_documenti`.`idintervento` = `in_righe_interventi`.`idintervento` AND `co_righe_documenti`.`descrizione` = `in_righe_interventi`.`descrizione` AND `co_righe_documenti`.`idarticolo` = `in_righe_interventi`.`idarticolo` SET `co_righe_documenti`.`original_id` = `in_righe_interventi`.`id`, `co_righe_documenti`.`original_type` = 'Modules\\Interventi\\Components\\Articolo' WHERE `co_righe_documenti`.`idarticolo` != 0 AND `co_righe_documenti`.`original_type` IS NULL;

-- Collegamento Sconti
UPDATE `co_righe_documenti` INNER JOIN `in_righe_interventi` ON `co_righe_documenti`.`idintervento` = `in_righe_interventi`.`idintervento` AND `co_righe_documenti`.`descrizione` = `in_righe_interventi`.`descrizione` AND `co_righe_documenti`.`idarticolo` = `in_righe_interventi`.`idarticolo` SET `co_righe_documenti`.`original_id` = `in_righe_interventi`.`id`, `co_righe_documenti`.`original_type` = 'Modules\\Interventi\\Components\\Sconto' WHERE `co_righe_documenti`.`is_sconto` != 0 AND `co_righe_documenti`.`original_type` IS NULL;

-- Collegamento Descrizioni
UPDATE `co_righe_documenti` INNER JOIN `in_righe_interventi` ON `co_righe_documenti`.`idintervento` = `in_righe_interventi`.`idintervento` AND `co_righe_documenti`.`descrizione` = `in_righe_interventi`.`descrizione` AND `co_righe_documenti`.`idarticolo` = `in_righe_interventi`.`idarticolo` SET `co_righe_documenti`.`original_id` = `in_righe_interventi`.`id`, `co_righe_documenti`.`original_type` = 'Modules\\Interventi\\Components\\Descrizione' WHERE `co_righe_documenti`.`is_descrizione` != 0 AND `co_righe_documenti`.`original_type` IS NULL;

-- Collegamento Righe
UPDATE `co_righe_documenti` INNER JOIN `in_righe_interventi` ON `co_righe_documenti`.`idintervento` = `in_righe_interventi`.`idintervento` AND `co_righe_documenti`.`descrizione` = `in_righe_interventi`.`descrizione` AND `co_righe_documenti`.`idarticolo` = `in_righe_interventi`.`idarticolo` SET `co_righe_documenti`.`original_id` = `in_righe_interventi`.`id`, `co_righe_documenti`.`original_type` = 'Modules\\Interventi\\Components\\Riga' WHERE `co_righe_documenti`.`original_id` IS NULL AND `co_righe_documenti`.`original_type` IS NULL;
