#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

//--------------------------------------------------------------------
/*/{Protheus.doc} JURSXB(cTab,cSXB,aCampos,lVisualiza,lInclui,cFiltro,cFonte)
Fun��o generica para consultas especificas

@Param cTab					Nome da tabela
@Param cSXB					Nome da consulta espec�fica
@Param aCampos				Array com os campos que devem ser exibidos no grid
@Param lVisualiza		Define se o bot�o Visualizar ser� apresentado. Padr�o .T.
@Param lInclui				Define se o bot�o Incluir ser� apresentado. Padr�o .T.
@Param cFiltro				Filtro (where) que ser� concatenado na query. Obs.: Sem o AND no inicio.
@Param cFonte				Nome do fonte (JURAXXX), Utilizado
@Param lExibeDados	Indica se a consulta apresenta dados na sua abertura. .T. = Apresenta dados / .F. = N�o presenta dados
                      Se for .F. tamb�m n�o permite realizar pesquisa com filtro em branco. Padr�o .T.
@Param nReduz Percentual de redu��o da view quando � informado o fonte
@Param lAltForVar  Define se o bot�o Alterar ser� apresentado. Padr�o .F.

@Return lResult .T. - Indica que algum registro foi selecionado
                  .F. - Indica que nenhum registro foi selecionado (a consulta foi fechada)

@author Jorge Luis Branco Martins Junior
@since 31/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURSXB(cTab,cSXB,aCampos,lVisualiza,lInclui,cFiltro,cFonte,lExibeDados,nReduz, lAltForVar)
Local aArea     := GetArea()
Local lResult   := .F.
Local nResult   := 0
Local cSQL      := ""
Local aRetPE    := {}
Local lAltera   := .F.
Local lIsPesq   := IsPesquisa()

Default aCampos    := {}
Default lVisualiza := .T.
Default lInclui    := .T.
Default cFiltro    := ""
Default cFonte     := ""
Default lExibeDados:= .T.
Default lAltForVar := .F. //-- Define se ir� exibir os bot�es de Inclusao e Altera��o na consulta padr�o dos campos de Foro e Vara no Grid NUQ, no processo

// Consulta do Tipo SX5
If Len(cTab) == 2 

	lVisualiza := .F.
	lInclui    := .F.
	lAltera    := .F.

	aCampos := {"X5_CHAVE","X5_DESCRI"}
	cFiltro := "X5_TABELA == '" + cTab + "'"
Else

	// Verifica se existe ponto de entrada para customiza��o
	If Existblock(cSXB)
	
		aRetPE := Execblock(cSXB, .F., .F.,{aCampos, lVisualiza, lInclui, cFiltro, cFonte, cSQL})
		
		If ValType(aRetPE) == "A" .And. Len(aRetPE) == 6
			aCampos	   := aRetPE[1]
			lVisualiza := aRetPE[2]
			lInclui	   := aRetPE[3]
			cFiltro	   := aRetPE[4]
			cFonte	   := aRetPE[5]
			cSQL	   := aRetPE[6]
		EndIf
		aSize(aRetPE, 0)
	EndIf	
EndIf

//-- Verifica se ser�o apresentados os bot�es de Incluir e Alterar na consulta padr�o de Foro e Vara
If !lIsPesq

	If ( cTab == 'NQC' .OR. cTab == 'NQE' ) .AND. lInclui 
		lAltera := lAltForVar
	EndIf

//-- Se esta na tela de pesquisa ou em outra tela que n�o � JURA095, n�o � permitido apresentar os bot�es para opera��es na tela de SXB	
Else
	If ( cTab == 'NQ6' .OR. cTab == 'NQC' .OR. cTab == 'NQE' )
		lVisualiza := .F.
		lInclui    := .F.
		lAltera    := .F.
	EndIf
EndIf

// Fun��o gen�rica para consultas especificas
nResult := JurF3SXB(cTab, aCampos, cFiltro, lVisualiza, lInclui, cFonte, cSQL, lExibeDados, nReduz, lAltera)
lResult := nResult > 0

RestArea( aArea )

// Posiciona no registro retornado pela consulta
If lResult
	If Len(cTab) == 2
		DbSelectArea("SX5")
		SX5->(dbgoTo(nResult))
	Else
		DbSelectArea(cTab)
		&(cTab)->(dbgoTo(nResult))
	EndIf
endif

Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JSxbRa
Consulta especifica de Funcionarios retornando multi filiais  

@param aCampos		- Array com os campos que devem ser exibidos no grid
@param lVisualiza	- Define se o bot�o Visualizar ser� apresentado. Padr�o .T.
@param lInclui		- Define se o bot�o Incluir ser� apresentado. Padr�o .T.
@param cFiltro		- Filtro (where) que ser� concatenado na query. Obs.: Sem o AND no inicio.
@param cFonte		- Nome do fonte (JURAXXX), Utilizado
@param lExibeDados	- Indica se a consulta apresenta dados na sua abertura. .T. = Apresenta dados / .F. = N�o presenta dados
                      Se for .F. tamb�m n�o permite realizar pesquisa com filtro em branco. Padr�o .T.

@return lResult .T. - Indica que algum registro foi selecionado
                .F. - Indica que nenhum registro foi selecionado (a consulta foi fechada)

@author  Rafael Tenorio da Costa
@since	 30/05/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function JSxbRa(aCampos, lVisualiza, lInclui, cFiltro, cFonte, lExibeDados)

	Local aArea   := GetArea()
	Local lResult := .F.
	Local nResult := 0
	Local cSQL	  := ""
	Local aRetPE  := {}
	Local nCont	  := 0
	Local cTab	  := "SRA"
	
	Default aCampos     := {}
	Default lVisualiza  := .T.
	Default lInclui     := .T.
	Default cFiltro     := ""
	Default cFonte      := ""
	Default lExibeDados := .T.
	
	If Len(aCampos) == 0
	
		JurMsgErro("N�o foram informados os campos da consulta.")
	Else
	
		cSQL := "SELECT "
		
		//Carrega campos
		For nCont:=1 To Len(aCampos)
			cSQL += aCampos[nCont] + ", "
		Next nCont
		
		cSQL += "SRA.R_E_C_N_O_ RECNO FROM " + RetSqlName("SRA") + " SRA WHERE SRA.D_E_L_E_T_ = ' '"
		
		//Verifica se usuario tem acesso
		If !fChkAcesso()
			cSQL += " AND RA_MAT = 'SEM ACESSO'"
		EndIf
		
		//Verifica se existe ponto de entrada para customiza��o
		If Existblock("JSxbRa")
			
			aRetPE := Execblock("JSxbRa", .F., .F., {aCampos, lVisualiza, lInclui, cFiltro, cFonte, cSQL} )
			
			If ValType(aRetPE) == "A" .And. Len(aRetPE) == 6
				aCampos	   := aRetPE[1]
				lVisualiza := aRetPE[2]
				lInclui	   := aRetPE[3]
				cFiltro	   := aRetPE[4]
				cFonte	   := aRetPE[5]
				cSQL	   := aRetPE[6]
			EndIf
			
			aSize(aRetPE, 0)
		EndIf	
		
		//Fun��o gen�rica para consultas especificas
		nResult := JurF3SXB(cTab, aCampos, cFiltro, lVisualiza, lInclui, cFonte, cSQL, lExibeDados)
		lResult := nResult > 0
		
		RestArea( aArea )
		
		//Posiciona no registro retornado pela consulta
		If lResult
			DbSelectArea(cTab)
			&(cTab)->(dbgoTo(nResult))
		EndIf
	EndIf

Return lResult