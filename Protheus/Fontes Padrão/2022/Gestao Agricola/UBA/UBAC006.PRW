#INCLUDE "ubac006.ch"
#INCLUDE "protheus.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "totvs.ch"

Static oArqTemp := Nil

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} UBAC006
Consulta Geral de Fardos

@param: Nil
@author: Cleber Maldonado
@since: 11/09/2012
@Uso: UBA
/*/
// -------------------------------------------------------------------------------------
Function UBAC006()
	Local oColumn   := Nil
	Local oDlg      := Nil
	Local aRet		:= {}
	Local aCoors	:= FWGetDialogSize( oMainWnd )
	Local bKeyF12	:= {|| If( Pergunte("UBAC006", .T.), ( cAliasTRB := UBAC006TRB()[1], oBrowse:SetAlias(cAliasTRB) , oBrowse:Refresh()), .T. ) }
	Private cAliasTRB := ""               
	Private nQtdReg := 0
	Private aTotais := {0,0}
	Private oBrowse	:= Nil
	SetKey( VK_F12, bKeyF12)

	If !Pergunte("UBAC006",.T.)
		Return
	EndIf

	Count to nQtdReg
	Processa({||aRet := UBAC006TRB()})
	cAliasTRB 	:= aRet[1] // Arquivo temporario
	aArqTemp 	:= aRet[2] // Estrutura do arquivo temporario

	If Select(cAliasTRB) > 0

		(cAliasTRB)->(DbSetOrder(1))                                
		//- Coordenadas da area total da Dialog
		oSize := FWDefSize():New(.T.)
		oSize:AddObject('DLG',100,100,.T.,.T.)    
		oSize:SetWindowSize(aCoors)
		oSize:lProp 	:= .T.      
		oSize:Process()
		DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] OF oMainWnd PIXEL	
		//	Instancia o layer
		oFWL := FWLayer():New()

		// Inicia o Layer
		oFWL:init(oDlg,.F.)

		// Cria uma linha unica para o Layer
		oFWL:addLine('SUP',85,.F.)
		oFWL:addLine('INF',15,.F.)

		// Cria colunas 
		oFWL:addCollumn('COL', 100, .T., 'INF')

		// Cria Janela
		oFWL:addWindow('COL','Wnd1',' ',100,.F.,.T.,,'INF')  

		oPnlCol  := oFWL:getLinePanel('SUP')
		oPnlWnd1 := oFWL:getWinPanel('COL','Wnd1','INF')

		//-------------------------------------------------------------------
		// Define o Browse
		//-------------------------------------------------------------------
		DEFINE FWFORMBROWSE oBrowse DATA TABLE ALIAS cAliasTRB DESCRIPTION STR0001 OF oPnlCol  //"Consulta Geral de Fardos"

		cCostelado     := "AGRTxtBox(&(aArqTemp[6,1]), 'DXI_COSTEL')" //costelado

		oBrowse:SetTemporary(.T.)
		oBrowse:SetFieldFilter(CriaArray())
		oBrowse:SetdbFFilter(.T.)
		oBrowse:SetUseFilter(.T.)
		oBrowse:DisableDetails()
		oBrowse:SetProfileID('1')		
		// Adiciona colunas do browse
		oBrowse:AddButton("Sair",{||oDlg:End()},,,,,,'10')
		ADD COLUMN oColumn DATA { || &(aArqTemp[1,1]) } TITLE STR0002						  SIZE aArqTemp[1,3]   	;
		PICTURE PesqPict("DXI","DXI_CODIGO")	TYPE TamSX3("DXI_CODIGO")[3]		OF oBrowse //"Numero do Fardo"
		ADD COLUMN oColumn DATA { || &(aArqTemp[2,1]) } TITLE STR0003						  SIZE aArqTemp[2,3]   	;
		PICTURE PesqPict("DXI","DXI_PSLIQU") 	TYPE TamSX3("DXI_PSLIQU")[3]		OF oBrowse //"Peso"
		ADD COLUMN oColumn DATA { || &(aArqTemp[3,1]) } TITLE STR0004						  SIZE aArqTemp[3,3]   	;
		PICTURE PesqPict("DXI","DXI_PRDTOR") 	TYPE TamSX3("DXI_PRDTOR")[3]		OF oBrowse //"Produtor"
		ADD COLUMN oColumn DATA { || &(aArqTemp[4,1]) } TITLE STR0017 						  SIZE aArqTemp[4,3]	  	;
		PICTURE PesqPict("NN2","NN2_CODIGO") 	TYPE TamSX3("NN2_CODIGO")[3]		OF oBrowse //"Fazenda"
		ADD COLUMN oColumn DATA { || &(aArqTemp[5,1]) } TITLE STR0005						  SIZE aArqTemp[5,3]   	;
		PICTURE PesqPict("DXI","DXI_PRENSA") 	TYPE TamSX3("DXI_PRENSA")[3]		OF oBrowse //"Maquina"
		ADD COLUMN oColumn DATA { || &(cCostelado)    } TITLE AGRTITULO("DXI_COSTEL")	  SIZE aArqTemp[6,3]   	;
		PICTURE PesqPict("DXI","DXI_COSTEL") 	TYPE TamSX3("DXI_COSTEL")[3]		OF oBrowse //"Maquina"
		ADD COLUMN oColumn DATA { || &(aArqTemp[7,1]) } TITLE AGRTITULO("DXI_DATA")        SIZE aArqTemp[7,3] 	;
		PICTURE PesqPict("DXI","DXI_DATA")	 	TYPE TamSX3("DXI_DATA")[3]			OF oBrowse //"Data "
		ADD COLUMN oColumn DATA { || &(aArqTemp[19,1])} TITLE AGRTITULO("DXI_HORA")  	  SIZE aArqTemp[19,3]  	;
		PICTURE PesqPict("DXI","DXI_HORA")	 	TYPE TamSX3("DXI_HORA")[3]			OF oBrowse //"HORA
		ADD COLUMN oColumn DATA { || &(aArqTemp[18,1])} TITLE AGRTITULO("DXL_DTBEN")  	  SIZE aArqTemp[18,3]  	;
		PICTURE PesqPict("DXL","DXL_DTBEN") 	TYPE TamSX3("DXL_DTBEN")[3]			OF oBrowse //"Data Benef."			
		ADD COLUMN oColumn DATA { || &(aArqTemp[8,1]) } TITLE STR0007						  SIZE aArqTemp[8,3]   	;
		PICTURE PesqPict("DXL","DXL_TALHAO") 	TYPE TamSX3("DXL_TALHAO")[3]		OF oBrowse //"Talhão"
		ADD COLUMN oColumn DATA { || &(aArqTemp[9,1]) } TITLE STR0008						  SIZE aArqTemp[9,3]   	;
		PICTURE PesqPict("DXL","DXL_CODIGO") 	TYPE TamSX3("DXL_CODIGO")[3]		OF oBrowse //"Fardão"
		ADD COLUMN oColumn DATA { || &(aArqTemp[10,1])} TITLE STR0009						  SIZE aArqTemp[10,3]  	;
		PICTURE PesqPict("DXD","DXD_CODIGO") 	TYPE TamSX3("DXD_CODIGO")[3]		OF oBrowse //"Bloco"
		ADD COLUMN oColumn DATA { || &(aArqTemp[11,1])} TITLE STR0010						  SIZE aArqTemp[11,3]  	;
		PICTURE PesqPict("SF2","F2_DOC")	  	TYPE TamSX3("F2_DOC")[3]				OF oBrowse //"Nota Fiscal"
		ADD COLUMN oColumn DATA { || &(aArqTemp[12,1])} TITLE STR0011						  SIZE aArqTemp[12,3]  	;
		PICTURE PesqPict("DXI","DXI_DATA")	 	TYPE TamSX3("DXI_DATA")[3]			OF oBrowse //"Data de Saída"
		ADD COLUMN oColumn DATA { || &(aArqTemp[13,1])} TITLE STR0012						  SIZE aArqTemp[13,3]  	;
		PICTURE PesqPict("ADA","ADA_NUMCTR") 	TYPE TamSX3("ADA_NUMCTR")[3]		OF oBrowse //"Contrato"
		ADD COLUMN oColumn DATA { || &(aArqTemp[14,1])} TITLE AGRTITULO("DXI_CLAVIS") 	  SIZE aArqTemp[14,3]  	;
		PICTURE PesqPict("DXI","DXI_CLAVIS") 	TYPE TamSX3("DXI_CLAVIS")[3]		OF oBrowse //"Classificação Visual"
		ADD COLUMN oColumn DATA { || &(aArqTemp[15,1])} TITLE AGRTITULO("DXI_CLACOM") 	  SIZE aArqTemp[14,3]  	;
		PICTURE PesqPict("DXI","DXI_CLACOM") 	TYPE TamSX3("DXI_CLACOM")[3]		OF oBrowse //"Classificação Comercial"
		ADD COLUMN oColumn DATA { || &(aArqTemp[16,1])} TITLE STR0016 						  SIZE aArqTemp[15,3]  	;
		PICTURE PesqPict("SA1","A1_COD") 	 	TYPE TamSX3("A1_COD")[3]				OF oBrowse //"Cliente Destino"
		ADD COLUMN oColumn DATA { || &(aArqTemp[17,1])} TITLE AGRTITULO("DXI_CODTUR")      SIZE aArqTemp[16,3]  	;
		PICTURE PesqPict("DXI","DXI_CODTUR") 	TYPE TamSX3("DXI_CODTUR")[3]		OF oBrowse //"Turno"
		ADD COLUMN oColumn DATA { || &(aArqTemp[20,1])} TITLE STR0064					   SIZE aArqTemp[19,3]  	;
		PICTURE PesqPict("DXI","DXI_ETIQ")	  	TYPE TamSX3("DXI_ETIQ")[3]			OF oBrowse //"Etiqueta"
		ADD COLUMN oColumn DATA { || &(aArqTemp[21,1])} TITLE STR0069					   SIZE aArqTemp[20,3]  	;
		PICTURE PesqPict("DXJ","DXJ_CODIGO")	TYPE TamSX3("DXJ_CODIGO")[3]		OF oBrowse //"Rom Clas"
		ADD COLUMN oColumn DATA { || &(aArqTemp[22,1])} TITLE STR0070	        		   SIZE aArqTemp[21,3]  	;
		PICTURE PesqPict("DXJ","DXJ_CODIGO")	TYPE TamSX3("DXJ_CODIGO")[3]		OF oBrowse //"Tipo Rom Clas"
		ADD COLUMN oColumn DATA { || &(aArqTemp[23,1])} TITLE STR0071					   SIZE aArqTemp[22,3]  	;
		PICTURE PesqPict("DXP","DXP_CODIGO")	TYPE TamSX3("DXP_CODIGO")[3]		OF oBrowse //"Reserva"
		ADD COLUMN oColumn DATA { || &(aArqTemp[24,1])} TITLE STR0072					   SIZE aArqTemp[23,3]  	;
		PICTURE PesqPict("DXT","DXT_NUMIE")	TYPE TamSX3("DXT_NUMIE")[3]		OF oBrowse //"Instr. Embarque"
		ADD COLUMN oColumn DATA { || &(aArqTemp[25,1])} TITLE STR0074					   SIZE aArqTemp[25,3]  	;
		PICTURE PesqPict("DXI","DXI_CODVAR")	TYPE TamSX3("DXI_CODVAR")[3]		OF oBrowse //"Variedade"
		ADD COLUMN oColumn DATA { || &(aArqTemp[26,1])} TITLE STR0075					   SIZE aArqTemp[26,3]  	;
		PICTURE PesqPict("NNV","NNV_DESCRI")	TYPE TamSX3("NNV_DESCRI")[3]		OF oBrowse //"Descrição"
		

		@ 0,233 SAY STR0020 SIZE 60, 7 PIXEL OF oPnlWnd1  //"Total Fardos"
		@ 0,275 MSGET oTotLona VAR aTotais[1] SIZE (10*4), 10 WHEN .F. PICTURE "@E 9999999999" PIXEL OF oPnlWnd1 

		@ 0,370 SAY STR0021 SIZE 60, 7 PIXEL OF oPnlWnd1 //"Peso Fardos"
		@ 0,425 MSGET oTotLiqu VAR aTotais[2] SIZE (TamSX3("DXM_PSLIQU")[1]*4), 10 WHEN .F. PICTURE PesqPict("DXM","DXM_PSLIQU") PIXEL OF oPnlWnd1

		//-------------------------------------------------------------------
		// Ativação do Browse
		//-------------------------------------------------------------------
		ACTIVATE FWFORMBROWSE oBrowse

		ACTIVATE MSDIALOG oDlg CENTER

		(cAliasTRB)->(DbCloseArea())
	EndIf	

	SetKey( VK_F12, Nil)
	//Elimina a tabela temporária, se houver
	AGRDLTPTB(oArqTemp)


Return

Static Function CriaArray()
	Local aCampos := {}
	Local aCmpsTam := {}

	aCmpsTam := TamSX3("DXI_CODIGO");AAdd(aCampos,{"FARDO"     ,STR0063    ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("DXI_PSLIQU");AAdd(aCampos,{"PESO"      ,STR0062     ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("DXI_PRDTOR");AAdd(aCampos,{"PRODUTOR"  ,STR0061 ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("NN2_CODIGO");AAdd(aCampos,{"FAZ"       ,STR0060     ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("DXI_PRENSA");AAdd(aCampos,{"MAQUINA"   ,STR0059  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("DXI_COSTEL");AAdd(aCampos,{"COSTELADO" ,STR0058  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := {8  ,0  ,"D"       };AAdd(aCampos,{"DAT_BENEF" ,AGRTITULO("DXI_DATA"),aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("NN3_TALHAO");AAdd(aCampos,{"TALHAO"    ,STR0057   ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("DXL_CODIGO");AAdd(aCampos,{"FARDAO"    ,STR0056   ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("DXD_CODIGO");AAdd(aCampos,{"BLOCO"     ,STR0055    ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("F2_DOC"    );AAdd(aCampos,{"NF"        ,STR0054       ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := {8  ,0  ,"D"       };AAdd(aCampos,{"DT_SAIDA"  ,AGRTITULO("DXS_DATA") ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("ADA_NUMCTR");AAdd(aCampos,{"CONTRATO"  ,STR0053 ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("DXI_CLAVIS");AAdd(aCampos,{"DXI_CLAVIS",AGRTITULO("DXI_CLAVIS"),aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("DXI_CLACOM");AAdd(aCampos,{"DXI_CLACOM",AGRTITULO("DXI_CLACOM"),aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("A1_COD"    );AAdd(aCampos,{"CLIENTE"   ,STR0052  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("DXI_CODTUR");AAdd(aCampos,{"TURNO"     ,STR0051  ,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("DXL_DTBEN" );AAdd(aCampos,{"DXL_DTBEN" ,AGRTITULO("DXL_DTBEN"),aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})	
	aCmpsTam := TamSX3("DXI_HORA"  );AAdd(aCampos,{"DXI_HORA"  ,AGRTITULO("DXI_HORA"),aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("DXI_ETIQ"  );AAdd(aCampos,{"DXI_ETIQ"  ,STR0050,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("DXJ_CODIGO");AAdd(aCampos,{"ROMCLAV"   ,STR0065,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("DXJ_CODIGO");AAdd(aCampos,{"ROMCLAH"   ,STR0066,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("DXP_CODIGO");AAdd(aCampos,{"DXP_CODIGO",STR0067,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("DXT_NUMIE" );AAdd(aCampos,{"DXT_NUMIE" ,STR0068,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""})
	aCmpsTam := TamSX3("DXI_CODVAR");AAdd(aCampos,{"DXI_CODVAR",STR0074,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) //"Variedade"
	aCmpsTam := TamSX3("NNV_DESCRI");AAdd(aCampos,{"NNV_DESCRI",STR0075,aCmpsTam[3],aCmpsTam[1],aCmpsTam[2],""}) //"Descrição"


Return aCampos

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} UBAC006TRB
Cria arquivo de trabalho com dados para exibição da consulta

@param: Nil
@author: Cleber Maldonado
@since: 23/07/2013
@Uso: UBA
/*/
// -------------------------------------------------------------------------------------

Function UBAC006TRB()
	Local aArqTemp 	:= {} 
	Local aIndex    := {}
	Local cAlias	:= ""
	Local cArqTemp	:= ""
	Local cJoinDXP  := ""
	Local cJoinDXS  := ""
	Local aCmpsTab  := {}

	If (!Empty(cAliasTRB)) .AND. (Select(cAliasTRB) > 0)
		(cAliasTRB)->(dbCloseArea())
	EndIf	

	// Cria arquivo de trabalho
	aCmpsTab := TamSX3("DXI_CODIGO");AADD(aArqTemp,{"FARDO"		  ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXI_PSLIQU");AADD(aArqTemp,{"PESO"		  ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXI_PRDTOR");AADD(aArqTemp,{"PRODUTOR"  ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("NN2_CODIGO");AADD(aArqTemp,{"FAZ"		  ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXI_PRENSA");AADD(aArqTemp,{"MAQUINA"	  ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXI_COSTEL");AADD(aArqTemp,{"COSTELADO" ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := {8     ,0     , "D"};AADD(aArqTemp,{"DAT_BENEF" ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("NN3_TALHAO");AADD(aArqTemp,{"TALHAO"	  ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXL_CODIGO");AADD(aArqTemp,{"FARDAO"	  ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXD_CODIGO");AADD(aArqTemp,{"BLOCO"		  ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("F2_DOC"    );AADD(aArqTemp,{"NF"			  ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := {8     ,0     , "D"};AADD(aArqTemp,{"DT_SAIDA"  ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("ADA_NUMCTR");AADD(aArqTemp,{"CONTRATO"	,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXI_CLAVIS");AADD(aArqTemp,{"DXI_CLAVIS"	,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXI_CLACOM");AADD(aArqTemp,{"DXI_CLACOM"	,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("A1_COD"    );AADD(aArqTemp,{"CLIENTE"		,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXI_CODTUR");AADD(aArqTemp,{"TURNO"			,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXL_DTBEN") ;AADD(aArqTemp,{"DXL_DTBEN" ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXI_HORA")  ;AADD(aArqTemp,{"DXI_HORA" ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXI_ETIQ")  ;AADD(aArqTemp,{"DXI_ETIQ" ,aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXJ_CODIGO");AADD(aArqTemp,{"ROMCLAV",aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXJ_CODIGO");AADD(aArqTemp,{"ROMCLAH",aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXP_CODIGO");AADD(aArqTemp,{"DXP_CODIGO",aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXT_NUMIE") ;AADD(aArqTemp,{"DXT_NUMIE",aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXI_CODVAR");AADD(aArqTemp,{"DXI_CODVAR",aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("NNV_DESCRI");AADD(aArqTemp,{"NNV_DESCRI",aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	cArqTemp := GetNextAlias()
	aAdd(aIndex, {"", "FARDO,PRODUTOR"})
	aAdd(aIndex, {"", "PRODUTOR,FARDO"})
	aAdd(aIndex, {"", "CLIENTE,FARDO"})
	oArqTemp := AGRCRTPTB(cArqTemp, {aArqTemp, aIndex })
	cAliasTRB := cArqTemp	

	cAlias := GetNextAlias()
	cQry := " SELECT DXI_CODIGO,DXI_PSLIQU,DXI_PRDTOR,DXI_PRENSA,DXI_DATA,DXI_FARDAO,DXI_BLOCO,DXI_CLAVIS, " 
	cQry += "DXI_CLACOM,ISNULL(DXS_NUMNFS,'') DXS_NUMNFS,"+;
	"ISNULL(DXS_DATA,'') DXS_DATA , ISNULL(DXS_CODCTP,'') DXS_CODCTP , ISNULL(DXS_CLIENT,'') DXS_CLIENT ,"
	cQry += "DXL_FAZ,DXL_TALHAO,DXI_CODTUR,DXI_COSTEL,DXL_DTBEN,DXI_HORA,DXI_ETIQ,"+;
	"ISNULL(DXP_CODIGO,'') DXP_CODIGO, ISNULL(DXT_NUMIE,'') DXT_NUMIE ," 
	cQry += " NVL((select DXJ.DXJ_CODIGO " 
	cQry += " from "  +RetSqlName("DXK") +" DXK "   
	cQry += " LEFT JOIN " + RetSqlName("DXJ") + " DXJ ON DXJ.D_E_L_E_T_ =  ' ' "
	cQry += "  AND DXJ.DXJ_FILIAL  = DXK.DXK_FILIAL "
	cQry += "  AND DXJ.DXJ_CODIGO  = DXK.DXK_CODROM "
	cQry += "  AND DXJ.DXJ_SAFRA   = DXK.DXK_SAFRA  "
	
	If DXK->(ColumnPos( 'DXK_TIPO' )) > 0 
		cQry += "  AND DXJ.DXJ_TIPO    = DXK.DXK_TIPO  "
	endIf
	
	cQry += " where DXJ.DXJ_TIPO  = '1'   AND DXK.D_E_L_E_T_ =  ' ' " 
	cQry += "   AND DXK.DXK_FILIAL    = DXI.DXI_FILIAL "
	cQry += "   AND DXK.DXK_SAFRA     = DXI.DXI_SAFRA  "
	cQry += "  AND DXK.DXK_ETIQ      = DXI.DXI_ETIQ "
	cQry += " ),'') AS ROMCLAV, "
	cQry += " NVL((select DXJ.DXJ_CODIGO " 
	cQry += " from "  +RetSqlName("DXK") +" DXK "   
	cQry += " LEFT JOIN " + RetSqlName("DXJ") + " DXJ ON DXJ.D_E_L_E_T_ =  ' ' "
	cQry += "  AND DXJ.DXJ_FILIAL  = DXK.DXK_FILIAL "
	cQry += "  AND DXJ.DXJ_CODIGO  = DXK.DXK_CODROM "
	cQry += "  AND DXJ.DXJ_SAFRA   = DXK.DXK_SAFRA  "
	
	If DXK->(ColumnPos( 'DXK_TIPO' )) > 0 
		cQry += "  AND DXJ.DXJ_TIPO    = DXK.DXK_TIPO  "
	endIf
	
	cQry += " where DXJ.DXJ_TIPO  = '2'   AND DXK.D_E_L_E_T_ =  ' ' "
	cQry += "   AND DXK.DXK_FILIAL    = DXI.DXI_FILIAL "
	cQry += "   AND DXK.DXK_SAFRA     = DXI.DXI_SAFRA  "
	cQry += "   AND DXK.DXK_ETIQ      = DXI.DXI_ETIQ   "
	cQry += " ),' ') AS ROMCLAH, "
	cQry += " DXI_CODVAR, ISNULL(NNV_DESCRI,'') NNV_DESCRI  "	
	cQry += " FROM " +RetSqlName("DXI")+ " DXI "
	cQry += " INNER JOIN " +RetSqlName("DXL")+ " DXL ON DXL.D_E_L_E_T_  = ' '"
	cQry += " AND DXL.DXL_SAFRA = DXI.DXI_SAFRA AND DXL.DXL_CODIGO = DXI.DXI_FARDAO AND DXL.DXL_PRDTOR = DXI.DXI_PRDTOR AND DXI.DXI_LJPRO = DXL.DXL_LJPRO"
	cQry += " AND DXI.DXI_FAZ = DXL.DXL_FAZ"

	If !Empty(ALLTRIM(MV_PAR16)) // Nota Fiscal de Saída
		cJoinDXS  := "S"
		cQry += " LEFT JOIN "+RetSqlName("DXS")+" DXS ON DXS.D_E_L_E_T_ = ' ' AND " 
		cQry += " DXS.DXS_FILIAL = '"+xFilial("DXS")+"' AND DXS.DXS_CODIGO = DXI.DXI_ROMSAI"
		cQry += " AND DXS.DXS_NUMNFS = '"+MV_PAR16+"'"
		cQry += " LEFT JOIN " + RetSqlName("DXT") + " DXT ON DXT.D_E_L_E_T_ = ' ' AND "
		cQry += " DXT.DXT_FILIAL = '"+xFilial("DXT")+"' AND DXT.DXT_CODIGO = DXI.DXI_ROMSAI"  	
		cQry += " AND DXT.DXT_BLOCO = DXI.DXI_BLOCO "
		cQry += " AND DXT.DXT_ITEM  = DXI.DXI_ITROMS "
	EndIf	
    
    If !Empty(ALLTRIM(MV_PAR21)) .AND. !Empty(ALLTRIM(MV_PAR22)) //Cliente
		cJoinDXP  := "S"
		cQry += " LEFT JOIN "+RetSqlName("DXP")+" DXP ON DXP.D_E_L_E_T_ = ' ' AND " 
		cQry += " DXP.DXP_FILIAL = '"+xFilial("DXP")+"' AND DXP.DXP_CODIGO = DXI.DXI_CODRES"
		cQry += " AND DXP.DXP_CLIENT = '"+MV_PAR21+"' AND DXP.DXP_LJCLI = '"+MV_PAR22+"'"	
	EndIf		

	If Empty(cJoinDXP)
		cQry += " LEFT JOIN "+RetSqlName("DXP")+" DXP ON DXP.D_E_L_E_T_ = ' ' AND " 
		cQry += " DXP.DXP_FILIAL = '"+xFilial("DXP")+"' AND"
		cQry += " DXP.DXP_CODIGO = DXI.DXI_CODRES"
	EndIf

	If Empty(cJoinDXS)
		cQry += " LEFT JOIN "+RetSqlName("DXS")+" DXS ON DXS.D_E_L_E_T_ = ' ' AND " 
		cQry += " DXS.DXS_FILIAL = '"+xFilial("DXS")+"' AND"
		cQry += " DXS.DXS_CODIGO = DXI.DXI_ROMSAI"
		cQry += " LEFT JOIN " + RetSqlName("DXT") + " DXT ON DXT.D_E_L_E_T_ = ' ' AND "
		cQry += " DXT.DXT_FILIAL = '"+xFilial("DXT")+"' AND DXT.DXT_CODIGO = DXI.DXI_ROMSAI"
		cQry += " AND DXT.DXT_BLOCO = DXI.DXI_BLOCO "
		cQry += " AND DXT.DXT_ITEM  = DXI.DXI_ITROMS "

	EndIf

	cQry += " LEFT JOIN "+RetSqlName("NNV")+" NNV ON NNV.D_E_L_E_T_ = ' ' AND " 
	cQry += " NNV.NNV_FILIAL = '"+xFilial("NNV")+"' AND"
	cQry += " NNV.NNV_CODPRO = DXL.DXL_CODPRO "+" AND"
	cQry += " NNV.NNV_CODIGO = DXI.DXI_CODVAR "

	//Filtra por filial
	cQry += " WHERE DXI_FILIAL = '"+xFilial("DXI")+"'" 
	cQry += " AND DXL_FILIAL = '"+xFilial("DXL")+"'"
	
	If !Empty(MV_PAR29)  
		cQry += " AND DXI_CODUNB = '" + MV_PAR29 + "'"
	EndIf		

	cQry += " AND DXI.D_E_L_E_T_ = ' '"
	
	If !Empty(ALLTRIM(MV_PAR01))
		cQry += " AND DXI.DXI_SAFRA = '" +MV_PAR01+"'"
	EndIf
    
    If !Empty(ALLTRIM(MV_PAR02)) //Produto
		cQry += " AND DXL.DXL_CODPRO = '" + MV_PAR02 + "' "
	EndIf	
	
	If !Empty(ALLTRIM(MV_PAR03)) .and. !Empty(ALLTRIM(MV_PAR04)) //Produtor
		cQry += " AND DXI.DXI_PRDTOR = '" + MV_PAR03 + "'" + " AND DXI.DXI_LJPRO = '" + MV_PAR04 + "'"
	EndIf	
    
    If !Empty(ALLTRIM(MV_PAR05)) //Fazenda
		cQry += " AND DXI.DXI_FAZ = '" + MV_PAR05 + "'"
	EndIf	
	
	If !Empty(ALLTRIM(DtoS(MV_PAR07))) .and. !Empty(ALLTRIM(DtoS(MV_PAR08))) // Data de - Data Até
		cQry += " AND DXL.DXL_DTBEN BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"'" 	
	EndIf	
	
	If !Empty(ALLTRIM(MV_PAR09)) //Turno 
		cQry += " AND DXL.DXL_CODTUR = '"+MV_PAR09+"'"
	EndIf	

	If !Empty(ALLTRIM(MV_PAR10)) //Fardao 
		cQry += " AND DXI.DXI_FARDAO = '"+MV_PAR10+"'"
	EndIf	
	
	If !Empty(ALLTRIM(MV_PAR11))// Bloco
		cQry += " AND DXI.DXI_BLOCO = '"+MV_PAR11+"'" 
	EndIf		
	
	If !Empty(ALLTRIM(MV_PAR12))// Talhao
		cQry += " AND DXL.DXL_TALHAO = '"+MV_PAR12+"'"
	EndIf		
	
	If !Empty(ALLTRIM(MV_PAR13)) //Prensa
		cQry += " AND DXI.DXI_PRENSA = '"+MV_PAR13+"'"
	EndIf	

	If !Empty(ALLTRIM(MV_PAR14)) .AND. !Empty(ALLTRIM(MV_PAR15)) // Laboratorio
		cQry += " and DXI_ETIQ IN (SELECT DX7_ETIQ FROM "+RetSqlName("DX7")+" DX7"
		cQry += " WHERE DX7.DX7_FILIAL = '"+xFilial("DX7")+"' AND DX7_ATIVO = '1'"
		cQry += " AND DX7.DX7_LAB = '"+MV_PAR14+"' AND DX7.DX7_UNI = '"+MV_PAR15+"'"
		cQry += " AND DX7.DX7_SAFRA = DXI.DXI_SAFRA "
		cQry += " AND DX7.D_E_L_E_T_ = ' '  )"
	EndIf
	
	If !Empty(ALLTRIM(MV_PAR17)) //Classificação visual 
		cQry += " AND DXI.DXI_CLAVIS = '"+MV_PAR17+"'"
	EndIf	

	If !Empty(ALLTRIM(MV_PAR18)) //Classificação Comercial 
		cQry += " AND DXI.DXI_CLACOM = '"+MV_PAR18+"'"
	EndIf
	
	If !Empty(ALLTRIM(MV_PAR19)) .and. !Empty(ALLTRIM(MV_PAR20))
		cQry += " AND DXI.DXI_CODIGO BETWEEN '"+MV_PAR19+"' AND '"+MV_PAR20+"'" // Fardo de - Fardo Até
	EndIf		

	If 	MV_PAR23 = 1 			//Costelado
		cQry += " AND DXI.DXI_COSTEL = '2'"
	ElseIf	MV_PAR23 = 2 			//Costelado 
		cQry += " AND DXI.DXI_COSTEL = '1'"	
	EndIf

	If 	MV_PAR24 = 1 			//Class. Visual
		cQry += " AND DXI.DXI_CLAVIS <> ''"
	ElseIf	MV_PAR24 = 2 			//Class. Visual
		cQry += " AND DXI.DXI_CLAVIS = ''"	
	EndIf

	If 	MV_PAR25 = 1 // Class. HVI
		cQry += " and DXI_ETIQ IN (SELECT DX7_ETIQ FROM "+RetSqlName("DX7")+" DX7"
		cQry += " WHERE DX7.DX7_FILIAL = '"+xFilial("DX7")+"' AND DX7_ATIVO = '1'"
		cQry += " AND DX7.DX7_SAFRA = DXI.DXI_SAFRA "
		cQry += " AND DX7.D_E_L_E_T_ = ' '  )"
	ElseIf	MV_PAR25 = 2 // Class. HVI
		cQry += " and DXI_ETIQ NOT IN (SELECT DX7_ETIQ FROM "+RetSqlName("DX7")+" DX7"
		cQry += " WHERE DX7.DX7_FILIAL = '"+xFilial("DX7")+"' AND DX7_ATIVO = '1'"
		cQry += " AND DX7.DX7_SAFRA = DXI.DXI_SAFRA "
		cQry += " AND DX7.D_E_L_E_T_ = ' '  )"
	EndIf	
	
	If 	MV_PAR26 = 1 			//Blocados
		cQry += " AND DXI_BLOCO <> ''"
	ElseIf	MV_PAR26 = 2 			//Blocados
		cQry += " AND DXI_BLOCO = ''"	
	EndIf		
	
	If MV_PAR27 = 1 			//Reservados
		cQry += " AND DXI_CODRES <> ''"
	ElseIf	MV_PAR27 = 2 			//Reservados
		cQry += " AND DXI_CODRES = ''"	
	EndIf

	If MV_PAR28 = 1 			//Embarcados
		cQry += " AND DXI_ROMSAI <> ''"
	ElseIf	MV_PAR28 = 2 			//Embarcados
		cQry += " AND DXI_ROMSAI = ''"	
	EndIf		
	
	If !Empty(ALLTRIM(MV_PAR06)) //Contrato
		cQry += " AND DXP_CODCTP = '"+MV_PAR06+"'"
	EndIf
		
	cQry += '  Order by DXI_CODIGO '
	cQry := ChangeQuery(cQry)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cAlias,.F.,.T.) 

	//Campos da tabela
		cCamposIns := " FARDO,PESO,PRODUTOR,MAQUINA,DAT_BENEF,FARDAO,BLOCO,"+;
	"DXI_CLAVIS,DXI_CLACOM,NF,DT_SAIDA,CONTRATO,CLIENTE,FAZ,TALHAO,TURNO,"+;
	"COSTELADO,DXL_DTBEN,DXI_HORA,DXI_ETIQ,DXP_CODIGO,DXT_NUMIE,ROMCLAV,ROMCLAH,DXI_CODVAR,NNV_DESCRI" 

	//Insert na tabela temporaria
	cInst := "INSERT INTO " + oArqTemp:GetRealName() + " (" + cCamposIns + " ) " + cQry 
	nStatus = TCSQLExec(cInst)

	//Validação de erro no insert. 
	if (nStatus < 0)
    	msgalert("TCSQLError() " + TCSQLError())
    endif

	//Select na Tabela temporaria populada
	_cTabCtr := GetSqlAll("SELECT COUNT(DXI_ETIQ) REGS, SUM(PESO) PLIQ FROM "+oArqTemp:GetRealName())

	//Atualização dos totais.
	aTotais[1] := (_cTabCtr)->REGS
	aTotais[2] := (_cTabCtr)->PLIQ

	(_cTabCtr)->(DbGoTop())
	(_cTabCtr)->(dbCloseArea())
	
	(cAliasTRB)->(dbGoTop())
 
Return({cAliasTRB, aArqTemp})
