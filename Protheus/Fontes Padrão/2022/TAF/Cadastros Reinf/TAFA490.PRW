#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA490.CH"
#INCLUDE "TOPCONN.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA490
@type			function
@description	Cadastro do Evento R-9000 da Reinf - Exclusï¿½o de Eventos
@author			Henrique Pereira
@since			22/01/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA490()

If TAFAlsInDic( "T9D" )
	BrowseDef()
Else
	Aviso( STR0007, TafAmbInvMsg(), { STR0008 }, 3 ) //##"Dicionï¿½rio Incompatï¿½vel" ##"Encerrar"
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@type			function
@description	Funï¿½ï¿½o genï¿½rica MVC com as opï¿½ï¿½es de menu.
@author			Henrique Pereira
@since			22/01/2018
@version		1.0
@return			aRotina - Array com as opï¿½ï¿½es de menu.
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao	as array
Local aRotina	as array

aFuncao	:=	{}
aRotina	:=	{}

aAdd( aFuncao, { "", "TAF490Xml", "1" } )
aAdd( aFuncao, { "", "TAFXmlLote( 'T9D', 'R-9000', 'evtExclusao', 'TAF490Xml', 5, oBrowse)", "5" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.TAFA490" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0010   	ACTION "TAF490Xml()" 	  OPERATION 2 ACCESS 0 //"Gerar Xml Reinf"
	ADD OPTION aRotina TITLE STR0011 	ACTION "TAFXmlLote( 'T9D', 'R-9000', 'evtExclusao', 'TAF490Xml', 5, oBrowse)" 	 OPERATION 2 ACCESS 0 //"Gerar Xml em Lote"
Else
	aRotina := TAFMenuReinf( "TAFA490", aFuncao )
EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF490Pre
@type			function
@description	Executa prï¿½-condiï¿½ï¿½es para a operaï¿½ï¿½o desejada.
@author			Felipe C. Seolin
@since			13/03/2018
@version		1.0
@param			cOper	-	Indica a operaï¿½ï¿½o a ser executada
/*/
//---------------------------------------------------------------------
Function TAF490Pre( cOper )

Local nOperation	as numeric

nOperation	:=	MODEL_OPERATION_VIEW

//De-Para de opï¿½ï¿½es do Menu para a operaï¿½ï¿½es em MVC
If Upper( cOper ) == Upper( "Alterar" )
	nOperation := MODEL_OPERATION_UPDATE
ElseIf Upper( cOper ) == Upper( "Excluir" )
	nOperation := MODEL_OPERATION_DELETE
Else
	nOperation := MODEL_OPERATION_VIEW
EndIf

//Permitido operaï¿½ï¿½o de Alteraï¿½ï¿½o e Exclusï¿½o apenas em registros nï¿½o transmitidos ou transmitido com rejeiï¿½ï¿½o
If T9D->T9D_STATUS $ " 013"
	FWExecView( cOper, "TAFA490", nOperation )
Else
	MsgInfo( STR0009 ) //"Operaï¿½ï¿½o nï¿½o permitida para registros transmitidos."
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
@type			function
@description	Funï¿½ï¿½o genï¿½rica MVC do Model.
@author			Henrique Pereira
@since			22/01/2018
@version		1.0
@history		08/03/2018, Felipe C. Seolin, Correï¿½ï¿½o nas funcionalidades de habilitar e limpar campos de perï¿½odo.
@return			oModel - Objeto do modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

Local oModel	as object
Local oStruT9D	as object

oModel		:=	MPFormModel():New( "TAFA490",,, { |oModel| SaveModel( oModel ) } )
oStruT9D	:=	FWFormStruct( 1, "T9D" )

//oStruT9D:SetProperty( "T9D_PERAPU", MODEL_FIELD_WHEN, FWBuildFeature( STRUCT_FEATURE_WHEN, "TAF490HabPER( 'T9D_PERAPU' )" ) )
oStruT9D:AddTrigger( "T9D_TPEVEN", "T9D_PERAPU",, { || "" } )
oStruT9D:SetProperty( "T9D_PERAPU", MODEL_FIELD_WHEN, { |oModel| TAF490HabPer( "T9D_PERAPU", @oModel ) } )

//oStruT9D:SetProperty( "T9D_PERAPR", MODEL_FIELD_WHEN, FWBuildFeature( STRUCT_FEATURE_WHEN, "TAF490HabPER( 'T9D_PERAPR' )" ) )
oStruT9D:AddTrigger( "T9D_TPEVEN", "T9D_PERAPR",, { || "" } )
oStruT9D:SetProperty( "T9D_PERAPR", MODEL_FIELD_WHEN, { |oModel| TAF490HabPer( "T9D_PERAPR", @oModel ) } )

oModel:AddFields( "MODEL_T9D", /*cOwner*/, oStruT9D )
oModel:GetModel( "MODEL_T9D" ):SetPrimaryKey( { "T9D_FILIAL", "T9D_ID", "T9D_VERSAO" } )

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Funï¿½ï¿½o genï¿½rica MVC da View
@author			Henrique Pereira
@since			22/01/2018
@version		1.0
@history		08/03/2018, Felipe C. Seolin, Conversï¿½o de Abas do Dicionï¿½rio para View.
@return			oView	-	Objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oModel	as object
Local oStruT9Da	as object
Local oStruT9Db	as object
Local oView		as object

oModel		:=	FWLoadModel( "TAFA490" )
oStruT9Da	:=	FWFormStruct( 2, "T9D", { |x| !( AllTrim( x ) $ "T9D_PROTUL|T9D_PROTPN" ) } ) //Campos exceto Recibo
oStruT9Db	:=	FWFormStruct( 2, "T9D", { |x| AllTrim( x ) $ "T9D_PROTUL|T9D_PROTPN" } ) //Campos Recibo
oView		:=	FWFormView():New()

oView:SetModel( oModel )

//*******************************************************************************************
//Estrutura da View
//*******************************************************************************************
oView:AddField( "VIEW_T9Da", oStruT9Da, "MODEL_T9D" )
oView:EnableTitleView( "VIEW_T9Da", STR0001 ) //"Exclusï¿½o de Eventos"

oView:AddField( "VIEW_T9Db", oStruT9Db, "MODEL_T9D" )
oView:EnableTitleView( "VIEW_T9Db", STR0006 ) //"Recibo de Transmissï¿½o"

//*******************************************************************************************
//Estrutura do Folder
//*******************************************************************************************
oView:CreateHorizontalBox( "PAINEL_PRINCIPAL", 100 )
oView:CreateFolder( "FOLDER_PRINCIPAL", "PAINEL_PRINCIPAL" )

//Aba de Recursos Recebidos por Associaï¿½ï¿½o Desportiva
oView:AddSheet( "FOLDER_PRINCIPAL", "ABA01", STR0001 ) //"Exclusï¿½o de Eventos"
oView:CreateHorizontalBox( "FIELDST9Da", 100,,, "FOLDER_PRINCIPAL", "ABA01" )

//Aba de Recibo de Transmissï¿½o
oView:AddSheet( "FOLDER_PRINCIPAL", "ABA02", STR0006 ) //"Recibo de Transmissï¿½o"
oView:CreateHorizontalBox( "FIELDST9Db", 100,,, "FOLDER_PRINCIPAL", "ABA02" )

//*******************************************************************************************
//Amarraï¿½ï¿½o para exibiï¿½ï¿½o das informaï¿½ï¿½es
//*******************************************************************************************
oView:SetOwnerView( "VIEW_T9Da", "FIELDST9Da" )
oView:SetOwnerView( "VIEW_T9Db", "FIELDST9Db" )

//*******************************************************************************************
//Remoï¿½ï¿½o de campos de controle interno
//*******************************************************************************************
lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif
	xFunRmFStr( @oStruT9Da, "T9D" )
EndIf

oStruT9Da:RemoveField( "T9D_ID" )
oStruT9Da:RemoveField( "T9D_IDTPEV" )
oStruT9Da:RemoveField( "T9D_REGREF" )
oStruT9Db:RemoveField( "T9D_PROTPN" )

Return( oView )

//---------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
@type			function
@description	Funï¿½ï¿½o de gravaï¿½ï¿½o dos dados, executado no momento da confirmaï¿½ï¿½o do modelo.
@author			Henrique Pereira
@since			22/01/2018
@version		1.0
@param			oModel	-	Modelo de dados
@return			lReturn	-	Indica se a operaï¿½ï¿½o foi executada
/*/
//---------------------------------------------------------------------
Static Function SaveModel( oModel )

Local cChave		as char
Local cEvento		as char
Local cAlias		as char
Local cFunction		as char
Local cSelect		as char
Local cFrom			as char
Local cWhere		as char
Local cAliasQry		as char
Local nOperation	as numeric
Local aRotinas		as array
Local lExcPer 		as character 
Local lSaveModel	as logical
Local lReturn		as logical

Default oModel		:=	Nil

cChave		:=	""
cEvento		:=	""
cAlias		:=	""
cFunction	:=	""
cSelect		:=	""
cFrom		:=	""
cWhere		:=	""
cAliasQry	:=	""
nOperation	:=	oModel:GetOperation()
aRotinas	:=	{}
lExcPer		:= IsInCallStack("TAFExcReg2") 
lSaveModel	:=	FunName() $ "TAFA490"
lReturn		:=	.T.

Begin Transaction

	If nOperation == MODEL_OPERATION_INSERT
		oModel:LoadValue( "MODEL_T9D", "T9D_VERSAO", xFunGetVer() )
		FWFormCommit( oModel )

		cEvento := Posicione( "T9B", 1, xFilial( "T9B" ) + T9D->T9D_IDTPEV, "T9B_CODIGO" )

		GerExcR9000( cEvento, T9D->T9D_NRRECI, .T. )

	ElseIf nOperation == MODEL_OPERATION_UPDATE

		//Busca para posicionar no registro antes de realizar as validaï¿½ï¿½es, visto que quando
		//nï¿½o estï¿½ pocisionado nï¿½o ï¿½ possï¿½vel analisar os campos Nï¿½o Usados como _STATUS
		T9D->( DBSetOrder( 3 ) )
		If T9D->( MsSeek( xFilial( "T9D" ) + T9D->T9D_ID + "1" ) )
			If T9D->T9D_STATUS $ ( "4" )
				MsgAlert( xValStrEr( "000749" ) ) //"Nï¿½o ï¿½ possï¿½vel realizar alteraï¿½ï¿½es em registros jï¿½ transmitidos."
				lReturn := .F.
			ElseIf T9D->T9D_STATUS == ( "2" )
				MsgAlert( xValStrEr( "000727" ) ) //"Registro nï¿½o pode ser alterado, pois se encontra em processo de transmissï¿½o."
				lReturn := .F.
			EndIf

			If lReturn
				FWFormCommit( oModel )
				TAFAltStat( "T9D", " " )
			EndIf
		EndIf

	ElseIf nOperation == MODEL_OPERATION_DELETE

		If T9D->T9D_STATUS $ ( "2|4" ) .And. !lExcPer
			Aviso( STR0002, STR0003, { STR0004 }, 1 ) //##"Exclusï¿½o de Evento" ##"Esse registro jï¿½ foi transmitido, portanto nï¿½o pode ser excluï¿½do." ##"Fechar"
			lReturn := .F.
		Else
			oModel:DeActivate()
			oModel:SetOperation( 5 )
			oModel:Activate()
			FWFormCommit( oModel )

			//Restaura o registro que havia sido excluï¿½do
			cEvento := Posicione( "T9B", 1, xFilial( "T9B" ) + T9D->T9D_IDTPEV, "T9B_CODIGO" )

			aRotinas := TAFRotinas( cEvento, 4, .F., 5 )
			If !Empty( aRotinas )
				cAlias := aRotinas[3]
				cFunction := aRotinas[1]

				//Se a exclusï¿½o for pelo SaveModel
				If lSaveModel
					cSelect := ""

					cAliasQry := GetNextAlias()

					cSelect := cAlias + ".R_E_C_N_O_ RECNO "
					cFrom := RetSqlName( cAlias ) + " " + cAlias
					cWhere += cAlias + "_ATIVO = '1' "
					cWhere += " AND " + cAlias + "_STATUS = '6' "
					cWhere += " AND " + cAlias + "_PROTPN = '" + T9D->T9D_NRRECI + "' "
					cWhere += " AND D_E_L_E_T_ = '' "

					cSelect := "%" + cSelect + "%"
					cFrom := "%" + cFrom + "%"
					cWhere := "%" + cWhere + "%"

					BeginSql Alias cAliasQry

						SELECT
							%Exp:cSelect%
						FROM
							%Exp:cFrom%
						WHERE
							%EXP:cWhere%

					EndSql

					If ( cAliasQry )->( !Eof() )
						( cAlias )->( DBGoTo( ( cAliasQry )->RECNO ) )

						If ( cAlias )->( !Eof() )
							cChave := &( cAlias + "->" + cAlias + "_ID" ) + &( cAlias + "->" + cAlias + "_VERANT" )
							oModel := FWLoadModel( cFunction )
							oModel:SetOperation( 5 )
							oModel:Activate()
							FWFormCommit( oModel )

							TAFRastro( cAlias, 1, cChave, .T. )
						EndIf
					EndIf
				EndIf

			EndIf

		EndIf

	EndIf

End Transaction

Return( lReturn )

//---------------------------------------------------------------------
/*/{Protheus.doc} GerExcR9000
@type			function
@description	Funcï¿½o que gera o registro de exclusï¿½o para um determinado evento.
@author			Henrique Pereira
@since			22/01/2018
@version		1.0
@param			cEvento		-	Tipo de evento a ser excluï¿½do
@param			cRecChv		-	Chave que pode ser o protocolo ou a chave do evento
/*/
//---------------------------------------------------------------------
Static Function GerExcR9000( cEvento, cRecChv )

Local cVerAnt	as char
Local cAlias	as char
Local cFunction	as char
Local nInd		as numeric
Local aRotinas	as array
Local lReturn	as logical

Private oModel	as object
Private nRecno	as numeric

Default cEvento	:=	""
Default cRecChv	:=	""

cVerAnt		:=	""
cAlias		:=	""
cFunction	:=	""
nInd		:=	0
aRotinas	:=	TAFRotinas( cEvento, 4, .F., 5 )
lReturn		:=	.T.

oModel		:=	Nil
nRecno		:=	0

If !Empty( aRotinas )
	cFunction := aRotinas[1]
	cAlias := aRotinas[3]
	nInd := aRotinas[13]

	DBSelectArea( cAlias )
	( cAlias )->( DBSetOrder( nInd ) )
	If ( cAlias )->( MsSeek( xFilial( cAlias ) + PadR( cRecChv, GetSX3Cache( cAlias + "_PROTUL", "X3_TAMANHO" ) ) + "1" ) )
		nRecno := ( cAlias )->( Recno() )
		oModel := FWLoadModel( cFunction )

		If ( cAlias )->&( cAlias + "_STATUS" ) == "4"
			oModel:SetOperation( 4 )
			oModel:Activate()
			&( "StaticCall( " + cFunction + ", GerarEvtExc, oModel, nRecno, .T. )" )
		EndIf
	EndIf
EndIf

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF490Xml
@type			function
@description	Funï¿½ï¿½o de geraï¿½ï¿½o do XML para atender o evento R-9000. Quando a rotina for chamada, o registro deve estar posicionado.
@author			Henrique Pereira
@since			22/01/2018
@version		1.0
@history		12/03/2018, Felipe C. Seolin, Correï¿½ï¿½o da geraï¿½ï¿½o da tag tpEvento.
@param			cAlias	-	Alias corrente
@param			nRecno	-	Recno corrente
@param			nOpc	-	Opï¿½ï¿½o selecionada
@param			lJob	-	Indicao execuï¿½ï¿½o por Job
@return			cXml	-	Estrutura do XML do Layout R-9000
/*/
//---------------------------------------------------------------------
Function TAF490Xml( cAlias, nRecno, nOpc, lJob )

Local cXml		as char
Local cLayout	as char
Local cReg		as char
Local cPerApu	as char
Local cNameXSD	as char

Default cAlias	:=	"T9D"
Default nRecno	:=	1
Default nOpc	:=	1
Default lJob	:=	.F.

cXml		:=	""
cLayout		:=	"9000"
cReg		:=	"Exclusao"
cPerApu		:=	""
cNameXSD	:= 'Exclusao'

If !Empty( T9D->T9D_PERAPR ) .or. !Empty( T9D->T9D_PERAPU )
	If !Empty( T9D->T9D_PERAPR )
		//formato AAAA-MM-DD
		cPerApu := DtoS(T9D->T9D_PERAPR)
		cPerApu := SubStr( cPerApu, 1, 4 ) + "-" + SubStr( cPerApu, 5, 2 ) + "-" + SubStr( cPerApu, 7, 2 )
	ElseIf !Empty( T9D->T9D_PERAPU )
		cPerApu := SubStr( T9D->T9D_PERAPU, 3, 4 ) + "-" + SubStr( T9D->T9D_PERAPU, 1, 2 )
	EndIf
EndIf

cXml := "<infoExclusao>"
cXml += 	xTafTag( "tpEvento", Posicione( "T9B", 1, xFilial( "T9B" ) + T9D->T9D_IDTPEV, "T9B_CODIGO" ) )
cXml += 	xTafTag( "nrRecEvt", T9D->T9D_NRRECI )
cXml += 	xTafTag( "perApur", cPerApu )
cXml += "</infoExclusao>"

//Estrutura do cabeï¿½alho
cXml := TAFXmlReinf( cXml, "T9D", cLayout, cReg, cPerApu,, cNameXSD )

//Executa gravaï¿½ï¿½o do registro
If !lJob
	xTafGerXml( cXml, cLayout,,,,,, "R-" )
EndIf

Return( cXml )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFAlw9000
@type			function
@description	Indica os Eventos permitidos para utilizaï¿½ï¿½o do Evento R-9000.
@author			Henrique Pereira
@since			22/01/2018
@version		1.0
@history		08/03/2018, Felipe C. Seolin, Correï¿½ï¿½o dos eventos permitidos.
/*/
//---------------------------------------------------------------------
Function TAFAlw9000()

Local cRet	as char

cRet	:=	"R-2010|R-2020|R-2030|R-2040|R-2050|R-2060|R-2070|R-3010"

Return( cRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFEvt9000
@type			function
@description	Verifica se o Evento pertence aos Eventos permitido pelo R-9000.
@author			Henrique Pereira
@since			22/01/2018
@version		1.0
@param			cEvento	-	Evento a ser verificado
@return			lRet	-	Indica se o Evento ï¿½ permitido ao R-9000
/*/
//---------------------------------------------------------------------
Function TAFEvt9000( cEvento )

Local cAllowed	as char
Local cNomeEven	as char
Local lRet		as logical

Default cEvento	:=	""

cAllowed	:=	TAFAlw9000()
lRet		:=	cEvento $ cAllowed

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF490HabPER
@type			function
@description	Controle para habilitar a ediï¿½ï¿½o do campo T9D_PERAPR apenas para o Evento R-3010.
@author			Henrique Pereira
@since			22/01/2018
@version		1.0
@return			lRet	-	Indica se o campo T9D_PERAPR pode ser habilitado
/*/
//---------------------------------------------------------------------
Function TAF490HabPER( cPer, oModel )

Local cNomeEven		as char
Local nOperation	as numeric
Local lEmptyEve		as logical
Local lRet			as logical

Default cPer	:=	""
Default oModel	:=	Nil

cNomeEven	:=	FWFldGet( "T9D_TPEVEN" )
nOperation	:=	oModel:GetOperation()
lEmptyEve	:=	Empty( cNomeEven )
lRet		:=	.F.

//If nOperation == MODEL_OPERATION_INSERT
	If !lEmptyEve .and. cPer == "T9D_PERAPR" .and. cNomeEven == "R-3010"
		lRet := .T.

		If ValType( oModel ) <> "U"
			oModel:GetModel( "MODEL_T9D" ):LoadValue( "MODEL_T9D", "T9D_PERAPU", "" )
		EndIf
	ElseIf !lEmptyEve .and. cPer == "T9D_PERAPU" .and. cNomeEven <> "R-3010"
		lRet := .T.

		If ValType( oModel ) <> "U"
			oModel:GetModel( "MODEL_T9D" ):LoadValue( "MODEL_T9D", "T9D_PERAPR", CToD( "//" ) )
		EndIf
	ElseIf lEmptyEve
		lRet := .F.
	EndIf
//EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Roberto Souza
@since 23/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
	Local cFiltro	as char
	Private oBrowse	as object

	oBrowse	:=	FWmBrowse():New()

	If FunName() == "TAFXREINF"
		lMenuDif 	:= Iif( Type( "lMenuDif" ) == "U", .T., lMenuDif ) 
		cPerAReinf	:= Iif( Type( "cPerAReinf" ) == "U", "", cPerAReinf )

		cFiltro := "T9D_ATIVO == '1'"  + IIf( !Empty(cPerAReinf) ," .AND. T9D_PERAPU =='"+cPerAReinf+"'","" )
	Else
		cFiltro := "T9D_ATIVO == '1'"
	EndIf

	oBrowse	:=	FWmBrowse():New()
	oBrowse:SetDescription( "R-9000 - "+STR0001 ) //"Exclusï¿½o de Eventos"
	oBrowse:SetAlias( "T9D" )
	oBrowse:SetMenuDef( "TAFA490" )
	oBrowse:SetFilterDefault( "T9D_ATIVO == '1'" )

	//DbSelectArea("T9D")
	//Set Filter TO &(cFiltro)

	If FindFunction("TAFLegReinf")
		TAFLegReinf( "T9D", oBrowse)
	Else
		TAFLegend( 2, "T9D", @oBrowse )
	EndIf

	oBrowse:Activate()
	
Return( oBrowse )

//-------------------------------------------------------------------
/*/{Protheus.doc} Save490Model
Função de redirecionamento para o SaveModel, quando vier do REST
Pois ao chamar oModel:CommitData() instanciado em outro fonte, não encontra a função do bcommit (Savemodel)
@param oModel - objeto model

@author Karen Honda
@since 18/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function Save490Model( oModel )
Return SaveModel( oModel )
