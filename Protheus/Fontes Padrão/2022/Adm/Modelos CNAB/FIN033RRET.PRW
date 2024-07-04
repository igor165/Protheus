#Include 'Protheus.ch' 

//------------------------------------------------------------------- 
/*/{Protheus.doc} FIN033RRET()
Rotina para construção de codigo fonte para geração de arquivo CNAB 

@author 
 
@since 28/12/2017  
@version TOTVS Série T Serviços MSSQL P12cnabttv  
/*/ 
//------------------------------------------------------------------- 
Function FIN033RRET()

	Local aRetCNAB    := {}

	//                     1       2       3       4       5       6       7       8        9
	//                     IDELIN, HEADET, CHALIN, IDESEG, DESMOV, POSINI, POSFIM, DECIMAL, CONARQ
	//    AADD(aRetCNAB, { ''    , ''    , ''    , ''    , ''    , ''    , ''    , ''     , ''     })

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ NIVEL 1                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aRetCNAB, {'1','0','H','' ,'HEADER DE ARQUIVO            ','.T.','','','','.F.','001','',''}) // 0H - HEADER DE ARQUIVO
	AADD(aRetCNAB, {'1','0','T','' ,'TRAILER  DE ARQUIVO          ','.T.','','','','.F.','002','',''}) // 0T - TRAILER DE ARQUIVO
	AADD(aRetCNAB, {'1','1','D','1','DETALHE SEGMENTO T           ','.T.','','','','.F.','003','',''}) // 1D1 - DETALHE SEGMENTO T
	AADD(aRetCNAB, {'1','1','D','2','DETALHE SEGMENTO U           ','.T.','','','','.F.','004','',''}) // 1D2 - DETALHE SEGMENTO U
	AADD(aRetCNAB, {'1','1','H','' ,'HEADER DE LOTE               ','.T.','','','','.F.','005','',''}) // 1H - HEADER DE LOTE
	AADD(aRetCNAB, {'1','1','T','' ,'TRAILER DE LOTE              ','.T.','','','','.F.','006','',''}) // 1T - TRAILER DE LOTE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ NIVEL 2                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	// 0H - HEADER DE ARQUIVO
	AADD(aRetCNAB, {'2','0','H','' ,'COD DO BANCO   ','001','003','0','                    ','.F.','007','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'LOTE SERVICO   ','004','007','0','                    ','.F.','008','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'TIPO REGISTRO  ','008','008','0','                    ','.F.','009','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'RESERVADO BCO  ','009','016','0','                    ','.F.','010','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'TIPO INSC EMPRE','017','017','0','                    ','.F.','011','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'NRO INSC EMPRES','018','032','0','                    ','.F.','012','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'AGENCIA CEDENTE','033','036','0','                    ','.F.','013','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'DV AGENCIA     ','037','037','0','                    ','.F.','014','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'NRO CTA CORRENT','038','046','0','                    ','.F.','015','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'DV CTA CORRENTE','047','047','0','                    ','.F.','016','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'RESERVADO BCO  ','048','052','0','                    ','.F.','017','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'CODIGO CEDENTE ','053','061','0','                    ','.F.','018','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'RESERVADO BCO  ','062','072','0','                    ','.F.','019','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'NOME DA EMPRESA','073','102','0','                    ','.F.','020','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'NOME BANCO     ','103','132','0','                    ','.F.','021','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'RESERVADO BCO  ','133','142','0','                    ','.F.','022','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'COD REM/RET    ','143','143','0','                    ','.F.','023','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'DT GERAC ARQ   ','144','151','0','                    ','.F.','024','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'RESERV USO BCO ','152','157','0','                    ','.F.','025','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'NRO SEQ ARQUIVO','158','163','0','                    ','.F.','026','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'VER LAYOUT ARQU','164','166','0','                    ','.F.','027','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'RESERVADO BCO  ','167','240','0','                    ','.F.','028','',''})

	// 0T - TRAILER DE ARQUIVO
	AADD(aRetCNAB, {'2','0','T','' ,'COD BANCO      ','001','003','0','                    ','.F.','029','',''})
	AADD(aRetCNAB, {'2','0','T','' ,'NRO LOTE REMESS','004','007','0','                    ','.F.','030','',''})
	AADD(aRetCNAB, {'2','0','T','' ,'TIPO REGISTRO  ','008','008','0','                    ','.F.','031','',''})
	AADD(aRetCNAB, {'2','0','T','' ,'RESERVADO BCO  ','009','017','0','                    ','.F.','032','',''})
	AADD(aRetCNAB, {'2','0','T','' ,'QUANT LOT ARQ  ','018','023','0','                    ','.F.','033','',''})
	AADD(aRetCNAB, {'2','0','T','' ,'QUANT REG ARQ  ','024','029','0','                    ','.F.','034','',''})
	AADD(aRetCNAB, {'2','0','T','' ,'RESERVADO BCO  ','030','240','0','                    ','.F.','035','',''})

	// 1H - HEADER DE LOTE
	AADD(aRetCNAB, {'2','1','H','' ,'COD BANCO      ','001','003','0','                    ','.F.','036','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'NRO LOTE RETORN','004','007','0','                    ','.F.','037','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'TIPO REGISTRO  ','008','008','0','                    ','.F.','038','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'TIPO OPERACAO  ','009','009','0','                    ','.F.','039','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'TIPO SERVICO   ','010','011','0','                    ','.F.','040','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'RESERVADO BCO  ','012','013','0','                    ','.F.','041','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'NRO VERS LOTE  ','014','016','0','                    ','.F.','042','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'RESERVADO BCO  ','017','017','0','                    ','.F.','043','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'TIPO INSC EMPRE','018','018','0','                    ','.F.','044','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'NUM INSC EMP   ','019','033','0','                    ','.F.','045','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'CODIGO CEDENTE ','034','042','0','                    ','.F.','046','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'RESERVADO BCO  ','043','053','0','                    ','.F.','047','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'AGENCIA CEDENTE','054','057','0','                    ','.F.','048','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'DV AGENCIA     ','058','058','0','                    ','.F.','049','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'NRO CTA CORREN ','059','067','0','                    ','.F.','050','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'DV CTA CORRENTE','068','068','0','                    ','.F.','051','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'RESERVADO BCO  ','069','073','0','                    ','.F.','052','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'NOME CEDENTE   ','074','103','0','                    ','.F.','053','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'RESERVADO BCO  ','104','183','0','                    ','.F.','054','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'NRO REMESSA    ','184','191','0','                    ','.F.','055','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'DATA GRAV REMES','192','199','0','                    ','.F.','056','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'RESERVADO BCO  ','200','240','0','                    ','.F.','057','',''})

	// 1T - TRAILER DE LOTE
	AADD(aRetCNAB, {'2','1','T','' ,'COD BANCO      ','001','003','0','                    ','.F.','058','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'NRO LOTE REMESS','004','007','0','                    ','.F.','059','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'TIPO REGISTRO  ','008','008','0','                    ','.F.','060','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'RESERVADO BCO  ','009','017','0','                    ','.F.','061','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'QUANT REG LOTE ','018','023','0','                    ','.F.','062','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'RESERVADO BCO  ','024','029','0','                    ','.F.','063','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'VLR TTL TIT SIM','030','046','2','                    ','.F.','064','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'QTD TIT VINCULA','047','052','0','                    ','.F.','065','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'VLR TTL TIT VIN','053','069','2','                    ','.F.','066','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'QTD TIT CAUCION','070','075','0','                    ','.F.','067','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'VLR TTL TIT CAU','076','092','2','                    ','.F.','068','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'QTD TIT DESCONT','093','098','0','                    ','.F.','069','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'VLR TTL TIT DES','099','115','2','                    ','.F.','070','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'NRO AVISO LACTO','116','123','0','                    ','.F.','071','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'RESERVADO BCO  ','124','240','0','                    ','.F.','072','',''})

	// 1D1 - DETALHE SEGMENTO T
	AADD(aRetCNAB, {'2','1','D','1','COD BANCO      ','001','003','0','                    ','.F.','073','',''})
	AADD(aRetCNAB, {'2','1','D','1','NRO LOTE RETORN','004','007','0','                    ','.F.','074','',''})
	AADD(aRetCNAB, {'2','1','D','1','TIPO REGISTRO  ','008','008','0','                    ','.F.','075','',''})
	AADD(aRetCNAB, {'2','1','D','1','NRO SEQ LOTE   ','009','013','0','                    ','.F.','076','',''})
	AADD(aRetCNAB, {'2','1','D','1','COD SEG DETALHE','014','014','0','SEGMENTO            ','.F.','077','',''})
	AADD(aRetCNAB, {'2','1','D','1','RESERV USO BCO ','015','015','0','                    ','.F.','078','',''})
	AADD(aRetCNAB, {'2','1','D','1','COD MOVIM OCORR','016','017','0','                    ','.F.','079','',''})
	AADD(aRetCNAB, {'2','1','D','1','AGENCIA CEDENTE','018','021','0','                    ','.F.','080','',''})
	AADD(aRetCNAB, {'2','1','D','1','DV AGENCIA     ','022','022','0','                    ','.F.','081','',''})
	AADD(aRetCNAB, {'2','1','D','1','NRO CTA CORRENT','023','031','0','                    ','.F.','082','',''})
	AADD(aRetCNAB, {'2','1','D','1','DV CTA CORRENTE','032','032','0','                    ','.F.','083','',''})
	AADD(aRetCNAB, {'2','1','D','1','RESERVADO BCO  ','033','040','0','                    ','.F.','084','',''})
	AADD(aRetCNAB, {'2','1','D','1','ID TITULO BANCO','041','053','0','NOSSONUMERO         ','.T.','085','{\"ZERAR POSICAO\",\"NOSSONUMERO\"}','{\"ZERAR POSICAO\",\"NOSSONUMERO\"}'})
	AADD(aRetCNAB, {'2','1','D','1','COD CARTEIRA   ','054','054','0','                    ','.F.','086','',''})
	AADD(aRetCNAB, {'2','1','D','1','NRO DOC COBRAN ','055','069','0','TITULO              ','.T.','087','{\"ZERAR POSICAO\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}','{\"ZERAR POSICAO\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}'})
	AADD(aRetCNAB, {'2','1','D','1','DT VENCTO TITUL','070','077','0','DATA                ','.T.','088','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}'})
	AADD(aRetCNAB, {'2','1','D','1','VLR NOM TITULO ','078','092','2','VALOR               ','.T.','089','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESA\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESA\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
	AADD(aRetCNAB, {'2','1','D','1','NRO BCO COBRAD ','093','095','0','                    ','.F.','090','',''})
	AADD(aRetCNAB, {'2','1','D','1','AG COBRADORA   ','096','099','0','                    ','.F.','091','',''})
	AADD(aRetCNAB, {'2','1','D','1','DV AGENCIA     ','100','100','0','                    ','.F.','092','',''})
	AADD(aRetCNAB, {'2','1','D','1','ID TITULO EMPRE','101','125','0','                    ','.F.','093','',''})
	AADD(aRetCNAB, {'2','1','D','1','CODIGO MOEDA   ','126','127','0','                    ','.F.','094','',''})
	AADD(aRetCNAB, {'2','1','D','1','TIPO INSC SACAD','128','128','0','                    ','.F.','095','',''})
	AADD(aRetCNAB, {'2','1','D','1','NRO INSC SACADO','129','143','0','                    ','.F.','096','',''})
	AADD(aRetCNAB, {'2','1','D','1','NOME SACADO    ','144','183','0','                    ','.F.','097','',''})
	AADD(aRetCNAB, {'2','1','D','1','CONTA COBRANC  ','184','193','0','                    ','.F.','098','',''})
	AADD(aRetCNAB, {'2','1','D','1','VLR TARIFAS CUS','194','208','2','                    ','.F.','099','',''})
	AADD(aRetCNAB, {'2','1','D','1','OCORRENCIAS    ','209','218','0','OCORRENCIA          ','.T.','100','{\"ZERAR POSICAO\",\"OCORRENCIA\"}','{\"ZERAR POSICAO\",\"OCORRENCIA\"}'})
	AADD(aRetCNAB, {'2','1','D','1','RESERVADO BCO  ','219','240','0','RESERVADO           ','.T.','101','{\"ZERAR POSICAO\",\"RESERVADO\"}','{\"ZERAR POSICAO\",\"RESERVADO\"}'})

	// 1D2 - DETALHE SEGMENTO U
	AADD(aRetCNAB, {'2','1','D','2','COD BANCO      ','001','003','0','                    ','.F.','102','',''})
	AADD(aRetCNAB, {'2','1','D','2','LOTE SERVICO   ','004','007','0','                    ','.F.','103','',''})
	AADD(aRetCNAB, {'2','1','D','2','TIPO REGISTRO  ','008','008','0','                    ','.F.','104','',''})
	AADD(aRetCNAB, {'2','1','D','2','NRO SEQ LOTE   ','009','013','0','                    ','.F.','105','',''})
	AADD(aRetCNAB, {'2','1','D','2','COD SEG DETALHE','014','014','0','SEGMENTO            ','.F.','106','',''})
	AADD(aRetCNAB, {'2','1','D','2','RESERVADO BCO  ','015','015','0','                    ','.F.','107','',''})
	AADD(aRetCNAB, {'2','1','D','2','COD MOV OCORREN','016','017','0','                    ','.F.','108','',''})
	AADD(aRetCNAB, {'2','1','D','2','JUROS MULTA ENC','018','032','2','JUROS               ','.T.','109','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESA\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESA\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
	AADD(aRetCNAB, {'2','1','D','2','VLR DESC CONCED','033','047','2','DESCONTO            ','.T.','110','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESA\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESA\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
	AADD(aRetCNAB, {'2','1','D','2','VLR ABAT CONCED','048','062','2','ABATIMENTO          ','.T.','111','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESA\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESA\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
	AADD(aRetCNAB, {'2','1','D','2','VLR IOF RECOLHI','063','077','2','IOF                 ','.T.','112','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESA\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESA\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
	AADD(aRetCNAB, {'2','1','D','2','VLR PAGO SACADO','078','092','2','VALOR               ','.T.','113','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESA\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESA\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
	AADD(aRetCNAB, {'2','1','D','2','VLR LIQ CREDITA','093','107','2','                    ','.T.','114','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESA\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESA\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
	AADD(aRetCNAB, {'2','1','D','2','VLR OUTR DESPES','108','122','2','                    ','.F.','115','',''})
	AADD(aRetCNAB, {'2','1','D','2','VLR OUTR CREDIT','123','137','2','DESPESA             ','.T.','116','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESA\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESA\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
	AADD(aRetCNAB, {'2','1','D','2','DATA OCORRENCIA','138','145','0','DATA                ','.T.','117','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}'})
	AADD(aRetCNAB, {'2','1','D','2','DATA EFET CREDI','146','153','0','DATACREDITO         ','.T.','118','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}'})
	AADD(aRetCNAB, {'2','1','D','2','CODIGO OCOR SAC','154','157','0','                    ','.F.','119','',''})
	AADD(aRetCNAB, {'2','1','D','2','DATA OCORR SACA','158','165','0','                    ','.F.','120','',''})
	AADD(aRetCNAB, {'2','1','D','2','VLR OCORR SACAD','166','180','0','                    ','.F.','121','',''})
	AADD(aRetCNAB, {'2','1','D','2','COMPL OCORR SAC','181','210','0','                    ','.F.','122','',''})
	AADD(aRetCNAB, {'2','1','D','2','COD BCO CORRESP','211','213','0','                    ','.F.','123','',''})
	AADD(aRetCNAB, {'2','1','D','2','RESERVADO BCO  ','214','240','0','RESERVADO           ','.T.','124','{\"ZERAR POSICAO\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}','{\"ZERAR POSICAO\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}'})

Return aRetCNAB 

