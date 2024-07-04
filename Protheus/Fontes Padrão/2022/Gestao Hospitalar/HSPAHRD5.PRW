#INCLUDE "HSPAHRD5.ch"
#INCLUDE "HSPAHRD5.ch"
#include "Protheus.ch"
#include "TopConn.ch"
#include "msgraphi.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRD5 บ       ณ MARCELO JOSE       บ Data ณ /04/2005    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RESUMO DAS GLOSAS POR ITEM                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRD5()
 Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3         := ""
 Local cPict          := ""
 Local cTitulo        := STR0003 //"RESUMO DE GLOSAS"
 Local nLin           := 80 
 Local cCabec1        := STR0004 //"Grupo de Despesas"
 Local cCabec2        := STR0005 //"Convenio---------------------- Item Detalhe  por Grupo       Total-----  -- % --"
 Local imprime        := .T.
 Local aOrd           := {}

 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private Tamanho      := "P"
 Private limite       := 80
 Private m_pag        := 01
 Private nomeprog     := "HSPAHRD5"
 Private nTipo        := 18
 Private aReturn      := {STR0006, 1, STR0007, 2, 2, 1, "", 1}   //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private wnrel        := "HSPAHRD5"
 Private cString      := "GCZ"
 Private aVetor       := {}
 Private aVetGraf     := {}
 Private nTotGerI     := 0
 Private ntotGerG     := 0
 Private cPerg        := "HSPRD5"

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 If !Pergunte(cPerg,.T.)
  return
 EndIf          

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2
 
 wnrel := SetPrint(cString,NomeProg,"",@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
 
 If nLastKey == 27
  Return
 Endif
 
 SetDefault(aReturn,cString)
 
 If nLastKey == 27
  Return
 Endif
 
 RptStatus({|| RunRepRel(cCabec1, cCabec2, cTitulo, nLin)}, cTitulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunRepRel(cCabec1, cCabec2, cTitulo, nLin)
 Local oGraf
 Local nPosVet    := 0
 Local nPercen    := 0
 Local nSomaMM    := 0
 Local nSomaTD    := 0
 Local nSomaPH    := 0
 Local nTotMM     := 0
 Local nTotTD     := 0
 Local nTotPH     := 0  
 Local nTotGra    := 0
 Local nPerMM     := 0
 Local nPerTD     := 0
 Local nPerPH     := 0
 Local bRepli     := {|| REPLI("_",82) }
             
 If TCSrvType() <> "AS/400"
	 cQuery := "SELECT GCZ.GCZ_CODCON GCZ_CODCON, GA9.GA9_NOME GA9_NOME, GCZ.GCZ_VLGLOM GCZ_VLGLOM, "
  cQuery += "GCZ.GCZ_VLGLOT GCZ_VLGLOT, GCZ.GCZ_VLGLOP GCZ_VLGLOP, GE5.GE5_VALGLO VALGLO, 'MAT' TIPO  "
	 cQuery += "FROM " + RetSqlName("GCZ") + " GCZ " 
	 cQuery += " JOIN " + RetSQLName("GE5") + " GE5 ON GE5.GE5_REGATE = GCZ.GCZ_REGATE AND GE5.GE5_FILIAL = '" + xFilial("GE5") + "' AND GE5.D_E_L_E_T_ <> '*' "
	 cQuery += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
	 cQuery += " WHERE GCZ.GCZ_FILIAL = '" + xFilial( "GCZ" ) + "' AND GCZ.D_E_L_E_T_ <> '*' "
  cQuery += " AND GCZ.GCZ_DATFAT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
  cQuery += " AND GCZ.GCZ_CODCON BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
  
  cQuery += "UNION ALL "
  cQuery += "SELECT GCZ.GCZ_CODCON GCZ_CODCON, GA9.GA9_NOME GA9_NOME, GCZ.GCZ_VLGLOM GCZ_VLGLOM, "
  cQuery += "GCZ.GCZ_VLGLOT GCZ_VLGLOT, GCZ.GCZ_VLGLOP GCZ_VLGLOP, GE6.GE6_VALGLO VALGLO,'TAX' TIPO  "
	 cQuery += "FROM " + RetSqlName("GCZ") + " GCZ " 
	 cQuery += " JOIN " + RetSQLName("GE6") + " GE6 ON GE6.GE6_REGATE = GCZ.GCZ_REGATE AND GE6.GE6_FILIAL = '" + xFilial("GE6") + "' AND GE6.D_E_L_E_T_ <> '*' "
	 cQuery += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' " 	 
	 cQuery += " WHERE GCZ.GCZ_FILIAL = '" + xFilial( "GCZ" ) + "' AND GCZ.D_E_L_E_T_ <> '*' "
  cQuery += " AND GCZ.GCZ_DATFAT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
  cQuery += " AND GCZ.GCZ_CODCON BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " 
  
  cQuery += "UNION ALL "
  cQuery += "SELECT GCZ.GCZ_CODCON GCZ_CODCON, GA9.GA9_NOME GA9_NOME, GCZ.GCZ_VLGLOM GCZ_VLGLOM, "
  cQuery += "GCZ.GCZ_VLGLOT GCZ_VLGLOT, GCZ.GCZ_VLGLOP GCZ_VLGLOP, GE7.GE7_VALGLO VALGLO,'PRO' TIPO  "
	 cQuery += "FROM " + RetSqlName("GCZ") + " GCZ " 
	 cQuery += " JOIN " + RetSQLName("GE7") + " GE7 ON GE7.GE7_REGATE = GCZ.GCZ_REGATE AND GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' "
	 cQuery += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' " 	 
	 cQuery += " WHERE GCZ.GCZ_FILIAL = '" + xFilial( "GCZ" ) + "' AND GCZ.D_E_L_E_T_ <> '*' "
  cQuery += " AND GCZ.GCZ_DATFAT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
  cQuery += " AND GCZ.GCZ_CODCON BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
        
  cQuery += " ORDER BY GCZ_CODCON, TIPO"
  
  cQuery := ChangeQuery(cQuery)
	  
  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY" ,.T.,.T.)
  DbSelectArea("QRY")
  DbGoTop()
 	While !EOF()

 	 nPosVet := aScan(aVetor, {| aVetTmp | aVetTmp[1] == QRY->GCZ_CODCON } )

   If nPosVet == 0
    AADD(aVetor,{QRY->GCZ_CODCON, QRY->GA9_NOME, 0, 0, 0, 0, 0, 0})
    nPos := Len(aVetor)
   Else
    nPos := nPosVet
   EndIf 
   
   If QRY->TIPO == "MAT"
    aVetor[nPos, 3] += QRY->GCZ_VLGLOM
    aVetor[nPos, 6] += QRY->VALGLO
    nTotMM += QRY->GCZ_VLGLOM + QRY->VALGLO
   ElseIf QRY->TIPO == "TAX"  
    aVetor[nPos, 4] += QRY->GCZ_VLGLOT
    aVetor[nPos, 7] += QRY->VALGLO
    nTotTD += QRY->GCZ_VLGLOT + QRY->VALGLO
   Else  
    aVetor[nPos, 5] += QRY->GCZ_VLGLOP
    aVetor[nPos, 8] += QRY->VALGLO
    nTotPH += QRY->GCZ_VLGLOP + QRY->VALGLO
   EndIf 

   DbSkip()

  EndDo

	 DbCloseArea()
 EndIf
  
 nTotGra := nTotMM + nTotTD + nTotPH
 nPerMM  := (nTotMM / nTotGra) * 100
 nPerTD  := (nTotTD / nTotGra) * 100
 nPerPH  := (nTotPH / nTotGra) * 100

 If MV_PAR05 == 2 
  /* Monta vetor para o grafico carteziano */ 
  AADD(aVetGraf,{nPerMM, STR0008 + Str(nPerMM,6,2) + "%"} )  //"Mat/Med "
  AADD(aVetGraf,{nPerTD, STR0009 + Str(nPerTD,6,2) + "%"} )  //"Tax/Dia "
  AADD(aVetGraf,{nPerPH, STR0010 + Str(nPerPH,6,2) + "%"} )  //"Pro/Hon "
  /* CRIA O OBJETO PARA CONSTRUCAO DO GRAFICO CARTEZIANO  */
  oGraf := hsGRAF():NEW(STR0011, STR0012, STR0013 + Transform(nTotGra,"@E 999,999.99"), STR0014, STR0004, "", aVetGraf,1,1,0,0,2,15,6,6,25,20) //"RESUMO DAS GLOSAS"###"POR GRUPO DE DESPESAS"###"Valor total Glosado R$"###"Percentual %"###"Grupo de Despesas"
 EndIf

 /* chama funcao para imprimir dados do vetor geral */
 nLin := FS_ImpGrI( STR0015, 3, 6, nPerMM, cCabec1, cCabec2, cTitulo, nLin)  //"MATERIAIS E MEDICAMENTOS"
 nLin := FS_ImpGrI( STR0016, 4, 7, nPerTD, cCabec1, cCabec2, cTitulo, nLin)  //"TAXAS E DIARIAS"
 nLin := FS_ImpGrI( STR0017, 5, 8, nPerPH, cCabec1, cCabec2, cTitulo, nLin)  //"PROCEDIMENTOS E HONORARIOS"

 nLin += 2
                 
 @ nLin,15 Psay STR0018 //"Total Geral ==> "
 @ nLin,31 Psay nTotGerI Picture "@E 999,999.9999" 
 @ nLin,45 Psay nTotGerG Picture "@E 999,999.9999"
 @ nLin,59 Psay nTotGra  Picture "@E 999,999.9999"
 
 nLin++ 

 @ nLin,00 Psay Eval(bRepli)

 Set Printer to
 Set Device  to Screen
 
 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()
Return(Nil)
 
/******************************************************************************************************************/
/* Funcao para imprimir os dados do vetor              autor MARCELO JOSE                                                           */
/******************************************************************************************************************/

Static Function FS_ImpGrI( cGrupo , nIndGrup , nIndItem, nPerGrup, cCabec1, cCabec2, cTitulo, nLin)

 Local nCtaFor  := 0  
 Local nTotId   := 0
 Local nTotGr   := 0 

 For nCtaFor := 1 to Len(aVetor)  
   If lAbortPrint
    @nLin,00 PSAY STR0019 //"INTERROMPIDO PELO USUARIO"
    Exit
   Endif  
   
   If nLin > nMaxLin
    Cabec(cTitulo,cCabec1,cCabec2,NomeProg,Tamanho,nTipo)
    nLin := 9
   EndIF
   
   If nCtaFor == 1
    nLin++
    @ nLin,00 Psay cGrupo
    nLin += 2
   EndIf 
    
   @ nLin,02 Psay PADR(aVetor[nCtaFor, 2], 28)
   @ nLin,31 Psay aVetor[nCtaFor, nIndItem] Picture "@E 999,999.9999" /* POR ITEM */
   @ nLin,45 Psay aVetor[nCtaFor, nIndGrup] Picture "@E 999,999.9999" /* POR GRUPO*/
   @ nLin,59 Psay ( aVetor[nCtaFor, nIndGrup] + aVetor[nCtaFor, nIndItem] ) Picture "@E 999,999.9999"
   nLin++
   nTotId := nTotId + aVetor[nCtaFor,nIndItem]
   nTotGr := nTotGr + aVetor[nCtaFor,nIndGrup]
  Next
  nLin++
  @ nLin,21 Psay STR0020 //"Total ==> "
  @ nLin,31 Psay nTotId Picture "@E 999,999.9999" 
  @ nLin,45 Psay nTotGr Picture "@E 999,999.9999"
  @ nLin,59 Psay (nTotId+nTotGr) Picture "@E 999,999.9999"
  @ nLin,73 Psay nPerGrup Picture "999.99"

  nLin++
  nTotGerI  := nTotGerI + nTotId
  nTotGerG  := nTotGerG + nTotGr
 
 Return(nLin)
 
/******************************************************************************************************************/
/* CLASSE : hsGRAF                           AUTOR: MARCELO JOSE                                 DATA: 13/04/2005 */
/******************************************************************************************************************/
/* Descricao: MONTA GRAFICOS CARTEZIANOS                                                                          */
/******************************************************************************************************************/
/*           | cTitForm  - titulo do formulario                                                                   */
/*           |  cTitGraf  - titulo do grafico                                                                     */
/*           |  cVert1    - descricao do eixo y                                                                   */  
/*           |  cVert2    - descricao do eixo y                                                                   */
/*           |  cHori1    - descricao do eixo X                                                                   */
/*           |  cHori2    - descricao do eixo X                                                                   */ 
/*Parametros |  aVemVet   - vetor que contem os dados do grafico                                                  */
/*    do   --|  nQuantSer - Quantidade de serie dos graficos (Tem quantidades maxima de 3 series)                 */
/*  Method   |  nIndiceY1 - indice do vetor que contem os dados do eixo y da serie 1                              */
/*   NEW     |  nIndiceY2 - indice do vetor que contem os dados do eixo y da serie 2                              */
/*           |  nIndiceY3 - indice do vetor que contem os dados do eixo y da serie 3                              */
/*           |  nIndiceX  - indice do vetor que contem os dados do eixo X                                         */
/*           |  nTamX     - Comprimento dos Itens do Eixo X                                                       */
/*           |  nTop      - Coordenada canto superior esquerdo                                                    */
/*           |  nLeft     - coordenada canto superior esquerdo                                                    */
/*           |  nBotton   - coordenada canto inferior direito                                                     */
/*           |  nRight    - coordenada canto inferior direito                                                     */
/******************************************************************************************************************/
CLASS hsGRAF

 Data oMSGraphic
 Data oDlgGraf
 Data oBmp
 Data oBold
 Data oSay1
 Data oBut1
 Data oBut2
 Data oBut3
 Data oBut4
 Data oBut5
 Data oBut6
 Data lStart
 Data nOldCbx
 Data pVemVet
 Data pQuantSer
 Data pIndiceY1
 Data pIndiceY2
 Data pIndiceY3
 Data pIndiceX
 Data pTamX
 
 METHOD NEW ( cTitForm , cTitGraf , cVert1 , cVert2 , cHori1 , cHori2 , aVemVet , nQuantSer , nIndiceY1 , nIndiceY2 , nIndiceY3 , nIndiceX , nTamX , nTop , nLeft , nBottom , nRight ) CONSTRUCTOR
 METHOD TipoGraf() CONSTRUCTOR
 METHOD MontGraf( nCbx ) CONSTRUCTOR
 METHOD GravGraf( oMSGraphic ) CONSTRUCTOR
 METHOD PrinGraf() CONSTRUCTOR
 
ENDCLASS 

/**************************/
/* INCIALIZA O FORMULARIO */
/**************************/

METHOD NEW ( cTitForm , cTitGraf , cVert1 , cVert2 , cHori1 , cHori2 , aVemVet , nQuantSer , nIndiceY1 , nIndiceY2 , nIndiceY3 , nIndiceX , nTamX ,nTop , nLeft , nBottom , nRight ) CLASS hsGRAF

 Local bSett := {|| ::MontGraf( 4 ), ::oMSGraphic:l3D := .F.}
 Local aSize := {}
  
 ::pVemVet   := aVemVet
 ::pQuantSer := nQuantSer
 ::pIndiceY1 := nIndiceY1
 ::pIndiceY2 := nIndiceY2
 ::pIndiceY3 := nIndiceY3
 ::pIndiceX  := nIndiceX
 ::pTamX     := nTamX
 ::lStart    := .F.
 ::nOldCbx   := 4 /* Inicializa o tipo de grafico No. 4  */
 
 aSize := MsAdvSize(.T.)

  
 DEFINE FONT ::oBold NAME "Arial" SIZE 0, -13 BOLD
 
 DEFINE MSDIALOG ::oDlgGraf FROM aSize[7], 000 To aSize[6], aSize[5]PIXEL TITLE cTitForm
  @ 000, 000 BITMAP ::oBmp RESNAME "ProjetoAP" oF ::oDlgGraf SIZE 80, 280 NOBORDER WHEN .F. PIXEL
  @ 003, 060 SAY cTitGraf FONT ::oBold PIXEL
  @ 014, 010 TO 16 ,500 LABEL '' OF ::oDlgGraf  PIXEL
  @ 020, 010 MSGRAPHIC ::oMSGraphic SIZE 490, 230 OF ::oDlgGraf
      
  ::oMSGraphic:bLClicked := {|o| HS_MsgInf(STR0035, STR0033, STR0036) } //"Click"###"Aviso"###"Incializa Formulario"
  ::oMSGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
  ::oMSGraphic:SetTitle( cVert1, cVert2, CLR_BLACK , A_LEFTJUST , GRP_TITLE )
  ::oMSGraphic:SetTitle( cHori1, cHori2, CLR_BLACK , A_RIGHTJUS , GRP_FOOT  )
  ::oMSGraphic:SetMargins( nTop, nLeft, nBottom, nRight )
  ::oMSGraphic:SetLegenProp( GRP_SCRBOTTOM, CLR_WHITE, GRP_SERIES, .F. ) 
  
  @ 257, 010 TO 259 ,500 LABEL '' OF ::oDlgGraf  PIXEL               
  
  ::oSay1 := tSay():New(265,195,{||STR0021},::oDlgGraf,,,,,,.T.,,,30,10)  //"Zoom"
  ::oBut1 := tButton():New(263,100,STR0022,::oDlgGraf,{|| ::TipoGraf()  },60,12,,,,.T.)  //"Tipo de Grafico"
  ::oBut2 := tButton():New(263,175,"+"   ,::oDlgGraf,{|| ::oMSGraphic:ZoomIn()  },18,12,,,,.T.)
  ::oBut3 := tButton():New(263,210,"-"   ,::oDlgGraf,{|| ::oMSGraphic:ZoomOut()  },18,12,,,,.T.)
  ::oBut4 := tButton():New(263,235,STR0023  ,::oDlgGraf,{|| ::oMSGraphic:l3D := !::oMSGraphic:l3D  },40,12,,,,.T.)  //"3D"
  ::oBut6 := tButton():New(263,285,STR0024 ,::oDlgGraf,{|| ::GravGraf(::oMSGraphic,cTitForm,cTitGraf)  },40,12,,,,.T.)  //"Impr"
  ::oBut5 := tButton():New(263,340,STR0025,::oDlgGraf,{|| ::oDlgGraf:End() },40,12,,,,.T.)  //"Sair"
 
  If ::lStart == .F.
   EVAL ( bSett )
  EndIf                                     
 
 ACTIVATE MSDIALOG ::oDlgGraf CENTER

Return(Nil)

/*****************************/
/* ESCOLHE O TIPO DE GRAFICO */
/* Autor: MARCELO JOSE       */
/*****************************/

METHOD TipoGraf() CLASS hsGRAF

 Local oDlgSer
 Local oCbx
 Local bCodeOne := {|| ::MontGraf(nCbx), oDlgSer:End() }
 Local nCbx     := 1
 Local cCbx     := STR0026 //"Linha"
 Local aCbx     := { STR0026, STR0027, STR0028, STR0029}/*, "Piramid", "Cilindro",; //"Linha"###"มrea"###"Pontos"###"Barras"
            				 "Barras Horizontal", "Piramid Horizontal", "Cilindro Horizontal",;
            				 "Pizza", "Forma", "Linha rแpida", "Flexas", "GANTT", "Bolha" }*/

 DEFINE MSDIALOG oDlgSer TITLE STR0037 FROM 0,0 TO 100,165 PIXEL OF ::oDlgGraf  //"Modelo de Grafico"
  @ 008, 010 SAY STR0030 PIXEL OF oDlgSer  //"Escolha o Modelo:"
  @ 018, 010 MSCOMBOBOX oCbx VAR cCbx ITEMS aCbx SIZE 061, 65 OF oDlgSer PIXEL ON CHANGE nCbx := oCbx:nAt
  @ 035, 010 BUTTON STR0031   SIZE 30,12 OF oDlgSer PIXEL ACTION EVAL ( bCodeOne )  //"Ok"
  @ 035, 040 BUTTON STR0025 SIZE 30,12 OF oDlgSer PIXEL ACTION oDlgSer:End()  //"Sair"
 ACTIVATE MSDIALOG oDlgSer CENTER

Return ( Nil )

/***********************/
/*   MONTA O GRAFICO   */
/* Autor: MARCELO JOSE */
/***********************/

METHOD MontGraf( nCbx ) CLASS hsGRAF

 Local nIncre
 Local bMax    := {|| Len(::pVemVet) }
 Local bAdSer1 := {|| ::oMSGraphic:Add( 1 , ::pVemVet[nIncre,::pIndiceY1] , PADR(::pVemVet[nIncre,::pIndiceX],::pTamX) , CLR_HRED ) }
 Local bAdSer2 := {|| ::oMSGraphic:Add( 2 , ::pVemVet[nIncre,::pIndiceY2] , PADR(::pVemVet[nIncre,::pIndiceX],::pTamX) , CLR_YELLOW ) }
 Local bAdSer3 := {|| ::oMSGraphic:Add( 3 , ::pVemVet[nIncre,::pIndiceY3] , PADR(::pVemVet[nIncre,::pIndiceX],::pTamX) , CLR_HBLUE ) }
 Local bCreSer := {|| ::oMSGraphic:CreateSerie( nCbx ) }

 If ::lStart == .F.
  ::lStart  := .T.  
  If ::pIndiceY1 > 0
   EVAL ( bCreSer )
   For nIncre := 1 To EVAL( bMax )
   	EVAL ( bAdSer1 )
   Next nIncre
  EndIf
  If ::pIndiceY2 > 0
   EVAL ( bCreSer )
   For nIncre := 1 To EVAL( bMax )
   	EVAL ( bAdSer2 )
   Next nIncre
  EndIf
  If ::pIndiceY3 > 0 
   EVAL ( bCreSer )
   For nIncre := 1 To EVAL( bMax )
   	EVAL ( bAdSer3 )
   Next nIncre
  EndIf
 Else
  EVAL ( bCreSer )
 EndIf
  
Return( Nil ) 
/***********************/
/*   SALVA O GRAFICO   */
/* Autor: MARCELO JOSE */
/***********************/
METHOD GravGraf( oMSGraphic,cfTit,cgTit ) CLASS hsGRAF
 Local bGrvGf := {|N,L| IIf(oMSGraphic:SaveToBMP(N,L), ::PrinGraf(N,cfTit,cgTit),	HS_MsgInf(STR0032, STR0033, STR0034))}  //"Experimente Mais um nivel de Zoom para viabilizar a impressao Ok..."###"Aviso"###"Monta o grafico"
 Eval( bGrvGf, "GrafB.BMP", "\" )
Return( Nil )
/***********************/
/*  IMPRIME O GRAFICO  */
/* Autor: MARCELO JOSE */
/***********************/
METHOD PrinGraf( cNameGF,cfTit,cgTit ) CLASS hsGRAF
 Local oFont1 := TFont():New("Arial",9,14 ,.T.,.F.,5,.T.,5,.T.,.F.), oFont2 := TFont():New("Arial",9,10 ,.T.,.F.,5,.T.,5,.T.,.F.)
 Local bImpGf := {|N| IIf(File(N),Eval( bSetaI, N ),) } 
 Local bSetaI := {|N| oPrint:=TMSPrinter():New(""), oPrint:Setup(), oPrint:StartPage(),oPrint:Say(100,100,cfTit,oFont1),oPrint:Say(200,150,cgTit,oFont2), oPrint:SayBitmap( 300,100,N, 3000, 2100 ), oPrint:endpage(), oPrint:PRINT(), Ms_Flush() }
 Eval( bImpGf, "\"+cNameGF )
Return( Nil )
