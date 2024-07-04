#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA238.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA238
Cadastro de Horários / Turnos de Trabalho

@author Anderson Costa
@since 23/08/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function TAFA238()

	Private oBrw := FWmBrowse():New()
	
	If FindFunction("TAFDesEven")
		TAFDesEven()
	EndIf

	If TafAtualizado()
		oBrw:SetDescription(STR0001) //"Cadastro de Horários / Turnos de Trabalho"
		oBrw:SetAlias('C90')
		oBrw:SetMenuDef( 'TAFA238' )
		oBrw:SetFilterDefault( "C90_ATIVO == '1' .Or. (C90_EVENTO == 'E' .And. C90_STATUS = '4' .And. C90_ATIVO = '2')" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )

		oBrw:AddLegend( "C90_EVENTO == 'I' ", "GREEN" , STR0013 ) //"Registro Incluído"
		oBrw:AddLegend( "C90_EVENTO == 'A' ", "YELLOW", STR0014 ) //"Registro Alterado"
		oBrw:AddLegend( "C90_EVENTO == 'E' .And. C90_STATUS <> '4' ", "RED"   , STR0015 ) //"Registro excluído não transmitido"
		oBrw:AddLegend( "C90_EVENTO == 'E' .And. C90_STATUS == '4' .And. C90_ATIVO = '2' ", "BLACK"   , STR0016 ) //"Registro excluído transmitido"

		oBrw:Activate()
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Anderson Costa
@since 23/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "TafxmlRet('TAF238Xml','1050','C90')" , "1" } )
Aadd( aFuncao, { "" , "xFunHisAlt( 'C90', 'TAFA238',,,,'TAF238XML','1050'  )" , "3" } )
aAdd( aFuncao, { "" , "TAFXmlLote( 'C90', 'S-1050' , 'evtTabHorTur' , 'TAF238Xml',,oBrw )" , "5" } )
Aadd( aFuncao, { "" , "xFunAltRec( 'C90' )" , "10" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif .Or. ViewEvent('S-1050')
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA238' OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA238" , , aFuncao)
EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Anderson Costa
@since 23/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC90 := FWFormStruct( 1, 'C90' )
Local oStruCRL := FWFormStruct( 1, 'CRL' )
Local oModel := MPFormModel():New( 'TAFA238' , , , {|oModel| SaveModel(oModel)})

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStruC90:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
EndIf

oModel:AddFields('MODEL_C90', /*cOwner*/, oStruC90)

oModel:AddGrid("MODEL_CRL","MODEL_C90",oStruCRL)
oModel:GetModel("MODEL_CRL"):SetOptional(.T.)
oModel:GetModel("MODEL_CRL"):SetUniqueLine({"CRL_TPINTE","CRL_DURINT","CRL_INIINT","CRL_FIMINT","CRL_CODSEQ"})

oModel:SetRelation("MODEL_CRL",{ {"CRL_FILIAL","xFilial('CRL')"}, {"CRL_ID","C90_ID"}, {"CRL_VERSAO","C90_VERSAO"} },CRL->(IndexKey(1)) )

oModel:GetModel('MODEL_C90'):SetPrimaryKey({'C90_FILIAL', 'C90_ID', 'C90_VERSAO'})


Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Anderson Costa
@since 23/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel( 'TAFA238' )
Local oStruC90 := FWFormStruct( 2, 'C90' )
Local oStruCRL := FWFormStruct( 2, 'CRL' )
Local oView    := FWFormView():New()

oStruCRL:SetProperty( "CRL_CODSEQ"	, MVC_VIEW_ORDEM, "04" )
oStruCRL:SetProperty( "CRL_INIINT"	, MVC_VIEW_ORDEM, "05" )
oStruCRL:SetProperty( "CRL_FIMINT"	, MVC_VIEW_ORDEM, "06" )
oStruCRL:SetProperty( "CRL_TPINTE"	, MVC_VIEW_ORDEM, "07" )
oStruCRL:SetProperty( "CRL_DURINT"	, MVC_VIEW_ORDEM, "08" )

oStruCRL:RemoveField( "C1E_CODSEQ" )

oView:SetModel( oModel )
oView:AddField( 'VIEW_C90', oStruC90, 'MODEL_C90' )

If FindFunction("TafAjustRecibo")
	TafAjustRecibo(oStruC90,"C90")
EndIf

oView:EnableTitleView( 'VIEW_C90', STR0001 )    //"Cadastro de Horários / Turnos de Trabalho"

oView:AddGrid("VIEW_CRL",oStruCRL,"MODEL_CRL")
oView:EnableTitleView("VIEW_CRL",STR0010) //"Horários de Intervalo"

oView:CreateHorizontalBox( 'FIELDSC90', 40 )
oView:CreateHorizontalBox("CRL",60)

oView:SetOwnerView( 'VIEW_C90', 'FIELDSC90' )
oView:SetOwnerView("VIEW_CRL","CRL")

oView:AddIncrementField("VIEW_CRL" , "CRL_CODSEQ")

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif
	xFunRmFStr(@oStruC90, 'C90')
EndIf

If TafColumnPos( "C90_LOGOPE" )
	oStruC90:RemoveField( "C90_LOGOPE" )
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF238Grv
@type			function
@description	Função de gravação para atender o registro S-1050 ( Tabela de Horários e Turnos de Trabalho ).
@author			Anderson Costa
@since			04/10/2013
@version		1.0
@param			cLayout		-	Nome do Layout que está sendo enviado
@param			nOpc		-	Opção a ser realizada ( 3 = Inclusão, 4 = Alteração, 5 = Exclusão )
@param			cFilEv		-	Filial do ERP para onde as informações deverão ser importadas
@param			oXML		-	Objeto com as informações a serem manutenidas ( Outras Integrações )
@param			cOwner
@param			cFilTran
@param			cPredeces
@param			nTafRecno
@param			cComplem
@param			cGrpTran
@param			cEmpOriGrp
@param			cFilOriGrp
@param			cXmlID		-	Atributo Id, único para o XML do eSocial. Utilizado para importação de dados de clientes migrando para o TAF
@return			lRet		-	Variável que indica se a importação foi realizada, ou seja, se as informações foram gravadas no banco de dados
@param			aIncons		-	Array com as inconsistências encontradas durante a importação
/*/
//-------------------------------------------------------------------
Function TAF238Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

Local cLogOpeAnt	:=	""
Local cCabec		:=	"/eSocial/evtTabHorTur/infoHorContratual"
Local cCmpsNoUpd	:=	"|C90_FILIAL|C90_ID|C90_VERSAO|C90_DTINI|C90_DTFIN|C90_VERANT|C90_PROTUL|C90_PROTPN|C90_EVENTO|C90_STATUS|C90_ATIVO|C90_TPJORN|C90_DTPJOR|C90_TPINT|C90_DURINT|C90_DELENT|C90_DELSAI"
Local cValChv		:=	""
Local cNewDtIni		:=	""
Local cNewDtFin		:=	""
Local cInconMsg		:=	""
Local cCodEvent		:=	Posicione( "C8E", 2, xFilial( "C8E" ) + "S-" + cLayout, "C8E->C8E_ID" )
Local cChave		:=	""
Local cPerIni		:=	""
Local cPerFin		:=	""
Local cPerIniOri	:=	""
Local nIndChv		:=	2
Local nIndIDVer		:=	1
Local nlI			:=	0
Local nTamCod		:=	TamSX3( "C90_CODIGO" )[1]
Local nCRL			:=	0
Local nJ			:=	0
Local lRet			:=	.F.
Local aIncons		:=	{}
Local aRules		:=	{}
Local aChave		:=	{}
Local aNewData		:=	{ Nil, Nil } 
Local oModel		:=	Nil
Local lNewValid		:= .F.

Private lVldModel	:=	.T. //Caso a chamada seja via integração, seto a variável de controle de validação como .T.
Private oDados		:=	Nil

Default cLayout		:=	""
Default nOpc		:=	1
Default cFilEv		:=	""
Default oXML		:=	Nil
Default cOwner		:=	""
Default cFilTran	:=	""
Default cPredeces	:=	""
Default nTafRecno	:=	0
Default cComplem	:=	""
Default cGrpTran	:=	""
Default cEmpOriGrp	:=	""
Default cFilOriGrp	:=	""
Default cXmlID		:=	""

oDados := oXML

If nOpc == 3
	cTagOper := "/inclusao"
ElseIf nOpc == 4
	cTagOper := "/alteracao"
ElseIf nOpc == 5
	cTagOper := "/exclusao"
EndIf

//Verificar se o codigo foi informado para a chave ( Obrigatorio ser informado )
cValChv := FTafGetVal( cCabec + cTagOper + "/ideHorContratual/codHorContrat", 'C', .F., @aIncons, .F., '', '' )
If !Empty( cValChv )
	Aadd( aChave, { "C", "C90_CODIGO", cValChv, .T.} )
	nIndChv := 4
	cChave += Padr(cValChv,nTamCod)
EndIf

//Verificar se a data inicial foi informado para a chave( Se nao informado sera adotada a database internamente )
cValChv := FTafGetVal( cCabec + cTagOper + "/ideHorContratual/iniValid", 'C', .F., @aIncons, .F., '', '' )
cValChv := TAF238Format("C90_DTINI", cValChv)
If !Empty( cValChv )
	Aadd( aChave, { "C", "C90_DTINI", cValChv, .T. } )
	nIndChv := 5
	cPerIni := cValChv
	cPerIniOri := cValChv
EndIf

//Verificar se a data final foi informado para a chave( Se nao informado sera adotado vazio )
cValChv := FTafGetVal( cCabec + cTagOper + "/ideHorContratual/fimValid", 'C', .F., @aIncons, .F., '', '' )
cValChv := TAF238Format("C90_DTFIN", cValChv)
If !Empty( cValChv )
	Aadd( aChave, { "C", "C90_DTFIN", cValChv, .T.} )
	nIndChv := 2
	cPerFin := cValChv
EndIf

If nOpc == 4
	If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', '' )
		cNewDtIni 	:= TAF238Format("C90_DTINI", FTafGetVal( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', '' ))
		aNewData[1] := cNewDtIni
		cPerIni 	:= cNewDtIni
		lNewValid	:= .T.
	EndIf

	If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', '' )
		cNewDtFin 	:= TAF238Format("C90_DTFIN", FTafGetVal( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', '' ))
		aNewData[2] := cNewDtFin
		cPerFin		:= cNewDtFin
		lNewValid	:= .T.
	EndIf
EndIf

//Valida as regras da nova validade
If Empty(aIncons)
	VldEvTab( "C90", 5, cChave, cPerIni, cPerFin, 2, nOpc, @aIncons, cPerIniOri,,, lNewValid )
EndIf

If Empty(aIncons)

	Begin Transaction

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao para validar se a operacao desejada pode ser realizada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FTafVldOpe( "C90", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA238", cCmpsNoUpd, nIndIDVer, .T., aNewData )

			If TafColumnPos( "C90_LOGOPE" )
				cLogOpeAnt := C90->C90_LOGOPE
			endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
			//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Carrego array com os campos De/Para de gravacao das informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRules := TAF238Rul( cTagOper, cCodEvent, cOwner )

				oModel:LoadValue( "MODEL_C90", "C90_FILIAL", C90->C90_FILIAL )

				If TAFColumnPos( "C90_XMLID" )
					oModel:LoadValue( "MODEL_C90", "C90_XMLID", cXmlID )
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o aRules para gravar as informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nlI := 1 To Len( aRules )
					cValorXml := FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F., , aRules[ nlI, 01 ] )
					cValorXml := TAF238Format(aRules[ nlI, 01 ], cValorXml)
					oModel:LoadValue( "MODEL_C90", aRules[ nlI, 01 ], cValorXml)
				Next

				If Findfunction("TAFAltMan")
					if nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C90', 'C90_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C90', 'C90_LOGOPE' , '', cLogOpeAnt )
					EndIf
				endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando se trata de uma alteracao deleto todas as linhas do Grid³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (nOpc == 4)
					For nJ := 1 to oModel:GetModel( 'MODEL_CRL' ):Length()
						oModel:GetModel( 'MODEL_CRL' ):GoLine(nJ)
						oModel:GetModel( 'MODEL_CRL' ):DeleteLine()
					Next nJ
				EndIf

				/* Esse layout, possui registros 'filhos'(horarioIntervalo). Então faço o controle para salvar
			 	a quantidade de nós que estiverem no xml para os 'filhos'.*/
				nCRL := 1
				While oDados:XPathHasNode(cCabec + cTagOper + "/dadosHorContratual/horarioIntervalo[" + CVALTOCHAR(nCRL) + "]"  )
					If (nCRL > 1) .Or. (nOpc == 4)
						// é necessário atribuir LVALID para que permita o addline();
						oModel:GetModel( "MODEL_CRL" ):LVALID := .T.
						oModel:GetModel( "MODEL_CRL" ):AddLine()
					EndIf

					if oDados:XPathHasNode(cCabec + cTagOper + "/dadosHorContratual/horarioIntervalo[" + CVALTOCHAR(nCRL) + "]/tpInterv")
						oModel:LoadValue( "MODEL_CRL", "CRL_TPINTE", FTafGetVal(cCabec + cTagOper + "/dadosHorContratual/horarioIntervalo[" + CVALTOCHAR(nCRL) + "]/tpInterv"   , "C", .F., @aIncons, .F.))
					EndIf


					if oDados:XPathHasNode(cCabec + cTagOper + "/dadosHorContratual/horarioIntervalo[" + CVALTOCHAR(nCRL) + "]/durInterv")
						oModel:LoadValue( "MODEL_CRL", "CRL_DURINT", FTafGetVal(cCabec + cTagOper + "/dadosHorContratual/horarioIntervalo[" + CVALTOCHAR(nCRL) + "]/durInterv"  , "C", .F., @aIncons, .F.))
					EndIf


					if oDados:XPathHasNode(cCabec + cTagOper + "/dadosHorContratual/horarioIntervalo[" + CVALTOCHAR(nCRL) + "]/iniInterv")
						oModel:LoadValue( "MODEL_CRL", "CRL_INIINT", FTafGetVal( cCabec + cTagOper + "/dadosHorContratual/horarioIntervalo[" + CVALTOCHAR(nCRL) + "]/iniInterv" , "C", .F., @aIncons, .F.))
					EndIF


					if oDados:XPathHasNode(cCabec + cTagOper + "/dadosHorContratual/horarioIntervalo[" + CVALTOCHAR(nCRL) + "]/termInterv")
						oModel:LoadValue( "MODEL_CRL", "CRL_FIMINT", FTafGetVal( cCabec + cTagOper + "/dadosHorContratual/horarioIntervalo[" + CVALTOCHAR(nCRL) + "]/termInterv", "C", .F., @aIncons, .F.))
					EndIf
					oModel:LoadValue( "MODEL_CRL" , "CRL_CODSEQ" , StrZero( nCRL , 3 ) )
					nCRL := nCRL + 1
				EndDo
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetiva a operacao desejada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cInconMsg) .And. Empty(aIncons)
				If TafFormCommit( oModel )
					Aadd(aIncons, "ERRO19")
				Else
					lRet := .T.
				EndIf
			Else
				Aadd(aIncons, cInconMsg)
				DisarmTransaction()
			EndIf

			oModel:DeActivate()
			If FindFunction('TafClearModel')
				TafClearModel(oModel)
			EndIf
		EndIf

	End Transaction

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zerando os arrays e os Objetos utilizados no processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize( aRules, 0 )
aRules     := Nil

aSize( aChave, 0 )
aChave     := Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF238Rul

Regras para gravacao das informacoes do registro S-1050 do E-Social

@Param
cTagOper - Tag de indicacao da operacao

@Return
aRull  - Regras para a gravacao das informacoes

@author Anderson Costa
@since 04/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF238Rul( cTagOper, cCodEvent, cOwner  )

Local aRull := {}
Local cCabec := "/eSocial/evtTabHorTur/infoHorContratual"

Default cTagOper	:= ""
Default cCodEvent	:= ""
Default cOwner	:= ""

if TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/ideHorContratual/codHorContrat"))
	aAdd( aRull, { "C90_CODIGO", cCabec + cTagOper + "/ideHorContratual/codHorContrat"           , "C", .F. } ) //codJornada
EndIf

if TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/ideHorContratual/codHorContrat" ))
	aAdd( aRull, { "C90_DESCRI", cCabec + cTagOper + "/ideHorContratual/codHorContrat"           , "C", .F. } ) //codJornada
EndIf

if TafXNode(oDados , cCodEvent, cOwner,( cCabec + cTagOper + "/dadosHorContratual/hrEntr" ))
	Aadd( aRull, { "C90_HRENT", cCabec + cTagOper + "/dadosHorContratual/hrEntr"                 , "C", .F. } ) //hrEntr
EndIf

if TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosHorContratual/hrSaida"))
	Aadd( aRull, { "C90_HRSAI", cCabec + cTagOper + "/dadosHorContratual/hrSaida"                , "C", .F. } ) //hrSaida
EndIf

if TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosHorContratual/durJornada" ))
	Aadd( aRull, { "C90_DURJOR",cCabec + cTagOper + "/dadosHorContratual/durJornada"             , "C", .F. } ) //durJornada
EndIf

if TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosHorContratual/perHorFlexivel"))
	Aadd( aRull, { "C90_PERFLH",cCabec + cTagOper + "/dadosHorContratual/perHorFlexivel"         , "C", .F. } ) //perHorFlexivel
EndIf

Return ( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF238Format

Formata os campos do registro S-1040 do E-Social

@Param
cCampo 	  - Campo que deve ser formatado
cValorXml - Valor a ser formatado

@Return
cFormatValue - Valor já formatado

@author Vitor Siqueira
@since 07/10/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF238Format(cCampo, cValorXml)

Local cFormatValue, cRet := ''

If (cCampo == 'C90_DTINI' .Or. cCampo == 'C90_DTFIN')
	cFormatValue := StrTran( StrTran( cValorXml, "-", "" ), "/", "")
	cRet := Substr(cFormatValue, 5, 2) + Substr(cFormatValue, 1,4)
ElseIf (cCampo = 'C90_PERFLH')
	cRet := xFunTrcSN(cValorXml, 2)
Else
	cRet := cValorXml
EndIf

Return( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Anderson Costa
@Since 07/10/2013
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local cLogOpe		
Local cLogOpeAnt	

Local cVerAnt		:= ""
Local cProtocolo	:= ""
Local cEvento		:= ""
Local cVersao		:= ""
Local cChvRegAnt	:= ""
Local nOperation	:= oModel:GetOperation()
Local nC90, nCRL	:= 0
Local aGrava		:= {}
Local aGravaCRL		:= {}
Local oModelC90		:= Nil
Local oModelCRL		:= Nil
Local lRetorno		:= .T.

cLogOpe		:= ""
cLogOpeAnt	:= ""

Begin Transaction

	If nOperation == MODEL_OPERATION_INSERT
	
		TafAjustID( "C90", oModel)
		
		oModel:LoadValue( "MODEL_C90", "C90_VERSAO", xFunGetVer() )

		If Findfunction("TAFAltMan")
			TAFAltMan( 3 , 'Save' , oModel, 'MODEL_C90', 'C90_LOGOPE' , '2', '' )
		endif

		FwFormCommit( oModel )

	ElseIf nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_DELETE

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seek para posicionar no registro antes de realizar as validacoes,³
		//³visto que quando nao esta posicionado nao eh possivel analisar   ³
		//³os campos nao usados como _STATUS                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    C90->( DbSetOrder( 3 ) )
	    If C90->( MsSeek( xFilial( 'C90' ) + FwFldGet('C90_ID') + '1' ) )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o registro ja foi transmitido³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If C90->C90_STATUS == "4"

				oModelC90 := oModel:GetModel( "MODEL_C90" )
				oModelCRL := oModel:GetModel( "MODEL_CRL" )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busco a versao anterior do registro para gravacao do rastro³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cVerAnt    := oModelC90:GetValue( "C90_VERSAO" )
				cProtocolo := oModelC90:GetValue( "C90_PROTUL" )
				cEvento    := oModelC90:GetValue( "C90_EVENTO" )

				If TafColumnPos( "C90_LOGOPE" )
					cLogOpeAnt := oModelC90:GetValue( "C90_LOGOPE" )
				endif

				If nOperation == MODEL_OPERATION_DELETE .And. cEvento == "E"
					// Não é possível excluir um evento de exclusão já transmitido
					TAFMsgVldOp(oModel,"4")
					lRetorno := .F.
				Else

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas na tela³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nC90 := 1 to Len( oModelC90:aDataModel[ 1 ] )
						aAdd( aGrava, { oModelC90:aDataModel[ 1, nC90, 1 ], oModelC90:aDataModel[ 1, nC90, 2 ] } )
					Next nC90

					If !oModel:GetModel( 'MODEL_CRL' ):IsEmpty()
						For nCRL := 1 To oModel:GetModel( 'MODEL_CRL' ):Length()
							oModel:GetModel( 'MODEL_CRL' ):GoLine(nCRL)
							If !oModel:GetModel( 'MODEL_CRL' ):IsDeleted()
								aAdd (aGravaCRL ,{oModelCRL:GetValue('CRL_INIINT');
												, oModelCRL:GetValue('CRL_FIMINT');
												, oModelCRL:GetValue('CRL_TPINTE');
												, oModelCRL:GetValue('CRL_DURINT');
												, oModelCRL:GetValue('CRL_CODSEQ')} )
							EndIf
						Next nCRL
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( 'C90', '2' ,.F.,FwFldGet("C90_DTFIN"),FwFldGet("C90_DTINI"),C90->C90_DTINI )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu preciso setar a operacao do model como Inclusao³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oModel:DeActivate()
					oModel:SetOperation( 3 )
					oModel:Activate()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento o usuario ja fez as modificacoes que          ³
					//³precisava e as mesmas estao armazenadas em memoria, ou seja,³
					//³nao devem ser consideradas agora                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					For nC90 := 1 to Len( aGrava )
						oModel:LoadValue( "MODEL_C90", aGrava[ nC90, 1 ], aGrava[ nC90, 2 ] )
					Next nC90

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu realizo a inclusao do novo registro ja³
					//³contemplando as informacoes alteradas pelo usuario     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nC90 := 1 to Len( aGrava )
						oModel:LoadValue( "MODEL_C90", aGrava[ nC90, 1 ], aGrava[ nC90, 2 ] )
					Next nC90

					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C90', 'C90_LOGOPE' , '' , cLogOpeAnt )
					endif

					For nCRL := 1 To Len( aGravaCRL )
						If nCRL > 1
							oModel:GetModel( 'MODEL_CRL' ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_CRL", "CRL_INIINT", aGravaCRL[nCRL][1] )
						oModel:LoadValue( "MODEL_CRL", "CRL_FIMINT", aGravaCRL[nCRL][2] )
						oModel:LoadValue( "MODEL_CRL", "CRL_TPINTE", aGravaCRL[nCRL][3] )
						oModel:LoadValue( "MODEL_CRL", "CRL_DURINT", aGravaCRL[nCRL][4] )
						oModel:LoadValue( "MODEL_CRL", "CRL_CODSEQ", aGravaCRL[nCRL][5] )

		            Next nCRL

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao que sera gravada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVersao := xFunGetVer()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oModel:LoadValue( "MODEL_C90", "C90_VERSAO", cVersao )
					oModel:LoadValue( "MODEL_C90", "C90_VERANT", cVerAnt )
					oModel:LoadValue( "MODEL_C90", "C90_PROTPN", cProtocolo )
					oModel:LoadValue( "MODEL_C90", "C90_PROTUL", "" )
					// Tratamento para limpar o ID unico do xml
					cAliasPai := "C90"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf


					If nOperation == MODEL_OPERATION_DELETE
						oModel:LoadValue( 'MODEL_C90', 'C90_EVENTO', "E" )
					ElseIf cEvento == "E"
						oModel:LoadValue( 'MODEL_C90', 'C90_EVENTO', "I" )
					Else
						oModel:LoadValue( 'MODEL_C90', 'C90_EVENTO', "A" )
					EndIf

					FwFormCommit( oModel )
				EndIf

			Elseif C90->C90_STATUS == "2"
				//Não é possível alterar um registro com aguardando validação
				TAFMsgVldOp(oModel,"2")
				lRetorno := .F.

			Else

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso o registro nao tenha sido transmitido ainda, gravo sua chave³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cChvRegAnt := C90->( C90_ID + C90_VERANT )

				If TafColumnPos( "C90_LOGOPE" )
					cLogOpeAnt := C90->C90_LOGOPE
				endif				

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³No caso de um evento de Exclusao deve-se perguntar ao usuario se ele realmente deseja realizar a exclusao.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If C90->C90_EVENTO == "E"
					If nOperation == MODEL_OPERATION_DELETE
						If Aviso( xValStrEr("000754"), xValStrEr("000755"), { xValStrEr("000756"), xValStrEr("000757") }, 1 ) == 2 //##"Registro Excluído" ##"O Evento de exclusão não foi transmitido. Deseja realmente exclui-lo ou manter o evento de exclusão para transmissão posterior ?" ##"Excuir" ##"Manter"
								cChvRegAnt := ""
						EndIf
					Else
						oModel:LoadValue( "MODEL_C90", "C90_EVENTO", "A" )
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Executo a operacao escolhida³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty( cChvRegAnt )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Funcao responsavel por setar o Status do registro para Branco³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TAFAltStat( "C90", " " )

					If nOperation == MODEL_OPERATION_UPDATE .And. Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C90', 'C90_LOGOPE' , '' , cLogOpeAnt )
					endif

					FwFormCommit( oModel )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Caso a operacao seja uma exclusao...³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nOperation == MODEL_OPERATION_DELETE
						//Funcao para setar o registro anterior como Ativo
						TAFRastro( "C90", 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
					EndIf

				EndIf

			EndIf

		Elseif TafIndexInDic("C90", 6, .T.)

			C90->( DbSetOrder( 6 ) )
	    	If C90->( MsSeek( xFilial( 'C90' ) + FwFldGet('C90_ID')+ 'E42' ) )

				If nOperation == MODEL_OPERATION_DELETE
					// Não é possível excluir um evento de exclusão já transmitido
					TAFMsgVldOp(oModel,"4")
					lRetorno := .F.
				EndIf

			EndIF

		EndIf
	EndIf

End Transaction

Return( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF238Xml
Funcao de geracao do XML para atender o registro S-1050
Quando a rotina for chamada o registro deve estar posicionado

@Param:
cAlias - Alias corrente (Parametro padrao MVC)
nRecno - Recno corrente (Parametro padrao MVC)
nOpc   - Opcao selecionada (Parametro padrao MVC)
lJob   - Informa se foi chamado por Job
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@Return:
cXml - Estrutura do Xml do Layout S-1000

@author Anderson Costa
@since 04/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF238Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

Local cXml     := ""
Local cLayout  := "1050"
Local cReg     := "TabHorTur"
Local cEvento  := ""
Local cDtIni   := ""
Local cDtFin   := ""
Local cId := ""
Local cVerAnt := ""
Local nRecnoSM0 := SM0->(Recno())

Default lJob   := .F.
Default cSeqXml := ""

If C90->C90_EVENTO $ "I|A"

	If C90->C90_EVENTO == "A"
		cEvento := "alteracao"

		cId := C90->C90_ID
		cVerAnt := C90->C90_VERANT

		BeginSql alias 'C90TEMP'
			SELECT C90.C90_DTINI,C90.C90_DTFIN
			FROM %table:C90% C90
			WHERE C90.C90_FILIAL= %xfilial:C90% AND
			C90.C90_ID = %exp:cId% AND C90.C90_VERSAO = %exp:cVerAnt% AND
			C90.%notDel%
		EndSql
		cDtIni := Iif(!Empty(('C90TEMP')->C90_DTINI), Substr( ('C90TEMP')->C90_DTINI,3,4 ) + "-" + Substr( ('C90TEMP')->C90_DTINI,1,2 ), "" )
		cDtFIN := Iif(!Empty(('C90TEMP')->C90_DTFIN), Substr( ('C90TEMP')->C90_DTFIN,3,4 ) + "-" + Substr( ('C90TEMP')->C90_DTFIN,1,2 ), "" )

		('C90TEMP')->( DbCloseArea() )
	Else
		cEvento := "inclusao"
		cDtIni := Iif(!Empty(C90->C90_DTINI), Substr( C90->C90_DTINI,3,4 ) + "-" + Substr( C90->C90_DTINI,1,2 ), "" )
		cDtFIN := Iif(!Empty(C90->C90_DTFIN), Substr( C90->C90_DTFIN,3,4 ) + "-" + Substr( C90->C90_DTFIN,1,2 ), "" )
	EndIf

	cXml +=			"<infoHorContratual>"
	cXml +=				"<" + cEvento + ">"
	cXml +=					"<ideHorContratual>"
	cXml +=						xTafTag("codHorContrat",C90->C90_CODIGO)
	cXml +=						xTafTag("iniValid",cDtIni)
	cXml +=						xTafTag("fimValid",cDtFin,,.T.)
	cXml +=					"</ideHorContratual>"
	cXml +=					"<dadosHorContratual>"
	cXml +=						xTafTag("hrEntr",StrTran(C90->C90_HRENT, ":", ""))
	cXml +=						xTafTag("hrSaida",StrTran(C90->C90_HRSAI, ":", ""))
	cXml +=						xTafTag("durJornada",Alltrim(C90->C90_DURJOR))
	cXml +=						xTafTag("perHorFlexivel",xFunTrcSN(C90->C90_PERFLH,1))

	("CRL")->( DbSetOrder( 1 ) )
	("CRL")->( DbSeek ( xFilial("CRL")+C90->C90_ID+C90->C90_VERSAO) )
	//Laço para geração dos registros filhos
	While CRL->( !Eof()) .And. (xFilial("CRL")+C90->C90_ID+C90->C90_VERSAO == xFilial("CRL")+CRL->CRL_ID+CRL->CRL_VERSAO)
		cXml +=					"<horarioIntervalo>"
		cXml +=						xTafTag("tpInterv",Alltrim(CRL->CRL_TPINTE))
		cXml +=						xTafTag("durInterv",Alltrim(CRL->CRL_DURINT))
		cXml +=						xTafTag("iniInterv",StrTran(CRL->CRL_INIINT, ":", ""),,.T.)
		cXml +=						xTafTag("termInterv",StrTran(CRL->CRL_FIMINT, ":", ""),,.T.)
		cXml +=					"</horarioIntervalo>"
		CRL->( dbSkip() )
	EndDo
	cXml +=					"</dadosHorContratual>"

	If C90->C90_EVENTO == "A"
		If TafAtDtVld("C90", C90->C90_ID, C90->C90_DTINI, C90->C90_DTFIN, C90->C90_VERANT, .T.)
			cXml +=			"<novaValidade>"
			cXml += 				TafGetDtTab(C90->C90_DTINI,C90->C90_DTFIN)
			cXml +=			"</novaValidade>"
		EndIf
	EndIf
	cXml +=				"</" + cEvento + ">"
	cXml +=			"</infoHorContratual>"

ElseIf C90->C90_EVENTO == "E"
	cXml +=			"<infoHorContratual>"
	cXml +=				"<exclusao>"
	cXml +=					"<ideHorContratual>"
	cXml +=						xTafTag("codHorContrat",C90->C90_CODIGO)
	cXml += 					TafGetDtTab(C90->C90_DTINI,C90->C90_DTFIN)
	cXml +=					"</ideHorContratual>"
	cXml +=				"</exclusao>"
	cXml +=			"</infoHorContratual>"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do cabecalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRecnoSM0 > 0
	SM0->(dbGoto(nRecnoSM0))
endif
cXml := xTafCabXml(cXml,"C90",cLayout,cReg,,cSeqXml)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa gravacao do registro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	xTafGerXml(cXml,cLayout)
EndIf

Return(cXml)
