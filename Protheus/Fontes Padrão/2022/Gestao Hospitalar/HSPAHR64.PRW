#INCLUDE "HSPAHR64.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR64  บ Autor ณ Daniel Peixoto     บ Data ณ  15/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Tabelas de Materiais Medicamentos                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR64()


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Declaracao de Variaveis                                             ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := STR0003 //"Tabela Materiais Medicamentos"
Local nLin           := 80 

Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd 				   := {}    

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "M"
Private nomeprog     := "HSPAHR64" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := { STR0004, 1, STR0005, 2, 2, 1, "", 1}   //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHR64" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cPerg        := "HSPR64"
Private cString      := ""      
Private cGcaTipo     := ""

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao
Private lTamProd := Iif((TamSx3("GCB_PRODUT")[1])<=15, .T., .F.)

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ PARAMETROS                                                       ณ
 ณ MV_PAR01	- Tipo Produto 1=Mat 2=Med                              ณ
 ณ MV_PAR02	- Ativa 1=NAO 2=SIM 3=AMBAS                             ณ
 ณ MV_PAR03	- Da Tabela                                             ณ
 ณ MV_PAR04	- Ate Tabela                                            ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */


If !Pergunte(cPerg,.T.)
	return
EndIf

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)


RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Daniel Peixoto     บ Data ณ  15/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HS_VldTab()
If !Empty(mv_par01)
	If MV_PAR01 == 1
    cGcaTipo := "0" 
  Else
    cGcaTipo := "1" 
  EndIf   
Endif
Return(.T.)

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local cSQL 	     := "" 
Local nTotItens  := 0
Private cCodTab  := ""
Private aTabPla  := {}


 cSQL := "SELECT  DISTINCT GCA.GCA_CODTAB, GCM.GCM_DESPLA "
 cSQL += " FROM " + RetSQLName("GCA") + " GCA" 
 If MV_PAR01 == 1
    cSQL += " JOIN " + RetSQLName("GD9") + " GD9 ON GD9.GD9_CODMAT = GCA.GCA_CODTAB "  //MAT
 Else
    cSQL += " JOIN " + RetSQLName("GDA") + " GDA ON GDA.GDA_CODMED = GCA.GCA_CODTAB "  //MED
 EndIf  
 If MV_PAR01 == 1 
   cSQL += " JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GD9.GD9_CODPLA  " 
 Else
   cSQL += " JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GDA.GDA_CODPLA "
 EndIf 
 cSQL += " WHERE"
 cSQL += "     GCA.GCA_FILIAL = '" + xFilial("GCA") + "' AND GCA.D_E_L_E_T_ <> '*' "
 If MV_PAR01 == 1  
   cSQL += " AND GD9.GD9_FILIAL = '" + xFilial("GD9") + "' AND GD9.D_E_L_E_T_ <> '*' "
 Else  
   cSQL += " AND GDA.GDA_FILIAL = '" + xFilial("GDA") + "' AND GDA.D_E_L_E_T_ <> '*' "
 EndIf     
 cSQL += " AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
 cSQL += "Order By GCA_CODTAB"
                      
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
 FS_MontaVet()               
 DBCloseArea()
 
 cSQL := "SELECT  DISTINCT GCA.GCA_CODTAB, GCA.GCA_DESCRI, GCA.GCA_TIPO, GCB.GCB_PRODUT, GCB.GCB_PRCVEN, GCB.GCB_PRCVUC, "
 cSQL += " GCB.GCB_FATOR, GCB.GCB_ATIVO, GCB.GCB_CODPRO, GCB.GCB_DATVIG, SB1.B1_DESC "
 cSQL += " FROM " + RetSQLName("GCA") + " GCA "  
 cSQL += " JOIN " + RetSQLName("GCB") + " GCB ON GCB.GCB_CODTAB = GCA.GCA_CODTAB "
 cSQL += " JOIN " + RetSQLName("GBI") + " GBI ON GBI.GBI_PRODUT = GCB.GCB_PRODUT "
 cSQL += " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD = GBI.GBI_PRODUT "
 cSQL += " WHERE"
 cSQL += "     GCA.GCA_FILIAL = '" + xFilial("GCA") + "' AND GCA.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCB.GCB_FILIAL = '" + xFilial("GCB") + "' AND GCB.D_E_L_E_T_ <> '*' "
 cSQL += " AND GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' "
 cSQL += " AND SB1.B1_FILIAL = '"  + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "
 If MV_PAR02 <> 3
   If MV_PAR02 == 1
     cSQL += " AND GCA.GCA_TABATV = '0' "
   Else
     cSQL += " AND GCA.GCA_TABATV = '1' "
   EndIf           
 EndIf  
 cSQL += " AND GCA.GCA_CODTAB BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "    
/* If MV_PAR01 == 1
   cSQL += " AND GBI.GBI_TIPO = '0' "   //TIPO DE PRODUTO
 Else
   cSQL += " AND GBI.GBI_TIPO = '1' "
 EndIf  */
 If MV_PAR01 == 1
   cSQL += " AND GCA.GCA_TIPO = '0' "   //TIPO DE TABELA
 Else
   cSQL += " AND GCA.GCA_TIPO = '1' "
 EndIf  
 cSQL += " AND GCB.GCB_DATVIG = ( SELECT MAX(GCB1.GCB_DATVIG) "
 cSQL += " FROM " + RetSQLName("GCA") + " GCA "  
 cSQL += " JOIN " + RetSQLName("GCB") + " GCB1 ON GCB1.GCB_CODTAB = GCA.GCA_CODTAB "
 cSQL += " WHERE"
 cSQL += "     GCA.GCA_FILIAL  = '" + xFilial("GCA") + "' AND GCA.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCB1.GCB_FILIAL = '" + xFilial("GCB") + "' AND GCB1.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCB1.GCB_CODTAB = GCB.GCB_CODTAB  "
 cSQL += " AND GCB1.GCB_PRODUT = GCB.GCB_PRODUT ) "
 cSQL += " Order By GCA_DESCRI, B1_DESC"

 cSQL :=  ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
                                
 If Eof()
  HS_MsgInf(STR0006, STR0014, STR0015) //"Nenhum dado foi encontado para a selecao efetuada!"###"Aten็ใo"###"Verifique a sele็ใo"
 Endif

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

 SetRegua(100)
 
 While !EOF()

	 IncRegua()
   
   If lAbortPrint
      @nLin,00 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
   
   If nLin > nMaxLin
/*              				   1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
        			   0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
      Cabec1 := STR0008 //"Tabelas"
      Cabec2 := Iif(lTamProd,STR0009,STR0016) //"Produto                                      Vl. Venda       Vl.Venda UC  Fator   Ativo  Cod.Proprio           Vigencia"
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
   Endif

   If cCodTab <> QRY->GCA_CODTAB
     If !EMPTY(cCodTab)
       nLin++
       @nLin,008 PSAY STR0010 //"Total de Itens da Tabela: "
       @nLin,050 PSAY nTotItens 
       nTotItens := 0
       nLin +=2    
       @nLin,050 PSAY STR0011 //"Planos que usam esta Tabela"
       nLin ++
       nLin:= FS_ImpVet(nLin)
       @nLin,000 PSAY REPLICATE("-",119)
       nLin += 2
     EndIf       
     @nLin,000 PSAY QRY->GCA_CODTAB +' - '+ QRY->GCA_DESCRI
     nLin +=2
     cCodTab := QRY->GCA_CODTAB
   EndIf

   @nLin,000 PSAY QRY->GCB_PRODUT + " - " + SUBSTR( QRY->B1_DESC, 1 , 18 ) 
   @nLin,Iif(lTamProd,038,048) PSAY TRANSFORM(QRY->GCB_PRCVEN,"@E 999,999,999.9999")
   @nLin,Iif(lTamProd,056,066) PSAY TRANSFORM(QRY->GCB_PRCVUC,"@E 999,999,999.9999") 
   @nLin,Iif(lTamProd,074,084) PSAY QRY->GCB_FATOR
   If QRY->GCB_ATIVO == '0'
     @nLin,Iif(lTamProd,082,092) PSAY STR0012 //"Nao"
   Else   
     @nLin,Iif(lTamProd,082,092) PSAY STR0013 //"Sim"
   EndIf  
   @nLin,Iif(lTamProd,089,099) PSAY QRY->GCB_CODPRO
   @nLin,Iif(lTamProd,111,121) PSAY DTOC( STOD(QRY->GCB_DATVIG) )      
   nTotItens += 1
   nLin ++        
   dbSkip() /* Avanca o ponteiro do registro no arquivo */
  
  If EOF()           
    nLin++
    @nLin,008 PSAY STR0010 //"Total de Itens da Tabela: "
    @nLin,050 PSAY nTotItens
    nLin +=2    
    @nLin,050 PSAY STR0011 //"Planos que usam esta Tabela"
    nLin ++
    nLin:= FS_ImpVet(nLin)
  EndIf       
  
EndDo


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

Static Function FS_MontaVet()
  While !EOF()
    AADD(aTabPla,{QRY->GCA_CODTAB,QRY->GCM_DESPLA})
    DBSkip()
  EndDo  
Return()

Static Function FS_ImpVet(nLin)
Local nContFor := 0
Local nNroCol  := 1
Local nCol     := 0

  If Ascan(aTabPla,{|x| x[1] == cCodTab }) == 0
    @nLin,000 PSAY "Nenhum Plano Encontrado"
  Else
    For nCOntFor:= 1 to Len(aTabPla)
      If nNroCol <= 3
        If aTabPla[nCOntFor,1] == cCodTab  
          @nLin,nCol PSAY aTabPla[nCOntFor,2]
          nCol := nCol + 40
          nNroCol ++
        EndIf
      Else        
        nLin++
        nCol    := 0
        nNroCol := 1      
      EndIf 
    Next
  EndIf  
  nLin += 2
 
Return(nLin)
