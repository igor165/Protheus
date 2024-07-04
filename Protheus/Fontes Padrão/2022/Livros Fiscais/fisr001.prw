#INCLUDE "FISR001.CH"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FISR001   ºAutor  ³Andressa Fagundes   º Data ³  18/05/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio Auxiliar para preenchimento do DUB-ICMS          º±±
±±º          ³ Rio de Janeiro                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FISR001

Local Titulo    := OemToAnsi(STR0001) // "DUB-ICMS - Documento de Utilização de Benefício Fiscal"
Local cDesc1    := OemToAnsi(STR0002) // "Este relatório emite as informações necessárias "
Local cDesc2    := OemToAnsi(STR0003) // "para auxiliar o preenchimento do DUB-ICMS."
Local cDesc3    := ""

Local cString   := "SF3"
Local wnrel     := "FISR001"			// Nome do Arquivo utilizado no Spool
Local nPagina   := 1

Local aArea     := GetArea()
Local lRet      := .T.
Local lDic      := .F.					// Habilita/Desabilita Dicionario
Local lComp     := .F.					// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro   := .F.					// Habilita/Desabilita o Filtro
//
Private Tamanho := "G"					// P/M/G
Private Limite  := 220					// 80/132/220
Private cPerg   := "FSR001"				// Pergunta do Relatorio
Private aReturn := {STR0004,1,STR0005,1,2,1,"",1}	//"Zebrado"###"Administracao"
Private lEnd    := .F.					// Controle de cancelamento do relatorio
Private m_pag   := 1					// Contador de Paginas
Private nLastKey:= 0					// Controla o cancelamento da SetPrint e SetDefault

Pergunte("FSR001",.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validacao/tratamento do periodo informado              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(mv_par01) .Or. Empty(mv_par02) .Or. (Year(mv_par01)<>Year(mv_par02)) .Or. RetPeriod(mv_par01,mv_par02)[2]
		xMagHelpFis(OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008))//"Período Inconsistente!"#"As perguntas Data Inicial e Data Final, foram preenchidas incorretamente ou não foram devidamente preenchidas."#"As perguntas Data Inicial e Final, devem estar devidamente preenchidas, e somente será válida a periodicidade Anual e Semestral."
		Return Nil
	Else
		If Day(mv_par01) <> 1
			mv_par01 := CtoD("01/"+StrZero(Month(mv_par01),2)+"/"+StrZero(Year(mv_par01),4))
		Endif
		If Day(mv_par02) <> Day(LastDay(mv_par02))
			mv_par02 := CtoD(StrZero(Day(LastDay(mv_par02)),2)+"/"+StrZero(Month(mv_par02),2)+"/"+StrZero(Year(mv_par02),4))
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia para a SetPrinter                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		wnrel:=SetPrint(cString,wnrel,"",@Titulo,cDesc1,cDesc2,cDesc3,lDic,"",lComp,Tamanho,lFiltro,.F.)
		If ( nLastKey==27 )
			dbSelectArea(cString)
			dbSetOrder(1)
			dbClearFilter()
			Return
		Endif
		SetDefault(aReturn,cString)
		If ( nLastKey==27 )
			dbSelectArea(cString)
			dbSetOrder(1)
			dbClearFilter()
			Return
		Endif
		
		RptStatus({|lEnd| ImpDub(@lEnd,wnrel,cString,Tamanho,nPagina)},Titulo)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura Ambiente                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cString)
		dbClearFilter()
		Set Device To Screen
		Set Printer To
		
		If ( aReturn[5] = 1 )
			dbCommitAll()
			OurSpool(wnrel)
		Endif
		MS_FLUSH()

	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ImpDub    ³ Autor ³Andressa Fagundes      ³ Data ³   18/05/2009   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao dos Dados para preenchimento do DUB-ICMS                ³±±
±±            Documento de Utilizacao de Beneficio Fiscal                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ FISR001                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpDub(lEnd,wnRel,cString,Tamanho,nPagina)

Local aArea      := GetArea()
Local cAliasSF3  := "SF3"
Local cIndSF3    := ""
Local cCfoAtiv   := GetNewPar("MV_CFOATIV","")
Local cCfoPFut   := GetNewPar("MV_CFOPFUT","")
Local lUfRj      := SuperGetMv('MV_ESTADO')=='RJ'
Local cTipo      := ""
Local cEspecie   := ""
Local cNumero    := ""
Local cPeriod    := ""
Local nValor     := 0
Local nLin       := 0
Local lMov       := .F.
Local nVlrIsen   := 0
Local nTamNumDub := TamSX3("F4_NUMDUB")[1]
Local cKeySF3	 := ""

//Impressao do Relatorio
Local aLay  := RDubLayOut()

//Variaveis do arquivo temporario
Local aStru := {}
Local cArq  := ""	

#IFDEF TOP
	Local aStruSF3 := {}
	Local cQuery   := ""
	Local nX       := 0
#ELSE
	Local cIndex   := ""
	Local cFiltro  := ""
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Temporario para gravacao dos Registros DUB  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru := {}
cArq  := ""
AADD(aStru,{"MES"     ,"C",002,0})
AADD(aStru,{"TIPO"    ,"C",001,0})
AADD(aStru,{"NUMERO"  ,"C",nTamNumDub,0})
AADD(aStru,{"ESPECIE" ,"C",001,0})
AADD(aStru,{"VALOR"   ,"N",014,2})

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"DUB")
IndRegua("DUB",cArq,"MES+TIPO+ESPECIE+NUMERO")

dbSelectArea("SF3")
SF3->(dbsetorder(1))

	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			cAliasSF3:= "AliasSF3"
			aStruSF3 := SF3->(dbStruct())
			cQuery := " SELECT F3_ENTRADA,F3_NFISCAL,F3_FILIAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ICMSDIF,F3_CFO,F3_ALIQICM, "
			cQuery += " F3_CRDPRES, F3_CRDTRAN, F3_BASEICM, F3_ISENICM, F3_OUTRICM, F3_VALICM, "
			cQuery += " SFT.FT_PRODUTO,SFT.FT_ITEM,SF4.F4_TIPODUB,SF4.F4_NUMDUB,SF4.F4_BENDUB
			cQuery += " FROM " + RetSqlName("SF3") + " SF3"
			cQuery += " JOIN " + RetSqlName("SFT") + " SFT ON SFT.FT_FILIAL=SF3.F3_FILIAL AND SFT.FT_SERIE = SF3.F3_SERIE AND SFT.FT_NFISCAL = SF3.F3_NFISCAL AND SFT.FT_CLIEFOR = SF3.F3_CLIEFOR AND SFT.FT_LOJA = SF3.F3_LOJA AND SFT.D_E_L_E_T_='' "
			cQuery += " JOIN " + RetSqlName("SF4") + " SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SFT.FT_TES AND SF4.D_E_L_E_T_=''
			cQuery += " WHERE F3_FILIAL = '" + xFilial("SF3") + "' AND "
			cQuery += " F3_ENTRADA >= '" + Dtos(mv_par01) + "' AND "
			cQuery += " F3_ENTRADA <= '" + Dtos(mv_par02) + "' AND "
			cQuery += " F3_TIPO <> 'S' AND "
			cQuery += " F3_DTCANC = '" + Dtos(Ctod("")) + "' AND "
			cQuery += " SF3.D_E_L_E_T_ = ' ' "
			cQuery += " AND SF4.F4_TIPODUB<>'' AND SF4.F4_NUMDUB<>'' AND SF4.F4_BENDUB<>''

			//Livro Selecionado
			If !((Empty(mv_par03)) .Or. ("*"$mv_par03))
				cQuery += " AND F3_NRLIVRO='"+mv_par03+"' "
			EndIf

			cQuery += "ORDER BY " + SqlOrder(SF3->(IndexKey()))
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)

			For nX := 1 To len(aStruSF3)
				If aStruSF3[nX][2] <> "C"
					TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
				EndIf
			Next nX

			dbSelectArea(cAliasSF3)
		Else
	#ENDIF
			cIndex  := CriaTrab(NIL,.F.)
			cFiltro	:=	"SF3->F3_FILIAL == '" + xFilial("SF3") + "' .And. DTOS(SF3->F3_ENTRADA) >= '" + Dtos(mv_par01) + "' .AND. DTOS(SF3->F3_ENTRADA) <= '" + Dtos(mv_par02) + "'"
			cFiltro	+=  " .And. SF3->F3_TIPO <> 'S' .And. Empty(F3_DTCANC) "
			//Livro Selecionado
			If !((Empty (mv_par03)) .Or. ("*"$mv_par03))
				cFiltro += ' .AND. F3_NRLIVRO=="'+mv_par03+'" '
			EndIf
			IndRegua(cAliasSF3,cIndex,SF3->(IndexKey()),,cFiltro)
			dbSelectArea(cAliasSF3)
			dbGoTop()
	#IFDEF TOP
		Endif
	#ENDIF

	SetRegua(LastRec())
	cIndSF3 := CriaTrab(NIL,.F.)

	While !(cAliasSF3)->(Eof())

		IncRegua()
		IncProc(STR0011) //"Processando Relatório"

		If Interrupcao(@lEnd)
			Exit
		Endif

		cPeriod  := Substr(DTOS((cAliasSF3)->F3_ENTRADA),5,2)
		cEspecie := ""
		If (cAliasSF3)->F3_CFO >="5"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Processamento das Saídas              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SD2->(dbSetOrder(3))
			If SD2->(dbSeek(xFilial("SD2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->FT_PRODUTO+(cAliasSF3)->FT_ITEM))
				SF4->(DbSetOrder(1))
				If SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
					cTipo   := Alltrim(SF4->F4_TIPODUB)
					cNumero := Alltrim(SF4->F4_NUMDUB)
					//Verificacao da Especie do Beneficio

					// Diferimento na Compra de Bens do Ativo Imobilizado
					If (cAliasSF3)->F3_ICMSDIF > 0 .And. Alltrim((cAliasSF3)->F3_CFO)$cCfoAtiv .And. SF4->F4_BENDUB == "1"
						nValor   := (cAliasSF3)->F3_ICMSDIF
						cEspecie := "1"
					// Diferimento para Pagamento Futuro
					Elseif (cAliasSF3)->F3_ICMSDIF > 0 .And. Alltrim((cAliasSF3)->F3_CFO)$cCfoPFut .And. SF4->F4_BENDUB == "2"
						nValor   := (cAliasSF3)->F3_ICMSDIF
						cEspecie := "2"
					// Isencao
					Elseif (cAliasSF3)->F3_BASEICM == 0 .And. (cAliasSF3)->F3_ISENICM > 0 .And. SF4->F4_BENDUB == "3"
						SF2->(DbSetOrder(1))
						SF2->(DbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
						MaFisEnd()
						MaFisIniNf(2,0,,"SF2",.F.,"FISR001")
						nValor   :=  MaFisRet(, "NF_VALICM")
						cEspecie := "3"
					// Reducao na Base de Calculo
					Elseif (SF4->F4_LFICM == "I") .And. SF4->F4_BENDUB == "4"
						If (cAliasSF3)->F3_ISENICM > 0 .And. (SF4->F4_BASEICM <> 100)
							nVlrIsen := (cAliasSF3)->F3_ISENICM
							nValor   := (nVlrIsen * SD2->D2_PICM) / 100  // Calculo para o imposto nao recolhido no mes em função do beneficio
						Else
							SF2->(DbSetOrder(1))
							SF2->(DbSeek (xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
							MaFisEnd()
							MaFisIniNf(2,0,,"SF2",.F.,"FISR001")
							nValor   := MaFisRet(,"NF_VALICM")
						Endif
						cEspecie := "4"
					Elseif (SF4->F4_LFICM == "O") .And. SF4->F4_BENDUB == "4"
						If (cAliasSF3)->F3_OUTRICM > 0 .And. (SF4->F4_BASEICM <> 100)
							nVlrIsen := (cAliasSF3)->F3_OUTRICM
							nValor   := (nVlrIsen * SD2->D2_PICM) / 100  // Calculo para o imposto nao recolhido no mes em função do beneficio
						Else
							SF2->(DbSetOrder(1))
							SF2->(DbSeek (xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
							MaFisEnd()
							MaFisIniNf(2,0,,"SF2",.F.,"FISR001")
							nValor   := MaFisRet(,"NF_VALICM")
						Endif
						cEspecie := "4"
					// Credito Presumido
					Elseif lUfRj .And. ((cAliasSF3)->F3_CRDPRES > 0 .Or. (cAliasSF3)->F3_CRDTRAN > 0) .And. SF4->F4_BENDUB == "5"
						nValor   := (cAliasSF3)->F3_CRDPRES + (cAliasSF3)->F3_CRDTRAN 
						cEspecie := "5"	
					// Outros
					Elseif (cAliasSF3)->F3_BASEICM == 0 .And. ((cAliasSF3)->F3_ISENICM > 0 .Or. (cAliasSF3)->F3_OUTRICM > 0) .And. SF4->F4_BENDUB == "6"
						SF2->(DbSetOrder(1))
						SF2->(DbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
						MaFisEnd()
						MaFisIniNf(2,0,,"SF2",.F.,"FISR001")
						nValor   :=  MaFisRet(, "NF_VALICM")
						cEspecie := "6"
					Endif
					If !Empty(Alltrim(cTipo)) .And. !Empty(Alltrim(cEspecie)) .And. !Empty(Alltrim(cNumero))
						dbSelectArea("DUB")
						If !DUB->(DbSeek(Alltrim(cPeriod+cTipo+cEspecie+cNumero)))
							RecLock("DUB",.T.)
							DUB->MES     := cPeriod
							DUB->TIPO    := cTipo
							DUB->NUMERO  := cNumero
							DUB->ESPECIE := cEspecie
							DUB->VALOR   := nValor
							MsUnlock()
							lMov := .T.
						Else
							//Como a MafisiniNF ja adicionará todos os itens e retornará o impostos total, se for a mesma nota e adicionar aqui, fica valor duplicado. Sei que no if acima se a nota tiver itens com F4_NUMDUB diferentes, também ficará duplicado, mas é um conceito que precisamos avaliar.
							if cKeySF3 <> (cAliasSF3)->F3_FILIAL+DTOS((cAliasSF3)->F3_ENTRADA)+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_CFO+cValToChar((cAliasSF3)->F3_ALIQICM)
								RecLock("DUB",.F.)
								DUB->VALOR   += nValor
								MsUnLock()
								lMov := .T.	
							endif												
						Endif
					Endif
				Endif
			Endif
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Processamento das Entradas           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SD1->(dbSetOrder(1))
			If SD1->(dbSeek(xFilial("SD1")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->FT_PRODUTO+(cAliasSF3)->FT_ITEM))
				SF4->(DbSetOrder(1))
				If SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES))
					cTipo   := SF4->F4_TIPODUB
					cNumero := Alltrim(SF4->F4_NUMDUB)

					//Verificacao da Especie do Beneficio

					// Diferimento na Compra de Bens do Ativo Imobilizado
					If (cAliasSF3)->F3_ICMSDIF > 0 .And. Alltrim((cAliasSF3)->F3_CFO)$cCfoAtiv .And. SF4->F4_BENDUB == "1"
						nValor   := (cAliasSF3)->F3_ICMSDIF
						cEspecie := "1"
					// Diferimento para Pagamento Futuro
					Elseif (cAliasSF3)->F3_ICMSDIF > 0 .And. Alltrim((cAliasSF3)->F3_CFO)$cCfoPFut .And. SF4->F4_BENDUB == "2"
						nValor   := (cAliasSF3)->F3_ICMSDIF
						cEspecie := "2"
					// Isencao
					Elseif (cAliasSF3)->F3_BASEICM == 0 .And. (cAliasSF3)->F3_ISENICM > 0 .And. SF4->F4_BENDUB == "3"
						SF1->(DbSetOrder(1))
						SF1->(DbSeek (xFilial("SF1")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
						MaFisEnd()
						MaFisIniNf(1,0,,"SF1",.F.,"FISR001")
						nValor   := MaFisRet(,"NF_VALICM")
						cEspecie := "3"
					// Reducao na Base de Calculo
					Elseif (SF4->F4_LFICM == "I") .And. SF4->F4_BENDUB == "4"
						If (cAliasSF3)->F3_ISENICM > 0 .And. (SF4->F4_BASEICM <> 100)
							nVlrIsen := (cAliasSF3)->F3_ISENICM
							nValor   := (nVlrIsen * SD1->D1_PICM) / 100  // Calculo para o imposto nao recolhido no mes em função do beneficio
						Else
							nVlrIsen := (cAliasSF3)->F3_ISENICM
							SF1->(DbSetOrder(1))
							SF1->(DbSeek (xFilial("SF1")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
							MaFisEnd()
							MaFisIniNf(1,0,,"SF1",.F.,"FISR001")
							nValor   := MaFisRet(,"NF_VALICM")
						Endif
						cEspecie := "4"
					Elseif (SF4->F4_LFICM == "O") .And. SF4->F4_BENDUB == "4"
						If (cAliasSF3)->F3_OUTRICM > 0 .And. (SF4->F4_BASEICM <> 100)
							nVlrIsen := (cAliasSF3)->F3_OUTRICM
							nValor   := (nVlrIsen * SD1->D1_PICM) / 100  // Calculo para o imposto nao recolhido no mes em função do beneficio
						Else
							nVlrIsen := (cAliasSF3)->F3_OUTRICM
							SF1->(DbSetOrder(1))
							SF1->(DbSeek (xFilial("SF1")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
							MaFisEnd()
							MaFisIniNf(1,0,,"SF1",.F.,"FISR001")
							nValor   := MaFisRet(,"NF_VALICM")
						Endif
						cEspecie := "4"
					// Credito Presumido
					Elseif lUfRj .And. ((cAliasSF3)->F3_CRDPRES > 0 .Or. (cAliasSF3)->F3_CRDTRAN > 0) .And. SF4->F4_BENDUB == "5"
						nValor   := (cAliasSF3)->F3_CRDPRES + (cAliasSF3)->F3_CRDTRAN
						cEspecie := "5"
					// Outros
					Elseif (cAliasSF3)->F3_BASEICM == 0 .And. ((cAliasSF3)->F3_ISENICM > 0 .Or. (cAliasSF3)->F3_OUTRICM > 0) .And. SF4->F4_BENDUB == "6"
						SF1->(DbSetOrder(1))
						SF1->(DbSeek (xFilial("SF1")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
						MaFisEnd()
						MaFisIniNf(1,0,,"SF1",.F.,"FISR001")
						nValor   := MaFisRet(,"NF_VALICM")
						cEspecie := "6"
					Endif
					If !Empty(Alltrim(cTipo)) .And. !Empty(Alltrim(cEspecie)) .And. !Empty(Alltrim(cNumero))
						dbSelectArea("DUB")
						If !DUB->(DbSeek(cPeriod+cTipo+cEspecie+cNumero))
							RecLock("DUB",.T.)
							DUB->MES     := cPeriod
							DUB->TIPO    := cTipo
							DUB->NUMERO  := cNumero
							DUB->ESPECIE := cEspecie
							DUB->VALOR   := nValor
							MsUnlock()
							lMov := .T.
						Else
							//Como a MafisiniNF ja adicionará todos os itens e retornará o impostos total, se for a mesma nota e adicionar aqui, fica valor duplicado. Sei que no if acima se a nota tiver itens com F4_NUMDUB diferentes, também ficará duplicado, mas é um conceito que precisamos avaliar.
							if cKeySF3 <> (cAliasSF3)->F3_FILIAL+DTOS((cAliasSF3)->F3_ENTRADA)+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_CFO+cValToChar((cAliasSF3)->F3_ALIQICM)
								RecLock("DUB",.F.)
								DUB->VALOR   += nValor
								MsUnLock()
								lMov := .T.
							endif
						Endif
					Endif
				EndIf
			Endif
		Endif
		
		cKeySF3:= (cAliasSF3)->F3_FILIAL+DTOS((cAliasSF3)->F3_ENTRADA)+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_CFO+cValToChar((cAliasSF3)->F3_ALIQICM)
		(cAliasSF3)->(dbSkip())
		nValor := 0
	Enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime as movimentacoes de entrada e saida processadas.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("DUB")
	dbSetOrder(1)
	dbGotop()

	nLin := DubCabec()
	FmtLin(,aLay[12],,,@nLin)
	FmtLin(,aLay[13],,,@nLin)
	FmtLin(,aLay[14],,,@nLin)
	FmtLin(,aLay[15],,,@nLin)
	While !DUB->(Eof())
		
		IncRegua()

		If nLin > 60
			FmtLin(,aLay[19],,,@nLin)
			nLin := DubCabec()
			FmtLin(,aLay[12],,,@nLin)
			FmtLin(,aLay[13],,,@nLin)
			FmtLin(,aLay[14],,,@nLin)
			FmtLin(,aLay[15],,,@nLin)
		Endif

		//Tipo Ato Legal
		Do Case
		Case DUB->TIPO == "1"
			cTipo := STR0013 //"CONVENIO"
		Case DUB->TIPO == "2"
			cTipo := STR0014 //"LEI"
		Case DUB->TIPO == "3"
			cTipo := STR0015 //"DECRETO"
		Case DUB->TIPO == "4"
			cTipo := STR0016 //"PROTOCOLO"
		Case DUB->TIPO == "5"
			cTipo := STR0017 //"RESOLUÇÃO"
		Case DUB->TIPO == "6"
			cTipo := STR0018 //"PORTARIA"
		EndCase

		//Especie do Beneficio
		Do Case
		Case DUB->ESPECIE == "1"
			cEspecie := STR0019 //"DIFERIMENTO NA COMPRA DE BENS DO ATIVO IMOBILIZADO"
		Case DUB->ESPECIE == "2"
			cEspecie := STR0020 //"DIFERIMENTO PARA PAGAMENTO FUTURO"
		Case DUB->ESPECIE == "3"
			cEspecie := STR0021 //"ISENÇÃO"
		Case DUB->ESPECIE == "4"
			cEspecie := STR0022 //"REDUÇÃO DE BASE DE CÁLCULO"
		Case DUB->ESPECIE == "5"
			cEspecie := STR0023 //"CRÉDITO PRESUMIDO"
		Case DUB->ESPECIE == "6"
			cEspecie := STR0032 //"OUTROS"
		EndCase

		FmtLin({MesExtenso(DUB->MES),cTipo,DUB->NUMERO,cEspecie,Alltrim(TransForm(DUB->VALOR,"@E 999,999,999.99"))},aLay[16],,,@nLin)
		DUB->(dbSkip(1))
	Enddo

	If !lMov
		FmtLin(,aLay[18],,,@nLin)
	Endif

	FmtLin(,aLay[19],,,@nLin)

	#IFDEF TOP
		dbSelectArea(cAliasSF3)
		dbCloseArea()
	#ELSE
		dbSelectArea(cAliasSF3)
		RetIndex(cAliasSF3)
		dbClearFilter()
		Ferase(cIndSF3+OrdBagExt())
	#ENDIF

	RestArea(aArea)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga arquivo temporario                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("DUB")
	dbCloseArea()
	Ferase(cArq)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³RetPeriod ³ Autor ³Andressa Fagundes      ³ Data ³   18/05/2009   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a periodicidade conforme as datas informadas              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³FISR001                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetPeriod(mv_par01,mv_par02)

Local aRet      := {}
Local nMesIni   := Month(mv_par01)
Local nMesFim   := Month(mv_par02)
Local cAnual    := OemToAnsi(STR0009)+StrZero(Year(mv_par02),4) //"Anual - "
Local cSemestre := OemToAnsi(STR0010)+StrZero(Year(mv_par02),4) //"º. Semestre/"

If nMesIni <> nMesFim
	Do Case
		Case nMesIni ==  1 .And. nMesFim ==  6
			aRet := {"1"+cSemestre,.F.}	//1o. Semestre
		Case nMesIni ==  7 .And. nMesFim == 12
			aRet := {"2"+cSemestre,.F.}	//2o. Semestre
		Case nMesIni ==  1 .And. nMesFim ==  12
			aRet := {cAnual,.F.}	// Anual
		Otherwise
			aRet := {"",.T.}		//Periodo Incorreto
	EndCase
Else
	aRet := {"",.T.} //Periodo Incorreto
Endif

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³DubCabec    ºAutor  ³ Andressa Fagundes  º Data ³ 19/05/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Imprime o cabecalho                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³FISR001                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function DubCabec()

Local nLin := 0
Local aLay := RDubLayOut()

	nLin:=3
	@ 0,0 PSAY AvalImp(220)
	FmtLin(,aLay[01],,,@nLin)
	FmtLin(,aLay[02],,,@nLin)
	FmtLin(,aLay[03],,,@nLin)
	FmtLin({SM0->M0_NOMECOM},aLay[04],,,@nLin)
	FmtLin(,aLay[05],,,@nLin)
	FmtLin({Transform(SM0->M0_INSC,"@R 999.999.999.999"),Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")},aLay[06],,,@nLin)
	FmtLin(,aLay[07],,,@nLin)
	FmtLin({RetPeriod(MV_PAR01,MV_PAR02)[1],Iif(!Empty(MV_PAR04),MV_PAR04,STR0012)},aLay[08],,,@nLin) //"NÃO POSSUI"
	FmtLin(,aLay[09],,,@nLin)
	FmtLin(,aLay[10],,,@nLin)
	FmtLin(,aLay[11],,,@nLin)

Return(nLin)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³RDubLayOut³ Autor ³Andressa Fagundes      ³ Data ³   19/05/2009   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Layout                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ FISR001                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RDubLayOut()

Local aLay := Array(19)

aLay[01]:=          "+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aLay[02]:=STR0024 //"|                                                                     DUB-ICMS - DOCUMENTO DE UTILIZAÇÃO DE BENEFÍCIO FISCAL                                                                               |"
aLay[03]:=          "|                                                                                                                                                                                                          |"
aLay[04]:=STR0025 //"| RAZÃO SOCIAL: #############################                                                                                                                                                              |"
aLay[05]:=          "|                                                                                                                                                                                                          |"
aLay[06]:=STR0026 //"| INSCRIÇÃO ESTADUAL: ###########              C.N.P.J.: ##############                                                                                                                                    |"
aLay[07]:=          "|                                                                                                                                                                                                          |"
aLay[08]:=STR0027 //"| PERIODO DE REFERÊNCIA: #######               DATA DO TERMO DE ACORDO: #######                                                                                                                            |"
aLay[09]:=          "|                                                                                                                                                                                                          |"
aLay[10]:=          "|                                                                                                                                                                                                          |"
aLay[11]:=          "|==========================================================================================================================================================================================================|"
aLay[12]:=STR0028 //"|                    |                            INSTRUMENTO LEGAL                                     |    ESPÉCIE DO BENEFÍCIO     |        IMPOSTO NÃO RECOLHIDO NO MÊS EM FUNÇÃO DO BENEFÍCIO         |"
aLay[13]:=          "|                    |----------------------------------------------------------------------------------|-----------------------------|--------------------------------------------------------------------|"
aLay[14]:=STR0029 //"|  MÊS DE REFERÊNCIA |   TIPO DO ATO LEGAL     |                       NÚMERO/ANO                       |            ESPÉCIE          |  VALOR DO IMPOSTO                                                  |"
aLay[15]:=          "|====================+=========================+========================================================+=============================+====================================================================|"
aLay[16]:=STR0030 //"|  ##########        |   ##########            |  ################################################      |  ########################## |  R$ ##############                                                 |"
aLay[17]:=          "|====================+=========================+========================================================+=============================+====================================================================|"
aLay[18]:=STR0031 //"|       *** NAO HOUVE MOVIMENTO ***                                                                                                                                                                        |"
aLay[19]:=          "+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"

Return aLay
