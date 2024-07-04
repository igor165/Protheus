#INCLUDE "UBAC001.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"
#include "fwbrowse.ch"


Static oArqTemp := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} UBAC001
Consulta Entrada de Cargas
@author Aécio Ferreira Gomes
@since 24/07/2013
@version MP11.8
/*/
//-------------------------------------------------------------------
Function UBAC001()
	Local oDLg      := Nil
	Local oSize     := Nil
	Local aCoors    := FWGetDialogSize( oMainWnd )
	Local cTipo     := ""
	Local cStatFard := ""
	Local cStatRom  := ""
	Local aCampos   := {}
	Local aRet      := {}

// Variaveis dos totalizadores
	Local oTotBrut 	:= Nil
	Local oTotTara 	:= Nil
	Local oTotLona 	:= Nil
	Local oTotLiqu 	:= Nil
	Local oTotQtd 	:= Nil	
	Local bKeyF12  	:= {|| If( Pergunte("UBAC001", .T.), ( cAliasTRB := CRIATRB()[1], oBrwSuper:SetAlias(cAliasTRB), oBrwSuper:Refresh()), .T. ) }
	
	Private cAliasTRB := ""	
	Private nQtdl  		:= 0
	Private cAlias 		:= ""
	Private aArqTemp  	:= {}
	Private oBrwSuper
	Private aTotais 	:= {0,0,0,0,0}
	SetKey( VK_F12, bKeyF12 )
	
/* Grupo de perguntas UBAC001
	mv_par01 - Safra
	mv_par02 - Data De
	mv_par03 - Data Ate
	mv_par04 - Placa
	mv_par05 - Entidade
	mv_par06 - Loja
	mv_par07 - Fazenda
	mv_par08 - Situação: 1=Normais; 2=Cancelados 
*/

	If !Pergunte("UBAC001",.T.)
		Return
	EndIf
	
	aRet := CRIATRB("TRBDXM",@aTotais)
	cAliasTRB := aRet[1]
	aArqTemp := aRet[2]
	
//- Coordenadas da area total da Dialog
	oSize := FWDefSize():New(.F.)
	oSize:AddObject('ALL',100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:aMargins := {3,3,3,3}
	oSize:lProp 	 := .T.
	oSize:Process()

	DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] OF oMainWnd PIXEL
	
	// Instancia o layer
	oFWL := FWLayer():New()
	
	// Inicia o Layer
	oFWL:init(oDlg,.F.)
	
	// Cria uma linha unica para o Layer
	oFWL:addLine('SUP',80,.F.)
	oFWL:addLine('INF',20,.F.)
	
	// Cria colunas 
	oFWL:addCollumn('COL', 100, .T., 'INF')
	
	// Cria Janela
	oFWL:addWindow('COL','Wnd1',STR0001,100,.F.,.T.,,'INF')  //"Totais"
    
	oPnlCol  := oFWL:getLinePanel('SUP')
	oPnlWnd1 := oFWL:getWinPanel('COL','Wnd1','INF')
	
	//-------------------------------------------------------------------
	// Define o Browse
	//-------------------------------------------------------------------
	DEFINE FWFORMBROWSE oBrwSuper DATA TABLE ALIAS (cAliasTRB) DESCRIPTION STR0002 OF oPnlCol //"Entrada de Cargas"
		//oBrwSuper:SetUseFilter(.T.)
	aCampos := CmpFiltro()
	oBrwSuper:SetTemporary(.T.)
	oBrwSuper:DisableDetails()
	oBrwSuper:SetFieldFilter(aCampos)
	oBrwSuper:SetdbFFilter(.T.)
	oBrwSuper:SetUseFilter(.T.)
	oBrwSuper:SetProfileID('1')
	oBrwSuper:BVLDEXECFILTER := {|| UBAC001RT()}
	oBrwSuper:AddButton(STR0030,{|| oDlg:End()},,,,,,'10')
	oBrwSuper:AddButton(STR0031,{|| UBAR006()}, ,8 ,0)  //"Imprimir"
	cStatRom  := "AGRTxtBox(&(aArqTemp[2,1]), 'DXM_STATUS')" //Status Romaneio
	cStatFard := "AGRTxtBox(&(aArqTemp[4,1]), 'DXL_STATUS')" //Status Fardão
	cTipo     := "AGRTxtBox(&(aArqTemp[8,1]), 'DXL_TPRENS')" //Tipo Fardão
		
	ADD COLUMN oColumn DATA {|| &(aArqTemp[1,1])}  TITLE STR0003 SIZE aArqTemp[1,3]  ;
		PICTURE PesqPict("DXM","DXM_CODIGO")										OF oBrwSuper //"Romaneio"
	ADD COLUMN oColumn DATA {|| &(cStatRom)}       TITLE STR0025 SIZE aArqTemp[2,3]  ;
		PICTURE PesqPict("DXM","DXM_STATUS")										OF oBrwSuper //"Status Romaneio"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[3,1])}  TITLE STR0013 SIZE aArqTemp[3,3]  ;
		PICTURE PesqPict("DXL","DXL_CODIGO")										OF oBrwSuper //"Fardao"
	ADD COLUMN oColumn DATA {|| &(cStatFard)}      TITLE STR0024 SIZE aArqTemp[4,3]  ;
		PICTURE PesqPict("DXL","DXL_STATUS")										OF oBrwSuper //"Status Fardão"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[5,1])}  TITLE STR0014 SIZE aArqTemp[5,3]  ;
		PICTURE PesqPict("DXL","DXL_TALHAO")										OF oBrwSuper //"Talhão"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[6,1])}  TITLE STR0023 SIZE aArqTemp[6,3]  ;
		PICTURE PesqPict("DXL","DXL_CODVAR")										OF oBrwSuper //"Variedade Algodão"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[7,1])}  TITLE DescriSX3("NNV_DESCRI") SIZE aArqTemp[7,3]  ;
		PICTURE PesqPict("NNV","NNV_DESCRI")										OF oBrwSuper //"Descrição de Variedade Algodão"
	ADD COLUMN oColumn DATA {|| &(cTipo)}          TITLE STR0015 SIZE aArqTemp[8,3]  ;
		PICTURE PesqPict("DXL","DXL_TPRENS") 										OF oBrwSuper //"Tipo Fardão"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[9,1])}  TITLE STR0016 SIZE aArqTemp[9,3]  ;
		PICTURE PesqPict("DX0","DX0_RATEIO") 	TYPE TamSX3("DX0_RATEIO")[3]	OF oBrwSuper //"% Rateio"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[10,1])} TITLE STR0004 SIZE aArqTemp[10,3] ;
		PICTURE PesqPict("DXM","DXM_DTEMIS") 										OF oBrwSuper //"Data"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[11,1])} TITLE STR0005 SIZE aArqTemp[11,3] ;
		PICTURE PesqPict("DXM","DXM_PRDTOR") 										OF oBrwSuper //"Entidade"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[12,1])} TITLE STR0006 SIZE aArqTemp[12,3] ;
		PICTURE PesqPict("DXM","DXM_LJPRO") 										OF oBrwSuper //"Loja"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[13,1])} TITLE DescriSX3("NJ0_NOME") SIZE aArqTemp[13,3] ;
		PICTURE PesqPict("NJ0","NJ0_NOME")											OF oBrwSuper //"Entidade Descrição"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[14,1])} TITLE STR0007 SIZE aArqTemp[14,3] ;
		PICTURE PesqPict("DXM","DXM_FAZ") 											OF oBrwSuper //"Fazenda"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[15,1])} TITLE STR0008 SIZE aArqTemp[15,3] ;
		PICTURE PesqPict("DXM","DXM_PSBRUT") 	TYPE TamSX3("DXM_PSBRUT")[3]	OF oBrwSuper //"Peso Bruto"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[16,1])} TITLE STR0009 SIZE aArqTemp[16,3] ;
		PICTURE PesqPict("DXM","DXM_PSTARA") 	TYPE TamSX3("DXM_PSTARA")[3]	OF oBrwSuper //"Peso Tara"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[17,1])} TITLE STR0017 SIZE aArqTemp[17,3] ;
		PICTURE PesqPict("DX0","DX0_PSLIQU") 	TYPE TamSX3("DX0_PSLIQU")[3]	OF oBrwSuper //"Peso Liquido"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[18,1])} TITLE STR0010 SIZE aArqTemp[18,3] ;
		PICTURE PesqPict("DXM","DXM_PSLONA") 	TYPE TamSX3("DXM_PSLONA")[3]	OF oBrwSuper //"Peso Lona"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[19,1])} TITLE STR0026 SIZE 10             ;
		PICTURE "!@"                         										OF oBrwSuper //"Observação"
					
	ACTIVATE FWFORMBROWSE oBrwSuper
	
	@ 15, 10 SAY 	STR0029 SIZE 60, 7 PIXEL OF oPnlWnd1 //"total de Fardos"
	@ 12, 50 MSGET oTotQtd VAR aTotais[5] SIZE (TamSX3("DXM_PSBRUT")[1]*4), 10 WHEN .F. PICTURE "@E 9,999,999,999" PIXEL OF oPnlWnd1
	
	@ 15, 100 SAY STR0018 SIZE 60, 7 PIXEL OF oPnlWnd1 //"Total Bruto"
	@ 12, 147 MSGET oTotBrut VAR aTotais[1] SIZE (TamSX3("DXM_PSBRUT")[1]*4), 10 WHEN .F. PICTURE PesqPict("DXM","DXM_PSLIQU") PIXEL OF oPnlWnd1
	
	@ 15, 200 SAY STR0019 SIZE 60, 7 PIXEL OF oPnlWnd1 //"Total Desc. Tara"
	@ 12, 247 MSGET oTotTara VAR aTotais[2] SIZE (TamSX3("DXM_PSTARA")[1]*4), 10 WHEN .F. PICTURE PesqPict("DXM","DXM_PSTARA") PIXEL OF oPnlWnd1
   
	@ 15, 310 SAY STR0020 SIZE 60, 7 PIXEL OF oPnlWnd1 //"Total Desc. Lona"
	@ 12, 355 MSGET oTotLona VAR aTotais[3] SIZE (TamSX3("DXM_PSLONA")[1]*4), 10 WHEN .F. PICTURE PesqPict("DXM","DXM_PSLONA") PIXEL OF oPnlWnd1
   
	@ 15, 430 SAY STR0021  SIZE 60, 7 PIXEL OF oPnlWnd1 //"Total Líquido"
	@ 12, 470 MSGET oTotLiqu VAR aTotais[4] SIZE (TamSX3("DXM_PSLIQU")[1]*4), 10 WHEN .F. PICTURE PesqPict("DXM","DXM_PSLIQU") PIXEL OF oPnlWnd1
	
	ACTIVATE MSDIALOG oDlg CENTER

	If Select("TRBDXM") > 0
		("TRBDXM")->(DbCloseArea())
	EndIf
	
	//Elimina a tabela temporária, se houver
	AGRDLTPTB(oArqTemp)

Return

//------------------------------------------------------
/*/{Protheus.doc} DescriSX3
Função para buscar a descrição de um campo na tabela SX3
@author Alexandre José Cuchi
@since 27/05/2014
@version MP11.8
/*/
//-------------------------------------------------------------------
Function DescriSX3(cCampo)
	Local cDesc := ""
	Local AreaSX3
	
	dbSelectArea("SX3")
	dbSetOrder(2)
	AreaSX3 := SX3->(GetArea())
	SX3->(MsSeek(cCampo))
	cDesc := X3Descric(cCampo)
	
	RestArea(AreaSX3)
Return cDesc

//------------------------------------------------------
/*/{Protheus.doc} DescriSX3
Função para criação do array para o filtro
@author Alexandre José Cuchi
@since 27/05/2014
@version MP11.8
/*/
//-------------------------------------------------------------------
Static Function CmpFiltro()
	Local aCampos := {}
	
	AADD(aCampos,{"ROMANEIO",DescriSX3("DXM_CODIGO"), "C", TamSX3("DXM_CODIGO")[1], TamSX3("DXM_CODIGO")[2], PesqPict("DXM","DXM_CODIGO")})
	AADD(aCampos,{"DXM_STATUS",DescriSX3("DXM_STATUS"), "C", TamSX3("DXM_STATUS")[1], TamSX3("DXM_STATUS")[2], PesqPict("DXM","DXM_STATUS")})
	AADD(aCampos,{"FARDAO",DescriSX3("DXL_CODIGO"), "C", TamSX3("DXL_CODIGO")[1], TamSX3("DXL_CODIGO")[2], PesqPict("DXL","DXL_CODIGO")})
	AADD(aCampos,{"DXL_STATUS",DescriSX3("DXL_STATUS"), "C", TamSX3("DXL_STATUS")[1], TamSX3("DXL_STATUS")[2], PesqPict("DXL","DXL_STATUS")})
	AADD(aCampos,{"DXL_TALHAO",DescriSX3("DXL_TALHAO"), "C", TamSX3("DXL_TALHAO")[1], TamSX3("DXL_TALHAO")[2], PesqPict("DXL","DXL_TALHAO")})
	AADD(aCampos,{"DXL_CODVAR",DescriSX3("DXL_CODVAR"), "C", TamSX3("DXL_CODVAR")[1], TamSX3("DXL_CODVAR")[2], PesqPict("DXL","DXL_CODVAR")})
	AADD(aCampos,{"NNV_DESCRI",DescriSX3("NNV_DESCRI"), "C", TamSX3("NNV_DESCRI")[1], TamSX3("NNV_DESCRI")[2], PesqPict("NNV","NNV_DESCRI")})
	AADD(aCampos,{"DXL_TPRENS",DescriSX3("DXL_TPRENS"), "C", TamSX3("DXL_TPRENS")[1], TamSX3("DXL_TPRENS")[2], PesqPict("DXL","DXL_TPRENS")})
	AADD(aCampos,{"DX0_RATEIO",DescriSX3("DX0_RATEIO"), "N", TamSX3("DX0_RATEIO")[1], TamSX3("DX0_RATEIO")[2], PesqPict("DX0","DX0_RATEIO")})
	AADD(aCampos,{"DXM_DTEMIS",DescriSX3("DXM_DTEMIS"), "D", TamSX3("DXM_DTEMIS")[1], TamSX3("DXM_DTEMIS")[2], PesqPict("DXM","DXM_DTEMIS")})
	AADD(aCampos,{"DXM_PRDTOR",DescriSX3("DXM_PRDTOR"), "C", TamSX3("DXM_PRDTOR")[1], TamSX3("DXM_PRDTOR")[2], PesqPict("DXM","DXM_PRDTOR")})
	AADD(aCampos,{"DXM_LJPRO", DescriSX3("DXM_LJPRO"),  "C", TamSX3("DXM_LJPRO")[1],  TamSX3("DXM_LJPRO")[2],  PesqPict("DXM","DXM_LJPRO")})
	AADD(aCampos,{"NJ0_NOME",  DescriSX3("NJ0_NOME"),   "C", TamSX3("NJ0_NOME")[1]  , TamSX3("NJ0_NOME")[2]  , PesqPict("NJ0","NJ0_NOME")})
	AADD(aCampos,{"DXM_FAZ",   DescriSX3("DXM_FAZ"),    "C", TamSX3("DXM_FAZ")[1],    TamSX3("DXM_FAZ")[2],    PesqPict("DXM","DXM_FAZ")})
	AADD(aCampos,{"PESOBRUT",  DescriSX3("DXM_PSBRUT"), "N", TamSX3("DXM_PSBRUT")[1], TamSX3("DXM_PSBRUT")[2], PesqPict("DXM","DXM_PSBRUT")})
	AADD(aCampos,{"PESOTARA",  DescriSX3("DXM_PSTARA"), "N", TamSX3("DXM_PSTARA")[1], TamSX3("DXM_PSTARA")[2], PesqPict("DXM","DXM_PSTARA")})
	AADD(aCampos,{"DX0_PSLIQU",DescriSX3("DX0_PSLIQU"), "N", TamSX3("DX0_PSLIQU")[1], TamSX3("DX0_PSLIQU")[2], PesqPict("DX0","DX0_PSLIQU")})
	AADD(aCampos,{"PESOLONA",  DescriSX3("DXM_PSLONA"), "N", TamSX3("DXM_PSLONA")[1], TamSX3("DXM_PSLONA")[2], PesqPict("DXM","DXM_PSLONA")})
	
Return aCampos

//------------------------------------------------------
/*/{Protheus.doc} QUERY
Responsável por montar as querys de trabalho da consulta
@author Aécio Ferreira Gomes
@since 24/07/2013
@version MP11.8
/*/
//-------------------------------------------------------------------
Static Function QUERY(cAlias)
	Local cQry := ""

	#IFDEF TOP
		cQry := " SELECT DXL_CODPRO, DXM_CODIGO, DXM_STATUS, DXL_CODIGO, DXL_STATUS, DXL_TALHAO, DXL_CODVAR,"
		cQry +=        " DXL_TPRENS, DX0_RATEIO, DXM_DTEMIS, DXM_PRDTOR,"
		cQry +=        " DXM_LJPRO, DXM_FAZ, DXM_PSBRUT, DXM_PSTARA, DX0_PSLIQU, DXM_PSLONA, DXM_PSLIQU, DXM.R_E_C_N_O_ "
		cQry +=   " FROM " +RetSqlName("DXM")+ " DXM "
		cQry +=   " LEFT JOIN " +RetSqlName("DXL")+ " DXL ON DXL.D_E_L_E_T_ = '' "
		cQry +=                                        " AND DXL_FILIAL = '"+FWxFilial("DXL")+"' " 
		cQry +=                                        " AND DXL.DXL_CODROM = DXM.DXM_CODIGO "
		cQry +=                                        " AND DXL.DXL_SAFRA  = DXM.DXM_SAFRA"
		cQry +=                                        " AND DXL.DXL_FAZ = DXM.DXM_FAZ"
		cQry +=   " LEFT JOIN " +RetSqlName("DX0")+ " DX0 ON DX0.D_E_L_E_T_ = '' "
		cQry +=                                        " AND DX0_FILIAL = '"+FWxFilial("DX0")+"' " 
		cQry +=                                        " AND DX0_CODROM     = DXM_CODIGO "
		cQry +=                                 	   " AND DX0.DX0_FARDAO = DXL.DXL_CODIGO "
		cQry +=  " WHERE DXM.D_E_L_E_T_ = ' '  " 
		cQry +=  "   AND DXM_FILIAL = '"+FWxFilial("DXM")+"' "
		cQry +=    " AND DXM.DXM_SAFRA = '"+mv_par01+"' "
		cQry +=    " AND DXM.DXM_DTEMIS BETWEEN '"+DTOS(mv_par02)+"' AND '"+DTOS(mv_par03)+"' AND"
		

		//Filtro de unidade de beneficiamento
		//If !Empty(cUserBenf)
		If !Empty(mv_par09) 
			cQry += " DXM.DXM_CODUNB = '"+mv_par09+"' AND"
		EndIf		
	
		If !Empty(mv_par04) //Placa do caminhao
			cQry +=	" DXM.DXM_PLACA = '"+mv_par04+"' AND"
		EndIf
		If !Empty(mv_par05)
			cQry +=	" DXM.DXM_PRDTOR = '"+mv_par05+"' AND" // Entidade
			If !Empty(mv_par06)
				cQry +=	" DXM.DXM_LJPRO = '"+mv_par06+"' AND" // Loja
			EndIf
		EndIf
	
		If !Empty(mv_par07) // Fazenda
			cQry +=	" DXM.DXM_FAZ = '"+mv_par07+"' AND" // Fazenda
		EndIf
	
	// Verificar para atribuir talhao e variedade e tipo de fardao na query
		If mv_par08 == 1
			cQry +=	" DXM.DXM_STATUS <> '3'"
		Else
			cQry +=	" DXM.DXM_STATUS = '3'"
		EndIf

		cQry := ChangeQuery(cQry)

	#ENDIF

Return(cQry)

//-------------------------------------------------------------------
/*/{Protheus.doc} CRIATRB
Responsável por montar o arquivo de trabalho do browse de fardos
@author Aécio Ferreira Gomes
@since 24/07/2013
@version MP11.8
/*/
//-------------------------------------------------------------------
Static Function CRIATRB(cAlias, aTotais)
	Local cArqTemp  := ""
	aCmpsTab := {}
	aArqTemp := {}
	aTotais := {0,0,0,0,0}
	If (!Empty(cAliasTRB)) .AND. Select(cAliasTRB) > 0
		(cAliasTRB)->(DbCloseArea())
	EndIf
	If Select("TRBDXM") > 0
		("TRBDXM")->(DbCloseArea())
	EndIf
	DbSelectArea("DXM")
// Cria arquivo de trabalho
	aCmpsTab := TamSX3("DXM_CODIGO" );AADD(aArqTemp,{"ROMANEIO", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXM_STATUS" );AADD(aArqTemp,{"DXM_STATUS", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXL_CODIGO" );AADD(aArqTemp,{"FARDAO", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXL_STATUS" );AADD(aArqTemp,{"DXL_STATUS", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXL_TALHAO" );AADD(aArqTemp,{"DXL_TALHAO", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXL_CODVAR" );AADD(aArqTemp,{"DXL_CODVAR", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("NNV_DESCRI" );AADD(aArqTemp,{"NNV_DESCRI", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXL_TPRENS" );AADD(aArqTemp,{"DXL_TPRENS", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DX0_RATEIO" );AADD(aArqTemp,{"DX0_RATEIO", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXM_DTEMIS" );AADD(aArqTemp,{"DXM_DTEMIS", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXM_PRDTOR" );AADD(aArqTemp,{"DXM_PRDTOR", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXM_LJPRO"  );AADD(aArqTemp,{"DXM_LJPRO",  aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("NJ0_NOME" )	 ;AADD(aArqTemp,{"NJ0_NOME",   aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXM_FAZ"    );AADD(aArqTemp,{"DXM_FAZ",    aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXM_PSBRUT" );AADD(aArqTemp,{"PESOBRUT",   aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXM_PSTARA" );AADD(aArqTemp,{"PESOTARA",   aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DX0_PSLIQU" );AADD(aArqTemp,{"DX0_PSLIQU", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXM_PSLONA" );AADD(aArqTemp,{"PESOLONA",   aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXM_OBS"    );AADD(aArqTemp,{"DXM_OBS",    aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	//-- Cria Indice de Trabalho
	cArqTemp  := GetNextAlias() 
	oArqTemp  := AGRCRTPTB(cArqTemp, {aArqTemp, {{"", "ROMANEIO,FARDAO"}} })
	cAliasTRB := cArqTemp

	cQry := QUERY(cAlias)

	cAlias := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQry),cAlias,.F.,.T.)

	TcSetField(cAlias,"DXM_DTEMIS","D",8,0)

	(cAlias)->(dbGoTop())
	Count To nQtdl
 
	Processa({|| UBAC001PT(cAlias,@aTotais) },STR0027)

Return({cArqTemp, aArqTemp})

/*-------------------------------------------------------------------------------------
UBAC001PT Processamento
@param: Nil
@author: Inácio Luiz Kolling
@since: 19/06/2014
@Uso: UBAC007
-------------------------------------------------------------------------------------
*/
Static Function UBAC001PT(cAlias,aTotais)
	aTotais[1] := 0
	aTotais[2] := 0
	aTotais[3] := 0
	aTotais[4] := 0
	aTotais[5] := 0
	DbSelectArea(cAlias)
	(cAlias)->(dbGotop())
	ProcRegua(nQtdl)
	nRegl := 0
	While (cAlias)->(!Eof())
		nRegl ++
		IncProc(STR0028+Alltrim(Str(nRegl,5))+" / "+Alltrim(Str(nQtdl,5))) //"Processando registro -> "
	
		aArea := GetArea()
		nRecno := (cAlias)->R_E_C_N_O_
	
		dbSelectArea("DXM")
		DXM->(dbSetOrder(1))
		DXM->(dbGoTo(nRecno))

		cObs := DXM->DXM_OBS

	
		RestArea(aArea)
		DbSelectArea(cAliasTRB)
		Reclock(cAliasTRB, .T.)
		Replace (cAliasTRB)->ROMANEIO With (cAlias)->DXM_CODIGO
		Replace (cAliasTRB)->DXM_STATUS With (cAlias)->DXM_STATUS
		Replace (cAliasTRB)->FARDAO With (cAlias)->DXL_CODIGO
		Replace (cAliasTRB)->DXL_STATUS With (cAlias)->DXL_STATUS
		Replace (cAliasTRB)->DXL_TALHAO With (cAlias)->DXL_TALHAO
		Replace (cAliasTRB)->DXL_CODVAR With (cAlias)->DXL_CODVAR
		Replace (cAliasTRB)->NNV_DESCRI With Posicione("NNV",1,FWxFilial("NNV")+(cAlias)->DXL_CODPRO+(cAlias)->DXL_CODVAR,"NNV_DESCRI")
		Replace (cAliasTRB)->DXL_TPRENS With (cAlias)->DXL_TPRENS
		Replace (cAliasTRB)->DX0_RATEIO With (cAlias)->DX0_RATEIO
		Replace (cAliasTRB)->DXM_DTEMIS With (cAlias)->DXM_DTEMIS
		Replace (cAliasTRB)->DXM_PRDTOR With (cAlias)->DXM_PRDTOR
		Replace (cAliasTRB)->DXM_LJPRO  With (cAlias)->DXM_LJPRO
		Replace (cAliasTRB)->NJ0_NOME With Posicione("NJ0",1,FWxFilial("NJ0")+(cAlias)->DXM_PRDTOR+(cAlias)->DXM_LJPRO,"NJ0_NOME")
		Replace (cAliasTRB)->DXM_FAZ    With (cAlias)->DXM_FAZ
		Replace (cAliasTRB)->PESOBRUT   With (((cAlias)->DXM_PSBRUT * (cAlias)->DX0_RATEIO) / 100)
		Replace (cAliasTRB)->PESOTARA   With (((cAlias)->DXM_PSTARA * (cAlias)->DX0_RATEIO) / 100)
		Replace (cAliasTRB)->DX0_PSLIQU With (cAlias)->DX0_PSLIQU
		Replace (cAliasTRB)->PESOLONA   With (((cAlias)->DXM_PSLONA * (cAlias)->DX0_RATEIO) / 100)
		Replace (cAliasTRB)->DXM_OBS    With cObs
	
		MsUnlock()
	
		aTotais[1] += (((cAlias)->DXM_PSBRUT * (cAlias)->DX0_RATEIO) / 100)
		aTotais[2] += (((cAlias)->DXM_PSTARA * (cAlias)->DX0_RATEIO) / 100)
		aTotais[3] += (((cAlias)->DXM_PSLONA * (cAlias)->DX0_RATEIO) / 100)
		aTotais[4] += (cAlias)->DX0_PSLIQU
		aTotais[5] += 1
		(cAlias)->(dbSkip())
	
	
	End

	If Select(cAliasTRB) > 0
		(cAliasTRB)->(dbGoTop())
	EndIf

	(cAlias)->(dbCloseArea())

Return

/*
###################################################################################
# Função   : UBAC001RT                                                            #
# Descrição: Recalcula os totalizadores após confirmar o(s) filtro(s)             #
# Autor    : Inácio Luiz Kolling                                                  #
# Data     : 16/09/2014                                                           #  
###################################################################################
*/
Function UBAC001RT()
	oBrwSuper:ExecuteFilter(.t.)
	oBrwSuper:SetUseFilter(.T.)
	aTotais := {0,0,0,0,0}
	ARGSETIFARQUI(cAliasTRB)
	While !Eof()
		aTotais[1] += (cAliasTRB)->PESOBRUT
		aTotais[2] += (cAliasTRB)->PESOTARA
		aTotais[3] += (cAliasTRB)->PESOLONA
		aTotais[4] += (cAliasTRB)->DX0_PSLIQU
		aTotais[5] += 1
		DbSkip()
	End
	ARGSETIFARQUI(cAliasTRB)
Return

