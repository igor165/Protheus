#INCLUDE "UBAC004.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static oArqTemp := Nil
Static oArqTemp2 := Nil

// ----------------------------------------------------------------------------------------
/*/{Protheus.doc} UBAC004
Consulta Média de HVI por Bloco

@param: Nil
@author: Cleber Maldonado
@since: 25/07/2013
@Uso: UBA
/*/
// ----------------------------------------------------------------------------------------
Function UBAC004()
	Local oColumn   := Nil
	Local aRet		:= {}
	Local aCoors	:= FWGetDialogSize( oMainWnd )
	Local cPerg		:= "UBAC004"
	Local aSeek		:= {}

	Private nQtdl   := 0
	Private cAliasTRB := ""
    Private cAliasTRB2:= ""
	oBrowse	        := Nil
	oDlg            := Nil
	bKeyF12         := {|| If( Pergunte("UBAC004", .T.), ( cAliasTRB := UBAC004TRB()[1], oBrowse:SetAlias(cAliasTRB) ,oBrowse:Refresh()), .T. ) }
	SetKey( VK_F12, bKeyF12)
	
	If !Pergunte(cPerg, .T.)
		Return
	EndIf

	aRet := UBAC004TRB()  
	cAliasTRB 	:= aRet[1] // Arquivo temporario
	aArqTemp 	:= aRet[2] // Estrutura do arquivo temporario

	Aadd(aSeek,{TxDadosCpo("DXI_BLOCO")[1]	,{{"",TamSX3("DXI_BLOCO")[3],TamSX3("DXI_BLOCO")[1]	,0,' ',,}}})
	Aadd(aSeek,{TxDadosCpo("DX7_FIBRA")[1]	,{{"",TamSX3("DX7_FIBRA")[3],TamSX3("DX7_FIBRA")[1]	,0,' ',,}}})
	Aadd(aSeek,{TxDadosCpo("DX7_MIC")[1]	,{{"",TamSX3("DX7_MIC")[3]	,TamSX3("DX7_MIC")[1]	,0,' ',,}}})
	Aadd(aSeek,{TxDadosCpo("DX7_RES")[1]	,{{"",TamSX3("DX7_RES")[3]	,TamSX3("DX7_RES")[1]	,0,' ',,}}})
	Aadd(aSeek,{TxDadosCpo("DX7_SFI")[1]	,{{"",TamSX3("DX7_SFI")[3]	,TamSX3("DX7_SFI")[1]	,0,' ',,}}})
	Aadd(aSeek,{TxDadosCpo("DX7_UI")[1]		,{{"",TamSX3("DX7_UI")[3]	,TamSX3("DX7_UI")[1]	,0,' ',,}}})	

	If Select(cAliasTRB) > 0	
		(cAliasTRB)->(DbSetOrder(1))
		//- Coordenadas da area total da Dialog
		oSize := FWDefSize():New(.T.)
		oSize:AddObject('DLG',100,100,.T.,.T.)
		oSize:SetWindowSize(aCoors)
		oSize:lProp 	:= .T.
		oSize:Process()
		DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] OF oMainWnd PIXEL

		//-------------------------------------------------------------------
		// Define o Browse
		//-------------------------------------------------------------------
		DEFINE FWFORMBROWSE oBrowse DATA TABLE ALIAS cAliasTRB DESCRIPTION STR0001 OF oDlg  //"Consulta Média de HVI por Bloco"
		// Filtro
		oBrowse:SetTemporary(.T.)
		oBrowse:SetFieldFilter(CmpFiltro(@aArqTemp))
		oBrowse:SetdbFFilter(.T.)
		oBrowse:SetUseFilter(.T.)
		oBrowse:SetProfileID('1')
		oBrowse:SetSeeK(,aSeek)
		oBrowse:DisableDetails()
		oBrowse:AddButton("Sair",{||oDlg:End()},,,,,,'10')
		ADD COLUMN oColumn DATA { || &(aArqTemp[28,1])  }			   	TITLE AGRTITULO("DXD_FILIAL")	SIZE  aArqTemp[28,3]  ;
		PICTURE PesqPict("DXD","DXD_FILIAL")  TYPE TamSX3("DXD_FILIAL")[3]	OF oBrowse //"FILIAL"	
		ADD COLUMN oColumn DATA { || &(aArqTemp[29,1])  }			   	TITLE AGRTITULO("DXD_SAFRA")	SIZE  aArqTemp[29,3]  ;
		PICTURE PesqPict("DXD","DXD_SAFRA")  TYPE TamSX3("DXD_SAFRA")[3]	OF oBrowse //"SAFRA"				
		ADD COLUMN oColumn DATA { || &(aArqTemp[1,1])  }			   	TITLE STR0002	SIZE  aArqTemp[1,3]  ;
		PICTURE PesqPict("DXI","DXI_BLOCO")  TYPE TamSX3("DXI_BLOCO")[3]	OF oBrowse //"Bloco"
		ADD COLUMN oColumn DATA { || AGC004Stat(&(aArqTemp[23,1])) }		TITLE STR0010	SIZE  10 OF oBrowse //"Status"
		ADD COLUMN oColumn DATA { || &(aArqTemp[2,1])  }			  	TITLE STR0003	SIZE  aArqTemp[2,3]  ;
		PICTURE PesqPict("DXI","DXI_PRDTOR") TYPE TamSX3("DXI_PRDTOR")[3]	OF oBrowse //"Produtor"
		ADD COLUMN oColumn DATA { || &(aArqTemp[3,1])  } 		   		TITLE STR0004	SIZE  aArqTemp[3,3]  ;
		PICTURE PesqPict("DXD","DXD_QTDVNC") TYPE TamSX3("DXD_QTDVNC")[3]	OF oBrowse //"Fardos"
		ADD COLUMN oColumn DATA { || &(aArqTemp[4,1])  } 		   		TITLE STR0005	SIZE  aArqTemp[4,3]  ;
		PICTURE "9999"						 TYPE "N"						OF oBrowse //"c/HVI"
		ADD COLUMN oColumn DATA { || &(aArqTemp[5,1])  }			   	TITLE STR0006	SIZE  aArqTemp[5,3]  ;
		PICTURE "9999"						 TYPE "N"						OF oBrowse //"s/HVI"
		ADD COLUMN oColumn DATA { || &(aArqTemp[6,1])  }  		   		TITLE STR0007	SIZE  aArqTemp[6,3]  ;
		PICTURE PesqPict("DXL","DXL_PSLIQU") TYPE TamSX3("DXL_PSLIQU")[3]	OF oBrowse //"Peso Liquido"
		ADD COLUMN oColumn DATA { || &(aArqTemp[30,1])  }			   	TITLE STR0045	SIZE  aArqTemp[30,3]  ;
		PICTURE PesqPict("DXK","DXK_CLAVIS") TYPE TamSX3("DXK_CLAVIS")[3]	OF oBrowse //"Classificação Visual"
		ADD COLUMN oColumn DATA { || &(aArqTemp[7,1])  }			   	TITLE STR0008 SIZE  aArqTemp[7,3]  ;
		PICTURE PesqPict("DXI","DXI_CLACOM") TYPE TamSX3("DXI_CLACOM")[3]	OF oBrowse //"Classificação Comercial"	
		ADD COLUMN oColumn DATA { || &(aArqTemp[32,1])  }			   	TITLE STR0046	SIZE  aArqTemp[32,3]  ;
		PICTURE PesqPict("DXK","DXK_CLACON") TYPE TamSX3("DXK_CLACON")[3]	OF oBrowse //"Classificação Conferência"
		ADD COLUMN oColumn DATA { || &(aArqTemp[31,1])  }			   	TITLE STR0047	SIZE  aArqTemp[31,3]  ;
		PICTURE PesqPict("DXK","DXK_TIPCON") TYPE TamSX3("DXK_TIPCON")[3]	OF oBrowse //"Tipo Conferência"
		ADD COLUMN oColumn DATA { || AGRMMToPol(&(aArqTemp[8,1])) }		TITLE STR0009	SIZE  aArqTemp[8,3]  ;
		PICTURE PesqPict("DX7","DX7_FIBRA")  TYPE TamSX3("DX7_FIBRA")[3]	OF oBrowse //"Fibra"
		ADD COLUMN oColumn DATA { || &(aArqTemp[9,1])  }			   	TITLE STR0022	SIZE  aArqTemp[9,3]  ;
		PICTURE PesqPict("DX7","DX7_MIC")	 TYPE TamSX3("DX7_MIC")[3]		OF oBrowse
		ADD COLUMN oColumn DATA { || &(aArqTemp[10,1]) }			   	TITLE STR0023	SIZE  aArqTemp[10,3] ;
		PICTURE PesqPict("DX7","DX7_RES")	 TYPE TamSX3("DX7_RES")[3]		OF oBrowse
		ADD COLUMN oColumn DATA { || &(aArqTemp[11,1]) }		   	   	TITLE STR0025	SIZE  aArqTemp[11,3] ;
		PICTURE PesqPict("DX7","DX7_SFI")	 TYPE TamSX3("DX7_SFI")[3]		OF oBrowse
		ADD COLUMN oColumn DATA { || &(aArqTemp[12,1]) }		   	   	TITLE STR0029	SIZE  aArqTemp[12,3] ;
		PICTURE PesqPict("DX7","DX7_CSP")	 TYPE TamSX3("DX7_CSP")[3]		OF oBrowse
		ADD COLUMN oColumn DATA { || &(aArqTemp[27,1]) }		   	   	TITLE AGRTITULO("DX7_SCI")	SIZE  aArqTemp[27,3] ;
		PICTURE PesqPict("DX7","DX7_SCI")	 TYPE TamSX3("DX7_SCI")[3]		OF oBrowse
		ADD COLUMN oColumn DATA { || &(aArqTemp[13,1]) }			   	TITLE STR0031	SIZE  aArqTemp[13,3] ;
		PICTURE PesqPict("DX7","DX7_RD")	 TYPE TamSX3("DX7_RD")[3]		OF oBrowse
		ADD COLUMN oColumn DATA { || &(aArqTemp[14,1]) }		   	   	TITLE STR0035	SIZE  aArqTemp[14,3] ;
		PICTURE PesqPict("DX7","DX7_MAISB")  TYPE TamSX3("DX7_MAISB")[3]	OF oBrowse
		ADD COLUMN oColumn DATA { || &(aArqTemp[15,1]) }			   	TITLE STR0024	SIZE  aArqTemp[15,3] ;
		PICTURE PesqPict("DX7","DX7_UI")	 TYPE TamSX3("DX7_UI")[3]		OF oBrowse
		ADD COLUMN oColumn DATA { || &(aArqTemp[16,1]) }			   	TITLE STR0026	SIZE  aArqTemp[16,3] ;
		PICTURE PesqPict("DX7","DX7_ELONG")  TYPE TamSX3("DX7_ELONG")[3]	OF oBrowse
		ADD COLUMN oColumn DATA { || &(aArqTemp[17,1]) }		   	   	TITLE STR0027	SIZE  aArqTemp[17,3] ;
		PICTURE PesqPict("DX7","DX7_LEAF")	 TYPE TamSX3("DX7_LEAF")[3]	OF oBrowse
		ADD COLUMN oColumn DATA { || &(aArqTemp[18,1]) }			   	TITLE STR0028	SIZE  aArqTemp[18,3] ;
		PICTURE PesqPict("DX7","DX7_AREA")	 TYPE TamSX3("DX7_AREA")[3]	OF oBrowse
		ADD COLUMN oColumn DATA { || &(aArqTemp[19,1]) }			   	TITLE STR0030	SIZE  aArqTemp[19,3] ;
		PICTURE PesqPict("DX7","DX7_CG")	 TYPE TamSX3("DX7_CG")[3]		OF oBrowse
		ADD COLUMN oColumn DATA { || &(aArqTemp[20,1]) }			   	TITLE STR0032	SIZE  aArqTemp[20,3] ;
		PICTURE PesqPict("DX7","DX7_COUNT")  TYPE TamSX3("DX7_COUNT")[3]	OF oBrowse
		ADD COLUMN oColumn DATA { || &(aArqTemp[21,1]) }			   	TITLE STR0033	SIZE  aArqTemp[21,3] ;
		PICTURE PesqPict("DX7","DX7_UHM")    TYPE TamSX3("DXI_CODIGO")[3]	OF oBrowse
		ADD COLUMN oColumn DATA { || &(aArqTemp[22,1]) }			  	TITLE STR0034	SIZE  aArqTemp[22,3] ;
		PICTURE PesqPict("DX7","DX7_MATU")	 TYPE TamSX3("DX7_MATU")[3]		OF oBrowse
		ADD COLUMN oColumn DATA { || &(aArqTemp[24,1]) }			   	TITLE STR0011	SIZE  aArqTemp[24,3] ;
		PICTURE PesqPict("DXS","DXS_CLIENT") TYPE TamSX3("DXS_CLIENT")[3]	OF oBrowse //"Destino"
		ADD COLUMN oColumn DATA { || &(aArqTemp[25,1]) }			   	TITLE STR0012	SIZE  aArqTemp[25,3] ;
		PICTURE PesqPict("DXS","DXS_CLIENT") TYPE TamSX3("DXS_CLIENT")[3]	OF oBrowse //"Nr. Contrato"

		oBrowse:SetDoubleClick({|| ViewFard(cAliasTRB)})

		//-------------------------------------------------------------------
		// Ativação do Browse
		//-------------------------------------------------------------------
		ACTIVATE FWFORMBROWSE oBrowse

		ACTIVATE MSDIALOG oDlg CENTER

		(cAliasTRB)->(dbCloseArea())
	EndIf

	SetKey( VK_F12, Nil)
	
	//Elimina a tabela temporária, se houver
	AGRDLTPTB(oArqTemp)
	AGRDLTPTB(oArqTemp2)
	
Return

/*/{Protheus.doc} CmpFiltro
Função para retornar estrutuda dos campos do filtro d Média HVI

@param: aArqTemp
@author: Alexandre Cuchi
@since: 29/05/2014
@version 1.0
/*/
Static Function CmpFiltro(aArqTemp)
	Local aCampos := {}
	// Nom do cmp ,Desc. do campo           ,Tipo do campo   ,Tamanho         ,Decimal         ,Picture
	AAdd(aCampos,{aArqTemp[01][1], STR0002, aArqTemp[01][2], aArqTemp[01][3], aArqTemp[01][4], ""})
	AAdd(aCampos,{aArqTemp[02][1], STR0003, aArqTemp[02][2], aArqTemp[02][3], aArqTemp[02][4], ""})
	AAdd(aCampos,{aArqTemp[03][1], STR0004, aArqTemp[03][2], aArqTemp[03][3], aArqTemp[03][4], ""})
	AAdd(aCampos,{aArqTemp[04][1], STR0005, aArqTemp[04][2], aArqTemp[04][3], aArqTemp[04][4], ""})
	AAdd(aCampos,{aArqTemp[05][1], STR0006, aArqTemp[05][2], aArqTemp[05][3], aArqTemp[05][4], ""})
	AAdd(aCampos,{aArqTemp[06][1], STR0007, aArqTemp[06][2], aArqTemp[06][3], aArqTemp[06][4], ""})
	AAdd(aCampos,{aArqTemp[07][1], STR0008, aArqTemp[07][2], aArqTemp[07][3], aArqTemp[07][4], ""})
	AAdd(aCampos,{aArqTemp[08][1], STR0009, aArqTemp[08][2], aArqTemp[08][3], aArqTemp[08][4], ""})
	AAdd(aCampos,{aArqTemp[09][1], STR0022, aArqTemp[09][2], aArqTemp[09][3], aArqTemp[09][4], ""})
	AAdd(aCampos,{aArqTemp[10][1], STR0023, aArqTemp[10][2], aArqTemp[10][3], aArqTemp[10][4], ""})
	AAdd(aCampos,{aArqTemp[11][1], STR0025, aArqTemp[11][2], aArqTemp[11][3], aArqTemp[11][4], ""})
	AAdd(aCampos,{aArqTemp[12][1], STR0029, aArqTemp[12][2], aArqTemp[12][3], aArqTemp[12][4], ""})
	AAdd(aCampos,{aArqTemp[13][1], STR0031, aArqTemp[13][2], aArqTemp[13][3], aArqTemp[13][4], ""})
	AAdd(aCampos,{aArqTemp[14][1], STR0035, aArqTemp[14][2], aArqTemp[14][3], aArqTemp[14][4], ""})
	AAdd(aCampos,{aArqTemp[15][1], STR0024, aArqTemp[15][2], aArqTemp[15][3], aArqTemp[15][4], ""})
	AAdd(aCampos,{aArqTemp[16][1], STR0026, aArqTemp[16][2], aArqTemp[16][3], aArqTemp[16][4], ""})
	AAdd(aCampos,{aArqTemp[17][1], STR0027, aArqTemp[17][2], aArqTemp[17][3], aArqTemp[17][4], ""})
	AAdd(aCampos,{aArqTemp[18][1], STR0028, aArqTemp[18][2], aArqTemp[18][3], aArqTemp[18][4], ""})
	AAdd(aCampos,{aArqTemp[19][1], STR0030, aArqTemp[19][2], aArqTemp[19][3], aArqTemp[19][4], ""})
	AAdd(aCampos,{aArqTemp[20][1], STR0032, aArqTemp[20][2], aArqTemp[20][3], aArqTemp[20][4], ""})
	AAdd(aCampos,{aArqTemp[21][1], STR0033, aArqTemp[21][2], aArqTemp[21][3], aArqTemp[21][4], ""})
	AAdd(aCampos,{aArqTemp[22][1], STR0034, aArqTemp[22][2], aArqTemp[22][3], aArqTemp[22][4], ""})
	AAdd(aCampos,{aArqTemp[23][1], STR0010, aArqTemp[23][2], aArqTemp[23][3], aArqTemp[23][4], ""})
	AAdd(aCampos,{aArqTemp[24][1], STR0011, aArqTemp[24][2], aArqTemp[24][3], aArqTemp[24][4], ""})
	AAdd(aCampos,{aArqTemp[25][1], STR0012, aArqTemp[25][2], aArqTemp[25][3], aArqTemp[25][4], ""})
	AAdd(aCampos,{aArqTemp[26][1], STR0019, aArqTemp[26][2], aArqTemp[26][3], aArqTemp[26][4], ""})
	AAdd(aCampos,{aArqTemp[27][1], AGRTITULO("DX7_SCI")	   , aArqTemp[27][2], aArqTemp[27][3], aArqTemp[27][4], ""})
	AAdd(aCampos,{aArqTemp[28][1], AGRTITULO("DXD_FILIAL") , aArqTemp[28][2], aArqTemp[28][3], aArqTemp[28][4], ""})
	AAdd(aCampos,{aArqTemp[29][1], AGRTITULO("DXD_SAFRA")  , aArqTemp[29][2], aArqTemp[29][3], aArqTemp[29][4], ""})
	AAdd(aCampos,{aArqTemp[30][1], STR0045, aArqTemp[30][2], aArqTemp[30][3], aArqTemp[30][4], ""})
	AAdd(aCampos,{aArqTemp[31][1], STR0047, aArqTemp[31][2], aArqTemp[31][3], aArqTemp[31][4], ""})
	AAdd(aCampos,{aArqTemp[32][1], STR0046, aArqTemp[32][2], aArqTemp[32][3], aArqTemp[32][4], ""})

Return aCampos

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} UBAC004
Cria arquivo de trabalho com dados para exibição da consulta
@param: Nil
@author: Cleber Maldonado
@since: 23/07/2013
@Uso: UBA
/*/
// -------------------------------------------------------------------------------------

Function UBAC004TRB()
	Local aArqTemp 	:= {}
	Local cArqTemp	:= ""
	Local cQuery	:= ""
	Local cFilQuery := ""
	Local aCmpsTab := {}
	Local nx := 0
	local aIndex := {}
	If (!Empty(cAliasTRB)) .AND. (Select(cAliasTRB) > 0)
		(cAliasTRB)->(dbCloseArea())
	EndIf

	dbSelectArea("SX3")

	// Cria arquivo de trabalho
	aCmpsTab := TamSX3("DXI_BLOCO" );AADD(aArqTemp,{"BLOCO"   ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXI_PRDTOR");AADD(aArqTemp,{"PRODUTOR",aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXL_PSLIQU");AADD(aArqTemp,{"FARDOS"  ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXL_PSLIQU");AADD(aArqTemp,{"C_HVI"   ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXL_PSLIQU");AADD(aArqTemp,{"S_HVI"   ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXL_PSLIQU");AADD(aArqTemp,{"PESO"    ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXI_CLACOM");AADD(aArqTemp,{"CLASSIF" ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DX7_FIBRA" );AADD(aArqTemp,{"FIBRA"   ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DX7_MIC"   );AADD(aArqTemp,{"MIC"     ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DX7_RES"   );AADD(aArqTemp,{"RES"     ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DX7_SFI"   );AADD(aArqTemp,{"SFI"     ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DX7_CSP"   );AADD(aArqTemp,{"CSP"     ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DX7_RD"    );AADD(aArqTemp,{"RD"      ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DX7_MAISB" );AADD(aArqTemp,{"MAISB"   ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DX7_UI"    );AADD(aArqTemp,{"UI"      ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DX7_ELONG" );AADD(aArqTemp,{"ELONG"   ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DX7_LEAF"  );AADD(aArqTemp,{"LEAF"    ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DX7_AREA"  );AADD(aArqTemp,{"AREA"    ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DX7_CG"    );AADD(aArqTemp,{"CG"      ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DX7_COUNT" );AADD(aArqTemp,{"CONT"    ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DX7_UHM"   );AADD(aArqTemp,{"UHM"     ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DX7_MATU"  );AADD(aArqTemp,{"MATU"    ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXL_STATUS");AADD(aArqTemp,{"STATUS" ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXS_CLIENT");AADD(aArqTemp,{"DESTINO" ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXS_CODCTP");AADD(aArqTemp,{"CONTRATO",aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXS_CODIGO");AADD(aArqTemp,{"ROMANEIO",aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DX7_SCI")	;AADD(aArqTemp,{"SCI",aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXD_FILIAL");AADD(aArqTemp,{"DXD_FILIAL" ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXD_SAFRA" );AADD(aArqTemp,{"DXD_SAFRA"  ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXK_CLAVIS");AADD(aArqTemp,{"DXK_CLAVIS" ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXK_TIPCON");AADD(aArqTemp,{"DXK_TIPCON" ,aCmpsTab[3], 06, aCmpsTab[2]})
	aCmpsTab := TamSX3("DXK_CLACON");AADD(aArqTemp,{"DXK_CLACON" ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})


	//-- Cria Indice de Trabalho
	cArqTemp := GetNextAlias()
	For nx := 1 To Len(aArqTemp)
		if aArqTemp[nx,1] $ "BLOCO|FIBRA|MIC|RES|SFI|UI"
			//A funcao AgrCrTpTb adiciona o nome do indice
			AADD(aIndex,{"i"+cValToChar(nx), aArqTemp[nx,1]})
		Endif
	Next nX 	
	oArqTemp := AGRCRTPTB(cArqTemp, {aArqTemp, aIndex })
	cAliasTRB := cArqTemp
	
	#IFDEF TOP
	cAlias := "AliasQry"
	cQuery	:= " 	SELECT DXD_FILIAL, DXD.DXD_CODIGO, DXD_SAFRA,DXI.DXI_PRDTOR,COUNT(DXI.DXI_ETIQ) AS DXD_QTDVNC, COUNT(HVI.DX7_ETIQ) AS FDC_HVI, "
	cQuery	+= " 	(COUNT(DXI.DXI_ETIQ) - COUNT(HVI.DX7_ETIQ)) AS FDS_HVI,																			"
	cQuery	+= " 	SUM(DXI.DXI_PSLIQU) AS PESOLIQ,"
	cQuery	+= " 	DXD_CLACOM, "

	cQuery	+= " 	DXK.DXK_CLAVIS, "
	cQuery	+= " 	DXK.DXK_TIPCON, "
	cQuery	+= " 	DXK.DXK_CLACON, "
	
	cQuery	+= " 	AVG(DX7_FIBRA) AS M_FIBRA,	"
	cQuery	+= " 	AVG(DX7_MIC)   AS M_MIC, "
	cQuery	+= " 	AVG(DX7_RES)   AS M_RES, "
	cQuery	+= " 	AVG(DX7_SFI)   AS M_SFI, "
	cQuery	+= " 	AVG(DX7_CSP)   AS M_CSP, " 
	cQuery	+= " 	AVG(DX7_SCI)   AS M_SCI, "
	cQuery	+= "  	AVG(DX7_RD)    AS M_RD,  "
	cQuery	+= "  	AVG(DX7_MAISB) AS M_MAISB, "
	cQuery	+= "   	AVG(DX7_UI)    AS M_UI,"
	cQuery	+= "   	AVG(DX7_LEAF)  AS M_LEAF,"
	cQuery	+= "   	AVG(DX7_ELONG) AS M_ELONG,"
	cQuery	+= "   	AVG(DX7_AREA)  AS M_AREA, "
	cQuery	+= "   	MAX(DX7_CG)    AS M_CG,   "
	cQuery	+= "   	AVG(DX7_COUNT) AS M_COUNT,"
	cQuery	+= "   	AVG(DX7_UHM)   AS M_UHM,  "
	cQuery	+= "   	AVG(DX7_MATU)  AS M_MATU, "
	cQuery	+= "   	DXS.DXS_CLIENT, "
	cQuery	+= "   	DXS.DXS_CODCTP,"
	cQuery	+= "	CASE WHEN DXI.DXI_ROMSAI = '' THEN CASE WHEN DXI.DXI_CODRES = '' THEN '1' ELSE '2' END ELSE '3' END AS  STATUS"
	cQuery	+= "	FROM "+RetSqlName("DXI")+" DXI "
	cQuery	+= "		INNER JOIN "+RetSqlName("DXD")+ " DXD "
	cQuery	+= "			ON DXD.D_E_L_E_T_   = ' ' "
	cQuery	+= "			AND DXD.DXD_CODIGO  = DXI.DXI_BLOCO	"
	cQuery	+= "			AND DXD.DXD_SAFRA   = DXI.DXI_SAFRA	"
	cQuery	+= "			AND DXD.DXD_FILIAL  = DXI.DXI_FILIAL	"

	cQuery	+= "		LEFT JOIN "+RetSqlName("DXK")+ " DXK "
	cQuery	+= "			ON DXK.D_E_L_E_T_ = ' ' "
	cQuery	+= "			AND DXK.DXK_FILIAL = DXI.DXI_FILIAL "
	cQuery	+= "			AND DXK.DXK_ETIQ  = DXI.DXI_ETIQ "
	cQuery	+= "			AND DXK.DXK_SAFRA = DXI.DXI_SAFRA "
	cQuery	+= "			AND DXK.DXK_TIPO = '1' "


	cQuery	+= "		LEFT JOIN "+RetSqlName("DX7")+ " HVI "
	cQuery	+= "			ON HVI.DX7_ETIQ   = DXI.DXI_ETIQ	"
	cQuery	+= "			AND HVI.DX7_FILIAL = DXI.DXI_FILIAL	"
	cQuery	+= "			AND HVI.DX7_SAFRA  = DXI.DXI_SAFRA	"
	cQuery	+= "			AND HVI.D_E_L_E_T_  = ' '	"
	cQuery	+= "			AND HVI.DX7_ATIVO = '1'	"
	cQuery	+= "		LEFT JOIN "+RetSqlName("DXS")+" DXS ON	" 
	cQuery	+= "			DXS.D_E_L_E_T_	=  ' ' AND " 
	cQuery	+= "   		DXS.DXS_FILIAL	= DXI.DXI_FILIAL AND	"
	cQuery	+= "  			DXS.DXS_CODIGO	= DXI.DXI_ROMSAI	" 


	If !Empty(mv_par01) //Safra
		cFilQuery += if(!Empty(cFilQuery)," AND ","")
		cFilQuery += "	DXI.DXI_SAFRA = '" + mv_par01 +"'"
	EndIf

	If !Empty(mv_par02)//Produtor
		cFilQuery += if(!Empty(cFilQuery)," AND ","")
		cFilQuery += "	DXI.DXI_PRDTOR = '" + mv_par02 +"' " 
	EndIf
	If !Empty(mv_par03)// Loja
		cFilQuery += if(!Empty(cFilQuery)," AND ","")
		cFilQuery += " DXI.DXI_LJPRO = '" + mv_par03 +"'"
	endif 

	If !Empty(mv_par06)//Classificação Comercial
		cFilQuery += if(!Empty(cFilQuery)," AND ","")
		cFilQuery += "  DXI.DXI_CLACOM = '" + mv_par06 +"'"
	EndIf	

	If !Empty(mv_par04) .And. !Empty(mv_par05)//Laboratorio + Unidade
		cFilQuery += if(!Empty(cFilQuery)," AND ","")
		cFilQuery += "  HVI.DX7_LAB    = '" + mv_par04 +"' AND HVI.DX7_UNI = '" + mv_par05 +"'"
	EndIf

	If !Empty(mv_par08) .And. !Empty(mv_par09)//Cliente + Loja
		cFilQuery += if(!Empty(cFilQuery)," AND ","")
		cFilQuery += "  DXS.DXS_CLIENT    = '" + mv_par08 +"' AND DXS.DXS_LJCLI = '" + mv_par09 +"'"
	EndIf

	If !Empty(mv_par07)//Contrato
		cFilQuery += if(!Empty(cFilQuery)," AND ","")
		cFilQuery += "  DXS.DXS_CODCTP = '" + mv_par07 +"'"
	EndIf

	If !Empty(mv_par10)//Reserva
		cFilQuery += if(!Empty(cFilQuery)," AND ","")
		cFilQuery += "  DXI.DXI_CODRES= '" + mv_par10 +"'"
	EndIf

	If mv_par11 == 1 //Disponivel
		cFilQuery += if(!Empty(cFilQuery)," AND  ( "," (")
		cFilQuery += "CASE WHEN DXI.DXI_ROMSAI = '' THEN CASE WHEN DXI.DXI_CODRES = '' THEN '1' ELSE '2' END ELSE '3' END = '1' "	 
	EndIf

	If mv_par12 == 1 //Reservado
		cFilQuery += if (mv_par11 == 1," OR ", " AND ( ")	
		cFilQuery += "CASE WHEN DXI.DXI_ROMSAI = '' THEN CASE WHEN DXI.DXI_CODRES = '' THEN '1' ELSE '2' END ELSE '3' END = '2' "
	EndIf

	If mv_par13 == 1 //Entregues
		cFilQuery  += if (mv_par12 == 1 .or. mv_par11 == 1," OR ", " AND ( ")
		cFilQuery += "CASE WHEN DXI.DXI_ROMSAI = '' THEN CASE WHEN DXI.DXI_CODRES = '' THEN '1' ELSE '2' END ELSE '3' END = '3' "	
	EndIf
	
	If(mv_par11 == 1 .OR. mv_par12 == 1 .Or.  mv_par13 == 1, cFilQuery += " )", "" )
	
	If !Empty(mv_par14)//BLOCO
		cFilQuery += if(!Empty(cFilQuery)," AND ","")
		cFilQuery += "  DXD.DXD_CODIGO= '" + mv_par14 +"'"
	EndIf	

	If !Empty(mv_par16)
		cFilQuery += if(!Empty(cFilQuery)," AND ","")
		cFilQuery += "  DXI.DXI_CODUNB = '" + mv_par16 + "'"
	Endif

	cQuery += if(!Empty(cFilQuery)," WHERE DXI.D_E_L_E_T_ = ' ' AND "+cFilQuery,"")
	cQuery +=  "GROUP BY DXD_FILIAL,DXD.DXD_CODIGO, DXD_SAFRA,DXI_PRDTOR, DXD_CLACOM,  DXS.DXS_CLIENT,DXS.DXS_CODCTP, DXK.DXK_CLAVIS, DXK.DXK_TIPCON, DXK.DXK_CLACON, CASE WHEN DXI.DXI_ROMSAI = '' THEN CASE WHEN DXI.DXI_CODRES = '' THEN '1' ELSE '2' END ELSE '3' END "
	cQuery +=  "ORDER BY DXD_FILIAL,DXD.DXD_CODIGO, DXD_SAFRA,DXI_PRDTOR, DXD_CLACOM,  DXS.DXS_CLIENT,DXS.DXS_CODCTP"

	cQuery := ChangeQuery(cQuery)

	cAlias := "AliasQry"
	dbUseArea( .T., 'TOPCONN', TcGenQry( , , cQuery), cAlias, .F., .T. )

	Count To nQtdl
	Processa({|| UBAC004P() },STR0039)

Return({cArqTemp, aArqTemp})

/* -------------------------------------------------------------------------------------
UBAC004P Processamento                  OBS: Foi incluído o temporizador
@param: Nil
@author: Inácio Luiz Kolling
@since: 17/06/2014
@Uso: UBAC004
-------------------------------------------------------------------------------------
*/
Static Function UBAC004P()
	If (!Empty(cAliasTRB)) .AND. (Select(cAliasTRB) > 0)
		(cAliasTRB)->(dbGoTop())
	EndIf
	ProcRegua(nQtdl)
	nRegl := 0
	(cAlias)->(dbGotop())
	While (cAlias)->(!Eof())
		nRegl ++
		IncProc(STR0040+Alltrim(Str(nRegl,5))+" / "+Alltrim(Str(nQtdl,5))) //"Processando Registro -> "
		// Atualiza arquivo temporário com o resultado da Query
		Reclock(cAliasTRB,.T.)
		Replace DXD_FILIAL   	With (cAlias)->DXD_FILIAL
		Replace DXD_SAFRA		With (cAlias)->DXD_SAFRA
		Replace BLOCO	   		With (cAlias)->DXD_CODIGO
		Replace PRODUTOR 		With (cAlias)->DXI_PRDTOR
		Replace FARDOS   		With (cAlias)->DXD_QTDVNC
		Replace C_HVI    		With (cAlias)->FDC_HVI
		Replace S_HVI    		With (cAlias)->FDS_HVI
		Replace PESO     		With (cAlias)->PESOLIQ
		Replace CLASSIF  		With (cAlias)->DXD_CLACOM
		Replace FIBRA    		With (cAlias)->M_FIBRA
		Replace MIC      		With (cAlias)->M_MIC
		Replace RES      		With (cAlias)->M_RES
		Replace SFI      		With (cAlias)->M_SFI
		Replace CSP      		With (cAlias)->M_CSP
		Replace SCI      		With (cAlias)->M_SCI
		Replace SFI      		With (cAlias)->M_SFI
		Replace RD       		With (cAlias)->M_RD
		Replace MAISB    		With (cAlias)->M_MAISB
		Replace UI       		With (cAlias)->M_UI
		Replace ELONG    		With (cAlias)->M_ELONG
		Replace LEAF     		With (cAlias)->M_LEAF
		Replace AREA     		With (cAlias)->M_AREA
		Replace CG       		With (cAlias)->M_CG
		Replace CONT     		With (cAlias)->M_COUNT
		Replace UHM      		With (cAlias)->M_UHM
		Replace MATU     		With (cAlias)->M_MATU
		Replace STATUS   		With (cAlias)->STATUS
		Replace DESTINO  		With (cAlias)->DXS_CLIENT
		Replace CONTRATO 		With (cAlias)->DXS_CODCTP
		Replace DXK_CLAVIS 		With (cAlias)->DXK_CLAVIS
		Replace DXK_TIPCON 		With If( (cAlias)->DXK_TIPCON == '1', STR0048 /*"Bom"*/, If( (cAlias)->DXK_TIPCON == '2', STR0049 /*"Médio"*/,  If( (cAlias)->DXK_TIPCON == '3', STR0050 /*"Fraco"*/,  " " )))
		Replace DXK_CLACON 		With (cAlias)->DXK_CLACON		

		Msunlock()
		(cAlias)->( dbSkip() )
	Enddo
	dbGoTop()
	#ENDIF
	(cAlias)->(dbCloseArea())
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AGC003Stat
@author Maicol Lange
@since 18/08/2015
/*/
//-------------------------------------------------------------------
Static Function AGC004Stat(cStatus)
	Do Case
	CASE cStatus = '3'
		cStatus := STR0044
	CASE cStatus = '2'
		cStatus := STR0043
	CASE cStatus = '1'
		cStatus := STR0042
	OTHERWISE
		//TODO Cadastrar liberar
		cStatus := "SEMSTATUS"
	ENDCASE
Return cStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRMMToPol
Função para converter milimetros para polegadas
@author Leonardo Quintania
@since 21/06/2013
@version MP11
/*/
//-------------------------------------------------------------------
Static Function AGRMMToPol(nMili)
	Local nPol := nMili

	If mv_par15 == 2
		nPol := nMili * 0.03937
	EndIf

Return nPol

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewFard
Função para apresentar os fardos do bloco posicionado na consulta
@author Aecio Ferreira Gomes
@since 27/07/2013
@version MP11
/*/
//-------------------------------------------------------------------
Static Function ViewFard(cAliasTRB)
	Local cQuery    	:= ""
	Local aArqTemp2  	:= {}
	Local cArqTemp2	:= ""
	Local nX := 0
	Local aIndex		:=	{}
	private aCoors   	:= FWGetDialogSize( oMainWnd )
	private cAlias   	:= GetNextAlias()

	If (!Empty(cAliasTRB2)) .AND. (Select(cAliasTRB2) > 0)
		(cAliasTRB2)->(dbCloseArea())
	EndIf
	
	If Select(cAlias) > 0
		(cAlias)->( dbCloseArea() )
	EndIf

	aArqTemp2 := CriaArray(.F.)
	cArqTemp2 := GetNextAlias()
	oArqTemp2 := AGRCRTPTB(cArqTemp2, {aArqTemp, {}} )
	
	cArqTemp2 := GetNextAlias()
	For nx := 1 To Len(aArqTemp2)
		if aArqTemp[nx,1] $ "DXI_CODIGO|DX7_FIBRA|DX7_MIC|DX7_RES|DX7_SFI|DX7_UI"
			//A funcao AgrCrTpTb adiciona o nome do indice
			AADD(aIndex,{"i"+cValToChar(nx), aArqTemp2[nx,1]})			
		Endif
	Next nX     
	oArqTemp2 := AGRCRTPTB(cArqTemp2, {aArqTemp2, aIndex })
	cAliasTRB2 := cArqTemp2
	
	cQuery := " SELECT DXI_ETIQ,DXI_CODIGO,DX7_ATIVO,DXI_CODRES,DXI_ROMSAI,"
	cQuery +=        "CASE WHEN DXI.DXI_ROMSAI  = '' THEN CASE WHEN DXI.DXI_CODRES = '' THEN '1' ELSE '2' END ELSE '3'  END AS TMP_STATUS,"
	cQuery +=        " DXI_CLACOM, DXK.DXK_CLAVIS, DXK.DXK_TIPCON, DXK.DXK_CLACON, DX7_MIC, DX7_RES, DX7_FIBRA, DX7_UI, DX7_SFI, DX7_ELONG,"
	cQuery +=        " DX7_LEAF, DX7_AREA, DX7_CSP, DX7_SCI, DX7_CG, DX7_RD, DX7_COUNT, DX7_UHM,"
	cQuery +=        " DX7_MATU, DX7_MAISB, DXL_CODPRO, DXL.DXL_FAZ, DXL_TALHAO, DXL_CODVAR "
	cQuery +=   " FROM "+ RetSqlName("DXI")+"  DXI"
	cQuery +=   " LEFT JOIN "+ RetSqlName("DX7") +"  DX7 ON DX7.D_E_L_E_T_ =  ' '  AND "
	cQuery +=  	" DX7.DX7_FILIAL = DXI.DXI_FILIAL	" 
	cQuery +=   "AND DX7_ATIVO = '1' AND  DX7.DX7_SAFRA = DXI.DXI_SAFRA  AND  DX7.DX7_ETIQ  = DXI.DXI_ETIQ "
	cQuery +=   " LEFT JOIN "+ RetSqlName("DXP") +"  DXP ON DXP.D_E_L_E_T_ =  ' ' AND  "
	cQuery +=        " DXP.DXP_FILIAL = DXI.DXI_FILIAL 	AND  	"
	cQuery +=        " DXP.DXP_CODIGO = DXI.DXI_CODRES  AND		"
	cQuery +=        " DXP.DXP_FILIAL = DXI.DXI_FILIAL 			"
	cQuery +=  " INNER JOIN "+ RetSqlName("DXL")+"  DXL ON DXL.D_E_L_E_T_ = ' ' AND  DXL_CODIGO = DXI.DXI_FARDAO AND"
	cQuery +=  		 " DXL.DXL_FILIAL   = '"+ xFilial('DXL')  + "'	AND	 "
	cQuery +=        " DXL.DXL_SAFRA  	= DXI.DXI_SAFRA 	AND  "
	cQuery +=        " DXL.DXL_LJPRO  	= DXI.DXI_LJPRO   	AND  "
	cQuery +=        " DXL.DXL_FAZ    	= DXI.DXI_FAZ "
	
	cQuery +=  " LEFT JOIN "+ RetSqlName("DXK")+"  DXK"
	cQuery +=        "  ON DXK.D_E_L_E_T_ = ' ' "
	cQuery +=        " AND DXK.DXK_FILIAL = DXI.DXI_FILIAL "
	cQuery +=        " AND DXK.DXK_ETIQ   = DXI.DXI_ETIQ "
	cQuery +=        " AND DXK.DXK_SAFRA  = DXI.DXI_SAFRA "
	cQuery +=        " AND DXK.DXK_TIPO   = '1'	"
	
	cQuery +=  " WHERE DXI.D_E_L_E_T_ = ' ' AND "
	cQuery +=        " DXI.DXI_BLOCO  = '" + AllTrim((cAliasTRB)->BLOCO) + "' AND "
	cQuery +=        " DXI.DXI_SAFRA  = '" + mv_par01 + "' AND DXI.DXI_FILIAL = '"+ AllTrim((cAliasTRB)->DXD_FILIAl)+"'"
	cQuery +=        "	AND CASE WHEN DXI.DXI_ROMSAI = '' THEN CASE WHEN DXI.DXI_CODRES = '' THEN '1' ELSE '2' END ELSE '3' END =  '"+(cAliasTRB)->STATUS+"'
	If !Empty(mv_par16)
		cQuery += " AND DXI.DXI_CODUNB = '" + mv_par16 + "'"
	Endif

	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., 'TOPCONN', TcGenQry( , , cQuery), cAlias, .F., .T. )
	Count To nQtdl
	Processa({|| UBAC0042P() },STR0039)

Return

/* -------------------------------------------------------------------------------------
UBAC004P Processamento                  OBS: Foi incluído o temporizador
@param: Nil
@author: Inácio Luiz Kolling
@since: 17/06/2014
@Uso: UBAC004
-------------------------------------------------------------------------------------
*/
Static Function UBAC0042P()
	Local oBrowse1   := Nil
	Local oDlg1      := Nil
	Local aSeek2	 := {}
	SetKey( VK_F12, Nil)
	ProcRegua(nQtdl)
	nRegl := 0
	(cAlias)->(dbGotop())
	While (cAlias)->(!Eof())
		nRegl ++
		IncProc(STR0040+Alltrim(Str(nRegl,5))+" / "+Alltrim(Str(nQtdl,5))) //"Processando Registro -> "
		// Atualiza arquivo temporário com o resultado da Query
		Reclock(cAliasTRB2,.T.)
		Replace DXI_ETIQ   With (cAlias)->DXI_ETIQ
		Replace DX7_ATIVO  With (cAlias)->DX7_ATIVO
		Replace DXI_CODIGO With (cAlias)->DXI_CODIGO
		Replace DXI_CODRES With (cAlias)->DXI_CODRES
		Replace TMP_STATUS With (cAlias)->TMP_STATUS
		Replace DXK_CLAVIS With (cAlias)->DXK_CLAVIS
		Replace DXK_CLACON With (cAlias)->DXK_CLACON
		Replace DXI_CLACOM With (cAlias)->DXI_CLACOM
		Replace DXK_TIPCON With If( (cAlias)->DXK_TIPCON == '1', STR0048 /*"Bom"*/, If( (cAlias)->DXK_TIPCON == '2', STR0049 /*"Médio"*/,  If( (cAlias)->DXK_TIPCON == '3', STR0050 /*"Fraco"*/,  " " )))
		Replace DXI_ROMSAI With (cAlias)->DXI_ROMSAI
		Replace DX7_MIC    With (cAlias)->DX7_MIC
		Replace DX7_RES    With (cAlias)->DX7_RES
		Replace DX7_FIBRA  With (cAlias)->DX7_FIBRA
		Replace DX7_UI     With (cAlias)->DX7_UI
		Replace DX7_SFI    With (cAlias)->DX7_SFI
		Replace DX7_ELONG  With (cAlias)->DX7_ELONG
		Replace DX7_LEAF   With (cAlias)->DX7_LEAF
		Replace DX7_AREA   With (cAlias)->DX7_AREA
		Replace DX7_CSP    With (cAlias)->DX7_CSP
		Replace DX7_SCI    With (cAlias)->DX7_SCI
		Replace DX7_CG     With (cAlias)->DX7_CG
		Replace DX7_RD     With (cAlias)->DX7_RD
		Replace DX7_COUNT  With (cAlias)->DX7_COUNT
		Replace DX7_UHM    With (cAlias)->DX7_UHM
		Replace DX7_MATU   With (cAlias)->DX7_MATU
		Replace DX7_MAISB  With (cAlias)->DX7_MAISB
		Replace DXL_FAZ    With (cAlias)->DXL_FAZ
		Replace DXL_TALHAO With (cAlias)->DXL_TALHAO
		Replace DXL_DESCVR With Posicione('NNV',1,xFilial('NNV')+(cAlias)->DXL_CODPRO+(cAlias)->DXL_CODVAR,'NNV_DESCRI')

		(cAliasTRB2)->( Msunlock() )
		(cAlias)->( dbSkip() )
	EndDo
	(cAlias)->(dbCloseArea())

	Aadd(aSeek2,{TxDadosCpo("DXI_CODIGO")[1],{{"",TamSX3("DXI_CODIGO")[3],TamSX3("DXI_CODIGO")[1],0,' ',,}}})
	Aadd(aSeek2,{TxDadosCpo("DX7_FIBRA")[1],{{"",TamSX3("DX7_FIBRA")[3],TamSX3("DX7_FIBRA")[1],0,' ',,}}})
	Aadd(aSeek2,{TxDadosCpo("DX7_MIC")[1],{{"",TamSX3("DX7_MIC")[3],TamSX3("DX7_MIC")[1],0,' ',,}}})
	Aadd(aSeek2,{TxDadosCpo("DX7_RES")[1],{{"",TamSX3("DX7_RES")[3],TamSX3("DX7_RES")[1],0,' ',,}}})
	Aadd(aSeek2,{TxDadosCpo("DX7_SFI")[1],{{"",TamSX3("DX7_SFI")[3],TamSX3("DX7_SFI")[1],0,' ',,}}})
	Aadd(aSeek2,{TxDadosCpo("DX7_UI")[1],{{"",TamSX3("DX7_UI")[3],TamSX3("DX7_UI")[1],0,' ',,}}})	

	//- Coordenadas da area total da Dialog
	oSize := FWDefSize():New(.T.)
	oSize:AddObject('DLG',100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.
	oSize:Process()

	DEFINE MSDIALOG oDlg1 FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] OF oDlg1 PIXEL

	//-------------------------------------------------------------------
	// Define o Browse
	//-------------------------------------------------------------------
	DEFINE FWFORMBROWSE oBrowse1 DATA TABLE ALIAS cAliasTRB2 DESCRIPTION STR0041 OF oDlg1
	//	Filtros
	
	
	oBrowse1:SetTemporary(.T.)
	oBrowse1:SetFieldFilter(CriaArray())
	oBrowse1:SetDBFFilter(.T.)
	oBrowse1:SetUseFilter(.T.)
	oBrowse1:SetProfileID('2')
	oBrowse1:SetSeek(,aSeek2)
	oBrowse1:DisableDetails()
	oBrowse1:AddButton("Sair",{||oDlg1:End()},,,,,,'10')
	ADD COLUMN oColumn DATA { || DXI_ETIQ    }TITLE STR0020 SIZE  TamSX3("DXI_ETIQ"  )[1] TYPE TamSX3("DXI_ETIQ")[3] PICTURE PesqPict("DXI","DXI_ETIQ"  ) OF oBrowse1
	ADD COLUMN oColumn DATA { || DXI_CODIGO  }TITLE STR0004 SIZE  TamSX3("DXI_CODIGO")[1] PICTURE PesqPict("DXI","DXI_CODIGO") OF oBrowse1 //"CODRES"
	ADD COLUMN oColumn DATA { || DXI_CODRES  }TITLE STR0021 SIZE  TamSX3("DXI_CODRES")[1] PICTURE PesqPict("DXI","DXI_CODRES") OF oBrowse1 //"CODRES"
	ADD COLUMN oColumn DATA { || DXI_ROMSAI  }TITLE STR0019 SIZE  TamSX3("DXI_ROMSAI")[1] PICTURE PesqPict("DXI","DXI_ROMSAI") OF oBrowse1
	ADD COLUMN oColumn DATA { || AGC004Stat(TMP_STATUS)  }TITLE STR0010	SIZE  10			             					 	                  OF oBrowse1 //"Status"	
	ADD COLUMN oColumn DATA { || DXK_CLAVIS  }TITLE STR0045 SIZE  TamSX3("DXK_CLAVIS")[1] PICTURE PesqPict("DXK","DXK_CLAVIS") OF oBrowse1
	ADD COLUMN oColumn DATA { || DXK_CLACON  }TITLE STR0046 SIZE  TamSX3("DXK_CLACON")[1] PICTURE PesqPict("DXK","DXK_CLACON") OF oBrowse1
	ADD COLUMN oColumn DATA { || DXI_CLACOM  }TITLE STR0008 SIZE  TamSX3("DXI_CLACOM")[1] PICTURE PesqPict("DXI","DXI_CLACOM") OF oBrowse1
	ADD COLUMN oColumn DATA { || DXK_TIPCON  }TITLE STR0047 SIZE  TamSX3("DXK_TIPCON")[1] PICTURE PesqPict("DXK","DXK_TIPCON") OF oBrowse1
	ADD COLUMN oColumn DATA { || DX7_MIC     }TITLE STR0022 SIZE  TamSX3("DX7_MIC"   )[1] PICTURE PesqPict("DX7","DX7_MIC"   ) OF oBrowse1
	ADD COLUMN oColumn DATA { || DX7_RES     }TITLE STR0023 SIZE  TamSX3("DX7_RES"   )[1] PICTURE PesqPict("DX7","DX7_RES"   ) OF oBrowse1
	ADD COLUMN oColumn DATA { || DX7_FIBRA   }TITLE STR0009 SIZE  TamSX3("DX7_FIBRA" )[1] PICTURE PesqPict("DX7","DX7_FIBRA" ) OF oBrowse1
	ADD COLUMN oColumn DATA { || DX7_UI      }TITLE STR0024	SIZE  TamSX3("DX7_UI"    )[1] PICTURE PesqPict("DX7","DX7_UI"    ) OF oBrowse1
	ADD COLUMN oColumn DATA { || DX7_SFI     }TITLE STR0025	SIZE  TamSX3("DX7_SFI"   )[1] PICTURE PesqPict("DX7","DX7_SFI"   ) OF oBrowse1
	ADD COLUMN oColumn DATA { || DX7_ELONG   }TITLE STR0026 SIZE  TamSX3("DX7_ELONG" )[1] PICTURE PesqPict("DX7","DX7_ELONG" ) oF oBrowse1
	ADD COLUMN oColumn DATA { || DX7_LEAF    }TITLE STR0027 SIZE  TamSX3("DX7_LEAF"  )[1] PICTURE PesqPict("DX7","DX7_LEAF"  ) OF oBrowse1
	ADD COLUMN oColumn DATA { || DX7_AREA    }TITLE STR0028 SIZE  TamSX3("DX7_AREA"  )[1] PICTURE PesqPict("DX7","DX7_AREA"  ) OF oBrowse1
	ADD COLUMN oColumn DATA { || DX7_CSP     }TITLE STR0029	SIZE  TamSX3("DX7_CSP"   )[1] PICTURE PesqPict("DX7","DX7_CSP"   ) OF oBrowse1
	ADD COLUMN oColumn DATA { || DX7_SCI     }TITLE AGRTITULO("DX7_SCI")	SIZE  TamSX3("DX7_SCI"   )[1] PICTURE PesqPict("DX7","DX7_SCI"   ) OF oBrowse1
	ADD COLUMN oColumn DATA { || DX7_CG      }TITLE STR0030 SIZE  TamSX3("DX7_CG"    )[1] PICTURE PesqPict("DX7","DX7_CG"    ) OF oBrowse1
	ADD COLUMN oColumn DATA { || DX7_RD      }TITLE STR0031 SIZE  TamSX3("DXI_ROMSAI")[1] PICTURE PesqPict("DX7","DX7_RD"    ) OF oBrowse1
	ADD COLUMN oColumn DATA { || DX7_COUNT   }TITLE STR0032	SIZE  TamSX3("DX7_COUNT" )[1] PICTURE PesqPict("DX7","DX7_COUNT" ) OF oBrowse1
	ADD COLUMN oColumn DATA { || DX7_UHM     }TITLE STR0033 SIZE  TamSX3("DX7_UHM"   )[1] PICTURE PesqPict("DX7","DX7_UHM"   ) OF oBrowse1
	ADD COLUMN oColumn DATA { || DX7_MATU    }TITLE STR0034	SIZE  TamSX3("DX7_MATU"  )[1] PICTURE PesqPict("DX7","DX7_MATU"  ) OF oBrowse1
	ADD COLUMN oColumn DATA { || DX7_MAISB   }TITLE STR0035	SIZE  TamSX3("DX7_MAISB" )[1] PICTURE PesqPict("DX7","DX7_MAISB" ) OF oBrowse1
	ADD COLUMN oColumn DATA { || DXL_FAZ     }TITLE STR0036 SIZE  TamSX3("DXL_FAZ"   )[1] PICTURE PesqPict("DXL","DXL_FAZ"   ) OF oBrowse1
	ADD COLUMN oColumn DATA { || DXL_TALHAO  }TITLE STR0037	SIZE  TamSX3("DXL_TALHAO")[1] PICTURE PesqPict("DXL","DXL_TALHAO") OF oBrowse1
	ADD COLUMN oColumn DATA { || DXL_DESCVR  }TITLE STR0038 SIZE  TamSX3("DXL_DESCVR")[1] PICTURE PesqPict("DXL","DXL_DESCVR") OF oBrowse1


	//-------------------------------------------------------------------
	// Ativação do Browse
	//-------------------------------------------------------------------
	ACTIVATE FWFORMBROWSE oBrowse1

	ACTIVATE MSDIALOG oDlg1 CENTER
	
	bKeyF12 := {|| If( Pergunte("UBAC004", .T.), ( cAliasTRB := UBAC004TRB()[1], oBrowse:SetAlias(cAliasTRB) ,oBrowse:Refresh()), .T. ) }
	SetKey( VK_F12, bKeyF12)

Return

/*/{Protheus.doc}   CriaArray
Função para retornar estrutuda dos campos da Classificação HVI
@param lRetorno := Se .T. retorna estrutura para os filtros, se .F. retorna estrutura dos campos.
@author Alexandre Cuchi	
@since 29/05/2014
@version 1.0
/*/
Static Function CriaArray(lRetorno)
	Local aCampos := {}
	Local aTamCmps := {}

	Default lRetorno := .T.

	If lRetorno
		//           Nome do campo , Descrição do campo     , Tipo, Tamanho,      decimal, picture
		aTamCmps := TamSX3("DXI_ETIQ"  );AAdd(aCampos,{"DXI_ETIQ"   ,STR0020 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_ATIVO" );AAdd(aCampos,{"DX7_ATIVO"  ,"Ativo" ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DXI_CODIGO");AAdd(aCampos,{"DXI_CODIGO" ,"Codigo",aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DXI_CODRES");AAdd(aCampos,{"DXI_CODRES" ,STR0021 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		
		aTamCmps := TamSX3("DXK_CLAVIS");AAdd(aCampos,{"DXK_CLAVIS" ,STR0008 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DXK_CLACON");AAdd(aCampos,{"DXK_CLACON" ,STR0008 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DXI_CLACOM");AAdd(aCampos,{"DXI_CLACOM" ,STR0008 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DXK_TIPCON");AAdd(aCampos,{"DXK_TIPCON" ,STR0008 ,aTamCmps[3], 6,aTamCmps[2],""})

		aTamCmps := TamSX3("DXI_ROMSAI");AAdd(aCampos,{"DXI_ROMSAI" ,STR0019 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_MIC"   );AAdd(aCampos,{"DX7_MIC"    ,STR0022 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_RES"   );AAdd(aCampos,{"DX7_RES"    ,STR0023 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_FIBRA" );AAdd(aCampos,{"DX7_FIBRA"  ,STR0009 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_UI"    );AAdd(aCampos,{"DX7_UI"     ,STR0024 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})

		aTamCmps := TamSX3("DX7_SFI"   );AAdd(aCampos,{"DX7_SFI"    ,STR0025 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_ELONG" );AAdd(aCampos,{"DX7_ELONG"  ,STR0026 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_LEAF"  );AAdd(aCampos,{"DX7_LEAF"   ,STR0027 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_AREA"  );AAdd(aCampos,{"DX7_AREA"   ,STR0028 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_CSP"   );AAdd(aCampos,{"DX7_CSP"    ,STR0029 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_SCI"   );AAdd(aCampos,{"DX7_SCI"    ,AGRTITULO("DX7_SCI") ,aTamCmps[3],aTamCmps[1],aTamCmps[2],PesqPict("DX7","DX7_SCI")})

		aTamCmps := TamSX3("DX7_CG"    );AAdd(aCampos,{"DX7_CG"     ,STR0030 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_RD"    );AAdd(aCampos,{"DX7_RD"     ,STR0031 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_COUNT" );AAdd(aCampos,{"DX7_COUNT"  ,STR0032 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_UHM"   );AAdd(aCampos,{"DX7_UHM"    ,STR0033 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_MATU"  );AAdd(aCampos,{"DX7_MATU"   ,STR0034 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})

		aTamCmps := TamSX3("DX7_MAISB" );AAdd(aCampos,{"DX7_MAISB"  ,STR0035 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DXL_FAZ"   );AAdd(aCampos,{"DXL_FAZ"    ,STR0036 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DXL_TALHAO");AAdd(aCampos,{"DXL_TALHAO" ,STR0037 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DXL_DESCVR");AAdd(aCampos,{"DXL_DESCVR" ,STR0038 ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
	Else

		aTamCmps := TamSX3("DXI_ETIQ"  );AAdd(aCampos,{"DXI_ETIQ"   ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_ATIVO" );AAdd(aCampos,{"DX7_ATIVO"  ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DXI_CODIGO");AAdd(aCampos,{"DXI_CODIGO" ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DXI_CODRES");AAdd(aCampos,{"DXI_CODRES" ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := {11   ,0    ,"C"   };AAdd(aCampos,{"TMP_STATUS" ,"C"        ,11         ,0          ,""})

		aTamCmps := TamSX3("DXK_CLAVIS");AAdd(aCampos,{"DXK_CLAVIS" ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DXK_CLACON");AAdd(aCampos,{"DXK_CLACON" ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DXI_CLACOM");AAdd(aCampos,{"DXI_CLACOM" ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DXK_TIPCON");AAdd(aCampos,{"DXK_TIPCON" ,aTamCmps[3], 6,aTamCmps[2],""})		
		
		aTamCmps := TamSX3("DXI_ROMSAI");AAdd(aCampos,{"DXI_ROMSAI" ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_MIC"   );AAdd(aCampos,{"DX7_MIC"    ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_RES"   );AAdd(aCampos,{"DX7_RES"    ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_FIBRA" );AAdd(aCampos,{"DX7_FIBRA"  ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})

		aTamCmps := TamSX3("DX7_UI"    );AAdd(aCampos,{"DX7_UI"     ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_SFI"   );AAdd(aCampos,{"DX7_SFI"    ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_ELONG" );AAdd(aCampos,{"DX7_ELONG"  ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_LEAF"  );AAdd(aCampos,{"DX7_LEAF"   ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_AREA"  );AAdd(aCampos,{"DX7_AREA"   ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_CSP"   );AAdd(aCampos,{"DX7_CSP"    ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_SCI"   );AAdd(aCampos,{"DX7_SCI"    ,aTamCmps[3],aTamCmps[1],aTamCmps[2],PesqPict("DX7","DX7_SCI")})

		aTamCmps := TamSX3("DX7_CG"    );AAdd(aCampos,{"DX7_CG"     ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_RD"    );AAdd(aCampos,{"DX7_RD"     ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_COUNT" );AAdd(aCampos,{"DX7_COUNT"  ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_UHM"   );AAdd(aCampos,{"DX7_UHM"    ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DX7_MATU"  );AAdd(aCampos,{"DX7_MATU"   ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})

		aTamCmps := TamSX3("DX7_MAISB" );AAdd(aCampos,{"DX7_MAISB"  ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DXL_FAZ"   );AAdd(aCampos,{"DXL_FAZ"    ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DXL_TALHAO");AAdd(aCampos,{"DXL_TALHAO" ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
		aTamCmps := TamSX3("DXL_DESCVR");AAdd(aCampos,{"DXL_DESCVR" ,aTamCmps[3],aTamCmps[1],aTamCmps[2],""})
	EndIf
Return aCampos