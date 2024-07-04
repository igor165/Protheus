#INCLUDE "HSPAHRDN.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#define ESC          27
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRDN  บ Autor ณ MARCELO JOSE       บ Data ณ  24/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ PENDENCIA  DE GUIAS                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRDN()

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0003 //"PENDENCIA DE GUIAS"
Local cPict          := ""
Local titulo         := STR0003 //"PENDENCIA DE GUIAS"
Local nLin           := 80

Local Cabec1         := STR0004 //"S E T O R"
                      /*                     1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                                   0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
Local Cabec2         := STR0005 //"Paciente                                       Atendimento  Data Aten.  Guia                 Plano                          Pendencia                                Observacao"
Local imprime        := .T.                 
Local aOrd           := {}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 132
Private tamanho      := "G"
Private nomeprog     := "HSPAHRDN" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 15
Private aReturn      := { STR0006, 1, STR0007, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHRDN" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cString      := "GEZ"
Private cPerg        := "HSPRDN"
Private aVetor       := {}
Private nTotGer      := 0

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao
Private nTipRel := 0

Private aVetPen := {}

 If !Pergunte(cPerg,.T.)
  return
 EndIf
 
 nTipRel := MV_PAR09
 
 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2

 wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

 If nLastKey == ESC
  Return 
 Endif

 SetDefault(aReturn,cString)

 If nLastKey == ESC
  Return
 Endif

 nTipo := If(aReturn[4]==1,15,18)

 RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
 
Return

/******************************************************************************************************************
Funcao     RUNREPORT  Autor : AP6 IDE               Data   30/07/04          
Descricao  Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.
Uso        Programa principal
*******************************************************************************************************************/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local cCodLoc := "", nCont    := 0
Local nQtdPen := 0, cCodPen  := "", cDespen := "" 
Local nPosVet := 0
Local aVetDados := {}

Private nTotal  := 0
Private aVetPen := {}

         /*                     1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                      0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
 If nTipRel == 2//sintetico                                    
  Cabec2          := STR0028 //"Pendencia                               Quantidade"
 EndIf

 cQuery := "SELECT GCY.GCY_REGATE, GCY.GCY_REGGER, GCY.GCY_NOME, GCY.GCY_DATATE, GCY.GCY_CODLOC, GCS.GCS_NOMLOC, "
 cQuery += "GCZ.GCZ_NRGUIA, GCM.GCM_DESPLA, GEY.GEY_DESPEN, GEZ.GEZ_OBSERV, GEZ.GEZ_CODPEN "
 cQuery += "FROM " + RetSqlName("GEZ") + " GEZ " 
 cQuery += "JOIN " + RetSQLName("GEY") + " GEY ON GEY.GEY_CODPEN = GEZ.GEZ_CODPEN AND GEY.GEY_FILIAL = '" + xFilial("GEY") + "' AND GEY.D_E_L_E_T_ <> '*' "
 cQuery += "JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GEZ.GEZ_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cQuery += " JOIN " + RetSQLName("GCU") + " GCU ON GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' "
 cQuery += " AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TPGUIA <> '7' "  //Nใo Apresenta Guias Tipo Retorno 
 cQuery += "JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cQuery += "JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GCY.GCY_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
 cQuery += "JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GCZ.GCZ_CODPLA AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cQuery += "WHERE GEZ.GEZ_FILIAL = '" + xFilial( "GEZ" ) + "' AND GEZ.D_E_L_E_T_ <> '*' "  
 cQuery += "AND GCY.GCY_DATATE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
 cQuery += "AND GCZ.GCZ_CODPLA BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
 cQuery += "AND GCZ.GCZ_STATUS < '3' "
 cQuery += "AND GCY.GCY_CODLOC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
 cQuery += "AND GEZ.GEZ_CODPEN BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
 cQuery += "AND GCY.GCY_TPALTA <> '99' "
 cQuery += "AND GEZ.GEZ_ATIVO = '1' "
 cQuery += "ORDER BY GCY_CODLOC"
 If nTipRel == 2 
  cQuery += ", GEZ_CODPEN"
 EndIf

 cQuery := ChangeQuery(cQuery)

 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.T.,.T.)

 DbSelectArea("QRY")
 DbGoTop()
                                
 If Eof()
  HS_MsgInf(STR0025, STR0026, STR0027) //"Nenhum dado foi encontado para a sele็ใo efetuada!"###"Aten็ใo"###"Verifique a sele็ใo"
  DbCloseArea()
  Return(Nil)
 Endif
 
 While !EOF()
  nTotGer ++
  If nTipRel == 1
   AADD(aVetDados, {QRY->GCY_CODLOC, QRY->GCS_NOMLOC, QRY->GCY_NOME, QRY->GCY_REGATE, STOD(QRY->GCY_DATATE), ;
                    QRY->GCZ_NRGUIA, QRY->GCM_DESPLA, QRY->GEY_DESPEN, QRY->GEZ_OBSERV})
  Else
   If(nPosVet := aScan(aVetDados, {| aVet | aVet[1] == QRY->GCY_CODLOC .And. aVet[3] == QRY->GEZ_CODPEN })) == 0
    AADD(aVetDados, {QRY->GCY_CODLOC, QRY->GCS_NOMLOC, QRY->GEZ_CODPEN, QRY->GEY_DESPEN, 1, 0})
   Else
    aVetDados[nPosVet, 5] ++
   EndIf  
   
   nPosVet := aScan(aVetDados, {| aVet | aVet[1] == QRY->GCY_CODLOC})
   aVetDados[nPosVet, 6] ++
  EndIf  
  
  DbSkip()
 EndDo
 
 For nCont := 1 To Len(aVetDados)
  If aVetDados[nCont, 1] == aVetDados[IIF(nCont == Len(aVetDados), Len(aVetDados), nCont + 1), 1]
   aVetDados[IIF(nCont == Len(aVetDados), Len(aVetDados), nCont + 1), 6] := aVetDados[nCont, 6]
  EndIf
 Next  

 If nTipRel == 2
  aSort(aVetDados,,, {|x, y| x[6] > y[6]})
 EndIf
 
 For nCont := 1 To Len(aVetDados)
  
  If nLin > nMaxLin
   Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   nLin := 10
  Endif

  If lAbortPrint
   @nLin,00 PSAY STR0008 //"INTERROMPIDO PELO USUARIO"
   Exit
  Endif     
 
  If nLin > nMaxLin
   @ nLin,01 Psay STR0009              //"continua..."
   Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   nLin := 10
  Endif
 
  If nCont == 1 .Or. aVetDados[nCont, 1] <> aVetDados[IIF(nCont == Len(aVetDados), nCont, nCont + 1), 1]
   If nCont > 1
    If nTipRel == 1
     nLin := FS_ImpDados(nCont, aVetDados, nLin)    
    Else
     @ nLin,000 Psay aVetDados[nCont, 4]
     @ nLin,043 Psay TRANSFORM(aVetDados[nCont, 5], "@E 999,999")
     FS_AtuVetPen(aVetDados[nCont, 3], aVetDados[nCont, 4], aVetDados[nCont, 5])
     nTotal += aVetDados[nCont, 5]
    EndIf 
    
    nLin += 2
    @ nLin,00 Psay STR0011 
    @ nLin,43 Psay TRANSFORM(nTotal, "@E 999,999") //"Total de Guias com Pendencia por setor: "
    @ nLin,55 Psay STR0029 + TRANSFORM((nTotal/nTotGer) * 100, "@E 999.99") + "%"  //"Percentual: "
    nLin += 2
    nTotal  := 0
    @ nLin,00 Psay aVetDados[IIF(nCont == Len(aVetDados), nCont, nCont + 1), 1] + " - " + aVetDados[IIF(nCont == Len(aVetDados), nCont, nCont + 1), 2]
    nLin += 2
    Loop
   Else
    @ nLin,00 Psay aVetDados[nCont, 1] + " - " + aVetDados[nCont, 2]
   EndIf
   
   nLin +=2
  EndIf

  If nTipRel == 1   
   nLin := FS_ImpDados(nCont, aVetDados, nLin)    
  Else
   @ nLin,000 Psay aVetDados[nCont, 4]
   @ nLin,043 Psay TRANSFORM(aVetDados[nCont, 5], "@E 999,999")
   nLin++

   FS_AtuVetPen(aVetDados[nCont, 3], aVetDados[nCont, 4], aVetDados[nCont, 5])
   nTotal += aVetDados[nCont, 5]
  EndIf

 Next

 nLin += 2
 @ nLin,00 Psay STR0011 
 @ nLin,43 Psay TRANSFORM(nTotal, "@E 999,999") //"Total de Guias com Pendencia por setor: "
 @ nLin,55 Psay STR0029 + TRANSFORM((nTotal/nTotGer) * 100, "@E 999.99") + "%"  //"Percentual: "

 nLin +=2
 @ nLin,00 Psay STR0012  //"Total de Guias com Pendencia: "
 @ nLin,43 Psay TRANSFORM(nTotGer, "@E 999,999")
 @ nLin,55 Psay STR0029+ TRANSFORM(100, "@E 999.99") + "%"  //"Percentual: "
 nLin += 2

 If nTipRel == 2
  //Resumo Geral
  aSort(aVetPen,,, {|x, y| x[3] > y[3]})
  @ nLin,000 Psay STR0030 //"Resumo Geral"
  @ nLin,040 Psay STR0031 //"Quantidade"
  @ nLin,055 Psay STR0032 //"Percentual"
  nLin ++
  @ nLin,000 Psay "============" 
  @ nLin,040 Psay "==========" 
  @ nLin,055 Psay "=========="  
  nLin ++
  For nCont := 1 to Len(aVetPen)
   @ nLin,00 Psay aVetPen[nCont, 2]
   @ nLin,43 Psay TRANSFORM(aVetPen[nCont, 3], "@E 999,999")
   @ nLin,58 Psay TRANSFORM((aVetPen[nCont, 3]/nTotGer) * 100, "@E 999.99") + "%"
   nLin ++
  Next
 EndIf
 
 dbCloseArea() 
 
 SET DEVICE TO SCREEN

 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()

Return           

Static Function FS_AtuVetPen(cCodPen, cDesPen, QtdPen)
Local nPosVet := 0

 If(nPosVet := aScan(aVetPen, {| aVet | aVet[1] == cCodPen })) == 0
  AADD(aVetPen, {cCodPen, cDesPen, QtdPen})
 Else
  aVetPen[nPosVet, 3] += QtdPen
 EndIf

Return(Nil)  

Static Function FS_ImpDados(nCont, aVetDados, nLin)
 
 @ nLin, 00 Psay aVetDados[nCont, 3]
 @ nLin, 47 Psay aVetDados[nCont, 4]
 @ nLin, 60 Psay aVetDados[nCont, 5]
 @ nLin, 72 Psay aVetDados[nCont, 6]
 @ nLin, 93 Psay aVetDados[nCont, 7]
 @ nLin,124 Psay aVetDados[nCont, 8]
 @ nLin,165 Psay aVetDados[nCont, 9]
 nLin ++
 nTotal++

Return(nLin)