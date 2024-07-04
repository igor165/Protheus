#include "GPEA051.CH"
#Include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
#DEFINE Confirma 1
#DEFINE Redigita 2
#DEFINE Abandona 3

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ GPEA051  ³ Autor  ³ Equipe MP                           ³ Data ³ 12/11/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Cadastro de Periodos Aquisitos                              			     	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEA051()                                                   					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                      				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                		    	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³Fabricio   ³ Nov/2013 ³M_RH001/REQ.	 	³- Ajustes gerais para atender as regras        ³±±
±±³Amaro      ³          ³       		 	³  conforme tabela S106, S107 e também          ³±±
±±³           ³          ³       		 	³  a chamada pela rotina TCFA040                ³±±
±±³Everson    ³ Dez/2013 ³M_RH001/REQ.002088³- Ajustes gerais para grava RG1 para           ³±±
±±³			  ³			 ³	                ³  Licença Premio                               ³±±
±±³Fabricio   ³10/12/2013³M_RH001/REQ.	 	³- Gravação da SRH quando a verba for do        ³±±
±±³Amaro      ³          ³       		 	³  ID 0072 e o regime 2=Estatutário	            ³±±
±±³Ademar Jr. ³27/03/2014³Prj.M_RH001	 	³- Ajuste para buscar a Dt.Admissao qdo for     ³±±
±±³           ³          ³Req.002103	 	³  incluir o 1o. Dias de Direito de Ferias.     ³±±
±±³Tania      ³13/05/2014³PRJ. M_RH001	 	³- Limitação da Indenização de Férias de        ³±±
±±³Bronzeri   ³          ³Gap.002092-12 	³  Membros.                                     ³±±
±±³Ademar Jr. ³11/09/2014³Proj.M_RH001      ³GSP-Ajuste para nao validar a Data de Pagto.   ³±±
±±³           ³          ³                  ³  de Gozo e de Indenizado quando a RIA foi     ³±±
±±³           ³          ³                  ³  criada a partir do PORTAL.                   ³±±
±±³Marcos Pere³22/10/2014³Proj.M_RH001      ³GSP-Ajustes diversos para tratamentos em       ³±±
±±³           ³          ³                  ³  programacao, cancelamento e refificação de   ³±±
±±³           ³          ³                  ³  gozo remanescente                            ³±±
±±³Marcos Pere³12/12/2014³000000442162014   ³- Validacao do Saldo na SRF quando estiver for ³±±
±±³           ³          ³                  ³efetivacao do portal, para nao pemitir program.³±±
±±³           ³          ³                  ³maior que saldo disponivel.                    ³±±
±±³           ³          ³                  ³- Ajuste no cancelamento para nao verificar    ³±±
±±³           ³          ³                  ³sobreposição de data do registro cancelado.    ³±±
±±³Marcos Pere³23/12/2014³ TRHQC1           ³- Implementação da opção de Alteração de Dias  ³±±
±±³           ³          ³                  ³de Direito (SRF), quando não há programações na³±±
±±³           ³          ³                  ³RIA, gerando histórico no RF_OBS.              ³±±
±±³Joao Balbin³23/01/2015³ TRKUMD           ³- Implementação dgatilho automatico do campo de³±±
±±³           ³          ³                  ³  Situacao quando a data base for menor que a  ³±±
±±³           ³          ³                  ³  dt fim na inclusão de dias de direito.       ³±±
±±³Marcos Pere³30/11/2015³PCREQ-5540        ³Alteracao do RG1_ROTEIR de "250" para "LIP" na ³±±
±±³           ³          ³                  ³gravacao da licenca premio                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPEA051(nOpcAuto, xAutoCab, xAutoItens, nOpc)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cFiltraSRA			   	//Variavel para filtro
Local aIndexSRA		:= {} 		//Variavel Para Filtro
Local oBrwSRA
Local lGestPubl 	:= if(ExistFunc("fUsaGFP"),fUsaGFP(),.f.) //Verifica se utiliza o modulo de Gestao de Folha Publica - SIGAGFP

Private nGSPopc 	:= 0
Private bFiltraBrw  := {|| Nil}	//Variavel para Filtro
Private lVerRI6     := .T.  	//Variavel para validar publicação
Private lHabAba  	:= .F. 		//Variavel para habilitar a aba de Programação de férias
Private lEmProgr 	:= .F. 		//VARIAVEL QUE CONTROLA AS PROGRAMAÇÕES, NAO PERMITINDO O USUÁRIO FAZER MAIS DE UMA SEM CONFIRMAR
Private lEmInc	 	:= .F. 		//VARIAVEL QUE CONTROLA AS INCLUSÕES, NAO PERMITINDO O USUÁRIO FAZER MAIS DE UMA SEM CONFIRMAR
Private lErrRet     := .F. 		//VARIAVEL QUE CONTROLA CRITICA DE RETIFICACAO, NAO PERMITINDO INCLUIR NOVA PROGRAMACAO
Private cEnt		:= chr(13) + chr(10)
Private lSuspensao  := .F. 		//VARIAVEL QUE CONTROLA A EXECUÇÃO DE UMA SUSPENSÃO    DE PROGRAMAÇÃO
Private lCancela    := .F. 		//VARIAVEL QUE CONTROLA A EXECUÇÃO DE UM  CANCELAMENTO DE PROGRAMAÇÃO
Private lRetifica   := .F. 		//VARIAVEL QUE CONTROLA A EXECUÇÃO DE UM  RETIFICAÇÃO  DE PROGRAMAÇÃO
Private lTcfa040    := .F. 		//VARIAVEL QUE SE FOI CHAMADA DA APROVAÇÃO DO PORTAL
Private LCANCSRF	:= .F. 		//VARIAVEL QUE CONTROLA A EXECUÇÃO DE UM  CANCELAMENTO/PRESCRIÇÃO DE UM DIA DE DIREITO
Private LALTSRF	  	:= .F. 		//VARIAVEL QUE CONTROLA A EXECUÇÃO DE UMA ALTERAÇÃO DE UM DIA DE DIREITO

Private RiaDatPag	:= STOD("")
Private RiaDtPgAd	:= STOD("")
Private cTxtReman	:= substr(alltrim(STR0219),2,len(alltrim(STR0219))-1)
Private cNumAto   	:= ""
Private aVetor		:= {}
Private aStatus 	:= {"0-"+STR0244,"1-"+STR0079,"2-"+STR0081,"3-"+STR0080,"4-"+STR0208,"5-"+STR0210} //'Em Aquisição','Ativo','Prescrito','Pago','Cancelado','Retificado'
Private nLinS106    := 0

	//Não permite executar esta rotina se não utiliza o modulo de Gestao de Folha Publica - SIGAGFP
    If !lGestPubl
    	MsgAlert(OemToAnsi(STR0267))  //"Esta rotina é permitida somente quando utilizado o modulo de Gestão de Folha Pública (SIGAGFP)"
		Return
	ElseIf !(cModulo  $ "VDF,GFP")
    	MsgAlert(OemToAnsi(STR0268)) //"Esta rotina é permitida somente nos módulos SIGAVDF e SIGAGFP."
		Return
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define array contendo as Rotinas a executar do programa      ³
	//³ ----------- Elementos contidos por dimensao ------------     ³
	//³ 1. Nome a aparecer no cabecalho                              ³
	//³ 2. Nome da Rotina associada                                  ³
	//³ 3. Usado pela rotina                                         ³
	//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
	//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
	//³    2 - Simplesmente Mostra os Campos                         ³
	//³    3 - Inclui registros no Bancos de Dados                   ³
	//³    4 - Altera o registro corrente                            ³
	//³    5 - Remove o registro corrente do Banco de Dados          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aRotina    := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
	Private lGp051Auto := (xAutoCab <> Nil)
	Private aAutoCab   := Nil
	Private aAutoItens := Nil

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o cabecalho da tela de atualizacoes                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cCadastro := OemToAnsi(STR0002)  //"Controle de Dias de Direito"

	If nOpcAuto <> Nil
		Do Case
			Case nOpcAuto == 3
				INCLUI := .T.
				ALTERA := .F.
			Case nOpcAuto == 4
				INCLUI := .F.
				ALTERA := .T.
			OtherWise
				INCLUI := .F.
				ALTERA := .F.
		EndCase

		dbSelectArea("SRA")
		nPos := Ascan(aRotina,{|x| x[4]== nOpcAuto})
		If ( nPos <> 0 )
			bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPos,2 ] + "(a,b,c,d,e) }" )
			Eval( bBlock, Alias(), (Alias())->(Recno()),nPos)
		EndIf
	Else
		If lGp051Auto
			aAutoCab	  := xAutoCab
			aAutoItens := xAutoItens
			If nOpc==3
				nOpc:=6//aRotina -> opçao Incluir
			EndIf
			mBrowseAuto(nOpc,aAutoCab,"SRA")
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o Arquivo Esta Vazio                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !ChkVazio("SRA")
					Return
			Endif

			oBrwSRA := FwMBrowse():New()
			oBrwSRA:SetAlias( 'SRA' )
			oBrwSRA:SetDescription(OemToAnsi(STR0002)) 	  //"Controle de Periodos por Empregado"
			cFiltraRh := CHKRH("GPEA051","SRA","1")

			oBrwSRA:AddLegend( "RA_SITFOLH==' '"	, "GREEN"	, STR0027 ) //"Situação Normal"
			oBrwSRA:AddLegend( "RA_RESCRAI$'30/31'"	, "PINK"	, STR0028 ) //"Transferido"
			oBrwSRA:AddLegend( "RA_SITFOLH=='D'"	, "RED"		, STR0029 ) //"Demitido"
			oBrwSRA:AddLegend( "RA_SITFOLH=='A'"	, "YELLOW"	, STR0030 ) //"Afastado"
			oBrwSRA:AddLegend( "RA_SITFOLH=='F'"	, "BLUE"	, STR0031 ) //"Férias"

			oBrwSRA:SetmenuDef( 'GPEA051' )
			oBrwSRA:SetChgAll(.F.)
			oBrwSRA:SetFilterDefault(cFiltraRh)

			oBrwSRA:Activate()

		EndIf
	EndIf
Return( NIL )

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Isola opcoes de menu para que as opcoes da rotina possam ser lidas pelas bibliotecas Framework da Versao 9.12
@sample 	MenuDef()
@author	    Luiz Gustavo
@since		03/01/2007
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina  := {}
	ADD OPTION aRotina Title STR0003  Action "VIEWDEF.GPEA051" 	OPERATION 2 ACCESS 0	//'Visualizar'
	ADD OPTION aRotina Title STR0004  Action "VDF051FIL()" 		OPERATION 4 ACCESS 0	//'Manutenção'
Return aRotina



//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
objetivo desta aplicação é controlar o Saldo de Dias de Folgas
@sample 	ModelDef()
@return		oModel	Retorna o Modelo de dados
@author	    Everson S P Junior
@since		27/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruSRA := FWFormStruct( 1, "SRA",/* { |cCampo|SELCCAMP(cCampo)}*/, /*lViewUsado*/ )
	Local oStruSRF := FWFormStruct( 1, "SRF", /*bAvalCampo*/, .T. )
	Local oStruRIA := FWFormStruct( 1, "RIA", /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel
	Local nItem    := 1
	Local cCposLib

	Private aRetRIA

	bCpoInit1 := {|| oModel:GetValue("SRAMASTER", "RA_MAT") }
	oStruSRF:SetProperty("RF_MAT", MODEL_FIELD_INIT, bCpoInit1 )

	bCpoInit1 := {|| oModel:GetValue("SRFDETAIL", "RF_PD") }
	oStruRIA:SetProperty("RIA_PD", MODEL_FIELD_INIT, bCpoInit1 )

	bCpoInit1 := {|| oModel:GetValue("SRFDETAIL", "RF_DATABAS") }
	oStruRIA:SetProperty("RIA_DTINPA", MODEL_FIELD_INIT, bCpoInit1 )

	oStruRIA:AddField(                         					   ;// Ord. Tipo Desc.
						AllTrim( STR0005 )                   	 , ;// [01]  C   Titulo do campo//'Item'
						AllTrim( STR0006 ) 						 , ;// [02]  C   ToolTip do campo//'Item'
						"RIA_ITEM"                               , ;// [03]  C   Id do Field
						"N"                                      , ;// [04]  C   Tipo do campo
						02                                       , ;// [05]  N   Tamanho do campo
						0                                        , ;// [06]  N   Decimal do campo
						FwBuildFeature( STRUCT_FEATURE_VALID,"") , ;// [07]  B   Code-block de validação do campo
						NIL                                      , ;// [08]  B   Code-block de validação When do campo
						NIL                                      , ;// [09]  A   Lista de valores permitido do campo
						NIL                                      , ;// [10]  L   Indica se o campo tem preenchimento obrigatório
						NIL      	        					 , ;// [11]  B   Code-block de inicializacao do campo
						NIL                                      , ;// [12]  L   Indica se trata-se de um campo chave
						NIL                                      , ;// [13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.                                        )// [14]  L   Indica se o campo é virtual

	oStruRIA:AddField(                         					   ;// Ord. Tipo Desc.
						AllTrim( STR0007 )                   	 , ;// [01]  C   Titulo do campo//'Novo'
						AllTrim( STR0008)  						 , ;// [02]  C   ToolTip do campo//'Novo'
						"RIA_NEW"    	                         , ;// [03]  C   Id do Field
						"C"                                      , ;// [04]  C   Tipo do campo
						01                                       , ;// [05]  N   Tamanho do campo
						0                                        , ;// [06]  N   Decimal do campo
						FwBuildFeature( STRUCT_FEATURE_VALID,"") , ;// [07]  B   Code-block de validação do campo
						NIL                                      , ;// [08]  B   Code-block de validação When do campo
						NIL                                      , ;// [09]  A   Lista de valores permitido do campo
						NIL                                      , ;// [10]  L   Indica se o campo tem preenchimento obrigatório
						{||" "}              					 , ;// [11]  B   Code-block de inicializacao do campo
						NIL                                      , ;// [12]  L   Indica se trata-se de um campo chave
						NIL                                      , ;// [13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.                                        )// [14]  L   Indica se o campo é virtual

	oStruSRF:AddField(                         					   ;// Ord. Tipo Desc.
						AllTrim( STR0009 )                   	 , ;// [01]  C   Titulo do campo//'Novo'
						AllTrim( STR0010)  						 , ;// [02]  C   ToolTip do campo//'Novo'
						"SRF_NEW"    	                         , ;// [03]  C   Id do Field
						"C"                                      , ;// [04]  C   Tipo do campo
						01                                       , ;// [05]  N   Tamanho do campo
						0                                        , ;// [06]  N   Decimal do campo
						FwBuildFeature( STRUCT_FEATURE_VALID,"") , ;// [07]  B   Code-block de validação do campo
						NIL                                      , ;// [08]  B   Code-block de validação When do campo
						NIL                                      , ;// [09]  A   Lista de valores permitido do campo
						NIL                                      , ;// [10]  L   Indica se o campo tem preenchimento obrigatório
						{||" "}              					 , ;// [11]  B   Code-block de inicializacao do campo
						NIL                                      , ;// [12]  L   Indica se trata-se de um campo chave
						NIL                                      , ;// [13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.                                        )// [14]  L   Indica se o campo é virtual

	oStruSRF:AddField(           					               ;// Ord. Tipo Desc.
						AllTrim( STR0169 )                   	 , ;// [01]  C   Titulo do campo//'Canc'
						AllTrim( STR0169 )  					 , ;// [02]  C   ToolTip do campo//'Canc'
						"SRF_CANC"    	                         , ;// [03]  C   Id do Field
						"C"                                      , ;// [04]  C   Tipo do campo
						01                                       , ;// [05]  N   Tamanho do campo
						0                                        , ;// [06]  N   Decimal do campo
						FwBuildFeature( STRUCT_FEATURE_VALID,"") , ;// [07]  B   Code-block de validação do campo
						NIL                                      , ;// [08]  B   Code-block de validação When do campo
						NIL                                      , ;// [09]  A   Lista de valores permitido do campo
						NIL                                      , ;// [10]  L   Indica se o campo tem preenchimento obrigatório
						{||" "}              					 , ;// [11]  B   Code-block de inicializacao do campo
						NIL                                      , ;// [12]  L   Indica se trata-se de um campo chave
						NIL                                      , ;// [13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.                                        )// [14]  L   Indica se o campo é virtual

	oStruSRF:AddField(           					               ;// Ord. Tipo Desc.
						AllTrim( STR0247 )                   	 , ;// [01]  C   Titulo do campo//'Alt'
						AllTrim( STR0247 )  					 , ;// [02]  C   ToolTip do campo//'Alt'
						"SRF_ALT"    	                         , ;// [03]  C   Id do Field
						"C"                                      , ;// [04]  C   Tipo do campo
						01                                       , ;// [05]  N   Tamanho do campo
						0                                        , ;// [06]  N   Decimal do campo
						FwBuildFeature( STRUCT_FEATURE_VALID,"") , ;// [07]  B   Code-block de validação do campo
						NIL                                      , ;// [08]  B   Code-block de validação When do campo
						NIL                                      , ;// [09]  A   Lista de valores permitido do campo
						NIL                                      , ;// [10]  L   Indica se o campo tem preenchimento obrigatório
						{||" "}              					 , ;// [11]  B   Code-block de inicializacao do campo
						NIL                                      , ;// [12]  L   Indica se trata-se de um campo chave
						NIL                                      , ;// [13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.                                        )// [14]  L   Indica se o campo é virtual

	oStruRIA:AddField(                         					   ;// Ord. Tipo Desc.
						AllTrim( STR0011 )                   	 , ;// [01]  C   Titulo do campo//'Suspen.'
						AllTrim( STR0012) 					 	 , ;// [02]  C   ToolTip do campo//'Suspen.'
						"RIA_XSUSPE"    			             , ;// [03]  C   Id do Field
						"C"                                      , ;// [04]  C   Tipo do campo
						01                                       , ;// [05]  N   Tamanho do campo
						0                                        , ;// [06]  N   Decimal do campo
						FwBuildFeature( STRUCT_FEATURE_VALID,"") , ;// [07]  B   Code-block de validação do campo
						NIL                                      , ;// [08]  B   Code-block de validação When do campo
						NIL                                      , ;// [09]  A   Lista de valores permitido do campo
						NIL                                      , ;// [10]  L   Indica se o campo tem preenchimento obrigatório
						{||" "}              					 , ;// [11]  B   Code-block de inicializacao do campo
						NIL                                      , ;// [12]  L   Indica se trata-se de um campo chave
						NIL                                      , ;// [13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.                                        )// [14]  L   Indica se o campo é virtual

	oStruRIA:AddField(                         					   ;// Ord. Tipo Desc.
						AllTrim( STR0169 )                   	 , ;// [01]  C   Titulo do campo// "Canc"
						AllTrim( STR0169)  						 , ;// [02]  C   ToolTip do campo// "Canc"
						"RIA_CANC"    	                         , ;// [03]  C   Id do Field
						"C"                                      , ;// [04]  C   Tipo do campo
						01                                       , ;// [05]  N   Tamanho do campo
						0                                        , ;// [06]  N   Decimal do campo
						FwBuildFeature( STRUCT_FEATURE_VALID,"") , ;// [07]  B   Code-block de validação do campo
						NIL                                      , ;// [08]  B   Code-block de validação When do campo
						NIL                                      , ;// [09]  A   Lista de valores permitido do campo
						NIL                                      , ;// [10]  L   Indica se o campo tem preenchimento obrigatório
						{||" "}              					 , ;// [11]  B   Code-block de inicializacao do campo
						NIL                                      , ;// [12]  L   Indica se trata-se de um campo chave
						NIL                                      , ;// [13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.                                        )// [14]  L   Indica se o campo é virtual


	//Remove campos da struct do SRA que nao estejam no cCposLib abaixo
	cCposLib := "RA_FILIAL,RA_MAT,RA_NOME,RA_ADMISSA"
	SX3->(DbSetOrder(1))
	SX3->(MsSeek("SRA"))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SRA"
		If (!Alltrim(SX3->X3_CAMPO) $ cCposLib) .AND. X3USO(SX3->X3_USADO)
			oStruSRA:SetProperty(Alltrim(SX3->X3_CAMPO), MODEL_FIELD_OBRIGAT, .F. )
		EndIf
		SX3->(dbSkip())
	EndDo

	oStruSRA:SetProperty("RA_OCORREN",MODEL_FIELD_WHEN,{||.T.})
	oStruSRA:SetProperty("RA_ADTPOSE",MODEL_FIELD_WHEN,{||.T.})
	oStruSRA:SetProperty("RA_ADMISSA",MODEL_FIELD_WHEN,{||.F.})
	oStruSRA:SetProperty("RA_MAT"     ,MODEL_FIELD_WHEN,{||.F.})
	oStruSRA:SetProperty("RA_NOME"    ,MODEL_FIELD_WHEN,{||.F.})

	oStruRIA:SetProperty("RIA_MAT"    , MODEL_FIELD_OBRIGAT,.F.)
	oStruRIA:SetProperty("RIA_PD"     , MODEL_FIELD_OBRIGAT,.F.)

	cCposSRF := "RF_DESCPD"
	SX3->(DbSetOrder(1))
	SX3->(MsSeek("SRF"))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SRF"
		If (!Alltrim(SX3->X3_CAMPO) $ cCposSRF) .AND. X3USO(SX3->X3_USADO)
			oStruSRF:SetProperty(Alltrim(SX3->X3_CAMPO), MODEL_FIELD_WHEN , {||SRFWHEN()} )
		EndIf
		SX3->(dbSkip())
	EndDo

	cCposRIA := ""
	SX3->(DbSetOrder(1))
	SX3->(MsSeek("RIA"))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "RIA"
		If (!Alltrim(SX3->X3_CAMPO) $ cCposRIA) .AND. X3USO(SX3->X3_USADO)
			If Alltrim(SX3->X3_CAMPO) $ "RIA_DATPAG*RIA_DTPGAD"
				oStruRIA:SetProperty(Alltrim(SX3->X3_CAMPO), MODEL_FIELD_WHEN , {||fRIAWHENDT()} )
			Else
				oStruRIA:SetProperty(Alltrim(SX3->X3_CAMPO), MODEL_FIELD_WHEN , {||RIAWHEN()} )
			EndIf
		EndIf
		SX3->(dbSkip())
	EndDo

	oStruSRF:SetProperty("RF_NOME", MODEL_FIELD_OBRIGAT,.F.)

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("GPEA051MODEL", /*bPreValidacao*/, {|oModel|GP051TUDOK(oModel)}, /*{|oModel|GP051GRV(oModel)}*/, {|oModel|GP051CAN(oModel)}/*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( "SRAMASTER", /*cOwner*/, oStruSRA,/* bPre*/{||.T.},{||.T.},/* bLoad*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( "SRFDETAIL", "SRAMASTER", oStruSRF, /*bLinePre*/ ,{|oModel|LINOKSRF(oModel)}     , /*bPreVal*/,{|oModel|TudoOkSRF(oModel)}, {|oModel|bLoadSRF(oModel)} )  // 26/11/2013

	If IsInCallStack("TCFA040")  //SE FOR CHAMADA PELA TCF
		oModel:AddGrid( "RIADETAIL", "SRFDETAIL", oStruRIA, /*bLinePre*/,{|oModel,nItem|LINOKRIA(oModel)}, /*bPreVal*/,{|oModel| TudOkRIA(oModel)}, {|oModel|bLoadRIA(oModel)})
	Else
		oModel:AddGrid( "RIADETAIL", "SRFDETAIL", oStruRIA, /*bLinePre*/,{|oModel,nItem|LINOKRIA(oModel)}, /*bPreVal*/,{|oModel| TudOkRIA(oModel)},)
	EndIf

	//Faz relaciomento entre os compomentes do model
	oModel:SetRelation( "SRFDETAIL", { { "RF_FILIAL" , "FWxFilial( 'SRF' )" }, { "RF_MAT", "RA_MAT" } }, SRF->( IndexKey( 1 ) ) )
	oModel:SetRelation( "RIADETAIL", { { "RIA_FILIAL", "FWxFilial( 'RIA' )" }, { "RIA_MAT", "RF_MAT" }, { "RIA_PD", "RF_PD" },{ "RIA_DTINPA", "RF_DATABAS" }} , RIA->( IndexKey( 1 ) ) ) //Add no Relação os periodos.

	// Liga o controle de nao repeticao de linha
	//oModel:GetModel( "RIADETAIL" ):SetUniqueLine( { "RIA_FILIAL" },{ "RIA_MAT" },{ "RIA_PD" },{ "RIA_DTINPA" },{"RIA_DATINI"}  )
	//oModel:GetModel( "SRFDETAIL" ):SetUniqueLine( {"RF_FILIAL"},{"RF_MAT"},{"RF_DATABAS"},{ "RF_PD" } )

	oModel:SetPrimaryKey( { "RA_FILIAL", "RA_MAT" } )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0013 )//'Controle de Dias de Direito'

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( "SRAMASTER" ):SetDescription( STR0014 ) //'Dados do Servidor'
	oModel:GetModel( "SRFDETAIL" ):SetDescription( STR0015 ) //'Períodos Aquisitivos'
	oModel:GetModel( "RIADETAIL" ):SetDescription( STR0001 ) //'Planejamentos do Servidor'

	//Permissão de grid sem dados
	oModel:GetModel( "RIADETAIL" ):SetOptional( .T. )

	//Não permite incluir novas linhas
	//oModel:GetModel( "SRFDETAIL" ):SetNoInsertLine( .T. )
	//oModel:GetModel( "RIADETAIL" ):SetNoInsertLine( .T. )

	//Não permite alterar as linhas do grid.
	oModel:GetModel( "SRFDETAIL" ):SetNoDeleteLine( .T. )
	oModel:GetModel( "RIADETAIL" ):SetNoDeleteLine( .T. )
Return oModel


//------------------------------------------------------------------------------
/*/{Protheus.doc} RIAWHEN()
Validação  When Dos campos da Tabela RIA
onde status diferente de X os campos não poderão ser
editados em tela.
@sample 	RIAWHEN()
@param		aParametro - Função
@return		L
@author	    Fabricio Amaro
@since		19/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function RIAWHEN()
	Local lRet 		:= .F.
	Local oModel 	:= FWModelActive()
	Local oModelRIA := oModel:GetModel( "RIADETAIL" )

	If oModelRIA:Length() > 0
		If oModel:GetValue("RIADETAIL", "RIA_NEW") == "X"
			If alltrim(SX3->X3_CAMPO) $ "RIA_PARMEM" .and. SRA->RA_CATFUNC $ '01' .and. ;
			POSICIONE("SRV",1,XFILIAL("SRV")+oModel:GetValue("SRFDETAIL", "RF_PD"),"RV_CODFOL") == "1332"
				lRet := .T.
			ElseIf !(alltrim(SX3->X3_CAMPO) $ "RIA_PARMEM") .and. !lTcfa040
				lRet := .T.
			EndIf

			If lRetifica
				If alltrim(SX3->X3_CAMPO) $ "RIA_DATINI" .or. "RIA_DATINI" $ readvar()
					lRet := .T.
				EndIf
				If alltrim(SX3->X3_CAMPO) $ "RIA_FILSUB" .or. "RIA_FILSUB" $ readvar()
					lRet := .T.
				EndIf
				If alltrim(SX3->X3_CAMPO) $ "RIA_MATSUB" .or. "RIA_MATSUB" $ readvar()
					lRet := .T.
				EndIf
				If alltrim(SX3->X3_CAMPO) $ "RIA_NPAGTO" .or. "RIA_NPAGTO" $ readvar()
					lRet := .T.
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} SRFWHEN()
Validação  When Dos campos da Tabela SRF
onde status diferente de X os campos não poderão ser
editados em tela.
@sample 	SRFWHEN()
@param		aParametro - Função
@return		L
@author	    Fabricio Amaro
@since		19/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function SRFWHEN(cCod)
	Local lRet 		:= .F.
	Local oModel 	:= FWModelActive()
	Local oModelSRF := oModel:GetModel( "SRFDETAIL" )

	If oModelSRF:Length() > 0
		If oModel:GetValue("SRFDETAIL", "SRF_NEW") == "X"
			lRet := .T.
		EndIF
	EndIf
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
objetivo desta aplicação é controlar o Saldo de Dias de Folgas, nos módulos SIGAVDF e SIGAGFP
@sample 	ViewDef()
@return		oView	Retorna o objeto de View criado
@author	    Everson S P Junior
@since		27/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()//OK
	Local cCposLib := ""
	Local oStruSRA := FWFormStruct( 2, "SRA" )
	Local oStruSRF := FWFormStruct( 2, "SRF" )
	Local oStruRIA := FWFormStruct( 2, "RIA" )
	// Cria a estrutura a ser usada na View
	Local oModel   := FWLoadModel( "GPEA051" )
	Local oView
	aStatus 	:= {"0-"+STR0244,"1-"+STR0079,"2-"+STR0081,"3-"+STR0080,"4-"+STR0208,"5-"+STR0210} //'Em Aquisição','Ativo','Prescrito','Pago','Cancelado','Retificado'
	//Remove campos da struct do SRA que nao estejam no cCposLib abaixo
	cCposLib := "RA_FILIAL,RA_MAT,RA_NOME,RA_ADMISSA"
	SX3->(DbSetOrder(1))
	SX3->(MsSeek("SRA"))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SRA"
		If (!Alltrim(SX3->X3_CAMPO) $ cCposLib) .AND. X3USO(SX3->X3_USADO)
		   oStruSRA:RemoveField(Alltrim(SX3->X3_CAMPO))
		EndIf
		SX3->(dbSkip())
	EndDo

	//Remove campos da struct do SRF que nao estejam no cCposLib abaixo
	cCposLib := "RF_PD,RF_DESCPD,RF_DATABAS,RF_DATAFIM,RF_DIASDIR,RF_DFERVAT,RF_DFERAAT,RF_STATUS,RF_DFALVAT"
	cCposLib += "RF_DFALAAT,RF_OBSERVA,RF_DIASPRG,RF_DIREMAN,RF_DTCANCE,RF_HRCANCE"
	SX3->(DbSetOrder(1))
	SX3->(MsSeek("SRF"))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SRF"
		If !(Alltrim(SX3->X3_CAMPO) $ cCposLib) .AND. X3USO(SX3->X3_USADO) .and. SX3->X3_PROPRI <> 'U'
		   oStruSRF:RemoveField(Alltrim(SX3->X3_CAMPO))
		EndIf
		SX3->(dbSkip())
	EndDo

	oStruSRA:SetProperty("*",MVC_VIEW_FOLDER_NUMBER,"1")
	oStruRIA:RemoveField("RIA_MAT")
	oStruRIA:RemoveField("RIA_PD")

	oStruRIA:AddField( 										 ;      // Ord. Tipo Desc.
						"RIA_ITEM"                         , ;      // [01]  C   Nome do Campo
						"01"                               , ;      // [02]  C   Ordem
						AllTrim( STR0016 )           	   , ; 		// [03]  C   Titulo do campo//'Item'
						AllTrim( STR0017 )      		   , ; 		// [04]  C   Descricao do campo//'Item'
						{ "ITEM" }             			   , ;      // [05]  A   Array com Help
						"N"                                , ;      // [06]  C   Tipo do campo
						"99"                               , ;      // [07]  C   Picture
						NIL                                , ;      // [08]  B   Bloco de Picture Var
						""                                 , ;      // [09]  C   Consulta F3
						.F.                                , ;      // [10]  L   Indica se o campo é alteravel
						NIL                                , ;      // [11]  C   Pasta do campo
						NIL                                , ;      // [12]  C   Agrupamento do campo
						NIL                                , ;      // [13]  A   Lista de valores permitido do campo (Combo)
						NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
						NIL                                , ;      // [15]  C   Inicializador de Browse
						.F.                                , ;      // [16]  L   Indica se o campo é virtual
						NIL                                , ;      // [17]  C   Picture Variavel
						NIL                                )        // [18]  L   Indica pulo de linha após o campo


	oStruRIA:AddField( 									     ;      // Ord. Tipo Desc.
						"RIA_NEW"                          , ;      // [01]  C   Nome do Campo
						"02"                               , ;      // [02]  C   Ordem
						AllTrim( STR0018)           	   , ; 		// [03]  C   Titulo do campo//'Novo'
						AllTrim( STR0019 )      		   , ; 		// [04]  C   Descricao do campo//'Novo'
						{ "NEW" }             			   , ;      // [05]  A   Array com Help
						"C"                                , ;      // [06]  C   Tipo do campo
						"A"                                , ;      // [07]  C   Picture
						NIL                                , ;      // [08]  B   Bloco de Picture Var
						""                                 , ;      // [09]  C   Consulta F3
						.F.                                , ;      // [10]  L   Indica se o campo é alteravel
						NIL                                , ;      // [11]  C   Pasta do campo
						NIL                                , ;      // [12]  C   Agrupamento do campo
						NIL                                , ;      // [13]  A   Lista de valores permitido do campo (Combo)
						NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
						" "                                , ;      // [15]  C   Inicializador de Browse
						.F.                                , ;      // [16]  L   Indica se o campo é virtual
						NIL                                , ;      // [17]  C   Picture Variavel
						NIL                                )        // [18]  L   Indica pulo de linha após o campo

	oStruRIA:AddField( 										 ;      // Ord. Tipo Desc.
						"RIA_XSUSPE"                       , ;      // [01]  C   Nome do Campo
						"99"                               , ;      // [02]  C   Ordem
						AllTrim( STR0020)           	   , ; 		// [03]  C   Titulo do campo//'Suspen.'
						AllTrim( STR0021 )      		   , ; 		// [04]  C   Descricao do campo//'Suspen.'
						{ "SUSPEN" }             		   , ;      // [05]  A   Array com Help
						"C"                                , ;      // [06]  C   Tipo do campo
						"A"                                , ;      // [07]  C   Picture
						NIL                                , ;      // [08]  B   Bloco de Picture Var
						""                                 , ;      // [09]  C   Consulta F3
						.F.                                , ;      // [10]  L   Indica se o campo é alteravel
						NIL                                , ;      // [11]  C   Pasta do campo
						NIL                                , ;      // [12]  C   Agrupamento do campo
						NIL                                , ;      // [13]  A   Lista de valores permitido do campo (Combo)
						NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
						" "                                , ;      // [15]  C   Inicializador de Browse
						.F.                                , ;      // [16]  L   Indica se o campo é virtual
						NIL                                , ;      // [17]  C   Picture Variavel
						NIL                                )        // [18]  L   Indica pulo de linha após o campo

	oStruRIA:AddField( 										 ;      // Ord. Tipo Desc.
						"RIA_CANC"                         , ;      // [01]  C   Nome do Campo
						"AA"                               , ;      // [02]  C   Ordem
						AllTrim( STR0169)           	   , ; 		// [03]  C   Titulo do campo//'Canc'
						AllTrim( STR0169)      			   , ; 		// [04]  C   Descricao do campo//'Canc'
						{ STR0169 }             		   , ;      // [05]  A   Array com Help
						"C"                                , ;      // [06]  C   Tipo do campo
						"A"                                , ;      // [07]  C   Picture
						NIL                                , ;      // [08]  B   Bloco de Picture Var
						""                                 , ;      // [09]  C   Consulta F3
						.F.                                , ;      // [10]  L   Indica se o campo é alteravel
						NIL                                , ;      // [11]  C   Pasta do campo
						NIL                                , ;      // [12]  C   Agrupamento do campo
						NIL                                , ;      // [13]  A   Lista de valores permitido do campo (Combo)
						NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
						" "                                , ;      // [15]  C   Inicializador de Browse
						.F.                                , ;      // [16]  L   Indica se o campo é virtual
						NIL                                , ;      // [17]  C   Picture Variavel
						NIL                                )        // [18]  L   Indica pulo de linha após o campo

	oStruSRF:AddField( 										 ;      // Ord. Tipo Desc.
						"SRF_NEW"                          , ;      // [01]  C   Nome do Campo
						"02"                               , ;      // [02]  C   Ordem
						AllTrim( STR0022)           	   , ; 		// [03]  C   Titulo do campo//'Novo'
						AllTrim( STR0023 )      		   , ; 		// [04]  C   Descricao do campo//'Novo'
						{ "NEW" }             			   , ;      // [05]  A   Array com Help
						"C"                                , ;      // [06]  C   Tipo do campo
						"A"                                , ;      // [07]  C   Picture
						NIL                                , ;      // [08]  B   Bloco de Picture Var
						""                                 , ;      // [09]  C   Consulta F3
						.F.                                , ;      // [10]  L   Indica se o campo é alteravel
						NIL                                , ;      // [11]  C   Pasta do campo
						NIL                                , ;      // [12]  C   Agrupamento do campo
						NIL                                , ;      // [13]  A   Lista de valores permitido do campo (Combo)
						NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
						" "                                , ;      // [15]  C   Inicializador de Browse
						.F.                                , ;      // [16]  L   Indica se o campo é virtual
						NIL                                , ;      // [17]  C   Picture Variavel
						NIL                                )        // [18]  L   Indica pulo de linha após o campo

	oStruSRF:AddField( 										 ;      // Ord. Tipo Desc.
						"SRF_CANC"                         , ;      // [01]  C   Nome do Campo
						"AA"                               , ;      // [02]  C   Ordem
						AllTrim( STR0169)                  , ; 		// [03]  C   Titulo do campo//'Canc'
						AllTrim( STR0169)      			   , ; 		// [04]  C   Descricao do campo//'Canc'
						{ "NEW" }             			   , ;      // [05]  A   Array com Help
						"C"                                , ;      // [06]  C   Tipo do campo
						"A"                                , ;      // [07]  C   Picture
						NIL                                , ;      // [08]  B   Bloco de Picture Var
						""                                 , ;      // [09]  C   Consulta F3
						.F.                                , ;      // [10]  L   Indica se o campo é alteravel
						NIL                                , ;      // [11]  C   Pasta do campo
						NIL                                , ;      // [12]  C   Agrupamento do campo
						NIL                                , ;      // [13]  A   Lista de valores permitido do campo (Combo)
						NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
						" "                                , ;      // [15]  C   Inicializador de Browse
						.F.                                , ;      // [16]  L   Indica se o campo é virtual
						NIL                                , ;      // [17]  C   Picture Variavel
						NIL                                )        // [18]  L   Indica pulo de linha após o campo

	oStruSRF:AddField( 										 ;      // Ord. Tipo Desc.
						"SRF_ALT"                          , ;      // [01]  C   Nome do Campo
						"AA"                               , ;      // [02]  C   Ordem
						AllTrim( STR0247)                  , ; 		// [03]  C   Titulo do campo//'Alt'
						AllTrim( STR0247)      			   , ; 		// [04]  C   Descricao do campo//'Alt'
						{ "NEW" }             			   , ;      // [05]  A   Array com Help
						"C"                                , ;      // [06]  C   Tipo do campo
						"A"                                , ;      // [07]  C   Picture
						NIL                                , ;      // [08]  B   Bloco de Picture Var
						""                                 , ;      // [09]  C   Consulta F3
						.F.                                , ;      // [10]  L   Indica se o campo é alteravel
						NIL                                , ;      // [11]  C   Pasta do campo
						NIL                                , ;      // [12]  C   Agrupamento do campo
						NIL                                , ;      // [13]  A   Lista de valores permitido do campo (Combo)
						NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
						" "                                , ;      // [15]  C   Inicializador de Browse
						.F.                                , ;      // [16]  L   Indica se o campo é virtual
						NIL                                , ;      // [17]  C   Picture Variavel
						NIL                                )        // [18]  L   Indica pulo de linha após o campo

	// Cria o objeto de View
    oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "VIEW_SRA", oStruSRA, "SRAMASTER" )

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid(  "VIEW_SRF",  oStruSRF,  "SRFDETAIL" )
	oView:AddGrid(  "VIEW_RIA",  oStruRIA,  "RIADETAIL" )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "SUPERIOR",  20 )
	oView:CreateHorizontalBox( "INFERIOR1", 40 )
	oView:CreateHorizontalBox( "INFERIOR2", 40 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( "VIEW_SRA", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_SRF", "INFERIOR1")
	oView:SetOwnerView( "VIEW_RIA", "INFERIOR2")
	// Define campos que terao Auto Incremento
	oView:AddIncrementField( "VIEW_RIA", "RIA_ITEM" )

	// Liga a identificacao do componente
	oView:EnableTitleView( "VIEW_SRA", STR0024)	//'Dados do Servidor'
	oView:EnableTitleView( "VIEW_SRF", STR0025)	//'Períodos Aquisitivos'
	oView:EnableTitleView( "VIEW_RIA", STR0026)	//'Planejamentos do Servidor'

	// Botões de Ações Relacionadas
	If Altera //!(oModel:GetOperation() == 1) //SE NÃO FOR VISUALIZAR
		If !IsInCallStack("TCFA040")  //SE NÃO FOR CHAMADA DA ROTINA DE APROVAÇÃO DO PORTAL
			If !lEmProgr
				oView:AddUserButton(STR0027	, "GPEA051",{|oView|VDFPROGFE(),oView:Refresh()})//'Programar Dias de Direito'
				oView:AddUserButton(STR0028 , "GPEA051",{|oView|VDFCANCRIA(oView,"C"),oView:Refresh(),fProgramRetif(),oView:Refresh()})//'Cancelar/Retificar Progr.'
				oView:AddUserButton(STR0029	, "GPEA051",{|oView|VDFCANCRIA(oView,"S"),oView:Refresh()})//'Suspender Programação'

				oView:AddUserButton(STR0170, "GPEA051",{|oView|VDFCANCSRF(oView,"C"),oView:Refresh()}) 	//"Cancelar Dias de Direito"
				oView:AddUserButton(STR0171, "GPEA051",{|oView|VDFCANCSRF(oView,"P"),oView:Refresh()}) 	//'Prescrever Dias de Direito'
				oView:AddUserButton(STR0248, "GPEA051",{|oView|VDFALTSRF(oView)     ,oView:Refresh()}) 	//'Alterar Dias de Direito'
			EndIf
			If !lEmInc
				oView:AddUserButton(STR0030	, "GPEA051",{|oView|VDFINCSRF(oModel),oView:Refresh()})		//'Incluir Dias Direito'
			EndIf
        Else
            oView:AddUserButton(STR0028 , "GPEA051",{|oView|VDFCANCRIA(oView,"C"),fProgramRetif(),oView:Refresh()})//'Cancelar/Retificar Progr.'
		EndIf
	EndIf
	// Desliga a navegacao interna de registros
	oView:setUseCursor(.T.)

	// Define fechamento da tela
	oView:SetCloseOnOk( {||.T.} )
Return oView


//------------------------------------------------------------------------------
/*/{Protheus.doc}  VDFINCSRF
Inclusão de Dias de Direito
@return		lRet
@author	    Fabricio Amaro
@since		22/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFINCSRF(oModel)
Local aArea    	:= GetArea()
Local cTipPro	:= "" //BR1_S10701 - Tipo Programação
Local cPDId 	:= ""
Local nDias 	:= 0
Local i			:= 0
Local cTitulo 	:= STR0031  //'Incluir Dias de Direito'
Local lOk		:= .F.
Local oDlg

Private lSubsTp := "MSSQL" $ AllTrim( Upper( TcGetDb() ) ) .Or. AllTrim( Upper( TcGetDb() ) ) == "SYBASE"
Private oLbx

aVetor	:= LISTS106("", RA_CATFUNC, RA_REGIME, , RA_SINDICA)

// Monta a tela para usuário visualizar consulta.
If Len( aVetor ) > 0 .AND. !lEmInc
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,920 PIXEL

	   @ 10,10 LISTBOX oLbx FIELDS HEADER 	STR0032,;	//1//'Cod.'
	   										STR0033,;	//2//'Tipo Programação'
	   										STR0034,;	//3	//'Verba'
	   										STR0035,;	//4	//'Desc. Verba'
	   										STR0036,;	//5//'Dias Direito'
	   										STR0037,;	//6//'Qtde. Per. Aq.'
	   										STR0038,;	//7//'Tipo'
	   										STR0039,;	//8//'Desc. Tipo'
	   									  	"",;		//9
	   									  	STR0040,;	//10//'Troca Desc. Ind.'
	   									  	STR0041,;	//11//'Dias Credito'
	   									  	"",;		//12
	   									  	STR0042;	//13//'Publica Ato/Portaria'
	   									  	SIZE 450,95 OF oDlg PIXEL

	   oLbx:SetArray( aVetor )
	   oLbx:bLine := {|| {aVetor[oLbx:nAt,1],;
	                      aVetor[oLbx:nAt,2],;
	                      aVetor[oLbx:nAt,3],;
	                      aVetor[oLbx:nAt,4],;
	                      aVetor[oLbx:nAt,5],;
	                      aVetor[oLbx:nAt,6],;
	                      aVetor[oLbx:nAt,7],;
	                      aVetor[oLbx:nAt,8],;
	                      aVetor[oLbx:nAt,9],;
	                      aVetor[oLbx:nAt,10],;
	                      aVetor[oLbx:nAt,11],;
	                      aVetor[oLbx:nAt,12],;
	                      aVetor[oLbx:nAt,13]}}

	DEFINE SBUTTON FROM 107,380 TYPE 1 ACTION (GeraSRF(oLbx:nAt,aVetor,oModel),oDlg:End())	ENABLE OF oDlg
	DEFINE SBUTTON FROM 107,410 TYPE 2 ACTION oDlg:End()									ENABLE OF oDlg

	lEmInc := .T.

	ACTIVATE MSDIALOG oDlg CENTER
ElseIf Len( aVetor ) <= 0
	MsgBox(STR0043,cTitulo,"INFO" )//'Não existem dados na tabela S106-Tipos de Dias de Direito'
ElseIf lEmInc
	MsgBox(STR0044,cTitulo,"STOP")//'Existe uma inclusão em andamento. Conclua para depois efetuar uma nova inclusão!'
EndIf

RestArea( aArea )
Return



//------------------------------------------------------------------------------
/*/{Protheus.doc} GeraSRF()
Gerar SRF de acordo com o Tipo Selecionado
na tela de listBox.
@return		lRet
@author		Fabricio Amaro
@since		25/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function GeraSRF(nLin,aVetor,oModel)
	Local lRet		:= .T.
	Local aArea    	:= GetArea()
	Local aAreaSRV 	:= SRV->(GetArea())
	Local oModel   	:= FWModelActive(oModel)
	Local oStruSRF 	:= oModel:GetModel("SRFDETAIL")
	Local cStatus 	:= "1"
	Local cVrbFER 	:= ""

	nLinS106		:= nLin

	If !(Empty(aVetor))

		//-Posiciona no cadastro de verbas
		SRV->( dbSetOrder(2) )	//-RV_FILIAL+RV_CODFOL
		SRV->( dbSeek(RV_FILIAL+"0072",.F.) )
		cVrbFER := SRV->RV_COD

		oStruSRF:AddLine()
		oStruSRF:setvalue("SRF_NEW"		,"X")

		If oStruSRF:nLine = 1 .And. aVetor[nLinS106,3] == cVrbFER
			oStruSRF:setvalue("RF_DATABAS"	,M->RA_ADMISSA)
		Else
			oStruSRF:setvalue("RF_DATABAS"	,Date())
		EndIf
		oStruSRF:setvalue("RF_PD"	 	,aVetor[nLinS106,3])
		oStruSRF:setvalue("RF_DESCPD" 	,aVetor[nLinS106,4])

	EndIf
	RestArea( aAreaSRV )
	RestArea( aArea )
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} GP051ATDIAS()
Valida a data digitada. Incluso no X3_VALID dos campos RF_DATABAS e RF_DATAFIM
@return		lRet
@author		Fabricio Amaro
@since		25/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function GP051ATDIAS()
	Local oModel   	:= FWModelActive()
	Local oStruSRF 	:= oModel:GetModel("SRFDETAIL")
	Local lRet		:= .T.

	Local nDias   	:= 0
	Local cTp		:= aVetor[nLinS106,7]  //MES OU ANO
	Local nQtdeTp	:= aVetor[nLinS106,6]  //QUANTIDADE QUANDO FOR DIAS PROGRAMADOS
	Local nQtDDir	:= aVetor[nLinS106,5]  //QUANTIDADE DE DIAS DE DIREITO QUANDO PROGRAMADO

	dIni := oModel:GetValue("SRFDETAIL", "RF_DATABAS")
	dFim := oModel:GetValue("SRFDETAIL", "RF_DATAFIM")

	If 'RF_DATAFIM' $ readvar() .or. 'RF_DATABAS' $ readvar()
		If nQtdeTp == 0 //QUANDO NÃO É DIAS PROGRAMADOS
			dFim := If(Empty(dFim),dIni,dFim)
			nDias := dFim - dIni
			oStruSRF:setvalue("RF_DIASDIR", aVetor[nLinS106,11] * (nDias+1)  )
		Else
			If cTp == "1" //DIAS
				nDias := nQtdeTp
			ElseIf cTp == "2" //MESES
				nDias := MonthSum(dIni,nQtdeTp) - dIni
			EndIf
			dFim := dIni + nDias - 1
			oStruSRF:setvalue("RF_DIASDIR", nQtDDir  ) //INDICA OS DIAS DE DIREITO
		EndIf
		
		If !( 'RF_DATAFIM' $ ReadVar() )
			oStruSRF:setvalue("RF_DATAFIM",dFim)
		EndIf
	EndIf
	If !empty(dFim) .and. dFim < dIni //PODE TER ADQUIRIDO 1 DIA
		cMsg := (STR0045)//'A data FINAL não pode ser menor ou igual a data INICIAL!'
		Help( ,, OemToAnsi(STR0273),, cMsg, 1, 0 ) //"Data Informada Incorreta"
		lRet := .F.
	EndIf
	If nQtdeTp == 0 //QUANDO NÃO É DIAS PROGRAMADOS
		dFim := If(Empty(dFim),dIni+1,dFim)
		nDias := dFim - dIni
		oStruSRF:setvalue("RF_DIASDIR", aVetor[nLinS106,11] * (nDias+1)  )
	Else
		oStruSRF:setvalue("RF_DIASDIR", nQtDDir  ) //INDICA OS DIAS DE DIREITO
	EndIf

	If empty(dFim) .or. MesAno(Date()) <= MesAno(dFim)
		oStruSRF:setvalue("RF_STATUS", "0" ) //EM AQUISICAO
	ELSE
		oStruSRF:setvalue("RF_STATUS", "1" ) //SUGERE O PERÍODO COMO ATIVO
	EndIf
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} VDF051FIL()
Filtro para apresentação da tela.
@sample 	VDF050F()
@author	    Everson S P Junior
@since		17/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDF051FIL()
	Local nGeraRia 	:= 0
	Local nX		:= 0
	Local cTipPro	:= ""
	Local cTitulo 	:= STR0046//'Dias de Direito já cadastrados'
	Local lOk		:= .T.
	Local aArea    	:= GetArea()
	Local aAreaSRA	:= SRA->(GetArea())
	Local bConfirma	:= { || fMntSRFRIA(),oDlg:End()}

	Local bNovo		:= { || fNewSRF() ,oDlg:End()}
	Local oDlg
	Private oLbx
	Private aVetor	:= {}

	lEmProgr := .F.  //COMO ESTÁ INICIANDO A ROTINA, SETA COM FALSO PARA PERMITIR EFETUAR PROGRAMAÇÕES

	aVetor := VerbSRF()

	// Monta a tela para usuário visualizar consulta.
	If Len( aVetor ) <= 0
		Aviso( STR0047, STR0264, {STR0048} )//'Dias de Direito não cadastrado!'###"Não existem dados a serem apresentados. Clique no botão abaixo e, na próxima tela, utilize a ação 'Incluir Dias de Direito'."###'Novo'
		aAdd(aVetor,{"","",""})
		lOk			:= .F.
		fNewSRF()
	Else
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL

		   // Primeira opção para montar o listbox.
		   @ 10,10 LISTBOX oLbx FIELDS HEADER STR0051,STR0052,STR0050 SIZE 230,95 OF oDlg PIXEL 	//'Descrição da Verba'//'Nome'//'Verba'

		   oLbx:SetArray( aVetor )
		   oLbx:bLine := {|| {aVetor[oLbx:nAt,1],;
		                      aVetor[oLbx:nAt,2],;
		                      aVetor[oLbx:nAt,3]}}

			oBtnAtual := TButton():New( 106, 120, STR0053, oDlg, bConfirma		, 30,13,,,,.T.,,,,,,, )//'Confirma'
			oBtnAtual := TButton():New( 106, 155, STR0054	, oDlg, bNovo			, 30,13,,,,.T.,,,,,,, )//'Novo'
			oBtnAtual := TButton():New( 106, 205, STR0055	, oDlg, {||oDlg:END()}	, 30,13,,,,.T.,,,,,,, )//'Sair'
		ACTIVATE MSDIALOG oDlg CENTER
	EndIf
	RestArea(aAreaSRA)
	RestArea( aArea )
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} fMntSRFRIA()
Manutenção/Programação dos Dia de Direito
@return
@author		Fabricio Amaro
@since		26/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function fMntSRFRIA()
	lEmProgr := .F.
	lEmInc 	 := .T.
	FWExecView(STR0004,"GPEA051", MODEL_OPERATION_UPDATE, , { || .T. } )
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} fNewSRF()
Inclusão de um Dia de Direito
@return
@author		Fabricio Amaro
@since		22/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function fNewSRF()
	Private lNewSRF := .T.
	Private nLinS106 := 0
	Private aVetor
	Private lNovo := .T.
	lEmProgr := .T.
	lEmInc 	 := .F.
	FWExecView(STR0004,"GPEA051", MODEL_OPERATION_UPDATE, , { || .T. } )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VDFCANCRIA
SUSPENSÃO / CANCELAMENTO / RETIFICAÇÃO de Programação - RIA
@author  Fabricio Amaro
@since 	 27/11/2013
@version P11
@params
/*/
//--------------------------------------------------------------------
Function VDFCANCRIA(oModel,cTipo)

	Local oStruSRF  := oModel:GetModel("SRFDETAIL")
    Local oModRet   := FWModelActive()
	Local dIniBas	:= oStruSRF:GetValue("RF_DATABAS")
	Local nDReman	:= oStruSRF:GetValue("RF_DIREMAN") //DIAS REMANESCENTES
	Local nDProgr	:= oStruSRF:GetValue("RF_DIASPRG") //DIAS PROGRAMADOS
	Local cFil		:= oStruSRF:GetValue("RF_FILIAL")
	Local cMat		:= oStruSRF:GetValue("RF_MAT")
	Local cPD		:= oStruSRF:GetValue("RF_PD")
	Local oStruRIA  := oModel:GetModel("RIADETAIL")
	Local dIni 	   	:= oStruRIA:GetValue("RIA_DATINI")
	Local dFim 	   	:= oStruRIA:GetValue("RIA_DATFIM")
	Local nDiasPrg	:= oStruRIA:GetValue("RIA_NRDGOZ")
	Local nDInd	   	:= oStruRIA:GetValue("RIA_NRDIND")
	Local nDOport	:= oStruRIA:GetValue("RIA_DOPORT")
	Local nLin 	   	:= oStruRIA:GetValue("RIA_ITEM")
	Local cStatus	:= oStruRIA:GetValue("RIA_STATUS")
	Local nSeqPrg	:= oStruRIA:GetValue("RIA_SEQPRG")
	Local cObs 	   	:= Alltrim(oStruRIA:GetValue("RIA_OBS"))
	Local cDescTp 	:= If(cTipo == "S",OemToAnsi(STR0172),OemToAnsi(STR0028))//"SUSPENDER"
    Local cCodFol   := ""
	Local dNewData	:= (dFim - 1)
	Local oData
	Local oDlgData
	Local ndTot	   	:= nDiasPrg + ndInd
	Local aPerAb,aPerFech,aPerTodos,aPerAtual
	Local cProcesso := RA_PROCES
	cTxtReman	:= substr(alltrim(STR0219),2,len(alltrim(STR0219))-1)

	lErrRet := .F.
	RiaDatPag := oStruRIA:GetValue("RIA_DATPAG") //ARMAZENA A DATA PARA O CASO DE CANCELAMENTO
	RiaDtPgAd := oStruRIA:GetValue("RIA_DTPGAD") //ARMAZENA A DATA PARA O CASO DE CANCELAMENTO

	If !(Empty(RiaDtPgAd))
		//-aAdd(aPerAberto, RCH->({ 1-RCH_PER, 2-RCH_NUMPAG, 3-RCH_MES, 4-RCH_ANO, 5-RCH_DTINI, 6-RCH_DTFIM, 7-RCH_PROCES, 8-RCH_ROTEIR, 9-RCH_DTPAGO, 10-RCH_DTCORT}))
		fRetPerComp(Strzero(month(RiaDtPgAd),2) , Alltrim(Str(year(RiaDtPgAd))) , , cProcesso ,"FOL" , @aPerAb , @aPerFech , @aPerTodos )
		If !Empty(aPerFech) //.OR. (Empty(aPerFech) .AND. Empty(aPerAb))
			MsgBox( STR0217 , STR0218 ,"STOP") //'O periodo de pagamento da indenização já se encontra encerrado, portanto, não poderá sofrer alteração.'  'Periodo encerrado'
            lErrRet := .T.
			Return
		Else
			fGetPerAtual(@aPerAtual, , cProcesso, fGetRotOrdinar() )
			IF LEN(aPerAtual) > 0
				If MesAno(RiaDtPgAd) == aPerAtual[1][1]
					MsgBox( STR0215 , STR0216 ,"INFO") //'O periodo de pagamento da indenização é o que atualmente está aberto, portanto, verifique a necessidade de recalculo do mesmo.'  'Periodo aberto'
				EndIf
			EndIF
		EndIf
	EndIf

	If lSuspensao .OR. lRetifica .OR. lCancela .OR. lEmProgr
		MsgBox( STR0173 ,STR0174,"STOP") // "Existe um proceso em andamento. Conclua o processo!" "Processo em andamento"
        lErrRet := .T.
		Return
	EndIf

	If nDProgr <= 0
		MsgBox( STR0175, STR0176 ,"STOP") //'Não existem dias programadados para o período selecionado!'  'Sem programação'
        lErrRet := .T.
		Return
	EndIf

	If cStatus $ "1*3*4"  //0=Programado;1=Cancelado;2=Suspenso;3=Retificado;4=Quitado
		MsgBox(STR0177,STR0178,"STOP") //'O período em questão já se encontra QUITADO / CANCELADO / RETIFICADO, portanto não pode sofrer alteração!'  'Programação já ajustada'
        lErrRet := .T.
		Return
	EndIf

	//VERIFICA SE A DATA ATUAL É MAIOR QUE O RETORNO
	If Date() >= dFim
		If !(MsgBox(STR0059+cValToChar(nLin)+': ' + dtoc(dFim) + STR0058,cDescTp + STR0179,"YESNO"))//'. Deseja continuar?'//'A data atual é maior que a data do Fim do Gozo da linha '//  ' Programação'
            lErrRet := .T.
			Return
		EndIf
	EndIf

	//COMO É CANCELAMENTO/RETIFICAÇÃO, PRECISA VER SE TEM ATO PORTARIA, E SE O MESMO JÁ FOI PUBLICADO
	If cTipo == "C"
		lCancela 	:= .T.
		cDescTp 	:= STR0180 //'CANCELAR'
		cTitDlg 	:= STR0181 //'Informe a data do CANCELAMENTO'
		dbSelectArea("RI6")
		dbSetOrder(4)
		If dbSeek( FwxFilial("RI6") + cFil + cMat + "RIA" + cPD + DtoS(dIniBas) + DTOS(dIni) + nSeqPrg)
			If !(Empty(RI6->RI6_NUMDOC))

               //Verifica se a verba possui ID de calculo
               //Caso não possua, é um lançamento referente a Dias de Folga
               //Sendo dias de folga, mesmo publicado pode ser apenas cancelado.
               cCodFol := POSICIONE("SRV",1,XFILIAL("SRV")+cPD,"RV_CODFOL")
               If Empty(cCodFol)
                  //'Para a programação em questão, já foi publicado o Ato/Portaria - N:,'
                  //'esse tipo de periodo aquisitivo, permite retificar ou apenas cancelar.'
                  //'Selecione:'
                  //Sim - Para retificar
                  //Não - Para Cancelar
                  If MsgBox(STR0183 + RI6->RI6_TIPDOC + '-' + RI6->RI6_NUMDOC + '/' + RI6->RI6_ANO +', ';
                            +STR0239 + cEnt + cEnt + STR0240 +cEnt + STR0241 +cEnt + STR0242 , STR0243, "YESNO")
                     cDescTp := STR0182 //'RETIFICAR'
                     lRetifica := .T.
                     lCancela  := .F.
                     cTitDlg   := STR0186 //'Informe a data da RETIFICAÇÃO'
                     cNumAto   := RI6->RI6_TIPDOC + RI6->RI6_NUMDOC + RI6->RI6_ANO
                  Else
                     //O usuario vai apenas cancelar a programacao publicada
                     lVerRI6   := .F.
                  EndIf

               Else
				  cDescTp := STR0182 //'RETIFICAR'
                  MsgBox(STR0183 + RI6->RI6_TIPDOC + '-' + RI6->RI6_NUMDOC + '/' + RI6->RI6_ANO + STR0184 , STR0185 ,'INFO')  //'Para a programação em questão, já foi publicado o Ato/Portaria - N: '  ', portanto, esse item será RETIFICADO!'  'Retificação'
                  lRetifica 	:= .T.
                  lCancela  	:= .F.
				  cTitDlg   	:= STR0186 //'Informe a data da RETIFICAÇÃO'
				  cNumAto      := RI6->RI6_TIPDOC + RI6->RI6_NUMDOC + RI6->RI6_ANO
               EndIf
			EndIf
		EndIf
	Else
		cTitDlg := STR0064 //'Informe o ultimo dia de GOZO'
		lSuspensao 	:= .T.
	EndIf

	If (ndTot) > 0
		If MsgBox(STR0187 + cDescTP + STR0188 + cValToChar(nLin)+' - ' + dtoc(dIni) + STR0061 + dtoc(dFim), cDescTp + STR0179,"YESNO")//' a '//'Deseja realmente '  ' a Programação da linha '  ' Programação'

			DEFINE MSDIALOG oDlgData TITLE cTitDlg FROM 9,0 TO 15,40
				@ C(010),C(010) Say STR0065	Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgData//'Data:'
				@ C(010),C(030) MsGet oData Var dNewData 	Size C(40),C(008) COLOR CLR_BLACK PIXEL OF oDlgData
				@ C(010),C(090) BmpButton Type 1 Action Close(oDlgData)
			ACTIVATE MSDIALOG oDlgData CENTERED

			oStruRIA:SetValue("RIA_NEW"		, "X") //ABRE PARA EDIÇÃO
			oStruSRF:SetValue("SRF_NEW"		, "X") //ABRE PARA EDIÇÃO

			If cTipo == "C" //SE FOR CANCELAMENTO OU RETIFICAÇÃO

				oStruRIA:SetValue("RIA_CANC"	, "X")
				If lCancela  //SE FOR CANCELAMENTO
					oStruRIA:LoadValue("RIA_STATUS"	, "1")
					oStruRIA:LoadValue("RIA_OBS"		, Alltrim(cObs) + STR0189 + dtoc(date()) )//'/CANCEL. MANUAL '

                    //Realiza atualização do SRF apenas para o cancelamento, pois para retificações
                    //o usuário tera que lançar uma nova programação para a mesma qtde de dias
                    If cTxtReman $ cObs //Se "(Remanescente)" estiver contido na observacao da RIA, significa que estou cancelando a programacao de dias remanascentes
                        oStruSRF:SetValue("RF_DIREMAN"  , ndTot )
                    Else
                        oStruSRF:SetValue("RF_DIREMAN"  , 0 )
                    EndIf
                   oStruSRF:SetValue("RF_DIASPRG"  , nDProgr - ndTot)
                   oStruRIA:LoadValue("RIA_ATOANT" , cNumAto )

                   lErrRet := .T. //Para cancelamentos não existe nova programação

				Else //SE FOR RETIFICAÇÃO
					oStruRIA:LoadValue("RIA_STATUS"	, "3")
					oStruRIA:LoadValue("RIA_OBS"		, Alltrim(cObs) + STR0189 + dtoc(date()) )//'/RETIF. MANUAL '
				EndIf

				oStruRIA:LoadValue("RIA_DATPAG"	, StoD("") )
				oStruRIA:LoadValue("RIA_DTPGAD"	, StoD("") )

			Else //SUSPENSÃO

				If dNewData <= dIni
					Alert(STR0066)//'A data informada é MENOR ou IGUAL a data INICIAL da Programação!'
                    lErrRet := .T.
					Return
				EndIf
				If dNewData >= dFim
					Alert(STR0067)//'A data informada é MAIOR ou IGUAL a data FINAL da Programação!'
                    lErrRet := .T.
					Return
				EndIf

				oStruRIA:SetValue("RIA_XSUSPE"	, "X")
				oStruRIA:SetValue("RIA_STATUS"	, "2")
				oStruRIA:SetValue("RIA_DATFIM"	, dNewData)
				oStruRIA:SetValue("RIA_NRDGOZ"	, (dNewData - dIni) + 1)
				oStruRIA:SetValue("RIA_OBS"		, Alltrim(cObs) + STR0068 + dtoc(date()) )//'/SUSPENSAO MANUAL '

				oStruSRF:SetValue("RF_DIREMAN"	, nDReman + (dFim - dNewData) )
				oStruSRF:SetValue("RF_DIASPRG"	, nDProgr - (dFim - dNewData) )

				lSuspensao := .T.
			EndIf

			If empty(dNewData)
	                oStruRIA:LoadValue("RIA_SUSPEN" , dDataBase)
	    		Else
	    			oStruRIA:LoadValue("RIA_SUSPEN"	, dNewData)
	    		EndIf

			oStruRIA:SetValue("RIA_NEW"		, " ") //FECHA PARA EDIÇÃO
			oStruSRF:SetValue("SRF_NEW"		, " ") //FECHA PARA EDIÇÃO
		Else
			lRetifica 	:= .F.
			lCancela  	:= .F.
			lSuspensao	:= .F.
		EndIf
	Else
		MsgBox(STR0070 + cValToChar(nLin) + ' - ' + dtoc(dIni) + STR0069 + dtoc(dFim),STR0071,"STOP")//' a '//'Não existe DIAS DE GOZO na Programação da linha '//'Suspender Programação'
	EndIf
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} VDFCANCSRF
CANCELAMENTO / PRESCRIÇÃO do Dia de Direito - SRF
@author  Fabricio Amaro
@since 	 02/12/2013
@version P11
@params
/*/
//--------------------------------------------------------------------
Function VDFCANCSRF(oModel,cTipo)

	Local oStruSRF  := oModel:GetModel("SRFDETAIL")
	Local dIni		:= oStruSRF:GetValue("RF_DATABAS")
	Local dFim		:= oStruSRF:GetValue("RF_DATAFIM")
	Local nDReman	:= oStruSRF:GetValue("RF_DIREMAN") //DIAS REMANESCENTES
	Local nDProgr	:= oStruSRF:GetValue("RF_DIASPRG") //DIAS PROGRAMADOS
	Local cFil		:= oStruSRF:GetValue("RF_FILIAL")
	Local cMat		:= oStruSRF:GetValue("RF_MAT")
	Local cPD		:= oStruSRF:GetValue("RF_PD")
	Local cStatus	:= oStruSRF:GetValue("RF_STATUS")
	Local cStNews	:= ""
	Local dNewData	:= Date()

	If lSuspensao .OR. lRetifica .OR. lCancela .OR. lEmProgr .OR. lCancSRF .OR. lAltSRF
		MsgBox( STR0173 ,STR0174,"STOP") // "Existe um proceso em andamento. Conclua o processo!" "Processo em andamento"
		Return
	EndIf

	If nDProgr > 0
		MsgBox(STR0190 ,STR0138,"STOP") //'Existem Programações para o período selecionado! Cancele as Programações'  'Dias de Direito'
		Return
	EndIf

	If cStatus $ "2*3*4"  //0=Em aquisicao;1=Ativo;2=Prescrito;3=Pago;4=Cancelado
		MsgBox( STR0191 , STR0138 ,"STOP")  //'O período em questão já se encontra PRESCRITO / PAGO / CANCELADO, portanto não pode sofrer alteração!'  'Dia de Direito'
		Return
	EndIf

	//COMO É CANCELAMENTO, PRECISA VER SE TEM ATO PORTARIA, E SE O MESMO JÁ FOI PUBLICADO
	If cTipo == "C"
		cDescTp := STR0180//'CANCELAR'
		cTitDlg	:= STR0192 //'do CANCELAMENTO'
		cStNews := "4"
	Else
		cTitDlg	:= STR0195 //'da PRESCRIÇÃO'
		cDescTp	:= STR0196 //'PRESCREVER'
		cStNews := "2"
	EndIf

	dbSelectArea("RI6")
	dbSetOrder(4)
	If dbSeek( FwxFilial("RI6") + cFil + cMat + "SRF" + cPD + DtoS(dIni) )
		If !(Empty(RI6->RI6_NUMDOC))
			cDescTp := STR0182//'RETIFICAR'
			MsgBox(STR0193 + RI6->RI6_NUMDOC + RI6->RI6_TIPDOC + RI6->RI6_ANO + STR0184,STR0185,'INFO') // "Para a Dia de Direito em questão, já foi publicao o Ato/Portaria - N: " ', portanto, esse item será RETIFICADO!'   'Retificação'
			cTitDlg 	:= STR0194 //'da RETIFICAÇÃO'
			cNumAto		:= RI6->RI6_TIPDOC + RI6->RI6_NUMDOC + RI6->RI6_ANO
			cStNews		:= "5"
		EndIf
	EndIf

	If MsgBox(STR0187 + cDescTP + STR0197 + dtoc(dIni) + STR0061 + dtoc(dFim), cDescTp + STR0198,"YESNO")  //'Deseja realmente '  ' o Dia de Direito - '  ' Dia de Direito'

		DEFINE MSDIALOG oDlgData TITLE STR0199 + cTitDlg FROM 9,0 TO 15,40 //PIXEL
			@ C(010),C(010) Say STR0065	Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgData//'Data:'
			@ C(010),C(030) MsGet oData Var dNewData 	Size C(40),C(008) COLOR CLR_BLACK PIXEL OF oDlgData
			@ C(010),C(090) BmpButton Type 1 Action Close(oDlgData)
		ACTIVATE MSDIALOG oDlgData CENTERED

		oStruSRF:SetValue("SRF_NEW"		, "X") //ABRE PARA EDIÇÃO
		oStruSRF:SetValue("SRF_CANC"	, "X")
		oStruSRF:SetValue("RF_STATUS"	, cStNews )
		oStruSRF:SetValue("RF_DTCANCE"	, dNewData )
		oStruSRF:SetValue("RF_HRCANCE"	, TIME() )
		oStruSRF:SetValue("SRF_NEW"		, " ") //FECHA PARA EDIÇÃO
		lCancSRF := .T.
	EndIf
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} LinOKSRF
Validação Tudo OK do modelo de dados.
@return		lRet
@author	    Everson S P Junior
@since		27/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function LinOKSRF(oMdl)
	Local lRet     := .T.
	Local aArea    := GetArea()
	Local aAreaSRA := SRA->(GetArea())
	Local cPD      := oMdl:GetValue("RF_PD")
	Local dIni     := oMdl:GetValue("RF_DATABAS")
	Local dFim     := oMdl:GetValue('RF_DATAFIM')
	Local cFil 	   := oMdl:GetValue("RF_FILIAL")
	Local cMat	   := oMdl:GetValue("RF_MAT")
	Local cNew	   := oMdl:GetValue("SRF_NEW")
	Local cMsg	   := ""

	If lRet
		If (dFim < dIni) .OR. (Empty(dIni)) .OR. (Empty(dFim))
			cMsg := (STR0074)//"A data FINAL não pode ser menor ou igual a data INICIAL!"
			Help( ,, 'Help',, cMsg, 1, 0 )
			lRet := .F.
		EndIf
	EndIf

	If !lRet
		Help( ,, 'Help',, cMsg, 1, 0 )
	EndIf

	//VERIFICA SE A PROGRAMAÇÃO QUE ESTÁ SENDO INCLUIDA ESTÁ DENTRO DE UM PERÍODO JÁ CADASTRADO
	If lRet
		If cNew == "X"
			lRet := VerSRF(cPD,dIni,dFim,cFil,cMat)
		EndIf
	EndIf

	RestArea(aAreaSRA)
	RestArea( aArea )
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} TudoOkSRF
Validação Tudo OK do modelo de dados da SRF
@return		lRet
@author	    Fabricio Amaro
@since		26/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function TudoOkSRF(oModel)
	Local lRet     := .T.
	Local aArea    := GetArea()
	Local aAreaSRA := SRA->(GetArea())
	Local cPD      := oModel:GetValue("RF_PD")
	Local dIni     := oModel:GetValue("RF_DATABAS")
	Local dFim     := oModel:GetValue('RF_DATAFIM')
	Local cFil 	   := oModel:GetValue("RF_FILIAL")
	Local nDDir	   := oModel:GetValue("RF_DIASDIR")
	Local cMat	   := oModel:GetValue("RF_MAT")
	Local cNew	   := oModel:GetValue("SRF_NEW")

	If oModel:GetValue("RF_DIASPRG") > nDDir
 		cMsg := (STR0245) //'A quantidade de dias a programar é superior ao saldo de dias do período.!'
 		Help( ,, OemToAnsi(STR0274),, cMsg, 1, 0 ) //Programação Inválida
 		lRet := .F.
 	EndIf

	aVetor := If(Type("aVetor") == "U",{},aVetor)

	cTIPOAFA := Posicione("RCM",3,FwxFilial("RCM")+cPD,"RCM_TIPO")
 	If Empty(cTIPOAFA)
 		cMsg := (STR0075)//'O tipo de Dia de Direito informado não possui Tipo de Ausencia - RCM - vinculado! Verifique!'
 		Help( ,, OemToAnsi(STR0272),, cMsg, 1, 0 ) //'Tipo de Ausência Invalido'
 		lRet := .F.
 	EndIf

	//GERA O ITEM DO ATO/PORTARIA, SE NA S106 ESTIVER MARCADO PARA GERAR NA AQUISIÇÃO OU AMBOS - 26/11/2013
	If Len(aVetor) > 0 .AND. cNew == "X" .AND. lRet
		cTpProg  := Alltrim(aVetor[nLinS106,2])
		Begin Transaction
			If aVetor[nLinS106,12] $ "2*3"

				cRotina := "GPEA051"
				dbSelectArea("SRA")
				dbSetOrder(1)
				dbSeek(cFil + cMat)

				aParTela :={cRotina,;										//aParametro[1] Fonte 	Fonte que chamou.
							SRA->RA_MAT,;									//aParametro[2] RA_MAT 	Matricula do Funcionario.
							SRA->RA_CATFUNC,;								//aParametro[3] CatFunc   Categoria do Funcionario.
							cPD + dtos(dIni),;								//aParametro[4] Chave 	Para gravação do Historioco RI6
							SRA->RA_FILIAL,;								//aParametro[5] Filial 	Filial do funcionario transferido
							SRA->RA_CIC,;									//aParametro[6] CPF Do funcionario transferido
							dIni,;											//aParametro[7] Data de Efeito
							"2",;											//aParametro[8] Indice da tabela
							"SRF",;											//aParametro[9] Alias da tabela
							dtos(dIni),;									//aParametro[10] Data Base Inicio
							dtos(dFim),;									//aParametro[11] Data Base Fim
							"",;											//aParametro[12] Data Inicio Gozo
							"",;											//aParametro[13] Data Fim Gozo
							nDDir,;								 			//aParametro[14] Dias de Gozo/Direito
							"",;                                            //aParametro[15] Dias Indenizados
							"",;                                            //aParametro[16] Dias Oportunos
							"",;                                            //aParametro[17] Filial do Substituto
							"",;                                            //aParametro[18] Matricula do Substituto
							"",;                                            //aParametro[19] Nome do Substituto
							cTpProg,;										//aParametro[20] Tipo de Dia de Direito
							0,;                                             //aParametro[21] Dias Remanescentes
							"",;                                	        //aParametro[22] Ato/Portaria Anterior
							"",;      										//aParametro[23] Data da Suspensão
							""; 											//aParametro[24] Descrição do Status da Linha
							}

				MsgBox(STR0076 +;//'Será gerado o item do Ato/Portaria ref. a AQUISIÇÃO do periodo de '
						 dtoc(dIni) + STR0077 + dtoc(dFim) + ' - ' + cTpProg,STR0078,"INFO")//' a '//'Item do Ato/Portaria'

				VDFA060(aParTela)
			EndIf
		End Transaction
	EndIF

	RestArea( aArea )
	RestArea( aAreaSRA )
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} VerSRF
Verifica se existe dados para o periodo indicado na mesma verba
@return		lRet
@author	    Fabricio Amaro
@since		25/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function VerSRF(cPD,dDataDe,dDataAte,cFil,cMat)
	Local lRet := .T.
	Local cMsg := ""
	Local cQryTmp
	Local cStatMsg := ""

	cQryTmp := " SELECT * FROM " + RETSQLNAME("SRF") + " WHERE "
	cQryTmp += " RF_FILIAL = '"+cFil+"' AND RF_MAT = '"+cMat+"' AND RF_PD = '"+cPD+"' "
	cQryTmp += " AND RF_DATABAS = '"+DTOS(dDataDe)+"' "
	cQryTmp += " AND D_E_L_E_T_ = ' ' "

	//EXECUTA A SELEÇÃO DE DADOS
	cQryTmp := ChangeQuery(cQryTmp)
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQryTmp), 'XTEMP', .F., .T. )
	If !XTEMP->(Eof())
		While !XTEMP->(Eof())
			If XTEMP->RF_STATUS=="0"
				cStatMsg := STR0244 //'Em Aquisição'
			ElseIf XTEMP->RF_STATUS=="1"
				cStatMsg := STR0079 //'Ativo'
			ElseIf XTEMP->RF_STATUS=="2"
				cStatMsg := STR0081 //'Prescrito'
			ElseIf XTEMP->RF_STATUS=="3"
				cStatMsg := STR0080 //'Pago'
			ElseIf XTEMP->RF_STATUS=="4"
				cStatMsg := STR0208 //'Cancelado'
			ElseIf XTEMP->RF_STATUS=="5"
				cStatMsg := STR0210 //'Retificado'
			EndIf
			cMsg += STR0082 + cStatMsg + cEnt +;
					STR0084 + dtoc(stod(XTEMP->RF_DATABAS)) + STR0083 + dtoc(stod(XTEMP->RF_DATAFIM)) + cEnt + ;//' até '//'Data Base: '
					STR0085 + cValToChar(XTEMP->RF_DIASPRG) + cEnt//'Dias Programados: '
		 	XTEMP->(DbSkip())
		EndDo
		lRet := .F.
		cMsg := STR0086 + cEnt + cMsg//'Para a data informada, já existe outro registro para esse mesmo tipo de Dia de Direito:'
		Help( ,, OemToAnsi(STR0273),, cMsg , 1, 0 ) //"Data Informada Incorreta"

	EndIf
	XTEMP->(DbCloseArea())
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc}  LinOkRIA
Validação LINHA Ok do modelo de dados.
@return		lRet
@author	    Everson S P Junior
@since		27/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function LinOkRIA(oMdl)//OK
	Local lRet      := .T.
	Local aArea     := GetArea()
	Local aAreaSRA  := SRA->(GetArea())
	Local oModel    := FWModelActive()
	Local oStruRIA  := oModel:GetModel("RIADETAIL")
	Local cMsg		:= ""
	Local i 		:= 0
	Local cFil      := oModel:GetValue("SRFDETAIL", "RF_FILIAL")
	Local cMat      := oModel:GetValue("SRFDETAIL", "RF_MAT")
	Local cStatus   := ''

 	//SE NÃO FOR CHAMADA PELA TCF e a linha atual está com Status 0-Programado ou 4-Quitado
	If !(IsInCallStack("TCFA040")) .and. oStruRIA:GetValue("RIA_STATUS",oStruRIA:nLine) $ '0/4'
		//VERIFICA SE AS DATAS ESTÃO INTERCALADAS COM OUTRA LINHA DA RIA
		If oStruRIA:Length() > 1

			nLinBkp := oStruRIA:nLine
			dIni	:= oStruRIA:GetValue("RIA_DATINI",oStruRIA:nLine)
			dFim  	:= oStruRIA:GetValue("RIA_DATFIM",oStruRIA:nLine)

			For i := 1 To oStruRIA:Length()
				oStruRIA:GoLine(i)
				If !(nLinBkp == i)

					dIniLin := oStruRIA:GetValue("RIA_DATINI",oStruRIA:nLine)
					dFimLin := oStruRIA:GetValue("RIA_DATFIM",oStruRIA:nLine)
					cStatus := oStruRIA:GetValue("RIA_STATUS",oStruRIA:nLine)

					If cStatus $ '0*4' //Verifica se o Status eh 0-Programado e 4-Quitado, pois os demais estao cancelados
						If 	(  ( ( dIniLin >= dIni .AND. dIniLin <= dFim ) .OR.  ;
								 (dIni >= dIniLin .AND. dFim <= dFimLin) )		 ;
							.OR. ( ( dFimLin >= dIni .AND. dFimLin <= dFim ) .OR.;
								 (dIni >= dIniLin .AND. dFim <= dFimLin) ) )


							cMsg := (STR0092+Alltrim(STR(nLinBkp))+ STR0091+Alltrim(STR(oStruRIA:nLine))+;//') não deve estar entre o período da linha - ('//'Inicio do Gozo: Linha - ('
									') '+dToc(oStruRIA:GetValue("RIA_DATINI",oStruRIA:nLine))+STR0093+dTOC(oStruRIA:GetValue("RIA_DATFIM",oStruRIA:nLine)))//' Até '
							lRet := .F.
							Exit
						EndIf
					EndIf
				EndIf
			Next i
			oStruRIA:GoLine(nLinBkp)
		EndIf
	EndIf

	If lRet .and. (oStruRIA:GetValue("RIA_FILSUB",oStruRIA:nLine) == cFil) .AND. ;
		(oStruRIA:GetValue("RIA_MATSUB",oStruRIA:nLine) == cMat)
		cMsg := STR0099//'O substituto informado é o próprio Servidor/Membro!'
		lRet := .F.

	ElseIf lRet .and. (oStruRIA:GetValue("RIA_NEW",oStruRIA:nLine) == "X")

		//Se for reprogramacao de dias remanescentes, nao verificar datas, pois devera deixar passar datas em branco
		If !(upper(substr(alltrim(STR0219),2,len(alltrim(STR0219))-1)) $ upper(oModel:GetValue("RIADETAIL", "RIA_OBS")))  //"(Remanescente)"
			If  (oStruRIA:GetValue("RIA_NRDGOZ",oStruRIA:nLine) > 0) .AND. Empty(oStruRIA:GetValue("RIA_DATPAG",oStruRIA:nLine))
				cMsg := STR0265 //'Por favor, informe a DATA DE PAGAMENTO quando o número de Dias de Gozo é maior que zero!'
				lRet := .F.
			ElseIf  (oStruRIA:GetValue("RIA_NRDIND",oStruRIA:nLine) > 0) .AND. Empty(oStruRIA:GetValue("RIA_DTPGAD",oStruRIA:nLine))
				cMsg := STR0266 //'Por favor, informe a DATA DE PAGAMENTO DA INDENIZAÇÃO/ABONO quando o número de Dias Abono/Indenizado é maior que zero!'
				lRet := .F.
			EndIF
		EndIf

	EndIf

	If !lRet
		Help( ,, 'Help',, cMsg , 1, 0 )
	EndIf

	RestArea(aAreaSRA)
	RestArea( aArea )
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc}  TudOkRIA
Validação TUDO Ok do modelo de dados.
@return		lRet
@author	    Everson S P Junior
@since		27/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function TudOkRIA(oMdl)//OK
	Local aArea     := GetArea()
	Local aAreaSRA  := SRA->(GetArea())
	Local lRet      := .T.
	Local nX		:= 0
	Local oModel    := FWModelActive()
	Local cFil  	:= oModel:GetVALUE("SRFDETAIL","RF_FILIAL" )
	Local cMat	    := oModel:GetVALUE("SRFDETAIL","RF_MAT" )
	Local cPD	    := oModel:GetVALUE("SRFDETAIL","RF_PD" )
	Local cMsg		:= ""
	Local cCargo	:= Posicione("SRA",1, cFil + cMat,"RA_CARGO")

	Local cExigSub  := Posicione("SQ3",1, fwxFilial("SQ3") + cCargo,"Q3_SUBSTIT")
	Local nDMinSub  := Posicione("RCM",3, fwxFilial("RCM") + cPD   ,"RCM_DSUBST")
	Local oStruRIA  := oModel:GetModel("RIADETAIL")

	lRet := LinOkRIA()  //PRIMEIRO VALIDA A LINHA POSICIONADA

	If lRet
		For nX := 1 To oMdl:Length()
			oMdl:GoLine(nX)
			If oMdl:GetValue("RIA_NEW") == "X"  //SOMENTE PARA LINHAS NOVAS
				nDGozo	:= oMdl:GetValue("RIA_NRDGOZ")
				nDInd	:= oMdl:GetValue("RIA_NRDIND")
				dIni 	:= oMdl:GetValue("RIA_DATINI")
				dFim 	:= oMdl:GetValue("RIA_DATFIM")
				cFilSub := oMdl:GetValue("RIA_FILSUB")
				cMatSub := oMdl:GetValue("RIA_MATSUB")

				If nDGozo > 0 //SÓ FAZ AS VALIDAÇÕES ABAIXO SE OS DIAS DE GOZO FOR MAIOR QUE ZERO
					//VERIFICA SE EXIGE SUBSTITUTO
					//VERIFICA SE O CARGO EXIGE , SE NÃO FOI INFORMADO E SE OS DIAS MINIMOS PARA INFORMAR O SUBSTITUTO <= DIAS DE GOZO
					If (cExigSub == "1") .AND. (Empty(cMatSub)) .AND. (nDMinSub <= nDGozo)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Ponto de entrada para aceitar ou não a inclusão quando deixar de informar o substituto exigido pelo cargo.  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ExistBlock("GP051VSUB")
							If !( ExecBlock("GP051VSUB",.F.,.F.) )
								cMsg := STR0100+ cValToChar(nX) +'!'//'O cargo desse servidor/membro exige substituto, porém, o mesmo não foi informado na linha '
								lRet := .F.
								Exit
							EndIf
						Else
							cMsg := STR0100+ cValToChar(nX) +'!'//'O cargo desse servidor/membro exige substituto, porém, o mesmo não foi informado na linha '
							lRet := .F.
							Exit
						EndIf
					EndIf

					//VERIFICA SE O CARGO EXIGE , PORÉM, NÃO PRECISA INFORMAR QUANDO OS DIAS DE GOZO É MENOR QUE O MINIMO PARA INFORMAR O SUBSTITUTO
					If (cExigSub == "1") .AND. !(Empty(cMatSub)) .AND. (nDGozo < nDMinSub)
						cMsg := STR0101+;//'O cargo desse servidor/membro até exige substituto, porém, o mínimo de dias para essa exigência é maior que '
								STR0103+ cValToChar(nX) +STR0102//', sendo assim, não é necessário informar o substituto! Por favor, retire o mesmo!'//'os dias de gozo na linha '
						lRet := .F.
						Exit
					EndIf

					//VERIFICA SE NÃO EXIGE, PORÉM, FOI INFORMADO SUBSTITUTO
					If (cExigSub <> "1") .AND. (!Empty(cFilSub) .or. !Empty(cMatSub))
						cMsg := STR0105+ cValToChar(nX) +STR0104//'. Por favor, retire o mesmo!'//'O cargo desse servidor/membro NÃO exige substituto, porém, o mesmo foi informado na linha '
						lRet := .F.
						Exit
					EndIf

					//AFASTAMENTOS / SUBSTITUIÇÕES
					//VERIFICA SE NO PERÍODO EM QUESTÃO EXISTEM AFASTAMENTOS OU SUBSTITUIÇÕES
					//      fVerRI8(cFil,cMat, dDataDe , dDataAte ,lSR8 , lMsg , lBlq , rRet , lBlqSR8)
					lRet := fVerRI8(cFil,cMat,dIni,dFim,.T.  ,.T.   ,.T.   ,.F.   ,.T.)
					If !lRet
						cMsg := STR0168 + cValToChar(nX) +'!' //
						Exit
					EndIf

					//VERIFICA SE NO PERÍODO EM QUESTÃO EXISTEM AFASTAMENTOS OU SUBSTITUIÇÕES PARA O SUBSTITUTO
					If !(Empty(cMatSub))
						lRet := fVerRI8(cFilSub,cMatSub,dIni,dFim,.T.  ,.T.   ,.T.   ,.F.   ,.T.)
						If !lRet
							cMsg := STR0106+ cValToChar(nX) +'!'//'Verifique o SUBSTITUTO da programação da linha '
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
		Next nX

		If !lRet
			Help( ,, 'Help',, cMsg, 1, 0 )
		EndIf
	Else
		nX := oStruRIA:nLine
	EndIf
	oMdl:GoLine(nX)
	RestArea(aAreaSRA)
	RestArea( aArea )
Return  lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc}  GP051GRV
Validações gerais na gravação da GPEA051
@return		lRet
@author	    Fabricio Amaro
@since		15/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function GP051TUDOK(oModel)
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local nJ			:= 0
Local cPD			:= ""
Local cTIPOAFA		:= ""
Local cPer        	:= ""
Local cNumPg		:= ""
Local cDIASEM    	:= ""
Local cSeqSR8		:= ""
Local cSeqSRK		:= ""
Local cWhere      	:= ""
Local cQueryRG1   	:= GetNextAlias()
Local cFil			:= oModel:GetValue("SRAMASTER", "RA_FILIAL")
Local cMat			:= oModel:GetValue("SRAMASTER", "RA_MAT")
Local lRet			:= .T.
Local aSaveLines 	:= FWSaveRows()
Local aParTela		:= {}
Local aBkpTpDoc 	:= {}
Local aTpDocSub 	:= {}
Local nLinNew		:= 0
Local nLin			:= 0
Local aTable		:= {}
Local cGeraAto		:= ""
Local cTpDDireito	:= ""
Local cMsgCompl	:= ""
Local cDescSt  	:= ""
Local aPerAb,aPerFech,aPerTodos
Local oStruRIA,oStruSRF

Private aTipoDoc 	:= {}

SRA->(dbSeek(cFil+cMAT))

cCateg 	:= SRA->RA_CATFUNC
cRegime := SRA->RA_REGIME

//-aAdd(aPerAberto, RCH->({ 1-RCH_PER, 2-RCH_NUMPAG, 3-RCH_MES, 4-RCH_ANO, 5-RCH_DTINI, 6-RCH_DTFIM, 7-RCH_PROCES, 8-RCH_ROTEIR, 9-RCH_DTPAGO, 10-RCH_DTCORT}))
fRetPerComp(Strzero(month(DATE()),2) , Alltrim(Str(year(DATE()))) , ,SRA->RA_PROCES ,"FOL" , @aPerAb , @aPerFech , @aPerTodos )

If !Empty(aPerAb)
	cPer   := aPerAb[1][1]
	cNumPg := aPerAb[1][2]
EndIf

fCarrTab( @aTable, "S106" ) //CARREGA A TABELA S106 - TIPOS DE DIAS DE DIREITO

Begin Transaction

	oStruRIA  := oModel:GetModel("RIADETAIL")
	oStruSRF  := oModel:GetModel("SRFDETAIL")

	For nX := 1 to oStruSRF:Length()
 		oStruSRF:GoLine(nX)
		cPD		 := oStruSRF:GetValue("RF_PD",nX)
		cFil	 := oStruSRF:GetValue("RF_FILIAL",nX)
		cMat	 := oStruSRF:GetValue("RF_MAT",nX)
		cDIASEM	 := Posicione("RCM",3,FwxFilial("RCM")+cPD,"RCM_DIASEM")
	 	cSeqSRK	 := FProxDoc(xFilial("SRA"),'SRK',cPD,cMat)
	 	cSeqSR8	 := FProxDoc(xFilial("SRA"),'SR8',cPD,cMat)
	 	cGeraAto := ""
		cTIPOAFA := Posicione("RCM",3,FwxFilial("RCM")+cPD,"RCM_TIPO")

		cAltSRF  := oStruSRF:GetValue("SRF_ALT",nX)
		cCancSRF := oStruSRF:GetValue("SRF_CANC",nX)
		cStSRF	 := oStruSRF:GetValue("RF_STATUS",nX)
		cDtCanc	 := oStruSRF:GetValue("RF_DTCANCE",nX)

		//VERIFICA SE A VERBA GERA ATO/PORTARIA NA PROGRAMAÇÃO CONFORME O QUE ESTÁ CADASTRADO NA S106
		For nY:= 1 To Len(aTable)
			If aTable[nY][1] == "S106" .AND. cCateg $ aTable[nY][11] .AND. cREGIME $ aTable[nY][12] .AND. aTable[nY][10] == cPD  //SE FOR DA MESMA CATEGORIA E REGIME E VERBA
				cGeraAto 	:= aTable[nY][7] //GERA ATO/PORTARIA =  1=NA PROGRAMAÇÃO-RIA | 2=NA AQUISIÇÃO-SRF | 3=AMBOS-RIA e SRF
				cTpDDireito := aTable[nY][5] //DESCRIÇÃO DO TIPO DE DIA DE DIREITO
			EndIf
		Next nY

	 	If !(cCancSRF == "X") .and. !(cAltSRF=="X")  //SE NÃO FOR CANCELAMENTO ou ALTERAÇÃO DA SRF

	 	    lRet	:= .T.

		 	//CONTA QUANTAS LINHAS NOVAS TEM
			For nZ := 1 To oStruRIA:Length()
		 		If (oStruRIA:GetValue("RIA_NEW",nZ) 	== "X" .OR. ;
		 			oStruRIA:GetValue("RIA_XSUSPE",nZ) 	== "X" .OR. ;
		 			oStruRIA:GetValue("RIA_CANC",nZ) 	== "X") .And. lRet

		 			nLinNew++

					//Valida se quantidade de indenizações solicitada é válida
					If oStruRIA:GetValue("RIA_NEW",nZ) 	== "X"

                        //Valida indenização apenas para Ferias
                        dbSelectArea("SRV")
                        dbSetOrder(1)
                        If SRV->(dbseek(xFilial("SRV")+oStruRIA:GetValue("RIA_PD",nZ)))
                              //ID - Ferias Ordinarias      ID - Ferias Compens membro   ID - Ferias Estagiario
                           If SRV->RV_CODFOL == "0072" .or. SRV->RV_CODFOL == "1335" .or. SRV->RV_CODFOL == "0891"
								//So valida se ha dias indenizados e data de pagamento de indenizacao preenchidos na programacao
								If oStruRIA:GetValue("RIA_NRDIND",nZ) > 0 .and. !empty(oStruRIA:GetValue("RIA_DTPGAD",nZ))
	        	 					lRet := fValindeni(oStruRIA:GetValue("RIA_NRDIND",nZ), cFil, cMat, oStruRIA:GetValue("RIA_DTPGAD",nZ),cPD)
	                                IF !lRet
	                                    MsgBox(STR0238,STR0158,"INFO") //"Programação não realizada!"
	                                    exit
	                                EndIf
	        	 			   	EndIf
							EndIf
     	 				EndIf
	 				EndIf
		 		EndIf
		 	Next nZ

            IF !lRet
                exit
            EndIf

		 	If lRet
			 	For nJ := 1 To oStruRIA:Length()
			 		oStruRIA:GoLine(nJ)
			 		cMsgCompl := ""

					//MONTA O ARRAY PARA GERAÇÃO DO ATO (CASO O TIPO DE AFASTAMENTO PERMITE)
					cChave := cPD + dtos(oStruRIA:GetValue("RIA_DTINPA",nJ)) + dtos(oStruRIA:GetValue("RIA_DATINI",nJ)) + oStruRIA:GetValue('RIA_SEQPRG',nJ)
					cRotina := "GPEA051"
					dbSelectArea("SRA")
					dbSetOrder(1)
					dbSeek(cFil + cMat)
					aParTela :={cRotina,;
								SRA->RA_MAT,;
								SRA->RA_CATFUNC,;
								cChave,;
								SRA->RA_FILIAL,;
								SRA->RA_CIC,;
								oStruRIA:GetValue("RIA_DATINI",nJ),;  //DATA DO EFEITO
								'1',;
								"RIA",;
								dtos(oStruSRF:GetValue("RF_DATABAS",nX)),;
								dtos(oStruSRF:GetValue('RF_DATAFIM',nX)),;
								dtos(oStruRIA:GetValue("RIA_DATINI",nJ)),;
								dtos(oStruRIA:GetValue("RIA_DATFIM",nJ)),;
									 oStruRIA:GetValue("RIA_NRDGOZ",nJ),;
									 oStruRIA:GetValue("RIA_NRDIND",nJ),;
									 oStruRIA:GetValue('RIA_DOPORT',nJ),;
									 oStruRIA:GetValue("RIA_FILSUB",nJ),;
									 oStruRIA:GetValue("RIA_MATSUB",nJ),;
									 oStruRIA:GetValue('RIA_NMSUBS',nJ),;
									 cTpDDireito,;
									 oStruSRF:GetValue("RF_DIREMAN",nX),;
									 oStruRIA:GetValue("RIA_ATOANT",nJ),;
								dtos(oStruRIA:GetValue("RIA_SUSPEN",nJ));
								}

					//SE FOR UM ITEM NOVO OU ESTIVER SENDO FEITA SUSPENSÃO / CANCELADO / RETIFICADO
					If 	oStruRIA:GetValue("RIA_NEW",nJ) 	== "X" .OR. ;
						oStruRIA:GetValue("RIA_XSUSPE",nJ) 	== "X" .OR. ;
						oStruRIA:GetValue("RIA_CANC",nJ) 	== "X"

						nLin++
						If (oStruRIA:GetValue("RIA_NRDGOZ",nJ) > 0)

							lGrvNew  := .T. //NOVO REGISTRO
							lContSR8 := .T.
							dbSelectArea("SR8")
							If oStruRIA:GetValue("RIA_NEW",nJ) != "X" //Se nao for nova RIA
								If lSuspensao .OR. lCancela .OR. lRetifica //SE FOR SUSPENSÃO / CANCELAMENTO / RETIFICAÇÃO DE PERÍODO TEM QUE ALTERAR A SR8 QUE ESTAVA GRAVADA
									dbSetOrder(6)
									If DbSeek( cFil + cMat + dtos(oStruRIA:GetValue("RIA_DATINI",nJ)) + cTIPOAFA )

										If lCancela .OR. lRetifica //SE FOR PARA CANCELAR OU RETIFICAR, TEM QUE APAGAR O REGISTRO DA SR8
											RecLock("SR8",.F.)
											dbDelete()
											MSUnlock()
											lContSR8 := .F.
											RetSituacao()
										Else
											lGrvNew := .F.  //ALTERA REGISTRO
										EndIf

									Else
										MsgBox(STR0108,STR0107,"INFO")//'Afastamento não encontrado'//'Não foi encontrado o registro de AFASTAMENTO - SR8 - referente a programação em questão! A rotina continuará normalmente.'
										lContSR8 := .F.
									EndIf
								EndIf
							EndIf

							If lContSR8
								RecLock("SR8", lGrvNew)
									If lGrvNew
										R8_FILIAL	:= cFil
										R8_MAT		:= cMat
										R8_SEQ     := cSeqSR8 := StrZero(Val(cSeqSR8) + 1, TAMSX3('R8_SEQ')[1]) //deve respeitar uma sequencia para cada Filial / Matrícula
										R8_DATA	:= Date()
										R8_TIPO	:= ""
										R8_TIPOAFA := cTIPOAFA  //Código da Ausência
										R8_DATAINI	:= oStruRIA:GetValue("RIA_DATINI",nJ)
										R8_PD		:= cPD
										R8_CONTINU	:="2"
										R8_PROCES  := SRA->RA_PROCES
										R8_PER		:= oStruRIA:GetValue("RIA_PERIOD",nJ)	//cPer
										R8_NUMPAGO	:= oStruRIA:GetValue("RIA_NPAGTO",nJ)	//cNumPg
										R8_DNAPLIC	:= 0
										R8_DIASEMP	:= cDIASEM
										R8_FILSUB	:= oStruRIA:GetValue("RIA_FILSUB",nJ)
										R8_MATSUB	:= oStruRIA:GetValue("RIA_MATSUB",nJ)
									EndIf
									R8_DATAFIM	:= oStruRIA:GetValue("RIA_DATFIM",nJ)
									R8_DURACAO	:= oStruRIA:GetValue("RIA_NRDGOZ",nJ)
								SR8->(MsUnlock())
							EndIf
							RetSituacao( SRA->RA_FILIAL , SRA->RA_MAT , .T. )

						EndIf

						//ARMAZENA NA SRH, QUANDO REGIME = ESTATUTÁRIO E VERBA = FÉRIAS
						If cRegime == "2" .AND. Posicione("SRV",1,FWXFILIAL("SRV")+cPD,"RV_CODFOL") == "0072"
							lGrvNew  := .T. //NOVO REGISTRO
							lContSRH := .T.
							dbSelectArea("SRH")
							If lSuspensao .OR. lCancela .OR. lRetifica //SE FOR SUSPENSÃO / CANCELAMENTO / RETIFICAÇÃO DE PERÍODO TEM QUE ALTERAR A SRH QUE ESTAVA GRAVADA
								dbSetOrder(1)  //RH_FILIAL+RH_MAT+DTOS(RH_DATABAS)+DTOS(RH_DATAINI)
								If DbSeek( cFil + cMat + dtos(oStruSRF:GetValue("RF_DATABAS",nX)) + dtos(oStruRIA:GetValue("RIA_DATINI",nJ)) )

									If lCancela .OR. lRetifica //SE FOR PARA CANCELAR OU RETIFICAR, TEM QUE APAGAR O REGISTRO DA SRH
										RecLock("SRH",.F.)
										dbDelete()
										MSUnlock()
										lContSRH := .F.
									Else
										lGrvNew := .F.  //ALTERA REGISTRO
									EndIf
								Else
									lContSRH := .F.
								EndIf
							EndIf

							If lContSRH
								IF SRA->RA_CATFUNC $ "0|1" // MEMBROS
									DDTPAGO := POSICIONE("RCH",1, FwxFilial("RCH") + SRA->RA_PROCES + oStruRIA:GetValue("RIA_PERIOD",nJ) + oStruRIA:GetValue("RIA_NPAGTO",nJ) + "170" ,"RCH_DTPAGO")
								ELSE
									DDTPAGO := POSICIONE("RCH",1, FwxFilial("RCH") + SRA->RA_PROCES + oStruRIA:GetValue("RIA_PERIOD",nJ) + oStruRIA:GetValue("RIA_NPAGTO",nJ) + "060" ,"RCH_DTPAGO")
								EndIF

								RecLock("SRH", lGrvNew)
									If lGrvNew
										RH_FILIAL	:= cFil
										RH_MAT		:= cMat
										RH_SALMES	:= SRA->RA_SALARIO
										RH_SALDIA	:= (SRA->RA_SALARIO / 30)
										RH_SALHRS	:= (SRA->RA_SALARIO / SRA->RA_HRSMES)
										RH_DATABAS	:= oStruSRF:GetValue("RF_DATABAS",nX)
										RH_DBASEAT	:= oStruSRF:GetValue("RF_DATAFIM",nX)
										RH_DATAINI	:= oStruRIA:GetValue("RIA_DATINI",nJ)
									EndIf
									RH_DATAFIM	:= oStruRIA:GetValue("RIA_DATFIM",nJ)
									RH_DFERVEN	:= oStruSRF:GetValue("RF_DIASDIR",nX)
									RH_DFERIAS	:= oStruRIA:GetValue("RIA_NRDGOZ",nJ)
									RH_DABONPE	:= oStruRIA:GetValue("RIA_NRDIND",nJ)
									RH_DTRECIB  := DDTPAGO
								SRH->(MsUnlock())
							EndIf
						EndIf

						If (oStruRIA:GetValue("RIA_NRDIND",nJ) > 0) .AND. Posicione("SRV",1,FWXFILIAL("SRV")+cPD,"RV_CODFOL") == "1332" // Para atender a Licença Premio.
							cPdAd := FGETCODFOL("1333")
							lGrvNew  := .T. //NOVO REGISTRO
							lContRG1 := .T.
							dbSelectArea("RG1")
							If lSuspensao .OR. lCancela .OR. lRetifica //SE FOR SUSPENSÃO / CANCELAMENTO / RETIFICAÇÃO DE PERÍODO TEM QUE ALTERAR A SR8 QUE ESTAVA GRAVADA
								dbSetOrder(2)
								If RG1->(DbSeek( cFil + cMat + cPdAd + dtos(RiaDtPgAd) )) //dtos(oStruRIA:GetValue("RIA_DATPAG",nJ))))

									If lCancela .OR. lRetifica //SE FOR PARA CANCELAR OU RETIFICAR, TEM QUE APAGAR O REGISTRO DA RG1
										RecLock("RG1",.F.)
										dbDelete()
										MSUnlock()
										lContRG1 := .F.
									Else
										lGrvNew := .F.  //ALTERA REGISTRO
									EndIf

								Else
									//MsgBox('','',"INFO")
									lContRG1 := .F.
								EndIf
							EndIf
							If lContRG1
								If lGrvNew
									//-Verifica qual o Ultimo RG1_ORDEM gravado no RG1
                                    cWhere := "%"
                                    cWhere += " AND RG1.RG1_FILIAL = '" + cFil + "'"
                                    cWhere += " AND RG1.RG1_MAT    = '" + cMAT + "'"
                                    cWhere += "%"
                                    BeginSql alias cQueryRG1
                                        SELECT RG1_ORDEM
                                        FROM %table:RG1% RG1
                                              WHERE RG1.%notDel%
                                                    %exp:cWhere%
                                        ORDER BY RG1_ORDEM DESC
                                    EndSql

									//-Grava o registro na RG1
									RecLock("RG1", lGrvNew)
										RG1_FILIAL	:= 	cFil
										RG1_MAT 	:=	cMat
										RG1_ORDEM	:=	StrZero(Val((cQueryRG1)->RG1_ORDEM)+1,3)
										RG1_AUTOM	:= 	"1"
										RG1_TPCALC	:=	"2"
										RG1_PD 		:=	cPdAd //Provento da indenização Licença Prêmio
										RG1_REFER 	:=	(oStruRIA:GetValue("RIA_NRDIND",nJ) / oStruRIA:GetValue("RIA_PARMEM",nJ))
										RG1_PROP 	:=	"2"
										RG1_CC 		:=	SRA->RA_CC
										RG1_DINIPG	:=	oStruRIA:GetValue("RIA_DTPGAD",nJ)
										RG1_LIBPAG	:=	oStruRIA:GetValue("RIA_DATPAG",nJ)
										RG1_DFIMPG	:=	MonthSum( oStruRIA:GetValue("RIA_DTPGAD",nJ) , oStruRIA:GetValue("RIA_PARMEM",nJ) - 1 )//(oStruRIA:GetValue("RIA_DATPAG",nJ)+(oStruRIA:GetValue("RIA_PARMEM",nJ)*30)-30)
										RG1_PROCES	:=	SRA->RA_PROCES
										RG1_PERIOD	:=	oStruRIA:GetValue("RIA_PERIOD",nJ)
										RG1_SEMANA	:=	oStruRIA:GetValue("RIA_NPAGTO",nJ)
										RG1_ROT     :=	"250"
										RG1_STATUS  :=  "1"

									MSUnlock()

                                   (cQueryRG1)->(dbCloseArea())
								EndIf
							EndIf
						EndIf


						IF lSuspensao
							cMsgCompl :=  STR0119 //' SUSPENSÃO da'
						ElseIf lCancela
							cMsgCompl :=  STR0200 //' CANCELAMENTO da'
						ElseIf lRetifica
							cMsgCompl :=  STR0201 //' RETIFICAÇÃO da'
						EndIf

						//SE FOR PARA GERAR ATO/PORTARIA
						If cGeraAto $ "1*3"

							If !lCancela
								If (oStruRIA:GetValue("RIA_NRDGOZ",nJ) == 0) .AND. (oStruRIA:GetValue("RIA_NRDIND",nJ) > 0) //SE HOUVER APENAS INDENIZAÇÃO/ABONO
									cMsgCompl +=  STR0109//' INDENIZAÇÃO/ABONO da'
								EndIf

								MsgBox( STR0112 + cMsgCompl + STR0111 + ;//' programação do periodo de '//'Será gerado o item do Ato/Portaria ref. a'
										 dtoc(oStruRIA:GetValue("RIA_DATINI",nJ)) + STR0113 + ; //' a '
										 dtoc(oStruRIA:GetValue("RIA_DATFIM",nJ)) + STR0114 + transform(nJ,"@E 99") ,STR0116 + transform(nLin,"@E 99") + STR0115 + transform(nLinNew,"@E 99") ,"INFO")//' - Item '//' de '//'Item do Ato/Portaria - Processo '

								VDFA060(aParTela)
							ElseIf lCancela
								//SE FOR APENAS PARA CANCELAR
                                If lVerRI6
    								dbSelectArea("RI6")
    								dbSetOrder(4)
    								If DbSeek( xFilial("RI6") + SRA->RA_FILIAL + SRA->RA_MAT + "RIA" + cChave )
    									If Empty(RI6->RI6_NUMDOC)  //VERIFICA NOVAMENTE SE REALMENTE NÃO PUBLICOU O ATO/PORTARIA
    										RecLock("RI6",.F.)
    										dbDelete()
    										MSUnlock()
    									Else
    										cMsg := STR0202 + RI6->RI6_NUMDOC + RI6->RI6_TIPDOC + RI6->RI6_ANO + ; //'Atenção! O Ato/Portaria para essa programação foi PUBLICADO no decorrer desse processo - N: '
    												STR0203 //', portanto, esse não poderá ser CANCELADO. Deverá ser feito MANUALMENTE o processo de RETIFICAÇÃO! O processo continuará normalmente.'
    										MsgBox(cMsg,,"INFO") //'Ato/Portaria já Publicado!'
    									EndIf
    								EndIf
    							EndIf

							EndIf
						EndIf

						//SE HOUVER SUBSTITUTO E SE OS DIAS DE GOZO FOR MAIOR QUE ZERO OU SE FOR SUSPENSÃO
						If  !(Empty(oStruRIA:GetValue("RIA_MATSUB",nJ))) .AND. ;
								( oStruRIA:GetValue("RIA_NRDGOZ",nJ) > 0 .OR. (lSuspensao .OR. lCancela .OR. lRetifica) )

							lGrvNew   := .T. //NOVO REGISTRO
							lContRI8  := .T.
							dbSelectArea("RI8")
							If lSuspensao .OR. lCancela .OR. lRetifica //SE FOR SUSPENSÃO DE PERÍODO TEM QUE ALTERAR A RI8 QUE ESTAVA GRAVADA
								dbSetOrder(1)
								If DbSeek( cFil + cMat + dtos(oStruRIA:GetValue("RIA_DATINI",nJ)) )

									If lCancela .OR. lRetifica //SE FOR PARA CANCELAR OU RETIFICAR, TEM QUE APAGAR O REGISTRO DA SR8
										RecLock("RI8",.F.)
										dbDelete()
										MSUnlock()
										lContRI8 := .F.
									Else
										lGrvNew := .F.  //ALTERA REGISTRO
									EndIf

								Else
									MsgBox(STR0117,STR0118,"INFO")//'Não foi encontrado o registro de SUBSTITUIÇÃO - RI8 - referente a programação em questão! A rotina continuará normalmente.'//'Substituição não encontrada'
									lContRI8 := .F.
								EndIf
							EndIf
							If lContRI8
								RecLock("RI8",lGrvNew)
									If lGrvNew

										cPerPagto := INIDATPAG( If(oStruRIA:GetValue("RIA_DATINI",nJ) < Date(),Date(),oStruRIA:GetValue("RIA_DATINI",nJ)) ,.T.,SRA->RA_PROCES)
										cPerPagto := If( Empty(cPerPagto)   , LastDay( oStruRIA:GetValue("RIA_DATINI",nJ) ) , cPerPagto )

										RI8_FILIAL	:= SRA->RA_FILIAL
										RI8_MAT		:= SRA->RA_MAT
										RI8_DATADE	:= oStruRIA:GetValue("RIA_DATINI",nJ)
										RI8_PERIOD	:= MesAno(cPerPagto)
										RI8_DIASDIR	:= POSICIONE("RCM",3, FwxFilial("RCM") + cPD,"RCM_DSUBST")
										RI8_FILSUB	:= oStruRIA:GetValue("RIA_FILSUB",nJ)
										RI8_MATSUB	:= oStruRIA:GetValue("RIA_MATSUB",nJ)
										RI8_DEPTO	:= SRA->RA_DEPTO
										RI8_FATGER	:= "1"
										RI8_ORIGEM	:= "2"
									EndIf

									RI8_DATATE	:= oStruRIA:GetValue("RIA_DATFIM",nJ)
									RI8_DIAS	:= oStruRIA:GetValue("RIA_DATFIM",nJ) - oStruRIA:GetValue("RIA_DATINI",nJ) + 1
								RI8->(MsUnlock())
							EndIf

							//VERIFICA SE JÁ HOUVE PAGTO OU SE OS DIAS DE DIREITO É MENOR QUE OS DIAS DE GOZO
							If lSuspensao .OR. lCancela .OR. lRetifica
								If RI8->RI8_PERIOD <= MesAno(Date()) //SE O PERIODO DE PAGAMENTO FOR O MES ANTERIOR OU O CORRENTE

									If RI8->RI8_DIAS < RI8_DIASDIR
										cMsg := STR0120//'Os dias de substituição ficaram menores que os dias de direito mínimo, portanto, não é necessário o pagamento, entretanto, esse já foi realizado!'
									Else
										cMsg := STR0121//'O pagamento pertinente a essa substitução já foi realizado!'
									EndIf

									MsgBox(cMsg + cEnt + STR0124+cEnt+STR0122,STR0123,"INFO")//'A rotina será concluida normalmente!'//'Pagamento Substituição'//'Verifique a necessidade de devolução! '

								EndIf
							EndIf

							If cGeraAto $ "1*3"

								If !lCancela
									MsgBox( STR0126 + cMsgCompl + STR0125 +;//' programação do periodo de '//'Será gerado o item do Ato/Portaria da SUBSTITUIÇÃO referente a'
											 dtoc(oStruRIA:GetValue("RIA_DATINI",nJ)) + STR0127 + ; //' a '
											 dtoc(oStruRIA:GetValue("RIA_DATFIM",nJ)) + STR0128 + transform(nJ,"@E 99") ,STR0130 + transform(nLin,"@E 99") + STR0129 + transform(nLinNew,"@E 99") ,"INFO")//' - Item '//' de '//'Item do Ato/Portaria - Processo '

									aBkpTpDoc := aTipoDoc
									aTipoDoc  := {}

									If Len(aTpDocSub) > 0
										aTipoDoc := aTpDocSub
									EndIf

									dbSelectArea("RI6")
									dbSetOrder(4)
									dbSeek( FwxFilial("RI6") + SRA->RA_FILIAL + SRA->RA_MAT + "RI8" + DtoS(oStruRIA:GetValue("RIA_DATINI",nJ)) )

									SETFUNNAME("VDFA070")
									aParTela[1]  := "VDFA070"
									aParTela[9]  := "RI8"
									aParTela[4]  := dtos(oStruRIA:GetValue("RIA_DATINI",nJ))
									aParTela[22] := RI6->RI6_NUMDOC + RI6->RI6_TIPDOC + RI6->RI6_ANO

									If lSuspensao
										aParTela[7] := oStruRIA:GetValue("RIA_DATFIM",nJ) + 1  //ALTERA A DATA DO EFEITO PARA O DIA FINAL DO GOZO + 1
									ElseIf lCancela .OR. lRetifica
										aParTela[7] := oStruRIA:GetValue("RIA_SUSPEN",nJ)
									EndIf

									VDFA060(aParTela)

									SETFUNNAME("GPEA051")

									aTpDocSub := aTipoDoc
									aTipoDoc  := aBkpTpDoc

								ElseIf lCancela
									//SE FOR APENAS PARA CANCELAR
									dbSelectArea("RI6")
									dbSetOrder(4)
									If DbSeek( xFilial("RI6") + SRA->RA_FILIAL + SRA->RA_MAT + "RI8" + dtos(oStruRIA:GetValue("RIA_DATINI",nJ)) )
										If Empty(RI6->RI6_NUMDOC) //VERIFICA NOVAMENTE SE REALMENTE NÃO PUBLICOU O ATO/PORTARIA
											RecLock("RI6",.F.)
											dbDelete()
											MSUnlock()
										Else
											cMsg := STR0205 + RI6->RI6_NUMDOC + RI6->RI6_TIPDOC + RI6->RI6_ANO + ; //'Atenção! O Ato/Portaria para essa SUBSTITUIÇÃO já foi PUBLICADO - N: '
													STR0206 //', portanto, esse não poderá ser CANCELADO. Deverá ser feito MANUALMENTE o processo de Retificação da Substituição! O processo continuará normalmente.'
											//Help( ,, "Help",, cMsg, 1, 0 )
											MsgBox(cMsg,STR0204,"INFO")  //'Ato/Portaria já Publicado!'
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				Next nJ
			EndIf
		ElseIF cCancSRF == "X" .or. cAltSRF=="X" //SE FOR CANCELAMENTO/PRESCRIÇÃO ou ALTERAÇÃO DA SRF

			cNumAto := ""
			cMsgCompl	:= STR0207 //'ao CANCELAMENTO'
			cDescSt   	:= STR0208 //'CANCELADO'

			Begin Transaction

				If cGeraAto $ "2*3"

					cRotina := "GPEA051"
					dbSelectArea("SRA")
					dbSetOrder(1)
					dbSeek(cFil + cMat)

					If cAltSRF=="X" //Se ALTERAÇÃO da SRF
						cMsgCompl	:= STR0259 //'a ALTERAÇÃO'
						cDescSt		:= alltrim(substr(aStatus[Ascan(aStatus,{|x| left(x,1) == cStSRF})],3,20))

					//PESQUISA SE GEROU ATO
					ElseIf cStSRF $ "4*5" //CANCELAMENTO OU RETIFICAÇÃO
						dbSelectArea("RI6")
						dbSetOrder(4)
						If DbSeek( FwxFilial("RI6") + SRA->RA_FILIAL + SRA->RA_MAT + "SRF" + cPD + DtoS(oStruSRF:GetValue("RF_DATABAS",nX)) )
							If Empty(RI6->RI6_NUMDOC) //VERIFICA NOVAMENTE SE REALMENTE NÃO PUBLICOU O ATO/PORTARIA
								RecLock("RI6",.F.)
									dbDelete()
								MSUnlock()
							Else
								cNumAto 	:= RI6->RI6_TIPDOC + RI6->RI6_NUMDOC + RI6->RI6_ANO
								cMsgCompl 	:= STR0209 //'a RETIFICAÇÃO '
								cDescSt  	:= STR0210 //'RETIFICADO'
							EndIf
						EndIf
					Else //PRESCREVER
						cMsgCompl	:= STR0211 //'a PRESCRIÇÃO'
						cDescSt		:= STR0212 //'PRESCRITO'
					EndIf

					aParTela :={cRotina,;										//aParametro[1] Fonte 	Fonte que chamou.
								SRA->RA_MAT,;									//aParametro[2] RA_MAT 	Matricula do Funcionario.
								SRA->RA_CATFUNC,;								//aParametro[3] CatFunc   Categoria do Funcionario.
								cPD + DtoS(oStruSRF:GetValue("RF_DATABAS",nX)),;//aParametro[4] Chave 	Para gravação do Historioco RI6
								SRA->RA_FILIAL,;								//aParametro[5] Filial 	Filial do funcionario transferido
								SRA->RA_CIC,;									//aParametro[6] CPF Do funcionario transferido
								oStruSRF:GetValue("RF_DTCANCE",nX),;			//aParametro[7] Data de Efeito
								"2",;											//aParametro[8] Indice da tabela
								"SRF",;											//aParametro[9] Alias da tabela
								DtoS(oStruSRF:GetValue("RF_DATABAS",nX)),;		//aParametro[10] Data Base Inicio
								DtoS(oStruSRF:GetValue("RF_DATAFIM",nX)),;		//aParametro[11] Data Base Fim
								"",;											//aParametro[12] Data Inicio Gozo
								"",;											//aParametro[13] Data Fim Gozo
								oStruSRF:GetValue("RF_DIASDIR",nX),; 			//aParametro[14] Dias de Gozo/Direito
								"",;                                            //aParametro[15] Dias Indenizados
								"",;                                            //aParametro[16] Dias Oportunos
								"",;                                            //aParametro[17] Filial do Substituto
								"",;                                            //aParametro[18] Matricula do Substituto
								"",;                                            //aParametro[19] Nome do Substituto
								cTpDDireito,;									//aParametro[20] Tipo de Dia de Direito
								0,;                                             //aParametro[21] Dias Remanescentes
								cNumAto,;                                       //aParametro[22] Ato/Portaria Anterior
								DtoS(oStruSRF:GetValue("RF_DTCANCE",nX)),;      //aParametro[23] Data da Suspensão
								cDescSt; 										//aParametro[24] Descrição do Status da Linha
								}

					MsgBox(STR0214 + cMsgCompl + STR0213 +;  //'Será gerado o item do Ato/Portaria ref. '   ' do periodo de '
							 dtoc(oStruSRF:GetValue("RF_DATABAS",nX)) + STR0077 + dtoc(oStruSRF:GetValue("RF_DATAFIM",nX)) + ' - ' + cTpDDireito,STR0078,"INFO")//' a '//'Item do Ato/Portaria'

					VDFA060(aParTela)
				EndIf
			End Transaction
		EndIf
	Next nX
End Transaction


lEmInc	 	:= .F.
lEmProgr 	:= .F.
lSuspensao	:= .F.
lCancela 	:= .F.
lRetifica 	:= .F.
LCANCSRF	:= .F.
LAltSRF		:= .F.

FWRestRows( aSaveLines )


//Retornar .T. para não mostrar tela de help sem mensagens
Return lRet



//------------------------------------------------------------------------------
/*/{Protheus.doc}  GP051CAN
Cancelamento da GPEA051
@return		lRet
@author	    Fabricio Amaro
@since		15/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function GP051CAN(oModel)
	lEmInc	 	:= .F.
	lEmProgr 	:= .F.
	lSuspensao	:= .F.
	lRetifica 	:= .F.
	lCancela 	:= .F.
	lCancSRF 	:= .F.
	lAltSRF 	:= .F.
Return .T.


//------------------------------------------------------------------------------
/*/{Protheus.doc}  VDFPROGFE
Programaçao dos Dias de Direito
@return		lRet
@author	    Everson S P Junior
@since		11/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFPROGFE()
	Local nGeraRia 	:= 0
	Local nX		    := 0
	Local cTipPro	    := "" //BR1_S10701 - Tipo Programação
	Local lOk		    := .F.
	Local aArea    	:= GetArea()
	Local aVetor 	    := {}
    Local aQtdeDias   := {}
	Local oModel   	:= FWModelActive()
	Local oStruRIA 	:= oModel:GetModel("RIADETAIL")
	Local oStruSRF 	:= oModel:GetModel("SRFDETAIL")
    Local cPDId        := ""
    Local nDias        := 0
    Local i            := 0
    Local cTitulo     := STR0132 + dtoc(oModel:GetValue("SRFDETAIL", "RF_DATABAS")) + STR0131 + dtoc(oModel:GetValue("SRFDETAIL", "RF_DATAFIM"))  //' a '//'Programar Dias de Direito - Data Base: '
    Local cStatus     := oModel:GetValue("SRFDETAIL", "RF_STATUS")
	Local oDlg
	Local oLbx
	Local oData
	Local oDGoz
	Local oDInd
	Local lRetifFun   := IsInCallStack("fProgramRetif")

	If !lRetifFun .And. ( lSuspensao .OR. lCancela .OR. lRetifica .OR. LCANCSRF .OR. lAltSRF )
		MsgBox( STR0173 ,STR0174,"STOP") // "Existe um proceso em andamento. Conclua o processo!" "Processo em andamento"
		RestArea(aArea)
		Return
	EndIf

	//0=Em aquisicao;1=Ativo;2=Prescrito;3=Pago;4=Cancelado
	If !(cStatus $ "0*1") //EM AQUISIÇÃO OU ATIVO
		MsgBox( STR0191 , STR0138 ,"STOP")  //'O período em questão já se encontra PRESCRITO / PAGO / CANCELADO, portanto não pode sofrer alteração!'  'Dia de Direito'
		RestArea(aArea)
		Return
	EndIf

	//VERIFICA SE EXISTE PROGRAMAÇÕES A LINHA ANTERIOR QUE PRECISAM SER CONCLUIDA
	nLinBkp := oStruSRF:nline
	For i := 1 To oStruSRF:Length()
		If i < nLinBkp
			oStruSRF:GoLine(i)
			If !((oModel:GetValue("SRFDETAIL","RF_DIASDIR") - oModel:GetValue("SRFDETAIL","RF_DIASPRG")) == 0) .AND. oModel:GetValue("SRFDETAIL","RF_STATUS") $ "0*1"
				MsgBox( STR0135 + cEnt + ;//'Existe programação anterior que precisa ser concluida:'
						STR0136 + dtoc(oModel:GetValue("SRFDETAIL","RF_DATABAS"))+ cEnt + ;//'Data Base Inicial: '
						STR0137 + dtoc(oModel:GetValue("SRFDETAIL",'RF_DATAFIM'))+ cEnt + ;//'Data Base Final: '
						STR0138 + cValToChar(oModel:GetValue("SRFDETAIL","RF_DIASDIR"))+ cEnt + ;//'Dias de Direito: '
						STR0139 + cValToChar(oModel:GetValue("SRFDETAIL","RF_DIASPRG")) , cTitulo,"STOP" )//'Dias Programados: '
				RestArea(aArea)
				Return
			EndIf
		Else
			oStruSRF:GoLine(nLinBkp)
			Exit
		EndIf
	Next i

	If !lEmProgr //SE NÃO TIVER NENHUMA PROGRAMAÇÃO SENDO FEITA
		Private lSubsTp := "MSSQL" $ AllTrim( Upper( TcGetDb() ) ) .Or. AllTrim( Upper( TcGetDb() ) ) == 'SYBASE'

		If SRV->(dbSeek(xFilial("SRV") + oModel:GetValue("SRFDETAIL","RF_PD")))
			cPDId := SRV->RV_CODFOL
		EndIf

		/*BR1_S10701 - Tipo Programação:
		1=Licença Prêmio;
		2=Férias Ordinárias Membro;
		3=Férias Regulamentares Servidor;
		4=Férias Compensatórias;
		5=Férias Estagiário;
		6=Férias Gerais
		*/
		SRA->(dbSeek(oModel:GetValue("SRFDETAIL","RF_FILIAL") + oModel:GetValue("SRFDETAIL","RF_MAT")))
		If cPDId == "1332"  // 1=Licença Prêmio;
			cTipPro := '1'
		ElseIf cPDId == "0072" .AND. SRA->RA_CATFUNC $ "0*1"  //2=Férias Ordinárias Membro;
			cTipPro := '2'
		ElseIf cPDId == "0072" .AND. SRA->RA_CATFUNC $ "2*3*4*5*6" //3=Férias Regulamentares Servidor;
			cTipPro := '3'
		ElseIf cPDId == "1335" .AND. SRA->RA_CATFUNC $ "0|1" //4=Férias Compensatórias;
			cTipPro := '4'
		ElseIf cPDId == "0891" .AND. SRA->RA_CATFUNC $ 'E;G' //5=Férias Estagiário;
			cTipPro := '5'
		Else
			cTipPro := '6'
		EndIf

		If lRetifFun
			nDReman := 0
			nDDir   := oModel:GetValue("SRFDETAIL", "RF_DIASDIR")
			nDProg  := 0
		Else
			nDReman	:= oModel:GetValue("SRFDETAIL", "RF_DIREMAN")
			nDDir   := oModel:GetValue("SRFDETAIL", "RF_DIASDIR")
			nDProg  := oModel:GetValue("SRFDETAIL", "RF_DIASPRG")
			cPD     := oModel:GetValue("SRFDETAIL", "RF_PD")
		EndIf

		nDias   := nDDir - nDProg
		ndInd	:= 0
		cCateg 	:= SRA->RA_CATFUNC
		cRegime := SRA->RA_REGIME

		If !(cTipPro == "6") //NÃO FOR OUTROS TIPOS DE DIAS
			//TRATAMENTO ESPECIFICO PARA MEMBROS, POIS PRECISA PROGRAMAR DE 30 EM 30 DIAS
			If nDDir == 60  .AND. nDias > 30 .AND. cPDID == "0072" .AND. SRA->RA_CATFUNC $ "0*1"
                AAdd(aQtdeDias, nDias)
                AAdd(aQtdeDias, nDias - 30)

                aVetor := LISTS107(oModel,cTipPro,0,ndReman,ndInd,,aQtdeDias)
            Else
                aVetor := LISTS107(oModel,cTipPro, If( nDReman > 0, 0 ,nDias),ndReman,ndInd)
			EndIf

			// Monta a tela para usuário visualizar consulta.
			If Len( aVetor ) > 0 .AND. nDias > 0
				DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,920 PIXEL

				   // Primeira opção para montar o listbox.
				   @ 10,10 LISTBOX oLbx FIELDS HEADER STR0142,STR0140,STR0141, ;//'Dias Gozo 1'//'Dias Gozo 2'//'Tipo de Programação'
				   									  STR0143,STR0144,STR0145 SIZE 450,95 OF oDlg PIXEL 	//'Dias Indeniz./Abono'//'Dias Oportuno'//'Dias Total'

				   oLbx:SetArray( aVetor )
				   oLbx:bLine := {|| {aVetor[oLbx:nAt,1],;
				                      aVetor[oLbx:nAt,2],;
				                      aVetor[oLbx:nAt,3],;
				                      aVetor[oLbx:nAt,5],;
				                      aVetor[oLbx:nAt,6],;
				                      aVetor[oLbx:nAt,4]}}

					DEFINE SBUTTON FROM 107,380 TYPE 1 ACTION (GeraRia(oLbx:nAt,aVetor,oModel),oDlg:End())	ENABLE OF oDlg
					DEFINE SBUTTON FROM 107,410 TYPE 2 ACTION oDlg:End()									ENABLE OF oDlg
				ACTIVATE MSDIALOG oDlg CENTER
			ElseIf nDias == 0
				MsgBox(STR0146,cTitulo,"INFO" )//'O periodo em questão já está totalmente programado!'
			Else
				MsgBox(STR0147,cTitulo,"INFO" )//'Não existem dados na tabela S107-Combinação de Gozo/Indenização'
			EndIf
		Else

			cTrDescInd 	:= ""
			aTable		:= {}
			fCarrTab( @aTable, "S106" ) //CARREGA A TABELA S106 - TIPOS DE DIAS DE DIREITO

			//VERIFICA SE TROCA DESCANSO POR INDENIZAÇÃO
			For i := 1 To Len(aTable)
				If aTable[i][1] == "S106" .AND. cCateg $ aTable[i][11] .AND. cREGIME $ aTable[i][12] .AND. aTable[i][10] == cPD  //SE FOR DA MESMA CATEGORIA E REGIME E VERBA
					cTrDescInd 	:= aTable[i][8] //TROCA DESCANSO POR INDENIZAÇÃO
				EndIf
			Next i

			dNewData := Date()
			nDGoz	 := nDias
			nDInd	 := 0

			DEFINE MSDIALOG oDlg TITLE STR0167 FROM C(201),C(239) TO C(300),C(500) PIXEL//'Programar dias de Direito'

				@ C(010),C(030) Say STR0166	Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg//'Dias de Gozo:'
				@ C(008),C(075) MsGet oDGoz 	Var ndGoz PICTURE "@E 999"	Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg

				If cTrDescInd == "1"
					@ C(020),C(030) Say STR0165	Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg//'Dias Indenizados:'
					@ C(018),C(075) MsGet oDInd 	Var nDInd	PICTURE "@E 999" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
				EndIf

				@ C(030),C(060) BmpButton Type 1 Action Close(oDlg)

			ACTIVATE MSDIALOG oDlg CENTERED

			If (nDGoz + ndInd) > nDias
				Alert( STR0164 ) //"O total de dias informado é maior que o de dias de Direito!"
				Return
			EndIf

			If nDGoz < 0 .or. ndInd < 0
				Alert( STR0246 ) //"Não pode ser informada quantidade negativa!"
				Return
			EndIf

			ndOport := nDias - (nDGoz + ndInd)

			aVetor := LISTS107(oModel,cTipPro,nDGoz,0,ndInd,ndOport)

			// Monta a tela para usuário visualizar consulta.
			If Len( aVetor ) > 0
				DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,920 PIXEL

				   // Primeira opção para montar o listbox.
				   @ 10,10 LISTBOX oLbx FIELDS HEADER STR0142,STR0140,STR0141, ;//'Dias Gozo 1'//'Dias Gozo 2'//'Tipo de Programação'
				   									  STR0143,STR0144,STR0145 SIZE 450,95 OF oDlg PIXEL 	//'Dias Indeniz./Abono'//'Dias Oportuno'//'Dias Total'

				   oLbx:SetArray( aVetor )
				   oLbx:bLine := {|| {aVetor[oLbx:nAt,1],;
				                      aVetor[oLbx:nAt,2],;
				                      aVetor[oLbx:nAt,3],;
				                      aVetor[oLbx:nAt,5],;
				                      aVetor[oLbx:nAt,6],;
				                      aVetor[oLbx:nAt,4]}}

					DEFINE SBUTTON FROM 107,380 TYPE 1 ACTION (GeraRia(oLbx:nAt,aVetor,oModel),oDlg:End())	ENABLE OF oDlg
					DEFINE SBUTTON FROM 107,410 TYPE 2 ACTION oDlg:End()									ENABLE OF oDlg
				ACTIVATE MSDIALOG oDlg CENTER
			Else
				MsgBox(STR0147,cTitulo,"INFO" )//'Não existem dados na tabela S107-Combinação de Gozo/Indenização'
			EndIf
		EndIf
	Else
		MsgBox( STR0148 + cEnt + ;//"Existe uma programação em andamento! "
				STR0149+cEnt+;//"Conclua essa programação, confirme, e volte para fazer as demais programações!"
				STR0150,cTitulo,"STOP" )//"Caso não queira continurar com essa programação, feche sem salvar, e volte para fazer novamente!"
	EndIf
	RestArea( aArea )
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} GeraRia()
Gerar Ria de acordo com o Tipo Selecionado
na tela de listBox.
@return		lRet
@author		Everson S P Junior
@since		14/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function GeraRia(nLin,aVetor,oModel,dIniGoz)
	Local lRet		:= .T.
	Local aArea    	:= GetArea()
	Local nX,nL		:= 0
	Local nGeraRia	:= 0
	Local oStruRIA 	:= oModel:GetModel("RIADETAIL")
	Local oStruSRF 	:= oModel:GetModel("SRFDETAIL")
	Local cPD 		:= oModel:GetValue("SRFDETAIL", "RF_PD")
	Local dDtBase 	:= oModel:GetValue("SRFDETAIL", "RF_DATABAS")
	Local dDtBasFim	:= oModel:GetValue("SRFDETAIL", "RF_DATAFIM")
	Local cFil 		:= oModel:GetValue("SRFDETAIL", "RF_FILIAL")
	Local cMat	 	:= oModel:GetValue("SRFDETAIL", "RF_MAT")
	Local dIni 		:= Date()
	Local dIniPer	:= STOD("")
	Local nDReman   := oModel:GetValue("SRFDETAIL", "RF_DIREMAN")
	Local dDatPag   := ctod("//")
	Local dDtPgAd   := ctod("//")
	Local cPeriod   := ""
	Local cNPagto   := ""

	SRA->(dbSeek(cFil+cMat))

	If (aVetor[nLin,2]) > 0  //DIAS DE GOZO 1
		nGeraRia++
	EndIf
	If (aVetor[nLin,3]) > 0 //DIAS DE GOZO 2
		nGeraRia++
	EndIf

	If nGeraRia == 0 .AND. aVetor[nLin,5] > 0//DIAS INDENIZADOS
		nGeraRia++
	EndIf

	cSeq := fPrxSeqFer(cFil,cMat,cPD,dDtBase)
	lIni := (Empty(oModel:GetValue("RIADETAIL","RIA_FILIAL")))

	If oStruRIA:Length() > 0 .AND. !lIni //SE NÃO FOR INCLUSÃO
		oStruRIA:GoLine( oStruRIA:Length() )
		dIni := oModel:GetValue("RIADETAIL", "RIA_DATFIM")  +  1//PEGA A DATA DA ULTIMA PROGRAMAÇÃO
		If dIni < Date() //SE A DATA DA PROGRAMAÇÃO FOR MENOR, SUGERE A DATA DO DIA
			dIni := Date()
		EndIf
 		//Se existe dias remanescentes na SRF, entao a programacao devera utilizar a mesma data de pagamento utilizada na suspensao,
 		//que é a mesma da ultima RIA existente.
 		If nDReman > 0
			dDatPag   := oModel:GetValue("RIADETAIL", "RIA_DATPAG")
			dDtPgAd   := oModel:GetValue("RIADETAIL", "RIA_DTPGAD")
			cPeriod   := oModel:GetValue("RIADETAIL", "RIA_PERIOD")
			cNPagto   := oModel:GetValue("RIADETAIL", "RIA_NPAGTO")
		EndIf
	Else
		If dIni <= dDtBasFim
			dIni := dDtBasFim + 1
		EndIf
	EndIf

	For nX := 1 To nGeraRia
		If( !lIni , oStruRIA:AddLine() , lIni := .F. )
		SRA->(dbSeek(cFil+cMat)) //Posiciona SRA novamente, pois o addline desposiciona

		If nX == 1
			dDtPagto   := If (aVetor[nLin,2] > 0,  INIDATPAG( If(dIni < Date(),Date(),dIni) ,.T., SRA->RA_PROCES , , @dIniPer ) , stod(""))
			dDtPagtoAd := INIDATPAG( If(Empty(dIniPer), If(Empty(dDtPagto),dIni,dDtPagto-1) , dIniPer - 1) ,.T., SRA->RA_PROCES ) //TEM QUE PAGAR NO PERIODO ANTERIOR

			//CASO A DATA NÃO SEJA ENCONTRADA POIS NÃO EXISTE O PERÍODO CADASTRADO, SUGERE A DATA DO INICIO DO GOZO
			dDtPagto   := If( Empty(dDtPagto)   , dIni , dDtPagto  )
			dDtPagtoAd := If( Empty(dDtPagtoAd) , dIni , dDtPagtoAd)
		EndIf

		oStruRIA:SetValue("RIA_NEW", "X")
		nL := oStruRIA:Length()
		If nX == 1
			oStruRIA:SetValue("RIA_DATINI", dIni )
			oStruRIA:SetValue("RIA_NRDGOZ", aVetor[nLin,2] )
			oStruRIA:setvalue("RIA_NRDIND", aVetor[nLin,5] )
			oStruRIA:setvalue("RIA_DOPORT", aVetor[nLin,6] )
			If aVetor[nLin,5] > 0 //DIAS INDENIZADOS/ABONO
				oStruRIA:setvalue("RIA_DTPGAD", dDtPagtoAd )
			EndIf
		Else
			dDtPagto   := If (aVetor[nLin,3] > 0, INIDATPAG( If((dIni + aVetor[nLin,2]) < Date(),Date(),(dIni + aVetor[nLin,2])) ,.T., SRA->RA_PROCES ) , stod(""))

			//CASO A DATA NÃO SEJA ENCONTRADA POIS NÃO EXISTE O PERÍODO CADASTRADO, SUGERE A DATA FINAL
			dDtPagto   := If( Empty(dDtPagto)   , dIni + aVetor[nLin,2] , dDtPagto  )

			oStruRIA:SetValue("RIA_DATINI", dIni + aVetor[nLin,2] )
			oStruRIA:SetValue("RIA_NRDGOZ", aVetor[nLin,3] )
		EndIf

		oStruRIA:setvalue("RIA_SEQPRG",cSeq)
		oStruRIA:setvalue("RIA_STATUS","0")
		oStruRIA:setvalue("RIA_OBS",STR0151 + if(oStruSRF:GetValue("RF_DIREMAN")>0,STR0219,'') + dtoc(dDataBase))//"PROGRAM. MANUAL "   //Acrescenta '(Remanescente)' quando for de dias remanescentes
		oStruRIA:setvalue("RIA_DATPAG", dDtPagto )

		//-Conforme regras definidas pelo MP, eh fixo 90 em 3x, 60 em 2x e outros em 1x
		If SRA->RA_CATFUNC $ "0*1" /*MEMBRO*/ .AND. POSICIONE("SRV",1,XFILIAL("SRV")+cPD,"RV_CODFOL") == "1332" /*LICENÇA PREMIO*/
			If (aVetor[nLin,5] >= 90)
				oStruRIA:setvalue("RIA_PARMEM", 3 )

			ElseIf (aVetor[nLin,5] >= 60)
				oStruRIA:setvalue("RIA_PARMEM", 2 )
			Else
				oStruRIA:setvalue("RIA_PARMEM", 1 )
			EndIf
		EndIf

 		//Quando é programacao de dias remanescentes, então gera com as informações de pagamento conforme a suspensao.
 		If nDReman > 0
			oStruRIA:setvalue("RIA_DATPAG", dDatPag)
			oStruRIA:setvalue("RIA_DTPGAD", dDtPgAd)
			oStruRIA:setvalue("RIA_PERIOD", cPeriod)
			oStruRIA:setvalue("RIA_NPAGTO", cNPagto)
		EndIf

	Next nX

	oStruSRF:SetValue("SRF_NEW","X")  //SETA COMO ALTERAÇÃO APENAS PARA MUDAR OS DIAS PROGRAMADOS, DEPOIS VOLTA
	oStruSRF:SetValue("RF_DIASPRG", (aVetor[nLin,2]) + (aVetor[nLin,3]) + (aVetor[nLin,5]) )
	oStruSRF:SetValue("RF_DIREMAN", 0 ) ///SEMPRE ZERA OS DIAS REMANESCENTES, NÃO PODE DEIXAR PARA DEPOIS
	oStruSRF:SetValue("SRF_NEW"," ")

	oStruRIA:GoLine(1) //VAI PRA 1A LINHA DA PROGRAMAÇÃO

	lEmProgr := .T.
	RestArea( aArea )
Return lRet



/*/{Protheus.doc} LISTS106
Controle de Saldos de Dias
@return		lRet
@author	    Fabricio Amaro
@since		22/11/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function LISTS106(oModel,cCateg,cRegime,cBsVerba,cSind)
	Local aArea   := GetArea()
	Local aRet    := {}
	Local aTable  := {}
	Local i		  := 0
	Local aVerba  := {}

	DEFAULT cSind 	 := ""
	DEFAULT cBsVerba := ""
	DEFAULT cRegime  := ""
	DEFAULT cCateg   := ""

	fCarrTab( @aTable, "S106" )
	
	// Consulta Controle de Dias de Direito por Regime, Categoria e Sindicato, de acordo com o Servidor.
	For i:= 1 To Len(aTable)
		IF (!Empty(cSind) .AND. cREGIME $ aTable[i][12] .AND. cCateg $ aTable[i][11] .AND. cSind == aTable[i][16] .AND. Ascan(aVerba, aTable[i][9]) == 0 )
				
			IF !EMPTY(aTable[i][9])
				AADD(aVerba, aTable[i][9])
			ENDIF
			
			Aadd(aRet,{	aTable[i][04],;													//01-CODIGO
				alltrim(aTable[i][05]),;  												//02-DESCRICAO
				aTable[i][10],; 														//03-VERBA DE BASE
				Alltrim(Posicione("SRV",1,xFilial("SRV")+aTable[i][10],"RV_DESC")),;   //04-DESCR.VERBA DE BASE
				aTable[i][15],; 														//05-DIAS DE DIREITO
				aTable[i][14],;															//06-QTDE PER AQUISITIVO
				aTable[i][13],;  														//07-TIPO DA QTDE PER AQUISITIVO
				cValToChar(aTable[i][14])+" "+If(aTable[i][13]=="1",STR0152,If(aTable[i][13]=="2",STR0153,"")) ,;  //08-QTDE E DESCRIÇÃO TIPO DA QTDE PER AQUISITIVO//'Dias'//'Meses'
				aTable[i][08],;  														//09-TROCA DESC POR INDEN.
				If(aTable[i][08]=="1",STR0155,STR0154),;  								//10-DESCR.TROCA DESC POR INDEN.//'Sim'//'Não'
				aTable[i][06],;  														//11-DIAS CREDITO
				aTable[i][07],;  														//12-PUBLICA PORTARIA
				If(aTable[i][07]=="1",STR0158,If(aTable[i][07]=="2",STR0156,If(aTable[i][07]=="3",STR0159,STR0157))),; //13-DESCR.PUBLICA PORTARIA//'Aquisição'//'Não Publica'//'Programação'//'Programação/Aquisição'
				aTable[i][09],; 														//14-VERBA DE INDENIZACAO
			})
		EndIf
	Next i

	// Consulta Controle de Dias apenas por Regime e Categoria, de acordo com o servidor.
	For i:= 1 To Len(aTable)
		IF ((cREGIME $ aTable[i][12] .AND. cCateg $ aTable[i][11] .AND. EMPTY(aTable[i][16])))
			Aadd(aRet,{	aTable[i][04],;													//01-CODIGO
				alltrim(aTable[i][05]),;  												//02-DESCRICAO
				aTable[i][10],; 														//03-VERBA DE BASE
				Alltrim(Posicione("SRV",1,xFilial("SRV")+aTable[i][10],"RV_DESC")),;   //04-DESCR.VERBA DE BASE
				aTable[i][15],; 														//05-DIAS DE DIREITO
				aTable[i][14],;															//06-QTDE PER AQUISITIVO
				aTable[i][13],;  														//07-TIPO DA QTDE PER AQUISITIVO
				cValToChar(aTable[i][14])+" "+If(aTable[i][13]=="1",STR0152,If(aTable[i][13]=="2",STR0153,"")) ,;  //08-QTDE E DESCRIÇÃO TIPO DA QTDE PER AQUISITIVO//'Dias'//'Meses'
				aTable[i][08],;  														//09-TROCA DESC POR INDEN.
				If(aTable[i][08]=="1",STR0155,STR0154),;  								//10-DESCR.TROCA DESC POR INDEN.//'Sim'//'Não'
				aTable[i][06],;  														//11-DIAS CREDITO
				aTable[i][07],;  														//12-PUBLICA PORTARIA
				If(aTable[i][07]=="1",STR0158,If(aTable[i][07]=="2",STR0156,If(aTable[i][07]=="3",STR0159,STR0157))),; //13-DESCR.PUBLICA PORTARIA//'Aquisição'//'Não Publica'//'Programação'//'Programação/Aquisição'
				aTable[i][09],; 														//14-VERBA DE INDENIZACAO
			})
		EndIf
	Next i

	aNewSRF := aRet
	RestArea(aArea)
Return aRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} LISTS107
Programaçao dos Dias de Direito
@return		aRet
@author	    Everson S P Junior
@since		11/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function LISTS107(oModel,cTipPro,nDias,nDReman,ndInd,ndOport,aDias)
	Local aArea   	:= GetArea()
	Local aRet    	:= {}
	Local aTable  	:= {}
	Local i		  	:= 0
    Local x         := 0

	Default ndReman := 0 //DIAS REMANESCENTES
	Default ndInd 	:= 0 //DIAS INDENIZADOS
	Default ndOport := 0 //DIAS OPORTUNOS
    Default aDias   := {}

	If cTipPro == "6"

		Aadd(aRet,{	STR0163 ,;  	//DESCRICAO //"GOZO/INDENIZACAO OUTROS"
					nDias,;  						//Dias Gozo 1
					0,; 							//Dias Gozo 2
					nDias + nDInd + ndOport,;  		//Dias Total
					ndInd,;  						//Dias Indenizados/Abono
					ndOport;						//Dias Oportuno
					})
	Else

		fCarrTab( @aTable, "S107" )

		For i:= 1 To Len(aTable)
			If aTable[i][5] == cTipPro .AND. aTable[i][11] == "1" .AND. aTable[i][1] == "S107"//SE FOR DO TIPO PASSADO NO PARAMETRO E SE ESTIVER ATIVO

                If nDias > 0
                    If nDias == aTable[i][13] //SE A QUANTIDADE DE DIAS EM ABERTO FOR IGUAL AO TOTAL DE DIAS
                       Aadd(aRet,{ aTable[i][07],;                      //DESCRICAO
                                If(nDias==0,nDReman,aTable[i][08]),;    //Dias Gozo 1
                                aTable[i][12],;                         //Dias Gozo 2
                                If(nDias==0,nDReman,aTable[i][13]),;    //Dias Total
                                If(ndInd==0,aTable[i][09],ndInd),;      //Dias Indenizados/Abono
                                aTable[i][10];                          //Dias Oportuno
                                })
                    EndIf
                Else
                    IF ndReman > 0
                        If aTable[i][13] == 0 //AVALIA OPÇÃO PARA DIAS REMANESCENTES
                           Aadd(aRet,{ aTable[i][07],;                      //DESCRICAO
                                    If(nDias==0,nDReman,aTable[i][08]),;    //Dias Gozo 1
                                    aTable[i][12],;                         //Dias Gozo 2
                                    If(nDias==0,nDReman,aTable[i][13]),;    //Dias Total
                                    If(ndInd==0,aTable[i][09],ndInd),;      //Dias Indenizados/Abono
                                    aTable[i][10];                          //Dias Oportuno
                                    })
                        EndIf
                    Else

                        //AVALIA VÁRIOS DIAS INFORMADOS NO ARRAY
                        For x := 1 to len(aDias)
                           //Tratamento especial para membros terem opções com multiplos de 30d
                           If aDias[x] == aTable[i][13]
                              Aadd(aRet,{ aTable[i][07],;                   //DESCRICAO
                                    If(aDias[x]==0,nDReman,aTable[i][08]),; //Dias Gozo 1
                                    aTable[i][12],;                         //Dias Gozo 2
                                    If(aDias[x]==0,nDReman,aTable[i][13]),; //Dias Total
                                    If(ndInd==0,aTable[i][09],ndInd),;      //Dias Indenizados/Abono
                                    aTable[i][10];                          //Dias Oportuno
                                    })
                           EndIf
                        Next x

                    EndIf
				EndIf

			EndIf
		Next i
	EndIf
	RestArea( aArea )
Return aRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} VerbSRF
Filtro de tela para cadastro de dias de direito.
@return		aRet
@author	    Everson S P Junior
@since		11/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------

Static Function VerbSRF()//OK
	Local cQuery  := ""
	Local aRet		:= {}

	cQuery := " SELECT distinct(RF_PD)"
	cQuery += " FROM "
	cQuery += + RetSqlName("SRF") +  " SRF "
	cQuery += " WHERE "
	cQuery += " SRF.RF_FILIAL = '"+SRA->RA_FILIAL+ "' AND "
	cQuery += " SRF.RF_MAT = '"+SRA->RA_MAT+ "' AND "
	cQuery += " SRF.D_E_L_E_T_ = ' ' "
	cQuery = ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBSRF",.T.,.T.)

	While !TRBSRF->(Eof())
		aAdd(aRet,{SRA->RA_NOME,TRBSRF->RF_PD,FDESC("SRV",TRBSRF->RF_PD,"RV_DESC")})
		TRBSRF->(DbSkip())
	EndDo
	TRBSRF->( dbCloseArea() )
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} bLoadSRF
Seleciona os dados para o grid da SRF
@author Everson S P Junior
@since 12/07/2013
@version P11
@params
oMdl -> Modelo de dados Detail.
/*/
//--------------------------------------------------------------------
Static Function bLoadSRF( oModel )//OK
	Local aRet      := {}
	Local cTmpTrab  := GetNextAlias()
	Local cFil      := SRA->RA_FILIAL
	Local cMat      := SRA->RA_MAT
	Local cPD		:= ""
	lNewSRF := If(Type("lNewSRF") == "U",.F.,lNewSRF)

	If !IsInCallStack("TCFA040")
		If nGSPopc == 0 .AND. oModel:GetOperation() <> 1
			If !(Empty(lNewSRF))
			cPd 	:= "" //aVetor[oLbx:nAt,3] //INDICA A VERBA SELECIONADA
			Else
				cPD	:= aVetor[oLbx:nAt,2]
			EndIf
		Else
			cPD := SRF->RF_PD
		EndIf

		If oModel:GetOperation() <> 1
			BeginSql alias cTmpTrab

				COLUMN RF_DATABAS AS DATE
				COLUMN RF_DATAFIM AS DATE
				COLUMN RF_DTCANCE AS DATE

				SELECT * FROM %table:SRF%
				WHERE
				    RF_FILIAL = %exp:cFil%
				AND RF_MAT    = %exp:cMat%
				AND RF_PD     = %exp:cPD%
				AND %NotDel%
				ORDER BY RF_MAT,RF_DATABAS
			EndSql
		Else
			BeginSql alias cTmpTrab

				COLUMN RF_DATABAS AS DATE
				COLUMN RF_DATAFIM AS DATE
				COLUMN RF_DTCANCE AS DATE

				SELECT * FROM %table:SRF%
				WHERE
					RF_FILIAL = %exp:cFil%
				AND RF_MAT 	  = %exp:cMat%
				AND %NotDel%
				ORDER BY RF_MAT,RF_DATABAS
			EndSql
		EndIf
		aRet := FwLoadByAlias( oModel, cTmpTrab )
		(cTmpTrab)->(DbCloseArea())
	Else
		//COMO A ROTINA ESTA SENDO CHAMADA PELO TCFA040, TEM QUE POSICIONAR NA LINHA QUE ESTÁ SENDO CHAMADA
		BeginSql alias cTmpTrab
			COLUMN RF_DATABAS AS DATE
			COLUMN RF_DATAFIM AS DATE
			COLUMN RF_DTCANCE AS DATE

			SELECT * FROM %table:SRF%
			WHERE
			    RF_FILIAL	= %exp:aSRF040[1][1]%
			AND RF_MAT 	 	= %exp:aSRF040[1][2]%
			AND RF_PD 		= %exp:aSRF040[1][3]%
			AND RF_DATABAS 	= %exp:dtos(aSRF040[1][4])%
			AND %NotDel%
			ORDER BY RF_MAT,RF_DATABAS
		EndSql

		aRet := FwLoadByAlias( oModel, cTmpTrab )
		(cTmpTrab)->(DbCloseArea())
	EndIf
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} bLoadRIA
Seleciona os dados para o grid da RIA
@author Fabricio Amaro
@since 14/11/2013
@version P11
@params
oMdl -> Modelo de dados Detail.
/*/
//--------------------------------------------------------------------
Static Function bLoadRIA( oModel )
	Local cTmpRIA	 := GetNextAlias()
	Local oMdl51   := FWModelActive()
	Local oStruSRF := oMdl51:GetModel("SRFDETAIL")
	Local xAux 	 := 1
	Local nDProgr 	 := 0
    Local cWhere   := "%%"
    Local dIniPer  := STOD("")
    Local dIni     := Date()
    Local nX

    If cTipSolicPortal == "O"
        cWhere := "% AND R_E_C_N_O_ = " +str(aRIA040[1][8]) +"%"
    EndIf

	BeginSql alias cTmpRIA

		COLUMN RIA_DTINPA AS DATE
		COLUMN RIA_DATINI AS DATE
		COLUMN RIA_DATFIM AS DATE
		COLUMN RIA_DATPAG AS DATE
		COLUMN RIA_SUSPEN AS DATE
		COLUMN RIA_DTPGAD AS DATE

		SELECT 	* FROM %table:RIA%
		WHERE
		    RIA_FILIAL   = %exp:aSRF040[1][1]%
		AND RIA_MAT 	 = %exp:aSRF040[1][2]%
		AND RIA_PD  	 = %exp:aSRF040[1][3]%
		AND RIA_DTINPA	 = %exp:dtos(aSRF040[1][4])%
		AND %NotDel%
        %exp:cWhere%
		ORDER BY RIA_DTINPA
	EndSql

	aRetRIA := FwLoadByAlias( oModel, cTmpRIA )
	(cTmpRIA)->(DbCloseArea())

	If Len(aRIA040) > 0  //CHAMADA VIA APROVAÇÃO DO PORTAL

       // PROGRAMACAO DE FERIAS
       If cTipSolicPortal == "P"
            If oStruSRF:GetValue("RF_DIREMAN") > 0 .AND. !(aRIA040[xAux][1] == oStruSRF:GetValue("RF_DIREMAN"))
                Alert(STR0162) //'Para o período em questão, existem dias Remanescentes, e o total de dias de gozo originários do Portal não confere com esses dias! O processo não poderá ser concluído!'
                Return aRetRIA
            EndIf

			For nX := 1 to len(aRIA040)
				nDProgr += aRIA040[nX][1] + aRIA040[nX][6] + aRIA040[nX][7]
			Next nX

			If nDProgr > (oStruSRF:GetValue("RF_DIASDIR")-oStruSRF:GetValue("RF_DIASPRG"))
                Alert(STR0245) //'A quantidade de dias a programar é superior ao saldo de dias do período.!'
            EndIf
			nDProgr := 0

    		cSeq := fPrxSeqFer(aSRF040[1][1],aSRF040[1][2],aSRF040[1][3],aSRF040[1][4])

    		oModel:AddLine()

    		dDtPagto   := If ( aRIA040[xAux][1] > 0,  INIDATPAG( If(aRIA040[xAux][2] < Date() , Date() , aRIA040[xAux][2]) ,.T., aSRF040[1][6] , , @dIniPer ) , stod(""))
    		dDtPagtoAd := INIDATPAG( If( Empty(dIniPer),If(Empty(dDtPagto),dIni,dDtPagto-1), dIniPer-1) ,.T., aSRF040[1][6] ) //TEM QUE PAGAR NO PERIODO ANTERIOR

    		//CASO A DATA NÃO SEJA ENCONTRADA POIS NÃO EXISTE O PERÍODO CADASTRADO, SUGERE A DATA FINAL
    		dDtPagto   := If( Empty(dDtPagto)   , aRIA040[xAux][2] , dDtPagto  )
    		dDtPagtoAd := If( Empty(dDtPagtoAd) , aRIA040[xAux][2] , dDtPagtoAd)

			//Se for programacao de dias remanescentes, zera datas para que o usuario informe as datas originais da suspensao
			If oStruSRF:GetValue("RF_DIREMAN") > 0
	    		dDtPagto   := ctod("//")
    			dDtPagtoAd := ctod("//")
        	EndIf

    		oModel:setvalue("RIA_NEW","X")
    		lBkpTcf  := lTcfa040

    		lTcfa040 := .F.
    		SRA->(dbseek(aSRF040[1][1]+aSRF040[1][2]))
    		oModel:setvalue("RIA_DATINI",aRIA040[xAux][2])
    		oModel:setvalue("RIA_NRDGOZ",aRIA040[xAux][1])
    		oModel:setvalue("RIA_NRDIND",aRIA040[xAux][6])  //Vem da variavel TMP_DABONO da RH4
    		oModel:setvalue("RIA_DOPORT",aRIA040[xAux][7])

    		nDProgr += aRIA040[xAux][1] + aRIA040[xAux][6] + aRIA040[xAux][7]

    		If aRIA040[xAux][6] > 0 //DIAS INDENIZADOS/ABONO
    			oModel:setvalue("RIA_DTPGAD", dDtPagto ) //TEM QUE PAGAR NO PERIODO ANTERIOR
    		EndIf

    		oModel:setvalue("RIA_STATUS","0")
    		oModel:setvalue("RIA_FILSUB",aRIA040[xAux][4])
    		oModel:setvalue("RIA_MATSUB",aRIA040[xAux][5])
            If empty(aRIA040[xAux][5])
                oModel:setvalue("RIA_NMSUBS","")
            Else
        		oModel:setvalue("RIA_NMSUBS",POSICIONE("SRA",1,aRIA040[xAux][4]+aRIA040[xAux][5],"RA_NOME"))
        	EndIf
    		oModel:setvalue("RIA_OBS"	,STR0160 + if(oStruSRF:GetValue("RF_DIREMAN")>0,STR0219,'') + dtoc(dDataBase))//'PORTAL '###"(Remanescente)"
    		oModel:setvalue("RIA_DATPAG",dDtPagto)
    		oModel:setvalue("RIA_SEQPRG",cSeq)
    		oModel:setvalue("RIA_NRPORT",aSRF040[1][7])

    		If Len(aRIA040) > 1
    			xAux++
    			oModel:AddLine()

    			dDtPagto   := If ( aRIA040[xAux][1] > 0, INIDATPAG( If(aRIA040[xAux][2]<Date(),Date(),aRIA040[xAux][2]) ,.T., aSRF040[1][6] , , @dIniPer ) , stod(""))
    			dDtPagtoAd := INIDATPAG( If(Empty(dIniPer),If(Empty(dDtPagto),dIni,dDtPagto-1),dIniPer - 1)  ,.T., aSRF040[1][6] ) //TEM QUE PAGAR NO PERIODO ANTERIOR

    			//CASO A DATA NÃO SEJA ENCONTRADA POIS NÃO EXISTE O PERÍODO CADASTRADO, SUGERE A DATA FINAL
    			dDtPagto   := If( Empty(dDtPagto)   , aRIA040[xAux][2] , dDtPagto  )
    			dDtPagtoAd := If( Empty(dDtPagtoAd) , aRIA040[xAux][2] , dDtPagtoAd)

    			oModel:setvalue("RIA_NEW","X")
    			oModel:setvalue("RIA_DATINI",aRIA040[xAux][2])
    			oModel:setvalue("RIA_NRDGOZ",aRIA040[xAux][1])
    			oModel:setvalue("RIA_DOPORT",aRIA040[xAux][7])
    			oModel:setvalue("RIA_NRDIND",aRIA040[xAux][6])

    			nDProgr += aRIA040[xAux][1] + aRIA040[xAux][6] + aRIA040[xAux][7]

    			If aRIA040[xAux][6] > 0
    				oModel:setvalue("RIA_DTPGAD", dDtPagtoAd)
    			EndIf

    			oModel:setvalue("RIA_STATUS","0")
    			oModel:setvalue("RIA_FILSUB",aRIA040[xAux][4])
    			oModel:setvalue("RIA_MATSUB",aRIA040[xAux][5])
                If empty(aRIA040[xAux][5])
                    oModel:setvalue("RIA_NMSUBS","")
                Else
                    oModel:setvalue("RIA_NMSUBS",POSICIONE("SRA",1,aRIA040[xAux][4]+aRIA040[xAux][5],"RA_NOME"))
                EndIf
    			oModel:setvalue("RIA_OBS"	,STR0161 + if(oStruSRF:GetValue("RF_DIREMAN")>0,STR0219,'') + dtoc(dDataBase))//'PORTAL '		//Acrescenta 'Remanescente' quando for de dias remanescentes
    			oModel:setvalue("RIA_DATPAG",dDtPagto)
    			oModel:setvalue("RIA_SEQPRG",cSeq)
    			oModel:setvalue("RIA_NRPORT",aSRF040[1][7])
    		EndIf

    		//AJUSTA A SRF
    		oStruSRF:SetValue("SRF_NEW","X")  //SETA COMO ALTERAÇÃO APENAS PARA MUDAR OS DIAS PROGRAMADOS, DEPOIS VOLTA
    		oStruSRF:SetValue("RF_DIASPRG",oStruSRF:GetValue("RF_DIASPRG") + nDProgr)
    		oStruSRF:SetValue("RF_DIREMAN", 0 ) ///SEMPRE ZERA OS DIAS REMANESCENTES, NÃO PODE DEIXAR PARA DEPOIS
    		oStruSRF:SetValue("SRF_NEW"," ")

    		lTcfa040 := lBkpTcf
        EndIf

	EndIf

//	oModel:DeActivate()

Return aRetRIA

//-------------------------------------------------------------------
/*/{Protheus.doc} fProgramRetif
Seleciona os dados para o grid da RIA
@author Marcelo Faria
@since 21/05/2014
@version P11
@params
oMdl -> Modelo de dados Detail.
/*/
//--------------------------------------------------------------------
Static Function fProgramRetif()
    Local lRet      := .T.
    Local aArea     := GetArea()
    Local nX,nL     := 0
    Local nGeraRia  := 1
    Local oModel    := FWModelActive()
    Local oStruRIA  := oModel:GetModel("RIADETAIL")
    Local oStruSRF  := oModel:GetModel("SRFDETAIL")
    Local cPD       := oModel:GetValue("SRFDETAIL", "RF_PD")
    Local dDtBase   := oModel:GetValue("SRFDETAIL", "RF_DATABAS")
    Local dDtBasFim := oModel:GetValue("SRFDETAIL", "RF_DATAFIM")
    Local cFil      := oModel:GetValue("SRFDETAIL", "RF_FILIAL")
    Local cMat      := oModel:GetValue("SRFDETAIL", "RF_MAT")
    Local dIni      := Date()
    Local dIniPer   := STOD("")
    Local dDtPagto  := STOD("")

    Local nDiasGoz  := 0
    Local nDiasInd  := 0
    Local nDiasOpt  := 0
    Local nParMem   := 0
    Local cObs      := ""

    If !lRetifica
       return lRet
    EndIf

    //Avalia se ocorreram problemas de criticas anteriores
    If lErrRet
       return lRet
    EndIf

    nDiasGoz 	:= oModel:GetValue("RIADETAIL", "RIA_NRDGOZ")
    nDiasInd 	:= oModel:GetValue("RIADETAIL", "RIA_NRDIND")
    nDiasInd 	:= oModel:GetValue("RIADETAIL", "RIA_DOPORT")
    cPeriod  	:= oModel:GetValue("RIADETAIL", "RIA_PERIOD")
    cNPagto  	:= oModel:GetValue("RIADETAIL", "RIA_NPAGTO")
    nParMem  	:= oModel:GetValue("RIADETAIL", "RIA_PARMEM")

    If dIni <= dDtBasFim
       dIni := dDtBasFim + 1
    EndIf

    MsgBox(OemToAnsi(STR0235)  +cEnt +OemToAnsi(STR0236),OemToAnsi(STR0237),"INFO")
    //"A retificação da programação foi preparada." "Agora, será aberto uma linha para ser realizado uma nova programação." "Retificando..."

    cSeq := fPrxSeqFer(cFil,cMat,cPD,dDtBase)

    SRA->(dbSeek(cFil+cMat)) //Posiciona SRA novamente, pois o addline desposiciona

    dDtPagto   := INIDATPAG( If(dIni < Date(),Date(),dIni) ,.T., SRA->RA_PROCES , , @dIniPer )
    dDtPagtoAd := INIDATPAG( If(Empty(dIniPer), If(Empty(dDtPagto),dIni,dDtPagto-1) , dIniPer - 1) ,.T., SRA->RA_PROCES ) //TEM QUE PAGAR NO PERIODO ANTERIOR

    //CASO A DATA NÃO SEJA ENCONTRADA POIS NÃO EXISTE O PERÍODO CADASTRADO, SUGERE A DATA DO '
    dDtPagto   := If( Empty(dDtPagto)   , dIni , dDtPagto  )
    dDtPagtoAd := If( Empty(dDtPagtoAd) , dIni , dDtPagtoAd)

	cObs := STR0234  //"PROGRAM.RETIFICAÇÃO"

	//Se for reprogramacao de dias remanescentes, mantem as datas de pagamento originais
	If upper(substr(alltrim(STR0219),2,len(alltrim(STR0219))-1)) $ upper(oModel:GetValue("RIADETAIL", "RIA_OBS"))  //"(Remanescente)"
	    dDtPagto   := oModel:GetValue("RIADETAIL", "RIA_DATPAG")
    	dDtPagtoAd := oModel:GetValue("RIADETAIL", "RIA_DTPGAD")
		cObs	   += " "+STR0219+' ' +dtoc(dDataBase) //"(Remanescente)"
	EndIf
	 
	VDFPROGFE()

    lBkpTcf  := lTcfa040
    lTcfa040 := .F.

    If IsInCallStack("TCFA040") //CHAMADA PELO PORTAL - TCFA040
       oStruRIA:setvalue("RIA_NRPORT",aSRF040[1][7] )
    EndIf

    lTcfa040 := lBkpTcf

    lEmProgr := .T.
    RestArea( aArea )
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fPrxSeqFer
Pesquisa a sequencia da proxima programação de Férias
@author Fabricio Amaro
@since 	18/11/2013
@version P11
@params
/*/
//--------------------------------------------------------------------
Function fPrxSeqFer(cFil,cMat,cPD,dDtBasFer)
	Local cSeq		:= ""
	Local cQryTmp	:= ""

	cQryTmp := " SELECT MAX(RIA_SEQPRG) DOCUMEN "
	cQryTmp += " FROM "+ RetSqlName("RIA")
	cQryTmp += " WHERE "
	cQryTmp += " RIA_FILIAL = '" + cFil + "' AND "
	cQryTmp += " RIA_MAT  	= '" + cMat + "' AND "
	cQryTmp += " RIA_PD  	= '" + cPD  + "' AND "
	cQryTmp += " RIA_DTINPA = '" + dtos(dDtBasFer) + "' AND "
	cQryTmp += " D_E_L_E_T_ = ' ' "
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQryTmp), "TBRTEMP", .F., .T. )

	cSeq:= TBRTEMP->DOCUMEN
	TBRTEMP->(dbCloseArea())

	cSeq := StrZero( Val(cSeq) + 1, TAMSX3("RIA_SEQPRG")[1])
Return cSeq


//------------------------------------------------------------------------------
/*/{Protheus.doc} ListS115
Controle de Limites Indenização Férias
Controla a quantidade de ocorrências e de dias de indenização por período.
Utilização na Programação de Dias de Direito do Servidor
@sample 	ListS115(oModel, cCateg)
@param		cCateg 		- Categoria do Servidor Corrente para filtro da S115
@return		aRet		- Array com as informações dos limites de indenização.
@author	    Tânia Bronzeri
@since		14/05/2014
@version	P.11.9
/*/
//------------------------------------------------------------------------------
Function ListS115(cCateg)
Local aArea   := GetArea()
Local aRet    := {}
Local aTabIn  := {}
Local ni	  := 0

fCarrTab(@aTabIn, "S115",,.T.)

For ni:= 1 To Len(aTabIn)
	If aTabin[ni][01] == "S115" .And. cCateg $ aTabIn[ni][05]
		aAdd(aRet, {aTabIn[ni][05]	,;	//01-Categorias
					aTabIn[ni][06]	,;	//02-Anual Ocorrências
					aTabIn[ni][07]	,;	//03-Anual Limite Dias
					aTabIn[ni][08]	,;	//04-Semestral Ocorrências
					aTabIn[ni][09]	,;	//05-Semestral Limite Dias
					aTabIn[ni][10]	,;	//06-Quadrimestral Ocorrências
					aTabIn[ni][11]	,;	//07-Quadrimestral Limite Dias
					aTabIn[ni][12]	,;  //08-Trimestral Ocorrências
					aTabIn[ni][13]	,;	//09-Trimestral Limite Dias
					aTabIn[ni][14]	,;	//10-Bimestral Ocorrências
					aTabIn[ni][15]	,;	//11-Bimestral Limite Dias
					aTabIn[ni][16]	,;	//12-Mensal Ocorrências
					aTabIn[ni][17]	,;	//13-Mensal Limite Dias
					})
	EndIf
Next ni

aNewSRF := aRet
RestArea(aArea)
Return aClone(aRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} fValindeni
Controle de Limites Indenização Férias
Controla a quantidade de ocorrências e de dias de indenização por período.
Utilização na Programação de Dias de Direito do Servidor
@sample 	fValindeni(oStruRIA, nRiaInd, cRiaFil, cRiaMat)
@param		nRiaInd		- Número de Dias Indenizados solicitados
			cRiaFil		- Filial do Servidor
			cRiaMat		- Matrícula do Servidor
			dRiaPgIn	- Data do Pagamento da Indenização
			cRiaPd		- Verba Identificadora da RIA
@return		lGrava		- Informa se deve gravar ou não.
@author	    Tânia Bronzeri
@since		14/05/2014
@version	P.11.9
/*/
//------------------------------------------------------------------------------
Function fValindeni(nRiaInd, cRiaFil, cRiaMat, dRiaPgIn, cRiaPd)
Local aRiaArea	:= RIA->(GetArea())
Local aSraArea	:= SRA->(GetArea())
Local lGrava	:= .T.
Local lPortal	:= (GetRemoteType() == -1)
Local aPerInd	:= {}
Local aInden	:= {}
Local cRiaAls	:= GetNextAlias()
Local cQFilial	:= "%'" + cRiaFil + "'%"
Local cQMatric	:= "%'" + cRiaMat + "'%"
Local cQVerba	:= "%'" + cRiaPd  + "'%"
Local cQStatus	:= "%('0','4')%"
Local cQIniInd	:= ""
Local cQFimInd	:= ""
Local cMensa	:= ""
Default nRiaInd	:= 0

DbSelectArea("SRA")
DbSetOrder(1)
SRA->(DbSeek(cRiaFil+cRiaMat))

aInden	:= ListS115(SRA->RA_CATFUNC)

If Len(aInden) > 0	//Somente validar se há restrições na S115 para esta categoria

	//Valida Períodos aInden[]
	DbSelectArea("RIA")
	DbSetOrder(1)

	//Anual
	aPerInd		:= fPerAnoCiv(dRiaPgIn,"A")
	cQIniInd	:= "%'" + DtoS(aPerInd[1]) + "'%"
	cQFimInd	:= "%'" + DtoS(aPerInd[2]) + "'%"

	BeginSql alias cRiaAls

		Select Count(RIA_PD) IND_OCOR, Sum(RIA_NRDIND) IND_DIND
		From %table:RIA% RIA
		Where	RIA_FILIAL  =  %exp:cQFilial%
			And	RIA_MAT		=  %exp:cQMatric%
			And	RIA_PD		=  %exp:cQVerba%
			And RIA_STATUS	in %exp:cQStatus%
			And RIA_DTPGAD	>= %exp:cQIniInd%
			And RIA_DTPGAD	<= %exp:cQFimInd%
			And RIA.%NotDel%
	EndSql
	DbSelectArea(cRiaAls)
	DbGoTop()
	If !Eof()
		If (cRiaAls)->IND_OCOR + 1 > aInden[1][2] .And. aInden[1][2] > 0
			If lPortal
				cMensa	:= OemToAnsi(STR0221)
				lGrava	:= .F.
			Else
				lGrava	:= MsgBox(OemToAnsi(STR0221) + OemToAnsi(STR0233),OemToAnsi(STR0220),"YESNO")	//"Quantidade de Indenizações excedem o permitido para o ano. Recomenda-se alterar a programação. "	###	"Deseja Prosseguir com a Programação?" ### "Atenção!"
			EndIf
		EndIf
		If (cRiaAls)->IND_DIND + nRiaInd > aInden[1][3] .And. aInden[1][3] > 0 .And. lGrava
			If lPortal
				cMensa	:= OemToAnsi(STR0222)
				lGrava	:= .F.
			Else
				lGrava	:= MsgBox(OemToAnsi(STR0222) + OemToAnsi(STR0233),OemToAnsi(STR0220),"YESNO")	//"Dias de Indenização excedem o permitido para o ano. Recomenda-se alterar a programação. " ### "Deseja Prosseguir com a Programação?" 	### "Atenção!"
			EndIf
		EndIf
	EndIf
	(cRiaAls)->(DbCloseArea())

	If lGrava
		//Semestral
		aPerInd	:= fPerAnoCiv(dRiaPgIn,"S")
		cQIniInd	:= "%'" + DtoS(aPerInd[1]) + "'%"
		cQFimInd	:= "%'" + DtoS(aPerInd[2]) + "'%"

		BeginSql alias cRiaAls

			Select Count(RIA_PD) IND_OCOR, Sum(RIA_NRDIND) IND_DIND
			From %table:RIA% RIA
			Where	RIA_FILIAL  =  %exp:cQFilial%
				And	RIA_MAT		=  %exp:cQMatric%
				And	RIA_PD		=  %exp:cQVerba%
				And RIA_STATUS	in %exp:cQStatus%
				And RIA_DTPGAD	>= %exp:cQIniInd%
				And RIA_DTPGAD	<= %exp:cQFimInd%
				And RIA.%NotDel%
		EndSql
		DbSelectArea(cRiaAls)
		DbGoTop()
		If !Eof()
			If ((cRiaAls)->IND_OCOR + 1) > aInden[1][4] .And. aInden[1][4] > 0
				If lPortal
					cMensa	:= OemToAnsi(STR0223)
					lGrava	:= .F.
				Else
					lGrava	:= MsgBox(OemToAnsi(STR0223) + OemToAnsi(STR0233),OemToAnsi(STR0220),"YESNO")	//"Quantidade de Indenizações excedem o permitido para o semestre. Recomenda-se alterar a programação. " ### "Deseja Prosseguir com a Programação?" ###	"Atenção!"
				EndIf
			EndIf
			If ((cRiaAls)->IND_DIND + nRiaInd) > aInden[1][5] .And. aInden[1][5] > 0 .And. lGrava
				If lPortal
					cMensa	:= OemToAnsi(STR0224)
					lGrava	:= .F.
				Else
					lGrava	:= MsgBox(OemToAnsi(STR0224) + OemToAnsi(STR0233),OemToAnsi(STR0220),"YESNO")	//"Dias de Indenização excedem o permitido para o semestre. Recomenda-se alterar a programação. " ### "Deseja Prosseguir com a Programação?"	###	"Atenção!"
				EndIf
			EndIf
		EndIf
		(cRiaAls)->(DbCloseArea())
	EndIf

	If lGrava
		//Quadrimestral
		aPerInd	:= fPerAnoCiv(dRiaPgIn,"Q")
		cQIniInd	:= "%'" + DtoS(aPerInd[1]) + "'%"
		cQFimInd	:= "%'" + DtoS(aPerInd[2]) + "'%"

		BeginSql alias cRiaAls

			Select Count(RIA_PD) IND_OCOR, Sum(RIA_NRDIND) IND_DIND
			From %table:RIA% RIA
			Where	RIA_FILIAL  =  %exp:cQFilial%
				And	RIA_MAT		=  %exp:cQMatric%
				And	RIA_PD		=  %exp:cQVerba%
				And RIA_STATUS	in %exp:cQStatus%
				And RIA_DTPGAD	>= %exp:cQIniInd%
				And RIA_DTPGAD	<= %exp:cQFimInd%
				And RIA.%NotDel%
		EndSql
		DbSelectArea(cRiaAls)
		DbGoTop()
		If !Eof()
			If ((cRiaAls)->IND_OCOR + 1) > aInden[1][6] .And. aInden[1][6] > 0
				If lPortal
					cMensa	:= OemToAnsi(STR0225)
					lGrava	:= .F.
				Else
					lGrava	:= MsgBox(OemToAnsi(STR0225) + OemToAnsi(STR0233),OemToAnsi(STR0220),"YESNO")	//"Quantidade de Indenizações excedem o permitido para o quadrimestre. Recomenda-se alterar a programação. " ### "Deseja Prosseguir com a Programação?" ###	"Atenção!"
				EndIf
			EndIf
			If ((cRiaAls)->IND_DIND + nRiaInd) > aInden[1][7] .And. aInden[1][7] > 0 .And. lGrava
				If lPortal
					cMensa	:= OemToAnsi(STR0226)
					lGrava	:= .F.
				Else
					lGrava	:= MsgBox(OemToAnsi(STR0226) + OemToAnsi(STR0233),OemToAnsi(STR0220),"YESNO")	//"Dias de Indenização excedem o permitido para o quadrimestre. Recomenda-se alterar a programação. " ### "Deseja Prosseguir com a Programação?"	### "Atenção!"
				EndIf
			EndIf
		EndIf
		(cRiaAls)->(DbCloseArea())
	EndIf

	If lGrava
		//Trimestral
		aPerInd	:= fPerAnoCiv(dRiaPgIn,"T")
		cQIniInd	:= "%'" + DtoS(aPerInd[1]) + "'%"
		cQFimInd	:= "%'" + DtoS(aPerInd[2]) + "'%"

		BeginSql alias cRiaAls

			Select Count(RIA_PD) IND_OCOR, Sum(RIA_NRDIND) IND_DIND
			From %table:RIA%  RIA
			Where	RIA_FILIAL  =  %exp:cQFilial%
				And	RIA_MAT		=  %exp:cQMatric%
				And	RIA_PD		=  %exp:cQVerba%
				And RIA_STATUS	in %exp:cQStatus%
				And RIA_DTPGAD	>= %exp:cQIniInd%
				And RIA_DTPGAD	<= %exp:cQFimInd%
				And RIA.%NotDel%
		EndSql
		DbSelectArea(cRiaAls)
		DbGoTop()
		If !Eof()
			If ((cRiaAls)->IND_OCOR + 1) > aInden[1][8] .And. aInden[1][8] > 0
				If lPortal
					cMensa	:= OemToAnsi(STR0227)
					lGrava	:= .F.
				Else
					lGrava	:= MsgBox(OemToAnsi(STR0227) + OemToAnsi(STR0233),OemToAnsi(STR0220),"YESNO")	//"Quantidade de Indenizações excedem o permitido para o trimestre. Recomenda-se alterar a programação. " ### "Deseja Prosseguir com a Programação?"	### "Atenção!"
				EndIf
			EndIf
			If ((cRiaAls)->IND_DIND + nRiaInd) > aInden[1][9] .And. aInden[1][9] > 0 .And. lGrava
				If lPortal
					cMensa	:= OemToAnsi(STR0228)
					lGrava	:= .F.
				Else
					lGrava	:= MsgBox(OemToAnsi(STR0228) + OemToAnsi(STR0233),OemToAnsi(STR0220),"YESNO")	//"Dias de Indenização excedem o permitido para o trimestre. Recomenda-se alterar a programação. "	### "Deseja Prosseguir com a Programação?"	### "Atenção!"
				EndIf
			EndIf
		EndIf
		(cRiaAls)->(DbCloseArea())
	EndIf

	If lGrava
		//Bimestral
		aPerInd	:= fPerAnoCiv(dRiaPgIn,"B")
		cQIniInd	:= "%'" + DtoS(aPerInd[1]) + "'%"
		cQFimInd	:= "%'" + DtoS(aPerInd[2]) + "'%"

		BeginSql alias cRiaAls

			Select Count(RIA_PD) IND_OCOR, Sum(RIA_NRDIND) IND_DIND
			From %table:RIA% RIA
			Where	RIA_FILIAL  =  %exp:cQFilial%
				And	RIA_MAT		=  %exp:cQMatric%
				And	RIA_PD		=  %exp:cQVerba%
				And RIA_STATUS	in %exp:cQStatus%
				And RIA_DTPGAD	>= %exp:cQIniInd%
				And RIA_DTPGAD	<= %exp:cQFimInd%
				And RIA.%NotDel%
		EndSql
		DbSelectArea(cRiaAls)
		DbGoTop()
		If !Eof()
			If ((cRiaAls)->IND_OCOR) + 1 > aInden[1][10] .And. aInden[1][10] > 0
				If lPortal
					cMensa	:= OemToAnsi(STR0229)
					lGrava	:= .F.
				Else
					lGrava	:= MsgBox(OemToAnsi(STR0229) + OemToAnsi(STR0233),OemToAnsi(STR0220),"YESNO")	//"Quantidade de Indenizações excedem o permitido para o bimestre. Recomenda-se alterar a programação. " ### "Deseja Prosseguir com a Programação?"	### "Atenção!"
				EndIf
			EndIf
			If ((cRiaAls)->IND_DIND + nRiaInd) > aInden[1][11] .And. aInden[1][11] > 0 .And. lGrava
				If lPortal
					cMensa	:= OemToAnsi(STR0230)
					lGrava	:= .F.
				Else
					lGrava	:= MsgBox(OemToAnsi(STR0230) + OemToAnsi(STR0233),OemToAnsi(STR0220),"YESNO")	//"Dias de Indenização excedem o permitido para o bimestre. Recomenda-se alterar a programação. "	### "Deseja Prosseguir com a Programação?"	###	"Atenção!"
				EndIf
			EndIf
		EndIf
		(cRiaAls)->(DbCloseArea())
	EndIF

	If lGrava
		//Mensal
		aPerInd	:= fPerAnoCiv(dRiaPgIn,"M")
		cQIniInd	:= "%'" + DtoS(aPerInd[1]) + "'%"
		cQFimInd	:= "%'" + DtoS(aPerInd[2]) + "'%"

		BeginSql alias cRiaAls

			Select Count(RIA_PD) IND_OCOR, Sum(RIA_NRDIND) IND_DIND
			From %table:RIA% RIA
			Where	RIA_FILIAL  =  %exp:cQFilial%
				And	RIA_MAT		=  %exp:cQMatric%
				And	RIA_PD		=  %exp:cQVerba%
				And RIA_STATUS	in %exp:cQStatus%
				And RIA_DTPGAD	>= %exp:cQIniInd%
				And RIA_DTPGAD	<= %exp:cQFimInd%
				And RIA.%NotDel%
		EndSql
		DbSelectArea(cRiaAls)
		DbGoTop()
		If !Eof()
			If ((cRiaAls)->IND_OCOR + 1) > aInden[1][12] .And. aInden[1][12] > 0
				If lPortal
					cMensa	:= OemToAnsi(STR0231)
					lGrava	:= .F.
				Else
					lGrava	:= MsgBox(OemToAnsi(STR0231) + OemToAnsi(STR0233),OemToAnsi(STR0220),"YESNO")	//"Quantidade de Indenizações excedem o permitido para o mês. Recomenda-se alterar a programação. "	### "Deseja Prosseguir com a Programação?"	###	"Atenção!"
				EndIf
			EndIf
			If ((cRiaAls)->IND_DIND + nRiaInd) > aInden[1][13] .And. aInden[1][13] > 0 .And. lGrava
				If lPortal
					cMensa	:= OemToAnsi(STR0232)
					lGrava	:= .F.
				Else
					lGrava	:= MsgBox(OemToAnsi(STR0232) + OemToAnsi(STR0233),OemToAnsi(STR0220),"YESNO")	//"Dias de Indenização excedem o permitido para o mês. Recomenda-se alterar a programação. " ### "Deseja Prosseguir com a Programação?"	### "Atenção!"
				EndIf
			EndIf
		EndIf
		(cRiaAls)->(DbCloseArea())
	EndIf
EndIf

RestArea(aSraArea)
RestArea(aRiaArea)

If lPortal
	Return cMensa
Else
	Return lGrava
EndIf



//-------------------------------------------------------------------
/*/{Protheus.doc} VDFALTSRF
ALTERAÇÃO de Dia de Direito - SRF
@author  Marcos Pereira
@since 	 22/12/2014
@version P11
@params
/*/
//--------------------------------------------------------------------
Function VDFALTSRF(oModel)

	Local oStruSRF  := oModel:GetModel("SRFDETAIL")
	Local dIni		:= oStruSRF:GetValue("RF_DATABAS")
	Local dFim		:= oStruSRF:GetValue("RF_DATAFIM")
	Local nDReman	:= oStruSRF:GetValue("RF_DIREMAN") //DIAS REMANESCENTES
	Local nDProgr	:= oStruSRF:GetValue("RF_DIASPRG") //DIAS PROGRAMADOS
	Local cFil		:= oStruSRF:GetValue("RF_FILIAL")
	Local cMat		:= oStruSRF:GetValue("RF_MAT")
	Local cPD		:= oStruSRF:GetValue("RF_PD")
	Local cStatus	:= oStruSRF:GetValue("RF_STATUS")
	Local dNewIni	:= dIni
	Local dNewFim	:= dFim
	Local cStNews	:= cStatus
	Local oStruRIA  := oModel:GetModel("RIADETAIL")
	Local cChaveRI6
	Local cRetRI6	:= STR0249+CRLF //"Tipo/Class/Numero/Ano"
	Local lRet      := .f.
	Local aNewStat  := {}
	Local nX
	Local cTitulo 	:= STR0248

	If lSuspensao .OR. lRetifica .OR. lCancela .OR. lEmProgr .OR. lCancSRF .or. lAltSRF
		MsgBox( STR0173 ,STR0174,"STOP") // "Existe um proceso em andamento. Conclua o processo!" "Processo em andamento"
		Return
	EndIf

	If oStruRIA:Length() > 1 .or. nDProgr > 0  //Não pode alterar SRF quando existe RIA, mesmo que cancelada, pois se alterar a data inicial da SRF irá perder o relacionamento com a RIA.
		MsgBox(STR0250 ,STR0138,"STOP") //'Já existem Programações para o período selecionado. Não poderá mais ser alterado.'  'Dias de Direito'
		Return
	EndIf

	aVetor	:= LISTS106("", RA_CATFUNC, RA_REGIME, , RA_SINDICA)

	If Len( aVetor ) <= 0
		MsgBox(STR0043,cTitulo,"INFO" )//'Não existem dados na tabela S106-Tipos de Dias de Direito'
		Return
	EndIf
	nLinS106 := Ascan(aVetor,{|x| x[3] == cPD})

	//Como nao há RIA, então pode alterar a SRF independente do Status, pois irá acrescentar o RF_OBSERVA os campos alterados.

	cDescTp := STR0251 //'ALTERAR'
	cTitDlg	:= STR0252 //'da ALTERAÇÃO'

	dbSelectArea("RI6")
	dbSetOrder(4) //RI6_FILIAL+RI6_FILMAT+RI6_MAT+RI6_TABORI+RI6_CHAVE
	cChaveRI6 := FwxFilial("RI6") + cFil + cMat + "SRF" + cPD + DtoS(dIni)
	If dbSeek( cChaveRI6 )
		While !eof() .and. RI6->(RI6_FILIAL+RI6_FILMAT+RI6_MAT+RI6_TABORI)+alltrim(RI6->RI6_CHAVE) == cChaveRI6
			If !empty(RI6->RI6_NUMDOC)
				cRetRI6 += RI6->RI6_TIPDOC + ' / ' + RI6->RI6_CLASTP + '  / ' + RI6->RI6_NUMDOC + ' /' + RI6->RI6_ANO + CRLF
				lRet := .t.
			EndIf
			dbskip()
		EndDo
		If lRet
			MsgBox(STR0253+CRLF+cRetRI6,STR0254,'INFO') // 'Para a Dia de Direito em questão já existem as publicações abaixo:' ### "Alteração"
		EndIf
	EndIf

	If MsgBox(STR0187 + cDescTP + STR0197 + dtoc(dIni) + STR0061 + dtoc(dFim), cDescTp + STR0198,"YESNO")  //'Deseja realmente '  ' o Dia de Direito - '  ' Dia de Direito'

		If (nPosStat := Ascan(aStatus,{|x| left(x,1) == cStatus})) > 0
			aadd(aNewStat,aStatus[nPosStat]) //Inicializa aNewStat com o status atual da SRF para que fique na primeira posicao do combo
		EndIf
		For nX := 1 to len(aStatus)
			If nX <> nPosStat .and. left(aStatus[nX],1) $ '0/1/3' //So pode alterar p/estes status, pois para os demais há rotina específica
				aadd(aNewStat,aStatus[nX])
			EndIf
		Next nX

		DEFINE MSDIALOG oDlgData TITLE STR0255 FROM C(201),C(229) TO C(350),C(500) PIXEL //"Dados disponíveis para a Alteração"
			@ C(010),C(010) Say STR0256						Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgData//'Nova Data Base Inicial:'
			@ C(008),C(060) MsGet oData Var dNewIni 		Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgData
			@ C(025),C(010) Say STR0257						Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgData//'Nova Data Base Final:'
			@ C(023),C(060) MsGet oData Var dNewFim 		Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgData
			@ C(040),C(010) Say STR0258						Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgData//'Nova Situação:'
			@ C(038),C(060) MSCOMBOBOX oData VAR cStNews ITEMS aNewStat SIZE C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgData
			@ C(060),C(060) BmpButton Type 1 Action Close(oDlgData)
		ACTIVATE MSDIALOG oDlgData CENTERED
		cStNews := left(cStNews,1)
		If dNewIni == dIni .and. dNewFim == dFim .and. cStNews == cStatus //Se nao houve alteracao, return
			Return
		EndIF

		cObs := alltrim(oStruSRF:GetValue("RF_OBSERVA"))
		cObs += if(!empty(cObs)," / ","")+dtoc(date())+"-"+cUserName+"-"+STR0254+" " //"Alteração"
		If dNewIni <> dIni
			cObs += STR0260 + dtoc(dIni)+" " //"Dt.Inicial(ant):"
		EndIf
		If dNewFim <> dFim
			cObs += STR0261 + dtoc(dFim)+" " //"Dt.Final(ant):"
		EndIf
		If cStNews <> cStatus
			cObs += STR0262 + aStatus[Ascan(aStatus,{|x| left(x,1) == cStatus})]+" " //"Status(ant):"
		EndIf

		If cStatus $ '2/4' .and. cStNews <> cStatus  //Status anterior = 4-Cancelado ou 2-Prescrito e houve mudança de status
			cObs += STR0263 + dtoc(oStruSRF:GetValue("RF_DTCANCE"))+" " //"Dt.Canc/Pres(ant):"
		EndIf

		oStruSRF:SetValue("SRF_NEW"		, "X") //ABRE PARA EDIÇÃO
		oStruSRF:SetValue("SRF_ALT"		, "X")
		oStruSRF:SetValue("RF_DATABAS"	, dNewIni )
		oStruSRF:SetValue("RF_DATAFIM"	, dNewFim )
		oStruSRF:SetValue("RF_STATUS"	, cStNews )
		oStruSRF:SetValue("RF_OBSERVA"	, PadR(cObs,TAMSX3("RF_OBSERVA")[1]))
		oStruSRF:SetValue("RF_DTCANCE"	, ctod("//") )
		oStruSRF:SetValue("RF_HRCANCE"	, "" )
		oStruSRF:SetValue("SRF_CANC"	, " ")
		oStruSRF:SetValue("SRF_NEW"		, " ") //FECHA PARA EDIÇÃO
		lAltSRF := .T.
	EndIf
Return



Function gp051DtValid(dData)
Local oModel 	:= FWModelActive()
Local lRet		:= .T.

lGp051Auto := If (Type("lGp051Auto") == "U",.F.,lGp051Auto)

If !IsInCallSTack("GPEA053")
	If dData <= oModel:GetValue("SRFDETAIL", "RF_DATABAS")
		If lGp051Auto
			AutoGrLog( OemToAnsi(STR0021) ) //A Data de Inicio da programacao deve ser maior que a Data de Inicio do Periodo
		Else
			Help(,,STR0016,, OemToAnsi(STR0021) ,1,0)
		EndIf
		lRet := .F.
	EndIf
EndIf

If lRet .and. !Empty(oModel:GetValue("SRFDETAIL","RF_DATINI2"))
	If Empty(oModel:GetValue("SRFDETAIL","RF_DATAINI")) .or. oModel:GetValue("SRFDETAIL","RF_DATINI2") < oModel:GetValue("SRFDETAIL","RF_DATAINI") + oModel:GetValue("SRFDETAIL","RF_DFEPRO1")
		If lGp051Auto
			AutoGrLog( OemToAnsi(STR0040) )  //"A Data inicial da 2ª programação de férias deve ser maior que a Data final da 1ª programação."
		Else
			Help(,,STR0016,, OemToAnsi(STR0040) ,1,0)
		EndIf
      	lRet := .F.
    EndIf
EndIf

If lRet .and. !Empty(oModel:GetValue("SRFDETAIL","RF_DATINI3"))
	If Empty(oModel:GetValue("SRFDETAIL","RF_DATINI2")) .or. oModel:GetValue("SRFDETAIL","RF_DATINI3") < oModel:GetValue("SRFDETAIL","RF_DATINI2") + oModel:GetValue("SRFDETAIL","RF_DFEPRO2")
		If lGp051Auto
			AutoGrLog( OemToAnsi(STR0041) )  //"A Data inicial da 3ª programação de férias deve ser maior que a Data final da 2ª programação."
		Else
			Help(,,STR0016,, OemToAnsi(STR0041) ,1,0)
		EndIf
		lRet := .F.
    EndIf
EndIf

Return ( lRet )

/*/{Protheus.doc} fRIAWHENDT
	Retorna WHEN dos campos RIA_DATPAG e RIA_DTPGAD
	@type  Function
	@author gabriel.almeida
	@since 10/12/2019
	@version 1.0
	@return lWhen, Lógico, Retorna se o campo pode ou não ser editado
	/*/
Function fRIAWHENDT()
	Local lWhen     := .F.
	Local oModel    := FWModelActive()
	Local oModelRIA := oModel:GetModel( "RIADETAIL" )

	If oModelRIA:Length() > 0 .And. oModel:GetValue("RIADETAIL", "RIA_NEW") == "X"
		//Nao é retificacao e é portal
		lWhen := ( !lRetifica .And. lTcfa040 ) .Or. lRetifica .Or. IsInCallStack("bLoadRIA") .Or. FunName() == "GPEA051"
	EndIf
Return lWhen