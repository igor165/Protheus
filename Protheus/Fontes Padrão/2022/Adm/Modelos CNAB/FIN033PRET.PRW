#Include 'Protheus.ch' 

//------------------------------------------------------------------- 
/*/{Protheus.doc} FIN033PRET()
Rotina para construção de codigo fonte para geração de arquivo CNAB 

@author 
 
@since 22/12/2017  
@version TOTVS Série T Serviços MSSQL P12cnabttv  
/*/ 
//------------------------------------------------------------------- 
Function FIN033PRET()

	Local aRetCNAB    := {}

	//                     1       2       3       4       5       6       7       8        9
	//                     IDELIN, HEADET, CHALIN, IDESEG, DESMOV, POSINI, POSFIM, DECIMAL, CONARQ
	//    AADD(aRetCNAB, { ''    , ''    , ''    , ''    , ''    , ''    , ''    , ''     , ''     } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ NIVEL 1                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aRetCNAB, {'1','0','H','' ,'HEADER DE ARQUIVO             ','.T.','','','','.F.','001','',''}) // 0H - HEADER DE ARQUIVO
	AADD(aRetCNAB, {'1','0','T','' ,'TRAILER ARQUIVO               ','.T.','','','','.F.','002','',''}) // 0T - TRAILER DE ARQUIVO
	AADD(aRetCNAB, {'1','1','D','1','DETALHE SEGMENTO A            ','.T.','','','','.F.','003','',''}) // 1D1 - DETALHE SEGMENTO A
	AADD(aRetCNAB, {'1','1','D','2','DETALHE SEGMENTO B            ','.T.','','','','.F.','004','',''}) // 1D2 - DETALHE SEGMENTO B
	AADD(aRetCNAB, {'1','1','H','' ,'HEADER DE LOTE A/B            ','.T.','','','','.F.','005','',''}) // 1H - HEADER DE LOTE A/B
	AADD(aRetCNAB, {'1','1','T','' ,'TRAILER DE LOTE A/B           ','.T.','','','','.F.','006','',''}) // 1T - TRAILER DE LOTE A/B
	AADD(aRetCNAB, {'1','2','D','1','DETALHE SEGMENTO J            ','.T.','','','','.F.','007','',''}) // 2D1 - DETALHE SEGMENTO J
	AADD(aRetCNAB, {'1','2','D','2','DETALHE SEGMENTO J-52         ','.T.','','','','.F.','008','',''}) // 2D2 - DETALHE SEGMENTO J-52
	AADD(aRetCNAB, {'1','2','H','' ,'HEADER DE LOTE J / J52        ','.T.','','','','.F.','009','',''}) // 2H - HEADER DE LOTE J / J52
	AADD(aRetCNAB, {'1','2','T','' ,'TRAILER DE LOTE J / J52       ','.T.','','','','.F.','010','',''}) // 2T - TRAILER DE LOTE J / J52

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ NIVEL 2                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	// 0H - HEADER DE ARQUIVO
		AADD(aRetCNAB, {'2','0','H','' ,'COD DO BANCO   ','001','003','0','                    ','.F.','011','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'LOTE DE SERV   ','004','007','0','                    ','.F.','012','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'TP SERVICO     ','008','008','0','                    ','.F.','013','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'USO EXCL CNAB  ','009','017','0','                    ','.F.','014','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'TP INSC EMPRESA','018','018','0','                    ','.F.','015','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NUM INSC EMP   ','019','032','0','                    ','.F.','016','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COD CONVENIO BC','033','052','0','                    ','.F.','017','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'AG MANT CONTA  ','053','057','0','                    ','.F.','018','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'DV AGENCIA     ','058','058','0','                    ','.F.','019','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'CONTA CORRENTE ','059','070','0','                    ','.F.','020','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'DV CONTA       ','071','072','0','                    ','.F.','021','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NOME DA EMPRESA','073','102','0','                    ','.F.','022','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NOME BANCO     ','103','132','0','                    ','.F.','023','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'USO EXCL CNAB  ','133','142','0','                    ','.F.','024','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'COD REMESSA    ','143','143','0','                    ','.F.','025','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'DT GERAC ARQ   ','144','151','0','                    ','.F.','026','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'HORA GR ARQ    ','152','157','0','                    ','.F.','027','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'NUM SEQ ARQ    ','158','163','0','                    ','.F.','028','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'VERSAO LAY-OUT ','164','166','0','                    ','.F.','029','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'DENSID GRV ARQ ','167','171','0','                    ','.F.','030','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'RESERVADO BCO  ','172','191','0','                    ','.F.','031','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'USO RESERV EMPR','192','211','0','                    ','.F.','032','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'USO EXCL CNAB  ','212','230','0','                    ','.F.','033','',''})
		AADD(aRetCNAB, {'2','0','H','' ,'OCORRENCIAS    ','231','240','0','                    ','.F.','034','',''})

	// 0T - TRAILER DE ARQUIVO
		AADD(aRetCNAB, {'2','0','T','' ,'COD BANCO      ','001','003','0','                    ','.F.','035','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'LOTE SERVICO   ','004','007','0','                    ','.F.','036','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'TIPO REGISTRO  ','008','008','0','                    ','.F.','037','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'USO EXCL CNAB  ','009','017','0','                    ','.F.','038','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'QUANT LOT ARQ  ','018','023','0','                    ','.F.','039','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'QUANT REG ARQ  ','024','029','0','                    ','.F.','040','',''})
		AADD(aRetCNAB, {'2','0','T','' ,'USO EXCL CNAB  ','030','240','0','                    ','.F.','041','',''})

	// 1H - HEADER DE LOTE A/B
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
		AADD(aRetCNAB, {'2','1','H','' ,'NRO AGENCIA    ','053','057','0','                    ','.F.','053','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'DV AGENCIA     ','058','058','0','                    ','.F.','054','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'NRO CTA CORRENT','059','070','0','                    ','.F.','055','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'DV CONTA       ','071','072','0','                    ','.F.','056','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'NOME EMPRESA   ','073','102','0','                    ','.F.','057','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'MENSAGEM 1     ','103','142','0','                    ','.F.','058','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'ENDEREÇO       ','143','172','0','                    ','.F.','059','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'NUMERO         ','173','177','0','                    ','.F.','060','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'COMPLEMENTO    ','178','192','0','                    ','.F.','061','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'CIDADE         ','193','212','0','                    ','.F.','062','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'CEP            ','213','220','0','                    ','.F.','063','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'UNID FEDERATIVA','221','222','0','                    ','.F.','064','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'USO EXCL CNAB  ','223','230','0','                    ','.F.','065','',''})
		AADD(aRetCNAB, {'2','1','H','' ,'OCORRENCIA     ','231','240','0','                    ','.F.','066','',''})

	// 1T - TRAILER DE LOTE A/B
		AADD(aRetCNAB, {'2','1','T','' ,'COD BANCO      ','001','003','0','                    ','.F.','067','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'LOTE SERV      ','004','007','0','                    ','.F.','068','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'TP DE REG      ','008','008','0','                    ','.F.','069','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'USO EXCL CNAB  ','009','017','0','                    ','.F.','070','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'QUANT DE REG   ','018','023','0','                    ','.F.','071','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'SOMAT VLR      ','024','041','0','                    ','.F.','072','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'SOMAT QTD MOED ','042','059','0','                    ','.F.','073','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'NRO AVISO DEBTO','060','065','0','                    ','.F.','074','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'USO EXCL CNAB  ','066','230','0','                    ','.F.','075','',''})
		AADD(aRetCNAB, {'2','1','T','' ,'OCORRENCIAS    ','231','240','0','                    ','.F.','076','',''})

	// 2H - HEADER DE LOTE J / J52
		AADD(aRetCNAB, {'2','2','H','' ,'COD BANCO      ','001','003','0','                    ','.F.','077','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'LOTE SERVICO   ','004','007','0','                    ','.F.','078','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'TIPO REGISTRO  ','008','008','0','                    ','.F.','079','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'TIPO OPERACAO  ','009','009','0','                    ','.F.','080','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'TIPO SERVICO   ','010','011','0','                    ','.F.','081','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'FORMA LANCAM   ','012','013','0','                    ','.F.','082','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'NUM VERS LOTE  ','014','016','0','                    ','.F.','083','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'USO EXCL CNAB  ','017','017','0','                    ','.F.','084','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'TP INSC EMPRESA','018','018','0','                    ','.F.','085','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'NUM INSC EMP   ','019','032','0','                    ','.F.','086','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'CONVENIO       ','033','052','0','                    ','.F.','087','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'NRO AGENCIA    ','053','057','0','                    ','.F.','088','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'DV AGENCIA     ','058','058','0','                    ','.F.','089','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'NRO CTA CORRENT','059','070','0','                    ','.F.','090','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'DV CONTA       ','071','072','0','                    ','.F.','091','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'NOME EMPRESA   ','073','102','0','                    ','.F.','092','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'MENSAGEM 1     ','103','142','0','                    ','.F.','093','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'ENDEREÇO       ','143','172','0','                    ','.F.','094','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'NUMERO         ','173','177','0','                    ','.F.','095','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'COMPLEMENTO    ','178','192','0','                    ','.F.','096','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'CIDADE         ','193','212','0','                    ','.F.','097','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'CEP            ','213','220','0','                    ','.F.','098','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'UNID FEDERATIVA','221','222','0','                    ','.F.','099','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'USO EXCL CNAB  ','223','230','0','                    ','.F.','100','',''})
		AADD(aRetCNAB, {'2','2','H','' ,'OCORRENCIA     ','231','240','0','                    ','.F.','101','',''})

	// 2T - TRAILER DE LOTE J / J52
		AADD(aRetCNAB, {'2','2','T','' ,'COD BANCO      ','001','003','0','                    ','.F.','102','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'LOTE SERV      ','004','007','0','                    ','.F.','103','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'TP DE REG      ','008','008','0','                    ','.F.','104','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'USO EXCL CNAB  ','009','017','0','                    ','.F.','105','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'QUANT DE REG   ','018','023','0','                    ','.F.','106','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'SOMAT VLR      ','024','041','0','                    ','.F.','107','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'SOMAT QTD MOED ','042','059','0','                    ','.F.','108','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'NRO AVISO DEBTO','060','065','0','                    ','.F.','109','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'USO EXCL CNAB  ','066','230','0','                    ','.F.','110','',''})
		AADD(aRetCNAB, {'2','2','T','' ,'OCORRENCIAS    ','231','240','0','                    ','.F.','111','',''})

	// 1D1 - DETALHE SEGMENTO A
		AADD(aRetCNAB, {'2','1','D','1','COD BANCO      ','001','003','0','                    ','.F.','112','',''})
		AADD(aRetCNAB, {'2','1','D','1','LOTE SERVICO   ','004','007','0','                    ','.F.','113','',''})
		AADD(aRetCNAB, {'2','1','D','1','TIPO REGISTRO  ','008','008','0','                    ','.F.','114','',''})
		AADD(aRetCNAB, {'2','1','D','1','NUM SEQ REG    ','009','013','0','                    ','.F.','115','',''})
		AADD(aRetCNAB, {'2','1','D','1','COD SEG REG    ','014','014','0','                    ','.F.','116','',''})
		AADD(aRetCNAB, {'2','1','D','1','TP DE MOV      ','015','015','0','                    ','.F.','117','',''})
		AADD(aRetCNAB, {'2','1','D','1','COD INST MOVIM ','016','017','0','                    ','.F.','118','',''})
		AADD(aRetCNAB, {'2','1','D','1','COD CAM. COMP  ','018','020','0','                    ','.F.','119','',''})
		AADD(aRetCNAB, {'2','1','D','1','COD BANCO FV   ','021','023','0','                    ','.F.','120','',''})
		AADD(aRetCNAB, {'2','1','D','1','AGENCIA FAVOREC','024','028','0','                    ','.F.','121','',''})
		AADD(aRetCNAB, {'2','1','D','1','DV AGENCIA     ','029','029','0','                    ','.F.','122','',''})
		AADD(aRetCNAB, {'2','1','D','1','CONTA FAVOR    ','030','041','0','                    ','.F.','123','',''})
		AADD(aRetCNAB, {'2','1','D','1','DV CONTA       ','042','043','0','                    ','.F.','124','',''})
		AADD(aRetCNAB, {'2','1','D','1','NOME FAVOR     ','044','073','0','                    ','.F.','125','',''})
		AADD(aRetCNAB, {'2','1','D','1','NUMDOC         ','074','093','0','                    ','.F.','126','',''})
		AADD(aRetCNAB, {'2','1','D','1','DATA PAGAMENTO ','094','101','0','DATA                ','.T.','127','{\"ZERAR VARIAVEL\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR VARIAVEL\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','1','D','1','TIPO MOEDA     ','102','104','0','                    ','.F.','128','',''})
		AADD(aRetCNAB, {'2','1','D','1','QUANT MOEDA    ','105','119','5','                    ','.F.','129','',''})
		AADD(aRetCNAB, {'2','1','D','1','VLR PAG        ','120','134','2','VALOR               ','.T.','130','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','1','NRO DOC ATR BCO','135','154','0','NOSSONUMERO         ','.T.','131','{\"ZERAR VARIAVEL\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}','{\"ZERAR VARIAVEL\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}'})
		AADD(aRetCNAB, {'2','1','D','1','DT REAL PGTO   ','155','162','0','DATACREDITO         ','.T.','132','{\"ZERAR VARIAVEL\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR VARIAVEL\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','1','D','1','VLR REAL PGTO  ','163','177','2','VALOR               ','.T.','133','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','1','INFORMAÇÃO 2   ','178','217','0','                    ','.F.','134','',''})
		AADD(aRetCNAB, {'2','1','D','1','FINALID DOC    ','218','219','0','                    ','.F.','135','',''})
		AADD(aRetCNAB, {'2','1','D','1','FINALID TED    ','220','224','0','                    ','.F.','136','',''})
		AADD(aRetCNAB, {'2','1','D','1','COMPL FIN PAGTO','225','226','0','                    ','.F.','137','',''})
		AADD(aRetCNAB, {'2','1','D','1','USO EXCL CNAB  ','227','229','0','                    ','.F.','138','',''})
		AADD(aRetCNAB, {'2','1','D','1','AVISO FAVOR    ','230','230','0','                    ','.F.','139','',''})
		AADD(aRetCNAB, {'2','1','D','1','OCORRENCIAS    ','231','240','0','OCORRENCIA          ','.T.','140','{\"ZERAR VARIAVEL\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}','{\"ZERAR VARIAVEL\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}'})

	// 1D2 - DETALHE SEGMENTO B
		AADD(aRetCNAB, {'2','1','D','2','COD BANCO      ','001','003','0','                    ','.F.','141','',''})
		AADD(aRetCNAB, {'2','1','D','2','LOTE SERVICO   ','004','007','0','                    ','.F.','142','',''})
		AADD(aRetCNAB, {'2','1','D','2','TIPO REGISTRO  ','008','008','0','                    ','.F.','143','',''})
		AADD(aRetCNAB, {'2','1','D','2','NUM SEQ DO REG ','009','013','0','                    ','.F.','144','',''})
		AADD(aRetCNAB, {'2','1','D','2','COD SEG DETALHE','014','014','0','                    ','.F.','145','',''})
		AADD(aRetCNAB, {'2','1','D','2','USO EXCL CNAB  ','015','017','0','                    ','.F.','146','',''})
		AADD(aRetCNAB, {'2','1','D','2','TP INSC FAV    ','018','018','0','                    ','.F.','147','',''})
		AADD(aRetCNAB, {'2','1','D','2','CNPJ/CPF FAV   ','019','032','0','                    ','.F.','148','',''})
		AADD(aRetCNAB, {'2','1','D','2','LOGRAD FAVOREC ','033','062','0','                    ','.F.','149','',''})
		AADD(aRetCNAB, {'2','1','D','2','NUMERO         ','063','067','0','                    ','.F.','150','',''})
		AADD(aRetCNAB, {'2','1','D','2','COMPLEMENTO    ','068','082','0','                    ','.F.','151','',''})
		AADD(aRetCNAB, {'2','1','D','2','BAIRRO FAVOR   ','083','097','0','                    ','.F.','152','',''})
		AADD(aRetCNAB, {'2','1','D','2','CIDADE FAVOR   ','098','117','0','                    ','.F.','153','',''})
		AADD(aRetCNAB, {'2','1','D','2','CEP FAVOR      ','118','125','0','                    ','.F.','154','',''})
		AADD(aRetCNAB, {'2','1','D','2','ESTADO FAVOR   ','126','127','0','                    ','.F.','155','',''})
		AADD(aRetCNAB, {'2','1','D','2','DATA VENCIMENTO','128','135','0','DATA                ','.T.','156','{\"ZERAR VARIAVEL\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR VARIAVEL\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VALOR DOCUMENTO','136','150','2','VALOR               ','.T.','157','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR ABATIMENTO ','151','165','2','ABATIMENTO          ','.T.','158','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR  DESCONTO  ','166','180','2','DESCONTO            ','.T.','159','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR MORA       ','181','195','2','JUROS               ','.T.','160','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','VLR MULTA      ','196','210','2','MULTA               ','.T.','161','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','1','D','2','HR ENVIO TED   ','211','214','0','                    ','.F.','162','',''})
		AADD(aRetCNAB, {'2','1','D','2','USO EXCL CNAB  ','215','225','0','                    ','.F.','163','',''})
		AADD(aRetCNAB, {'2','1','D','2','COD HIST CREDIT','226','229','0','                    ','.F.','164','',''})
		AADD(aRetCNAB, {'2','1','D','2','AVISO FAVOR    ','230','230','0','                    ','.F.','165','',''})
		AADD(aRetCNAB, {'2','1','D','2','USO EXCL CNAB  ','231','231','0','                    ','.F.','166','',''})
		AADD(aRetCNAB, {'2','1','D','2','TED INST FINANC','232','232','0','                    ','.F.','167','',''})
		AADD(aRetCNAB, {'2','1','D','2','ID DA IF NO SPB','233','240','0','                    ','.F.','168','',''})

	// 2D1 - DETALHE SEGMENTO J
		AADD(aRetCNAB, {'2','2','D','1','COD BANCO      ','001','003','0','                    ','.F.','169','',''})
		AADD(aRetCNAB, {'2','2','D','1','LOTE SERVICO   ','004','007','0','                    ','.F.','170','',''})
		AADD(aRetCNAB, {'2','2','D','1','TIPO REGISTRO  ','008','008','0','                    ','.F.','171','',''})
		AADD(aRetCNAB, {'2','2','D','1','NUM SEQ REG LOT','009','013','0','                    ','.F.','172','',''})
		AADD(aRetCNAB, {'2','2','D','1','COD SEG DETALHE','014','014','0','                    ','.F.','173','',''})
		AADD(aRetCNAB, {'2','2','D','1','TIPO MOVIMENTO ','015','015','0','                    ','.F.','174','',''})
		AADD(aRetCNAB, {'2','2','D','1','COD INST MOVIM ','016','017','0','                    ','.F.','175','',''})
		AADD(aRetCNAB, {'2','2','D','1','COD BARRAS     ','018','061','0','                    ','.F.','176','',''})
		AADD(aRetCNAB, {'2','2','D','1','NOME DO CEDENTE','062','091','0','                    ','.F.','177','',''})
		AADD(aRetCNAB, {'2','2','D','1','DATA VENCIMENTO','092','099','0','DATA                ','.T.','178','{\"ZERAR VARIAVEL\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR VARIAVEL\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','2','D','1','VLR NOM TITULO ','100','114','2','VALOR               ','.T.','179','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','2','D','1','VALOR DESCONTO ','115','129','2','DESCONTO            ','.T.','180','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','2','D','1','VALOR JUROS    ','130','144','2','JUROS               ','.T.','181','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','2','D','1','DATA PAGAMENTO ','145','152','0','DATACREDITO         ','.T.','182','{\"ZERAR VARIAVEL\",\"DATA\",\"DATACREDITO\"}','{\"ZERAR VARIAVEL\",\"DATA\",\"DATACREDITO\"}'})
		AADD(aRetCNAB, {'2','2','D','1','VLR PAG        ','153','167','2','VALOR               ','.T.','183','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}','{\"ZERAR VARIAVEL\",\"VALOR\",\"DESPESAS\",\"DESCONTO\",\"JUROS\",\"ABATIMENTO\",\"MULTA\",\"IOF\",\"OUTROSCREDITOS\"}'})
		AADD(aRetCNAB, {'2','2','D','1','QTD MOEDA      ','168','182','0','                    ','.F.','184','',''})
		AADD(aRetCNAB, {'2','2','D','1','NRO DOC CLIENTE','183','202','0','NOSSONUMERO         ','.T.','185','{\"ZERAR VARIAVEL\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}','{\"ZERAR VARIAVEL\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}'})
		AADD(aRetCNAB, {'2','2','D','1','DOC ATR BANCO  ','203','222','0','NOSSONUMERO         ','.T.','186','{\"ZERAR VARIAVEL\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}','{\"ZERAR VARIAVEL\",\"TITULO\",\"ESPECIE\",\"NOSSONUMERO\",\"AUTENTICACAO\",\"MOTIVO\"}'})
		AADD(aRetCNAB, {'2','2','D','1','COD MOEDA      ','223','224','0','                    ','.F.','187','',''})
		AADD(aRetCNAB, {'2','2','D','1','USO EXCL CNAB  ','225','230','0','                    ','.F.','188','',''})
		AADD(aRetCNAB, {'2','2','D','1','OCORRENCIAS    ','231','240','0','OCORRENCIA          ','.T.','189','{\"ZERAR VARIAVEL\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}','{\"ZERAR VARIAVEL\",\"OCORRENCIA\",\"RESERVADO\",\"SEGMENTO\"}'})

	// 2D2 - DETALHE SEGMENTO J52
		AADD(aRetCNAB, {'2','2','D','2','COD BANCO      ','001','003','0','                    ','.F.','190','',''})
		AADD(aRetCNAB, {'2','2','D','2','LOTE SERVICO   ','004','007','0','                    ','.F.','191','',''})
		AADD(aRetCNAB, {'2','2','D','2','TIPO REGISTRO  ','008','008','0','                    ','.F.','192','',''})
		AADD(aRetCNAB, {'2','2','D','2','NUM SEQ REG LOT','009','013','0','                    ','.F.','193','',''})
		AADD(aRetCNAB, {'2','2','D','2','COD SEG DETALHE','014','014','0','                    ','.F.','194','',''})
		AADD(aRetCNAB, {'2','2','D','2','USO EXCL CNAB  ','015','015','0','                    ','.F.','195','',''})
		AADD(aRetCNAB, {'2','2','D','2','COD MOV REMESSA','016','017','0','                    ','.F.','196','',''})
		AADD(aRetCNAB, {'2','2','D','2','IDENT REG OPCIO','018','019','0','                    ','.F.','197','',''})
		AADD(aRetCNAB, {'2','2','D','2','TP INSC SACADO ','020','020','0','                    ','.F.','198','',''})
		AADD(aRetCNAB, {'2','2','D','2','NRO INSC SACADO','021','035','0','                    ','.F.','199','',''})
		AADD(aRetCNAB, {'2','2','D','2','NOME DO SACADO ','036','075','0','                    ','.F.','200','',''})
		AADD(aRetCNAB, {'2','2','D','2','TP INSC CEDENTE','076','076','0','                    ','.F.','201','',''})
		AADD(aRetCNAB, {'2','2','D','2','NRO INSC CEDENT','077','091','0','                    ','.F.','202','',''})
		AADD(aRetCNAB, {'2','2','D','2','NOME DO CEDENTE','092','131','0','                    ','.F.','203','',''})
		AADD(aRetCNAB, {'2','2','D','2','TP INSC SACADO ','132','132','0','                    ','.F.','204','',''})
		AADD(aRetCNAB, {'2','2','D','2','NRO INSC SACADO','133','147','0','                    ','.F.','205','',''})
		AADD(aRetCNAB, {'2','2','D','2','NOME DO SACADO ','148','187','0','                    ','.F.','206','',''})
		AADD(aRetCNAB, {'2','2','D','2','USO EXCL CNAB  ','188','240','0','                    ','.F.','207','',''})

Return aRetCNAB 

