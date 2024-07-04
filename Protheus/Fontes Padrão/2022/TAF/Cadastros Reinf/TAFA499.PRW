#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA499.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA499
@type			function
@description	Cadastro do Evento R-2060 - Contrib Previdenciária Receita Bruta CPRB 
				(Legado CPRB TAFA097 ) / LayOut Unico T082 (CPRB)//
@author			Denis Souza
@since			19/03/2018
@version		1.0
/*/
//---------------------------------------------------------------------

Function TAFA499()

If TAFColumnPos( "V0S_ID" ) .And. Upper(AllTrim( GetSx3Cache("V0S_XMLID", "X3_DESCRIC"))) == Upper("Id Xml do Registro")
	BrowseDef()
Else
	Aviso(STR0002, TafAmbInvMsg(), { STR0003 }, 3) //##"Dicionário Incompatível" ##"Encerrar"
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@type			function
@description	Função genérica MVC com as opções de menu.
@author			Denis Souza
@since			19/03/2018
@version		1.0
@return			aRotina - Array com as opções de menu.
/*/
//---------------------------------------------------------------------

Static Function MenuDef()

Local aFuncao	as array
Local aRotina	as array

aFuncao	:=	{}
aRotina	:=	{}

aAdd(aFuncao, { "", "TAF499Xml", "1" })
aAdd(aFuncao, { "", "xFunNewHis( 'V0S', 'TAFA499' )", "3" })
aAdd(aFuncao, { "", "TAFXmlLote( 'V0S', 'R-2060', 'evtinfocprb', 'TAF499Xml', 5, oBrowse)", "5" })

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TAFA499" OPERATION 2 ACCESS 0 //"Visualizar"
Else
	//aRotina	:=	xFunMnuTAF( "TAFA499" , , aFuncao) //!Habilitar P/ Teste
	aRotina := TAFMenuReinf( "TAFA499", aFuncao ) //!Habilitar P/ Produção
EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
@type			function
@description	Função genérica MVC do Model.
@author			Denis Souza
@since			19/03/2018
@version		1.0
@return			oModel - Objeto do modelo MVC
/*/
//---------------------------------------------------------------------

Static Function ModelDef()

Local oStruV0S	As Object
Local oStruV0T	As Object
Local oStruV0U	As Object
Local oStruV0V	As Object
Local oModel	As Object

oStruV0S	:=	FWFormStruct(1, "V0S")
oStruV0T	:=	FWFormStruct(1, "V0T")
oStruV0U	:=	FWFormStruct(1, "V0U")
oStruV0V	:=	FWFormStruct(1, "V0V")
oModel		:=	MPFormModel():New("TAFA499" , , , {|oModel| SaveModel( oModel ) })

oModel:AddFields("MODEL_V0S", /*cOwner*/, oStruV0S )

oModel:AddGrid("MODEL_V0T", "MODEL_V0S", oStruV0T )
oModel:GetModel("MODEL_V0T"):SetUniqueLine({"V0T_IDATIV"})

oModel:AddGrid("MODEL_V0U", "MODEL_V0T", oStruV0U)
oModel:GetModel("MODEL_V0U"):SetUniqueLine({"V0U_DTAJUS", "V0U_TPAJUS", "V0U_CODAJU"})
oModel:GetModel("MODEL_V0U"):SetOptional(.T.)

oModel:AddGrid("MODEL_V0V", "MODEL_V0T", oStruV0V)
oModel:GetModel("MODEL_V0V"):SetUniqueLine({"V0V_IDPROC", "V0V_IDSUSP"})
oModel:GetModel("MODEL_V0V"):SetMaxLine(50)
oModel:GetModel("MODEL_V0V"):SetOptional(.T.)

oModel:SetRelation("MODEL_V0T",{{"V0T_FILIAL","xFilial('V0T')"},{"V0T_ID","V0S_ID"},{"V0T_VERSAO","V0S_VERSAO"}},V0T->(IndexKey(1)))
oModel:SetRelation("MODEL_V0U",{{"V0U_FILIAL","xFilial('V0U')"},{"V0U_ID", "V0S_ID"},{"V0U_VERSAO", "V0S_VERSAO"},{"V0U_IDATIV","V0T_IDATIV"}},V0U->(IndexKey(1)))
oModel:SetRelation("MODEL_V0V",{{"V0V_FILIAL","xFilial('V0V')"},{"V0V_ID", "V0S_ID"},{"V0V_VERSAO", "V0S_VERSAO"},{"V0V_IDATIV","V0T_IDATIV"}},V0V->(IndexKey(1)))

oModel:GetModel( "MODEL_V0S" ):SetPrimaryKey({"V0S_FILIAL", "V0S_ID", "V0S_VERSAO"})

Return(oModel)

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Função genérica MVC da View.
@author			Denis Souza
@since			19/03/2018
@version		1.0
@return			oModel - Objeto do modelo MVC
/*/
//---------------------------------------------------------------------

Static Function ViewDef()

Local oModel	As Object
Local oStrV0Sa	As Object
Local oStrV0Sb	As Object
Local oStruV0T	As Object
Local oStruV0U	As Object
Local oStruV0V	As Object
Local oView		As Object

oModel		:=	FWLoadModel("TAFA499")
oStrV0Sa	:=	FWFormStruct(2, "V0S", {|x| !( AllTrim( x ) $ "V0S_PROTUL|_PROTPN")})	//Campos exceto Recibo
oStrV0Sb	:=	FWFormStruct(2, "V0S", {|x| AllTrim( x ) $ "V0S_PROTUL|_PROTPN"}) 		//Campos Recibo
oStruV0T	:=	FWFormStruct(2, "V0T")
oStruV0U	:=	FWFormStruct(2, "V0U")
oStruV0V	:=	FWFormStruct(2, "V0V")
oView		:=	FWFormView():New()

oView:SetModel( oModel )

oStrV0Sa:SetProperty( "V0S_PERAPU", MVC_VIEW_ORDEM, "01" )
oStrV0Sa:SetProperty( "V0S_TPINSC", MVC_VIEW_ORDEM, "02" )
oStrV0Sa:SetProperty( "V0S_NRINSC", MVC_VIEW_ORDEM, "03" )
oStrV0Sa:SetProperty( "V0S_VLRBRT", MVC_VIEW_ORDEM, "04" )
oStrV0Sa:SetProperty( "V0S_VLCPAP", MVC_VIEW_ORDEM, "05" )
oStrV0Sa:SetProperty( "V0S_VLSCPR", MVC_VIEW_ORDEM, "06" )

oStruV0T:SetProperty( "V0T_IDATIV", MVC_VIEW_ORDEM, "01" )
oStruV0T:SetProperty( "V0T_CDATIV", MVC_VIEW_ORDEM, "02" )
oStruV0T:SetProperty( "V0T_DESATV", MVC_VIEW_ORDEM, "03" )
oStruV0T:SetProperty( "V0T_VLBTAT", MVC_VIEW_ORDEM, "04" )
oStruV0T:SetProperty( "V0T_VLERBT", MVC_VIEW_ORDEM, "05" )
oStruV0T:SetProperty( "V0T_VLARBT", MVC_VIEW_ORDEM, "06" )
oStruV0T:SetProperty( "V0T_VLBCPR", MVC_VIEW_ORDEM, "07" )
oStruV0T:SetProperty( "V0T_ALQCON", MVC_VIEW_ORDEM, "08" )
oStruV0T:SetProperty( "V0T_CPRBAP", MVC_VIEW_ORDEM, "09" )

oStruV0U:SetProperty( "V0U_DTAJUS", MVC_VIEW_ORDEM, "01" )
oStruV0U:SetProperty( "V0U_TPAJUS", MVC_VIEW_ORDEM, "02" )
oStruV0U:SetProperty( "V0U_CODAJU", MVC_VIEW_ORDEM, "03" )
oStruV0U:SetProperty( "V0U_VLRAJU", MVC_VIEW_ORDEM, "04" )
oStruV0U:SetProperty( "V0U_DESAJU", MVC_VIEW_ORDEM, "05" )

oStruV0V:SetProperty( "V0V_IDPROC", MVC_VIEW_ORDEM, "01" )
oStruV0V:SetProperty( "V0V_TPPROC", MVC_VIEW_ORDEM, "02" )
oStruV0V:SetProperty( "V0V_NRPROC", MVC_VIEW_ORDEM, "03" )
oStruV0V:SetProperty( "V0V_CODSUS", MVC_VIEW_ORDEM, "04" )
oStruV0V:SetProperty( "V0V_IDSUSP", MVC_VIEW_ORDEM, "05" )
oStruV0V:SetProperty( "V0V_VALSUS", MVC_VIEW_ORDEM, "06" )

//*******************************************************************************************
//Estrutura da View
//*******************************************************************************************
oView:AddField( "VIEW_V0Sa", oStrV0Sa, "MODEL_V0S" )
oView:EnableTitleView("VIEW_V0Sa", STR0005)	//"Info. Estabelecimento / CPRB"
												
oView:AddField( "VIEW_V0Sb", oStrV0Sb, "MODEL_V0S" )
oView:EnableTitleView("VIEW_V0Sb", STR0006)	//"Recibo de Transmissão"

oView:AddGrid( "VIEW_V0T", oStruV0T, "MODEL_V0T" )
oView:EnableTitleView("VIEW_V0T", STR0007) 	//"Valor Total X Tipo Cod Ativ Econômica"

oView:AddGrid( "VIEW_V0U", oStruV0U, "MODEL_V0U" ) 
oView:EnableTitleView("VIEW_V0U", STR0008)	//"Tipo Ajuste CPRB"

oView:AddGrid( "VIEW_V0V", oStruV0V, "MODEL_V0V" )
oView:EnableTitleView("VIEW_V0V", STR0009) 	//"Informações Processos"

//*******************************************************************************************
//Estrutura do Folder
//*******************************************************************************************
oView:CreateHorizontalBox( "PAINEL_PRINCIPAL", 100 )
oView:CreateFolder( "FOLDER_PRINCIPAL", "PAINEL_PRINCIPAL" )

//Aba de Info. Estabelecimento / CPRB
oView:AddSheet( "FOLDER_PRINCIPAL", "ABA01", STR0005 )	//"Info. Estabelecimento / CPRB"

//Box de Info. Estabelecimento / CPRB
oView:CreateHorizontalBox( "FIELDSV0Sa", 20,,, "FOLDER_PRINCIPAL", "ABA01" )

//Box de Valor Total X Tipo Cod Ativ Econômica"
oView:CreateHorizontalBox( "GRIDV0T", 35,,, "FOLDER_PRINCIPAL", "ABA01" )

//Box para as Abas de Tipo Ajuste CPRB e Informações Processos
oView:CreateHorizontalBox( "PANFOLDER1", 45,,, "FOLDER_PRINCIPAL", "ABA01" )
oView:CreateFolder( "FOLDER1", "PANFOLDER1" )

//Aba de Tipo Ajuste CPRB
oView:AddSheet( "FOLDER1", "ABA01", STR0008 ) //"Tipo Ajuste CPRB"
oView:CreateHorizontalBox( "GRIDV0U", 100,,, "FOLDER1", "ABA01" )

//Aba de Informações de Processos
oView:AddSheet( "FOLDER1", "ABA02", STR0009 ) //"Informações Processos"
oView:CreateHorizontalBox( "GRIDV0V", 100,,, "FOLDER1", "ABA02" )

//Aba de Recibo de Transmissão
oView:AddSheet( "FOLDER_PRINCIPAL", "ABA02", STR0006 ) //"Recibo de Transmissão"
oView:CreateHorizontalBox( "FIELDSV0Sb", 100,,, "FOLDER_PRINCIPAL", "ABA02" )

//*******************************************************************************************
//Amarração para exibição das informações
//*******************************************************************************************
oView:SetOwnerView( "VIEW_V0Sa"	, "FIELDSV0Sa" )
oView:SetOwnerView( "VIEW_V0Sb"	, "FIELDSV0Sb" )
oView:SetOwnerView( "VIEW_V0T"	, "GRIDV0T" )
oView:SetOwnerView( "VIEW_V0U"	, "GRIDV0U" )
oView:SetOwnerView( "VIEW_V0V"	, "GRIDV0V" )

//*******************************************************************************************
//Remoção de campos de controle interno
//*******************************************************************************************
lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif
	xFunRmFStr( @oStrV0Sa, "V0S" )
EndIf

/*-----------------------------------------------------------------------------------
Remoção Campos
-------------------------------------------------------------------------------------*/
oStrV0Sa:RemoveField("V0S_FILIAL")
oStrV0Sa:RemoveField("V0S_ID")
oStrV0Sa:RemoveField("V0S_STATUS")
oStrV0Sa:RemoveField("V0S_VERSAO")
oStrV0Sa:RemoveField("V0S_VERANT")
oStrV0Sa:RemoveField("V0S_PROTPN")
oStrV0Sa:RemoveField("V0S_EVENTO")
oStrV0Sa:RemoveField("V0S_ATIVO")
//oStrV0Sa:RemoveField("V0S_PROCID")
oStrV0Sa:RemoveField("V0S_XMLID")

oStruV0T:RemoveField("V0T_ID")
oStruV0T:RemoveField("V0T_VERSAO")

oStruV0U:RemoveField("V0U_ID")
oStruV0U:RemoveField("V0U_VERSAO")
oStruV0U:RemoveField("V0U_IDATIV")

oStruV0V:RemoveField("V0V_ID")
oStruV0V:RemoveField("V0V_VERSAO")
oStruV0V:RemoveField("V0V_IDATIV")
oStruV0V:RemoveField("V0V_IDSUSP")

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao para validação de gravação do modelo

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
/*/{Protheus.doc} TAF499Xml
@type			function
@description	Função de geração do XML para atender o evento R-2060. Quando a rotina for chamada, o registro deve estar posicionado.
@author			Denis Souza
@since			19/03/2018
@version		1.0
@param			cAlias	-	Alias corrente
@param			nRecno	-	Recno corrente
@param			nOpc	-	Opção selecionada
@param			lJob	-	Indicao execução por Job
@return			cXml	-	Estrutura do XML do Layout R-2060
/*/
//---------------------------------------------------------------------
Function TAF499Xml( cAlias, nRecno, nOpc, lJob )

Local cXml		As Char
Local cLayout	As Char
Local cReg		As Char
Local cId 	   	As Char
Local cEvento   As Char
Local lObrig	As Logical
Local cNameXSD  As Char

Default lJob :=	.F.

cXml		:= ""
cLayout		:= "2060"
cReg		:= "CPRB" //Registro Campo evtCPRB
cId 		:= ""
cEvento		:= ""
lObrig		:= .F.
cNameXSD	:= 'InfoCPRB'

DBSelectArea("V0T")
V0T->(DBSetOrder(1)) //V0T_FILIAL+V0T_ID+V0T_VERSAO

DBSelectArea("V0U")
V0U->(DBSetOrder(1)) //V0U_FILIAL+V0U_ID+V0U_VERSAO+V0T_IDATIV

DBSelectArea("V0V")
V0V->(DBSetOrder(1)) //V0V_FILIAL+V0V_ID+V0V_VERSAO+V0T_IDATIV

/*
If V0S->V0S_EVENTO $ "I|A"
	If V0S->V0S_EVENTO == "A"
		cEvento := "alteracao"
        cId 	:= V0S->V0S_ID
        cVerAnt	:= V0S->V0S_VERANT
        BeginSql alias 'TEMPV0S'
        	SELECT ._PERAPU
        	FROM %table:V0S% V0S 
        	WHERE V0S.V0S_FILIAL= %xfilial:% AND
        	V0S.V0S_ID = %exp:cId% AND V0S.V0S_VERSAO = %exp:cVerAnt% AND V0S.%notDel%
        EndSql
        cPerApu := Iif(!Empty(('TEMPV0S')->V0S_PERAPU),Substr(('TEMPV0S')->V0S_PERAPU,3,4) + "-" + Substr(('TEMPV0S')->V0S_PERAPU,1,2),"")
        ('TEMPV0S')->(DbCloseArea())
	ElseIf V0S->V0S_EVENTO == "I"
		cEvento := "inclusao"
		cPerApu := Iif(!Empty(('TEMPV0S')->_PERAPU),Substr(('TEMPV0S')->_PERAPU,3,4) + "-" + Substr(('TEMPV0S')->_PERAPU,1,2),"") //IIf pois se a data estiver vazia a string recebia '  -  -   '
	EndIf
*/

cXml += "<infoCPRB>"
cXml += "<ideEstab>"

cXml += 	xTafTag( "tpInscEstab", V0S->V0S_TPINSC,,.F. ) //1-1
cXml += 	xTafTag( "nrInscEstab", V0S->V0S_NRINSC,,.F. ) //1-1

cXml += 	xTafTag( "vlrRecBrutaTotal"	,TafFReinfNum(V0S->V0S_VLRBRT),,.F.) //1-1
cXml += 	xTafTag( "vlrCPApurTotal"	,TafFReinfNum(V0S->V0S_VLCPAP),,.F.) //1-1
cXml += 	xTafTag( "vlrCPRBSuspTotal"	,TafFReinfNum(V0S->V0S_VLSCPR),,.T.) //0-1

If V0T->( MsSeek( xFilial( "V0T" ) + V0S->( V0S_ID + V0S_VERSAO ) ) )
	While V0T->( !Eof() ) .And. V0T->( V0T_FILIAL + V0T_ID + V0T_VERSAO ) == xFilial( "V0T" ) + V0S->( V0S_ID + V0S_VERSAO )
		
		//1 - N | Registro que apresenta o valor total da receita por tipo de código de atividade econômica.
		cXml += "<tipoCod>"
		cXml += 	xTafTag( "codAtivEcon"		,V0T->V0T_CDATIV,,.F.) //1-1
		cXml += 	xTafTag( "vlrRecBrutaAtiv"	,TafFReinfNum(V0T->V0T_VLBTAT),,.F.) //1-1
		cXml += 	xTafTag( "vlrExcRecBruta"	,TafFReinfNum(V0T->V0T_VLERBT),,.F.) //1-1
		cXml += 	xTafTag( "vlrAdicRecBruta"	,TafFReinfNum(V0T->V0T_VLARBT),,.F.) //1-1
		cXml += 	xTafTag( "vlrBcCPRB"		,TafFReinfNum(V0T->V0T_VLBCPR),,.F.) //1-1
		cXml += 	xTafTag( "vlrCPRBapur"		,TafFReinfNum(V0T->V0T_CPRBAP),,.T.) //0-1	  			

		If V0U->( MsSeek( xFilial( "V0U" ) + V0T->( V0T_ID + V0T_VERSAO + V0T_IDATIV ) ) )
			While V0U->( !Eof() ) .And. V0U->( V0U_FILIAL + V0U_ID + V0U_VERSAO + V0U_IDATIV ) == xFilial( "V0U" ) + V0T->( V0T_ID + V0T_VERSAO + V0T_IDATIV )					
				
				lObrig := iif(!Empty(V0U->V0U_TPAJUS) .And. !Empty(V0U->V0U_CODAJU) .And. !Empty(V0U->V0U_VLRAJU) .And. !Empty(V0U->V0U_DESAJU) .And. !Empty(V0U->V0U_DTAJUS) ,.F.,.T.)
				if !lObrig
					//0 - N | Registro a ser preenchido caso a pessoa jurídica tenha de proceder a ajustes da contribuição apurada no período, decorrentes da legislação tributária da contribuição, de estorno ou de outras situações.
					cXml += "<tipoAjuste>"
					cXml += 	xTafTag( "tpAjuste"		,V0U->V0U_TPAJUS				,,lObrig) //1-1
					cXml += 	xTafTag( "codAjuste"	,V0U->V0U_CODAJU				,,lObrig) //1-1
					cXml += 	xTafTag( "vlrAjuste"	,TafFReinfNum(V0U->V0U_VLRAJU)	,,lObrig) //1-1
					cXml += 	xTafTag( "descAjuste"	,NOACENTO(V0U->V0U_DESAJU) ,,lObrig) //1-1
					cXml += 	xTafTag( "dtAjuste"		,(SubStr(V0U->V0U_DTAJUS,3,4) + "-" + SubStr(V0U->V0U_DTAJUS,1,2)),,lObrig) //1-1 "AAAA-MM"
					cXml += "</tipoAjuste>"
				EndIf

				V0U->( DBSkip() )
			EndDo
		EndIf

		If V0V->(MsSeek(xFilial("V0V") + V0T->( V0T_ID + V0T_VERSAO + V0T_IDATIV )))
			While V0V->( !Eof() ) .And. V0V->( V0V_FILIAL + V0V_ID + V0V_VERSAO + V0V_IDATIV ) == xFilial( "V0V" ) + V0T->( V0T_ID + V0T_VERSAO + V0T_IDATIV )					
				
				lObrig := iif((!Empty(V0V->V0V_TPPROC) .And. !Empty(V0V->V0V_NRPROC)),.F.,.T.)
				if !lObrig
					//0 - 50 | Informações de processos relacionados a Suspensão da CPRB.
					cXml += "<infoProc>"
					cXml += 	xTafTag( "tpProc", 		V0V->V0V_TPPROC,,lObrig)					//1-1
					cXml += 	xTafTag( "nrProc", 		V0V->V0V_NRPROC,,lObrig)					//1-1
					cXml += 	xTafTag( "codSusp", 	V0V->V0V_CODSUS,,.T. ) 						//0-1
					cXml += 	xTafTag( "vlrCPRBSusp",	TafFReinfNum(V0V->V0V_VALSUS),,lObrig )	//1-1
					cXml +=	"</infoProc>"
				EndIf

				V0V->( DBSkip() )
			EndDo
		EndIf
		
		cXml += "</tipoCod>"

		V0T->( DBSkip() )
	EndDo
EndIf

cXml += "</ideEstab>"
cXml += "</infoCPRB>"

/*
ElseIf V0S->V0S_EVENTO == "E"

	cXml +=	"<infoProcesso>"
	cXml +=		"<exclusao>"
	cXml +=			"<ideProcesso>"
	cXml += 			xTafTag("tpProc",V0V->V0V_TPPROC)
	cXml += 			xTafTag("nrProc",V0V->V0V_NRPROC)
	cXml +=				//TAFGetDtTab( AAA->AAA_DTINI, AAA->AAA_DTFIN )
	cXml +=			"</ideProcesso>
	cXml +=		"</exclusao>"
	cXml +=	"</infoProcesso>"
EndIf	
*/

V0T->( DBCloseArea() )
V0U->( DBCloseArea() )
V0V->( DBCloseArea() )

cXml := TAFXmlReinf( cXml, "V0S", cLayout, cReg, SubStr( V0S->V0S_PERAPU, 3, 4 ) + "-" + SubStr( V0S->V0S_PERAPU, 1, 2 )  ,, cNameXSD) //"AAAA-MM" evtInfoCPRB-v1_03_00

If !lJob
	xTafGerXml( cXml, cLayout,,,,,, "R-" )
EndIf

Return( cXml )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF499Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return	aLogErro

@author	Denis Souza
@since	26/03/2018

@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------

Function TAF499Vld(cAlias,nRecno,nOpc,lJob)

    Local aLogErro	:= {} 

    Default lJob 		:= .F.

    //Garanto que o Recno seja da tabela referente ao cadastro principal
    nRecno := V0S->( Recno() )

    If V0S->V0S_STATUS $ ( " |1" )

    Else	
        AADD(aLogErro,{"V0S_ID","000305", "V0S", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
    EndIf

    //Não apresento o alert quando utilizo o JOB para validar
    If !lJob
        xValLogEr(aLogErro)
    EndIf

Return(aLogErro)

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF499Valid
@type			function
@description	Função com validação das regras de inclusão e alteração
@description	de eventos de tabelas da Reinf ( VldEvTab ), para o cadastro
@description	de Tabela da CPRB
@author			Denis Souza
@since			28/03/2018
@version		1.0
@return			lRet	-	Indica se a operação é válida
/*/
//---------------------------------------------------------------------
Function TAF499Valid()

Local cCampo	As Char
Local lRet		As Logical 

cCampo	:=	SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
lRet	:=	.T.

If cCampo == "V0S_PERAPU"
	lRet := VldEvTab( "V0S", 2, M->V0S_PERAPU + FWFldGet( "V0S_TPINSC" ) + FWFldGet( "V0S_NRINSC" )	,,,1,,,,5)
ElseIf cCampo == "V0S_TPINSC"
	lRet := VldEvTab( "V0S", 2, FWFldGet( "V0S_PERAPU" ) + M->V0S_TPINSC + FWFldGet( "V0S_NRINSC" )	,,,1,,,,5)
ElseIf cCampo == "V0S_NRINSC"
	lRet := VldEvTab( "V0S", 2, FWFldGet( "V0S_PERAPU" ) + FWFldGet( "V0S_TPINSC" ) + M->V0S_NRINSC	,,,1,,,,5)
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author			Denis Souza
@since			26/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function BrowseDef()

    Private oBrowse As Object

	If FunName() == "TAFXREINF"
		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .T., lMenuDif ) 
	EndIf

    oBrowse	:=	FWMBrowse():New()

	oBrowse:SetDescription( "R-2060 - "+STR0001 ) //"Contribuição Previdenciária sobre a Receita Bruta - CPRB"
	oBrowse:SetAlias( "V0S" )
	oBrowse:SetMenuDef( "TAFA499" )
	oBrowse:SetFilterDefault( "V0S_ATIVO == '1'" )
	
	//DbSelectArea("V0S")
	//Set Filter TO &("V0S_ATIVO == '1'")
	
	oBrowse:SetOnlyFields({"V0S_PERAPU", "V0S_TPINSC", "V0S_NRINSC", "V0S_VLRBRT", "V0S_VLCPAP", "V0S_VLSCPR"})	
	
	If FindFunction("TAFLegReinf")
		TAFLegReinf( "V0S", oBrowse)
	Else
		TAFLegend(2, "V0S", @oBrowse)
	EndIf

    oBrowse:Activate()

Return( oBrowse )

//---------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
@type			function
@description	Função com o objetivo de gerar o Evento de Exclusão.
@author			Denis Souza
@since			10/04/2018
@version		1.0
@param			oModel	-	Modelo de dados
@param			nRecno	-	Número do registro
@param			lRotExc	-	Variável que controla se a function é chamada pelo TafIntegraESocial
/*/
//---------------------------------------------------------------------

Static Function GerarEvtExc( oModel, nRecno, lRotExc )

Local oModelV0S		As Object
Local oModelV0T		As Object
Local oModelV0U		As Object
Local oModelV0V		As Object
Local cVerAnt		As Char
Local cRecAnt		As Char
Local cVersao		As Char
Local nI			As Numeric
Local nV0T			As Numeric
Local nV0U			As Numeric
Local nV0UAdd		As Numeric
Local nV0V			As Numeric
Local nV0VAdd		As Numeric
Local aGravaV0S		As Array
Local aGravaV0T		As Array
Local aGravaV0U		As Array
Local aGravaV0V		As Array

oModelV0S	:=	Nil
oModelV0T	:=	Nil
oModelV0U	:=	Nil
oModelV0V	:=	Nil
cVerAnt		:=	""
cRecAnt		:=	""
cVersao		:=	""
nI			:=	0
nV0T		:=	0
nV0U		:=	0
nV0UAdd		:=	0
nV0V		:=	0
nV0VAdd		:=	0
aGravaV0S	:=	{}
aGravaV0T	:=	{}
aGravaV0U	:=	{}
aGravaV0V	:=	{}

Begin Transaction

	DBSelectArea( "V0S" )
	V0S->( DBGoTo( nRecno ) )

	oModelV0S := oModel:GetModel( "MODEL_V0S" )
	oModelV0T := oModel:GetModel( "MODEL_V0T" )
	oModelV0U := oModel:GetModel( "MODEL_V0U" )
	oModelV0V := oModel:GetModel( "MODEL_V0V" )

	//************************************
	//Informações para gravação do rastro
	//************************************
	cVerAnt := oModelV0S:GetValue( "V0S_VERSAO" )
	cRecAnt := oModelV0S:GetValue( "V0S_PROTUL" )

	//****************************************************************************************************************
	//Armazeno as informações que foram modificadas na tela, para utilização em operação de inclusão de novo registro
	//****************************************************************************************************************
	For nI := 1 to Len( oModelV0S:aDataModel[1] )
		aAdd( aGravaV0S, { oModelV0S:aDataModel[1,nI,1], oModelV0S:aDataModel[1,nI,2] } )
	Next nI

	//V0T - ATIVIDADE
	If V0T->( MsSeek( xFilial( "V0T" ) + V0S->( V0S_ID + V0S_VERSAO ) ) )		
		For nV0T := 1 to oModel:GetModel( "MODEL_V0T" ):Length()
			oModel:GetModel( "MODEL_V0T" ):GoLine( nV0T )
			If !oModel:GetModel( "MODEL_V0T" ):IsEmpty() .And. !oModel:GetModel( "MODEL_V0T" ):IsDeleted()

				aAdd( aGravaV0T, {	oModelV0T:GetValue("V0T_IDATIV"),;
									oModelV0T:GetValue("V0T_CDATIV"),;
									oModelV0T:GetValue("V0T_DESATV"),;
									oModelV0T:GetValue("V0T_VLBTAT"),;
									oModelV0T:GetValue("V0T_VLERBT"),;
									oModelV0T:GetValue("V0T_VLARBT"),;
									oModelV0T:GetValue("V0T_VLBCPR"),;
									oModelV0T:GetValue("V0T_ALQCON"),;
									oModelV0T:GetValue("V0T_CPRBAP")})

				//V0U -AJUSTE
				For nV0U := 1 to oModel:GetModel( "MODEL_V0U" ):Length()
					oModel:GetModel( "MODEL_V0U" ):GoLine( nV0U )
					If !oModel:GetModel( "MODEL_V0U" ):IsEmpty() .And. !oModel:GetModel( "MODEL_V0U" ):IsDeleted()
						aAdd( aGravaV0U, {	oModelV0T:GetValue("V0T_IDATIV"),;
											oModelV0U:GetValue("V0U_DTAJUS"),;
											oModelV0U:GetValue("V0U_TPAJUS"),;
											oModelV0U:GetValue("V0U_CODAJU"),;
											oModelV0U:GetValue("V0U_VLRAJU"),;
											oModelV0U:GetValue("V0U_DESAJU")})
					EndIf
				Next nV0U

				//V0V - PROCESSO
				For nV0V := 1 to oModel:GetModel( "MODEL_V0V" ):Length()
					oModel:GetModel( "MODEL_V0V" ):GoLine( nV0V )		
					If !oModel:GetModel( "MODEL_V0V" ):IsEmpty() .And. !oModel:GetModel( "MODEL_V0V" ):IsDeleted()
						aAdd( aGravaV0V, {	oModelV0T:GetValue("V0T_IDATIV"),;
											oModelV0V:GetValue("V0V_IDPROC"),;
											oModelV0V:GetValue("V0V_TPPROC"),;
											oModelV0V:GetValue("V0V_NRPROC"),;
											oModelV0V:GetValue("V0V_CODSUS"),;
											oModelV0V:GetValue("V0V_IDSUSP"),;
											oModelV0V:GetValue("V0V_VALSUS")})
					EndIf
				Next nV0V
			EndIf
		Next nV0T
	EndIf

	//*****************************
	//Seto o registro como Inativo
	//*****************************
	FAltRegAnt( "V0S", "2" )

	//**************************************
	//Operação de Inclusão de novo registro
	//**************************************
	oModel:DeActivate()
	oModel:SetOperation( 3 )
	oModel:Activate()

	//********************************************************************************
	//Inclusão do novo registro já considerando as informações alteradas pelo usuário
	//********************************************************************************
	For nI := 1 to Len( aGravaV0S )
		oModel:LoadValue( "MODEL_V0S", aGravaV0S[nI,1], aGravaV0S[nI,2] )
	Next nI

	//V0T - Atividade
	For nV0T := 1 to Len( aGravaV0T )
		oModel:GetModel( "MODEL_V0T" ):LVALID := .T.
		If nV0T > 1
			oModel:GetModel( "MODEL_V0T" ):AddLine()
		EndIf
		oModel:LoadValue( "MODEL_V0T", "V0T_IDATIV" , aGravaV0T[nV0T][1] )
		oModel:LoadValue( "MODEL_V0T", "V0T_CDATIV"	, aGravaV0T[nV0T][2] )
		oModel:LoadValue( "MODEL_V0T", "V0T_DESATV" , aGravaV0T[nV0T][3] )
		oModel:LoadValue( "MODEL_V0T", "V0T_VLBTAT" , aGravaV0T[nV0T][4] )
		oModel:LoadValue( "MODEL_V0T", "V0T_VLERBT"	, aGravaV0T[nV0T][5] )
		oModel:LoadValue( "MODEL_V0T", "V0T_VLARBT"	, aGravaV0T[nV0T][6] )
		oModel:LoadValue( "MODEL_V0T", "V0T_VLBCPR"	, aGravaV0T[nV0T][7] )
		oModel:LoadValue( "MODEL_V0T", "V0T_ALQCON"	, aGravaV0T[nV0T][8] )
		oModel:LoadValue( "MODEL_V0T", "V0T_CPRBAP"	, aGravaV0T[nV0T][9] )

		//V0U - Ajuste
		nV0UAdd := 1
		For nV0U := 1 to Len( aGravaV0U )
			If aGravaV0T[nV0T][1] == aGravaV0U[nV0U][1]
				oModel:GetModel( "MODEL_V0U" ):LVALID := .T.
				If nV0UAdd > 1
					oModel:GetModel( "MODEL_V0U" ):AddLine()
				EndIf
				oModel:LoadValue( "MODEL_V0U", "V0U_DTAJUS", aGravaV0U[nV0U][2] )
				oModel:LoadValue( "MODEL_V0U", "V0U_TPAJUS", aGravaV0U[nV0U][3] )
				oModel:LoadValue( "MODEL_V0U", "V0U_CODAJU", aGravaV0U[nV0U][4] )
				oModel:LoadValue( "MODEL_V0U", "V0U_VLRAJU", aGravaV0U[nV0U][5] )
				oModel:LoadValue( "MODEL_V0U", "V0U_DESAJU", aGravaV0U[nV0U][6] )							
				nV0UAdd++
			EndIf
		Next nV0U
		
		//V0V - Processo
		nV0VAdd := 1
		For nV0V := 1 to Len( aGravaV0V )
			If aGravaV0T[nV0T][1] == aGravaV0V[nV0V][1]
				oModel:GetModel( "MODEL_V0V" ):LVALID := .T.
				If nV0VAdd > 1
					oModel:GetModel( "MODEL_V0V" ):AddLine()
				EndIf
				oModel:LoadValue( "MODEL_V0V", "V0V_IDPROC", aGravaV0V[nV0V][2] )
				oModel:LoadValue( "MODEL_V0V", "V0V_TPPROC", aGravaV0V[nV0V][3] )
				oModel:LoadValue( "MODEL_V0V", "V0V_NRPROC", aGravaV0V[nV0V][4] )
				oModel:LoadValue( "MODEL_V0V", "V0V_CODSUS", aGravaV0V[nV0V][5] )
				oModel:LoadValue( "MODEL_V0V", "V0V_IDSUSP", aGravaV0V[nV0V][6] )
				oModel:LoadValue( "MODEL_V0V", "V0V_VALSUS", aGravaV0V[nV0V][7] )
				nV0VAdd++
			EndIf
		Next nV0V

	Next nV0T
		
	//*****************************************
	//Versão que será gravada no novo registro
	//*****************************************
	cVersao := xFunGetVer()

	//********************************************************************
	//ATENÇÃO
	//A alteração destes campos devem sempre estar abaixo do loop do For,
	//pois devem substituir as informações que foram armazenadas acima
	//********************************************************************
	oModel:LoadValue( "MODEL_V0S", "V0S_VERSAO"	, cVersao )
	oModel:LoadValue( "MODEL_V0S", "V0S_VERANT"	, cVerAnt )
	oModel:LoadValue( "MODEL_V0S", "V0S_PROTPN"	, cRecAnt )
	oModel:LoadValue( "MODEL_V0S", "V0S_PROTUL"	, "" )
	oModel:LoadValue( "MODEL_V0S", "V0S_EVENTO"	, "E" )
	oModel:LoadValue( "MODEL_V0S", "V0S_ATIVO"	, "1" )

	FWFormCommit( oModel )
	TAFAltStat( "V0S", "6" ) 
End Transaction

Return( .T. )
