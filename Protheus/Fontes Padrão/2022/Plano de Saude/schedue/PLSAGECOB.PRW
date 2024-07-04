#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "TOTVS.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tela de Cadastro do Novo Lote de Cobranca
ModelDef - MVC

@author    Rafael Soares (r.soares)
@version   V12
@since     08/07/2020
/*/
//------------------------------------------------------------------------------------------

Function PLSAGECOB(lAutoma) 
Local oBrowse := FWMBrowse():New()

Default lAutoma := .F.

Private cCodInt := PlsIntPad()
Private VAR_IXB := ""

oBrowse:SetDescription( "Agendamento do Lote de Cobranca" )
oBrowse:SetAlias( "B6J" )
oBrowse:SetMenuDef( 'PLSAGECOB' )
oBrowse:SetProfileID( 'PLSAGECOB' )
oBrowse:ForceQuitButton()
oBrowse:DisableDetails()

Iif(!lAutoma, oBrowse:Activate(),"")

Return 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
ModelDef - MVC

@author    Rafael Soares (r.soares)
@version   V12
@since     08/07/2020
/*/
//------------------------------------------------------------------------------------------

Static Function MenuDef()
local aRotina	:= {}

aadd( aRotina, { "Visualizar"	,	"VIEWDEF.PLSAGECOB" , 0, MODEL_OPERATION_VIEW	} )
aadd( aRotina, { "Excluir"		, 	"VIEWDEF.PLSAGECOB" , 0, MODEL_OPERATION_DELETE	} )
aadd( aRotina, { "Incluir"		, 	"VIEWDEF.PLSAGECOB" , 0, MODEL_OPERATION_INSERT	} )
aadd( aRotina, { "Alterar"		,	"VIEWDEF.PLSAGECOB" , 0, MODEL_OPERATION_UPDATE	} )

Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    Rafael Soares (r.soares)
@version   V12
@since     08/07/2020
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef() 
Local oStruB6J	:= FwFormStruct(1,'B6J')
Local oStruB6K	:= FwFormStruct(1,'B6K')
Local oStruB6Q	:= FwFormStruct(1,'B6Q')
Local oModel    := MPFormModel():New('PLSAGECOB',, { |oModel| PLAGECOBPOS( oModel ) } , /*bCommit*/ , /*bCancel*/ )
	
	//Instancia do Objeto de Modelo de Dados
	oModel:AddFields( 'B6JMASTER', NIL, oStruB6J )
	oModel:AddGrid( 'B6KDETAIL', 'B6JMASTER', oStruB6K,/*bLinePre*/,{ |oGrid| GridB6KValid(oGrid) },/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
	oModel:AddGrid( 'B6QDETAIL', 'B6JMASTER', oStruB6Q )

	oModel:GetModel( 'B6JMASTER' ):SetDescription( "Agendamento de Cobrancas" ) 
	oModel:GetModel( 'B6KDETAIL' ):SetDescription( "Complem. Subcontrato" ) 
	oModel:GetModel( 'B6QDETAIL' ):SetDescription( "Movimentos de Schedule" ) 
	oModel:GetModel("B6KDETAIL"):SetOptional(.T.)
	oModel:GetModel("B6QDETAIL"):SetOptional(.T.)

	oModel:SetPrimaryKey( { "B6J_FILIAL", "B6J_CODAGE" } )
	
	// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'B6KDETAIL',  { 	{ 'B6K_FILIAL'	, 'xFilial( "B6K" )' },;
										{ 'B6K_NUMSEC' 	, 'B6J_CODAGE' }}, ;
										B6K->( IndexKey( 1 ) ) )
		// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'B6QDETAIL',  { 	{ 'B6Q_FILIAL'	, 'xFilial( "B6J" )' },;
										{ 'B6Q_CODAGE' 	, 'B6J_CODAGE' }}, ;
										B6Q->( IndexKey( 1 ) ) )									


	xAux := FwStruTrigger('B6K_NUMCON', 'B6K_VERSAO', 'BQC->BQC_VERCON', .F.)
	oStruB6K:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger('B6K_SUBCON', 'B6K_VERSUB', 'BQC->BQC_VERSUB', .F.)
	oStruB6K:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger('B6K_CONFIN', 'B6K_VERFIN', 'BQC->BQC_VERCON', .F.)
	oStruB6K:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger('B6K_SUBFIN', 'B6K_VESUFI', 'BQC->BQC_VERSUB', .F.)
	oStruB6K:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4])


Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Descricao: Cria a View da Rotina.
@author r.soares
@since 09/07/2020
@version 1.0

@Complem.:

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	
	Local oModel   	:= FWLoadModel( 'PLSAGECOB' )
	Local oStruB6J 	:= FWFormStruct( 2, 'B6J' ) 
	Local oStruB6K 	:= FWFormStruct( 2, 'B6K' ) 
	Local oStruB6Q 	:= FWFormStruct( 2, 'B6Q' ) 
	Local oView
	Local cFiltro 	:= ""

	//Removendo os valores dos campos não necessários a serem mostrados
	oStruB6K:RemoveField('B6K_CODOPE')
	oStruB6K:RemoveField('B6K_NUMSEC')

	oView    	:= FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField('VIEW_B6J' , oStruB6J, 'B6JMASTER' )
	oView:AddGrid( 'VIEW_B6K'  , oStruB6K, 'B6KDETAIL' )
	oView:AddGrid( 'VIEW_B6Q'  , oStruB6Q, 'B6QDETAIL' )

	oView:CreateHorizontalBox( 'SUPERIOR', 65 )
	oView:CreateHorizontalBox( 'BOXFOLDER', 35 )

	
	oView:CreateFolder( 'PASTAS','BOXFOLDER' )

	oView:AddSheet( 'PASTAS'	,'ABA_PARAMJURI'	,"Complem. Subcontrato") 
	oView:AddSheet( 'PASTAS'	,'ABA_MOVSCHEDU'	,"Movimentos de Schedule") 

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'PARAM'	, 100,,, 'PASTAS', 'ABA_PARAMJURI'	)
	oView:CreateHorizontalBox( 'SCHED'	, 100,,, 'PASTAS', 'ABA_MOVSCHEDU'		)

	// Relaciona o identificador (ID) da View com o "box" para exibiÃ§Ã£o
	oView:SetOwnerView( 'VIEW_B6J', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_B6K', 'PARAM' )
	oView:SetOwnerView( 'VIEW_B6Q', 'SCHED' )

	/* Cria botões na View*/
	oView:AddUserButton( "Filtro",'' , {|oView| (FWFldPut("B6J_FILTRO",BuildExpr("BA3",,cFiltro)) , oView:Refresh("VIEW_B6J"))} ,,,{MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE}) 

	//Insiro descriÃ§Ãµes nas views
	oView:EnableTitleView( 'VIEW_B6J', "Agendamento de Cobrancas" )
	oView:EnableTitleView( 'VIEW_B6K', "Complem. Subcontrato" )
	oView:EnableTitleView( 'VIEW_B6K', "Movimentos de Schedule" )

	//Desabilita a edição dos campos 
	oStruB6Q:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)

Return oView

/*/{Protheus.doc} PLAGECOBPOS 
Valida quando salva alguma operação da rotina. 

@author  r.soares - Rafael Soares
@version P12
@since   13.07.2020
/*/

Function PLAGECOBPOS(oModel, lAutoma)
Local lRet 		 := .T.
Local lFisJur	 := Iif(Empty(oModel:GetValue("B6JMASTER","B6J_FISJUR")),.F.,Iif(oModel:GetValue("B6JMASTER","B6J_FISJUR") == "1", .T., .F.) )
Local nOperation := oModel:GetOperation()

Default lAutoma	 := .F.

	If nOperation == 3 .And. lFisJur
		If Empty(oModel:GetValue("B6KDETAIL","B6K_CODEMP"))
			Help(' ',1,"HELP","B6K_CODEMP","O campo Empresa encontra-se vazio por favor, preencher.",1,0)
			lRet := .F.
		EndIf
	ElseIf nOperation == 3 .And. !lFisJur
		If Empty(AllTrim(oModel:GetValue("B6JMASTER","B6J_FILTRO")))
			Help(' ',1,"HELP","B6J_FILTRO","O campo Filtro Fam. encontra-se vazio por favor, preencher.",1,0)
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} GridB6KValid 
Valida a linha

@author  r.soares - Rafael Soares
@version P12
@since   23.07.2021
/*/

Function GridB6KValid(oGrid)
LOCAL lRet   := .T.
LOCAL oModel := FwModelActive()
Local nOperation := oModel:GetOperation()
Local lFisJur	 := Iif(Empty(oModel:GetValue("B6JMASTER","B6J_FISJUR")),.F.,Iif(oModel:GetValue("B6JMASTER","B6J_FISJUR") == "1", .T., .F.) )

If nOperation == 3 .And. lFisJur .And. Empty(oModel:GetValue("B6KDETAIL","B6K_CODEMP"))
	Help(' ',1,"HELP","B6K_CODEMP","O campo Empresa encontra-se vazio por favor, preencher.",1,0)
	lRet := .F.
EndIF

Return lRet



/*/{Protheus.doc} PLAGECOBVLD 
Valida campos de data inicio e fim no lote de cobranca...

@author  r.soares - Rafael Soares
@version P12
@since   16.07.2020
/*/
Function PLAGECOBVLD()
LOCAL lRet := .F.

If Empty(M->B6J_MESFIN) .OR.;
 ((M->B6J_ANOFIN+M->B6J_MESFIN >= M->B6J_ANOINI+M->B6J_MESINI) .And.;
  (M->B6J_MESFIN >= "01" .And. M->B6J_MESFIN <= "12") )

	lRet := .T.
EndIf

Return(lRet)


/*/{Protheus.doc} SubCoAgeCob 
Efetua validacao do campo de Filtro. 

@author  r.soares - Rafael Soares
@version P12
@since   17.07.20
/*/
Function AGECOBFIL(cFiltro)
LOCAL xResult
LOCAL cForm			:=&(ReadVar())
LOCAL lRet			:=.T.
LOCAL aRetSyntax 	:= {}
Local lAutoma		:= IsBlind()

Default cFiltro		:= "" //

//An lise estrutural de sintaxe														  

aRetSyntax := ParAnalise(cForm)

IF !empty(aRetSyntax[1])
	If !lAutoma
		Help(" ",1,"ERR_FORM",,OemToAnsi( "Estrutura Inconsistente : " + aRetSyntax[1]),3,0)
	EndIf
	lRet := .F.
EndIf

If lRet
	bBlock := ErrorBlock( { |e| ChecErro(e) } )
	BEGIN SEQUENCE
		xResult := &cForm
	RECOVER
		lRet := .F.
	END SEQUENCE
	ErrorBlock(bBlock)
EndIf

Return lRet

/*/{Protheus.doc} SubCoAgeCob 
Efetua validacao do campo de Filtro. 

@author  r.soares - Rafael Soares
@version P12
@since   17.07.20
/*/

Static Function ParAnalise(cTexto)
LOCAL uAbre
LOCAL uFecha
LOCAL cStack	:= ""
LOCAL cAspas	:= ""
LOCAL nPosAt	:= 1
LOCAL uLastPar	:= 1
LOCAL cPosAtual	:= ""
LOCAL cSeparador:= ","
LOCAL aSepFunc	:= {"()","[]","{}"}
LOCAL aParam	:= {}

//Arranca os caracteres da esquerda se forem 'espa?o' ou 'TAB'							  

While left(cTexto,1)==" " .or. left(cTexto,1)==chr(9)
	cTexto:=right(cTexto,len(cTexto)-1)
EndDo

While nPosAt<=len(cTexto)
	cPosAtual:=substr(cTexto,nPosAt,1)
	
	//Achou "ASPAS"																		  
	
	If cPosAtual==chr(34) .or. cPosAtual==chr(39)
		cAspas:=If(empty(cAspas),cPosAtual,If(cAspas == cPosAtual,"",cAspas))
	EndIf
	
	//Apenas analiza a estrutura caso nao esteja entre aspas								  
	
	If empty(cAspas)
		uAbre :=ascan(aSepFunc,{|_v|  left(_v,1) == cPosAtual})
		uFecha:=ascan(aSepFunc,{|_v| right(_v,1) == cPosAtual})
		
		//Abriu ou Fechou uma estrutura														  

		If uAbre+uFecha>0
			
			//Abriu uma estrutura ! Acrescenta no STACK											  
			
			If uAbre>0
				If !empty(substr(cTexto,uLastPar,nPosAt-uLastPar))
					aadd(aParam,substr(cTexto,uLastPar,nPosAt-uLastPar))
				EndIf
				uLastPar:=nPosAt+1	 ; cStack:=cStack+cPosAtual
			
			//Fechou uma estrutura : Checa o STACK													  
			
			Else
				
				//Se fechou certo, tira do Stack														  
				
				If right(cStack,1)==Left(aSepFunc[uFecha],1)
					cStack:=left(cStack,len(cStack)-1)
				
				//Estrutura fechada incorretamente														  
				
				Else
					cStack:=right(aSepFunc[uFecha],1)
					EXIT
				EndIf
				If !empty(substr(cTexto,uLastPar,nPosAt-uLastPar))
					aadd(aParam,substr(cTexto,uLastPar,nPosAt-uLastPar))
				EndIf
				uLastPar:=nPosAt+1
			EndIf
		
		//Verifica separador																	  
		
		Else
			If cPosAtual==cSeparador
				aadd(aParam,SubStr(cTexto,uLastPar,nPosAt-uLastPar))
				uLastPar:=nPosAt+1
			EndIf
		EndIf
	EndIf
	nPosAt++
EndDo

IF !empty(cTexto) .and. len(aParam) == 0
	aadd(aParam,AllTrim(cTexto))
EndIf
cStack+=if(empty(cAspas),"",cAspas)

Return {cStack,aParam}

/*/{Protheus.doc} AGEVLDCGR
Valida conteudo do campo	
@author  r.soares - Rafael Soares
@since   20/07/2020
@version p12
/*/
Function AGEVLDCGR()
LOCAL lRet := .F.

If ___lVld
	 ___lVld := .F.
	lRet 	 := .T.
EndIf

Return(lRet)


/*/{Protheus.doc} PLGRCOBMVC
Seleciona grupo de cobranca	
@author  r.soares
@since   20/07/2020
@version p11
/*/

Function PLGRCOBMVC(lAutoma, aAutoma)
Local oDlg
LOCAL nOpca       := 0
LOCAL bOK         := { || nOpca := K_OK, oDlg:End() }
LOCAL bCancel     := { || oDlg:End() }
LOCAL aPosObj     := {}
LOCAL aObjects    := {}
LOCAL aSize       := {}
LOCAL aInfo       := {}
LOCAL oDados	  := NIL
Local aDados 	  := {}
Local lRet   	  := .F.
Local nX	 	  := 0
Local cDado		  := ""

Default aAutoma	  := {}
Default lRetorno  := .F.
Default lAutoma	  := .F.

Static objCENFUNLGP := CENFUNLGP():New()

BR0->( DbSetOrder(1) )
BR0->( DbGoTop() )
While ! BR0->( Eof() )
	If BR0->BR0_FILIAL == xFilial("BR0")
		aAdd(aDados, { BR0->BR0_FILIAL, BR0->BR0_CODIGO,BR0->BR0_DESCRI, IIf(BR0->BR0_CODIGO $ cDado, .T., .F.) })
	EndIf
	BR0->(DbSkip())
EndDo

BR0->(dbCloseArea())

If Len(aDados) < 1
	aAdd(aDados,{" "," "," "})
EndIf

If Len(aAutoma)
	aDados := AClone(aAutoma)
EndIf

aSize 	 := MsAdvSize()
aSize[7] := Round(aSize[7] * 0.75, 0)
aSize[6] := Round(aSize[6] * 0.75, 0)
aSize[5] := Round(aSize[5] * 0.75, 0)
aSize[4] := Round(aSize[4] * 0.75, 0)
aSize[3] := Round(aSize[3] * 0.75, 0)
aObjects := {}
AAdd( aObjects, { 1, 10, .T., .F., .T. } )
AAdd( aObjects, { 1, 1, .T., .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

If !lAutoma
	DEFINE MSDIALOG oDlg TITLE "Grupo de Cobrança" FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel //"Grupo de Cobrança"
	oDados := TcBrowse():New( aPosObj[2][1], aPosObj[2][2], aPosObj[2][3], aPosObj[2][4],,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	@ aPosObj[1][1],aPosObj[1][2]+5 SAY oSay PROMPT "Selecione o(s) Grupos de Combrança(s)" SIZE aPosObj[1][3],aPosObj[1][4] OF oDlg PIXEL COLOR CLR_HBLUE//"Selecione o(s) Grupos de Combrança(s)"
EndIf

Iif(!lAutoma,oDados:AddColumn(TcColumn():New(" ",{ || IF(aDados[oDados:nAt,4],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },"@!",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil)),"")

Iif(!lAutoma,oDados:AddColumn(TcColumn():New("Filial",{ || OemToAnsi(aDados[oDados:nAt,1]) },"@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil)),"")

Iif(!lAutoma,oDados:AddColumn(TcColumn():New("Código",{ || OemToAnsi(aDados[oDados:nAt,2]) },"@!",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil)),"")

Iif(!lAutoma,oDados:AddColumn(TcColumn():New("Descrição",{ || OemToAnsi(aDados[oDados:nAt,3]) },"@!",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil)),"")
//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
if objCENFUNLGP:isLGPDAt()
	aCampos := {.F.,"BR0_CODIGO","BR0_DESCRI"}
	aBls := objCENFUNLGP:getTcBrw(aCampos)

	If !lAutoma
		oDados:aObfuscatedCols := aBls
	EndIF
endif

If !lAutoma
	oDados:SetArray(aDados)
	oDados:bLDblClick := { || aDados[oDados:nAt,4] := IF(aDados[oDados:nAt,4],.F.,.T.) }
	oDados:bLine      := {|| {aDados[oDados:nAt,1], aDados[oDados:nAt,2], aDados[oDados:nAt,3], aDados[oDados:nAt,4]}}

	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{}) CENTER
EndIf

If lAutoma .Or. Len(aDados) > 0 .And. nOpca == K_OK
	For nX := 1 To Len(aDados)
		If aDados[nX][4]
			cDado += aDados[nX][2] + ","
		EndIf
	Next nX
EndIf

// Tira a virgula do final da string e seta o valor no form

If SubStr(cDado, Len(cDado), 1) == ","
	cDado 	:= SubStr(cDado, 1, Len(cDado) - 1)
	Iif(!lAutoma, FWFldPut("B6J_GRCOBV", cDado), "")
	Iif(!lAutoma,FWFldPut("B6J_GRUCOB", ""),"")
	VAR_IXB := cDado
	VAR_IXB := AllTrim(VAR_IXB)
	___lVld := .T.
	lRet 	:= .T.
EndIf

Return lRet


/*/{Protheus.doc} SubCoAgeCob 
Efetua validacao dos campos chaves do Compl de Subcontrato. 

@author  r.soares - Rafael Soares
@version P12
@since   16.07.20
/*/
Function SubCoAgeCob(cValor, cValEmp, cNumCon, cVersao, cSubCon)
LOCAL lRet 		:= .T.
LOCAL cFunName	:= FunName()
LOCAL cCodInt	:= PlsIntPad()
Local cReadVar	:= ReadVar()
Local cValAux	:= ""
Local lAutoma	:= IsBlind()

Do Case
	Case cReadVar == "M->B6K_CODEMP" .And. ! Empty(cValor)
		lRet := BG9->(MsSeek(xFilial("BG9") + cCodInt+cValor)) .And.;
				BT5->(MsSeek(xFilial("BT5") + cCodInt+cValor))
		If ! lRet .Or. (BT5->BT5_INTERC = "1" .And. cFunName = "PLSAGECOB")
			Iif(!lAutoma,Help("",1,"REGNOIS"),"")
			lRet := .F.
		Else
			cValAux:= BG9->BG9_DESCRI
			FWFldPut("B6K_DESEMP", cValAux)
		EndIf

	Case cReadVar == "M->B6K_EMPFIN" .And. ! Empty(cValor)	// Empresa Final
		lRet := BG9->(MsSeek(xFilial("BG9") + cCodInt+cValor)) .And.;
				BT5->(MsSeek(xFilial("BT5") + cCodInt+cValor))
		If ! lRet .Or. (BT5->BT5_INTERC = "1" .And. cFunName = "PLSAGECOB")
			Iif(!lAutoma,Help("",1,"REGNOIS"),"")
			lRet := .F.
		Else
			cValAux:= BG9->BG9_DESCRI
			FWFldPut("B6K_DESFIN", cValAux)
		EndIf

	Case cReadVar == "M->B6K_NUMCON" .And. ! Empty(cValor)
		lRet := ExistCpo("BT5",cCodInt+cValEmp+cValor)
		If lRet		// Gatilho o campo
			cValAux:= BT5->BT5_VERSAO
			FWFldPut("B6K_VERSAO", cValAux)
		EndIf

	Case cReadVar == "M->B6K_CONFIN" .And. ! Empty(cValor)
		lRet := ExistCpo("BT5",cCodInt+cValEmp+cValor)
		//Gatilho o campo																	
		If lRet
			If BT5->BT5_INTERC = "1" .And. cFunName = "PLSAGECOB"
			Iif(!lAutoma,Help("",1,"REGNOIS"),"")
					lRet := .F.
			Else
				cValAux:= BT5->BT5_VERSAO
				FWFldPut("B6K_VERFIN", cValAux)
			EndIf
		EndIf

	Case cReadVar == "M->B6K_VERSAO" .And. ! Empty(cValor)
		lRet := ExistCpo("BT5",cCodInt+cValEmp+cNumCon+cValor)

	Case cReadVar == "M->B6K_VERFIN" .And. ! Empty(cValor)
		lRet := ExistCpo("BT5",cCodInt+cValEmp+cNumCon+cValor)
	
	Case cReadVar == "M->B6K_SUBCON" .And. ! Empty(cValor)
		lRet := ExistCpo("BQC",cCodInt+cValEmp+cNumCon+cVersao+cValor)
		//Gatilho o campo														
		If lRet
			cValAux	:= BQC->BQC_VERSUB
			FWFldPut("B6K_VERSUB", cValAux)
		EndIf
	
	Case cReadVar == "M->B6K_SUBFIN" .And. ! Empty(cValor)	// Sub-Contrato Final
		lRet := ExistCpo("BQC",cCodInt+cValEmp+cNumCon+cVersao+cValor)
		
		If lRet
			cValAux	:= BQC->BQC_VERSUB
			FWFldPut("B6K_VESUFI", cValAux)
		EndIf

	Case cReadVar == "M->B6K_VERSUB" .And. ! Empty(FWFldGet("B6K_SUBCON")) .And. ! Empty(BQC->BQC_VERSUB)
		lRet := ExistCpo("BQC",cCodInt+cValEmp+cNumCon+cVersao+cSubCon+BQC->BQC_VERSUB)
	
	Case cReadVar == "M->B6K_VESUFI" .And. ! Empty(FWFldGet("B6K_SUBCON")) .And. ! Empty(BQC->BQC_VERSUB)
		lRet := ExistCpo("BQC",cCodInt+cValEmp+cNumCon+cVersao+cSubCon+BQC->BQC_VERSUB)

EndCase


Return lRet