#Include 'Protheus.ch' 

//------------------------------------------------------------------- 
/*/{Protheus.doc} FIN341PRET()
Rotina para construção de codigo fonte para geração de arquivo CNAB 

@author 
 
@since 28/12/2017  
@version TOTVS Série T Serviços MSSQL P12cnabttv  
/*/ 
//------------------------------------------------------------------- 
Function FIN341PRET()

	Local aRetCNAB	:= {}
	
	//                     1       2       3       4       5       6       7       8        9
	//                     IDELIN, HEADET, CHALIN, IDESEG, DESMOV, POSINI, POSFIM, DECIMAL, CONARQ
	//    AADD(aRetCNAB, { ''    , ''    , ''    , ''    , ''    , ''    , ''    , ''     , ''     } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ NIVEL 1                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aRetCNAB, {'1','0','H','' ,'HEADER ARQUIVO                ',''   ,'','','','.F.','001','',''}) // 0H - HEADER ARQUIVO
	AADD(aRetCNAB, {'1','0','T','' ,'TRAILLER ARQUIVO              ',''   ,'','','','.F.','002','',''}) // 0T - TRAILLER ARQUIVO
	AADD(aRetCNAB, {'1','1','D','1','DETALHE SEGMENTO A            ','A'  ,'','','','.F.','003','',''}) // 1H - HEADER DE LOTE - A / B
	AADD(aRetCNAB, {'1','1','D','2','DETALHE SEGMENTO B            ','B'  ,'','','','.F.','004','',''}) // 1D1 - DETALHE SEGMENTO A
	AADD(aRetCNAB, {'1','1','H','' ,'HEADER DE LOTE - A/B          ',''   ,'','','','.F.','005','',''}) // 1D2 - DETALHE SEGMENTO B
	AADD(aRetCNAB, {'1','1','T','' ,'TRAILLER DE LOTE - A/B        ',''   ,'','','','.F.','006','',''}) // 1T - TRAILLER DE LOTE - A / B
	AADD(aRetCNAB, {'1','2','D','1','DETALHE SEGMENTO J            ','J'  ,'','','','.F.','007','',''}) // 2H - HEADER DE LOTE - J / J52
	AADD(aRetCNAB, {'1','2','D','2','DETALHE SEGMENTO J-52         ','J52','','','','.F.','008','',''}) // 2D1 - DETALHE SEGMENTO J
	AADD(aRetCNAB, {'1','2','H','' ,'HEADER DE LOTE - J / J52      ',''   ,'','','','.F.','009','',''}) // 2D2 - DETALHE SEGMENTO J-52
	AADD(aRetCNAB, {'1','2','T','' ,'TRAILLER DE LOTE - J / J52    ',''   ,'','','','.F.','010','',''}) // 2T - TRAILLER DE LOTE - J / J52

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ NIVEL 2                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	// 0H - HEADER ARQUIVO
		AADD(aRetCNAB, {'2','0','H','' ,'COD BCO        ','001','003','0','                    ','.F.','011','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'LOTE SERVICO   ','004','007','0','                    ','.F.','012','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'REG.HEADER ARQ.','008','008','0','                    ','.F.','013','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COMPL REGISTRO ','009','014','0','                    ','.F.','014','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'VERS.LAYOUT ARQ','015','017','0','                    ','.F.','015','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'TIPO INSCRICAO ','018','018','0','                    ','.F.','016','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NUM. INSCRICAO ','019','032','0','                    ','.F.','017','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COMPL REGISTRO ','033','052','0','                    ','.F.','018','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'AGENCIA        ','053','057','0','                    ','.F.','019','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COMPL REGISTRO ','058','058','0','                    ','.F.','020','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'CONTA CORRENTE ','059','070','0','                    ','.F.','021','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COMPL REGISTRO ','071','071','0','                    ','.F.','022','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'DIGITO DA CTA  ','072','072','0','                    ','.F.','023','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NOME DA EMPRESA','073','102','0','                    ','.F.','024','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NOME DO BANCO  ','103','132','0','                    ','.F.','025','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COMPL REGISTRO ','133','142','0','                    ','.F.','026','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'REMESSA        ','143','143','0','                    ','.F.','027','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'DT.GERACAO     ','144','151','0','                    ','.F.','028','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'HR.GERACAO     ','152','157','0','                    ','.F.','029','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COMPL REGISTRO ','158','166','0','                    ','.F.','030','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'DENSIDADE GRAV.','167','171','0','                    ','.F.','031','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COMPL REGISTRO ','172','240','0','                    ','.F.','032','',''})

 	// 0T - TRAILLER ARQUIVO
		AADD(aRetCNAB, {'2','0','T','' ,'BCO COMPENSACAO','001','003','0','                    ','.F.','033','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'LOTE DE SERVICO','004','007','0','                    ','.F.','034','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'REG TRAILER ARQ','008','008','0','                    ','.F.','035','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'COMPL REGISTRO ','009','017','0','                    ','.F.','036','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'QTD LOTES      ','018','023','0','                    ','.F.','037','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'QTD REGISTRO   ','024','029','0','                    ','.F.','038','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'COMPL REGISTRO ','030','240','0','                    ','.F.','039','',''})

	// 1H - HEADER DE LOTE - A / B
		AADD(aRetCNAB, {'2','1','H','' ,'COD BCO        ','001','003','0','BANCO               ','.F.','040','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'LOTE ID PAGTOS ','004','007','0','                    ','.F.','041','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'REG HEADER LOTE','008','008','0','                    ','.F.','042','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'TIPO OPERACAO  ','009','009','0','                    ','.F.','043','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'TIPO PAGTO     ','010','011','0','                    ','.F.','044','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'FORMA PAGTO    ','012','013','0','                    ','.F.','045','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'VERSAO LAYOUT  ','014','016','0','                    ','.F.','046','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'COMPL REGISTRO ','017','017','0','                    ','.F.','047','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'INSCR. TIPO    ','018','018','0','                    ','.F.','048','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'INSCR. NUMERO  ','019','032','0','                    ','.F.','049','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'ID LANCTO      ','033','036','0','                    ','.F.','050','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'COMPL REGISTRO ','037','052','0','                    ','.F.','051','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'AGENCIA DA CTA ','053','057','0','AGENCIA             ','.F.','052','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'COMPL REGISTRO ','058','058','0','                    ','.F.','053','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'CTA CORRENTE   ','059','070','0','CONTA               ','.F.','054','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'COMPL REGISTRO ','071','071','0','                    ','.F.','055','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'DAC DA AG./CTA ','072','072','0','                    ','.F.','056','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'NOME EMPRESA   ','073','102','0','                    ','.F.','057','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'FINAL LOTE     ','103','132','0','                    ','.F.','058','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'COMPL.HIST.C/C ','133','142','0','                    ','.F.','059','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'LOGRADOURO     ','143','172','0','                    ','.F.','060','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'NUMERO         ','173','177','0','                    ','.F.','061','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'COMPLEMENTO    ','178','192','0','                    ','.F.','062','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'CIDADE         ','193','212','0','                    ','.F.','063','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'CEP            ','213','220','0','                    ','.F.','064','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'ESTADO         ','221','222','0','                    ','.F.','065','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'COMPL REGISTRO ','223','230','0','                    ','.F.','066','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'OCORRENCIAS    ','231','240','0','                    ','.F.','067','',''})

	// 1T - TRAILLER DE LOTE - A / B
		AADD(aRetCNAB, {'2','1','T','' ,'COD BANCO      ','001','003','0','                    ','.F.','068','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'LOTE SERVICO   ','004','007','0','                    ','.F.','069','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'REGISTRO LOTE  ','008','008','0','                    ','.F.','070','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'COMPL REGISTRO ','009','017','0','                    ','.F.','071','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'QTDE REG LOTE  ','018','023','0','                    ','.F.','072','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'VLR CREDITO    ','024','041','2','                    ','.F.','073','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'COMPL REGISTRO ','042','059','0','                    ','.F.','074','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'COMPL REGISTRO ','060','230','0','                    ','.F.','075','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'OCORRENCIAS    ','231','240','0','                    ','.F.','076','',''})

	// 2H - HEADER DE LOTE - J / J52
		AADD(aRetCNAB, {'2','2','H','' ,'COD BCO        ','001','003','0','BANCO               ','.F.','077','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'LOTE ID PAGTOS ','004','007','0','                    ','.F.','078','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'REG HEADER LOTE','008','008','0','                    ','.F.','079','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'TIPO OPERACAO  ','009','009','0','                    ','.F.','080','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'TIPO PAGTO     ','010','011','0','                    ','.F.','081','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'FORMA PAGTO    ','012','013','0','                    ','.F.','082','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'VERSAO LAYOUT  ','014','016','0','                    ','.F.','083','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'COMPL REGISTRO ','017','017','0','                    ','.F.','084','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'INSCR. TIPO    ','018','018','0','                    ','.F.','085','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'INSCR. NUMERO  ','019','032','0','                    ','.F.','086','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'COMPL REGISTRO ','033','052','0','                    ','.F.','087','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'AGENCIA DA CTA ','053','057','0','AGENCIA             ','.F.','088','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'COMPL REGISTRO ','058','058','0','                    ','.F.','089','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'CTA CORRENTE   ','059','070','0','CONTA               ','.F.','090','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'COMPL REGISTRO ','071','071','0','                    ','.F.','091','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'DAC DA AG./CTA ','072','072','0','                    ','.F.','092','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'NOME EMPRESA   ','073','102','0','                    ','.F.','093','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'FINAL LOTE     ','103','132','0','                    ','.F.','094','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'COMPL.HIST.C/C ','133','142','0','                    ','.F.','095','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'LOGRADOURO     ','143','172','0','                    ','.F.','096','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'NUMERO         ','173','177','0','                    ','.F.','097','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'COMPLEMENTO    ','178','192','0','                    ','.F.','098','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'CIDADE         ','193','212','0','                    ','.F.','099','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'CEP            ','213','220','0','                    ','.F.','100','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'ESTADO         ','221','222','0','                    ','.F.','101','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'COMPL REGISTRO ','223','230','0','                    ','.F.','102','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'OCORRENCIAS    ','231','240','0','                    ','.F.','103','',''})

	// 2T - TRAILLER DE LOTE - J / J52
		AADD(aRetCNAB, {'2','2','T','' ,'COD BANCO      ','001','003','0','                    ','.F.','104','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'LOTE SERVICO   ','004','007','0','                    ','.F.','105','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'REGISTRO LOTE  ','008','008','0','                    ','.F.','106','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'COMPL REGISTRO ','009','017','0','                    ','.F.','107','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'QTDE REG LOTE  ','018','023','0','                    ','.F.','108','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'VLR CREDITO    ','024','041','2','                    ','.F.','109','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'COMPL REGISTRO ','042','059','0','                    ','.F.','110','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'COMPL REGISTRO ','060','230','0','                    ','.F.','111','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'OCORRENCIAS    ','231','240','0','                    ','.F.','112','',''})

	// 1D1 - DETALHE SEGMENTO A
		AADD(aRetCNAB, {'2','1','D','1','BCO COMPENSACAO','001','003','0','                    ','.F.','113','',''})
		AADD(aRetCNAB, {'2','1','D','1','LOTE SERVICO   ','004','007','0','                    ','.F.','114','',''})
		AADD(aRetCNAB, {'2','1','D','1','RG.DETALHE LOTE','008','008','0','                    ','.F.','115','',''})
		AADD(aRetCNAB, {'2','1','D','1','SEQ.REG.LOTE   ','009','013','0','                    ','.F.','116','',''})
		AADD(aRetCNAB, {'2','1','D','1','COD.SEQ.REG.DET','014','014','0','SEGMENTO            ','.F.','117','',''})
		AADD(aRetCNAB, {'2','1','D','1','TIPO DE MOV.   ','015','017','0','                    ','.F.','118','',''})
		AADD(aRetCNAB, {'2','1','D','1','ZEROS          ','018','020','0','                    ','.F.','119','',''})
		AADD(aRetCNAB, {'2','1','D','1','COD BCO FAVOR  ','021','023','0','                    ','.F.','120','',''})
		AADD(aRetCNAB, {'2','1','D','1','AGENCIA FAVOR  ','024','043','0','                    ','.F.','121','',''})
		AADD(aRetCNAB, {'2','1','D','1','NOME FAVORECIDO','044','073','0','                    ','.F.','122','',''})
		AADD(aRetCNAB, {'2','1','D','1','DOC ATRI EMP   ','074','093','0','TITULO              ','.F.','123','',''})
		AADD(aRetCNAB, {'2','1','D','1','DT PAGTO       ','094','101','0','DATA                ','.T.','124','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','1','D','1','TIPO DA MOEDA  ','102','104','0','                    ','.F.','125','',''})
		AADD(aRetCNAB, {'2','1','D','1','COD ISPB       ','105','119','0','                    ','.F.','126','',''})
		AADD(aRetCNAB, {'2','1','D','1','VALOR PAGTO    ','120','134','2','                    ','.T.','127','',''})
		AADD(aRetCNAB, {'2','1','D','1','NOSSO NUMERO   ','135','149','0','NOSSONUMERO         ','.T.','128','{\"ZERAR POSICAO\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}','{\"ZERAR POSICAO\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}'})
		AADD(aRetCNAB, {'2','1','D','1','COMP REGISTRO  ','150','154','0','                    ','.F.','129','',''})
		AADD(aRetCNAB, {'2','1','D','1','DT REAL PAGTO  ','155','162','0','DATACREDITO         ','.T.','130','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','1','D','1','VALOR EFETIVO  ','164','177','2','VALOR               ','.T.','131','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','1','COMP HISTORICO ','178','191','0','                    ','.F.','132','',''})
		AADD(aRetCNAB, {'2','1','D','1','COMP REGISTRO  ','192','197','0','                    ','.F.','133','',''})
		AADD(aRetCNAB, {'2','1','D','1','NRO DOCUMENTO  ','198','203','0','                    ','.T.','134','{\"ZERAR POSICAO\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}','{\"ZERAR POSICAO\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}'})
		AADD(aRetCNAB, {'2','1','D','1','NRO FAVORECIDO ','204','217','0','                    ','.F.','135','',''})
		AADD(aRetCNAB, {'2','1','D','1','FINAL DOC STATU','218','218','0','                    ','.F.','136','',''})
		AADD(aRetCNAB, {'2','1','D','1','COMP REGISTRO  ','219','229','0','                    ','.F.','137','',''})
		AADD(aRetCNAB, {'2','1','D','1','AVISO FAVOREC  ','230','230','0','                    ','.F.','138','',''})
		AADD(aRetCNAB, {'2','1','D','1','OCORRENCIAS    ','231','240','0','OCORRENCIA          ','.T.','139','{\"ZERAR POSICAO\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}','{\"ZERAR POSICAO\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}'})

	// 1D2 - DETALHE SEGMENTO B
		AADD(aRetCNAB, {'2','1','D','2','NOME BANCO     ','001','003','0','                    ','.F.','140','',''})
		AADD(aRetCNAB, {'2','1','D','2','LOTE SERVICO   ','004','007','0','                    ','.F.','141','',''})
		AADD(aRetCNAB, {'2','1','D','2','REG DET LOTE   ','008','008','0','                    ','.F.','142','',''})
		AADD(aRetCNAB, {'2','1','D','2','SEQ REG LOTE   ','009','013','0','                    ','.F.','143','',''})
		AADD(aRetCNAB, {'2','1','D','2','COD SEGM DETALH','014','014','0','SEGMENTO            ','.F.','144','',''})
		AADD(aRetCNAB, {'2','1','D','2','COMPL REGISTRO ','015','017','0','                    ','.F.','145','',''})
		AADD(aRetCNAB, {'2','1','D','2','TP INSC FAVOREC','018','018','0','                    ','.F.','146','',''})
		AADD(aRetCNAB, {'2','1','D','2','INSC FAVORECIDO','019','032','0','                    ','.F.','147','',''})
		AADD(aRetCNAB, {'2','1','D','2','END FAVORECIDO ','033','062','0','                    ','.F.','148','',''})
		AADD(aRetCNAB, {'2','1','D','2','NRO END FAVOREC','063','067','0','                    ','.F.','149','',''})
		AADD(aRetCNAB, {'2','1','D','2','COMPLEM END FAV','068','082','0','                    ','.F.','150','',''})
		AADD(aRetCNAB, {'2','1','D','2','BAIRRO FAVOR   ','083','097','0','                    ','.F.','151','',''})
		AADD(aRetCNAB, {'2','1','D','2','CIDADE FAVOR   ','098','117','0','                    ','.F.','152','',''})
		AADD(aRetCNAB, {'2','1','D','2','CEP FAVOR      ','118','125','0','                    ','.F.','153','',''})
		AADD(aRetCNAB, {'2','1','D','2','EST FAVOR      ','126','127','0','                    ','.F.','154','',''})
		AADD(aRetCNAB, {'2','1','D','2','E-MAIL FAVOR   ','128','227','0','                    ','.F.','155','',''})
		AADD(aRetCNAB, {'2','1','D','2','COMPL REGISTRO ','228','230','0','                    ','.F.','156','',''})
		AADD(aRetCNAB, {'2','1','D','2','OCORRENCIAS    ','231','240','0','                    ','.T.','157','{\"ZERAR POSICAO\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}','{\"ZERAR POSICAO\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}'})

	// 2D1 - DETALHE SEGMENTO J
		AADD(aRetCNAB, {'2','2','D','1','BCO COMPENSACAO','001','003','0','                    ','.F.','158','',''})
		AADD(aRetCNAB, {'2','2','D','1','LOTE SERVICO   ','004','007','0','                    ','.F.','159','',''})
		AADD(aRetCNAB, {'2','2','D','1','REG.DET. LOTE  ','008','008','0','                    ','.F.','160','',''})
		AADD(aRetCNAB, {'2','2','D','1','SEQ REG LOTE   ','009','013','0','                    ','.F.','161','',''})
		AADD(aRetCNAB, {'2','2','D','1','SEG.REG.DET    ','014','014','0','SEGMENTO            ','.F.','162','',''})
		AADD(aRetCNAB, {'2','2','D','1','TP MOVIMENTO   ','015','017','0','                    ','.F.','163','',''})
		AADD(aRetCNAB, {'2','2','D','1','COD BAR BCO FAV','018','020','0','                    ','.F.','164','',''})
		AADD(aRetCNAB, {'2','2','D','1','COD BAR MOEDA  ','021','021','0','                    ','.F.','165','',''})
		AADD(aRetCNAB, {'2','2','D','1','COD BAR DIG VER','022','022','0','                    ','.F.','166','',''})
		AADD(aRetCNAB, {'2','2','D','1','COD BAR VEN/VAL','023','036','0','                    ','.F.','167','',''})
		AADD(aRetCNAB, {'2','2','D','1','COD BAR F VECTO','023','026','0','                    ','.F.','168','',''})
		AADD(aRetCNAB, {'2','2','D','1','COD BAR CPO LIV','037','061','0','                    ','.F.','169','',''})
		AADD(aRetCNAB, {'2','2','D','1','NOME FAVOREC   ','062','091','0','                    ','.F.','170','',''})
		AADD(aRetCNAB, {'2','2','D','1','DT VENCTO      ','092','099','0','                    ','.T.','171','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','2','D','1','VALOR LCTO     ','100','114','2','                    ','.T.','172','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','2','D','1','VAL DESC+ABATIM','116','129','2','DESCONTO            ','.T.','173','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','2','D','1','VAL MORA+MULTA ','131','144','2','JUROS               ','.T.','174','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','2','D','1','DT EFET.DO PAG.','145','152','0','DATA                ','.T.','175','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','2','D','1','VAL.EFET.DO PAG','154','167','2','VALOR               ','.T.','176','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','2','D','1','ZEROS          ','168','182','0','                    ','.F.','177','',''})
		AADD(aRetCNAB, {'2','2','D','1','SEU NUMERO     ','183','202','0','TITULO              ','.T.','178','{\"ZERAR POSICAO\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}','{\"ZERAR POSICAO\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}'})
		AADD(aRetCNAB, {'2','2','D','1','BRANCOS        ','203','215','0','                    ','.F.','179','',''})
		AADD(aRetCNAB, {'2','2','D','1','NUM.DOC.NO BCO.','216','230','0','                    ','.F.','180','',''})
		AADD(aRetCNAB, {'2','2','D','1','OCORRENCIA     ','231','240','0','OCORRENCIA          ','.T.','181','{\"ZERAR POSICAO\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}','{\"ZERAR POSICAO\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}'})

	// 2D2 - DETALHE SEGMENTO J-52
		AADD(aRetCNAB, {'2','2','D','2','COD BANCO      ','001','003','0','                    ','.F.','182','',''})
		AADD(aRetCNAB, {'2','2','D','2','LOTE SERVICO   ','004','007','0','                    ','.F.','183','',''})
		AADD(aRetCNAB, {'2','2','D','2','REG DET LOTE   ','008','008','0','                    ','.F.','184','',''})
		AADD(aRetCNAB, {'2','2','D','2','SEQ REG LOTE   ','009','013','0','                    ','.F.','185','',''})
		AADD(aRetCNAB, {'2','2','D','2','COD SEGM LOTE  ','014','014','0','SEGJ52              ','.F.','186','',''})
		AADD(aRetCNAB, {'2','2','D','2','TIPO MOVIMENTO ','015','017','0','                    ','.F.','187','',''})
		AADD(aRetCNAB, {'2','2','D','2','ID REG OPCIONAL','018','019','0','                    ','.F.','188','',''})
		AADD(aRetCNAB, {'2','2','D','2','TP INSC PAGADOR','020','020','0','                    ','.F.','189','',''})
		AADD(aRetCNAB, {'2','2','D','2','INSCR PAGADOR  ','021','035','0','                    ','.F.','190','',''})
		AADD(aRetCNAB, {'2','2','D','2','NOME PAGADOR   ','036','075','0','                    ','.F.','191','',''})
		AADD(aRetCNAB, {'2','2','D','2','TP INSC BENEFIC','076','076','0','                    ','.F.','192','',''})
		AADD(aRetCNAB, {'2','2','D','2','NRO INSC BENEFI','077','091','0','                    ','.F.','193','',''})
		AADD(aRetCNAB, {'2','2','D','2','NOME BENEFICIAR','092','131','0','                    ','.F.','194','',''})
		AADD(aRetCNAB, {'2','2','D','2','TP INSC SACADOR','132','132','0','                    ','.F.','195','',''})
		AADD(aRetCNAB, {'2','2','D','2','NRO INSC SACADO','133','147','0','                    ','.F.','196','',''})
		AADD(aRetCNAB, {'2','2','D','2','NOME SACADOR   ','148','187','0','                    ','.F.','197','',''})
		AADD(aRetCNAB, {'2','2','D','2','COMPL REGISTRO ','188','240','0','                    ','.F.','198','',''})

Return aRetCNAB 

