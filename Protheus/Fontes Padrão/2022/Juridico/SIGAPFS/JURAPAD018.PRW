#INCLUDE "JURAPAD018.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURAPAD018
Relatorio Crystal/FWMSPrinter de Detalhes de Despesas.

@param, lAutomato, lógico   , Se verdadeiro indica execução via automação
@param, cNameAuto, caractere, Nome do arquivo do relatório via a ser gerado pela automação

@author Antonio Carlos Ferreira
@since 08/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURAPAD018(lAutomato, cNameFile)
	Local lRet      := .F.
	Local aArea     := GetArea()
	Local cLojaAuto := SuperGetMv( "MV_JLOJAUT" , .F. , "2" ,  ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
	Local lPDUserAc := lAutomato .Or. Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)
	Local cPergunte := IIF(cLojaAuto == "1",'JURPAD018B', 'JURAPAD018')

	Default lAutomato := .F.
	Default cNameFile := ""

	If lPDUserAc
		If lAutomato .Or. Pergunte(cPergunte)
			If cLojaAuto == "1"
				JR018Relat(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, IIF(lAutomato, "", JurGetLjAt()), MV_PAR05, Str(MV_PAR06, 1), MV_PAR07, Str(MV_PAR08, 1), lAutomato, cNameFile)
			Else
				JR018Relat(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, Str(MV_PAR07, 1), MV_PAR08, Str(MV_PAR09, 1), lAutomato, cNameFile)
			EndIf
		EndIf
	Else
		MsgInfo(STR0025, STR0026) // "Usuário com restrição de acesso a dados pessoais/sensíveis.", "Acesso restrito"
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JR018VldDt
Valida a data

@author Antonio Carlos Ferreira
@since 08/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JR018VldDt(nData,dDtIni,dDtFim)

Local lRet := .T.

If  (nData == 1)
    If  (dTos(dDtIni) > dTos(Date()))
		 lRet := .F.
		 ApMsgAlert(STR0020) // "Data Inicial para consulta não pode ser maior que a data atual!"
    EndIf
EndIf	
                                                                                 
If  lRet .And. !Empty(dTos(dDtIni)) .And. !Empty(dTos(dDtFim))
    If  (dTos(dDtFim) < dTos(dDtIni))
		 lRet := .F.
		 ApMsgAlert(STR0021) // "Data Final deve ser maior que a inicial. Verifique!"
    EndIf
EndIf

If  lRet .And. (nData == 2)
    If  (dTos(dDtFim) > dTos(Date()))
		 lRet := .F.
		 ApMsgAlert(STR0022) // "Não é possível emitir relatório com dados futuros"
    EndIf
EndIf

Return lRet   


//-------------------------------------------------------------------
/*/{Protheus.doc} JR018VldMoe
Valida o codigo da Moeda     

@author Mauricio Canalle
@since 24/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JR018VldMoe(cMoeda)
Local lRet := .T.
Local aArea := GetArea()

	If !Empty(cMoeda)
	   If Empty(Posicione("CTO", 1, xFilial("CTO")+cMoeda, "CTO_MOEDA"))
	      ApMsgAlert(STR0005)  // "Código não encontrado no cadastro!"   
	      lRet := .F.
	   Endif
	EndiF

	Restarea(aArea)

Return lRet	


//-------------------------------------------------------------------
/*/{Protheus.doc} JR018VldDes
Valida o codigo do Tipo de Despesa

@author Mauricio Canalle
@since 24/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JR018VldDes(cTpDes)
Local lRet := .T.
Local aArea := GetArea()

	If !Empty(cTpDes)
	   If Empty(Posicione("NRH", 1, xFilial("NRH")+cTpDes, "NRH_COD"))
	      ApMsgAlert(STR0005)  // "Código não encontrado no cadastro!"   
	      lRet := .F.
	   Endif
	EndiF

	Restarea(aArea)

Return lRet	


//-------------------------------------------------------------------
/*/{Protheus.doc} JR018VldCli
Valida o codigo do Cliente

@author Mauricio Canalle
@since 24/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JR018VldCli(cCliente)
Local lRet      := .T.
Local aArea     := GetArea()

	If !Empty(cCliente)
		If FindFunction("JurVldCli")
			lRet := JurVldCli(, cCliente, , , ,"CLI", )
		Else
			If Empty(Posicione("NUH", 1, xFilial("NUH")+cCliente, "NUH_COD"))
				ApMsgAlert(STR0005)  // "Código não encontrado no cadastro!"   
				lRet := .F.
			EndIf
		EndiF
	EndIf

	Restarea(aArea)

Return lRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} JR018VldLoja
Valida o codigo do Cliente + Loja

@author Mauricio Canalle
@since 24/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JR018VldLoja(cCliente, cLoja)
Local lRet := .T.
Local aArea := GetArea()

	If !Empty(cCliente) .and. Empty(cLoja)
	      ApMsgAlert(STR0024)  // "Informe o código da loja do cliente" 
	      lRet := .F.	
	Endif

	If lRet .AND. !Empty(cCliente) .and. !Empty(cLoja)
		If FindFunction("JurVldCli")
			lRet := JurVldCli(, cCliente, , , ,"LOJ", )		
		Else
			If Empty(Posicione("NUH", 1, xFilial("NUH")+cCliente+cLoja, "NUH_COD"))
				ApMsgAlert(STR0005)  // "Código não encontrado no cadastro!"   
				lRet := .F.
			Else
				If Posicione("NUH", 1, xFilial("NUH")+cCliente+cLoja, "NUH->NUH_PERFIL")   <> '1'
					ApMsgAlert(STR0008)  // "Cliente cadastrado como somente pagador!"   
					lRet := .F.
				Endif
			Endif
		EndIf
	EndIf

	Restarea(aArea)

Return lRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} JR018VldGrp
Valida o codigo do Grupo de Cliente

@author Mauricio Canalle
@since 24/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JR018VldGrp(cGrpCli)
Local lRet := .T.
Local aArea := GetArea()

	If !Empty(cGrpCli)
	   If Empty(Posicione("ACY", 1, xFilial("ACY")+cGrpCli, "ACY_GRPVEN"))
	      ApMsgAlert(STR0005)  // "Código não encontrado no cadastro!"   
	      lRet := .F.
	   Endif
	EndiF

	Restarea(aArea)

Return lRet	


//-------------------------------------------------------------------
/*/{Protheus.doc} JR018Relat
Rotina para o processamento do relatorio em Crystal.

@author Antonio Carlos Ferreira
@since 08/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JR018Relat(dDtIni, dDtFim, cGrpCliente, cCliente, cLoja, cMoeda, cQuebra, cTpDespesa, cResultado, lAutomato, cNameFile)

Local lRet		   := .T.
Local cRelatorio := "JURAPAD018"
Local cArquivo   := "JURAPAD018" 
Local aTables    := {'NVZ'}
Local cModRel     := SuperGetMV('MV_JMODREL',,'1')  // TIPO DE RELATORIO 1 CRYSTAL, 2 FWMSPRINT
Local lJURRPAD018 := ExistBlock('JURRPAD018')


Begin Sequence

    If  Empty(dDtIni) .Or. Empty(dDtFim) .Or. Empty(cQuebra) .Or. Empty(cResultado)
        lRet := .F.
        ApMsgAlert(STR0023) // "Alguns dos parâmetros não foram preenchidos! Verifique!"
        Break
    EndIf

    If cModRel == '1'   // CRYSTAL
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
    	cOptions := cResultado + ";0;1;"

    	cParams  := dtos(dDtIni) + ";" + dtos(dDtFim) + ";" + ;
    				cGrpCliente + ";" + cCliente + ";" + cLoja + ";" + cMoeda + ";" + cQuebra + ";" + cTpDespesa + ";"
		
    	JCallCrys( cRelatorio, cParams, cOptions + cArquivo, .T., .T., .F., aTables )
    Else
        IIF( lJURRPAD018,;
        	ExecBlock('JURRPAD018', .F., .F.),;
            JURRPAD018(dDtIni, dDtFim, cGrpCliente, cCliente, cLoja, cMoeda, cQuebra, cTpDespesa, IIF(!lAutomato, cRelatorio, cNameFile), lAutomato) )
    EndIf

End Sequence

Return lRet
