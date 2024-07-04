#INCLUDE "HSPAHC02.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TopConn.ch"
#define ESC          27
#define TRACE        repl("_",131)
#define TRACEDUPLO   repl("=",131)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHC02  บ Autor ณ MARCELO JOSE       บ Data ณ  23/07/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RESUMO DE ATENDIMENTO                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHC02()
 // Declaracao de Variaveis
 Local nCtaFor  := 1 , nPosVet := 0

 PRIVATE aCusto   := {}, aEspec     := {}, aMedico := {}, aConve := {}
 PRIVATE nPosHora :=  0, nSomatorio :=  0, cCrm := ""
 PRIVATE aTotCus  := {}, aTotEsp    := {}, aTotMed := {}, aTotCon := {}
 PRIVATE nTotalAa :=  0, nTotalCc   :=  0
 Private aEstru   := {}

 Private cDesc1       := "Este programa tem como objetivo imprimir relatorio "
 Private cDesc2       := "de acordo com os parametros informados pelo usuario."
 Private cDesc3       := STR0003
 Private cPict        := ""
 Private titulo       := STR0003
 Private nLin         := 80
 Private Cabec1       := STR0021
 Private Cabec2       := STR0022
 Private imprime      := .T.
 Private aOrd         := {}

 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private limite       := 132
 Private tamanho      := "M"
 Private nomeprog     := "HSPAHC02" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo        := 15
 Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
 Private nLastKey     := 0
 Private cbtxt        := Space(10)
 Private cbcont       := 00
 Private CONTFL       := 01
 Private m_pag        := 01
 Private wnrel        := "HSPAHC02" // Coloque aqui o nome do arquivo usado para impressao em disco
 Private cString      := "GCY"

 Private cPerg        := "HSPC02"
 
 Private nPer1_das    := 0
 Private nPer1_aas    := 0
 Private nPer2_das    := 0 
 Private nPer2_aas    := 0 
 Private nPer3_das    := 0 
 Private nPer3_aas    := 0 

 PRIVATE cLinOk       := "AllwaysTrue()"
 PRIVATE cTudOk       := "AllwaysTrue()"
 PRIVATE cFieldOk     := "AllwaysTrue()"
 PRIVATE nOpca        := 0

 Private nP_cCodigo := 0, nP_cDescri := 0, nP_nAtenP1 := 0, nP_nCancP1 := 0, nP_nAtenP2 := 0
 Private nP_nCancP2 := 0, nP_nAtenP3 := 0, nP_nCancP3 := 0, nP_nAtenTo := 0, nP_nCancTo := 0
 
 Private oGDCusto, oGDEspec, oGDMedic, oGDConve, oBtnPar, oFolder, oDlg

 Define  FONT oFont NAME "Arial,14," BOLD
 
 FS_IniX1()     // verifica perguntas
 
 If Pergunte(cPerg,.T.)
 	Processa({|| FS_MCons()})
 Else
  Return(Nil)
 EndIf
 
 FS_MontaTel()  // chama formulario
 
Return(Nil)           
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Funcao   ณ MCons()  บ Autor ณ MARCELO JOSE       บ Data ณ  23/07/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que monta as matrizes                               บฑฑ
ฑฑบ          ณ Nil  FS_MCons(Nil)                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_MCons()

 Local cAliasQRY := "C02QRY"
 Local bWhile     := {||!Eof()}

 aCusto    := {}; aEspec     := {}; aMedico := {}; aConve := {}
 nPosHora  := 0 ; nSomatorio := 0 ; cCrm    := ""
 aTotCus   := {}; aTotEsp    := {}; aTotMed := {}; aTotCon := {}
 nTotalAa  := 0 ; nTotalCc   := 0
 nCtaFor   := 1 ; nPosVet    := 0
 aEstru    := {}
 
 Cabec2    := "        de: "+dtoc(mv_par07)+" ate: "+DTOC(mv_par08)+ repl(" ",17)+mv_par01+"-"+mv_par02+"    "+mv_par03+"-"+mv_par04+"    "+mv_par05+"-"+mv_par06

 nPer1_das := StrTran(mv_par01, ":", "")
 nPer1_aas := StrTran(mv_par02, ":", "")
 nPer2_das := StrTran(mv_par03, ":", "")
 nPer2_aas := StrTran(mv_par04, ":", "")
 nPer3_das := StrTran(mv_par05, ":", "")
 nPer3_aas := StrTran(mv_par06, ":", "")
 
 aAdd(aEstru,{"codigo"    ,"cCodigo", "@A"       ,  9,0,,,"C",,,,,})
 aAdd(aEstru,{"Descricao" ,"cDescri", "@A"       , 40,0,,,"C",,,,,})
 aAdd(aEstru,{"Aten."     ,"nAtenP1", "@E 999999", 10,0,,,"N",,,,,})
 aAdd(aEstru,{"Canc."     ,"nCancP1", "@E 999999", 10,0,,,"N",,,,,})
 aAdd(aEstru,{"Aten."     ,"nAtenP2", "@E 999999", 10,0,,,"N",,,,,})
 aAdd(aEstru,{"Canc."     ,"nCancP2", "@E 999999", 10,0,,,"N",,,,,})
 aAdd(aEstru,{"Aten."     ,"nAtenP3", "@E 999999", 10,0,,,"N",,,,,})
 aAdd(aEstru,{"Canc."     ,"nCancP3", "@E 999999", 10,0,,,"N",,,,,})
 aAdd(aEstru,{"Total-Aten","nAtenTo", "@E 999999", 10,0,,,"N",,,,,})
 aAdd(aEstru,{"Total-Canc","nCancTo", "@E 999999", 10,0,,,"N",,,,,})
 aAdd(aEstru,{" "         ,"cBranco", "@!"       , 01,0,,,"N",,,,,})

 nP_cCodigo := aScan(aEstru, { | aVet | aVet[2] == "cCodigo"})
 nP_cDescri := aScan(aEstru, { | aVet | aVet[2] == "cDescri"})
 nP_nAtenP1 := aScan(aEstru, { | aVet | aVet[2] == "nAtenP1"})
 nP_nCancP1 := aScan(aEstru, { | aVet | aVet[2] == "nCancP1"})
 nP_nAtenP2 := aScan(aEstru, { | aVet | aVet[2] == "nAtenP2"})
 nP_nCancP2 := aScan(aEstru, { | aVet | aVet[2] == "nCancP2"})
 nP_nAtenP3 := aScan(aEstru, { | aVet | aVet[2] == "nAtenP3"})
 nP_nCancP3 := aScan(aEstru, { | aVet | aVet[2] == "nCancP3"})
 nP_nAtenTo := aScan(aEstru, { | aVet | aVet[2] == "nAtenTo"})
 nP_nCancTo := aScan(aEstru, { | aVet | aVet[2] == "nCancTo"})
 //=================== INICIO DA MONTAGEM  DAS MATRIZES  =======================
 aadd(aTotCus,{"","",0,0,0,0,0,0,0,0,0,.f.})
 aadd(aTotEsp,{"","",0,0,0,0,0,0,0,0,0,.f.})
 aadd(aTotMed,{"","",0,0,0,0,0,0,0,0,0,.f.})
 aadd(aTotCon,{"","",0,0,0,0,0,0,0,0,0,.f.})
 ProcRegua(RecCount())
 //===================================== LOOP CENTRAL ===========================
	#IFDEF TOP
	 If TCSrvType() <> "AS/400"
 	 cQuery := "SELECT "
 	 cQuery += "GCY.GCY_REGATE GCY_REGATE, "
 	 cQuery += "GCY.GCY_DATATE GCY_DATATE, "
 	 cQuery += "GCY.GCY_HORATE GCY_HORATE, "
 	 cQuery += "GCY.GCY_CODCRM GCY_CODCRM, "
 	 cQuery += "GCY.GCY_CODLOC GCY_CODLOC, "
 	 cQuery += "GCY.GCY_CODCLI GCY_CODCLI, "
 	 cQuery += "GCY.GCY_TPALTA GCY_TPALTA, "
 	 cQuery += "GCZ.GCZ_CODCON GCZ_CODCON "
 	 cQuery += "FROM " + RetSqlName("GCY") + " GCY " 
 	 cQuery += "JOIN " + RetSqlName("GCZ") + " GCZ ON (GCZ.GCZ_REGATE = GCY.GCY_REGATE AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_FILIAL = '" + xFilial( "GCZ" ) + "') " 
 	 cQuery += "WHERE "
 	 cQuery += "GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_FILIAL = '" + xFilial( "GCY" ) + "' " 

   If !Empty(MV_PAR07) .Or. !Empty(MV_PAR08)
    cQuery += "AND GCY.GCY_DATATE BETWEEN '" + DTOS(MV_PAR07) + "' AND '" + DTOS(MV_PAR08) + "' "
	  EndIf
   If !Empty(MV_PAR09) .Or. !Empty(MV_PAR10) 
    cQuery += "AND GCY.GCY_CODLOC BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
	 	EndIf
   If !Empty(MV_PAR11) .Or. !Empty(MV_PAR12) 
    cQuery += "AND GCY.GCY_CODCLI BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
	 	EndIf
   If !Empty(MV_PAR13) .Or. !Empty(MV_PAR14) 
    cQuery += "AND GCY.GCY_CODCRM BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR14 + "' "
	 	EndIf
   If !Empty(MV_PAR15) .Or. !Empty(MV_PAR16) 
    cQuery += "AND GCZ.GCZ_CODCON BETWEEN '" + MV_PAR15 + "' AND '" + MV_PAR16 + "' "
	 	EndIf
	 	If MV_PAR17 <> 5                                              
	 	 If MV_PAR17 = 4 
 	 	 cQuery += "AND GCY.GCY_ATENDI IN ('1','2')"
 	 	Else
  	  cQuery += "AND GCY.GCY_ATENDI = '" + ALLTRIM(STR(MV_PAR17 - 1)) + "' "
  	 EndIf
 	 EndIf
   cQuery += "ORDER BY 2"
	  cQuery := ChangeQuery(cQuery)
	  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
  EndIf
 #ENDIF 

 DbSelectArea(cAliasQRY)
 /**************************************** inicia o loop para impressao dos dados */
	While (cAliasQRY)->(Eval(bWhile))

  IncProc("Aguarde, processando dados")

	 nPosHora := FS_PegaH(StrTran((cAliasQRY)->GCY_HORATE, ":", ""), (cAliasQRY)->GCY_TPALTA)
  If nPosHora == 11 
   DbSkip()
		 Loop
	 endif
	
	 // alimenta matriz de centro de custo
	 nPosVet := aScan(aCusto, {| aVetTmp | aVetTmp[1] == (cAliasQRY)->GCY_CODLOC})
	 If nPosVet == 0
 		aAdd(aCusto, {(cAliasQRY)->GCY_CODLOC, POSICIONE("GCS", 1, xFilial("GCS")+(cAliasQRY)->GCY_CODLOC, "GCS_NOMLOC"), 0, 0, 0, 0, 0, 0, 0, 0, 0, .F.})
 		nPosVet := Len(aCusto)
	 Endif
	
	 aCusto [nPosVet, nPosHora] += 1
	 aTotCus[      1, nPosHora] += 1
	 
	 If (cAliasQRY)->GCY_TPALTA == "99"
	 	aCusto [nPosVet, nP_nCancTo] += 1
	 	aTotCus[      1, nP_nCancTo] += 1
	 Else
	 	aCusto [nPosVet, nP_nAtenTo] += 1
	 	aTotCus[      1, nP_nAtenTo] += 1
	 Endif
	 
	 // alimenta matriz de medicos
	 nPosVet := aScan(aMedico, {| aVetTmp | aVetTmp[1] == (cAliasQRY)->GCY_CODCRM})
	 If nPosVet == 0
	 	aAdd(aMedico, {(cAliasQRY)->GCY_CODCRM, Posicione("SRA", 11, xFilial("SRA") + (cAliasQRY)->GCY_CODCRM, "RA_NOME"), 0, 0, 0, 0, 0, 0, 0, 0, 0, .F.})
	 	nPosVet := Len(aMedico)
	 Endif

 	aMedico[nPosVet, nPosHora] += 1
 	aTotMed[      1, nPosHora] += 1
 	If (cAliasQRY)->GCY_TPALTA == "99"
 		aMedico[nPosVet, nP_nCancTo] += 1
 		aTotMed[      1, nP_nCancTo] += 1
 	Else
 		aMedico[nPosVet, nP_nAtenTo] += 1
 		aTotMed[      1, nP_nAtenTo] += 1
 	Endif

	// alimenta matriz de convenios
	 nPosVet := aScan(aConve, {| aVetTmp | aVetTmp[1] == (cAliasQRY)->GCZ_CODCON})
	 If nPosVet == 0
	 	aAdd(aConve, {(cAliasQRY)->GCZ_CODCON, Posicione("GA9", 1, xFilial("GA9") + (cAliasQRY)->GCZ_CODCON, "GA9_NREDUZ"), 0, 0, 0, 0, 0, 0, 0, 0, 0, .F.})
	 	nPosVet := Len(aConve)
	 Endif

 	aConve [nPosVet, nPosHora] += 1
 	aTotCon[      1, nPosHora] += 1
 	If (cAliasQRY)->GCY_TPALTA == "99"
 		aConve [nPosVet, nP_nCancTo] += 1
 		aTotCon[      1, nP_nCancTo] += 1
 	Else
 		aConve [nPosVet, nP_nAtenTo] += 1
 		aTotCon[      1, nP_nAtenTo] += 1
 	Endif
 	
	 // alimenta matriz de especialidades medicas
	 nPosVet := aScan(aEspec, {| aVetTmp | aVetTmp[1] == (cAliasQRY)->GCY_CODCLI})
	 If nPosVet == 0
	 	aadd(aEspec, {(cAliasQRY)->GCY_CODCLI, Posicione("GCW",1,xFilial("GCW")+(cAliasQRY)->GCY_CODCLI,"GCW_DESCLI"), 0, 0, 0, 0, 0, 0, 0, 0, 0, .F.})
	 	nPosVet:= Len(aEspec)
	 Endif
	 
	 aEspec [nPosVet, nPosHora] += 1
	 aTotEsp[      1, nPosHora] += 1
	 If (cAliasQRY)->GCY_TPALTA == "99"
	 	aEspec [nPosVet, nP_nCancTo] += 1
	 	aTotEsp[      1, nP_nCancTo] += 1
	 Else
	 	aEspec [nPosVet, nP_nAtenTo] += 1
	 	aTotEsp[      1, nP_nAtenTo] += 1
		Endif
 	
	 DbSkip() // Avanca o ponteiro do registro no arquivo
	
 EndDo

 DbSelectArea(cAliasQRY)
 dbCloseArea()

 aSort(aCusto,,,{|x,y| x[2] < y[2]})
 aSort(aEspec,,,{|x,y| x[2] < y[2]})
 aSort(aMedico,,,{|x,y| x[2] < y[2]})
 aSort(aConve ,,,{|x,y| x[2] < y[2]})
 
 If oGDCusto # Nil
  oGDCusto:SetArray(aCusto)
  oGDCusto := MsNewGetDados():New(030, 002, 160, 480, 2,,,,,, Len(aCusto ),,,, oFolder:aDialogs[1], aEstru, aCusto)
  oGDCusto:lUpDate := .F.
  oGDCusto:oBrowse:Refresh()
 EndIf 
      
 If oGDEspec # Nil
  oGDEspec:SetArray(aEspec) 
  oGDEspec := MsNewGetDados():New(030, 002, 160, 480, 2,,,,,, Len(aEspec ),,,, oFolder:aDialogs[2], aEstru, aEspec)
  oGDEspec:lUpDate := .F.
  oGDEspec:oBrowse:Refresh()
 EndIf 
      
 If oGDMedic # Nil
  oGDMedic:SetArray(aMedico) 
  oGDMedic := MsNewGetDados():New(030, 002, 160, 480, 2,,,,,, Len(aMedico),,,, oFolder:aDialogs[3], aEstru, aMedico)
  oGDMedic:lUpDate := .F.
  oGDMedic:oBrowse:Refresh()
 EndIf 

 If oGDConve # Nil
  oGDConve:SetArray(aConve)
  oGDConve := MsNewGetDados():New(030, 002, 160, 480, 2,,,,,, Len(aConve),,,, oFolder:aDialogs[4], aEstru, aConve)
  oGDConve:lUpDate := .F.
  oGDConve:oBrowse:Refresh()
 EndIf 
 
return(Nil)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Funcao   ณMontaTel()บ Autor ณ MARCELO JOSE       บ Data ณ  23/07/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que Monta Tela (Formulario)                         บฑฑ
ฑฑบ          ณ Nil FS_MontaTel(Nil)                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_MontaTel()
 
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0003) From 01,01 to 465,980	of oMainWnd PIXEL // resumo de atendimento
 
 @ 030,002 FOLDER oFolder SIZE 485, 190 OF oDlg PROMPTS STR0029, STR0030, STR0031, STR0032 PIXEL
 
 @ 003, 220 SAY "de : "+DTOC(mv_par07)+" ate : "+DTOC(mv_par08) Of oFolder:aDialogs[1] PIXEL COLOR CLR_GREEN FONT oFont
 @ 012, 190 SAY "Periodo 1                     Periodo 2                    Periodo3" Of oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK FONT oFont
 @ 022, 185 Say mv_par01+"         "+mv_par02+"         "+mv_par03+"        "+mv_par04+"         "+mv_par05+"         "+mv_par06 Of oFolder:aDialogs[1] PIXEL COLOR CLR_BLACK FONT oFont

 @ 003, 220 SAY "de : "+DTOC(mv_par07)+" ate : "+DTOC(mv_par08) Of oFolder:aDialogs[2] PIXEL COLOR CLR_GREEN FONT oFont
 @ 012, 190 SAY "Periodo 1                     Periodo 2                    Periodo3" Of oFolder:aDialogs[2] PIXEL COLOR CLR_BLACK FONT oFont
 @ 022, 185 Say mv_par01+"         "+mv_par02+"         "+mv_par03+"        "+mv_par04+"         "+mv_par05+"         "+mv_par06 Of oFolder:aDialogs[2] PIXEL COLOR CLR_BLACK FONT oFont

 @ 003, 220 SAY "de : "+DTOC(mv_par07)+" ate : "+DTOC(mv_par08) Of oFolder:aDialogs[3] PIXEL COLOR CLR_GREEN FONT oFont
 @ 012, 190 SAY "Periodo 1                     Periodo 2                    Periodo3" Of oFolder:aDialogs[3] PIXEL COLOR CLR_BLACK FONT oFont
 @ 022, 185 Say mv_par01+"         "+mv_par02+"         "+mv_par03+"        "+mv_par04+"         "+mv_par05+"         "+mv_par06 Of oFolder:aDialogs[3] PIXEL COLOR CLR_BLACK FONT oFont

 @ 003, 220 SAY "de : "+DTOC(mv_par07)+" ate : "+DTOC(mv_par08) Of oFolder:aDialogs[4] PIXEL COLOR CLR_GREEN FONT oFont
 @ 012, 190 SAY "Periodo 1                     Periodo 2                    Periodo3" Of oFolder:aDialogs[4] PIXEL COLOR CLR_BLACK FONT oFont
 @ 022, 185 Say mv_par01+"         "+mv_par02+"         "+mv_par03+"        "+mv_par04+"         "+mv_par05+"         "+mv_par06 Of oFolder:aDialogs[4] PIXEL COLOR CLR_BLACK FONT oFont

 tButton():New(010, 390, STR0022, oFolder:aDialogs[1], {|| HS_Prin0(1)}, 60,,,,, .T.) //imprimir
 tButton():New(010, 390, STR0022, oFolder:aDialogs[2], {|| HS_Prin0(2)}, 60,,,,, .T.) //imprimir
 tButton():New(010, 390, STR0022, oFolder:aDialogs[3], {|| HS_Prin0(3)}, 60,,,,, .T.) //imprimir
 tButton():New(010, 390, STR0022, oFolder:aDialogs[4], {|| HS_Prin0(4)}, 60,,,,, .T.) //imprimir

 @ 160,  80 Say "TOTAL GERAL ===> " Of oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 185 Say transform(aTotCus[1, 3],"999999") Of oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 218 Say transform(aTotCus[1, 4],"999999") Of oFolder:aDialogs[1] PIXEL COLOR CLR_RED  FONT oFont
 @ 160, 243 Say transform(aTotCus[1, 5],"999999") Of oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 275 Say transform(aTotCus[1, 6],"999999") Of oFolder:aDialogs[1] PIXEL COLOR CLR_RED  FONT oFont
 @ 160, 300 Say transform(aTotCus[1, 7],"999999") Of oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 328 Say transform(aTotCus[1, 8],"999999") Of oFolder:aDialogs[1] PIXEL COLOR CLR_RED  FONT oFont
 @ 160, 370 Say transform(aTotCus[1, 9],"999999") Of oFolder:aDialogs[1] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 415 Say transform(aTotCus[1,10],"999999") Of oFolder:aDialogs[1] PIXEL COLOR CLR_RED  FONT oFont


 @ 160,  80 Say "TOTAL GERAL ===> " Of oFolder:aDialogs[2] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 185 Say transform(aTotEsp[1, 3],"999999") Of oFolder:aDialogs[2] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 218 Say transform(aTotEsp[1, 4],"999999") Of oFolder:aDialogs[2] PIXEL COLOR CLR_RED  FONT oFont
 @ 160, 243 Say transform(aTotEsp[1, 5],"999999") Of oFolder:aDialogs[2] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 275 Say transform(aTotEsp[1, 6],"999999") Of oFolder:aDialogs[2] PIXEL COLOR CLR_RED  FONT oFont
 @ 160, 300 Say transform(aTotEsp[1, 7],"999999") Of oFolder:aDialogs[2] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 328 Say transform(aTotEsp[1, 8],"999999") Of oFolder:aDialogs[2] PIXEL COLOR CLR_RED  FONT oFont
 @ 160, 370 Say transform(aTotEsp[1, 9],"999999") Of oFolder:aDialogs[2] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 415 Say transform(aTotEsp[1,10],"999999") Of oFolder:aDialogs[2] PIXEL COLOR CLR_RED  FONT oFont


 @ 160,  80 Say "TOTAL GERAL ===> " Of oFolder:aDialogs[3] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 185 Say transform(aTotMed[1, 3],"999999") Of oFolder:aDialogs[3] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 218 Say transform(aTotMed[1, 4],"999999") Of oFolder:aDialogs[3] PIXEL COLOR CLR_RED  FONT oFont
 @ 160, 243 Say transform(aTotMed[1, 5],"999999") Of oFolder:aDialogs[3] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 275 Say transform(aTotMed[1, 6],"999999") Of oFolder:aDialogs[3] PIXEL COLOR CLR_RED  FONT oFont
 @ 160, 300 Say transform(aTotMed[1, 7],"999999") Of oFolder:aDialogs[3] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 328 Say transform(aTotMed[1, 8],"999999") Of oFolder:aDialogs[3] PIXEL COLOR CLR_RED  FONT oFont
 @ 160, 370 Say transform(aTotMed[1, 9],"999999") Of oFolder:aDialogs[3] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 415 Say transform(aTotMed[1,10],"999999") Of oFolder:aDialogs[3] PIXEL COLOR CLR_RED  FONT oFont

 @ 160,  80 Say "TOTAL GERAL ===> " Of oFolder:aDialogs[4] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 185 Say transform(aTotCon[1, 3],"999999") Of oFolder:aDialogs[4] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 218 Say transform(aTotCon[1, 4],"999999") Of oFolder:aDialogs[4] PIXEL COLOR CLR_RED  FONT oFont
 @ 160, 243 Say transform(aTotCon[1, 5],"999999") Of oFolder:aDialogs[4] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 275 Say transform(aTotCon[1, 6],"999999") Of oFolder:aDialogs[4] PIXEL COLOR CLR_RED  FONT oFont
 @ 160, 300 Say transform(aTotCon[1, 7],"999999") Of oFolder:aDialogs[4] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 328 Say transform(aTotCon[1, 8],"999999") Of oFolder:aDialogs[4] PIXEL COLOR CLR_RED  FONT oFont
 @ 160, 370 Say transform(aTotCon[1, 9],"999999") Of oFolder:aDialogs[4] PIXEL COLOR CLR_BLUE FONT oFont
 @ 160, 415 Say transform(aTotCon[1,10],"999999") Of oFolder:aDialogs[4] PIXEL COLOR CLR_RED  FONT oFont

 oGDCusto := MsNewGetDados():New(030, 002, 160, 480, 2,,,,,, Len(aCusto ),,,, oFolder:aDialogs[1], aEstru, aCusto)
 oGDCusto:lUpDate := .F.
 oGDEspec := MsNewGetDados():New(030, 002, 160, 480, 2,,,,,, Len(aEspec ),,,, oFolder:aDialogs[2], aEstru, aEspec)
 oGDEspec:lUpDate := .F.
 oGDMedic := MsNewGetDados():New(030, 002, 160, 480, 2,,,,,, Len(aMedico),,,, oFolder:aDialogs[3], aEstru, aMedico)
 oGDMedic:lUpDate := .F.
 oGDConve:= MsNewGetDados():New(030, 002, 160, 480, 2,,,,,, Len(aConve),,,, oFolder:aDialogs[4], aEstru, aConve)
 oGDConve:lUpDate := .F.

 aBtnPar := {{"PARAMETROS", {|| IIf(Pergunte(cPerg,.T.),	Processa({|| FS_MCons()}), .T.)}, "Parametros", "Parametros"}}

 ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End() }, {|| oDlg:End()},, aBtnPar)
Return(Nil)
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Funcao   ณHS_Prin0  บ Autor ณ MARCELO JOSE       บ Data ณ  23/07/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que imprime as matrizes dos NewGetDados             บฑฑ
ฑฑบ          ณ Nil HS_Prin0(int nvem0) o param.se refere ao folder escolh.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_Prin0(nvem0)
 wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

 If nLastKey == ESC
 	Return
 Endif

 SetDefault(aReturn,cString)

 If nLastKey == ESC
 	Return
 Endif
Processa({|| FS_MCons()})

 nTipo := If(aReturn[4]==1,15,18)

 // Processamento RPTSTATUS monta janela com a regua de processamento.
 RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin,nvem0) },Titulo)

Return (Nil)
//******************************************************************************************************************
//Funcao    RUNREPORT  Autor : AP6 IDE               Data   15/07/04                                               *
//Descricao Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.*
//Uso       Programa principal                                                                                     *
//******************************************************************************************************************

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin,nvem1)
 Local nCtaFor := 1

 // SETREGUA -> Indica quantos registros serao processados para a regua
// SetRegua(RecCount())
 If nvem1 == 1
	 // IMPRIME CENTRO DE CUSTO -----------------------------------------------------------------------------------------
 	nLin := 80
	 For nCtaFor := 1 To LEN(aCusto) //
	 	If nLin > 55 //Impressao do cabecalho do relatorio. Salto de Pแgina. Neste caso o formulario tem 55 linhas...
	 		If nCtaFor > 1
	 			@ nLin,00 Psay TRACE
	 			nLin++
	 			@ nLin,00 Psay STR0026
	 		Endif
	 		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	 		@ 09,00 PSAY STR0023
	 		@ 10,00 PSAY TRACE
	 		nLin := 12
	 	Endif
	 	@ nLin, 00 Psay SUBS(aCusto[nCtaFor,nP_cCodigo],1,6)+"-"
	 	@ nLin, 07 Psay aCusto[nCtaFor,nP_cDescri]
		 @ nLin, 50 Psay Transform(aCusto[nCtaFor, nP_nAtenP1],"999999")
		 @ nLin, 56 Psay Transform(aCusto[nCtaFor, nP_nCancP1],"999999")
		 @ nLin, 65 Psay Transform(aCusto[nCtaFor, nP_nAtenP2],"999999")
		 @ nLin, 71 Psay Transform(aCusto[nCtaFor, nP_nCancP2],"999999")
		 @ nLin, 80 Psay Transform(aCusto[nCtaFor, nP_nAtenP3],"999999")
		 @ nLin, 86 Psay Transform(aCusto[nCtaFor, nP_nCancP3],"999999")
		 @ nLin, 95 Psay Transform(aCusto[nCtaFor, nP_nAtenTo],"999999")
		 @ nLin,105 Psay Transform(aCusto[nCtaFor, nP_nCancTo],"999999")
		 nLin++
	 Next
	 @ nLin,00 Psay TRACE
	 nLin++
	 @ nLin, 10 Psay STR0027
	 @ nLin, 50 Psay Transform(aTotCus[1, nP_nAtenP1],"999999")
	 @ nLin, 56 Psay Transform(aTotCus[1, nP_nCancP1],"999999")
	 @ nLin, 65 Psay Transform(aTotCus[1, nP_nAtenP2],"999999")
	 @ nLin, 71 Psay Transform(aTotCus[1, nP_nCancP2],"999999")
	 @ nLin, 80 Psay Transform(aTotCus[1, nP_nAtenP3],"999999")
	 @ nLin, 86 Psay Transform(aTotCus[1, nP_nCancP3],"999999")
	 @ nLin, 95 Psay Transform(aTotCus[1, nP_nAtenTo],"999999")
	 @ nLin,105 Psay Transform(aTotCus[1, nP_nCancTo],"999999")
	 nLin++
 Endif
 If nvem1 == 2
	// IMPRIME ESPECIALIDADES MEDICAS ---------------------------------------------------------------------------------
	nLin := 80
	For nCtaFor := 1 To LEN(aEspec) //
		If nLin > 55 //Impressao do cabecalho do relatorio. Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			If nCtaFor > 1
				@ nLin,00 Psay TRACE
				nLin++
				@ nLin,00 Psay STR0026
			Endif
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			@ 09,00 PSAY STR0024
			@ 10,00 PSAY TRACE
			nLin := 12
		Endif
		@ nLin, 00 Psay aEspec[nCtaFor,nP_cCodigo]+"-"
		@ nLin, 07 Psay PADR(aEspec[nCtaFor,nP_cDescri],30)
		@ nLin, 50 Psay Transform(aEspec[nCtaFor, nP_nAtenP1],"999999")
		@ nLin, 56 Psay Transform(aEspec[nCtaFor, nP_nCancP1],"999999")
		@ nLin, 65 Psay Transform(aEspec[nCtaFor, nP_nAtenP2],"999999")
		@ nLin, 71 Psay Transform(aEspec[nCtaFor, nP_nCancP2],"999999")
		@ nLin, 80 Psay Transform(aEspec[nCtaFor, nP_nAtenP3],"999999")
		@ nLin, 86 Psay Transform(aEspec[nCtaFor, nP_nCancP3],"999999")
		@ nLin, 95 Psay Transform(aEspec[nCtaFor, nP_nAtenTo],"999999")
		@ nLin,105 Psay Transform(aEspec[nCtaFor, nP_nCancTo],"999999")
		nLin++
	Next
	@ nLin,00 Psay TRACE
	nLin++
	@ nLin, 10 Psay STR0027
 @ nLin, 50 Psay Transform(aTotEsp[1, nP_nAtenP1],"999999")
	@ nLin, 56 Psay Transform(aTotEsp[1, nP_nCancP1],"999999")
	@ nLin, 65 Psay Transform(aTotEsp[1, nP_nAtenP2],"999999")
	@ nLin, 71 Psay Transform(aTotEsp[1, nP_nCancP2],"999999")
	@ nLin, 80 Psay Transform(aTotEsp[1, nP_nAtenP3],"999999")
	@ nLin, 86 Psay Transform(aTotEsp[1, nP_nCancP3],"999999")
	@ nLin, 95 Psay Transform(aTotEsp[1, nP_nAtenTo],"999999")
	@ nLin,105 Psay Transform(aTotEsp[1, nP_nCancTo],"999999")
	nLin++
Endif
If nvem1 == 3
	// IMPRIME MEDICOS ------------------------------------------------------------------------------------------------
	nLin := 80
	For nCtaFor := 1 To LEN(aMedico) //
		If nLin > 55 //Impressao do cabecalho do relatorio. Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			If nCtaFor > 1
				@ nLin,00 Psay TRACE
				nLin++
				@ nLin,00 Psay STR0026
			Endif
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			@ 09,00 PSAY STR0025
			@ 10,00 PSAY TRACE
			nLin := 12
		Endif
		@ nLin, 00 Psay aMedico[nCtaFor,nP_cCodigo]+"-"
		@ nLin, 07 Psay aMedico[nCtaFor,nP_cDescri]
		@ nLin, 50 Psay Transform(aMedico[nCtaFor, nP_nAtenP1],"999999")
		@ nLin, 56 Psay Transform(aMedico[nCtaFor, nP_nCancP1],"999999")
		@ nLin, 65 Psay Transform(aMedico[nCtaFor, nP_nAtenP2],"999999")
		@ nLin, 71 Psay Transform(aMedico[nCtaFor, nP_nCancP2],"999999")
		@ nLin, 80 Psay Transform(aMedico[nCtaFor, nP_nAtenP3],"999999")
		@ nLin, 86 Psay Transform(aMedico[nCtaFor, nP_nCancP3],"999999")
		@ nLin, 95 Psay Transform(aMedico[nCtaFor, nP_nAtenTo],"999999")
		@ nLin,105 Psay Transform(aMedico[nCtaFor, nP_nCancTo],"999999")
		nLin++
	Next
	@ nLin,00 Psay TRACE
	nLin++
	@ nLin, 10 Psay STR0027
	@ nLin, 50 Psay Transform(aTotMed[1, nP_nAtenP1],"999999")
	@ nLin, 56 Psay Transform(aTotMed[1, nP_nCancP1],"999999")
	@ nLin, 65 Psay Transform(aTotMed[1, nP_nAtenP2],"999999")
	@ nLin, 71 Psay Transform(aTotMed[1, nP_nCancP2],"999999")
	@ nLin, 80 Psay Transform(aTotMed[1, nP_nAtenP3],"999999")
	@ nLin, 86 Psay Transform(aTotMed[1, nP_nCancP3],"999999")
	@ nLin, 95 Psay Transform(aTotMed[1, nP_nAtenTo],"999999")
	@ nLin,105 Psay Transform(aTotMed[1, nP_nCancTo],"999999")
	nLin++
Endif
If nvem1 == 4
	// IMPRIME Convenios ------------------------------------------------------------------------------------------------
	nLin := 80
	For nCtaFor := 1 To LEN(aConve) //
		If nLin > 55 //Impressao do cabecalho do relatorio. Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			If nCtaFor > 1
				@ nLin,00 Psay TRACE
				nLin++
				@ nLin,00 Psay STR0026
			Endif
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			@ 09,00 PSAY STR0033
			@ 10,00 PSAY TRACE
			nLin := 12
		Endif
		@ nLin, 00 Psay aConve[nCtaFor,nP_cCodigo]+"-"
		@ nLin, 07 Psay aConve[nCtaFor,nP_cDescri]
		@ nLin, 50 Psay Transform(aConve[nCtaFor, nP_nAtenP1],"999999")
		@ nLin, 56 Psay Transform(aConve[nCtaFor, nP_nCancP1],"999999")
		@ nLin, 65 Psay Transform(aConve[nCtaFor, nP_nAtenP2],"999999")
		@ nLin, 71 Psay Transform(aConve[nCtaFor, nP_nCancP2],"999999")
		@ nLin, 80 Psay Transform(aConve[nCtaFor, nP_nAtenP3],"999999")
		@ nLin, 86 Psay Transform(aConve[nCtaFor, nP_nCancP3],"999999")
		@ nLin, 95 Psay Transform(aConve[nCtaFor, nP_nAtenTo],"999999")
		@ nLin,105 Psay Transform(aConve[nCtaFor, nP_nCancTo],"999999")
		nLin++
	Next
	@ nLin,00 Psay TRACE
	nLin++
	@ nLin, 10 Psay STR0027
	@ nLin, 50 Psay Transform(aTotCon[1, nP_nAtenP1],"999999")
	@ nLin, 56 Psay Transform(aTotCon[1, nP_nCancP1],"999999")
	@ nLin, 65 Psay Transform(aTotCon[1, nP_nAtenP2],"999999")
	@ nLin, 71 Psay Transform(aTotCon[1, nP_nCancP2],"999999")
	@ nLin, 80 Psay Transform(aTotCon[1, nP_nAtenP3],"999999")
	@ nLin, 86 Psay Transform(aTotCon[1, nP_nCancP3],"999999")
	@ nLin, 95 Psay Transform(aTotCon[1, nP_nAtenTo],"999999")
	@ nLin,105 Psay Transform(aTotCon[1, nP_nCancTo],"999999")
	nLin++
Endif
// Finaliza a execucao do relatorio...
SET DEVICE TO SCREEN

// Se impressao em disco, chama o gerenciador de impressao...
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return(Nil)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Funcao   ณFS_IniX1()บ Autor ณ MARCELO JOSE       บ Data ณ  15/07/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Inicia SX1 p/receber parametros selecionados pelo usuario  บฑฑ
ฑฑบ          ณ Nil FS_IniX1(Nil)                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_IniX1()

Local aHelpPor := {}
Local aHelpSpa := {}
Local aHelpEng := {}
Local aRegs    := {}

_sAlias := Alias()
dbSelectArea("SX1")

If DbSeek(cPerg) // Se encontrar a pergunta , nใo faz nada, pois ja foi criada.
	DbSelectArea(_sAlias)
	Return
Endif

AADD(aHelpPor,"Informe o Horario INICIAL do 1o.   ")
AADD(aHelpPor,"periodo, no formato 99:99										")
AADD(aHelpSpa,"                                   ")
AADD(aHelpSpa,"              																					")
AADD(aHelpEng,"                                   ")
AADD(aHelpEng,"                                   ")
AADD(aRegs,{STR0007,STR0007,STR0007,"mv_ch1","C",05,0,0,"G","HS_ValXP(@mv_par01)","mv_par01","","","","","","","","","","",;
"","","","","","","","","","","","","","","","N","","",aHelpPor,aHelpSpa,aHelpEng})

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
AADD(aHelpPor,"Informe o Horario FINAL do 1o.     ")
AADD(aHelpPor,"periodo, no formato 99:99										")
AADD(aHelpSpa,"                                   ")
AADD(aHelpSpa,"              																					")
AADD(aHelpEng,"                                   ")
AADD(aHelpEng,"                                   ")
AADD(aRegs,{STR0008,STR0008,STR0008,"mv_ch2","C",05,0,0,"G","HS_ValXP(@mv_par02)","mv_par02","","","","","","","","","","",;
"","","","","","","","","","","","","","","","N","","",aHelpPor,aHelpSpa,aHelpEng})


aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
AADD(aHelpPor,"Informe o Horario INICIAL do 2o.   ")
AADD(aHelpPor,"periodo, no formato 99:99        		")
AADD(aHelpSpa,"                                   ")
AADD(aHelpSpa,"              																					")
AADD(aHelpEng,"                                   ")
AADD(aHelpEng,"                                   ")
AADD(aRegs,{STR0009,STR0009,STR0009,"mv_ch3","C",05,0,0,"G","HS_ValXP(@mv_par03)","mv_par03","","","","","","","","","","",;
"","","","","","","","","","","","","","","","N","","",aHelpPor,aHelpSpa,aHelpEng})

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
AADD(aHelpPor,"Informe o Horario FINAL do 2o.     ")
AADD(aHelpPor,"periodo, no formato 99:99										")
AADD(aHelpSpa,"                                   ")
AADD(aHelpSpa,"              																					")
AADD(aHelpEng,"                                   ")
AADD(aHelpEng,"                                   ")
AADD(aRegs,{STR0010,STR0010,STR0010,"mv_ch4","C",05,0,0,"G","HS_ValXP(@mv_par04)","mv_par04","","","","","","","","","","",;
"","","","","","","","","","","","","","","","N","","",aHelpPor,aHelpSpa,aHelpEng})

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
AADD(aHelpPor,"Informe o Horario INICIAL do 3o.   ")
AADD(aHelpPor,"periodo, no formato 99:99										")
AADD(aHelpSpa,"                                   ")
AADD(aHelpSpa,"              																					")
AADD(aHelpEng,"                                   ")
AADD(aHelpEng,"                                   ")
AADD(aRegs,{STR0011,STR0011,STR0011,"mv_ch5","C",05,0,0,"G","HS_ValXP(@mv_par05)","mv_par05","","","","","","","","","","",;
"","","","","","","","","","","","","","","","N","","",aHelpPor,aHelpSpa,aHelpEng})

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
AADD(aHelpPor,"Informe o Horario FINAL do 3o.     ")
AADD(aHelpPor,"periodo, no formato 99:99										")
AADD(aHelpSpa,"                                   ")
AADD(aHelpSpa,"              																					")
AADD(aHelpEng,"                                   ")
AADD(aHelpEng,"                                   ")
AADD(aRegs,{STR0012,STR0012,STR0012,"mv_ch6","C",05,0,0,"G","HS_ValXP(@mv_par06)","mv_par06","","","","","","","","","","",;
"","","","","","","","","","","","","","","","N","","",aHelpPor,aHelpSpa,aHelpEng})


aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
AADD(aHelpPor,"Informe a Data  I N I C I A L  do  ")
AADD(aHelpPor,"Atendimento para pesquisa.					   	")
AADD(aHelpSpa,"                                   ")
AADD(aHelpSpa,"              																					")
AADD(aHelpEng,"                                   ")
AADD(aHelpEng,"                                   ")
AADD(aRegs,{STR0013,STR0013,STR0013,"mv_ch7","D",08,0,0,"G","","mv_par07","","","","","","","","","","",;
"","","","","","","","","","","","","","","","N","","",aHelpPor,aHelpSpa,aHelpEng})

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
AADD(aHelpPor,"Informe a Data  F I N A L  do      ")
AADD(aHelpPor,"Atendimento para pesquisa.									")
AADD(aHelpSpa,"                                   ")
AADD(aHelpSpa,"              																					")
AADD(aHelpEng,"                                   ")
AADD(aHelpEng,"                                   ")
AADD(aRegs,{STR0014,STR0014,STR0014,"mv_ch8","D",08,0,0,"G","","mv_par08","","","","","","","","","","",;
"","","","","","","","","","","","","","","","N","","",aHelpPor,aHelpSpa,aHelpEng})

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
AADD(aHelpPor,"Informe o Setor Inical             ")
AADD(aHelpPor,"para a pesquisa.	          				   	")
AADD(aHelpSpa,"                                   ")
AADD(aHelpSpa,"              																					")
AADD(aHelpEng,"                                   ")
AADD(aHelpEng,"                                   ")
AADD(aRegs,{STR0015,STR0015,STR0015,"mv_ch9","C",02,0,0,"G","","mv_par09","","","","","","","","","","",;
"","","","","","","","","","","","","","","GCS","N","","",aHelpPor,aHelpSpa,aHelpEng})

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
AADD(aHelpPor,"Informe o Setor Final              ")
AADD(aHelpPor,"para pesquisa.		           								")
AADD(aHelpSpa,"                                   ")
AADD(aHelpSpa,"              																					")
AADD(aHelpEng,"                                   ")
AADD(aHelpEng,"                                   ")
AADD(aRegs,{STR0016,STR0016,STR0016,"mv_ch10","C",02,0,0,"G","","mv_par10","","","","","","","","","","",;
"","","","","","","","","","","","","","","GCS","N","","",aHelpPor,aHelpSpa,aHelpEng})

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
AADD(aHelpPor,"Informe a Clinica Medica           ")
AADD(aHelpPor,"Inical para a pesquisa.  						   	")
AADD(aHelpSpa,"                                   ")
AADD(aHelpSpa,"              																					")
AADD(aHelpEng,"                                   ")
AADD(aHelpEng,"                                   ")
AADD(aRegs,{STR0017,STR0017,STR0017,"mv_ch11","C",06,0,0,"G","","mv_par11","","","","","","","","","","",;
"","","","","","","","","","","","","","","GCW","N","","",aHelpPor,aHelpSpa,aHelpEng})

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
AADD(aHelpPor,"Informe a Clinica Medica           ")
AADD(aHelpPor,"Final para a pesquisa.   										")
AADD(aHelpSpa,"                                   ")
AADD(aHelpSpa,"              																					")
AADD(aHelpEng,"                                   ")
AADD(aHelpEng,"                                   ")
AADD(aRegs,{STR0018,STR0018,STR0018,"mv_ch12","C",06,0,0,"G","","mv_par12","","","","","","","","","","",;
"","","","","","","","","","","","","","","GCW","N","","",aHelpPor,aHelpSpa,aHelpEng})

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
AADD(aHelpPor,"Informe o Codigo do Medico         ")
AADD(aHelpPor,"Inical para a pesquisa.  						   	")
AADD(aHelpSpa,"                                   ")
AADD(aHelpSpa,"              																					")
AADD(aHelpEng,"                                   ")
AADD(aHelpEng,"                                   ")
AADD(aRegs,{STR0019,STR0019,STR0019,"mv_ch13","C",06,0,0,"G","","mv_par13","","","","","","","","","","",;
"","","","","","","","","","","","","","","MED","N","","",aHelpPor,aHelpSpa,aHelpEng})

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
AADD(aHelpPor,"Informe o Codigo do Medico         ")
AADD(aHelpPor,"Final para a pesquisa.   										")
AADD(aHelpSpa,"                                   ")
AADD(aHelpSpa,"              																					")
AADD(aHelpEng,"                                   ")
AADD(aHelpEng,"                                   ")
AADD(aRegs,{STR0020,STR0020,STR0020,"mv_ch14","C",06,0,0,"G","","mv_par14","","","","","","","","","","",;
"","","","","","","","","","","","","","","MED","N","","",aHelpPor,aHelpSpa,aHelpEng})

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
AADD(aHelpPor,"Informe o Codigo do Convenio       ")
AADD(aHelpPor,"Inical para a pesquisa.  						   	")
AADD(aHelpSpa,"                                   ")
AADD(aHelpSpa,"              																					")
AADD(aHelpEng,"                                   ")
AADD(aHelpEng,"                                   ")
AADD(aRegs,{"Do Convenio","Do Convenio","Do Convenio","mv_ch15","C",03,0,0,"G","","mv_par15","","","","","","","","","","",;
"","","","","","","","","","","","","","","GA9","N","","",aHelpPor,aHelpSpa,aHelpEng})

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
AADD(aHelpPor,"Informe o Codigo do Convenio       ")
AADD(aHelpPor,"Final para a pesquisa.   										")
AADD(aHelpSpa,"                                   ")
AADD(aHelpSpa,"              																					")
AADD(aHelpEng,"                                   ")
AADD(aHelpEng,"                                   ")
AADD(aRegs,{"Ate o Convenio","Ate o Convenio","Ate o Convenio","mv_ch16","C",03,0,0,"G","","mv_par16","","","","","","","","","","",;
"","","","","","","","","","","","","","","GA9","N","","",aHelpPor,aHelpSpa,aHelpEng})

AjustaSx1(cPerg, aRegs)
dbSelectArea(_sAlias)
Return(Nil)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Funcao   ณValXP()   บ Autor ณ MARCELO JOSE       บ Data ณ  15/07/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida o horario nas perguntas com formato 99:99           บฑฑ
ฑฑบ          ณ Nil HS_ValXP(Char cvempar) param.eh o horario da pergunta  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
FUNCTION HS_ValXP(cvempar)
Local lZera := .F.

if val(subs(cvempar,1,2)) < 0 .OR. val(subs(cvempar,1,2)) > 23
	lZera := .T.
endif

if subs(cvempar,3,1) != ":"
	lZera := .T.
endif

if val(subs(cvempar,4,2)) < 0 .OR. val(subs(cvempar,4,2)) > 59
	lZera := .T.
endif
if lZera
	cvempar := "  :  "
endif
return(nil)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Funcao   ณ FS_PEGAH บ Autor ณ MARCELO JOSE       บ Data ณ  23/07/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ seleciona na matriz a posicao referente a _HORATE          บฑฑ
ฑฑบ          ณ int nPCpoHor  FS_PEGAH(int nHorAte, Char cTpAlta)          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_PegaH(nHorAte, cTpAlta)
 Local nPCpoHor := 0, lSai := .F., cCondP1 := "", cCondP2 := "", cCondP3 := ""
           
 If nPer1_aas < nPer1_das
  cCondP1 := "('" + nHorAte + "' >= nPer1_das .And. '" + nHorAte + "' <= '2359') .Or. ('" + nHorAte + "' >= '0000' .And. '" + nHorAte + "' <= nPer1_aas)" 
 Else 
  cCondP1 := "'" + nHorAte + "' >= nPer1_das .And. '" + nHorAte + "' <= nPer1_aas" 
 EndIf 
 
 If nPer2_aas < nPer2_das
  cCondP2 := "('" + nHorAte + "' >= nPer2_das .And. '" + nHorAte + "' <= '2359') .Or. ('" + nHorAte + "' >= '0000' .And. '" + nHorAte + "' <= nPer2_aas)" 
 Else 
  cCondP2 := "'" + nHorAte + "' >= nPer2_das .And. '" + nHorAte + "' <= nPer2_aas" 
 EndIf 
 
 If nPer3_aas < nPer3_das
  cCondP3 := "('" + nHorAte + "' >= nPer3_das .And. '" + nHorAte + "' <= '2359') .Or. ('" + nHorAte + "' >= '0000' .And. '" + nHorAte + "' <= nPer3_aas)" 
 Else 
  cCondP3 := "'" + nHorAte + "' >= nPer3_das .And. '" + nHorAte + "' <= nPer3_aas" 
 EndIf 
 
 If     &(cCondP1)
 	nPCpoHor := IIf(cTpAlta == "99",	nP_nCancP1,	nP_nAtenP1) // 3 = periodo-1 das...   4 = periodo-1 aas...
 ElseIf &(cCondP2)
 	nPCpoHor := IIf(cTpAlta == "99",	nP_nCancP2, nP_nAtenP2) // 5 = periodo-2 das...   6 = periodo-2 aas...
 ElseIf &(cCondP3)
 	nPCpoHor := IIf(cTpAlta == "99",	nP_nCancP3,	nP_nAtenP3) // 7 = periodo-3 das...   8 = periodo-3 aas...
 EndIf 
 
 If nPCpoHor == 0
 	nPCpoHor := 11 // colocar valor no campo(11) da matriz que recebe as horas  que nao esta em nenhum dos periodos selecionados
 EndIf
Return(nPCpoHor)
