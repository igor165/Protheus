#INCLUDE "TopConn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FISA027.CH"                                                                                
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FISA027    ³ Autor ³ Ivan Haponczuk       ³ Data ³02/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Apuracao de imposto ISC-02                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISA027()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                      								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Republica Dominicana                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FISA027()
Local 	aArea	 := GetArea()
Local 	cCadastro:= STR0001//"DGII ISC-02" 
Local 	aSays	 := {}
Local 	aButtons := {}
Local 	aProcFil := {}
Local 	aTrab	 := {}
Local 	nx   	 := 0 
Local 	nxOpc	 := 0 
Local 	lPerg	 := .F.
Local   lExclTit := .F.
Local	cNorma   := ""
Local	cDest    := ""
Private	cpDir    := ""
Private cPerg	 := "FISA027"

aAdd(aSays,STR0002)//"Essa rotina tem a finalidade de efetuar a apuração do ISC"
aAdd(aSays,STR0003)//"para bebidas e cigarros."
aAdd(aSays,"")
aAdd(aButtons,{5,.T.,{ || lPerg := Pergunte(cPerg,.T.) }})
aAdd(aButtons,{1,.T.,{ || nxOpc := 1,FechaBatch()      }})
aAdd(aButtons,{2,.T.,{ || nxOpc := 0,FechaBatch()      }})
FormBatch(cCadastro,aSays,aButtons)      

//*****************************************************************
//Parametros FISA027 - Rep. Dominicana
//*****************************************************************
//MV_PAR01 - Data Inicial
//MV_PAR02 - Data Final
//MV_PAR03 - Gera Titulo
//MV_PAR04 - Data Limite para Pagamento
//MV_PAR05 - Arquivo do Periodo Anterior
//MV_PAR06 - Inst. Normativa
//MV_PAR07 - Arquivo Destino
//MV_PAR08 - Diretorio
//*****************************************************************

If nxOpc == 1
	If !lPerg
		lPerg := Pergunte(cPerg,.T.)
	Endif 
	If lPerg
		cNorma		:= AllTrim(MV_PAR06) + ".INI"
		cpDir		:= Alltrim(MV_PAR08)
		cDirRec		:= cpDir	 	    
		aProcFil	:= {.F.,cFilAnt}
		
		If File(AllTrim(MV_PAR08)+AllTrim(MV_PAR07)+".ISC2")
			If MsgYesNo(STR0094)//"Periodo ja apurado. Deseja refazer?"
				MsgRun(STR0095,,{|| lExclTit := DelTitApur(AllTrim(MV_PAR08)+AllTrim(MV_PAR07)+".ISC2")})//"Cancelando apuracao anterior"
				If !lExclTit
					MsgStop(STR0096,STR0097) //"O titulo já foi baixado.Apenas será possível excluir o título gerado e baixado anteriormente se for estornado."###"Apenas será possível excluir o título gerado e baixado anteriormente se for estornado"
					Return Nil
				Endif
			Else
				Return Nil
			EndIf
		EndIf
		
		dbSelectArea("SX3")
		dbSetOrder(1)
		Processa({||ProcNorma(cNorma,cDest,cDirRec,aProcFil,@aTrab)})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ferase no array aTrab                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to Len(aTrab)
			Ferase(AllTrim(aTrab[nX][1]))
		Next
		DbSelectArea("SF3")
		DbSetOrder(1)
	EndIF
Endif
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DelTitApur   ³ Autor ³ Ivan Haponczuk    ³ Data ³21/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Excluir o titulo de apuração para o governo.				  ³±±	
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DelTitApur() 		                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum								  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet- Se .T. Foi excluido. Se .F. não foi possivel excluir ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rep. Dominicana  	                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/         
Static Function DelTitApur(cNomArq)

Local   lRet        := .T.
Local   cBuffer     := ""
Local   aLin        := {}
Local   aDadosSE2   := {}
Private lMsErroAuto := .F.

If FT_FUSE(cNomArq) <> -1
	FT_FGOTOP()
	Do While !FT_FEOF()
		cBuffer := FT_FREADLN()
		If Substr(cBuffer,1,3) == "TIT"
			aLin := Separa(cBuffer,";")
			dbSelectArea("SE2")
			SE2->(dbGoTop())
			SE2->(dbSetOrder(1))
			If SE2->(dbSeek(xFilial("SE2")+aLin[2]+aLin[3]))
				If SE2->E2_VALOR <> SE2->E2_SALDO //Já foi dado Baixa no Título				
					lRet := .F.
				Else	
					aAdd(aDadosSE2,{"E2_FILIAL" ,xFilial("SE2"),nil})
					aAdd(aDadosSE2,{"E2_PREFIXO",SE2->E2_PREFIXO,nil})
					aAdd(aDadosSE2,{"E2_NUM"    ,SE2->E2_NUM,nil})
					aAdd(aDadosSE2,{"E2_PARCELA",SE2->E2_PARCELA,nil})
					aAdd(aDadosSE2,{"E2_TIPO"   ,SE2->E2_TIPO,nil})
					aAdd(aDadosSE2,{"E2_FORNECE",SE2->E2_FORNECE,nil})
					aAdd(aDadosSE2,{"E2_LOJA"   ,SE2->E2_LOJA,nil})
					     
					MsExecAuto({|x,y,z| FINA050(x,y,z)},aDadosSE2,,5)
					If lMsErroAuto
		       			MostraErro()
		       			lRet := .F.
			  		EndIf
				EndIf
			Endif
		EndIF
		FT_FSKIP()
	EndDo
Else
	Alert(STR0098) //"Erro na abertura do arquivo"
	Return Nil	
EndIF
FT_FUSE()

If lRet
	fErase(cNomArq)
Endif

Return lRet 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FISC02  ³ Autor ³ Ivan Haponczuk  		³ Data ³02/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega os valores do imposto ISC para a impressao         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQImposto()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum       	         								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Republica Dominicana                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISC02(aDadGer)

	Local nlX      := 0
	Local nlY      := 0
	Local nlTot    := 0
	Local aDados   := {}
	Local aApuAnt  := {}
	Local aTitulos := {}
	Local cQry     := ""
	
	For nlX:=1 To 32 // Numero de linhas
		aAdd(aDados,{})
		For nlY:=1 To 9 // Numero de colunas
			aAdd(aDados[nlX],0)
		Next nlX
	Next nlX
	
	cQry := " SELECT 'S' AS TIPO" + CRLF
	cQry += " ,SF2.F2_ESPECIE AS ESPECIE" + CRLF
	cQry += " ,CCR.CCR_GAPUR AS CAMPO" + CRLF 
	cQry += " ,SUM(SD2.D2_TOTAL) AS OPERAC" + CRLF
	cQry += " ,SB1.B1_MARGISC AS AJUSTE" + CRLF
	cQry += " ,CCR.CCR_ALIQ AS TAXA" + CRLF
	cQry += " ,CASE WHEN SB1.B1_FATISC = 0 THEN SUM(SD2.D2_QUANT) ELSE (SUM(SD2.D2_QUANT*SB1.B1_FATISC)) END AS QUANT" + CRLF
	cQry += " ,CCR.CCR_VALOR AS MONTA" + CRLF
	cQry += " FROM "+RetSqlName("CCR")+" CCR" + CRLF
	cQry += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON(SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_CONISC = CCR.CCR_CONCEP)" + CRLF
	cQry += " INNER JOIN "+RetSqlName("SD2")+" SD2 ON(SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND SB1.B1_COD = SD2.D2_COD  AND SD2.D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"')" + CRLF
	cQry += " INNER JOIN "+RetSqlName("SF2")+" SF2 ON(SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND SF2.F2_DOC = SD2.D2_DOC AND SF2.D_E_L_E_T_ ='')" + CRLF
	cQry += " WHERE CCR.CCR_FILIAL = '"+xFilial("CCR")+"' AND CCR.CCR_APUR = '3'" + CRLF
	cQry += " GROUP BY SF2.F2_ESPECIE ,CCR.CCR_GAPUR ,CCR.CCR_VALOR ,SB1.B1_MARGISC ,SB1.B1_FATISC ,CCR.CCR_ALIQ" + CRLF
	cQry += " UNION" + CRLF
	cQry += " SELECT 'E' AS TIPO" + CRLF
	cQry += " ,SF1.F1_ESPECIE AS ESPECIE" + CRLF
	cQry += " ,CCR.CCR_GAPUR AS CAMPO" + CRLF
	cQry += " ,SUM(SD1.D1_TOTAL) AS OPERAC" + CRLF
	cQry += " ,SB1.B1_MARGISC AS AJUSTE" + CRLF
	cQry += " ,CCR.CCR_ALIQ AS TAXA" + CRLF
	cQry += " ,CASE WHEN SB1.B1_FATISC = 0 THEN SUM(SD1.D1_QUANT) ELSE (SUM(SD1.D1_QUANT*SB1.B1_FATISC)) END AS QUANT" + CRLF
	cQry += " ,CCR.CCR_VALOR AS MONTA" + CRLF
	cQry += " FROM "+RetSqlName("CCR")+" CCR" + CRLF
	cQry += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON(SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_CONISC = CCR.CCR_CONCEP)" + CRLF
	cQry += " INNER JOIN "+RetSqlName("SD1")+" SD1 ON(SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND SB1.B1_COD = SD1.D1_COD AND SD1.D1_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"')" + CRLF
	cQry += " INNER JOIN "+RetSqlName("SF1")+" SF1 ON(SF1.F1_FILIAL = '"+xFilial("SF1")+"' AND SF1.F1_DOC = SD1.D1_DOC AND SF1.D_E_L_E_T_ ='')" + CRLF
	cQry += " WHERE CCR.CCR_FILIAL = '"+xFilial("CCR")+"' AND CCR.CCR_APUR = '3'" + CRLF
	cQry += " GROUP BY SF1.F1_ESPECIE ,CCR.CCR_GAPUR ,CCR.CCR_VALOR ,SB1.B1_MARGISC ,SB1.B1_FATISC ,CCR.CCR_ALIQ" + CRLF

	TcQuery cQry New Alias "DGII"
	dbSelectArea("DGII")
	Do While DGII->(!EOF())
		nPos := DGII->CAMPO
		If Len(aDados) >= nPos
			If AllTrim(DGII->ESPECIE) $ "NCC|NDE|NDI|NCP"
				aDados[nPos][1] -= DGII->OPERAC
				aDados[nPos][6] -= DGII->QUANT
			Else
				aDados[nPos][1] += DGII->OPERAC
				aDados[nPos][6] += DGII->QUANT
			EndIf
			aDados[nPos][2] := DGII->AJUSTE
			aDados[nPos][3] := aDados[nPos][1] + ((aDados[nPos][1] * aDados[nPos][2])/100)
			aDados[nPos][4] := DGII->TAXA
			aDados[nPos][5] := (aDados[nPos][3] * aDados[nPos][4])/100
			aDados[nPos][7] := DGII->MONTA
			aDados[nPos][8] := aDados[nPos][6] * aDados[nPos][7]
			aDados[nPos][9] := aDados[nPos][5] + aDados[nPos][8]
		EndIf
		DGII->(dbSkip())
	EndDo	
	DGII->(dbCloseArea())

	aApuAnt := FMApur(Alltrim(MV_PAR08),AllTrim(MV_PAR05))
	If Len(aApuAnt) >= 28
		If Len(aApuAnt[28]) >= 9
			aDados[25][9] := Val(aApuAnt[28][10])
		EndIf
	EndIf
	
	//Preenchidos pelo usuário.
	aDados[18][9] := Val(aDadGer[1][1])
	aDados[20][9] := Val(aDadGer[1][2])
	aDados[21][9] := Val(aDadGer[1][3])
	aDados[24][9] := Val(aDadGer[1][4])
	If Val(aDadGer[1][5]) > 0
		aDados[25][9] := Val(aDadGer[1][5])
	EndIf
	aDados[26][9] := Val(aDadGer[1][6])
	aDados[29][9] := Val(aDadGer[1][7])
	aDados[30][9] := Val(aDadGer[1][8])
	aDados[31][9] := Val(aDadGer[1][9])
	
	//Grava totais
	nlTot := 0
	For nlX:=1 To 13
		nlTot += aDados[nlX][9]
	Next nlX
	aDados[14][9] := nlTot
	aDados[17][9] := aDados[15][9] + aDados[16][9]
	aDados[19][9] := aDados[14][9] + aDados[17][9] + aDados[18][9]
	nlTot := aDados[19][9] - aDados[20][9] - aDados[21][9]
	If nlTot > 0
		aDados[22][9] := nlTot
	Else
		aDados[23][9] := nlTot*-1
	EndIf
	nlTot := aDados[22][9] - aDados[23][9] - aDados[24][9] - aDados[25][9] - aDados[26][9]
	If nlTot > 0
		aDados[27][9] := nlTot
	Else
		aDados[28][9] := nlTot*-1
	EndIf
	aDados[32][9] := aDados[27][9] + aDados[29][9] + aDados[30][9] + aDados[31][9]
	
	FRConf(aDados) //Geração do Relatorio de Conferencia das Informações

	If MV_PAR03 == 1
		MsgRun(STR0004,,{|| IIf(aDados[32][9]>0,aTitulos := GrvTitLoc(aDados[32][9]),Nil) })//"Gerando titulo de apuração..."
	Endif

	MsgRun(STR0005,,{|| CriarArq(AllTrim(MV_PAR08),AllTrim(MV_PAR07),aDados,aTitulos) })//"Gerando Arquivo apuração de imposto..."
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    FRConf() ³ Autor ³ Ivan Haponczuk          ³ Data ³02/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função que cria o objeto do TMSPRINTER e chama as funções  ³±±
±±³ 		 | de impressão do cabeçalho e do corpo do relatorio		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FRConf()				                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impostos			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRConf(aDados)
    
	Private apTabApu    := {}
    Private clTitulo 	:= STR0006//"Relatório de Conferência de Informações"
   	Private opFont1		:= TFont():New("Garamond",,15,,.T.,,,,,.F.)
	Private opFont2  	:= TFont():New("Perpetua",,11,,.T.,,,,,.F.)
	Private opFont3  	:= TFont():New("Perpetua",,11,,.F.,,,,,.F.)
	Private opFont4  	:= TFont():New("Perpetua",,10,,.F.,,,,,.F.)
    
	oPrn := TmsPrinter():New(clTitulo)
	oPrn:SetPaperSize(9)
	oPrn:SetPortrait()
	oPrn:StartPage()

    nLin := FPag1(aDados,260)
    nLin += 60
    nLin := FPag2(aDados,nLin)
    nLin += 60
    nLin := FTotal(aDados,nLin)
       
	oPrn:EndPage()
	oPrn:Preview()
	oPrn:End()
	
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ FPag1   ³ Autor ³ Ivan Haponczuk         ³ Data ³02/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que faz a impressão dos registros					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FPag1()				                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impostos			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FPag1(aDados,nLinIni)

	Local nColSize := 0
	Local nColIni  := 40
	Local nLin     := 0

 	oPrn:Box(0020,0020,0080,2355)
	oPrn:Say(0022,040,STR0007,opFont1)//"Direção Geral de Impostos Internos - ISC-02"
	
	oPrn:Box(0080,0020,0240,2355)
	oPrn:Say(0085,0040,STR0008,opFont2)//"Dados Gerais"
	oPrn:Line(0140,0020,0140,2355)
	oPrn:Say(0145,0040,STR0009+SM0->M0_CGC+STR0010+SM0->M0_NOME,opFont3)//"RNC: "###" Razão Social:"
	oPrn:Line(0190,0020,0190,2355)
	oPrn:Say(0195,0040,STR0011+SM0->M0_NOMECOM+STR0012+SM0->M0_TEL+STR0013+SM0->M0_TEL,opFont3)//"Nome comercial: "##" Telefone: "##" Fax: "
	
	oPrn:Box(0080,1900,0240,2355)
	oPrn:Say(0085,1920,STR0014,opFont2)//"Periodo"
	oPrn:Say(0145,1950,STR0015,opFont3)//"MES"
	oPrn:Say(0145,2200,STR0016,opFont3)//"ANO"
	oPrn:Say(0195,1950,SubSTR(dtos(MV_PAR01),5,2),opFont3)
	oPrn:Say(0195,2200,SubSTR(dtos(MV_PAR01),1,4),opFont3)
	oPrn:Line(0140,2100,0240,2100)
	
	nColSize := nColIni
	nLin := nLinIni
	oPrn:Box(nLin,0020,nLinIni+1655,2355)
	
	oPrn:Say(nLin+005,nColSize,"",opFont2)
	oPrn:Say(nLin+055,nColSize,STR0017,opFont2)//"II. Bebidas e"	
	oPrn:Say(nLin+105,nColSize,STR0018,opFont2)//"alcool"
	nColSize += 245
	
	oPrn:Line(nLin,nColSize-20,nLinIni+1655,nColSize-20)
	oPrn:Say(nLin+005,nColSize,STR0019,opFont2)//a) Total"
	oPrn:Say(nLin+055,nColSize,STR0020,opFont2)//"Operacoes"
	oPrn:Say(nLin+105,nColSize,STR0021,opFont2)//"gravadas"
	nColSize += 260
	
	oPrn:Line(nLin,nColSize-20,nLinIni+1655,nColSize-20)
	oPrn:Say(nLin+005,nColSize,"",opFont2)
	oPrn:Say(nLin+055,nColSize,STR0022,opFont2)//"%"
	oPrn:Say(nLin+105,nColSize,STR0023,opFont2)//"Ajuste"
	nColSize += 140
	
	oPrn:Line(nLin,nColSize-20,nLinIni+1655,nColSize-20)
	oPrn:Say(nLin+005,nColSize,"",opFont2)
	oPrn:Say(nLin+055,nColSize,STR0024,opFont2)//"b) Base"
	oPrn:Say(nLin+105,nColSize,STR0025,opFont2)//"imponivel"
	nColSize += 260
	
	oPrn:Line(nLin,nColSize-20,nLinIni+1655,nColSize-20)
	oPrn:Say(nLin+005,nColSize,"",opFont2)
	oPrn:Say(nLin+055,nColSize,STR0026,opFont2)//"Taxa"
	oPrn:Say(nLin+105,nColSize,STR0022,opFont2)//"%"
	nColSize += 140
	
	oPrn:Line(nLin,nColSize-20,nLinIni+1655,nColSize-20)
	oPrn:Say(nLin+005,nColSize,"",opFont2)
	oPrn:Say(nLin+055,nColSize,STR0027,opFont2)//"c) Imposto"
	oPrn:Say(nLin+105,nColSize,STR0028,opFont2)//"adicional"
	nColSize += 260
	
	oPrn:Line(nLin,nColSize-20,nLinIni+1655,nColSize-20)
	oPrn:Say(nLin+005,nColSize,"",opFont2)
	oPrn:Say(nLin+055,nColSize,STR0029,opFont2)//"d)Total Litros"
	oPrn:Say(nLin+105,nColSize,STR0030,opFont2)//"alcool absol."
	nColSize += 260
	
	oPrn:Line(nLin,nColSize-20,nLinIni+1655,nColSize-20)
	oPrn:Say(nLin+005,nColSize,"",opFont2)
	oPrn:Say(nLin+055,nColSize,STR0031,opFont2)//"e) Montante"
	oPrn:Say(nLin+105,nColSize,STR0032,opFont2)//"expecifico"
	nColSize += 260
	
	oPrn:Line(nLin,nColSize-20,nLinIni+1655,nColSize-20)
	oPrn:Say(nLin+005,nColSize,"",opFont2)
	oPrn:Say(nLin+055,nColSize,STR0033,opFont2)//"f) Imposto"
	oPrn:Say(nLin+105,nColSize,STR0034,opFont2)//"liquidado"
	nColSize += 260
	
	oPrn:Line(nLin,nColSize-20,nLinIni+1655,nColSize-20)
	oPrn:Say(nLin+005,nColSize,"",opFont2)
	oPrn:Say(nLin+055,nColSize,STR0035,opFont2)//"g) Imposto"
	oPrn:Say(nLin+105,nColSize,STR0036,opFont2)//"total"

	nColSize := nColIni
	nLin += 155
	oPrn:Line(nLin,0020,nLin,2355)
	oPrn:Say(nLin+010,nColSize,STR0037,opFont3)//"1.Cerveja"
	nColSize += 245
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[1,1],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[1,2],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[1,3],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[1,4],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[1,5],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[1,6],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[1,7],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[1,8],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[1,9],"@E 999,999,999.99"),opFont3)

	nColSize := nColIni
	nLin += 60
	oPrn:Line(nLin,0020,nLin,2355)
	oPrn:Say(nLin+015,nColSize,STR0038,opFont3)//"2.Vinos de"
	nColSize += 245
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[2,1],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[2,2],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[2,3],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[2,4],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[2,5],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[2,6],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[2,7],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[2,8],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[2,9],"@E 99,999,999.99"),opFont3)
	nColSize := nColIni
	nLin += 40
	oPrn:Say(nLin+015,nColSize,STR0039,opFont3)//"Uvas"

	nColSize := nColIni	
	nLin += 60
	oPrn:Line(nLin,0020,nLin,2355)
	oPrn:Say(nLin+015,nColSize,STR0040,opFont3)//"3.Vermut e"
	nLin += 40
	oPrn:Say(nLin+015,nColSize,STR0041,opFont3)//"demais vinos"
	nColSize += 245
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[3,1],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[3,2],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[3,3],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[3,4],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[3,5],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[3,6],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[3,7],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[3,8],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[3,9],"@E 99,999,999.99"),opFont3)
	nColSize := nColIni
	nLin += 40
	oPrn:Say(nLin+015,nColSize,STR0042,opFont3)//"de uvas"
	nLin += 40
	oPrn:Say(nLin+015,nColSize,STR0043,opFont3)//"frescas"

	nColSize := nColIni	
	nLin += 60
	oPrn:Line(nLin,0020,nLin,2355)
	oPrn:Say(nLin+015,nColSize,STR0044,opFont3)//"4.Demais"
	nLin += 40
	oPrn:Say(nLin+015,nColSize,STR0045,opFont3)//"bebidas"
	nColSize += 245
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[4,1],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[4,2],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[4,3],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[4,4],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[4,5],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[4,6],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[4,7],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[4,8],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[4,9],"@E 99,999,999.99"),opFont3)
	nColSize := nColIni
	nLin += 40
	oPrn:Say(nLin+015,nColSize,STR0046,opFont3)//"fermentadas"

	nColSize := nColIni
	nLin += 60
	oPrn:Line(nLin,0020,nLin,2355)
	oPrn:Say(nLin+015,nColSize,STR0047,opFont3)//"5.Alcool"
	nLin += 40
	oPrn:Say(nLin+015,nColSize,STR0048,opFont3)//"etilico sem"
	nLin += 40
	oPrn:Say(nLin+015,nColSize,STR0049,opFont3)//"desnaturalizar"
	nColSize += 245
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[5,1],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[5,2],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[5,3],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[5,4],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[5,5],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[5,6],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[5,7],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[5,8],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[5,9],"@E 99,999,999.99"),opFont3)
	nColSize := nColIni
	nLin += 40
	oPrn:Say(nLin+015,nColSize,STR0050,opFont3)//"(maior ou igual"
	nLin += 40
	oPrn:Say(nLin+015,nColSize,STR0051,opFont3)//"a 80%)"	

	nColSize := nColIni	
	nLin += 60
	oPrn:Line(nLin,0020,nLin,2355)
	oPrn:Say(nLin+015,nColSize,STR0052,opFont3)//"6.Alcool"
	nLin += 40
	oPrn:Say(nLin+015,nColSize,STR0053,opFont3)//"etilico sem"
	nLin += 40
	oPrn:Say(nLin+015,nColSize,STR0054,opFont3)//"desnaturalizar"
	nColSize += 245
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[6,1],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[6,2],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[6,3],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[6,4],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[6,5],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[6,6],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[6,7],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[6,8],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[6,9],"@E 99,999,999.99"),opFont3)
	nColSize := nColIni
	nLin += 40
	oPrn:Say(nLin+015,nColSize,STR0055,opFont3)//"(inferior"
	nLin += 40
	oPrn:Say(nLin+015,nColSize,STR0056,opFont3)//"a 80%)"

	nColSize := nColIni	
	nLin += 60
	oPrn:Line(nLin,0020,nLin,2355)
	oPrn:Say(nLin+015,nColSize,STR0057,opFont3)//"7.Aguardente"
	nColSize += 245
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[7,1],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[7,2],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[7,3],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[7,4],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[7,5],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[7,6],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[7,7],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[7,8],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[7,9],"@E 99,999,999.99"),opFont3)
	nColSize := nColIni
	nLin += 40
	oPrn:Say(nLin+015,nColSize,STR0058,opFont3)//"de uvas"
	
	nColSize := nColIni
	nLin += 60
	oPrn:Line(nLin,0020,nLin,2355)
	oPrn:Say(nLin+015,nColSize,STR0059,opFont3)//"8.Whisky"
	nColSize += 245
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[8,1],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[8,2],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[8,3],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[8,4],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[8,5],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[8,6],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[8,7],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[8,8],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[8,9],"@E 99,999,999.99"),opFont3)

	nColSize := nColIni	
	nLin += 60
	oPrn:Line(nLin,0020,nLin,2355)
	oPrn:Say(nLin+015,nColSize,STR0060,opFont3)//"9.Run e demais"
	nLin += 40
	oPrn:Say(nLin+015,nColSize,STR0061,opFont3)//"aguardentes"
	nColSize += 245
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[9,1],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[9,2],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[9,3],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[9,4],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[9,5],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[9,6],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[9,7],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[9,8],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[9,9],"@E 99,999,999.99"),opFont3)
	nColSize := nColIni
	nLin += 40
	oPrn:Say(nLin+015,nColSize,STR0062,opFont3)//"de cana"
	
	nColSize := nColIni
	nLin += 60
	oPrn:Line(nLin,0020,nLin,2355)
	oPrn:Say(nLin+015,nColSize,STR0063,opFont3)//"10.Gin e"
	nColSize += 245
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[10,1],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[10,2],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[10,3],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[10,4],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[10,5],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[10,6],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[10,7],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[10,8],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[10,9],"@E 99,999,999.99"),opFont3)
	nColSize := nColIni
	nLin += 40
	oPrn:Say(nLin+015,nColSize,STR0064,opFont3)//"Ginebra"
	
	nColSize := nColIni
	nLin += 60
	oPrn:Line(nLin,0020,nLin,2355)
	oPrn:Say(nLin+015,nColSize,STR0065,opFont3)//"11.Vodka"
	nColSize += 245
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[11,1],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[11,2],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[11,3],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[11,4],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[11,5],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[11,6],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[11,7],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[11,8],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[11,9],"@E 99,999,999.99"),opFont3)
	
	nColSize := nColIni
	nLin += 60
	oPrn:Line(nLin,0020,nLin,2355)
	oPrn:Say(nLin+015,nColSize,STR0066,opFont3)//"12.Licores"
	nColSize += 245
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[12,1],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[12,2],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[12,3],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[12,4],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[12,5],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[12,6],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[12,7],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[12,8],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[12,9],"@E 99,999,999.99"),opFont3)
	
	nColSize := nColIni
	nLin += 60
	oPrn:Line(nLin,0020,nLin,2355)
	oPrn:Say(nLin+015,nColSize,STR0067,opFont3)//"13.Os Demais"
	nColSize += 245
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[13,1],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[13,2],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[13,3],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[13,4],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[13,5],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[13,6],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[13,7],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[13,8],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[13,9],"@E 99,999,999.99"),opFont3)
	
	nColSize := nColIni
	nLin += 60
	oPrn:Box(nLin,0020,nLin+60,2355)
	oPrn:Say(nLin+015,nColSize,STR0068,opFont3)//"14.Total de imposto liquidado bebidas e alcoois (Somar os campos de 1 a 13)"
	nColSize += 2085
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[14,9],"@E 99,999,999.99"),opFont3)
  
Return nLin

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ FPag2   ³ Autor ³ Ivan Haponczuk         ³ Data ³02/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que faz a impressão dos registros					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FPag1()				                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impostos			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FPag2(aDados,nLinIni)

	Local nColSize := 0
	Local nColIni  := 40
	Local nLin     := 0
	
	nColSize := nColIni
	nLin := nLinIni
	oPrn:Box(nLin,0020,nLin+355,2355)
	
	oPrn:Say(nLin+005,nColSize,"",opFont2)
	oPrn:Say(nLin+055,nColSize,STR0069,opFont2)//"II."
	oPrn:Say(nLin+105,nColSize,STR0070,opFont2)//"Cigarros"
	nColSize += 245
	
	oPrn:Line(nLin,nColSize-20,nLin+355,nColSize-20)
	oPrn:Say(nLin+005,nColSize,STR0019,opFont2)//"a) Total"
	oPrn:Say(nLin+055,nColSize,STR0020,opFont2)//"Operacoes"
	oPrn:Say(nLin+105,nColSize,STR0021,opFont2)//"gravadas"
	nColSize += 260
	
	oPrn:Line(nLin,nColSize-20,nLin+355,nColSize-20)
	oPrn:Say(nLin+005,nColSize,"",opFont2)
	oPrn:Say(nLin+055,nColSize,STR0022,opFont2)//"%"
	oPrn:Say(nLin+105,nColSize,STR0023,opFont2)//"Ajuste"
	nColSize += 140
	
	oPrn:Line(nLin,nColSize-20,nLin+355,nColSize-20)
	oPrn:Say(nLin+005,nColSize,"",opFont2)
	oPrn:Say(nLin+055,nColSize,STR0024,opFont2)//"b) Base"
	oPrn:Say(nLin+105,nColSize,STR0025,opFont2)//"imponivel"
	nColSize += 260
	
	oPrn:Line(nLin,nColSize-20,nLin+355,nColSize-20)
	oPrn:Say(nLin+005,nColSize,"",opFont2)
	oPrn:Say(nLin+055,nColSize,STR0026,opFont2)//"Taxa"
	oPrn:Say(nLin+105,nColSize,STR0022,opFont2)//"%"
	nColSize += 140
	
	oPrn:Line(nLin,nColSize-20,nLin+355,nColSize-20)
	oPrn:Say(nLin+005,nColSize,"",opFont2)
	oPrn:Say(nLin+055,nColSize,STR0027,opFont2)//"c) Imposto"
	oPrn:Say(nLin+105,nColSize,STR0028,opFont2)//"adiocional"
	nColSize += 520
	nColSize += 260
	oPrn:Line(nLin,nColSize-20,nLin+355,nColSize-20)
	oPrn:Say(nLin+005,nColSize,"",opFont2)
	oPrn:Say(nLin+055,nColSize,STR0033,opFont2)//"f) Imposto"
	oPrn:Say(nLin+105,nColSize,STR0034,opFont2)//"liquidado"
	nColSize += 260
	
	oPrn:Line(nLin,nColSize-20,nLin+355,nColSize-20)
	oPrn:Say(nLin+005,nColSize,"",opFont2)
	oPrn:Say(nLin+055,nColSize,STR0035,opFont2)//"c) Imposto"
	oPrn:Say(nLin+105,nColSize,STR0036,opFont2)//"total"

	nColSize := nColIni
	nLin += 155
	oPrn:Line(nLin,0020,nLin,2355)
	oPrn:Say(nLin+010,nColSize,STR0071,opFont3)//"15.Cigarros"
	nLin += 40
	oPrn:Say(nLin+010,nColSize,STR0072,opFont3)//"que contem"
	nColSize += 245
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[15,1],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[15,2],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[15,3],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[15,4],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[15,5],"@E 99,999,999.99"),opFont3)
	nColSize += 520
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[15,8],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[15,9],"@E 999,999,999.99"),opFont3)
	nColSize := nColIni
	nLin += 40
	oPrn:Say(nLin+010,nColSize,STR0073,opFont3)//"tabaco"

	nColSize := nColIni
	nLin += 60
	oPrn:Line(nLin,0020,nLin,2355)
	oPrn:Say(nLin+015,nColSize,STR0074,opFont3)//"16.Os Demais"
	nColSize += 245
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[16,1],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[16,2],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[16,3],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDirPer(aDados[16,4],"@E 999.99"),opFont3)
	nColSize += 140
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[16,5],"@E 99,999,999.99"),opFont3)
	nColSize += 520
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[16,8],"@E 99,999,999.99"),opFont3)
	nColSize += 260
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[16,9],"@E 99,999,999.99"),opFont3)
	
	nColSize := nColIni
	nLin += 60
	oPrn:Box(nLin,0020,nLin+60,2355)
	oPrn:Say(nLin+015,nColSize,STR0075,opFont3)//"17.Total de impostos de cigarros"
	nColSize += 2085
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[17,9],"@E 99,999,999.99"),opFont3)
  
Return nLin

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ FTotal  ³ Autor ³ Ivan Haponczuk         ³ Data ³02/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que faz a impressão dos registros					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FPag1()				                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impostos			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FTotal(aDados,nLinIni)

	Local nColSize := 0
	Local nColIni  := 40
	Local nLin     := 0
	
	nColSize := nColIni
	nLin := nLinIni
	oPrn:Box(nLin,0020,nLin+920,2355)
	
	oPrn:Say(nLin+005,nColSize,STR0076,opFont2)//"IV. Otros Bens"
	nLin+=40
	oPrn:Say(nLin+005,nColSize,STR0077,opFont2)//"18. Otros Bens (ver o anexo ISC-02-A da declaracao jurada do imposto seletivo ao consumo)"
	nColSize += 2085
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[18,9],"@E 99,999,999.99"),opFont3)	
	nColSize := nColIni
	nLin+=40
	oPrn:Say(nLin+005,nColSize,STR0078,opFont2)//"V. Liquidacao"
	nColSize += 2085
	
	nColSize := nColIni
	nLin += 60
	oPrn:Box(nLin,0020,nLin+60,2355)
	oPrn:Say(nLin+015,nColSize,STR0079,opFont3)//"19.Total impuesto liquidado(somar os campos 14+17+18)"
	nColSize += 2085
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[19,9],"@E 99,999,999.99"),opFont3)
	
	nColSize := nColIni
	nLin += 60
	oPrn:Box(nLin,0020,nLin+60,2355)
	oPrn:Say(nLin+015,nColSize,STR0080,opFont3)//"20.Adiantamentos de materias primas e insumos em importacoes"
	nColSize += 2085
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[20,9],"@E 99,999,999.99"),opFont3)
	
	nColSize := nColIni
	nLin += 60
	oPrn:Box(nLin,0020,nLin+60,2355)
	oPrn:Say(nLin+015,nColSize,STR0081,opFont3)//"21.Adiantamentos de materias primas e insumos em compras locais"
	nColSize += 2085
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[21,9],"@E 99,999,999.99"),opFont3)
	
	nColSize := nColIni
	nLin += 60
	oPrn:Box(nLin,0020,nLin+60,2355)
	oPrn:Say(nLin+015,nColSize,STR0082,opFont3)//"22.Imposto a pagar(se o valor dos campos 19-20-21 for positivo)"
	nColSize += 2085
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[22,9],"@E 99,999,999.99"),opFont3)
	
	nColSize := nColIni
	nLin += 60
	oPrn:Box(nLin,0020,nLin+60,2355)
	oPrn:Say(nLin+015,nColSize,STR0083,opFont3)//"23.Saldo a favor(se o valor dos campos 19-20-21 for negativo)"
	nColSize += 2085
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[23,9],"@E 99,999,999.99"),opFont3)
	
	nColSize := nColIni
	nLin += 60
	oPrn:Box(nLin,0020,nLin+60,2355)
	oPrn:Say(nLin+015,nColSize,STR0084,opFont3)//"24.Saldos compensaveis autorizados"
	nColSize += 2085
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[24,9],"@E 99,999,999.99"),opFont3)
	
	nColSize := nColIni
	nLin += 60
	oPrn:Box(nLin,0020,nLin+60,2355)
	oPrn:Say(nLin+015,nColSize,STR0085,opFont3)//"25.Saldo a favor anterior"
	nColSize += 2085
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[25,9],"@E 99,999,999.99"),opFont3)
	
	nColSize := nColIni
	nLin += 60
	oPrn:Box(nLin,0020,nLin+60,2355)
	oPrn:Say(nLin+015,nColSize,STR0086,opFont3)//"26.Pagamentos computaveis em conta"
	nColSize += 2085
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[26,9],"@E 99,999,999.99"),opFont3)
	
	nColSize := nColIni
	nLin += 60
	oPrn:Box(nLin,0020,nLin+60,2355)
	oPrn:Say(nLin+015,nColSize,STR0087,opFont3)//"27.Diferenca a pagar(se o valor dos campos 22-24-25-26 for positivo)"
	nColSize += 2085
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[27,9],"@E 99,999,999.99"),opFont3)
	
	nColSize := nColIni
	nLin += 60
	oPrn:Box(nLin,0020,nLin+60,2355)
	oPrn:Say(nLin+015,nColSize,STR0088,opFont3)//"28.Novo saldo a favor(se o valor dos campos 22-24-25-26 for negativo)"
	nColSize += 2085
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[28,9],"@E 99,999,999.99"),opFont3)
	
	nColSize := nColIni
	nLin += 60
	oPrn:Box(nLin,0020,nLin+60,2355)
	oPrn:Say(nLin+015,nColSize,STR0089,opFont3)//"29.Encargos"
	nColSize += 2085
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[29,9],"@E 99,999,999.99"),opFont3)
	
	nColSize := nColIni
	nLin += 60
	oPrn:Box(nLin,0020,nLin+60,2355)
	oPrn:Say(nLin+015,nColSize,STR0090,opFont3)//"30.Multas indenizatorias"
	nColSize += 2085
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[30,9],"@E 99,999,999.99"),opFont3)
	
	nColSize := nColIni
	nLin += 60
	oPrn:Box(nLin,0020,nLin+60,2355)
	oPrn:Say(nLin+015,nColSize,STR0091,opFont3)//"31.Sanções"
	nColSize += 2085
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[31,9],"@E 99,999,999.99"),opFont3)
	
	nColSize := nColIni
	nLin += 60
	oPrn:Box(nLin,0020,nLin+60,2355)
	oPrn:Say(nLin+015,nColSize,STR0092,opFont3)//"32.Total a pagar(somar 27+29+30+31)"
	nColSize += 2085
	oPrn:Say(nLin+10,nColSize,AliDir(aDados[32,9],"@E 99,999,999.99"),opFont3)
  
Return nLin

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    AliDir()³ Autor ³ Ivan Haponczuk          ³  Data ³02/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que faz a impressão dos registros					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AliDir(nVlr,cPicture)	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nVlr: valor a ser alinhado  cPicture: picture do valor     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet: valor alinhado a direita							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impostos			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AliDir(nVlr,cPicture)
	Local cRet:=""
	
	If Len(Alltrim(Str(Int(nVlr))))==9                    
		cRet:=PADL(" ",0," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==8                    
		cRet:=PADL(" ",0," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==7                    
		cRet:=PADL(" ",2," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==6                    
		cRet:=PADL(" ",4," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==5                     
		cRet:=PADL(" ",6," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==4                       
		cRet:=PADL(" ",8," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==3                    
		cRet:=PADL(" ",10," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==2               
		cRet:=PADL(" ",12," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==1         
		cRet:=PADL(" ",14," ")+alltrim(Transform(nVlr,cPicture))
	Endif 
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    AliDirPer³ Autor ³ Ivan Haponczuk         ³  Data ³02/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que faz a impressão dos registros					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AliDir(nVlr,cPicture)	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nVlr: valor a ser alinhado  cPicture: picture do valor     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet: valor alinhado a direita							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impostos			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AliDirPer(nVlr,cPicture)
	Local cRet:=""
	
	If Len(Alltrim(Str(Int(nVlr))))==3                    
		cRet:=PADL(" ",0," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==2               
		cRet:=PADL(" ",2," ")+alltrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr))))==1         
		cRet:=PADL(" ",4," ")+alltrim(Transform(nVlr,cPicture))
	Endif 
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CriarArq  ³ Autor ³ Ivan Haponczuk        ³ Data ³02/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o arquivo TXT com os valores que constam na getdados  ³±±
±±³          ³ e no array do Titulo                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CriarArq 		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum								  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum										              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TXT  				                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriarArq(cDir,cArq,aDados,aTitulos)
	Local nHdl		:= 0
	Local nlX	:= 0
	Local nlY   := 0
	Local cLinha	:= ""
	
	nHdl := fCreate(cDir+cArq+".isc2")
	If nHdl <= 0
		ApMsgStop(STR0093)//"Ocorreu um erro ao criar o arquivo"
	Endif  
	
	For nlX := 1 to Len(aDados)
		cLinha := "IMP;"+AllTrim(Str(nlX))
		For nlY := 1 To Len(aDados[nlX])
			cLinha += ";"
			cLinha += AllTrim(Str(aDados[nlX][nlY]))
		Next nlY
		cLinha += chr(13)+chr(10)
		fWrite(nHdl,cLinha)
	Next nlX
	
	If Len(aTitulos) > 0
		cLinha := "TIT"
		For nlX := 1 to Len(aTitulos)
			cLinha += ";"
			If ValType(aTitulos[nlX]) == "N"
				cLinha += AllTrim(Str(aTitulos[nlX]))
			Else
				cLinha += AllTrim(aTitulos[nlX])
			EndIf
		Next nlX
		cLinha += chr(13)+chr(10)
		fWrite(nHdl,cLinha)
	EndIf
	
	If nHdl > 0
		fClose(nHdl)
	Endif
Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    FMApur   ³ Autor ³ Ivan Haponczuk          ³ Data ³02/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função que faz a leitura do TXT para mostrar o Relatorio   ³±±
±±³ 		 | de Conferencia					     	    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FMApur(cNomArq)		                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impostos			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FMApur(cDir,cNomArq)
 
 	Local cLinha := ""
	Local aDados := {}

	IF FT_FUSE(cpDir+cNomArq+".isc2") <> -1
		FT_FGOTOP()
		Do While !FT_FEOF()
			cLinha := FT_FREADLN()
			If SubStr(cLinha,1,4) == "IMP;"
				cLinha := SubStr(cLinha,5,Len(cLinha))
				aAdd(aDados,Separa(cLinha,";"))
			EndIf
			FT_FSKIP()
		EndDo
		FT_FUSE()
	EndIF
	
Return aDados