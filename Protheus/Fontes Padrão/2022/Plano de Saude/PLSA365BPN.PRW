#INCLUDE "plsa365bpn.ch"

#include "PROTHEUS.CH"
#include "PLSMGER.CH"


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� As funcoes abaixo sao utilizadas no browse de Porte Anestesico de um Local de Atendimento     |
//� Sao chamadas na validacao e exclusao de uma linha do Browse oGet39                            |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPNVld  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a inclusao de uma linha no browse de Porte          낢�
굇�          � Anestesico na Operadora                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPNVld()

LOCAL lRet       := .T.

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se foi informado uma valor, e obrigatorio o codigo da Unidade de Medida |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPN_VLRPOR <> 0 .And. Empty(M->BPN_CODDOC)
   MsgInfo(STR0001) //"Informe uma Unidade de Medida de Valor para esse Porte Anestesico."
   Return(.F.)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se o nivel zero e valido                                       |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPN_VLRPOR == 0 .And. M->BPN_PERPOR == 0 .And. Empty(M->BPN_NIVVAL)
   MsgInfo(STR0002) //"Informe se o nivel zero e valido."
   Return(.F.)
Endif
          

/*
BNM->(DBSetOrder(1))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se existe alguma data de vigencia anterior a essa.             |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If BNM->(DBSeek(xFilial("BNM")+cCodigo+M->BPN_CODINT+M->BPN_CODLOC+Str(M->BPN_CODPOR,2)))
   If M->BPN_VIGDE < BNM->BNM_DATDE
      MsgInfo("A data de vigencia do Porte Anestesico e menor que a ultima data de vigencia "+dtoc(BNM->BNM_DATDE))
      Return(.F.)
   Else                  
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //� Caso a data de vigencia seja igual a data de, entao verifico o valor do Porte Anestesico|
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      If M->BPN_VIGDE == BNM->BNM_DATDE
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Se o valor do Porte Anestesico for diferente, nao consigo colocar a data final        |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         If M->BPN_VLRPOR <> BNM->BNM_VLRPOR
       	    MsgInfo("A data de vigencia do Porte Anestesico e igual a data da vigencia anterior.")
       	    Return(.F.)
         Else           
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
            //� Se o percentual do Porte Anestesico for diferente, nao consigo colocar a data final   |
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�         
            If M->BPN_PERPOR <> BNM->BNM_PERPOR
         	   MsgInfo("A data de vigencia do Porte Anestesico e igual a data da vigencia anterior.")
        	   Return(.F.)
            Else            
        	   lRet := .T.
        	Endif
         Endif
      Else
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Crio uma nova vigencia de Porte Anestesico                        |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         nPosScan := aScan(aVetBNM,{|x| x[2] == M->BPN_CODINT .And. x[3] == M->BPN_CODLOC .And. x[4] == M->BPN_CODPOR })
         If nPosScan == 0
            aadd(aVetBNM,{cCodigo,M->BPN_CODINT,M->BPN_CODLOC,M->BPN_CODPOR,M->BPN_SEQPOR,M->BPN_VLRPOR,M->BPN_VIGPOR,M->BPN_CODDOC,M->BPN_PERPOR,M->BPN_NIVVAL,M->BPN_VIGDE,ctod("")})
         Else
            aVetBNM[nPosScan,5]  := M->BPN_SEQPOR
            aVetBNM[nPosScan,6]  := M->BPN_VLRPOR
            aVetBNM[nPosScan,7]  := M->BPN_VIGPOR
            aVetBNM[nPosScan,8]  := M->BPN_CODDOC
            aVetBNM[nPosScan,9]  := M->BPN_PERPOR
            aVetBNM[nPosScan,10] := M->BPN_NIVVAL
            aVetBNM[nPosScan,10] := M->BPN_VIGDE
         Endif
            
         lRet := .T.
      Endif
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Crio uma nova vigencia de Porte Anestesico                        |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNM,{|x| x[2] == M->BPN_CODINT .And. x[3] == M->BPN_CODLOC .And. x[4] == M->BPN_CODPOR })
   If nPosScan == 0
      aadd(aVetBNM,{cCodigo,M->BPN_CODINT,M->BPN_CODLOC,M->BPN_CODPOR,M->BPN_SEQPOR,M->BPN_VLRPOR,M->BPN_VIGPOR,M->BPN_CODDOC,M->BPN_PERPOR,M->BPN_NIVVAL,M->BPN_VIGDE,ctod("")})
   Else
      aVetBNM[nPosScan,5]  := M->BPN_SEQPOR
      aVetBNM[nPosScan,6]  := M->BPN_VLRPOR
      aVetBNM[nPosScan,7]  := M->BPN_VIGPOR
      aVetBNM[nPosScan,8]  := M->BPN_CODDOC
      aVetBNM[nPosScan,9]  := M->BPN_PERPOR
      aVetBNM[nPosScan,10] := M->BPN_NIVVAL
      aVetBNM[nPosScan,10] := M->BPN_VIGDE
   Endif
                     
   lRet := .T.
Endif
*/
Return(lRet)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPNDel  � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a exclusao de uma linha no browse de Porte          낢�
굇�          � Anestesico na Operadora                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPNDel()

/*
If M->BPN_FLAG == "1"
   lRet := .F.
Endif

nPosScan := aScan(aVetBNM,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
            x[4] == oGet32:aCols[oGet32:Linha(),oGet32:PlRetPos("BPN_CODPOR")]})
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se for exclusao da linha, tiro o dado do vetor                    |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�      
If oGet32:aCols[oGet32:Linha(),Len(oGet32:aHeader)+1]
   If nPosScan <> 0
      aadd(aVetDelBNM,aVetBNM[nPosScan])
      nTamCols   := Len(aVetBNM)
      aDel(aVetBNM,nPosScan)
      aSize(aVetBNM,nTamCols-1)
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Se for retirar a exclusao, tenho que verificar se os dados daquele linha estavam no vetor   |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNM,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
                x[4] == oGet32:aCols[oGet32:Linha(),oGet32:PlRetPos("BPN_CODPOR")]})
                
   If nPosScan <> 0
      aadd(aVetBNM,{cCodigo,cCodInt,cCodLoc,oGet32:aCols[oGet32:Linha(),oGet32:PlRetPos("BPN_CODPOR")],;
                     oGet32:aCols[oGet32:Linha(),oGet32:PlRetPos("BPN_SEQPOR")],;
                     oGet32:aCols[oGet32:Linha(),oGet32:PlRetPos("BPN_VLRPOR")],;
                     oGet32:aCols[oGet32:Linha(),oGet32:PlRetPos("BPN_VIGPOR")],;
                     oGet32:aCols[oGet32:Linha(),oGet32:PlRetPos("BPN_CODDOC")],;
                     oGet32:aCols[oGet32:Linha(),oGet32:PlRetPos("BPN_PERPOR")],;
                     oGet32:aCols[oGet32:Linha(),oGet32:PlRetPos("BPN_NIVVAL")],;
                     oGet32:aCols[oGet32:Linha(),oGet32:PlRetPos("BPN_VIGDE")],;
                     ctod("")})
                                                    
      nTamCols   := Len(aVetDelBNM)
      aDel(aVetDelBNM,nPosScan)
      aSize(aVetDelBNM,nTamCols-1)
   Endif
Endif
*/

Return(.T.)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPNWhen � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida o X3_WHEN para os campos do BPN.                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPNWhen(cTipo)

LOCAL lRet    := .T.
DEFAULT cTipo := ""
/*
If M->BPN_FLAG == "1" .And. Empty(cTipo)
   lRet := .F.
Endif
*/
If lRet .And. cTipo == "V" .And. !Empty(M->BPN_PERPOR)
   lRet := .F.
Endif

If lRet .And. cTipo == "P" .And. !Empty(M->BPN_VLRPOR)
   lRet := .F.
Endif

If lRet .And. cTipo == "N" .And. (!Empty(M->BPN_PERPOR) .Or. !Empty(M->BPN_VLRPOR))
   lRet := .F.
Endif

Return(lRet)

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPNRet  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Retorna a data da vigencia em aberto da Porte Anestesico   낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� cCampo - Campo que vai ser retornado                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPNRet(cCampo)
    
LOCAL cConteu
LOCAL lRet    := .F.

If ValType(&(cCampo)) == "D"
   cConteu := ctod("")
Else
   If ValType(&(cCampo)) == "C"
      cConteu := ""
   Else
      If ValType(&(cCampo)) == "N"
         cConteu := 0
      Endif
   Endif
Endif
      
BKF->(DBSetOrder(1))
If BKF->(DBSeek(xFilial("BKF")+M->BPN_CODINT+Str(M->BPN_CODPOR,2)))
   While !BKF->(EOF()) .And. xFilial("BKF")+M->BPN_CODINT+Str(M->BPN_CODPOR,2) == BKF->(BKF_FILIAL+BKF_CODINT+Str(BKF_PORTE,2)) .And.;
         !lRet
         If Empty(BKF->BKF_VIGATE)
            cConteu := &(cCampo)
            lRet    := .T.
         Endif
   BKF->(DBSkip())
   Enddo
Endif

Return(cConteu)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSPOSBNM  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Verifica se ja existe vigencia para esse registro e se     낢�
굇�          � essa esta e menor que a que esta sendo digitada            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSPOSBNM()

LOCAL lRet := .T.

BNM->(DBSetOrder(2))
BNM->(DBSeek(xFilial("BNM")+cCodigo+cCodInt+cCodLoc+Str(M->BPN_CODPOR,2)))
If M->BPN_VIGDE < BNM->BNM_DATDE
   MsgInfo(STR0003+dtoc(BNM->BNM_DATDE)+STR0004) //"A data de vigencia do Porte Anestesico e menor que a data inicial("###") da vigencia anterior."
   lRet := .F.
Endif


Return(lRet)
