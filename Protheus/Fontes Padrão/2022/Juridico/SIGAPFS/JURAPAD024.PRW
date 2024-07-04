#INCLUDE "JURAPAD024.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURAPAD024
Relatorio Crystal de Faturas Canceladas

@param, lAutomato, Se verdadeiro indica execução via automação
@param, cNameAuto, Nome do arquivo do relatório via a ser gerado pela automação

@author Antonio Carlos Ferreira
@since 07/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURAPAD024(lAutomato, cNameAuto)
	Local lRet      := .F.
	Local aArea     := GetArea()
	Local lPDUserAc := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)
	
	Default lAutomato := .F.
	Default cNameAuto  := ""

	If lPDUserAc
		If lAutomato .Or. Pergunte('JURAPAD024')
			JR024Relat(MV_PAR01, MV_PAR02, MV_PAR03, Str(MV_PAR04, 1), Str(MV_PAR05, 1), lAutomato, cNameAuto)
		Endif
	Else
		MsgInfo(STR0020, STR0021) // "Usuário com restrição de acesso a dados pessoais/sensíveis.", "Acesso restrito"
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JR024VldDt
Valida a data

@author Antonio Carlos Ferreira
@since 07/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JR024VldDt(nData,dDtIni,dDtFim)

Local lRet := .T.

If  (nData == 1)
    If  (dTos(dDtIni) > dTos(Date()))
		 lRet := .F.
		 ApMsgAlert(STR0016) // "Data Inicial para consulta não pode ser maior que a data atual! "
    EndIf
EndIf	
                                                                                 
If  lRet .And. !Empty(dTos(dDtIni)) .And. !Empty(dTos(dDtFim))
    If  (dTos(dDtFim) < dTos(dDtIni))
		 lRet := .F.
		 ApMsgAlert(STR0017) // "Data Final deve ser maior que a inicial. Verifique!"
    EndIf
EndIf

If  lRet .And. (nData == 2)
    If  (dTos(dDtFim) > dTos(Date()))
		 lRet := .F.
		 ApMsgAlert(STR0018) // "Não é possível emitir relatório com dados futuros"
    EndIf
EndIf

Return lRet   


//-------------------------------------------------------------------
/*/{Protheus.doc} JR024VldEsc
Valida o codigo do Escritorio

@author Mauricio Canalle
@since 24/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JR024VldEsc(cEscrit)
Local lRet := .T.
Local aArea := GetArea()

	If !Empty(cEscrit)
	   If Empty(Posicione("NS7", 1, xFilial("NS7")+cEscrit, "NS7_COD"))
	      ApMsgAlert(STR0005)  // "Código não encontrado no cadastro!"   
	      lRet := .F.
	   Endif
	EndiF

	Restarea(aArea)

Return lRet	
   

//-------------------------------------------------------------------
/*/{Protheus.doc} JR024Relat
Rotina para o processamento do relatorio em Crystal.

@author Antonio Carlos Ferreira
@since 07/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JR024Relat(dDtIni, dDtFim, cEscritorio, cQuebra, cResult, lAutomato, cNameAuto)

Local lRet		   := .T.
Local cRelatorio := "JURAPAD024"
Local cArquivo   := "JURAPAD024" 
Local cModRel     := SuperGetMV('MV_JMODREL',,'1')  // TIPO DE RELATORIO 1 CRYSTAL, 2 FWMSPRINT
Local lJURRPAD024 := ExistBlock('JURRPAD024')


Begin Sequence

    If  Empty(dDtIni) .Or. Empty(dDtFim) .Or. Empty(cQuebra) .Or. Empty(cResult)
        lRet := .F.
        ApMsgAlert(STR0019) // "Alguns dos parâmetros não foram preenchidos! Verifique!"
        Break
    EndIf
    
    If cModRel == '1' .And. !lAutomato // CRYSTAL
    	/*
    	CALLCRYS (rpt , params, options), onde:
    	rpt = Nome do relat?rio, sem o caminho.
    	params = Par?metros do relat?rio, separados por v?rgula ou ponto e v?rgula. Caso seja marcado este par?metro, ser?o desconsiderados os par?metros marcados no SX1.
    	options = Op??es para n?o se mostrar a tela de configura??o de impress?o , no formato x;y;z;w ,onde:
    	x = Impress?o em V?deo(1), Impressora(2), Impressora(3), Excel (4), Excel Tabular(5), PDF(6) e?Texto?(7)?.
    	y = Atualiza Dados  ou n?o(1)
    	z = N?mero de C?pias, para exporta??o este valor sempre ser? 1.
    	w =T?tulo do Report, para exporta??o este ser? o nome do arquivo sem extens?o.
    	*/

    	cOptions := cResult + ";0;1;"

	
    	cParams  := dtos(dDtIni) + ";" + dtos(dDtFim) + ";" + ;
    				cEscritorio + ";" + cQuebra + ";" + ;
    				Posicione("CTO",1,xFilial("CTO")+SuperGetMv("MV_JMOENAC",,"01"),"CTO_SIMB") + ";" + ;
    				SuperGetMv("MV_JMOENAC",,"01") + ";"
		
    	JCallCrys( cRelatorio, cParams, cOptions + cArquivo, .T., .T., .F.)
    Else
        If lJURRPAD024
        	ExecBlock('JURRPAD024', .F., .F.)
        Else
        	JURRPAD024(dDtIni, dDtFim, cEscritorio, cQuebra, cRelatorio, lAutomato, cNameAuto)
    	Endif   	
    Endif

End Sequence

Return lRet
