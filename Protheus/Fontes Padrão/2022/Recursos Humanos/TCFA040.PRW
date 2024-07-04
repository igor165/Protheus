#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TCFA040.CH"
#INCLUDE "PONCALEN.CH"

#DEFINE VIEW_RESULT_OK		0
#DEFINE VIEW_RESULT_CANCEL 	1

Static lTCF040INF  	:= ExistBlock("TCF040INF")
Static lTCF040REP  	:= ExistBlock("TCF040REP")
Static lRefTrab	   	:= FindFunction("fRefTrab") .And. fRefTrab("F")
Static lIntTAF	   	:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ?TCFA040  ?Autor ?Totvs                      ?Data ?02/10/2009 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atendimento de Solicitacoes                                        ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso      ?Generico                                                          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±±±±±±±±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿±±
±±³Programador   ?Data   ?PRJ/REQ-Chamado ? Motivo da Alteracao                       ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Emerson Campos|06/05/14|M_RH003/310901   |Disponibilizado a nova opção de Solicitação ³±?
±±?             |        |                 |Subsídio Acadêmico e ajustes para P12       ³±?
±±³Renan Borges  |19/12/14|TQIS11           |Ajuste p/ validar modo de acessa tabelas    ³±?
±±?             |        |                 |vinculadas com informações do funcionário.  ³±?
±±³Renan Borges  |10/07/15|TSPBC2           |Ajuste para validar sequencia do turno, no  ³±?
±±?             |        |                 |Brasil, no cadastro de funcionários correta-³±?
±±?             |        |                 |mente, mesmo quando o parâmetro MV_USESPJ,  ³±?
±±?             |        |                 |estiver como 0, j?que não ?utilizado para ³±?
±±?             |        |                 |o Brasil.                                   ³±?
±±³Mariana M.    |14/09/15|TTALLH           |Ajuste no fonte TCFA040 para que não gere   ³±?
±±?             |        |                 |error.log referente a variável CVERGSP que  ³±?
±±?             |        |                 |não existe.A mesma foi declarada no ModelDef³±?
±±?             |        |                 |e no ViewDef como variável Local.           ³±?
±±³Matheus M.    |23/09/15|TTJLK4           |Ajuste para enviar corretamente o tipo da   ³±?
±±?             |        |                 |rescisão.                                   ³±?
±±³Mariana M.    |25/09/15|TTIWK2           |Ajuste de CH                                ³±?
±±³Renan Borges  |19/10/15|TTIBVT           |Ajuste para quando houver solicitações de   ³±?
±±?             |        |                 |funcionários com mesma matricula em filiais ³±?
±±?             |        |                 |diferentes, seja mostrado o nome dos funcio-³±?
±±?             |        |                 |nários corretamente                         ³±?
±±³Renan Borges  |09/12/15|TTSYXZ           |Ajuste para ao tentar aprovar a solicitação ³±?
±±?             |        |                 |de férias no SIGAGPE seja carregado correta-³±?
±±?             |        |                 |mente as datas de inicio e a duração das fe-³±?
±±?             |        |                 |rias.                                       ³±?
±±³EstherV.      |11/12/15|TTDITV           |Tratamento ColumnPos no campo RH3_EMP.      ³±?
±±³Matheus M.    |23/09/15|TTQAXT           |Inclusa opção de alteração cadastral do     ³±?
±±?             |        |                 |eSocial.                                    ³±?
±±ºRenan Borges  |25/04/16|TUWJKS           |Mostrar as descrições dos campos utilizados º±?
±±?             |        |                 |nas solicitações de férias.                 º±?
±±?			   |25/04/16|TUTABC           |Ajuste para posicionar sobre o registro SRF ³±?
±±?             |        |                 |correto ao lancar prog de ferias.			  ³±?
±±³Cícero Alves  ?5/07/16³TVQB91	        ³Ajuste p/ exibir pergunta p/ solicitacao de  ³±?
±±?             ?       ?                ³acao salarial p/ usuario definir atualiza o ³±?
±±?             ?       ?                ³campo de salario base de dissidio ou nao    ³±?
±±³Allyson M.    |01/08/16|TVNQAR           |Ajuste p/ verificar idade do funcionario na ³±?
±±?             |        |                 |solicitacao de ferias e abrir a tela de pro-³±?
±±?             |        |                 |gramação caso tenha idade menor de 18 ou    ³±?
±±?             |        |                 |maior de 50 anos     						     ³±?
±±³Esther Viveiro|17/08/16|     TVTYVH      |Ajuste na exibicao das mensagens para       ³±?
±±?             |        |                 |efetivacao de solicitacao de ferias.        ³±?
±±³Marcos Cout.  |13/12/16|     MRH-92      |Criação do P.E chamado logo apos a aprovacao³±?
±±?             |        |                 |de uma solicitação realizada.               ³±?
±±³Marcelo Faria |27/01/17|MRH-5800         |Criação do P.E logo apos a reprovacao       ³±?
±±?             |        |tckt #403140     |de uma solicitação realizada.               ³±?
±±³Eduardo K.    |10/03/17|MPRIMESP-9307  	|Ajuste p/ gravação do campo RA3_PORTAL      ³±?
±±|Renan Borges  |26/04/17|DRHPONTP-301     |Ajuste para ao aprovar uma solicitação de   ³±?
±±|              |        |                 |Transferência, o sistema trazer o posto     ³±?
±±|              |        |                 |que foi informado na solicitação.           ³±?
±±³Oswaldo L     |27-04-17|DRHPONTP300      | Entre os dias 24-04-17 e 26-04-17			 ³±?
±±?             |        |                 | baixamos os fontes do TFS das pastas		 ³±?
±±?             |        |                 | MAIN, 12.1.14 e 12.1.16. Conforme   		 ³±?
±±?             |        |                 | solicitado fizemos merge delas,depois		 ³±?
±±?             |        |                 | removemos alteracoes em SX          		 ³±?
±±|Esther V.     |23/05/17|  DRHPONTP-580   |Ajuste na funcao Grava() para reposicionar  ³±?
±±|              |        |                 |a SRA no funcionario da solicitacao atual.  ³±?
±±|Willian U.    |16/06/17|DRHPONTP-936     |Inserida string para ajustar o título da    ³±?
±±|              |        |                 |rotina Solicitações ao RH.                  ³±?
±±|M. Silveira   |22/06/17|DRHPONTP-924     |Ajustes na funcao Grava() para considerar a ³±?
±±|              |        |                 |filial onde a vaga foi incluida.            ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

//-----------------------------------------------------------------------
/*/{Protheus.doc} TCFA040()
Atendimento de Solicitacoes

@author Rogerio Ribeiro da Cruz
@since 02/10/2009
@version 1.0
/*/
//-----------------------------------------------------------------------
Function TCFA040()
	Local oMBrowse
	Local cFiltro := ""
	Local aAllUser := {}
	Local nTamEmp  := 0
	Local nTamFil  := 0

	Private oReturn
	Private cAliasQry
	Private cOBS    := space(250)
	Private cFilUsr := ""
	Private cMatUsr := ""
	Private cTpUser := "" // Tipos de solicitação customizados
	Private nPer13S := SuperGetMv("MV_PERC13S", NIL, 0) //Percentual padrao de 13º Salario

	Private cVerGSP  := SuperGetMv("MV_GSPUBL",,"1")
	Private cConCTT		:= .F.
	Private cConDept	:= .F.
	Private cConProc	:= .F.
	Private cConPosto	:= .F.
	If FindFunction("existF3New")
		existF3New(@cConCTT, @cConDept, @cConProc, @cConPosto)
	EndIf
	
	If cVerGSP == "2" .And. GetMv("MV_VDFLOGO",,"0") <> "0"
		cVerGSP := "3"
	EndIf

	If !ValTab()
		Return
	EndIf

	//Busca vinculo funcional
	If (PswSeek(__cUserId,.T.))
		aAllUser := PswRet()

		nTamEmp := len(Alltrim(cEmpAnt))
		nTamFil := len(Alltrim(cFilAnt))

		cFilUsr := SUBSTR(aAllUser[1,22], nTamEmp+1, nTamFil)
		cMatUsr := SUBSTR(aAllUser[1,22], nTamEmp+nTamFil+1, 6)
	EndIf

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("RH3")
	oMBrowse:AddLegend('RH3->RH3_STATUS=="1"',  "YELLOW", STR0004) //"Solicitado"
	oMBrowse:AddLegend('RH3->RH3_STATUS=="2"',  "GREEN"	, STR0005) //"Atendido"
	oMBrowse:AddLegend('RH3->RH3_STATUS=="3"',  "RED"	, STR0006) //"Rejeitado"
	If cVerGSP == "3"
		oMBrowse:AddLegend('RH3->RH3_STATUS=="5"',  "ORANGE", STR0010) //"Aguardando Aprovacao RH"
    EndIf
    oMBrowse:AddLegend('RH3->RH3_STATUS=="4"',  "BLUE"	, STR0009) //"Aguardando Efetivacao RH"

	// Ponto de entrada para filtrar tipos de solicitações customizados
	If ExistBlock("TCF040TP")
		cTpUser := ExecBlock("TCF040TP", .F., .F., {cModulo})
	EndIf

	cFiltro := "RH3_TIPO $ '" + GetTipos() + "'"

	/*Tratamento ColumnPos provisorio ate saida dos campos no dicionario*/
	If RH3->(ColumnPos("RH3_EMP")) > 0
		cFiltro += " .AND. ( Empty(RH3_EMP) .Or. RH3_EMP == '"+cEmpAnt+"')"
	End If

	oMBrowse:SetFilterDefault(cFiltro)
	oMBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional

@return aRotina - Estrutura
            [n,1] Nome a aparecer no cabecalho
            [n,2] Nome da Rotina associada
            [n,3] Reservado
            [n,4] Tipo de Transação a ser efetuada:
                1 - Pesquisa e Posiciona em um Banco de Dados
                2 - Simplesmente Mostra os Campos
                3 - Inclui registros no Bancos de Dados
                4 - Altera o registro corrente
                5 - Remove o registro corrente do Banco de Dados
                6 - Alteração sem inclusão de registros
                7 - Copia
                8 - Imprimir
            [n,5] Nivel de acesso
            [n,6] Habilita Menu Funcional
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	Local aArea	:= GetArea()

	ADD OPTION aRotina TITLE STR0001 ACTION "VIEWDEF.TCFA040" OPERATION 2 ACCESS 0	//"Atende"

	ADD OPTION aRotina TITLE STR0012 ACTION "TCFA040Leg" OPERATION 2 ACCESS 0	//"Legenda"

	DbSelectArea("SX1")
	DbSetOrder(1)

	If dbSeek("TCF40SUB")
		ADD OPTION aRotina TITLE STR0142 ACTION "TCFA040Sub" OPERATION 4 ACCESS 0	//"Subst.Aprovador"
	EndIf

	RestArea(aArea)

	ADD OPTION aRotina TITLE STR0158 ACTION "AtendeLote" OPERATION 2 ACCESS 0	//"Atender em Lote"

Return aRotina

Function TCFA040Sub()
Local lRet	:= .T.
Local nOpcA	:= 0
Local aArea			:= GetArea()
Local aSays			:= {}
Local aButtons		:= {}
Private cCadPart   := OemToAnsi( STR0142 ) // 'Subst.Aprovador'

AADD(aSays,OemToAnsi( STR0143 )) // "Esta rotina tem como objetivo substituir o aprovador em solicitações que estão em "
AADD(aSays,OemToAnsi( STR0144 ) )// "processo de aprovação."

AADD(aButtons, { 5,.T.,{|| Pergunte("TCF40SUB",.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(),FechaBatch(),nOpcA := 0 ) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadPart, aSays, aButtons )

IF ( nOpcA == 1 )
	Processa({|| TCF40Apro() },OemToAnsi(STR0145)) //"Substituindo Aprovador... "
	MostraErro()
EndIF

RestArea( aArea )

Return lRet

/*/{Protheus.doc} TCF40Apro
@author martins.marcio
@since 01/10/2019
@version 1.0
@type function
/*/
Function TCF40Apro()

Local cAliasRH3 := getNextAlias()
Local cAliasSRA := getNextAlias()
Local lAtualizou := .F.
Local cFilDe	:= MV_PAR01
Local cFilAte	:= MV_PAR02
Local cCodDe	:= MV_PAR03
Local cCodAte	:= MV_PAR04
Local dDtSolDe	:= MV_PAR05
Local dDtSolAte	:= MV_PAR06
Local cEmpAprv	:= MV_PAR07
Local cFilAprv	:= MV_PAR08
Local cMatAprv	:= MV_PAR09
Local cNvEmpAprv:= MV_PAR10
Local cNvFilAprv:= MV_PAR11
Local cNvMatAprv:= MV_PAR12
Local lNvMatOk	:= .T.
Local cTabSra	:= ""

If Empty(MV_PAR05)
	Pergunte("TCF40SUB",.T. )
	cFilDe		:= MV_PAR01
	cFilAte		:= MV_PAR02
	cCodDe		:= MV_PAR03
	cCodAte		:= MV_PAR04
	dDtSolDe	:= MV_PAR05
	dDtSolAte	:= MV_PAR06
	cEmpAprv	:= MV_PAR07
	cFilAprv	:= MV_PAR08
	cMatAprv	:= MV_PAR09
	cNvEmpAprv	:= MV_PAR10
	cNvFilAprv	:= MV_PAR11
	cNvMatAprv	:= MV_PAR12
EndIf

// Valida a NOVA Matricula
cTabSra	:= "%"+ RetFullName("SRA",cNvEmpAprv)+"%"
BeginSql alias cAliasSRA
	SELECT SRA.R_E_C_N_O_
	FROM %Exp:cTabSra% SRA
	WHERE 	SRA.RA_FILIAL	= %exp:cNvFilAprv% AND
			SRA.RA_MAT		= %exp:cNvMatAprv% AND
			SRA.RA_SITFOLH	<> "D" AND
			SRA.%notDel%
EndSql

If (cAliasSRA)->(Eof())
	AutoGrLog(OemToAnsi(STR0150)) // " A nova matrícula escolhida ?inválida, revise os parâmetros."
	lNvMatOk := .F.
EndIf

(cAliasSRA)->( DbCloseArea() )

If lNvMatOk

	AutoGrLog(OemToAnsi(STR0148) + ": "+cEmpAprv + "/"+cFilAprv+"/"+cMatAprv) // Aprov. Anterior": ##/######/#######
	AutoGrLog(OemToAnsi(STR0146) + ": "+cNvEmpAprv + "/"+cNvFilAprv+"/"+cNvMatAprv) // Novo Aprovador: ##/######/#######
	AutoGrLog(" ")
	AutoGrLog(Replicate("-",60))
	AutoGrLog(" ")

	BeginSql alias cAliasRH3
		SELECT RH3.R_E_C_N_O_, RH3.RH3_FILIAL, RH3.RH3_CODIGO, RH3.RH3_MAT, RH3.RH3_ORIGEM, RH3.RH3_STATUS, RH3.RH3_DTSOLI, RH3.RH3_FILAPR, RH3.RH3_MATAPR
		FROM %table:RH3% RH3
		WHERE 	RH3.RH3_FILIAL >= %exp:cFilDe% AND
				RH3.RH3_FILIAL <= %exp:cFilAte% AND
				RH3.RH3_CODIGO >= %exp:cCodDe% AND
				RH3.RH3_CODIGO <= %exp:cCodAte% AND
				RH3.RH3_DTSOLI >= %exp:DTOS(dDtSolDe)% AND
				RH3.RH3_DTSOLI <= %exp:DTOS(dDtSolAte)% AND
				RH3.RH3_EMPAPR = %exp:cEmpAprv% AND
				RH3.RH3_FILAPR = %exp:cFilAprv% AND
				RH3.RH3_MATAPR = %exp:cMatAprv% AND
				RH3.RH3_STATUS = "1" AND
				RH3.%notDel%
	EndSql

	AutoGrLog(OemToAnsi(STR0147)) // "Solicitações atualizadas:"
	DbSelectArea("RH3")
	While !(cAliasRH3)->(Eof())

		DbGoTo((cAliasRH3)->R_E_C_N_O_)

		If RecLock("RH3",.F.)
			RH3->RH3_EMPAPR := cNvEmpAprv
			RH3->RH3_FILAPR := cNvFilAprv
			RH3->RH3_MATAPR := cNvMatAprv
			lAtualizou := .T.
			AutoGrLog(AllTrim(RH3->RH3_FILIAL) +"/"+ AllTrim(RH3->RH3_CODIGO))
			RH3->(MsUnlock())
		EndIf

		(cAliasRH3)->( dbSkip() )
	EndDo

	If !lAtualizou
		AutoGrLog(" ")
		AutoGrLog(OemToAnsi(STR0149)) //"Nenhuma solicitação foi encontrada, revise os parâmetros."
	EndIf

	(cAliasRH3)->( DbCloseArea() )

EndIf

Return( NIL )

//-------------------------------------------------------------------
/*/{Protheus.doc} TCFA040Leg()
Legendas do workflow

@author Marcelo Faria
@since 04/04/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function TCFA040Leg()

	Local aLegenda	:= {}
	Local aSvKeys	:= GetKeys()

	If cVerGSP == "3"
		aLegenda := {;
							{ "BR_AMARELO" , OemToAnsi( STR0004 ) } ,; //"Solicitado"
							{ "BR_VERDE"   , OemToAnsi( STR0005 ) } ,; //"Atendido"
							{ "BR_VERMELHO", OemToAnsi( STR0006 ) } ,; //"Rejeitado"
							{ "BR_AZUL"    , OemToAnsi( STR0009 ) } ,; //"Aguardando efetivacao RH"
							{ "BR_LARANJA" , OemToAnsi( STR0010 ) }  ; //"Aguardando aprovacao RH"
						 }

	Else
		aLegenda := {;
							{ "BR_AMARELO" , OemToAnsi( STR0004 ) } ,; //"Solicitado"
							{ "BR_VERDE"   , OemToAnsi( STR0005 ) } ,; //"Atendido"
							{ "BR_VERMELHO", OemToAnsi( STR0006 ) } ,; //"Rejeitado"
							{ "BR_AZUL"    , OemToAnsi( STR0009 ) } ; //"Aguardando efetivacao RH"
						 }
	EndIf
	BrwLegenda(	STR0011 , STR0012 , aLegenda ) //"Legendas do Workflow"

	RestKeys( aSvKeys )

Return( NIL )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do modelo da regra de negocios

@author Rogerio Ribeiro
@since 02/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel     := MPFormModel():New("TCFA040")
	Local oStructRH3 := FWFormStruct(1, "RH3")
	Local oStructRH4 := FWFormStruct(1, "RH4")
	Local oStructRGK := FWFormStruct(1, "RGK")
	Local cVerGSP    := SuperGetMv("MV_GSPUBL",,"1")

	oStructRH3:SetProperty( "RH3_MAT", MODEL_FIELD_OBRIGAT, .F. )

	oModel:AddFields("TCFA040_RH3", NIL, oStructRH3)

	//Gestao Publica - MP
	If cVerGSP == "2"
		oStructRGK:AddField( ;                  // Ord. Tipo Desc.
		AllTrim( 'Nome Aprovador' )   , ;      // [01]  C   Titulo do campo
		AllTrim( 'Nome Aprovador' )   , ;      // [02]  C   ToolTip do campo
		'RGK_NMAPR'                     , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		70                               , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'GetNomeSRA(RGK->RGK_FILAPR,RGK->RGK_MATAPR)') , ;  // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo ?virtual

		oStructRGK:AddField( ;                  // Ord. Tipo Desc.
		AllTrim( 'Observação' )       , ;      // [01]  C   Titulo do campo
		AllTrim( 'Observação' )       , ;      // [02]  C   ToolTip do campo
		'RGK_OBS'                       , ;      // [03]  C   Id do Field
		'M'                              , ;      // [04]  C   Tipo do campo
		80                               , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'GetMemoRDY(RGK->RGK_CODCON)') , ;      // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo ?virtual

		oModel:AddGrid(   "TCFA040_RGK",;     //cId - Identificador do modelo
							"TCFA040_RH3",;     //cOwner - Identificador superior do modelo
							oStructRGK,;     //oModelStruct - Objeto com a estrutura de dados
									NIL,;     //bLinePre - Code-Block de pre-edição da linha do grid de edição. Indica se a edição esta liberada
									NIL,;     //bLinePost - Code-Block de validação da linha do grid de edição
									NIL,;     //bPre - Code-Block de pre-edição do grid de edição. Indica se a edição esta liberada
									NIL,;     //bPost - Code-Block de validação do grid de edição
										NIL;     //bLoad - Code-Block de carga dos dados do formulário de edição
						)
	EndIf

	oModel:AddGrid(	"TCFA040_RH4",;			//cId - Identificador do modelo
						"TCFA040_RH3",;			//cOwner - Identificador superior do modelo
					  	   	oStructRH4,;			//oModelStruct - Objeto com a estrutura de dados
									NIL,;			//bLinePre - Code-Block de pre-edição da linha do grid de edição. Indica se a edição esta liberada
									NIL,;			//bLinePost - Code-Block de validação da linha do grid de edição
									NIL,;			//bPre - Code-Block de pre-edição do grid de edição. Indica se a edição esta liberada
									NIL,;			//bPost - Code-Block de validação do grid de edição
										{|oGrid|CargaGrid(oGrid)};			//bLoad - Code-Block de carga dos dados do formulário de edição
							)
	oModel:GetModel("TCFA040_RH4"):SetOnlyQuery(.T.)

	oModel:SetPrimaryKey({"RH3_CODIGO"})

	If cVerGSP == "2"
    	oModel:GetModel("TCFA040_RGK"):SetUniqueLine({"RGK_SEQUEN"}) //Diz ao model que o campo deve ser validado quanto a repeticao
        oModel:SetRelation( "TCFA040_RGK", {   {"RGK_FILIAL", "xFilial('RGK')"}, {"RGK_CODIGO", "RH3_CODIGO"} }, "RGK_FILIAL+RGK_CODIGO+STR(RGK_SEQUEN,3)")
    EndIf

	oModel:SetDescription(STR0089)

	oModel:GetModel("TCFA040_RH4"):SetUniqueLine({"RH4_ITEM"}) //Diz ao model que o campo deve ser validado quanto a repeticao

	oModel:SetRelation(	 "TCFA040_RH4",;
						{	{"RH4_FILIAL", "xFilial('RH4', RH3->RH3_FILIAL)"},;
					      	{"RH4_CODIGO", "RH3_CODIGO"}	},;
							 "RH4_FILIAL+RH4_CODIGO+STR(RH4_ITEM,3)")


Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

@author Rogerio Ribeiro
@since 02/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel 	:= FWLoadModel("TCFA040")
	Local oView 	:= FWFormView():New()

	Local oStructRH3 := FWFormStruct(2, "RH3")
	Local oStructRH4 := FWFormStruct(2, "RH4")
	Local oStructRGK := FWFormStruct(2, "RGK")
	Local cVerGSP    := SuperGetMv("MV_GSPUBL",,"1")

	oStructRH3:RemoveField("RH3_FILIAL")
	oStructRH3:RemoveField("RH3_VISAO")
	oStructRH3:RemoveField("RH3_NVLINI")
	oStructRH3:RemoveField("RH3_FILINI")
	oStructRH3:RemoveField("RH3_MATINI")
	oStructRH3:RemoveField("RH3_NVLAPR")
	oStructRH3:RemoveField("RH3_FILAPR")
	oStructRH3:RemoveField("RH3_MATAPR")
	oStructRH3:RemoveField("RH3_WFID")
	oStructRH3:RemoveField("RH3_IDENT")
	oStructRH3:RemoveField("RH3_KEYINI")

	oStructRH4:RemoveField("RH4_FILIAL")
	oStructRH4:RemoveField("RH4_CAMPO")
	oStructRH4:RemoveField("RH4_CODIGO")

	If !(RH3->RH3_TIPO $ "1")
		oStructRH4:RemoveField("RH4_VALANT")
	EndIf

	//Gestao Publica - MP
	If cVerGSP == "2"
		oStructRGK:RemoveField("RGK_FILIAL")
		oStructRGK:RemoveField("RGK_MAT")
		oStructRGK:RemoveField("RGK_CODIGO")
		oStructRGK:RemoveField("RGK_CODCON")
		oStructRGK:RemoveField("RGK_CONTEU")

		oStructRGK:AddField( ;                     // Ord. Tipo Desc.
		'RGK_NMAPR'                       , ;      // [01]  C   Nome do Campo
		'10'                                , ;      // [02]  C   Ordem
		AllTrim( 'Nome Aprovador' )     , ;      // [03]  C   Titulo do campo
		AllTrim( 'Nome Aprovador' )     , ;      // [04]  C   Descricao do campo
		NIL                                , ;      // [05]  A   Array com Help
		'M'                                , ;      // [06]  C   Tipo do campo
		NIL                                , ;      // [07]  C   Picture
		NIL                                , ;      // [08]  B   Bloco de Picture Var
		''                                 , ;      // [09]  C   Consulta F3
		.F.                                , ;      // [10]  L   Indica se o campo ?alteravel
		NIL                                , ;      // [11]  C   Pasta do campo
		NIL                                , ;      // [12]  C   Agrupamento do campo
		NIL                                , ;      // [13]  A   Lista de valores permitido do campo (Combo)
		NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
		NIL                                , ;      // [15]  C   Inicializador de Browse
		.T.                                , ;      // [16]  L   Indica se o campo ?virtual
		NIL                                , ;      // [17]  C   Picture Variavel
		NIL                                )        // [18]  L   Indica pulo de linha após o campo

		oStructRGK:AddField( ;                     // Ord. Tipo Desc.
		'RGK_OBS'                          , ;      // [01]  C   Nome do Campo
		'11'                               , ;      // [02]  C   Ordem
		AllTrim( 'Observacao' )          , ;      // [03]  C   Titulo do campo
		AllTrim( 'Observacao' )          , ;      // [04]  C   Descricao do campo
		NIL                                , ;      // [05]  A   Array com Help
		'M'                                , ;      // [06]  C   Tipo do campo
		NIL                                , ;      // [07]  C   Picture
		NIL                                , ;      // [08]  B   Bloco de Picture Var
		''                                 , ;      // [09]  C   Consulta F3
		.F.                                , ;      // [10]  L   Indica se o campo ?alteravel
		NIL                                , ;      // [11]  C   Pasta do campo
		NIL                                , ;      // [12]  C   Agrupamento do campo
		NIL                                , ;      // [13]  A   Lista de valores permitido do campo (Combo)
		NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
		NIL                                , ;      // [15]  C   Inicializador de Browse
		.T.                                , ;      // [16]  L   Indica se o campo ?virtual
		NIL                                , ;      // [17]  C   Picture Variavel
		NIL                                )        // [18]  L   Indica pulo de linha após o campo

		oView:SetModel(oModel)
		oView:AddField("TCFA040_RH3", oStructRH3)
		oView:AddGrid("TCFA040_RGK", oStructRGK)
		oView:AddGrid("TCFA040_RH4", oStructRH4)

		oView:CreateHorizontalBox("TOP", 30)
		oView:CreateHorizontalBox("MIDDLE", 30)
		oView:CreateHorizontalBox("BOTTOM", 40)

		oView:SetOwnerView("TCFA040_RH3", "TOP")
		oView:SetOwnerView("TCFA040_RGK", "MIDDLE")
		oView:SetOwnerView("TCFA040_RH4", "BOTTOM")
	Else
		oView:SetModel(oModel)
		oView:AddField("TCFA040_RH3", oStructRH3)

		oView:AddGrid("TCFA040_RH4", oStructRH4)
		oView:CreateHorizontalBox("TOP", 50)
		oView:CreateHorizontalBox("BOTTOM", 50)

		oView:SetOwnerView("TCFA040_RH3", "TOP")
		oView:SetOwnerView("TCFA040_RH4", "BOTTOM")
	EndIf

	oView:AddUserButton(STR0039, "SDUSETDEL", {|| TCFA040Atende()})				//"Aprovar"
	oView:AddUserButton(STR0040, "BMPDEL"   , {|| TCFA040Rejeita() }) 			    //"Reprovar"
	If RH3->RH3_TIPO $ "Q"
		oView:AddUserButton('Relat.Afast.', "TCFA040", {|oModel|VDFR040(oModel) })				//"Relat.Afast."
	EndIf

	If cVerGSP == "1"
		oView:AddUserButton(STR0038, "CLIPS", {|oModel| ViewCurric(oModel) }) 	//"Currículo"
		oView:AddUserButton(STR0046, "CLIPS", {|| RSPM002() }) 					//"Seleção Interna"
	EndIf

	//Afastamentos incluidos pelo MeuRH - Tratamento da imagem do atestado
	If RH3->(ColumnPos("RH3_BITMAP")) .And. !Empty(RH3->RH3_BITMAP) .And. RH3->RH3_TIPO $ "R|8" .And. !(cVerGSP $ "2/3") .And. FindFunction("FGETIMGMEDICAL")
		oView:AddUserButton(STR0176, "CLIPS", {|| fGetImgMedical(.T.) }) //"Salvar anexo da solicitação"
	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} TCFA040Atende()

@author Rogerio Ribeiro
@since 02/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TCFA040Atende(lLote)

	Local cUserIni		:= ""
	Local cTipo			:= ""
	Local lTCF040Vld	:= ExistBlock( "TCF040VLD" )
	Local lTCF040PE		:= .F.
	Local aDadosApr		:= {}

	Default lLote := .F.

	If !Valida()
		Return
	EndIf

	//Aprovacao Gestao Publica - MP
	If cVerGSP == "3"
		If !Empty(RH3->RH3_WKFAPV) .and. RH3->RH3_STATUS == '5'
			If MsgYesNo(STR0067, STR0014) //Confirma a aprovacao da solicitacao na etapa do workflow?

				If fCapturaHistorico( , lLote) //Captura historico
					Grava("5", lLote)

					If oReturn <> Nil
						//Atualiza historico
						Reclock("RGK",.T.)
						RGK->RGK_FILIAL := RH3->RH3_FILIAL
						RGK->RGK_MAT    := RH3->RH3_MAT
						RGK->RGK_CODIGO := RH3->RH3_CODIGO
						RGK->RGK_DATA   := dDataBase
						RGK->RGK_SEQUEN := GetRGKSeq(RH3->RH3_CODIGO)
						RGK->RGK_FILAPR := cFilUsr
						RGK->RGK_MATAPR := cMatUsr
						RGK->RGK_OPERAC := '3' //Aprovacao
						ApdMsMm(RGK->RGK_CODCON, NIL, NIL, cOBS, 1, NIL, NIL, "RGK", "RGK_CODCON")
						RGK->( MsUnlock() )

						//Variavel do PE lTCF040INF
						aDadosApr := {}
						aAdd(aDadosApr,{RH3->RH3_CODIGO, RH3->RH3_TIPO})

						//Acionamento do PE após validação
						If lTCF040INF
							ExecBlock("TCF040INF",.F.,.F.,aDadosApr)
						EndIf

						WFSolicPortal(3, RH3->RH3_CODIGO, Nil, RH3->RH3_FILIAL,"3")

						MsgInfo(STR0068, STR0013) //Solicitacao aprovada na etapa!

					Else
						MsgInfo(STR0061, STR0013) //Etapa do workflow nao localizada!
					Endif
				Else
					MsgInfo(STR0062, STR0013) //Procedimento cancelado!
				EndIf
			EndIf

			Return
		EndIf
	EndIf

//Aprovacao Padrao
	If GetRPORelease() < "12.1.025" .And. RH3->RH3_TIPO == "V" .And. ! VldOutBen() // Validação Subsídio acadêmico apenas para versões anteriores a 12.1.25
		Return
	EndIf

	If lLote .Or. MsgYesNo(STR0016, STR0014) //Confirma a aprovacao da solicitacao?

		If cVerGSP == "3"             //Gestao Publica - MP
			If fCapturaHistorico()    //Captura historico
				Grava("2", lLote)
			EndIf
		Else
    		// - Ponto de Entrada para validar os registros antes de efetuar a gravação.
			// - Caso o cliente possua necessidade de customizar o momento de atender a solicitação.
			If lTCF040VLD
				lTCF040PE := ExecBlock("TCF040VLD")
				If lTCF040PE
					// - Dependendo do retorno da User Function do P.E
					// - Será ou não gravada a solicitação.
					Grava("2", lLote)
				Else
					MsgInfo(STR0088) //A solicitação não poderá ser aprovada.
					If MsgYesNo(STR0018, STR0015) //Confirma a reprovação da solicitacao?
						Grava("3")
						If !lLote
							MsgInfo(STR0019, STR0013) //Solicitação reprovada!
						Else
							aAdd(aLog, STR0019) //Solicitação reprovada!
						EndIf
						Return
					Else
						If !lLote
							MsgInfo(STR0009) // - Aguardando Aprovação do RH.
						Else
							aAdd(aLog, STR0009)
						EndIf
						Return
					EndIf
				EndIf
			Else
				Grava("2", lLote)
			EndIf
		EndIf

		If oReturn <> Nil
			If cVerGSP == "3"     //Gestao Publica - MP
				//Atualiza historico
				Reclock("RGK",.T.)
				RGK->RGK_FILIAL := RH3->RH3_FILIAL
				RGK->RGK_MAT    := RH3->RH3_MAT
				RGK->RGK_CODIGO := RH3->RH3_CODIGO
				RGK->RGK_DATA   := dDataBase
				RGK->RGK_SEQUEN := GetRGKSeq(RH3->RH3_CODIGO)
				RGK->RGK_FILAPR := cFilUsr
				RGK->RGK_MATAPR := cMatUsr
				RGK->RGK_OPERAC := '3' //Aprovacao
				ApdMsMm(RGK->RGK_CODCON, NIL, NIL, cOBS, 1, NIL, NIL, "RGK", "RGK_CODCON")
				RGK->( MsUnlock() )
			EndIf

			//Variavel e PE para alerta apos aprovação de solicitação
			aDadosApr := {}
			aAdd(aDadosApr,{RH3->RH3_CODIGO, RH3->RH3_TIPO})

			If FWHasBPM() .And. RH3->RH3_FLUIG > 0//verifica se cliente tem Fluig configurado
				cUserIni := fUserFluig(RH3->RH3_FILIAL,RH3->RH3_MAT)

				If Alltrim(RH3->RH3_TIPO) == "B"
					cTipo := "SOLFER"
				Else
					cTipo := "SOLRH" + Alltrim(RH3->RH3_TIPO)
					dbSelectArea("CPG")
					CPG->(dbSetOrder(1))
					If CPG->(dbSeek(xFilial("CPG")+Padr(cTipo,TamSx3("CPG_CODPRC")[1]," ")+"003"))
						If !Empty(CPG->CPG_MAUSER)
							cUserIni := FWWFColleagueId(CPG->CPG_MAUSER)//fUserFluig(RH3->RH3_FILIAL,RH3->RH3_MAT)
						EndIf
					EndIf
					MoveProcess(cTipo,RH3->RH3_FLUIG,cUserIni,{cUserIni},4,STR0017,.T.)
				EndIf

			Endif
			If !lLote
				MsgInfo(STR0017, STR0013) //Solicitacao aprovada!
			Else
				aAdd(aLog, STR0017) // Solicitação aprovada!
			EndIf

			If lTCF040INF
				ExecBlock("TCF040INF",.F.,.F.,aDadosApr)
			EndIf

		Endif
	EndIf

Return .F.


Function TCFA40Rej( cObserva, cFilRH3, cIDRH3, cMatRest, cEmpRH3, lLote )
    Local lRet := .F.
	Local aDadosRep := {}

    DEFAULT cFilRH3  := ""
    DEFAULT cIDRH3   := ""
    DEFAULT cMatRest := ""
	DEFAULT cEmpRH3  := cEmpAnt
	DEFAULT lLote 	 := .F.

    If !Empty(cIDRH3)
        RH3->(dbSetOrder(1))
        If !RH3->( MsSeek( cFilRH3 + cIDRH3 ) )
            Return .F.
        EndIf

        //Marca como excluida a marcacao na tabela SP8
		lRet := GetDataForJob( "2", {cFilRH3, cMatRest, cIDRH3, cObserva}, cEmpRH3 )

        cFilUsr := cFilRH3
        cMatUsr := cMatRest
        oReturn := Nil
    EndIf

    If Empty(cIDRH3)
	    cOBS := cObserva
	    Grava("3")
	EndIf

	If oReturn <> Nil
			//Atualiza historico
			Reclock("RGK",.T.)
			RGK->RGK_FILIAL := RH3->RH3_FILIAL
			RGK->RGK_MAT    := RH3->RH3_MAT
			RGK->RGK_CODIGO := RH3->RH3_CODIGO
			RGK->RGK_DATA   := dDataBase
			RGK->RGK_SEQUEN := GetRGKSeq(RH3->RH3_CODIGO)
			RGK->RGK_FILAPR := cFilUsr
			RGK->RGK_MATAPR := cMatUsr
			RGK->RGK_OPERAC := '4' //Reprovacao
			ApdMsMm(RGK->RGK_CODCON, NIL, NIL, cOBS, 1, NIL, NIL, "RGK", "RGK_CODCON")
			RGK->( MsUnlock() )

			aDadosRep := {}
			aAdd(aDadosRep, {RH3->RH3_CODIGO, RH3->RH3_TIPO})

			If lTCF040REP
				ExecBlock("TCF040REP",.F.,.F.,aDadosRep)
			EndIf

			If lLote .And. !lJustifica // Mantem a justificativa para a execução em lote
				cOBS := Space(250)
			EndIf

			lRet := .T.
	Endif
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TCFA040Rejeita()

@author Rogerio Ribeiro
@since 02/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TCFA040Rejeita(lLote)

	Local lMeuRH	:= AllTrim(Upper(RH3->RH3_ORIGEM)) == "MEURH"
	Local cUserIni  := ""
	Local cTipo     := ""
	Local aDadosRep := {}

	Default lLote := .F.

	If !Valida()
		Return
	EndIf

	If lLote .Or. MsgYesNo(STR0018, STR0015) //Confirma a reprovação da solicitacao?
		aDadosRep := {}
		aAdd(aDadosRep, {RH3->RH3_CODIGO, RH3->RH3_TIPO})

		//Gestao Publica - MP ou Reprovacao de Licenca/Atestado do MeuRH
		If cVerGSP == "3" .Or. lMeuRH

			If (lLote .And. lJustifica) .Or. fCapturaHistorico( lMeuRH, lLote ) //Captura historico
                TCFA40Rej(cObs,,,,,lLote)
				If !lLote
					MsgInfo(STR0019, STR0013) //Solicitação reprovada!
				Else
					aAdd(aLog, STR0019)
				EndIF
			Else
				If !lLote
					MsgInfo(STR0062, STR0013) //Procedimento cancelado!
				Else
					aAdd(aLog, STR0062)
				EndIF
			EndIf
		Else
			Grava("3")
			If FWHasBPM() .And. RH3->RH3_FLUIG > 0//verifica se cliente tem Fluig configurado
				If Alltrim(RH3->RH3_TIPO) == "B"
					cTipo := "SOLFER"
				Else
					cTipo := "SOLRH" + Alltrim(RH3->RH3_TIPO)
					dbSelectArea("CPG")
					CPG->(dbSetOrder(1))
					If CPG->(dbSeek(xFilial("CPG")+Padr(cTipo,TamSx3("CPG_CODPRC")[1]," ")+"003"))
						If !Empty(CPG->CPG_MAUSER)
							cUserIni := FWWFColleagueId(CPG->CPG_MAUSER)//fUserFluig(RH3->RH3_FILIAL,RH3->RH3_MAT)
						EndIf
					EndIf

					MoveProcess(cTipo,RH3->RH3_FLUIG,cUserIni,{cUserIni},4,STR0019,.T.)
				EndIf
			Endif

			If lTCF040REP
				ExecBlock("TCF040REP",.F.,.F.,aDadosRep)
			EndIf

			If !lLote
				MsgInfo(STR0019, STR0013) //Solicitação reprovada!
			Else
				aAdd(aLog, STR0019)
			EndIF

		EndIf
	EndIf

Return .F.


//-------------------------------------------------------------------
/*/{Protheus.doc} Grava()
@author Rogerio Ribeiro
@since 02/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Grava(cStatus, lLote)

	Local aDtFer		:= {}
	Local aDadosSRH		:= {}
	Local aPerFerias	:= {}
	Local nx
	Local oModel    	:= FWLoadModel("TCFA040")
	Local oModRH3   	:= oModel:GetModel("TCFA040_RH3")
	Local oModGPE
	Local oModSRF
	Local oModSR8
	Local cSolicRej   	:= GetMv("MV_SOLICRP", NIL, "0") //0=Volta para Solicitante;1=Volta para Gestor do solicitante
	Local aWorkflow     := {}

	local cTpAlt    	:= ""
	Local cFuncao   	:= ""
	Local cCargo    	:= ""
	Local cMensagem		:= ""
	Local nSalario  	:= 0
	Local cCateg		:= ""
	Local cAliasRF0Qry	:= ""
	Local cCodAbo		:= ""
	Local cMat			:= ""
	Local dDtPreF		:= cToD("//")
	Local dDtPreI		:= cToD("//")
	Local nHorFim		:= 0
	Local nHorIni		:= 0
	Local nIdade		:= 0
	Local nTamFilial	:= FWGETTAMFILIAL
	Local nTamMat		:= TAMSX3("RA_MAT")[1]

	Local cTrmFilial	:= ""
	Local cTrmMat		:= ""
	Local cTrmCalend	:= ""
	Local cTrmCurso		:= ""
	Local cTrmTurma		:= ""
	Local cTrmPortal	:= ""

	Local nDiasAb		:= 0
	Local cDatabas		:= ""
	Local cFerFilial	:= ""
	Local cFerMat		:= ""
	Local lFerAbono		:= .F.
	Local lFer13Sal		:= .F.
	Local cMsgEmail		:= ''
	Local aArea

	Local cAfaFilial	:= ""
	Local cAfaMat		:= ""
	Local cAfaCod		:= ""
	Local cAfaPd		:= ""
	Local cAfaEsoc		:= ""
	Local cAfaCID		:= ""
	Local cMemoAux		:= ""
	Local cMemoSR8		:= ""
	Local cNumId		:= ""
	Local cMsg			:= ""
	Local cAviso		:= ""
	Local cNomMed		:= ""
	Local cCRMMed		:= ""
	Local cIdeOC		:= ""
	Local dAfaIni		:= cTod("//")
	Local dAfaFim		:= cTod("//")
	Local nDuracao		:= 0
	Local nLine			:= 0

	Local cEndEmail 	:= ''
	Local cCodMsgApr	:= ''
	Local nErro		 	:= 0

	Local cJornFilial   := ""
	Local cJornMat      := ""
	Local cJornada     	:= ""

	Local cFSubst		:= ""
	Local cMSubst		:= ""
	Local cSeq			:= ""
	Local aPerAtual		:= {}

	Local nOrd1RH4      := RetOrdem( "RH4", "RH4_FILIAL+RH4_CODIGO+STR(RH4_ITEM,3,0)" )
	Local nOrd1SQG      := RetOrdem( "SQG", "QG_FILIAL+QG_CURRIC" )
	Local nOrd1SQS      := RetOrdem( "SQS", "QS_FILIAL+QS_VAGA" )
	Local nOrd3SQG      := RetOrdem( "SQG", "QG_FILIAL+QG_CIC" )
	Local lFluig		:= .F.
	Local lOk			:= .F.
	Local lMeuRH		:= .F.
	Local lShowSRF		:= .T.
	Local lContinua		:= .F.

	Local nOpcES 	 	:= 4 // alteração
	Local nI 		 	:= 0
	Local aErro 	 	:= {}
	Local nHdl		 	:= 0
	Local cXmlRet  		:= ""
	Local aAreaTp2 		:= GetArea()
	Local aAreaSRA 		:= SRA->( GetArea() )
	Local cQry			:= ""
	Local cAliasQry		:= ""
	Local cFilFunc 		:=  ""
	Local cMatFunc		:= ""
	Local cAnexo		:= ""
	Local cChave		:= ""

	Local cBlqCV		:= SuperGetMv("MV_BLQCV",, "1")
	Local nBlqCV		:= 0

	// Utilizada na solicitação de ação salarial
	Static lAtualiza := NIL

	Private cCadastro 			:= ""
	Private cTipSolicPortal		:= ""
	Private cFilFun    			:= ""
	Private cMatFun   			:= ""
	Private cProcesso 			:= ""
	Private dFerDtIni			:= CToD("")
	Private dFerDtFim			:= CToD("")
	Private nFerDuracao			:= 0
	Private cCodSolic  			:= RH3->RH3_CODIGO
	Private aCPosPortal			:= {}
	Private bParamPortal		:= {|| .T.}
	Private lUseSPJ             := If(cPaisLoc == "BRA", .T., SuperGetMv("MV_USESPJ", NIL, "0")  == "1" )
	Private cRH3Cod				:= ''
	Private cSqsFil

	//variaveis usadas (RH3_TIPO = '2') na alteração cadastral eSocial.
	Private aCpoSRA := {}
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.

	//variaveis usadas no GPEA050
	Private lIncSRA		:= .T.
	Private lInitDesc
	Private lHabAba 	:= .F.				//Variavel para habilitar a aba de Programação de férias
	Private cOrgCfg		:= SuperGetMv("MV_ORGCFG", NIL, "0" )	//-- Controlde de Postos : 0-não usa Sigaorg;1-Tem controle de postos; 2- não tem  controle de postos
	Private cGsPubl 	:= SuperGetMv("MV_GSPUBL",,"1")
	Private cContrMat	:= SuperGetMv( "MV_MATRICU", NIL, "0")
	Private lCtrAutoMat	:= .F.					//Checa se o controle Automatico de Matricula esta ativado e se havera transferencia de matricula
	Private lTpDesl		:= lIntTAF .And. X3USADO('RE_DESL')
	Private lRfzCmp    	:= X3USADO('RFZ_DTTRA')
	Private lGera2299	:= .F.
	Private lGp050Auto  := .F.

	// variaveis usadas no GPEA180
	Private aTransf	:= {}
	Private aCpoAuxSra := {}

	Default lLote := .F.

	lMsErroAuto    := .F.

	If cGsPubl == "2" .And. GetMv("MV_VDFLOGO",,"0") <> "0"
		cGsPubl := "3"
	EndIf

	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()

	//Posiciona na SRA do candidato - necessario quando utilizada opcao Selecao Interna presente em Outras Acoes
	DbSelectArea("SRA")
	SRA->(DbSetOrder(1))
	SRA->(dbSeek(RH3->(RH3_FILIAL+RH3_MAT)))

	// Aprovacao na etapa do workflow - Gestao Publica
	// Essa etapa somente podera ser acionada caso a solicitacao esteja usando o modelo de workflow do GSP
	If cStatus == "5"
		aWorkflow := fBuscaWorkflow(RH3->RH3_FILINI, RH3->RH3_MATINI, RH3->RH3_WKFAPV, STRZERO( (val(RH3->RH3_WKFETP) + 1) , 3), .F.)

		If Len(aWorkflow) > 0
			oModRH3:SetValue("RH3_WKFETP", aWorkflow[2])
			oModRH3:SetValue("RH3_FILAPR", "")
			oModRH3:SetValue("RH3_MATAPR", "")

			DO CASE
				CASE aWorkflow[4] == "98"
					oModRH3:SetValue("RH3_STATUS", "5")
					oModRH3:SetValue("RH3_NVLAPR", 98)   //ApproverLevel - Direcionado remote (RH) - aprovacao parcial

				CASE aWorkflow[4] == "99"
					oModRH3:SetValue("RH3_STATUS", "4")
					oModRH3:SetValue("RH3_NVLAPR", 99)   //ApproverLevel - Direcionado remote (RH) - aprovacao parcial
				Otherwise
					oModRH3:SetValue("RH3_STATUS", "1")
					oModRH3:SetValue("RH3_NVLAPR", 0)    //ApproverLevel - Em processo de aprovacao
					oModRH3:SetValue("RH3_FILAPR", aWorkflow[7])
					oModRH3:SetValue("RH3_MATAPR", aWorkflow[8])
			ENDCASE

			oReturn := 0
		EndIf
	EndIf

	// Reprovacao
	If cStatus == "3"
		If oModRH3:GetValue("RH3_TIPO") $ cTpUser
			// ********************* Tipo custimizado
			If ExistBlock("TCF040GRV")
				oReturn := ExecBlock("TCF040GRV", .F., .F., {cStatus, .F., oModel})
			EndIf
		EndIf
		// Atualiza Status da Solicitacao
		oModRH3:SetValue("RH3_STATUS", cStatus)
		oModRH3:SetValue("RH3_DTATEN", dDataBase)
		oReturn := 0

		If cSolicRej == "0"
			oModRH3:SetValue("RH3_NVLAPR", oModRH3:GetValue("RH3_NVLINI"))
			oModRH3:SetValue("RH3_FILAPR", oModRH3:GetValue("RH3_FILINI"))
			oModRH3:SetValue("RH3_MATAPR", oModRH3:GetValue("RH3_MATINI"))
		Else
			aSuper:= GetSuperior(oModRH3:GetValue("RH3_FILINI"), oModRH3:GetValue("RH3_MATINI"), oModRH3:GetValue("RH3_VISAO"))

			if ValType(aSuper) == 'A' .and. len(aSuper) > 0 .and. len(aSuper[1]) >= 4
				oModRH3:SetValue("RH3_NVLAPR", aSuper[1, 4])
				oModRH3:SetValue("RH3_FILAPR", aSuper[1, 1])
				oModRH3:SetValue("RH3_MATAPR", aSuper[1, 2])
			endif
		EndIf

		If (oModRH3:GetValue("RH3_TIPO") == "H")
			// ********************* Candidato Externo
			DbSelectArea("RH4")
			RH4->(DbSetOrder(nOrd1RH4))
			RH4->(dbSeek(xFilial("RH4")+oModRH3:GetValue("RH3_CODIGO")))

			//Analisa se existe email cadastrado no Curriculo e se existe messagem de reprovacao cadastrada na vaga
			While RH4->(!Eof())

				If Alltrim(RH4->RH4_CAMPO) == "TMP_FILIAL" //Filial da vaga
					cSqsFil := SUBSTR(RH4->RH4_VALNOV, 1, FWGetTamFilial)
				EndIf

				If (Alltrim(RH4->RH4_CAMPO) == "QG_CURRIC")
					DbSelectArea("SQG")
					SQG->(DbSetOrder(nOrd1SQG))
					SQG->(dbSeek(xFilial("SQG")+RH4->RH4_VALNOV))
				ElseIf (Alltrim(RH4->RH4_CAMPO) == "TMP_VAGA")
					cSqsFil := If(cSqsFil == Nil, xFilial("SQS"), cSqsFil)
					DbSelectArea("SQS")
					SQS->(DbSetOrder(nOrd1SQS))
					SQS->(dbSeek(cSqsFil+AllTrim(RH4->RH4_VALNOV)))
				EndIf
				RH4->(dbSkip())
			EndDo

			//Questiona se deseja enviar email de reprovacao
			If !Empty(SQS->QS_MSGREP) .AND. !Empty(SQG->QG_EMAIL)
				If MsgYesNo(STR0044)//"Deseja enviar email informando a reprovação?"
					//STR0036 - "Retorno sobre Processo Seletivo"
					cMsgEmail	:= RHMSMM( Fdesc("RDG",SQS->QS_MSGREP,"RDG_CODMEM"),,,,,,,,,,,"RDG" )

					MsgRun( "Aguarde. Enviando Email...","",;	//"Aguarde. Enviando Email..."
							{||nErro := RH_Email(Lower(Alltrim(SQG->QG_EMAIL)),'',STR0036,cMsgEmail,'','')})

					If nErro != 0
						RH_ErroMail(nErro)
					EndIf

				EndIf
			EndIf
		EndIf

		If (oModRH3:GetValue("RH3_TIPO") == "2") //esocial

			DbSelectArea("RH4")
			RH4->(DbSetOrder(nOrd1RH4))
			If RH4->(dbSeek(xFilial("RH4")+oModRH3:GetValue("RH3_CODIGO")))
				While RH4->(!Eof())
					If Alltrim(RH4->RH4_CAMPO) == "RA_FILIAL"
						cFilFunc :=  SubStr( RH4->RH4_VALNOV, 1, nTamFilial)
					ElseIf Alltrim(RH4->RH4_CAMPO) == "RA_MAT"
						cMatFunc	:=  SubStr( RH4->RH4_VALNOV, 1, nTamMAT)
					ElseIf Alltrim(RH4->RH4_CAMPO) == "TMP_ANEXO"
						cAnexo	:= Alltrim(RH4->RH4_VALNOV)
					EndIf
					RH4->(dbSkip())
				EndDo
				If !Empty(cAnexo)
					DbSelectArea("ACB")
					ACB->(dbSetOrder(2))//ACB_FILIAL, ACB_OBJETO, R_E_C_N_O_, D_E_L_E_T_
					If ACB->(dbSeek(xFilial("ACB")+Upper(cAnexo)))
						cChave := ACB->ACB_CODOBJ
						RecLock("ACB",.F.)
							ACB->(dbDelete())
						ACB->(msUnlock())

						DbSelectArea("AC9")
						AC9->(dbSetOrder(1))////AC9_FILIAL, AC9_CODOBJ, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, R_E_C_N_O_, D_E_L_E_T_
						If AC9->(dbSeek(xFilial("AC9")+cChave+"SRA"+cFilFunc+cFilFunc+cMatFunc))
							RecLock("AC9",.F.)
								AC9->(dbDelete())
							AC9->(msUnlock())
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		/*
		Futuramente ser?feito um trabalho para que todas as solictações envie email, acordado com o GDP em 07/05/2014
		If (oModRH3:GetValue("RH3_TIPO") == "V")
			// ********************* Subsidio Academicoo
			//Questiona se deseja enviar email de reprovacao
			If !Empty(cCodMsgApr) .AND. !Empty(cEndEmail)
				If MsgYesNo(STR0045)   //"Deseja enviar email informando a aprovação?"
					//STR0036 - "Retorno sobre Subs&iacute;dio Acad&ecirc;mico"
					cMsgEmail	:= "<strong>Prezado Funcion&aacute;rio,</strong><br><br>"
					cMsgEmail	+= "Sua solicita&ccedil;&atilde;o de subs&iacute;dio foi reprovada, acesse o portal para maiores detalhes.<br><br>"
					cMsgEmail	+= "Atenciosamente,"
					cEndEmail	:= 'emecampos@gmail.com"
					RH_Email(Lower(Alltrim(cEndEmail)),'',"Retorno sobre Subs&iacute;dio Acad&ecirc;mico",cMsgEmail,'','')
				EndIf
			EndIf
		EndIf*/

		If (oModRH3:GetValue("RH3_TIPO") == "Z") //Marcação de Ponto via Portal
			oModRH3:LoadValue("RH3_STATUS", cStatus)
			oModRH3:LoadValue("RH3_DTATEN", dDataBase)
			DbSelectArea("RS3")
			DbSetOrder(1)
			If DbSeek(RH3->(RH3_FILIAL + RH3_CODIGO))
				RecLock("RS3",.F.)
				RS3->RS3_STATUS := "2"
				MsUnLock()
			EndIf
		EndIf
	EndIF

	cXmlRet:= FWNoAccent(cXmlRet)
	cXmlRet:= EncodeUTF8(cXmlRet)

	// Aprovacao
	If cStatus == "2"
		If oModRH3:GetValue("RH3_TIPO") $ cTpUser
			// ********************* Tipo custimizado
			If ExistBlock("TCF040GRV")
				oReturn := ExecBlock("TCF040GRV", .F., .F., {cStatus, .F., oModel})
			EndIf

		ElseIf (oModRH3:GetValue("RH3_TIPO") == "2")
			// ********************* Alteracao Cadastral

			//Busca Filial do funcionario a ser desligado
			cAliasQry := "FilRes"
			BeginSql alias cAliasQry
				SELECT RH4.RH4_VALNOV
				FROM %table:RH4% RH4
				WHERE RH4.RH4_CODIGO = %exp:cCodSolic% AND
						RH4.RH4_CAMPO = "RA_FILIAL"     AND
						RH4.%notDel%
			EndSql
			cFilFun := SubStr( (cAliasQry)->RH4_VALNOV, 1, nTamFilial)
			(cAliasQry)->( DbCloseArea() )

			//Busca Matricula do funcionario a ter os dados alterados.
			cAliasQry := "MatRes"
			BeginSql alias cAliasQry
				SELECT RH4.RH4_VALNOV
				FROM %table:RH4% RH4
				WHERE RH4.RH4_CODIGO = %exp:cCodSolic% AND
						RH4.RH4_CAMPO = "RA_MAT"     	 AND
						RH4.%notDel%
			EndSql
			cMatFun := Alltrim( (cAliasQry)->RH4_VALNOV )
			(cAliasQry)->( DbCloseArea() )

			//Busca todos os campos da RH4
			//Itens da solicitação.
			cAliasQry := "Fields"
			BeginSql alias cAliasQry
				SELECT RH4.RH4_CAMPO,RH4.RH4_VALNOV
				FROM %table:RH4% RH4
				WHERE 	RH4.RH4_FILIAL = %exp:cFilFun%  	 AND
						RH4.RH4_CODIGO = %exp:cCodSolic%	 AND
						RH4.%notDel%
			EndSql

			/***************************************
			- VERIFICA OS CAMPOS DA REQUISIÇÃO
			- E EFETUA A INSERÇÃO.
			- DADOS DA SRB MANTIDOS, PARA FUTURA
			- IMPLEMENTAÇÃO.
			****************************************/
			RecLock('SRA',.F.)
				While !(cAliasQry)->( Eof() )
					IF 	'RA_' $ (cAliasQry)->RH4_CAMPO
						IF Alltrim ((cAliasQry)->RH4_CAMPO ) $ 'RA_FILIAL' // Trata a filial.
							aAdd(aCpoSRA,{(cAliasQry)->RH4_CAMPO,Substr((cAliasQry)->RH4_VALNOV,1,FWGETTAMFILIAL),Nil})
						Elseif Alltrim ((cAliasQry)->RH4_CAMPO ) $ 'RA_MAT' // Trata a Matrícula.
							aAdd(aCpoSRA,{(cAliasQry)->RH4_CAMPO,Substr((cAliasQry)->RH4_VALNOV,1,TAMSX3((cAliasQry)->RH4_CAMPO)[1]),Nil})
						ElseIf Alltrim ( (cAliasQry)->RH4_CAMPO ) == 'RA_DEXPRIC' // Data expedição RIC
							aAdd(aCpoSRA,{(cAliasQry)->RH4_CAMPO,cToD( AllTrim( (cAliasQry)->RH4_VALNOV ) ),Nil})
						ElseIf Alltrim ( (cAliasQry)->RH4_CAMPO ) == 'RA_RNEDEXP' // Data expedição RNE
							aAdd(aCpoSRA,{(cAliasQry)->RH4_CAMPO,cToD( AllTrim( (cAliasQry)->RH4_VALNOV ) ),Nil})
						ElseIf Alltrim ( (cAliasQry)->RH4_CAMPO ) == 'RA_DATCHEG' // Data de chegada ( Estrangeiro )
							aAdd(aCpoSRA,{(cAliasQry)->RH4_CAMPO,cToD( AllTrim( (cAliasQry)->RH4_VALNOV ) ),Nil})
						ElseIf Alltrim ( (cAliasQry)->RH4_CAMPO ) == 'RA_OCDTEXP' // Expedição orgão de Classe
							aAdd(aCpoSRA,{(cAliasQry)->RH4_CAMPO,cToD( AllTrim( (cAliasQry)->RH4_VALNOV ) ),Nil})
						ElseIf Alltrim ( (cAliasQry)->RH4_CAMPO ) == 'RA_OCDTVAL' // Orgão de Classe validade
							aAdd(aCpoSRA,{(cAliasQry)->RH4_CAMPO,cToD( AllTrim( (cAliasQry)->RH4_VALNOV ) ),Nil})
						ElseIf Alltrim ( (cAliasQry)->RH4_CAMPO ) == 'RA_DTEMCNH' // Data de emissão CNH
							aAdd(aCpoSRA,{(cAliasQry)->RH4_CAMPO,cToD( AllTrim( (cAliasQry)->RH4_VALNOV ) ),Nil})
						ElseIf Alltrim ( (cAliasQry)->RH4_CAMPO ) == 'RA_DTVCCNH' // Data de vencimento CNH
							aAdd(aCpoSRA,{(cAliasQry)->RH4_CAMPO,cToD( AllTrim( (cAliasQry)->RH4_VALNOV ) ),Nil})
						Else
							aAdd(aCpoSRA,{(cAliasQry)->RH4_CAMPO,AllTrim( (cAliasQry)->RH4_VALNOV ),Nil})
						EndIF
					EndIF
					(cAliasQry)->( dbSkip() )
				EndDo

				//Adiciono o cargo no array do execauto para que o sistema não altere o cadastro do funcionário
				aAdd(aCpoSRA,{"RA_CARGO",SRA->RA_CARGO,Nil})

				/*************************
				- GRAVAÇÃO DOS DADOS
				- COM SUAS VALIDAÇÕES.
				*************************/
				MSExecAuto({|x, y, z, w| GPEA010(x, y, z, w)},,, aCpoSRA, nOpcES,)

				// CAPTURA O ERRO CASO HAJA
				If lMsErroAuto
					DisarmTransaction()
					RollBackSX8()
					aErro := GetAutoGRLog()
					lRet := .F.
					For nI := 1 To Len(aErro) // Capturar o Erro
						cXMLRet += StrTran( StrTran( StrTran( StrTran( StrTran( aErro[nI], CHR(10), "" ), CHR(13), "" ), "/", "" ), "<", "" ), ">", "" ) + "|"
					Next nI
					nHdl := FCreate("TCFA040.txt", 0) // StartPath (SYSTEM).
					FWrite(nHdl,cXMLRet,Len(cXMLRet)) // Efetua a gravação do Buffer.
					FClose(nHdl) // Finaliza.
					lRet := .F.
				Else
					oReturn := 0
				EndIF

			MsUnlock()	 // Destrava o registro SRA ( FUNCIONÁRIOS )
			(cAliasQry)->( DbCloseArea() ) // Fecha o alias tmp da query.

			RestArea( aAreaTp2 ) //Area Ativa.
			RestArea( aAreaSRA ) //Area Funcionários.

			If (oReturn == 0 .AND. (lMsErroAuto == .F.) )  //0 - CONFIRMOU A ROTINA   |  1 - FECHOU A ROTINA
				oModRH3:SetValue("RH3_STATUS", cStatus)
				oModRH3:SetValue("RH3_DTATEN", dDataBase)
			Else
				// CASO ALGUMA PROPIEDADE ENVIADA, NÃO SEJA VALIDADA PELA EXECAUTO.
				//"Há inconsistência nos dados enviados!"###"Não foi possível efetuar a aprovação - arquivo de log gerado (TCFA040.txt)."
				MsgInfo( OemToAnsi(STR0168 + chr(10) + chr(13) + STR0169))
				oReturn := Nil
			EndIf

		ElseIf (oModRH3:GetValue("RH3_TIPO") == "3")
			// ********************* Solicitacao de Postos;

			If MsgYesNo(STR0021, STR0014) //Deseja complementar as informacoes vindas do portal?
				RegToMemory("RBT", .T., .F. )

				cCadastro := STR0022 //Complemento da solicitacao
				Private aAcho  	  := GetRBTFields(.T.)
				Private aAlter 	  := {}

				// Inicializa
				M->RBT_JUSTIF	  := "02"
				M->RBT_TIPOR	  := "2"
				M->RBT_STATUS	  := "1"

				// Verifica quais campos foram informados na solicitacao
				// de desligamento, inicializa memoria e bloqueia para edicao
				cAliasQry := "QRH4"
				For nx := 1 to Len(aAcho)

					BeginSQL Alias cAliasQry
						SELECT RH4.RH4_CAMPO, RH4.RH4_VALNOV
						FROM %table:RH4% RH4
						WHERE RH4.RH4_FILIAL = %exp:RH3->RH3_FILIAL% AND
						RH4.RH4_CODIGO = %exp:RH3->RH3_CODIGO% AND
						RH4.RH4_CAMPO  = %exp:aAcho[nx]% AND
						RH4.%notDel%
					EndSQL

					If (cAliasQry)->(eof())
						If aAcho[nx] == "RBT_DTAMOV"
							M->RBT_DTAMOV := RH3->RH3_DTSOLI
						Elseif aAcho[nx] == "RBT_CODMOV"
							M->RBT_CODMOV := GetSx8Num("RBT", "RBT_CODMOV")
						Else
							AAdd(aAlter, aAcho[nx])
						Endif
					Else
						Do Case
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RBT_CC"
							M->RBT_CC				  		 := (cAliasQry)->RH4_VALNOV
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RBT_DEPTO"
							M->RBT_DEPTO	 		  		 := (cAliasQry)->RH4_VALNOV
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RBT_FUNCAO"
							M->RBT_FUNCAO			    	 := (cAliasQry)->RH4_VALNOV
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RBT_CARGO"
							M->RBT_CARGO			   		 := (cAliasQry)->RH4_VALNOV
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RBT_REMUNE"
							M->RBT_REMUNE		    		 := val((cAliasQry)->RH4_VALNOV)
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RBT_TPOSTO"
							M->RBT_TPOSTO		   			 := (cAliasQry)->RH4_VALNOV
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RBT_TPCONT"
							M->RBT_TPCONT		   		     := (cAliasQry)->RH4_VALNOV
						Case (cAliasQry)->RH4_CAMPO == "RBT_QTDMOV"
							M->RBT_QTDMOV		   		 	 := val((cAliasQry)->RH4_VALNOV)
						Case (cAliasQry)->RH4_CAMPO == "RBT_CODPOS"
							M->RBT_CODPOS                  := (cAliasQry)->RH4_VALNOV
						EndCase
					Endif
					(cAliasQry)->( DbCloseArea() )
				Next nx

				If AxInclui040("RBT", 1, 3, aAcho, NIL, aAlter, "GA1040TudOk()",,,,) == 1

					// Atualizando RBX - Registro de movimentacao do departamento
					dbSelectArea("RBX")
					RecLock("RBX",.T.)
					RBX->RBX_FILIAL	:=	xFilial("RBX")
					RBX->RBX_DEPTO 	:=	RBT->RBT_DEPTO
					RBX->RBX_CODMOV :=	RBT->RBT_CODMOV
					RBX->RBX_DTAMOV :=	RBT->RBT_DTAMOV
					RBX->RBX_CODOPE :=	"1"
					RBX->RBX_TPOSTO :=	RBT->RBT_TPOSTO
					RBX->RBX_QTDOPE	:=	RBT->RBT_QTDMOV
					RBX->RBX_RESOPE	:=	cUsername
					RBX->RBX_JUSTIF :=  "01"
					MsUnLock()
				Endif
			else
			// Atualiza RBT
			// Busca RH4
				cAliasQry := "QRH4"
				BeginSQL Alias cAliasQry
					SELECT RH4.RH4_CAMPO, RH4.RH4_VALNOV
					FROM %table:RH4% RH4
					WHERE RH4.RH4_FILIAL = %exp:RH3->RH3_FILIAL% AND
					RH4.RH4_CODIGO = %exp:RH3->RH3_CODIGO% AND
					RH4.%notDel%
				EndSQL

				Begin Transaction
					RecLock("RBT", .T.)
					RBT->RBT_FILIAL					:= xFilial("RBT")
					RBT->RBT_CODMOV					:= GetSx8Num("RBT", "RBT_CODMOV")
					RBT->RBT_DTAMOV					:= dDataBase

					Dbselectarea(cAliasQry)
					While !(cAliasQry)->(eof())

						Do Case
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RBT_CC"
							RBT->RBT_CC			  			 := (cAliasQry)->RH4_VALNOV
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RBT_DEPTO"
							RBT->RBT_DEPTO 		  			 := (cAliasQry)->RH4_VALNOV
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RBT_FUNCAO"
							RBT->RBT_FUNCAO		    		 := (cAliasQry)->RH4_VALNOV
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RBT_CARGO"
							RBT->RBT_CARGO		   			 := (cAliasQry)->RH4_VALNOV
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RBT_REMUNE"
							RBT->RBT_REMUNE		    		 := val((cAliasQry)->RH4_VALNOV)
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RBT_TPOSTO"
							RBT->RBT_TPOSTO		   			 := (cAliasQry)->RH4_VALNOV
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RBT_TPCONT"
							RBT->RBT_TPCONT		   			 := (cAliasQry)->RH4_VALNOV
						Case (cAliasQry)->RH4_CAMPO == "RBT_QTDMOV"
							RBT->RBT_QTDMOV		   			 := val((cAliasQry)->RH4_VALNOV)
						Case (cAliasQry)->RH4_CAMPO == "RBT_CODPOS"
							RBT->RBT_CODPOS                    := (cAliasQry)->RH4_VALNOV
						EndCase

						(cAliasQry)->(dbskip())
					Enddo

					RBT->RBT_JUSTIF					:= "02"
					RBT->RBT_TIPOR					:= "2"
					RBT->RBT_STATUS					:= "1"

					MsUnLock()
				End Transaction
				(cAliasQry)->( DbCloseArea() )

				// Atualizando RBX - Registro de movimentacao do departamento
				dbSelectArea("RBX")
				RecLock("RBX",.T.)
				RBX->RBX_FILIAL	:=	xFilial("RBX")
				RBX->RBX_DEPTO 	:=	RBT->RBT_DEPTO
				RBX->RBX_CODMOV :=	RBT->RBT_CODMOV
				RBX->RBX_DTAMOV :=	RBT->RBT_DTAMOV
				RBX->RBX_CODOPE :=	"1"
				RBX->RBX_TPOSTO :=	RBT->RBT_TPOSTO
				RBX->RBX_QTDOPE	:=	RBT->RBT_QTDMOV
				RBX->RBX_RESOPE	:=	cUsername
				RBX->RBX_JUSTIF :=  "01"
				MsUnLock()
			Endif
			//Valida tipo de posto se a solicitacao for de atualizacao de posto que ja existe
			If !Empty(RBT->RBT_CODPOS) .And. AllTrim(RBT->RBT_CODPOS) != STR0057//"Novo"
				If !( ValidTipPos( RBT->RBT_FILIAL, RBT->RBT_CODPOS ) )
					Return .F.
				EndIf
			EndIf
			// Atualiza Status da Solicitacao
			oModRH3:SetValue("RH3_STATUS", cStatus)
			oModRH3:SetValue("RH3_DTATEN", dDataBase)
			oReturn := 0
			//Efetua gravacao de postos/historico
			OrgXAprova( RBT->RBT_FILIAL, RBT->RBT_CODMOV, RBX->RBX_CODOPE, RBX->RBX_QTDOPE, RBX->RBX_JUSTIF, .F., .T., RBT->RBT_DEPTO )
		ElseIf (oModRH3:GetValue("RH3_TIPO") == "4")
			// **************************** Transferencia;
			Private cCodTrasfPortal := RH3->RH3_CODIGO

			//-- Variaveis utilizadas pelo GPEA180
			Private cItemClVl       := SuperGetMv( "MV_ITMCLVL", .F., "2" )
			Private lItemClVl       := SuperGetMv( "MV_ITMCLVL", .F., "2" ) $ "13"
			Private aLogTransf		:= {}
			Private aTransfCols 	:= {}
			Private aTransf1Cols    := {}

			Private aNewIndexSRA  	:= {}
			Private bNewFiltroBrw 	:= {|| NIL }
			Private cMarkTransf		:= GetMark()
			Private cRaOkTransSpc	:= Space( TamSx3( "RA_OKTRANS" )[1] )
			Private lAbortPrint		:= .F.
			Private cObsTcfa040		:= ""
			Private _CITEM
			Private _CCLVL
			Private aTpAlt			:= {.F.,.F.,.F.}
			Private lGeraDem		:= .F.
			Private cCPFDe			:= ""
			Private cCPFAte			:= ""
			Private dDataTAF		:= CTOD("//")
			Private lRobo			:= .F.

			cCadastro               := OemToAnsi( STR0023 )  //"Transferencias"
			cTipSolicPortal         := "4"

			DbSelectArea( "SRA" )
			DbSetOrder( RetOrder( "SRA", "RA_FILIAL + RA_MAT") )

			lOk := .F.
			If SRA->(DbSeek(RH3->RH3_FILIAL + RH3->RH3_MAT))
				CursorWait()

				RH4->(DbSeek(RH3->(RH3_FILIAL + RH3_CODIGO)))

				// Inicializa as variaveis com o destino do funcionário
				M->RE_EMPP 		:= ""
				M->RE_FILIALP 	:= ""
				M->RE_MATP 		:= ""
				M->RE_DEPTOP 	:= ""
				M->RE_PROCESS 	:= ""

				While RH4->(RH4_FILIAL + RH4_CODIGO) == RH3->(RH3_FILIAL + RH3_CODIGO) .And. ! RH4->(Eof())
					If AllTrim(RH4->RH4_CAMPO) == "RE_EMPP"
						M->RE_EMPP := Left(RH4->RH4_VALNOV, Len(SRE->RE_EMPP))
					ElseIf AllTrim(RH4->RH4_CAMPO) == "RE_FILIALP"
						M->RE_FILIALP := Left(RH4->RH4_VALNOV, Len(SRA->RA_FILIAL))
					ElseIf AllTrim(RH4->RH4_CAMPO) == "RE_MATP"
						M->RE_MATP := Left(RH4->RH4_VALNOV, Len(SRE->RE_MATP))
					ElseIf AllTrim(RH4->RH4_CAMPO) == "RE_DEPTOP"
						M->RE_DEPTOP := Left(RH4->RH4_VALNOV, Len(SRE->RE_DEPTOP))
					ElseIf AllTrim(RH4->RH4_CAMPO) == "RE_CCP"
						M->RE_CCP := Left(RH4->RH4_VALNOV, Len(SRE->RE_CCP))
					ElseIf AllTrim(RH4->RH4_CAMPO) == "RE_PROCESS"
						M->RE_PROCESS := Left(RH4->RH4_VALNOV, Len(SRE->RE_PROCESP))
					ElseIf AllTrim(RH4->RH4_CAMPO) == "RE_POSTOP"
						M->RE_POSTOP := Left(RH4->RH4_VALNOV, Len(SRE->RE_POSTOP))
					ElseIf AllTrim(RH4->RH4_CAMPO) == "TMP_TPALT"
						aAdd(aCpoAuxSRA,{ AllTrim(RH4->RH4_CAMPO), Left(RH4->RH4_VALNOV, 3) } )
					ElseIf AllTrim(RH4->RH4_CAMPO) == "TMP_FUNCAO"
						aAdd(aCpoAuxSRA,{ AllTrim(RH4->RH4_CAMPO), Left(RH4->RH4_VALNOV, Len(SRA->RA_CODFUNC)) } )
					EndIf

					RH4->(DbSkip())
				EndDo
				If Empty(M->RE_EMPP)
					If RH3->(ColumnPos("RH3_EMP")) > 0
						M->RE_EMPP := RH3->RH3_EMP
					Else
						M->RE_EMPP := cEmpAnt
					EndIf
				EndIf

				If Empty(M->RE_FILIALP)
					M->RE_FILIALP := RH3->RH3_FILIAL
				EndIf

				cQry := GetNextAlias()
				BeginSQL Alias cQry
					SELECT RGK.*
					FROM %table:RGK% RGK
					WHERE RGK.RGK_CODIGO = %exp:RH3->RH3_CODIGO% AND
					RGK.RGK_SEQUEN = '000001' AND
					RGK.%notDel%
					ORDER BY RGK.RGK_CODIGO,RGK.RGK_SEQUEN
				EndSQL

				While !(cQry)->(Eof())

					If !Empty((cQry)->RGK_CODCON)	 .AND. !Empty((cQry)->RGK_CODCON)
						cAliasQry	:= GetNextAlias()
						cFilRDY := "%'" + xFilial( 'RDY', (cQry)->RGK_FILAPR ) + "'%"
						BeginSQL Alias cAliasQry
							SELECT RDY.RDY_TEXTO
							FROM %table:RDY% RDY
							WHERE RDY.RDY_FILIAL = %exp:cFilRDY% 	AND
							RDY.RDY_CHAVE = %exp:(cQry)->RGK_CODCON% AND
							RDY.%notDel%
						EndSQL

						While !(cAliasQry)->(Eof())
							cObsTcfa040   += (cAliasQry)->RDY_TEXTO
							(cAliasQry)->(dbSkip())
						EndDo
						(cAliasQry)->(dbCloseArea())

					EndIf

					(cQry)->(dbSkip())
				EndDo
				(cQry)->(dbCloseArea())

				SetFunName("GPEA180")
				If GPEA180MAT("RH3",0,4, ,If(Len(aCpoAuxSRA)>0,aCpoAuxSRA,)) == 1 .And. fTransf(@aTransf,,,,,,,.T.)
					oModRH3:SetValue("RH3_STATUS", cStatus)
					oModRH3:SetValue("RH3_DTATEN", dDataBase)
					oReturn := 0
					aCpoAuxSRA := {}
					lOk := .T.
				EndIf
				SetFunName("TCFA040")
				CursorArrow()
			EndIf

			If !lOk
				If !lLote
					MsgInfo(STR0024, STR0013) //Transferencia nao localizada
				Else
					aAdd(aLog, STR0024)
				EndIf
				oReturn := Nil
				Return .F.
			EndIF

		ElseIf (oModRH3:GetValue("RH3_TIPO") == "5")
			// **************************** Admissao (Novas Contratacoes/Substituicoes/Vagas Internas);
			oModRH3:SetValue("RH3_STATUS", cStatus)
			oModRH3:SetValue("RH3_DTATEN", dDataBase)
			oReturn := 0

		ElseIf (oModRH3:GetValue("RH3_TIPO") == "6")
			// **************************** Desligamento
			Private cTipResPortal 	:= ""

			//Busca informações do funcionario a ser desligado
			cAliasQry := "FilRes"
			BeginSQL Alias cAliasQry
				SELECT RH4.RH4_VALNOV, RH4.RH4_CAMPO
				FROM %table:RH4% RH4
				WHERE RH4.RH4_CODIGO = %exp:cCodSolic% AND
				RH4.RH4_CAMPO IN ('RA_FILIAL', 'RA_MAT', 'RX_COD') AND
				RH4.%notDel%
			EndSQL

			While (cAliasQry)->(!EoF())

				If AllTrim((cAliasQry)->RH4_CAMPO) == 'RA_FILIAL'
					cFilFun := SubStr( (cAliasQry)->RH4_VALNOV, 1, nTamFilial)
				ElseIf AllTrim((cAliasQry)->RH4_CAMPO) == 'RA_MAT'
					cMatFun := (cAliasQry)->RH4_VALNOV
				ElseIf AllTrim((cAliasQry)->RH4_CAMPO) == 'RX_COD'
					cTipResPortal := SubStr((cAliasQry)->RH4_VALNOV, 1, 2 )
				EndIf

				(cAliasQry)->(dbSkip())
			EndDo

			(cAliasQry)->( DbCloseArea() )

			GPEM040()

			IF Select("SRG") > 0
				SRG->(dbCloseArea())
			Endif

			dbSelectArea("SRG")
			If SRG->(MsSeek(( cFilFun + RTrim(cMatFun))))
				oModRH3:SetValue("RH3_STATUS", cStatus)
				oModRH3:SetValue("RH3_DTATEN", dDataBase)
				oReturn := 0
			Else
				If !lLote
					MsgInfo(STR0020, STR0013) //Rescisao nao calculada
				Else
					aAdd(aLog, STR0020)
				EndIf
			EndIf
			SRG->(dbCloseArea())

		ElseIf (oModRH3:GetValue("RH3_TIPO") == "7")
			// **************************** Acao Salarial
			//Busca Filial do funcionario a ser desligado

			cAliasQry := "FilAct"
			BeginSQL Alias cAliasQry
				SELECT RH4.RH4_VALNOV
				FROM %table:RH4% RH4
				WHERE RH4.RH4_CODIGO = %exp:cCodSolic% AND
				RH4.RH4_CAMPO  = "RB7_FILIAL"    AND
				RH4.%notDel%
			EndSQL
			If !(cAliasQry)->(eof())
				cFilFun := SubStr( (cAliasQry)->RH4_VALNOV, 1, nTamFilial)
			EndIF
			(cAliasQry)->( DbCloseArea() )

			//Busca Matricula do funcionario a ser desligado
			cAliasQry := "MatAct"
			BeginSQL Alias cAliasQry
				SELECT RH4.RH4_VALNOV
				FROM %table:RH4% RH4
				WHERE RH4.RH4_CODIGO = %exp:cCodSolic% AND
				RH4.RH4_CAMPO  = "RB7_MAT"      AND
				RH4.%notDel%
			EndSQL
			If !(cAliasQry)->(eof())
				cMatFun := (cAliasQry)->RH4_VALNOV
			EndIF
			(cAliasQry)->( DbCloseArea() )

			If cMatFun != ""
				//Seleciona SRA
				If Select("SRA") > 0
					SRA->(dbCloseArea())
				Endif
				dbSelectArea("SRA")
				If SRA->( MsSeek( ( cFilFun + rtrim(cMatFun) ) ) )

					//Busca RH4 e Inicializa variaveis locais
					cAliasQry := "QRYRH4"
					BeginSQL Alias cAliasQry
						SELECT RH4.RH4_CAMPO, RH4.RH4_VALNOV
						FROM %table:RH4% RH4
						WHERE RH4.RH4_FILIAL = %exp:RH3->RH3_FILIAL% AND
						RH4.RH4_CODIGO = %exp:RH3->RH3_CODIGO% AND
						RH4.%notDel%
					EndSQL

					Begin Transaction
						Dbselectarea(cAliasQry)
						While !(cAliasQry)->(eof())

							Do Case
							Case alltrim((cAliasQry)->RH4_CAMPO) == "RB7_TPALT"
								cTpALT				  			 := (cAliasQry)->RH4_VALNOV
							Case alltrim((cAliasQry)->RH4_CAMPO) == "RB7_FUNCAO"
								cFuncao				  			 := (cAliasQry)->RH4_VALNOV
							Case alltrim((cAliasQry)->RH4_CAMPO) == "RB7_CARGO"
								cCargo				    		 := (cAliasQry)->RH4_VALNOV
							Case alltrim((cAliasQry)->RH4_CAMPO) == "RB7_SALARI"
								nSalario			    		 := val((cAliasQry)->RH4_VALNOV)
							Case alltrim((cAliasQry)->RH4_CAMPO) == "RB7_CATEG"
								cCateg				   			 := (cAliasQry)->RH4_VALNOV
							EndCase

							(cAliasQry)->(dbskip())
						EndDo
					End Transaction
					(cAliasQry)->( DbCloseArea() )

					If Empty(lAtualiza) .Or. !lLote
						lAtualiza	:= MsgYesNo("Deseja atualizar o campo do salário base do dissídio?", STR0007) //Atencao!##Atencao!
					EndIf

					//Atualiza SR3 e SR7
					//Inicializa M->SRA com possiveis alteracoes dos campos
					//pedidos na solicitacao de acao salarial
					RegToMemory("SRA", .F., .F. )
					M->RA_TIPOALT 		:= cTpALT
					M->RA_DATAALT 		:= dDataBase
					if cCargo != ""
						M->RA_CARGO   	:= cCargo
					Endif
					if cFuncao != ""
						M->RA_CODFUNC  	:= cFuncao
					Endif
					if nSalario != 0
						M->RA_SALARIO 	:= nSalario
					Endif
					If nSalario != 0 .And. lAtualiza
						M->RA_ANTEAUM 	:= nSalario
					EndIf
					if cCateg != ""
						M->RA_CATFUNC 	:= cCateg
					Endif

					fGravaSr3( dDataBase, cTpALT, nSalario )

					//Atualiza SRA
					RecLock("SRA", .F.)
					if cCargo != ""
						SRA->RA_CARGO	 := cCargo
					Endif
					if cFuncao != ""
						SRA->RA_CODFUNC	 := cFuncao
					Endif
					if nSalario != 0
						SRA->RA_SALARIO	 := nSalario
					Endif
					If nSalario != 0 .And. lAtualiza
						SRA->RA_ANTEAUM  := nSalario
					EndIf
					if cCateg != ""
						SRA->RA_CATFUNC	 := cCateg
					Endif
					MsUnLock()

					//Atualiza RH3
					oModRH3:SetValue("RH3_STATUS", cStatus)
					oModRH3:SetValue("RH3_DTATEN", dDataBase)
					oReturn := 0
				Else
					If !lLote
						MsgInfo(STR0025, STR0013) //Acao salarial nao executada
					Else
						aAdd(aLog, STR0025)
					EndIf
				EndIf
				SRA->(dbCloseArea())

			Else
				If !lLote
					MsgInfo(STR0025, STR0013) //Acao salarial nao executada
				Else
					aAdd(aLog, STR0025)
				EndIf
			EndIf

		ElseIf (oModRH3:GetValue("RH3_TIPO") == "8")
			// **************************** Justificativa de Horario
			// Busca RH4
			cAliasQry := "JUSTIFHOR"
			BeginSQL Alias cAliasQry
				SELECT RH4.RH4_CAMPO, RH4.RH4_VALNOV
				FROM %table:RH4% RH4
				WHERE RH4.RH4_FILIAL = %exp:RH3->RH3_FILIAL% AND
				RH4.RH4_CODIGO = %exp:RH3->RH3_CODIGO% AND
				RH4.%notDel%
			EndSQL

			//Verifica se ha um pre-abono cadastrado com todas informacoes iguais
			Dbselectarea(cAliasQry)
			While !(cAliasQry)->(eof())
				Do Case
				Case Alltrim((cAliasQry)->RH4_CAMPO) == "RF0_MAT"
					cMat := AllTrim( (cAliasQry)->RH4_VALNOV )
				Case Alltrim((cAliasQry)->RH4_CAMPO) == "RF0_DTPREI"
					dDtPreI	:= dToS( cToD( AllTrim( (cAliasQry)->RH4_VALNOV ) ) )
				Case Alltrim((cAliasQry)->RH4_CAMPO) == "RF0_HORINI"
					nHorIni := Str( Val( AllTrim( (cAliasQry)->RH4_VALNOV ) ), 5, 2 )
				Case Alltrim((cAliasQry)->RH4_CAMPO) == "RF0_DTPREF"
					dDtPreF := dToS( cToD( AllTrim( (cAliasQry)->RH4_VALNOV ) ) )
				Case Alltrim((cAliasQry)->RH4_CAMPO) == "RF0_HORFIM"
					nHorFim := Str( Val( AllTrim( (cAliasQry)->RH4_VALNOV ) ), 5, 2 )
				Case Alltrim((cAliasQry)->RH4_CAMPO) == "RF0_CODABO"
					cCodAbo := AllTrim( (cAliasQry)->RH4_VALNOV )
				Case Alltrim((cAliasQry)->RH4_CAMPO) == "RF0_FILIAL"
					cFilRF0 := SubStr( (cAliasQry)->RH4_VALNOV, 1, nTamFilial)
				EndCase

				(cAliasQry)->(dbskip())
			EndDo

			cAliasRF0Qry := "QRF0"
			BeginSQL Alias cAliasRF0Qry
				SELECT COUNT(*) as nRegs
				FROM %table:RF0% RF0
				WHERE RF0.RF0_FILIAL  = %exp:cFilRF0% AND
				RF0.RF0_MAT    = %exp:cMat%    AND
				RF0.RF0_DTPREI = %exp:dDtPreI% AND
				RF0.RF0_HORINI = %exp:nHorIni% AND
				RF0.RF0_DTPREF = %exp:dDtPreF% AND
				RF0.RF0_HORFIM = %exp:nHorFim% AND
				RF0.RF0_CODABO = %exp:cCodAbo% AND
				RF0.%notDel%
			EndSQL

			// Atualiza RF0
			If (cAliasRF0Qry)->nRegs == 0
				Begin Transaction
					RecLock("RF0", .T.)
					RF0->RF0_FILIAL	:= cFilRF0
					RF0->RF0_MAT	:= cMat
					RF0->RF0_DTPREI	:= sToD(dDtPreI)
					RF0->RF0_HORINI	:= Val(nHorIni)
					RF0->RF0_DTPREF	:= sToD(dDtPreF)
					RF0->RF0_HORFIM	:= Val(nHorFim)
					RF0->RF0_CODABO	:= cCodAbo
					RF0->RF0_HORTAB	:= "N"
					RF0->RF0_ABONA 	:= "N"
					RF0->RF0_USUAR 	:= UsrRetName(RetCodUsr())
					RF0->RF0_FLAG  	:= "I"

					MsUnLock()
				End Transaction
			EndIf
			(cAliasQry)->( DbCloseArea() )
			(cAliasRF0Qry)->( DbCloseArea() )

			oModRH3:SetValue("RH3_STATUS", cStatus)
			oModRH3:SetValue("RH3_DTATEN", dDataBase)
			oReturn := 0

		ElseIf (oModRH3:GetValue("RH3_TIPO") == "A")
			// **************************** Treinamento
			//Busca Dados da Reserva
			cAliasQry := "MATTrm"
			BeginSql alias cAliasQry
				SELECT *
				FROM %table:RH4% RH4
				WHERE 	RH4.RH4_CODIGO = %exp:cCodSolic% AND
						RH4.%notDel%
			EndSql

			Dbselectarea(cAliasQry)
			While !(cAliasQry)->(eof())
				Do Case
				Case alltrim((cAliasQry)->RH4_CAMPO) == "RA3_FILIAL"
					cTrmFilial				  		:= SubStr( (cAliasQry)->RH4_VALNOV, 1, nTamFilial)
				Case alltrim((cAliasQry)->RH4_CAMPO) == "RA3_MAT"
					cTrmMat					  		:= (cAliasQry)->RH4_VALNOV
				Case alltrim((cAliasQry)->RH4_CAMPO) == "RA3_CALEND"
					cTrmCalend			    		:= (cAliasQry)->RH4_VALNOV
				Case alltrim((cAliasQry)->RH4_CAMPO) == "RA3_CURSO"
					cTrmCurso			  			 	:= (cAliasQry)->RH4_VALNOV
				Case alltrim((cAliasQry)->RH4_CAMPO) == "RA3_TURMA"
					cTrmTurma			    		 	:= (cAliasQry)->RH4_VALNOV
				Case alltrim((cAliasQry)->RH4_CAMPO) == "RA3_PORTAL"
					cTrmPortal			    		 	:= (cAliasQry)->RH4_VALNOV

				EndCase

				(cAliasQry)->(dbskip())
			Enddo
			(cAliasQry)->( DbCloseArea() )

			//Verifica disponibilidade de vagas
			cAliasQry := "RA2Trm"
			BeginSQL Alias cAliasQry
				SELECT *
				FROM %table:RA2% RA2
				WHERE RA2.RA2_CALEND = %exp:cTrmCalend% AND
				RA2.RA2_CURSO  = %exp:cTrmCurso%  AND
				RA2.RA2_TURMA  = %exp:cTrmTurma%  AND
				RA2.%notDel%
			EndSql

			If !(cAliasQry)->(eof())
				If !((cAliasQry)->RA2_VAGAS > (cAliasQry)->RA2_RESERV)
					(cAliasQry)->( DbCloseArea() )

					If !lLote
						MsgAlert(STR0026 , STR0007) //"Nao existem mais vagas disponiveis para esse treinamento!"
					Else
						aAdd(aLog, STR0026)
					EndIf

					oReturn := Nil
					Return .F.
				EndIf
			Else
				(cAliasQry)->( DbCloseArea() )

				If !lLote
					MsgAlert(STR0027 , STR0007) //"Treinamento da solicitacao nao localizado!"
				Else
					aAdd(aLog, STR0027)
				EndIf

				oReturn := Nil
				Return .F.
			EndIf
			(cAliasQry)->( DbCloseArea() )

			// Atualiza treinamento RA3
			dbSelectArea("RA3")
			RecLock("RA3", .T.)
				RA3->RA3_FILIAL	:= xFilial("RA3", cTrmFilial)
				RA3->RA3_MAT		:= cTrmMat
				RA3->RA3_CALEND	:= cTrmCalend
				RA3->RA3_CURSO	:= cTrmCurso
				RA3->RA3_TURMA	:= cTrmTurma
				RA3->RA3_DATA		:= dDataBase
				RA3->RA3_RESERV := "S"
				//utilizado ColumnPos pois ?um requisito da 12.1.10 compatibilizada para 12.1.6 para a PRODAM
				If ColumnPos("RA3_PORTAL") > 0
					RA3->RA3_PORTAL := cTrmPortal
				EndIf
			MsUnlock()

			// Atualiza reservas calendario RA2
			dbSelectArea("RA2")
			DbSetOrder(1)
			IF RA2->( MsSeek( ( xFilial("RA2", cTrmFilial) + rtrim(cTrmCalend) + rtrim(cTrmCurso) + rtrim(cTrmTurma) ) ) )
				RecLock("RA2", .F.)
					RA2->RA2_RESERV := (RA2->RA2_RESERV + 1)
				MsUnlock()
			Endif

			//Atualiza status solicitacao
			oModRH3:SetValue("RH3_STATUS", cStatus)
			oModRH3:SetValue("RH3_DTATEN", dDataBase)
			oReturn := 0

		//PROGRAMACAO DE FÉRIAS - GESTAO PUBLICA
		ElseIf (oModRH3:GetValue("RH3_TIPO") == "P")

			//DECLARA AS VARIAVEIS DESSE ITEM
			cFil	    := ""
			cMat	    := ""
			cPD			:= ""
			dDtBIni    := STOD("")
			dDtBFim	:= STOD("")
			nDiasPer1	:= 0
			dPerIni1	:= STOD("")
			dPerFim1	:= STOD("")
			cFilSub1	:= ""
			cMatSub1	:= ""
			dAbono		:= 0
			dOport		:= 0
			nDiasPer2	:= 0
			dPerIni2	:= STOD("")
			dPerFim2	:= STOD("")
			cFilSub2	:= ""
			cMatSub2	:= ""
			cTipSolicPortal := "P"

			//TEM QUE DECLARAR ESSAS VARIAVEIS, POIS ELAS ESTAO NA CHAMADA PRINCIPAL DA ROTINA GPEA051
			Private aSRF040 	 := {}
			Private aRIA040 	 := {}
			Private lSuspensao := .F.
			Private lCancela    := .F.
			Private lRetifica   := .F.
			Private LCANCSRF    := .F.
			Private LTCFA040     := .T.

			Private cGsPubl      := GetMv( "MV_GSPUBL",,"1")
			Private nGSPopc      := 0
			Private bFiltraBrw   := {|| Nil}		//Variavel para Filtro
			Private lHabAba      := .F.				//Variavel para habilitar a aba de Programação de férias

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//³O parametro MV_GSPUBL = "2" identifica que eh GSP-Caixa. Se existir o ?
			//³parametro MV_VDFLOGO eh porque eh GSP-MP (novo modelo de GSP).        ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			If cGsPubl == "2" .And. GetMv("MV_VDFLOGO",,"0") <> "0"
				cGsPubl := "3"
			EndIf

			//Busca Dados da solicitacao de ferias
			cAliasQry := "PerFer"
			BeginSQL Alias cAliasQry
				SELECT * FROM %table:RH4% RH4 WHERE RH4.RH4_CODIGO = %exp:cCodSolic% AND RH4.%notDel%
			EndSQL

			Dbselectarea(cAliasQry)
			While !(cAliasQry)->(eof())
				Do Case

					//CABEÇALHO - SRF
					Case alltrim((cAliasQry)->RH4_CAMPO) == "RA_FILIAL"
						cFil	    := SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RA_FILIAL')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "RA_MAT"
						cMat	    := SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RA_MAT')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_PD"
						cPD			:= SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RV_COD')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DTBINI"
						dDtBIni    	:= CtoD((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DTBFIM"
						dDtBFim		:= CtoD((cAliasQry)->RH4_VALNOV)

					//LINHA 1 DA RIA
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DPER1"
						nDiasPer1	:= Val((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DTINI1"
						dPerIni1	:= CtoD((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DTFIM1"
						dPerFim1		:= CtoD((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_FSUB1"
						cFilSub1		:= SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RIA_FILIAL')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_MSUB1"
						cMatSub1		:= SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RIA_MAT')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DABONO"
						dAbono		:= VAL((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DOPORT"
						dOport		:= VAL((cAliasQry)->RH4_VALNOV)

					//LINHA 2 DA RIA
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DPER2"
						nDiasPer2	:= Val((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DTINI2"
						dPerIni2	:= CtoD((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DTFIM2"
						dPerFim2		:= CtoD((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_FSUB2"
						cFilSub2		:= SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RIA_FILIAL')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_MSUB2"
						cMatSub2		:= SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RIA_MAT')[1])

				EndCase
				(cAliasQry)->(dbskip())
			EndDo
			(cAliasQry)->( DbCloseArea() )

			dbSelectArea("SRA")
			dbSetOrder(1)
			dbSeek(cFil+cMat)
			Aadd(aSRF040,{cFil,cMat,cPd,dDtBIni,dDtBFim,SRA->RA_PROCES,cCodSolic})
			Aadd(aRIA040,{nDiasPer1,dPerIni1,dPerFim1,cFilSub1,cMatSub1,dAbono,dOport})
			If !empty(dPerIni2)
				Aadd(aRIA040,{nDiasPer2,dPerIni2,dPerFim2,cFilSub2,cMatSub2,0     ,0     })
			EndIf

			SETFUNNAME("GPEA051")

			oReturn := FWExecView(,'GPEA051', MODEL_OPERATION_UPDATE, , { || .T. } )  //CHAMA A TELA DE PROGRAMAÇÃO

			SETFUNNAME("TCFA040")
			dbSelectArea("SRA")  //REPOSICIONA O FUNCIONARIO

			If (oReturn == 0)  //0 - CONFIRMOU A ROTINA   |  1 - FECHOU A ROTINA
				oModRH3:SetValue("RH3_STATUS", cStatus)
				oModRH3:SetValue("RH3_DTATEN", dDataBase)
			Else
				oReturn := Nil
			EndIf

		//SALDO DE FÉRIAS - GESTAO PUBLICA
		ElseIf (oModRH3:GetValue("RH3_TIPO") == "O")

			//DECLARA AS VARIAVEIS DESSE ITEM
			cFil             := ""
			cMat             := ""
			cPD              := ""
			nSeq             := 0
			nRegID           := 0
			dDtINPA          := STOD("")
			dDtIni           := STOD("")
			dDtFim           := STOD("")
			cTipSolicPortal := "O"

			//TEM QUE DECLARAR ESSAS VARIAVEIS, POIS ELAS ESTAO NA CHAMADA PRINCIPAL DA ROTINA GPEA051
			Private aSRF040     := {}
			Private aRIA040     := {}
			Private LTCFA040    := .T.
			Private lSuspensao  := .F. //VARIAVEL QUE CONTROLA A EXECUÇÃO DE UMA SUSPENSÃO    DE PROGRAMAÇÃO
			Private lCancela    := .F. //VARIAVEL QUE CONTROLA A EXECUÇÃO DE UM  CANCELAMENTO DE PROGRAMAÇÃO
			Private lRetifica   := .F. //VARIAVEL QUE CONTROLA A EXECUÇÃO DE UM  RETIFICAÇÃO  DE PROGRAMAÇÃO
			Private lEmProgr    := .F. //VARIAVEL QUE CONTROLA AS PROGRAMAÇÕES, NAO PERMITINDO O USUÁRIO FAZER MAIS DE UMA SEM CONFIRMAR
			Private lEmInc      := .F. //VARIAVEL QUE CONTROLA AS INCLUSÕES, NAO PERMITINDO O USUÁRIO FAZER MAIS DE UMA SEM CONFIRMAR
			Private lHabAba     := .F. //Variavel para habilitar a aba de Programação de férias
			Private cEnt        := chr(13) + chr(10)

			Private cGsPubl     := GetMv( "MV_GSPUBL",,"1")
			Private nGSPopc     := 0
			Private bFiltraBrw  := {|| Nil}      //Variavel para Filtro

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//³O parametro MV_GSPUBL = "2" identifica que eh GSP-Caixa. Se existir o ?
			//³parametro MV_VDFLOGO eh porque eh GSP-MP (novo modelo de GSP).        ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			If cGsPubl == "2" .And. GetMv("MV_VDFLOGO",,"0") <> "0"
				cGsPubl := "3"
			EndIf

			//Busca Dados da solicitacao de ferias
			cAliasQry := "SalFer"
			BeginSql alias cAliasQry
				SELECT * FROM %table:RH4% RH4 WHERE RH4.RH4_CODIGO = %exp:cCodSolic% AND RH4.%notDel%
			EndSql

			Dbselectarea(cAliasQry)
			While !(cAliasQry)->(eof())
				Do Case

					//LINHA DA RIA
					Case alltrim((cAliasQry)->RH4_CAMPO) == "RA_FILIAL"
						cFil        := SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RA_FILIAL')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "RA_MAT"
						cMat        := SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RA_MAT')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "RIA_SEQPRG"
						nSeq        := Val((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "RIA_PD"
						cPD         := SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RV_COD')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "RIA_DTINPA"
						dDtINPA     := CtoD(Substr((cAliasQry)->RH4_VALNOV,7,2)+'/'+Substr((cAliasQry)->RH4_VALNOV,5,2)+'/'+Substr((cAliasQry)->RH4_VALNOV,1,4))
					Case alltrim((cAliasQry)->RH4_CAMPO) == "RIA_DATINI"
						dDtIni      := CtoD(Substr((cAliasQry)->RH4_VALNOV,7,2)+'/'+Substr((cAliasQry)->RH4_VALNOV,5,2)+'/'+Substr((cAliasQry)->RH4_VALNOV,1,4))
					Case alltrim((cAliasQry)->RH4_CAMPO) == "RIA_DATFIM"
						dDtFim      := CtoD(Substr((cAliasQry)->RH4_VALNOV,7,2)+'/'+Substr((cAliasQry)->RH4_VALNOV,5,2)+'/'+Substr((cAliasQry)->RH4_VALNOV,1,4))

					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_REGID"
						nRegID      := Val((cAliasQry)->RH4_VALNOV)
				EndCase
				(cAliasQry)->(dbskip())
			Enddo
			(cAliasQry)->( DbCloseArea() )

			dbSelectArea("SRA")
			dbSetOrder(1)
			dbSeek(cFil+cMat)
			Aadd(aSRF040,{cFil,cMat,cPd,dDtINPA,,SRA->RA_PROCES,cCodSolic})
			Aadd(aRIA040,{0,dDtIni,dDtFim,,,0,0,nRegID})

			SETFUNNAME("GPEA051")
			Altera := .T.

			//CHAMA A TELA DE PROGRAMAÇÃO
			oReturn := FWExecView(STR0066,'GPEA051', MODEL_OPERATION_UPDATE, , { || .T. } ) //Cancelamento de programacao

			SETFUNNAME("TCFA040")
			dbSelectArea("SRA")  //REPOSICIONA O FUNCIONARIO

			If (oReturn == 0)  //0 - CONFIRMOU A ROTINA   |  1 - FECHOU A ROTINA
				oModRH3:SetValue("RH3_STATUS", cStatus)
				oModRH3:SetValue("RH3_DTATEN", dDataBase)
			Else
				oReturn := Nil
			EndIf

		ElseIf (oModRH3:GetValue("RH3_TIPO") == "B")
			// **************************** Ferias
			cTipSolicPortal	:= "B"
			lFluig := Alltrim(oModRH3:GetValue("RH3_ORIGEM")) == "FLUIG" //Solicitação veio do Fluig ou do Portal
			lMeuRH := Alltrim(Upper(oModRH3:GetValue("RH3_ORIGEM"))) == "MEURH" //Solicitação veio do MeuRH

			//Busca Dados da solicitacao de ferias
			cAliasQry := "SolFer"
			BeginSQL Alias cAliasQry
				SELECT *
				FROM %table:RH4% RH4
				WHERE RH4.RH4_FILIAL = %exp:RH3->RH3_FILIAL% AND
				RH4.RH4_CODIGO = %exp:cCodSolic% AND
				RH4.%notDel%
			EndSQL

			Dbselectarea(cAliasQry)
			While !(cAliasQry)->(eof())
				If !lFluig
					Do Case
						Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_FILIAL"
							cFerFilial				    := SubStr( (cAliasQry)->RH4_VALNOV, 1, nTamFilial)
						Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_MAT"
							cFerMat					    := SubStr( (cAliasQry)->RH4_VALNOV, 1, nTamMAT )
						Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_DATAINI"
							dFerDtIni				      := CtoD((cAliasQry)->RH4_VALNOV)
						Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_DATAFIM"
							dFerDtFim			  		  := CtoD((cAliasQry)->RH4_VALNOV)
						Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_DURACAO"
							nFerDuracao		    	  := val((cAliasQry)->RH4_VALNOV)
						Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_ABONO"
							lFerAbono			    	  := If (alltrim((cAliasQry)->RH4_VALNOV) == ".T.",.T.,.F.)
						Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_1P13SL"
							lFer13Sal			    	  := If (alltrim((cAliasQry)->RH4_VALNOV) == ".T.",.T.,.F.)
						Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DABONO"
							nDiasAb    				      := val((cAliasQry)->RH4_VALNOV)
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RF_DATABAS"
							cDatabas			    	  := DTOS(CTOD(Alltrim((cAliasQry)->RH4_VALNOV)))
					EndCase
				Else
					Do Case
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RF_FILIAL"
							cFerFilial				    := SubStr( (cAliasQry)->RH4_VALNOV, 1, nTamFilial)
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RF_MAT"
							cFerMat					    := SubStr( (cAliasQry)->RH4_VALNOV, 1, nTamMAT )
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RF_DATAINI"
							dFerDtIni				      := StoD((cAliasQry)->RH4_VALNOV)
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RF_DABPRO1"
							nDiasAb			  		  := Val((cAliasQry)->RH4_VALNOV)
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RF_DFEPRO1"
							nFerDuracao		    	  := val((cAliasQry)->RH4_VALNOV)
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RF_TEMABPE"
							lFerAbono			    	  := If (alltrim((cAliasQry)->RH4_VALNOV) == "S",.T.,.F.)
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RF_PERC13S"
							lFer13Sal			    	  := If (val((cAliasQry)->RH4_VALNOV) > 0,.T.,.F.)
						Case alltrim((cAliasQry)->RH4_CAMPO) == "RF_DATABAS"
							cDatabas			    	  := Alltrim((cAliasQry)->RH4_VALNOV)
					EndCase
				Endif

				(cAliasQry)->(dbskip())
			EndDo
			(cAliasQry)->( DbCloseArea() )

			If (cPaisLoc $ "BRA|CHI|PAR|URU")
				IF Select("SRA") > 0
					SRA->(dbCloseArea())
				Endif
				dbSelectArea("SRA")
				If !SRA->( MsSeek( cFerFilial + cFerMat ) )
					If !lLote
						MsgAlert(STR0034 , STR0007) //"Cadastro do funcionario da solicitacao nao localizado!"
					Else
						aAdd(aLog, STR0034)
					EndIf
					oReturn := Nil
					Return .F.
				EndIf

				dbSelectArea("SRF")
				DbSetOrder(1)
				If !SRF->( MsSeek( cFerFilial + cFerMat + cDatabas ) )
					If !lLote
						MsgAlert(STR0028 , STR0007) //"Nao existe periodo de ferias no cadastro de Programacao de Ferias!"
					Else
						aAdd(aLog, STR0028)
					EndIf
					oReturn := Nil
					Return .F.
				Else
					If !lMeuRH
						fCarPerFer(cFerFilial, cFerMat, @aPerFerias)
						If len(aPerFerias) > 0
							SRF->(dbGoto(aPerFerias[1][30]))
						Else
							If !lLote
								MsgAlert(STR0028 , STR0007) //"Nao existe periodo de ferias no cadastro de Programacao de Ferias!"
							Else
								aAdd(aLog, STR0028)
							EndIf
							oReturn := Nil
							Return .F.
						EndIf
					EndIf
				EndIf

				nIdade    := Int((dDataBase - SRA->RA_NASC) / 365)
				lContinua := .T.
				lShowSRF  := (lMeuRH .And. lFer13Sal .And. nPer13S == 0) .Or. (!lMeuRH .And. lFer13Sal)

				If ( lFerAbono .or. lFer13Sal .Or. ( !lRefTrab .And. nFerDuracao < 30 .AND. (nIdade < 18 .Or. nIdade > 50) ) )
					cMensagem := OemToAnsi(STR0083) + CRLF	//"Funcionário : " + CRLF
					If !lRefTrab .And. nIdade < 18 .AND. nFerDuracao < 30
						cMensagem += OemToAnsi(STR0084) + CRLF //"- ?menor de 18 anos e deve tirar férias em período único." + CRLF
					ElseIf !lRefTrab .And. nIdade > 50 .AND. nFerDuracao < 30
						cMensagem += OemToAnsi(STR0085) + CRLF //"- ?maior de 50 anos e deve tirar férias em período único." + CRLF
					EndIf
					If lFerAbono
						cMensagem += OemToAnsi(STR0086) + CRLF //"- Solicitou abono de férias." + CRLF
					EndIf
					If lFer13Sal
						cMensagem += OemToAnsi(STR0087) + CRLF //"- Solicitou adiantamento de 13o salário." + CRLF
					EndIf
					cMensagem += CRLF + OemToAnsi(STR0079)	//"A tela Controle de Dias de Direito sera aberta para realizar o complemento dos dados!
					
					If lShowSRF
						If !MsgYesNo(cMensagem, STR0031) //cMensagem ### "Deseja continuar?"
							oReturn := Nil
							Return .F.
						EndIf
					EndIf

					//Atualiza solicitacao para o Brasil pelo GPEA050
					IF 	(!Empty(SRF->RF_DATAINI) .and. !Empty(SRF->RF_DATINI2) .and. !Empty(SRF->RF_DATINI3))
						If !lLote
							MsgAlert(STR0032, STR0007) //"Todas as programacoes disponiveis ja estao ocupadas, verifique!"
						Else
							aAdd(aLog, STR0032)
						EndIf
						oReturn := Nil
						Return .F.
					EndIf
				EndIf

				If lShowSRF
					oModGPE	:= FWLOADMODEL('GPEA050')
					oModSRF	:= oModGPE:GetModel("GPEA050_SRF")
					oModGPE:SetOperation( 4 )
					oModGPE:Activate()
					If !lMeuRH
						oModSRF:SeekLine( { {"RF_STATUS","1"} } )
					Else
						oModSRF:SeekLine( { {"RF_DATABAS", STOD(cDatabas)}, {"RF_STATUS","1"} } )

						If (!Empty(SRF->RF_DATAINI) .And. SRF->RF_DATAINI > dFerDtIni) .Or. (!Empty(SRF->RF_DATINI2) .And. SRF->RF_DATINI2 > dFerDtIni)
							aDadosSRH := fGetSRH(SRF->RF_FILIAL, SRF->RF_MAT, SRF->RF_DATABAS, SRF->RF_DATAFIM)
							lContinua := Empty(aDadosSRH)
						EndIf
					EndIf

					If lContinua
						TCF040Prep(dFerDtIni,nFerDuracao,oModSRF,nDiasAb,lFerAbono,lMeuRH)
						oReturn := FWExecView(STR0078,'GPEA050', 4, , { || .T. },,,,,,,oModGPE)
						If (oReturn == 0)
							oModRH3:SetValue("RH3_STATUS", cStatus)
							oModRH3:SetValue("RH3_DTATEN", dDataBase)
						Else
							oReturn := Nil
						EndIf
					Else
						If !lLote
							MsgAlert(STR0175, STR0007) //"Já existem férias programadas e calculadas com data superior!"
						Else
							aAdd(aLog, STR0175) 
						EndIf
						oReturn := Nil
						Return .F.
					EndIf
				Else
					nPer13S := MIN(nPer13S, 100) //RF_PERC13S
					
					If lMeuRH .And. Empty(SRF->RF_DATINI3)

						//Ordena as programações existentes que está com data superior, mas somente se não houver calculo
						If (!Empty(SRF->RF_DATAINI) .And. SRF->RF_DATAINI > dFerDtIni) .Or. (!Empty(SRF->RF_DATINI2) .And. SRF->RF_DATINI2 > dFerDtIni)
							aDadosSRH := fGetSRH(SRF->RF_FILIAL, SRF->RF_MAT, SRF->RF_DATABAS, SRF->RF_DATAFIM)

							If Empty(aDadosSRH)

								aDtFer := {}
								aAdd( aDtFer, { dFerDtIni, nFerDuracao, nDiasAb  } )

								If !Empty(SRF->RF_DATAINI)
									aAdd( aDtFer, { SRF->RF_DATAINI, SRF->RF_DFEPRO1, SRF->RF_DABPRO1 } )
								EndIf
								If !Empty(SRF->RF_DATINI2)
									aAdd( aDtFer, { SRF->RF_DATINI2, SRF->RF_DFEPRO2, SRF->RF_DABPRO2 } )
								EndIf

								aSort( aDtFer,,, { |x,y| x[1] < y[1] } )

								RecLock("SRF", .F.)
								SRF->RF_PERC13S := If( Empty(SRF->RF_PERC13S), nPer13S, SRF->RF_PERC13S )
								For nX := 1 To Len(aDtFer)
									If nX == 1
										SRF->RF_DATAINI	:= aDtFer[nX,1]
										SRF->RF_DFEPRO1	:= aDtFer[nX,2]
										SRF->RF_DABPRO1 := aDtFer[nX,3]
									ElseIf nX == 2
										SRF->RF_DATINI2	:= aDtFer[nX,1]
										SRF->RF_DFEPRO2	:= aDtFer[nX,2]
										SRF->RF_DABPRO2 := aDtFer[nX,3]
									Else
										SRF->RF_DATINI3	:= aDtFer[nX,1]
										SRF->RF_DFEPRO3	:= aDtFer[nX,2]
										SRF->RF_DABPRO3 := aDtFer[nX,3]																
									EndIf
								Next nX
								SRF->(MsUnlock())
								lContinua := .F.
							Else
								If !lLote
									MsgAlert(STR0175, STR0007) //"Já existem férias programadas e calculadas com data superior!"
								Else
									aAdd(aLog, STR0175) 
								EndIf
								oReturn := Nil
								Return .F.
							EndIf
						EndIf
					EndIf					
					
					//Atualiza direto SRF(Programacao de ferias)
					If lContinua
						If lFer13Sal .And. lMeuRH .And. Empty(SRF->RF_PERC13S) .And. nPer13S > 0 
							RecLock("SRF", .F.)
							SRF->RF_PERC13S := nPer13S
							SRF->(MsUnlock())
						EndIf

						IF Empty(SRF->RF_DATAINI)
							RecLock("SRF", .F.)
							SRF->RF_DATAINI	:= dFerDtIni
							SRF->RF_DFEPRO1	:= nFerDuracao
							If (lFerAbono)
								SRF->RF_DABPRO1	:= nDiasAb
							Else
								SRF->RF_DABPRO1	:= 0
							EndIf	
							SRF->(MsUnlock())
						ElseIf Empty(SRF->RF_DATINI2)
							RecLock("SRF", .F.)
							SRF->RF_DATINI2	:= dFerDtIni
							SRF->RF_DFEPRO2	:= nFerDuracao
							If (lFerAbono)
								SRF->RF_DABPRO2	:= nDiasAb
							Else
								SRF->RF_DABPRO2	:= 0
							EndIf	
							SRF->(MsUnlock())
						ElseIf Empty(SRF->RF_DATINI3)
							RecLock("SRF", .F.)
							SRF->RF_DATINI3	:= dFerDtIni
							SRF->RF_DFEPRO3	:= nFerDuracao
							If (lFerAbono)
								SRF->RF_DABPRO3	:= nDiasAb
							Else
								SRF->RF_DABPRO3	:= 0
							EndIf	
							SRF->(MsUnlock())
						Else
							If !lLote
								MsgAlert(STR0032 , STR0007) //"Todas as programacoes disponiveis ja estao ocupadas, verifique!"
							Else
								aAdd(aLog, STR0032) 
							EndIf
							oReturn := Nil
							Return .F.
						EndIf
						
					EndIf
					oModRH3:SetValue("RH3_STATUS", cStatus)
					oModRH3:SetValue("RH3_DTATEN", dDataBase)
					oReturn := 0
				EndIf

				SRA->(dbCloseArea())
				SRF->(dbCloseArea())
			EndIF

			If (cPaisLoc $ "ARG")
				//GPEM033()

				IF Select("RHI") > 0
					RHI->(dbCloseArea())
				Endif

				dbSelectArea("RHI")
				dbSetOrder(RetOrder("RHI", "RHI_FILIAL+RHI_MAT+DTOS(RHI_DTINI)"))
				IF RHI->(dbSeek( cFerFilial + cFerMat + DTOS(dFerDtIni) ))
					oModRH3:SetValue("RH3_STATUS", cStatus)
					oModRH3:SetValue("RH3_DTATEN", dDataBase)
					oReturn := 0
				EndIF
				RHI->(dbCloseArea())
			EndIF

			If (cPaisLoc $ "MEX|COS|BOL")
				IF Select("SRA") > 0
					SRA->(dbCloseArea())
				Endif
				dbSelectArea("SRA")
				If !SRA->( MsSeek( cFerFilial + cFerMat ) )
					If !lLote
						MsgAlert(STR0034 , STR0007) //"Cadastro do funcionario da solicitacao nao localizado!"
					Else
						aAdd(aLog, STR0034)
					EndIf
					oReturn := Nil
					Return .F.
				EndIf

				/*dbSelectArea("SR8")
				DbSetOrder(1)
				If SR8->( MsSeek( cFerFilial + alltrim(cFerMat) ) )
					//Processo de alteracao de afastamento
					gp240Atu( "SRA" , 1 , 4 )
				Else
					//Processo Inclusao de afastamento
					gp240Aux("SRA" , 1 , 4 )
				EndIf*/

				dbSelectArea("SR8")
				DbSetOrder(1)
				If SR8->( MsSeek( cFerFilial + cFerMat + DTOS(dFerDtIni)  ) )
					oModRH3:SetValue("RH3_STATUS", cStatus)
					oModRH3:SetValue("RH3_DTATEN", dDataBase)
					oReturn := 0
				EndIf
			EndIF

			If (cPaisLoc $ "ANG|POR|EQU")
				IF Select("SRA") > 0
					SRA->(dbCloseArea())
				Endif
				dbSelectArea("SRA")
				If !SRA->( MsSeek( cFerFilial + cFerMat ) )
					If !lLote
						MsgAlert(STR0034 , STR0007) //"Cadastro do funcionario da solicitacao nao localizado!"
					Else
						aAdd(aLog, STR0034)
					EndIf
					oReturn := Nil
					Return .F.
				EndIf

				If Type("P_FERPAC") == "U"
					Private P_FERPAC := "S"
				EndIf
				//GPFerias("SRA",SRA->(Recno()),4)

				dbSelectArea("SR8")
				DbSetOrder(1)
				If SR8->( MsSeek( cFerFilial + cFerMat + DTOS(dFerDtIni)  ) )
					oModRH3:SetValue("RH3_STATUS", cStatus)
					oModRH3:SetValue("RH3_DTATEN", dDataBase)
					oReturn := 0
				EndIf
			EndIF
		ElseIf (oModRH3:GetValue("RH3_TIPO") == "H")
			// **************************** Candidato Externo

			DbSelectArea("RH4")
			RH4->(DbSetOrder(nOrd1RH4))
			RH4->(dbSeek(xFilial("RH4")+oModRH3:GetValue("RH3_CODIGO")))

			//Analisa se existe email cadastrado no Curriculo e se existe messagem de aprovacao cadastrada na vaga
			While RH4->(!Eof()) .AND. RH4->RH4_FILIAL+RH4->RH4_CODIGO == xFilial("RH4")+oModRH3:GetValue("RH3_CODIGO")

				If Alltrim(RH4->RH4_CAMPO) == "TMP_FILIAL" //Filial da vaga
					cSqsFil := SUBSTR(RH4->RH4_VALNOV, 1, FWGetTamFilial)
				EndIf

				If (Alltrim(RH4->RH4_CAMPO) == "QG_CURRIC")
					DbSelectArea("SQG")
					SQG->(DbSetOrder(nOrd1SQG))
					SQG->(dbSeek(xFilial("SQG")+RH4->RH4_VALNOV))
					if (SQG->(Columnpos("QG_ACTRSP")) > 0 .and. SQG->QG_ACTRSP <> '1') .or.  SQG->(Columnpos("QG_ACTRSP")) <= 0 //1- sem aceite e 2-com aceite
						IF (cBlqCV == "2" .AND. SQG->QG_ACEITE == "2") .OR. cBlqCV <> "2"
							//BLOQUEAR O CV POR NAO ACEITE DO TERMO DE CONSENTIMENTO
							//1=Sem aceite; 2=Aceite vigente gravado
							nBlqCV := 0
						else
							nBlqCV := 2
							exit
						ENDIF
					else
						nBlqCV := 1
						exit
					ENDIF
					cEndEmail	:= Alltrim(SQG->QG_EMAIL)
				ElseIf (Alltrim(RH4->RH4_CAMPO) == "TMP_VAGA")
					cSqsFil := If(cSqsFil == Nil, xFilial("SQS"), cSqsFil)
					DbSelectArea("SQS")
					SQS->(DbSetOrder(nOrd1SQS))
					SQS->(dbSeek(cSqsFil+AllTrim(RH4->RH4_VALNOV)))
					cCodMsgApr	:= AllTrim(SQS->QS_MSGAPV)
				EndIf
				RH4->(dbSkip())
			EndDo

			if nBlqCV <= 0
				Private	nTamaCols	:= 0

				aArea := GetArea()
				Rs150List(3,2,SQS->QS_VAGA,SQS->QS_FILIAL)
				RestArea(aArea)

				If oReturn == 0
					oModRH3:SetValue("RH3_STATUS", cStatus)
					oModRH3:SetValue("RH3_DTATEN", dDataBase)

					//Questiona se deseja enviar email de reprovacao
					If !Empty(cCodMsgApr) .AND. !Empty(cEndEmail)
						If MsgYesNo(STR0045)   //"Deseja enviar email informando a aprovação?"
							//STR0036 - "Retorno sobre Processo Seletivo"
							cMsgEmail	:= RHMSMM( Fdesc("RDG",cCodMsgApr,"RDG_CODMEM"),,,,,,,,,,,"RDG" )
							RH_Email(Lower(Alltrim(cEndEmail)),'',STR0036,cMsgEmail,'','')
						EndIf
					EndIf
				Else
					oReturn := Nil
				EndIf
			else
				if nBlqCV == 1
					If !lLote
						MsgAlert(STR0152 , STR0007) //"Currículo bloqueado aguardando documentos do responsável do menor."
					Else
						aAdd(aLog, STR0152)
					EndIf
				elseif nBlqCV == 2
					If !lLote
						MsgAlert(OEMTOANSI( STR0151 ) , STR0007) //"Currículo bloqueado aguardando aceite do termo de consentimento."
					Else
						aAdd(aLog, STR0151)
					EndIf
				ENDIF
				oReturn := Nil
			ENDIF
		ElseIf (oModRH3:GetValue("RH3_TIPO") == "9")
			// **************************** Candidato Interno
			Private	nTamaCols	:= 0

			DbSelectArea("SQG")
			SQG->(DbSetOrder(nOrd3SQG))
			SQG->(dbSeek(xFilial("SQG")+SRA->RA_CIC))

			If AllTrim(SRA->RA_CIC) == AllTrim(SQG->QG_CIC)
				if (SQG->(Columnpos("QG_ACTRSP")) > 0 .and. SQG->QG_ACTRSP <> '1') .or.  SQG->(Columnpos("QG_ACTRSP")) <= 0 //1- sem aceite e 2-com aceite
					IF (cBlqCV == "2" .AND. SQG->QG_ACEITE == "2") .OR. cBlqCV <> "2"
						//BLOQUEAR O CV POR NAO ACEITE DO TERMO DE CONSENTIMENTO
						//1=Sem aceite; 2=Aceite vigente gravado
						DbSelectArea("RH4")
						RH4->(DbSetOrder(nOrd1RH4))
						RH4->(dbSeek(xFilial("RH4")+oModRH3:GetValue("RH3_CODIGO")))

						//Analisa se existe email cadastrado no Curriculo e se existe messagem de aprovacao cadastrada na vaga
						While RH4->(!Eof()) .AND. RH4->RH4_FILIAL+RH4->RH4_CODIGO == xFilial("RH4")+oModRH3:GetValue("RH3_CODIGO")

							If Alltrim(RH4->RH4_CAMPO) == "TMP_FILIAL" //Filial da vaga
								cSqsFil := SUBSTR(RH4->RH4_VALNOV, 1, FWGetTamFilial)
							EndIf

							If (Alltrim(RH4->RH4_CAMPO) == "TMP_VAGA")
								cSqsFil := If(cSqsFil == Nil, xFilial("SQS"), cSqsFil)
								DbSelectArea("SQS")
								SQS->(DbSetOrder(nOrd1SQS))
								SQS->(dbSeek(cSqsFil+AllTrim( RH4->RH4_VALNOV) ))
							EndIf
							RH4->(dbSkip())
						EndDo
						aArea := GetArea()

						Rs150List(3,2,SQS->QS_VAGA,SQS->QS_FILIAL)

						RestArea(aArea)
						If oReturn == 0
							oModRH3:SetValue("RH3_STATUS", cStatus)
							oModRH3:SetValue("RH3_DTATEN", dDataBase)
						Else
							oReturn := Nil
						EndIf
					ELSE
						//"Currículo bloqueado por falta de aceite do termo de consentimento."
						If !lLote
							MsgAlert(STR0151 , STR0007)
						Else
							aAdd(aLog, STR0151)
						EndIf
						oReturn := Nil
					ENDIF
				ELSE
					If !lLote
						MsgAlert(STR0152 , STR0007) //"Currículo bloqueado aguardando documentos do responsável do menor."
					Else
						aAdd(aLog, STR0152)
					EndIf
					oReturn := Nil
				ENDIF
			Else
				If !lLote
					Alert(STR0047)//"Esse funcionário ainda não possui o currículo cadastrado, utilize a função 'Seleção Interna' em Ações Relacionadas ou 'Miscelânea -> Seleção Interna' para gerar os dados do funcionário no cadastro de currículos."
				Else
					aAdd(aLog, STR0047)
				EndIf
				oReturn := Nil
			EndIf

		ElseIf (oModRH3:GetValue("RH3_TIPO") == "N")
			// **************************** Alteracao de Jornada - Gestao publica

			//Buscar jornada solicitada
			DbSelectArea("RH4")
			RH4->(DbSetOrder(nOrd1RH4))
			RH4->(dbSeek(xFilial("RH4")+oModRH3:GetValue("RH3_CODIGO")))

			While RH4->(!Eof()) .AND. RH4->RH4_FILIAL+RH4->RH4_CODIGO == xFilial("RH4")+oModRH3:GetValue("RH3_CODIGO")

				Do Case
					Case "_FILIAL" $ Alltrim(RH4->RH4_CAMPO)
						cJornFilial            := SubStr(RH4->RH4_VALNOV,1,Len(RH4->RH4_FILIAL))
					Case alltrim(RH4->RH4_CAMPO) == "PF_MAT"
						cJornMat               := RH4->RH4_VALNOV
					Case alltrim(RH4->RH4_CAMPO) == "PF_JORNAPA"
						cJornada               := RH4->RH4_VALNOV
				EndCase

				RH4->(dbSkip())
			EndDo
			aArea := GetArea()

			//Atualizacao da jornada
			Pn161Verif(cJornFilial,cJornMat,dtos(dDataBase),cJornada) // filial,matricula,data alt, op jornada (30,35 ou 40hs)

			If oReturn == 0
				oModRH3:SetValue("RH3_STATUS", cStatus)
				oModRH3:SetValue("RH3_DTATEN", dDataBase)
			Else
				oReturn := Nil
			EndIf

		ElseIf (oModRH3:GetValue("RH3_TIPO") == "Q")
			// **************************** Diarias - Gestao publica
			oModRH3:SetValue("RH3_STATUS", cStatus)
			oModRH3:SetValue("RH3_DTATEN", dDataBase)
			oReturn := 0

		ElseIf (oModRH3:GetValue("RH3_TIPO") == "R") .And. !(cVerGSP $ "2/3")
			// **************************** Licenca e Afastamento - SIGAPGE Padrao (requisicoes do App MeuRH)

			//Busca dados do funcionario
			cAliasQry := "FilAfas"
			BeginSQL Alias cAliasQry
				SELECT *
				FROM %table:RH4% RH4
				WHERE RH4.RH4_CODIGO = %exp:cCodSolic% AND
				RH4.%notDel%
			EndSQL

			Dbselectarea(cAliasQry)
			While (cAliasQry)->(!Eof())

				Do Case
					Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_FILIAL"
						cAfaFilial			:= SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RA_FILIAL')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_MAT"
						cAfaMat				:= SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RA_MAT')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_TIPOAFA"
						cAfaCod				:= AllTrim((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_PD"
						cAfaPd				:= AllTrim((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_CID"
						cAfaCID				:= AllTrim((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_TPEFD"
						cAfaEsoc			:= AllTrim((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_DATAINI"
						dAfaIni				:= CtoD((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_DATAFIM"
						dAfaFim				:= CtoD((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_DURACAO"
						nDuracao			:= Val( AllTrim((cAliasQry)->RH4_VALNOV) )
					Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_NUMID"
						cNumId  			:= AllTrim((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_MEMO"
						cMemoSR8  			:= AllTrim((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_NMMED"
						cNomMed  			:= AllTrim((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_CRMMED"
						cCRMMed  			:= AllTrim((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "R8_IDEOC"
						cIdeOC  			:= AllTrim((cAliasQry)->RH4_VALNOV)
				EndCase

				(cAliasQry)->(dbSkip())
			EndDo

			(cAliasQry)->( DbCloseArea() )

			dbSelectArea("SRA")
			If !SRA->( dbSeek( cAfaFilial + cAfaMat ))
				If !lLote
					MsgAlert(STR0034 , STR0007) //"Cadastro do funcionario da solicitacao nao localizado!"
				Else
					aAdd(aLog, STR0034)
				EndIf
				oReturn := Nil
				Return .F.
			EndIf

			cProcesso := SRA->RA_PROCES

			dbSelectArea("SR8")
			cMemoAux	:= RHMSMM(, NIL, NIL, cMemoSR8, 1, NIL, NIL, "SR8", "R8_CODMEMO","RDY",,,.F.,cAfaFilial)
			oModGPE	 	:= FWLOADMODEL('GPEA240')
			oModSR8		:= oModGPE:GetModel("GPEA240_SR8")

			oModGPE:SetOperation( 3 )
			oModGPE:Activate()

			nLine := oModSR8:Length()
			If nLine > 1 .Or. (nLine ==  1 .And. !Empty(oModSR8:GetValue("R8_TIPOAFA")) )
				oModSR8:AddLine()
			EndIf

			//Atribui valores para a linha adicionada
			oModSR8:LoadValue("R8_FILIAL"	, cAfaFilial )
			oModSR8:LoadValue("R8_MAT"		, cAfaMat )
			oModSR8:SetValue("R8_TIPOAFA"	, cAfaCod )
			oModSR8:LoadValue("R8_PD" 		, cAfaPd )
			oModSR8:LoadValue("R8_TPEFD"	, cAfaEsoc )
			oModSR8:LoadValue("R8_CID"		, cAfaCID )
			oModSR8:LoadValue("R8_DATAINI"	, dAfaIni )
			oModSR8:SetValue("R8_DURACAO"	, nDuracao )
			oModSR8:LoadValue("R8_DATAFIM"	, dAfaFim )
			oModSR8:LoadValue("R8_MEMO"		, cMemoSR8 )
			oModSR8:LoadValue("R8_NUMID"	, cNumId )
			oModSR8:LoadValue("R8_CODMEMO"	, cMemoAux )
			oModSR8:LoadValue("R8_NMMED"	, cNomMed )
			oModSR8:LoadValue("R8_CRMMED"	, cCRMMed )
			oModSR8:LoadValue("R8_IDEOC"	, cIdeOC )

			//Nao permite incluir um outro afastamento durante a aprovacao
			oModSR8:SetNoInsertLine( .T. )

			oReturn := FWExecView(STR0078,'GPEA240', 3, , { || .T. },,,,,,,oModGPE)

			If (oReturn == 0)  //0 - CONFIRMOU A ROTINA   |  1 - FECHOU A ROTINA
				oModRH3:SetValue("RH3_STATUS", cStatus)
				oModRH3:SetValue("RH3_DTATEN", dDataBase)
			Else
				oReturn := Nil
			EndIf

		ElseIf (oModRH3:GetValue("RH3_TIPO") == "R")
			// **************************** Licenca e Afastamento - Gestao publica
			cAliasQry := "LicGsp"
			BeginSQL Alias cAliasQry
				SELECT * FROM %table:RH4% RH4 WHERE RH4.RH4_CODIGO = %exp:cCodSolic% AND RH4.%notDel%
			EndSQL

			Dbselectarea(cAliasQry)
			While !(cAliasQry)->(eof())
				Do Case

					Case alltrim((cAliasQry)->RH4_CAMPO) == "RA_FILIAL"
						cFil        := SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RA_FILIAL')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "RA_MAT"
						cMat        := SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RA_MAT')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "RCM_TIPO"
						cTpALT      := SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RCM_TIPO')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DTINI"
						dFerDtIni  := CtoD((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DTFIM"
						dFerDtFim   := CtoD((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DIAREQ"
						nFerDuracao := val((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_FSUBST"
						cFSubst     := SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RA_FILIAL')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_MSUBST"
						cMSubst     := SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RA_MAT')[1])

				EndCase
				(cAliasQry)->(dbskip())
			Enddo
			(cAliasQry)->( DbCloseArea() )

			//Busca SRA
			dbSelectArea("SRA")
			If !SRA->( MsSeek( xFilial("SRA") + alltrim(cMat) ) )
				If !lLote
					MsgAlert(STR0034 , STR0007) //"Cadastro do funcionario da solicitacao nao localizado!"
				Else
					aAdd(aLog, STR0034)
				EndIf
				oReturn := Nil
				Return .F.
			EndIf

			//Busca detalhes da licenca (RCM)
			dbSelectArea("RCM")
			If !RCM->( MsSeek( xFilial("RCM") +cTpALT ) )
				If !lLote
					MsgAlert(STR0069 , STR0007) //"Registro da licenca nao localizado!"
				Else
					aAdd(aLog, STR0069)
				EndIf
				oReturn := Nil
				Return .F.
			EndIf

			//Procura a ultima sequencia
			cAliasQry := "QSEQSR8"
			BeginSQL Alias cAliasQry
				SELECT MAX(R8_SEQ) R8_SEQ
				FROM %table:SR8% SR8
				WHERE SR8.R8_FILIAL = %exp:cFil% AND
				SR8.R8_MAT    = %exp:cMat% AND
				SR8.%notDel%
			EndSQL
			If !(cAliasQry)->(eof())
				cSeq := soma1((cAliasQry)->R8_SEQ)
			Else
				cSeq := "001"
			EndIf
			(cAliasQry)->( DbCloseArea() )

			//Busca Período em aberto para o servidor/funcionario
			fGetPerAtual(@aPerAtual, , SRA->RA_PROCES, fGetRotOrdinar(,,If(SRA->RA_REGIME == "2", "GFP","GPE") ) )
			//varinfo("Periodo atual-> ",aPerAtual)
			If len(aPerAtual) == 0
				If !lLote
					MsgAlert(STR0070 , STR0007) //"Periodo em aberto nao localizado!"
				Else
					aAdd(aLog, STR0070)
				EndIf
				oReturn := Nil
				Return .F.
			EndIf

			//Grava afastamento (SR8)
			RecLock("SR8", .T.)
				SR8->R8_FILIAL       := xFilial("SR8")
				SR8->R8_MAT          := cMat
				SR8->R8_SEQ          := cSeq

				SR8->R8_DATA         := dDataBase
				SR8->R8_TIPO         := RCM->RCM_TIPOAF
				SR8->R8_TIPOAFA     := RCM->RCM_TIPO
				SR8->R8_PD           := RCM->RCM_PD

				SR8->R8_AFARAIS     := RCM->RCM_CODRAI
				SR8->R8_DIASEMP     := RCM->RCM_DIASEM
				SR8->R8_DPAGAR      :=  0

				SR8->R8_DATAINI     := dFerDtIni
				SR8->R8_DATAFIM     := dFerDtFim
				SR8->R8_DURACAO     := nFerDuracao

				SR8->R8_PROCES      := SRA->RA_PROCES
				SR8->R8_PER         := aPerAtual[1][1]
				SR8->R8_NUMPAGO     := aPerAtual[1][2]

				SR8->R8_FILSUB      := cFSubst
				SR8->R8_MATSUB      := cMSubst
			MsUnLock()

			//Confirma atualização
			dbSelectArea("SR8")
			DbSetOrder(1)
			If SR8->( MsSeek( xFilial("SR8") + alltrim(cMat) + DTOS(dFerDtIni) ) )
				If !lLote
					MsgInfo(STR0071 , STR0007) //"Licença(SR8) registrada com sucesso!"
				Else
					aAdd(aLog, STR0071)
				EndIf

				oModRH3:SetValue("RH3_STATUS", cStatus)
				oModRH3:SetValue("RH3_DTATEN", dDataBase)
				oReturn := 0
			Else
				oReturn := Nil
			EndIf

		ElseIf (oModRH3:GetValue("RH3_TIPO") == "S")
			// **************************** Certidao - Gestao publica
			oModRH3:SetValue("RH3_STATUS", cStatus)
			oModRH3:SetValue("RH3_DTATEN", dDataBase)
			oReturn := 0

		ElseIf (oModRH3:GetValue("RH3_TIPO") == "T")
			// **************************** Dias de Folga - Gestao publica
			cFil	    := ""
			cMat	    := ""
			cPD			:= ""
			dDtBIni    := STOD("")
			dDtBFim	:= STOD("")
			nDiasPer1	:= 0
			dPerIni1	:= STOD("")
			dPerFim1	:= STOD("")
			cFilSub1	:= ""
			cMatSub1	:= ""
			dAbono		:= 0
			dOport		:= 0
			nDiasPer2	:= 0
			dPerIni2	:= STOD("")
			dPerFim2	:= STOD("")
			cFilSub2	:= ""
			cMatSub2	:= ""
			cTipSolicPortal := "P"

			//TEM QUE DECLARAR ESSAS VARIAVEIS, POIS ELAS ESTAO NA CHAMADA PRINCIPAL DA ROTINA GPEA051
			Private aSRF040 	 := {}
			Private aRIA040 	 := {}
			Private lSuspensao := .F.
			Private lCancela    := .F.
			Private lRetifica   := .F.
			Private LCANCSRF    := .F.
			Private LTCFA040     := .T.

			Private cGsPubl      := GetMv( "MV_GSPUBL",,"1")
			Private nGSPopc      := 0
			Private bFiltraBrw   := {|| Nil}		//Variavel para Filtro
			Private lHabAba      := .F.				//Variavel para habilitar a aba de Programação de férias
			Private lVerRI6      := .T.  //Variavel para validar publicação

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//³O parametro MV_GSPUBL = "2" identifica que eh GSP-Caixa. Se existir o ?
			//³parametro MV_VDFLOGO eh porque eh GSP-MP (novo modelo de GSP).        ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			If cGsPubl == "2" .And. GetMv("MV_VDFLOGO",,"0") <> "0"
				cGsPubl := "3"
			EndIf

			//Busca Dados da solicitacao de ferias
			cAliasQry := "PerFer"
			BeginSQL Alias cAliasQry
				SELECT * FROM %table:RH4% RH4 WHERE RH4.RH4_CODIGO = %exp:cCodSolic% AND RH4.%notDel%
			EndSQL

			Dbselectarea(cAliasQry)
				While !(cAliasQry)->(eof())
					Do Case

					//CABEÇALHO - SRF
					Case alltrim((cAliasQry)->RH4_CAMPO) == "RA_FILIAL"
						cFil	    := SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RA_FILIAL')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "RA_MAT"
						cMat	    := SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RA_MAT')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_PD"
						cPD			:= SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RV_COD')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DTBINI"
						dDtBIni    	:= CtoD((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DTBFIM"
						dDtBFim		:= CtoD((cAliasQry)->RH4_VALNOV)

					//LINHA 1 DA RIA
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DPER1"
						nDiasPer1	:= Val((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DTINI1"
						dPerIni1	:= CtoD((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DTFIM1"
						dPerFim1		:= CtoD((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_FSUB1"
						cFilSub1		:= SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RIA_FILIAL')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_MSUB1"
						cMatSub1		:= SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RIA_MAT')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DABONO"
						dAbono		:= VAL((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DOPORT"
						dOport		:= VAL((cAliasQry)->RH4_VALNOV)

					//LINHA 2 DA RIA
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DPER2"
						nDiasPer2	:= Val((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DTINI2"
						dPerIni2	:= CtoD((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_DTFIM2"
						dPerFim2		:= CtoD((cAliasQry)->RH4_VALNOV)
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_FSUB2"
						cFilSub2		:= SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RIA_FILIAL')[1])
					Case alltrim((cAliasQry)->RH4_CAMPO) == "TMP_MSUB2"
						cMatSub2		:= SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('RIA_MAT')[1])

					EndCase
					(cAliasQry)->(dbskip())
				Enddo
			(cAliasQry)->( DbCloseArea() )

			dbSelectArea("SRA")
			dbSetOrder(1)
			dbSeek(cFil+cMat)
			Aadd(aSRF040,{cFil,cMat,cPd,dDtBIni,dDtBFim,SRA->RA_PROCES,cCodSolic})
			Aadd(aRIA040,{nDiasPer1,dPerIni1,dPerFim1,cFilSub1,cMatSub1,dAbono,dOport})
			If !empty(dPerIni2)
				Aadd(aRIA040,{nDiasPer2,dPerIni2,dPerFim2,cFilSub2,cMatSub2,0     ,0     })
			EndIf

			SETFUNNAME("GPEA051")

			oReturn := FWExecView(,'GPEA051', MODEL_OPERATION_UPDATE, , { || .T. } )  //CHAMA A TELA DE PROGRAMAÇÃO

			SETFUNNAME("TCFA040")
			dbSelectArea("SRA")  //REPOSICIONA O FUNCIONARIO

			If (oReturn == 0)  //0 - CONFIRMOU A ROTINA   |  1 - FECHOU A ROTINA
				oModRH3:SetValue("RH3_STATUS", cStatus)
				oModRH3:SetValue("RH3_DTATEN", dDataBase)
			Else
				oReturn := Nil
			EndIf
		ElseIf (oModRH3:GetValue("RH3_TIPO") == "V")
			// **************************** Subsidio academico
			cRh3Cod	:= oModRH3:GetValue("RH3_CODIGO")
			SETFUNNAME("GPEA065")

			oReturn := FWExecView(,'GPEA065', MODEL_OPERATION_UPDATE, , { || .T. } )  //CHAMA A TELA DE PROGRAMAÇÃO

			SETFUNNAME("TCFA040")
			dbSelectArea("SRA")  //REPOSICIONA O FUNCIONARIO

			If (oReturn == 0)  //0 - CONFIRMOU A ROTINA   |  1 - FECHOU A ROTINA
				/*
				Futuramente será feito um trabalho para que todas as solictações envie email, acordado com o GDP em 07/05/2014
				//Questiona se deseja enviar email de reprovacao
				If !Empty(cCodMsgApr) .AND. !Empty(cEndEmail)
					If MsgYesNo(STR0045)   //"Deseja enviar email informando a aprovação?"
						//STR0036 - "Retorno sobre Subs&iacute;dio Acad&ecirc;mico"
						cMsgEmail	:= "<strong>Prezado Funcion&aacute;rio,</strong><br><br>"
						cMsgEmail	+= "Sua solicita&ccedil;&atilde;o de subs&iacute;dio foi aprovada, acesse o portal para maiores detalhes.<br><br>"
						cMsgEmail	+= "Atenciosamente,"
						cEndEmail	:= 'emecampos@gmail.com"
						RH_Email(Lower(Alltrim(cEndEmail)),'',"Retorno sobre Subs&iacute;dio Acad&ecirc;mico",cMsgEmail,'','')
					EndIf
				EndIf*/

				oModRH3:SetValue("RH3_STATUS", cStatus)
				oModRH3:SetValue("RH3_DTATEN", dDataBase)
			Else
				oReturn := Nil
			EndIf
		ElseIf (oModRH3:GetValue("RH3_TIPO") == "Z") //Marcação de Ponto via Portal

			nRet := fAprovPon( RH3->RH3_FILIAL, RH3->RH3_MAT, RH3->RH3_CODIGO, @cMsg, @cAviso, .F. )

			DbSelectArea("SRA")
			DbSetOrder(1)
			SRA->(DbSeek(RH3->RH3_FILIAL + RH3->RH3_MAT))

			If nRet == 1
				If !lLote
					MsgStop( cMsg, cAviso )
				Else
					aAdd(aLog, cAviso + " - " + cMsg )
				EndIf
				oReturn := Nil
				Return(.F.)
			ElseIf nRet == 2
				If !lLote
					MsgAlert(STR0076 , STR0007) //"Marcação esta fora do período aberto, não poder?ser incluída!"
				Else
					aAdd(aLog, STR0076)
				EndIf
				oReturn := Nil
				Return .F.
			Else
				oModRH3:SetValue("RH3_STATUS", cStatus)
				oModRH3:SetValue("RH3_DTATEN", dDataBase)
				oReturn := 0
			EndIf

		EndIf
	EndIf
	If oReturn != NIL
		// Ponto de entrada antes do commit das solicitações
		If ExistBlock("TCF040GRV")
			ExecBlock("TCF040GRV", .F., .F., {cStatus, .T., oModel})
		EndIf

		If (oModRH3:GetValue("RH3_TIPO") != "H") .And. (cStatus $ "2|3")
			WFSolicPortal(3, RH3->RH3_CODIGO, Nil, RH3->RH3_FILIAL, cStatus)
		EndIf

		If oModel:VldData()
			oModel:CommitData()
		Else
			If !lLote
				MsgAlert(oModel:GetErrorMessage()[6], STR0007) //"Atencao!"
			Else
				aAdd(aLog, oModel:GetErrorMessage()[6])
			EndIf
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Valida()

@author Rogerio Ribeiro
@since 02/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Valida()
	Local lValid:= .T.

	If RH3->RH3_STATUS == "2" .OR. RH3->RH3_STATUS == "3"
		MsgAlert(STR0008, STR0007)		//"A solicitacao ja foi atendida!"###"Atencao!"
		lValid:= .F.
	EndIf

   If cVerGSP == "3" // Gestao Publica - MP
      If RH3->RH3_STATUS == "1"
          MsgAlert(STR0033, STR0007) //"A solicitacao ainda esta em processo de aprovação!"
          lValid:= .F.
      EndIf
   Else
    	If RH3->RH3_STATUS == "1" .OR. RH3->RH3_STATUS == "5"
    		MsgAlert(STR0033, STR0007) //"A solicitacao ainda esta em processo de aprovação!"
    		lValid:= .F.
    	EndIf
   EndIf
Return lValid

Static Function UpdateFields(oModel)
	Local nLine
	//Local oModel:= FWLoadModel("GPEA010_MVC")
	Local oModSRA:= oModel:GetModel("TCFA040_SRA")
	Local oModRH4:= oModel:GetModel("TCFA040_RH4")

	//Posicione("SRA", 1, cFil+cMat, "")

	//oModel:SetOperation(MODEL_OPERATION_UPDATE)
	//oModel:Activate()

	For nLine:= 1 To oModRH4:GetQtdLine()
		oModSRA:SetValue(oModRH4:GetValue("RH4_CAMPO", nLine), AllTrim(oModRH4:GetValue("RH4_VALNOV", nLine)))
	Next

/*	If oModel:VldData()
		oModel:CommitData()
	Else
		MsgAlert(oModel:GetErrorMessage()[6], "Atencao!")		//"Atencao!"
	EndIf
*/
Return

Static Function ViewWebDef(nOperation, cPk, cFormMVC)
	Local oView := ViewDef()
Return( oView:GetXML2Web(nOperation, cPk, cFormMVC) )

Function RH4InitDesc()
	Local cDesc := ""
	Local aDescCampos := {{"TMP_1P13SL"  , STR0081},; //"1a Parcela 13?Salario"
							{"TMP_ABOND"   , STR0090},; //"Abono Descrição"
							{"TMP_ABONO"   , STR0080},; //"Abono Pecuniário"
							{"TMP_COD"     , STR0091},; //"Código"
							{"TMP_CONTAT"  , STR0092},; //"Nome do Contato"
							{"TMP_DABONO"  , STR0093},; //"Dias Abono"
							{"TMP_DCARGO"  , STR0094},; //"Desc. Sumária"
							{"TMP_DCC"     , STR0095},; //"Desc. Centro Custo"
							{"TMP_DCCP"    , STR0095},; //"Desc. Centro Custo"
							{"TMP_DDEPTO"  , STR0096},; //"Desc. Departamento"
							{"TMP_DDEPTOP" , STR0096},; //"Desc. Departamento"
							{"TMP_DESC"    , STR0056},; //"Descrição"
							{"TMP_DFUNCA"  , STR0097},; //"Desc. Função"
							{"TMP_DIAREQ"  , STR0098},; //"Dias Licença"
							{"TMP_DOPORT"  , STR0099},; //"Dias Oport."
							{"TMP_DPER1"   , STR0100},; //"Dias Prim. Per."
							{"TMP_DPER2"   , STR0101},; //"Dias Segun. Per."
							{"TMP_DPROCP"  , STR0102},; //"Desc. Processo"
							{"TMP_DSCFIL"  , STR0103},; //"Desc. Filial"
							{"TMP_DTBFIM"  , STR0104},; //"Data Base Final"
							{"TMP_DTBINI"  , STR0105},; //"Data Base Inicial"
							{"TMP_DTFIM"   , STR0106},; //"Data Final"
							{"TMP_DTFIM1"  , STR0107},; //"Primeira Data Final"
							{"TMP_DTFIM2"  , STR0108},; //"Segunda Data Final"
							{"TMP_DTINI"   , STR0109},; //"Data Inicial"
							{"TMP_DTINI1"  , STR0110},; //"Primeira Data Inicial"
							{"TMP_DTINI2"  , STR0111},; //"Segunda Data Inicial"
							{"TMP_FILIAL"  , STR0053},; //"Filial"
							{"TMP_FSUB1"   , STR0112},; //"Primeira Filail Sub."
							{"TMP_FSUB2"   , STR0113},; //"Segunda Filial Sub."
							{"TMP_FSUBST"  , STR0114},; //"Filial Sub."
							{"TMP_MAT"     , STR0054},; //"Matrícula"
							{"TMP_MSUB1"   , STR0115},; //"Primeira Mat. Sub."
							{"TMP_MSUB2"   , STR0116},; //"Segunda Mat. Sub."
							{"TMP_MSUBST"  , STR0117},; //"Matrícula Sub."
							{"TMP_NMCURS"  , STR0118},; //"Nome do Curso"
							{"TMP_NMINST"  , STR0119},; //"Nome da Instituição"
							{"TMP_NOME"    , STR0082},; //"Nome"
							{"TMP_NOTA"    , STR0120},; //"Nota"
							{"TMP_NOVAC"   , STR0050},; //"Gera Nova Contratação?"
							{"TMP_NOVACO"  , STR0121},; //"Novo Contrato"
							{"TMP_NSUB1"   , STR0122},; //"Primeiro Nome Sub."
							{"TMP_NSUB2"   , STR0123},; //"Segundo Nome Sub."
							{"TMP_NSUBST"  , STR0124},; //"Nome Sub."
							{"TMP_PD"      , STR0125},; //"Verba"
							{"TMP_POSTO"   , STR0051},; //"Posto"
							{"TMP_QTDEPA"  , STR0126},; //"Qtde. Parcelas"
							{"TMP_RAZAO"   , STR0049},; //"Motivo Desligamento"
							{"TMP_REGID"   , STR0127},; //"Id Registro"
							{"TMP_SEQ"     , STR0128},; //"Sequência"
							{"TMP_SITUAC"  , STR0129},; //"Situação"
							{"TMP_TABELA"  , STR0130},; //"Tabela"
							{"TMP_TELEFO"  , STR0131},; //"Telefone"
							{"TMP_TEST"    , STR0132},; //"Teste"
							{"TMP_TIPO"    , STR0133},; //"Tipo"
							{"TMP_TPDESC"  , STR0134},; //"Tipo Dia Desc."
							{"TMP_VAGA"    , STR0055},; //"Vaga"
							{"TMP_VLRMEN"  , STR0135},; //"Valor Mensal"
							{"TMP_TEXT"    , STR0140},; //"Justificativa"
							{"TMP_MOTIVO"  , STR0141},; //"Motivo do afastamento"
							{"TMP_OBS"     , STR0140},; //"Justificativa"
							{"TMP_DIRECT"  , STR0153} } //"Direção"

	cDesc := Posicione("SX3", 2, RH4->RH4_CAMPO, "X3Descric()")
	If Empty(cDesc)
		If (nPos := aScan(aDescCampos, {|x| Alltrim(x[1]) == AllTrim(RH4->RH4_CAMPO)})) > 0
			cDesc := aDescCampos[nPos][2]
		EndIf
	EndIf

	If Empty(cDesc)
		cDesc := AllTrim(RH4->RH4_CAMPO)
	EndIf

Return cDesc

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡ao    ?AxInclui ?Autor ?Jorge Queiroz			?Data ?         ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡ao ?Programa generico para inclusao                            ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?Generico                                                   ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Function AxInclui040(cAlias,nReg,nOpc,aAcho,cFunc,aCpos,cTudoOk,lF3,cTransact,aButtons,;
						aParam,aAuto,lVirtual,lMaximized,cTela,lPanelFin,oFather,aDim,uArea, lFlat )

	Local aArea    := GetArea(cAlias)
	Local aCRA     := { oemtoansi(STR0001),oemtoansi(STR0002),oemtoansi(STR0003) }//"Confirma" ### "Redigita" ### "Abandona"
	Local aSvRot   := Nil
	Local aPosEnch := {}
	Local cMemo    := ""
	Local nX       := 0
	Local nOpcA    := 0
	Local nLenSX8  := GetSX8Len()
	Local bCampo   := {|nCPO| Field(nCPO) }
	Local bOk      := Nil
	Local bOk2     := {|| .T.}
	Local oDlg
	Local nTop
	Local nLeft
	Local nBottom
	Local nRight
	Local cAliasMemo
	Local bEndDlg := {|lOk| lOk:=oDlg:End(), nOpcA:=1, lOk}
	Local oEnc01

	Private aTELA[0][0]
	Private aGETS[0]

	DEFAULT cTudoOk := ".T."
	DEFAULT bOk     := &("{|| "+cTudoOk+"}")
	DEFAULT lF3     := .F.
	DEFAULT lVirtual:= .F.
	DEFAULT lPanelFin := .F.
	DEFAULT lFlat		:= .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Processamento de codeblock de validacao de confirmacao            ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If !Empty(aParam)
		bOk2 := aParam[2]
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Monta a entrada de dados do arquivo							 ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == Nil
		nOpc := 3
		If Type("aRotina") == "A"
			aSvRot := aClone(aRotina)
		EndIf
		Private aRotina := { { " "," ",0,1 } ,{ " "," ",0,2 },{ " "," ",0,3 } }
	EndIf
	//RegToMemory(cAlias, .T., lVirtual )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Inicializa variaveis para campos Memos Virtuais (GILSON)			 ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type("aMemos")=="A"
		For nX :=1 To Len(aMemos)
			cMemo := aMemos[nX][2]
			If ExistIni(cMemo)
				&cMemo := InitPad(SX3->X3_RELACAO)
			Else
				&cMemo := ""
			EndIf
		Next nX
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Funcoes executadas antes da chamada da Enchoice      ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cFunc != NIL
		&cFunc.()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Processamento de codeblock de antes da interface                  ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If !Empty(aParam)
		Eval(aParam[1],nOpc)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Envia para processamento dos Gets		 			 ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aAuto == Nil
		If !lPanelFin .AND. !lFlat
			If SetMDIChild()
				oMainWnd:ReadClientCoors()
				nTop := 40
				nLeft := 30
				nBottom := oMainWnd:nBottom-80
				nRight := oMainWnd:nRight-70
			Else
				nTop := 135
				nLeft := 0
				nBottom := TranslateBottom(.T.,28)
				nRight := 632
			EndIf
			If FindFunction("ISPDA") .and. IsPDA()
				nTop := 0
				nLeft := 0
				nBottom := PDABOTTOM
				nRight  := PDARIGHT
			EndIf

			// Build com correção no tratamento dos controles pendentes na dialog ao executar o método End()
			If GetBuild() >= "7.00.060302P"
				bEndDlg := {|lOk| If(lOk:=oDlg:End(),nOpcA:=1,nOpcA:=3), lOk}
			EndIf

			DEFINE MSDIALOG oDlg TITLE cCadastro FROM nTop,nLeft TO nBottom,nRight PIXEL OF oMainWnd
			If lMaximized <> NIL
				oDlg:lMaximized := lMaximized
			EndIf


			If FindFunction("ISPDA") .and. IsPDA()
				aPosEnch := {,,,}
				oEnc01:= MsMGet():New( cAlias, nReg, nOpc, aCRA,"CRA",oemtoansi(STR0005),aAcho, aPosEnch , aCpos, , , ,cTudoOk,,lF3,lVirtual,.t.,,,,,,,,cTela) //"Quanto ?inclus„o?"
				oEnc01:oBox:align := CONTROL_ALIGN_ALLCLIENT
			Else
				aPosEnch := {,,,}
				oEnc01:= MsMGet():New( cAlias, nReg, nOpc, aCRA,"CRA",oemtoansi(STR0005),aAcho, aPosEnch , aCpos, , , ,cTudoOk,,lF3,lVirtual,,,,,,,,,cTela) //"Quanto ?inclus„o?"
				oEnc01:oBox:align := CONTROL_ALIGN_ALLCLIENT
			Endif

			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela).And.Eval(bOk).And.Eval(bOk2,nOpc),Eval(bEndDlg),(nOpcA:=3,.f.))},{|| nOpcA := 3,oDlg:End()},,aButtons)

		ElseIf lPanelFin .OR. lFlat

			DEFINE MSDIALOG ___oDlg OF oFather:oWnd FROM 0, 0 TO 0, 0 PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP )

			aPosEnch := {,,,}
			oEnc01:= MsMGet():New( cAlias, nReg, nOpc, aCRA,"CRA",oemtoansi(STR0005),aAcho,aPosEnch,aCpos,,,,cTudoOk,___oDlg,lF3,lVirtual,.F.,,,,,,,,cTela) //"Quanto ?inclus„o?"
			oEnc01:oBox:Align := CONTROL_ALIGN_ALLCLIENT

			bEndDlg := {|lOk| If(lOk:=___oDlg:End(),nOpcA:=1,nOpcA:=3), lOk}

			// posiciona dialogo sobre a celula
			___oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])

			ACTIVATE MSDIALOG ___oDlg  ON INIT FaMyBar(___oDlg,{|| If(Obrigatorio(aGets,aTela).And.Eval(bOk).And.Eval(bOk2,nOpc),Eval(bEndDlg),(nOpcA:=3,.f.))},{|| nOpcA := 3,___oDlg:End()},aButtons)

			(cAlias)->(MsGoto( nReg ) )

		EndIf

		If lF3  // Esta na conpad, desabilita o trigger por execblock
			SetEntryPoint(.f.)
		EndIf
	Else
		If EnchAuto(cAlias,aAuto,{|| Obrigatorio(aGets,aTela).And.Eval(bOk).And.Eval(bOk2,nOpc)},nOpc,aCpos)
			nOpcA := 1
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Gravacao da enchoice                                 ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcA == 1
		Begin Transaction
			RecLock(cAlias,.T.)
			For nX := 1 TO FCount()
				If "_FILIAL"$FieldName(nX)
					FieldPut(nX,xFilial(cAlias))
				Else
					FieldPut(nX,M->&(EVAL(bCampo,nX)))
				EndIf
			Next nX
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//³Grava os campos Memos Virtuais         ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			If Type("aMemos") == "A"
				For nX := 1 to Len(aMemos)
					cVar := aMemos[nX][2]
					//Incluído parametro com o nome da tabela de memos => para módulo APT
					cAliasMemo := If(len(aMemos[nX]) == 3,aMemos[nX][3],Nil)
					MSMM(,TamSx3(aMemos[nX][2])[1],,&cVar,1,,,cAlias,aMemos[nX][1],cAliasMemo)
				Next nX
			EndIf
			While ( GetSX8Len() > nLenSX8 )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Confirma a numeracao com a verificacao do numero gravado ativado  ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ConfirmSx8()
			EndDo
			If cTransact != Nil
				If !("("$cTransact)
					cTransact+="()"
				EndIf
				&cTransact
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//?Processamento de codeblock dentro da transacao                    ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			If !Empty(aParam)
				Eval(aParam[3],nOpc)
			EndIf
		End Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//?Processamento de codeblock fora da transacao                      ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		If !Empty(aParam)
			Eval(aParam[4],nOpc)
		EndIf
	Else
		While ( GetSX8Len() > nLenSX8 )
			RollBackSX8()
		EndDo
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Restaura a integridade dos dados                                  ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If aSvRot != Nil
		aRotina := aClone(aSvRot)
	EndIf
	RestArea(aArea)
	lRefresh := .T.

	If lPanelFin
		FinVisual(cAlias,uArea,(cAlias)->(Recno()))
	Endif
Return(nOpcA)

Static Function GetRBTFields(lCodigo)
	Local aRbtHeader 	:= {}
	Local aReturn		:= {}
	Local aNoFields		:= {"RBT_FILIAL","RBT_STATUS","RBT_RESPON"}

	If !lCodigo
		AAdd(aNoFields, "RBT_CODMOV")
	EndIf

	aRbtHeader 			:= GdMontaHeader(	NIL				,;	//01 -> Por Referencia contera o numero de campos em Uso
											NIL				,;	//02 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Virtuais
											NIL				,;	//03 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Visuais
											"RBT"			,;	//04 -> Opcional, Alias do Arquivo Para Montagem do aHeader
											aNoFields		,;	//05 -> Opcional, Campos que nao Deverao constar no aHeader
											.F.				,;	//06 -> Opcional, Carregar Todos os Campos
											.F.			 	,;	//07 -> Nao Carrega os Campos Virtuais
											.F.				,;	//08 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
											NIL				,;	//09 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
											.T.				,;	//10 -> Verifica se Deve Checar se o campo eh usado
											.T.				,;	//11 -> Verifica se Deve Checar o nivel do usuario
											.F.				 ;	//12 -> Utiliza Numeracao na GhostCol
						  	 			)

	Aeval(aRbtHeader, {|X| AADD(aReturn,x[2])})

Return aReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºPrograma  ³TCFA040   ºAutor  ³Marcelo Faria       ?Data ? 13/06/12   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ?Prepara dados para integracao									  º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Function TCF040Prep(dDataIni,nDuracao,oModSRF,nDiasAb,lFerAbono,lMeuRH)

Local nX     := 0
Local aDtFer := {}

DEFAULT nDiasAb   := 0
DEFAULT lFerAbono := .F.
DEFAULT lMeuRH    := .F.

If lMeuRH
	If Empty(oModSRF:GetValue("RF_PERC13S")) .And. nPer13S > 0
		nPer13S := MIN(nPer13S, 100)
		oModSRF:LoadValue("RF_PERC13S", nPer13S)
	EndIf

	aDtFer := {}
	aAdd( aDtFer, { dDataIni, nDuracao, nDiasAb  } )

	If !Empty(SRF->RF_DATAINI)
		aAdd( aDtFer, { SRF->RF_DATAINI, SRF->RF_DFEPRO1, SRF->RF_DABPRO1 } )
	EndIf
	If !Empty(SRF->RF_DATINI2)
		aAdd( aDtFer, { SRF->RF_DATINI2, SRF->RF_DFEPRO2, SRF->RF_DABPRO2 } )
	EndIf

	aSort( aDtFer,,, { |x,y| x[1] < y[1] } )	

	For nX := 1 To Len(aDtFer)
		If nX == 1
			oModSRF:LoadValue("RF_DATAINI",aDtFer[nX,1])
			oModSRF:LoadValue("RF_DFEPRO1",aDtFer[nX,2])
			If (lFerAbono)
				oModSRF:LoadValue("RF_DABPRO1",aDtFer[nX,3])
			EndIf
		ElseIf nX == 2
			oModSRF:LoadValue("RF_DATINI2",aDtFer[nX,1])
			oModSRF:LoadValue("RF_DFEPRO2",aDtFer[nX,2])
			If (lFerAbono)
				oModSRF:LoadValue("RF_DABPRO2",aDtFer[nX,3])
			EndIf
		Else
			oModSRF:LoadValue("RF_DATINI3",aDtFer[nX,1])
			oModSRF:LoadValue("RF_DFEPRO3",aDtFer[nX,2])
			If (lFerAbono)
				oModSRF:LoadValue("RF_DABPRO3",aDtFer[nX,3])
			EndIf
		EndIf
	Next nX
Else
	//Inicializa M->SRF
	IF Empty(SRF->RF_DATAINI)
		oModSRF:LoadValue("RF_DATAINI",dDataIni)
		oModSRF:LoadValue("RF_DFEPRO1",nDuracao)
		If (lFerAbono)
			oModSRF:LoadValue("RF_DABPRO1",nDiasAb)
		EndIf
		aCPosPortal	:=	{"RF_FERCOLE","RF_TEMABPE","RF_ABOPEC","RF_DATABAS","RF_DFERANT","RF_DFERVAT","RF_DFERAAT","RF_PERC13S","RF_PAR13AT","RF_DVENPEN","RF_IVENPEN","RF_FVENPEN","RF_DFALVAT","RF_DFALAAT"}
	ElseIf Empty(SRF->RF_DATINI2)
		oModSRF:LoadValue("RF_DATINI2",dDataIni)
		oModSRF:LoadValue("RF_DFEPRO2",nDuracao)
		If (lFerAbono)
			oModSRF:LoadValue("RF_DABPRO2",nDiasAb)
		EndIf
		aCPosPortal	:=	{"RF_FERCOLE","RF_TEMABPE","RF_ABOPEC","RF_DATABAS","RF_DFERANT","RF_DFERVAT","RF_DFERAAT","RF_PERC13S","RF_PAR13AT","RF_DVENPEN","RF_IVENPEN","RF_FVENPEN","RF_DFALVAT","RF_DFALAAT"}
	ElseIf Empty(SRF->RF_DATINI3)
		oModSRF:LoadValue("RF_DATINI3",dDataIni)
		oModSRF:LoadValue("RF_DFEPRO3",nDuracao)
		If (lFerAbono)
			oModSRF:LoadValue("RF_DABPRO3",nDiasAb)
		EndIf
		aCPosPortal	:=	{"RF_FERCOLE","RF_TEMABPE","RF_ABOPEC","RF_DATABAS","RF_DFERANT","RF_DFERVAT","RF_DFERAAT","RF_PERC13S","RF_PAR13AT","RF_DVENPEN","RF_IVENPEN","RF_FVENPEN","RF_DFALVAT","RF_DFALAAT"}
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºPrograma  ³GetNmRH3  ºAutor  ³Emerson Campos      ?Data ? 27/09/12   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ?Retorna o nome do Funcionário no SRA ou para candidato     º±?
±±?         ?Externo o conteudo salvo na posicao 3 da tabela RH4 que    º±?
±±?         ?contém o nome salvo no Curriculo                           º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±?Uso      ?X3_INIBRW                                                  º±?
±±?         ?GetNmRH3(RH3_CODIGO, RH3->RH3_MAT, RH3_TIPO)               º±?
±±?         ?X3_RELACAO 												  º±?
±±?         ?IF(INCLUI, "",GetNmRH3(RH3_CODIGO, RH3->RH3_MAT, RH3_TIPO))º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Function GetNmRH3(cCodRH3, cCodMat, cTipo)
	Local aArea	:= GetArea()
	Local cNome
		If Empty(cCodMat) .AND. cTipo == "H" //Candidato externo
			dbSelectArea("RH4")
			RH4->(DbSetOrder(1))
			RH4->(dbSeek(xFilial("RH4")+cCodRH3+'  3'))
			cNome	:= STR0035+RH4->RH4_VALNOV //"(Cand. Externo) - "
		Else
			cNome	:= FDesc("SRA", cCodMat, "RA_NOME", ,xFilial("SRA",RH3->RH3_FILIAL), 1)
		EndIf
	RestArea(aArea)
Return cNome

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºPrograma  ³ViewCurricºAutor  ³Emerson Campos      ?Data ? 01/10/12   º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ?Retorna o currículo cadastro no SQG do funcionário ou do   º±?
±±?         ?Candidato Externo                                          º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±?Uso      ?TCFA040                                                    º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Function ViewCurric(oModel)
	Local oModRH3   	:= oModel:GetModel("TCFA040_RH3")
	Local oModRH4   	:= oModel:GetModel("TCFA040_RH4")
	Local nOrdRH4 := RetOrdem( "RH4" , "RH4_FILIAL+RH4_CODIGO+STR(RH4_ITEM,3,0)" )
	Local nOrdSRA := RetOrdem( "SRA" , "RA_FILIAL+RA_MAT" )
	Local nOrdSQG := ''

	Private cCadastro 	:= OemToAnsi(STR0041) //"Curriculos"

	If Empty(oModRH3:GetValue("RH3_MAT")) //Candidato Externo
		DbSelectArea("RH4")
		RH4->(DbSetOrder(nOrdRH4))
		If RH4->(DbSeek(xFilial("RH4")+oModRH3:GetValue("RH3_CODIGO")+'  2'))
			nOrdSQG := RetOrdem( "SQG" , "QG_FILIAL+QG_CURRIC" )
			DbSelectArea("SQG")
			SQG->(DbSetOrder(nOrdSQG))

			If SQG->(DbSeek(xFilial("SQG")+RH4->RH4_VALNOV))
				RSP010Rot("SQG", SQG->(Recno()), 2)
			Else
				Alert(STR0042)	//Não h?currículo cadastrado.
			EndIf
		Else
			Alert(STR0043)	//'Não foi possível localizar o currículo cadastrado'
		EndIf
	Else  //Funcionarios
		DbSelectArea("SRA")
		SRA->(DbSetOrder(nOrdSRA))
		If SRA->(DbSeek(xFilial('SRA')+oModRH3:GetValue("RH3_MAT")))
			nOrdSQG := RetOrdem( "SQG" , "QG_FILIAL+QG_CIC" )
			DbSelectArea("SQG")
			SQG->(DbSetOrder(nOrdSQG))

			If SQG->(DbSeek(xFilial("SQG")+SRA->RA_CIC))
				RSP010Rot("SQG", SQG->(Recno()), 2)
			Else
				Alert(STR0042)	//Não h?currículo cadastrado.
			EndIf
		Else
			Alert(STR0043)	//'Não foi possível localizar o currículo cadastrado'
		EndIf
	EndIf
Return .T.


Function AtuRH4(oModRH3, aAltRH4)
	Local aSaveArea	:= GetArea()
	Local nTamRH4	:= 0
	Local nI		:= 0
	Local nItem		:= 1
	Local nCampo	:= 2
	Local nValNov	:= 3
	Local cCodRH3	:= Str(Alltrim(oModRH3:GetValue("RH3_CODIGO")), TamSX3("RH3_CODIGO")[2], 0)
	Local cCodFil	:= Str(AllTrim(oModRH3:GetValue("RH3_FILIAL")), TamSX3("RH3_FILIAL")[2], 0)
	/***************************************************************
	*aAltRH4	:= {                                               *
	*			     {RH4_ITEM   - Item do Campo a ser alterado},; *
	*			     {RH4_CAMPO  - Nome do Campo a ser alterado},; *
	*                {RH4_VALNOV - Valor do campo a ser alterado}  *
	*              }                                               *
	* Ex.:
	* aAltRH4 := {{'6','TMP_SITUAC','3'}}
	***************************************************/
	If ValType(aAltRH4) == "A"
		nTamRH4	:= Len(aAltRH4)

		dbSelectArea("RH4")
		RH4->(DbSetOrder(1))

		For nI := 1 To nTamRH4

			If RH4->(dbSeek(cCodFil+cCodRH3+STR(AllTrim(aAltRH4[nI,nItem]),TamSX3("RH4_ITEM")[2],0)))
				RecLock("RH4",.F.)
					Replace &("AllTrim(aAltRH4[nI,nCampo])")	WITH AllTrim(aAltRH4[nI,nValNov])
				MsUnlock()
			EndIf
		Next nI
	EndIf

	RestArea(aSaveArea)
Return Nil


Function fCapturaHistorico( lMeuRH, lLote )

	Local bOk     	:= {||lRet := .T., oDlg:End()}
	Local bCancel 	:= {||oDlg:End()}
	Local lRet   	:= .F.
	Local cTitulo 	:= STR0063
	Local oDlg
	Local oMemo
	Local oChkBox

	DEFAULT lMeuRH := .F.
	DEFAULT lLote := .F.

	If lMeuRH
		cTitulo := STR0139 //"Motivo da Rejeição"
	EndIf

	Begin Sequence
		DEFINE FONT oFont NAME "Arial" SIZE 0,-9 BOLD
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 9,0 TO 20,60                  //'Historico de Movimento'

		//****************************************************************
		@ 040,005 SAY STR0064 OF oDlg PIXEL                                   //'Observacao:'
		@ 040,040 MSGET oMemo VAR cOBS SIZE 180,10 OF oDlg PIXEL PICTURE "@#"
		If !lMeuRH
			@ 063,005 SAY STR0065 OF oDlg PIXEL FONT oFont                         //'Maximo 250 caracteres!'
		Else
			@ 063,005 SAY STR0157 OF oDlg PIXEL FONT oFont                         //'Maximo 50 caracteres!'
		EndIf

		If lLote
			@ 063, 150 CHECKBOX oChkBox VAR lJustifica PROMPT STR0159 SIZE 100, 10 OF oDlg PIXEL // "Usar nas demais solicitações"
		EndIf

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, bOk, bCancel)

	End Sequence

Return lRet

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³ValidTipPos³Autor³Equipe RH                  ³Data?1/10/2013?
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Validar tipo de posto                                        ?
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ?Vide Parametros Formais>                                    ?
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros?Vide Parametros Formais>                                    ?
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³TCFA040                                                      ?
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function ValidTipPos( cFilRCL, cCodPos )

Local aArea := GetArea()
Local lRet  := .T.

dbSelectArea("RCL")
dbSetOrder(RetOrder("RCL", "RCL_FILIAL+RCL_POSTO"))
RCL->(dbSeek(cFilRCL + cCodPos))

If RCL->RCL_TPOSTO == "1"
    If !MsgYesNo( OemToAnsi(STR0059) + CRLF + OemToAnsi(STR0060), OemToAnsi(STR0058) ) //"O Posto Origem ?Individual, após a aprovação ele se tornar?Genérico!"##"Deseja continuar?"##"Atenção"
        lRet := .F.
    EndIf
EndIf

Restarea(aArea)

Return( lRet )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³ValTab  ³Autor³Renan Borges                 ³Data?5/08/2014?
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Validar modos de acesso das tabelas.                         ?
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ?Vide Parametros Formais>                                    ?
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros?Vide Parametros Formais>                                    ?
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³TCFA040                                                      ?
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function ValTab()

Local aArea := GetArea()
Local lRet  := .T.

	IF !( ValidArqPon() )
		lRet := .F.
	EndIF

	IF !( xRetModo("SRA","RH3",.T.) )
		lRet := .F.
	EndIF

	IF !( xRetModo("SRA","RH4",.T.) )
		lRet := .F.
	EndIF

	IF !( xRetModo("SRA","RGK",.T.) )
		lRet := .F.
	EndIF

Restarea(aArea)

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±?
±±ºPrograma  ³CargaGrid  ºAutor  ³Flavio Correa      ?Data ? 09/01/2017 º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ³Carrega RH4												  º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºUso       ³SIGAGPE                                                     º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?*/
Static Function CargaGrid(oGrid)
Local aRet 			:= {}
Local aRet2			:= {}
Local nX			:= 0
Local nPosVal		:= oGrid:GetIdField("RH4_VALNOV")
Local nPosCampo		:= oGrid:GetIdField("RH4_CAMPO")
Local cCampo		:= ""

aRet2 := FormLoadGrid(oGrid)
For nX:= 1 to Len(aRet2)
	cCampo := Alltrim(aRet2[nX][2][nPosCampo])
	If cCampo == "RB7_TPALT"
		aRet2[nX][2][nPosVal] := Alltrim(aRet2[nX][2][nPosVal]) + " - " + FDESC("SX5","41"+aRet2[nX][2][nPosVal],"X5DESCRI()")
	ElseIf cCampo == "RB7_FUNCAO"
		dbSelectArea("SRJ")
		aRet2[nX][2][nPosVal] := Alltrim(aRet2[nX][2][nPosVal]) + " - " + FDESC("SRJ",aRet2[nX][2][nPosVal],"RJ_DESC")
	ElseIf cCampo == "RB7_CARGO"
		dbSelectArea("SQ3")
		aRet2[nX][2][nPosVal] := Alltrim(aRet2[nX][2][nPosVal]) + " - " +  FDESC("SQ3",aRet2[nX][2][nPosVal],"Q3_DESCSUM")
	ElseIf cCampo == "TMP_OBS"
		aRet2[nX][2][nPosVal] := StrTran(aRet2[nX][2][nPosVal], Chr(10), " ")
		aRet2[nX][2][nPosVal] := StrTran(aRet2[nX][2][nPosVal], Chr(13), " ")
	Endif
	aAdd(aRet,aClone(aRet2[nX]))
Next

Return aRet

/*/{Protheus.doc} VldOutBen
	Realiza a validação da solicitação de subsídio acadêmico para evitar chave duplicada na tabela RI1
	@type  Static Function
	@author Cícero Alves
	@since 28/03/2019
	@version 12.1.17
	@return lRet, Lógico, Verdadeiro caso o registro seja válido, falso caso j?exista uma benefício com a mesma chave cadastrado
*/
Static Function VldOutBen()

	Local oModel 	:= FWLoadModel("TCFA040")
	Local oModRH4	:= oModel:GetModel("TCFA040_RH4")
	Local cFilFunc, cMatFunc, cTipo, cCodBen, dDataIni, dDataFim
	Local cAliasRI1 := GetNextAlias()
	Local lRet		:= .T.
	Local nTamMat	:= GetSX3Cache("RA_MAT", "X3_TAMANHO")

	If GetRPORelease() < "12.1.025" // Apenas para versões anteriores a 12.1.25
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()

		cTipo := "83" // Subsídio acadêmico
		oModRH4:GoLine(1)  // Filial
		cFilFunc := SubStr(oModRH4:GetValue("RH4_VALNOV"), 1, FWGETTAMFILIAL)
		oModRH4:GoLine(2)  // Matricula
		cMatFunc := SubStr(oModRH4:GetValue("RH4_VALNOV"), 1, nTamMat)
		oModRH4:GoLine(4)  // Código do benefício
		cCodBen := SubStr(oModRH4:GetValue("RH4_VALNOV"), 1, 2)
		oModRH4:GoLine(9)  // Inicio
		dDataIni := cToD(oModRH4:GetValue("RH4_VALNOV"))
		oModRH4:GoLine(10) // Final
		dDataFim := cToD(oModRH4:GetValue("RH4_VALNOV"))

		BeginSQL Alias cAliasRI1

			COLUMN RI1_DINIPG AS DATE
			COLUMN RI1_DFIMPG AS DATE

			SELECT RI1_BENEF, RI1_TABELA, RI1_DINIPG, RI1_DFIMPG
			FROM %table:RI1% RI1
			WHERE RI1_FILIAL = %Exp: cFilFunc% AND
			RI1_MAT = %Exp: cMatFunc% AND
			RI1_BENEF = %Exp: cTipo% AND
			RI1.%NotDel%

		EndSQL

		While !(cAliasRI1)->(Eof())
			If (cAliasRI1)->RI1_TABELA == cCodBen
				lRet := .F.
				// Atenção # O funcionário j?possui esse benefício
				// Para aprovar essa solicitação ?necessário antes excluir esse benefício na rotina de atualização de outros benefícios.
				Help(,, STR0007,, STR0136, 1, 0, ,,,,, {STR0137})
			EndIf
			(cAliasRI1)->(dbSkip())
		EndDo

		(cAliasRI1)->(dbCloseArea())

	EndIf

Return lRet

/*/{Protheus.doc} fAprovPon
Realiza a aprovacao das solicitacoes de marcacoes do Portal e do MeuRH.
@author:	Marcelo Silveira
@since:		25/06/2019
@param:		cFilSRA - Filial;
			cMatSRA - Matricula;
			cCodRH3 - Codigo da solicitacao;
			cMsg - Mensagens de erro durante a geracao da marcacao;
			cAviso - Mensagens de erro durante a geracao da marcacao;
			lUpdRH3 - Se atualiza o status da requisicao marcando como aprovado;
			lIntRob - Verifica se foi chamado pela interface para Automação
@return:	nRet - Retorna zero (0) quando a operacao foi realizada com sucesso
/*/
Function fAprovPon( cFilSRA, cMatSRA, cCodRH3, cMsg, cAviso, lUpdRH3, lIntRob )

Local aArea      := getArea()
Local aTabCalend := {}
Local cFilMat    := ""
Local cMat       := ""
Local dData      := ""
Local nHora      := ""
Local cMotivo    := ""
Local cTipoReg   := ""
Local cLatitu    := ""
Local cLongit    := ""
Local cAliasQry  := ""
Local cRH3Status := "2"
Local cRS3Status := "1"
Local dPerIni 	 := cToD("//")
Local dPerFim    := cToD("//")
Local nRet       := 0
Local nX         := 0
Local nPos       := 0
Local aMarcDia   := {}
Local aMarcOrd   := {}
Local lGeolocal  := SP8->(ColumnPos("P8_LATITU")) > 0 .And. SP8->(ColumnPos("P8_LONGIT")) > 0
Local lNoMcIgual := SuperGetMv("MV_MCIGUAL",,"N",cFilSRA) == "N"
Local nDespMin	 := Min( __Min2Hrs( Val( SuperGetMv("MV_DESPMIN",NIL,"0") ) ) , 0.59 )
Local lDespMin	 := !(nDespMin == 0)

DEFAULT cMsg     := ""
DEFAULT cAviso	 := ""
DEFAULT lUpdRH3  := .F.
DEFAULT	lIntRob	 := .F.

DbSelectArea("SRA")
DbSetOrder(1)
If SRA->( DbSeek( cFilSRA + cMatSRA) )

	cAliasQry := GetNextAlias()

	BeginSql alias cAliasQry
		SELECT * FROM %table:RH4% RH4
		WHERE RH4.RH4_FILIAL = %exp:cFilSRA% AND RH4.RH4_CODIGO = %exp:cCodRH3% AND RH4.%notDel%
	EndSql

	While !(cAliasQry)->(Eof())
		Do Case
			Case Alltrim((cAliasQry)->RH4_CAMPO) == "P8_FILIAL"
				cFilMat  := SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('P8_FILIAL')[1])
			Case Alltrim((cAliasQry)->RH4_CAMPO) == "P8_MAT"
				cMat     := SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('P8_MAT')[1])
			Case Alltrim((cAliasQry)->RH4_CAMPO) == "P8_DATA"
				dData    := STOD( SubSTR( (cAliasQry)->RH4_VALNOV, 7, 4 ) + SubSTR( (cAliasQry)->RH4_VALNOV, 4, 2 ) + SubSTR( (cAliasQry)->RH4_VALNOV, 1, 2 ) )
			Case Alltrim((cAliasQry)->RH4_CAMPO) == "P8_HORA"
				nHora    := Val(StrTran((cAliasQry)->RH4_VALNOV,":","."))
			Case Alltrim((cAliasQry)->RH4_CAMPO) == "P8_MOTIVRG"
				cMotivo  := Alltrim((cAliasQry)->RH4_VALNOV)
			Case Alltrim((cAliasQry)->RH4_CAMPO) == "P8_LATITU"
				cLatitu  := Alltrim((cAliasQry)->RH4_VALNOV)
			Case Alltrim((cAliasQry)->RH4_CAMPO) == "P8_LONGIT"
				cLongit  := Alltrim((cAliasQry)->RH4_VALNOV)
		EndCase
		(cAliasQry)->(dbskip())
	Enddo

	(cAliasQry)->( DbCloseArea() )

	/* 	Busca o período do ponto de acordo com a data da marcação
		Em casos de batidas geolocalizadas, a data da marcação pode ser superior à data do período do ponto aberto.
		Caso o período de apontamento não fique conforme a data da marcação, o campo P8_DATAAPO não será preenchido
		E o fechamento mensal do ponto eletronico ficará incorreto.
	*/
	PerAponta( @dPerIni , @dPerFim , dData , .F. , cFilMat , .T. , .F., , , .T. )

	aMarcacoes := Array( 01 , Array( ELEMENTOS_AMARC ) )
	aTabCalend := {}

	cTipoReg := If( Empty(cLatitu), "I", "O" )	  //Batida de geolocalizacao tem Flag de marcacao original
	cMotivo	 := If( Empty(cLatitu), cMotivo, "" ) //Batida de Geolocalizacao nao precisa de motivo porque tem Flag de original

	aMarcacoes[ 01 , AMARC_DATA    	] := dData
	aMarcacoes[ 01 , AMARC_HORA    	] := nHora
	aMarcacoes[ 01 , AMARC_MOTIVRG	] := cMotivo
	aMarcacoes[ 01 , AMARC_ORDEM   	] := Space( GetSx3Cache( "P8_ORDEM" , "X3_TAMANHO" ) )		//03 - Ordem da Marcacao
	aMarcacoes[ 01 , AMARC_FLAG    	] := "P"													//04 - Flag (Origem) da Marcacao
	aMarcacoes[ 01 , AMARC_RECNO   	] := 0														//05 - Recno
	aMarcacoes[ 01 , AMARC_TURNO   	] := Space( GetSx3Cache( "P8_TURNO" , "X3_TAMANHO" ) )		//06 - Turno da Marcacao (Sera Carregado na PutOrdMarc())
	aMarcacoes[ 01 , AMARC_FUNCAO  	] := Space( GetSx3Cache( "P8_FUNCAO" , "X3_TAMANHO" ) )		//07 - Funcao do Relogio
	aMarcacoes[ 01 , AMARC_GIRO    	] := Space( GetSx3Cache( "P8_GIRO" , "X3_TAMANHO" ) )		//08 - Giro do Relogio
	aMarcacoes[ 01 , AMARC_CC      	] := SRA->RA_CC												//09 - Centro de Custo da Marcacao
	aMarcacoes[ 01 , AMARC_APONTA  	] := "N"													//10 - Flag de Marcacao Apontada
	aMarcacoes[ 01 , AMARC_RELOGIO	] := Space( GetSx3Cache( "P8_RELOGIO" , "X3_TAMANHO" ) )	//11 - Relogio da Marcacao
	aMarcacoes[ 01 , AMARC_TIPOMARC	] := Space( GetSx3Cache( "P8_TPMARCA" , "X3_TAMANHO" ) )	//12 - Flag de Tipo de Marcacao
	aMarcacoes[ 01 , AMARC_L_ORIGEM	] := .F.													//13 - Define Se a Marcacao Pode ou Nao ser (Re)Ordenada
	aMarcacoes[ 01 , AMARC_PERAPONTA] := Space( GetSx3Cache( "P8_PAPONTA" , "X3_TAMANHO" ) )	//15 - String de Data com o Periodo de Apontamento
	aMarcacoes[ 01 , AMARC_DATAAPO	] := ctod("//")					  							//25 - Data de Apontamento
	aMarcacoes[ 01 , AMARC_NUMREP	] := ""							   							//26 - Numero do REP
	aMarcacoes[ 01 , AMARC_TPMCREP	] := Space(01)					   							//27 - Tipo de Marcacao no REP
	aMarcacoes[ 01 , AMARC_TIPOREG	] := cTipoReg												//28 - Tipo de Registro
	aMarcacoes[ 01 , AMARC_EMPORG	] := ""							   							//31 - Empresa Origem da marcacao
	aMarcacoes[ 01 , AMARC_FILORG	] := ""		       				   							//32 - Filial Origem da marcacao
	aMarcacoes[ 01 , AMARC_MATORG	] := ""														//33 - Matricula Origem da marcacao
	aMarcacoes[ 01 , AMARC_DHORG	] := ""														//34 - Data/Hora Origem da marcacao
	aMarcacoes[ 01 , AMARC_IDORG	] := ""							   							//35 - Identificacao da Origem da marcacao

	If lGeolocal
		aMarcacoes[ 01 , AMARC_LATITU	] := cLatitu	//36 - Latitude (marcacao geolocalizacao)
		aMarcacoes[ 01 , AMARC_LONGIT	] := cLongit	//37 - Longitude (marcacao geolocalizacao)
	EndIf

	If !lIntRob .And. (dData < dPerIni .Or. If( dData > dPerFim, fChkNextPer(cFilSRA, dData, cLatitu, cLongit), .F. ) )
		nRet := 2
	Else
		//Cria calendario para a data
		CriaCalend(		dPerIni	 	,;	//01 -> Data Inicial do Calendario
						dPerFim		,;	//02 -> Data Final do Calendario
						NIL			,;	//03 -> Turno de Trabalho
						NIL			,;	//04 -> Sequencia de Turno
						NIL			,;	//05 -> Tabela de Horario Padrao
						@aTabCalend	,;	//06 -> Calendario de Marcacoes
						cFilMat    	,;	//07 -> Filial do Funcionario
						cMat   		,;	//08 -> Matricula do Funcionario
						NIL   		,;	//09 -> Centro de Custo do Funcionario
						NIL			,;	//10 -> Array com as Trocas de Turno
						NIL			,;	//11 -> Array com Todas as Excecoes do Periodo
						NIL			,;	//12 -> Se executa Query para a Montagem da Tabela Padrao
						.T.			,;	//13 -> Se executa a funcao se sincronismo do calendario
						NIL			 ;	//14 -> Se Forca a Criacao de Novo Calendario
					);

		If lUpdRH3

			//Identifica as marcacoes do dia para realizar a classificacao
			GetMarcacoes(	@aMarcDia			,;	//01 -> Marcacoes do Funcionario
							aTabCalend			,;	//02 -> Calendario de Marcacoes
							NIL					,;	//03 -> Tabela Padrao
							NIL     			,;	//04 -> Turnos de Trabalho
							dPerIni				,;	//05 -> Periodo Inicial
							dPerFim				,;	//06 -> Periodo Final
							SRA->RA_FILIAL		,;	//07 -> Filial
							SRA->RA_MAT			,;	//08 -> Matricula
							SRA->RA_TNOTRAB		,;	//09 -> Turno
							SRA->RA_SEQTURN		,;	//10 -> Sequencia de Turno
							SRA->RA_CC			,;	//11 -> Centro de Custo
							"SP8"				)

			For nX := 1 To Len(aMarcDia)
				If aMarcDia[nX,1] == dData

					//Valida se a batida esta duplicada conforme MV_MCIGUAL
					If lNoMcIgual .And. Str(aMarcDia[nX,2]) == Str(nHora)
						aMarcacoes[ 1, AMARC_TPMCREP ] := "D"
						aMarcacoes[ 1, AMARC_MOTIVRG ] := STR0154 //"Excluida automaticamente via MEURH. Motivo: batida duplicada"

					//Verifica se esta dentro do Intervalo definido em MV_DESPMIN
					ElseIf lDespMin .And. (__Min2Hrs( DataHora2Val( aMarcDia[nX,1], aMarcDia[nX,2], dData, nHora ) ) <= nDespMin)
						aMarcacoes[ 1, AMARC_TPMCREP ] := "D"
						aMarcacoes[ 1, AMARC_MOTIVRG ] := STR0155 //"Excluida automaticamente via MEURH. Motivo: batida dentro do limite minimo entre duas batidas."
					EndIf

					Aadd(aMarcOrd, aMarcDia[nX])
				EndIf
			Next nX

			If aMarcacoes[ 1, AMARC_TPMCREP ] == "D"
				cRH3Status := "3" //Reprovado - Tabela RH3
				cRS3Status := "3" //Reprovado automaticamente - Tabela RS3
			EndIf

			Aadd(aMarcOrd, aMarcacoes[1]) //Adiciona a marcacao da batida por geolocalizacao

			PutOrdMarc( @aMarcOrd , aTabCalend ) //Ordena todas as batidas do dia

			//Identifica a batida que sera incluida
			nPos := aScan( aMarcOrd, {|x| 	x[AMARC_DATA] == aMarcacoes[1,AMARC_DATA] .And. ;
											x[AMARC_HORA] == aMarcacoes[1,AMARC_HORA] .And. ;
											x[AMARC_TPMCREP] == aMarcacoes[1,AMARC_TPMCREP] } )

			//Grava a marcação por geolocalizacao ja classificada
			If nPos > 0
				/* -- IMPORTANTE.
					O MV_PAPONTA pode ser preenchido de duas formas.
					1 - AAAMMDD/AAAMMDD Ex: 20201001/20201031
					2 - DD/DD			Ex: 01/31
					Caso o parametro estiver com AAAMMDD/AAAMMDD e for uma marcação futura, o aMarcOrd posição 25 estará vazio
					Caso o parametro estiver com DD/DD e for uma marcação futura, o aMarcOrd posição 25 estará preenchido com a data do prox período..

					Se a posição 25 do aMarcOrd não estiver vazia, pode ser;
					tanto uma marcação dentro do período quanto uma marcação futura utilizando o MV_PAPONTA com DD/DD
				*/
				If !Empty(aMarcOrd[nPos,AMARC_DATAAPO])
					//Verifica se existe bloqueio de tabelas devido ao fechamento, considerando o período da batida.
					If !Pn090Open(@cMsg, @cAviso,.T.,DtoS(dPerIni) + DtoS(dPerFim))
						RestArea(aArea)
						Return( 1 )
					EndIf
				EndIf
			EndIf
			PutMarcacoes( { aMarcOrd[nPos] }, cFilMat, cMat, "SP8", .F. )
		Else
			//Ordena as marcacoes
			PutOrdMarc( @aMarcacoes , aTabCalend)

			//Verifica se existe bloqueio de tabelas devido ao fechamento, considerando o período da batida.
			If !Pn090Open(@cMsg, @cAviso,.T.,DtoS(dPerIni) + DtoS(dPerFim))
				RestArea(aArea)
				Return( 1 )
			EndIf

			//Grava a marcação
			PutMarcacoes( aMarcacoes, cFilMat, cMat, "SP8", .T. )
		EndIf

		//Atualiza a RS3
		DbSelectArea("RS3")
		DbSetOrder(1)
		If DbSeek( cFilSRA + cCodRH3 )
			RecLock("RS3",.F.)
			RS3->RS3_STATUS := cRS3Status
			MsUnlock()
		EndIf

		If lUpdRH3
			DbSelectArea("RH3")
			DbSetOrder(1)
			If RH3->( DbSeek( cFilSRA + cCodRH3) )
				RecLock("RH3",.F.)
				RH3->RH3_STATUS := cRH3Status
				RH3->RH3_DTATEN := dDataBase
				MsUnlock()
			EndIf
		EndIf

	EndIf

EndIf

RestArea(aArea)

// Fecho as tabelas do fechamento do ponto abertas
Pn090Close()

Return( nRet )


/*/{Protheus.doc} fChkNextPer
Verifica se a batida por geolocalizao esta sendo feita fora do proximo periodo
@author:	Marcelo Silveira
@since:		19/07/2019
@param:		dData - Filial;
			cLatitu - Latitude;
			cLongit - Longitude
@return:	lRet - Retorna verdadeiro (.T.) caso a data da batida seja em data superior ao proximo periodo
/*/
Static Function fChkNextPer( cBranchVld, dData, cLatitu, cLongit )

	Local dDataIni 	:= cTod("//")
	Local dDataFim 	:= cTod("//")
	Local lRet		:= .T.

	DEFAULT cLatitu := ""
	DEFAULT cLongit := ""

	//Somente batidas por geolocalizacao poderao ser feitas dentro do proximo periodo
	//Demais batidas serao aprovadas somente se estiverem dentro do periodo aberto do ponto
	If Empty(cLatitu) .Or. Empty(cLongit)
		lRet := .T.
	Else
		GetPonMesDat( @dDataIni, @dDataFim, cBranchVld )
		GetPerNext( @dDataIni, @dDataFim, , ,.F. )
		lRet := !(dData >= dDataIni .And. dData <= dDataFim)
	EndIf

Return lRet

Function GetMemoRDY(CODCON)
    Local cObs := ""

    cObs := ApdMsMM(CODCON)
Return cObs

Function GetNomeSRA(cFilMat,cMatric)
    Local cNome := ""

    SRA->(dbSetOrder(1))
    If SRA->(dbSeek(cFilMat+cMatric))
        If !empty(SRA->RA_NOMECMP)
           cNome := SRA->RA_NOMECMP
        Else
           cNome := SRA->RA_NOME
        ENDIf
    EndIF
Return cNome


/*/{Protheus.doc} AtendeLote
Interface que permite selecionar diversas solicitações para aprovação ou rejeição
@type  Static Function
@author Cícero Alves
@since 29/01/2021
@see (links_or_references)
/*/
Function AtendeLote()

	Local aArea			:= GetArea()
	Local cFilAux		:= cFilAnt
	Local aColsMark		:= {}
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local bAprova		:= {|| If(AprovLote(), oDlgMark:End(), )}
	Local bReprova		:= {|| If(AprovLote(.T.), oDlgMark:End(), )}
	Local lMarcar		:= .F.
	Local oCombo
	Local oTela
	Local cIdCab
	Local cIdGrid
	Local oPanelUp
	Local oPanelDown
	Local oGroup

	Private oTmpTable   := NIL
	Private cAliasMark 	:= GetNextAlias()
	Private oDlgMark	:= NIL

	// Variáveis utilizadas no Filtro
	Private cFilRH3		:= Space( GetSx3Cache("RH3_FILIAL", "X3_TAMANHO"))
	Private cTipoSoli	:= Space(Len(StrTran(GetTipos(.F.), "/", "")))
	Private cOrigem		:= Space( GetSx3Cache("RH3_ORIGEM", "X3_TAMANHO"))
	Private dPerIni		:= CtoD("  /  /    ")
	Private dPerFim		:= CtoD("  /  /    ")
	Private lJustifica	:= .F.

	fCriaTmp()

	DbSelectArea(cAliasMark)

	SET FILTER TO TAB_FIL == ''

	aColsMark:= fMntColsMark()

	aAdvSize	:= MsAdvSize( .F., .F., 370)
	aInfoAdvSize	:= { aAdvSize[1], aAdvSize[2], aAdvSize[3], aAdvSize[4], 5, 15 }

	aAdd( aObjCoords, { 000, 000, .T., .T. } )

	aObjSize := MsObjSize( aInfoAdvSize, aObjCoords)

	DEFINE MsDialog oDlgMark FROM aAdvSize[7], 0 To aAdvSize[6], aAdvSize[5] TITLE STR0158 PIXEL // "Atender em Lote"

	// Cria o conteiner onde serão colocados os paineis
	oTela     := FWFormContainer():New( oDlgMark )
	cIdCab	  := oTela:CreateHorizontalBox( 15 )
	cIdGrid   := oTela:CreateHorizontalBox( 85 )

	oTela:Activate( oDlgMark, .F. )

	//Cria os paineis onde serao colocados os browses
	oPanelUp  	:= oTela:GeTPanel( cIdCab )
	oPanelDown  := oTela:GeTPanel( cIdGrid )

		@ 5, aObjSize[1, 2]	GROUP oGroup TO 50, aObjSize[1, 4] LABEL STR0160 OF oPanelUp PIXEL // "Filtro"

		@ (aObjSize[1, 1] * 0.5) + 10, aObjSize[1, 2] + 5 SAY OemToAnsi(GetSx3Cache("RH3_FILIAL", "X3_TITULO")) SIZE 038, 007 OF oPanelUp PIXEL
		@ (aObjSize[1, 1] * 0.5) + 18, aObjSize[1, 2] + 5 MSGET cFilRH3 SIZE 012, 010 OF oPanelUp PIXEL F3 'SM0' HASBUTTON VALID TCF40VldMark(.T.)

		@ (aObjSize[1, 1] * 0.5) + 10, aObjSize[1, 2] + 80 SAY OemToAnsi(GetSx3Cache("RH3_TIPO", "X3_TITULO")) SIZE 038, 007 OF oPanelUp PIXEL
		@ (aObjSize[1, 1] * 0.5) + 18, aObjSize[1, 2] + 80 MSGET cTipoSoli SIZE 012, 010 OF oPanelUp PIXEL HASBUTTON VALID (fTipoOpc(@cTipoSoli), TCF40VldMark())

		@ (aObjSize[1, 1] * 0.5) + 10, aObjSize[1, 2] + 160 SAY OemToAnsi(GetSx3Cache("RH3_ORIGEM", "X3_TITULO")) SIZE 038, 007 OF oPanelUp PIXEL
		@ (aObjSize[1, 1] * 0.5) + 18, aObjSize[1, 2] + 160	MSCOMBOBOX oCombo VAR cOrigem ITEMS {"","1=PORTAL","2=MEURH"} SIZE 050, 010 OF oPanelUp PIXEL ON CHANGE TCF40VldMark()

		@ (aObjSize[1, 1] * 0.5) + 10, aObjSize[1, 2] + 240 SAY STR0161 SIZE 038, 007 OF oPanelUp PIXEL // Data Inicial
		@ (aObjSize[1, 1] * 0.5) + 18, aObjSize[1, 2] + 240	MSGET dPerIni SIZE 050, 010	OF oPanelUp PIXEL HASBUTTON VALID TCF40VldMark()

		@ (aObjSize[1, 1] * 0.5) + 10, aObjSize[1, 2] + 320 SAY STR0162 SIZE 038, 007 OF oPanelUp PIXEL // "Data Final"
		@ (aObjSize[1, 1] * 0.5) + 18, aObjSize[1, 2] + 320	MSGET dPerFim SIZE 050, 010 OF oPanelUp PIXEL HASBUTTON VALID TCF40VldMark()

	oMark := FWMarkBrowse():New()

	oMark:SetAlias((cAliasMark))
	oMark:SetFields(aColsMark)

	//Indica o container onde sera criado o browse
	oMark:SetOwner(oPanelDown)

	oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar ), oMark:Refresh(.T.) }

	// Define o campo que sera utilizado para a marcação
	oMark:SetFieldMark( 'TAB_OK')
	oMark:SetValid({||.T.})

	oMark:SetFilterDefault("TAB_TIPO $ '" + GetTipos(.F.) + "'" )

	oMark:SetMenuDef("")
	oMark:AddButton("Aprovar",  bAprova,,,, .F., 2 ) // Aprovar
	oMark:AddButton("Reprovar", bReprova,,,, .F., 2 ) // Reprovar

	// A tabela já está filtrada, a legenda é apenas para deixar vizual para o usuário
	oMark:AddLegend('.T.',  "BLUE", STR0009) //"Aguardando Efetivacao RH"

	oMark:Activate()

	ACTIVATE MSDIALOG oDlgMark CENTERED

	oTmpTable:Delete()
	oTmpTable := Nil

	cFilAnt := cFilAux
	RestArea(aArea)

Return


/*/{Protheus.doc} fCriaTmp
Cria tabela temporária utilizada na tela de aprovação em lote
@type  Static Function
@author Cícero Alves
@since 29/01/2021
/*/
Static Function fCriaTmp()

	Local aColumns	:= {}
	Local cAliasRH3	:= GetNextAlias()
	Local cRH3Emp	:= "%'','" + cEmpAnt + "'%"

	If Select(cAliasMark) > 0
		DbSelectArea(cAliasMark)
		(cAliasMark)->(DbCloseArea())
	EndIf

	aAdd( aColumns, { "TAB_OK"		, "C", 02, 00 })
	aAdd( aColumns, { "TAB_FIL"		, "C", TAMSX3("RH3_FILIAL")[1], TAMSX3("RH3_FILIAL")[2] })
	aAdd( aColumns, { "TAB_COD"		, "C", TAMSX3("RH3_CODIGO")[1], TAMSX3("RH3_CODIGO")[2]})
	aAdd( aColumns, { "TAB_MAT"		, "C", TAMSX3("RH3_MAT")[1],    TAMSX3("RH3_MAT")[2]})
	aAdd( aColumns, { "TAB_NOME"	, "C", TAMSX3("RH3_NOME")[1],   TAMSX3("RH3_NOME")[2]})
	aAdd( aColumns, { "TAB_TIPO"	, "C", TAMSX3("RH3_TIPO")[1],   TAMSX3("RH3_TIPO")[2]})
	aAdd( aColumns, { "TAB_DESC"	, "C", TAMSX3("RH3_TPDESC")[1], TAMSX3("RH3_TPDESC")[2]})
	aAdd( aColumns, { "TAB_ORIGEM"	, "C", TAMSX3("RH3_ORIGEM")[1], TAMSX3("RH3_ORIGEM")[2]})
	aAdd( aColumns, { "TAB_DTSOLI"	, "D", 8, 0})
	aAdd( aColumns, { "TAB_DTDEM"	, "D", 8, 0})
	aAdd( aColumns, { "TAB_RECNO"	, "N", 15, 0})

	oTmpTable := FWTemporaryTable():New(cAliasMark)
	oTmpTable:SetFields( aColumns )
	oTmpTable:AddIndex( "IND", { "TAB_FIL", "TAB_TIPO", "TAB_COD" } )
	oTmpTable:Create()

	BeginSQL Alias cAliasRH3

		COLUMN RH3_DTSOLI AS DATE

		SELECT RH3_FILIAL, RH3_CODIGO, RH3_MAT, RH3_TIPO, RH3_ORIGEM, RH3_DTSOLI, R_E_C_N_O_ as RECNO
		FROM %Table:RH3% RH3
		WHERE RH3.RH3_STATUS = '4' AND
			RH3.RH3_EMP IN (%exp:cRH3Emp%) AND
			RH3.%NotDel%

	EndSQL

	While (cAliasRH3)->(!EoF())

		RecLock(cAliasMark, .T.)
		(cAliasMark)->TAB_FIL 		:= (cAliasRH3)->RH3_FILIAL
		(cAliasMark)->TAB_COD 		:= (cAliasRH3)->RH3_CODIGO
		(cAliasMark)->TAB_MAT 		:= (cAliasRH3)->RH3_MAT
		(cAliasMark)->TAB_NOME 		:= Posicione("SRA", 1, xFilial("SRA", (cAliasRH3)->RH3_FILIAL) + (cAliasRH3)->RH3_MAT, "RA_NOME")
		(cAliasMark)->TAB_TIPO		:= (cAliasRH3)->RH3_TIPO
		(cAliasMark)->TAB_DESC		:= Posicione('SX5', 1, xFilial('SX5') + 'JQ' + (cAliasRH3)->RH3_TIPO, 'X5DESCRI()')
		(cAliasMark)->TAB_ORIGEM	:= (cAliasRH3)->RH3_ORIGEM
		(cAliasMark)->TAB_DTSOLI	:= (cAliasRH3)->RH3_DTSOLI
		(cAliasMark)->TAB_DTDEM		:= Posicione("SRA", 1, (cAliasRH3)->RH3_FILIAL + (cAliasRH3)->RH3_MAT, "RA_DEMISSA")
		(cAliasMark)->TAB_RECNO		:= (cAliasRH3)->RECNO

		(cAliasRH3)->(dbSkip())
	EndDo

	(cAliasRH3)->(dbCloseArea())

Return


/*/{Protheus.doc} fMntColsMark
Preenche o aCols utilizado no browser da tela de aprovação em lote
@type  Static Function
@author Cícero Alves
@since 29/01/2021
@return aColsAux, Array, aCols preenchido com as informações da tabela temporária
/*/
Static Function fMntColsMark()

	Local aArea			:= GetArea()
	Local aColsAux 		:= {}
	Local aColsSX3		:= {}
	Local aCampos  		:= { "RH3_FILIAL", "RH3_CODIGO", "RH3_MAT", "RH3_NOME", "RH3_TIPO", "RH3_TPDESC", "RH3_DTSOLI", "RA_DEMISSA" }
	Local aDados		:= { { || (cAliasMark)->TAB_FIL }, { || (cAliasMark)->TAB_COD }, { || (cAliasMark)->TAB_MAT }, { || (cAliasMark)->TAB_NOME }, { || (cAliasMark)->TAB_TIPO }, { || (cAliasMark)->TAB_DESC }, { || (cAliasMark)->TAB_DTSOLI }, { || (cAliasMark)->TAB_DTDEM } }
	Local nX			:= 0

	DbSelectArea("SX3")
	DbSetOrder(2)

	For nX := 1 to Len(aCampos)
		If SX3->( dbSeek(aCampos[nX]) )
			aColsSX3 := {X3Titulo(), aDados[nX], SX3->X3_TIPO, SX3->X3_PICTURE, 1, SX3->X3_TAMANHO, SX3->X3_DECIMAL, .F.,,,,,,,, 1}
			aAdd(aColsAux, aColsSX3)
			aColsSX3 := {}
		EndIf
	Next nX

	RestArea(aArea)

Return aColsAux

/*/{Protheus.doc} TCF40VldMark
Aplica os filtros informados na tela na tabela temporária e atualiza o browser
@type  Static Function
@author Cícero Alves
@since 29/01/2021
@version version
@param lAtuFil, Lógico, Define se foi alterado o filtro de filial
@return --, Lógico, Sempre verdadeiro pois a função é chamada no Valid dos campos
/*/
Static Function TCF40VldMark(lAtuFil)

	Local cFilAux		:= ""

	DEFAULT lAtuFil := .F.

	If lAtuFil .and. !Empty(cFilRH3)
		cFilRH3 := xFilial("RH3", cFilRH3)
	EndIf

	DbSelectArea(cAliasMark)
	SET FILTER TO

	SetMarkAll(oMark:Mark(), .F. )
	oMark:Refresh()

	DbSelectArea(cAliasMark)

	If !Empty(cFilRH3)
		cFilAux := "TAB_FIL == '" + cFilRH3 + "'"
	EndIf

	If !Empty(cTipoSoli)
		cFilAux += if(!Empty(cFilAux), " .And. TAB_TIPO $ '" + cTipoSoli, "TAB_TIPO $'" + cTipoSoli ) + "'"
	Else
		cFilAux += if(!Empty(cFilAux), " .And. TAB_TIPO $'" + GetTipos(.F.), "TAB_TIPO $ '" + GetTipos(.F.)) + "'"
	Endif

	If !Empty(cOrigem)
		If cOrigem == "1"
			cFilAux += if(!Empty(cFilAux), " .And. AllTrim(TAB_ORIGEM) == 'PORTAL'", "AllTrim(TAB_ORIGEM) == 'PORTAL'")
		Else
			cFilAux += if(!Empty(cFilAux), " .And. AllTrim(TAB_ORIGEM) == 'MEURH'", "AllTrim(TAB_ORIGEM) == 'MEURH'")
		EndIf
	EndIf

	If !Empty(dPerIni)
		cFilAux += if(!Empty(cFilAux), " .And. DToS(TAB_DTSOLI) >= '" + DToS(dPerIni) + "'", "DToS(TAB_DTSOLI) >= '" + DToS(dPerIni) + "'")
	EndIf

	If !Empty(dPerFim)
		cFilAux += if(!Empty(cFilAux), " .And. DToS(TAB_DTSOLI) <= '" + DToS(dPerFim) + "'", "DToS(TAB_DTSOLI) >= '" + DToS(dPerFim) + "'")
	EndIf

	SET FILTER TO &cFilAux

	oMark:GoTop(.T.)
	oMark:Refresh()

Return .T.

/*/{Protheus.doc} GetTipos
Retorna os tipos de solicitação de acordo com o módulo
@type  Static Function
@author Cícero Alves
@since 29/01/2021
@param lCliente, Lógico, Define se serão considerados os tipo de solicitação customizados
@return cTipos, Caracter, Tipos de solicitação do módulo separados por /
/*/
Static Function GetTipos(lCliente)

	Local cTipos	:= ""

	Default lCliente := .T.

	Do Case
		Case cModulo == "GPE"
			If cPaisLoc == "BRA" .AND. msFile("XAM" + cEmpAnt + "0")
				cTipos := "X/B/7/6/4/2/1/V/"
			Else
				cTipos := "B/7/6/4/2/1/V/"
			EndIf
		Case cModulo == "RSP"
			If cPaisLoc == "BRA" .AND. msFile("XAM" + cEmpAnt + "0")
				cTipos := "X/9/5/2/1/H/"
			Else
				cTipos := "9/5/2/1/H/"
			EndIf
		Case cModulo == "TRM"
			cTipos := "A/2/1/"
		Case cModulo == "ORG"
			cTipos := "3/2/1/"
		Case cModulo == "PON"
			cTipos := "8/Z/"
		Case cModulo == "VDF"
			If cPaisLoc == "BRA" .AND. msFile("XAM" + cEmpAnt + "0")
				cTipos := "N/O/P/Q/R/S/T/"
			Else
				cTipos := "X/N/O/P/Q/R/S/T/"
			EndIf
		Otherwise
			cTipos := ""
	EndCase

	If !(cVerGSP $ "2/3") .And. cModulo == "GPE"
		cTipos += "R/"
	EndIf

	If lCliente
		// Tipos de solicitações customizados
		cTipos += cTpUser
	EndIf

Return cTipos

/*/{Protheus.doc} SetMarkAll
Marca ou desmarca todos os registros da markBrowser na tela de aprovação em lote
@type  Static Function
@author Cícero Alves
@since 29/01/2021
@param cMarca, Caracter, Marca utilizada no oMark
@param lMarcar, Lógico, Define se a ação será de Marcar ou Desmarcar
@return --, Lógico, Sempre Verdadeiro
/*/
Static Function SetMarkAll(cMarca, lMarcar )

	Local aAreaMark  := (cAliasMark)->( GetArea() )

	dbSelectArea(cAliasMark)
	(cAliasMark)->( dbGoTop() )

	While !(cAliasMark)->( Eof() )
		RecLock( (cAliasMark), .F. )
		(cAliasMark)->TAB_OK := IIf( lMarcar, cMarca, '  ' )
		MsUnLock()
		(cAliasMark)->( dbSkip() )
	EndDo

	RestArea( aAreaMark )

Return .T.

/*/{Protheus.doc} fTipoOpc
Monta a tela com as opções de tipos de solicitação utilizado no filtro da tela de aprovação em lote
@type  Static Function
@author Cícero Alves
@since 02/02/2021
@param cTipoSoli, Caracter, Variável com o conteúdo do campo - Deve ser passado por referência
@return --, Lógico, Sempre verdadeiro pois a função é chamada no valid do campo
/*/
Static Function fTipoOpc(cTipoSoli)

	Local cOpcoes	:= GetTipos()
	Local aTiposDes	:= {}
	Local nI

	cOpcoes := StrTran(cOpcoes, "/", "")

	For nI := 1 To Len(cOpcoes)
		aAdd(aTiposDes, Posicione('SX5', 1, xFilial('SX5') + 'JQ' + SubStr(cOpcoes, nI, 1), 'X5DESCRI()'))
	Next

	f_Opcoes(	@cTipoSoli	,;	//Variavel de Retorno
				STR0163		,;	//Titulo da Coluna com as opcoes # Tipos
				aTiposDes	,;	//Opcoes de Escolha (Array de Opcoes)
				cOpcoes		,;	//String de Opcoes para Retorno
				NIL			,;	//Nao Utilizado
				NIL			,;	//Nao Utilizado
				.F.			,;	//Se a Selecao sera de apenas 1 Elemento por vez
				1			,;	//Tamanho da Chave
				Len(cOpcoes),;	//No maximo de elementos na variavel de retorno
				.T.			,;	//Inclui Botoes para Selecao de Multiplos Itens
				.F.			,;	//Se as opcoes serao montadas a partir de ComboBox de Campo ( X3_CBOX )
				NIL			,;	//Qual o Campo para a Montagem do aOpcoes
				.T.			,;	//Nao Permite a Ordenacao
				.T.			,;	//Nao Permite a Pesquisa
				.F.   		,;	//Forca o Retorno Como Array
				NIL			 ;	//Consulta F3
			)

	cTipoSoli := StrTran(cTipoSoli, "*", "")

Return .T.

/*/{Protheus.doc} AprovLote
Aprova ou rejeita as solicitações selecionadas
@type  Static Function
@author Cícero Alves
@since 02/02/2021
@param lrejeita, Lógico, .T. as solicitações serão aprovadas - .F. as solicitações serão rejeitadas
/*/
Static Function AprovLote(lrejeita)

	Local cMarca	:= oMark:Mark()
	Local cTipoAnt	:= "*"
	Local aLogAux	:= {}
	Local lPrimeiro	:= .T.
	Local lRet		:= .F.
	Local nOrd1RH4  := RetOrdem( "RH4", "RH4_FILIAL+RH4_CODIGO+STR(RH4_ITEM,3,0)" )

	Default lrejeita := .F.

	Private aLog 	   := {}
	Private aLogTitulo := {}

	DbSelectArea(cAliasMark)
	(cAliasMark)->(DbGoTop())

	While (cAliasMark)->(!Eof())

		If oMark:IsMark(cMarca)
			If lPrimeiro .And. !lrejeita
				MsgAlert(STR0164, STR0007 ) // "Para alguns tipos de solicitação será aberta a rotina relacionada para efetivação do cálculo ou revisão das informações."
				lPrimeiro := .F.
			EndIf
			aAdd(aLog, (cAliasMark)->( TAB_FIL + " - " + TAB_MAT + " - " + TAB_NOME ))
			DbSelectArea("RH3")
			RH3->(dbGoto((cAliasMark)->TAB_RECNO))
//			DbSelectArea("RH4")
//			RH4->(DbSetOrder(nOrd1RH4))
//			RH4->(dbSeek(xFilial("RH4", RH3->RH3_FILIAL) + RH3->RH3_CODIGO ))
			If lrejeita
				TCFA040Rejeita(.T.)
			Else
				TCFA040Atende(.T.)
			EndIf

			If (cAliasMark)->TAB_TIPO != cTipoAnt
				aAdd(aLogTitulo, STR0165 + (cAliasMark)->TAB_TIPO + " - " + (cAliasMark)->TAB_DESC ) // "Solicitações "
				cTipoAnt := (cAliasMark)->TAB_TIPO
			EndIf

			aAdd(aLogAux, alog)
			alog := {}

		EndIf

		(cAliasMark)->(DbSkip())
	EndDo

	If Empty(aLogTitulo)
		MsgAlert(STR0166, STR0007 ) // "Nenhuma solicitação selecionada"
		lRet := .F.
	Else
		fMakeLog( aLogAux, aLogTitulo,,,,,, "P")
		lRet := .T.
	EndIf

	oMark:Refresh(.T.)

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} fBuscaSRA
Funcao responsavel por montar a tela da consulta especifica de funcionarios.

@author		Silvio C. Stecca
@since		23/09/2021
@version	1.0
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data         Programador          Motivo
/*/
//------------------------------------------------------------------
Function fBuscaSRA()

	local oOrdem	:= Nil
	Local oChave	:= Nil
	Local oTmpTbl1	:= Nil
	Local i			:= 0
	Local j			:= 0
	Local nOpca		:= 0
	Local cChave	:= Space(255)
	Local cAreaSRA	:= SRA->(GetArea())
	Local cFilsSRA	:= ""

	Private oLbx		:= Nil
	Private oDlg2		:= Nil
	Private cOrdIx		:= ""
	Private nOrdem		:= 1
	Private aIndices	:= {}
	Private cTRB		:= GetNextAlias()

	Static cMatFunRet	:= ""

	aDbf := {	{"CODFIL"  , "C",  TamSX3("RA_FILIAL")[1]	,  TamSX3("RA_FILIAL")[2]}	, ;
				{"CODMAT"  , "C",  TamSX3("RA_MAT")[1]		,  TamSX3("RA_MAT")[2]}		, ;
			 	{"NOME"    , "C",  TamSX3("RA_NOME")[1]		,  TamSX3("RA_NOME")[2]}	}

	// INSTANCIA CLASSE FWTemporaryTable
	oTmpTbl1 := FWTemporaryTable():New(cTRB, aDbf)

	// CRIA INDICES
	oTmpTbl1:AddIndex("Ind01", {"CODFIL"})
	oTmpTbl1:AddIndex("Ind02", {"CODMAT"})
	oTmpTbl1:AddIndex("Ind03", {"NOME"})

	// CRIA A TABELA TEMPORARIA.
	oTmpTbl1:Create()

	cAliasQry := GetNextAlias()

	If !Empty(MV_PAR08)
		cFilsSRA += MV_PAR08
	EndIf

	If !Empty(MV_PAR11)
		cFilsSRA += Iif(!Empty(cFilsSRA), + "/" + MV_PAR11, MV_PAR11)
	EndIf

	cFilsSRA := Iif(Empty(cFilsSRA), xFilial("SRA"), cFilsSRA)

	cQuery := " SELECT RA_FILIAL, RA_MAT, RA_NOME "
	cQuery += " FROM " + RetSqlName("SRA")
	cQuery += " WHERE RA_DEMISSA = ' ' "
	cQuery += " AND RA_FILIAL  IN " + FormatIn(cFilsSRA, "/")+ ""
	cQuery += " AND D_E_L_E_T_ = '' "
	cQuery += " ORDER BY RA_FILIAL, RA_MAT "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,, cQuery), cAliasQry, .F., .T.)

	dbSelectArea((cAliasQry))
	dbGoTop()
	While !Eof()
		DbSelectArea(cTRB)
		RecLock((cTRB), .T.)
		(cTRB)->CODFIL := (cAliasQry)->RA_FILIAL
		(cTRB)->CODMAT := (cAliasQry)->RA_MAT
		(cTRB)->NOME   := (cAliasQry)->RA_NOME
		MsUnlock(cTRB)
		DbSelectArea((cAliasQry))
		DbSkip()
	EndDo

	(cAliasQry)->(DbCloseArea())

	cLine	:= "{ || { "
	i		:= 0
	aAux	:= {}
	aLbx	:= {}

	// MONTA OS DADOS DO LISTBOX
	dbSelectArea(cTRB)
	aFields := DbStruct()
	aCabec  := {STR0170, STR0171, STR0172} //Filial##"Matrícula"###"Nome"

	dbGotop()
	While !Eof()
		aAux := Array(Len(aFields))

		For j := 1 to Len(aFields)
			aAux[j] := &(aFields[j][1])
		Next j

		Aadd(aLbx, aAux)
		dbSkip()
	End

	// DEFINE O NUMERO DE COLUNAS DO LISTBOX
	For i := 1 To Len(aDbf)
		If aDbf[i][2] == "D"
			cLine += "DtoC(aLbx[oLbx:nAt," + Alltrim(Str(i, 2)) + "])"
		ElseIf aDbf[i][2] == "N"
			cLine += "Str(aLbx[oLbx:nAt," + Alltrim(Str(i, 2)) + "])"
		Else
			cLine += "aLbx[oLbx:nAt," + Alltrim(Str(i, 2)) + "]"
		EndIf

		If i#Len(aDbf)
			cLine += ","
		Else
			cLine += "}"
		EndIf
	Next i

	cLine	+= "}"
	nGuarda := 1

	aAdd(aIndices, STR0170)	// "Filial"
	aAdd(aIndices, STR0171) // "Matrícula"
	aAdd(aIndices, STR0172)	// "Nome"

	Define MsDialog oDlg2 Title STR0173 From 000, 000 To 421, 522 Pixel //"Funcionários"

	@ 005, 005 ComboBox oOrdem 		var cOrdIx items aIndices size 210, 08 PIXEL OF oDlg2 ON CHANGE nOrdem := oOrdem:nAt
	@ 020, 005 MsGet 	oChave 		var cChave size 210, 08 of oDlg2 pixel
	@ 005, 220 Button 	STR0174 of oDlg2 Size 40, 10 Pixel Action fPesqSRA(cChave, nOrdem) //"&Pesquisar"

	oLbx := TWBrowse():New(3, 0, 263, 149,, aCabec,, oDlg2,,,,,,,,,,,, .F.,, .F.,, .F.,,, )

	oLbx:SetArray(aLbx)
	bLbxLine := {||{Space(Len(SRA->RA_MAT)), Space(40)}}
	Iif(Len(aLbx) > 0, oLbx:bLine := &(cline), oLbx:bLine := bLbxLine)
	oLbx:nAt 		:= nGuarda
	oLbx:bLDblClick := {||(nOpcA := 1, nGuarda := oLbx:nAt, oDlg2:End())}

	Define sButton oBtOk  from 195, 05 type 1 action (nOpcA := 1, nGuarda := oLbx:nAt, oDlg2:End()) enable of oDlg2 pixel
	Define sButton oBtCan from 195, 36 type 2 action (nOpcA := 0, oDlg2:End()) enable of oDlg2 pixel

	ACTIVATE MSDIALOG oDlg2 CENTERED

	If nOpca == 1
		If Len(aLbx) > 0
			DbSelectArea("SRA")
			DbSetOrder(1)
			If DbSeek(aLbx[nGuarda][1] + aLbx[nGuarda][2] + aLbx[nGuarda][3])
				cMatFunRet := SRA->RA_MAT
			EndIf
		EndIf
	EndIf

	// DELETA O ARQUIVO TEMPORARIO.
	oTmpTbl1:Delete()

	RestArea(cAreaSRA)

Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} fRetSRA
Funcao responsavel por retornar a matricula a consulta realizada.

@author		Silvio C. Stecca
@since		23/09/2021
@version	1.0
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data         Programador          Motivo
/*/
//------------------------------------------------------------------
Function fRetSRA()

	Local cRetorno := ""

	If ValType( cMatFunRet ) == "C"
		cRetorno := cMatFunRet
	EndIf

Return cRetorno

//------------------------------------------------------------------
/*/{Protheus.doc} fPesqSRA
Funcao responsavel por retornar o registro selecionado.

@author		Silvio C. Stecca
@since		23/09/2021
@version	1.0
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data         Programador          Motivo
/*/
//------------------------------------------------------------------
Static Function fPesqSRA(cCHPesq, nOrdem)

	Local cSeek := ""
	Local nReg	:= 0

	dbSelectArea(cTRB)
	dbSetOrder(nOrdem)

	If nOrdem == 1
		cSeek := SubStr(cCHPesq, 1, TamSX3("RA_FILIAL")[1])
	ElseIf nOrdem == 2
		cSeek := SubStr(cCHPesq, 1, TamSX3("RA_MAT")[1])
	Else
		cSeek := Upper(SubStr(cCHPesq, 1, TamSX3("RA_NOME")[1]))
	EndIf

	dbSeek(cSeek, .T.)

	If !Eof()
		nReg := Recno()
	ElseIf Eof()
		nReg := Len(aLbx)
	Endif

	oLbx:SetFocus(aLbx[nReg])

	oLbx:nAt	:= nReg
	oLbx:bLine	:= &(cline)

Return .T.
