#Include "Mata017.ch"
#Include "Protheus.ch"
#Include "FWMVCDEF.CH"

Static lNewCdv :=  .F.
//lNewCdv := CDV->(FieldPos("CDV_REGCAL")) > 0 .and. CDV->(FieldPos("CDV_VLOUTR")) > 0 .and. CDV->(FieldPos("CDV_CODMSG")) > 0 .and. CDV->(FieldPos("CDV_CODCPL")) > 0 .and. CDV->(FieldPos("CDV_TXTDSC")) > 0 .and. CDV->(FieldPos("CDV_OPBASE")) > 0 .and. CDV->(FieldPos("CDV_OPALIQ")) > 0 .and. CDV->(FieldPos("CDV_AGRLAN")) > 0
 
 //-------------------------------------------------------------------
/*/{Protheus.doc} MATA017()
Cadastro das informacoes adicionais da Apuracao
@author Flavio Luiz Vicco
@since 29/01/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

Function Mata017()
Local oBrowse 		:= Nil
Local lVer12		:= SubStr( GetRpoRelease(),1,2 ) == "12"

Private aRotina		:= MenuDef()
Private cCadastro	:= OemToAnsi(STR0001) //"Inf. Adic.da Apuracao"
Private cKeyCDV		:= ""
Private lDicAtu		:= ValidDic()

IF !lVer12
	AjustaHlp()
Endif

If !ValidDic()
	Help("",1,"Help","Help",STR0010,1,0)//Ambiente desatualizado, favor executar o UPDDISTR com o ultimo pacote de expedição do fiscal disponivel no portal do cliente!
EndIf

//CDV->(dbSetOrder(1)) //CDV_FILIAL+CDV_PERIOD+CDV_CODAJU+CDV_LIVRO+CDV_DOC+CDV_SERIE+CDV_CLIFOR+CDV_LOJA

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("CDV")
oBrowse:SetMenuDef("MATA017")
oBrowse:SetDescription(cCadastro) //"Inf. Adic.da Apuracao"
oBrowse:Activate()

Return()

//-------------------------------------
/*/{Protheus.doc} MenuDef do Browser
@author  	Flavio Luiz Vicco
@version 	P11
@build		7.00.121227P
@since		29/01/2015
@return 	aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------
Static Function MenuDef()
/*
Local aRotina := {}
ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"         OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.MATA017" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.MATA017" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.MATA017" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.MATA017" OPERATION 5 ACCESS 0 //"Excluir"
*/
Return FWMVCMenu("MATA017")

//-------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo de Dados
@author  	Flavio Luiz Vicco
@version 	P11
@build		7.00.121227P
@since		29/01/2015
@return 	oModel Objeto do Modelo
/*/
//-------------------------------------
Static Function ModelDef()
Local oModel	:= Nil
Local oStruCDV	:= FWFormStruct( 1, "CDV")
lNewCdv := CDV->(FieldPos("CDV_REGCAL")) > 0 .and. CDV->(FieldPos("CDV_VLOUTR")) > 0 .and. CDV->(FieldPos("CDV_CODMSG")) > 0 .and. CDV->(FieldPos("CDV_CODCPL")) > 0 .and. CDV->(FieldPos("CDV_TXTDSC")) > 0 .and. CDV->(FieldPos("CDV_OPBASE")) > 0 .and. CDV->(FieldPos("CDV_OPALIQ")) > 0 .and. CDV->(FieldPos("CDV_AGRLAN")) > 0

cKeyCDV := AllTrim(oStruCDV:aIndex[1][3]) //Retorna indice prim.

oModel:= MpFormModel():New("MATA017", /*Pre-Validacao*/, {|oModel|A017TudOk(oModel)}/*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
oModel:SetDescription(STR0001) //"Inf. Adic.da Apuracao"

If ValidDic()
	oStruCDV:SetProperty('CDV_ID'		,MODEL_FIELD_INIT, {|| FWUUID("CDV") })
	oStruCDV:SetProperty('CDV_NUMITE'	,MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 .OR. (oModel:GetOperation()==4 .AND. CDV->CDV_AUTO <> "1")) })
Else
	oStruCDV:SetProperty('CDV_NUMITE'	,MODEL_FIELD_WHEN, {|| .F. })
EndIf
oStruCDV:SetProperty('CDV_DOC'		,MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 .OR. (oModel:GetOperation()==4 .AND. CDV->CDV_AUTO <> "1")) })
oStruCDV:SetProperty('CDV_SERIE'	,MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 .OR. (oModel:GetOperation()==4 .AND. CDV->CDV_AUTO <> "1")) })
oStruCDV:SetProperty('CDV_CLIFOR'	,MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 .OR. (oModel:GetOperation()==4 .AND. CDV->CDV_AUTO <> "1")) })
oStruCDV:SetProperty('CDV_LOJA'		,MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 .OR. (oModel:GetOperation()==4 .AND. CDV->CDV_AUTO <> "1")) })
oStruCDV:SetProperty('CDV_TPMOVI'	,MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 .OR. (oModel:GetOperation()==4 .AND. CDV->CDV_AUTO <> "1")) })
oStruCDV:SetProperty('CDV_ESPECI'	,MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 .OR. (oModel:GetOperation()==4 .AND. CDV->CDV_AUTO <> "1")) })
oStruCDV:SetProperty('CDV_FORMUL'	,MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 .OR. (oModel:GetOperation()==4 .AND. CDV->CDV_AUTO <> "1")) })

oModel:AddFields("CDVMASTER",/*cOwner*/,oStruCDV, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetPrimaryKey( { "CDV_FILIAL", "CDV_PERIOD", "CDV_CODAJU", "CDV_LIVRO", "CDV_DOC", "CDV_SERIE", "CDV_CLIFOR", "CDV_LOJA", "CDV_CFOP", "CDV_NUMITE"} )

Return(oModel)

//-------------------------------------
/*/{Protheus.doc}  ViewDef()
Definicao da View
@author  	Flavio Luiz Vicco
@version 	P11
@build		7.00.121227P
@since		29/01/2015
@return 	oView Objeto do View
/*/
//-------------------------------------
Static Function ViewDef()
Local oView    	:= Nil
Local oModel   	:= FwLoadModel("MATA017")
Local oStruCDV 	:= FWFormStruct( 2, "CDV")

oView:= FWFormView():New()
oView:SetModel(oModel)
oView:AddField( "VIEW_CDV", oStruCDV, "CDVMASTER")

//Ajuste do Título do campo CDV_DESCR
oStruCDV:SetProperty("CDV_DESCR", MVC_VIEW_TITULO, STR0011)  //"Descrição compl. do ajuste"

oStruCDV:RemoveField("CDV_ID")
oStruCDV:RemoveField("CDV_FILIAL")

Return(oView)

//-------------------------------------
/*/{Protheus.doc}  A017TudOk(oModel)
Validacao se ja existe Ajuste Informado para esse periodo
@author  	Flavio Luiz Vicco
@version 	P11
@build		7.00.121227P
@since		29/01/2015
@return 	lRet 
/*/
//-------------------------------------
Function A017TudOk(oModel)
Local aArea  	:= GetArea()
Local lRet      := .T.
Local nOp	  	:= oModel:GetOperation()
Local cCodAju   := oModel:GetValue("CDVMASTER","CDV_CODAJU"	)
Local cMvEstado := SuperGetMV("MV_ESTADO")
Local cErro		:= ""
Local nRecno    := CDV->(Recno())
Local nRecnoVld := 0

If (nOp == MODEL_OPERATION_INSERT) .OR. (nOp == MODEL_OPERATION_UPDATE)
	
	If (nRecnoVld := QryVld(oModel)) > 0
		If nOp == MODEL_OPERATION_UPDATE //Alteração
			If nRecnoVld <> nRecno
				Help(" ", 1, "JAGRAVADO")
				lRet := .F.
			EndIf
		Else
			Help(" ", 1, "JAGRAVADO")
			lRet := .F.
		EndIf
		//Volta Recno posicionado na tela
		CDV->(DbGoTo(nRecno))
	EndIf
	If	lRet .And. Substr(cCodAju,1,2) <> Alltrim(cMvEstado)
		lRet := .F.
		cErro := Chr(13) + Chr(10) + "UF do Cód. Ajuste: " + Substr(cCodAju,1,2) + Chr(13) + Chr(10) +"MV_ESTADO: "+ Alltrim(cMvEstado)
		Help(" ",1,"Help","Cód. Ajuste (CDV_CODAJU)",STR0008 + Chr(13) + Chr(10) + cErro,1,0,NIL, NIL, NIL, NIL, NIL, {"Utilizar Cód. Ajuste valido a UF Informada no MV_ESTADO"})//O codigo de apuracao selecionado nao refera a UF informada.
	EndIf
EndIf

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaHlp ºAutor  ³Luana Ferrari       º Data ³ 07/10/10    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ajusta help da rotina                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaHlp()
Local aHelpPor := {}
Local aHelpSpa := {}
Local aHelpEng := {}

//ÚÄÄÄÄÄÄÄÄ¿
//³Problema³
//ÀÄÄÄÄÄÄÄÄÙ
aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}

Aadd(aHelpPor,"O código de apuração selecionado não " )
Aadd(aHelpPor,"refere a UF informada")
aHelpSpa:= aHelpEng:= aHelpPor
PutHelp("PA017ESTAD",aHelpPor,aHelpEng,aHelpSpa,.T.)

//ÚÄÄÄÄÄÄÄ¿
//³Solucao³
//ÀÄÄÄÄÄÄÄÙ
aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
Aadd(aHelpPor,"Verifique a UF" )
aHelpSpa:= aHelpEng:= aHelpPor
PutHelp("SA017ESTAD",aHelpPor,aHelpEng,aHelpSpa,.T.)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PerValido  ³ Autor ³ Henrique Fabiano  ³ Data ³ 29.10.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Valida o período no formato AAAAMM                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PerValido(cAnoMes)
Local cAno := ""
Local cMes := ""
Local lRet := .T.

Default cAnoMes := ""

If !Empty(cAnoMes)
	cAno := Subs(cAnoMes,1,4)
	cMes := Subs(cAnoMes,5,2)
	If	(Len(AllTrim(cMes)) < 2 .Or. !(cMes >= "01"   .And. cMes <= "12"  )) .Or. ;
		(Len(AllTrim(cAno)) < 4 .Or. !(cAno >= "1900" .And. cAno <= "3000"))
		Help(,,"PERIODO",,"Por favor, informe um período valido!",1,0)
		lRet := .F.
	EndIf
EndIf

Return(lRet)


//Exibe valores calculados para Pedido de venda referente tabela 5.2 -Valores Declaratório
Function SHOWCDV(lVisual,lInclui)
Local aHeadCDV := {}
Local aColsCDV := {}
Local oDlg		:=	Nil

Private oLancCDV

If FindFunction("DicTabCDV")
	IF !DicTabCDV()
		Alert("Dicionário desatualizado, verifique tabela CDV - Valores Declaratórios")
		Return
	Endif
Else
	Return
Endif


SaveInter()

oDlg := MSDIALOG():New(000,000,340,600,"Valores Declaratório",,,,,,,,,.T.)
	
@ 155,258 Button "Sair" Size 037,012 PIXEL OF oDlg ACTION (nOpca := 1, oDlg:End())

oLancCDV := A017LAICMS(oDlg,{001,001,300,140},aHeadCDV,aColsCDV,lVisual,lInclui)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0,.F.)

RestInter()

Return oLancCDV


//Funcao para montagem do GETDADOS do folder de lancamentos fiscais
Static Function A017LAICMS(oDlg,aPos,aHeadCDV,aColsCDV,lVisual,lInclui)

Local	oLancCDV
Local	aCmps		:=	{}
Local	nI			:=	0
Local	aLAp		:=	A0170LancAp()
Local	cMaskVlr	:=	""
Local 	cMaskOut	:=  ""
Local	nPNUMITE	:=	0
Local	nPSEQ		:=	0
Local	nPCODLAN	:=	0
Local	nPVALOR		:=	0
Local	nDescr		:=	0
Local	nPVOut		:=  0
Local 	lVlOutr		:= CDV->(FieldPos("CDV_VLOUTR")) > 0
Local   aYesFields  := {"CDV_NUMITE","CDV_SEQ","CDV_CODAJU","CDV_VALOR","CDV_DESCR","CDV_ALI_WT","CDV_REC_WT"}
local   lGerAlp		:= .F.

If lVlOutr .And. Len(aLAp) > 0 .And. Len(aLAp[1]) > 20 
	lGerAlp := .T.
Endif 

If lGerAlp
	aAdd(aYesFields,"CDV_VLOUTR")
Endif

FillGetDados(2, "CDV", 1, /*cSeek*/, /*{|| &cWhile }*/, {||.T.}, /*aNoFields*/, aYesFields, /*lOnlyYes*/, /*cQuery*/, {||MontCols(aHeadCDV,.F., lGerAlp)},/* lInclui*/, aHeadCDV, aColsCDV) 

For nI := 1 To Len(aHeadCDV)
	aAdd(aCmps,aHeadCDV[nI,1])	
	
	If "CDV_VALOR"==AllTrim(aHeadCDV[nI,2])
		cMaskVlr	:=	AllTrim(aHeadCDV[nI,3])
	EndIf	
	If lGerAlp .And. "CDV_VLOUTR"==AllTrim(aHeadCDV[nI,2])
		cMaskOut	:=	AllTrim(aHeadCDV[nI,3])
	EndIf
	If nPNUMITE==0
		nPNUMITE	:=	Iif("CDV_NUMITE"$aHeadCDV[nI,2],nI,0)
	EndIf
	If nPSEQ==0
		nPSEQ		:=	Iif("CDV_SEQ"$aHeadCDV[nI,2],nI,0)
	EndIf
	If nPCODLAN==0
		nPCODLAN	:=	Iif("CDV_CODAJU"$aHeadCDV[nI,2],nI,0)
	EndIf
	If nPVALOR==0
		nPVALOR		:=	Iif("CDV_VALOR"$aHeadCDV[nI,2],nI,0)
	EndIf
	If nDescr==0
		nDescr	:=	Iif("CDV_DESCR"$aHeadCDV[nI,2],nI,0)
		If nDescr > 0
			aCmps[nI] := "Descrição"
		Endif
	EndIf	
	If lGerAlp .And. nPVOut==0
		nPVOut		:=	Iif("CDV_VLOUTR"$aHeadCDV[nI,2],nI,0)
	Endif	
Next nI

If Len(aLAp)==0
	aLAp	:=	{{"","","",0,0,0,"","","","","","","","","","",""}}	
EndIf

If lVlOutr .And. nPVOut > 0 .And. lGerAlp
	aLine	:=	{,,,,,}
Else
	aLine	:=	{,,,,}
Endif

aLine[nPNUMITE]	:=	"aLAp[oLancCDV:nAT,1]"
aLine[nPSEQ]	:=	"aLAp[oLancCDV:nAT,7]"
aLine[nPCODLAN]	:=	"aLAp[oLancCDV:nAT,2]"
aLine[nPVALOR]	:=	"Transform(aLAp[oLancCDV:nAT,6],cMaskVlr)"
aLine[nDescr]	:=	"aLAp[oLancCDV:nAT,17]"	

If lVlOutr .And. nPVOut > 0 .And. lGerAlp
	aLine[nPVOut]	:=	"Transform(aLAp[oLancCDV:nAT,21],cMaskOut)"
Endif

oLancCDV	:=	TWBrowse():New( aPos[1],aPos[2],aPos[3],aPos[4],,aCmps,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
oLancCDV:SetArray(aLAp)
If lVlOutr .And. nPVOut > 0 .And. lGerAlp
	oLancCDV:bLine := &("{|| {"+aLine[nPNUMITE]+","+aLine[nPSEQ]+","+aLine[nPCODLAN]+","+aLine[nPVALOR]+","+aLine[nPVOut]+","+aLine[nDescr]+"} }")
Else
	oLancCDV:bLine := &("{|| {"+aLine[nPNUMITE]+","+aLine[nPSEQ]+","+aLine[nPCODLAN]+","+aLine[nPVALOR]+","+aLine[nDescr]+"} }")
Endif
           

Return oLancCDV 


Function MontCols(aHeadCDV,lMT103, lGerAlp)
Local aSeqNewHdr := {}
Local aNoFields  := {"CDV_ALI_WT","CDV_REC_WT"}
Local aNewHeader := {}
Local nPosCpo    := 0
Local nX         := 0

Default lMT103  := .F.
Default lGerAlp := .F.

If lGerAlp

	aSeqNewHdr := {"CDV_NUMITE","CDV_SEQ","CDV_CODAJU","CDV_VALOR","CDV_VLOUTR","CDV_DESCR","CDV_ALI_WT","CDV_REC_WT"}

Else
	If lMT103
		aSeqNewHdr := {"CDV_NUMITE","CDV_SEQ","CDV_AUTO","CDV_CODAJU","CDV_VALOR","CDV_CFOP","CDV_LIVRO","CDV_DESCR"}
	Else
		aSeqNewHdr := {"CDV_NUMITE","CDV_SEQ","CDV_CODAJU","CDV_VALOR","CDV_DESCR","CDV_ALI_WT","CDV_REC_WT"}
	Endif	
Endif

IF lMT103
	For nX := 1 to Len(aNoFields)
		nPosCpo := aScan(aHeadCDV,{|x| AllTrim(x[2]) == aNoFields[nX]}) 
		If nPosCpo > 0
			aDel(aHeadCDV,nPosCpo)
			aSize(aHeadCDV,Len(aHeadCDV)-1)	
		Endif
	Next
	For nX := 1 to Len(aSeqNewHdr)
		nPosCpo := aScan(aHeadCDV,{|x| AllTrim(x[2]) == aSeqNewHdr[nX]}) 
		If nPosCpo > 0  
			aHeadCDV[nPosCpo,2] := Alltrim(aHeadCDV[nPosCpo,2])
		Endif
	Next
Endif

For nX := 1 to Len(aSeqNewHdr)
	nPosCpo := aScan(aHeadCDV,{|x| AllTrim(x[2]) == aSeqNewHdr[nX]}) 
	If nPosCpo > 0 
		If lMT103
			aHeadCDV[nPosCpo,6] := Iif(AllTrim(aHeadCDV[nPosCpo,2]) == "CDV_NUMITE","a017LCpIt().And.","")+"a017LCps()"
			aHeadCDV[nPosCpo,1] := Iif(AllTrim(aHeadCDV[nPosCpo,2]) == "CDV_DESCR","Descrição",aHeadCDV[nPosCpo,1])
			aHeadCDV[nPosCpo,1] := Iif(AllTrim(aHeadCDV[nPosCpo,2]) == "CDV_VALOR","Valor",aHeadCDV[nPosCpo,1])
		Endif
		aNewHeader := aClone(aHeadCDV[nPosCpo])
		aDel(aHeadCDV,nPosCpo)
		aSize(aHeadCDV,Len(aHeadCDV)-1)		
		aAdd(aHeadCDV,aClone(aNewHeader))
		
	EndIf
Next nX

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  a017AjuICM Autor ³ Gustavo G. Rueda      ³ Data ³13/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para atualizar o objeto do mata103 (TFOLDER) com as  ³±±
±±³          ³ informacoes referentes ao lancamento fiscal.               ³±±
±±³          ³                                                            ³±±
±±³          ³Chamada: MAFISALT da MATXFIS                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nZ -> Numero do item do documento fiscal.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function a017AjuICM(nZ)
Local nI            := 0
Local aGrava        := {}
Local cMvEstado     := SuperGetMV("MV_ESTADO")
Local nPosIt        := 0
Local nPosSeq       := 0
Local nPosCLan      := 0
Local nPosCSis      := 0
Local nPos          := 0
Local nPosX         := 0
Local cSeq          := "000"
Local aBkpaCls      := {}
Local lApagTudo     := .T.
Local aRetMaFisAjIt := {}
Local nJ            := 0
Local nTotalCols    := Len(oLancCDV:aHeader)
Local nRegCalc 		:= 0
Local nValOut  		:= 0
Local nCodObs  		:= 0
Local nCodOLan 		:= 0
Local nCodDes  		:= 0
Local nOpBase  		:= 0
Local nOpAliq  		:= 0
Local nAgrLan		:= 0
Local nR			:= 0


aRetMaFisAjIt	:=	MaFisAjIt(nZ)	
aGrava			:=	{}
//aGrava	:=	MaFisAjIt(nZ)

For nJ := 1 to Len(aRetMaFisAjIt)
	iF Len(aRetMaFisAjIt[nJ]) >= 14 .And. aRetMaFisAjIt[nJ,14] <> "4"
		Loop
	Endif
	aAdd(aGrava, aRetMaFisAjIt[nJ])				
Next nJ


If Len(aGrava)>0
	nPosIt	:=	aScan(oLancCDV:aHeader,{|aX|Alltrim(aX[2])=="CDV_NUMITE"})
	nPosSeq	:=	aScan(oLancCDV:aHeader,{|aX|Alltrim(aX[2])=="CDV_SEQ"})
	nPosCLan:=	aScan(oLancCDV:aHeader,{|aX|Alltrim(aX[2])=="CDV_CODAJU"})
	nPosCSis:=	aScan(oLancCDV:aHeader,{|aX|Alltrim(aX[2])=="CDV_AUTO"})

	IF lNewCdv
		nRegCalc := aScan( oLancCDV:aHeader, {|aX| aX[2] == "CDV_REGCAL" } )
		nValOut  := aScan( oLancCDV:aHeader, {|aX| aX[2] == "CDV_VLOUTR" } )
		nCodObs  := aScan( oLancCDV:aHeader, {|aX| aX[2] == "CDV_CODMSG" } )
		nCodOLan := aScan( oLancCDV:aHeader, {|aX| aX[2] == "CDV_CODCPL" } )
		nCodDes  := aScan( oLancCDV:aHeader, {|aX| aX[2] == "CDV_TXTDSC" } )
		nOpBase  := aScan( oLancCDV:aHeader, {|aX| aX[2] == "CDV_OPBASE" } )
		nOpAliq  := aScan( oLancCDV:aHeader, {|aX| aX[2] == "CDV_OPALIQ" } )
		nAgrLan  := aScan( oLancCDV:aHeader, {|aX| aX[2] == "CDV_AGRLAN" } )
	Endif

	If nPosIt>0 .And. nPosSeq>0 .And. nPosCLan>0 .And. nPosCSis>0
		For nI := Len(oLancCDV:aCols) To 1 Step -1
			If (!oLancCDV:aCols[nI,Len(oLancCDV:aCols[nI])] .And. ( MaFisRet(nZ,"IT_ITEM")==oLancCDV:aCols[nI,nPosIt] .And. oLancCDV:aCols[nI,nPosCSis] == '1' ) ) .Or.;
				(Empty(oLancCDV:aCols[nI,nPosIt]) .And. Len(oLancCDV:aCols)==1)
				aDel(oLancCDV:aCols,nI)
				aSize(oLancCDV:aCols,Len(oLancCDV:aCols)-1)
			EndIf
		Next nI

		If Len(oLancCDV:aCols)>0
			aBkpaCls	:=	aClone(oLancCDV:aCols)
			aSort(aBkpaCls,,,{|aX,aY| aX[nPosSeq]<aY[nPosSeq]})
			cSeq	:=	aBkpaCls[Len(aBkpaCls),nPosSeq]
		EndIf

		For nI := 1 To Len(aGrava)				
			cSeq	:=	Soma1(cSeq)
			nPos	:=	aScan(oLancCDV:aCols,{|aX| aX[nPosIt]==aGrava[nI,1] .And.;
													 aX[nPosCLan]==aGrava[nI,2] .And.;
													 aX[nPosCSis]==aGrava[nI,3] .And.;
													 aX[Len(oLancCDV:aHeader)+1]==.F.})
			If nPos>0
				nPosX	:=	aScan(oLancCDV:aHeader,{|aX|Alltrim(aX[2])=="CDV_VALOR"})
				oLancCDV:aCols[1,nPosX]	+=	aGrava[nI,6]

		
			Else
				//Novo campo criado pelo compatibilizador UPDFIS
					aAdd(oLancCDV:aCols,Iif(lNewCdv,array(17),array(9)))
					nR := len(oLancCDV:aCols)
					oLancCDV:aCols[nR,1] :=  aGrava[nI,1] //1 - Item
					oLancCDV:aCols[nR,2] :=  cSeq			
					oLancCDV:aCols[nR,3] :=  aGrava[nI,3] //Calc Sistema
					oLancCDV:aCols[nR,4] :=  aGrava[nI,2] //Codigo
					oLancCDV:aCols[nR,5] :=  aGrava[nI,6] //Valor
					oLancCDV:aCols[nR,6] :=  aGrava[nI,15]//CFOP
					oLancCDV:aCols[nR,7] :=  aGrava[nI,16]//Livro
					oLancCDV:aCols[nR,8] :=  aGrava[nI,17]//Descrição
					
					IF lNewCdv .and. Len(aGrava[nI]) > 17
						oLancCDV:aCols[nR,nCodDes]  :=  aGrava[nI,18] //
						oLancCDV:aCols[nR,nCodObs]  :=  aGrava[nI,19] //
						oLancCDV:aCols[nR,nCodOLan] :=  aGrava[nI,20] //
						oLancCDV:aCols[nR,nRegCalc] :=  aGrava[nI,22] //
						oLancCDV:aCols[nR,nValOut]  :=  aGrava[nI,21] //						
						oLancCDV:aCols[nR,nOpBase]  :=  aGrava[nI,23] //
						oLancCDV:aCols[nR,nOpAliq]  :=  aGrava[nI,24] //
						oLancCDV:aCols[nR,nAgrLan]  :=  aGrava[nI,25] //
					Endif

					oLancCDV:aCols[nR,nTotalCols + 1] := .F.

				EndIf
		Next nI
	EndIf
Else
	nPosIt	:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_NUMITE"})
	nPosCSis:=	aScan(oLancCDV:aHeader,{|aX|Alltrim(aX[2])=="CDV_AUTO"})

	If nPosIt>0
		For nI := Len(oLancCDV:aCols) To 1 Step -1
			If (oLancCDV:aCols[nI,nPosIt]== MaFisRet(nZ,"IT_ITEM") .And. oLancCDV:aCols[nI,nPosCSis] == '1' ) .Or.;
				(Empty(oLancCDV:aCols[nI,nPosIt]) .And. Len(oLancCDV:aCols)==1)
				aDel(oLancCDV:aCols,nI)
				aSize(oLancCDV:aCols,Len(oLancCDV:aCols)-1)
			Else
				lApagTudo	:=	.F.
			EndIf
		Next nI

		If lApagTudo
			oLancCDV:aCols:=	{Array(Len(oLancCDV:aHeader)+1)}
			oLancCDV:aCols[1,Len(oLancCDV:aHeader)+1]:=	.F.

			For nI := 1 To Len(oLancCDV:aHeader)
				If oLancCDV:aHeader[nI,10]#"V"
					oLancCDV:aCols[1,nI]	:=	CriaVar(oLancCDV:aHeader[nI,2])
				EndIf
				If "_SEQ"$oLancCDV:aHeader[nI,2]
					oLancCDV:aCols[1,nI]	:=	StrZero(1,oLancCDV:aHeader[nI,4])
				EndIf
			Next
		EndIf
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  a017GrvCDV Autor ³ Gustavo G. Rueda      ³ Data ³13/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de gravacao/exclusao das informacoes do documento    ³±±
±±³          ³ fiscal referente ao lancamento fiscal da apuracao de icms. ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lExclui -> Flag que indica exclusao do registro.            ³±±
±±³          ³cTipMov -> (E)nttrada ou (S)aida                            ³±±
±±³          ³cEspecie -> Especie do documento fiscal para montar a chave.³±±
±±³          ³cFormul -> Indicador de formulario proprio (S)im/(N)ao para ³±±
±±³          ³ montar a chave.                                            ³±±
±±³          ³cNFiscal -> Numero da nota fiscal para montar a chave.      ³±±
±±³          ³cSerie -> Serie do documento fiscal para montar a chave.    ³±±
±±³          ³cForn -> Codigo do fornecedor para montar a chave.          ³±±
±±³          ³cLoja -> Codigo da loja do fornecedor para montar a chave.  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function a017GrvCDV(lExclui,cTipMov,cEspecie,cFormul,cNFiscal,cSerie,cForn,cLoja,aInfApurICMS,cOrigem,nValDesp,cCfop)
Local lRet	:=	.T.
Local aArea	:=	GetArea()
Local nI		:=	0
Local nPosIte	:=	0
Local nPosSeq	:=	0
Local nTamCDVNu := Iif(CDV->(FieldPos("CDV_NUMITE")) > 0 , TamSx3("CDV_NUMITE")[1],0)
Local nTamCDVNt := Iif(CDV->(FieldPos("CDV_DOC")) > 0 , TamSx3("CDV_DOC")[1],0)
Local nTamCDVSr := Iif(CDV->(FieldPos("CDV_SERIE")) > 0 , TamSx3("CDV_SERIE")[1],0)
Local nTamCDVEs := Iif(CDV->(FieldPos("CDV_ESPECI")) > 0 , TamSx3("CDV_ESPECI")[1],0)
Local cSerId   := ""
Local lAuto920 :=  (Type("l920Auto") <> "U" .And. (l920Auto))
Local lAuto116 :=  (Type("l116Auto") <> "U" .And. (l116Auto))
Local lAuto103 :=  (Type("l103Auto") <> "U" .And. (l103Auto))
Local aRetMaFisAjIt
Local nJ
Local nPosAuto

Local cNumItem 	 := ""
Local cCodLan	 := ""
Local cCalPro	 :=	""
Local nBase	 	 :=	0
Local nAliq	 	 :=	0
Local nValor	 :=	0
Local cNumSeq	 := ""
Local cIFCOMP	 := ""
Local cTPLanc	 :=	""
Local cCmp0460   := ""
Local cCodRef    := ""
Local cGuia	 	 := ""
Local cCodOrig 	 := ""
Local cLivro	 := ""
Local CDescr	 := ""
Local lCampos    := Iif(CDV->(FieldPos("CDV_NFE")) > 0 .And. CDV->(FieldPos("CDV_ZERAVL")) > 0, .T., .F.)
Local aCampos	 := {}
Local lMATA119  := .F. 
Local cNUMITE_1	:=	""
Local cSEQ_1    :=	""						
Local cCODAJU_1	:=	""
Local cAUTO_1   :=	""
Local cLIVRO_1	:=	""
Local cDESCR_1	:=	""
Local cCodDes	:= ""
Local cCodObs	:= ""
Local cCodOLan	:= ""
Local nValOut	:= 0
Local cRegCalc	:= ""
Local cOpBase	:= ""
Local cOpAliq	:= ""
Local cAgrLan   := ""
						      
Default aInfApurICMS := {}
Default cOrigem := ""
Default cCfop   := ""
Default nValDesp:= 0

lMATA119 := Iif(cOrigem = 'MATA119', .T.,.F.)


If FindFunction("DicTabCDV")
	IF !DicTabCDV()
		Alert("Dicionário desatualizado, verifique tabela CDV - Valores Declaratórios")
		Return
	Endif
Else
	Return
Endif

//Ajusta quando numero da nota for menor que tamanho do campo F1_DOC
cNFiscal	:= Padr(cNFiscal,TamSX3("F1_DOC")[1])

If cTipMov == "E"
	cSerId := SerieNfId("SF1",4,"F1_SERIE",dDEmissao,cEspecie,cSerie)
Else
	cSerId := SerieNfId("SF2",4,"F2_SERIE",d920Emis,cEspecie,cSerie)
EndIf

cFormul	:=	IIF(cFormul=="S","S"," ")

If lAuto103 .or. lAuto920 .or. lMATA119
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gerando informacoes dos lanctos da apuracao de ICMS  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRetMaFisAjIt := MaFisAjIt(,2)
	
	For nJ := 1 to Len(aRetMaFisAjIt)
		iF Len(aRetMaFisAjIt[nJ]) >= 14 .And. aRetMaFisAjIt[nJ,14] <> "4"
			Loop
		Endif
		aAdd(aInfApurICMS, {})
		nPosAuto :=	Len (aInfApurICMS)
		aAdd (aInfApurICMS[nPosAuto], aRetMaFisAjIt[nJ])
	Next nJ
	
EndIf

If Type("oLancCDV")= "O" .Or. lAuto116 .OR. lAuto103 .or. lAuto920 .or. lMATA119

	dbSelectArea("CDV")
	CDV->(dbSetOrder(4))

	If lExclui
		If CDV->(MsSeek(xFilial("CDV")+cTipMov+cEspecie+cFormul+cNFiscal+cSerId+cForn+cLoja))
			While !CDV->(Eof()) .And.;
				xFilial("CDV")+cTipMov+cEspecie+cFormul+cNFiscal+cSerId+cForn+cLoja==;
				CDV->(CDV_FILIAL+CDV_TPMOVI+CDV_ESPECI+CDV_FORMUL+CDV_DOC+CDV_SERIE+CDV_CLIFOR+CDV_LOJA)

				RecLock("CDV",.F.)
				CDV->(dbDelete())
				MsUnLock()
				CDV->(FkCommit())
				CDV->(dbSkip())
			End
		EndIf
	Else
		If lAuto116 .OR. lAuto103 .or. lAuto920 .or. lMATA119
			If Len(aInfApurICMS) > 0
				For nI := 1 To Len(aInfApurICMS)
					If Empty(aInfApurICMS[nI][1][2])
						Loop
					EndIf

					cNumItem :=	aInfApurICMS[nI][1][1]
					cCodLan	 := aInfApurICMS[nI][1][2]
					cCalPro	 :=	aInfApurICMS[nI][1][3]
					nBase	 :=	aInfApurICMS[nI][1][4]
					nAliq	 :=	aInfApurICMS[nI][1][5]
					nValor	 :=	aInfApurICMS[nI][1][6]
					cNumSeq	 := aInfApurICMS[nI][1][7]
					cIFCOMP	 := aInfApurICMS[nI][1][8]
					cTPLanc	 :=	aInfApurICMS[nI][1][9]
					cCmp0460 := aInfApurICMS[nI][1][11]
					cCodRef  := aInfApurICMS[nI][1][12]
					cGuia	 := aInfApurICMS[nI][1][13]
					cCodOrig := aInfApurICMS[nI][1][14]
					cCfop	 := aInfApurICMS[nI][1][15]
					cLivro	 := aInfApurICMS[nI][1][16]
					CDescr	 := aInfApurICMS[nI][1][17]

					IF lNewCdv
						cCodDes  := aInfApurICMS[nI][1][18]
						cCodObs  := aInfApurICMS[nI][1][19]
						cCodOLan := aInfApurICMS[nI][1][20]
						nValOut  := aInfApurICMS[nI][1][21]
						cRegCalc := aInfApurICMS[nI][1][22]						
						cOpBase  := aInfApurICMS[nI][1][23]
						cOpAliq  := aInfApurICMS[nI][1][24]
						cAgrLan	 := aInfApurICMS[nI][1][25]
					Endif
					

					If CDV->(MsSeek(xFilial("CDV")+cTipMov+Padr(cEspecie,5)+cFormul+PadR(cNFiscal,9)+Padr(cSerie,3)+cForn+cLoja+PadR(cNumItem,nTamCDVNu)+cNumSeq))
						RecLock("CDV",.F.)
					Else
						RecLock("CDV",.T.)
						CDV->CDV_FILIAL	:=	xFilial("CDV")
						CDV->CDV_TPMOVI	:=	cTipMov
						CDV->CDV_ESPECI	:=	cEspecie
						CDV->CDV_FORMUL	:=	cFormul
						CDV->CDV_DOC	:=	cNFiscal
						SerieNfId("CDV",1,"CDV_SERIE",Iif( cTipMov == "E" , dDEmissao , d920Emis ) ,cEspecie,cSerie)
						//CDV->CDV_SERIE	:=	cSerie
						CDV->CDV_CLIFOR	:=	cForn
						CDV->CDV_LOJA	:=	cLoja
						CDV->CDV_NUMITE	:=	cNumItem
						CDV->CDV_SEQ	:=	cNumSeq
					EndIf

					CDV->CDV_CODAJU	:=	cCodLan
					CDV->CDV_AUTO	:=	cCalPro
					CDV->CDV_VALOR	:=	nValor
					CDV->CDV_CFOP	:=	cCfop					
					CDV->CDV_LIVRO	:=	cLivro
					CDV->CDV_DESCR	:=	CDescr
					CDV->CDV_ID		:=	FWUUID("FISA140")
					If lCampos
						aCampos := RetInfCDY(cCodLan)
						CDV->CDV_NFE    := aCampos[1,1]
						CDV->CDV_ZERAVL := aCampos[1,2]
					EndIf
					IF lNewCdv
						CDV->CDV_REGCAL := cRegCalc  
						CDV->CDV_VLOUTR := nValOut  
						CDV->CDV_CODMSG := cCodObs 
						CDV->CDV_CODCPL := cCodOLan  
						CDV->CDV_TXTDSC := cCodDes 					
						CDV->CDV_OPBASE := cOpBase  
						CDV->CDV_OPALIQ := cOpAliq 
						CDV->CDV_AGRLAN := cAgrLan
					Endif

					MsUnLock()
					CDV->(FkCommit())
				Next nI
			ElseIf lMATA119
				//Grava CDV quando houver Nota Fisca para Despesa de importação
			    If CDV->(MsSeek(xFilial("CDV")+"E"+Padr(SF1->F1_ESPECIE,5)+SF1->F1_FORMUL+PadR(SF1->F1_DOC,9)+Padr(SF1->F1_SERIE,3)+SF1->F1_FORNECE + SF1->F1_LOJA))
						While !CDV->(Eof()) .And.;
					          CDV->(CDV_FILIAL+CDV_TPMOVI+CDV_ESPECI+CDV_FORMUL+CDV_DOC+CDV_SERIE+CDV_CLIFOR+CDV_LOJA)==;
					          xFilial("CDV")+"E"+Padr(SF1->F1_ESPECIE,5)+SF1->F1_FORMUL+PadR(SF1->F1_DOC,9)+Padr(SF1->F1_SERIE,3)+SF1->F1_FORNECE + SF1->F1_LOJA

							  cNUMITE_1	:=	CDV->CDV_NUMITE
						      cSEQ_1	:=	CDV->CDV_SEQ						
						      cCODAJU_1	:=	CDV->CDV_CODAJU
						      cAUTO_1	:=	CDV->CDV_AUTO
						      cLIVRO_1  :=	CDV->CDV_LIVRO
						      cDESCR_1	:=	CDV->CDV_DESCR				
						      
							  RecLock("CDV",.T.)
						      CDV->CDV_FILIAL	:=	xFilial("CDV")
						      CDV->CDV_TPMOVI	:=	cTipMov
						      CDV->CDV_ESPECI	:=	cEspecie
						      CDV->CDV_FORMUL	:=	cFormul
						      CDV->CDV_DOC	    :=	cNFiscal
						      SerieNfId("CDV",1,"CDV_SERIE",Iif( cTipMov == "E" , dDEmissao , d920Emis ) ,cEspecie,cSerie)
							  //CDV->CDV_SERIE    :=  cSerie 
						      CDV->CDV_CLIFOR	:=	cForn
						      CDV->CDV_LOJA	    :=	cLoja
						      CDV->CDV_NUMITE	:=	cNUMITE_1
						      CDV->CDV_SEQ	    :=	cSEQ_1						
						      CDV->CDV_PERIOD	:=	SubStr(DtoS(dDEmissao),1,6)
						      CDV->CDV_CODAJU	:=	cCODAJU_1
						      CDV->CDV_AUTO	    :=	cAUTO_1
						      CDV->CDV_VALOR	:=	nValDesp
						      CDV->CDV_CFOP	    :=	cCfop					
						      CDV->CDV_LIVRO	:=	cLIVRO_1
						      CDV->CDV_DESCR	:=	cDESCR_1
						      CDV->CDV_ID		:=	FWUUID("FISA140")
							  MsUnLock()
							  CDV->(FkCommit())
						End
						CDV->(dbSkip())
				Endif
			Endif
		Else
			For nI := 1 To Len(oLancCDV:aCols)
				If oLancCDV:aCols[nI,Len(oLancCDV:aCols[nI])]
					Loop
				EndIf

				nPos:=	aScan(oLancCDV:aHeader,{|aX|Alltrim(aX[2])=="CDV_CODAJU"})
				cCodLan	:=	oLancCDV:aCols[nI,nPos]
				If Empty(cCodLan)
					Loop
				EndIf

				//"CDV_NUMITE","CDV_SEQ","CDV_AUTO","CDV_CODAJU","CDV_VALOR","CDV_CFOP","CDV_LIVRO","CDV_DESCR"

				nPos:=	aScan(oLancCDV:aHeader,{|aX|Alltrim(aX[2])=="CDV_NUMITE"})
				cNumItem:=	oLancCDV:aCols[nI,nPos]

				nPos:=	aScan(oLancCDV:aHeader,{|aX|Alltrim(aX[2])=="CDV_SEQ"})
				cNumSeq	:=	oLancCDV:aCols[nI,nPos]

				nPos:=	aScan(oLancCDV:aHeader,{|aX|Alltrim(aX[2])=="CDV_AUTO"})
				cCalPro	:=	oLancCDV:aCols[nI,nPos]

				nPos:=	aScan(oLancCDV:aHeader,{|aX|Alltrim(aX[2])=="CDV_VALOR"})
				nValor	:=	oLancCDV:aCols[nI,nPos]

				nPos:=	aScan(oLancCDV:aHeader,{|aX|Alltrim(aX[2])=="CDV_CFOP"})
				cCfop :=	Iif(nPos==0,"",oLancCDV:aCols[nI,nPos])

				nPos:=	aScan(oLancCDV:aHeader,{|aX|Alltrim(aX[2])=="CDV_LIVRO"})
				cLivro :=	Iif(nPos==0,"",oLancCDV:aCols[nI,nPos])

				nPos:=	aScan(oLancCDV:aHeader,{|aX|Alltrim(aX[2])=="CDV_DESCR"})
				CDescr :=	Iif(nPos==0,"",oLancCDV:aCols[nI,nPos])

				If lNewCdv
					nPos:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_REGCAL"})
					cRegCalc :=	Iif(nPos==0,"",oLancCDV:aCols[nI,nPos])	

					nPos:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_VLOUTR"})
					nValOut :=	Iif(nPos==0,0,oLancCDV:aCols[nI,nPos])				

					nPos:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_CODMSG"})
					cCodObs :=	Iif(nPos==0,"",oLancCDV:aCols[nI,nPos])

					nPos:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_CODCPL"})
					cCodOLan :=	Iif(nPos==0,"",oLancCDV:aCols[nI,nPos])

					nPos:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_TXTDSC"})
					cCodDes :=	Iif(nPos==0,"",oLancCDV:aCols[nI,nPos])

					nPos:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_OPBASE"})
					cOpBase :=	Iif(nPos==0,"",oLancCDV:aCols[nI,nPos])

					nPos:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_OPALIQ"})
					cOpAliq :=	Iif(nPos==0,"",oLancCDV:aCols[nI,nPos])

					nPos:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_AGRLAN"})
					cAgrLan :=	Iif(nPos==0,"",oLancCDV:aCols[nI,nPos])

				Endif

				If CDV->(MsSeek(xFilial("CDV")+cTipMov+Padr(cEspecie,nTamCDVEs)+cFormul+PadR(cNFiscal,nTamCDVNt)+Padr(cSerie,nTamCDVSr)+cForn+cLoja+PadR(cNumItem,nTamCDVNu)+cNumSeq))
					RecLock("CDV",.F.)
				Else
					RecLock("CDV",.T.)
						CDV->CDV_FILIAL	:=	xFilial("CDV")
						CDV->CDV_TPMOVI	:=	cTipMov
						CDV->CDV_ESPECI	:=	cEspecie
						CDV->CDV_FORMUL	:=	cFormul
						CDV->CDV_DOC	:=	cNFiscal
						SerieNfId("CDV",1,"CDV_SERIE",Iif( cTipMov == "E" , dDEmissao , d920Emis ) ,cEspecie,cSerie)
						CDV->CDV_CLIFOR	:=	cForn
						CDV->CDV_LOJA	:=	cLoja
						CDV->CDV_NUMITE	:=	cNumItem
						CDV->CDV_SEQ	:=	cNumSeq						
						CDV->CDV_PERIOD	:=	Iif( cTipMov == "E" , SubStr(DtoS(dDEmissao),1,6) , SubStr(DtoS(d920Emis),1,6))
				EndIf				
				CDV->CDV_CODAJU	:=	cCodLan
				CDV->CDV_AUTO	:=	cCalPro
				CDV->CDV_VALOR	:=	nValor
				CDV->CDV_CFOP	:=	cCfop					
				CDV->CDV_LIVRO	:=	cLivro
				CDV->CDV_DESCR	:=	CDescr
				CDV->CDV_ID		:=	FWUUID("FISA140")
				
				If lCampos
					aCampos := RetInfCDY(cCodLan)
					CDV->CDV_NFE    := aCampos[1,1]
					CDV->CDV_ZERAVL := aCampos[1,2]
				EndIf
				IF lNewCdv
					CDV->CDV_REGCAL := cRegCalc  
					CDV->CDV_VLOUTR := nValOut  
					CDV->CDV_CODMSG := cCodObs 
					CDV->CDV_CODCPL := cCodOLan  
					CDV->CDV_TXTDSC := cCodDes 					
					CDV->CDV_OPBASE := cOpBase  
					CDV->CDV_OPALIQ := cOpAliq  
					CDV->CDV_AGRLAN := cAgrLan
				Endif

				MsUnLock()
				CDV->(FkCommit())
			Next nI

			//Tratamento para deletar os registros que nao foram reaproveitados acima no caso de reutilizacao de numeracao de nota
			If CDV->(MsSeek(xFilial("CDV")+cTipMov+cEspecie+cFormul+cNFiscal+cSerId+cForn+cLoja))
				nPosIte:=	aScan(oLancCDV:aHeader,{|aX|Alltrim(aX[2])=="CDV_NUMITE"})
				nPosSeq:=	aScan(oLancCDV:aHeader,{|aX|Alltrim(aX[2])=="CDV_SEQ"})
				While !CDV->(Eof()) .And.;
					CDV->(CDV_FILIAL+CDV_TPMOVI+CDV_ESPECI+CDV_FORMUL+CDV_DOC+CDV_SERIE+CDV_CLIFOR+CDV_LOJA)==;
					xFilial("CDV")+cTipMov+cEspecie+cFormul+cNFiscal+cSerId+cForn+cLoja

					If aScan(oLancCDV:aCols,{|aX|PadR(aX[nPosIte],TamSx3("CDV_NUMITE")[1])==CDV->CDV_NUMITE .And. aX[nPosSeq]==CDV->CDV_SEQ})==0
						RecLock("CDV",.F.)
						dbDelete()
						MsUnLock()
						CDV->(FkCommit())
					EndIf

					CDV->(dbSkip())
				End
			EndIf
		Endif
	EndIf
EndIf

RestArea(aArea)
Return lRet



//-------------------------------------------------------------------



//-------------------------------------------------------------------
//Entrada
Function MT103CDV(lShow)

If lShow
	oLancApICMS:Hide ( )	
	oLancCDV:show ( )	
Else	
	oLancCDV:Hide ( )
	oLancApICMS:Show ( )
Endif

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  a017xLAICMS Autor ³ Gustavo G. Rueda      ³ Data ³05/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para montagem do GETDADOS do folder de lancamentos   ³±±
±±³          ³ fiscais.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³oLancApICMS -> Objeto criado pelo MSNEWGETDADOS             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oDlg -> Objeto pai onde o GETDADOS serah criado.            ³±±
±±³          ³aPos -> posicoes de criacao do objeto.                      ³±±
±±³          ³aHeadCDV -> array com o HEADER da tabela CDV                ³±±
±±³          ³aColsCDV -> array com o ACOLS da tabela CDV                 ³±±
±±³          ³lVisual -> Flag de visualizacao                             ³±±
±±³          ³lInclui -> Flag de inclusao                                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function a017xLAICMS(oDlg,aPos,aHeadCDV,aColsCDV,lVisual,lInclui,cAlias,cRotina)
Local oLancCDV
Local aColsBkp := {}
Local bCond		:=	{||.T.}
Local bSkip     := {||.F.}
Local cVisual		:=	Iif(lVisual,"'1'","'2'")
Local cFormulBkp	:=	""
Local aYesFields	:=	{"CDV_NUMITE","CDV_SEQ","CDV_AUTO","CDV_CODAJU","CDV_VALOR","CDV_CFOP","CDV_LIVRO","CDV_DESCR"}
Local aYesUsado		:=	{"CDV_AUTO","CDV_LIVRO"}
Local aNoFields		:=	{"CDV_FILIAL","CDV_PERIOD","CDV_DOC","CDV_SERIE","CDV_CLIFOR","CDV_LOJA","CDV_SDOC","CDV_TPMOVI","CDV_ID","CDV_ESPECI","CDV_FORMUL"}
Local cSerieId  := ""
Local aArea		:= {}
//SaveInter()

Default cAlias := "SD1"
Default cRotina := ""

If !DicTabCDV()	
	return
Endif
If lNewCdv
	aAdd(aYesFields,"CDV_VLOUTR")
	aAdd(aYesFields,"CDV_TXTDSC")
	aAdd(aYesFields,"CDV_CODCPL")
	aAdd(aYesFields,"CDV_CODMSG")
	aAdd(aYesFields,"CDV_REGCAL")
	aAdd(aYesFields,"CDV_OPBASE")
	aAdd(aYesFields,"CDV_OPALIQ")
	aAdd(aYesFields,"CDV_AGRLAN")
Endif

aArea		:= GetArea()
//FillGetDados(4, "CDV", 1, /*cSeek*/, /*{|| &cWhile }*/, {||.T.},/*aNoFields*/,aYesFields, /*lOnlyYes*/, /*cQuery*/, {||MontCols(aHeadCDV,.T.)},/* lInclui*/, aHeadCDV, aColsCDV,/*bAfterCols*/,/*bBeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/,/*bCriaVar*/,/*lUserFields*/,aYesUsado) 
aMHead("CDV",aYesFields,@aHeadCDV)
If cAlias == "SD1"
	cFormulBkp	:=	cFormul
	cSerieId  := SerieNfId("SD1",4,"D1_SERIE",dDEmissao,cEspecie,cSerie)
	If lVisual
		dbSelectArea("CDV")
		CDV->(dbSetOrder(4))
		If !CDV->(msSeek(xFilial("CDV")+"E"+cEspecie+cFormul+cNFiscal+cSerieId+cA100For+cLoja)) .And. cFormul=="N"	//tratamento implementado devido ao default do mata103 para o cformul ser "N", porem as tabelas para N podem gravar branco ou N.
			cFormul	:=	" "
		CDV->(msSeek(xFilial("CDV")+"E"+cEspecie+cFormul+cNFiscal+cSerieId+cA100For+cLoja))
		EndIf
		bCond	:=	{||xFilial("CDV")+"E"+cEspecie+cFormul+cNFiscal+cSerieId+cA100For+cLoja==CDV->(CDV_FILIAL+CDV_TPMOVI+CDV_ESPECI+CDV_FORMUL+CDV_DOC+CDV_SERIE+CDV_CLIFOR+CDV_LOJA)}
	EndIf
Else	
	If lVisual			
		dbSelectArea("CDV")
		CDV->(dbSetOrder(4))
		CDV->(MsSeek(xFilial("CDV")+"S"+c920Especi+"S"+c920Nota+c920Serie+c920Client+c920Loja))
		bCond	:=	{||xFilial("CDV")+"S"+c920Especi+"S"+c920Nota+c920Serie+c920Client+c920Loja==CDV->(CDV_FILIAL+CDV_TPMOVI+CDV_ESPECI+CDV_FORMUL+CDV_DOC+CDV_SERIE+CDV_CLIFOR+CDV_LOJA)}
	EndIf
Endif
aMAcols(lVisual,"CDV",@aColsCDV,aHeadCDV,bCond,bSkip,cRotina)

oLancCDV	:=	MsNewGetDados():New(aPos[1],aPos[2],aPos[4],aPos[3]-45,Iif(lVisual,0,GD_UPDATE+GD_INSERT+GD_DELETE),"a017LOk","a017LOk","+CDV_SEQ",aYesFields,/*freeze*/,9999,/*fieldok*/,/*superdel*/,"a017LDel("+cVisual+")",oDlg,@aHeadCDV,@aColsCDV)	
oLancCDV:Hide ( )

If cAlias == "SD1"
	cFormul	:=	cFormulBkp
Endif

@ aPos[1],aPos[3]-45 BUTTON STR0007 SIZE 45,11 FONT oDlg:oFont ;
ACTION MT103CDV(.F.) OF oDlg PIXEL

//RestInter()
RestArea(aArea)

Return oLancCDV

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³aMHead    ³ Autor ³ Gustavo G. Rueda      ³ Data ³05/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para montagem do HEADER do GETDADOS                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias da tabela base para montagem do HEADER      ³±±
±±³          ³cNCmps -> Campos que nao serao considerados no HEADER       ³±±
±±³          ³aH -> array no qual o HEADER serah montado                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function aMHead(cAlias,aNCmps,aH)
Local lRet	:=	.T.
Local cValid	:=	""
Local cValid	:=	""
Local nX 	    := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a Integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(2)
//dbSeek(cAlias)
For nX := 1 to len(aNCmps)
	dbSeek(aNCmps[nX])
	If AllTrim(X3_CAMPO)=="CDV_NUMITE"
		cValid	:=	"a017LCpIt().And.a017LCps()"
	Else
		cValid	:=	AllTrim(X3_VALID)+Iif(Empty(AllTrim(X3_VALID)),"",".And.")+"a017LCps()"
	EndIf

	AADD(aH,{ Trim(X3Titulo()), ;
		AllTrim(X3_CAMPO),;
		X3_PICTURE,;
		X3_TAMANHO,;
		X3_DECIMAL,;
		cValid,;
		X3_USADO,;
		X3_TIPO,;
		X3_F3,;
		X3_CONTEXT,;
		X3_CBOX,;
		X3_RELACAO})
Next

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³aMAcols   ³ Autor ³ Gustavo G. Rueda      ³ Data ³05/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para montagem do ACOLS do GETDADOS                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpc -> Opcao do AROTINA                                    ³±±
±±³          ³cAlias -> Alias da tabela base para montagem do HEADER      ³±±
±±³          ³aC -> array no qual o ACOLS serah montado                   ³±±
±±³          ³aH -> array no qual o HEADER serah montado                  ³±±
±±³          ³bCond -> Condicao de loop do while                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function aMAcols(lVisual,cAlias,aC,aH,bCond,bSkip,cRotina)
Local	lRet	:=	.T.
Local	nI		:=	0

DEFAULT bSkip 	:= {|| .F. }

dbSelectArea(cAlias)
dbSetOrder(4)
If cRotina ==""
	If lVisual .And. !Eof()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o array aCols com os itens                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aC	:=	{}
		While !Eof() .And. Eval(bCond)
			IF Eval(bSkip)
				dbSkip()
				Loop
			EndIf
			aAdd(aC,Array(Len(aH)+1))
			For nI := 1 To Len(aH)
				aC[Len(aC),nI] := FieldGet(FieldPos(aH[nI,2]))
			Next
			aC[Len(aC),Len(aH)+1] := .F.
			dbSkip()
		End	
	Else
		aC				:=	{Array(Len(aH)+1)}
		aC[1,Len(aH)+1]	:=	.F.
		For nI := 1 To Len(aH)
			If aH[nI,10]#"V"
				aC[1,nI]	:=	CriaVar(aH[nI,2])
			EndIf

			If "_SEQ"$aH[nI,2]
				aC[1,nI]	:=	StrZero(1,aH[nI,4])
			EndIf
		Next	
	EndIf
ElseIf cRotina == "MATA920"
	If lVisual 
		If !Eof()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta o array aCols com os itens                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aC	:=	{}
			While !Eof() .And. Eval(bCond)
				IF Eval(bSkip)
					dbSkip()
					Loop
				EndIf
				aAdd(aC,Array(Len(aH)+1))
				For nI := 1 To Len(aH)
					aC[Len(aC),nI] := FieldGet(FieldPos(aH[nI,2]))
				Next
				aC[Len(aC),Len(aH)+1] := .F.
				dbSkip()
			End	
		ElseIf  Len(aColsD2)>1
			For nI := 1 To Len(aColsD2)
				
			Next nI
		EndIf
	Else
		aC				:=	{Array(Len(aH)+1)}
		aC[1,Len(aH)+1]	:=	.F.
		For nI := 1 To Len(aH)
			If aH[nI,10]#"V"
				aC[1,nI]	:=	CriaVar(aH[nI,2])
			EndIf

			If "_SEQ"$aH[nI,2]
				aC[1,nI]	:=	StrZero(1,aH[nI,4])
			EndIf
		Next	
	EndIf
EndIf
Return lRet

//Funcao para montar os lancamento fiscais para exibicao 
Static Function A0170LancAp()
Local	aRetMaFisAjIt := MaFisAjIt(,2)
Local	aLancAp	:=	{}
Local	nJ	:= 0

For nJ := 1 to Len(aRetMaFisAjIt)
	iF Len(aRetMaFisAjIt[nJ]) >= 14 .And. aRetMaFisAjIt[nJ,14] <> "4"
		Loop
	Endif
	aAdd(aLancAp, aRetMaFisAjIt[nJ])		
Next nJ

Return aLancAp  

//-------------------------------------------------------------------


//-------------------------------------------------------------------


Function a017LDel(cVisual)
Local	lRet	:=	.T.
Local	nPosCalc:=	0
Local	nPosIt	:=	0
Local 	nPosItD2:= 	0
Local	nPos	:=	0

If Type("oLancCDV")=="O" .And. cVisual=="2"
	nPosCalc:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_AUTO"})
	nPosIt	:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_NUMITE"})
	
	If nPosCalc>0 .And. oLancCDV:aCols[oLancCDV:nAT,nPosCalc]=="1"
		//Registros calculados pelo sistema não poderão ser excluídos, pois serão utilizados como log da rotina.
		//Caso seja necessário alterar este cálculo, basta inserir novos itens nesta opção de ajuste ou utitlizar a funcionalidade de Gerenciamento dos Lançamentos Fiscais de ICMS. Vale ressaltar que na Apuração de ICMS será considerada a sequência maior de cada lançamento fiscal do documento.
		Help("  ",1,"LAICMSDEL1")	
		lRet	:=	.F.
	
	ElseIf nPosCalc>0 .And. oLancCDV:aCols[oLancCDV:nAT,nPosCalc]=="2" .And. Type("aColsD2")=="A" .And. Type("aHeadD2")="A"
		nPosItD2:= 	aScan(aHeadD2,{|aX| aX[2]==PadR("D2_ITEM",Len(SX3->X3_CAMPO))})

		If nPosItD2>0 .And. nPosIt>0
			nPos	:=	aScan(aColsD2,{|aX|PadR(aX[nPosItD2],TamSx3("CDV_NUMITE")[1])==oLancCDV:aCols[oLancCDV:nAT,nPosIt].And.!aX[Len(aColsD2[1])]})
			If nPos==0 .And. !Empty(oLancCDV:aCols[oLancCDV:nAT,nPosIt])
				//Este registro não pode ser recuperado, pois o mesmo encontra-se excluído juntamente com seu respectivo item do documento fiscal.
				//Para se recuperar este registro é necessário que se tenha o respectivo item deste documento fiscal ativado.
				Help("  ",1,"LAICMSDEL2")
				lRet	:=	.F.
			EndIf
		EndIf
	ElseIf nPosCalc>0 .And. oLancCDV:aCols[oLancCDV:nAT,nPosCalc]=="2" .And. Type("aColsD1")=="A" .And. Type("aHeadD1")="A"
		nPosItD1:= 	aScan(aHeadD1,{|aX| aX[2]==PadR("D1_ITEM",Len(SX3->X3_CAMPO))})	
		
		If nPosItD1>0 .And. nPosIt>0
			nPos	:=	aScan(aColsD1,{|aX|PadR(aX[nPosItD1],TamSx3("CDV_NUMITE")[1])==oLancCDV:aCols[oLancCDV:nAT,nPosIt].And.!aX[Len(aColsD1[1])]})
			If nPos==0
				//Este registro não pode ser recuperado, pois o mesmo encontra-se excluído juntamente com seu respectivo item do documento fiscal.
				//Para se recuperar este registro é necessário que se tenha o respectivo item deste documento fiscal ativado.
				Help("  ",1,"LAICMSDEL2")
				lRet	:=	.F.
			EndIf
		EndIf
	EndIf
EndIf
Return lRet
//-------------------------------------------------------------------



//-------------------------------------------------------------------

Function a017LCpIt()
Local	lRet	:=	.T.
Local	nPosCalc:=	0
Local	nPosItD2:=	0
Local	nPosItD1:=	0

If Type("oLancCDV")=="O"

	nPosCalc:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_AUTO"})

	If nPosCalc>0 .And. oLancCDV:aCols[oLancCDV:nAT,nPosCalc]=="2" .And. Type("aColsD2")=="A" .And. Type("aHeadD2")="A"
		nPosItD2:= 	aScan(aHeadD2,{|aX| aX[2]==PadR("D2_ITEM",Len(SX3->X3_CAMPO))})
		If nPosItD2>0
			nPos	:=	aScan(aColsD2,{|aX|aX[nPosItD2]==AllTrim(M->CDV_NUMITE).And.!aX[Len(aColsD2[1])]})
			If nPos==0
				//Número do item é inválido para este lançamento fiscal.
				//Deve-se informar um número de item existente no respectivo documento fiscal.
				Help("  ",1,"LAICMSCMP1")
				lRet	:=	.F.
			EndIf
		EndIf
	EndIf
	
	If nPosCalc>0 .And. oLancCDV:aCols[oLancCDV:nAT,nPosCalc]=="2" .And. Type("aColsD1")=="A" .And. Type("aHeadD1")="A"
		nPosItD1:= 	aScan(aHeadD1,{|aX| aX[2]==PadR("D1_ITEM",Len(SX3->X3_CAMPO))})
		If nPosItD1>0
			nPos	:=	aScan(aColsD1,{|aX|aX[nPosItD1]==M->CDV_NUMITE.And.!aX[Len(aColsD1[1])]})
			If nPos==0
				//Número do item é inválido para este lançamento fiscal.
				//Deve-se informar um número de item existente no respectivo documento fiscal.
				Help("  ",1,"LAICMSCMP1")
				lRet	:=	.F.
			EndIf
		EndIf
	EndIf
	
EndIf
Return lRet

//-------------------------------------------------------------------



//-------------------------------------------------------------------
Function a017LCps()
Local	lRet	:=	.T.
Local	nPosCalc:=	0

If Type("oLancCDV")=="O"
	nPosCalc:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_AUTO"})
	If nPosCalc>0 .And. oLancCDV:aCols[oLancCDV:nAT,nPosCalc]=="1"
		//Registros calculados pelo sistema não poderão ser alterados, pois serão utilizados como log da rotina.
		//Caso seja necessário alterar este cálculo, basta inserir novos itens nesta opção de ajuste ou utitlizar a funcionalidade de Gerenciamento dos Lançamentos Fiscais de ICMS. Vale ressaltar que na Apuração de ICMS será considerada a sequência maior de cada lançamento fiscal do documento.
		Help("  ",1,"LAICMSCMP2")
		lRet	:=	.F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------



//-------------------------------------------------------------------
Function a017LOk()
Local	lRet	:=	.T.
Local	nPosLanc:=	0
Local	nPosVlr	:=	0
Local	nNumIte	:=	0
Local   nPosClPr := 0

If Type("oLancCDV")=="O"
	nPosLanc:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_CODAJU"})
	nPosVlr:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_VALOR"})
	nNumIte:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_NUMITE"})		
	nPosClPr:=  aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_AUTO"})
	
	If nPosClPr > 0 .AND. oLancCDV:aCols[oLancCDV:nAT,nPosClPr] <> "1"
		If !oLancCDV:aCols[oLancCDV:nAT,Len(oLancCDV:aCols[oLancCDV:nAT])] .And.;
			!Empty(oLancCDV:aCols[oLancCDV:nAT,nNumIte])

			If nPosLanc>0 .And. Empty(oLancCDV:aCols[oLancCDV:nAT,nPosLanc])
				Help(1," ","OBRIGAT",,"CDV_CODAJU"+Space(30),3,0)
				lRet	:=	.F.
			EndIf

			If lRet .And. nPosLanc>0 .And. Empty(oLancCDV:aCols[oLancCDV:nAT,nPosVlr])
				Help(1," ","OBRIGAT",,"CDV_VALOR"+Space(30),3,0)
				lRet	:=	.F.
			EndIf
		EndIf
	EndIf
EndIf
Return lRet

//-------------------------------------------------------------------


//FindFunction("DicTabCDV")
//Valida dicionario da tabela CDV
Function DicTabCDV()

Local nA	:= 0
Local aCPOCDV := {'CDV_NUMITE','CDV_SEQ','CDV_TPMOVI','CDV_ID','CDV_ESPECI','CDV_FORMUL'}

If AliasIndic("CDV") .And. FindFunction("a017xLAICMS")	.And.  FindFunction("SHOWCDV") .And. FindFunction("a017GrvCDV")
	aArea:= GetArea()
	IF !Empty(CDV->(IndexKey(4)))
		DbSelectArea("CDV")
		For nA:=1 to Len(aCPOCDV)			
			If CDV->(FieldPos(aCPOCDV[nA])) == 0
				RestArea(aArea)
				Return .F.
			Endif	
		Next
	Else
		RestArea(aArea)
		Return .F.
	Endif
Else	
	Return .F.
Endif

Return .T.

//-------------------------------------------------------------------
/*/ RetInfCDY()
Retorna informações do código de lançamento na tabela CDY.
@author Eduardo Vicente da Silva
@since 19/08/2019
/*/
//-------------------------------------------------------------------
Function RetInfCDY(cCodLan)
Local aRet := {}

CDY->(dbSetOrder(1))

If CDY->(MsSeek(xFilial("CDY")+cCodLan))
	Aadd(aRet, {CDY->CDY_NFE, CDY->CDY_ZERAVL})
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidDic
Função valida o dicionário de dados
@author Renato Rezende
@since 13/11/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function ValidDic()

If Type("lDicAtu")=="U"
	lDicAtu := (X3Uso(Posicione( "SX3", 2, "CDV_ID", "X3_USADO")))
EndIf

Return lDicAtu

/*/{Protheus.doc} QryVld
	(long_description)
	@type  Static Function
	@author Erich Buttner
	@since 26/02/2020
	@version version
	@param param, param_type, param_descr
	@return RECNO
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function QryVld(oModel)

Local cPeriod	:= oModel:GetValue("CDVMASTER","CDV_PERIOD"	)
Local cCodAju   := oModel:GetValue("CDVMASTER","CDV_CODAJU"	)
Local cLivro	:= oModel:GetValue("CDVMASTER","CDV_LIVRO"	)
Local cDoc      := oModel:GetValue("CDVMASTER","CDV_DOC"   	)
Local cSerie    := oModel:GetValue("CDVMASTER","CDV_SERIE" 	)
Local cCliFor   := oModel:GetValue("CDVMASTER","CDV_CLIFOR"	)
Local cLoja     := oModel:GetValue("CDVMASTER","CDV_LOJA"  	)
Local cCfop		:= oModel:GetValue("CDVMASTER","CDV_CFOP"	)
Local CDescr	:= oModel:GetValue("CDVMASTER","CDV_DESCR"	)
Local cNumItem  := oModel:GetValue("CDVMASTER","CDV_NUMITE" )
Local cSeq		:= oModel:GetValue("CDVMASTER","CDV_SEQ"	)
Local cTpMov    := oModel:GetValue("CDVMASTER","CDV_TPMOVI" )
Local cEspecie	:= oModel:GetValue("CDVMASTER","CDV_ESPECI"	)
Local cFormul	:= oModel:GetValue("CDVMASTER","CDV_FORMUL"	)
Local cAliasVld := GetNextAlias()
Local cSelect	:= ""
Local cFrom		:= ""
Local cWhere	:= ""

cSelect := " CDV.R_E_C_N_O_ RECNO

cFrom := RetSqlName("CDV")+" CDV"

cWhere := " CDV.CDV_FILIAL = "+ValToSQL(xFilial("CDV")) 
cWhere += " AND CDV.CDV_PERIOD = "+ValToSQL(cPeriod)
cWhere += " AND CDV.CDV_CODAJU = "+ValToSQL(cCodAju)
cWhere += " AND CDV.CDV_LIVRO = "+ValToSQL(cLivro)
cWhere += " AND CDV.CDV_DOC = "+ValToSQL(cDoc)
cWhere += " AND CDV.CDV_SERIE = "+ValToSQL(cSerie) 
cWhere += " AND CDV.CDV_CLIFOR = "+ValToSQL(cCliFor)
cWhere += " AND CDV.CDV_LOJA = "+ValToSQL(cLoja) 
cWhere += " AND CDV.CDV_CFOP = "+ValToSQL(cCfop)
cWhere += " AND CDV.CDV_NUMITE = "+ValToSQL(cNumItem)
cWhere += " AND CDV.CDV_TPMOVI = "+ValToSQL(cTpMov)
cWhere += " AND CDV.CDV_ESPECI = "+ValToSQL(cEspecie) 
cWhere += " AND CDV.CDV_FORMUL = "+ValToSQL(cFormul)
cWhere += " AND CDV.CDV_SEQ = "+ValToSQL(cSeq)
cWhere += " AND CDV.D_E_L_E_T_ = ' '

cSelect	:= "%"	+ cSelect + "%" 
cFrom	:= "%"	+ cFrom + "%" 
cWhere	:= "%"	+ cWhere + "%"

// Execução.
BeginSql Alias cAliasVld
	SELECT 
		%Exp:cSelect%
	FROM 
		%Exp:cFrom%
	WHERE 
		%Exp:cWhere%
EndSql

nRecno := (cAliasVld)->RECNO

(cAliasVld)->(DbCloseArea())

Return nRecno
