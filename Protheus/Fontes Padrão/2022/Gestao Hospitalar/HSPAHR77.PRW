#INCLUDE "HSPAHR77.ch"
#include "Protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR77 บ Autor ณ HEIMDALL CASTRO    บ Data ณ22/06/05     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de KITS                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR77()
 Local cDesc1  := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2  := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3  := ""
 Local cPict   := ""
 Local imprime := .T.
 Local aOrd    := {}
 Local nLinTotal := 60
 
 Private cCabec1 := "" //"C๓digo Kit      Descri็ใo                                              C๓digo Item         Descri็ใo Produto/Tx e Diแrias     Qtd."
 Private cCabec2 := ""
 Private cTitulo := STR0003 //"Rela็ใo de kits"
 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private limite       := 132
 Private tamanho      := "M"
 Private nomeprog     := "HSPAHR77"
 Private nTipo        := 15
 Private aReturn      := {STR0004, 1, STR0005, 2, 2, 1, "", 1}  //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private cbtxt        := Space(10)
 Private cbcont       := 00
 Private CONTFL       := 01
 Private m_pag        := 01
 Private cString      := ""
 Private wnrel        := "HSPAHR77"
 Private nLin         := 80

 Private cCODIMP      := ""
 Private nMaxLin      := 0 // quantidade maxima de linhas p/ impressao
 
 Private cCodKit_De   := ""
 Private cCodKit_Ate  := ""
 
 Private lTamProd := IIf((TamSx3("GAF_CCOKIT")[1])<=15, .T., .F.)
 cCabec1 := IIf(lTamProd,STR0013,STR0014)
 
 cPerg := "HSPR77"
 If !Pergunte(cPerg,.T.)
  return
 EndIf               
 
 cCodKit_De  := mv_par01
 cCodKit_Ate := mv_par02

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin    := nMaxLin * 2
           
 wnrel := SetPrint("", NomeProg, "", @cTitulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif
 
 SetDefault(aReturn,cString)
 
 If nLastKey == 27
  Return
 Endif
                
 nTipo := 18
 RptStatus({|| RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)}, cTitulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPREL บ Autor ณ HEIMDALL CASTRO    บ Data ณ18/04/08     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)
 
 Local cSql    := ""
 Local cCodKit := ""
 
 cSQL := "SELECT GAG.GAG_CODKIT CODKIT, GAF.GAF_DESKIT DESKIT, GAF.GAF_CCOKIT CCOPRI, GAG.GAG_CCOKIT CCOKIT, SB1.B1_DESC DESCR, GAG.GAG_QTDKIT QTDKIT "
 cSQL += "FROM " + RetSqlName("GAG") + " GAG "
 cSQL += "JOIN " + RetSqlName("GAF") + " GAF ON GAF.GAF_FILIAL = '" + xFilial("GAF") + "' AND GAF.D_E_L_E_T_ <> '*' AND GAF.GAF_CODKIT = GAG.GAG_CODKIT " 
 cSQL += "JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD = GAG.GAG_CCOKIT " 
 cSQL += "WHERE GAF.GAF_CODKIT BETWEEN '" + cCodKit_De + "' AND '" + cCodKit_Ate + "' AND "
 cSQL += "GAG.D_E_L_E_T_ <> '*' AND GAG.GAG_FILIAL = '" + xFilial("GAG") + "' AND GAF.GAF_CCOKIT <> GAG.GAG_CCOKIT " 
 cSQL += "ORDER BY GAG.GAG_CODKIT "

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 
 DbGoTop()
 If Eof()
  HS_MsgInf(STR0008, STR0011, STR0012) //"Nenhum dado foi encontrado para a selecao efetuada."###"Aten็ใo"###"Rotina de execucao do relatorio"
  DbCloseArea()
  Return()
 Endif 
             
  //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 SetRegua(RecCount())
 
 While !EOF()                                                                                
  IncRegua()
  
  If nLin+2 > nMaxLin
   FS_Cabec()
   nLin := 8
  Endif
    
  @ nLin, 002 PSAY SUBSTR(QRY->CODKIT, 1, 40)
  @ nLin, 010 PSAY QRY->DESKIT 
  @ nLin, 050 PSAY QRY->CCOPRI
  @ nLin, IIf(lTamProd,068,083) PSAY SUBSTR(HS_INIPADR("SB1", 1, QRY->CCOPRI, "B1_DESC"), 1, 40)
  @ nLin, IIf(lTamProd,118,133) PSAY HS_INIPADR("GAG", 1, QRY->CODKIT + QRY->CCOPRI, "GAG_QTDKIT")
  
  cCodKit := QRY->CODKIT

  nLin++    
  
		While (QRY->CODKIT == cCodKit)
		 If nLin+2 > nMaxLin
    FS_Cabec()
    nLin    := 8
   Endif
   
   @ nLin, 050 PSAY QRY->CCOKIT
   @ nLin, IIf(lTamProd,068,083) PSAY SUBSTR(QRY->DESCR, 1, 40)
   @ nLin, IIf(lTamProd,118,133) PSAY QRY->QTDKIT 
  	nLin++
      
 	 DbSkip() 
  End
          
  nLin += 1
  
  @ nLin, 001 PSAY "----------------------------------------------------------------------------------------------------------------------------"
             
  nLin += 1
 
 End 

 Set Device  to Screen
 
 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH() 
 DBCloseArea()
 
Return(Nil)       

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Cibele Peria       บ Data ณ  29/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec()
 Cabec(cTitulo, cCabec1, cCabec2, NomeProg, Tamanho, nTipo, ,.T.) 
Return()
