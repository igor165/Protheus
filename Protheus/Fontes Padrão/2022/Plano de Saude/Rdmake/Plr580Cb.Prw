User Function PLR580CB

Local cBanco	:= PARAMIXB[1]
Local cAgencia	:= PARAMIXB[2]
Local cConta	:= PARAMIXB[3]
Local cDacCC	:= PARAMIXB[4]
Local cCarteira	:= PARAMIXB[5]
Local cNroDoc	:= PARAMIXB[6]
Local nValor	:= PARAMIXB[7]

Local bldocnufinal := strzero(val(cNroDoc),8)
Local blvalorfinal := strzero(int(nValor*100),14)
Local dvnn := 0
Local dvcb := 0                                         
Local dv   := 0
Local NN := ''
Local RN := ''
Local CB := ''
Local s  := ''

   s :=  cAgencia + cConta + cCarteira + bldocnufinal
   dvnn := modulo10(s)
   NN := cCarteira + '/' + bldocnufinal + '-' + AllTrim(Str(dvnn))
   s := cBanco + blvalorfinal + cCarteira + bldocnufinal + AllTrim(Str(dvnn)) + cAgencia + cConta + cDacCC + '000'
   dvcb := IIF(FindFunction("StrTPLS"),modulo11(StrTPLS(s)),modulo11(s))
   CB := SubStr(s, 1, 4) + AllTrim(Str(dvcb)) + SubStr(s, 5, 39)
   s := cBanco + cCarteira + SubStr(bldocnufinal, 1, 2) 
   dv := modulo10(s)
   RN := SubStr(s, 1, 5) + '.' + SubStr(s, 6, 4) + AllTrim(Str(dv)) + '  '
   s := SubStr(bldocnufinal, 3, 6) + AllTrim(Str(dvnn)) + SubStr(cAgencia, 1, 3)
   dv := modulo10(s)
   RN := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(Str(dv)) + '  '
   s := SubStr(cAgencia, 4, 1) + cConta + cDacCC + '000'
   dv := modulo10(s)
   RN := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(Str(dv)) + '  '
   RN := RN + AllTrim(Str(dvcb)) + '  '
   RN := RN + AllTrim(Str(Int(nValor * 100)))

Return({CB,"INT25",RN,NN})

Static Function Modulo10(cData)
Local L,D,P := 0
Local B     := .F.

   L := Len(cData)
   B := .T.
   D := 0
   While L > 0 
      P := Val(SubStr(cData, L, 1))
      If (B) 
         P := P * 2
         If P > 9 
            P := P - 9
         End
      End
      D := D + P
      L := L - 1
      B := !B
   End
   D := 10 - (Mod(D,10))
   If D = 10
      D := 0
   End
Return(D)

Static Function Modulo11(cData)
Local L, D, P := 0

   L := Len(cdata)
   D := 0
   P := 1
   While L > 0 
      P := P + 1
      D := D + (Val(SubStr(cData, L, 1)) * P)
      If P = 9 
         P := 1
      End
      L := L - 1
   End
   D := 11 - (mod(D,11))
   If (D == 10 .Or. D == 11)
      D := 1
   End
Return(D)

