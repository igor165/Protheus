#Include "OFIOR640.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOR640 ³ Autor ³  Thiago        ³ Data ³ 06/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Mapa de Faturamento                                 |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR640()
Private cAlias   := "SE1"
Private cTitulo  := STR0001 //Mapa Faturamento"
Private cDesc1   := cTitulo
Private cDesc2   := ""
Private cDesc3   := ""
Private cCabec1  := STR0002 //Tp  Numero Parc NosNum   Cliente                            CNPJ / CPF     Valor do Titulo  DtVencto  Portador/Agencia"
Private cCabec2  := ""
Private aReturn  := {STR0003,1,STR0004,1,2,1,"",1} //Zebrado # Administracao
Private cTamanho := "M"           // P/M/G
Private Limite   := 132           // 80/132/220
Private cNomProg := "OFIOR640"
Private nLastKey := 0
Private nCaracter:= 15
Private cPerg    := "OFR640"
set printer to &cNomProg
set printer on
set device to printer
cNomProg := SetPrint(cAlias,cNomProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nlastkey == 27
	return
EndIf
Pergunte(cPerg,.f.)
SetDefault(aReturn,cAlias)
RptStatus({|lEnd| FS_OFR640(@lEnd,cNomProg,cAlias)},cTitulo)
Set Printer to
Set device to Screen
MS_FLUSH()
If aReturn[5] == 1
   OurSpool(cNomProg)
EndIf
Return

Static Function FS_OFR640(lEnd,wNRel,cAlias)
Local lOk := .t.
Local lA1_IBGE := If(SA1->(FieldPos("A1_IBGE"))#0,.t.,.f.)
Local cNomAge := ""
Local cSeek   := ""
Local ni      := 0
Local nTotal  := 0
Local nNumTit := 0
Local cNosNum := space(8)
M_PAG := 1
nLin  := 1
aPag  := 1                                                                                      
cTitulo += " " + STR0005 + ": "+Transform(MV_PAR01,"@D")+" a "+Transform(MV_PAR02,"@D") //Emissao
cTitulo += " " + STR0006 + ": "+Transform(MV_PAR03,"@D")+" a "+Transform(MV_PAR04,"@D")   //Baixa
cTitulo += " " + STR0007 + ": "
If MV_PAR05 == 4			// Todos
   cTitulo += STR0008  		// Todos
Else
	If MV_PAR05 == 1		// Balcao de Pecas
   	cTitulo += STR0009     	// Balcao
	ElseIf MV_PAR05 == 2	// Oficina (Pecas/Servicos)
	   cTitulo += STR0010 	// Oficina 
	ElseIf MV_PAR05 == 3	// Veiculos
	   cTitulo += STR0011 	// Veiculo
	EndIf
EndIf
nLin := Cabec(cTitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter)+1
dbSelectArea("SE1")
dbSetOrder(6)
dbSeek( xFilial("SE1") + dtos(MV_PAR01) , .t. )
SetRegua((RecCount()/100))
While !Eof() .and. xFilial("SE1") == SE1->E1_FILIAL .and. ( SE1->E1_EMISSAO <= MV_PAR02 )
	ni++
	If ni == 100
		ni := 0
		IncRegua()
	EndIf
	If !( MV_PAR03 <= SE1->E1_BAIXA .and. SE1->E1_BAIXA <= MV_PAR04 )
		DbSelectArea("SE1")
		DbSkip()
      Loop
	EndIf
   lOk := .t.
   If MV_PAR05 == 4 // Todos
  	   If !(SE1->E1_PREFORI $ GetNewPar("MV_PREFOFI","OFI")+"/"+GetNewPar("MV_PREFBAL","BAL")+"/"+GetNewPar("MV_PREFVEI","VEI"))
			lOk := .f.
  	   EndIf
   Else
	   If MV_PAR05 == 1 .and. ( SE1->E1_PREFORI # GetNewPar("MV_PREFBAL","BAL") ) 		// Balcao
			lOk := .f.
	   ElseIf MV_PAR05 == 2 .and. ( SE1->E1_PREFORI # GetNewPar("MV_PREFOFI","OFI") ) 	// Oficina
			lOk := .f.
	   ElseIf MV_PAR05 == 3 .and. ( SE1->E1_PREFORI # GetNewPar("MV_PREFVEI","VEI") ) 	// Veiculos
			lOk := .f.
	   EndIf
   EndIf
	If !lOk
		DbSelectArea("SE1")
		DbSkip()
      Loop
	EndIf
	If cSeek # ( SE1->E1_CLIENTE + SE1->E1_LOJA )
		cSeek := ( SE1->E1_CLIENTE + SE1->E1_LOJA )
	   DbSelectArea("SA1")
	  	DbSetOrder(1)
	   DbSeek( xFilial("SA1") + cSeek )
		If lA1_IBGE
			cNomAge := ""
		   DbSelectArea("VAM")
	   	DbSetOrder(1)
		   DbSeek( xFilial("VAM") + SA1->A1_IBGE )
		   cNomAge := left(VAM->VAM_AGDEP,15)
	   EndIf
	EndIf
	cNosNum := space(8)
	DbSelectArea("VO3")
	DbSetOrder(5)
	If DbSeek( xFilial("VO3") + SE1->E1_NUMNOTA + SE1->E1_SERIE )
	   cNosNum := VO3->VO3_NOSNUM
	Else
		DbSelectArea("VO4")
		DbSetOrder(7)
	   If DbSeek( xFilial("VO4") + SE1->E1_NUMNOTA + SE1->E1_SERIE )
		  	cNosNum := VO4->VO4_NOSNUM
		EndIf
	EndIf
	If nLin >= 58
		nLin := 1
		nLin := Cabec(cTitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter)+1
	EndIf
	@ nLin++, 000 pSay SE1->E1_TIPO+" "+SE1->E1_NUM+" "+left(SE1->E1_PARCELA+space(2),2)+cNosNum+" "+substr(SA1->A1_NOME,1,34)+" "+;
						left(Transform(SA1->A1_CGC,If(len(Alltrim(SA1->A1_CGC))>12,"@R 99.999.999/9999-99","@R 999.999.999-99"))+space(18),18)+;
						transform(SE1->E1_VALOR,"@E 9,999,999.99")+"  "+transform(SE1->E1_VENCTO,"@D")+"  "+SE1->E1_PORTADO+"  "+cNomAge
	nTotal += SE1->E1_VALOR
	nNumTit++
	DbSelectArea("SE1")
	DbSkip()
EndDo
nLin++                              
@ nLin++, 001 pSay space(62)+ STR0012 +" :"+transform(nTotal,"@E 999,999,999.99")+" ("+transform(nNumTit,"@E 99999")+" "+ STR0013 +" )"  //T O T A I S # Titulos
Return