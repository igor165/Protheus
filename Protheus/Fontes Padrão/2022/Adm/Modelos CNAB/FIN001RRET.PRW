#Include 'Protheus.ch' 

//------------------------------------------------------------------- 
/*/{Protheus.doc} FIN001RRET()
Rotina para construção de codigo fonte para geração de arquivo CNAB 

@author 
 
@since 22/12/2017  
@version TOTVS Série T Serviços MSSQL P12cnabttv  
/*/ 
//------------------------------------------------------------------- 
Function FIN001RRET()

	Local aRetCNAB    := {}

	//                    1        2      3       4       5       6       7       8        9
	//                    IDELIN, HEADET, CHALIN, IDESEG, DESMOV, POSINI, POSFIM, DECIMAL, CONARQ
	//    AADD(aRetCNAB, {''    , ''    , ''    , ''    , ''    , ''    , ''    , ''     , ''     } )

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ NIVEL 1                 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aRetCNAB, {'1','0','H','' ,'HEADER DE ARQUIVO             ',''   ,'','','','.F.','001','',''})	// 0H - HEADER DE ARQUIVO
	AADD(aRetCNAB, {'1','0','T','' ,'TRAILER DE ARQUIVO            ',''   ,'','','','.F.','002','',''})	// 0T - TRAILER DE ARQUIVO
	AADD(aRetCNAB, {'1','1','D','1','DETALHE SEGMENTO T            ','T'  ,'','','','.F.','003','',''})	// 1D1 - DETALHE SEGMENTO T
	AADD(aRetCNAB, {'1','1','D','2','DETALHE SEGMENTO U            ','U'  ,'','','','.F.','004','',''})	// 1D2 - DETALHE SEGMENTO U
	AADD(aRetCNAB, {'1','1','H','' ,'HEADER DE LOTE                ',''   ,'','','','.F.','005','',''}) // 1H - HEADER DE LOTE
	AADD(aRetCNAB, {'1','1','T','' ,'TRAILER DE LOTE               ',''   ,'','','','.F.','006','',''}) // 1T - TRAILER DE LOTE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ NIVEL 2                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// 0H - HEADER DE ARQUIVO
		AADD(aRetCNAB, {'2','0','H','' ,'COD. BANCO COMP','001','003','0','                    ','.F.','007','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'LOTE DE SERVICO','004','007','0','                    ','.F.','008','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'REG. HEADER ARQ','008','008','0','                    ','.F.','009','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'USO EXCL CNAB  ','009','017','0','                    ','.F.','010','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'TIPO INSCR. EMP','018','018','0','                    ','.F.','011','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NRO  INSCR EMPR','019','032','0','                    ','.F.','012','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COD CONV BANCO ','033','041','0','                    ','.F.','013','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COD CEDENTE BB ','042','045','0','                    ','.F.','014','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NRO CART COB BB','046','047','0','                    ','.F.','015','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NRO VAR CART BB','048','050','0','                    ','.F.','016','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'USO EXCL BCO   ','051','052','0','                    ','.F.','017','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'AGENCIA MANTENE','053','057','0','                    ','.F.','018','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'DIGITO VER AGEN','058','058','0','                    ','.F.','019','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NRO CTA CORRENT','059','070','0','                    ','.F.','020','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'DIGITO VER CONT','071','071','0','                    ','.F.','021','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'DIGITO VER AG/C','072','072','0','                    ','.F.','022','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NOME EMPRESA   ','073','102','0','                    ','.F.','023','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NOME DO BANCO  ','103','132','0','                    ','.F.','024','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'USO EXCL CNAB  ','133','142','0','                    ','.F.','025','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'CODIGO REM/RET ','143','143','0','                    ','.F.','026','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'DT GER  ARQ    ','144','151','0','                    ','.F.','027','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'HR GER  ARQ    ','152','157','0','                    ','.F.','028','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NRO SEQ ARQ    ','158','163','0','                    ','.F.','029','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NRO VER LAYOUT ','164','166','0','                    ','.F.','030','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'DENS. GRAV. ARQ','167','171','0','                    ','.F.','031','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'PARA USO BANCO ','172','191','0','                    ','.F.','032','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'PARA USO EMPRES','192','211','0','                    ','.F.','033','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'USO FEBRA/CNAB3','212','240','0','                    ','.F.','034','',''})

	// 0T - TRAILER DE ARQUIVO
		AADD(aRetCNAB, {'2','0','T','' ,'COD BCO COMPENS','001','003','0','                    ','.F.','035','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'LOTE SERVICO   ','004','007','0','                    ','.F.','036','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'REG TRAIL ARQUI','008','008','0','                    ','.F.','037','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'USO FEBRA/CNAB1','009','017','0','                    ','.F.','038','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'QTD LOTES ARQUI','018','023','0','                    ','.F.','039','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'QTD REG ARQUIVO','024','029','0','                    ','.F.','040','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'QTD CONTAS CONC','030','035','0','                    ','.F.','041','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'USO EXCL CNAB  ','036','240','','                     ','.F.','042','',''})

 	// 1H - HEADER DE LOTE
		AADD(aRetCNAB, {'2','1','H','' ,'COD BCO COMPENS','001','003','0','                    ','.F.','043','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'LOTE DE SERVICO','004','007','0','                    ','.F.','044','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'REG HEADER LOTE','008','008','0','                    ','.F.','045','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'TIPO OPERACAO  ','009','009','0','                    ','.F.','046','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'TIPO SERVICO   ','010','011','0','                    ','.F.','047','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'USO EXCL CNAB  ','012','013','0','                    ','.F.','048','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'NRO VER LAYOUT ','014','016','0','                    ','.F.','049','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'USO EXCL CNAB  ','017','017','0','                    ','.F.','050','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'TIPO INSC EMPRE','018','018','0','                    ','.F.','051','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'NO. INSCR EMPRE','019','033','0','                    ','.F.','052','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'COD CONV BCO   ','034','053','0','                    ','.F.','053','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'AGENCIA MAN CON','054','058','0','                    ','.F.','054','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'DIGIT VER AGENC','059','059','0','                    ','.F.','055','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'NO. CONTA CORRE','060','071','0','                    ','.F.','056','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'DIGIT VER CONTA','072','072','0','                    ','.F.','057','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'DIGIT VER AG/CO','073','073','0','                    ','.F.','058','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'NOME DA EMPRESA','074','103','0','                    ','.F.','059','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'MENSAGEM 1     ','104','143','0','                    ','.F.','060','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'MENSAGEM 2     ','144','183','0','                    ','.F.','061','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'NRO REM / RET  ','184','191','0','                    ','.F.','062','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'DT GRAV REM/RET','192','199','0','                    ','.F.','063','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'DATA CREDITO   ','200','207','0','                    ','.F.','064','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'USO EXCL CNAB  ','208','240','0','                    ','.F.','065','',''})

 	// 1T - TRAILER DE LOTE
		AADD(aRetCNAB, {'2','1','T','' ,'COD BCO COMPENS','001','003','0','                    ','.F.','066','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'LOTE SERVICO   ','004','007','0','                    ','.F.','067','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'REG. TRAIL LOTE','008','008','0','                    ','.F.','068','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'USO EXCL CNAB  ','009','017','0','                    ','.F.','069','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'QTD REG. LOTE  ','018','023','0','                    ','.F.','070','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'ZEROS          ','024','240','0','                    ','.F.','071','',''})

	// 1D2 - DETALHE SEGMENTO U
		AADD(aRetCNAB, {'2','1','D','2','COD BCO COMPENS','001','003','0','                    ','.F.','072','',''})
		AADD(aRetCNAB, {'2','1','D','2','LOTE SERVICO   ','004','007','0','                    ','.F.','073','',''})
		AADD(aRetCNAB, {'2','1','D','2','TIPO REGISTRO  ','008','008','0','                    ','.F.','074','',''})
		AADD(aRetCNAB, {'2','1','D','2','NRO SEQ LOTE   ','009','013','0','                    ','.F.','075','',''})
		AADD(aRetCNAB, {'2','1','D','2','COD SEG DETALHE','014','014','0','SEGMENTO            ','.F.','076','',''})
		AADD(aRetCNAB, {'2','1','D','2','USO EXCL CNAB  ','015','015','0','                    ','.F.','077','',''})
		AADD(aRetCNAB, {'2','1','D','2','CODIGO MOVIMENT','016','017','0','                    ','.F.','078','',''})
		AADD(aRetCNAB, {'2','1','D','2','JUROS MULTA ENC','018','032','2','JUROS               ','.T.','079','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR DESC CONCED','033','047','2','DESCONTO            ','.T.','080','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR ABAT CONCED','048','062','2','ABATIMENTO          ','.T.','081','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR IOF RECOLHI','063','077','2','IOF                 ','.T.','082','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR PAGO SACADO','078','092','2','VALOR               ','.T.','083','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR LIQ CREDITA','093','107','2','                    ','.T.','084','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR OUT DESPESA','108','122','2','DESPESA             ','.F.','085','',''})
		AADD(aRetCNAB, {'2','1','D','2','VLR OUT CREDITO','123','137','2','OUTROSCREDITOS      ','.T.','086','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','DATA OCORRENCIA','138','145','0','DATA                ','.T.','087','{\"ZERAR VARIAVEL\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR VARIAVEL\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','1','D','2','DT EFET CREDITO','146','153','0','DATACREDITO         ','.T.','088','{\"ZERAR VARIAVEL\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR VARIAVEL\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','1','D','2','COD OCORRENCIAS','154','157','0','OCORRENCIA          ','.T.','089','{\"ZERAR VARIAVEL\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}','{\"ZERAR VARIAVEL\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}'})
		AADD(aRetCNAB, {'2','1','D','2','DATA OCORRENCIA','158','165','0','DATA                ','.T.','090','{\"ZERAR VARIAVEL\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR VARIAVEL\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR OCORRENCIA ','166','180','2','VALOR               ','.T.','091','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','COMPL OCORRENCI','181','210','0','                    ','.F.','092','',''})
		AADD(aRetCNAB, {'2','1','D','2','COD BCO COR COM','211','213','0','                    ','.F.','093','',''})
		AADD(aRetCNAB, {'2','1','D','2','NOSSO NRO BCO  ','214','233','0','NOSSONUMERO         ','.T.','094','{\"ZERAR VARIAVEL\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}','{\"ZERAR VARIAVEL\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}'})
		AADD(aRetCNAB, {'2','1','D','2','USO EXCL CNAB  ','234','240','0','RESERVADO           ','.T.','095','{\"ZERAR VARIAVEL\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}','{\"ZERAR VARIAVEL\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}'})

	// 1D1 - DETALHE SEGMENTO T
		AADD(aRetCNAB, {'2','1','D','1','COD BCO COMPENS','001','003','0','                    ','.F.','096','',''})
		AADD(aRetCNAB, {'2','1','D','1','LOTE DE SERVICO','004','007','0','                    ','.F.','097','',''})
		AADD(aRetCNAB, {'2','1','D','1','REGISTRO DETALH','008','008','0','                    ','.F.','098','',''})
		AADD(aRetCNAB, {'2','1','D','1','NRO SEQ LOTE   ','009','013','0','                    ','.F.','099','',''})
		AADD(aRetCNAB, {'2','1','D','1','COD SEG DETALHE','014','014','0','SEGMENTO            ','.F.','100','',''})
		AADD(aRetCNAB, {'2','1','D','1','USO EXCL CNAB  ','015','015','0','                    ','.F.','101','',''})
		AADD(aRetCNAB, {'2','1','D','1','COD MOV REMESSA','016','017','0','                    ','.F.','102','',''})
		AADD(aRetCNAB, {'2','1','D','1','AGENCIA MANTENE','018','022','0','                    ','.F.','103','',''})
		AADD(aRetCNAB, {'2','1','D','1','DIGIT VERIF AGE','023','023','0','                    ','.F.','104','',''})
		AADD(aRetCNAB, {'2','1','D','1','NRO CTA CORRENT','024','035','0','                    ','.F.','105','',''})
		AADD(aRetCNAB, {'2','1','D','1','DIGIT VERIF CON','036','036','0','                    ','.F.','106','',''})
		AADD(aRetCNAB, {'2','1','D','1','DIGIT VER AG/CO','037','037','0','                    ','.F.','107','',''})
		AADD(aRetCNAB, {'2','1','D','1','IDENT. TIT. BCO','038','057','0','NOSSONUMERO         ','.T.','108','{\"ZERAR VARIAVEL\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}','{\"ZERAR VARIAVEL\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}'})
		AADD(aRetCNAB, {'2','1','D','1','COD CARTEIRA   ','058','058','0','                    ','.F.','109','',''})
		AADD(aRetCNAB, {'2','1','D','1','NRO DOC COBRANC','059','073','0','                    ','.T.','110','{\"ZERAR VARIAVEL\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}','{\"ZERAR VARIAVEL\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}'})
		AADD(aRetCNAB, {'2','1','D','1','DT VENCTO TITUL','074','081','0','DATA                ','.T.','111','{\"ZERAR VARIAVEL\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR VARIAVEL\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','1','D','1','VLR NOMIN TITUL','082','096','2','VALOR               ','.T.','112','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','1','NRO BANCO      ','097','099','0','                    ','.F.','113','',''})
		AADD(aRetCNAB, {'2','1','D','1','AG COBR RECEBED','100','104','0','                    ','.F.','114','',''})
		AADD(aRetCNAB, {'2','1','D','1','DV AGENCIA     ','105','105','0','                    ','.F.','115','',''})
		AADD(aRetCNAB, {'2','1','D','1','ID TITULO EMPRE','106','130','0','TITULO              ','.T.','116','{\"ZERAR VARIAVEL\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}','{\"ZERAR VARIAVEL\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}'})
		AADD(aRetCNAB, {'2','1','D','1','CODIGO MOEDA   ','131','132','0','                    ','.F.','117','',''})
		AADD(aRetCNAB, {'2','1','D','1','TIPO INSCRICAO ','133','133','0','                    ','.F.','118','',''})
		AADD(aRetCNAB, {'2','1','D','1','NRO INSCRICAO  ','134','148','0','                    ','.F.','119','',''})
		AADD(aRetCNAB, {'2','1','D','1','NOME           ','149','188','0','                    ','.F.','120','',''})
		AADD(aRetCNAB, {'2','1','D','1','NRO CONT OP CRE','189','198','0','                    ','.F.','121','',''})
		AADD(aRetCNAB, {'2','1','D','1','VLR TARIFA CUST','199','213','2','                    ','.F.','122','',''})
		AADD(aRetCNAB, {'2','1','D','1','ID REJEI TAR CU','214','223','0','OCORRENCIA          ','.F.','123','',''})
		AADD(aRetCNAB, {'2','1','D','1','USO EXCL CNAB  ','224','240','0','RESERVADO           ','.T.','124','{\"ZERAR VARIAVEL\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}','{\"ZERAR VARIAVEL\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}'})

Return aRetCNAB 

