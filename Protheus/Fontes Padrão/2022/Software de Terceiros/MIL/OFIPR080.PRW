#Include "OFIPR080.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIPR080 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 27/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Clientes Periodicos por NF's ou Titulos       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIPR080()
Local oReport 
Local aArea := GetArea()
Private cImp := ""
Private lA1_IBGE := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
Private cPerg := "OFP080" 
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rafael Goncalves 02/12/2009             ³
//³FNC 00000028292-2009-00                 ³
//³Alterar descrição do parametro 1 opção 2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
ValidPerg()
//Fim
If FindFunction("TRepInUse") .And. TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	FS_OFP080R3()
EndIf
RestArea( aArea )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef³ Autor ³ Andre Luis Almeida    ³ Data ³ 14/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio usando o TReport                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oSection4
Local oCell
oReport := TReport():New("OFIPR080",STR0001,cPerg,{|oReport| OFP080IMP(oReport)})

oSection1 := TRSection():New(oReport,STR0001,{})
TRCell():New(oSection1,"",,"","@!",80,,{|| cImp })

oSection2 := TRSection():New(oReport,OemToAnsi(STR0020),{"SF2","VAI"})   //NF
TRCell():New(oSection2,"",,"","@!",8,,{|| space(8) })
TRCell():New(oSection2,"F2_DOC"    ,"SF2")
TRCell():New(oSection2,"F2_SERIE"  ,"SF2")
TRCell():New(oSection2,"F2_PREFIXO","SF2")                                      
TRCell():New(oSection2,"F2_EMISSAO","SF2",,"@D",8)
TRCell():New(oSection2,"VAI_NOMTEC","VAI",,,22)
TRCell():New(oSection2,"F2_VALBRUT","SF2",,"@E 999,999,999.99",14)

oSection3 := TRSection():New(oReport,OemToAnsi(STR0019),{"SE1"})    //Titulo
TRCell():New(oSection3,"",,"","@!",13,,{|| space(13) })
TRCell():New(oSection3,"E1_PREFIXO","SE1")
TRCell():New(oSection3,"E1_NUM"    ,"SE1")
TRCell():New(oSection3,"E1_PARCELA","SE1")
TRCell():New(oSection3,"E1_TIPO"   ,"SE1")
TRCell():New(oSection3,"E1_PORTADO","SE1")
TRCell():New(oSection3,"E1_EMISSAO","SE1",,"@D",8)
TRCell():New(oSection3,"E1_VENCTO" ,"SE1",,"@D",8)
TRCell():New(oSection3,"E1_VALOR"  ,"SE1",,"@E 999,999,999.99",14)

If lA1_IBGE
	oSection4 := TRSection():New(oReport,OemToAnsi(STR0018),{"SA1","VAM"})   //Cliente
	TRCell():New(oSection4,"A1_NOME"   ,"SA1",,,30)
	TRCell():New(oSection4,"VAM_DESCID","VAM",,,25)
	TRCell():New(oSection4,"VAM_ESTADO","VAM",,,2)
Else
	oSection4 := TRSection():New(oReport,OemToAnsi(STR0018),{"SA1"})  //Cliente
	TRCell():New(oSection4,"A1_NOME"   ,"SA1",,,30)
	TRCell():New(oSection4,"A1_MUN"    ,"SA1",,,25)
	TRCell():New(oSection4,"A1_EST"    ,"SA1",,,2)
EndIf
TRCell():New(oSection4,"",,"","@!",len(STR0007),,{|| STR0007 })
TRCell():New(oSection4,"A1_TEL"    ,"SA1")

TRPosition():New(oSection2,"VAI",1,{|| xFilial()+SF2->F2_VEND1 })
If lA1_IBGE
	TRPosition():New(oSection4,"VAM",1,{|| xFilial()+SA1->A1_IBGE  })
EndIf

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFP080IMP³ Autor ³ Andre Luis Almeida    ³ Data ³ 14/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a impressao do relatorio do TReport                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFP080IMP(oReport)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local oSection3 := oReport:Section(3)
Local oSection4 := oReport:Section(4)
PERGUNTE(cPerg,.F.)
If !Empty(MV_PAR02)
	oReport:SetMeter(2)
	oSection1:Init()
	oSection2:Init()
	oSection3:Init()
	oSection4:Init()
	cImp := STR0004+"(" + If(MV_PAR01==1,STR0005,STR0006) + rtrim(MV_PAR02) + ")"
	oSection1:PrintLine()
	oReport:IncMeter()
	If MV_PAR01 == 1 // Nro.NF + Serie
		DbSelectArea( "SF2" )
		DbSetOrder(1) // Nro.NF + Serie
		If DbSeek( xFilial("SF2") + rtrim(MV_PAR02) )
		 	DbSelectArea( "SA1" )
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA )
			cImp := Repl("*",80)
			oSection1:PrintLine()
			oReport:SkipLine()
			oSection4:PrintLine()
			oReport:SkipLine()
			cImp := "."+STR0008
			oSection1:PrintLine()
			oReport:SkipLine()
			oSection2:PrintLine()
			cF2_DOC := SF2->F2_DOC + SF2->F2_SERIE
			cE1_NUM := SF2->F2_DUPL
			cPrefix := SF2->F2_PREFIXO
			lEntrou := .f.
			If !Empty(cE1_NUM)
				DbSelectArea( "SF2" )
				DbSetOrder(1)
				DbSeek( xFilial("SF2") )    
				While !Eof() .and. SF2->F2_FILIAL == xFilial("SF2") 
					If SF2->F2_DUPL == cE1_NUM .and. ( SF2->F2_DOC + SF2->F2_SERIE ) # cF2_DOC
						If !lEntrou
							lEntrou := .t.
							oReport:SkipLine()
							cImp := "."+STR0009
							oSection1:PrintLine()
	      	      EndIf
						oSection2:PrintLine()
					EndIf
					DbSelectArea( "SF2" )
					Dbskip()
				EndDo
				oReport:SkipLine()
				cImp := Repl("*",80)
				oSection1:PrintLine()
			EndIf
			DbSelectArea( "SE1" )
			DbSetOrder(1)
			If DbSeek( xFilial("SE1") + cPrefix + cE1_NUM )
				oReport:SkipLine()
				cImp := "."+STR0010
				oSection1:PrintLine()
				oReport:SkipLine()
				While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1") .and. cE1_NUM == SE1->E1_NUM .and. cPrefix == SE1->E1_PREFIXO
					oSection3:PrintLine()
					DbSelectArea( "SE1" )
					Dbskip()
				EndDo
			Else
				oReport:SkipLine()
				cImp := "."+STR0011+rtrim(MV_PAR02)
				oSection1:PrintLine()
			EndIf
		Else
			oReport:SkipLine()
			cImp := "."+space(4)+STR0012+rtrim(MV_PAR02)+" "+STR0013
			oSection1:PrintLine()
		EndIf
	Else // Pref.Titulo + Nro Titulo
		DbSelectArea( "SE1" )
		DbSetOrder(1) // Pref.Titulo + Nro Titulo
		If DbSeek( xFilial("SE1") + rtrim(MV_PAR02) )
		 	DbSelectArea( "SA1" )
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA )
			cE1_NUM := SE1->E1_NUM
			cImp := Repl("*",80)
			oSection1:PrintLine()
			oReport:SkipLine()
			oSection4:PrintLine()
			oReport:SkipLine()
			cImp := "."+STR0010
			oSection1:PrintLine()
			oReport:SkipLine()
			While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1") .and. left(SE1->E1_PREFIXO+SE1->E1_NUM,len(rtrim(MV_PAR02))) == rtrim(MV_PAR02)
				oSection3:PrintLine()
				DbSelectArea( "SE1" )
				Dbskip()
			EndDo
			oReport:SkipLine()
			cImp := Repl("*",80)
			oSection1:PrintLine()
			DbSelectArea( "SF2" )
			DbSetOrder(1)
			DbSeek( xFilial("SF2") )    
			lEntrou := .f.
			While !Eof() .and. SF2->F2_FILIAL == xFilial("SF2") 
				If SF2->F2_DUPL == cE1_NUM
					If !lEntrou
						lEntrou := .t.
						oReport:SkipLine()
						cImp := "."+STR0008
						oSection1:PrintLine()
						oReport:SkipLine()
	            EndIf
					oSection2:PrintLine()
				EndIf
				DbSelectArea( "SF2" )
				Dbskip()
			EndDo
			If !lEntrou
				oReport:SkipLine()
				cImp := "."+STR0014+rtrim(MV_PAR02)
				oSection1:PrintLine()
			EndIf
		Else
			oReport:SkipLine()
			cImp := "."+space(4)+STR0015+rtrim(MV_PAR02)+" "+STR0013
			oSection1:PrintLine()
		EndIf
	EndIf
	oReport:IncMeter()
	oSection1:Finish()
	oSection2:Finish()
	oSection3:Finish()
	oSection4:Finish()
Else
	MsgAlert(STR0017,STR0016)
EndIf
Return Nil

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function FS_OFP080R3()
Local cDesc1	  := STR0001
Local cDesc2	  := ""                
Local cDesc3	  := ""
Local cAlias	  := "SE1"                        
Private nLin 	  := 1
Private aReturn  := { OemToAnsi(STR0002), 1,OemToAnsi(STR0003), 2, 2, 1, "",1 }
Private cTamanho := "P"           // P/M/G
Private Limite   := 80           // 80/132/220
Private aOrdem   := {}           // Ordem do Relatorio
Private cTitulo  := STR0001
Private cNomProg := "OFIPR080"
Private cNomeRel := "OFIPR080"
Private nLastKey := 0
cNomeRel := SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
   Return
EndIf     
PERGUNTE(cPerg,.f.)
SetDefault(aReturn,cAlias)
RptStatus( { |lEnd| ImpRFIPER(@lEnd,cNomeRel,cAlias) } , cTitulo )
If aReturn[5] == 1
   OurSpool( cNomeRel )
EndIf
Return
////////////////////////////////////////////////////////////
Function ImpRFIPER(lEnd,wNRel,cAlias)
Private nLin    := 0
Private cTitulo , cabec1 , cabec2 , nomeprog , tamanho , nCaracter
Private cbTxt   := Space(10)
Private cbCont  := 0
Private cString := "SE1"
Private Li      := 80
Private m_Pag   := 1
Private lAbortPrint := .f.
Private lEntrou := .f.
If !Empty(MV_PAR02)
	Set Printer to &cNomeRel
	Set Printer On
	Set Device  to Printer
	cTitulo  := STR0004+"(" + If(MV_PAR01==1,STR0005,STR0006) + rtrim(MV_PAR02) + ")"
	cabec1   := ""
	cabec2   := ""
	nomeprog :="OFIPR080"
	tamanho  :="P"
	nCaracter:=15
	nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1      
	If MV_PAR01 == 1 // Nro.NF + Serie
		DbSelectArea( "SF2" )
		DbSetOrder(1) // Nro.NF + Serie
		If DbSeek( xFilial("SF2") + rtrim(MV_PAR02) )
		 	DbSelectArea( "SA1" )
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA )
			If lA1_IBGE
			 	DbSelectArea( "VAM" )
				DbSetOrder(1)
				DbSeek( xFilial("VAM") + SA1->A1_IBGE )
			EndIf
			@ nLin++ , 00 PSAY Repl("*",80)
			nLin++
			@ nLin++ , 01 PSAY left(SA1->A1_NOME,30) + "    " + left(If(lA1_IBGE,VAM->VAM_DESCID,SA1->A1_MUN),21) + " " + If(lA1_IBGE,VAM->VAM_ESTADO,SA1->A1_EST) + STR0007 + Alltrim(SA1->A1_TEL)
			nLin++
			@ nLin++ , 01 PSAY STR0008
			nLin++           
	  	 	DbSelectArea( "VAI" )
			DbSetOrder(1)
			DbSeek( xFilial("VAI") + SF2->F2_VEND1 )
			@ nLin++ , 08 PSAY SF2->F2_DOC + " " + SF2->F2_SERIE + " " + SF2->F2_PREFIXO + " " + SF2->F2_PREFORI + "   " + Transform(SF2->F2_EMISSAO,"@D") + "  " + left(VAI->VAI_NOMTEC,22) + " " + Transform(SF2->F2_VALBRUT,"@E 999,999,999.99") 
			cF2_DOC := SF2->F2_DOC + SF2->F2_SERIE
			cE1_NUM := SF2->F2_DUPL
			cPrefix := SF2->F2_PREFIXO
			lEntrou := .f.
			If !Empty(cE1_NUM)
				DbSelectArea( "SF2" )
				DbSetOrder(1)
				DbSeek( xFilial("SF2") )    
				While !Eof() .and. SF2->F2_FILIAL == xFilial("SF2") 
					If SF2->F2_DUPL == cE1_NUM .and. ( SF2->F2_DOC + SF2->F2_SERIE ) # cF2_DOC
						If !lEntrou
							lEntrou := .t.
							nLin++           
							@ nLin++ , 01 PSAY STR0009 
		            	EndIf
					 	DbSelectArea( "VAI" )
						DbSetOrder(1)
						DbSeek( xFilial("VAI") + SF2->F2_VEND1 )
						If nLin >= 57
							nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1      
						EndIf
						@ nLin++ , 08 PSAY SF2->F2_DOC + " " + SF2->F2_SERIE + " " + SF2->F2_PREFIXO + " " + SF2->F2_PREFORI + "   " + Transform(SF2->F2_EMISSAO,"@D") + "  " + left(VAI->VAI_NOMTEC,22) + " " + Transform(SF2->F2_VALBRUT,"@E 999,999,999.99") 
					EndIf
					DbSelectArea( "SF2" )
					Dbskip()
				EndDo
				nLin++
				@ nLin++ , 00 PSAY Repl("*",80)
			EndIf
			DbSelectArea( "SE1" )
			DbSetOrder(1)
			If DbSeek( xFilial("SE1") + cPrefix + cE1_NUM )
				nLin++           
				@ nLin++ , 01 PSAY STR0010
				nLin++
				While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1") .and. cE1_NUM == SE1->E1_NUM .and. cPrefix == SE1->E1_PREFIXO 
					If nLin >= 57
						nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1      
					EndIf
					@ nLin++ , 13 PSAY SE1->E1_PREFORI +" "+ SE1->E1_PREFIXO +" "+ SE1->E1_NUM +" "+ SE1->E1_PARCELA +" "+ SE1->E1_TIPO +"    "+ SE1->E1_PORTADO +"   "+ Transform(SE1->E1_EMISSAO,"@D") +"  "+ Transform(SE1->E1_VENCTO,"@D") + Transform(SE1->E1_VALOR,"@E 999,999,999.99")
					DbSelectArea( "SE1" )
					Dbskip()
				EndDo
			Else
				nLin++
				@ nLin++ , 01 PSAY STR0011 + rtrim(MV_PAR02)
			EndIf
		Else
			nLin++
			@ nLin++ , 05 PSAY STR0012 + rtrim(MV_PAR02) +" "+ STR0013
		EndIf
	Else // Pref.Titulo + Nro Titulo
		DbSelectArea( "SE1" )
		DbSetOrder(1) // Pref.Titulo + Nro Titulo
		If DbSeek( xFilial("SE1") + rtrim(MV_PAR02) )
		 	DbSelectArea( "SA1" )
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA )
			If lA1_IBGE
			 	DbSelectArea( "VAM" )
				DbSetOrder(1)
				DbSeek( xFilial("VAM") + SA1->A1_IBGE )
			EndIf
			cE1_NUM := SE1->E1_NUM
			@ nLin++ , 00 PSAY Repl("*",80)
			nLin++
			@ nLin++ , 01 PSAY left(SA1->A1_NOME,30) + "    " + left(If(lA1_IBGE,VAM->VAM_DESCID,SA1->A1_MUN),21) + " " + If(lA1_IBGE,VAM->VAM_ESTADO,SA1->A1_EST) + STR0007 + Alltrim(SA1->A1_TEL)
			nLin++   
			@ nLin++ , 01 PSAY STR0010
			nLin++
			While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1") .and. left(SE1->E1_PREFIXO+SE1->E1_NUM,len(rtrim(MV_PAR02))) == rtrim(MV_PAR02)
				If nLin >= 57
					nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1      
				EndIf
				@ nLin++ , 13 PSAY SE1->E1_PREFORI +" "+ SE1->E1_PREFIXO +" "+ SE1->E1_NUM +" "+ SE1->E1_PARCELA +" "+ SE1->E1_TIPO +"    "+ SE1->E1_PORTADO +"   "+ Transform(SE1->E1_EMISSAO,"@D") +"  "+ Transform(SE1->E1_VENCTO,"@D") + Transform(SE1->E1_VALOR,"@E 999,999,999.99")
				DbSelectArea( "SE1" )
				Dbskip()
			EndDo
			nLin++
			@ nLin++ , 00 PSAY Repl("*",80)
			DbSelectArea( "SF2" )
			DbSetOrder(1)
			DbSeek( xFilial("SF2") )    
			lEntrou := .f.
			While !Eof() .and. SF2->F2_FILIAL == xFilial("SF2") 
				If SF2->F2_DUPL == cE1_NUM
					If !lEntrou
						lEntrou := .t.
						nLin++           
						@ nLin++ , 01 PSAY STR0008 
						nLin++           
	            EndIf
			  	 	DbSelectArea( "VAI" )
					DbSetOrder(1)
					DbSeek( xFilial("VAI") + SF2->F2_VEND1 )
					If nLin >= 57
						nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1      
					EndIf
					@ nLin++ , 08 PSAY SF2->F2_DOC + " " + SF2->F2_SERIE + " " + SF2->F2_PREFIXO + " " + SF2->F2_PREFORI + "   " + Transform(SF2->F2_EMISSAO,"@D") + "  " + left(VAI->VAI_NOMTEC,22) + " " + Transform(SF2->F2_VALBRUT,"@E 999,999,999.99") 
				EndIf
				DbSelectArea( "SF2" )
				Dbskip()
			EndDo
			If !lEntrou
				nLin++
				@ nLin++ , 01 PSAY STR0014 + rtrim(MV_PAR02)
			EndIf
		Else
			nLin++
			@ nLin++ , 05 PSAY STR0015 + rtrim(MV_PAR02) +" "+ STR0013
		EndIf
	EndIf
	Ms_Flush()
	Set Printer to
	Set Device  to Screen
Else
	MsgAlert(STR0017,STR0016)
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºFun‡„o    ³VALIDPERG º Autor ³ AP5 IDE            º Data ³  13/07/01   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidPerg()
Local _sAlias := Alias()
Local aRegs := {}             	
Local ni,nj
Local aEstrSX1 := { "X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02","X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04","X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3","X1_PYME","X1_GRPSXG","X1_HELP","X1_PICTURE","X1_IDFIL" } 
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,LEN(SX1->X1_GRUPO))
If DBSeek(cPerg+"01") .and. Alltrim(SX1->X1_DEF02) <> "Prefixo+Titulo"
	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	Aadd(aRegs,{cPerg,"01","Pesquisar por ?","¿Buscar por ?","Search by ?","mv_ch1","N",1,0,1,"C","","mv_par01","NF + Serie","Factura + Serie","Inv. + Series","","","Prefixo+Titulo","Prefijo+Titulo","Prefix+Bill","","","","","","","","","","","","","","","","","","N","","","",""})
	Aadd(aRegs,{cPerg,"02","Chave para pesquisa ?","¿Clave para busqueda ?","Key for survey ?","mv_ch2","C",15,0,0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","N","","","",""})
	dbSelectArea("SX1")
	DbSetOrder(1)
	For ni:= 1 To Len(aRegs)
		DbSeek(aRegs[ni,1]+aRegs[ni,2])
		RecLock("SX1",!Found())
		For nj:=1 To Len(aRegs[ni])
			If ( FieldPos(aEstrSX1[nj])>0 .and. aRegs[ni,nj] # NIL )
				FieldPut(FieldPos(aEstrSX1[nj]),aRegs[ni,nj])
			EndIf
		Next nj
		dbCommit()
		MsUnLock()
	Next ni
EndIf		
dbSelectArea(_sAlias)
Return