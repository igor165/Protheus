#INCLUDE "HSPAHR17.ch"
#Include "Protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR17 บ Autor ณ Daniel Peixoto     บ Data ณ  03/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Trabalhos Cientificos                         บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR17()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relat๓rio "
 Local cDesc2 := STR0002 //"de acordo com os parโmetros informados pelo usuแrio."
 Local cDesc3 := STR0003 //"Trabalhos Cientํficos"
 Local aOrd   := {}
 
 Private Titulo      := cDesc3
 Private Cabec1      := ""
 Private Cabec2      := ""
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 132
 Private Tamanho     := "M"
 Private NomeProg    := "HSPAHR17" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := {STR0006 , 1, STR0007, 2, 2, 1, "", 1}  //"Zebrado"###"Administra็ใo"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := NomeProg
 Private nTam        := 132 
 Private cPerg       := "HSPR17"

 Private cDaDtnas := "", cAteDtNas := ""
 Private cSexo    := ""
 Private cEspec   := ""
 Private cCodCrm  := ""
 Private cCodPro  := ""
 Private cDaDtAte := "", cAteDtAte := ""
 Private cCodCID  := ""
 Private cTipo    := ""
 Private nClassi  := 0
 Private cCodImp  := ""  
 Private cRegAte  := ""
 Private nMaxLin  := 0 // quantidade maxima de linhas p/ impressao
 Private QRY      := "QRYR17"

 If !Pergunte(cPerg,.T.)
  Return()
 EndIf

 cDaDtNas  := MV_PAR01
 cAteDtNas := MV_PAR02
 nSexo     := MV_PAR03
 cEspec    := MV_PAR04
 cCodCrm   := MV_PAR05
 cCodPro   := MV_PAR06
 cDaDtAte  := MV_PAR07
 cAteDtAte := MV_PAR08
 cCodCID   := MV_PAR09
 cTipo     := MV_PAR10
 nClassi   := MV_PAR11
 cCodImp   := MV_PAR12
 
 nMaxLin := HS_MaxLin(cCodImp)

 If cTipo == 1 //Analitico
  Cabec1 := STR0004 //"Atendimento  Prontuแrio                               Data Nasc.  Sexo  Dt Atend.  Empresa                    Setor                  "
  Cabec2 := STR0005 //"   Procedimento                  Dt Proced.  M้dico                          CID"
 Else //Sintetico
  Cabec1 := STR0009 //"Atendimento  Prontuแrio                               Data Nasc.  Sexo  Dt Atend.  CID"
  Cabec2 := ""
 EndIf 
  
 wnrel := SetPrint("", NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 EndIf

 SetDefault(aReturn, "")
 If nLastKey == 27
  Return()
 EndIf

 nTipo := If(aReturn[4] == 1, 15, 18)
 RptStatus({|| RunReport("") }, Titulo)
 
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Daniel Peixoto     บ Data ณ  06/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()

 Local cSql    := ""
 Local nCtaReg := 0
 Local nSql    := 0

 For nSql := 1 To 2
  cSQL := "SELECT "
  
  If nSql == 1
   cSQL += "COUNT(*) nContasR"
  Else
   cSQL += "GCY.GCY_REGGER, GCY.GCY_REGATE, GCY.GCY_NOME, GBH.GBH_SEXO, SRA.RA_NOME, GBH.GBH_DTNASC, GCY.GCY_DATATE, "
   cSQL += "GAS.GAS_PATOLO, GAE.GAE_NOME, GA7.GA7_DESC, GCS.GCS_NOMLOC, GD7.GD7_DATDES"
  EndIf
   
  cSQL += " FROM " + RetSQLName("GCY") + " GCY"
  cSQL += "      JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCY.GCY_REGGER AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
  cSQL += " 		   JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GCY.GCY_LOCATE AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
  cSQL += " LEFT JOIN " + RetSQLName("GAS") + " GAS ON GAS.GAS_CODIGO = GCY.GCY_CIDINT AND GAS.GAS_FILIAL = '" + xFilial("GAS") + "' AND GAS.D_E_L_E_T_ <> '*' "
  cSQL += " LEFT JOIN " + RetSQLName("GAE") + " GAE ON GAE.GAE_CODEMP = GCY.GCY_CODEMP AND GAE.GAE_FILIAL = '" + xFilial("GAE") + "' AND GAE.D_E_L_E_T_ <> '*' "
  cSQL += "      JOIN " + RetSQLName("GD7") + " GD7 ON GD7.GD7_REGATE = GCY.GCY_REGATE AND GD7.GD7_FILIAL = '" + xFilial("GD7") + "' AND GD7.D_E_L_E_T_ <> '*' "
  cSQL += " 				 JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GD7.GD7_CODCRM AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*'  "       
  cSQL += "      JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GD7.GD7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
  cSQL += " WHERE "
  cSQL += " GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
  cSQL += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(cDaDtAte) + "' AND '" + DTOS(cAteDtAte) + "' "
  cSQL += " AND GBH.GBH_DTNASC BETWEEN '" + DTOS(cDaDtNas) + "' AND '" + DTOS(cAteDtNas) + "' "
  If nSexo <> 3 //Ambos
   cSQL += " AND GBH.GBH_SEXO   = '" + STR(nSexo-1, 1) + "' "
  EndIf
  If !EMPTY(cCodCrm) 
   cSQL += " AND GD7.GD7_CODCRM = '" + cCodCrm + "' "  
  EndIf 
  If !EMPTY(cCodCid) 
   cSQL += " AND GCY.GCY_CIDINT = '" + cCodCid + "' "
  EndIf 
  If !EMPTY(cEspec) 
   cSQL += " AND GD7.GD7_CODESP = '"+ cEspec + "' "
  EndIf 
  If !EMPTY(cCodPro)
   cSQL += " AND GD7.GD7_CODDES = '"+ cCodPro +"' "
  EndIf 
  
  If nSql == 2
   If nClassi == 1
    cSQL += " ORDER BY GCY.GCY_REGGER"
   Else 
    cSQL += " ORDER BY GCY.GCY_NOME"
   EndIf
  EndIf 
   
  cSQL := ChangeQuery(cSQL) 
 
  dbUseArea(.T., "TOPCONN", TcGenQry(,, cSQL), QRY, .T., .T.)
  
  If nSql == 1
   nCtaReg := (QRY)->nContasR
   DbCloseArea()
  EndIf
 Next
  
 DbSelectArea(QRY)
 DbGoTop()
 If Eof()
  HS_MsgInf(STR0008, STR0010, STR0011) //"Nenhum dado foi encontrado para a sele็ใo efetuada." //"Aten็ใo"###"Execu็ใo do relat๓rio"
  DbCloseArea()
  Return(Nil)
 EndIf 

 Processa({||FS_ImpRel(nCtaReg)})
 
 Return(Nil)
 /*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_ImpRel บ Autor ณ Marcelo Jose       บ Data ณ  06/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao do Relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao RUNREPORT                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ImpRel(nCtaReg) 

 Local nQtosFoi := 0
 Private nLin   := nMaxLin * 2
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 
 ProcRegua(nCtaReg)

 DbSelectArea(QRY)
 DbGoTop()   
 
 While !EOF()                                                                                

  nQtosFoi++
  IncProc(STR0012 + Alltrim(STR(nQtosFoi, 6, 0)) + STR0013 + Alltrim(STR(nCtaReg, 6, 0)) + STR0014 + Alltrim(STR(m_pag, 6, 0)) + STR0015)
  
  If nLin + 2 > nMaxLin
   FS_Cabec()
   nLin++ 
  EndIf

  If cRegAte <> (QRY)->GCY_REGATE
   nLin++ 
   @nLin, 000 PSAY (QRY)->GCY_REGATE
   @nLin, 013 PSAY (QRY)->GCY_REGGER + " - " + SUBSTR((QRY)->GCY_NOME, 1, 30)
   @nLin, 054 PSAY IIF(Empty((QRY)->GBH_DTNASC), " ", HS_DTOC(STOD((QRY)->GBH_DTNASC), 1)) 
   If (QRY)->GBH_SEXO = "0"
    @nLin, 066 PSAY "M"
   Else 
    @nLin, 066 PSAY "F"
   EndIf
   @nLin, 072 PSAY IIF(Empty((QRY)->GCY_DATATE), " ", HS_DTOC(STOD((QRY)->GCY_DATATE), 1))
   If cTipo == 1 
    @nLin, 083 PSAY SUBSTR((QRY)->GAE_NOME, 1, 25)
    @nLin, 110 PSAY SUBSTR((QRY)->GCS_NOMLOC, 1, 22)
   Else
    @nLin, 083 PSAY SUBSTR((QRY)->GAS_PATOLO, 1, 30)
   End 
   cRegAte := (QRY)->GCY_REGATE
   nLin++
  EndIf

  If cTipo == 1 
   @nLin, 003 PSAY SUBSTR((QRY)->GA7_DESC, 1, 28)
   @nLin, 033 PSAY IIF(Empty((QRY)->GD7_DATDES), " ", HS_DTOC(STOD((QRY)->GD7_DATDES), 1))
   @nLin, 045 PSAY SUBSTR((QRY)->RA_NOME, 1, 30)
   @nLin, 077 PSAY SUBSTR((QRY)->GAS_PATOLO, 1, 30)
   nLin += 1
  EndIf 
  
  If nLin + 1 > nMaxLin
   FS_Cabec()
  EndIf

  DbSkip()
  
 EndDo    
 
nLin := nLin + 2 
@nLin, 013 PSAY STR0016 + STR(nCtaReg)

 SET DEVICE TO SCREEN
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If aReturn[5] == 1
  DbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 EndIf

 MS_FLUSH()
 DBCloseArea()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Cibele Peria       บ Data ณ  16/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao FS_ImpRel                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec()

//          1         2         3         4         5         6         7         8         9        10        11        12        13
//0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.

 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, , .T.) 
 nLin := 8
 
Return()