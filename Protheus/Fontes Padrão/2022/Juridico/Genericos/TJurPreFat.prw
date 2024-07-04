#INCLUDE "PROTHEUS.CH"
#INCLUDE "TJurPreFat.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

/**************************
Classes: TJPREFATPARAM - Valida e agrupa os parâmetros passados para as rotinas
         TJPREFAT      - Chama as rotinas de emissão de pré
**************************/

//-------------------------------------------------------------------
/*/{Protheus.doc} Class TJPREFATPARAM
Classe usada para agrupar e validar os parâmetros de pré-faturamento

@cCodUser		Código do usuário.

@lFltrHH		Considera contratos com cobrança de honorários "Por hora" para faturar os honorários: '.T.' - Considera; '.F.' - Não Considera.
@lFltrHO		Considera contratos com cobrança de honorários com Outros Tipos para faturar os honorários: '.T.' - Considera; '.F.' - Não Considera.
@dDIniH			Data inicial de referência para Honorários.
@dDFinH			Data final de referência para honorários.
@lFltrDH		Considera contratos com cobrança de honorários "Por Hora" para faturar as Despesas: '.T.' - Considera; '.F.' - Não Considera.
@lFltrDO		Considera Despesas para faturamento Fixo: '.T.' - Considera; '.F.' - Não Considera.
@dDIniD			Data inicial de referência da Despesa.
@dDFinD			Data final de referência da Despesa.
@lFltrTH		Considera Lançamento Tabelado para faturamento por hora: '.T.' - Considera; '.F.' - Não Considera.
@lFltrTO		Considera Lançamento Tabelado para faturamento Fixo: '.T.' - Considera; '.F.' - Não Considera.
@dInitLT		Data inicial de referência do Lançamento Tabelado.
@dFinLT			Data final de referência do Lançamento Tabelado.
@lFltrFA		Considera Fatura Adicional: '.T.' - Considera; '.F.' - Não Considera.
@dInIfA			Data inicial de referência da Fatura Adicional.
@dFinFA			Data final de referência da Fatura Adicional.
@cSocio			Código do Sócio.
@cMoeda			Código da Moeda.
@cContrato		Código do contrato.
@lTdContr		Todos os Contrados? '.T.' - Todos os Contratos Vinculados '.F.' - Somente o Contrato Filtrado
@cGrpCli		Código do grupo de cliente.
@cCliente		Código do Cliente.
@cloja			Código da Loja.
@cCasos			Variável que recebe a lista de casos há serem pré-faturados.
@lTdCasos		Todos os Casos? '.T.' - Todos os Casos Vinculados '.F.' - Somente o Caso Filtrado

@cExceto		Variável que recebe a lista de Cliente+Loja que será exclusa do processo de pré-fatura.
@cExcSoc		Variável que recebe a lista de Socios que será exclusa do processo de pré-fatura.
@cSitSoc		Variável que recebe a situação do cadastro do sócio do processo de pré-fatura.
@cEscrit		Código do Escritório.
@cTipoDP		Código de Tipo de desconto.
@lChkPend		Emitir tudo que for pendente: '.T.' - Emite; '.F.' - Não Emite.

@cTipoHon		Codigo do Tipo de honorário.
@cSituac		Situação: 1 - Conferência; 2 - Pré-Fatura; 3 - Emitir Fatura;  4 - Emitir Minuta.
@cTipoRel		Código do tipo de relatório.
@lChkApaga		Apagar fatura anterior?: '.T.' - Sim; '.F.' - Não.
@lChkApaMP		Apagar minuta de pré-fatura anterior?: '.T.' - Sim; '.F.' - Não.
@lChkCorr		Corrige valor base do(s) contrato(s) fixo(s)?: '.T.' - Sim; '.F.' - Não.

@cTpExec		Tipo de Execução: 1 - Pré-Fatura; 2 - Reemissão Pré-fatura; 3 - Minuta Pré; 4 - Minuta Fatura; 5 - Emissão de Fatura; 6 - Reemissão de Fatura; 7 - Conferência.
@dDAtual		Data de atual.

@cPreFat		Código da Pré-fatura.	(para reeimpressão de pré)
@lTodosVinc		Pré-faturar Todos casos ou contratos vinculados? '.T.' - Sim; '.F.' - Não.

@cCodFilaImp	Código da fila de impressão (para emissão de Fatura ou Minuta)

@cFatura		Código da Fatura para Reemitir a Pré
@cEscr			Código do Escritório da Fatura para Reemitir a Pré
@lConsist		Indica se a pré-fatura sendo emitida está consistente. .T. - sim / .F. - Não

@Return aRet    Retorna variavél logica de: '.T.' - Commit Trasaction; '.F.' - Rollback Trasaction.

@author David G. Fernandes
@since 12/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function __TJPREFATPARAM() // Function Dummy
	ApMsgInfo( 'TJPREFATPARAM -> Utilizar Classe ao inves da funcao' )
Return NIL

Class TJPREFATPARAM From FWSerialize
	Data   cCodUser

	Data   lFltrHH
	Data   lFltrHO
	Data   dDIniH
	Data   dDFinH

	Data   lFltrDH
	Data   lFltrDO
	Data   dDIniD
	Data   dDFinD

	Data   lFltrTH
	Data   lFltrTO
	Data   dDIniT
	Data   dDFinT

	Data   lFltrFA
	Data   dDInIfA
	Data   dDFinFA

	Data   lFltrFxNc
	Data   dDInIFxNc
	Data   dDFinFxNc

	Data   cSocio
	Data   cMoeda
	Data   cContrato
	Data   aContratos
	Data   lTDContr
	Data   cGrpCli
	Data   cCliente
	Data   cloja
	Data   cCasos
	Data   lTDCasos

	Data   cExceto
	Data   cExcSoc
	Data   cSitSoc
	Data   cEscrit
	Data   cTipoDP
	Data   lChkPend
	Data   lChkFech
	Data   cTipoFech

	Data   cTipoHon
	Data   cSituac
	Data   cTipoRel
	Data   lChkApaga
	Data   lChkApaMP
	Data   lChkCorr

	Data   cTpExec
	Data   dDAtual

	Data   cTipoFat
	Data   cPreFat
	Data   lTodosVinc
	Data   cMarkEsc
	Data   cMarkFat
	Data   cCodFilaImp

	Data   cFatura
	Data   cEscr

	Data   aParams

	Data   cMoedaFt

	Data   lIsThread

	Data   aMsgs

	Data   cQueryPre

	Data   cNameFunction

	Data   lMarkInvert
	Data   lConsist

	Data   cFatSub
	Data   cEscSub

	Data   lTsZero
	Data   nTsZero

	Data   cResomaFt
	Data   aFaturas

	Data   oTmpContr
	Data   oTmpLimite

	Method New() Constructor
	Method Destroy()
	Method ValidInf()

 	Method GetCodUser()
 	Method SetCodUser(cCdUser)

 	Method GetMarkEsc()
 	Method GetMarkFat()
 	Method SetMark(cMark)

 	Method GetFltrHH()
 	Method SetFltrHH(lFltrHH)
	Method GetFltrHO()
 	Method SetFltrHO(lFltrHO)
	Method GetDIniH()
	Method SetDIniH(dDIniH)
 	Method GetDFinH()
	Method SetDFinH(dDIniH)

	Method GetFltrDH()
 	Method SetFltrDH(lFltrDH)
	Method GetFltrDO()
 	Method SetFltrDO(lFltrDO)
	Method GetDIniD()
	Method SetDIniD(dDIniD)
 	Method GetDFinD()
	Method SetDFinD(dDIniD)

	Method GetFltrTH()
 	Method SetFltrTH(lFltrTH)
	Method GetFltrTO()
 	Method SetFltrTO(lFltrTO)
	Method GetDIniT()
	Method SetDIniT(dDIniT)
 	Method GetDFinT()
	Method SetDFinT(dDFinT)

	Method GetFltrFA()
	Method SetFltrFA(lFltrFA)
	Method GetDInIFA()
	Method SetDInIFA(dDInIFA)
	Method GetDFinFA()
	Method SetDFinFA(dDFinFA)

	Method GetFltrFxNc()
	Method SetFltrFxNC(lFltrFxNc)
	Method GetDInIFxNc()
	Method SetDInIFxNc(dDInIFxNc)
 	Method GetDFinFxNc()
	Method SetDFinFxNc(dDFinFxNc)

	Method GetSocio()
	Method SetSocio(cSocio)

 	Method GetMoeda()
	Method SetMoeda(cMoeda)

	Method GetContrato()
	Method SetContrato(cContrato)
	Method GetTDContr()
	Method SetTDContr(lTDContr)

	Method GetCliente()
	Method SetCliente(cCliente)

	Method GetLoja()
	Method SetLoja(cLoja)

	Method GetCasos()
	Method SetCasos(cCasos)
	Method GetTDCasos()
	Method SetTDCasos(lTDCasos)

	Method GetGrpCli()
	Method SetGrpCli(cGrpCli)

	Method GetExceto()
	Method SetExceto(cExceto)

	Method GetExcSoc()
	Method SetExcSoc(cExcSoc)

	Method GetSitSoc()
	Method SetSitSoc(cSitSoc)

	Method GetEscrit()
	Method SetEScrit(cEscrit)

	Method GetTipoDP()
	Method SetTipoDP(cTipoDP)

	Method GetChkPend()
	Method SetChkPend(lChkPend)

	Method GetChkFech()
	Method SetChkFech(lChkFech)
	Method GetTipoFech()
	Method SetTipoFech(cTipoFech)

	Method GetTipoHon()
	Method SetTipoHon(cTipoHon)

	Method GetSituac()
	Method SetSituac(cSituac)

	Method GetTipRel()
	Method SetTipRel(cTipoRel)

	Method GetChkApaga()
	Method SetChkApaga(lChkApaga)

	Method GetChkApaMP()
	Method SetChkApaMP(lChkApaMP)

	Method GetChkCorr()
	Method SetChkCorr(lChkCorr)

	Method GetTpExec()
	Method SetTpExec(cTpExec)

	Method GetDEmi()
	Method SetDEmi(dDAtual)

	Method GetcTipoFat()
	Method SetcTipoFat(cTipoFat)

	Method GetPreFat()
	Method SetPreFat(cPreFat)

	Method GetCFilaImpr()
	Method SetCFilaImpr(cCodFilaImp)

	Method GetCodFatur()
	Method SetCodFatur(cFatura)
	Method GetCodEscr()
	Method SetCodEscr(cEscr)

	Method GetParams()
	Method SetParams(aParams)

	Method GetMoedaFt()
	Method SetMoedaFt(cMoedaFt)

	Method EventInsert()

	Method SetIsThread()
	Method IsThread()

	Method AddLog(cNewMsg)
	Method GetLog()
	Method ShowLog()

	Method GetQueryPre()
	Method GetCONTRS()
	Method LockContratos()
	Method UnLockContratos()

	Method SetNameFunction()
	Method GetNameFunction()
	Method PtInternal()
	Method SetMarkInvert()
	Method GetMarkInvert()
	Method GetConsist()
	Method SetConsist(lConsist)

	Method GetFatSub()
	Method SetFatSub(cFatSub)
	Method GetEscSub()
	Method SetEscSub(cEscSub)
	Method GetMsgErro(cCodErro)

	Method GetTsZero(nTsZero)
	Method SetTsZero(lTsZero)

	Method GetResomaFt()
	Method SetResomaFt(cResomaFt)

	Method GetFatEmite()
	Method SetFatEmite(aNXARecnos)

	Method GetQryTmpCtr()
	Method GetQryTmpLM()
	Method GeraTmpContrato()
	Method GeraTmpLimite()
	Method DelTmpContrato()
	Method DelTmpLimite()
	Method JSerialize()
	Method GetQryInFat(cTabela)

	Method IsLimit(cContr, cCliente, cLoja, cCaso)

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Construtor da Classe TJPREFATPARAM

@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class TJPREFATPARAM
	self:cCodUser      := __cUserID
	self:lFltrHH       := .F.
	self:lFltrHO       := .F.
	self:dDIniH        := CToD( '  /  /    ' )
	self:dDFinH        := Date()

	self:lFltrDH       := .F.
	self:lFltrDO       := .F.
	self:dDIniD        := CToD( '  /  /    ' )
	self:dDFinD        := Date()

	self:lFltrTH       := .F.
	self:lFltrTO       := .F.
	self:dDIniT        := CToD( '  /  /    ' )
	self:dDFinT        := Date()

	self:lFltrFA       := .F.
	self:dDInIfA       := CToD( '  /  /    ' )
	self:dDFinFA       := Date()

	self:cSocio        := " "
	self:cMoeda        := " "
	self:cCliente      := " "
	self:cloja         := " "
	self:cCasos        := " "
	self:lTDCasos      := .F.
	self:cGrpCli       := " "
	self:cContrato     := " "
	Self:aContratos    := {}
	self:lTDContr      := .F.
	self:cExceto       := " "
	self:cExcSoc       := " "
	self:cSitSoc       := ""
	self:cEscrit       := " "
	self:cTipoDP       := " "
	self:lChkPend      := .F.

	self:cTipoHon      := " "
	self:cSituac       := "2"
	self:cTipoRel      := " "
	self:lChkApaga     := .F.
	self:lChkApaMP     := .F.
	self:lChkCorr      := .F.

	self:cTpExec       := " "
	self:dDAtual       := Date()

	self:cTipoFat      := ""
	self:cPreFat       := " "
	self:cMarkEsc      := RandMark(TamSX3("NS7_COD")[1]) //Marca temporário para escritório
	self:cMarkFat      := RandMark(TamSX3("NXA_COD")[1]) //Marca temporário para o número da Fatura
	self:cCodFilaImp   := " "

	self:cFatura       := " "
	self:cEscr         := " "

	self:aParams       := {}

	self:lIsThread     := .F.

	self:aMsgs         := {}

	self:cQueryPre     := " " // inicializa a variavel para poder concatenar as querys

	self:cNameFunction := ""

	self:lMarkInvert   := .F.
	self:lConsist      := .T. // o padrão é estar consistente.

	self:lTsZero       := .F. // Ativa JA201ATS para verificar se existem timesheet com participantes se valor na tabela de honorários

	self:cResomaFt     := ""

	self:aFaturas      := {}

Return self

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy()
Destroy da Classe TJPREFATPARAM

@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method Destroy() Class TJPREFATPARAM
Local lRet := .T.

	lRet := Self:UnLockContratos()
	Self:DelTmpContrato()
	Self:DelTmpLimite()
	JurfreeArr(self:aFaturas)
	JurfreeArr(self:aMsgs)
	JurfreeArr(self:aParams)
	JurfreeArr(self:aContratos)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCodUser()
Método Get do Parâmetro cCodUser

@Return cCodUser   Código do usuário

@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetCodUser()  Class TJPREFATPARAM
Return (self:cCodUser)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetCodUser(cCdUser)
Método SET do Parâmetro cCdUser

@param cCdUser	    		Código do usuário

@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.

@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetCodUser(cCdUser)  Class TJPREFATPARAM
	Local aRet := {.F., "SetCodUser"}

	self:cCodUser := cCdUser
	aRet := {.T., "SetCodUser"}

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMarkEsc()
Método do Parâmetro da chave temporário do escritório

@Return cMarkEsc  Marca do escritório para filtrar as prés emitidas pelo usuário
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetMarkEsc()  Class TJPREFATPARAM
Return (self:cMarkEsc)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMarkFat()
Método do Parâmetro da chave temporária do número da Fatura

@Return cMarkEsc  Marca do número da Fatura para filtrar as prés emitidas pelo usuário
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetMarkFat()  Class TJPREFATPARAM
Return (self:cMarkFat)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetMark(cCdUser)
Método SET do Parâmetro cMark

@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author David G. Fernandes
@since 13/07/11
@version 1.0
@protect Método descontinuado por segurança
/*/
//-------------------------------------------------------------------
Method SetMark(cpMark)  Class TJPREFATPARAM
	aRet := {.F., "SetMark"}
Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFltrHH()
Método Get do Parâmetro lFltrHH

@Return lFltrHH	 	  Filtra Time Sheet? - .T. / .F.
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetFltrHH() Class TJPREFATPARAM
Return self:lFltrHH

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFltrHH(lFltrHH)
Método SET do Parâmetro lFltrHH

@param lFltrHH	    		 Filtra Time Sheet? - .T. / .F.
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetFltrHH(lFltrHH) Class TJPREFATPARAM
	Local aRet := {.F., "SetFltrHH"}

	If ValType(lFltrHH) == "L"
		self:lFltrHH := lFltrHH
		aRet := {.T., "SetFltrHH"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFltrHO()
Método Get do Parâmetro lFltrHO

@Return lFltrHO	 	  Filtra Fixo? .T. / .F.
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetFltrHO() Class TJPREFATPARAM
Return (self:lFltrHO)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFltrHO(lFltrHO)
Método SET do Parâmetro lFltrHO

@param lFltrHO	    		Filtra Fixo? .T. / .F.
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetFltrHO(lFltrHO) Class TJPREFATPARAM
	Local aRet := {.F., "SetFltrHO"}

	If ValType(lFltrHO) == "L"
		self:lFltrHO := lFltrHO
		aRet := {.T., "SetFltrHO"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDIniH()
Método Get do Parâmetro dDIniH

@Return dDIniH	 	  Data de referência Inicial para Time-Sheets
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetDIniH() Class TJPREFATPARAM
Return (self:dDIniH)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetDIniH(dDIniH)
Método SET do Parâmetro dDIniH

@param dDIniH	    		Data de referência Inicial para Time-Sheets
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetDIniH(dDIniH) Class TJPREFATPARAM
	Local aRet  := {.F., "SetDIniH"}
	Local cTipo := ValType(dDIniH)

	If cTipo $ "D|C"
		self:dDIniH := IIF(cTipo == "D", dDIniH, CtoD(dDIniH))
		aRet := {.T., "SetDIniH"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDFinH()
Método Get do Parâmetro dDFinH

@Return dDFinH	 	  Data de referência Final para Time-Sheets
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetDFinH() Class TJPREFATPARAM
Return (self:dDFinH)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetDFinH(dDFinH)
Método SET do Parâmetro dDFinH

@param dDFinH	    		Data de referência Final para Time-Sheets
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetDFinH(dDFinH) Class TJPREFATPARAM
	Local aRet := {.F., "SetDFinH"}
	Local cTipo := ValType(dDFinH)

	If cTipo $ "D|C"
		self:dDFinH := IIF(cTipo == "D", dDFinH, CtoD(dDFinH))
		aRet := {.T., "SetDFinH"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFltrDH()
Método Get do Parâmetro lFltrDH

@Return lFltrDH	 	  Filtra Despesas? .T. / .F.
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetFltrDH() Class TJPREFATPARAM
Return self:lFltrDH

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFltrDH(lFltrDH)
Método SET do Parâmetro lFltrDH

@param lFltrDH	    		Filtra Despesas? .T. / .F.
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetFltrDH(lFltrDH) Class TJPREFATPARAM
	Local aRet := {.F., "SetFltrDH"}

	If ValType(lFltrDH) == "L"
		self:lFltrDH := lFltrDH
		aRet := {.T., "SetFltrDH"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFltrDO()
Método Get do Parâmetro lFltrDO

@Return lFltrDO	 	  Filtra Despesas do Faturamento Fixo? .T. / .F.
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetFltrDO() Class TJPREFATPARAM
Return self:lFltrDO

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFltrDO(lFltrDO)
Método SET do Parâmetro lFltrDO

@param lFltrDO	    		Filtra Despesas? .T. / .F.
@Return aRet	 	  			Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetFltrDO(lFltrDO) Class TJPREFATPARAM
	Local aRet := {.F., "SetFltrDO"}

	If ValType(lFltrDO) == "L"
		self:lFltrDO := lFltrDO
		aRet := {.T., "SetFltrDO"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDIniD()
Método Get do Parâmetro dDIniD

@Return dDIniD	 	  Data de Referência Inicial para Despesas
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetDIniD() Class TJPREFATPARAM
Return (self:dDIniD)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetDIniD(dDIniD)
Método SET do Parâmetro dDIniD

@param dDIniD	    		Data de Referência Inicial para Despesas
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetDIniD(dDIniD) Class TJPREFATPARAM
	Local aRet  := {.F., "SetDIniD"}
	Local cTipo := ValType(dDIniD)

	If cTipo $ "D|C"
		self:dDIniD := IIF(cTipo == "D", dDIniD, CtoD(dDIniD))
		aRet := {.T., "SetDIniD"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDFinD()
Método Get do Parâmetro dDFinD

@Return dDFinD	 	  Data de Referência Final para Despesas
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetDFinD() Class TJPREFATPARAM
Return (self:dDFinD)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetDFinD(dDFinD)
Método SET do Parâmetro dDFinD

@param dDFinD	    		Data de Referência Final para Despesas
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetDFinD(dDFinD) Class TJPREFATPARAM
	Local aRet := {.F., "SetDFinD"}
	Local cTipo := ValType(dDFinD)

	If cTipo $ "D|C"
		self:dDFinD := IIF(cTipo == "D", dDFinD, CtoD(dDFinD))
		aRet := {.T., "SetDFinD"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFltrTH()
Método Get do Parâmetro lFltrTH

@Return lFltrTH	 	  Filtra Lançamento Tabelado? .T. / .F.
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetFltrTH() Class TJPREFATPARAM
Return (self:lFltrTH)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFltrTH(lFltrTH)
Método SET do Parâmetro lFltrTH

@param lFltrTH	    		Filtra Lançamento Tabelado? .T. / .F.
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetFltrTH(lFltrTH) Class TJPREFATPARAM
	Local aRet := {.F., "SetFltrTH"}

	If ValType(lFltrTH) == "L"
		self:lFltrTH := lFltrTH
		aRet := {.T., "SetFltrTH"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFltrTO()
Método Get do Parâmetro lFltrTO

@Return lFltrTO	 	  Filtra Lançamento Tabelado do faturamento fixo? .T. / .F.
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetFltrTO() Class TJPREFATPARAM
Return (self:lFltrTO)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFltrTO(lFltrTO)
Método SET do Parâmetro lFltrTO

@param lFltrTO	    		Filtra Lançamento Tabelado do faturamento fixo? .T. / .F.
@Return aRet		 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetFltrTO(lFltrTO) Class TJPREFATPARAM
	Local aRet := {.F., "SetFltrTO"}

	If ValType(lFltrTO) == "L"
		self:lFltrTO := lFltrTO
		aRet := {.T., "SetFltrTO"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDIniT()
Método Get do Parâmetro dDIniT

@Return dDIniT	 	  Data de referência Inicial para Lançamento Tabelado
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetDIniT() Class TJPREFATPARAM
return (self:dDIniT)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetDIniT(dDIniT)
Método SET do Parâmetro dDIniT

@param dDIniT	    		Data de referência Inicial para Lançamento Tabelado
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetDIniT(dDIniT) Class TJPREFATPARAM
	Local aRet := {.F., "SetDIniT"}
	Local cTipo := ValType(dDIniT)

	If cTipo $ "D|C"
		self:dDIniT := IIF(cTipo == "D", dDIniT, CtoD(dDIniT))
		aRet := {.T., "SetDIniT"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDFinT()
Método Get do Parâmetro dDFinT

@Return dDFinT	 	  Data de referência Final para Lançamento Tabelado
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetDFinT() Class TJPREFATPARAM
Return (self:dDFinT)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetDFinT(dDFinT)
Método SET do Parâmetro dDFinT

@param dDFinT	    		Data de referência Final para Lançamento Tabelado
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetDFinT(dDFinT) Class TJPREFATPARAM
	Local aRet  := {.F., "SetDFinT"}
	Local cTipo := ValType(dDFinT)

	If cTipo $ "D|C"
		self:dDFinT := IIF(cTipo == "D", dDFinT, CtoD(dDFinT))
		aRet := {.T., "SetDFinT"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFltrFA()
Método Get do Parâmetro lFltrFA

@Return lFltrFA	 	  Filtra Fatura Adicional? .T. / .F.
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetFltrFA() Class TJPREFATPARAM
Return (self:lFltrFA)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFltrFA
Método SET do Parâmetro lFltrFA

@param lFltrFA	    		Filtra Fatura Adicional? .T. / .F.
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetFltrFA(lFltrFA) Class TJPREFATPARAM
	Local aRet := {.F., "SetFltrFA"}

	If ValType(lFltrFA) == "L"
		self:lFltrFA := lFltrFA
		aRet := {.T., "SetFltrFA"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDInIFA()
Método Get do Parâmetro dDInIfA

@Return dDInIfA	 	  Data de referência Inicial para Fatura Adicional
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetDInIFA() Class TJPREFATPARAM
Return (self:dDInIFA)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetDInIfA(dDInIfA)
Método SET do Parâmetro dDInIfA

@param dDInIfA	    		Data de referência Inicial para Fatura Adicional
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetDInIfA(dDInIfA) Class TJPREFATPARAM
	Local aRet  := {.F., "SetDInIfA"}
	Local cTipo := ValType(dDInIfA)

	If cTipo $ "D|C"
		self:dDInIfA := IIF(cTipo == "D", dDInIfA, CtoD(dDInIfA))
		aRet := {.T., "SetDInIfA"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDFinFA()
Método Get do Parâmetro dDFinFA

@Return dDFinFA	 	  Data de referência Final para Fatura Adicional
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetDFinFA() Class TJPREFATPARAM
Return (self:dDFinFA)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetDFinFA(dDFinFA)
Método SET do Parâmetro dDFinFA

@param dDFinFA	    		Data de referência Final para Fatura Adicional
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetDFinFA(dDFinFA) Class TJPREFATPARAM
	Local aRet  := {.F., "SetDFinFA"}
	Local cTipo := ValType(dDFinFA)

	If cTipo $ "D|C"
		self:dDFinFA := IIF(cTipo == "D", dDFinFA, CtoD(dDFinFA))
		aRet := {.T., "SetDFinFA"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFltrFxNc
Método Get do Parâmetro lFltrFxNc

@Return lFltrFxNc, Filtra TSs de Contrato de Fixo ou Não Cobrável? .T. / .F.

@author Jonatas Martins / Jorge Martins
@since  22/03/2022
/*/
//-------------------------------------------------------------------
Method GetFltrFxNc() Class TJPREFATPARAM
Return (self:lFltrFxNc)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFltrFxNc
Método SET do Parâmetro lFltrFxNc

@param  lFltrFxNc, Filtra TSs de Contrato de Fixo ou Não Cobrável? .T. / .F.
@Return aRet     , Parâmetro setado com sucesso? .T. / .F.

@author Jonatas Martins / Jorge Martins
@since  22/03/2022
/*/
//-------------------------------------------------------------------
Method SetFltrFxNc(lFltrFxNc) Class TJPREFATPARAM
	Local aRet := {.F., "SetFltrFxNc"}

	If ValType(lFltrFxNc) == "L"
		self:lFltrFxNc := lFltrFxNc
		aRet := {.T., "SetFltrFxNc"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDInIFxNc
Método Get do Parâmetro dDInIFxNc

@Return dDInIFxNc, Data de referência Inicial para TSs de Contrato de Fixo ou Não Cobrável

@author Jonatas Martins / Jorge Martins
@since  22/03/2022
/*/
//-------------------------------------------------------------------
Method GetDInIFxNc() Class TJPREFATPARAM
Return (self:dDInIFxNc)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetDInIFxNc
Método SET do Parâmetro dDInIFxNc

@param  dDInIFxNc, Data de referência Inicial para TSs de Contrato de Fixo ou Não Cobrável
@Return aRet     , Parâmetro setado com sucesso? .T. / .F.

@author Jonatas Martins / Jorge Martins
@since  22/03/2022
/*/
//-------------------------------------------------------------------
Method SetDInIFxNc(dDInIFxNc) Class TJPREFATPARAM
	Local aRet  := {.F., "SetDInIFxNc"}
	Local cTipo := ValType(dDInIFxNc)

	If cTipo $ "D|C"
		self:dDInIFxNc := IIF(cTipo == "D", dDInIFxNc, CtoD(dDInIFxNc))
		aRet := {.T., "SetDInIFxNc"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDFinFxNc
Método Get do Parâmetro dDFinFxNc

@Return dDFinFxNc, Data de referência Final para TSs de Contrato de Fixo ou Não Cobrável

@author Jonatas Martins / Jorge Martins
@since  22/03/2022
/*/
//-------------------------------------------------------------------
Method GetDFinFxNc() Class TJPREFATPARAM
Return (self:dDFinFxNc)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetDFinFxNc
Método SET do Parâmetro dDFinFxNc

@param dDFinFxNc, Data de referência Final para TSs de Contrato de Fixo ou Não Cobrável
@Return aRet    , Parâmetro setado com sucesso? .T. / .F.

@author Jonatas Martins / Jorge Martins
@since  22/03/2022
/*/
//-------------------------------------------------------------------
Method SetDFinFxNc(dDFinFxNc) Class TJPREFATPARAM
	Local aRet  := {.F., "SetDFinFxNc"}
	Local cTipo := ValType(dDFinFxNc)

	If cTipo $ "D|C"
		self:dDFinFxNc := IIF(cTipo == "D", dDFinFxNc, CtoD(dDFinFxNc))
		aRet := {.T., "SetDFinFxNc"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSocio()
Método Get do Parâmetro cSocio

@Return cSocio	 	  Sócio responsável
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetSocio() Class TJPREFATPARAM
Return (self:cSocio)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetSocio(cSocio)
Método SET do Parâmetro cSocio

@param cSocio	    		Sócio responsável
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetSocio(cSocio) Class TJPREFATPARAM
	Local aRet := {.F., "SetSocio"}

	self:cSocio := cSocio
	aRet := {.T., "SetSocio"}

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMoeda()
Método Get do Parâmetro cMoeda

@Return cMoeda	 	  Moeda
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetMoeda() Class TJPREFATPARAM
Return (self:cMoeda)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetMoeda(cMoeda)
Método SET do Parâmetro cMoeda

@param cMoeda	    		Moeda
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetMoeda(cMoeda) Class TJPREFATPARAM
	Local aRet := {.F., "SetMoeda"}

	self:cMoeda := cMoeda
	aRet := {.T., "SetMoeda"}

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCliente()
Método Get do Parâmetro cCliente

@Return cCliente	 	  Cliente
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetCliente()Class TJPREFATPARAM
Return (self:cCliente)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetCliente(cCliente)
Método SET do Parâmetro cCliente

@param cCliente	    		Cliente
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetCliente(cCliente) Class TJPREFATPARAM
	Local aRet := {.F., "SetCliente"}

	self:cCliente := cCliente
	aRet := {.T., "SetCliente"}

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetLoja()
Método Get do Parâmetro cLoja

@Return cLoja	 	  Loja
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetLoja() Class TJPREFATPARAM
Return (self:cLoja)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetLoja(cLoja)
Método SET do Parâmetro cLoja

@param cLoja	    		Loja
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetLoja(cLoja) Class TJPREFATPARAM
	Local aRet := {.F., "SetLoja"}

	self:cLoja := cLoja
	aRet := {.T., "SetLoja"}

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCasos()
Método Get do Parâmetro cCasos

@Return cCasos	 	  Lista de Casos separados por ';'
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetCasos() Class TJPREFATPARAM
Return (self:cCasos)

//-------------------------------------------------------------------
/*/{Protheus.doc}  SetCasos(cCasos)
Método SET do Parâmetro cCasos

@param cCasos	    		Lista de Casos separados por ';'
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetCasos(cCasos) Class TJPREFATPARAM
	Local aRet    := {.T., "SetCasos"}

	If !Empty(cCasos)
		self:cCasos := CodToSqlIn(cCasos, 'NVE_NUMCAS')
	Else
		aRet := {.F., "SetCasos"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTDCasos()
Método Get do Parâmetro lTDCasos

@Return lTDCasos	 	  Transfere todos os Casos Vinculados?
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetTDCasos() Class TJPREFATPARAM
Return (self:lTDCasos)

//-------------------------------------------------------------------
/*/{Protheus.doc}  SetCasos(cCasos)
Método SET do Parâmetro cCasos

@param cCasos	    		Transfere todos os Casos vinculados?
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetTDCasos(lTDCasos) Class TJPREFATPARAM
	Local aRet := {.F., "SetTDCasos"}

	If ValType(lTDCasos) == "L"
		self:lTDCasos := lTDCasos
		aRet := {.T., "SetTDCasos"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetGrpCli()
Método Get do Parâmetro cGrpCli

@Return cGrpCli	 	  Grupo de Cliente
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetGrpCli() Class TJPREFATPARAM
Return (self:cGrpCli)

//-------------------------------------------------------------------
/*/{Protheus.doc}  SetGrpCli(cGrpCli)
Método SET do Parâmetro cGrpCli

@param cGrpCli	    		Grupo de Cliente
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetGrpCli(cGrpCli) Class TJPREFATPARAM
	Local aRet := {.F., "SetGrpCli"}

	self:cGrpCli := cGrpCli
	aRet := {.T., "SetGrpCli" }

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetContrato()
Método Get do Parâmetro cContrato

@Return cContrato	 	  Contrato
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetContrato() Class TJPREFATPARAM
Return (self:cContrato)

//-------------------------------------------------------------------
/*/{Protheus.doc}  SetContrato(cContrato)
Método SET do Parâmetro cContrato

@param cContrato  Código do Contrato
@Return aRet      Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetContrato(cContrato) Class TJPREFATPARAM
	Local aRet    := {.T., "SetContrato"}

	If !Empty(cContrato)
		self:cContrato := CodToSqlIn(cContrato, 'NT0_COD')
	Else
		aRet := {.F., "SetContrato"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTDContr()
Método Get do Parâmetro lTDContr

@Return cContrato	 	  lTDContr
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetTDContr() Class TJPREFATPARAM
Return (self:lTDContr)

//-------------------------------------------------------------------
/*/{Protheus.doc}  SetContrato(cContrato)
Método SET do Parâmetro cContrato

@param cContrato   Todos os contratos vinculados?
@Return aRet       Parâmetro setado com sucesso? .T. / .F.

@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetTDContr(lTDContr) Class TJPREFATPARAM
	Local aRet := {.F., "SetTDContr"}

	If ValType(lTDContr) == "L"
		self:lTDContr := lTDContr
		aRet := {.T., "'"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetExceto()
Método Get do Parâmetro cExceto

@Return cExceto	 	  Lista de excessão de casos, separados por ';'
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetExceto() Class TJPREFATPARAM
Return (self:cExceto)

//-------------------------------------------------------------------
/*/{Protheus.doc}  SetExceto(cExceto)
Método SET do Parâmetro cExceto

@param  cExceto   Lista de excessão de cliente, separados por ';'
@Return aRet      Parâmetro setado com sucesso? .T. / .F.

@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetExceto(cExceto) Class TJPREFATPARAM
	Local aRet    := {.T., "SetExceto"}

	If !Empty(cExceto)
		self:cExceto := CodToSqlIn(cExceto, 'A1_COD')
	Else
		aRet := {.F., "SetExceto"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetExcSoc()
Método Get do Parâmetro cExcSoc

@Return cExcSoc  Lista de excessão de sócios do(s) caso(s), separados por ';'
@author Jorge Martins
@since 06/02/17
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetExcSoc() Class TJPREFATPARAM
Return (self:cExcSoc)

//-------------------------------------------------------------------
/*/{Protheus.doc}  SetExcSoc(cExcSoc)
Método SET do Parâmetro cExceto

@param cExcSoc  Lista de excessão de sócios do(s) caso(s), separados por ';'
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Jorge Martins
@since 06/02/17
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetExcSoc(cExcSoc) Class TJPREFATPARAM
	Local aRet    := {.T., "SetExcSoc"}
	Local cTmpCod := ""
	Local cPart   := ""
	Local aExcSoc := StrTokArr(AllTrim(cExcSoc), ";")
	Local nI      := 0

	If Len(aExcSoc) > 0
		For nI := 1 To Len(aExcSoc)
			cPart := JurGetDados('RD0', 9, xFilial('RD0') + aExcSoc[nI], 'RD0_CODIGO')
			If !Empty(cPart)
				cTmpCod += cPart + Iif(Len(aExcSoc) != nI, "','", "")
			EndIf
		Next

		If !Empty(cTmpCod)
			self:cExcSoc := "'" + cTmpCod + "'"
		Else
			aRet := {.F., "SetExcSoc"}
		EndIf

		JurFreeArr(@aExcSoc)

	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSitSoc()
Método Get do Parâmetro cSitSoc

@Return cSitSoc  Situação do cadastro do(s) sócios do(s) caso(s) para filtro
@author Jorge Martins
@since 06/02/17
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetSitSoc() Class TJPREFATPARAM
Return (self:cSitSoc)

//-------------------------------------------------------------------
/*/{Protheus.doc}  SetSitSoc(cExcSoc)
Método SET do Parâmetro cExceto

@param cSitSoc  Situação do cadastro do(s) sócios do(s) caso(s) para filtro
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Jorge Martins
@since 06/02/17
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetSitSoc(cSitSoc) Class TJPREFATPARAM
	Local aRet := {.F., "SetSitSoc"}

	If Empty(cSitSoc)
		self:cSitSoc := ""
	Else
		self:cSitSoc := cSitSoc
	EndIf

	aRet := {.T., "SetSitSoc"}

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetEscrit()
Método Get do Parâmetro cEscrit

@Return cEscrit	 	  Escritório
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetEscrit() Class TJPREFATPARAM
Return (self:cEscrit)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTipoDP(cTipoDP)
Método SET do Parâmetro cTipoDP

@param cEscrit	    		Tipo de Despesa
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetEScrit(cEscrit) Class TJPREFATPARAM
	Local aRet := {.F., "SetEScrit"}

	self:cEscrit := cEscrit
	aRet := {.T., "SetEScrit"}

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTipoDP()
Método Get do Parâmetro cTipoDP

@Return cTipoDP	 	  Tipo de Despesa
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetTipoDP() Class TJPREFATPARAM
Return (self:cTipoDP)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTipoDP(cTipoDP)
Método SET do Parâmetro cTipoDP

@param cTipoDP   Tipo de Despesa
@Return aRet     Parâmetro setado com sucesso? .T. / .F.

@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetTipoDP(cTipoDP) Class TJPREFATPARAM
	Local aRet    := {.T., "SetTipoDP"}

	If !Empty(cTipoDP)
		self:cTipoDP := CodToSqlIn(cTipoDP, 'NRH_COD')
	Else
		aRet := {.F., "SetTipoDP"}
	EndIf

Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetChkPend(lChkPend)
Método Get do Parâmetro lChkPend

@Return lChkPend	 	  Emitir Tudo pendente? .T. / .F.
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetChkPend() Class TJPREFATPARAM
Return (self:lChkPend)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetChkPend(lChkPend)
Método SET do Parâmetro lChkPend

@param lChkPend	    		Emitir Tudo pendente? .T. / .F.
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetChkPend(lChkPend) Class TJPREFATPARAM
	Local aRet := {.F., "SetChkPend"}

	If ValType(lChkPend) == "L"
		self:lChkPend := lChkPend
		aRet := {.T., "SetChkPend"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetChkFech
Método Get do Parâmetro lChkFech que retonarna a flag do tipo de 
fechamento

@return lChkFech, logico, Flag do Tipo de fechamento
@author Jonatas Martins
@since  08/05/2020
/*/
//-------------------------------------------------------------------
Method GetChkFech() Class TJPREFATPARAM
Return (self:lChkFech)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetChkFech
Método Set do Parâmetro lChkFech que retonarna a flag o tipo de 
fechamento

@Return lChkFech, logico, Tipo de fechamento
@author Jonatas Martins
@since  08/05/2020
/*/
//-------------------------------------------------------------------
Method SetChkFech(lChkFech) Class TJPREFATPARAM
	Local aRet := {.F., "SetTipoFech"}

	If ValType(lChkFech) == "L"
		self:lChkFech := lChkFech
		aRet := {.T., "SetChkFech"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTipoFech
Método Get do Parâmetro cTipoFech que retonarna o tipo de 
fechamento

@Return cTipoFech, caractere, Tipo de fechamento
@author Jonatas Martins
@since  08/05/2020
/*/
//-------------------------------------------------------------------
Method GetTipoFech() Class TJPREFATPARAM
Return (self:cTipoFech)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTipoFech
Método Set do Parâmetro cTipoFech que retonarna o tipo de 
fechamento

@Return cTipoFech, caractere, Tipo de fechamento
@author Jonatas Martins
@since  08/05/2020
/*/
//-------------------------------------------------------------------
Method SetTipoFech(cTipoFech) Class TJPREFATPARAM
	Local aRet := {.T., "SetTipoFech"}

	If !Empty(cTipoFech)
		Self:cTipoFech := CodToSqlIn(cTipoFech, 'OHU_CODIGO')
	Else
		aRet := {.F., "SetTipoFech"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTipoHon()
Método Get do Parâmetro cTipoHon

@Return cTipoHon	 	  Tipo de Honorários
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetTipoHon() Class TJPREFATPARAM
Return (self:cTipoHon)

//-------------------------------------------------------------------
/*/{Protheus.doc}  SetTipoHon(cTipoHon)
Método SET do Parâmetro cTipoHon

@param cTipoHon	    	Tipo de Honorários
@Return aRet	 	  	Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetTipoHon(cTipoHon) Class TJPREFATPARAM
	Local aRet := {.F., "SetSituac"}

	If !Empty(cTipoHon)
		self:cTipoHon := CodToSqlIn(cTipoHon, 'NT0_CTPHON')
		aRet := {.T., "SetSituac"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSituac(
Método Get do Parâmetro cSituac

@Return cSituac	 	  Situação que será emitida a pré
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetSituac() Class TJPREFATPARAM
Return (self:cSituac)

//-------------------------------------------------------------------
/*/{Protheus.doc}  SetSituac(cSituac)
Método SET do Parâmetro cSituac

@param cSituac	    	Situação que será emitida a pré
@Return aRet	 	  	Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetSituac(cpSituac) Class TJPREFATPARAM
	Local aRet := {.F., "SetSituac"}
	Local cSituac := cpSituac

	If ValType(cSituac) == "N"
		cSituac := Strzero(cSituac,1)
	EndIf

	If Empty(cSituac) .Or. cSituac $ '123456'
		self:cSituac := cSituac
		aRet := {.T., "SetSituac"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTipRel()
Método Get do Parâmetro cTipoRel

@Return cTipoRel	 	  Tipo do relatório que será emitida a pré
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetTipRel() Class TJPREFATPARAM
Return (self:cTipoRel)

//-------------------------------------------------------------------
/*/{Protheus.doc}  SetTipRel(cTipoRel)
Método SET do Parâmetro cTipoRel

@param cTipoRel	    	Tipo do relatório que será emitida a pré
@Return aRet	 	  	Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetTipRel(cTipoRel) Class TJPREFATPARAM
Local aRet := {.F., "SetTipRel"}

self:cTipoRel := cTipoRel
aRet := {.T., "SetTipRel"}

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetChkApaga()
Método Get do Parâmetro lChkApaga

@Return lChkApaga	 	  Apagar / Substituir Pré-Faturas existentes? .T. / .F.
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetChkApaga() Class TJPREFATPARAM
Return (self:lChkApaga)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetChkApaga(lChkApaga)
Método SET do Parâmetro lChkApaga

@param lChkApaga	    Apagar / Substituir Pré-Faturas existentes? .T. / .F.
@Return aRet	 	  	Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetChkApaga(lChkApaga) Class TJPREFATPARAM
	Local aRet := {.F., "SetChkApaga"}

	If ValType(lChkApaga) == "L"
		self:lChkApaga := lChkApaga
		aRet := {.T., "SetChkApaga"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetChkApaMP()
Método Get do Parâmetro lChkApaMP

@Return lChkApaMP	 	  Apagar / Substituir Minuta de Pré-Faturas existentes? .T. / .F.
@author Jorge Martins
@since 07/02/17
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetChkApaMP() Class TJPREFATPARAM
Return (self:lChkApaMP)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetChkApaMP(lChkApaMP)
Método SET do Parâmetro lChkApaMP

@param lChkApaMP	    Apagar / Substituir Minuta de Pré-Faturas existentes? .T. / .F.
@Return aRet	 	  	Parâmetro setado com sucesso? .T. / .F.
@author Jorge Martins
@since 07/02/17
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetChkApaMP(lChkApaMP) Class TJPREFATPARAM
	Local aRet := {.F., "SetChkApaMP"}

	If ValType(lChkApaMP) == "L"
		self:lChkApaMP := lChkApaMP
		aRet := {.T., "SetChkApaMP"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetChkCorr()
Método Get do Parâmetro lChkCorr

@Return lChkCorr  Corrige valor base do(s) contrato(s) fixo(s)? .T. / .F.
@author Jorge Martins
@since 07/02/17
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetChkCorr() Class TJPREFATPARAM
Return (self:lChkCorr)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetChkCorr(lChkCorr)
Método SET do Parâmetro lChkCorr

@param lChkCorr  Corrige valor base do(s) contrato(s) fixo(s)? .T. / .F.
@Return aRet	 	  	Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetChkCorr(lChkCorr) Class TJPREFATPARAM
	Local aRet := {.F., "SetChkCorr"}

	If ValType(lChkCorr) == "L"
		self:lChkCorr := lChkCorr
		aRet := {.T., "SetChkCorr"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTpExec()
Método Get do Parâmetro cTpExec

@param cTpExec	 	  Tipo de execução da rotina de faturamento:
						1 - Emissão de Pré-Fatura
						2 - Reemissão Pré-fatura
						3 - Emissão de Minuta Pré
						4 - Emissão de Minuta Fatura
						5 - Emissão de Fatura
						6 - Reemissão de Pré-fatura (Por cancelamento de fatura)
						**7 - Emissão de Relatório de Conferência (não existe isso)
@Return aRet	 	  	Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetTpExec() Class TJPREFATPARAM
Return (self:cTpExec)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTpExec(cTpExec)
Método SET do Parâmetro cTpExec

@param 	cTpExec		  	Tipo de execução da rotina de faturamento:
						1 - Emissão de Pré-Fatura
						2 - Reemissão Pré-fatura
						3 - Emissão de Minuta Pré
						4 - Emissão de Minuta Fatura
						5 - Emissão de Fatura
						6 - Reemissão da Pré ao Cancelar a Fatura
						MS - Minuta Sócio
@Return aRet	 	  	Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetTpExec(cTpExec) Class TJPREFATPARAM
	Local aRet := {.F., "SetTpExec"}

	If Empty(cTpExec) .Or. Pertence('1|2|3|4|5|6|7|MS',cTpExec)
		self:cTpExec := cTpExec
		aRet := {.T., "SetTpExec"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDEmi()
Método Get do Parâmetro dDAtual

@Return dDAtual	 	  Data da emissão
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetDEmi() Class TJPREFATPARAM
Return (self:dDAtual)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetDEmi(dDAtual)
Método SET do Parâmetro dDAtual

@param 	dDAtual		  	Data da emissão
@Return aRet	 	  	Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetDEmi(dDAtual) Class TJPREFATPARAM
	Local aRet := {.F., "SetDEmi"}

	If ValType(dDAtual) == "D"
		self:dDAtual := dDAtual
		aRet := {.T., "SetDEmi"}
	EndIf
	If Empty(dDAtual)
		self:dDAtual := Date()
		aRet := {.T., "SetDEmi"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTipoFat()
Método Get do Parâmetro cTipoFat

@Return cTipoFat	 	  1 - Fatura / 2 - Minuta de Fatura / 3 - Minuta de Pré-fatura

@author Luciano Pereira dos Santos
@since 01/12/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetcTipoFat() Class TJPREFATPARAM
Return (self:cTipoFat)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTipoFat(cTipoFat)
Método SET do Parâmetro cTipoFat

@param cTipoFat	    		1 - Fatura / 2 - Minuta de Fatura / 3 - Minuta de Pré-fatura
@Return aRet	 	  		Parâmetro setado com sucesso? .T. / .F.

@author Luciano Pereira dos Santos
@since 01/12/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetcTipoFat(cTipoFat) Class TJPREFATPARAM
	Local aRet := {.F., "SetTipoFat"}

	If Empty(cTipoFat) .Or. (cTipoFat $ "1|2|3|4" )
		self:cTipoFat := cTipoFat
		aRet := {.T., "SetTipoFat"}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPreFat()
Método Get do Parâmetro cPreFat

@Return cPreFat	 	  Número da pré-fatura (para reemissão)
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetPreFat() Class TJPREFATPARAM
Return (self:cPreFat)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetPreFat(cPreFat)
Método SET do Parâmetro cPreFat

@param 	cPreFat		  	Número da pré-fatura (para reemissão)
@Return aRet	 	  	Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetPreFat(cPreFat) Class TJPREFATPARAM
	Local aRet := {.F., "SetPreFat"}

	self:cPreFat := cPreFat
	aRet := {.T., "SetPreFat"}

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPreFat()
Método Get do Parâmetro cCodFilaImp

@Return cPreFat	 	  Código da Fila de emissão (para Emissão de Fatura ou minuta)
@author David G. Fernandes
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetCFilaImpr() Class TJPREFATPARAM
Return (self:cCodFilaImp)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetPreFat(cPreFat)
Método SET do Parâmetro cCodFilaImp

@param 	cPreFat		  	Código da Fila de emissão (para Emissão de Fatura ou minuta)
@Return aRet	 	  	Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetCFilaImpr(cCodFilaImp) Class TJPREFATPARAM
	Local aRet := {.F., "SetPreFat"}

	self:cCodFilaImp := cCodFilaImp
	aRet := {.T., "SetPreFat"}

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCodFatur()
Método SET do Parâmetro cFatura

@param 	cFatura		  	Código da Fatura que será
						utilizada como base para reemitir a pré-fatura
@Return aRet	 	  	Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetCodFatur() Class TJPREFATPARAM
Return (self:cFatura)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetCodFatur(cFatura)
Método SET do Parâmetro cFatura

@param 	cFatura		  	Código da Fatura que será
						utilizada como base para reemitir a pré-fatura
@Return aRet	 	  	Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetCodFatur(cFatura) Class TJPREFATPARAM
	Local aRet := {.F., "SetCodFatur"}

	self:cFatura := cFatura
	aRet := {.T., "SetCodFatur"}

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCodEscr()
Método Get do Parâmetro cEscr

@param 	cEscr		  	Código do Escritório da Fatura que será
						utilizada como base para reemitir a pré-fatura
@Return aRet	 	  	Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetCodEscr() Class TJPREFATPARAM
Return (self:cEscr)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetCodEscr(cEscr)
Método SET do Parâmetro cEscr

@param 	cEscr		  	Código do Escritório da Fatura que será
						utilizada como base para reemitir a pré-fatura
@Return aRet	 	  	Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetCodEscr(cEscr) Class TJPREFATPARAM
	Local aRet := {.F., "SetCodEscr"}

	self:cEscr := cEscr
	aRet := {.T., "SetCodEscr"}

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetaParams()

@author Felipe Bonvicini Conti
@since 12/09/11
/*/
//-------------------------------------------------------------------
Method GetParams() Class TJPREFATPARAM
Return self:aParams

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParams(aParams)

@author Felipe Bonvicini Conti
@since 12/09/11
/*/
//-------------------------------------------------------------------
Method SetParams(aParams) Class TJPREFATPARAM
	Local aRet := {.T., "SetParams"}

	If ValType(aParams) == "A"
		self:aParams := aParams
	Else
		aRet := {.F., "SetParams"}
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFatSub()
Método GET do Parâmetro cFatSub

@param 	cFatSub		  	Código da Fatura Substituida

@Return aRet	 	  	Parâmetro setado com sucesso? .T. / .F.

@author Luciano Pereira dos Santos
@since 04/05/12
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetFatSub() Class TJPREFATPARAM
Return (self:cFatSub)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFatSub(cFatSub)
Método SET do Parâmetro cFatura

@param 	cFatSub		  	Código da Fatura Substituida

@Return aRet	 	  	Parâmetro setado com sucesso? .T. / .F.

@author Luciano Pereira dos Santos
@since 04/05/12
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetFatSub(cFatSub) Class TJPREFATPARAM
	Local aRet := {.F., "SetFatSub"}

	self:cFatSub := cFatSub
	aRet := {.T., "SetFatSub"}

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCodEscr()
Método Get do Parâmetro cEscr

@param 	cEscSub		  	Código do Escritório da Fatura Substituida

@Return aRet	 	  	Parâmetro setado com sucesso? .T. / .F.

@author Luciano Pereira dos Santos
@since 04/05/12
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetEscSub() Class TJPREFATPARAM
Return (self:cEscSub)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetEscSub(cEscSub)
Método SET do Parâmetro cEscr

@param 	cEscSub		  	Código do Escritório da Fatura que será
						utilizada como base para reemitir a pré-fatura
@Return aRet	 	  	Parâmetro setado com sucesso? .T. / .F.

@author Luciano Pereira dos Santos
@since 04/05/12
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetEscSub(cEscSub) Class TJPREFATPARAM
	Local aRet := {.F., "SetEscSub"}

	self:cEscSub := cEscSub
	aRet := {.T., "SetEscSub"}

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidInf()
Método de validação dos parâmetros

@Return aRet	 	 Validação OK? .T. / .F.
@author Luciano Pereira
@since 13/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method ValidInf() Class TJPREFATPARAM
	Local aRet := {.T., "ValidInf"}

	If aRet[1] .And. ((Self:GetFltrHH()) .Or. (Self:GetFltrTH()).Or.(Self:GetFltrDH()) .Or. (Self:GetFltrHO())) .And. (Self:GetFltrFA())
		aRet := {.F., "ValidInf - " + STR0001}
	EndIf

	If  aRet[1] .And. !Empty(Self:GetLoja()) .And. Empty(self:GetCliente())
		MsgStop(STR0003)  //"Informe o código do cliente!"
		aRet := {.F., "ValidInf - " + STR0003}
	EndIf

	If  aRet[1] .And. !Empty(self:GetCliente()) .And. Empty(Self:GetLoja())
		MsgStop(STR0004)  //"Informe o código da loja!"
		aRet := {.F., "ValidInf - " + STR0004}
	EndIf

	If aRet[1] .And. (SuperGetMV("MV_JCASO1",, "1") == "1") .And. Empty(self:GetCasos()) .And. Empty(Self:GetLoja())
		MsgStop(STR0005)  //"Informe o código do cliente e loja!"
		aRet := {.F., "ValidInf - " + STR0005}
	EndIf

	If aRet[1] .And. !Empty(self:GetExceto()) .And. !Empty(self:GetCliente()) .And. !Empty(Self:GetLoja())
		MsgStop(STR0010)  //"Não é possivel usar ao mesmo tempo os filtros de cliente e exceção de cliente!"
		aRet := {.F., "ValidInf - " + STR0010}
	EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} EventInsert()
Método de inserção de evento.

@Return aRet	 	 Validação OK? .T. / .F.
@author Felipe Bonvicini Conti
@since 06/11/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method EventInsert(nEventID, cpMsg, nLevel) Class TJPREFATPARAM
Local aRet       := {.T., "EventInsert"}
Local cChannel   := FW_EV_CHANEL_ENVIRONMENT
Local cCateg     := FW_EV_CATEGORY_MODULES
Local cEventID   := ""
Local cTitle     := ""
Local cMessage   := ""
Local lPublic    := .F.

Default nEventID := 1
Default cpMsg    := ""
Default nLevel   := 1 // 1 = FW_EV_LEVEL_INFO // 2 = FW_EV_LEVEL_WARNING // 3 = FW_EV_LEVEL_ERROR

	cEventID := IIF(nEventID == 1, "054", "055")
	cTitle   := IIF(cEventID == "054", STR0012, STR0013) //"Emissão de Pré-Fatura" e "Emissão de fatura"

	If Empty(cpMsg)
		cMessage := STR0014 //"Processando"
	Else
		cMessage := cpMsg
	EndIf

	EventInsert( cChannel, cCateg, cEventID, nLevel, Self:GetMarkEsc(), cTitle, cMessage, lPublic )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetIsThread()

@author Felipe Bonvicini Conti
@since 12/09/11
/*/
//-------------------------------------------------------------------
Method SetIsThread(lIsThread) Class TJPREFATPARAM
Return ::lIsThread := lIsThread

//-------------------------------------------------------------------
/*/{Protheus.doc} IsThread()

@author Felipe Bonvicini Conti
@since 12/09/11
/*/
//-------------------------------------------------------------------
Method IsThread() Class TJPREFATPARAM
Return ::lIsThread

//-------------------------------------------------------------------
/*/{Protheus.doc} RandMark()
Gera uma marca aleatória por meio da função Randomize()

@Param	nMarkTam	Tamanho da marca

@Retun	cMark		Marca gerada por número aleatório

@author Luciano Pereira dos Santos
@since 23/11/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static function RandMark(nMarkTam)
	Local cMark      := ""
	Local nI         := 0

	Default nMarkTam := 2

	For nI := 1 to nMarkTam
		If (Randomize(0,100)%2 == 0)
			cMark := cMark + chr(Randomize(97,123))
		Else
			cMark := cMark + chr(Randomize(48,58) )
		EndIf
	Next nI

Return cMark

//-------------------------------------------------------------------
/*/{Protheus.doc} CodToSqlIn(cCods, cCampo)
Transforma uma cadeia de codigos separados por ";" em uma cadeira de codigos
para condição Sql IN.

@Param cCods  Cadeia de codigos para ser transformada 000001;000002
@Param cCampo Nome do campo referente a cadeia de codigos Ex: A1_COD

@Return cRet   Cadeia de codigos com aspas simples e separados por "," Ex: '000001','000002'

@author Luciano Pereira dos Santos
@since 18/12/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CodToSqlIn(cCods, cCampo)
	Local cRet    := ""
	Local aCods   := StrTokArr(AllTrim(cCods), ";")
	Local nTamCod := TamSX3(cCampo)[1]
	Local nI      := 0

	If Len(aCods) > 0
		For nI := 1 To Len(aCods)
			cCod := PadR(aCods[nI], nTamCod, " ") //Tratamento de espaços p/ Oracle
			If !Empty(cCod)
				cRet += cCod + Iif(Len(aCods) != nI, "','", "")
			EndIf
		Next nI

		If !Empty(cRet)
			cRet := "'" + cRet + "'"
		EndIf

		JurFreeArr(@aCods)

	EndIf

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} AddLog()
Metodo para alimentar o Log da emissao da Pre/Fatura

@Param	cNewMsg		Mensagem a ser adicionada ao log

@Retun	lRet		Mensagem adicionada? T/F

@author Daniel Magalhaes
@since 12/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Method AddLog(cNewMsg) Class TJPREFATPARAM
	Local lRet := .F.

	If ValType(cNewMsg) == "C"
		AAdd(self:aMsgs, cNewMsg)
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetLog()
Metodo para recuperar o array com o Log da emissao da Pre/Fatura

@param	nil

@return	aRet	Array com as mensagens de log gravadas

@author Daniel Magalhaes
@since 12/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetLog() Class TJPREFATPARAM
	Local aRet := {}

	aRet := self:aMsgs

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetLog()
Metodo para apresentar uma tela apresentando o conteudo do log

@param	nil

@return	lRet	Existem itens no log? T/F

@author Daniel Magalhaes
@since 12/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Method ShowLog() Class TJPREFATPARAM
	Local lRet     := .F.
	Local aPages   := {}
	Local cPageTmp := ""
	Local nIdx     := 0

	lRet := Len(self:aMsgs) > 0

	If lRet

		For nIdx := 1 To Len(self:aMsgs)
			If Len(cPageTmp) + Len(self:aMsgs[nIdx]) > 1048575 //tamanho maximo de string alocado pelo Protheus
				AAdd(aPages, cPageTmp)
				cPageTmp := self:aMsgs[nIdx]
			Else
				cPageTmp += If(Len(cPageTmp) > 0, CRLF, "") + self:aMsgs[nIdx]
			EndIf

		Next nIdx

		If Len(cPageTmp) > 0
			AAdd(aPages, cPageTmp)
			cPageTmp := ""
		EndIf

		PreFtMsgDlg(STR0022, aPages) // "Log da emissão"

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetQueryPre() Class TJPREFATPARAM
Metodo para montar a query da emissão de préfatura

@Retun	cRet	Query

@author Felipe Bonvicini Conti
@since 22/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetQueryPre() Class TJPREFATPARAM

	Self:cQueryPre := ""

	If self:GetFltrFA()
		Self:cQueryPre := JA201AFA(self)

	Else
		Self:GeraTmpContrato()

		If self:GetFltrHH() .Or. self:GetFltrFxNc() // Honorários ou TSs de Contratos Fixos ou Não Cobráveis
			Self:cQueryPre := JA201ATS(self)
		EndIf

		If self:GetFltrTH() .Or. self:GetFltrTO()
			If !Empty(Self:cQueryPre)
				Self:cQueryPre := Self:cQueryPre + " UNION ALL "
			EndIf
			Self:cQueryPre := Self:cQueryPre + JA201ALT(self)
		EndIf

		If self:GetFltrDH() .Or. self:GetFltrDO()
			If !Empty(Self:cQueryPre)
				Self:cQueryPre := Self:cQueryPre + " UNION ALL "
			EndIf
			Self:cQueryPre := Self:cQueryPre + JA201ADP(self)
		EndIf

		If self:GetFltrHO()
			If !Empty(Self:cQueryPre)
				Self:cQueryPre := Self:cQueryPre + " UNION ALL "
			EndIf
			Self:cQueryPre := Self:cQueryPre + JA201AFX(self)
		EndIf

		If !Empty(Self:cQueryPre)
			Self:cQueryPre := Self:cQueryPre + " UNION ALL "
		EndIf

		Self:cQueryPre := Self:cQueryPre + JA201ALM(self)

	EndIf

Return Self:cQueryPre

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCONTRS
Monta array de contratos da pré-fatura

@Return  aContratos, array de contratos

@author  Felipe Bonvicini Conti
@since   22/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetCONTRS() Class TJPREFATPARAM
	Local aSQL      := {}
	Local nI        := 0
	Local nQtd      := 0
	Local aAUX      := aClone(Self:aContratos)

	If Empty(aAUX)
		aSQL := JurSQL(Self:GetQueryPre(), {"NT0_COD"})

		If !Empty(aSQL)

			nQtd := Len(aSQL)
			For nI := 1 To nQtd
				If aScan(aAUX, aSQL[nI][1]) == 0
					aAdd(aAUX, aSQL[nI][1])
				EndIf
			Next

			Self:aContratos := aClone(aAUX)

		EndIf
	EndIf

	JurFreeArr(@aSQL)
	JurFreeArr(@aAUX)

Return Self:aContratos

//-------------------------------------------------------------------
/*/{Protheus.doc} LockContratos()
Metodo para bloquear os contratos da emissão para que mais ninguem
emita ao mesmo tempo.

@author Felipe Bonvicini Conti
@since 23/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Method LockContratos() Class TJPREFATPARAM
	Local lRet  := .T.
	Local nI    := 0
	Local nQtd  := 0

	If !Empty(Self:GetCONTRS())

		nQtd := Len(Self:aContratos)
		For nI := 1 To nQtd
			lRet := LockName(Self:aContratos[nI], Self)
			If !lRet
				Exit
			EndIf
		Next

		If !lRet
			nQtd := Len(Self:aContratos)
			For nI := 1 To nQtd
				UnLockName(Self:aContratos[nI], Self)
			Next
		EndIf

	Else
		lRet := .F.
	EndIf

Return {lRet, Self:aContratos}

//-------------------------------------------------------------------
/*/{Protheus.doc} UnLockContratos()
Metodo para desbloquear os contratos da emissão.

@author Felipe Bonvicini Conti
@since 23/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Method UnLockContratos() Class TJPREFATPARAM
	Local lRet  := .T.
	Local nQtd  := 0
	Local nI    := 0

	If !Empty(Self:aContratos)
		nQtd := Len(Self:aContratos)
		For nI := 1 To nQtd

			lRet := UnLockName(Self:aContratos[nI], self)
			If !lRet
				Exit
			EndIf

		Next
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetNameFunction()

@author Felipe Bonvicini Conti
@since 12/09/11
/*/
//-------------------------------------------------------------------
Method SetNameFunction(cNameFunction) Class TJPREFATPARAM
	Local aRet := {.F., "SetNameFunction"}

	self:cNameFunction := cNameFunction
	aRet := {.T., "SetNameFunction"}

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetNameFunction()

@author Felipe Bonvicini Conti
@since 12/09/11
/*/
//-------------------------------------------------------------------
Method GetNameFunction() Class TJPREFATPARAM
Return IIF(empty(::cNameFunction), "Emissão", ::cNameFunction)

//-------------------------------------------------------------------
/*/{Protheus.doc} PtInternal()

@author Felipe Bonvicini Conti
@since 12/09/11
/*/
//-------------------------------------------------------------------
Method PtInternal(cTexto) Class TJPREFATPARAM
	Local lRet := .F.

	Default cTexto := "Working"

	If ::IsThread()
		PtInternal(1, ::GetNameFunction() + ": " + cTexto)
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMarkInvert()
Método Get do Parâmetro lMarkInvert

@author Felipe Bonvicini Conti
@since 18/04/12
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetMarkInvert()  Class TJPREFATPARAM
Return (self:lMarkInvert)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetMarkInvert()
Método SET do Parâmetro lMarkInvert

@Return aRet	Parâmetro setado com sucesso? .T. / .F.
@author Felipe Bonvicini Conti
@since 18/04/12
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetMarkInvert(lpMarkInvert) Class TJPREFATPARAM
	Local aRet := {.F., "SetMarkInvert"}

	self:lMarkInvert := lpMarkInvert
	aRet := {.T., "SetMarkInvert"}

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetConsist()
Método Get do Parâmetro lConsist

@author David G. Fernandes
@since 18/04/12
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetConsist() Class TJPREFATPARAM
Return (self:lConsist)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetConsist(lConsist)
Método SET do Parâmetro lConsist

@Return aRet	Parâmetro setado com sucesso? .T. / .F.
@author David G. Fernandes
@since 18/04/12
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetConsist(lConsist)  Class TJPREFATPARAM
	Local aRet := {.F., "SetConsist"}

	self:lConsist := lConsist
	aRet := {.T., "SetConsist"}

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFatEmite()
Método Get para pegar o array com os recnos das faturas emitidas

@Return aFaturas array com os codigos do registro das faturas

@author Jonatas
@since 18/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetFatEmite()  Class TJPREFATPARAM
Return (self:aFaturas)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFatEmite()
Método SET para gravar o Recno do registro das faturas Emitidas

@Param	aNXARecnos, array, Recnos dos registro de faturas
@Return aFaturas  , array, Recnos dos registro de faturas
@author Jonatas
@since 18/04/12
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetFatEmite(aNXARecnos)  Class TJPREFATPARAM

	self:aFaturas := aNXARecnos

Return (self:aFaturas)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMsgErro()
Método Get para as mesnagens de erro em CH

@author David G. Fernandes
@since 18/04/12
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetMsgErro(cCodErro)  Class TJPREFATPARAM
	Local cMsgErro

	Do Case
		Case cCodErro == "STR0015" // "Erro ao recuperar informações dos Time Sheets para o caso"
			cMsgErro := STR0015
		Case cCodErro == "STR0016" // "Erro ao recuperar informações das Despesas para o caso"
			cMsgErro := STR0016
		Case cCodErro == "STR0017" // "Erro ao recuperar informações de Serviços Tabelados para o caso"
			cMsgErro := STR0017
		Case cCodErro == "STR0019" // "Valor de Time-Sheets não pode ser negativo na fatura"
			cMsgErro := STR0019
		Case cCodErro == "STR0020" // "Valor de Despesas não pode ser negativo na fatura"
			cMsgErro := STR0020
		Case cCodErro == "STR0021" // "Valor de Serviços Tabelados não pode ser negativo na fatura"
			cMsgErro := STR0021
		Case cCodErro == ""
			cMsgErro :=  STR0018  // Cód Erro não cadastrado
		OtherWise
			cMsgErro := STR0018   // "Cód Erro não cadastrado"
	EndCase

Return (cMsgErro)

//-------------------------------------------------------------------
/*/{Protheus.doc} LockName()
Método LockName

@author David G. Fernandes
@since 18/04/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LockName(cContrato, oObj)
	Local lRet  := .T.

	If oObj:GetFltrHH()
		lRet := LockByName("SIGAPFS_CONTR_" + cContrato + "_TIMESHEET", .T., .T., /*lMayIUseDisk*/)
	EndIf

	If lRet .And. oObj:GetFltrHO()
		lRet := LockByName("SIGAPFS_CONTR_" + cContrato + "_TIMESHEET_PARCELA", .T., .T., /*lMayIUseDisk*/)
	EndIf

	If lRet .And. oObj:GetFltrDH()
		lRet := LockByName("SIGAPFS_CONTR_" + cContrato + "_DESPESA", .T., .T., /*lMayIUseDisk*/)
	EndIf

	If lRet .And. oObj:GetFltrDO()
		lRet := LockByName("SIGAPFS_CONTR_" + cContrato + "_DESPESA_PARCELA", .T., .T., /*lMayIUseDisk*/)
	EndIf

	If lRet .And. oObj:GetFltrTH()
		lRet := LockByName("SIGAPFS_CONTR_" + cContrato + "_TABELADO", .T., .T., /*lMayIUseDisk*/)
	EndIf

	If lRet .And. oObj:GetFltrTO()
		lRet := LockByName("SIGAPFS_CONTR_" + cContrato + "_TABELADO_PARCELA", .T., .T., /*lMayIUseDisk*/)
	EndIf

	If lRet .And. oObj:GetFltrFA()
		lRet := LockByName("SIGAPFS_CONTR_" + cContrato + "_FATADICIONAL", .T., .T., /*lMayIUseDisk*/)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} UnLockName()
Método UnLockName

@author David G. Fernandes
@since 18/04/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function UnLockName(cContrato, oObj)
	Local lRet  := .T.

	If oObj:GetFltrHH()
		lRet := UnLockByName("SIGAPFS_CONTR_" + cContrato + "_TIMESHEET", .T., .T., /*lMayIUseDisk*/)
	EndIf

	If lRet .And. oObj:GetFltrHO()
		lRet := UnLockByName("SIGAPFS_CONTR_" + cContrato + "_TIMESHEET_PARCELA", .T., .T., /*lMayIUseDisk*/)
	EndIf

	If lRet .And. oObj:GetFltrDH()
		lRet := UnLockByName("SIGAPFS_CONTR_" + cContrato + "_DESPESA", .T., .T., /*lMayIUseDisk*/)
	EndIf

	If lRet .And. oObj:GetFltrDO()
		lRet := UnLockByName("SIGAPFS_CONTR_" + cContrato + "_DESPESA_PARCELA", .T., .T., /*lMayIUseDisk*/)
	EndIf

	If lRet .And. oObj:GetFltrTH()
		lRet := UnLockByName("SIGAPFS_CONTR_" + cContrato + "_TABELADO", .T., .T., /*lMayIUseDisk*/)
	EndIf

	If lRet .And. oObj:GetFltrTO()
		lRet := UnLockByName("SIGAPFS_CONTR_" + cContrato + "_TABELADO_PARCELA", .T., .T., /*lMayIUseDisk*/)
	EndIf

	If lRet .And. oObj:GetFltrFA()
		lRet := UnLockByName("SIGAPFS_CONTR_" + cContrato + "_FATADICIONAL", .T., .T., /*lMayIUseDisk*/)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTsZero()
Método Get do Parâmetro lTsZero

@Param  nTsZero Se 0 - Retorna lTsZero
				Se 1 - Retorna as clausulas where do filtro

@Return xValor  Ver paramentro nTsZero

@author Luciano Pereira dos Santos
@since 28/10/15
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetTsZero(nTsZero)  Class TJPREFATPARAM
	Local xValor    := self:lTsZero
	Local cQueryTS  := ''
	Local cSpaceAM  := CriaVar("NUE_ANOMES", .F.)

	Default nTsZero := 0

	Do Case
		Case nTsZero == 0
			xValor := self:lTsZero

		Case nTsZero == 1
			cQueryTS :=   " AND NOT EXISTS ( " //histórico do caso
			cQueryTS +=                   " SELECT NUU.R_E_C_N_O_ " // VERIFICA SE ESTÁ APTO PARA O CALCULO COM BASE NA TABELA DE HONORÁRIOS
			cQueryTS +=                     " FROM " + RetSqlName("NUU") + " NUU, " // HISTÓRICO DO CASO
			cQueryTS +=                          " " + RetSqlName("NTV") + " NTV, " // HISTÓRICO DA TABELA DE HONORÁRIOS
			cQueryTS +=                          " " + RetSqlName("NUS") + " NUS, " // HISTÓRICO DO PARTICIPANTE
			cQueryTS +=                          " " + RetSqlName("NTU") + " NTU " // HISTÓRICO POR CATEGORIA DA TABELA DE HONORÁRIOS
			cQueryTS +=                    " WHERE NUU.NUU_FILIAL = '" + xFilial("NUU") + "' "
			cQueryTS +=                      " AND NTV.NTV_FILIAL = '" + xFilial("NTV") + "' "
			cQueryTS +=                      " AND NUS.NUS_FILIAL = '" + xFilial("NUS") + "' "
			cQueryTS +=                      " AND NTU.NTU_FILIAL = '" + xFilial("NTU") + "' "

			cQueryTS +=                      " AND NUU.NUU_CCLIEN = NUE.NUE_CCLIEN "
			cQueryTS +=                      " AND NUU.NUU_CLOJA = NUE.NUE_CLOJA "
			cQueryTS +=                      " AND NUU.NUU_CCASO = NUE.NUE_CCASO "
			cQueryTS +=                      " AND ((NUE.NUE_ANOMES >= NUU.NUU_AMINI AND NUU.NUU_AMFIM = '"+cSpaceAM+"') "
			cQueryTS +=                       " OR (NUE.NUE_ANOMES BETWEEN NUU.NUU_AMINI AND NUU.NUU_AMFIM)) "

			cQueryTS +=                      " AND NTV.NTV_CTAB = NUU.NUU_CTABH "
			cQueryTS +=                      " AND ((NUE.NUE_ANOMES >= NTV.NTV_AMINI AND NTV.NTV_AMFIM = '"+cSpaceAM+"') "
			cQueryTS +=                       " OR (NUE.NUE_ANOMES BETWEEN NTV.NTV_AMINI AND NTV.NTV_AMFIM)) "

			cQueryTS +=                      " AND NUE.NUE_CPART2 = NUS.NUS_CPART "
			cQueryTS +=                      " AND ((NUE.NUE_ANOMES >= NUS.NUS_AMINI AND NUS.NUS_AMFIM = '"+cSpaceAM+"') "
			cQueryTS +=                       " OR (NUE.NUE_ANOMES BETWEEN NUS.NUS_AMINI AND NUS.NUS_AMFIM)) "

			cQueryTS +=                      " AND NTU.NTU_CCAT = NUS.NUS_CCAT "
			cQueryTS +=                      " AND NTU.NTU_CTAB = NTV.NTV_CTAB AND NTU.NTU_CHIST = NTV.NTV_COD "

			cQueryTS +=                      " AND NUU.D_E_L_E_T_ = ' ' "
			cQueryTS +=                      " AND NTV.D_E_L_E_T_ = ' ' "
			cQueryTS +=                      " AND NUS.D_E_L_E_T_ = ' ' "
			cQueryTS +=                      " AND NTU.D_E_L_E_T_ = ' ' "

			cQueryTS +=                    " UNION "

			cQueryTS +=                   " SELECT NUU.R_E_C_N_O_ " // VERIFICA SE EXISTE EXCEÇÃO PARA O PARTICIPANTE NA TABELA DE HONORÁRIOS
			cQueryTS +=                     " FROM " + RetSqlName("NUU") + " NUU, " // HISTÓRICO DO CASO
			cQueryTS +=                          " " + RetSqlName("NTV") + " NTV, " // HISTÓRICO DA TABELA DE HONORÁRIOS
			cQueryTS +=                          " " + RetSqlName("NTT") + " NTT " // HISTÓRICO DE EXCEÇÃO POR PARTICIPANTE DA TABELA DE HONORÁRIOS - NÃO OBRIGATÓRIO

			cQueryTS +=                    " WHERE NUU.NUU_FILIAL = '" + xFilial("NUU") + "' "
			cQueryTS +=                      " AND NTV.NTV_FILIAL = '" + xFilial("NTV") + "' "
			cQueryTS +=                      " AND NTT.NTT_FILIAL = '" + xFilial("NTT") + "' "
			cQueryTS +=                      " AND NUU.NUU_CCLIEN = NUE.NUE_CCLIEN "
			cQueryTS +=                      " AND NUU.NUU_CLOJA = NUE.NUE_CLOJA "
			cQueryTS +=                      " AND NUU.NUU_CCASO = NUE.NUE_CCASO "
			cQueryTS +=                      " AND NTV.NTV_CTAB = NUU.NUU_CTABH "
			cQueryTS +=                      " AND ((NUE.NUE_ANOMES >= NTV.NTV_AMINI AND NTV.NTV_AMFIM = '"+cSpaceAM+"') "
			cQueryTS +=                       " OR (NUE.NUE_ANOMES BETWEEN NTV.NTV_AMINI AND NTV.NTV_AMFIM)) "
			cQueryTS +=                      " AND ((NUE.NUE_ANOMES >= NUU.NUU_AMINI AND NUU.NUU_AMFIM = '"+cSpaceAM+"') "
			cQueryTS +=                       " OR (NUE.NUE_ANOMES BETWEEN NUU.NUU_AMINI AND NUU.NUU_AMFIM)) "
			cQueryTS +=                      " AND NTT.NTT_CHIST = NTV.NTV_COD "
			cQueryTS +=                      " AND NTT.NTT_CPART = NUE.NUE_CPART2 "
			cQueryTS +=                      " AND NUU.D_E_L_E_T_ = ' ' "
			cQueryTS +=                      " AND NTV.D_E_L_E_T_ = ' ' "
			cQueryTS +=                      " AND NTT.D_E_L_E_T_ = ' ' "

			cQueryTS +=                    " UNION "

			cQueryTS +=                   " SELECT NUS.R_E_C_N_O_ " // VERIFICA SE EXISTE EXCEÇÃO PARA A CATEGORIA NO CASO
			cQueryTS +=                     " FROM " + RetSqlName("NUS") + " NUS, " // HISTÓRICO DO PARTICIPANTE
			cQueryTS +=                          " " + RetSqlName("NUW") + " NUW " // HISTÓRICO DE EXCEÇÃO POR CATEGORIA DA TABELA DE HONORÁRIOS NO CASO - NÃO OBRIGATÓRIO
			cQueryTS +=                    " WHERE NUS.NUS_FILIAL = '" + xFilial("NUS") + "' "
			cQueryTS +=                      " AND NUW.NUW_FILIAL = '" + xFilial("NUW") + "' "
			cQueryTS +=                      " AND NUE.NUE_CPART2 = NUS.NUS_CPART "
			cQueryTS +=                      " AND ((NUE.NUE_ANOMES >= NUS.NUS_AMINI AND NUS.NUS_AMFIM = '"+cSpaceAM+"') "
			cQueryTS +=                       " OR (NUE.NUE_ANOMES BETWEEN NUS.NUS_AMINI AND NUS.NUS_AMFIM)) "
			cQueryTS +=                      " AND NUW.NUW_CCLIEN = NUE.NUE_CCLIEN "
			cQueryTS +=                      " AND NUW.NUW_CLOJA = NUE.NUE_CLOJA "
			cQueryTS +=                      " AND NUW.NUW_CCASO = NUE.NUE_CCASO "
			cQueryTS +=                      " AND NUW.NUW_CCAT = NUS.NUS_CCAT "
			cQueryTS +=                      " AND ((NUW.NUW_AMINI <= NUE.NUE_ANOMES AND NUW.NUW_AMFIM = '"+cSpaceAM+"') "
			cQueryTS +=                       " OR (NUW.NUW_AMINI <= NUE.NUE_ANOMES AND NUW.NUW_AMFIM >= NUE.NUE_ANOMES)) "
			cQueryTS +=                      " AND NUS.D_E_L_E_T_ = ' ' "
			cQueryTS +=                      " AND NUW.D_E_L_E_T_ = ' ' "

			cQueryTS +=                    " UNION "

			cQueryTS +=                   " SELECT NV0.R_E_C_N_O_ " // VERIFICA SE EXISTE EXCEÇÃO PARA O PARTICIPANTE NO CASO
			cQueryTS +=                     " FROM " + RetSqlName("NV0") + " NV0 " // HISTÓRICO DE EXCEÇÃO POR PARTICIPANTE DA TABELA DE HONORÁRIOS NO CASO - NÃO OBRIGATÓRIO
			cQueryTS +=                    " WHERE NV0.NV0_FILIAL = '" + xFilial("NV0") + "' "
			cQueryTS +=                      " AND NV0.NV0_CCLIEN = NUE.NUE_CCLIEN "
			cQueryTS +=                      " AND NV0.NV0_CLOJA = NUE.NUE_CLOJA "
			cQueryTS +=                      " AND NV0.NV0_CCASO = NUE.NUE_CCASO "
			cQueryTS +=                      " AND NV0.NV0_CPART = NUE.NUE_CPART2 "
			cQueryTS +=                      " AND ((NUE.NUE_ANOMES >= NV0.NV0_AMINI AND NV0.NV0_AMFIM = '"+cSpaceAM+"') "
			cQueryTS +=                       " OR  (NUE.NUE_ANOMES >= NV0.NV0_AMINI AND NV0.NV0_AMFIM >= NUE.NUE_ANOMES)) "
			cQueryTS +=                      " AND NV0.D_E_L_E_T_ = ' ' "
			cQueryTS +=                  " ) "
			xValor   := cQueryTS

	EndCase

Return xValor

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTsZero(lTsZero)
Método SET do Parâmetro lTsZero para identificar timesheets com problemas de valorização

@Return aRet Parâmetro setado com sucesso? .T. / .F.
@author Luciano Pereira dos Santos
@since 28/10/15
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetTsZero(lTsZero)  Class TJPREFATPARAM
	Local aRet := {.F., "SetTsZero"}

	self:lTsZero := lTsZero
	aRet := {.T., "SetTsZero"}

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetResomaFt(cResomaFt)
Método SET do Parâmetro cResomaFt que diz se a fatura pode ser resomada por Buttom up

@param  lResoma, Indica se a fatura pode ser resomada por Buttom up
@param  lLimpa , Indica se o valor cResomaFt deve ser resetada

@return aRet Parâmetro setado com sucesso? .T. / .F.

@obs Grava a informação como caracter para poder saber no GetResomaFt, se alguma vez foi atribuido um valor para ele. ( exemplo: JURA201E)

@author Luciano Pereira dos Santos
@since  02/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetResomaFt(lResoma, lLimpa)  Class TJPREFATPARAM
	Local aRet := {.F., "SetResomaFt"}

	Default lLimpa := .F.

	If lLimpa
		self:cResomaFt := ""
	Else
		self:cResomaFt := Iif(lResoma , "S", "N")
	EndIf
	
	aRet := {self:cResomaFt == "S", "SetResomaFt"}

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetResomaFt(cResomaFt)
Método GET do Parâmetro cResomaFt que diz se a fatura pode ser resomada por Buttom up

@Return self:cResomaFt
@author Luciano Pereira dos Santos
@since 02/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetResomaFt(lRetLogico)  Class TJPREFATPARAM
	Local xRet         := ""

	Default lRetLogico := .T.

	If lRetLogico
		xRet := self:cResomaFt == "S"
	Else
		xRet := Iif(self:cResomaFt == "S" .Or. self:cResomaFt == "N", self:cResomaFt, "" )
	EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PreFtMsgDlg
Dialogo para exibicao do historico do processamento

@author Daniel Magalhaes
@since 10/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PreFtMsgDlg(cTitulo, aMsgPages)
	Local oDlgResumo  := Nil
	Local oFont1      := Nil
	Local cMsgDisplay := ""
	Local cNoPage     := ""
	Local cLastPage   := ""
	Local nPage       := 1
	Local nLastPage   := 0

	nPage       := 1
	cMsgDisplay := aMsgPages[nPage]
	nLastPage   := Len(aMsgPages)
	cLastPage   := AllTrim(Str(nLastPage))
	cNoPage     := PadL( AllTrim(Str(nPage)), Len(cLastPage) )

	Define MsDialog oDlgResumo Title cTitulo From 7,2 To 26,78 Of oMainWnd

	Define FONT oFont1 NAME "Courier New" Bold Size 0,14

	oDlgResumo:SetFont(oFont1)

	@ 06.5,03 Get cMsgDisplay MEMO HSCROLL READONLY SIZE 295,120 OF oDlgResumo Pixel

	Define SButton From 130,140 Type 1 Action (oDlgResumo:End()) Enable Of oDlgResumo Pixel

	@ 130,260 Get cNoPage Picture "@9" SIZE 15,10 ON CHANGE (nPage:=VldPage(cNoPage,nLastPage),RefreshMsg(@cMsgDisplay,@cNoPage,aMsgPages[nPage],nPage)) WHEN {|| nLastPage > 1} OF oDlgResumo Pixel
	@ 132,274 Say "/"+cLastPage OF oDlgResumo Pixel

	@ 130,175 BUTTON "<<" SIZE 40 ,11 ACTION (nPage-=1,RefreshMsg(@cMsgDisplay,@cNoPage,aMsgPages[nPage],nPage) ) WHEN {|| nPage > 1 } OF oDlgResumo PIXEL
	@ 130,215 BUTTON ">>" SIZE 40 ,11 ACTION (nPage+=1,RefreshMsg(@cMsgDisplay,@cNoPage,aMsgPages[nPage],nPage) ) WHEN {|| nPage < nLastPage } OF oDlgResumo PIXEL

	Activate MSdialog oDlgResumo Centered
	oFont1:End()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RefreshMsg
Funcao para atualizar o conteudo campo Memo conforme a pagina
selecionada

@author Daniel Magalhaes
@since 10/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RefreshMsg(cCpoMemo, cCpoPage, cNewMsg, nNewPage)

	cCpoMemo := ""
	cCpoMemo := cNewMsg

	cCpoPage := ""
	cCpoPage := AllTrim(Str(nNewPage))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldPage
Funcao para validar a pagina recebida por digitacao direta no campo

@author Daniel Magalhaes
@since 10/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldPage(cNoPage, nLastPage)
	Local nNewPage   := 1
	Local nPageInput := Val(cNoPage)

	If nPageInput < 1
		nNewPage:= 1
	ElseIf nPageInput > nLastPage
		nNewPage:= nLastPage
	Else
		nNewPage:= nPageInput
	EndIf

Return nNewPage

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201ATS(oParams)
Rotina para filtrar os Time-Sheets que atendam aos parâmetros na
emissão da pré-fatura

@param oParams, Objeto da classe Tjurprefat

@author David G. Fernandes
@since 19/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA201ATS(oParams)
	Local cQueryTS   := ""
	Local lAtivNaoC  := SuperGetMV( 'MV_JURTS4',, .F. ) // Zera a hora revisada dos TS com atividade não cobrável
	Local lTsZero    := oParams:GetTsZero()
	Local lTSNCobra  := SuperGetMV( 'MV_JTSNCOB',, .F. ) // Indica se vincula TimeSheet não cobrável na emissão

	cQueryTS :=     "SELECT DISTINCT '"+ Space(TamSx3('NVV_COD')[1]) +"' NVV_COD, "
	cQueryTS +=        " TMP.NW2_COD,"
	cQueryTS +=        " TMP.NT0_FILIAL,"
	cQueryTS +=        " TMP.NT0_COD,"
	cQueryTS +=        " TMP.NT0_CESCR,"
	cQueryTS +=        " TMP.NT0_VLRBAS, "
	cQueryTS +=        " TMP.NT0_CRELAT,"
	cQueryTS +=        " NVE.NVE_CCLIEN,"
	cQueryTS +=        " NVE.NVE_LCLIEN,"
	cQueryTS +=        " NVE.NVE_NUMCAS,"
	cQueryTS +=        " '1' TEMTS,"
	cQueryTS +=        " '2' TEMLT,"
	cQueryTS +=        " '2' TEMDP,"
	cQueryTS +=        " '2' TEMFX,"
	cQueryTS +=        " '2' TEMFA,"
	cQueryTS +=        " '2' SEPARA,"
	cQueryTS +=        " '2' TEMLM "
	cQueryTS += " FROM (" + oParams:GetQryTmpCtr() + ") TMP "
	cQueryTS +=          " INNER JOIN " + RetSqlName("NUT") + " NUT ON (NUT.NUT_FILIAL = '" + xFilial("NUT") + "' AND "
	cQueryTS +=                                                       " NUT.NUT_CCONTR = TMP.NT0_COD AND "
	If !Empty(oParams:GetCliente()) .Or. !Empty(oParams:GetCasos())
		cQueryTS +=                                                   " NUT.NUT_CCASO = TMP.NUT_CCASO AND "
		cQueryTS +=                                                   " NUT.NUT_CCLIEN = TMP.NUT_CCLIEN AND "
		cQueryTS +=                                                   " NUT.NUT_CLOJA = TMP.NUT_CLOJA AND "
	EndIf
	cQueryTS +=                                                       " NUT.D_E_L_E_T_ = ' ') "
	cQueryTS +=          " INNER JOIN " + RetSqlName("NTH") + " NTH ON (NTH.NTH_FILIAL = '" + xFilial("NTH") +"' AND "
	cQueryTS +=                                                       " NTH.NTH_CTPHON = TMP.NRA_COD AND "
	cQueryTS +=                                                       " NTH.NTH_CAMPO = 'NT0_TPCEXC' AND "
	cQueryTS +=                                                       " NTH.D_E_L_E_T_ = ' ') "
	cQueryTS +=         " LEFT OUTER JOIN " + RetSqlName("NT1") + " NT1 ON (NT1.NT1_FILIAL = '" + xFilial("NT1") +"' AND "
	cQueryTS +=                                                       " NT1.NT1_CCONTR = TMP.NT0_COD AND "
	If !Empty(oParams:GetDIniH()) .AND. !Empty(oParams:GetDFinH())
		cQueryTS += " NT1.NT1_DATAFI >= '" + DtoS(oParams:GetDIniH()) +"' AND "
		cQueryTS += " NT1.NT1_DATAFI <= '" + DtoS(oParams:GetDFinH()) +"' AND "
	EndIf
	cQueryTS +=                                                       " NT1.D_E_L_E_T_ = ' ') "
	cQueryTS +=          " INNER JOIN " + RetSqlName("NVE") + " NVE ON (NVE.NVE_FILIAL = '" + xFilial("NVE") + "' AND "
	cQueryTS +=                                                       " NVE.NVE_CCLIEN = NUT.NUT_CCLIEN AND "
	cQueryTS +=                                                       " NVE.NVE_LCLIEN = NUT.NUT_CLOJA AND "
	cQueryTS +=                                                       " NVE.NVE_NUMCAS = NUT.NUT_CCASO AND "
	cQueryTS +=                                                       " NVE.NVE_ENCHON = '2' AND "
	If lTsZero .Or. oParams:GetSituac() <> "1" // Conferência
		cQueryTS +=                                                   " NVE.NVE_COBRAV = '1' AND "
	EndIf
	cQueryTS +=                                                       " NVE.D_E_L_E_T_ = ' ' AND "
	/*Bloco criado para verificar a existência de casos válidos quando houver a cobrança de excedente
	(Misto e Mínimo), de forma que se não houver casos válidos, o excedente também não seja emitido.
	Para hora e fixo a emissão de horas deve ocorrer normalmente. */
	cQueryTS +=                                                       " ( CASE WHEN NTH.NTH_VISIV = '1' THEN "
	cQueryTS +=                                                           "(CASE WHEN NVE.NVE_SITUAC = '1' THEN (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) ELSE "
	cQueryTS +=                                                              "(CASE WHEN NVE.NVE_DTENCE >= NT1.NT1_DATAIN AND NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
	cQueryTS +=                                                           " END) "
	cQueryTS +=                                                         " ELSE '1' END ) <> '2' "
	cQueryTS +=                                                       " ) "
	cQueryTS +=          " INNER JOIN " + RetSqlName("NUE") + " NUE ON (NUE.NUE_FILIAL = '" + xFilial("NUE") + "' AND "
	cQueryTS +=                                                       " NUE.NUE_CCLIEN = NVE.NVE_CCLIEN AND "
	cQueryTS +=                                                       " NUE.NUE_CLOJA  = NVE.NVE_LCLIEN AND "
	cQueryTS +=                                                       " NUE.NUE_CCASO  = NVE.NVE_NUMCAS AND "
	If oParams:GetSituac() <> '1' .And. !lTSNCobra // Não é Conferência e só considera TimeSheets cobrável
		cQueryTS +=                                                   " NUE.NUE_COBRAR = '1' AND "
	EndIf
	cQueryTS +=                                                       " NUE.NUE_SITUAC = '1' AND "
	If !Empty(oParams:GetDIniH()) .AND. !Empty(oParams:GetDFinH())
		cQueryTS += JFilVigCtr(DtoS(oParams:GetDIniH()), DtoS(oParams:GetDFinH()), "NUE.NUE_DATATS")
	EndIf
	If !Empty(oParams:GetDInIFxNc()) .AND. !Empty(oParams:GetDFinFxNc()) // Contratos Fixos ou Não Cobráveis
		cQueryTS += JFilVigCtr(DtoS(oParams:GetDInIFxNc()), DtoS(oParams:GetDFinFxNc()), "NUE.NUE_DATATS")
	EndIf
	cQueryTS +=                                                       " NUE.D_E_L_E_T_ = ' ') "

	If !lAtivNaoC .And. (oParams:GetSituac() <> '1' .And. !lTSNCobra) // Só considera TimeSheets cobrável
		cQueryTS +=      " INNER JOIN " + RetSqlName("NRC") + " NRC ON (NRC.NRC_FILIAL = '" + xFilial("NRC") + "' AND "
		cQueryTS +=                                                     " NRC.NRC_COD = NUE.NUE_CATIVI AND "
		cQueryTS +=                                                     " NRC.NRC_TEMPOZ  = '1' AND "
		cQueryTS +=                                                     " NRC.D_E_L_E_T_  = ' ') "
	EndIf
	cQueryTS +=    " WHERE TMP.NT0_ENCH = '2' "
	cQueryTS +=      " AND NVE.NVE_ENCHON = '2' "

	If oParams:GetSituac() <> "1" .And. !lTSNCobra // Conferência e só considera TimeSheets cobrável
		cQueryTS +=  " AND NOT EXISTS (SELECT NTJ.R_E_C_N_O_ "
		cQueryTS +=                    " FROM " + RetSqlName("NTJ") + " NTJ "
		cQueryTS +=                   " WHERE NTJ.NTJ_FILIAL = '" + xFilial("NTJ") + "' "
		cQueryTS +=                     " AND NTJ.NTJ_CCONTR = TMP.NT0_COD "
		cQueryTS +=                     " AND NTJ.NTJ_CTPATV = NUE.NUE_CATIVI "
		cQueryTS +=                     " AND NTJ.D_E_L_E_T_ = ' ' ) "
	EndIf

	cQueryTS +=      " AND (NUE.NUE_CLTAB = '"+ Space(TamSx3('NUE_CLTAB')[1]) + "' "
	cQueryTS +=           " OR EXISTS (SELECT NV4.R_E_C_N_O_ "
	cQueryTS +=                        " FROM " + RetSqlName("NV4") + " NV4 "
	cQueryTS +=                       " WHERE NV4.NV4_FILIAL = '" +xFilial("NV4") + "' "
	cQueryTS +=                         " AND NV4.NV4_COD = NUE.NUE_CLTAB "
	cQueryTS +=                         " AND NV4.NV4_SITUAC = '1' "
	If oParams:GetSituac() <> '1' // Não é Conferência
		cQueryTS +=                     " AND NV4.NV4_COBRAR = '1' "
	EndIf
	cQueryTS +=                         " AND NV4.NV4_CONC = '1' "
	cQueryTS +=                         " AND " + Iif(oParams:GetFltrTH(), "'1'", "'2'") + " = '1' "
	cQueryTS +=                         " AND NV4.D_E_L_E_T_ = ' ')) "

	// clausula where do filtro de participantes com tabela de honorarios zerada
	If lTsZero
		cQueryTS += oParams:GetTsZero(1)
	EndIf

	cQueryTS += oParams:GetQryInFat("NUE") //Filtro comum aos laçamentos para verificar se estão em pre-fatura ou minuta.

	If oParams:GetSituac() <> '1' // Não é Conferência 
		If oParams:GetFltrFxNc() // Flag de TSs de Contrato Fixo/Não Cobrável ativada
			cQueryTS +=  " AND (TMP.NRA_NCOBRA = '1' OR (TMP.NRA_COBRAH = '2' AND TMP.NRA_COBRAF = '1')) "
		Else
			cQueryTS +=  " AND TMP.NRA_NCOBRA = '2' "
			cQueryTS +=  " AND TMP.NRA_COBRAH = '1' "
		EndIf
	EndIf

Return (cQueryTS)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201ALT(oParams)
Rotina para filtrar os Lançamentos Tabelados que atendam aos parâmetros na
emissão da pré-fatura

@param oParams, Objeto da classe Tjurprefat

@author David G. Fernandes
@since 20/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA201ALT(oParams)
	Local cQueryLT   := ""
	Local cNameTbTmp := oParams:oTmpContr:GetRealName()

	cQueryLT :=     "SELECT DISTINCT '"+ Space(TamSx3('NVV_COD')[1]) +"' NVV_COD, "
	cQueryLT +=       " TMP.NW2_COD,"
	cQueryLT +=       " TMP.NT0_FILIAL,"
	cQueryLT +=       " TMP.NT0_COD,"
	cQueryLT +=       " TMP.NT0_CESCR,"
	cQueryLT +=       " TMP.NT0_VLRBAS, "
	cQueryLT +=       " TMP.NT0_CRELAT,"
	cQueryLT +=       " NVE.NVE_CCLIEN,"
	cQueryLT +=       " NVE.NVE_LCLIEN,"
	cQueryLT +=       " NVE.NVE_NUMCAS,"
	cQueryLT +=       " '2' TEMTS,"
	cQueryLT +=       " '1' TEMLT,"
	cQueryLT +=       " '2' TEMDP,"
	cQueryLT +=       " '2' TEMFX,"
	cQueryLT +=       " '2' TEMFA,"
	cQueryLT +=       " '2' SEPARA,"
	cQueryLT +=       " '2' TEMLM"
	cQueryLT +=     " FROM " + cNameTbTmp + " TMP "
	cQueryLT +=          " INNER JOIN " + RetSqlName("NUT") + " NUT ON (NUT.NUT_FILIAL = '" + xFilial("NUT") + "' AND "
	cQueryLT +=                                                       " NUT.NUT_CCONTR = TMP.NT0_COD AND "
	If !Empty(oParams:GetCliente()) .Or. !Empty(oParams:GetCasos())
		cQueryLT +=                                                   " NUT.NUT_CCASO = TMP.NUT_CCASO AND "
		cQueryLT +=                                                   " NUT.NUT_CCLIEN = TMP.NUT_CCLIEN AND "
		cQueryLT +=                                                   " NUT.NUT_CLOJA = TMP.NUT_CLOJA AND "
	EndIf
	cQueryLT +=                                                       " NUT.D_E_L_E_T_ = ' ') "
	cQueryLT +=          " INNER JOIN " + RetSqlName("NVE") + " NVE ON (NVE.NVE_FILIAL = '" + xFilial("NVE") + "' AND "
	cQueryLT +=                                                       " NVE.NVE_CCLIEN = NUT.NUT_CCLIEN AND "
	cQueryLT +=                                                       " NVE.NVE_LCLIEN = NUT.NUT_CLOJA AND "
	cQueryLT +=                                                       " NVE.NVE_NUMCAS = NUT.NUT_CCASO AND "
	cQueryLT +=                                                       " NVE.NVE_ENCTAB = '2' AND "
	If oParams:GetSituac() <> "1" // Não é Conferência
		cQueryLT +=                                                   " NVE.NVE_COBRAV = '1' AND "
	EndIf
	cQueryLT +=                                                       " NVE.D_E_L_E_T_ = ' ') "
	cQueryLT +=          " INNER JOIN " + RetSqlName("NV4") + " NV4 ON (NV4.NV4_FILIAL = '" + xFilial("NV4") + "' AND "
	cQueryLT +=                                                       " NV4.NV4_CCLIEN = NVE.NVE_CCLIEN AND "
	cQueryLT +=                                                       " NV4.NV4_CLOJA  = NVE.NVE_LCLIEN AND "
	cQueryLT +=                                                       " NV4.NV4_CCASO  = NVE.NVE_NUMCAS AND "
	cQueryLT +=                                                       " NV4.NV4_SITUAC = '1' AND "
	If oParams:GetSituac() <> '1' // Não é Conferência
		cQueryLT +=                                                   " NV4.NV4_COBRAR = '1' AND "
	EndIf
	cQueryLT +=                                                       " NV4.NV4_CONC   = '1' AND "
	If !Empty(oParams:GetDIniT()) .AND. !Empty(oParams:GetDFinT())
		cQueryLT += JFilVigCtr(DtoS(oParams:GetDIniT()), DtoS(oParams:GetDFinT()), "NV4.NV4_DTCONC")
	EndIf
	cQueryLT +=                                                       " NV4.D_E_L_E_T_ = ' ') "
	cQueryLT +=     " WHERE TMP.NT0_SERTAB = '1' "
	cQueryLT +=       " AND TMP.NT0_ENCT = '2' "

	cQueryLT += oParams:GetQryInFat("NV4") //Filtro comum aos laçamentos para verificar se estão em pre-fatura ou minuta.

	If oParams:GetFltrTH() .AND. !oParams:GetFltrTO()
		cQueryLT +=    " AND ( "
		cQueryLT +=        " TMP.NT0_FIXEXC = '1' "
		cQueryLT +=        " OR TMP.NT0_SERTAB = '1' "
		If oParams:GetSituac() <> '1' // Não é Conferência
			cQueryLT +=     " OR TMP.NRA_NCOBRA = '1' "
			cQueryLT +=     " OR TMP.NRA_COBRAH = '1' "
		EndIf
		cQueryLT +=        " ) "
	Else
		If !oParams:GetFltrTH() .AND. oParams:GetFltrTO() //OUTROS TIPOS
			cQueryLT +=  " AND (TMP.NRA_COBRAF = '1' "
			cQueryLT +=       " OR TMP.NT0_FIXEXC = '1'  "
			If oParams:GetSituac() <> '1' // Não é Conferência
				cQueryLT +=    " OR TMP.NRA_NCOBRA = '1'  "
			EndIf
			cQueryLT +=       " ) "
		EndIf
	EndIf

Return (cQueryLT)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201ADP(oParams)
Rotina para filtrar as Despesas que atendam aos parâmetros na
emissão da pré-fatura

@param oParams, Objeto da classe Tjurprefat

@author David G. Fernandes
@since 20/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA201ADP(oParams)
	Local cQueryDP   := ""
	Local cNameTbTmp := oParams:oTmpContr:GetRealName()

	cQueryDP :=     "SELECT DISTINCT '"+ Space(TamSx3('NVV_COD')[1]) +"' NVV_COD, "
	cQueryDP +=         " TMP.NW2_COD,"
	cQueryDP +=         " TMP.NT0_FILIAL,"
	cQueryDP +=         " TMP.NT0_COD,"
	cQueryDP +=         " TMP.NT0_CESCR,"
	cQueryDP +=         " TMP.NT0_VLRBAS, "
	cQueryDP +=         " TMP.NT0_CRELAT,"
	cQueryDP +=         " NVE.NVE_CCLIEN,"
	cQueryDP +=         " NVE.NVE_LCLIEN,"
	cQueryDP +=         " NVE.NVE_NUMCAS,"
	cQueryDP +=         " '2' TEMTS,"
	cQueryDP +=         " '2' TEMLT,"
	cQueryDP +=         " '1' TEMDP,"
	cQueryDP +=         " '2' TEMFX,"
	cQueryDP +=         " '2' TEMFA,"
	cQueryDP +=         " '2' SEPARA,"
	cQueryDP +=         " '2' TEMLM"
	cQueryDP +=     " FROM " + cNameTbTmp + " TMP "
	cQueryDP +=          " INNER JOIN " + RetSqlName("NUT") + " NUT ON (NUT.NUT_FILIAL = '" + xFilial("NUT") + "' AND "
	cQueryDP +=                                                       " NUT.NUT_CCONTR = TMP.NT0_COD AND "
	If !Empty(oParams:GetCliente()) .Or. !Empty(oParams:GetCasos())
		cQueryDP +=                                                   " NUT.NUT_CCASO = TMP.NUT_CCASO AND "
		cQueryDP +=                                                   " NUT.NUT_CCLIEN = TMP.NUT_CCLIEN AND "
		cQueryDP +=                                                   " NUT.NUT_CLOJA = TMP.NUT_CLOJA AND "
	EndIf
	cQueryDP +=                                                       " NUT.D_E_L_E_T_ = ' ') "
	cQueryDP +=          " INNER JOIN " + RetSqlName("NVE") + " NVE ON (NVE.NVE_FILIAL = '" + xFilial("NVE") + "' AND "
	cQueryDP +=                                                       " NVE.NVE_CCLIEN = NUT.NUT_CCLIEN AND "
	cQueryDP +=                                                       " NVE.NVE_LCLIEN = NUT.NUT_CLOJA AND "
	cQueryDP +=                                                       " NVE.NVE_NUMCAS = NUT.NUT_CCASO AND "
	cQueryDP +=                                                       " NVE.NVE_ENCDES = '2' AND "
	If oParams:GetSituac() <> "1" // Conferência
		cQueryDP +=                                                   " NVE.NVE_COBRAV = '1' AND "
	EndIf
	cQueryDP +=                                                       " NVE.D_E_L_E_T_ = ' ') "
	cQueryDP +=          " INNER JOIN " + RetSqlName("NVY") + " NVY ON (NVY.NVY_FILIAL = '" + xFilial("NVY") + "' AND "
	cQueryDP +=                                                       " NVY.NVY_CCLIEN = NVE.NVE_CCLIEN AND "
	cQueryDP +=                                                       " NVY.NVY_CLOJA  = NVE.NVE_LCLIEN AND "
	cQueryDP +=                                                       " NVY.NVY_CCASO  = NVE.NVE_NUMCAS AND "
	If oParams:GetSituac() <> '1' // Não é Conferência
		cQueryDP +=                                                   " NVY.NVY_COBRAR = '1' AND "
	EndIf
	cQueryDP +=                                                       " NVY.NVY_SITUAC = '1' AND "
	If !Empty(oParams:GetDIniD()) .AND. !Empty(oParams:GetDFinD())
		cQueryDP += JFilVigCtr(DtoS(oParams:GetDIniD()), DtoS(oParams:GetDFinD()), "NVY.NVY_DATA")
	EndIf
	If !Empty(oParams:GetTipoDP())
		cQueryDP +=                                                   " NVY.NVY_CTPDSP IN (" + oParams:GetTipoDP() +") AND "
	EndIf
	If ExistBlock('J201BDPF')
		cQueryDP += ExecBlock('J201BDPF', .F., .F.) + " AND "
	EndIf
	cQueryDP +=                                                       " NVY.D_E_L_E_T_ = ' ') "
	cQueryDP +=     " WHERE TMP.NT0_DESPES = '1' "
	cQueryDP +=       " AND TMP.NT0_ENCD = '2' "
	
	If oParams:GetSituac() <> "1" // Conferência
		cQueryDP +=       " AND NOT EXISTS (SELECT NTK.R_E_C_N_O_ "
		cQueryDP +=                         " FROM " + RetSqlName("NTK") + " NTK "
		cQueryDP +=                        " WHERE NTK.NTK_FILIAL = '" + xFilial("NTK") + "' "
		cQueryDP +=                          " AND NTK.NTK_CCONTR = TMP.NT0_COD "
		cQueryDP +=                          " AND NTK.NTK_CTPDSP = NVY.NVY_CTPDSP "
		cQueryDP +=                          " AND NTK.D_E_L_E_T_ = ' ') "
	EndIf

	cQueryDP += oParams:GetQryInFat("NVY") //Filtro comum aos laçamentos para verificar se estão em pre-fatura ou minuta.

	If oParams:GetFltrDH() .AND. !oParams:GetFltrDO()
		cQueryDP +=   " AND ( "
		cQueryDP +=        " TMP.NT0_FIXEXC = '1' "
		If oParams:GetSituac() <> '1' // Não é conferência
			cQueryDP +=    " OR TMP.NRA_NCOBRA = '1' "
			cQueryDP +=    " OR TMP.NRA_COBRAH = '1' "
		EndIf
		cQueryDP +=        " ) "
	Else
		If !oParams:GetFltrDH() .AND. oParams:GetFltrDO() //OUTROS TIPOS
			cQueryDP += " AND (TMP.NRA_COBRAF = '1' "
			cQueryDP +=      " OR TMP.NT0_FIXEXC = '1' "
			If oParams:GetSituac() <> '1' // Não é conferência
				cQueryDP +=   " OR TMP.NRA_NCOBRA = '1' "
			EndIf
			cQueryDP +=      " ) "
		EndIf
	EndIf

Return (cQueryDP)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201AFX(oParams)
Rotina para filtrar as Parcelas Fixas que atendam aos parâmetros na
emissão da pré-fatura

@param oParams, Objeto da classe Tjurprefat

@author David G. Fernandes
@since 20/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA201AFX(oParams)
	Local cQueryFX   := ""
	Local cNameTbTmp := oParams:oTmpContr:GetRealName()

	cQueryFX :=     "SELECT '"+ Space(TamSx3('NVV_COD')[1]) +"' NVV_COD, "
	cQueryFX +=        " TMP.NW2_COD,"
	cQueryFX +=        " TMP.NT0_FILIAL,"
	cQueryFX +=        " TMP.NT0_COD,"
	cQueryFX +=        " TMP.NT0_CESCR,"
	cQueryFX +=        " TMP.NT0_VLRBAS, "
	cQueryFX +=        " TMP.NT0_CRELAT,"
	cQueryFX +=        " TMP.NT0_CCLIEN as NVE_CCLIEN,"
	cQueryFX +=        " TMP.NT0_CLOJA as NVE_LCLIEN,"
	cQueryFX +=        " '"+ Space(TamSx3('NVE_NUMCAS')[1]) +"' NVE_NUMCAS,"
	cQueryFX +=        " '2' TEMTS,"
	cQueryFX +=        " '2' TEMLT,"
	cQueryFX +=        " '2' TEMDP,"
	cQueryFX +=        " '1' TEMFX,"
	cQueryFX +=        " '2' TEMFA,"
	cQueryFX +=        " CASE WHEN NTH.NTH_VISIV = '1' THEN "
	cQueryFX +=             " (CASE WHEN TMP.NT0_FIXEXC = '2' AND TMP.NRA_COBRAH = '1' "
	cQueryFX +=                   " THEN '1' ELSE '2' END) "
	cQueryFX +=        " ELSE "+ (Iif(oParams:GetFltrHO(), "'2'", "'1'")) +" END SEPARA,"
	cQueryFX +=         " '2' TEMLM "
	cQueryFX +=     " FROM " + cNameTbTmp + " TMP "
	cQueryFX +=     " INNER JOIN " + RetSqlName("NTH") + " NTH ON (NTH.NTH_FILIAL = '" + xFilial("NTH") +"' AND "
	cQueryFX +=                                                    " NTH.NTH_CTPHON = TMP.NRA_COD AND "
	cQueryFX +=                                                    " NTH.NTH_CAMPO = 'NT0_TPCEXC' AND "
	cQueryFX +=                                                    " NTH.D_E_L_E_T_ = ' ') "
	cQueryFX +=     " INNER JOIN " + RetSqlName("NTH") + " NTH1 ON (NTH1.NTH_FILIAL = '" + xFilial("NTH") +"' AND "
	cQueryFX +=                                                    " NTH1.NTH_CTPHON = TMP.NRA_COD AND "
	cQueryFX +=                                                    " NTH1.NTH_CAMPO = 'NT0_FXABM' AND "
	cQueryFX +=                                                    " NTH1.D_E_L_E_T_ = ' '), "
	cQueryFX +=                " " + RetSqlName("NT1") + " NT1 "
	cQueryFX +=     " WHERE NT1.NT1_FILIAL = '" + xFilial("NT1") +"'  "
	cQueryFX +=       " AND TMP.NT0_ENCH = '2' "
	cQueryFX +=       " AND TMP.NT0_COD = NT1.NT1_CCONTR  "
	cQueryFX +=       " AND NT1.NT1_SITUAC = '1'  "

	If oParams:GetSituac() <> '1' // Não é Conferência
		cQueryFX +=   " AND TMP.NRA_NCOBRA = '2' "
		If oParams:GetFltrHO()
			cQueryFX += " AND TMP.NRA_COBRAF = '1' "
		EndIf
	Else
		cQueryFX +=   " AND TMP.NRA_COBRAF = '1' "
		If !oParams:GetFltrHO()
			cQueryFX += " AND TMP.NT0_FIXEXC = '1' "
		EndIf
	EndIf

	/*Bloco criado para exibir na fila apenas as parcelas cujo contrato possui casos válidos.*/
	cQueryFX +=       " AND EXISTS ( SELECT NVE.R_E_C_N_O_ FROM " + RetSqlName("NVE") + " NVE, "
	cQueryFX +=                                               " " + RetSqlName("NUT") + " NUT "

	cQueryFX +=                                   " WHERE NVE.NVE_FILIAL = '"+ xFilial("NVE") +"' AND "
	If oParams:GetSituac() <> "1" // Conferência
		cQueryFX +=                               " NVE.NVE_COBRAV = '1' AND "
	EndIf
	cQueryFX +=                                   " NUT.NUT_FILIAL = '"+ xFilial("NUT") +"' AND "
	cQueryFX +=                                   " NUT.NUT_CCONTR = TMP.NT0_COD AND "
	If !Empty(oParams:GetCliente()) .Or. !Empty(oParams:GetCasos())
		cQueryFX +=                               " NUT.NUT_CCASO = TMP.NUT_CCASO AND "
		cQueryFX +=                               " NUT.NUT_CCLIEN = TMP.NUT_CCLIEN AND "
		cQueryFX +=                               " NUT.NUT_CLOJA = TMP.NUT_CLOJA AND "
	EndIf
	cQueryFX +=                                   " NVE.NVE_CCLIEN = NUT.NUT_CCLIEN AND "
	cQueryFX +=                                   " NVE.NVE_LCLIEN = NUT.NUT_CLOJA AND "
	cQueryFX +=                                   " NVE.NVE_NUMCAS = NUT.NUT_CCASO AND "
	cQueryFX +=                                   " NVE.NVE_ENCHON = '2' AND "
	cQueryFX +=                                   " NVE.D_E_L_E_T_ = ' ' AND "
	cQueryFX +=                                   " NUT.D_E_L_E_T_ = ' ' AND "

	//Se não for Faixa - Qtdade de Casos - verifica regra para considerar apenas casos abertos
	cQueryFX +=                                 " ( CASE WHEN NTH1.NTH_VISIV = '2' THEN "
	cQueryFX +=                                           "(CASE WHEN NVE.NVE_SITUAC = '1' THEN (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) ELSE "
	cQueryFX +=                                               "(CASE WHEN NVE.NVE_DTENCE >= NT1.NT1_DATAIN AND NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
	cQueryFX +=                                           " END) "
	cQueryFX +=                                   " ELSE "
	//Se for Faixa - Qtdade de Casos - verifica o conteúdo dos campos NT0_FXABM e NT0_FXENCM além da situação do caso
	If SuperGetMV("MV_JQTDAUT", .F., "1") == "1" // Calcula a quantidade de casos automática
		cQueryFX +=                                      " (CASE WHEN NTH1.NTH_VISIV = '1' THEN "
		cQueryFX +=                                             " (CASE WHEN NVE.NVE_SITUAC = '1' THEN (CASE WHEN TMP.NT0_FXABM = '1' THEN (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
		cQueryFX +=                                              " ELSE "
		cQueryFX +=                                             " (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
		cQueryFX +=                                              " END) "
		cQueryFX +=                                       " ELSE (CASE WHEN TMP.NT0_FXABM = '1' THEN (CASE WHEN TMP.NT0_FXENCM = '1' THEN (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI AND NVE.NVE_DTENCE >= NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
		cQueryFX +=                                             " ELSE (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI AND NVE.NVE_DTENCE > NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
		cQueryFX +=                                              " END) "
		cQueryFX +=                                              " ELSE (CASE WHEN TMP.NT0_FXENCM = '1' THEN (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN AND NVE.NVE_DTENCE >= NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
		cQueryFX +=                                                    " ELSE (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN AND NVE.NVE_DTENCE > NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
		cQueryFX +=                                               " END) "
		cQueryFX +=                                              " END) "
		cQueryFX +=                                            " END) "
		cQueryFX +=                                          " END) "
		cQueryFX +=                                   " END ) <> '2' "
		cQueryFX +=                                 " ) "
	Else
		cQueryFX +=                                      " (CASE WHEN NTH.NTH_VISIV = '1' THEN (CASE WHEN NT1.NT1_QTDADE > 0 THEN '1' ELSE '2' END) END) END) <> '2' ) "
	EndIf

	If !Empty(oParams:GetDIniH()) .AND. !Empty(oParams:GetDFinH())
		cQueryFX += JFilVigCtr(DtoS(oParams:GetDIniH()), DtoS(oParams:GetDFinH()), "NT1.NT1_DATAFI", .F.)
	EndIf

	cQueryFX += oParams:GetQryInFat("NT1") //Filtro comum aos laçamentos para verificar se estão em pre-fatura ou minuta.

	cQueryFX +=     " AND NTH.D_E_L_E_T_ = ' ' "
	cQueryFX +=     " AND NT1.D_E_L_E_T_ = ' ' "

Return (cQueryFX)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201AFA(oParams)
Rotina para filtrar as Faturas Adicionais que atendam aos parâmetros na
emissão da pré-fatura

@author David G. Fernandes
@since 20/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA201AFA(oParams)
	Local cQueryFA := ""

	cQueryFA := "SELECT NVV.NVV_COD,"
	cQueryFA +=       " '"+ Space(TamSx3('NW2_COD')[1]) +"' NW2_COD,"
	cQueryFA +=       " NT0.NT0_FILIAL,"
	cQueryFA +=       " NT0.NT0_COD,"
	cQueryFA +=       " NT0.NT0_CESCR,"
	cQueryFA +=       " NT0.NT0_VLRBAS, "
	cQueryFA +=       " NT0.NT0_CRELAT,"
	cQueryFA +=       " NVW.NVW_CCLIEN NVE_CCLIEN,"
	cQueryFA +=       " NVW.NVW_CLOJA NVE_LCLIEN,"
	cQueryFA +=       " NVW.NVW_CCASO NVE_NUMCAS,"
	cQueryFA +=       " CASE WHEN NVW.NVW_VALORH > 0 THEN '1' ELSE '2' END TEMTS, "
	cQueryFA +=       " CASE WHEN NVW.NVW_VALORT > 0 THEN '1' ELSE '2' END TEMLT, "
	cQueryFA +=       " CASE WHEN NVW.NVW_VALORD > 0 THEN '1' ELSE "
	cQueryFA +=       " (CASE WHEN NVV.NVV_TRADSP = '1' AND (SELECT COUNT(NVY.R_E_C_N_O_) " //Verifica se existe despesa para emitir no caso da FA
	cQueryFA +=                      " FROM " + RetSqlName("NVY") + " NVY, "
	cQueryFA +=                         " " + RetSqlName("NRH") + " NRH "
	cQueryFA +=                     " WHERE NVY.NVY_FILIAL = '" + xFilial("NVY") +"' "
	cQueryFA +=                       " AND NRH.NRH_FILIAL = '" + xFilial("NRH") +"' "
	cQueryFA +=                       " AND NVY.NVY_CTPDSP = NRH.NRH_COD "
	cQueryFA +=                       " AND NRH.NRH_COBRAR = '1' "
	cQueryFA +=                       " AND NVY.NVY_CCLIEN = NVW.NVW_CCLIEN "
	cQueryFA +=                       " AND NVY.NVY_CLOJA = NVW.NVW_CLOJA "
	cQueryFA +=                       " AND NVY.NVY_CCASO = NVW.NVW_CCASO "
	cQueryFA +=                       " AND NVY.NVY_COBRAR = '1' "
	cQueryFA +=                       " AND NVY.NVY_SITUAC = '1' "
	If !Empty(oParams:GetTipoDP())
		cQueryFA +=                   " AND NVY.NVY_CTPDSP IN (" + oParams:GetTipoDP() +") "
	EndIf
	cQueryFA +=                       " AND NVY.NVY_DATA >= NVV.NVV_DTINID " //Perido da despesa na FA
	cQueryFA +=                       " AND NVY.NVY_DATA <= NVV.NVV_DTFIMD "
	cQueryFA +=                       " AND NOT EXISTS (SELECT NTK.R_E_C_N_O_ "
	cQueryFA +=                                         " FROM " + RetSqlName("NTK") + " NTK "
	cQueryFA +=                                         " WHERE NTK.NTK_FILIAL = '" + xFilial("NTK") +"' "
	cQueryFA +=                                         " AND NTK.NTK_CCONTR = NT0.NT0_COD "
	cQueryFA +=                                         " AND NTK.NTK_CTPDSP = NVY.NVY_CTPDSP "
	cQueryFA +=                                         " AND NTK.D_E_L_E_T_ = ' ') "

	cQueryFA += oParams:GetQryInFat("NVY") //Filtro comum aos laçamentos para verificar se estão em pre-fatura ou minuta (Despesas em FA).

	cQueryFA +=                       " AND NVY.D_E_L_E_T_ = ' ' "
	cQueryFA +=                       " AND NRH.D_E_L_E_T_ = ' ' "
	cQueryFA +=                       ") > 0 THEN '1' ELSE '2' END) "

	cQueryFA +=    " END TEMDP, "
	cQueryFA +=       " '2' TEMFX,"
	cQueryFA +=       " '1' TEMFA,"
	cQueryFA +=       " '2' SEPARA,"
	cQueryFA +=       " '2' TEMLM"
	cQueryFA +=     " FROM " + RetSqlName("NT0") + " NT0, "
	cQueryFA +=          " " + RetSqlName("NVV") + " NVV, "
	cQueryFA +=          " " + RetSqlName("NVW") + " NVW "

	/*Bloco de verificação da situação dos sócios conforme filtro na emissão*/
	If !Empty(oParams:GetSitSoc())
		cQueryFA +=      " INNER JOIN " + RetSqlName("RD0") + " RD0 ON (RD0.RD0_FILIAL = '" + xFilial("RD0") + "' AND "
		cQueryFA +=                                                   " RD0.RD0_CODIGO = NVV.NVV_CPART1 AND "
		cQueryFA +=                                                   " RD0.RD0_MSBLQL = '"+ oParams:GetSitSoc() +"' AND "
		cQueryFA +=                                                   " RD0.D_E_L_E_T_ = ' ' ) "
	EndIf
	cQueryFA +=     " WHERE NVV.NVV_FILIAL = '" + xFilial("NVV") +"' "
	cQueryFA +=       " AND NT0.NT0_FILIAL = '" + xFilial("NT0") +"' "
	cQueryFA +=       " AND NVW.NVW_FILIAL = '" + xFilial("NVW") +"' "
	cQueryFA +=       " AND NVV.NVV_CCONTR = NT0.NT0_COD "
	cQueryFA +=       " AND NT0.NT0_ATIVO = '1' "
	cQueryFA +=       " AND NT0.NT0_SIT = '2' "
	cQueryFA +=       " AND NVV.NVV_COD = NVW.NVW_CODFAD "
	cQueryFA +=       " AND NVV.NVV_SITUAC = '1' "
	If !Empty(oParams:GetContrato())
		cQueryFA+= " AND NVV.NVV_CCONTR IN ("+  oParams:GetContrato() +")  "
	Else
		cQueryFA +=   " AND NVV.NVV_CCONTR > '"+ Space(TamSx3('NVV_CCONTR')[1]) +"' "
	EndIf

	If !Empty(oParams:GetCliente()) .AND. !Empty(oParams:GetLoja()) .AND. Empty(oParams:GetCasos())
		cQueryFA +=   " AND NVV.NVV_CCLIEN = '"+ oParams:GetCliente() +"' " // SE O PARÂMETRO POR POR CLIENTE, EXIGE CLIENTE /LOJA
		cQueryFA +=   " AND NVV.NVV_CLOJA = '"+ oParams:GetLoja() +"' "
	EndIf

	If !Empty(oParams:GetExceto())
		cQueryFA +=   " AND NVV.NVV_CCLIEN NOT IN ("+ oParams:GetExceto() +") "
	EndIf

	If !Empty(oParams:GetGrpCli())
		cQueryFA +=   " AND EXISTS ( SELECT SA1a.R_E_C_N_O_ "
		cQueryFA +=                 " FROM " + RetSqlName("SA1") + " SA1a "
		cQueryFA +=                 " WHERE SA1a.A1_FILIAL = '" + xFilial("SA1") +"' "
		cQueryFA +=                   " AND SA1a.A1_GRPVEN = '" + oParams:GetGrpCli() +"' "
		cQueryFA +=                   " AND SA1a.D_E_L_E_T_ = ' ' "
		cQueryFA +=                   " AND SA1a.A1_COD = NVV.NVV_CCLIEN "
		cQueryFA +=                   " AND SA1a.A1_LOJA = NVV.NVV_CLOJA "
		cQueryFA +=               " ) "
	EndIf

	If !Empty(oParams:GetCasos())
		cQueryFA +=   " AND EXISTS ( SELECT NVWa.R_E_C_N_O_ "
		cQueryFA +=                 " FROM " + RetSqlName("NVW") + " NVWa "
		cQueryFA +=                 " WHERE NVWa.NVW_FILIAL = '" + xFilial("NVW") +"' "
		If !Empty(oParams:GetCliente())
			cQueryFA +=               " AND NVWa.NVW_CCLIEN = '"+ oParams:GetCliente() +"' "
		EndIf
		If !Empty(oParams:GetLoja())
			cQueryFA +=               " AND NVWa.NVW_CLOJA = '"+ oParams:GetLoja() +"' "
		EndIf
		cQueryFA +=                   " AND NVWa.NVW_CCASO IN ("+ oParams:GetCasos() +") "
		cQueryFA +=                   " AND NVWa.D_E_L_E_T_ = ' ' "
		cQueryFA +=                   " AND NVWa.NVW_CODFAD = NVV.NVV_COD "
		cQueryFA +=               " ) "
		cQueryFA +=   " AND NVV.D_E_L_E_T_ = ' ' "
	EndIf

	If !Empty(oParams:GetDIniFA()) .AND. !Empty(oParams:GetDFinFA())
		cQueryFA +=   " AND NVV.NVV_DTBASE BETWEEN '" + DtoS(oParams:GetDIniFA()) + "' AND '" + DtoS(oParams:GetDFinFA()) +"' "
	EndIf

	If !Empty(oParams:GetSocio())
		cQueryFA +=   " AND NVV.NVV_CPART1 = '"+  oParams:GetSocio() +"' "
	EndIf

	If !Empty(oParams:GetExcSoc())
		cQueryFA +=   " AND NVV.NVV_CPART1 NOT IN ("+ oParams:GetExcSoc() +") "
	EndIf

	If !Empty(oParams:GetMoeda())
		cQueryFA +=   " AND NVV.NVV_CMOE3 = '"+  oParams:GetMoeda() +"' "
	EndIf

	If !Empty(oParams:GetEscrit())
		cQueryFA +=   " AND NVV.NVV_CESCR = '"+oParams:GetEscrit()+"' "
	EndIf

	cQueryFA += oParams:GetQryInFat("NVV") //Filtro comum aos laçamentos para verificar se estão em pre-fatura ou minuta

	cQueryFA +=       " AND NVV.D_E_L_E_T_ = ' ' "
	
	If NVV->(ColumnPos("NVV_MSBLQL")) > 0 // Proteção
		cQueryFA +=       " AND NVV.NVV_MSBLQL <> '1' "
	EndIf

	cQueryFA +=       " AND NT0.D_E_L_E_T_ = ' ' "

Return (cQueryFA)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201ALM
Rotina para filtrar os contratos que possuem limites excedentes

@param   oParams ,  Objeto da classe Tjurprefat
@param   lGeraCtr, Se .T. Gera a query temporaria com o filtro de contratos
@param   cCampos , Campos trazidos pela query principal
@param   cContr  , Código do contrato para filtro
@param   cCodJun , Código da junção de contratos

@author  Jonatas Martins / Luciano Pereira
@since   04/10/2018
@Obs     Função utilizada no fonte JURA201D e JURA201E
/*/
//-------------------------------------------------------------------
Function JA201ALM(oParams, lGeraCtr, cCampos, cContr, cCodJun)
	Local cQueryLM   := ""
	Local cNameTbTmp := ""
	Local cNameTbLM  := ""

	Default lGeraCtr := .F.
	Default cCampos  := ""
	Default cContr   := ""
	Default cCodJun  := ""

	If lGeraCtr
		oParams:GeraTmpContrato()
	EndIf
	cNameTbTmp := oParams:oTmpContr:GetRealName()

	oParams:GeraTmpLimite() // Cria tabela temporária de cotratos com limite
	cNameTbLM := oParams:oTmpLimite:GetRealName()

	If Empty(cCampos)
		If oParams:GetTpExec() $ "2|3|4|5|6|MS"
			cCampos := " FILIAL, CCESC, CCONTR, CCLIEN, CLOJA, CCASO, VLRBAS, TEMTS, TEMDP, TEMLT, TEMFX, TEMFA, TEMLM "
		Else // Campos na ordem para Emissão de Pré-Fatura
			cCampos := " TMPLM.NVV_COD, TMPLM.NW2_COD, FILIAL, CCONTR, CCESC, VLRBAS, TMPLM.NT0_CRELAT, CCLIEN, CLOJA, CCASO, TEMTS, TEMLT, TEMDP, TEMFX, TEMFA, SEPARA, TEMLM "
		EndIf
	EndIf

	cQueryLM := " SELECT " + cCampos
	cQueryLM +=       " FROM " + cNameTbTmp + " TMP "
	cQueryLM +=            " INNER JOIN " + cNameTbLM + " TMPLM ON ( TMPLM.FILIAL = TMP.NT0_FILIAL AND "
	cQueryLM +=                                                    " TMPLM.CCONTR = TMP.NT0_COD AND "
	cQueryLM +=                                                    " TMPLM.CCLIEN = TMP.NUT_CCLIEN AND "
	cQueryLM +=                                                    " TMPLM.CLOJA = TMP.NUT_CLOJA AND "
	cQueryLM +=                                                    " TMPLM.CCASO = TMP.NUT_CCASO) "

	If !Empty(cCodJun)
		cQueryLM += " WHERE EXISTS (SELECT NW3.R_E_C_N_O_ "
		cQueryLM +=                 " FROM " + RetSqlName("NW3") + " NW3 "
		cQueryLM +=                 " WHERE NW3.NW3_FILIAL = '" + xFilial("NW3") + "' "
		cQueryLM +=                   " AND NW3.NW3_CCONTR = TMP.NT0_COD "
		cQueryLM +=                   " AND NW3.NW3_CJCONT = '" + cCodJun + "'
		cQueryLM +=                   " AND NW3.D_E_L_E_T_ = ' ')"
	ElseIf !Empty(cContr)
		cQueryLM += " WHERE TMP.NT0_COD = '" + cContr + "' "
	EndIf

Return (cQueryLM)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetQryInFat()
Filtro de query comum aos lançamentos para verificar se os lançamentos estão em pré-fatura, fatura ou minuta.

@return cQuery Filtro para query dos lançamentos elegíveis à emissão

@author Luciano Pereira dos Santos
@since 17/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetQryInFat(cTabela) Class TJPREFATPARAM
Local cQuery   := ""
Local cCampo   := cTabela+"_CPREFT"
Local cSpace   := CriaVar(cCampo, .F.)
Local lExists  := .T.

	If self:GetSituac() != "1" // Se não for conferência
		If self:GetChkApaga() // Se apaga pré-fatuas existentes = .T. -> Usa o que tiver
			cQuery += " AND (" + cTabela + "." + cCampo + " = '" + cSpace + "' "
			cQuery +=       " OR ( EXISTS ( SELECT NX0.R_E_C_N_O_ "
			cQuery +=                       " FROM " + RetSqlName("NX0") + " NX0 "
			cQuery +=                      " WHERE NX0.NX0_FILIAL = '" + xFilial("NX0") + "' "
			cQuery +=                        " AND NX0.NX0_COD = " + cTabela + "." + cCampo + " "
			If self:GetFltrFA() .And. cTabela == "NVY" //Despesas na Fatura Adicional
				cQuery +=                    " AND NX0.NX0_CFTADC = NVV.NVV_COD " //Só considera as despesas se forem de uma emissão de FA anterior que possa ser apagada antes da emissao
			EndIf
			If self:GetChkApaMP() // Se Apaga/Substituí minutas existentes incluí as situações de minuta nos filtros
				cQuery +=                    " AND NX0.NX0_SITUAC IN ('2', '3', '5', '6', '7', '9', 'A', 'B') "
			Else
				cQuery +=                    " AND NX0.NX0_SITUAC IN ('2', '3') "
			EndIf
			cQuery +=                        " AND NX0.D_E_L_E_T_ = ' ' "
			cQuery +=                   " ) "
			If !self:GetChkApaMP() // Se apaga minutas existentes = .F. -> Usa só o que não tiver minuta
				cQuery += " AND NOT EXISTS ( SELECT NXA.NXA_COD "
				cQuery +=                    " FROM " + RetSqlName("NXA") + " NXA "
				cQuery +=                   " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") +"' "
				cQuery +=                     " AND NXA.NXA_CPREFT = " + cTabela + "." + cCampo + " "
				cQuery +=                     " AND NXA.NXA_SITUAC = '1' "
				cQuery +=                     " AND NXA.NXA_TIPO IN ('MP','MS') "
				cQuery +=                     " AND NXA.D_E_L_E_T_ = ' ' "
				cQuery +=                 " ) "
			EndIf
		Else //Se apaga pré-faturas existentes = .F. -> Usa só as pendentes
			cQuery +=    " AND (( " + cTabela + "." + cCampo + " = '" + cSpace + "' "
			lExists := .F.
		EndIf
	Else // Senão usa o que tiver
		cQuery +=        " AND ( " + cTabela+"."+cCampo + " = '"+ cSpace + "' "
		cQuery +=             " OR ( EXISTS ( SELECT NX0.R_E_C_N_O_ "
		cQuery +=                             " FROM " + RetSqlName("NX0") + " NX0 "
		cQuery +=                            " WHERE NX0.NX0_FILIAL = '" +xFilial("NX0") +"' "
		cQuery +=                              " AND NX0.NX0_COD = " + cTabela + "." + cCampo + " "
		cQuery +=                              " AND NX0.NX0_SITUAC IN ('2', '3') "
		cQuery +=                              " AND NX0.D_E_L_E_T_ = ' ' "
		cQuery +=                         " ) "
	EndIf

	If cTabela == "NT1" .Or. cTabela == "NVV"
		cQuery +=        " AND NOT EXISTS ( SELECT NXA.R_E_C_N_O_ "
		cQuery +=                           " FROM " + RetSqlName("NXA") + " NXA "
		cQuery +=                          " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") +"' "
		If cTabela == "NT1"
			cQuery +=                        " AND NXA.NXA_CFIXO = NT1.NT1_SEQUEN " //Verifica emissão de fixo direto da fila
		EndIf
		If cTabela == "NVV"
			cQuery +=                        " AND NXA.NXA_CFTADC = NVV.NVV_COD " //Verifica emissão de Fatura adicional direto da fila
		EndIf
		cQuery +=                            " AND NXA.NXA_SITUAC = '1' "
		cQuery +=                            " AND NXA.NXA_TIPO = 'FT' "
		cQuery +=                            " AND NXA.D_E_L_E_T_ = ' ' "
		cQuery +=                        " ) "
	EndIf
	
	If lExists
		cQuery +=           " AND NOT EXISTS ( SELECT NXG.R_E_C_N_O_ " //Pré-faturas cujo algum dos pagadores esta faturado
		cQuery +=                              " FROM " + RetSqlName("NXG") + " NXG "
		cQuery +=                             " WHERE NXG.NXG_FILIAL = '" +xFilial("NXG") +"' "
		cQuery +=                               " AND NXG.NXG_CPREFT = " + cTabela+"."+cCampo + " "
		cQuery +=                               " AND NXG.NXG_CPREFT > '"+ Criavar('NXG_CPREFT', .F.) + "' "
		cQuery +=                               " AND NXG.NXG_CFATUR > '"+ Criavar('NXG_CFATUR', .F.) + "' "
		cQuery +=                               " AND NXG.NXG_CESCR > '"+ Criavar('NXG_CESCR', .F.) + "' "
		cQuery +=                               " AND NXG.D_E_L_E_T_ = ' ') "
	EndIf

	cQuery +=                 " ) "
	cQuery +=             " ) "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} GetQryTmpCtr()
Gera a query para tabela temporária com os contratos passíveis de emissão

@return cQueryCT, Query para tabela temporária com os contratos passíveis de emissão

@author Bruno Ritter
@since 12/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetQryTmpCtr(lFilter) Class TJPREFATPARAM
	Local cQueryCT   := ""
	Local cContratos := Self:GetContrato()
	Local lTipoFech  := Self:GetChkFech()
	Local cTamFech   := IIF(lTipoFech, Space(TamSX3("OHU_CODIGO")[1]), "")
	Local lFltrFxNc  := self:GetFltrFxNc() // Contrato Fixo ou Não Cobrável

	Default lFilter  := .F.

	cQueryCT := "SELECT NT0.NT0_FILIAL,"
	cQueryCT +=       " NT0.NT0_COD, "
	cQueryCT +=       " NT0.NT0_CRELAT, "
	cQueryCT +=       " NT0.NT0_CTPHON, "
	cQueryCT +=       " NT0.NT0_DESPES, "
	cQueryCT +=       " NT0.NT0_SERTAB, "
	cQueryCT +=       " NT0.NT0_ENCD, "
	cQueryCT +=       " NT0.NT0_ENCH, "
	cQueryCT +=       " NT0.NT0_ENCT, "
	cQueryCT +=       " NT0.NT0_CCLIEN, "
	cQueryCT +=       " NT0.NT0_CLOJA, "
	cQueryCT +=       " NT0.NT0_CESCR, "
	cQueryCT +=       " NT0.NT0_CPART1, "
	cQueryCT +=       " NT0.NT0_CMOE, "
	cQueryCT +=       " NT0.NT0_FIXEXC, "
	cQueryCT +=       " NT0.NT0_FXABM, "
	cQueryCT +=       " NT0.NT0_FXENCM, "
	cQueryCT +=       " NT0.NT0_CMOELI, "
	cQueryCT +=       " NT0_VLRBAS, "
	If NT0->(ColumnPos("NT0_DTVIGI")) > 0
		cQueryCT +=       " NT0.NT0_DTVIGI, "
		cQueryCT +=       " NT0.NT0_DTVIGF, "
	EndIf
	cQueryCT +=       " NRA.NRA_COD, "
	cQueryCT +=       " NRA.NRA_NCOBRA, "
	cQueryCT +=       " NRA.NRA_COBRAH, "
	cQueryCT +=       " NRA.NRA_COBRAF, "
	cQueryCT +=       " NUT.NUT_CCASO, "
	cQueryCT +=       " NUT.NUT_CCLIEN, "
	cQueryCT +=       " NUT.NUT_CLOJA, "
	cQueryCT +=       " CASE WHEN NW2.NW2_COD IS NULL THEN '"+ Space(TamSx3('NW2_COD')[1]) +"' ELSE NW2.NW2_COD END NW2_COD "
	cQueryCT += " FROM " + RetSqlName("NT0") + " NT0 "
	cQueryCT +=      " INNER JOIN " + RetSqlName("NRA") + " NRA ON (NRA.NRA_FILIAL = '" + xFilial("NRA") + "' "
	cQueryCT +=                                                   " AND NRA.NRA_COD = NT0.NT0_CTPHON "
	If lFltrFxNc // Contrato Fixo ou Não Cobrável
		cQueryCT +=                                               " AND (NRA.NRA_NCOBRA = '1' OR (NRA.NRA_COBRAH = '2' AND NRA.NRA_COBRAF = '1')) "
	EndIf
	cQueryCT +=                                                   " AND NRA.D_E_L_E_T_ = ' ') "
	cQueryCT +=      " LEFT OUTER JOIN " + RetSqlName("NW3") + " NW3 ON (NW3.NW3_FILIAL = '" + xFilial("NW3") + "' "
	cQueryCT +=                                                       " AND NT0.NT0_COD = NW3.NW3_CCONTR "
	cQueryCT +=                                                       " AND NW3.D_E_L_E_T_ = ' ') "
	cQueryCT +=      " LEFT OUTER JOIN " + RetSqlName("NW2") + " NW2 ON (NW2.NW2_FILIAL = '" + xFilial("NW2") + "' "
	cQueryCT +=                                                       " AND NW3.NW3_CJCONT = NW2.NW2_COD "
	cQueryCT +=                                                       " AND NW2.D_E_L_E_T_ = ' ') "

	/*Bloco de verificação da situação dos sócios conforme filtro na emissão*/
	If !Empty(Self:GetSitSoc())
		cQueryCT +=  " INNER JOIN " + RetSqlName("RD0") + " RD0 ON (RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
		cQueryCT +=                                                   " AND RD0.RD0_CODIGO = ( CASE WHEN NW2.NW2_CPART IS NULL THEN NT0.NT0_CPART1 ELSE NW2.NW2_CPART END ) "
		cQueryCT +=                                                   " AND RD0.RD0_MSBLQL = '"+ Self:GetSitSoc() +"' "
		cQueryCT +=                                                   " AND RD0.D_E_L_E_T_ = ' ' ) "
	EndIf

	cQueryCT +=  " INNER JOIN " + RetSqlName("NUT") + " NUT ON (NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
	cQueryCT +=                                               " AND NUT.NUT_CCONTR = NT0.NT0_COD "
	If Self:GetTDCasos()
		cQueryCT +=                                           " AND (EXISTS (SELECT NW3a.R_E_C_N_O_ "
		cQueryCT +=                                                            " FROM " + RetSqlName("NW3") + " NW3a "
		cQueryCT +=                                                           " WHERE NW3a.NW3_FILIAL = '" + xFilial("NW3") + "' "
		cQueryCT +=                                                             " AND NW3a.NW3_CCONTR = NUT.NUT_CCONTR "
		cQueryCT +=                                                             " AND EXISTS (SELECT NUTa.R_E_C_N_O_ "
		cQueryCT +=                                                                           " FROM " + RetSqlName("NUT") + " NUTa, "
		cQueryCT +=                                                                                " " + RetSqlName("NW3") + " NW3b "
		cQueryCT +=                                                                          " WHERE NUTa.NUT_FILIAL = '" + xFilial("NUT") + "' "
		cQueryCT +=                                                                            " AND NW3b.NW3_FILIAL = '" + xFilial("NW3") + "' "
		cQueryCT +=                                                                            " AND NW3b.NW3_CJCONT = NW3a.NW3_CJCONT "
		cQueryCT +=                                                                            " AND NUTa.NUT_CCONTR = NW3b.NW3_CCONTR "
		If !Empty(Self:GetCliente())
			cQueryCT +=                                                                         " AND NUTa.NUT_CCLIEN = '" + Self:GetCliente() + "' "
			If !Empty(Self:GetLoja())
				cQueryCT +=                                                                     " AND NUTa.NUT_CLOJA = '" + Self:GetLoja() + "' "
			EndIf
		EndIf
		If !Empty(Self:GetCasos())
			cQueryCT +=                                                                         " AND NUTa.NUT_CCASO IN (" + Self:GetCasos() + ") "
		EndIf
		cQueryCT +=                                                                            " AND NUTa.D_E_L_E_T_ = ' ' "
		cQueryCT +=                                                                            " AND NW3b.D_E_L_E_T_ = ' ')"
		cQueryCT +=                                                             " AND NW3a.D_E_L_E_T_ = ' ') "
		cQueryCT +=                                                  " OR EXISTS (SELECT NUTb.R_E_C_N_O_ "
		cQueryCT +=                                                               " FROM " + RetSqlName("NUT") + " NUTb "
		cQueryCT +=                                                              " WHERE NUTb.NUT_FILIAL = '" + xFilial("NUT") + "' "
		cQueryCT +=                                                                " AND NUTb.NUT_CCONTR = NUT.NUT_CCONTR "
		If !Empty(Self:GetCliente())
			cQueryCT +=                                                            " AND NUTb.NUT_CCLIEN = '" + Self:GetCliente() + "' "
			If !Empty(Self:GetLoja())
				cQueryCT +=                                                         " AND NUTb.NUT_CLOJA = '" + Self:GetLoja() + "' "
			EndIf
		EndIf
		If !Empty(Self:GetCasos())
			cQueryCT +=                                                            " AND NUTb.NUT_CCASO IN ("+ Self:GetCasos() +") "+ CRLF
		EndIf
		cQueryCT +=                                                                " AND NUTb.D_E_L_E_T_ = ' ')"+ CRLF
		cQueryCT +=                                                " ) "
	Else
		If !Empty(Self:GetCliente())
			cQueryCT +=                                         " AND NUT.NUT_CCLIEN = '"+ Self:GetCliente() +"' "
			If !Empty(Self:GetLoja())
				cQueryCT +=                                      " AND NUT.NUT_CLOJA = '"+ Self:GetLoja() +"' "
			EndIf
		EndIf
		If !Empty(Self:GetCasos())
			cQueryCT +=                                         " AND NUT.NUT_CCASO IN ("+ Self:GetCasos() +") "
		EndIf
	EndIf
	cQueryCT +=                               " AND NUT.D_E_L_E_T_ = ' ') "

	cQueryCT +=     " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
	cQueryCT +=       " AND NT0.NT0_ATIVO = '1' "
	cQueryCT +=       " AND NT0.NT0_SIT = '2' "

	If !Empty(Self:GetTipoHon())
		cQueryCT +=   " AND NT0.NT0_CTPHON IN ("+ Self:GetTipoHon() +") "
	EndIf

	If !Empty(Self:GetExceto())
		cQueryCT +=   " AND NT0.NT0_CCLIEN NOT IN ("+ Self:GetExceto() +") "
	EndIf

	If !Empty(Self:GetGrpCli())
		cQueryCT +=   " AND EXISTS ( SELECT SA1A.R_E_C_N_O_ "
		cQueryCT +=               " FROM " + RetSqlName("SA1") + " SA1A "
		cQueryCT +=               " WHERE SA1A.A1_FILIAL = '" + xFilial("SA1") +"' "
		cQueryCT +=                 " AND SA1A.A1_GRPVEN = '" + Self:GetGrpCli() +"' "
		cQueryCT +=                 " AND SA1A.D_E_L_E_T_ = ' ' "
		cQueryCT +=                 " AND SA1A.A1_COD = NT0.NT0_CCLIEN "
		cQueryCT +=                 " AND SA1A.A1_LOJA = NT0.NT0_CLOJA "
		cQueryCT +=                " ) "
	EndIf

	If !Empty(cContratos)
		If Self:GetTDContr()
			cQueryCT += " AND ( NT0.NT0_COD IN (" + cContratos + ") "
			cQueryCT +=       " OR EXISTS (SELECT NW3c.R_E_C_N_O_ "
			cQueryCT +=                      " FROM " + RetSqlName("NW3") + " NW3c "
			cQueryCT +=                      " WHERE NW3c.NW3_FILIAL = '" + xFilial("NW3") +"' "
			cQueryCT +=                        " AND NW3c.NW3_CCONTR = NT0.NT0_COD "
			cQueryCT +=                        " AND EXISTS ( SELECT NW3d.R_E_C_N_O_ "
			cQueryCT +=                                       " FROM " + RetSqlName("NW3") + " NW3d "
			cQueryCT +=                                      " WHERE NW3d.NW3_FILIAL = '" + xFilial("NW3") +"' "
			cQueryCT +=                                        " AND NW3d.NW3_CJCONT = NW3c.NW3_CJCONT "
			cQueryCT +=                                        " AND NW3d.NW3_CCONTR IN (" + cContratos + ") "
			cQueryCT +=                                        " AND NW3d.D_E_L_E_T_ = ' ') "
			cQueryCT +=                         " AND NW3c.D_E_L_E_T_ = ' ' "
			cQueryCT +=                  " )) "
		Else
			cQueryCT += " AND NT0.NT0_COD IN ("+ cContratos +") "
		EndIf
	EndIf

	If Self:GetTpExec() $ "2|6" .And. !Empty(self:GetPreFat())
		cQueryCT += " AND EXISTS (SELECT NX8.R_E_C_N_O_ "
		cQueryCT +=               " FROM " + RetSqlName("NX8") + " NX8 "
		cQueryCT +=              " WHERE NX8.NX8_FILIAL = '" + xFilial("NX8") + "' "
		cQueryCT +=                " AND NX8.NX8_CCONTR = NT0.NT0_COD "
		cQueryCT +=                " AND NX8.NX8_CPREFT = '" + self:GetPreFat() + "' "
		cQueryCT +=                " AND NX8.D_E_L_E_T_ = ' ' ) "
	EndIf

	If !Empty(Self:GetEscrit())
		cQueryCT +=   " AND NT0.NT0_CESCR = '" + Self:GetEscrit() + "' "
	EndIf

	If !Empty(Self:GetSocio())
		cQueryCT +=   " AND ( (NW2.NW2_CPART IS NULL AND NT0.NT0_CPART1 = '" + Self:GetSocio() + "') "
		cQueryCT +=            " OR "
		cQueryCT +=            " NW2.NW2_CPART = '"+  Self:GetSocio() +"'  "
		cQueryCT +=       " ) "
	EndIf

	If !Empty(Self:GetExcSoc())
		cQueryCT +=  " AND ( (NW2.NW2_CPART IS NULL AND NT0.NT0_CPART1 NOT IN ( " + Self:GetExcSoc() + " ) ) "
		cQueryCT +=           " OR "
		cQueryCT +=           " NW2.NW2_CPART NOT IN (" + Self:GetExcSoc() + ") "
		cQueryCT +=      " ) "
	EndIf

	If !Empty(Self:GetMoeda())
		cQueryCT +=   " AND ( (NW2.NW2_CMOE IS NULL AND NT0.NT0_CMOE = '"+  Self:GetMoeda() +"')  "
		cQueryCT +=            " OR "
		cQueryCT +=            " NW2.NW2_CMOE = '" +  Self:GetMoeda() + "' "
		cQueryCT +=       " ) "
	EndIf

	If lTipoFech // Filtra Tipo de Fechamento de Período
		cQueryCT +=   " AND ( (NW2.NW2_COD IS NULL " 
		If Empty(Self:GetTipoFech())
			cQueryCT +=        " AND NT0.NT0_TPFECH = '" + cTamFech + "') "
		Else
			cQueryCT +=        " AND NT0.NT0_TPFECH IN (" + Self:GetTipoFech() + ")) "
		EndIf
		cQueryCT +=            " OR "
		If Empty(Self:GetTipoFech())
			cQueryCT +=        " NW2.NW2_TPFECH = '" + cTamFech + "' "
		Else
			cQueryCT +=        " NW2.NW2_TPFECH IN (" + Self:GetTipoFech() + ") "
		EndIf
		cQueryCT +=       " ) "
	EndIf

	cQueryCT +=       " AND NT0.D_E_L_E_T_ = ' ' "

Return cQueryCT

//-------------------------------------------------------------------
/*/{Protheus.doc} GetQryTmpLM()
Gera a query para tabela temporária de contratos com limites por fatura
passíveis de emissão

@return cQueryLM, Query para tabela temporária com os contratos passíveis de emissão

@author  Bruno Ritter
@since   04/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetQryTmpLM() Class TJPREFATPARAM
	Local cQueryLM := ""

	cQueryLM :=  "SELECT '"+ Space(TamSx3('NVV_COD')[1]) +"' NVV_COD, "
	cQueryLM +=         " NW2_COD,"
	cQueryLM +=         " NT0_FILIAL FILIAL,"
	cQueryLM +=         " NT0_COD CCONTR,"
	cQueryLM +=         " NT0_CESCR CCESC,"
	cQueryLM +=         " NT0_VLRBAS VLRBAS, "
	cQueryLM +=         " NT0_CRELAT,"
	cQueryLM +=         " NVE_CCLIEN CCLIEN,"
	cQueryLM +=         " NVE_LCLIEN CLOJA,"
	cQueryLM +=         " NVE_NUMCAS CCASO,"
	cQueryLM +=         " '2' TEMTS,"
	cQueryLM +=         " '2' TEMLT,"
	cQueryLM +=         " '2' TEMDP,"
	cQueryLM +=         " '2' TEMFX,"
	cQueryLM +=         " '2' TEMFA,"
	cQueryLM +=         " '2' SEPARA,"
	cQueryLM +=         " '2' TEMLM "
	cQueryLM +=     "FROM " + RetSqlName("NVV") + " NVV, "
	cQueryLM +=         " " + RetSqlName("NW2") + " NW2, "
	cQueryLM +=         " " + RetSqlName("NT0") + " NT0, "
	cQueryLM +=         " " + RetSqlName("NVE") + " NVE  "
	cQueryLM +=     "WHERE 1 = 2"

Return cQueryLM

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraTmpContrato()
Retorna a tabela temporária de contratos passiveis de emissão para gerar a
pré-fatura de lançamentos

@Return oTmpContr, objeto da tabela temporária

@author Bruno Ritter
@since 13/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GeraTmpContrato() Class TJPREFATPARAM

	If !self:GetFltrFA() .And. Empty(Self:oTmpContr) //Se não for fatura adicional
		Self:oTmpContr := JurCriaTmp(GetNextAlias(), Self:GetQryTmpCtr(), "NT0")[1]
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraTmpLimite
Retorna a tabela temporária de contratos com limite por fatura
passiveis de emissão para gerar a pré-fatura de lançamentos

@Return oTmpLimite, objeto da tabela temporária

@author Bruno Ritter
@since 13/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GeraTmpLimite() Class TJPREFATPARAM
	Local aStruAdic   := {}
	Local aIdxAdic    := {}
	Local cAlsLimite  := ""
	Local cAlsCtrLim  := ""
	Local cQryCtrLim  := ""
	Local cNameCtrTmp := ""
	Local dDtEmi      := CtoD("  /  /  ")
	Local nLimite     := 0
	Local nTamIdxAdic := 0
	Local cContr      := ''
	Local lApagaPre   := Self:GetChkApaga()
	Local lApagaMin   := Self:GetChkApaMP()
	Local lLimitGer   := .F.
	Local lLimitFat   := .F.
	Local nLimitGer   := 0
	Local nLimitFat   := 0

	If !self:GetFltrFA() .And. Empty(Self:oTmpLimite) //Se não for fatura adicional
		Aadd(aStruAdic, {"TEMTS"  , "TEMTS"  , "C", 1, 0, "@!"})
		Aadd(aStruAdic, {"TEMLT"  , "TEMLT"  , "C", 1, 0, "@!"})
		Aadd(aStruAdic, {"TEMDP"  , "TEMDP"  , "C", 1, 0, "@!"})
		Aadd(aStruAdic, {"TEMFX"  , "TEMFX"  , "C", 1, 0, "@!"})
		Aadd(aStruAdic, {"TEMFA"  , "TEMFA"  , "C", 1, 0, "@!"})
		Aadd(aStruAdic, {"SEPARA" , "SEPARA" , "C", 1, 0, "@!"})
		Aadd(aStruAdic, {"TEMLM"  , "TEMLM"  , "C", 1, 0, "@!"})
		Aadd(aStruAdic, {"FILIAL" , "FILIAL" , "C", TamSx3('NT0_FILIAL')[1], 0, "@!"})
		Aadd(aStruAdic, {"CCONTR" , "CCONTR" , "C", TamSx3('NT0_COD')[1]   , 0, "@!"})
		Aadd(aStruAdic, {"CCESC"  , "CCESC"  , "C", TamSx3('NT0_CESCR')[1] , 0, "@!"})
		Aadd(aStruAdic, {"CCLIEN" , "CCLIEN" , "C", TamSx3('NVE_CCLIEN')[1], 0, "@!"})
		Aadd(aStruAdic, {"CLOJA"  , "CLOJA"  , "C", TamSx3('NVE_LCLIEN')[1], 0, "@!"})
		Aadd(aStruAdic, {"CCASO"  , "CCASO"  , "C", TamSx3('NVE_NUMCAS')[1], 0, "@!"})
		Aadd(aStruAdic, {"VLRBAS" , "VLRBAS" , "N", TamSx3('NT0_VLRBAS')[1], 0, "@!"})

		nTamIdxAdic := TamSx3('NT0_FILIAL')[1] + TamSx3('NT0_COD')[1] + TamSx3('NVE_CCLIEN')[1] + TamSx3('NVE_LCLIEN')[1] + TamSx3('NVE_NUMCAS')[1]
		aIdxAdic    := {{'01', 'FILIAL+CCONTR+CCLIEN+CLOJA+CCASO', nTamIdxAdic}}

		cAlsLimite      := GetNextAlias()
		Self:oTmpLimite := JurCriaTmp(cAlsLimite, Self:GetQryTmpLM(), "NT0", aIdxAdic, aStruAdic)[1]
		dDtEmi          := JURA203G('FT', Date(), 'FATEMI')[1]
		cNameCtrTmp     := Self:oTmpContr:GetRealName()

		// Filtra somente contratos que utilizam limite geral ou por fatura
		cQryCtrLim := " SELECT TMP.* "
		cQryCtrLim +=   " FROM " + cNameCtrTmp + " TMP"
		cQryCtrLim +=  " INNER JOIN " + RetSqlName("NTH") + " NTH"
		cQryCtrLim +=     " ON NTH.NTH_FILIAL = '" + xFilial("NTH") + "'"
		cQryCtrLim +=    " AND NTH.NTH_CTPHON = TMP.NT0_CTPHON"
		cQryCtrLim +=    " AND (NTH.NTH_CAMPO = 'NT0_VLRLI' OR NTH.NTH_CAMPO = 'NT0_VLRLIF')"
		cQryCtrLim +=    " AND NTH.NTH_OBRIGA = '1'"
		cQryCtrLim +=    " AND NTH.D_E_L_E_T_ = ' '"

		cAlsCtrLim := GetNextAlias()
		DbUseArea(.T., "TOPCONN", TcGenQry(,, cQryCtrLim), cAlsCtrLim, .T., .F.)

		While (cAlsCtrLim)->(! Eof())

			If cContr != (cAlsCtrLim)->NT0_COD //Verifica os tipos de honorarios do contrato com Limite geral ou por fatura ou a combinação dos dois.
				nLimite   := 0
				nLimitGer := 0
				nLimitFat := 0

				If (lLimitGer := JurGetDados("NTH", 1, xFilial("NTH") + (cAlsCtrLim)->NT0_CTPHON + "NT0_VLRLI", 'NTH_OBRIGA') == "1") //Limite geral
					nLimitGer := JURA201G("2", (cAlsCtrLim)->NT0_CMOELI, "", (cAlsCtrLim)->NT0_COD, Self:cTpExec, dDtEmi, self:cPreFat, lApagaPre, lApagaMin, "2")
				EndIf

				If (lLimitFat := JurGetDados("NTH", 1, xFilial("NTH") + (cAlsCtrLim)->NT0_CTPHON + "NT0_VLRLIF", 'NTH_OBRIGA') == "1") //Limite por fatura
					nLimitFat := JURA201G("1", (cAlsCtrLim)->NT0_CMOELI, "", (cAlsCtrLim)->NT0_COD, Self:cTpExec, dDtEmi, self:cPreFat, lApagaPre, lApagaMin)
				EndIf

				If lLimitGer .And. lLimitFat
					nLimite := Iif(nLimitGer < nLimitFat, nLimitGer, nLimitFat)
				ElseIf lLimitFat
					nLimite := nLimitFat
				EndIf

				cContr := (cAlsCtrLim)->NT0_COD
			EndIf

			If nLimite > 0 // Verifica se existe limite
				RecLock(cAlsLimite, .T.)
				(cAlsLimite)->NW2_COD    := (cAlsCtrLim)->NW2_COD
				(cAlsLimite)->CCONTR     := (cAlsCtrLim)->NT0_COD
				(cAlsLimite)->CCESC      := (cAlsCtrLim)->NT0_CESCR
				(cAlsLimite)->VLRBAS     := 0
				(cAlsLimite)->NT0_CRELAT := (cAlsCtrLim)->NT0_CRELAT
				(cAlsLimite)->CCLIEN     := (cAlsCtrLim)->NUT_CCLIEN
				(cAlsLimite)->CLOJA      := (cAlsCtrLim)->NUT_CLOJA
				(cAlsLimite)->CCASO      := (cAlsCtrLim)->NUT_CCASO
				(cAlsLimite)->TEMTS      := "2"
				(cAlsLimite)->TEMDP      := "2"
				(cAlsLimite)->TEMLT      := "2"
				(cAlsLimite)->TEMFX      := "2"
				(cAlsLimite)->TEMFA      := "2"
				(cAlsLimite)->SEPARA     := "2"
				(cAlsLimite)->TEMLM      := "1"

				(cAlsLimite)->(MsUnLock())
			EndIf
			(cAlsCtrLim)->(DbSkip())
		EndDo

		(cAlsCtrLim)->(DbCloseArea())
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DelTmpContrato()
Deleta a tabela temporária de contratos passiveis de emissão para gerar a
pré-fatura de lançamentos

@author Bruno Ritter
@since 13/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method DelTmpContrato() Class TJPREFATPARAM

	If !Empty(Self:oTmpContr) //Se não for fatura adicional
		Self:oTmpContr:Delete()
		Self:oTmpContr := Nil
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DelTmpLimite()
Deleta a tabela temporária de contratos com limite passiveis de emissão para gerar a
pré-fatura

@author Bruno Ritter
@since 13/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method DelTmpLimite() Class TJPREFATPARAM

	If !Empty(Self:oTmpLimite) //Se não for fatura adicional
		Self:oTmpLimite:Delete()
		Self:oTmpLimite := Nil
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JSerialize()
Excluí a tabela temporária de contratos antes de serializar o objeto,
pois ocorre uma exceção devido o Serialize não conseguir executar no
objeto gerado pelo FWTemporaryTable que está como propriedade no TJurPreFat.

@author Bruno Ritter
@since 13/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method JSerialize() Class TJPREFATPARAM
	Local cObj := ""

	Self:DelTmpContrato()
	Self:DelTmpLimite()
	cObj := Self:Serialize()

Return cObj

//-------------------------------------------------------------------
/*/{Protheus.doc} JFilVigCtr
Filtra lançamentos considerando a data de vigência do contrato

@param   cDataIni , caracatere, Data inicial digitada na tela de emissão
@param   cDataFim , caracatere, Data final digitada na tela de emissão
@param   cCampo   , caracatere, Campo para filtro de data
@param   lAndFim  , logico    , Se .T. insere o concatenador "AND" no final da query

@return  cQryVig  , caractere , Query de filtro com as datas

@author  Jonatas Martins
@since   06/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JFilVigCtr(cDataIni, cDataFim, cCampo, lAndFim)
	Local cQryVig    := ""
	Local cSpaceDT   := Space(8)

	Default cDataIni := "''"
	Default cDataIni := "''"
	Default cCampo   := "''"
	Default lAndFim  := .T.

	If NT0->(ColumnPos("NT0_DTVIGI")) > 0 // Proteção
		cQryVig += IIF(lAndFim, "", "AND ") + cCampo + " >= (CASE WHEN TMP.NT0_DTVIGI > '" + cSpaceDT + "' AND TMP.NT0_DTVIGI > '" + cDataIni + "' "
 		cQryVig += " THEN TMP.NT0_DTVIGI ELSE '" + cDataIni + "' END) AND " + CRLF
		cQryVig += cCampo + " <= (CASE WHEN TMP.NT0_DTVIGF > '" + cSpaceDT + "' AND TMP.NT0_DTVIGF < '" + cDataFim + "' "
		cQryVig +=  " THEN TMP.NT0_DTVIGF ELSE '" + cDataFim + "' END) " + IIF(lAndFim, "AND ", "")
	Else
		cQryVig += IIF(lAndFim, "", "AND ") + cCampo + " >= '" + cDataIni + "' AND "
		cQryVig += cCampo + " <= '" + cDataFim + "' " + IIF(lAndFim, "AND ", "")
	EndIf

Return (cQryVig)
