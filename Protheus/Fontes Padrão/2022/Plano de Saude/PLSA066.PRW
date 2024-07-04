
Function PLSA066                                   
LOCAL cMatric
Local lCent := __SetCentury() // Salva formato ano/data 2 ou 4 digitos
Local aRet
Local lStrTPLS := FindFunction("StrTPLS")

If ! Pergunte("PLS066",.T.)
   Return
Endif   

cMatric := alltrim(mv_par01)

If     Len(cMatric) == 16

   If !lStrTPLS

        If Modulo11(Subs(cMatric,1,15)) <> Subs(cMatric,16,1)        
          MsgStop("Digito invalido")
          Return
       Endif

   Else

       If Modulo11(StrTPLS(Subs(cMatric,1,15))) <> Subs(cMatric,16,1)        
          MsgStop("Digito invalido")
          Return
       Endif

   EndIf

ElseIf Len(cMatric) == 17

   If !lStrTPLS

        If Modulo11(Subs(cMatric,1,16)) <> Subs(cMatric,17,1)
          MsgStop("Digito invalido")
          Return
       Endif

   Else

       If Modulo11(StrTPLS(Subs(cMatric,1,16))) <> Subs(cMatric,17,1)
          MsgStop("Digito invalido")
          Return
       Endif
   EndIf
      
Else
       MsgStop("Matricula Invalida")
       Return
Endif

BA1->(DbSetOrder(2))
If BA1->(DbSeek(xFilial("BA1")+cMatric))
   MsgInfo("Matricula "+cMatric+" ja cadastrada para o usuario "+BA1->BA1_NOMUSR)
   Return
Endif   

BA1->(DbSetOrder(5))
If BA1->(DbSeek(xFilial("BA1")+cMatric))
   MsgInfo("Matricula "+cMatric+" ja cadastrada para o usuario "+BA1->BA1_NOMUSR)
   Return
Endif   

__SetCentury( "on" )   // habilita ano para 4 digitos
aRet := PLSA235(.F.,cMatric)
__SetCentury(If(lCent,"on","off")) // Retorna formato ano salvo anteriormente 2 ou 4 digitos
        
If aRet[1]
	MsgInfo("Inclusao feita com sucesso!!")
EndIf

Return

