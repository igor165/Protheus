#INCLUDE "HSPAHRB8.ch"
#include "TopConn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHRB8  º Autor ³ Cibele L. Peria    º Data ³  20/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Solicitacoes de Prontuario                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPAHRB8()
 
 Local cDesc1   := STR0001 //"Este programa tem como objetivo imprimir relatório "
 Local cDesc2   := STR0002 //"de acordo com os parâmetros informados pelo usuário."
 Local cDesc3   := STR0003 //"Relatório de Solicitação de Prontuários"
 Local cPict    := ""
 Local imprime  := .T.
 Local aOrd     := {STR0022, STR0023, STR0024, STR0025,; //"Paciente"###"Médico"###"Usuário"###"Motivo da Solicitação"
                     STR0026, STR0027, STR0028, STR0029} //"Data da Solicitação"###"Data da Saída"###"Data do Retorno"###"Prontuário"
 
 Private Titulo      := STR0004 //"R e l a t ó r i o   d e   S o l i c i t a ç ã o   d e   P r o n t u á r i o s"
 Private Cabec1      := "" 
 Private Cabec2      := ""
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 80
 Private tamanho     := "G"
 Private NomeProg    := "HSPAHRB8" /* Coloque aqui o nome do programa para impressao no cabecalho */
 Private nTipo       := 18
 Private aReturn     := {STR0006, 1, STR0007, 2, 2, 1, "", 1}  //"Zebrado"###"Administração"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := "HSPAHRB8" /* Coloque aqui o nome do arquivo usado para impressao em disco */
 Private nOK		       := 0
 Private dDatSol_De	 := ""
 Private dDatSol_Ate	:= ""
 Private cHorSol_De  := ""
 Private cHorSol_Ate := ""
 Private cCodLoc_De	 := ""
 Private cCodLoc_Ate	:= ""
 Private cCodEnd_De  := ""
 Private cCodEnd_Ate := ""
 Private cCRM_De 	   := ""
 Private cCRM_Ate	   := ""
 Private nTipoSolic  := 0
 Private cTipoSolic  := ""
 Private nDias       := ""
 Private nTipEnd 	   := 0
 Private nOrdem      := 0
 Private cCODIMP     := ""
 Private nMaxLin     := 0 // quantidade maxima de linhas p/ impressao
 Private cAliasSP    := "GSA" //Alias do SetPrint
 If !Pergunte("HSPRB8", .T.)
 	Return()
 EndIf

 nMaxLin := HS_MaxLin(cCODIMP)

 nOK		       := MV_PAR01
 dDatSol_De	 := MV_PAR02
 dDatSol_Ate	:= MV_PAR03
 cCodLoc_De	 := MV_PAR04
 cCodLoc_Ate	:= MV_PAR05
 cCodEnd_De  := MV_PAR06
 cCodEnd_Ate := MV_PAR07
 cCodCRM_De  := MV_PAR08
 cCodCRM_Ate := MV_PAR09
 cHorSol_De  := MV_PAR10
 cHorSol_Ate := MV_PAR11
 nTipEnd 	   := MV_PAR12
 nTipoSolic  := MV_PAR13 
 nDias       := MV_PAR14

 wnrel := SetPrint(cAliasSP, NomeProg, "", @titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho,, .T.)
 If nLastKey == 27
	 Return()
 EndIf

 nOrdem := aReturn[8]

 SetDefault(aReturn, "GSA")
 If nLastKey == 27
	 Return()
 EndIf

 nTipo := If(aReturn[4] == 1, 15, 18)
 RptStatus({|| RunReport()}, Titulo)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºDescri‡„o ³ Execucao do relatorio.                                     º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunReport()
 Local   cSQL       := ""
 Local   cCodLoc    := ""
 Local   cOK        := ""
 Local   nTotSta    := 0
 Local   nTotSet    := 0
 Local   dDatAtra   := "" //armazena a data a partir da qual sera considerado atraso
 Local   nDiaAtra   := "" //armazena a qtde de dias de atraso
 Local   nMem       := 0
 Local   nCount     := 0
 Local   cFilUsu    := HS_FilUsu("GSA")
 Local   cCpoGsa    := HS_RetCpos("GSA",.T.,".")
 
 Local   cSelect    := {}
 Local   cFrom      := {}
 Local   cWhere     := {}

 Private nTotCha    := 0
 Private nLin       := nMaxLin * 2        
 
 cSelect := "SELECT "+cCpoGsa+", GSA.R_E_C_N_O_ GSA_RECNO, GSC.GSC_DESMOT, GA7.GA7_DESC, GSD.GSD_TIPEND, "//GSA.GSA_REGGER, 
 cFrom   := "FROM " + RetSQLName("GSA") + " GSA "
 cFrom   += "JOIN " + RetSQLName("GSC") + " GSC ON GSC.GSC_FILIAL = '" + xFilial("GSC") + "' AND GSC.GSC_CODMOT = GSA.GSA_CODMOT AND GSC.D_E_L_E_T_ <> '*' "
 cFrom   += "JOIN " + RetSQLName("GSD") + " GSD ON GSD.GSD_FILIAL = '" + xFilial("GSD") + "' AND GSD.GSD_CODEND = GSA.GSA_CODEND AND GSD.D_E_L_E_T_ <> '*' "
 cFrom   += "LEFT JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.GA7_CODPRO = GSA.GSA_CODPRO AND GA7.D_E_L_E_T_ <> '*' "
 
 cWhere := "WHERE GSA.GSA_FILIAL = '" + xFilial("GSA") + "' "
 If nOK <> 5
 	cWhere += "AND GSA.GSA_OK = '" + IIF(nOK == 1, " ", IIF(nOK == 2, "0", IIF(nOK == 3, "1", "2"))) + "' "
 EndIf
	cWhere += " AND GSA.D_E_L_E_T_ <> '*' "
 cWhere += IIF(nTipoSolic # 4," AND GSA.GSA_ORISOL = '"+AllTrim(str(nTipoSolic-1))+"' ","")

 If nOk == 2
	dDatAtra := Ddatabase - nDias
	cWhere += "AND GSA.GSA_DATENT < '" + DTOS(dDatAtra) + "' "
 EndIf

 If !Empty(dDatSol_De) .Or. !Empty(dDatSol_Ate)
 	cWhere += "AND GSA.GSA_DATSOL BETWEEN '" + DTOS(dDatSol_De) + "' AND '" + DTOS(dDatSol_Ate) + "' "
 EndIf
 If !Empty( subs(cHorSol_De,1,2) + SUBS(cHorSol_De, 4, 2) ) .Or. !Empty( SUBS(cHorSol_Ate, 1, 2) + SUBS(cHorSol_Ate, 4, 2))
 	cWhere += "AND GSA.GSA_HORSOL BETWEEN '" + cHorSol_De + "' AND '" + cHorSol_Ate + "' "
 EndIf
 If !Empty(cCodLoc_De) .Or. !Empty(cCodLoc_Ate)
 	cWhere += "AND GSA.GSA_CODLOC BETWEEN '" + cCodLoc_De + "' AND '" + cCodLoc_Ate + "' "
 EndIf
 If !Empty(cCodEnd_De) .Or. !Empty(cCodEnd_Ate)
 	cWHere += "AND GSA.GSA_CODEND BETWEEN '" + cCodEnd_De + "' AND '" + cCodEnd_Ate + "' "
 EndIf
 If !Empty(cCodCRM_De) .Or. !Empty(cCodCRM_Ate)
 	cWHere += "AND GSA.GSA_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "' "
 EndIf

 If nTipEnd <> 4
 	cWHere += "AND GSD.GSD_TIPEND = '" + STR(nTipEnd, 1) +  "' "
 Endif  

 //Montagem do Comando
 cSQL := cSelect + "SRA.RA_NOME RA_NOME "
 cSQL += cFrom
 cSQL += "JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.RA_CODIGO = GSA.GSA_CODCRM AND SRA.D_E_L_E_T_ <> '*' "
 cSQL += cWhere
	cSQL += " AND GSA.GSA_CODCRM <> '" + Space(Len(GSA->GSA_CODCRM)) + "' "
	If Empty(cCodCRM_De) .Or. Empty(cCodCRM_Ate)
 	cSQL += " UNION ALL "
  cSQL += cSelect + "'" + Space(Len(SRA->RA_NOME)) + "' RA_NOME "
  cSQL += cFrom
  cSQL += cWhere
 	cSQL += " AND GSA.GSA_CODCRM = '" + Space(Len(GSA->GSA_CODCRM)) + "' "
 Endif	
	
 If nOrdem == 1
 	cSQL += "ORDER BY GSA_OK, GSA_CODLOC, GSA_NOMPAC"    //Paciente
 ElseIf nOrdem == 2
 	cSQL += "ORDER BY GSA_OK, GSA_CODLOC, RA_NOME"       //Medico
 ElseIf nOrdem == 3
 	cSQL += "ORDER BY GSA_OK, GSA_CODLOC, GSA_NOMSOL"    //Usuario
 ElseIf nOrdem == 4
 	cSQL += "ORDER BY GSA_OK, GSA_CODLOC, GSC_DESMOT"    //Motivo da solicitacao
 ElseIf nOrdem == 5
 	cSQL += "ORDER BY GSA_OK, GSA_CODLOC, GSA_DATSOL"    //Data da solicitacao
 ElseIf nOrdem == 6
 	cSQL += "ORDER BY GSA_OK, GSA_CODLOC, GSA_DATENT"    //Data da saida (entrega)
 ElseIf nOrdem == 7
 	cSQL += "ORDER BY GSA_OK, GSA_CODLOC, GSA_DATRET"    //Data do Retorno
 ElseIf nOrdem == 8
 	cSQL += "ORDER BY GSA_OK, GSA_CODLOC, GSA_REGGER"    //Prontuario
 EndIf
 
 cSQL += IIF( at('ORDER BY', cSQL) > 0 , ", GSA_ORISOL", "ORDER BY GSA_ORISOL")
 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"

 DbSelectArea("QRY")
 DbGoTop()
 If Eof()
 	HS_MsgInf(STR0009, STR0018, STR0019) //"Nao há dados a serem impressos para a seleão efetuada!"###"Atenção"###"Verifique a seleção"
 	dbCloseArea()
 	Return(Nil)
 EndIf

 SetRegua(1000)
 
 While !EOF() .And. !(&cFilUsu)
	 DbSkip()
	End 
 
 While !Eof()

  If lAbortPrint
	  @nLin, 000 PSAY STR0008 //"*** CANCELADO PELO OPERADOR ***"
	  Exit
  EndIf                            
 
	 If QRY->GSA_OK == " "
	 	cDescOk := STR0013 //"Não Atendida(s)"
	 ElseIf QRY->GSA_OK == "0"
	 	cDescOk := STR0014 //"Atendida(s) e Não Retornada(s)"
	 ElseIf QRY->GSA_OK == "1"
	 	cDescOk := STR0015 //"Atendida(s) e Retornada(s)"
	 ElseIf QRY->GSA_OK == "2"
	 	cDescOk := STR0016 //"Encerrada(s)"
	 Else
	 	cDescOk := "........................."
	 EndIf
	
	 If nLin + 4 > nMaxLin
	 	FS_Cabec()
	 EndIf
	
	 nLin++
	 @nLin, 000 PSAY STR0017 + cDescOk  //"STATUS DA SOLICITAÇÃO : "
	 nLin++
	 @nLin, 000 PSAY "------ -- -----------"
	 nLin++
	
 	cOK := QRY->GSA_OK
 	While !Eof() .And. QRY->GSA_OK == cOK

 		cCodLoc := QRY->GSA_CODLOC
 		While !Eof() .And. QRY->GSA_OK == cOK .And. QRY->GSA_CODLOC == cCodLoc
 		
 			If nLin+2 > nMaxLin
 				FS_Cabec()
 			EndIf
 			
 			nLin += 1       
  		@nLin, 000 PSAY QRY->GSA_CODSOL	
 			@nLin, 008 PSAY IIF(Empty(QRY->GSA_DATSOL), " ", HS_DTOC(STOD(QRY->GSA_DATSOL), 1))
 			@nLin, 018 PSAY QRY->GSA_HORSOL
 			@nLin, 025 PSAY QRY->GSA_REGGER + "-" + SUBSTR(QRY->GSA_NOMPAC, 1, 25)
 			@nLin, 059 PSAY SUBSTR(HS_RDESCRB("GSD_TIPEND", GSD->GSD_TIPEND), 1, 11)
  		@nLin, 072 PSAY QRY->GSA_CODEND
 			@nLin, 086 PSAY SUBSTR(HS_INIPADR("GCS", 1, QRY->GSA_CODLOC, "GCS_NOMLOC"), 1, 20)
 			@nLin, 108 PSAY SUBSTR(QRY->RA_NOME, 1, 22)
    @nLin, 132 PSAY SUBSTR(QRY->GA7_DESC, 1, 33)			
    @nLin, 167 PSAY SUBSTR(QRY->GSA_NOMSOL, 1, 12)
    @nLin, 181 PSAY QRY->GSA_LOTE
    @nLin, 192 PSAY IIF(Empty(QRY->GSA_DATENT), " ", HS_DTOC(STOD(QRY->GSA_DATENT), 1))
    @nLin, 202 PSAY QRY->GSA_HORENT
    @nLin, 209 PSAY SUBSTR(QRY->GSA_NOMENT, 1, 11)
    nLin++     
    
    If nOk == 2	
   			@nLin, 025 PSAY TRANSFORM(nDiaAtra := (Date()) - STOD(QRY->GSA_DATENT), "@E 9,999") 
 		 EndIf      
    
    If(QRY->GSA_ORISOL == "0")
     cTipoSolic := STR0032
    ElseIf(QRY->GSA_ORISOL == "1")
     cTipoSolic := STR0033
    Else
     cTipoSolic := STR0034
    EndIf  
    
    @nLin, 008 PSAY cTipoSolic 
    @nLin, 059 PSAY SUBSTR(QRY->GSC_DESMOT, 1, 25)    
    @nLin, 086 PSAY SUBSTR(QRY->GSA_OBSERV, 1, 44)   
      
    GSA->(DbGoTo(QRY->GSA_RECNO)	)
    
    If !Empty(GSA->GSA_MOTIVO)
     nCount := MlCount(AllTrim(GSA->GSA_MOTIVO))   
 	   @nLin, 132 PSAY SUBSTR(MemoLine(GSA->GSA_MOTIVO,, 1), 1, 59)	   
 	 		@nLin, 192 PSAY IIF(Empty(QRY->GSA_DATCAN), " ", HS_DTOC(STOD(QRY->GSA_DATCAN), 1))
    	@nLin, 202 PSAY QRY->GSA_HORCAN
    	@nLin, 209 PSAY SUBSTR(QRY->GSA_NOMCAN, 1, 11)
 	  Else
 	   @nLin, 132 PSAY " "
 	 		@nLin, 192 PSAY IIF(Empty(QRY->GSA_DATRET), " ", HS_DTOC(STOD(QRY->GSA_DATRET), 1))
    	@nLin, 202 PSAY QRY->GSA_HORRET
    	@nLin, 209 PSAY SUBSTR(QRY->GSA_NOMRET, 1, 11)
 	  EndIf 
    
    If nCount > 1
     nLin++
     For nMem := 2 To nCount
      @nLin, 132 PSAY SUBSTR(MemoLine(GSA->GSA_MOTIVO,, nMem), 1, 59)
 		   nLin++
 		  Next
 	   
 	  EndIf
     
   	nTotCha++
 			nTotSta++
 			nTotSet++
 			
 			DbSelectArea("QRY")
 			DbSkip()
		  While !Eof() .And. !(&cFilUsu)
  	  DbSkip()
	   End
 			
 		EndDo
 		
 		nLin++
 		FS_Total(STR0011 + SUBSTR(HS_INIPADR("GCS", 1, cCodLoc, "GCS_NOMLOC"), 1, 28)+" : ", nTotSet) //"===> Total do Setor "
 		nTotSet := 0
 		
 	EndDo
 	
 	If nLin + 4 > nMaxLin
 		FS_Cabec()
 	EndIf
 	
 	FS_Total(STR0012 + cDescOk + ": ", nTotSta)  //"===> T O T A L   de    "
 	nLin++
 	@nLin, 000 PSAY Replicate("_", 228)
 	nLin++
 	nTotSta := 0
 	
 EndDo
 
 SET DEVICE TO SCREEN
 If aReturn[5] == 1
 	dbCommitAll()
 	SET PRINTER TO
 	OurSpool(wnrel)
 EndIf
 MS_FLUSH()
 
 DbSelectArea("QRY")
 DbCloseArea()
Return()

Static Function FS_Cabec()   
 Cabec1 := STR0021 //"Solicitacao              Paciente                          Tipo Ender.  Endereco      Setor                 Medico                  Procedimento                       Solicitante   Protocolo  Saida            Usuario"

 If nOk == 2
 	Cabec2 := STR0020	//"                         Qtde. de Dias                     Motivo da Solicit.         Obs. Solicitação                             	Obs. Encerramento                                           Retorno          Usuário"
 Else              	
 	Cabec2 := STR0005	//"        Origem Solicitação                                   Motivo da Solicit.         Obs. Solicitação                              Obs. Encerramento                                           Retorno          Usuário"
 EndIf

 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
 nLin := 8

 If nTotCha > 1
 	nLin += 1
 	@nLin, 000 PSAY STR0010 //"Continuação..."
 EndIf  

Return()

Static Function FS_Total(cTitulo, nTotal)

 If nLin + 2 > nMaxLin
 	FS_Cabec()
 EndIf

 nLin++
 @nLin, 007 PSAY cTitulo + AllTrim(STR(nTotal, 6, 0))
 nLin++
 
Return()
