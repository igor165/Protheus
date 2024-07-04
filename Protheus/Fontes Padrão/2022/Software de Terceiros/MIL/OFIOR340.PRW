//#INCLUDE "ofior340.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOR340 ³ Autor ³  Emilton              ³ Data ³ 08/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ RMS - AUDI                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ (Veiculos)                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION OFIOR340
	MsgAlert("Conforme definicao da Montadora VW. A Rotina de RMS foi descontinuada e esta sendo substituida pela rotina de AUTOSERVICE, em desenvolvimento.","Atencao")
Return()
/*
Local cDesc1     := OemToAnsi(STR0003)
Local cDesc2     :=""
Local cDesc3     :=""
Local cAlias	  :="VO4" 
Private nLin     := 1
Private aPag     := 1
Private aReturn  := { STR0001, 1,STR0002, 2, 2, 1, "",1 }
Private cTamanho := "M"           // P/M/G
Private Limite   := 132           // 80/132/220
Private aOrdem   := {}            // Ordem do Relatorio
Private cTitulo  := OemToAnsi(STR0003)
Private cNomProg := "OFIOR340"
Private cNomRel  := "OFIOR340"
Private nLastKey := 0                       
Private cPerg    := "OFI340"
Private lAbortPrint := .f.

Private MVG_PAR01 := ""
Private MVG_PAR02 := ""
Private MVG_PAR03 := ""
Private MVG_PAR04 := ""
Private MVG_PAR05 := ""
Private MVG_PAR06 := ""
//Private MVG_PAR07 := ""

Private MVV_PAR01 := ""
Private MVV_PAR02 := ""
Private MVV_PAR03 := ""
Private MVV_PAR04 := ""
Private MVV_PAR05 := ""
Private MVV_PAR06 := ""
Private MVV_PAR07 := ""
Private MVV_PAR08 := ""
Private MVV_PAR09 := ""
Private MVV_PAR10 := ""
Private MVV_PAR11 := ""
Private MVV_PAR12 := ""
Private MVV_PAR13 := ""
Private MVV_PAR14 := ""
Private MVV_PAR15 := ""

Private MVC_PAR01 := ""
Private MVC_PAR02 := ""
Private MVC_PAR03 := ""
Private MVC_PAR04 := ""
Private MVC_PAR05 := ""
Private MVC_PAR06 := ""
Private MVC_PAR07 := ""
Private MVC_PAR08 := ""
Private MVC_PAR09 := ""
Private MVC_PAR10 := ""
Private MVC_PAR11 := ""
Private MVC_PAR12 := ""

while .t.

   If Pergunte("OFI340",.t.)

      MVG_PAR01 := MV_PAR01
      MVG_PAR02 := MV_PAR02
      MVG_PAR03 := MV_PAR03
      MVG_PAR04 := MV_PAR04
      MVG_PAR05 := MV_PAR05
      MVG_PAR06 := MV_PAR06
//      MVG_PAR07 := MV_PAR07
      Exit

   Else

      Return .t.

   EndIf
   
EndDo

Do Case

   Case MVG_PAR04 == 1 // Volkswagen Veiculo de Passeio
        cPerg   := "OFI34A"
        cNomRel := SetPrint(cAlias,cNomRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,,cTamanho)
        
        If nLastKey == 27
           Return
        Endif

        PERGUNTE("OFI34A",.f.)

        MVV_PAR01 := MV_PAR01
        MVV_PAR02 := MV_PAR02
        MVV_PAR03 := MV_PAR03
        MVV_PAR04 := MV_PAR04
        MVV_PAR05 := MV_PAR05
        MVV_PAR06 := MV_PAR06
        MVV_PAR07 := MV_PAR07
        MVV_PAR08 := MV_PAR08
        MVV_PAR09 := MV_PAR09
        MVV_PAR10 := MV_PAR10
        MVV_PAR11 := MV_PAR11
        MVV_PAR12 := MV_PAR12
        MVV_PAR13 := MV_PAR13
        MVV_PAR14 := MV_PAR14
        MVV_PAR15 := MV_PAR15
        
   Case MVG_PAR04 == 2 // Volkswagen Caminhoes/Onibus

        cPerg   := "OFI34B"
        cNomRel := SetPrint(cAlias,cNomRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,,cTamanho)

        If nLastKey == 27
           Return
        Endif

        PERGUNTE("OFI34B",.f.)

        MVC_PAR01 := MV_PAR01
        MVC_PAR02 := MV_PAR02
        MVC_PAR03 := MV_PAR03
        MVC_PAR04 := MV_PAR04
        MVC_PAR05 := MV_PAR05
        MVC_PAR06 := MV_PAR06
        MVC_PAR07 := MV_PAR07
        MVC_PAR08 := MV_PAR08
        MVC_PAR09 := MV_PAR09
        MVC_PAR10 := MV_PAR10
        MVC_PAR11 := MV_PAR11
        MVC_PAR12 := MV_PAR12

EndCase

SetDefault(aReturn,cAlias)

RptStatus( { |lEnd| ImpOR340(@lEnd,cNomRel,cAlias) } , cTitulo )

If aReturn[5] == 1
     
   OurSpool( cNomRel )

EndIf

Return
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ IMPOR340 ºAutor  ³Emilton             º Data ³  08/02/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime relatorio                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function IMPOR340()

Local nBarra  := 08
Local aQtdPas := {}
Local aTpoPro := {}
Local aTpoVen := {}
Local aRet    := {}
Local nVLMOSG := 0
Local nVLMORP := 0
Local nVLMOSC := 0
Local nVLMOPB := 0
Local nVLPCBL := 0
Local nVLPCOF := 0
Local nTPDSSG := 0
Local nTPDSSC := 0
Local nRecVAI := 0
Local MVT_PAR24 := ""
Local MVT_PAR25 := ""
Local nTPVNSG := 0
Local nTPVNSC := 0
Local aWrk    := {}

aAdd(aTpoPro,{0,0})
aAdd(aTpoPro,{0,0})
aAdd(aTpoPro,{0,0})

Private nLin := 1 , lAbortPrint := .f.

Set Printer to &cNomRel
Set Printer On
Set device to Printer

&& Levantamento para a barra de rolagem

SetRegua( nBarra )

&& Impressao        

nBarra   := 0
nLin     := 1
cbTxt    := Space(10)
cbCont   := 0
cString  := "VEC"
Li       := 80
m_Pag    := 1
wnRel    := "OFIOR340"
cabec1   := ""
cabec2   := ""
nomeprog := "OFIOR340"
tamanho  := "M"
nCaracter:= 15
nTotal   := 0           

Do Case

   Case MVG_PAR04 == 1 // Volkswagen Veiculo de Passeio

        nLin := cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
        nLin ++

        // Total de Passagens

        IncRegua(STR0005)

        If lAbortPrint
           Return .t.
        EndIf

        aRet := FG_CALTEM(,MVG_PAR01,"F",MVG_PAR02,,"R",,,If(MVG_PAR03 == 1,"A","F"))  // Passagens

        aAdd(aQtdPas,{aRet[01,01]+aRet[01,02]+aRet[02,01]+aRet[02,02]+aRet[03,01]+aRet[03,02],aRet[01,01]+aRet[02,01]+aRet[03,01],aRet[01,02]+aRet[02,02]+aRet[03,02] })
        aAdd(aQtdPas,{aRet[01,01]+aRet[01,02],aRet[01,01],aRet[01,02] })
        aAdd(aQtdPas,{aRet[02,01]+aRet[02,02],aRet[02,01],aRet[02,02] })
        aAdd(aQtdPas,{aRet[03,01]+aRet[03,02],aRet[03,01],aRet[03,02] })

        IncRegua(STR0005)
        aRet    := FG_CALTEM(,MVG_PAR01,"7",MVG_PAR02,,"R",,,)  // Venda de Mao-de-Obra

        nVLMORP := aRet[01]
        nVLMOSG := aRet[02]
        nVLMOSC := aRet[03]

        IncRegua(STR0005)
        nVLPCBL := FG_CALTEM(,MVG_PAR01,"D",MVG_PAR02,,"B",,,)

        IncRegua(STR0005)
        nVLPCOF := FG_CALTEM(,MVG_PAR01,"D",MVG_PAR02,,"O",,,)

        IncRegua(STR0005)
        nVLMOPB := FG_VALHOR(MVV_PAR15,MVG_PAR02)

        IncRegua(STR0005)
        dbSelectArea("VAI")
        dbGoTop()
        
        While xFilial("VAI") == VAI_FILIAL .and. !Eof()
*/
                                             
/*   Nao deletar                      
           If !empty(MVG_PAR07)
              If VAI->VAI_CODTEC != MVG_PAR07
                 dbSkip()
                 Loop
              EndIf
           EndIf
*/
/*
           If VAI->VAI_FUNPRO == "1"
              aWrk := FG_CALTEM(VAI->VAI_CODTEC,MVG_PAR01,"2",MVG_PAR02,,"R",,,)
              If len(aWrk) > 0
                 aTpoPro[01,01] += aWrk[01,01]
                 aTpoPro[01,02] += aWrk[01,02]
                 aTpoPro[02,01] += aWrk[02,01]
                 aTpoPro[02,02] += aWrk[02,02]
                 aTpoPro[03,01] += aWrk[03,01]
                 aTpoPro[03,02] += aWrk[03,02]
              EndIf
           EndIf

           dbSelectArea("VAI")
           dbSkip()           

        EndDo
        
        IncRegua(STR0005)
                     
//        If !empty(MVG_PAR07)
//           aTpoVen := FG_CALTEM(MVG_PAR07,MVG_PAR01,"I",MVG_PAR02,,"R",,,)
//        Else
           aTpoVen := FG_CALTEM(,MVG_PAR01,"I",MVG_PAR02,,"R",,,)
//        EndIf

        nTPVNSG := aTpoVen[03,01]
        nTPVNSC := aTpoVen[03,02]
        nTPDSSG := 0
        nTPDSSC := 0

        Pergunte("OFR190",.F.) // ATO
        MVT_PAR24 := MV_PAR24
        MVT_PAR25 := MV_PAR25

        DbSelectArea("VAI")   
        DbGoTop()

        While VAI->VAI_FILIAL == xFilial("VAI") .and. !eof()

           nRecVAI := RecNo()
           If VAI->VAI_FUNPRO == "1"                 
              Do Case
                 Case VAI->VAI_FUNCAO $ MVT_PAR24
                      nTPDSSG += FG_CALTEM(VAI->VAI_CODTEC,MVG_PAR01,"0",MVG_PAR02)
                 Case VAI->VAI_FUNCAO $ MVT_PAR25
                      nTPDSSC += FG_CALTEM(VAI->VAI_CODTEC,MVG_PAR01,"0",MVG_PAR02)
              EndCase
           EndIf

           DbSelectArea("VAI")
           dbGoTo(nRecVAI)
           DbSkip()
        EndDo

        nLin ++
        @ nLin++,1 PSAY OemToAnsi(STR0032)+" "+MVG_PAR05
        @ nLin++,1 PSAY OemToAnsi(STR0033)+" "+MVG_PAR06
        
        nLin ++
        @ nLin++,1 PSAY OemToAnsi(STR0004)
        @ nLin++,1 PSAY OemToAnsi(STR0005)
        @ nLin++,1 PSAY OemToAnsi(STR0006)
        @ nLin++,1 PSAY OemToAnsi(STR0007)+Transform(aQtdPas[01,01],"@ez 999,999")+"|"+;
                                           Transform(aQtdPas[01,02],"@ez 999,999")+"|"+;
                                           Transform(aQtdPas[01,03],"@ez 999,999")+"|"+;
                                           OemToAnsi(STR0008)+;
                                           Transform(nVLMOSG,"@ez 999,999,999.99")
        @ nLin++,1 PSAY OemToAnsi(STR0009)+Transform(aQtdPas[02,01],"@ez 999,999")+"|"+;
                                           Transform(aQtdPas[02,02],"@ez 999,999")+"|"+;
                                           Transform(aQtdPas[02,03],"@ez 999,999")+"|"+;
                                           OemToAnsi(STR0010)+;
                                           Transform(nVLMORP,"@ez 999,999,999.99")
        @ nLin++,1 PSAY OemToAnsi(STR0011)+Transform(aQtdPas[03,01],"@ez 999,999")+"|"+;
                                           Transform(aQtdPas[03,02],"@ez 999,999")+"|"+;
                                           Transform(aQtdPas[03,03],"@ez 999,999")+"|"+;
                                           OemToAnsi(STR0012)+;
                                           Transform(nVLMOSC,"@ez 999,999,999.99")
        @ nLin++,1 PSAY OemToAnsi(STR0013)+Transform(aQtdPas[04,01],"@ez 999,999")+"|"+;
                                           Transform(aQtdPas[04,02],"@ez 999,999")+"|"+;
                                           Transform(aQtdPas[04,03],"@ez 999,999")+"|"+;
                                           OemToAnsi(STR0014)+;
                                           Transform(nVLPCOF,"@ez 999,999,999.99")
        @ nLin++,1 PSAY OemToAnsi(STR0015)+Transform(nVLPCBL,"@ez 999,999,999.99")
        @ nLin++,1 PSAY OemToAnsi(STR0016)+Transform(nVLMOPB,"@ez 999,999,999.99")
        @ nLin++,1 PSAY OemToAnsi(STR0017)
        @ nLin++,1 PSAY OemToAnsi(STR0018)
        @ nLin++,1 PSAY OemToAnsi(STR0019)
        @ nLin++,1 PSAY OemToAnsi(STR0020)
        @ nLin++,1 PSAY OemToAnsi(STR0021)+Transform(MVV_PAR01+MVV_PAR02,"@ez 999,999")+"|"+;
                                           Transform(MVV_PAR01,"@ez 999,999")+"|"+;
                                           Transform(MVV_PAR02,"@ez 999,999")+"|"+;
                                           OemToAnsi(STR0022)+;
                                           Transform(aTpoPro[03,01],"@ez 999,999:99")+"|"+;
                                           Transform(aTpoPro[03,02],"@ez 999,999:99")+"|"
        @ nLin++,1 PSAY OemToAnsi(STR0023)+Transform(MVV_PAR03+MVV_PAR04,"@ez 999,999")+"|"+;
                                           Transform(MVV_PAR03,"@ez 999,999")+"|"+;
                                           Transform(MVV_PAR04,"@ez 999,999")+"|"+;
                                           OemToAnsi(STR0024)+;
                                           Transform(aTpoPro[02,01],"@ez 999,999:99")+"|"+;
                                           Transform(aTpoPro[02,02],"@ez 999,999:99")+"|"
        @ nLin++,1 PSAY OemToAnsi(STR0025)+Transform(MVV_PAR05+MVV_PAR06,"@ez 999,999")+"|"+;
                                           Transform(MVV_PAR05,"@ez 999,999")+"|"+;
                                           Transform(MVV_PAR06,"@ez 999,999")+"|"+;
                                           OemToAnsi(STR0026)+;
                                           Transform(nTPDSSG,"@ez 999,999:99")+"|"+;
                                           Transform(nTPDSSC,"@ez 999,999:99")+"|"
        @ nLin++,1 PSAY OemToAnsi(STR0027)+Transform(MVV_PAR07+MVV_PAR08,"@ez 999,999")+"|"+;
                                           Transform(MVV_PAR07,"@ez 999,999")+"|"+;
                                           Transform(MVV_PAR08,"@ez 999,999")+"|"+;
                                           OemToAnsi(STR0028)+;
                                           Transform(nTPVNSG,"@ez 999,999:99")+"|"+;
                                           Transform(nTPVNSC,"@ez 999,999:99")+"|"
        @ nLin++,1 PSAY OemToAnsi(STR0029)+Transform(MVV_PAR09+MVV_PAR10,"@ez 999,999")+"|"+;
                                           Transform(MVV_PAR09,"@ez 999,999")+"|"+;
                                           Transform(MVV_PAR10,"@ez 999,999")+"|"
        @ nLin++,1 PSAY OemToAnsi(STR0030)+Transform(MVV_PAR11+MVV_PAR12,"@ez 999,999")+"|"+;
                                           Transform(MVV_PAR11,"@ez 999,999")+"|"+;
                                           Transform(MVV_PAR12,"@ez 999,999")+"|"
        @ nLin++,1 PSAY OemToAnsi(STR0031)+Transform(MVV_PAR13+MVV_PAR14,"@ez 999,999")+"|"+;
                                           Transform(MVV_PAR13,"@ez 999,999")+"|"+;
                                           Transform(MVV_PAR14,"@ez 999,999")+"|"
        
   Case MVG_PAR04 == 2 // Volkswagen Caminhoes/Onibus

EndCase
Eject

Set Printer to
Set device to Screen

MS_FLUSH()

Return
*/