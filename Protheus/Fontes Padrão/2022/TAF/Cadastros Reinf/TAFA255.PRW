#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA255.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA255
@type			function
@description	Cadastro do Evento R-2030 da Reinf - Recursos Recebidos por Associa��o Desportiva.
@author			Felipe C. Seolin
@since			28/08/2013
@version		1.0
@history		23/01/2018, Felipe C. Seolin, Adequa��o do evento para R-2030.
/*/
//---------------------------------------------------------------------
Function TAFA255() 

Private cIndOpe	as char

cIndOpe	:=	"" //Alternativa para corrigir equ�voco de ter criado ViewDef do TAFA062 com vari�vel cIndOpe Private.

If TAFColumnPos( "V1G_VLNRET" ) .and. AllTrim( GetSx3Cache( "C9B_ID", "X3_RELACAO" ) ) == 'TAFGeraID( "TAF" )'
	BrowseDef()
Else
	Aviso( STR0015, TafAmbInvMsg(), { STR0016 }, 3 ) //##"Dicion�rio Incompat�vel" ##"Encerrar"
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@type			function
@description	Fun��o gen�rica MVC com as op��es de menu.
@author			Felipe C. Seolin
@since			28/08/2013
@version		1.0
@return			aRotina - Array com as op��es de menu.
@history		23/01/2018, Felipe C. Seolin, Adequa��o do evento para R-2030.
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao	as array
Local aRotina	as array

aFuncao	:=	{}
aRotina	:=	{}

aAdd( aFuncao, { "", "TAF255Xml", "1" } )
aAdd( aFuncao, { "", "xFunNewHis( 'C9B', 'TAFA255' )", "3" } )
aAdd( aFuncao, { "", "TAFXmlLote( 'C9B', 'R-2030', 'AssocDespRec', 'TAF255Xml', 5, oBrowse)", "5" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina TITLE STR0010 ACTION "VIEWDEF.TAFA255" OPERATION 2 ACCESS 0 //"Visualizar"
Else
	aRotina := TAFMenuReinf( "TAFA255", aFuncao )
	//aRotina	:=	xFunMnuTAF( "TAFA255" , , aFuncao)
EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
@type			function
@description	Fun��o gen�rica MVC do Model.
@author			Felipe C. Seolin
@since			28/08/2013
@version		1.0
@return			oModel - Objeto do modelo MVC
@history		23/01/2018, Felipe C. Seolin, Adequa��o do evento para R-2030.
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

Local oStruC9B	as object
Local oStruV1G	as object
Local oStruV1H	as object
Local oStruV1I	as object
Local oModel	as object

oStruC9B	:=	FWFormStruct( 1, "C9B" )
oStruV1G	:=	FWFormStruct( 1, "V1G" )
oStruV1H	:=	FWFormStruct( 1, "V1H" )
oStruV1I	:=	FWFormStruct( 1, "V1I" )
oModel		:=	MPFormModel():New( "TAFA255", , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields( "MODEL_C9B", /*cOwner*/, oStruC9B )

oModel:AddGrid( "MODEL_V1G", "MODEL_C9B", oStruV1G )
oModel:GetModel( "MODEL_V1G" ):SetUniqueLine( { "V1G_CNPJOR" } )

oModel:AddGrid( "MODEL_V1H", "MODEL_V1G", oStruV1H )
oModel:GetModel( "MODEL_V1H" ):SetUniqueLine( { "V1H_TPREPA" } )

oModel:AddGrid( "MODEL_V1I", "MODEL_V1G", oStruV1I )
oModel:GetModel( "MODEL_V1I" ):SetUniqueLine( { "V1I_TPPROC", "V1I_NRPROC", "V1I_CODSUS" } )
oModel:GetModel( "MODEL_V1I" ):SetOptional( .T. )
oModel:GetModel('MODEL_V1I'):SetMaxLine(50) 

oModel:SetRelation( "MODEL_V1G", { { "V1G_FILIAL", "xFilial( 'V1G' )" }, { "V1G_ID", "C9B_ID" }, { "V1G_VERSAO", "C9B_VERSAO" } }, V1G->( IndexKey( 1 ) ) )
oModel:SetRelation( "MODEL_V1H", { { "V1H_FILIAL", "xFilial( 'V1H' )" }, { "V1H_ID", "C9B_ID" }, { "V1H_VERSAO", "C9B_VERSAO" }, { "V1H_CNPJOR", "V1G_CNPJOR" } }, V1H->( IndexKey( 1 ) ) )
oModel:SetRelation( "MODEL_V1I", { { "V1I_FILIAL", "xFilial( 'V1I' )" }, { "V1I_ID", "C9B_ID" }, { "V1I_VERSAO", "C9B_VERSAO" }, { "V1I_CNPJOR", "V1G_CNPJOR" } }, V1I->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_C9B" ):SetPrimaryKey( { "C9B_PERAPU", "C9B_TPINSC", "C9B_NRINSC" } )

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Fun��o gen�rica MVC da View.
@author			Felipe C. Seolin
@since			28/08/2013
@version		1.0
@return			oModel - Objeto do modelo MVC
@history		23/01/2018, Felipe C. Seolin, Adequa��o do evento para R-2030.
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oModel	as object
Local oStruC9B	as object
Local oStruC9Ba	as object
Local oStruC9Bb	as object
Local oStruV1G	as object
Local oStruV1H	as object
Local oStruV1I	as object
Local oView		as object
Local aCmpGrp   as array
Local cCmpFil	as char
Local cGrpCom1	as char
Local cGrpCom2	as char
Local cGrpCom3	as char
Local nI		as numeric

oModel		:=	FWLoadModel( "TAFA255" )
oStruC9Ba	:=	Nil
oStruC9Bb	:=	Nil
oStruV1G	:=	FWFormStruct( 2, "V1G" )
oStruV1H	:=	FWFormStruct( 2, "V1H" )
oStruV1I	:=	FWFormStruct( 2, "V1I" )
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
cGrpCom1  := 'C9B_VERSAO|C9B_VERANT|C9B_PROTPN|C9B_EVENTO|C9B_ATIVO|C9B_PERAPU|'
cGrpCom2  := 'C9B_TPINSC|C9B_NRINSC|'
cCmpFil   := cGrpCom1 + cGrpCom2
oStruC9Ba := FwFormStruct( 2, 'C9B', {|x| AllTrim( x ) + "|" $ cCmpFil } )

//"Protocolo de Transmiss�o"
cGrpCom3 := 'C9B_PROTUL|'
cCmpFil   := cGrpCom3
oStruC9Bb := FwFormStruct( 2, 'C9B', {|x| AllTrim( x ) + "|" $ cCmpFil } )

//*******************************************************************************************
//Grupo de campos 	
//*******************************************************************************************

oStruC9Ba:AddGroup( "GRP_ESTAB_01", STR0017, "", 1 ) //"Informa��es de Identifica��o do Evento" 

aCmpGrp := StrToKArr(cGrpCom1,"|")
For nI := 1 to Len(aCmpGrp)
	oStruC9Ba:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_ESTAB_01")
Next nI

oStruC9Ba:AddGroup( "GRP_ESTAB_02", STR0018, "", 1 ) //"Identifica��o do Estabelecimento" 

aCmpGrp := StrToKArr(cGrpCom2,"|")
For nI := 1 to Len(aCmpGrp)
	oStruC9Ba:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_ESTAB_02")
Next nI

//*******************************************************************************************
//Estrutura da View
//*******************************************************************************************

oView:AddField( "VIEW_C9Ba", oStruC9Ba, "MODEL_C9B" )
oView:EnableTitleView( "VIEW_C9Ba", STR0001 ) //"Recursos Recebidos por Associa��o Desportiva"

oView:AddField( "VIEW_C9Bb", oStruC9Bb, "MODEL_C9B" )
oView:EnableTitleView( "VIEW_C9Bb", STR0006 ) //"Recibo de Transmiss�o"

oView:AddGrid( "VIEW_V1G", oStruV1G, "MODEL_V1G" )
oView:EnableTitleView( "VIEW_V1G", STR0005 ) //"Totalizador Recursos Recebidos"

oView:AddGrid( "VIEW_V1H", oStruV1H, "MODEL_V1H" )
oView:EnableTitleView( "VIEW_V1H", STR0002 ) //"Detalhamento Recursos Recebidos"

oView:AddGrid( "VIEW_V1I", oStruV1I, "MODEL_V1I" )
oView:EnableTitleView( "VIEW_V1I", STR0003 ) //"Informa��es de Processos"

//*******************************************************************************************
//Estrutura do Folder
//*******************************************************************************************

oView:CreateHorizontalBox( "PAINEL_PRINCIPAL", 100 )
oView:CreateFolder( "FOLDER_PRINCIPAL", "PAINEL_PRINCIPAL" )

//Aba de Recursos Recebidos por Associa��o Desportiva
oView:AddSheet( "FOLDER_PRINCIPAL", "ABA01", STR0001 ) //"Recursos Recebidos por Associa��o Desportiva"

//Box de Recursos Recebidos por Associa��o Desportiva
oView:CreateHorizontalBox( "FIELDSC9Ba", 20,,, "FOLDER_PRINCIPAL", "ABA01" )

//Box de Totalizador Recursos Recebidos
oView:CreateHorizontalBox( "GRIDV1G", 35,,, "FOLDER_PRINCIPAL", "ABA01" )

//Box para as Abas de Detalhamento Recursos Recebidos e Informa��es de Processos
oView:CreateHorizontalBox( "PANFOLDER1", 45,,, "FOLDER_PRINCIPAL", "ABA01" )
oView:CreateFolder( "FOLDER1", "PANFOLDER1" )

//Aba de Detalhamento Recursos Recebidos
oView:AddSheet( "FOLDER1", "ABA01", STR0002 ) //"Detalhamento Recursos Recebidos"
oView:CreateHorizontalBox( "GRIDV1H", 50,,, "FOLDER1", "ABA01" )

//Aba de Informa��es de Processos
oView:AddSheet( "FOLDER1", "ABA02", STR0003 ) //"Informa��es de Processos"
oView:CreateHorizontalBox( "GRIDV1I", 100,,, "FOLDER1", "ABA02" )

//Aba de Recibo de Transmiss�o
oView:AddSheet( "FOLDER_PRINCIPAL", "ABA02", STR0006 ) //"Recibo de Transmiss�o"
oView:CreateHorizontalBox( "FIELDSC9Bb", 100,,, "FOLDER_PRINCIPAL", "ABA02" )

//*******************************************************************************************
//Amarra��o para exibi��o das informa��es
//*******************************************************************************************
oView:SetOwnerView( "VIEW_C9Ba", "FIELDSC9Ba" )
oView:SetOwnerView( "VIEW_C9Bb", "FIELDSC9Bb" )
oView:SetOwnerView( "VIEW_V1G", "GRIDV1G" )
oView:SetOwnerView( "VIEW_V1H", "GRIDV1H" )
oView:SetOwnerView( "VIEW_V1I", "GRIDV1I" )

//*******************************************************************************************
//Remo��o de campos de controle interno
//*******************************************************************************************
lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif
	xFunRmFStr( @oStruC9Ba, "C9B" )
EndIf

oStruV1I:RemoveField('V1I_IDSUSP')

Return( oView )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF255Xml
@type			function
@description	Fun��o de gera��o do XML para atender o evento R-2030. Quando a rotina for chamada, o registro deve estar posicionado.
@author			Anderson Costa
@since			27/09/2013
@version		1.0
@history		23/01/2018, Felipe C. Seolin, Adequa��o do evento para R-2030.
@param			cAlias	-	Alias corrente
@param			nRecno	-	Recno corrente
@param			nOpc	-	Op��o selecionada
@param			lJob	-	Indicao execu��o por Job
@return			cXml	-	Estrutura do XML do Layout R-2030
/*/
//---------------------------------------------------------------------
Function TAF255Xml( cAlias, nRecno, nOpc, lJob )

Local cXml		as char
Local cLayout	as char
Local cReg		as char
Local cNameXSD  as char

Default lJob	:=	.F.

cXml	 :=	""
cLayout	 :=	"2030"
cReg	 :=	"AssocDespRec"
cNameXSD := 'RecursoRecebidoAssociacao'

DBSelectArea( "V1G" )
V1G->( DBSetOrder( 1 ) ) 

DBSelectArea( "V1H" )
V1H->( DBSetOrder( 1 ) ) 

DBSelectArea( "V1I" )
V1I->( DBSetOrder( 1 ) ) 


//Revisar a forma de pesquisa do Estabelecimento
cXml += "<ideEstab>"
cXml += 	xTafTag( "tpInscEstab", C9B->C9B_TPINSC )
cXml += 	xTafTag( "nrInscEstab", C9B->C9B_NRINSC )


If V1G->( MsSeek( xFilial( "V1G" ) + C9B->( C9B_ID + C9B_VERSAO ) ) )
	While V1G->( !Eof() ) .and. V1G->( V1G_FILIAL + V1G_ID + V1G_VERSAO ) == C9B->( C9B_FILIAL + C9B_ID + C9B_VERSAO )

		cXml += "<recursosRec>"
		cXml += 	xTafTag( "cnpjOrigRecurso", V1G->V1G_CNPJOR )
		cXml += 	xTafTag( "vlrTotalRec"    , TafFReinfNum(V1G->V1G_VLREPA))
		cXml += 	xTafTag( "vlrTotalRet"    , TafFReinfNum(V1G->V1G_VLRET ) )
		cXml += 	xTafTag( "vlrTotalNRet"   , TafFReinfNum(V1G->V1G_VLNRET), , .T. )

		If V1H->( MsSeek( xFilial( "V1H" ) + V1G->( V1G_ID + V1G_VERSAO + V1G_CNPJOR ) ) )
			While V1H->( !Eof() ) .and. V1H->( V1H_FILIAL + V1H_ID + V1H_VERSAO + V1H_CNPJOR ) ==  V1G->( V1G_FILIAL + V1G_ID + V1G_VERSAO + V1G_CNPJOR )
				cXml += "<infoRecurso>"
				cXml += 	xTafTag( "tpRepasse"  , V1H->V1H_TPREPA )
				cXml += 	xTafTag( "descRecurso", V1H->V1H_DESCRE )
				cXml += 	xTafTag( "vlrBruto"   , TafFReinfNum(V1H->V1H_VLBRUT) )
				cXml += 	xTafTag( "vlrRetApur" , TafFReinfNum(V1H->V1H_VLRECP) )					
				cXml += "</infoRecurso>"

				V1H->( DBSkip() )
			EndDo
		EndIf
		
		If V1I->( MsSeek( xFilial( "V1I" ) + V1G->( V1G_ID + V1G_VERSAO + V1G_CNPJOR ) ) )
			While V1I->( !Eof() ) .and. V1I->( V1I_FILIAL + V1I_ID + V1I_VERSAO + V1I_CNPJOR  ) ==  V1G->( V1G_FILIAL + V1G_ID + V1G_VERSAO + V1G_CNPJOR )
				//If V1G->V1G_VLNRET > 0 .Or. V1I->V1I_CODSUS $ "92"
					xTafTagGroup("infoProc"      ,{ { "tpProc" , V1I->V1I_TPPROC				    	,,.F. }; 
										 		 ,  { "nrProc" , V1I->V1I_NRPROC				    	,,.F. };
										 		 ,	{ "codSusp", V1I->V1I_CODSUS 						,,.T. };
				   	  		 			 		 ,  { "vlrNRet", TafFReinfNum(V1I->V1I_VLNRET)  		,,.F. }};	
				   	  		 			 		 ,  @cXml)

				//EndIf

				V1I->( DBSkip() )
			EndDo
		EndIf
		
		cXml += "</recursosRec>"

		V1G->( DBSkip() )
	EndDo
EndIf

cXml += "</ideEstab>"

V1G->( DBCloseArea() )
V1H->( DBCloseArea() )
V1I->( DBCloseArea() )
T9U->( DBCloseArea() )

cXml := TAFXmlReinf( cXml, "C9B", cLayout, cReg, SubStr( C9B->C9B_PERAPU, 3, 4 ) + "-" + SubStr( C9B->C9B_PERAPU, 1, 2 ),, cNameXSD)

If !lJob
	xTafGerXml( cXml, cLayout,,,,,, "R-" )
EndIf

Return( cXml )

//---------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
@type			function
@description	Fun��o com o objetivo de gerar o Evento de Exclus�o.
@author			Vitor Henrique Ferreira
@since			30/06/2015
@version		1.0
@history		02/02/2018, Felipe C. Seolin, Adequa��o do evento para R-2030.
@param			oModel	-	Modelo de dados
@param			nRecno	-	N�mero do registro
@param			lRotExc	-	Vari�vel que controla se a function � chamada pelo TafIntegraESocial
/*/
//---------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

Local oModelC9B		as object
Local oModelV1G		as object
Local oModelV1H		as object
Local oModelV1I		as object
Local cVerAnt		as char
Local cRecibo		as char
Local cVersao		as char
Local nI			as numeric
Local nV1G			as numeric
Local nV1H			as numeric
Local nV1HAdd		as numeric
Local nV1I			as numeric
Local nV1IAdd		as numeric
Local aGravaC9B		as array
Local aGravaV1G		as array
Local aGravaV1H		as array
Local aGravaV1I		as array

oModelC9B	:=	Nil
oModelV1G	:=	Nil
oModelV1H	:=	Nil
oModelV1I	:=	Nil
cVerAnt		:=	""
cRecibo		:=	""
cVersao		:=	""
nI			:=	0
nV1G		:=	0
nV1H		:=	0
nV1HAdd		:=	0
nV1I		:=	0
nV1IAdd		:=	0
aGravaC9B	:=	{}
aGravaV1G	:=	{}
aGravaV1H	:=	{}
aGravaV1I	:=	{}

Begin Transaction

	DBSelectArea( "C9B" )
	C9B->( DBGoTo( nRecno ) )

	oModelC9B := oModel:GetModel( "MODEL_C9B" )
	oModelV1G := oModel:GetModel( "MODEL_V1G" )
	oModelV1H := oModel:GetModel( "MODEL_V1H" )
	oModelV1I := oModel:GetModel( "MODEL_V1I" )

	//************************************
	//Informa��es para grava��o do rastro
	//************************************
	cVerAnt := oModelC9B:GetValue( "C9B_VERSAO" )
	cRecibo := oModelC9B:GetValue( "C9B_PROTUL" )

	//****************************************************************************************************************
	//Armazeno as informa��es que foram modificadas na tela, para utiliza��o em opera��o de inclus�o de novo registro
	//****************************************************************************************************************
	For nI := 1 to Len( oModelC9B:aDataModel[1] )
		aAdd( aGravaC9B, { oModelC9B:aDataModel[1,nI,1], oModelC9B:aDataModel[1,nI,2] } )
	Next nI

	//V1G
	If V1G->( MsSeek( xFilial( "V1G" ) + C9B->( C9B_ID + C9B_VERSAO ) ) )

		For nV1G := 1 to oModel:GetModel( "MODEL_V1G" ):Length()
			oModel:GetModel( "MODEL_V1G" ):GoLine( nV1G )

			If !oModel:GetModel( "MODEL_V1G" ):IsEmpty() .and. !oModel:GetModel( "MODEL_V1G" ):IsDeleted()
				aAdd( aGravaV1G, {	oModelV1G:GetValue( "V1G_CNPJOR" ),;
									oModelV1G:GetValue( "V1G_VLREPA" ),;
									oModelV1G:GetValue( "V1G_VLRET"  ),;
									oModelV1G:GetValue( "V1G_VLNRET" ) } )

				//V1H
				For nV1H := 1 to oModel:GetModel( "MODEL_V1H" ):Length()
					oModel:GetModel( "MODEL_V1H" ):GoLine( nV1H )
					If !oModel:GetModel( "MODEL_V1H" ):IsEmpty() .and. !oModel:GetModel( "MODEL_V1H" ):IsDeleted()
						aAdd( aGravaV1H, {	oModelV1G:GetValue( "V1G_CNPJOR" ),;
											oModelV1H:GetValue( "V1H_TPREPA" ),;
											oModelV1H:GetValue( "V1H_DESCRE" ),;
											oModelV1H:GetValue( "V1H_VLBRUT" ),;
											oModelV1H:GetValue( "V1H_VLRECP" ) } )
					EndIf
				Next nV1H
			EndIf
			
			//V1I
			For nV1I := 1 to oModel:GetModel( "MODEL_V1I" ):Length()
				oModel:GetModel( "MODEL_V1I" ):GoLine( nV1I )
				If !oModel:GetModel( "MODEL_V1I" ):IsEmpty() .and. !oModel:GetModel( "MODEL_V1I" ):IsDeleted()
					aAdd( aGravaV1I, {	oModelV1G:GetValue( "V1G_CNPJOR" ),;										
										oModelV1I:GetValue( "V1I_IDPROC" ),;
										oModelV1I:GetValue( "V1I_TPPROC" ),;
										oModelV1I:GetValue( "V1I_NRPROC" ),;
										oModelV1I:GetValue( "V1I_CODSUS" ),;
										oModelV1I:GetValue( "V1I_IDSUSP" ),;
										oModelV1I:GetValue( "V1I_VLNRET" ) } )
				EndIf
			Next nV1I			

		Next nV1G

	EndIf

	//*****************************
	//Seto o registro como Inativo
	//*****************************
	FAltRegAnt( "C9B", "2" )

	//**************************************
	//Opera��o de Inclus�o de novo registro
	//**************************************
	oModel:DeActivate()
	oModel:SetOperation( 3 )
	oModel:Activate()

	//********************************************************************************
	//Inclus�o do novo registro j� considerando as informa��es alteradas pelo usu�rio
	//********************************************************************************
	For nI := 1 to Len( aGravaC9B )
		oModel:LoadValue( "MODEL_C9B", aGravaC9B[nI,1], aGravaC9B[nI,2] )
	Next nI

	//V1G
	For nV1G := 1 to Len( aGravaV1G )

		oModel:GetModel( "MODEL_V1G" ):LVALID := .T.

		If nV1G > 1
			oModel:GetModel( "MODEL_V1G" ):AddLine()
		EndIf

		oModel:LoadValue( "MODEL_V1G", "V1G_CNPJOR", aGravaV1G[nV1G][1] )
		oModel:LoadValue( "MODEL_V1G", "V1G_VLREPA", aGravaV1G[nV1G][2] )
		oModel:LoadValue( "MODEL_V1G", "V1G_VLRET" , aGravaV1G[nV1G][3] )
		oModel:LoadValue( "MODEL_V1G", "V1G_VLNRET", aGravaV1G[nV1G][4] )

		//V1H
		nV1HAdd := 1
		For nV1H := 1 to Len( aGravaV1H )
			If aGravaV1H[nV1H][1] == aGravaV1G[nV1G][1]

				oModel:GetModel( "MODEL_V1H" ):LVALID := .T.

				If nV1HAdd > 1
					oModel:GetModel( "MODEL_V1H" ):AddLine()
				EndIf

				oModel:LoadValue( "MODEL_V1H", "V1H_TPREPA", aGravaV1H[nV1H][2] )
				oModel:LoadValue( "MODEL_V1H", "V1H_DESCRE", aGravaV1H[nV1H][3] )
				oModel:LoadValue( "MODEL_V1H", "V1H_VLBRUT", aGravaV1H[nV1H][4] )
				oModel:LoadValue( "MODEL_V1H", "V1H_VLRECP", aGravaV1H[nV1H][5] )

				nV1HAdd ++
			EndIf
		Next nV1H
		
		//V1I
		nV1IAdd := 1
		For nV1I := 1 to Len( aGravaV1I )
			If aGravaV1I[nV1I][1] == aGravaV1G[nV1G][1] 

				oModel:GetModel( "MODEL_V1I" ):LVALID := .T.

				If nV1IAdd > 1
					oModel:GetModel( "MODEL_V1I" ):AddLine()
				EndIf


				oModel:LoadValue( "MODEL_V1I", "V1I_IDPROC", aGravaV1I[nV1I][2] )
				oModel:LoadValue( "MODEL_V1I", "V1I_TPPROC", aGravaV1I[nV1I][3] )
				oModel:LoadValue( "MODEL_V1I", "V1I_NRPROC", aGravaV1I[nV1I][4] )
				oModel:LoadValue( "MODEL_V1I", "V1I_CODSUS", aGravaV1I[nV1I][5] )
				oModel:LoadValue( "MODEL_V1I", "V1I_IDSUSP", aGravaV1I[nV1I][6] )
				oModel:LoadValue( "MODEL_V1I", "V1I_VLNRET", aGravaV1I[nV1I][7] )

				nV1IAdd ++
			EndIf
		Next nV1I

	Next nV1G

	//*****************************************
	//Vers�o que ser� gravada no novo registro
	//*****************************************
	cVersao := xFunGetVer()

	//********************************************************************
	//ATEN��O
	//A altera��o destes campos devem sempre estar abaixo do loop do For,
	//pois devem substituir as informa��es que foram armazenadas acima
	//********************************************************************
	oModel:LoadValue( "MODEL_C9B", "C9B_VERSAO", cVersao )
	oModel:LoadValue( "MODEL_C9B", "C9B_VERANT", cVerAnt )
	oModel:LoadValue( "MODEL_C9B", "C9B_PROTPN", cRecibo )
	oModel:LoadValue( "MODEL_C9B", "C9B_PROTUL", "" )

	oModel:LoadValue( "MODEL_C9B", "C9B_EVENTO", "E" )
	oModel:LoadValue( "MODEL_C9B", "C9B_ATIVO", "1" )

	FWFormCommit( oModel )
	TAFAltStat("C9B", "6") 

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

	oBrowse:SetDescription( "R-2030 - "+STR0001 ) //"Recursos Recebidos por Associa��o Desportiva"
	oBrowse:SetAlias( "C9B" )
	oBrowse:SetMenuDef( "TAFA255" )
	oBrowse:SetFilterDefault( "C9B_ATIVO == '1'" )

	//DbSelectArea("C9B")
	//Set Filter TO &("C9B_ATIVO == '1'")

	If FindFunction("TAFLegReinf")
		TAFLegReinf( "C9B", oBrowse)
	Else
		TAFLegend( 2, "C9B", @oBrowse )
	EndIf


	oBrowse:Activate()

Return( oBrowse )

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
