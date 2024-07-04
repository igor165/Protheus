#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA269.CH"
#INCLUDE "TOPCONN.CH"

Static lLaySimplif	:= TafLayESoc("S_01_00_00")
Static oReport      := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA269
Exclusão de Evento Enviado Indevidamente (S-3000)

@author Anderson Costa
@since 12/09/2013
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA269()

	Private oBrw := FWmBrowse():New()

	// Função que indica se o ambiente é válido para o eSocial 2.3
	If TafAtualizado()

		oBrw:SetDescription(STR0001)    //"Exclusão de Evento Enviado Indevidamente"
		oBrw:SetAlias( 'CMJ')
		oBrw:SetMenuDef( 'TAFA269' )

		If FindFunction('TAFSetFilter')
			oBrw:SetFilterDefault(TAFBrwSetFilter("CMJ","TAFA269","S-3000"))
		Else
			oBrw:SetFilterDefault( "CMJ_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
		EndIf

		TafLegend(2,"CMJ",@oBrw)
		oBrw:Activate()

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Anderson Costa
@since 12/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {}

	If FindFunction('TafXmlRet')
		Aadd( aFuncao, { "" , "TafxmlRet('TAF269Xml','3000','CMJ')" , "1" } )
	Else
		Aadd( aFuncao, { "" , "TAF269Xml" , "1" } )
	EndIf

	Aadd( aFuncao, { "" , "xFunHisAlt( 'CMJ', 'TAFA269' ,,,, 'TAF269XML','3000' )" , "3" } )
	Aadd( aFuncao, { "" , "TAFXmlLote( 'CMJ', 'S-3000' , 'evtExclusao' , 'TAF269Xml',, oBrw )" , "5" } )
	Aadd( aFuncao, { "" , "Processa( {||TAF269Ajust(),'Processando', 'Iniciando Rotina de Ajuste' } )"  	, "6" } )
	//Aadd( aFuncao, { "" , "Processa( {||TAF269CPFAjust(),'Processando', 'Iniciando Ajuste de CPF/NIS' } )"  , "7" } )  //Tem que alterar para olhar a T1U/T1V
	Aadd( aFuncao, { "" , "xFunAltRec( 'CMJ' )" , "10" } )

	lMenuDIf := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDIf )

	If lMenuDif
		ADD OPTION aRotina Title "Visualizar"       Action 'VIEWDEF.TAFA269' OPERATION 2 ACCESS 0
	Else
		aRotina	:=	xFunMnuTAF( "TAFA269" , , aFuncao)
	EndIf

Return (aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Anderson Costa
@since 12/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruCMJ	:=	FWFormStruct( 1, 'CMJ' )
	Local oModel    :=	MPFormModel():New( 'TAFA269' ,,,{|oModel| SaveModel(oModel)})

	If lLaySimplif
		oStruCMJ:RemoveField("CMJ_NIS")
	EndIf
	oModel:AddFields('MODEL_CMJ', /*cOwner*/, oStruCMJ)
	oModel:GetModel('MODEL_CMJ'):SetPrimaryKey({'CMJ_FILIAL', 'CMJ_ID', 'CMJ_VERSAO'})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Anderson Costa
@since 12/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   	:=  FWLoadModel( 'TAFA269' )
	Local oStruCMJ 	:=  Nil//FWFormStruct( 2, 'CMJ' )
	Local oView    	:=  FWFormView():New()
	Local cCmpFil	:= ""
	Local cGrpTra1 	:= ""
	Local cGrpTra2	:= ""
	Local cGrpTra3	:= ""
	Local aCmpGrp 	:= {}
	Local nI		:= 0
	Local cEvent	:= Iif(Type("_cEvent") == "U", "", _cEvent)

	oView:SetModel( oModel )

	cGrpTra1 := "CMJ_TPEVEN|CMJ_DTPEVE|CMJ_NRRECI|CMJ_INDAPU|CMJ_PERAPU|CMJ_CPF|"

	cGrpTra2 := "CMJ_PROTUL|"
	If TafColumnPos("CMJ_DTRANS")
		cGrpTra3 := "CMJ_DINSIS|CMJ_DTRANS|CMJ_HTRANS|CMJ_DTRECP|CMJ_HRRECP|"
	EndIf

	cCmpFil := cGrpTra1 + cGrpTra2 + cGrpTra3

	oStruCMJ := FwFormStruct( 2, "CMJ",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

	If lLaySimplif

		If !Empty(cEvent) .AND. !cEvent $ "S-1200|S-1202|S-1207|S-1280|S-1300"

			oStruCMJ:RemoveField("CMJ_INDAPU")

		EndIf

	EndIf

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruCMJ,"CMJ")
	EndIf

	If TafColumnPos("CMJ_DTRANS")
		oStruCMJ:AddGroup( "GRP_TRABALHADOR_01", TafNmFolder("recibo",1), "", 1 ) //Recibo da última Transmissão
		oStruCMJ:AddGroup( "GRP_TRABALHADOR_02", TafNmFolder("recibo",2), "", 1 ) //Informações de Controle eSocial

		oStruCMJ:SetProperty(Strtran(cGrpTra2,"|",""),MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_01")

		aCmpGrp := StrToKArr(cGrpTra3,"|")
		For nI := 1 to Len(aCmpGrp)
			oStruCMJ:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_02")
		Next nI
	EndIf

	oView:AddField( 'VIEW_CMJ', oStruCMJ, 'MODEL_CMJ' )
	oView:EnableTitleView( 'VIEW_CMJ', STR0001 )    //"Exclusão de Evento Enviado Indevidamente"
	oView:CreateHorizontalBox( 'FIELDSCMJ', 100 )
	oView:SetOwnerView( 'VIEW_CMJ', 'FIELDSCMJ' )

	xFunRmFStr(@oStruCMJ, 'CMJ')
	oStruCMJ:RemoveField('CMJ_REGREF') //Não mostra o campo que tem o R_E_C_N_O_ da origem.

	If lLaySimplif
		oStruCMJ:RemoveField('CMJ_NIS')
	EndIf

	If TafColumnPos( "CMJ_LOGOPE" )
		oStruCMJ:RemoveField( "CMJ_LOGOPE" )
	EndIf

Return oView

//-------------------------------------------------------------------	
/*/{Protheus.doc} TAF269Xml
@author Evandro dos Santos Oliveira
@since 23/10/2013
@version 1.0
		
@Param:
lJob   - Informa se foi chamado por Job
nOpc   - Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@return
cXml - Estrutura do Xml do Layout S-3000 
/*/
//-------------------------------------------------------------------
Function TAF269Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cXml    	:= ""
	Local cLayout 	:= "3000"
	Local cReg    	:= "Exclusao"
	Local cPerApu	:= ""
	Local lXmlVLd	:= IIF(FindFunction('TafXmlVLD'),TafXmlVLD('TAF269XML'),.T.)
	Local cTpEvent	:= Posicione("C8E", 1, xFilial("C8E") + CMJ->CMJ_TPEVEN, "C8E_CODIGO")

	Default cAlias 	:= "CMJ"
	Default nRecno	:= 1
	Default nOpc	:= 1
	Default lJob 	:= .F.
	Default cSeqXml := ""

	If lXmlVLd
		If (CMJ->CMJ_INDAPU == '1' .AND. !Empty(CMJ->CMJ_PERAPU)) .OR. lLaySimplif
			If Len(Alltrim(CMJ->CMJ_PERAPU)) > 4
				cPerApu := SubStr(CMJ->CMJ_PERAPU, 1, 4) + '-' + SubStr(CMJ->CMJ_PERAPU, 5, 7)
			Else
				cPerApu := SubStr(CMJ->CMJ_PERAPU, 1, 4)
			EndIf
		ElseIf CMJ->CMJ_INDAPU == '2' .AND. !Empty(CMJ->CMJ_PERAPU)
			cPerApu := SubStr(CMJ->CMJ_PERAPU, 1, 4)
		Else
			cPerApu := CMJ->CMJ_PERAPU
		EndIf

		cXml :=		"<infoExclusao>"
		cXml +=	 		xTafTag("tpEvento", cTpEvent)

		cXml +=			xTafTag("nrRecEvt",CMJ->CMJ_NRRECI)

		If !lLaySimplif
			xTafTagGroup("ideTrabalhador"	,{{"cpfTrab" 	,CMJ->CMJ_CPF,,.F.};
				, {"nisTrab"	,CMJ->CMJ_NIS,,.T.}};
				, @cXml)
		Else
			xTafTagGroup("ideTrabalhador"	,{{"cpfTrab" 	,CMJ->CMJ_CPF,,.F.}};
				, @cXml)
		EndIf

		If !lLaySimplif .OR. (lLaySimplif .AND. cTpEvent $ "S-1200|S-1202|S-1207|S-1280|S-1300")
			xTafTagGroup("ideFolhaPagto"	,{{"indApuracao" 	, CMJ->CMJ_INDAPU,, Iif(lLaySimplif, .T., .F.)};
				, {"perApur"		, Iif(lLaySimplif, AllTrim(cPerApu), cPerApu),, .F.}};
				, @cXml)
		Else
			xTafTagGroup("ideFolhaPagto", {{"perApur", Iif(lLaySimplif, AllTrim(cPerApu), cPerApu),, .F.}}, @cXml)
		EndIf

		cXml +=		"</infoExclusao>"

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Estrutura do cabecalho³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cXml := xTafCabXml(cXml,"CMJ",cLayout,cReg,,cSeqXml)

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Executa gravacao do registro³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If !lJob
			xTafGerXml(cXml,cLayout)
		EndIf
	EndIf

Return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@author Evandro dos Santos oliveira
@since 23/10/2013
@version 1.0

@param   oModel -  Modelo de dados
@return .T.
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

	Local aOrder		:= {}
	Local cChave		:= ""  
	Local cEvento	 	:= "" 
	Local cAlias		:= ""
	Local cNmFun		:= ""
	Local cInd			:= ""
	Local cSelect   	:= ""
	Local cFrom   		:= ""
	Local cWhere   		:= ""
	Local cAliasQry		:= ""
	Local cLogOpeAnt    := ""
	Local cQuery		:= ""

	Local nOperation 	:= oModel:GetOperation()

	Local lReturn   	:= .T.

	Local aTafRotn		:= {}

	Default oModel	:= Nil

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT
			
			TafAjustID( "CMJ", oModel)
			
			oModel:LoadValue( 'MODEL_CMJ', 'CMJ_VERSAO', xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_CMJ', 'CMJ_LOGOPE' , '2', '' )
			Endif

			FwFormCommit( oModel )
			
			cEvento := Posicione("C8E",1,xFilial("C8E") + CMJ->CMJ_TPEVEN,"C8E_CODIGO")
			GerarExclusao(cEvento, CMJ->CMJ_NRRECI, .T.)
			
		ElseIf nOperation == MODEL_OPERATION_UPDATE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CMJ->( DbSetOrder( 3 ) )
			If lGoExtemp .OR. CMJ->( MsSeek( xFilial( 'CMJ' ) + CMJ->CMJ_ID + "1" ) )
				
				If CMJ->CMJ_STATUS $ ( "4" )
					MsgAlert(xValStrEr("000749"))
					lReturn := .F.
				
				ElseIf	CMJ->CMJ_STATUS == ( "2" )
					MsgAlert(xValStrEr("000727"))
					lReturn := .F.
				EndIf
				
				If lReturn
					If TafColumnPos( "CMJ_LOGOPE" )
						cLogOpeAnt := CMJ->CMJ_LOGOPE
					endif

					//Gravo alteração para o Extemporâneo
					If lGoExtemp
						TafGrvExt( oModel, 'MODEL_CMJ', 'CMJ' )			
					EndIf

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_CMJ', 'CMJ_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )
					TAFAltStat( 'CMJ', " " )
				EndIf
			EndIf
			
		ElseIf nOperation == MODEL_OPERATION_DELETE
			
			If CMJ->CMJ_STATUS $ ( "2|4" )
				Aviso( STR0002, STR0006, {STR0007}, 1 )
			Else
				oModel:DeActivate()
				oModel:SetOperation( 5 )
				oModel:Activate()
				FwFormCommit( oModel )
				
				//Restaura o registro que havia sido excluido
				cEvento  := Posicione("C8E",1,xFilial("C8E") + CMJ->CMJ_TPEVEN,"C8E_CODIGO")
				aTafRotn := TAFRotinas( cEvento ,4,.F.,2)
				
				If !Empty(aTafRotn)
					cAlias	 := aTafRotn[3]
					cNmFun	 := aTafRotn[1]
					cInd	 := aTafRotn[13]
				
					If TAFAlsInDic( cAlias )
						DbselectArea(cAlias)
						(cAlias)->( DbSetOrder( cInd ) )
						If (cAlias)->( MsSeek( xFilial( cAlias ) + CMJ->CMJ_NRRECI + '1'  ) )
							If (cAlias)->&(cAlias + "_STATUS") == "6"
								cChave := (cAlias)->&(cAlias + "_ID") + (cAlias)->&(cAlias + "_VERANT")
								oModel := FWLoadModel(cNmFun)
								oModel:SetOperation(5)
								oModel:Activate()
								FwFormCommit( oModel )
								TAFRastro(cAlias,1,cChave, .T., , IIF(Type("oBrw") == "U", Nil, oBrw))
							EndIf
						Else
							//Se a exclusão for pelo savemodel
							cSelect  	:= ""
							cAliasQry	:= GetNextAlias()
							
							If  !(cAlias $ "T0F|T1U|T1V")
								cSelect := cAlias + "_ID ID "
							ElseIf (cAlias $ "T1V")
								cSelect := cAlias + "_ID ID," + cAlias + "_DTALT DTALT," + cAlias + "_DTEF DTEF"
							Else
								cSelect := cAlias + "_ID ID," + cAlias + "_DTALT DTALT"
							EndIf
							cFrom	:= RetSqlName(cAlias)
							cWhere	+= cAlias + "_ATIVO = '1' "
							cWhere	+= " AND " + cAlias + "_STATUS = '6' "
							cWhere	+= " AND " + cAlias + "_PROTPN = '" + CMJ->CMJ_NRRECI + "' "
							cWhere	+= " AND D_E_L_E_T_= '' "
							
							cSelect  := "%" + cSelect  + "%"
							cFrom    := "%" + cFrom    + "%"
							cWhere   := "%" + cWhere   + "%"
							
							BeginSql Alias cAliasQry
								SELECT
									%Exp:cSelect%
								FROM
									%Exp:cFrom%
								WHERE
									%EXP:cWhere%
							EndSql
							
							aOrder := ChangeOrder(cAlias)

							(cAlias)->(DbSetOrder(aOrder[1]))

							If (cAlias $ "T0F|T1U")
								cQuery := xFilial(cAlias) + (cAliasQry)->ID + '1' + (cAliasQry)->DTALT
							ElseIf  (cAlias $ "T1V")
								cQuery := xFilial(cAlias) + (cAliasQry)->ID + '1' + (cAliasQry)->DTALT + (cAliasQry)->DTEF
							ElseIf !(cAlias $ "T0F|T1U|T1V")
								cQuery := xFilial(cAlias) + (cAliasQry)->ID + '1'
							EndIf						

							(cAlias)->(MsSeek(cQuery))

							cChave := (cAlias)->&(cAlias + "_ID") + (cAlias)->&(cAlias + "_VERANT")
							oModel := FWLoadModel(cNmFun)

							oModel:SetOperation(5)
							oModel:Activate()
							FwFormCommit(oModel)
							TAFRastro(cAlias, aOrder[2], cChave, .T.,, Iif(Type("oBrw") == "U", Nil, oBrw))							
							
						EndIf
					EndIf
				EndIf
			
			EndIf
			
		EndIf
		
	End Transaction       
		
Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF269Grv
@author Vitor Siqueira
@since 16/11/2015
@version 1.0
		
@param
cLayout	- Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
				alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
		   		tratamentos de acordo com o layout que esta sendo enviado.
nOpc  		- Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv 		- Filial do ERP para onde as informacoes deverao ser importadas
oXML   		- Objeto com as informacoes a serem manutenidas ( Outras Integracoes )  
cTAFKEY 	- Chave do registro que está sendo excluído.

@Return    
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as 
		  informacoes foram gravadas no banco de dados
aIncons - Array com as inconsistencias encontradas durante a importacao 
/*/
//-------------------------------------------------------------------
Function TAF269Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID, cEvtOri,lMigrador, lDepGPE, cKey, cMatrC9V, lLaySmpTot, lExclCMJ )

	Local cCmpsNoUpd 		:= "|CMJ_FILIAL|CMJ_ID|CMJ_VERSAO|CMJ_VERANT|CMJ_PROTUL|CMJ_PROTPN|CMJ_EVENTO|CMJ_STATUS|CMJ_ATIVO|CMJ_TRABAL|CMJ_DTRABA|"
	Local cCabec     		:= "/eSocial/evtExclusao/infoExclusao"
	Local cLogOpeAnt		:= ""

	//Layouts que podem ser excluídos através desse evento.
	Local cLaysOK			:= "S-1200|S-1202|S-1207|S-1210|S-1250|S-1260|S-1270|S-1280|S-1300|S-2190|S-2200|S-2205|S-2206|S-2210|S-2220|S-2230|S-2240|S-2241|S-2250|S-2298|S-2299|S-2300|S-2306|S-2399|S-2400|S-2405|S-2410|S-2416|S-2418|S-2420|S-2260|S-2221|S-2245|S-2231"
					
	Local cValChv 			:= ""
	Local cValorXml  		:= ""
	Local cChave	   		:= ""
	Local cRecChv	   		:= ""
	Local cIdFunc	   		:= ""
	Local cFldsIndex 		:= ""
	Local cAlias	   		:= ""
	Local cTpOper	   		:= ""
	Local cIdEvento  		:= ""
	Local cVersaoEvt	 	:= ""
	Local cInconMsg  		:= ""
	Local cQry				:= ""
	Local cAliasTafKey	    := ""
	Local cAliasQry		    := GetNextAlias()
	Local cCmpTrab		    := ""
	Local cStatus	   		:= ""
	Local cTAFKEY			:= ""
	Local cCodEvent  		:= ""
	Local cEvento			:= ""
	Local cBanco	 		:= Upper(TcGetDb())

	Local nIndChv    		:= 2
	Local nIndIDVer  		:= 1
	Local nI         		:= 0
	Local nSeqErrGrv		:= 0
	Local nIndExc	  		:= 0
	Local nIndProt		    := 0
	Local nIndApp	   		:= 0
	Local nTamCmp			:= 0
	Local nPosChave			:= 1
	Local nTamCampo			:= 0

	Local lRet       		:= .F.
	Local lTafKey			:= .F.
	Local lRecibo			:= .F.
	Local lPadProtu		    := .T. 

	Local aIncons    		:= {}
	Local aRules     		:= {}
	Local aChave     		:= {}
	Local aFldsIndex 		:= {}
	Local aArea      		:= GetArea()
	Local aTafRotn   		:= {}
	Local cEvtExclu			:= ""
	Local cChaveEvt		 	:= ""
	Local cCPF				:= ""
	Local cCateg			:= ""
	Local cCodCat			:= ""
	Local cTAGVal			:= ""
	Local cCMJstatus		:= ""

	Local oModel     		:= Nil

	Private oDados   		:= oXML
	Private lVldModel		:= .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.

	Default cLayout 		:= ""
	Default nOpc     		:= 1
	Default cFilEv   		:= ""
	Default oXML     		:= Nil
	Default cOwner			:= ""
	Default cFilTran		:=	""
	Default cPredeces		:=	""
	Default nTafRecno		:=	0
	Default cComplem		:=	""
	Default cGrpTran		:=	""
	Default cEmpOriGrp		:=	""
	Default cFilOriGrp		:=	""
	Default cXmlID			:=	""
	Default cEvtOri			:=  ""
	Default lMigrador		:=	.F.
	Default lDepGPE			:=	.F.
	Default cKey			:=	""
	Default cMatrC9V		:=	""
	Default lLaySmpTot		:= .F.
	Default lExclCMJ		:= .F.

	cTpOper		:= TAFIdNfe(oDados:Save2String(),"tpOper") 
	cEvento  	:= FTafGetVal( cCabec + "/tpEvento", "C", .F., @aIncons, .F. )
	aTafRotn 	:= TAFRotinas( cEvento,4,.F.,2)
	cCodEvent  	:= Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")

	cRet:= TAFAlw3000()

	if !(cEvento $ cRet)
		cInconMsg := STR0014
	EndIF

	//A informação enviada em nrRecEvt pode ser o protocolo do registro que deseja excluir ou
	//a chave do registro ( alternativa de integração do TAF com o ERP de origem não tem o protocolo )
	cRecChv := oDados:XPathGetNodeValue( cCabec + "/nrRecEvt")

	If !Empty(AllTrim(cRecChv))
		
		If !Empty(aTafRotn)
			
			cAlias		:= aTafRotn[ 3 ]
			cNmFun		:= aTafRotn[ 1 ]
			nIndProt	:= aTafRotn[ 13 ]
			nIndApp		:= aTafRotn[ 10 ]
			cCmpTrab	:= aTafRotn[ 11 ]
			
			dbSelectArea( cAlias )
			
			//Primeiro tentar encontrar o registro pelo indice e chave de protocolo.
			( cAlias )->( dbSetOrder( nIndProt ) )
			
			If ( cAlias )->( MsSeek( xFilial( cAlias ) +Padr( cRecChv, TamSx3( cAlias + "_PROTUL" )[1] )  + '1' ) )
				
				cIdEvento	:= ( cAlias )->&( cAlias + "_ID" )
				cVersaoEvt 	:= ( cAlias )->&( cAlias + "_VERSAO" )
				cStatus		:= ( cAlias )->&( cAlias + "_STATUS" )
				nIndExc		:= nIndProt
				lRecibo		:= .T.
			
			//Se não encontrou com o protocolo, tenta encontrar pelo indice e chave de negocio ( alternativa de integração do TAF com o ERP de origem não tem o protocolo )
			Else
		
				If oDados:xPathHasNode(cCabec+"/tpEvento")
					cEvtExclu := AllTrim(oDados:XPathGetNodeValue(cCabec+"/tpEvento"))
				EndIf
			
				( cAlias )->( dbSetOrder( nIndApp ) )
			
				cFldsIndex := ( cAlias )->( IndexKey() )
				cFldsIndex := StrTran( cFldsIndex	, "DTOS("		, "" )
				cFldsIndex := StrTran( cFldsIndex	, "STR("		, "" )
				cFldsIndex := StrTran( cFldsIndex	, "DESCEND("	, "" )
				cFldsIndex := StrTran( cFldsIndex	, ")"			, "" )
				aFldsIndex := Str2Arr( cFldsIndex 	, "+" )
					
				For nI:= 1 To Len( aFldsIndex )

					If !(cEvtExclu $ "S-2205|S-2206") .And. (aFldsIndex[ nI ] == ( cAlias + "_IDTRAB" ) .or. aFldsIndex[ nI ] == ( cAlias + "_TRABAL" ) .or. aFldsIndex[ nI ]==( cAlias + "_FUNC" ) .or.;
							aFldsIndex[ nI ]==( cAlias + "_CPF" ))

						If cEvtExclu $ "S-2399"
							cTAGVal		:= oDados:XPathGetNodeValue(cCabec + "/nrRecEvt")
							cCPF 		:= SubStr(cTAGVal, 1, GetSx3Cache("C9V_CPF", "X3_TAMANHO"))
							cCateg 		:= SubStr(cTAGVal, GetSx3Cache("C9V_CPF", "X3_TAMANHO") + 1, Len(cTAGVal))
							cCodCat		:= Posicione("C87", 2, xFilial("C87") + AllTrIM(cCateg), "C87_ID")
							cIdFunc 	:= FGetIdInt("cpfTrab",, cCPF,, .F.,,,, "codCateg", cCodCat,,,,,, @nPosChave)
							cChaveEvt 	+= cIdFunc
						Else
							cIdFunc := FGetIdInt("cpfTrab/Recibo", "matricula/Recibo", cCabec + "/ideTrabalhador/cpfTrab", cCabec + "/nrRecEvt",,,,,,,,,,,, @nPosChave)
							cChaveEvt += cIdFunc
						EndIf

					Else

						If !(aFldsIndex[nI] == (cAlias+"_FILIAL") .Or. aFldsIndex[nI] == (cAlias+"_ATIVO"))

							nTamCampo := GetSx3Cache(aFldsIndex[nI],"X3_TAMANHO")
							
							If aFldsIndex[ nI ] == cAlias + "_NOMEVE"
								cChaveEvt += StrTran( cEvento , "-" , "" )
							Else
								cChaveEvt += Substr(cRecChv,nPosChave,nTamCampo)
							EndIf 

							nPosChave += nTamCampo

						EndIf 

					EndIf
					
					If !aFldsIndex[ nI ] == cAlias + "_PROTUL"
						lPadProtu := .F.
					Else
						lPadProtu := .T.
					EndIf

				Next

				If !Empty(cChaveEvt) .And. ( cAlias )->( msSeek( xFilial( cAlias ) + cChaveEvt + '1' ) ) 
					cIdEvento	:= ( cAlias )->&( cAlias + "_ID" )
					cVersaoEvt := ( cAlias )->&( cAlias + "_VERSAO" )
					cStatus	:= ( cAlias )->&( cAlias + "_STATUS" )
					nIndExc	:= nIndApp
					cRecChv := cChaveEvt
				EndIf
				
				If Empty(cIdEvento) //Caso seja enviado o TAFKEY na tag de recibo(nrRecEvt)
					
					cTAFKEY := FTafGetVal( cCabec + "/nrRecEvt", "C", .F., @aIncons, .F. )
					
					cQry += "SELECT * FROM TAFXERP TAFXERP "
					cQry += "	WHERE TAFALIAS = '" + cAlias + "'"

					If cBanco == "ORACLE"
						cQry += "   AND TAFXERP.TAFKEY IN ( '" + Padr(cTAFKEY, 100) + "' ) "
					Else
						cQry += "   AND TAFXERP.TAFKEY IN ( '" + cTAFKEY + "' ) "
					EndIf

					cQry += "   AND TAFXERP.TAFRECNO <> '0' "
					cQry += "   AND TAFXERP.D_E_L_E_T_ = '' "
					cQry += "   ORDER BY R_E_C_N_O_ DESC"
					
					cQry := ChangeQuery(cQry)
					
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ) , cAliasQry, .F., .T. )

					If !Empty((cAliasQry)->TAFALIAS)
						cAliasTafKey := (cAliasQry)->TAFALIAS
									
						(cAliasTafKey)->(dbGoTo((cAliasQry)->TAFRECNO))
						
						cIdEvento	:= ( cAliasTafKey )->&( cAliasTafKey + "_ID" )
						cVersaoEvt  := ( cAliasTafKey )->&( cAliasTafKey + "_VERSAO" )
						cStatus		:= ( cAliasTafKey )->&( cAliasTafKey + "_STATUS" )
						cRecChv		:= ( cAliasTafKey )->&( cAliasTafKey + "_PROTUL" )
						nIndExc	    := nIndApp
						lTafKey		:= .T.
						
						If Empty(cRecChv) //Se protocolo estiver vazio
							cRecChv := ''
							For nI:= 1 To Len( aFldsIndex )
								If aFldsIndex[nI] <> (cAliasTafKey + "_FILIAL") .AND. aFldsIndex[nI] <> (cAliasTafKey + "_ATIVO")
									cTipoCmp := GetSx3Cache(aFldsIndex[nI],"X3_TIPO")
									If cTipoCmp == "D"
										nTamCmp := TamSx3(aFldsIndex[nI])[1] + 2
										cRecChv += DTOS(( cAliasTafKey) -> &( aFldsIndex[nI] ))
									Else
										cRecChv += Padr( ( cAliasTafKey) -> &( aFldsIndex[nI] ), TamSx3(aFldsIndex[nI])[1] )
									EndIf
								EndIf
							Next nI
						EndIf
					
					EndIf
									
				EndIf
			
			EndIf
		
		EndIf
		
		If !Empty( cIdEvento )

			cValChv := FGetIdInt( "tpEvento" , , cCabec + "/tpEvento" , , , , @cInconMsg , @nSeqErrGrv )

			If Empty( cValChv )
				
				If !Empty( cInconMsg )
					aAdd( aIncons , cInconMsg )
				EndIf
			
			ElseIf ( cEvento $ cLaysOK ) .And. ( nOpc <> 5 )// .And. cStatus == "4"
			
				//Quando o Evento que deseja excluir estiver com status diferente de '2' = Aguardando Retorno, '4' = Transmitido '6' = Pendente Transmissão S-3000 e 
				//'7' = Transmissão S-3000 com sucesso, devo realizar uma exclusão direta
				If !( cStatus $ '4|2|6|7' )
					
					//Utilizo a variável aIncons para fazer o controle de retorno para TAFPrepInt. Apesar de não se tratar de uma inconsistência ou erro
					// essa variável auxilia no processo de exclusão direta de registros no TAF através do Evento S-3000.
					//Através dela consigo identificar essa operação e setar o Status '5' na TAFXERP ( exclusão direta via S-3000 )
					GerarExclusao( cEvento , cRecChv , lPadProtu , @aIncons , nIndExc ,, @lExclCMJ )
				
				//Quando o Evento que deseja excluir estiver com status '2' = Aguardando Retorno
				ElseIf cStatus == '2'
					
					aAdd( aIncons , '000025' ) //'Não é permitido a integração deste evento, enquanto outro estiver pendente de transmissão.'

				Else
					/*----------------------------
					CAMPOS DA CHAVE
					-----------------------------*/
					If !Empty( cValChv )
						Aadd( aChave, { "C", "CMJ_TPEVEN", cValChv, .T. } )
						cChave	+= Padr( cValChv, Tamsx3( aChave[ 1, 2 ])[1] )
						nIndChv := 2
					EndIf
					
					cValChv := FTafGetVal( cCabec + "/nrRecEvt", "C", .F., @aIncons, .F. )

					If !Empty( cRecChv )
						Aadd( aChave, { "C", "CMJ_NRRECI", cRecChv, .T.} )
						cChave += Padr( cRecChv, Tamsx3( aChave[ 2, 2 ])[1] )
						nIndChv := 2
					EndIf
					
					("CMJ")->( DbSetOrder( 2 ) )
					If ("CMJ")->( MsSeek( xFilial("CMJ") + cChave + "1" ) )
						cCMJstatus := CMJ->CMJ_STATUS
						If cCMJstatus $ '4|2'
							aAdd( aIncons , STR0015 ) // "Recibo/Chave que deseja excluir já se escontra excluído ou aguardando retorno do governo"
						Else
							nOpc := 4
						EndIf
					EndIf

					RestArea(aArea)
					
					cAliasEvent := TafSelecEvt("U",cAlias,cIdEvento,cVersaoEvt)
								
					Begin Transaction
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Funcao para validar se a operacao desejada pode ser realizada³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If FTafVldOpe( "CMJ", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA269", cCmpsNoUpd, nIndIDVer, .F.)

							If TafColumnPos( "CMJ_LOGOPE" )
								cLogOpeAnt := CMJ->CMJ_LOGOPE
							endif

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
							//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If nOpc <> 5


								If (cAliasEvent)->(!Eof())

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Carrego array com os campos De/Para de gravacao das informacoes³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									aRules := TAF269Rul(nOpc, cCodEvent, cOwner, cAlias, nIndProt, cRecChv)
									oModel:LoadValue( "MODEL_CMJ", "CMJ_FILIAL", xFilial("CMJ"))

									If TAFColumnPos( "CMJ_XMLID" )
										oModel:LoadValue( "MODEL_CMJ", "CMJ_XMLID", cXmlID )
									EndIf			

								
									While (cAliasEvent)->(!EOF())
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Rodo o aRules para gravar as informacoes³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										For nI := 1 To Len( aRules )
											If aRules[ nI, 01 ] == "CMJ_NRRECI"
												cValorXml := (cAliasEvent)->(RECIBO)
											Else
												cValorXml := FTafGetVal( aRules[ nI, 02 ], aRules[nI, 03], aRules[nI, 04], @aIncons, .F., , aRules[ nI, 01 ] )
											EndIf
											oModel:LoadValue("MODEL_CMJ", aRules[ nI, 01 ], cValorXml)
										Next
										(cAliasEvent)->(dbSkip())
									Enddo

									If Findfunction("TAFAltMan")
										If nOpc == 3
											TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_CMJ', 'CMJ_LOGOPE' , '1', '' )
										ElseIf nOpc == 4
											TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_CMJ', 'CMJ_LOGOPE' , '', cLogOpeAnt )
										EndIf
									EndIf
								Else
									If cAlias == "CM6"
										cInconMsg := "Existe um termino de afastamento pendente de envio. Realize a exclusão do termino para excluir o seu respectivo inicio."								
									EndIf
								EndIf

							EndIf
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Efetiva a operacao desejada³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
							If Empty(cInconMsg) .And. Empty(aIncons)
								If TafFormCommit ( oModel )
									Aadd(aIncons, "ERRO19")
								Else
									lRet  := .T.
								EndIf
							Else
								Aadd (aIncons, cInconMsg)
								DisarmTransaction()
							EndIf
			
						//Não gera registro de exclusão no evento
							If nOpc == 3 .AND.Len(aIncons) == 0
								If lTafKey
									GerarExclusao(cEvento, cRecChv,,,nIndProt)
								Else
									GerarExclusao(cEvento, cRecChv, lRecibo)
								EndIf
							EndIf
							
							oModel:DeActivate()
							If FindFunction('TafClearModel')
								TafClearModel(oModel)
							EndIf
						
						EndIf
					
					End Transaction
					(cAliasEvent)->(DbCloseArea())
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Zerando os arrays e os Objetos utilizados no processamento³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aSize( aRules, 0 )
					aRules     := Nil
					
					aSize( aChave, 0 )
					aChave     := Nil
				EndIf
			EndIf
		Else
			lRet := .F.
			aAdd( aIncons , STR0012 + cEvento) //'Recibo/chave  não encontrado(a) no cadastro do evento '
		EndIf
	Else
		lRet := .F.
		aAdd( aIncons ,STR0011)//'Para eventos S-3000 é obrigatório o envio da tag  nrRecEvt contendo o numero do recibo ou a chave do registro a ser excluido'
	EndIf
			
Return { lRet, aIncons }    

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF269Rul           
Regras para gravacao das informacoes do registro S-3000

@param nOpc - Número da operação

@Return	
aRull  - Regras para a gravacao das informacoes

@author Vitor Siqueira
@since 17/11/2015
@version 1.0

/*/                        	
//-------------------------------------------------------------------
Static Function TAF269Rul( nOpc, cCodEvent, cOwner, cAliasExc, nIndExc, cRecChv )	

	Local aArea     := GetArea()
	Local cCabec	:= "/eSocial/evtExclusao/infoExclusao"
	Local cIndApu	:= ""
	Local cPerApu	:= ""
	Local cApu		:= ""
	Local nRegRef   := 0
	Local aRull		:= {}
	Local aIncons	:= {} 
	Local cChvSeek  := ""


	Default nOpc 		:= 1
	Default cCodEvent	:= ""
	Default cOwner		:= ""
	Default cAliasExc   := ""
	Default nIndExc     := 0
	Default cRecChv     := ""

	If TafXNode( oDados, cCodEvent, cOwner, (cCabec + "/ideFolhaPagto/indApuracao"))
		cIndApu	:= FTafGetVal( cCabec + "/ideFolhaPagto/indApuracao", 'C', .F., @aIncons, .F. )
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner, (cCabec + "/ideFolhaPagto/perApur"))
		cPerApu	:= FTafGetVal( cCabec + "/ideFolhaPagto/perApur", 'C', .F., @aIncons, .F.)
	EndIf

	If cIndApu == '1' .OR. (lLaySimplif .AND. Len(StrTran(cPerApu, "-")) > 4)
		cApu := SubStr(cPerApu, 1, 4) + SubStr(cPerApu, 6, 7)
	ElseIf cIndApu == '2' .OR. (lLaySimplif .AND. Len(StrTran(cPerApu, "-")) <= 4)
		cApu := SubStr(cPerApu, 1, 4) 
	EndIf 

	If nOpc == 3
		If TafXNode( oDados, cCodEvent, cOwner, (cCabec + "/nrRecEvt"))
			aAdd( aRull,{ "CMJ_NRRECI" , cCabec + "/nrRecEvt", "C", .F. } )	// Recibo
		EndIf
		
		If TafXNode( oDados, cCodEvent, cOwner, (cCabec + "/tpEvento"))
			aAdd( aRull,{ "CMJ_TPEVEN" , FGetIdInt( "tpEvento", ,cCabec + "/tpEvento",,,,), "C", .T. } ) 	// Tipo do evento
		EndIf
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner, (cCabec + "/ideTrabalhador/cpfTrab"))
		aAdd( aRull,{ "CMJ_CPF"    , cCabec + "/ideTrabalhador/cpfTrab", "C", .F. } ) 	// CPF do trabalhador
	EndIf

	If !lLaySimplif
		If TafXNode( oDados, cCodEvent, cOwner, (cCabec + "/ideTrabalhador/nisTrab"))
			aAdd( aRull,{ "CMJ_NIS"    , cCabec + "/ideTrabalhador/nisTrab", "C", .F. } ) 	// NIS do trabalhador
		EndIf
	EndIf

	aAdd( aRull,{ "CMJ_INDAPU" , cIndApu, "C", .T. } ) 	// Ind. Per. Apuração 
	aAdd( aRull,{ "CMJ_PERAPU" , cApu   , "C", .T. } ) 	// Per. Apuração

	If !Empty(cAliasExc) .And. nIndExc > 0
		
		DbselectArea(cAliasExc)
		(cAliasExc)->( DbSetOrder( nIndExc ) )
		
		cChvSeek := xFilial( cAliasExc ) + Padr( cRecChv, TamSx3( cAliasExc + "_PROTUL" )[1] )
		
		If cAliasExc <> "CM6"
			cChvSeek += '1'
		EndIf
			
		If (cAliasExc)->( MsSeek( cChvSeek ) )
		
			nRegRef := (cAliasExc)->(Recno())
			
		EndIf
		
	EndIf

	aAdd( aRull,{ "CMJ_REGREF" , nRegRef, "N", .T. } )  // Registro Referência

	RestArea( aArea )
			 
Return ( aRull ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarExclusao()          
Function que gera o registro de exclusão para um determinado evento
 
@param cEvento - Tipo de evento a ser excluido
@param cRecChv - Chave que pode ser o protocolo ou a chave do evento
@param lSaveModel - 
@param aIncons - Array auxiliar de inconsistencias
@param nIndex - Indice para busca do registro
@Return	

@author Vitor Siqueira
@since 03/12/2015
@version 1.0

/*/                        	
//-------------------------------------------------------------------
Function GerarExclusao( cEvento, cRecChv, lSaveModel, aIncons, nIndex, lPadProtu, lExclCMJ )

	Local cVerAnt		:= "" 
	Local cAlias		:= ""
	Local cNmFun		:= ""
	Local cRecChvC91    := ""

	Local nInd			:= 0
	Local aTafRotn 		:= TAFRotinas( cEvento ,4,.F.,2)

	Private nRecno		:= 0

	Default cEvento		:= ""
	Default cRecChv		:= ""	
	Default lSaveModel	:= .F.
	Default aIncons		:= {}
	Default nIndex		:= 0
	Default lPadProtu	:= .T.
	Default lExclCMJ    := .F.

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )
	l2405 := Iif( Type( "l2405" ) == "U", .F., l2405 )

	If !Empty(aTafRotn)
		cAlias	 := aTafRotn[3]
		cNmFun	 := aTafRotn[1]
		
		//tratamento para quando o índice é enviado na chamada da função e não precisa ser pesquisado no TAFRotinas()
		If nIndex > 0
			nInd	 := nIndex
		Else 
			nInd	 := IIf ( lSaveModel , aTafRotn[ 13 ] , aTafRotn[ 10 ] )
		EndIf
		
		DbselectArea(cAlias)
		(cAlias)->( DbSetOrder( nInd ) )
		If lGoExtemp .Or. l2405 .Or. (cAlias)->( MsSeek( xFilial( cAlias ) + Iif(lSaveModel,Padr( cRecChv, TamSx3( cAlias + "_PROTUL" )[1] ),cRecChv) + '1' ) )
			
			nRecno := (cAlias)->(Recno())	
			oModel := FWLoadModel(cNmFun)

			If cAlias == "C91"
				cVerAnt := C91->C91_VERANT
				cRecChvC91 := C91->C91_ID + cVerAnt + "S1200"
			EndIf
			
			If ( cAlias )->&( cAlias + "_STATUS" ) == '4'

				oModel:SetOperation( 4 )
				oModel:Activate()

				If cAlias $ "V75|V76|V77|V78|"
					EvtExclusao( oModel, nRecno, cAlias )
				Else
					&( "StaticCall( " + cNmFun + ", GerarEvtExc , oModel, nRecno ,.T. )" )
				EndIf

			Else
				oModel:SetOperation(5)
				oModel:Activate()
				FwFormCommit(oModel,,,, {|oModel| ValidModel(cEvento, cAlias, oModel)})

				If cAlias == "C91" .And. !Empty(cVerAnt)
					nInd 	:= 1
					cRecChv := cRecChvC91
				EndIf

				lExclCMJ := .T.

				TAFRastro(cAlias, nInd, cRecChv, .T., .F.,  IIf(Type("oBrw") == "U", Nil, oBrw))
			EndIf
			
			oModel:DeActivate()
			If FindFunction('TafClearModel')
				TafClearModel(oModel)
			EndIf
		EndIf

	EndIf				    		
			 
Return (.T.)  

//-------------------------------------------------------------------
/*/{Protheus.doc} xSelecEvent()          
Seleciona os registros a serem excluídos
 
@param cTpOper - Tipo de Operação de Exclusão
				   T = Todo Histórico
				   U = Ultimo Registro
				   
@param cAlias - Alias da Tabela do Evento que deve ser excluído
@param cIdEvento - Id do evento que deve ser excluído

@Return	

@author Paulo Santana
@since 03/12/2015
@version 1.0

/*/                        	
//-------------------------------------------------------------------
Static Function TafSelecEvt( cTpOper, cAlias, cIdEvento,cVersaoEvt)

	Local cSelect  	:= ""
	Local cAliasQry	:= GetNextAlias()

	Default cTpOper	:= "U"
	Default cAlias	:= ""
	Default cIdEvento	:= ""

	cSelect:= cAlias + "_PROTUL RECIBO"
	cFrom	:= RetSqlName(cAlias)
	cWhere	:= cAlias + "_FILIAL = '" +  xFilial(cAlias) + "'"
	cWhere  += " AND " + cAlias + "_ID = '" 		+ cIdEvento  + "'"
	cWhere  += " AND " + cAlias +  "_VERSAO = '" 	+ cVersaoEvt + "'"  

	cWhere  += " AND D_E_L_E_T_='' "
	/*
	If cTpOper == "U"
		cWhere	+= " AND " + cAlias + "_ATIVO = '1'"
	EndIf
	*/
		cSelect  := "%" + cSelect  + "%"
		cFrom    := "%" + cFrom    + "%"
		cWhere   := "%" + cWhere   + "%"

		BeginSql Alias cAliasQry
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%EXP:cWhere%
		EndSql

		Return (cAliasQry)

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFAlw3000
Indica os Eventos permitidos para utilização do Evento S-3000.

@Return		cRet - Eventos permitidos para utilização do Evento S-3000

@Author		Felipe C. Seolin
@Since		07/12/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFAlw3000()

	Local cPeriod		:= ""
	Local cNaoPeriod	:= ""
	Local cRet			:= ""

	If lLaySimplif
		cPeriod		:=	"S-1200|S-1202|S-1207|S-1210|S-1250|S-1260|S-1270|S-1280|"
		cNaoPeriod	:=	"S-2190|S-2200|S-2205|S-2206|S-2210|S-2220|S-2230|S-2240|S-2241|S-2250|S-2260|S-2298|S-2299|S-2300|S-2306|S-2399|S-2231|S-2400|S-2405|S-2410|S-2416|S-2418|S-2420|"
		cRet 		:= cPeriod + cNaoPeriod
	else
		cPeriod		:=	"S-1200|S-1202|S-1207|S-1210|S-1250|S-1260|S-1270|S-1280|S-1300|"
		cNaoPeriod	:=	"S-2190|S-2200|S-2205|S-2206|S-2210|S-2220|S-2230|S-2240|S-2241|S-2250|S-2260|S-2298|S-2299|S-2300|S-2306|S-2399|S-2231|S-2400|S-2405|S-2410|S-2416|S-2418|S-2420|"
		cRet		:=	cPeriod + cNaoPeriod
	EndIf

Return( cRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFEvt3000
Verifica se o Evento pertence aos Eventos permitido pelo S-3000.

@Param		cEvento	-	Evento a ser verificado

@Return		lRet	-	Indica se o Evento é permitido ao S-3000

@Author		Felipe C. Seolin
@Since		07/12/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFEvt3000( cEvento )

	Local cAllowed	:=	TAFAlw3000()
	Local lRet		:=	.F.

	Default cEvento	:=	""

	lRet := Posicione( "C8E", 1, xFilial( "C8E" ) + cEvento, "C8E_CODIGO" ) $ cAllowed

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF269Ajust
Rotina para ajuste de Status dos registros Excluidos.
Issue:
DSERTAF1-3419
* Retirar essa rotina quando expedir o release 12.1.21

@Author		Evandro dos Santos Oliveira
@Since		22/03/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF269Ajust()

	Local aEvtEsocial := {}
	Local nX := 0
	Local cQuery := ""
	Local cTipEvt := ""
	Local cAliasEvt := ""
	Local cAliasQry := ""
	Local cLayout := ""
	Local cMsg := ""
	Local nQtdAjus := 0
	Local cIdCM6        := ""
	Local cAliasCM6     := ""

	aEvtEsocial := TAFRotinas(,,.T.,2)

	ProcRegua(Len(aEvtEsocial))

	BEGIN TRANSACTION

		For nX := 1 To Len(aEvtEsocial)

			cTipEvt   := aEvtEsocial[nX][12]
			cAliasEvt := aEvtEsocial[nX][3]
			cLayout   := aEvtEsocial[nX][4]

			IncProc("Analisando/Ajustando Evento " + cLayout)

			If cTipEvt $ "EM"

				If !Empty(cLayout) .And. cAliasEvt != "CMJ" .And. TafColumnPos(cAliasEvt + "_FILIAL")

					cAliasQry := GetNextAlias()

					cQuery := " SELECT CMJ_NRRECI "
					cQuery += ", " + cAliasEvt + "_PROTPN "
					cQuery += ", " + cAliasEvt + "_FILIAL "
					cQuery += ", " + cAliasEvt + "_ID "
					cQuery += ", " + cAliasEvt + "_VERSAO "
					cQuery += ", " + cAliasEvt + "_STATUS "
					cQuery += ", " + cAliasEvt + "_ATIVO "
					cQuery += ", " + cAliasEvt + ".R_E_C_N_O_ RECNO"

					cQuery += " FROM " + RetSqlName("CMJ") + " CMJ "
					cQuery += " LEFT JOIN " + RetSqlName(cAliasEvt) + " " + cAliasEvt
					cQuery += " ON CMJ_NRRECI = " + cAliasEvt + "_PROTPN AND " + cAliasEvt + "_PROTPN != ' ' "
					cQuery += " WHERE " + cAliasEvt + ".D_E_L_E_T_ = ' ' AND CMJ.D_E_L_E_T_ = ' ' "

					If cAliasEvt $ "C9V|C91"
						cQuery += " AND " + cAliasEvt + "_NOMEVE = '" + StrTran(cLayout,"-","") + "'"
					EndIf

//				cQuery += " AND CMJ.CMJ_FILIAL = '" + xFilial("CMJ") + "' AND " + cAliasEvt + "." + cAliasEvt + "_FILIAL = '" + xFilial(cAliasEvt) + "'"
					cQuery += " AND CMJ.CMJ_STATUS = '4' "

					TcQuery cQuery New Alias (cAliasQry)

					While (cAliasQry)->(!Eof())

						(cAliasEvt)->(dbGoto((cAliasQry)->RECNO))

						If (cAliasEvt)->&(cAliasEvt + "_STATUS") != '7' .OR. (cAliasEvt)->&(cAliasEvt + "_ATIVO") == '1'

							TAFConOut("Correção Status Exclusao- Found " + cAliasEvt + " - RecnO: " + AllTrim(Str((cAliasQry)->RECNO)))

							RecLock(cAliasEvt,.F.)

							(cAliasEvt)->&(cAliasEvt + "_STATUS") := '7'
							(cAliasEvt)->&(cAliasEvt + "_ATIVO")  := '2'

							(cAliasEvt)->(MsUnlock())

							nQtdAjus++

						EndIf

						// Ao excluir o término de um afastamento já transmitido, será necessário buscar o registro de início para reativá-lo, possibilitando assim o envio de um novo término.
						If cAliasEvt == "CM6" .AND. (cAliasEvt)->&(cAliasEvt + "_STATUS") == '7' .AND. (cAliasEvt)->&(cAliasEvt + "_XMLREC") == 'TERM'

							cIdCM6     := CM6->CM6_ID
							cAliasCM6  := GetNextAlias()

							BeginSql Alias cAliasCM6
							SELECT MAX(CM6.R_E_C_N_O_) RECNOCM6
							FROM %table:CM6% CM6
							WHERE CM6.CM6_FILIAL = %xfilial:CM6% 
							AND	CM6.CM6_ID       = %exp:cIdCM6%
							AND CM6.CM6_XMLREC   = 'INIC'
							AND	CM6.%notDel%
							EndSql

							(cAliasCM6)->(DbGoTop())

							If (cAliasCM6)->(!Eof()) .And. (cAliasCM6)->RECNOCM6 > 0
								CM6->( DBGoTo( (cAliasCM6)->RECNOCM6 ) )
								Reclock('CM6', .F.)
								CM6->CM6_ATIVO := '1'
								CM6->(MsUnlock())
							EndIf

							(cAliasCM6)->(DbCloseArea())

						EndIf

						(cAliasQry)->(dbSkip())
					EndDo

					(cAliasQry)->(dbCloseArea())
				EndIf
			EndIf

		Next nX

	END TRANSACTION

	If nQtdAjus > 0
		cMsg := "Realizado ajuste em " + AllTrim(Str(nQtdAjus)) + " Registro(os)."
	Else
		cMsg := "Não foram encontrados registos com Status Incorretos."
	EndIf

	MsgInfo(cMsg)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ChangeOrder
Altera o índice de acordo com o Alias informado

@param cTable - Alias a ser posicionado

@author Melkz Siqueira
@since 16/11/2021
@version 1.0		

@return aOrder - Retornar um array de índices
/*/
//-------------------------------------------------------------------
Static Function ChangeOrder(cTable)

	Local aOrder 	:= {2, 1}

	Default cTable	:= ""
						
	If cTable $ "V75|V76|V77|V78|"
		
		aOrder := {1, 2}

	EndIf

Return aOrder

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
@type			static function
@description	Pós-validação do modelo antes da persistência dos dados
@author			Melkz Siqueira
@since			31/08/2022
@version		1.0
@param			cEvento		- Evento a ser excluído da V3N
@param			cAliasEve	- Array com os dados a serem gravados na V3N
@param			oModel		- Objeto FWFormModel()
@return			.T.			- Retorno da validação do modelo
/*/
//---------------------------------------------------------------------
Static Function ValidModel(cEvento as character, cAliasEve as character, oModel as object)
	
	Default cEvento 	:= ""
	Default cAliasEve	:= ""
	Default oModel 		:= Nil

	If oModel != Nil
		DelInfoRPT(cEvento, cAliasEve, oModel)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} DelInfoRPT
@type			static function
@description	Apaga as informações de relatório na V3N
@author			Melkz Siqueira
@since			16/08/2022
@version		1.0
@param			cEvento		- Evento a ser excluído da V3N
@param			cAliasEve	- Array com os dados a serem gravados na V3N
@param			oModel		- Objeto FWFormModel()
@return			.T.			- Retorno da validação do modelo
/*/
//---------------------------------------------------------------------
Static Function DelInfoRPT(cEvento as character, cAliasEve as character, oModel as object)

	Local cIndApu		as character
	Local cPerApu		as character
	Local cCPF			as character

	Default cEvento 	:= ""
	Default cAliasEve	:= ""
	Default oModel 		:= Nil

	cIndApu	:= ""
	cPerApu	:= ""
	cCPF	:= ""

	If oModel != Nil
		If cEvento $ "S-1200"
			cIndApu	:= oModel:GetValue("MODEL_" + cAliasEve, cAliasEve + "_INDAPU")
			cPerApu	:= oModel:GetValue("MODEL_" + cAliasEve, cAliasEve + "_PERAPU")
			
			If cEvento == "S-1200"
				If oModel:GetValue("MODEL_" + cAliasEve, cAliasEve + "_MV") == "1" .Or. Empty(oModel:GetValue("MODEL_" + cAliasEve, cAliasEve + "_TRABAL"))
					cCPF := oModel:GetValue("MODEL_" + cAliasEve, cAliasEve + "_CPF")
				ElseIf TafColumnPos(cAliasEve + "_ORIEVE") .And. oModel:GetValue("MODEL_" + cAliasEve, cAliasEve + "_ORIEVE") == "S2190"
					cCPF := GetADVFVal("T3A", "T3A_CPF", xFilial("T3A") + oModel:GetValue("MODEL_" + cAliasEve, cAliasEve + "_TRABAL") + "1", 3, "", .T.)
				Else
					cCPF := GetADVFVal("C9V", "C9V_CPF", xFilial("C9V") + oModel:GetValue("MODEL_" + cAliasEve, cAliasEve + "_TRABAL") + "1", 2, "", .T.)
				EndIf
			EndIf

			If oReport == Nil
				oReport := TAFSocialReport():New()
			EndIf

			oInfoRPT := oReport:oVOReport

			oInfoRPT:SetIndApu(AllTrim(cIndApu))
			oInfoRPT:SetPeriodo(AllTrim(cPerApu))
			oInfoRPT:SetCPF(AllTrim(cCPF))

			oReport:UpSert(cEvento, "1", xFilial(cAliasEve), oInfoRPT, .T.)

			oInfoRPT:SetIndApu(AllTrim(cIndApu))
			oInfoRPT:SetPeriodo(AllTrim(cPerApu))
			oInfoRPT:SetCPF(AllTrim(cCPF))

			oReport:UpSert(cEvento, "2", xFilial(cAliasEve), oInfoRPT, .T.)
		EndIf
	EndIf

Return
