#INCLUDE "UBAC012.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"
#include "fwbrowse.ch"

Static oArqTemp := Nil

/*/{Protheus.doc} UBAC012
//Consulta Status Consolidado Fardão
@author marina.muller
@since 17/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function UBAC012()
	Local oDLg      := Nil
	Local oSize     := Nil
	Local aCoors    := FWGetDialogSize( oMainWnd )
	Local cStatFard := ""
	Local aCampos   := {}
	Local aRet      := {}

	// Variaveis dos totalizadores
	Local oQtdFard 	:= Nil
	Local oPesoTot 	:= Nil
	Local oPesoEst 	:= Nil	
	
	Private cAliasTRB := ""	
	Private nQtdl  		:= 0
	Private cAlias 		:= ""
	Private aArqTemp  	:= {}
	Private oBrwSuper
	Private aTotais 	:= {0,0,0}
	
	aRet := CRIATRB("TRBDXL",@aTotais)
	cAliasTRB := aRet[1]
	aArqTemp  := aRet[2]
	
	//Coordenadas da area total da Dialog
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
	oFWL:addWindow('COL','Wnd1',STR0002,100,.F.,.T.,,'INF')  //"Totais"
    
	oPnlCol  := oFWL:getLinePanel('SUP')
	oPnlWnd1 := oFWL:getWinPanel('COL','Wnd1','INF')
	
	//-------------------------------------------------------------------
	// Define o Browse
	//-------------------------------------------------------------------
	DEFINE FWFORMBROWSE oBrwSuper DATA TABLE ALIAS (cAliasTRB) DESCRIPTION STR0001 OF oPnlCol //"Status Consolidado Fardão"
	aCampos := CmpFiltro(@aArqTemp)
	oBrwSuper:SetTemporary(.T.)
	oBrwSuper:DisableDetails()
	oBrwSuper:SetFieldFilter(aCampos)
	oBrwSuper:SetdbFFilter(.T.)
	oBrwSuper:SetUseFilter(.T.)
	oBrwSuper:SetProfileID('1')
	oBrwSuper:BVLDEXECFILTER := {|| UBAC012RT()}
	oBrwSuper:AddButton(STR0003,{|| oDlg:End()},,,,,,'10') //"Sair"
	
	cStatFard := "AGRTxtBox(&(aArqTemp[3,1]), 'DXL_STATUS')" //"Status"
		
	ADD COLUMN oColumn DATA {|| &(aArqTemp[1,1])}  TITLE STR0004    SIZE aArqTemp[1,3]  ;
		PICTURE PesqPict("DXL","DXL_FILIAL")						OF oBrwSuper            //"Filial"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[2,1])}  TITLE STR0005    SIZE aArqTemp[2,3]  ;
		PICTURE PesqPict("DXL","DXL_SAFRA")		   					OF oBrwSuper            //"Safra"
	ADD COLUMN oColumn DATA {|| &(cStatFard)}      TITLE STR0006    SIZE 12             ;
		PICTURE PesqPict("DXL","DXL_STATUS")						OF oBrwSuper            //"Status"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[4,1])}  TITLE STR0007    SIZE aArqTemp[4,3]  ;
		PICTURE PesqPict("DXL","DXL_PSESTI")						OF oBrwSuper            //"Peso Estimado"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[5,1])}  TITLE STR0008    SIZE aArqTemp[5,3]  ;
		PICTURE PesqPict("DXL","DXL_RDMTOP")						OF oBrwSuper 			//"Rend. Previsto %"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[6,1])}  TITLE STR0009    SIZE aArqTemp[6,3]  ;
		PICTURE PesqPict("NJR","NJR_QTDCTR")						OF oBrwSuper            //"Qtde Fardão"
	ADD COLUMN oColumn DATA {|| &(aArqTemp[7,1])}  TITLE STR0010    SIZE aArqTemp[7,3]  ;
		PICTURE PesqPict("DXL","DXL_PSLIQU")						OF oBrwSuper 			//"Peso Total"
					
	ACTIVATE FWFORMBROWSE oBrwSuper
	
	@ 15, 10 SAY   STR0011  SIZE 60, 7 PIXEL OF oPnlWnd1 //"Peso Estimado Total: "
	@ 12, 70 MSGET oPesoEst VAR aTotais[1]  SIZE (TamSX3("DXL_PSESTI")[1]*4), 10 WHEN .F. PICTURE PesqPict("DXL","DXL_PSESTI") PIXEL OF oPnlWnd1
	
	@ 15, 220 SAY  STR0012  SIZE 60, 7 PIXEL OF oPnlWnd1 //"Qtde Fardões: "
	@ 12, 267 MSGET oQtdFard VAR aTotais[2] SIZE (TamSX3("NJR_QTDCTR")[1]*4), 10 WHEN .F. PICTURE PesqPict("NJR","NJR_QTDCTR") PIXEL OF oPnlWnd1
   
	@ 15, 430 SAY  STR0013  SIZE 60, 7 PIXEL OF oPnlWnd1 //"Peso Total: "
	@ 12, 470 MSGET oPesoTot VAR aTotais[3] SIZE (TamSX3("DXL_PSLIQU")[1]*4), 10 WHEN .F. PICTURE PesqPict("DXL","DXL_PSLIQU") PIXEL OF oPnlWnd1
	
	ACTIVATE MSDIALOG oDlg CENTER

	If Select("TRBDXL") > 0
		("TRBDXL")->(DbCloseArea())
	EndIf
	
	//Elimina a tabela temporária, se houver
	AGRDLTPTB(oArqTemp)

Return

/*/{Protheus.doc} CmpFiltro
//Função array do botão filtro
@author marina.muller
@since 17/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function CmpFiltro()
	Local aCampos := {}
	
	AADD(aCampos,{"FILIAL"    , AGRTITULO("DXL_FILIAL"), "C", TamSX3("DXL_FILIAL")[1], TamSX3("DXL_FILIAL")[2], PesqPict("DXL","DXL_FILIAL")})
	AADD(aCampos,{"SAFRA"     , AGRTITULO("DXL_SAFRA"),  "C", TamSX3("DXL_SAFRA")[1],  TamSX3("DXL_SAFRA")[2],  PesqPict("DXL","DXL_SAFRA")})
	AADD(aCampos,{"DXL_STATUS", AGRTITULO("DXL_STATUS"), "C", TamSX3("DXL_STATUS")[1], TamSX3("DXL_STATUS")[2], PesqPict("DXL","DXL_STATUS")})
	AADD(aCampos,{"DXL_PSESTI", AGRTITULO("DXL_PSESTI"), "N", TamSX3("DXL_PSESTI")[1], TamSX3("DXL_PSESTI")[2], PesqPict("DXL","DXL_PSESTI")})
	AADD(aCampos,{"DXL_RDMTOP", AGRTITULO("DXL_RDMTOP"), "N", TamSX3("DXL_RDMTOP")[1], TamSX3("DXL_RDMTOP")[2], PesqPict("DXL","DXL_RDMTOP")})
	AADD(aCampos,{"DXL_PSLIQU", AGRTITULO("DXL_PSLIQU"), "N", TamSX3("DXL_PSLIQU")[1], TamSX3("DXL_PSLIQU")[2], PesqPict("DXL","DXL_PSLIQU")})
	
Return aCampos

/*/{Protheus.doc} QUERY
//Função montagem query
@author marina.muller
@since 17/08/2018
@version 1.0
@return ${return}, ${return_description}
@param cAlias, characters, descricao
@type function
/*/
Static Function QUERY(cAlias)
	Local cQry := ""

	#IFDEF TOP
		cQry := " SELECT DXL.DXL_FILIAL      AS FILIAL,     " 
		cQry +=	"	     DXL.DXL_SAFRA       AS SAFRA,      " 
		cQry +=	"		 DXL.DXL_STATUS      AS STATUS,     "
		cQry +=	"		 SUM(DXL.DXL_PSESTI) AS PESO_EST,   "
		cQry +=	"		 AVG(DXL_RDMTOP)     AS REND_PREV,  "
		cQry +=	"		 COUNT(*)            AS QTDE_FARD,  "
		cQry +=	"		 SUM(DXL.DXL_PSLIQU) AS PESO_TOT    "
		cQry +=	"	FROM " +RetSqlName("DXL")+ " DXL "
		cQry +=	"  WHERE DXL.D_E_L_E_T_ = '' "
		cQry +=	"  GROUP BY DXL.DXL_FILIAL, DXL.DXL_SAFRA, DXL.DXL_STATUS "
		
		cQry := ChangeQuery(cQry)
	#ENDIF

Return(cQry)

/*/{Protheus.doc} CRIATRB
//Função criação tabela temporária
@author marina.muller
@since 17/08/2018
@version 1.0
@return ${return}, ${return_description}
@param cAlias, characters, descricao
@param aTotais, array, descricao
@type function
/*/
Static Function CRIATRB(cAlias, aTotais)
	Local cArqTemp  := ""
	
	aCmpsTab := {}
	aArqTemp := {}
	aTotais := {0,0,0}
	
	If (!Empty(cAliasTRB)) .AND. Select(cAliasTRB) > 0
		(cAliasTRB)->(DbCloseArea())
	EndIf
	
	If Select("TRBDXL") > 0
		("TRBDXL")->(DbCloseArea())
	EndIf
	
	// Cria arquivo de trabalho
	aCmpsTab := TamSX3("DXL_FILIAL" );AADD(aArqTemp,{"FILIAL",      aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXL_SAFRA" ) ;AADD(aArqTemp,{"SAFRA",       aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXL_STATUS" );AADD(aArqTemp,{"DXL_STATUS",  aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXL_PSESTI" );AADD(aArqTemp,{"DXL_PSESTI",  aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXL_RDMTOP" );AADD(aArqTemp,{"DXL_RDMTOP",  aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("NJR_QTDCTR" );AADD(aArqTemp,{"NJR_QTDCTR",  aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})
	aCmpsTab := TamSX3("DXL_PSLIQU" );AADD(aArqTemp,{"DXL_PSLIQU",  aCmpsTab[3],aCmpsTab[1],aCmpsTab[2]})

	//-- Cria Indice de Trabalho
	cArqTemp  := GetNextAlias() 
	oArqTemp  := AGRCRTPTB(cArqTemp, {aArqTemp, {{"", "FILIAL, SAFRA"}} })
	cAliasTRB := cArqTemp

	cQry := QUERY(cAlias)

	cAlias := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQry),cAlias,.F.,.T.)

	(cAlias)->(dbGoTop())
	Count To nQtdl
 
	Processa({|| UBAC012PT(cAlias,@aTotais) },STR0014) //"Aguarde..."

Return({cArqTemp, aArqTemp})

/*/{Protheus.doc} UBAC012PT
//Função carregar os valores na tabela temporária com valor query
@author marina.muller
@since 17/08/2018
@version 1.0
@return ${return}, ${return_description}
@param cAlias, characters, descricao
@param aTotais, array, descricao
@type function
/*/
Static Function UBAC012PT(cAlias,aTotais)
	aTotais[1] := 0
	aTotais[2] := 0
	aTotais[3] := 0
	
	DbSelectArea(cAlias)
	(cAlias)->(dbGotop())
	ProcRegua(nQtdl)

	nRegl := 0
	While (cAlias)->(!Eof())
		nRegl ++
		IncProc(STR0015+Alltrim(Str(nRegl,5))+" / "+Alltrim(Str(nQtdl,5))) //"Processando registro: "
	
		DbSelectArea(cAliasTRB)
		Reclock(cAliasTRB, .T.)
			
		Replace (cAliasTRB)->FILIAL       With (cAlias)->FILIAL
		Replace (cAliasTRB)->SAFRA        With (cAlias)->SAFRA
		Replace (cAliasTRB)->DXL_STATUS   With (cAlias)->STATUS
		Replace (cAliasTRB)->DXL_PSESTI   With (cAlias)->PESO_EST
		Replace (cAliasTRB)->DXL_RDMTOP   With (cAlias)->REND_PREV
		Replace (cAliasTRB)->NJR_QTDCTR   With (cAlias)->QTDE_FARD
		Replace (cAliasTRB)->DXL_PSLIQU   With (cAlias)->PESO_TOT
	
		MsUnlock()
	
		aTotais[1] += (cAlias)->PESO_EST
		aTotais[2] += (cAlias)->QTDE_FARD
		aTotais[3] += (cAlias)->PESO_TOT
		
		(cAlias)->(dbSkip())
	EndDo

	If Select(cAliasTRB) > 0
		(cAliasTRB)->(dbGoTop())
	EndIf

	(cAlias)->(dbCloseArea())

Return

/*/{Protheus.doc} UBAC012RT
//Função carregar os valores dos totalizadores 
@author marina.muller
@since 17/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function UBAC012RT()
	oBrwSuper:ExecuteFilter(.T.)
	oBrwSuper:SetUseFilter(.T.)
	
	aTotais := {0,0,0}

	ARGSETIFARQUI(cAliasTRB)
	While !Eof()
		aTotais[1] += (cAliasTRB)->DXL_PSESTI
		aTotais[2] += (cAliasTRB)->NJR_QTDCTR
		aTotais[3] += (cAliasTRB)->DXL_PSLIQU
		
		DbSkip()
	End
	ARGSETIFARQUI(cAliasTRB)
Return
