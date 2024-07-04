
#include "PROTHEUS.CH"
#include "PLSMGER.CH"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ As funcoes abaixo sao utilizadas no browse de Filme para uma operadora. |
//³ Sao chamadas na validacao e exclusao de uma linha do Browse oGet38      |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSBPBVld  ³ Autor ³ Michele Tatagiba    ³ Data ³ 22.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a inclusao de uma linha no browse de Filme da       ³±±
±±³          ³ Operadora                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBPBVld()

LOCAL lRet       := .T.
LOCAL lRetBPB    := .T.
LOCAL nPosScan   := 0 
                             
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se foi informado uma valor, e obrigatorio o codigo da Unidade de Medida |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->BPB_VLRFIL <> 0 .And. Empty(M->BPB_CODDOC)
   MsgInfo("Informe uma Unidade de Medida de Valor para esse Filme.")
   Return(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se o nivel zero e valido                                       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->BPB_VLRFIL == 0 .And. M->BPB_PERFIL == 0 .And. Empty(M->BPB_NIVVAL)
   MsgInfo("Informe se o nivel zero e valido.")
   Return(.F.)
Endif
          
BNC->(DBSetOrder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se existe alguma data de vigencia anterior a essa.             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BNC->(DBSeek(xFilial("BNC")+cCodigo+M->BPB_CODINT+M->BPB_CODFIL))
   If M->BPB_VIGDE < BNC->BNC_DATDE
      MsgInfo("A data de vigencia do Filme e menor que a ultima data de vigencia "+dtoc(BNC->BNC_DATDE))
      Return(.F.)
   Else                  
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Caso a data de vigencia seja igual a data de, entao verifico o valor da diaria|
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If M->BPB_VIGDE == BNC->BNC_DATDE
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Se o valor do filme for diferente, nao consigo colocar a data final |
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         If M->BPB_VLRFIL <> BNC->BNC_VLRFIL
       	    MsgInfo("A data de vigencia do Filme e igual a data da vigencia anterior.")
       	    Return(.F.)
         Else           
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Se o percentual da taxa for diferente, nao consigo colocar a data final |
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         
            If M->BPB_PERFIL <> BNC->BNC_PERFIL
         	   MsgInfo("A data de vigencia do filme e igual a data da vigencia anterior.")
        	   Return(.F.)
            Else            
        	   lRet := .T.
        	Endif
         Endif
      Else
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Crio uma nova vigencia de filme                                   |
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         nPosScan := aScan(aVetBNC,{|x| x[2] == M->BPB_CODINT .And. x[3] == M->BPB_CODFIL})
         If nPosScan == 0
            aadd(aVetBNC,{cCodigo,M->BPB_CODINT,M->BPB_CODFIL,M->BPB_SEQFIL,M->BPB_VIGFIL,M->BPB_VLRFIL,M->BPB_PERFIL,M->BPB_NIVVAL,M->BPB_CODDOC,M->BPB_VIGDE,ctod("")})
         Else
            aVetBNC[nPosScan,4]  := M->BPB_SEQFIL
            aVetBNC[nPosScan,5]  := M->BPB_VIGFIL
            aVetBNC[nPosScan,6]  := M->BPB_VLRFIL
            aVetBNC[nPosScan,7]  := M->BPB_PERFIL
            aVetBNC[nPosScan,8]  := M->BPB_NIVVAL
            aVetBNC[nPosScan,9]  := M->BPB_CODDOC
            aVetBNC[nPosScan,10] := M->BPB_VIGDE
         Endif
            
         lRet := .T.
      Endif
   Endif
Else
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Crio uma nova vigencia do filme                                   |
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   nPosScan := aScan(aVetBNC,{|x| x[2] == M->BPB_CODINT .And. x[3] == M->BPB_CODFIL})
   If nPosScan == 0
      aadd(aVetBNC,{cCodigo,M->BPB_CODINT,M->BPB_CODFIL,M->BPB_SEQFIL,M->BPB_VIGFIL,M->BPB_VLRFIL,M->BPB_PERFIL,M->BPB_NIVVAL,M->BPB_CODDOC,M->BPB_VIGDE,ctod("")})
   Else
      aVetBNC[nPosScan,4]  := M->BPB_SEQFIL
      aVetBNC[nPosScan,5]  := M->BPB_VIGFIL
      aVetBNC[nPosScan,6]  := M->BPB_VLRFIL
      aVetBNC[nPosScan,7]  := M->BPB_PERFIL
      aVetBNC[nPosScan,8]  := M->BPB_NIVVAL
      aVetBNC[nPosScan,9]  := M->BPB_CODDOC
      aVetBNC[nPosScan,10] := M->BPB_VIGDE
   Endif
            
   lRet := .T.
Endif

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSBPBDel  ³ Autor ³ Michele Tatagiba    ³ Data ³ 22.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a exclusao de uma linha no browse de Filme da       ³±±
±±³          ³ Operadora                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBPBDel()

LOCAL nPosScan
LOCAL nTamCols := 1

/*
If M->BPB_FLAG == "1"
   lRet := .F.
Endif
*/

nPosScan := aScan(aVetBNC,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And.;
            x[3] == oGet28:aCols[oGet28:Linha(),oGet28:PlRetPos("BPB_CODFIL")]})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for exclusao da linha, tiro o dado do vetor                    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
If oGet28:aCols[oGet28:Linha(),Len(oGet28:aHeader)+1]
   If nPosScan <> 0
      aadd(aVetDelBNC,aVetBNC[nPosScan])
      nTamCols   := Len(aVetBNC)
      aDel(aVetBNC,nPosScan)
      aSize(aVetBNC,nTamCols-1)
   Endif
Else
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Se for retirar a exclusao, tenho que verificar se os dados daquele linha estavam no vetor   |
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   nPosScan := aScan(aVetBNC,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And.;
                x[3] == oGet28:aCols[oGet28:Linha(),oGet28:PlRetPos("BPB_CODFIL")]})
                
   If nPosScan <> 0
      aadd(aVetBNC,{cCodigo,cCodInt,oGet28:aCols[oGet28:Linha(),oGet28:PlRetPos("BPB_CODFIL")],;
                     oGet28:aCols[oGet28:Linha(),oGet28:PlRetPos("BPB_SEQFIL")],;
                     oGet28:aCols[oGet28:Linha(),oGet28:PlRetPos("BPB_VIGFIL")],;
                     oGet28:aCols[oGet28:Linha(),oGet28:PlRetPos("BPB_VLRFIL")],;
                     oGet28:aCols[oGet28:Linha(),oGet28:PlRetPos("BPB_PERFIL")],;
                     oGet28:aCols[oGet28:Linha(),oGet28:PlRetPos("BPB_NIVVAL")],;
                     oGet28:aCols[oGet28:Linha(),oGet28:PlRetPos("BPB_CODDOC")],;
                     oGet28:aCols[oGet28:Linha(),oGet28:PlRetPos("BPB_VIGDE")],;
                     ctod("")})
                                                    
      nTamCols   := Len(aVetDelBNC)
      aDel(aVetDelBNC,nPosScan)
      aSize(aVetDelBNC,nTamCols-1)
   Endif
Endif

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSBPBWhen ³ Autor ³ Michele Tatagiba    ³ Data ³ 22.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o X3_WHEN para os campos do BPB.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBPBWhen(cTipo)

LOCAL lRet    := .T.
DEFAULT cTipo := ""

/*
If M->BPB_FLAG == "1" .And. Empty(cTipo)
   lRet := .F.
Endif
*/

If lRet .And. cTipo == "V" .And. !Empty(M->BPB_PERFIL)
   lRet := .F.
Endif

If lRet .And. cTipo == "P" .And. !Empty(M->BPB_VLRFIL)
   lRet := .F.
Endif

If lRet .And. cTipo == "N" .And. (!Empty(M->BPB_PERFIL) .Or. !Empty(M->BPB_VLRFIL))
   lRet := .F.
Endif

Return(lRet)

            
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSBPBRet  ³ Autor ³ Michele Tatagiba    ³ Data ³ 02.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a data da vigencia em aberto do Filme              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCampo - Campo que vai ser retornado                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBPBRet(cCampo)
    
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
      
BP8->(DBSetOrder(1))
If BP8->(DBSeek(xFilial("BP8")+M->BPB_CODINT+M->BPB_CODFIL))
   While !BP8->(EOF()) .And. xFilial("BP8")+M->BPB_CODINT+M->BPB_CODFIL == BP8->(BP8_FILIAL+BP8_CODINT+BP8_CODIGO) .And.;
         !lRet
         If Empty(BP8->BP8_VIGATE)
            cConteu := &(cCampo)
            lRet    := .T.
         Endif
   BP8->(DBSkip())
   Enddo
Endif

Return(cConteu)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPOSBNC  ³ Autor ³ Michele Tatagiba    ³ Data ³ 02.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se ja existe vigencia para esse registro e se     ³±±
±±³          ³ essa esta e menor que a que esta sendo digitada            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPOSBNC()

LOCAL lRet := .T.

BNC->(DBSetOrder(2))
BNC->(DBSeek(xFilial("BNC")+cCodigo+cCodInt+M->BPB_CODFIL))
If M->BPB_VIGDE < BNC->BNC_DATDE
   MsgInfo("A data de vigencia do Filme e menor que a data inicial("+dtoc(BNC->BNC_DATDE)+") da vigencia anterior.")
   lRet := .F.
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSBPBPad  ³ Autor ³ Michele Tatagiba    ³ Data ³ 06.11.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se o filme e padrao                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBPBPad(cOpc)

LOCAL lRet   := .T.
LOCAL nInd   := 1
LOCAL nQtd   := 0

If cOpc == "1"
   While nInd <= Len(oGet28:aCols) .And. lRet

       If (oGet28:aCols[nInd,oGet28:PlRetPos("BPB_CODINT")] == cCodInt .And.;
          oGet28:aCols[nInd,oGet28:PlRetPos("BPB_PADRAO")] == "1") .Or.;
          (nInd == oGet28:Linha() .And. oGet28:aCols[nInd,oGet28:PlRetPos("BPB_PADRAO")] == "0")
          If MsgYesNo("Ja existe outro filme cadastrado como padrao. Deseja altera-lo?")
             oGet28:aCols[nInd,oGet28:PlRetPos("BPB_PADRAO")] := "0"
             oGet28:Atualiza()
          Else
             lRet := .F.
          Endif
       Endif

   nInd ++
   Enddo
Endif

If cOpc == "0"
   While nInd <= Len(oGet28:aCols)

       If (oGet28:aCols[nInd,oGet28:PlRetPos("BPB_CODINT")] == cCodInt .And.;
          oGet28:aCols[nInd,oGet28:PlRetPos("BPB_PADRAO")] == "0") .Or.;
          (nInd == oGet28:Linha() .And. oGet28:aCols[nInd,oGet28:PlRetPos("BPB_PADRAO")] == "1")
          nQtd ++
       Endif

   nInd ++
   Enddo
      
   If nQtd == Len(oGet28:aCols) .Or. Empty(oGet28:aCols[oGet28:Linha(),oGet28:PlRetPos("BPB_PADRAO")])
      If MsgYesNo("Nao existe nenhum filme cadastrado como Padrao. Deseja tornar esse padrao?")
         M->BPB_PADRAO := "1"
      Else
         lRet := .F.
      Endif
   Endif
Endif


Return(lRet)
