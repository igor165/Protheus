/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M460IE    ³ Autor ³ Fernando Machima       ³ Data ³ 02.11.00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Programa que calcula Imposto especifico de combustivel(CHILE) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA467                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M460IE()

LOCAL nValIE := 0
LOCAL cAliasRot, cOrdemRot
Local nCols := 0
Local nPosQt, nPosCod, nPosLote, nPosSbLote, nPosLoc
Local nQuant, cCodPr, cCodLote, cCodSbLote, cLocal
Local cSeekB8

SetPrvt("AITEMINFO,AIMPOSTO")

cAliasRot:= Alias()
cOrdemRot:= IndexOrd()

aItemINFO   := ParamIxb[1]
aImposto    := aClone(ParamIxb[2])
nCols       := ParamIxb[3]

dbSelectArea("SB8")     
dbSetorder(3)
If cModulo $ "LOJA|FRT"
   If (Upper(FunName())<>"MATA468N")    
      nPosQt     := Ascan(aHeader,{|x|trim(x[2])=="D2_QUANT"})
      nQuant     := aCols[nCols][nPosQt]
      nPosCod    := Ascan(aHeader,{|x|Trim(x[2])=="D2_COD"})
      cCodPr     := aCols[nCols][nPosCod]
      nPosLote   := Ascan(aHeader,{|x|Trim(x[2])=="D2_LOTECTL"})
      cCodLote   := aCols[nCols][nPosLote]
      nPosSbLote := Ascan(aHeader,{|x|Trim(x[2])=="D2_NUMLOTE"})
      cCodSbLote := aCols[nCols][nPosSbLote]
      nPosLoc    := Ascan(aHeader,{|x|Trim(x[2])=="D2_LOCAL"})
      cLocal     := aCols[nCols][nPosLoc]    
  Else
     If lPedidos
         cCodPr   := SC6->C6_PRODUTO
         cLocal   := SC6->C6_LOCAL     
         nQuant   := SC6->C6_QTDVEN   
     Else
     	 // Modificado para pegar direto do Arquivo temporario - Sergio Camurca
         cCodPr   := SCN->CN_PRODUTO
	     If SCN->CN_TIPOREM $ "1"
	        cLocal  := SCN->CN_LOCDEST
	     Else   
	        cLocal  := SCN->CN_LOCAL
	     EndIf             
         nQuant   := SCN->CN_QUANT   	     
     EndIf   
     cCodLote   := SC9->C9_LOTECTL
     cCodSbLote := SC9->C9_NUMLOTE            
  EndIf
EndIf      
    
If !Empty(cCodSbLote)
   cSeekB8 := xFilial("SB8")+cCodPr+cLocal+cCodLote+cCodSbLote
Else
   cSeekB8 := xFilial("SB8")+cCodPr+cLocal+cCodLote
EndIf   
If DbSeek(cSeekB8)
   nValIE := SB8->B8_IE
EndIf

aImposto[03] := aItemINFO[3]  //Base de Calculo
aImposto[4] := nValIE*nQuant

dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return( aImposto )


