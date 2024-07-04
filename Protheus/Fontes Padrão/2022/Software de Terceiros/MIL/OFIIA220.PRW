#INCLUDE "ofiia220.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIIA220 ³ Autor ³  Manoel               ³ Data ³ 01/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exportacao saldo/demanda peca p/ arquivo integracao VID    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Integracao montadora                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function OFIIA220

Private nQtdade, cCodCon, cLocPad, cAno, cMes, cMovto, nTrans, nProce
Private lSai := .t.                                          

while .t.

		if !Pergunte("GRVVID",.t.)
		   return
		Endif
		
		if Lastkey() == 27
		   return
		Endif
		
		cMarca := Mv_Par01
		cMovto := if(str(Mv_Par02,1)=="1"," ",If(str(Mv_Par02,1)=="2","E","S"))  // C 1
//-----------------------------------------------------------------------------------------------------------------------
//      esta variavel esta recebendo os valores de Saldo=1 e Demanda=99, devido o combo do sx1 so retorna 1,2,3etc.. entao foi feito esse If junto com o parametro MV_PAR03
		nTrans := If(Mv_Par03 ==1, 1 , 99 )     // N 2
//----------------------------------------------------------------------------------------------------------------------		
		nProce := Mv_Par04         // N 1
		
		if Upper(cMovto) # " " // Saldo
		   MsgInfo(STR0001,STR0002) //"Processo liberado apenas para Movimento de SALDO!"###"Atencao!"
		   lSai := .f.
		Endif
		if nTrans # 1 .and. nTrans # 99 // Saldo ou Demanda
		   MsgInfo(STR0003,STR0002) //"Processo liberado apenas para Transacoes de SALDO e DEMANDA!"###"Atencao!"
		   lSai := .f.
		Endif
		if nProce # 1 // Montadora
		   MsgInfo(STR0004,STR0002) //"Processo liberado apenas para Procedencia da Montadora!"###"Atencao!"
		   lSai := .f.
	   	Endif
		If VID->(Reccount()) > 0
		   MsgInfo(STR0005,STR0002) //"Arquivo ainda nao transmitido!"###"Atencao!"
		   lSai := .f.
		Endif
		if lSai
		   exit
		Endif
Enddo

DbselectArea("VE4")
DbSetOrder(1)
dbSeek(xFilial("VE4"))
while !eof() .and. VE4->VE4_FILIAL == xFilial("VE4")
   
      if !(VE4->VE4_PREFAB  == Mv_Par01)
         DbSkip()
         loop
      Endif
      exit
Enddo                      

DbselectArea("SBM")
DbSetOrder(1)
dbSeek(xFilial("SBM"))
cStrGruI := "" 
while !eof() .and. SBM->BM_FILIAL == xFilial("SBM")
   
      if !(SBM->BM_CODMAR  == Mv_Par01) .or. SBM->BM_PROORI # "O"
         DbSkip()
         loop
      Endif
      cStrGruI := cStrGruI + SBM->BM_GRUPO + "#"
      DbSkip()
Enddo                      

cCodCon := VE4->VE4_CODCON   
cLocPad := VE4->VE4_ALMPAD

cAno := left(dTos(dDataBase),4)
if month(dDataBase) - 1 == 0
   cMes := "12"
   cAno := str(year(dDataBase)-1,4)
Else   
   cMes := strzero(month(dDataBase)-1,2)
Endif   
Processa( {|| FS_GERAVID() }," "," ",.t. )
                                         
Return

Function FS_GERAVID()
Local i,j := 0

ProcRegua(len(cStrGruI)/4)

for j := 1 to len(cStrGruI)/4  

	IncProc(STR0006) //"Gravando arquivo de SALDO/DEMANDA..."
   cGruIte := Subs(cStrGruI,j*6-(4+j),4)
	DbSelectArea("SB1")
	DbSetOrder(7)
	DbSeek(xFilial("SB1")+cGruIte)
	While !eof() .and. xFilial("SB1") == SB1->B1_FILIAL .and. SB1->B1_GRUPO == cGruIte

	
		if nTrans == 1 // Saldo
	
	      DbSelectArea("SB2") // Saldo da Peca
		   DbSetOrder(1)
	      if DbSeek(xFilial("SB2")+SB1->B1_COD+cLocPad)
	
	         DbSelectArea("SC7") // Pedido de Compra
			   DbSetOrder(2)
			   nQtdade := 0
	   	   if DbSeek(xFilial("SC7")+SB1->B1_COD)
				   While !eof() .and. xFilial("SC7") == SC7->C7_FILIAL .and. SC7->C7_PRODUTO == SB1->B1_COD
				         nQtdade := nQtdade + SC7->C7_QUANT - SC7->C7_QUJE // a receber
				         dbskip()
				   Enddo
				Endif
	         nQtdade := nQtdade + SB2->B2_QATU
	      Else  
		      DbSelectArea("SB1")
		      DbSkip()
		      Loop
	      Endif   
	      
	   ElseIf nTrans == 99 // Demanda  
	
		   DbSelectArea("SBL") // Demanda da Peca
		   DbSetOrder(1)
		   if !(DbSeek(xFilial("SBL")+SB1->B1_COD+cAno+cMes))
		      DbSelectArea("SB1")
		      DbSkip()
		      Loop
	      Endif
	      
	   Endif
	   
		cCodite := "" 
	   for i = 1 to Len(SB1->B1_CODITE)      
	       if Subs(SB1->B1_CODITE,i,1) # "/"
	          cCodIte := cCodIte + subs(SB1->B1_CODITE,i,1)
	       Endif   
	   Next
	   if nQtdade > 0
		   DbSelectArea("VID")
		   RecLock("VID",.t.)           
		   VID_FILIAL := xFilial("VID")
		   VID_CODMAR := cMarca
		   VID_TIPREG := if(nTrans==1,"SDO","DEM")
			VID_DATPRO := dDataBase
			VID_CODCON := cCodCon
			VID_TIPMOV := cMovto
			VID_TIPTRA := nTrans
			VID_CODITE := cCodIte
			VID_PROCED := nProce            
			VID_QTDADE := if(nTrans==1,nQtdade,SBL->BL_DEMANDA )
			VID_PREPCA := SB1->B1_PRV1
			MsUnlock()
	   Endif
	
	   DbSelectArea("SB1")
	   DbSkip()
	      
	Enddo      
	
Next
	
return