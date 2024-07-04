// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 11     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "OFIPR090.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OFIPR090 º Autor ³ Andre Luis Almeida º Data ³  27/05/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do Valor/Qtde   ABC CUSTO ESTOQUE                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MIL                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIPR090

Private cPerg        := "OFP090"
OFR090R3() // Executa versão anterior do fonte

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFR090R3  ºAutor  ³Fabio               º Data ³  06/20/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OFR090R3()

cDesc1    := STR0001
cDesc2    := ""
cDesc3    := ""
cAlias    := "SB2"
aRegistros:= {}
nLin      := 0
aPag      := 1
nIte      := 1
aReturn   := { OemToAnsi(STR0002), 1,OemToAnsi(STR0003), 2, 2, 1, "",1 }
cTamanho  := "M"           	// P/M/G
Limite    := 132           	// 80/132/220
aOrdem    := {}           	// Ordem do Relatorio
cTitulo   := STR0004
cNomeProg := "OFIPR090"
cNomeRel  := "OFIPR090"
nLastKey  := 0
nCaracter := 15
cabec1    := ""
cabec2    := ""
cPerg     := "OFP090"   

ValidPerg()

cNomeRel:=SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,,cTamanho)
If nLastKey == 27
   Return
EndIf     
PERGUNTE("OFP090",.f.)
                        
SetDefault(aReturn,cAlias)
RptStatus( { |lEnd| OFIR090IMP(@lEnd,cNomeRel,cAlias) } , cTitulo )

If aReturn[5] == 1
   OurSpool( cNomeRel )
EndIf

MS_Flush()
Return
           
Static Function OFIR090IMP(lEnd,wNRel,cAlias)
                  
Private cbTxt    := Space(10)
Private cbCont   := 0
Private cString  := "SB2"
Private Li       := 132
Private m_Pag    := 1
Private aAlmox   := {}
Private aTotal   := {}
Private aVetCampos:={}

	Set Printer to &cNomeRel
	Set Printer On
	Set Device  to Printer

	If !Empty(MV_PAR01)
		cTitulo += STR0005 + Alltrim(MV_PAR01)
	Else
		cTitulo += STR0005 + "00 a 99"
	EndIf 

nTamVal := 14
nTamQTD := 14
cabecT := STR0006
DbSelectArea("SX3")
DbSetOrder(2)
If DbSeek("B2_VATU1")
   nTamVal := SX3->X3_TAMANHO
EndIf	
DbSelectArea("SX3")
DbSetOrder(2)
If DbSeek("B2_QATU")
   nTamQTD := SX3->X3_TAMANHO
EndIf	

///////////////////////////////////////////////////////////////////////////
//         C r i a     A r q u i v o    d e    T r a b a l h o           //
///////////////////////////////////////////////////////////////////////////
 aadd(aVetCampos,{ "TRB_GRUPO"  , "C" , 4 , 0 })  //  Grupo da Peca      //
 aadd(aVetCampos,{ "TRB_CODITE" , "C" ,27 , 0 })  //  Codigo da Peca     //
 aadd(aVetCampos,{ "TRB_DESC"   , "C" ,30 , 0 })  //  Descricao Peca     //
 aadd(aVetCampos,{ "TRB_VALORT" , "N" ,nTamVal , 2 })  //  Valor SB2 TOTAL    //
 aadd(aVetCampos,{ "TRB_QTDET"  , "N" ,nTamQTD , 0 })  //  Qtde SB2 TOTAL     //
 aadd(aVetCampos,{ "TRB_VALOR1" , "N" ,nTamVal , 2 })  //  Valor SB2 LOC<=50  //
 aadd(aVetCampos,{ "TRB_QTDE1"  , "N" ,nTamQTD , 0 })  //  Qtde SB2 LOC<=50   //
 aadd(aVetCampos,{ "TRB_VALOR2" , "N" ,nTamVal , 2 })  //  Valor SB2 LOC>50   //
 aadd(aVetCampos,{ "TRB_QTDE2"  , "N" ,nTamQTD , 0 })  //  Qtde SB2 LOC>50    //
///////////////////////////////////////////////////////////////////////////
      
oObjTempTable := OFDMSTempTable():New()
oObjTempTable:cAlias := "TRB"
oObjTempTable:aVetCampos := aVetCampos
oObjTempTable:AddIndex(, {"TRB_VALORT"} )
oObjTempTable:CreateTable()

DbSelectArea("SB2")
DbSetOrder(1)
DbSeek( xFilial("SB2") )    
SetRegua(RecCount())

cCod  := SB2->B2_COD

nVT:= 0
nV1:= 0
nV2:= 0

nValorT:= 0
nQtdeT := 0

nValor1:= 0
nQtde1 := 0

nValor2:= 0
nQtde2 := 0

Do While !Eof() .And. SB2->B2_FILIAL == xFilial("SB2")

	IncRegua()   
	
	If SB2->B2_LOCAL > "99" .or.  SB2->B2_LOCAL < "00"
		DbSelectArea("SB2")
		DbSkip()
		Loop
	EndIf
	If !Empty(MV_PAR01)
		If !(SB2->B2_LOCAL $ MV_PAR01 )
			DbSelectArea("SB2")
			DbSkip()
			Loop
		EndIf
	EndIf
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek( xFilial("SB1") + SB2->B2_COD )
    if !Empty(MV_PAR02+MV_PAR03)
       if SB1->B1_TIPO < MV_PAR02 .or. SB1->B1_TIPO > MV_PAR03
		  DbSelectArea("SB2")
		  DbSkip()
		  Loop
       Endif
    Endif
    if !Empty(MV_PAR04+MV_PAR05)
       if SB1->B1_GRUPO < MV_PAR04 .or. SB1->B1_GRUPO > MV_PAR05
		  DbSelectArea("SB2")
		  DbSkip()
		  Loop
       Endif
    Endif
    if !Empty(MV_PAR06+MV_PAR07)
       if SB1->B1_CODITE < MV_PAR06 .or. SB1->B1_CODITE > MV_PAR07
		  DbSelectArea("SB2")
		  DbSkip()
		  Loop
       Endif
    Endif
    
	If cCod # SB2->B2_COD
		If nValorT > 0
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek( xFilial("SB1") + cCod )
			DbSelectArea("TRB")
			RecLock("TRB",.t.)
			   TRB->TRB_GRUPO  := SB1->B1_GRUPO 
			  	TRB->TRB_CODITE := SB1->B1_CODITE 
			   TRB->TRB_DESC   := SB1->B1_DESC
			   TRB->TRB_VALORT := ( nValorT * (-1) )
			   TRB->TRB_QTDET  := nQtdeT
			   TRB->TRB_VALOR1 := nValor1
			   TRB->TRB_QTDE1  := nQtde1
			   TRB->TRB_VALOR2 := nValor2
			   TRB->TRB_QTDE2  := nQtde2
			MsUnlock()
      EndIf
		nValorT:= 0
		nQtdeT := 0
		nValor1:= 0
		nQtde1 := 0
		nValor2:= 0
		nQtde2 := 0
		cCod := SB2->B2_COD
	EndIf

	nVT += SB2->B2_VATU1
	nValorT+= SB2->B2_VATU1
	nQtdeT += SB2->B2_QATU
   If SB2->B2_LOCAL <= "50"
		nV1 += SB2->B2_VATU1
		nValor1+= SB2->B2_VATU1
		nQtde1 += SB2->B2_QATU
	Else
		nV2 += SB2->B2_VATU1
		nValor2+= SB2->B2_VATU1
		nQtde2 += SB2->B2_QATU   
  	EndIf
   
   DbSelectArea("SB2")  
   DbSkip()
Enddo

/////////////////////////////////////
//  U L T I M A   P E C A   S B 2  //
/////////////////////////////////////
DbSelectArea("SB1")
DbSetOrder(1)
DbSeek( xFilial("SB1") + cCod )

DbSelectArea("TRB")
RecLock("TRB",.t.)
   TRB->TRB_GRUPO  := SB1->B1_GRUPO 
   TRB->TRB_CODITE := SB1->B1_CODITE
   TRB->TRB_DESC   := SB1->B1_DESC
   TRB->TRB_VALORT := ( nValorT * (-1) )
   TRB->TRB_QTDET  := nQtdeT
   TRB->TRB_VALOR1 := nValor1
   TRB->TRB_QTDE1  := nQtde1
   TRB->TRB_VALOR2 := nValor2
   TRB->TRB_QTDE2  := nQtde2
MsUnlock()
/////////////////////////////////////

nAcumulado := 0


nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1      
	
@ nLin++ , 13 psay STR0008
@ nLin++ , 13 psay STR0009 + Transform(nVT,"@E 999,999,999.99") + space(6) ;
							+ Transform(nV1,"@E 999,999,999.99") + space(6) ;
							+ Transform(nV2,"@E 999,999,999.99") 

If ( ( nVT + nV1 + nV2 ) > 0 )

	nLin++
	nLin++
	@ nLin++ , 00 psay cabecT
	nLin++
	
	DbSelectArea("TRB")
	DbGoTop()
	Do While !Eof()

	   If nLin >= 60
			nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1      
			@ nLin++ , 00 psay cabecT
			nLin++
	   EndIf
	   nAcumulado += ( TRB->TRB_VALORT * (-1) )
	 	@ nLin++ , 00 psay TRB->TRB_GRUPO + " " + TRB->TRB_CODITE + " " + left(TRB->TRB_DESC,30) ;
						+ Transform(( TRB->TRB_VALORT * (-1) ),"@E 999999,999.99") + Transform(TRB->TRB_QTDET,"@E 999,999") ;
						+ Transform(TRB->TRB_VALOR1,"@E 999999,999.99") + Transform(TRB->TRB_QTDE1,"@E 999,999") ;
		   				+ Transform(TRB->TRB_VALOR2,"@E 999999,999.99") + Transform(TRB->TRB_QTDE2,"@E 999,999") ;
		   				+ "  " + Transform(If(((nAcumulado/nVT)*100)>100,100,((nAcumulado/nVT)*100)),"@E 999.99") + "%"

      DbSelectArea("TRB")
      DbSkip()
   EndDo
EndIf

DbSelectArea("TRB")
oObjTempTable:CloseTable()

Set Printer to
Set Device  to Screen

Return

Static Function ValidPerg     

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
if dbSeek("OFP090    01")
   if !Empty(SX1->X1_VALID)
      RecLock("SX1",.f.)
      SX1->X1_VALID := ""
      MsUnlock()         
   Endif
Endif            

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg, Len(SX1->X1_GRUPO) )

aAdd(aRegs,{cPerg,"02","Tipo De      ","","","mv_ch2","C", 02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","02",""})
aAdd(aRegs,{cPerg,"03","Tipo Ate     ","","","mv_ch3","C", 02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","02",""})
Aadd(aRegs,{cPerg,"04","Grupo De     ","","","mv_ch4","C", 04,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SBM",""})
Aadd(aRegs,{cPerg,"05","Grupo Ate    ","","","mv_ch5","C", 04,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SBM",""})
Aadd(aRegs,{cPerg,"06","Cod Item De  ","","","mv_ch4","C", 27,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
Aadd(aRegs,{cPerg,"07","Cod Item Ate ","","","mv_ch5","C", 27,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return


