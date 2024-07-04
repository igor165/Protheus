#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OGC002.CH"

#DEFINE CR Chr(13) + Chr(10)

/* 
+=================================================================================================+
| Função    : OGC002                                                                              |
| Descrição : Consulta Compra x Venda                                                             |
| Autor     : Ana Laura Olegini                                                                   |
| Data      : 31/10/2014                                                                          |
+=================================================================================================+                                                                           |  
*/
Function OGC002()


	Local aCoors	:= FWGetDialogSize( oMainWnd )
	Local oSize		:= Nil


	Private aArqCompra	:= {}
	Private aArqVenda	:= {}

	Private aAlT1, aAlT2
	Private cNoT1, cAlt1
	Private cNoT2, cAlT2	

	Private aIndice1, aIndice2

	Private oDlg, oBrwP1, oBrwP2

	Private bKeyF12	  	:= {|| If( Pergunte(STR0002, .T.), ( CRIATRBS(), oDlg:Refresh()), .T. ) } //"OGC002"
	SetKey(VK_F12,bKeyF12)

	/*+===============================================+
	|| ARQUIVO TEMPORARIO -- CONTRATOS DE COMPRA		||
	+================================================*/
	vVetCom := {	{"NJR_STATUS"}, ;
	{"NJR_STATUS"}, ;					
	{"NJR_CODCTR"}, ;											//CONTRATO
	{"NJR_MODAL"} , ;  											//MODALIDADE
	{"NJR_CODOPE"}, ;											//COD. OPERACAO
	{"TIPFIX" ,"C",07,0,"@!", RetTitle( "NJR_TIPFIX" )}	, ;		//TIPO PREÇO
	{"NJR_MOEDA"}	, ;											//MOEDA
	{"IMPOSTO","N",18,2,"@E 999,999,999,999.99",STR0014}	, ;	//VALOR IMPOSTO
	{"TPFRET" ,"C",03,0,"",STR0015}	, ;							//TIPO FRETE
	{"DATFIM" ,"D",08,0,"",STR0016}	, ;							//PRAZO FINAL
	{"DTVENC" ,"D",08,0,"",STR0017}	, ;							//DATA PAGTO
	{"NJR_CODENT"}, ;											//COD. ENTIDADE
	{"NJR_NOMENT"}, ;											//NOME ENTIDADE
	{"NJR_LOJENT"}, ;											//LOJA ENTIDADE
	{"NJR_QTDCTR"}, ;											//QTD TOTAL
	{"NN8_QTDFIX"}, ;											//QTD FIXADA
	{"AFIXAR","N",18,2,"@E 999,999,999,999.99",STR0021}	, ;		//QTD A FIXAR
	{"PMEDIO","N",18,2,"@E 999,999,999,999.99",STR0022}	, ;		//PRECO MEDIO
	{"VTOTME","N",18,2,"@E 999,999,999,999.99",STR0023}	, ;		//VL TOTAL MEDIO
	{"VTOTLQ","N",18,2,"@E 999,999,999,999.99",STR0024}	, ;		//VL TOTAL LIQUIDO
	{"COMPRA","N",18,2,"@E 999,999,999,999.99",STR0025}	, ;		//QTD ENTREGUE
	{"NJR_QSLFCO"}}												//QTD ENTREGAR

	//{"NJR_TIPFIX"}, ;		//TIPO PREÇO

	vRetCom := AGRCRIATRB(,vVetCom,{"NJR_CODCTR"},STR0002,.T.) //"OGC002"	//FUNCAO DO AGRUTIL01
	cNoT1 := vRetCom[3]	//INDICE
	cAlT1 := vRetCom[4]  //ALIAS        
	aAlT1 := vRetCom[5]	//ARRAY 

	aIndice1 := AGRINDICONS({"NJR_CODCTR"}, aAlT1 )	

	/*+===============================================+
	|| ARQUIVO TEMPORARIO -- CONTRATOS DE VENDA		||
	+================================================*/
	vVetVen := {	{"NJR_STATUS"}, ;
	{"NJR_CODCTR"}, ;											//CONTRATO
	{"NJR_MODAL"}	, ;  										//MODALIDADE
	{"NJR_CODOPE"}, ;											//COD. OPERACAO
	{"TIPFIX" ,"C",07,0,"@!", RetTitle( "NJR_TIPFIX" )}	, ;		//TIPO PREÇO
	{"NJR_MOEDA"}	, ;											//MOEDA
	{"IMPOSTO","N",18,2,"@E 999,999,999,999.99",STR0014}	, ;	//VALOR IMPOSTO
	{"TPFRET" ,"C",03,0,"",STR0015}	, ;							//TIPO FRETE
	{"DATFIM" ,"D",08,0,"",STR0016}	, ;							//PRAZO FINAL
	{"DTVENC" ,"D",08,0,"",STR0017}	, ;							//DATA PAGTO
	{"NJR_CODENT"}, ;											//COD. ENTIDADE
	{"NJR_NOMENT"}, ;											//NOME ENTIDADE
	{"NJR_LOJENT"}, ;											//LOJA ENTIDADE
	{"NJR_QTDCTR"}, ;											//QTD TOTAL
	{"NN8_QTDFIX"}, ;											//QTD FIXADA
	{"AFIXAR","N",18,2,"@E 999,999,999,999.99",STR0021}	, ;		//QTD A FIXAR
	{"PMEDIO","N",18,2,"@E 999,999,999,999.99",STR0022}	, ;		//PRECO MEDIO
	{"VTOTME","N",18,2,"@E 999,999,999,999.99",STR0023}	, ;		//VL TOTAL MEDIO
	{"VTOTLQ","N",18,2,"@E 999,999,999,999.99",STR0024}	, ;		//VL TOTAL LIQUIDO
	{"VENDA" ,"N",18,2,"@E 999,999,999,999.99",STR0025}	, ;		//QTD ENTREGUE
	{"NJR_QSLFCO"} }											//QTD ENTREGAR

	//{"NJR_TIPFIX"}, ;		//TIPO PREÇO

	vRetVen := AGRCRIATRB(,vVetVen,{"NJR_CODCTR"},STR0002,.T.)	//"OGC002" //FUNCAO DO AGRUTIL01
	cNoT2 := vRetVen[3]	//INDICE
	cAlT2 := vRetVen[4]  //ALIAS         
	aAlT2 := vRetVen[5]	//ARRAY 

	aIndice2 := AGRINDICONS({"NJR_CODCTR"}, aAlT2 )		

	//-- PERGUNTE
	If !Pergunte(STR0002,.T.) //"OGC002"
		Return
	EndIf		


	//-- CRIA ARQUIVOS TEMPORARIOS 
	Processa({|| CRIATRBS()},STR0003)
	ARGSETIFARQUI(cAlT1)	//FUNCAO DO AGRUTIL01
	ARGSETIFARQUI(cAlT2)	//FUNCAO DO AGRUTIL01

	//-- COORDENADAS A AREA TOTAL DA DIALOG
	oSize := FWDefSize():New(.F.)
	oSize:AddObject('ALL',100,100,.T.,.T.)    
	oSize:SetWindowSize(aCoors)
	oSize:aMargins := {3,3,3,3}      
	oSize:lProp 	 := .T.      
	oSize:Process()

	aMatSem := {	{"NJR_STATUS=='P'","Previsto"	,"AL"},;
	{"NJR_STATUS=='A'","Aberto"  	,"VE"},;
	{"NJR_STATUS=='I'","Iniciado"	,"AO"},;
	{"NJR_STATUS=='E'","Cancelado"	,"PO"},;
	{"NJR_STATUS=='F'","Finalizado"	,"VO"}	}


	//-- TELA PRINCIPAL
	oDlg := TDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4],STR0001,,,,,CLR_BLACK,CLR_WHITE,,,.t.) //"Consulta Compra X Venda"

	//-- Instancia o layer
	oFWL := FWLayer():New()			
	//-- Inicia o Layer
	oFWL:Init(oDlg,.F.)			
	//-- Cria uma linha unica para o Layer	
	oFWL:addLine( 'SUP', 50 , .F.)
	oFWL:addLine( 'INF', 50 , .F.)		
	//-- Cria colunas 
	oFWL:addCollumn('ESQ',100,.T.,'INF' )
	oPnlLine1 	:= oFWL:getLinePanel('SUP') 
	oPnlLine 	:= oFWL:getLinePanel('INF') 
	oPnDir    	:= oFWL:getColPanel('ESQ','INF')

	/*+===============================================+
	|| DEFINE -- BROWSE DE CONTRATOS DE COMPRA		||
	+================================================*/
	DEFINE FWFORMBROWSE oBrwP1 DATA TABLE ALIAS cAlT1 DESCRIPTION STR0008 OF oPnlLine1 //"Compra" 			
	oBrwP1:DisableDetails()
	oBrwP1:SetTemporary(.T.)
	oBrwP1:SetFieldFilter(@aArqCompra)
	oBrwP1:SetdbFFilter(.F.)
	oBrwP1:SetUseFilter(.F.)
	oBrwP1:SetSeek(,aIndice1)

	AGRMONTALE(oBrwP1,aMatSem)

	ADD COLUMN oColumn DATA { || &(aArqCompra[2,1]) } TITLE STR0009 SIZE  aArqCompra[2,1]  PICTURE PesqPict("NJR","NJR_CODCTR") 	OF oBrwP1 //"Contrato"
	ADD COLUMN oColumn DATA { || &(aArqCompra[3,1]) } TITLE STR0010 SIZE  aArqCompra[3,1]  PICTURE PesqPict("NJR","NJR_MODAL") 	OF oBrwP1 //"Modalidade"
	ADD COLUMN oColumn DATA { || &(aArqCompra[4,1]) } TITLE STR0011 SIZE  aArqCompra[4,1]  PICTURE PesqPict("NJR","NJR_CODOPE") 	OF oBrwP1 //"Operação"
	ADD COLUMN oColumn DATA { || &(aArqCompra[5,1]) } TITLE STR0012 SIZE  aArqCompra[5,1]  PICTURE "@!"							 	OF oBrwP1 //"Tipo Preço"
	ADD COLUMN oColumn DATA { || &(aArqCompra[6,1]) } TITLE STR0013 SIZE  aArqCompra[6,1]  PICTURE PesqPict("NJR","NJR_MOEDA") 	OF oBrwP1 //"Moeda"
	ADD COLUMN oColumn DATA { || &(aArqCompra[7,1]) } TITLE STR0014 SIZE  aArqCompra[7,1]  PICTURE "@E 999,999,999,999.99"			TYPE TamSX3("NJR_QTDCTR")[3] OF oBrwP1 //"Imposto"
	ADD COLUMN oColumn DATA { || &(aArqCompra[8,1]) } TITLE STR0015 SIZE  aArqCompra[8,1]  PICTURE "@!"							 	OF oBrwP1 //"Tipo Frete"
	ADD COLUMN oColumn DATA { || &(aArqCompra[9,1])}  TITLE STR0016 SIZE  aArqCompra[9,1]  PICTURE PesqPict("NNY","NNY_DATFIM") 	OF oBrwP1 //"Prazo Final"
	ADD COLUMN oColumn DATA { || &(aArqCompra[10,1])} TITLE STR0017 SIZE  aArqCompra[10,1] PICTURE PesqPict("NN7","NN7_DTVENC") 	OF oBrwP1 //"Data Pagto"	
	ADD COLUMN oColumn DATA { || &(aArqCompra[11,1])} TITLE STR0018 SIZE  aArqCompra[11,1] PICTURE PesqPict("NJR","NJR_CODENT") 	OF oBrwP1 //"Entidade"
	ADD COLUMN oColumn DATA { || &(aArqCompra[12,1])} TITLE STR0053 SIZE  aArqCompra[12,1] PICTURE PesqPict("NJR","NJR_NOMENT") 	OF oBrwP1 //"Nome Entidade"
	ADD COLUMN oColumn DATA { || &(aArqCompra[13,1])} TITLE STR0054 SIZE  aArqCompra[13,1] PICTURE PesqPict("NJR","NJR_LOJENT") 	OF oBrwP1 //"Loja Entidade"
	ADD COLUMN oColumn DATA { || &(aArqCompra[14,1])} TITLE STR0019 SIZE  aArqCompra[14,1] PICTURE "@E 999,999,999,999.99"			TYPE TamSX3("NJR_QTDCTR")[3] OF oBrwP1 //"Qtd Total"
	ADD COLUMN oColumn DATA { || &(aArqCompra[15,1])} TITLE STR0020 SIZE  aArqCompra[15,1] PICTURE "@E 999,999,999,999.99"			TYPE TamSX3("NJR_QTDCTR")[3] OF oBrwP1 //"Qtd Fixada"
	ADD COLUMN oColumn DATA { || &(aArqCompra[16,1])} TITLE STR0021 SIZE  aArqCompra[16,1] PICTURE "@E 999,999,999,999.99"			TYPE TamSX3("NJR_QTDCTR")[3] OF oBrwP1 //"Qtd à Fixar"
	ADD COLUMN oColumn DATA { || &(aArqCompra[17,1])} TITLE STR0022 SIZE  aArqCompra[17,1] PICTURE "@E 999,999,999,999.99"			TYPE TamSX3("NJR_QTDCTR")[3] OF oBrwP1 //"Preço Médio"
	ADD COLUMN oColumn DATA { || &(aArqCompra[18,1])} TITLE STR0023 SIZE  aArqCompra[18,1] PICTURE "@E 999,999,999,999.99"			TYPE TamSX3("NJR_QTDCTR")[3] OF oBrwP1 //"Val Total Médio"
	ADD COLUMN oColumn DATA { || &(aArqCompra[19,1])} TITLE STR0024 SIZE  aArqCompra[19,1] PICTURE "@E 999,999,999,999.99"			TYPE TamSX3("NJR_QTDCTR")[3] OF oBrwP1 //"Val Total Liq."
	ADD COLUMN oColumn DATA { || &(aArqCompra[20,1])} TITLE STR0025 SIZE  aArqCompra[20,1] PICTURE "@E 999,999,999,999.99"			TYPE TamSX3("NJR_QTDCTR")[3] OF oBrwP1 //"Qtd Entregue"
	ADD COLUMN oColumn DATA { || &(aArqCompra[21,1])} TITLE STR0026 SIZE  aArqCompra[21,1] PICTURE "@E 999,999,999,999.99"			TYPE TamSX3("NJR_QTDCTR")[3] OF oBrwP1 //"Qtd Entregar"

	ACTIVATE FWFORMBROWSE oBrwP1

	/*+===============================================+
	|| DEFINE -- BROWSE DE CONTRATOS DE VENDA  		||
	+================================================*/
	DEFINE FWFORMBROWSE oBrwP2 DATA TABLE ALIAS cAlT2 DESCRIPTION "Venda" OF oPnlLine //"Venda"			
	oBrwP2:DisableDetails()
	oBrwP2:SetTemporary(.T.)
	oBrwP2:SetFieldFilter(@aArqVenda)
	oBrwP2:SetdbFFilter(.F.)
	oBrwP2:SetUseFilter(.F.)
	oBrwP2:SetSeek(,aIndice2)
	//-- BOTOES
	oBrwP2:AddButton(STR0004	,{||oDlg:End()},,1,,,,'10')						//"Sair"
	oBrwP2:AddButton(STR0005	,{||OGC02RES()},,3,,,,'10') 					//"Posição Resumida Excel"
	oBrwP2:AddButton(STR0006	,{||OGC02DET()},,2,,,,'10')						//"Posição Detalhada Excel"

	AGRMONTALE(oBrwP2,aMatSem)

	ADD COLUMN oColumn DATA { || &(aArqVenda[2,1]) } TITLE STR0009 SIZE  aArqVenda[2,1]  PICTURE PesqPict("NJR","NJR_CODCTR") 	OF oBrwP2 //"Contrato"
	ADD COLUMN oColumn DATA { || &(aArqVenda[3,1]) } TITLE STR0010 SIZE  aArqVenda[3,1]  PICTURE PesqPict("NJR","NJR_MODAL") 	OF oBrwP2 //"Modalidade"
	ADD COLUMN oColumn DATA { || &(aArqVenda[4,1]) } TITLE STR0011 SIZE  aArqVenda[4,1]  PICTURE PesqPict("NJR","NJR_CODOPE") 	OF oBrwP2 //"Operação"
	ADD COLUMN oColumn DATA { || &(aArqVenda[5,1]) } TITLE STR0012	SIZE  aArqVenda[5,1]  PICTURE "@!"							 	OF oBrwP2 //"Tipo Preço"
	ADD COLUMN oColumn DATA { || &(aArqVenda[6,1]) } TITLE STR0013	SIZE  aArqVenda[6,1]  PICTURE PesqPict("NJR","NJR_MOEDA") 	OF oBrwP2 //"Moeda"
	ADD COLUMN oColumn DATA { || &(aArqVenda[7,1]) } TITLE STR0014	SIZE  aArqVenda[7,1]  PICTURE "@E 999,999,999,999.99"		TYPE TamSX3("NJR_QTDCTR")[3] OF oBrwP2 //"Imposto"
	ADD COLUMN oColumn DATA { || &(aArqVenda[8,1]) } TITLE STR0015	SIZE  aArqVenda[8,1]  PICTURE "@!"							 	OF oBrwP2 //"Tipo Frete"
	ADD COLUMN oColumn DATA { || &(aArqVenda[9,1])}  TITLE STR0016	SIZE  aArqVenda[9,1]  PICTURE PesqPict("NNY","NNY_DATFIM")	OF oBrwP2 //"Prazo Final"
	ADD COLUMN oColumn DATA { || &(aArqVenda[10,1])} TITLE STR0017	SIZE  aArqVenda[10,1] PICTURE PesqPict("NN7","NN7_DTVENC") 	OF oBrwP2 //"Data Pagto"	
	ADD COLUMN oColumn DATA { || &(aArqVenda[11,1])} TITLE STR0018 SIZE  aArqVenda[11,1] PICTURE PesqPict("NJR","NJR_CODENT") 	OF oBrwP2 //"Entidade"
	ADD COLUMN oColumn DATA { || &(aArqVenda[12,1])} TITLE STR0053 SIZE  aArqVenda[12,1] PICTURE PesqPict("NJR","NJR_NOMENT") OF oBrwP2 //"Nome Entidade"
	ADD COLUMN oColumn DATA { || &(aArqVenda[13,1])} TITLE STR0054 SIZE  aArqVenda[13,1] PICTURE PesqPict("NJR","NJR_LOJENT") OF oBrwP2 //"Loja Entidade"
	ADD COLUMN oColumn DATA { || &(aArqVenda[14,1])} TITLE STR0019 SIZE  aArqVenda[14,1] PICTURE "@E 999,999,999,999.99"		TYPE TamSX3("NJR_QTDCTR")[3] OF oBrwP2 //"Qtd Total"
	ADD COLUMN oColumn DATA { || &(aArqVenda[15,1])} TITLE STR0020	SIZE  aArqVenda[14,1] PICTURE "@E 999,999,999,999.99"		TYPE TamSX3("NJR_QTDCTR")[3] OF oBrwP2 //"Qtd Fixada"
	ADD COLUMN oColumn DATA { || &(aArqVenda[16,1])} TITLE STR0021	SIZE  aArqVenda[16,1] PICTURE "@E 999,999,999,999.99"		TYPE TamSX3("NJR_QTDCTR")[3] OF oBrwP2 //"Qtd à Fixar"
	ADD COLUMN oColumn DATA { || &(aArqVenda[17,1])} TITLE STR0022	SIZE  aArqVenda[17,1] PICTURE "@E 999,999,999,999.99"		TYPE TamSX3("NJR_QTDCTR")[3] OF oBrwP2 //"Preço Médio"
	ADD COLUMN oColumn DATA { || &(aArqVenda[18,1])} TITLE STR0023	SIZE  aArqVenda[18,1] PICTURE "@E 999,999,999,999.99"		TYPE TamSX3("NJR_QTDCTR")[3] OF oBrwP2 //"Val Total Médio"
	ADD COLUMN oColumn DATA { || &(aArqVenda[19,1])} TITLE STR0024	SIZE  aArqVenda[19,1] PICTURE "@E 999,999,999,999.99"		TYPE TamSX3("NJR_QTDCTR")[3] OF oBrwP2 //"Val Total Liq."
	ADD COLUMN oColumn DATA { || &(aArqVenda[20,1])} TITLE STR0025	SIZE  aArqVenda[20,1] PICTURE "@E 999,999,999,999.99"		TYPE TamSX3("NJR_QTDCTR")[3] OF oBrwP2 //"Qtd Entregue"
	ADD COLUMN oColumn DATA { || &(aArqVenda[21,1])} TITLE STR0026	SIZE  aArqVenda[21,1] PICTURE "@E 999,999,999,999.99"		TYPE TamSX3("NJR_QTDCTR")[3] OF oBrwP2 //"Qtd Entregar"

	ACTIVATE FWFORMBROWSE oBrwP2

	ACTIVATE MSDIALOG oDlg CENTER
Return
/*
############################################################################
# Função   : CRIATRBS                                                      #
# Descrição: Filtra tabelas, cria e carrega arquivos temporários           #
# Autor    : Ana Laura Olegini                                             #
# Data     : 31/10/2014                                                    #  
############################################################################
*/
Static Function CRIATRBS(nOp)

	Local nx			:= 0
	Local nXC 			:= 0
	Local nXV 			:= 0
	Local nQtdReg 		:= 0

	Local nMediaC		:= 0
	Local nQtdFixC 		:= 0
	Local nCMedia 		:= 0
	Local nQtdFiTC 		:= 0

	Local nMediaV		:= 0
	Local nQtdFixV 		:= 0
	Local nVMedia 		:= 0
	Local nQtdFiTV 		:= 0	

	Local cQueryC 		:= ""	// COMPRA
	Local cMediaC		:= ""	// PARA MEDIA COMPRA
	Local cQueryV 		:= ""	// VENDA
	Local cMediaV		:= ""	// PARA MEDIA VENDA	
	Local cTIPFIXC		:= ""	// TIPO PRECO
	Local cTIPFIXV   	:= ""	// TIPO PRECO
	Local lTpoBrwP1     := Type("oBrwP1") <> "U"
	Private cAliasC  	:= GetNextAlias()     // Retorna o próximo Alias disponível COMPRA
	Private cAliasV  	:= GetNextAlias()     // Retorna o próximo Alias disponível VENDA
	Private cAlMedC		:= GetNextAlias()     // Retorna o próximo Alias disponível MEDIA COMPRA
	Private cAlMedV		:= GetNextAlias()     // Retorna o próximo Alias disponível MEDIA VENDA


	/*+================================================================================================+
	|| QUERY -- BUSCA DO CONTRATOS DE COMPRA CONFORME PARAMETROS DE TELA [MV_PAR01] [MV_PAR02]  		||
	+=================================================================================================*/		
	cQueryC := " SELECT NJR.NJR_STATUS, NJR.NJR_CODCTR, NJR.NJR_MODAL, NJR.NJR_CODOPE, NJR.NJR_TIPFIX, " 
	cQueryC +=        " NJR.NJR_MOEDA, NJR.NJR_TPFRET, NJR.NJR_CODENT, NJR.NJR_QTDCTR, NJR.NJR_QSLFCO, NJR.NJR_LOJENT," 
	cQueryC +=        " (NJR.NJR_QTEFCO - NJR.NJR_QTSFCO) COMPRA, MAX(NNY.NNY_DATFIM) DATFIM, "
	cQueryC +=        " MAX(NN7.NN7_DTVENC) DTVENC, NJR.NJR_CODSAF, NJR.NJR_CODPRO, NJR.NJR_VLRUNI "
	cQueryC +=   " FROM "+ RetSqlName("NJR") + " NJR "	
	cQueryC +=  " LEFT JOIN "+ RetSqlName("NNY") + " NNY ON NNY.NNY_FILIAL = '" + xFilial( 'NNY' ) + "'"  
	cQueryC +=                                         " AND NNY.D_E_L_E_T_ = '' " 
	cQueryC +=                                         " AND NNY.NNY_CODCTR = NJR.NJR_CODCTR "
	cQueryC +=  " LEFT JOIN "+ RetSqlName("NN7") + " NN7 ON NN7.NN7_FILIAL = '" + xFilial( 'NN7' ) + "'"    
	cQueryC +=                                         " AND NN7.D_E_L_E_T_ = '' "
	cQueryC +=                                         " AND NN7.NN7_CODCTR = NJR.NJR_CODCTR "
	cQueryC += "  WHERE NJR.NJR_FILIAL = '" + xFilial( 'NJR' ) + "'"	 
	cQueryC +=    " AND NJR.D_E_L_E_T_ = '' "	 
	cQueryC +=    " AND NJR.NJR_TIPO   = '1' "						// TIPO 1=COMPRA
	cQueryC +=    " AND NJR.NJR_CODSAF = '" + mv_par01 + "'"		// SAFRA
	cQueryC +=    " AND NJR.NJR_CODPRO = '" + mv_par02 + "'"		// PRODUTO

	If mv_par05 == 2 //Nao mostra contratos cancelados
		cQueryC += " AND NJR.NJR_STATUS <> 'E'"
	EndIf

	cQueryC +=  " GROUP BY NJR_CODSAF, NJR_CODPRO, NJR_TIPO, NJR_CODCTR, NJR_MODAL, NJR_CODOPE, NJR_TIPFIX, NJR_MOEDA,NJR_TPFRET, " 
	cQueryC +=           " NJR_CODENT, NJR_LOJENT, NJR_QTDCTR, NJR_QSLFCO, NJR_QTEFCO, NJR_QTSFCO, NJR_VLRUNI , NJR_STATUS"
	cQueryC := ChangeQuery(cQueryC)
	//-- VERIFICA SE EXISTE - SE SIM APAGA TABELA TEMP
	If Select(cAliasC) <> 0
		(cAliasC)->(dbCloseArea())
	EndIf
	//-- DEFINE UM ARQUIVO DE DADOS COMO UMA AREA DE TRABALHO DISPONIVEL NA APLICACAO
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryC),cAliasC,.T.,.T.)

	COUNT TO nQtdReg 	//-- USE UMA VARIAVEL(NREC) P/ RECEBER O CONTADOR DE REGISTRO(COUNT)

	dbSelectArea(cAlt1)
	Zap

	dbSelectArea(cAliasC)
	(cAliasC)->(dbGoTop())

	nReg 	 := 0
	nContMC := 0
	While (cAliasC)->(!Eof())    
		nReg ++ 
		IncProc(STR0007+"  "+Alltrim(Str(nReg,5))+" / "+Alltrim(Str(nQtdReg,5)))  //"Processando registro"

		/*+=============================================================+
		|| 	QUERY -- BUSCA E CALCULA A MEDIA E SOMA DA QTD FIXADA  		||
		+==============================================================*/		
		cMediaC := " SELECT  NN8_TIPOFX, NN8.NN8_QTDFIX, NN8.NN8_VLRUNI, NN8.NN8_VALUNI "
		cMediaC +=   " FROM "+ RetSqlName("NN8") + " NN8 "	
		cMediaC +=  " WHERE NN8_FILIAL = '" + xFilial( 'NN8' ) + "'"	
		//cMediaC +=    " AND NN8_TIPOFX = '" + cTipoFix + "'"
		cMediaC +=    " AND NN8_CODCTR = '" + (cAliasC)->NJR_CODCTR + "'"
		cMediaC +=    " AND D_E_L_E_T_ = '' "
		cMediaC := ChangeQuery(cMediaC)
		//-- VERIFICA SE EXISTE - SE SIM APAGA TABELA TEMP
		If Select(cAlMedC) <> 0
			(cAlMedC)->(dbCloseArea())
		EndIf
		//-- DEFINE UM ARQUIVO DE DADOS COMO UMA AREA DE TRABALHO DISPONIVEL NA APLICACAO
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cMediaC),cAlMedC,.T.,.T.)

		COUNT TO nContMC

		dbSelectArea(cAlMedC)
		(cAlMedC)->(dbGoTop())

		nMediaC 	:= 0
		nCMedia	:= 0
		nQtdFixC	:= 0
		nQtdFiTC	:= 0

		/*+=================================+
		|| 	TRATAMENTO DO PRECO MEDIO    	||
		|| -> mv_par03 - 1 Preco Fixado	 	||
		|| -> mv_par04 - 2 Preco Previsto	||
		+==================================*/			
		If mv_par03 = 1 .AND. nContMC = 0

			nMediaC := 0

		ElseIf mv_par03 = 1 .AND. nContMC > 0 .AND. (cAlMedC)->NN8_TIPOFX = '1'

			For nXC := 1 TO nContMC		

				nQtdFixC := (cAlMedC)->NN8_QTDFIX*(cAlMedC)->NN8_VLRUNI

				If nXC = 1
					nCMedia  := nQtdFixC
					nQtdFiTC := (cAlMedC)->NN8_QTDFIX
				Else
					nCMedia  += nQtdFixC
					nQtdFiTC += (cAlMedC)->NN8_QTDFIX
				EndIf

				(cAlMedC)->(dbSkip())
			Next nXC

			nMediaC := nCMedia/nQtdFiTC

		ElseIf mv_par03 = 2 .AND. nContMC = 0

			nMediaC := (cAliasC)->NJR_VLRUNI

		ElseIf mv_par03 = 2 .AND. nContMC > 0 .AND. (cAlMedC)->NN8_TIPOFX = '1'

			For nXC := 1 TO nContMC		

				nQtdFixC := (cAlMedC)->NN8_QTDFIX*(cAlMedC)->NN8_VLRUNI

				If nXC = 1
					nCMedia  := nQtdFixC
					nQtdFiTC := (cAlMedC)->NN8_QTDFIX
				Else
					nCMedia  += nQtdFixC
					nQtdFiTC += (cAlMedC)->NN8_QTDFIX
				EndIf

				(cAlMedC)->(dbSkip())
			Next nXC

			nMediaC := nCMedia/nQtdFiTC		
		EndIf			


		cTIPFIXC := If ((cAliasC)->NJR_TIPFIX = "1", STR0033, STR0034) //"Fixo"###"A fixar"

		/*+=============================================================+
		|| 	GRAVA NO ARQUIVO TEMPORARIO DE CONTRATO DE COMPRA COM REGRAS||
		+==============================================================*/			
		Reclock(cAlt1, .T.)
		(cAlt1)->NJR_STATUS 	:= (cAliasC)->NJR_STATUS

		(cAlt1)->NJR_CODCTR 	:= (cAliasC)->NJR_CODCTR								//CONTRATO
		(cAlt1)->NJR_MODAL 		:= (cAliasC)->NJR_MODAL								//MODALIDADE
		(cAlt1)->NJR_CODOPE		:= (cAliasC)->NJR_CODOPE								//OPERACAO
		//(cAlt1)->NJR_TIPFIX 	:= (cAliasC)->NJR_TIPFIX								//TIPO PRECO
		(cAlt1)->TIPFIX 		:= cTIPFIXC											//TIPO PRECO
		(cAlt1)->NJR_MOEDA 		:= (cAliasC)->NJR_MOEDA								//TIPO MOEDA
		(cAlt1)->IMPOSTO		:= OGC002FUN((cAliasC)->NJR_QTDCTR)				//IMPOSTO				-- FUNCAO MV_CONTSOC 
		(cAlt1)->TPFRET  		:= 	If((cAliasC)->NJR_TPFRET="C","CIF","FOB")		//TIPO FRETE
		(cAlt1)->DATFIM	 		:= StoD((cAliasC)->DATFIM)							//PRAZO FINAL			-- DATA MAXIMA
		(cAlt1)->DTVENC 		:= StoD((cAliasC)->DTVENC)							//DATA PGTO			-- DATA MAXIMA
		(cAlt1)->NJR_CODENT 	:= (cAliasC)->NJR_CODENT								//ENTIDADE
		(cAlt1)->NJR_NOMENT 	:= POSICIONE('NJ0',1,XFILIAL('NJ0')+(cAliasC)->NJR_CODENT+(cAliasC)->NJR_LOJENT,'NJ0_NOME')    //NOME ENTIDADE
		(cAlt1)->NJR_LOJENT 	:= (cAliasC)->NJR_LOJENT								//LOJA ENTIDADE
		(cAlt1)->NJR_QTDCTR 	:= (cAliasC)->NJR_QTDCTR								//QTD TOTAL		
		(cAlt1)->NN8_QTDFIX  	:=  nQtdFiTC											//QTD FIXADA			-- BUSCA TABELA FIXACAO[NN8] - SOMA [NN8_QTDFIX]
		(cAlt1)->AFIXAR      	:= (cAliasC)->NJR_QTDCTR-(cAlt1)->NN8_QTDFIX   	//QTD A FIXAR			-- QTD TOTAL - QTD FIXADA
		(cAlt1)->PMEDIO	 		:=  nMediaC											//PRECO MEDIO			-- FUNCAO TRATAMENTO DO PRECO MEDIO
		(cAlt1)->VTOTME	 		:= (cAliasC)->NJR_QTDCTR*(cAlt1)->PMEDIO			//VAL TOTAL MEDIO    -- QTD TOTAL * PRECO MEDIO 
		(cAlt1)->VTOTLQ	 		:= (cAlt1)->VTOTME-(cAlt1)->IMPOSTO				//VAL TOTAL LIQUIDO	-- VL TOTAL MEDIO - IMPOSTO 
		(cAlt1)->COMPRA	 		:= (cAliasC)->COMPRA									//QTD ENTREGUE		-- [NJR.NJR_QTEFCO - NJR.NJR_QTSFCO] TRATADO QUERY [cAliasC]
		(cAlt1)->NJR_QSLFCO 	:= (cAliasC)->NJR_QSLFCO								//QTD ENTREGAR		
		MsUnlock()
		(cAliasC)->(dbSkip())
		//-- CONTROLE QUERY [cAlMedC]
		cMediaC := ""
		(cAlMedC)->(dbCloseArea())
	End	

	(cAliasC)->(dbCloseArea())

	//-- MONTA GRIDS
	ARGSETIFARQUI(cAlT1)	//FUNCAO DO AGRUTIL01
	AGRAREAORDE(cAlt1,1)	//FUNCAO DO AGRUTIL01

	//-- ALIMENTA O ARRAY PARA IMPRIMIR NA TELA
	aArqCompra := {}
	For nx := 1 To Len(aAlt1)
		Aadd(aArqCompra,{aAlT1[nx,1],aAlT1[nx,5],aAlT1[nx,2],aAlT1[nx,3],aAlT1[nx,4],Alltrim(aAlT1[nx,6])})
	Next nx
	If lTpoBrwP1
		oBrwP1:Refresh(.T.)
	EndIf

	/*+================================================================================================+
	|| QUERY -- BUSCA DO CONTRATOS DE VENDA CONFORME PARAMETROS DE TELA [MV_PAR01] [MV_PAR02]  		||
	+=================================================================================================*/	
	cQueryV := " SELECT NJR.NJR_STATUS, NJR.NJR_CODCTR, NJR.NJR_MODAL, NJR.NJR_CODOPE, NJR.NJR_TIPFIX, " 
	cQueryV +=        " NJR.NJR_MOEDA, NJR.NJR_TPFRET, NJR.NJR_CODENT, NJR.NJR_QTDCTR, NJR.NJR_QSLFCO, NJR.NJR_LOJENT," 
	cQueryV +=        " (NJR.NJR_QTSFCO - NJR.NJR_QTEFCO) VENDA, MAX(NNY.NNY_DATFIM) DATFIM, "
	cQueryV +=        "  MAX(NN7.NN7_DTVENC) DTVENC, NJR.NJR_CODSAF, NJR.NJR_CODPRO, NJR.NJR_VLRUNI " 
	cQueryV +=   " FROM "+ RetSqlName("NJR") + " NJR "	
	cQueryV +=  " LEFT JOIN "+ RetSqlName("NNY") + " NNY ON NNY.NNY_FILIAL = '" + xFilial( 'NNY' ) + "'"   
	cQueryV +=                                         " AND NNY.D_E_L_E_T_ = '' " 
	cQueryV +=                                         " AND NNY.NNY_CODCTR = NJR.NJR_CODCTR "  
	cQueryV +=  " LEFT JOIN "+ RetSqlName("NN7") + " NN7 ON NN7.NN7_FILIAL = '" + xFilial( 'NN7' ) + "'"      
	cQueryV +=                                         " AND NN7.D_E_L_E_T_ = '' "
	cQueryV +=                                         " AND NN7.NN7_CODCTR = NJR.NJR_CODCTR "
	cQueryV += "  WHERE NJR.NJR_FILIAL = '" + xFilial( 'NJR' ) + "'"	 
	cQueryV +=    " AND NJR.D_E_L_E_T_ = '' "	 
	cQueryV +=    " AND NJR.NJR_TIPO   = '2' "						//TIPO 2=VENDA
	cQueryV +=    " AND NJR.NJR_CODSAF = '" + mv_par01 + "'"		// SAFRA
	cQueryV +=    " AND NJR.NJR_CODPRO = '" + mv_par02 + "'"		// PRODUTO

	If .NOT. Empty (mv_par05) 
		If mv_par05 == 2 //Nao mostra contratos cancelados
			cQueryV += " AND NJR.NJR_STATUS <> 'E'"
		EndIf
	EndIf

	cQueryV +=  " GROUP BY NJR_CODSAF, NJR_CODPRO, NJR_TIPO, NJR_CODCTR, NJR_MODAL, NJR_CODOPE, NJR_TIPFIX, NJR_MOEDA,NJR_TPFRET, " 
	cQueryV +=           " NJR_CODENT, NJR_LOJENT, NJR_QTDCTR, NJR_QSLFCO, NJR_QTEFCO, NJR_QTSFCO, NJR_VLRUNI, NJR_STATUS "
	cQueryV := ChangeQuery(cQueryV)
	//-- VERIFICA SE EXISTE - SE SIM APAGA TABELA TEMP
	If Select(cAliasV) <> 0
		(cAliasV)->(dbCloseArea())
	EndIf
	//-- DEFINE UM ARQUIVO DE DADOS COMO UMA AREA DE TRABALHO DISPONIVEL NA APLICACAO
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryV),cAliasV,.T.,.T.)

	nQtdReg := 0
	COUNT TO nQtdReg 	//-- USE UMA VARIAVEL(NREC) P/ RECEBER O CONTADOR DE REGISTRO(COUNT)

	dbSelectArea(cAlt2)
	Zap

	dbSelectArea(cAliasV)
	(cAliasV)->(dbGoTop())

	nReg     := 0
	nContMV  := 0
	While (cAliasV)->(!Eof())    
		nReg ++ 
		IncProc(STR0007+"  "+Alltrim(Str(nReg,5))+" / "+Alltrim(Str(nQtdReg,5)))

		/*+=============================================================+
		|| 	QUERY -- BUSCA E CALCULA A MEDIA E SOMA DA QTD FIXADA  		||
		+==============================================================*/	
		cMediaV := " SELECT NN8_TIPOFX, NN8_QTDFIX,NN8_VLRUNI,NN8_VALUNI  "
		cMediaV +=   " FROM "+ RetSqlName("NN8") + " NN8 "	
		cMediaV +=  " WHERE NN8_FILIAL = '" + xFilial( 'NN8' ) + "'"	
		//cMediaV +=    " AND NN8_TIPOFX = '1' "
		cMediaV +=    " AND NN8_CODCTR 		= '" + (cAliasV)->NJR_CODCTR + "'"
		cMediaV +=    " AND D_E_L_E_T_ = '' "
		cMediaV := ChangeQuery(cMediaV)
		//-- VERIFICA SE EXISTE - SE SIM APAGA TABELA TEMP
		If Select(cAlMedV) <> 0
			(cAlMedV)->(dbCloseArea())
		EndIf
		//-- DEFINE UM ARQUIVO DE DADOS COMO UMA AREA DE TRABALHO DISPONIVEL NA APLICACAO
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cMediaV),cAlMedV,.T.,.T.)

		COUNT TO nContMV

		dbSelectArea(cAlMedV)
		(cAlMedV)->(dbGoTop())


		nMediav 	:= 0
		nVMedia	:= 0
		nQtdFixV	:= 0
		nQtdFiTV	:= 0

		/*+=================================+
		|| 	TRATAMENTO DO PRECO MEDIO    	||
		|| -> mv_par03 - 1 Preco Fixado	 	||
		|| -> mv_par04 - 2 Preco Previsto	||
		+==================================*/			
		If mv_par03 = 1 .AND. nContMV = 0

			nMediaV := 0

		ElseIf mv_par03 = 1 .AND. nContMV > 0 .AND. (cAlMedV)->NN8_TIPOFX = '1'

			For nXV := 1 TO nContMV		

				nQtdFixV := (cAlMedV)->NN8_QTDFIX*(cAlMedV)->NN8_VLRUNI

				If nXV = 1
					nVMedia  := nQtdFixV
					nQtdFiTV := (cAlMedV)->NN8_QTDFIX
				Else
					nVMedia  += nQtdFixV
					nQtdFiTV += (cAlMedV)->NN8_QTDFIX
				EndIf

				(cAlMedV)->(dbSkip())
			Next nXV

			nMediaV := nVMedia/nQtdFiTV 

		ElseIf mv_par03 = 2 .AND. nContMV = 0

			nMediaV := (cAliasV)->NJR_VLRUNI

		ElseIf mv_par03 = 2 .AND. nContMV > 0 .AND. (cAlMedV)->NN8_TIPOFX = '1'

			For nXV := 1 TO nContMV		

				nQtdFixV := (cAlMedV)->NN8_QTDFIX*(cAlMedV)->NN8_VLRUNI

				If nXV = 1
					nVMedia  := nQtdFixV
					nQtdFiTV := (cAlMedV)->NN8_QTDFIX
				Else
					nVMedia  += nQtdFixV
					nQtdFiTV += (cAlMedV)->NN8_QTDFIX
				EndIf

				(cAlMedV)->(dbSkip())
			Next nXV

			nMediaV := nVMedia/nQtdFiTV		
		EndIf	

		cTIPFIXV := If ((cAliasV)->NJR_TIPFIX = "1", STR0033, STR0034) //"Fixo"###"A fixar"

		/*+=============================================================+
		|| 	GRAVA NO ARQUIVO TEMPORARIO DE CONTRATO DE VENDA COM REGRAS ||
		+==============================================================*/						
		Reclock(cAlt2, .T.)
		(cAlt2)->NJR_STATUS 	:= (cAliasV)->NJR_STATUS
		(cAlt2)->NJR_CODCTR 	:= (cAliasV)->NJR_CODCTR								//CONTRATO
		(cAlt2)->NJR_MODAL 		:= (cAliasV)->NJR_MODAL								//MODALIDADE
		(cAlt2)->NJR_CODOPE		:= (cAliasV)->NJR_CODOPE								//OPERACAO
		//(cAlt2)->NJR_TIPFIX 	:= (cAliasV)->NJR_TIPFIX								//TIPO PRECO
		(cAlt2)->TIPFIX 		:= cTIPFIXV											//TIPO PRECO
		(cAlt2)->NJR_MOEDA 		:= (cAliasV)->NJR_MOEDA								//TIPO MOEDA
		(cAlt2)->IMPOSTO		:= OGC002FUN((cAliasV)->NJR_QTDCTR)				//IMPOSTO				-- FUNCAO MV_CONTSOC
		(cAlt2)->TPFRET  		:= If((cAliasV)->NJR_TPFRET="C","CIF","FOB")		//TIPO FRETE
		(cAlt2)->DATFIM 		:= StoD((cAliasV)->DATFIM)							//PRAZO FINAL			-- DATA MAXIMA
		(cAlt2)->DTVENC 		:= StoD((cAliasV)->DTVENC)							//DATA PGTO			-- DATA MAXIMA
		(cAlt2)->NJR_CODENT 	:= (cAliasV)->NJR_CODENT								//ENTIDADE
		(cAlt2)->NJR_NOMENT 	:= POSICIONE('NJ0',1,XFILIAL('NJ0')+(cAliasV)->NJR_CODENT+(cAliasV)->NJR_LOJENT,'NJ0_NOME')    //NOME ENTIDADE
		(cAlt2)->NJR_LOJENT 	:= (cAliasV)->NJR_LOJENT								//LOJA ENTIDADE
		(cAlt2)->NJR_QTDCTR 	:= (cAliasV)->NJR_QTDCTR								//QTD TOTAL
		(cAlt2)->NN8_QTDFIX  	:= nQtdFiTV						 					//QTD FIXADA			-- BUSCA TABELA FIXACAO[NN8] - SOMA [NN8_QTDFIX]	
		(cAlt2)->AFIXAR      	:= (cAliasV)->NJR_QTDCTR-(cAlt2)->NN8_QTDFIX   	//QTD A FIXAR			-- QTD TOTAL - QTD FIXADA
		(cAlt2)->PMEDIO	 		:= nMediaV												//PRECO MEDIO			-- FUNCAO TRATAMENTO DO PRECO MEDIO
		(cAlt2)->VTOTME	 		:= (cAliasV)->NJR_QTDCTR*(cAlt2)->PMEDIO			//VAL TOTAL MEDIO    -- QTD TOTAL * PRECO MEDIO  
		(cAlt2)->VTOTLQ	 		:= (cAlt2)->VTOTME-(cAlt2)->IMPOSTO				//VAL TOTAL LIQUIDO	-- VL TOTAL MEDIO - IMPOSTO  
		(cAlt2)->VENDA	 		:= (cAliasV)->VENDA									//QTD ENTREGUE		-- [NJR.NJR_QTSFCO - NJR.NJR_QTEFCO] TRATADO QUERY [cAliasC]
		(cAlt2)->NJR_QSLFCO 	:= (cAliasV)->NJR_QSLFCO								//QTD ENTREGAR
		MsUnlock(cAlt2)
		(cAliasV)->(dbSkip())
		//-- CONTROLE QUERY [cAlMedV]
		cMediaV := ""
		(cAlMedV)->(dbCloseArea())
	End	

	(cAliasV)->(dbCloseArea())

	//-- MONTA GRIDS
	ARGSETIFARQUI(cAlT2)	//FUNCAO DO AGRUTIL01
	AGRAREAORDE(cAlt2,1)	//FUNCAO DO AGRUTIL01

	//-- ALIMENTA O ARRAY PARA IMPRIMIR NA TELA
	aArqVenda := {}
	For nx := 1 To Len(aAlt2)
		Aadd(aArqVenda,{aAlT2[nx,1],aAlT2[nx,5],aAlT2[nx,2],aAlT2[nx,3],aAlT2[nx,4],Alltrim(aAlT2[nx,6])})
	Next nx
	If Type("oBrwP2") <> "U"
		oBrwP2:Refresh(.T.)
	EndIf

	(cAlT2)->(dbGoTop())
	(cAlT1)->(dbGoTop())

Return
/*
###################################################################################
# Função   : OGC002FUN                                                            #
# Descrição: Calculo Imposto parametro MV_CONTSOC - FUNRURAL					     #
# Autor    : Ana Laura Olegini                                                    #
# Data     : 31/10/2014                                                           #  
###################################################################################
*/
Function OGC002FUN(nTotal)	
	Local cFunrur		:= ""
	Local cProduto 	:= mv_par02
	Local nAcValFun 	:= 0

	//VERIFICA NA FUNCAO SE O REGISTRO EXISTE NA BASE DE DADOS
	AGRIFDBSEEK("SB1",cProduto,1,.F.)
	cFunrur := SB1->B1_CONTSOC  //-- Indica se o Produto incide a Contribuição Seguridade Social (Funrural)

	nPerFun := GetMV("MV_CONTSOC") // L=2,2 F= 2,3 J=2,7

	//-- CALCULA IMPOSTO FUNRURAL
	nValFun := NoRound(a100FunRural(cFunrur,.T.,.T.,nTotal,nPerFun),2,nAcValFun)
Return ABS(nValFun)
/*
###################################################################################
# Função   : OGC02DET                                                             #
# Descrição: Exporta informações da tela para o excel - Detalhado                 #
# Autor    : Ana Laura Olegini                                                    #
# Data     : 31/10/2014                                                           #  
###################################################################################
*/
Static Function OGC02DET()

	Local aStru		:= {}	
	Local cArquivo 	:= STR0029 // Posição Detalhada
	Local cCODSAF 	:= mv_par01
	Local cCODPRO 	:= mv_par02	
	Local cCrLf 		:= Chr(13) + Chr(10)
	Local cDirDocs   	:= MsDocPath() 
	Local cPath		:= AllTrim(GetTempPath())
	Local oExcelApp
	Local nHandle
	Local nX
	Local nContC := 0
	Local nContV := 0
	//VARIAVEIS DE TOTALIZADORES COMPRA
	Local nQtdTot1 := 0 
	Local nQtdFix1 := 0
	Local nQtdAFi1 := 0
	Local nPreMed1 := 0
	Local nVlTMed1 := 0
	Local nVlTliq1 := 0
	Local nQtdEtg1 := 0
	Local nQtdAEg1 := 0
	//VARIAVEIS DE TOTALIZADORES VENDA
	Local nQtdTot2 := 0
	Local nQtdFix2 := 0
	Local nQtdAFi2 := 0
	Local nPreMed2 := 0
	Local nVlTMed2 := 0
	Local nVlTliq2 := 0
	Local nQtdEtg2 := 0
	Local nQtdAEg2 := 0

	Local nPreMed11 := 0
	Local nPreMed22 := 0

	//-- MONTA ESTRUTURA PARA CABECALHO IMPRESSAO
	aStru := {	{STR0009	,"C", 40, 0},; //Contrato
	{STR0010	,"C", 06, 0},; //Modalidade
	{STR0011	,"C", 06, 0},; //Operação
	{STR0012	,"C", 06, 0},; //Tipo Preço
	{STR0013	,"C", 03, 0},; //Moeda
	{STR0014	,"N", 20, 2},; //Imposto
	{STR0015	,"C", 03, 0},; //Tipo Frete
	{STR0016  	,"D", 08, 0},; //Prazo Final
	{STR0017 	,"D", 08, 0},; //Data Pagto
	{STR0018 	,"C", 30, 0},; //Entidade
	{STR0053    ,"C", 40, 0},; //Nome da Entidade
	{STR0054    ,"C", 02, 0},; //Loja da Entidade
	{STR0019 	,"N", 20, 2},; //Qtd Total
	{STR0020	,"N", 20, 2},; //Qtd Fixada
	{STR0021	,"N", 20, 2},; //Qtd á Fixar
	{STR0022	,"N", 20, 2},; //Preço Médio
	{STR0023	,"N", 20, 2},; //Val Total Medio
	{STR0024	,"N", 20, 2},; //Val Total Liq
	{STR0025	,"N", 20, 2},; //Qtd Entregue
	{STR0026	,"N", 20, 2} } //Qtd Entregar 

	//-- CHAMA QUERY PARA ATUALIZAR
	CRIATRBS()

	//-- VERIFICA SE CRIA ARQUIVO
	nHandle := MsfCreate(cDirDocs + "\" + cArquivo + ".CSV",0)
	If nHandle > 0
		IncProc(STR0030) //"Aguarde! Gerando arquivo de integração com Excel..."

		//PRIMEIRA LINHA
		FWrite(nHandle, STR0031 	+ ";" ) //"Posição Detalhada Compra X Venda"
		FWrite(nHandle, cCrLf ) // Pula linha
		FWrite(nHandle, cCrLf ) // Pula linha

		//CABECALHO		
		FWrite(nHandle, STR0027 	+ ";" ) //"Safra:"
		FWrite(nHandle, Alltrim(cCODSAF) + ";" )
		FWrite(nHandle, cCrLf ) // Pula linha
		FWrite(nHandle, STR0028	+ ";" ) //"Produto:"
		FWrite(nHandle, Alltrim(cCODPRO) + ";" )
		FWrite(nHandle, Alltrim(POSICIONE("SB1", 1, xFilial("SB1") + cCODPRO, "B1_DESC")) + ";" )
		FWrite(nHandle, cCrLf ) // Pula linha
		FWrite(nHandle, cCrLf ) // Pula linha


		/*+==================================+
		||  BLOCO DE CONTRATO DE COMPRAS	 ||
		+===================================*/
		FWrite(nHandle, Alltrim(STR0032) + ";" )	//"Contrato de Compras"
		FWrite(nHandle, cCrLf ) // Pula linha

		//-- Grava o cabecalho do arquivo
		aEval(aStru, {|e, nX| FWrite(nHandle, e[1] + If(nX < Len(aStru), ";", "") ) } )
		FWrite(nHandle, cCrLf ) // Pula linha

		While (cAlt1)->(!Eof()) 			
			//TRATA VARIAVEIS
			cMODAL  := POSICIONE("NK5", 1, xFilial("NK5") + ((cAlt1))->NJR_MODAL,  "NK5_DESMOD")
			cDESOPE := POSICIONE("NNO", 1, xFilial("NNO") + ((cAlt1))->NJR_CODOPE, "NNO_DESCRI") 
			dDATFIM := (cAlt1)->DATFIM
			dDTVENC := (cAlt1)->DTVENC				

			//FAZ A IMPRESSAO NO EXCEL
			FWrite(nHandle, CHR(160)+Alltrim((cAlt1)->NJR_CODCTR)									+ ";" )	//CONTARO
			FWrite(nHandle, CHR(160)+Alltrim(cMODAL)												+ ";" )	//MODALIDADE
			FWrite(nHandle, CHR(160)+Alltrim(cDESOPE)												+ ";" ) //DESCRICAO OPERACAO
			FWrite(nHandle, CHR(160)+Alltrim((cAlt1)->TIPFIX)										+ ";" ) //TIPO FIXO
			FWrite(nHandle, Alltrim(Transform((cAlt1)->NJR_MOEDA	, "@E 999" ))					+ ";" ) //MOEDA
			FWrite(nHandle, Alltrim(Transform((cAlt1)->IMPOSTO		, "@E 999,999,999,999.99" )) 	+ ";" )	//IMPOSTO
			FWrite(nHandle, CHR(160)+Alltrim((cAlt1)->TPFRET)										+ ";" ) //TIPO FRETE
			FWrite(nHandle, CHR(160)+Alltrim(Transform(dDATFIM		, "@D 99/99/9999" ))			+ ";" )	//PRAZO FINAL
			FWrite(nHandle, CHR(160)+Alltrim(Transform(dDTVENC		, "@D 99/99/9999" ))			+ ";" )	//DATA PAGTO
			FWrite(nHandle, CHR(160)+Alltrim((cAlt1)->NJR_CODENT)									+ ";" )	//ENTIDADE
			FWrite(nHandle, CHR(160)+Alltrim((cAlt1)->NJR_NOMENT)									+ ";" )	//NOME ENTIDADE
			FWrite(nHandle, CHR(160)+Alltrim((cAlt1)->NJR_LOJENT)									+ ";" )	//LOJA ENTIDADE
			FWrite(nHandle, Alltrim(Transform((cAlt1)->NJR_QTDCTR	, "@E 999,999,999,999.99" )) 	+ ";" )	//QTD TOTAL
			FWrite(nHandle, Alltrim(Transform((cAlt1)->NN8_QTDFIX	, "@E 999,999,999,999.99" ))	+ ";" )	//QTD FIXADA -- BUSCA TABELA FIXACAO[NN8] - SOMA [NN8_QTDFIX]
			FWrite(nHandle, Alltrim(Transform((cAlt1)->AFIXAR 		, "@E 999,999,999,999.99" )) 	+ ";" )	//QTD A FIXAR	-- QTD TOTAL - QTD FIXADA
			FWrite(nHandle, Alltrim(Transform((cAlt1)->PMEDIO		, "@E 999,999,999,999.99" ))	+ ";" )	//PRECO MEDIO			-- FUNCAO TRATAMENTO DO PRECO MEDIO		
			FWrite(nHandle, Alltrim(Transform((cAlt1)->VTOTME		, "@E 999,999,999,999.99" )) 	+ ";" )	//VAL TOTAL MEDIO    -- QTD TOTAL * PRECO MEDIO
			FWrite(nHandle, Alltrim(Transform((cAlt1)->VTOTLQ		, "@E 999,999,999,999.99" ))	+ ";" )	//VAL TOTAL LIQUIDO	-- VL TOTAL MEDIO - IMPOSTO
			FWrite(nHandle, Alltrim(Transform((cAlt1)->COMPRA		, "@E 999,999,999,999.99" )) 	+ ";" )	 
			FWrite(nHandle, Alltrim(Transform((cAlt1)->NJR_QSLFCO	, "@E 999,999,999,999.99" ))	+ ";" )	 			
			FWrite(nHandle, cCrLf ) // Pula linha			
			//-- SOMA PARA TOTALIZADORES
			nQtdTot1 += (cAlt1)->NJR_QTDCTR
			nQtdFix1 += (cAlt1)->NN8_QTDFIX
			nQtdAFi1 += (cAlt1)->AFIXAR 	
			If (cAlt1)->PMEDIO > 0
				nPreMed1 += (cAlt1)->NN8_QTDFIX+(cAlt1)->AFIXAR
				nVlTMed1 += (cAlt1)->VTOTME
			EndIf					
			nVlTliq1 += (cAlt1)->VTOTLQ
			nQtdEtg1 += (cAlt1)->COMPRA
			nQtdAEg1 += (cAlt1)->NJR_QSLFCO

			nContC ++
			dbSelectArea(cAlt1) 
			(cAlt1)->( dbSkip() )
		EndDo		

		nPreMed11 += nVlTMed1/nPreMed1

		//-- TOTALIZADORES
		FWrite(nHandle, Alltrim(STR0035) + ";" ) //"TOTAL:"
		FWrite(nHandle, ";" )
		FWrite(nHandle, ";" ) 
		FWrite(nHandle, ";" ) 
		FWrite(nHandle, ";" ) 
		FWrite(nHandle, ";" )
		FWrite(nHandle, ";" )  
		FWrite(nHandle, ";" )
		FWrite(nHandle, ";" )
		FWrite(nHandle, ";" )
		FWrite(nHandle, ";" )
		FWrite(nHandle, ";" )
		FWrite(nHandle, Alltrim(Transform(nQtdTot1	, "@E 999,999,999,999.99" )) 	+ ";" )
		FWrite(nHandle, Alltrim(Transform(nQtdFix1	, "@E 999,999,999,999.99" ))	+ ";" )
		FWrite(nHandle, Alltrim(Transform(nQtdAFi1	, "@E 999,999,999,999.99" )) 	+ ";" )
		FWrite(nHandle, Alltrim(Transform(nPreMed11	, "@E 999,999,999,999.99" ))	+ ";" )			
		FWrite(nHandle, Alltrim(Transform(nVlTMed1	, "@E 999,999,999,999.99" )) 	+ ";" )
		FWrite(nHandle, Alltrim(Transform(nVlTliq1	, "@E 999,999,999,999.99" ))	+ ";" )
		FWrite(nHandle, Alltrim(Transform(nQtdEtg1	, "@E 999,999,999,999.99" )) 	+ ";" )
		FWrite(nHandle, Alltrim(Transform(nQtdAEg1	, "@E 999,999,999,999.99" ))	+ ";" )
		FWrite(nHandle, cCrLf ) // Pula linha


		/*+==================================+
		||  BLOCO DE CONTRATO DE VENDAS 	 ||
		+===================================*/
		FWrite(nHandle, cCrLf ) // Pula linha
		FWrite(nHandle, cCrLf ) // Pula linha
		FWrite(nHandle, cCrLf ) // Pula linha
		FWrite(nHandle, Alltrim(STR0036) + ";" )	//"Contrato de Vendas"
		FWrite(nHandle, cCrLf ) // Pula linha

		//-- Grava o cabecalho do arquivo
		aEval(aStru, {|e, nX| FWrite(nHandle, e[1] + If(nX < Len(aStru), ";", "") ) } )
		FWrite(nHandle, cCrLf ) // Pula linha		
		While (cAlt2)->(!Eof()) 
			//TRATA VARIAVEIS	
			cMODAL  := POSICIONE("NK5", 1, xFilial("NK5") + ((cAlt2))->NJR_MODAL,  "NK5_DESMOD")
			cDESOPE := POSICIONE("NNO", 1, xFilial("NNO") + ((cAlt2))->NJR_CODOPE, "NNO_DESCRI") 		
			//cTIPFIX := If ((cAlt2)->TIPFIX = "1", STR0033, STR0034)
			dDATFIM := (cAlt2)->DATFIM
			dDTVENC := (cAlt2)->DTVENC

			//FAZ A IMPRESSAO EXCEL
			FWrite(nHandle, CHR(160)+Alltrim((cAlt2)->NJR_CODCTR)									+ ";" )
			FWrite(nHandle, CHR(160)+Alltrim(cMODAL)												+ ";" )
			FWrite(nHandle, CHR(160)+Alltrim(cDESOPE)												+ ";" ) 
			FWrite(nHandle, CHR(160)+Alltrim((cAlt2)->TIPFIX)										+ ";" ) 
			FWrite(nHandle, Alltrim(Transform((cAlt2)->NJR_MOEDA		, "@E 999" ))				+ ";" )  
			FWrite(nHandle, Alltrim(Transform((cAlt2)->IMPOSTO		, "@E 999,999,999,999.99" ))	+ " ;")
			FWrite(nHandle, CHR(160)+Alltrim((cAlt2)->TPFRET)										+ ";" )  
			FWrite(nHandle, CHR(160)+Alltrim(Transform(dDATFIM		, "@D 99/99/9999" ))			+ ";" )
			FWrite(nHandle, CHR(160)+Alltrim(Transform(dDTVENC		, "@D 99/99/9999" ))			+ ";" )
			FWrite(nHandle, CHR(160)+Alltrim((cAlt2)->NJR_CODENT)									+ ";" )
			FWrite(nHandle, CHR(160)+Alltrim((cAlt2)->NJR_NOMENT)									+ ";" )				//NOME ENTIDADE
			FWrite(nHandle, CHR(160)+Alltrim((cAlt2)->NJR_LOJENT)									+ ";" )				//LOJA ENTIDADE
			FWrite(nHandle, Alltrim(Transform((cAlt2)->NJR_QTDCTR	, "@E 999,999,999,999.99" ))	+ ";" )
			FWrite(nHandle, Alltrim(Transform((cAlt2)->NN8_QTDFIX	, "@E 999,999,999,999.99" )) 	+ ";" )
			FWrite(nHandle, Alltrim(Transform((cAlt2)->AFIXAR 		, "@E 999,999,999,999.99" ))	+ ";" )
			FWrite(nHandle, Alltrim(Transform((cAlt2)->PMEDIO		, "@E 999,999,999,999.99" )) 	+ ";" )			
			FWrite(nHandle, Alltrim(Transform((cAlt2)->VTOTME		, "@E 999,999,999,999.99" ))	+ ";" )
			FWrite(nHandle, Alltrim(Transform((cAlt2)->VTOTLQ		, "@E 999,999,999,999.99" )) 	+ ";" )
			FWrite(nHandle, Alltrim(Transform((cAlt2)->VENDA		, "@E 999,999,999,999.99" )) 	+ ";" )	 
			FWrite(nHandle, Alltrim(Transform((cAlt2)->NJR_QSLFCO	, "@E 999,999,999,999.99" ))	+ ";" )				
			FWrite(nHandle, cCrLf ) // Pula linha
			//-- SOMA PARA TOTALIZADORES
			nQtdTot2 += (cAlt2)->NJR_QTDCTR
			nQtdFix2 += (cAlt2)->NN8_QTDFIX
			nQtdAFi2 += (cAlt2)->AFIXAR 	
			If (cAlt2)->PMEDIO > 0
				nPreMed2 += (cAlt2)->NN8_QTDFIX+(cAlt2)->AFIXAR
				nVlTMed2 += (cAlt2)->VTOTME
			EndIf
			nVlTliq2 += (cAlt2)->VTOTLQ
			nQtdEtg2 += (cAlt2)->VENDA
			nQtdAEg2 += (cAlt2)->NJR_QSLFCO

			nContV ++
			dbSelectArea(cAlt2) 
			(cAlt2)->( dbSkip() )
		EndDo		

		nPreMed22 := nVlTMed2/nPreMed2

		//-- TOTALIZADORES
		FWrite(nHandle, Alltrim(STR0035) + ";" ) //"TOTAL:"
		FWrite(nHandle, ";" )
		FWrite(nHandle, ";" ) 
		FWrite(nHandle, ";" ) 
		FWrite(nHandle, ";" ) 
		FWrite(nHandle, ";" )
		FWrite(nHandle, ";" )  
		FWrite(nHandle, ";" )
		FWrite(nHandle, ";" )
		FWrite(nHandle, ";" )
		FWrite(nHandle, ";" )
		FWrite(nHandle, ";" )
		FWrite(nHandle, Alltrim(Transform(nQtdTot2	, "@E 999,999,999,999.99" ))	+ ";" )
		FWrite(nHandle, Alltrim(Transform(nQtdFix2	, "@E 999,999,999,999.99" ))	+ ";" )
		FWrite(nHandle, Alltrim(Transform(nQtdAFi2	, "@E 999,999,999,999.99" ))	+ ";" )
		FWrite(nHandle, Alltrim(Transform(nPreMed22	, "@E 999,999,999,999.99" )) 	+ ";" )			
		FWrite(nHandle, Alltrim(Transform(nVlTMed2	, "@E 999,999,999,999.99" ))	+ ";" )
		FWrite(nHandle, Alltrim(Transform(nVlTliq2	, "@E 999,999,999,999.99" )) 	+ ";" )
		FWrite(nHandle, Alltrim(Transform(nQtdEtg2	, "@E 999,999,999,999.99" )) 	+ ";" )
		FWrite(nHandle, Alltrim(Transform(nQtdAEg2	, "@E 999,999,999,999.99" ))	+ ";" )		
		FWrite(nHandle, cCrLf ) // Pula linha


		/*+=====================================+
		||  FINAL DE ARQUIVOS -- FECHA ARQUIVO ||
		+======================================*/
		FClose(nHandle)
		CpyS2T( cDirDocs+"\"+ cArquivo + ".csv" , cPath, .T. )

		If !ApOleClient( 'MsExcel' ) 
			MsgAlert( STR0037 )  //"MsExcel nao instalado!"
			Return
		EndIf

		oExcelApp := MsExcel():New()
		//-- ABRE UMA PLANILHA
		oExcelApp:WorkBooks:Open( cPath+cArquivo+".CSV" ) 
		oExcelApp:SetVisible(.T.)
	Else
		MsgAlert( STR0038 )  //"Falha na criação do arquivo!" 
	Endif	
Return
/*
###################################################################################
# Função   : OGC02RES                                                             #
# Descrição: Exporta informações da tela para o excel	                          #
# Autor    : Ana Laura Olegini                                                    #
# Data     : 31/10/2014                                                           #  
###################################################################################
*/
Static Function OGC02RES()

	Local aItens		:= {}
	Local aStru		:= {}
	Local cArquivo 	:= STR0039 //"Posicao Resumida"
	Local cCrLf 		:= Chr(13) + Chr(10)
	Local cDirDocs   	:= MsDocPath() 
	Local cPath		:= AllTrim(GetTempPath())
	Local oExcelApp
	Local nHandle	
	Local nRec, nCont
	Local nX, nY, nZ
	//VARIAVEIS DE TOTALIZADORES COMPRA
	Local nQtdTot1 := 0 
	Local nQtdFix1 := 0
	Local nQtdAFi1 := 0
	Local nQtdEnt1 := 0
	Local nQtEntr1 := 0
	Local nVlTMed1 := 0
	//VARIAVEIS DE TOTALIZADORES VENDA
	Local nQtdTot2 := 0
	Local nQtdFix2 := 0
	Local nQtdAFi2 := 0
	Local nQtdEnt2 := 0
	Local nQtEntr2 := 0
	Local nVlTMed2 := 0
	//VARIAVEIS DIFERENCA
	Local nDiferenca 	:= 0
	Local nTotalDife	:= 0
	//VARIAVEIS PARA QUERYS
	Local cQryR1 	:= ""
	Local cQryR2 	:= ""	// MEDIA 

	Local nPreMedia	:= 0
	Local nQtdFixada	:= 0
	Local nMediaF		:= 0
	Local nQtdFixTo	:= 0

	Private cAliasR1 	:= GetNextAlias()     // Retorna o próximo Alias disponível COMPRA
	Private cAliasR2 	:= GetNextAlias()     // Retorna o próximo Alias disponível COMPRA

	nQTotalC := 0 
	nVTotalC := 0

	nMQTotalV := 0
	nMVTotalV := 0


	//-- MONTA CABECALHO PARA IMPRESSAO EXCEL
	aStru  := {{STR0040	,"C", 06, 0},;
	{STR0027	,"C", 40, 0},; //Safra
	{STR0011	,"C", 06, 0},; //Operação
	{STR0028	,"C", 40, 0},; //Produto
	{STR0041 	,"D", 8,  0},; //Prazo
	{STR0042	,"N", 20, 2},; //Qtd Comprada
	{STR0043	,"N", 20, 2},; //Qtd Fixada
	{STR0021	,"N", 20, 2},; //Qtd á Fixar
	{STR0025	,"N", 20, 2},; //Qtd Entregue
	{STR0026	,"N", 20, 2},; //Qtd Entregar
	{STR0044	,"N", 20, 2},; //Preço Médio
	{STR0045	,"N", 20, 2},; //Vl Total Médio
	{STR0046	,"N", 20, 2},; //Qtd Vendida
	{STR0043	,"N", 20, 2},; //Qt Fixada
	{STR0021	,"N", 20, 2},; //Qtd á Fixar
	{STR0025	,"N", 20, 2},; //Qtd Entregue
	{STR0026	,"N", 20, 2},; //Qtd Entregar
	{STR0044	,"N", 20, 2},; //Preço Medio
	{STR0045	,"N", 20, 2},; //Vl Total Medio
	{STR0047	,"N", 20, 2} } //Diferença

	/*+=============================================================+
	|| 	QUERY -- BUSCA CONTRATOS COMPRA E VENDA PARA IMPRESSAO 		||
	+==============================================================*/	
	cQryR1 := " SELECT NJR.NJR_FILIAL, NJR.NJR_CODSAF, NJR.NJR_CODOPE, NJR.NJR_CODPRO, NJR.NJR_TIPO, NJR_CODCTR, " 
	cQryR1 +=        " MAX(NNY.NNY_DATFIM) DATAFIM, NJR.NJR_QTDCTR, (NJR.NJR_QTEFCO - NJR.NJR_QTSFCO) ENTREGUEC, "
	cQryR1 +=        " (NJR.NJR_QTSFCO - NJR.NJR_QTEFCO) ENTREGUEV, NJR.NJR_QSLFCO, NJR.NJR_VLRUNI "	   
	cQryR1 +=    " FROM "+ RetSqlName("NJR") + " NJR "  		  
	cQryR1 +=    " LEFT JOIN "+ RetSqlName("NNY") + " NNY  ON NNY.NNY_FILIAL = '" + xFilial( 'NNY' ) + "'"
	cQryR1 +=                                            " AND NNY.D_E_L_E_T_ = '' "
	cQryR1 +=                                            " AND NNY.NNY_CODCTR = NJR.NJR_CODCTR " 		
	cQryR1 +=   " WHERE NJR.NJR_FILIAL = '" + xFilial( 'NJR' ) + "'" 
	cQryR1 +=     " AND NJR.D_E_L_E_T_ = ''  "
	cQryR1 +=     " AND NJR.NJR_TIPO   IN ('1' , '2') " 			//--TIPO 1=COMPRA E 2=VENDA
	cQryR1 +=     " AND NJR.NJR_CODSAF = '" + mv_par01 + "'"	//-- SAFRA
	cQryR1 +=     " AND NJR.NJR_CODPRO = '" + mv_par02 + "'"	//-- PRODUTO

	If .NOT. Empty (mv_par05) 
		If mv_par05 == 2 //Nao mostra contratos cancelados
			cQryR1 += " AND NJR.NJR_STATUS <> 'E'"
		EndIf
	EndIf

	cQryR1 +=   " GROUP BY NJR_FILIAL, NJR_CODSAF, NJR_CODPRO, NJR_CODOPE, NJR_CODCTR, NJR_TIPO, "
	cQryR1 +=            " NJR_QTDCTR, NJR_QSLFCO, NJR_QTEFCO, NJR_QTSFCO, NJR.NJR_VLRUNI "	
	cQryR1 +=   " ORDER BY NJR_CODOPE, DATAFIM "
	cQryR1 := ChangeQuery(cQryR1)	
	If Select(cAliasR1) <> 0
		(cAliasR1)->(dbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryR1),cAliasR1,.T.,.T.)
	COUNT TO nRec //--use uma variavel(nRec) p/ receber o contador de registro(COUNT)

	dbSelectArea(cAliasR1)
	(cAliasR1)->(dbGoTop())

	nHandle := MsfCreate(cDirDocs + "\" + cArquivo + ".CSV",0)
	If nHandle > 0
		IncProc(STR0030) 

		//--PRIMEIRA LINHA
		FWrite(nHandle, STR0048 	+ ";" ) //"Posição Resumida Compra X Venda"
		FWrite(nHandle, cCrLf ) // Pula linha
		FWrite(nHandle, cCrLf ) // Pula linha

		//--Grava o cabecalho do arquivo
		aEval(aStru, {|e, nX| FWrite(nHandle, e[1] + If(nX < Len(aStru), ";", "") ) } )
		FWrite(nHandle, cCrLf ) // Pula linha

		nQCompra1C := 0	//QTD COMPRADA
		nQtFixadaC := 0	//QTD FIXADA
		nQtAFixarC := 0	//QTD A FIXAR
		nQtEntrg1C := 0	//QTD ENTREGUE
		nQEntregaC := 0	//QTD A ENTREGAR
		nPreMedi1C := 0	//PRECO MEDIO
		nVlTMedi1C := 0	//VL TOTAL MEDIO
		nQtVenda1V := 0	//QTD VENDIDA
		nQtFixadaV := 0	//QTD FIXADA
		nQtAFixarV := 0	//QTD A FIXAR
		nQtEntrg1V := 0	//QTD ENTREGUE
		nQEntregaV := 0	//QTD A ENTREGAR
		nPreMedi1V := 0	//PRECO MEDIO
		nVlTMedi1V := 0	//VL TOTAL MEDIO

		nCont  := 0
		nZ		:= 0		
		For nx := 1 To nRec
			/*+=============================================================+
			|| 	QUERY -- BUSCA E CALCULA A MEDIA E SOMA DA QTD FIXADA  		||
			+==============================================================*/				
			cQryR2 := " SELECT NN8_TIPOFX, NN8_QTDFIX,NN8_VLRUNI,NN8_VALUNI, NN8_MOEDA, NN8_TXMOED, NN8_DATA "
			cQryR2 +=   " FROM "+ RetSqlName("NN8") + " NN8 "  
			cQryR2 +=  " WHERE NN8_FILIAL = '" + xFilial( 'NN8' ) + "'" 
			cQryR2 +=    " AND NN8_CODCTR = '" + (cAliasR1)->NJR_CODCTR + "'"
			cQryR2 +=    " AND D_E_L_E_T_ = '' "
			cQryR2 := ChangeQuery(cQryR2)			
			If Select(cAliasR2) <> 0
				(cAliasR2)->(dbCloseArea())
			EndIf		
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryR2),cAliasR2,.T.,.T.)		
			COUNT TO nCont

			dbSelectArea(cAliasR2)
			(cAliasR2)->(dbGoTop())

			nPreMedia 	:= 0
			nMediaF	:= 0
			nQtdFixTo	:= 0
			nQtdFixada	:= 0

			/*+=================================+
			|| 	TRATAMENTO DO PRECO MEDIO    	||
			|| -> mv_par03 - 1 Preco Fixado	 	||
			|| -> mv_par04 - 2 Preco Previsto	||
			+==================================*/			
			If mv_par03 = 1 .AND. nCont = 0				
				nPreMedia := 0	

			ElseIf mv_par03 = 1 .AND. nCont > 0 .AND. (cAliasR2)->NN8_TIPOFX = '1'								
				For nZ := 1 TO nCont							
					nQtdFixada := (cAliasR2)->NN8_QTDFIX*(cAliasR2)->NN8_VLRUNI					
					If nZ = 1
						nMediaF   := nQtdFixada
						nQtdFixTo := (cAliasR2)->NN8_QTDFIX
					Else
						nMediaF   += nQtdFixada
						nQtdFixTo += (cAliasR2)->NN8_QTDFIX
					EndIf					
					(cAliasR2)->(dbSkip())
				Next nZ				
				nPreMedia := nMediaF/nQtdFixTo

			ElseIf mv_par03 = 2 .AND. nCont = 0				
				nPreMedia := (cAliasR1)->NJR_VLRUNI

			ElseIf mv_par03 = 2 .AND. nCont > 0 .AND. (cAliasR2)->NN8_TIPOFX = '1'
				For nZ := 1 TO nCont							
					nQtdFixada := (cAliasR2)->NN8_QTDFIX*(cAliasR2)->NN8_VLRUNI					
					If nZ = 1
						nMediaF   := nQtdFixada
						nQtdFixTo := (cAliasR2)->NN8_QTDFIX
					Else
						nMediaF   += nQtdFixada
						nQtdFixTo += (cAliasR2)->NN8_QTDFIX
					EndIf					
					(cAliasR2)->(dbSkip())
				Next nZ				
				nPreMedia := nMediaF/nQtdFixTo	
			EndIf	

			//--TRATA DATA
			cAnoPrazo	:= SUBSTR( (cAliasR1)->DATAFIM ,1,4)
			cMesPrazo 	:= SUBSTR( (cAliasR1)->DATAFIM ,5,2)
			cAnoMesPr 	:= cMesPrazo+cAnoPrazo

			//-- VERIFICA SE JA EXISTE
			nPosItens	:= aScan(aItens,{|x| x[1]  == (cAliasR1)->NJR_CODPRO+(cAliasR1)->NJR_CODOPE+cAnoMesPr})

			IF (cAliasR1)->NJR_TIPO = '1' //COMPRA			
				nQCompra1C := (cAliasR1)->NJR_QTDCTR							//QTD COMPRADA
				nQtFixadaC := nQtdFixTo  										//QTD FIXADA
				nQtAFixarC := nQCompra1C-nQtdFixTo			 					//QTD A FIXAR
				nQtEntrg1C := (cAliasR1)->ENTREGUEC							//QTD ENTREGUE
				nQEntregaC := (cAliasR1)->NJR_QSLFCO							//QTD A ENTREGAR
				nPreMedi1C := nPreMedia  										//PRECO MEDIO
				nVlTMedi1C := nQCompra1C*nPreMedia								//VL TOTAL MEDIO										
				nQtVenda1V := 0 	//QTD VENDIDA
				nQtFixadaV := 0	//QTD FIXADA
				nQtAFixarV := 0	//QTD A FIXAR
				nQtEntrg1V := 0	//QTD ENTREGUE
				nQEntregaV := 0	//QTD A ENTREGAR
				nPreMedi1V := 0	//PRECO MEDIO
				nVlTMedi1V := 0	//VL TOTAL MEDIO				
				If nPreMedia > 0 .AND. (cAliasR1)->NJR_TIPO = '1'
					nQTotalC += nQtFixadaC+nQtAFixarC	//QTD COMPRADA
					nVTotalC += nVlTMedi1C				//VL TOTAL MEDIO
				EndIf
			ELSEIF (cAliasR1)->NJR_TIPO = '2' //VENDA						
				nQCompra1C := 0	//QTD COMPRADA
				nQtFixadaC := 0	//QTD FIXADA
				nQtAFixarC := 0	//QTD A FIXAR
				nQtEntrg1C := 0	//QTD ENTREGUE
				nQEntregaC := 0	//QTD A ENTREGAR
				nPreMedi1C := 0	//PRECO MEDIO
				nVlTMedi1C := 0	//VL TOTAL MEDIO				
				nQtVenda1V := (cAliasR1)->NJR_QTDCTR							//QTD VENDIDA
				nQtFixadaV := nQtdFixTo     									//QTD FIXADA
				nQtAFixarV := nQtVenda1V-nQtdFixTo	 							//QTD A FIXAR
				nQtEntrg1V := (cAliasR1)->ENTREGUEV							//QTD ENTREGUE
				nQEntregaV := (cAliasR1)->NJR_QSLFCO							//QTD A ENTREGAR
				nPreMedi1V := nPreMedia  										//PRECO MEDIO
				nVlTMedi1V := nQtVenda1V*nPreMedia 							//VL TOTAL MEDIO	
				If nPreMedia > 0 .AND.(cAliasR1)->NJR_TIPO = '2'
					nMQTotalV += nQtFixadaV+nQtAFixarV	//QTD VENDIDA
					nMVTotalV += nVlTMedi1V				//VL TOTAL MEDIO
				EndIf	
			ENDIF


			If nPosItens == 0 

				//se nPosProd for igual igual a 0
				aAdd(aItens,{	(cAliasR1)->NJR_CODPRO+(cAliasR1)->NJR_CODOPE+cAnoMesPr, ;		//-- Codigo Produto/Codigo Operacao/AnoMesPrazo
				(cAliasR1)->NJR_FILIAL,(cAliasR1)->NJR_CODSAF,(cAliasR1)->NJR_CODOPE,;
				(cAliasR1)->NJR_CODPRO,cAnoMesPr,;
				nQCompra1C,nQtFixadaC,nQtAFixarC,nQtEntrg1C,nQEntregaC,nPreMedi1C,nVlTMedi1C,;
				nQtVenda1V,nQtFixadaV,nQtAFixarV,nQtEntrg1V,nQEntregaV,nPreMedi1V,nVlTMedi1V } )
				nPosItens := Len(aItens)			


				//senão atribui para a variavel de array	
			ElseIf (cAliasR1)->NJR_TIPO = '1'
				aItens[nPosItens][7]  += nQCompra1C
				aItens[nPosItens][8]  += nQtFixadaC
				aItens[nPosItens][9]  += nQtAFixarC
				aItens[nPosItens][10] += nQtEntrg1C
				aItens[nPosItens][11] += nQEntregaC
				aItens[nPosItens][12] += nPreMedi1C
				aItens[nPosItens][13] += nVlTMedi1C
			ElseIf (cAliasR1)->NJR_TIPO = '2'
				aItens[nPosItens][14] += nQtVenda1V
				aItens[nPosItens][15] += nQtFixadaV
				aItens[nPosItens][16] += nQtAFixarV
				aItens[nPosItens][17] += nQtEntrg1V
				aItens[nPosItens][18] += nQEntregaV				
				aItens[nPosItens][19] += nPreMedi1V
				aItens[nPosItens][20] += nVlTMedi1V			
			EndIf

			dbSelectArea(cAliasR1) 
			(cAliasR1)->( dbSkip() )		
		Next nx		

		For ny := 1 To len(aItens)
			cDESOPE := POSICIONE("NNO", 1, xFilial("NNO") + aItens[ny][3], "NNO_DESCRI") 
			//-- TRATAMENTO DATA
			cAnoPrazo1	:= SUBSTR( aItens[ny][6] ,3,4)
			cMesPrazo1	:= SUBSTR( aItens[ny][6] ,1,2)
			cAnoMesPr1	:= cMesPrazo1+"/"+cAnoPrazo1			
			//FAZ A EXPORTACAO EXCEL -- CABECALHO
			FWrite(nHandle, CHR(160)+Alltrim(aItens[ny][2])			+ ";" )
			FWrite(nHandle, CHR(160)+Alltrim(aItens[ny][3])		   	+ ";" )
			FWrite(nHandle, CHR(160)+Alltrim(aItens[ny][4])			+ ";" ) 
			FWrite(nHandle, CHR(160)+Alltrim(aItens[ny][5])			+ ";" ) 
			FWrite(nHandle, CHR(160)+Alltrim(cAnoMesPr1)				+ ";" )			
			nDiferenca := aItens[ny][7]-aItens[ny][14]			
			//VALORES COMPRA
			FWrite(nHandle, Alltrim(Transform(aItens[ny][7]	, "@E 999,999,999,999.99" )) 		+ ";" )
			FWrite(nHandle, Alltrim(Transform(aItens[ny][8] 	, "@E 999,999,999,999.99" ))	 	+ ";" )
			FWrite(nHandle, Alltrim(Transform(aItens[ny][9]	, "@E 999,999,999,999.99" )) 		+ ";" )			
			FWrite(nHandle, Alltrim(Transform(aItens[ny][10]	, "@E 999,999,999,999.99" ))	 	+ ";" )
			FWrite(nHandle, Alltrim(Transform(aItens[ny][11]	, "@E 999,999,999,999.99" )) 		+ ";" )
			FWrite(nHandle, Alltrim(Transform(aItens[ny][13]/aItens[ny][7], "@E 999,999,999,999.99" )) 		+ ";" )
			FWrite(nHandle, Alltrim(Transform(aItens[ny][13]	, "@E 999,999,999,999.99" ))	 	+ ";" )
			//VALORES VENDA
			FWrite(nHandle, Alltrim(Transform(aItens[ny][14]	, "@E 999,999,999,999.99" ))	 	+ ";" )
			FWrite(nHandle, Alltrim(Transform(aItens[ny][15]	, "@E 999,999,999,999.99" )) 		+ ";" )
			FWrite(nHandle, Alltrim(Transform(aItens[ny][16] , "@E 999,999,999,999.99" ))	 	+ ";" )
			FWrite(nHandle, Alltrim(Transform(aItens[ny][17]	, "@E 999,999,999,999.99" )) 		+ ";" )			
			FWrite(nHandle, Alltrim(Transform(aItens[ny][18]	, "@E 999,999,999,999.99" ))	 	+ ";" )
			FWrite(nHandle, Alltrim(Transform(aItens[ny][20]/aItens[ny][14], "@E 999,999,999,999.99" )) 		+ ";" )
			FWrite(nHandle, Alltrim(Transform(aItens[ny][20]	, "@E 999,999,999,999.99" )) 		+ ";" )			
			FWrite(nHandle, Alltrim(Transform( nDiferenca 	, "@E 999,999,999,999.99" )) 		+ ";" )

			FWrite(nHandle, cCrLf ) // Pula linha

			nTotalDife += nDiferenca

			nQtdTot1 += aItens[ny][7]	//QTD COMPRADA
			nQtdFix1 += aItens[ny][8]	//QTD FIXADA
			nQtdAFi1 += aItens[ny][9] 	//QTD A FIXAR
			nQtdEnt1 += aItens[ny][10]	//QTD ENTREGUE
			nQtEntr1 += aItens[ny][11]	//QTD ENTRAGAR
			nVlTMed1 += aItens[ny][13]	//VL TOTAL MEDIO

			nQtdTot2 += aItens[ny][14]	//QTD VENDIDA
			nQtdFix2 += aItens[ny][15]	//QTD FIXADA
			nQtdAFi2 += aItens[ny][16] 	//QTD A FIXAR
			nQtdEnt2 += aItens[ny][17]	//QTD ENTREGUE
			nQtEntr2 += aItens[ny][18]	//QTD ENTRAGAR
			nVlTMed2 += aItens[ny][20]	//VL TOTAL MEDIO

		Next ny

		FWrite(nHandle, cCrLf ) // Pula linha		
		FWrite(nHandle, Alltrim(STR0035) + ";" ) //"TOTAL:"
		FWrite(nHandle, ";" )
		FWrite(nHandle, ";" ) 
		FWrite(nHandle, ";" ) 
		FWrite(nHandle, ";" ) 
		//COMPRA
		FWrite(nHandle, Alltrim(Transform(nQtdTot1	, "@E 999,999,999,999.99" ))	 	+ ";" )
		FWrite(nHandle, Alltrim(Transform(nQtdFix1	, "@E 999,999,999,999.99" )) 		+ ";" )
		FWrite(nHandle, Alltrim(Transform(nQtdAFi1	, "@E 999,999,999,999.99" ))	 	+ ";" )
		FWrite(nHandle, Alltrim(Transform(nQtdEnt1	, "@E 999,999,999,999.99" )) 		+ ";" )
		FWrite(nHandle, Alltrim(Transform(nQtEntr1	, "@E 999,999,999,999.99" )) 		+ ";" )
		FWrite(nHandle, Alltrim(Transform(nVTotalC/nQTotalC	, "@E 999,999,999,999.99" )) 		+ ";" )			
		FWrite(nHandle, Alltrim(Transform(nVlTMed1	, "@E 999,999,999,999.99" ))	 	+ ";" )
		//VENDA
		FWrite(nHandle, Alltrim(Transform(nQtdTot2	, "@E 999,999,999,999.99" ))	 	+ ";" )
		FWrite(nHandle, Alltrim(Transform(nQtdFix2	, "@E 999,999,999,999.99" )) 		+ ";" )
		FWrite(nHandle, Alltrim(Transform(nQtdAFi2	, "@E 999,999,999,999.99" ))	 	+ ";" )
		FWrite(nHandle, Alltrim(Transform(nQtdEnt2	, "@E 999,999,999,999.99" )) 		+ ";" )
		FWrite(nHandle, Alltrim(Transform(nQtEntr2	, "@E 999,999,999,999.99" )) 		+ ";" )
		FWrite(nHandle, Alltrim(Transform(nMVTotalV/nMQTotalV	, "@E 999,999,999,999.99" )) 		+ ";" )			
		FWrite(nHandle, Alltrim(Transform(nVlTMed2	, "@E 999,999,999,999.99" ))	 	+ ";" )
		//DIFERENCA
		FWrite(nHandle, Alltrim(Transform(nTotalDife	, "@E 999,999,999,999.99" ))	 	+ ";" )

		FWrite(nHandle, cCrLf ) // Pula linha


		//FECHA ARQUIVO
		FClose(nHandle)
		CpyS2T( cDirDocs+"\"+ cArquivo + ".csv" , cPath, .T. )

		If ! ApOleClient( 'MsExcel' ) 
			MsgAlert( STR0037 )  //"MsExcel nao instalado!"
			Return
		EndIf

		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open( cPath+cArquivo+".CSV" ) // Abre uma planilha
		oExcelApp:SetVisible(.T.)
	Else
		MsgAlert( STR0038 )  //"Falha na criação do arquivo!"
	EndIf
Return
