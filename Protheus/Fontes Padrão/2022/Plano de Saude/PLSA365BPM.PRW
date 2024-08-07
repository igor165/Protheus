#INCLUDE "plsa365bpm.ch"

#include "PROTHEUS.CH"
#include "PLSMGER.CH"


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� As funcoes abaixo sao utilizadas no browse de Medicamento de um Local de Atendimento |
//� Sao chamadas na validacao e exclusao de uma linha do Browse oGet38                   |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPMVld  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a inclusao de uma linha no browse de Medicamentos do낢�
굇�          � Local de Atendimento                                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPMVld()

LOCAL lRet       := .T.
LOCAL lRetBPM    := .T.
LOCAL nPosScan   := 0 

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se foi informado uma valor, e obrigatorio o codigo da Unidade de Medida |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPM_VLRMED <> 0 .And. Empty(M->BPM_CODDOC)
   MsgInfo(STR0001) //"Informe uma Unidade de Medida de Valor para esse Medicamento."
   Return(.F.)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se o nivel zero e valido                                       |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPM_VLRMED == 0 .And. M->BPM_PERMED == 0 .And. Empty(M->BPM_NIVVAL)
   MsgInfo(STR0002) //"Informe se o nivel zero e valido."
   Return(.F.)
Endif
          
BNL->(DBSetOrder(2))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se existe alguma data de vigencia anterior a essa.             |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If BNL->(DBSeek(xFilial("BNL")+cCodigo+M->BPM_CODINT+M->BPM_CODLOC+M->BPM_CODTAB+M->BPM_PREMED+M->BPM_PREAPR+M->BPM_PRELAB))
   If M->BPM_VIGDE < BNL->BNL_DATDE
      MsgInfo(STR0003+dtoc(BNL->BNL_DATDE)) //"A data de vigencia do Medicamento e menor que a ultima data de vigencia "
      Return(.F.)
   Else                  
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //� Caso a data de vigencia seja igual a data de, entao verifico o valor do Medicamento     |
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      If M->BPM_VIGDE == BNL->BNL_DATDE
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Se o valor do Medicamento for diferente, nao consigo colocar a data final     |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         If M->BPM_VLRMED <> BNL->BNL_VLRMED
       	    MsgInfo(STR0004) //"A data de vigencia do Medicamento e igual a data da vigencia anterior."
       	    Return(.F.)
         Else           
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
            //� Se o percentual do Medicamento for diferente, nao consigo colocar a data final|
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�         
            If M->BPM_PERMED <> BNL->BNL_PERMED
         	   MsgInfo(STR0004) //"A data de vigencia do Medicamento e igual a data da vigencia anterior."
        	   Return(.F.)
            Else            
        	   lRet := .T.
        	Endif
         Endif
      Else
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Crio uma nova vigencia do Medicamento                             |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         nPosScan := aScan(aVetBNL,{|x| x[2] == M->BPM_CODINT .And. x[4] == M->BPM_CODTAB .And. x[3] == M->BPM_CODLOC .And. x[5] == M->BPM_PREMED ;
                                         .And. x[6] == M->BPM_PREAPR .And. x[7] == M->BPM_PRELAB })
         If nPosScan == 0
            aadd(aVetBNL,{cCodigo,M->BPM_CODINT,M->BPM_CODLOC,M->BPM_CODTAB,M->BPM_PREMED,M->BPM_PREAPR,M->BPM_PRELAB,M->BPM_VIGMED,M->BPM_VLRMED,M->BPM_PRTIPO,M->BPM_CODDOC,M->BPM_PERMED,M->BPM_NIVVAL,M->BPM_VIGDE,ctod("")})
         Else
            aVetBNL[nPosScan,8]   := M->BPM_VIGMED
            aVetBNL[nPosScan,9]   := M->BPM_VLRMED
            aVetBNL[nPosScan,10]  := M->BPM_PRTIPO
            aVetBNL[nPosScan,11]  := M->BPM_CODDOC
            aVetBNL[nPosScan,12]  := M->BPM_PERMED
            aVetBNL[nPosScan,13]  := M->BPM_NIVVAL
            aVetBNL[nPosScan,14]  := M->BPM_VIGDE
         Endif
            
         lRet := .T.
      Endif
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Crio uma nova vigencia do Medicamento                             |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   If nPosScan == 0
      aadd(aVetBNL,{cCodigo,M->BPM_CODINT,M->BPM_CODLOC,M->BPM_CODTAB,M->BPM_PREMED,M->BPM_PREAPR,M->BPM_PRELAB,M->BPM_VIGMED,M->BPM_VLRMED,M->BPM_PRTIPO,M->BPM_CODDOC,M->BPM_PERMED,M->BPM_NIVVAL,M->BPM_VIGDE,ctod("")})
   Else
      aVetBNL[nPosScan,8]   := M->BPM_VIGMED
      aVetBNL[nPosScan,9]   := M->BPM_VLRMED
      aVetBNL[nPosScan,10]  := M->BPM_PRTIPO
      aVetBNL[nPosScan,11]  := M->BPM_CODDOC
      aVetBNL[nPosScan,12]  := M->BPM_PERMED
      aVetBNL[nPosScan,13]  := M->BPM_NIVVAL
      aVetBNL[nPosScan,14]  := M->BPM_VIGDE
   Endif

   lRet := .T.
Endif

Return(lRet)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPMDel  � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a exclusao de uma linha no browse de Medicamentos da낢�
굇�          � Operadora                                                  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPMDel()

LOCAL nPosScan
LOCAL nTamCols := 1
/*
If M->BPM_FLAG == "1"
   lRet := .F.
Endif
*/
nPosScan := aScan(aVetBNL,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
            x[4] == oGet38:aCols[oGet38:Linha(),oGet38:PlRetPos("BPM_CODTAB")] .And.;
            x[5] == oGet38:aCols[oGet38:Linha(),oGet38:PlRetPos("BPM_PREMED")] .And.;
            x[6] == oGet38:aCols[oGet38:Linha(),oGet38:PlRetPos("BPM_PREAPR")] .And.;
            x[7] == oGet38:aCols[oGet38:Linha(),oGet38:PlRetPos("BPM_PRELAB")] })
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se for exclusao da linha, tiro o dado do vetor                    |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�      
If oGet38:aCols[oGet38:Linha(),Len(oGet38:aHeader)+1]
   If nPosScan <> 0
      aadd(aVetDelBNL,aVetBNL[nPosScan])
      nTamCols   := Len(aVetBNL)
      aDel(aVetBNL,nPosScan)
      aSize(aVetBNL,nTamCols-1)
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Se for retirar a exclusao, tenho que verificar se os dados daquele linha estavam no vetor   |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNL,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
               x[4] == oGet38:aCols[oGet38:Linha(),oGet38:PlRetPos("BPM_CODTAB")] .And.;
               x[5] == oGet38:aCols[oGet38:Linha(),oGet38:PlRetPos("BPM_PREMED")] .And.;
               x[6] == oGet38:aCols[oGet38:Linha(),oGet38:PlRetPos("BPM_PREAPR")] .And.;
               x[7] == oGet38:aCols[oGet38:Linha(),oGet38:PlRetPos("BPM_PRELAB")] })
                
   If nPosScan <> 0
      aadd(aVetBNL,{cCodigo,cCodInt,cCodLoc,oGet38:aCols[oGet38:Linha(),oGet38:PlRetPos("BPM_CODTAB")],;
                     oGet38:aCols[oGet38:Linha(),oGet38:PlRetPos("BPM_PREMED")],;
                     oGet38:aCols[oGet38:Linha(),oGet38:PlRetPos("BPM_PREAPR")],;
                     oGet38:aCols[oGet38:Linha(),oGet38:PlRetPos("BPM_PRELAB")],;
                     oGet38:aCols[oGet38:Linha(),oGet38:PlRetPos("BPM_VIGMED")],;
                     oGet38:aCols[oGet38:Linha(),oGet38:PlRetPos("BPM_VLRMED")],;
                     oGet38:aCols[oGet38:Linha(),oGet38:PlRetPos("BPM_PRTIPO")],;
                     oGet38:aCols[oGet38:Linha(),oGet38:PlRetPos("BPM_PERMED")],;
                     oGet38:aCols[oGet38:Linha(),oGet38:PlRetPos("BPM_NIVVAL")],;
                     oGet38:aCols[oGet38:Linha(),oGet38:PlRetPos("BPM_VIGDE")],;
                     ctod("")})
                                                    
      nTamCols   := Len(aVetDelBNL)
      aDel(aVetDelBNL,nPosScan)
      aSize(aVetDelBNL,nTamCols-1)
   Endif
Endif

Return(.T.)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPMWhen � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida o X3_WHEN para os campos do BPM.                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPMWhen(cTipo)

LOCAL lRet    := .T.    
DEFAULT cTipo := ""
/*
If M->BPM_FLAG == "1" .And. Empty(cTipo)
   lRet := .F.
Endif
*/
If lRet .And. cTipo == "V" .And. !Empty(M->BPM_PERMED)
   lRet := .F.
Endif

If lRet .And. cTipo == "P" .And. !Empty(M->BPM_VLRMED)
   lRet := .F.
Endif       

If lRet .And. cTipo == "N" .And. (!Empty(M->BPM_PERMED) .Or. !Empty(M->BPM_VLRMED))
   lRet := .F.
Endif

Return(lRet)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPMRet  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Retorna a data da vigencia em aberto do Medicamento        낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� cCampo - Campo que vai ser retornado                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPMRet(cCampo)
    
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
                	
BS4->(DBSetOrder(1))
If BS4->(DBSeek(xFilial("BS4")+M->BPM_CODINT+M->BPM_CODTAB+M->BPM_PREMED+M->BPM_PREAPR+M->BPM_PRELAB))
   While !BS4->(EOF()) .And. xFilial("BS4")+M->BPM_CODINT+M->BPM_CODTAB+M->BPM_PREMED+M->BPM_PREAPR+M->BPM_PRELAB == BS4->(BS4_FILIAL+BS4_CODINT+BS4_TABMED+BS4_PREMED+BS4_PREAPR+BS4_PRELAB) .And.;
         !lRet
         If Empty(BS4->BS4_VIGATE)
            cConteu := &(cCampo)
            lRet    := .T.
         Endif
   BS4->(DBSkip())
   Enddo
Endif

Return(cConteu)
                       
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSPOSBNL  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Verifica se ja existe vigencia para esse registro e se     낢�
굇�          � essa esta e menor que a que esta sendo digitada            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSPOSBNL()

LOCAL lRet := .T.

BNL->(DBSetOrder(2))
BNL->(DBSeek(xFilial("BNL")+cCodigo+cCodInt+cCodLoc+M->BPM_CODTAB+M->BPM_PREMED+M->BPM_PREAPR+M->BPM_PRELAB))
If M->BPM_VIGDE < BNL->BNL_DATDE
   MsgInfo(STR0005+dtoc(BNC->BNC_DATDE)+STR0006) //"A data de vigencia do Medicamento e menor que a data inicial("###") da vigencia anterior."
   lRet := .F.
Endif

Return(lRet)



Function PLSBPMCpo()

LOCAL lRet    := .T.

If Empty(M->BPM_CODTAB) .Or. Empty(M->BPM_PREMED) .Or. Empty(M->BPM_PREAPR) .Or. Empty(M->BPM_PRELAB)
   Return(.T.)
Endif

BS4->(DBSetOrder(1))
lRet := BS4->(DBSeek(xFilial("BS4")+M->BPM_CODINT+M->BPM_CODTAB+M->BPM_PREMED+M->BPM_PREAPR+M->BPM_PRELAB))


Return(lRet)
