#INCLUDE "PROTHEUS.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA134

Facilitador de altera��es da exce��o fiscal.

@author joao.pellegrini
@since 02/05/2017
@version 12.1.16
/*/
//-------------------------------------------------------------------
Function FISA134()

Local aCmpAlt   := {}
Local aWizard   := {}
Local cNomeCFP  := "FISA134"
Local nContProc := 0
Local aFilProc  := {}
Local nX        := 1
Local nCpoAlt   := 0
Local cCpoAlt   := 0
Local aArea     := GetArea()

If LockByName("FISA134", .T., .T.)

	If A134Wizard(@aCmpAlt)
		
		cNomeCFP := Iif(File(cNomeCFP+".cfp"),cNomeCFP,"FISA134")
	
		If xMagLeWiz(cNomeCFP, @aWizard, .T.)
			
			// Verifica se a tela de sele��o de filiais deve ser exibida.				
			If SubStr(aWizard[1][1],1,1) == "1"
				aFilProc :=	MatFilCalc(.T.,,,,,,.F.)
				// Retirando do array as filiais que n�o foram selecionadas p/ processamento.
				While nX <= Len(aFilProc)
					If !aFilProc[nX,1]
						aDel(aFilProc,nX)
	                    aSize(aFilProc,Len(aFilProc)-1)
					Else
						nX++
					EndIf	
				EndDo
			EndIf
			
			If Len(aFilProc) > 0 .Or. SubStr(aWizard[1][1],1,1) == "2"			
				Processa({|| A134Proc(aCmpAlt, aWizard, @nContProc, aFilProc)},,,.T.)
			Else
				MsgAlert("Nenhuma filial foi selecionada. O processo n�o ser� executado.")			
			EndIf
			
			If nContProc == 0
				MsgAlert("Nenhum registro foi atualizado." + Chr(13) + Chr(10) + "- Verifique se os filtros foram informados corretamente." + Chr(13) + Chr(10) + "- Verifique se o novo valor inserido difere do valor atual do campo selecionado.")
			Else
				MsgInfo("Processamento Conclu�do. Registros Atualizados: " + cValToChar(nContProc))
				
				nCpoAlt := Val(AllTrim(SubStr(aWizard[2][1],1,2))) // 2 caracteres pois pode haver mais de 10 campos na lista.
				cCpoAlt := aCmpAlt[nCpoAlt,1] 
				
				If AllTrim(SubStr(aWizard[2][3],1,1)) == "1"
					If MsgYesNo("Para gera��o do relat�rio � necess�rio que o Embedded Audit Trail esteja habilitado para a tabela SF7." + Chr(13) + Chr(10) + ;								
								"Deseja prosseguir com a gera��o?", "Relat�rio de Confer�ncia")
						A134Report(aCmpAlt, nCpoAlt)
					EndIf
				EndIf											
			EndIf
	
		EndIf
	EndIf

	UnLockByName('FISA134', .T. , .T. )

Else

	Help("",1,"Rotina J� est� sendo executada","Rotina J� est� sendo executada","Rotina J� est� sendo executada",1,0)
	
EndIf

RestArea(aArea)

Return .T.

Static Function A134Proc(aCmpAlt, aWizard, nContProc, aFilProc)

Local cAliasSF7    := ""
Local lRet         := .F. 
Local cWhere       := ""
Local nCpoAlt      := 0
Local nValAnterior := 0
Local nValAtual    := 0
Local oError       := NIL
Local bError       := { |e| oError := e , Break(e) }
Local bErrorBlock  := ErrorBlock( bError )
Local lError       := .F.
Local lHistFiscal  := IIf(FindFunction("HistFiscal"), HistFiscal(), .F.)
Local aCmps        := {}
Local bCampoSF7    := { |x| SF7->(Field(x)) }
Local cIdAux       := "AA"
Local nTotProc     := 0

DEFAULT aCmpAlt    := {}
DEFAULT aWizard    := {}
DEFAULT nContProc  := 0
DEFAULT aFilProc   := {}

ProcLogIni({})
ProcLogAtu("INICIO","Facilitador SF7",,"FISA134")			

nCpoAlt   := Val(AllTrim(SubStr(aWizard[2][1],1,2))) // 2 caracteres pois pode haver mais de 10 campos na lista.
nValAtual := Val(aWizard[2][2])

// Obtendo somente a quantidade de registros que ser�o processados (3 parametro = .T.).
cAliasSF7 := A134QrySF7(aWizard, aFilProc, .T.)
nTotProc := (cAliasSF7)->TOTREG
(cAliasSF7)->(dbCloseArea())

ProcRegua (nTotProc)

// Executando novamente a consulta para obten��o dos dados que ser�o processados (3 parametro = .F.).
cAliasSF7 := A134QrySF7(aWizard, aFilProc, .F.)

BEGIN SEQUENCE

	Begin Transaction
	
		Do While !(cAliasSF7)->(Eof())
			
			IncProc("Processando... " + cValToChar(nContProc) + " de " + cValToChar(nTotProc))
			
			SF7->(dbGoTo((cAliasSF7)->R_E_C_N_O_))
								
			nValAnterior := &("SF7->"+aCmpAlt[nCpoAlt,1])
			
			// Se o valor � o mesmo n�o faz altera��o nem grava o hist�rico..
			If nValAnterior <> nValAtual 
				
				nContProc++					  
			
				// Se habilitado hist�rico fiscal fa�o a grava��o na tabela espelho da SF7 (SS1).
				If lHistFiscal
					RecLock("SF7", .F.)											
					SF7->F7_IDHIST := IdHistFis() + cIdAux // Controle para que n�o sejam gerados ID's iguais, j� que farei altera��o em v�rios registros.
					cIdAux := Soma1(cIdAux)
					MsUnlock()						
					aCmps := RetCmps("SF7",bCampoSF7) // Busca estrutura dos campos da tabela SF7		 				
		 			GrvHistFis("SF7", "SS1", aCmps) // Grava o hist�rico da tabela SF7 na tabela SS1
				EndIf
							
				RecLock("SF7", .F.)				
				&("SF7->"+aCmpAlt[nCpoAlt,1]) := nValAtual									
				MsUnlock()
				
			EndIf
			
			(cAliasSF7)->(DbSkip())
								
		EndDo
		
	End Transaction
	
	(cAliasSF7)->(dbCloseArea())
	SF7->(dbCloseArea())

	ProcLogAtu("FIM","Facilitador SF7",,"FISA134")
	
	lRet := .T.

RECOVER

	lError := .T.
	
END SEQUENCE

ErrorBlock( bErrorBlock )

If lError			
	DisarmTransaction()
	ProcLogAtu("MENSAGEM", "Facilitador SF7 - Erro de Execu��o", oError:Description, "FISA134") 			
EndIf	

Return

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} A134Wizard

Fun��o respons�vel por efetuar a montagem do wizard do facilitador.

@author joao.pellegrini
@since 02/05/2017
@version 12.1.16
/*/
//-----------------------------------------------------------------------------------------------
Static Function A134Wizard(aCmpAlt)

Local aTxtApre   := {}
Local aPaineis   := {}
Local cNomeWiz   := "FISA134"
Local nPos       := 0
Local nTamGrpTrb := TamSX3("F7_GRTRIB")[1]
Local nTamGrpCli := TamSX3("F7_GRPCLI")[1]
Local aItemCbo   := {}
Local aItSimNao  := {"1 - Sim", "2 - N�o"}
Local cTxtWiz    := ""

DEFAULT aCmpAlt  := {}

aAdd (aPaineis, {})
nPos := Len (aPaineis)

aAdd (aTxtApre, "Facilitador - Exce��o Fiscal.")
aAdd (aTxtApre, "Facilitador - Exce��o Fiscal.")
aAdd (aTxtApre, "Facilitador de manuten��o das exce��es fiscais.")

cTxtWiz := "Este facilitador ir� auxiliar na altera��o em lote de exce��es fiscais." + Chr(13) + Chr(10) 
cTxtWiz += "Informe os par�metros para o processamento e confirme para que as altera��es sejam efetuadas."

aAdd (aTxtApre, cTxtWiz)

aAdd (aPaineis[nPos], "Preencha corretamente as informa��es solicitadas.")
aAdd (aPaineis[nPos], "Informe os filtros para sele��o dos registros que ser�o alterados.")
aAdd (aPaineis[nPos], {})

aAdd (aPaineis[nPos][3], {1,"Seleciona Filiais?",,,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco
aAdd (aPaineis[nPos][3], {3,,,,,aItSimNao,,}) // Aglutina Sele��o Por CNPJ + IE?
aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco

aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco
aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco

aAdd (aPaineis[nPos][3], {1,"Filial De:",,,,,,}) 
aAdd (aPaineis[nPos][3], {1,"Filial At�:",,,,,,})
aAdd (aPaineis[nPos][3], {2,,,1,,,,FWGETTAMFILIAL}) // Filial De							
aAdd (aPaineis[nPos][3], {2,,,1,,,,FWGETTAMFILIAL}) // Filial At�

aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco
aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco

aAdd (aPaineis[nPos][3], {1,"Grupo de Tributa��o De:",,,,,,}) 
aAdd (aPaineis[nPos][3], {1,"Grupo de Tributa��o At�:",,,,,,})
aAdd (aPaineis[nPos][3], {2,,,1,,,,nTamGrpTrb}) // Grupo de Tributa��o De							
aAdd (aPaineis[nPos][3], {2,,,1,,,,nTamGrpTrb}) // Grupo de Tributa��o At�

aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco
aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco

aAdd (aPaineis[nPos][3], {1,"Grupo Cliente/Fornecedor De:",,,,,,}) 
aAdd (aPaineis[nPos][3], {1,"Grupo Cliente/Fornecedor At�:",,,,,,})
aAdd (aPaineis[nPos][3], {2,,,1,,,,nTamGrpCli}) // Grupo Cliente/Fornecedor de							
aAdd (aPaineis[nPos][3], {2,,,1,,,,nTamGrpCli}) // Grupo Cliente/Fornecedor at�

aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco
aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco

aAdd (aPaineis[nPos][3], {1,"Filtrar Por Al�quota?",,,,,,})
aAdd (aPaineis[nPos][3], {1,"Al�quota:",,,,,,})

aItemCbo := {}
aAdd(aItemCbo, "1 - N�o")
aAdd(aItemCbo, "2 - Aliq. Interna")
aAdd(aItemCbo, "3 - Aliq. Externa")

aAdd (aPaineis[nPos][3], {3,,,,,aItemCbo,,}) // Filtrar Por Al�quota
aAdd (aPaineis[nPos][3], {2,,"@E 999.99",2,2,,,3}) // Aliquota

aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco
aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco

aAdd (aPaineis[nPos][3], {1,"Filtrar Por UF de Origem/Destino?",,,,,,})
aAdd (aPaineis[nPos][3], {1,"UF:",,,,,,})

aItemCbo := {}
aAdd(aItemCbo, "1 - N�o")
aAdd(aItemCbo, "2 - Origem")
aAdd(aItemCbo, "3 - Destino")
aAdd(aItemCbo, "4 - N�o Informado")

aAdd (aPaineis[nPos][3], {3,,,,,aItemCbo,,}) // Filtrar Por UF de Origem/Destino
aAdd (aPaineis[nPos][3], {2,,,1,,,,2})       // UF

aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco
aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco

aAdd (aPaineis[nPos][3], {1,"Filtrar Por Tipo de Cliente?",,,,,,})
aAdd (aPaineis[nPos][3], {1,"Tipo de Cliente:",,,,,,})

aAdd (aPaineis[nPos][3], {3,,,,,aItSimNao,,}) // Filtrar Por Tipo de Cliente

aItemCbo := {}
aAdd(aItemCbo, "* - Todos")
aAdd(aItemCbo, "F - Cons. Final")
aAdd(aItemCbo, "L - Prod. Rural")
aAdd(aItemCbo, "R - Revendedor")
aAdd(aItemCbo, "S - Solid�rio")
aAdd(aItemCbo, "X - Importa��o")

aAdd (aPaineis[nPos][3], {3,,,,,aItemCbo,,}) // Tipo de Cliente

aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco
aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco

// Painel 2

aAdd (aPaineis, {})
nPos :=	Len (aPaineis)

aAdd (aPaineis[nPos], "Preencha corretamente as informa��es solicitadas.")
aAdd (aPaineis[nPos], "Informe o campo que ser� alterado e o novo valor do respectivo campo.")
aAdd (aPaineis[nPos], {})

aAdd (aPaineis[nPos][3], {1,"Campo a Ser Alterado:",,,,,,})
aAdd (aPaineis[nPos][3], {1,"Novo Valor:",,,,,,})

aItemCbo := {}
aItemCbo := A134LoadX3(@aCmpAlt)

aAdd (aPaineis[nPos][3], {3,,,,,aItemCbo,,})	     // Campo a ser alterado
aAdd (aPaineis[nPos][3], {2,,"@E 999.9999",2,4,,,3}) // Novo Valor

aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco
aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco

aAdd (aPaineis[nPos][3], {1,"Gerar Relat�rio de Confer�ncia?",,,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco
aAdd (aPaineis[nPos][3], {3,,,,,aItSimNao,,}) // Gerar Relat�rio de Confer�ncia
aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco

aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco
aAdd (aPaineis[nPos][3], {0,"",,,,,,}) // linha em branco

lRet := xMagWizard(aTxtApre, aPaineis, cNomeWiz)

Return lRet

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} A134LoadX3

Fun��o respons�vel por retornar os campos que ser�o disponibilizados
para altera��o no facilitador.

@author joao.pellegrini
@since 02/05/2017
@version 12.1.16
/*/
//-----------------------------------------------------------------------------------------------
Static Function A134LoadX3(aCmpAlt)

Local aRet    := {}
Local cCampos := ""
Local nCont   := 0

dbSelectArea("SX3")
SX3->(dbSetOrder(1))

cCampos := "F7_ALIQINT|F7_ALIQEXT|F7_MARGEM|F7_ALIQDST|F7_VLR_ICM|F7_VLR_IPI|F7_VLR_PIS|F7_VLR_COF|"
cCampos += "F7_VLRICMP|F7_ALIQIPI|F7_ALIQPIS|F7_ALIQCOF|F7_BASEICM|F7_BASEIPI|F7_REDPIS|F7_REDCOF|"
cCampos += "F7_BSICMST|F7_PRCUNIC"

If SX3->(dbSeek("SF7"))
	While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "SF7"
		If AllTrim(SX3->X3_CAMPO) $ cCampos 		
			nCont++			
			aAdd(aRet,cValToChar(nCont) + " - " + SX3->X3_TITULO)
			aAdd(aCmpAlt,{SX3->X3_CAMPO,SX3->X3_TITULO})			
		EndIf
		SX3->(dbSkip())
	EndDo
EndIf

Return aRet

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} A134RetQry

Fun��o respons�vel por executar a query utilizada para sele��o dos 
registros alterados pelo facilitador.

@author joao.pellegrini
@since 02/05/2017
@version 12.1.16
/*/
//-----------------------------------------------------------------------------------------------
Static Function A134QrySF7(aWizard, aFilProc, lCount)

Local cRet       := ""
Local cFilAliq   := ""
Local cFilUF     := ""
Local cFilTpCli  := ""
Local cGrTribDe  := ""
Local cGrTribAte := ""
Local cGrpCFDe   := ""
Local cGrpCFAte  := ""
Local nAliquota  := 0
Local cUF        := ""
Local cTpCli     := ""
Local cFilDe     := ""
Local cFilAte    := ""
Local cFilIN     := ""
Local nX         := 0
Local cSelect    := ""
Local cWhere     := ""

DEFAULT aFilProc := {}
DEFAULT lCount   := .F.

cFilDe     := aWizard[1][2]
cFilAte    := aWizard[1][3]
cGrTribDe  := aWizard[1][4]
cGrTribAte := aWizard[1][5]
cGrpCFDe   := aWizard[1][6] 
cGrpCFAte  := aWizard[1][7]
cFilAliq   := AllTrim(SubStr(aWizard[1][8],1,1))
nAliquota  := Val(aWizard[1][9]) 
cFilUF     := AllTrim(SubStr(aWizard[1][10],1,1))
cUF        := aWizard[1][11] 
cFilTpCli  := AllTrim(SubStr(aWizard[1][12],1,1))
cTpCli     := AllTrim(SubStr(aWizard[1][13],1,1))

// Caso nao sejam preenchidas filiais na wizard processa apenas a filial corrente.
If Empty(cFilDe) .And. Empty(cFilAte)
	cFilDe := cFilAnt
	cFilAte := cFilAnt
EndIf

If lCount
	cSelect := "COUNT(SF7.R_E_C_N_O_) TOTREG " 
Else
	cSelect := "SF7.R_E_C_N_O_ "
EndIf

// Se o array aFilProc cont�m dados significa que foi configurada sele��o de filiais.
If Len(aFilProc) > 0
	For nX := 1 to Len(aFilProc)
		// Nao adiciono "pipe" depois do ultimo item para que n�o seja criada uma posi��o em branco pela "FormatIn" mais abaixo.
		cFilIN += aFilProc[nX][2] + IIf(nX < Len(aFilProc), "|", "") 
	Next nX 
	cWhere := "F7_FILIAL IN " + FormatIn( cFilIN, "|" )
Else
	cWhere := "F7_FILIAL >= '" + cFilDe + "' AND F7_FILIAL <= '" + cFilAte + "'"
EndIf
	
// Grupo de Tributa��o
cWhere += " AND F7_GRTRIB >= '" + cGrTribDe + "' AND F7_GRTRIB <= '" + cGrTribAte + "'"  

// Grupo de cliente/fornecedor
cWhere += " AND F7_GRPCLI >= '" + cGrpCFDe + "' AND F7_GRPCLI <= '" + cGrpCFAte + "'"

//Aliquota		
If cFilAliq == "2"
	cWhere += " AND F7_ALIQINT = " + cValToChar(nAliquota)
ElseIf cFilAliq == "3"
	cWhere += " AND F7_ALIQEXT = " + cValToChar(nAliquota) 
EndIf

// Estado
Do Case
	Case cFilUF == "2"
		cWhere += " AND F7_UFBUSCA = '2' AND F7_EST = '" + cUF + "'"
	Case cFilUF == "3"
		cWhere += " AND F7_UFBUSCA = '1' AND F7_EST = '" + cUF + "'"
	Case cFilUF == "4"
		cWhere += " AND F7_UFBUSCA = ' ' AND F7_EST = '" + cUF + "'"
EndCase

//Tipo de Cliente		
If cFilTpCli == "1"
	cWhere += "AND F7_TIPOCLI = '" + cTpCli + "'"			
EndIf

cSelect := "%" + cSelect + "%"
cWhere  := "%" + cWhere + "%"

cRet := GetNextAlias()

BeginSql Alias cRet
	SELECT
		%Exp:cSelect%
	FROM
		%Table:SF7% SF7
	WHERE		
		%Exp:cWhere% AND
		SF7.%NotDel%
EndSql

dbSelectArea(cRet)
(cRet)->(DbGoTop())
		
Return cRet

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} A134Report

Fun��o respons�vel por exibir o hist�rico das altera��es efetuadas
pelo facilitador.

@author joao.pellegrini
@since 02/05/2017
@version 12.1.16
/*/
//-----------------------------------------------------------------------------------------------
Function A134Report(aCmpAlt, nCpoAlt)

Local oReport    := NIL
Local oSection   := NIL
Local cAlsRep    := ""
Local cFilter    := "(TMP_FIELD = '" + aCmpAlt[nCpoAlt,1] + "' AND OPERATI = 'U' AND TMP_PROGRAM = 'FISA134')"
Local bPrintData := {|| SToD( StrTran( SubStr( (cAlsRep)->TMP_DTIME , 1, 10) , "-", "") ) }
Local bPrintHora := {|| SubStr((cAlsRep)->TMP_DTIME, 12, 8)}
Local aUltExec   := {}

// Consultando ultima execu��o da rotina (Tabela CV8).
aUltExec := GetLastExe()

If Len(aUltExec) >= 2

	// Chamada da API de consulta ao Embedded Audit Trail
	FWMsgRun(,{|| cAlsRep := FwATTViewLog({"SF7","SF7"},cFilter,"TMP_RECNO, TMP_FIELD, TMP_DTIME",,Date(),Date())},,"Gerando Relat�rio de Confer�ncia...") // "Consultando banco de dados..."

	If !Empty(cAlsRep)
	
		oReport  := Treport():New('Confer�ncia - Facilitador SF7','Confer�ncia de Registros Alterados - Facilitador SF7','',{|oReport| ReportPrint(oReport)},'Confer�ncia de Registros Alterados - Facilitador SF7',)		
		oReport:HideParamPage()		
		
		oSection := TRSection():New(oReport,"Registros Alterados",{cAlsRep, "SF7"})
		
		// Condi��o para impress�o da linha: Fa�o uma valida��o pois a API do AuditTrail n�o possui um filtro para a hora da altera��o. Desta forma, caso
		// o facilitador seja executado mais de uma vez no mesmo dia, s� posso exibir o(s) registro(s) alterado(s) na �ltima execu��o. Esta rotina "VldDtHr"
		// faz esta valida��o para que n�o sejam exibidos registros relacionados a outras execu��es. 
		oSection:SetLineCondition({|| VldDtHr(Eval(bPrintData),Eval(bPrintHora),aUltExec)})
		
		// Antes de imprimir cada linha posiciono no registro da SF7 para utilizar as informa��es na impress�o.
		oSection:OnPrintLine({|| SF7->(dbGoTo((cAlsRep)->TMP_RECNO)) })	
		
		oSection:SetCellBorder(2, 1, 000000, .F.)
				
		TRCell():New(oSection, "TMP_RECNO", cAlsRep, "RECNO"        , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
		TRCell():New(oSection, "F7_FILIAL", "SF7"  , "Filial"       , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
		TRCell():New(oSection, "F7_GRTRIB", "SF7"  , "Gr. Trib."    , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
		TRCell():New(oSection, "F7_SEQUEN", "SF7"  , "Sequencia"    , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)				
		TRCell():New(oSection, "TMP_FIELD", cAlsRep, "Campo Alt."   , /*Picture*/, 30        , /*lPixel*/, {|| AllTrim(aCmpAlt[nCpoAlt,2]) + " (" + (cAlsRep)->TMP_FIELD + ")"})
		TRCell():New(oSection, "TMP_COLD" , cAlsRep, "Valor Ant."   , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
		TRCell():New(oSection, "TMP_CNEW" , cAlsRep, "Valor Atual"  , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
		TRCell():New(oSection, "DATA"     , cAlsRep, "Data"         , /*Picture*/, 10        , /*lPixel*/, bPrintData)
		TRCell():New(oSection, "HORA"     , cAlsRep, "Hora"         , /*Picture*/, 8         , /*lPixel*/, bPrintHora)
		TRCell():New(oSection, "TMP_USER" , cAlsRep, "Usu�rio"      , /*Picture*/, 20        , /*lPixel*/, /*{|| code-block de impressao }*/)
		
		oSection:Cell("TMP_RECNO"):nAlign       := 2
		oSection:Cell("TMP_RECNO"):nHeaderAlign := 2		
		oSection:Cell("F7_GRTRIB"):nAlign       := 2
		oSection:Cell("F7_GRTRIB"):nHeaderAlign := 2
		oSection:Cell("F7_SEQUEN"):nAlign       := 2
		oSection:Cell("F7_SEQUEN"):nHeaderAlign := 2
		oSection:Cell("TMP_COLD"):nAlign        := 3
		oSection:Cell("TMP_COLD"):nHeaderAlign  := 3
		oSection:Cell("TMP_CNEW"):nAlign        := 3
		oSection:Cell("TMP_CNEW"):nHeaderAlign  := 3
		oSection:Cell("DATA"):nAlign            := 2	
		oSection:Cell("DATA"):nHeaderAlign      := 2
		oSection:Cell("HORA"):nAlign            := 2
		oSection:Cell("HORA"):nHeaderAlign      := 2
		
		oReport:PrintDialog()	
	
	Else
		
		MsgAlert("N�o foram localizados dados para gerar o relat�rio. Verifique a configura��o do Embedded Audit Trail.")	
		
	EndIf
	
	// Fechando alias da API de consulta ao Embedded Audit Trail
	FwATTDropLog(cAlsRep)	

Else

	MsgAlert("N�o foi poss�vel obter a data da �ltima execu��o. O relat�rio n�o ser� gerado.")	

EndIf

Return

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Fun��o respons�vel por retornar a data e a hora da �ltima execu��o
do facilitador.

@author joao.pellegrini
@since 02/05/2017
@version 12.1.16
/*/
//-----------------------------------------------------------------------------------------------
Static Function ReportPrint(oReport)

oReport:Section(1):Print()

Return Nil

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldData

Fun��o respons�vel por retornar a data e a hora da �ltima execu��o
do facilitador.

@author joao.pellegrini
@since 02/05/2017
@version 12.1.16
/*/
//-----------------------------------------------------------------------------------------------
Static Function VldDtHr(dData, cHora, aUltExec)

Local lRet := .F.

lRet := dData >= aUltExec[1,2] .And. dData <= aUltExec[2,2] .And. cHora >= aUltExec[1,3] .And. cHora <= aUltExec[2,3]      

Return lRet

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetLastExe

Fun��o respons�vel por retornar a data e a hora da �ltima execu��o
do facilitador.

@author joao.pellegrini
@since 02/05/2017
@version 12.1.16
/*/
//-----------------------------------------------------------------------------------------------
Static Function GetLastExe()

Local cSelect   := ""
Local aRet      := {}
Local cAliasCV8 := ""
Local nReg      := 1

// nReg = 1 - Ultimo in�cio de execu��o.
// nReg = 2 - Ultimo t�rmino de execu��o.

For nReg := 1 To 2

	cAliasCV8 := GetNextAlias()
	
	BeginSql Alias cAliasCV8
		
		COLUMN CV8_DATA AS DATE
	
		SELECT
			CV8.CV8_DATA, CV8.CV8_HORA, CV8.CV8_INFO
		FROM
			%Table:CV8% CV8
		WHERE
			CV8.CV8_FILIAL = %xFilial:CV8%    AND
			CV8.CV8_DATA = %Exp:DToS(Date())% AND 
			CV8.CV8_PROC = "FISA134"          AND
			CV8.CV8_INFO = %Exp:nReg%         AND
			CV8.%NotDel%
		ORDER BY
			CV8.CV8_DATA DESC, CV8.CV8_HORA DESC
			
	EndSql
	
	dbSelectArea(cAliasCV8)
	
	// Ordenei a query com DESC ent�o s� me interessa a primeira linha (Ultima data e hora de execu��o).
	(cAliasCV8)->(dbGoTop())
	
	If !(cAliasCV8)->(Eof())
		aAdd(aRet,{(cAliasCV8)->CV8_INFO,(cAliasCV8)->CV8_DATA, (cAliasCV8)->CV8_HORA})
	EndIf
	
	(cAliasCV8)->(dbCloseArea())

Next nReg

Return aRet