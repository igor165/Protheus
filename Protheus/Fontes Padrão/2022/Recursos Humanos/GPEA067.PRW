#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GPEA067.CH'
#INCLUDE 'TopConn.CH'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ão    ³GPEA067   ³ Autor ³ Leandro Drumond                   ³ Data ³ 20/02/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definicao de Beneficios                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ FNC            ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Christiane V³08/04/2015³    PCREQ-2683  ³Criação dos campos para informar as verbas  ³±±
±±³            ³          ³                ³para pagamento/desconto do benefício.       ³±±
±±³            ³          ³                ³                                            ³±±
±±³Flavio C.   ³06/07/2015³TSROAD          ³Correção chave unica					    ³±±
±±³Gabriel A.  ³14/07/2016³TVKROM          ³Ajuste para que antes da montagem do browser³±±
±±³            ³          ³                ³/grid seja verificado se os registros da    ³±±
±±³            ³          ³                ³tabela S011 já foram vinculados.            ³±±
±±³Paulo O I   ³13/04/2017³DRHPAG-239      ³Melhoria -  remoção de dependencias do ctree³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPEA067()

Local aCampos	:= {}
Local aSeek		:= {}
Local oBrwTMP

Private oTmpTable := Nil
Private cAliasTmp := "TABAUX"

If !fCriaTmp(@aCampos,@aSeek)
	Return Nil
EndIf

oBrwTMP := FWmBrowse():New()
oBrwTMP:SetAlias( cAliasTmp )
oBrwTMP:SetFields(aCampos)
oBrwTMP:SetDescription(STR0001)	//"Definicao de Beneficios"
oBrwTMP:SetSeek(.T., aSeek)
oBrwTMP:DisableDetails()

oBrwTMP:Activate()

oTmpTable:Delete()

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MenuDef    ³ Autor ³ Marcelo Silveira      ³ Data ³31/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Menu Funcional                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE OemToAnsi(STR0003)  ACTION 'VIEWDEF.GPEA067' 	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE OemToAnsi(STR0004)  ACTION 'GPE067MNT()'	 	OPERATION 4 ACCESS 0 //"Manutenção"

Return( aRotina )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ModelDef    ³ Autor ³ Leandro Drumond       ³ Data ³20/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Modelo de dados e Regras de Preenchimento para a Definicao de ³±±
±±³          ³Outros Beneficios (RIS)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ModelDef()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ModelDef()

Local aAux			:= {}

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruTMP 		:= DefStrModel( )
Local oStruRIS 		:= FWFormStruct(1, 'RIS', /*bAvalCampo*/,/*lViewUsado*/)
Local oModel

// Blocos de codigo do modelo
Local bLinePos		:= {|oMdl| Gp067LinePos(oMdl)}

If Empty(oStruTMP)
	Return Nil
EndIf

//Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('GPEA067', /*bPreValid*/ , /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oStruRIS:SetProperty("RIS_FILIAL", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD,'xFilial("RIS")'))
oStruRIS:SetProperty("RIS_FUNCD", MODEL_FIELD_VALID, { |oModel| Gp67FunDVld(oModel) })
oStruRIS:SetProperty("RIS_TPDESC", MODEL_FIELD_VALID, { |oModel| Gp67TpDescVld(oModel) })

oStruRIS:SetProperty("RIS_EMP", MODEL_FIELD_WHEN, { |oModel| Gp67EmpWhen(oModel) })

//Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields('TMPMASTER', /*cOwner*/, oStruTMP, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)

//Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'RISDETAIL', 'TMPMASTER', oStruRIS, /*bLinePre*/, bLinePos, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

aAux := FwStruTrigger('RIS_PD','RIS_DESCPD','SRV->RV_DESC',.T.,'SRV',1,'xFilial("SRV",SRA->RA_FILIAL) + M->RIS_PD','.T.')
oStruRIS:AddTrigger( aAux[1] , aAux[2] , aAux[3] , aAux[4] )

aAux := FwStruTrigger('RIS_PD1','RIS_DESC1','SRV->RV_DESC',.T.,'SRV',1,'xFilial("SRV",SRA->RA_FILIAL) + M->RIS_PD1','.T.')
oStruRIS:AddTrigger( aAux[1] , aAux[2] , aAux[3] , aAux[4] )

aAux := FwStruTrigger('RIS_PD2','RIS_DESC2','SRV->RV_DESC',.T.,'SRV',1,'xFilial("SRV",SRA->RA_FILIAL) + M->RIS_PD2','.T.')
oStruRIS:AddTrigger( aAux[1] , aAux[2] , aAux[3] , aAux[4] )


//Faz relaciomaneto entre os compomentes do model
oModel:SetRelation('RISDETAIL', {{'RIS_TPBENE', 'TAB_COD'},{'RIS_FILIAL', 'xFilial("RIS")'}}, RIS->(IndexKey(1)))

oModel:GetModel('RISDETAIL'):SetUniqueLine({'RIS_FILIAL','RIS_TPBENE','RIS_COD','RIS_SALATE','RIS_SALMIN'})
oModel:SetPrimaryKey({'RIS_FILIAL','RIS_TPBENE','RIS_COD','RIS_SALATE','RIS_SALMIN'})

//Permite grid sem dados
oModel:GetModel('RISDETAIL'):SetOptional(.T.)

oModel:GetModel('TMPMASTER'):SetOnlyView(.T.)
oModel:GetModel('TMPMASTER'):SetOnlyQuery(.T.)

//Adiciona a descricao do Modelo de Dados
oModel:SetDescription(OemToAnsi(STR0001))  //"Definição de Beneficios"

Return( oModel )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ViewDef     ³ Autor ³ Leandro Drumond       ³ Data ³20/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Visualizador de dados da Definicao de Beneficios (RIS)        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ViewDef()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ViewDef()

Local oView

//Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel('GPEA067')

//Cria a estrutura a ser usada na View
Local oStruTMP := DefStrView()
Local oStruRIS := FWFormStruct(2, 'RIS')

//Cria o objeto de View
oView := FWFormView():New()

//Remove campos da estrutura e ajusta ordem dos campos na view
oStruRIS:RemoveField('RIS_TPBENE')

//Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_TMP', oStruTMP, 'TMPMASTER')

oStruTMP:SetNoFolder()

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid('VIEW_RIS', oStruRIS, 'RISDETAIL')

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 10)
oView:CreateHorizontalBox('INFERIOR', 90)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_TMP', 'SUPERIOR')
oView:SetOwnerView('VIEW_RIS', 'INFERIOR')

Return( oView )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³DefStrModel  	³ Autor ³ Leandro Drumond   ³ Data ³ 20.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta estrutura temporaria								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function DefStrModel( )

Local aArea    := GetArea()
Local bValid   := { || }
Local bWhen    := { || }
Local bRelac   := { || }

Local aCampos	:= {}
Local aSeek		:= {}

If type("cAliasTmp") == "U"

	Private cAliasTmp := "TABAUX"

	If !fCriaTmp(@aCampos,@aSeek)
		Return Nil
	EndIf

EndIf

oStruct := FWFormModelStruct():New()

//-------------------------------------------------------------------
// Tabela
//-------------------------------------------------------------------
oStruct:AddTable( 	cAliasTmp		               				, ;	// [01] Alias da tabela
					StrTokArr( "TAB_COD+TAB_FORN", ' + ' ) 		, ;	// [02] Array com os campos que correspondem a primary key
					STR0001 )               					// [03] Descrição da tabela


//-------------------------------------------------------------------
// Indices
//-------------------------------------------------------------------
oStruct:AddIndex( 	1	      						, ;     // [01] Ordem do indice
					"01"   							, ;     // [02] ID
					"TAB_COD+TAB_FORN"			    , ;     // [03] Chave do indice
					STR0007 + " + " + STR0009	 	, ;     // [04] Descrição do indice
					""       						, ;    	// [05] Expressão de lookUp dos campos de indice (SIX_F3)
					"" 								, ;    	// [06] Nickname do indice
					.T. )      								// [07] Indica se o indice pode ser utilizado pela interface

//-------------------------------------------------------------------
// Campos
//-------------------------------------------------------------------
				//Titulo ,ToolTip,Id do Field	,Tipo	,Tamanho		,Decimal,Valid,When	,Combo	,Obrigatorio	,Init	,Chave	,Altera	,Virtual
oStruct:AddField(STR0007,STR0007,'TAB_COD' 		,'C'	,2				,0		,Nil,Nil	,{}		,.F.			,Nil	,NIL	,NIL	,.F.)   //Codigo
oStruct:AddField(STR0008,STR0008,'TAB_DESC'		,'C'	,30				,0		,Nil,Nil	,{}		,.F.			,Nil	,NIL	,NIL	,.F.)	//Descricao
oStruct:AddField(STR0009,STR0009,'TAB_FORN'	 	,'C'	,3				,0		,Nil,Nil	,{}		,.F.			,Nil	,NIL	,NIL	,.F.)	//Fornecedor

RestArea( aArea )

Return oStruct

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³DefStrView  	³ Autor ³ Leandro Drumond   ³ Data ³ 20.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta estrutura temporaria								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DefStrView()
Local oStruct   := FWFormViewStruct():New()
               //Campo			,Ordem	,Titulo		,Descricao	,Help,Tipo 	,Picture               	,PictVar,F3,Editavel,Folder	,Group	,Combo	,Tam.Combo 	, Init. , Virtual
oStruct:AddField('TAB_COD'		,'01'	,STR0007	,STR0007	,NIL ,'C'	,'@!'					,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TAB_DESC'		,'02'	,STR0008	,STR0008	,NIL ,'C'	,'@!'					,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TAB_FORN'		,'03'	,STR0009	,STR0009	,NIL ,'C'	,'@!'					,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)

Return oStruct

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fCriaTmp    	³ Autor ³ Leandro Drumond   ³ Data ³ 20.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria arquivo temporario									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fCriaTmp(aCampos,aSeek)

Local aColumns	 := {}
Local aTabBenef	 := {}
Local cArqTmp	 := ""
Local lRet		 := .F.
Local nX		 := 0

If Select(cAliasTmp) > 0
	DbSelectArea(cAliasTmp)
	dbclosearea()
EndIf

Begin Sequence

	fCarrTab( @aTabBenef   , "S011", Nil)

	//Verifica se o benefício já está vinculado na tabela SRN ou RFO para não apresentar.
	If Len(aTabBenef) > 0
		fVerVinc(@aTabBenef)
	EndIf

	If Empty(aTabBenef)
		Help(,,STR0005,, STR0006, 1, 0 )  // "Nenhum tipo de beneficio foi cadastrado na tabela S011. Efetue o cadastramento." # "Atencao"
		Break
	EndIf

	lRet := .T.

	aAdd( aColumns, { "TAB_COD"		,"C",02,00 })
	aAdd( aColumns, { "TAB_DESC"	,"C",30,00 })
	aAdd( aColumns, { "TAB_FORN"	,"C",03,00 })

	aAdd( aCampos, { STR0007 , { || (cAliasTmp)->(TAB_COD)  } , "C" , "@!" , 0 , 02 , 0 , , , , , , , } )
	aAdd( aCampos, { STR0008 , { || (cAliasTmp)->(TAB_DESC) } , "C" , "@!" , 0 , 30 , 0 , , , , , , , } )
	aAdd( aCampos, { STR0009 , { || (cAliasTmp)->(TAB_FORN) } , "C" , "@!" , 0 , 03 , 0 , , , , , , , } )

	Aadd( aSeek, {STR0007, {{"","C",2,0,STR0007,}},1,.T. } )
	Aadd( aSeek, {STR0008, {{"","C",30,0,STR0008,}},2,.T. } )

	oTmpTable := FWTemporaryTable():New(cAliasTmp)
	oTmpTable:SetFields( aColumns )
	oTmpTable:AddIndex( "Codigo", {"TAB_COD"} )
	oTmpTable:AddIndex( "Descricao", {"TAB_DESC"} )
	oTmpTable:Create()

	DbSelectArea(cAliasTmp)

	For nX := 1 to Len(aTabBenef)
		lRet := .T.

		RecLock(cAliasTmp,.T.)

		(cAliasTmp)->TAB_COD 	:= aTabBenef[nX,5]
		(cAliasTmp)->TAB_DESC 	:= aTabBenef[nX,6]
		(cAliasTmp)->TAB_FORN 	:= aTabBenef[nX,7]

		MsUnLock()

	Next nX

End Sequence



Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Gp067LinePos	³ Autor ³ Leandro Drumond   ³ Data ³ 20.02.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³VALIDACAO DE LINHA										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Gp067LinePos(oGrid)
Local lRet		:= .T.

If Empty(oGrid:GetValue("RIS_SALATE")) .and. Empty(oGrid:GetValue("RIS_SALMIN"))
	Help(,,STR0005,, STR0010, 1, 0 )  // "Campo Salário Até deve ser informado." # "Atencao"
	lRet := .F.
ElseIf Empty(oGrid:GetValue("RIS_DESC"))
	Help(,,STR0005,, STR0011, 1, 0 )  // "Campo Descrição deve ser informado." # "Atencao"
	lRet := .F.
ElseIf Empty(oGrid:GetValue("RIS_TPREF"))
	Help(,,STR0005,, STR0012, 1, 0 )  // "Campo Tipo Ref. deve ser informado." # "Atencao"
	lRet := .F.
ElseIf Empty(oGrid:GetValue("RIS_REF"))
	Help(,,STR0005,, STR0013, 1, 0 )  // "Campo Referência deve ser informado." # "Atencao"
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Gp067SalWhen	³ Autor ³ Leandro Drumond   ³ Data ³ 23.04.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³When dos capos RIS_SALATE e RIS_SALMIN					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gp067SalWhen(nTipo)
Local lRet 		:= .F.
Local oModel 	:= FWModelActive()
Local oGrid 	:= oModel:GetModel('RISDETAIL')

If nTipo == 1 //Salario Ate
	If Empty(oGrid:GetValue("RIS_SALMIN"))
		lRet := .T.
	EndIf
Else
	If Empty(oGrid:GetValue("RIS_SALATE"))
		lRet := .T.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Gp67EmpWhen	³ Autor ³ Leandro Drumond   ³ Data ³ 29.05.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³When do campo RIS_EMP										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gp67EmpWhen(oGrid)
Local lRet		:= .F.

If oGrid:GetValue("RIS_TPDESC") == "1"
	lRet := .T.
Else
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Gp67TpDescVld	³ Autor ³ Leandro Drumond   ³ Data ³ 29.05.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valid do campo RIS_TPDESC									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gp67TpDescVld(oGrid)

cVar := &(ReadVar())

If cVar <> "1"
	oGrid:LoadValue("RIS_EMP", 0)
Else
	If oGrid:GetValue("RIS_FUNCD") > 0
		oGrid:LoadValue("RIS_EMP", 100 - oGrid:GetValue("RIS_FUNCD"))
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Gp67FunDVld	³ Autor ³ Leandro Drumond   ³ Data ³ 29.05.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valid do campo RIS_FUNCD              					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gp67FunDVld(oGrid)

Local nVar		:= &(ReadVar())

If oGrid:GetValue("RIS_TPDESC") == "1"
	oGrid:SetValue("RIS_EMP", 100 - nVar)
Else
	oGrid:LoadValue("RIS_EMP", 0)
EndIf

Return .T.


/*/{Protheus.doc} GPE067MNT
Rotina que permite realizar manutenção no benefício posicionado.
@type function
@author Victor Andrade
@since 20/04/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Function GPE067MNT()

Local cTitulo 	 := "Manutenção de Benefícios"
Local cPrograma	 := "GPEA067"
Local nOperation := MODEL_OPERATION_UPDATE
Local nRet  	 := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } , /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )

Return

/*/{Protheus.doc}fVerVinc
Função para eliminar as posições do array aTabBenef que já possuem vínculos na tabela SRN ou FRO.
@author Victor Andrade
@since 13/07/2016
@version 1.0
/*/
Function fVerVinc(aTabBenef)

	Local i 	 	:= 0
	Local aPosDel 	:= {}
	Local aBenef 	:= {}

	For i:= 1 To Len(aTabBenef)
		If !(fVerRFO(aTabBenef[i][5]) .Or. fVerSRN(aTabBenef[i][5]))
			Aadd(aBenef, aTabBenef[i])
		EndIf
	Next i

	aTabBenef := AClone(aBenef)

Return

/*/{Protheus.doc} fVerRFO
Função que retorna se há ou não registro vinculado na tabela RFO
@author Victor Andrade
@since 13/07/2016
/*/
Static Function fVerRFO(cCod)

	Local lRet 		 := .F.
	Local cQuery	 := ""
	Local cAliasRFO	 := "TMPRFO"

	cQuery := "SELECT RFO_CODIGO FROM " + RetSQLName("RFO") + " RFO "
	cQuery += "WHERE D_E_L_E_T_ = ' ' "
	cQuery += "AND RFO_TPBEN = '" + cCod + "' "
	cQuery += "AND RFO_FILIAL = '" + FWxFilial("RFO") + "' "

	If Select(cAliasRFO) > 0
		DbSelectArea(cAliasRFO)
		(cAliasRFO)->(DbCloseArea())
	EndIf

	TCQuery cQuery New Alias (cAliasRFO)

	(cAliasRFO)->(DbGoTop())

	If (cAliasRFO)->( !Eof() )
		lRet := .T.
	EndIf

Return(lRet)

/*/{Protheus.doc} fVerSRN
Função que retorna se há ou não registro vinculado na tabela SRN
@author Victor Andrade
@since 13/07/2016
@version 1.0
/*/
Static Function fVerSRN(cCod)

	Local lRet 		 := .F.
	Local cQuery	 := ""
	Local cAliasSRN	 := "TMPSRN"

	cQuery := "SELECT RN_COD FROM " + RetSQLName("SRN") + " SRN "
	cQuery += "WHERE D_E_L_E_T_ = ' ' "
	cQuery += "AND RN_TPBEN = '" + cCod + "' "
	cQuery += "AND RN_FILIAL = '" + FWxFilial("SRN") + "' "

	If Select(cAliasSRN) > 0
		DbSelectArea(cAliasSRN)
		(cAliasSRN)->(DbCloseArea())
	EndIf

	TCQuery cQuery New Alias (cAliasSRN)

	(cAliasSRN)->(DbGoTop())

	If (cAliasSRN)->( !Eof() )
		lRet := .T.
	EndIf

Return(lRet)
