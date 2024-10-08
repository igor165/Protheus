#INCLUDE "plsa365bpo.ch"

#include "PROTHEUS.CH"
#include "PLSMGER.CH"


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� As funcoes abaixo sao utilizadas no browse de Taxas para uma Especialidade  . |
//� Sao chamadas na validacao e exclusao de uma linha do Browse oGet40            |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPOVld  � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a inclusao de uma linha no browse de Taxas da       낢�
굇�          � Especialidades.                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPOVld()

LOCAL lRet       := .T.
LOCAL lRetBPO    := .T.
LOCAL nPosScan   := 0
                     
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se foi informado uma valor, e obrigatorio o codigo da Unidade de Medida |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPO_VLRTAX <> 0 .And. Empty(M->BPO_CODDOC)
   MsgInfo(STR0001) //"Informe uma Unidade de Medida de Valor para essa Taxa."
   Return(.F.)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se o nivel zero e valido                                       |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If M->BPO_VLRTAX == 0 .And. M->BPO_PERFIL == 0 .And. Empty(M->BPO_NIVVAL)
   MsgInfo(STR0002) //"Informe se o nivel zero e valido."
   Return(.F.)
Endif
          
BNN->(DBSetOrder(1))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifico se existe alguma data de vigencia anterior a essa.             |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If BNN->(DBSeek(xFilial("BNN")+cCodigo+M->BPO_CODINT+M->BPO_CODLOC+M->BPO_CODESP+M->BPO_CODSUB+M->BPO_CODTAX))
   If M->BPO_VIGDE < BNN->BNN_DATDE
      MsgInfo(STR0003+dtoc(BNN->BNN_DATDE)) //"A data de vigencia da Taxa e menor que a ultima data de vigencia "
      Return(.F.)
   Else                  
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //� Caso a data de vigencia seja igual a data de, entao verifico o valor da taxa  |
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      If M->BPO_VIGDE == BNN->BNN_DATDE
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Se o valor da taxa for diferente, nao consigo colocar a data final|
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         If M->BPO_VLRTAX <> BNN->BNN_VLRTAX
       	    MsgInfo(STR0004) //"A data de vigencia da taxa e igual a data da vigencia anterior."
       	    Return(.F.)
         Else           
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
            //� Se o percentual da taxa for diferente, nao consigo colocar a data final |
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�         
            If M->BPO_PERTAX <> BNN->BNN_PERTAX
         	   MsgInfo(STR0004) //"A data de vigencia da taxa e igual a data da vigencia anterior."
        	   Return(.F.)            
            Else            
        	   lRet := .T.
        	Endif
         Endif
      Else
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         //� Crio uma nova vigencia de taxa                                    |
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
         nPosScan := aScan(aVetBNN,{|x| x[2] == M->BPO_CODINT .And. x[3] == M->BPO_CODLOC .And. x[4] == M->BPO_CODSUB .And.;
                            x[5] == M->BPO_CODSUB .And. x[6] == M->BPO_CODTAX})
         If nPosScan == 0
            aadd(aVetBNN,{cCodigo,M->BPO_CODINT,M->BPO_CODLOC,M->BPO_CODESP,M->BPO_CODSUB,M->BPO_CODTAX,M->BPO_SEQTAX,M->BPO_VIGTAX,M->BPO_VLRTAX,M->BPO_PERTAX,M->BPO_NIVVAL,M->BPO_CODDOC,M->BPO_VIGDE,ctod("")})
         Else
            aVetBNN[nPosScan,7]  := M->BPO_SEQTAX
            aVetBNN[nPosScan,8]  := M->BPO_VIGTAX
            aVetBNN[nPosScan,9]  := M->BPO_VLRTAX
            aVetBNN[nPosScan,10] := M->BPO_PERTAX
            aVetBNN[nPosScan,11] := M->BPO_NIVVAL
            aVetBNN[nPosScan,12] := M->BPO_CODDOC
            aVetBNN[nPosScan,13] := M->BPO_VIGDE
         Endif
            
         lRet := .T.
      Endif
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Crio uma nova vigencia de taxa                                    |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNN,{|x| x[2] == M->BPO_CODINT .And. x[3] == M->BPO_CODLOC .And. x[4] == M->BPO_CODSUB .And.;
                      x[5] == M->BPO_CODSUB .And. x[6] == M->BPO_CODTAX})
   If nPosScan == 0
      aadd(aVetBNN,{cCodigo,M->BPO_CODINT,M->BPO_CODLOC,M->BPO_CODESP,M->BPO_CODSUB,M->BPO_CODTAX,M->BPO_SEQTAX,M->BPO_VIGTAX,M->BPO_VLRTAX,M->BPO_PERTAX,M->BPO_NIVVAL,M->BPO_CODDOC,M->BPO_VIGDE,ctod("")})
   Else
      aVetBNN[nPosScan,7]  := M->BPO_SEQTAX
      aVetBNN[nPosScan,8]  := M->BPO_VIGTAX
      aVetBNN[nPosScan,9]  := M->BPO_VLRTAX
      aVetBNN[nPosScan,10] := M->BPO_PERTAX
      aVetBNN[nPosScan,11] := M->BPO_NIVVAL
      aVetBNN[nPosScan,12] := M->BPO_CODDOC
      aVetBNN[nPosScan,13] := M->BPO_VIGDE
   Endif
   
   lRet := .T. 
Endif

Return(lRet)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPODel  � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida a exclusao de uma linha no browse de Taxas da       낢�
굇�          � Especialidade.                                             낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPODel()

LOCAL nPosScan
LOCAL nTamCols := 1               
LOCAL lRet     := .T.
/*
If M->BPO_FLAG == "1"
   lRet := .F.
Endif
*/
nPosScan := aScan(aVetBNN,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;  
            x[4] == oGet33:aCols[oGet33:Linha(),oGet33:PlRetPos("BPO_CODESP")] .And.;
            x[5] == oGet33:aCols[oGet33:Linha(),oGet33:PlRetPos("BPO_CODSUB")] .And.;
            x[6] == oGet33:aCols[oGet33:Linha(),oGet33:PlRetPos("BPO_CODTAX")]})
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se for exclusao da linha, tiro o dado do vetor                    |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�      
If oGet33:aCols[oGet33:Linha(),Len(oGet33:aHeader)+1]
   If nPosScan <> 0
      aadd(aVetDelBNN,aVetBNN[nPosScan])
      nTamCols   := Len(aVetBNN)
      aDel(aVetBNN,nPosScan)
      aSize(aVetBNN,nTamCols-1)
   Endif
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Se for retirar a exclusao, tenho que verificar se os dados daquele linha estavam no vetor   |
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   nPosScan := aScan(aVetBNN,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;  
               x[4] == oGet33:aCols[oGet33:Linha(),oGet33:PlRetPos("BPO_CODESP")] .And.;
               x[5] == oGet33:aCols[oGet33:Linha(),oGet33:PlRetPos("BPO_CODSUB")] .And.;
               x[6] == oGet33:aCols[oGet33:Linha(),oGet33:PlRetPos("BPO_CODTAX")]})
                
   If nPosScan <> 0
      aadd(aVetBNN,{cCodigo,cCodInt,oGet33:aCols[oGet33:Linha(),oGet33:PlRetPos("BPO_CODLOC")],;
                     oGet33:aCols[oGet33:Linha(),oGet33:PlRetPos("BPO_CODESP")],;
                     oGet33:aCols[oGet33:Linha(),oGet33:PlRetPos("BPO_CODSUB")],;
                     oGet33:aCols[oGet33:Linha(),oGet33:PlRetPos("BPO_CODTAX")],;
                     oGet33:aCols[oGet33:Linha(),oGet33:PlRetPos("BPO_SEQTAX")],;
                     oGet33:aCols[oGet33:Linha(),oGet33:PlRetPos("BPO_VIGTAX")],;
                     oGet33:aCols[oGet33:Linha(),oGet33:PlRetPos("BPO_VLRTAX")],;
                     oGet33:aCols[oGet33:Linha(),oGet33:PlRetPos("BPO_PERTAX")],;
                     oGet33:aCols[oGet33:Linha(),oGet33:PlRetPos("BPO_NIVVAL")],;
                     oGet33:aCols[oGet33:Linha(),oGet33:PlRetPos("BPO_CODDOC")],;
                     oGet33:aCols[oGet33:Linha(),oGet33:PlRetPos("BPO_VIGDE")],;
                     ctod("")})
                                                    
      nTamCols   := Len(aVetDelBNN)
      aDel(aVetDelBNN,nPosScan)
      aSize(aVetDelBNN,nTamCols-1)
   Endif
Endif

Return(.T.)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPOWhen � Autor � Michele Tatagiba    � Data � 22.08.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Valida o X3_WHEN para os campos do BPO.                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPOWhen(cTipo)

LOCAL lRet    := .T.
DEFAULT cTipo := ""
/*
If M->BPO_FLAG == "1" .And. Empty(cTipo)
   lRet := .F.
Endif
*/
If lRet .And. cTipo == "V" .And. !Empty(M->BPO_PERTAX)
   lRet := .F.
Endif

If lRet .And. cTipo == "P" .And. !Empty(M->BPO_VLRTAX)
   lRet := .F.
Endif

If lRet .And. cTipo == "N" .And. (!Empty(M->BPO_PERTAX) .Or. !Empty(M->BPO_VLRTAX))
   lRet := .F.
Endif

Return(lRet)             


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSBPORet  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Retorna a data da vigencia em aberto da Taxa               낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� cCampo - Campo que vai ser retornado                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSBPORet(cCampo)
    
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
      
BLP->(DBSetOrder(1))
If BLP->(DBSeek(xFilial("BLP")+M->BPO_CODINT+M->BPO_CODTAX))
   While !BLP->(EOF()) .And. xFilial("BLP")+M->BPO_CODINT+M->BPO_CODTAX == BLP->(BLP_FILIAL+BLP_CODINT+BLP_CODTAX) .And.;
         !lRet
         If Empty(BLP->BLP_VIGATE)
            cConteu := &(cCampo)
            lRet    := .T.
         Endif
   BLP->(DBSkip())
   Enddo
Endif

Return(cConteu)


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    � PLSPOSBNN  � Autor � Michele Tatagiba    � Data � 02.10.02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Verifica se ja existe vigencia para esse registro e se     낢�
굇�          � essa esta e menor que a que esta sendo digitada            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function PLSPOSBNN()

LOCAL lRet := .T.

BNN->(DBSetOrder(2))
BNN->(DBSeek(xFilial("BNN")+cCodigo+cCodInt+cCodLoc+cCodEsp+cCodSub+M->BPO_CODTAX))
If M->BPO_VIGDE < BNN->BNN_DATDE
   MsgInfo(STR0005+dtoc(BNN->BNN_DATDE)+STR0006) //"A data de vigencia da Taxa e menor que a data inicial("###") da vigencia anterior."
   lRet := .F.
Endif


Return(lRet)
