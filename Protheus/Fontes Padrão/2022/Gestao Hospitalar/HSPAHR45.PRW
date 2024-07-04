#INCLUDE "HSPAHR45.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR45 บ Autor ณ Mario Arizono      บ Data ณ  10/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio Pacote X Faturamento Conta Aberta                บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR45()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3 := STR0003 //"Pacote X Faturamento Conta Aberta"
 Local aOrd   := {}
 
 Private Titulo      := cDesc3
 Private Cabec1      := ""
 Private Cabec2      := ""
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 220
 Private Tamanho     := "G"
 Private NomeProg    := "HSPAHR45" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := {STR0004 , 1, STR0005, 2, 2, 1, "", 1}     //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := NomeProg
 Private nTam        := 220 
 Private cPerg       := "HSPR45"
 Private cCodConDe   := "", cCodConAte := "", cPacoteDe := "", cPacoteAte := "", dPerInic := "", dPerFinal := "", nTipoRel := 0, nSlPagCon := 0

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ PARAMETROS                                                         ณ
  ณ MV_PAR01	Do Convenio                                               ณ
  ณ MV_PAR02	Ate o Convenio                                            ณ
  ณ MV_PAR03	Do pacote                                                 ณ
  ณ MV_PAR04	Ate o pacote                                              ณ 
  ณ MV_PAR05	Do periodo inicial atendimento                            ณ
  ณ MV_PAR06	Ate o periodo final atendimento                           ณ
  ณ MV_PAR07	Tipo Relatorio : Analit/Sintet                            ณ
  ณ MV_PAR08	Salta pagina convenio : S/N                               ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */
 
 If !Pergunte(cPerg,.T.)
  return
 EndIf

 cCodConDe   := MV_PAR01
 cCodConAte  := MV_PAR02
 cPacoteDe   := MV_PAR03
 cPacoteAte  := MV_PAR04
 dPerInic    := MV_PAR05
 dPerFinal   := MV_PAR06
 nTipoRel    := MV_PAR07
 nSlPagCon   := MV_PAR08

 
 nMaxLin := HS_MaxLin(cCODIMP)

 //                    1         2         3         4         5         6         7         8         9        10        11        12        13        14         15        16        17        18        19        20        21        22
 //          0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.
 If nTipoRel == 1
  Cabec1 := STR0006 //"Atend.  Paciente                                 Dat. Ent.  Hor. Ent.  Dat. Sai.  Hor. Sai.  Guia                    Con. Prev. Aber.         Aberto  +    Fat. Pacote   =           Total        Diferen็a              %"
 Else
  Cabec1 := STR0007 //"Pacote                                                                                                               Con. Prev. Aber.         Aberto  +    Fat. Pacote   =           Total        Diferen็a              %"
 Endif

 titulo += "-" + IIF(nTipoRel == 1, STR0008, STR0009) //"Analํtico"###"Sint้tico"
  
 wnrel := SetPrint("", NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif

 SetDefault(aReturn, "")
 If nLastKey == 27
  Return()
 Endif

 nTipo := If(aReturn[4]==1,15,18)
 RptStatus({|| RunReport("") }, Titulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Mario Arizono      บ Data ณ  10/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()
 Local   cSql       := ""
 Local aVetPac      := {}
 Local    nPos      := 0, nPosPac := 0, nValGds := 0, nValGes := 0, nValDif := 0, nValTot := 0, nValPer  
 Local nTotPac      := 0, nTotCon := 0, nTotGer := 0
 Local cCodCon      := "", cCodPct := ""
 Private nPacCPrev := 0,  nPacCAber  := 0, nPacFatPac := 0, nPacTotal := 0, nPacDifer := 0
 Private nConCPrev := 0,  nConCAber  := 0, nConFatPac := 0, nConTotal := 0, nConDifer := 0
 Private nTotCPrev := 0,  nTotCAber  := 0, nTotFatPac := 0, nTotGeral := 0, nTotDifer := 0
 Private nLin       := nMaxLin * 2

 
 cSQL := "SELECT GE7.GE7_CODDES QRY_CODDES,SUM(" + HS_FVALDES("GE7") + ") QRY_VALPAC, GCZ.GCZ_REGATE QRY_REGATE, GCZ.GCZ_NRSEQG QRY_NRSEQG, "
 cSQL += "GCZ.GCZ_REGGER QRY_REGGER, GCZ.GCZ_NOME QRY_NOME, GCZ.GCZ_CODCON QRY_CODCON, GCY.GCY_DATATE QRY_DATATE, GCZ.GCZ_NRGUIA QRY_NRGUIA, "
 cSQL += "GCY.GCY_HORATE QRY_HORATE, GCY.GCY_DATALT QRY_DATALT, GCY.GCY_HORALT QRY_HORALT, GA9.GA9_NREDUZ QRY_NOMCON, GA7.GA7_DESC QRY_DESPRO " 
 cSQL += " FROM " + RetSQLName("GE7") + " GE7"
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GE7.GE7_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 
 IF !Empty(cCodConAte) //Filtra o convenio
  cSQL += " AND GCZ_CODCON BETWEEN '" + cCodConDe  + "' AND '" +  cCodConAte + "' " 
 ElseIf !Empty(cCodConDe) //Filtra o convenio
  cSQL += " AND GCZ.GCZ_CODCON >= '" + cCodConDe  + "'"
 EndIf 
 
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 
 If !Empty(dPerFinal) // Filtra data do atendimento
  cSQL += " AND GCY.GCY_DATATE BETWEEN '"  + DToS(dPerInic) + "' AND '" + DToS(dPerFinal) + "'"
 Else
  cSQL += " AND GCY.GCY_DATATE >= '" + DToS(dPerFinal) + "'"  
 Endif 
 
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' " 
 cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GE7.GE7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' " 
 cSQL += " WHERE "
 cSQL += " GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' "
 
 IF !Empty(cPacoteAte) //Filtra o Pacote  
  cSQL += " AND GE7_CODDES BETWEEN '" + cPacoteDe  + "' AND '" +  cPacoteAte + "' " 
 ElseIf !Empty(cPacoteDe) //Filtra o Pacote  
  cSQL += " AND GE7.GE7_CODDES >= '" + cPacoteDe  + "'"
 EndIf
 
 cSQL += " AND GA7.GA7_TIPPRO = '9' "
 cSQL += " AND NOT EXISTS (SELECT GE71.GE7_CODDES FROM " + RetSQLName("GE7") + " GE71 "
 cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GE71.GE7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' " 
	cSQL += "											          WHERE GE71.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE71.D_E_L_E_T_ <> '*' AND GE71.GE7_NRSEQG = GE7.GE7_NRSEQG "
	cSQL += "											          AND GE71.GE7_CODDES <> GE7.GE7_CODDES AND GA7.GA7_TIPPRO = '9') "
 cSQL += " GROUP BY GE7.GE7_CODDES, GCZ.GCZ_REGATE, GCZ.GCZ_NRSEQG, GCZ.GCZ_REGGER, GCZ.GCZ_NOME, GCZ.GCZ_CODCON, GCY.GCY_DATATE, " 
 cSQL += " GCZ.GCZ_NRGUIA, GCY.GCY_HORATE, GCY.GCY_DATALT, GCY.GCY_HORALT, GA9.GA9_NREDUZ, GA7.GA7_DESC "
 cSQL += " ORDER BY QRY_CODCON, QRY_CODDES, QRY_NRSEQG"

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 
 DbGoTop()
 If Eof()
  HS_MsgInf(STR0010, STR0011, STR0012)  //"Nenhum dado foi encontrado para a selecao efetuada."###"Aten็ใo"###"Execu็ใo do relat๓rio"
  DbCloseArea()
  Return()
 Endif 
 
 While !EOF()  
 	If lAbortPrint
			@nLin, 000 PSAY STR0013 //"*** CANCELADO PELO OPERADOR ***"
			Exit
		EndIf
		
		 	nValGds := FS_TOTDES("GD", QRY->QRY_NRSEQG)
			 nValGes := FS_TOTDES("GE", QRY->QRY_NRSEQG, QRY->QRY_CODDES )
			 nValTot := nValGes + QRY->QRY_VALPAC
			 nValDif := nValTot - nValGds
				nValPer := (nValDif/nValGds)*100
		
  	If (nPos := IIF(nTipoRel == 1, aScan(aVetPac, {|aVetPac| aVetPac[1] == QRY->QRY_CODCON .And. aVetPac[3] == QRY->QRY_NRSEQG .And. ;
				aVetPac[4] == QRY->QRY_CODDES }), aScan(aVetPac, {|aVetPac| aVetPac[1] == QRY->QRY_CODCON .And. aVetPac[4] == QRY->QRY_CODDES})) ) == 0
							
				AADD(aVetPac,{;
				 QRY->QRY_CODCON,;               //[1]  Convenio
				 QRY->QRY_NOMCON,;               //[2]  Nome Convenio         
				 QRY->QRY_NRSEQG,;               //[3]  Sequencial da guia              
				 QRY->QRY_CODDES,;               //[4]  Codigo da despesa           
				 QRY->QRY_DESPRO,;               //[5]  Nome da despesa  
				 QRY->QRY_NRGUIA,;               //[6]  Numero da guia          
				 QRY->QRY_REGATE,;               //[7]  Registro de atendimento
				 QRY->QRY_REGGER,;               //[8]  Codigo do paciente
				 QRY->QRY_NOME  ,;               //[9]  Nome Paciente
				 DTOC(STOD(QRY->QRY_DATATE)),;   //[10]  Data Atendimento
				 QRY->QRY_HORATE,;               //[11] Hora Atendimento
				 DTOC(STOD(QRY->QRY_DATALT)),;  //[12] Data Alta         
 				QRY->QRY_HORALT,;               //[13] Hora Alta        
				 nValGds        ,;               //[14] Conta Previa Aberta
				 nValGes        ,;               //[15] Faturado em Aberto          
				 QRY->QRY_VALPAC,;               //[16] Faturado Pacote
				 nValTot        ,;               //[17] Total = Faturado Aberto + Pacote
				 nValDif        ,;               //[18] Diferenca = faturado total - conta previa
 			 nValPer})                       //[19] %                  
			Else
				aVetPac[nPos,14] += nValGds
				aVetPac[nPos,15] += nValGes          
				aVetPac[nPos,16] += QRY->QRY_VALPAC
   	aVetPac[nPos,17] += nValTot
  		aVetPac[nPos,18] += nValDif
  		aVetPac[nPos,19] := (	aVetPac[nPos,18]/	aVetPac[nPos,14])*100          
			EndIf 
      
  DbSkip()
 End  
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 SetRegua(len(aVetPac))
 
 For nPosPac := 1 to len(aVetPac)
 
  IncRegua()
                      
  If nLin+2 > nMaxLin
   FS_Cabec()
   nLin ++ 
  Endif
    
  If cCodCon <> aVetPac[nPosPac, 1]
   If Empty(cCodCon)
    @nLin, 000 PSAY STR0014 + aVetPac[nPosPac, 1]+ " - " + aVetPac[nPosPac, 2] //"Conv๊nio: "
   Else
    If nTipoRel == 1
     FS_SOMTOT(1)
    Endif 
    FS_SOMTOT(2)
    If nSlPagCon == 1
     FS_Cabec()
    Endif  
    nLin++
    @nLin, 000 PSAY STR0014 + aVetPac[nPosPac, 1]+ " - " + aVetPac[nPosPac, 2] //"Conv๊nio: "
    cCodPct := ""
   EndIf 
  EndIf
  
  If nTipoRel == 1 
   If cCodPct <> aVetPac[nPosPac, 4]
    If Empty(cCodPct)
     nLin++
     @nLin, 000 PSAY STR0015 + ALLTRIM(aVetPac[nPosPac, 4]) + " - " + aVetPac[nPosPac, 5]  //"Pacote..: "
    Else 
     FS_SOMTOT(1)   
     nLin++
     @nLin, 000 PSAY STR0015 + ALLTRIM(aVetPac[nPosPac, 4]) + " - " + aVetPac[nPosPac, 5]  //"Pacote..: "
    Endif
   EndIf
   
   cCodPct := aVetPac[nPosPac, 4]
  Endif
 
  nLin++
  If nTipoRel == 1
   @nLin, 000 Psay aVetPac[nPosPac, 7]
   @nLin, 008 Psay aVetPac[nPosPac, 8] + "-" + SUBSTR(aVetPac[nPosPac, 9],1,30) 
   @nLin, 049 Psay aVetPac[nPosPac, 10] 
   @nLin, 060 Psay aVetPac[nPosPac, 11]
   @nLin, 071 Psay aVetPac[nPosPac, 12] 
   @nLin, 082 Psay aVetPac[nPosPac, 13]
   @nLin, 093 Psay aVetPac[nPosPac, 6]
  Else
   @nLin, 000 PSAY ALLTRIM(aVetPac[nPosPac, 4]) + " - " + aVetPac[nPosPac, 5] 
  Endif
  
 
  @nLin, 121 Psay Transform(aVetPac[nPosPac, 14],"@E 9,999,999.99")  
  @nLin, 136 Psay Transform(aVetPac[nPosPac, 15],"@E 9,999,999.99")
  @nLin, 154 Psay Transform(aVetPac[nPosPac, 16],"@E 9,999,999.99")   
  @nLin, 174 Psay Transform(aVetPac[nPosPac, 17],"@E 9,999,999.99")   
  @nLin, 191 Psay Transform(aVetPac[nPosPac, 18],"@E 9,999,999.99")
  @nLin, 208 Psay Transform(aVetPac[nPosPac, 19],"@E 999,999.99")
 
  
  nPacCPrev  += aVetPac[nPosPac, 14] 
  nPacCAber  += aVetPac[nPosPac, 15]
  nPacFatPac += aVetPac[nPosPac, 16] 
  nPacTotal  += aVetPac[nPosPac, 17] 
  nPacDifer  += aVetPac[nPosPac, 18]
  

  nConCPrev  += aVetPac[nPosPac, 14]
  nConCAber  += aVetPac[nPosPac, 15]
  nConFatPac += aVetPac[nPosPac, 16]
  nConTotal  += aVetPac[nPosPac, 17] 
  nConDifer  += aVetPac[nPosPac, 18]
  
 
  nTotCPrev  += aVetPac[nPosPac, 14] 
  nTotCAber  += aVetPac[nPosPac, 15]
  nTotFatPac += aVetPac[nPosPac, 16] 
  nTotGeral  += aVetPac[nPosPac, 17] 
  nTotDifer  += aVetPac[nPosPac, 18]

  
  cCodCon := aVetPac[nPosPac, 1]
  
 Next nPosPac
 
 FS_SOMTOT(1)
 FS_SOMTOT(2)
 FS_SOMTOT(3)

 SET DEVICE TO SCREEN
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()
 DBCloseArea()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_TOTDES บ Autor ณ Mario Arizono      บ Data ณ  11/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Totalizador das despesas                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_TOTDES(cAlias, cNrGuia, cCodDes)
 Local cSQL      := ""
 Local nValRet   := 0, nPosAlias := 0
 Local aAlias    := {cAlias + "5", cAlias + "6", cAlias + "7"}
 Local aArea     := GetArea()
 
 Default cCodDes := ""  
 
 For nPosAlias := 1 to len(aAlias)
 
  cSQL := "SELECT SUM(" + HS_FVALDES(aAlias[nPosAlias]) + ") TRB_VALDES "
  cSQL += "FROM " + RetSQLName(aAlias[nPosAlias]) + " " + aAlias[nPosAlias]
  cSQL += " WHERE " + aAlias[nPosAlias] + "_FILIAL = '" + xFilial(aAlias[nPosAlias]) + "' AND " + aAlias[nPosAlias] + ".D_E_L_E_T_ <> '*' "
  cSQL += "        AND " + aAlias[nPosAlias] + "_NRSEQG = '" + cNrGuia + "' "
  If !Empty(cCodDes)
   cSQL += "        AND " + aAlias[nPosAlias] + "_CODDES <> '" + cCodDes + "' "
  Endif
 
  TCQUERY cSQL NEW ALIAS "TRB"
 
  DbSelectArea("TRB")
  DbGoTop()
   
  nValRet += TRB->TRB_VALDES
   
  DbCloseArea()
 
 Next nPosAlias 
 
 RestArea(aArea)
 
 Return(nValRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Mario Arizono      บ Data ณ  12/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec()
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.) 
 nLin := 8
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SOMTOT บ Autor ณ MARIO ARIZONO      บ Data ณ  11/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ PROCESSA TOTAIS DAS QUEBRAS                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
STATIC FUNCTION FS_SOMTOT(nOpc)

 If nOpc == 1
  nLin++   
  @nLin, 000 Psay STR0016 //"Total Pacote"
  @nLin, 121 Psay Transform(nPacCPrev,"@E 9,999,999.99")  
  @nLin, 136 Psay Transform(nPacCAber,"@E 9,999,999.99")   
  @nLin, 154 Psay Transform(nPacFatPac,"@E 9,999,999.99")   
  @nLin, 174 Psay Transform(nPacTotal,"@E 9,999,999.99")   
  @nLin, 191 Psay Transform(nPacDifer,"@E 9,999,999.99")   
  @nLin, 208 Psay Transform((nPacDifer/nPacCPrev)*100,"@E 999,999.99")   
  nPacCPrev  := 0 
  nPacCAber  := 0
  nPacFatPac := 0 
  nPacTotal  := 0 
  nPacDifer  := 0
  
 ElseIf nOpc == 2
  nLin++   
  @nLin, 000 Psay STR0017 //"Total Conv๊nio"
  @nLin, 121 Psay Transform(nConCPrev,"@E 9,999,999.99")  
  @nLin, 136 Psay Transform(nConCAber,"@E 9,999,999.99")   
  @nLin, 154 Psay Transform(nConFatPac,"@E 9,999,999.99")   
  @nLin, 174 Psay Transform(nConTotal,"@E 9,999,999.99")   
  @nLin, 191 Psay Transform(nConDifer,"@E 9,999,999.99")   
  @nLin, 208 Psay Transform((nConDifer/nConCPrev)*100,"@E 999,999.99")   
  nConCPrev  := 0 
  nConCAber  := 0
  nConFatPac := 0 
  nConTotal  := 0 
  nConDifer  := 0
  
 Else
  nLin++   
  @nLin, 000 PSay Replicate("-",220)
  nLin++
  @nLin, 000 Psay STR0018 //"Total Geral"
  @nLin, 121 Psay Transform(nTotCPrev,"@E 9,999,999.99")  
  @nLin, 136 Psay Transform(nTotCAber,"@E 9,999,999.99")   
  @nLin, 154 Psay Transform(nTotFatPac,"@E 9,999,999.99")   
  @nLin, 174 Psay Transform(nTotGeral,"@E 9,999,999.99")   
  @nLin, 191 Psay Transform(nTotDifer,"@E 9,999,999.99")   
  @nLin, 208 Psay Transform((nTotDifer/nTotCPrev)*100,"@E 999,999.99")   
  nTotCPrev  := 0 
  nTotCAber  := 0
  nTotFatPac := 0 
  nTotGeral  := 0 
  nTotDifer  := 0
  
 EndIf
 nLin++
RETURN( NIL ) 

