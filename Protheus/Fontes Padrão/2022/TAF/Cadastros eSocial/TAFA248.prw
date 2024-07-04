#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA248.CH"

//--------------------------------------------------------------------
/*/{Protheus.doc} TAFA248
Cadastro de Operadores Portuários - S-1080

@author Anderson Costa
@since 27/08/2013
@version 1.0

/*/
//--------------------------------------------------------------------
Function TAFA248()

	Private oBrw	:= FWmBrowse():New()
	
	If FindFunction("TAFDesEven")
		TAFDesEven()
	EndIf

	oBrw:SetDescription(STR0001)    //"Cadastro de Operadores Portuários"
	oBrw:SetAlias( 'C8W')
	oBrw:SetMenuDef( 'TAFA248' )
	oBrw:SetFilterDefault( "C8W_ATIVO == '1' .Or. (C8W_EVENTO == 'E' .And. C8W_STATUS = '4' .And. C8W_ATIVO = '2')" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )

	oBrw:AddLegend( "C8W_EVENTO == 'I' ", "GREEN" , STR0006 ) //"Registro Incluído"
	oBrw:AddLegend( "C8W_EVENTO == 'A' ", "YELLOW", STR0007 ) //"Registro Alterado"
	oBrw:AddLegend( "C8W_EVENTO == 'E' .And. C8W_STATUS <> '4' ", "RED"   , STR0008 ) //"Registro excluído não transmitido"
	oBrw:AddLegend( "C8W_EVENTO == 'E' .And. C8W_STATUS == '4' .And. C8W_ATIVO = '2' ", "BLACK"   , STR0012 ) //"Registro excluído não transmitido"

	oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Anderson Costa
@since 27/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao := {}
Local aRotina := {}

If FindFunction('TafXmlRet')
	Aadd( aFuncao, { "" , "TafxmlRet('TAF248Xml','1080','C8W')" , "1" } )
Else 
	Aadd( aFuncao, { "" , "TAF248Xml" , "1" } )
EndIf
Aadd( aFuncao, { "" , "xFunHisAlt( 'C8W', 'TAFA248',,,,'TAF248XML','1080'  )" , "3" } )
aAdd( aFuncao, { "" , "TAFXmlLote( 'C8W', 'S-1080' , 'evtTabOperPort' , 'TAF248Xml',, oBrw )" , "5" } )
Aadd( aFuncao, { "" , "xFunAltRec( 'C8W' )" , "10" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif .Or. ViewEvent('S-1080')
	ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.TAFA248' OPERATION 2 ACCESS 0 //"Visualizar"
Else
	aRotina	:=	xFunMnuTAF( "TAFA248" , , aFuncao)
EndIf

Return( aRotina )
//------------------------------------------------------------------- 
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Anderson Costa
@since 27/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC8W  :=  FWFormStruct( 1, 'C8W' )
Local oModel 	:= MPFormModel():New( 'TAFA248' , , , {|oModel| SaveModel( oModel ) } )

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
            
If lVldModel
	oStruC8W:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_C8W', /*cOwner*/, oStruC8W)
oModel:GetModel("MODEL_C8W"):SetPrimaryKey({"C8W_CNPJOP","C8W_DTINI","C8W_DTFIN"})

Return oModel   
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Anderson Costa
@since 27/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA248")
Local oStruC8W := FwFormStruct(2,"C8W")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_C8W",oStruC8W,"MODEL_C8W")

If FindFunction("TafAjustRecibo")
	TafAjustRecibo(oStruC8W,"C8W")
EndIf

oView:EnableTitleView("VIEW_C8W",STR0001) //"Cadastro de Tabelas de Cargos"
oView:CreateHorizontalBox("FIELDSC8W",100)
oView:SetOwnerView("VIEW_C8W","FIELDSC8W")

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif
	xFunRmFStr(@oStruC8W,"C8W")
EndIf

If TafColumnPos( "C8W_LOGOPE" )
	oStruC8W:RemoveField( "C8W_LOGOPE")
EndIf

Return(oView)
//-------------------------------------------------------------------
/*/{Protheus.doc} TAF248Xml
Funcao de geracao do XML para atender o registro S-1080
Quando a rotina for chamada o registro deve estar posicionado

@Param:
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@Return:
cXml - Estrutura do Xml do Layout S-1080

@author Fabio V. Santana
@since 07/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF248Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

Local cXml		:= ""
Local cLayout	:= "1080"
Local cEvento	:= ""
Local cReg		:= "TabOperPort"
Local cDtIni  	:= ""
Local cDtFin  	:= ""
Local cId := ""
Local cVerAnt := ""

Default cSeqXml := ""

If C8W->C8W_EVENTO $ "I|A"

	If C8W->C8W_EVENTO == "A"
		cEvento := "alteracao"

		cId := C8W->C8W_ID 
		cVerAnt := C8W->C8W_VERANT
		
		BeginSql alias 'C8WTEMP'
			SELECT C8W.C8W_DTINI,C8W.C8W_DTFIN
			FROM %table:C8W% C8W
			WHERE C8W.C8W_FILIAL= %xfilial:C8W% AND
			C8W.C8W_ID = %exp:cId% AND C8W.C8W_VERSAO = %exp:cVerAnt% AND 
			C8W.%notDel%
		EndSql  
		cDtIni := Substr(('C8WTEMP')->C8W_DTINI,3,4) +"-"+ Substr(('C8WTEMP')->C8W_DTINI,1,2)
		cDtFin := Iif(Empty(('C8WTEMP')->C8W_DTFIN), "",Substr(('C8WTEMP')->C8W_DTFIN,3,4) +"-"+ Substr(('C8WTEMP')->C8W_DTFIN,1,2))

		('C8WTEMP')->( DbCloseArea() )
	Else
		cEvento := "inclusao"
		cDtIni  := Substr(C8W->C8W_DTINI,3,4) +"-"+ Substr(C8W->C8W_DTINI,1,2)
		cDtFin  := Iif(Empty(C8W->C8W_DTFIN), "", Substr(C8W->C8W_DTFIN,3,4) +"-"+ Substr(C8W->C8W_DTFIN,1,2)) //Faço o Iif pois se a data estiver vazia a string recebia '  -  -   '
	EndIf

	cXml +=			"<infoOperPortuario>"
	cXml +=				"<" + cEvento + ">"
	cXml +=					"<ideOperPortuario>"	
	cXml +=						xTafTag("cnpjOpPortuario",C8W->C8W_CNPJOP)
	cXml +=						xTafTag("iniValid",cDtIni)
	cXml +=						xTafTag("fimValid",cDtFin,,.T.)	
	cXml +=					"</ideOperPortuario>"
	cXml +=					"<dadosOperPortuario>"	
	cXml +=						xTafTag("aliqRat",C8W->C8W_ALQRAT,PesqPict("C8W","C8W_ALQRAT"))
	cXml +=						xTafTag("fap",C8W->C8W_FAP,PesqPict("C8W","C8W_FAP"))
	cXml +=						xTafTag("aliqRatAjust",C8W->C8W_ALQAJU,PesqPict("C8W","C8W_ALQAJU"))
	cXml +=					"</dadosOperPortuario>"
	
	If C8W->C8W_EVENTO == "A"		
		If TafAtDtVld("C8W", C8W->C8W_ID, C8W->C8W_DTINI, C8W->C8W_DTFIN, C8W->C8W_VERANT, .T. )
			cXml +=			"<novaValidade>"		
			cXml +=				TafGetDtTab(C8W->C8W_DTINI,C8W->C8W_DTFIN)							
			cXml +=			"</novaValidade>"
		EndIf     		
	EndIf

	cXml +=				"</" + cEvento + ">"
	cXml +=			"</infoOperPortuario>"

ElseIf C8W->C8W_EVENTO == "E"
	cXml +=			"<infoOperPortuario>"
	cXml +=				"<exclusao>"
	cXml +=					"<ideOperPortuario>"
	cXml += 					xTafTag("cnpjOpPortuario",C8W->C8W_CNPJOP)
	cXml +=						TafGetDtTab(C8W->C8W_DTINI,C8W->C8W_DTFIN)	
	cXml +=					"</ideOperPortuario>"
	cXml +=				"</exclusao>"
	cXml +=			"</infoOperPortuario>"

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do cabecalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cXml := xTafCabXml(cXml,"C8W", cLayout,cReg, ,cSeqXml)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa gravacao do registro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	xTafGerXml(cXml,cLayout)
EndIf

Return(cXml) 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF248Grv
@type			function
@description	Função de gravação para atender o registro S-1080.
@author			Fabio V. Santana
@since			07/10/2013
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
Function TAF248Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

Local cLogOpeAnt	:=	""
Local cCmpsNoUpd	:=	"|C8W_FILIAL|C8W_ID|C8W_VERSAO|C8W_VERANT|C8W_PROTPN|C8W_EVENTO|C8W_STATUS|C8W_ATIVO|"
Local cCabec		:=	"/eSocial/evtTabOperPort/infoOperPortuario"
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
Local nTamCod		:=	TamSX3( "C8W_CNPJOP" )[1]
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
cValChv := FTafGetVal( cCabec + cTagOper + "/ideOperPortuario/cnpjOpPortuario", 'C', .F., @aIncons, .F., '', '' )
If !Empty( cValChv )
	Aadd( aChave, { "C", "C8W_CNPJOP", cValChv, .T.} )
	nIndChv	:= 4
	cChave 	:= Padr(cValChv,nTamCod)
EndIf	

//Verificar se a data inicial foi informado para a chave( Se nao informado sera adotada a database internamente )
cValChv := FTafGetVal( cCabec + cTagOper + "/ideOperPortuario/iniValid", 'C', .F., @aIncons, .F., '', '' )
cValChv := TAF248Format("C8W_DTINI", cValChv)
If !Empty( cValChv )
	Aadd( aChave, { "C", "C8W_DTINI", cValChv, .T. } )
	nIndChv 	:= 5
	cPerIni 	:= cValChv
	cPerIniOri	:= cPerIni
EndIf

//Verificar se a data final foi informado para a chave( Se nao informado sera adotado vazio )
cValChv := FTafGetVal( cCabec + cTagOper + "/ideOperPortuario/fimValid", 'C', .F., @aIncons, .F., '', '' )
cValChv := TAF248Format("C8W_DTFIN", cValChv)
If !Empty(cValChv)		
	Aadd( aChave, { "C", "C8W_DTFIN", cValChv, .T.} )
	nIndChv	:= 2
	cPerFin 	:= cValChv
EndIf

If nOpc == 4	
	If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', ''  )
		cNewDtIni 	:= TAF248Format("C8W_DTINI", FTafGetVal( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', '' ))	
		aNewData[1]	:= cNewDtIni
		cPerIni 	:= cNewDtIni
		lNewValid	:= .T.
	EndIf

	If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', ''  )
		cNewDtFin 	:= TAF248Format("C8W_DTFIN", FTafGetVal( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', '' ))
		aNewData[2]	:= cNewDtFin
		cPerFin		:= cNewDtFin
		lNewValid	:= .T.
	EndIf
EndIf

//Valida as regras da nova validade
If Empty(aIncons)	
	VldEvTab( "C8W", 5, cChave, cPerIni, cPerFin, 2, nOpc, @aIncons, cPerIniOri,,, lNewValid )	
EndIf

If Empty(aIncons)
	
	Begin Transaction
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao para validar se a operacao desejada pode ser realizada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FTafVldOpe( "C8W", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA248", cCmpsNoUpd, nIndIDVer, .T., aNewData )

			If TafColumnPos( "C8W_LOGOPE" )
				cLogOpeAnt := C8W->C8W_LOGOPE
			endif		

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
			//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Carrego array com os campos De/Para de gravacao das informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TAF248Rul( cTagOper, @aRules, cCodEvent, cOwner )

				If TAFColumnPos( "C8W_XMLID" )
					oModel:LoadValue( "MODEL_C8W", "C8W_XMLID", cXmlID )
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o aRules para gravar as informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nlI := 1 To Len( aRules )
					oModel:LoadValue( "MODEL_C8W", aRules[ nlI, 01 ], FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F., ,aRules[ nlI, 01 ] ) )
				Next

				If Findfunction("TAFAltMan")
					if nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C8W', 'C8W_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C8W', 'C8W_LOGOPE' , '', cLogOpeAnt )
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

EndIf

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
/*/{Protheus.doc} TAF248Rul           

Regras para gravacao das informacoes do registro S-1080 do E-Social

@Param
nOper      - Operacao a ser realizada ( 3 = Inclusao / 4 = Alteracao / 5 = Exclusao )

@Return	
aRull  - Regras para a gravacao das informacoes


@author Fabio V. Santana
@since 07/10/2013
@version 1.0

/*/                        	
//-------------------------------------------------------------------
Static Function TAF248Rul( cTagOper, aRull, cCodEvent, cOwner )

Default cTagOper	:= ""
Default aRull		:= ""
Default cCodEvent	:= ""
Default cOwner	:= ""

if TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtTabOperPort/infoOperPortuario" + cTagOper + "/ideOperPortuario/cnpjOpPortuario") )
	Aadd( aRull, { "C8W_CNPJOP", "/eSocial/evtTabOperPort/infoOperPortuario" + cTagOper + "/ideOperPortuario/cnpjOpPortuario", "C", .F. } )
EndIf

if TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtTabOperPort/infoOperPortuario" + cTagOper + "/dadosOperPortuario/aliqRat") )
	Aadd( aRull, { "C8W_ALQRAT", "/eSocial/evtTabOperPort/infoOperPortuario" + cTagOper + "/dadosOperPortuario/aliqRat"        , "N", .F. } )
EndIf

if TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtTabOperPort/infoOperPortuario" + cTagOper + "/dadosOperPortuario/fap"))
	Aadd( aRull, { "C8W_FAP"   , "/eSocial/evtTabOperPort/infoOperPortuario" + cTagOper + "/dadosOperPortuario/fap"            , "N", .F. } )
EndIf

if TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtTabOperPort/infoOperPortuario" + cTagOper + "/dadosOperPortuario/aliqRatAjust") )
	Aadd( aRull, { "C8W_ALQAJU", "/eSocial/evtTabOperPort/infoOperPortuario" + cTagOper + "/dadosOperPortuario/aliqRatAjust", "N", .F. } )
EndIf

Return( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Fabio V. Santana
@Since 08/10/2013
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local cLogOpe
Local cLogOpeAnt

Local cVerAnt    	:= ""  
Local cProtocolo 	:= ""
Local cVersao    	:= ""  
Local cChvRegAnt 	:= ""
Local cEvento	 	:= ""
Local nOperation 	:= oModel:GetOperation()

Local nlI, nlY   	:= 0   
Local aGrava     	:= {}

Local oModelC8W  	:= Nil
Local lRetorno 	:= .T.

cLogOpe		:= ""
cLogOpeAnt	:= ""

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_INSERT

	TafAjustID( "C8W", oModel)

		oModel:LoadValue( 'MODEL_C8W', 'C8W_VERSAO', xFunGetVer() )

		If Findfunction("TAFAltMan")
			TAFAltMan( 3 , 'Save' , oModel, 'MODEL_C8W', 'C8W_LOGOPE' , '2', '' )
		Endif

		FwFormCommit( oModel )
		
	ElseIf nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seek para posicionar no registro antes de realizar as validacoes,³
		//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
		//³os campos nao usados como _STATUS                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    C8W->( DbSetOrder( 6 ) )
	    If C8W->( MsSeek( xFilial( 'C8W' ) + C8W->C8W_ID + '1' ) )
	    	    	    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o registro ja foi transmitido³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    If C8W->C8W_STATUS == "4" 
				
				If nOperation == MODEL_OPERATION_DELETE 
					oModel:DeActivate()
					oModel:SetOperation( 4 ) 	
					oModel:Activate()
		        EndIf
		        
				oModelC8W := oModel:GetModel( 'MODEL_C8W' )     
										
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busco a versao anterior do registro para gravacao do rastro³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cVerAnt    := oModelC8W:GetValue( "C8W_VERSAO" )				
				cProtocolo := oModelC8W:GetValue( "C8W_PROTUL" )
				cEvento	   := oModelC8W:GetValue( "C8W_EVENTO" )

				If TafColumnPos( "C8W_LOGOPE" )
					cLogOpeAnt := oModelC8W:GetValue( "C8W_LOGOPE" )
				endif

				If nOperation == MODEL_OPERATION_DELETE .And. cEvento == "E" 
					// Não é possível excluir um evento de exclusão já transmitido
					TAFMsgVldOp(oModel,"4")
					lRetorno := .F.
				Else
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas       ³
					//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
					//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
					//³nao devem ser consideradas neste momento                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nlI := 1 To 1
						For nlY := 1 To Len( oModelC8W:aDataModel[ nlI ] )			
							Aadd( aGrava, { oModelC8W:aDataModel[ nlI, nlY, 1 ], oModelC8W:aDataModel[ nlI, nlY, 2 ] } )									
						Next
					Next	       						
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas       ³
					//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
					//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
					//³nao devem ser consideradas neste momento                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
					For nlI := 1 To Len( aGrava )	
						oModel:LoadValue( 'MODEL_C8W', aGrava[ nlI, 1 ], C8W->&( aGrava[ nlI, 1 ] ) )
					Next                        
							
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³ 
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( 'C8W', '2' ,.F.,FwFldGet("C8W_DTFIN"),FwFldGet("C8W_DTINI"),C8W->C8W_DTINI )
					
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
						oModel:LoadValue( 'MODEL_C8W', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
					Next

					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C8W', 'C8W_LOGOPE' , '' , cLogOpeAnt )	
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
					oModel:LoadValue( 'MODEL_C8W', 'C8W_VERSAO', cVersao )  
					oModel:LoadValue( 'MODEL_C8W', 'C8W_VERANT', cVerAnt )									          				    
					oModel:LoadValue( 'MODEL_C8W', 'C8W_PROTPN', cProtocolo )									          						
					oModel:LoadValue( 'MODEL_C8W', 'C8W_PROTUL', "" )									          				
					// Tratamento para limpar o ID unico do xml
					cAliasPai := "C8W"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf
					
					If nOperation == MODEL_OPERATION_DELETE 		
						oModel:LoadValue( 'MODEL_C8W', 'C8W_EVENTO', "E" )                                               		                    		
					Else
						If cEvento == "E"
							oModel:LoadValue( 'MODEL_C8W', 'C8W_EVENTO', "I" )
						Else
							oModel:LoadValue( 'MODEL_C8W', 'C8W_EVENTO', "A" )
						EndIf			
					EndIf
					    
					FwFormCommit( oModel )
				EndIf
			
			Elseif C8W->C8W_STATUS == "2"
				//Não é possível alterar um registro com aguardando validação
				TAFMsgVldOp(oModel,"2")
				lRetorno := .F.		
			
			Else         
				cChvRegAnt := C8W->C8W_ID + C8W->C8W_VERANT        

				If TafColumnPos( "C8W_LOGOPE" )
					cLogOpeAnt := C8W->C8W_LOGOPE
				endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³No caso de um evento de Exclusao de um registro com status 'Excluido' deve-se³
				//³perguntar ao usuario se ele realmente deseja realizar a inclusao.            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If C8W->C8W_EVENTO == "E"
	                If nOperation == MODEL_OPERATION_DELETE
	                	If Aviso( xValStrEr("000754"), xValStrEr("000755"), { xValStrEr("000756"), xValStrEr("000757") }, 1 ) == 2 //##"Registro Excluído" ##"O Evento de exclusão não foi transmitido. Deseja realmente exclui-lo ou manter o evento de exclusão para transmissão posterior ?" ##"Excuir" ##"Manter"
								cChvRegAnt := ""
						EndIf
		            Else
	                	oModel:LoadValue( "MODEL_C8W", "C8W_EVENTO", "A" )
	                EndIf
				EndIf
													
				If !Empty( cChvRegAnt )
					TAFAltStat( 'C8W', " " )

					If nOperation == MODEL_OPERATION_UPDATE .And. Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C8W', 'C8W_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )

					If nOperation == MODEL_OPERATION_DELETE
						If C8W->C8W_EVENTO == "A" .Or. C8W->C8W_EVENTO == "E"
							TAFRastro( 'C8W', 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
						EndIf
					EndIf
				EndIf
			EndIf
		Elseif TafIndexInDic("C8W", 7, .T.)

			C8W->( DbSetOrder( 7 ) )
	    	If C8W->( MsSeek( xFilial( 'C8W' ) + FwFldGet('C8W_ID')+ 'E42' ) ) 

				If nOperation == MODEL_OPERATION_DELETE 
					// Não é possível excluir um evento de exclusão já transmitido
					TAFMsgVldOp(oModel,"4")
					lRetorno := .F.
				EndIf

			EndIF

		EndIf			
	EndIf      
			
End Transaction 

Return (lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF248Format

Formata os campos do registro S-1080 do E-Social

@Param
cCampo 	  - Campo que deve ser formatado
cValorXml - Valor a ser formatado

@Return
cFormatValue - Valor já formatado

@author Vitor Siqueira
@since 12/01/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF248Format(cCampo, cValorXml)

Local cFormatValue, cRet := ''

If (cCampo == 'C8W_DTINI' .OR. cCampo == 'C8W_DTFIN')
	cFormatValue := StrTran( StrTran( cValorXml, "-", "" ), "/", "")
	cRet := Substr(cFormatValue, 5, 2) + Substr(cFormatValue, 1,4)
Else
	cRet := cValorXml
EndIf

Return( cRet )
