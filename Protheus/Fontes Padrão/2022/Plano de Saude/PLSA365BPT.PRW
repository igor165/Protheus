
#include "PROTHEUS.CH"
#include "PLSMGER.CH"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ As funcoes abaixo sao utilizadas no browse de Medicamento de uma Especialidade.      |
//³ Sao chamadas na validacao e exclusao de uma linha do Browse oGet45                   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSBPTVld  ³ Autor ³ Michele Tatagiba    ³ Data ³ 02.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a inclusao de uma linha no browse de Medicamentos do³±±
±±³          ³ Especialidade                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBPTVld()

LOCAL lRet       := .T.
LOCAL lRetBPT    := .T.
LOCAL nPosScan   := 0 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se foi informado uma valor, e obrigatorio o codigo da Unidade de Medida |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->BPT_VLRMED <> 0 .And. Empty(M->BPT_CODDOC)
   MsgInfo("Informe uma Unidade de Medida de Valor para esse Medicamento.")
   Return(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se o nivel zero e valido                                       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->BPT_VLRMED == 0 .And. M->BPT_PERMED == 0 .And. Empty(M->BPT_NIVVAL)
   MsgInfo("Informe se o nivel zero e valido.")
   Return(.F.)
Endif
          
BNT->(DBSetOrder(2))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se existe alguma data de vigencia anterior a essa.             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BNT->(DBSeek(xFilial("BNT")+cCodigo+M->BPT_CODINT+M->BPT_CODLOC+M->BPT_CODESP+M->BPT_CODSUB+M->BPT_CODTAB+M->BPT_PREMED+M->BPT_PREAPR+M->BPT_PRELAB))
   If M->BPT_VIGDE < BNT->BNT_DATDE
      MsgInfo("A data de vigencia do Medicamento e menor que a ultima data de vigencia "+dtoc(BNT->BNT_DATDE))
      Return(.F.)
   Else                  
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Caso a data de vigencia seja igual a data de, entao verifico o valor do Medicamento     |
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If M->BPT_VIGDE == BNT->BNT_DATDE
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Se o valor do Medicamento for diferente, nao consigo colocar a data final     |
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         If M->BPT_VLRMED <> BNT->BNT_VLRMED
       	    MsgInfo("A data de vigencia do Medicamento e igual a data da vigencia anterior.")
       	    Return(.F.)
         Else           
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Se o percentual do Medicamento for diferente, nao consigo colocar a data final|
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         
            If M->BPT_PERMED <> BNT->BNT_PERMED
         	   MsgInfo("A data de vigencia do Medicamento e igual a data da vigencia anterior.")
        	   Return(.F.)
            Else            
        	   lRet := .T.
        	Endif
         Endif
      Else
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Crio uma nova vigencia do Medicamento                             |
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         nPosScan := aScan(aVetBNT,{|x| x[2] == M->BPT_CODINT .And. x[3] == M->BPT_CODLOC .And.;
                                     x[4] == M->BPT_CODESP .And. x[5] == M->BPT_CODSUB .And. x[6] == M->BPT_CODTAB .And.;
                                     x[7] == M->BPT_PREMED .And. x[8] == M->BPT_PREAPR .And. x[9] == M->BPT_PRELAB })
         If nPosScan == 0
            aadd(aVetBNT,{cCodigo,M->BPT_CODINT,M->BPT_CODLOC,M->BPT_CODESP,M->BPT_CODSUB,M->BPT_CODTAB,M->BPT_PREMED,M->BPT_PREAPR,M->BPT_PRELAB,M->BPT_SEQMED,M->BPT_VIGMED,M->BPT_VLRMED,M->BPT_PRTIPO,M->BPT_CODDOC,M->BPT_PERMED,M->BPT_NIVVAL,M->BPT_VIGDE,ctod("")})
         Else
            aVetBNT[nPosScan,10]  := M->BPT_SEQMED
            aVetBNT[nPosScan,11]  := M->BPT_VIGMED
            aVetBNT[nPosScan,12]  := M->BPT_VLRMED
            aVetBNT[nPosScan,13]  := M->BPT_PRTIPO
            aVetBNT[nPosScan,14]  := M->BPT_CODDOC
            aVetBNT[nPosScan,15]  := M->BPT_PERMED
            aVetBNT[nPosScan,16]  := M->BPT_NIVVAL
            aVetBNT[nPosScan,17]  := M->BPT_VIGDE
         Endif
            
         lRet := .T.
      Endif
   Endif
Else
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Crio uma nova vigencia do Medicamento                             |
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   nPosScan := aScan(aVetBNT,{|x| x[2] == M->BPT_CODINT .And. x[3] == M->BPT_CODLOC .And.;
                                x[4] == M->BPT_CODESP .And. x[5] == M->BPT_CODSUB .And. x[6] == M->BPT_CODTAB .And.;
                                x[7] == M->BPT_PREMED .And. x[8] == M->BPT_PREAPR .And. x[9] == M->BPT_PRELAB })
   If nPosScan == 0
      aadd(aVetBNT,{cCodigo,M->BPT_CODINT,M->BPT_CODLOC,M->BPT_CODESP,M->BPT_CODSUB,M->BPT_CODTAB,M->BPT_PREMED,M->BPT_PREAPR,M->BPT_PRELAB,M->BPT_SEQMED,M->BPT_VIGMED,M->BPT_VLRMED,M->BPT_PRTIPO,M->BPT_CODDOC,M->BPT_PERMED,M->BPT_NIVVAL,M->BPT_VIGDE,ctod("")})
   Else
      aVetBNT[nPosScan,10]  := M->BPT_SEQMED
      aVetBNT[nPosScan,11]  := M->BPT_VIGMED
      aVetBNT[nPosScan,12]  := M->BPT_VLRMED
      aVetBNT[nPosScan,13]  := M->BPT_PRTIPO
      aVetBNT[nPosScan,14]  := M->BPT_CODDOC
      aVetBNT[nPosScan,15]  := M->BPT_PERMED
      aVetBNT[nPosScan,16]  := M->BPT_NIVVAL
      aVetBNT[nPosScan,17]  := M->BPT_VIGDE
   Endif

   lRet := .T.
Endif

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSBPTDel  ³ Autor ³ Michele Tatagiba    ³ Data ³ 22.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a exclusao de uma linha no browse de Medicamentos da³±±
±±³          ³ Especialidade                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBPTDel()

LOCAL nPosScan
LOCAL nTamCols := 1
/*
If M->BPT_FLAG == "1"
   lRet := .F.
Endif
*/
nPosScan := aScan(aVetBNT,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
            x[4] == oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_CODESP")] .And.;
            x[5] == oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_CODSUB")] .And.;
            x[6] == oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_CODTAB")] .And.;
            x[7] == oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_PREMED")] .And.;
            x[8] == oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_PREAPR")] .And.;
            x[9] == oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_PRELAB")] })
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for exclusao da linha, tiro o dado do vetor                    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
If oGet45:aCols[oGet45:Linha(),Len(oGet45:aHeader)+1]
   If nPosScan <> 0
      aadd(aVetDelBNT,aVetBNT[nPosScan])
      nTamCols   := Len(aVetBNT)
      aDel(aVetBNT,nPosScan)
      aSize(aVetBNT,nTamCols-1)
   Endif
Else
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Se for retirar a exclusao, tenho que verificar se os dados daquele linha estavam no vetor   |
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   nPosScan := aScan(aVetBNT,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
               x[4] == oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_CODESP")] .And.;
               x[5] == oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_CODSUB")] .And.;
               x[6] == oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_CODTAB")] .And.;
               x[7] == oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_PREMED")] .And.;
               x[8] == oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_PREAPR")] .And.;
               x[9] == oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_PRELAB")] })
                
   If nPosScan <> 0
      aadd(aVetBNT,{cCodigo,cCodInt,cCodLoc,cCodEsp,cCodSub,;
                     oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_CODTAB")],;
                     oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_PREMED")],;
                     oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_PREAPR")],;
                     oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_PRELAB")],;
                     oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_SEQMED")],;
                     oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_VIGMED")],;
                     oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_VLRMED")],;
                     oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_PRTIPO")],;
                     oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_PERMED")],;
                     oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_NIVVAL")],;
                     oGet45:aCols[oGet45:Linha(),oGet45:PlRetPos("BPT_VIGDE")],;
                     ctod("")})
                                                    
      nTamCols   := Len(aVetDelBNT)
      aDel(aVetDelBNT,nPosScan)
      aSize(aVetDelBNT,nTamCols-1)
   Endif
Endif

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSBPTWhen ³ Autor ³ Michele Tatagiba    ³ Data ³ 22.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o X3_WHEN para os campos do BPT.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBPTWhen(cTipo)

LOCAL lRet    := .T.    
DEFAULT cTipo := ""
/*
If M->BPT_FLAG == "1" .And. Empty(cTipo)
   lRet := .F.
Endif
*/
If lRet .And. cTipo == "V" .And. !Empty(M->BPT_PERMED)
   lRet := .F.
Endif

If lRet .And. cTipo == "P" .And. !Empty(M->BPT_VLRMED)
   lRet := .F.
Endif       

If lRet .And. cTipo == "N" .And. (!Empty(M->BPT_PERMED) .Or. !Empty(M->BPT_VLRMED))
   lRet := .F.
Endif

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSBPTRet  ³ Autor ³ Michele Tatagiba    ³ Data ³ 02.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a data da vigencia em aberto do Medicamento        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCampo - Campo que vai ser retornado                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBPTRet(cCampo)
    
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
If BS4->(DBSeek(xFilial("BS4")+M->BPT_CODINT+M->BPT_CODTAB+M->BPT_PREMED+M->BPT_PREAPR+M->BPT_PRELAB))
   While !BS4->(EOF()) .And. xFilial("BS4")+M->BPT_CODINT+M->BPT_CODTAB+M->BPT_PREMED+M->BPT_PREAPR+M->BPT_PRELAB == BS4->(BS4_FILIAL+BS4_CODINT+BS4_TABMED+BS4_PREMED+BS4_PREAPR+BS4_PRELAB) .And.;
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPOSBNT  ³ Autor ³ Michele Tatagiba    ³ Data ³ 02.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se ja existe vigencia para esse registro e se     ³±±
±±³          ³ essa esta e menor que a que esta sendo digitada            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPOSBNT()

LOCAL lRet := .T.

BNT->(DBSetOrder(2))
BNT->(DBSeek(xFilial("BNT")+cCodigo+cCodInt+cCodLoc+cCodEsp+cCodSub+M->BPT_CODTAB+M->BPT_PREMED+M->BPT_PREAPR+M->BPT_PRELAB))
If M->BPT_VIGDE < BNT->BNT_DATDE
   MsgInfo("A data de vigencia do Medicamento e menor que a data inicial("+dtoc(BNC->BNC_DATDE)+") da vigencia anterior.")
   lRet := .F.
Endif

Return(lRet)



Function PLSBPTCpo()

LOCAL lRet    := .T.

If Empty(M->BPT_CODTAB) .Or. Empty(M->BPT_PREMED) .Or. Empty(M->BPT_PREAPR) .Or. Empty(M->BPT_PRELAB)
   Return(.T.)
Endif

BS4->(DBSetOrder(1))
lRet := BS4->(DBSeek(xFilial("BS4")+M->BPT_CODINT+M->BPT_CODTAB+M->BPT_PREMED+M->BPT_PREAPR+M->BPT_PRELAB))


Return(lRet)
