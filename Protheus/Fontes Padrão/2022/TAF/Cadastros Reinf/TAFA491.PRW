#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA491.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA491
@type			function
@description	Cadastro do Evento R-2040 da Reinf - Recursos Repassados para Associa��o Desportiva.
@author			Felipe C. Seolin
@since			14/02/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA491()

Private cIndOpe	as char

cIndOpe	:=	"" //Alternativa para corrigir equ�voco de ter criado ViewDef do TAFA062 com vari�vel cIndOpe Private.

If TAFAlsInDic("V1J")
	BrowseDef()
Else
	Aviso( STR0007, TafAmbInvMsg(), { STR0008 }, 3 ) //##"Dicion�rio Incompat�vel" ##"Encerrar"
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@type			function
@description	Fun��o gen�rica MVC com as op��es de menu.
@author			Felipe C. Seolin
@since			14/02/2018
@version		1.0
@return			aRotina - Array com as op��es de menu.
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao	as array
Local aRotina	as array

aFuncao	:=	{}
aRotina	:=	{}

aAdd( aFuncao, { "", "TAF491Xml", "1" } )
aAdd( aFuncao, { "", "xFunNewHis( 'T9K', 'TAFA491' )", "3" } )
aAdd( aFuncao, { "", "TAFXmlLote( 'T9K', 'R-2040', 'AssocDespRep', 'TAF491Xml', 5, oBrowse)", "5" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TAFA491" OPERATION 2 ACCESS 0 //"Visualizar"
Else
	aRotina := TAFMenuReinf( "TAFA491", aFuncao )
	//aRotina	:=	xFunMnuTAF( "TAFA491" , , aFuncao)
EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
@type			function
@description	Fun��o gen�rica MVC do Model.
@author			Felipe C. Seolin
@since			14/02/2018
@version		1.0
@return			oModel - Objeto do modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

Local oStruT9K	as object
Local oStruV1J	as object
Local oStruV1K	as object
Local oStruV1L	as object
Local oModel	as object

oStruT9K	:=	FWFormStruct( 1, "T9K" )
oStruV1J	:=	FWFormStruct( 1, "V1J" )
oStruV1K	:=	FWFormStruct( 1, "V1K" )
oStruV1L	:=	FWFormStruct( 1, "V1L" )
oModel		:=	MPFormModel():New( "TAFA491", , , {|oModel| SaveModel( oModel ) })

oModel:AddFields( "MODEL_T9K", /*cOwner*/, oStruT9K )

oModel:AddGrid( "MODEL_V1J", "MODEL_T9K", oStruV1J )
oModel:GetModel( "MODEL_V1J" ):SetUniqueLine( { "V1J_CNPJAD" } )

oModel:AddGrid( "MODEL_V1K", "MODEL_V1J", oStruV1K )
oModel:GetModel( "MODEL_V1K" ):SetUniqueLine( { "V1K_TPREPA" } )

oModel:AddGrid( "MODEL_V1L", "MODEL_V1J", oStruV1L )
oModel:GetModel( "MODEL_V1L" ):SetUniqueLine( { "V1L_TPPROC", "V1L_NRPROC", "V1L_CODSUS"} )
oModel:GetModel( "MODEL_V1L" ):SetOptional( .T. )
oModel:GetModel('MODEL_V1L'):SetMaxLine(50) 

oModel:SetRelation( "MODEL_V1J", { { "V1J_FILIAL", "xFilial( 'V1J' )" }, { "V1J_ID", "T9K_ID" }, { "V1J_VERSAO", "T9K_VERSAO" } }, V1J->( IndexKey( 1 ) ) )
oModel:SetRelation( "MODEL_V1K", { { "V1K_FILIAL", "xFilial( 'V1K' )" }, { "V1K_ID", "T9K_ID" }, { "V1K_VERSAO", "T9K_VERSAO" }, { "V1K_CNPJAD", "V1J_CNPJAD" } }, V1K->( IndexKey( 1 ) ) )
oModel:SetRelation( "MODEL_V1L", { { "V1L_FILIAL", "xFilial( 'V1L' )" }, { "V1L_ID", "T9K_ID" }, { "V1L_VERSAO", "T9K_VERSAO" }, { "V1L_CNPJAD", "V1J_CNPJAD" } }, V1L->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_T9K" ):SetPrimaryKey( { "T9K_PERAPU", "T9K_TPINSC", "T9K_NRINSC" } )

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Fun��o gen�rica MVC da View.
@author			Felipe C. Seolin
@since			14/02/2018
@version		1.0
@return			oModel - Objeto do modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oModel	as object
Local oStruT9K	as object
Local oStruT9Ka	as object
Local oStruT9Kb	as object
Local oStruV1J	as object
Local oStruV1K	as object
Local oStruV1L	as object
Local oView		as object
Local aCmpGrp   as array
Local cCmpFil	as char
Local cGrpCom1	as char
Local cGrpCom2	as char
Local cGrpCom3	as char
Local nI		as numeric

oModel		:=	FWLoadModel( "TAFA491" )
oStruT9Ka	:=	Nil
oStruT9Kb	:=	Nil
oStruV1J	:=	FWFormStruct( 2, "V1J" )
oStruV1K	:=	FWFormStruct( 2, "V1K" )
oStruV1L	:=	FWFormStruct( 2, "V1L" )
oView		:=	FWFormView():New()
aCmpGrp		:= {}
cCmpFil		:= ""
cGrpCom1	:= ""
cGrpCom2	:= ""
cGrpCom3	:= ""
nI			:= 1

oView:SetModel(oModel)
oView:SetContinuousForm(.T.)


//Identifica��o do Estabelecimento
cGrpCom1  := 'T9K_VERSAO|T9K_VERANT|T9K_PROTPN|T9K_EVENTO|T9K_ATIVO|T9K_PERAPU|'
cGrpCom2  := 'T9K_TPINSC|T9K_NRINSC|'
cCmpFil   := cGrpCom1 + cGrpCom2
oStruT9Ka := FwFormStruct( 2, 'T9K', {|x| AllTrim( x ) + "|" $ cCmpFil } )

//"Protocolo de Transmiss�o"
cGrpCom3 := 'T9K_PROTUL|'
cCmpFil   := cGrpCom3
oStruT9Kb := FwFormStruct( 2, 'T9K', {|x| AllTrim( x ) + "|" $ cCmpFil } )

//*******************************************************************************************
//Grupo de campos 	
//*******************************************************************************************

oStruT9Ka:AddGroup( "GRP_ESTAB_01", STR0009, "", 1 ) //"Informa��es de Identifica��o do Evento" 

aCmpGrp := StrToKArr(cGrpCom1,"|")
For nI := 1 to Len(aCmpGrp)
	oStruT9Ka:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_ESTAB_01")
Next nI

oStruT9Ka:AddGroup( "GRP_ESTAB_02", STR0010, "", 1 ) //"Identifica��o do Estabelecimento" 

aCmpGrp := StrToKArr(cGrpCom2,"|")
For nI := 1 to Len(aCmpGrp)
	oStruT9Ka:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_ESTAB_02")
Next nI


//*******************************************************************************************
//Estrutura da View
//*******************************************************************************************

oView:AddField( "VIEW_T9Ka", oStruT9Ka, "MODEL_T9K" )
oView:EnableTitleView( "VIEW_T9Ka", STR0001 ) //"Recursos Repassados para Associa��o Desportiva"

oView:AddField( "VIEW_T9Kb", oStruT9Kb, "MODEL_T9K" )
oView:EnableTitleView( "VIEW_T9Kb", STR0005 ) //"Recibo de Transmiss�o"

oView:AddGrid( "VIEW_V1J", oStruV1J, "MODEL_V1J" )
oView:EnableTitleView( "VIEW_V1J", STR0004 ) //"Totalizador Recursos Repassados"

oView:AddGrid( "VIEW_V1K", oStruV1K, "MODEL_V1K" )
oView:EnableTitleView( "VIEW_V1K", STR0002 ) //"Detalhamento Recursos Repassados"

oView:AddGrid( "VIEW_V1L", oStruV1L, "MODEL_V1L" )
oView:EnableTitleView( "VIEW_V1L", STR0003 ) //"Informa��es de Processos"

//*******************************************************************************************
//Estrutura do Folder
//*******************************************************************************************

oView:CreateHorizontalBox( "PAINEL_PRINCIPAL", 100 )
oView:CreateFolder( "FOLDER_PRINCIPAL", "PAINEL_PRINCIPAL" )

//Aba de Recursos Repassados para Associa��o Desportiva
oView:AddSheet( "FOLDER_PRINCIPAL", "ABA01", STR0001 ) //"Recursos Repassados para Associa��o Desportiva"

//Box de Recursos Repassados para Associa��o Desportiva
oView:CreateHorizontalBox( "FIELDST9Ka", 20,,, "FOLDER_PRINCIPAL", "ABA01" )

//Box de Totalizador Recursos Repassados
oView:CreateHorizontalBox( "GRIDV1J", 35,,, "FOLDER_PRINCIPAL", "ABA01" )

//Box para as Abas de Detalhamento Recursos Repassados e Informa��es de Processos
oView:CreateHorizontalBox( "PANFOLDER1", 45,,, "FOLDER_PRINCIPAL", "ABA01" )
oView:CreateFolder( "FOLDER1", "PANFOLDER1" )

//Aba de Detalhamento Recursos Recebidos
oView:AddSheet( "FOLDER1", "ABA01", STR0002 ) //"Detalhamento Recursos Recebidos"
oView:CreateHorizontalBox( "GRIDV1K", 50,,, "FOLDER1", "ABA01" )

//Aba de Informa��es de Processos
oView:AddSheet( "FOLDER1", "ABA02", STR0003 ) //"Informa��es de Processos"
oView:CreateHorizontalBox( "GRIDV1L", 100,,, "FOLDER1", "ABA02" )

//Aba de Recibo de Transmiss�o
oView:AddSheet( "FOLDER_PRINCIPAL", "ABA02", STR0005 ) //"Recibo de Transmiss�o"
oView:CreateHorizontalBox( "FIELDST9Kb", 100,,, "FOLDER_PRINCIPAL", "ABA02" )

//*******************************************************************************************
//Amarra��o para exibi��o das informa��es
//*******************************************************************************************
oView:SetOwnerView( "VIEW_T9Ka", "FIELDST9Ka" )
oView:SetOwnerView( "VIEW_T9Kb", "FIELDST9Kb" )
oView:SetOwnerView( "VIEW_V1J", "GRIDV1J" )
oView:SetOwnerView( "VIEW_V1K", "GRIDV1K" )
oView:SetOwnerView( "VIEW_V1L", "GRIDV1L" )

//*******************************************************************************************
//Remo��o de campos de controle interno
//*******************************************************************************************
lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif
	xFunRmFStr( @oStruT9Ka, "T9K" )
EndIf

oStruV1L:RemoveField( "V1L_IDSUSP" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao para valida��o de grava��o do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Roberto Souza
@Since 02/04/2018
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local nOperation 	as numeric
	Local lRetorno		as logical

	nOperation 			:= oModel:GetOperation()
	lRetorno			:= .T.

	FWFormCommit( oModel )	

Return( lRetorno )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF491Xml
@type			function
@description	Fun��o de gera��o do XML para atender o evento R-2040. Quando a rotina for chamada, o registro deve estar posicionado.
@author			Felipe C. Seolin
@since			14/02/2018
@version		1.0
@param			cAlias	-	Alias corrente
@param			nRecno	-	Recno corrente
@param			nOpc	-	Op��o selecionada
@param			lJob	-	Indicao execu��o por Job
@return			cXml	-	Estrutura do XML do Layout R-2040
/*/
//---------------------------------------------------------------------
Function TAF491Xml( cAlias, nRecno, nOpc, lJob )

Local cXml		as char
Local cLayout	as char
Local cReg		as char
Local cNameXSD  as char

Default lJob	:=	.F.

cXml		:=	""
cLayout		:=	"2040"
cReg		:=	"AssocDespRep"
cNameXSD	:=  "RecursoRepassadoAssociacao"

DBSelectArea( "V1J" )
V1J->( DBSetOrder( 1 ) ) 

DBSelectArea( "V1K" )
V1K->( DBSetOrder( 1 ) ) 

DBSelectArea( "V1L" )
V1L->( DBSetOrder( 1 ) ) 


//Revisar a forma de pesquisa do Estabelecimento
cXml += "<ideEstab>"
cXml += 	xTafTag( "tpInscEstab", T9K->T9K_TPINSC )
cXml += 	xTafTag( "nrInscEstab", T9K->T9K_NRINSC )

If V1J->( MsSeek( xFilial( "V1J" ) + T9K->( T9K_ID + T9K_VERSAO ) ) )
	While V1J->( !Eof() ) .and. V1J->( V1J_FILIAL + V1J_ID + V1J_VERSAO ) == T9K->( T9K_FILIAL + T9K_ID + T9K_VERSAO )

		cXml += "<recursosRep>"
		cXml += 	xTafTag( "cnpjAssocDesp", V1J->V1J_CNPJAD  )
		cXml += 	xTafTag( "vlrTotalRep"	, TafFReinfNum(V1J->V1J_VLREPA)  )
		cXml += 	xTafTag( "vlrTotalRet"	, TafFReinfNum(V1J->V1J_VLRET)   )
		cXml += 	xTafTag( "vlrTotalNRet"	, TafFReinfNum(V1J->V1J_VLNRET) , .T. )

		If V1K->( MsSeek( xFilial( "V1K" ) + V1J->( V1J_ID + V1J_VERSAO + V1J_CNPJAD ) ) )
			While V1K->( !Eof() ) .and. V1K->( V1K_FILIAL + V1K_ID + V1K_VERSAO + V1K_CNPJAD ) ==  V1J->( V1J_FILIAL + V1J_ID + V1J_VERSAO + V1J_CNPJAD )
				cXml += "<infoRecurso>"
				cXml += 	xTafTag( "tpRepasse"  , V1K->V1K_TPREPA )
				cXml += 	xTafTag( "descRecurso", V1K->V1K_DESCRE )
				cXml += 	xTafTag( "vlrBruto"   , TafFReinfNum(V1K->V1K_VLBRUT) )
				cXml += 	xTafTag( "vlrRetApur" , TafFReinfNum(V1K->V1K_VLRECP) )
				cXml += "</infoRecurso>"

				V1K->( DBSkip() )
			EndDo
		EndIf
		
		If V1L->( MsSeek( xFilial( "V1L" ) + V1J->( V1J_ID + V1J_VERSAO + V1J_CNPJAD ) ) )
			While V1L->( !Eof() ) .and. V1L->( V1L_FILIAL + V1L_ID + V1L_VERSAO + V1L_CNPJAD ) ==  V1J->( V1J_FILIAL + V1J_ID + V1J_VERSAO + V1J_CNPJAD )
				//If V1J->V1J_VLNRET > 0 .Or. V1L->V1L_CODSUS $ "92"
					xTafTagGroup("infoProc"      ,{ { "tpProc" , V1L->V1L_TPPROC				    ,,.F. }; 
										 		 ,  { "nrProc" , V1L->V1L_NRPROC				    ,,.F. };
										 		 ,	{ "codSusp", V1L->V1L_CODSUS 					,,.T. };
				   	  		 			 		 ,  { "vlrNRet", TafFReinfNum(V1L->V1L_VLNRET)  	,,.F. }};	
				   	  		 			 		 ,  @cXml)

				//EndIf

				V1L->( DBSkip() )
			EndDo
		EndIf	
		
		cXml += "</recursosRep>"

		V1J->( DBSkip() )
	EndDo
EndIf

cXml += "</ideEstab>"

V1J->( DBCloseArea() )
V1K->( DBCloseArea() )
V1L->( DBCloseArea() )
T9U->( DBCloseArea() )

cXml := TAFXmlReinf( cXml, "T9K", cLayout, cReg, SubStr( T9K->T9K_PERAPU, 3, 4 ) + "-" + SubStr( T9K->T9K_PERAPU, 1, 2 ),, cNameXSD)

If !lJob
	xTafGerXml( cXml, cLayout,,,,,, "R-" )
EndIf

Return( cXml )

//---------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
@type			function
@description	Fun��o com o objetivo de gerar o Evento de Exclus�o.
@author			Felipe C. Seolin
@since			17/02/2018
@version		1.0
@param			oModel	-	Modelo de dados
@param			nRecno	-	N�mero do registro
@param			lRotExc	-	Vari�vel que controla se a function � chamada pelo TafIntegraESocial
/*/
//---------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

Local oModelT9K		as object
Local oModelV1J		as object
Local oModelV1K		as object
Local oModelV1L		as object
Local cVerAnt		as char
Local cRecibo		as char
Local cVersao		as char
Local nI			as numeric
Local nV1J			as numeric
Local nV1K			as numeric
Local nV1KAdd		as numeric
Local nV1L			as numeric
Local nV1LAdd		as numeric
Local aGravaT9K		as array
Local aGravaV1J		as array
Local aGravaV1K		as array
Local aGravaV1L		as array

oModelT9K	:=	Nil
oModelV1J	:=	Nil
oModelV1K	:=	Nil
oModelV1L	:=	Nil
cVerAnt		:=	""
cRecibo		:=	""
cVersao		:=	""
nI			:=	0
nV1J		:=	0
nV1K		:=	0
nV1KAdd		:=	0
nV1L		:=	0
nV1LAdd		:=	0
aGravaT9K	:=	{}
aGravaV1J	:=	{}
aGravaV1K	:=	{}
aGravaV1L	:=	{}

Begin Transaction

	DBSelectArea( "T9K" )
	T9K->( DBGoTo( nRecno ) )

	oModelT9K := oModel:GetModel( "MODEL_T9K" )
	oModelV1J := oModel:GetModel( "MODEL_V1J" )
	oModelV1K := oModel:GetModel( "MODEL_V1K" )
	oModelV1L := oModel:GetModel( "MODEL_V1L" )

	//************************************
	//Informa��es para grava��o do rastro
	//************************************
	cVerAnt := oModelT9K:GetValue( "T9K_VERSAO" )
	cRecibo := oModelT9K:GetValue( "T9K_PROTUL" )

	//****************************************************************************************************************
	//Armazeno as informa��es que foram modificadas na tela, para utiliza��o em opera��o de inclus�o de novo registro
	//****************************************************************************************************************
	For nI := 1 to Len( oModelT9K:aDataModel[1] )
		aAdd( aGravaT9K, { oModelT9K:aDataModel[1,nI,1], oModelT9K:aDataModel[1,nI,2] } )
	Next nI

	//V1J
	If V1J->( MsSeek( xFilial( "V1J" ) + C9B->( C9B_ID + C9B_VERSAO ) ) )

		For nV1J := 1 to oModel:GetModel( "MODEL_V1J" ):Length()
			oModel:GetModel( "MODEL_V1J" ):GoLine( nV1J )

			If !oModel:GetModel( "MODEL_V1J" ):IsEmpty() .and. !oModel:GetModel( "MODEL_V1J" ):IsDeleted()
				aAdd( aGravaV1J, {	oModelV1J:GetValue( "V1J_CNPJAD" ),;
									oModelV1J:GetValue( "V1J_VLREPA" ),;
									oModelV1J:GetValue( "V1J_VLRET"  ),;
									oModelV1J:GetValue( "V1J_VLNRET" ) } )

				//V1K
				For nV1K := 1 to oModel:GetModel( "MODEL_V1K" ):Length()
					oModel:GetModel( "MODEL_V1K" ):GoLine( nV1K )
					If !oModel:GetModel( "MODEL_V1K" ):IsEmpty() .and. !oModel:GetModel( "MODEL_V1K" ):IsDeleted()
						aAdd( aGravaV1K, {	oModelV1J:GetValue( "V1J_CNPJAD" ),;
											oModelV1K:GetValue( "V1K_TPREPA" ),;
											oModelV1K:GetValue( "V1K_DESCRE" ),;
											oModelV1K:GetValue( "V1K_VLBRUT" ),;
											oModelV1K:GetValue( "V1K_VLRECP" ) } )
					EndIf
				Next nV1K

				//V1L
				For nV1L := 1 to oModel:GetModel( "MODEL_V1L" ):Length()
					oModel:GetModel( "MODEL_V1L" ):GoLine( nV1L )
					If !oModel:GetModel( "MODEL_V1L" ):IsEmpty() .and. !oModel:GetModel( "MODEL_V1L" ):IsDeleted()
						aAdd( aGravaV1L, {	oModelV1J:GetValue( "V1J_CNPJAD" ),;											
											oModelV1L:GetValue( "V1L_IDPROC" ),;
											oModelV1L:GetValue( "V1L_TPPROC" ),;
											oModelV1L:GetValue( "V1L_NRPROC" ),;
											oModelV1L:GetValue( "V1L_CODSUS" ),;
											oModelV1L:GetValue( "V1L_IDSUSP" ),;
											oModelV1L:GetValue( "V1L_VLNRET" ) } )
					EndIf
				Next nV1L

			EndIf

		Next nV1J

	EndIf

	//*****************************
	//Seto o registro como Inativo
	//*****************************
	FAltRegAnt( "T9K", "2" )

	//**************************************
	//Opera��o de Inclus�o de novo registro
	//**************************************
	oModel:DeActivate()
	oModel:SetOperation( 3 )
	oModel:Activate()

	//********************************************************************************
	//Inclus�o do novo registro j� considerando as informa��es alteradas pelo usu�rio
	//********************************************************************************
	For nI := 1 to Len( aGravaT9K )
		oModel:LoadValue( "MODEL_T9K", aGravaT9K[nI,1], aGravaT9K[nI,2] )
	Next nI

	//V1J
	For nV1J := 1 to Len( aGravaV1J )

		oModel:GetModel( "MODEL_V1J" ):LVALID := .T.

		If nV1J > 1
			oModel:GetModel( "MODEL_V1J" ):AddLine()
		EndIf

		oModel:LoadValue( "MODEL_V1J", "V1J_CNPJAD", aGravaV1J[nV1J][1] )
		oModel:LoadValue( "MODEL_V1J", "V1J_VLREPA", aGravaV1J[nV1J][2] )
		oModel:LoadValue( "MODEL_V1J", "V1J_VLRET" , aGravaV1J[nV1J][3] )
		oModel:LoadValue( "MODEL_V1J", "V1J_VLNRET", aGravaV1J[nV1J][4] )

		//V1K
		nV1KAdd := 1
		For nV1K := 1 to Len( aGravaV1K )
			If aGravaV1K[nV1K][1] == aGravaV1J[nV1J][1]

				oModel:GetModel( "MODEL_V1K" ):LVALID := .T.

				If nV1KAdd > 1
					oModel:GetModel( "MODEL_V1K" ):AddLine()
				EndIf

				oModel:LoadValue( "MODEL_V1K", "V1K_TPREPA", aGravaV1K[nV1K][2] )
				oModel:LoadValue( "MODEL_V1K", "V1K_DESCRE", aGravaV1K[nV1K][3] )
				oModel:LoadValue( "MODEL_V1K", "V1K_VLBRUT", aGravaV1K[nV1K][4] )
				oModel:LoadValue( "MODEL_V1K", "V1K_VLRECP", aGravaV1K[nV1K][5] )	

				nV1KAdd ++
			EndIf
		Next nV1K
		
		//V1L
		nV1LAdd := 1
		For nV1L := 1 to Len( aGravaV1L )
			If aGravaV1L[nV1L][1] == aGravaV1J[nV1J][1] 

				oModel:GetModel( "MODEL_V1L" ):LVALID := .T.

				If nV1LAdd > 1
					oModel:GetModel( "MODEL_V1L" ):AddLine()
				EndIf


				oModel:LoadValue( "MODEL_V1L", "V1L_IDPROC", aGravaV1L[nV1L][2] )
				oModel:LoadValue( "MODEL_V1L", "V1L_TPPROC", aGravaV1L[nV1L][3] )
				oModel:LoadValue( "MODEL_V1L", "V1L_NRPROC", aGravaV1L[nV1L][4] )
				oModel:LoadValue( "MODEL_V1L", "V1L_CODSUS", aGravaV1L[nV1L][5] )
				oModel:LoadValue( "MODEL_V1L", "V1L_IDSUSP", aGravaV1L[nV1L][6] )
				oModel:LoadValue( "MODEL_V1L", "V1L_VLNRET", aGravaV1L[nV1L][7] )

				nV1LAdd ++
			EndIf
		Next nV1L
		
		
		
		

	Next nV1J

	//*****************************************
	//Vers�o que ser� gravada no novo registro
	//*****************************************
	cVersao := xFunGetVer()

	//********************************************************************
	//ATEN��O
	//A altera��o destes campos devem sempre estar abaixo do loop do For,
	//pois devem substituir as informa��es que foram armazenadas acima
	//********************************************************************
	oModel:LoadValue( "MODEL_T9K", "T9K_VERSAO", cVersao )
	oModel:LoadValue( "MODEL_T9K", "T9K_VERANT", cVerAnt )
	oModel:LoadValue( "MODEL_T9K", "T9K_PROTPN", cRecibo )
	oModel:LoadValue( "MODEL_T9K", "T9K_PROTUL", "" )

	oModel:LoadValue( "MODEL_T9K", "T9K_EVENTO", "E" )
	oModel:LoadValue( "MODEL_T9K", "T9K_ATIVO", "1" )

	FWFormCommit( oModel )
	TAFAltStat( "T9K", "6" ) 

End Transaction

Return( .T. )



//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Roberto Souza
@since 23/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()

	Private oBrowse	as object

	oBrowse	:=	FWMBrowse():New()

	If FunName() == "TAFXREINF"
		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .T., lMenuDif ) 
	EndIf

	oBrowse:SetDescription( STR0001 ) //"Recursos Repassados para Associa��o Desportiva"
	oBrowse:SetAlias( "T9K" )
	oBrowse:SetMenuDef( "TAFA491" )
	oBrowse:SetFilterDefault( "T9K_ATIVO == '1'" )
	
	//DbSelectArea("T9K")
	//Set Filter TO &("T9K_ATIVO == '1'")

	If FindFunction("TAFLegReinf")
		TAFLegReinf( "T9K", oBrowse)
	Else
		TAFLegend( 2, "T9K", @oBrowse )
	EndIf
	
	oBrowse:Activate()

Return( oBrowse )
