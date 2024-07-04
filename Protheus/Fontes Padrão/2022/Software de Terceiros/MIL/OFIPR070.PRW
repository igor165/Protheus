#Include "OFIPR070.ch" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OFIPR070 ºAutor  ³Andre Luis Almeida  º Data ³  18/04/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio de Contas a Receber Titulos Vencidos              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MIL                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIPR070

Local oReport
Private cStr   := ""
Private aNumCRT := {}
Private cParTot := "  /  "
Private lParTot := .f.
Private lObserv := (SE1->(FieldPos("E1_OBSERV")) # 0)

If !(FindFunction("TRepInUse") .And. TRepInUse())
   Return PR070R3() // Executa versão anterior do fonte
Else
	If TRepInUse()
	   oReport := ReportDef()
	   oReport:PrintDialog()
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef³ Autor ³ ANDRE                 ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio usando o TReport                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()

Local oReport 
Local oSection1 
Local oCell

oReport := TReport():New("OFIPR070",OemToAnsi(STR0009),"",{|oReport| PR070Imp(oReport)})//Contas a Receber Titulos Vencidos

oSection1 := TRSection():New(oReport,OemToAnsi("Secao 1"),{})
TRCell():New(oSection1,"",,"","@!",220,, {|| cStr } )

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PR070Imp ³ Autor ³ ANDRE                 ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a impressao do relatorio do TReport                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PR070Imp(oReport)

Local oSection1 := oReport:Section(1)

dbSelectArea("SB1")
dbSetOrder(7)

dbSelectArea("SB2")
dbSetOrder(1)

dbSelectArea("VE9")
dbSetOrder(1)
dbSeek(xFilial("VE9"))

oReport:SetMeter(RecCount())
oSection1:Init(.f.)

cabec1    := space(20)+STR0005
cabec2    := STR0006

cStr := cabec1
oSection1:PrintLine()

cStr := cabec2
oSection1:PrintLine()

cStr := repl("-",100)
oSection1:PrintLine()

aAdd(aNumCRT,{ STR0007 , 0 , 0 }) 
cCidade := "INICIAL"
DbSelectArea("SX3")
DbSetOrder(2)
If DbSeek("E1_PARTOT")
	lParTot := .t.
EndIf
DbSelectArea("SE1") 
DbSetOrder(7)
DbSeek( xFilial("SE1") )    
Do While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1") .and. (SE1->E1_VENCREA<dDataBase)
	If !(SE1->E1_SALDO>0)
	   DbSelectArea("SE1") 
		DbSkip()     	          
      Loop
   EndIf 
   aNumCRT[1,2]++
   aNumCRT[1,3]+= SE1->E1_SALDO
	DbSelectArea("SA1")  
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA )
	If cCidade # SA1->A1_MUN + SA1->A1_EST
		cCidade := SA1->A1_MUN + SA1->A1_EST
		DbSelectArea("N31")
		DbSetOrder(1)
		DbSeek( xFilial("N31") + SA1->A1_MUN + SA1->A1_EST ) 
   EndIf
	If lParTot
		If Empty(SE1->E1_PARTOT)
			FS_ALTERAR_SE1_PARC(SE1->(RecNo()),7,SE1->E1_PREFIXO+SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO)
		EndIf
		cParTot := Transform(SE1->E1_PARTOT,"@R 99/99")
	EndIf
                        
   cStr := SA1->A1_CGC +" "+ left(SA1->A1_NOME,23) +" " ;
								+ SE1->E1_PREFORI +" "+ SE1->E1_PREFIXO +" "+ SE1->E1_NUM + "-" + SE1->E1_PARCELA +" "+ cParTot +" " ;
								+ Transform(SE1->E1_EMISSAO,"@D") +" "+ Transform(SE1->E1_VENCREA,"@D") +" "+ Transform(SE1->E1_VENCREA-dDataBase,"@E 999999") ;
								+ Transform(SE1->E1_SALDO,"@E 99999,999.99") +" "+ SE1->E1_PORTADO +" "+ N31->N31_DDD +" "+ left(SA1->A1_TEL,12) + IIF(lObserv,SE1->E1_OBSERV,"")
   oSection1:PrintLine()

   DbSelectArea("SE1")  
	DbSkip()     	          
EndDo             

cStr := Repl("-",132) 
oSection1:PrintLine()
cStr := aNumCRT[1,1] + space(06) + "  (" + Transform(aNumCRT[1,2] ,"@E 999,999") + STR0008+" )" + space(7) + Transform(aNumCRT[1,3] ,"@E 999,999,999,999.99") 
oSection1:PrintLine()
cStr := Repl("-",132) 
oSection1:PrintLine()

oSection1:Finish()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef³ Autor ³ ANDRE                 ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio usando o TReport                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PR070R3

cDesc1    := STR0001
cDesc2    := ""
cDesc3    := ""
cAlias    := "SE1"
aRegistros:= {}
nLin      := 1
aPag      := 1
nIte      := 1
aReturn   := { OemToAnsi(STR0002), 1,OemToAnsi(STR0003), 1, 2, 1, "",1 }
cTamanho  := "M"          // P/M/G
Limite    := 132           // 80/132/220
aOrdem    := {}          // Ordem do Relatorio
cTitulo   := STR0004
cNomeProg := "OFIPR070"
cNomeRel  := "OFIPR070"
nLastKey  := 0
nCaracter := 15
cabec1    := space(20)+STR0005
cabec2    := STR0006

cNomeRel:=SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)

If nLastKey == 27
   Return
EndIf     
                        
SetDefault(aReturn,cAlias)
RptStatus( { |lEnd| FS_IMPM_RCRVEN(@lEnd,cNomeRel,cAlias) } , cTitulo )

If aReturn[5] == 1
   OurSpool( cNomeRel )
EndIf

MS_Flush()
Return
           
Static Function FS_IMPM_RCRVEN()
                  
Private cbTxt   := Space(10)
Private cbCont  := 0
Private cString := "SE1"
Private Li      := 132
Private m_Pag   := 1
Private wnRel   := "OFIPR070"
Private aNumCRT := {}
Private cParTot := "  /  "
Private lParTot := .f.

Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer
nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1      

aAdd(aNumCRT,{ STR0007 , 0 , 0 }) 
cCidade := "INICIAL"
DbSelectArea("SX3")
DbSetOrder(2)
If DbSeek("E1_PARTOT")
	lParTot := .t.
EndIf
DbSelectArea("SE1") 
DbSetOrder(7)
DbSeek( xFilial("SE1") )    
SetRegua( RecCount() )       
Do While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1") .and. (SE1->E1_VENCREA<dDataBase)
	IncRegua()
	If !(SE1->E1_SALDO>0)
	   DbSelectArea("SE1") 
		DbSkip()     	          
      Loop
   EndIf 
   aNumCRT[1,2]++
   aNumCRT[1,3]+= SE1->E1_SALDO
	DbSelectArea("SA1")  
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA )
	If cCidade # SA1->A1_MUN + SA1->A1_EST
		cCidade := SA1->A1_MUN + SA1->A1_EST
		DbSelectArea("N31")
		DbSetOrder(1)
		DbSeek( xFilial("N31") + SA1->A1_MUN + SA1->A1_EST ) 
   EndIf
	If nLin >= 60
    	nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1      
	EndIf 
	If lParTot
		If Empty(SE1->E1_PARTOT)
			FS_ALTERAR_SE1_PARC(SE1->(RecNo()),7,SE1->E1_PREFIXO+SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO)
		EndIf
		cParTot := Transform(SE1->E1_PARTOT,"@R 99/99")
	EndIf
	@ nLin++ , 00 psay  SA1->A1_CGC +" "+ left(SA1->A1_NOME,23) +" " ;
								+ SE1->E1_PREFORI +" "+ SE1->E1_PREFIXO +" "+ SE1->E1_NUM + "-" + SE1->E1_PARCELA +" "+ cParTot +" " ;
								+ Transform(SE1->E1_EMISSAO,"@D") +" "+ Transform(SE1->E1_VENCREA,"@D") +" "+ Transform(SE1->E1_VENCREA-dDataBase,"@E 999999") ;
								+ Transform(SE1->E1_SALDO,"@E 99999,999.99") +" "+ SE1->E1_PORTADO +" "+ N31->N31_DDD +" "+ left(SA1->A1_TEL,12)  + IIF(lObserv,SE1->E1_OBSERV,"")
   DbSelectArea("SE1")  
	DbSkip()     	          
EndDo             

nLin++
@ nLin++ , 00 psay Repl("-",132) 
nLin++
@ nLin++ , 06 psay aNumCRT[1,1] + space(06) + "  (" + Transform(aNumCRT[1,2] ,"@E 999,999") + STR0008+" )" + space(7) + Transform(aNumCRT[1,3] ,"@E 999,999,999,999.99") 
nLin++
@ nLin++ , 00 psay Repl("-",132) 

Set Printer to
Set Device  to Screen

Return
               

Static Function FS_ALTERAR_SE1_PARC(nRecSE1,nOrdSE1,cTitNro,cTitPar,cTitTip)
Local cParcela := "" 
Local cTotParc := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ/.-*,;"
nTotPar := 0
DbSelectArea("SE1") 
DbSetOrder(1)
DbSeek( xFilial("SE1") + cTitNro )    
Do	While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1") .and. ( SE1->E1_PREFIXO + SE1->E1_NUM == cTitNro )
	If SE1->E1_TIPO == cTitTip
	   nTotPar++
	EndIf
   DbSelectArea("SE1")  
	DbSkip()     	          
EndDo             
DbSelectArea("SE1") 
DbSetOrder(1)
DbSeek( xFilial("SE1") + cTitNro )    
Do	While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1") .and. ( SE1->E1_PREFIXO + SE1->E1_NUM == cTitNro )
	If SE1->E1_TIPO == cTitTip
		cParcela := strzero(At(SE1->E1_PARCELA,cTotParc),2)
		If cParcela == "00"
			cParcela := "01"
		EndIf
		cParcela := cParcela + strzero(nTotPar,2)
		DbSelectArea("SE1") 		
		RecLock("SE1",.f.)
		SE1->E1_PARTOT := cParcela
		MsUnlock()
	EndIf
   DbSelectArea("SE1")  
	DbSkip()     	          
EndDo             
DbSelectArea("SE1") 
DbSetOrder( nOrdSE1 )
DbGoTo( nRecSE1 )    
Return
