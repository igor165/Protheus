#Include 'Protheus.ch' 

//------------------------------------------------------------------- 
/*/{Protheus.doc} FIN237PRET()
Rotina para construção de codigo fonte para geração de arquivo CNAB 

@author 
 
@since 28/12/2017  
@version TOTVS Série T Serviços MSSQL P12cnabttv  
/*/ 
//------------------------------------------------------------------- 
Function FIN237PRET()

	Local aRetCNAB    := {}

	//                     1       2       3       4       5       6       7       8        9
	//                     IDELIN, HEADET, CHALIN, IDESEG, DESMOV, POSINI, POSFIM, DECIMAL, CONARQ
	//    AADD(aRetCNAB, { ''    , ''    , ''    , ''    , ''    , ''    , ''    , ''     , ''     } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ NIVEL 1                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aRetCNAB, {'1','0','H','' ,'HEADER DE ARQUIVO             ',''   ,'','','','.F.','001','',''})    // 0H - HEADER DE ARQUIVO
	AADD(aRetCNAB, {'1','0','T','' ,'TRAILLER ARQUIVO              ',''   ,'','','','.F.','002','',''})    // 0T - TRAILLER ARQUIVO
	AADD(aRetCNAB, {'1','1','D','1','DETALHE SEGMENTO A            ','A'  ,'','','','.F.','003','',''})    // 1D1 - DETALHE SEGMENTO A
	AADD(aRetCNAB, {'1','1','D','2','DETALHE SEGMENTO B            ','B'  ,'','','','.F.','004','',''})    // 1D2 - DETALHE SEGMENTO B
	AADD(aRetCNAB, {'1','1','H','' ,'HEADER DE LOTE - A/B          ',''   ,'','','','.F.','005','',''})    // 1H - HEADER DE LOTE - A/B
	AADD(aRetCNAB, {'1','1','T','' ,'TRAILLER DE LOTE - A/B        ',''   ,'','','','.F.','006','',''})    // 1T - TRAILLER DE LOTE - A/B
	AADD(aRetCNAB, {'1','2','D','1','DETALHE SEGMENTO J            ','J'  ,'','','','.F.','007','',''})    // 2D1 - DETALHE SEGMENTO J
	AADD(aRetCNAB, {'1','2','D','2','DETALHE SEGMENTO J-52         ','J52','','','','.F.','008','',''})    // 2D2 - DETALHE SEGMENTO J-52
	AADD(aRetCNAB, {'1','2','H','' ,'HEADER DE LOTE - J / J52      ',''   ,'','','','.F.','009','',''})    // 2H - HEADER DE LOTE - J / J52
	AADD(aRetCNAB, {'1','2','T','' ,'TRAILLER DE LOTE - J / J52    ',''   ,'','','','.F.','010','',''})    // 2T - TRAILLER DE LOTE - J / J52

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ NIVEL 2                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	// 0H - HEADER DE ARQUIVO
		AADD(aRetCNAB, {'2','0','H','' ,'COD DO BANCO   ','001','003','0','                    ','.F.','011','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'LOTE DE SERV   ','004','007','0','                    ','.F.','012','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'TIPO REGISTRO  ','008','008','0','                    ','.F.','013','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'USO EXCL CNAB  ','009','017','0','                    ','.F.','014','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'TP INSC EMPRESA','018','018','0','                    ','.F.','015','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NUM INSC EMP   ','019','032','0','                    ','.F.','016','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COD CONVENIO BC','033','052','0','                    ','.F.','017','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'AG MANT CONTA  ','053','057','0','                    ','.F.','018','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'DV AGENCIA     ','058','058','0','                    ','.F.','019','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NUM CTA CORREN ','059','070','0','                    ','.F.','020','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'DV AGCONTA     ','071','071','0','                    ','.F.','021','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'DV AG/CTA      ','072','072','0','                    ','.F.','022','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NOME DA EMPRESA','073','102','0','                    ','.F.','023','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NOME BANCO     ','103','132','0','                    ','.F.','024','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'USO EXCL CNAB  ','133','142','0','                    ','.F.','025','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'CODIGO REMESSA ','143','143','0','                    ','.F.','026','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'DT GERAC ARQ   ','144','151','0','                    ','.F.','027','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'HORA GR ARQ    ','152','157','0','                    ','.F.','028','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NUM SEQ ARQ    ','158','163','0','                    ','.F.','029','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'VERSAO LAY-OUT ','164','166','0','                    ','.F.','030','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'DENSID GRV ARQ ','167','171','0','                    ','.F.','031','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'RESERVADO BCO  ','172','191','0','                    ','.F.','032','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'RESERVADO EMP  ','192','211','0','                    ','.F.','033','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'USO EXCL CNAB  ','212','240','0','                    ','.F.','034','',''})

	// 0T - TRAILLER DE ARQUIVO
		AADD(aRetCNAB, {'2','0','T','' ,'COD BANCO      ','001','003','0','                    ','.F.','034','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'LOTE SERV      ','004','007','0','                    ','.F.','035','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'TP DE REG      ','008','008','0','                    ','.F.','036','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'USO EXCL CNAB  ','009','017','0','                    ','.F.','037','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'QUANT LOT ARQ  ','018','023','0','                    ','.F.','038','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'QUANT REG ARQ  ','024','029','0','                    ','.F.','039','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'QTDE CTAS CONC ','030','035','0','                    ','.F.','040','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'USO EXCL CNAB  ','036','240','0','                    ','.F.','041','',''})

	// 1H - HEADER DE LOTE - A/B
		AADD(aRetCNAB, {'2','1','H','' ,'COD BANCO      ','001','003','0','                    ','.F.','042','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'LOTE SERVICO   ','004','007','0','                    ','.F.','043','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'TIPO REGISTRO  ','008','008','0','                    ','.F.','044','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'TIPO OPERACAO  ','009','009','0','                    ','.F.','045','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'TIPO SERVICO   ','010','011','0','                    ','.F.','046','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'FORMA LANCAM   ','012','013','0','                    ','.F.','047','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'NUM VERS LOTE  ','014','016','0','                    ','.F.','048','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'USO EXCL CNAB  ','017','017','0','                    ','.F.','049','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'TP INSC EMPRESA','018','018','0','                    ','.F.','050','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'NUM INSC EMP   ','019','032','0','                    ','.F.','051','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'CONVENIO       ','033','052','0','                    ','.F.','052','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'AG MANT CC     ','053','057','0','                    ','.F.','053','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'DV AGENCIA     ','058','058','0','                    ','.F.','054','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'NRO CTA CORRENT','059','070','0','                    ','.F.','055','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'DV CTA CORRENTE','071','071','0','                    ','.F.','056','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'DV AG/CTA      ','072','072','0','                    ','.F.','057','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'NOME EMPRESA   ','073','102','0','                    ','.F.','058','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'MENSAGEM       ','103','142','0','                    ','.F.','059','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'ENDERECO       ','143','172','0','                    ','.F.','060','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'NUMERO         ','173','177','0','                    ','.F.','061','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'COMPLEMENTO    ','178','192','0','                    ','.F.','062','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'CIDADE         ','193','212','0','                    ','.F.','063','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'CEP            ','213','217','0','                    ','.F.','064','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'COMPLEM CEP    ','218','220','0','                    ','.F.','065','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'ESTADO         ','221','222','0','                    ','.F.','066','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'IND FOR PGT SER','223','224','0','                    ','.F.','067','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'USO EXCL CNAB  ','225','230','0','                    ','.F.','068','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'OCORRENCIAS    ','231','240','0','                    ','.F.','069','',''})

	// 1T - TRAILLER DE LOTE - A/B
		AADD(aRetCNAB, {'2','1','T','' ,'COD BANCO      ','001','003','0','                    ','.F.','070','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'LOTE SERVICO   ','004','007','0','                    ','.F.','071','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'TIPO REGISTRO  ','008','008','0','                    ','.F.','072','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'USO EXCL CNAB  ','009','017','0','                    ','.F.','073','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'QUANT DE REG   ','018','023','0','                    ','.F.','074','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'SOMAT VALORES  ','024','041','2','                    ','.F.','075','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'SOMAT QTD MOED ','042','059','5','                    ','.F.','076','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'NRO AVISO DEBIT','060','065','0','                    ','.F.','077','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'USO EXCL CNAB  ','066','230','0','                    ','.F.','078','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'OCORRENCIAS    ','231','240','0','                    ','.F.','079','',''})

	// 2H - HEADER DE LOTE - J / J52
		AADD(aRetCNAB, {'2','2','H','' ,'COD BANCO      ','001','003','0','                    ','.F.','080','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'LOTE SERVICO   ','004','007','0','                    ','.F.','081','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'TIPO REGISTRO  ','008','008','0','                    ','.F.','082','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'TIPO OPERACAO  ','009','009','0','                    ','.F.','083','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'TIPO SERVICO   ','010','011','0','                    ','.F.','084','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'FORMA LANCAM   ','012','013','0','                    ','.F.','085','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'NUM VERS LOTE  ','014','016','0','                    ','.F.','086','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'USO EXCL CNAB  ','017','017','0','                    ','.F.','087','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'TP INSC EMPRESA','018','018','0','                    ','.F.','088','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'NUM INSC EMP   ','019','032','0','                    ','.F.','089','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'CONVENIO       ','033','052','0','                    ','.F.','090','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'AG MANT CC     ','053','057','0','                    ','.F.','091','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'DV AGENCIA     ','058','058','0','                    ','.F.','092','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'NRO CTA CORRENT','059','070','0','                    ','.F.','093','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'DV CTA CORRENTE','071','071','0','                    ','.F.','094','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'DV AG/CTA      ','072','072','0','                    ','.F.','095','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'NOME EMPRESA   ','073','102','0','                    ','.F.','096','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'MENSAGEM       ','103','142','0','                    ','.F.','097','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'ENDERECO       ','143','172','0','                    ','.F.','098','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'NUMERO         ','173','177','0','                    ','.F.','099','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'COMPLEMENTO    ','178','192','0','                    ','.F.','100','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'CIDADE         ','193','212','0','                    ','.F.','101','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'CEP            ','213','217','0','                    ','.F.','102','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'COMPLEM CEP    ','218','220','0','                    ','.F.','103','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'ESTADO         ','221','222','0','                    ','.F.','104','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'USO EXCL CNAB  ','223','230','0','                    ','.F.','105','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'OCORRENCIAS    ','231','240','0','                    ','.F.','106','',''})

	// 2T - TRAILLER DE LOTE - J / J52
		AADD(aRetCNAB, {'2','2','T','' ,'COD BANCO      ','001','003','0','                    ','.F.','107','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'LOTE SERVICO   ','004','007','0','                    ','.F.','108','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'TIPO REGISTRO  ','008','008','0','                    ','.F.','109','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'USO EXCL CNAB  ','009','017','0','                    ','.F.','110','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'QUANT DE REG   ','018','023','0','                    ','.F.','111','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'SOMAT VALORES  ','024','041','2','                    ','.F.','112','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'SOMAT QTD MOED ','042','059','5','                    ','.F.','113','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'NRO AVISO DEBIT','060','065','0','                    ','.F.','114','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'USO EXCL CNAB  ','066','230','0','                    ','.F.','115','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'OCORRENCIAS    ','231','240','0','                    ','.F.','116','',''})

	// 1D1 - DETALHE SEGMENTO A
		AADD(aRetCNAB, {'2','1','D','1','COD BANCO      ','001','003','0','                    ','.F.','117','',''})
		AADD(aRetCNAB, {'2','1','D','1','LOTE SERVICO   ','004','007','0','                    ','.F.','118','',''})
		AADD(aRetCNAB, {'2','1','D','1','TIPO REGISTRO  ','008','008','0','                    ','.F.','119','',''})
		AADD(aRetCNAB, {'2','1','D','1','NRO SEQ LOTE   ','009','013','0','                    ','.F.','120','',''})
		AADD(aRetCNAB, {'2','1','D','1','COD SEG DETALHE','014','014','0','SEGMENTO            ','.F.','121','',''})
		AADD(aRetCNAB, {'2','1','D','1','TIPO MOVIMENTO ','015','015','0','                    ','.F.','122','',''})
		AADD(aRetCNAB, {'2','1','D','1','COD INST MOVIME','016','017','0','                    ','.F.','123','',''})
		AADD(aRetCNAB, {'2','1','D','1','COD CAM CENTRAL','018','020','0','                    ','.F.','124','',''})
		AADD(aRetCNAB, {'2','1','D','1','COD BCO FAVOR  ','021','023','0','                    ','.F.','125','',''})
		AADD(aRetCNAB, {'2','1','D','1','AGENCIA FAVOR  ','024','028','0','                    ','.F.','126','',''})
		AADD(aRetCNAB, {'2','1','D','1','DV AGENCIA     ','029','029','0','                    ','.F.','127','',''})
		AADD(aRetCNAB, {'2','1','D','1','CTA CORRENTE   ','030','041','0','                    ','.F.','128','',''})
		AADD(aRetCNAB, {'2','1','D','1','DV CONTA       ','042','042','0','                    ','.F.','129','',''})
		AADD(aRetCNAB, {'2','1','D','1','DV AG/CTA      ','043','043','0','                    ','.F.','130','',''})
		AADD(aRetCNAB, {'2','1','D','1','NOME FAVOR     ','044','073','0','                    ','.F.','131','',''})
		AADD(aRetCNAB, {'2','1','D','1','NUM DOC EMPRES ','074','093','0','TITULO              ','.F.','132','',''})
		AADD(aRetCNAB, {'2','1','D','1','DATA PAGAMENTO ','094','101','0','DATA                ','.T.','133','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','1','D','1','TIPO DA MOEDA  ','102','104','0','                    ','.F.','134','',''})
		AADD(aRetCNAB, {'2','1','D','1','QUANT MOEDA    ','105','119','5','                    ','.F.','135','',''})
		AADD(aRetCNAB, {'2','1','D','1','VLR PAGAMENTO  ','120','134','2','                    ','.T.','136','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','1','NRO DOC ATRI BC','135','154','0','NOSSONUMERO         ','.T.','137','{\"ZERAR POSICAO\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}','{\"ZERAR POSICAO\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}'})
		AADD(aRetCNAB, {'2','1','D','1','DT REAL PGTO   ','155','162','0','DATACREDITO         ','.T.','138','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','1','D','1','VLR REAL PGTO  ','163','177','2','VALOR               ','.T.','139','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','1','OUTRAS INFORMAC','178','217','0','                    ','.F.','140','',''})
		AADD(aRetCNAB, {'2','1','D','1','COMP TP SERVICO','218','219','0','                    ','.F.','141','',''})
		AADD(aRetCNAB, {'2','1','D','1','COD FINAL TED  ','220','224','0','                    ','.F.','142','',''})
		AADD(aRetCNAB, {'2','1','D','1','COMPL FINAL PAG','225','226','0','                    ','.F.','143','',''})
		AADD(aRetCNAB, {'2','1','D','1','USO EXCL CNAB  ','227','229','0','                    ','.F.','144','',''})
		AADD(aRetCNAB, {'2','1','D','1','AVISO FAVOREC  ','230','230','0','                    ','.F.','145','',''})
		AADD(aRetCNAB, {'2','1','D','1','OCORRENCIAS    ','231','240','0','OCORRENCIA          ','.T.','146','{\"ZERAR POSICAO\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}','{\"ZERAR POSICAO\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}'})

	// 1D2 - DETALHE SEGMENTO B
		AADD(aRetCNAB, {'2','1','D','2','COD BANCO      ','001','003','0','                    ','.F.','147','',''})
		AADD(aRetCNAB, {'2','1','D','2','LOTE SERVICO   ','004','007','0','                    ','.F.','148','',''})
		AADD(aRetCNAB, {'2','1','D','2','TIPO REGISTRO  ','008','008','0','                    ','.F.','149','',''})
		AADD(aRetCNAB, {'2','1','D','2','NRO SEQ LOTE   ','009','013','0','                    ','.F.','150','',''})
		AADD(aRetCNAB, {'2','1','D','2','COD SEG DETALHE','014','014','0','SEGMENTO            ','.F.','151','',''})
		AADD(aRetCNAB, {'2','1','D','2','USO EXCL CNAB  ','015','017','0','                    ','.F.','152','',''})
		AADD(aRetCNAB, {'2','1','D','2','TP INSC FAVOR  ','018','018','0','                    ','.F.','153','',''})
		AADD(aRetCNAB, {'2','1','D','2','NRO INSC FAVOR ','019','032','0','                    ','.F.','154','',''})
		AADD(aRetCNAB, {'2','1','D','2','LOGRAD FAVOREC ','033','062','0','                    ','.F.','155','',''})
		AADD(aRetCNAB, {'2','1','D','2','NRO LOCAL      ','063','067','0','                    ','.F.','156','',''})
		AADD(aRetCNAB, {'2','1','D','2','COMPLEMENTO    ','068','082','0','                    ','.F.','157','',''})
		AADD(aRetCNAB, {'2','1','D','2','BAIRRO FAVOREC ','083','097','0','                    ','.F.','158','',''})
		AADD(aRetCNAB, {'2','1','D','2','CIDADE FAVOREC ','098','117','0','                    ','.F.','159','',''})
		AADD(aRetCNAB, {'2','1','D','2','CEP FAVOREC    ','118','122','0','                    ','.F.','160','',''})
		AADD(aRetCNAB, {'2','1','D','2','COMPLEM CEP    ','123','125','0','                    ','.F.','161','',''})
		AADD(aRetCNAB, {'2','1','D','2','FAV ESTADO     ','126','127','0','                    ','.F.','162','',''})
		AADD(aRetCNAB, {'2','1','D','2','DATA VENCIMENTO','128','135','0','                    ','.T.','163','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VALOR          ','136','150','2','                    ','.T.','164','{\"ZERAR POSICAO\",\"VALOR\"}','{\"ZERAR POSICAO\",\"VALOR\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR ABATIMENTO ','151','165','2','ABATIMENTO          ','.T.','165','{\"ZERAR POSICAO\",\"VALOR\",\"ABATIMENTO\"','{\"ZERAR POSICAO\",\"VALOR\",\"ABATIMENTO\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR  DESCONTO  ','166','180','2','DESCONTO            ','.T.','166','{\"ZERAR POSICAO\",\"VALOR\",\"DESCONTO\"','{\"ZERAR POSICAO\",\"VALOR\",\"DESCONTO\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR MORA       ','181','195','2','JUROS               ','.T.','167','{\"ZERAR POSICAO\",\"VALOR\",\"JUROS\"','{\"ZERAR POSICAO\",\"VALOR\",\"JUROS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR MULTA      ','196','210','2','MULTA               ','.T.','168','{\"ZERAR POSICAO\",\"VALOR\",\"MULTA\"','{\"ZERAR POSICAO\",\"VALOR\",\"MULTA\"}'})
		AADD(aRetCNAB, {'2','1','D','2','COD DCTO FAVORE','211','225','0','                    ','.F.','169','',''})
		AADD(aRetCNAB, {'2','1','D','2','AVISO FAVOREC  ','226','226','0','                    ','.F.','170','',''})
		AADD(aRetCNAB, {'2','1','D','2','USO EXCL SIAPE ','227','232','0','                    ','.F.','171','',''})
		AADD(aRetCNAB, {'2','1','D','2','COD ISPB       ','233','240','0','                    ','.F.','172','',''})

	// 2D1 - DETALHE SEGMENTO J
		AADD(aRetCNAB, {'2','2','D','1','COD BANCO      ','001','003','0','                    ','.F.','173','',''})
		AADD(aRetCNAB, {'2','2','D','1','LOTE SERVICO   ','004','007','0','                    ','.F.','174','',''})
		AADD(aRetCNAB, {'2','2','D','1','TIPO REGISTRO  ','008','008','0','                    ','.F.','175','',''})
		AADD(aRetCNAB, {'2','2','D','1','NUM SEQ REG LOT','009','013','0','                    ','.F.','176','',''})
		AADD(aRetCNAB, {'2','2','D','1','COD SEG DETALHE','014','014','0','SEGMENTO            ','.F.','177','',''})
		AADD(aRetCNAB, {'2','2','D','1','TIPO MOVIMENTO ','015','015','0','                    ','.F.','178','',''})
		AADD(aRetCNAB, {'2','2','D','1','COD INST MOVIM ','016','017','0','                    ','.F.','179','',''})
		AADD(aRetCNAB, {'2','2','D','1','COD BARRAS     ','018','061','0','                    ','.F.','180','',''})
		AADD(aRetCNAB, {'2','2','D','1','NOME DO CEDENTE','062','091','0','                    ','.F.','181','',''})
		AADD(aRetCNAB, {'2','2','D','1','DATA VENCIMENTO','092','099','0','                    ','.T.','182','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','2','D','1','VLR NOM TIT    ','100','114','2','                    ','.T.','183','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','2','D','1','VALOR DESCONTO ','115','129','2','DESCONTO            ','.T.','184','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','2','D','1','VALOR JUROS    ','130','144','2','JUROS               ','.T.','185','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','2','D','1','DATA PAGAMENTO ','145','152','0','DATA                ','.T.','186','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','2','D','1','VALOR PAGAMENTO','153','167','2','VALOR               ','.T.','187','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','2','D','1','QTDE MOEDA     ','168','182','5','                    ','.F.','188','',''})
		AADD(aRetCNAB, {'2','2','D','1','NRO DOC EMPRESA','183','202','0','TITULO              ','.T.','189','{\"ZERAR POSICAO\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}','{\"ZERAR POSICAO\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}'})
		AADD(aRetCNAB, {'2','2','D','1','NRO DOC BANCO  ','203','222','0','NOSSONUMERO         ','.F.','190','',''})
		AADD(aRetCNAB, {'2','2','D','1','COD MOEDA      ','223','224','0','                    ','.F.','191','',''})
		AADD(aRetCNAB, {'2','2','D','1','USO EXCL CNAB  ','225','230','0','RESERVADO           ','.F.','192','',''})
		AADD(aRetCNAB, {'2','2','D','1','OCORRENCIAS    ','231','240','0','OCORRENCIA          ','.T.','193','{\"ZERAR POSICAO\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}','{\"ZERAR POSICAO\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}'})

	// 2D2 - DETALHE SEGMENTO J-52
		AADD(aRetCNAB, {'2','2','D','2','COD BANCO      ','001','003','0','                    ','.F.','194','',''})
		AADD(aRetCNAB, {'2','2','D','2','LOTE SERVICO   ','004','007','0','                    ','.F.','195','',''})
		AADD(aRetCNAB, {'2','2','D','2','TIPO REGISTRO  ','008','008','0','                    ','.F.','196','',''})
		AADD(aRetCNAB, {'2','2','D','2','NRO SEQ LOTE   ','009','013','0','                    ','.F.','197','',''})
		AADD(aRetCNAB, {'2','2','D','2','COD SEG DETALHE','014','014','0','SEGJ52              ','.F.','198','',''})
		AADD(aRetCNAB, {'2','2','D','2','USO EXCL CNAB  ','015','015','0','                    ','.F.','199','',''})
		AADD(aRetCNAB, {'2','2','D','2','COD MOV REMESSA','016','017','0','                    ','.F.','200','',''})
		AADD(aRetCNAB, {'2','2','D','2','ID REGISTRO    ','018','019','0','                    ','.F.','201','',''})
		AADD(aRetCNAB, {'2','2','D','2','TIPO INSC SACAD','020','020','0','                    ','.F.','202','',''})
		AADD(aRetCNAB, {'2','2','D','2','NRO INSC SACADO','021','035','0','                    ','.F.','203','',''})
		AADD(aRetCNAB, {'2','2','D','2','NOME SACADO    ','036','075','0','                    ','.F.','204','',''})
		AADD(aRetCNAB, {'2','2','D','2','TIPO INSC CEDEN','076','076','0','                    ','.F.','205','',''})
		AADD(aRetCNAB, {'2','2','D','2','NRO INSC CEDEN ','077','091','0','                    ','.F.','206','',''})
		AADD(aRetCNAB, {'2','2','D','2','NOME CEDENTE   ','092','131','0','                    ','.F.','207','',''})
		AADD(aRetCNAB, {'2','2','D','2','TP INSC SACADOR','132','132','0','                    ','.F.','208','',''})
		AADD(aRetCNAB, {'2','2','D','2','NRO INS SACADOR','133','147','0','                    ','.F.','209','',''})
		AADD(aRetCNAB, {'2','2','D','2','NOME SACADOR   ','148','187','0','                    ','.F.','210','',''})
		AADD(aRetCNAB, {'2','2','D','2','USO EXCL CNAB  ','188','240','0','                    ','.F.','211','',''})

Return aRetCNAB 
