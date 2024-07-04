#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA303.CH'

Static lLaySimplif	:= TafLayESoc()
Static lSimplBeta   := TafLayESoc("S_01_01_00",, .T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA303
Cadastro MVC para atender o registro S-1299 (Fechamento dos Eventos Periódicos) antigo S-1399 do e-Social

@author Mick William da Silva
@since 21/01/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA303()

	Private	oBrw

	IF TafAtualizado()

		oBrw	:= FWmBrowse():New()

		oBrw:SetDescription( STR0013 ) //"Fechamento dos Eventos Periódicos"
		oBrw:SetMenuDef( 'TAFA303' )
		oBrw:SetAlias( 'CUO' )

		If FindFunction('TAFSetFilter')
			oBrw:SetFilterDefault(TAFBrwSetFilter("CUO","TAFA303","S-1299"))
		Else
			oBrw:SetFilterDefault( "CUO_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
		EndIf

		TafLegend(  1, "CUO" , @oBrw )

		oBrw:Activate()

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Paulo Sérgio V.B. Santana
@since 10/01/2014
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()

	Local aFuncao
	Local aRotina

	aFuncao := {}
	aRotina := {}

	Aadd( aFuncao, { "" , "TafxmlRet('TAF303Xml','1299','CUO')" 								, "1" 	} )
	Aadd( aFuncao, { "" , "xFunHisAlt( 'CUO', 'TAFA303' ,,,, 'TAF303XML','1299' )" 				, "3"	} )
	Aadd( aFuncao, { "" , "Taf303Prg" 															, "4", 3} )
	Aadd( aFuncao, { "" , "TAFXmlLote( 'CUO', 'S-1299' , 'evtFechaEvPer' , 'TAF303Xml',, oBrw )", "5"  	} )
	Aadd( aFuncao, { "" , "xFunAltRec( 'CUO' )" 												, "10"	} )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif
		ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA303' OPERATION 2 ACCESS 0
	Else
		aRotina	:=	xFunMnuTAF( "TAFA303" , , aFuncao)
	EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Paulo Sérgio V.B. Santana
@since 10/01/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruCUO
	Local oModel

	oStruCUO := FWFormStruct( 1, 'CUO' )// Cria a estrutura a ser usada no Modelo de Dados
	oModel := MPFormModel():New('TAFA303',,,{|oModel| SaveModel(oModel)} )

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruCUO:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	If lLaySimplif
		oStruCUO:RemoveField("CUO_IDRESP")
		oStruCUO:RemoveField("CUO_DESCRE")
		oStruCUO:RemoveField("CUO_COSMVT")
		oStruCUO:RemoveField("CUO_AQPROD")

		If !lSimplBeta
			oStruCUO:RemoveField("CUO_PAGDIV")
		EndIf
	Else
		oStruCUO:RemoveField( "CUO_TPGUIA" )
	EndIf

	// Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'MODEL_CUO', /*cOwner*/, oStruCUO)
	oModel:GetModel( 'MODEL_CUO' ):SetPrimaryKey( { 'CUO_FILIAL' , 'CUO_ID', 'CUO_VERSAO' } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View 

@author Mick William da Silva
@since 21/01/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel
	Local oStruCUO  := Nil
	Local oStruCUOp := Nil
	Local oStruCUOq := Nil
	Local oView
	Local cCmpIden
	Local cCmpIden2
	Local cCmpIden3
	Local cCmpIden4
	Local cCmpIden5
	Local cCmpList
	Local cCmpList1
	Local cCmpList2
	Local aCmpGrp
	Local nI

	oModel    := FWLoadModel( 'TAFA303' ) // objeto de Modelo de dados baseado no ModelDef() do fonte informado
	oView     := FWFormView():New()
	cCmpIden  := ""
	cCmpIden2 := ""
	cCmpIden3 := ""
	cCmpIden4 := ""
	cCmpIden5 := ""
	cCmpList  := ""
	cCmpList1 := ""
	cCmpList2 := ""
	cCmpList3 := ""
	aCmpGrp   := {}
	nI        := 0

	oView:SetModel( oModel )

	/*-----------------------------------------------------------------------------------
								Estrutura da View do Trabalhador
	-------------------------------------------------------------------------------------*/
	If !lLaySimplif

		cCmpIden	:= "CUO_ID|CUO_INDAPU|CUO_PERAPU|"
		cCmpIden2	:= "CUO_IDRESP|CUO_DESCRE|"
		cCmpList	:= "CUO_REMUN|CUO_PAGDIV|CUO_AQPROD|CUO_COMPRD|CUO_COAVNP|CUO_COMPER|CUO_COSMVT|"

		If TafColumnPos("CUO_EX1250")
			cCmpList1 := "CUO_EX1250|"
		EndIF

		cCmpIden4 := cCmpList + cCmpList1

	Else
		cCmpIden	:= "CUO_ID|CUO_INDAPU|CUO_PERAPU|CUO_TPGUIA|"
		cCmpIden4	:= "CUO_REMUN|"
		
		If lSimplBeta
			cCmpIden4 += "CUO_PAGDIV|"
		EndIf

		cCmpIden4 += "CUO_COMPRD|CUO_COAVNP|CUO_COMPER|CUO_EX1250|"

		If TafColumnPos("CUO_TDCTFW")
			cCmpList2 := "CUO_TDCTFW|"
		EndIF

		If TafColumnPos("CUO_NVALID")
			cCmpList3 := "CUO_NVALID|"
		EndIf

		cCmpIden4 := cCmpIden4 + cCmpList2 + cCmpList3
	EndIf

	cCmpIden5	:= "CUO_PROTUL|" 

	cCmpFil		:= cCmpIden+cCmpIden2+cCmpIden3+cCmpIden4
	oStruCUO 	:= FwFormStruct( 2, "CUO", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	oStruCUOp	:= FwFormStruct( 2, "CUO", { |x| AllTrim( x ) + "|" $ cCmpIden5 } )

	If TafColumnPos("CUO_DTRANS")
		cCmpIden5 := "CUO_DINSIS|CUO_DTRANS|CUO_HTRANS|CUO_DTRECP|CUO_HRRECP|"
		oStruCUOq := FwFormStruct( 2, "CUO",{|x| AllTrim( x ) + "|" $ cCmpIden5 } )  
	EndIf

	If lLaySimplif
		oStruCUO:RemoveField("CUO_IDRESP")
		oStruCUO:RemoveField("CUO_DESCRE")
		oStruCUO:RemoveField("CUO_COSMVT")
		oStruCUO:RemoveField("CUO_AQPROD")
	
		If !lSimplBeta
			oStruCUO:RemoveField("CUO_PAGDIV")
		EndIf
	Else
		oStruCUO:RemoveField( "CUO_TPGUIA" )
	EndIf

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruCUOp,"CUO")
	EndIf
	/*-----------------------------------------------------------------------------------
								Grupo de campos do Trabalhador
	-------------------------------------------------------------------------------------*/
	//"Fechamento dos Eventos Periódicos"
	oStruCUO:AddGroup( "GRP_FECHA_PERIODICOS", STR0013, "", 1 )//"Fechamento dos Eventos Periódicos" 

	If !lLaySimplif
		cCmpIden	:= "CUO_ID|CUO_INDAPU|CUO_PERAPU|"
		aCmpGrp 	:= StrToKarr( cCmpIden, "|" )
		For nI := 1 to Len( aCmpGrp )
			oStruCUO:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_FECHA_PERIODICOS" )
		Next nI
	Else
		cCmpIden	:= "CUO_ID|CUO_INDAPU|CUO_PERAPU|CUO_TPGUIA|"
		aCmpGrp		:= StrToKarr( cCmpIden, "|")
		For nI := 1 to Len( aCmpGrp )
			oStruCUO:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_FECHA_PERIODICOS" )
		Next nI
	EndIf

	//"Responsável pelas informações"
	oStruCUO:AddGroup( "GRP_RESP_INFORMAÇÕES", STR0014, "", 1 )//"Responsável pelas informações" 

	If !lLaySimplif 
		cCmpIden2 := "CUO_IDRESP|CUO_DESCRE|"
		aCmpGrp := StrToKarr( cCmpIden2, "|" )

		For nI := 1 to Len( aCmpGrp )
			oStruCUO:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_RESP_INFORMAÇÕES" )
		Next nI
	EndIf

	//"Informações do Fechamento"
	oStruCUO:AddGroup( "GRP_INFO_FECHAMENTO", STR0022, "", 1 ) 

	If !lLaySimplif
		cCmpList	:= "CUO_REMUN|CUO_PAGDIV|CUO_AQPROD|CUO_COMPRD|CUO_COAVNP|CUO_COMPER|CUO_COSMVT|"

		If TafColumnPos("CUO_EX1250")
			cCmpList1 := "CUO_EX1250|"
		EndIF

		cCmpIden4 := cCmpList + cCmpList1
		aCmpGrp := StrToKarr( cCmpIden4, "|" )
		For nI := 1 to Len( aCmpGrp )
			oStruCUO:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_INFO_FECHAMENTO" )
		Next nI
	Else
		cCmpIden4 := "CUO_REMUN|"

		If lSimplBeta
			cCmpIden4 += "CUO_PAGDIV|"
		EndIf

		cCmpIden4 += "CUO_COMPRD|CUO_COAVNP|CUO_COMPER|CUO_EX1250|"

		If TafColumnPos("CUO_TDCTFW")
			cCmpList2 := "CUO_TDCTFW|"
		EndIF

		If TafColumnPos("CUO_NVALID")
			cCmpList3 := "CUO_NVALID|"
		EndIf

		cCmpIden4 := cCmpIden4 + cCmpList2 + cCmpList3

		aCmpGrp := StrToKarr( cCmpIden4, "|" )
		For nI := 1 to Len( aCmpGrp )
			oStruCUO:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_INFO_FECHAMENTO" )
		Next nI
	EndIf

	oView:AddField( 'VIEW_CUO', oStruCUO , 'MODEL_CUO' )
	oView:AddField( 'VIEW_CUOp', oStruCUOp, 'MODEL_CUO' )


	If TafColumnPos("CUO_PROTUL")
		oView:EnableTitleView( 'VIEW_CUOp', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"  
	EndIf 
	If TafColumnPos("CUO_DTRANS")
		oView:AddField( 'VIEW_CUOq', oStruCUOq, 'MODEL_CUO' )
		oView:EnableTitleView( 'VIEW_CUOq', TafNmFolder("recibo",2) )
	EndIf

	oView:CreateHorizontalBox( 'PAINEL', 100 )
	oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL' )
	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0013 ) //"Fechamento dos Eventos Periódicos" 
	oView:CreateHorizontalBox( 'PAINEL_01', 100,,, 'FOLDER_SUPERIOR', 'ABA01' )

	If FindFunction("TafNmFolder")
		oView:AddSheet( 'FOLDER_SUPERIOR', "ABA02", TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0019 ) //"Protocolo de Transmissão"
	EndIf 

	If TafColumnPos("CUO_DTRANS")
		oView:CreateHorizontalBox( 'PAINEL_02', 20,,, 'FOLDER_SUPERIOR', 'ABA02' )
		oView:CreateHorizontalBox( 'PAINEL_03', 50,,, 'FOLDER_SUPERIOR', 'ABA02' )
	Else
		oView:CreateHorizontalBox( 'PAINEL_02', 100,,, 'FOLDER_SUPERIOR', 'ABA02' )
	EndIf

	oView:SetOwnerView( 'VIEW_CUO' , 'PAINEL_01')
	oView:SetOwnerView( 'VIEW_CUOp', 'PAINEL_02')
	If TafColumnPos("CUO_DTRANS")
		oView:SetOwnerView( 'VIEW_CUOq', 'PAINEL_03')
	EndIf

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif
		xFunRmFStr(@oStruCUO, 'CUO')	
	EndIf


Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Mick William da Silva
@since 21/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)
						
	Local cVerAnt	
	Local cProtocolo
	Local cVersao	
	Local cChvRegAnt
	Local cEvento
	Local cLogOpe	
	Local cLogOpeAnt
	Local nOperation
	Local nlI
	Local nlY 
	Local aGrava
	Local lRetorno

	cVerAnt    := ""
	cProtocolo := ""
	cVersao    := ""
	cChvRegAnt := ""
	cEvento    := ""
	cLogOpe    := ""
	cLogOpeAnt := ""
	nOperation := oModel:GetOperation()
	nlI        := 0
	nlY        := 0
	aGrava     := {}
	lRetorno   := .T.

	Begin Transaction 
		
		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "CUO", oModel)
		
			oModel:LoadValue( 'MODEL_CUO', 'CUO_VERSAO', xFunGetVer() ) 

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_CUO', 'CUO_LOGOPE' , '2', '' )
			Endif

			FwFormCommit( oModel )  
			
		ElseIf nOperation == MODEL_OPERATION_UPDATE
					
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CUO->( DbSetOrder( 1 ) )
			If CUO->( MsSeek( xFilial( 'CUO' ) + FWFLDGET("CUO_ID") + FWFLDGET("CUO_VERSAO") +  '1' ) ) // Ja esta posicionado no registro correto
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o registro ja foi transmitido³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If CUO->CUO_STATUS $ ( "4" )		
					oModel:SetErrorMessage(, , , , , STR0018, , , )//"Registro não pode ser alterado, pois o evento já se encontra na base do RET"
					lRetorno := .F.
				ElseIf CUO->CUO_STATUS == ( "2" )
					TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno := .F.
				Else
					//Alteração Sem Transmissão
					If TafColumnPos( "CUO_LOGOPE" )
						cLogOpeAnt := CUO->CUO_LOGOPE
					endif
				Endif
				
				If lRetorno			
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_CUO', 'CUO_LOGOPE' , '' , cLogOpeAnt )
					EndIf
					FwFormCommit( oModel )
					TAFAltStat( "CUO", " " )
				EndIf

			EndIf

		ElseIf nOperation == MODEL_OPERATION_DELETE 
			
			If CUO->CUO_STATUS == "4"
				oModel:SetErrorMessage(, , , , , xValStrEr("000783"), , , ) //"Registro não pode ser excluído, pois o evento já se encontra base do RET"  
				lRetorno := .F.
			Else
				cChvRegAnt := CUO->(CUO_ID + CUO_VERANT)

				TAFAltStat( 'CUO', " " )
				FwFormCommit( oModel )

				TAFRastro( 'CUO', 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )

			Endif
			
		EndIf      
				
	End Transaction 

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF303Xml
Funcao de geracao do XML para atender o registro S-1299
Quando a rotina for chamada o registro deve estar posicionado

@Param:
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@Return:
cXml - Estrutura do Xml do Layout S-1299

@author Mick William da Silva
@since 21/01/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF303Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cXml
	Local cLayout
	Local cReg
	Local aMensal
	Local lXmlVLd	:= IIF(FindFunction('TafXmlVLD'),TafXmlVLD('TAF303XML'),.T.)

	Default cSeqXml := ""

	If lXmlVLd

		cXml    := ""
		cLayout := "1299"
		cReg	 := "FechaEvPer"
		aMensal := {CUO->CUO_INDAPU,Substr(CUO->CUO_PERAPU,1,4) + Iif(!Empty(Substr(CUO->CUO_PERAPU,5)),"-" + Substr(CUO->CUO_PERAPU,5),"")}

		If !lLaySimplif
			C2J->( DbSetOrder( 5 ) )
			If C2J->( msSeek ( xFilial( "C2J" ) +CUO->( CUO_IDRESP ) ) )
				cXml +=	"<ideRespInf>"
				cXml +=		xTafTag("nmResp" 		, C2J->C2J_NOME , , .F. )
				cXml +=		xTafTag("cpfResp"		, C2J->C2J_CPF , , .F.  )
				cXml +=		xTafTag("telefone"	, AllTrim(C2J->C2J_DDD) + StrTran(C2J->C2J_FONE,"-","") , , .F. )
				cXml +=		xTafTag("email"		, C2J->C2J_EMAIL , , .T. )
				cXml +=	"</ideRespInf>"   
			EndIf
		EndIf

		cXml +=	"<infoFech>"

		cXml +=		xTafTag( "evtRemun"			,xFunTrcSN(CUO->CUO_REMUN,1) 	, , .F. )
		
		If !lLaySimplif .Or. lSimplBeta
			cXml +=	xTafTag("evtPgtos", xFunTrcSN(CUO->CUO_PAGDIV, 1))
		EndIf

		If !lLaySimplif
			cXml +=		xTafTag( "evtAqProd"		,xFunTrcSN(CUO->CUO_AQPROD,1)	, , .F. )
		EndIf

		cXml +=		xTafTag( "evtComProd"		,xFunTrcSN(CUO->CUO_COMPRD,1)	, , .F. )
		cXml +=		xTafTag( "evtContratAvNP"	,xFunTrcSN(CUO->CUO_COAVNP,1)	, , .F. )
		cXml +=		xTafTag( "evtInfoComplPer"	,xFunTrcSN(CUO->CUO_COMPER,1)	, , .F. )

		If !lLaySimplif
			cXml +=		xTafTag( "compSemMovto"	 	,Substr(CUO->CUO_COSMVT,1,4) + Iif(!Empty(Substr(CUO->CUO_COSMVT,5)),"-" + Substr(CUO->CUO_COSMVT,5),"") , , .T. )
		EndIf
		
		If TafColumnPos("CUO_EX1250")
			cXml +=		xTafTag( "indExcApur1250"	,xFunTrcSN(CUO->CUO_EX1250,1)	, , .T. )
		EndIf
		
		If TafColumnPos("CUO_TDCTFW")
			cXml +=		xTafTag( "transDCTFWeb"	,xFunTrcSN(CUO->CUO_TDCTFW,1)	, , .T. )
		EndIf

		If lLaySimplif .And. TafColumnPos("CUO_NVALID")
			cXml +=	xTafTag("naoValid", xFunTrcSN(CUO->CUO_NVALID, 1),, .T.)
		EndIf

		cXml +=	"</infoFech>"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do cabecalho³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cXml := xTafCabXml(cXml,"CUO",cLayout,cReg,aMensal,cSeqXml)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa gravacao do registro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lJob
			xTafGerXml(cXml,cLayout)
		EndIf

	EndIf
	
Return cXml 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF303Grv
@type			function
@description	Função de gravação para atender o registro S-1299.
@author			Paulo Sérgio V.B. Santana
@since			14/01/2014
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
Function TAF303Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local cCmpsNoUpd	:=	"|CUO_FILIAL|CUO_ID|CUO_VERSAO|CUO_VERANT|CUO_PROTPN|CUO_EVENTO|CUO_STATUS|CUO_ATIVO|"
	Local cCabec		:=	"/eSocial/evtFechaEvPer"
	Local cInconMsg		:=	""
	Local cPeriodo		:=	""
	Local cChave		:=	""
	Local cIndApur		:=	""
	Local cId			:=	""
	Local cChvRegAnt	:=	""
	Local cLogOpeAnt	:=	""
	Local cIndGuia		:= 	""
	Local nIndChv		:=	Iif(!lLaySimplif, 5, 6)
	Local nIndIDVer		:=	1
	Local nlI			:=	0
	Local nSeqErrGrv	:=	0
	Local lRet			:=	.F.
	Local aIncons		:=	{}
	Local aRules		:=	{}
	Local aChave		:=	{}
	Local oModel		:=	Nil

	Private oDados		:=	Nil
	Private lVldModel	:=	.T. //Caso a chamada seja via integração, seto a variável de controle de validação como .T.

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

	//Chave do Registro
	cPeriodo	:= FTafGetVal( cCabec + "/ideEvento/perApur", "C", .F., @aIncons, .F. )
	cIndApur	:= FTafGetVal( cCabec + "/ideEvento/indApuracao", "C", .F., @aIncons, .F. )
	
	If lLaySimplif
		cIndGuia	:= FTafGetVal( cCabec + "/ideEvento/indGuia", "C", .F., @aIncons, .F. )
	EndIf

	Aadd( aChave, { "C", "CUO_INDAPU", cIndApur, .T. } )

	If At("-", cPeriodo) > 0
		Aadd( aChave, {"C", "CUO_PERAPU", StrTran(cPeriodo, "-", "" ),.T.} )
	Else
		Aadd( aChave, {"C", "CUO_PERAPU", cPeriodo , .T.} ) 
	EndIf

	If lLaySimplif
		aAdd( aChave, { "C", "CUO_TPGUIA", cIndGuia, .T. } )
	EndIf

	cChave	:= Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1] ) 
	cChave	+= Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1] ) 

	If lLaySimplif
		cChave	+= Padr( aChave[ 3, 3 ], Tamsx3( aChave[ 3, 2 ])[1] ) 
	EndIf

	//Verifica se o evento ja existe na base
	("CUO")->(DbSetOrder(nIndChv))

	If ("CUO")->(MsSeek(xFilial("CUO") + cChave + "1"))
		If CUO->CUO_STATUS == '4'
			cId  		:= CUO->CUO_ID 
			cChvRegAnt 	:= CUO->CUO_VERSAO
			
			FAltRegAnt('CUO', '2')
		Else
			nOpc := 4
		EndIf
	EndIf	

	Begin Transaction	
		
		//Funcao para validar se a operacao desejada pode ser realizada
		If FTafVldOpe( "CUO", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA303", cCmpsNoUpd, nIndIDVer, .F.)

			If TafColumnPos( "CUO_LOGOPE" )
				cLogOpeAnt := CUO->CUO_LOGOPE
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrego array com os campos De/Para de gravacao das informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRules := TAF303Rul( @cInconMsg , @nSeqErrGrv , @aIncons )					     		    	      	    		    		    		    		    																						        		
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
			//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5 
				
				If !Empty(cId)
					oModel:LoadValue( "MODEL_CUO", "CUO_ID", cId )	
					oModel:LoadValue( "MODEL_CUO", "CUO_VERANT", cChvRegAnt )
				EndIf

				oModel:LoadValue( "MODEL_CUO", "CUO_FILIAL", CUO->CUO_FILIAL )

				If TAFColumnPos( "CUO_XMLID" )
					oModel:LoadValue( "MODEL_CUO", "CUO_XMLID", cXmlID )
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o aRules para gravar as informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nlI := 1 To Len( aRules )                 					
					oModel:LoadValue( "MODEL_CUO", aRules[ nlI , 01 ], FTafGetVal( aRules[ nlI , 02 ], aRules[nlI , 03], aRules[nlI , 04], @aIncons, .F., , aRules[ nlI , 01 ] ) )
				Next

				If Findfunction("TAFAltMan")
					if nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_CUO', 'CUO_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_CUO', 'CUO_LOGOPE' , '', cLogOpeAnt )
					EndIf
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetiva a operacao desejada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cInconMsg)	.And. Empty(aIncons)		
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
	aRules     := Nil

	aSize( aChave, 0 ) 
	aChave     := Nil    

Return { lRet, aIncons } 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF303Rul           

Regras para gravacao das informacoes do registro S-1299 do E-Social

@Return	
aRull  - Regras para a gravacao das informacoes


@author Paulo V.B. Santana
@since 15/01/2014
@version 1.0

/*/                        	
//-------------------------------------------------------------------
Static Function TAF303Rul( cInconMsg , nSeqErrGrv , aIncons )
									
	Local	aRull
	Local	aInfComp  
	Local	cCabec
	Local	cPeriodo
	Local   cCompSMov

	aRull		:=	{}
	aInfComp	:=	{}
	cCabec		:=	"/eSocial/evtFechaEvPer"
	cPeriodo	:=	FTafGetVal( "/eSocial/evtFechaEvPer/ideEvento/perApur" , "C" , .F. , , .F. )
	cCompSMov   := ""
														
	//Regras de Inclusao dos campos da tabela de Fechamento   

	If oDados:XPathHasNode("/eSocial/evtFechaEvPer/ideEvento/indApuracao")                         
		Aadd( aRull, { "CUO_INDAPU",  "/eSocial/evtFechaEvPer/ideEvento/indApuracao", "C", .F. } )  				
	Endif

	If oDados:XPathHasNode("/eSocial/evtFechaEvPer/ideEvento/perApur")
		If At("-", cPeriodo) > 0
			Aadd( aRull, {"CUO_PERAPU", StrTran(cPeriodo, "-", "" ) ,"C",.T.} )	
		Else
			Aadd( aRull, {"CUO_PERAPU", cPeriodo ,"C", .T.} )		
		EndIf
	EndIf

	If lLaySimplif
		If oDados:XPathHasNode("/eSocial/evtFechaEvPer/ideEvento/indGuia")                         
			Aadd( aRull, { "CUO_TPGUIA",  "/eSocial/evtFechaEvPer/ideEvento/indGuia", "C", .F. } )			
		Endif
	EndIf

	//Inclui em aInfComp informações que devem ser utilizadas quando for necessario incluir novo contabilista
	If !lLaySimplif
		Aadd( aInfComp , { 'C2J_NOME' , FTafGetVal( cCabec + "/ideRespInf/nmResp"	, "C", .F., @aIncons, .F.)})
		Aadd( aInfComp , { 'C2J_FONE' , FTafGetVal( cCabec + "/ideRespInf/telefone"	, "C", .F., @aIncons, .F.)})
		Aadd( aInfComp , { 'C2J_EMAIL', FTafGetVal( cCabec + "/ideRespInf/email"	, "C", .F., @aIncons, .F.)})

		if oDados:XPathHasNode(cCabec + "/ideRespInf/cpfResp")	
			Aadd( aRull, { "CUO_IDRESP", FGetIdInt( "cpfResp" , "" , cCabec + "/ideRespInf/cpfResp" , , , aInfComp , @cInconMsg , @nSeqErrGrv ) , "C" , .T. } )
		EndIf
	EndIf

	If oDados:XPathHasNode(cCabec + "/infoFech/evtRemun")	
		Aadd( aRull, { "CUO_REMUN", +;
							xFunTrcSN( TAFExisTag(cCabec + "/infoFech/evtRemun") , 2), "C", .T. } ) 
	EndIf

	If !lLaySimplif .Or. lSimplBeta
		If oDados:XPathHasNode(cCabec + "/infoFech/evtPgtos")
			Aadd(aRull, {"CUO_PAGDIV", xFunTrcSN(TAFExisTag(cCabec + "/infoFech/evtPgtos"), 2), "C", .T.})     	       
		EndIf
	EndIf

	If !lLaySimplif
		If oDados:XPathHasNode(cCabec +"/infoFech/evtAqProd")
			Aadd( aRull, { "CUO_AQPROD", +;    
							xFunTrcSN( TAFExisTag(cCabec +"/infoFech/evtAqProd") , 2), "C", .T. } )
		EndIf
	EndIf

	If oDados:XPathHasNode(cCabec +"/infoFech/evtComProd")
		Aadd( aRull, { "CUO_COMPRD", +;    
							xFunTrcSN( TAFExisTag(cCabec +"/infoFech/evtComProd") , 2), "C", .T. } )
	EndIf

	If oDados:XPathHasNode(cCabec +"/infoFech/evtContratAvNP")
		Aadd( aRull, { "CUO_COAVNP", +;    
							xFunTrcSN( TAFExisTag(cCabec +"/infoFech/evtContratAvNP") , 2), "C", .T. } )
	EndIf

	If oDados:XPathHasNode(cCabec +"/infoFech/evtInfoComplPer")
		Aadd( aRull, { "CUO_COMPER", +;    
							xFunTrcSN( TAFExisTag(cCabec +"/infoFech/evtInfoComplPer") , 2), "C", .T. } )
	EndIf

	If !lLaySimplif
		If oDados:XPathHasNode(cCabec +"/infoFech/compSemMovto")

			cCompSMov := FTafGetVal(cCabec +"/infoFech/compSemMovto", "C", .F., , .F. )

			If At("-", cCompSMov) > 0
				Aadd( aRull, {"CUO_COSMVT", StrTran(cCompSMov, "-", "" ) ,"C",.T.} )	
			Else
				Aadd( aRull, {"CUO_COSMVT",cCompSMov ,"C", .T.} )		
			EndIf
		EndIf
	EndIf

	If TafColumnPos("CUO_EX1250")
		If oDados:XPathHasNode(cCabec +"/infoFech/indExcApur1250")
			Aadd( aRull, { "CUO_EX1250", +;    
							xFunTrcSN( TAFExisTag(cCabec +"/infoFech/indExcApur1250") , 2), "C", .T. } ) 
		EndIf

	EndIf

	If TafColumnPos("CUO_TDCTFW")
		If oDados:XPathHasNode(cCabec +"/infoFech/transDCTFWeb")
			Aadd( aRull, { "CUO_TDCTFW", +;    
							xFunTrcSN( TAFExisTag(cCabec +"/infoFech/transDCTFWeb") , 2), "C", .T. } ) 
		EndIf

	EndIf

	If lLaySimplif .And. TafColumnPos("CUO_NVALID")
		If oDados:XPathHasNode(cCabec + "/infoFech/naoValid")
			Aadd(aRull, {"CUO_NVALID", xFunTrcSN(TAFExisTag(cCabec +"/infoFech/naoValid") , 2), "C", .T.}) 
		EndIf
	EndIf
					
Return aRull 

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf303Prg

Funcao que Mostra o pergunte e chama a geração automatica do registro.

@param
@return 
@author Leandro Prado 
@since 07/05/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf303Prg()

	If Pergunte("TAF303PER",.T.)
		Taf303Ger(ALLTRIM(STR(MV_PAR01)), ALLTRIM(MV_PAR02), .T.)        
	EndIf
	
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Taf303Ger

Funcao que gera automaticamente um registro se baseando nas informações na base de dados.

@param cInd - Indicador do periodo (1 - Folha Mensal; 2 - Décimo Terceiro)
		cPer - Periodo
		lMsg - Mostra Msg caso já tenha fechamento para o periodo informado.
@return lRet - Falso se tiver fechamento para o período informado. True caso contrario.

@author Leandro Prado 
@since 07/05/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf303Ger(cInd, cPer, lMsg, cGuia)

	Local aCampos
	Local i       := 0
	Local cChv    := ""
	Local cChvCmp := ""
	Local lRet    := .T.
	Local lPosic  := .F.
	Local lIdxT1M := Iif(lLaySimplif, TafIndexInDic("T1M", 6), .F.)
	Local lIdxT2A := Iif(lLaySimplif, TafIndexInDic("T2A", 6), .F.)

	Default cInd  := Padr( "" , TamSX3( "CUO_INDAPU" )[1] )
	Default cPer  := Padr( "" , TamSX3( "CUO_PERAPU" )[1] )
	Default cGuia := Padr( "" , TamSX3( "CUO_TPGUIA" )[1] )
	Default lMsg  := .F.

	If (lLaySimplif .And. lIdxT1M .And. lIdxT2A) .Or. !lLaySimplif

		If !lLaySimplif
			aCampos	:= {{"C91", 2, "CUO_REMUN" , "", "2"},;
						{"T3P", 2, "CUO_PAGDIV", "", "2"},;
						{"T3V", 4, "CUO_COMPER", "", "2"},;
						{"CMR", 2, "CUO_AQPROD", "", "2"},;
						{"T1M", 2, "CUO_COMPRD", "", "2"},;
						{"T2A", 2, "CUO_COAVNP", "", "2"}}
		Else
			aCampos := {{"C91", 7, "CUO_REMUN" , "", "2"},;
						{"T3V", 4, "CUO_COMPER", "", "2"},;
						{"T1M", 6, "CUO_COMPRD", "", "2"},;
						{"T2A", 6, "CUO_COAVNP", "", "2"}}
			
			If lSimplBeta
				AAdd(aCampos, {"T3P", 2, "CUO_PAGDIV", "", "2"})
			EndIf
		EndIf

		Iif(!lLaySimplif,("CUO")->(DbSetOrder(2)),("CUO")->(DbSetOrder(6)) )

		lPosic := Iif(!lLaySimplif, !("CUO")->(MsSeek(xFilial("CUO") + cInd + cPer + "1")), !("CUO")->(MsSeek(xFilial("CUO") + cInd + cPer + cGuia + "1")) )

		If lPosic

			For i := 1 to Len(aCampos)

				(aCampos[i, 1])->(DbSetOrder(aCampos[i,2]))

				cChv := Iif(lLaySimplif, xFilial(aCampos[i, 1]) + cInd + cPer + cGuia, xFilial(aCampos[i, 1]) + cInd + cPer)

				If (aCampos[i, 1])->(MsSeek(cChv))

					cChvCmp := Iif(lLaySimplif,;
								xFilial(aCampos[i, 1]) + &(aCampos[i, 1] + '->' + aCampos[i, 1] + "_INDAPU") + &(aCampos[i, 1] + '->' + aCampos[i, 1] + "_PERAPU") + &(aCampos[i, 1] + '->' + aCampos[i, 1] + "_TPGUIA"),;
								xFilial(aCampos[i, 1]) + &(aCampos[i, 1] + '->' + aCampos[i, 1] + "_INDAPU") + &(aCampos[i, 1] + '->' + aCampos[i, 1] + "_PERAPU"))
								
					While !(aCampos[i, 1])->(Eof()) .AND. (cChv == cChvCmp)

						If &(aCampos[i, 1] + '->' + aCampos[i, 1] + "_ATIVO") = '1' .AND. &(aCampos[i, 1] + '->' + aCampos[i, 1] + "_STATUS") $ ' 2349'
							aCampos[i, 5] := "1"
						EndIf

						(aCampos[i, 1])->(dbSkip())
						cChvCmp := Iif(lLaySimplif,;
									xFilial(aCampos[i, 1]) + &(aCampos[i, 1] + '->' + aCampos[i, 1] + "_INDAPU") + &(aCampos[i, 1] + '->' + aCampos[i, 1] + "_PERAPU") + &(aCampos[i, 1] + '->' + aCampos[i, 1] + "_TPGUIA"),;
									xFilial(aCampos[i, 1]) + &(aCampos[i, 1] + '->' + aCampos[i, 1] + "_INDAPU") + &(aCampos[i, 1] + '->' + aCampos[i, 1] + "_PERAPU"))
					EndDo
				EndIf

			Next
			
			Begin Transaction

				If RecLock("CUO",.T.)

					CUO->CUO_FILIAL := xFilial("CUO")
					CUO->CUO_ID     := GetSx8Num("CUO","CUO_ID")
					CUO->CUO_VERSAO := xFunGetVer()
					CUO->CUO_INDAPU := cInd
					CUO->CUO_PERAPU := cPer
					
					If TafColumnPos("CUO_TPGUIA") .AND. lLaySimplif
						CUO->CUO_TPGUIA := cGuia
					EndIf
					
					CUO->CUO_REMUN := aCampos[1, 5]

					If !lLaySimplif
						CUO->CUO_PAGDIV     := aCampos[2, 5]
						CUO->CUO_COMPER     := aCampos[3, 5]
						CUO->CUO_AQPROD     := aCampos[4, 5]
						CUO->CUO_COMPRD     := aCampos[5, 5]
						CUO->CUO_COAVNP     := aCampos[6, 5]
					Else
						CUO->CUO_COMPER := aCampos[2, 5]
						CUO->CUO_COMPRD := aCampos[3, 5]
						CUO->CUO_COAVNP := aCampos[4, 5]

						If lSimplBeta
							CUO->CUO_PAGDIV := aCampos[5, 5]
						EndIf
					EndIf

					CUO->CUO_EVENTO := "I"
					CUO->CUO_ATIVO  := "1"
					CUO->(MsUnlock())
					
				EndIf

			End Transaction

		Else
		
			If lMsg
					Aviso( "Registro Existente", "Já existe registro ativo para esse período. Não será possível criar um registro automatico.", { "Fechar" } )
			EndIf
			lRet := .F.

		EndIf

	Else

		If lMsg
			Aviso( "Ambiente desatualizado", "O dicionário encontra-se desatualizado! Para correção é necessário aplicar o último pacote de expedição.", { "Fechar" } )
		EndIf	
		lRet := .F.
			
	EndIf

Return lRet
