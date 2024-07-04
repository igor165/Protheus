#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

//--------------------------------------------------------------------
/*/{Protheus.doc} JURSXB(cTab,cSXB,aCampos,lVisualiza,lInclui,cFiltro,cFonte)
Função generica para consultas especificas

@Param cTab					Nome da tabela
@Param cSXB					Nome da consulta específica
@Param aCampos				Array com os campos que devem ser exibidos no grid
@Param lVisualiza		Define se o botão Visualizar será apresentado. Padrão .T.
@Param lInclui				Define se o botão Incluir será apresentado. Padrão .T.
@Param cFiltro				Filtro (where) que será concatenado na query. Obs.: Sem o AND no inicio.
@Param cFonte				Nome do fonte (JURAXXX), Utilizado
@Param lExibeDados	Indica se a consulta apresenta dados na sua abertura. .T. = Apresenta dados / .F. = Não presenta dados
                      Se for .F. também não permite realizar pesquisa com filtro em branco. Padrão .T.
@Param nReduz Percentual de redução da view quando é informado o fonte
@Param lAltForVar  Define se o botão Alterar será apresentado. Padrão .F.

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
Default lAltForVar := .F. //-- Define se irá exibir os botões de Inclusao e Alteração na consulta padrão dos campos de Foro e Vara no Grid NUQ, no processo

// Consulta do Tipo SX5
If Len(cTab) == 2 

	lVisualiza := .F.
	lInclui    := .F.
	lAltera    := .F.

	aCampos := {"X5_CHAVE","X5_DESCRI"}
	cFiltro := "X5_TABELA == '" + cTab + "'"
Else

	// Verifica se existe ponto de entrada para customização
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

//-- Verifica se serão apresentados os botões de Incluir e Alterar na consulta padrão de Foro e Vara
If !lIsPesq

	If ( cTab == 'NQC' .OR. cTab == 'NQE' ) .AND. lInclui 
		lAltera := lAltForVar
	EndIf

//-- Se esta na tela de pesquisa ou em outra tela que não é JURA095, não é permitido apresentar os botões para operações na tela de SXB	
Else
	If ( cTab == 'NQ6' .OR. cTab == 'NQC' .OR. cTab == 'NQE' )
		lVisualiza := .F.
		lInclui    := .F.
		lAltera    := .F.
	EndIf
EndIf

// Função genérica para consultas especificas
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
@param lVisualiza	- Define se o botão Visualizar será apresentado. Padrão .T.
@param lInclui		- Define se o botão Incluir será apresentado. Padrão .T.
@param cFiltro		- Filtro (where) que será concatenado na query. Obs.: Sem o AND no inicio.
@param cFonte		- Nome do fonte (JURAXXX), Utilizado
@param lExibeDados	- Indica se a consulta apresenta dados na sua abertura. .T. = Apresenta dados / .F. = Não presenta dados
                      Se for .F. também não permite realizar pesquisa com filtro em branco. Padrão .T.

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
	
		JurMsgErro("Não foram informados os campos da consulta.")
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
		
		//Verifica se existe ponto de entrada para customização
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
		
		//Função genérica para consultas especificas
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