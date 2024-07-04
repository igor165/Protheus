
#include "PROTHEUS.CH"
#include "PLSMGER.CH"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ As funcoes abaixo sao utilizadas no browse de Medicamento de uma operad.|
//³ Sao chamadas na validacao e exclusao de uma linha do Browse oGet31      |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSBPEVld  ³ Autor ³ Michele Tatagiba    ³ Data ³ 02.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a inclusao de uma linha no browse de Medicamentos da³±±
±±³          ³ Operadora                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBPEVld()

LOCAL lRet       := .T.
LOCAL lRetBPE    := .T.
LOCAL nPosScan   := 0 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se foi informado uma valor, e obrigatorio o codigo da Unidade de Medida |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->BPE_VLRMED <> 0 .And. Empty(M->BPE_CODDOC)
   MsgInfo("Informe uma Unidade de Medida de Valor para esse Medicamento.")
   Return(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se o nivel zero e valido                                       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->BPE_VLRMED == 0 .And. M->BPE_PERMED == 0 .And. Empty(M->BPE_NIVVAL)
   MsgInfo("Informe se o nivel zero e valido.")
   Return(.F.)
Endif
          
BNF->(DBSetOrder(2))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se existe alguma data de vigencia anterior a essa.             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BNF->(DBSeek(xFilial("BNF")+cCodigo+M->BPE_CODINT+M->BPE_CODTAB+M->BPE_PREMED+M->BPE_PREAPR+M->BPE_PRELAB))
   If M->BPE_VIGDE < BNF->BNF_DATDE
      MsgInfo("A data de vigencia do Medicamento e menor que a ultima data de vigencia "+dtoc(BNF->BNF_DATDE))
      Return(.F.)
   Else                  
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Caso a data de vigencia seja igual a data de, entao verifico o valor do Medicamento     |
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If M->BPE_VIGDE == BNF->BNF_DATDE
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Se o valor do Medicamento for diferente, nao consigo colocar a data final     |
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         If M->BPE_VLRMED <> BNF->BNF_VLRMED
       	    MsgInfo("A data de vigencia do Medicamento e igual a data da vigencia anterior.")
       	    Return(.F.)
         Else           
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Se o percentual do Medicamento for diferente, nao consigo colocar a data final|
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         
            If M->BPE_PERMED <> BNF->BNF_PERMED
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
         nPosScan := aScan(aVetBNF,{|x| x[2] == M->BPE_CODINT .And. x[3] == M->BPE_CODTAB .And. x[4] == M->BPE_PREMED ;
                                         .And. x[5] == M->BPE_PREAPR .And. x[6] == M->BPE_PRELAB })
         If nPosScan == 0
            aadd(aVetBNF,{cCodigo,M->BPE_CODINT,M->BPE_CODTAB,M->BPE_PREMED,M->BPE_PREAPR,M->BPE_PRELAB,M->BPE_SEQMED,M->BPE_VIGMED,M->BPE_VLRMED,M->BPE_PRTIPO,M->BPE_CODDOC,M->BPE_PERMED,M->BPE_NIVVAL,M->BPE_VIGDE,ctod("")})
         Else
            aVetBNF[nPosScan,7]   := M->BPE_SEQMED
            aVetBNF[nPosScan,8]   := M->BPE_VIGMED
            aVetBNF[nPosScan,9]   := M->BPE_VLRMED
            aVetBNF[nPosScan,10]  := M->BPE_PRTIPO
            aVetBNF[nPosScan,11]  := M->BPE_CODDOC
            aVetBNF[nPosScan,12]  := M->BPE_PERMED
            aVetBNF[nPosScan,13]  := M->BPE_NIVVAL
            aVetBNF[nPosScan,14]  := M->BPE_VIGDE
         Endif
            
         lRet := .T.
      Endif
   Endif
Else
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Crio uma nova vigencia do Medicamento                             |
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   nPosScan := aScan(aVetBNF,{|x| x[2] == M->BPE_CODINT .And. x[3] == M->BPE_CODTAB .And. x[4] == M->BPE_PREMED ;
                                  .And. x[5] == M->BPE_PREAPR .And. x[6] == M->BPE_PRELAB })
   If nPosScan == 0
      aadd(aVetBNF,{cCodigo,M->BPE_CODINT,M->BPE_CODTAB,M->BPE_PREMED,M->BPE_PREAPR,M->BPE_PRELAB,M->BPE_SEQMED,M->BPE_VIGMED,M->BPE_VLRMED,M->BPE_PRTIPO,M->BPE_CODDOC,M->BPE_PERMED,M->BPE_NIVVAL,M->BPE_VIGDE,ctod("")})
   Else
      aVetBNF[nPosScan,7]   := M->BPE_SEQMED
      aVetBNF[nPosScan,8]   := M->BPE_VIGMED
      aVetBNF[nPosScan,9]   := M->BPE_VLRMED
      aVetBNF[nPosScan,10]  := M->BPE_PRTIPO
      aVetBNF[nPosScan,11]  := M->BPE_CODDOC
      aVetBNF[nPosScan,12]  := M->BPE_PERMED
      aVetBNF[nPosScan,13]  := M->BPE_NIVVAL
      aVetBNF[nPosScan,14]  := M->BPE_VIGDE
   Endif
         
   lRet := .T.
Endif

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSBPEDel  ³ Autor ³ Michele Tatagiba    ³ Data ³ 22.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a exclusao de uma linha no browse de Medicamentos da³±±
±±³          ³ Operadora                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBPEDel()

LOCAL nPosScan
LOCAL nTamCols := 1
/*
If M->BPE_FLAG == "1"
   lRet := .F.
Endif
*/
nPosScan := aScan(aVetBNF,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And.;
            x[3] == oGet31:aCols[oGet31:Linha(),oGet31:PlRetPos("BPE_CODTAB")] .And.;
            x[4] == oGet31:aCols[oGet31:Linha(),oGet31:PlRetPos("BPE_PREMED")] .And.;
            x[5] == oGet31:aCols[oGet31:Linha(),oGet31:PlRetPos("BPE_PREAPR")] .And.;
            x[6] == oGet31:aCols[oGet31:Linha(),oGet31:PlRetPos("BPE_PRELAB")] })
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for exclusao da linha, tiro o dado do vetor                    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
If oGet31:aCols[oGet31:Linha(),Len(oGet31:aHeader)+1]
   If nPosScan <> 0
      aadd(aVetDelBNF,aVetBNF[nPosScan])
      nTamCols   := Len(aVetBNF)
      aDel(aVetBNF,nPosScan)
      aSize(aVetBNF,nTamCols-1)
   Endif
Else
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Se for retirar a exclusao, tenho que verificar se os dados daquele linha estavam no vetor   |
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   nPosScan := aScan(aVetBNF,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And.;
               x[3] == oGet31:aCols[oGet31:Linha(),oGet31:PlRetPos("BPE_CODTAB")] .And.;
               x[4] == oGet31:aCols[oGet31:Linha(),oGet31:PlRetPos("BPE_PREMED")] .And.;
               x[5] == oGet31:aCols[oGet31:Linha(),oGet31:PlRetPos("BPE_PREAPR")] .And.;
               x[6] == oGet31:aCols[oGet31:Linha(),oGet31:PlRetPos("BPE_PRELAB")] })
                
   If nPosScan <> 0
      aadd(aVetBNF,{cCodigo,cCodInt,oGet31:aCols[oGet31:Linha(),oGet31:PlRetPos("BPE_CODTAB")],;
                     oGet31:aCols[oGet31:Linha(),oGet31:PlRetPos("BPE_PREMED")],;
                     oGet31:aCols[oGet31:Linha(),oGet31:PlRetPos("BPE_PREAPR")],;
                     oGet31:aCols[oGet31:Linha(),oGet31:PlRetPos("BPE_PRELAB")],;
                     oGet31:aCols[oGet31:Linha(),oGet31:PlRetPos("BPE_SEQMED")],;
                     oGet31:aCols[oGet31:Linha(),oGet31:PlRetPos("BPE_VIGMED")],;
                     oGet31:aCols[oGet31:Linha(),oGet31:PlRetPos("BPE_VLRMED")],;
                     oGet31:aCols[oGet31:Linha(),oGet31:PlRetPos("BPE_PRTIPO")],;
                     oGet31:aCols[oGet31:Linha(),oGet31:PlRetPos("BPE_PERMED")],;
                     oGet31:aCols[oGet31:Linha(),oGet31:PlRetPos("BPE_NIVVAL")],;
                     oGet31:aCols[oGet31:Linha(),oGet31:PlRetPos("BPE_VIGDE")],;
                     ctod("")})
                                                    
      nTamCols   := Len(aVetDelBNF)
      aDel(aVetDelBNF,nPosScan)
      aSize(aVetDelBNF,nTamCols-1)
   Endif
Endif

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSBPEWhen ³ Autor ³ Michele Tatagiba    ³ Data ³ 22.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o X3_WHEN para os campos do BPE.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBPEWhen(cTipo)

LOCAL lRet    := .T.    
DEFAULT cTipo := ""
/*
If M->BPE_FLAG == "1" .And. Empty(cTipo)
   lRet := .F.
Endif
*/
If lRet .And. cTipo == "V" .And. !Empty(M->BPE_PERMED)
   lRet := .F.
Endif

If lRet .And. cTipo == "P" .And. !Empty(M->BPE_VLRMED)
   lRet := .F.
Endif                                  

If lRet .And. cTipo == "N" .And. (!Empty(M->BPE_PERMED) .Or. !Empty(M->BPE_VLRMED))
   lRet := .F.
Endif

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSBPERet  ³ Autor ³ Michele Tatagiba    ³ Data ³ 02.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a data da vigencia em aberto do Medicamento        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCampo - Campo que vai ser retornado                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBPERet(cCampo)
    
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
If BS4->(DBSeek(xFilial("BS4")+M->BPE_CODINT+M->BPE_CODTAB+M->BPE_PREMED+M->BPE_PREAPR+M->BPE_PRELAB))
   While !BS4->(EOF()) .And. xFilial("BS4")+M->BPE_CODINT+M->BPE_CODTAB+M->BPE_PREMED+M->BPE_PREAPR+M->BPE_PRELAB == BS4->(BS4_FILIAL+BS4_CODINT+BS4_TABMED+BS4_PREMED+BS4_PREAPR+BS4_PRELAB) .And.;
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
±±³Funcao    ³ PLSPOSBNF  ³ Autor ³ Michele Tatagiba    ³ Data ³ 02.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se ja existe vigencia para esse registro e se     ³±±
±±³          ³ essa esta e menor que a que esta sendo digitada            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPOSBNF()

LOCAL lRet := .T.

BNF->(DBSetOrder(2))
BNF->(DBSeek(xFilial("BNF")+cCodigo+cCodInt+M->BPE_CODTAB+M->BPE_PREMED+M->BPE_PREAPR+M->BPE_PRELAB))
If M->BPE_VIGDE < BNF->BNF_DATDE
   MsgInfo("A data de vigencia do Medicamento e menor que a data inicial("+dtoc(BNC->BNC_DATDE)+") da vigencia anterior.")
   lRet := .F.
Endif

Return(lRet)



Function PLSBPECpo()

LOCAL dDatIni := ctod("")
LOCAL lRet    := .T.

If Empty(M->BPE_CODTAB) .Or. Empty(M->BPE_PREMED) .Or. Empty(M->BPE_PREAPR) .Or. Empty(M->BPE_PRELAB)
   Return(.T.)
Endif

BS4->(DBSetOrder(1))
lRet := BS4->(DBSeek(xFilial("BS4")+M->BPE_CODINT+M->BPE_CODTAB+M->BPE_PREMED+M->BPE_PREAPR+M->BPE_PRELAB))


Return(lRet)
