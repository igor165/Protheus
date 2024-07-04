#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#Include "TMSA500.CH"

/*/{Protheus.doc} T500MntSql
//Monta o SQL para Filtro do Browse do TMSA500
@author Katia
@since 04/05/2021
@version 12.1.33
@param 
@return cFiltroSQL
@type function
/*/
Function T500MntSql(cFiltro, cFilFilOri, cFilFilDes, dFilDataDe, dFilDataAte,  cFilCodCli, cFilLojCli, lFilCliRem,  ;
lFilCliDes, lFilCliCon, lFilCliDpc, cFilNumNFC, cFilSerNFC, cFilPfxFat, cFilNroFat, cFilTipFat, cFilNroVge, cFaturado )

Local cFiltroSQL   := "" 

Default cFiltro    := ""   //Filtro do Ponto de Entrada
Default cFilFilOri := Space(TamSX3("DT6_FILORI")[1])
Default cFilFilDes := Space(TamSX3("DT6_FILDES")[1])
Default dFilDataDe := CtoD('')
Default dFilDataAte:= CtoD('')
Default cFilCodCli := Space(TamSX3("DT6_CLIREM")[1])
Default cFilLojCli := Space(TamSX3("DT6_LOJREM")[1])
Default lFilCliRem := .F. 
Default lFilCliDes := .F.
Default lFilCliCon := .F.
Default lFilCliDpc := .F.
Default cFilNumNFC := Space(TamSX3("DTC_NUMNFC")[1])
Default cFilSerNFC := Space(TamSX3("DTC_SERNFC")[1])
Default cFilPfxFat := Space(TamSX3("DT6_PREFIX")[1])
Default cFilNroFat := Space(TamSX3("DT6_NUM")[1])
Default cFilTipFat := Space(TamSX3("DT6_TIPO")[1])
Default cFilNroVge := Space(TamSX3("DTQ_VIAGEM")[1])
Default cFaturado  := "1" // "1=Todos" utilizado no filtro para todos documentos faturados ou nao faturados

	If !Empty(cFiltro)   //Filtro do PE TM500FBR
		cFiltroSQL:= cFiltro
	EndIf

	If alltrim(cFaturado) == "2"    		 // Filtro para trazer documentos faturados
		cFiltroSQL += "DT6_NUM <> ' ' "
	ElseIf alltrim(cFaturado) == "3" 		// Filtro para trazer documentos nao faturados
		cFiltroSQL += "DT6_NUM = ' ' "
	EndIf	

	If !Empty(AllTrim(cFilFilOri))	
		If !Empty(cFiltroSQL)
			cFiltroSQL += " AND  "
		EndIf
		cFiltroSQL += " DT6_FILDOC = '" + cFilFilOri + "'  "
	EndIf 
		
	If lFilCliRem
		If !Empty(cFiltroSQL)
			cFiltroSQL += " AND  "
		EndIf
		If !Empty(cFilCodCli)
			cFiltroSQL += " (DT6_CLIREM = '" + cFilCodCli + "' " 
			If !Empty(cFilLojCli)
				cFiltroSQL += " AND  DT6_LOJREM = '" + cFilLojCli + "' " 
			EndIf
			cFiltroSQL += ") "
		EndIf
	EndIf
	
	If lFilCliDes
		If lFilCliRem 
			cFiltroSQL += " OR  "
		ElseIf !Empty(cFiltroSQL)
			cFiltroSQL += " AND  "
		EndIf
		If !Empty(cFilCodCli)
			cFiltroSQL += "  (DT6_CLIDES = '" + cFilCodCli + "' " 
			If !Empty(cFilLojCli)
				cFiltroSQL += "  AND DT6_LOJDES = '" + cFilLojCli+ "' " 
			EndIf
			cFiltroSQL += ") "
		EndIf
	EndIf

	If lFilCliCon
		If lFilCliRem .Or. lFilCliDes
			cFiltroSQL += " OR  "
		ElseIf !Empty(cFiltroSQL)
			cFiltroSQL += " AND  "
		EndIf
		If !Empty(cFilCodCli)
			cFiltroSQL += " (DT6_CLICON= '" + cFilCodCli + "' " 
			If !Empty(cFilLojCli)
				cFiltroSQL += " AND DT6_LOJCON = '" + cFilLojCli + "' " 
			EndIf
			cFiltroSQL += ") "
		EndIf
	EndIf

	If lFilCliDpc
		If lFilCliRem .Or. lFilCliDes .Or. lFilCliCon
			cFiltroSQL += " OR  "
		ElseIf !Empty(cFiltroSQL)
			cFiltroSQL += " AND  "
		EndIf
		If !Empty(cFilCodCli)
			cFiltroSQL += " (DT6_CLIDPC = '" + cFilCodCli + "' " 
			If !Empty(cFilLojCli)
				cFiltroSQL += " AND  DT6_LOJDPC = '" + cFilLojCli + "' " 
			EndIf
			cFiltroSQL += ") "
		EndIf
	EndIf

	   
	If !Empty(AllTrim(cFilFilDes)) 
		If !Empty(cFiltroSQL)
			cFiltroSQL += " AND  "
		EndIf
		cFiltroSQL += " DT6_FILDES = '"+cFilFilDes+"'" 
	EndIf

	If !Empty(AllTrim(DtoS(dFilDataDe))) .and. !Empty(AllTrim(DtoS(dFilDataAte)))
		If !Empty(cFiltroSQL)
			cFiltroSQL += " AND  "
		EndIf
		cFiltroSQL += " (DT6_DATEMI BETWEEN '"+DtoS(dFilDataDe)+"' AND '"+DtoS(dFilDataAte)+"' ) " 
	EndIf

		 
	If !Empty(cFilPfxFat) .And. !Empty(cFilNroFat) .And. !Empty(cFilTipFat)
		If !Empty(cFiltroSQL)
			cFiltroSQL += " AND  "
		EndIf
		cFiltroSQL += " DT6_PREFIX = '" +cFilPfxFat + "'"
		cFiltroSQL += " AND DT6_NUM = '" +cFilNroFat + "'	" 
		cFiltroSQL += " AND DT6_TIPO  = '"+cFilTipFat + "' " 
	EndIf

	If !Empty(cFilNumNFC)
		If !Empty(cFiltroSQL)
			cFiltroSQL += " AND  "
		EndIf
		cFiltroSQL += " (EXISTS (SELECT 1"
		cFiltroSQL += " FROM "+RetSqlName("DTC")+" DTC"
		cFiltroSQL += " WHERE DTC.DTC_FILIAL  = '"+xFilial("DTC")+"'"
		cFiltroSQL += " AND DTC.DTC_FILDOC     = DT6_FILDOC "
		cFiltroSQL += " AND DTC.DTC_DOC       = DT6_DOC "
		cFiltroSQL += " AND DTC.DTC_SERIE    = DT6_SERIE "
		cFiltroSQL += " AND DTC.DTC_NUMNFC = '" + cFilNumNFC +"'
		If !Empty(cFilSerNFC)
			cFiltroSQL += " AND DTC.DTC_SERNFC = '" + cFilSerNFC +"'
		EndIf
		cFiltroSQL += " AND DTC.D_E_L_E_T_ = ' ')) "
	EndIf

	If !Empty(cFilNroVge)
		If !Empty(cFiltroSQL)
			cFiltroSQL += " AND  "
		EndIf
		cFiltroSQL += " (EXISTS (SELECT 1"
		cFiltroSQL += " FROM "+RetSqlName("DUD")+" DUD"
		cFiltroSQL += " WHERE DUD.DUD_FILIAL  = '"+xFilial("DUD")+"'"
		cFiltroSQL += " AND DUD.DUD_FILDOC     = DT6_FILDOC "
		cFiltroSQL += " AND DUD.DUD_DOC       = DT6_DOC "
		cFiltroSQL += " AND DUD.DUD_SERIE    = DT6_SERIE "
		cFiltroSQL += " AND DUD.DUD_FILORI= '" + cFilAnt +"'
		cFiltroSQL += " AND DUD.DUD_VIAGEM= '" + cFilNroVge +"'
		cFiltroSQL += " AND DUD.D_E_L_E_T_ = ' ')) "
	EndIf
Return cFiltroSQL

/*/{Protheus.doc} T500VisVge
//Visualizar Viagem do Browse
@author Katia
@since 04/05/2021
@version 12.1.33
@type Static function
/*/
Function T500VisVge()
Local lTabDM3  := AliasInDic("DM3")
Local aArea    := GetArea()

//--- Variaveis para Viagem Modelo2
Private cSerTms  := ""
Private cTipTra  := ""
Private aIndex   := ""
Private lLocaliz := SuperGetMv("MV_LOCALIZ",.F.,"") == 'S'
Private INCLUI   := .F.
Private ALTERA   := .F.

DTQ->(dbSetOrder(2))
If DTQ->(MsSeek(xFilial("DTQ") + DUD->DUD_FILORI + DUD->DUD_VIAGEM))
	If lTabDM3
		DM3->(dbSetOrder(1))
		If DM3->(MsSeek(xFilial("DM3") + DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM)))
			FWExecView (, "TMSAF60" , MODEL_OPERATION_VIEW , ,{|| .T. }, , , , , , , )
		Else
			lTabDM3:= .F.
		EndIf
	EndIf

	If !lTabDM3
		cSerTms := DTQ->DTQ_SERTMS
		cTipTra := DTQ->DTQ_TIPTRA		

		TmsA144Mnt('DTQ',DTQ->(Recno()),2,)
	EndIf
EndIf
RestArea(aArea)
FwFreeArray(aArea)
Return

/*/{Protheus.doc} T500VisPnd
//Visualizar Pendencia/Indenizacao do Browse
@author Katia
@since 04/05/2021
@version 12.1.33
@type Function
/*/
Function T500VisPnd(cTpPend)
Local aAreas := {DT6->(GetArea()),GetArea()}
Local lRet   := .T.

Private INCLUI := .F.
Private ALTERA := .F.

Default cTpPend:= "P"  //P- Pendencia, I-Indenização

If cTpPend == "I"
	If !Empty(DUU->DUU_FILRID) .And. !Empty(DUU->DUU_NUMRID)
		DUB->( DbSetOrder( 2 ) )
		If DUB->( !MsSeek( xFilial('DUB')+DUU->(DUU_FILRID+DUU_NUMRID) ) )
			Help(' ', 1, 'TMSA54006')	//-- Erro ao localizar Registro de Indenização	
			lRet:= .F.
		Else
			TMSA370Mnt( 'DUB',  DUB->(Recno()), 2 )
		EndIf
	EndIf
Else
	TMSA540Mnt('DUU', DUU->(Recno()), 2 )
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return lRet


/*/{Protheus.doc} T500VisNF
//Visualizar Nota Fiscal Cliente
@author Katia
@since 04/05/2021
@version 12.1.33
@type Function
/*/
Function T500VisNF()
Local aArea:= GetArea()

Private INCLUI := .F.

TMSA050Mnt("DTC",DTC->(Recno()),2)

RestArea(aArea)
FwFreeArray()
Return

/*/{Protheus.doc} T500VisOpe
//Visualizar Operações da Viagem
@author Katia
@since 04/05/2021
@version 12.1.33
@type Function
/*/
Function T500VisOpe()
Local aAreas := {DT6->(GetArea()),GetArea()}

Private INCLUI := .F.
Private ALTERA := .F.

TMSA350Mnt( 'DTW',  DTW->(Recno()), 2 )

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} T500MntDoc
Tela de manutenção de Tipo Serviço / Transporte para diversos documentos
@author Rafael Souza
@since 02/12/21
@version 1.0
/*/
//-------------------------------------------------------------------
Function T500MntDoc(aDoc)
Local aCoors   := FWGetDialogSize(oMainWnd)
Local nOpca    := 0
Local cAlias   := "TRB"
Local cTabela  := STR0001 //"Manutenção de Documentos"
Local cTipTra  := Space(Len(DTQ->DTQ_TIPTRA))
Local cSerTms  := Space(Len(DTQ->DTQ_SERTMS))
Local oLayer, oPanelUp1, oPanelDown, oDlgPrinc
Local nx 	   := 0

//--Tabela Temporária 
Local oTempTable	:= Nil 
Local aStru			:= {} //Estrutura da Tela
Local aCampos		:= {} //Campos que Compoem a tela 
Local aColsBrw		:= {} //Colunas da MarkBrowse 
Local abkpRot 		:= {}

Default aDoc := {}

If !IsInCallStack("TMSA500")
	cTipTra  := DTQ->DTQ_TIPTRA
	cSerTms  := DTQ->DTQ_SERTMS 
Else //-- Limpa o arotina para não exibir as opções do menu do TMSA500.
	abkpRot := aclone(aRotina)
	aRotina	:={}
EndIf 

//--Definição dos campos da FwMarkBrowse 
aCampos := { {"MARK"   ,"", "Ok"},;
{"FILORI"   ,"", AllTrim(FwX3Titulo('DUD_FILORI'))	, GetSX3Cache('DUD_FILORI', "X3_PICTURE") },;
{"FILDOC"	,"", AllTrim(FwX3Titulo('DUD_FILDOC'))	, GetSX3Cache('DUD_FILDOC', "X3_PICTURE") },;
{"DOC"		,"", AllTrim(FwX3Titulo('DUD_DOC'))		, GetSX3Cache('DUD_DOC'	  , "X3_PICTURE") },;
{"SERIE"	,"", AllTrim(FwX3Titulo('DUD_SERIE'))	, GetSX3Cache('DUD_SERIE' , "X3_PICTURE") },;
{"SERTMS"	,"", AllTrim(FwX3Titulo('DUD_SERTMS'))	, GetSX3Cache('DUD_SERTMS', "X3_PICTURE") },;
{"TIPTRA" 	,"", AllTrim(FwX3Titulo('DUD_TIPTRA'))	, GetSX3Cache('DUD_TIPTRA', "X3_PICTURE") },;
{"CLIREM"	,"", AllTrim(FwX3Titulo('DT6_CLIREM'))	, GetSX3Cache('DT6_CLIREM', "X3_PICTURE") },;
{"LOJREM"	,"", AllTrim(FwX3Titulo('DT6_LOJREM'))	, GetSX3Cache('DT6_LOJREM', "X3_PICTURE") },;
{"REM_NOME"	,"", AllTrim(FwX3Titulo('A1_NOME'))		, GetSX3Cache('A1_NOME'   , "X3_PICTURE") },;
{"CLIDES"	,"", AllTrim(FwX3Titulo('DT6_CLIDES'))	, GetSX3Cache('DT6_CLIDES', "X3_PICTURE") },;
{"LOJDES"	,"", AllTrim(FwX3Titulo('DT6_LOJDES'))	, GetSX3Cache('DT6_LOJDES', "X3_PICTURE") },;
{"DES_NOME"	,"", AllTrim(FwX3Titulo('A1_NOME'))		, GetSX3Cache('A1_NOME'   , "X3_PICTURE") },;
{"DES_MUNICI" ,"", AllTrim(FwX3Titulo('A1_MUN'))	, GetSX3Cache('A1_MUN'    , "X3_PICTURE") },;
{"DES_UF" 	  ,"", AllTrim(FwX3Titulo('A1_EST'))	, GetSX3Cache('A1_EST'    , "X3_PICTURE") }}

//--Definição da estrutura do arquivo
AADD(aStru,{ "MARK"   	, "C", 2                   	, 0 })
AADD(aStru,{ "FILORI" 	, "C", Len(DUD->DUD_FILORI) , 0 })
AADD(aStru,{ "FILDOC" 	, "C", Len(DUD->DUD_FILDOC) , 0 })
AADD(aStru,{ "DOC" 		, "C", Len(DUD->DUD_DOC)   	, 0 })
AADD(aStru,{ "SERIE"  	, "C", Len(DUD->DUD_SERIE) 	, 0 })
AADD(aStru,{ "SERTMS" 	, "C", Len(DUD->DUD_SERTMS)	, 0 })
AADD(aStru,{ "TIPTRA"  	, "C", Len(DUD->DUD_TIPTRA)	, 0 })
AADD(aStru,{ "CLIREM" 	, "C", Len(DT6->DT6_CLIREM)	, 0 })
AADD(aStru,{ "LOJREM"	, "C", Len(DT6->DT6_LOJREM)	, 0 })
AADD(aStru,{ "REM_NOME" , "C", Len(SA1->A1_NOME)	, 0 })
AADD(aStru,{ "CLIDES" 	, "C", Len(DT6->DT6_CLIDES)	, 0 })
AADD(aStru,{ "LOJDES"	, "C", Len(DT6->DT6_LOJDES)	, 0 })
AADD(aStru,{ "DES_NOME" , "C", Len(SA1->A1_NOME)	, 0 })
AADD(aStru,{ "DES_MUNICI"  	, "C", Len(SA1->A1_MUN)	, 0 })
AADD(aStru,{ "DES_UF"  		, "C", Len(SA1->A1_EST)	, 0 })

//--FILORI
oBrwCol := FWBrwColumn():New()
oBrwCol:SetType('C')
oBrwCol:SetData(&("{|| (cAlias)->FILORI }"))
oBrwCol:SetTitle(FwX3Titulo('DUD_FILORI'))
oBrwCol:SetSize(TAMSX3("DUD_FILORI")[1])
oBrwCol:SetDecimal(0)
oBrwCol:SetPicture("")
oBrwCol:SetReadVar("DUD_FILORI")
AAdd(aColsBrw, oBrwCol)

//--FILDOC
oBrwCol := FWBrwColumn():New()
oBrwCol:SetType('C')
oBrwCol:SetData(&("{|| (cAlias)->FILDOC }"))
oBrwCol:SetTitle(FwX3Titulo('DUD_FILDOC'))
oBrwCol:SetSize(TAMSX3("DUD_FILDOC")[1])
oBrwCol:SetDecimal(0)
oBrwCol:SetPicture("")
oBrwCol:SetReadVar("DUD_FILDOC")
AAdd(aColsBrw, oBrwCol)

//--DOC
oBrwCol := FWBrwColumn():New()
oBrwCol:SetType('C')
oBrwCol:SetData(&("{|| (cAlias)->DOC }"))
oBrwCol:SetTitle(FwX3Titulo('DUD_DOC'))
oBrwCol:SetSize(TAMSX3("DUD_DOC")[1])
oBrwCol:SetDecimal(0)
oBrwCol:SetPicture("")
oBrwCol:SetReadVar("DUD_DOC")
AAdd(aColsBrw, oBrwCol)

//--SERIE
oBrwCol := FWBrwColumn():New()
oBrwCol:SetType('C')
oBrwCol:SetData(&("{|| (cAlias)->SERIE }"))
oBrwCol:SetTitle(FwX3Titulo('DUD_SERIE'))
oBrwCol:SetSize(TAMSX3("DUD_SERIE")[1])
oBrwCol:SetDecimal(0)
oBrwCol:SetPicture("")
oBrwCol:SetReadVar("DUD_SERIE")
AAdd(aColsBrw, oBrwCol)

//--SERTMS
oBrwCol := FWBrwColumn():New()
oBrwCol:SetType('C')
oBrwCol:SetData(&("{|| (cAlias)->SERTMS }"))
oBrwCol:SetTitle(FwX3Titulo('DUD_SERTMS'))
oBrwCol:SetSize(TAMSX3("DUD_SERTMS")[1])
oBrwCol:SetDecimal(0)
oBrwCol:SetPicture("")
oBrwCol:SetReadVar("DUD_SERTMS")
AAdd(aColsBrw, oBrwCol)

//--TIPTRA
oBrwCol := FWBrwColumn():New()
oBrwCol:SetType('C')
oBrwCol:SetData(&("{|| (cAlias)->TIPTRA }"))
oBrwCol:SetTitle(FwX3Titulo('DUD_TIPTRA'))
oBrwCol:SetSize(TAMSX3("DUD_TIPTRA")[1])
oBrwCol:SetDecimal(0)
oBrwCol:SetPicture("")
oBrwCol:SetReadVar("DUD_TIPTRA")
AAdd(aColsBrw, oBrwCol)

//--CLIREM
oBrwCol := FWBrwColumn():New()
oBrwCol:SetType('C')
oBrwCol:SetData(&("{|| (cAlias)->CLIREM }"))
oBrwCol:SetTitle(FwX3Titulo('DT6_CLIREM'))
oBrwCol:SetSize(TAMSX3("DT6_CLIREM")[1])
oBrwCol:SetDecimal(0)
oBrwCol:SetPicture("")
oBrwCol:SetReadVar("DT6_CLIREM")
AAdd(aColsBrw, oBrwCol)

//--LOJREM
oBrwCol := FWBrwColumn():New()
oBrwCol:SetType('C')
oBrwCol:SetData(&("{|| (cAlias)->LOJREM }"))
oBrwCol:SetTitle(FwX3Titulo('DT6_LOJREM'))
oBrwCol:SetSize(TAMSX3("DT6_LOJREM")[1])
oBrwCol:SetDecimal(0)
oBrwCol:SetPicture("")
oBrwCol:SetReadVar("DT6_LOJREM")
AAdd(aColsBrw, oBrwCol)

//--REM_NOME
oBrwCol := FWBrwColumn():New()
oBrwCol:SetType('C')
oBrwCol:SetData(&("{|| (cAlias)->REM_NOME }"))
oBrwCol:SetTitle("Nome Remetente")
oBrwCol:SetSize(TAMSX3("A1_NOME")[1])
oBrwCol:SetDecimal(0)
oBrwCol:SetPicture("")
oBrwCol:SetReadVar("DT6_CLIREM")
AAdd(aColsBrw, oBrwCol)

//--CLIDES
oBrwCol := FWBrwColumn():New()
oBrwCol:SetType('C')
oBrwCol:SetData(&("{|| (cAlias)->CLIDES }"))
oBrwCol:SetTitle(FwX3Titulo('DT6_CLIDES'))
oBrwCol:SetSize(TAMSX3("DT6_CLIDES")[1])
oBrwCol:SetDecimal(0)
oBrwCol:SetPicture("")
oBrwCol:SetReadVar("DT6_CLIDES")
AAdd(aColsBrw, oBrwCol)

//--LOJDES
oBrwCol := FWBrwColumn():New()
oBrwCol:SetType('C')
oBrwCol:SetData(&("{|| (cAlias)->LOJDES }"))
oBrwCol:SetTitle(FwX3Titulo('DT6_LOJDES'))
oBrwCol:SetSize(TAMSX3("DT6_LOJDES")[1])
oBrwCol:SetDecimal(0)
oBrwCol:SetPicture("")
oBrwCol:SetReadVar("DT6_LOJDES")
AAdd(aColsBrw, oBrwCol)

//--DES_NOME
oBrwCol := FWBrwColumn():New()
oBrwCol:SetType('C')
oBrwCol:SetData(&("{|| (cAlias)->DES_NOME }"))
oBrwCol:SetTitle("Nome Destinatário")
oBrwCol:SetSize(TAMSX3("A1_NOME")[1])
oBrwCol:SetDecimal(0)
oBrwCol:SetPicture("")
oBrwCol:SetReadVar("DT6_CLIDES")
AAdd(aColsBrw, oBrwCol)

//--DES_MUNICI
oBrwCol := FWBrwColumn():New()
oBrwCol:SetType('C')
oBrwCol:SetData(&("{|| (cAlias)->DES_MUNICI }"))
oBrwCol:SetTitle(FwX3Titulo('A1_MUN'))
oBrwCol:SetSize(TAMSX3("A1_MUN")[1])
oBrwCol:SetDecimal(0)
oBrwCol:SetPicture("")
oBrwCol:SetReadVar("DES_MUNICI")
AAdd(aColsBrw, oBrwCol)

//--DES_UF
oBrwCol := FWBrwColumn():New()
oBrwCol:SetType('C')
oBrwCol:SetData(&("{|| (cAlias)->DES_UF }"))
oBrwCol:SetTitle(FwX3Titulo('A1_EST'))
oBrwCol:SetSize(TAMSX3("A1_EST")[1])
oBrwCol:SetDecimal(0)
oBrwCol:SetPicture("")
oBrwCol:SetReadVar("DES_UF")
AAdd(aColsBrw, oBrwCol)

oTempTable := FwTemporaryTable():New("TRB")
oTempTable :SetFields( aStru )
oTempTable :AddIndex("01",{"FILDOC","DOC","SERIE"})
oTempTable :Create()

//--Grava a tabela temporária 
For nx := 1 to Len(aDoc)
	dbSelectArea("TRB")
	RecLock("TRB",.T.)
	MARK 	:= "" 
	FILORI  := adoc[nx][1]
	FILDOC	:= aDoc[nx][2] 
	DOC		:= aDoc[nx][3]
	SERIE	:= aDoc[nx][4]
	SERTMS	:= aDoc[nx][5]
	TIPTRA	:= aDoc[nx][6]
	CLIREM  := aDoc[nx][7]
	LOJREM	:= aDoc[nx][8]
	REM_NOME:= aDoc[nx][9]
	CLIDES  := aDoc[nx][10]
	LOJDES  := aDoc[nx][11]
	DES_NOME:= aDoc[nx][12]
	DES_MUNICI:= aDoc[nx][13]
	DES_UF	:= aDoc[nx][14]
	TRB->(MsUnlock())
Next nX 

dbSelectArea("TRB")
dbGoTop()


If !Empty(cAlias)

	DEFINE MSDIALOG oDlgPrinc TITLE STR0001 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] PIXEL // Manutenção de Documentos 

		//-- Cria o Layer
		oLayer := FWLayer():New()
		oLayer:Init(oDlgPrinc,.F.,.T.)

		//-- Adiciona Linha	
		oLayer:AddLine("UP"  ,020,.F.)
		oLayer:AddLine("DOWN",070,.F.)

		//-- Adiciona Coluna
		oLayer:AddCollumn("COLUMN1",100,.T.,"UP")
		oLayer:AddCollumn("ALL"    ,100,.F.,"DOWN")

		//-- Adiciona Janela
		oLayer:AddWindow("COLUMN1","WINDOW1","Campos",100,.F.,.T.,,"UP",{||})	//-- "Campos"
		
		//-- Adiciona Painel
		oPanelUp1  := oLayer:GetWinPanel("COLUMN1","WINDOW1","UP")
		oPanelDown := oLayer:GetColPanel("ALL","DOWN")

		//-- Adiciona Campos para Marcação
		TSay():New(011,001,{|| STR0080},oPanelUp1,,,.F.,.F.,.F.,.T.,,,050,007)	//-- "Para Serviço Transp. : "
		TSay():New(011,100,{|| STR0078},oPanelUp1,,,.F.,.F.,.F.,.T.,,,050,007)	//-- "Para Tipo Transp.: "
	
		TGet():New(010,055,{|u| Iif(PCount() > 0,cSerTms   := u,cSerTms)}   ,oPanelUp1,010,007,"@!",{||CheckSx3("DUD_SERTMS",cSerTms)},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"DLH","cSerTms")
		TGet():New(010,158,{|u| Iif(PCount() > 0,cTipTra   := u,cTipTra)}   ,oPanelUp1,010,007,"@!",{||CheckSx3("DUD_TIPTRA",cTipTra)},,,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"DLG","cTipTra")

		
		//-- Adiciona o MarkBrowse das Tabelas		
		oMrkBrw:= FWMarkBrowse():New()
		oMrkBrw:SetOwner(oPanelDown)
		oMrkBrw:SetDescription(cTabela)
		oMrkBrw:SetAlias(cAlias)
		oMrkBrw:SetFieldMark("MARK")
		oMrkBrw:SetColumns(aColsBrw)
		oMrkBrw:SetMenuDef("")
		oMrkBrw:DisableDetails()
		oMrkBrw:SetTemporary()
		oMrkBrw:bMark    := {|| T500TRBMk(cAlias,cSerTms)}
		oMrkBrw:bAllMark := {|| T500TRBIn(cAlias) }
		
		oMrkBrw:Activate()

	ACTIVATE MSDIALOG oDlgPrinc ON INIT EnchoiceBar(oDlgPrinc,{|| Iif(T500TdOk(cAlias,cSerTms),(nOpca := 1,oDlgPrinc:End()),.F.)},{||oDlgPrinc:End()}) CENTERED

	If nOpca == 1 .And. !Empty(cTiptra) .And. !Empty(cSerTms)	//-- Salvar
		FwMsgRun(,{|| T500AtzDUD(cAlias,cTipTra,cSerTms)},STR0162,STR0071)	//-- "Aguarde..." # "Atualizando Documento..."
	EndIf

EndIf

oTempTable:Delete() //-- Deleta arquivo temporario do banco

aRotina := aClone(abkpRot) //--Restaura o menu aRotina

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} T500TRBMk
Marcacao de um registro
@author Rafael Souza
@since 03/12/21
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function T500TRBMk(cAliasTRB, cSerTms)

	Local lRet := .T.
		
	Default cAliasTRB 	:= ""
	Default cSerTMS 	:= ""

	If (cAliasTRB)->SERIE != 'COL' .And. cSerTMS == '1' 
		Aviso("Aviso" , "Documento: " + (cAliasTRB)->DOC + "Série: " + (cAliasTRB)->SERIE + ", não é uma Sol. de Coleta, informe outro tipo de serviço." ,{"OK"})
		(cAliasTRB)->(MsRLock())
		(cAliasTRB)->MARK := "  "
		(cAliasTRB)->(MsUnlock())
		lRet := .F.
	EndIf  	

	oMrkBrw:oBrowse:Refresh(.t.)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T500TRBIn
Marcacao de vários registros
@author Rafael Souza
@since 03/12/21
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function T500TRBIn(cAliasTRB)

	Local nReg		:= (cAliasTRB)->(Recno())
	Local cMarca	:= oMrkBrw:cMark

	DbSelectArea(cAliasTRB)
	DbGoTop()

	While !(cAliasTRB)->(Eof())
		If (cAliasTRB)->(MsRLock())
			If	(cAliasTRB)->MARK == cMarca
				(cAliasTRB)->MARK := "  "
				(cAliasTRB)->(MsUnlock())
			Else
				(cAliasTRB)->MARK := cMarca
			Endif
		Endif
		(cAliasTRB)->(dbSkip())
	Enddo

	(cAliasTRB)->(dbGoto(nReg))

	oMrkBrw:oBrowse:Refresh(.t.)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} T500TdOk
Validações Gerais para confirmar a gravação da alteração do DUD
@author Rafael Souza
@since 07/12/21
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function T500TdOk(cAlias,cserTms)
Local aArea	:= GetArea()
Local lRet	:= .T. 		  

Default cAlias	:= ""
Default cSerTms := ""

	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())

	While !(cAlias)->(Eof())

		If !Empty((cAlias)->MARK)
			If (cAlias)->SERIE != 'COL' .And. cSerTMS == '1' 
				Aviso("Aviso" , "Documento: " + (cAlias)->DOC + "Série: " + (cAlias)->SERIE + ", não é uma Sol. de Coleta, informe outro tipo de serviço." ,{"OK"})
				lRet := .F.
				Exit
			ElseIf (cAlias)->SERIE == 'COL' .And. cSerTMS != '1'
			 	Aviso("Aviso" , "Documento: " + (cAlias)->DOC + "Série: " + (cAlias)->SERIE + ", é uma Sol. de Coleta, informe outro tipo de serviço." ,{"OK"})
				lRet := .F.
				Exit 
			EndIf	
		EndIf

		DbSelectArea(cAlias)
		(cAlias)->(DbSkip())
	EndDo

	RestArea(aArea)

Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} T500AtzDUD
Rotina Acionada Pelo Botao "Confirmar" Do FWMarkBrowse
@author Rafael Souza
@since 03/12/21
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function T500AtzDUD(cAlias,cTipTra,cserTms)
Local aArea       := GetArea()

Default cAlias	:= ""
Default cTipTra := ""
Default cSerTms := ""

	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())

	While !(cAlias)->(Eof())

		If !Empty((cAlias)->MARK)
			DUD->(DbSetOrder(1))
			If DUD->(MsSeek(xFilial("DUD")+TRB->FILDOC+TRB->DOC+TRB->SERIE+cFilAnt))
				RecLock("DUD",.F.)
				DUD->DUD_TIPTRA := cTiptra 
				DUD->DUD_SERTMS := cSerTms 
				MsUnlock()  
			EndIf 
		EndIf

		DbSelectArea(cAlias)
		(cAlias)->(DbSkip())
	EndDo

	RestArea(aArea)

Return()



//-------------------------------------------------------------------
/*/{Protheus.doc} T500QryDoc
Identifica os documentos aptos para manutenção de Transporte em Lote
@author Rafael Souza
@since 03/12/21
@version 1.0
/*/
//-------------------------------------------------------------------
Function T500QryDoc()

Local aAreas    := {GetArea()}
Local aDoctos	:= {} 
Local cQuery    := ""
Local cAliasDUD := ""
Local dDtEmiDe	:= ""
Local dDtEmiAte	:= ""

Pergunte('TMA500A',.T.)
dDtEmiDe 	:= DtoS(mv_par01)
dDtEmiAte	:= DtoS(mv_par02)

cQuery := "SELECT DUD_FILIAL, DUD_FILORI, DUD_FILDOC, DUD_DOC, DUD_SERIE, DUD_SERTMS, DUD_TIPTRA, DT6_DATEMI, DT6_CLIREM, DT6_LOJREM, CLIREM.A1_NOME REM_NOME, DT6_CLIDES, DT6_LOJDES, CLIDES.A1_NOME DES_NOME, CLIDES.A1_MUN DES_MUNICI, CLIDES.A1_EST DES_UF"
cQuery += " FROM " + RetSqlName("DUD") + " DUD "
cQuery += " INNER JOIN " + RetSqlName("DT6") + " DT6 "
cQuery += " ON DT6.DT6_FILIAL 	= '" + xFilial("DT6") + "' "
cQuery += " AND DT6.DT6_FILDOC 	= DUD.DUD_FILDOC "
cQuery += " AND DT6.DT6_DOC 	= DUD.DUD_DOC "
cQuery += " AND DT6.DT6_SERIE 	= DUD.DUD_SERIE "
cQuery += " AND DT6.D_E_L_E_T_ 	= ' ' "
cQuery += " INNER JOIN " + RetSqlName('SA1') + " CLIREM  ON (CLIREM.A1_COD = DT6_CLIREM AND CLIREM.A1_LOJA = DT6_LOJREM ) " + CRLF
cQuery += " INNER JOIN " + RetSqlName('SA1') + " CLIDES  ON (CLIDES.A1_COD = DT6_CLIDES AND CLIDES.A1_LOJA = DT6_LOJDES ) " + CRLF
cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "'"
cQuery += " AND DUD.DUD_FILORI = '" +cFilant + "'"
cQuery += " AND DUD.DUD_VIAGEM = ' '"
cQuery += " AND DUD.DUD_SERTMS BETWEEN  '" + MV_PAR05       + "' AND '" + MV_PAR06       + "'"
cQuery += " AND DUD.DUD_TIPTRA BETWEEN  '" + MV_PAR03       + "' AND '" + MV_PAR04       + "'"
cQuery += " AND DT6.DT6_DATEMI BETWEEN  '" + dDtEmiDe       + "' AND '" + dDtEmiAte      + "'"
cQuery += " AND DUD.D_E_L_E_T_ = ' '"
cQuery += " AND CLIREM.A1_FILIAL  = '" + xFilial('SA1') + "'" + CRLF
cQuery += " AND CLIREM.D_E_L_E_T_ = ' '" + CRLF
cQuery += " AND CLIDES.A1_FILIAL  = '" + xFilial('SA1') + "'" + CRLF
cQuery += " AND CLIDES.D_E_L_E_T_ = ' '"

cAliasDUD := GetNextAlias()
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUD,.T.,.T.)

While (cAliasDUD)->(!Eof())
	Aadd(aDoctos,{(cAliasDUD)->DUD_FILORI,(cAliasDUD)->DUD_FILDOC,(cAliasDUD)->DUD_DOC,(cAliasDUD)->DUD_SERIE,(cAliasDUD)->DUD_SERTMS,;
		(cAliasDUD)->DUD_TIPTRA,(cAliasDUD)->DT6_CLIREM,(cAliasDUD)->DT6_LOJREM,(cAliasDUD)->REM_NOME,(cAliasDUD)->DT6_CLIDES, (cAliasDUD)->DT6_LOJDES, (cAliasDUD)->DES_NOME, (cAliasDUD)->DES_MUNICI, (cAliasDUD)->DES_UF })	
(cAliasDUD)->(DbSkip()) 	
EndDo 
(cAliasDUD)->(DbCloseArea())	

If Len(aDoctos) > 0 
	T500MntDoc(aDoctos) //--Tela de Manutenção de Documentos 
Else
	Help( " ",1,"TMSA500F7") //-- Não foi localizado documentos para manutenção para os parâmetros informados.
EndIf 

AEval(aAreas,{|x,y| RestArea(x) })

//--Destroi o array aDoctos
aSize(aDoctos, 0)
aDoctos := Nil 

Return 
