#INCLUDE "HSPAHR70.ch"
#INCLUDE "TopConn.ch"
#include "protheus.CH"
#include "colors.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHR70  ºAutor  ³André L. G. Cruz    º Data ³  05/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressão do relatório de histórico de Movimentação de     º±±
±±º          ³ Endereços                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GH                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION HSPAHR70()
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Declaracao de Variaveis Locais                                      ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 LOCAL cDesc1         := STR0001,; //"Este programa tem como objetivo imprimir relatorio "
       cDesc2         := STR0002,; //"de histórico transferencia de endereços dos        "
       cDesc3         := STR0003,; //"prontuários.                                       "
       cPict          := "",;
       cTitulo        := STR0004,; //"Histórico de Endereço"
       nLin           := 80,;
       Cabec1         := "",;
       Cabec2         := "",;
       imprime        := .T.,;
       aOrd           := {},;
       nInt           := 0,;
       nInt2          := 0,;
       cMes           := "",;
       cMeses         := ""

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Declaracao de Variaveis Privadas                                    ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
 PRIVATE cPerg        := "HSPR70",;
         lEnd         := .F.,;
         lAbortPrint  := .F.,;
         limite       := 132,;
         tamanho      := "P",; // P 80 cols, M 132 cols, G 220 Cols
         nomeprog     := "HSPAHR70",;
         nTipo        := 18,;
         aReturn      := { STR0012, 1, STR0013, 2, 2, 1, "", 1},;
         nLastKey     := 0,;
         cbtxt        := Space(10),;
         cbcont       := 00,;
         CONTFL       := 01,;
         m_pag        := 01,;
         wnrel        := "HSPAHR70",;
         cString      := "GSI",;
         nCompMaxNome := 80 - (TamSx3("GSI_REGGER")[1] + Len("-")  + 1 + Len("DD/MM/AAAA") + 1 + TamSx3("GSI_CODEND")[1] + 1 + TamSx3("GSI_CODENO")[1]),;
         cCodImp      := "",;
         aRet         := {}
 
 IF !Pergunte(cPerg,.T.)
  RETURN NIL
 ENDIF            

 aRet := FS_GetData()

/*
 * Roda a impressão de relatório se aRet não estiver vazia
 */
 IF Len(aRet) > 0
  Cabec1 := PadR(STR0005, (TamSx3("GSI_REGGER")[1] + Len("-") + nCompMaxNome + 1 )) //"Prontuário"
  Cabec1 += PadR(STR0006, (Len("DD/MM/AAAA") + 1)) //"Data"
  Cabec1 += PadR(STR0007, TamSx3("GSI_CODEND")[1] + 1) //"Origem"
  Cabec1 += PadR(STR0008, TamSx3("GSI_CODENO")[1] ) //"Destino"
           
  Cabec2 := ""
 
 /*
  * Monta interface com o usuário
  */ 
  wnrel := SetPrint(cString, NomeProg,"" , @cTitulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho, , .F.)
  IF nLastKey == 27
   RETURN NIL
  ENDIF
  SetDefault(aReturn, cString)
  IF nLastKey == 27
   RETURN NIL
  ENDIF
  nTipo := IIf(aReturn[4]==1, 15, 18)
 
  RptStatus( { || RunReport(Cabec1, Cabec2, cTitulo, nLin, aRet) }, cTitulo )
  
  SET DEVICE TO SCREEN

  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Se impressao em disco, chama o gerenciador de impressao...          ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  IF aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
  ENDIF

 ELSE

  HS_MsgInf(STR0010, STR0011, "HSPAHR70")

 ENDIF


RETURN NIL

/*
 * Localização dos Dados
 */
STATIC FUNCTION FS_GetData()
 LOCAL aRet      := {},;
       cProntDe  := MV_PAR01,;
       cProntAte := MV_PAR02,;
       cSql      := ""
       
cSql := "SELECT " +;
            " GSI.GSI_REGGER AS " + Chr(34) + "_REG"    + Chr(34) + ", " +;
            " GBH.GBH_NOME   AS " + Chr(34) + "_NOME"   + Chr(34) + ", " +;
            " GSI.GSI_DATTRA AS " + Chr(34) + "_DATA"   + Chr(34) + ", " +;
            " GSI.GSI_CODEND AS " + Chr(34) + "_ENDFIN" + Chr(34) + ", " +;
            " GSI.GSI_CODENO AS " + Chr(34) + "_ENDINI" + Chr(34) + " " +;             
       " FROM " +;
            " " + RetSQLName("GSI") + " GSI JOIN " + RetSQLName("GBH") + " GBH ON ( " +;
            "     GBH.GBH_CODPAC =  GSI.GSI_REGGER " +;
            " AND GSI.GSI_FILIAL =  '" + xFilial("GSI") + "' " +;
            " AND GBH.GBH_FILIAL =  '" + xFilial("GBH") + "' " +;
            " AND GSI.D_E_L_E_T_ <> '*' " +;
            " AND GBH.D_E_L_E_T_ <> '*' " +;
            " ) " +;
       " WHERE " +;
            " GSI.GSI_REGGER BETWEEN '" + cProntDe + "' AND '" + cProntAte + "' "+;
       " ORDER BY " + SqlOrder(GSI->(IndexKey(3))) // GSI_FILIAL, GSI_REGGER, GSI_DATTRA, GSI_HORTRA 
 
	cSql := ChangeQuery( cSql )

	TCQUERY cSql NEW ALIAS "TMP"
 
 DbSelectArea("TMP")
 WHILE (!Eof())
  AAdd(aRet, { TMP->_REG, TMP->_NOME, TMP->_DATA, TMP->_ENDINI, TMP->_ENDFIN})  
  DbSkip()
 END

	DbCloseArea()
 
RETURN aRet

/*
 * Impressão do relátorio
 */
STATIC FUNCTION RunReport(Cabec1,Cabec2,cTit,nLin, aData)
 LOCAL i         := 0,;
       nDataLen  := "",; //Len(aData),;
       nPosPront := 0,;
       nPosData  := "",; //TamSx3("GSI_REGGER")[1] + Len("-") + TamSx3("GBH_NOME")[1] + 1,;
       nPosOri   := "",; //Len("DD/MM/AAAA")[1] + 1,;
       nPosDest  := "",; //TamSx3("GSI_CODEND")[1] + 1
       nMaxLin   := 0       


 nDataLen  := Len(aData)
 nPosData  := nPosPront + TamSx3("GSI_REGGER")[1] + Len("-") + nCompMaxNome + 1
 nPosOri   := nPosData + Len("DD/MM/AAAA") + 1
 nPosDest  := nPosOri + TamSx3("GSI_CODEND")[1] + 1

 cCodImp := MV_PAR03
 nMaxLin := HS_MaxLin(cCodImp)

 IF nDataLen < 0
  RETURN NIL
 ENDIF

 SetRegua(nDataLen)

 FOR i := 1 TO nDataLen
  IncRegua()
  
  IF lAbortPrint
   @nLin,000 PSAY STR0009 //"*** CANCELADO PELO OPERADOR ***"
   EXIT
  ENDIF

  If nLin > nMaxLin // Salto de Página. De acordo com a impressora
   Cabec(cTit,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   nLin := 8  
  Endif    
  
  IF i != 1
   IF aData[i][1] != aData[i-1][1]
    @ nLin, nPosPront PSAY  aData[i][1]+ "-" + SubStr(aData[i][2], 1, nCompMaxNome)
   ENDIF
  ELSE
   @ nLin, nPosPront PSAY  aData[i][1]+ "-" + SubStr(aData[i][2], 1, nCompMaxNome)
  ENDIF
  @ nLin, nPosData PSAY StoD(aData[i][3])
  @ nLin, nPosOri  PSAY aData[i][4]
  @ nLin, nPosDest PSAY aData[i][5]
  nLin++
 NEXT

 MS_FLUSH()
RETURN NIL
