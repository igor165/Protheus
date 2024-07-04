#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA248.CH"

//--------------------------------------------------------------------
/*/{Protheus.doc} TAFA248
Cadastro de Operadores Portu�rios - S-1080

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

	oBrw:SetDescription(STR0001)    //"Cadastro de Operadores Portu�rios"
	oBrw:SetAlias( 'C8W')
	oBrw:SetMenuDef( 'TAFA248' )
	oBrw:SetFilterDefault( "C8W_ATIVO == '1' .Or. (C8W_EVENTO == 'E' .And. C8W_STATUS = '4' .And. C8W_ATIVO = '2')" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )

	oBrw:AddLegend( "C8W_EVENTO == 'I' ", "GREEN" , STR0006 ) //"Registro Inclu�do"
	oBrw:AddLegend( "C8W_EVENTO == 'A' ", "YELLOW", STR0007 ) //"Registro Alterado"
	oBrw:AddLegend( "C8W_EVENTO == 'E' .And. C8W_STATUS <> '4' ", "RED"   , STR0008 ) //"Registro exclu�do n�o transmitido"
	oBrw:AddLegend( "C8W_EVENTO == 'E' .And. C8W_STATUS == '4' .And. C8W_ATIVO = '2' ", "BLACK"   , STR0012 ) //"Registro exclu�do n�o transmitido"

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
cSeqXml - Numero sequencial para composi��o da chave ID do XML

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
		cDtFin  := Iif(Empty(C8W->C8W_DTFIN), "", Substr(C8W->C8W_DTFIN,3,4) +"-"+ Substr(C8W->C8W_DTFIN,1,2)) //Fa�o o Iif pois se a data estiver vazia a string recebia '  -  -   '
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

//����������������������Ŀ
//�Estrutura do cabecalho�
//������������������������
cXml := xTafCabXml(cXml,"C8W", cLayout,cReg, ,cSeqXml)

//����������������������������Ŀ
//�Executa gravacao do registro�
//������������������������������
If !lJob
	xTafGerXml(cXml,cLayout)
EndIf

Return(cXml) 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF248Grv
@type			function
@description	Fun��o de grava��o para atender o registro S-1080.
@author			Fabio V. Santana
@since			07/10/2013
@version		1.0
@param			cLayout		-	Nome do Layout que est� sendo enviado
@param			nOpc		-	Op��o a ser realizada ( 3 = Inclus�o, 4 = Altera��o, 5 = Exclus�o )
@param			cFilEv		-	Filial do ERP para onde as informa��es dever�o ser importadas
@param			oXML		-	Objeto com as informa��es a serem manutenidas ( Outras Integra��es )
@param			cOwner
@param			cFilTran
@param			cPredeces
@param			nTafRecno
@param			cComplem
@param			cGrpTran
@param			cEmpOriGrp
@param			cFilOriGrp
@param			cXmlID		-	Atributo Id, �nico para o XML do eSocial. Utilizado para importa��o de dados de clientes migrando para o TAF
@return			lRet		-	Vari�vel que indica se a importa��o foi realizada, ou seja, se as informa��es foram gravadas no banco de dados
@param			aIncons		-	Array com as inconsist�ncias encontradas durante a importa��o
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

Private lVldModel	:=	.T. //Caso a chamada seja via integra��o, seto a vari�vel de controle de valida��o como .T.
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
	
		//�������������������������������������������������������������Ŀ
		//�Funcao para validar se a operacao desejada pode ser realizada�
		//���������������������������������������������������������������
		If FTafVldOpe( "C8W", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA248", cCmpsNoUpd, nIndIDVer, .T., aNewData )

			If TafColumnPos( "C8W_LOGOPE" )
				cLogOpeAnt := C8W->C8W_LOGOPE
			endif		

			//����������������������������������������������������������������Ŀ
			//�Quando se tratar de uma Exclusao direta apenas preciso realizar �
			//�o Commit(), nao eh necessaria nenhuma manutencao nas informacoes�
			//������������������������������������������������������������������
			If nOpc <> 5

				//���������������������������������������������������������������Ŀ
				//�Carrego array com os campos De/Para de gravacao das informacoes�
				//�����������������������������������������������������������������
				TAF248Rul( cTagOper, @aRules, cCodEvent, cOwner )

				If TAFColumnPos( "C8W_XMLID" )
					oModel:LoadValue( "MODEL_C8W", "C8W_XMLID", cXmlID )
				EndIf

				//����������������������������������������Ŀ
				//�Rodo o aRules para gravar as informacoes�
				//������������������������������������������
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
			
			//���������������������������Ŀ
			//�Efetiva a operacao desejada�
			//�����������������������������
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

//����������������������������������������������������������Ŀ
//�Zerando os arrays e os Objetos utilizados no processamento�
//������������������������������������������������������������
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

		//�����������������������������������������������������������������Ŀ
		//�Seek para posicionar no registro antes de realizar as validacoes,�
		//�visto que quando nao esta pocisionado nao eh possivel analisar   �
		//�os campos nao usados como _STATUS                                �
		//�������������������������������������������������������������������
	    C8W->( DbSetOrder( 6 ) )
	    If C8W->( MsSeek( xFilial( 'C8W' ) + C8W->C8W_ID + '1' ) )
	    	    	    
			//��������������������������������Ŀ
			//�Se o registro ja foi transmitido�
			//����������������������������������
		    If C8W->C8W_STATUS == "4" 
				
				If nOperation == MODEL_OPERATION_DELETE 
					oModel:DeActivate()
					oModel:SetOperation( 4 ) 	
					oModel:Activate()
		        EndIf
		        
				oModelC8W := oModel:GetModel( 'MODEL_C8W' )     
										
				//�����������������������������������������������������������Ŀ
				//�Busco a versao anterior do registro para gravacao do rastro�
				//�������������������������������������������������������������
				cVerAnt    := oModelC8W:GetValue( "C8W_VERSAO" )				
				cProtocolo := oModelC8W:GetValue( "C8W_PROTUL" )
				cEvento	   := oModelC8W:GetValue( "C8W_EVENTO" )

				If TafColumnPos( "C8W_LOGOPE" )
					cLogOpeAnt := oModelC8W:GetValue( "C8W_LOGOPE" )
				endif

				If nOperation == MODEL_OPERATION_DELETE .And. cEvento == "E" 
					// N�o � poss�vel excluir um evento de exclus�o j� transmitido
					TAFMsgVldOp(oModel,"4")
					lRetorno := .F.
				Else
				
					//�����������������������������������������������������������������Ŀ
					//�Neste momento eu gravo as informacoes que foram carregadas       �
					//�na tela, pois neste momento o usuario ja fez as modificacoes que �
					//�precisava e as mesmas estao armazenadas em memoria, ou seja,     �
					//�nao devem ser consideradas neste momento                         �
					//�������������������������������������������������������������������
					For nlI := 1 To 1
						For nlY := 1 To Len( oModelC8W:aDataModel[ nlI ] )			
							Aadd( aGrava, { oModelC8W:aDataModel[ nlI, nlY, 1 ], oModelC8W:aDataModel[ nlI, nlY, 2 ] } )									
						Next
					Next	       						
					
					//�����������������������������������������������������������������Ŀ
					//�Neste momento eu gravo as informacoes que foram carregadas       �
					//�na tela, pois neste momento o usuario ja fez as modificacoes que �
					//�precisava e as mesmas estao armazenadas em memoria, ou seja,     �
					//�nao devem ser consideradas neste momento                         �
					//�������������������������������������������������������������������		
					For nlI := 1 To Len( aGrava )	
						oModel:LoadValue( 'MODEL_C8W', aGrava[ nlI, 1 ], C8W->&( aGrava[ nlI, 1 ] ) )
					Next                        
							
					//�����������������������������������������������������������Ŀ
					//�Seto o campo como Inativo e gravo a versao do novo registro�
					//�no registro anterior                                       � 
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//�������������������������������������������������������������
					FAltRegAnt( 'C8W', '2' ,.F.,FwFldGet("C8W_DTFIN"),FwFldGet("C8W_DTINI"),C8W->C8W_DTINI )
					
					//��������������������������������������������������Ŀ
					//�Neste momento eu preciso setar a operacao do model�
					//�como Inclusao                                     �
					//����������������������������������������������������
					oModel:DeActivate()
					oModel:SetOperation( 3 ) 	
					oModel:Activate()		
									
					//�������������������������������������������������������Ŀ
					//�Neste momento eu realizo a inclusao do novo registro ja�
					//�contemplando as informacoes alteradas pelo usuario     �
					//���������������������������������������������������������
					For nlI := 1 To Len( aGrava )	
						oModel:LoadValue( 'MODEL_C8W', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
					Next

					//Necess�rio Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C8W', 'C8W_LOGOPE' , '' , cLogOpeAnt )	
					EndIf					
					
					//�������������������������������Ŀ
					//�Busco a versao que sera gravada�
					//���������������������������������
					cVersao := xFunGetVer()		 
					                                   
					//�����������������������������������������������������������Ŀ		
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//�������������������������������������������������������������		                                                                      				         
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
				//N�o � poss�vel alterar um registro com aguardando valida��o
				TAFMsgVldOp(oModel,"2")
				lRetorno := .F.		
			
			Else         
				cChvRegAnt := C8W->C8W_ID + C8W->C8W_VERANT        

				If TafColumnPos( "C8W_LOGOPE" )
					cLogOpeAnt := C8W->C8W_LOGOPE
				endif

				//�����������������������������������������������������������������������������Ŀ
				//�No caso de um evento de Exclusao de um registro com status 'Excluido' deve-se�
				//�perguntar ao usuario se ele realmente deseja realizar a inclusao.            �
				//�������������������������������������������������������������������������������
				If C8W->C8W_EVENTO == "E"
	                If nOperation == MODEL_OPERATION_DELETE
	                	If Aviso( xValStrEr("000754"), xValStrEr("000755"), { xValStrEr("000756"), xValStrEr("000757") }, 1 ) == 2 //##"Registro Exclu�do" ##"O Evento de exclus�o n�o foi transmitido. Deseja realmente exclui-lo ou manter o evento de exclus�o para transmiss�o posterior ?" ##"Excuir" ##"Manter"
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
					// N�o � poss�vel excluir um evento de exclus�o j� transmitido
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
cFormatValue - Valor j� formatado

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
