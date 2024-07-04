#INCLUDE "JURA125.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA125
Validações do Faturam. Por Faixa de Valores

@author Fabio Crespo Arruda
@since 23/09/09
@version 1.0
/*/
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Faz a validação das faixas para não ficarem sobrepostas

@author Fabio Crespo Arruda
@since 23/09/09
@version 1.0

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

/*/
//-------------------------------------------------------------------
Function JA125VLFX( oGrid, cIdModel, lVldTpVal )
Local lRet       := .T.
Local cMsg       := ""
Local cMdlId     := oGrid:GetId()
Local cCmpVlrIni := If(cMdlId == 'NTRDETAIL',"NTR_VLINI",'OI5_VLRINI')
Local cCmpVlrFim := If(cMdlId == 'NTRDETAIL',"NTR_VLFIM",'OI5_VLRFIN')
Local cCmpCod    := If(cMdlId == 'NTRDETAIL',"NTR_COD"  ,'OI5_SEQ')

Default lVldTpVal := .T.

	If !oGrid:IsDeleted()
	
		If Empty(oGrid:GetValue(cCmpVlrFim))
			cMsg := STR0009 //"A faixa de faturamento deve ser preenchida"
			lRet := .F.
		EndIF
	
		//Valor inicial menor do que o final
		If lRet .And. oGrid:GetValue(cCmpVlrIni) > oGrid:GetValue(cCmpVlrFim)
			cMsg := STR0001	//"O Valor inicial deve ser menor ou igual  ao valor final"
			lRet := .F.
		EndIf
	
		//Faixas sobrepostas
		If lRet .And. !(JVldFaixas(oGrid, cCmpVlrIni, cCmpVlrFim, cCmpCod) == 0)
			cMsg := STR0002 //"Esta faixa esta em conflito com as outras, favor verificar o cadastro"
			lRet := .F.
		EndIf

		//Valida o preenchimento do Cód tab Hon quando o Tipo Valor é "4"
		If lRet .And. lVldTpVal .and. (oGrid:GetValue("NTR_TPVL") == '4' .And. Empty(oGrid:GetValue("NTR_CTABH"))) 
			cMsg := STR0010 //"Para este Tipo de Valor é necessário preencher a Tabela de Honorários."
			lRet := .F.
		EndIf
		
		If !lRet
			JurMsgErro(cMsg)
		Endif	

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Faz a validação dos valores de como será cobrada a faixa

@author Fabio Crespo Arruda
@since 23/09/09
@version 1.0

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

/*/
//-------------------------------------------------------------------
Function JA125VLTP( oModel, cId, cTpCalc )
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaNTR := NTR->( GetArea() )
Local aAreaNT0 := NT0->( GetArea() )
Local cVlIni
Local cVlFim
Local cTpVL
Local cTabH 
Local nQtd     := 0, nI
Local oModelGrid
Local nSucesso := 0
Local cTpHon   := FwFldGet('NT0_CTPHON')

  oModelGrid := oModel //:GetModel(cId) 
	nQtd       := oModelGrid:GetQtdLine()
	For nI:=1 To oModelGrid:GetQtdLine()

		oModelGrid:GoLine( nI )
		If !oModelGrid:IsDeleted(nI)
	    cVlIni := FwFldGet('NTR_VLINI', nI)
	    cVlFim := FwFldGet('NTR_VLFIM', nI)
	    cTpVL  := FwFldGet('NTR_TPVL' , nI)
	    cValor := FwFldGet('NTR_VALOR', nI)
	    cTabH  := FwFldGet('NTR_CTABH', nI)
			//cTpCalc -> 1=Valor;2=Hora
			//cTpVL   -> 1=Valor Fixo;2=Valor Unitário;3=% a Cobrar;4=Tab Honorários

			Do Case
	    Case (cTpCalc == '1' ) .AND. (cTpVL == '2' .OR. cTpVL == '4')  //Bloq  valor com Vlr Unitário para faixas em Valor e tab h
	      JurMsgErro(STR0003)  //"Faixas por valor só permitem o tipo 'Valor Fixo' ou 'Perc Desconto'"
	      lRet := .F.
	    Case cTpCalc == '1' .AND. !Empty(cTabh) // Bloq Hora com Tab h vazia
	      JurMsgErro(STR0004) //"Não é possível preencher a Tabela de Honorários para esta opção de Cálculo "
	      lRet := .F.
	    Case cTpCalc == '2' .AND. cTpVL == '2'  // "Faixas por valor só permitem o tipo 'Valor Fixo', 'Perc Desconto' ou 'Tab de Honorários'"
	      JurMsgErro(STR0005)
	      lRet := .F.
	    Case cTpCalc == '2' .AND. (cTpVL == '4' .AND. Empty(cTabh) )   // Bloq Hora com Vlr Unitário ou Tab h vazia
	      JurMsgErro(STR0006) //"Para esta opção de Cálculo a Tabela de Honorários deve ser preenchida "
	      lRet := .F.
	    Case JUR96FAIXA(cTpHon) .AND. (cTpVL == '3' .OR. cTpVL == '4') //Quantidade de Casos e % Desc
	      JurMsgErro(STR0007) //"Faixas por Quantidade de Caos só permitem o tipo 'Valor Fixo' ou 'Valor Unitário'"
	      lRet := .F.
	    Case JUR96FAIXA(cTpHon) .AND. !EMPTY(cTabH) //Quantidade de Casos e % Desc
	      JurMsgErro(STR0004) //"Não é possível preencher a Tabela de Honorários para esta opção de Cálculo "
	      lRet := .F.
	    End Case

			nSucesso++

		Else
			nQtd--
		EndIf

	next

  RestArea( aAreaNT0 )
  RestArea( aAreaNTR )
  RestArea( aArea )

	lRet := lRet .And. nQtd == nSucesso

Return lRet
