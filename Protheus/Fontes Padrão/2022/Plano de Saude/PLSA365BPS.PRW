
#include "PROTHEUS.CH"
#include "PLSMGER.CH"


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� As funcoes abaixo sao utilizadas no browse de Material de uma Especialidade         |
//� Sao chamadas na validacao e exclusao de uma linha do Browse oGet44                  |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPSVld  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a inclusao de uma linha no browse de Material da    낢�
굇�          � Especialidade                                              낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPSVld()

LOCAL lRet       := .T.
LOCAL lRetBPS    := .T.
LOCAL nPosScan   := 0 

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se foi informado uma valor, e obrigatorio o codigo da Unidade de Medida |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPS_VLRMAT <> 0 .And. Empty(M->BPS_CODDOC)
   MsgInfo("Informe uma Unidade de Medida de Valor para esse Material.")
   Return(.F.)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se o nivel zero e valido                                       |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPS_VLRMAT == 0 .And. M->BPS_PERMAT == 0 .And. Empty(M->BPS_NIVVAL)
   MsgInfo("Informe se o nivel zero e valido.")
   Return(.F.)
Endif
          
BNS->(DBSetOrder(1))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se existe alguma data de vigencia anterior a essa.             |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If BNS->(DBSeek(xFilial("BNS")+cCodigo+M->BPS_CODINT+M->BPS_CODLOC+M->BPS_CODESP+M->BPS_CODSUB+M->BPS_CODTAB+M->BPS_CODMAT))
   If M->BPS_VIGDE < BNS->BNS_DATDE
      MsgInfo("A data de vigencia do Material e menor que a ultima data de vigencia "+dtoc(BNS->BNS_DATDE))
      Return(.F.)
   Else                  
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //� Caso a data de vigencia seja igual a data de, entao verifico o valor do Material        |
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      If M->BPS_VIGDE == BNS->BNS_DATDE
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Se o valor do Material for diferente, nao consigo colocar a data final        |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         If M->BPS_VLRMAT <> BNS->BNS_VLRMAT
       	    MsgInfo("A data de vigencia do Material e igual a data da vigencia anterior.")
       	    Return(.F.)
         Else           
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
            //� Se o percentual do Material for diferente, nao consigo colocar a data final   |
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�         
            If M->BPS_PERMAT <> BNS->BNS_PERMAT
         	   MsgInfo("A data de vigencia do Material e igual a data da vigencia anterior.")
        	   Return(.F.)
            Else            
        	   lRet := .T.
        	Endif
         Endif
      Else
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Crio uma nova vigencia de Material                                |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         nPosScan := aScan(aVetBNS,{|x| x[2] == M->BPS_CODINT .And. x[3] == M->BPS_CODLOC .And. x[4] == M->BPS_CODESP .And.;
                                         x[5] == M->BPS_CODSUB .And. x[6] == M->BPS_CODTAB .And. x[7] == M->BPS_CODMAT })
         If nPosScan == 0
            aadd(aVetBNS,{cCodigo,M->BPS_CODINT,M->BPS_CODLOC,M->BPS_CODESP,M->BPS_CODSUB,M->BPS_CODTAB,M->BPS_CODMAT,M->BPS_SEQMAT,M->BPS_VIGMAT,M->BPS_VLRMAT,M->BPS_MATIPO,M->BPS_CODDOC,M->BPS_PERMAT,M->BPS_NIVVAL,M->BPS_VIGDE,ctod("")})
         Else
            aVetBNS[nPosScan,8]  := M->BPS_SEQMAT
            aVetBNS[nPosScan,9]  := M->BPS_VIGMAT
            aVetBNS[nPosScan,10] := M->BPS_VLRMAT
            aVetBNS[nPosScan,11] := M->BPS_MATIPO
            aVetBNS[nPosScan,12] := M->BPS_CODDOC
            aVetBNS[nPosScan,13] := M->BPS_PERMAT
            aVetBNS[nPosScan,14] := M->BPS_NIVVAL
            aVetBNS[nPosScan,15] := M->BPS_VIGDE
         Endif
            
         lRet := .T.
      Endif
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Crio uma nova vigencia de Material                                |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNS,{|x| x[2] == M->BPS_CODINT .And. x[3] == M->BPS_CODLOC .And. x[4] == M->BPS_CODESP .And.;
                                   x[5] == M->BPS_CODSUB .And. x[6] == M->BPS_CODTAB .And. x[7] == M->BPS_CODMAT })
   If nPosScan == 0
      aadd(aVetBNS,{cCodigo,M->BPS_CODINT,M->BPS_CODLOC,M->BPS_CODESP,M->BPS_CODSUB,M->BPS_CODTAB,M->BPS_CODMAT,M->BPS_SEQMAT,M->BPS_VIGMAT,M->BPS_VLRMAT,M->BPS_MATIPO,M->BPS_CODDOC,M->BPS_PERMAT,M->BPS_NIVVAL,M->BPS_VIGDE,ctod("")})
   Else
      aVetBNS[nPosScan,8]  := M->BPS_SEQMAT
      aVetBNS[nPosScan,9]  := M->BPS_VIGMAT
      aVetBNS[nPosScan,10] := M->BPS_VLRMAT
      aVetBNS[nPosScan,11] := M->BPS_MATIPO
      aVetBNS[nPosScan,12] := M->BPS_CODDOC
      aVetBNS[nPosScan,13] := M->BPS_PERMAT
      aVetBNS[nPosScan,14] := M->BPS_NIVVAL
      aVetBNS[nPosScan,15] := M->BPS_VIGDE
   Endif
                     
   lRet := .T.
Endif

Return(lRet)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPSDel  � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a exclusao de uma linha no browse de Materiais da   낢�
굇�          � Operadora                                                  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPSDel()

LOCAL nPosScan
LOCAL nTamCols := 1
/*
If M->BPS_FLAG == "1"
   lRet := .F.
Endif
*/
nPosScan := aScan(aVetBNS,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
            x[4] == oGet44:aCols[oGet44:Linha(),oGet44:PlRetPos("BPS_CODESP")] .And.;
            x[5] == oGet44:aCols[oGet44:Linha(),oGet44:PlRetPos("BPS_CODSUB")] .And.;
            x[6] == oGet44:aCols[oGet44:Linha(),oGet44:PlRetPos("BPS_CODTAB")] .And.;
            x[7] == oGet44:aCols[oGet44:Linha(),oGet44:PlRetPos("BPS_CODMAT")]})
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se for exclusao da linha, tiro o dado do vetor                    |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�      
If oGet44:aCols[oGet44:Linha(),Len(oGet44:aHeader)+1]
   If nPosScan <> 0
      aadd(aVetDelBNS,aVetBNS[nPosScan])
      nTamCols   := Len(aVetBNS)
      aDel(aVetBNS,nPosScan)
      aSize(aVetBNS,nTamCols-1)
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Se for retirar a exclusao, tenho que verificar se os dados daquele linha estavam no vetor   |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNS,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
                x[4] == oGet44:aCols[oGet44:Linha(),oGet44:PlRetPos("BPS_CODESP")] .And.;
                x[5] == oGet44:aCols[oGet44:Linha(),oGet44:PlRetPos("BPS_CODSUB")] .And.;
                x[6] == oGet44:aCols[oGet44:Linha(),oGet44:PlRetPos("BPS_CODTAB")] .And.;
                x[7] == oGet44:aCols[oGet44:Linha(),oGet44:PlRetPos("BPS_CODMAT")]})
                
   If nPosScan <> 0
      aadd(aVetBNS,{cCodigo,cCodInt,cCodLoc,cCodEsp,cCodSub,;
                     oGet44:aCols[oGet44:Linha(),oGet44:PlRetPos("BPS_CODTAB")],;
                     oGet44:aCols[oGet44:Linha(),oGet44:PlRetPos("BPS_CODMAT")],;
                     oGet44:aCols[oGet44:Linha(),oGet44:PlRetPos("BPS_SEQMAT")],;
                     oGet44:aCols[oGet44:Linha(),oGet44:PlRetPos("BPS_VIGMAT")],;
                     oGet44:aCols[oGet44:Linha(),oGet44:PlRetPos("BPS_VLRMAT")],;
                     oGet44:aCols[oGet44:Linha(),oGet44:PlRetPos("BPS_MATIPO")],;
                     oGet44:aCols[oGet44:Linha(),oGet44:PlRetPos("BPS_CODDOC")],;
                     oGet44:aCols[oGet44:Linha(),oGet44:PlRetPos("BPS_PERMAT")],;
                     oGet44:aCols[oGet44:Linha(),oGet44:PlRetPos("BPS_NIVVAL")],;
                     oGet44:aCols[oGet44:Linha(),oGet44:PlRetPos("BPS_VIGDE")],;
                     ctod("")})
                                                    
      nTamCols   := Len(aVetDelBNS)
      aDel(aVetDelBNS,nPosScan)
      aSize(aVetDelBNS,nTamCols-1)
   Endif
Endif

Return(.T.)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPSWhen � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida o X3_WHEN para os campos do BPS.                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPSWhen(cTipo)

LOCAL lRet    := .T.
DEFAULT cTipo := ""
/*
If M->BPS_FLAG == "1" .And. Empty(cTipo)
   lRet := .F.
Endif
*/
If lRet .And. cTipo == "V" .And. !Empty(M->BPS_PERMAT)
   lRet := .F.
Endif

If lRet .And. cTipo == "P" .And. !Empty(M->BPS_VLRMAT)
   lRet := .F.
Endif

If lRet .And. cTipo == "N" .And. (!Empty(M->BPS_PERMAT) .Or. !Empty(M->BPS_VLRMAT))
   lRet := .F.
Endif

Return(lRet)


/*                   
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPSRet  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Retorna a data da vigencia em aberto dos Materiais         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� cCampo - Campo que vai ser retornado                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPSRet(cCampo)
    
LOCAL cConteu
LOCAL lRet   := .F.

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
      
BS6->(DBSetOrder(1))
If BS6->(DBSeek(xFilial("BS6")+M->BPS_CODINT+M->BPS_CODTAB+M->BPS_CODMAT))
   While !BS6->(EOF()) .And. xFilial("BS6")+M->BPS_CODINT+M->BPS_CODTAB+M->BPS_CODMAT == BS6->(BS6_FILIAL+BS6_CODINT+BS6_CODTAB+BS6_MACODI) .And.;
         !lRet
         If Empty(BS6->BS6_VIGATE)
            cConteu := &(cCampo)
            lRet    := .T.
         Endif
   BS6->(DBSkip())
   Enddo
Endif

Return(cConteu)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSPOSBNS  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Verifica se ja existe vigencia para esse registro e se     낢�
굇�          � essa esta e menor que a que esta sendo digitada            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSPOSBNS()

LOCAL lRet := .T.

BNS->(DBSetOrder(2))
BNS->(DBSeek(xFilial("BNS")+cCodigo+cCodInt+cCodLoc+cCodEsp+cCodSub+M->BPS_CODTAB+M->BPS_CODMAT))
If M->BPS_VIGDE < BNS->BNS_DATDE
   MsgInfo("A data de vigencia do Material e menor que a data inicial("+dtoc(BNC->BNC_DATDE)+") da vigencia anterior.")
   lRet := .F.
Endif


Return(lRet)
