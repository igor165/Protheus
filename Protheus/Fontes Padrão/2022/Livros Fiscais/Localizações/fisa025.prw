#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "FISA025.ch"
#INCLUDE 'FWLIBVERSION.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FISA025  ³ Autor ³ Ivan Haponczuk        ³ Data ³ 10.08.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta de impostos / retencoes - Argentina                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Fiscal - Argentina                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR    ³ DATA   ³  BOPS  ³  MOTIVO DA ALTERACAO                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Emanuel V.V.    ³29/01/14³        ³Se agrega a la consulta la opcion de  ³±±
±±³                ³        ³        ³retenciones SLI (Servicios de Limpie- ³±±
±±³                ³        ³        ³za.                                   ³±±
±±³Marco A. Glez R.³27/02/17³MMI-216 ³Se realiza replica para V12.1.14, que ³±±
±±³                ³        ³        ³permite seleccion de sucursales y ajus³±±
±±³                ³        ³        ³te de campo filial en consulta. (ARG) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FISA025(lAutomato)

	Local nCliFor	:= 0            //1-Fornecedor, 2-Cliente
	Local dDatIni	:= dDatabase    //Data de inicio do periodo
	Local dDatFim	:= dDataBase    //Data do fim do periodo
	Local cAlias	:= ""           //Alias da tabela que vai ser usada (SFE/SF3)
	Local cTipImp	:= ""           //I-Imposto, P-Percepção, R-Retenção
	Local cCmbCli	:= ""           //Fornecedor/Cliente
	Local cCmbTip	:= ""           //Tipo do imposto
	Local cCmbDoc	:= ""           //Tipo do documento
	Local cCmbSer	:= ""           //Serie do documento
	Local cCmbRet	:= ""           //Numero do comprovante de rentacao
	Local cProv		:= ""           //Provincia
	Local cDocNum	:= Space(12)    //Numero do documento
	Local cCodIni	:= Space(TamSx3("A2_COD")[1])     //Codigo inicial do cli/for
	Local cLojIni	:= Space(2)     //Loja inicial do cli/for
	Local cCodFin	:= Space(TamSx3("A2_COD")[1])    //Codigo final do cli/for
	Local cLojFin	:= Space(2)     //Loja final do cli/for
	Local aClassif	:= {}           //Array com as classificações fiscais selecionadas
	Local aImps		:= {}           //Vetor com impostos classificados
	Local aConcep	:= {}           //Vetor com os conceitos de acordo com as classificacoes fiscais
	Local aHead		:= {}           //Cabecalho da getdados a ser apresentada
	Local lOk		:= .F.          //Variável que controla se o processo esta certo
	Local cMunicip	:= ""

	Private lChk01		:= .T.	//Consulta por classe
	Private lChk02		:= .F.	//Consulta especifica por documento
	Private lChk03		:= .F.	//Consulta por comprovante de retencao
	Private aSelFil		:= {}
	Private aCpoTmpSF3	:= {}
	Private aCpoTmpSFE	:= {}
	Private cQRYCON		:= ""
	Private oTmpTable	:= Nil

    Default lAutomato	:= .F.
    
	dDatIni := STOD(SubStr(DTOS(dDataBase),1,6)+"01")

	If !(Tela4(lAutomato))
		Return
	EndIf

	Do While !lOk
		lOk := Tela1(@nCliFor,@cTipImp,@dDatIni,@dDatFim,@cCmbCli,@cCmbTip,@cCmbDoc,@cCmbSer,@cDocNum,@cCmbRet,lAutomato)
		If !lOk
			Exit
		EndIf

		//+-----------------------+
		//| Consulta por classe   |
		//+-----------------------+
		If lOk .and. lChk01
			lOk := Tela2(nCliFor,cCmbCli,cTipImp,@cProv,@aClassif,@aConcep,@cCodIni,@cLojIni,@cCodFin,@cLojFin,@cMunicip,lAutomato)
			If lOk
				If cTipImp == "R" //para retencoes
					cAlias := "SFE"
					aHead  := FQryFE(nCliFor,dDatIni,dDatFim,,,cCodIni,cLojIni,cCodFin,cLojFin,cProv,aClassif,aConcep,cMunicip)
				Else //para impostos/percepcoes
					cAlias := "SF3"
					aHead :=  FQryF3(nCliFor,dDatIni,dDatFim,aImps,,,,cCodIni,cLojIni,cCodFin,cLojFin,aConcep,aClassif,cTipImp,cProv)
				EndIf
				METFIS025(cTipImp,aClassif,.T.)
			EndIf
		EndIf

		//+------------------------------------------------+
		//| Consulta especifica com documento              |
		//+------------------------------------------------+
		If lOk .and. lChk02
			If cCmbDoc $ "OP|RC" //Ordem de pago|Recibo
				cAlias := "SFE"
				aHead := FQryFE(nCliFor,dDatIni,dDatFim,cCmbDoc,cDocNum)
			Else //Para as demais especies
				cAlias := "SF3"
				aHead := FQryF3(nCliFor,dDatIni,dDatFim,aImps,cCmbDoc,cCmbSer,cDocNum)//,,,,,,aClassif,cTipImp,cProv
			EndIf
			METFIS025(cCmbDoc,aClassif,.F.)
		EndIf
		
		//+------------------------------------------------+
		//| Consulta por comprovante de retencao           |
		//+------------------------------------------------+
		If lOk .and. lChk03
			cAlias := "SFE"
			aHead := FQryFE(nCliFor,dDatIni,dDatFim,,cCmbRet)
		EndIf
	EndDo

	If lOk	
		If Len(aHead) > 0
			Tela3(cAlias,aHead,lAutomato)
		Else
			MsgAlert(STR0001)//Não há resultados para esta consulta.
		EndIf
	EndIf
	
	If oTmpTable <> Nil
		oTmpTable:Delete()
		oTmpTable := Nil
	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tela1    ³ Autor ³ Ivan Haponczuk      ³ Data ³ 11.08.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria a primeira tela de configurações.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nPar01 - Movimento ao (1=Fornecedor, 2=Cliente)            ³±±
±±³          ³ cPar02 - Tipo do imposto (I=Imposto, P=Percepção,          ³±±
±±³          ³          R=Retenção)                                       ³±±
±±³          ³ dPar03 - Data inicial do periodo                           ³±±
±±³          ³ dPar04 - Data final do periodo                             ³±±
±±³          ³ cPar05 - (Fornecedores/Clientes)                           ³±±
±±³          ³ cPar06 - (Impostos/Percepcoes/Retencoes)                   ³±±
±±³          ³ cPar07 - Especie do documento                              ³±±
±±³          ³ cPar08 - Serie do documento                                ³±±
±±³          ³ cPar09 - Numero do documento                               ³±±
±±³          ³ cPar10 - Numero do comprovante de retencao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet - .T. se confirmado e validado ou .F. caso contrario  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tela1(nCliFor,cTipImp,dDatIni,dDatFim,cCmbCli,cCmbTip,cCmbDoc,cCmbSer,cDocNum,cCmbRet,lAutomato)

	Local aCmbCli	:= {STR0002,STR0003}//Fornecedores###Clientes
	Local aCmbTip	:= {STR0004,STR0005,STR0006}//Impostos###Percepções###Retenções
	Local aCmbDoc	:= FaCmbDoc() //Lista as especies das notas
	Local aCmbSer	:= FaCmbSer() //Lista as series das notas
	Local aCmbRet	:= FRetCerts(1) //Lista as retencoes a fornecedores
	Local lOk		:= .F.
    Default lAutomato	:= .F.
	
IF !lAutomato
	oDlg01 := MSDialog():New(000,000,365,430,STR0007,,,,,,,,,.T.)//Consultar de Impostos

	//+------------------------------------------------+
	//| Periodo                                        |
	//+------------------------------------------------+
	@005,005 To 045,170 prompt STR0008 Pixel Of oDlg01//Período
	oSay01 := tSay():New(017,015,{||STR0009},oDlg01,,,,,,.T.,,,100,20)//Movimento de:
	oCmb01 := tComboBox():New(027,015,{|u|if(PCount()>0,cCmbCli:=u,cCmbCli)},aCmbCli,050,020,oDlg01,,{|| FChCliFor(aScan(aCmbCli,{|x| x == cCmbCli})) },,,,.T.)
	oSay02 := tSay():New(017,075,{||STR0010},oDlg01,,,,,,.T.,,,100,20)//Da data:
	oGet01 := TGet():New(027,075,{|u| if(PCount()>0,dDatIni:=u,dDatIni)},oDlg01,040,007,,,,,,,,.T.)
	oSay03 := tSay():New(017,120,{||STR0011},oDlg01,,,,,,.T.,,,100,20)//Até a data:
	oGet02 := TGet():New(027,120,{|u| if(PCount()>0,dDatFim:=u,dDatFim)},oDlg01,040,007,,,,,,,,.T.)

	oBtn01:=sButton():New(012,180,1,{|| lOk:=.T. ,oDlg01:End() },oDlg01,.T.,,)
	oBtn02:=sButton():New(028,180,2,{|| lOk:=.F. ,oDlg01:End() },oDlg01,.T.,,)

	//+------------------------------------------------+
	//| Por classe                                     |
	//+------------------------------------------------+
	@050,005 To 085,210 prompt STR0012 Pixel Of oDlg01//Por classe
	oChk01 := TCheckBox():New(065,015,"",{|| lChk01 },oDlg01,100,210,,,,,,,,.T.,,,)
	oChk01:bLClicked := {|| ChgChk(1) }
	oCmb02 := tComboBox():New(065,035,{|u| if(PCount()>0,cCmbTip:=u,cCmbTip)},aCmbTip,060,020,oDlg01,,,,,,.T.,,,,{|| lChk01 })

	//+------------------------------------------------+
	//| Especifica por documento                       |
	//+------------------------------------------------+		
	@090,005 To 137,210 prompt STR0013 Pixel Of oDlg01//Específica por documento
	oChk02 := TCheckBox():New(105,015,"",{|| lChk02 },oDlg01,100,210,,,,,,,,.T.,,,)
	oChk02:bLClicked := {|| ChgChk(2) }
	oSay04 := tSay():New(106,035,{||STR0014}  ,oDlg01,,,,,,.T.,,,100,20)//Tipo:
	oSay05 := tSay():New(106,085,{||STR0015} ,oDlg01,,,,,,.T.,,,100,20)//Série:
	oSay06 := tSay():New(106,125,{||STR0016},oDlg01,,,,,,.T.,,,100,20)//Número:
	oCmb03 := tComboBox():New(0117,035,{|u|if(PCount()>0,cCmbDoc:=u,cCmbDoc)},aCmbDoc,040,020,oDlg01,,,,,,.T.,,,,{|| lChk02 })
	oCmb04 := tComboBox():New(0117,085,{|u|if(PCount()>0,cCmbSer:=u,cCmbSer)},aCmbSer,030,020,oDlg01,,,,,,.T.,,,,{|| lChk02 .and. !(cCmbDoc$"OP|RC") })
	oGet03 := TGet():New(117,125,{|u| if(PCount()>0,cDocNum:=u,cDocNum)},oDlg01,070,007,,,,,,,,.T.,,,{|| lChk02 })

	//+------------------------------------------------+
	//| Por comprovante de retencao                    |
	//+------------------------------------------------+
	@142,005 To 177,210 prompt STR0017 Pixel Of oDlg01//Por comprovante de retenção
	oChk03 := TCheckBox():New(157,015,"",{|| lChk03 },oDlg01,100,210,,,,,,,,.T.,,,)
	oChk03:bLClicked := {|| ChgChk(3) }
	oCmbRet := tComboBox():New(0157,035,{|u|if(PCount()>0,cCmbRet:=u,cCmbRet)},aCmbRet,060,020,oDlg01,,,,,,.T.,,,,{|| lChk03 })
	oDlg01:Activate(,,,.T.,,,)
Else
   If FindFunction("GetParAuto")
	    aRetAuto := GetParAuto("FISA025TESTCASE")
	    cCmbCli 		:= aRetAuto[2]
	    dDatIni 		:= aRetAuto[3]
	    dDatFim 		:= aRetAuto[4]
	    cCmbTip 		:= aRetAuto[5]
	    ChgChk(aRetAuto[12])
	    lOk := .T.
	EndIf
Endif
	
	//+------------------------+
	//| 1 - Fornecedores       |
	//| 2 - Clientes           |
	//+------------------------+
	nCliFor := aScan(aCmbCli,{|x| x == cCmbCli})

	//+------------------------+
	//| I - Imposto            |
	//| P - Percepcao          |
	//| R - Retencao           |
	//+------------------------+
	cTipImp := SubStr(cCmbTip,1,1)

Return lOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ChgChk   ³ Autor ³ Ivan Haponczuk      ³ Data ³ 11.08.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz a selecao do checkbox clicado e remove as demais       ³±±
±±³          ³ selecoes.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nPar01 - Numero da opcao escolhida                         ³±±
±±³          ³          1 = Por classe                                    ³±±
±±³          ³          2 = Especifica por documento                      ³±±
±±³          ³          3 = Por comprovante de retencao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ChgChk(nChk)

	lChk01 := .F.
	lChk02 := .F.
	lChk03 := .F.

	If nChk == 1
		lChk01 := .T.
	ElseIf nChk == 2
		lChk02 := .T.
	Else
		lChk03 := .T.
	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FChCliFor³ Autor ³ Ivan Haponczuk      ³ Data ³ 11.08.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Recria as opcoes do combo de numero dos certificados.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nPar01 - Movimento ao (1=Fornecedor, 2=Cliente)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FChCliFor(nCliFor)

	Local aCerts := FRetCerts(nCliFor)

	oCmbRet:aItems := aCerts
	oCmbRet:Refresh()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FRetCerts³ Autor ³ Ivan Haponczuk      ³ Data ³ 11.08.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Busca os numeros dos certificados.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nPar01 - Movimento ao (1=Fornecedor, 2=Cliente)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet - Vetor com o numero dos certificados encontrados     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRetCerts(nCliFor)

	Local cQry   := ""
	Local aCerts := {""}
	Local cSucursal := ObtFilial("SFE")

	// Query
	cQry := " SELECT"
	cQry += " DISTINCT SFE.FE_NROCERT"
	cQry += " FROM "+RetSqlName("SFE")+" SFE"
	cQry += " WHERE SFE.FE_FILIAL IN (" + cSucursal +")"
	cQry += " AND SFE.D_E_L_E_T_ = ' '"
	cQry += " AND SFE.FE_NROCERT <> 'NORET'"
	If nCliFor == 1
		// Filtro por fornecedor
		cQry += " AND SFE.FE_FORNECE <> ' '"
	Else
		// Filtro por cliente
		cQry += " AND SFE.FE_CLIENTE <> ' '"
	EndIf

	If Select("QRY") > 0                 
		dbSelectArea("QRY")
		dbCloseArea()
	Endif

	cQry := ChangeQuery(cQry)
	TCQUERY cQry NEW ALIAS "QRY"  

	dbSelectArea("QRY")
	While !QRY->(EOF())
		aAdd(aCerts,QRY->FE_NROCERT)
		QRY->(dbSkip())
	EndDo	
	QRY->(dbCloseArea())

Return aCerts

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tela2    ³ Autor ³ Ivan Haponczuk      ³ Data ³ 11.08.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria a primeira tela de configurações.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nPar01 - Movimento ao (1=Fornecedor, 2=Cliente)            ³±±
±±³          ³ cPar02 - (Fornecedores/Clientes)                           ³±±
±±³          ³ cPar03 - (Impostos/Percepcoes/Retencoes)                   ³±±
±±³          ³ cPar04 - Provincia            o                            ³±±
±±³          ³ cPar05 - Array com as classificacoes fiscais               ³±±
±±³          ³ cPar06 - Array com os conceitos usados (CFOS/CONCEPTS)     ³±±
±±³          ³ cPar07 - Codigo do cliente/fornecedor                      ³±±
±±³          ³ cPar08 - Codigo da loja                                    ³±±
±±³          ³ cPar09 - Codito ate cliente/fornecedor                     ³±±
±±³          ³ cPar10 - Codigo ate loja                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet - .T. se confirmado e validado ou .F. caso contrario  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tela2(nCliFor,cCmbCli,cTipImp,cProv,aClassif,aConcep,cCodIni,cLojIni,cCodFin,cLojFin,cMunicip,lAutomato)

	Local nI      := 0
	Local cImpIVA := ""
	Local cImpGAN := ""
	Local cImpSUS := ""
	Local cImpIBB := ""
	Local cImpIMP := ""
	Local cImpPRV := "" 
	Local cImpMun := ""
	Local cImpSLI := ""	
	Local aImpIVA := {}
	Local aImpGAN := {}
	Local aImpSUS := {}
	Local aImpIBB := {}
	Local aImpIMP := {}
	Local aImpPRV := {}
	Local aImpMun := {}
	Local aImpSLI := {}	
	Local lImpIVA := .F.
	Local lImpGAN := .F.
	Local lImpSUS := .F.
	Local lImpIBB := .F.
	Local lImpIMP := .F.
	Local lImpMUN := .F.
	Local lImpSLI := .F.
	Local lImpINT := .F.
	Local lOk     := .F.
	Local aImps   := {}
	Local cMunic  := ""
	Local aMunic  := {}
	Default lAutomato := .F.
	cProv    := ""
	aClassif := {}
	aConcep  := {}
	cCodIni  := Space(TamSx3("A2_COD")[1])
	cLojIni  := Space(2)
	cCodFin  :=Space(TamSx3("A2_COD")[1])
	cLojFin  := Space(2)

	// Faz a carga dos conceitos de IVA
	aImps := FaImps({"3"},{cTipImp})
	aImpIVA := RetConFF(aImps,nCliFor)

	//Faz a carga dos conceitos de Ganancias
	aImps := FaImps({"4"},{cTipImp})
	aAdd(aImps,{"GAN",0})
	aImpGAN := RetConFF(aImps,0)

	//Faz a carga dos conceitos de SUSS
	aImpSUS := RetX5Tab("CS")

	//Faz a carga dos conceitos de Ingressos Brutos
	aImps := FaImps({"1"},{cTipImp})
	aImpIBB := RetConFF(aImps,nCliFor)

	//Faz a carga dos conceitos de Importações
	aImps := FaImps({"7"},{cTipImp})
	aImpIMP := RetConFF(aImps,0)
	
	//Faz a carga dos conceitos de impostos municipais
	aImps := FaImps({"5"},{cTipImp})
	aImpMun := RetConFF(aImps,0,nCliFor)

	//Faz a carga das provincias
	aImpPRV := RetX5Tab("12")
	aMunic  := RetX5Tab("S1")
	
	//Faz a carga dos conceitos de SLI
	//aImps := FaImps({"4"},{cTipImp})
	aAdd(aImps,{"SLI",0})
	aImpSLI := RetConFF(aImps,0)

If !lAutomato
	oDlg02:=MSDialog():New(000,000,580,450,STR0018+cCmbCli,,,,,,,,,.T.)//Selecione os impostos para os 

	@005,005 To 045,180 prompt cCmbCli Pixel Of oDlg02

	oSay01 := tSay():New(017,010,{||STR0019},oDlg02,,,,,,.T.,,,100,20)//Do código:
	oSay02 := tSay():New(017,095,{||STR0020},oDlg02,,,,,,.T.,,,100,20)//Da Loja:
	oGet01 := TGet():New(015,045,{|u| if(PCount()>0,cCodIni:=u,cCodIni)},oDlg02,040,007,,,,,,,,.T.)
	oGet01:cF3 := Iif(nCliFor==1,"FOR","SA1")
	oGet02 := TGet():New(015,125,{|u| if(PCount()>0,cLojIni:=u,cLojIni)},oDlg02,020,007,,,,,,,,.T.)

	oSay03 := tSay():New(032,010,{||STR0021},oDlg02,,,,,,.T.,,,100,20)//Até código:
	oSay04 := tSay():New(032,095,{||STR0022},oDlg02,,,,,,.T.,,,100,20)//Até Loja:
	oGet03 := TGet():New(030,045,{|u| if(PCount()>0,cCodFin:=u,cCodFin)},oDlg02,040,007,,,,,,,,.T.)
	oGet03:cF3 := Iif(nCliFor==1,"FOR","SA1")
	oGet04 := TGet():New(030,125,{|u| if(PCount()>0,cLojFin:=u,cLojFin)},oDlg02,020,007,,,,,,,,.T.)

	oBtn01:=sButton():New(012,190,1,{|| lOk:=.T. ,oDlg02:End() },oDlg02,.T.,,)
	oBtn02:=sButton():New(028,190,2,{|| lOk:=.F. ,oDlg02:End() },oDlg02,.T.,,)

	@050,005 To 100,220 prompt STR0023 Pixel Of oDlg02//Local

	//Est/Dist/Reg
	oSay05 := tSay():New(064,015,{||STR0024},oDlg02,,,,,,.T.,,,100,20)//Est/Dist/Reg
	oCmb01 := tComboBox():New(062,100,{|u| if(PCount()>0,cImpPRV:=u,cImpPRV)},aImpPRV,110,020,oDlg02,,,{|| },,,.T.) 

	//Codigo Municipal
	oSay14 := tSay():New(084,015,{||STR0042},oDlg02,,,,,,.T.,,,100,20)//Est/Dist/Reg
	oCmb08 := tComboBox():New(81,100,{|u| if(PCount()>0,cMunic:=u,cMunic)},aMunic,110,020,oDlg02,,,{|| },,,.T.)

	@105,005 To 280,220 prompt STR0025 Pixel Of oDlg02//Impostos/Conceitos

	//IVA
	oChk01 := TCheckBox():New(121,015,"",{|| lImpIVA },oDlg02,100,210,,,,,,,,.T.,,,)
	oChk01:bLClicked := {|| lImpIVA:=!lImpIVA }
	oSay06 := tSay():New(123,030,{||STR0026},oDlg02,,,,,,.T.,,,100,20)//IVA
	oCmb02 := tComboBox():New(120,100,{|u| if(PCount()>0,cImpIVA:=u,cImpIVA)},aImpIVA,110,020,oDlg02,,,{|| },,,.T.,,,,{|| lImpIVA })

	//Ganancias
	oChk02 := TCheckBox():New(141,015,"",{|| lImpGAN },oDlg02,100,210,,,,,,,,.T.,,,)
	oChk02:bLClicked := {|| lImpGAN:=!lImpGAN }
	oSay07 := tSay():New(143,030,{||STR0027},oDlg02,,,,,,.T.,,,100,20)//Ganancias
	oCmb03 := tComboBox():New(140,100,{|u| if(PCount()>0,cImpGAN:=u,cImpGAN)},aImpGAN,110,020,oDlg02,,,{|| },,,.T.,,,,{|| lImpGAN })

	//SUSS
	oChk03 := TCheckBox():New(161,015,"",{|| lImpSUS },oDlg02,100,210,,,,,,,,.T.,,,)
	oChk03:bLClicked := {|| lImpSUS:=!lImpSUS }
	oSay08 := tSay():New(163,030,{||STR0028},oDlg02,,,,,,.T.,,,100,20)//SUSS
	oCmb04 := tComboBox():New(160,100,{|u| if(PCount()>0,cImpSUS:=u,cImpSUS)},aImpSUS,110,020,oDlg02,,,{|| },,,.T.,,,,{|| lImpSUS })

	//Ingressos brutos
	oChk04 := TCheckBox():New(181,015,"",{|| lImpIBB },oDlg02,100,210,,,,,,,,.T.,,,)
	oChk04:bLClicked := {|| lImpIBB:=!lImpIBB }
	oSay09 := tSay():New(183,030,{||STR0029},oDlg02,,,,,,.T.,,,100,20)//Ingressos Brutos
	oCmb05 := tComboBox():New(180,100,{|u| if(PCount()>0,cImpIBB:=u,cImpIBB)},aImpIBB,110,020,oDlg02,,,{|| },,,.T.,,,,{|| lImpIBB })

	//Impostos de importações
	oChk05 := TCheckBox():New(201,015,"",{|| lImpIMP },oDlg02,100,210,,,,,,,,.T.,,,)
	oChk05:bLClicked := {|| lImpIMP:=!lImpIMP }
	oSay10 := tSay():New(203,030,{||STR0030},oDlg02,,,,,,.T.,,,100,20)//Imp. de Importações
	oCmb06 := tComboBox():New(200,100,{|u| if(PCount()>0,cImpIMP:=u,cImpIMP)},aImpIMP,110,020,oDlg02,,,{|| },,,.T.,,,,{|| lImpIMP })

	//Impostos municipais
	oChk06 := TCheckBox():New(221,015,"",{|| lImpMUN },oDlg02,100,210,,,,,,,,.T.,,,)
	oChk06:bLClicked := {|| lImpMUN:=!lImpMUN }
	oSay11 := tSay():New(223,030,{||STR0031},oDlg02,,,,,,.T.,,,100,20)//Imp. Municipais
	oCmb07 := tComboBox():New(220,100,{|u| if(PCount()>0,cImpMUN:=u,cImpMUN)},aImpMUN,110,020,oDlg02,,,{|| },,,.T.,,,,{|| lImpMUN })

	//Impostos internos
	oChk07 := TCheckBox():New(241,015,"",{|| lImpINT },oDlg02,100,210,,,,,,,,.T.,,,)
	oChk07:bLClicked := {|| lImpINT:=!lImpINT }
	oSay12 := tSay():New(243,030,{||STR0032},oDlg02,,,,,,.T.,,,100,20)//Imp. Internos

	//Impostos SLI
	oChk08 := TCheckBox():New(261,015,"",{|| lImpSLI },oDlg02,100,210,,,,,,,,.T.,,,)
	oChk08:bLClicked := {|| lImpSLI:=!lImpSLI }
	oSay13 := tSay():New(263,030,{||STR0041},oDlg02,,,,,,.T.,,,100,20)//Impostos SLI
	//oCmb08 := tComboBox():New(240,100,{|u| if(PCount()>0,cImpSLI:=u,cImpSLI)},aImpSLI,110,020,oDlg02,,,{|| },,,.T.,,,,{|| lImpSLI })

	oDlg02:Activate(,,,.T.,,,)
Else
    If FindFunction("GetParAuto")
	    aRetAuto := GetParAuto("FISA025TESTCASE")
	    cCodIni 		:= aRetAuto[6]
	    cLojIni 		:= aRetAuto[7]
	    cCodFin 		:= aRetAuto[8]
	    cLojFin 		:= aRetAuto[9]
	    cImpPRV			:= aRetAuto[10]
	    lImpIVA 		:= aRetAuto[11]
        lOk 			:= .T.
	EndIf
Endif
	//Alimenta vetor com a classificacao dos impostos selecionados
	Iif(lImpIBB,aAdd(aClassif,"1"),) //1 - Ingressos brutos
	Iif(lImpINT,aAdd(aClassif,"2"),) //2 - Impostos internos
	Iif(lImpIVA,aAdd(aClassif,"3"),) //3 - IVA
	Iif(lImpGAN,aAdd(aClassif,"4"),) //4 - Ganancias
	Iif(lImpMUN,aAdd(aClassif,"5"),) //5 - Impostos municipais
	Iif(lImpSUS,aAdd(aClassif,"6"),) //6 - SUSS
	Iif(lImpIMP,aAdd(aClassif,"7"),) //7 - Impostos importação
	Iif(lImpSLI,aAdd(aClassif,"8"),) //7 - Impostos importação	
	
	//Alimenta vetor com os conceitos selecionados
	For nI:=1 To 8
		aAdd(aConcep,"")
	Next nI
	Iif(lImpIBB,aConcep[1] := SubStr(cImpIBB,1,5),)          //1 - Ingressos brutos
	Iif(lImpINT,aConcep[2] := "",)                           //2 - Impostos internos
	Iif(lImpIVA,aConcep[3] := SubStr(cImpIVA,1,5),)          //3 - IVA
	Iif(lImpGAN,aConcep[4] := AllTrim(SubStr(cImpGAN,1,2)),) //4 - Ganancias
	Iif(lImpMUN,aConcep[5] := AllTrim(SubStr(cImpMUN,1,3)),) //5 - Impostos municipais
	Iif(lImpSUS,aConcep[6] := AllTrim(SubStr(cImpSUS,1,1)),) //6 - SUSS
	Iif(lImpIMP,aConcep[7] := SubStr(cImpIMP,1,2),)          //7 - Impostos importação
	Iif(lImpSLI,aConcep[8] := "",)  // SLI Servicios de Limpieza	
	//Provincia selecionada
	cProv := SubStr(cImpPRV,1,2)
	cMunicip := SubStr(cMunic, 1,5)



Return lOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RetX5Tab ³ Autor ³ Ivan Haponczuk      ³ Data ³ 11.08.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os dados de uma determinada tabela de tabelas      ³±±
±±³          ³ genericas (SX5).                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Codigo da tabela                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet - Dados da tabela selecionada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetX5Tab(cTab)

	Local aRet := {}

	aAdd(aRet,"")
	dbSelectArea("SX5")
	SX5->(dbSetOrder(1))
	SX5->(dbGoTop())
	If SX5->(dbSeek(xFilial("SX5")+cTab))
		Do While SX5->X5_TABELA == cTab .and. SX5->(!EOF())
			aAdd(aRet,AllTrim(SX5->X5_CHAVE)+" - "+AllTrim(SX5->X5_DESCRI))
			SX5->(dbSkip())
		EndDo
	EndIf

Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RetConFF ³ Autor ³ Ivan Haponczuk      ³ Data ³ 11.08.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os conceitos da tabela SFF dos impostos indicados. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aPar01 - Array com as informacoes dos impostos.            ³±±
±±³          ³ nPar02 - Movimento ao (1=Fornecedor, 2=Cliente)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet - Array com os codigos e descricoes dos conceitos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetConFF(aImps,nCliFor, nRetMun)

	Local nI      := 0
	Local cQry    := ""
	Local aConcep := {}
	Local lFF_Ret_Mun := Iif(SFF->(FieldPos('FF_RET_MUN')) > 0, .T., .F.)
	Local cSucursal := ObtFilial("SFF")
	
	Default aImps := {}
	Default nRetMun := 0
	
	cQry := " SELECT"
	cQry += "  SFF.FF_ITEM"
	cQry += " ,SFF.FF_CFO_C"
	cQry += " ,SFF.FF_CFO_V"
	cQry += " ,SFF.FF_CONCEPT"
	If lFF_Ret_Mun
		cQry += " ,SFF.FF_RET_MUN"	
	EndIf
	cQry += " FROM "+RetSqlName("SFF")+" SFF"
	cQry += " WHERE SFF.FF_FILIAL IN (" + cSucursal +")"
	cQry += " AND SFF.D_E_L_E_T_ = ' '"
	If Len(aImps) == 0
		cQry += " AND SFF.FF_IMPOSTO = '*'"
	Else
		cQry += " AND ( SFF.FF_IMPOSTO = '"+aImps[1,1]+"'"
		For nI:=2 To Len(aImps)
			cQry += " OR SFF.FF_IMPOSTO = '"+aImps[nI,1]+"'"
		Next nI
		cQry += " )"
	EndIf

	If lFF_Ret_Mun .And. nRetMun <> 0
		cQry += " AND SFF.FF_RET_MUN <> ''"
	EndIf
	cQry := ChangeQuery(cQry)
	TCQUERY CQRY NEW ALIAS "QRY"
	
	aAdd(aConcep,"")
	dbSelectArea("QRY")
	Do While QRY->(!EOF())
		If nCliFor == 1
			Iif(!Empty(QRY->FF_CFO_C),aAdd(aConcep,QRY->FF_CFO_C+" - "+QRY->FF_CONCEPT),) //Mov. de entrada
		ElseIf nCliFor == 2
			Iif(!Empty(QRY->FF_CFO_V),aAdd(aConcep,QRY->FF_CFO_V+" - "+QRY->FF_CONCEPT),) //Mov. de saida
		Else
			If nRetMun == 1
				If lFF_Ret_Mun
					Iif(!Empty(QRY->FF_RET_MUN),aAdd(aConcep,QRY->FF_CFO_C+" - "+QRY->FF_CONCEPT),) //Independente do movimento
				EndIf
			ElseIF nRetMun == 2
				If lFF_Ret_Mun
					Iif(!Empty(QRY->FF_RET_MUN),aAdd(aConcep,QRY->FF_CFO_V+" - "+QRY->FF_CONCEPT),) //Independente do movimento
				EndIf
			Else
				Iif(!Empty(QRY->FF_ITEM),aAdd(aConcep,QRY->FF_ITEM+" - "+QRY->FF_CONCEPT),) //Independente do movimento
			EndIf
		EndIf
		QRY->(dbSkip())
	EndDo
	QRY->(dbCloseArea())

Return aConcep

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FaImps   ³ Autor ³ Ivan Haponczuk      ³ Data ³ 11.08.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Busca as informacoes dos impostos de acordo com os         ³±±
±±³          ³ paramentros informados.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aPar01 - Array com as classificacoes fiscais               ³±±
±±³          ³ aPar02 - Array com as classes dos impostos                 ³±±
±±³          ³ cPar03 - Provincia                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet - Array com as informacoes dos impostos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FaImps(aClassif,aClasse,cProv, nSuc)

	Local nI    := 0
	Local cQry  := ""
	Local aImps := {}
	Local cSucursal := ""

	//Se estiver vazio traz todos impostos classificados
	Default aClassif := {}
	Default aClasse  := {}
	Default cProv    := ""
	Default nSuc     := 0

	If nSuc == 0
		cSucursal := ObtFilial("SFB")
	Else
		cSucursal := "'" + xFilial("SFB", aSelFil[nSuc]) + "'"
	EndIf

	cQry := " SELECT"
	cQry += "  SFB.FB_CODIGO"
	cQry += " ,SFB.FB_CPOLVRO"
	cQry += " ,SFB.FB_CLASSIF"
	cQry += " FROM "+RetSqlName("SFB")+" SFB"
	cQry += " WHERE SFB.FB_FILIAL IN (" + cSucursal +")"
	cQry += " AND SFB.D_E_L_E_T_ = ' '"

	//Faz o filtro do campo classif
	If Len(aClassif) <= 0
		cQry += " AND SFB.FB_CLASSIF <> ' '"
	Else
		cQry += " AND ("
		cQry += " SFB.FB_CLASSIF = '"+aClassif[1]+"'"
		For nI:=2 To Len(aClassif)
			cQry += " OR SFB.FB_CLASSIF = '"+aClassif[nI]+"'"
		Next nI
		cQry += " )"
	EndIf

	//Faz o filtro do campo classe
	If Len(aClasse) <= 0
		cQry += " AND SFB.FB_CLASSE <> ' '"
	Else
		cQry += " AND ("
		cQry += " SFB.FB_CLASSE = '"+aClasse[1]+"'"
		For nI:=2 To Len(aClasse)
			cQry += " OR SFB.FB_CLASSE = '"+aClasse[nI]+"'"
		Next nI
		cQry += " )"
	EndIf

	//Faz o filtro por provincia
	If !Empty(cProv)
		cQry += " AND SFB.FB_ESTADO = '"+cProv+"'"
	EndIf

	cQry += "ORDER BY SFB.FB_CPOLVRO"

	cQry := ChangeQuery(cQry)
	TCQUERY CQRY NEW ALIAS "QRY"

	dbSelectArea("QRY")
	Do While QRY->(!EOF())
		aAdd(aImps,{QRY->FB_CODIGO,QRY->FB_CPOLVRO,QRY->FB_CLASSIF})
		QRY->(dbSkip())
	EndDo
	QRY->(dbCloseArea())

Return aImps

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FaCmbSer ³ Autor ³ Ivan Haponczuk      ³ Data ³ 11.08.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Busca seres utilizadas nas notas do sistema.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet - Array com as series do sistema                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FaCmbSer()

	Local cQry   := ""
	//Bruno Cremaschi - Projeto chave única.
	Local cSDoc	 := SerieNFID("SF3", 3, "F3_SERIE")
	Local aSerie := {}
	Local cSucursal := ObtFilial("SF3")

	aAdd(aSerie,"")

	cQry := " SELECT"
	//Bruno Cremaschi - Projeto chave única.
	cQry += " SF3." + cSDoc + " AS SERIE"
	cQry += " FROM "+RetSqlName("SF3")+" SF3"
	cQry += " WHERE SF3.F3_FILIAL IN (" + cSucursal +")"
	cQry += " AND SF3.D_E_L_E_T_ = ' '"
	cQry += " GROUP BY SF3." + cSDoc + " "

	TCQUERY CQRY NEW ALIAS "QRY"

	dbSelectArea("QRY")
	Do While QRY->(!EOF())
		aAdd(aSerie,QRY->SERIE)
		QRY->(dbSkip())
	EndDo
	QRY->(dbCloseArea())

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FaCmbDoc ³ Autor ³ Ivan Haponczuk      ³ Data ³ 11.08.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os tipos de documentos utilizados no sistema.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet - Array com as tipos de documentos suportados.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FaCmbDoc()

	Local cQry     := ""
	Local aEspecie := {}
	
	aAdd(aEspecie,"OP") //Ordem de pago
	aAdd(aEspecie,"RC") //Recibo

	cQry := " SELECT"
	cQry += " SF3.F3_ESPECIE"
	cQry += " FROM "+RetSqlName("SF3")+" SF3"
	cQry += " GROUP BY SF3.F3_ESPECIE"
	
	cQry := ChangeQuery(cQry)
	TCQUERY CQRY NEW ALIAS "QRY"
	
	dbSelectArea("QRY")
	Do While QRY->(!EOF())
		aAdd(aEspecie,QRY->F3_ESPECIE)
		QRY->(dbSkip())
	EndDo
	QRY->(dbCloseArea())

Return aEspecie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FQryFE   ³ Autor ³ Ivan Haponczuk      ³ Data ³ 11.08.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz a consulta nos certificados de retencao de acordo com  ³±±
±±³          ³ os paramentros informados.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nPar01 - Movimento ao (1=Fornecedor, 2=Cliente)            ³±±
±±³          ³ dPar02 - Data inicial do periodo                           ³±±
±±³          ³ dPar03 - Data final do periodo                             ³±±
±±³          ³ cPar04 - Especie do documento                              ³±±
±±³          ³ cPar05 - Numero do comprovante de retencao                 ³±±
±±³          ³ cPar06 - Codigo do cliente/fornecedor                      ³±±
±±³          ³ cPar07 - Codigo da loja                                    ³±±
±±³          ³ cPar08 - Codito ate cliente/fornecedor                     ³±±
±±³          ³ cPar09 - Codigo ate loja                                   ³±±
±±³          ³ cPar10 - Provincia            o                            ³±±
±±³          ³ cPar11 - Array com as classificacoes fiscais               ³±±
±±³          ³ cPar12 - Array com os conceitos usados (CFOS/CONCEPTS)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet - Array com os campos que devem ser apresentados      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FQryFE(nCliFor,dDadaDe,dDataAte,cEspecie,cDocNum,cCodIni,cLojIni,cCodFin,cLojFin,cProv,aClassif,aConcep,cMunicip)
 
	Local nI		:= 0
	Local cQry		:= ""
	Local aHead		:= {}
	Local nX		:= 0
	Local aStruSFE	:= {}
	Local nSuc		:= 0
	Local cFilAnt	:= ""

	Default nCliFor  := 1
	Default dDadaDe  := dDataBase
	Default dDataAte := dDataBase
	Default cEspecie := ""
	Default cDocNum  := ""
	Default cProv    := ""
	Default cCodIni  := ""
	Default cLojIni  := ""
	Default cCodFin  := ""
	Default cLojFin  := ""
	Default aConcep  := {}
	Default aClassif := {}
	Default cMunicip := ""
	
	aAdd(aHead,"FE_FILIAL")
	aAdd(aHead,"FE_NROCERT")
	aAdd(aHead,"FE_EMISSAO")
	If nCliFor == 1
		aAdd(aHead,"FE_FORNECE")
		aAdd(aHead,"FE_LOJA")		
		aAdd(aHead,"FE_FORCOND")
		aAdd(aHead,"FE_LOJCOND")
	Else
		aAdd(aHead,"FE_CLIENTE")
		aAdd(aHead,"FE_LOJCLI")
	EndIf
	If nCliFor == 2
		aAdd(aHead,"A1_NOME")
		aAdd(aHead,"A1_CGC")
	Else
		aAdd(aHead,"A2_NOME")
		aAdd(aHead,"A2_CGC")
	EndIf
	aAdd(aHead,"FE_CONCEPT")
	aAdd(aHead,"FE_TIPO")
	If nCliFor == 2
		aAdd(aHead,"FE_RECIBO")
	Else
		aAdd(aHead,"FE_ORDPAGO")
	EndIf
	aAdd(aHead,"FE_VALBASE")
	aAdd(aHead,"FE_ALIQ")
	aAdd(aHead,"FE_RETENC")
	aAdd(aHead,"FE_EST")
	If  nCliFor == 2
		aAdd(aHead,"EL_DTDIGIT")
	Else
		aAdd(aHead,"EK_DTDIGIT")
	EndIf
	
	aStruSFE  := SFE->(dbStruct())
	AADD(aStruSFE,{"EL_DTDIGIT","D",8,0})
	AADD(aStruSFE,{"EK_DTDIGIT","D",8,0})

	CreaTmp(aStruSFE, aHead, aCpoTmpSFE, "SFE", nCliFor)

	For nSuc := 1 To Len(aSelFil)
		If cFilAnt <> xFilial("SFE", aSelFil[nSuc])
			cFilAnt := xFilial("SFE", aSelFil[nSuc])

			cQry := "SELECT"
			cQry += "DISTINCT SFE.R_E_C_N_O_,"

			cQry += " CASE WHEN SFE.FE_CONCEPT = '' THEN '-' ELSE  SFE.FE_CONCEPT  END AS FE_CONCEPT,"
			cQry += " SFE.FE_FILIAL"
			For nI:=1 To Len(aHead)
				iF Alltrim(aHead[nI])<> "FE_CONCEPT"
					cQry += " ,"+aHead[nI]
				EndIf
			Next nI
			cQry += " FROM "+RetSqlName("SFE")+" SFE"  
			If nCliFor == 2                                                      
				cQry += " INNER JOIN "+RetSqlName("SA1")+" SA1"
				cQry += " ON SA1.A1_COD = SFE.FE_CLIENTE "
				cQry += " AND SA1.A1_LOJA = SFE.FE_LOJCLI "
				cQry += " AND SA1.A1_FILIAL = '"+xFilial("SA1", aSelFil[nSuc])+"'"
				cQry += " INNER JOIN "+RetSqlName("SEL")+" SEL"
				cQry += " ON SEL.EL_CLIORIG = SFE.FE_CLIENTE "
				cQry += " AND SEL.EL_LOJORIG = SFE.FE_LOJCLI "
				cQry += " AND SEL.EL_FILIAL = '"+xFilial("SEL", aSelFil[nSuc])+"'"
				cQry += " AND SEL.EL_RECIBO = SFE.FE_RECIBO "
				cQry += " AND SEL.EL_NUMERO = SFE.FE_NROCERT "
			Else
				cQry += " INNER JOIN "+RetSqlName("SA2")+" SA2"
				cQry += " ON CASE SFE.FE_FORCOND WHEN '' THEN SFE.FE_FORNECE ELSE SFE.FE_FORCOND END = SA2.A2_COD " 
				cQry += " AND CASE SFE.FE_LOJCOND WHEN '' THEN SFE.FE_LOJA ELSE SFE.FE_LOJCOND END = SA2.A2_LOJA "     
				cQry += " AND SA2.A2_FILIAL = '"+xFilial("SA2", aSelFil[nSuc])+"'"
				cQry += " INNER JOIN "+RetSqlName("SEK")+" SEK"
				cQry += " ON SEK.EK_FORNECE = SFE.FE_FORNECE "
				cQry += " AND SEK.EK_LOJA = SFE.FE_LOJA "
				cQry += " AND SEK.EK_FILIAL = '"+xFilial("SEK", aSelFil[nSuc])+"'"
				cQry += " AND SEK.EK_ORDPAGO = SFE.FE_ORDPAGO "
			EndIf

			cQry += " WHERE SFE.FE_FILIAL = '"+xFilial("SFE", aSelFil[nSuc])+"'"
			cQry += " AND SFE.D_E_L_E_T_ <> '*'"

			If nCliFor == 1
				cQry += " AND SA2.D_E_L_E_T_ <> '*'"
				cQry += " AND SEK.D_E_L_E_T_ <> '*'"
			Else
				cQry += " AND SA1.D_E_L_E_T_ <> '*'"
				cQry += " AND SEL.D_E_L_E_T_ <> '*'"
			Endif 
			cQry += " AND SFE.FE_RETENC <> 0 "
			//Filtra movimentos de fornecedores/clientes
			If nCliFor == 1
				cQry += " AND SFE.FE_FORNECE <> ''" //Fornecedor
			Else
				cQry += " AND SFE.FE_CLIENTE <> ''" //Cliente
			EndIf

			//Filtra movimento entra as datas
			If  nCliFor == 2
				cQry += " AND SEL.EL_DTDIGIT >= '"+DTOS(dDadaDe)+"'"
				cQry += " AND SEL.EL_DTDIGIT <= '"+DTOS(dDataAte)+"'"
			Else
				cQry += "AND SEK.EK_TIPO <> 'CH'"
				cQry += "AND SEK.EK_DTDIGIT >= '"+DTOS(dDadaDe)+"'"
				cQry += "AND SEK.EK_DTDIGIT <= '"+DTOS(dDataAte)+"'"
			EndIf

			//Filtra pro numero do documento
			If !Empty(cDocNum)
				If cEspecie == "OP"
					cQry += " AND SFE.FE_ORDPAGO = '"+cDocNum+"'"
				ElseIf cEspecie == "RC"
					cQry+=" AND SFE.FE_RECIBO = '"+cDocNum+"'" 
				Else
					cQry+=" AND SFE.FE_NROCERT = '"+cDocNum+"'" 
				EndIf
			Else
				If cEspecie == "OP"
					cQry += " AND SFE.FE_ORDPAGO <> ''"
				ElseIf cEspecie == "RC"
					cQry += " AND SFE.FE_RECIBO <> ''"
				EndIf
			EndIf

			//Filtra por provincia
			If !Empty(cProv)
				cQry += " AND SFE.FE_EST = '"+cProv+"'"
			EndIf
			If !EmpTy(cMunicip) .AND. SFE->(FieldPos('FE_RET_MUN')) > 0
				cQry += " AND SFE.FE_RET_MUN = '" + cMunicip + "'"
			EndIf

			//Filtra do cliente/fornecedor ate cliente/fornecedor
			If !Empty(cCodIni) 
				If nCliFor == 1 //Fornecedor
					cQry += " AND SFE.FE_FORNECE >= '"+cCodIni+"'"
				Else //Cliente
					cQry += " AND SFE.FE_CLIENTE >= '"+cCodIni+"'"
				EndIf
			EndIf
			
			If !Empty(cLojIni) 
				If nCliFor == 1 //Fornecedor
					cQry += " AND SFE.FE_LOJA >= '"+cLojIni+"'"
				Else //Cliente
					cQry += " AND SFE.FE_LOJCLI >= '"+cLojIni+"'"
				EndIf
			EndIf

			If !Empty(cCodFin)
				If nCliFor == 1 //Fornecedor
					cQry += " AND SFE.FE_FORNECE <= '"+cCodFin+"'"
				Else //Cliente
					cQry += " AND SFE.FE_CLIENTE <= '"+cCodFin+"'"
				EndIf
			EndIf

			If !Empty(cLojFin)
				If nCliFor == 1 //Fornecedor
					cQry += " AND SFE.FE_LOJA <= '"+cLojFin+"'"
				Else //Cliente
					cQry += " AND SFE.FE_LOJCLI <= '"+cLojFin+"'"
				EndIf
			EndIf


			//Filtra pelo imposto e conceito
			If Len(aClassif) > 0
				cQry += " AND ("
				For nI:=1 To Len(aClassif)
					If nI > 1
						cQry += " OR"
					EndIf
					If aClassif[nI] == "1"//Ingressos brutos
						cQry += " ( SFE.FE_TIPO = 'B'"
						If !Empty(aConcep[1])
							cQry += " AND SFE.FE_CFO = '"+aConcep[1]+"'"
						EndIf
						cQry += " )"
					ElseIf aClassif[nI] == "3"//IVA
						cQry += " ( SFE.FE_TIPO = 'I'"
						If !Empty(aConcep[3])
							cQry += " AND  SFE.FE_CFO = '"+aConcep[3]+"'"
						EndIf
						cQry += " )"
					ElseIf aClassif[nI] == "4"//Ganancias
						cQry += " ( SFE.FE_TIPO = 'G'"
						If !Empty(aConcep[4])
							cQry += " AND SFE.FE_CONCEPT = '"+aConcep[4]+"'"
						EndIf
						cQry += " )"
					ElseIf aClassif[nI] == "5"//Ganancias
						cQry += " ( SFE.FE_TIPO = 'M'"
						If !Empty(aConcep[5])
							cQry += " AND SFE.FE_CFO = '"+aConcep[5]+"'"
						EndIf
						cQry += " )"
					ElseIf aClassif[nI] == "6"//SUSS
						cQry += " ( SFE.FE_TIPO = 'S'"
						If !Empty(aConcep[6])
							cQry += " AND SFE.FE_CONCEPT = '"+aConcep[6]+"'"
						EndIf
						cQry += " )"
					ElseIf aClassif[nI] == "8"//SLI
						cQry += " ( SFE.FE_TIPO = 'L'"
						If !Empty(aConcep[6])
							cQry += " AND SFE.FE_CONCEPT = '"+aConcep[8]+"'"
						EndIf
						cQry += " )"
					Else
						cQry += " SFE.FE_TIPO = '*'"
					EndIf
				Next nI
				cQry += " )"
				If  nCliFor == 2
					cQry += "GROUP BY FE_FILIAL,FE_NROCERT,FE_EMISSAO,FE_CLIENTE,FE_LOJCLI,A1_NOME,A1_CGC,EL_DTDIGIT,FE_CONCEPT,FE_TIPO,FE_RECIBO,FE_VALBASE,FE_ALIQ,FE_EST,FE_RETENC,SFE.R_E_C_N_O_  "
				Else
					cQry += "GROUP BY FE_FILIAL,FE_NROCERT,FE_EMISSAO,FE_FORNECE,FE_LOJA,FE_FORCOND,FE_LOJCOND,A2_NOME,A2_CGC,EK_DTDIGIT,FE_CONCEPT,FE_TIPO,FE_ORDPAGO,FE_VALBASE,FE_ALIQ,FE_EST,FE_RETENC,SFE.R_E_C_N_O_  "
				EndIf
			EndIf

			cQry := ChangeQuery(cQry)	
			SqlToTrb(cQry,aCpoTmpSFE,cQRYCON)

		EndIf
	Next
	dbSelectArea(cQRYCON)
	(cQRYCON)->(dbGoTop())
	If (cQRYCON)->(EOF())
		aHead := {}
	EndIf

Return aHead

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FQryF3   ³ Autor ³ Ivan Haponczuk      ³ Data ³ 11.08.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz a consulta nos certificados de retencao de acordo com  ³±±
±±³          ³ os paramentros informados.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nPar01 - Movimento ao (1=Fornecedor, 2=Cliente)            ³±±
±±³          ³ dPar02 - Data inicial do periodo                           ³±±
±±³          ³ dPar03 - Data final do periodo                             ³±±
±±³          ³ aPar04 - Vetor com as informacoes dos impostos             ³±±
±±³          ³ cPar05 - Especie do documento                              ³±±
±±³          ³ cPar06 - Serie do documento                                ³±±
±±³          ³ cPar07 - Numero do documento                               ³±±
±±³          ³ cPar08 - Codigo do cliente/fornecedor                      ³±±
±±³          ³ cPar09 - Codigo da loja                                    ³±±
±±³          ³ cPar10 - Codito ate cliente/fornecedor                     ³±±
±±³          ³ cPar11 - Codigo ate loja                                   ³±±
±±³          ³ cPar12 - Array com os conceitos usados (CFOS/CONCEPTS)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet - Array com os campos que devem ser apresentados      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FQryF3(nCliFor,dDadaDe,dDataAte,aImps,cEspecie,cSerie,cDocNum,cCodIni,cLojIni,cCodFin,cLojFin,aConcep,aClassif,cTipImp,cProv)

	Local nI			:= 1
	Local nX			:= 0
	Local cQry			:= ""
	Local aHead			:= {}
	Local aStruSF3		:= {}
	Local lUnion		:= .F.
	Local nSuc			:= 0
	Local cFilAnt		:= ""
	Local aCampo		:= {}
	Local cAliasQry		:= GetNextAlias()
	Local cAliasQry1	:= GetNextAlias()
	Local cChave		:= ""

	Default nCliFor  := 1
	Default dDadaDe  := dDataBase
	Default dDataAte := dDataBase
	Default cEspecie := ""
	Default cSerie   := ""
	Default cDocNum  := ""
	Default cCodIni  := ""
	Default cLojIni  := ""
	Default cCodFin  := ""
	Default cLojFin  := ""
	Default aImps    := {}
	Default aConcep  := {}
	Default aClassif := {}
	Default cTipImp  := ""
	Default cProv    := ""
	
	aAdd(aHead,"F3_FILIAL")		//Sucursal
	aAdd(aHead,"FB_DESCR")		//Descripcion
	aAdd(aHead,"F3_ESPECIE")	//Especie Doc
	aAdd(aHead,"F3_ENTRADA")	//Fecha Entrada                                         
	aAdd(aHead,"F3_CLIEFOR")	//Razon Social
	If nCliFor == 2	
		aAdd(aHead,"A1_NOME")
		aAdd(aHead,"A1_CGC")			
	Else
		aAdd(aHead,"A2_NOME")
		aAdd(aHead,"A2_CGC")
	EndIf
	aAdd(aHead,"F3_LOJA")		//Tienda
	aAdd(aHead,"F3_SERIE")		//Serie Factura
	aAdd(aHead,"F3_NFISCAL")	//Factura
	aAdd(aHead,"F3_CFO")		//Codigo Fiscal
	aAdd(aHead,"F3_ESTADO")		//Provincia de Referencia
	aAdd(aHead,"F3_BASIMP1")	//Base Imp 1
	aAdd(aHead,"F3_ALQIMP1")	//Alic. Imp. 1
	aAdd(aHead,"F3_VALIMP1")	//Valor Imp. 1

	aStruSF3  := SF3->(dbStruct())

	CreaTmp(aStruSF3, aHead, aCpoTmpSF3, "SF3", nCliFor)

	For nSuc := 1 To Len(aSelFil)
		If cFilAnt <> xFilial("SF3", aSelFil[nSuc])
			cFilAnt := xFilial("SF3", aSelFil[nSuc])

			If lChk02
				aImps := FaImps(,,,nSuc)
			Else
				If Len(aClassif) == 0
					aImps := FaImps({"1"},{cTipImp},cProv,nSuc)
					aImps := FaImps({"3","4","5","7"},{cTipImp},cProv,nSuc)
				Else
					aImps := FaImps(aClassif,{cTipImp},cProv,nSuc)
				EndIf
			EndIf

			If Len(aImps) <> 0
				CursorWait()
				cQry := MntQuery(nCliFor,.F.,dDadaDe,dDataAte,aImps,cEspecie,cSerie,cDocNum,cCodIni,cLojIni,cCodFin,cLojFin,aConcep,nSuc)
				SqlToTrb(cQry,aCpoTmpSF3,cQRYCON)
				cQry2 := MntQuery(nCliFor,.T.,dDadaDe,dDataAte,aImps,cEspecie,cSerie,cDocNum,cCodIni,cLojIni,cCodFin,cLojFin,aConcep,nSuc)
				SqlToTrb(cQry2, aCpoTmpSF3, cQRYCON)
				CursorArrow()
			EndIf
		EndIf
	Next

	dbSelectArea(cQRYCON)
	(cQRYCON)->(dbGoTop())
	If (cQRYCON)->(EOF())
		aHead := {}
	EndIf

Return aHead

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Tela3    ³ Autor ³ Ivan Haponczuk      ³ Data ³ 11.08.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria tela de apresentacao dos dados da consulta.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Alias da tabela a ser usada                       ³±±
±±³          ³ aPar02 - Array com os campos da query a serem apresentados ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tela3(cAlias,aHead,lAutomato)

	Local nI		:= 0
	Local nTotBas	:= 0
	Local nTotVal	:= 0
	Local cTotBas	:= ""
	Local cTotVal	:= ""
	Local aSize		:= MsAdvSize()
	Local aHeader	:= {} 
	Local lCred		:= .F.
	Private aCols    := {}
	Private aButtons := {}
	Default lAutomato	:= .F.
	
	//Define os campos de totais
	If cAlias == "SF3"
		cTotBas  := "F3_BASIMP1"
		cTotVal  := "F3_VALIMP1"
	ElseIf cAlias == "SFE"
		cTotBas  := "FE_VALBASE"
		cTotVal  := "FE_RETENC"
	EndIf	
	
	//Busca dados dos campos a serem apresentados
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For nI:=1 To Len(aHead)
		SX3->(dbSeek(aHead[nI]))
		Aadd(aHeader,{ AllTrim(X3Titulo()),;
		TRIM(SX3->X3_CAMPO),;
		SX3->X3_PICTURE,;
		SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL,;
		"",;
		"€€€€€€€€€€€€€€€",;
		SX3->X3_TIPO,;
		SX3->X3_ARQUIVO,;
		SX3->X3_CONTEXT } )
	Next nI
	
	//Preenche o vetos com os dados da query
	dbSelectArea(cQRYCON) 

	(cQRYCON)->(dbGoTop())
	Do While (cQRYCON)->(!EOF())
		If cAlias == "SF3"	 .AND. (cQRYCON)->(F3_VALIMP1) > 0 .OR. cAlias == "SFE"
			aAdd(aCols,Array(Len(aHead)+1)) 
			For nI:=1 To Len(aHead)
				aCols[Len(aCols)][nI] := &("(cQRYCON)->"+aHead[nI]) 

				If Alltrim(aHead[nI]) == "F3_ESPECIE" .And. Alltrim(aCols[Len(aCols)][nI])$"NCP/NDI/NCC/NDE"
					lCred := .T.
				ElseIf Alltrim(aHead[nI]) $ "F3_VALIMP1/FE_RETENC/F3_BASIMP1/FE_VALBASE" .And. lCred
					aCols[Len(aCols)][nI] := aCols[Len(aCols)][nI] * (-1)
				EndIf
			Next nI

			If cAlias == "SF3"
		   		aCols[Len(aCols)][nI] := .F.			
				aHeader[5][1]:="Clien/Provee"
				aHeader[5][2]:="A2_COD"
				aHeader[5][4]:= 14			 
				aHeader[6][1]:="Razon Social"
				aHeader[6][2]:="A2_NOME"
				aHeader[6][4]:= 40
				aHeader[7][1]:="Nro Doc"
				aHeader[7][2]:="A2_CGC"
				aHeader[7][4]:= 14
				aHeader[13][1]:="Base Imp."
				aHeader[14][1]:="Alic.Imp."
				aHeader[15][1]:="Valor Imp."
			ElseIF SubStr(aHead[8],1,2) == "A1"
				aCols[Len(aCols)][nI] := .F.			
				aHeader[5][1]:="Clien/Provee"
				aHeader[5][2]:="A1_COD"
				aHeader[5][4]:= 14			 
				aHeader[6][1]:="Razon Social"
				aHeader[6][2]:="A1_NOME"
				aHeader[6][4]:= 40
				aHeader[7][1]:="Nro Doc"
				aHeader[7][2]:="A1_CGC"
				aHeader[7][4]:= 14
				aHeader[11][1]:="Base Imp."
				aHeader[12][1]:="Aliq Imp."
				aHeader[13][1]:="Valor Imp."
				aHeader[14][1]:="Estado."
			ElseIF SubStr(aHead[8],1,2) == "A2"
				aCols[Len(aCols)][nI] := .F.			
				aHeader[6][1]:="Prov.Cond"
				aHeader[7][1]:="Tda.Cond"
				aHeader[5][4]:= 14			 
				aHeader[8][1]:="Razon Social"
				aHeader[8][2]:="A2_NOME"
				aHeader[8][4]:= 40
				aHeader[9][1]:="Nro Doc"
				aHeader[9][2]:="A2_CGC"
				aHeader[9][4]:= 14
			ElseIF SubStr(aHead[6],1,2) == "A1"
				aCols[Len(aCols)][nI] := .F.			
					aHeader[5][1]:="Clien/Provee"
				aHeader[5][2]:="A1_COD"
				aHeader[5][4]:= 14			 
				aHeader[6][1]:="Razon Social"
				aHeader[6][2]:="A1_NOME"
				aHeader[6][4]:= 40
				aHeader[7][1]:="Nro Doc"
				aHeader[7][2]:="A1_CGC"
				aHeader[7][4]:= 14
				aHeader[11][1]:="Base Imp."
				aHeader[12][1]:="Aliq Imp."
				aHeader[13][1]:="Valor Imp."
				aHeader[14][1]:="Estado."
			EndIF

			If lCred
				nTotVal  -= &("(cQRYCON)->"+cTotVal)
				nTotBas  -= &("(cQRYCON)->"+cTotBas)
			Else
				nTotVal  += &("(cQRYCON)->"+cTotVal) 
				nTotBas  += &("(cQRYCON)->"+cTotBas)
			EndIf
			lCred := .F.
		EndIf
		(cQRYCON)->(dbSkip())  
	EndDo        

	//Cria linha dos totalizadores
	aAdd(aCols,Array(Len(aHead)+1))
	aCols[Len(aCols)][1] := STR0039//TOTAIS
	aCols[Len(aCols)][2] :="-"
	aCols[Len(aCols)][3] :="-"
	aCols[Len(aCols)][4] :="-"
	aCols[Len(aCols)][5] :="-"
	aCols[Len(aCols)][6] :="-"
	aCols[Len(aCols)][7] :="-"
	aCols[Len(aCols)][8] :="-"
	aCols[Len(aCols)][9] :="-"
	aCols[Len(aCols)][aScan(aHead,{|x| x == cTotBas})] := nTotBas
	aCols[Len(aCols)][aScan(aHead,{|x| x == cTotVal})] := nTotVal
	aCols[Len(aCols)][Len(aCols[Len(aCols)])] := .F.

If !lAutomato
	oDlg03:=MSDialog():New(000,000,aSize[6],aSize[5],STR0040,,,,,,,,,.T.)//"Consulta de Impostos"

	oGetDados:=	MsNewGetDados():New(030,000,(aSize[6]/2),(aSize[5]/2),1,"AllwaysTrue","AllwaysTrue",,,,,"AllwaysTrue",,,oDlg03,aHeader,aCols)  
	aAdd(aButtons,{"PAPEL_ESCRITO",{|| A025Report(aHeader,aCols)},STR0033,STR0034,{|| .T.}})//Imprimir###Imprimir

	oDlg03:Activate(,,,.T.,,,{|| EnchoiceBar(oDlg03,{||oDlg03:End()},{||oDlg03:End()},,@aButtons)})
Else
    Conout ("Se ha realizado la consulta con Exito")
Endif
Return Nil


Function A025Report(aHeader,aCols)

	Local oReport
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef(aHeader,aCols)
	oReport:PrintDialog()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef³ Autor ³ Ivan Haponczuk      ³ Data ³ 11.08.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa a impressao dos dados apresentados na tela.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aPar01 - Array com os campos a serem apresentados          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(aHeader,aCols)

	Local oReport   := Nil
	Local oSection  := Nil
	Local nI        := 0

	oReport := TReport():New("CONIMP",STR0035,,{|oReport| ReportPrint(oReport,aHeader,aCols,oSection)},STR0036)//Relatorio de Consulta de Impostos###Relatorio de Consulta de Impostos
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	oReport:SetTitle(STR0037)//Relatorio de Consulta de Impostos

	oSection := TRSection():New(oReport,STR0038,{cQRYCON})//Relatorio de Consulta de Impostos
	For nI := 1 To Len(aHeader)
		TRCell():New(oSection,aHeader[nI,2],cQRYCON,aHeader[nI,1],,aHeader[nI,4],.F.)
	Next nI

Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ReportPrint³ Autor ³ Ivan Haponczuk      ³ Data ³ 11.08.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa a impressao dos dados apresentados na tela.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oPar01 - Objeto de impressao do relatorio                  ³±±
±±³          ³ aPar02 - Array com os campos a serem apresentados          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,aHeader,aCols,oSection)

	Local nI      := 0	        
	Local nJ      := 0
	Local nLin    := 0
	Local nAltPag := 0

	nAltPag := oReport:PageHeight() - 2
	nLin := 0
	oReport:SetMeter((cQRYCON)->(RecCount()) + 1)
	oSection:Init()

	For nI:=1 to Len(aCols)
		For nJ:=1 To Len(aHeader)
			oSection:Cell(aHeader[nJ,2]):SetValue(aCols[nI,nJ])
		Next nJ
		oSection:PrintLine()
		nLin := oReport:Row()
		If nLin >= nAltPag
			oReport:EndPage()
			oSection:Init()
		Endif
		(cQRYCON)->(dbSkip())
		oReport:IncMeter()
	Next nI
	oReport:IncMeter()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MntQuery Autor    ³ totvs               ³ Data ³ 08.06.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta a query para a geracao do relatorio                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 												              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Query                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MntQuery(nClifor,lUnion,dDadaDe,dDataAte,aImps,cEspecie,cSerie,cDocNum,cCodIni,cLojIni,cCodFin,cLojFin,aConcep, nSuc)

	Local nI		:= 1
	Local nX		:= 0
	Local cQry		:= ""
	Local aHead		:= {}
	Local aStruSF3	:= {}
	Local aCampo	:= {}
	Local cMtQry	:= ""

	Default nCliFor  := 1
	Default dDadaDe  := dDataBase
	Default dDataAte := dDataBase
	Default cEspecie := ""
	Default cSerie   := ""
	Default cDocNum  := ""
	Default cCodIni  := ""
	Default cLojIni  := ""
	Default cCodFin  := ""
	Default cLojFin  := ""
	Default aImps    := {}
	Default aConcep  := {}

	aAdd(aHead,"FB_DESCR")
	aAdd(aHead,"F3_ESPECIE")
	aAdd(aHead,"F3_ENTRADA")                                            
	aAdd(aHead,"F3_CLIEFOR")

	If nCliFor == 2	
		aAdd(aHead,"A1_NOME")
		aAdd(aHead,"A1_CGC" )			
	Else
		aAdd(aHead,"A2_NOME")
		aAdd(aHead,"A2_CGC")
	EndIf

	aAdd(aHead,"F3_LOJA")
	aAdd(aHead,"F3_SERIE")
	aAdd(aHead,"F3_NFISCAL")
	aAdd(aHead,"F3_CFO")
	aAdd(aHead,"F3_TES")
	aAdd(aHead,"F3_ESTADO")

	aStruSF3  := SF3->(dbStruct())

	If !lUnion	
		//Seleciona os campos 
		aStruSF3  := SF3->(dbStruct())

		cQry := " SELECT"
		cQry += "  SF3.F3_FILIAL"	

		For nI:=1 To Len(aHead)
			cQry += " ,"+aHead[nI]
		Next nI

		//Filtra campos de valores 
		aAdd(aHead,"F3_BASIMP1")
		aAdd(aHead,"F3_ALQIMP1")
		aAdd(aHead,"F3_VALIMP1")
		cQry += " ,( CASE"
		For nI:=1 To Len(aImps)
			If aScan( aCampo,{|x| Alltrim(x) == Alltrim(aImps[nI,2])} ) == 0
				cQry += " WHEN FB_CPOLVRO = '"+aImps[nI,2]+"' THEN SF3.F3_BASIMP"+aImps[nI,2]
				Aadd(aCampo,aImps[nI,2])
			EndIf
		Next nI
		aCampo := {}
		cQry += " ELSE 0 END ) AS F3_BASIMP1"
		cQry += " ,( CASE"
		For nI:=1 To Len(aImps)
			If aScan( aCampo,{|x| Alltrim(x) == Alltrim(aImps[nI,2])} ) == 0
				cQry += " WHEN FB_CPOLVRO = '"+aImps[nI,2]+"' THEN SF3.F3_ALQIMP"+aImps[nI,2]
				Aadd(aCampo,aImps[nI,2])
			EndIf
		Next nI
		aCampo := {}
		cQry += " ELSE 0 END ) AS F3_ALQIMP1"
		cQry += " ,( CASE"
		For nI:=1 To Len(aImps)
			cQry += " WHEN FB_CPOLVRO = '"+aImps[nI,2]+"' THEN SF3.F3_VALIMP"+aImps[nI,2]
		Next nI
		cQry += " ELSE 0 END ) AS F3_VALIMP1"

		If nCliFor == 2
			cQry += " FROM "+RetSqlName("SF2")+" SF2"
		Else  
			cQry += " FROM "+RetSqlName("SF1")+" SF1"
		EndIf	

		//Filtra pelos impostos e conceitos
		If nCliFor == 2  
			cQry += " INNER JOIN "+RetSqlName("SF3")+" SF3"
			cQry += " ON SF2.F2_SERIE = SF3.F3_SERIE "
			cQry += " AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR "
			cQry += " AND SF2.F2_LOJA = SF3.F3_LOJA "
			cQry += " AND SF2.F2_EMISSAO = SF3.F3_EMISSAO "
			cQry += " AND SF2.F2_EST = SF3.F3_ESTADO "
			cQry += " AND SF2.F2_ESPECIE = SF3.F3_ESPECIE "		

			cQry += " INNER JOIN "+RetSqlName("SD2")+" SD2"
			cQry += " ON  SF2.F2_DOC = SD2.D2_DOC "
			cQry += " AND SF2.F2_SERIE = SD2.D2_SERIE "
			cQry += " AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
			cQry += " AND SF2.F2_LOJA = SD2.D2_LOJA "
		//cQry += " AND SF2.F2_EMISSAO = SD2.D2_EMISSAO "
			cQry += " AND SF2.F2_ESPECIE = SD2.D2_ESPECIE "
			cQry += " AND SD2.D2_CF = SF3.F3_CFO "
			cQry += " AND SD2.D2_TES = SF3.F3_TES "
		Else                                                    
			cQry += " INNER JOIN "+RetSqlName("SF3")+" SF3"
			cQry += " ON SF1.F1_SERIE = SF3.F3_SERIE "
			cQry += " AND SF1.F1_FORNECE = SF3.F3_CLIEFOR "
			cQry += " AND SF1.F1_LOJA = SF3.F3_LOJA "
			cQry += " AND SF1.F1_EMISSAO = SF3.F3_EMISSAO "
			cQry += " AND SF1.F1_EST = SF3.F3_ESTADO "
			cQry += " AND SF1.F1_ESPECIE = SF3.F3_ESPECIE "		

			cQry += " INNER JOIN "+RetSqlName("SD1")+" SD1"
			cQry += " ON  SF1.F1_DOC = SD1.D1_DOC "
			cQry += " AND SF1.F1_SERIE = SD1.D1_SERIE "
			cQry += " AND SF1.F1_FORNECE = SD1.D1_FORNECE "
			cQry += " AND SF1.F1_LOJA = SD1.D1_LOJA "
		//cQry += " AND SF1.F1_EMISSAO = SD1.D1_EMISSAO "
			cQry += " AND SF1.F1_ESPECIE = SD1.D1_ESPECIE "
			cQry += " AND SD1.D1_CF = SF3.F3_CFO "
			cQry += " AND SD1.D1_TES = SF3.F3_TES " 
		EndIf
		If nCliFor == 2
			cQry += " INNER JOIN "+RetSqlName("SFC")+" SFC "
			cQry += " ON  SD2.D2_TES = SFC.FC_TES "
			cQry += " AND SFC.FC_FILIAL ='"+xFilial("SFC", aSelFil[nSuc])+"'"
			cQry += " AND SFC.D_E_L_E_T_ <> '*' "		
		Else 	 
			cQry += " INNER JOIN "+RetSqlName("SFC")+" SFC "
			cQry += " ON  SD1.D1_TES = SFC.FC_TES "
			cQry += " AND SFC.FC_FILIAL ='"+xFilial("SFC", aSelFil[nSuc])+"'"
			cQry += " AND SFC.D_E_L_E_T_ <> '*' "		
		EndIf	

		cQry += " INNER JOIN "+RetSqlName("SFB")+" SFB "
		cQry += " ON  SFB.FB_CODIGO = SFC.FC_IMPOSTO "
		cQry += " AND SFB.FB_FILIAL = '"+xFilial("SFB", aSelFil[nSuc])+"'"
		cQry += " AND SFB.D_E_L_E_T_ <> '*' AND " //modificado fguerrero
		cQry += " ( " //agregado fguerrero

		//Si el tamanio de aConcep es menor que aImps, iguala la cantidad de registros. 
		For nI := (Len(aConcep)+1) To Len(aImps)
			AADD(aConcep,"")
		Next

		For nI:=1 To Len(aImps)
			If nI > 1
				cQry += " OR"
			EndIf
			cQry += " ( SFB.FB_CODIGO = '"+aImps[nI,1]+"' AND SF3.F3_BASIMP"+aImps[nI,2]+" > '0'"

			//Filtra por conceito
			If Len(aConcep) > 0
				If !Empty(aConcep[Val(aImps[nI,3])])
					cQry += " AND SF3.F3_CFO = '"+aConcep[Val(aImps[nI,3])]+"'"
				EndIf
			EndIf
			cQry += " )"
		Next nI
		
		cQry += " ) "//agregado fguerrero 
		If nCliFor == 2 
			cQry += " INNER JOIN "+RetSqlName("SA1")+" SA1 "
			cQry += " ON  SA1.A1_COD = SF3.F3_CLIEFOR "
			cQry += " AND SA1.A1_LOJA = SF3.F3_LOJA "
			cQry += " AND SA1.A1_FILIAL = '"+xFilial("SA1", aSelFil[nSuc])+"'"
			cQry += " AND SA1.D_E_L_E_T_ <> '*' "
		Else	
			cQry += " INNER JOIN "+RetSqlName("SA2")+" SA2 "
			cQry += " ON  SA2.A2_COD = SF3.F3_CLIEFOR "
			cQry += " AND SA2.A2_LOJA = SF3.F3_LOJA "
			cQry += " AND SA2.A2_FILIAL = '"+xFilial("SA2", aSelFil[nSuc])+"'"
			cQry += " AND SA2.D_E_L_E_T_ <> '*' "
		EndIf	

		If nCliFor == 2
			cQry += " WHERE SF2.D_E_L_E_T_ <> '*' "
			cQry += " AND   SD2.D_E_L_E_T_ <> '*' "
		Else
			cQry += " WHERE SF1.D_E_L_E_T_ <> '*' "
			cQry += " AND   SD1.D_E_L_E_T_ <> '*' "
		EndIf
		cQry += " AND   SF3.F3_FILIAL = '"+xFilial("SF3", aSelFil[nSuc])+"'"
		cQry += " AND SF3.D_E_L_E_T_ <> '*'"

		cQry += " AND SFB.FB_FILIAL = '"+xFilial("SFB", aSelFil[nSuc])+"'"
		cQry += " AND SFB.D_E_L_E_T_ <> '*'"	

		//Filtra movimentos de fornecedores/clientes
		If nCliFor == 1
			cQry += " AND SF3.F3_TIPOMOV = 'C'" //Fornecedor
		Else
			cQry += " AND SF3.F3_TIPOMOV = 'V'" //Cliente
		EndIf

		//Filtra movimento entra as datas
		cQry += " AND SF3.F3_ENTRADA >= '"+DTOS(dDadaDe)+"'"
		cQry += " AND SF3.F3_ENTRADA <= '"+DTOS(dDataAte)+"'"

		//Filtra por especie
		If !Empty(cEspecie)
			cQry += " AND SF3.F3_ESPECIE = '"+cEspecie+"'"
		EndIf

		//Filtra por serie
		If !Empty(cSerie)
			cQry += " AND SF3.F3_SERIE = '"+cSerie+"'"
		EndIf

		//Filtra pro numero do documento
		If !Empty(cDocNum)
			cQry += " AND SF3.F3_NFISCAL = '"+cDocNum+"'"
		EndIf

		//Filtra do cliente/fornecedor ate cliente/fornecedor
			
		If !Empty(cCodIni)
			cQry += " AND SF3.F3_CLIEFOR >= '"+cCodIni+"'"
			
		EndIf	
		
		If !Empty(cCodFin) 
			cQry += " AND SF3.F3_CLIEFOR <= '"+cCodFin+"'"
		EndIf	
		
		If  !Empty(cLojIni)
			cQry += " AND SF3.F3_LOJA >= '"+cLojIni+"'"
		EndIf	
		
		If  !Empty(cLojFin)
			cQry += " AND SF3.F3_LOJA <= '"+cLojFin+"'"
		EndIf	
		


		cQry += " GROUP BY SF3.F3_FILIAL, "
		cQry += " SFB.FB_CODIGO, "
		cQry += " SFB.FB_DESCR, "
		cQry += " SF3.F3_ESPECIE, "
		cQry += " SF3.F3_ENTRADA, "
		cQry += " SF3.F3_ESTADO, "
		cQry += " SF3.F3_CLIEFOR, "
		If nCliFor == 2 
			cQry += " SA1.A1_NOME, "
			cQry += " SA1.A1_CGC, "
		Else
			cQry += " SA2.A2_NOME, "
			cQry += " SA2.A2_CGC, "
		EndIf		
		cQry += " SF3.F3_LOJA, "
		cQry += " SF3.F3_SERIE, "
		cQry += " SF3.F3_NFISCAL, "
		cQry += " SF3.F3_CFO, "
		cQry += " SF3.F3_TES, "
		cQry += " SFB.FB_CPOLVRO "
		aCampo := {}	
		For nI:=1 To Len(aImps)
			If aScan( aCampo,{|x| Alltrim(x) == Alltrim(aImps[nI,2])} ) == 0
				cQry += " , SF3.F3_BASIMP"+aImps[nI,2]
				Aadd(aCampo,aImps[nI,2])
			EndIf
		Next nI
		aCampo := {}	
		For nI:=1 To Len(aImps)
			If aScan( aCampo,{|x| Alltrim(x) == Alltrim(aImps[nI,2])} ) == 0
				cQry += " , SF3.F3_ALQIMP"+aImps[nI,2]
				Aadd(aCampo,aImps[nI,2])
			EndIf
		Next nI
		aCampo := {}	
		For nI:=1 To Len(aImps)
			If aScan( aCampo,{|x| Alltrim(x) == Alltrim(aImps[nI,2])} ) == 0
				cQry += " , SF3.F3_VALIMP"+aImps[nI,2]
				Aadd(aCampo,aImps[nI,2])
			EndIf
		Next nI
	Else
		cQry := " SELECT"
		cQry += "  SF3.F3_FILIAL"

		For nI:=1 To Len(aHead)
			cQry += " ,"+aHead[nI]
		Next nI

		//Filtra campos de valores 
		aAdd(aHead,"F3_BASIMP1")
		aAdd(aHead,"F3_ALQIMP1")
		aAdd(aHead,"F3_VALIMP1")
		cQry += " ,( CASE"
		aCampo := {}
		For nI:=1 To Len(aImps)
			If aScan( aCampo,{|x| Alltrim(x) == Alltrim(aImps[nI,2])} ) == 0
				cQry += " WHEN FB_CPOLVRO = '"+aImps[nI,2]+"' THEN SF3.F3_BASIMP"+aImps[nI,2]
				Aadd(aCampo,aImps[nI,2])
			EndIf	
		Next nI
		aCampo := {}
		cQry += " ELSE 0 END ) AS F3_BASIMP1"
		cQry += " ,( CASE"
		For nI:=1 To Len(aImps)
			If aScan( aCampo,{|x| Alltrim(x) == Alltrim(aImps[nI,2])} ) == 0
				cQry += " WHEN FB_CPOLVRO = '"+aImps[nI,2]+"' THEN SF3.F3_ALQIMP"+aImps[nI,2]
				Aadd(aCampo,aImps[nI,2])
			EndIf	
		Next nI
		aCampo := {}	
		cQry += " ELSE 0 END ) AS F3_ALQIMP1"
		cQry += " ,( CASE"
		For nI:=1 To Len(aImps)
			If aScan( aCampo,{|x| Alltrim(x) == Alltrim(aImps[nI,2])} ) == 0
				cQry += " WHEN FB_CPOLVRO = '"+aImps[nI,2]+"' THEN SF3.F3_VALIMP"+aImps[nI,2]
				Aadd(aCampo,aImps[nI,2])
			EndIf	
		Next nI
		cQry += " ELSE 0 END ) AS F3_VALIMP1"

		If nCliFor == 2
			cQry += " FROM "+RetSqlName("SF1")+" SF1"
		Else  
			cQry += " FROM "+RetSqlName("SF2")+" SF2"
		EndIf	

		//Filtra pelos impostos e conceitos
		If nCliFor == 2  
			cQry += " INNER JOIN "+RetSqlName("SF3")+" SF3"
			cQry += " ON SF1.F1_SERIE = SF3.F3_SERIE "
			cQry += " AND SF1.F1_FORNECE = SF3.F3_CLIEFOR "
			cQry += " AND SF1.F1_LOJA = SF3.F3_LOJA "
			cQry += " AND SF1.F1_EMISSAO = SF3.F3_EMISSAO "
			cQry += " AND SF1.F1_EST = SF3.F3_ESTADO "
			cQry += " AND SF1.F1_ESPECIE = SF3.F3_ESPECIE "		

			cQry += " INNER JOIN "+RetSqlName("SD1")+" SD1"
			cQry += " ON  SF1.F1_DOC = SD1.D1_DOC "
			cQry += " AND SF1.F1_SERIE = SD1.D1_SERIE "
			cQry += " AND SF1.F1_FORNECE = SD1.D1_FORNECE "
			cQry += " AND SF1.F1_LOJA = SD1.D1_LOJA "
			cQry += " AND SF1.F1_EMISSAO = SD1.D1_EMISSAO "
			cQry += " AND SF1.F1_ESPECIE = SD1.D1_ESPECIE "
			cQry += " AND SD1.D1_CF = SF3.F3_CFO "
			CQry += " AND SD1.D1_TES = SF3.F3_TES "
		Else                                                    
			cQry += " INNER JOIN "+RetSqlName("SF3")+" SF3"
			cQry += " ON SF2.F2_SERIE = SF3.F3_SERIE "
			cQry += " AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR "
			cQry += " AND SF2.F2_LOJA = SF3.F3_LOJA "
			cQry += " AND SF2.F2_EMISSAO = SF3.F3_EMISSAO "
			cQry += " AND SF2.F2_EST = SF3.F3_ESTADO "
			cQry += " AND SF2.F2_ESPECIE = SF3.F3_ESPECIE "		

			cQry += " INNER JOIN "+RetSqlName("SD2")+" SD2"
			cQry += " ON  SF2.F2_DOC = SD2.D2_DOC "
			cQry += " AND SF2.F2_SERIE = SD2.D2_SERIE "
			cQry += " AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
			cQry += " AND SF2.F2_LOJA = SD2.D2_LOJA "
			cQry += " AND SF2.F2_EMISSAO = SD2.D2_EMISSAO "
			cQry += " AND SF2.F2_ESPECIE = SD2.D2_ESPECIE "
			cQry += " AND SD2.D2_CF = SF3.F3_CFO "
			CQry += " AND SD2.D2_TES = SF3.F3_TES "
		EndIf
		If nCliFor == 2
			cQry += " INNER JOIN "+RetSqlName("SFC")+" SFC "
			cQry += " ON  SD1.D1_TES = SFC.FC_TES "
			cQry += " AND SFC.FC_FILIAL ='"+xFilial("SFC", aSelFil[nSuc])+"'"
			cQry += " AND SFC.D_E_L_E_T_ <> '*' AND "		
		Else 	 
			cQry += " INNER JOIN "+RetSqlName("SFC")+" SFC "
			cQry += " ON  SD2.D2_TES = SFC.FC_TES "
			cQry += " AND SFC.FC_FILIAL ='"+xFilial("SFC", aSelFil[nSuc])+"'"
			cQry += " AND SFC.D_E_L_E_T_ <> '*' AND "
		EndIf	

		For nI:=1 To Len(aImps)

			If nI == 1
				cQry += " SFC.FC_IMPOSTO IN ( "
			EndIf

			cQry += " '"+aImps[nI,1]+"'"+IIf(nI<Len(aImps),",","")

			If nI == Len(aImps)
				cQry += " )"
			EndIf

		Next nI	

		cQry += " INNER JOIN "+RetSqlName("SFB")+" SFB "
		cQry += " ON  SFB.FB_CODIGO = SFC.FC_IMPOSTO "
		cQry += " AND SFB.FB_FILIAL = '"+xFilial("SFB", aSelFil[nSuc])+"'"
		cQry += " AND SFB.D_E_L_E_T_ <> '*' AND "//modificado fguerrero
		cQry += " ( "//agregado fguerrero

		//Si el tamanio de aConcep es menor que aImps, iguala la cantidad de registros. 
		For nI:=(Len(aConcep)+1) To Len(aImps)
			AADD(aConcep,"")
		Next

		For nI:=1 To Len(aImps)
			If nI > 1
				cQry += " OR"
			EndIf
			cQry += " ( SFB.FB_CODIGO = '"+aImps[nI,1]+"' AND SF3.F3_BASIMP"+aImps[nI,2]+" > '0'"

			//Filtra por conceito
			If Len(aConcep) > 0
				If !Empty(aConcep[Val(aImps[nI,3])])
					cQry += " AND SF3.F3_CFO = '"+aConcep[Val(aImps[nI,3])]+"'"
				EndIf
			EndIf

			cQry += " )"
		Next nI 
		cQry += ") "//agregado fguerrero
		If nCliFor == 2 
			cQry += " INNER JOIN "+RetSqlName("SA1")+" SA1 "
			cQry += " ON  SA1.A1_COD = SF3.F3_CLIEFOR "
			cQry += " AND SA1.A1_LOJA = SF3.F3_LOJA "
			cQry += " AND SA1.A1_FILIAL = '"+xFilial("SA1", aSelFil[nSuc])+"'"
			cQry += " AND SA1.D_E_L_E_T_ <> '*' "
		Else	
			cQry += " INNER JOIN "+RetSqlName("SA2")+" SA2 "
			cQry += " ON  SA2.A2_COD = SF3.F3_CLIEFOR "
			cQry += " AND SA2.A2_LOJA = SF3.F3_LOJA "
			cQry += " AND SA2.A2_FILIAL = '"+xFilial("SA2", aSelFil[nSuc])+"'"
			cQry += " AND SA2.D_E_L_E_T_ <> '*' "
		EndIf	

		If nCliFor == 2
			cQry += " WHERE SF1.D_E_L_E_T_ <> '*' "
			cQry += " AND   SD1.D_E_L_E_T_ <> '*' "
		Else
			cQry += " WHERE SF2.D_E_L_E_T_ <> '*' "
			cQry += " AND   SD2.D_E_L_E_T_ <> '*' "
		EndIf
		cQry += " AND   SF3.F3_FILIAL = '"+xFilial("SF3", aSelFil[nSuc])+"'"
		cQry += " AND SF3.D_E_L_E_T_ <> '*'"

		cQry += " AND SFB.FB_FILIAL = '"+xFilial("SFB", aSelFil[nSuc])+"'"
		cQry += " AND SFB.D_E_L_E_T_ <> '*'"

		//Filtra movimentos de fornecedores/clientes
		If nCliFor == 1
			cQry += " AND SF3.F3_TIPOMOV = 'C'" //Fornecedor
		Else
			cQry += " AND SF3.F3_TIPOMOV = 'V'" //Cliente
		EndIf

		//Filtra movimento entra as datas
		cQry += " AND SF3.F3_ENTRADA >= '"+DTOS(dDadaDe)+"'"
		cQry += " AND SF3.F3_ENTRADA <= '"+DTOS(dDataAte)+"'"

		//Filtra por especie
		If !Empty(cEspecie)
			cQry += " AND SF3.F3_ESPECIE = '"+cEspecie+"'"
		EndIf

		//Filtra por serie
		If !Empty(cSerie)
			cQry += " AND SF3.F3_SERIE = '"+cSerie+"'"
		EndIf

		//Filtra pro numero do documento
		If !Empty(cDocNum)
			cQry += " AND SF3.F3_NFISCAL = '"+cDocNum+"'"
		EndIf
		//Filtra por codigo Inicial
		If !Empty(cCodIni)
			cQry += " AND SF3.F3_CLIEFOR >= '"+cCodIni+"'"
		EndIf	
		
		//Filtra por codigo final
		If !Empty(cCodFin) 
			cQry += " AND SF3.F3_CLIEFOR <= '"+cCodFin+"'"
		EndIf	
		
		//Filtra por Loja Inicial
		If  !Empty(cLojIni)
			cQry += " AND SF3.F3_LOJA >= '"+cLojIni+"'"
		EndIf	
		
		//Filtra por Loja Final
		If  !Empty(cLojFin)
			cQry += " AND SF3.F3_LOJA <= '"+cLojFin+"'"
		EndIf	
		

		cQry += " GROUP BY SF3.F3_FILIAL, "
		cQry += " SFB.FB_CODIGO, "
		cQry += " SFB.FB_DESCR, "
		cQry += " SF3.F3_ESPECIE, "
		cQry += " SF3.F3_ENTRADA, "
		cQry += " SF3.F3_ESTADO, "
		cQry += " SF3.F3_CLIEFOR, "	
		If nCliFor == 2
			cQry += " SA1.A1_NOME, "
			cQry += " SA1.A1_CGC, " 		
		Else			
			cQry += " SA2.A2_NOME, "
			cQry += " SA2.A2_CGC, "
		EndIf	
		cQry += " SF3.F3_LOJA, "
		cQry += " SF3.F3_SERIE, "
		cQry += " SF3.F3_NFISCAL, "
		cQry += " SF3.F3_CFO, "
		cQry += " SF3.F3_TES, "
		cQry += " SFB.FB_CPOLVRO "
		
		aCampo := {}
		For nI:=1 To Len(aImps)
			If aScan( aCampo,{|x| Alltrim(x) == Alltrim(aImps[nI,2])} ) == 0
				cQry += " , SF3.F3_BASIMP"+aImps[nI,2]
				Aadd(aCampo,aImps[nI,2])
			EndIf
		Next nI
		aCampo := {}
			For nI:=1 To Len(aImps)
			If aScan( aCampo,{|x| Alltrim(x) == Alltrim(aImps[nI,2])} ) == 0
				cQry += " , SF3.F3_ALQIMP"+aImps[nI,2]
				Aadd(aCampo,aImps[nI,2])
			EndIf
		Next nI
		aCampo := {}
			For nI:=1 To Len(aImps)
			If aScan( aCampo,{|x| Alltrim(x) == Alltrim(aImps[nI,2])} ) == 0
				cQry += " , SF3.F3_VALIMP"+aImps[nI,2]
				Aadd(aCampo,aImps[nI,2])
			EndIf
		Next nI

		//Ordenado por imposto
		cQry += " ORDER BY SF3.F3_FILIAL"

	EndIf
	
	If EXISTBLOCK("FA025MTQRY")
		cMtQry := EXECBLOCK("FA025MTQRY",.F.,.F.,{cQry,dDadaDe,dDataAte})
		If  ValType(cMtQry) == "C" .and. !Empty(cMtQry)
		 cQry := cMtQry 
		EndIf 
	EndIf

Return cQry

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ObtFilial |Autor  ³ totvs               ³ Data ³ 30.09.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Obtiene Filiales a consultar                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 												              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ String                                                     ³±±                  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ObtFilial(cTabla)

	Local nLoop     := 0
	Local cSucursal := ""
	Local nPosSF    := 0
	Local aFilSF    := {}

	For nLoop := 1 To Len(aSelFil)
		nPosSF := aScan( aFilSF,{|x| x == xFilial(cTabla, aSelFil[nLoop])} )

		If nPosSF == 0
			If !Empty(cSucursal) .Or. (Len(aSelFil) == nLoop .And. Len(aSelFil) > 1)
				cSucursal += ", "
			EndIf
			cSucursal += "'" + xFilial(cTabla, aSelFil[nLoop]) + "'"
			AADD(aFilSF, xFilial(cTabla, aSelFil[nLoop]))
		EndIf
	Next

Return cSucursal

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CreaTmp   |Autor  ³ totvs               ³ Data ³ 30.09.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Crea structura de tabla temporal                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 												              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ -                                                          ³±±                  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CreaTmp(aStru, aHead, aTemp, cTabla, nCliFor)

	Local nLoop		:= 0
	Local nPosCpo	:= 0
	Local aIndice	:= {}

	If (cTabla=="SF3".and. nCliFor== 2).or. (cTabla=="SFE".and. nCliFor== 2)
		aAdd(aTemp,{ "FB_DESCR",   "C", TamSX3("FB_DESCR")[1], TamSX3("FB_DESCR")[2]  })
		aAdd(aTemp,{ "A1_NOME", "C", TamSX3("A1_NOME")[1],  TamSX3("A1_NOME")[2]  })
		aAdd(aTemp,{ "A1_CGC",  "C", TamSX3("A1_CGC")[1],   TamSX3("A1_CGC")[2]  })
	Else
		aAdd(aTemp,{ "FB_DESCR",   "C", TamSX3("FB_DESCR")[1], TamSX3("FB_DESCR")[2]  })
		aAdd(aTemp,{ "A2_NOME",  "C", TamSX3("A2_NOME")[1], TamSX3("A2_NOME")[2]  })
		aAdd(aTemp,{ "A2_CGC",   "C", TamSX3("A2_CGC")[1],  TamSX3("A2_CGC")[2]  })
	EndIf

	For nLoop := 1 To Len(aHead)
		nPosCuit := aScan( aStru,{|x| x[1] == aHead[nLoop]} )
		If nPosCuit != 0
			AADD(aTemp, { aStru[nPosCuit][1], aStru[nPosCuit][2], aStru[nPosCuit][3], aStru[nPosCuit][4] })
		EndIf
	Next

	If cTabla == "SFE"
		If nCliFor == 1
			aIndice := {"FE_FORNECE", "FE_LOJA", "FE_EMISSAO"}
		Else
			aIndice := {"FE_CLIENTE", "FE_LOJCLI", "FE_EMISSAO"}
		EndIf
	Else
		aIndice := {"F3_CLIEFOR", "F3_LOJA", "F3_ENTRADA"}
	EndIf
	
	cQRYCON  := CriaTrab(Nil, .F.)
	oTmpTable := FWTemporaryTable():New(cQRYCON)
	oTmpTable:SetFields(aTemp)
	oTmpTable:AddIndex("IN1", aIndice)
	oTmpTable:Create()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tela4     |Autor  ³ totvs               ³ Data ³ 30.09.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta ventana para la selección de sucursales              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 												              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ -                                                          ³±±                  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tela4(lAutomato)

	Local aCmbSuc := {STR0046, STR0047}
	Local cCmbSuc := ""
	Local lOk :=  .F.
    Default lAutomato := .F.
    
If !lAutomato
	oDlg01:=MSDialog():New(000,000,100,430,STR0043/*STR0007*/,,,,,,,,,.T.)//Consultar de Impostos

	@005,005 To 045,170 prompt STR0044 Pixel Of oDlg01
	oSay01 := tSay():New(020,015,{||STR0045},oDlg01,,,,,,.T.,,,100,20)
	oCmb01 := tComboBox():New(020,085,{|u|if(PCount()>0,cCmbSuc:=u,cCmbSuc)},aCmbSuc,050,020,oDlg01,,{|| .T. },,,,.T.)

	oBtn01:=sButton():New(012,180,1,{|| Iif(VldSelSuc(cCmbSuc),(lOk:=.T., oDlg01:End()),) },oDlg01,.T.,,)
	oBtn02:=sButton():New(028,180,2,{|| lOk:=.F. ,oDlg01:End() },oDlg01,.T.,,)
	oDlg01:Activate(,,,.T.,,,)
Else
    If FindFunction("GetParAuto")
	    aRetAuto := GetParAuto("FISA025TESTCASE")
	    cCmbSuc 		:= aRetAuto[1]
	    If VldSelSuc(cCmbSuc)
	      lOk:=.T.
	    EndIf
	EndIf
EndIf
Return lOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VldSelSuc |Autor  ³ totvs               ³ Data ³ 30.09.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Se valida si se habilita la seleccion de sucursales        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 												              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ -                                                          ³±±                  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Argentina                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VldSelSuc(cCmbSuc)

	Local lOK := .T.

	If cCmbSuc == "No"
		aSelFil := { FWGETCODFILIAL }
	ElseIf cCmbSuc == "Si"
		aSelFil := AdmGetFil()
		If Len(aSelFil) == 0
			lOK := .F.
		EndIf
	EndIf

Return lOK

/*/{Protheus.doc} LibFIS025
valida fecha de la LIB para ser utilizada en Telemetria
@type       Function
@author     adrian.perez
@since      13/10/2021
@version    12.1.27
@return      lógico, si la LIB puede ser utilizada para Telemetria
/*/
Static Function LibFIS025()

Return (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')




/*/{Protheus.doc} METFIS025
	@type  Static Function
	@author adrian.perez
	@since 13/10/2021
	@param   cTipoRet,caracter, filtro por impuesto,retencion,percepcion
			 aImps,array, impuestos seleccionados en la pantalla2
			 lClase , logico, por clase(.T.) o tipo de documento(.F.)
	@return nil
/*/
Static Function METFIS025(cTipo,aImps,lClase)

Local cIdMetric     := ""
Local cSubRutina    := ""
Local lAutomato		:= IsBlind()

Local nI:=0

	If  LibFIS025()
		cIdMetric   := "fiscal-protheus_consulta-perc-ret_total"

		IF cTipo=="I"
			cSubRutina+= "IMPUESTOS"
		ELSEIF cTipo="R"
			cSubRutina+= "RETENCIONES"
		ELSEIF cTipo="P"
			cSubRutina+= "PERCEPCIONES"
		END
		If lAutomato
			cSubRutina  += "-AUTO"
		EndIf

		If lClase
			If len(aImps)>0
				For nI:=1 To len(aImps)
					If(aImps[nI] =="1") //1 - Ingressos brutos
						FwCustomMetrics():setSumMetric(cSubRutina+"-IBB",cIdMetric,1,/*dDateSend*/ , /*nLapTime*/, "FISA025") 
					elseIf(aImps[nI] =="2") //2 - Impostos internos
						FwCustomMetrics():setSumMetric(cSubRutina+"-INT",cIdMetric,1,/*dDateSend*/, /*nLapTime*/, "FISA025")
					elseif(aImps[nI] =="3") //3 - IVA
						FwCustomMetrics():setSumMetric(cSubRutina+"-IVA",cIdMetric,1,/*dDateSend*/ , /*nLapTime*/, "FISA025") 
					elseif(aImps[nI] =="4") //4 - Ganancias
						FwCustomMetrics():setSumMetric(cSubRutina+"-GAN",cIdMetric,1,/*dDateSend*/ , /*nLapTime*/, "FISA025") 
					elseif(aImps[nI] =="5") //5 - Impostos municipais
						FwCustomMetrics():setSumMetric(cSubRutina+"-MUN",cIdMetric,1,/*dDateSend*/, /*nLapTime*/, "FISA025") 
					elseif(aImps[nI] =="6") //6 - SUSS
						FwCustomMetrics():setSumMetric(cSubRutina+"-SUS",cIdMetric,1,/*dDateSend*/, /*nLapTime*/, "FISA025") 
					elseif(aImps[nI] =="7") //7 - Impostos importação
						FwCustomMetrics():setSumMetric(cSubRutina+"-IMPOR",cIdMetric,1,/*dDateSend*/ , /*nLapTime*/, "FISA025") 
					elseif(aImps[nI] =="8") //8 - SLI stos importação
						FwCustomMetrics():setSumMetric(cSubRutina+"-SLI",cIdMetric,1,/*dDateSend*/, /*nLapTime*/, "FISA025") 
					ENDIF
				Next nI
			ELSE
				FwCustomMetrics():setSumMetric(cSubRutina+="-ALL",cIdMetric,1,/*dDateSend*/ , /*nLapTime*/, "FISA025") 
			EndIf
		ELSE
			FwCustomMetrics():setSumMetric("TIPO-DOC-"+cTipo,cIdMetric,1,/*dDateSend*/ , /*nLapTime*/, "FISA025") 
		ENDIF

		
	EndIf
	
Return NIL
