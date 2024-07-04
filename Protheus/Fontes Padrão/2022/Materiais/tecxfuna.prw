#INCLUDE "TECXFUNA.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PONCALEN.CH"

#DEFINE T_ENTIDADE		1
#DEFINE T_INDICE		2
#DEFINE T_CHAVE			3

Static cRetProd := ""
Static cRetSta := ""
Static lVldMsgAloc := .F.
Static lRetVldSub  := .T.
Static aCpoAA1		:= {}

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TxEntPerm()

Retorna as entidades permitidas para agendamento no sigatec, tabela ABB

@return ExpC: Entidades permitidas para agendamento. Ex: AB6|AB7|AAT
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TxEntPerm()

Return "AAT|AB6|AB7"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TxEntABB()

@param cEntidade Parametro Opcional. Código da Entidade de Agendamento (X2_CHAVE). Quando informado retornara apenas os dados daquela entidade.

Funcao utilizada para montar o array das entidades de agendamento do sigatec.
Retornara informacoes de indice e chava utilizada para todas as entidades que for permitido realizar agendamento via ABB

@return ExpA: Entidades de agendamento. Ex: aEntidad[1][T_ENTIDADE], aEntidad[1][T_INDICE], aEntidad[1][T_CHAVE]
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TxEntABB(cEntidade)
Local nX		:= 1
Local aEntPerm	:= StrTokArr(TxEntPerm(),"|")
Local aArea
Local aAreaSX2
Local aAreaSIX
Local nPos
Local aRet

Default cEntidade	:= ""

Static aEntidade	:= {} //Dados das Entidades

If Len(aEntidade) == 0
	aArea		:= GetArea()
	aAreaSX2	:= SX2->(GetArea())
	aAreaSIX	:= SIX->(GetArea())

	For nX := 1 To Len(aEntPerm)
		SIX->(DbSeek(aEntPerm[nX]))
		AAdd(aEntidade,{aEntPerm[nX],1,SIX->CHAVE}) //Ordem conforme defines
	Next nX

	RestArea(aAreaSX2)
	RestArea(aAreaSIX)
	RestArea(aArea)
EndIf

If !Empty(cEntidade) .AND. Len(aEntidade) > 0
	If (nPos := aScan(aEntidade,{|x| x[1] == cEntidade})) > 0
		aRet := aEntidade[nPos]
	EndIf
Else
	aRet := aEntidade
EndIf

Return aRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TxSeekEnt()

@param cTab Código da Entidade de Agendamento (X2_CHAVE)
@param cChave Chave da Tabela para posicionamento

Retorna Posiciona e retorna o registro da entidade de agendamento a partir da Entidade/Chave

@return ExpL:.T. para quando encontrar a chave na entidade, .F. para quando não encontrar

/*/
//--------------------------------------------------------------------------------------------------------------------
Function TxSeekEnt(cTab,cChave)
Local lRet		:= .F.
Local aArea		:= GetArea()
Local aEnt		:= TxEntABB(cTab)

If !EMPTY(cTab) .AND. !EMPTY(cChave)
	If Len(aEnt) > 0
		DbSelectArea(aEnt[T_ENTIDADE])
		DbSetOrder(aEnt[T_INDICE])
		lRet := DbSeek(xFilial(cTab)+cChave)
	EndIf
EndIf

RestArea(aArea)

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TXSelEnt()

Consulta Padrão especifica ABBENT do campo ABB_CHAVE - Aciona a Conpad Entidade + "ABB".
De acordo com a entidade escolhida na tabela ABB acionará a conpad adequada.
Exemplos:
Quando ABB_ENTIDA for preenchida com AAT, acionará a conpad AATABB.
Quando ABB_ENTIDA for preenchida com AB6 acionará conpad AB6ABB.

@return ExpL: Retornara .T. quando a chave for válida.

/*/
//--------------------------------------------------------------------------------------------------------------------
Function TXSelEnt(cVar)
Local lRet		:= .T.
Local cMVar		:= ReadVar()
Local nPosEnt
Local aArea		:= GetArea()
Local cVal
Local cTabela

Default cVar 	:= ""

SaveInter()

If Empty(cVar)
	cVar := TxGetVar("ABB_ENTIDA")
EndIf

If !Empty(cVar)
	cF3 := cVar+"ABB" //Conpad sempre será Entidade+ABB. Ex. AATABB

	DbSelectArea("SXB")
	SXB->(dbSetOrder(1))
	If SXB->(dbSeek(cF3+"1"))
		cTabela := Trim(SXB->XB_CONTEM)
	EndIf
	If SXB->(dbSeek(cF3+"5"))
		If Trim(SXB->XB_CONTEM) != ""
			cVal := Trim(SXB->XB_CONTEM)
		EndIf
		SXB->(DbSkip())
	EndIf

	lRet := Conpad1( NIL,NIL,NIL,cF3)
	If lRet
		&(cMVar) := PadR(&(cVal),TamSX3("ABB_CHAVE")[1])
	EndIf
Else
	Help(,,'HELP', 'TXSELENT', STR0042, 1, 0) //"É necessário Escolher uma Entidade de Agendamento para utilizar a consulta padrão."
EndIf

RestInter()

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TxVldChave()

Valida a Chave da Entidade de Agendamento. Uso: X3_VALID do campo ABB_CHAVE

@return ExpL: Retornara .T. quando a chave for válida.

/*/
//--------------------------------------------------------------------------------------------------------------------
Function TxVldChave(cChv,cVar,cNumOs,cMsgHlp)

Local lRet		:= .F.
Local aEnt		:= {}
Local aChv		:= {}
Local nX		:= 0
Local nPosEnt 	:= 0
Local aArea		:= GetArea()
Local aAreaEnt	:= {}
Local cChave	:= ""

Default cVar	:= ""
Default cChv	:= ""
Default cNumOs  := ""
Default cMsgHlp := STR0001 //"Item de Agendamento Inválido. O Item agendado deve ser correspondente à entidade escolhida."

//Quando vazio procura no M-> ou Acols ou Dicionario
If Empty(cVar)
	cVar := TxGetVar("ABB_ENTIDA")
EndIf

//Retorna os dados da Entidade
If VALTYPE(cVar) == 'C'
	aEnt := TxEntABB(Trim(cVar))
EndIf

If Len(aEnt) > 0	.AND. ValType(aEnt) == "A" .AND. ValType(aEnt[1]) != "A"
	aAreaEnt := &(aEnt[T_ENTIDADE]+"->(GetArea())")
	DbSelectArea(aEnt[T_ENTIDADE])
	DbSetOrder(aEnt[T_INDICE])

	If Empty(cChv)
		If ReadVar() == "M->ABB_CHAVE"
			cChv := &(ReadVar())
		Else
			aChv := StrTokArr(aEnt[T_CHAVE],"+")
			For nX := 2 To Len(aChv) //Todos menos filial
				cChv += &("ABB->"+aChv[nX])
			Next nX
		EndIf
	EndIf

	lRet := DbSeek(XFilial(aEnt[T_ENTIDADE])+RTrim(cChv))	//Busca pela chave informada

	// Quando cNumOs informado Valida se a O.S. bate com a chave
	If Trim(cNumOs) != ""
		lRet := (cNumOs == &(aEnt[T_ENTIDADE]+"->"+PrefixoCpo(aEnt[T_ENTIDADE])+"_NUMOS"))
	EndIf
	RestArea(aAreAEnt)
EndIf

If !lRet .AND. !Empty(cVar)
	Help(,,'HELP', 'TXVLDCHV', cMsgHlp, 1, 0)
ElseIf Empty(cVar)
	lRet := .T.
EndIf

RestArea(aArea)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TxGatNOS()

Funcao acionada pelo gatilho de ABB_CHAVE para retornar o número da Ordem de Serviço em ABB_NUMOS.

@return ExpC: Retorna o número da O.S. AB6_NUMOS para ABB_NUMOS
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TxGatNumOS()
Local cEnt
Local cRet := Space(TamSX3("ABB_NUMOS")[1])

cVar := TxGetVar("ABB_CHAVE")
cEnt := TxGetVar("ABB_ENTIDA")

If !Empty(cVar) .AND. cEnt $ "AB6|AB7" //Numero De O.S apenas para AB6 e AB7
	If TxSeekEnt(cEnt,cVar)
		If cEnt == "AB6"
			cRet := AB6->AB6_NUMOS
		Else
			cRet := AB7->AB7_NUMOS
		EndIf
	EndIf
EndIf

Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TxGetVar()

Retorna Varivel da ABB conforme escopo. Procura no model, em M->, Acols ou Tabela

@param cVar:Campo da abb. Ex: "ABB_ENTIDA" procura no model, em M->, Acols ou Tabela

@return ExpX: Retorna o Conteudo da Variavel da ABB com o Tipo da Variavel
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TxGetVar(cVar)
Local xRetVar
Local oModel	:= FwModelActive()
Local nPosChv	:= 0

If ValType(oModel) == "O"
	xRetVar := FwFldGet(cVar)
ElseIf Type("M->"+cVar) != "U"
	xRetVar := &("M->"+cVar)
ElseIf Type("aHeader") != "U" .AND. (nPosChv := aScan(aHeader,{|x| AllTrim(x[2])==cVar})) > 0
	If (nPosChv := aScan(aHeader,{|x| AllTrim(x[2])==cVar})) > 0
		xRetVar := &("aCols[N]["+cValToChar(nPosChv)+"]")
	EndIf
ElseIf Select("ABB") .AND. !Empty(&("ABB->"+cVar))
	xRetVar := &("ABB->"+cVar)
EndIf

Return xRetVar

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TxExistAloc()

Verifica se ja existe alocação na ABB para o Tecnico no Periodo Informado

@param ExpC:Codigo do Tecnico (ABB_CODTEC)
@param ExpD:Data Inicial (ABB_DTINI)
@param ExpC:Hora Inicial (ABB_HRINI)
@param ExpD:Data Final (ABB_DTFIM)
@param ExpC:Hora Final (ABB_HRFIM)
@param ExpN:Recno da ABB a ser Ignorado (Caso seja uma alteração, informe o recno para ignorar o proprio na consulta)
@param ExpC:Local de atendimento para busca
@param ExpÇ:Indica se irá considerar somente agendas ativas
@param ExpC:Local de destino da alocacao (OPCIONAL) para validar se for lugar efetivo e atual alocacao for RESERVA TECNICA
@return ExpL: Retorna .T. quando há alocação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TxExistAloc(cCodTec,dDtIni,cHrIni,dDtFim,cHrFim,nRecno,cLocal,lAtiva,cLocDestino,aRecno)
Local aOldArea	:= GetArea()
Local nX
Local cAlias		:= GetNextAlias()
Local lRet			:= .F.
Local aSM0 		:= FWArrFilAtu()
Local aFilPesq	:= {}
Local cFilPesq	:= ""
Local cExpConc	:= If(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","%ABB.ABB_DTINI||ABB.ABB_HRINI%","%ABB.ABB_DTINI+ABB.ABB_HRINI%") //Sinal de concatenação (Igual ao ADMXFUN)
Local cExpConcF	:= If(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","%ABB.ABB_DTFIM||ABB.ABB_HRFIM%","%ABB.ABB_DTFIM+ABB.ABB_HRFIM%") //Sinal de concatenação (Igual ao ADMXFUN)
Local cCompE		:= FWModeAccess("ABB",1)
Local cCompU		:= FWModeAccess("ABB",2)
Local cCompF		:= FWModeAccess("ABB",3)
Local cAgenAtiv 	:= '1'
Local cWhere		:= ""
Local cWhereABS	:= ""
Local cFiltroAge	:= ""
Local nI			:= 0

Default nRecno := 0
Default cLocal := ""
Default lAtiva := .T.
Default cLocDestino := ""
Default aRecno := {}

If !Empty (cLocal)
	cWhere := " AND ABB_LOCAL = '" + cLocal + "' "
Endif

If isInCallStack("At581Efet") .And. cHrFim < cHrIni
	dDtFim++
Endif
//Caso local de destino seja EFETIVO, e local da agenda seja RESERVA, nao considera como indisponivel
If !Empty(cLocDestino)
	dbSelectArea("ABS")
	ABS->(dbSetOrder(1))
	If ABS->(dbSeek(xFilial("ABS")+cLocDestino )) .And. ABS->ABS_RESTEC <> "1"
		cWhereABS += " AND ABS.ABS_RESTEC <> '1' "
	EndIf
EndIf

If !Empty(aRecno)
	cWhere += " AND ABB.R_E_C_N_O_ NOT IN ("
	For nI := 1 To Len(aRecno)
		If nI > 1
			cWhere +=","
		EndIf
		cWhere += "'"+Alltrim(CValToChar(aRecno[nI]))+"'"
	Next nI   
	if nRecno != 0 
		cWhere += ",'"+CValToChar(nRecno)+"'"  
	endif
	cWhere += ") "	
Else
	cWhere += " AND ABB.R_E_C_N_O_ NOT IN ('"+CValToChar(nRecno)+"') " 
EndIf

cWhereABS	:= "%"+ cWhereABS + "%"
cWhere		:= "%"+ cWhere + "%"

If lAtiva
	cFiltroAge := "%AND ABB.ABB_ATIVO = '"+cAgenAtiv+"'%"
Else
	cFiltroAge := "%%"
EndIf

If cCompE == 'C' .AND. cCompU == 'C' .AND. cCompF == 'C'
	cFilPesq := XFilial("ABB")
ElseIf cCompU == 'E'
	aFilPesq := FWAllFilial(aSM0[SM0_EMPRESA],aSM0[SM0_UNIDNEG])
ElseIf cCompE == 'E'
	aFilPesq := FWAllUnitBusiness(aSM0[SM0_EMPRESA])
EndIf

For nX := 1 To Len(aFilPesq)
	If nX > 1
		cFilPesq+="','"
	EndIf
	If cCompF == 'E'
		cFilPesq += aSM0[SM0_EMPRESA]+aSM0[SM0_UNIDNEG]+aFilPesq[nX]
	ElseIf cCompU == 'E'
		cFilPesq += aSM0[SM0_EMPRESA]+aSM0[SM0_UNIDNEG]+Space(Len(aFilPesq[nX]))
	ElseIf cCompE == 'E'
		cFilPesq += aSM0[SM0_EMPRESA]+Space(Len(aSM0[SM0_UNIDNEG]))+Space(Len(aSM0[SM0_FILIAL]))
	EndIf
Next nX

BeginSQL alias cAlias
	select COUNT(1) AS CT
	  from %table:ABB% ABB
	       left join %table:ABS% ABS ON ABS.%NotDel%
	                                AND ABS.ABS_FILIAL = %xFilial:ABS%
	                                AND ABS.ABS_LOCAL = ABB.ABB_LOCAL
	                                    %Exp:cWhereABS%
	 where ABB.%NotDel%
	       %Exp:cFiltroAge%
	   AND ABB.ABB_CODTEC = %exp:cCodTec%
	   AND ABB.ABB_FILIAL IN (%exp:cFilPesq%)
	   AND (
	         (%exp:dDtIni% > ABB.ABB_DTINI AND %exp:dDtIni% < ABB.ABB_DTFIM)
	         OR
	         (%exp:dDtFim% > ABB.ABB_DTINI AND %exp:dDtFim% < ABB.ABB_DTFIM)
	         OR
	         (ABB.ABB_DTINI > %exp:dDtIni% AND ABB.ABB_DTINI < %exp:dDtFim%)
	         OR
	         (ABB.ABB_DTFIM > %exp:dDtIni% AND ABB.ABB_DTFIM < %exp:dDtFim%)
	       	 OR 
			 (%exp:DTOS(dDtIni)+cHrIni% > %exp:cExpConc% AND %exp:DTOS(dDtIni)+cHrIni% < %exp:cExpConcF%)
       		 OR 
			 (%exp:DTOS(dDtFim)+cHrFim% > %exp:cExpConc% AND %exp:DTOS(dDtFim)+cHrFim% < %exp:cExpConcF%)
       		 OR 
			 (%exp:cExpConc% > %exp:DTOS(dDtIni)+cHrIni% AND %exp:cExpConc% < %exp:DTOS(dDtFim)+cHrFim%)
       		 OR 
			 (%exp:cExpConc% > %exp:DTOS(dDtIni)+cHrIni% AND %exp:cExpConc% < %exp:DTOS(dDtFim)+cHrFim%)
	   		)
	   %Exp:cWhere%
EndSQL

DbSelectArea(cAlias)
If (cAlias)->(!Eof()) .AND. (cAlias)->CT > 0
	lRet := .T.
EndIf
(cAlias)->(DbCloseArea())
RestArea(aOldArea)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TxPrefix()

A partir do campo retorna o prefixo da tabela, Ex. para A1_COD retorna SA1. Para ABB_CODTEC retorna ABB

@param ExpC:Campo. Ex. ABB_CODTEC

@return ExpC: Retorna a Tabela a qual o campo pertence
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TxPrefix(cCampo)
Local aParte := StrTokArr(cCampo,"_")
Local cRet	:= ""
If Len(aParte) == 2
	cRet := aParte[1]
	If Len(cRet) == 2
		cRet := "S"+cRet
	EndIf
EndIf
Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ListarApoio
Função para criar tabela temporária com registros de recursos do
Banco de Apoio para uso em rotinas do SIGATEC.

@sample 	ListarApoio( 	 dIniAloc, dFimAloc, aCargos, aFuncoes, aHabil, cDisponib,;
						 cContIni, cContFim, cCCusto, cLista, nLegenda, cItemOS,;
						 aTurnos, aRegiao, lEstrut, aPeriodos, cIdCfAbq, cLocOrc, aSeqTrn, aPeriodRes,cLocAloc  )

@param		dIniAloc	Data inicial do período de alocação.
			dFimAloc	Data final do período de alocação.
			cCargo		Cargo do recurso
			cFuncao	Função que será exercida.
			aCarac		Array com dados da Caracteristicas do local de atendimento
			aCursos		Array com dados do Cursos do local de atendimento
			aHabil		Array com dados da habilidade que deve ser filtrada.
						Integrado ao RH ([1]Habilidade - [2]Item da Escala
						Não integrado ao RH ([1]Habilidade - [2]Nível)
			cDisponib	Indica se deve filtrar apenas os recursos Disponíveis(D),
						apenas os Indisponíveis(I), Alocados(A) ou Todos(T)
			cContIni	Indica o contrato inicial para filtrar os recursos do mesmo
						Centro de Custo.
			cContFim	Indica o contrato final para filtrar os recursos do mesmo
						Centro de Custo.
			cCCusto	Indica um centro de custo para filtrar os recursos.
			cLista		Indica quais atendentes deverão ser listados.
						(1)Lista apenas Banco de Apoio (Atendentes não relacionados a um contrato)
						(2)Lista apenas Reserva Técnica (Atendentes relacionados ao contrato informado)
						(3)Lista Banco de Apoio e Reserva Técnica
						(4)Lista todos os atendentes do Banco de Apoio e Reserva técnica (Inclusive de outros contratos)
			nLegenda	Indica como será montada a legenda.
						(1) Legenda de alocação
						(2) Legenda de recursos alocados
			cItemOS	Item da OS para filtrar os atendentes alocados
			cTurno		Turno do atendente
			lEstrut	Indica se deve retornar apenas a estrutura
						(F) Consulta completa
						(T) Apenas a estrutura

			cIdCfAbq	Indica o relacionamento com a tabela ABQ
			cLocOrc	Local onde serão listados os atendentes
			aSeqTrn	Array com dados da Sequencia do turno a serem filtradas
			aPeriodRes Periodo a ser considerado quando consulta for por reserva Tecnica
			cLocalAloc Codigo do local de DESTINO caso seja informado, para consistir se existe uma efetivacao em periodo no qual o recurso estava alocado como RESERVA TECNICA

@return	aRet 		Array de 3 posições
			aRet[1]	Tabela temporária com Banco de Apoio
			aRet[2]	Índice da tabela temporária
			aRet[3]	Estrutura das colunas para uso com FwFormBrowse

@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function ListarApoio( dIniAloc, dFimAloc, aCargos, aFuncoes, aHabil, cDisponib,;
						 cContIni, cContFim, xCCusto, cLista, nLegenda, cItemOS,;
						 aTurnos, aRegiao, lEstrut, aPeriodos, cIdCfAbq, cLocOrc,;
						 aSeqTrn, aPeriodRes, cLocalAloc, aCarac, aCursos, cCodtec, dDtRef )

Local lRH 				:= SuperGetMv("MV_TECXRH",,.F.)
Local cAlias			:= GetNextAlias()
Local cTempTab		:= ''	   								//Tabela temporária criada
Local cTempIdx		:= ''	   								//indice da tabela temporária
Local cTempKey		:= ''									//Chave para o índice da tabela temporária
Local aCampos			:= {}									//Campos retornados na consulta
Local aColumns		:= {}									//Estrutura dos campos retornada de acordo com os campos em aCampos
Local aStructure		:= {}									//Estrutura da tabela para criação do arquivo temporário
Local nI				:= 1									//Contador de uso geral
Local cSim				:= UPPER(STR0036)								//Indica o sim de acordo com o idioma corrente
Local cNao				:= UPPER(STR0037)								//Indica o não de acordo com o idioma corrente
Local cFer				:= 'FER'								//Indica o não de acordo com o idioma corrente
Local cWhereDisp		:= ''									//Condição de filtro para os atendentes disponíveis
Local cWhereIndisp	:= ''									//Condição de filtro para os atendentes indisponíveis
Local cWhereABB		:= ''									//Condição para filtrar apenas agendamentos para um determinado Item da OS
Local cFiltroCC		:= '' 									//Condição de where da consulta para filtrar atendentes por Centro de Custo
Local nHabil			:= 0									//Indica qual a habilidade será usada, do RH ou do FieldService
Local cCCVazio		:= Space( TamSX3('AA1_CC')[1] )		//Cria campo de Centro de Custo vazio
Local aHabAtd 		:= {}									//Retorna as habilidades do atendente
Local aRegAtd			:= {}									//Retorna as regioes de atendimento do atendimento.
Local aRet				:= {}									//Array de retorno.
Local cTableAlias		:= ''
Local cAliasRBG		:= ''
Local cAliasRBLX		:= ''
Local cAliasRBI		:= ''
Local dDtIni			:= nil
Local dDtFim			:= nil
Local nX				:= 0
Local aEquipe 		:= {}
Local cAtend			:= ''
Local nPerc				:= 1
Local cReserva		:= "1"
Local cApoio			:= "2"
Local lDispRH			:= .T. //Controle de disponibilidade no RH
Local cCarac			:= ''
Local cCursos			:= ''
Local aCarAtd 		:= {} //Retorna as Características do atendente
Local aCurAtd 		:= {} //Retorna os cursos do funcionario
Local nPosTW2        := 0
Local aTW2Restri   := {}
Local oTempTab		:= Nil
Local cCCusto 		:= ""
Local nTpRest 		:= 0
Local cSubAtend     := ""
Local aRetorno		:= {}
Local dIniPE  := Ctod("")
Local dFimPE  := Ctod("")
Local cWhereTrns := ""
Local cJoinSPF := ""
Local cHrIni	:= ''
Local cHrFim	:= ''
Local lGSVERHR := SuperGetMV("MV_GSVERHR",,.F.)
Local lResRH	 := TableInDic("TXB")
Local cTMP_DISP  := ""
Local cTMP_ALOCA := ""
Local cWhereTec := ""
//--------------------------------------------------------------------------
// Inicialização de valores padrão para os parâmetros da função
//-------------------------------------------------------------------------

Default dIniAloc 		:= ''												//Por padrão filtra recursos agendados apenas para a data atual.
Default dFimAloc		:= ''												//Por padrão filtra recursos agendados apenas para a data atual.
Default cDisponib		:= 'T'												//Por padrão lista todos os recursos (Disponíveis e Indisponíveis).
Default cContIni		:= Space( TamSX3('AAH_CONTRT')[1] )			//Por padrão filtra recursos de todos os contratos
Default cContFim		:= Replicate( '9', TamSX3('AAH_CONTRT')[1] )	//Por padrão filtra recursos de todos os contratos
Default aHabil		:= {}												//Por padrão não filtra habilidades.
Default cLista			:= '3'												//Por padrão lista todos os atendentes (Banco de Apoio e Reserva de qualquer contrato)
Default nLegenda		:= 1												//Por padrão monta legenda de alocação.
Default cItemOS		:= ''												//Por padrão não filtra por item da OS
Default aRegiao		:= {}												//Por padrão não filtra por regiao
Default lEstrut		:= .F.												//Indica como a tabela será retornada
Default aPeriodos		:= {}
Default aCargos		:= {}
Default aFuncoes		:= {}
Default aTurnos		:= {}
Default aSeqTrn		:= {}												//Filtro por sequencia do turno
Default cIdCfAbq 		:= ''
Default cLocOrc 		:= ''
Default aPeriodRes	:= {}
Default cLocalAloc  := ''												//Periodo para reserva Tecnica
Default aCarac		:= {}
Default aCursos		:= {}
Default cCodTec		:= "" //Codigo do Atendente
Default dDtRef      := ''

If lGSVERHR .OR. isInCallStack("AT570Subst")
	If (isInCallStack("teca190d") .OR. isInCallStack("AT190dIMn2")) .OR. (isInCallStack("AT570Subst") .AND. !IsInCallStack("At190dCons"))
		cHrIni	:= FWFLDGET("ABR_HRINI")
		cHrFim	:= FWFLDGET("ABR_HRFIM")
	EndIf
EndIf 

If lRH
	GetPonMesDat( @dIniPE , @dFimPE , cFilAnt )
Else
	dFimPE := dIniAloc
EndIf

If ValType(xCCusto) == 'U'
	xCCusto := ""
EndIf

IIf( lRH, nHabil := 1, nHabil := 2 )

//-----------------------------------------------------------------------------------------
// Estrutura de campos da tabela temporária
//-----------------------------------------------------------------------------------------

//Campos retornados
AAdd( aCampos, { 'TMP_LEGEN'	, ''	} )
AAdd( aCampos, { 'TMP_FILIAL'	, TxDadosCpo( 'AA1_FILIAL' )[1]	} )
AAdd( aCampos, { 'TMP_CODTEC'	, TxDadosCpo( 'AA1_CODTEC' )[1]	} )
AAdd( aCampos, { 'TMP_NOMTEC'	, TxDadosCpo( 'AA1_NOMTEC' )[1]	} )
AAdd( aCampos, { 'TMP_CDFUNC'	, TxDadosCpo( 'AA1_CDFUNC' )[1]	} )
AAdd( aCampos, { 'TMP_TURNO'	, TxDadosCpo( 'AA1_TURNO'  )[1]	} )
AAdd( aCampos, { 'TMP_FUNCAO'	, TxDadosCpo( 'AA1_FUNCAO' )[1]	} )
AAdd( aCampos, { 'TMP_CARGO'	, TxDadosCpo( 'RA_CARGO'   )[1]	} )
AAdd( aCampos, { 'TMP_DISP'		, STR0038 	} )						//'Disponível?'
AAdd( aCampos, { 'TMP_DISPRH'		, STR0043 	} )	   					//'Disponivel RH?'
AAdd( aCampos, { 'TMP_ALOC'		, STR0039 	} )	   					//'Alocado?'
AAdd( aCampos, { 'TMP_SITFOL'	, TxDadosCpo( 'RA_SITFOLH' )[1]	} )
AAdd( aCampos, { 'TMP_DESC'		, STR0040 } )						//'Descrição'
AAdd( aCampos, { 'TMP_RESTEC'	, TxDadosCpo( 'TCU_RESTEC'  )[1] } ) // Reserva Tecnica
AAdd( aCampos, { 'TMP_PTURNO'	, TxDadosCpo( 'PF_TURNOPA'  )[1]	} )
AAdd( aCampos, { 'TMP_OK'		, STR0041 } ) 						// "OK"
AAdd( aCampos, { 'TMP_ALOCA'	, TxDadosCpo( 'AA1_ALOCA'  )[1]	} )
AAdd( aCampos, { 'TMP_TPCONT'	, TxDadosCpo( 'RA_TPCONTR'  )[1]	} )

//Estrutura para criação do arquivo temporário
AAdd( aStructure, { aCampos[1][1]	, 'C', 15, 0 } )
AAdd( aStructure, { aCampos[2][1]	, 'C', TamSX3('AA1_FILIAL')[1], TamSX3('AA1_FILIAL')[2] } )
AAdd( aStructure, { aCampos[3][1]	, 'C', TamSX3('AA1_CODTEC')[1], TamSX3('AA1_CODTEC')[2] } )
AAdd( aStructure, { aCampos[4][1]	, 'C', TamSX3('AA1_NOMTEC')[1], TamSX3('AA1_NOMTEC')[2] } )
AAdd( aStructure, { aCampos[5][1]	, 'C', TamSX3('AA1_CDFUNC')[1], TamSX3('AA1_CDFUNC')[2] } )
AAdd( aStructure, { aCampos[6][1]	, 'C', TamSX3('AA1_TURNO')[1], TamSX3('AA1_TURNO')[2] } )
AAdd( aStructure, { aCampos[7][1]	, 'C', TamSX3('AA1_FUNCAO')[1], TamSX3('AA1_FUNCAO')[2] } )
AAdd( aStructure, { aCampos[8][1]	, 'C', TamSX3('RA_CARGO')[1], TamSX3('RA_CARGO')[2] } )
AAdd( aStructure, { aCampos[9][1]	, 'C', 3, 0 } )
AAdd( aStructure, { aCampos[10][1]	, 'C', 3, 0 } )
AAdd( aStructure, { aCampos[11][1]	, 'C', 3, 0 } )
AAdd( aStructure, { aCampos[12][1]	, 'C', TamSX3('RA_SITFOLH')[1], TamSX3('RA_SITFOLH')[2] } )
AAdd( aStructure, { aCampos[13][1]	, 'C', 55, 0 } )
AAdd( aStructure, { aCampos[14][1]	, 'C', TamSX3('TCU_RESTEC')[1], TamSX3('TCU_RESTEC')[2] } )
AAdd( aStructure, { aCampos[15][1]	, 'C', TamSX3('PF_TURNOPA')[1], TamSX3('PF_TURNOPA')[2] } )
AAdd( aStructure, { aCampos[16][1]	, 'C', 2, 0 } )
AAdd( aStructure, { aCampos[17][1]	, 'C', TamSX3('AA1_ALOCA')[1], TamSX3('AA1_ALOCA')[2] } )
AAdd( aStructure, { aCampos[18][1]	, 'C', TamSX3('RA_TPCONTR')[1], TamSX3('RA_TPCONTR')[2] } )

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
// Monta filtros dinâmicos da consulta
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------

//------------------------------------------------------------------
// Filtra atendentes disponíveis pela agenda e RH
//------------------------------------------------------------------
cWhereDisp := "ABB_CODTEC IS NULL "		//Filtra apenas atendentes sem agenda

//------------------------------------------------------------------
// Filtra atendentes indisponíveis no RH
//------------------------------------------------------------------
If ( Upper(cDisponib) == 'A' )
	cWhereIndisp := "ABB.ALOCADO = '" + cSim + "' "
Else
	cWhereIndisp := "(  ABB.ALOCADO = '" + cSim + "' ) "		//Filtra as situações de folha Afastado, Férias e Transferido
EndIf

//-----------------------------------------------------------------------------------------
// Filtro por Centro de Custo, de acordo com o parâmetro cLista
//-----------------------------------------------------------------------------------------
If ValType(xCCusto) == 'C'
	If ( !Empty(xCCusto) )
    	cWhereDisp += "AND AA1_CC = '" + xCCusto + "' "
       	cWhereIndisp += "AND AA1_CC = '" + xCCusto + "' "
    EndIf
ElseIf ValType(xCCusto) == 'A'
	If Len(xCCusto) > 0
    	For nX := 1 To Len(xCCusto)
	    	If !Empty(xCCusto[nX])
	        	If nX == 1
	            	cCCusto += "'"+ xCCusto[nX] + "'"
	    		Else
	         		cCCusto += ",'"+xCCusto[nX] + "'"
	        	EndIf
	  		EndIf
      	Next nX

	  	If !Empty(cCCusto)
      		cWhereDisp += "AND AA1_CC IN (" + cCCusto + ") "
  			cWhereIndisp += "AND AA1_CC IN (" + cCCusto + ") "
        EndIf
  	EndIf
EndIf



// Carrega os filtros de equipe
//Filtra apenas Banco de Apoio ( Atendentes não ligados a um contrato )
If ( cLista == '1' )
	/*
		Alteração feita para substituir o código dos atendentes, por subquery

		//------
		De: While AAX->(!Eof()) .AND. AAX->(AAX_FILIAL+AAX_TPGRUP) == xFilial("AAX")+cApoio + While AAY->(!Eof()) .AND. xFilial("AAY") == AAY->AAY_FILIAL .AND. aEquipe[nX] == AAY->AAY_CODEQU

		Para: SELECT AAY_CODTEC FROM " + RetSQLName('AAX') + " AAX "
					INNER JOIN "+ RetSQLName('AAY')  + " AAY ON AAY_FILIAL = '" + xFilial("AAY") + "' AND AAX.AAX_CODEQU = AAY.AAY_CODEQU"
					WHERE AAX_FILIAL = '" + xFilial("AAX") + "'"
						AND AAX_TPGRUP = '" + cApoio +   "'"
						AND AAX.D_E_L_E_T_ =  ' '"
		  				AND AAY.D_E_L_E_T_ = ' '"
		//------

		De: If Len(aAcesso[2]) > 0 .And. ; // verifica se o filtro consta a equipe
			   aScan(aAcesso[2], { |x| Alltrim(x[7]) == AllTrim(AAX->(AAX_FILIAL+AAX_CODEQU)) } ) == 0
				AAX->(DbSkip())
				Loop
			EndIf
		   	aAdd(aEquipe,AAX->AAX_CODEQU)
			AAX->(DbSkip())



		Para: TIZ->(DbSetOrder(2))
		If TIZ->(DbSeek(xFilial("TIZ") + __cUserId + PADR('AAX', TamSX3('TIZ_TABELA')[1], '') + '001' ))
				AND EXISTS ("
							SELECT 1 FROM " + RetSQLName('TIZ')
							WHERE  TIZ_FILIAL = '" +  xFilial("TIZ")
							AND TIZ_TABELA = 'AAX'"
								AND TIZ_CODUSR = '" + __cUserId  + "'"
								AND TIZ_FILTRA = '1'"
								AND TIZ_NICK = '001'"
								AND TIZ_VALOR = AAX_FILIAL+AAX_CODEQU"
								AND D_E_L_E_T_ = ' ')"
		EndIf
	*/

    If checkSIX("AAX", 2)
		cSubAtend := "SELECT AAY_CODTEC FROM " + RetSQLName('AAX') + " AAX "
		cSubAtend += "	INNER JOIN "+ RetSQLName('AAY')  + " AAY ON AAY_FILIAL = '" + xFilial("AAY") + "' AND AAX.AAX_CODEQU = AAY.AAY_CODEQU"
		cSubAtend += "	WHERE AAX_FILIAL = '" + xFilial("AAX") + "'"
		cSubAtend += "  AND AAX_TPGRUP = '" + cApoio +   "'"
		cSubAtend += "  AND AAX.D_E_L_E_T_ =  ' '"
		cSubAtend += "  AND AAY.D_E_L_E_T_ = ' '"

		TIZ->(DbSetOrder(2))
		If TIZ->(DbSeek(xFilial("TIZ") + __cUserId + PADR('AAX', TamSX3('TIZ_TABELA')[1], '') + '001' ))
			cSubAtend += "	AND EXISTS ("
			cSubAtend += "				SELECT 1 FROM " + RetSQLName('TIZ')
			cSubAtend += "				WHERE  TIZ_FILIAL = '" +  xFilial("TIZ") + "'"
			cSubAtend += "  				AND TIZ_TABELA = 'AAX'"
			cSubAtend += "					AND TIZ_CODUSR = '" + __cUserId  + "'"
			cSubAtend += "					AND TIZ_FILTRA = '1'"
			cSubAtend += "					AND TIZ_NICK = '001'"
			cSubAtend += "					AND TIZ_VALOR = AAX_FILIAL||AAX_CODEQU"
			cSubAtend += "					AND D_E_L_E_T_ = ' ')"
		EndIf

		cWhereDisp += "AND AA1_CODTEC IN (" + cSubAtend + ") "
		cWhereIndisp += "AND AA1_CODTEC IN (" + cSubAtend + ") "

	EndIf

//Filtra apenas Reserva Técnica ( Atendentes ligados ao contrato )
ElseIf ( cLista == '2' )
	If checkSIX("AAX", 2)
		cSubAtend := "SELECT AAY_CODTEC FROM " + RetSQLName('AAX') + " AAX "
		cSubAtend += "	INNER JOIN "+ RetSQLName('AAY')  + " AAY ON AAY_FILIAL = '" + xFilial("AAY") + "' AND AAX.AAX_CODEQU = AAY.AAY_CODEQU"
		cSubAtend += "	WHERE AAX_FILIAL = '" + xFilial("AAX") + "'"
		cSubAtend += "  AND AAX_TPGRUP = '" + cReserva + "'"
		cSubAtend += "  AND AAX.D_E_L_E_T_ = ' '"
		cSubAtend += "  AND AAY.D_E_L_E_T_ = ' '"

		TIZ->(DbSetOrder(2))
		If TIZ->(DbSeek(xFilial("TIZ") + __cUserId + PADR('AAX', TamSX3('TIZ_TABELA')[1], '') + '001' ))
			cSubAtend += "	AND EXISTS ("
			cSubAtend += "				SELECT 1 FROM " + RetSQLName('TIZ')
			cSubAtend += "				WHERE  TIZ_FILIAL = '" +  xFilial("TIZ") + "'"
			cSubAtend += "  				AND TIZ_TABELA = 'AAX'"
			cSubAtend += "					AND TIZ_CODUSR = '" + __cUserId  + "'"
			cSubAtend += "					AND TIZ_FILTRA = '1'"
			cSubAtend += "					AND TIZ_NICK = '001'"
			cSubAtend += "					AND TIZ_VALOR = AAX_FILIAL||AAX_CODEQU"
			cSubAtend += "					AND D_E_L_E_T_ = ' ')"
		EndIf

		cWhereDisp += "AND AA1_CODTEC IN (" + cSubAtend + ") "
		cWhereIndisp += "AND AA1_CODTEC IN (" + cSubAtend + ") "
	EndIf

Else

	TIZ->(DbSetOrder(2))
	If TIZ->(DbSeek(xFilial("TIZ") + __cUserId + PADR('AAX', TamSX3('TIZ_TABELA')[1], '') + '001' ))  //Len(aAcesso[2]) > 0 	//verificar se o filtro existe de equipes

	    If checkSIX("AAX", 2)

	    	cSubAtend := "SELECT AAY_CODTEC FROM " + RetSQLName('AAX') + " AAX "
			cSubAtend += "	INNER JOIN "+ RetSQLName('AAY')  + " AAY ON AAY_FILIAL = '" + xFilial("AAY") + "' AND AAX.AAX_CODEQU = AAY.AAY_CODEQU"
			cSubAtend += "	WHERE AAX_FILIAL = '" + xFilial("AAX") + "'"
			cSubAtend += "  AND AAX.D_E_L_E_T_ = ' '"
			cSubAtend += "  AND AAY.D_E_L_E_T_ = ' '"

			cSubAtend += "	AND EXISTS ("
			cSubAtend += "				SELECT 1 FROM " + RetSQLName('TIZ')
			cSubAtend += "				WHERE  TIZ_FILIAL = '" +  xFilial("TIZ") + "'"
			cSubAtend += "  				AND TIZ_TABELA = 'AAX'"
			cSubAtend += "					AND TIZ_CODUSR = '" + __cUserId  + "'"
			cSubAtend += "					AND TIZ_FILTRA = '1'"
			cSubAtend += "					AND TIZ_NICK = '001'"
			cSubAtend += "					AND TIZ_VALOR = AAX_FILIAL||AAX_CODEQU"
			cSubAtend += "					AND D_E_L_E_T_ = ' ')"

			cWhereDisp += "AND AA1_CODTEC IN (" + cSubAtend + ") "
			cWhereIndisp += "AND AA1_CODTEC IN (" + cSubAtend + ") "
		EndIf
	EndIf
EndIf

//Se for igual a 3 ou estiver em branco,
//lista todos os atendentes independente do centro de custo

If ( !lRH )
	cWhereTrns := ""
EndIf

cJoinSPF := " LEFT JOIN "+RetSQLName('SPF')+" SPF ON PF_FILIAL = '"+xFilial("SPF")+"' "
cJoinSPF += " AND SPF.PF_MAT = AA1_CDFUNC "
cJoinSPF += " AND SPF.D_E_L_E_T_ = ' '
cJoinSPF += cWhereTrns
cJoinSPF += "	AND SPF.PF_DATA = (SELECT MAX(X.PF_DATA) AS DATA  FROM " + RetSQLName('SPF') + ;
									" X WHERE X.PF_FILIAL = SPF.PF_FILIAL "+;
									"AND X.PF_MAT = SPF.PF_MAT  "+;
									IIF(!Empty(dFimPE), "AND X.PF_DATA > '" + Dtos(dFimPE) +"' ", "")+;
									IIF(!Empty(dIniAloc), " AND X.PF_DATA <= '" + Dtos(dIniAloc) +"' ", " " )+;
									"AND X.D_E_L_E_T_ = ' ')  "

If !Empty(cIdCfAbq) // Estrutura nova de alocação
	cWhereABB 	:= "AND ( ABB_IDCFAL = '" + cIdCfAbq + "')"
	If !Empty(cLocOrc)
		cWhereABB += " AND ABB_LOCAL = '" + cLocOrc + "'"
	EndIf
ElseIf ( !Empty(cItemOS) )	// Filtro por Item da OS
	cWhereABB 	:= "AND ( ABB_ENTIDA = 'AB7' AND ABB_CHAVE = '" + cItemOS + "')"
EndIf
//------------------------------------------------------------------

//------------------------------------------------------------------
// Filtro por Data do agendamento da alocação
//------------------------------------------------------------------
If ( !Empty(dIniAloc) ) .And. ( !Empty(dFimAloc) )
	If( !Empty(cHrIni) ) .And. ( !Empty(cHrFim) ) .AND. lGSVERHR
		cWhereABB += " AND ((ABB_DTINI = '" + DtoS(dIniAloc) + "' "
        cWhereABB += " AND ABB_HRINI > '" + cHrIni +"') "
		cWhereABB += " AND (ABB_DTFIM = '" + DtoS(dFimAloc) + "' "
		cWhereABB += " AND ABB_HRFIM < '" + cHrFim + "')) "
	ELSE
		cWhereABB += " AND ABB_DTINI BETWEEN '" + DToS(dIniAloc) + "' AND '" + DtoS(dFimAloc) + "' "
	ENDIF
ElseIf ( Len( aPeriodos ) > 0 .OR. Len(aPeriodRes) > 0)
	//Caso seja listagem de Reserva considera as informações do periodo da reserva
	If cLista == "2" .AND. Len(aPeriodRes) > 0 //Reserva
		cWhereABB += GetSqlPeri(aPeriodRes)
	Else
		cWhereABB += GetSqlPeri(aPeriodos)
	EndIf

EndIf

//------------------------------------------------------------------
// Filtra apenas agendamentos ativos e que nao foram atendidos.
//------------------------------------------------------------------
cWhereABB	+= " AND ABB.ABB_ATIVO <> '2'"

If cDisponib == "A"
	cWhereABB += " AND ABB.ABB_ATENDE <> '1'"
EndIf

cWhereDisp 	+= " AND '" + cDisponib + "' IN ('T','D') "		//Se for "A" ou "I", ignora a consulta de disponíveis
cWhereIndisp 	+= " AND '" + cDisponib + "' IN ('T','A','I') "	//Se for "A" ou "I", ignora a consulta de disponíveis

If ( lEstrut )
	cWhereDisp		+= " AND 1 = 2"
	cWhereIndisp	+= " AND 1 = 2"
EndIf

cWhereDisp		:= '%' + cWhereDisp + '%'
cWhereIndisp	:= '%' + cWhereIndisp + '%'
cWhereABB		:= '%' + cWhereABB + '%'

cJoinSPF :=  '%' + cJoinSPF + '%'

If !Empty(cCodTec)
	cCodTEC := " AND AA1.AA1_CODTEC = '" + cCodTec+ "'"
EndIf

cWhereTec := '%' + cCodTEC + '%'

//-------------------------------------------------------------------------------------
// Query de consulta de recursos
//-------------------------------------------------------------------------------------
BeginSql alias cAlias

	//-----------------------------------------------------------
	// Seleciona os Atendentes disponíveis para alocação
	//-----------------------------------------------------------
	SELECT DISTINCT TMP_LEGEN, TMP_FILIAL, TMP_CODTEC, TMP_NOMTEC, TMP_CDFUNC, TMP_TURNO, TMP_FUNCAO,
	       TMP_CARGO, TMP_DISP, TMP_DISPRH, TMP_ALOC, TMP_SITFOL, TMP_DESC, TMP_RESTEC, TMP_PTURNO, TMP_OK, TMP_ALOCA, TMP_IDCFAL, TMP_DTREF, TMP_TPCONT
	FROM (
	   SELECT '               '	AS TMP_LEGEN,
	   		   AA1_FILIAL 		AS TMP_FILIAL,
	          AA1_CODTEC 		AS TMP_CODTEC,
	          AA1_NOMTEC 		AS TMP_NOMTEC,
	          AA1_CDFUNC 		AS TMP_CDFUNC,
	          AA1_ALOCA 		AS TMP_ALOCA,
	          RA_TPCONTR		AS TMP_TPCONT,
	          CASE WHEN RA_TNOTRAB IS NULL
	              THEN AA1_TURNO
	              ELSE RA_TNOTRAB
	          END  				AS TMP_TURNO,
	          CASE WHEN RA_CODFUNC IS NULL
	              THEN AA1_FUNCAO
	              ELSE RA_CODFUNC
	          END  				AS TMP_FUNCAO,
	          RA_CARGO			AS TMP_CARGO,
	          %Exp:cSim% 		AS TMP_DISP,
	          %Exp:cSim% 		AS TMP_DISPRH,
	          %Exp:cNao% 		AS TMP_ALOC,
	          CASE WHEN RA_SITFOLH IS NULL THEN ' '
	          		ELSE RA_SITFOLH
	          END 				AS TMP_SITFOL,
	          CASE WHEN X5_DESCRI IS NULL THEN ' '
	          		ELSE X5_DESCRI
	          END 				AS TMP_DESC,
			  CASE WHEN ABB_IDCFAL IS NULL THEN ' '
	          		ELSE ABB_IDCFAL
	          END 				AS TMP_IDCFAL,
			  CASE WHEN TDV_DTREF IS NULL THEN ' '
	          		ELSE TDV_DTREF
	          END 				AS TMP_DTREF,
	          TCU_RESTEC    AS TMP_RESTEC,
			  SPF.PF_TURNOPA AS TMP_PTURNO,
	          '  ' AS TMP_OK
	     FROM %Table:AA1% AA1
	//Contratos de Manutenção
	LEFT JOIN %Table:AAH% AAH
	       ON %xFilial:AAH% = AAH.AAH_FILIAL
	      AND AA1.AA1_CC = AAH.AAH_CCUSTO
	      AND AA1.AA1_CC <> %Exp:cCCVazio%
	      AND AAH.%NotDel%
	//Agenda de Atendimentos
		%Exp:cJoinSPF%
	LEFT JOIN (   SELECT ABB_FILIAL, ABB_CODTEC, ABB_CODIGO, ABB_IDCFAL, TCU_RESTEC
	              FROM %Table:ABB% ABB, %Table:TCU% TCU
	              WHERE ABB.%NotDel% AND
	                    TCU.%NotDel% AND TCU_FILIAL = %xFilial:TCU% AND
	                    (TCU_COD = ABB_TIPOMV OR ABB_TIPOMV='')
	                    %Exp:cWhereABB%
	           ) ABB
	       ON %xFilial:ABB% = ABB.ABB_FILIAL
	      AND AA1.AA1_CODTEC = ABB.ABB_CODTEC
	//Funcionários
	LEFT JOIN %Table:SRA% SRA
	       ON AA1.AA1_FUNFIL = SRA.RA_FILIAL
	      AND AA1.AA1_CDFUNC = SRA.RA_MAT
	      AND SRA.%NotDel%
	//Programação de Férias
	LEFT JOIN %Table:SRF% SRF
	       ON SRA.RA_MAT = SRF.RF_MAT
	      AND SRA.RA_FILIAL = SRF.RF_FILIAL
	      AND SRF.%NotDel%

	//Tabelas genéricas
	LEFT JOIN %Table:SX5% SX5
	       ON SX5.X5_TABELA = '31'	//31 - Tabela de Situações da Folha
	      AND SX5.X5_CHAVE = SRA.RA_SITFOLH
	      AND SX5.%NotDel%

	LEFT JOIN %Table:TDV% TDV 
		   ON ABB.ABB_CODIGO = TDV.TDV_CODABB
           AND ABB.ABB_FILIAL = TDV.TDV_FILIAL

	WHERE %Exp:cWhereDisp%
	    AND AA1.%NotDel%
	    %Exp:cWhereTec%

	UNION ALL

	//-----------------------------------------------------------
	//Seleciona os Atendentes indisponíveis para alocação
	//-----------------------------------------------------------
	SELECT '               '	AS TMP_LEGEN,
	   		AA1_FILIAL 		AS TMP_FILIAL,
	       AA1_CODTEC 		AS TMP_CODTEC,
	       AA1_NOMTEC 		AS TMP_NOMTEC,
	       AA1_CDFUNC 		AS TMP_CDFUNC,
	       AA1_ALOCA 		AS TMP_ALOCA,	
	       RA_TPCONTR		AS TMP_TPCONT,   
	       CASE WHEN RA_TNOTRAB IS NULL
	              THEN AA1_TURNO
	              ELSE RA_TNOTRAB
	          END  			AS TMP_TURNO,
	          CASE WHEN RA_CODFUNC IS NULL
	              THEN AA1_FUNCAO
	              ELSE RA_CODFUNC
	          END  			AS TMP_FUNCAO,
          	RA_CARGO			AS TMP_CARGO,
	       %Exp:cNao% 		AS TMP_DISP,
	       %Exp:cSim% 		AS TMP_DISPRH,
	       CASE WHEN ABB.ALOCADO IS NULL THEN %Exp:cNao%
	       	ELSE ABB.ALOCADO
	       END 				AS TMP_ALOC,
	       CASE WHEN RA_SITFOLH IS NULL THEN ' '
	       	ELSE RA_SITFOLH
	       END			       AS TMP_SITFOL,
	       CASE WHEN X5_DESCRI IS NULL THEN ' '
	       	ELSE X5_DESCRI
	       END 				AS TMP_DESC,
		   CASE WHEN ABB_IDCFAL IS NULL THEN ' '
	        ELSE ABB_IDCFAL
	       END 				AS TMP_IDCFAL,
		   CASE WHEN TDV_DTREF IS NULL THEN ' '
	        ELSE TDV_DTREF
	       END 				AS TMP_DTREF,
	       TCU_RESTEC AS TMP_RESTEC,
		   SPF.PF_TURNOPA AS TMP_PTURNO,
	       '  ' 				AS TMP_OK

	     FROM %Table:AA1% AA1
	//Contratos de Manutenção
	LEFT JOIN %Table:AAH% AAH
	       ON %xFilial:AAH% = AAH.AAH_FILIAL
	      AND AA1.AA1_CC = AAH.AAH_CCUSTO
	      AND AA1.AA1_CC <> %Exp:cCCVazio%
	      AND AAH.%NotDel%
	//Agenda de Atendimentos
	%Exp:cJoinSPF%
	LEFT JOIN ( SELECT ABB_FILIAL, ABB_CODTEC, ABB_CODIGO, ABB_IDCFAL, TCU_RESTEC, %Exp:cSim% AS ALOCADO
	              FROM %Table:ABB% ABB, %Table:TCU% TCU
	             WHERE ABB.%NotDel% %Exp:cWhereABB% AND
	                   TCU.%NotDel% AND TCU_FILIAL = %xFilial:TCU% AND
	                   (TCU_COD = ABB_TIPOMV OR ABB_TIPOMV='') ) ABB
	       ON %xFilial:ABB% = ABB.ABB_FILIAL
	      AND AA1.AA1_CODTEC = ABB.ABB_CODTEC
	//Funcionários
	LEFT JOIN %Table:SRA% SRA
	       ON AA1.AA1_FUNFIL = SRA.RA_FILIAL
	      AND AA1.AA1_CDFUNC = SRA.RA_MAT
	//Programação de Férias
	LEFT JOIN %Table:SRF% SRF
	       ON SRA.RA_MAT = SRF.RF_MAT
	      AND SRA.RA_FILIAL = SRF.RF_FILIAL

	//Tabelas genéricas
	LEFT JOIN %Table:SX5% SX5
	       ON SX5.X5_TABELA = '31'	//31 - Tabela de Situações da Folha
	      AND SX5.X5_CHAVE = SRA.RA_SITFOLH

	LEFT JOIN %Table:TDV% TDV 
		   ON ABB.ABB_CODIGO = TDV.TDV_CODABB
           AND ABB.ABB_FILIAL = TDV.TDV_FILIAL

	WHERE %Exp:cWhereIndisp%
	    AND AA1.%NotDel%
	    %Exp:cWhereTec%
	 ) TAB_QRY

EndSql

// Desvio adicionado, para o caso da utilização da permissão 036, para seleção manual de atendete via consulta padrão, na manutenção da agenda
If isInCallStack('At550VaSub') // Verifica se a função do valido do campo ABR_CODSUB está na pilha de execução
	While (cAlias)->(!EOF())
		cTMP_DISP := (cAlias)->TMP_DISP
		cTMP_ALOCA := (cAlias)->TMP_ALOCA
		If !Empty(cLocalAloc)
			dbSelectArea("ABS")
			ABS->(dbSetOrder(1))
			ABS->(dbSeek(xFilial("ABS")+cLocalAloc ))
			
			If ABS->ABS_RESTEC <> "1" .And. (cAlias)->TMP_RESTEC == "1"
				cTMP_DISP := 'SIM'
				cTMP_ALOCA := '1'
			EndIf
		EndIf

		If !lGSVERHR .AND. isInCallStack("AT570Subst") .AND. cIdCfAbq == (cAlias)->TMP_IDCFAL
			If dDtRef == STOD((cAlias)->TMP_DTREF) .OR. VerAbbRest( (cAlias)->TMP_IDCFAL, (cAlias)->TMP_CODTEC, dIniAloc, dFimAloc, cHrIni, cHrFim, (cAlias)->TMP_FILIAL )
				cTMP_DISP := 'SIM'
				cTMP_ALOCA := '1'
			EndIf
		EndIf	

		If !Empty(dDtRef)
			If UPPER(cTMP_DISP) == 'SIM' .AND. cTMP_ALOCA <> "2" .AND. TxExitCon((cAlias)->TMP_CODTEC, dDtRef, dDtRef)
				AADD(aRetorno, {(cAlias)->TMP_CODTEC,(cAlias)->TMP_CDFUNC})
			EndIf	
		Else
			If UPPER(cTMP_DISP) == 'SIM' .AND. cTMP_ALOCA <> "2" .AND. TxExitCon((cAlias)->TMP_CODTEC,dIniAloc, dFimAloc) //Indisponível
				// Adiciona ao array aRetorno apenas os dados dos atendentes/funcionários que estão disponíveis
				AADD(aRetorno, {(cAlias)->TMP_CODTEC,(cAlias)->TMP_CDFUNC})
			EndIf
		EndIf	
		
		(cAlias)->(Dbskip())
	EndDo

	(cAlias)->(DbCloseArea())
Else
//----------------------------------------------------------------------
// Cria arquivo de dados temporário
//----------------------------------------------------------------------
	cTempTab:= GetNextAlias()
	oTempTab:= FWTemporaryTable():New(cTempTab)
	oTempTab:SetFields(aStructure)
	oTempTab:AddIndex("I1",{"TMP_CODTEC"})
	oTempTab:AddIndex("I2",{"TMP_NOMTEC"})
	oTempTab:Create()
	(cTempTab)->(dbGotop())

	DBTblCopy(cAlias, cTempTab)

	If ( Select( cAlias ) > 0 )
		DbSelectArea(cAlias)
		DbCloseArea()
	EndIf

	dbSelectArea(cTempTab)

	//----------------------------------------------------------------------
	// Monta estrutura para a criação do FormBrowse
	//----------------------------------------------------------------------
	For nI := 1 To Len( aCampos )

		If  !( RTrim(aCampos[nI][1]) $ "TMP_OK#TMP_PTURNO#TMP_TPCONT") .AND. RTrim(aCampos[nI][1]) <> "TMP_ALOCA"

			AAdd( aColumns, FWBrwColumn():New() )
			aColumns[nI]:SetData( &("{||" + aCampos[nI][1] + "}") )
			aColumns[nI]:SetTitle( aCampos[nI][2] )
			aColumns[nI]:SetSize(5)
			aColumns[nI]:SetDecimal(0)

			If ( aCampos[nI][1] == 'TMP_LEGEN' )
				aColumns[nI]:SetPicture("@BMP")
				aColumns[nI]:SetImage(.T.)
			EndIf
		EndIf

	Next nI

	//----------------------------------------------------------------------
	// Monta legenda da consulta
	//----------------------------------------------------------------------
	(cTempTab)->(DbGoTop())

	//verificar as restrições por local de atendimento / cliente - tabela TW2
	// por performance sera retornado um array com todas as restrições do local

	aTW2Restri:=TxRestri(cLocalAloc)

	While (cTempTab)->(!Eof())

		(cTempTab)->(Reclock( cTempTab, .F.))
		
		//Integração com RH
		If lRH
			If !Empty((cTempTab)->TMP_PTURNO) .AND. (cTempTab)->TMP_PTURNO <> (cTempTab)->TMP_TURNO
				(cTempTab)->TMP_TURNO := (cTempTab)->TMP_PTURNO
			EndIf
			//Verificação pela data de alocação
			If ( !Empty(dIniAloc) ) .And. ( !Empty(dFimAloc) )
				lDispRH := At570VldRh((cTempTab)->TMP_CODTEC, dIniAloc, dFimAloc,@nTpRest  )

			//Verificação pelos periodos informados
			ElseIf Len( aPeriodos ) > 0

				For nI := 1 To Len( aPeriodos )
					lDispRh := At570VldRh((cTempTab)->TMP_CODTEC, aPeriodos[nI][1], aPeriodos[nI][3],@nTpRest )
					If !lDispRh
						Exit
					EndIf
				Next nI
			EndIf

			If !lDispRh
				//-- Tratamento somente para gestão de escalas
				If nTpRest <= 1 
					(cTempTab)->TMP_DISP := cNao
					(cTempTab)->TMP_DISPRH := cNao
				ElseIf nTpRest == 2
					(cTempTab)->TMP_DISP := cFer
					(cTempTab)->TMP_DISPRH := cFer
				EndIf
			EndIf

		EndIf

		//Tratamento para consultar alocacao em RESERVA TECNICA
		//regra: caso o local de destino seja informado, e nao seja reserva, se o recurso estiver em algum local como reserva, lista como DISPONIVEL
		If !Empty(cLocalAloc)
			dbSelectArea("ABS")
			ABS->(dbSetOrder(1))
			ABS->(dbSeek(xFilial("ABS")+cLocalAloc ))
			If ABS->ABS_RESTEC <> "1" .And. (cTempTab)->TMP_RESTEC == "1"
				(cTempTab)->TMP_DISP := cSim
				(cTempTab)->TMP_ALOC := cNao
			EndIf
		EndIf

		//Verifica se o campo alocado está diferente de não
		If !Empty((cTempTab)->TMP_ALOCA) .AND. (cTempTab)->TMP_ALOCA == "2" //Indisponível
			(cTempTab)->TMP_DISP := cNao
		EndIf

		//Monta legenda para tela de alocação com status dos atendentes
		If ( nLegenda == 1 )
			//Recurso indisponível (RH)
			If UPPER((cTempTab)->TMP_DISPRH) == UPPER(cNao) .or. ((IsInCallStack("AT19LAA1") .and. dIniAloc <= Posicione("SRA",1,(Posicione("AA1",1,xFilial("AA1")+(cTempTab)->TMP_CODTEC,"AA1_FUNFIL"))+(cTempTab)->TMP_CDFUNC,"RA_ADMISSA")))
                 (cTempTab)->TMP_LEGEN := 'BR_VERMELHO'    
			ElseIf UPPER((cTempTab)->TMP_DISPRH) == UPPER(cFer)
				(cTempTab)->TMP_LEGEN := 'BR_PINK'
			//Recurso disponível
			ElseIf ( UPPER((cTempTab)->TMP_DISP) == UPPER(cSim) ) .And. ( UPPER((cTempTab)->TMP_ALOC) == UPPER(cNao) )
				//Verificar se tem restrição operacional
				For nI := 1 To Len( aPeriodos )
					
					//Verificar se tem restrição operacional nos períodos de alocação
					nPosTw2:= aScan(aTW2Restri,{|x| x[1] == (cTempTab)->TMP_CODTEC .And. ((sTod(x[6]) >= aPeriodos[nI,1] .And. sTod(x[6]) <= aPeriodos[nI,3] ) .Or. ;
													  	 								 ( sTod(x[7]) >= aPeriodos[nI,1] .And. sTod(x[7]) <= aPeriodos[nI,3] ))})
					If nPosTW2 > 0
						Exit
					EndIf
				Next nI

				If 	nPosTW2 > 0
					If aTW2Restri[nPosTW2][8] == '1' //Aviso de restrição local/cliente
						(cTempTab)->TMP_LEGEN := 'BR_LARANJA'
					Elseif aTW2Restri[nPosTW2][8] == '2' //Bloqueio de restrição local/cliente
						(cTempTab)->TMP_LEGEN := 'BR_PRETO'
					Endif
				Else
					//disponivel para alocação
					(cTempTab)->TMP_LEGEN := 'BR_BRANCO'
				Endif
			// "Disponível / Alocado em RT."	
			ElseIf isInCallStack("At190dCons") .AND. (cTempTab)->TMP_RESTEC == '1'
				(cTempTab)->TMP_LEGEN := 'BR_VIOLETA'
			//Recurso indisponível (Alocado)
			ElseIf ( UPPER((cTempTab)->TMP_DISP) == UPPER(cNao) ) .And. ( UPPER((cTempTab)->TMP_ALOC) == UPPER(cSim) )
				(cTempTab)->TMP_LEGEN := 'BR_AMARELO'

			//Recurso indisponível (RH)
			Else
				(cTempTab)->TMP_LEGEN := 'BR_VERMELHO'
			EndIf

		//Monta legenda de tela de recursos alocados com apenas uma cor
		ElseIf ( nLegenda == 2 )
			(cTempTab)->TMP_LEGEN := 'BR_PRETO'
		EndIf

		If lResRh
			If ( !Empty(dIniAloc) ) .And. ( !Empty(dFimAloc) ) .And. TxRestriRH((cTempTab)->TMP_CODTEC,dIniAloc,dFimAloc)
				(cTempTab)->TMP_LEGEN := 'BR_PRETO'
			Elseif Len( aPeriodos ) > 0 
				For nI := 1 To Len( aPeriodos )		
					If TxRestriRH((cTempTab)->TMP_CODTEC,aPeriodos[nI][1],aPeriodos[nI][3])				
						(cTempTab)->TMP_LEGEN := 'BR_PRETO'
					Endif
				Next nI
			Endif
		Endif
		
		If (cTempTab)->TMP_LEGEN = 'BR_BRANCO' .AND.  (cTempTab)->TMP_TPCONT == "3"
			//Se estiver disponível para alocação mas for contrato intermitente, altera a legenda
			(cTempTab)->TMP_LEGEN := 'BR_AZUL'
		EndIf 
		(cTempTab)->(MsUnlock())

		aRet := TxAHabil((cTempTab)->TMP_CODTEC)

		If Len(aRet) > 0
			aAdd(aHabAtd,aRet[1])
		EndIf

		aRet := TxARegiao((cTempTab)->TMP_CODTEC)

		If Len(aRet) > 0
			aAdd(aRegAtd,aRet[1])
		EndIf

		// Caracteristica
		aRet := TxCarac((cTempTab)->TMP_CODTEC)

		If Len(aRet) > 0
			aAdd(aCarAtd,aRet[1])
		EndIf

		// Curso
		aRet := TxCurso((cTempTab)->TMP_CODTEC)

		If Len(aRet) > 0
			aAdd(aCurAtd,aRet[1])
		EndIf

		(cTempTab)->(DbSkip())

	EndDo
	// Retorno da função, caso não tenha chamada At550VaSub na pilha de execução
	aRetorno := { cTempTab, cTempIdx, aColumns, aHabAtd, aRegAtd, aCarAtd, aCurAtd  }
EndIf

Return aRetorno


//------------------------------------------------------------------------------
/*/{Protheus.doc} TxDadosCpo
Função auxiliar que retorna dados de um campo no SX3.

@sample 	TxDadosCpo( cCampo )

@param		cCampo	Nome do campo que deseja obter informações.

@return	aDados Dados do campo.
					[1] Título do campo.
					[2] Descrição do campo.

@since		13/11/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function TxDadosCpo( cCampo )

Local aArea	:= GetArea()
Local aDados	:= {}

DbSelectArea('SX3')		//Campos da tabela
SX3->( DbSetOrder(2) )	//X3_CAMPO
SX3->( DbGoTop() )

If ( SX3->( MsSeek( cCampo ) ) )

	AAdd( aDados, X3Titulo() )	//Retorna título do campo no X3
	AAdd( aDados, X3Descric() )	//Retorna descrição do campo no X3

EndIf

RestArea( aArea )

Return aDados


//------------------------------------------------------------------------------
/*/{Protheus.doc} ApagarTemp
Função auxiliar que exclui arquivo temporário.

@sample 	ApagarTemp( cArquivo )

@param		cArquivo	Arquivo que deve ser apagado.

@return	aRet 		Resultado da operação.
						[1] Resultado - (0)Sucesso | (-1) Erro.
						[2] Descrição do erro, caso o resultado seja -1.

@since		23/11/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function ApagarTemp( cArquivo )

Local aRet 	:= {}
Local nResult	:= 0
Local cErro	:= ''

Default cArquivo := Nil

If ( cArquivo != Nil )

	If ( File( cArquivo + '.DBF' ) )

		(cArquivo)->(DbCloseArea())

		nResult := FErase( cArquivo + '.DBF' )

		If ( nResult != 0 )
			cErro = FError()
		Else
			If ( File( cArquivo + '.IDX' ) )
				FErase( cArquivo + '.IDX' )
			EndIf
		EndIf

		AAdd( aRet, { nResult, cErro } )

	EndIf

EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TxAHabil
Função para criar tabela temporária com registros de recursos do
Banco de Apoio para uso em rotinas do SIGATEC.

@sample TxAHabil(cCodAtend)

@param	ExpC1	Codigo do atendente.

@return	ExpA	Habilidades do Atendente.

@author		Anderson Silva
@since		13/11/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function TxAHabil(cCodAtend)

Local aHabAtd 	 := {}
Local cDescHab	 := ""
Local nLinha 	 	 := 0
Local lTecXRh	 	 := SuperGetMv("MV_TECXRH",,.F.)	   			// Integracao Gestao de Servicos com RH?.
Local cDescHabil	 := ""
Local cDescEscal	 := ""
Local cDescItEsc	 := ""

If lTecXRh

	DbSelectArea("AA1")
	DbSetOrder(1)

	DbSelectArea("RBI")
	DbSetOrder(1)


	If AA1->(DbSeek(xFilial("AA1")+cCodAtend))

		DbSelectArea("RBI")
		DbSetOrder(1)

		If RBI->(DbSeek(xFilial("RBI")+AA1->AA1_CDFUNC))

			aAdd(aHabAtd,{cCodAtend})

			While ( RBI->(!Eof()) .AND. RBI->RBI_FILIAL == xFilial("RBI") .AND. RBI->RBI_MAT == AA1->AA1_CDFUNC )

				cDescHabil := Capital(AllTrim(FDesc("RBG",RBI->RBI_HABIL,"RBG_DESC")))
				cDescEscal := Capital(AllTrim(FDesc("RBK",RBI->RBI_ESCALA,"RBK_DESCRI")))
				cDescItEsc := Capital(AllTrim(FDesc("RBL",RBI->RBI_ESCALA + RBI->RBI_ITESCA,"RBL_DESCRI")))
				nLinha := Len(aHabAtd)
				aAdd(aHabAtd[nLinha],{RBI->RBI_HABIL,cDescHabil,0,RBI->RBI_ESCALA,cDescEscal,RBI->RBI_ITESCA,cDescItEsc})

				RBI->(DbSkip())
			End

		EndIf
	EndIf

Else

	DbSelectArea("AA2")
	DbSetOrder(1)

	If AA2->(DbSeek(xFilial("AA2")+cCodAtend))

		aAdd(aHabAtd,{cCodAtend})

		While ( AA2->(!Eof()) .AND. AA2->AA2_FILIAL == xFilial("AA2") .AND. AA2->AA2_CODTEC == cCodAtend )

			cDescHab :=	Posicione("SX5",1,xFilial("SX5")+"A4"+AA2->AA2_HABIL,"X5_DESCRI")
			cDescHab := Capital(Alltrim(cDescHab))
			nLinha := Len(aHabAtd)
			aAdd(aHabAtd[nLinha],{AA2->AA2_HABIL,cDescHab,AA2->AA2_NIVEL,"","","",""})

			AA2->(DbSkip())
		End

	EndIf

EndIf

Return( aHabAtd )

//------------------------------------------------------------------------------
/*/{Protheus.doc} TxARegiao
Função que retorna as regioes de atendimento do atendentes.

@sample	TxARegiao(cCodAtend)

@param	ExpC1	Codigo do atendente.

@return	ExpA	Regiao de Atendimento.

@author		Anderson Silva
@since		13/11/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function TxARegiao(cCodAtend)

Local aRegiao 	 := {}
Local nLinha 		 := 0
Local cDescReg 	 := ""

DbSelectArea("AA1")
DbSetOrder(1)

If AA1->(DbSeek(xFilial("AA1")+cCodAtend))
	If !Empty(AA1->AA1_REGIAO)
		aAdd(aRegiao,{cCodAtend})
		cDescReg :=	Posicione("SX5",1,xFilial("SX5")+"A2"+AA1->AA1_REGIAO,"X5_DESCRI")
		cDescReg := Capital(Alltrim(cDescReg))
		nLinha := Len(aRegiao)
		aAdd(aRegiao[nLinha],{AA1->AA1_REGIAO,cDescReg+STR0028}) //" (Residência)"
	EndIf
EndIf

DbSelectArea("ABU")
DbSetOrder(1)

If ABU->(DbSeek(xFilial("ABU")+cCodAtend))
	If Len(aRegiao) == 0
		aAdd(aRegiao,{cCodAtend})
	EndIf

	While ( ABU->(!Eof()) .AND. ABU->ABU_FILIAL == xFilial("ABU") .AND. ABU->ABU_CODTEC == cCodAtend )
		If ABU->ABU_REGIAO <> AA1->AA1_REGIAO
			cDescReg :=	Posicione("SX5",1,xFilial("SX5")+"A2"+ABU->ABU_REGIAO,"X5_DESCRI")
			cDescReg := Capital(Alltrim(cDescReg))
			nLinha := Len(aRegiao)
			aAdd(aRegiao[nLinha],{ABU->ABU_REGIAO,cDescReg})
		EndIf
		ABU->(DbSkip())
	End
EndIf

Return( aRegiao )

//------------------------------------------------------------------------------
/*/{Protheus.doc} TxRtDiaSem
Retorna o dia da semana.

@sample	TxRtDiaSem(dData)

@param	ExpD1	Data.

@return	ExpC	Dia da Semana.

@author		Anderson Silva
@since		13/11/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function TxRtDiaSem(dData)
Local aSemana	:= {}
Local nPos		:= 0

aSemana := {{1,STR0029}	,;	//"Domingo"
			{2,STR0030}	,;	//"Segunda-feira"
			{3,STR0031}	,;	//"Terça-feira"
			{4,STR0032}	,;	//"Quarta-feira"
			{5,STR0033}	,;	//"Quinta-feira"
			{6,STR0034}	,;	//"Sexta-feira"
			{7,STR0035}} 	//"Sábado"

nPos := aScan(aSemana,{|x| x[1] == Dow(dData)})


Return( aSemana[nPos][2] )

/*/{Protheus.doc} TxCalenAtd
Funcao para criar o calendario do atendente utilizado CriaCalend.

@sample 	TxCalenAtd(dAlocDe,dAlocAte,cCodAtend,aCalendAtd,aCalendInf)

@param		ExpD1	Alocacao De.
			ExpD2	Alocacao Ate.
			ExpC3	Codigo do atendente.
			ExpA4	Calendario do atendente (Referencia).
			ExpA5	Informacoes do calendario do atendente (Referencia).
			ExpC6	Turno a ser considerado para montar o calendario.
			ExpC7	Sequencia a ser considerada para montar o calendario.
			ExpL8	Utiliza o CriaCalend para transferencia.
			ExpL9	Exibe a mensagem de help quando existir conflito de alocação?
			ExpC10	Dia inicial do período de alocação.
			ExpC11	Codigo do local de destino da alocacao, para validacao em caso de RESERVA TECNICA
			ExpC12	Filial do atendente para uso na pesquisa ao atendente (default: xFilial("AA1"))
			ExpC13	Variável para captura da descrição do erro.

@return		ExpL	Verdadeiro / Falso.

@author		Anderson Silva
@since		23/11/2012
@version	P12
/*/
Function TxCalenAtd(dAlocDe,dAlocAte,cCodAtend,aCalendAtd,aCalendInf,cTurno,cSequen,lTransf,lExibeHelp,dPerIni, cLocAloc, cFilAtd, cErroRet)

Local lRetorno  	:= .F.												//	Retorno da rotina.
Local aTabPadrao	:= {}        										//	Tabela de horario padrao.
Local aTabCalend	:= {}   											//	Calendario do atendente retornando pelo CriaCalend.
Local aPeriodos		:= {}   											// 	Calendario do atendente (Tratato).
Local nX			:= 0       											//	Incremento utilizado no for.
Local lTecXRh 		:= SuperGetMv("MV_TECXRH",,.F.) 					//	Integracao Gestao de Servicos com RH?.
Local nTotalHrs	 	:= 0    											// 	Total de horas.
Local nDiasTrab	 	:= 0												//	Total de dias trabalhados.
Local nTotHrsTrb	:= 0												//	Total de horas trabalhadas.
Local cTurnoTrb		:= ""												//	Turno de trabalho.
Local cSeqTurno		:= "" 												//	Sequencia do turno.
Local cHrEntrada	:= ""												//	Hora de entrada.
Local cHrSaida		:= ""												//	Hora de saida.
Local dPonMes           := cTod("//")

Default dAlocDe 	:= cTod("//")  										//	Alocacao de.
Default dAlocAte	:= cTod("//") 										//	Alocacao ate.
Default cCodAtend	:= "" 												//	Codigo do atendente.
Default cTurno		:= "" 												//	Turno de trabalho.
Default cSequen		:= "" 												//	Sequencia do turno.
Default aCalendAtd 	:= {}												//	Calendario do atendente (Referencia)
Default aCalendInf 	:= {}  												//	Informacoes do calendario (Referencia)
Default lTransf		:= .F. 												//	Utiliza o CriaCalend para transferencia de atendentes.
Default lExibeHelp 	:= .T.												// Define se será exebido help quando identificar divergência na alocação
Default dPerIni		:= STOD("")
Default cLocAloc    := "" 												//  Codigo do local de destino da alocacao do atendente
Default cFilAtd 	:= xFilial("AA1")									// Código da filial do atendente selecionado para alocação
Default cErroRet 	:= "" 												// variável para retorno mais inteligente com a descrição do erro

DbSelectArea("AA1")
DbSetOrder(1)

If !(AA1->(DbSeek( cFilAtd+cCodAtend )))
	cErroRet := STR0071  // "Atendente não encontrado."
Else
    dPonMes :=  StoD(Substr(SUPERGETMV('MV_PONMES'),1,8))
	If lTecXRh .And. !lTransf

		DbSelectArea("SRA")
		DbSetOrder(1)

		If DbSeek(AA1->AA1_FUNFIL + AA1->AA1_CDFUNC)

			If 	!Empty(cTurno)

				If cTurno == SRA->RA_TNOTRAB .AND. cSequen == SRA->RA_SEQTURN
                       lRetorno := CriaCalend( dPonMes,; //dPonMes               ,;    //01 -> Data Inicial do Periodo
											dAlocAte		,;	//02 -> Data Final do Periodo
											SRA->RA_TNOTRAB	,;	//03 -> Turno Para a Montagem do Calendario
											SRA->RA_SEQTURN ,;	//04 -> Sequencia Inicial para a Montagem Calendario
											@aTabPadrao		,;	//05 -> Array Tabela de Horario Padrao
											@aTabCalend		,;	//06 -> Array com o Calendario de Marcacoes
											SRA->RA_FILIAL  ,;	//07 -> Filial para a Montagem da Tabela de Horario
											SRA->RA_MAT		,;	//08 -> Matricula para a Montagem da Tabela de Horario
											SRA->RA_CC 		,;	//09 -> Centro de Custo para a Montagem da Tabela
											,;
											,;
											,;
											,;
										    .F.)

				Else
					DbSelectArea("SR6")
					SR6->( DbSetOrder( 1 ) )// R6_FILIAL + R6_TURNO

					DbSelectArea("SPJ")
					SPJ->( DbSetOrder( 1 ) ) // PJ_FILIAL + PJ_TURNO + PJ_SEMANA + PJ_DIA

					If SR6->( DbSeek( xFilial("SR6", SRA->RA_FILIAL) + cTurno ) ) .And. ;
						SPJ->( DbSeek( xFilial("SPJ", SRA->RA_FILIAL) + cTurno + cSequen ) )


                       lRetorno := CriaCalend( dPonMes,;
												dAlocAte				,;	//02 -> Data Final do Periodo
												cTurno					,;	//03 -> Turno Para a Montagem do Calendario
												cSequen 				,;	//04 -> Sequencia Inicial para a Montagem Calendario
												@aTabPadrao			,;	//05 -> Array Tabela de Horario Padrao
												@aTabCalend			,;	//06 -> Array com o Calendario de Marcacoes
												SRA->RA_FILIAL  		,;	//07 -> Filial para a Montagem da Tabela de Horario
												,;	//08 -> Matricula para a Montagem da Tabela de Horario
												,;	//09 -> Centro de Custo para a Montagem da Tabela
												,;
												,;
												,;
												,;
												.F.)

					Else
						cErroRet := STR0078 + alltrim(cTurno) + STR0079  // "O turno de trabalho: " + " não foi localizado na tabela de Turnos de Trabalho (SR6) ou na tabela de Horario Padrão (SPJ). "
					EndIf
				EndIf
			Else
				cErroRet := STR0073 // "Turno não informado para a criação do calendário."
			EndIf
		Else
			cErroRet := STR0074 // "Atendente tem vínculo com funcionário e o funcionário não foi encontrado na tabela SRA."
		EndIf
	Else

		cTurnoTrb	:= IIF(Empty(cTurno),AA1->AA1_TURNO,cTurno)
		cSeqTurno	:= IIF(Empty(cSequen),"01",cSequen)


        lRetorno := CriaCalend( dPonMes,;
								dAlocAte		,;	//02 -> Data Final do Periodo
								cTurnoTrb		,;	//03 -> Turno Para a Montagem do Calendario
								cSeqTurno		,;	//04 -> Sequencia Inicial para a Montagem Calendario
								@aTabPadrao		,;	//05 -> Array Tabela de Horario Padrao
								@aTabCalend		,;	//06 -> Array com o Calendario de Marcacoes
								xFilial("SRA")	,;	//07 -> Filial para a Montagem da Tabela de Horario
								,;	//08 -> Matricula para a Montagem da Tabela de Horario
								,;	//09 -> Centro de Custo para a Montagem da Tabela
								,;
								,;
								,;
								,;
								.F.)
	EndIf

	If lRetorno

		For nX := 1 To Len(aTabCalend) Step 2
			If aTabCalend[nX][6] == "S" .And. ;
				aTabCalend[nX][1] >= dAlocDe .And. aTabCalend[nX][1] <= dAlocAte // verifica se a data está no período da alocação

				cHrEntrada := IntToHora(TxAjtHoras(aTabCalend[nX][3]))
				cHrSaida   := IntToHora(TxAjtHoras(aTabCalend[nX+1][3]))
				nTotHrsTrb := SubtHoras(aTabCalend[nX][1],cHrEntrada,IIf(aTabCalend[nX+1][3] < aTabCalend[nX][3],  aTabCalend[nX][1]+1, aTabCalend[nX][1] ), cHrSaida)

				//Criar validação para o dia a dia.
				If lExibeHelp .And. TxExistAloc(cCodAtend,aTabCalend[nX][1],cHrEntrada,aTabCalend[nX+1][1],cHrSaida,0,,,cLocAloc)
					Help( ,, "TxExistAloc",, ;
						I18N( STR0055,;  // "Já existe alocação para o atendente no período de '#1[diaEnt]# - #2[horaEnt]#' a '#3[diaSai]# - #4[horaSai]#'"
						{aTabCalend[nX][1],cHrEntrada,aTabCalend[nX+1][1],cHrSaida}), 1, 0 )
					Return .F.
				EndIf

				aAdd(aPeriodos,{	aTabCalend[nX][1], TxRtDiaSem(aTabCalend[nX][1]),; // dia entrada ## dia da semana
									cHrEntrada, cHrSaida, IntToHora(nTotHrsTrb),; // hora entrada ## hora saída ## total de horas
									aTabCalend[nX][8], aTabCalend[nX+1][1], ; // sequência do turno ## dia saída
									aTabCalend[nX][48]}) // data referência
				nTotalHrs	+= nTotHrsTrb
				If aTabCalend[nX][4] == "1E"
					nDiasTrab	+= 1
				EndIf
			EndIf
		Next nX

		aCalendAtd	:= aPeriodos
		aCalendInf	:= {nTotalHrs,nDiasTrab}
	ElseIf Empty(cErroRet)
		cErroRet := STR0075 // "Problemas na geração do calendário padrão para o item ou atendente."
	EndIf
EndIf

Return( lRetorno )

/*/{Protheus.doc} TxSaldoCfg
Funcao para controlar o saldo de horas da configuracao da alocacao.

@sample 	TxSaldoCfg(cIdAloc,nValor,lSoma)

@param		ExpC1	Id. da configuracao da alocacao.
			ExpN2	Quantidade de horas para compor o saldo.
			ExpL3	Tipo de operacao (.T. para devolver horas para o saldo / .F. para consumir o saldo de horas.) .F.(Default)

@return		ExpN	 Saldo de Horas.

@author		Anderson Silva
@since		23/11/2012
@version	P12
/*/
Function TxSaldoCfg(cIdAloc,nQtdHrs,lSoma)

Local aAreaABQ 	:= ABQ->(GetArea())
Local nSaldo	:= 0

Default cIdAloc := ""
Default nQtdHrs	:= 0
Default lSoma	:= .F.

DbSelectArea("ABQ")
DbSetOrder(1)

If DbSeek(xFilial("ABQ")+cIdAloc)
 	nSaldo := IIF(lSoma,(ABQ->ABQ_SALDO+nQtdHrs),(ABQ->ABQ_SALDO-nQtdHrs))
	RecLock("ABQ",.F.)
	Replace ABQ->ABQ_SALDO With nSaldo
	MsUnLock()
EndIf

RestArea(aAreaABQ)

Return( nSaldo )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TxAjtHoras
Ajusta o formato da horas. (Exemplo 1.3 para 1.5)

@sample TxAjtHoras(nHoras)

@param	ExpN1	Horas sem o ajuste.

@return	ExpN	Saldo de Horas.

@author		Anderson Silva
@since		23/11/2012
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TxAjtHoras(nHoras)

Local nHrsInt 	:= 0
Local nResul	:= 0
Local nHrsAjt	:= 0

Default nHoras	:= 0

nHrsInt := Int(nHoras)

nResul 	:= ( nHoras - nHrsInt ) * 100

nHrsAjt :=  ( nResul + ( nHrsInt * 60 ) ) / 60

Return( nHrsAjt )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TxLogFile()

Cria um Arquivo de Log dentro da pasta do startpath do appserver.ini.
O arquivo sera nomeado de acordo com o parametro + "-" +

@param ExpC:Nome do Arquivo de Log. Ex: "atendimento" para gerar atendimento-20130131.log
@param ExpC:Texto a ser gravado no arquivo de log

/*/
//--------------------------------------------------------------------------------------------------------------------
Function TxLogFile(cLogName,cText,lPrintTime,lBreak,lAddTimeSt)

Local cFileLog := ""		//Path do arquivo de log a ser gravado
Local nAux					//Auxilia na construcao do arquivo de log
Default lPrintTime := .T.
Default lBreak := .T.
Default lAddTimeSt := .T.

cFileLog := TxLogPath(cLogName,lAddTimeSt)

If File(cFileLog)
	nAux := FOpen(cFileLog, FO_READWRITE+FO_SHARED)
Else
	nAux := FCreate(cFileLog,0)
EndIf

If nAux != -1
	FSeek(nAux,0,2)
	FWrite(nAux, AllTrim(IIF(lPrintTime,DtoC(Date())+" ","")) + IIF(lPrintTime,TIME() + " - ","") + cText + IIF(lBreak,CRLF,""))
	FClose(nAux)
EndIf

Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TxLogPath()

Retorna o nome do arquivo de log a partir do prefixo informado.

@param ExpC:Nome do Arquivo de Log. Ex: "atendimento" para gerar atendimento-20130131.log

@return cFileLog nome-data.log

/*/
//--------------------------------------------------------------------------------------------------------------------
Function TxLogPath(cLogName, lAddTimeSt)
Default lAddTimeSt := .T.

cFileLog  := ALLTRIM(GetPvProfString(GetEnvServer(),"startpath","",GetADV97()))

If Subs(cFileLog,Len(cFileLog),1) <> "\"
	cFileLog += "\"
EndIf
cFileLog += "GestaoServicos\"

MakeDir(cFileLog)

cFileLog += cLogName + IIF(lAddTimeSt,"-" + AllTrim(DToS(Date())),"") + ".LOG"

Return cFileLog


//------------------------------------------------------------------------------
/*/{Protheus.doc} TxSX3Campo
Função auxiliar que retorna dados de um campo no SX3.

@sample 	TxSX3Campo( cCampo )

@param		cCampo	Nome do campo que deseja obter informações.

@return	aDados Dados do campo.
					[1] Título do campo.
					[2] Descrição do campo.
					[3] Tamanho do campo.
					[4] Decimais do campo.
					[5] Picture do campo.

@author	Danilo Dias
@since		13/11/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function TxSX3Campo( cCampo )

Local aArea	:= GetArea()
Local aDados	:= {}

DbSelectArea('SX3')		//Campos da tabela
SX3->( DbSetOrder(2) )	//X3_CAMPO
SX3->( DbGoTop() )

If ( SX3->( MsSeek( cCampo ) ) )

	AAdd( aDados, X3Titulo() )			//Retorna título do campo no X3
	AAdd( aDados, X3Descric() )			//Retorna descrição do campo no X3
	If VALTYPE(TamSX3(cCampo)) == "A" .AND. LEN(TamSX3(cCampo)) >= 2
		AAdd( aDados, TamSX3(cCampo)[1] )	//Retorna tamanho do campo
		AAdd( aDados, TamSX3(cCampo)[2] )	//Retorna quantidade de casas decimais do campo
	EndIf
	AAdd( aDados, Alltrim(X3Picture(cCampo)) )	//Retorna a picture do campo
	AAdd( aDados, SX3->X3_TIPO )
	AAdd( aDados, X3CBox() )

EndIf

RestArea( aArea )

Return aDados

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} checkSIX

Verifica se indice informado existe no dicionário.
Rotina utilizada para a realização de proteção dos indices novos no fonte

@param cALias  String - Tabela do dicionario
@param nOrder Integer - numero do indice a ser verificado.

@owner  rogerio.souza
@author  rogerio.souza
@version V11
@since   12/06/2013
@return lRet Boolean
/*/
//--------------------------------------------------------------------------------------------------------------------
Function checkSIX(cAlias, nOrder)
Local aArea := GetArea()
Local aAreaSIX := SIX->(GetArea())
Local lRet := .F.

SIX->(DbSetOrder(1))//INDICE+ORDEM
If SIX->(MSSeek(cAlias+cValToChar(nOrder)))
	lRet := .T.
EndIf

RestArea(aAreaSIX)
RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AtCpyData
	Realiza a cópia dos dados de um modelo para outro
evitando sobrepor conteudo de alguns campos, informados na exceção

@sample 	CpyData

@since		23/09/2013
@version	P11.90

@param 		oMdlFrom, Objeto, Modelo de origem dos dados a serem copiado
@param 		oMdlTo, Objeto, Modelo destino dos dados
@param 		aNoCpos, Array, lista com os campos que não devem ter o conteúdo copiado

@return 	lRet, Logico, status da cópia dos dados

/*/
//------------------------------------------------------------------------------
Function AtCpyData( oMdlFrom, oMdlTo, aNoCpos )

Local lRetCpy  := .T.
Local nCpos := 0

Local aStruFrom := oMdlFrom:GetStruct():GetFields()
Local aStruTo   := oMdlTo:GetStruct():GetFields()

Local lExAllStru := .F.
Local xTmpValue   := Nil
//Campos que dever ser utilizados por SetValue, para que disparem os gatilhos de cálculo
Local aCposAux  := {	'TFJ_TOTRH','TFJ_TOTMC','TFJ_TOTMI','TFJ_TOTLE',;
						'TFL_TOTRH','TFL_TOTMI','TFL_TOTMC','TFL_TOTLE','TFL_TOTAL','TFL_TOTIMP','TFL_MESRH','TFL_MESMI','TFL_MESMC','TFL_MESIMP',;
						'TFF_SUBTOT','TFF_TOTMI','TFF_TOTMI','TFF_TOTMC','TFF_TOTMES','TFF_PERFIM',;
						'TFI_TOTAL','TEV_MODCOB','TEV_VLRUNI','TEV_SUBTOT','TEV_VLTOT','TEV_QTDE',;
						'TFG_TOTAL','TFG_TOTGER','TFG_PERFIM',;
						'TFH_TOTAL','TFH_TOTGER','TFH_PERFIM' ;
					}


Local lOkWhen   := .F.

lRetCpy := ( Len( aStruFrom ) > 0 .And. Len( aStruTo ) > 0 )

If lRetCpy
	For nCpos := 1 To Len( aStruTo )

		lExAllStru := ( aScan( aStruFrom, {|x| x[MODEL_FIELD_IDFIELD]==aStruTo[ nCpos, MODEL_FIELD_IDFIELD ] } ) > 0 .And. ;
						aScan( aNoCpos, aStruTo[ nCpos, MODEL_FIELD_IDFIELD ] ) == 0 )

		lOkWhen := If( Valtype(aStruTo[ nCpos, MODEL_FIELD_WHEN ]) == 'B', ;
					Eval( aStruTo[ nCpos, MODEL_FIELD_WHEN ], oMdlTo, aStruTo[ nCpos, MODEL_FIELD_IDFIELD ]  ), ;
					.T. )

		If lExAllStru .And. lOkWhen

			xTmpValue := oMdlFrom:GetValue( aStruTo[ nCpos, MODEL_FIELD_IDFIELD ] )
			If aScan( aCposAux, {|x| x==aStruTo[ nCpos, MODEL_FIELD_IDFIELD ] } ) > 0
				If ( (oMdlFrom:GetModel():GetId() == "TECA740" .OR. oMdlFrom:GetModel():GetId() == "TECA740F") .AND. ;
						aStruTo[ nCpos, MODEL_FIELD_IDFIELD ] $ "TFF_SUBTOT|TFG_TOTAL|TFG_TOTGER|TFH_TOTAL|TFH_TOTGER" .AND.;
							 oMdlFrom:GetValue( LEFT(aStruTo[ nCpos, MODEL_FIELD_IDFIELD ],4) + "COBCTR" ) == '2' )
					lRetCpy := lRetCpy .AND. oMdlTo:LoadValue( aStruTo[ nCpos, MODEL_FIELD_IDFIELD ], xTmpValue )
				Else
					lRetCpy := lRetCpy .AND. oMdlTo:SetValue( aStruTo[ nCpos, MODEL_FIELD_IDFIELD ], xTmpValue )
				EndIf
			Else
				lRetCpy := lRetCpy .AND. oMdlTo:LoadValue( aStruTo[ nCpos, MODEL_FIELD_IDFIELD ], xTmpValue )
			EndIf
		EndIf

	Next nCpos
Else
	Help(,,'CPYMDL01',,STR0024,1,0)  // 'Estrutura dos campos vazia'
EndIf

Return lRetCpy

//------------------------------------------------------------------------------
/*/{Protheus.doc} AtErroMvc
	Captura o erro no objeto do mvc e gera o log. Pode ser usado tbm em execauto

@sample 	AtErroMvc(oModel)

@since		24/02/2014
@version	P12

@param 		oMdl, Objeto, objeto do mvc MpFormModel/FwFormModel

/*/
//------------------------------------------------------------------------------
Function AtErroMvc( oMdl )

Local aMsgErro := {}

DEFAULT oMdl := FwModelActive()

		aMsgErro := oMdl:GetErrorMessage()

		AutoGrLog( STR0044 + ' [' + AllToChar( aMsgErro[1] ) + ']' )	//"Id do formulário de origem:"
		AutoGrLog( STR0045 + ' [' + AllToChar( aMsgErro[2] ) + ']' )	//"Id do campo de origem: "
		AutoGrLog( STR0046 + ' [' + AllToChar( aMsgErro[3] ) + ']' )	//"Id do formulário de erro: "
		AutoGrLog( STR0047 + ' [' + AllToChar( aMsgErro[4] ) + ']' )	//"Id do campo de erro: "
		AutoGrLog( STR0048 + ' [' + AllToChar( aMsgErro[5] ) + ']' )	//"Id do erro: "
		AutoGrLog( STR0049 + ' [' + AllToChar( aMsgErro[6] ) + ']' )	//"Mensagem do erro: "
		AutoGrLog( STR0050 + ' [' + AllToChar( aMsgErro[7] ) + ']' )	//"Mensagem da solução: "
		AutoGrLog( STR0051 + ' [' + AllToChar( aMsgErro[8] ) + ']' )	//"Valor atribuído: "
		AutoGrLog( STR0052 + ' [' + AllToChar( aMsgErro[9] ) + ']' )	//"Valor anterior: "

		If ValType(oMdl:GetModel(AllToChar( aMsgErro[3] ))) == "O" .And. ;
			oMdl:GetModel(AllToChar( aMsgErro[3] )):ClassName() == 'FWFORMGRID' .And. ;
			oMdl:GetModel(AllToChar( aMsgErro[3])):GetLine() > 0

			AutoGrLog( STR0053 + ' [' + AllTrim( AllToChar( oMdl:GetModel(AllToChar( aMsgErro[3]) ):GetLine() ) ) + ']' )	//"Erro no Item: "
		EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} TxDiaTrab()
       Verfica se o dia informado é um dia trabalhado de acordo com o turno

@sample      TxDiaTrab(dData, cTurno, cSeq)

@since       26/02/2014
@version     P12

@param              dData dia a ser verificado
@param       cTurno turno que será verificado
@param       cSeq sequencia dos dias do turno
@param       cMat Matrícula do funcionário para geração do criacalend com base no funcionário
@param       cCC centro de custo do funcionário

/*/
//------------------------------------------------------------------------------
Function TxDiaTrab(dData, cTurno, cSeq, cMat, cCC)
Local lRet := .F.
Local aTabPadrao:= {}
Local aTabCalend := {}
Local lRetorno := .T.

Default cSeq := "01"
Default cMat := ""
Default cCC  := ""

If Empty(cMat) .Or. Empty(cCC)

	lRetorno := CriaCalend(    dData,;					//01 -> Data Inicial do Periodo
	                           dData,;					//02 -> Data Final do Periodo
	                           cTurno,;				//03 -> Turno Para a Montagem do Calendario
	                           cSeq,;					//04 -> Sequencia Inicial para a Montagem Calendario
	                           @aTabPadrao,;			//05 -> Array Tabela de Horario Padrao
	                           @aTabCalend,;			//06 -> Array com o Calendario de Marcacoes
	                           xFilial("SRA"),;		//07 -> Filial para a Montagem da Tabela de Horario
	                      )
Else
	lRetorno := CriaCalend(    dData,;					//01 -> Data Inicial do Periodo
	                           dData,;					//02 -> Data Final do Periodo
	                           cTurno,;				//03 -> Turno Para a Montagem do Calendario
	                           cSeq,;					//04 -> Sequencia Inicial para a Montagem Calendario
	                           @aTabPadrao,;			//05 -> Array Tabela de Horario Padrao
	                           @aTabCalend,;			//06 -> Array com o Calendario de Marcacoes
	                           xFilial("SRA"),;		//07 -> Filial para a Montagem da Tabela de Horario
	                           cMat,;					//08 -> Matrícula do funcionário para a consulta da tabela de horário
	                           cCC )					//09 -> Centro de custo para carregar a tabela
EndIf

If Len(aTabCalend) > 0 .AND. Len(aTabCalend[1])>=6
	If aTabCalend[1][6] == "S"
		lRet := .T.
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TxTransfAA1()
Monta o array aCampos para replicar as informações no cadastro de atendente

@since 18/03/2014
@version 1.0
/*/
//------------------------------------------------------------------------------
Function TxTransfAA1(cEmpAnt, cEmpAte,cFilDe, cFilAte,  cMatDe, cMatAte, cCcDe, cCcuAte, cFuncDe, cFuncAte,;
						cTurnDe, cTurnAte, cSeqDe, cSeqAte, cNomDe, cNomAte)
Local aCampos 		:= {}
Local lInteRHAA1	:= If(FindFunction("IntegRHAA1"),IntegRHAA1(),.F.)
Local aNewAA1		:= {}
Local lGpea180		:= IsInCallStack("GPEA180") //Verifica se a chamada foi feita para a transferencia de funcionario

Default cEmpAnt	:= ""
Default cEmpAte	:= ""
Default cFilDe	:= ""
Default cFilAte	:= ""
Default cMatDe	:= ""
Default cMatAte	:= ""
Default cCcDe		:= ""
Default cCcuAte	:= ""

If lInteRHAA1

	//Mudança de Filial
	If cEmpAte == cEmpAnt .And. cFilDe <> cFilAte
		Aadd(aCampos,{"RA_FILIAL",cFilAte})
	EndIf

	//Mudança de Centro de Custo
	If cEmpAte == cEmpAnt .And. cCcDe <> cCcuAte
		Aadd(aCampos,{"RA_CC",cCcuAte})
	EndIf

	//Mudança de Matricula
	If cEmpAte == cEmpAnt .And. cMatDe <> cMatAte
		Aadd(aCampos,{"RA_MAT",cMatAte})
	EndIf

	//Mudança de Funçao
	If cEmpAte == cEmpAnt .And. cFuncDe <> cFuncAte
		Aadd(aCampos,{"RA_CODFUNC",cFuncAte})
	EndIf

	//Mudança de Turno
	If cEmpAte == cEmpAnt .And. cTurnDe <> cTurnAte
		Aadd(aCampos,{"RA_TNOTRAB",cTurnAte})
	EndIf

	//Mudança de Sequencia
	If cEmpAte == cEmpAnt .And. cSeqDe <> cSeqAte
		Aadd(aCampos,{"RA_SEQTURN",cSeqAte})
	EndIf

	//Mudança de Nome
	If cEmpAte == cEmpAnt .And. cNomDe <> cNomAte
		Aadd(aCampos,{"RA_NOME",cNomAte})
	EndIf

	If lGpea180
		aNewAA1 := TxNewAA1(cFilAte,cMatAte,cNomAte,cFuncAte,cTurnAte,cSeqAte,cCcuAte)
	EndIf

	At020AltRH( cFilDe, cMatDe, aCampos, , , cFilAte, cEmpAnt, cEmpAte, aNewAA1)

EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} IntegRHAA1()
Validação de integração Gest.Serv. com RH para replicar as informações no cadastro de atendente

@since 03/07/2014
@version 1.0
/*/
//------------------------------------------------------------------------------
Function IntegRHAA1()
Local lRet := SuperGetMv("MV_TECXRH",,.F.) .And. FindFunction("At020AltRH")

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TxQtIntTrab()
	Conta a quantidade de intervalos em um determinado período

@sample 	TxQtIntTrab(dDataIni, dDataFim, cTurno, cSeq)

@since		22/04/2014
@version	P12

@param 		dDataIni data inicial do período para
@param 		dDataFim dia a ser verificado
@param		cTurno turno que será verificado
@param		cSeq sequencia dos dias do turno

/*/
//------------------------------------------------------------------------------
Function TxQtIntTrab(dDataIni,dDataFim, cTurno, cSeq)

Local aTabPadrao    := {}
Local aTabCalend    := {}
Local lRetorno      := .T.
Local nX			:= 0
Local nIntervalos	:= 0

Default cSeq := "01"

lRetorno := CriaCalend(	dDataIni		,;    //01 -> Data Inicial do Periodo
						dDataFim		,;    //02 -> Data Final do Periodo
						cTurno			,;    //03 -> Turno Para a Montagem do Calendario
						cSeq			,;    //04 -> Sequencia Inicial para a Montagem Calendario
						@aTabPadrao		,;    //05 -> Array Tabela de Horario Padrao
						@aTabCalend		,;    //06 -> Array com o Calendario de Marcacoes
						xFilial("SRA")	,;    //07 -> Filial para a Montagem da Tabela de Horario
						)

If Len(aTabCalend) > 0
	For nX := 1 To Len(aTabCalend)
		// avalia se é um dia trabalhado e se é um registro de entrada
		If Len(aTabCalend[1])>=6 .AND. aTabCalend[nX][6] == "S" .And. "E"$aTabCalend[nX][4]
			nIntervalos++
		EndIf
	Next nX
EndIf

Return nIntervalos

//------------------------------------------------------------------------------
/*/{Protheus.doc} TxCalF3Medicao / TxRetF3Medicao
	Chama a consulta padrão das medições com o filtro do contrato

@sample 	TxCalF3Medicao( '000000000000009' )

@since		27/06/2014
@version	P12

@param 		xVal, Caracter, número do contrato para receber o filtro das medições

/*/
//------------------------------------------------------------------------------
Function TxCalF3Medicao( xVal )
Local lRet := .F.

If ValType(xVal)=='C'
	cCNDContra := xVal // cria a variável que vai filtrar o código do contrato
	lRet := ConPad1(,,,'CNDTEC',,,.F.)
EndIf

Return lRet
//------------------------------------------------------------------------------
Function TxRetF3Medicao()
cCNDContra := ''  // zera o código do contrato que recebeu o filtro
Return CND->CND_NUMMED

Static Function GetSqlPeri(aPeriodos, lTCU)
Local cRet := ""
Local nI := 1
Local dDtIni := CTOD("//")
Local cHrIni := ""
Local dDtFim := CTOD("//")
Local cHrFim := ""

Default lTCU := .F.

If Len(aPeriodos)> 0
	cRet += " AND ( "

	For nI := 1 To Len( aPeriodos )

		dDtIni := aPeriodos[nI][1]
		cHrIni := aPeriodos[nI][2]
		dDtFim := aPeriodos[nI][3]
		cHrFim := aPeriodos[nI][4]

		IF Empty(dDtIni)
			dDtIni := CTOD("//")
		ENDIF

		IF Empty(cHrIni)
			cHrIni := ""
		ENDIF

		IF Empty(dDtFim)
			dDtFim := CTOD("//")
		ENDIF

		IF Empty(cHrFim)
			cHrFim := ""
		ENDIF

		If ( dDtIni = dDtFim )	//Quando as datas de início e fim do período forem iguais
			If !lTCU
				cRet += " ( ( ABB_DTINI = '" + DtoS(dDtIni) + "' AND ABB_HRINI > '" + cHrIni + "' AND ABB_HRINI < '" + cHrFim + "' ) OR" 					//Agendas que comecem dentro do período
				cRet += " ( ABB_DTFIM = '" + DtoS(dDtIni) + "' AND ABB_HRFIM > '" + cHrIni + "' AND ABB_HRFIM < '" + cHrFim + "' ) OR" 							//Agendas que terminem dentro do período
			Else
				cRet += " ( ( ABB_DTINI = '" + DtoS(dDtIni) + "' AND ABB_HRINI >= '" + cHrIni + "' AND ABB_HRINI < '" + cHrFim + "' ) OR" 					//Agendas que comecem dentro do período
				cRet += " ( ABB_DTFIM = '" + DtoS(dDtIni) + "' AND ABB_HRFIM > '" + cHrIni + "' AND ABB_HRFIM <= '" + cHrFim + "' ) OR" 							//Agendas que terminem dentro do período
			EndIf 
			cRet += " ( ABB_DTINI = '" + DtoS(dDtIni) + "' AND ABB_HRINI < '" + cHrIni + "' AND ABB_DTFIM = '" + DtoS(dDtFim) + "' AND ABB_HRFIM > '" + cHrFim + "' ) OR"	//Agendas que comecem antes e termine depois do período, tendo a mesma data de início e fim
			cRet += " ( ABB_DTINI < '" + DtoS(dDtIni) + "' AND ABB_DTFIM > '" + DtoS(dDtFim) + "' ) )"			  											//Agendas que comecem antes e termine depois do período, tendo data de início e fim diferentes

		Else					//Quando as datas de início e fim do período forem diferentes

			cRet += " ( ( ABB_DTINI = '" + DtoS(dDtIni) + "' AND ABB_HRINI > '" + cHrIni + "' ) OR"		//Agendas que comecem dentro do período (Data Inicial)
			cRet += " ( ABB_DTINI = '" + DtoS(dDtFim) + "' AND ABB_HRINI < '" + cHrFim + "' ) OR"				//Agendas que comecem dentro do período (Data Final)
			cRet += " ( ABB_DTFIM = '" + DtoS(dDtIni) + "' AND ABB_HRFIM > '" + cHrIni + "' ) OR"				//Agendas que terminem dentro do período
			cRet += " ( ABB_DTINI = '" + DtoS(dDtIni) + "' AND ABB_DTFIM = '" + DtoS(dDtFim) + "' ) )"				//Agendas que comecem e terminem nas mesmas datas do período

		EndIf

		If ( Len(aPeriodos) > nI )
			cRet += " OR"
		Else
			cRet += " )"
		EndIf

	Next nI
EndIf

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ExistFilTFF()
Verifica se o campo ABQ_FILTFF existe no banco

@since 24/02/2015
@version 12
/*/
//------------------------------------------------------------------------------
Function ExistFilTFF()

Local lRet     := .F.
Local aAreaABQ := GetArea()

DbSelectArea("ABQ")
lRet := ABQ->(FieldPos("ABQ_FILTFF"))>0 // Filial do Recursos Humanos

RestArea(aAreaABQ)

RETURN lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TXRetAloc
Retorna as informações de alocação de um determinado funcionário

@sample 	TXRetAloc(_cFunFil, _cMatFunc, _dDtIni, _dDtFim)

@param		ExpC1	Filial do Funcionario
@param		ExpC2	Matricula do Funcionario
@param		ExpD3	Data Inicial da Alocacao
@param		ExpD4	Data Final da Alocacao

@return	ExpA	Array dos dados de Alocacao

@author	TOTVS
@since		22/04/2015
@version	P12.1.5
/*/
//------------------------------------------------------------------------------
FUNCTION TXRetAloc(_cFunFil, _cMatFunc, _dDtIni, _dDtFim)

Local aAreaAloc   := GetArea()	// Guarda a Area de Trabalho
Local aRetAloc    := {}			// Vetor de dados da alocacao
Local lMV_GSLOG   := SuperGetMV('MV_GSLOG',,.F.)
Local oGsLog	  := GsLog():new(lMV_GSLOG)
// Temporarios
Local _cAliasABB_ := ''
Local _cAliasABR_ := ''

// Variavel de Controle
Local lOk         := .T.

// Variaveis Auxiliares
Local _cCodTec    := Space(TamSx3('AA1_CODTEC')[1])
Local _cDataI     := ''
Local _cDataF     := ''
Local _cDataI2    := ''
Local _cDataF2    := ''
Local _cHoraI2    := ''
Local _cHoraI2_1  := ''
Local _cHoraF2    := ''
Local _cHoraF2_1  := ''
Local cMsgDia     := ''
Local _dDtRef := CTOD('//')
Local _nPosABB    := 0
Local _cManut     := Space(TamSx3('ABB_MANUT')[1])
Local aEscala	  := {}
Local aTabCalend  := {}
Local aTabPadrao  := {}
Local aAuxPeriod  := {} 
Local aDePara := {STR0107,;		//[01] "Filial do Posto"
					STR0108,;	//[02] "Data de Referência"
					STR0109,;	//[03] "Data Inicial"
					STR0110,;	//[04] "Horário Inicial"
					STR0111,;	//[05] "Data Final"
					STR0112,;	//[06] "Horário Final"
					STR0113,;	//[07] "Local"
					STR0114,;	//[08] "Turno"
					STR0115,;	//[09] "Contrato"
					STR0116,;	//[10] "Cliente"
					STR0117,;	//[11] "Loja"
					STR0118,;	//[12] "Feriado? (.T. = Sim, .F. = Não)"
					STR0119,;	//[13] "Falta? (.T. = Sim, .F. = Não)"
					STR0120,;	//[14] "Substituto? (.T. = Sim, .F. = Não)"
					STR0121}	//[15] "Código do Posto (TFF_COD)"
Local cFilTFF	  := xFilial("TFF")

Local nI			:= 0
Local nZ			:= 0
Local nTotalDias 	:= 0
Local nTotEsc		:= 0

Default _dDtIni := CTOD('//')
Default _dDtFim := CTOD('//')

// Validacao dos Parametros

// Filial do Funcionario
If ! Empty(_cFunFil)
	_cFunFil := PadR(_cFunFil,TamSx3('AA1_FUNFIL')[1],' ')
EndIf

// Matricula do Funcionario
If Empty(_cMatFunc)
	lOk := .F.
Else
	_cMatFunc := PadR(_cMatFunc,TamSx3('AA1_CDFUNC')[1],' ')
EndIf

// Data Inicial
If lOk .AND. Empty(_dDtIni)
	lOk := .F.
Else
	_cDataI := DTOS(_dDtIni)
EndIf

// Data Final
If lOk .AND. Empty(_dDtFim)
	lOk := .F.
Else
	_cDataF := DTOS(_dDtFim)
EndIf

// Valida o Periodo
If lOk .AND. _dDtIni > _dDtFim
	lOk := .F.
EndIf

// Funcionario
If lOk
	DbSelectArea("AA1")
	AA1->(DbSetOrder(7)) // AA1_FILIAL, AA1_CDFUNC, AA1_FUNFIL
	If AA1->(DbSeek(xFilial("AA1") + _cMatFunc + _cFunFil))
		If Empty(AA1->AA1_CODTEC)
			lOk := .F.
		Else
			//Verifica se o atendente está disponivel ou bloqueado
			If AA1->AA1_ALOCA == "1" .Or. RegistroOK("AA1")
				_cCodTec := AA1_CODTEC
			Else
				lOk := .F.
			EndIf
		EndIf
	Else
		lOk := .F.
	EndIf
EndIf

//Descobrir a Escala e Calendario
If lOk
	aEscala := TxEscCalen(_cCodTec,_cDataI,_cDataF,.T.)
EndIf

//Realiza a projeção da agenda
If Len(aEscala) > 0
	nTotEsc := Len(aEscala)
	For nI := 1 to nTotEsc
		aSize(aTabCalend,0)
		aSize(aTabPadrao,0)
		aSize(aAuxPeriod,0)
		
		oGsLog:addLog(_cFunFil+_cMatFunc+'TXRetAloc',STR0122 + cValToChar(nI) + ")") //"Dados do aEscala: ("
		oGsLog:addLog(_cFunFil+_cMatFunc+'TXRetAloc',"cEscala (aEscala[nI][1]): " + aEscala[nI][1] )
		oGsLog:addLog(_cFunFil+_cMatFunc+'TXRetAloc',"cCalend (aEscala[nI][4]): " + aEscala[nI][4] )
		oGsLog:addLog(_cFunFil+_cMatFunc+'TXRetAloc',"dDatIni (aEscala[nI][5]): " + DTOS(aEscala[nI][5]) )
		oGsLog:addLog(_cFunFil+_cMatFunc+'TXRetAloc',"dDatFim (aEscala[nI][6]): " + DTOS(aEscala[nI][6]) )
		oGsLog:addLog(_cFunFil+_cMatFunc+'TXRetAloc',"cTurno (aEscala[nI][2]): " + aEscala[nI][2])
		oGsLog:addLog(_cFunFil+_cMatFunc+'TXRetAloc',"cSeq (aEscala[nI][3]): " + aEscala[nI][3])

		// Realiza a busca da agenda(ABB)
		_cAliasABB_ := TxBuscAgen(_cFunFil,_cMatFunc,_cCodTec,aEscala[nI][5],aEscala[nI][6])
		
		// Identifica o periodo das agendas
		If(!(_cAliasABB)->(Eof()))
			While !(_cAliasABB)->(Eof())
				If Empty(aAuxPeriod)
					AADD(aAuxPeriod,{(_cAliasABB)->TDV_DTREF, ''})
				Else
					aAuxPeriod[1][2] = (_cAliasABB)->TDV_DTREF
				EndIf
			(_cAliasABB)->(DbSkip())
			End

			(_cAliasABB)->(DBGOTOP())

			If !EMPTY(aAuxPeriod) .AND. EMPTY(aAuxPeriod[1][2])
				aAuxPeriod[1][2] = aAuxPeriod[1][1]
			EndIf
			
			TxProjEsc(aEscala[nI][1],aEscala[nI][4],aAuxPeriod[1][1],aAuxPeriod[1][2],aEscala[nI][2],aEscala[nI][3],@aTabPadrao,@aTabCalend)
		EndIf
	
		//Realiza a comparação da projeção com a agenda
		nZ := 1
		nTotalDias := Len(aTabCalend)
		oGsLog:addLog(_cFunFil+_cMatFunc+'TXRetAloc',"nTotalDias := Len(aTabCalend): " + cValToChar(nTotalDias) + CRLF)
		While nZ <= nTotalDias
			If !(_cAliasABB_)->(Eof()) .And. aTabCalend[ nZ, CALEND_POS_DATA ] >= (_cAliasABB_)->TDV_DTREF

				// Repassa o periodo da alocacao
				_cDataI2 := (_cAliasABB_)->ABB_DTINI
				_cDataF2 := (_cAliasABB_)->ABB_DTFIM

				// Repassa o horario
				_cHoraI2 := (_cAliasABB_)->ABB_HRINI
				_cHoraI2_1 := TecConvHr( SomaHoras( (_cAliasABB_)->ABB_HRINI, "00:01" ) )
				_cHoraF2 := (_cAliasABB_)->ABB_HRFIM
				_cHoraF2_1 := TecConvHr( SomaHoras( (_cAliasABB_)->ABB_HRFIM, "00:01" ) )

				// Armazena um registro por data de referencia
				If _dDtRef <> (_cAliasABB_)->TDV_DTREF
					Aadd(aRetAloc,{	(_cAliasABB_)->TFF_FILIAL,;								// 01 - FILIAL
										(_cAliasABB_)->TDV_DTREF,;							// 02 - DATA REFERENCIA
										(_cAliasABB_)->ABB_DTINI,;							// 03 - DATA INICIAL
										(_cAliasABB_)->ABB_HRINI,;							// 04 - HORA INICIAL
										(_cAliasABB_)->ABB_DTFIM,;							// 05 - DATA FINAL
										(_cAliasABB_)->ABB_HRFIM,;							// 06 - HORA FINAL
										(_cAliasABB_)->ABB_LOCAL,;							// 07 - LOCAL
										(_cAliasABB_)->TDV_TURNO,;							// 08 - TURNO
										(_cAliasABB_)->TFF_CONTRT,;							// 09 - CONTRATO
										(_cAliasABB_)->ABS_CODIGO,;							// 10 - CLIENTE
										(_cAliasABB_)->ABS_LOJA,;							// 11 - LOJA
										IIF(!Empty((_cAliasABB_)->TDV_FERIAD),.T.,.F.),;	// 12 - FERIADO
										IIF((_cAliasABB_)->ABN_TIPO == "01",.T.,.F.),;		// 13 - FALTA
										.F.,;												// 14 - SUBSTITUTO
										(_cAliasABB_)->TFF_COD})							// 15 - CODIGO RH

					// Repassa a Data de Referencia
					_dDtRef := (_cAliasABB_)->TDV_DTREF

					// Repassa se a alocacao sofreu algum tipo de manutencao
					_cManut := (_cAliasABB_)->ABB_MANUT

					// Contabiliza o numero de registros
					_nPosABB := Len(aRetAloc)
				Else

					Do Case
						// Caso exista mais de uma sequencia no turno atualiza
						// a data e hora final
						Case _cManut == (_cAliasABB_)->ABB_MANUT
							aRetAloc[_nPosABB][05] := (_cAliasABB_)->ABB_DTFIM
							aRetAloc[_nPosABB][06] := (_cAliasABB_)->ABB_HRFIM

						// Caso exista mais de uma sequencia no turno
						// e exista falta considera somente a hora produtiva
						Case (_cManut <> (_cAliasABB_)->ABB_MANUT) .AND. aRetAloc[_nPosABB][13] .AND. (_cAliasABB_)->ABN_TIPO <> "01"
							aRetAloc[_nPosABB][03] := (_cAliasABB_)->ABB_DTINI
							aRetAloc[_nPosABB][04] := (_cAliasABB_)->ABB_HRINI

					EndCase

					// Filtra as Manutencoes do Funcionario Substituto
					_cAliasABR_ := GetNextAlias()

					BeginSql Alias _cAliasABR_

						SELECT DISTINCT ABR_CODSUB
						     , ABR_AGENDA
						     , ABR_DTINI
						     , ABR_HRINI
						     , ABR_DTFIM
						     , ABR_HRFIM
						  FROM %Table:ABR% ABR
						 WHERE ABR.ABR_FILIAL = %xFilial:ABR%
						   AND ABR.ABR_CODSUB = %Exp:_cCodTec%
						   AND ABR.ABR_DTINI = %Exp:_cDataI2%
						   AND ABR.ABR_DTFIM = %Exp:_cDataF2%
						   AND (ABR.ABR_HRINI = %Exp:_cHoraI2%
						   OR ABR.ABR_HRINI = %Exp:_cHoraI2_1%)
						   AND (ABR.ABR_HRFIM = %Exp:_cHoraF2%
						   OR ABR.ABR_HRFIM = %Exp:_cHoraF2_1%)
						   AND ABR.%NotDel%

					EndSql

					// Atualiza o parametro como substituto
					IF (_cAliasABR_)->(!Eof())
						aRetAloc[_nPosABB][14] := .T.
					ENDIF

					// Finaliza o Temporario da Manutencao
					DbSelectArea(_cAliasABR_)
					(_cAliasABR_)->(DbCloseArea())

				EndIf

				DbSelectArea(_cAliasABB_)
				(_cAliasABB_)->(DbSkip())

				// Passa para o próximo dia
				nZ += 2

			Else
				If DiaExist(aTabCalend[nZ][CALEND_POS_DATA_APO], _cFunFil,_cMatFunc,_cCodTec)
					// Armazena um registro por data de referencia dentro da projeção
					If (_dDtRef <> (_cAliasABB_)->TDV_DTREF .Or. (_cAliasABB_)->(Eof())) .And. (aTabCalend[nZ][CALEND_POS_TIPO_MARC] == "1E" .And. aTabCalend[nZ][CALEND_POS_TIPO_DIA ] == "S")
						Aadd(aRetAloc,{	cFilTFF,;														// 01 - FILIAL
											aTabCalend[ nZ, CALEND_POS_DATA ],;							// 02 - DATA REFERENCIA
											aTabCalend[ nZ, CALEND_POS_DATA ],;							// 03 - DATA INICIAL
											IntToHora(aTabCalend[ nZ, CALEND_POS_HORA ]),;				// 04 - HORA INICIAL
											aTabCalend[ nZ, CALEND_POS_DATA ],;							// 05 - DATA FINAL
											IntToHora(aTabCalend[ nZ+1, CALEND_POS_HORA ]),;			// 06 - HORA FINAL
											aEscala[nI][7],;											// 07 - LOCAL
											aEscala[nI][2],;											// 08 - TURNO
											aEscala[nI][10],;											// 09 - CONTRATO
											aEscala[nI][8],;											// 10 - CLIENTE
											aEscala[nI][9],;											// 11 - LOJA
											aTabCalend[ nZ, CALEND_POS_FERIADO ],;						// 12 - FERIADO
											.F.,;														// 13 - FALTA
											.F.,;														// 14 - SUBSTITUTO
											aEscala[nI][11]})											// 15 - CODIGO RH

						// Repassa a Data de Referencia
						_dDtRef := aTabCalend[ nZ, CALEND_POS_DATA ]

						// Contabiliza o numero de registros
						_nPosABB := Len(aRetAloc)
					Else
						If "S" $ aTabCalend[nZ+1][CALEND_POS_TIPO_MARC] .And. aTabCalend[nZ+1][CALEND_POS_TIPO_DIA ] == "S"
							aRetAloc[_nPosABB][05] := aTabCalend[ nZ+1, CALEND_POS_DATA ]
							aRetAloc[_nPosABB][06] := IntToHora(aTabCalend[ nZ+1, CALEND_POS_HORA ])
						EndIf
					EndIf
				EndIf
				// Passa para o próximo dia
				nZ += 2
			EndIf
		End

		// Finaliza o temporário da alocação
		DbSelectArea(_cAliasABB_)
		(_cAliasABB_)->(DbCloseArea())

	Next nI
EndIf
	
For nI := 1 To LEN(aRetAloc)
	For nZ := 1 To LEN(aRetAloc[nI])
		cMsgDia := "aRetAloc["+cValToChar(nI)+"]["+cValToChar(nZ)+"]: "
		If nZ <= LEN(aDePara)
			cMsgDia := "aRetAloc["+cValToChar(nI)+"]["+aDePara[nZ]+"]: "
		EndIf
		oGsLog:addLog(_cFunFil+_cMatFunc+'TXRetAloc',cMsgDia + AllToChar(aRetAloc[nI][nZ]))
	Next nZ
	oGsLog:addLog(_cFunFil+_cMatFunc+'TXRetAloc',CRLF)
	oGsLog:addLog(_cFunFil+_cMatFunc+'TXRetAloc',Replicate("-",15))
Next nI
If VALTYPE(_cFunFil) == 'C' .AND. VALTYPE(_cMatFunc) == 'C'
	oGsLog:printLog(_cFunFil+_cMatFunc+'TXRetAloc')
EndIf

RestArea(aAreaAloc)

RETURN aRetAloc

//-------------------------------------------------------------------
/*/{Protheus.doc} TECFilSB1()
Construção da consulta especifica

@author Matheus Lando Raimundo
@since 12/01/2016
@version P12.1.7
@return Nil
/*/
//------------------------------------------------------------------
Function TECFilSB1(cTabela)

Local lRet		:= .F.
Local oBrowse	:= Nil
Local cAls		:= ""
Local nSuperior	:= 0
Local nEsquerda	:= 0
Local nInferior	:= 0
Local nDireita	:= 0
Local oDlgEscTela	:= Nil
Local cQry		:= ""
Local aIndex:= {}
Local aSeek := {}
Local oView := Nil
Local cProfID	:= ""  //Indica o ID do browse para recuperar as informações do usuario	

Default cTabela	:= SubStr(ReadVar(),1,AT("_",ReadVar())-1)
Default cTipo := ""

Aadd( aSeek, { STR0063, {{"","C",TamSX3("B1_COD")[1],0,STR0063,,}} } )	// "Código" ### "Código"
Aadd( aSeek, { STR0064, {{"","C",TamSX3("B1_DESC")[1],0,STR0064,,}}}) // "Descrição" ### "Descrição"

Aadd( aIndex, "B1_COD" )
Aadd( aIndex, "B1_DESC")
Aadd( aIndex, "B1_FILIAL")  // adicionado para não ter problema de não encontrar o último índice, em caso de adicionar mais deixe a filial por último

cTabela := Substr(cTabela,4,Len(cTabela))

//Tratativa para tela de Facilitador
If FunName() == "TECA984" .And. !IsInCallStack("TECA984A")
	oView := FwViewActive()
	If oView:GetFolderActive("ABAS", 2)[2] == STR0083 // Aba RH
		cTabela := 'TFF'
	ElseIf oView:GetFolderActive("ABAS", 2)[2] == STR0084 // Aba MC
		cTabela := 'TFH'
	ElseIf oView:GetFolderActive("ABAS", 2)[2] == STR0085 // Aba MI
		cTabela := 'TFG'
	ElseIf oView:GetFolderActive("ABAS", 2)[2] == STR0086 // Aba LE
		cTabela := 'TFI'
	EndIf
EndIf

If IsInCallStack("TECA984A")
	If cTabela == "TXS"
		cTabela := 'TFF'
	Elseif cTabela == "TXT"
		cTabela := 'TFG'
	Elseif cTabela == "TXU"
		cTabela := 'TFH'
	Endif
Endif

cQry := " SELECT B1_FILIAL, B1_COD, B1_DESC, B1_TIPO, B1_UM, B1_LOCPAD, B1_TIPCONV "
cQry += " FROM " + RetSqlName("SB1") + " B1"
cQry += " INNER JOIN " + RetSqlName("SB5") + " B5"
cQry += 	" ON '" +  xFilial('SB5') + "' = B5.B5_FILIAL"
cQry += 	" AND B1.B1_COD = B5.B5_COD"
cQry += 	" AND B1.D_E_L_E_T_ = ' '"
cQry += 	" AND B5.D_E_L_E_T_ = ' '"
cQry += " WHERE B1_FILIAL = '" +  xFilial('SB1') + "'"

If cTabela == 'TFF'
	cQry += " AND B5.B5_TPISERV = '4'"
	cProfID := "TFFP"
	cTipo := "RECURSOS_HUMANOS"
ElseIf cTabela == 'TFG'
	cQry += " AND B5.B5_TPISERV = '5'"
	cQry += " AND B5.B5_GSMI= '1' "
	cProfID := "TFGP"
	cTipo := "MATERIAL_IMPLANTACAO"
ElseIf cTabela == 'TFH'
	cQry += " AND B5.B5_TPISERV = '5'"
	cQry += " AND B5.B5_GSMC= '1' "
	cProfID := "TFHP"
	cTipo := "MATERIAL_CONSUMO"
ElseIf cTabela == 'TFI'
	cQry += " AND B5.B5_TPISERV = '5'"
	cQry += " AND B5.B5_GSLE= '1' "
	cProfID := "TFIP"
	cTipo := "LOCACAO"
EndIf

cAls := cTipo
//-- Necessário utilizar FieldPos, pois o campo de bloqueio de registro é opcional para o cliente.
If SB1->(FieldPos('B1_MSBLQL')) > 0
	cQry += " AND B1.B1_MSBLQL <> '1'"
EndIf

If SB5->(FieldPos('B5_MSBLQL ')) > 0
	cQry += " AND B5.B5_MSBLQL <> '1'"
EndIf

nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800
IF !isBlind()
	DEFINE MSDIALOG oDlgEscTela TITLE STR0059 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL // "Produtos"

	oBrowse := FWFormBrowse():New()
	oBrowse:SetOwner(oDlgEscTela)
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetAlias(cAls)
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetQuery(cQry)
	oBrowse:SetSeek(,aSeek)
	oBrowse:SetDescription(STR0059)  // "Produtos"
	oBrowse:SetMenuDef("")
	oBrowse:DisableDetails()
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetProfileID(cProfID)

	oBrowse:SetDoubleClick({ || cRetProd := (oBrowse:Alias())->B1_COD, lRet := .T. ,oDlgEscTela:End()})
	oBrowse:AddButton( OemTOAnsi(STR0061), {|| cRetProd   := (oBrowse:Alias())->B1_COD, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
	oBrowse:AddButton( OemTOAnsi(STR0062),  {||  cRetProd  := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
	oBrowse:DisableDetails()

	ADD COLUMN oColumn DATA { ||  B1_COD  } TITLE STR0063 SIZE TamSX3("B1_COD")[1] OF oBrowse //"Código"
	ADD COLUMN oColumn DATA { ||  B1_DESC } TITLE STR0064 SIZE TamSX3("B1_DESC")[1] OF oBrowse //"Descrição"
	oBrowse:Activate()
	ACTIVATE MSDIALOG oDlgEscTela CENTERED
EndIf
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TECRetProd()
Retorno da consulta especifica

@author Matheus Lando Raimundo
@since 12/01/2016
@version P12.1.7
@return Nil
/*/
//------------------------------------------------------------------
Function TECRetProd()

Return cRetProd

/*/{Protheus.doc} AtIsPrdLoc
	Verifica se um produto corresponde a um item de locação e está ativo

@since		22/04/2015

@sample 	AtIsPrdLoc(_cFunFil, _cMatFunc, _dDtIni, _dDtFim)
@param 		cExp1, Char, Código do produto que deseja verificar
@return	ExpA	Array dos dados de Alocacao

/*/
Function AtIsPrdLoc( cCodPrd, cFilSB5 )

Local lRet := .F.
Local aArea := GetArea()
Local aAreaSB5 := {}

Default cFilSB5 := xFilial("SB5")

DbSelectArea("SB5")
SB5->( DbSetOrder( 1 ) ) // B5_FILIAL+B5_COD

If !Empty(cCodPrd) .And. SB5->( DbSeek( cFilSB5+cCodPrd ) )
	lRet := ( SB5->B5_TPISERV == "5" .And. SB5->B5_GSLE == "1" )
EndIf

RestArea( aArea )

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AtShowLog
Exibe log de processamento na tela
@param cMemoLog, caracter: (LOG a ser exibido)
@param cTitle, caracter: Título da tela de LOG de processamento
@param lVScroll, lógico: habilita ou não a barra de scroll vertical
@param lHScroll, lógico: habilita ou não a barra de scroll horizontal
@param lWrdWrap, lógico: habilita a quebra de linha automática ou não, obedecendo ao tamanho da caixa de texto do log
@return lRet, Indica confirmação ou cancelamento
@author 	Alexandre da Costa
@since 24/09/2015
@version 1.0
/*/
//------------------------------------------------------------------------------
Function AtShowLog(cMemoLog,cTitle,lVScroll,lHScroll,lWrdWrap,lCancel)
Local lRet			:=	.F.
Local oFont		:=	TFont():New("Courier New",07,15)
Local oMemo 	:= Nil
Local oDlgEsc 		:= Nil
Default cMemoLog	:=	""
Default cTitle	:=	""
Default lVScroll	:=	.T.
Default lHScroll	:=	.F.
Default lWrdWrap	:=	.T.
Default lCancel		:=  .T.

If	!Empty(cMemoLog)
	Define Dialog oDlgEsc Title AllTrim(STR0056+" "+AllTrim(cTitle)) From 0,0 to 425, 600 Pixel
	@ 000, 000 MsPanel oTop Of oDlgEsc Size 000,250	// Coordenada para o panel
	oTop:Align := CONTROL_ALIGN_TOP //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
	@ 005,005 Get oMemo Var cMemoLog Memo FONT oFont Size 292,186 READONLY Of oTop Pixel
	oMemo:EnableVScroll(lVScroll)
	oMemo:EnableHScroll(lHScroll)
	oMemo:lWordWrap := lWrdWrap
	oMemo:bRClicked := {|| AllwaysTrue()}
	Define SButton From 196, 270 Type  1 Action (lRet := .T., oDlgEsc:End()) Enable Of oTop Pixel // OK

	If lCancel
		Define SButton From 196, 240 Type  2 Action (lRet := .F., oDlgEsc:End()) Enable Of oTop Pixel // Cancelar
	Endif

	Activate Dialog oDlgEsc Centered

EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TxCarac
Função que retorna as regioes de atendimento do atendentes.

@sample	TxCarac(cCodAtend)

@param	ExpC1	Codigo do atendente.

@return	ExpA	Caracteristica do Atendimento.

@author		Anderson Silva
@since		13/11/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function TxCarac(cCodAtend)

Local aCarac	 := {}
Local nLinha 	 := 0
Local cDescCar 	 := ""

DbSelectArea("AA1")
DbSetOrder(1) // AA1_FILIAL+AA1_CODTEC

If AA1->(DbSeek(xFilial("AA1")+cCodAtend))

	DbSelectArea("TDU")
	DbSetOrder(2) //  TDU_FILIAL+TDU_CODTEC+TDU_CODTCZ

	If TDU->(DbSeek(xFilial("TDU")+cCodAtend))
		If Len(aCarac) == 0
			aAdd(aCarac,{cCodAtend})
		EndIf

		While ( TDU->(!Eof()) .AND. TDU->TDU_FILIAL == xFilial("TDU") .AND. TDU->TDU_CODTEC == cCodAtend )
			cDescCar :=	Posicione("TCZ",1,xFilial("TCZ")+TDU->TDU_CODTCZ,"TCZ_DESC")
			cDescCar := Capital(Alltrim(cDescCar))
			nLinha := Len(aCarac)
			aAdd(aCarac[nLinha],{TDU->TDU_CODTCZ,cDescCar})

			TDU->(DbSkip())
		End
	EndIf
Endif

Return( aCarac )

//------------------------------------------------------------------------------
/*/{Protheus.doc} TxCurso
Função que retorna os Cursos do Funcionário.

@sample	TxCurso(cCodAtend)

@param	ExpC1	Codigo do atendente.

@return	ExpA	Curso do Funcionario.

@author		Anderson Silva
@since		13/11/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function TxCurso(cCodAtend)

Local aCurso	 := {}
Local nLinha 	 := 0
Local cDescCur 	 := ""

DbSelectArea("AA1")
DbSetOrder(1)

If AA1->(DbSeek(xFilial("AA1")+cCodAtend))

	DbSelectArea("RA4")
	DbSetOrder(1) //RA4_FILIAL, RA4_MAT, RA4_CURSO

	If RA4->(DbSeek(xFilial("RA4")+AA1->AA1_CDFUNC))
		If Len(aCurso) == 0
			aAdd(aCurso,{cCodAtend})
		EndIf

		While ( RA4->(!Eof()) .AND. RA4->RA4_FILIAL == xFilial("RA4") .AND. RA4->RA4_MAT == AA1->AA1_CDFUNC )
			cDescCur :=	Posicione("RA1",1,xFilial("RA1")+RA4->RA4_CURSO,"RA1_DESC")
			cDescCur := Capital(Alltrim(cDescCur))
			nLinha := Len(aCurso)
			aAdd(aCurso[nLinha],{RA4->RA4_CURSO,cDescCur})

			RA4->(DbSkip())
		End
	EndIf
Endif


Return( aCurso )

//------------------------------------------------------------------------------
/*/{Protheus.doc} TxRestri(cLocAloc)
Função que retorna as restrições dos atendentes.

@sample	TxRestri(cLocAloc)

@param	ExpC1 Local de Atendimento

@return	ExpA	 Array Restrições.

@author	services
@since		15/10/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function TxRestri(cLocalAloc)

Local aRestri:={}
Local cTmpRestri := ""
Local cTmpResCli := ""

//query com as restricoes do local de atendimento
If !Empty(cLocalAloc)
	cTmpResTri:= GetNextAlias()
	BeginSql Alias cTmpResTri
		Select TW2_CODTEC, TW2_CLIENT, TW2_LOJA, TW2_LOCAL, TW2_TEMPO, TW2_DTINI, TW2_DTFIM, TW2_RESTRI
		From %table:TW2% TW2
		left join %table:ABS% ABS on ABS_FILIAL = %xFilial:ABS%
			AND ABS_LOCAL = TW2_LOCAL
		WHERE	TW2_FILIAL = %xFilial:TW2%
		AND TW2_LOCAL = %Exp:cLocalAloc%
		AND TW2.%NotDel%
	EndSql

	//adiciona numa matriz
	DbSelectArea(cTmpResTri)
	(cTmpResTri)->(DbGoTop())
	While (cTmpResTri)->(! Eof())

		AADD(aRestri,{(cTmpResTri)->TW2_CODTEC,;
					  (cTmpResTri)->TW2_CLIENT,;
					  (cTmpResTri)->TW2_LOJA,;
					  (cTmpResTri)->TW2_LOCAL,;
					  (cTmpResTri)->TW2_TEMPO,;
					  (cTmpResTri)->TW2_DTINI,;
					  (cTmpResTri)->TW2_DTFIM,;
					  (cTmpResTri)->TW2_RESTRI,;
					})

	(cTmpResTri)->(DbSkip())

	EndDo

	//verificar restrição no cliente

	//cliente do local de atendimento
	cCliente:= Posicione("ABS",1,xFilial("ABS")+cLocalAloc,"ABS_CODIGO")
	cLojaCli:= Posicione("ABS",1,xFilial("ABS")+cLocalAloc,"ABS_LOJA")

	cTmpResCli:= GetNextAlias()
	BeginSql Alias cTmpResCli
		Select TW2_CODTEC, TW2_CLIENT, TW2_LOJA, TW2_LOCAL, TW2_TEMPO, TW2_DTINI, TW2_DTFIM, TW2_RESTRI
		From %table:TW2% TW2
		left join %table:ABS% ABS on ABS_FILIAL = %xFilial:ABS%
			AND ABS_LOCAL = TW2_LOCAL
		WHERE	TW2_FILIAL = %xFilial:TW2%
		AND TW2_CLIENT = %Exp:cCliente%
		AND TW2_LOJA = %Exp:cLojaCli%
		AND TW2.%NotDel%
	EndSql

	DbSelectArea(cTmpResCli)
	(cTmpResCli)->(DbGoTop())
	While (cTmpResCli)->(! Eof())
		//verificar se ja existe o atendente e nao adicionar novamente
		If ! aScan(aRestri,{|x| x[1] == (cTmpResCli)->TW2_CODTEC})
			AADD(aRestri,{(cTmpResCli)->TW2_CODTEC,;
					  (cTmpResCli)->TW2_CLIENT,;
					  (cTmpResCli)->TW2_LOJA,;
					  (cTmpResCli)->TW2_LOCAL,;
					  (cTmpResCli)->TW2_TEMPO,;
					  (cTmpResCli)->TW2_DTINI,;
					  (cTmpResCli)->TW2_DTFIM,;
					  (cTmpResCli)->TW2_RESTRI,;
						})
		Endif
		(cTmpResCli)->(DbSkip())
	EndDo
	//Fecha a area das tabelas
	(cTmpResCli)->(DbCloseArea())
	(cTmpResTri)->(DbCloseArea())
EndIf

Return( aRestri )

//-------------------------------------------------------------------
/*/{Protheus.doc} At820PrdF3()
Construção da consulta especifica

@author Filipe Gonçalves Rodrigues
@since 07/07/2016
@version P12.1.14
@return Nil
/*/
//------------------------------------------------------------------
Function At820PrdF3(cTabela)
Local lRet		:= .F.
Local oBrowse	:= Nil
Local cAls		:= GetNextAlias()
Local nSuperior	:= 0
Local nEsquerda	:= 0
Local nInferior	:= 0
Local nDireita	:= 0
Local oDlgEscTela	:= Nil
Local cQry		:= ""
Local aIndex	:= {"B1_COD", "B1_FILIAL"} // adicionada filial para não ter problema de não encontrar o último índice, em caso de adicionar mais deixe a filial por último
Local aSeek		:= {{STR0057, {{STR0058,"C",TamSX3("B1_COD")[1],0,"",,}} }}	//"Produtos" # "Produto"
Local oModel	:= Nil
Local cFil 		:= ""

DEFAULT cTabela	:= SubStr(ReadVar(),1,AT("_",ReadVar())-1)
cTabela := Substr(cTabela,4,Len(cTabela))

cQry := " SELECT B1_FILIAL, B1_COD, B1_DESC "
cQry += " FROM " + RetSqlName("SB1") + " B1 "
cQry += " INNER JOIN " + RetSqlName("SB5") + " B5 "
cQry += 	" ON B1.B1_FILIAL = B5.B5_FILIAL "
cQry += 	" AND B1.B1_COD = B5.B5_COD "
cQry += 	" AND B1.D_E_L_E_T_ = ' ' "
cQry += 	" AND B5.D_E_L_E_T_ = ' ' "
cQry += 	" AND B5.B5_TPISERV = '5'"
cQry += 	" AND B5.B5_GSLE= '1' "

//Tratativa para tela de Facilitador
If FunName() == "TECA001"
	oModel := FwModelActive()
	cFil := oModel:GetValue("GRIDDETAIL","TWS_FILPRD")
	cQry += " AND B1_FILIAL = '" +  cFil + "'"
EndIf

//-- Necessário utilizar FieldPos, pois o campo de bloqueio de registro é opcional para o cliente.
If SB1->(FieldPos('B1_MSBLQL')) > 0
	cQry += " AND B1.B1_MSBLQL <> '1'"
EndIf

If SB5->(FieldPos('B5_MSBLQL ')) > 0
	cQry += " AND B5.B5_MSBLQL <> '1'"
EndIf

cQry += " ORDER BY B1_FILIAL, B1_COD"

nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800

If !isBlind()
	DEFINE MSDIALOG oDlgEscTela TITLE STR0059 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL	//"Produtos"

	oBrowse := FWFormBrowse():New()
	oBrowse:SetDescription(STR0060)	//"Produtos"
	oBrowse:SetAlias(cAls)
	oBrowse:SetDataQuery()
	oBrowse:SetQuery(cQry)
	oBrowse:SetOwner(oDlgEscTela)
	oBrowse:SetDoubleClick({ || cRetProd := (oBrowse:Alias())->B1_COD, lRet := .T. ,oDlgEscTela:End()})
	oBrowse:AddButton( OemTOAnsi(STR0061), {|| cRetProd  := (oBrowse:Alias())->B1_COD, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
	oBrowse:AddButton( OemTOAnsi(STR0062), {|| cRetProd  := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
	oBrowse:DisableDetails()
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetSeek(,aSeek)

	ADD COLUMN oColumn DATA {|| B1_COD}  TITLE STR0063 SIZE TamSX3("B1_COD")[1] OF oBrowse //"Código"
	ADD COLUMN oColumn DATA {|| B1_DESC} TITLE STR0064 SIZE TamSX3("B1_DESC")[1] OF oBrowse //"Descrição"

	oBrowse:Activate()
	ACTIVATE MSDIALOG oDlgEscTela CENTERED
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} At820PrdRt()
Retorno da consulta especifica

@author Matheus Lando Raimundo
@since 12/01/2016
@version P12.1.7
@return Nil
/*/
//------------------------------------------------------------------
Function At820PrdRt()

Return cRetProd

//------------------------------------------------------------------------------
/*/{Protheus.doc} AtChkHasKey
  Pesquisa se um determinado valor chave existe em uma tabela, não considera a filial corrente
como a ExistCpo faz
@since  04/08/2016
@version P12
@author  Inovação - Gestão de Serviços
@param   cTab, Caracter, define qual a tabela terá o conteúdo pesquisado
@param   nInd, Numérico, Default = 1, determina qual deve ser utilizado na tabela a ter o conteúdo pesquisado
@param   cChave, Caracter, conteúdo a ser verificado
@param   lHelp, Lógico, Default = .T., indica se deve ser exibido ou não help
@return  Lógico, determina de conseguiu encontrar o registro (.T.) ou não (.F.).
/*/
//------------------------------------------------------------------------------
Function AtChkHasKey( cTab, nInd, cChave, lHelp )

Local lRet := .F.
Local aArea := {}
Local aAreacTab := {}

Default nInd := 1
Default lHelp := .T.

If !Empty(cTab) .And. !Empty(cChave)

	aArea := GetArea()
	aAreacTab := (cTab)->(GetArea())

	DbSelectArea(cTab)
	(cTab)->(DbSetOrder(nInd))

	lRet := ( (cTab)->(DbSeek( cChave ) ) )

	If lHelp .And. !lRet
		Help(,,'REGNOIS')
	EndIf

	RestArea( aAreacTab )
	RestArea(aArea)

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At740F3Tur()
Construção da consulta especifica

@author Filipe Gonçalves Rodrigues
@since 07/07/2016
@version P12.1.14
@return Nil
/*/
//------------------------------------------------------------------
Function At740F3Tur()
Local lRet		:= .F.
Local oBrowse	:= Nil
Local cAls		:= GetNextAlias()
Local nSuperior	:= 0
Local nEsquerda	:= 0
Local nInferior	:= 0
Local nDireita	:= 0
Local oDlgTela	:= Nil
Local cQry		:= ""
Local aIndex	:= {"R6_TURNO", "R6_FILIAL"} // adicionado para não ter problema de não encontrar o último índice, em caso de adicionar mais deixe a filial por último
Local aSeek		:= {{STR0065, {{STR0066,"C",TamSX3("R6_TURNO")[1],0,"",,}} }}	//"Turnos" # "Turno"
Local oModel	:= Nil
Local cFil 		:= ""

cQry := "SELECT SR6.R6_FILIAL, SR6.R6_TURNO, SR6.R6_DESC"
cQry += " FROM " + RetSqlName("SR6") + " SR6 "
cQry += " WHERE R6_FILIAL = '"+xFilial("SR6")+"' AND SR6.D_E_L_E_T_ = ' ' "
cQry += " ORDER BY R6_FILIAL, R6_TURNO"

nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800
If !isBlind()
	DEFINE MSDIALOG oDlgTela TITLE STR0067 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL	//"Turnos"

	oBrowse := FWFormBrowse():New()
	oBrowse:SetOwner(oDlgTela)
	oBrowse:SetDataQuery()
	oBrowse:SetAlias(cAls)
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetQuery(cQry)
	oBrowse:SetSeek(,aSeek)
	oBrowse:SetDescription(STR0068) //"Turnos"
	oBrowse:SetMenuDef("")
	oBrowse:DisableDetails()
	oBrowse:SetDoubleClick({ || cRetProd := (oBrowse:Alias())->R6_TURNO, lRet := .T. ,oDlgTela:End()})
	oBrowse:AddButton( OemTOAnsi(STR0061), {|| cRetProd := (oBrowse:Alias())->R6_TURNO, lRet := .T., oDlgTela:End() } ,, 2 ) //"Confirmar"
	oBrowse:AddButton( OemTOAnsi(STR0062), {|| cRetProd := "", oDlgTela:End() } ,, 2 ) //"Cancelar"
	oBrowse:SetUseFilter(.T.)


	ADD COLUMN oColumn DATA {|| R6_TURNO} TITLE STR0069 SIZE TamSX3("R6_TURNO")[1] OF oBrowse //"Turno"
	ADD COLUMN oColumn DATA {|| R6_DESC}  TITLE STR0070 SIZE TamSX3("R6_DESC")[1] OF oBrowse //"Descrição"
	oBrowse:Activate()
	ACTIVATE MSDIALOG oDlgTela CENTERED
EndIf
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} At740turRt()
Retorno da consulta especifica

@author Filipe Gonçalves Rodrigues
@since 07/07/2016
@version P12.1.7
@return Nil
/*/
//------------------------------------------------------------------
Function At740turRt()

Return cRetProd

//------------------------------------------------------------------------------
/*/{Protheus.doc} AtPosAA3
  Verifica a existência e posiciona na base de atendimento considerando a combinação de FIlial de Origem + Numero de Série
@since		12/08/2016
@version	P12
@author 	Inovação - Gestão de Serviços
@param 		cFilOri_NS, Caracter, define qual a tabela a chave a ser pesquisada considerando a concatenação dos campos AA3_FILORI+AA3_NUMSER
@param 		cProdFiltro, Caracter, define o produto da base de atendimento a ser pesquisada
@return 	Lógico, determina de conseguiu encontrar o registro (.T.) ou não (.F.).
/*/
Function AtPosAA3( cFilOri_NS, cProdFiltro )

Local lFound := .F.
Local cTmpAlias := GetNextAlias()
Local cFiltroQry := "%%"
Local nTamFilOri := TamSX3("AA3_FILORI")[1]
Local nTamNumSer := TamSX3("AA3_NUMSER")[1]
Local cFilOri 	 := SubString( cFilOri_NS, 1, nTamFilOri )
Local cNumSer 	 := SubString( cFilOri_NS, nTamFilOri+1, nTamNumSer )

//  não foi adicionado default pois este parâmetro passa a ser obrigatório para a identificação
// correta da base de atendimento
If !Empty(cProdFiltro)
	cFiltroQry := "% AND AA3_CODPRO = '"+cProdFiltro+"'%"
EndIf

BeginSQL Alias cTmpAlias
	SELECT AA3.R_E_C_N_O_ AA3RECNO
	FROM %Table:AA3% AA3
	WHERE AA3.%NotDel%
		AND AA3_FILORI = %Exp:cFilOri%
		AND (AA3_NUMSER = %Exp:cNumSer%)
		%Exp:cFiltroQry%
EndSql

If (cTmpAlias)->(!EOF())
	AA3->( DbGoTo( (cTmpAlias)->AA3RECNO ) )
	lFound := .T.
EndIf
(cTmpAlias)->( DbCloseArea() )

Return lFound

//------------------------------------------------------------------------------
/*/{Protheus.doc} AtTamFilTab
  Identifica a quantidade de caracteres do campo filial considerando o nível de compartilhamento das tabelas
@since		17/08/2016
@version	P12
@author 	Inovação - Gestão de Serviços
@param 		cTab, Caracter, define qual a tabela deverá ter nível de compartilhamento considerado
@return 	Numérico, retorna a quantidade de caracteres considerando o nível de compartilhamento da tabela
/*/
//------------------------------------------------------------------------------
Function AtTamFilTab( cTab )
Local nTamNvlEmp := 0
Local nTamNvlUni := 0
Local nTamNvlFil := 0
Local nTamFilTot := 0
Local nTamFilTab := 0

If ( nTamNvlFil := Len( FWSM0Layout(cEmpAnt,3) ) ) > 0
	nTamNvlUni := Len( FWSM0Layout(cEmpAnt,2) )
	nTamNvlEmp := Len( FWSM0Layout(cEmpAnt,1) )
	nTamFilTot := ( nTamNvlEmp + nTamNvlUni + nTamNvlFil )
ElseIf !Empty( SM0->M0_LEIAUTE )
	nTamNvlEmp := AtCharCount( SM0->M0_LEIAUTE, "E" )
	nTamNvlUni := AtCharCount( SM0->M0_LEIAUTE, "U" )
	nTamNvlFil := AtCharCount( SM0->M0_LEIAUTE, "F" )
EndIf

nTamFilTab := If( FWModeAccess(cTab,3) == "E", nTamFilTot, If( FWModeAccess(cTab,2) == "E", nTamNvlEmp + nTamNvlUni, If( FWModeAccess(cTab,1) == "E", nTamNvlEmp, 0 ) ) )

Return nTamFilTab

//------------------------------------------------------------------------------
/*/{Protheus.doc} GSEscolha
Exibe uma interface grafica para que o usuario escolha 1 opcao entre varias
@since		29/09/2016
@version	P12
@author 	Cesar A. Bianchi
@param 		aPergs, nDefault
@return 	nRet - Numero da opção escolhida dentro do parametro aPergs
/*/
//------------------------------------------------------------------------------
Function GSEscolha(cTitle,cMsg,aPergs,nDefault)
Local nRet := 1
Local oDlgEsc := Nil
Local oSayMain:= Nil
Local oBoxOpc	:= Nil
Local oRadM	:= Nil
Local nRadio 	:= 0
Local nAlt		:= 0
Local nLarg	:= 0
Local nFatAlt := 20
Local bOk		:= Nil
Local bCancel := Nil
Local aEnchBt := {}
Local lOk		:= .F.

	Default aPergs := {}
	Default nDefault := 1
	Default cTitle := "Titulo não definido"
	Default cMsg	 := "Mensagem não definida"


	If len(aPergs) > 1
		//1* - Seta a escolha Default
		nRet := nDefault
		nRadio := nDefault

		//2* - Define a largura e a altura da tela
		nAlt := 200 + (nFatAlt * len(aPergs))
		nLarg := 400

		//3* - Define as acoes do botao Ok e Cancel
		bOk := {|| lOk := .T., oDlgEsc:End()}
		bCancel := {|| lOk := .F., oDlgEsc:End()}

		//"Pinta" a Dialog
		oDlgEsc:= MSDIALOG():Create()
		oDlgEsc:cName     := "oDlgEsc"
		oDlgEsc:cCaption  := cTitle
		oDlgEsc:nLeft     := 0
		oDlgEsc:nTop      := 10
		oDlgEsc:nWidth    := nLarg
		oDlgEsc:nHeight   := nAlt
		oDlgEsc:lShowHint := .F.
		oDlgEsc:lCentered := .T.
		oDlgEsc:bInit := EnchoiceBar(oDlgEsc,bOk,bCancel,,aEnchBt)

		//"Pinta" a Mensagem de alerta ao usuario
		oSayMain:= TSAY():Create(oDlgEsc)
		oSayMain:cName			:= "oSayMain"
		oSayMain:cCaption 		:= cMsg
		oSayMain:nLeft 			:= 30
		oSayMain:nTop 			:= 80
		oSayMain:nWidth 	   		:= oDlgEsc:nWidth - 30 - 30
		oSayMain:nHeight 			:= 40
		oSayMain:lShowHint 		:= .F.
		oSayMain:lReadOnly 		:= .F.
		oSayMain:Align 			:= 0
		oSayMain:lVisibleControl	:= .T.
		oSayMain:lWordWrap 	  	:= .T.
		oSayMain:lTransparent 	:= .F.

		//"Pinta" o Box das opções
		oBoxOpc:= TGROUP():Create(oDlgEsc)
		oBoxOpc:cName 	   := "oBoxOpc"
		oBoxOpc:cCaption    := ""
		oBoxOpc:nLeft 	   := 30
		oBoxOpc:nTop  	   := 130
		oBoxOpc:nWidth 	   := oDlgEsc:nWidth - 30 - 30
		oBoxOpc:nHeight 	   := oDlgEsc:nHeight - 130 - 40

		//"Pinta" as opções disponiveis no array aPergs
		oRadM:= TRadMenu():Create(oDlgEsc)
		oRadM:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}
		oRadM:nTop := oBoxOpc:nTop + 20
		oRadM:nLeft := oBoxOpc:nLeft + 20
		oRadM:nWidth := oBoxOpc:nWidth - 40
		oRadM:nHeight := oBoxOpc:nHeight - 40
		oRadM:aItems := aPergs
		oRadM:cMsg := "Teste cMsg Property"


		//Exibe a Dialog
		oDlgEsc:Activate()

		//Define o retorno a partir da escolha feita pelo usuario
		If lOk
			nRet := nRadio
		Else
			nRet := 0
		EndIf

		//Destroi os objetos da memoria
		TecDestroy(oDlgEsc)
		TecDestroy(oSayMain)
		TecDestroy(oBoxOpc)
		TecDestroy(oRadM)
	Else
		nRet := 0
	EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AtABBNumCd()
Validação da numeração do codigo da agenda(ABB_CODIGO)

@author Serviços
@since 28/09/2016
@version P12.1.7
@return cNumCod - Numero do codigo da agenda
/*/
//------------------------------------------------------------------
Function AtABBNumCd()

Local aArea		:= GetArea()
Local aAreaABB	:= ABB->(GetArea())
Local cNumCod   := ""

dbSelectArea("ABB")
dbSetOrder(8)
dbGoTop()

cNumCod:= GetSXENum("ABB","ABB_CODIGO",,8)
nSaveSX8  := 1

While ABB->( MsSeek(xFilial("ABB")+cNumCod) )
	If ( __lSx8 )
		ConfirmSX8()
	EndIf
	cNumCod:= GetSXENum("ABB","ABB_CODIGO",,8)
EndDo

RestArea(aAreaABB)
RestArea(aArea)

Return( cNumCod )

//------------------------------------------------------------------------------
/*/{Protheus.doc} AtCharCount
  Conta a quantidade de caracteres em uma determinada string
@since		25/10/2016
@version	P12
@author 	Inovação - Gestão de Serviços
@param 		cStrAval, Caracter, define qual a cadeia de caracteres será avaliada
@param 		cCharAlvo, Caracter, define qual o caracter deverá ter a
@return 	Numérico, quantidade de vezes que o caracter se repete na string
/*/
//------------------------------------------------------------------------------
Function AtCharCount( cStrAval, cCharAlvo )

Local nCount := 0
Local nPosNew := 0
Local nDifChar := Len(cCharAlvo)

While ( nPosNew := At( cCharAlvo, cStrAval ) ) > 0
	nCount++
	cStrAval := SubStr( cStrAval, nPosNew+nDifChar )
EndDo

Return nCount

//------------------------------------------------------------------------------
/*/{Protheus.doc} TxEscCalen
  Função para descobrir a escala e calendario do atendente dentro de um periodo
@since		31/05/2017
@version	P12.1.17
@author 	Inovação - Gestão de Serviços

@param		ExpC1	Filial do Funcionario
@param		ExpC2	Matricula do Funcionario
@param		ExpD3	Data Inicial da Alocacao
@param		ExpD4	Data Final da Alocacao
@param 		ExpD5	Busca da escala pelo Beneficio

@return 	aEscala[1][1] - Codigo da Escala
			aEscala[1][2] - turno da escala
			aEscala1[1][3] - Sequencia do Turno da escala
			aEscala[1][4] - Calendario da Escala(TFF)
			aEscala[1][5] - Data inicial da escala
			aEscala[1][6] - Data Final da escala
			aEscala[1][7] - Local de Atendimento
			aEscala[1][8] - Codigo do cliente
			aEscala[1][9] - Loja do Clientte
			aEscala[1][10] - Numero do Contrato
			aEscala[1][11] - Codigo da TFF
/*/
//------------------------------------------------------------------------------
Function TxEscCalen(_cCodTec,_cDataI,_cDataF,lBenef)
Local aEscala	:= {}
Local cAliasTmp := GetNextAlias()
Local cSql 		:= ""
Local lSemTGY	:= .F.
Local lAlocHR	:= ExistFunc("TecABBPRHR") .AND. TecABBPRHR()
Local lGSBENAG  := SuperGetMV("MV_GSBENAG",,.F.)

Default lBenef	:= .F.

cSql += "	SELECT 	TGY.TGY_ESCALA, "
cSql += "		   	TGY.TGY_ATEND, "
cSql += "	      	TGY.TGY_DTINI, "
cSql += "	       	TGY.TGY_DTFIM, "
cSql += "			TGY.TGY_CODTFF, "
cSql += "			TGY.TGY_ULTALO, "
cSql += "			TDX.TDX_TURNO, "
cSql += "        	TDX.TDX_SEQTUR, "
cSql += "			TFF.TFF_FILIAL, "
cSql += "			TFF.TFF_COD, "
cSql += "			TFF.TFF_ESCALA, "
cSql += "			TFF.TFF_CALEND, "
cSql += "			TFF.TFF_CONTRT, "
cSql += "			TFF.TFF_LOCAL, "
cSql += "			ABS.ABS_CODIGO, "
cSql += "			ABS.ABS_LOJA "
cSql += "	FROM " + RetSqlName("TGY") + " TGY "
cSql += " INNER JOIN " + RetSqlName("TDX") + " TDX ON "
cSql += FWJoinFilial("TDX" , "TGY" , "TDX", "TGY", .T.)
cSql += " AND TDX_COD = TGY_CODTDX "
cSql += " AND TDX.D_E_L_E_T_ = ' ' "
cSql += " INNER JOIN " + RetSqlName("TFF") + " TFF ON "
cSql += FWJoinFilial("TFF" , "TGY" , "TFF", "TGY", .T.)
cSql += " AND TFF_COD = TGY_CODTFF "
cSql += " AND TFF.D_E_L_E_T_ = ' ' "
cSql += " INNER JOIN " + RetSqlName("ABS") + " ABS ON "
cSql += FWJoinFilial("TFF" , "ABS" , "TFF", "ABS", .T.)
cSql += " AND TFF_LOCAL = ABS_LOCAL "
cSql += " AND ABS.D_E_L_E_T_ = ' ' "
cSql += " INNER JOIN " + RetSqlName("AA1") + " AA1 ON "
cSql += " AA1.D_E_L_E_T_ = ' ' "
cSql += " AND AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
cSql += " AND AA1.AA1_CODTEC = '" + _cCodTec + "' AND "
cSql += FWJoinFilial("AA1" , "TGY" , "AA1", "TGY", .T.)
cSql += " WHERE "
cSql += " TGY.TGY_ATEND = '" + _cCodTec + "' "
If FWModeAccess("AA1",3) == "E" .OR. LEN(Rtrim(xFilial("ABB"))) == LEN(Rtrim(xFilial("AA1")))
	cSql += " AND TGY_FILIAL = '" + xFilial("TGY") + "' "
EndIf		
cSql += " AND NOT (TGY.TGY_DTINI > '" + _cDataF + "' OR TGY.TGY_DTFIM < '" + _cDataI + "') "
cSql += " AND TGY.D_E_L_E_T_ = ' ' "
cSql += " ORDER BY TGY.TGY_DTINI, TGY.TGY_DTFIM "

cSql := ChangeQuery(cSql)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasTmp, .F., .F.)

If (cAliasTmp)->(Eof())
	lSemTGY := .T.
EndIf 

While (cAliasTmp)->(!Eof())
	If lGSBENAG .AND. ( EMPTY((cAliasTmp)->TGY_ULTALO) .OR. (cAliasTmp)->TGY_ULTALO < _cDataI )
		(cAliasTmp)->(DbSkip())
		Loop
	EndIf
	AAdd( aEscala, {(cAliasTmp)->TFF_ESCALA,(cAliasTmp)->TDX_TURNO,;
		 (cAliasTmp)->TDX_SEQTUR, (cAliasTmp)->TFF_CALEND,;
		  Iif(_cDataI >= (cAliasTmp)->TGY_DTINI, sTod(_cDataI),sToD((cAliasTmp)->TGY_DTINI)),;
		  Iif(_cDataF <= (cAliasTmp)->TGY_DTFIM, sToD(_cDataF), sToD((cAliasTmp)->TGY_DTFIM)),;
		   (cAliasTmp)->TFF_LOCAL,(cAliasTmp)->ABS_CODIGO,;
		   (cAliasTmp)->ABS_LOJA,(cAliasTmp)->TFF_CONTRT,;
		   (cAliasTmp)->TFF_COD})

	(cAliasTmp)->(DbSkip())

EndDo

(cAliasTmp)->(DbCloseArea())

//Faz a busca quando não há TGY e é chamado no calculo de beneficio
If lSemTGY .And. lBenef
	cAliasTmp := GetNextAlias()

	cSql := ""
	cSql += " SELECT TDV.TDV_TURNO, TDV.TDV_SEQTRN, TDV.TDV_DTREF, TFF.TFF_CALEND, "
	cSql += " TFF.TFF_LOCAL, TFF.TFF_CONTRT, TFF.TFF_COD, ABS.ABS_CODIGO, ABS.ABS_LOJA"
	cSql += " FROM " + RetSqlName("ABB") + " ABB "
	cSql += " INNER JOIN " + RetSqlName("ABR") + " ABR ON "
	cSql += FWJoinFilial("ABR" , "ABB" , "ABR", "ABB", .T.)
	cSql += " AND ABR.ABR_AGENDA = ABB.ABB_CODIGO "
	cSql += " AND ABR.ABR_CODSUB = '" + _cCodTec + "' "
	cSql += " AND ABR.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName("TDV") + " TDV ON "
	cSql += FWJoinFilial("TDV" , "ABB" , "TDV", "ABB", .T.)
	cSql += " AND TDV.TDV_CODABB = ABB.ABB_CODIGO "
	cSql += " AND TDV.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName("ABQ") + " ABQ ON "
	cSql += FWJoinFilial("ABQ" , "ABB" , "ABQ", "ABB", .T.)
	cSql += " AND ABQ_CONTRT || ABQ_ITEM || ABQ_ORIGEM = ABB_IDCFAL "
	cSql += " AND ABQ.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName("TFF") + " TFF ON "
	csql += " TFF.TFF_FILIAL = ABQ.ABQ_FILTFF "
	cSql += " AND TFF_COD = ABQ_CODTFF "
	cSql += " AND TFF.D_E_L_E_T_ = ' ' "
	If lAlocHR
		cSql += " AND TFF.TFF_QTDHRS = ' ' "
	EndIf
	cSql += " INNER JOIN " + RetSqlName("ABS") + " ABS ON "
	cSql += FWJoinFilial("TFF" , "ABS" , "TFF", "ABS", .T.)
	cSql += " AND TFF_LOCAL = ABS_LOCAL "
	cSql += " AND ABS.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName("AA1") + " AA1 ON "
	cSql += " AA1.D_E_L_E_T_ = ' ' "
	cSql += " AND AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
	cSql += " AND AA1.AA1_CODTEC = '" + _cCodTec + "' "
	cSql += " WHERE ABB.ABB_DTINI >= '" + _cDataI + "' "
	cSql += " AND ABB.ABB_DTFIM <= '" + _cDataF + "' "
	cSql += " AND ABB.D_E_L_E_T_= ' ' "
	If FWModeAccess("AA1",3) == "E" .OR. LEN(Rtrim(xFilial("ABB"))) == LEN(Rtrim(xFilial("AA1")))
		cSql += " AND ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
	EndIf

	cSql := ChangeQuery(cSql)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasTmp, .F., .F.)
	While (cAliasTmp)->(!Eof())

		AAdd( aEscala, {"",(cAliasTmp)->TDV_TURNO,;
			(cAliasTmp)->TDV_SEQTRN, (cAliasTmp)->TFF_CALEND,;
			sToD((cAliasTmp)->TDV_DTREF),sToD((cAliasTmp)->TDV_DTREF),;
			(cAliasTmp)->TFF_LOCAL,(cAliasTmp)->ABS_CODIGO,;
			(cAliasTmp)->ABS_LOJA,(cAliasTmp)->TFF_CONTRT,;
			(cAliasTmp)->TFF_COD})

		(cAliasTmp)->(DbSkip())
	EndDo

	(cAliasTmp)->(DbCloseArea())
EndIf

//Faz a busca quando o atendente realiza a alocação por hora
If lAlocHR
	cAliasTmp := GetNextAlias()

	cSql := ""
	cSql += " SELECT TDV.TDV_TURNO, TDV.TDV_SEQTRN, TDV.TDV_DTREF, TFF.TFF_CALEND, "
	cSql += " TFF.TFF_LOCAL, TFF.TFF_CONTRT, TFF.TFF_COD, ABS.ABS_CODIGO, ABS.ABS_LOJA, TFF.TFF_QTDHRS"
	cSql += " FROM " + RetSqlName("ABB") + " ABB "
	cSql += " INNER JOIN " + RetSqlName("TDV") + " TDV ON "
	cSql += FWJoinFilial("TDV" , "ABB" , "TDV", "ABB", .T.)
	cSql += " AND TDV.TDV_CODABB = ABB.ABB_CODIGO "
	cSql += " AND TDV.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName("ABQ") + " ABQ ON "
	cSql += FWJoinFilial("ABQ" , "ABB" , "ABQ", "ABB", .T.)
	cSql += " AND ABQ_CONTRT || ABQ_ITEM || ABQ_ORIGEM = ABB_IDCFAL "
	cSql += " AND ABQ.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName("TFF") + " TFF ON "
	csql += " TFF.TFF_FILIAL = ABQ.ABQ_FILTFF "
	cSql += " AND TFF_COD = ABQ_CODTFF "
	cSql += " AND TFF.D_E_L_E_T_ = ' ' "
	cSql += " AND TFF.TFF_QTDHRS <> ' ' "
	cSql += " INNER JOIN " + RetSqlName("ABS") + " ABS ON "
	cSql += FWJoinFilial("TFF" , "ABS" , "TFF", "ABS", .T.)
	cSql += " AND TFF_LOCAL = ABS_LOCAL "
	cSql += " AND ABS.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName("AA1") + " AA1 ON "
	cSql += " AA1.D_E_L_E_T_ = ' ' "
	cSql += " AND AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
	cSql += " AND AA1.AA1_CODTEC = '" + _cCodTec + "' "
	cSql += " WHERE ABB.ABB_DTINI >= '" + _cDataI + "' "
	cSql += " AND ABB.ABB_DTFIM <= '" + _cDataF + "' "
	cSql += " AND ABB.ABB_CODTEC = '" + _cCodTec + "' "
	cSql += " AND ABB.D_E_L_E_T_= ' ' "
	If FWModeAccess("AA1",3) == "E" .OR. LEN(Rtrim(xFilial("ABB"))) == LEN(Rtrim(xFilial("AA1")))
		cSql += " AND ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
	EndIf

	cSql := ChangeQuery(cSql)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasTmp, .F., .F.)
	While (cAliasTmp)->(!Eof())
		If TecConvHr((cAliasTmp)->TFF_QTDHRS) > 0
			AAdd( aEscala, {"",(cAliasTmp)->TDV_TURNO,;
				(cAliasTmp)->TDV_SEQTRN, (cAliasTmp)->TFF_CALEND,;
				sToD((cAliasTmp)->TDV_DTREF),sToD((cAliasTmp)->TDV_DTREF),;
				(cAliasTmp)->TFF_LOCAL,(cAliasTmp)->ABS_CODIGO,;
				(cAliasTmp)->ABS_LOJA,(cAliasTmp)->TFF_CONTRT,;
				(cAliasTmp)->TFF_COD})
		EndIf
		(cAliasTmp)->(DbSkip())
	EndDo

	(cAliasTmp)->(DbCloseArea())
EndIf

Return aEscala

//------------------------------------------------------------------------------
/*/{Protheus.doc} TxProjEsc
  Função para realizar a projeção de uma agenda baseado em uma escala
@since		31/05/2017
@version	P12.1.17
@author 	Inovação - Gestão de Serviços

@param		ExpC1	Codigo da Escala
@param		ExpD2	Data Inicial da Alocacao
@param		ExpD3	Data Final da Alocacao
@param		ExpC4	Codigo do turno
@param		ExpC5	Sequencia do Turno
@param		ExpA6	Array da tabela padrão
@param		ExpA7	Array da tabela de calendario
@param		ExpC8	Filial da SR6

@return 	Nenhum
/*/
//------------------------------------------------------------------------------
Function TxProjEsc(cEscala,cCalend,dDatIni,dDatFim,cTurno,cSeq,aTabPadrao,aTabCalend,cFilSR6)
Local lRetCalend 	:= .T.
local lPEEscala		:= FindFunction('U_PNMSEsc') .And. FindFunction('U_PNMSCal')
Local lTecEscala	:= FindFunction( "TecExecPNM" ) .AND. TecExecPNM()

Default cFilSR6    	:= xFilial("SR6")

If !lPEEscala .AND. !lTecEscala
	If !IsBlind()
		Help( , , "TxProjEsc", , STR0076, 1, 0,,,,,,{STR0077}) //"O RDMAKE PNMTABC01 não está compilado no repositorio. Parametro 'MV_GSPNMTA' está desabilitado."##"Para realizar a projeção baseado na escala é necessario que o RDMAKE esteja compilado no repositorio ou ativação do parametro 'MV_GSPNMTA', onde, não necessita da compilação do mesmo."
	EndIf
Else
	If lPEEscala
		U_PNMSEsc(cEscala) // informar escala
		U_PNMSCal(cCalend) // informar calendario
	ElseIf lTecEscala
		TecPNMSEsc( cEscala )
		TecPNMSCal( cCalend )
	EndIf
	lRetCalend := CriaCalend( 	dDatIni    ,;    //01 -> Data Inicial do Periodo
	                           		dDatFim    ,;    //02 -> Data Final do Periodo
	                            	cTurno     ,;    //03 -> Turno Para a Montagem do Calendario
	                            	cSeq       ,;    //04 -> Sequencia Inicial para a Montagem Calendario
	                            	@aTabPadrao,;    //05 -> Array Tabela de Horario Padrao
	                            	@aTabCalend,;    //06 -> Array com o Calendario de Marcacoes
	                            	cFilSR6    ,;    //07 -> Filial para a Montagem da Tabela de Horario
	                            	Nil, Nil )
	If lPEEscala
		U_PNMSEsc(Nil) // Limpar as variaveis estaticas
		U_PNMSCal(Nil)
	ElseIf lTecEscala
		TecPNMSEsc( cEscala )
		TecPNMSCal( cCalend )
	EndIf
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} TxBuscAgen
  Função para buscar a agenda do atendente dentro de um periodo
@since		31/05/2017
@version	P12.1.17
@author 	Inovação - Gestão de Serviços

@param		_cFunFil	Filial do Funcionario
@param		_cMatFunc	Matricula do Funcionario
@param		_cCodTec	Codigo do técnico
@param		_cDataI		Data inicial
@param		_cDataF		Data inicial
@param		_cCodTFF	Codigo do posto
@param		_cContrt	Codigo do contrato

@return 	Caracter, Alias da agenda
/*/
//------------------------------------------------------------------------------
Function TxBuscAgen(_cFunFil,_cMatFunc,_cCodTec,_cDataI,_cDataF,_cCodTFF, _cContrt)
Local cAliasABB	:= GetNextAlias()
Local cSQLFil	:= ""
Local cSqlAtend := ""
Local cSqlTFF	:= ""
Local cWhereABB := " AND ABB_FILIAL = '" + xFilial("ABB") + "' "
Local cABQxABB := " ABQ_FILIAL = '" + xFilial("ABQ") + "' "
Local cAA1xABB := " AA1_FILIAL = '" + xFilial("AA1") + "' "
Local cABSxABB := " ABS_FILIAL = '" + xFilial("ABS") + "' "
Local cABRxABB := " ABR_FILIAL = '" + xFilial("ABR") + "' "
Local cABNxABR := " ABN_FILIAL = '" + xFilial("ABN") + "' "

Default _cCodTFF := ""
Default _cContrt := ""

If FWModeAccess("AA1",3) != "E" .AND. LEN(Rtrim(xFilial("ABB"))) != LEN(Rtrim(xFilial("AA1")))
	cWhereABB := ""
	cABQxABB := FWJoinFilial("ABQ" , "ABB" , "ABQ", "ABB", .T.)
	cAA1xABB := FWJoinFilial("AA1" , "ABB" , "AA1", "ABB", .T.)
	cABSxABB := FWJoinFilial("ABS" , "ABB" , "ABS", "ABB", .T.)
	cABRxABB := FWJoinFilial("ABR" , "ABB" , "ABR", "ABB", .T.)
	cABNxABR := FWJoinFilial("ABN" , "ABR" , "ABN", "ABR", .T.)
EndIf

cWhereABB := "% " + cWhereABB + " %"
cABQxABB := "% AND " + cABQxABB + " %"
cABSxABB := "% AND " + cABSxABB + " %"
cABRxABB := "% AND " + cABRxABB + " %"
cABNxABR := "% AND " + cABNxABR + " %"

If FWModeAccess("TDV",3) == FWModeAccess("ABB",3)
	cSQLFil := "%"
	cSQLFil += " TDV.TDV_FILIAL = ABB.ABB_FILIAL "
	cSQLFil += "%"
Else
	cSQLFil := "%"
	cSQLFil += "TDV.TDV_FILIAL = '" + xFilial("TDV") + "' "
	cSQLFil += "%"
EndIf 

//Query do Atendente
cSqlAtend := "% "
If !Empty(_cMatFunc)
	cSqlAtend += "   AND AA1_CDFUNC =  '" +_cMatFunc+ "'"
	cSqlAtend += "   AND AA1_FUNFIL =  '" + _cFunFil+ "'"
	cSqlAtend += "   AND " + cAA1xABB
Else
	cSqlAtend += "   AND " + cAA1xABB
EndIf

cSqlAtend += " %"

cSqlTFF := "%"
//Query do posto
If !Empty(_cCodTFF)
	cSqlTFF += " AND TFF_COD = '" +_cCodTFF + "'"
EndIf

If !Empty(_cContrt)
	cSqlTFF += " AND TFF_CONTRT = '" +_cContrt + "' "
EndIf

cSqlTFF += "%"

BeginSql Alias cAliasABB

	COLUMN TDV_DTREF AS DATE
	COLUMN ABB_DTINI AS DATE
	COLUMN ABB_DTFIM AS DATE
		SELECT ABB_CODIGO
		     , ABB_MANUT
		     , ABB_CODTEC
		     , ABB_ATIVO
		     , TDV_DTREF
		     , ABB_DTINI
		     , ABB_HRINI
		     , ABB_DTFIM
		     , ABB_HRFIM
		     , ABB_LOCAL
		     , ABS_CODIGO
		     , ABS_LOJA
		     , COALESCE(ABR_CODSUB,'') ABR_CODSUB
		     , COALESCE(ABN_TIPO,'') ABN_TIPO
		     , TDV_FERIAD
		     , TDV_TURNO
		     , TFF_FILIAL
		     , TFF_CONTRT
		     , TFF_COD
		  FROM %Table:ABB% ABB

		  JOIN %Table:ABS% ABS ON ABS_LOCAL = ABB_LOCAL
		   AND ABS.%NotDel%
		   %Exp:cABSxABB%

		  LEFT OUTER JOIN %Table:ABR% ABR ON ABR_AGENDA = ABB_CODIGO
		   AND ABR.%NotDel%
		   %Exp:cABRxABB%

		  LEFT OUTER JOIN %Table:ABN% ABN ON ABN_CODIGO = ABR_MOTIVO
		   AND ABN.%NotDel%
		   %Exp:cABNxABR%

		  JOIN %Table:AA1% AA1 ON AA1_CODTEC = ABB_CODTEC
		   AND AA1.%NotDel%
		   %Exp:cSqlAtend%

		  JOIN %Table:TDV% TDV ON %Exp:cSqlFil%
		   AND TDV_CODABB = ABB_CODIGO
		   AND TDV.%NotDel%

		  JOIN %Table:ABQ% ABQ ON ABQ_CONTRT||ABQ_ITEM||ABQ_ORIGEM = ABB_IDCFAL
		   AND ABQ.%NotDel%
		   %Exp:cABQxABB%

		  JOIN %Table:TFF% TFF ON TFF_FILIAL = ABQ_FILTFF
		   AND TFF_COD = ABQ_CODTFF
		   AND TFF.%NotDel%
		   %Exp:cSqlTFF%

		 WHERE ABB.ABB_CODTEC = %Exp:_cCodTec%
   		   AND TDV.TDV_DTREF >= %Exp:_cDataI%
		   AND TDV.TDV_DTREF <= %Exp:_cDataF%
		   AND ABB.ABB_ATIVO = '1'
		   AND ABB.%NotDel%
		   %Exp:cWhereABB%

		 ORDER BY TDV_DTREF
		        , ABB_DTINI
		        , ABB_HRINI
		        , ABB_DTFIM
		        , ABB_HRFIM
		        , TFF_CONTRT
		        , ABB_LOCAL

EndSql

Return cAliasABB

//-------------------------------------------------------------------
/*/{Protheus.doc} TxStrAlias()

Retorna a estrutura de um alias

@author Serviços
@since 05/09/2017
@version P12.1.17
@return array, 	aStruc - Estrutura do Alias
/*/
//------------------------------------------------------------------
Function TxStrAlias(cAlias)

Local aArea := GetArea()
Local aStruct  := {}

If !Empty(cAlias)

	DbSelectArea("SX3")
	DbSetOrder(1)

	MsSeek(cAlias)

	While !EOF() .And. (SX3->X3_ARQUIVO == cAlias)

		If SX3->X3_CONTEXT <> 'V'
			AADD(aStruct,{SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		EndIf

		DbSkip()

	EndDo

EndIf

RestArea(aArea)

Return aStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} TxStrAlias()

Retorna array com as localizacoes fisicas (AGW)

@author Serviços
@since 09/11/2017
@version P12.1.17
@return array
/*/
//------------------------------------------------------------------
Function GSAGWLoad(nOpc,cContra,cPlanil)
Local aRet := {}
Local nX   := 0

Default cContra := CNA->CNA_CONTRA
Default cPlanil := CNA->CNA_NUMERO

DbSelectArea("AGW")
If AliasInDic("AGW") .And. nOpc # 3
	AGW->(dbSetOrder(2))
	AGW->(dbSeek(xFilial("AGW")+cContra+cPlanil))

	While AGW->(!EOF()) .And. Alltrim(AGW->AGW_FILIAL+AGW_CONTRA+AGW_PLANIL) == Alltrim(xFilial("AGW")+cContra+cPlanil)
		aAdd(aRet,{AGW->AGW_ITEM,Array(AGW->(FCount()))})
		For nX := 1 To Len(aTail(aRet)[2])
			aTail(aRet)[2,nX] := {AGW->(FieldName(nX)),AGW->&(FieldName(nX))}
		Next nX

		AGW->(dbSkip())
	End
EndIf

DbCloseArea()
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TECLOCFIS

Chamada da função de atualização da localização física

@author Serviços
@since 17/11/2017
/*/
//-------------------------------------------------------------------
Function TECLOCFIS()
Local oModel 	:= FwModelActive()
Local oModCN9	:= oModel:GetModel("CN9MASTER")
Local oModCNA	:= oModel:GetModel("CNADETAIL")
Local oModCNB	:= oModel:GetModel("CNBDETAIL")
Local oStruCNB	:= oModCNB:GetStruct()
Local cContra	:= oModCN9:GetValue("CN9_NUMERO")
Local cRevisa	:= oModCN9:GetValue("CN9_REVISA")
Local cPlan		:= oModCNA:GetValue("CNA_NUMERO")
Local cProdut	:= oModCNB:GetValue("CNB_PRODUT")
Local cBaseIns	:= oModCNB:GetValue("CNB_BASINS")
Local cItem		:= oModCNB:GetValue("CNB_ITEM")
Local cPlanil	:= oModCNA:GetValue("CNA_NUMERO")
Local cCliente  := oModCNA:GetValue("CNA_CLIENT")
Local cLojaCli  := oModCNA:GetValue("CNA_LOJACL")
Local nPosLocal := 0
Local nX 	    := 0
Local nY		:= 0
Local nPLANIL 	:= 0
Local nITEM2  	:= 0
Local nCLIENT 	:= 0
Local nLOJA   	:= 0
Local nCODFAB 	:= 0
Local nLOJAFA 	:= 0
Local nPRODUT2 	:= 0
Local nNUMSER 	:= 0
Local aLocais   := GSAGWLoad(oModel:GetOperation(), cContra, cPlan)
Local aDadosCtr := {}
Local aTail		:= {}
Local aPlani	:= {}
Local lBkpINC   := oModel:GetOperation() == MODEL_OPERATION_INSERT
Local lBkpALT   := oModel:GetOperation() == MODEL_OPERATION_UPDATE
Local lVisual	:= oModel:GetOperation() == MODEL_OPERATION_VIEW
Local lInclui	:= .F.
Local lAltera	:= .F.
Local lConfirm  := .F.
Local lValidou  := .F.

If oStruCNB <> Nil
	If Empty(cProdut)
		Aviso("Atenção","Informe o código do produto/eqpto.",{"OK"}) //-- Informe o código do produto/eqpto.
	ElseIf cBaseIns <> "1"
		Aviso("Atenção","Produto/eqpto não configurado para geração de base instalada.",{"OK"}) //-- Produto/eqpto não configurado para geração de base instalada.
	ElseIf Posicione("CNB",1,xFilial("CNB")+cContra+cRevisa+cPlan+cItem,"CNB_GERBIN") == "1"
		Aviso("Atenção","Já foi gerada base instalada para este produto/eqpto.",{"OK"}) //-- Já foi gerada base instalada para este produto/eqpto.
	Else
		AGW->(dbSetOrder(2))
		If lVisual
			If AGW->(dbSeek(xFilial("AGW")+cContra+cPlan+cItem))
				AT110Man("AGW",AGW->(Recno()),2,,,,,oModCNB)
			EndIf
		ElseIf (nPosLocal := aScan(aLocais,{|x| x[1] == cItem})) > 0
			If !AGW->(dbSeek(xFilial("AGW")+cContra+cPlan+cItem))
				lInclui := .T.
				lAltera := .F.
			Else
				lInclui := .F.
				lAltera := .T.
			EndIf

			If nPosLocal > 0
				aDadosCtr := aClone(aLocais[nPosLocal,2])
				//-- Tratamento para troca do produto
				If (nPRODUT2 := aScan(aDadosCtr,{|x| x[1] == "AGW_PRODUT"})) > 0
					aDadosCtr[nPRODUT2,2] := cProdut
				EndIf
			Else
				For nX := 1 To AGW->(FCount())
					aAdd(aDadosCtr,{Trim(AGW->(FieldName(nX))),AGW->&(FieldName(nX))})
				Next nX
			EndIf

			lConfirm := AT110Man("AGW",AGW->(Recno()),If(AGW->(Found()),4,3),aDadosCtr,cPlanil,,,oModCNB)
		Else
			lInclui := .T.
			lAltera := .F.

			aAdd(aDadosCtr,{"AGW_CONTRA",cContra,.F.})
			aAdd(aDadosCtr,{"AGW_PLANIL",cPlanil,.F.})
			aAdd(aDadosCtr,{"AGW_ITEM",cItem,.F.})
			aAdd(aDadosCtr,{"AGW_CLIENT",cCliente,.F.})
			aAdd(aDadosCtr,{"AGW_LOJA",cLojaCli,.F.})
			aAdd(aDadosCtr,{"AGW_PRODUT",cProdut,.F.})
			aAdd(aDadosCtr,{"AGW_DESCRI",Posicione("SB1",1,xFilial("SB1")+cProdut,"B1_DESC"),.F.})

			lConfirm := AT110Man("AGW",0,3,aDadosCtr,cPlanil,,,oModCNB)
		EndIf

		//-- Valida chaves
		While aPlani # NIL .And. lConfirm .And. !lValidou
			lValidou := .T.

			nPLANIL  := aScan(aDadosCtr,{|x| x[1] == "AGW_PLANIL"})
			nITEM2   := aScan(aDadosCtr,{|x| x[1] == "AGW_ITEM"})
			nCLIENT  := aScan(aDadosCtr,{|x| x[1] == "AGW_CLIENT"})
			nLOJA    := aScan(aDadosCtr,{|x| x[1] == "AGW_LOJA"})
			nCODFAB  := aScan(aDadosCtr,{|x| x[1] == "AGW_CODFAB"})
			nLOJAFA  := aScan(aDadosCtr,{|x| x[1] == "AGW_LOJAFA"})
			nPRODUT2 := aScan(aDadosCtr,{|x| x[1] == "AGW_PRODUT"})
			nNUMSER  := aScan(aDadosCtr,{|x| x[1] == "AGW_NUMSER"})

			For nX := 1 To Len(aPlani)
				//-- Planilha sem localizacoes
				If Empty(aTail(aPlani[nX]))
					Loop
				EndIf

				For nY := 1 To Len(aTail(aPlani[nX]))
					//-- Mesmo item da mesma planilha
					If aTail(aPlani[nX])[nY,2,nPLANIL,2]+aTail(aPlani[nX])[nY,2,nITEM2,2] == cPlanil+cItem
						Loop
					EndIf

					If aTail(aPlani[nX])[nY,2,nCLIENT,2] == aDadosCtr[nCLIENT,2] .And.;
									aTail(aPlani[nX])[nY,2,nLOJA,2] == aDadosCtr[nLOJA,2] .And.;
									aTail(aPlani[nX])[nY,2,nPRODUT2,2] == aDadosCtr[nPRODUT2,2] .And.;
									aTail(aPlani[nX])[nY,2,nNUMSER,2] == aDadosCtr[nNUMSER,2]
						Help(" ",1,"AT040INC01")
						lValidou := .F.
					EndIf
				Next nY
			Next nX

			If !lValidou
				lConfirm := AT110Man("AGW",0,If(lInclui,3,4),aDadosCtr,cPlanil,,,oModCNB)
			EndIf
		End

		If lConfirm
			If (nPosLocal := aScan(aLocais,{|x| x[1] == cItem})) == 0
				aAdd(aLocais,{cItem,aClone(aDadosCtr)})
			Else
				aLocais[nPosLocal,2] := aClone(aDadosCtr)
			EndIf
		EndIf
	EndIf
EndIf

lInclui := lBkpINC
lAltera := lBkpALT

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TECHTMLMap
Gera um HTML de google maps a partir de um array de coordenadas.

@param cNomeArq, string, valor da tag title no HTML
@param aCoordenadas, array, array bidimensional que deve receber:
 (1) Latitude, (2) Longitude, (3) Título do pin, (4) cor do pin
@param cZoom, string, qual deve ser o zoom do google maps
@param nCenter, int, em qual dos pins o mapa deve ser centralizado

@author Mateus Boiani
@since 24/01/2018
/*/
//-------------------------------------------------------------------
Function TECHTMLMap(cNomeArq, aCoordenadas, cZoom, nCenter)
Local cHtml
Local nX
Local cAppId := "AIzaSyD9va9dHwtTClye_apM9Gy7GBYmUQTi4og"

Default cNomeArq := "Mapa"
Default aCoordenadas := {{"-23.5084952",; 		// [1]Latitude
							"-46.6536569",; 			// [2]Longitude
							"TOTVS - Nova Sede",;	// [3]Título
							"green"}}					// [4]Cor da marcação
Default nCenter := 1

cHtml := '<!DOCTYPE html>'
cHtml += '<html>'
cHtml += '<head>'
cHtml += '    <meta name="viewport" content="initial-scale=1.0, user-scalable=no">'
cHtml += '    <meta charset="utf-8">'
cHtml += '    <title>' + Alltrim(STRTRAN(STRTRAN(cNomeArq,'</title>',""),'<title>',""))  + '</title>'
cHtml += '    <style>'
cHtml += '      #map {'
cHtml += '        height: 100%;'
cHtml += '        width: 100%;'
cHtml += '      }'
cHtml += '      html, body {'
cHtml += '        height: 100%;'
cHtml += '        width: 100%;'
cHtml += '        margin: 0;'
cHtml += '        padding: 0;'
cHtml += '      }'
cHtml += '    </style>'
cHtml += '  </head>'
cHtml += '  <body>'
cHtml += '    <div id="map"></div>'
cHtml += '    <script>'
cHtml += '      function initMap() {'
cHtml += ' 		var mapBoundries = new google.maps.LatLngBounds(); '
For nX := 1 To LEN(aCoordenadas)
	cHtml += '        var myLatLng' + cValToChar(nX) + ' = {lat:' + aCoordenadas[nX][1] + ', lng:' +  aCoordenadas[nX][2] + '};'
Next
cHtml += '        var map = new google.maps.Map(document.getElementById("map"), {'
cHtml += '          zoom: '+ cZoom +','
cHtml += '      	maxZoom: 18,'
cHtml += '          center: myLatLng' + cValToChar(nCenter) + ',
cHtml += '			 streetViewControl: false'
cHtml += '        });'
For nX := 1 TO LEN(aCoordenadas)
	cHtml += '        var marker' + cValToChar(nX) + ' = new google.maps.Marker({'
	cHtml += '          position: myLatLng' + cValToChar(nX) + ','
	cHtml += '          map: map,'
	cHtml += '          title: "' + aCoordenadas[nX][3] + '",'
	cHtml += "          icon: 'http://maps.google.com/mapfiles/ms/icons/" + aCoordenadas[nX][4] + "-dot.png'"
	cHtml += '        });'

	cHtml += '  markerLatLng' + cValToChar(nX) + ' = new google.maps.LatLng(marker' + cValToChar(nX) + '.position.lat(), marker' + cValToChar(nX) + '.position.lng());'
    cHtml += '  mapBoundries.extend(markerLatLng' + cValToChar(nX) + '); '
Next
If VALTYPE(aCoordenadas) == 'A' .AND. !EMPTY(aCoordenadas)
	cHtml += '        var pos = new google.maps.LatLng(' + aCoordenadas[nCenter][1] + ',' +  aCoordenadas[nCenter][2] + ');'
EndIf
cHtml += '        map.setCenter(pos);'
cHtml += '        map.panTo(pos);'
cHtml += '        map.fitBounds(mapBoundries);'
cHtml += '        map.panToBounds(mapBoundries);'
cHtml += '      }'
cHtml += '    </script>'
cHtml += '    <script async defer'
cHtml += '    src="https://maps.googleapis.com/maps/api/js?key=' + cAppId + '&callback=initMap">'
cHtml += '    </script>'
cHtml += '  </body>'
cHtml += '</html>'

Return cHtml

//-------------------------------------------------------------------
/*/{Protheus.doc} TECGenMap
Gera um arquivo em uma pasta determinada e o abre via shellExecute

@param cHtml, string, o que deve ser escrito no arquivo gerado
@param cPath, string, Local + extensão do arquivo gerado
@param nSleep, int, valor em milisegundos que a thread deve aguardar até tentar abrir o arquivo
@param lShellExec, bool, indica se deve ou não realizar o shellExecute de openfile. Default := .T.

@author Mateus Boiani
@since 24/01/2018
/*/
//-------------------------------------------------------------------
Function TECGenMap(cHtml, cPath, nSleep, lShellExec)
Local	nHandle
Local lCriou

Default cPath := GetTempPath() + "locationcheckin.html"
Default nSleep := 1000
Default lShellExec := .T.

nHandle := FCREATE(cPath, 0)
IF nHandle == -1
	MsgAlert("O Arquivo não foi criado: " + STR(FERROR()))
Else
	lCriou := .T.
	FWrite(nHandle, cHtml)
	FClose(nHandle)
	SLEEP(nSleep)
EndIf

If lShellExec .AND. lCriou
	ShellExecute("open",cPath ,"","",2)
EndIf

Return lCriou

//-------------------------------------------------------------------
/*/{Protheus.doc} TECGtCoord
Retorna um array de duas posições com latitude e longitude de um determinado endereço

@param cEndereco, string, endereço do local pesquisado (Nome da rua, Número, Complemento)
@param cMunic, string, município do local pesquisado
@param cEstado, string, UF do local pesquisado
@param nVezes, int, Número de tentativas que a função tentará executar um HttpGet no endereço do Google (Default := 10)

@author Mateus Boiani
@since 24/01/2018
/*/
//-------------------------------------------------------------------
Function TECGtCoord(cEndereco, cMunic, cEstado, nVezes)
Local aCord	 := {}
Local cAddress
Local nI
Local cJson
Local oJson
Local aLocs	 := {}
Local nR		 := 1
Local cShowLog := ""
Local cLocais	 := ""
Local cEnder	 := ""
Local cLat		 := ""
Local cLng		 := ""
Local cAppId := "AIzaSyClktWAZVsEnkFziSMIBFiECGwnoX8OQ-4"

Default cEndereco := ""
Default cMunic := ""
Default cEstado := ""
Default nVezes := 10

cAddress  := StrTran(Alltrim(cEndereco), ' ','%20') + StrTran(Alltrim(cMunic), ' ','%20') + StrTran(Alltrim(cEstado), ' ','%20')

For nI := 1 To nVezes
	cJson  := HttpGet( 'https://maps.googleapis.com/maps/api/geocode/json?address='+cAddress+'&key='+cAppId)
	If  "You have exceeded your daily request" $ cJson
		Loop
	Else
		FWJsonDeserialize(cJson ,@oJson)
		lOk := .T.
		Exit
	EndIf
Next nI

If lOk .AND. VALTYPE(oJson:Results) == 'A' .AND. !EMPTY(oJson:Results)
	If Len(oJson:Results) == 1
	   aCord := {}
	   cLat  := AllTrim(Str(oJson:Results[1]:GEOMETRY:LOCATION:LAT))
	   cLng  := AllTrim(Str(oJson:Results[1]:GEOMETRY:LOCATION:LNG))
	   aAdd(aCord, cLat)
	   aAdd(aCord, cLng)

	Else
	   cEnder  := AllTrim(oJson:Results[nR]:FORMATTED_ADDRESS)
	   cLat    := AllTrim(Str(oJson:Results[1]:GEOMETRY:LOCATION:LAT))
	   cLng    := AllTrim(Str(oJson:Results[1]:GEOMETRY:LOCATION:LNG))

	   For nR := 1 To Len(oJson:Results)
	   		aAdd(aLocs, {cEnder, cLat, cLng} )
	   Next nR
	   aCord := {"",""}
	EndIf
Else
    aCord := {"",""}
EndIf

Return aCord

//-------------------------------------------------------------------
/*/{Protheus.doc} TECGtZoom
Retorna uma string que representa um valor de "zoom" utilizado no google.maps para posicionamento

@param cEndereco, string, endereço do local pesquisado (Nome da rua, Número, Complemento)
@param cMunic, string, município do local pesquisado
@param cEstado, string, UF do local pesquisado

@author Mateus Boiani
@since 24/01/2018
/*/
//-------------------------------------------------------------------
Function TECGtZoom(cEndereco, cMunic, cEstado)
Local cZoom := '19'

Do Case
	Case Empty(cMunic) .AND. Empty(cEstado) //Só o endereço preenchido
		cZoom := '19'
	Case Empty(cEndereco) .AND. Empty(cEstado) //Só o município preenchido
		cZoom := '12'
	Case Empty(cEndereco) .AND. Empty(cMunic) //Só o Estado preenchido
		cZoom := '6'
EndCase

Return cZoom

//-------------------------------------------------------------------
/*/{Protheus.doc} TECdiffArr
Verifica se dois arrays tem a mesma estrutura e os mesmos valores em todas as suas posições

@param aArr1, array, primeiro array que será utilizado na comparação
@param aArr2, array, segundo array que será utilizado na comparação
@return lRet, bool, retorna .T. se houver qualquer diferença (tamanho ou valores) ou .F. se forem iguais

@author Mateus Boiani
@since 03/07/2018
/*/
//-------------------------------------------------------------------
Function TECdiffArr(aArr1, aArr2)
Local nX
Local lRet := .F.

If LEN(aArr1) != LEN(aArr2)
	lRet := .T.
EndIf

If !lRet
	For nX := 1 To LEN(aArr1)
		If (VALTYPE(aArr1[nX]) == 'N' .AND. VALTYPE(aArr2[nX]) == 'N') .OR.;
				(VALTYPE(aArr1[nX]) == 'C' .AND. VALTYPE(aArr2[nX]) == 'C') .OR.;
					(VALTYPE(aArr1[nX]) == 'L' .AND. VALTYPE(aArr2[nX]) == 'L') .OR.;
						(VALTYPE(aArr1[nX]) == 'U' .AND. VALTYPE(aArr2[nX]) == 'U')

			If (VALTYPE(aArr1[nX]) != 'U' .AND. VALTYPE(aArr2[nX]) != 'U')
				If !(aArr1[nX] == aArr2[nX])
					lRet := .T.
					Exit
				EndIf
			EndIf

		ElseIf (VALTYPE(aArr1[nX]) == 'B' .AND. VALTYPE(aArr2[nX]) == 'B')
			If !(GetCBSource(aArr1[nX]) == GetCBSource(aArr2[nX]))
				lRet := .T.
				Exit
			EndIf
		ElseIf (VALTYPE(aArr1[nX]) == 'A' .AND. VALTYPE(aArr2[nX]) == 'A')
			lRet := TECdiffArr(aArr1[nX], aArr2[nX])
			If lRet
				Exit
			EndIf
		Else
			lRet := .T.
			Exit
		EndIf
	Next
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AtJustChar
Retorna apenas os caracteres aceitos da String

@param cStr, character, String a tratar
@param cAccept, character, Caracteres aceitos

@return character, String tratada

@author Mateus Boiani
@since 08/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function AtJustChar(cStr, cAccept)
local cRet := ""
Local nI := 0
Local cChar := ""

For nI := 1 to Len(cStr)
	If (cChar := Substr(cStr, nI, 1))$cAccept
		cRet += cChar
	Endif
Next
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AtJustNum
Retorna apenas os números da string

@param cValue, character, string a ser tratada
@return character, todos os caracteres numéricos de cValue
@author Mateus Boiani
@since 08/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Function AtJustNum(cValue)

Return AtJustChar(cValue, "0123456789")


//-------------------------------------------------------------------
/*/{Protheus.doc} TxRetArm()

Retorno da consulta especifica

@author Rebeca Facchinato Asunção
@since 25/08/2017
@version P12.1.17
@return Nil
/*/
//------------------------------------------------------------------
Function TxRetArm()

Return cRetProd

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TxPrdArmA

Construção da consulta especifica para armamentos.

@author Rebeca Facchinato Asunção
@since 25/08/2017
@version P12.1.17
@return Nil
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TxPrdArma(nOpc) //-- Produtos B1 e B5
Local lRet        := .F.
Local oBrowse     := Nil
Local cAls        := GetNextAlias()
Local nSuperior   := 0
Local nEsquerda   := 0
Local nInferior   := 0
Local nDireita    := 0
Local cQry        := ""
Local aIndex      := {}
Local aSeek       := {}
Local oView       := Nil
Local oDlgEscTela := Nil

Aadd( aSeek, { STR0063, {{"","C",TamSX3("B1_COD")[1],0,STR0063,,}} } ) // "Código" ### "Código"
Aadd( aSeek, { STR0064, {{"","C",TamSX3("B1_DESC")[1],0,STR0064,,}}}) // "Descrição" ### "Descrição"

Aadd( aIndex, "B1_COD" )
Aadd( aIndex, "B1_DESC")
Aadd( aIndex, "B1_FILIAL")  // adicionado para não ter problema de não encontrar o último índice, em caso de adicionar mais deixe a filial por último

cQry :=     " SELECT B1_FILIAL, B1_COD, B1_DESC"
cQry +=     " FROM " + RetSqlName("SB1") + " B1"
cQry +=     " INNER JOIN " + RetSqlName("SB5") + " B5"
cQry +=     " ON B5.B5_FILIAL = '"+xFilial("SB5")+"' "
cQry +=     " AND B1.B1_COD = B5.B5_COD"
cQry +=     " AND B1.B1_FILIAL = '"+xFilial("SB1")+"'"

Do Case
      Case nOpc == 1
            cQry += 	" AND B5_TPISERV = '1'" // Arma
      Case nOpc == 2
            cQry += 	" AND B5_TPISERV = '2'" //Colete
      Case nOpc == 3
            cQry += 	" AND B5_TPISERV = '3'" //Municao
EndCase

cQry +=     " AND B1.D_E_L_E_T_ = ' '"
cQry +=     " AND B5.D_E_L_E_T_ = ' '"
cQry +=     " WHERE B1_FILIAL = '" +  xFilial('SB1') + "'

nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800
If !isBlind()
	DEFINE MSDIALOG oDlgEscTela TITLE STR0057 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL // "Produtos"

	oBrowse := FWFormBrowse():New()
	oBrowse:SetOwner(oDlgEscTela)
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetAlias(cAls)
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetQuery(cQry)
	oBrowse:SetSeek(,aSeek)
	oBrowse:SetDescription(STR0057)  // "Produtos"
	oBrowse:SetMenuDef("")
	oBrowse:DisableDetails()

	oBrowse:SetDoubleClick({ || cRetProd := (oBrowse:Alias())->B1_COD, lRet := .T. ,oDlgEscTela:End()})
	oBrowse:AddButton( OemTOAnsi(STR0061), {|| cRetProd   := (oBrowse:Alias())->B1_COD, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
	oBrowse:AddButton( OemTOAnsi(STR0062),  {||  cRetProd  := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
	oBrowse:DisableDetails()

	ADD COLUMN oColumn DATA { ||  B1_COD  } TITLE STR0063 SIZE TamSX3("B1_COD")[1] OF oBrowse //"Código"
	ADD COLUMN oColumn DATA { ||  B1_DESC } TITLE STR0064 SIZE TamSX3("B1_DESC")[1] OF oBrowse //"Descrição"

	oBrowse:Activate()

	ACTIVATE MSDIALOG oDlgEscTela CENTERED
EndIf
Return( lRet )


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TxProdArm

Construção da consulta especifica para armamentos.

@author Rebeca Facchinato Asunção
@since 25/08/2017
@version P12.1.17
@return Nil
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TxProdArm(nOpc) //-- Armas, coletes e munição

Local lRet        := .F.
Local oBrowse     := Nil
Local cAls        := GetNextAlias()
Local nSuperior   := 0
Local nEsquerda   := 0
Local nInferior   := 0
Local nDireita    := 0
Local cQry        := ""
Local aIndex      := {}
Local aSeek       := {}
Local oView       := Nil
Local oDlgEscTela := Nil

Do Case
      Case nOpc == 1
	  	Aadd( aSeek, { STR0131, {{"","C",TamSX3("TE0_COD")[1],0,STR0131,,}} } ) // "Cod. Arma" ### "Cod. Arma"
		  
		Aadd( aIndex, "TE0_COD" )
	  	
		cQry :=    "  SELECT TE0_COD, B1_COD, B1.B1_DESC FROM " + RetSqlName("TE0") + " TE0 "
		cQry +=     " INNER JOIN "  + RetSqlName("SB1")  + " B1 " +   "ON B1_FILIAL =  '" + xFilial("SB1") + "' AND B1.B1_COD = TE0.TE0_CODPRO AND B1.D_E_L_E_T_ = ' '"
		cQry +=     " INNER JOIN "  + RetSqlName("SB5")  + " B5 " +  "ON B5_FILIAL =  '" + xFilial("SB5") + "'  AND B5.B5_COD = B1.B1_COD AND B5.D_E_L_E_T_ = ' '"
		cQry +=     " WHERE TE0_FILIAL = '" +  xFilial('TE0') + "'"
		cQry +=     " AND TE0.D_E_L_E_T_ = ' '"
      Case nOpc == 2
	  	Aadd( aSeek, { STR0132, {{"","C",TamSX3("TE1_CODCOL")[1],0,STR0132,,}} } ) // "Cod. Colete" ### "Cod. Colete"

		Aadd( aIndex, "TE1_CODCOL" )
	  	
      	cQry :=    "  SELECT TE1_CODCOL, B1_COD, B1.B1_DESC FROM " + RetSqlName("TE1") + " TE1 "
		cQry +=     " INNER JOIN "  + RetSqlName("SB1")  + " B1 " +   "ON B1_FILIAL =  '" + xFilial("SB1") + "' AND B1.B1_COD = TE1.TE1_CODPRO AND B1.D_E_L_E_T_ = ' '"
		cQry +=     " INNER JOIN "  + RetSqlName("SB5")  + " B5 " +  "ON B5_FILIAL =  '" + xFilial("SB5") + "'  AND B5.B5_COD = B1.B1_COD AND B5.D_E_L_E_T_ = ' '"
		cQry +=     " WHERE TE1_FILIAL = '" +  xFilial('TE1') + "'"
		cQry +=     " AND TE1.D_E_L_E_T_ = ' '"
	  Case nOpc == 3
	  	Aadd( aSeek, { STR0063, {{"","C",TamSX3("B1_COD")[1],0,STR0063,,}} } ) // "Código" ### "Código"

		Aadd( aIndex, "B1_COD")
		
      	cQry :=    "  SELECT DISTINCT B1_COD , B1.B1_DESC FROM " + RetSqlName("TE2") + " TE2 "
      	cQry +=     " INNER JOIN "  + RetSqlName("SB1")  + " B1 " +   "ON B1_FILIAL =  '" + xFilial("SB1") + "' AND B1.B1_COD = TE2.TE2_CODPRO AND B1.D_E_L_E_T_ = ' '"
		cQry +=     " INNER JOIN "  + RetSqlName("SB5")  + " B5 " +  "ON B5_FILIAL =  '" + xFilial("SB5") + "'  AND B5.B5_COD = B1.B1_COD AND B5.D_E_L_E_T_ = ' '"
		cQry +=     " WHERE TE2_FILIAL = '" +  xFilial('TE2') + "'"
		cQry +=     " AND TE2.D_E_L_E_T_ = ' '"
EndCase
Aadd( aSeek, { STR0064, {{"","C",TamSX3("B1_DESC")[1],0,STR0064,,}}}) // "Descrição" ### "Descrição"
Aadd( aIndex, "B1_DESC")
nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800
If !isBlind()
	DEFINE MSDIALOG oDlgEscTela TITLE STR0057 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL // "Produtos"

	oBrowse := FWFormBrowse():New()
	oBrowse:SetOwner(oDlgEscTela)
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetAlias(cAls)
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetQuery(cQry)
	oBrowse:SetSeek(,aSeek)
	oBrowse:SetDescription(STR0057)  // "Produtos"
	oBrowse:SetMenuDef("")
	oBrowse:DisableDetails()

	If nOpc == 1
		oBrowse:SetDoubleClick({ || cRetProd := (oBrowse:Alias())->TE0_COD, lRet := .T. ,oDlgEscTela:End()})
		oBrowse:AddButton( OemTOAnsi(STR0061), {|| cRetProd   := (oBrowse:Alias())->TE0_COD, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
		ADD COLUMN oColumn DATA { ||  TE0_COD  } TITLE STR0063 SIZE TamSX3("TE0_COD")[1] OF oBrowse //"Código"
	ElseIf nOpc == 2
		oBrowse:SetDoubleClick({ || cRetProd := (oBrowse:Alias())->TE1_CODCOL, lRet := .T. ,oDlgEscTela:End()})
		oBrowse:AddButton( OemTOAnsi(STR0061), {|| cRetProd   := (oBrowse:Alias())->TE1_CODCOL, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
		ADD COLUMN oColumn DATA { ||  TE1_CODCOL  } TITLE STR0063 SIZE TamSX3("TE1_CODCOL")[1] OF oBrowse //"Código"
	ElseIf nOpc == 3
		oBrowse:SetDoubleClick({ || cRetProd := (oBrowse:Alias())->B1_COD, lRet := .T. ,oDlgEscTela:End()})
		oBrowse:AddButton( OemTOAnsi(STR0061), {|| cRetProd   := (oBrowse:Alias())->B1_COD, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
		ADD COLUMN oColumn DATA { ||  B1_COD  } TITLE STR0063 SIZE TamSX3("B1_COD")[1] OF oBrowse //"Código"

	EndIf

	ADD COLUMN oColumn DATA { ||  B1_DESC } TITLE STR0064 SIZE TamSX3("TE2_DESPRO")[1] OF oBrowse //"Descrição"

	oBrowse:AddButton( OemTOAnsi(STR0062),  {||  cRetProd  := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
	oBrowse:DisableDetails()

	oBrowse:Activate()

	ACTIVATE MSDIALOG oDlgEscTela CENTERED
EndIf
Return( lRet )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TxSitAA3()

Construção da consulta dos status da base de atendimento
            
@author Matheus Lando Raimundo	
@since 26/03/2019
@version P12.1.23
@return Nil
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TxSitAA3() //-- Armas, coletes e munição

Local lRet        := .F.
Local oBrowse     := Nil
Local cAls        := GetNextAlias()
Local nSuperior   := 0
Local nEsquerda   := 0
Local nInferior   := 0
Local nDireita    := 0
Local cQry        := ""
Local aIndex      := {}
Local aSeek       := {} 
Local oView       := Nil
Local oDlgEscTela := Nil

Aadd( aSeek, { STR0063, {{"","C",TamSX3("X5_CHAVE")[1],0,STR0063,,}} } ) // "Código" ### "Código"
Aadd( aSeek, { STR0064, {{"","C",TamSX3("X5_DESCRI")[1],0,STR0064,,}}}) // "Descrição" ### "Descrição"

Aadd( aIndex, "X5_CHAVE" )
Aadd( aIndex, "X5_DESCRI")

      
cQry :=    "  SELECT X5_CHAVE, X5_DESCRI FROM " + RetSqlName("SX5") + " SX5 " 
cQry +=     " WHERE X5_FILIAL = '" +  xFilial('SX5') + "'" 
cQry +=     " AND X5_TABELA = 'A5'"
cQry +=     " AND D_E_L_E_T_ = ' '"

nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800

If !isBlind()
	DEFINE MSDIALOG oDlgEscTela TITLE STR0089 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL // "Status

	oBrowse := FWFormBrowse():New() 
	oBrowse:SetOwner(oDlgEscTela)
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetAlias(cAls)
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetQuery(cQry)
	oBrowse:SetSeek(,aSeek)
	oBrowse:SetDescription(STR0090)  // "Status Base atendimento"
	oBrowse:SetMenuDef("")
	oBrowse:DisableDetails()


	oBrowse:SetDoubleClick({ || cRetSta := (oBrowse:Alias())->X5_CHAVE, lRet := .T. ,oDlgEscTela:End()})
	oBrowse:AddButton( OemTOAnsi(STR0061), {|| cRetSta   := (oBrowse:Alias())->X5_CHAVE, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"


	ADD COLUMN oColumn DATA { ||  X5_CHAVE  } TITLE STR0063 SIZE TamSX3("X5_CHAVE")[1] OF oBrowse //"Código"	
	ADD COLUMN oColumn DATA { || AtPosSX5(X5_CHAVE), X5Descri() } TITLE STR0064 SIZE TamSX3("X5_DESCRI")[1] OF oBrowse //"Descrição"

	oBrowse:AddButton( OemTOAnsi(STR0062),  {||  cRetSta  := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
	oBrowse:DisableDetails()

	oBrowse:Activate()

	ACTIVATE MSDIALOG oDlgEscTela CENTERED
EndIf
Return( lRet )
//-------------------------------------------------------------------
/*/{Protheus.doc} TxRetSta()

Retorno da consulta especifica

@author Rebeca Facchinato Asunção
@since 25/08/2017
@version P12.1.17
@return Nil
/*/
//------------------------------------------------------------------
Function TxRetSta()

Return cRetSta


//-------------------------------------------------------------------
/*/{Protheus.doc} AtPosSX5()

Posiciona em uma SX5 de status da base de atendimento

/*/
//------------------------------------------------------------------
Function AtPosSX5(cChave)

SX5->( dbSetOrder( 1 ) )
SX5->( dbSeek( xFilial('SX5') + 'A5'+ cChave ) )

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TxVldAtend()

Função para validar se o atendente pode ser selecionado no campo TGY_ATEND

@return lRet, Logico - Permite que o atendente seja selecionado
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TxVldAtend(cCodTec,dDtIni,dDtFim,cLocalAloc,lNoMdl,cHrIni,cHrFim, cIdcFal, cFilABB, dDtRef)
Local oModel 			:= Nil 
Local oMdlTFF			:= Nil 
Local lRH 				:= SuperGetMv("MV_TECXRH",,.F.)
Local cAlias			:= GetNextAlias()
Local cSim				:= UPPER(STR0036)					//Indica o sim de acordo com o idioma corrente
Local cNao				:= UPPER(STR0037)					//Indica o não de acordo com o idioma corrente
Local cFer				:= 'FER'							//Indica o não de acordo com o idioma corrente
Local cWhereDisp		:= ''								//Condição de filtro para os atendentes disponíveis
Local cWhereIndisp		:= ''								//Condição de filtro para os atendentes indisponíveis
Local cWhereABB			:= ''								//Condição para filtrar apenas agendamentos para um determinado Item da OS
Local cWhereTCU         := ''
Local cCCVazio			:= Space( TamSX3('AA1_CC')[1] )		//Cria campo de Centro de Custo vazio
Local nX				:= 0
Local nPosTW2        	:= 0
Local aTW2Restri   		:= {}
Local dFimPE  			:= Ctod("")
Local cWhereTrns 		:= ""
Local cJoinSPF 			:= ""
Local dIniAloc 			:= ''								//Por padrão filtra recursos agendados apenas para a data atual.
Local lRet				:= .T.
Local aPeriodos			:= {}
Local cDisponib			:= 'T'								//Por padrão lista todos os recursos (Disponíveis e Indisponíveis).
Local lDemis			:= .F.
Local lFerias			:= .F.
Local lAfast			:= .F.
Local lConfl			:= .F.
Local lAdmis			:= .F.
Local aCnflt			:= {}
Local lMsgHlp			:= !IsBlind()
Local lNoAfast			:= .T.
Local lTabTXB			:= TableInDic("TXB") //Restrições de RH
Local lRestrRH			:= .F. 
Local lGSVERHR 			:= SuperGetMV("MV_GSVERHR",,.F.)
Local lSubs550			:= isInCallStack("At550VaSub")
Local nTXBDtIni 		:= 0
Local nTXBDtFim 		:= 0

Default cCodTec 	:= ""
Default dDtIni  	:= sTod("")
Default dDtFim  	:= sTod("")
Default cLocalAloc  := ""
Default lNoMdl		:= .F.
Default cHrIni		:= ""
Default cHrFim		:= ""
Default cIdcFal		:= ""
Default cFilABB		:= xFilial("ABB")
Default dDtRef		:= StoD("")

//so realiza a validação para o campo habilitado
If At680Perm( Nil, __cUserID, "037" )

	dFimPE := dIniAloc	

	If !lNoMdl
		oModel := FwModelActive()
		oMdlTFF:= oModel:GetModel("TFFMASTER")

		If Empty(dDtIni)
			dDtIni := oMdlTFF:GetValue("TFF_PERINI")
		EndIf	
		
		If Empty(dDtFim)
			dDtFim := oMdlTFF:GetValue("TFF_PERFIM") 
		EndIf	
	
		If Empty(cLocalAloc)
			cLocalAloc := oMdlTFF:GetValue("TFF_LOCAL")
		Endif
		
		If oModel:GetId() == "TECA580E" 
			lNoAfast := .F.
		EndIf
	Endif

	aAdd(aPeriodos,{dDtIni,cHrIni,dDtFim,cHrFim})

	aTW2Restri:=TxRestri(cLocalAloc)

	//------------------------------------------------------------------
	// Filtra atendentes disponíveis pela agenda e RH
	//------------------------------------------------------------------
	cWhereDisp := "ABB_CODTEC IS NULL "		//Filtra apenas atendentes sem agenda

	//------------------------------------------------------------------
	// Filtra atendentes indisponíveis no RH
	//------------------------------------------------------------------

	cWhereIndisp := "(  ABB.ALOCADO = '" + cSim + "' ) "		//Filtra as situações de folha Afastado, Férias e Transferido

	If ( !lRH )
		cWhereTrns := ""
	EndIf

	cJoinSPF := " LEFT JOIN "+RetSQLName('SPF')+" SPF ON PF_FILIAL = '"+xFilial("SPF")+"' "
	cJoinSPF += " AND SPF.PF_MAT = AA1_CDFUNC "
	cJoinSPF += " AND SPF.D_E_L_E_T_ = ' '
	cJoinSPF += cWhereTrns
	cJoinSPF += "	AND SPF.PF_DATA = (SELECT MAX(X.PF_DATA) AS DATA  FROM " + RetSQLName('SPF') + ;
	" X WHERE X.PF_FILIAL = SPF.PF_FILIAL "+;
	"AND X.PF_MAT = SPF.PF_MAT  "+;
	"AND X.D_E_L_E_T_ = ' ')  "


	//------------------------------------------------------------------
	// Filtro por Data do agendamento da alocação
	//------------------------------------------------------------------

	cWhereABB += GetSqlPeri(aPeriodos)
	cWhereTCU += GetSqlPeri(aPeriodos, isInCallStack("AT190dIMn2"))

	//------------------------------------------------------------------
	// Filtra apenas agendamentos ativos e que nao foi atendido.
	//------------------------------------------------------------------
	cWhereABB	+= " AND ABB.ABB_ATIVO <> '2'"
	cWhereTCU	+= " AND ABB.ABB_ATIVO <> '2'"

	cWhereDisp 	+= " AND '" + cDisponib + "' IN ('T','D') "		//Se for "A" ou "I", ignora a consulta de disponíveis
	cWhereIndisp 	+= " AND '" + cDisponib + "' IN ('T','A','I') "	//Se for "A" ou "I", ignora a consulta de disponíveis


	cWhereDisp		:= '%' + cWhereDisp + '%'
	cWhereIndisp	:= '%' + cWhereIndisp + '%'
	cWhereABB		:= '%' + cWhereABB + '%'
	cWhereTCU		:= '%' + cWhereTCU + '%'

	cJoinSPF :=  '%' + cJoinSPF + '%'

	//-------------------------------------------------------------------------------------
	// Query de consulta de recursos
	//-------------------------------------------------------------------------------------
	BeginSql alias cAlias

		//-----------------------------------------------------------
		// Seleciona os Atendentes disponíveis para alocação
		//-----------------------------------------------------------
		SELECT DISTINCT TMP_LEGEN, TMP_FILIAL, TMP_CODTEC, TMP_NOMTEC, TMP_CDFUNC, TMP_TURNO, TMP_FUNCAO,
		TMP_CARGO, TMP_DISP, TMP_DISPRH, TMP_ALOC, TMP_SITFOL, TMP_DESC, TMP_RESTEC, TMP_PTURNO, TMP_OK, TMP_ALOCA
		FROM (
		SELECT '               '	AS TMP_LEGEN,
		AA1_FILIAL 		AS TMP_FILIAL,
		AA1_CODTEC 		AS TMP_CODTEC,
		AA1_NOMTEC 		AS TMP_NOMTEC,
		AA1_CDFUNC 		AS TMP_CDFUNC,
		AA1_ALOCA 		AS TMP_ALOCA,
		CASE WHEN RA_TNOTRAB IS NULL
		THEN AA1_TURNO
		ELSE RA_TNOTRAB
	END  				AS TMP_TURNO,
	CASE WHEN RA_CODFUNC IS NULL
	THEN AA1_FUNCAO
	ELSE RA_CODFUNC
	END  				AS TMP_FUNCAO,
	RA_CARGO			AS TMP_CARGO,
	%Exp:cSim% 		AS TMP_DISP,
	%Exp:cSim% 		AS TMP_DISPRH,
	%Exp:cNao% 		AS TMP_ALOC,
	CASE WHEN RA_SITFOLH IS NULL THEN ' '
	ELSE RA_SITFOLH
	END 				AS TMP_SITFOL,
	CASE WHEN X5_DESCRI IS NULL THEN ' '
	ELSE X5_DESCRI
	END 				AS TMP_DESC,
	TCU_RESTEC    AS TMP_RESTEC,
	SPF.PF_TURNOPA AS TMP_PTURNO,
	'  ' AS TMP_OK
	FROM %Table:AA1% AA1
	//Contratos de Manutenção
	LEFT JOIN %Table:AAH% AAH
	ON %xFilial:AAH% = AAH.AAH_FILIAL
	AND AA1.AA1_CC = AAH.AAH_CCUSTO
	AND AA1.AA1_CC <> %Exp:cCCVazio%
	AND AAH.%NotDel%
	//Agenda de Atendimentos
	%Exp:cJoinSPF%
	LEFT JOIN (   SELECT ABB_FILIAL, ABB_CODTEC, TCU_RESTEC
	FROM %Table:ABB% ABB, %Table:TCU% TCU
	WHERE ABB.%NotDel% AND
	TCU.%NotDel% AND TCU_FILIAL = %xFilial:TCU% AND
	(TCU_COD = ABB_TIPOMV OR ABB_TIPOMV='')
	%Exp:cWhereTCU%
	) ABB
	ON %xFilial:ABB% = ABB.ABB_FILIAL
	AND AA1.AA1_CODTEC = ABB.ABB_CODTEC
	//Funcionários
	LEFT JOIN %Table:SRA% SRA
	ON AA1.AA1_FUNFIL = SRA.RA_FILIAL
	AND AA1.AA1_CDFUNC = SRA.RA_MAT
	AND SRA.%NotDel%
	//Programação de Férias
	LEFT JOIN %Table:SRF% SRF
	ON SRA.RA_MAT = SRF.RF_MAT
	AND SRA.RA_FILIAL = SRF.RF_FILIAL
	AND SRF.%NotDel%

	//Tabelas genéricas
	LEFT JOIN %Table:SX5% SX5
	ON SX5.X5_TABELA = '31'	//31 - Tabela de Situações da Folha
	AND SX5.X5_CHAVE = SRA.RA_SITFOLH
	AND SX5.%NotDel%
	//Região de atendimento
	LEFT JOIN ( SELECT DISTINCT
	ABU_FILIAL,
	ABU_CODTEC
	FROM %Table:ABU% ABU
	WHERE ABU.%NotDel% ) ABU
	ON ABU.ABU_FILIAL = %xFilial:ABU%
	AND AA1.AA1_CODTEC = ABU.ABU_CODTEC

	WHERE %Exp:cWhereDisp%
	AND AA1.%NotDel%
	AND AA1.AA1_CODTEC =  %Exp:cCodTec%

	UNION ALL

	//-----------------------------------------------------------
	//Seleciona os Atendentes indisponíveis para alocação
	//-----------------------------------------------------------
	SELECT '               '	AS TMP_LEGEN,
	AA1_FILIAL 		AS TMP_FILIAL,
	AA1_CODTEC 		AS TMP_CODTEC,
	AA1_NOMTEC 		AS TMP_NOMTEC,
	AA1_CDFUNC 		AS TMP_CDFUNC,
	AA1_ALOCA 		AS TMP_ALOCA,	     
	CASE WHEN RA_TNOTRAB IS NULL
	THEN AA1_TURNO
	ELSE RA_TNOTRAB
	END  			AS TMP_TURNO,
	CASE WHEN RA_CODFUNC IS NULL
	THEN AA1_FUNCAO
	ELSE RA_CODFUNC
	END  			AS TMP_FUNCAO,
	RA_CARGO			AS TMP_CARGO,
	%Exp:cNao% 		AS TMP_DISP,
	%Exp:cSim% 		AS TMP_DISPRH,
	CASE WHEN ABB.ALOCADO IS NULL THEN %Exp:cNao%
	ELSE ABB.ALOCADO
	END 				AS TMP_ALOC,
	CASE WHEN RA_SITFOLH IS NULL THEN ' '
	ELSE RA_SITFOLH
	END			       AS TMP_SITFOL,
	CASE WHEN X5_DESCRI IS NULL THEN ' '
	ELSE X5_DESCRI
	END 				AS TMP_DESC,
	TCU_RESTEC AS TMP_RESTEC,
	SPF.PF_TURNOPA AS TMP_PTURNO,
	'  ' 				AS TMP_OK

	FROM %Table:AA1% AA1
	//Contratos de Manutenção
	LEFT JOIN %Table:AAH% AAH
	ON %xFilial:AAH% = AAH.AAH_FILIAL
	AND AA1.AA1_CC = AAH.AAH_CCUSTO
	AND AA1.AA1_CC <> %Exp:cCCVazio%
	AND AAH.%NotDel%
	//Agenda de Atendimentos
	%Exp:cJoinSPF%
	LEFT JOIN ( SELECT ABB_FILIAL, ABB_CODTEC, TCU_RESTEC, %Exp:cSim% AS ALOCADO
	FROM %Table:ABB% ABB, %Table:TCU% TCU
	WHERE ABB.%NotDel% %Exp:cWhereTCU% AND
	TCU.%NotDel% AND TCU_FILIAL = %xFilial:TCU% AND
	(TCU_COD = ABB_TIPOMV OR ABB_TIPOMV='') ) ABB
	ON %xFilial:ABB% = ABB.ABB_FILIAL
	AND AA1.AA1_CODTEC = ABB.ABB_CODTEC
	//Funcionários
	LEFT JOIN %Table:SRA% SRA
	ON AA1.AA1_FUNFIL = SRA.RA_FILIAL
	AND AA1.AA1_CDFUNC = SRA.RA_MAT
	//Programação de Férias
	LEFT JOIN %Table:SRF% SRF
	ON SRA.RA_MAT = SRF.RF_MAT
	AND SRA.RA_FILIAL = SRF.RF_FILIAL

	//Tabelas genéricas
	LEFT JOIN %Table:SX5% SX5
	ON SX5.X5_TABELA = '31'	//31 - Tabela de Situações da Folha
	AND SX5.X5_CHAVE = SRA.RA_SITFOLH

	//Região de atendimento
	LEFT JOIN ( SELECT DISTINCT
	ABU_FILIAL,
	ABU_CODTEC
	FROM %Table:ABU% ABU
	WHERE ABU.%NotDel% ) ABU
	ON ABU.ABU_FILIAL = %xFilial:ABU%
	AND AA1.AA1_CODTEC = ABU.ABU_CODTEC

	WHERE %Exp:cWhereIndisp%
	AND AA1.%NotDel%
	AND AA1.AA1_CODTEC =  %Exp:cCodTec%
	) TAB_QRY

	EndSql

	While (cAlias)->(!EOF())

		If (cAlias)->TMP_ALOCA == "2"
			lRet := .F.
			If lMsgHlp
				Help(,,STR0074,,STR0075,1,0) // "Atendente não esta disponível para alocação." ## "Realize manutenção no cadastro de Atendentes no campo AA1_ALOCA."
			Endif
		Endif

		If lRet 
			AT330ArsSt(,.T.)
			aCnflt 	:= ChkCfltAlc(dDtIni, dDtFim, (cAlias)->TMP_CODTEC, cHrIni,cHrFim, , , , , , , , , , ,  cFilABB, dDtRef, cIdcFal)
	
			//Integração com RH
			If lRH
				lDemis	:= aCnflt[1] //Conflito de demissão
				lAfast	:= aCnflt[2] //Conflito de Afastamento
				lFerias	:= aCnflt[3] //Conflito de ferias
				lAdmis	:= aCnflt[6] //Conflito de Admissão
			EndIf
			
			If (cAlias)->TMP_RESTEC <> "1" //Quando for reserva não verifica o conflito de alocação.
				lConfl	:= aCnflt[4] //Conflito de agenda.	
			Endif
			
			If lTabTXB
				nPosTXBDtI:= AScan(AT330ArsSt("aCfltHead"),{|e| e == 'TXB_DTINI'})
				nPosTXBDtF:= AScan(AT330ArsSt("aCfltHead"),{|e| e == 'TXB_DTFIM'})

				lRestrRH := aCnflt[5] //Conflito de RH (TXB)

				If !lRestrRH .And. Len(AT330ArsSt("ACFLTATND")) > 0  .And. nPosTXBDtI > 0 .And. nPosTXBDtF > 0
					If lSubs550 .AND. !Empty(cIdcFal)
						lRestrRH := (Ascan(AT330ArsSt("ACFLTATND"),{|x| !Empty(x[nPosTXBDtI]) .And. dDtRef >= sTod(x[nPosTXBDtI]) .And. ( Empty(x[nPosTXBDtF]) .Or. dDtRef <= sTod(x[nPosTXBDtF])) } ) > 0)
					Else
						lRestrRH := (Ascan(AT330ArsSt("ACFLTATND"),{|x| !Empty(x[nPosTXBDtI]) .And. dDtIni >= sTod(x[nPosTXBDtI]) .And. ( Empty(x[nPosTXBDtF]) .Or. dDtIni <= sTod(x[nPosTXBDtF])) } ) > 0)
					EndIf
				Endif
			Endif			
		Endif
		
		If lRet .And. (UPPER((cAlias)->TMP_DISPRH) == UPPER(cFer)) //Ferias Programadas
			lRet := IsBlind() .Or. MsgYesNo(STR0093)//"Atendente com Ferias Programadas, Deseja Continuar com a alocação?"
		Endif

		If lRet .And. isInCallStack("AT190dIMn2") .OR. isInCallStack("SubstLote") .OR. isInCallStack("at190dV550")
			//Permissão para incluir agenda do substituto com restrições de RH
			If At680Perm( Nil, __cUserID,"017")
				If lDemis
					If lMsgHlp
						If !lVldMsgAloc
							lRet := MsgYesNo(STR0123) //"Atendente demítido, deseja continuar com a alocação no período de demissão?"
							lRetVldSub := lRet
						Endif
						lVldMsgAloc := .T.
						lRet := lRetVldSub
						If !lRet
							Help(,,STR0091,,STR0126,1,0) //"Atendente demitido."
						Endif
					Else
						lRet := .F.
					Endif
				ElseIf lAdmis
					If lMsgHlp
						If !lVldMsgAloc
							lRet := MsgYesNo(STR0133) //"Atendente admitido depois da data de alocação, deseja continuar?"
							lRetVldSub := lRet
						Endif
						lVldMsgAloc := .T.
						lRet := lRetVldSub
						If !lRet
							Help(,,STR0091,,STR0134,1,0) // "Aloca Atendente" ## "Atendente com admissão posterior a data de alocação."
						Endif
					Else
						lRet := .F.
					Endif
				Elseif lRet .And. lAfast
					If lMsgHlp
						If !lVldMsgAloc
							lRet := MsgYesNo(STR0124) //"Atendente afastado, deseja continuar com a alocação no período de afastamento?"
							lRetVldSub := lRet
						Endif
						lVldMsgAloc := .T.
						lRet := lRetVldSub
						If !lRet
							Help(,,STR0091,,STR0127,1,0) //"Atendente afastado."
						Endif
					Else
						lRet := .F.
					Endif
				Elseif lRet .And. lFerias
					If lMsgHlp
						If !lVldMsgAloc
							lRet := MsgYesNo(STR0125) //"Atendente de férias, deseja continuar com a alocação no período de férias?"
							lRetVldSub := lRet
						Endif
						lVldMsgAloc := .T.
						lRet := lRetVldSub
						If !lRet
							Help(,,STR0091,,STR0128,1,0) //"Atendente de férias."
						Endif
					Else
						lRet := .F.
					Endif
				Elseif lRet .And. lRestrRh
					If lMsgHlp
						If !lVldMsgAloc
							lRet := MsgYesNo(STR0129) //"Atendente com restrição de RH, deseja continuar com a alocação no período de restrição?"
							lRetVldSub := lRet
						Endif
						lVldMsgAloc := .T.
						lRet := lRetVldSub
						If !lRet
							Help(,,STR0091,,STR0130,1,0) //"Atendente com restrição de RH."
						Endif
					Else
						lRet := .F.
					Endif					
				Endif
			Else
				If lDemis
					If lMsgHlp 
						Help(,,STR0091,,STR0126,1,0) //"Atendente demitido."
					EndIf
					lRet := .F.
				ElseIf lAdmis
					If lMsgHlp 
						Help(,,STR0091,,STR0134,1,0) // "Aloca Atendente" ## "Atendente com admissão posterior a data de alocação."
					EndIf
					lRet := .F.
				Elseif lRet .And. lAfast 
					If lMsgHlp
						Help(,,STR0091,,STR0127,1,0) //"Atendente afastado."
					EndIf						
					lRet := .F.
				Elseif lRet .And. lFerias 
					If lMsgHlp
						Help(,,STR0091,,STR0128,1,0) //"Atendente de férias."
					EndIf						
					lRet := .F.
				Elseif lRet .And. lRestrRh
					If lMsgHlp
						Help(,,STR0091,,STR0130,1,0) //"Atendente com restrição de RH."
					EndIf						
					lRet := .F.
				Endif
			Endif
		Endif

		If lRet .And. ( UPPER((cAlias)->TMP_DISP) == UPPER(cSim) ) .And. ( UPPER((cAlias)->TMP_ALOC) == UPPER(cNao) )

			//Verificar se tem restrição operacional no periodo de alocação
			nPosTw2:= aScan( aTW2Restri,{|x| x[1] == (cAlias)->TMP_CODTEC .And. ((sTod(x[6]) >= dDtIni .And. sTod(x[6]) <= dDtFim ) .Or. ;
													  	 						( sTod(x[7]) >= dDtIni .And. sTod(x[7]) <= dDtFim ))})

			If 	nPosTW2 > 0
				If aTW2Restri[nPosTW2][8] == '1' //Aviso de restrição local/cliente
					If lMsgHlp
						Help(,,STR0091,,STR0094,1,0)
					EndIf	
				Elseif aTW2Restri[nPosTW2][8] == '2' //Bloqueio de restrição local/cliente
					lRet := .F.
					If lMsgHlp
						Help(,,STR0091,,STR0095,1,0)
					EndIf	
				Endif
			Endif
		Endif

		//Recurso indisponível (Alocado)
		If lRet .And. (((( UPPER((cAlias)->TMP_DISP) == UPPER(cNao) ) .And. ( UPPER((cAlias)->TMP_ALOC) == UPPER(cSim) ) .And.;
		 																   ( (cAlias)->TMP_RESTEC <> "1" ) ) .Or. lConfl) .AND. lNoAfast) .OR. (!lNoAfast .AND. lConfl)
			lRet := .F.
			If lMsgHlp
				Help(,,STR0091,,STR0096,1,0)//"Atendente já alocado"
			EndIf	
		Endif

		If  lRet .And. (UPPER((cAlias)->TMP_DISPRH) == UPPER(cNao)) 
			//Recurso indisponível (RH)
			lRet := .F.
			If lMsgHlp
				Help(,,STR0091,,STR0092,1,0)//"Atendente com restrição de RH"
			EndIf	
		EndIf

		(cAlias)->(Dbskip())
	EndDo

	(cAlias)->(DbCloseArea())

EndIf

Return lRet

/*/{Protheus.doc} TecDifHr
Calculo de total de horas, passando horas em formato numérico, utilizando separador decimal.
@since 08/07/2018
@author diego.bezerra
@version 1.0
@param nEntrada, decimal, horário de entrada
@param nSaida, decimal, horário de saída
@return nTotalH, Total de horas em formato numérico

/*/
Function TecDifHr ( nEntrada, nSaida )

Local 	nAuxEnt		:= 0
Local	nAuxSai		:= 0
Local 	nTotalH		:= 0
Default nEntrada 	:= 0
Default nSaida 		:= 0

//Trata horario final no proximo dia
If nEntrada > nSaida
	nTotalH := (24 - nEntrada) + nSaida
Else
	nTotalH := nSaida - nEntrada
EndIf

If nTotalH > 0 
	If nSaida < 10
		If len( cValToChar( nSaida ) ) == 1
			nAuxSai 	:= 0
		ElseIf len( cValtoChar ( nSaida ) ) == 3
			nAuxSai 	:= VAL( right( cValtoChar( nSaida ),1) )
		Else	
			nAuxSai 	:= VAL( right( cValtoChar( nSaida ),2) )
		EndIf
	Else
		If len( cValToChar( nSaida ) ) == 2 
			nAuxSai 	:= 0
		ElseIf len( cValtoChar ( nSaida ) ) == 4
			nAuxSai 	:= VAL( right( cValtoChar( nSaida ),1) )
		Else	
			nAuxSai 	:= VAL( right( cValtoChar( nSaida ),2) )
		EndIf	
	EndIf
	
	If nEntrada < 10
		If len( cValToChar( nEntrada ) ) == 1 
			nAuxEnt		:= 0
		ElseIf len( cValtoChar ( nEntrada ) ) == 3
			nAuxEnt		:=	VAL( right( cValtoChar( nEntrada ),1) )
		Else	
			nAuxEnt		:=	VAL( right( cValtoChar( nEntrada ),2) )
		EndIf
	Else
		If len( cValToChar( nEntrada ) ) == 2
			nAuxEnt		:= 0
		ElseIf len( cValtoChar ( nEntrada ) ) == 4
			nAuxEnt 	:=	VAL( right( cValtoChar( nEntrada ),1) )
		Else	
			nAuxEnt 	:=	VAL( right( cValtoChar( nEntrada ),2) )
		EndIf	
	EndIf
	
	If nAuxSai < nAuxEnt
		nTotalH := nTotalH - 0.4
	EndIf
EndIf

Return nTotalH

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} T180WhenMdtGS
Caso exista o parâmetro (MV_NG2GS) de integração (SIGAMDT x SIGATEC) durante a inclusão na tabela (TN0-Risco) 
os campos TN0_CC (Centro Custo), TN0_CODFUN (Função) e TN0_DEPTO (Departamento) serão preenchidos automaticamente com “*”.
@param  cField, Caracter, Campo posicionado durante a validção
@return lRetorno, Lógico, Verdadeiro/Falso
@author Eduardo Gomes Júnior
@since 09/01/2018
/*/
//------------------------------------------------------------------------------------------
Function T180WhenMdtGS(cField)

Local lRetorno		:= .T.
Local lSigaMdtGS	:= SuperGetMv("MV_NG2GS",.F.,.F.)	//Parâmetro de integração entre o SIGAMDT x SIGATEC

If	cField == "TN0_CC"
	
	If	lSigaMdtGS
	
		M->TN0_CC := "*"
		RunTrigger( 1,,,, "TN0_CC" )
		lRetorno := .F.
		
	Else 
	
		lRetorno := A180DESTIN() .And. (Type('lTrava902')=='L' .AND. lTrava902)
	
	Endif 		
			
ElseIf	cField == "TN0_CODFUN"

	If	lSigaMdtGS

		M->TN0_CODFUN := "*"
		RunTrigger( 1,,,, "TN0_CODFUN" )
		lRetorno := .F.
		
	Else
	
		lRetorno := DTVALIDA .And. (Type('lTrava902') == 'L' .AND. lTrava902)
	
	Endif 		
			
ElseIf	cField == "TN0_DEPTO"

	If	lSigaMdtGS

		M->TN0_DEPTO := "*"
		RunTrigger( 1,,,, "TN0_DEPTO" )
		lRetorno := .F.
		
	Else
	
		lRetorno := DTVALIDA .And. (Type('lTrava902') == 'L' .AND. lTrava902) 
					  	
	Endif 		

Endif 

Return(lRetorno) 


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} T180ValidMdtGS
Caso exista o parâmetro (MV_NG2GS) de integração (SIGAMDT x SIGATEC) durante a inclusão na 
tabela (TN0-Risco) o campo TN0_CODTAR não poderá ser preenchido com "*" 
Validação adicionada no VALID do campo mencionado acima.
@param  cField, Caracter, Campo posicionado durante a validção
@return lRetorno, Lógico, Verdadeiro/Falso
@author Eduardo Gomes Júnior
@since 09/01/2018
/*/
//------------------------------------------------------------------------------------------	
Function T180ValidMdtGS(cField)

Local lRetorno		:= .T.
Local lSigaMdtGS	:= SuperGetMv("MV_NG2GS",.F.,.F.)	//Parâmetro de integração entre o SIGAMDT x SIGATEC

If	lSigaMdtGS .AND. Alltrim(M->TN0_CODTAR) == "*"
	HELP(' ',1,'T180ValidMdtGS',,"Tarefa não pode ser preenchida com (*).",5,1)	//"Tarefa não pode ser preenchida com (*)."
	lRetorno := .F.
Endif 

Return(lRetorno)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetIdcFAL
Função para retornar o IDCFAL de uma agenda 
@author		boiani
@since		15/06/2019
@version	P12
/*/
//-------------------------------------------------------------------------------------------
Function GetIdcFAL(cCodABB)
Local cRet := ""
Local aArea := GetArea()
Local aAreaABB := ABB->(GetArea())

cRet := Posicione("ABB",8,xFilial("ABB") + cCodABB, "ABB_IDCFAL")

RestArea(aAreaABB)
RestArea(aArea)
Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TxRestriRH(cCodTec,dDtIni,dDtFim)
Função que retorna a restrição de RH do Atendente - TXB

@sample	TxRestriRH(cCodTec,dDtIni,dDtFim)

@param	cCodTec Codigo do atendente
@param	dDtIni 	Data inicio do atendimento
@param	dDtFim 	Data final do atendimento

@return	lRestrRH	 .T. = Existe restrição no período

@author	services
@since		09/08/2019
/*/
//------------------------------------------------------------------------------
Function TxRestriRH(cCodTec,dDtIni,dDtFim)
Local lRestrRH 	 := .T.
Local cTmpResTri := ""

cTmpResTri:= GetNextAlias()

BeginSql Alias cTmpResTri

	COLUMN TXB_DTINI AS DATE
	COLUMN TXB_DTFIM AS DATE	

	SELECT 1
	FROM %table:TXB% TXB
	WHERE TXB.TXB_FILIAL   = %xFilial:TXB%
		AND TXB.TXB_CODTEC = %Exp:cCodTec%
		AND (TXB.TXB_DTINI BETWEEN %Exp:dDtIni% AND %Exp:dDtFim% 
		OR   TXB.TXB_DTFIM BETWEEN %Exp:dDtIni% AND %Exp:dDtFim%)
		AND TXB.%NotDel%
EndSql

lRestrRH := (cTmpResTri)->(!EOF())

(cTmpResTri)->(DbCloseArea())

Return lRestrRH

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TxConfTCU
@description  Retorna as configurações do tipo de alocação

@param cTpAloc - Caracter - Codigo do tipo de Alocação(TCU_COD)
@param aCampos - Array - Campos da TCU a serem pesquisados e retornados
@param cFilTCU - Caracter - Filial da TCU a ser pesquisado 

@return aConf, Array - Array[1][1] - Campo da TCU
                       Array[1][2] - Valor do campo	

@author Luiz Gabriel
@since  22/08/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TxConfTCU(cCodTCU,aCampos,cFilTCU)
Local aAreaTCU 	:= TCU->(GetArea())
Local aConf		:= {}
Local cCampo	:= ""
Local nI		:= 0

Default cFilTCU := ""

If Empty(cFilTCU)
	cFilTCU := xFilial("TCU")
EndIf

DbSelectArea("TCU")
TCU->(DbSetOrder(1))
If TCU->(MsSeek(cFilTCU+cCodTCU))
	For nI := 1 To Len(aCampos)
		cCampo := aCampos[nI]
		AAdd(aConf,{aCampos[nI],TCU->&cCampo})
	Next nI
EndIf

RestArea(aAreaTCU)

Return aConf
//------------------------------------------------------------------------------
/*/{Protheus.doc} TxRestrTW2(cLocalAloc,cCodAtend,dDtIni,dDtFim)
Função que retorna as restrições de atendente no Cliente e Local de Atendimento.

@sample	TxRestri(cLocAloc)

@param	cCodAtend 	Codigo do Atendente
@param	dDtIni 		Data Ínicio
@param	dDtFim 		Data Fim
@param	cLocalAloc 	Local de Atendimento

@return	aRestri	 Array Restrições.

@author	Serviços
@since	28/08/2019
/*/
//------------------------------------------------------------------------------
Function TxRestrTW2(cCodAtend,dDtIni,dDtFim,cLocalAloc)

Local aRestri		:={}
Local cTmpResLoc 	:= ""
Local cTmpResCli 	:= ""

Default cCodAtend 	:= ""
Default dDtIni	  	:= sTod("")
Default dDtFim	  	:= sTod("")
Default cLocalAloc	:= ""

//Query com as restricoes do local de atendimento
If !Empty(cCodAtend) .And. !Empty(dDtIni) .And. !Empty(cLocalAloc)

	cTmpResLoc:= GetNextAlias()

	BeginSql Alias cTmpResLoc

		COLUMN TW2_DTINI AS DATE
		COLUMN TW2_DTFIM AS DATE

		SELECT TW2.TW2_CODTEC, 
			   TW2.TW2_DTINI, 
			   TW2.TW2_DTFIM, 
			   TW2.TW2_RESTRI,
			   TW2.TW2_TIPO
		FROM %table:TW2% TW2
		WHERE TW2_FILIAL 	= %xFilial:TW2%
			AND TW2.TW2_LOCAL 	= %Exp:cLocalAloc%
			AND TW2.TW2_CODTEC	= %Exp:cCodAtend%
			AND (TW2.TW2_DTINI BETWEEN %Exp:dDtIni% AND %Exp:dDtFim% 
				OR TW2.TW2_DTFIM BETWEEN %Exp:dDtIni% AND %Exp:dDtFim%)
			AND TW2.%NotDel%

	EndSql

	DbSelectArea(cTmpResLoc)
	(cTmpResLoc)->(DbGoTop())

	//Preenche o array 
	While (cTmpResLoc)->(! Eof())

		AADD(aRestri,{(cTmpResLoc)->TW2_CODTEC	,;
					  (cTmpResLoc)->TW2_DTINI	,;
					  (cTmpResLoc)->TW2_DTFIM	,;
					  (cTmpResLoc)->TW2_RESTRI	,;
					  (cTmpResLoc)->TW2_TIPO})

		(cTmpResLoc)->(DbSkip())

	EndDo

	//Cliente do local de atendimento
	cCliente:= Posicione("ABS",1,xFilial("ABS")+cLocalAloc,"ABS_CODIGO")
	cLojaCli:= Posicione("ABS",1,xFilial("ABS")+cLocalAloc,"ABS_LOJA")

	cTmpResCli:= GetNextAlias()

	//Query com as restrição no cliente
	BeginSql Alias cTmpResCli
		
		COLUMN TW2_DTINI AS DATE
		COLUMN TW2_DTFIM AS DATE
		
		SELECT TW2.TW2_CODTEC, 
			   TW2.TW2_DTINI, 
			   TW2.TW2_DTFIM, 
			   TW2.TW2_RESTRI,
			   TW2.TW2_TIPO
		FROM %table:TW2% TW2
		WHERE TW2_FILIAL 		= %xFilial:TW2%
			AND TW2.TW2_CODTEC	= %Exp:cCodAtend%
			AND TW2_CLIENT 		= %Exp:cCliente%
			AND TW2_LOJA 		= %Exp:cLojaCli%
			AND (TW2.TW2_DTINI BETWEEN %Exp:dDtIni% AND %Exp:dDtFim% 
				OR TW2.TW2_DTFIM BETWEEN %Exp:dDtIni% AND %Exp:dDtFim%)
			AND TW2.%NotDel%

	EndSql

	DbSelectArea(cTmpResCli)
	(cTmpResCli)->(DbGoTop())

	//Preenche o array
	While (cTmpResCli)->(! Eof())

		AADD(aRestri,{(cTmpResCli)->TW2_CODTEC	,;
				  	  (cTmpResCli)->TW2_DTINI	,;
				  	  (cTmpResCli)->TW2_DTFIM	,;
				  	  (cTmpResCli)->TW2_RESTRI	,;
				  	  (cTmpResCli)->TW2_TIPO})

		(cTmpResCli)->(DbSkip())

	EndDo

	//Fecha a area das tabelas
	(cTmpResCli)->(DbCloseArea())
	(cTmpResLoc)->(DbCloseArea())

EndIf

Return aRestri

//------------------------------------------------------------------------------
/*/{Protheus.doc} TxExitCon (cAtend,dDtIni,dDtFim)
Função que verifica se o atendente possui convoção, no caso de ser intermitente.

@sample	TxExitCon(cAtend,dDtIni,dDtFim)

@param	cAtend 	Codigo do Atendente
@param	dDtIni 		Data Ínicio
@param	dDtFim 		Data Fim

@return	lRet - O atendente não é intermitente ou possui convovação para o período

@author	Serviços
@since	06/09/2019
/*/
//------------------------------------------------------------------------------
Function TxExitCon(cAtend,dDtIni,dDtFim)
Local lRet := .T.
Local lTabSV7 := TableInDic("SV7")
Local lIntRH := SuperGetMV("MV_GSXINT",.f.,"2") == "2"
Local cAlias := GetNextAlias()
Local dDtIniQry := CtoD("")
Local dDtFimQry := CtoD("")

Default cAtend := ""
Default dDtIni := CtoD("")
Default dDtFim := CtoD("")

If lTabSV7 .AND. !Empty(cAtend) .AND. !Empty(dDtIni) .AND. !Empty(dDtFim) .AND. lIntRH
	BeginSQl Alias cAlias
		Select 
			AA1.AA1_CODTEC,
			SV7.V7_DTINI,
			SV7.V7_DTFIM
		From 
			%Table:AA1% AA1,
			%Table:SRA% SRA
			LEFT JOIN %Table:SV7% SV7 ON (		(SV7.V7_DTINI  <= %Exp:dDtIni% AND SV7.V7_DTFIM >= %Exp:dDtFim%) AND
												SV7.V7_MAT    = SRA.RA_MAT     AND
												SV7.V7_FILIAL = SRA.RA_FILIAL  AND 
												SV7.%NotDel%)	
		Where
			SRA.RA_TPCONTR = '3' AND
			SRA.RA_MAT = AA1.AA1_CDFUNC AND
			SRA.RA_FILIAL = AA1.AA1_FUNFIL AND 
			SRA.%NotDel% AND		
			AA1.AA1_CODTEC = %Exp:cAtend% AND
			AA1.AA1_FILIAL = %xFilial:AA1% AND 
			AA1.%NotDel%
	EndSQL
	
	If (cAlias)->(Eof())
		lRet := .T. 
	ElseIf 	!Empty((cAlias)->V7_DTINI)
		lRet := .T.
	Else
		//Verifica se existe convocações intercalas
		(cAlias)->(DbCloseArea())
		
		BeginSQl Alias cAlias
			Column V7_DTINI AS DATE
			Column V7_DTFIM AS Date
			Select 
				SV7.V7_DTINI,
				SV7.V7_DTFIM
			From 
				
				%Table:AA1% AA1
				INNER JOIN %Table:SV7% SV7 ON (	 (	(SV7.V7_DTINI  <= %Exp:dDtIni% AND SV7.V7_DTFIM >= %Exp:dDtIni%) OR (SV7.V7_DTINI  >= %Exp:dDtIni% AND SV7.V7_DTINI <= %Exp:dDtFim% ) ) AND
													 SV7.V7_DTINI <= %Exp:dDtFim% AND
													SV7.V7_MAT = AA1.AA1_CDFUNC AND
													SV7.V7_FILIAL = %xFilial:SV7%  AND 
													SV7.%NotDel%)	
			Where
				AA1.AA1_CODTEC = %Exp:cAtend% AND
				AA1.AA1_FILIAL = %xFilial:AA1% AND 
				AA1.%NotDel%
	
			Order By SV7.V7_DTINI,SV7.V7_DTFIM
		
		EndSQL	
		
		//Agrupa as convocações no período que iniciam no dia seguinte
		Do While !(cAlias)->(Eof())
			If Empty(dDtIniQry)
				dDtIniQry := (cAlias)->V7_DTINI
				dDtFimQry := (cAlias)->V7_DTFIM
			ElseIf  dDtFimQry+1 == (cAlias)->V7_DTINI
					dDtFimQry := (cAlias)->V7_DTFIM
			Else
				Exit
			EndIf
			(cAlias)->(DbSkip(1))
		EndDo
		lRet := dDtIniQry <= dDtIni .AND. dDtFimQry >= dDtFim
		
	EndIf
	(cAlias)->(DbCloseArea())
EndIf

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SendMailGS()
Função para envio de e-mail

@param cToEmail - Caracter - E-mail dos destinatarios
@param cMensagem - Caracter - Mensagem que será enviado no corpo do e-mail
@param cAssunto - Caracter - Mensagem que será colocado no assunto do e-mail
@param cFile - Caminho do arquivo para anexar ao e-mail
@param cMsg	- Caracter - Informa a msg do objeto tMailManager, passar parametro como referencia

@author 	Luiz Gabriel
@since		23/10/2019
@version 	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function SendMailGS(cToEmail,cMensagem,cAssunto,cFile,cMsg)
Local oServer 		:= TMailManager():New()
Local nErr 			:= 0
Local lRet			:= .T.  
Local lRelauth 		:= SuperGetMv("MV_RELAUTH")			// Parametro que indica se existe autenticacao no e-mail
Local nSMTPTime 	:= SuperGetMv("MV_RELTIME",.F.,60)	// TIMEOUT PARA A CONEXAO
Local lSSL 			:= SuperGetMv("MV_RELSSL",.F.,.F.)	// VERIFICA O USO DE SSL
Local lTLS 			:= SuperGetMv("MV_RELTLS",.F.,.F.)	// VERIFICA O USO DE TLS
Local nSMTPPort 	:= SuperGetMv("MV_PORSMTP",.F.,25)	// PORTA SMTP
Local cCtaAut   	:= SuperGetMV('MV_RELAUSR') 		// usuario para Autenticacao Ex.: fuladetal
Local cConta    	:= SuperGetMV('MV_RELACNT') 		// Conta Autenticacao Ex.: fuladetal@fulano.com.br
Local cSenha      	:= SuperGetMV('MV_RELAPSW') 		// Senha de acesso Ex.: 123abc
Local cServer   	:= SuperGetMV('MV_RELSERV') 		// Ex.: smtp.gmail.com
Local cTo		 	:= ""

If Empty(cToEmail)
	cMsg := STR0099 + CRLF // "É necessario que informe um e-mail"
	lRet := .F.
EndIf

If lRet
	// Usa SSL, TLS ou nenhum na inicializacao
	oServer:SetUseSSL(lSSL)
	oServer:SetUseTLS(lTLS)
	
	// Inicializacao do objeto de Email
	nErr := oServer:init("",cServer,cConta,cSenha,,nSMTPPort)
	If nErr <> 0
		cMsg := STR0100 + oServer:getErrorString(nErr) // "[Init SMTP] Falha ao inicializar SMTP: "
		lRet := .F.
	Endif
	
	If lRet	
		// Define o Timeout SMTP
		nErr := oServer:SetSMTPTimeout(nSMTPTime)
		If nErr <> 0
			cMsg := STR0101 + oServer:getErrorString(nErr) //"[SetSMTPTimeout] Falha ao definir timeout: "
			lRet := .F.
		EndIf
	EndIf

EndIf

If lRet	
	// Conecta ao servidor
	nErr := oServer:smtpConnect()
	If nErr <> 0
		cMsg := STR0102 + oServer:getErrorString(nErr) // "[Connect SMTP] Falha ao conectar: "
		oServer:SMTPDisconnect()
		lRet := .F.
	EndIf
EndIf
	
// Realiza autenticacao no servidor
If lRet .And. lRelauth
	nErr := oServer:smtpAuth(cConta, cSenha)
	If nErr <> 0
		cMsg := STR0103 + oServer:getErrorString(nErr) // "Falha ao autenticar ao servidor SMTP:"
		oServer:SMTPDisconnect()
		lRet := .F.
	EndIf
EndIf

If lRet	
	// Cria uma nova mensagem (TMailMessage)
	oMessage := TMailMessage():New()
	oMessage:clear()
		
	oMessage:cFrom		:= cConta
	oMessage:cTo    	:= cToEmail
	oMessage:cSubject	:= cAssunto
	oMessage:cBody 		:= cMensagem
		
	If !Empty(cFile)
		nErr := oMessage:AttachFile( cFile )
		If nErr < 0
			cMsg := STR0104 +  oServer:getErrorString(nErr) //"[Attach] Erro ao anexar arquivo"
			lRet := .F.
		Endif
	EndIf
		
	//conout( "[SEND] Enviando ..." ) //"[SEND] Enviando ..."
	nErr := oMessage:Send( oServer )
			  
	If nErr != 0
		//conout( "[SEND] Falha ao enviar " ) //"[SEND] Falha ao enviar"
		cMsg := STR0105 +  oServer:GetErrorString( nErr ) //"[SEND][ERROR] "
		lRet := .F.
	Else
		//conout( "[SEND] Sucesso no envio " + oServer:getErrorString(nErr) ) // "[SEND] Sucesso no envio"
		cMsg := STR0106 + oServer:getErrorString(nErr)	// "[SEND] Sucesso no envio "
	EndIf
		
	//conout( STR0057 ) //"[DISCONNECT] Descone tando SMTP "
	nErr := oServer:SmtpDisconnect()
	/*If nErr != 0
		conout( "[DISCONNECT] Falha ao Desconectar SMTP" ) //"[DISCONNECT] Falha ao Desconectar SMTP"
		conout( "[DISCONNECT][ERROR] " + oServer:GetErrorString( nErr )) //"[DISCONNECT][ERROR] "
	Else
		conout( "[DISCONNECT] Sucesso ao desconectar SMTP" + oServer:getErrorString(nErr) ) //"[DISCONNECT] Sucesso ao desconectar SMTP"
	EndIf*/
EndIf
		
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecConvHr
@description  Função para transformar Hora (Numerico) em String
@return cRet - Horario em String
@author Augusto Albuquerque
@since  16/12/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecConvHr( xHora )
Local cRet		:= ""
Local cAux		:= ""
Local nPonto	:= 0

If ValType( xHora ) == "N"
	cAux := cValToChar( xHora )
	If AT(".",cAux) > 0
		cRet := STRTRAN(cAux, ".",":")
		If ":" $ Right(cRet, 2)
			cRet += "0"
		EndIf
	Else
		cRet := cAux +":00"
	EndIf
	If Len(cRet) == 4
		cRet := "0" + cRet
	EndIf
ElseIf ValType( xHora ) == "C"
	xHora := AllTrim(xHora)
	If AT(":",xHora)
		cRet := Val(STRTRAN(xHora, ":","."))
	Else
		cRet := Val(xHora)
	EndIf
EndIf

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecSupTXI
Verifica se a tabela TXI existe no dicionario de dados para verificar supervisor

@author		Luiz Gabriel
@since		07/02/2020
@version	P12.1.30
/*/
//------------------------------------------------------------------------------
Function TecSupTXI()
Local lRet := .F.

lRet := AA1->(ColumnPos("AA1_SUPERV")) > 0  .AND. TableInDic("TXI")

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecFilterTXI
Realiza o filtro de supervisores, utilizado na API TECM020 app Minha Gestão de Postos

@author		Luiz Gabriel
@since		07/02/2020
@version	P12.1.30
/*/
//------------------------------------------------------------------------------
Function TecFilterTXI(aSuperv,aLocais,nTamSuperv,nTamPlace)
Local cAliasTXI := GetNextAlias()
Local cSuperv	:= ""
Local cLocais	:= ""
Local nI		:= 0
Local cExpPla   := "%0 = 0%"
Local cExpLoc   := "%0 = 0%"

If Len(aSuperv) > 0
	For nI := 1 To Len(aSuperv)
            cSuperv      := aSuperv[nI]    
            cSuperv := cSuperv + Space(nTamSuperv - Len(cSuperv))    
            
            If nI == 1
                  cExpPla :=  '%  TXI_CODTEC IN (' + "'" + cSuperv +  "'"      
            Else  
                  cExpPla := cExpPla +  ",'" + cSuperv +  "'"                       
            EndIf
                  
            If nI == Len(aSuperv)
                  cExpPla := cExpPla + ")%"
            EndIf      
      Next nI

	If Len(aLocais) > 0
		For nI := 1 To Len(aLocais)
            cLocais      := aLocais[nI]    
            cLocais := cLocais + Space(nTamPlace - Len(cLocais))    
            
            If nI == 1
                  cExpLoc :=  '%  TXI_LOCAL IN (' + "'" + cLocais +  "'"      
            Else  
                  cExpLoc := cExpLoc +  ",'" + cLocais +  "'"                       
            EndIf
                  
            If nI == Len(aLocais)
                  cExpLoc := cExpLoc + ")%"
            EndIf      
      Next nI
	EndIf

	BeginSql Alias cAliasTXI
		SELECT TXI.TXI_LOCAL, TXI.TXI_CODTEC
		FROM %table:TXI% TXI
		WHERE TXI.TXI_FILIAL = %xFilial:TXI%
			AND  %exp:cExpPla%
			AND  %exp:cExpLoc%
			AND (TXI.TXI_DTINI <= %exp:dDatabase% AND TXI.TXI_DTFIM >= %exp:dDatabase%)
			AND TXI.%NotDel%
	EndSql

	If ( cAliasTXI )->( !Eof() )
		aLocais := {}
		While ( cAliasTXI )->( !Eof() )
			aAdd(aLocais,(cAliasTXI)->TXI_LOCAL)
			( cAliasTXI )->( DBSkip() ) 	
		EndDo
	Else
		aLocais := {Space(nTamPlace)}
	EndIf
			
	(cAliasTXI)->(DbCloseArea())
EndIf

Return aLocais
//------------------------------------------------------------------------------
/*/{Protheus.doc} TecxVldMsg
Função responsável pela alteração da variável estática de validação de restrição de RH para substituto na Mesa Operacional,
Impedindo a exibição de múltiplas mensagens.

@author		Kaique Schiller
@since		04/08/2020
/*/
//------------------------------------------------------------------------------
Function TecxVldMsg(lMsg,lVld)
lVldMsgAloc := lMsg
lRetVldSub  := lVld
Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} DiaExist
Função responsável pela alteração da variável estática de validação de restrição de RH para substituto na Mesa Operacional,
Impedindo a exibição de múltiplas mensagens.

@author		Mateus Boiani
@since		07/10/2020
/*/
//------------------------------------------------------------------------------
Static Function DiaExist(dDataRef,_cFunFil,_cMatFunc,_cCodTec)
Local lRet := .T.
Local aArea := GetArea()
Local cAliasQry	:= GetNextAlias()
Local cSql := ""
Local lMtFil := SuperGetMV("MV_GSMSFIL",,.F.)

Default _cFunFil := ""
Default _cMatFunc := ""
Default _cCodTec := ""

cSql += " SELECT 1 FROM " + RetSqlName( "ABB" ) + " ABB "
cSql += " INNER JOIN " + RetSqlName( "TDV" ) + " TDV ON "
cSql += " TDV.TDV_FILIAL = ABB.ABB_FILIAL AND "
cSql += " TDV.TDV_CODABB = ABB.ABB_CODIGO AND "
cSql += " TDV.D_E_L_E_T_ = ' ' "
cSql += " INNER JOIN " + RetSqlName( "AA1" ) + " AA1 ON "
cSql += " AA1.AA1_CODTEC = ABB.ABB_CODTEC AND "
cSql += " AA1.D_E_L_E_T_ = ' ' AND "
cSql += " AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
cSql += " WHERE "
cSql += " TDV.TDV_DTREF = '" + DTOS(dDataRef) + "' AND "
cSql += " ABB.D_E_L_E_T_ = ' ' AND "
If !EMPTY(_cCodTec)
	cSql += " AA1.AA1_CODTEC = '" + _cCodTec + "' "
Else
	cSql += " AA1.AA1_CDFUNC = '" + _cMatFunc + "' AND "
	cSql += " AA1.AA1_FUNFIL = '" + _cFunFil + "' "
EndIf
cSql += " AND ABB.ABB_ATIVO = '1' "
If !lMtFil
	cSql += " AND ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
EndIf
cSql := ChangeQuery(cSql)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
lRet := !((cAliasQry)->(Eof()))
(cAliasQry)->(dbCloseArea())

RestArea(aArea)
Return lRet
//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecADiaExs
@description Execução da função DiaExist de forma não-Static
@author Mateus Boiani
@since  15/10/2020
/*/
//--------------------------------------------------------------------------------
Function TecADiaExs(dDataRef,_cFunFil,_cMatFunc,_cCodTec)

Return DiaExist(dDataRef,_cFunFil,_cMatFunc,_cCodTec)

//------------------------------------------------------------------------------
/*/{Protheus.doc} VerAbbRest

@description Verifica se o atendente tem a primeira parte da agenda no posto 
com o parametro MV_GSVERHR desabilitado, para não ocorrer erro de alocação no mesmo dia.

@author	augusto.albuquerque
@since	24/02/2021   (cAlias)->TMP_IDCFAL, cCodtec, dIniAloc, dFimAloc, cHrIni, cHrFim
/*/
//------------------------------------------------------------------------------
Static Function VerAbbRest(cIdcFal, cAtend, DtIni, DtFim, cHrIni, cHrFim, cFilABB)
Local aArea		:= GetArea()
Local cQuery	:= ""
Local cAliasABB	:= GetNextAlias()
Local lRet		:= .T.

cQuery := ""
cQuery += " SELECT 1 "
cQuery += " FROM " + RetSqlName("ABB") + " ABB "
cQuery += " WHERE "
cQuery += " ABB.ABB_IDCFAL = '" + cIdcFal + "' "
cQuery += " AND ABB.ABB_FILIAL = '" + cFilABB + "' "
cQuery += " AND ABB.ABB_CODTEC = '" + cAtend + "' "
cQuery += " AND ABB.D_E_L_E_T_ = ' ' "
cQuery += " AND ((ABB_DTINI = '" + DtoS(DtIni) + "' "
cQuery += " AND ABB_HRINI > '" + cHrIni +"') "
cQuery += " AND (ABB_DTFIM = '" + DtoS(DtFim) + "' "
cQuery += " AND ABB_HRFIM < '" + cHrFim + "')) "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasABB, .F., .T.)

lRet := (cAliasABB)->(EOF())

(cAliasABB)->(dbCloseArea())

RestArea( aArea )
Return lRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecEncDtFt
@description Retorna se a base de dados possui os campos TFF_DTENCE e TFL_DTENCE
@author Augusto Albuquerque
@since  20/10/2021
/*/
//--------------------------------------------------------------------------------
Function TecEncDtFt()
Return TFF->( ColumnPos('TFF_DTENCE') ) > 0 .AND. TFL->( ColumnPos('TFL_DTENCE') ) > 0

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecBHasExc

@description Retorna se a base de dados possui o campo TFF_GERVAG
@author Luiz Gabriel
@since  22/10/2021
/*/
//--------------------------------------------------------------------------------
Function TecBHasGvg()
Return (TFF->(ColumnPos('TFF_GERVAG')) > 0)

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecBHasExc

@description Retorna se a base de dados possui os campos da TGT para uso no
relatorio de timeline do reajuste retroativo.

@author Luiz Gabriel
@since  22/10/2021
/*/
//--------------------------------------------------------------------------------
Function TecCpoTGT()
Return (TGT->( ColumnPos('TGT_DTINI') ) > 0 .AND. TGT->( ColumnPos('TGT_DTFIM') ) > 0 .AND. TGT->( ColumnPos('TGT_INDICE') ) > 0 .AND. TGT->( ColumnPos('TGT_VALREA') ) > 0)

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TxNewAA1

@description Retorna arrya utilizado para gerar o atendente
@author Luiz Gabriel
@since  28/12/2021
/*/
//--------------------------------------------------------------------------------
Static Function TxNewAA1(cFilAten,cMatAten,cNomAte,cFuncAte,cTurnAte,cSeqAte,cCcuAte)

Local cFilAA1 	:= xFilial('AA1', cFilAten)
Local cCodTec 	:= cFilAten + cMatAten
Local cCCusto 	:= cCcuAte
Local cCodFunc 	:= cMatAten
Local aDados 	:= {}
Local aCampos   :=  GetCpoAA1()
Local nCont     := 0 


For nCont := 1 to Len(aCampos)
	If (GetSX3Cache( aCampos[nCont], "X3_CONTEXT" ) != "V" )
		If aCampos[nCont]     == 'AA1_FILIAL'
			AADD(aDados,{aCampos[nCont],cFilAA1})
		Elseif aCampos[nCont] == 'AA1_CODTEC'
			AADD(aDados,{aCampos[nCont],cCodTec}) 
		Elseif aCampos[nCont] == 'AA1_CC'
			AADD(aDados,{aCampos[nCont],cCCusto}) 
		Elseif aCampos[nCont] == 'AA1_CDFUNC'
			AADD(aDados,{aCampos[nCont],cCodFunc})  	 	      
		Elseif aCampos[nCont] == 'AA1_FUNFIL'
			AADD(aDados,{aCampos[nCont],cFilAten}) 
		ElseIf X3Uso(GetSX3Cache(aCampos[nCont],"X3_USADO"),28)		
			AADD(aDados,{aCampos[nCont],(AA1->&(aCampos[nCont]))})
		Endif	
	Endif	
Next

Return aDados		

//--------------------------------------------------------------------------------
/*/{Protheus.doc} GetCpoAA1

@description Retorna array com a estrutura da tabela AA1
@author Luiz Gabriel
@since  13/05/2022
/*/
//--------------------------------------------------------------------------------
Function GetCpoAA1()

If Empty(aCpoAA1)
	aCpoAA1 := FWSX3Util():GetAllFields( 'AA1' , .F. )
EndIf 

Return aCpoAA1

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} TecPostoLib
    Verifica se o tipo de movimentação é para Posto Liberado(TCU_LIBERA)
    @type  Function
	@param cFilTCU - Filial do tipo de movimentação
	@param cTipoAloc - Tipo de Alocação
    @author Luiz Gabriel
    @since 01/04/2022
    @version 12
    @return lRet, Logico, .T. se o tipo de movimentação é para posto liberado
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function TecPostoLib(cFilTCU,cTipoAloc)
Local lRet 	:= .F.
Local aConf	:= {}

Default cFilTCU 	:= ""
Default cTipoAloc	:= ""

If !Empty(cFilTCU) .And. !Empty(cTipoAloc)
	DbSelectArea("TCU")
	If TCU->( ColumnPos('TCU_LIBERA') ) > 0
		aConf := TxConfTCU(cTipoAloc,{"TCU_LIBERA"},cFilTCU)
		If Len(aConf) > 0 .And. (!Empty(aConf[1][1]) .And. aConf[1][1] = "TCU_LIBERA")
			If aConf[1][2] = "1" //"1=Sim;2=Não"
				lRet := .T.
			EndIf
		EndIf
	EndIf 
EndIf

Return lRet

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} TecAgPstLib
    Verifica se as agendas marcadas são do tipo Posto Liberado
    @type  Function
	@param aMarks - Array contendo as agendas marcadas
    @author Luiz Gabriel
    @since 01/04/2022
    @version 12
    @return lRet, Logico, .F. se a agenda marcada é do tipo Posto Liberado
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function TecAgPstLib(aMarks)
Local aAreaABB 	:= ABB->(GetArea())
Local lRet 		:= .T.
Local nX 		:= 0

Default aMarks	:= {}

If Len(aMarks) > 0
	DbSelectArea("ABB")
	ABB->(DbSetOrder(8))

	For nX := 1 To Len(aMarks)
		If !EMPTY(aMarks[nX][1]) .And. ABB->( MsSeek(aMarks[nX][12] + aMarks[nX][1] ) )
			If !TecPostoLib(aMarks[nX][12],ABB->ABB_TIPOMV)
				lRet := .F.
				Exit
			EndIf 
		EndIf
	Next nX 
EndIf 

RestArea(aAreaABB)
Return lRet

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} TecMnPstLib
    Verifica se as agendas selecionadas para manutenção são do tipo manutenção e adiciona no array para msg de alerta
    @type  Function
	@param aMarks - Array contendo as agendas marcadas
	@param nPosManut - Posição do array aMarks
	@param cTpMot - Tipo de Manutenção informada
	@param aPostLib - Array com as agendas que são do tipo Posto Liberado, passado como Referencia
    @author Luiz Gabriel
    @since 01/04/2022
    @version 12
    @return lRet, Logico, .T. se a agenda é do tipo Posto Liberado
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function TecMnPstLib(aMarks,nPosManut,cTpMot,aPostLib)
Local aAreaABB 	:= ABB->(GetArea())
Local lRet 		:= .F.

Default aMarks		:= {}
Default nPosManut	:= 0
Default cTpMot		:= ""
Default aPostLib 	:= {}

If Len(aMarks) > 0 .And. nPosManut > 0 .And. !Empty(cTpMot)
	DbSelectArea("ABB")
	ABB->(DbSetOrder(8))

	If ABB->( MsSeek(aMarks[nPosManut][12] + aMarks[nPosManut][1] ) )
		If TecPostoLib(aMarks[nPosManut][12],ABB->ABB_TIPOMV) .And. cTpMot <> "05" //"05" Cancelamento
			lRet := .T.
			AADD(aPostLib, { aMarks[nPosManut][1],;
					aMarks[nPosManut][2],;
					aMarks[nPosManut][3],;
					aMarks[nPosManut][4],;
					aMarks[nPosManut][5],;
					aMarks[nPosManut][9],;
					aMarks[nPosManut][12];
					})
		EndIf 
	EndIf
EndIf 	

RestArea(aAreaABB)
Return lRet

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} TecPtLibMsg
    Monta o texto para as agendas que não foram processadas pelo motivo de Posto Liberado
    @type  Function
	@param aAgendas - Array com as agendas que não foram processadas pelo motivo de Posto Liberado
    @author Luiz Gabriel
    @since 01/04/2022
    @version 12
    @return cMsg - Mensagem que será exibida na mesa operacional
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function TecPtLibMsg(aAgendas)
Local cMsg	:= ""
Local nX 	:= 0

Default aAgendas	:= {}

If Len(aAgendas) > 0
	cMsg	:= STR0135 + CRLF //"As Seguintes Agendas não foram processadas: "
	For nX := 1 To Len(aAgendas)
		cMsg += STR0136 + AllToChar(aAgendas[nX][1]) + CRLF //"Código da Agenda: "
		cMsg += STR0137 + AllToChar(aAgendas[nX][2]) + CRLF //"Data de Inicio: "
		cMsg += STR0138 + AllToChar(aAgendas[nX][3]) + CRLF //"Hora de Inicio: "
		cMsg += STR0139 + AllToChar(aAgendas[nX][4]) + CRLF //"Hora de Termino: "
		cMsg += STR0140 + AllToChar(aAgendas[nX][5]) + CRLF //"Data de Termino: "
		cMsg += STR0141 + AllToChar(aAgendas[nX][6]) + CRLF //"Data de Referencia: "
		cMsg += STR0142 + AllToChar(aAgendas[nX][7]) + CRLF //"Filial da Agenda: "
		cMsg += "--------------------------------------------------------------" + CRLF
	Next nX

	cMsg	+= STR0143 + CRLF //"Agendas do Tipo Posto Liberado, não podem realizar manutenções diferentes de 000005 - Cancelamento"
EndIf 

Return cMsg

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} TecAponts
    @description Verifica se existe os camçpços e parâmetro escritos no return 
    @author Natacha Romeiro
    @since 01/06/2022
    @return Logico
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function TecAponts()

Return SuperGetMv('MV_GSAPMAT',.F.,.F.) .and. ((TFS->(ColumnPos("TFS_CODSA"))>0) .and. (TFT->(ColumnPos("TFT_CODSA"))>0)) 
