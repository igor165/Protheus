#INCLUDE "hspahr22.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#INCLUDE "Report.ch" 

Static oFont  := TFont():New( "Courier New", 11, 09,, .T.,,,,,.F.) //Titulos dos Campos
Static oFont1 := TFont():New( "Courier New", 09, 08,, .T.,,,,,.F.) //Conteudo dos Campos
Static oFont2 := TFont():New( "Courier New", 09, 08,, .T.,,,,,.F.) //Conteudo dos Campos em Negrito

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR22  บ Autor ณ Mario Arizono      บ Data ณ  28/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relat๓rio Prescri็ใo Medica                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR22(aItens,lCertDig,lAssLote,aGuiasLote)


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Declaracao de Variaveis                                             ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""                    
Local imprime        := .T.
Local aOrd 				      := {}   
Local nLin           := 80     
Private titulo       := STR0003 //"Prescri็๕es M้dicas"
Private Cabec1       := ""
Private Cabec2       := "" 
Private Cabec3       := ""   
Private Cabec4       := "" 
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "HSPAHR22" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := {STR0004 , 1, STR0005, 2, 2, 1, "", 1}  //"Administracao"###"Zebrado"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHR22" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cPerg        := "HSPR22"
Private cString      := ""
Private lPrescri     := .F.  
Private cRegAteIni := "", cRegateFim := "", cCodPacIni := "", cCodPacFim := "", dDatAteIni := "", dDatAteFim := "", dDatPreIni := "", dDatPreFim := "", cSeqPre := "", nTipoImp:= ""
Private nColStart  := 0050  
Private nLenPag    := 3550
Private nColEnd    := nLenPag - 0050          
Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao  
Private aImp    := aItens
Private cMntApre := ""
Default aItens  := {}   
Default lCertDig := .F.
Default lAssLote := .F.
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Ponto de entrada - HSR22ALT ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If ExistBlock("HSR22ALT")
  Execblock("HSR22ALT", .F., .F., {aItens})
  Return(Nil)
 EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Impressao com assinatura do certificado digital                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lCertDig
 	relDigCert(aImp,lAssLote,@aGuiasLote)
	Return
EndIf
/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ PARAMETROS                                                       ณ
  ณ MV_PAR01	Do Atendimento                                          ณ
  ณ MV_PAR02	Ate o Atendimento                                       ณ
  ณ MV_PAR03	Do Paciente                                             ณ
  ณ MV_PAR04	Ate o Paciente                                          ณ  
  ณ MV_PAR05	Da Data Atendimento                                     ณ
  ณ MV_PAR06	Ate Data Atendimento                                    ณ
  ณ MV_PAR07	Do Setor                                                ณ
  ณ MV_PAR08	Ate o Setor                                             ณ     
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

If Empty(aItens)
 If !Pergunte(cPerg,.T.)
	 return
 EndIf
 cRegateIni := MV_PAR01
 cRegateFim := MV_PAR02
 cCodPacIni := MV_PAR03
 cCodPacFim := MV_PAR04
 dDatAteIni := MV_PAR05
 dDatAteFim := MV_PAR06 
 cTipoRel   := MV_PAR07
 nTipoImp   := MV_PAR08   
 cCodImp    := MV_PAR09   
Else   
 If !Pergunte("HSR22A",.T.)
	 return
 EndIf    
 cPerg := "HSR22A"
 lPrescri := .T.
 cTipoRel   := MV_PAR01
 nTipoImp   := MV_PAR02   
 cCodImp    := MV_PAR03    
Endif                                                                      
nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2     


//**************************************************
          /*                    1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                      0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */

 Cabec1 := STR0015 //"Atendimento Prontuario  Paciente                                   Dat. Aten.     Setor                                   Quar./Leit.   Convenio/Plano" //"Atendimento Prontuario   Paciente                                  Dat. Aten.     Setor                                   Quarto/Leito  Convenio/Plano"
 Cabec2 := STR0016 //"Dat. Presc.   Hora Presc.                  Medico da Prescricao"
 Cabec3 := STR0017 //"Seq.  Tipo           Apresentacao/Frequencia                                                                           Regime          Diluente                                     Horarios" 
 Cabec4 := STR0039 //"      Observa็ใo"

 If cTipoRel == 1
  RptStatus({|| RotImp(Cabec1,Cabec2,Titulo,nMaxLin)},Titulo)
 Else
  wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho,, .F.)

 If nLastKey == 27
 	Return(Nil)
 EndIf

 SetDefault(aReturn, cString)

 If nLastKey == 27
	 Return(Nil)
 EndIf

 nTipo := If(aReturn[4] == 1, 15, 18)
 RptStatus({|| RunReport(Cabec1, Cabec2, Titulo, nLin)}, Titulo)

 EndIf
//**************************************************    


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Mario Arizono      บ Data ณ  28/05/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local cSQL 	     := "" 
Local cRegate    := "" 
Local dDatPre    := CTOD("  /  /  ") 
Local nCont      := 0
Local nItemPag   := 0
Private aRegs  		:= {}  


If Empty(aimp)
 cSQL := "SELECT GCY.GCY_REGATE GCY_REGATE, GCY.GCY_REGGER GCY_REGGER, GCY.GCY_NOME GCY_NOME,  GCY.GCY_QUAINT GCY_QUAINT, GCY.GCY_LEIINT GCY_LEIINT, "
 cSQL += "GHV.GHV_DATPRE GHV_DATPRE, GHV.GHV_HORCRI GHV_HORCRI, GCY.GCY_CODLOC GCY_CODLOC, GCS.GCS_NOMLOC GCS_NOMLOC, GHV.GHV_CODCRM GHV_CODCRM, GHV.GHV_STATUS GHV_STATUS, GHV.GHV_IMPVIA GHV_IMPVIA, "
 cSQL += "GHX.GHX_SEQITE GHX_SEQITE,GHX.GHX_CDITMP GHX_CDITMP, GHX.GHX_TPITMP GHX_TIPO, GCY.GCY_DATATE GCY_DATATE, GCZ.GCZ_CODCON GCZ_CODCON, GCZ.GCZ_CODPLA GCZ_CODPLA, "
 cSQL += "GHX.GHX_APRESE GHX_APRESE, GHX.GHX_APRESD GHX_APRESD, GFZ.GFZ_PEFRQA GFZ_PEFRQA, GFZ.GFZ_UNFRQA GFZ_UNFRQA,"
 cSQL += "GFZ.GFZ_DSFRQA GFZ_DSFRQA, GHX.GHX_IDREGI GHX_IDREGI, GHX.GHX_DISPAR GHX_DISPAR, GHX.GHX_OBSREG GHX_OBSREG, GHX.GHX_CDMEDI GHX_CDMEDI, "
 cSQL += "GHX.GHX_VOLUME GHX_VOLUME, GHX.GHX_VELINF GHX_VELINF, GFW.GFW_DESVIA GFW_DESVIA, GFY.GFY_DSMINF GFY_DSMINF "
 cSQL += "FROM " + RetSQLName("GCY") + " GCY "    
 cSQL += "JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_REGATE = GCY.GCY_REGATE AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += "JOIN " + RetSQLName("GHV") + " GHV ON GHV.GHV_REGATE = GCY.GCY_REGATE AND GHV.GHV_FILIAL = '" + xFilial("GHV") + "' AND GHV.D_E_L_E_T_ <> '*' " 
 cSQL += "JOIN " + RetSQLName("GHX") + " GHX ON GHX.GHX_SEQPRE = GHV.GHV_SEQPRE AND GHX.GHX_REGATE = GHV.GHV_REGATE AND GHX.GHX_FILIAL = '" + xFilial("GHX") + "' AND GHX.D_E_L_E_T_ <> '*' " 
 cSQL += "JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GCY.GCY_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' " 
 cSQL += "LEFT JOIN " + RetSQLName("GFZ") + " GFZ ON GFZ.GFZ_CDFRQA = GHX.GHX_CDFRQA AND GFZ.GFZ_FILIAL = '" + xFilial("GFZ") + "' AND GFZ.D_E_L_E_T_ <> '*' " 
 cSQL += "LEFT JOIN " + RetSQLName("GFW") + " GFW ON GFW.GFW_CODVIA = GHX.GHX_CODVIA AND GFW.GFW_FILIAL = '" + xFilial("GFW") + "' AND GFW.D_E_L_E_T_ <> '*' " 
 cSQL += "LEFT JOIN " + RetSQLName("GFY") + " GFY ON GFY.GFY_CDMINF = GHX.GHX_CDMINF AND GFY.GFY_FILIAL = '" + xFilial("GFY") + "' AND GFY.D_E_L_E_T_ <> '*' " 
 cSQL += "WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "   
 cSQL += "AND GCY.GCY_REGATE BETWEEN '" + cRegateIni  + "' AND '" +  cRegateFim + "' " 
 cSQL += "AND GCY.GCY_REGGER BETWEEN '" + cCodPacIni  + "' AND '" +  cCodPacFim + "' " 
 cSQL += "AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatAteIni)  + "' AND '" +  DTOS(dDatAteFim) + "' " 
 If !Empty(dDatPreFim) 
  cSQL += "AND GHV.GHV_DATPRE BETWEEN '" + DTOS(dDatPreIni)  + "' AND '" +  DTOS(dDatPreFim) + "' " 
 Endif             
 If !Empty(cSeqPre)  
  cSQL += "AND GHV.GHV_SEQPRE = '" + cSeqPre + "' "   
 EndIf
 cSQL += "ORDER BY GCY_REGATE, GHV_DATPRE, GHX_SEQITE "
   
 cSQL :=  ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
                                
 If Eof()  
   HS_MsgInf(STR0006, STR0007, STR0008)  //"Nenhum dado foi encontrado para a selecao efetuada!"###"Aten็ใo"###"Valida็ใo Relat. Prescri็ใo Medica."
  EndIf

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

 SetRegua(100)

 While !EOF()

	 IncRegua()
   
   If lAbortPrint
      @nLin,00 PSAY STR0009 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
   
   If nLin  > nMaxLin
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif

   If cRegate <> QRY->GCY_REGATE  
    If !Empty(cRegate)
     nLin:= nLin + 3
    Endif     
    nLin++
    @nLin,000 PSAY QRY->GCY_REGATE
    @nLin,012 PSAY QRY->GCY_REGGER
    @nLin,025 PSAY SUBSTR(QRY->GCY_NOME,1,40) 
    @nLin,067 PSAY HS_DTOC(STOD(QRY->GCY_DATATE),2)  
    @nLin,082 PSAY QRY->GCY_CODLOC + "-" + SUBSTR(QRY->GCS_NOMLOC, 1, 30)
    @nLin,122 PSAY IIF(!Empty(QRY->GCY_QUAINT), ALLTRIM(QRY->GCY_QUAINT),SPACE(LEN(GCY->GCY_QUAINT))) + "/" + IIF(!Empty(QRY->GCY_LEIINT), QRY->GCY_LEIINT, SPACE(LEN(GCY->GCY_LEIINT)))
    @nLin,136 PSAY ALLTRIM(POSICIONE("GA9",  1, XFILIAL("GA9") + HS_IniPadr("GCZ", 2, GCY->GCY_REGATE+"0", "GCZ_CODCON"), "GA9_NREDUZ")) + "/" + ALLTRIM(HS_IniPadr("GCM",  2, HS_IniPadr("GCZ",  2, GCY->GCY_REGATE+"0", "GCZ_CODPLA",, .F.), "GCM_DESPLA",, .F.))
    nLin++
    @nLin,000 PSAY HS_DTOC(STOD(QRY->GHV_DATPRE),2)
    @nLin,014 PSAY QRY->GHV_HORCRI
    @nLin,043 PSAY ALLTRIM(HS_INIPADR("SRA", 11,QRY->GHV_CODCRM, "RA_NOME",, .F.)) + " - CRM " + QRY->GHV_CODCRM
    nLin++
    @nLin, 000 PSAY __PRTTHINLINE()   
    nLin++
    @nLin,000 PSAY Cabec3
    nLin++
    @nLin,000 PSAY Cabec4
    nLin++
    @nLin, 000 PSAY __PRTTHINLINE()
    nLin:= FS_ImpPre(nLin,, STOD(QRY->GHV_DATPRE))   
   Else
    If dDatPre <> 	QRY->GHV_DATPRE   
     If !Empty(dDatPre) // quebra de pแgina na mudan็a de data
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
      @nLin,000 PSAY QRY->GCY_REGATE
      @nLin,012 PSAY QRY->GCY_REGGER
      @nLin,025 PSAY SUBSTR(QRY->GCY_NOME,1,40) 
      @nLin,067 PSAY HS_DTOC(STOD(QRY->GCY_DATATE),2)  
      @nLin,082 PSAY QRY->GCY_CODLOC + "-" + SUBSTR(QRY->GCS_NOMLOC, 1, 30)
      @nLin,122 PSAY IIF(!Empty(QRY->GCY_QUAINT), ALLTRIM(QRY->GCY_QUAINT),SPACE(LEN(GCY->GCY_QUAINT))) + "/" + IIF(!Empty(QRY->GCY_LEIINT), QRY->GCY_LEIINT, SPACE(LEN(GCY->GCY_LEIINT)))
      @nLin,136 PSAY ALLTRIM(POSICIONE("GA9",  1, XFILIAL("GA9") + HS_IniPadr("GCZ", 2, GCY->GCY_REGATE+"0", "GCZ_CODCON"), "GA9_NREDUZ")) + "/" + ALLTRIM(HS_IniPadr("GCM",  2, HS_IniPadr("GCZ",  2, GCY->GCY_REGATE+"0", "GCZ_CODPLA",, .F.), "GCM_DESPLA",, .F.))
      nLin++
     EndIf
     @nLin,000 PSAY HS_DTOC(STOD(QRY->GHV_DATPRE),2)
     @nLin,014 PSAY QRY->GHV_HORCRI
     @nLin,043 PSAY ALLTRIM(HS_INIPADR("SRA", 11,QRY->GHV_CODCRM, "RA_NOME",, .F.)) + " - CRM " + QRY->GHV_CODCRM
     nLin++
     @nLin, 000 PSAY __PRTTHINLINE()   
     nLin++
     @nLin,000 PSAY Cabec3
     nLin++
     @nLin,000 PSAY Cabec4
     nLin++
     @nLin, 000 PSAY __PRTTHINLINE()
     nLin:= FS_ImpPre(nLin,, STOD(QRY->GHV_DATPRE))       
    Else  
     nLin:= FS_ImpPre(nLin,, STOD(QRY->GHV_DATPRE))
    Endif
   EndIf
    
    cRegate := QRY->GCY_REGATE
    dDatPre := QRY->GHV_DATPRE  
    
   dbSkip() /* Avanca o ponteiro do registro no arquivo */  
  
   nLin ++
 End

Else //imprime matriz

 SetRegua(Len(aimp))
 For nCont:=1 to Len(aimp)
	 IncRegua()
     nItemPag++
   If lAbortPrint
      @nLin,00 PSAY STR0009 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   If nCont == 1 
   	Titulo := ALLTRIM(Titulo) + " (" + ALLTRIM(aimp[nCont,21]) + ") - " +  ALLTRIM(aimp[nCont,20])
   EndIf

   If nLin  > nMaxLin
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nItemPag := 1
      nLin := 8
   Endif
   If nItemPag == 1
   
    nLin++
    @nLin,000 PSAY aimp[nCont,1]
    @nLin,012 PSAY aimp[nCont,2]
    @nLin,025 PSAY SUBSTR(aimp[nCont,3],1,40)
    @nLin,067 PSAY HS_DTOC(aimp[nCont,8],2)  
    @nLin,082 PSAY aimp[nCont,6] + "-" + SUBSTR(HS_IniPadr("GCS",1,aimp[nCont,6],"GCS_NOMLOC"), 1, 30)
    @nLin,122 PSAY IIF(!Empty(aimp[nCont,4]), ALLTRIM(aimp[nCont,4]),SPACE(LEN(aimp[nCont,4]))) + "/" + IIF(!Empty(aimp[nCont,5]), aimp[nCont,5], SPACE(LEN(aimp[nCont,5])))
    @nLin,136 PSAY ALLTRIM(POSICIONE("GA9",  1, XFILIAL("GA9") + HS_IniPadr("GCZ", 2, aimp[nCont,1]+"0", "GCZ_CODCON"), "GA9_NREDUZ")) + "/" + ALLTRIM(HS_IniPadr("GCM",  2, HS_IniPadr("GCZ",  2, aimp[nCont,1]+"0", "GCZ_CODPLA",, .F.), "GCM_DESPLA",, .F.)) 
    nLin++
    @nLin,000 PSAY HS_DTOC(aimp[nCont,9],2)
    @nLin,014 PSAY aimp[nCont,10]
    @nLin,043 PSAY ALLTRIM(HS_INIPADR("SRA", 11,aimp[nCont,7], "RA_NOME",, .F.)) + " - CRM " + aimp[nCont,7]
    nLin++
    @nLin, 000 PSAY __PRTTHINLINE()   
    nLin++
    @nLin,000 PSAY Cabec3
    nLin++
    @nLin,000 PSAY Cabec4
    nLin++
    @nLin, 000 PSAY __PRTTHINLINE()
    nLin++ 
   Endif
    nLin:= FS_ImpPre(nLin, nCont, aimp[nCont,9] )   
 
next nCont
EndIf
/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Finaliza a execucao do relatorio...                                 ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

SET DEVICE TO SCREEN

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Se impressao em disco, chama o gerenciador de impressao...          ณ                                           	
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()
DBCloseArea()

Return  

//******************************
Static Function FS_ImpPre(nLin, nCont, dDatPre)
Local nHora    := 0 
Local cImp     := "", cMin := ""
Local cHorIni  := "", cHorLim := ""
Local dDatIni  := "", dDatLim := "" 
Local aCalcDat := {}
Local nLinObs  := 0
Local aArea    := GetArea()
Default nCont  := 0  

If Empty(aimp)
 If nLin > nMaxLin
  Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
  nLin := 8
 Endif 
 nLin++

 @nLin,000 PSAY QRY->GHX_SEQITE
 @nLin,006 PSAY ALLTRIM(SUBSTR(HS_RDescrB("GHX_TPITMP", QRY->GHX_TIPO),1,13))
 
 cMntApre := FS_MNTDESC(QRY->GHX_TIPO, QRY->GHX_CDMEDI, QRY->GHX_APRESE, QRY->GFZ_DSFRQA, QRY->GHX_VOLUME, QRY->GFW_DESVIA, QRY->GFY_DSMINF, QRY->GHX_VELINF)
 
 @nLin,021 PSAY cMntApre
 @nLin,119 PSAY HS_RDescrB("GHX_IDREGI", QRY->GHX_IDREGI) 
 @nLin,135 PSAY SUBSTR(QRY->GHX_APRESD,1,40) 
 
 If QRY->GHX_TIPO <> "1"
  nLin++
  @nLin,006 PSAY QRY->GHX_OBSREG
  nLin++
 Else
  //monta horแrios      
  If !Empty(QRY->GHX_OBSREG)
   nLinObs := nLin + 1
  Endif
  aCalcDat := HS_CALCDAT(dDatPre, QRY->GHV_HORCRI, "+", ALLTRIM(STR(QRY->GHX_DISPAR)+ ":00"))
   
  cHorIni  := aCalcDat[2]
  dDatIni  := aCalcDat[1]  
  cHorLim  := aCalcDat[2]
  dDatLim  := aCalcDat[1]
 
  If QRY->GFZ_UNFRQA =="M" 
   If QRY->GFZ_PEFRQA > 59
    cMin:= STRZERO((QRY->GFZ_PEFRQA / 60),2)+"."+STRZERO((Mod(QRY->GFZ_PEFRQA,60)*60),2)
   Else
    cMin:="00."+STRZERO(QRY->GFZ_PEFRQA,2)
   EndIf  
  Else
   cMin:= STRZERO(QRY->GFZ_PEFRQA,2) +".00"
  EndIf  

  While (dDatIni == dDatLim .And. cHorIni < "24:00") .Or. (dDatIni < dDatLim .And. cHorLim < cHorIni)
   AADD(aRegs,{cHorLim})                        
   aCalcDat := HS_CALCDAT(dDatLim, cHorLim, "+", cMin)
   cHorLim  := aCalcDat[2]
   dDatLim  := aCalcDat[1]
  End                                            
 
  For nHora:=1 to len(aRegs)
   If Len(cImp) > 28 
    If nLin == nLinObs
     @nLin,006 PSAY QRY->GHX_OBSREG
    Endif
    @nLin,180 PSAY cImp
    nLin++
    cImp:= aRegs[nHora][1]
   Else 
   IIf(Len(cImp)=0,(cImp:= aRegs[nHora][1]),(cImp+= " / " + aRegs[nHora][1])) 
    If nHora==Len(aRegs)
     If nLin == nLinObs
      @nLin,006 PSAY QRY->GHX_OBSREG
     Endif
     @nLin,180 PSAY cImp
     nLin++     
     If nLin > nMaxLin
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
     Endif        
      cImp := ""
    EndIf
   EndIf
  Next nHora
 Endif
 aRegs:={} 
Else
 If nLin > nMaxLin
  Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
  nLin := 8
 Endif 
 nLin++
 
 @nLin,000 PSAY aimp[nCont,11] + Iif(!empty(aimp[nCont,28]),"S","")
 @nLin,006 PSAY ALLTRIM(SUBSTR(HS_RDescrB("GHX_TPITMP", aimp[nCont,12]),1,13))   
 cMntApre := FS_MNTDESC(aimp[nCont,12], aimp[nCont,27], aimp[nCont,13], aimp[nCont,16], aimp[nCont,23], aimp[nCont,24], aimp[nCont,26], aimp[nCont,25])
 
 @nLin,021 PSAY cMntApre
 @nLin,119 PSAY HS_RDescrB("GHX_IDREGI", aimp[nCont,17]) 
 @nLin,135 PSAY SUBSTR(aimp[nCont,14],1,40) 
 
 If aimp[nCont,12] <> "1"
  nLin++
  @nLin,006 PSAY aimp[nCont,22]
  nLin++
 Else

  If !Empty(aimp[nCont,22])
   nLinObs := nLin + 1
  Endif 
 
  cSql := "SELECT GFZ.GFZ_UNFRQA, GFZ.GFZ_PEFRQA "
  cSQL += "FROM " + RetSQLName("GFZ") + " GFZ " 
  cSQL += "WHERE GFZ.GFZ_CDFRQA = '" +aimp[nCont,19] + "' AND GFZ.GFZ_FILIAL = '" + xFilial("GFZ") + "' AND GFZ.D_E_L_E_T_ <> '*' "     
  cSQL :=  ChangeQuery(cSQL)

  TCQUERY cSQL NEW ALIAS "FRQ"
  DbSelectArea("FRQ")
  DbGoTop()       
  
  //monta horแrios
  aCalcDat := HS_CALCDAT(dDatPre, aimp[nCont,10], "+", ALLTRIM(STR(aimp[nCont,18])+ ":00"))
   
  cHorIni  := aCalcDat[2]
  dDatIni  := aCalcDat[1]  
  cHorLim  := aCalcDat[2]
  dDatLim  := aCalcDat[1]
 
  If FRQ->GFZ_UNFRQA =="M" 
   If FRQ->GFZ_PEFRQA > 59
    cMin:= STRZERO((FRQ->GFZ_PEFRQA / 60),2)+"."+STRZERO((Mod(FRQ->GFZ_PEFRQA,60)*60),2)
   Else
    cMin:="00."+STRZERO(FRQ->GFZ_PEFRQA,2)
   EndIf  
  Else
   cMin:= STRZERO(FRQ->GFZ_PEFRQA,2) +".00"
  EndIf  
  
  While (dDatIni == dDatLim .And. cHorIni < "24:00") .Or. (dDatIni < dDatLim .And. cHorLim < cHorIni )
   AADD(aRegs,{cHorLim})                        
   aCalcDat := HS_CALCDAT(dDatLim, cHorLim, "+",cMin)
   cHorLim  := aCalcDat[2]
   dDatLim  := aCalcDat[1]
  End                                            
   
  For nHora:=1 to len(aRegs)
   If Len(cImp) > 28 
    If nLin == nLinObs
     @nLin,006 PSAY aimp[nCont,22]
    Endif
    @nLin,180 PSAY cImp
    nLin++
    cImp:= aRegs[nHora][1]
   Else 
   IIf(Len(cImp)=0,(cImp:= aRegs[nHora][1]),(cImp+= " / " + aRegs[nHora][1])) 
    If nHora==Len(aRegs)
     If nLin == nLinObs
      @nLin,012 PSAY aimp[nCont,22]
     Endif
     @nLin,180 PSAY cImp
     nLin++     
     If nLin > nMaxLin
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
     Endif        
     cImp := ""
    EndIf
   EndIf
  next nHora 
  dbCloseArea()
 Endif
 aRegs:={} 
        
 
EndIf 
RestArea(aArea)
Return(nLin)                           


// ************************************************
Static Function RotImp(Cabec1,Cabec2,Titulo,nMaxLin)

Local cRegate    := "" 
Local dDatPre    := CTOD("  /  /  ") 
Local nHeiPag    := 2200 //3200
Local nLin       := nHeiPag + 1 
Local nCont      := 0
Local nItemPag   := 0
Local lNovaPag   := .F.
Private lCabec     := .T. 
Private nLinF  := 260
Private cCodCon     := ""
Private cCodPla_De  := ""
Private cCodPla_Ate := ""
Private cCodLoc_De  := ""
Private cCodLoc_Ate := ""
Private cNrLote     := ""
Private cNumPro     := ""
Private cNrFatu     := ""
Private dDatAte_De  := ""
Private dDatAte_Ate := ""
Private nOrdem      := 0
Private cNrSeqG     := ""
                             
If Empty(aimp)
	cSQL := "SELECT GCY.GCY_REGATE GCY_REGATE, GCY.GCY_REGGER GCY_REGGER, GCY.GCY_NOME GCY_NOME,GCY_IDADE,  GCY.GCY_QUAINT GCY_QUAINT, GCY.GCY_LEIINT GCY_LEIINT, "
 cSQL += "GHV.GHV_DATPRE GHV_DATPRE, GHV.GHV_HORCRI GHV_HORCRI, GCY.GCY_CODLOC GCY_CODLOC, GCS.GCS_NOMLOC GCS_NOMLOC, GHV.GHV_CODCRM GHV_CODCRM, GHV.GHV_STATUS GHV_STATUS, GHV.GHV_IMPVIA GHV_IMPVIA, "
 cSQL += "GHX.GHX_SEQITE GHX_SEQITE,GHX.GHX_CDITMP GHX_CDITMP, GHX.GHX_TPITMP GHX_TIPO, GCY.GCY_DATATE GCY_DATATE, GCZ.GCZ_CODCON GCZ_CODCON, GCZ.GCZ_CODPLA GCZ_CODPLA, "
 cSQL += "GHX.GHX_APRESE GHX_APRESE, GHX.GHX_APRESD GHX_APRESD, GFZ.GFZ_PEFRQA GFZ_PEFRQA, GFZ.GFZ_UNFRQA GFZ_UNFRQA,"
 cSQL += "GFZ.GFZ_DSFRQA GFZ_DSFRQA, GHX.GHX_IDREGI GHX_IDREGI, GHX.GHX_DISPAR GHX_DISPAR, GHX.GHX_OBSREG GHX_OBSREG, GHX.GHX_CDMEDI GHX_CDMEDI, "
 cSQL += "GHX.GHX_VOLUME GHX_VOLUME, GHX.GHX_VELINF GHX_VELINF, GFW.GFW_DESVIA GFW_DESVIA, GFY.GFY_DSMINF GFY_DSMINF "
 cSQL += "FROM " + RetSQLName("GCY") + " GCY "    
 cSQL += "JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_REGATE = GCY.GCY_REGATE AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += "JOIN " + RetSQLName("GHV") + " GHV ON GHV.GHV_REGATE = GCY.GCY_REGATE AND GHV.GHV_FILIAL = '" + xFilial("GHV") + "' AND GHV.D_E_L_E_T_ <> '*' " 
 cSQL += "JOIN " + RetSQLName("GHX") + " GHX ON GHX.GHX_SEQPRE = GHV.GHV_SEQPRE AND GHX.GHX_REGATE = GHV.GHV_REGATE AND GHX.GHX_FILIAL = '" + xFilial("GHX") + "' AND GHX.D_E_L_E_T_ <> '*' " 
 cSQL += "JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GCY.GCY_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' " 
 cSQL += "LEFT JOIN " + RetSQLName("GFZ") + " GFZ ON GFZ.GFZ_CDFRQA = GHX.GHX_CDFRQA AND GFZ.GFZ_FILIAL = '" + xFilial("GFZ") + "' AND GFZ.D_E_L_E_T_ <> '*' " 
 cSQL += "LEFT JOIN " + RetSQLName("GFW") + " GFW ON GFW.GFW_CODVIA = GHX.GHX_CODVIA AND GFW.GFW_FILIAL = '" + xFilial("GFW") + "' AND GFW.D_E_L_E_T_ <> '*' " 
 cSQL += "LEFT JOIN " + RetSQLName("GFY") + " GFY ON GFY.GFY_CDMINF = GHX.GHX_CDMINF AND GFY.GFY_FILIAL = '" + xFilial("GFY") + "' AND GFY.D_E_L_E_T_ <> '*' " 
 cSQL += "WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "   
 cSQL += "AND GCY.GCY_REGATE BETWEEN '" + cRegateIni  + "' AND '" +  cRegateFim + "' " 
 cSQL += "AND GCY.GCY_REGGER BETWEEN '" + cCodPacIni  + "' AND '" +  cCodPacFim + "' " 
 cSQL += "AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatAteIni)  + "' AND '" +  DTOS(dDatAteFim) + "' " 
 If !Empty(dDatPreFim) 
  cSQL += "AND GHV.GHV_DATPRE BETWEEN '" + DTOS(dDatPreIni)  + "' AND '" +  DTOS(dDatPreFim) + "' " 
 Endif             
 If !Empty(cSeqPre)  
  cSQL += "AND GHV.GHV_SEQPRE = '" + cSeqPre + "' "   
 EndIf
 cSQL += "ORDER BY GCY_REGATE, GHV_DATPRE, GHX_SEQITE "
   
 cSQL :=  ChangeQuery(cSQL)
  
 DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"QRYIMG",.F.,.T.)
 
 DbSelectArea("QRYIMG")
 SetRegua(RecCount())
 DbGoTop()
  
 If Eof()
 	HS_MsgInf(STR0004, STR0009, STR0005)   //"Nenhuma informa็ใo foi encontrada para a sele็ใo!"###"Aten็ใo"###"Verifique a sele็ใo"
 EndIf


 oPrn:=TMSPrinter():New()
 oPrn:Setup()
	oPrn:SetLandscape()

	nEspLin	:=  060   	// espa็amento entre linha
 nMarSup	   :=  080   	             // margen superior
	nCol1 	:=  030     // margen da coluna1
 nCol2 	    :=  617		               // margen da coluna2
 nCol3 	    :=  817		               // margen da coluna3


 oPrn:StartPage()
 nLin 	  := nMarSup      // Linha inicial

 While !Eof() 
  
  If (cRegate <> QRYIMG->GCY_REGATE  .and. !Empty(cRegate)) .or. nLin > nHeiPag
   lCabec := .T.  
	 	lNovaPag := .F.
	 	nLin 	   := nMarSup      
	 	oPrn:EndPage()
	 	oPrn:StartPage() 
  EndIf
  If lCabec .or. cRegate <> QRYIMG->GCY_REGATE  
	  nLin := FS_CabecImp("0123", oPrn, nLenPag, NomeProg, Titulo, QRYIMG->GCY_REGATE)
	  lCabec := .F.
	 EndIf
	
  If cRegate <> QRYIMG->GCY_REGATE  
			oPrn:Line(nLin + 0030 , nColStart, nLin,  nColEnd)
   nLin += nEspLin
	  oPrn:Say(nLin, 050, QRYIMG->GCY_REGATE, oFont1, 100)
	  oPrn:Say(nLin, 291, QRYIMG->GCY_REGGER, oFont1, 100)
			oPrn:Say(nLin, 541, SUBSTR(QRYIMG->GCY_NOME,1,40), oFont1, 100) //Nome
			oPrn:Say(nLin, 1180, SUBSTR(QRYIMG->GCY_IDADE,1,10), oFont1, 100) //Idade do Paciente			
   oPrn:Say(nLin, 1360, HS_DTOC(STOD(QRYIMG->GCY_DATATE),2), oFont1, 100)  
   oPrn:Say(nLin, 1650,QRYIMG->GCY_CODLOC + "-" + SUBSTR(QRYIMG->GCS_NOMLOC, 1, 30), oFont1, 100)
   oPrn:Say(nLin, 2430, IIF(!Empty(QRYIMG->GCY_QUAINT), ALLTRIM(QRYIMG->GCY_QUAINT)+ "/" ,SPACE(LEN(QRYIMG->GCY_QUAINT))) + IIF(!Empty(QRYIMG->GCY_LEIINT), QRYIMG->GCY_LEIINT, SPACE(LEN(QRYIMG->GCY_LEIINT))), oFont1, 100)
   oPrn:Say(nLin, 2700, ALLTRIM(HS_IniPadr("GA9",  1, QRYIMG->GCZ_CODCON, "GA9_NREDUZ",, .F.)) + "/" + ALLTRIM(SUBSTR(HS_IniPadr("GCM", 2, QRYIMG->GCZ_CODPLA, "GCM_DESPLA",, .F.),1,20))  , oFont1, 100)  
   nLin += nEspLin                            

   oPrn:Say(nLin, 050, HS_DTOC(STOD(QRYIMG->GHV_DATPRE),2), oFont2, 100)
   oPrn:Say(nLin, 325, QRYIMG->GHV_HORCRI, oFont2, 100)
   oPrn:Say(nLin, 890, ALLTRIM(HS_INIPADR("SRA", 11,QRYIMG->GHV_CODCRM, "RA_NOME",, .F.)) + " - CRM " + QRYIMG->GHV_CODCRM, oFont2, 100)
   nLin += nEspLin 
			oPrn:Line(nLin + 0030 , nColStart, nLin,  nColEnd)
   nLin += nEspLin   
   nLin := FS_CabItem(nLin)
   nLin += nEspLin/2 
			oPrn:Line(nLin + 0030 , nColStart, nLin,  nColEnd)
   nLin += nEspLin     
   nLin:= FS_ImpPreImg(nLin,, STOD(QRYIMG->GHV_DATPRE))
  Else  
   If dDatPre <> 	QRYIMG->GHV_DATPRE 
    If !Empty(dDatPre) // quebra de pแgina na mudan็a de data
 	 	 lNovaPag := .F.
	   	nLin 	   := nMarSup      // linha inicial
 	  	oPrn:EndPage()
	  	 oPrn:StartPage()
   	 nLin := FS_CabecImp("0123", oPrn, nLenPag, NomeProg, Titulo, QRYIMG->GCY_REGATE)
					oPrn:Line(nLin + 0030 , nColStart, nLin,  nColEnd)
     nLin += nEspLin
   	 oPrn:Say(nLin, 050, QRYIMG->GCY_REGATE, oFont1, 100)
	    oPrn:Say(nLin, 291, QRYIMG->GCY_REGGER, oFont1, 100)
     oPrn:Say(nLin, 541, SUBSTR(QRYIMG->GCY_NOME,1,40), oFont1, 100)
					oPrn:Say(nLin, 1180, SUBSTR(QRYIMG->GCY_IDADE,1,10), oFont1, 100) //Idade do Paciente
     oPrn:Say(nLin, 1360, HS_DTOC(STOD(QRYIMG->GCY_DATATE),2), oFont1, 100)  
     oPrn:Say(nLin, 1650,QRYIMG->GCY_CODLOC + "-" + SUBSTR(QRYIMG->GCS_NOMLOC, 1, 30), oFont1, 100)
     oPrn:Say(nLin, 2430, IIF(!Empty(QRYIMG->GCY_QUAINT), ALLTRIM(QRYIMG->GCY_QUAINT)+ "/" ,SPACE(LEN(QRYIMG->GCY_QUAINT))) + IIF(!Empty(QRYIMG->GCY_LEIINT), QRYIMG->GCY_LEIINT, SPACE(LEN(QRYIMG->GCY_LEIINT))), oFont1, 100)
     oPrn:Say(nLin, 2700, ALLTRIM(HS_IniPadr("GA9",  1, QRYIMG->GCZ_CODCON, "GA9_NREDUZ",, .F.)) + "/" + ALLTRIM(SUBSTR(HS_IniPadr("GCM", 2, QRYIMG->GCZ_CODPLA, "GCM_DESPLA",, .F.),1,20)), oFont1, 100)  
     nLin += nEspLin                            
    Endif
    oPrn:Say(nLin, 050, HS_DTOC(STOD(QRYIMG->GHV_DATPRE),2), oFont2, 100)
    oPrn:Say(nLin, 325, QRYIMG->GHV_HORCRI, oFont2, 100)
    oPrn:Say(nLin, 890, ALLTRIM(HS_INIPADR("SRA", 11,QRYIMG->GHV_CODCRM, "RA_NOME",, .F.)) + " - CRM " + QRYIMG->GHV_CODCRM, oFont2, 100)
    nLin += nEspLin 
				oPrn:Line(nLin + 0030 , nColStart, nLin,  nColEnd)
    nLin += nEspLin   
    nLin := FS_CabItem(nLin)
    nLin += nEspLin/2 
				oPrn:Line(nLin + 0030 , nColStart, nLin,  nColEnd)
    nLin += nEspLin     
    nLin:= FS_ImpPreImg(nLin,, STOD(QRYIMG->GHV_DATPRE))
   Else  
    nLin += nEspLin
    nLin:= FS_ImpPreImg(nLin,, STOD(QRYIMG->GHV_DATPRE))
   Endif
  EndIf

  cRegate := QRYIMG->GCY_REGATE
  dDatPre := QRYIMG->GHV_DATPRE           
  DbSkip()
 
 EndDo
  DbClosearea()
Else //imprime matriz 
 oPrn:=TMSPrinter():New()
 oPrn:Setup()
	oPrn:SetLandscape()

 nEspLin	   :=   60   	             // espa็amento entre linha
 nMarSup	   :=  080   	             // margen superior
	nCol1 	   :=  030		               // margen da coluna1
 nCol2 	    :=  617		               // margen da coluna2
 nCol3 	    :=  817		               // margen da coluna3


 oPrn:StartPage()
 nLin 	  := nMarSup      // Linha inicial
 SetRegua(Len(aimp))
 For nCont:=1 to Len(aimp)
	 IncRegua()
   	 nItemPag++
  
  If nCont == 1
  	Titulo := ALLTRIM(Titulo) + " (" + ALLTRIM(aimp[nCont,21]) + ") - " +  ALLTRIM(aimp[nCont,20])
  EndIf
  
  If nLin > nHeiPag 
   		nLin 	   := nMarSup      // linha incial
		oPrn:EndPage()
		oPrn:StartPage() 
   		nLin := FS_CabecImp("0123", oPrn, nLenPag, NomeProg, Titulo, aimp[nCont,1])
   		nItemPag := 1
  Endif
  
  If nItemPag == 1
    
 	 nLin := FS_CabecImp("0123", oPrn, nLenPag, NomeProg, Titulo, aimp[nCont,1])
	  lCabec := .F.
			oPrn:Line(nLin + 0030 , nColStart, nLin,  nColEnd)
	  nLin += nEspLin
			oPrn:Say(nLin, 0050, aimp[nCont,1], oFont1, 100) // Num do Atendimento
			oPrn:Say(nLin, 0291, aimp[nCont,2], oFont1, 100) // Num do Prontuario
			oPrn:Say(nLin, 0541, SUBSTR(aimp[nCont,3],1,40), oFont1, 100) //Nome do Paciente
			oPrn:Say(nLin, 1180, SUBSTR(aimp[nCont,29],1,10), oFont1, 100) //Idade do Paciente
			oPrn:Say(nLin, 1360, HS_DTOC(aimp[nCont,8],2), oFont1, 100) //data Atend.
			oPrn:Say(nLin, 1650, aimp[nCont,6] + "-" + SUBSTR(HS_IniPadr("GCS",1,aimp[nCont,6],"GCS_NOMLOC"), 1, 30), oFont1, 100) //Setor de Atend.
			oPrn:Say(nLin, 2430, IIF(!Empty(aimp[nCont,4]), ALLTRIM(aimp[nCont,4]),SPACE(LEN(aimp[nCont,4]))) + "/" + IIF(!Empty(aimp[nCont,5]), aimp[nCont,5], SPACE(LEN(aimp[nCont,5]))), oFont1, 100) //Quarto / Leito
			oPrn:Say(nLin, 2700, ALLTRIM(POSICIONE("GA9",  1, XFILIAL("GA9") + HS_IniPadr("GCZ", 2, aimp[nCont,1]+"0", "GCZ_CODCON"), "GA9_NREDUZ")) + "/" + ALLTRIM(SUBSTR(HS_IniPadr("GCM",  2, HS_IniPadr("GCZ",  2, aimp[nCont,1]+"0", "GCZ_CODPLA",, .F.), "GCM_DESPLA",, .F.),1,20)) , oFont1, 100) //Convenio/Plano
   nLin += nEspLin 
			oPrn:Say(nLin, 0050, HS_DTOC(aimp[nCont,9],2), oFont2, 100) //Data Prescr.
			oPrn:Say(nLin, 0325, aimp[nCont,10], oFont2, 100) //Hora Prescr.
			oPrn:Say(nLin, 0890, ALLTRIM(HS_INIPADR("SRA", 11,aimp[nCont,7], "RA_NOME",, .F.)) + " - CRM " + aimp[nCont,7], oFont2, 100) //Medico da Presc.
   nLin += nEspLin 
			oPrn:Line(nLin + 0030 , nColStart, nLin,  nColEnd)//Preenche com _____
   nLin += nEspLin   
			nLin := FS_CabItem(nLin) //Monta o Cabe็alho dos Itens (Seq.|Tipo Obser|Apresent./Freq.|Regime|Diluente|Horarios)
   nLin += nEspLin/2 
			oPrn:Line(nLin + 0030 , nColStart, nLin,  nColEnd)
  Endif 
  nLin += nEspLin
		
		If nLin > nHeiPag
			nLin := nMarSup      // linha incial
			oPrn:EndPage()
			oPrn:StartPage()
			nLin := FS_CabecImp("0123", oPrn, nLenPag, NomeProg, Titulo, aimp[nCont,1])
			nItemPag := 1
			nLin := FS_ImpPreImg(nLin, nCont, aimp[nCont,9]) //Impressใo da Prescri็ใo dos itens
		Else
			nLin := FS_ImpPreImg(nLin, nCont, aimp[nCont,9]) //Impressใo da Prescri็ใo dos itens
		Endif
 next nCont

EndIf

oPrn:Preview()
oPrn:End()  

MS_FLUSH()

Return(Nil)

 // ************************************************
Static Function FS_ImpPreImg(nLin, nCont, dDatPre)
Local nHora     := 0
Local cImp     := "", cMin := ""
Local cHorIni  := "", cHorLim := ""
Local dDatIni  := "", dDatLim := ""
Local aCalcDat := {}
Local nEntreLin := 0030
Local nEntreLin1:= 0060
Local aRegs     := {}
Local aArea     := GetArea()
Local oItemFont := TFont():New("Courier New", 09, 10,, .F.,,,,,.F.) //Adendos Cabe็alho
Local cvar1:=""
Local nHeiPag 	:= 2300
Default nCont     := 0

nLin+=nEntreLin

If Empty(aimp)
 
	oPrn:Say(nLin, nColStart, QRYIMG->GHX_SEQITE, oItemFont, 100) //Seq.
	oPrn:Say(nLin, 150, ALLTRIM(SUBSTR(HS_RDescrB("GHX_TPITMP", QRYIMG->GHX_TIPO),1,13)), oItemFont, 100) //Observa็ใo
	//Monta a Apresenta็ใo do Item e a frequencia 
	cMntApre := FS_MNTDESC(QRYIMG->GHX_TIPO, QRYIMG->GHX_CDMEDI, QRYIMG->GHX_APRESE, QRYIMG->GFZ_DSFRQA, QRYIMG->GHX_VOLUME, QRYIMG->GFW_DESVIA, QRYIMG->GFY_DSMINF, QRYIMG->GHX_VELINF)
 
	If len(cMntApre)<=66
		oPrn:Say(nLin, 420, cMntApre , oItemFont, 100)
	Else
		cvar1:=SUBSTR(cMntApre,1,66)
		oPrn:Say(nLin, 420,cvar1, oItemFont, 100)
		oPrn:Say(nLin + nEntreLin, 420, SUBSTR(cMntApre,len(cvar1)+1,66) , oItemFont, 100)
		nLin+=nEntreLin
	Endif
	oPrn:Say(nLin, 1900, HS_RDescrB("GHX_IDREGI", QRYIMG->GHX_IDREGI), oItemFont, 100)//Tipo do regime
	oPrn:Say(nLin, 2210, QRYIMG->GHX_APRESD, oItemFont, 100)
   

	If len(cMntApre)<75
		oPrn:Say(nLin + nEntreLin, 150, QRYIMG->GHX_OBSREG, oItemFont, 100)
	Else
		oPrn:Say(nLin + nEntreLin1, 150, QRYIMG->GHX_OBSREG, oItemFont, 100)
		nLin+=nEntreLin
	Endif
 //monta horแrios  
  
	If QRYIMG->GHX_TIPO == "1"
  
		aCalcDat := HS_CALCDAT(dDatPre, QRYIMG->GHV_HORCRI, "+", ALLTRIM(STR(QRYIMG->GHX_DISPAR)+ ":00"))
   
		cHorIni  := aCalcDat[2]
		dDatIni  := aCalcDat[1]
		cHorLim  := aCalcDat[2]
		dDatLim  := aCalcDat[1]
 
		If QRYIMG->GFZ_UNFRQA =="M"
			If QRYIMG->GFZ_PEFRQA > 59
				cMin:= STRZERO((QRYIMG->GFZ_PEFRQA / 60),2)+"."+STRZERO((Mod(QRYIMG->GFZ_PEFRQA,60)*60),2)
			Else
				cMin:="00."+STRZERO(QRYIMG->GFZ_PEFRQA,2)
			EndIf
		Else
			cMin:= STRZERO(QRYIMG->GFZ_PEFRQA,2) +".00"
		EndIf

		While (dDatIni == dDatLim .And. cHorIni < "24:00") .Or. (dDatIni < dDatLim .And. cHorLim < cHorIni)
			AADD(aRegs,{cHorLim})
			aCalcDat := HS_CALCDAT(dDatLim, cHorLim, "+", cMin)
			cHorLim  := aCalcDat[2]
			dDatLim  := aCalcDat[1]
		End
 
		nColHor := 2400//2850
		For nHora:=1 to len(aRegs)
		
			If nLin >= nHeiPag
				
				nLin := nMarSup      // linha incial
				oPrn:EndPage()
				oPrn:StartPage()
				nLin := FS_CabecImp("0123", oPrn, nLenPag, NomeProg, Titulo, QRYIMG->GCY_REGATE)
				oPrn:Line(nLin + 0030 , nColStart, nLin,  nColEnd)
				nLin += nEspLin
				oPrn:Say(nLin, nColStart, QRYIMG->GCY_REGATE, oFont1, 100) // Num do Atendimento
				oPrn:Say(nLin, 291, QRYIMG->GCY_REGGER, oFont1, 100)
				oPrn:Say(nLin, 541, SUBSTR(QRYIMG->GCY_NOME,1,40), oFont1, 100)
				oPrn:Say(nLin, 1180, SUBSTR(QRYIMG->GCY_IDADE,1,10), oFont1, 100) //Idade do Paciente
				oPrn:Say(nLin, 1360, HS_DTOC(STOD(QRYIMG->GCY_DATATE),2), oFont1, 100)
				oPrn:Say(nLin, 1650,QRYIMG->GCY_CODLOC + "-" + SUBSTR(QRYIMG->GCS_NOMLOC, 1, 30), oFont1, 100)
				oPrn:Say(nLin, 2430, IIF(!Empty(QRYIMG->GCY_QUAINT), ALLTRIM(QRYIMG->GCY_QUAINT)+ "/" ,SPACE(LEN(QRYIMG->GCY_QUAINT))) + IIF(!Empty(QRYIMG->GCY_LEIINT), QRYIMG->GCY_LEIINT, SPACE(LEN(QRYIMG->GCY_LEIINT))), oFont1, 100)
				oPrn:Say(nLin, 2700, ALLTRIM(HS_IniPadr("GA9",  1, QRYIMG->GCZ_CODCON, "GA9_NREDUZ",, .F.)) + "/" + ALLTRIM(SUBSTR(HS_IniPadr("GCM", 2, QRYIMG->GCZ_CODPLA, "GCM_DESPLA",, .F.),1,20))  , oFont1, 100)
				nLin += nEspLin
				oPrn:Say(nLin, 050, HS_DTOC(STOD(QRYIMG->GHV_DATPRE),2), oFont2, 100)
				oPrn:Say(nLin, 325, QRYIMG->GHV_HORCRI, oFont2, 100)
				oPrn:Say(nLin, 890, ALLTRIM(HS_INIPADR("SRA", 11,QRYIMG->GHV_CODCRM, "RA_NOME",, .F.)) + " - CRM " + QRYIMG->GHV_CODCRM, oFont2, 100)
				nLin += nEspLin
				oPrn:Line(nLin + 0030 , nColStart, nLin,  nColEnd) //Preenche com _____
				nLin += nEspLin
				nLin := FS_CabItem(nLin) //Monta o Cabe็alho dos Itens (Seq.|Tipo Obser|Apresent./Freq.|Regime|Diluente|Horarios)
				nLin += nEspLin/2
				oPrn:Line(nLin + 0030 , nColStart, nLin,  nColEnd)
				nLin += nEspLin
				oPrn:Say(nLin, nColStart, QRYIMG->GHX_SEQITE, oItemFont, 100) //Seq.
				oPrn:Say(nLin, 150, ALLTRIM(SUBSTR(HS_RDescrB("GHX_TPITMP", QRYIMG->GHX_TIPO),1,13)), oItemFont, 100) //Observa็ใo
				//Monta a Apresenta็ใo do Item e a frequencia 
				cMntApre := FS_MNTDESC(QRYIMG->GHX_TIPO, QRYIMG->GHX_CDMEDI, QRYIMG->GHX_APRESE, QRYIMG->GFZ_DSFRQA, QRYIMG->GHX_VOLUME, QRYIMG->GFW_DESVIA, QRYIMG->GFY_DSMINF, QRYIMG->GHX_VELINF)
				
				If len(cMntApre)<=66
					oPrn:Say(nLin, 420, cMntApre , oItemFont, 100)
				Else
					cvar1:= SUBSTR(cMntApre,1,66)
					oPrn:Say(nLin, 420,cvar1, oItemFont, 100)
					oPrn:Say(nLin + nEntreLin, 420, SUBSTR(cMntApre,len(cvar1)+1,66) , oItemFont, 100)
					nLin += nEntreLin
				Endif
				oPrn:Say(nLin, 1900, HS_RDescrB("GHX_IDREGI", QRYIMG->GHX_IDREGI), oItemFont, 100)//Tipo do regime
				oPrn:Say(nLin, 2210, QRYIMG->GHX_APRESD, oItemFont, 100)
				
				If len(cMntApre)<75
					oPrn:Say(nLin + nEntreLin, 150, QRYIMG->GHX_OBSREG, oItemFont, 100)
				Else
					oPrn:Say(nLin + nEntreLin1, 150, QRYIMG->GHX_OBSREG, oItemFont, 100)
					nLin += nEntreLin
				Endif
				
			Endif
				
			If Len(cImp) > 28
				oPrn:Say(nLin + 0030, nColHor, cImp, oItemFont, 100)
				nLin+=nEntreLin
				cImp:= aRegs[nHora][1]
			Else
				IIf(Len(cImp)=0,(cImp:= aRegs[nHora][1]),(cImp+= "/" + aRegs[nHora][1]))
				If nHora==Len(aRegs)
					oPrn:Say(nLin + 0030, nColHor, cImp, oItemFont, 100)
					nLin+=nEntreLin
					cImp := ""
				EndIf
			EndIf
		Next
	Endif
Else
 
	oPrn:Say(nLin, nColStart, aimp[nCont,11] + Iif(!empty(aimp[nCont,28]),"S",""), oItemFont, 100)	//Seq.
	oPrn:Say(nLin, 150, ALLTRIM(SUBSTR(HS_RDescrB("GHX_TPITMP", aimp[nCont,12]),1,13)), oItemFont, 100)	//Tipo Observa็ใo
	//Monta a Apresenta็ใo do Item e a frequencia
	cMntApre := FS_MNTDESC(aimp[nCont,12], aimp[nCont,27], aimp[nCont,13], aimp[nCont,16], aimp[nCont,23], aimp[nCont,24], aimp[nCont,26], aimp[nCont,25]) //Apresenta็ใo / Frequencia
 
	If len(cMntApre)<=66
		oPrn:Say(nLin, 420, cMntApre , oItemFont, 100)
	Else
		cvar1:=SUBSTR(cMntApre,1,66)
		oPrn:Say(nLin, 420,cvar1, oItemFont, 100)
		oPrn:Say(nLin + nEntreLin, 420, SUBSTR(cMntApre,len(cvar1)+1,66) , oItemFont, 100)
		nLin+=nEntreLin
	Endif

	oPrn:Say(nLin, 1900, HS_RDescrB("GHX_IDREGI", aimp[nCont,17]), oItemFont, 100) //Tipo do Regime
	oPrn:Say(nLin, 2210, SUBSTR(aimp[nCont,14],1,40) , oItemFont, 100)

	If len(cMntApre)<75
		oPrn:Say(nLin + nEntreLin, 150, aimp[nCont,22], oItemFont, 100)
	Else
		oPrn:Say(nLin + nEntreLin1, 150, aimp[nCont,22], oItemFont, 100)
		nLin+=nEntreLin
	Endif
	//Monta os Horแrios
	If aimp[nCont,12] == "1"

		cSql := "SELECT GFZ.GFZ_UNFRQA, GFZ.GFZ_PEFRQA "
		cSQL += "FROM " + RetSQLName("GFZ") + " GFZ "
		cSQL += "WHERE GFZ.GFZ_CDFRQA = '" +aimp[nCont,19] + "' AND GFZ.GFZ_FILIAL = '" + xFilial("GFZ") + "' AND GFZ.D_E_L_E_T_ <> '*' "
		cSQL :=  ChangeQuery(cSQL)
		
		TCQUERY cSQL NEW ALIAS "FRQ"
		DbSelectArea("FRQ")
		DbGoTop()
		  
		  //monta horแrios
		aCalcDat := HS_CALCDAT(dDatPre, aimp[nCont,10], "+", ALLTRIM(STR(aimp[nCont,18])+ ":00"))
		   
		cHorIni  := aCalcDat[2]
		dDatIni  := aCalcDat[1]
		cHorLim  := aCalcDat[2]
		dDatLim  := aCalcDat[1]
		 
		If FRQ->GFZ_UNFRQA =="M"
			If FRQ->GFZ_PEFRQA > 59
				cMin:= STRZERO((FRQ->GFZ_PEFRQA / 60),2)+"."+STRZERO((Mod(FRQ->GFZ_PEFRQA,60)*60),2)
			Else
				cMin:="00."+STRZERO(FRQ->GFZ_PEFRQA,2)
			EndIf
		Else
			cMin:= STRZERO(FRQ->GFZ_PEFRQA,2) +".00"
		EndIf
		
		While (dDatIni == dDatLim .And. cHorIni < "24:00") .Or. (dDatIni < dDatLim .And. cHorLim < cHorIni )
			AADD(aRegs,{cHorLim})
			aCalcDat := HS_CALCDAT(dDatLim, cHorLim, "+",cMin)
			cHorLim  := aCalcDat[2]
			dDatLim  := aCalcDat[1]
		End
 
		nColHor := 2400//2600//2850
		For nHora:=1 to len(aRegs)
		
			If nLin >= nHeiPag
				
				nLin := nMarSup      // linha incial
				oPrn:EndPage()
				oPrn:StartPage()
				nLin := FS_CabecImp("0123", oPrn, nLenPag, NomeProg, Titulo, aimp[nCont,1])
				oPrn:Line(nLin + 0030 , nColStart, nLin,  nColEnd)
				nLin += nEspLin
				oPrn:Say(nLin, nColStart, aimp[nCont,1], oFont1, 100) // Num do Atendimento
				oPrn:Say(nLin, 0291, aimp[nCont,2], oFont1, 100) // Num do Prontuario
				oPrn:Say(nLin, 0541, SUBSTR(aimp[nCont,3],1,40), oFont1, 100) //Nome do Paciente
				oPrn:Say(nLin, 1180, SUBSTR(aimp[nCont,29],1,10), oFont1, 100) //Idade do Paciente
				oPrn:Say(nLin, 1360, HS_DTOC(aimp[nCont,8],2), oFont1, 100) //data Atend.
				oPrn:Say(nLin, 1650, aimp[nCont,6] + "-" + SUBSTR(HS_IniPadr("GCS",1,aimp[nCont,6],"GCS_NOMLOC"), 1, 30), oFont1, 100) //Setor de Atend.
				oPrn:Say(nLin, 2430, IIF(!Empty(aimp[nCont,4]), ALLTRIM(aimp[nCont,4]),SPACE(LEN(aimp[nCont,4]))) + "/" + IIF(!Empty(aimp[nCont,5]), aimp[nCont,5], SPACE(LEN(aimp[nCont,5]))), oFont1, 100) //Quarto / Leito
				oPrn:Say(nLin, 2700, ALLTRIM(POSICIONE("GA9",  1, XFILIAL("GA9") + HS_IniPadr("GCZ", 2, aimp[nCont,1]+"0", "GCZ_CODCON"), "GA9_NREDUZ")) + "/" + ALLTRIM(SUBSTR(HS_IniPadr("GCM",  2, HS_IniPadr("GCZ",  2, aimp[nCont,1]+"0", "GCZ_CODPLA",, .F.), "GCM_DESPLA",, .F.),1,20)) , oFont1, 100) //Convenio/Plano
				nLin += nEspLin
				oPrn:Say(nLin, 0050, HS_DTOC(aimp[nCont,9],2), oFont2, 100) //Data Prescr.
				oPrn:Say(nLin, 0325, aimp[nCont,10], oFont2, 100) //Hora Prescr.
				oPrn:Say(nLin, 0890, ALLTRIM(HS_INIPADR("SRA", 11,aimp[nCont,7], "RA_NOME",, .F.)) + " - CRM " + aimp[nCont,7], oFont2, 100) //Medico da Presc.
				nLin += nEspLin
				oPrn:Line(nLin + 0030 , nColStart, nLin,  nColEnd) //Preenche com _____
				nLin += nEspLin
				nLin := FS_CabItem(nLin) //Monta o Cabe็alho dos Itens (Seq.|Tipo Obser|Apresent./Freq.|Regime|Diluente|Horarios)
				nLin += nEspLin/2
				oPrn:Line(nLin + 0030 , nColStart, nLin,  nColEnd)
				nLin += nEspLin

				oPrn:Say(nLin, nColStart, aimp[nCont,11] + Iif(!empty(aimp[nCont,28]),"S",""), oItemFont, 100)	//Seq.
				oPrn:Say(nLin, 150, ALLTRIM(SUBSTR(HS_RDescrB("GHX_TPITMP", aimp[nCont,12]),1,13)), oItemFont, 100)	//Tipo Observa็ใo
				//Monta a Apresenta็ใo do Item e a frequencia
				cMntApre := FS_MNTDESC(aimp[nCont,12], aimp[nCont,27], aimp[nCont,13], aimp[nCont,16], aimp[nCont,23], aimp[nCont,24], aimp[nCont,26], aimp[nCont,25]) //Apresenta็ใo / Frequencia
				
				If len(cMntApre)<=66
					oPrn:Say(nLin, 420, cMntApre , oItemFont, 100)
				Else
					cvar1 := SUBSTR(cMntApre,1,66)
					oPrn:Say(nLin, 420,cvar1, oItemFont, 100)
					oPrn:Say(nLin + nEntreLin, 420, SUBSTR(cMntApre,len(cvar1)+1,66) , oItemFont, 100)
					nLin += nEntreLin
				Endif
				oPrn:Say(nLin, 1900, HS_RDescrB("GHX_IDREGI", aimp[nCont,17]), oItemFont, 100) //Tipo do Regime
				oPrn:Say(nLin, 2210, SUBSTR(aimp[nCont,14],1,40) , oItemFont, 100)
				
				If len(cMntApre)<75
					oPrn:Say(nLin + nEntreLin, 150, aimp[nCont,22], oItemFont, 100)
				Else
					oPrn:Say(nLin + nEntreLin + 30, 150, aimp[nCont,22], oItemFont, 100)
					nLin += nEntreLin
				Endif
			Endif
			
			If Len(cImp) > 28
				oPrn:Say(nLin + 30, nColHor, cImp, oItemFont, 100)
				nLin+=nEntreLin
				cImp:= aRegs[nHora][1]
			Else
				IIf(Len(cImp)=0,(cImp:= aRegs[nHora][1]),(cImp+= "/" + aRegs[nHora][1]))
				If nHora==Len(aRegs)
					oPrn:Say(nLin + 30, nColHor, cImp, oItemFont, 100)
					nLin+=nEntreLin
					cImp := ""
				EndIf
			EndIf
		Next nHora
		DbCloseArea()
	Endif
	aRegs:={}
 

EndIf
aRegs:={}
RestArea(aArea)
Return(nLin)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_CabGrafบAutor  ณAndr้ Cruz          บ Data ณ  09/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Impressใo de cabe็alho grแfico                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ HS_CABGRAF(oTMSPinter, nLenPag, cNomeFunct, nColTit,      บฑฑ
ฑฑบ          ณ             cTitulo)                                      บฑฑ
ฑฑบ          ณ oTMSPrinter -> Objeto TMSPrinte instanciado.               บฑฑ
ฑฑบ          ณ nLenPag     -> Largura da Pแgina.                          บฑฑ
ฑฑบ          ณ cNomeFunct  -> Nome do programa.                           บฑฑ
ฑฑบ          ณ nColTit     -> Coluna onde o tํtulo do relat๓rio serแ      บฑฑ
ฑฑบ          ณ                impresso.                                   บฑฑ
ฑฑบ          ณ cTitulo     -> Tํtulo do relat๓rio.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function HS_CabGraf(oPrn, nLenPag, cNomeFunc, nColTit, cTitulo, lCertDig)
Local cEmpLogo   := "system\lgrl" + Lower(Iif( FindFunction("FWGRPCompany"),FWGRPCompany(), SM0->M0_CODIGO )) + ".bmp"

Local nLin1      := 0050
Local nLin2      := 0100
Local nLin3      := 0150
Local nLinTit    := 0080

Local oCabFont1  := TFont():New("Courier New", 13, 11,, .T.,,,,,.F.) //cTitulos dos Relat๓rio
Local oCabFont2  := TFont():New("Courier New", 11, 09,, .F.,,,,,.F.) //Adendos Cabe็alho

Default nColTit    := 0800
Default lCertDig   := .F.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Certificado digital tem linhas iniciais diferenciadas                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lCertDig
	nLin1   := 0150
	nLinTit := 0150   
	nLin3   := 0175
EndIf

oPrn:Line(nLin1-40, nColStart, nLin1-40,  nColEnd)

If File(cEmpLogo)
 oPrn:SayBitmap(nLin1-40, nColStart, cEmpLogo, 0300, 0080)
Else
 oPrn:Say(nLin1, nColStart, Iif( FindFunction("FWFilialName"),  FWFilialName(),SM0->M0_NOME), oCabFont2, 100)
EndIf

oPrn:Say(nLin2, nColStart, "SIGA/" + AllTrim(cNomeFunc) + "/v." + cVersao, oCabFont2, 100)
oPrn:Say(nLin3, nColStart, Time(), oCabFont2, 100)
oPrn:Say(nLinTit, 800, cTitulo, oCabFont1, 100)
oPrn:Say(nLin1, nColEnd - 0805, Padl(STR0019 + AllTrim(Str(m_pag++))	, 20), oCabFont2, 100) //"Pแgina:   " //"Pแgina:   "
oPrn:Say(nLin2, nColEnd - 0805, Padl(STR0020 + DToC(dDataBase)			, 20), oCabFont2, 100) //"Dt. Ref.: " //"Dt. Ref.: "
oPrn:Say(nLin3, nColEnd - 0805, Padl(STR0021 + DToC(Date())		 	 	, 20), oCabFont2, 100) //"Emissใo:  " //"Emissใo:  "
oPrn:Line(0200, nColStart, 0200,  nColEnd)

Return 0250
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Cabec  บAutor  ณMicrosiga           บ Data ณ  09/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprssใo do cabe็alho do relat๓rio HSPAHR22                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_CabecImp(cAtendim, oPrn, nLenPag, cNomeProg, cTitulo, cRegate,lCertDig)
Local nLin       	:= 0
Local nEntreLin  	:= 30
Local nColBar   	:= (0019  / 1)	//Numero da coluna em centimentros 0
Local nLargBar  	:= (0.025 / 1)	//Numero do Tamanho da barra em centimetros  0.025 1/3 M/mm
Local nAltuBar  	:= (001.1 / 1)	//Numero da Altura da barra em milimetros    1.5
Local cTipoBar   	:= "CODE128"
Local lDigBar	   	:= .F.
Local lHoriBar   	:= Nil
Local lBanbar	   	:= .T.  
Local nLinBar		:= (0.60 / 1)
Local cCorBar	   	:= Nil 
Local cFonBar	   	:= Nil
Local cModBar	   	:= Nil
Local cPaciente 	:= STR0024
Local cIdade 		:= STR0042
Default lCertDig   := .F.  

nLin := HS_CabGraf(oPrn, nLenPag, cNomeProg, 0800, cTitulo, lCertDig)
If lCertDig
	nAltuBar := 0.60 / nTipoImp
	nColBar  := 55 / nTipoImp  //10  
	nLinBar  := 1.30 / nTipoImp   
	oPrn:FWMSBar(cTipoBar,nLinBar,nColBar,cRegate,oPrn,lDigBar,cCorBar,lHOriBar,nLargBar,nAltuBar,lBanbar,cFonBar,cModBar,.F.)
Else
	MSBAR(cTipoBar,nLinBar,nColBar,cRegate,oPrn,lDigBar,cCorBar,lHOriBar,nLargBar,nAltuBar,lBanbar,cFonBar,cModBar,.F.)	
Endif
oPrn:Say(nLin, 0050, STR0022, oFont, 100) //"Atendimento"
oPrn:Say(nLin, 0291, STR0023, oFont, 100) //"Prontuario"
oPrn:Say(nLin, 0541, cPaciente, oFont, 100) //"Paciente"
oPrn:Say(nLin, 1200, cIdade, oFont, 100) //"Idade"
oPrn:Say(nLin, 1360, STR0025, oFont, 100)//"Dat. Atend."  
oPrn:Say(nLin, 1650, STR0026, oFont, 100) //"Setor"
oPrn:Say(nLin, 2430, STR0027, oFont, 100) //"Quarto/Leito"
oPrn:Say(nLin, 2700, STR0028, oFont, 100)  //"Convenio/Plano"
nLin += nEntreLin 
oPrn:Say(nLin, 0050, STR0029, oFont, 100) //"Dat. Presc."
oPrn:Say(nLin, 0325, STR0030, oFont, 100) //"Hora Presc."
oPrn:Say(nLin, 0890, STR0031, oFont, 100) //"Medico da Prescricao"
nLin += nEntreLin 

Return(nLin)     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CabItemบAutor  ณMicrosiga           บ Data ณ  11/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprssใo do cabe็alho dos itens    HSPAHR22                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_CabItem(nLin)
oPrn:Say(nLin, 0050, STR0032, oFont, 100) //"Seq."
oPrn:Say(nLin, 0170, STR0033, oFont, 100) //"Tipo"
oPrn:Say(nLin, 0440, STR0034 + "/" + STR0035, oFont, 100) //"Apresentacao"
 oPrn:Say(nLin, 1920, STR0036, oFont, 100) //"Regime"        
 oPrn:Say(nLin, 2230, STR0037, oFont, 100) //"Diluente"        
oPrn:Say(nLin, 2750, STR0038, oFont, 100) //"Horarios"
 nLin += 30
 oPrn:Say(nLin, 170, ALLTRIM(STR0039), oFont, 100) //"Observa็ใo"
Return(nLin)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MntDescบAutor  ณMario Arizono       บ Data ณ  25/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Montagem apresentacao/frequencia                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_MNTDESC(cTipo, cCdMedi, cAprese, cDsfrqa, nVolume, cDesvia, cDsminf, cVelInf)
 Local cDescri := "", cVolume := "" 
 Local aArea   := GetArea()
 Local nTam1    := 0
 Local nTam2    := 132
 
 cAprese := IIF(!Empty(cAprese), ", " +ALLTRIM(SUBSTR(cAprese, 1, 40)), "") 
 cVolume := IIF(nVolume > 0, ", " + ALLTRIM(STR(nVolume)), "")
 cDsfrqa := IIF(!Empty(cDsfrqa), ", " + ALLTRIM(cDsfrqa) , "")
 cDesvia := IIF(!Empty(cDesvia), ", " + ALLTRIM(cDesvia) , "")    
 cVelInf := IIF(!Empty(cVelInf), ", " + ALLTRIM(cVelInf) , "")
 cDsminf := IIF(!Empty(cDsminf), ", " + ALLTRIM(cDsminf) , "")    
 
 cDescri :=  cAprese + cVolume + cDsfrqa + cDesvia + cVelInf + cDsMinf
 nTam1 := Len(cDescri)
 
 cCdMedi := IIF(!Empty(cCdMedi), ALLTRIM(SUBSTR(HS_PREITEM(cTipo, cCdMedi, .F.), 1, nTam2-nTam1)), "")
 cDescri := cCdMedi + cDescri

RestArea(aArea) 

Return(cDescri)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณrelDigCertบAutor  ณTotvs               บ Data ณ  14/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relat๓rio impresso via pdf para certifica็ใo digital       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function relDigCert(aImp,lAssLote,aGuiasLote) 

Local oFont      := TFont():New("Courier New", 11, 09,, .T.,,,,,.F.) //Titulos dos Campos
Local nHeiPag    := 2200 //3200
Local nLin       := nHeiPag + 1 
Local nCont      := 0
LOCAL cFileName := "GCY"+GHV->GHV_REGATE+"GHV"+GHV->GHV_SEQPRE
LOCAL cPathSrv  := PLSMUDSIS("\certificados\prescricao\")
Local cNameCert := "DLLAssinaturaDigital.dll"

Private lCabec     := .T. 
Private oFont1 := TFont():New( "Courier New", 09, 08, , .T., , , , , .F. ) //Conteudo dos Campos
Private oFont2 := TFont():New( "Courier New", 09, 08, , .T., , , , , .F. ) //Conteudo dos Campos em Negrito
Private nLinF  := 260
Private oPrn        

Default lAssLote := .F.

nTipoImp := 1
nLenPag  := 3250
nColEnd  := nLenPag - 0050  

If MakeDir(PLSMUDSIS("\certificados")) == 3
   MsgInfo(STR0041+"'\certificados\'")//"Nใo foi possํvel criar o diret๓rio "
   Return
EndIf

If MakeDir(PLSMUDSIS("\certificados\prescricao\")) == 3
   MsgInfo(STR0041+"'\certificados\prescricao\'") //"Nใo foi possํvel criar o diret๓rio "
   Return
EndIf


nH   := PLSAbreSem("HSPR22SMF.SMF")
oPrn := FWMSPrinter():New(cFileName,IMP_PDF,.T.,cPathSrv,.T.,.F.,@oPrn,,.T.,.F.,.F.,.T.)
PLSFechaSem(nH,"HSPR22SMF.SMF")

nEspLin	   :=   60   	             // Espacamento entre linha
nMarSup	   :=  150   	             // Margem superior
nCol1 	   :=  015		             // Margem da coluna1
nCol2 	   :=  617		             // Margem da coluna2
nCol3 	   :=  817		             // Margem da coluna3
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Resolucao do relatorio                                                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPrn:setResolution(72)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Modo paisagem                                                                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPrn:setLandscape()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Papel A4                                                                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPrn:setPaperSize(TAM_A4)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Margem                                                                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPrn:setMargin(05,05,05,05) 

If lAssLote .And. GetNewPar("MV_HSCDPDF","0") <> "1"
	oPrn:SetViewPDF(.F.)
EndIf  

oPrn:StartPage()     

nLin 	  := nMarSup      // Linha inicial

For nCont := 1 to Len(aImp)
	
	If nCont == 1
		Titulo := ALLTRIM(Titulo) + " (" + ALLTRIM(aImp[nCont,21]) + ") - " +  ALLTRIM(aImp[nCont,20])
	EndIf
	
	If nLin > nHeiPag
		nLin 	   := nMarSup      // linha incial
		oPrn:EndPage()
		oPrn:StartPage()
		nLin := FS_CabecImp("0123", oPrn, nLenPag, NomeProg, Titulo, aImp[nCont,1],.T.)
	Endif
	
	If nCont == 1
		
		nLin := FS_CabecImp("0123", oPrn, nLenPag, NomeProg, Titulo, aImp[nCont,1],.T.)
		lCabec := .F.
				
		oPrn:Say(nLin, nCol1, Repl("_", 250), oFont)
		nLin += nEspLin
		oPrn:Say(nLin, 050, aImp[nCont,1], oFont1) 
		oPrn:Say(nLin, 291, aImp[nCont,2], oFont1)   
		oPrn:Say(nLin, 541, SUBSTR(aImp[nCont,3],1,40), oFont1)
		oPrn:Say(nLin, 1360, HS_DTOC(aImp[nCont,8],2), oFont1)
		oPrn:Say(nLin, 1650,aImp[nCont,6] + "-" + SUBSTR(HS_IniPadr("GCS",1,aImp[nCont,6],"GCS_NOMLOC"), 1, 30), oFont1)
		oPrn:Say(nLin, 2430, IIF(!Empty(aImp[nCont,4]), ALLTRIM(aImp[nCont,4]),SPACE(LEN(aImp[nCont,4]))) + "/" + IIF(!Empty(aImp[nCont,5]), aImp[nCont,5], SPACE(LEN(aImp[nCont,5]))), oFont1)
		oPrn:Say(nLin, 2700, ALLTRIM(POSICIONE("GA9",  1, XFILIAL("GA9") + HS_IniPadr("GCZ", 2, aImp[nCont,1]+"0", "GCZ_CODCON"), "GA9_NREDUZ")) + "/" + ALLTRIM(SUBSTR(HS_IniPadr("GCM",  2, HS_IniPadr("GCZ",  2, aImp[nCont,1]+"0", "GCZ_CODPLA",, .F.), "GCM_DESPLA",, .F.),1,20)) , oFont1)
		nLin += nEspLin
		oPrn:Say(nLin, 050, HS_DTOC(aImp[nCont,9],2), oFont2)
		oPrn:Say(nLin, 325, aImp[nCont,10], oFont2)
		oPrn:Say(nLin, 890, ALLTRIM(HS_INIPADR("SRA", 11,aImp[nCont,7], "RA_NOME",, .F.)) + " - CRM " + aImp[nCont,7], oFont2)
		nLin += nEspLin
		oPrn:Say(nLin, nCol1, Repl("_", 250), oFont)
		nLin += nEspLin
		nLin := FS_CabItem(nLin)
		nLin += nEspLin/2
		oPrn:Say(nLin, nCol1, Repl("_", 250), oFont) 
	Endif
	nLin += nEspLin
   	nLin := FS_ImpPreImg(nLin, nCont, aImp[nCont,9])
	
next nCont  
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Deleta arquivo se ja existente  									        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
FERASE(GetTempPath()+"totvsprinter\"+cFileName+".pdf") 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Gera o relatorio   													        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
oPrn:Preview()     
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Chama rotina para ceritificar o arquivo gerado						        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
If lAssLote
	Aadd(aGuiasLote,{GetTempPath()+"totvsprinter\"+cFileName+".pdf",cFileName+".pdf",GHV->GHV_CODCRM})
Else
	HSCertDig("2",cFileName)  
EndIf

Return(nil)
