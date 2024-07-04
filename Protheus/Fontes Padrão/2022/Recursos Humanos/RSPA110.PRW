#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RSPA110.CH"

Static cAliasTmp 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RSPA110  ³ Autor ³ Leandro Drumond       ³ Data ³ 02.10.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Fatores e Graduacao das Avaliacoes             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RSPA110()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA110                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ FNC  ³  Motivo da Alteracao                     ³±±
±±³Oswaldo L.  ³11/05/17³DHRPONTP10³Ajuste ctree Porjeto SOYUZ   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RSPA110()
Local cFiltra	:= ""	//Variavel para filtro
Local oMBrowse
Private oTmp

//Cria arquivo temporario
fCriaTMP()

oMBrowse := FWMBrowse():New()

oMBrowse:SetAlias("SQ0")
oMBrowse:SetDescription(OemToAnsi(STR0006)) //"Fatores de Avaliacao e Graduacao dos Fatores"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltra 	:= CHKRH(FunName(),"SQ0","1")

oMBrowse:SetFilterDefault( cFiltra )

oMBrowse:Activate()

fDelTMP( cAliasTMP )

Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Leandro Drumond  ³ Data ³02/10/2014³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Criacao do Menu do Browse.                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³RSPA110                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0001  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar'
	ADD OPTION aRotina TITLE STR0002  ACTION "VIEWDEF.RSPA110" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE STR0022  ACTION "VIEWDEF.RSPA110" 		OPERATION 4 ACCESS 0				//'Manutenção'
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.RSPA110" 		OPERATION 5 ACCESS 0				//'Excluir'

Return aRotina

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ ModelDef 		³Autor³  Leandro Drumond  ³ Data ³02/10/2014³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Regras de Modelagem da gravacao.                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³RSPA110                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function ModelDef()

Local oModel
Local oStructSQ0
Local oStructSQ1
Local oStructTMP

Local bValActivate 	:= { || fLoadTMP() }

// Criacao do Objeto de Modelagem de dados da tabela RFC //
oModel:= MPFormModel():New("RSPA110", NIL, NIL, {|oModel| RSP110Commit(oModel)})
oModel:SetDescription( OemToAnsi(STR0006) ) //"Fatores de Avaliacao e Graduacao dos Fatores"


// Estrutura de campos do Model //
oStructSQ0 := FWFormStruct(1, "SQ0",,.F.)
oModel:AddFields("RSPA_MSQ0", NIL, oStructSQ0)
oModel:GetModel( "RSPA_MSQ0" ):SetOnlyQuery(.T.)
oModel:GetModel( "RSPA_MSQ0" ):SetOnlyView(.T.)

oStructSQ1	:= FWFormStruct(1, "SQ1",,.F.)
FWMemoVirtual( oStructSQ1,{ { 'Q1_DESCDET' , 'Q1_MEMO1' } } )
oModel:AddGrid("RSPA_MSQ1", "RSPA_MSQ0", oStructSQ1,/*bLinePre*/, {|oModel|SQ1LinhaOk()}/* bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation( "RSPA_MSQ1", { { "Q1_FILIAL", "xFilial('SQ1')" } , { "Q1_GRUPO", "SQ0->Q0_GRUPO" } }, SQ1->( IndexKey( 1 ) ) )
oModel:GetModel("RSPA_MSQ1"):SetUniqueLine({'Q1_FILIAL','Q1_FATOR'})
oStructSQ1:SetProperty( "Q1_FATOR", MODEL_FIELD_WHEN, { |oGrid| oGrid:IsInserted() } )

If cAliasTMP == Nil
	fCriaTMP()
EndIf

oStructTMP := DefStrModel( cAliasTMP )
oModel:AddGrid("RSPA_MTMP", "RSPA_MSQ1", oStructTMP,/*bLinePre*/, {|oModel|TMPLinhaOk()}/* bLinePost*/, /*bPre*/,  /*bPost*/,  bValActivate/* bLoad*/    )
oModel:SetRelation( "RSPA_MTMP", { { "TMP_FILIAL", "xFilial('SQ1')" } , { "TMP_GRUPO", "Q1_GRUPO" } , { "TMP_FATOR", "Q1_FATOR"  }}, (cAliasTMP)->( IndexKey( 1 ) ) )
oModel:GetModel( "RSPA_MTMP" ):SetOptional(.T.)
oModel:GetModel( "RSPA_MTMP" ):SetNoInsertLine(.T.)
oModel:GetModel( "RSPA_MTMP" ):SetNoDeleteLine(.T.)
oModel:GetModel( "RSPA_MTMP" ):SetOnlyQuery(.T.)


//Inclusão de estrutura para que permita a exclusão do SQ1 sem validar o relacionamento com SQ2 do SX9. Não será exibido na tela.
oStructSQ2	:= FWFormStruct(1, "SQ2")
oModel:AddGrid("RSPA_MSQ2", "RSPA_MSQ1", oStructSQ2,/*bLinePre*/,/* bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation( "RSPA_MSQ2", { { "Q2_FILIAL", "xFilial('SQ2')" } , { "Q2_GRUPO", "Q1_GRUPO" } , { "Q2_FATOR", "Q1_FATOR"  }}, SQ2->( IndexKey( 1 ) ) )
oModel:GetModel( "RSPA_MSQ2" ):SetOnlyQuery(.T.)
oModel:GetModel( "RSPA_MSQ2" ):SetOptional(.T.)

Return( oModel )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ ViewDef  		³Autor³  Leandro Drumond  ³ Data ³02/10/2014³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Regras de Interface com o Usuario                           ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³RSPA110                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function ViewDef()

Local oView
Local oModel
Local oStructSQ0
Local oStructSQ1
Local oStructTMP

oModel := FWLoadModel("RSPA110")

oView := FWFormView():New()
oView:SetModel(oModel)

oStructSQ0 := FWFormStruct(2, "SQ0",,.F.)
oStructSQ0:SetNoFolder()
oView:AddField("RSPA_VSQ0", oStructSQ0, "RSPA_MSQ0" )
oStructSQ0:RemoveField( "Q0_FILIAL" )

oStructSQ1 := FWFormStruct(2, "SQ1",,.F.)
oView:AddGrid("RSPA_VSQ1", oStructSQ1, "RSPA_MSQ1" )
oStructSQ1:RemoveField( "Q1_FILIAL" )
oStructSQ1:RemoveField( "Q1_GRUPO" )
oStructSQ1:RemoveField( "Q1_DESCDET" )

If cModulo == "RSP"
	oStructSQ1:RemoveField( "Q1_PERCFAT" )
	oStructSQ1:RemoveField( "Q1_PMIN" )
	oStructSQ1:RemoveField( "Q1_PMAX" )
EndIf

oStructTMP := DefStrView()
oView:AddGrid("RSPA_VTMP", oStructTMP, "RSPA_MTMP" )
oStructTMP:RemoveField( "TMP_FILIAL" )
oStructTMP:RemoveField( "TMP_FATOR" )
oStructTMP:RemoveField( "TMP_GRUPO" )

// Desenho da Tela //
oView:CreateHorizontalBox("SQ0_HEAD", 15)
oView:CreateHorizontalBox("SQ1_GRID", 42)
oView:CreateHorizontalBox("TMP_GRID", 42)

oView:SetOwnerView( "RSPA_VSQ0", "SQ0_HEAD" )
oView:SetOwnerView( "RSPA_VSQ1", "SQ1_GRID" )
oView:SetOwnerView( "RSPA_VTMP", "TMP_GRID" )

oView:EnableTitleView( "RSPA_VSQ1", OemToAnsi(STR0007) ) //"Fatores Avaliação"
oView:EnableTitleView( "RSPA_VTMP", OemToAnsi(STR0008) ) //"Graduação Fatores"

oView:SetCloseOnOk({ || .T. })		//Apos COMMIT gravacao fecha a tela

Return oView

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ DefStrModel	³Autor³  Leandro Drumond  ³ Data ³02/10/2014³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Monta estrutura temporaria							      	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³RSPA110                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function DefStrModel( cAlias )

Local aArea    := GetArea()
Local bValid   := { || }
Local bWhen    := { || }
Local bRelac   := { || }

oStruct := FWFormModelStruct():New()

//-------------------------------------------------------------------
// Tabela
//-------------------------------------------------------------------
oStruct:AddTable( 	cAlias		                					, ;	// [01] Alias da tabela
					StrTokArr( "TMP_FILIAL+TMP_GRUPO+TMP_FATOR+TMP_GRAU", ' + ' ) 	, ;	// [02] Array com os campos que correspondem a primary key
					STR0008		 )               					// [03] Descrição da tabela #GRADUACAO FATORES


//-------------------------------------------------------------------
// Indices
//-------------------------------------------------------------------
oStruct:AddIndex( 	1	      						, ;     // [01] Ordem do indice
					"01"   							, ;     // [02] ID
					"TMP_FILIAL+TMP_GRUPO+TMP_FATOR+TMP_GRAU", ;     // [03] Chave do indice
					STR0023				 			, ;     // [04] Descrição do indice ### "Filial+Grupo+Fator"
					""       						, ;    	// [05] Expressão de lookUp dos campos de indice (SIX_F3)
					"" 								, ;    	// [06] Nickname do indice
					.T. )      								// [07] Indica se o indice pode ser utilizado pela interface

//-------------------------------------------------------------------
// Campos
//-------------------------------------------------------------------
bValid := { |A,B,C,D| FwInitCpo(A,B,C), lRetorno := .T., FwCloseCpo( A, B, C, lRetorno ), lRetorno }

bWhen  := NIL
bRelac := NIL
				//Titulo 							  ,ToolTip								,Id do Field	,Tipo	,Tamanho		,Decimal ,Valid,When	 ,Combo	,Obrigatorio	,Init	,Chave	,Altera	,Virtual
oStruct:AddField(GetSX3Cache("QN_FILIAL","X3_TITULO") ,GetSX3Cache("QN_FILIAL","X3_TITULO") ,'TMP_FILIAL'	,'C'	,FWGETTAMFILIAL ,0		 ,bValid,bWhen	 ,{}		,.F.	,bRelac	,NIL	,NIL	,.F.)	//Filial
oStruct:AddField(GetSX3Cache("QN_GRUPO","X3_TITULO")  ,GetSX3Cache("QN_GRUPO","X3_TITULO")	,'TMP_GRUPO'	,'C'	,2				,0		 ,bValid,bWhen	 ,{}		,.F.	,bRelac	,NIL	,NIL	,.F.)	//Matricula
oStruct:AddField(GetSX3Cache("QN_FATOR","X3_TITULO")  ,GetSX3Cache("QN_FATOR","X3_TITULO")	,'TMP_FATOR'	,'C'	,2				,0		 ,bValid,bWhen	 ,{}		,.F.	,bRelac	,NIL	,NIL	,.F.)	//Complemento
oStruct:AddField(GetSX3Cache("QV_GRAU","X3_TITULO")   ,GetSX3Cache("QV_GRAU","X3_TITULO")	,'TMP_GRAU'		,'C'	,2				,0		 ,bValid,{||.F.} ,{}		,.F.	,bRelac	,NIL	,NIL	,.F.)	//Descricao
oStruct:AddField(GetSX3Cache("QV_DESCGRA","X3_TITULO"),GetSX3Cache("QV_DESCGRA","X3_TITULO"),'TMP_DESCGR'	,'C'	,100			,0		 ,bValid,bWhen	 ,{}		,.F.	,bRelac	,NIL	,NIL	,.F.)	//Processo
oStruct:AddField(GetSX3Cache("QN_DE","X3_TITULO")     ,GetSX3Cache("QN_DE","X3_TITULO")	    ,'TMP_DE'		,'C'	,4				,0		 ,bValid,bWhen	 ,{}		,.F.	,bRelac	,NIL	,NIL	,.F.)	//Mes/Ano Inicial
oStruct:AddField(GetSX3Cache("QN_ATE","X3_TITULO")    ,GetSX3Cache("QN_ATE","X3_TITULO")	,'TMP_ATE'		,'C'	,4				,0		 ,bValid,bWhen	 ,{}		,.F.	,bRelac	,NIL	,NIL	,.F.)	//Mes/Ano Final
oStruct:AddField(GetSX3Cache("Q2_PONTOSI","X3_TITULO"),GetSX3Cache("Q2_PONTOSI","X3_TITULO"),'TMP_PONTOI'	,'N'	,7				,3		 ,bValid,bWhen	 ,{}		,.F.	,bRelac	,NIL	,NIL	,.F.)	//Pontos Inicial

RestArea( aArea )

Return oStruct

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ DefStrView		³Autor³  Leandro Drumond  ³ Data ³02/10/2014³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Monta estrutura temporaria							      	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³RSPA110                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function DefStrView()
Local oStruct   := FWFormViewStruct():New()
               //Campo			,Ordem	,Titulo								  ,Descricao							 ,Help	,Tipo	,Picture		,PictVar, F3, Editavel,Folder	,Group	,Combo	,Tam.Combo 	, Init. , Virtual
oStruct:AddField('TMP_FILIAL'	,'01'	,GetSX3Cache("QN_FILIAL","X3_TITULO") ,GetSX3Cache("QN_FILIAL","X3_TITULO")	 ,NIL 	,'C'	,'@!'			,NIL	, '', .F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_GRUPO'	,'02'	,GetSX3Cache("QN_GRUPO","X3_TITULO")  ,GetSX3Cache("QN_GRUPO","X3_TITULO")	 ,NIL 	,'C'	,'99'			,NIL	, '', .F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_FATOR'	,'03'	,GetSX3Cache("QN_FATOR","X3_TITULO")  ,GetSX3Cache("QN_FATOR","X3_TITULO")	 ,NIL 	,'C'	,'@!'			,NIL	, '', .F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_GRAU'		,'04'	,GetSX3Cache("QV_GRAU","X3_TITULO")   ,GetSX3Cache("QV_GRAU","X3_TITULO")	 ,NIL 	,'C'	,'@!'			,NIL	, '', .F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_DESCGR'	,'05'	,GetSX3Cache("QV_DESCGRA","X3_TITULO"),GetSX3Cache("QV_DESCGRA","X3_TITULO") ,NIL 	,'C'	,'@!'			,NIL	, '', .T.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_DE'		,'06'	,GetSX3Cache("QN_DE","X3_TITULO")     ,GetSX3Cache("QN_DE","X3_TITULO")		 ,NIL 	,'C'	,'99.9'			,NIL	, '', .T.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_ATE'		,'07'	,GetSX3Cache("QN_ATE","X3_TITULO")    ,GetSX3Cache("QN_ATE","X3_TITULO")	 ,NIL 	,'C'	,'99.9'			,NIL	, '', .T.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TMP_PONTOI'	,'08'	,GetSX3Cache("Q2_PONTOSI","X3_TITULO"),GetSX3Cache("Q2_PONTOSI","X3_TITULO") ,NIL 	,'N'	,'@E 999.999'	,NIL	, '', .T.		,''		,''		,{}		,0			,''		,.F.)

Return oStruct

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fCriaTMP  		³Autor³  Leandro Drumond  ³ Data ³02/10/2014³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Cria o arquivo temporario							      	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³RSPA110                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fCriaTMP()
Local aArea     := GetArea()
Local aCampos   := {}
Local cIndTemp	:= ""
Local cTrab		:= ""

cAliasTMP	:= GetNextAlias()

aAdd( aCampos, { 'TMP_FILIAL'		, "C", FWGETTAMFILIAL	, 0 } )
aAdd( aCampos, { 'TMP_GRUPO'		, "C", 2	, 0 } )
aAdd( aCampos, { 'TMP_FATOR'		, "C", 2	, 0 } )
aAdd( aCampos, { 'TMP_GRAU'			, "C", 2	, 0 } )
aAdd( aCampos, { 'TMP_DESCGR'		, "C", 100	, 0 } )
aAdd( aCampos, { 'TMP_DE'			, "C", 4	, 0 } )
aAdd( aCampos, { 'TMP_ATE'			, "C", 4	, 0 } )
aAdd( aCampos, { 'TMP_PONTOI'		, "N", 7	, 3 } )

If Select(cAliasTMP)>0
	dbSelectArea(cAliasTMP)
	dbCloseArea()
EndIf

oTmp := FWTemporaryTable():New(cAliasTMP,aCampos)
oTmp:AddIndex( "TRPINDT1", {"TMP_FILIAL","TMP_GRUPO","TMP_FATOR","TMP_GRAU"} )
oTmp:Create()



RestArea( aArea )

Return Nil

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fLoadTMP  		³Autor³  Leandro Drumond  ³ Data ³02/10/2014³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Carrega dados da RF1      							      	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³RSPA110                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fLoadTMP()
Local aStruct := {}
Local nMeuRecno := 0
Local cKeySQN 	:= xFilial("SQN") + SQ0->Q0_GRUPO
Local cFilSQ2	:= xFilial("SQ2")
Local oModel 	:= FwModelActive()
Local oGrid		:= IIf(ValType(oModel) <> "U", oModel:GetModel("RSPA_MSQ1"), Nil)
cKeySQN += IIf(ValType(oGrid) <> "U", oGrid:GetValue("Q1_FATOR"), "")
Private aLstDados := {}

If Select(cAliasTmp)>0
	dbSelectArea(cAliasTmp)
	ZAP
EndIf

DbSelectArea("SQ2")
DbSetOrder(1) //Q2_FILIAL+Q2_GRUPO+Q2_FATOR+Q2_GRAU

DbSelectArea("SQN")
DbSetOrder(1) //QN_FILIAL+QN_GRUPO+QN_FATOR+QN_GRAU

DbSelectArea(cAliasTmp)

If SQN->(DbSeek(cKeySQN))
	While SQN->( !Eof()) .and. SQN->( QN_FILIAL + QN_GRUPO + QN_FATOR) == cKeySQN

		SQ2->(DbSeek(cFilSQ2 + SQN->QN_GRUPO + SQN->QN_FATOR + SQN->QN_GRAU))

		Reclock( cAliasTmp, .T.)
		(cAliasTmp)->TMP_FILIAL	:= xFilial("SQN")
		(cAliasTmp)->TMP_GRUPO 	:= SQ0->Q0_GRUPO
		(cAliasTmp)->TMP_FATOR 	:= SQN->QN_FATOR
		(cAliasTmp)->TMP_GRAU	:= SQN->QN_GRAU
		(cAliasTmp)->TMP_DESCGR	:= SQ2->Q2_DESC
		(cAliasTmp)->TMP_DE	 	:= SQN->QN_DE
		(cAliasTmp)->TMP_ATE 	:= SQN->QN_ATE
		(cAliasTmp)->TMP_PONTOI	:= SQ2->Q2_PONTOSI
		MsUnLock()

		aStruct := {(cAliasTmp)->TMP_FILIAL, (cAliasTmp)->TMP_GRUPO,(cAliasTmp)->TMP_FATOR, (cAliasTmp)->TMP_GRAU, (cAliasTmp)->TMP_DESCGR,(cAliasTmp)->TMP_DE, (cAliasTmp)->TMP_ATE,(cAliasTmp)->TMP_PONTOI }
		nMeuRecno := (cAliasTmp)->(Recno())
		Aadd (aLstDados, {nMeuRecno,aStruct} )


		SQN->(DbSkip())
	EndDo
EndIf

Return aLstDados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ SQ1LinhaOk ³ Autor ³ Leandro Drumond     ³ Data ³ 02.10.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da linha da getdados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SQ1LinhaOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA110  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SQ1LinhaOk()
Local lRet      := .T.
Local nLinAtual	:= 0
Local nPos		:= 0
Local nPerct	:= 0
Local oModel	:= FwModelActive()
Local oGrid		:= oModel:GetModel("RSPA_MSQ1")

Begin Sequence

	If !(oGrid:IsDeleted())

		If 	Empty(oGrid:GetValue("Q1_DESCSUM"))
			 Help(" ",1,"A110VZ1")		// Verifique o campo de Descricao Sumaria
			 lRet := .F.				// nao pode estar vazio.
			 Break
		EndIf

		nLinAtual := oGrid:GetLine()
		cFator	  := oGrid:GetValue("Q1_FATOR")
		nPerct	  := 0
		For nPos:= 1 to oGrid:Length()
			If nPos <> nLinAtual
				oGrid:Goline(nPos)
				If oGrid:IsDeleted()
					Loop
				EndIf
				If	oGrid:GetValue("Q1_FATOR") == cFator
					Help(" ",1,"A110IGUAL")		// Existem fatores com o mesmo codigo
					lRet := .F.
					Break
				EndIf
				If cModulo <> "RSP"	//Condicao abaixo verificada apenas no SIGACSA e SIGARSP
					nPerct	:=  nPerct + oGrid:GetValue("Q1_PERCFAT")
					If nPerct > 100
						Help(,,STR0013,, STR0020,1,0 ) //"Atencao"###"A soma do percentual dos pontos dos fatores deve ser igual a 100%."
						lRet := .F.
						Break
					EndIf
				EndIf
			EndIf
		Next nPos
		oGrid:GoLine(nLinAtual)
	EndIf

End Sequence

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMPLinhaOk() ³ Autor ³ Leandro Drumond   ³ Data ³ 02.10.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da linha da getdados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMPLinhaOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA110  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMPLinhaOk()
Local oModel	:= FwModelActive()
Local oGrid		:= oModel:GetModel("RSPA_MTMP")

If !Empty(oGrid:GetValue("TMP_DE")) .and. Val(oGrid:GetValue("TMP_ATE")) < Val(oGrid:GetValue("TMP_DE"))
	Help(,,STR0013,, STR0017,1,0 ) //"Atencao"###'O Campo "Ate" nao pode ser menor que o Campo "De"'
	Return .F.
EndIf

Return .T.

Static Function TMPLinhaPre()
Local oModel	:= FwModelActive()
Local oGrid		:= oModel:GetModel("RSPA_MSQ1")

SQ1->(dbSeek(oGrid:GetValue("Q1_FILIAL")+oGrid:GetValue("Q1_GRUPO")+oGrid:GetValue("Q1_FATOR")))

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun!o    ³ A110DeAte³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri!o ³ Valida os campo de QN_DE e QN_ATE                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A110DeAte()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA110  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A110DeAte()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ Rs110Desc        ³ Autor ³ Cristina Ogura³ Data ³ 04.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri!&o ³ Traz a descricao do fator                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Rs110Desc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA110       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs110Desc(nQual)
Local lRet 		:= .T.
Local aSaveArea	:= GetArea()
Local cVar		:= &(ReadVar())
Local cGrupo	:= ""
Local nLinAux	:= 0
Local nLinAtual	:= 0
Local nPos		:= 0
Local oModel
Local oGridSQ1
Local oGridTMP

If nQual == 1


	oModel		:= FwModelActive()
	oGridSQ1	:= oModel:GetModel("RSPA_MSQ1")
	oGridTMP	:= oModel:GetModel("RSPA_MTMP")
	cGrupo		:= oModel:GetModel("RSPA_MSQ0"):GetValue("Q0_GRUPO")


	nLinAtual := oGridSQ1:GetLine()
	For nPos:= 1 to oGridSQ1:Length()
		If nPos <> nLinAtual
			oGridSQ1:Goline(nPos)
			If oGridSQ1:IsDeleted()
				Loop
			EndIf
			If	oGridSQ1:GetValue("Q1_FATOR") == cVar
				Help(" ",1,"A110IGUAL")		// Existem fatores com o mesmo codigo
				oGridSQ1:GoLine(nLinAtual)
				Return(.F.)
			EndIf
		EndIf
	Next nPos


	oGridSQ1:GoLine(nLinAtual)

	SQN->(dbSetOrder(1)) //QN_FILIAL+QN_GRUPO+QN_FATOR+QN_GRAU
	SQV->(dbSetOrder(1)) //QV_FILIAL+QV_FATOR+QV_GRAU

	If 	SQV->(dbSeek(xFilial("SQV") + cVar))
		// Retorna Descricao do Fator
		oGridSQ1:LoadValue("Q1_DESCSUM",Alltrim(SQV->QV_DESCFAT))
		oGridSQ1:LoadValue("Q1_GRUPO",cGrupo)

		While SQV->(!Eof() .and. QV_FILIAL + QV_FATOR == xFilial("SQV")+cVar )

			nLinAux++
			If nLinAux > 1
				oGridTMP:AddLine(.T.)
				oGridTMP:GoLine(nLinAux)
			EndIf
			oGridTMP:LoadValue("TMP_FILIAL",SQV->QV_FILIAL)
			oGridTMP:LoadValue("TMP_FATOR",SQV->QV_FATOR)
			oGridTMP:LoadValue("TMP_GRAU",SQV->QV_GRAU)
			oGridTMP:LoadValue("TMP_DESCGR",SQV->QV_DESCGRA)
			oGridTMP:LoadValue("TMP_GRUPO",cGrupo)
			If SQN->(DbSeek(xFilial("SQN")+cGrupo+cVar+SQV->QV_GRAU))
				oGridTMP:LoadValue("TMP_DE",SQN->QN_DE)
				oGridTMP:LoadValue("TMP_ATE",SQN->QN_ATE)
			EndIf
			oGridTMP:LoadValue("TMP_PONTOI",SQ2->Q2_PONTOSI)

			SQV->(DbSkip())
		EndDo

		oGridTMP:GoLine(1)
	EndIf
EndIf


RestArea(aSaveArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ Rs110NPode       ³ Autor ³ Cristina Ogura³ Data ³ 04.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri!&o ³ Funcao que trata alteracao nos campos Q1_DESCSUM e Q2_DESC ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Rs110RetD()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA110       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs110NPode()
	Help(" ", 1, "Rs110NPODE")
Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun!o    ³ A110Grau ³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri!o ³ Valida o grau da avaliacao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A110Grau()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA110  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A110Grau()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ Rs110Pto         ³ Autor ³ Emerson Grassi³ Data ³ 06/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula Pontuacao Minima e Maxima do Fator.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Rs110Pto()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA110       ³ USADO NO VALIDADOR DE CAMPO                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs110Pto(nCampo)

Local nPtos		:= 0
Local oModel

If nCampo == 1

	oModel	:= FwModelActive()

	oGrid	:= oModel:GetModel("RSPA_MSQ1")

	// Calcula Ponto Minimo
	oGrid:LoadValue("Q1_PMIN",SQ0->Q0_PMIN * oGrid:GetValue("Q1_PERCFAT") / 100)

	// Calcula Ponto Maximo
	oGrid:LoadValue("Q1_PMAX",SQ0->Q0_PMAX * oGrid:GetValue("Q1_PERCFAT") / 100)

	Return .T.

ElseIf nCampo == 2			//Q1_PMIN

	nPtos := SQ0->Q0_PMIN * SQ1->Q1_PERCFAT / 100

	Return( nPtos )

ElseIf nCampo == 3			//Q1_PMAX
	nPtos := SQ0->Q0_PMAX * SQ1->Q1_PERCFAT / 100

	Return( nPtos )

EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ RSP110Commit    ³ Autor ³ Leandro Drumond³ Data ³ 02/10/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua gravacao dos dados                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ RSP110Commit()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA110       ³ USADO NO VALIDADOR DE CAMPO                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RSP110Commit(oModel)
Local nOperation := oModel:GetOperation()
Local oGridSQ1	 := oModel:GetModel("RSPA_MSQ1")
Local oGridTMP	 := oModel:GetModel("RSPA_MTMP")
Local nLinSQ1	 := oGridSQ1:GetLine()
Local nX := 0
Local nY := 0

DbSelectArea("SQV")
DbSetOrder(1)//QV_FILIAL+QV_FATOR+QV_GRAU
DbSelectArea("SQN")
DbSetOrder(1)//QN_FILIAL+QN_GRUPO+QN_FATOR+QN_GRAU
DbSelectArea("SQ2")
DbSetOrder(1) //Q2_FILIAL+Q2_GRUPO+Q2_FATOR+Q2_GRAU

For nX := 1 to oGridSQ1:Length()
	oGridSQ1:GoLine(nX)
	For nY := 1 to oGridTMP:Length()
		oGridTMP:GoLine(nY)
		If nOperation == MODEL_OPERATION_UPDATE .And. (oGridTMP:IsInserted() .Or. oGridTMP:IsUpdated()) .And. !oGridSQ1:IsDeleted() .And. !Empty(oGridTMP:GetValue("TMP_FATOR"))
			If SQN->(DbSeek(oGridTMP:GetValue("TMP_FILIAL")+oGridTMP:GetValue("TMP_GRUPO")+oGridTMP:GetValue("TMP_FATOR")+oGridTMP:GetValue("TMP_GRAU")))
				RecLock("SQN",.F.)
			Else
				RecLock("SQN",.T.)
				SQN->QN_FILIAL 	:= xFilial("SQN")
				SQN->QN_FATOR	:= oGridTMP:GetValue("TMP_FATOR")
				SQN->QN_GRAU	:= oGridTMP:GetValue("TMP_GRAU")
				SQN->QN_GRUPO	:= oGridTMP:GetValue("TMP_GRUPO")
			EndIf
			SQN->QN_DE  := oGridTMP:GetValue("TMP_DE")
			SQN->QN_ATE := oGridTMP:GetValue("TMP_ATE")
			MsUnLock()

			If SQ2->(DbSeek(oGridTMP:GetValue("TMP_FILIAL")+oGridTMP:GetValue("TMP_GRUPO")+oGridTMP:GetValue("TMP_FATOR")+oGridTMP:GetValue("TMP_GRAU")))
				RecLock("SQ2",.F.)
			Else
				RecLock("SQ2",.T.)
				SQ2->Q2_FILIAL 	:= xFilial("SQ2")
				SQ2->Q2_FATOR	:= oGridTMP:GetValue("TMP_FATOR")
				SQ2->Q2_GRAU	:= oGridTMP:GetValue("TMP_GRAU")
				SQ2->Q2_GRUPO	:= oGridTMP:GetValue("TMP_GRUPO")
			EndIf
			SQ2->Q2_PONTOSI	:= oGridTMP:GetValue("TMP_PONTOI")
			SQ2->Q2_DESC		:= oGridTMP:GetValue("TMP_DESCGR")
			MsUnLock()

		ElseIf (oGridTMP:IsDeleted() .or. oGridSQ1:IsDeleted()) .Or. nOperation == MODEL_OPERATION_DELETE
			If SQN->(DbSeek(oGridTMP:GetValue("TMP_FILIAL")+oGridTMP:GetValue("TMP_GRUPO")+oGridTMP:GetValue("TMP_FATOR")+oGridTMP:GetValue("TMP_GRAU")))
				RecLock("SQN",.F.)
				DbDelete()
				MsUnLock()
			EndIf

			If SQ2->(DbSeek(oGridTMP:GetValue("TMP_FILIAL")+oGridTMP:GetValue("TMP_GRUPO")+oGridTMP:GetValue("TMP_FATOR")+oGridTMP:GetValue("TMP_GRAU")))
				RecLock("SQ2",.F.)
				DbDelete()
				MsUnLock()
			EndIf
		EndIf
	Next nY
Next nX

OGridSQ1:GoLine(nLinSQ1)

FWFormCommit(oModel)

Return .T.

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fDelTMP   		³Autor³  Leandro Drumond  ³ Data ³02/10/2014³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Exclui o arquivo temporario							      	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³RSPA110                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fDelTMP(cAlias)
Local aArea := GetArea()

If Select(cAlias)>0
	dbSelectArea(cAlias)
	dbCloseArea()
EndIf

If oTmp <> Nil
	oTmp:Delete()
	Freeobj(oTmp)
EndIf

RestArea(aArea)

Return .T.


