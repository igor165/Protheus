#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GPEA950.CH'

/*/{Protheus.doc} GPEA950
Cadastro de Grupo de Beneficios - SWILE
@author Leandro Drumond
@since 27/09/2022
@Type     Function
/*/
Function GPEA950()
Local aCoors  		:= FWGetDialogSize( oMainWnd )
Local cIdBrowse
Local cIdGrid
Local oDlgPrinc
Local oTela
Local oPanelUp
Local oPanelDown
Local oBrowseRUA
Local oBrowseRUB
Local oRelacRUB
Local cFiltraRh
Local lTemSwile		:= !Empty(SuperGetMv( 'MV_APISWI1', Nil, "" )) 
Local lTemRUA 		:= ChkFile("RUA")

If !lTemRUA
	//"Atenção"###"Para utilizar essa rotina é necessário atualização do dicionário de dados com o pacote da 'Integração de Benefícios SWILE'." ### "Consulte a documentação no TDN" 
	Help( " ", 1, OemToAnsi(STR0002), Nil, OemToAnsi(STR0003), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0004) } )
	Return Nil
EndIf

If !lTemSwile
	//"Atenção"###"Os parâmetros MV_APISWI1, MV_APISWI2 e/ou MV_APISWI3 não estão preenchidos."###"Contate o administrador do sistema para revisar a configuração dos parâmetros MV_APISWI1 MV_APISWI2 e/ou MV_APISWI3 no módulo Configurador"
	Help( " ", 1, OemToAnsi(STR0002), Nil, OemToAnsi(STR0005), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0006) } )
	Return Nil
EndIf

DEFINE MsDialog oDlgPrinc Title OemToAnsi(STR0007) From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] OF oMainWnd Pixel  //"Grupos de Benefícios - SWILE"

	// Cria o conteiner onde serão colocados os paineis
	oTela     := FWFormContainer():New( oDlgPrinc )
	cIdBrowse := oTela:CreateHorizontalBox( 50 )
	cIdGrid   := oTela:CreateHorizontalBox( 50 )

	oTela:Activate( oDlgPrinc, .F. )

	//Cria os paineis onde serao colocados os browses
	oPanelUp  	:= oTela:GeTPanel( cIdBrowse )
	oPanelDown  := oTela:GeTPanel( cIdGrid )

	oBrowseRUA 	:= FWMBrowse():New()
	oBrowseRUA:SetOwner( oPanelUp )

	oBrowseRUA:SetAlias("RUA")
	oBrowseRUA:SetDescription(OemToAnsi(STR0007)) //"Grupos de Benefícios - SWILE"
	oBrowseRUA:DisableDetails()
	oBrowseRUA:ForceQuitButton()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFiltraRh := CHKRH("GPEA950","RUA","1")
	oBrowseRUA:SetFilterDefault( cFiltraRh )

	oBrowseRUA:Activate()

	//FWmBrowse Inferior: Benefícios associados
	oBrowseRUB	:= FWMBrowse():New()
	oBrowseRUB:SetOwner( oPanelDown )

	oBrowseRUB:SetDescription( OemToAnsi(STR0008) )	//"Benefícios associados"
	oBrowseRUB:DisableDetails()
	oBrowseRUB:SetAlias( 'RUB' )
	oBrowseRUB:SetCacheView(.F.)
	oBrowseRUB:SetSeek(.F.)
	oBrowseRUB:ExecuteFilter(.F.)
	oBrowseRUB:SetUseFilter(.F.)
	oBrowseRUB:SetMenuDef('')

	// Relacionamento entre os Paineis
	oRelacRUB:= FWBrwRelation():New()
	oRelacRUB:AddRelation( oBrowseRUA  , oBrowseRUB , { { 'xFilial("RUA",RUB->RUB_FILIAL)', 'RUA_FILIAL' },{ 'RUB->RUB_CODGRP', 'RUA->RUA_CODIGO' } } )

	oRelacRUB:Activate()

	oBrowseRUB:Activate()

	oBrowseRUA:Refresh()
	oBrowseRUB:Refresh()

ACTIVATE MsDialog oDlgPrinc Center

Return

/*/{Protheus.doc} ModelDef
Definição e detalhamento do Model
@author Leandro Drumond
@since 27/09/2022
@Type     Function
/*/
Static Function ModelDef()

Local oModel
Local oStructRUA
Local oStructRUB
Local bCommit		:= { |oMdl| Gpea950Grv( oMdl ) }
Local bValid		:= { |oMdl| Gpea950Vld( oMdl ) }

// Criacao do Objeto de Modelagem de dados da tabela RUB //
oModel	:= MPFormModel():New("GPEA950", NIL, bValid , bCommit )

oModel:SetDescription( OemToAnsi(STR0007) ) //"Grupo de Benefícios - SWILE"

// Estrutura de campos do Model //
oStructRUA := FWFormStruct(1, "RUA")

oStructRUB := FWFormStruct(1, "RUB")

oStructRUB:AddField( 	" "			       , ;              // [01] Titulo do campo "Periodo"
						""       		   , ;              // [02] ToolTip do campo
						"RUB_OK"	       , ;              // [03] Id do Field
						"L"           	   , ;              // [04] Tipo do campo
						1		           , ;              // [05] Tamanho do campo
						0         		   , ;              // [06] Decimal do campo
						{|oMdl| fVldMark_Ok(oMdl) } , ;  	// [07] Code-block de validação do campo
						{|oMdl| fWhenOK(oMdl) } , ;   		// [08] Code-block de validação When do campo
										   , ;              // [09] Lista de valores permitido do campo
						.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
						{|| .T.}		   , ;              // [11] Code-block de inicializacao do campo
						NIL                , ;              // [12] Indica se trata-se de um campo chave
						Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
						.T.)          		           		// [14] Indica se o campo é virtual	


oStructRUB:SetProperty( 'RUB_DESCRI', MODEL_FIELD_WHEN, {|| .F. } )
oStructRUB:SetProperty( 'RUB_CODIGO', MODEL_FIELD_WHEN, {|| .F. } )
oStructRUB:SetProperty( 'RUB_CODGRP', MODEL_FIELD_WHEN, {|| .F. } )
oStructRUB:SetProperty( 'RUB_FILBEN', MODEL_FIELD_WHEN, {|| .F. } )
oStructRUB:SetProperty( 'RUB_TPVALE', MODEL_FIELD_WHEN, {|| .F. } )
oStructRUB:SetProperty( 'RUB_VALOR', MODEL_FIELD_WHEN, {|| .F. } )

oModel:AddFields("GPEA950_RUA", NIL, oStructRUA)

oModel:SetPrimaryKey({"RUA_CODIGO"})

oModel:GetModel( "GPEA950_RUA" ):SetDescription( OemToAnsi(STR0007) )  //"Grupo de Benefícios - SWILE"

oModel:AddGrid("GPEA950_RUB", "GPEA950_RUA"/*cOwner*/, oStructRUB , /*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,/*bLoad*/)
oModel:GetModel( "GPEA950_RUB" ):SetOptional(.F.)
oModel:GetModel( "GPEA950_RUB" ):SetNoInsertLine(.T.)
oModel:GetModel( "GPEA950_RUB" ):SetNoDeleteLine(.T.)

oModel:SetRelation("GPEA950_RUB",{{'RUB_FILIAL',"xFilial('RUB')"},{"RUB_CODGRP","RUA_CODIGO"}},RUB->(IndexKey()))

Return( oModel )

/*/{Protheus.doc} ViewDef
Definição da viewdef
@author Leandro Drumond
@since 27/09/2022
@Type     Function
/*/
Static Function ViewDef()
Local oView
Local oModel
Local oStructRUA
Local oStructRUB

// Criacao da Interface //
oView := FWFormView():New()

// Vincular o View ao Model //
oModel := FWLoadModel("GPEA950")
oStructRUA := FWFormStruct(2, "RUA")
oStructRUB := FWFormStruct(2, "RUB")

RemoveFields(@oStructRUB)

oStructRUB:AddField( 	"RUB_OK"              	, ;              // [01] Campo
						"01"  					, ;              // [02] Ordem
						" "                		, ;              // [03] Titulo
						"Ok"                	, ;              // [04] Descricao
						NIL              		, ;              // [05] Help
						"L"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
								                , ;              // [07] Picture
												, ;              // [08] PictVar
												, ;              // [09] F3
						.T.  		            , ;              // [10] Editavel
												, ;              // [11] Folder
						""                		, ;              // [12] Group
												, ;              // [13] Lista Combo
												, ;              // [14] Tam Max Combo
												, ;              // [15] Inic. Browse
						.T.)                                     // [16] Virtual

oView:SetModel(oModel)

oView:CreateHorizontalBox("FIELDS", 70)
oView:CreateHorizontalBox("BOTTOM", 30)

oView:AddField("GPEA950_RUA", oStructRUA)
oView:AddGrid('GPEA950_RUB' , oStructRUB)

oView:addUserButton( OemTOAnsi(STR0009) + " (F6)"	,"MAGIC_BMP", {|oModel| MsAguarde( { || LoadBenef(oModel) } , OemtoAnsi(STR0010)) }	,OemToAnsi(STR0009),VK_F6	, {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} ) //"Carregar Benefícios" ### "Carregando Benefícios..."

oView:SetOwnerView("GPEA950_RUA", "FIELDS")
oView:SetOwnerView("GPEA950_RUB", "BOTTOM")

Return oView

/*/{Protheus.doc} fWhenOK
Habilita o campo para seleção apenas se as colunas estiver preenchidas.
@author Leandro Drumond
@since 27/09/2022
@Type     Function
/*/
Static Function fWhenOK(oGrid)
Local lRet 			:= .T.

If Empty(oGrid:GetValue("RUB_CODIGO"))
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} LoadBenef
Seleciona os benefícios que serão associados ao grupo
@author Leandro Drumond
@since 27/09/2022
@Type     Function
/*/
Static Function LoadBenef(oModel)
Local aArea 		:= GetArea()
Local aStru  		:= {}
Local aLstIndices	:= {}
Local aColumns		:= {}
Local aPesq			:= {}
Local aTpVale 		:= {}
Local oGrid			:= oModel:GetModel("GPEA950_RUB")
Local cBenef	    := ""
Local cIdGrid		:= ""
Local cAliasBen 	:= ""
Local cFilRFO		:= ""
Local cFilSRN		:= ""
Local cFilRUB 		:= xFilial("RUB")
Local lDifFil		:= xFilial("RUA") <> xFilial("RFO")
Local cCodGrp 		:= oModel:GetModel("GPEA950_RUA"):GetValue("RUA_CODIGO")
Local nTam          := oGrid:Length()
Local nX 			:= 0
Local nOpcX			:= 0
Local oSize
Local oTela
Local oDlgGrid
Local oPanel
Local oMark
Local oFont
Local oGroup
Local lInclui
Local lMarcar 		:= .T.

Private cAliasTRB

If Empty(cCodGrp)
	//"Atenção" ### "O código do grupo de benefícios não foi informado." ### "Informe o código do grupo antes de incluir benefícios."
	Help( " ", 1, OemToAnsi(STR0002), Nil, OemToAnsi(STR0011), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0012) } )
	Return Nil
EndIf

For nX := 1 to nTam
	oGrid:GoLine(nX)
	If oGrid:GetValue("RUB_OK")
		cBenef += oGrid:GetValue("RUB_FILBEN") + oGrid:GetValue("RUB_TPVALE") + oGrid:GetValue("RUB_CODIGO") + "#"
	EndIf
Next nX

Static cAliasTmp
Static oArqTmp

If oArqTmp == Nil //Monta temporária com filiais disponíveis
	Aadd(aStru, {"OK"		, "C", 2						, 0})
	Aadd(aStru, {"FILIAL"	, "C", FwGetTamFilial			, 0})
	Aadd(aStru, {"TPVALE"  	, "C", 1						, 0})
	Aadd(aStru, {"CODIGO"  	, "C", 3						, 0})
	Aadd(aStru, {"NOME"  	, "C", 40						, 0})
	Aadd(aStru, {"VALOR"  	, "N", 12						, 2})
	AAdd(aLstIndices, {"FILIAL","TPVALE","CODIGO"})
	AAdd(aLstIndices, {"NOME"})

	cAliasTmp := cAliasTRB := GetNextAlias()

	oArqTmp := RhCriaTrab(cAliasTRB, aStru, aLstIndices)

	cAliasBen := GetNextAlias()

	cFilRFO		:= If(lDifFil, FWJoinFilial("RFO","RUA"), "RFO.RFO_FILIAL = '" + xFilial("RUA") + "'")
	cFilSRN		:= If(lDifFil, FWJoinFilial("SRN","RUA"), "SRN.RN_FILIAL = '" + xFilial("RUA") + "'")

	cFilRFO		:= If(lDifFil, SubStr(cFilRFO,1,At("=",cFilRFO)) + " '" + RTrim(xFilial("RUA")) + "'", cFilRFO)
	cFilSRN		:= If(lDifFil, SubStr(cFilSRN,1,At("=",cFilSRN)) + " '" + RTrim(xFilial("RUA")) + "'", cFilSRN)

	cFilRFO		:= "% " + cFilRFO + " %"
	cFilSRN		:= "% " + cFilSRN + " %"

	BeginSql alias cAliasBen
		SELECT RFO_FILIAL,RFO_TPVALE,RFO_CODIGO,RFO_DESCR,RFO_VALOR
		FROM %table:RFO% RFO
		WHERE  RFO.%notDel%  AND %exp:cFilRFO%
		UNION ALL 
		SELECT RN_FILIAL, "3", RN_COD, RN_DESC, RN_VUNIATU
		FROM %table:SRN% SRN 
		WHERE SRN.%notDel% AND %exp:cFilSRN%
		ORDER BY RFO_FILIAL, RFO_TPVALE, RFO_CODIGO
	EndSql

	While (cAliasBen)->( !Eof() )
		RecLock(cAliasTRB, .T.)
		(cAliasTRB)->FILIAL	:= (cAliasBen)->RFO_FILIAL
		(cAliasTRB)->TPVALE	:= (cAliasBen)->RFO_TPVALE
		(cAliasTRB)->CODIGO	:= (cAliasBen)->RFO_CODIGO
		(cAliasTRB)->NOME	:= (cAliasBen)->RFO_DESCR
		(cAliasTRB)->VALOR	:= (cAliasBen)->RFO_VALOR
		(cAliasTRB)->(MsUnlock())

		(cAliasBen)->(DbSkip())
	EndDo

	(cAliasBen)->( dbCloseArea() )
Else 
	cAliasTRB := cAliasTmp
EndIf

aTpVale := Gp950CBOX(.F.,.T.)

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->FILIAL}") )
aColumns[Len(aColumns)]:SetTitle(OemToAnsi(STR0013)) //"Filial"
aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->TPVALE}") )
aColumns[Len(aColumns)]:SetTitle(OemToAnsi(STR0014)) //"Tipo"
aColumns[Len(aColumns)]:SetSize(1)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")
aColumns[Len(aColumns)]:SetOptions(aTpVale)

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->CODIGO}") )
aColumns[Len(aColumns)]:SetTitle(OemToAnsi(STR0015)) //"Código"
aColumns[Len(aColumns)]:SetSize(3)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->NOME}") )
aColumns[Len(aColumns)]:SetTitle(OemToAnsi(STR0016)) //"Descrição"
aColumns[Len(aColumns)]:SetSize(40)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->VALOR}") )
aColumns[Len(aColumns)]:SetTitle(OemToAnsi(STR0017)) //"Valor"
aColumns[Len(aColumns)]:SetSize(12)
aColumns[Len(aColumns)]:SetDecimal(2)
aColumns[Len(aColumns)]:SetPicture("@E 999,999,999.99")

Aadd( aPesq , {	OemToAnsi(STR0015), { { "CODIGO"   , "C", 02 , 0, "CODIGO", "@!"}}, 1}) //"Código"
Aadd( aPesq , {	OemToAnsi(STR0016), { { "NOME   "  , "C", 40 , 0, "NOME"  , "@!"}}, 1}) //"Descrição"

oSize := FwDefSize():New(.F.)

oSize:AddObject( "CABECALHO",(oSize:aWindSize[3]*1.1),(oSize:aWindSize[3]*0.4) , .F., .F. ) // Não dimensionavel
oSize:aMargins 	:= { 0, 0, 0, 0 } 		// Espaco ao lado dos objetos 0, entre eles 3
oSize:lProp 		:= .F. 				// Proporcional
oSize:Process() 	   					// Dispara os calculos

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( STR0018 ) From 0,0 TO 600,1230 OF oMainWnd PIXEL //"Selecione os benefícios que serão associados"

// Cria o conteiner onde serão colocados os paineis
oTela		:= FWFormContainer():New( oDlgGrid )
cIdGrid  	:= oTela:CreateHorizontalBox( 80 )

oTela:Activate( oDlgGrid, .F. )

//Cria os paineis onde serao colocados os browses
oPanel	:= oTela:GeTPanel( cIdGrid )

@ oSize:GetDimension("CABECALHO","LININI")+1 , oSize:GetDimension("CABECALHO","COLINI")+4	GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090 ,oSize:GetDimension("CABECALHO","COLEND") * 0.431  OF oDlgGrid PIXEL
oGroup:oFont:=oFont
@ oSize:GetDimension("CABECALHO","LININI")+9 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY "" Of oDlgGrid Pixel

oMark := FWMarkBrowse():New()

oMark:SetOwner(oPanel)
oMark:SetAlias(cAliasTRB)
oMark:SetTemporary(.T.)
oMark:SetColumns(aColumns)
oMark:SetFieldMark('OK')
oMark:SetFilterDefault( "" )
oMark:SetIgnoreARotina(.T.)
oMark:SetMenuDef('')
oMark:SetSeek( .T., aPesq )

oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar, cAliasTRB ), oMark:Refresh(.T.)  }

oMark:Activate()

SetMarkAll(oMark:Mark(),.F.,cAliasTRB,cBenef) //Desmarca todos os registros

oMark:Refresh(.T.)

ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, {||nOpcX := 1, oDlgGrid:End() } ,{|| oDlgGrid:End() }, NIL, {})

If nOpcX == 1

	//Adiciona filiais selecionadas
	(cAliasTRB)->(dbGoTop())

	lInclui := !Empty(cBenef)

	If lInclui
		For nX := 1 to nTam //Desmarca todos os sindicatos
			oGrid:GoLine(nX)
			oGrid:LoadValue("RUB_OK",.F.)
		Next nX
	Else 
		oGrid:GoLine(1)
	EndIf

	While (cAliasTRB)->(!EOF())
		If !Empty((cAliasTRB)->OK)
			
			If lInclui
				If !oGrid:SeekLine({{"RUB_FILBEN",(cAliasTRB)->FILIAL},{"RUB_TPVALE",(cAliasTRB)->TPVALE},{"RUB_CODIGO",(cAliasTRB)->CODIGO}})
					oGrid:AddLine(.T.) //Se não encontrar, adiciona uma linha
				EndIf
			EndIf

			oGrid:LoadValue("RUB_FILIAL"	,cFilRUB)
			oGrid:LoadValue("RUB_CODGRP"	,cCodGrp)
			oGrid:LoadValue("RUB_FILBEN"	,(cAliasTRB)->FILIAL)
			oGrid:LoadValue("RUB_TPVALE"	,(cAliasTRB)->TPVALE)
			oGrid:LoadValue("RUB_CODIGO"	,(cAliasTRB)->CODIGO)
			oGrid:LoadValue("RUB_DESCRI"    ,(cAliasTRB)->NOME)
			oGrid:LoadValue("RUB_VALOR"     ,(cAliasTRB)->VALOR)
			oGrid:LoadValue("RUB_OK"		,.T.)

			lInclui := .T.
		EndIf
		(cAliasTRB)->(dbSkip())
	EndDo

	oGrid:GoLine(1)
EndIf

RestArea(aArea)

Return Nil

/*/{Protheus.doc} SetMarkAll
Marca/Desmarca os registros
@author Leandro Drumond
@since 27/09/2022
@version P12.1.33
@Type     Function
/*/
Static Function SetMarkAll(cMarca,lMarcar,cAliasTRB,cMarcados)

Local cAliasMark := cAliasTRB
Local aAreaMark  := (cAliasMark)->( GetArea() )

DEFAULT cMarca := ""

dbSelectArea(cAliasMark)
(cAliasMark)->( dbGoTop() )

While !(cAliasMark)->( Eof() )
	RecLock( (cAliasMark), .F. )
	If !Empty(cMarcados)
		If (cAliasMark)->FILIAL + (cAliasMark)->TPVALE + (cAliasMark)->CODIGO $ cMarcados 
			(cAliasMark)->OK := cMarca
		Else 
			(cAliasMark)->OK := '  '
		EndIf
	Else
		(cAliasMark)->OK := IIf( lMarcar , cMarca, '  ' )
	EndIf
	MsUnLock()
	(cAliasMark)->( dbSkip() )
EndDo

RestArea(aAreaMark)

Return .T.

/*/{Protheus.doc} RemoveFields
Deixa apenas o código do benefício e descrição no grid
@author Leandro Drumond
@since 27/09/2022
@Type     Function
/*/
Static Function RemoveFields(oStruct)
Local aAux 		:= aClone(oStruct:GetFields())
Local nX 		:= 0

For nX := 1 to Len(aAux)
	If (aAux[nX, MVC_VIEW_IDFIELD ] $ "RUB_FILIAL*RUB_CODGRP")
		oStruct:RemoveField(aAux[nX, MVC_VIEW_IDFIELD ])
	EndIf
Next nX

Return Nil

/*/{Protheus.doc} GPEA950Grv
Efetua gravação do modelo de dados
@author Leandro Drumond
@since 27/09/2022
@Type     Function
/*/
Static Function GPEA950Grv( oModel )
Local nOperation  := oModel:GetOperation()
Local oGrid
Local nTam
Local nX
Local lRet			:= .T.

If nOperation == 3 .or. nOperation == 4
	
	oGrid := oModel:GetModel("GPEA950_RUB")
	oModel:GetModel( "GPEA950_RUB" ):SetNoDeleteLine(.F.)
	nTam  := oGrid:Length()
	For nX := 1 to nTam
		oGrid:GoLine(nX)
		If !oGrid:GetValue("RUB_OK") .or. Empty(oGrid:GetValue("RUB_CODIGO"))
			oGrid:DeleteLine() //Se a linha foi desmarcada, deixa
		EndIf
	Next nX
	oModel:GetModel( "GPEA950_RUB" ):SetNoDeleteLine(.T.)		
EndIf

FWFormCommit( oModel )

Return lRet

/*/{Protheus.doc} GPEA950Vld
Efetua validação do modelo de dados
@author Leandro Drumond
@since 27/09/2022
@Type     Function
/*/
Static Function GPEA950Vld( oModel )
Local nOperation  	:= oModel:GetOperation()
Local oGrid
Local nTamGrid 		:= 0
Local nX 			:= 0
Local lRet			:= .T.

Begin Sequence

	If nOperation <> 5 //--Exclusão
		oGrid := oModel:GetModel("GPEA950_RUB")
		lRet := .F.
		nTamGrid := oGrid:Length()
		If nTamGrid > 0
			For nX := 1 to nTamGrid
				oGrid:GoLine(nX)
				If oGrid:GetValue("RUB_OK") .and. !Empty(oGrid:GetValue("RUB_CODIGO"))
					lRet := .T.
					Exit
				EndIf 
			Next nX
		EndIf
		If !lRet
			//"Atenção" ### "Nenhum benefício associado ao grupo" ### "Associe ao menos um benefício ao grupo"
			Help(,, OemToAnsi(STR0002),, OemToAnsi(STR0019) , 1, 0,,,,,, { OemToAnsi(STR0020)})
		EndIf
	EndIf

End Sequence

Return lRet

/*/{Protheus.doc} fVldMark_Ok
Confirma desassociação do benefício
@author Leandro Drumond
@since 27/09/2022
@Type     Function
/*/
Static Function fVldMark_Ok(oModel)

If !M->RUB_OK 
	If !MsgYesNo(OemToAnsi(STR0021) + CRLF + CRLF + "") //"Desassociar este benefício do grupo?"
		oModel:LoadValue("RUB_OK", .T.) //Se não confirmar, volta valor para true
	EndIf
EndIf

Return .T.

/*/{Protheus.doc} Gp950CBOX
Monta combo dos tipos de benefícios disponíveis
@author Leandro Drumond
@since 27/09/2022
@version P12.1.33
@Type     Function
/*/
Function Gp950CBOX(lValid,lArray)
Local uRet

DEFAULT lValid := .F.
DEFAULT lArray := .F.

If lArray
	uRet := {}
	aAdd(uRet,  "1=" + OemToAnsi(STR0022)) //"Vale Refeição"
	aAdd(uRet,  "2=" + OemToAnsi(STR0023)) //"Vale Alimentação"
	aAdd(uRet,  "3=" + OemToAnsi(STR0024)) //"Vale Transporte"
ElseIf lValid
	uRet := "1*2*3"
Else 
	uRet := ( "1=" + OemToAnsi(STR0022) + ";" )	//"Vale Refeição"
	uRet += ( "2=" + OemToAnsi(STR0023) + ";" )	//"Vale Alimentação"
	uRet += ( "3=" + OemToAnsi(STR0024)       )	//"Vale Transporte"	
EndIf

Return uRet

/*/{Protheus.doc} MenuDef
Definição do MenuDef
@author Leandro Drumond
@since 27/09/2022
@Type     Function
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0025)  Action 'PesqBrw'           OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0026)  Action 'VIEWDEF.GPEA950'   OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0027)  Action 'VIEWDEF.GPEA950'   OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title OemToAnsi(STR0028)  Action 'VIEWDEF.GPEA950'   OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0029)  Action 'VIEWDEF.GPEA950'   OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina
