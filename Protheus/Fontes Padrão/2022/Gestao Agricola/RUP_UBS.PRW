#Include 'Protheus.ch'

/*{Protheus.doc}
Função de compatibilização do release incremental.
Função chamada apartir da rotina RUP_AGR*/
Function RUP_UBS()
	//Realiza a chamada da função refente aos campos ( SX3 )
	FAtuTafSX3()
	AjustaSX6()
	
Return  Nil

/*{Protheus.doc}
Função de compatibilização do release incremental.
Função chamada a partir da rotina RUP_AGR*/
Function RUP_UBS37()
	
	AjustaSx3("NKV_USUARI", { { "X3_RELACAO"	,'' } }, { }, { }, {|| .T.} )
	AjustaSx3("ND3_TRANSM", { { "X3_CBOX"		,' ' } }, { }, { }, {|| .T.} )
	AjustaSx3("ND3_TRANSM", { { "X3_CBOXSPA"	,' ' } }, { }, { }, {|| .T.} )
	AjustaSx3("ND3_TRANSM", { { "X3_CBOXENG"	,' ' } }, { }, { }, {|| .T.} )
	AjustSX137()	
	
Return Nil

Static Function FAtuTafSX3()	
	AjustaSx3("DXD_FILIAL", { { "X3_ORDEM", '01' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_SAFRA",	{ { "X3_ORDEM", '02' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_CODIGO", { { "X3_ORDEM", '03' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_DATAEM", { { "X3_ORDEM", '04' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_CLACOM", { { "X3_ORDEM", '05' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_QTDMAX", { { "X3_ORDEM", '06' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_QTDVNC", { { "X3_ORDEM", '07' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_FDINI",  { { "X3_ORDEM", '08' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_FDFIN",  { { "X3_ORDEM", '09' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_PRDTOR", { { "X3_ORDEM", '10' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_LJPRO",  { { "X3_ORDEM", '11' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_NMPRDT", { { "X3_ORDEM", '12' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_FAZ",  	{ { "X3_ORDEM", '13' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_NMFAZ",  { { "X3_ORDEM", '14' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_CODVAR", { { "X3_ORDEM", '15' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_DESCVR", { { "X3_ORDEM", '16' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_CODUNB", { { "X3_ORDEM", '17' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_LOCAL",  { { "X3_ORDEM", '18' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_ENDXYZ", { { "X3_ORDEM", '19' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_OK",  	{ { "X3_ORDEM", '20' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_CODREG", { { "X3_ORDEM", '21' } }, { }, { }, {|| .T.} )
	
	AjustaSx3("N95_ORDEM", { { "X3_ORDEM", '04' } }, { }, { }, {|| .T.} )
	AjustaSx3("N95_CODIGO",{ { "X3_ORDEM", '05' } }, { }, { }, {|| .T.} )
	AjustaSx3("N95_CAMPO", { { "X3_ORDEM", '06' } }, { }, { }, {|| .T.} )
	AjustaSx3("N95_TITULO",{ { "X3_ORDEM", '07' } }, { }, { }, {|| .T.} )
	AjustaSx3("N95_DESCPO",{ { "X3_ORDEM", '08' } }, { }, { }, {|| .T.} )
	AjustaSx3("N95_OBRIGA",{ { "X3_ORDEM", '09' } }, { }, { }, {|| .T.} )
	
	AjustaSx3("DXD_QTDVNC", { { "X3_BROWSE", 'S' } }, { }, { }, {|| .T.} )		
	
	AjustaSx3("NPX_CODPRO", { { "X3_CBOX", ' ' } }, { }, { }, {|| .T.} )
	
	AjustaSx3("DX0_TALHAO", { { "X3_TAMANHO", 16 } }, { }, { }, {|| .T.} )
	AjustaSx3("DXK_TALHAO", { { "X3_TAMANHO", 16 } }, { }, { }, {|| .T.} )
	AjustaSx3("DXL_TALHAO", { { "X3_TAMANHO", 16 } }, { }, { }, {|| .T.} )
	AjustaSx3("NJF_TALHAO", { { "X3_TAMANHO", 16 } }, { }, { }, {|| .T.} )
	AjustaSx3("NJM_TALHAO", { { "X3_TAMANHO", 16 } }, { }, { }, {|| .T.} )
	AjustaSx3("NJP_TALHAO", { { "X3_TAMANHO", 16 } }, { }, { }, {|| .T.} )
	AjustaSx3("NJR_TALHAO", { { "X3_TAMANHO", 16 } }, { }, { }, {|| .T.} )
	AjustaSx3("NN3_TALHAO", { { "X3_TAMANHO", 16 } }, { }, { }, {|| .T.} )
	AjustaSx3("NN4_TALHAO", { { "X3_TAMANHO", 16 } }, { }, { }, {|| .T.} )
	AjustaSx3("NNP_TALHAO", { { "X3_TAMANHO", 16 } }, { }, { }, {|| .T.} )
	AjustaSx3("NP1_TALHAO", { { "X3_TAMANHO", 16 } }, { }, { }, {|| .T.} )
	AjustaSx3("NP5_TALHAO", { { "X3_TAMANHO", 16 } }, { }, { }, {|| .T.} )
	AjustaSx3("NPA_TALHAO", { { "X3_TAMANHO", 16 } }, { }, { }, {|| .T.} )
	AjustaSx3("NPO_TALHAO", { { "X3_TAMANHO", 16 } }, { }, { }, {|| .T.} )
	AjustaSx3("N71_TALHAO", { { "X3_TAMANHO", 16 } }, { }, { }, {|| .T.} )
	AjustaSx3("DX2_NOME"  , { { "X3_TAMANHO", 20 } }, { }, { }, {|| .T.} )
	AjustaSx3("N71_PRODUT", { { "X3_TAMANHO", 6  } }, { }, { }, {|| .T.} )
	AjustaSx3("N71_LOJA"  , { { "X3_TAMANHO", 2  } }, { }, { }, {|| .T.} )
	AjustaSx3("DX2_NOME"  , { { "X3_F3"     ,' ' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXJ_CODCLA", { { "X3_WHEN"   ,' ' } }, { }, { }, {|| .T.} ) 
	
	/*DAGROUBA-1839*/
	AjustaSx3("DXE_CODPRO", { { "X3_BROWSE" ,'N' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXE_DESCPR", { { "X3_BROWSE" ,'N' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXE_DESCPR", { { "X3_RELACAO",'If(!INCLUI,Posicione("SB1",1,xFilial("SB1")+DXE->DXE_CODPRO,"B1_DESC"),"")' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXE_LOCAL",  { { "X3_BROWSE" ,'N' } }, { }, { }, {|| .T.} )
	
	AjustaSx3("NPX_SAFRA",  { { "X3_OBRIGAT",' ' } }, { }, { }, {|| .T.} )
	AjustaSx3("NPX_SAFRA",  { { "X3_USADO"  ,"€€€€€€€€€€€€€€€" } }, { }, { }, {|| .T.} )
	
	AjustaSx3("N94_DADENT",  { { "X3_USADO"  ,"€€€€€€€€€€€€€€€" } }, { }, { }, {|| .T.} )
	AjustaSx3("N94_INTPIM",  { { "X3_USADO"  ,"€€€€€€€€€€€€€€€" } }, { }, { }, {|| .T.} )
	AjustaSx3("N94_MVPPRD",  { { "X3_USADO"  ,"€€€€€€€€€€€€€€€" } }, { }, { }, {|| .T.} )
	AjustaSx3("N94_ACDFPS",  { { "X3_USADO"  ,"€€€€€€€€€€€€€€€" } }, { }, { }, {|| .T.} )
	AjustaSx3("N94_DESCAR",  { { "X3_USADO"  ,"€€€€€€€€€€€€€€€" } }, { }, { }, {|| .T.} )
	AjustaSx3("N94_DADCON",  { { "X3_USADO"  ,"€€€€€€€€€€€€€€€" } }, { }, { }, {|| .T.} )
	AjustaSx3("N94_DADEMB",  { { "X3_USADO"  ,"€€€€€€€€€€€€€€€" } }, { }, { }, {|| .T.} )
	AjustaSx3("N94_PREROM",  { { "X3_USADO"  ,"€€€€€€€€€€€€€€€" } }, { }, { }, {|| .T.} )
	AjustaSx3("N94_MOVORI",  { { "X3_USADO"  ,"€€€€€€€€€€€€€€€" } }, { }, { }, {|| .T.} )
	AjustaSx3("N94_GSTFD1",  { { "X3_USADO"  ,"€€€€€€€€€€€€€€€" } }, { }, { }, {|| .T.} )
	AjustaSx3("N94_GSTFD2",  { { "X3_USADO"  ,"€€€€€€€€€€€€€€€" } }, { }, { }, {|| .T.} )
	AjustaSx3("N94_LANCPR",  { { "X3_USADO"  ,"€€€€€€€€€€€€€€€" } }, { }, { }, {|| .T.} )
	
	AjustaSx3("NPX_SAFRA",  { { "X3_RESERV" ,"‚A" } }, { }, { }, {|| .T.} )
	AjustaSx3("DXL_CODPRO", { { "X3_VISUAL" ,'A' } }, { }, { }, {|| .T.} )
	AjustaSx3("NKT_CONDPG", { { "X3_VISUAL" ,'A' } }, { }, { }, {|| .T.} )
	AjustaSx3("NN3_CODPRO", { { "X3_VISUAL" ,'A' } }, { }, { }, {|| .T.} )
	AjustaSx3("NNV_CODIGO", { { "X3_VISUAL" ,'A' } }, { }, { }, {|| .T.} )
	
	If AGRColPos('NN3_DESPRO')
		AjustaSx3("NN3_DESPRO", { { "X3_RELACAO" , "If(Inclui,'',Posicione('SB1',1,xFilial('SB1')+NN3->NN3_CODPRO,'B1_DESC'))" } }, { }, { }, {|| .T.} )
		AjustaSx3("NN3_DESPRO", { { "X3_INIBRW"  , "Posicione('SB1',1,xFilial('SB1')+NN3->NN3_CODPRO,'B1_DESC')" } }, { }, { }, {|| .T.} )
	EndIf
	
	AjustaSx3("DXD_LOCAL", { { "X3_TITULO"  ,'Local' } }, { }, { }, {|| .T.} )
	
	AjustaSx3("DXN_CODUNB", { { "X3_F3"  	,'DX3' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXS_CODUNB", { { "X3_F3"  	,'DX3' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXT_CODUNB", { { "X3_F3"  	,'DX3' } }, { }, { }, {|| .T.} )
	
	AjustaSx3("DXD_PRDTOR",{ { "X3_TITULO"  ,'Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_LJPRO", { { "X3_TITULO"  ,'Lj. Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_NMPRDT",{ { "X3_TITULO"  ,'Nome Entid.' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXI_PRDTOR",{ { "X3_TITULO"  ,'Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXI_LJPRO", { { "X3_TITULO"  ,'Lj. Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXJ_PRDTOR",{ { "X3_TITULO"  ,'Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXJ_LJPRO", { { "X3_TITULO"  ,'Lj. Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXJ_NMPDTR",{ { "X3_TITULO"  ,'Nome Entid.' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXL_PRDTOR",{ { "X3_TITULO"  ,'Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXL_LJPRO", { { "X3_TITULO"  ,'Lj. Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXL_NMPDTR",{ { "X3_TITULO"  ,'Nome Entid.' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXM_PRDTOR",{ { "X3_TITULO"  ,'Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXM_LJPRO", { { "X3_TITULO"  ,'Lj. Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXM_NMPDTR",{ { "X3_TITULO"  ,'Nome Entid.' } }, { }, { }, {|| .T.} )
	AjustaSx3("NN2_PRDTOR",{ { "X3_TITULO"  ,'Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("NN2_LJPRO", { { "X3_TITULO"  ,'Lj. Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("N71_PRODUT",{ { "X3_TITULO"  ,'Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("N71_LOJA",  { { "X3_TITULO"  ,'Lj. Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_PRDTOR",{ { "X3_TITULO"  ,'Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_LJPRO", { { "X3_TITULO"  ,'Lj. Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("NPX_PRDTOR",{ { "X3_TITULO"  ,'Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("NPX_LJPRO", { { "X3_TITULO"  ,'Lj. Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("N94_DADAGD",{ { "X3_TITULO"  ,'Agendamento' } }, { }, { }, {|| .T.} )
	
	AjustaSx3("DXD_PRDTOR",{ { "X3_DESCRIC"  ,'Código da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_LJPRO", { { "X3_DESCRIC"  ,'Loja da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_NMPRDT",{ { "X3_DESCRIC"  ,'Nome da Entididade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXD_FAZ",   { { "X3_DESCRIC"  ,'Fazenda de Produção' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXI_PRDTOR",{ { "X3_DESCRIC"  ,'Código da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXI_LJPRO", { { "X3_DESCRIC"  ,'Loja da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXJ_PRDTOR",{ { "X3_DESCRIC"  ,'Código da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXJ_LJPRO", { { "X3_DESCRIC"  ,'Loja da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXJ_NMPDTR",{ { "X3_DESCRIC"  ,'Nome da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXJ_FAZ",   { { "X3_DESCRIC"  ,'Fazenda de Produção' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXL_PRDTOR",{ { "X3_DESCRIC"  ,'Código da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXL_LJPRO", { { "X3_DESCRIC"  ,'Loja da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXL_NMPDTR",{ { "X3_DESCRIC"  ,'Nome da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXM_PRDTOR",{ { "X3_DESCRIC"  ,'Código da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXM_LJPRO", { { "X3_DESCRIC"  ,'Loja da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXM_NMPDTR",{ { "X3_DESCRIC"  ,'Nome da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("NN2_PRDTOR",{ { "X3_DESCRIC"  ,'Código da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("NN2_LJPRO", { { "X3_DESCRIC"  ,'Loja da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("N71_PRODUT",{ { "X3_DESCRIC"  ,'Código da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("N71_LOJA",  { { "X3_DESCRIC"  ,'Loja da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_PRDTOR",{ { "X3_DESCRIC"  ,'Código da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_LJPRO", { { "X3_DESCRIC"  ,'Loja da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("NPX_PRDTOR",{ { "X3_DESCRIC"  ,'Código da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("NPX_LJPRO", { { "X3_DESCRIC"  ,'Loja da Entidade' } }, { }, { }, {|| .T.} )
	AjustaSx3("NPX_FAZ",   { { "X3_DESCRIC"  ,'Fazenda de Produção' } }, { }, { }, {|| .T.} )
	AjustaSx3("N94_DADAGD",{ { "X3_DESCRIC"  ,'Dados de Agendamento' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXJ_CODIGO",{ { "X3_DESCRIC"  ,'Código da Mala de Class.' } }, { }, { }, {|| .T.} )	
	AjustaSx3("DXJ_TIPO",  { { "X3_DESCRIC"  ,'Tipo da Mala de Class.' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXJ_DATA",  { { "X3_DESCRIC"  ,'Data da Mala de Class.' } }, { }, { }, {|| .T.} )
	
	AjustaSx3("DXD_NMPRDT", { { "X3_RELACAO",'IF(!INCLUI,POSICIONE("NJ0",1,XFILIAL("NJ0")+M->(DXD_PRDTOR+DXD_LJPRO),"NJ0_NOME"),"")' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXJ_NMPDTR", { { "X3_RELACAO",'If(!INCLUI,Posicione("NJ0",1,xFilial("NJ0")+M->(DXJ_PRDTOR+DXJ_LJPRO),"NJ0_NOME"),"")' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXL_NMPDTR", { { "X3_RELACAO",'If(!INCLUI,Posicione("NJ0",1,xFilial("NJ0")+M->(DXL_PRDTOR+DXL_LJPRO),"NJ0_NOME"),"")' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXM_NMPDTR", { { "X3_RELACAO",'If(!INCLUI,Posicione("NJ0",1,xFilial("NJ0")+M->(DXM_PRDTOR+DXM_LJPRO),"NJ0_NOME"),"")' } }, { }, { }, {|| .T.} )

	AjustaSx3("N92_TIPO",   { { "X3_CBOX"   ,' ' } }, { }, { }, {|| .T.} )
	AjustaSx3("N92_DSTIPO", { { "X3_ORDEM", '05' } }, { }, { }, {|| .T.} )
	AjustaSx3("N92_MDEXEC", { { "X3_ORDEM", '06' } }, { }, { }, {|| .T.} )
	AjustaSx3("N92_MDEXEC", { { "X3_CBOX",  '1=Etapas;2=Único' } }, { }, { }, {|| .T.} )
	
	AjustaSx3("NJJ_TOETAP", { { "X3_VISUAL" ,'V' } }, { }, { }, {|| .T.} )

	/* DAGROUBA-4505 */
	AjustaSx3("DXB_NOMPRT", { { "X3_ORDEM", '07' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_FAZ"	  , { { "X3_ORDEM", '08' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_NOMFAZ", { { "X3_ORDEM", '09' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_OP"	  , { { "X3_ORDEM", '10' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_CODPRO", { { "X3_ORDEM", '11' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_DESPRO", { { "X3_ORDEM", '12' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_ROTINA", { { "X3_ORDEM", '13' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_DOC"	  , { { "X3_ORDEM", '14' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_DOCNF" , { { "X3_ORDEM", '15' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_SERIE" , { { "X3_ORDEM", '16' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_NUMPED", { { "X3_ORDEM", '17' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_QUANT" , { { "X3_ORDEM", '18' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_LOCAL" , { { "X3_ORDEM", '19' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_DESLOC", { { "X3_ORDEM", '20' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_CODUNI", { { "X3_ORDEM", '21' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_NUMSEQ", { { "X3_ORDEM", '22' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_CF"	  , { { "X3_ORDEM", '23' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_TM"	  , { { "X3_ORDEM", '24' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_OK"	  , { { "X3_ORDEM", '25' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_LOTCTL", { { "X3_ORDEM", '26' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_NMLOT" , { { "X3_ORDEM", '27' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_LOCLIZ", { { "X3_ORDEM", '28' } }, { }, { }, {|| .T.} )		
	
	AjustaSx3("DXB_QUANT" , { { "X3_DESCRIC", 'Peso' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_QUANT" , { { "X3_TITULO"  ,'Peso' } }, { }, { }, {|| .T.} )
	
	AjustaSx3("DXB_CODPRO", { { "X3_BROWSE" ,'S' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_LOTCTL", { { "X3_BROWSE" ,'S' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_NMLOT" , { { "X3_BROWSE" ,'S' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_LOCLIZ", { { "X3_BROWSE" ,'S' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_ROTINA", { { "X3_BROWSE" ,'N' } }, { }, { }, {|| .T.} )
	AjustaSx3("DXB_OK"    , { { "X3_BROWSE" ,'N' } }, { }, { }, {|| .T.} )
	
	AjustaSx3("DXJ_CODIGO", { { "X3_RELACAO",'IIF(INCLUI .And. !(FwIsInCallStack("AGRA615")),GETSXENUM("DXJ","DXJ_CODIGO"),"")' } }, { }, { }, {|| .T.} )
	
	AjustaSx3("DXJ_CODIGO", { { "X3_RELACAO",'IIF(INCLUI .And. !(FwIsInCallStack("AGRA615")),GETSXENUM("DXJ","DXJ_CODIGO"),"")' } }, { }, { }, {|| .T.} )
	AjustaSx3("NJK_TIPREG", { { "X3_RELACAO",'' } }, { }, { }, {|| .T.} )
	
Return

//-------------------------------------------------------------------
Static Function AjustaSx3(cCampo, aCpoPor, aCpoSpa, aCpoEng, cCondicao)
	Local aArea := GetArea(), nIndice, lCondicao

	If ValType(aCpoPor) = "C"        // A variavel pode ser passada tambem como string
		aCpoPor := { { "X3_CBOX", aCpoPor } }        
		aCpoSpa := { { "X3_CBOXSPA", aCpoSpa } } 
		aCpoEng := { { "X3_CBOXENG", aCpoEng } }
	Endif

	DbSelectArea("SX3")
	DbSetOrder(2)
	MsSeek(cCampo)

	If ValType(cCondicao) = "B"
		lCondicao := Eval(cCondicao)
	Else
		lCondicao := ! cCondicao $ AllTrim(&(aCpoPor[1][1]))
	Endif
	If Found() .And. lCondicao
		RecLock("SX3", .F.)
		For nIndice := 1 To Len(aCpoPor)
			Replace &(aCpoPor[nIndice][1]) With aCpoPor[nIndice][2]
		Next
		For nIndice := 1 To Len(aCpoSpa)
			Replace &(aCpoSpa[nIndice][1]) With aCpoSpa[nIndice][2]
		Next
		For nIndice := 1 To Len(aCpoEng)
			Replace &(aCpoEng[nIndice][1]) With aCpoEng[nIndice][2]
		Next
		SX3->(MsUnLock())
	Endif

	RestArea(aArea)

Return .T. 


/*{Protheus.doc} AjustaSX6
//TODO Descrição auto-gerada.
@author	 	ana.olegini
@since 		12/12/2017
@version 	P12.1.19
*/
Static Function AjustaSX6()

	dbSelectArea("SX6")
	dbSetOrder(1)
    If dbSeek(xFilial("SX6") + "MV_AGRTMPP")
    	RecLock("SX6",.F.)
			SX6->X6_TIPO	:= "C"
		MsUnlock()
	Endif
	
Return

/*/{Protheus.doc} AjustSX125
 Ajusta SX1 na release 12.1.25
@type function
@version 
@author rafael.voltz
@since 07/04/2020
@return return_type, return_description
/*/
Static Function AjustSX137()
	
    Local aPerguntes := {"AGRA840F11"}
    Local nX   := 0    
	//Atualiza tamanho 	
	DbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	/* Exclusão dos Perguntes com ordem de apenas 1 dígito, pois foi alterado na ATUSX para 2 e gerou duplicidade */
	For nX := 1 To len(aPerguntes)
        If SX1->(DbSeek(aPerguntes[nX]))
            While SX1->(!Eof()) .AND. ALLTRIM(SX1->X1_GRUPO) == aPerguntes[nX]
                If Len(alltrim(SX1->X1_ORDEM)) == 1
                    RecLock("SX1")
                    SX1->(dbDelete())        
                    SX1->(MsUnlock())
                EndIf
                SX1->(dbSkip())
            EndDo
        EndIf
    Next nX

Return  Nil	
