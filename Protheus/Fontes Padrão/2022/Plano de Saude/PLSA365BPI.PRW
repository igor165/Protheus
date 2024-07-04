#INCLUDE "plsa365bpi.ch"

#include "PROTHEUS.CH"
#include "PLSMGER.CH"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ As funcoes abaixo sao utilizadas no browse de Filme para um Local de Atendim. |
//³ Sao chamadas na validacao e exclusao de uma linha do Browse oGet35            |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSBPIVld  ³ Autor ³ Michele Tatagiba    ³ Data ³ 22.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a inclusao de uma linha no browse de Filme do       ³±±
±±³          ³ Local de Atendimento                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBPIVld()

LOCAL lRet       := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se foi informado uma valor, e obrigatorio o codigo da Unidade de Medida |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se o nivel zero e valido                                       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*
BN9->(DBSetOrder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se existe alguma data de vigencia anterior a essa.             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BN9->(DBSeek(xFilial("BN9")+cCodigo+M->BPI_CODINT+M->BPI_CODLOC+M->BPI_CODFIL))
   If M->BPI_VIGDE < BN9->BN9_DATDE
      MsgInfo("A data de vigencia do Filme e menor que a ultima data de vigencia "+dtoc(BN9->BN9_DATDE))
      Return(.F.)
   Else                  
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Caso a data de vigencia seja igual a data de, entao verifico o valor da diaria|
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If M->BPI_VIGDE == BN9->BN9_DATDE
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Se o valor do filme for diferente, nao consigo colocar a data final |
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         If M->BPI_VLRFIL <> BN9->BN9_VLRFIL
       	    MsgInfo("A data de vigencia do Filme e igual a data da vigencia anterior.")
       	    Return(.F.)
         Else           
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Se o percentual da taxa for diferente, nao consigo colocar a data final |
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         
            If M->BPI_PERFIL <> BN9->BN9_PERFIL
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
         nPosScan := aScan(aVetBN9,{|x| x[2] == M->BPI_CODINT .And. x[3] == M->BPI_CODLOC .And. x[4] == M->BPI_CODFIL})
         If nPosScan == 0
            aadd(aVetBN9,{cCodigo,M->BPI_CODINT,M->BPI_CODLOC,M->BPI_CODFIL,M->BPI_VIGFIL,M->BPI_VLRFIL,M->BPI_PERFIL,M->BPI_NIVVAL,M->BPI_CODDOC,M->BPI_VIGDE,ctod("")})
         Else
            aVetBN9[nPosScan,5]  := M->BPI_VIGFIL
            aVetBN9[nPosScan,6]  := M->BPI_VLRFIL
            aVetBN9[nPosScan,7]  := M->BPI_PERFIL
            aVetBN9[nPosScan,8]  := M->BPI_NIVVAL
            aVetBN9[nPosScan,9]  := M->BPI_CODDOC
            aVetBN9[nPosScan,10] := M->BPI_VIGDE
         Endif
            
         lRet := .T.
      Endif
   Endif
Else
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Crio uma nova vigencia do filme                                   |
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   nPosScan := aScan(aVetBN9,{|x| x[2] == M->BPI_CODINT .And. x[3] == M->BPI_CODLOC .And. x[4] == M->BPI_CODFIL})
   If nPosScan == 0
      aadd(aVetBN9,{cCodigo,M->BPI_CODINT,M->BPI_CODLOC,M->BPI_CODFIL,M->BPI_VIGFIL,M->BPI_VLRFIL,M->BPI_PERFIL,M->BPI_NIVVAL,M->BPI_CODDOC,M->BPI_VIGDE,ctod("")})
   Else
      aVetBN9[nPosScan,5]  := M->BPI_VIGFIL
      aVetBN9[nPosScan,6]  := M->BPI_VLRFIL
      aVetBN9[nPosScan,7]  := M->BPI_PERFIL
      aVetBN9[nPosScan,8]  := M->BPI_NIVVAL
      aVetBN9[nPosScan,9]  := M->BPI_CODDOC
      aVetBN9[nPosScan,10] := M->BPI_VIGDE
   Endif
   
   lRet := .T.
Endif
*/
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSBPIDel  ³ Autor ³ Michele Tatagiba    ³ Data ³ 22.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a exclusao de uma linha no browse de Filme do       ³±±
±±³          ³ Local de Atendimento                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBPIDel()

LOCAL nPosScan
LOCAL nTamCols := 1

nPosScan := aScan(aVetBN9,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
            x[3] == oGet35:aCols[oGet35:Linha(),oGet35:PlRetPos("BPI_CODFIL")]})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for exclusao da linha, tiro o dado do vetor                    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
If oGet35:aCols[oGet35:Linha(),Len(oGet35:aHeader)+1]
   If nPosScan <> 0
      aadd(aVetDelBN9,aVetBN9[nPosScan])
      nTamCols   := Len(aVetBN9)
      aDel(aVetBN9,nPosScan)
      aSize(aVetBN9,nTamCols-1)
   Endif
Else
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Se for retirar a exclusao, tenho que verificar se os dados daquele linha estavam no vetor   |
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   nPosScan := aScan(aVetBN9,{|x| x[1] == cCodigo .And. x[2] == cCodInt .And. x[3] == cCodLoc .And.;
                x[3] == oGet35:aCols[oGet35:Linha(),oGet35:PlRetPos("BPI_CODFIL")]})
                
   If nPosScan <> 0
      aadd(aVetBN9,{cCodigo,cCodInt,cCodLoc,oGet35:aCols[oGet35:Linha(),oGet35:PlRetPos("BPI_CODFIL")],;
                     oGet35:aCols[oGet35:Linha(),oGet35:PlRetPos("BPI_VIGFIL")],;
                     oGet35:aCols[oGet35:Linha(),oGet35:PlRetPos("BPI_VLRFIL")],;
                     oGet35:aCols[oGet35:Linha(),oGet35:PlRetPos("BPI_PERFIL")],;
                     oGet35:aCols[oGet35:Linha(),oGet35:PlRetPos("BPI_NIVVAL")],;
                     oGet35:aCols[oGet35:Linha(),oGet35:PlRetPos("BPI_CODDOC")],;
                     oGet35:aCols[oGet35:Linha(),oGet35:PlRetPos("BPI_VIGDE")],;
                     ctod("")})
                                                    
      nTamCols   := Len(aVetDelBN9)
      aDel(aVetDelBN9,nPosScan)
      aSize(aVetDelBN9,nTamCols-1)
   Endif
Endif

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSBPIWhen ³ Autor ³ Michele Tatagiba    ³ Data ³ 22.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o X3_WHEN para os campos do BPI.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBPIWhen(cTipo)

LOCAL lRet    := .T.
DEFAULT cTipo := ""

If lRet .And. cTipo == "V" .And. !Empty(M->BPI_PERFIL)
   lRet := .F.
Endif

If lRet .And. cTipo == "P" .And. !Empty(M->BPI_VLRFIL)
   lRet := .F.
Endif

If lRet .And. cTipo == "N" .And. (!Empty(M->BPI_PERFIL) .Or. !Empty(M->BPI_VLRFIL))
   lRet := .F.
Endif

Return(lRet)

                                 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSBPIRet  ³ Autor ³ Michele Tatagiba    ³ Data ³ 02.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a data da vigencia em aberto do Filme              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCampo - Campo que vai ser retornado                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBPIRet(cCampo)
    
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
If BP8->(DBSeek(xFilial("BP8")+M->BPI_CODINT+M->BPI_CODFIL))
   While !BP8->(EOF()) .And. xFilial("BP8")+M->BPI_CODINT+M->BPI_CODFIL == BP8->(BP8_FILIAL+BP8_CODINT+BP8_CODIGO) .And.;
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
±±³Funcao    ³ PLSPOSBN9  ³ Autor ³ Michele Tatagiba    ³ Data ³ 02.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se ja existe vigencia para esse registro e se     ³±±
±±³          ³ essa esta e menor que a que esta sendo digitada            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSPOSBN9()

LOCAL lRet := .T.

BN9->(DBSetOrder(2))
BN9->(DBSeek(xFilial("BN9")+cCodigo+cCodInt+cCodLoc+M->BPI_CODFIL))
If M->BPI_VIGDE < BN9->BN9_DATDE
   MsgInfo(STR0001+dtoc(BN9->BN9_DATDE)+STR0002) //"A data de vigencia do Filme e menor que a data inicial("###") da vigencia anterior."
   lRet := .F.
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSBPIPad  ³ Autor ³ Michele Tatagiba    ³ Data ³ 06.11.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se o filme e padrao                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBPIPad(cOpc)

LOCAL lRet   := .T.
LOCAL nInd   := 1
LOCAL nQtd   := 0

If cOpc == "1"
   While nInd <= Len(oGet35:aCols) .And. lRet

       If (oGet35:aCols[nInd,oGet35:PlRetPos("BPI_CODINT")] == cCodInt .And.;
          oGet35:aCols[nInd,oGet35:PlRetPos("BPI_CODLOC")] == cCodLoc .And.;
          oGet35:aCols[nInd,oGet35:PlRetPos("BPI_PADRAO")] == "1") .Or.;
          (nInd == oGet35:Linha() .And. oGet35:aCols[nInd,oGet35:PlRetPos("BPI_PADRAO")] == "0")
          If MsgYesNo(STR0003) //"Ja existe outro filme cadastrado como padrao. Deseja altera-lo?"
             oGet35:aCols[nInd,oGet35:PlRetPos("BPI_PADRAO")] := "0"
             oGet35:Atualiza()
          Else
             lRet := .F.
          Endif
       Endif

   nInd ++
   Enddo
Endif

If cOpc == "0"
   While nInd <= Len(oGet35:aCols)

       If (oGet35:aCols[nInd,oGet35:PlRetPos("BPI_CODINT")] == cCodInt .And.;
          oGet35:aCols[nInd,oGet35:PlRetPos("BPI_CODLOC")] == cCodLoc .And.;
          oGet35:aCols[nInd,oGet35:PlRetPos("BPI_PADRAO")] == "0") .Or.;
          (nInd == oGet35:Linha() .And. oGet35:aCols[nInd,oGet35:PlRetPos("BPI_PADRAO")] == "1")
          nQtd ++
       Endif

   nInd ++
   Enddo
      
   If nQtd == Len(oGet35:aCols) .Or. Empty(oGet35:aCols[oGet35:Linha(),oGet35:PlRetPos("BPI_PADRAO")])
      If MsgYesNo(STR0004) //"Nao existe nenhum filme cadastrado como Padrao. Deseja tornar esse padrao?"
         M->BPI_PADRAO := "1"
      Else
         lRet := .F.
      Endif
   Endif
Endif


Return(lRet)
