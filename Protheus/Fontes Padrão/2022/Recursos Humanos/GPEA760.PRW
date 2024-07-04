#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA760.CH"

/*/{Protheus.doc} GPEA760
Cadastro de bloqueio de períodos para o MDT
@author Leandro Drumond
@since 24/01/2021
@version P12.1.33
@Type     Function
/*/

Function GPEA760()

Local oMBrowse
Local cFiltraRh

oMBrowse := FWMBrowse():New()

oMBrowse:SetAlias("RG3")
oMBrowse:SetDescription(OemToAnsi(STR0001)) //'Bloqueio de Períodos MDT'
oMBrowse:SetmenuDef( "GPEA760" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltraRh := CHKRH("GPEA760","RG3","1")
oMBrowse:SetFilterDefault( cFiltraRh )

oMBrowse:Activate()

Return

/*/{Protheus.doc} ModelDef
Regras de Modelagem da gravacao
@author Leandro Drumond
@since 24/01/2021
@version P12.1.33
@Type     Function
/*/
Static Function ModelDef()

Local nOrdRG3		:= RetOrdem( "RG3", "RG3_FILIAL+RG3_PROCES+RG3_PERIOD+RG3_ROTEIR" )
Local oModel
Local oStructRFQ
Local oStructRG3

//Criacao do Objeto de Modelagem de dados 
oModel     := MPFormModel():New("GPEA760")
oModel:SetDescription( OemToAnsi(STR0001) ) //"Bloqueio de Períodos MDT"

//Cabecalho de dados - RFQ (Períodos)
oStructRFQ := FWFormStruct(1, "RFQ", {|cCampo| AllTrim(cCampo)+"|" $ "RFQ_PROCES|RFQ_PERIOD|"})
oModel:AddFields("GPEA760_MRFQ", NIL, oStructRFQ)
oModel:GetModel( "GPEA760_MRFQ" ):SetDescription( OemToAnsi(STR0001) ) //"Bloqueio de Períodos MDT"
oModel:GetModel('GPEA760_MRFQ'):SetOnlyQuery(.T.)
oModel:GetModel('GPEA760_MRFQ'):SetOnlyView(.T.)

//Estrutura de campos do Model - RG3 - Bloqueio de períodos
oStructRG3 := FWFormStruct(1, "RG3")

oStructRG3:SetProperty( "RG3_USER1", MODEL_FIELD_VALID, { |oModel| Vazio() .or. Gp760VldUser(oModel, 1) } )
oStructRG3:SetProperty( "RG3_USER2", MODEL_FIELD_VALID, { |oModel| Vazio() .or. Gp760VldUser(oModel, 2) } )
oStructRG3:SetProperty( "RG3_DTINI", MODEL_FIELD_VALID, { |oModel| NaoVazio() .and. Gp760VldDat(oModel, .T.) } )
oStructRG3:SetProperty( "RG3_DTFIM", MODEL_FIELD_VALID, { |oModel| NaoVazio() .and. Gp760VldDat(oModel, .F.) } )
oStructRG3:SetProperty( "RG3_FIL",   MODEL_FIELD_VALID, { || GP760VldFil() } )
oStructRG3:SetProperty( "RG3_FIL",   MODEL_FIELD_WHEN , { || .T.  } )
oStructRG3:SetProperty( "RG3_DFIL",  MODEL_FIELD_VALID, { || .T. } )
oStructRG3:SetProperty( "RG3_ROTEIR",MODEL_FIELD_VALID, { || .T. } )

oStructRG3:SetProperty( "RG3_EMP",    MODEL_FIELD_INIT, {||cEmpAnt} )
oStructRG3:SetProperty( "RG3_FIL",    MODEL_FIELD_INIT, {||cFilAnt} )
oStructRG3:SetProperty( "RG3_PERIOD", MODEL_FIELD_INIT, {||RFQ->RFQ_PERIOD} )
oStructRG3:SetProperty( "RG3_ROTEIR", MODEL_FIELD_INIT, {||"MDT"} )
oStructRG3:SetProperty( "RG3_NUSER1", MODEL_FIELD_INIT, {|| UsrRetName(RG3->RG3_USER1)} )
oStructRG3:SetProperty( "RG3_NUSER2", MODEL_FIELD_INIT, {|| UsrRetName(RG3->RG3_USER2)} )
oStructRG3:SetProperty( "RG3_DFIL",   MODEL_FIELD_INIT, {|| Posicione("SM0", 1, cEmpAnt+RG3->RG3_FIL, "M0_FILIAL")} )
oStructRG3:SetProperty( "RG3_FILIAL", MODEL_FIELD_INIT, {|| xFilial("RG3", cFilAnt)} )

oModel:AddGrid("GPEA760_MRG3", "GPEA760_MRFQ", oStructRG3,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, {|oGrid| CargaRG3(oGrid) })

oModel:GetModel( "GPEA760_MRG3" ):SetOptional(.T.)
oModel:GetModel( "GPEA760_MRG3" ):SetUniqueLine( { "RG3_FIL" , "RG3_PERIOD" , "RG3_ROTEIR" } )

oModel:GetModel( "GPEA760_MRFQ" ):SetPrimaryKey( { "RFQ_PROCES" ,"RFQ_PERIOD" } )

oModel:SetRelation( "GPEA760_MRG3", { { "RG3_PROCES", 'RFQ->RFQ_PROCES' }, { "RG3_PERIOD", 'RFQ->RFQ_PERIOD' } }, RG3->( IndexKey( nOrdRG3 ) ) )

Return( oModel )

/*/{Protheus.doc} ViewDef
Regras de Interface com o Usuario
@author Leandro Drumond
@since 24/01/2021
@version P12.1.33
@Type     Function
/*/
Static Function ViewDef()

Local oView 
Local oModel
Local oStructRFQ
Local oStructRG3
Local bLoadFil		:= {|| Gp760LoadFil() }

oModel := FWLoadModel("GPEA760")

oView := FWFormView():New()
oView:SetModel(oModel)

oStructRFQ := FWFormStruct(2, "RFQ", {|cCampo| AllTrim(cCampo)+"|" $ "RFQ_PROCES|RFQ_PERIOD|"})
oStructRFQ:SetNoFolder()
oView:AddField("GPEA760_VRFQ", oStructRFQ, "GPEA760_MRFQ" )

oStructRG3 	:= FWFormStruct(2, "RG3")
oStructRG3:RemoveField( "RG3_EMP" )
oStructRG3:RemoveField( "RG3_ROTEIR" )
oStructRG3:RemoveField( "RG3_PERIOD" )
oStructRG3:RemoveField( "RG3_SEMANA" )

oView:AddGrid("GPEA760_VRG3", oStructRG3, "GPEA760_MRG3" )

oView:CreateHorizontalBox("RFQ_HEAD", 12)
oView:CreateHorizontalBox("RG3_BODY", 88)

oView:SetOwnerView( "GPEA760_VRFQ", "RFQ_HEAD" )
oView:SetOwnerView( "GPEA760_VRG3", "RG3_BODY" )

oView:addUserButton(OemToAnsi(STR0002),"",bLoadFil ,OemToAnsi(STR0002+"..."),,{MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE } )	//"Carregar Filiais"
	
Return oView

/*/{Protheus.doc} GP760VldFil
Validação das informações
@author Leandro Drumond
@since 24/01/2021
@version P12.1.33
@Type     Function
/*/
Static Function GP760VldFil()
Local cFilAux   := &(ReadVar())
Local lRet 		:= FwFilExist(,cFilAux)

Return lRet

/*/{Protheus.doc} Gp760VldUser
Valida usuário liberado
@author Leandro Drumond
@since 24/01/2021
@version P12.1.33
@Type     Function
/*/
Static Function Gp760VldUser(oGrid, nUser)
Local lRet  := .F.
Local cUser	:= &(ReadVar())
Local cDesc := ""

If UsrExist(cUser)
	lRet := .T.
	cDesc := UsrRetName( cUser )
EndIf

If nUser == 1
	oGrid:LoadValue("RG3_NUSER1", cDesc)
Else 
	oGrid:LoadValue("RG3_NUSER2", cDesc)
EndIf

Return lRet

/*/{Protheus.doc} Gp760VldDat
Valida data inicial e final
@author Leandro Drumond
@since 24/01/2021
@version P12.1.33
@Type     Function
/*/
Static Function Gp760VldDat(oGrid,lIni)
Local dDtFim	:= Ctod("")
Local dDtIni	:= Ctod("")
Local lRet      := .T.

dDtIni		:= If( lIni ,&(ReadVar()) , oGrid:GetValue("RG3_DTINI"))
dDtFim		:= If( !lIni,&(ReadVar()) , oGrid:GetValue("RG3_DTFIM"))

Begin Sequence

	If !Empty(dDtFim) .And. ( dDtFim < dDtIni )
		Help(" ",1,"DATA2INVAL")  // "A Data de Fim nao pode ser menor do que a Data de Inicio."
		lRet := .F.
		Break
	EndIf

	If !Empty(dDtIni) .And. ( dDtIni < RFQ->RFQ_DTINI )
		Help( , , "HELP", ,STR0003, 1, 0,,,,,,{STR0004 + DtoC(RFQ->RFQ_DTINI) + " - " + DtoC(RFQ->RFQ_DTFIM) }) //"A data inicial nao pode anteceder a data inicial do periodo selecionado" ### Período selecionado: "
		lRet := .F.
		Break
	EndIf

	If !Empty(dDtFim) .And. ( dDtFim < RFQ->RFQ_DTINI )
		Help( , , "HELP", ,STR0005, 1, 0,,,,,,{STR0004 + DtoC(RFQ->RFQ_DTINI) + " - " + DtoC(RFQ->RFQ_DTFIM)}) //"A data final nao pode anteceder a data inicial do periodo selecionado" ### Período selecionado: "
		lRet := .F.
		Break
	EndIf

	If !Empty(dDtIni) .And. ( dDtIni > RFQ->RFQ_DTFIM )
		Help( , , "HELP", ,STR0006, 1, 0,,,,,,{STR0004 + DtoC(RFQ->RFQ_DTINI) + " - " + DtoC(RFQ->RFQ_DTFIM) }) //"A data inicial nao pode ultrapassar a data final do periodo selecionado." ### Período selecionado: "
		lRet := .F.
		Break
	EndIf

End Sequence

Return( lRet )

/*/{Protheus.doc} Gp760LoadFil
Carrega filiais
@author Leandro Drumond
@since 24/01/2021
@version P12.1.33
@Type     Function
/*/
Static Function Gp760LoadFil()
Local aArea			:= GetArea()
Local aColumns		:= {}
Local aSM0     		:= {}
Local aStru			:= {}
Local aLstIndices	:= {}
Local cUser1  		:= ""
Local cUser2  		:= ""
Local cNome1  		:= ""
Local cNome2  		:= ""
Local dDtIni  		:= ""
Local dDtFim  		:= ""
Local lMarcar 		:= .T.
Local oModel      	:= FWModelActive()
Local oGrid			:= oModel:GetModel("GPEA760_MRG3")
Local nOpcX 		:= 0
Local nCont
Local oSize 
Local oDlgGrid 
Local oTela2
Local oPanel4
Local oMark
Local oGroup
Local oFont

Private cFilAux 	:= oGrid:GetValue("RG3_FIL")
Private cAliasTRB

Static cAliasTmp
Static oArqTmp

If oArqTmp == Nil //Monta temporária com filiais disponíveis
	Aadd(aStru, {"OK"		, "C", 2						, 0})
	Aadd(aStru, {"FILIAL"	, "C", FwGetTamFilial			, 0})
	Aadd(aStru, {"NOME"  	, "C", 100						, 0})
	AAdd(aLstIndices, {"FILIAL"})

	cAliasTmp := cAliasTRB := GetNextAlias()

	oArqTmp := RhCriaTrab(cAliasTRB, aStru, aLstIndices)

	aSM0  := FWLoadSM0(.T.,,.T.)

	For nCont := 1 To Len(aSM0)
		If aSM0[nCont, 1] == cEmpAnt
			RecLock(cAliasTRB, .T.)
				(cAliasTRB)->FILIAL	:= aSM0[nCont, 2]
				(cAliasTRB)->NOME  	:= aSM0[nCont, 7]
			(cAliasTRB)->(MsUnlock())
		EndIf
	Next nCont
Else 
	cAliasTRB := cAliasTmp
EndIf

cUser1  := oGrid:GetValue("RG3_USER1")
cNome1  := oGrid:GetValue("RG3_NUSER1")
cUser2 	:= oGrid:GetValue("RG3_USER2")
cNome2  := oGrid:GetValue("RG3_NUSER2")
dDtIni  := oGrid:GetValue("RG3_DTINI")
dDtFim  := oGrid:GetValue("RG3_DTFIM")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->FILIAL}") )
aColumns[Len(aColumns)]:SetTitle(STR0008 ) //"Filial"
aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->NOME}") )
aColumns[Len(aColumns)]:SetTitle(STR0009) //"Nome"
aColumns[Len(aColumns)]:SetSize(Len(SM0->M0_NOME))
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

oSize := FwDefSize():New(.F.)

oSize:AddObject( "CABECALHO",(oSize:aWindSize[3]*1.1),(oSize:aWindSize[3]*0.4) , .F., .F. ) // Não dimensionavel
oSize:aMargins 	:= { 0, 0, 0, 0 } 		// Espaco ao lado dos objetos 0, entre eles 3
oSize:lProp 		:= .F. 				// Proporcional
oSize:Process() 	   					// Dispara os calculos

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( STR0010 ) From 0,0 TO 380,930 OF oMainWnd PIXEL //"Selecione as filiais"

// Cria o conteiner onde serão colocados os paineis
oTela2		:= FWFormContainer():New( oDlgGrid )
cIdGrid  	:= oTela2:CreateHorizontalBox( 80 )

oTela2:Activate( oDlgGrid, .F. )

//Cria os paineis onde serao colocados os browses
oPanel4	:= oTela2:GeTPanel( cIdGrid )

@ oSize:GetDimension("CABECALHO","LININI")+1 , oSize:GetDimension("CABECALHO","COLINI")+4	GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090 ,oSize:GetDimension("CABECALHO","COLEND") * 0.431   LABEL OemToAnsi(STR0010) OF oDlgGrid PIXEL
oGroup:oFont:=oFont
@ oSize:GetDimension("CABECALHO","LININI")+9 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY "" Of oDlgGrid Pixel

oMark := FWMarkBrowse():New()

oMark:SetOwner(oPanel4)
oMark:SetAlias(cAliasTRB)
oMark:SetTemporary(.T.)
oMark:SetColumns(aColumns)
oMark:SetFieldMark('OK')
oMark:SetFilterDefault( " (cAliasTRB)->FILIAL <> cFilAux " )
oMark:SetIgnoreARotina(.T.)
oMark:SetMenuDef('')

oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar, cAliasTRB ), oMark:Refresh(.T.)  }

oMark:Activate()

SetMarkAll(oMark:Mark(),.T.,cAliasTRB) //Marca todos os registros

oMark:Refresh(.T.)

ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, {||nOPcX := 1, oDlgGrid:End() } ,{|| oDlgGrid:End() }, NIL, {})

If nOpcX == 1

	//Adiciona filiais selecionadas
	(cAliasTRB)->(dbGoTop())

	While (cAliasTRB)->(!EOF())
		If !Empty((cAliasTRB)->OK) .and. (cAliasTRB)->FILIAL <> cFilAux
			oGrid:AddLine(.T.)

			oGrid:LoadValue("RG3_FILIAL"	,xFilial("RG3", (cAliasTRB)->FILIAL))
			oGrid:LoadValue("RG3_FIL"		,(cAliasTRB)->FILIAL)
			oGrid:LoadValue("RG3_DFIL"	    ,SubStr((cAliasTRB)->NOME,1,15))
			oGrid:LoadValue("RG3_USER1"		,cUser1)
			oGrid:LoadValue("RG3_NUSER1"	,cNome1)
			oGrid:LoadValue("RG3_USER2"		,cUser2)
			oGrid:LoadValue("RG3_NUSER2"	,cNome2)
			oGrid:LoadValue("RG3_DTINI"		,dDtIni)
			oGrid:LoadValue("RG3_DTFIM"		,dDtFim)
		EndIf
		(cAliasTRB)->(dbSkip())
	EndDo

	oGrid:GoLine(1)
EndIf

RestArea(aArea)

Return Nil

/*/{Protheus.doc} SetMarkAll
Marca/Desmarca todas as filiais
@author Leandro Drumond
@since 26/01/2021
@version P12.1.33
@Type     Function
/*/
Static Function SetMarkAll(cMarca,lMarcar,cAliasTRB)

Local cAliasMark := cAliasTRB
Local aAreaMark  := (cAliasMark)->( GetArea() )

dbSelectArea(cAliasMark)
(cAliasMark)->( dbGoTop() )

While !(cAliasMark)->( Eof() )
	RecLock( (cAliasMark), .F. )
	(cAliasMark)->OK := IIf( lMarcar , cMarca, '  ' )
	MsUnLock()
	(cAliasMark)->( dbSkip() )
EndDo

RestArea(aAreaMark)
Return .T.

/*/{Protheus.doc} MenuDef
MenuDef
@author Leandro Drumond
@since 24/01/2021
@version P12.1.33
@Type     Function
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0011  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0 DISABLE MENU 	//"Pesquisar"
	ADD OPTION aRotina TITLE STR0012  ACTION "VIEWDEF.GPEA760" 	OPERATION 2 ACCESS 0 					//"Visualizar"
	ADD OPTION aRotina TITLE STR0013  ACTION "VIEWDEF.GPEA760" 		OPERATION 3 ACCESS 0				//"Incluir"
	ADD OPTION aRotina TITLE STR0014  ACTION "VIEWDEF.GPEA760" 		OPERATION 4 ACCESS 0				//"Alterar"  
	ADD OPTION aRotina TITLE STR0015  ACTION "VIEWDEF.GPEA760" 		OPERATION 5 ACCESS 0				//"Excluir"

Return aRotina

/*/{Protheus.doc} CargaRG3
Carrega registros da tabela RH3
@author Allyson Luiz Mesashi
@since 02/05/2022
@param oGrid, objeto, grid da estrutura a ser carregada
@return aRet, array, array com os registros carregados
/*/
Static Function CargaRG3(oGrid)

Local aAreaRG3	:= RG3->( GetArea() )
Local aRet		:= {}
Local aRet2		:= {}
Local nCont		:= 0
Local nPosRot	:= oGrid:GetIdField("RG3_ROTEIR")

aRet2 := FormLoadGrid(oGrid)

For nCont := 1 To Len(aRet2)
	If AllTrim( aRet2[nCont, 2, nPosRot] ) == "MDT"
		aAdd( aRet, aClone(aRet2[nCont]) )
	EndIf
Next

RestArea(aAreaRG3)

Return aRet 
