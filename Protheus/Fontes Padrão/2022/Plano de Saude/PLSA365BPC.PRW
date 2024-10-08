
#include "PROTHEUS.CH"
#include "PLSMGER.CH"


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� As funcoes abaixo sao utilizadas no browse de Auxiliar de uma operadora.|
//� Sao chamadas na validacao e exclusao de uma linha do Browse oGet29      |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPCVld  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a inclusao de uma linha no browse de Auxiliar da    낢�
굇�          � Operadora                                                  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPCVld()

LOCAL lRet       := .T.
LOCAL lRetBPC    := .T.
LOCAL nPosScan   := 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se o nivel zero e valido                                       |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPC_PERCAX == 0 .And. Empty(M->BPC_NIVVAL)
   MsgInfo("Informe se o nivel zero e valido.")
   Return(.F.)
Endif
          
BND->(DBSetOrder(2))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se existe alguma data de vigencia anterior a essa.             |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If BND->(DBSeek(xFilial("BND")+cCodigo+M->BPC_CODINT+M->BPC_CODTAB+Str(M->BPC_NUMAUX,1)))
   If M->BPC_VIGDE < BND->BND_DATDE
      MsgInfo("A data de vigencia do Auxiliar e menor que a ultima data de vigencia "+dtoc(BND->BND_DATDE))
      Return(.F.)
   Else
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //� Caso a data de vigencia seja igual a data de, entao verifico o percentual do auxiliar   |
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      If M->BPC_VIGDE == BND->BND_DATDE
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Se o percentual do auxiliar for diferente, nao consigo colocar a data final   |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         If M->BPC_PERCAX <> BND->BND_PERCAX
       	    MsgInfo("A data de vigencia do Auxiliar e igual a data da vigencia anterior.")
       	    Return(.F.)
         Else           
      	    lRet := .T.
         Endif
      Else
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Crio uma nova vigencia de auxiliar                                |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         nPosScan := aScan(aVetBND,{|x| x[2] == M->BPC_CODINT .And. x[3] == M->BPD_CODTAB .And. x[4] == M->BPD_NUMAUX })
         If nPosScan == 0
            aadd(aVetBND,{cCodigo,M->BPC_CODINT,M->BPC_CODTAB,M->BPC_NUMAUX,M->BPC_SEQAUX,M->BPC_VIGAUX,M->BPC_PERCAX,M->BPC_NIVVAL,M->BPC_VIGDE,ctod("")})
         Else
            aVetBND[nPosScan,5] := M->BPC_SEQAUX
            aVetBND[nPosScan,6] := M->BPC_VIGAUX
            aVetBND[nPosScan,7] := M->BPC_PERCAX
            aVetBND[nPosScan,8] := M->BPC_NIVVAL
            aVetBND[nPosScan,9] := M->BPC_VIGDE
         Endif
            
         lRet := .T.
      Endif
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Crio uma nova vigencia de auxiliar                                |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBND,{|x| x[2] == M->BPC_CODINT .And. x[3] == M->BPD_CODTAB .And. x[4] == M->BPD_NUMAUX })
   If nPosScan == 0
      aadd(aVetBND,{cCodigo,M->BPC_CODINT,M->BPC_CODTAB,M->BPC_NUMAUX,M->BPC_SEQAUX,M->BPC_VIGAUX,M->BPC_PERCAX,M->BPC_NIVVAL,M->BPC_VIGDE,ctod("")})
   Else
      aVetBND[nPosScan,5] := M->BPC_SEQAUX
      aVetBND[nPosScan,6] := M->BPC_VIGAUX
      aVetBND[nPosScan,7] := M->BPC_PERCAX
      aVetBND[nPosScan,8] := M->BPC_NIVVAL
      aVetBND[nPosScan,9] := M->BPC_VIGDE
   Endif
            
   lRet := .T.
Endif

Return(lRet)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPCDel  � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a exclusao de uma linha no browse de Auxliares da   낢�
굇�          � Operadora                                                  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPCDel()

LOCAL nPosScan
LOCAL nTamCols := 1

/*
If M->BPC_FLAG == "1"
   lRet := .F.
Endif
*/

nPosScan := aScan(aVetBND,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And.;
            x[3] == oGet29:aCols[oGet29:Linha(),oGet29:PlRetPos("BPC_CODTAB")] .And.;
            x[4] == oGet29:aCols[oGet29:Linha(),oGet29:PlRetPos("BPC_NUMAUX")]})
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se for exclusao da linha, tiro o dado do vetor                    |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�      
If oGet29:aCols[oGet29:Linha(),Len(oGet29:aHeader)+1]
   If nPosScan <> 0
      aadd(aVetDelBND,aVetBND[nPosScan])
      nTamCols   := Len(aVetBND)
      aDel(aVetBND,nPosScan)
      aSize(aVetBND,nTamCols-1)
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Se for retirar a exclusao, tenho que verificar se os dados daquele linha estavam no vetor   |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBND,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And.;
                x[3] == oGet29:aCols[oGet29:Linha(),oGet29:PlRetPos("BPC_CODTAB")] .And.;
                x[4] == oGet29:aCols[oGet29:Linha(),oGet29:PlRetPos("BPC_NUMAUX")]})
                
   If nPosScan <> 0
      aadd(aVetBND,{cCodigo,cCodInt,oGet29:aCols[oGet29:Linha(),oGet29:PlRetPos("BPC_CODTAB")],;
                     oGet29:aCols[oGet29:Linha(),oGet29:PlRetPos("BPC_NUMAUX")],;
                     oGet29:aCols[oGet29:Linha(),oGet29:PlRetPos("BPC_SEQAUX")],;
                     oGet29:aCols[oGet29:Linha(),oGet29:PlRetPos("BPC_VIGAUX")],;
                     oGet29:aCols[oGet29:Linha(),oGet29:PlRetPos("BPC_PERCAX")],;
                     oGet29:aCols[oGet29:Linha(),oGet29:PlRetPos("BPC_NIVVAL")],;
                     oGet29:aCols[oGet29:Linha(),oGet29:PlRetPos("BPC_VIGDE")],;
                     ctod("")})
                                                    
      nTamCols   := Len(aVetDelBND)
      aDel(aVetDelBND,nPosScan)
      aSize(aVetDelBND,nTamCols-1)
   Endif
Endif

Return(.T.)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPCWhen � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida o X3_WHEN para os campos do BPC.                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPCWhen(cTipo)

LOCAL lRet    := .T.
DEFAULT cTipo := ""
/*
If M->BPC_FLAG == "1" .And. Empty(cTipo)
   lRet := .F.
Endif
*/
If lRet .And. cTipo == "N" .And. !Empty(M->BPC_NUMAUX)
   lRet := .F.
Endif

Return(lRet)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPCRet  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Retorna a data da vigencia em aberto do Filme              낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� cCampo - Campo que vai ser retornado                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPCRet(cCampo)
    
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
      
BP1->(DBSetOrder(1))
If BP1->(DBSeek(xFilial("BP1")+M->BPC_CODINT+M->BPC_CODTAB+Str(M->BPC_NUMAUX,1)))
   While !BP1->(EOF()) .And. xFilial("BP1")+M->BPC_CODINT+M->BPC_CODTAB+Str(M->BPC_NUMAUX,1) == BP1->(BP1_FILIAL+BP1_CODINT+BP1_CODTAB+Str(M->BPC_NUMAUX,1)) .And.;
         !lRet
         If Empty(BP1->BP1_VIGATE)
            cConteu := &(cCampo)
            lRet    := .T.
         Endif
   BP1->(DBSkip())
   Enddo
Endif

Return(cConteu)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSPOSBND  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Verifica se ja existe vigencia para esse registro e se     낢�
굇�          � essa esta e menor que a que esta sendo digitada            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSPOSBND()
                                                                                          	
LOCAL lRet := .T.

BND->(DBSetOrder(2))
BND->(DBSeek(xFilial("BND")+cCodigo+cCodInt+M->BPC_CODTAB+Str(M->BPC_NUMAUX,1)))
If M->BPC_VIGDE < BND->BND_DATDE
   MsgInfo("A data de vigencia do Auxiliar e menor que a data inicial("+dtoc(BNC->BNC_DATDE)+") da vigencia anterior.")
   lRet := .F.
Endif


Return(lRet)
