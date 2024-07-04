#Include 'Protheus.ch' 

//------------------------------------------------------------------- 
/*/{Protheus.doc} FIN341RRET()
Rotina para construção de codigo fonte para geração de arquivo CNAB 

@author 
 
@since 28/12/2017  
@version TOTVS Série T Serviços MSSQL P12cnabttv  
/*/ 
//------------------------------------------------------------------- 
Function FIN341RRET()

	Local aRetCNAB	:= {}

	//                     1       2       3       4       5       6       7       8        9
	//                     IDELIN, HEADET, CHALIN, IDESEG, DESMOV, POSINI, POSFIM, DECIMAL, CONARQ
	//    AADD(aRetCNAB, { ''    , ''    , ''    , ''    , ''    , ''    , ''    , ''     , ''     } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ NIVEL 1                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aRetCNAB, {'1','0','H','' ,'HEADER DE ARQUIVO             ',''   ,'','','','.F.','001','',''}) // 0H - HEADER ARQUIVO
	AADD(aRetCNAB, {'1','0','T','' ,'TRAILER ARQUIVO               ',''   ,'','','','.F.','002','',''}) // 0T - TRAILER ARQUIVO
	AADD(aRetCNAB, {'1','1','D','1','DETALHE SEGMENTO T            ','T'  ,'','','','.F.','003','',''}) // 1D1 - DETALHE SEGMENTO T
	AADD(aRetCNAB, {'1','1','D','2','DETALHE SEGMENTO U            ','U'  ,'','','','.F.','004','',''}) // 1D2 - DETALHE SEGMENTO U
	AADD(aRetCNAB, {'1','1','H','' ,'HEADER DE LOTE                ',''   ,'','','','.F.','005','',''}) // 1H - HEADER DE LOTE
	AADD(aRetCNAB, {'1','1','T','' ,'TRAILER LOTE                  ',''   ,'','','','.F.','006','',''}) // 1T - TRAILER DE LOTE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ NIVEL 2                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// 0H - HEADER ARQUIVO
		AADD(aRetCNAB, {'2','0','H','' ,'CODIGO BANCO   ','001','003','0','                    ','.F.','007','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'LOTE SERVICO   ','004','007','0','                    ','.F.','008','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'REGISTRO ARQUIV','008','008','0','                    ','.F.','009','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COMPLEM REGISTR','009','017','0','                    ','.F.','010','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'TIPO INSC REGIS','018','018','0','                    ','.F.','011','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NRO INSC EMPRES','019','032','0','                    ','.F.','012','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COMPLEM REGISTR','033','052','0','                    ','.F.','013','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COD REM RETORNO','043','143','0','                    ','.F.','014','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COMPLEM REGISTR','053','053','0','                    ','.F.','015','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'AGENCIA MANTENE','054','057','0','                    ','.F.','016','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COMPLEM REGISTR','058','058','0','                    ','.F.','017','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NRO CTA CORRENT','059','070','0','                    ','.F.','018','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COMPLEM REGISTR','071','071','0','                    ','.F.','019','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'DV AGENCIA     ','072','072','0','                    ','.F.','020','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NOME EMPRESA   ','073','102','0','                    ','.F.','021','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NOME BANCO     ','103','132','0','                    ','.F.','022','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COMPLEM REGISTR','133','142','0','                    ','.F.','023','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'DT GER ARQUIVO ','144','151','0','                    ','.F.','024','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'HR GER ARQUIVO ','152','157','0','                    ','.F.','025','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NRO SEQ ARQ RET','158','163','0','                    ','.F.','026','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NRO VER ARQUIVO','164','166','0','                    ','.F.','027','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COMPLEM REGISTR','167','171','0','                    ','.F.','028','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COMPLEM REGISTR','172','225','0','                    ','.F.','029','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COMPLEM REGISTR','226','228','0','                    ','.F.','030','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COMPLEM REGISTR','229','240','0','                    ','.F.','031','',''})

 	// 0T - TRAILER ARQUIVO
		AADD(aRetCNAB, {'2','0','T','' ,'COD BANCO      ','001','003','0','                    ','.F.','032','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'LOTE SERVICO   ','004','007','0','                    ','.F.','033','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'REG TRAILER ARQ','008','008','0','                    ','.F.','034','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'COMP REGISTRO  ','009','017','0','                    ','.F.','035','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'QTD LOTES ARQUI','018','023','0','                    ','.F.','036','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'QTD REG ARQUIVO','024','029','0','                    ','.F.','037','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'COMP REGISTRO  ','030','035','0','                    ','.F.','038','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'COMP REGISTRO  ','036','240','0','                    ','.F.','039','',''})

 	// 1H - HEADER DE LOTE
		AADD(aRetCNAB, {'2','1','H','' ,'CODIGO BANCO   ','001','003','0','                    ','.F.','040','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'LOTE SERVICO   ','004','007','0','                    ','.F.','041','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'REGISTRO LOTE  ','008','008','0','                    ','.F.','042','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'TIPO OPERACAO  ','009','009','0','                    ','.F.','043','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'ID TIPO SERVICO','010','011','0','                    ','.F.','044','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'COMPL REGISTRO ','012','013','0','                    ','.F.','045','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'NRO VER LOTE   ','014','016','0','                    ','.F.','046','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'COMPL REGISTRO ','017','017','0','                    ','.F.','047','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'TIPO INSC EMPRE','018','018','0','                    ','.F.','048','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'NRO INSC EMPRES','019','033','0','                    ','.F.','049','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'COMPL REGISTRO ','034','053','0','                    ','.F.','050','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'AG MANT CONTA  ','054','058','0','                    ','.F.','051','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'COMPL REGISTRO ','059','059','0','                    ','.F.','052','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'NRO CONTA      ','060','071','0','                    ','.F.','053','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'COMPL REGISTRO ','072','072','0','                    ','.F.','054','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'DV AG CON      ','073','073','0','                    ','.F.','055','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'BOME EMPRESA   ','074','103','0','                    ','.F.','056','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'MENSAGEM 1     ','104','143','0','                    ','.F.','057','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'MENSAGEM 2     ','144','183','0','                    ','.F.','058','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'NRO SEQ RETORNO','184','191','0','                    ','.F.','059','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'DT GRAV ARQUIVO','192','199','0','                    ','.F.','060','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'DT CREDITO     ','200','207','0','                    ','.F.','061','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'COMPL REGISTRO ','208','240','0','                    ','.F.','062','',''})

 	// 1T - TRAILER DE LOTE
		AADD(aRetCNAB, {'2','1','T','' ,'COD BANCO      ','001','003','0','                    ','.F.','063','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'LOTE SERVICO   ','004','007','0','                    ','.F.','064','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'REGISTRO LOTE  ','008','008','0','                    ','.F.','065','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'COMP REGISTRO  ','009','017','0','                    ','.F.','066','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'QTD REGIS LOTE ','018','023','0','                    ','.F.','067','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'QTD TITULO SIMP','024','029','0','                    ','.F.','068','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'VLR TOTAL SIMPL','030','046','2','                    ','.F.','069','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'QTD TITULO VINC','047','052','0','                    ','.F.','070','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'VLT TOTAL VINCU','053','069','2','                    ','.F.','071','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'QTDE TIT COBRAN','070','075','0','                    ','.F.','072','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'QTDE TIT CARTEI','076','092','2','                    ','.F.','073','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'QTDE TIT COBRAN','093','098','0','                    ','.F.','074','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'VLR TTL TIT CAR','099','115','2','                    ','.F.','075','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'REF AVISO BANCA','116','123','0','                    ','.F.','076','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'COMP REGISTRO  ','124','240','0','                    ','.F.','077','',''})

	// 1D1 - DETALHE SEGMENTO T
		AADD(aRetCNAB, {'2','1','D','1','CODIGO BANCO   ','001','003','0','                    ','.F.','078','',''})
		AADD(aRetCNAB, {'2','1','D','1','LOTE SERVICO   ','004','007','0','                    ','.F.','079','',''})
		AADD(aRetCNAB, {'2','1','D','1','REGISTRO DETALH','008','008','0','                    ','.F.','080','',''})
		AADD(aRetCNAB, {'2','1','D','1','NRO SEQ DETALHE','009','013','0','                    ','.F.','081','',''})
		AADD(aRetCNAB, {'2','1','D','1','COD SEG DETALHE','014','014','0','SEGMENTO            ','.F.','082','',''})
		AADD(aRetCNAB, {'2','1','D','1','IND BOLETO DDA ','015','015','0','                    ','.F.','083','',''})
		AADD(aRetCNAB, {'2','1','D','1','ID OCORRENCIA  ','016','017','0','                    ','.F.','084','',''})
		AADD(aRetCNAB, {'2','1','D','1','COMP REGISTRO  ','018','018','0','                    ','.F.','085','',''})
		AADD(aRetCNAB, {'2','1','D','1','AG MAN CONTA   ','019','022','0','                    ','.F.','085','',''})
		AADD(aRetCNAB, {'2','1','D','1','COMP REGISTRO  ','023','030','0','                    ','.F.','086','',''})
		AADD(aRetCNAB, {'2','1','D','1','NRO CTA CORRENT','031','035','0','                    ','.F.','087','',''})
		AADD(aRetCNAB, {'2','1','D','1','COMP REGISTRO  ','036','036','0','                    ','.F.','088','',''})
		AADD(aRetCNAB, {'2','1','D','1','DIG AG/CONTA   ','037','037','0','                    ','.F.','089','',''})
		AADD(aRetCNAB, {'2','1','D','1','NRO CART BANCO ','038','040','0','                    ','.F.','090','',''})
		AADD(aRetCNAB, {'2','1','D','1','IDENT TIT BCO  ','041','048','0','NOSSONUMERO         ','.F.','090','',''})
		AADD(aRetCNAB, {'2','1','D','1','DAC DIGIT      ','049','049','0','                    ','.F.','091','',''})
		AADD(aRetCNAB, {'2','1','D','1','COMP REGISTRO  ','050','057','0','                    ','.F.','091','',''})
		AADD(aRetCNAB, {'2','1','D','1','COMP REGISTRO  ','058','058','0','                    ','.F.','092','',''})
		AADD(aRetCNAB, {'2','1','D','1','NRO DOC COBRAN ','059','068','0','TITULO              ','.F.','092','',''})
		AADD(aRetCNAB, {'2','1','D','1','COMP REGISTRO  ','069','073','0','                    ','.F.','093','',''})
		AADD(aRetCNAB, {'2','1','D','1','DT VENCTO      ','074','081','0','                    ','.T.','093','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','1','D','1','VLR NOM TITULO ','082','096','2','                    ','.T.','094','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','1','COMP REGISTRO  ','097','099','0','                    ','.F.','095','',''})
		AADD(aRetCNAB, {'2','1','D','1','AG COB TITULO  ','100','104','0','                    ','.F.','096','',''})
		AADD(aRetCNAB, {'2','1','D','1','DV AG COB TITUL','105','105','0','                    ','.F.','097','',''})
		AADD(aRetCNAB, {'2','1','D','1','ESPECIE TITULO ','106','130','0','ESPECIE             ','.T.','098','{\"ZERAR POSICAO\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}','{\"ZERAR POSICAO\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}'})
		AADD(aRetCNAB, {'2','1','D','1','COMP REGISTRO  ','131','132','0','                    ','.F.','099','',''})
		AADD(aRetCNAB, {'2','1','D','1','TIPO INSC PAGAD','133','133','0','                    ','.F.','100','',''})
		AADD(aRetCNAB, {'2','1','D','1','NRO INSC PAGADO','134','148','0','                    ','.F.','101','',''})
		AADD(aRetCNAB, {'2','1','D','1','NOME PAGADOR   ','149','178','0','                    ','.F.','102','',''})
		AADD(aRetCNAB, {'2','1','D','1','COMP REGISTRO  ','179','188','0','                    ','.F.','103','',''})
		AADD(aRetCNAB, {'2','1','D','1','COMP REGISTRO  ','189','198','0','                    ','.F.','103','',''})
		AADD(aRetCNAB, {'2','1','D','1','TARIFAS/CUSTAS ','199','213','2','DESPESA             ','.F.','104','',''})
		AADD(aRetCNAB, {'2','1','D','1','ID REG REJEITAD','214','221','0','                    ','.F.','105','',''})
		AADD(aRetCNAB, {'2','1','D','1','COD LIQUIDACAO ','222','223','0','                    ','.F.','105','',''})
		AADD(aRetCNAB, {'2','1','D','1','COMP REGISTRO  ','224','240','0','                    ','.F.','106','',''})

	// 1D2 - DETALHE SEGMENTO U
		AADD(aRetCNAB, {'2','1','D','2','COD BANCO      ','001','003','0','                    ','.F.','107','',''})
		AADD(aRetCNAB, {'2','1','D','2','LOTE SERVICO   ','004','007','0','                    ','.F.','108','',''})
		AADD(aRetCNAB, {'2','1','D','2','REGISTRO DETALH','008','008','0','                    ','.F.','109','',''})
		AADD(aRetCNAB, {'2','1','D','2','NRO SEQ LOTE   ','009','013','0','                    ','.F.','110','',''})
		AADD(aRetCNAB, {'2','1','D','2','COD SEG DETALHE','014','014','0','SEGMENTO            ','.F.','111','',''})
		AADD(aRetCNAB, {'2','1','D','2','COMP REGISTRO  ','015','015','0','                    ','.F.','112','',''})
		AADD(aRetCNAB, {'2','1','D','2','ID OCORRENCIA  ','016','017','0','OCORRENCIA          ','.F.','113','',''})
		AADD(aRetCNAB, {'2','1','D','2','JUROS MORA MULT','018','032','2','JUROS               ','.T.','114','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR DESC CONCED','033','047','2','DESCONTO            ','.T.','115','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR ABATIMENTO ','048','062','2','ABATIMENTO          ','.T.','116','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR IOF RECOLHI','063','077','2','IOF                 ','.T.','117','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR LAN CTA COR','078','092','2','VALOR               ','.T.','118','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR LAN CTA COR','093','107','2','                    ','.T.','118','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','COMP REGISTRO  ','108','137','0','                    ','.T.','119','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','DT GER ARQUIVO ','138','145','0','                    ','.F.','123','',''})
		AADD(aRetCNAB, {'2','1','D','2','DT CREDITO     ','146','153','0','DATA                ','.T.','123','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','1','D','2','COD OCOR PAGADO','154','157','0','                    ','.F.','124','',''})
		AADD(aRetCNAB, {'2','1','D','2','DT OCOR PAGADOR','158','165','0','                    ','.F.','125','',''})
		AADD(aRetCNAB, {'2','1','D','2','VLR OCOR PAGADO','166','180','2','                    ','.F.','126','',''})
		AADD(aRetCNAB, {'2','1','D','2','COMP REGISTRO  ','181','210','0','                    ','.F.','127','',''})
		AADD(aRetCNAB, {'2','1','D','2','COMP REGISTRO  ','211','233','0','                    ','.F.','128','',''})
		AADD(aRetCNAB, {'2','1','D','2','USO EXCL CNAB  ','234','240','0','                    ','.T.','130','{\"ZERAR POSICAO\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}','{\"ZERAR POSICAO\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}'})

Return aRetCNAB 
