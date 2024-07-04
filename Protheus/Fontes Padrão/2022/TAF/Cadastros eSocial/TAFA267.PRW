#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA267.CH"

Static lLaySimplif	:= TafLayESoc("S_01_00_00")

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA267
Cadastro MVC de Reintegracao - S-2298

@author Felipe C. Seolin
@since 16/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFA267()

	Local aOnlyFields   := {}

	Private cNomEve		:= "S2298"
	Private oBrw 		:= FwMBrowse():New()

	If lLaySimplif
		aOnlyFields := { 'CMF_FILIAL','CMF_ID', 'CMF_FUNC', 'CMF_TPREIN', 'CMF_NRPROC', 'CMF_NRLEIJ', 'CMF_DTEFEI', 'CMF_DTRET', 'CMF_PROTUL', 'CMF_DINSIS', 'CMF_XMLID','CMF_CPFV', 'CMF_MATV', 'CMF_NOMEV' }
	Else
		aOnlyFields := { 'CMF_FILIAL','CMF_ID', 'CMF_FUNC', 'CMF_TPREIN', 'CMF_NRPROC', 'CMF_NRLEIJ', 'CMF_DTEFEI', 'CMF_DTRET', 'CMF_INDPGJ', 'CMF_PROTUL', 'CMF_DINSIS', 'CMF_XMLID','CMF_CPFV', 'CMF_NISV', 'CMF_MATV', 'CMF_NOMEV' }
	EndIf

	If FindFunction("FilCpfNome") .And. GetSx3Cache("CMF_CPFV","X3_CONTEXT") == "V" .AND. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES")

		TafNewBrowse( "S-2298","CMF_DTRET",,2, STR0001, aOnlyFields, 2, 2 ) //"Reintegração por Determinação Judicial"

	Else

		// Função que indica se o ambiente é válido para o eSocial 2.4
		If TafAtualizado()
		
			oBrw:SetDescription(STR0001) //"Reintegração por Determinação Judicial"
			oBrw:SetAlias("CMF")
			oBrw:SetMenuDef("TAFA267")
		
			If FindFunction('TAFSetFilter')
				oBrw:SetFilterDefault(TAFBrwSetFilter("CMF","TAFA267","S-2298"))
			Else
				oBrw:SetFilterDefault( "CMF_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos (1 = Ativo, 2 = Inativo)
			EndIf
		
			TafLegend(2,"CMF",@oBrw)
			oBrw:Activate()
		
		EndIf
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Felipe C. Seolin
@since 16/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {} 
Local aRotina := {}

If FindFunction("FilCpfNome") .And. GetSx3Cache("CMF_CPFV","X3_CONTEXT") == "V" .AND. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES")

	ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.TAFA267' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE "Incluir"    ACTION 'VIEWDEF.TAFA267' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE "Alterar"    ACTION 'VIEWDEF.TAFA267' OPERATION 4 ACCESS 0 //'Alterar'
    ADD OPTION aRotina TITLE "Imprimir"	  ACTION 'VIEWDEF.TAFA267' OPERATION 8 ACCESS 0 //'Imprimir'

Else

	Aadd( aFuncao, { "" , "TAF267Xml" , "1" } )
		
	//Chamo a Browse do Histórico
	If FindFunction( "xNewHisAlt" ) 
		Aadd( aFuncao, { "" , "xNewHisAlt( 'CMF', 'TAFA267' )" , "3" } )
	Else
		Aadd( aFuncao, { "" , "xFunHisAlt( 'CMF', 'TAFA267' )" , "3" } )
	EndIf

	Aadd( aFuncao, { "" , "TAFXmlLote( 'CMF', 'S-2298' , 'evtReintegr' , 'TAF267Xml' )" , "5" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'CMF' )" , "10" } )
	
	lMenuDIf := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDIf )
	
	If lMenuDif
		ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.TAFA267' OPERATION 2 ACCESS 0 //"Visualizar"
		
		// Menu dos extemporâneos
		If FindFunction( "xNewHisAlt" ) .AND. FindFunction( "xTafExtmp" ) .And. xTafExtmp()
			aRotina	:= xMnuExtmp( "TAFA267", "CMF" )
		EndIf
		
	Else
		aRotina	:=	xFunMnuTAF( "TAFA267" , , aFuncao)
	EndIf
EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Felipe C. Seolin
@since 16/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

Local oStruCMF := FwFormStruct(1,"CMF")
Local oModel   

If lLaySimplif
	oStruCMF:RemoveField("CMF_INDPGJ")
EndIf

oModel := MpFormModel():New("TAFA267",,,{|oModel| SaveModel(oModel)})

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStruCMF:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
EndIf

//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
//Necessário para não incrementar ID que não será utilizado.
If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
	oStruCMF:SetProperty( "CMF_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
EndIf

oModel:AddFields("MODEL_CMF",/*cOwner*/,oStruCMF)
oModel:GetModel("MODEL_CMF"):SetPrimaryKey({"CMF_FUNC","CMF_DTRET"})

Return(oModel)

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Felipe C. Seolin
@since 16/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oModel    := FWLoadModel("TAFA267")
Local oStruCMF 	:= Nil
Local oView     := FWFormView():New()

Local cCmpFil	:= ""
Local cGrpTra1 	:= ""
Local cGrpTra2	:= ""
Local cGrpTra3	:= ""
Local aCmpGrp 	:= {}
Local nI		:= 0

oView:SetModel(oModel)

cGrpTra1 := "CMF_FUNC|CMF_DFUNC|CMF_TPREIN|CMF_NRPROC|CMF_DNRPRO|CMF_NRLEIJ|CMF_DTEFEI|CMF_DTRET|"
If !lLaySimplif
	cGrpTra1 += "CMF_INDPGJ|"
EndIf

cGrpTra2 := "CMF_PROTUL|"
If TafColumnPos("CMF_DTRANS")
	cGrpTra3 := "CMF_DINSIS|CMF_DTRANS|CMF_HTRANS|CMF_DTRECP|CMF_HRRECP|"
EndIf

cCmpFil := cGrpTra1 + cGrpTra2 + cGrpTra3
oStruCMF := FwFormStruct( 2, "CMF",{ |x| AllTrim( x ) + "|" $ cCmpFil } )


If lLaySimplif
	oStruCMF:RemoveField("CMF_NISV")
	oStruCMF:RemoveField("CMF_INDPGJ")
	oStruCMF:RemoveField("CMF_CPFV")
	oStruCMF:RemoveField("CMF_NOMEV")
	oStruCMF:RemoveField("CMF_MATV")
EndIf

If FindFunction("TafAjustRecibo")
	TafAjustRecibo(oStruCMF,"CMF")
EndIf

If TafColumnPos("CMF_DTRANS")
	oStruCMF:AddGroup( "GRP_TRABALHADOR_01", TafNmFolder("recibo",1), "", 1 ) //Recibo da última Transmissão
	oStruCMF:AddGroup( "GRP_TRABALHADOR_02", TafNmFolder("recibo",2), "", 1 ) //Informações de Controle eSocial

	oStruCMF:SetProperty(Strtran(cGrpTra2,"|",""),MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_01")
	
	aCmpGrp := StrToKArr(cGrpTra3,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCMF:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_02")
	Next nI
EndIf      

oView:AddField("VIEW_CMF",oStruCMF,"MODEL_CMF")

oView:EnableTitleView("VIEW_CMF",STR0001) //"Reintegração por Determinação Judicial"
oView:CreateHorizontalBox("FIELDSCMF",100)
oView:SetOwnerView("VIEW_CMF","FIELDSCMF")

lMenuDIf := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDIf )

If !lMenuDif .OR. ( FindFunction( "xTafExtmp" ) .And. xTafExtmp() )
	xFunRmFStr(@oStruCMF,"CMF")
EndIf

If TafColumnPos( "CMF_LOGOPE" )
	oStruCMF:RemoveField( "CMF_LOGOPE" )
EndIf

Return(oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Felipe C. Seolin
@since 09/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local cVerAnt   	:= ""
Local cProtocolo	:= ""
Local cVersao   	:= ""
Local cChvRegAnt	:= ""
Local cEvento	    := ""
Local cLogOpe		:= ""
Local cLogOpeAnt	:= ""

Local nOperation	:= oModel:GetOperation()
Local nlI			:= 0
Local nlY   		:= 0

Local lRetorno	:= .T.
Local aGrava    	:= {}
Local oModelCMF 	:= Nil

Default oModel	:= Nil

//Controle se o evento é extemporâneo
lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

Begin Transaction

	If nOperation == MODEL_OPERATION_INSERT
	
		TafAjustID( "CMF", oModel)

		oModel:LoadValue( 'MODEL_CMF', 'CMF_VERSAO', xFunGetVer() )

		If Findfunction("TAFAltMan")
			TAFAltMan( 3 , 'Save' , oModel, 'MODEL_CMF', 'CMF_LOGOPE' , '2', '' )
		Endif

		FwFormCommit( oModel )

	ElseIf nOperation == MODEL_OPERATION_UPDATE

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seek para posicionar no registro antes de realizar as validacoes,³
		//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
		//³os campos nao usados como _STATUS                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CMF->( DbSetOrder( 3 ) )
		If lGoExtemp .OR. CMF->( MsSeek( xFilial( 'CMF' ) + M->CMF_ID + '1' ) )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o registro ja foi transmitido com sucesso    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If CMF->CMF_STATUS ==  "4"

				oModelCMF := oModel:GetModel( 'MODEL_CMF' )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busco a versao anterior do registro para gravacao do rastro³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cVerAnt    	:= oModelCMF:GetValue( "CMF_VERSAO" )
				cProtocolo 	:= oModelCMF:GetValue( "CMF_PROTUL" )
				cEvento		:= oModelCMF:GetValue( "CMF_EVENTO" )

				If TafColumnPos( "CMF_LOGOPE" )
					cLogOpeAnt := oModelCMF:GetValue( "CMF_LOGOPE" )	
				endif				

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Neste momento eu gravo as informacoes que foram carregadas       ³
				//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
				//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
				//³nao devem ser consideradas neste momento                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nlI := 1 To 1
					For nlY := 1 To Len( oModelCMF:aDataModel[ nlI ] )
						Aadd( aGrava, { oModelCMF:aDataModel[ nlI, nlY, 1 ], oModelCMF:aDataModel[ nlI, nlY, 2 ] } )
					Next
				Next

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seto o campo como Inativo e gravo a versao do novo registro³
				//³no registro anterior                                       ³
				//|                                                           |
				//|ATENCAO -> A alteracao destes campos deve sempre estar     |
				//|abaixo do Loop do For, pois devem substituir as informacoes|
				//|que foram armazenadas no Loop acima                        |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FAltRegAnt( 'CMF', '2' )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Neste momento eu preciso setar a operacao do model³
				//³como Inclusao                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oModel:DeActivate()
				oModel:SetOperation( 3 )
				oModel:Activate()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Neste momento eu realizo a inclusao do novo registro ja³
				//³contemplando as informacoes alteradas pelo usuario     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nlI := 1 To Len( aGrava )
					oModel:LoadValue( 'MODEL_CMF', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
				Next

				//Necessário Abaixo do For Nao Retirar
				If Findfunction("TAFAltMan")
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_CMF', 'CMF_LOGOPE' , '' , cLogOpeAnt )
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busco a versao que sera gravada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cVersao := xFunGetVer()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//|ATENCAO -> A alteracao destes campos deve sempre estar     |
				//|abaixo do Loop do For, pois devem substituir as informacoes|
				//|que foram armazenadas no Loop acima                        |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oModel:LoadValue( 'MODEL_CMF', 'CMF_VERSAO', cVersao )
				oModel:LoadValue( 'MODEL_CMF', 'CMF_VERANT', cVerAnt )
				oModel:LoadValue( 'MODEL_CMF', 'CMF_PROTPN', cProtocolo )
				oModel:LoadValue( 'MODEL_CMF', 'CMF_PROTUL', "" )
				oModel:LoadValue( "MODEL_CMF", "CMF_EVENTO", "A" )
				// Tratamento para limpar o ID unico do xml
				cAliasPai := "CMF"
				If TAFColumnPos( cAliasPai+"_XMLID" )
					oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
				EndIf

				//Gravo alteração para o Extemporâneo
				If lGoExtemp
					TafGrvExt( oModel, 'MODEL_CMF', 'CMF' )	
				Endif

				FwFormCommit( oModel )
				TAFAltStat( 'CMF', " " )

			ElseIf	CMF->CMF_STATUS == "2" 
				TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
				lRetorno:= .F.
			ElseIf CMF->CMF_STATUS == "6"
				TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
				lRetorno:= .F.
			ElseIf CMF->CMF_STATUS == "7"
				TAFMsgVldOp(oModel,"7") //"Registro não pode ser alterado, pois o evento já se encontra na base do RET"
				lRetorno:= .F.
			Else
				If TafColumnPos( "CMF_LOGOPE" )
					cLogOpeAnt := CMF->CMF_LOGOPE
				endif

				//Gravo alteração para o Extemporâneo
				If lGoExtemp
					TafGrvExt( oModel, 'MODEL_CMF', 'CMF' )	
				Endif

				If Findfunction("TAFAltMan")
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_CMF', 'CMF_LOGOPE' , '' , cLogOpeAnt )
				EndIf

				FwFormCommit( oModel )
				TAFAltStat( 'CMF', " " )
			EndIf
		EndIf

	//Exclusão Manual do Evento
	ElseIf nOperation == MODEL_OPERATION_DELETE

		cChvRegAnt := CMF->(CMF_ID + CMF_VERANT)

		If !Empty( cChvRegAnt )
			TAFAltStat( 'CMF', " " )
			FwFormCommit( oModel )
			If nOperation == MODEL_OPERATION_DELETE
				If CMF->CMF_EVENTO == "A" .Or. CMF->CMF_EVENTO == "E"
					TAFRastro( 'CMF', 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
				EndIf
			EndIf
		Else
			oModel:DeActivate()
			oModel:SetOperation( 5 )
			oModel:Activate()
			FwFormCommit( oModel )
		EndIf

	EndIf

End Transaction

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF267Xml
Funcao de geracao do XML para atender o registro S-2820
Quando a rotina for chamada o registro deve estar posicionado

@Param:
cAlias - Alias da Tabela
nRecno - Recno do Registro corrente
nOpc   - Operacao a ser realizada
lJob   - Informa se foi chamado por Job

@Return:
cXml - Estrutura do Xml do Layout S-2820
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@author Felipe C. Seolin
@since 21/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF267Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

Local cXml     := ""
Local cLayout  := "2298"
Local cReg     := "Reintegr"
Local cFilBkp  := cFilAnt
Local lXmlVLd  := IIF(FindFunction('TafXmlVLD'),TafXmlVLD('TAF267XML'),.T.)
Local cNISFunc := ""

Default cAlias	:= ""
Default nRecno	:= 0
Default nOpc	:= 1
Default lJob	:= .F.
Default cSeqXml := ""

If lXmlVLd
	If IsInCallStack("TafNewBrowse") .And. ( CMF->CMF_FILIAL <> cFilAnt )
		cFilAnt := CMF->CMF_FILIAL
	EndIf

	DBSelectArea("C9V")
	C9V->(DBSetOrder(2))

	cXml +=	"<ideVinculo>"
	If C9V->( MSSeek( xFilial("C9V") + CMF->CMF_FUNC + "1" ) )
		cXml +=	xTafTag("cpfTrab",C9V->C9V_CPF)
		
		If !lLaySimplif
			cNISFunc := TAF250Nis(C9V->C9V_FILIAL, C9V->C9V_ID, C9V->C9V_NIS)
			cXml +=	xTafTag("nisTrab",cNISFunc)
		EndIf
		
		cXml +=	xTafTag("matricula",C9V->C9V_MATRIC)
	EndIf
	cXml +=	"</ideVinculo>"

	cXml +=	"<infoReintegr>"
	cXml +=		xTafTag("tpReint",CMF->CMF_TPREIN)
	cXml +=		xTafTag("nrProcJud",CMF->CMF_NRPROC,,.T.)
	cXml +=		xTafTag("nrLeiAnistia",CMF->CMF_NRLEIJ,,.T.)
	cXml +=		xTafTag("dtEfetRetorno",CMF->CMF_DTRET)
	cXml +=		xTafTag("dtEfeito",CMF->CMF_DTEFEI)
	
	If !lLaySimplif
		cXml +=		xTafTag("indPagtoJuizo",xFunTrcSN(CMF->CMF_INDPGJ))
	EndIf

	cXml +=	"</infoReintegr>"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Estrutura do cabecalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cXml := xTafCabXml(cXml,"CMF",cLayout,cReg,,cSeqXml)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa gravacao do registro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lJob
		xTafGerXml(cXml,cLayout)
	EndIf

	cFilAnt := cFilBkp
EndIf

Return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF267Grv
Funcao de gravacao para atender o registro S-2365

@parametros:
cLayout - Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
tratamentos de acordo com o layout que esta sendo enviado.
nOpc   -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv -  Filial do ERP para onde as informacoes deverao ser importadas
oDados -  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )

@Return
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as
informacoes foram gravadas no banco de dados
aIncons - Array com as inconsistencias encontradas durante a importacao

@author Leandro Prado
@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF267Grv( cLayout, nOpc, cFilEv, oXML, cOwner , cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

Local cCmpsNoUpd	:= "|CMF_FILIAL|CMF_ID|CMF_VERSAO|CMF_VERANT|CMF_PROTPN|CMF_EVENTO|CMF_STATUS|CMF_ATIVO|"
Local cChave	 	:= ""
Local cInconMsg 	:= ""
Local cCodEvent		:= Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")

Local nlI       	:= 0
Local nSeqErrGrv	:= 0

Local lRet 			:= .F.

Local aIncons		:= {}
Local aRules 		:= {}
Local aChave  		:= {}

Local oModel  		:= Nil
Local cLogOpeAnt 	:= ""

Private lVldModel	:= .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
Private oDados    	:= Nil

Default cLayout		:= ""
Default nOpc 		:= 1
Default cFilEv 		:= ""
Default oXML		:= Nil
Default cOwner		:= ""
Default cFilTran	:=	""
Default cPredeces	:=	""
Default nTafRecno	:=	0
Default cComplem	:=	""
Default cGrpTran	:=	""
Default cEmpOriGrp	:=	""
Default cFilOriGrp	:=	""
Default cXmlID		:=	""

oDados 	:= oXML

Aadd( aChave, { "C", "CMF_FUNC", FGetIdInt("cpfTrab", "matricula","/eSocial/evtReintegr/ideVinculo/cpfTrab",;
	"/eSocial/evtReintegr/ideVinculo/matricula"), .T. } )
cChave := 	aChave[1,3]

Aadd( aChave, { "D", "CMF_DTRET", FTafGetVal( "/eSocial/evtReintegr/infoReintegr/dtEfetRetorno", "D", .F., @aIncons, .F. ), .T.}  )

cChave 	+= 	DTOS(aChave[2,3])
nIndice 	:= 2

//Verifica se o evento ja existe na base
("CMF")->( DbSetOrder( 2 ) )
If ("CMF")->( MsSeek( xFilial("CMF") + cChave +'1' ) )
	If !CMF->CMF_STATUS $ ( "2|6" )
		nOpc := 4
	EndIf
EndIf

Begin Transaction

	//Funcao para validar se a operacao desejada pode ser realizada
	If FTafVldOpe( 'CMF', nIndice, @nOpc, cFilEv, @aIncons, aChave, @oModel, 'TAFA267', cCmpsNoUpd,1 )

		If TafColumnPos( "CMF_LOGOPE" )
			cLogOpeAnt := CMF->CMF_LOGOPE
		endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrego array com os campos De/Para de gravacao das informacoes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRules := TAF267Rul( cLayout, @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
		//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc <> 5
			oModel:LoadValue( "MODEL_CMF", "CMF_FILIAL", CMF->CMF_FILIAL )

			If TAFColumnPos( "CMF_XMLID" )
				oModel:LoadValue( "MODEL_CMF", "CMF_XMLID", cXmlID )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Rodo o aRules para gravar as informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nlI := 1 To Len( aRules )
				oModel:LoadValue( "MODEL_CMF", aRules[ nlI, 01 ], FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F. ) )
			Next

			If Findfunction("TAFAltMan")
				if nOpc == 3
					TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_CMF', 'CMF_LOGOPE' , '1', '' )
				elseif nOpc == 4
					TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_CMF', 'CMF_LOGOPE' , '', cLogOpeAnt )
				EndIf
			EndIf
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zerando os arrays e os Objetos utilizados no processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize( aRules, 0 )
aRules	:= Nil

aSize( aChave, 0 )
aChave	:= Nil
oModel	:= Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF267Rul
Regras para gravacao das informacoes do registro S-2365

@Param
nOper      - Operacao a ser realizada ( 3 = Inclusao / 4 = Alteracao / 5 = Exclusao )

@Return
aRull  - Regras para a gravacao das informacoes

@author Leandro Prado
@since 28/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF267Rul( cTagOper, cInconMsg, nSeqErrGrv, cCodEvent, cOwner )
	
Local aRull				:= {}

Default cTagOper		:= ""
Default cInconMsg		:= ""
Default nSeqErrGrv		:= 0
Default cCodEvent		:= ""
Default cOwner			:= ""

// Campos da tabela CMF
If TafXNode( oDados, cCodEvent, cOwner, ("matricula","/eSocial/evtReintegr/ideVinculo/cpfTrab")) .or. TafXNode( oDados , cCodEvent, cOwner, ("/eSocial/evtReintegr/ideVinculo/matricula"))
	Aadd( aRull, { "CMF_FUNC", FGetIdInt( "cpfTrab","matricula","/eSocial/evtReintegr/ideVinculo/cpfTrab",;
		"/eSocial/evtReintegr/ideVinculo/matricula",,,@cInconMsg, @nSeqErrGrv), "C", .T. } ) //Funcionario
EndIf

If TafXNode( oDados, cCodEvent, cOwner, ("/eSocial/evtReintegr/infoReintegr/tpReint"))
	Aadd( aRull, { "CMF_TPREIN", "/eSocial/evtReintegr/infoReintegr/tpReint", "C", .F. } )	//dtFimCondicao
EndIf

If TafXNode( oDados, cCodEvent, cOwner, ("/eSocial/evtReintegr/infoReintegr/nrProcJud"))
	Aadd( aRull, { "CMF_NRPROC", "/eSocial/evtReintegr/infoReintegr/nrProcJud", "C", .F. } )	//nrProcJud
Else
	Aadd( aRull, { "CMF_NRPROC", "", "C", .F. } )
EndIf

If TafXNode( oDados, cCodEvent, cOwner, ("/eSocial/evtReintegr/infoReintegr/nrLeiAnistia"))
	Aadd( aRull, { "CMF_NRLEIJ", "/eSocial/evtReintegr/infoReintegr/nrLeiAnistia", "C", .F. } )	//dtFimCondicao
Else
	Aadd( aRull, { "CMF_NRLEIJ", "", "C", .F. } )
EndIf

If TafXNode( oDados, cCodEvent, cOwner, ("/eSocial/evtReintegr/infoReintegr/dtEfeito"))
	Aadd( aRull, { "CMF_DTEFEI", "/eSocial/evtReintegr/infoReintegr/dtEfeito", "D", .F. } )		//dtFimCondicao
EndIf

If TafXNode( oDados, cCodEvent, cOwner, ("/eSocial/evtReintegr/infoReintegr/dtEfetRetorno"))
	Aadd( aRull, { "CMF_DTRET",  "/eSocial/evtReintegr/infoReintegr/dtEfetRetorno", "D", .F. } )	//dtFimCondicao
EndIF

if !lLaySimplif
	If TafXNode( oDados, cCodEvent, cOwner, ("/eSocial/evtReintegr/infoReintegr/indPagtoJuizo"))
		Aadd( aRull, { "CMF_INDPGJ", xFunTrcSN(TAFExisTag("/eSocial/evtReintegr/infoReintegr/indPagtoJuizo"),2), "C", .T. } )	//indPagtoJuizo
	EndIf
EndIf

Return ( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@author denis.oliveira
@since 29/06/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

Local cVerAnt   	:= ""
Local cProtocolo	:= ""
Local cVersao   	:= ""
Local cChvRegAnt	:= ""
Local cEvento		:= ""

Local nOperation	:= oModel:GetOperation()
Local nlI			:= 0
Local nlY   		:= 0

Local aGrava    	:= {}
Local oModelCMF 	:= Nil

Default oModel		:= Nil
Default nRecno		:= 0
Default lRotExc		:= .F.

//Controle se o evento é extemporâneo
lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

Begin Transaction

	//Posiciona o item
	("CMF")->( DBGoTo( nRecno ) )

	oModelCMF := oModel:GetModel( 'MODEL_CMF' )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busco a versao anterior do registro para gravacao do rastro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cVerAnt    	:= oModelCMF:GetValue( "CMF_VERSAO" )
	cProtocolo 	:= oModelCMF:GetValue( "CMF_PROTUL" )
	cEvento		:= oModelCMF:GetValue( "CMF_EVENTO" )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Neste momento eu gravo as informacoes que foram carregadas       ³
	//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
	//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
	//³nao devem ser consideradas neste momento                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nlI := 1 To 1
		For nlY := 1 To Len( oModelCMF:aDataModel[ nlI ] )
			Aadd( aGrava, { oModelCMF:aDataModel[ nlI, nlY, 1 ], oModelCMF:aDataModel[ nlI, nlY, 2 ] } )
		Next
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seto o campo como Inativo e gravo a versao do novo registro³
	//³no registro anterior                                       ³
	//|                                                           |
	//|ATENCAO -> A alteracao destes campos deve sempre estar     |
	//|abaixo do Loop do For, pois devem substituir as informacoes|
	//|que foram armazenadas no Loop acima                        |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FAltRegAnt( 'CMF', '2' )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Neste momento eu preciso setar a operacao do model³
	//³como Inclusao                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oModel:DeActivate()
	oModel:SetOperation( 3 )
	oModel:Activate()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Neste momento eu realizo a inclusao do novo registro ja³
	//³contemplando as informacoes alteradas pelo usuario     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nlI := 1 To Len( aGrava )
		oModel:LoadValue( 'MODEL_CMF', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busco a versao que sera gravada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cVersao := xFunGetVer()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|ATENCAO -> A alteracao destes campos deve sempre estar     |
	//|abaixo do Loop do For, pois devem substituir as informacoes|
	//|que foram armazenadas no Loop acima                        |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oModel:LoadValue( 'MODEL_CMF', 'CMF_VERSAO', cVersao )
	oModel:LoadValue( 'MODEL_CMF', 'CMF_VERANT', cVerAnt )
	oModel:LoadValue( 'MODEL_CMF', 'CMF_PROTPN', cProtocolo )
	oModel:LoadValue( 'MODEL_CMF', 'CMF_PROTUL', "" )

	/*---------------------------------------------------------
	Tratamento para que caso o Evento Anterior fosse de exclusão
	seta-se o novo evento como uma "nova inclusão", caso contrário o
	evento passar a ser uma alteração
	-----------------------------------------------------------*/
	oModel:LoadValue( "MODEL_CMF", "CMF_EVENTO", "E" )
	oModel:LoadValue( "MODEL_CMF", "CMF_ATIVO" , "1" )

	//Gravo alteração para o Extemporâneo
	If lGoExtemp
		TafGrvExt( oModel, 'MODEL_CMF', 'CMF' )	
	EndIf

	FwFormCommit( oModel )
	TAFAltStat( 'CMF',"6" )

End Transaction

Return ( .T. )

//--------------------------------------------------------------------
/*/{Protheus.doc} SetCssButton

Cria objeto TButton utilizando CSS

@author Eduardo Sukeda
@since 09/04/2019
@version 1.0

@param cTamFonte - Tamanho da Fonte
@param cFontColor - Cor da Fonte
@param cBackColor - Cor de Fundo do Botão
@param cBorderColor - Cor da Borda

@return cCss
/*/
//--------------------------------------------------------------------
Static Function SetCssButton(cTamFonte,cFontColor,cBackColor,cBorderColor)

Local cCSS := ""

cCSS := "QPushButton{ background-color: " + cBackColor + "; "
cCSS += "border: none; "
cCSS += "font: bold; "
cCSS += "color: " + cFontColor + ";" 
cCSS += "padding: 2px 5px;" 
cCSS += "text-align: center; "
cCSS += "text-decoration: none; "
cCSS += "display: inline-block; "
cCSS += "font-size: " + cTamFonte + "px; "
cCSS += "border: 1px solid " + cBorderColor + "; "
cCSS += "border-radius: 3px "
cCSS += "}"

Return cCSS

//---------------------------------------------------------------------
/*/{Protheus.doc} PreXmlLote
Função que chama a TAFXmlLote e limpa slRubERPPad

@author brunno.costa
@since 01/10/2018
@version 1.0
/*/
//---------------------------------------------------------------------

Static Function PreXmlLote()
    TAFXmlLote( 'CMF', 'S-2298' , 'evtReintegr' , 'TAF267Xml', ,oBrw )
    slRubERPPad := Nil  //Limpa variável no final do processo em lote
Return


