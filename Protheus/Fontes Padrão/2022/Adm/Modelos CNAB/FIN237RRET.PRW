#Include 'Protheus.ch' 

//------------------------------------------------------------------- 
/*/{Protheus.doc} FIN237RRET()
Rotina para construção de codigo fonte para geração de arquivo CNAB 

@author 
 
@since 28/12/2017  
@version TOTVS Série T Serviços MSSQL P12cnabttv  
/*/ 
//------------------------------------------------------------------- 
Function FIN237RRET()

	Local aRetCNAB    := {}

	//                    1        2      3       4       5       6       7         8        9
	//                    IDELIN, HEADET, CHALIN, IDESEG, DESMOV, POSINI, POSFIM, DECIMAL, CONARQ
	//    AADD(aRetCNAB, {''    , ''    , ''    , ''    , ''    , ''    , ''    , ''     , ''      } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ NIVEL 1                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aRetCNAB, {'1','0','H','' ,'HEADER DE ARQUIVO            ',''  ,'','','','.F.','001','',''})	// 0H - HEADER DE ARQUIVO
	AADD(aRetCNAB, {'1','0','T','' ,'TRAILER ARQUIVO              ',''  ,'','','','.F.','002','',''})	// 0T - TRAILER DE ARQUIVO
	AADD(aRetCNAB, {'1','1','D','1','DETALHE SEGMENTO T           ','T' ,'','','','.F.','003','',''})	// 1D1 - DETALHE SEGMENTO P
	AADD(aRetCNAB, {'1','1','D','2','DETALHE SEGMENTO U           ','U' ,'','','','.F.','004','',''})	// 1D2 - DETALHE SEGMENTO Q
	AADD(aRetCNAB, {'1','1','H','' ,'HEADER DE LOTE               ',''  ,'','','','.F.','005','',''})	// 1H - HEADER DE LOTE
	AADD(aRetCNAB, {'1','1','T','' ,'TRAILER DE LOTE              ',''  ,'','','','.F.','006','',''})	// 1T - TRAILER DE LOTE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ NIVEL 2                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// 0H - HEADER DE ARQUIVO
	AADD(aRetCNAB, {'2','0','H','' ,'COD BANCO      ','001','003','0','                    ','.F.','007','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'LOTE SERVICO   ','004','007','0','                    ','.F.','008','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'TIPO REGISTRO  ','008','008','0','                    ','.F.','009','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'RESERVADO BANCO','009','017','0','                    ','.F.','010','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'TP INSCR EMPRES','018','018','0','                    ','.F.','011','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'NUM INSC EMPRES','019','032','0','                    ','.F.','012','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'CONVENIO  BCO  ','033','052','0','                    ','.F.','013','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'AGENCIA MANTENE','053','057','0','                    ','.F.','014','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'DV AGENCIA     ','058','058','0','                    ','.F.','015','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'NRO CTA CORRENT','059','070','0','                    ','.F.','016','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'DV CONTA       ','071','071','0','                    ','.F.','017','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'DV AG/CONTA    ','072','072','0','                    ','.F.','018','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'NOME DO CLIENTE','073','102','0','                    ','.F.','019','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'NOME DO BANCO  ','103','132','0','                    ','.F.','020','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'USO EXCL CNAB  ','133','142','0','                    ','.F.','021','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'COD REMESSA    ','143','143','0','                    ','.F.','022','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'DATA GER ARQUIV','144','151','0','                    ','.F.','023','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'HORA GER ARQUIV','152','157','0','                    ','.F.','024','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'NUM SEQ ARQUIVO','158','163','0','                    ','.F.','025','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'NUM VERSAO ARQU','164','166','0','                    ','.F.','026','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'DENS GARV ARQUI','167','171','0','                    ','.F.','027','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'RESERVADO BCO  ','172','191','0','                    ','.F.','028','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'RESERVADO EMPRE','192','211','0','                    ','.F.','029','',''})
	AADD(aRetCNAB, {'2','0','H','' ,'USO EXCL CNAB  ','212','240','0','                    ','.F.','030','',''})

	// 0T - TRAILER DE ARQUIVO
	AADD(aRetCNAB, {'2','0','T','' ,'COD BCO COMP   ','001','003','0','                    ','.F.','031','',''})
	AADD(aRetCNAB, {'2','0','T','' ,'LOTE DE SERVICO','004','007','0','                    ','.F.','032','',''})
	AADD(aRetCNAB, {'2','0','T','' ,'TIPO REGISTRO  ','008','008','0','                    ','.F.','033','',''})
	AADD(aRetCNAB, {'2','0','T','' ,'CNAB           ','009','017','0','                    ','.F.','034','',''})
	AADD(aRetCNAB, {'2','0','T','' ,'QTDE LOTE      ','018','023','0','                    ','.F.','035','',''})
	AADD(aRetCNAB, {'2','0','T','' ,'QTDE REG ARQUIV','024','029','0','                    ','.F.','036','',''})
	AADD(aRetCNAB, {'2','0','T','' ,'QTDE CONTAS    ','030','035','0','                    ','.F.','037','',''})
	AADD(aRetCNAB, {'2','0','T','' ,'USO FEBRABAN   ','036','240','0','                    ','.F.','038','',''})

	// 1H - HEADER DE LOTE
	AADD(aRetCNAB, {'2','1','H','' ,'BANCO          ','001','003','0','                    ','.F.','039','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'LOTE SERVICO   ','004','007','0','                    ','.F.','040','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'TIPO REGISTRO  ','008','008','0','                    ','.F.','041','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'TIPO OPERACAO  ','009','009','0','                    ','.F.','042','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'TIPO SERVICO   ','010','011','0','                    ','.F.','043','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'USO EXCL CNAB  ','012','013','0','                    ','.F.','044','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'LAYOUT LOTE    ','014','016','0','                    ','.F.','045','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'USO EXCL CNAB  ','017','017','0','                    ','.F.','046','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'TIPO INSCRICAO ','018','018','0','                    ','.F.','047','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'CGC / CPF      ','019','033','0','                    ','.F.','048','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'COD DO CONVENIO','034','053','0','                    ','.F.','049','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'AGENCIA        ','054','058','0','                    ','.F.','050','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'DV AGENCIA     ','059','059','0','                    ','.F.','051','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'CONTA          ','060','071','0','                    ','.F.','052','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'DV AGENCIA     ','072','072','0','                    ','.F.','053','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'DV AG/CONTA    ','073','073','0','                    ','.F.','054','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'NOME EMPRESA   ','074','103','0','                    ','.F.','055','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'MENSAGEM 1     ','104','143','0','                    ','.F.','056','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'MENSAGEM 2     ','144','183','0','                    ','.F.','057','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'NUM SEQ REMESSA','184','191','0','                    ','.F.','058','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'DATA GRAVACAO  ','192','199','0','                    ','.F.','059','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'DATA CREDITO   ','200','207','0','                    ','.F.','060','',''})
	AADD(aRetCNAB, {'2','1','H','' ,'USO FEBRABAN   ','208','240','0','                    ','.F.','061','',''})

	// 1H - TRAILER DE LOTE
	AADD(aRetCNAB, {'2','1','T','' ,'BANCO          ','001','003','0','                    ','.F.','062','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'LOTE SERVICO   ','004','007','0','                    ','.F.','063','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'TIPO RESGISTRO ','008','008','0','                    ','.F.','064','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'USO EXCL CNAB  ','009','017','0','                    ','.F.','065','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'QTDE REG LOTE  ','018','023','0','                    ','.F.','066','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'QTD TIT SIMPLES','024','029','0','                    ','.F.','067','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'VLR TTL SIMPLES','030','046','2','                    ','.F.','068','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'QTD TIT VINCULA','047','052','0','                    ','.F.','069','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'VLR TIT VINCULA','053','069','2','                    ','.F.','070','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'QTD TIT CAUCION','070','075','0','                    ','.F.','071','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'VLR TIT CAUCION','076','092','2','                    ','.F.','072','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'QTD TIT DESCONT','093','098','0','                    ','.F.','073','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'VLR TIT DESCONT','099','115','2','                    ','.F.','074','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'NRO AVISO LACTO','116','123','0','                    ','.F.','075','',''})
	AADD(aRetCNAB, {'2','1','T','' ,'USO EXCL CNAB  ','124','240','0','                    ','.F.','076','',''})

	// 1D1 - DETALHE SEGMENTO P
	AADD(aRetCNAB, {'2','1','D','1','COD BCO COMP   ','001','003','0','                    ','.F.','077','',''})
	AADD(aRetCNAB, {'2','1','D','1','LOTE SERVICO   ','004','007','0','                    ','.F.','078','',''})
	AADD(aRetCNAB, {'2','1','D','1','TIPO REGISTRO  ','008','008','0','                    ','.F.','079','',''})
	AADD(aRetCNAB, {'2','1','D','1','NUN SEQ LOTE   ','009','013','0','                    ','.F.','080','',''})
	AADD(aRetCNAB, {'2','1','D','1','COD SEG REGISTR','014','014','0','SEGMENTO            ','.F.','081','',''})
	AADD(aRetCNAB, {'2','1','D','1','RESERVADO BANCO','015','015','0','                    ','.F.','082','',''})
	AADD(aRetCNAB, {'2','1','D','1','COD MOV RETORNO','016','017','0','                    ','.F.','083','',''})
	AADD(aRetCNAB, {'2','1','D','1','AGENCIA        ','018','022','0','                    ','.F.','084','',''})
	AADD(aRetCNAB, {'2','1','D','1','DV AGENCIA     ','023','023','0','                    ','.F.','085','',''})
	AADD(aRetCNAB, {'2','1','D','1','CONTA CORRENTE ','024','035','0','                    ','.F.','086','',''})
	AADD(aRetCNAB, {'2','1','D','1','DV CONTA       ','036','036','0','                    ','.F.','087','',''})
	AADD(aRetCNAB, {'2','1','D','1','DV AG/CONTA    ','037','037','0','                    ','.F.','088','',''})
	AADD(aRetCNAB, {'2','1','D','1','ID TITULO      ','038','057','0','NOSSONUMERO         ','.F.','089','',''})
	AADD(aRetCNAB, {'2','1','D','1','CODIGO DA CART ','058','058','0','                    ','.F.','090','',''})
	AADD(aRetCNAB, {'2','1','D','1','NRO DOC COBRAN ','059','073','0','TITULO              ','.F.','091','',''})
	AADD(aRetCNAB, {'2','1','D','1','DATA VENCTO TIT','074','081','0','                    ','.T.','092','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}'})
	AADD(aRetCNAB, {'2','1','D','1','VLR NOM TITULO ','082','096','2','VALOR               ','.T.','093','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
	AADD(aRetCNAB, {'2','1','D','1','NRO BANCO      ','097','099','0','                    ','.F.','094','',''})
	AADD(aRetCNAB, {'2','1','D','1','AGENCIA COBRADO','100','104','0','                    ','.F.','095','',''})
	AADD(aRetCNAB, {'2','1','D','1','DV AGENCIA     ','105','105','0','                    ','.F.','096','',''})
	AADD(aRetCNAB, {'2','1','D','1','ID TIT EMPRESA ','106','130','0','                    ','.F.','097','',''})
	AADD(aRetCNAB, {'2','1','D','1','CODIGO MOEDA   ','131','132','0','                    ','.F.','098','',''})
	AADD(aRetCNAB, {'2','1','D','1','TIPO INSCRICAO ','133','133','0','                    ','.F.','099','',''})
	AADD(aRetCNAB, {'2','1','D','1','NRO INSCRICAO  ','134','148','0','                    ','.F.','100','',''})
	AADD(aRetCNAB, {'2','1','D','1','NOME           ','149','188','0','                    ','.F.','101','',''})
	AADD(aRetCNAB, {'2','1','D','1','NRO CONT OP CRE','189','198','0','                    ','.F.','102','',''})
	AADD(aRetCNAB, {'2','1','D','1','VLR TARIFA CUST','199','213','2','                    ','.F.','103','',''})
	AADD(aRetCNAB, {'2','1','D','1','ID REJ TAR CUS ','214','223','0','                    ','.F.','104','',''})
	AADD(aRetCNAB, {'2','1','D','1','USO ESCL CNAB  ','224','240','0','                    ','.F.','105','',''})

	// 1D2 - DETALHE SEGMENTO Q
	AADD(aRetCNAB, {'2','1','D','2','COD BCO COMP   ','001','003','0','                    ','.F.','106','',''})
	AADD(aRetCNAB, {'2','1','D','2','LOTE SERVICO   ','004','007','0','                    ','.F.','107','',''})
	AADD(aRetCNAB, {'2','1','D','2','TIPO REGISTRO  ','008','008','0','                    ','.F.','108','',''})
	AADD(aRetCNAB, {'2','1','D','2','NUN SEQ LOTE   ','009','013','0','                    ','.F.','109','',''})
	AADD(aRetCNAB, {'2','1','D','2','COD SEG REGISTR','014','014','0','                    ','.F.','110','',''})
	AADD(aRetCNAB, {'2','1','D','2','USO EXCL CNAB  ','015','015','0','                    ','.F.','111','',''})
	AADD(aRetCNAB, {'2','1','D','2','COD MOV RETORNO','016','017','0','                    ','.F.','112','',''})
	AADD(aRetCNAB, {'2','1','D','2','JUROS MULTA    ','018','032','2','JUROS + MULTA       ','.T.','113','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
	AADD(aRetCNAB, {'2','1','D','2','VLR DESC CONCED','033','047','2','DESCONTO            ','.T.','114','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
	AADD(aRetCNAB, {'2','1','D','2','VLR ABAT CONCED','048','062','2','ABATIMENTO          ','.T.','115','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
	AADD(aRetCNAB, {'2','1','D','2','VLR IOF RECOLHI','063','077','2','IOF                 ','.T.','116','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
	AADD(aRetCNAB, {'2','1','D','2','VLR PAGO PAGADO','078','092','2','VALOR               ','.T.','117','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
	AADD(aRetCNAB, {'2','1','D','2','VLR LIQ CREDITA','093','107','2','VALOR               ','.T.','118','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
	AADD(aRetCNAB, {'2','1','D','2','VLR OUTRAS DESP','108','122','2','                    ','.F.','119','',''})
	AADD(aRetCNAB, {'2','1','D','2','VLR OUTROS CRED','123','137','2','OUTROSCREDITOS      ','.T.','120','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
	AADD(aRetCNAB, {'2','1','D','2','DATA OCORRENCIA','138','145','0','DATA                ','.T.','121','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}'})
	AADD(aRetCNAB, {'2','1','D','2','DATA EFETIV CRE','146','153','0','DATACREDITO         ','.T.','122','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}'})
	AADD(aRetCNAB, {'2','1','D','2','CODIGO OCORRENC','154','157','0','                    ','.F.','123','',''})
	AADD(aRetCNAB, {'2','1','D','2','DATA OCORRENCIA','158','165','0','DATA                ','.T.','124','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR POSICAO\",\"DATA\",\"DATACREDITO\"}'})
	AADD(aRetCNAB, {'2','1','D','2','VALOR OCORRENCI','166','180','2','VALOR               ','.T.','125','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR POSICAO\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
	AADD(aRetCNAB, {'2','1','D','2','COMPL OCORRENCI','181','210','0','                    ','.F.','126','',''})
	AADD(aRetCNAB, {'2','1','D','2','COD BCO COMPENS','211','213','0','                    ','.F.','127','',''})
	AADD(aRetCNAB, {'2','1','D','2','NOSSO NRO BCO  ','214','233','0','NOSSONUMERO         ','.T.','128','{\"ZERAR POSICAO\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}','{\"ZERAR POSICAO\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}'})
	AADD(aRetCNAB, {'2','1','D','2','USO EXCL CNAB  ','234','240','0','OCORRENCIA          ','.T.','129','{\"ZERAR POSICAO\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}','{\"ZERAR POSICAO\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}'})

Return aRetCNAB 

