#Include "VEICR600.CH"
#Include "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICR600 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 21/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Etiquetas para Clientes "VEI" e A PRAZO                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VEICR600()

Private aReturn:= {STR0002,1,STR0003,2,2,1, ,1}  
Private cAlias  := "SF2"
Private cNomRel := "VEICR600"
Private cPerg   := "VCR600"
Private cTitulo := STR0001
Private cDesc1  := STR0001
Private cDesc2  := ""
Private cDesc3  := ""
Private cTamanho:= "M"
Private cLimite := 132      
cNomRel := SetPrint(cAlias,cNomRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,,cTamanho)
If nlastkey == 27
   Return
EndIf
PERGUNTE(cPerg,.F.)
RptStatus({|lEnd| FS_VEICR600()},cTitulo)

Return

Static Function FS_VEICR600()
Local ni := 0
Local aClientes := {}
Local cImp_Etq := GetMv("MV_IMP_ETQ",,"MATRICIAL")
Local nIni     := If(cImp_Etq=="LASER",6,0)
Local nLin     := If(cImp_Etq=="LASER",1,0)
Local nCont    := 0
Local cNomes   := ""
Local cEnds    := ""
Local cCeps    := ""
Local cBairros := ""
Local nColunas := MV_PAR04
Local nLarg    := MV_PAR05
Local lA1_IBGE := If(SA1->(FieldPos("A1_IBGE"))#0,.t.,.f.)

Set Console On
Set Printer to &cNomRel
Set Printer On
Set device to Printer
SetDefault(aReturn,cAlias)

DbSelectArea("SD2")
DbSetOrder(5)
DbSeek( xFilial("SD2") + DTOS(MV_PAR01) , .t. )
DbSelectArea("SF2")
DbSetOrder(1)
DbSeek( xFilial("SF2") + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA )
If SF2->F2_EMISSAO > MV_PAR02
	Return
EndIf
SetRegua(RecCount())
While !Eof() .and. xFilial("SF2")==SF2->F2_FILIAL .and. ( SF2->F2_EMISSAO >= MV_PAR01 ) .and. ( SF2->F2_EMISSAO <= MV_PAR02 )
   IncRegua()
	If SF2->F2_PREFORI # GetNewPar("MV_PREFVEI","VEI")
		DbSelectArea("SF2")
  	   DbSkip()
     	Loop
	EndIf
	DbSelectArea("SE4")
	DbSetOrder(1)
	DbSeek( xFilial("SE4") + SF2->F2_COND )
   If Alltrim(SE4->E4_COND) == "0"
		DbSelectArea("SF2")
  	   DbSkip()
     	Loop
   EndIf
	DbSelectArea("VV0")
	DbSetOrder(4)
	DbSeek( xFilial("VV0") + SF2->F2_DOC + SF2->F2_SERIE )
	If !Empty(MV_PAR03) .and. VV0->VV0_TIPVEN # MV_PAR03
		DbSelectArea("SF2")
  	   DbSkip()
     	Loop
	EndIf
	nPos := aScan(aClientes,{|x| x[6] == SF2->F2_CLIENTE + SF2->F2_LOJA })
	If nPos == 0
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA )
		If lA1_IBGE
			DbSelectArea("VAM") 
			DbSetOrder(1)
			DbSeek( xFilial("VAM") + SA1->A1_IBGE )
			Aadd(aClientes,{ SA1->A1_NOME , Alltrim(SA1->A1_END)+", "+SA1->A1_NUMERO , SA1->A1_BAIRRO , Transform(SA1->A1_CEP,"@R 99999-999") , Alltrim(VAM->VAM_DESCID)+"-"+VAM->VAM_ESTADO , SF2->F2_CLIENTE + SF2->F2_LOJA } )
		Else
			Aadd(aClientes,{ SA1->A1_NOME , Alltrim(SA1->A1_END)+", "+SA1->A1_NUMERO , SA1->A1_BAIRRO , Transform(SA1->A1_CEP,"@R 99999-999") , Alltrim(SA1->A1_MUN)+"-"+SA1->A1_EST , SF2->F2_CLIENTE + SF2->F2_LOJA } )
		EndIf
	EndIf
	DbSelectArea("SF2")
	DbSkip()
EndDo                       
If MV_PAR06 == 1 // Nome do Cliente
	aSort(aClientes,1,,{|x,y| x[1] < y[1] })
ElseIf MV_PAR06 == 2 // Cidade + Bairro + Endereco
	aSort(aClientes,1,,{|x,y| x[5]+x[3]+x[2] < y[5]+y[3]+y[2] })
ElseIf MV_PAR06 == 3 // CEP
	aSort(aClientes,1,,{|x,y| x[4] < y[4] })
EndIf
For ni:=1 to Len(aClientes)
   If !(nColunas > 0 )
		If cImp_Etq == "LASER"
	      nLin++ 
	 	EndIf
      nLin++ 
      @ nLin++,nIni PSAY cNomes
	   @ nLin++,nIni PSAY cEnds
  		@ nLin++,nIni PSAY cBairros
      @ nLin++,nIni PSAY cCeps
	   nLin++
		If cImp_Etq == "LASER" .and. nCont # 5
			nLin++
		EndIf
   	nColunas := MV_PAR04 
  	   cNomes := cEnds := cBairros := cCeps := ""
		If cImp_Etq == "LASER"
			nCont++
			If nCont == 10
				nCont := 0
				nLin := 1
			EndIf
		EndIf
   EndIf
   nColunas--
   cNomes   += left( Alltrim(aClientes[ni,1]) + space(nLarg) , nLarg-1 ) + " "
   cEnds    += left( aClientes[ni,2] + space(nLarg) , nLarg-1 ) + " " 
  	cBairros += left( aClientes[ni,3] + space(nLarg) , nLarg-1 ) + " " 
   cCeps    += left( aClientes[ni,4] + " " + aClientes[ni,5] + space(nLarg) , nLarg-1 ) + " " 
Next
If len(cNomes) > 0 
	If cImp_Etq == "LASER"
	   nLin++ 
	EndIf
	nLin++
   @ nLin++,nIni PSAY cNomes
   @ nLin++,nIni PSAY cEnds
   @ nLin++,nIni PSAY cBairros
   @ nLin++,nIni PSAY cCeps
EndIf                    

Eject        
Set Printer to
Set device to Screen 
IF aReturn[5] == 1 
   ourspool(cNomRel)
Endif
MS_FLUSH()

Return
