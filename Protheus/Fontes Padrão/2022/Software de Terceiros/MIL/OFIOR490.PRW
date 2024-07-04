#Include "OFIOR490.CH"
#Include "Protheus.ch" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOR490 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 02/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Pos-Venda - SCANIA                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR490

Local cDesc1	 := STR0001
Local cDesc2	 := ""                
Local cDesc3	 := ""
Local cAlias	 := "SF2"                        
Private nLin 	 := 1
Private aReturn := { STR0024, 1,STR0025, 2, 2, 1, "",1 } //"Zebrado # Administracao
Private cTamanho:= "P"          // P/M/G
Private Limite  := 80           // 80/132/220
Private aOrdem  := {}          // Ordem do Relatorio
Private nCaracter:=15
Private cTitulo := STR0001
Private cNomProg:= "OFIOR490"
Private cNomeRel:= "OFIOR490"
Private cabec1  := "" 
Private cabec2  := "" 
Private nLastKey:= 0                       
Private cPerg   := "OFR490"

cNomeRel := SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
	Return
EndIf     

PERGUNTE("OFR490",.f.)

SetDefault(aReturn,cAlias)
RptStatus( { |lEnd| ImpOR490(@lEnd,cNomeRel,cAlias) } , cTitulo )
If aReturn[5] == 1
   OurSpool( cNomeRel )
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpOR490  ºAutor  ³Andre Luis Almeida  º Data ³  02/07/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡ao ³ Impressao Relatorio de Pos-Venda - SCANIA                  ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ImpOR490(lEnd,wNRel,cAlias)

Private nLin := 1 , nCont := 0 , nPos := 0 , ni := 0 , nRecVAI := 0
Private cbTxt  := Space(10)
Private cbCont := 0
Private cString:= "SF2"
Private Li     := 80
Private m_Pag	:= 1
Private lAbortPrint := .f.
Private aRet 	:= {}
Private nTot01 := 0
Private nTot02	:= 0
Private nTot03	:= 0
Private nTot04	:= 0
Private nTot05	:= 0
Private nTot06	:= 0
Private nTot07	:= 0
Private nTot08	:= 0
Private nTot09	:= 0
Private nTot10	:= 0
Private nTot11	:= 0
Private nTot12	:= 0
Private nTot13	:= 0

Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer

	SetRegua(13)

	IncRegua()

	DbSelectArea("VAI")   
	DbGoTop()
	While VAI->VAI_FILIAL == xFilial("VAI") .and. !eof()
		nRecVAI := RecNo()
		If VAI->VAI_FUNPRO == "1"                 
			// 01 - Horas Disponiveis na Oficina
			nTot01 += FG_CALTEM(VAI->VAI_CODTEC,MV_PAR01,"0",MV_PAR02)
		EndIf
		DbSelectArea("VAI")
		DbGoTo(nRecVAI)
		DbSkip()
   EndDo

	IncRegua()

	DbSelectArea("VAI")   
	DbSetOrder(1)
	DbSeek( xFilial("VAI") )
	While !eof() .and. VAI->VAI_FILIAL == xFilial("VAI")
		
		If VAI->VAI_FUNPRO == "1"                 

				// 02 - Horas Trabalhadas na Oficina
         nTot02 += FG_CALTEM(VAI->VAI_CODTEC,MV_PAR01,"2",MV_PAR02,,"G",,,)
           	
				// 03 - Horas Vendidas na Oficina
			nTot03 += FG_CALTEM(VAI->VAI_CODTEC,MV_PAR01,"5",MV_PAR02,,"G",,,)

		   	// 04 - Horas Vendidas - Interna
			nTot04 += FG_CALTEM(VAI->VAI_CODTEC,MV_PAR01,"5",MV_PAR02,,"A","3",,)

		EndIf

		DbSelectArea("VAI")
		DbSkip()

	EndDo

	  	// 05 - Horas Vendidas - Externa
	nTot05 := nTot03 - nTot04
 
   IncRegua()

      // 06 - Faturamento de Pecas Balcao
  	nTot06 := FG_CALTEM(,MV_PAR01,"D",MV_PAR02,,"B",,,)

   IncRegua()

		// 07 - Faturamento de Pecas Oficina
   nTot07 := FG_CALTEM(,MV_PAR01,"D",MV_PAR02,,"O",,,)

	IncRegua()

      // 08 - Faturamento de Mao-de-Obra Oficina
   nTot08 := FG_CALTEM(,MV_PAR01,"7",MV_PAR02,,"G",,,)  

	IncRegua()
	
		// 09 - Valor de Hora de Mao-de-Obra Oficina
   nTot09 := FG_VALHOR(MV_PAR03,MV_PAR02)  

	IncRegua()

		// 10 - Total de Compras Pecas Originais
	nTot10 := FG_CALEST("2",MV_PAR01,MV_PAR02,"O",)

	IncRegua()

		// 11 - Total de Compras Pecas Nao-Originais
	nTot11 := FG_CALEST("2",MV_PAR01,MV_PAR02,"N",)

	IncRegua()

		// 12 - Custo das Vendas - Balcao
	nTot12 := FG_CALEST("1",MV_PAR01,MV_PAR02,,"B")

	IncRegua()

		// 12 - Custo das Vendas - Oficina
	nTot12 += FG_CALEST("1",MV_PAR01,MV_PAR02,,"O") 
	
	IncRegua()

		// 13 - Estoque Medio
	nTot13 := FG_CALEST("0",,,"G",)

	IncRegua()

	///////////////////////////////////////////////////////////
	//                                                       //
	//          I   M   P   R   E   S   S   A   O            //
	//                                                       //
	///////////////////////////////////////////////////////////

nLin := cabec(cTitulo,cabec1,cabec2,cNomProg,ctamanho,nCaracter) + 1      

nLin++
If MV_PAR10 == 1
	@ nLin++ , 00 psay MV_PAR11 
	@ nLin++ , 00 psay STR0004 + MV_PAR12 
	nLin++ 
	@ nLin++ , 00 psay STR0005 + MV_PAR13 + " - " + MV_PAR14
	@ nLin++ , 00 psay STR0006 + MV_PAR15 
	nLin++ 
	@ nLin++ , 00 psay STR0007 + MV_PAR16
	nLin++
	nLin++
	nLin++
EndIf	

@ nLin++ , 00 psay STR0002
@ nLin++ , 00 psay STR0003
nLin++
@ nLin++ , 00 psay Repl("-",80)                                                                                  
@ nLin++ , 00 psay STR0008 + Transform(nTot01,"@R 99999999,999,999,999:99") + "  |" 
@ nLin++ , 00 psay Repl("-",80) 
@ nLin++ , 00 psay STR0009 + Transform(nTot02,"@R 99999999,999,999,999:99") + "  |" 
@ nLin++ , 00 psay Repl("-",80)                                              
@ nLin++ , 00 psay STR0010 + Transform(nTot03,"@R 99999999,999,999,999:99") + "  |" 
@ nLin++ , 00 psay Repl("-",80) 
@ nLin++ , 00 psay STR0011 + Transform(nTot04,"@R 99999999,999,999,999:99") + "  |" 
@ nLin++ , 00 psay Repl("-",80) 
@ nLin++ , 00 psay STR0012 + Transform(nTot05,"@R 99999999,999,999,999:99") + "  |" 
@ nLin++ , 00 psay Repl("-",80) 
@ nLin++ , 00 psay STR0013 + Transform(nTot06,"@E 9999,999,999,999,999.99") + "  |" 
@ nLin++ , 00 psay Repl("-",80) 
@ nLin++ , 00 psay STR0014 + Transform(nTot07,"@E 9999,999,999,999,999.99") + "  |" 
@ nLin++ , 00 psay Repl("-",80) 
@ nLin++ , 00 psay STR0015 + Transform(nTot08,"@E 9999,999,999,999,999.99") + "  |" 
@ nLin++ , 00 psay Repl("-",80) 
@ nLin++ , 00 psay STR0016 + Transform(nTot09,"@E 9999,999,999,999,999.99") + "  |" 
@ nLin++ , 00 psay Repl("-",80) 
@ nLin++ , 00 psay STR0017 + Transform(nTot10,"@E 9999,999,999,999,999.99") + "  |" 
@ nLin++ , 00 psay Repl("-",80) 
@ nLin++ , 00 psay STR0018 + Transform(nTot11,"@E 9999,999,999,999,999.99") + "  |" 
@ nLin++ , 00 psay Repl("-",80) 
@ nLin++ , 00 psay STR0019 + Transform(nTot12,"@E 9999,999,999,999,999.99") + "  |" 
@ nLin++ , 00 psay Repl("-",80) 
@ nLin++ , 00 psay STR0020 + Transform(nTot13,"@E 9999,999,999,999,999.99") + "  |" 
@ nLin++ , 00 psay Repl("-",80) 
@ nLin++ , 00 psay STR0021
@ nLin++ , 00 psay STR0022
@ nLin++ , 00 psay "|    " + Transform(MV_PAR04,"@E 9,999,999,999.99") + "      |    " + Transform(MV_PAR05,"@E 9,999,999,999.99") + "     |    " + Transform(MV_PAR06,"@E 9,999,999,999.99") + "     |" 
@ nLin++ , 00 psay STR0023
@ nLin++ , 00 psay "|    " + Transform(MV_PAR07,"@E 9,999,999,999.99") + "      |    " + Transform(MV_PAR08,"@E 9,999,999,999.99") + "     |    " + Transform(MV_PAR09,"@E 9,999,999,999.99") + "     |" 
@ nLin++ , 00 psay Repl("-",80) 
nLin++
nLin++

IncRegua()

Ms_Flush()
Set Printer to
Set Device  to Screen              
Return