#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA389.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA389
Cadastro de Ambientes de Trabalho - S-1060

@author Anderson Costa
@since 29/05/2015
@version 1.0
/*/ 
//-------------------------------------------------------------------
Function TAFA389()

	Private	oBrw := FWmBrowse():New()

	If FindFunction("TAFDesEven")
		TAFDesEven()
	EndIf

	oBrw:SetDescription(STR0001)    //"Cadastro de Ambientes de Trabalho"
	oBrw:SetAlias( 'T04')
	oBrw:SetMenuDef( 'TAFA389' )
	oBrw:SetFilterDefault( "T04_ATIVO == '1' .Or. (T04_EVENTO == 'E' .And. T04_STATUS = '4' .And. T04_ATIVO = '2')" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )

	oBrw:AddLegend( "T04_EVENTO == 'I' ", "GREEN" , STR0002 ) //"Registro Incluído"
	oBrw:AddLegend( "T04_EVENTO == 'A' ", "YELLOW", STR0003 ) //"Registro Alterado"
	oBrw:AddLegend( "T04_EVENTO == 'E' .And. T04_STATUS <> '4' ", "RED"   , STR0004 ) //"Registro excluído não transmitido"
	oBrw:AddLegend( "T04_EVENTO == 'E' .And. T04_STATUS == '4' .And. T04_ATIVO = '2' ", "BLACK"   , STR0009 ) //"Registro excluído transmitido"

	oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Anderson Costa
@since 29/05/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao := {}
Local aRotina := {}

If FindFunction('TafXmlRet')
	Aadd( aFuncao, { "" , "TafxmlRet('TAF389Xml','1060','T04')" , "1" } )
Else 
	Aadd( aFuncao, { "" , "TAF389Xml" , "1" } )
EndIf 
Aadd( aFuncao, { "" , "xFunHisAlt( 'T04', 'TAFA389' ,,,, 'TAF389XML','1060' )" , "3" } )
aAdd( aFuncao, { "" , "TAFXmlLote( 'T04', 'S-1060' , 'evtTabAmbiente' , 'TAF389Xml',, oBrw )" , "5" } )
Aadd( aFuncao, { "" , "xFunAltRec( 'T04' )" , "10" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif .Or. ViewEvent('S-1060')
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.TAFA389' OPERATION 2 ACCESS 0 //"Visualizar"
Else
	aRotina	:=	xFunMnuTAF( "TAFA389" , , aFuncao)
EndIf

Return( aRotina )

//------------------------------------------------------------------- 
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Anderson Costa
@since 29/05/2015
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function ModelDef()
Local oStruT04 := FWFormStruct( 1, 'T04' )
Local oModel := MPFormModel():New( 'TAFA389' , , , {|oModel| SaveModel( oModel ) } )

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
            
If lVldModel
	oStruT04:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_T04', /*cOwner*/, oStruT04)
oModel:GetModel("MODEL_T04"):SetPrimaryKey({"T04_CODIGO","T04_DTINI","T04_DTFIN"})

Return oModel   

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Anderson Costa
@since 29/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA389")
Local oStruT04 := FwFormStruct(2,"T04")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_T04",oStruT04,"MODEL_T04")

If FindFunction("TafAjustRecibo")
	TafAjustRecibo(oStruT04,"T04")
EndIf

oView:EnableTitleView("VIEW_T04",STR0001) //"Cadastro de Ambientes de Trabalho"

oView:CreateHorizontalBox("FIELDST04",100)

oView:SetOwnerView("VIEW_T04","FIELDST04")

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif
	xFunRmFStr(@oStruT04,"T04")
EndIf

If TafColumnPos( "T04_LOGOPE" )
	oStruT04:RemoveField( "T04_LOGOPE")
EndIf

Return(oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF389Xml
Funcao de geracao do XML para atender o registro S-1060
Quando a rotina for chamada o registro deve estar posicionado

@Param:
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@Return:
cXml - Estrutura do Xml do Layout S-1060

@author Anderson Costa
@since 29/05/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF389Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

Local cXml			:= ""
Local cLayout		:= "1060"
Local cEvento		:= ""
Local cReg			:= "TabAmbiente"
Local cDtIni		:= ""
Local cDtFin		:= ""
Local cId			:= ""
Local cVerAnt		:= ""
Local nRecnoSM0 	:= SM0->(Recno())
Local cVerSchema	:= SuperGetMv('MV_TAFVLES',.F.,"02_04_02")
Local lXmlVLd	:= IIF(FindFunction('TafXmlVLD'),TafXmlVLD('TAF389XML'),.T.)

Default cSeqXml := ""

If lXmlVLd
	If T04->T04_EVENTO $ "I|A"

		If T04->T04_EVENTO == "A"
			cEvento := "alteracao"

			cId := T04->T04_ID 
			cVerAnt := T04->T04_VERANT
			
			BeginSql alias 'T04TEMP'
				SELECT T04.T04_DTINI,T04.T04_DTFIN
				FROM %table:T04% T04
				WHERE T04.T04_FILIAL= %xfilial:T04% AND
				T04.T04_ID = %exp:cId% AND T04.T04_VERSAO = %exp:cVerAnt% AND 
				T04.%notDel%
			EndSql

			cDtIni := Iif(!Empty(('T04TEMP')->T04_DTINI),Substr(('T04TEMP')->T04_DTINI,3,4) + "-" + Substr(('T04TEMP')->T04_DTINI,1,2),"")
			cDtFin := Iif(!Empty(('T04TEMP')->T04_DTFIN),Substr(('T04TEMP')->T04_DTFIN,3,4) + "-" + Substr(('T04TEMP')->T04_DTFIN,1,2),"")

			('T04TEMP')->( DbCloseArea() )
			
		Else

			cEvento := "inclusao"
			cDtIni  := Iif(!Empty(T04->T04_DTINI),Substr(T04->T04_DTINI,3,4) + "-" + Substr(T04->T04_DTINI,1,2),"") //Faço o Iif pois se a data estiver vazia a string recebia '-'
			cDtFin  := Iif(!Empty(T04->T04_DTFIN),Substr(T04->T04_DTFIN,3,4) + "-" + Substr(T04->T04_DTFIN,1,2),"")
		EndIf

		cXml +=			"<infoAmbiente>"
		cXml +=				"<" + cEvento + ">"
		cXml +=					"<ideAmbiente>"	
		cXml +=						xTafTag("codAmb",T04->T04_CODIGO)
		cXml +=						xTafTag("iniValid",cDtIni)
		cXml +=						xTafTag("fimValid",cDtFin,,.T.)		
		cXml +=					"</ideAmbiente>"
		cXml +=					"<dadosAmbiente>"

		If cVerSchema >= "02_05_00"
			cXml +=						xTafTag("nmAmb",T04->T04_NMAMB)
		EndIf
		
		cXml +=						xTafTag("dscAmb",T04->T04_DESCRI)
		cXml +=						xTafTag("localAmb",T04->T04_LOCAMB)
		cXml +=						xTafTag("tpInsc",T04->T04_TPINSC,,.T.)
		cXml +=						xTafTag("nrInsc",T04->T04_NRINSC,PesqPict("T04","T04_NRINSC"),.T.)
		cXml +=						xTafTag("codLotacao",Posicione("C99",1, xFilial("C99")+T04->T04_LOTACA,"C99_CODIGO"),,.T.)
		cXml +=					"</dadosAmbiente>"
		
		If T04->T04_EVENTO == "A"
			If TafAtDtVld("T04", T04->T04_ID, T04->T04_DTINI, T04->T04_DTFIN, T04->T04_VERANT, .T.)
				cXml +=		"<novaValidade>"		
				cXml +=			TafGetDtTab(T04->T04_DTINI,T04->T04_DTFIN)
				cXml +=		"</novaValidade>"
			EndIf     		
		EndIf

		cXml +=			"</" + cEvento + ">"
		cXml +=			"</infoAmbiente>"

	ElseIf T04->T04_EVENTO == "E"

		cXml +=			"<infoAmbiente>"
		cXml +=				"<exclusao>"
		cXml +=					"<ideAmbiente>"
		cXml += 					xTafTag("codAmb",T04->T04_CODIGO)
		cXml +=						TafGetDtTab(T04->T04_DTINI,T04->T04_DTFIN)
		cXml +=					"</ideAmbiente>"
		cXml +=				"</exclusao>"
		cXml +=			"</infoAmbiente>"
	EndIf

	/*--------------------
	Estrutura do cabecalho
	--------------------*/

	If nRecnoSM0 > 0
		SM0->(dbGoto(nRecnoSM0))
	EndIf
	cXml := xTafCabXml(cXml,"T04", cLayout,cReg,,cSeqXml)

	/*--------------------------
	Executa gravacao do registro
	--------------------------*/

	If !lJob
		xTafGerXml(cXml,cLayout)
	EndIf
EndIf
Return(cXml) 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF389Grv
@type			function
@description	Função de gravação para atender o registro S-1060.
@author			Anderson Costa
@since			29/05/2015
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
Function TAF389Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

Local cCmpsNoUpd	:=	"|T04_FILIAL|T04_ID|T04_VERSAO|T04_VERANT|T04_PROTPN|T04_EVENTO|T04_STATUS|T04_ATIVO|"
Local cCabec		:=	"/eSocial/evtTabAmbiente/infoAmbiente"
Local cValChv		:=	""
Local cNewDtIni		:=	""
Local cNewDtFin		:=	""
Local cInconMsg		:=	""
Local cCodEvent		:=	Posicione( "C8E", 2, xFilial( "C8E" ) + "S-" + cLayout, "C8E->C8E_ID" )
Local cChave		:=	""
Local cPerIni		:=	""
Local cPerFin		:=	""
Local cPerIniOri	:=	""
Local nIndex		:=	2
Local nIndIDVer		:=	1
Local nlI			:=	0
Local nTamCod		:=	TamSX3( "T04_CODIGO" )[1]
Local lRet			:=	.F.
Local aIncons		:=	{}
Local aRules		:=	{}
Local aChave		:=	{}
Local aNewData		:=	{ Nil, Nil }
Local oModel		:=	Nil
Local cLogOpeAnt	:=  ""
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

//Verificar se o numero de inscricao foi informado para a chave( Obrigatorio ser informado )
cValChv := FTafGetVal( cCabec + cTagOper + '/ideAmbiente/codAmb', 'C', .F., @aIncons, .F., '', '' )
If !Empty( cValChv )
	Aadd( aChave, { "C", "T04_CODIGO", cValChv, .T. } )
	nIndex := 4  //T04_FILIAL+T04_CODIGO+T04_ATIVO 
	cChave += Padr(cValChv,nTamCod)
EndIf


//Verificar se a data inicial foi informado para a chave( Se nao informado sera adotada a database internamente )
cValChv := FTafGetVal( cCabec + cTagOper + "/ideAmbiente/iniValid", 'C', .F., @aIncons, .F., '', '' )
cValChv := StrTran( cValChv, "-", "" )
cValChv := Substr(cValChv, 5, 2) + Substr(cValChv, 1,4) 
If !Empty( cValChv )
	aAdd( aChave, { "C", "T04_DTINI", cValChv, .T. } )
	nIndex := 5  //T04_FILIAL+T04_CODIGO+T04_DTINI+T04_ATIVO
	cPerIni := cValChv
	cPerIniOri := cValChv
EndIf

//Verificar se a data final foi informado para a chave( Se nao informado sera adotado vazio )
cValChv := FTafGetVal( cCabec + cTagOper + "/ideAmbiente/fimValid", 'C', .F., @aIncons, .F., '', '' )
cValChv := StrTran( cValChv, "-", "" )
cValChv := Substr(cValChv, 5, 2) + Substr(cValChv, 1,4) 
If !Empty( cValChv )
	aAdd( aChave, { "C", "T04_DTFIN", cValChv, .T.} )
	nIndex := 2 //T04_FILIAL+T04_CODIGO+T04_DTINI+T04_DTFIN+T04_ATIVO
	cPerFin := cValChv      
EndIf

If nOpc == 4
	If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/iniValid", 'C', 'C', .F., @aIncons, .F., '', ''  )
		cNewDtIni := FTafGetVal( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', '' )
		cNewDtIni := StrTran( cNewDtIni, "-", "" )
		cNewDtIni := Substr(cNewDtIni, 5, 2) + Substr(cNewDtIni, 1,4) 
		aNewData[1] := cNewDtIni
		cPerIni 	:= cNewDtIni
		lNewValid	:= .T.
	EndIf
	
	If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/fimValid", 'C', 'C', .F., @aIncons, .F., '', ''  )
		cNewDtFin := FTafGetVal( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', '' )
		cNewDtFin := StrTran( cNewDtFin, "-", "" )
		cNewDtFin := Substr(cNewDtFin, 5, 2) + Substr(cNewDtFin, 1,4) 
		aNewData[2] := cNewDtFin
		cPerFin 	:= cNewDtFin
		lNewValid	:= .T.
	EndIf
EndIf

/*-------------------------------
Valida as regras da nova validade
-------------------------------*/

If Empty(aIncons)
	VldEvTab( "T04", 5, cChave, cPerIni, cPerFin, 2, nOpc, @aIncons, cPerIniOri,,, lNewValid  )
EndIf

If Empty(aIncons)	

	Begin Transaction	
	
		/*-----------------------------------------------------------
		Funcao para validar se a operacao desejada pode ser realizada
		-----------------------------------------------------------*/

		If FTafVldOpe( "T04", nIndex, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA389", cCmpsNoUpd, nIndIDVer, .T., aNewData )

			If TafColumnPos( "T04_LOGOPE" )
				cLogOpeAnt := T04->T04_LOGOPE
			endif

			/*-------------------------------------------------------------
			Carrego array com os campos De/Para de gravacao das informacoes
			-------------------------------------------------------------*/			
			aRules := TAF389Rul( cTagOper, cCodEvent, cOwner )
	
			/*--------------------------------------------------------------
			Quando se tratar de uma Exclusao direta apenas preciso realizar
			o Commit(), nao eh necessaria nenhuma manutencao nas informacoes
			--------------------------------------------------------------*/

			If nOpc <> 5 
	
				oModel:LoadValue( "MODEL_T04", "T04_FILIAL", T04->T04_FILIAL)              

				If TAFColumnPos( "T04_XMLID" )
					oModel:LoadValue( "MODEL_T04", "T04_XMLID", cXmlID )
				EndIf

				/*--------------------------------------
				Executo o aRules para gravar as informações
				--------------------------------------*/

				For nlI := 1 To Len( aRules )
				 	oModel:LoadValue( "MODEL_T04", aRules[ nlI, 01 ], FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F., ,aRules[ nlI, 01 ] ) )
				Next

				If Findfunction("TAFAltMan")
					if nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T04', 'T04_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T04', 'T04_LOGOPE' , '', cLogOpeAnt )
					EndIf
				EndIf 
	       EndIf       
	      
			/*-------------------------
			Efetiva a operacao desejada
			-------------------------*/

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

/*--------------------------------------------------------
Zerando os arrays e os Objetos utilizados no processamento
--------------------------------------------------------*/

aSize( aRules, 0 ) 
aRules     := Nil

aSize( aChave, 0 ) 
aChave     := Nil    

Return { lRet, aIncons } 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAF389Rul           

Regras para gravacao das informacoes do registro S-1060 do E-Social

@Param
nOper      - Operacao a ser realizada ( 3 = Inclusao / 4 = Alteracao / 5 = Exclusao )

@Return	
aRull  - Regras para a gravacao das informacoes


@author Anderson Costa
@since 29/05/2015
@version 1.0

/*/                        	
//-------------------------------------------------------------------
Static Function TAF389Rul( cTagOper, cCodEvent, cOwner )

Local aRull      	:= {}
Local cCabec     	:= "/eSocial/evtTabAmbiente/infoAmbiente"

Default cTagOper	:= ""
Default cCodEvent	:= ""
Default cOwner 		:= ""

	If TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/ideAmbiente/codAmb"))
		Aadd( aRull, { "T04_CODIGO", cCabec + cTagOper + "/ideAmbiente/codAmb", "C", .F. } 									) //codAmb	
	EndIf

	If TafXNode(oDados , cCodEvent, cOwner,( cCabec + cTagOper + "/dadosAmbiente/nmAmb"))
		Aadd( aRull, { "T04_NMAMB", cCabec + cTagOper + "/dadosAmbiente/nmAmb", "C", .F. } 									) //nmAmb	
	EndIf
	
	If TafXNode(oDados , cCodEvent, cOwner,( cCabec + cTagOper + "/dadosAmbiente/dscAmb"))
		Aadd( aRull, { "T04_DESCRI", cCabec + cTagOper + "/dadosAmbiente/dscAmb", "C", .F. } 								) //dscAmb	
	EndIf
	
	If TafXNode(oDados , cCodEvent, cOwner,( cCabec + cTagOper + "/dadosAmbiente/localAmb"))
		Aadd( aRull, { "T04_LOCAMB", cCabec + cTagOper + "/dadosAmbiente/localAmb"	, "C", .F. } 							) //localAmb
	EndIf
	
	If TafXNode(oDados , cCodEvent, cOwner,( cCabec + cTagOper + "/dadosAmbiente/tpInsc"))
		Aadd( aRull, { "T04_TPINSC", cCabec + cTagOper + "/dadosAmbiente/tpInsc", "C", .F. } 								) //tpInsc
	EndIf

	If TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosAmbiente/nrInsc"))
		Aadd( aRull, { "T04_NRINSC", cCabec + cTagOper + "/dadosAmbiente/nrInsc", "C", .F. } 								) //nrInsc
	EndIf

	If TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosAmbiente/codLotacao"))
		aAdd( aRull, { "T04_LOTACA", FGetIdInt("codLotacao",,cCabec + cTagOper + "/dadosAmbiente/codLotacao"), "C", .T. } 	) //codLotacao	
	EndIf
	
Return( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo	

@Param  oModel -> Modelo de dados

@Return .T.

@Author Anderson Costa
@Since 29/05/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local cLogOpe		
Local cLogOpeAnt	

Local cVerAnt    := ""  
Local cProtocolo := ""
Local cVersao    := ""
Local cEvento	 := ""  
Local cChvRegAnt := ""
Local nOperation := oModel:GetOperation()

Local nT04       := 0   

Local aGrava     := {}

Local oModelT04  := Nil

Local lRetorno   := .T.

cLogOpe    := ""
cLogOpeAnt := ""

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_INSERT
		
		oModel:LoadValue( 'MODEL_T04', 'T04_VERSAO', xFunGetVer() )

		If Findfunction("TAFAltMan")
			TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T04', 'T04_LOGOPE' , '2', '' )
		Endif

		FwFormCommit( oModel )  
		
	ElseIf nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE 

		/*---------------------------------------------------------------
		Seek para posicionar no registro antes de realizar as validacoes,
		visto que quando nao esta pocisionado nao eh possivel analisar   
		os campos nao usados como _STATUS                                
		---------------------------------------------------------------*/
		
	    T04->( DbSetOrder( 3 ) )
	    If T04->( MsSeek( xFilial( 'T04' ) + FwFldGet('T04_ID') + '1' ) )
	    	    	    
			/*------------------------------
			Se o registro ja foi transmitido
			------------------------------*/
			
		    If T04->T04_STATUS == "4" 
		        
				oModelT04 := oModel:GetModel( 'MODEL_T04' )					
										
				/*---------------------------------------------------------
				Busco a versao anterior do registro para gravacao do rastro
				---------------------------------------------------------*/

				cVerAnt    	:= oModelT04:GetValue( "T04_VERSAO" )				
				cProtocolo		:= oModelT04:GetValue( "T04_PROTUL" )				
				cEvento	 	:= oModelT04:GetValue( "T04_EVENTO" )				

				If TafColumnPos( "T04_LOGOPE" )
					cLogOpeAnt := oModelT04:GetValue( "T04_LOGOPE" )
				endif

				If nOperation == MODEL_OPERATION_DELETE .And. cEvento == "E" 
					// Não é possível excluir um evento de exclusão já transmitido
					TAFMsgVldOp(oModel,"4")
					lRetorno := .F.
				Else
				
					/*----------------------------------------------------------------
					Neste momento eu gravo as informacoes que foram carregadas na tela
					----------------------------------------------------------------*/

					For nT04 := 1 to Len( oModelT04:aDataModel[ 1 ] )
						aAdd( aGrava, { oModelT04:aDataModel[ 1, nT04, 1 ], oModelT04:aDataModel[ 1, nT04, 2 ] } )
					Next nT04        
					      	
					/*---------------------------------------------------------
					Seto o campo como Inativo e gravo a versao do novo registro
					no registro anterior                                       
					                                                           
					ATENCAO -> A alteracao destes campos deve sempre estar     
					abaixo do Loop do For, pois devem substituir as informacoes
					que foram armazenadas no Loop acima                        
					---------------------------------------------------------*/

					FAltRegAnt( 'T04', '2' ,.F.,FwFldGet("T04_DTFIN"),FwFldGet("T04_DTINI"),T04->T04_DTINI )
			
					/*--------------------------------------------------------------
					Neste momento eu preciso setar a operacao do model como Inclusao                                     
					--------------------------------------------------------------*/

					oModel:DeActivate()
					oModel:SetOperation( 3 ) 	
					oModel:Activate()		
									
					/*----------------------------------------------------------
					Neste momento o usuario ja fez as modificacoes que          
					precisava e as mesmas estao armazenadas em memoria, ou seja,
					nao devem ser consideradas agora                            
					----------------------------------------------------------*/

					For nT04 := 1 to Len( aGrava )
						oModel:LoadValue( "MODEL_T04", aGrava[ nT04, 1 ], aGrava[ nT04, 2 ] )
					Next nT04

					/*-----------------------------------------------------
					Neste momento eu realizo a inclusao do novo registro ja
					contemplando as informacoes alteradas pelo usuario     
					-----------------------------------------------------*/

					For nT04 := 1 to Len( aGrava )
						oModel:LoadValue( "MODEL_T04", aGrava[ nT04, 1 ], aGrava[ nT04, 2 ] )
					Next nT04

					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T04', 'T04_LOGOPE' , '' , cLogOpeAnt )
					EndIf
					
					/*-----------------------------
					Busco a versao que sera gravada
					-----------------------------*/

					cVersao := xFunGetVer()		 
					                                   
					/*---------------------------------------------------------		
					ATENCAO -> A alteracao destes campos deve sempre estar     
					abaixo do Loop do For, pois devem substituir as informacoes
					que foram armazenadas no Loop acima                        
					---------------------------------------------------------*/

					oModel:LoadValue( 'MODEL_T04', 'T04_VERSAO', cVersao )  
					oModel:LoadValue( 'MODEL_T04', 'T04_VERANT', cVerAnt )									          				    
					oModel:LoadValue( 'MODEL_T04', 'T04_PROTPN', cProtocolo )									          						
					oModel:LoadValue( 'MODEL_T04', 'T04_PROTUL', "" )	

					// Tratamento para limpar o ID unico do xml
					cAliasPai := "T04"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf
					
					If nOperation == MODEL_OPERATION_DELETE
						oModel:LoadValue( 'MODEL_T04', 'T04_EVENTO', "E" )
					ElseIf cEvento == "E"
						oModel:LoadValue( 'MODEL_T04', 'T04_EVENTO', "I" )
					Else
						oModel:LoadValue( 'MODEL_T04', 'T04_EVENTO', "A" )
					EndIf   					
						FwFormCommit( oModel )
				EndIF
			
			Elseif T04->T04_STATUS == "2"

				//Não é possível alterar um registro com aguardando validação
				TAFMsgVldOp(oModel,"2")
				lRetorno := .F.
							
			Else         
		
		    	/*---------------------------------------------------------------
				Caso o registro nao tenha sido transmitido ainda, gravo sua chave
				---------------------------------------------------------------*/

				cChvRegAnt := T04->( T04_ID + T04_VERANT )

				If TafColumnPos( "T04_LOGOPE" )
					cLogOpeAnt := T04->T04_LOGOPE
				Endif

				/*---------------------------------------------------------------------------
				No caso de um evento de Exclusao de um registro com status 'Excluido' deve-se
				perguntar ao usuario se ele realmente deseja realizar a inclusao.
				---------------------------------------------------------------------------*/          
				
				If T04->T04_EVENTO == "E"
					If nOperation == MODEL_OPERATION_DELETE
						If Aviso( xValStrEr("000754"), xValStrEr("000755"), { xValStrEr("000756"), xValStrEr("000757") }, 1 ) == 2 //##"Registro Excluído" ##"O Evento de exclusão não foi transmitido. Deseja realmente exclui-lo ou manter o evento de exclusão para transmissão posterior ?" ##"Excuir" ##"Manter"
								cChvRegAnt := ""
						EndIf
					Else
							oModel:LoadValue( "MODEL_T04", "T04_EVENTO", "A" )
					EndIf
				EndIf
			
				/*--------------------------
				Executo a operacao escolhida
				--------------------------*/
				
				If !Empty( cChvRegAnt )
				
					/*-----------------------------------------------------------
					Funcao responsavel por setar o Status do registro para Branco
					-----------------------------------------------------------*/

					TAFAltStat( "T04", " " )

					If nOperation == MODEL_OPERATION_UPDATE .And. Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T04', 'T04_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )

					/*-------------------------------
					Caso a operacao seja uma exclusao
					-------------------------------*/

					If nOperation == MODEL_OPERATION_DELETE

						/*----------------------------------------------
						Funcao para setar o registro anterior como Ativo
						----------------------------------------------*/

						TAFRastro( "T04", 1, cChvRegAnt, .T. )
					EndIf
	
				EndIf
	
			EndIf 
		
		Elseif TafIndexInDic("T04", 6, .T.)

			T04->( DbSetOrder( 6 ) )
	    	If T04->( MsSeek( xFilial( 'T04' ) + FwFldGet('T04_ID')+ 'E42' ) ) 

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
