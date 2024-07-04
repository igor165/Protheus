/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M100FEPP  ³ Autor ³ Fernando Machima       ³ Data ³ 02.11.00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Programa que calcula FEPP  (CHILE)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA101                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100FEPP()

LOCAL _cAlias 
LOCAL _nOrd     
LOCAL cCpoDecs
LOCAL nDecs := 0
LOCAL nCols := 0
LOCAL nPosFEPP := 0

SetPrvt("AITEMINFO,AIMPOSTO")

_cAlias := Alias()
_nOrd   := IndexOrd()

aItemINFO   := ParamIxb[1]
aImposto    := aClone(ParamIxb[2])
nCols       := ParamIxb[3]

aImposto[02] := SFB->FB_ALIQ	// Aliquota
aImposto[03] := aItemINFO[3]  //Base de Calculo
            
cCpoDecs := "F1_VALIMP"+SFB->FB_CPOLVRO
dbSelectArea("SX3")
dbSetOrder(2)
If dbSeek(cCpoDecs)
   nDecs := SX3->X3_DECIMAL
Else
   nDecs := 2
EndIf   

nPosFEPP:= Ascan(aHeader,{|x|Trim(x[2])=="D1_FEPP"})
If nPosFEPP > 0    
   aImposto[4]:= Round(aCols[nCols][nPosFEPP] * aItemInfo[1],nDecs)   //Calculo do imposto
EndIf  

DbSelectArea(_cAlias)
DbSetOrder(_nOrd)

Return( aImposto )

