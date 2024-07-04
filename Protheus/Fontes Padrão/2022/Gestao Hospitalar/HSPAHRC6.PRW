#include "Protheus.ch"            
#INCLUDE "HSPAHRC6.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRC6  บ Autor ณ Daniel Peixoto     บ Data ณ  24/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Descritivo da Fatura                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRC6(cProgCh, aGuiasP12)

Local cDesc1  := STR0001 //"Este programa tem como objetivo imprimir relat๓rio "
Local cDesc2  := STR0002 //"de acordo com os parโmetros informados pelo usuแrio."
Local cDesc3  := STR0003 //"Emissใo Descritiva da Fatura"
Local cPict   := ""
Local imprime := .T.
Local aOrd    := {}
Local aArea   := GetArea()
Local aGuias  := Iif(!Empty(aGuiasP12), aClone(aGuiasP12), {})

Private cTitulo     := STR0003 //"Emissใo Descritiva da Fatura"
Private nLin        := 80
Private Cabec1      := ""
Private Cabec2      := ""
Private bRepli      := {|| REPLI("_", limite)}
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 132
Private tamanho     := "M"
Private nomeprog    := "HSPAHRC6"
Private nTipo       := 18
Private aReturn     := {STR0004, 1, STR0005, 2, 1, 1, "", 1} //"Zebrado"###"Administra็ใo"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "HSPAHRC6"
Private cString     := ""
Private lChamado    := !Empty(cProgCh)
Private cCODIMP     := ""
Private nMaxLin     := 0
Private nMaxConta:=0
Private lTamProd := IIf((TamSx3("GBI_PRODUT")[1])<=15, .T., .F.)

If ExistBlock("HSERC6")
 If ExecBlock("HSERC6",.F.,.F.,{cProgCh, aGuiasP12})
  Return Nil
 Endif
EndIf

If !lChamado
 If !Pergunte("HSRC6B", .T.)
  Return
 Else
  nTpFat      := MV_PAR01
  cRegAte_De  := MV_PAR02
  cRegAte_Ate := MV_PAR03
  cNrGuia_De  := MV_PAR04
  cNrGuia_Ate := MV_PAR05
  nOrdemDesp  := MV_PAR06
  nApresDesc  := MV_PAR07
  lIpmGraf    := MV_PAR08 == 1
  
  aGuias := HS_RC6Guias(nTpFat, cRegAte_De, cRegAte_Ate, cNrGuia_De, cNrGuia_Ate)
 EndIf
 
Else
 
 If !Pergunte("HSRC6A", .T.)
  Return
 Else
  nOrdemGuia  := MV_PAR01
  nOrdemDesp  := MV_PAR02
  nApresDesc  := MV_PAR03
  lIpmGraf    := MV_PAR04 == 1
 Endif
EndIf

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

If len(aGuias) == 0
 HS_MsgInf(STR0020, STR0032, STR0031) //"Nenhuma guia foi selecionada. Verifique!"###"Aten็ใo"###"Descritivo da Fatura"
 Return()
EndIf

If lIpmGraf
 
 RptStatus({ || FS_RunGraf(aGuias) }, cTitulo)
 
Else
 
 wnrel := SetPrint(cString, NomeProg, Nil, @cTitulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho)
 
 If nLastKey == 27
  Return
 EndIf
 
 SetDefault(aReturn, cString)
 
 If nLastKey == 27
  Return
 EndIf
 
 nTipo := If(aReturn[4] == 1, 15, 18)
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 
 RptStatus({|| RunReport(aGuias)}, cTitulo)
 
 SET PRINTER TO
 SET DEVICE TO SCREEN
 
 If aReturn[5] == 1
  DbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 EndIf
 
 MS_FLUSH()
 
 RestArea(aArea)
 
EndIf // Imp Matricial

Return(NIL)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  16/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(aGuias)
Local cDESCUNC := ""
Local cDESCGRU := ""
Local cRepDir  := ""
Local nTotGer  := 0
Local nGrpDesp := 0, nPosDesc := 0
Local nUniCons := 0
Local nForGui  := 0
Local aRet     := {}
Local nCont    := 0
Local nTotDsc  := 0
Private aVetDes := {}
Private aVetCir := {}

If FunName() <> "HSPAHP12"
 aSort(aGuias,,,{|x,y| x[2]+x[1] < y[2]+y[1]}) //REGATE + NRSEQG
Else
 If !Empty(aGuias[1,3]) .And. nOrdemGuia == 1
  aSort(aGuias,,,{|x,y| x[3] < y[3]})
 Endif
Endif

For nForGui := 1 to len(aGuias)
 
 FS_RETGUIA(aGuias[nForGui, 1]) // Recupera a guia atual
 
 For nCont := 1 To Len(aVetDes)
  
  If nLin > nMaxLin .Or. aVetDes[nCont, 2] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 2]
   nLin := FS_CabEmp(nLin, nCont)
//   nLin := 10
   
   If nCont == 1
    nLin := FS_AUTGUI(GCZ->GCZ_NRSEQG, nLin)
    If !Empty(aVetCir)
     nLin := FS_ATUCIR(nLin)
    Endif
   EndIf
   
   nLin++
   
   //                                    1         2         3         4         5         6         7         8         9         10        11        12        13
   //                          0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.12 */
   @ nLin, 000 pSay STR0015 //"Cod. Despesa   Nome Despesa            Coef.Desp  Filme      Qtd.CH     Qtd.CO   Un.    Quanti.            Vl.Unit.         Vl.Total"
   nLin++
   //                                    1         2         3         4         5         6         7         8         9         10        11        12        13
   //                          0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.12 */
   @ nLin, 000 pSay STR0016// "CRM            M้dico                  Coef.Ato   Ato                                   Urgencia           Desconto"                                                                                                                                                                                                                                                                                                                                                                                          
   nLin++
  EndIf
  
  //Quebra do grupo de Unidade de Consumo
  If IIF(nCont > 1, aVetDes[nCont, 3] != aVetDes[nCont-1, 3], .T.)
   @ nLin, 000 pSay REPLICATE("-", 132)
   nLin++
   @ nLin, 000 pSay aVetDes[nCont, 3]
   nLin += 2
  EndIf
  
  // Quebra do grupo de Despesas
  If IIF(nCont > 1, aVetDes[nCont, 4] != aVetDes[nCont-1, 4] .Or. aVetDes[nCont, 3] != aVetDes[nCont-1, 3], .T.)
   @ nLin, 000 pSay aVetDes[nCont, 4]
   nLin++
  EndIf
  
  @ nLin, 000 pSay PADL(ALLTRIM(aVetDes[nCont, 5]), 10) //Codigo do Material
  @ nLin, 010 pSay " - " + SubStr(aVetDes[nCont, 6], 1, 29) //Descri็ao do Produto
  
  If aVetDes[nCont, 1] == "G5"
      @ nLin, 052 pSay PADR(ALLTRIM(aVetDes[nCont, 11]), iif(lTamProd,15,30)) //Codigo do Sistema
      //@ nLin, 062 pSay PADR(ALLTRIM(aVetDes[nCont, 12]), 20) //Fabricante
  EndIf
  
  If aVetDes[nCont, 1] == "G7"
   @ nLin, 040 pSay PADR(Transform(aVetDes[nCont, 13], "@E 99.99"),5) //Coef.Desp
   If aVetDes[nCont, 15] <> 0
    @ nLin, 050 pSay PADL(Transform(aVetDes[nCont, 8] * aVetDes[nCont, 15], "@E 99,999.9999"), 11) // Valor Filme
   EndIf
   @ nLin, 062 pSay PADL(Transform(aVetDes[nCont, 14], "@E 99,999.99"), 9) //Qtd. CH
   @ nLin, 065 pSay PADL(Transform(aVetDes[nCont, 16], "@E 9,999,999.999"), 13) //Qtd. CO
  EndIf                                                                                                                 
  
  @ nLin, 071 pSay aVetDes[nCont, 7] //Unidade de Medida
  @ nLin, 084 pSay PADL(Transform(aVetDes[nCont, 8] , "@E 999,999.99"), 10) //Quantidade
  @ nLin, 101 pSay PADL(Transform(aVetDes[nCont, 9] , "@E 999,999,999.9999"), 16) //Vlr. Unit.
  @ nLin, 120 pSay PADL(Transform(aVetDes[nCont, 10], "@E 999,999,999.99"), 14) //Vlr. Total
  
  If aVetDes[nCont, 1] == "G5" .And. aVetDes[nCont, 17] $ "1/2/3" 
      nLin++ 
	  @ nLin, 003 pSay aVetDes[nCont, 16] //CRM
      @ nLin, 010 pSay SubStr(aVetDes[nCont, 15], 1, 36) //Medico
  EndIf
  
  If aVetDes[nCont, 1] == "G7"
   nLin++
   @ nLin, 000 pSay aVetDes[nCont, 17] //CRM
   @ nLin, 008 pSay SubStr(aVetDes[nCont, 11], 1, 30) //Medico
   @ nLin, 039 pSay PADR(Transform(aVetDes[nCont, 18], "@E 99.99"),5) //Coef.Ato
   @ nLin, 049 pSay SubStr(aVetDes[nCont, 12], 1, 25) //Ato
   @ nLin, 089 pSay HS_RDescrB("GD7_URGDES", aVetDes[nCont, 22]) //Urgencia
  EndIf
  
  nPosDesc := IIF(aVetDes[nCont, 1] == "G5", 13, IIF(aVetDes[nCont, 1] == "G6", 11, 20))
  
  If !Empty(aVetDes[nCont,nPosDesc])
   nTotDsc += aVetDes[nCont,nPosDesc]
   If aVetDes[nCont, 1] <> "G7"
    nLin ++
    If nApresDesc == 1 .And. !Empty(aVetDes[nCont, nPosDesc+1])
     @ nLin, 061 pSay STR0035 + SubStr(ALLTRIM(aVetDes[nCont, nPosDesc+1]),1,37)  //"Mot. Desc.: "
    Endif
    @ nLin, 109 pSay Transform(aVetDes[nCont,nPosDesc], "@E 99,999.9999") // Valor Desconto
   Else
    @ nLin, 109 pSay Transform(aVetDes[nCont,nPosDesc], "@E 99,999.9999") // Valor Desconto
    If nApresDesc == 1 .And. !Empty(aVetDes[nCont, nPosDesc+1])
     nLin ++
     @ nLin, 061 pSay STR0035 + SubStr(ALLTRIM(aVetDes[nCont, nPosDesc+1]),1,37)  //"Mot. Desc.: "
    Endif
   Endif
   
  Endif
  
  nGrpDesp += Iif(aVetDes[nCont, 1] # "G7" .Or. aVetDes[nCont, 19] # "0", aVetDes[nCont, 10], 0)//Se for repasse direto nใo somatiza no total
  nTotGer  += Iif(aVetDes[nCont, 1] # "G7" .Or. aVetDes[nCont, 19] # "0", aVetDes[nCont, 10], 0)//Se for repasse direto nใo somatiza no total
  
  nLin++
  
  // Imprime o total do grupo de despesas
  If aVetDes[nCont, 4] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 4];
   .Or. aVetDes[nCont, 3] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 3];
   .Or. aVetDes[nCont, 2] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 2];
   .Or. nCont == Len(aVetDes)
   
   @ nLin, 023 pSay STR0017 //"Total do Grupo "
   @ nLin, 119 pSay nGrpDesp PICTURE "@E 999,999,999.99"
   nUniCons += Iif(aVetDes[nCont, 1] # "G7" .Or. aVetDes[nCont, 19] # "0", nGrpDesp, 0)//Se for repasse direto nใo somatiza no total
   nGrpDesp := 0
   nLin += 2
   
  EndIf
  
  //Imprime o total da unidade de consumo
  If aVetDes[nCont, 3] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 3] ;
   .Or. aVetDes[nCont, 2] != aVetDes[IIF((nCont) == Len(aVetDes), nCont, nCont + 1), 2] ;
   .Or. nCont == Len(aVetDes)
   
   If aVetDes[nCont, 3] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 3] .Or. nCont == Len(aVetDes)
    
    @ nLin, 023 pSay STR0018 //"Total da Unidade de Consumo"
    @ nLin, 119 pSay nUniCons PICTURE "@E 999,999,999.99"
    nLin += 2
    nUniCons := 0
    
   EndIf
   
   If nCont == Len(aVetDes)
    
    @ nLin, 023 pSay STR0068//"Total Desconto"
    @ nLin, 119 pSay nTotDsc PICTURE "@E 999,999,999.99"
    nTotDsc := 0
    
    nLin++
    
    @ nLin, 023 pSay STR0019 //"Total Geral"
    @ nLin, 119 pSay nTotGer PICTURE "@E 999,999,999.99"
    nTotGer := 0
    
   EndIf
   
   If aVetDes[nCont, 2] != aVetDes[IIF((nCont) == Len(aVetDes), nCont, nCont + 1), 2] .Or. nCont == Len(aVetDes)
    
    nUniCons := 0
    nLin     := nMaxLin * 2 // Forca um salto de pagina
    
   EndIf
   
  EndIf
  
 Next
 
 aVetDes := {}
 aVetCir := {}
 
Next nForGui

Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_RC6Guiasบ Autor ณMicrosiga           บ Data ณ  02/13/06   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Seleciona as guias, de acordo com as informacoes dos parame_บฑฑ
ฑฑบ          ณ tros iniciais.                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Principal                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_RC6Guias(nTpFat, cRegAte_De, cRegAte_Ate, cNrGuia_De, cNrGuia_Ate)

Local aArea  := GetArea()
Local aGuias := {}
Local cSQL   := ""

cSQL := "SELECT GCZ.GCZ_NRSEQG , GCZ.GCZ_REGATE "
cSQL += "FROM " + RetSQLName("GCZ") + " GCZ "
cSQL += " JOIN " + RetSQLName("GCU") + " GCU ON GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' "
cSQL += " AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TPGUIA <> '7' "  //Nใo Apresenta Guias Tipo Retorno 
cSQL += "WHERE GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
cSQL += "AND GCZ.GCZ_REGATE BETWEEN '" + cRegAte_De + "' AND '" + cRegAte_Ate + "' "
cSQL += "AND GCZ.GCZ_NRGUIA BETWEEN '" + cNrGuia_De + "' AND '" + cNrGuia_Ate + "' "
cSQL += "AND GCZ.GCZ_STATUS"

If nTpFat == 1
 cSQL += " IN "
Else
 cSQL += " NOT IN "
EndIf

cSQL += "('0', '1') "
cSQL += "ORDER BY GCZ.GCZ_NRSEQG"

TCQUERY cSQL NEW ALIAS "QRY"

DbSelectArea("QRY")
DbGoTop()
While !Eof()
 aAdd(aGuias, {QRY->GCZ_NRSEQG, QRY->GCZ_REGATE})
 DbSkip()
End

aSort(aGuias,,,{|x,y| x[2]+x[1] < y[2]+y[1]})
DbCloseArea()

RestArea(aArea)

Return(aGuias)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CabEmp บ Autor ณMario Arizono       บ Data ณ  21/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Imprime o cabecalho.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao RunReport                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_CabEmp(nLin, nContCab)

Cabec(cTitulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)

       


@ 06, 00 pSay STR0009 + aVetDes[nContCab, 2] + "                 " +  ; //"Atendimento: "
              STR0010 + SubStr(HS_INIPADR("GCY", 1, aVetDes[nContCab, 2], "GCY_NOME"), 1, 36) + " " + ;//"Paciente.: "
              STR0024 + HS_INIPADR("GD4", 1, GCY->GCY_REGGER + GCZ->GCZ_CODPLA,"GD4_MATRIC",,.F.) //"Matrํcula: "
              
@ 07, 00 pSay "                                    " + STR0011 + PADR(DTOC(GCY->GCY_DATATE),10) + " " + ; 
              GCY->GCY_HORATE + "                     " + ; //"Entrada..: "
              STR0025 + PADR(DTOC(GCY->GCY_DATALT),10) + " " + (GCY->GCY_HORALT)//"Dt.Alt.: "  
              
               
@ 08, 00 pSay STR0027 + GCZ->GCZ_NRGUIA + "   "+ ; // Guia numero:
              STR0012 + SubStr(HS_INIPADR("GA9", 1, GCZ->GCZ_CODCON, "GA9_NREDUZ"), 1, 20) + "                 " + ; //"Convenio.: "
              STR0013 + SubStr(HS_INIPADR("GCM", 2, GCZ->GCZ_CODPLA, "GCM_DESPLA"), 1, 25) + " " //"Plano....: " 
                          
              
@ 09, 00 pSay "     " + STR0026 + GCZ->GCZ_NRSEQG + "                 " + ; //Seq...:
              STR0033 + GD4->GD4_SQCATP + " - " + SubStr(HS_INIPADR("GFV", 1, GD4->GD4_CODPLA + GD4->GD4_SQCATP, "GFV_NOMCAT"), 1, 10) + ; //"Categoria: "
              "                     " + STR0014 + GCZ->GCZ_NRFATU  //"Fat......: "
    
   
@ 10, 00 pSay "                                    " + STR0021 + PADR(DTOC(GCZ->GCZ_DCPARI),10) + "                           " + ; //"Dt.F.Ini.: "  
              STR0022 +  Dtoc(IIF(((EMPTY(GCY->GCY_DATALT).or.GCY->GCY_DATALT>GCZ->GCZ_DCPARF).AND.GCZ->GCZ_CTAPAR<>nMaxConta ), GCZ->GCZ_DCPARF, GCY->GCY_DATALT    ))  //"Dt.F.Fin.:"
 
   
@ 11, 00 pSay STR0067 + GCZ->GCZ_NUMORC + "   " + STR0023 + ALLTRIM(STR(GCZ->GCZ_CTAPAR, 2)) + "        " + ; //"Numer. Orc.: "##"Nr.Fech..: "
              STR0028 + GCY->GCY_CIDALT + "                             " + ; //"CID: "
              STR0029 + GCZ->GCZ_NRSEN1 //"Senha: "
      
      
      
@ 12, 00 pSay Eval(bRepli)

Return(13)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_AUTGUI บ Autor ณMario Arizono       บ Data ณ  21/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Imprime as autorizacoes da guia.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao RunReport                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FS_AUTGUI(cNrSeqg, nLin)

Local aArea := GetArea()

DbSelectArea("GE8")
DbSetOrder(2) //GE8_FILIAL + GE8_NRSEQG
If Dbseek(xFilial("GE8") + cNrSeqg)
 nLin++
 
 /*        1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
 0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
 
 @ nLin, 000 pSay STR0030 // "N. Autorizacao         Senha Autorizacao      Data Autorizacao   Data Vencimento   N. Dias Autorizados    Tipo de Diแria"
 nLin++
 
 While !Eof() .And. GE8->GE8_FILIAL == xFilial("GE8") .And. GE8->GE8_NRSEQG = cNrSeqg
  @ nLin, 000 pSay GE8->GE8_NROAUT
  @ nLin, 023 pSay GE8->GE8_SENAUT
  @ nLin, 046 pSay HS_DTOC(GE8->GE8_DATLIB,1)
  @ nLin, 065 pSay HS_DTOC(GE8->GE8_DATVEN,1)
  @ nLin, 083 pSay PADL(ALLTRIM(Transform(GE8->GE8_QTDLIB, "@E 99")), 2, " ")
  @ nLin, 106 pSay HS_RDescrB("GE8_TPDIAR", GE8->GE8_TPDIAR)
  nLin++
  
  DbSkip()
  
 EndDo
 
 @ nLin, 000 pSay Eval(bRepli)
 nLin++
 
EndIf

RestArea(aArea)

Return(nLin)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ATUCIR บ Autor ณMario Arizono       บ Data ณ  30/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Imprime o detalhamento da cirurgia.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao RunReport                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FS_ATUCIR(nLin)

Local aArea := GetArea()
Local nPos  := 0

nLin++

/*        1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */

@ nLin, 000 pSay STR0034 // "Documento   Inicio Cirurgia  Fim Cirurgia   Cod. Procedimento  Descricao                       Via    Anestesia "
nLin++

For nPos := 1 to len(aVetCir)
 
 @ nLin, 000 pSay SubStr(aVetCir[nPos, 1],1,10)
 @ nLin, 012 pSay aVetCir[nPos, 2]+ " " + aVetCir[nPos, 3]
 @ nLin, 029 pSay aVetCir[nPos, 4]+ " " + aVetCir[nPos, 5]
 @ nLin, 044 pSay SubStr(aVetCir[nPos, 6],1,15)
 @ nLin, 063 pSay SubStr(aVetCir[nPos, 7],1,30)
 @ nLin, 095 pSay ALLTRIM(Transform(aVetCir[nPos, 8], "@E 99.99"))
 @ nLin, 102 pSay SubStr(aVetCir[nPos, 9],1,30)
 nLin++
Next nPos
@ nLin, 000 pSay Eval(bRepli)
nLin++

RestArea(aArea)

Return(nLin)


Static Function FS_RETGUIA(cGuia)
Local cQry       := ""
Local nPos       := 0
Local cRepDir    := ""
Local cGD5       := ""
Local cGD6       := ""
Local cGD7       := ""
Local nContAg    := 0
Local nContAg2   := 0
Local lAgl       := .F.
Local cReg       := ""
DbSelectArea("GCZ")
DbSetOrder(1) //GCZ_FILIAL + GCZ_NRSEQG + GCZ_STATUS
GCZ->(DbSeek(xFilial("GCZ") + cGuia))

If lChamado
 cGD5 := IIF(GCZ->GCZ_STATUS $ "0/1", "GD5", "GE5")
 cGD6 := IIF(GCZ->GCZ_STATUS $ "0/1", "GD6", "GE6")
 cGD7 := IIF(GCZ->GCZ_STATUS $ "0/1", "GD7", "GE7")
Else
 cGD5 := IIF(nTpFat == 1, "GD5", "GE5")
 cGD6 := IIF(nTpFat == 1, "GD6", "GE6")
 cGD7 := IIF(nTpFat == 1, "GD7", "GE7")
EndIf

cRepDir := HS_INIPADR("GA9",1, GCZ->GCZ_CODCON, "GA9_REPDIR",,.F.)

cQry := "SELECT DISTINCT 'G5' AS IDTAB," + cGD5 + "_SEQDES TRB_SEQ , " + cGD5 + "_REGATE TRB_REGATE, " + cGD5 + "_NRSEQG TRB_NRSEQG, GCS_CODUNC TRB_CODUNC, GCT_DESUNC TRB_DESUNC, "
cQry += " GBI_CODGDE TRB_CODGDE, GBI_UNICON TRB_UNICON, GAW_DESC TRB_DESGRP, B1_FABRIC TRB_FABRIC, B1_UM TRB_UM, " + cGD5 + "_QTDDES TRB_QTDDES, "
cQry += " " + cGD5 + "_VALDES TRB_VALDES, " + HS_FVALDES(cGD5) + " TRB_VALTOT, 0 TRB_COEDES, 0 TRB_QTDCHP, 0 TRB_VFILME, 0 TRB_VLRCOS, RA_NOME TRB_NOMMED, ' ' TRB_CODATO, ' ' TRB_DESATO, "
cQry += " " + cGD5 + "_CODPRO TRB_CODIGO, " + cGD5 + "_DESPRO TRB_DESC, " + cGD5 + "_CODDES TRB_CDESP, " + cGD5 + "_CODCRM TRB_CRM, ' ' TRB_DOCCIR, ' ' TRB_DATFIM, ' ' TRB_HORFIM, "
cQry += " ' ' TRB_TIPATM, ' ' TRB_HORDES, ' ' TRB_DATDES, ' ' TRB_TPANES, " + cGD5 + "_PGTMED TRB_PGTMED, 0 TRB_COEFAM, " + cGD5 + "_DESVAL TRB_DESVAL,  " + cGD5 + "_DESOBS TRB_DESOBS,' ' TRB_TIPPRO, "
cQry += " ' ' TRB_URGDES"
cQry += " FROM " + RetSqlName(cGD5) + " " + cGD5
cQry += " JOIN " + RetSqlName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = " + cGD5 + "." + cGD5 + "_CODLOC "
cQry += " JOIN " + RetSqlName("GCT") + " GCT ON GCT.GCT_FILIAL = '" + xFilial("GCT") + "' AND GCT.D_E_L_E_T_ <> '*' AND GCT.GCT_CODUNC = GCS.GCS_CODUNC "
cQry += " JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD     = " + cGD5 + "." + cGD5 + "_CODDES "
cQry += " JOIN " + RetSqlName("GBI") + " GBI ON GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' AND GBI.GBI_PRODUT = SB1.B1_COD "
cQry += " JOIN " + RetSqlName("GAW") + " GAW ON GAW.GAW_FILIAL = '" + xFilial("GAW") + "' AND GAW.D_E_L_E_T_ <> '*' AND GAW.GAW_CODGDE = GBI.GBI_CODGDE "
cQry += " LEFT JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO  = " + cGD5 + "." + cGD5 + "_CODCRM AND SRA.RA_CODIGO <> ''"
cQry += " WHERE " + cGD5 + "_FILIAL = '" + xFilial(cGD5) + "' AND " + cGD5 + ".D_E_L_E_T_ <> '*' "
cQry += "       AND " + cGD5 + "_NRSEQG = '" + cGuia + "' "
cQry += "       AND " + cGD5 + "_GLODES = '0' "

cQry += " UNION ALL "
cQry += " SELECT 'G6' AS IDTAB,' ' TRB_SEQ , " + cGD6 + "_REGATE TRB_REGATE, " + cGD6 + "_NRSEQG TRB_NRSEQG, GCS_CODUNC TRB_CODUNC, GCT_DESUNC TRB_DESUNC, "
cQry += " GAA_CODGDE TRB_CODGDE, ' ' TRB_UNICON, GAW_DESC TRB_DESGRP, ' ' TRB_FABRIC, ' ' TRB_UM, " + cGD6 + "_QTDDES TRB_QTDDES, "
cQry += " " + cGD6 + "_VALDES TRB_VALDES, " + HS_FVALDES(cGD6) + " TRB_VALTOT, 0 TRB_COEDES, 0 TRB_QTDCHP, 0 TRB_VFILME, 0 TRB_VLRCOS, ' ' TRB_NOMMED, ' ' TRB_CODATO, ' ' TRB_DESATO, "
cQry += " " + cGD6 + "_CODTXC TRB_CODIGO, " + cGD6 + "_DESTXC TRB_DESC, ' ' TRB_CDESP, ' ' TRB_CRM, ' ' TRB_DOCCIR, ' ' TRB_DATFIM, ' ' TRB_HORFIM, ' ' TRB_TIPATM, "
cQry += " ' ' TRB_HORDES, ' ' TRB_DATDES, ' ' TRB_TPANES, ' ' TRB_PGTMED, 0 TRB_COEFAM, " + cGD6 + "_DESVAL TRB_DESVAL,  " + cGD6 + "_DESOBS TRB_DESOBS,' ' TRB_TIPPRO,  "
cQry += " ' ' TRB_URGDES"
cQry += " FROM " + RetSqlName(cGD6) + " " + cGD6
cQry += " JOIN " + RetSqlName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = " + cGD6 + "." + cGD6 + "_CODLOC "
cQry += " JOIN " + RetSqlName("GCT") + " GCT ON GCT.GCT_FILIAL = '" + xFilial("GCT") + "' AND GCT.D_E_L_E_T_ <> '*' AND GCT.GCT_CODUNC = GCS.GCS_CODUNC "
cQry += " JOIN " + RetSqlName("GAA") + " GAA ON GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' AND GAA.GAA_CODTXD = " + cGD6 + "." + cGD6 + "_CODDES "
cQry += " JOIN " + RetSqlName("GAW") + " GAW ON GAW.GAW_FILIAL = '" + xFilial("GAW") + "' AND GAW.D_E_L_E_T_ <> '*' AND GAW.GAW_CODGDE = GAA.GAA_CODGDE "
cQry += " WHERE " + cGD6 + "_FILIAL = '" + xFilial(cGD6) + "' AND " + cGD6 + ".D_E_L_E_T_ <> '*' "
cQry += "       AND " + cGD6 + "_NRSEQG = '" + cGuia + "' "
cQry += "       AND " + cGD6 + "_GLODES = '0' "

cQry += " UNION ALL "
cQry += " SELECT 'G7' AS IDTAB,' ' TRB_SEQ , " + cGD7 + "_REGATE TRB_REGATE, " + cGD7 + "_NRSEQG TRB_NRSEQG, GCS_CODUNC TRB_CODUNC, GCT_DESUNC TRB_DESUNC, "
cQry += " GA7_CODGDE TRB_CODGDE, ' ' TRB_UNICON, GAW_DESC TRB_DESGRP, ' ' TRB_FABRIC, ' ' TRB_UM, " + cGD7 + "_QTDDES TRB_QTDDES, " + cGD7 + "_VALDES TRB_VALDES, "
cQry += " " + HS_FVALDES(cGD7) + " TRB_VALTOT, " + cGD7 + "_COEDES TRB_COEDES, " + cGD7 + "_QTDCHP TRB_QTDCHP,  " + cGD7 + "_VFILME TRB_VFILME, "
cQry += " " + cGD7 + "_VLRCOS TRB_VLRCOS, RA_NOME TRB_NOMMED, " + cGD7 + "_CODATO TRB_CODATO, GMC_DESATO TRB_DESATO, "
cQry += " " + cGD7 + "_CODPRT TRB_CODIGO, " + cGD7 + "_DESPRT TRB_DESC, ' ' TRB_CDESP, " + cGD7 + "_CODCRM TRB_CRM, " + cGD7 + "_DOCCIR TRB_DOCCIR, " + cGD7 + "_DATFIM TRB_DATFIM, "
cQry += " " + cGD7 + "_HORFIM TRB_HORFIM, GMC.GMC_TIPATM TRB_TIPATM, " + cGD7 + "_HORDES TRB_HORDES, " + cGD7 + "_DATDES TRB_DATDES, "
cQry += " " + cGD7 + "_TPANES TRB_TPANES, " + cGD7 + "_PGTMED TRB_PGTMED, " + cGD7 + "_COEFAM TRB_COEFAM, " + cGD7 + "_DESVAL TRB_DESVAL,  " + cGD7 + "_DESOBS TRB_DESOBS,GA7_TIPPRO TRB_TIPPRO,  " 
cQry += " " + cGD7 + "_URGDES TRB_URGDES"
cQry += " FROM " + RetSqlName(cGD7) + " " + cGD7
cQry += " JOIN " + RetSqlName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = " + cGD7 + "." + cGD7 + "_CODLOC "
cQry += " JOIN " + RetSqlName("GCT") + " GCT ON GCT.GCT_FILIAL = '" + xFilial("GCT") + "' AND GCT.D_E_L_E_T_ <> '*' AND GCT.GCT_CODUNC = GCS.GCS_CODUNC "
cQry += " JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = " + cGD7 + "." + cGD7 + "_CODDES "
cQry += " JOIN " + RetSqlName("GAW") + " GAW ON GAW.GAW_FILIAL = '" + xFilial("GAW") + "' AND GAW.D_E_L_E_T_ <> '*' AND GAW.GAW_CODGDE = GA7.GA7_CODGDE "
cQry += " JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO  = " + cGD7 + "." + cGD7 + "_CODCRM "
cQry += " LEFT JOIN " + RetSqlName("GMC") + " GMC ON GMC.GMC_FILIAL = '"+xFilial("GMC")+"' AND GMC.D_E_L_E_T_ <> '*' AND GMC.GMC_CODATO = " + cGD7 + "." + cGD7 + "_CODATO "
cQry += " WHERE " + cGD7 + "_FILIAL = '" + xFilial(cGD7) + "' AND " + cGD7 + ".D_E_L_E_T_ <> '*' "
cQry += "       AND " + cGD7 + "_NRSEQG  = '" + cGuia + "' "
cQry += "       AND " + cGD7 + "_GLODES  = '0' "

If nOrdemDesp == 1
 cQry += " ORDER BY TRB_REGATE, TRB_NRSEQG, TRB_CODUNC, TRB_CODGDE, TRB_CODIGO, TRB_CODATO"
Else
 cQry += " ORDER BY TRB_REGATE, TRB_NRSEQG, TRB_CODUNC, TRB_CODGDE, TRB_DESC, TRB_CODATO"
Endif
TCQUERY cQry NEW ALIAS "TRB"

DbSelectArea("TRB")
//If !lImpGraf
// SetRegua(150)
//EndIf

While !Eof()
 
 If lAbortPrint
  @nLin, 000 pSay STR0008 //"*** CANCELADO PELO OPERADOR ***"
  Exit
 EndIf
 
 If TRB->IDTAB == "G5"
  If (nPos := aScan(aVetDes, {|aVetDes| aVetDes[5] == TRB->TRB_CODIGO .And. aVetDes[9] == TRB->TRB_VALDES .And. ;
   aVetDes[3] == TRB->TRB_DESUNC .And. aVetDes[4] == TRB->TRB_DESGRP .And. TRB->TRB_CRM ==aVetDes[16]  })) == 0
   AADD(aVetDes,{;
   TRB->IDTAB, ;       //[1] Tabela
   TRB->TRB_REGATE, ;  //[2]  Registro de Atendimento
   TRB->TRB_DESUNC, ;  //[3]  Descricao de Unidade de Consumo
   TRB->TRB_DESGRP, ;  //[4]  Descri็ao do Grupo Despesas
   TRB->TRB_CODIGO, ;  //[5]  Codigo do Produto
   TRB->TRB_DESC  , ;  //[6]  Descricao do Produto
   TRB->TRB_UNICON, ;  //[7]  Unidade de Medida
   TRB->TRB_QTDDES, ;  //[8]  Quantidade
   TRB->TRB_VALDES, ;  //[9]  Valor Unitario
   TRB->TRB_VALTOT, ;  //[10] Valor Total
   TRB->TRB_CDESP , ;  //[11] Codigo Material Medicamento
   TRB->TRB_FABRIC, ;  //[12] Fabricante
   TRB->TRB_DESVAL, ;  //[13] Valor Unitario Desconto
   TRB->TRB_DESOBS, ;  //[14] Motivo Desconto   
   TRB->TRB_NOMMED, ;  //[15] Nome Medico
   TRB->TRB_CRM, ;     //[16] CRM  
   TRB->TRB_PGTMED})   //[17] Tipo Pagamento Medico  
  Else
   aVetDes[nPos,8]  += TRB->TRB_QTDDES
   aVetDes[nPos,10] += TRB->TRB_VALTOT
   If !Empty(TRB->TRB_DESVAL)
    aVetDes[nPos,13] += TRB->TRB_DESVAL
   EndIF
  EndIf //Esta com End
  
 ElseIf  TRB->IDTAB == "G6"
  If (nPos := aScan(aVetDes, {|aVetDes| aVetDes[5] == TRB->TRB_CODIGO .And. aVetDes[9] == TRB->TRB_VALDES .And. ;
   aVetDes[3] == TRB->TRB_DESUNC .And. aVetDes[4] == TRB->TRB_DESGRP})) == 0
   AADD(aVetDes,{;
   TRB->IDTAB, ;       //[1]  Tabela
   TRB->TRB_REGATE, ;  //[2]  Registro de Atendimento
   TRB->TRB_DESUNC, ;  //[3]  Descricao de Unidade de Consumo
   TRB->TRB_DESGRP, ;  //[4]  Descri็ao do Grupo Despesas
   TRB->TRB_CODIGO, ;  //[5]  Codigo do Produto
   TRB->TRB_DESC  , ;  //[6]  Descricao do Produto
   TRB->TRB_UM    , ;  //[7]  Unidade de Medida
   TRB->TRB_QTDDES, ;  //[8]  Quantidade
   TRB->TRB_VALDES, ;  //[9]  Valor Unitario
   TRB->TRB_VALTOT, ;  //[10] Valor Total
   TRB->TRB_DESVAL, ;  //[11] Valor Unitario Desconto
   TRB->TRB_DESOBS})   //[12] Motivo Desconto
  Else
   aVetDes[nPos,8]  += TRB->TRB_QTDDES
   aVetDes[nPos,10] += TRB->TRB_VALTOT  
   If !Empty(TRB->TRB_DESVAL)
    aVetDes[nPos,11] += TRB->TRB_DESVAL
   EndIF
  EndIf
 Else //G7
 	lAgl := .F.
  If TRB->TRB_PGTMED <> "0" .Or. cRepDir $ "1/2"
		If TRB->TRB_TIPPRO == "3" .Or. TRB->TRB_TIPPRO == "6" .Or. TRB->TRB_TIPPRO == "8"
			For nContAg := 1 To Len(aVetDes) // Aglutinacao de Despesas de SADT
				If aVetDes[nContAg][5] == TRB->TRB_CODIGO .AND. aVetDes[nContAg][13] == TRB->TRB_COEDES .AND. aVetDes[nContAg][17]==TRB->TRB_CRM .AND. aVetDes[nContAg][15]==TRB->TRB_VFILME .AND. aVetDes[nContAg][9] == TRB->TRB_VALDES .AND. 	aVetDes[nContAg][20] == TRB->TRB_DESVAL
					aVetDes[nContAg][8]	  :=	aVetDes[nContAg][8]+TRB->TRB_QTDDES			// Soma Quantidade 
					//aVetDes[nContAg][13]	:=		aVetDes[nContAg][13]+TRB->TRB_COEDES			// Soma Coeficiente de Depesa
					//aVetDes[nContAg][15] :=		aVetDes[nContAg][15]+TRB->TRB_VFILME		// Soma Filme (retirado pois o valor fdo filme ja e multiplicado pela quantidade
					//aVetDes[nContAg][14]	:=		aVetDes[nContAg][14]+TRB->TRB_QTDCHP			// Soma Quantidade CH 
					aVetDes[nContAg][16] :=		aVetDes[nContAg][16]+TRB->TRB_VLRCOS		// Soma Valor Custo Operacional  
					//aVetDes[nContAg][20]	:=		aVetDes[nContAg][20]+TRB->TRB_DESVAL			// Soma Desconto Valor Unitario 
					//aVetDes[nContAg][9]	:=		aVetDes[nContAg][9]+IIF(TRB->TRB_PGTMED == "0" .And. cRepDir == "1", 0, TRB->TRB_VALDES)			// Soma Valor Unitario
					aVetDes[nContAg][10] :=		aVetDes[nContAg][10]+IIF(TRB->TRB_PGTMED == "0" .And. cRepDir == "1", 0, TRB->TRB_VALTOT)			// Soma Valor Total
					lAgl := .T.
					Exit
				End if						
			Next nContAg
		End If 
   If !lAgl
    AADD(aVetDes, {;
    TRB->IDTAB, ;       //[1] Tabela
    TRB->TRB_REGATE, ;  //[2]  Registro de Atendimento
    TRB->TRB_DESUNC, ;  //[3]  Descricao de Unidade de Consumo
    TRB->TRB_DESGRP, ;  //[4]  Descri็ao do Grupo Despesas
    TRB->TRB_CODIGO, ;  //[5]  Codigo do Produto
    TRB->TRB_DESC  , ;  //[6]  Descricao do Produto
    TRB->TRB_UM    , ;  //[7]  Unidade de Medida
    TRB->TRB_QTDDES, ;  //[8]  Quantidade
    IIF(TRB->TRB_PGTMED == "0" .And. cRepDir == "1", 0, TRB->TRB_VALDES), ;   //[9]  Valor Unitario
    IIF(TRB->TRB_PGTMED == "0" .And. cRepDir == "1", 0, TRB->TRB_VALTOT), ;  //[10] Valor Total
    TRB->TRB_NOMMED, ;  //[11] Nome Medico
    TRB->TRB_DESATO, ;  //[12] Descricao Ato
    TRB->TRB_COEDES, ;  //[13] Coeficiente Despesa
    TRB->TRB_QTDCHP, ;  //[14] Qtd CHs
    TRB->TRB_VFILME, ;  //[15] Valor Filme
    TRB->TRB_VLRCOS, ;  //[16] Valor Custo Operacional
    TRB->TRB_CRM   , ;  //[17] CRM
    TRB->TRB_COEFAM, ;  //[18] Coeficente do Ato Medico
    TRB->TRB_PGTMED, ;  //[19] Tipo recebimento medico
    TRB->TRB_DESVAL, ;  //[20] Valor Unitario Desconto
    TRB->TRB_DESOBS, ;  //[21] Motivo Desconto
    TRB->TRB_URGDES,;	//[22] Urgencia
    TRB->TRB_COEDES})   //[23] Coeficiente Despesa (mantido para base de calculo) 
   Endif
  Endif
  
  If TRB->TRB_TIPATM == "0"
   AADD(aVetCir, {TRB->TRB_DOCCIR, HS_DTOC(STOD(TRB->TRB_DATDES),1), TRB->TRB_HORDES, HS_DTOC(STOD(TRB->TRB_DATFIM),1),;
   TRB->TRB_HORFIM,  TRB->TRB_CODIGO, TRB->TRB_DESC, TRB->TRB_COEDES, HS_INIPADR("SX5",1,"CA" + TRB->TRB_TPANES,"X5_DESCRI",,.F.)})
  Endif
  
 EndIf                     
 
 If TRB->TRB_REGATE <> cReg
	 FS_MAXCTA(TRB->TRB_REGATE)
 	cReg := TRB->TRB_REGATE
 EndIf
 
 DbSelectArea("TRB")
 DbSkip()
 
EndDo

DbCloseArea()

Return(NIL)


Static Function FS_RunGraf(aGuias)
Local cDESCUNC   := ""
Local cDESCGRU   := ""
Local cRepDir    := ""
Local nTotGer    := 0
Local nGrpDesp   := 0
Local nUniCons   := 0
Local nForGui    := 0
Local aRet       := {}
Local nCont      := 0
Local nTotDsc    := 0

Local nHeiPag    := 3100
Local nLenPag    := 2300
Local nColStart  := 0050
Local nColEnd    := nLenPag - 0050
Local nLin       := nHeiPag + 1

Local nEntreLin  := 30

Local nPosCodMat := 0000
Local nPosDscPrd := 0257
Local nPosCoeDes := 0771
Local nPosFilme  := 0883 
Local nPosQtdCH  := 1092
Local nPosQtdCO  := 1269 
Local nPosUn     := 1494 
Local nPosQuant  := 1574 
Local nPosVlUnit := 1751 
Local nPosVtTot  := 1959 

Local nPosCRM    := 0048
Local nPosMedico := 0161
Local nPosCoeAto := 0771
Local nPosAto    := 0980
Local nPosCodSis := 0835
Local nPosMotDes := 0980
Local nPosUrgDes := 1606
Local nPosValDes := 1751

Local nPosTotTit := 0369
Local nPosTotVal := 1959

Local nLenGuias  := Len(aGuias)
Local nLenVetDes := 0
Local lStPag     := .T.

Private aVetDes    := {}
Private aVetCir    := {}

Private oFontBody  := TFont():New("Courier New", 09, 08,, .F.,,,,,.F.) //cTitulos dos Campos
Private oPrn       := Nil

Private nMargX     := 0050

DbSelectArea("GCY")
DbSetOrder(1)

ProcRegua(Len(aGuias))

oPrn := TMSPrinter():New()
oPrn:Setup()

If FunName() <> "HSPAHP12"
 aSort(aGuias,,, {|x,y| x[2]+x[1] < y[2]+y[1]}) //REGATE + NRSEQG
Else
 If !Empty(aGuias[1,3]) .And. nOrdemGuia == 1
  aSort(aGuias,,, {|x,y| x[3] < y[3]})
 Endif
Endif

SetRegua(nLenGuias)

For nForGui := 1 To nLenGuias

 nLin := nHeiPag + 1
 
 FS_RETGUIA(aGuias[nForGui, 1]) // Recupera a guia atual
 
 nLenVetDes := Len(aVetDes)
 For nCont := 1 To nLenVetDes
  
  If nLin > nHeiPag .Or. aVetDes[nCont, 2] != aVetDes[Iif(nCont = Len(aVetDes), nCont, nCont + 1), 2]
   If nLin > nHeiPag 
    If !lStPag
     oPrn:EndPage()
    EndIf
    oPrn:StartPage()
    lStPag := .F.
   EndIf
   nLin := FS_Cabec(aVetDes[nCont, 2], oPrn, nLenPag, NomeProg, cTitulo)
   If nCont == 1
    nLin := FS_GRFAGUI(GCZ->GCZ_NRSEQG, nLin, nLenPag)
    If !Empty(aVetCir)
     nLin := FS_GRFCIR(nLin, nLenPag)
    Endif
   EndIf
   
   nLin += nEntreLin
   
//            1         2         3         4         5         6         7         8         9         10        11        12        13
//   0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.12 
//  "Cod. Despesa     Nome Despesa               Coef.Desp        Filme     Qtd.CH        Qtd.CO  Un.    Quanti.     Vl.Unit.    Vl.Total"
//  "   CRM    M้dico                             Coef.Ato        Ato                                    Urgencia    Desconto"


   oPrn:Say(nLin, nMargX+0000, STR0036, oFontBody, 100) //"Cod. Despesa"
   oPrn:Say(nLin, nMargX+0273, STR0037, oFontBody, 100) //"Nome Despesa"
   oPrn:Say(nLin, nMargX+0707, STR0038, oFontBody, 100) //"Coef.Desp"
   oPrn:Say(nLin, nMargX+0980, STR0039, oFontBody, 100) //"Filme"
   oPrn:Say(nLin, nMargX+1140, STR0066, oFontBody, 100) //"Qtd.CH"
   oPrn:Say(nLin, nMargX+1365, STR0040, oFontBody, 100) //"Qtd.CO"
   oPrn:Say(nLin, nMargX+1494, STR0041, oFontBody, 100) //"Un."
   oPrn:Say(nLin, nMargX+1606, STR0042, oFontBody, 100) //"Quanti."
   oPrn:Say(nLin, nMargX+1799, STR0043, oFontBody, 100) //"Vl.Unit."
   oPrn:Say(nLin, nMargX+1992, STR0044, oFontBody, 100) //"Vl.Total"
   
   nLin += nEntreLin

   oPrn:Say(nLin, nMargX+0048, STR0045, oFontBody, 100) //"CRM"
   oPrn:Say(nLin, nMargX+0161, STR0046, oFontBody, 100) //"M้dico"
   oPrn:Say(nLin, nMargX+0723, STR0047, oFontBody, 100) //"Coef.Ato"
   oPrn:Say(nLin, nMargX+0980, STR0048, oFontBody, 100) //"Ato"
   oPrn:Say(nLin, nMargX+1606, STR0069, oFontBody, 100) //"Urgencia"
   oPrn:Say(nLin, nMargX+1799, STR0049, oFontBody, 100) //"Desconto"
   
   nLin += 2 * nEntreLin

  EndIf
  
  //Quebra do grupo de Unidade de Consumo
  If Iif(nCont > 1, aVetDes[nCont, 3] != aVetDes[nCont-1, 3], .T.)
   oPrn:Line(nLin, nColStart, nLin,  nColEnd)
   nLin += nEntreLin
   oPrn:Say(nLin, nMargX+0000, aVetDes[nCont, 3],   oFontBody, 100)
   nLin += 2 * nEntreLin
  EndIf
  
  // Quebra do grupo de Despesas
  If Iif(nCont > 1, aVetDes[nCont, 4] != aVetDes[nCont-1, 4] .Or. aVetDes[nCont, 3] != aVetDes[nCont-1, 3], .T.)
   oPrn:Say(nLin, nMargX+0000, aVetDes[nCont, 4],   oFontBody, 100)
   nLin += nEntreLin
  EndIf
  
  oPrn:Say(nLin, nMargX+nPosCodMat, PadL(AllTrim(aVetDes[nCont, 5]), 15), oFontBody, 100) //Codigo do Material
  oPrn:Say(nLin, nMargX+nPosDscPrd, "-" + SubStr(aVetDes[nCont, 6], 1, 29), oFontBody, 100) //Descri็ao do Produto

  If aVetDes[nCont, 1] == "G7"
//   @ nLin, 048 pSay  
   oPrn:Say(nLin, nMargX+nPosCoeDes, PADR(Transform(aVetDes[nCont, 13], "@E 99.99"),5), oFontBody, 100) //Coef.Desp
   If aVetDes[nCont, 15] <> 0
    oPrn:Say(nLin, nMargX+nPosFilme, PADL(Transform(aVetDes[nCont, 8] * aVetDes[nCont, 15], "@E 99,999.9999"), 11), oFontBody, 100) // Valor Filme
   EndIf
   oPrn:Say(nLin, nMargX+nPosQtdCH, PADL(Transform(aVetDes[nCont, 14], "@E 99,999.99"), 9), oFontBody, 100) //Qtd. CH
   oPrn:Say(nLin, nMargX+nPosQtdCO, PADL(Transform(aVetDes[nCont, 16], "@E 9,999,999.999"), 13), oFontBody, 100) //Qtd. CO
  EndIf

  oPrn:Say(nLin, nMargX+nPosUn, aVetDes[nCont, 7], oFontBody, 100) //Unidade de Medida
  oPrn:Say(nLin, nMargX+nPosQuant, PADL(Transform(aVetDes[nCont, 8], "@E 999,999.99"), 10), oFontBody, 100) //Quantidade
  oPrn:Say(nLin, nMargX+nPosVlUnit, PADL(Transform(aVetDes[nCont, 9], "@E 999,999,999.9999"), 11), oFontBody, 100) //Vlr. Unit.
  oPrn:Say(nLin, nMargX+nPosVtTot, PADL(Transform(aVetDes[nCont, 10], "@E 999,999,999.99"), 14), oFontBody, 100) //Vlr. Total

  If aVetDes[nCont, 1] == "G7"
   nLin += nEntreLin
   oPrn:Say(nLin, nMargX+nPosCRM, aVetDes[nCont, 17], oFontBody, 100) //CRM
   oPrn:Say(nLin, nMargX+nPosMedico, SubStr(aVetDes[nCont, 11], 1, 36), oFontBody, 100) //Medico
   oPrn:Say(nLin, nMargX+nPosCoeAto, PADR(Transform(aVetDes[nCont, 18], "@E 99.99"),5), oFontBody, 100) //Coef.Ato
   oPrn:Say(nLin, nMargX+nPosAto, SubStr(aVetDes[nCont, 12], 1, 25), oFontBody, 100) //Ato
   oPrn:Say(nLin, nMargX+nPosUrgDes, HS_RDescrB("GD7_URGDES", aVetDes[nCont, 22]), oFontBody, 100) //Urgencia
  EndIf

  
  If aVetDes[nCont, 1] == "G5"
   oPrn:Say(nLin, nMargX+nPosCodSis, PADR(ALLTRIM(aVetDes[nCont, 11]), Iif(lTamProd,15,30)), oFontBody, 100) //Codigo do Sistema
//   oPrn:Say(nLin, nMargX+nPosMotDes, ALLTRIM(aVetDes[nCont, 12]), oFontBody, 100) // Motivo Desconto
   
   	If aVetDes[nCont, 17] $ "1/2/3"  
   		nLin += nEntreLin
   		oPrn:Say(nLin, nMargX+nPosCRM, aVetDes[nCont, 16], oFontBody, 100) //CRM
       	oPrn:Say(nLin, nMargX+nPosMedico, SubStr(aVetDes[nCont, 15], 1, 36), oFontBody, 100) //Medico
    EndIf   
  EndIf
  
  nPosDesc := IIF(aVetDes[nCont, 1] == "G5", 13, IIF(aVetDes[nCont, 1] == "G6", 11, 20))
  
  If !Empty(aVetDes[nCont,nPosDesc])
   nTotDsc += aVetDes[nCont,nPosDesc]
   If aVetDes[nCont, 1] <> "G7"
    nLin += nEntreLin
    If nApresDesc == 1 .And. !Empty(aVetDes[nCont, nPosDesc+1])
     oPrn:Say(nLin, nMargX+nPosMotDes, STR0035 + SubStr(aVetDes[nCont, nPosDesc+1],1,92), oFontBody, 100) // "Mot. Desc.: " 
    Endif
    oPrn:Say(nLin, nMargX+nPosValDes, Transform(aVetDes[nCont,nPosDesc], "@E 999,999.9999"), oFontBody, 100) // Valor Desconto
   Else
    oPrn:Say(nLin, nMargX+nPosValDes, Transform(aVetDes[nCont,nPosDesc], "@E 99,999.9999"), oFontBody, 100) // Valor Desconto
    If nApresDesc == 1 .And. !Empty(aVetDes[nCont, nPosDesc+1])
     nLin += nEntreLin
     oPrn:Say(nLin, nMargX+nPosMotDes, STR0035 + SubStr(aVetDes[nCont, nPosDesc+1],1,92), oFontBody, 100) // "Mot. Desc.: " 
    Endif
   Endif
  Endif
  
  nGrpDesp += Iif(aVetDes[nCont, 1] # "G7" .Or. aVetDes[nCont, 19] # "0", aVetDes[nCont, 10], 0)//Se for repasse direto nใo somatiza no total
  nTotGer  += Iif(aVetDes[nCont, 1] # "G7" .Or. aVetDes[nCont, 19] # "0", aVetDes[nCont, 10], 0)//Se for repasse direto nใo somatiza no total
  
  nLin += nEntreLin
  
  // Imprime o total do grupo de despesas
  If     aVetDes[nCont, 4] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 4];
   .Or. aVetDes[nCont, 3] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 3];
   .Or. aVetDes[nCont, 2] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 2];
   .Or. nCont == Len(aVetDes)
   
   oPrn:Say(nLin, nMargX+nPosTotTit, STR0017, oFontBody, 100) // "Total do Grupo "
   oPrn:Say(nLin, nMargX+nPosTotVal, Transform(nGrpDesp, "@E 999,999,999.99"), oFontBody, 100) // "Total do Grupo "
   nUniCons += Iif(aVetDes[nCont, 1] # "G7" .Or. aVetDes[nCont, 19] # "0", nGrpDesp, 0)//Se for repasse direto nใo somatiza no total
   nGrpDesp := 0
   nLin += 2*nEntreLin
   
  EndIf
  
  //Imprime o total da unidade de consumo
  If     aVetDes[nCont, 3] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 3] ;
   .Or. aVetDes[nCont, 2] != aVetDes[IIF((nCont) == Len(aVetDes), nCont, nCont + 1), 2] ;
   .Or. nCont == Len(aVetDes)
   
   If aVetDes[nCont, 3] != aVetDes[IIF(nCont = Len(aVetDes), nCont, nCont + 1), 3] .Or. nCont == Len(aVetDes)
    
    oPrn:Say(nLin, nMargX+nPosTotTit, STR0018, oFontBody, 100) // "Total da Unidade de Consumo"
    oPrn:Say(nLin, nMargX+nPosTotVal, Transform(nUniCons, "@E 999,999,999.99"), oFontBody, 100) // "Total do Grupo "
    nLin += 2 * nEntreLin
    nUniCons := 0
    
   EndIf
   
   If nCont == Len(aVetDes)
    
    oPrn:Say(nLin, nMargX+nPosTotTit, STR0068, oFontBody, 100) //"Total Desconto"
    oPrn:Say(nLin, nMargX+nPosTotVal, Transform(nTotDsc, "@E 999,999,999.99"), oFontBody, 100) // "Total Desconto"
    nTotDsc := 0
    
    nLin += nEntreLin
   
    oPrn:Say(nLin, nMargX+nPosTotTit, STR0019, oFontBody, 100) // "Total Geral"
    oPrn:Say(nLin, nMargX+nPosTotVal, Transform(nTotGer, "@E 999,999,999.99"), oFontBody, 100) // "Total do Grupo "
    nTotGer := 0
    
   EndIf
   
   If aVetDes[nCont, 2] != aVetDes[IIF((nCont) == Len(aVetDes), nCont, nCont + 1), 2] .Or. nCont == Len(aVetDes)
    
    nUniCons := 0
    nLin     := nMaxLin * 2 // Forca um salto de pagina
    
   EndIf
   
  EndIf
  
 Next
 
 aVetDes := {}
 aVetCir := {}
 IncRegua()
Next nForGui

oPrn:EndPage()
oPrn:Preview()
oPrn:End()

Return Nil


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

Function HS_CabGraf(oPrn, nLenPag, cNomeFunc, nColTit, cTitulo)
Local cEmpLogo   := ""

Local nLin1      := 0050
Local nLin2      := 0100
Local nLin3      := 0150
Local nLinTit    := 0080

Local nColStart  := 0050
Local nColEnd    := nLenPag - 0050

Local oCabFont1  := TFont():New("Courier New", 13, 11,, .T.,,,,,.F.) //cTitulos dos Relat๓rio
Local oCabFont2  := TFont():New("Courier New", 11, 09,, .F.,,,,,.F.) //Adendos Cabe็alho

Default nColTit    := 0800

oPrn:Line(0000, nColStart, 0000,  nColEnd)

cEmpLogo := "system\lgrl" + Lower(Iif( FindFunction("FWGRPCompany"),FWGRPCompany(), SM0->M0_CODIGO )   ) + ".bmp"
If File(cEmpLogo)
 oPrn:SayBitmap(nLin1-40, nColStart, cEmpLogo, 0300, 0080)
Else
 oPrn:Say(nLin1, nColStart,Iif( FindFunction("FWGRPCompany"),AllTrim(FWFilialName(FWGrpCompany(),FWCodFil(),2)), SM0->M0_CODIGO )+ Iif( FindFunction("FWFilialName"), STR0070 + FWFilialName(),SM0->M0_NOME), oCabFont2, 100)
EndIf

oPrn:Say(nLin2, nColStart, "SIGA/" + AllTrim(cNomeFunc) + "/v." + cVersao, oCabFont2, 100)
oPrn:Say(nLin3, nColStart, Time(), oCabFont2, 100)

oPrn:Say(nLinTit, nColTit, cTitulo, oCabFont1, 100)

oPrn:Say(nLin1, nColEnd-380, Padl(STR0050 + AllTrim(Str(m_pag++)), 20), oCabFont2, 100) //"Pแgina: "
oPrn:Say(nLin2, nColEnd-380, Padl(STR0051 + DToC(dDataBase), 20), oCabFont2, 100) //"Dt. Ref.: "
oPrn:Say(nLin3, nColEnd-380, Padl(STR0052 + DToC(Date()), 20), oCabFont2, 100) //"Emissใo: "
oPrn:Line(0200, nColStart, 00200,  nColEnd)

Return 0250

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Cabec  บAutor  ณMicrosiga           บ Data ณ  09/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprssใo do cabe็alho do relat๓rio HSPAHRC6                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_Cabec(cAtendim, oPrn, nLenPag, cNomeProg, cTitulo)
Local cMsgLin    := ""
Local nLin       := 0
Local nColStart  := 0050
Local nColEnd    := nLenPag - 0050

Local oFont      := TFont():New("Courier New", 11, 09,, .T.,,,,,.F.) //Titulos dos Campos
Local nEntreLin  := 30

nLin := HS_CabGraf(oPrn, nLenPag, cNomeProg, 0800, cTitulo)

cMsgLin := STR0009 + cAtendim + "                 " + ; //"Atendimento: "
           STR0010 + SubStr(HS_INIPADR("GCY", 1, cAtendim, "GCY_NOME"), 1, 36) + " " + ; //"Paciente.: "  
           STR0024 + HS_INIPADR("GD4", 1, GCY->GCY_REGGER + GCZ->GCZ_CODPLA,"GD4_MATRIC",,.F.) + " " //"Matrํcula: "
                           

oPrn:Say(nLin, nColStart, cMsgLin, oFont, 100)

nLin += nEntreLin

cMsgLin := "                                    " + STR0011 + PADR(DTOC(GCY->GCY_DATATE),10) + " " + GCY->GCY_HORATE + "                     " + ; //"Entrada..: "
           STR0025 + PADR(DTOC(GCY->GCY_DATALT),10) + " " +  (GCY->GCY_HORALT)//"Dt.Alt.: "
          
           
oPrn:Say(nLin, nColStart, cMsgLin, oFont, 100)

nLin += nEntreLin

cMsgLin := STR0027 + GCZ->GCZ_NRGUIA + "   "+ ; // Guia numero:
           STR0012 + SubStr(HS_INIPADR("GA9", 1, GCZ->GCZ_CODCON, "GA9_NREDUZ"), 1, 20) + "                 " + ; //"Convenio.: "
           STR0013 + SubStr(HS_INIPADR("GCM", 2, GCZ->GCZ_CODPLA, "GCM_DESPLA"), 1, 20) + " " //"Plano....: "

oPrn:Say(nLin, nColStart, cMsgLin, oFont, 100)

nLin += nEntreLin

cMsgLin := "     " + STR0026 + GCZ->GCZ_NRSEQG + "                 " + ; //Seq...:
           STR0033 + GD4->GD4_SQCATP + " - " + SubStr(HS_INIPADR("GFV", 1, GD4->GD4_CODPLA + GD4->GD4_SQCATP, "GFV_NOMCAT"), 1, 10) + ; //"Categoria: "
           "                     " + STR0014 + GCZ->GCZ_NRFATU  //"Fat......: "
    
oPrn:Say(nLin, nColStart, cMsgLin, oFont, 100)

nLin += nEntreLin
   
cMsgLin := "                                    " + STR0021 + PADR(DTOC(GCZ->GCZ_DCPARI),10) + "                           " + ; //"Dt.F.Ini.: "  
           STR0022 + Dtoc(IIF(((EMPTY(GCY->GCY_DATALT).or.GCY->GCY_DATALT>GCZ->GCZ_DCPARF).AND.GCZ->GCZ_CTAPAR<>nMaxConta ), GCZ->GCZ_DCPARF, GCY->GCY_DATALT    )) 
 
oPrn:Say(nLin, nColStart, cMsgLin, oFont, 100)

nLin += nEntreLin
   
cMsgLin :=  STR0067 + GCZ->GCZ_NUMORC + "   " + STR0023 + ALLTRIM(STR(GCZ->GCZ_CTAPAR, 2)) + "        " + ; //"Numer. Orc.: "##"Nr.Fech..: "
            STR0028 + GCY->GCY_CIDALT + "                             " + ; //"CID: "
            STR0029 + GCZ->GCZ_NRSEN1 //"Senha: "
           
           



oPrn:Say(nLin, nColStart, cMsgLin, oFont, 100)

nLin += 2 * nEntreLin

oPrn:Line(nLin, nColStart, nLin,  nColEnd)

nLin += nEntreLin

Return(nLin)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRFCIR บAutor  ณMicrosiga           บ Data ณ  09/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime as ciriugias realizadas                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FS_GRFCIR(nLin, nLenPag)

 Local aArea := GetArea()
 Local nPos  := 0
 Local nPosDocume := 0000
 Local nPosInicCi := 0202
 Local nPosFimCir := 0516
 Local nPosCodPro := 0800//0766
 Local nPosDesc   := 1147
 Local nPosVia    := 1640
 Local nPosAneste := 1799

 Local nColStart  := 0050
 Local nColEnd    := nLenPag - 0050

 Local nLen       := 0
 Local nMargX     := 0050

 Local oFontCir   := TFont():New("Courier New", 11, 09,, .F.,,,,,.F.) //cTitulos dos Relat๓rio
 Local oFontCirN  := TFont():New("Courier New", 11, 09,, .T.,,,,,.F.) //cTitulos dos Relat๓rio

 Local nEntreLin  := 30
//            1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
//  0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
// "Documento   Inicio Cirurgia  Fim Cirurgia   Cod. Procedimento  Descricao                       Via    Anestesia "

 nLin += nEntreLin

 oPrn:Say(nLin, nMargX+nPosDocume, STR0053, oFontCirN, 100) //"Documento"
 oPrn:Say(nLin, nMargX+nPosInicCi, STR0054, oFontCirN, 100) //"Inicio Cirurgia"
 oPrn:Say(nLin, nMargX+nPosFimCir, STR0055, oFontCirN, 100) //"Fim Cirurgia"
 oPrn:Say(nLin, nMargX+nPosCodPro, STR0056, oFontCirN, 100) //"Cod. Procedimento"
 oPrn:Say(nLin, nMargX+nPosDesc,   STR0057, oFontCirN, 100) //"Descricao"
 oPrn:Say(nLin, nMargX+nPosVia,    STR0058, oFontCirN, 100) //"Via"
 oPrn:Say(nLin, nMargX+nPosAneste, STR0059, oFontCirN, 100) //"Anestesia"

 nLin += nEntreLin

 nLen := Len(aVetCir)
 For nPos := 1 To nLen
 
  oPrn:Say(nLin, nMargX+nPosDocume, SubStr(aVetCir[nPos, 1],1,10),                    oFontCir, 100)
  oPrn:Say(nLin, nMargX+nPosInicCi, aVetCir[nPos, 2]+ " " + aVetCir[nPos, 3],         oFontCir, 100)
  oPrn:Say(nLin, nMargX+nPosFimCir, aVetCir[nPos, 4]+ " " + aVetCir[nPos, 5],         oFontCir, 100)
  oPrn:Say(nLin, nMargX+nPosCodPro, SubStr(aVetCir[nPos, 6],1,15),                    oFontCir, 100)
  oPrn:Say(nLin, nMargX+nPosDesc,   SubStr(aVetCir[nPos, 7],1,25),                    oFontCir, 100)
  oPrn:Say(nLin, nMargX+nPosVia,    ALLTRIM(Transform(aVetCir[nPos, 8], "@E 99.99")), oFontCir, 100)
  oPrn:Say(nLin, nMargX+nPosAneste, SubStr(aVetCir[nPos, 9],1,30),                    oFontCir, 100)
 
  nLin += nEntreLin
 
 Next nPos

 nLin += nEntreLin
 oPrn:Line(nLin, nColStart, nLin,  nColEnd)
 nLin += nEntreLin

 RestArea(aArea)

Return(nLin)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRFAGUIบAutor  ณMicrosiga           บ Data ณ  09/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime as guias de interna็ใo                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FS_GRFAGUI(cNrSeqg, nLin, nLenPag)
Local aArea := GetArea()
//           1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
// 0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 
//"N. Autorizacao         Senha Autorizacao      Data Autorizacao   Data Vencimento   N. Dias Autorizados    Tipo de Diแria"

Local nPosNAutor := 0000
Local nPosSenha  := 0369
Local nPosDtAuto := 0739
Local nPosDtVenc := 1084
Local nPosNrDAut := 1413
Local nPosTpDiar := 1832

Local nMargX     := 0050

Local oFontGui   := TFont():New("Courier New", 11, 09,, .F.,,,,, .F.) //cTitulos dos Relat๓rio
Local oFontGuiN  := TFont():New("Courier New", 11, 09,, .T.,,,,, .F.) //cTitulos dos Relat๓rio

Local nColStart  := 0050
Local nColEnd    := nLenPag - 0050

Local nEntreLin  := 30

DbSelectArea("GE8")
DbSetOrder(2) //GE8_FILIAL + GE8_NRSEQG
If Dbseek(xFilial("GE8") + cNrSeqg)
 
 nLin += nEntreLin
 
 oPrn:Say(nLin, nMargX+nPosNAutor, STR0060, oFontGuiN, 100) //"N. Autorizacao"
 oPrn:Say(nLin, nMargX+nPosSenha,  STR0061, oFontGuiN, 100) //"Senha Autorizacao"
 oPrn:Say(nLin, nMargX+nPosDtAuto, STR0062, oFontGuiN, 100) //"Data Autorizacao"
 oPrn:Say(nLin, nMargX+nPosDtVenc, STR0063, oFontGuiN, 100) //"Data Vencimento"
 oPrn:Say(nLin, nMargX+nPosNrDAut, STR0064, oFontGuiN, 100) //"N. Dias Autorizados"
 oPrn:Say(nLin, nMargX+nPosTpDiar, STR0065, oFontGuiN, 100) //"Tipo de Diแria"
 
 nLin += nEntreLin
 
 While !Eof() .And. GE8->GE8_FILIAL == xFilial("GE8") .And. GE8->GE8_NRSEQG = cNrSeqg
  
  oPrn:Say(nLin, nMargX+nPosNAutor, GE8->GE8_NROAUT, oFontGui, 100)
  oPrn:Say(nLin, nMargX+nPosSenha,  GE8->GE8_SENAUT, oFontGui, 100)
  oPrn:Say(nLin, nMargX+nPosDtAuto, HS_DTOC(GE8->GE8_DATLIB,1), oFontGui, 100)
  oPrn:Say(nLin, nMargX+nPosDtVenc, HS_DTOC(GE8->GE8_DATVEN,1), oFontGui, 100)
  oPrn:Say(nLin, nMargX+nPosNrDAut, PADL(ALLTRIM(Transform(GE8->GE8_QTDLIB, "@E 999")), 2, " "), oFontGui, 100)
  oPrn:Say(nLin, nMargX+nPosTpDiar, HS_RDescrB("GE8_TPDIAR", GE8->GE8_TPDIAR), oFontGui, 100)
  nLin += nEntreLin
  
  DbSkip()
  
 EndDo
 
 nLin += nEntreLin
 oPrn:Line(nLin, nColStart, nLin, nColEnd)
 nLin += nEntreLin
 
EndIf

RestArea(aArea)

Return(nLin)


