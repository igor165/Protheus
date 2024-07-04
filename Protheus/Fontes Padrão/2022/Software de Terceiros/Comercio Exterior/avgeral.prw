/*
Programa        : AVXGERAL.PRW
Objetivo        :
Autor           : Average Tecnologia S/A
Data/Hora       : 04/12/98 15:59
Obs.            :
*/

//#include "FiveWin.ch"
#include "average.ch"
#include "AVGERAL.CH"
#include "ap5mail.ch"
#include "tbiconn.ch"
#Include "EEC.ch"
#INCLUDE "fileio.ch"  
#INCLUDE "shell.ch"
#Include "TOPCONN.ch"

#define CRW_NewPage STR0116
#define EEM_DV  "5"    //Nota de Devolução


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declara variavel estatica, utilizada na funcao IsYear4()             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static nYear
Static lSX3Buffer := .F.
Static lTETempBanco
//estática usada na função EasyEntryPoint
//Static __aEntryPoint:= {}
//Concentrados todos os buffer num unico hashmap
Static oAllBuffers
#DEFINE BUFFER_GET 2
#DEFINE BUFFER_SET 3
#DEFINE BUFFER_DEL 5
#DEFINE BUFFER_LIST 6
/*
Funcao          : E_MSG(cMsg,nTempo,lLimpa,cTitulo,aLinCol)
Parametros      :       cMsg    := mensagem
                                nTempo  := tempo em que a mensagem fica ativa
                                lLimpa  := manter a mensagem ativa ou limpar area usada
                                cTitulo := titulo do dialogo da mensagem
                                aLinCol := vetor com coordenadas
Retorno         : NIL
Objetivos       :
Autor           : AVERAGE
Data/Hora       :
Revisao         :
Obs.            :
*/
Function E_Msg(cMsg,nTempo,lLimpa,cTitulo,aLinCol)
IF(nTempo==NIL,nTempo:=0,)
If nTempo > 0
   MsgInfo(OemToAnsi(cMsg),If(cTitulo=NIL,STR0001,cTitulo)) //"Informação"
EndIf
Return NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³E_GravaTRB ³ Autor ³ AVERAGE-MJBARROS     ³ Data ³ 10/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do Arquivo de Trabalho a partir de uma area       ³±±
±±³          ³ qualquer. Esta funcao somente pode ser utilizada quando    ³±±
±±³          ³ houver uma perfeita correspondencia entre os campos do     ³±±
±±³          ³ arquivo principal (do SX3) e o arquivo de trabalho.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ E_GravaTRB()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Alias do arquivo base, bloco de posicionamento (seek),     ³±±
±±³          ³ bloco de condicao "para" e bloco de "enquanto"             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION E_GravaTRB(cAliasArq,bSeek,bFor,bWhile,aSemSx3,bRecNo,cAliasTRB)
LOCAL xVar, bVar, bTRB, aTRB:={}, cOldAlias:=ALIAS()
IF(cAliasTRB==NIL,cAliasTRB:="TRB",)
DbSelectArea(cAliasTRB)

// gera tabela com os campos a serem atualizados no arquivo do sistema, por
// isso despreza campos virtuais, que nao fazem parte da estrutura

AEVAL(aHeader,{|acHeader| xVar:=Trim(acHeader[2]),;
                          bVar:=FIELDWBLOCK(xVar,SELECT(cAliasArq)),;
                          bTRB:=FIELDWBLOCK(xVar,SELECT(cAliasTRB)),;
                          If(acHeader[10] # "V",AADD(aTRB,{bTRB,bVar}),) })

If aSemSx3 # NIL
   aEval(aSemSx3,{|x|bVar:=FIELDWBLOCK(x[1],SELECT(cAliasArq)),;
                     bTRB:=FIELDWBLOCK(x[1],SELECT(cAliasTRB)),;
                     If((cAliasArq)->(FieldPos(x[1]))>0,AADD(aTRB,{bTRB,bVar}),) })
Endif

EVAL(bSeek)

(cAliasArq)->(DBEVAL({||(cAliasTRB)->(DBAPPEND()),;
                        AEVAL(aTRB,{|abTRB| EVAL(abTRB[1],EVAL(abTRB[2]))}),;
                        If(bRecNo#NIL,Eval(bRecNo,(cAliasArq)->(RecNo()),cAliasTRB),)},;
                      bFor,bWhile))

DbSelectArea(cOldAlias)

RETURN ( (cAliasTRB)->(EasyRecCount(cAliasTRB)) > 0 )
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³E_EraseArq ³ Autor ³ AVERAGE-MJBARROS     ³ Data ³ 10/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apaga Arquivo de Trabalho                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ E_EraseArq(NomeArq) - a area do arquivo deve ser a corrente³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nome do Arquivo de Trabalho                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico
    Revisão: wfs - mar/2017
             Adaptado para realizar a chamada do EECEraseArq
             O EECEraseArq() executará o E_EraseArq() caso o ambiente não
             esteja configurado para reaproveitamento dos arquivos
             temporários.                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION E_EraseArq(cNomArq,cIndice2,cIndice3, lEECEraseArq, lForcaBanc)
Default lEECEraseArq:= .F.
Default lForcaBanc  := TETempBanco()

   If ValType(lEECEraseArq) <> "L"
      lEECEraseArq:= .F.
   EndIf

   If lEECEraseArq
      EECEraseArq(cNomArq,cIndice2,cIndice3)
   Else
      If (lForcaBanc .And. AvTmpBanco(Alias())) //THTS - 20/10/2017 - AvTmpBanco verifica se a work works tem indices que nao cabem no banco
         TETempBuffer(cNomArq,,, .T.)
      Else
         dbcloseArea()
         // Destroi o arquivo TRB da GetDadDb()
         If ValType(cNomArq) == "C" .AND. ValType(GetDBExtension()) == "C" .AND. ValType(OrdBagExt()) = "C"   //AAF - 10/12/2013
            FErase(cNomArq+GetDBExtension())
            FErase(cNomArq+".FPT")
            FErase(cNomArq+TEOrdBagExt())
            IF(cIndice2#NIL,FErase(cIndice2+TEOrdBagExt()),)
            IF(cIndice3#NIL,FErase(cIndice3+TEOrdBagExt()),)
         EndIf
      EndIf
      DbSelectArea("SX3") // sempre deve haver uma area selecionada
   EndIf
RETURN .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³E_Grava   ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 21.08.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³E_Grava(cAlias,lInclui)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias = alias do arquivo no SX3                           ³±±
±±³          ³ lInclui= .T. cria novo registro, bloqueia registro atual   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
FUNCTION E_Grava(cAlias,lInclui,bEspecial)

//LOCAL nInd, nCampos
LOCAL nAlias := Select()
//LOCAL bVar,lRET:=.T.
Local lRet := .t.
Local i, cVar, cVar1

Begin Sequence
   dbSelectArea(cAlias)
   // Alterado por Heder M Oliveira - 8/19/1999
   IF !RecLock(cAlias,lInclui)
      lRET:=.F.
      BREAK
   ENDIF

   AvReplace("M",cAlias)

   If(bEspecial#NIL,Eval(bEspecial),)

   //WFS 30/11/2009
   //Gravação de campos memos
   If Type("aMemos") == "A"
      For i:= 1 To Len(aMemos)
         cVar := aMemos[i][2]
         cVar1:= aMemos[i][1]
         If IsMemVar(cVar) .And. &cVar <> Nil         
            MSMM(&cVar1, AvSx3(aMemos[i][2], AV_TAMANHO),, &cVar, 1,,, cAlias, aMemos[i][1])
         EndIf
      Next
   EndIf

   (cAlias)->(MsUnlock())
End Sequence
Select(nAlias)
RETURN lRET

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³E_CriaTrab ³ Autor ³ AVERAGE-MJBARROS     ³ Data ³ 10/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria Arquivo de Trabalho                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ E_CriaTab(cAlias)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aCampos,                                                   ³±±
±±³          ³ aHeader = devem estar definidas como PRIVATE               ³±±
±±³          ³ Alias   = Arquivo Base p/ geracao quando todos os campos de³±±
±±³          ³(opcional) aCampos pertencerem ao mesmo arquivo; caso       ³±±
±±³          ³           contrario nao deve ser informado e a funcao bus- ³±±
±±³          ³           cara no SX3 de acordo com o prefixo do campo     ³±±
±±³          ³ aSemSX3 = campos que nao estao no SX3, mas devem ser       ³±±
±±³          ³           incluidos no arquivo de trabalho                 ³±±
±±³          ³ cAliasWork = alias do arquivo de trabalho (opcional)       ³±±
±± ³         ³ aCposNewStru = utiliza uma estrutura informada, ao invés   ³±±
±± ³         ³                dos valores no SX3                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico
    Revisão: wfs - mar/2017
             Adaptado para realizar a chamada do EECCRIATRAB()
             A função EECCRIATRAB() executará a função E_CriaTrab() quando
             o ambiente não estiver configurado para reaproveitar os
             arquivos temporários.                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function E_CriaTrab(cAlias,aSemSX3,cAliasWork,aHeaderP,lDelete, aCposNewStru, lEECCriaTrab, lForcaBanc)
LOCAL aCamposTRB:={}, cNomArq, aCamposMemo:={}, i := 0
Local nPos
Local oTemp //RMD - 04/09/17
Local cNextAlias := GetNextAlias()
Default aCposNewStru := {}
Default lEECCriaTrab:= .F.
Default lForcaBanc  := TETempBanco()

   If lEECCriaTrab
     cNomArq:= EECCriaTrab(cAlias,aSemSX3,cAliasWork,aHeaderP,lDelete, aCposNewStru)
   Else

      IF(aHeaderP<>NIL,aHeader:=aHeaderP,)//AWR
      IF TYPE("aCampos")="U" //MCF - 24/02/2016
         If !Empty(cAlias)
            aCampos := ARRAY((cAlias)->(FCOUNT()))
         Else
            aCampos := {}
         EndIf
      Endif
      //IF(TYPE("aCampos")="U",aCampos:= ARRAY((cAlias)->(FCOUNT())),)//AWR
      IF(TYPE("aHeader")="U",aHeader:={},)//AWR

      //Cria WorkFile para GetDadDB()
      IF(cAliasWork==NIL,cAliasWork:="TRB",)
      If !Empty(cAlias)
         aCamposTRB:= CriaEstru(aCampos,@aHeader,cAlias)
      Else
         If (Len(aCampos) > 0 .And. aScan(aCampos,{ |x| ValType(x) <> "C" }) == 0)
            aCamposTRB:= CriaEstru(aCampos,@aHeader,Nil)
         EndIf
      EndIf

      If(aSemSX3 # NIL,AEval(aSemSX3,{|campo| aCampo := campo, if(aScan(aCamposTRB,{|X| AllTrim(X[1]) == AllTrim(aCampo[1])}) == 0,AAdd(aCamposTRB,aClone(aCampo)),) }),)

      //by CAF 14/08/2001 10:55
      IF (lDelete = NIL .And. !lForcaBanc) //AWR
         IF aScan(aCamposTRB,{|x| Upper(Alltrim(x[1])) == "DELETE"}) == 0 .And. aScan(aCamposTRB,{|x| Upper(Alltrim(x[1])) == "DBDELETE"}) == 0
            //If !TETempBanco()
               //AAdd(aCamposTRB,{"DELETE","L",1,0})  //17/07/2018 - Nopado por NCF para histórico - a condição foi mudada pra baixo com verificação do LocalFiles
            //Else
            //   AAdd(aCamposTRB,{"DBDELETE","L",1,0}) //RMD - 04/09/17 - "DELETE" é uma palavra reservada, passa a utilizar "DBDELETE"
            //EndIf
            If "SQLITE" $ Upper(RealRDD())
               AAdd(aCamposTRB,{"DBDELETE","L",1,0}) //RMD - 04/09/17 - "DELETE" é uma palavra reservada, passa a utilizar "DBDELETE"
            Else
               AAdd(aCamposTRB,{"DELETE","L",1,0})
            EndIf
         Endif
      Endif

      For i := 1 to Len(aCamposTRB)
         nPos := ASCAN(aCamposTRB,{|Campo|Campo[2]=="M"})
         If nPos > 1
            Aadd(aCamposMemo,aCamposTRB[nPos])
            ADEL(aCamposTRB,nPos)
            ASIZE(aCamposTRB,LEN(aCamposTRB)-1)
         EndIf
      Next

      For i := 1 to Len(aCamposMemo)
          Aadd(aCamposTRB,aCamposMemo[i])
      Next

      //Altera a estrutura de um campo obtido pelo SX3, pela estrutura informada pelo usuário
      For i := 1 to Len(aCposNewStru)
         nPos := AScan(aCamposTRB,{|Campo|Campo[1] == aCposNewStru[i][1]})
         If nPos > 0
            aCamposTRB[nPos] := aCposNewStru[i]
         EndIf
      Next

      If (lForcaBanc .And. AvTmpBanco(cAliasWork))//THTS - 20/10/2017 - AvTmpBanco verifica se a work works tem indices que nao cabem no banco
         TETempBuffer(, cAliasWork, ,.T.)
         oTemp := FWTemporaryTable():New(cNextAlias, aCamposTRB)
         oTemp:Create()
         cNomArq := StrTran(oTemp:GetRealName(), ".", "")
         TETempBuffer(cNomArq, cAliasWork, oTemp)
         (cNextAlias)->(dbCloseArea())
         TETempReOpen(cNomArq,cNextAlias,cAliasWork)
      /*Else
         //Cria arquivo de trabalho e indice
         cNomArq := CriaTrab(aCamposTRB,.T.)
         dbUseArea(.T.,,(cNomArq),cAliasWork, .F. , .F. )*/
      EndIf

   EndIf

Return cNomArq
/*
Funcao      : AvVldUn(cUN)
Parametros  : cUN   : Unidade a ser validada
Retorno     : lRet  : Retorna True para informar que a unidade é a KG
Objetivos   : Validar a unidade de medida se é KG ou 10
Autor       : Miguel Prado Gontijo - MPG
Data/Hora   : 06/02/2018
*/
Function AvVldUn(cUN)
Local lRet := .F.

If Upper(Alltrim(cUN)) == "KG" .or. Alltrim(cUN) == "10"
    lRet := .T.
EndIf

Return lRet

/*
Funcao      : AvTmpBanco
Parametros  : cTmpWork : Alias temporario a ser criado
Retorno     : lRet     : Indica se o alias pode ser criado no banco de dados (.T.) ou deve ser criado na System (.F.)
Objetivos   : Verificar se o temporario pode ser criado no banco de dados, pois temos casos de work com indices que não podem ser criados no banco de dados
Autor       : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora   : 24/10/2017
*/
Static Function AvTmpBanco(cTmpWork)
Local lRet := .T.
/*
Local lTmpLocDIe := GetApoInfo("EICADICAO_RDM.PRW")[4]  <  CTOD("06/09/2018") .Or. GetApoInfo("EICDI500.PRW")[4]  <  CTOD("06/09/2018")
Local lTmpLocDIm := GetApoInfo("EICADICAO_RDM.PRW")[4]  <  CTOD("06/09/2018")
Local lTmpLocNFe := GetApoInfo("EICDI154.PRW")[4]       <  CTOD("06/09/2018")

If IsInCallStack("DI500CriaWork") .And. (Upper(cTmpWork) == "WORK_SW8" .Or. Upper(cTmpWork) == "WORK_EIJ") .And. lTmpLocDIe // Adicao no Embarque
    lRet := .F.
EndIf

If lRet .And. IsInCallStack("AdicaoTela") .And. (Upper(cTmpWork) == "WORKCAP_SW8" .Or. Upper(cTmpWork) == "WORKITENS_SW8") .And. lTmpLocDIm //Adicao no Desembaraco
    lRet := .F.
EndIf

If lRet .And. (IsInCallStack("DI154NFE") .Or. IsInCallStack("EICCO100")) .And. (Upper(cTmpWork) == "WORK1" .Or. Upper(cTmpWork) == "WORK2") .And. lTmpLocNFe //Recebimento de Importacao
    lRet := .F.
EndIf
*/
Return lRet

Function SetTeTempBanco()
    // MPG- 23/08/2018 - alteração para possiblitar manter os arquivos no banco quando usado o ponto de entrada eeckeepfiles retornsando sempre true
    /*if IsMemVar("__KeepUsrFiles") .and. __KeepUsrFiles   //NCF - 23/10/2018 - Parâmetro obsoleto
        putmv("MV_EASYTMP",.T.) //setmv("MV_EASYTMP",.T.)
    endif*/

    lTETempBanco := AllwaysTrue() //EasyGParam("MV_EASYTMP",,.F.)//THTS - 25/09/2017 - Verifica se os temporarios devem ser criados no banco de dados ou nao.
                                  //NCF - 23/10/2018 - Arquivos temporários no banco passa a ser padrão e não mais configurável.
Return Nil

/*
Função  : TETempBanco()
Autor   : Rodrigo Mendes Diaz
Data    : 01/06/17
Objetivo: Definir se o ambiente está configurado para o uso temporários no banco de dados
*/
Function TETempBanco()
Local lRet := .F.

    If ValType(lTETempBanco) == "U" .Or. (!lTETempBanco .And. IsMemVar("__KeepUsrFiles") .and. __KeepUsrFiles)
        SetTeTempBanco()
    EndIf

    lRet := lTETempBanco

Return lRet

/*
Função  : TETempBuffer()
Autor   : Rodrigo Mendes Diaz
Data    : 01/06/17
Objetivo: Registrar em variável estática os arquivos temporários criados
*/
//Static aTempBuffer := {}
Function TETempBuffer(cNome, cAlias, oTemp, lDelete)
Local nPos, aTempBuffer
Default cNome := ""
Default cAlias := ""
Default lDelete := .F.

   If !EasyGetBuffers('TETempBuffer','aTempBuffer',@aTempBuffer)
      aTempBuffer := {}
      EasySetBuffers('TETempBuffer','aTempBuffer',@aTempBuffer)
   EndIf

   If (nPos := aScan(aTempBuffer, {|x| Upper(x[1]) == Upper(cNome) })) > 0 .Or. (!Empty(cAlias) .And. (nPos := aScan(aTempBuffer, {|x| Upper(x[2]) == Upper(cAlias) })) > 0)
         If Select(aTempBuffer[nPos][2]) > 0
               (aTempBuffer[nPos][2])->(dbCloseArea())
      EndIf
      if !intransact()
         aTempBuffer[nPos][3]:Delete()
      EndIf
      //TcSqlExec("DROP TABLE " + aTempBuffer[nPos][3]:GetRealName())
      If !lDelete
         aTempBuffer[nPos] :=  {cNome, cAlias, oTemp}
      Else
         aDel(aTempBuffer, nPos)
         aSize(aTempBuffer, Len(aTempBuffer)-1)
      EndIf
   Else
      If !lDelete .And. Valtype(oTemp) == "O"
         aAdd(aTempBuffer, {cNome, cAlias, oTemp})
      EndIf
   EndIf

Return Nil

/*
Função  : TETempName()
Autor   : Rodrigo Mendes Diaz
Data    : 01/06/17
Objetivo: Retornar o nome do arquivo temporário criado a partir do nome do Alias
*/
Function TETempName(cAlias)
Local cRet := ""
Local nPos
Local aTempBuffer

   If EasyGetBuffers('TETempBuffer','aTempBuffer',@aTempBuffer) .AND.;
   (nPos := aScan(aTempBuffer, {|x| Upper(x[2]) == Upper(cAlias) })) > 0
      cRet := aTempBuffer[nPos][3]:GetRealName()
   EndIf
Return cRet

/*
Função  : TETempBackup()
Autor   : Rodrigo Mendes Diaz
Data    : 01/06/17
Objetivo: Criar um backup da área corrente em uma tabela temporária (deve ser informado o Alias do temporário a ser criado)
*/
Function TETempBackup(cReferencia, lDados)
Local cAliasAtu := Alias()
Local aStructure:= (cAliasAtu)->(DbStruct())
Local nRecAtu   := (cAliasAtu)->(Recno())
Default lDados := .T.//17/01/19 - Permite clonar a tabela sem copiar os dados

    E_CriaTrab(, aStructure, cReferencia)
    If lDados
        (cAliasAtu)->(dbGoTop())
        While (cAliasAtu)->(!Eof())
            (cReferencia)->(DbAppend())
            AvReplace(cAliasAtu, cReferencia)
            (cAliasAtu)->(DbSkip())
        EndDo
    EndIf

DbSelectArea(cAliasAtu)
(cAliasAtu)->(dbGoTo(nRecAtu))
Return Nil

/*
Função  : TERestBackup()
Autor   : Rodrigo Mendes Diaz
Data    : 01/06/17
Objetivo: Restaurar o conteúdo da área corrente a partir de um arquivo temporário (Alias temporário indicado na referência). 
          O temporário será excluido no final da execução.
*/
Function TERestBackup(cReferencia)
Local cAliasAtu := Alias()
    
    (cReferencia)->(dbGoTop())
    While (cReferencia)->(!Eof())
    	(cAliasAtu)->(DbAppend())
    	AvReplace(cReferencia, cAliasAtu)
        (cReferencia)->(DbSkip())
    EndDo    
    TETempBuffer(, cReferencia,, .T.)

Return Nil

/*
Função  : TEOrdBagExt()
Autor   : Rodrigo Mendes Diaz
Data    : 01/06/17
Objetivo: Definir a extensão dos índices temporários. Caso utilize temporário no banco, retorna em branco para uso em legado.
*/
Function TEOrdBagExt()
Local TEOrdAlias 	:= Alias()
Local cRet			:= ""
Local cExt        := ""

   If !Empty(TEOrdAlias) .And. !("SX" $ TEOrdAlias) .And. !("SIX" $ TEOrdAlias) .And. !("XAL" $ TEOrdAlias) .And. !("XX" $ TEOrdAlias) .And. TEOrdAlias <> "SM0" //se não é dicionário
      cExt:= (TEOrdAlias)->(Dbinfo(9))
   EndIf

   If !TETempBanco() .Or. !Empty(cExt)
      cRet := OrdBagExt()
   Else
		//THTS - 08/01/2019 - Quando for no banco, o indice nao pode ter o mesmo nome da tabela, entao retornamos uma descricao para diferenciar
		If Upper(TCGetDb()) == "POSTGRES"
			cRet := "i"
		EndIf
	EndIf
Return cRet

/*
Função  : TETempReopen()
Autor   : Rodrigo Mendes Diaz
Data    : 13/10/17
Objetivo: Reabrir o arquivo temporário a partir do nome ou alias
*/
Function TETempReopen(cNome, cAlias, cNewAlias, cRDDDrive)
Local nPos
Local aTempBuffer
Default cNewAlias:= ""
Default cRDDDrive:= RDDSetDefault()

   If TETempBanco()
      If EasyGetBuffers('TETempBuffer','aTempBuffer',@aTempBuffer) .AND.;
      (nPos := aScan(aTempBuffer, {|x| x[1] == cNome })) > 0 .Or. (nPos := aScan(aTempBuffer, {|x| x[2] == cAlias })) > 0
         If !Empty(cNewAlias) //RMD 16/11/17 - Permite reabrir a tabela com um novo Alias
            dbUseArea(.T.,"TOPCONN", aTempBuffer[nPos][3]:cTableName, cNewAlias,.F.)
            cAlias:= cNewAlias
         Else
            dbUseArea(.T.,"TOPCONN", aTempBuffer[nPos][3]:cTableName, cAlias,.F.)
         EndIf
         aTempBuffer[nPos][2]:=cAlias
         DbSelectArea(cAlias)
      EndIf
   Else
      If !Empty(cNewAlias)
         cAlias:= cNewAlias
      EndIf
      dbUseArea(.T.,cRDDDrive, cNome, cAlias,.F.)
      DbSelectArea(cAlias)
   EndIf

Return Nil


/*
Funcao          : SimNao(cTexto,cTitulo)
Parametros      :       cTexto  := mensagem
                                aOpcoes := vetor com alternativas
                                cPrefixo:=
                                nLin,nCol := coordenadas
                                cTitulo := titulo da janela de dialogo
Retorno         :
Objetivos       :
Autor           : AVERAGE
Data/Hora       :
Revisao         : HEDER 08/12/98 16:03 (retirado compatibilidade com versao DOS)
Obs.            :
*/
Function SimNao(cTexto,cTitulo)
cTitulo:=If(cTitulo=NIL,STR0008+cModulo,OemToAnsi(cTitulo))//"SIGA"

Return If(MsgYesNo(OemToAnsi(cTexto),cTitulo),"S","X")




/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MATA011   ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 05.08.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Efetua a abertura de arquivos necessarios ao MATA010, pois  ³±±
±±³          ³estes foram excluidos do menu devido ao estouro do numero   ³±±
±±³          ³maximo de arquivos abertos no DOS                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ....................                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ...................................                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
FUNCTION MATA011

// JA COLOCADO NO MATA010
PRIVATE aMemos:={{"B1_DESC_I","B1_VM_I"},{"B1_DESC_GI","B1_VM_GI"},;
                 {"B1_DESC_P","B1_VM_P"}}

// Nopado por GFP - 02/05/2012 - Não deve haver diferença quando MV_EASY estiver habilitado ou não.
//IF ! EasyGParam("MV_EASY") $ cSim
//   axCadastro("SB1",STR0009,"ExcluiItem()","ValidaItemOK()")//"Atualiza‡Æo de Produtos"
//ELSE
   MATA010()
//ENDIF

RETURN
*----------------------*
FUNCTION ValidaItemOK()
*----------------------*
LOCAL lExiste:=EasyEntryPoint('ICPADB1')

IF lExiste
   RETURN ExecBlock('ICPADB1',.F.,.F.)
ENDIF

RETURN .T.

*----------------------*
FUNCTION ExcluiItem()
*----------------------*
LOCAL lExiste:=EasyEntryPoint('MTA010OK') .AND. EasyEntryPoint('MTA010E')
LOCAL lFunc:=.F.

IF lExiste .AND. ExecBlock('MTA010OK',.F.,.F.)
   lFunc:=ExecBlock('MTA010E',.F.,.F.)
ELSE
   /*
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Estas funções que antes eram RdMakes foram incorporadas³
   //³no Programa MATA010.PRX da Microsiga. Não foi tirado o ³
   //³Ponto de Entrada para manter a Integridade do Programa ³
   //³nos Clientes .                                         ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   */
   lFunc := Mta010ok()
   IF lFunc
      Mta010e()
   ENDIF
ENDIF

// TLM 05/12/2007 - Tratamento para excluir o vinculo do fornecedor caso o item seja apagado - Chamado 055764
If lFunc //FDR - 20/10/2011
   SA5->(dbSetOrder(2))
   If SA5->(DbSeek(xFilial("SA5")+SB1->B1_COD))
      If (lFunc := MsgYesNo(STR0149,STR0150)) //#STR0149->"O item possui vinculo com fornecedor, deseja apagar o item e o vinculo ?" # STR0150 ->"Atenção"
         While SA5->(!EOF() .And. SA5->A5_FILIAL+SA5->A5_PRODUTO == xFilial("SA5")+SB1->B1_COD)
            SA5->(RecLock("SA5",.F.))
            SA5->(dbDelete())
            SA5->(MsUnlock())
            SA5->(dbSkip())
         EndDo
      EndIf
   EndIf
EndIf

RETURN lFunc


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³E_OpenFile³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 23.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Abertura de Arquivos nao constantes do Menu                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³E_OpenFile(aDBFS,[bProgram],lAbre)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aDBFS = array com dbfs a serem abertos                     ³±±
±±³          ³ bProgram = programa/funcao a ser executada apos a abertura ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
FUNCTION E_OpenFile(aAlias,bProgram,aClose)

LOCAL cOldScreen, lAbre:=.T.

#IFNDEF TOP
   AEVAL(aClose,{|_dbf| ("S"+_dbf)->(DbCloseArea()) })  // fecha arquivos do eic
#ENDIF

IF ! EMPTY(aAlias)
   MsAguarde({|lEnd| E_Open({|msg| MsProcTxt(msg)},aAlias,@lAbre) },;
               STR0010)//"Abertura de Arquivos"
ENDIF

IF lAbre .AND. bProgram # NIL
   EVAL(bProgram)
ENDIF

#IFNDEF TOP
   AEVAL(aAlias,{|xAlias| ("S"+xAlias)->(DBCLOSEAREA()) })
   IF ! EMPTY(aClose)
      MsAguarde({|lEnd| E_Open({|msg| MsProcTxt(msg)},aClose,@lAbre) },;
                     STR0011)//"Reabertura de Arquivos"
   ENDIF
#ENDIF

Return lAbre

*----------------------------------------------------------------------------
FUNCTION E_Open(bMsg,aAlias,lAbre)
*----------------------------------------------------------------------------
LOCAL cFileName, nInd

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura de arquivos                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nInd:=1 TO LEN(aAlias)

    cFileName:="S"+aAlias[nInd]

    Eval(bMsg,STR0012+cFileName+STR0013)//"ABRINDO ARQUIVO "###" - AGUARDE...    "

    If SELECT(cFileName) = 0
       If !ChkFile(cFileName,.F.)
          Help("",1,"AVG0001021")//"NÆo foi possivel abrir Arquivo EA700"###"Informação"
*         Help(" ",1,"EA700"+cFileName)
          lAbre:=.F.
       Endif
    Endif

Next

RETURN .T.

/*
Funcao          : E_SJ0Codigo(Codigo,Var)
Parametros      :
Retorno         :
Objetivos       :
Autor           : AVERAGE
Data/Hora       :
Revisao         :
Obs.            :
*/
Function E_SJ0Codigo(Codigo,Var)
*---------------------------*
M->&(Var):=Codigo
Return .T.

/*
Funcao          : SYQ_VALID
Parametros      :
Retorno         :
Objetivos       :
Autor           : AVERAGE
Data/Hora       :
Revisao         :
Obs.            :
*/
FUNCTION SYQ_Valid()
Local cX5_DESC
IF ! EMPTY(cX5_DESC:=Tabela("Y3",LEFT(M->YQ_COD_DI,1)))
   M->YQ_COD_DI:= Left(SX5->X5_CHAVE,1) + "-" + cX5_DESC
ELSE
   M->YQ_COD_DI:=SPACE(15)
   RETURN .F.
ENDIF
lRefresh:=.T.
RETURN .T.

/*
Funcao          : SYCRLVALID()
Parametros      : Nenhum
Retorno         : .T. / .F.
Objetivos       : Validar campo YC_COD_RL
Autor           : Heder M Oliveira
Data/Hora       : 18/12/98 13:32
Revisao         :
Obs.            :
*/
Function SYCRLVALID( )
    Local lRet:=.T.,cOldArea:=select(),cMensa:=""
    Begin sequence
                If EMPTY(M->YC_IDIOMA)
                        cMensa:=STR0016 //"Necessário informar Idioma antes de definir Relação."
                        lRet:=.F.
                Else
                        lRet:=ExistCpo("SYC",M->cFiltroTip+M->YC_IDIOMA+M->YC_COD_RL)
                        cMensa:=STR0017 //"Código inválido ou de idioma diferente"
                EndIf
                If !lRet
                	Help("",1,"AVG0001022",,cMensa,1,2)
                EndIf
    End Sequence
    dbselectarea(cOldArea)
Return lRet


/*
Funcao          : E02FORFAB(cTipo)
Parametros      : cTipo   := FABR = FABRICANTE / FORN=FORNECEDOR
Retorno         : NIL
Objetivos       :
Autor           : Robson - Tecnologia
Data/Hora       :
Obs.            :
*/
Function E02FORFAB(cTipo)
   Local oDlg, FileWork, Tb_Campos:={}, OldArea:=SELECT(), OldOrd:=SA5->(INDEXORD())
   Local cTitulo, cCampo

   bReturn:={||M->EE8_FABR:=SA5->A5_FABR,oDlg:End()}

   cCampo:=IF(UPPER(cTipo)=="FABR","A5_FABR","A5_FORNECE")

   AADD(Tb_Campos,{cCampo ,,STR0125}) //"Codigo"
   AADD(Tb_Campos,{{||BuscaFabr_Forn(A5_FABR)},,STR0126}) //"Nome"
   AADD(Tb_Campos,{"A5_PRODUTO",,STR0127}) //"Item"
   AADD(Tb_Campos,{"A5_CODPRF",,STR0128}) //"Part-Number"

   DBSELECTAREA("SA5")

   SA5->(DBSETORDER(3))
   SA5->(DBSEEK(xFilial("SA5")+ALLTRIM(M->EE8_COD_I)))

   cTitulo:=STR0019+IF(UPPER(cTipo)=='FABR',STR0129,STR0130)//"Consulta Relação de Produtos x " //"Fabricantes"###"Fornecedores"

   IF UPPER(cTipo) == 'FORN'
            bReturn:={||M->EE8_FORN:=SA5->A5_FORNECE,oDlg:End()}
   ENDIF

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 4,3 TO 20,55 OF oMainWnd

      oMark:= MsSelect():New("SA5",,,TB_Campos,,,{20,6,100,160},"E02_DSel","E02_DSel")
      oMark:baval:=bReturn
      oMark:oBrowse:align:=CONTROL_ALIGN_ALLCLIENT
            
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| Eval(oMark:baval) }, { || oDlg:End() },,,,,,,.F.)

   SA5->(DBCLEARFILTER())
   SA5->(DBSETORDER(OldOrd))
   DBSELECTAREA(OldArea)

Return NIL

******************
Function E02_DSel()
******************
Return xFilial("SA5")+ALLTRIM(M->EE8_COD_I)


/*
Funcao          : BUSCAFABR_FORN(PCODIGO)
Parametros      : PCODIGO:= CODIGO FABRICANTE/FORNECEDOR
Retorno         : NOME REDUZIDO
Objetivos       : RETORNAR NOME REDUZIDO DE FABRICANTE/FORNECEDOR
Autor           : AVERAGE
Data/Hora       :
Revisao         :
Obs.            :
*/
FUNCTION BuscaFabr_Forn( PCodigo, PLoja )
Default PLoja := ""
RETURN ( SA2->( MSSEEK(xFilial("SA2")+PCodigo+PLoja) ), SA2->A2_NREDUZ )

/*
Funcao          : E_CREATE(aSTRU,lDBF)
Parametros      : aStru,;
                  lDBF para indicar se cria a estrutura;
                  cAlias,;
                  cNomArqAlias,;
                  nIndex;
                  lEECGetIndexFile
Retorno         :
Objetivos       : Criar arquivo baseado em vetor com definicao da estrutura
Autor           : AVERAGE
Data/Hora       :
Revisao         : wfs mar/2017
                  Adequação para uso do EECGetIndexFile(), para reaproveitamento de arquivos temporários
Obs.            :
*/
Function E_Create(aStru,lDBF,cAlias,cNomArqAlias,nIndex,lEECGetIndexFile)
Local cNome
Default lEECGetIndexFile:= .F.

   If lEECGetIndexFile
      cNome:= EECGetIndexFile(cAlias,cNomArqAlias,nIndex)
   Else
      While ( File((cNome:=CriaTrab(,.F.))+RetIndExt()) .OR. File(cNome+GetDBExtension()) ) ; Enddo
      If lDBF .And. !Empty(aStru)
         cNome := E_CriaTrab(,aStru,"ECREATE")
         ECREATE->(DbCloseArea())
      Endif
   EndIf
Return cNome

/*
Funcao          :
Parametros      :
Retorno         :
Objetivos       :
Autor           :
Data/Hora       :
Revisao         :
Obs.            : EICXFUN
*/
Function EicFBOrigem(cOrigem,cTipo)
*----------------------------------------------------------------------------
LOCAL cOrigAtu, nOrdSYR:=SYR->(INDEXORD())
IF EMPTY(cOrigem)
   RETURN .T.
ENDIF

DO CASE
   CASE cTipo == "1"   ; cOrigAtu:=M->A2_ORIG_2+M->A2_ORIG_3
   CASE cTipo == "2"   ; cOrigAtu:=M->A2_ORIG_1+M->A2_ORIG_3
   CASE cTipo == "3"   ; cOrigAtu:=M->A2_ORIG_1+M->A2_ORIG_2
ENDCASE

SYR->(DBSETORDER(3))
IF ! SYR->(DBSEEK(xFilial()+cOrigem))
   HELP(" ",1,"AVG0000034")
   SYR->(DBSETORDER(nOrdSYR))
   RETURN .F.
ENDIF

SYR->(DBSETORDER(nOrdSYR))
IF AT(cOrigem,cOrigAtu) <> 0
        HELP(" ",1,"AVG0000035")
   RETURN .F.
ENDIF
RETURN .T.

/*
Funcao          : AVSX3(cCAMPO)
Parametros      : cCAMPO
Retorno         : aRET
Objetivos       :
Autor           : Heder M Oliveira/Cristiano
Data/Hora       : 11/03/99 18:48
Revisao         : Cristiano A. Ferreira - 29/03/1999
                  Heder M Oliveira - 11/05/99
Obs.            :
*/
Function AVSX3(cCampo,nRet,cAlias,lVerExiste)
Local aRet:={},nOldArea:=select(),nORDSX3
Local cValid :="{||.T.}", cWhen  :="{||.T.}", cIniBrw, cPasta
Local nRecno, i

Local xRet, aBox
Local nPos, aStruct, lErro
//Static aBuffer := {}                   //AAF/NCF - 13/09/2013 - Ajustes para melhora de performance Integ. Pedido Expo. Msg. Unica
//Static cCpo_Old, aRet_Old, cAliasOld

Default nRet := 0
Default lVerExiste:= .f.
Default cAlias := If(AT("_",cCampo)>3,Left(cCampo,3),"S"+Left(cCampo,2)) //AAF 17/05/2018 - Alias precisa ser inicializado com um default para buscar no buffer (sem pegar do SX3 para nao perder performance)

cCampo:=UPPER(ALLTRIM(cCampo))

If /*lSX3Buffer .AND. */EasyGetBuffers("AVSX3",cAlias+','+cCampo,@aRet)//(nPos := aScan(aBuffer,{|X| X[1] == cCampo .And. x[3] == cAlias})) > 0//RMD - 05/02/17 - Busca o Alias no Buffer para evitar erro no inicializador browse
   //aRet := aBuffer[nPos][2]
Else

   Begin Sequence

      nORDSX3:=SX3->(INDEXORD())
      nRecno:=SX3->(RECNO())

      /*
      If cCpo_Old == cCampo .And. cAliasOld == cAlias
        aRet := aRet_Old
        Break
      Endif
      */

      SX3->(DBSETORDER(2))
      If SX3->(DBSEEK(cCampo))
      //If SX3->(DBSEEK(cCampo))
         //IF Empty(cAlias)
         //   cAlias := AllTrim(SX3->X3_ARQUIVO)
         //Endif

         If !EMPTY(SX3->X3_VALID) .OR. !EMPTY(SX3->X3_VLDUSER)
            cValid:=ALLTRIM(SX3->X3_VALID)
            If !Empty(SX3->X3_VLDUSER)
               cValid:=cValid+If(!EMPTY(cValid)," .AND. ","")+ALLTRIM(SX3->X3_VLDUSER)
            Endif

            cValid:="{||"+cValid+"}"
         EndIf

         If(!Empty(SX3->X3_WHEN),cWhen := "{|| "+ AllTrim(SX3->X3_WHEN)+"}",)

         If !Empty(SX3->X3_INIBRW)
            cIniBrw := AllTrim(SX3->X3_INIBRW)
         Else
            IF SX3->X3_CONTEXT == "V"
               cIniBrw := STR0117 //"'Campo Virtual'"
            ElseIf !Empty(X3Cbox())
               aBox := ComboX3Box(cCampo,X3Cbox())
               cIniBrw := ""

               For i:=1 To Len(aBox)
                  cIniBrw += "IF("+cAlias+"->"+cCampo+" == "+IF(SX3->X3_TIPO=="C","'","")+Substr(aBox[i],1,At("=",aBox[i])-1)+IF(SX3->X3_TIPO=="C","'","")+",'"+Substr(aBox[i],At("=",aBox[i])+1)+"',"
               Next

               cIniBrw += "''"+Replic(")",Len(aBox))

            ElseIf Empty(SX3->X3_PICTURE)
               cIniBrw := cAlias+"->"+cCAMPO
            Else
               cIniBrw := "Transform("+cAlias+"->"+cCAMPO+",'"+AllTrim(SX3->X3_PICTURE)+"')"
            Endif
         Endif

         SXA->(DBSETORDER(1))
         cPasta:=IF(SXA->(DBSEEK(SX3->X3_ARQUIVO+SX3->X3_FOLDER)),ALLTRIM(SXA->XA_DESCRIC),'Outros')

         AADD(aRET,SX3->X3_ORDEM)
         AADD(aRET,SX3->X3_TIPO)
         AADD(aRET,SX3->X3_TAMANHO)
         AADD(aRET,SX3->X3_DECIMAL)
         AADD(aRET,OemToAnsi(ALLTRIM(X3TITULO())))
         AADD(aRET,ALLTRIM(SX3->X3_PICTURE))
         AADD(aRET,&(cValid))
         AADD(aRET,SX3->X3_F3)
         AADD(aRET,SX3->X3_NIVEL)
         AADD(aRET,SX3->X3_TRIGGER)
         AADD(aRET,ALLTRIM(SX3->X3_BROWSE))
         AADD(aRET,ALLTRIM(X3Cbox()))
         AADD(aRET,&(cWhen))
         AADD(aRET,cIniBrw)
         AADD(aRET,cPasta)
         AAdd(aRet,SX3->X3_CONTEXT)
         AAdd(aRet,SX3->X3_ARQUIVO)
      Else
         lErro := .t.
         // Se for um dos dicionarios puxar o tipo/tamanho/decimal da estrutura da tabela
         IF Substr(cCampo,1,1) = "X" .And. Substr(cCampo,3,1) = "_"
            aStruct := ("S"+Substr(cCampo,1,2))->(dbStruct())

            nPos := aScan(aStruct,{|x| x[1] == cCampo})
            IF nPos > 0
               lErro:= .f.
               aRet := {"0",aStruct[nPos][2],aStruct[nPos][3],aStruct[nPos][4],"","",{||.T.},"",0,"","","",{||.T.},"",""}
            Endif
         Endif

         IF lErro
            // Help("",1,"AVG0001022",,cCampo + STR0021+' - '+STR0022 +AllTrim(ProcName(1))+","+AllTrim(Str(ProcLine(1))),1,7)
            If !lVerExiste
               MSGSTOP(STR0146+cCampo+STR0021,STR0022+AllTrim(ProcName(1))+","+AllTrim(Str(ProcLine(1))))//"Campo: " ### "não cadastrado no dicionário de dados !"###"Erro - Função: "
            Endif
            aRet := {"0","C",0,0,STR0118,"",{||.T.},"",0,"","","",{||.T.},"",""} //"#Erro"
         Endif
      EndIf

      cCpo_Old := cCampo
      cAliasOld:= cAlias
      aRet_Old := aRet

      //If lSX3Buffer //NCF - 28/07/2020 - Melhoria performance SIGAEDC (Apuração de insumos - ato isenção) 
         EasySetBuffers("AVSX3",cAlias+','+cCampo,aClone(aRet))
         //aAdd(aBuffer,{cCampo,aClone(aRet),cAlias})//RMD - 05/02/17 - Inclui o Alias no Buffer para evitar erro no inicializador browse
      //EndIf

      SX3->(DBSETORDER(nORDSX3))
      SX3->(DBGOTO(nRecno))
      dbselectarea(nOldArea)

   End Sequence
EndIf


IF nRet != 0
   xRet := aRet[nRet]
Else
   xRet := aRet
Endif

Return If(lVerExiste,If(aRet[1]=="0",.f.,.t.),xRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ InitYear4 ³ Autor ³Cristiano A. Ferreira ³ Data ³ 06.04.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa variavel, para o uso da funcao IsYear4()        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ void InitYear4()                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Inicializacao do modulo. Ex. SIGAEIC.prw, SIGAEIF.prw      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function InitYear4()

nYear := iif( Len(DtoC(MSDate())) == 10, 4, 2)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  IsYear4  ³ Autor ³Cristiano A. Ferreira ³ Data ³ 06.04.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Indica se o usuario usa 4 digitos no ano.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ IsYear4(), Retorna True se o usuario usa 4 digitos no ano. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IsYear4()

Return ( nYear == 4 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICXFUN  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 13/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcoes Comuns utilizadas no SIGAEIC                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*---------------------------------------------------------------------------------------
FUNCTION E_Init(lJob)                                                     //MJB-SAP-0800
*  lJob = .T. => chamada a partir de outro programa (normal via SX2)      //MJB-SAP-0800
*---------------------------------------------------------------------------------------
LOCAL Cont1:=VerItem(), CodItem, CharItem

/* FSM - 13/05/11 - Retirado os comentarios das variaveis publicas habilitando as para o fonte.*/
Public _PictPO , _PictPrUn , _PictNBM, _PictPrTot , _FirstYear , _PictQtde

_PictPrUn := ALLTRIM(X3Picture("W3_PRECO"))
_PictPrTot:= ALLTRIM(X3Picture("W2_FOB_TOT"))
_PictQtde := ALLTRIM(X3Picture("W3_QTDE"))
_PictPO   := ALLTRIM(X3Picture("W2_PO_NUM"))
_PictNBM  := E_Tran("YD_TEC",,.T.)          //ALLTRIM(X3Picture("B1_POSIPI"))
_FirstYear:=Right(Padl(Set(_SET_EPOCH),4,"0"),2)

If lJob = NIL
   IF EasyEntryPoint("EICCALEND") 
      SETKEY(VK_F12,{|| ExecBlock("EICCALEND",.F.,.F.)})      
   ENDIF
Endif 

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³E_InitVar ³ Autor ³ AVERAGE/MICROSIGA     ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa variaveis de memoria p/ campos do arquivo sele- ³±±
±±³          ³ cionado. As variaveis devem ter sido criadas previamente   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
FUNCTION E_InitVar()

LOCAL i,lInit, bCampo := { |nCPO| Field(nCPO) }

FOR i := 1 TO FCount()
    M->&(EVAL(bCampo,i)) := FieldGet(i)
    lInit := .F.
    If ExistIni(EVAL(bCampo,i))
        lInit := .t.
        M->&(EVAL(bCampo,i)) := InitPad(SX3->X3_RELACAO)
        If ValType(M->&(EVAL(bCampo,i))) = "C"
            M->&(EVAL(bCampo,i)) := PADR(M->&(EVAL(bCampo,i)),SX3->X3_TAMANHO)
        Endif
        If M->&(EVAL(bCampo,i)) == NIL
            lInit := .F.
        EndIf
    EndIf
    If !lInit
        IF ValType(M->&(EVAL(bCampo,i))) == "C"
           M->&(EVAL(bCampo,i)) := SPACE( LEN(M->&(EVAL(bCampo,i))) )
        ELSEIF ValType(M->&(EVAL(bCampo,i))) == "N"
            M->&(EVAL(bCampo,i)) := 0
        ELSEIF ValType(M->&(EVAL(bCampo,i))) == "D"
            M->&(EVAL(bCampo,i)) := dDataBase
        ELSEIF ValType(M->&(EVAL(bCampo,i))) == "L"
            M->&(EVAL(bCampo,i)) := .F.
        ENDIF
    EndIf
Next i
Return .T.

/*
Funcao    : BuscaBanco(PBanco,PReduzido)
Parametros:     PBanco:= codigo do banco
                    PReduzido:= se .T. (default) retorna nome reduzio, senao retorna nome extendido
Objetivos : Retornar Nome reduzido do banco
Autor     : Heder M Oliveira
Data/Hora : 08/10/98 15:30
Revisao   :
Obs.      :
*/
Function BuscaBanco(PBanco,PReduzido)
Local lRet:=STR0023 //"Banco não cadastrado"
default PReduzido:=.T.
SA6->( DBSETORDER(1))
If SA6->(DBSEEK(xFilial("SA6")+PBanco))
   lRet:=if(PReduzido,SA6->A6_NREDUZ,SA6->A6_NOME)
EndIf
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ AV_Justifica  ³ Autor    ³ Victor Iotti   ³ Data ³ 21/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³CoAutor   ³ Alexandro Wallauer                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Justifica uma String                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaEIC                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observa‡Æo³ NÆo usar com fontes TrueType                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*-----------------------------*
Function AV_Justifica(cString)
*-----------------------------*
LOCAL cRetorno, nTam, cSpacs, nWinter ,nCont, cJustString

nTam  :=LEN(ALLTRIM(cString))
cSpacs:=LEN(cString)-nTam

IF cSpacs<=0
   RETURN cString
ENDIF

cString:=ALLTRIM(cString)
nWinter:=0
nCont  :=LEN(cString)

DO WHILE nCont>0

   IF SUBSTR(cString,nCont,1)=SPACE(1)
      nWinter++
      DO WHILE SUBSTR(cString,nCont,1)=SPACE(1) .and. nCont>0
          --nCont
      ENDDO
   ELSE
      nCont--
   ENDIF

END

IF nWinter=0
   RETURN cString
ENDIF

DO WHILE cSpacs>0

   cRetorno:=""
   nCont   :=LEN(cString)

   DO WHILE nCont>0

      IF SUBSTR(cString,nCont,1)=SPACE(1)
         IF cSpacs>0
            cRetorno+=SPACE(1)
            --cSpacs
         ENDIF
      ENDIF

      cRetorno+=SUBSTR(cString,nCont,1)
      nCont--

   END

   cString:=""
   FOR nCont=LEN(cRetorno) TO 1 step -1
       cString+=SUBSTR(cRetorno,nCont,1)
   NEXT

END

cJustString:=""

FOR nCont=LEN(cRetorno) TO 1 step -1
    cJustString+=SUBSTR(cRetorno,nCont,1)
NEXT

RETURN cJustString

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³E_Tran    ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 21.08.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna Picture de Campos                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³E_Tran (cCampo,sAlias)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCampo = nome do campo no arquivo no SX3                   ³±±
±±³          ³ sAlias = nome do Alias do Campo                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
FUNCTION E_Tran(cCampo,sAlias,lSoPict)

LOCAL nPos, nOrder:=SX3->(INDEXORD())
LOCAL cConteudo, cOldAlias:=ALIAS()

SX3->(DBSETORDER(2))
SX3->(DBSEEK(PADR(cCampo,10)))
SX3->(DBSETORDER(nOrder))

If lSoPict = NIL
   IF(sAlias==NIL,sAlias:=cOldAlias,)
   nPos     :=(sAlias)->(FIELDPOS(cCampo))
   cConteudo:=(sAlias)->(FIELDGET(nPos))
Else
   Return Trim(SX3->X3_PICTURE)
Endif

If ! Empty(SX3->X3_PICTURE)
   Return ( TRANSFORM(cConteudo,AllTrim(SX3->X3_PICTURE)) )
Endif

Return cConteudo
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BuscaCCusto  ³ Autor ³ AVERAGE-          ³ Data ³ 13/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------------------------------------------------------------------
FUNCTION BuscaCCusto (PCCusto)
*----------------------------------------------------------------------------
LOCAL _LIT_CC := (SW0->(E_Tran("W0__CC")),ALLTRIM(X3TITULO()))
RETURN IF(SY3->( DBSEEK(xFilial()+AvKey(PCCUSTO,"Y3_COD")/*FSY - 02/05/2013*/) ), SY3->Y3_DESC ,;
                                     _LIT_CC + STR0024) //" Não cadastrado"
*----------------------------------------------------------------------------
FUNCTION Grava_Ocor (PNr_Po,PDt_Ocor,POcor,PFase)
*----------------------------------------------------------------------------
LOCAL nOldArea:=SELECT()
RecLock("SWO",.T.)
SWO->WO_FILIAL  := xFilial("SWO")
SWO->WO_PO_NUM  := PNr_PO
SWO->WO_DT      := PDt_Ocor
SWO->WO_DESC    := POcor
SWO->WO_USUARIO := cUserName
IF PFase == NIL
ELSE
   SWO->WO_FASE := PFase
ENDIF
SWO->(MsUnlock())
//SWO->(DBCOMMIT())
DBSELECTAREA(nOldArea)

/*
    Funcao   : BUSCAF_F(pCODIGO,lREDUZIDO)
    Autor    : AVERAGE
    Data     :
    Revisao  :
    Uso      :
    Recebe   :
    Retorna  :

*/
FUNCTION BuscaF_F ( PCodigo,lREDUZIDO,PLoja )
DEFAULT lREDUZIDO:=.F.
DEFAULT PLoja := ""
RETURN ( SA2->( DBSEEK(xFilial("SA2")+PCodigo+PLoja) ), IF(lREDUZIDO,SA2->A2_NREDUZ,SA2->A2_NOME))


*-----------------------*
FUNCTION PO_Busca(cQual) //AWR 23/04/1999 - Usado no X3_VALID, X3_RELACAO E
*-----------------------*  X3_INIBRW do SW2
LOCAL cRet
DO CASE
   CASE cQual = "0"

        cRet:=IF(!EMPTY(M->W2_REG_TRI),ALLTRIM(Tabela("Y2",M->W2_REG_TRI)),"")

   CASE cQual = "1"

        cRet:=IF(!EMPTY(SW2->W2_REG_TRI),ALLTRIM(Tabela("Y2",SW2->W2_REG_TRI)),"")

   CASE cQual = "2"

        SY6->(DBSEEK(xFilial("SY6")+M->W2_COND_PA+STR(M->W2_DIAS_PA,3)))
        cRet:=MSMM(SY6->Y6_DESC_P,AVSX3("Y6_VM_DESP",3),1)

   CASE cQual = "3"

        SY6->(DBSEEK(xFilial("SY6")+SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA,3)))
        cRet:=MSMM(SY6->Y6_DESC_P,AVSX3("Y6_VM_DESP",3),1)

   CASE cQual = "4"

        SY6->(DBSEEK(xFilial("SY6")+M->W2_COND_EX+STR(M->W2_DIAS_EX,3)))
        cRet:=MSMM(SY6->Y6_DESC_P,AVSX3("Y6_VM_DESP",3),1)

   CASE cQual = "5"

        SY6->(DBSEEK(xFilial("SY6")+SW2->W2_COND_EX+STR(SW2->W2_DIAS_EX,3)))
        cRet:=MSMM(SY6->Y6_DESC_P,AVSX3("Y6_VM_DESP",3),1)

   CASE cQual = "6"

        M->W2_REGDESC:=IF(!EMPTY(M->W2_REG_TRI),ALLTRIM(Tabela("Y2",M->W2_REG_TRI)),"")
        cRet:=lRefresh:=.T.

ENDCASE

RETURN cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AvButtonBar ³ Autor ³ AVERAGE-RS            ³ Data ³ 18/04/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para montagem de uma barra de Ferramentas (ToolBar)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*----------------------------------------------------------------------------------------------*
FUNCTION AvButtonBar(oDlg,bOk,bCancel,nOpc,cToolTip,bFunction,cButton,cTitle, aButtons, lCancel)
*----------------------------------------------------------------------------------------------*
RETURN EnchoiceBar(oDlg,bOk,bCancel, ,aButtons)

*----------------------------------------------------------------------------
FUNCTION BuscaPais(nPais,lSigla)
*----------------------------------------------------------------------------
LOCAL cRET:=""
// Alterado por Heder M Oliveira - 7/20/1999
IF SYA->( DBSeek(xFilial("SYA")+nPais) )
   cRET:=IF(lSigla = NIL,SYA->YA_DESCR,SYA->YA_SIGLA)
ELSE
   cRET:=IF(lSigla = NIL,STR0037,'***')//"Pais não cadastrado"
ENDIF
RETURN cRET


/*
    Funcao   : E_FIELD2(pChaveP,cAlias1,nOrdem1,pRet1,pChaveP2,nCol)
    Autor    : Heder M Oliveira
    Data     : 13/07/99 112:01
    Revisao  : 13/07/99 112:01
    Uso      : Retornar descrições para campos virtuais, inclusive de MSMM
    Recebe   : pCHAVEP :=chave de pesquisa sobre o alias
                           cALIAS1 :=alias que sera pesquisado
                           nORDEM1 :=ordem a ser utilizada na pesquisa

                           pCHAVEP2:=se informado, esta chave indica o campo que
                                                 sera utilizado na pesquisa para MSMM
                           nCOL    :=numero de colunas que deve ser retornado pelo MSMM
    Retorna  :

*/
FUNCTION E_FIELD2(pCHAVEP,cALIAS1,nORDEM1,pRET,pCHAVEP2,nCOL)
        LOCAL cRET:=""
    Local lInclui

    lInclui := IF(TYPE("Inclui")=="L",Inclui,.F.)

        DEFAULT nCOL:=60

        BEGIN SEQUENCE
        IF EMPTY(pChaveP) .Or. lInclui
           Break
        Endif

                IF ( pcount()<3 )
                        Help("",1,"AVG0001024")//"Erro no uso da E_FIELD2."###"Erro"
                        break
                ENDIF

                (cALIAS1)->(DBSETORDER(nORDEM1))
                (cALIAS1)->(DBSEEK(XFILIAL(cALIAS1)+pCHAVEP))

                IF (pCHAVEP2#NIL  )
            cRET:=(cALIAS1)->(MSMM(&pCHAVEP2,nCOL,1))
                ELSEIF (pRET#NIL)
                        cRET:=(cALIAS1)->(&pRET)
                ELSE
                        Help("",1,"AVG0001025")//"Não foi informado identificador de retorno."###"Erro"
                        break
                ENDIF
        ENDSEQUENCE

RETURN cRET


/*
    Funcao   : AVField(cChave,cCampoDesc,cOrigem,lChave,nOrder)
    Autor    : 
    Data     : 
    Revisao  : 
    Uso      : 
    Recebe   : 
    Retorna  :
*/
Function AVField(cChave,cCampoDesc,cOrigem,lChave,nOrder)

Local nPos := At("_",cCampoDesc)
Local cArea:= If(nPos>3,Left(cCampoDesc,3),"S"+Left(cCampoDesc,2))
Local nRec := (cArea)->(RecNo())
Local nOrd := (cArea)->(IndexOrd())
Local cDesc:= cArea + "->(" + cCampoDesc + ")"//FieldWBlock(cCampoDesc,Select(cArea))
Local bVar, cAreaAux
Local cRet := ""
Local aChave := AvFSplit(cChave)
Local lMemoria := .F.
Local oGrid

Begin Sequence

   nPos:=AT("_",cChave)
   cAreaAux:=If(nPos>3,Left(cChave,3),"S"+Left(cChave,2))

   nOrder:=Iif(nOrder==Nil,1,nOrder)
   lChave:=Iif(lChave==Nil,.F.,lChave)
   cOrigem:=Iif(cOrigem==Nil,"G",cOrigem)

   If cOrigem = "G" // Gatilho/Enchoice  ou Browse se For U

      If MVCGrid(@oGrid)
         If oGrid:nLine == 0
            cChave:= (cAreaAux)->&(cChave)
         Else
            cChave:= ""
         EndIf

      Else
         lMemoria := .T.
         aEval(aChave, {|x| If(Type("M->"+x) == "U", lMemoria := .F.,) })
         If lMemoria//TYPE("M->("+cChave+")") != "U"
            bVar := "M->(" + cChave + ")"//MemVarBlock(cChave)
            cChave:=&(bVar)
         Else
            cChave:= (cAreaAux)->&(cChave)//Eval(FieldWBlock(cChave,Select(cAreaAux)))
         EndIf
      EndIf
   Else
      // Browse
      cChave:= (cAreaAux)->&(cChave)//Eval(FieldWBlock(cChave,Select(cAreaAux)))
   EndIf

   If Empty(cChave)
      Break
   EndIf

   (cArea)->(DbSetOrder(nOrder))
   (cArea)->(DbSeek(xFilial()+cChave))
   cCampoDesc:=&(cDesc)

   If nRec > 0
      (cArea)->(DbGoTo(nRec))
      (cArea)->(DbSetOrder(nOrd))
   EndIf

   cRet := If(!lChave,cCampoDesc,cChave+" "+cCampoDesc)

End Sequence

Return cRet

/*
   Funcao    : MVCGrid(oGrid)
   Parâmetros:
   Objetivo  : Avaliar se é rotina MVC e retornar o objeto grid para inicializador padrão dos campos
   Retorno   : Lógico - se é rotina MVC
   Autor     : wfs
   Data      : set/2019
   Revisao   : 
*/
Static Function MVCGrid(oGrid)
Local oModel := FWModelActive()
Local lRet:= .F.

Begin Sequence

   If ValType(oModel) == "O" 
      
      Do Case

         Case oModel:GetID() == "MATA061" .And. oModel:GetOperation() <> 3
            
            oGrid:= oModel:GetModel("MdGridSA5")
            lRet:= .T.

      End Case

   EndIf

End Sequence

Return lRet

Static Function AvFSplit(cChave)
Local aRet := {}
Local nPos

   While (nPos := At("+", cChave)) > 0
      aAdd(aRet, Left(cChave, nPos - 1))
      cChave := SubStr(cChave, nPos + 1)
   EndDo
   aAdd(aRet, cChave)

Return aRet

Function BuscaITEM(pCHAVE)
    Local cRet:=""
        BEGIN SEQUENCE
        SB1->( DBSETORDER(1))
        If SB1->(DBSEEK(xFilial("SB1")+pCHAVE))
            cRet:=SB1->B1_DESC
                EndIf
        ENDSEQUENCE
Return cRet

/*
    Funcao   : ComboSX5(cTABELA,lESPACO)
    Autor    : Heder M Oliveira
    Data     : 19/07/99 16:52
    Revisao  : 19/07/99 16:52
    Uso      : Retornar um vetor para ser usado como list-box
    Recebe   : Codigo da tabela no sx5
    Retorna  : vetor com codigo+descricao

*/
FUNCTION ComboSX5(cTABELA,lESPACO)
    LOCAL aRET:={},nRECNOSX5:=SX5->(RECNO())
	DEFAULT lESPACO:=.T.
    IF SX5->(DBSEEK(xFilial("SX5")+cTABELA))
        WHILE !SX5->(EOF()) .AND. xFIlial("SX5") == SX5->X5_FILIAL .AND. SX5->X5_TABELA == cTABELA
			IF ( lESPACO )
               AADD(aRET,SX5->X5_CHAVE+"-"+X5DESCRI())
			ELSE
            AADD(aRET,ALLTRIM(SX5->X5_CHAVE)+"-" +ALLTRIM(X5DESCRI()))
			ENDIF
            SX5->(DBSKIP())
        ENDDO
    ENDIF
    SX5->(DBGOTO(nRECNOSX5))
RETURN aRET



/*
    Funcao   : ComboX3BOX(cCAMPO)
    Autor    : Heder M Oliveira
    Data     : 20/07/99 09:50
    Revisao  :
    Uso      : Criar um vetor com conteudo do X3_BOX de um campo para ser
                usado em list-box
    Recebe   : Campo
    Retorna  : vetor com codigo+descricao
    Revisao  : Cristiano A. Ferreira
               15/09/1999 15:59

*/
FUNCTION ComboX3BOX(cCAMPO,cCBOX)
   LOCAL aRET:={},nCONT

   IF Empty(cCBOX)
      cCBOX:=AVSX3(UPPER(ALLTRIM(cCampo)))[12]
   Endif

   BEGIN SEQUENCE
      While !Empty(cCBOX)
         nCONT:=AT(";",cCBOX)
         IF nCont == 0
            AADD(aRET,AllTrim(cCBOX))
            Exit
         Else
            AADD(aRET,AllTrim(SUBSTR(cCBOX,1,nCONT-1)))
         Endif
         cCBOX:=SUBSTR(cCBOX,nCONT+1)
      Enddo
   ENDSEQUENCE

RETURN aRET

/*
    Funcao   : BSCBOX
    Autor    : Heder M Oliveira
    Data     : 20/07/99 17:27
    Revisao  : 20/07/99 17:27
    Uso      : Retornar descricao de um campo que tem valor baseado no X3_CBOX
    Recebe   :
    Retorna  :

*/
FUNCTION BSCXBOX(cCAMPO,cESCBOX)
    Local cRet:=""/*STR0042*/,nINC,nCONT //"ITEM NAO CADASTRADO" //MCF - 08/09/2015
    LOCAL cCBOX:=AVSX3(cCAMPO)[12]
    BEGIN SEQUENCE
        FOR nINC:=1 TO LEN(cCBOX)
            nCONT:=AT(";",cCBOX)
            nCONT:=IF(nCONT==0,LEN(cCBOX)+3,nCONT)
            IF LEFT(cCBOX,1)=cESCBOX
                cRET:=SUBSTR(cCBOX,3,nCONT-3)
                EXIT
            ENDIF
            cCBOX:=SUBSTR(cCBOX,nCONT+1)
        NEXT nINC
    ENDSEQUENCE
Return cRet

/*
Funcao      : ArrayBrowse(cAlias)
Parametros  : cAlias   := Alias do arquivo no SX3
              cAliasDad:= (opcional) Alias do browse, de onde vem a informacao
                          Exemplo: TRB
Retorno     : Array para ser passado para a MSSELECT
Objetivos   : Montar a MSSELECT, com as caracteristicas do SX3
Autor       : Cristiano A. Ferreira
Data/Hora   : 16/07/99 16:37
Revisao     : 28/02/2000 10:43
Obs.        :
*/
FUNCTION ArrayBrowse(cAlias,cAliasDad,aCposfora, lColBrw)

Local aOrd := SaveOrd("SX3")

LOCAL aRet := {}
LOCAL aField

Default cAliasDad := cAlias
Default aCposfora := {}
Default lColBrw := .F.

SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))

While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == cAlias


   IF aScan(aCposfora, {|x| AllTrim(SX3->X3_CAMPO) == AllTrim(x)}) > 0
      SX3->(dbSkip())
      Loop
   Endif


   IF SX3->X3_NIVEL > cNivel .Or. ! X3Uso(SX3->X3_USADO) .Or. (SX3->X3_TIPO == "M" .And. SX3->X3_CONTEXT == "V")
      SX3->(dbSkip())
      Loop
   Endif

   IF Upper(SX3->X3_BROWSE) != "S"
      SX3->(dbSkip())
      Loop
   Endif

   If !lColBrw
      /* RMD - 29/01/20 - Caso o ambiente possua os controles de LGPD habilitados, se o campo trata-se de um conteúdo sensível ou pessoal e o usuário não possuir a acesso
                        aos campos com este perfil, inclui o nome do campo diretamente no array (sem codeblock) para que o tratamento padrão do framework para ofuscação de dados
                        possa identificar o campo e aplicar a ofuscação padrão.
                        Caso o usuário possua acesso aos campos com dados pessoais ou sensíveis foi mantido o modelo anterior (com codeblock) para preservar o legado.
      */
      If FindFunction("FWPDCANUSE") .And. FwPDCanUse(.T.) .And. Len(FwProtectedDataUtil():UsrNoAccessFieldsInList({SX3->X3_CAMPO}, .T., .T.)) > 0
         aField := {SX3->X3_CAMPO,"", OemToAnsi(X3TITULO()) }
      Else
         IF Empty(SX3->X3_PICTURE)
            aField := { &("{|| "+cAliasDad+"->("+SX3->X3_CAMPO+") }"),"", OemToAnsi(X3TITULO()) }
         Else
            aField := { &("{|| TRANSFORM("+cAliasDad+"->("+SX3->X3_CAMPO+"),'"+AllTrim(SX3->X3_PICTURE)+"') }"),"", OemToAnsi(X3TITULO()) }
         Endif

         IF SX3->X3_CONTEXT == "V"
            aField[1] := NIL
         Endif

         IF ! Empty(SX3->X3_INIBRW)
            aField[1] := &("{|| "+cAliasDad+"->("+SX3->X3_INIBRW+") }")
         Endif
      EndIf

      IF aField[1] != Nil
         aAdd(aRet,aField)
      Endif
   Else
      aAdd(aRet, ColBrw(SX3->X3_CAMPO,cAlias, If(cAliasDad <> cAlias, cAliasDad,)))
   EndIf

   SX3->(dbSkip())
Enddo

RestOrd(aOrd)

Return aRet

/*
    Funcao   : BUSCACLIENTE(pCODIGO)
    Autor    : AVERAGE
    Data     :
    Revisao  :
    Uso      :
    Recebe   :
    Retorna  :

*/
FUNCTION BuscaCliente (PCliente,lREDUZIDO)
   LOCAL cRET:=""
   DEFAULT lREDUZIDO:=.F.
   IF SA1->( DBSEEK(xFilial("SA1")+PCliente) )
      cRET:=IF(lREDUZIDO,SA1->A1_NREDUZ,SA1->A1_NOME)
   ENDIF
RETURN cRET


/*
Funcao      : AVReplace(cOrigem,cDestino)
Parametros  : cOrigem  := Alias do arquivo Origem ou "M" para variavel de memoria
              cDestino := Alias do arquivo Destino ou "M" para variavel de mem.
Retorno     : Nenhum
Objetivos   : Gravar dados de um arquivo a partir de outro
Autor       : Cristiano A. Ferreira
Data/Hora   : 27/07/99 11:34
Revisao     : Gravação de campos virtuais, qdo destino for uma Work.
Obs.        :
*/
FUNCTION AVReplace(cOrigem,cDestino)

//Static aCposV - RMD - 09/04/19 - Substituido por HashMap
//Static oCposV := tHashMap():New()
Local aCposV
Local i, nFieldCount
Local cFieldO, bFieldO, cbFieldO
Local cFieldD, bFieldD
Local cPrefixoD := Upper(IF(Left(cDestino,1) == "S",Right(cDestino,2),Right(cDestino,3)))
//Local lCopyVirtual := .f.
Local aOrdSX3, bLastHandler, xData
Local nFPos
Local cPrefixo, cVar1, cVar2
//Local aOrdSX2 := SaveOrd("SX2") - RMD - 08/04/19 - Retirado pois o SX2 não é desposicionado nesta rotina

Default cOrigem  := "M"

Begin Sequence

   cOrigem  := Upper(AllTrim(cOrigem))
   cDestino := Upper(AllTrim(cDestino))

   IF cOrigem == cDestino
      Help("",1,"AVG0001026",,STR0044 +ProcName(1)+STR0045 +ProcLine(1),2,18)//"Alias do arquivo Origem igual ao Destino."//"Rotina: "//"Linha: "###"Erro na função AVReplace"
      Break
   Endif

   IF cDestino == "M"
      Help("",1,"AVG0001027",,STR0048+ProcName(1)+STR0049+ProcLine(1),2,1)//"Alias Destino não pode ser M !"//"Rotina: "//"Linha: "###"Erro na função AVReplace"
      Break
   Endif

   IF Select(cOrigem) == 0 .And. cOrigem != "M"
      Help("",1,"AVG0001028",,STR0052+ProcName(1)+STR0053+ProcLine(1),2,1)//"Alias do arquivo Origem não existe."//"Rotina: ""Linha: "###"Erro na função AVReplace"
      Break
   Endif

   IF Select(cDestino) == 0
      Help("",1,"AVG0001029",,STR0056+ProcName(1)+STR0057+ProcLine(1),2,1)//"Alias do arquivo Destino não existe."//"Rotina: "//"Linha: "###"Erro na função AVReplace"
      Break
   Endif

   //TRP - 21/12/2011 - Para evitar erro nos inicializadores padrão na chamada do AvReplace (alguns campos da memória são considerados).
   //NOPADO POR - AOM  - 26/12/2011 - Esse tratamento está desposicionando a Tabela SX2
   /*SX2->(DbSetOrder(1))
   If SX2->(DbSeek(cOrigem))
      RegToMemory(cOrigem,.F.,,.F.)
   Endif */

   //RestOrd(aOrdSX2,.F.) - RMD - 08/04/19 -Retirado pois o SX2 não estava sendo desposicionado

   // by CAF 13/01/2005 - Copiar campos virtuais para Work.
   If !EasyGetBuffers("AVREPLACE",cOrigem,@aCposV)//!oCposV:Get(cOrigem, @aCposV)
   /*
   IF ValType(aCposV) == "A" .And. aCposV[1] == cOrigem
      lCopyVirtual := .t.
   Else*/
      aCposV  := {}
      //RMD 26/03/19 - Somente grava a ordem se for necessário desposicionar
      //aOrdSX3 := SaveOrd("SX3",1)

      //IF !SX3->(dbSeek(cDestino)) .And. SX3->(dbSeek(cOrigem)) - RMD - 08/04/19 - Utiliza uma função com buffer para checar se a work existe na base de dados
      IF !IsInSx2(cDestino) .And. IsInSx2(cOrigem)
         // Se a Origem for um campo do Dicionário e o Destino for uma Work (não está no SX2)
         aOrdSX3 := SaveOrd("SX3",1)
         SX3->(dbSeek(cOrigem))
         // Montar array com os campos virtuais.
         //aCposV := {cOrigem}

         // SX3 já posicionado pelo seek acima
         While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cOrigem
            IF SX3->X3_CONTEXT == "V" .And. !Empty(SX3->X3_RELACAO)
               //RMD - 27/03/19 - Guarda mais informações sobre o campo virtual no buffer para não precisar posicionar o SX3 novamente e melhorar a performance
               IF (cDestino)->(FieldPos(SX3->X3_CAMPO)) > 0 .And. CheckPosicione(SX3->X3_RELACAO)
                  //lCopyVirtual := .t.
                  //aAdd(aCposV,SX3->X3_CAMPO) 
                  aAdd(aCposV,{SX3->X3_CAMPO, SX3->X3_RELACAO})
               Endif
            Endif
            SX3->(dbSkip())
         Enddo

         //oCposV:Set(cOrigem, aCposV)
         EasySetBuffers("AVREPLACE",cOrigem,@aCposV)

         /*IF !lCopyVirtual
            aCposV := NIL
         Endif
         */
         RestOrd(aOrdSX3,.T.)
      Endif
      //RestOrd(aOrdSX3,.T.) - RMD - 08/04/19 - Somente reposiciona se tiver mudado a ordem/posicionamento
   Endif

   IF cOrigem != "M"
      nFieldCount := (cOrigem)->(FCount())
   Else
      nFieldCount := (cDestino)->(FCount())
   Endif

   For i:=1 To nFieldCount

      cFieldO := cFieldD := bFieldO := bFieldD := Nil

      IF cOrigem != "M"
         cFieldO := (cOrigem)->(FieldName(i))
         cFieldD := cFieldO
      Else
         cFieldD := (cDestino)->(FieldName(i))
         cFieldO := cFieldD
      Endif

      IF Empty(cFieldO) .And. Empty(cFieldD)
         Loop
      Endif
      /*
      IF Empty(cFieldO)
         bFieldO := MemVarBlock(cFieldD)
         IF TYPE("M->"+cFieldD) = "U"
            Loop
         Endif
      Else
         bFieldO := FieldWBlock(cFieldO,Select(cOrigem))
      Endif

      //IF Empty(Eval(bFieldO))
      //   Loop
      //Endif

      IF Empty(cFieldD)
         IF cDestino == "M"
            bFieldD := MemVarBlock(cFieldO)
            // IF bFieldD == Nil
            IF ValType(bFieldD) != "B"
               Loop
            Endif
         Else
            IF (cDestino)->(FieldPos(cFieldO)) == 0
               Loop
            Else
               bFieldD := FieldWBlock(cFieldO,Select(cDestino))
            Endif
         Endif
      Else
         bFieldD := FieldWBlock(cFieldD,Select(cDestino))
      Endif

      IF Empty(cFieldD)
         cFieldD := cFieldO
      Endif

      //IF "FILIAL" $ Upper(cFieldD)
      //   Eval(FieldWBlock(cFieldD,Select(cDestino)),xFilial(cDestino))
      //   Loop
      //Endif

      // RA - 08/11/2003 - O.S. 1177/03 - Inicio
      // A gravacao da Filial esta no Final da Funcao
      // by CAF 02/02/2005 - Alteração para tratar o prefixo do campo, estava com problema nos arquivos
      // Header e Detail
      If cPrefixoD+"_FILIAL" == Upper(AllTrim(cFieldD))
         Loop
      EndIf
      // RA - 08/11/2003 - O.S. 1177/03 - Final

      Eval(bFieldD,Eval(bFieldO))*/

      //** AAF 11/07/2013 - Melhorar performance
	  If cOrigem == "M"
	     If Type("M->"+cFieldO) == "U"
	        Loop
	     EndIf

	     uInfo := &("M->"+cFieldO)
	  Else
	     If (nFPos := (cOrigem)->(FieldPos(cFieldO))) > 0
	        uInfo := (cOrigem)->(FieldGet(nFPos))
	     Else
	        Loop
	     EndIf
	  EndIf

	  If cDestino == "M"
	     If Type("M->"+cFieldD) == "U"
	        Loop
	     EndIf

	     &("M->"+cFieldD) := uInfo
	  Else
	     If (nFPos := (cDestino)->(FieldPos(cFieldD))) > 0
   	        (cDestino)->(FieldPut(nFPos,uInfo))
   	     Else
   	        Loop
   	     EndIf
	  EndIf
	  //**
   Next i

   // by CAF 13/01/05 - Gravação dos campos virtuais
   IF ValType(aCposV) == "A"
      //RMD - 26/03/19 - As verificações do SX3 já são feitas ao adicionar o campo no array
      //aOrdSX3 := SaveOrd("SX3",2) 
      For i:=2 To Len(aCposV)
         cFieldD := aCposV[i][1]
         bFieldD := FieldWBlock(cFieldD,Select(cDestino))

         // Pegar inicializador padrão
         /* RMD - 26/03/19 - Utiliza as informações do buffer
         SX3->(dbSeek(cFieldD))
         IF /*!Empty(bFieldO) .And. /CheckPosicione(SX3->X3_RELACAO)
            bFieldO := "{|| "+SX3->X3_RELACAO+" }"
         Else
            Loop
         Endif
         */
         cbFieldO := "{|| " + aCposV[i][2] + " }"

         //AAF - força um break para cair direto no end sequence se der erro no inicializador.
         //Antes com o retorno .F., a execução seguia e aconteciam outros erros que geravam um access violation no server nas versoes mais recentes do lobo guara 19.
         //bLastHandler := ErrorBlock({|| .f. }) 
         bLastHandler := ErrorBlock({|| mybreak() }) 
         Begin Sequence
            //RegToMemory("SY5",.T.) //LRS - 19/05/2015 - deve ser tratado na origem da chamada
            bFieldO := &(cbFieldO)
            xData := Eval(bFieldO)
            IF ValType(xData) == ValType(Eval(bFieldD))
               Eval(bFieldD,xData)
            Endif
         End Sequence
         ErrorBlock(bLastHandler)
      Next i
      //RestOrd(aOrdSX3,.t.)
   Endif

   // RA - 08/11/2003 - O.S. 1177/03 - Inicio
   // Se existir o campo Filial no Arquivo Destino, grava nele a xFilial()
   // by CAF 02/02/2005 - Revisão gravação do campo filial
   IF (cDestino)->(FieldPos(cPrefixoD+"_FILIAL")) != 0
      (cDestino)->(FieldPut(FieldPos(cPrefixoD+"_FILIAL"),xFilial(cDestino)))
   EndIf

   // by CAF 02/02/2005 - Gravação dos campos memos automaticamente.
   /*
   IF Type("aMemos") == "A"
      For i := 1 to Len(aMemos)
         cPrefixo := Substr(aMemos[i][1],1,At("_",aMemos[i][1])-1)
         cPrefixo := IF(Len(cPrefixo) == 2, "S"+cPrefixo, cPrefixo)

         IF cPrefixo <> cDestino
            Loop
         Endif

         IF Type("M->"+aMemos[i][1]) <> "C" .Or.Type("M->"+aMemos[i][2]) <> "C"
            Loop
         Endif

         cVar1 := aMemos[i][1]
         cVar2 := aMemos[i][2]

         MSMM(&cVar1,TamSx3(aMemos[i][2])[1],,&cVar2,1,,,cDestino,aMemos[i][1])
         // Locar o registro, pois a MSMM desaloca o registro.
         (cDestino)->(RecLock(cDestino,.F.))
      Next i
   Endif
   */

End Sequence

Return NIL

static function mybreak()
BREAK
return

/*
Função   : IsInSx2
Parametro: cAlias - Alias a ser avaliado
Objetivo : Verifica se o Alias existe no SX2 e guarda um buffer com a informação para otimizar performance
Autor    : Rodrigo Mendes Diaz
Data     : 26/03/19
*/
Static Function IsInSx2(cAlias)
Local lRet := .F.
//Static oIsInSx2 := tHashMap():New() //RMD 27/03/19

   If !EasyGetBuffers("IsInSx2",cAlias,@lRet)//oIsInSx2:Get(cAlias, @lRet)
      lRet := SX2->(DbSeek(cAlias))
      EasySetBuffers("IsInSx2",cAlias,@lRet)//oIsInSx2:Set(cAlias, lRet)
   EndIf

Return lRet

/*
Função   : CheckPosicione
Parametro: cRelacao - Chave de inicializador padrão
Objetivo : Verifica se existe um Posicione na chave de inicializador padrão e, caso positivo,
           valida a chave de busca, pois se a mesma retornar Nil causaria erro na função MsSeek (chamada do Posicione)
Autor    : Rodrigo Mendes Diaz
Data     : 29/11/12
*/
Static Function CheckPosicione(cRelacao)
Local nAt
Local lRet := .T.
Local aLimpa := {"POSICIONE", "(", ",", ","}
Local i, bLastHandler
Private lErro := .F.

Begin Sequence

	cRelacao := Upper(cRelacao)

	//Função não está preparada quando há encadeamento de condição na chamada do posicione().
	If At(aLimpa[1], cRelacao) > 0 .And. At("IF", cRelacao) > 0
	   Break
	EndIf

	//Verifica se trata-se de um posicione e limpa as informações a fim de isolar a chave de busca
	For i := 1 To Len(aLimpa)
		If (nAt := At(aLimpa[i], cRelacao)) > 0
			cRelacao := SubStr(cRelacao, nAt + 1)
		Else
			Exit
		EndIf
	Next

	If nAt > 0 .And. (nAt := At(",", cRelacao)) > 0
		//Esta é a chave do posicione
		cRelacao := Left(cRelacao, nAt - 1)
		//MCF - 22/07/2016 - Try/catch não entrava no Catch quando &(cRelacao) apresentava erro na versão 12.
		/*TRY
			//Testa a chave para verificar se ela não é inválida
			cRelacao := &(cRelacao)
		CATCH
			//Se a chave for inválida, retorna .F. a fim de não dar erro no MsSeek
			lRet := .F.
		END TRY*/
		bLastHandler := ErrorBlock({||lErro := .T.,.F.})
		cRelacao := &(cRelacao)
		If lErro
		   lRet := .F.
		EndIf
		ErrorBlock(bLastHandler)
	EndIf

End Sequence
Return lRet

/*
Funcao      : AVKey(xInformacao,cCpo)
Parametros  : xInformacao := Informacao a ser pesquisada
              cCpo        := Campo no qual a informacao sera formatada
Retorno     : Informacao a ser pesquisada
Objetivos   : Formatar a informacao de pesquisa de acordo com o SX3
Autor       : Cristiano A. Ferreira
Data/Hora   : 04/08/99 11:14
Revisao     :
Obs.        :
*/
FUNCTION AVKey(xInformacao,cCpo,lTruncar,aEstru)

Local cRet := "", aSX3, cType, cMsg
Default lTruncar := .T. //RRC - 18/04/2013 - Indica se deve truncar a informação caso esta seja maior que o tamanho do campo informado
Begin Sequence

   If ValType(aEstru) == "A"
        aSX3 := aEstru
   Else
        aSX3 := AVSX3(cCpo)
   EndIf

   IF aSX3[3] == 0 //Se o tamanho eh zero, logo nao achou no SX3
      Break
   Endif

   cType := ValType(xInformacao)

   do Case
      Case cType == "N"
         cRet := Str(xInformacao,aSX3[3],aSX3[4])

      Case cType == "D"
         cRet := Dtos(xInformacao)

      Case cType == "C"
         IF Len(xInformacao) > aSX3[3]
            //RRC - 18/04/2013 - Indica se deve truncar a informação caso esta seja maior que o tamanho do campo informado
            If lTruncar
               cRet := Left(xInformacao,aSX3[3])
            Else
               cRet := xInformacao
            EndIf
         Else
            cRet := xInformacao+Space(aSX3[3]-Len(xInformacao))
         Endif

   OtherWise

      cMsg := STR0059+"  " //"Erro no uso da função AVKey:"
      cMsg += STR0060+"  " //"Função não compatível com o tipo de dado !"
      cMsg += STR0061+ProcName(1)+STR0062+LTrim(Str(ProcLine(1))) //"Procedure "###", linha "

      Help("",1,"AVG0001030",,cMsg,1,1) //MsgStop(cMsg,"Aviso")

   end Case

End Sequence

Return cRet

*------------------------------------*
FUNCTION ExtPlusE(Valor,Moeda,cIdioma)
*------------------------------------*
Local SingMoeda,PlurMoeda,SingCent,PlurCent, Extenso:="", ParteInteira,;
      VlString, Bilhoes, Milhoes, Milhares, Centenas, Centavos
Local aOrd := SaveOrd({"SYF","EE2"})
Local bRestore:= {|| RestOrd(aOrd) }
// by CAF 28/08/2002 - Codigo do Idioma Ingles
Local cIngles := AvKey(IncSpace(EasyGParam("MV_AVG0037",,"INGLES"), 6, .F.),"X5_CHAVE")
Local cMsg		:= "" //LGS-31/05/2016
Default cIdioma := "" //LGS-31/05/2016

If !Empty(cIdioma) .And. cIdioma == "ESP." //LGS-31/05/2016
   cIngles := AvKey(IncSpace(cIdioma,6,.F.),"X5_CHAVE")
Else
   // ** By JBJ - 11/10/02 - 14:26 - Codigo do Idioma Ingles a partir do parâmetro MV_AVG0037.
   If EasyGParam("MV_AVG0037",.t.,)
      //ACB - 05/01/2011 
      cIngles := Avkey(EasyGParam("MV_AVG0037",.f.,),"X5_CHAVE")
   
      If Empty(cIngles) .Or. cIngles == "."
         cIngles := AvKey(IncSpace(EasyGParam("MV_AVG0037",,"INGLES"), 6, .F.),"X5_CHAVE")
      EndIf
   EndIf

   If Empty(Posicione("SX5",1,xFilial("SX5")+"ID"+cIngles,"X5_DESCRI"))
      // Quando integrado com o SAP, utiliza "I"
      cIngles := AvKey("I","X5_CHAVE")
   Endif
   
   cIdioma := "" //Só para garantir que vai estar vazia //LGS-31/05/2016
EndIf

cIngles := cIngles+"-"+Tabela("ID",cIngles)

SYF->(dbSetOrder(1))
EE2->(dbSetOrder(1))

IF ! SYF->(DBSEEK(xFilial()+Moeda))
   Eval(bRestore)
   RETURN "****** INVALID CURRENCY *******"
ELSE
   if ! EE2->(DBSEEK(xFilial("EE2")+"4*"+AVKey(cIngles,"EE2_IDIOMA")+AVKey(Moeda,"EE2_COD")))
      cMsg := If(Empty(cIdioma),STR0151,STR0269)  //LGS-31/05/2016
      RETURN "*** " + cMsg +MOEDA //## STR0151 -> "DESCRICAO EM INGLES NAO CADASTRADO PARA A MOEDA "
   endif
   SingMoeda:= ALLTRIM(EE2->EE2_DESC_S)
   PlurMoeda:= ALLTRIM(EE2->EE2_DESC_P)
   SingCent := If(Empty(cIdioma), STR0063, STR0311) //"Cent"  - centavo
   PlurCent := If(Empty(cIdioma), STR0064, STR0312) //"Cents" - centavos
ENDIF

Eval(bRestore)

IF Valor <= 0
   RETURN STR0065 //"Zero"
ELSEIF Valor > 999999999999.99
   RETURN STR0066 //"*** Error: Value bigger than 999.999.999.999,99 ***"
ENDIF

VlString    := STRZERO(Valor,15,2)
ParteInteira:= VAL(SUBSTR(VlString,01,12))
Bilhoes     := SUBSTR(VlString,01,3)
Milhoes     := SUBSTR(VlString,04,3)
Milhares    := SUBSTR(VlString,07,3)
Centenas    := SUBSTR(VlString,10,3)
Centavos    := "0"+SUBSTR(VlString,14,2)

IF VAL(Bilhoes) # 0
   If Empty(cIdioma) //LGS-31/05/2016
      Extenso:= VlCentenas(Bilhoes,cIdioma)+IF(VAL(Bilhoes) = 1,STR0067,STR0068)//" billion"###" billions"
   Else
      Extenso:= VlCentenas(Bilhoes,cIdioma)+IF(VAL(Bilhoes) = 1,STR0270,STR0271)//" billion"###" billions"
   EndIf
ENDIF

IF VAL(Milhoes) # 0
   If Empty(cIdioma) //LGS-31/05/2016
      Extenso:= Extenso + IF(LEN(Extenso)#0," , ","") + ;
            VlCentenas(Milhoes,cIdioma) + IF(VAL(Milhoes) = 1,STR0069,STR0070)//" million"###" millions"
   Else
      Extenso:= Extenso + IF(LEN(Extenso)#0," , ","") + ;
            VlCentenas(Milhoes,cIdioma) + IF(VAL(Milhoes) = 1,STR0272,STR0273)//" million"###" millions"
   EndIf
ENDIF

IF VAL(Milhares) # 0
   If Empty(cIdioma) //LGS-31/05/2016
      Extenso:= Extenso + IF(LEN(Extenso)#0," , ","") + ;
            VlCentenas(Milhares,cIdioma) + STR0071 //" thousand"
   Else
      Extenso:= Extenso + IF(LEN(Extenso)#0," , ","") + ;
            VlCentenas(Milhares,cIdioma) + STR0274 //" thousand"
   EndIf
ENDIF

IF VAL(Centenas) # 0
   Extenso:= Extenso + IF(LEN(Extenso)#0," , ","") + VlCentenas(Centenas,cIdioma) //LGS-31/05/2016 //Extenso + IF(LEN(Extenso)#0," and ","") + VlCentenas(Centenas)
ENDIF

IF ParteInteira # 0
   IF ( VAL(Bilhoes)  # 000 .OR.  VAL(Milhoes)  # 000 ) .AND.;
      ( VAL(Milhares) = 000 .AND. VAL(Centenas) = 000 )
       Extenso:= Extenso //+ " of"
   ENDIF
   Extenso:= Extenso + IF(ParteInteira=1," " + SingMoeda," " + PlurMoeda)
ENDIF

IF VAL(Centavos) # 0
   Extenso:= Extenso + IF(LEN(Extenso)#0," and ","") + ;
            VlCentenas(Centavos,cIdioma) + IF(VAL(Centavos)=1," " + SingCent," " + PlurCent) //LGS-31/05/2016
ENDIF

RETURN (UPPER(SUBSTR(Extenso,1,1))+SUBSTR(Extenso,2))

*------------------------------------*
FUNCTION VlCentenas(Numero,cRelIdioma)
*------------------------------------*
LOCAL VlExtenso:= "", Num1:= VAL( SUBSTR(Numero,1,1) ),;
      Num2:= VAL( SUBSTR(Numero,2,1) ), Num3:= VAL( SUBSTR(Numero,3,1) )

LOCAL Unidades:={STR0072, STR0073, STR0074, STR0075, STR0076, STR0077, STR0078    ,;//"one"###"two"###"three"###"four"###"five"###"six"###"seven"
				  STR0079,STR0080, STR0081, STR0082, STR0083, STR0084, STR0085 ,; //"eight"###"nine"###"ten"###"eleven"###"twelve"###"thirteen"###"fourteen"
               STR0086, STR0087, STR0088, STR0089, STR0090}//"fifteen"###"sixteen"###"seventeen"###"eighteen"###"nineteen"

LOCAL Dezenas:={STR0091, STR0092, STR0093, STR0094, STR0095,;//"ten"###"twenty"###"thirty"###"forty"###"fifty"
              STR0096, STR0097, STR0098, STR0099}//"sixty"###"seventy"###"eighty"###"ninety"

LOCAL Centenas:={STR0100, STR0101, STR0102, STR0103           ,;//"one hundred"###"two hundred"###"three hundred"###"four hundred"
               STR0104, STR0105, STR0106, STR0107     ,;//"five hundred"###"six hundred"###"seven hundred"###"eight hundred"
               STR0108}//"nine hundred"

Default cRelIdioma := "" //LGS-31/05/2016

If !Empty(cRelIdioma) .And. cRelIdioma == "ESP." //LGS-31/05/2016
   Unidades:={ STR0275, STR0276, STR0277, STR0278, STR0279, STR0280, STR0281 ,;
				 STR0282, STR0283, STR0284, STR0285, STR0286, STR0287, STR0288 ,;
               STR0289, STR0290, STR0291, STR0292, STR0293}

   Dezenas:={ STR0284, STR0294, STR0295, STR0296, STR0297 ,;
              STR0298, STR0299, STR0300, STR0301}

   Centenas:={ STR0302, STR0303, STR0304, STR0305 ,;
               STR0306, STR0307, STR0308, STR0309 ,;
               STR0301}
EndIf

IF Num1 # 0
   IF Num1 = 1 .AND. Num2 = 0 .AND. Num3 = 0
      VlExtenso:= If(!Empty(cRelIdioma) .And. cRelIdioma == "ESP.",STR0302,STR0109) //"One Hundred" //LGS-31/05/2016
   ELSE
      VlExtenso:= Centenas[Num1]
   ENDIF
ENDIF

IF Num2 # 0
   IF Num2 < 2
      // VlExtenso:= VlExtenso + IF(LEN(VlExtenso)#0," and ","") + Unidades[(Num2*10+Num3)]
      VlExtenso:= VlExtenso+" "+Unidades[(Num2*10+Num3)]
   ELSE
      VlExtenso:= VlExtenso + IF(LEN(VlExtenso)#0," and ","") + Dezenas[Num2]
      IF Num3 # 0
        // VlExtenso:= VlExtenso + IF(LEN(VlExtenso)#0," and ","") + Unidades[Num3]
        VlExtenso:= VlExtenso+" "+Unidades[Num3]
      ENDIF
   ENDIF
ELSEIF Num3 # 0
   // VlExtenso := VlExtenso+IF(LEN(VlExtenso)#0," and ","") + Unidades[Num3]
   VlExtenso:= VlExtenso+" "+Unidades[Num3]
ENDIF

RETURN (VlExtenso)

/*
Funcao      : IsVazio(cAlias,bCond)
Parametros  : cAlias := Alias do Arquivo
              bCond  := Code Block que retorna .T. ou .F. (opicional)
Retorno     : .T./.F.
Objetivos   : Verificar se o arquivo tem registros
Autor       : Cristiano A. Ferreira
Data/Hora   : 04/08/99 11:14
Revisao     :
Obs.        :
Exemplo     : IsVazio("SW2",{|| W2_MARCA == cMarca})
*/
Function IsVazio(cAlias,bCond)

Local lRet    := .T.
Local nRecOld := (cAlias)->(RecNo())

Local bWhile  := {|| .t.}
Local cCpo

Default bCond := {|| .t. }

Begin Sequence

   IF At("FILIAL",(cAlias)->(IndexKey())) != 0
      (cAlias)->(dbSeek(xFilial()))
      cCpo   := IF(Left(cAlias,1) == "S",Subst(cAlias,2),cAlias)+"_FILIAL"
      bWhile := {|| FieldGet(FieldPos(cCpo)) == xFilial(cAlias) }
   Else
      (cAlias)->(dbGoTop())
   Endif

   While (cAlias)->(!Eof() .And. Eval(bWhile))
      IF ! Eval(bCond)
         (cAlias)->(dbSkip())
         Loop
      Endif

      lRet := .F.

      Exit
   Enddo

End Sequence

(cAlias)->(dbGoTo(nRecOld))

Return lRet


/*
Funcao      : saveOrd
Parametros  : xAlias := Nome do Alias ou Array com Nome dos Alias
              nOrdem := Nova Ordem a ser Posicionado
                        Usado qdo salva um alias
Retorno     : Array com a ordem, e registro salvo
Objetivos   : Salvar a Ordem e o Registro
Autor       : Cristiano A. Ferreira
Data/Hora   : 27/09/99 11:32
Revisao     :
Obs.        :
*/
Function saveOrd(xAlias,nOrdem)
Local aRet:={}, cAlias, i

xAlias := if(ValType(xAlias) == "C",{xAlias},xAlias)

Begin Sequence
   For i:=1 To Len(xAlias)
      cAlias := xAlias[i]
      aAdd(aRet,{cAlias,(cAlias)->(IndexOrd()),(cAlias)->(RecNo())})
      IF nOrdem != nil .And. Len(xAlias) == 1
         (cAlias)->(dbSetOrder(nOrdem))
      Endif
   Next i
End Sequence

Return aRet

/*
Funcao      : restOrd
Parametros  : aOrd := Array retornado pela salveOrd
Retorno     : Nenhum
Objetivos   : Restaurar a Ordem e o Registro
Autor       : Cristiano A. Ferreira
Data/Hora   : 27/09/99 11:36
Revisao     :17/04/2000 Heder M Oliveira
Obs.        :
*/
Function restOrd(aOrd,lReg)
Local i, cAlias
default lReg:=.f.
Begin Sequence
   For i:=1 To Len(aOrd)
      cAlias := aOrd[i][1]
      (cAlias)->(dbSetOrder(aOrd[i][2]))

      // by CAF 28/10/02 IF lReg
      // Verificar se o Nro. do Registro é válido, para executar o dbGoTo
      IF lReg .And. aOrd[i][3] > 0
         (cAlias)->(dbGoTo(aOrd[i][3]))
      ENDIF
   Next
End Sequence
Return NIL

/*
Funcao      : AVSeekLast
Parametros  : cKey      := Chave a ser pesquisada
              lSoftSeek := Qdo true, se nao encontrar posiciona na ocorrencia mais
                           proxima. (opcional)
Retorno     : .T./.F.
Objetivos   : Pesquisa a ultima ocorrencia de xKey
Autor       : Cristiano A. Ferreira
Data/Hora   : 29/08/99 14:23
Revisao     : 01/12/05 - João Pedro Macimiano Trabbold - Tratamentos para os caracteres '9', 'Z' e 'z'.
Obs.        :
*/
Function AVSeekLast(cKey,lSoftSeek, lADS)
Local lFound := .f.
Local nRecNo := 0
Local bIndexKey := &("{|| "+IndexKey()+" }")
Local cAux, cRight, aCpo, cIndKey, n, cAtu, cCpo, cCpo2, nLen, nStart, lStop, aInd
Local nLenKey := Len(cKey)
Local lSelect
Default lSoftSeek := .f.
Default lADS := .F.

Begin Sequence
   IF Len(Eval(bIndexKey)) < nLenKey
      cKey := Left(cKey,Len(Eval(bIndexKey)))
   Endif

   cRight := Right(cKey,1)

   // ** JPM - 01/12/05
   If Len(cRight) > 0 .And. !lADS
      lSelect := (RddName() == "TOPCONN" .And. !((Asc(cRight) >= 48 .And. Asc(cRight) <= 56 ) .Or.; // números de 1 a 8
                                                 (Asc(cRight) >= 65 .And. Asc(cRight) <= 89 ) .Or.; // letras de 'A' a 'Y'
                                                 (Asc(cRight) >= 97 .And. Asc(cRight) <= 121))  )   // letras de 'a' a 'y'
   Else
      lSelect := .f.
   EndIf

   //RRC - 02/09/2013 - Impede a chamada da função AvAuxSeekLast() pois a mesma necessita de revisão já que possibilitou erro de chave duplicada
   lSelect := .F.

   If lSelect .AND. !( Upper(TcSrvType() ) == "AS/400" )    //TRP-02/07/07
      aCpo := {}
      aInd  := {}
      cIndKey := AllTrim(IndexKey())
      nStart  := 1
      lStop := .f.
      // separa as chaves passadas no seek
      While Len(AllTrim(cIndKey)) > 0 // enquanto houver chave a ser tratada
         n := At("+",cIndKey) // procura o próximo sinal '+'
         If n > 0
            cCpo := AllTrim(SubStr(cIndKey,1,n-1)) // separa um campo da chave
            cIndKey := SubStr(cIndKey,n+1)         // recorta a chave, tirando o campo que foi separado, juntamente com o '+'
         Else
            cCpo := AllTrim(cIndKey) //separa o último campo da chave.
            If Len(cCpo) = 0
               Exit
            EndIf
            cIndKey := ""
         EndIf

         If !lStop
            nLen := Len(&(cCpo)) // tamanho do campo
            cAtu := SubStr(cKey,nStart,nLen) // chave passada para este campo
            If Len(cAtu) = 0 // se não passou a chave atual
               lStop := .t.  // não armazena mais as chaves no array de chaves, apenas no array dos campos de ordenação (aInd)
            EndIf
         EndIf

         If (n := At("DTOS",Upper(cCpo))) > 0 /* as chaves do SIX costumam usar DTOS (pra data) e STR (para numérico), porém o
                                                 SQL reconhece apenas o STR, e o DTOS já é o formato de data do protheus no SQL */
            cCpo2 := StrTran(Upper(cCpo),"DTOS","")
         Else
            cCpo2 := cCpo
         EndIf

         If !lStop
            AAdd(aCpo,{cCpo2,cAtu,1,cCpo})
            nStart := (nStart + nLen)
         EndIf
         AAdd(aInd, cCpo2)
      EndDo
      AvAuxSeekLast(aCpo,aInd) // procura através de Query
   Else
      nAuxCh := Asc(cRight)+1
      If nAuxCh > Asc("9") .AND. nAuxCh < Asc("A")
         nAuxCh := Asc("A")
      EndIf
      cAux := Substr(cKey,1,nLenKey-1)+Chr(nAuxCh)
      dbSeek(cAux,.t.)
      dbSkip(-1)
   EndIf
   // ** JPM

   lFound := (cKey == Left(Eval(bIndexKey),nLenKey))

   IF ! lSoftSeek .And. !lFound
       DbGoBottom() // Eof - chave nao encontrada.
       DbSkip()
   Endif

End Sequence

If Select("WkSeek") > 0
   WkSeek->(DbCloseArea())
EndIf

Return lFound

/*
Função     : AvAuxSeekLast()
Objetivos  : executar a query para AvSeekLast
Parâmetros : aCpo -> array bidimensional com campos
             aInd -> array unidimensional com indice
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 01/12/05 às 10:53
Obs.       : Função Recursiva.
*/
*--------------------------------------*
Static Function AvAuxSeekLast(aCpo,aInd)
*--------------------------------------*
Local cQry, i, j, cCpo, cAlias := Alias(), nLike, cVar, nLen

Begin Sequence
   cVar := aCpo[Len(aCpo)][2]
   If ValType(cVar) = "C" .And. (nLen := Len(&(aCpo[Len(aCpo)][4])) - Len(cVar)) > 0
      aCpo[Len(aCpo)][2] += Repl(Chr(255),nLen)
   EndIf

   cQry := "Select R_E_C_N_O_ REC From " + RetSqlName(Alias()) + " " + Alias() + " "
   cQry += "Where D_E_L_E_T_ <> '*' "
   For i := 1 To Len(aCpo)
      cQry += "And " + aCpo[i][1] + If(i==Len(aCpo)," > "," = ") + " '" + aCpo[i][2] + "' "
   Next
   i--

   cCpo  := AllTrim(cVar)
   nLike := aCpo[i][3]

   cQry += "And " + aCpo[i][1] + " Like '" + Left(cCpo,Len(cCpo)-nLike) + Repl("%",nLike)+ "' "

   cQry += "Order By "
   For j := 1 To Len(aInd)
      cQry += aInd[j] + ", "
   Next
   cQry += "R_E_C_N_O_ " // o recno é sempre o último elemento da chave,

   aCpo[Len(aCpo)][2] := cVar

   cQry:=ChangeQuery(cQry)
   dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "WkSeek", .F., .T.)
   DbSelectArea(cAlias)
   If WkSeek->(EoF())
      WkSeek->(DbCloseArea())
      If nLike > Len(cCpo)
         If Len(aCpo) > 1
            ADel(aCpo,Len(aCpo))
            ASize(aCpo,Len(aCpo)-1)
         Else
            DbGoBottom()
            Return Nil
         EndIf
      Else
         aCpo[i][3]++ //incrementa o número de caracteres-coringa no Like
      EndIf
      AvAuxSeekLast(aCpo,aInd)
   Else
      DbGoTo(WkSeek->REC)
      DbSkip(-1)
   EndIf

End Sequence

Return Nil

/*
    Funcao   : SETMV(cID,xVALOR)
    Autor    : Heder M Oliveira
    Data     : 27/10/99 9:19
    Revisao  : 27/10/99 9:19
    Uso      : Gravar Variavel no SX6
    Recebe   : cID := Variavel MV_???????
			   xVALOR:=valor a ser gravado
    Retorna  : .T./.F.

*/
FUNCTION SETMV(cID,xVALOR)
   LOCAL lRET:=.F.
   lRet := PutMv(cID, xValor)
RETURN lRET

*---------------------------------*
Function E_MarkbAval(oMark,bBlock)
*---------------------------------*
IF VALTYPE(oMark) = "O" .AND. VALTYPE(bBlock) = "B"
   oMark:bAval:=bBlock
ENDIF
RETURN NIL

/*
Funcao      : SizeGets(oDlg)
Parametros  : oDlg
Retorno     : NIL
Objetivos   : Acerta o size dos gets baseado no len das variaveis ou pictures
Autor       : Cristiano A. Ferreira
Data/Hora   : 04/11/99 10:41
Revisao     :
Obs.        :
*/
Function SizeGets(oDlg)

Local i, nWidth
Local oGet, cPict, nLen, xBuffer
Local nAux := oDlg:GetWidth("A")

Begin Sequence
   For i:=1 To Len(oDlg:aControls)

      IF oDlg:aControls[i]:ClassName() != "TGET"
         Loop
      Endif

      oGet := oDlg:aControls[i]
      xBuffer := Eval(oGet:bSetGet)

      IF !Empty(cPict:= oGet:oGet:picture)
         nLen := Len(Transform(xBuffer,cPict))
      Else
         cType := ValType(xBuffer)
         do Case
            Case cType == "C"
               nLen := Len(xBuffer)
            Case cType == "N"
               nLen := 10
            Case cType == "D"
               nLen := 10
         End Case
ENDIF

      nWidth := nAux*nLen

      oGet:nWidth := nWidth
      oGet:Refresh()
   Next
End Sequence

RETURN NIL

/*
Funcao      : ValidAll(oDlg)
Parametros  : oDlg
Retorno     : .T./.F.
Objetivos   : Executa todas a validacoes da janela
Autor       : Cristiano A. Ferreira
Data/Hora   : 04/11/99 10:41
Revisao     :
Obs.        :
 */
Function ValidAll(oDlg)

Local bReadVar := MemVarBlock("__ReadVar")
Local lRet := .t.
Local cReadVOld := Eval(bReadVar)
Local bVld := nil
Local o, i

For i:=1 To Len(oDlg:aControls)

   o := oDlg:aControls[i]

   IF At(Upper(AllTrim(o:ClassName())),"TGET,TRADIO,TCHECKBOX,TCOMBOBOX") == 0
      Loop
   Endif

   Eval(bReadVar,o:cReadVar)

   bVld := o:bValid

   IF ValType(bVld) == "B" .And. ! Eval(bVld,o)
      oSend(o,"SetFocus")
      lRet := .f.
      Exit
   Endif
Next

Eval(bReadVar,cReadVOld)

Return lRet

//===========================================================================
FUNCTION BuscaTaxa(PInd, PData, lFiscal,lMostraMsg,lANTERIOR,cImpExp,cTipo)
*----------------------------------------------------------------------------
// O parametro cImpExp, for igual a  "E" indica que sera
// aberto o arq. da exportacao. Este parametro só sera utilizado no modulo de Drawback.
// alterado por Heder M Oliveira 10/04/00 11:52h
//O parâmetro cTipo indica se será utilizada a taxa de venda("1") ou a taxa de compra("2")

// GCC - 24/09/2013 - Ajustes em todas as comparações de = para ==

Local aOrd      	:= SaveOrd("SYE")
Local cAliasTaxa	:= "SYE"
Local cFilialAtu	:= xFilial("SYE")
Local cMoeDolar		:= BuscaDolar()	//ASR 24/01/2006 - cMoeDolar := EasyGParam("MV_SIMB2",,"US$")
Local lAbreExp		:= .T.
Local nReturn 		:= 1 			// SVG - 03/08/2010 -
Local PFiscal     := lFiscal
Default lANTERIOR 	:= .T.

//WFS 12/12/08
If AllTrim(PInd) <> AllTrim(EasyGParam("MV_SIMB1"))

   IF(lMostraMsg == NIL,lMostraMsg:=.T.,)
   IF(cImpExp == NIL,cImpExp:="I",)

   If cTipo == NIL .Or. Empty(cTipo)
      If nModulo == 17
         If Empty(cTipo:=EasyGParam("MV_IMP_TX",,""))
            cTipo:="1"
         EndIf
      ElseIf nModulo == 29
         If Empty(cTipo:=EasyGParam("MV_EXP_TX",,""))
            cTipo:="1"
         EndIf
      ElseIf nModulo == 50
         If Empty(cTipo:=EasyGParam("MV_DRAW_TX",,""))
            cTipo:="1"
         EndIf
      EndIf
   EndIf

   // Verifica se o Modulo e o SigaEDC
   If cImpExp == "E" .AND. nModulo == 50
      If Select("SYEEXP") == 0
         lAbreExp := AbreArqExp("SYE",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))),cFilialAtu,"SYEEXP") // Abre arq. produtos de outra Empresa/Filial de acordo com os parametros.
      Endif
      If lAbreExp
         cFilialAtu := If(Empty(ALLTRIM(EasyGParam("MV_FILEXP",,Space(FWSizeFilial())))), Space(FWSizeFilial()), ALLTRIM(EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))))
         cAliasTaxa := "SYEEXP"
      Endif
   Endif

   (cAliasTaxa)->(DBSETORDER(2))
   IF PInd == cMoeDolar .AND. !(cAliasTaxa)->(DBSEEK(cFilialAtu+cMoeDolar))
      PInd := "USD"
   ENDIF
   If !(cAliasTaxa)->(DBSEEK(cFilialAtu+PInd+DTOS(PData),lANTERIOR))
      IF ( lANTERIOR )
         IF (cAliasTaxa)->(EOF())
            (cAliasTaxa)->(DBSKIP(-1))
         ENDIF

         If !(PFiscal == Nil) .And. PFiscal
            cTipo:= "1"
            PFiscal:= Nil
         EndIf

         Do While !(cAliasTaxa)->(BOF()) .and. (cAliasTaxa)->YE_FILIAL == cFilialAtu .and. Pind == (cAliasTaxa)->YE_MOEDA .and.;
         Empty(IF(PFiscal == NIL,If(cTipo="1",(cAliasTaxa)->YE_VLCON_C,(cAliasTaxa)->YE_TX_COMP),(cAliasTaxa)->YE_VLFISCA))
            (cAliasTaxa)->(DBSKIP(-1))
         EndDo

         IF (cAliasTaxa)->YE_DATA > PData .OR. Pind <> (cAliasTaxa)->YE_MOEDA
            (cAliasTaxa)->(DBSKIP(-1))
            IF Pind <> (cAliasTaxa)->YE_MOEDA
               (cAliasTaxa)->(DBSEEK(cFilialAtu+Pind))
            ENDIF
         ENDIF
      ENDIF
   EndIf
   IF lMostraMsg
      If PFiscal == NIL
         IF EMPTY(IF(cTipo == "1",(cAliasTaxa)->YE_VLCON_C,(cAliasTaxa)->YE_TX_COMP))
            Help("",1,If(cTipo="1","AVG0005282","AVG0005283"),," "+PIND + " Em " + DTOC(PDATA)/* FSM - 03/04/11+" ("+ProcName(1)+")"*/,1,31) //Valor de conversão de compra/venda zerado -->
         ENDIF
      ElseIf Empty((cAliasTaxa)->YE_VLFISCA)
         Help("",1,"AVG0001031",," "+PIND + " Em " + DTOC(PDATA)/* FSM - 03/04/11 +" ("+ProcName(1)+")"*/,1,31) //Valor de conversão fiscal zerado -->
      EndIf
   ENDIF
Else // SVG - 03/08/2010 -
   Return nReturn
EndIf
RestOrd(aORD)
RETURN IF(PFiscal==NIL,If(cTipo == "1",(cAliasTaxa)->YE_VLCON_C,(cAliasTaxa)->YE_TX_COMP),(cAliasTaxa)->YE_VLFISCA)

/*
Funcao      : ColBrw(cField,cAlias)
Parametros  : cField := Nome do Campo
              cAlias := Nome do Alias
              cWork  := Nome da Work
Retorno     : Uma linha do array do MSSELECT
Objetivos   : Montar a MSSELECT, com as caracteristicas do SX3
Autor       : Cristiano A. Ferreira
Data/Hora   : 01/03/2000 11:12
Revisao     :
Obs.        :
*/
FUNCTION ColBrw(cField,cAlias, cWork)

Local aRet := {{|| STR0123},,STR0123} //"## erro ##"###"## erro ##"
Local cBlock

Begin Sequence
   IF Empty(cAlias)
      cAlias := Substr(cField,1,At("_",cField)-1)
      IF Len(cAlias) == 2
         cAlias := "S"+cAlias
      Endif
   Endif

   /* RMD - 29/01/20 - Caso o ambiente possua os controles de LGPD habilitados, se o campo trata-se de um conteúdo sensível ou pessoal e o usuário não possuir a acesso
                       aos campos com este perfil, inclui o nome do campo diretamente no array (sem codeblock) para que o tratamento padrão do framework para ofuscação de dados
                       possa identificar o campo e aplicar a ofuscação padrão.
                       Caso o usuário possua acesso aos campos com dados pessoais ou sensíveis foi mantido o modelo anterior (com codeblock) para preservar o legado.
   */
   If FindFunction("FWPDCANUSE") .And. FwPDCanUse(.T.) .And. Len(FwProtectedDataUtil():UsrNoAccessFieldsInList({cField}, .T., .T.)) > 0
      cBlock := '"' + cField + '"'
   Else
      If cWork <> Nil
         cBlock := "{|| "+AVSX3(cField,14,cWork)+"} "
      Else
         cBlock := "{|| "+AVSX3(cField,14,cAlias)+"} "
      EndIf
   EndIf
   aRet := '{'+cBlock+',"","'+AVSX3(cField,5)+'" }'

End Sequence

Return &(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ABREEFF  ³ Autor ³ Gilson Nascimento     ³ Data ³ 09/11/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de Abertura do Modulo de FINANCIAMENTO              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEFF                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ABREEFF()

IF cModulo == "EFF"
   Public nSUMACES:= 53 // nSUMACES //informar onde comeca os acessos deste sistema
// *** GFP 22/12/2010 - 17:31 - Nopado declaração de variavel publica
// Public nSUMACES:= 53 // nSUMACES //informar onde comeca os acessos deste sistema
// *** Fim GFP

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica se Usuario definiu usar o Controle de Alcadas.  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// If EasyGParam("MV_ALCADA") $ cSim
//    if !File(cArqAlca)
//       Final(STR0124) //"SIGAMAT.ALC inexiste"
//    EndIf
// EndIf

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Inicializa variaveis padroes do sistema                              ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   MV_RELT   := __RELDIR

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Inicializa funcao IsYear4(), que indica se o usuario usa 4 digitos   ³
   //³ no ano.                                                              ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   InitYear4()

   E_ARQCRW(.T.)
Endif

Return Nil

/*
Funcao      : AVDelay
Parametros  : nSec := Segundos
Retorno     : NIL
Objetivos   : Aguardar n segundos
Autor       : Cristiano A. Ferreira
Data/Hora   : 12/08/99 17:14
Revisao     :
Obs.        :
*/
FUNCTION AVDelay(nSec)

Sleep(nSec*1000)

Return Nil

/*
    Funcao   : MEMFIELD(cCPO,cALIAS)
    Autor    : Cristiano A Ferreira
    Data     : 26/10/99
    Revisao  : 26/10/99
    Uso      : Retornar valor atual de variavel de memoria ou campo
    Recebe   : cCPO := Campo (sem o alias)
               cALIAS:=Alias do campo
    Retorna  :

*/
FUNCTION MEMFIELD(cCPO,cALIAS)
   LOCAL xRET:=NIL,nOLDAREA:=SELECT()

   BEGIN SEQUENCE
      xRET:=MemVarBlock(cAlias+"_"+cCpo)
      IF Type("M->"+cAlias+"_"+cCpo) == "U"
         IF ((cALIAS)->(FIELDPOS(cAlias+"_"+cCpo))>0)
            xRET:=fieldwblock(cAlias+"_"+cCpo,select(cAlias))
         ELSE
            Help("",1,"AVG0001030",,cAlias+"_"+cCpo+" não existe no arquivo !",1,1)
            xRET:=NIL
            BREAK
         Endif
      ENDIF
      xRET:=EVAL(xRET)
   End Sequence

   DBSELECTAREA(nOLDAREA)
RETURN xRET

/*
    Funcao   : ArqField(cCpo,cAlias)
    Autor    : Cristiano A Ferreira
    Data     : 15/12/1999
    Uso      : Retornar valor atual arquivo
    Recebe   : cCPO := Campo (sem o alias)
               cALIAS:=Alias do campo
    Retorna  :

*/
FUNCTION ArqField(cCpo,cAlias)
   LOCAL xRET:=NIL
   BEGIN SEQUENCE
      IF ((cALIAS)->(FIELDPOS(cAlias+"_"+cCpo))>0)
         xRET:=fieldwblock(cAlias+"_"+cCpo,select(cAlias))
      ELSE
         Help("",1,"AVG0001030",,cAlias+"_"+cCpo+" não existe no arquivo !",1,1)
         BREAK
      ENDIF
      xRET:=EVAL(xRET)
   END SEQUENCE
RETURN xRET

/*
Funcao      : BCOAGE(cBCO,cAGE)
Parametros  : cBCO:= Campo que se refere ao banco
              cAGE:= Campo que se refere a agencia
Retorno     : Agencia encontrada e deixa posicionado no registro em questão
Objetivos   : Retornar a Agencia correta do banco escolhido pelo usuário
Autor       : Cristiane C. Figueiredo
Data/Hora   : 26/06/2000 11:37
Revisao     :
Obs.        :
*/
FUNCTION BCOAGE(cBCO)
   LOCAL cRETAGE, aORD, cBCOB
   aORD := SAVEORD("SA6")

   BEGIN SEQUENCE
      cBCOB := SA6->A6_COD
      If cBCOB == cBCO
         cRETAGE := SA6->A6_AGENCIA
      ELSE
        SA6->(DBSETORDER(1))
        IF SA6->(dbSEEK(XFILIAL("SA6")+AVKEY(cBCO,"A6_COD")))
          cRETAGE := SA6->A6_AGENCIA
        ELSE
          cRETAGE := SPACE(AVSX3("A6_AGENCIA",3))
        ENDIF
     ENDIF
   END SEQUENCE
   RestOrd(aOrd)
RETURN cRETAGE

/*
Funcao      : AVCTOD(cData,cTipo)
Parametros  : cData:= Data (caracter) que ser  convertida
              cTipo:= Em que tipo ser  convertida (MMDDYY)
Retorno     : Data
Objetivos   : Devido a fun‡Æo AVCTOD ter sido alterada no protheus.
Autor       : Victor Iotti
Data/Hora   : 06/09/2000 22:45
Revisao     :
Obs.        :
*/
FUNCTION AVCTOD(cData,cTipo)
   IF cTipo==NIL
      If Len(cData) = 10
         cTipo:="ddmmyyyy"
      Else
         cTipo:="ddmmyy"
      EndIf
   EndIf

RETURN CTOD(cData,cTipo)

*-------------------------------------------------------------------------*
Function AbreArqExp(cAlias,cEmpExp,cFilExp,cFilAtu,cAliasOutr)
*-------------------------------------------------------------------------*
Local cArquivo
Local lRet   := .F.
Local cCodEmp
Local cArqSx2,  cIndSx2
Local cLocal := ALLTRIM(EasyGParam("MV_PATH_PE",,""))
Private cDriver

IF(Right(cLocal,1) # "\", cLocal += "\",)

#IFDEF TOP
	cDriver := "TOPCONN"
#ELSE
	cDriver := "DBFCDX"
#ENDIF

If (Empty(cEmpExp) .And. Empty(cFilExp)) .or. Alltrim(cEmpExp)="." .or.;
Alltrim(cFilExp)="."
   Return .F.
Endif

cEmpExp:=Strzero(Val(cEmpExp),2)

If SX2->(DbSeek(cAlias))
   // Verifica a empresa atual
   cCodEmp := Alltrim(SUBSTR(RetSQLName(cAlias),4,2))
   If Empty(cEmpExp) .Or. cEmpExp == cCodEmp
      If xFilial(cAlias) # cFilExp
         lRet       := .F.
      Endif
   Elseif !Empty(cEmpExp) .And. cEmpExp # cCodEmp
      // Verifica o Codigo da empresa do arquivo encontrado no parametro
      cArqSx2   := "SX2"  + cEmpExp + "0"
      cIndSx2   := cArqSx2

      // Abre o SX2 da empresa correspondente do arquivo.
      SX2->(DbCloseArea())
      OpenSxs(,,,,,cLocal+(cArqSx2),"SX2",,.F.)
      If RetIndExt()!=".CDX"
         SX2->(dbSetIndex( cIndSx2 ))
      Else
         SX2->(DbSetOrder(1))
      EndIf
      SX2->(DbSeek(cAlias))

      // Verifica a existencia da tabela dentro do banco de dados
   	  cArquivo := RetArq(cDriver, AllTrim(RetSQLName(cAlias)),.T.)  // Nome do arquivo dependendo da Rdd
      If !MsFile(cArquivo,,cDriver)     // Se Arquivo nao existir o arquivo
         MsgStop(cArquivo + STR0152,STR0150 )//#STR0152 ->" não encontrado!" ## STR0150->"Atencao"
         lRet := .F.
      Else
         // Fecha o Arquivo Atual de Importacao
         If cAliasOutr = NIL                          // Fecha o Arquivo de Importacao e abre o arquivo de exportacao
            (cAlias)->(DbCloseArea())

            If ChkFile(cAlias)
               DbSelectArea(cAlias)
               (cAlias)->(DbSetOrder(1))
               lRet := .T.
            Else
               MsgStop(cArquivo + STR0153, STR0150) //#STR0153->" não foi aberto!" ## STR0150->"Atencao"
               // Abre o Arquivo anterior
               ChkFile(cAlias)
          	   lRet := .F.
          	Endif
         Else								   // Abre o Arquivo de Exportacao mas mantem o arquivo de importacao tambem aberto
            If ChkFile(cAlias,.F.,cAliasOutr)
               DbSelectArea(cAliasOutr)
               (cAliasOutr)->(DbSetOrder(1))
      	       lRet := .T.
            Else
               MsgStop(cArquivo + STR0153, STR0150) //#STR0153->" não foi aberto!" ## STR0150->"Atencao"
          	   lRet := .F.
          	Endif
    	 EndIf
      Endif

      // Abre o SX2 anterior
      cArqSx2 := "SX2" + cCodEmp + "0"
      cIndSx2 = cArqSx2

      SX2->(DbCloseArea())
      OpenSxs(,,,,,(cArqSx2),"SX2",,.F.)
      If RetIndExt()!=".CDX"
         SX2->(dbSetIndex(cIndSx2))
      Else
         SX2->(DbSetOrder(1))
      EndIf
   Endif
Endif

DbSelectArea(cAlias)

Return lRet
*----------------------------------------------*
Function FechaArqExp(cArquivo,lAbreImp)
*----------------------------------------------*

// Fecha o Arquivo Atual
(cArquivo)->(DbCloseArea())
// Abre o Arquivo da nova filial
If lAbreImp
   ChkFile(cArquivo)
   (cArquivo)->(DbSetOrder(1))
Endif

Return

//Alex Wallauer (AWR) 01/03/2002
//cAlias  : Arquivo cadastrado na Tabela (SX5) 'CF' e no rdmake FTMSREL_AP6.PRW ou na Funcao MsRelation();
//cChave  : Um codigo valido na tabela do Alias passado no 1o parametro;
//cContato: Contato cadastrado para a Chave passada no 2o parametro;
//cCampo  : Campo do Arquivo SU5 para retorno passada no 2o parametro;
*----------------------------------------------------------------------------*
FUNCTION BuscaContato(cAlias,cChave,cContato,cCampo)
*----------------------------------------------------------------------------*
Local C
IF EMPTY(cAlias)
   cAlias  :=SPACE(3)
   cChave  :=""
   cContato:=''
   lSair   :=.T.
   cFiltro :=xFilial('SX5')+"CF"
   bOk     :={|| cAlias:=ALLTRIM(SX5->X5_CHAVE), oDlg:End(), lSair:=.F. }
   aTB_Campos:={ {"X5_CHAVE",,"Tabela"},{"X5_DESCRI",,"Cadastro"}}

   oMainWnd:ReadClientCoords()
   DEFINE MSDIALOG oDlg TITLE STR0154; //#STR0154 -> "Escolha o Cadastrado"
          FROM 0,0 TO 270,360 OF oMainWnd PIXEL

       oMark:=MSSELECT():New("SX5",,,aTB_Campos,.F.,'X',{15,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2},"FiltContato(cFiltro)","FiltContato(cFiltro)")
       oMark:bAval:=bOk

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,{|| oDlg:End(),lSair:=.T.}) CENTERED

   IF lSair
      RETURN ''
   ENDIF

ENDIF

IF EMPTY(cChave)
   cChave   := SPACE(20)
   cContato := ''
   cCpoChave:= ''
   aEntidade:= MsRelation()
   nPos     := ASCAN(aEntidade,{ |A| A[1] == cAlias} )
   lSair := .T.
   nReg  := 0
   bOk   := {|| nReg:=(cAlias)->(RECNO()), oDlg:End(), lSair:=.F. }
   aTB_Campos:={}
   IF nPos # 0
      aCpoPos   := {}
      aCpoChave := aEntidade[nPos,2]
      bCpoNome  := aEntidade[nPos,3]
      FOR C := 1 TO LEN(aCpoChave)
          nPos  := (cAlias)->(FIELDPOS( aCpoChave[C] ))
          AADD(aCpoPos,nPos)
          AADD(aTB_Campos,{ aCpoChave[C],,AVSX3(aCpoChave[C],5) })
      NEXT
      AADD(aTB_Campos,{bCpoNome ,,"Nome"})
   ELSE
      Aviso(STR0150 ,STR0155 + cAlias, { "Ok" } ) //#STR0150 ->  "Atencao !" ##STR0155 -> "Nao existe chave de relacionamento definida para o alias "
      RETURN ''
   ENDIF

   SX5->(DBSETORDER(1))
   SX5->(DBSEEK(xFilial()+'CF'+cAlias))
   cDescr:=ALLTRIM(SX5->X5_DESCRI)

   DBSELECTAREA(cAlias)
   oMainWnd:ReadClientCoords()
   DEFINE MSDIALOG oDlg TITLE cDescr;
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
          TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL

     oMark:=MSSELECT():New(cAlias,,,aTB_Campos,.F.,'X',{15,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
     oMark:bAval:=bOk

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,{|| oDlg:End(),lSair:=.T.})

   IF lSair
      RETURN ''
   ENDIF
   cChave:=''
   (cAlias)->(DBGOTO(nReg))
   FOR C := 1 TO LEN(aCpoPos)
       cChave+=(cAlias)->(FIELDGET(aCpoPos[C]))
   NEXT
   cChave:=RTRIM(cChave)

ENDIF

IF EMPTY(cContato)
   aCampos:={"U5_CODCONT","U5_CONTAT"}
   cFileWk:=E_CriaTrab()

   IF !USED()
      Help(" ",1,"E_NAOHAREA")
      RETURN ''
   ENDIF

   aTB_Campos:={}
   AADD(aTB_Campos,{"U5_CODCONT",,"Codigo"})
   AADD(aTB_Campos,{"U5_CONTAT" ,,"Nome"})

   cContato:=SPACE(LEN(SU5->U5_CODCONT))
   lSair  :=.T.
   bOk    :={|| cContato:=TRB->U5_CODCONT, oDlg:End(), lSair:=.F. }
   cFilAC8:=xFilial()
   cFilSU5:=xFilial("SU5")
   cFil   :=xFilial(cAlias)
   bWhile :={|| cFilAC8+cAlias+cFil+cChave = AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+RTRIM(AC8_CODENT) }
   bGrava :={|| TRB->(DBAPPEND()),;
                SU5->(DBSEEK(cFilSU5+AC8->AC8_CODCON)),;
                TRB->U5_CODCONT:=SU5->U5_CODCONT,;
                TRB->U5_CONTAT:=SU5->U5_CONTAT}

   SU5->(DBSETORDER(1))
   AC8->(DBSETORDER(2))
   AC8->(DBSEEK(cFilAC8+cAlias+cFil+cChave))
   AC8->(DBEVAL(bGrava,,bWhile))
   AC8->(DBSETORDER(1))

   oMainWnd:ReadClientCoords()//So precisa declarar uma fez para o Programa todo
   DEFINE MSDIALOG oDlg TITLE STR0156 ; //#STR0156->"Escolha o Contato" ;
          FROM 0,0 TO 270,360 OF oMainWnd PIXEL

       TRB->(DBGOTOP())
       oMark:=MSSELECT():New("TRB",,,aTB_Campos,.F.,'X',{15,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
       oMark:bAval:=bOk

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,{|| oDlg:End(),lSair:=.T.}) CENTERED

   TRB->(E_EraseArq(cFileWk))

   IF lSair
      RETURN ''
   ENDIF
ENDIF

SU5->(DBSETORDER(1))
SU5->(DBSEEK(xFilial()+cContato))
IF EMPTY(cCampo)
   RETURN SU5->U5_CODCONT
ELSE
   IF (nPos:=SU5->(FIELDPOS(cCampo))) # 0
      RETURN SU5->(FIELDGET(nPos))
   ENDIF
ENDIF

RETURN ''
*---------------------------*
FUNCTION FiltContato(cChave)
*---------------------------*
RETURN cChave

/*
Funcao          : AVTransUnid()
Parametros      : cUnid1    = Unidade DE
                  cUnid2    = Unidade PARA
                  cProd     = Produto
                  nQtd      = Quantidade na Unidade DE
                  lRetFalse = Define o retorno caso não encontre uma conversão para as unidades.
                              (.T.) para retorno NIL e (.F.) para retornar a mesma quantidade da
                              U.M. DE.
                  aNotSearch = unidades que não devem ser buscadas na recursividade, para evitar referência circular. (JPM - 18/01/06)
                  lPreco     = Se é conversão de unidade de medida de preço.
                  cForn      = Codigo do Fornecedor - AWF - 19/05/2014
                  cLoja      = Codigo da Loja - AWF - 19/05/2014
Retorno         : Quantidade na Unidade PARA
Objetivos       : Retornar Quantidade na Unidade de Medida PARA
Autor           : AVERAGE
*/
*---------------------------------------------------------------------------------------------*
Function AVTransUnid(cUnid1,cUnid2,cProd,nQtd,lRetFalse,lPreco,aNotSearch,cForn,cLoja)
*---------------------------------------------------------------------------------------------*
Local cOldArea:=Select(), nVal, lAchou:=.F.
Local cKey := "", cKeyInv := ""
Local aSearch := {}, cUn, j, i, nRet, aParam
Local c50, c60, cLb, cTon, aConvTable := {}, nPos
Local nDe, nPara
//Local aOrd := SaveOrd({"SB1"}) //RRC - Guarda a ordem da tabela correspondente
lRetFalse := If(lRetFalse<>NIL,lRetFalse,.F.)
cProd     := If(cProd<>NIL,cProd,"")

Default lPreco     := .F.
Default aNotSearch := {}
Default cUnid1     := ""
Default cUnid2     := ""
Default cForn      := ""
Default cLoja      := ""

//RRC - 19/06/2012 - Verifica o peso do produto antes de realizar qualquer conversão
/*DbSelectArea("SB1")
SB1->(DbSetOrder(1))
If SB1->(DbSeek(xFilial("SB1")+cProd)) .And. SB1->B1_PESO <> 0 .And. cUnid2 == "KG" .And. SB1->B1_UM == cUnid1
   nVal := SB1->B1_PESO * nQtd
   RestOrd(aOrd,.T.)
   DbSelectArea(cOldArea)
   Return nVal
EndIf
RestOrd(aOrd,.T.)
DbSelectArea(cOldArea)*/

//WFS
cUnid1:= AVKey(cUnid1, "J5_DE")
cUnid2:= AVKey(cUnid2, "J5_PARA")

//RMD - Não tenta converter quando alguma das unidades estiver em branco
//If !Empty(cUnid1) .And. !Empty(cUnid2) .And. Alltrim(cUnid1) <> Alltrim(cUnid2)
If !Empty(cUnid1) .And. !Empty(cUnid2) .And. Alltrim(cUnid1) <> Alltrim(cUnid2)

   // ** JPM - 14/03/06 - Tratamentos específicos para conversões de unidades de medida de preço
   If lPreco
      nDe   := 1
      nPara := 2
   Else
      nDe   := 2
      nPara := 1
   EndIf

   If cModulo == "EEC" .And. FindFunction("Ap104ConvTable")//RMD - 21/11/06
      aConvTable := Ap104ConvTable()[1]
      If (nPos := AScan(aConvTable,{|x| x[nDe]+x[nPara] == cUnid1+cUnid2 })) > 0
         Return Round(ApPriceConv(nPos,nQtd),AvSx3("EE8_PRECO",4))
      EndIf
   EndIf

   If lPreco
      cUn    := cUnid1
      cUnid1 := cUnid2
      cUnid2 := cUn
   EndIf
   // **

   dbSelectArea("SJ5")
   SJ5->(dbSetOrder(1))
   If !Empty(cProd)
      cKey    := xFilial("SJ5")+ cUnid1 + cUnid2 // MPG - ALTERAÇÃO UNIDADES DE MEDIDAS AVKey(cUnid1,"J5_DE")+AVKey(cUnid2,"J5_PARA")
      cKeyInv := xFilial("SJ5")+ cUnid2 + cUnid1 // MPG - ALTERAÇÃO UNIDADES DE MEDIDAS AVKey(cUnid2,"J5_DE")+AVKey(cUnid1,"J5_PARA")
      IF SJ5->(FieldPos("J5_COD_I")) > 0
         cKey    += AVKey(cProd,"J5_COD_I")
         cKeyInv += AVKey(cProd,"J5_COD_I")
      Endif

      IF SJ5->(FieldPos("J5_FORN")) > 0 .AND. SJ5->(FieldPos("J5_FORLOJ")) > 0
         cKey    += AVKey(cForn,"J5_FORN")+AVKey(cLoja,"J5_FORLOJ")
         cKeyInv += AVKey(cForn,"J5_FORN")+AVKey(cLoja,"J5_FORLOJ")
      Endif

      If SJ5->(dbSeek(cKey))//Tenta achar com o fornecedor
         lAchou := .T.
         nVal   := nQtd * SJ5->J5_COEF
      ElseIf SJ5->(dbSeek(cKeyInv))
         lAchou := .T.
         nVal   := nQtd / SJ5->J5_COEF
      EndIf

      If !lAchou
         cKey    := xFilial("SJ5")+cUnid1+cUnid2
         cKeyInv := xFilial("SJ5")+cUnid2+cUnid1
         IF SJ5->(FieldPos("J5_COD_I")) > 0
            cKey    += AVKey(cProd,"J5_COD_I")
            cKeyInv += AVKey(cProd,"J5_COD_I")
         Endif

         If SJ5->(dbSeek(cKey))//Tenta achar sem o fornecedor
            lAchou := .T.
            nVal   := nQtd * SJ5->J5_COEF
         ElseIf SJ5->(dbSeek(cKeyInv))
            lAchou := .T.
           nVal   := nQtd / SJ5->J5_COEF
         EndIf

      ENDIF
   EndIf
   If !lAchou
   //If SJ5->(dbSeek(xFilial("SJ5")+AVKey(cUnid1,"J5_DE")+AVKey(cUnid2,"J5_PARA")))  // TLM 02/06/2008 - Compatibilização
     If SJ5->(dbSeek(xFilial("SJ5")+cUnid1+cUnid2)) .and. (SJ5->(FieldPos("J5_COD_I")) <= 0 .or. Empty(SJ5->J5_COD_I))
         If SJ5->(FieldPos("J5_COD_I")) <= 0 .or. Empty(SJ5->J5_COD_I)
            lAchou := .T.
            nVal   := nQtd * SJ5->J5_COEF
         EndIf
     //ElseIf SJ5->(dbSeek(xFilial("SJ5")+AVKey(cUnid2,"J5_DE")+AVKey(cUnid1,"J5_PARA"))) // TLM 02/06/2008 - Compatibilização
     ElseIf SJ5->(dbSeek(xFilial("SJ5")+cUnid2+cUnid1)) .and. (SJ5->(FieldPos("J5_COD_I")) <= 0 .or. Empty(SJ5->J5_COD_I))
         If SJ5->(FieldPos("J5_COD_I")) <= 0 .or. Empty(SJ5->J5_COD_I)
            lAchou := .T.
            nVal   := nQtd / SJ5->J5_COEF
         EndIf
      EndIf
   EndIf

   // ** JPM - 18/01/06 - busca recursivamente as conversões
   //If !lAchou
   If !lRetFalse .And. Empty(cProd) //TRP-13/12/07
      If lPreco // Volta as unidades que foram trocadas.
         cUn    := cUnid1
         cUnid1 := cUnid2
         cUnid2 := cUn
      EndIf
      For j := 1 To 2
         aSearch := {}
         If j == 1
            SJ5->(dbSeek(xFilial("SJ5")+cUnid1))
            While SJ5->(!EoF()) .And. SJ5->(J5_FILIAL+J5_DE) == xFilial("SJ5")+cUnid1
               If AScan(aNotSearch,SJ5->J5_PARA) = 0
                  AAdd(aSearch,SJ5->J5_PARA)
               EndIf
               SJ5->(DbSkip())
            EndDo

            For i := 1 To Len(aConvTable)
               If aConvTable[i][nDe] = cUnid1
                  If AScan(aNotSearch,aConvTable[i][nPara]) = 0 .And. AScan(aSearch,aConvTable[i][nPara]) = 0
                     AAdd(aSearch,aConvTable[i][nPara])
                  EndIf
               EndIf
            Next
         Else
            SJ5->(dbSeek(xFilial("SJ5")))
            While SJ5->(!EoF())
               If SJ5->J5_PARA == cUnid1
                  If AScan(aNotSearch,SJ5->J5_DE) = 0
                     AAdd(aSearch,SJ5->J5_DE)
                  EndIf
               EndIf
               SJ5->(DbSkip())
            EndDo

            For i := 1 To Len(aConvTable)
               If aConvTable[i][nPara] = cUnid1
                  If AScan(aNotSearch,aConvTable[i][nDe]) = 0 .And. AScan(aSearch,aConvTable[i][nDe]) = 0
                     AAdd(aSearch,aConvTable[i][nDe])
                  EndIf
               EndIf
            Next
         EndIf

         aParam := AClone(aNotSearch)
         Eval({|x, y| aSize(x, Len(x)+Len(y)),;
                      aCopy(y, x,,, Len(x)-Len(y)+1 )}, aParam, aSearch)

         nRet := Nil
         For i := 1 To Len(aSearch)
            If ValType((nRet := AvTransUnid(cUnid1,aSearch[i],cProd,nQtd,.T.,lPreco,AClone(aParam)))) = "N"
               If ValType((nRet := AvTransUnid(aSearch[i],cUnid2,cProd,nRet,.T.,lPreco,AClone(aParam)))) = "N"
                  lAchou := .T.
                  Exit
               EndIf
            EndIf
         Next

         If ValType(nRet) = "N"
            nVal := nRet
            Exit
         EndIf
      Next
   EndIf

   //OAP - 18/01/2011 - Adequação para o caso de lRetFalse ser .T.
   If lRetFalse .And. Empty(cProd)
      If !lAchou
         SJ5->(DbSetOrder(1))
         SJ5->(DbGoTop())
            If SJ5->(DBSEEK(xFilial("SJ5")+cUnid1+cUnid2))
                nVal   := nQtd*SJ5->J5_COEF
                lAchou := .T.
            EndIf
      EndIf
   EndIf
   // ** JPM - fim

   If !lAchou
      If(lRetFalse, nVal:=NIL, nVal := nQtd)
   EndIf

   dbSelectArea(cOldArea)
Else
   nVal := nQtd
EndIf

Return nVal
*----------------------------------------------------*
FUNCTION Busca_UM(PChave,PChave1,cLojaFAB, cLojaFOR) //OS.:0022/02 SO.:0140/02 FCD
*----------------------------------------------------*
Local cUniPO := ""
Local nTamPRD:= AVSX3("B1_COD",3)
Local nOrdSA5:= SA5->(INDEXORD())
Local nOrdSB1:= SB1->(INDEXORD())
Local nOrdSW0,nOrdSC1
Local hashChave:= ""
Private lRet := .T.     // GFP - 08/11/2012
Default PChave:= ""
Default PChave1:= ""
Default cLojaFAB:= ""
Default cLojaFOR:= ""

//wfs - out/2019: ajustes de performance
hashChave:= cFilAnt + PChave + PChave1 + cLojaFAB + cLojaFOR

If !IsMemVar("oBufferUM") .Or. oBufferUM == Nil
   oBufferUM:= tHashMap():New()
EndIf

If !oBufferUM:Get(hashChave, @cUniPO)

   If AvFlags("EIC_EAI")//AWF - 25/06/2014 - Para o Logix
      nOrdSW1:= SW1->(INDEXORD())
      SW1->(DBSETORDER(1))
      If !EMPTY(PChave1) .AND. SW1->(DBSeek(xFilial("SW1")+PChave1))
         cUniPO:= SW1->W1_UM
         lRet  := .F.
      EndIf
      SW0->(DBSETORDER(nOrdSW1))
      lRet:= .F.
   ENDIF

   If EasyEntryPoint("AVGERAL")     // GFP - 08/11/2012 - Ponto de entrada para customizar busca de unidades de medidas.
      ExecBlock("AVGERAL",.F.,.F.,{"BUSCA_UNID_MED"})
   Endif

   If lRet   // GFP - 08/11/2012
      SA5->(DBSETORDER(3))
      EICSFabFor(xFilial("SA5")+PChave, cLojaFAB, cLojaFOR)
      SB1->(DBSETORDER(1))
      SB1->(DBSEEK(xFilial("SB1")+Substr(PChave,1,nTamPRD)))
      cUniPO:= IF(! EMPTY(SA5->A5_UNID),SA5->A5_UNID,If(EasyGParam("MV_UNIDCOM") == 1,SB1->B1_UM,SB1->B1_SEGUM))  // GFP - 05/06/2013 - Sistema deve considerar conteudo do parametro "MV_UNIDCOM" para informar unidade.
      If EasyGParam("MV_EASY")=="S".and. !EMPTY(pChave1)
         nOrdSW0:= SW0->(INDEXORD())
         SW0->(DBSETORDER(1))
         If SW0->(DBSeek(xFilial("SW0")+Pchave1))
            nOrdSC1:= SC1->(INDEXORD())
            SC1->(DBSETORDER(2))
            If SC1->(DBSEEK(xFilial('SC1')+SUBSTR(PChave,1,nTamPRD)+SW0->W0_C1_NUM))
               If GETNEWPAR("MV_UNIDCOM",2)==2
               cUniPO := SC1->C1_SEGUM
               // RA - 04/11/03 - O.S. 1116/03 - Inicio
               If Empty(SC1->C1_SEGUM) .And. ( SC1->C1_QTSEGUM == 0 .Or. SC1->C1_QUANT == SC1->C1_QTSEGUM )
                  cUniPO := SC1->C1_UM
               EndIf
               // RA - 04/11/03 - O.S. 1116/03 - Final
               Else
               cUniPO := SC1->C1_UM
               Endif
            Endif
            SC1->(DBSETORDER(nOrdSC1))
         Endif
         SW0->(DBSETORDER(nOrdSW0))
      Endif
   EndIf

   SB1->(DBSETORDER(nOrdSB1))
   SA5->(DBSETORDER(nOrdSA5))

   oBufferUM:Set(hashChave, cUniPO)

EndIf

Return cUniPO

*----------------------------------------------------*
FUNCTION Busca_2UM(cPo_Num,cPosicao) //AWF - 25/06/2014 - Para o Logix
*----------------------------------------------------*
Local aOrd:= AClone(SaveOrd("SW3"))
Local aSegUN := {}

SW3->(DBSETORDER(8))
If SW3->(DBSeek(xFilial("SW3")+AVKEY(cPo_Num,"W3_PO_NUM")+AVKEY(cPosicao,"W3_PO_NUM")))
   aSegUN := {SW3->W3_UM,SW3->W3_SEGUM,SW3->W3_QTSEGUM/SW3->W3_QTDE}
ENDIF

RestOrd(aOrd, .T.)

Return aSegUN

*-----------------------------------------------------------------------------------------*
//Funcao....: ENVIA_EMAIL()
//Parametros: cArquivo: Dir\Nome         (C)
//            cTitulo : Titulo da Tela   (C)
//            cSubject: Titulo do E-Mail (C)
//            cBody   : Corpo do E-Mail  (C)
//            lShedule: Se for Shedulado (L)
//            cTo     : E-Mail destino   (C)
//            cCc     : E-Mail Copia     (C)
//Data/Hora.: 15/10/2003 19:00
//Retorno...: .T./.F.
//Autor.....: ALEX WALLAUER (AWR)
FUNCTION ENVIA_EMAIL(cArquivo,cTitulo,cSubject,cBody,lShedule,cTo,cCC)
*-----------------------------------------------------------------------------------------*
LOCAL cServer, cAccount, cPassword, lAutentica, cUserAut, cPassAut
LOCAL cUser,lMens:=.T.,nOp:=0,oDlg

DEFAULT cArquivo := ""
DEFAULT cTitulo  := ""
DEFAULT cSubject := ""
DEFAULT cBody    := ""
DEFAULT lShedule := .F.
DEFAULT cTo      := ""
DEFAULT cCc      := ""

IF EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
   IF !lShedule
      MSGINFO(STR0157  + "'MV_RELSERV'") //#STR0157->"Nome do Servidor de Envio de E-mail não definido no "
   ELSE
      ConOut(STR0157 + "'MV_RELSERV'") //#STR0157->"Nome do Servidor de Envio de E-mail não definido no "
   ENDIF
   RETURN .F.
ENDIF

IF EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
   IF !lShedule
      MSGINFO( STR0158 + "'MV_RELACNT'") //#STR0158-> "Conta para acesso ao Servidor de E-mail nao definida no "
   ELSE
      ConOut(STR0158 + "'MV_RELACNT'") //#STR0158-> "Conta para acesso ao Servidor de E-mail no definida no "
   ENDIF
   RETURN .F.
ENDIF

IF lShedule .AND. EMPTY(cTo)
   IF !lShedule
      ConOut(STR0159) //#STR0159 ->"E-mail para envio, nao informado."
   ENDIF
   RETURN .F.
ENDIF

PswOrder(1)
PswSeek(__CUSERID,.T.)
aUsuario:= PswRet()
cFrom:= Alltrim(aUsuario[1,14])
cUser:= cUserName
cCC  := cCC + SPACE(200)
cTo  := cTo + SPACE(200)
cSubject:=cSubject+SPACE(100)

IF EMPTY(cFrom)
   IF !lShedule
       MsgInfo(STR0160+cUser) //#STR0160->"E-mail do remetente nao definido no cad. do usuario: "
   ELSE
       ConOut(STR0160+cUser) //#STR0160->"E-mail do remetente nao definido no cad. do usuario: "
   ENDIF
   RETURN .F.
ENDIF

DO WHILE !lShedule

   nOp  :=0
   nCol1:=8
   nCol2:=33
   nSize:=225
   nLinha:=15

   DEFINE MSDIALOG oDlg OF oMainWnd FROM 0,0 TO 350,544 PIXEL TITLE STR0161 //STR0161->"Envio de E-mail"

      oPnl:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 1, 1)
      oPnl:Align:= CONTROL_ALIGN_ALLCLIENT      

  		@ nLinha,nCol1 Say STR0162  Size 12,8              OF oPnl PIXEL //#STR0162->"Titulo:"
        @ nLinha,nCol2 MSGET cTitulo  SIZE nSize,10 WHEN .F. OF oPnl PIXEL
        nLinha+=15

  		@ nLinha,nCol1 Say STR0163 Size 20,8              OF oPnl PIXEL //STR0163->"Usuário:"
        @ nLinha,nCol2 MSGET cUser    SIZE nSize,10 WHEN .F. OF oPnl PIXEL
        nLinha+=20

  		@ 000005,nCol1-4 To nLinha   ,268 LABEL STR0164 OF oPnl PIXEL //#STR0164->" Informacoes "
        nLinha+=05
        nLinAux:=nLinha
        nLinha+=10

  		@ nLinha,nCol1 Say   STR0134      Size 012,08             OF oPnl PIXEL //#STR0134->"De:"
  		@ nLinha,nCol2 MSGET cFrom      Size nSize,10 WHEN .F.  OF oPnl PIXEL
        nLinha+=15

  		@ nLinha,nCol1 Say   STR0165    Size 016,08             OF oPnl PIXEL //#STR0165->"Para:"
  		@ nLinha,nCol2 MSGET cTo        Size nSize,10  F3 "_EM" OF oPnl PIXEL
        nLinha+=15

  		@ nLinha,nCol1 Say   "CC:"      Size 016,08             OF oPnl PIXEL
  		@ nLinha,nCol2 MSGET cCC        Size nSize,10  F3 "_EM" OF oPnl PIXEL
        nLinha+=15

  		@ nLinha,nCol1 Say   STR0166 Size 021,08             OF oPnl PIXEL //#STR0166->"Assunto:"
  		@ nLinha,nCol2 MSGET cSubject   Size nSize,10           OF oPnl PIXEL
        nLinha+=15

  		@ nLinha,nCol1 Say   STR0167   Size 016,08             OF oPnl PIXEL //#STR0167->"Corpo:"
  		@ nLinha,nCol2 Get   cBody      Size nSize,20  MEMO     OF oPnl PIXEL HSCROLL

  		@ nLinAux,nCol1-4 To nLinha+28,268 LABEL STR0168 OF oDlg PIXEL //#STR0168->" Dados de Envio "
        nLinha+=35

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, { || If(Empty(cTo),Help("",1,"AVG0001054"),(oDlg:End(),nOp:=1)) },;
                                                      { || oDlg:End()  },,,,,,,.F.) CENTERED

   IF nOp = 0
      RETURN .T.
   ENDIF

   EXIT

ENDDO

cAttachment:=cArquivo
cPassword := AllTrim(GetNewPar("MV_RELPSW"," "))
lAutentica:= EasyGParam("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut  := Alltrim(EasyGParam("MV_RELAUSR",," "))//Usuário para Autenticação no Servidor de Email
cPassAut  := Alltrim(EasyGParam("MV_RELAPSW",," "))//Senha para Autenticação no Servidor de Email
cTo := AvLeGrupoEMail(cTo)
cCC := AvLeGrupoEMail(cCC)

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
   IF !lShedule
       MsgInfo(STR0169) //#STR0169->"Falha na Conexão com Servidor de E-Mail"
   ELSE
       ConOut(STR0169) //#STR0169->"Falha na Conexão com Servidor de E-Mail"
   ENDIF
ELSE
   If lAutentica
      If !MailAuth(cUserAut,cPassAut)
         MSGINFO(STR0170) //#STR0170->"Falha na Autenticacao do Usuario"
         DISCONNECT SMTP SERVER RESULT lOk
      EndIf
   EndIf
   IF !EMPTY(cCC)
      SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cBody ATTACHMENT cAttachment RESULT lOK
   ELSE
      SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody ATTACHMENT cAttachment RESULT lOK
   ENDIF
   If !lOK
      IF !lShedule
         MsgInfo(STR0171+ALLTRIM(cTo)) //#STR0171->"Falha no Envio do E-Mail: "
      ELSE
         ConOut(STR0171+ALLTRIM(cTo)) //#STR0171->"Falha no Envio do E-Mail: "
      ENDIF
   ENDIF
ENDIF

DISCONNECT SMTP SERVER

IF lOk
   IF !lShedule
      MsgInfo(STR0172) //#STR0172->"E-mail enviado com sucesso."
   ELSE
      ConOut(STR0172) //#STR0172->"E-mail enviado com sucesso."
   ENDIF
ENDIF

RETURN .T.

/*
Funcao          : MSMM_DR() Função igual a msmm porém utilizada pelo drawback quando se utiliza de duas empresas diferentes.
Autor           : Victor
*/
*---------------------------------------------------------------------------*
Function MSMM_DR(cChave,nTam,nLin,cString,nOpc,nTabSize,lWrap,cAlias,cCpochave)
*---------------------------------------------------------------------------*
Local nx, nPos, lCrLf, nRead, nTotal, nTexto
Local cAliasOld := Alias()
Local uRet      := " "
Local lUsaSx8   := (cChave == NIL .Or. Val(cChave) == 0)
Local nCrlf     := 0
Local nSubs     := 0
Local cLine     := ""
Local nFator    := 0, cByte
Local lField    := .F.
Local lYP_CAMPO := .F.
Local nLen1
Local nLen2
Local nSeq
Local lGrv := .F.
Local nPos2

Private CFILSYP := XFILIAL("SYP"), cFilSYPAux:=cFilSYP, cAliasSYP:="SYP" //Para utilizar SYP de outra Empresa/Filial

If Select("SYPEXP") = 0
   lAbriuExp := AbreArqExp("SYP",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"")),cFilSYP,"SYPEXP") // Abre arq. produtos de outra Empresa/Filial de acordo com os parametros.
Else
   lAbriuExp := .T.
Endif

If lAbriuExp
   cAliasSYP  := "SYPEXP"
   cFilSYPAux := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))
   If(Empty(Alltrim(cFilSYPAux)),cFilSYPAux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
Endif


//verifica se o campo existe na tabela

nOpc    := If(nOpc == NIL,3,nOpc)

If nOpc <> 3
	If ( cCpoChave <> NIL )
		DbSelectArea(cAlias)
		cCpoChave := Trim(cCpoChave)
		For nx := 1 To FCount()
			If ( FieldName(nx) == cCpoChave )
				lField := .T.
				Exit
			EndIf
		Next

		If ( !lField )
			DbSelectArea(cAliasOld)
			Return uRet
		EndIf
	EndIf
EndIf

/*// Somente o Importacao usa a CHKFILE desta forma. - gilson 8/9/97
// sempre estava retornando branco qdo nao era o Importacao.
If Select("SYP") == 0   //EasyGParam("MV_EASY") == "S"
	If !ChkFile("SYP")
		MsgStop("SYP Open Failure")
		Return uRet
	EndIf
EndIf*/

DbSelectArea(cAliasSYP)
cChave  := If(cChave == NIL,StrZero(0,6),cChave)
cString := If(cString == NIL,"",cString)
nTam    := If(nTam == NIL,Len((cAliasSYP)->YP_TEXTO),nTam)
nLin    := If(nLin == NIL,0,nLin)
lCrLf   := If(nTam#Len((cAliasSYP)->YP_TEXTO),.T.,.F.)
lYP_CAMPO := Ascan(DbStruct(),{|x| x[1] == "YP_CAMPO"}) <> 0
DbSetOrder(1)
DbSeek(cFilSYPAux+cChave)

// Ler campo MEMO
If nOpc == 3
	While !Eof() .And. cChave == (cAliasSYP)->YP_CHAVE .And. cFilial == (cAliasSYP)->YP_FILIAL
		If nLin > 0
			If nLin # Val((cAliasSYP)->YP_SEQ)
				DbSkip()
				Loop
			EndIf
			nPos := At("\13\10",Subs((cAliasSYP)->YP_TEXTO,1,nTam+6))
			If ( nPos == 0 )
				cLine := RTrim(Subs((cAliasSYP)->YP_TEXTO,1,nTam))
				If ( nPos2 := At("\14\10", cLine) ) > 0
					cString += StrTran( cLine, "\14\10", Space(6) )
				Else
					cString += cLine
				EndIf
			Else
				cString += Subs((cAliasSYP)->YP_TEXTO,1,nPos-1)
			EndIf
			Exit
		EndIf
		nPos := At("\13\10",Subs((cAliasSYP)->YP_TEXTO,1,nTam+6))
		If ( nPos == 0 )
			cLine := RTrim(Subs((cAliasSYP)->YP_TEXTO,1,nTam))
			If ( nPos2 := At("\14\10", cLine) ) > 0
				cString += StrTran( cLine, "\14\10", Space(6) )
			Else
				cString += cLine
			EndIf
		Else
			cString += Subs((cAliasSYP)->YP_TEXTO,1,nPos-1) + CRLF
		EndIf
		DbSkip()
	End
	uRet := cString
ElseIf nOpc == 2
	// Excluir campo MEMO
    MSGSTOP(STR0002)
Else
	// Incluir/Alterar campo MEMO
    MSGSTOP(STR0002)
Endif
DbSelectArea(cAliasOld)
Return uRet

// Funcao     : EICDLL
// Objetivo   : Chama DLL para obter Campos de uma Tabela(MDB) e Inclui em uma Work.
// Sintaxe    : EICDLL( cFonteDados, cTabela, aArrayCampos, aMensagLog,;
//              cAliasWork, lProcessa, cCompSelect, lMensagTela, lFechaDll )
//
// Parametros : cFonteDados  = Fonte de Dados(ODBC) do Usuario
//              cTabela      = Nome da Tabela
//              aArrayCampos = Colunas da Tabela/Campos do cAliasWork/Veja Observacoes
//              aMensagLog   = Nome da Matriz para armazenar as mensagens de erro
//              cAliasWork   = Alias da Work (Arquivo DBF)
//              lProcessa    = Indica se havera uso da funcao Processa() (.T.)/(.F)
//              cCompSelect  = Complemento do Comando Select ou ""
//              lMensagTela  = Indica se as mensagens devem aparecer na tela (.T.)/(.F.)
//              lFechaDll    = Indica se a DLL sera Fechada (.T.) ou nao (.F.)
//
// Default    : DEFAULT cAliasWork  := "TRB"
//              DEFAULT lProcessa   := .F.
//              DEFAULT cCompSelect := ""
//              DEFAULT lMensagTela := .T.
//              DEFAULT lFechaDll   := .T.
//
// Retorno    : .T. se obteve sucesso, ou .F. se nao obteve sucesso.
//
// Observacoes: cAliasWork deve existir e estar aberto.
//
//              aMensagLog deve ser inicializada com {} no programa chamador.
//
//              No parametro aArrayCampos, a terceira dimensao do array, contera o
//              formato da Data para Campo Data OU um Codigo de Bloco para qualquer
//              Tipo de Campo da Work OU deve ser preenchida com "".
//
//              Formato da Data : "DDMMAA", "AAMMDD", "AAAAMMDD", "DDMMAAAA",
//              "DD/MM/AA", "AA/MM/DD", "AAAA/MM/DD", "DD/MM/AAAA".
//
//              O Codigo de Bloco deve retornar o conteudo a ser gravado no Campo.
//              O conteudo que vai ser retornado pelo Codigo de Bloco deve ser
//              compativel com o tipo de campo. Nao existe validacao pela funcao
//              desse conteudo.
//
//              Tipos de Campos que podem ser utilizado por esta funcao =
//              C (Caracter), N (Numerico), D (Data), M (Memo), L (Logico).
//
//              Para os Campos Numericos sao aceitas as seguintes conversoes :
//              123.456.789 => 123456.789
//              123,456,789 => 123456.789
//              123.456,789 => 123456.789
//              123,456.789 => 123456.789
//              123,456     => 123.456
//              123.456     => 123.456
//              123456789   => 123456789
//
//              Para outras conversoes deve se usar o Codigo de Bloco.
//
//              Se houver algo diferente de "0123456789 -.,", o campo sera gravado
//              incorretamente na WorkArea e aMensagLog recebera a mensagem abaixo :
//              "16-Coluna na Tabela com caracteres Invalidos para o Campo Numerico !
//              Recno = "+Str((cAliasWork)->(Recno())) )
//
//              Se lMensagTela estiver como .T., a mensagem acima tambem aparecera na tela.
//
//              As mensagens 16 e 17, continuam o processamento da funcao e retornam .T. .
//              "16-Coluna na Tabela com caracteres Invalidos para o Campo Numerico !
//              Recno = "+Str((cAliasWork)->(Recno())) )
//              "17-Data gravada Incorretamente ! Recno = "+Str((cAliasWork)->(Recno()))
//
//              Na Tabela existem colunas com Tipo de Dados SIM/NAO, onde sao gravados :
//              SIM = -1 / NAO = 0, essas colunas podem ser gravadas na Work como :
//              campos do Tipo (L) - Logico e funcionarao da seguinte maneira =
//              0 = .F. / <> 0 = .T. .
//
//              IMPORTANTE a ultima chamada da funcao deve ser com lFechaDll = .T. !!!
//
//              A DLL deve estar em um diretorio que faca parte do PATH da estacao.
//              A DLL deve estar sempre na estacao e nunca no SERVER.
//
//              As mensagens de 1 a 15 e de 18 a 20 terminam a funcao e retornam .F. .
//
//              As mensagens de erros gravadas em aMensagLog tem incluidas um numero
//              que identifica o erro e em que posicao na funcao o erro ocorreu.
//
//              Os erros que vierem da DLL terao sempre o numero 99. Sendo que essas
//              mensagens tem o seguinte formato : 99-Mensagem. #Erro: -1234567890, onde:
//              Mensagem = Mensagem de erro da Microsoft OLE DB Provider for ODBC Drivers
//              -1234567890 = Numero de erro da Microsoft OLE DB Provider for ODBC Drivers
//
//              Todas as mensagens sao para uso do Desenvolvedor/Suporte !
//
// Mensagens  : "01-Fonte de Dados nao esta preenchida corretamente !"
//              "02-Tabela nao esta prenchida corretamente !"
//              "03-Complemento do Select diferente de caracter !"
//              "04-aMensagLog deve ser uma Matriz !"
//              "05-cAliasWork nao preenchida corretamente ou nao esta em uso !"
//              "06-aArrayCampos nao esta preenchida corretamente !"
//              "07-Na aArrayCampos, o formato da data esta incorreto para o Campo : "+aArrayCampos[nCont,2]+" !" )
//              "08-Campo : "+aArrayCampos[nCont,2]+" nao encontrado !"
//              "09-Tamanho do Buffer nao pode ser maior que 20000 !"
//              "10-Nao foi possivel carregar a DLL !!! nHandle = " + Str(nHandle, 2)
//              "11-Nao foi possivel Abrir a Fonte de Dados !"
//              "99-"+cBuffer // ==> Quando nao foi possivel fazer o Select na Tabela
//              "12-Erro ao fechar a Conexao !"
//              "13-O Select nao retornou nenhum registro para a WorkArea !"
//              "14-Erro ao fechar a Tabela e/ou a Conexao !"
//              "15-Erro na inclusao do registro !"
//              "16-Campo Numerico gravado Incorretamente ! Recno = "+Str((cAliasWork)->(Recno())) )
//              "17-Data gravada Incorretamente ! Recno = "+Str((cAliasWork)->(Recno()))
//              "18-Tamanho total do Conteudo dos 'campos' da tabela excedeu o limite de 19k !"
//              "19-Erro ao Fazer a Leitura da Tabela !"
//              "20-Erro ao fechar a Tabela e/ou a Conexao !"
//
// Autor      : Reinaldo Augusto
// Data       : 03/07/2003

#define EICDLL_ERROR -1
#define EICDLL_OK 0
#define EICDLL_OPEN 1
#define EICDLL_SELECT 2
#define EICDLL_FIELDNAME 3
#define EICDLL_FIELD 4
#define EICDLL_CLOSE 5
#define EICDLL_FIELDTOTAL 6
#define EICDLL_RECORDTOTAL 7
#define EICDLL_EXECUTE 8
#define EICDLL_BEGINTRANS 9
#define EICDLL_COMMITTRANS 10
#define EICDLL_ROLLBACKTRANS 11
#define EICDLL_OPEN_EXEC 12
#define EICDLL_CLOSE_EXEC 13
#define EICDLL_RELEASE_SMARTPOINTER 14

// Se lMensagTela for .T. utiliza a MsgStop para mostrar a mensagem na Tela
// Se lMensagTela for .F. nao mostra a mensagem na Tela
// M = Verifica se [M]ostra a [M]ensagem
#define MsgStopM( cMensagem ) ( Iif( lMensagTela, MsgStop( cMensagem ), "" ) )

// Grava a cMensagem no Log de erro e chama a MsgStopM
// LM = [L]og de erro e verificar se [M]ostra a [M]ensagem
#define MsgStopLM( cMensagem ) ;
        ( Iif( Len(aMensagLog) < 4096, Aadd ( aMensagLog, cMensagem ), ""),;
          MsgStopM( cMensagem ) )

*----------------------------------------------------------------------------------*
FUNCTION EICDLL( cFonteDados, cTabela, aArrayCampos, aMensagLog,;
                 cAliasWork, lProcessa, cCompSelect, lMensagTela, lFechaDll  )
*----------------------------------------------------------------------------------*

Local  nTamBuffer := 19456 // Tamanho 19K, pode ser no maximo 20000(menos de 20K)
Local  nRet, cBuffer, cAuxBuffer, nContCampos, cData, nCont
Local  nPos, nPos3, nPos4, lIncluido := .F.
Local  cDec := "", xCampo, cTipoCpo, cNomeCpo, xExecute, cTipoData, lRet := .T.
Static lAbreDll := .T. // Controle para Abrir a Dll e a Fontes de Dados
Static nHandle // Controle para guardar o nHandle entre as chamadas da Função

DEFAULT cAliasWork  := "TRB"
DEFAULT lProcessa   := .F.
DEFAULT cCompSelect := ""
DEFAULT lMensagTela := .T.
DEFAULT lFechaDll   := .T.

// Verifica se cFonteDados esta preenchida corretamente
If Empty( cFonteDados ) .Or. ValType( cFonteDados ) != "C"
    MsgStopLM( STR0173 ) //#STR0173->"01-Fonte de Dados nao esta preenchida corretamente !"
	Return ( .F. )
EndIf

// Verifica se cTabela esta preenchida corretamente
If Empty( cTabela )  .Or. ValType( cTabela ) != "C"
    MsgStopLM( STR0174 ) //#STR0174->"02-Tabela nao esta prenchida corretamente !"
	Return ( .F. )
EndIf

// Verifica se o Complemento do Select foi passado como caracter
If ValType( cCompSelect ) != "C"
    MsgStopLM( STR0175 ) //#->"03-Complemento do Select diferente de caracter !"
	Return ( .F. )
EndIf

// Verifica se aMensagLog veio como matriz
If ValType( aMensagLog ) != "A"
    MsgStopLM( STR0176 ) //#STR0176->"04-aMensagLog deve ser uma Matriz !"
	Return ( .F. )
EndIf

// Verifica se cAliasWork esta preenchida corretamente e esta em uso
If Empty( cAliasWork ) .Or. ValType( cAliasWork ) != "C" .Or.;
                            Select( cAliasWork ) < 1
    MsgStopLM( STR0177 ) //#->"05-cAliasWork nao preenchida corretamente ou nao esta em uso !"
	Return ( .F. )
EndIf

// Verifica os Array's de Campos
If ValType( aArrayCampos ) != "A"
    MsgStopLM( STR0178 ) //#->"06-aArrayCampos nao esta preenchida corretamente !"
	Return ( .F. )
EndIf
For nCont := 1 to Len( aArrayCampos )
	If Empty( aArrayCampos[nCont,1] ) .Or. Empty( aArrayCampos[nCont,2] ) .Or.;
           !( ValType( aArrayCampos[nCont,3] ) $ "CB" )
        MsgStopLM( STR0178 ) //#->"06-aArrayCampos nao esta preenchida corretamente !"
        Return ( .F. )
	EndIf
Next

// Verifica no Array de Campos se o formato das Datas esta correto
For nCont := 1 to Len( aArrayCampos )
    If ValType( (cAliasWork)->( FieldGet(FieldPos(aArrayCampos[nCont,2])) ) ) == "D"
        If .Not.( aArrayCampos[nCont,3] == "AAAAMMDD"   .Or. aArrayCampos[nCont,3] == "AAMMDD";
           .Or.   aArrayCampos[nCont,3] == "DDMMAAAA"   .Or. aArrayCampos[nCont,3] == "DDMMAA";
           .Or.   aArrayCampos[nCont,3] == "AAAA/MM/DD" .Or. aArrayCampos[nCont,3] == "AA/MM/DD";
           .Or.   aArrayCampos[nCont,3] == "DD/MM/AAAA" .Or. aArrayCampos[nCont,3] == "DD/MM/AA";
           .Or.   ValType( aArrayCampos[nCont,3] ) == "B" )
            MsgStopLM( STR0179+aArrayCampos[nCont,2]+" !" ) //#STR0179->"07-Na aArrayCampos, o formato da data esta incorreto para o Campo : "
			Return ( .F. )
		EndIf
	EndIf
Next

// Verificar se os Campos existem
For nCont := 1 To Len( aArrayCampos )
    If (cAliasWork)->( FieldPos(aArrayCampos[nCont,2]) ) == 0
        MsgStopLM( STR0180+aArrayCampos[nCont,2]+STR0152 ) //#->"08-Campo : " ##STR0152->" nao encontrado !"
        Return ( .F. )
    EndIf
Next

// Monta a Query
cQuery := 'SELECT '
For nCont := 1 To Len( aArrayCampos )
	cQuery += aArrayCampos[nCont,1] + ', '
Next
cQuery := SubStr( cQuery, 1, Len(cQuery)-2 )
cQuery += ' FROM '+cTabela+Iif( !empty(cCompSelect), (' '+cCompSelect), "" )

// Verifica o Tamanho do Buffer
If nTamBuffer > 20000
   MsgStopLM( STR0181 ) //#STR0181->"09-Tamanho do Buffer nao pode ser maior que 20000 !"
   Return ( .F. )
EndIf

// Se lAbreDll = .T., entao carrega a DLL e Abre a Fote de Dados
If lAbreDll
	// Carregar a DLL AveasyConnect.DLL
	If (nHandle := ExecInDllOpen( 'AveasyConnect.dll' )) < 0
       MsgStopLM(STR0182 + " nHandle = " + Str(nHandle, 2) )
	   Return ( .F. )
	EndIf
	// Abrir a Fonte de Dados
	cBuffer := cFonteDados + Replicate( Chr(1), nTamBuffer - Len(cFonteDados) )
	If ExeDllRun2( nHandle, EICDLL_OPEN, @cBuffer ) == EICDLL_ERROR
       MsgStopLM( STR0183 ) //#STR0183->"11-Não foi possivel Abrir a Fonte de Dados !"
       // Deixar NULL os SmartPointers
       cBuffer := ""
       ExeDLLRun2( nHandle, EICDLL_RELEASE_SMARTPOINTER, @cBuffer )
       // Descarregar a DLL AveasyConnect.DLL
       ExecInDLLClose(nHandle)
       lAbreDll := .T.
       Return ( .F. )
	EndIf
	lAbreDll := .F.
EndIf

// Fazer o Select na Tabela
cBuffer := cQuery + Replicate( Chr(1), nTamBuffer - Len(cQuery) )
If ExeDllRun2( nHandle, EICDLL_SELECT, @cBuffer ) == EICDLL_ERROR
    MsgStopLM( "99-"+cBuffer ) // Erro que vem da DLL
	If lFechaDll
		// Fechar a Tabela/Conexao
		cBuffer := ""
		If ExeDLLRun2( nHandle, EICDLL_CLOSE, @cBuffer ) == EICDLL_ERROR
			MsgStopLM( STR0184 ) //#STR0184->"12-Erro ao fechar a Conexao !"
		EndIf
		// Deixar NULL os SmartPointers
		cBuffer := ""
		ExeDLLRun2( nHandle, EICDLL_RELEASE_SMARTPOINTER, @cBuffer )
		// Descarregar a DLL AveasyConnect.DLL
		ExecInDLLClose(nHandle)
		lAbreDll := .T.
	EndIf
	Return ( .F. )
EndIf

// Verifica a quantidade de linhas trazidas pelo Comando Select
cBuffer := ""
If ExeDLLRun2( nHandle, EICDLL_RECORDTOTAL, @cBuffer ) == 0
    MsgStopLM( STR0185 )  //#->"13-O Select nao retornou nenhum registro para a WorkArea !"
	If lFechaDll
		// Fechar a Tabela/Conexao
		cBuffer := ""
		If ExeDLLRun2( nHandle, EICDLL_CLOSE, @cBuffer ) == EICDLL_ERROR
			MsgStopLM( STR0186 ) //#->"14-Erro ao fechar a Tabela e/ou a Conexao !"
		EndIf
		// Deixar NULL os SmartPointers
		cBuffer := ""
		ExeDLLRun2( nHandle, EICDLL_RELEASE_SMARTPOINTER, @cBuffer )
		// Descarregar a DLL AveasyConnect.DLL
		ExecInDLLClose(nHandle)
		lAbreDll := .T.
	EndIf
	Return ( .F. )
EndIf

// Envia total de registro a processar para a Funcao Processa(), se lProcessa = .T.
If lProcessa
    ProcRegua( ExeDLLRun2( nHandle, EICDLL_RECORDTOTAL, @cBuffer ) ) // Total a Processar
EndIf

// Buscar as Colunas da Tabela (Campos)
cBuffer := Space( nTamBuffer )
nRet := ExeDLLRun2( nHandle, EICDLL_FIELD, @cBuffer )

// Processamento = Obter Conteudo das colunas(campos) de cada linha e Gravar na Work
Do While ! ( cBuffer == "<AveasyConnect#EOF>"     .Or.;
	         cBuffer == "<AveasyConnect#INVSIZE>" .Or.;
             nRet    == EICDLL_ERROR )

    // Preparacao para buscar o primeiro campo
	cAuxBuffer := cBuffer
	nContCampos := 1
	nPos := At( "<#>", cAuxBuffer )
	If nPos <> 0

       // Atualiza a Barra de Processamento, se lProcessa = .T.
       If lProcessa
           IncProc( STR0187 ) //#STR0187->"Gravando os Dados ..."
       EndIf

       // Inclui um registro em branco
	   lIncluido := (cAliasWork)->(RecLock(cAliasWork, .T.))
	   If !lIncluido
	      MsgStopLM( STR0188 ) //#STR0188->"15-Erro na inclusao do registro !"
	      Exit
	   EndIf

	EndIf

    // Processa enquanto existirem campos
	Do While nPos <> 0 .and. lIncluido

        // Tipo do Campo
        cTipoCpo := ValType( (cAliasWork)->( FieldGet(FieldPos(aArrayCampos[nContCampos,2])) ) )

        // Conteudo do Campo
        xCampo   := SubStr(cAuxBuffer, 1, (nPos-1))

        // Nome do Campo
        cNomeCpo := aArrayCampos[nContCampos,2]

        // Codigo de Bloco a ser executado para o campo ou Formato da Data para o campo
        xExecute := aArrayCampos[nContCampos,3]

        // Tratamento para cada Tipo de Campo
        If cTipoCpo $ "CM"
            If ValType( xExecute ) == "B"
                xCampo := Eval( xExecute, xCampo )
            EndIf

		ElseIf cTipoCpo == "N"
            If ValType( xExecute ) != "B"
                nPos4 := 0
                For nPos3 := Len(xCampo) To 1 Step -1
                    If !(SubStr(xCampo,nPos3,1) $ "0123456789 -.,")
                        MsgStopLM( STR0189 + " Recno = "+Str((cAliasWork)->(Recno())) ) //#STR0189->"16-Coluna na Tabela com caracteres Invalidos para o Campo Numerico !"
                    ElseIf SubStr(xCampo,nPos3,1) $ ",." .And. nPos4 == 0
                        nPos4 := nPos3
                    EndIf
                Next
                xCampo := StrTran(xCampo,"E-","00" ) // Para valores negativos altos
                xCampo := StrTran(xCampo,"E+","00" ) // Para valores positivos altos
                cDec := ""
                If nPos4 <> 0
                    cDec   := "."+SubStr(xCampo,nPos4+1)
                    xCampo := SubStr(xCampo,1,nPos4-1)
                    xCampo := StrTran(xCampo,".","" )
                    xCampo := StrTran(xCampo,",","" )
                Endif
                xCampo := Val(xCampo+cDec)
            Else
                xCampo := Eval( xExecute, xCampo )
            Endif

		ElseIf cTipoCpo == "L"
            If ValType( xExecute ) != "B"
                xCampo := Iif( xCampo == "0", .F., .T. )
            Else
                xCampo := Eval( xExecute, xCampo )
            EndIf

		ElseIf cTipoCpo == "D"
            If ValType( xExecute ) != "B"
                cTipoData := xExecute
                cData := xCampo
                cData := StrTran( cData,"/","" ) //Retira as "/", se existirem
                Do Case
                    Case cTipoData == "AAAAMMDD" .Or. cTipoData == "AAAA/MM/DD"
                        cData := SubStr( cData, 7, 2 ) + "/" + SubStr( cData, 5, 2) + "/" + SubStr( cData, 1, 4 )
                    Case cTipoData == "DDMMAAAA" .Or. cTipoData == "DD/MM/AAAA"
                        cData := SubStr( cData, 1, 2 ) + "/" + SubStr( cData, 3, 2) + "/" + SubStr( cData, 5, 4 )
                    Case cTipoData == "AAMMDD" .Or. cTipoData == "AA/MM/DD"
                        cData := SubStr( cData, 7, 2 ) + "/" + SubStr( cData, 5, 2) + "/" + SubStr( cData, 1, 2 )
                    Case cTipoData == "DDMMAA" .Or. cTipoData == "DD/MM/AA"
                        cData := SubStr( cData, 1, 2 ) + "/" + SubStr( cData, 3, 2) + "/" + SubStr( cData, 5, 2 )
                EndCase
                If !Empty( SubStr( xCampo, 1, 1 ) ) .And. Empty( CtoD( cData ) )
                    MsgStopLM( STR0190+" Recno = "+Str((cAliasWork)->(Recno())) )//#STR0190->"17-Data gravada Incorretamente !"
                EndIf
                xCampo := CToD(cData)
            Else
                xCampo := Eval( xExecute, xCampo )
            EndIf
		EndIf

        // Grava o conteudo do campo na Work
        (cAliasWork)->(FieldPut(FieldPos(cNomeCpo), xCampo ))

        // Preparacao para buscar o proximo campo
		cAuxBuffer := SubStr( cAuxBuffer, (nPos+3), (Len(cAuxBuffer)-(nPos+2)) )
		nPos := At( "<#>", cAuxBuffer )
		nContCampos++

	EndDo

    // Se foi incluido um registro, faz o desbloqueio
	If lIncluido
		(cAliasWork)->( MSUnLock() )
	EndIf

    // Buscar as Colunas da Tabela (Campos)
	cBuffer := Space( nTamBuffer )
	nRet := ExeDLLRun2( nHandle, EICDLL_FIELD, @cBuffer )

EndDo

// Se houve algum erro, mostrar a mensagem de erro
If cBuffer == "<AveasyConnect#INVSIZE>"
	lRet := .F. // Faz a funcao retornar falso
    MsgStopLM( STR0191 ) //#->"18-Tamanho total do Conteudo dos 'campos' da tabela excedeu o limite de 19k !"
ElseIf nRet == EICDLL_ERROR
	lRet := .F. // Faz a funcao retornar falso
    MsgStopLM( STR0192 )//#->"19-Erro ao Fazer a Leitura da Tabela !"
EndIf

// Se lFechaDll = .T., entao fechar a Tabela/Conexao e Descarregar a DLL
If lFechaDll
	// Fechar a Tabela/Conexao
	cBuffer := ""
	If ExeDLLRun2( nHandle, EICDLL_CLOSE, @cBuffer ) == EICDLL_ERROR
        MsgStopLM( STR0193 ) //#STR0193->"20-Erro ao fechar a Tabela e/ou a Conexão !"
	EndIf
	// Deixar NULL os SmartPointers
	cBuffer := ""
	ExeDLLRun2( nHandle, EICDLL_RELEASE_SMARTPOINTER, @cBuffer )
	// Descarregar a DLL AveasyConnect.DLL
	ExecInDLLClose(nHandle)
	lAbreDll := .T.
EndIf

Return ( lRet )

// Funcao     : EICDLLSQL
// Objetivo   : Executar INSERT/UPDATE/DELETE em uma Tabela(MDB) utilizando uma WorkArea
//
// Sintaxe    : EICDLLSQL( cFonteDados, aEicdll, cWATipoOper, aMensagLog,;
//                         cAliasWork,  cWAErro, lProcessa,   lMensagTela )
//
// Parametros : cFonteDados  = Fonte de Dados(ODBC) do Usuario
//              aEicdll      = Matriz com as informacoes abaixo mencionadas
//              cWATipoOper  = Nome do Campo na Work que contera o Tipo de Operacao(IAE)
//              aMensagLog   = Nome da matriz para armazenar as mensagens de erro
//              cAliasWork   = Alias da Work (Arquivo DBF)
//              cWAErro      = Nome do Campo na Work que contera o erro, se existir
//              lProcessa    = Indica se havera uso da funcao Processa() (.T.)/(.F.)
//              lMensagTela  = Indica se as mensagens devem aparecer na tela (.T.)/(.F.)
//
// Matriz :     aEicdll = Matriz contendo os "parametros" abaixo mencionados :
//
//              cTipo        = "I"-Inclusao,"A"-Alteracao,"E"-Exclusao," "-Sem Operacao
//              cTabela      = Nome da Tabela
//              aArrayCampos = Colunas da Tabela/Campos do cAliasWork/Veja Observacoes
//              aArrayChaves = Colunas chaves Tab./Campos de cAliasWork/Veja Observacoes
//
// Obs. Matriz: aEicdll deve conter 3 elementos
//              Primeiro => Inclusao
//              Segundo  => Alteracao
//              Terceiro => Exclusao
//              Caso nao exista alguma dessas operacoes, deixar com " " o cTipo
//              respectivo e os outros "parametros" podem ficar como NIL.
//
// Default    : DEFAULT cAliasWork  := "TRB"
//              DEFAULT cWAErro     := ""
//              DEFAULT lProcessa   := .F.
//              DEFAULT lMensagTela := .T.
//
// Retorno    : .T. se obteve sucesso, ou .F. se nao obteve sucesso.
//
// Observacoes: cAliasWork deve existir e estar aberto.
//
//              aMensagLog deve ser inicializada com {} no programa chamador.
//
//              No parametro aArrayCampos e no aArrayChaves, a terceira dimensao
//              do array, contera o formato da Data para Campo Data OU um Codigo
//              de Bloco para qualquer Tipo de Campo da Work OU deve ser preenchida
//              com "".
//
//              Formato da Data : "DDMMAA", "AAMMDD", "AAAAMMDD", "DDMMAAAA",
//              "DD/MM/AA", "AA/MM/DD", "AAAA/MM/DD", "DD/MM/AAAA".
//
//              O Codigo de Bloco deve retornar o conteudo a ser gravado no Campo.
//              O conteudo que vai ser retornado pelo Codigo de Bloco deve ser
//              compativel com a coluna da tabela. Nao existe validacao pela funcao
//              desse conteudo.
//
//              No parametro aArrayCampos e no aArrayChaves, a quarta dimensao do
//              array, contera "NULL" para os casos em a coluna da tabela precise
//              ficar com NULL. O Tipo de campo Logico nao utilizara este recurso.
//              Se for passado "NULL" para o campo Logico, nao havera nenhum efeito,
//              ou seja, sera gravado 0 ou -1, caso se precise passar NULL para uma
//              coluna com tipo logico em uma tabela, utilize o Codigo de Bloco.
//              Para os demais campos utilizados por este funcao, sera utilizado,
//              o seguinte criterio : Se Empty(campo) entao envia NULL para a coluna.
//              Caso se passe o terceiro parametro como Codigo de Bloco e o quarto
//              parametro como "NULL", sera utilizado o seguinte criterio :
//              Se Empty(Eval(Codigo de Bloco)) entao envia NULL para a coluna.
//
//              Se for Inclusao ou Alteracao o aArraycampos deve estar preenchido,
//              ou seja, no minimo com o primeiro e segundo elemento preenchido,
//              segue abaixo alguns Exemplos :
//              aArrayCampos := { { "coluna", "campo", ""                   , ""    } }
//              aArrayCampos := { { "coluna", "campo", "DDMMAAAA"           , "NULL"} }
//              aArrayCampos := { { "coluna", "campo", "DDMMAA"             , "NULL"} }
//              aArrayCampos := { { "coluna", "campo", {|X| Val(X)}         , ""    } }
//              aArrayCampos := { { "coluna", "campo", {|X| "'"+DToS(X)+"'"}, "NULL"} }
//              Caso contrario pode estar como : aArrayCampos := { { "", "", "", "" } }
//
//              Se for Alteracao ou Exclusao o aArraychaves deve estar preenchido,
//              ou seja, no minimo com o primeiro e segundo elemento preenchido,
//              segue abaixo alguns Exemplos :
//              aArrayChaves := { { "coluna", "campo", ""          , "NULL" } }
//              aArrayChaves := { { "coluna", "campo", "DD/MM/AAAA", "NULL" } }
//              aArrayChaves := { { "coluna", "campo", "AA/MM/DD"  , "NULL" } }
//              aArrayChaves := { { "coluna", "campo", {|X| Iif((X=="-"),"'-'", "'+'"}, "" } }
//              aArrayChaves := { { "coluna", "campo", {|X| Iif((Val(X)>=0),Val(X),Val(X)*-1)}, "" } }
//              aArrayChaves := { { "coluna", "campo", {|X| "'"+DToC(X)+"'", "NULL" } }
//              Caso contrario pode estar como : aArrayChaves := { { "", "", "", "" } }
//
//              Tipos de Campos que podem ser utilizado por esta funcao =
//              C (Caracter), N (Numerico), D (Data), M (Memo), L (Logico).
//
//              Na Tabela existem colunas com Tipo de Dados SIM/NAO, onde são gravados :
//              SIM = -1 / NAO = 0. Os campos do Tipo (L)-Logico serao gravados nestas
//              colunas da seguinte maneira : Para .T. => -1 / .F. => 0 .
//
//              IMPORTANTE a ultima chamada da funcao deve ser com lFechaDll = .T. !!!
//
//              A DLL deve estar em um diretorio que faca parte do PATH da estação.
//              A DLL deve estar sempre na estação e nunca no SERVER.
//
//              As mensagens de 1 a 23 e de 26 a 29 terminam a funcao e retornam .F. .
//
//              As mensagens de erros gravadas em aMensagLog tem incluidas um numero
//              que identifica o erro e em que posicao na funcao o erro ocorreu.
//
//              Os erros diretos da DLL terao sempre o numero 99. Sendo que essas
//              mensagens tem o seguinte formato : 99-Mensagem. #Erro: -1234567890, onde:
//              Mensagem = Mensagem de erro da Microsoft OLE DB Provider for ODBC Drivers
//              -1234567890 = Numero de erro da Microsoft OLE DB Provider for ODBC Drivers
//              ou 99-Nenhuma linha foi alterada e/ou excluida pelo comando.
//
//              As mensagens 99 sao gravadas no Log, na WorkArea e terminam a funcao.
//
//              As Mensagens :
//                 "Tipo de Operacao na WorkArea nao passado como parametro na Funcao !"
//                 "Tipo de Operacao na WorkArea invalido !"
//              Sao gravadas somente na WorkArea e nao terminam a funcao.
//
//              Todas as mensagens sao para uso do Desenvolvedor/Suporte !
//
// Mensagens  : "01-Tipo de aEicdll diferente de Matriz ou Tamanho diferente de 3 !"
//              "02-cTipo do primeiro elemento da matriz deve ser Caracter!"
//              "03-cTipo do primeiro elemento da matriz deve ser 'I' ou ' ' !"
//              "04-cTipo do segundo elemento da matriz deve ser Caracter!"
//              "05-cTipo do segundo elemento da matriz deve ser 'A' ou ' ' !"
//              "06-cTipo do terceiro elemento da matriz deve ser Caracter!"
//              "07-cTipo do terceiro elemento da matriz deve ser 'E' ou ' ' !"
//              "08-Fonte de Dados nao esta preenchida corretamente !"
//              "09-aMensagLog deve ser uma Matriz !"
//              "10-WorkArea nao esta preenchida corretamente!"
//              "11-WorkArea nao esta em uso !"
//              "12-Campo : "+cWAErro+" do Alias : "+cAliasWork+" => Erro: Tipo do campo deve ser caracter."
//              "13-Tabela nao esta prenchida corretamente !"
//              "14-aArrayCampos nao esta preenchida corretamente !"
//              "15-aArrayChaves nao esta preenchida corretamente !"
//              "16-Campo : "+aArrayCampos[nCont,2]+" nao encontrado !"
//              "17-Na aArrayCampos, o formato da data esta incorreto para o Campo : "+aArrayCampos[nCont,2]+" !"
//              "18-Campo : "+aArrayChaves[nCont,2]+" nao encontrado !"
//              "19-Na aArrayChaves, o formato da data esta incorreto para o Campo : "+aArrayCampos[nCont,2]+" !"
//              "20-cTipo nao foi preenchido para nenhum elemento da matriz !"
//              "21-Nao foi possivel carregar a DLL !!! nHandle = " + Str(nHandle, 2)
//              "22-Nao foi possivel Abrir a Fonte de Dados !"
//              "23-Nao foi possivel Iniciar a Transacao (BEGIN) !"
//              "99-"+cBuffer
//              "24-Nao foi possivel fazer a gravacao deste erro no Campo : "+cWAErro+" do Alias : "+cAliasWork+". Registro nao pode ser bloqueado para gravacao."
//              "25-Nao foi possivel fazer a gravacao deste erro no Campo : "+cWAErro+" do Alias : "+cAliasWork+". Registro nao pode ser bloqueado para gravacao."
//              "26-Erro ao Gravar (COMMIT) os Dados !"
//              "27-Desfazendo as alteracoes anteriores (ROLLBACK) !"
//              "28-Erro ao Desfazer as alteracoes anteriores (ROLLBACK) !"
//              "29-Erro ao fechar a Tabela e/ou a Conexao !"
//
// Autor      : Reinaldo Augusto
// Data       : 03/07/2003

// Se lMensagTela for .T. utiliza a MsgStop para mostrar a mensagem na Tela
// Se lMensagTela for .F. nao mostra a mensagem na Tela
// M = Verifica se [M]ostra a [M]ensagem
#define MsgStopM( cMensagem ) ( Iif( lMensagTela, MsgStop( cMensagem ), "" ) )

// Grava a cMensagem no Log de erro e chama a MsgStopM
// LM = [L]og de erro e verificar se [M]ostra a [M]ensagem
#define MsgStopLM( cMensagem );
 ( Iif( Len(aMensagLog) < 4096, Aadd ( aMensagLog, cMensagem ), "" ),;
   MsgStopM( cMensagem ) )

*----------------------------------------------------------------------------------*
FUNCTION EICDLLSQL( cFonteDados, aEicdll, cWATipoOper, aMensagLog,;
                    cAliasWork,  cWAErro, lProcessa, lMensagTela  )
*----------------------------------------------------------------------------------*

Local cTipo
Local cTabela
Local aArrayCampos
Local aArrayChaves

Local nCont, cExecuta, cBuffer, nHandle, cData, lOk, xExecute,  nTotProc := 0
Local nCnt,  cColuna, cTipoCpo, xCampo, xChave, lRet,cTipoData, cAuxBuffer, lNull

DEFAULT cAliasWork  := "TRB"
DEFAULT cWAErro     := ""
DEFAULT lProcessa   := .F.
DEFAULT lMensagTela := .T.

// Verifica os elementos da Matriz
If ValType( aEicdll ) != "A" .Or. Len( aEicdll ) <> 3
    MsgStopLM( STR0194 ) //#STR0194->"01-Tipo de aEicdll diferente de Matriz ou Tamanho diferente de 3 !"
	Return ( .F. )
EndIf

// Verifica o tipo do primeiro elementro da matriz
If ValType( aEicdll[1,1] ) != "C"
  	MsgStopLM( STR0195 ) //#STR0195->"02-cTipo do primeiro elemento da matriz deve ser Caracter!"
	Return ( .F. )
EndIf
If !( aEicdll[1,1] $ "I " )
  	MsgStopLM( STR0196 ) //#STR0196->"03-cTipo do primeiro elemento da matriz deve ser 'I' ou ' ' !"
	Return ( .F. )
EndIf

// Verifica o tipo do segundo elementro da matriz
If ValType( aEicdll[2,1] ) != "C"
  	MsgStopLM( STR0197 ) //#STR0197->"04-cTipo do segundo elemento da matriz deve ser Caracter!"
	Return ( .F. )
EndIf
If !( aEicdll[2,1] $ "A " )
  	MsgStopLM( STR0198 ) //#STR0198->"05-cTipo do segundo elemento da matriz deve ser 'A' ou ' ' !"
	Return ( .F. )
EndIf

// Verifica o tipo do terceiro elementro da matriz
If ValType( aEicdll[3,1] ) != "C"
  	MsgStopLM( STR0199 ) //#STR0199->"06-cTipo do terceiro elemento da matriz deve ser Caracter!"
	Return ( .F. )
EndIf
If !( aEicdll[3,1] $ "E " )
  	MsgStopLM( STR0200 ) //#STR0200->"07-cTipo do terceiro elemento da matriz deve ser 'E' ou ' ' !"
	Return ( .F. )
EndIf

// Verifica se cFonteDados esta preenchida
If Empty( cFonteDados ) .Or. ValType( cFonteDados ) != "C"
    MsgStopLM( STR0201 ) //#STR0201->"08-Fonte de Dados nao esta preenchida corretamente !"
	Return ( .F. )
EndIf

// Verifica se aMensagLog veio como Matriz
If ValType( aMensagLog ) != "A"
    MsgStopLM( STR0202 ) //#STR0202->"09-aMensagLog deve ser uma Matriz !"
	Return ( .F. )
EndIf

// Verifica se cAliasWork esta preenchida e se veio com o tipo correto
If Empty( cAliasWork ) .Or. ValType( cAliasWork ) != "C"
    MsgStopLM( STR0203 ) //#STR0203->"10-WorkArea nao esta preenchida corretamente !"
	Return ( .F. )
EndIf

// Verifica se cAliasWork esta em uso
If Select( cAliasWork ) < 1
	MsgStopLM( STR0204 ) //#STR0204->"11-WorkArea nao esta em uso !"
	Return ( .F. )
EndIf

// Verifica se cWAErro esta preenchido e se o tipo de campo esta correto
If !Empty( cWAErro )
    If !( ValType ( (cAliasWork)->(FieldGet(FieldPos(cWAErro))) ) $ "CM" )
		MsgStopLM( "12-"+STR0146+cWAErro+STR0207+cAliasWork+" => "+ STR0205 ) //#STR0146->"Campo : " ##STR0205->"Erro: Tipo do campo deve ser caracter." ###STR0207->" do Alias : "
		Return ( .F. )
	EndIf
EndIf

// Verifica os outros parametros da Matriz aEicdll
For nCnt = 1 to Len( aEicdll )

    cTipo := aEicdll[nCnt,1]

    // Se cTipo esta em branco nao existe a Operacao
	If cTipo == " "
		Loop // Volta para o Inicio do For e Incrementa o nCnt
  	EndIf

    cTabela      := aEicdll[nCnt,2]
    aArrayCampos := aEicdll[nCnt,3]
    aArrayChaves := aEicdll[nCnt,4]

    nTotProc++ // Soma um ao Contador de Elementos da Matriz a serem processados

	// Verifica se cTabela esta preenchida
    If Empty( cTabela ) .Or. ValType( cTabela ) != "C"
        MsgStopLM( STR0208 ) //#STR0208->"13-Tabela nao esta prenchida corretamente !"
		Return ( .F. )
	EndIf

	// Verifica o Array de Campos
	// Se for Inclusao ou Alteracao, aArrayCampos deve estar preenchida corretamente
	If cTipo $ "IA"
        If ValType( aArrayCampos ) != "A"
            MsgStopLM( STR0209 ) //#STR0209->"14-aArrayCampos nao esta preenchida corretamente !"
            Return ( .F. )
        EndIf
		For nCont := 1 to Len( aArrayCampos )
	        If Len( aArrayCampos[nCont] ) != 4
                MsgStopLM( "14-aArrayCampos" + STR0210  ) //#STR0210->" nao esta preenchida corretamente !!"
                Return ( .F. )
            EndIf
			If Empty( aArrayCampos[nCont,1] ) .Or.;
			   Empty( aArrayCampos[nCont,2] ) .Or.;
               !( ValType( aArrayCampos[nCont,3] ) $ "CB" ) .Or.;
               ValType( aArrayCampos[nCont,4] ) != "C"  .Or.;
               ( !Empty(aArrayCampos[nCont,4]) .And. aArrayCampos[nCont,4] != "NULL" )
			  	MsgStopLM( "14-aArrayCampos" + STR0210  ) //#STR0210->" nao esta preenchida corretamente !!"
				Return ( .F. )
			EndIf
		Next
	EndIf

	// Verifica o Array de Chaves
	// Se for Alteracao ou Exclusao, aArrayChaves deve estar preenchida corretamente
	If cTipo $ "AE"
        If ValType( aArrayChaves ) != "A"
            MsgStopLM( "15-aArrayChaves"+ STR0210  ) //#STR0210->" não esta preenchida corretamente!"
            Return ( .F. )
        EndIf
		For nCont := 1 to Len( aArrayChaves )
	        If Len( aArrayChaves[nCont] ) != 4
                MsgStopLM( "15-aArrayChaves"+ STR0210  ) //#STR0210->" não esta preenchida corretamente!"
                Return ( .F. )
            EndIf
			If Empty( aArrayChaves[nCont,1] ) .Or.;
			   Empty( aArrayChaves[nCont,2] ) .Or.;
               !( ValType( aArrayChaves[nCont,3] ) != "CB" ) .Or.;
	           ValType( aArrayChaves[nCont,4] ) != "C"  .Or.;
	           ( !Empty(aArrayChaves[nCont,4]) .And. aArrayChaves[nCont,4] != "NULL" )
			  	MsgStopLM( "15-aArrayChaves" + STR0210  ) //#STR0210->" não esta preenchida corretamente!"
				Return ( .F. )
			EndIf
  		Next
	EndIf

	If cTipo $ "IA"

		// Verificar se os Campos existem
		For nCont := 1 To Len( aArrayCampos )
            If (cAliasWork)->( FieldPos(aArrayCampos[nCont,2]) ) == 0
                MsgStopLM( "16-"+STR0146+aArrayCampos[nCont,2]+ STR0152 ) //#STR0146->"Campo: " ##STR0152->" nao encontrado !"
				Return ( .F. )
			EndIf
		Next

		// Verifica no Array de Campos se o formato das Datas esta correto
		For nCont := 1 to Len( aArrayCampos )
            If ValType( (cAliasWork)->( FieldGet(FieldPos(aArrayCampos[nCont,2])) ) ) == "D"
                If .Not.( aArrayCampos[nCont,3] == "AAAAMMDD"   .Or. aArrayCampos[nCont,3] == "AAMMDD";
                   .Or.   aArrayCampos[nCont,3] == "DDMMAAAA"   .Or. aArrayCampos[nCont,3] == "DDMMAA";
                   .Or.   aArrayCampos[nCont,3] == "AAAA/MM/DD" .Or. aArrayCampos[nCont,3] == "AA/MM/DD";
                   .Or.   aArrayCampos[nCont,3] == "DD/MM/AAAA" .Or. aArrayCampos[nCont,3] == "DD/MM/AA" );
                   .Or.   ValType( aArrayCampos[nCont,3] ) == "B"
                    MsgStopLM( "17-Na aArrayCampos," + STR0206 +aArrayCampos[nCont,2]+" !" ) //#STR0206->" o formato da data esta incorreto para o Campo : "
					Return ( .F. )
				EndIf
			EndIf
		Next

	EndIf

	If cTipo $ "AE"

		// Verificar se as Chaves tem o tipo correto
		For nCont := 1 To Len( aArrayChaves )
            If (cAliasWork)->( FieldPos(aArrayChaves[nCont,2]) ) == 0
	            MsgStopLM( "18-"+ STR0146+aArrayChaves[nCont,2]+STR0152 ) //#STR0146->Campo : " ##STR0152->" nao encontrado !"
				Return ( .F. )
			EndIf
		Next

		// Verifica no Array de Chaves se o formato das Datas esta correto
		For nCont := 1 to Len( aArrayChaves )
            If ValType( (cAliasWork)->( FieldGet(FieldPos(aArrayChaves[nCont,2])) ) ) == "D"
                If .Not.( aArrayChaves[nCont,3] == "AAAAMMDD"   .Or. aArrayChaves[nCont,3] == "AAMMDD";
                   .Or.   aArrayChaves[nCont,3] == "DDMMAAAA"   .Or. aArrayChaves[nCont,3] == "DDMMAA";
                   .Or.   aArrayChaves[nCont,3] == "AAAA/MM/DD" .Or. aArrayChaves[nCont,3] == "AA/MM/DD";
                   .Or.   aArrayChaves[nCont,3] == "DD/MM/AAAA" .Or. aArrayChaves[nCont,3] == "DD/MM/AA" );
                   .Or.   ValType( aArrayChaves[nCont,3] ) == "B"
	                MsgStopLM( "19-Na aArrayChaves," + STR0211 + aArrayCampos[nCont,2]+" !" ) //#STR0211->" o formato da data esta incorreto para o Campo : "
                    Return ( .F. )
				EndIf
			EndIf
		Next

	EndIf

Next

// Se cTipo nao foi preenchido para nenhum elemento da matriz, mostra erro e retorna .F.
If nTotProc == 0
	MsgStopLM( "20-cTipo" + STR0212 ) //#STR0212->" nao foi preenchido para nenhum elemento da matriz !"
	Return ( .F. )
EndIf

// Carregar a DLL AveasyConnect.DLL
If (nHandle := ExecInDllOpen( 'AveasyConnect.dll' )) < 0
  	MsgStopLM( "21-" + STR0213 + " nHandle = " + Str(nHandle, 2) ) //#STR0213"->Nao foi possivel carregar a AveasyConnect.DLL !!!"
  	Return ( .F. )
EndIf

// Abrir a Fonte de Dados
cBuffer := cFonteDados
If ExeDllRun2( nHandle, EICDLL_OPEN_EXEC, @cBuffer ) == EICDLL_ERROR
  	MsgStopLM( "22-" + STR0214 ) //#STR0214->"Nao foi possivel Abrir a Fonte de Dados !"
	// Deixar NULL os SmartPointers
	cBuffer := ""
	ExeDLLRun2( nHandle, EICDLL_RELEASE_SMARTPOINTER, @cBuffer )
  	// Descarregar a DLL AveasyConnect.DLL
  	ExecInDLLClose(nHandle)
  	Return ( .F. )
EndIf

// Iniciar a Transacao
cBuffer := ""
If ExeDllRun2( nHandle, EICDLL_BEGINTRANS, @cBuffer ) == EICDLL_ERROR
  	MsgStopLM( "23-" + STR0215 + " (BEGIN) !" )//#STR0215->"Nao foi possivel Iniciar a Transacao"
	// Deixar NULL os SmartPointers
	cBuffer := ""
	ExeDLLRun2( nHandle, EICDLL_RELEASE_SMARTPOINTER, @cBuffer )
  	// Descarregar a DLL AveasyConnect.DLL
  	ExecInDLLClose(nHandle)
  	Return ( .F. )
EndIf

// Envia total de registro a processar para a Funcao Processa(), se lProcessa = .T.
If lProcessa
    ProcRegua( (cAliasWork)->( EasyRecCount(cAliasWork) ) )
EndIf

// Seta lOk (Controle do Processamento) como verdadeira para iniciar o Processamento
lOk := .T.

// Inicia o Processamento
// Monta e Executa o comando SQL para cada registro da WorkArea
// de acordo com o tipo ( Inclusao / Alteracao / Exclusao )
(cAliasWork)->( DbGoTop() )
Do While !( (cAliasWork)->( Eof() ) )

    // Atualiza a Barra de Processamento, se lProcessa = .T.
    If lProcessa
        IncProc(STR0187) //#STR0187->"Processando os Dados ..."
    EndIf

    // Tipo de Operacao que vem da WorkArea
    cTipoCPo := (cAliasWork)->( FieldGet(FieldPos(cWATipoOper)) )

	// Se for Inclusao
    If  cTipoCpo == "I" .And. aEicdll[1,1] == "I"
		cTipo 		 := aEicdll[1,1]
        cTabela      := aEicdll[1,2]
		aArrayCampos := aEicdll[1,3]
		aArrayChaves := aEicdll[1,4]
        // Montagem do Comando INSERT
		cExecuta := 'INSERT INTO '+cTabela+' ('
		For nCont := 1 To Len( aArrayCampos )
            xCampo := (cAliasWork)->( FieldGet(FieldPos(aArrayCampos[nCont,2])) )
			cExecuta += aArrayCampos[nCont,1] + ', '
		Next
		cExecuta := SubStr( cExecuta, 1, Len(cExecuta)-2 )
		cExecuta += ') VALUES ('
		For nCont := 1 To Len( aArrayCampos )
            // Codigo de Bloco a ser executado para o campo ou Formato da Data para o campo
            xExecute := aArrayCampos[nCont,3]
            // Coluna precisa de NULL (.T./.F.)
            lNull := Iif( aArrayCampos[nCont,4] == "NULL", .T., .F. )
            // Campo
            xCampo := (cAliasWork)->( FieldGet(FieldPos(aArrayCampos[nCont,2])) )
            If ValType( xExecute ) == "B" // Se tem Codigo de Bloco, ja executa
            	If !lNull // Verifica se foi passado NULL no quarto parametro
                	cExecuta += Eval( xExecute, xCampo ) + ", "
                Else
                	cExecuta += Iif( !Empty( Eval( xExecute, xCampo ) ),;
                	                         Eval( xExecute, xCampo ) + ", ",;
                	                         "NULL, " )
                EndIf
            ElseIf ValType ( xCampo ) $ "CM"
            	If !lNull
                    cExecuta += "'" + xCampo + "', "
                Else
                	cExecuta += Iif( !Empty(xCampo),("'" + xCampo + "', "), "NULL, " )
                EndIf
            ElseIf ValType ( xCampo ) == "N"
             	If !lNull
                    cExecuta += Str( xCampo ) + ", "
                Else
                	cExecuta += Iif( !Empty(xCampo),(Str( xCampo ) + ", "), "NULL, " )
                EndIf
            ElseIf ValType ( xCampo ) == "L"
                // Se foi passado NULL no quarto parametro nao faz o tratamento de NULL
                cColuna := Iif( xCampo, "-1", "0" )
                cExecuta += cColuna + ", "
            ElseIf ValType ( xCampo ) == "D"
                cTipoData := aArrayCampos[nCont,3]
                cData := DToS( xCampo )
				Do Case
                    Case cTipoData == "AAAAMMDD"
                        // cData := cData
                    Case cTipoData == "DDMMAAAA"
					  	cData := SubStr( cData, 7, 2 ) + SubStr( cData, 5, 2) +  SubStr( cData, 1, 4 )
                    Case cTipoData == "AAMMDD"
					  	cData := SubStr( cData, 3, 2 ) + SubStr( cData, 5, 2) +  SubStr( cData, 7, 2 )
                    Case cTipoData == "DDMMAA"
					  	cData := SubStr( cData, 7, 2 ) + SubStr( cData, 5, 2) +  SubStr( cData, 3, 2 )
                    Case cTipoData == "AAAA/MM/DD"
                        cData := SubStr( cData, 1, 4 ) + "/" + SubStr( cData, 5, 2) + "/" + SubStr( cData, 7, 2 )
                    Case cTipoData == "DD/MM/AAAA"
                        cData := SubStr( cData, 7, 2 ) + "/" + SubStr( cData, 5, 2) + "/" + SubStr( cData, 1, 4 )
                    Case cTipoData == "AA/MM/DD"
                        cData := SubStr( cData, 3, 2 ) + "/" + SubStr( cData, 5, 2) + "/" + SubStr( cData, 7, 2 )
                    Case cTipoData == "DD/MM/AA"
                        cData := SubStr( cData, 7, 2 ) + "/" + SubStr( cData, 5, 2) + "/" + SubStr( cData, 3, 2 )
				EndCase
            	If !lNull
					cExecuta += "'" + cData + "', "
                Else
                	cExecuta += Iif( !Empty(xCampo),("'" + cData + "', "), "NULL, " )
                EndIf
 			EndIf
		Next
		cExecuta := SubStr( cExecuta, 1, Len(cExecuta)-2 ) +	')'

	// Na WorkArea existe uma Inclusao e nao foi passado esta opcao na aEicdll
    ElseIf cTipoCpo == "I" .And. aEicdll[1,1] == " "
		lOk := .F.

	// Se for Alteracao
    ElseIf cTipoCpo == "A" .And. aEicdll[2,1] == "A"
		cTipo 		 := aEicdll[2,1]
        cTabela      := aEicdll[2,2]
		aArrayCampos := aEicdll[2,3]
		aArrayChaves := aEicdll[2,4]
        // Montagem do Comando UPDATE
		cExecuta := 'UPDATE '+cTabela+' SET '
		For nCont := 1 To Len( aArrayCampos )
            // Codigo de Bloco a ser executado para o campo ou Formato da Data para o campo
            xExecute := aArrayCampos[nCont,3]
            // Coluna precisa de NULL (.T./.F.)
            lNull := Iif( aArrayCampos[nCont,4] == "NULL", .T., .F. )
            // Campo
            xCampo := (cAliasWork)->( FieldGet(FieldPos(aArrayCampos[nCont,2])) )
            // Montagem do Comando
			cExecuta += aArrayCampos[nCont,1] + ' = '
            If ValType( xExecute ) == "B" // Se tem Codigo de Bloco, ja executa
            	If !lNull // Verifica se foi passado NULL no quarto parametro
                	cExecuta += Eval( xExecute, xCampo ) + ", "
                Else
                	cExecuta += Iif( !Empty( Eval( xExecute, xCampo ) ),;
                  	                         Eval( xExecute, xCampo ) + ", ",;
                	                         "NULL, " )
                EndIf
            ElseIf ValType ( xCampo ) $ "CM"
            	If !lNull
                    cExecuta += "'" + xCampo + "', "
                Else
                	cExecuta += Iif( !Empty(xCampo),("'" + xCampo + "', "), "NULL, " )
                EndIf
            ElseIf ValType ( xCampo ) == "N"
             	If !lNull
                    cExecuta += Str( xCampo ) + ", "
                Else
                	cExecuta += Iif( !Empty(xCampo),(Str( xCampo ) + ", "), "NULL, " )
                EndIf
            ElseIf ValType ( xCampo ) == "L"
                // Se foi passado NULL no quarto parametro nao faz o tratamento de NULL
                cColuna := Iif( xCampo, "-1", "0" )
                cExecuta += cColuna + ", "
            ElseIf ValType ( xCampo ) == "D"
                cTipoData := aArrayCampos[nCont,3]
                cData := DToS( xCampo )
				Do Case
                    Case cTipoData == "AAAAMMDD"
                        // cData := cData
                    Case cTipoData == "DDMMAAAA"
                        cData := SubStr( cData, 7, 2 ) + SubStr( cData, 5, 2) +  SubStr( cData, 1, 4 )
                    Case cTipoData == "AAMMDD"
                        cData := SubStr( cData, 3, 2 ) + SubStr( cData, 5, 2) +  SubStr( cData, 7, 2 )
                    Case cTipoData == "DDMMAA"
                        cData := SubStr( cData, 7, 2 ) + SubStr( cData, 5, 2) +  SubStr( cData, 3, 2 )
                    Case cTipoData == "AAAA/MM/DD"
                        cData := SubStr( cData, 1, 4 ) + "/" + SubStr( cData, 5, 2) + "/" + SubStr( cData, 7, 2 )
                    Case cTipoData == "DD/MM/AAAA"
                        cData := SubStr( cData, 7, 2 ) + "/" + SubStr( cData, 5, 2) + "/" + SubStr( cData, 1, 4 )
                    Case cTipoData == "AA/MM/DD"
                        cData := SubStr( cData, 3, 2 ) + "/" + SubStr( cData, 5, 2) + "/" + SubStr( cData, 7, 2 )
                    Case cTipoData == "DD/MM/AA"
                        cData := SubStr( cData, 7, 2 ) + "/" + SubStr( cData, 5, 2) + "/" + SubStr( cData, 3, 2 )
				EndCase
            	If !lNull
					cExecuta += "'" + cData + "', "
                Else
                	cExecuta += Iif( !Empty(xCampo),("'" + cData + "', "), "NULL, " )
                EndIf
			EndIf
		Next
        // Continuacao da montagem do Comando UPDATE
		cExecuta := SubStr( cExecuta, 1, Len(cExecuta)-2 )
		cExecuta += ' WHERE '
		For nCont := 1 To Len( aArrayChaves )
            // Codigo de Bloco a ser executado para o campo ou Formato da Data para o campo
            xExecute := aArrayChaves[nCont,3]
            // Coluna precisa de NULL (.T./.F.)
            lNull := Iif( aArrayChaves[nCont,4] == "NULL", .T., .F. )
            // Chave
            xChave := (cAliasWork)->( FieldGet(FieldPos(aArrayChaves[nCont,2])) )
            // Continuacao da montagem do Comando
			cExecuta += aArrayChaves[nCont,1]
            If ValType( xExecute ) == "B" // Se tem Codigo de Bloco, ja executa
            	If !lNull // Verifica se foi passado NULL no quarto parametro
                	cExecuta += " = " + Eval( xExecute, xChave ) + " AND "
                Else
                	cExecuta += Iif( !Empty( Eval( xExecute, xChave ) ),;
                	                 " = " + Eval( xExecute, xChave ) + " AND ",;
                	                         " IS NULL AND " )
                EndIf
            ElseIf ValType ( xChave ) $ "CM"
                If !lNull
                    cExecuta += " = '" + xChave + "' AND "
                Else
                	cExecuta += Iif( !Empty(xChave),(" = '" + xChave + "' AND "), " IS NULL AND " )
                EndIf
            ElseIf ValType ( xChave ) == "N"
            	If !lNull
                    cExecuta += " = " + Str(xChave) + " AND "
                Else
                    cExecuta += Iif( !Empty(xChave),(" = " + Str(xChave) + " AND "), " IS NULL AND " )
                EndIf
            ElseIf ValType ( xChave ) == "L"
                // Se foi passado NULL no quarto parametro nao faz o tratamento de NULL
                cColuna := Iif( xChave, "-1", "0" )
                cExecuta += " = " + cColuna + " AND "
            ElseIf ValType ( xChave ) == "D"
                cTipoData := aArrayChaves[nCont,3] // Neste caso, somente para documentacao
                cData := DToS( xChave )
	            // Para o Where o formato da data deve ser #MM/DD/AAAA# (MDB)
                cData := SubStr( cData, 5, 2 ) + "/" + SubStr( cData, 7, 2) + "/" + SubStr( cData, 1, 4 )
           	    If !lNull
                    cExecuta += " = #" + cData + "# AND "
                Else
                 	cExecuta += Iif( !Empty(xChave),(" = #" + cData + "# AND "), " IS NULL AND " )
                EndIf
 			EndIf
		Next
		cExecuta := SubStr( cExecuta, 1, Len(cExecuta)-5 )

	// Na WorkArea existe uma Alteracao e nao foi passado esta opcao na aEicdll
    ElseIf cTipoCpo == "A" .And. aEicdll[2,1] == " "
		lOk := .F.

	// Se for Exclusao
    ElseIf cTipoCpo == "E" .And. aEicdll[3,1] == "E"
		cTipo 		 := aEicdll[3,1]
        cTabela      := aEicdll[3,2]
		aArrayCampos := aEicdll[3,3]
		aArrayChaves := aEicdll[3,4]
        // Montagem do Comando DELETE
		cExecuta := 'DELETE FROM '+cTabela+' WHERE '
		For nCont := 1 To Len( aArrayChaves )
            // Codigo de Bloco a ser executado para o campo ou Formato da Data para o campo
            xExecute := aArrayChaves[nCont,3]
            // Coluna precisa de NULL (.T./.F.)
            lNull := Iif( aArrayChaves[nCont,4] == "NULL", .T., .F. )
            // Chave
            xChave := (cAliasWork)->( FieldGet(FieldPos(aArrayChaves[nCont,2])) )
            // Montagem do Comando
			cExecuta += aArrayChaves[nCont,1]
            If ValType( xExecute ) == "B" // Se tem Codigo de Bloco, ja executa
            	If !lNull // Verifica se foi passado NULL no quarto parametro
                	cExecuta += " = " + Eval( xExecute, xChave ) + " AND "
                Else
                	cExecuta += Iif( !Empty( Eval( xExecute, xChave ) ),;
                	                 " = " + Eval( xExecute, xChave ) + " AND ",;
                	                         " IS NULL AND " )
                EndIf
            ElseIf ValType ( xChave ) $ "CM"
                If !lNull
                    cExecuta += " = '" + xChave + "' AND "
                Else
                	cExecuta += Iif( !Empty(xChave),(" = '" + xChave + "' AND "), " IS NULL AND " )
                EndIf
            ElseIf ValType ( xChave ) == "N"
            	If !lNull
                    cExecuta += " = " + Str(xChave) + " AND "
                Else
                    cExecuta += Iif( !Empty(xChave),(" = " + Str(xChave) + " AND "), " IS NULL AND " )
                EndIf
            ElseIf ValType ( xChave ) == "L"
                // Se foi passado NULL no quarto parametro nao faz o tratamento de NULL
                cColuna := Iif( xChave, "-1", "0" )
                cExecuta += " = " + cColuna + " AND "
            ElseIf ValType ( xChave ) == "D"
                cTipoData := aArrayChaves[nCont,3] // Neste caso, somente para documentacao
                cData := DToS( xChave )
	            // Para o Where o formato da data deve ser  #MM/DD/AAAA# (MDB)
                cData := SubStr( cData, 5, 2 ) + "/" + SubStr( cData, 7, 2) + "/" + SubStr( cData, 1, 4 )
           	    If !lNull
                    cExecuta += " = #" + cData + "# AND "
                Else
                 	cExecuta += Iif( !Empty(xChave),("= #" + cData + "# AND "), " IS NULL AND " )
                EndIf
			EndIf
		Next
		cExecuta := SubStr( cExecuta, 1, Len(cExecuta)-5 )

	// Na WorkArea existe uma Exclusao e nao foi passado esta opcao na aEicdll
    ElseIf cTipoCpo == "E" .And. aEicdll[3,1] == " "
		lOk := .F.

	// Na WorkArea existe um registro que nao tem o tipo de operacao preenchido corretamente
    ElseIf !( cTipoCpo $ "IAE" )
		lOk := .F.

	EndIf

    // Se o Tipo de Operacao na WorkArea existe como opcao na Funcao (dentro do aEicdll)
	If lOK
		// Executar o Comando na Tabela
		cBuffer := cExecuta + Replicate( Chr(1), 512 - Len(cExecuta) )
		If ExeDllRun2( nHandle, EICDLL_EXECUTE, @cBuffer ) == EICDLL_ERROR

            // Tirar Chr(0) que vem da DLL (StrTran E AllTrim nao funcionam neste caso)
            cAuxBuffer:=""
            For nCont := 1 To Len(cBuffer)
                If SubStr(cBuffer,nCont,1) != Chr(0)
                    cAuxBuffer += SubStr(cBuffer,nCont,1)
                Else
                    Exit
                EndIf
            Next
            cBuffer:=cAuxBuffer

	 	    MsgStopLM( "99-"+cBuffer )
			// cWAErro = Nome do Campo na Work que contera o erro, se existir
			If !Empty( cWAErro )
                If ValType ( (cAliasWork)->(FieldGet(FieldPos(cWAErro))) ) $ "CM"
                    If (cAliasWork)->( RecLock( cAliasWork, .F.) )
                        (cAliasWork)->( FieldPut( FieldPos(cWAErro), ("99-"+cBuffer) ) )
                        (cAliasWork)->( MSUnlock() )
					Else
						MsgStopLM( "24-" + STR0216 +cWAErro+STR0207+cAliasWork+STR0217  ) //#STR0216->"Nao foi possivel fazer a gravacao deste erro no Campo : " ##STR0207->" do Alias : " ###STR0217->". Registro nao pode ser bloqueado para gravacao."
					EndIf
				EndIf
			EndIf
		    lOk := .F. // Deixa lOk falsa, pois este erro bloqueia o processamento
		    Exit
		EndIf
	Else
		// cWAErro = Nome do Campo na Work que contera o erro, se existir
		If !Empty( cWAErro )
            If ValType ( (cAliasWork)->(FieldGet(FieldPos(cWAErro))) ) $ "CM"
                If (cAliasWork)->( RecLock( cAliasWork, .F.) )
                    If cTipoCpo $ "IAE"
                        (cAliasWork)->( FieldPut( FieldPos(cWAErro), STR0218 ) )//#STR0218->"Tipo de Operacao na WorkArea nao passado como parametro na Funcao !"
                    Else
                        (cAliasWork)->( FieldPut( FieldPos(cWAErro), STR0219 ) ) //#STR0219->"Tipo de Operacao na WorkArea invalido !"
                    EndIf
                    (cAliasWork)->( MSUnlock() )
				Else
					MsgStopLM( "25-" + STR0216 +cWAErro+STR0207+cAliasWork+STR0217 ) //#STR0216->"Nao foi possivel fazer a gravacao deste erro no Campo : " ##STR0207->" do Alias : " ###STR0217->". Registro nao pode ser bloqueado para gravacao."
				EndIf
			EndIf
		EndIf
		lOk := .T. // Deixa lOk verdadeira, pois este erro nao bloqueia o processamento
   EndIf
   (cAliasWork)->( DbSkip() )
EndDo

If lOk // Se executou todos os comandos com sucesso, grava a Transacao
	lRet := .T. // Faz a funcao retornar verdadeiro
	cBuffer := ""
	If ExeDLLRun2( nHandle, EICDLL_COMMITTRANS, @cBuffer ) == EICDLL_ERROR
		MsgStopLM( "26-" + STR0220 ) //#STR0220->"Erro ao Gravar (COMMIT) os Dados !"
	EndIf
Else // Se nao executou todos os comandos com sucesso, desfaz a Transacao
	lRet := .F. // Faz a funcao retornar falso
    MsgStopLM( "27-" + STR0221  ) //#STR0221->"Desfazendo as alteracoes anteriores (ROLLBACK) !"
	cBuffer := ""
	If ExeDLLRun2( nHandle, EICDLL_ROLLBACKTRANS, @cBuffer ) == EICDLL_ERROR
		MsgStopLM( "28-" + STR0222 ) //#->"Erro ao Desfazer as alteracoes anteriores (ROLLBACK) !"
	EndIf
EndIf

// Fechar a Tabela/Conexao
cBuffer := ""
If ExeDLLRun2( nHandle, EICDLL_CLOSE_EXEC, @cBuffer ) == EICDLL_ERROR
	MsgStopLM( "29-" + STR0223 ) //#STR0223->"Erro ao fechar a Tabela e/ou a Conexao !"
EndIf

// Deixar NULL os SmartPointers
cBuffer := ""
ExeDLLRun2( nHandle, EICDLL_RELEASE_SMARTPOINTER, @cBuffer )

// Descarregar a DLL AveasyConnect.DLL
ExecInDLLClose(nHandle)

Return ( lRet )

*-------------------------------------------------------------------------------------------------------------------*
//Funcao.....: AvgNumSeq(cAlias,cCampo)
//Autor......: ALEX WALLAUER
//Data.......: 23, Junho de 2004
//Parametros.: cAlias := Alias do cCampo
//             cCampo := Campo onde vai ser lida a sequencia
//Objetivo...: Trazer o Proximo Numero da sequencia gravada no campo
//Retorno....: Proximo Numero
FUNCTION AvgNumSeq(cAlias,cCampo)
*-------------------------------------------------------------------------------------------------------------------*
LOCAL aSemSX3,cConteudo,nPosicao,nPos,nPosFilial
LOCAL lAchou    :=.F.
LOCAL cArquivo  :="AVG_SEQ"
LOCAL cAvg_Seq  :="Avg_Seq"
LOCAL nOldArea  :=SELECT()
LOCAL nRecAtual :=(cAlias)->(RECNO())
LOCAL cSequencia:=""
//GFP - 19/04/2012 - Tratamento para que geração da numeração automatica não seja duplicada quando tabela SE2 ou cAlias for compartilhado.
LOCAL cFilNumSeq := If(!Empty(xFilial(cAlias)) .AND. xFilial(cAlias) <> xFilial("SE2"), xFilial("SE2"), xFilial(cAlias))//RMD - 01/06/18 - Alterado o nome da variável, estava dando conflito com defines
//LOCAL cFilial := If(!Empty(xFilial(cAlias)) .AND. xFilial(cAlias) <> xFilial("SE2"), xFilial("SE2"), xFilial(cAlias))    //GFP - 19/04/2012
LOCAL cAvgFilial:=UPPER(PADR(/*xFilial(cAlias)*/cFilNumSeq+x2path(cAlias),50))    //GFP - 19/04/2012
Local oUserParams:= EASYUSERCFG():New("AVGSEQ", "AVGSEQ", Space(FWSizeFilial()))
Local aDataFonte :=  GetApoInfo("EECEI300.PRW")  //LRS - 17/07/2018

PRIVATE cAliasAux := cAlias //LGS-25/04/2015
PRIVATE cCampoAux := cCampo //LGS-25/04/2015
cCampo:=UPPER(cCampo)

If EasyEntryPoint("AVGERAL")    //LGS-25/04/2015
   ExecBlock("AVGERAL",.F.,.F.,"ALTERA_FILIAL")
EndIf

cSequencia := oUserParams:LoadParam(cCampo, "", cAvgFilial, .T.)

IF Empty(cSequencia)

   cConteudo :=""
   nPosicao  :=(cAlias)->(FIELDPOS(cCampo))
   If nPosicao = 0
      MSGSTOP(STR0146+cCampo+STR0226+cAlias)//#STR0146->"Campo: " ##STR0226->" nao existe no arquivo: "
      DbSelectArea(nOldArea)
      RETURN ""
   EndIf
   nPos      :=AT("_",cCampo)
   nPosFilial:=(cAlias)->(FIELDPOS(SUBSTR(cCampo,1,nPos)+"FILIAL"))
   If nPosFilial = 0
      MSGSTOP(STR0146+SUBSTR(cCampo,1,nPos)+"FILIAL " + STR0226+cAlias) //#STR0146->"Campo: "##STR0226->"nao existe no arquivo: "
      DbSelectArea(nOldArea)
      RETURN ""
   EndIf
   (cAlias)->(DBSEEK(/*xFilial()*/cFilNumSeq))    //GFP - 19/04/2012
   DO WHILE (cAlias)->(!EOF()) .AND. (cAlias)->(FIELDGET(nPosFilial)) == cFilNumSeq /*xFilial(cAlias)*/    //GFP - 19/04/2012

      IF !EMPTY( (cConteudo:=(cAlias)->(FIELDGET(nPosicao))) )
         IF cConteudo > cSequencia
            cSequencia:=cConteudo
         ENDIF
      ENDIF

      (cAlias)->(DBSKIP())
   ENDDO
   (cAlias)->(DBGOTO(nRecAtual))

   IF EMPTY(cSequencia)
      cSequencia:=STRZERO(1,LEN( (cAlias)->(FIELDGET(nPosicao)) ))
   ELSE
      cSequencia:=Soma1( cSequencia )
   ENDIF

ELSE
   nPosicao:= (cAlias)->(FIELDPOS(cCampo))                                    //TRP 08/05/2007 - Chamado 049354
   cSequencia:= LEFT(cSequencia,LEN((cAlias)->(FIELDGET(nPosicao)))) //TRP 08/05/2007 - Chamado 049354
   cSequencia:=Soma1(cSequencia)                                              //LDB 07/10/2006 - Chamado 038304
ENDIF

oUserParams:SetParam(cCampo, cSequencia, cAvgFilial)

DbSelectArea(nOldArea)

RETURN ALLTRIM(cSequencia)

/*
Função     : ConverteAvgSeq
Objetivo   : Converte o arquivo legado avg_seq para o controle de configurações no banco de dados (tabela EWQ)
Observações: Esta função será executada uma única vez por ambiente, transportando as informações do arquivo para a tabela EWQ e renomeando o arquivo para avg_seq.old
             A estrutura será convertida conforme a correspondência abaixo:
                De: AVG_CAMPO  Para: EWQ_PARAM
                De: AVG_SEQ    Para: EWQ_XCONT
                De: AVG_FILIAL Para: EWQ_USER

*//*
Static Function ConverteAvgSeq(cArquivo, cAvg_Seq, oUserParams)
Local lRet := .T.
Local cArea := Alias()

   USE (cArquivo) ALIAS (cAvg_Seq) SHARED NEW VIA "CTREECDX"
   If Select(cAvg_Seq) == 0
      MSGSTOP(STR0225+cArquivo)//#STR0225->"Nao foi possivel abrir o arquivo: "
      lRet := .F.
   Else
   
      (cAvg_Seq)->(DBGOTOP())
      DO WHILE (cAvg_Seq)->(!EOF())
         (cAvg_Seq)->(oUserParams:SetParam(AVG_CAMPO, AVG_SEQ, AVG_FILIAL))
         (cAvg_Seq)->(DBSKIP())
      ENDDO
      (cAvg_Seq)->(DbCloseArea())
      If FRename(cArquivo+GetDBExtension(), cArquivo+".old") == -1
         MsgStop(StrTran("Erro ao renomear o arquivo 'XXX'. Verique as permissões de acesso em disco.", "XXX", cArquivo+GetDbExtension()), "Aviso")
         lRet := .F.
      EndIf
   EndIf

If !Empty(cArea)
    DbSelectArea(cArea)
EndIf

Return lRet*/

*------------------------------------------------------------------------------------------------------*
Function AvgMBrowseFil(cTabela,cTitulo,aFilSel,Tb_Campos,cCampo,aDBF,bMarca,aRetFields,lPesquisa,bMarkAll,cWKRegs)   // GFP - 07/12/2012
*------------------------------------------------------------------------------------------------------*
#DEFINE MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#DEFINE FINAL_ENCHOICE MEIO_DIALOG-1
#DEFINE COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#DEFINE FINAL_SELECT   (oDlg:nClientHeight-6)/2

LOCAL WorkFile, aMarcados:={}, /*oDlg,*/ bAval, nI, aMontaCampos:={}
LOCAL aPesquisa:={}
PRIVATE cMarca , lInverte := .F., oDlg  // GFP - 07/12/2012
DEFAULT bMarkAll := {|| AvgAllMark()}
aSize(TB_Campos,len(TB_Campos)+2)
aSize(aDBF,len(aDBF)+2)

aIns(aDBF,1)
aIns(aDBF,2)
aIns(TB_Campos,1)
aIns(TB_Campos,2)

TB_Campos[1]:={"WKMARCA","",""}
TB_Campos[2]:={ {||WorkFil->WKFILIAL+'-'+AvgFilName({WorkFil->WKFILIAL})[1]},"",AVSX3("W2_FILIAL",5) }

aDBF[1]:={"WKMARCA","C",2,0}
aDBF[2]:={"WKFILIAL","C",AVSX3("W2_FILIAL",3),0}

WorkFile := E_CriaTrab(,aDBF,"WorkFil") //THTS - 28/09/2017 - TE-6431 - Temporario no Banco de Dados

cMarca := GetMark(,"WorkFil","WKMARCA")
AvZap()

//JAP - 22/08/06 - Indice necessário para pesquisa na função AvgMPesqFil.
IF lPesquisa
   IndRegua("WorkFil",WorkFile+TEOrdBagExt(),"WKFILIAL+"+cCampo)// ‚ obrigat¢ria a cria‡Æo de ¡ndice p/
   //SVG - 10/07/08 - Informa as filiais recebidas para a função de busca.
   aAdd(aPesquisa,{"PESQUISA" ,{|| AvgMPesqFil(cTitulo,cTabela, aFilSel) },STR0227})//#STR0227->"Pesquisar"
ELSE
   IndRegua("WorkFil",WorkFile+TEOrdBagExt(),"WKFILIAL")// ‚ obrigat¢ria a cria‡Æo de ¡ndice p/
EndIf

//If !Empty(bMarkAll)        // GFP - 27/02/2013
   aAdd(aPesquisa,{"LBTIK"    ,bMarkAll, "Marca/Desmarca Todos"})  // GFP - 27/02/2013
//EndIf

Processa({|lEnd|AvgGrvWorkFil(aFilSel,aDBF,cTabela,cCampo,cWKRegs)},"")    // GFP - 12/12/2012

While .T.
   oMainWnd:ReadClientCoords()

   nOpca:=0

 	DEFINE MSDIALOG oDlg TITLE cTITULO FROM 10,0 TO 38,90 OF oMainWnd

   dbSelectArea("WorkFil")
   dbGoTop()

   bAval:={||(WorkFil->WKMARCA:=IF(EMPTY(WorkFil->WKMARCA),cMarca,SPACE(02))),.T.}   // default

   if bMarca <> NIL   // passado a partir do ip150 - rs 11/01/06
      bAval:=bMarca
   endif

   oMark:=MsSelect():New("WorkFil","WKMARCA",,TB_Campos,@lInverte,@cMarca,{30,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-3)/2}) // GFP - 21/08/2015
   oMark:bAval := bAval
   oMark:oBrowse:Refresh()

   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nopca:=2,oDlg:End()},{||oDlg:End()},,aPesquisa)) CENTERED

   if nopca == 2
      WorkFil->(DBGOTOP())
      WHILE ! WorkFil->(EOF())

       IF ! EMPTY(WorkFil->WKMARCA)

          if aRetFields == NIL
             AADD(aMarcados,{WorkFil->WKFILIAL,WorkFil->(FIELDGET(FIELDPOS(cCampo)))})
             WorkFil->(DBSKIP()) ; LOOP
          endif

          aMontaCampos:=ACLONE(aRetFields)
          FOR nI:=1 to LEN(aRetFields)
              cCampo:=aRetFields[nI]
              aMontaCampos[nI]:=WorkFil->(FIELDGET(FIELDPOS(cCampo)))
          NEXT
          AADD(aMarcados,{WorkFil->WKFILIAL,aMontaCampos})
       ENDIF
       WorkFil->(DBSKIP())
      END
   endif
   Exit
Enddo
WorkFil->(E_EraseArq(WorkFile,WorkFile))
RETURN aMarcados

*---------------------------------------------------------*
Function AvgGrvWorkFil(aFilSel,aDBF,cTabela,cCampo,cWKRegs)   // GFP - 12/12/2012
*---------------------------------------------------------*
LOCAL cNomeCampo:=RIGHT(cTabela,2)+"_FILIAL", cFil, nI,n, xCampo,xConteudo
LOCAL cCampoOri, cSvFilAnt:=cFilAnt
if ! EMPTY(cTabela)
   ProcRegua((cTabela)->(EasyRecCount(cTabela)))
endif
For nI:=1 to LEN(aFilSel)
    cFil:=aFilSel[nI]
    cFilAnt:=cFil

    if empty(cTabela)    // a partir do ip150 - rs 11/01/06
       WorkFil->(DBAPPEND())
       WorkFil->WKFILIAL:=cFil
       LOOP
    endif

    (cTabela)->(dbseek(xFilial(cTabela)))
    WHILE ! (cTabela)->(EOF()) .AND. (cTabela)->(FIELDGET(FIELDPOS(cNomeCampo))) == cFil

       cCampoOri:= (cTabela)->(FIELDGET(FIELDPOS(cCampo)))
       IncProc(AVSX3("W2_FILIAL",5)+" "+cFil+" Item "+cCampoOri)
       WorkFil->(DBAPPEND())
       WorkFil->WKFILIAL:=cFil
       FOR n:=1 TO LEN(aDBF)
           IF aDBF[n,1] == "WKMARCA"  .OR. aDBF[n,1] == "WKFILIAL"
              LOOP
           ENDIF
           xcampo:=aDBF[n,1]
           xConteudo:=(cTabela)->(FIELDGET(FIELDPOS(xcampo)))
           WorkFil->(FIELDPUT(n,xConteudo))
       NEXT
       (cTabela)->(DBSKIP())
    END
Next
cFilAnt:=cSvFilAnt
RETURN .T.

//REVISÃO - ALCIR ALVES - 15-03-05 - PERMITIR FECHAR A JANELA DE MULTIFILIAL
//LRL 07/12/04-------------------------------------------------------------------------------------------------------
/*
Função    : AvgSelectFil
Autor     : Lucas Rolim Rosa Lopes
Data      : 06/12/2004
Descrição : Gera Array com as filiais selecionadas pelo usuario
Revisão   : 05/03/2010 - Revisão e adaptação para Gestão Corporativa - Protheus 11
*/
Function  AvgSelectFil(lPerg,cAliasC,cAliasE)
Local i, j
Local lOk := .F.
Local nRec := SM0->(RecNo())
// ** AAF 18/12/2007 - Tratamento para execução por agendamento
Local lSched := Type("lScheduled") == "L" .AND. lScheduled
// **

Default lPerg:= .T.

Private lPergRDM := lPerg //AAF 09/06/05 - Passa lPerg para Private, usado em RDMs.
Private aFiliais :={}, lPVez := .T.
Private aFil  := {}
Private cFiliais  :=""
Private cTodasFil :="" //AAF 09/06/05 - String com todas as filiais.
Private oDlg,oCmbFil,oBtnOK
PRIVATE aFilSelect:={}
Private lRet_AVG:=.F. //caso não seja clicado em Ok esta variavel será o retorno da função - Alcir Alves - 15-03-05 - adaptação para fechamento da janela retorna nulo quando fechado a janela
Private cFil := cFilDe := cFilAte :=  Space(FWSizeFilial()) //NCF - 05/03/2010 - Adaptação - P11
Private aSM0,aGrupo := {}

If Valtype(cAliasC) == "C"              //NCF-19/03/2010
  If FWModeAccess(cAliasC,3) == "C"
     AADD(aFilSelect,xFilial(cAliasC))
     Return aFilSelect
  EndIf
EndIf
If Valtype(cAliasE) == "C"              //NCF-19/03/2010
  If FWModeAccess(cAliasE,3) == "C"
     AADD(aFilSelect,cFilAnt)
     Return aFilSelect
  EndIf
EndIf

// ** AAF 18/12/2007 - Tratamento para execução por agendamento
If lSched .AND. !lPerg
   nRec := SM0->(RecNo())
   SM0->(DbGoTop())
   While SM0->(!EOF())
      If SM0->M0_CODIGO == cEmpAnt .AND. !aScan(aFilSelect,AvGetM0Fil()) > 0
         aAdd(aFilSelect,AvGetM0Fil())
      EndIf
      SM0->(DbSkip())
   EndDo
   SM0->(dbGoTo(nRec))
EndIf
// **
aGrupo := FWAllGrpCompany()
aSM0   := FWLoadSM0()

If !lSched .AND. VerSenha(115)      //NCF-05/03/2010
   For i := 1 To Len(aGrupo)
      If aGrupo[i] == cEmpAnt
         For j := 1 To Len(aSM0)
            If aSM0[j][1] == aGrupo[i]
               AADD( aFiliais,IF(Empty(aSM0[j][3]),"",aSM0[j][3]) + IF(Empty(aSM0[j][4]),"",aSM0[j][4]) + IF(Empty(aSM0[j][5]),"",aSM0[j][5]) )
            EndIf
         Next j
      EndIf
   Next i
   If EasyEntryPoint("AVGERAL")
      ExecBlock("AVGERAL",.F.,.F.,"AVGSELECTFIL_AJUSTA_FILIAIS")
   EndIf
   If !lPerg
      aSort(aFilSelect)
      aFilSelect:=aFiliais
   Else
      aSort(aFilSelect)
      aFilSelect:=aFiliais
      For i:=1 to len(aFilSelect)
         cFiliais += aFilSelect[i] + "\ "
         cTodasFil+= aFilSelect[i] + "\ " //AAF 09/06/05
      Next
/*
      SM0->(DbGoTop())
      aAdd(aFil,"Todas")
      While SM0->(!EOF())
         If SM0->M0_CODIGO == cEmpAnt .AND. aScan(aFiliais,AvGetM0Fil()) > 0
            aAdd(aFil,AvGetM0Fil() +" - " + SM0->M0_FILIAL)
         EndIf
         SM0->(DbSkip())
      EndDo
*/
      aAdd(aFil,"Todas")
      For i := 1 To Len(aSM0)
         If aSM0[i][1] == cEmpAnt .And. aScan(aFiliais,aSM0[i][2]) > 0
            aAdd(aFil,aSM0[i][2] +" - " + aSM0[i][7])
         EndIf
      Next i

      // ** AAF 09/06/05 - Ponto de Entrada antes da tela com os gets.
      If EasyEntryPoint("AVGERAL")
         ExecBlock("AVGERAL",.F.,.F.,"AVGSELECTFIL_ANTES_GETS")
      EndIf
      // **

      SM0->(DbGoTo(nRec))
      nDlgAlt := 540
      DEFINE MSDIALOG oDlg TITLE STR0132 FROM 10,10 TO nDlgAlt,290 OF oMainWnd  PIXEL //"Seleção de Filiais"

         oPnl:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 1, 1)
         oPnl:Align:= CONTROL_ALIGN_ALLCLIENT            

         @ 02, 006 To 056,135 of oPnl Pixel
         @ 08, 010 Say STR0133  of oPnl Pixel   //"Filiais"
         @ 20, 010 Say STR0134  of oPnl Pixel  //"De :"
         @ 18, 031 MsGet cFilDe VALID ValidFil (2) Of oPnl Pixel Size 20,6
         @ 20, 075 Say STR0135  of oPnl Pixel //"Ate :"
         @ 18, 095 MsGet cFilAte VALID ValidFil (2) Of oPnl Pixel Size 20,6
         @ 35, 010 Say STR0136  of oPnl Pixel //"Filial :"
         @ 34, 030 ComboBox oCmbFil Var cFil Items aFil  Of oPnl Pixel Size 85,6
         @ 34, 118 BUTTON "OK" SIZE 10,10 ACTION   ValidFil (1) Of oPnl Pixel
         @ 62, 006 To 210,135 of oPnl Pixel
         @ 68, 048 Say STR0137 Of oPnl Pixel  //"Filiais Selecionadas"
         // MFR 09/06/2020 OSSME-4872
        //@ 78, 012 Get cFiliais Of oPnl Pixel Size 116,6  When .F.
         @ 78,012 Get oMemo Var cFiliais MEMO HSCROLL Size 115,100 READONLY Of oPnl  Pixel
         @ 194, 012 BUTTON STR0228 SIZE 116,10 ACTION Eval({|| cFiliais:="", aFilSelect:={} }) Of oPnl Pixel //#STR0228->"Limpar"
         oMemo:lWordWrap := .t.
         oMemo:EnableVScroll(.t.)
         oMemo:EnableHScroll(.t.) 


      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, { || if (!Empty(aFilSelect),;
                                                                  Eval({|| lOK := .T.,lRet_AVG:=.T., oDlg:End()}),;
                                                                  MsgInfo(STR0138))  },;
                                                         { || lRet_AVG:=.F.,oDlg:End() },,,,,,,.F.) CENTERED
      //Alcir Alves - 15-03-05 - adaptação para fechamento da janela - retorna "False" quando fechado a janela
      if lRet_AVG==.F.
         aFilSelect:={}
         aadd(aFilSelect,"WND_CLOSE")
      endif
      //
   EndIf
ElseIf !lSched
   AADD(aFilSelect,cFilAnt)
EndIf
Return aFilSelect

/*
Função    : ValidFil
Autor     : Lucas Rolim Rosa Lopes
Data      : 06/12/2004
Descrição : Usado pela função AvgSetFIlter
*/

Function ValidFil (nTipo)
Local i
Local nTamFil := FWSizeFilial()
cFiliais:=""
If nTipo == 1
   If lPVez
      aFilSelect:={}
      lPVez := .F.
   EndIf

   If Alltrim(cFil) = "Todas"
      aFilSelect:= {}
      For i:=1 to Len(aFiliais)
          If Val(aFiliais[i]) > 0
             AAdd(aFilSelect,Left(aFiliais[i],nTamFil))
          EndIf
      Next
   Else
      If aScan(aFilSelect,Left(cFil,nTamFil)) == 0
         AAdd(aFilSelect,Left(cFil,nTamFil))
      EndIf
   EndIf

Else
  If  !Empty(cFilDe) .And.  !Empty(cFilAte)
        For i:= Val(cFilDe) to Val(cFilAte)
           If aScan(aFiliais,StrZero(i,nTamFil)) > 0 .And.  aScan(aFilSelect,StrZero(i,nTamFil)) == 0
             AAdd(aFilSelect,StrZero(i,nTamFil))
           EndIf
        Next
  EndIf
EndIF

If EasyEntryPoint("AVGERAL")
   ExecBlock("AVGERAL",.F.,.F.,"ValidFil_AJUSTA_FILIAIS")
EndIf

aSort(aFilSelect)
For i:=1 to len(aFilSelect)
  cFiliais+= aFilSelect[i] + "\ "
Next

Return .t.
//-------------------------------------------------------------------------------------------------------LRL 07/12/04

/*
Função    : AvgFilName(aFiliais)
Autor     : Alessandro Alves Ferreira
Data      : 18/12/2004 15:30
Descrição : Retorna o Nome das filiais recebidas no parametro aFiliais.
Revisão   : set/2016 - ajuste do tamanho da filial (p12)
*/
Function AvgFilName(aFiliais,lCod)
Local nOldPos := SM0->( RecNo() )
Local aRet    := Array(Len(aFiliais))
Local cFilPos
Default lCod  := .F.
aFill(aRet,"")

//Percorre o SM0 pelas filiais do array aFiliais da Empresa atualmente logada.
SM0->( dbGoTop() )
Do While !SM0->( EoF() )
   If SM0->M0_CODIGO == cEmpAnt
      cFilPos:= AvGetM0Fil()

      If Len(cFilPos) <> FwSizeFilial()
         cFilPos:= Left(cFilPos, FwSizeFilial())
      EndIf

      nPos:= aScan(aFiliais, cFilPos)
      If nPos > 0
         aRet[nPos] := IF(lCod,AvGetM0Fil() + " - " ,"") + SM0->M0_FILIAL
      Endif
   Endif
   SM0->( dbSkip() )
EndDo

SM0->( dbGoTo(nOldPos) )
Return aRet

/*
Função    : AvgExistCpo()
Autor     : Alessandro Alves Ferreira
Data      : 06/01/2005 12:00
Descrição : Validação de uma chave em uma tabela, verificando em todas as filiais do parametro aFiliais.
*/
Function AvgExistCpo(cAlias,cChave,nOrdem,aFiliais,lGoTo)
Local nFil, lRet := .F.

If ValType(cAlias) <> "C" .OR. ValType(cChave) <> "C"
   MsgStop(STR0139)//"Erro no Uso da Função AvgExistCpo."
   RETURN
Endif

//Define ordem padrão e as filiais visiveis
Default nOrdem   := 1
Default aFiliais := AvgSelectFil(.F.,cAlias)
Default lGoTo    := .T.

nOldInd := (cAlias)->( IndexOrd() )
nOldReg := (cAlias)->( RecNo() )

(cAlias)->( dbSetOrder(nOrdem) )

//Pesquisa em todas as filiais
For nFil := 1 To Len(aFiliais)
   lRet  := (cAlias)->( dbSeek(aFiliais[nFil]+cChave) )
   If lRet
      Exit
   Endif
Next

//Retorna o Indice e o Registro
(cAlias)->( dbSetOrder(nOldInd) )

If lGoTo
   (cAlias)->( dbGoTo(nOldReg) )
EndIf

If !lRet
   Help("",1,"REGNOIS")
Endif

Return lRet
/*
Função    : AvgExistChave()
Autor     : Lucas Rolim Rosa Lopes
Revisão   : Alessandro Alves Ferreira - 25/02/05 - Validação deve ser feita em todas as filiais do sistema e não apenas,
                                                   nas filiais que o usuário possui acesso.
Data      : 26/01/2005 10:00
Descrição : Validação de uma chave em uma tabela, verificando em todas as filiais do sistema.
          : Retorno .F. caso ja exista o campo
*/
Function AvgExistChav(cAlias,cChave,nOrdem)
Local nFil, lRet := .T., aFiliais:= {}
Local cFilGrv := ""

If ValType(cAlias) <> "C" .OR. ValType(cChave) <> "C"
   MsgStop("Erro no Uso da Função AvgExistChave.")
   RETURN
Endif

//Define ordem padrão
Default nOrdem   := 1

// ** AAF 25/02/05 - Carrega todas as filiais
nRec:= SM0->( RecNo() )
SM0->( dbGoTop() )
Do While !SM0->( EoF() )
  If SM0->M0_CODIGO == cEmpAnt
     aAdd(aFiliais,AvGetM0Fil())
  EndIf
  SM0->(DbSkip())
EndDo
SM0->( dbGoTo(nRec) )
// **

nOldInd := (cAlias)->( IndexOrd() )
nOldReg := (cAlias)->( RecNo() )

(cAlias)->( dbSetOrder(nOrdem) )

//Pesquisa em todas as filiais
For nFil := 1 To Len(aFiliais)
   lRet  := !(cAlias)->( dbSeek(aFiliais[nFil]+cChave) )
   If !lRet
      cFilGrv := AvgFilName({aFiliais[nFil]},.T.)[1]
      Exit
   Endif
Next

//Retorna o Indice e o Registro
(cAlias)->( dbSetOrder(nOldInd) )
(cAlias)->( dbGoTo(nOldReg) )

If !lRet
   MsgStop(STR0140+cFilGrv)//"Já existe registro com essa informação gravado na filial "
Endif

Return lRet


/*
Funcao          : PosDlg(oDlg)
Parametros      : oDlg := Objeto da Dialog
Retorno         : Array com Coordenadas para Posicionamento de Objetos
Objetivos       : Posicionar Objeto em Toda a Dialog
Autor           : Cristiano A. Ferreira
Data/Hora       :
Revisao         :
Obs.            :
*/
Function PosDlg(oDlg)
Local aPos := {15,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2}
Local lP12 := Left(AllTrim(GetVersao(.F.)),2) == "12"

   If !lP12 .AND. SetMdiChild()//Caso o sistema esteja na versão MDI
      aPos[3] -= 6
   ElseIf lP12
      aPos[1] += 16
      aPos[3] -= 16
   EndIf

Return aPos

/*
Funcao          : PosDlgUp(oDlg)
Parametros      : oDlg := Objeto da Dialog
Retorno         : Array com Coordenadas para Posicionamento de Objetos
Objetivos       : Posicionar Objeto na Parte de Cima da Dialog
Autor           : Cristiano A. Ferreira
Data/Hora       :
Revisao         :
Obs.            :
*/
Function PosDlgUp(oDlg)
Local aPos:= {15,1,(oDlg:nClientHeight-6)/4-1,(oDlg:nClientWidth-4)/2}
Local lP12:= Left(AllTrim(GetVersao(.F.)),2) == "12"

   If !lP12 .AND. SetMdiChild()//Caso o sistema esteja na versão MDI
      aPos[1] -= 3
      aPos[2] -= 1
      aPos[4] += 3
   ElseIf lP12
      aPos[1] += 16
      aPos[3] += 8
   EndIf

Return aPos

/*
Funcao          : PosDlgUp(oDlg)
Parametros      : oDlg := Objeto da Dialog
Retorno         : Array com Coordenadas para Posicionamento de Objetos
Objetivos       : Posicionar Objeto na Parte de Cima da Dialog
Autor           : Cristiano A. Ferreira
Data/Hora       :
Revisao         :
Obs.            :
*/
Function PosDlgDown(oDlg)
Local aPos:= {(oDlg:nClientHeight-6)/4+1,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2}
Local lP12:= Left(AllTrim(GetVersao(.F.)),2) == "12"

   If !lP12 .AND. SetMdiChild()//Caso o sistema esteja na versão MDI
      aPos[1] -= 4
      aPos[2] -= 2
      aPos[3] -= 6
      aPos[4] += 3
   ElseIf lP12
      aPos[1] += 8
      aPos[3] -= 8
   EndIf

Return aPos
/*
Funcao          : AVG_CORD(nTam)
Parametros      : nTam := Tamanho do Objeto
Retorno         : Tamanho calculado conforme a resolução de tela ou tema utilizado
Objetivos       : Corrigir problemas com o reflesh da MsGetDB e com a resolução da tela e com o tema FLAT
Autor           : Alexandre Soares Reis
Data/Hora       : 14/12/2005
Revisao         :
Obs.            :
*/
*--------------------------------------------------------------*
Function AVG_CORD(nTam)
*--------------------------------------------------------------*
Local nHRes	:= oMainWnd:nClientWidth	//Resolucao horizontal do monitor
Do Case
	Case nHRes == 640	//Resolucao 640x480
		nTam *= 0.8
	Case nHRes == 800	//Resolucao 800x600
		nTam *= 1
	OtherWise			//Resolucao 1024x768 e acima
		nTam *= 1.28
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para tema "Flat"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If "MP8" $ oApp:cVersion
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf
Return Int(nTam)

/*
Funcao          : AVG_TELA()
Parametros      : -
Retorno         : Array com as posições calculada para o objeto
Objetivos       : Corrigir problemas com o reflesh da MsGetDB e com a resolução da tela e com o tema FLAT
Autor           : Alexandre Soares Reis
Data/Hora       : 14/12/2005
Revisao         :
Obs.            :
*/
*--------------------------------------------------------------*
Function AVG_TELA()
*--------------------------------------------------------------*
Private aSize := MsAdvSize()
Private aObjects := {}
AADD(aObjects, {100, 100, .T., .T.})
Private aInfo := {aSize[1], aSize[2], aSize[3], aSize[4], 3, 3}
Private aPosObj := MsObjSize(aInfo, aObjects, .T.)
Return aPosObj

/*
Funcao          : AvgMPesqFil()
Parametros      : cTitulo,cTabela
Retorno         : -
Objetivos       : Pesquisa de acordo com a tabela e parâmetro(lPesquisa = .T.) definidos na função AvgMBrowseFil.
Autor           : José Augusto Pereira Alves
Data/Hora       : 22/08/2006 - 14:00
Revisao         :
Obs.            :
*/
*--------------------------------------------------*
Function AvgMPesqFil(cTitulo,cTabela, aFiliais)
*--------------------------------------------------*
Local nInc

   DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 To 18,45 OF oMainWnd

        @ nLinSay,nColSay SAY cTitulo SIZE 50,08

        @ nLinGet,nColGet MSGET TCOD F3 cTabela PICTURE "@!" SIZE 60,10

   ACTIVATE MSDIALOG oDlg ON INIT ;
              EnchoiceBar(oDlg,{||If(!Empty(TCOD),;
                                (nOpca:=1,oDlg:End()),)},;
                               {||nOpca:=0,oDlg:End()}) CENTERED

   If nOpca == 1
      //SVG - 10/07/08 - Caso as filiais forem informadas em aFiliais, faz a busca em todas as filiais contidas no array
      If ValType(aFiliais) <> "A"
      DBSELECTAREA("WorkFil")
      WorkFil->(DBSETORDER())
      IF !WorkFil->(DBSEEK(xFilial()+TCOD))
         MsgInfo(cTitulo+STR0111,STR0122)
         WorkFil->(DbGoTop())
      EndIf
      Else
         For nInc := 1 To Len(aFiliais)
            If WorkFil->(DBSEEK(aFiliais[nInc]+TCOD))
               Exit
            Else
               If nInc == Len(aFiliais)
                  MsgInfo(cTitulo+STR0111,STR0122)
                  WorkFil->(DbGoTop())
               EndIf
            EndIf
         Next
      EndIf
   EndIf

RETURN .T.

/*
Funcao          : ExcHeader
Parametros      : aYesHeader, cAlias
Retorno         : aNoHeader
Objetivos       : Monta array com campos que não devem ser exibidos no Header, para uso na função FillGetDb.
Autor           : Rodrigo Mendes Diaz
Data/Hora       : 15/02/07 - 09:00
Revisao         :
Obs.            : Na função FillGetDb atualmente não existe um parâmetro para informar quais campos serão exibidos no header, existe somente
                  um parâmetro para informar quais campos NÃO aparecerão no header, portanto esta função monta um array com todos os campos
                  cadastrados para a tabela especificada, exceto os campos informados no parâmetro aYesHeader.
*/
*-------------------------------------*
Function ExcHeader(aYesHeader, cAlias)
*-------------------------------------*
Local aNoHeader := {}
Default aYesHeader := {}
Default cAlias := ""

Begin Sequence
   If Len(aYesHeader) == 0
      Break
   EndIf

   SX3->(DbSetOrder(1))
   If SX3->(DbSeek(cAlias))
      While SX3->(!Eof() .And. X3_ARQUIVO == cAlias)
         If aScan(aYesHeader, AllTrim(SX3->X3_CAMPO)) == 0
            aAdd(aNoHeader, AllTrim(SX3->X3_CAMPO))
         EndIf
         SX3->(DbSkip())
      EndDo
   EndIf

End Sequence
Return aNoHeader

/*
Funcao          : AvTrabName
Parametros      : cAlias    - Alias do arquivo de trabalho
                  lFullPath - Indica se será retornado o caminho completo do arquivo, o nome e a extensão do mesmo.
                  Caso contrário, retorna somente o nome, sem a extensão e o caminho.
Retorno         : cName  - Nome do arquivo de trabalho
Objetivos       : Retorna o nome do arquivo de trabalho a partir do alias.
Autor           : Rodrigo Mendes Diaz
Data/Hora       : 15/02/07 - 09:00
Revisao         :
Obs.            :
*/
*------------------------------------*
Function AvTrabName(cAlias, lFullPath)
*------------------------------------*
Local cName := StrTran(TETempName(cAlias), ".", "")
Default cAlias := ""
Default lFullPath := .F.

If Select(cAlias) > 0 .AND. Empty(cName)
   cName := (cAlias)->(DbInfo(10))//Retorna o FullPath do arquivo
   If !Empty((cAlias)->(DbInfo(9))) //Retorna a extensao - Se não for vazio, o temporario nao foi criado no banco de dados
	   If !lFullPath
	      cName := Left(cName, Len(cName)-4)//Retira a extens? (.dbf)
         While (nPos := At("\", cName)) > 0 .Or. (nPos := At("/", cName)) > 0
            cName := Right(cName, Len(cName) - nPos)
         EndDo
      EndIf
	Else//Temporario criado no banco de dados
      cName := StrTran( cName, "_")
      cName := StrTran( cName, "#")
	EndIf
EndIf

Return cName

/*
Funcao          : OrdHeader
Parametros      : aHeader - Array a ser alterado de acordo com o aCampos
                            (este parametro deve ser passado por referencia, ex.: @aHeader)
                  aCampos - Array contendo os campos na ordem correta do aHeader
                  aCols   - Array a ser alterado de acordo com as alterações do aHeader, para uso em GetDados
                            (este parametro deve ser passado por referencia, ex.: @aCols)
Retorno         : NIL
Objetivos       : Altera o aHeader de maneira que os campos estejam na ordem do aCampos
Autor           : PLB - Pedro Luiz Baroni
Data/Hora       : 26/02/2007
Revisao         :
Obs.            :
*/
*------------------------------------------*
Function OrdHeader(aHeader, aCampos, aCols)
*------------------------------------------*

 Local aHeaderAux := {}  ,;
       aColsAux   := {}  ,;
       nPos       := 0   ,;
       ni         := 1   ,;
       lCols      := ValType(aCols) == "A"

   aHeaderAux := AClone(aHeader)
   aHeader    := {}
   nPos++
   aEval(aHeaderAux, {|x| x := {x, nPos}, nPos++ })
   If lCols
      aColsAux   := AClone(aCols)
      aCols      := {}
   EndIf

   For ni := 1  to  Len(aCampos)
      nPos := AScan( aHeaderAux, {|x| AllTrim(x[1][2]) == AllTrim(aCampos[ni]) }  )
      If nPos > 0
         AAdd( aHeader, aHeaderAux[nPos][1] )
         If ValType(aCols) == "A"
            AAdd( aCols,   aColsAux[nPos])
         EndIf
         aDel(aHeaderAux, nPos)
         aSize(aHeaderAux, Len(aHeaderAux) - 1)
      EndIf
   Next ni

   // Adiciona no fim do aHeader os campos não existentes no aCampos mas que já existiam no aHeader
   For ni := 1  to  Len(aHeaderAux)
      AAdd( aHeader, aHeaderAux[ni][1] )
      If lCols
         AAdd( aCols,   aHeaderAux[ni][2])
      EndIf
   Next ni


Return

/*
Funcao          : AvSetFocus
Parametros      : cField  - Nome do campo cujo Get deve receber o foco
                  oDialog - Objeto da caixa de diálogo onde encontra-se o campo cField
Retorno         : NIL
Objetivos       : Mover o foco para o get ou combo de um campo em uma Enchoice
Autor           : Pedro Baroni
Data/Hora       : 15/03/2007
Revisao         :
Obs.            :
*/
*--------------------------------------------------*
Function AvSetFocus(cField,oDialog)
*--------------------------------------------------*

 Local nPosField  := 0    ,;
       nPosFolder := 0    ,;
       nInd       := 1    ,;
       cOrdFolder := ""   ,;
       cDesFolder := ""   ,;
       cFolderAux := ""   ,;
       oFolder    := NIL  ,;
       lIsCombo   := .F.  ,;
       nPosApronts:= 0//FSY - 22/07/2013

   cOrdFolder := Right(aGets[aScan(aGets, {|x| IncSpace(cField, 10, .F.) $ x })],1)
   SX3->( DBSetOrder(2) )
   If SX3->( DBSeek(IncSpace(cField, 10, .F.)) )
      SXA->( DBSetOrder(1) )
      If SXA->( DBSeek(SX3->X3_ARQUIVO) )
         If SXA->( DBSeek(SX3->X3_ARQUIVO+cOrdFolder) )
            cDesFolder := AllTrim(SXA->XA_DESCRIC)
         Else
            cDesFolder := STR0141  // "Outros"
         EndIf
         If !Empty(cDesFolder)
            For nInd := 1  to  Len(cDesFolder)
               cFolderAux += SubStr(cDesFolder,1,nInd-1)+"&"+SubStr(cDesFolder,nInd)+"___"
            Next nInd
            //** FSY - 22/07/2013 - Adicionado aScan para procurar a posição do TFOLDER atibuindo corretamente a posição do aPromtps.
            nPosApronts := AScan( oDialog:aControls, {|x| GETCLASSNAME(x) == "TFOLDER" })
            oFolder := oDialog:aControls[nPosApronts]//oFolder := oDialog:aControls[1]//Antigo código
            //**
            nPosFolder := AScan( oFolder:aPrompts, { |x| x $ cFolderAux } )
            If nPosFolder > 0
               oFolder:SetOption(nPosFolder)
               oFolder:Refresh()
            EndIf
         EndIf
      EndIf

      lIsCombo := !Empty(SX3->X3_CBOX)

      cField := "M->"+cField
      nPosField := AScan( oDialog:aControls, { |x| x:cReadVar == cField } )
      If nPosField > 0
         If lIsCombo
            oDialog:aControls[nPosField]:SetFocus()
         Else
            oDialog:aControls[nPosField]:oGet:SetFocus()
         EndIf
      EndIf

   EndIf

Return


/*
Funcao          : AvTabela
Parametros      : cTable - Codigo da Tabela
                  cKey   - Chave para a Tabela
Retorno         : Funcao Tabela() do fonte MATXFUNA.PRX
Objetivos       : Devolver o conteudo da tabela de acordo com a chave garantindo que uma Tabela esteja em uso
Autor           : Pedro Baroni
Data/Hora       : 02/04/2007
Revisao         :
Obs.            :
*/
*--------------------------------------------------*
Function AvTabela(cTable,cKey)
*--------------------------------------------------*

 Local xAlias

   xAlias := Alias()

   If Empty(xAlias)
      DBSelectArea("SX5")
   EndIf

Return Tabela(cTable,cKey)

/*
Funcao          : AvMnuFnc()
Parametros      : Nenhum
Retorno         : Nome da função para qual o menu funcional está sendo montado
Objetivos       : Identificar o nome da função para qual o menu funcional está sendo montado, quando utilizada na execução da função MenuDef()
Autor           : Rodrigo Mendes Diaz
Data/Hora       : 05/04/2007
Revisao         :
Obs.            :
*/
*------------------*
Function AvMnuFnc()
*------------------*
//Local cFunction := GetStaticCallProgram()
//Return if(Type("cAvStaticCall")=="C",cAvStaticCall,GetStaticCallProgram())
//Return if(funname()=="CFGA530",AllTrim(M->RL__ROTINA),if(Type("cAvStaticCall")=="C",cAvStaticCall,GetStaticCallProgram()))
Local cRetFunction:= ""
Local lcfg:= funname() == "CFGA530"

if lcfg
   cRetFunction:= AllTrim(M->RL__ROTINA)
endif

if !lcfg .or. empty(cRetFunction)
   if Type("cAvStaticCall")=="C"
      cRetFunction:= cAvStaticCall
   else
      cRetFunction:= GetStaticCallProgram()
   endif
endif

Return cRetFunction




/*
Funcao          : MenuDef()
Parametros      : Nenhum
Objetivos       : Inserir a funcionalidade do Menu Funcional para as rotinas que utilizam AxCadastro
Autor           : Adriane Sayuri Kamiya
Data/Hora       : 17/04/2007
Revisao         :
Obs.            :
*/
*------------------------*
 Static Function MenuDef()
*------------------------*
Local cStaticCall := 'StaticCall(MATXATU,MENUDEF)'
Return &cStaticCall


/*
Funcao          : AvZap(cAlias)
Parametros      : cAlias := Alias da Tabela em que se deseja efetuar os procedimentos
Retorno         : lZap := Retorna se os procedimentos foram executados com sucesso
Objetivos       : Efetuar um comando DBZap() em uma tabela.
Autor           : Pedro Baroni
Data/Hora       : 20/08/2007
Revisao         :
Obs.            : Função criada devido ao comando DBZAP() não poder ser executado
                  quando os indíces temporários de uma Work estiverem em uso
*/

Function AvZap(cAlias)

 Local lZap    := .F.  ,;
       nOldOrd := 0
Local cTempName
//MFR OSSME-2268 28/02/2019
 Default cAlias := alias()

    If !Empty(cAlias)
        If !Empty(cTempName := TETempName(cAlias))
            nOldOrd := (cAlias)->( IndexOrd() )
            (cAlias)->( DBSetOrder(0) )
            (cAlias)->( DbClearFilter())
            TcSqlExec("UPDATE " + cTempName + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ ") 
            (cAlias)->( DBSetOrder(nOldOrd) )
            lZap := .T.
        Else
            nOldOrd := (cAlias)->( IndexOrd() )
            (cAlias)->( DBSetOrder(0) )
            (cAlias)->( DbClearFilter())            
            (cAlias)->( __DBZap() )
            (cAlias)->( DBSetOrder(nOldOrd) )
            lZap := .T.
      EndIf
      (cAlias)->(dbGoTop())
      (cAlias)->(dbSkip())
   EndIf

Return lZap

/*
Função          : AvTrocaChar
Parâmetros      : cCampo -> String que deve conter os caracteres a serem alterados.
Retorno         : Retornar a string sem os caracteres especiais.
Objetivos       : Retirar caracteres especiais do texto e incluir no lugar caracteres sem acento.
Autor           : Luciano Campos de Santana
Data/Hora       : 11/10/2007
Revisao         : Thiago Rinaldi Pinto
Data/Hora       : 15/10/2007 às 16:45
Obs.            :
*/

Function AvTrocaChar(cCampo)

cCampo  := ConverteXML(cCampo)

Return cCampo
/*
/*
Funcao          : AVCanTrans()
Parametros      : cUnid1 -> Unidade DE
                  cUnid2 -> Unidade PARA
                  cProd  -> Produto
Retorno         : lCan -> Retorna o Objetivo
Objetivos       : Verificar se é possível efetuar a conversão entre as Unidades de medida DE e PARA
Autor           : PLB - Pedro Baroni
Data            : 18/07/2007
*/
*------------------------------------------------------*
Function AvCanTrans(cUnid1,cUnid2,cProd)
*------------------------------------------------------*

 Local cKey     := ""   ,;
       cKeyInv  := ""   ,;
       cOldArea := ""   ,;
       lCan     := .F.

 Default cProd := ""

   cOldArea := Select()

   Begin Sequence

      If Alltrim(cUnid1) <> Alltrim(cUnid2)
         DBSelectArea("SJ5")
         SJ5->( DBSetOrder(1) )
         If !Empty(cProd)
            cKey    := xFilial("SJ5")+AVKey(cUnid1,"J5_DE")+AVKey(cUnid2,"J5_PARA")
            cKeyInv := xFilial("SJ5")+AVKey(cUnid2,"J5_DE")+AVKey(cUnid1,"J5_PARA")
            If SJ5->( FieldPos("J5_COD_I") ) > 0
               cKey    += AVKey(cProd,"J5_COD_I")
               cKeyInv += AVKey(cProd,"J5_COD_I")
               If SJ5->( DBSeek(cKey) )
                  lCan := .T.
                  Break
               ElseIf SJ5->( DBSeek(cKeyInv) )
                  lCan := .T.
                  Break
               EndIf
            EndIf
         EndIf
         If SJ5->( DBSeek(xFilial("SJ5")+AVKey(cUnid1,"J5_DE")+AVKey(cUnid2,"J5_PARA")) )
            If SJ5->( FieldPos("J5_COD_I") ) <= 0  .Or.  Empty(SJ5->J5_COD_I)
               lCan := .T.
               Break
            EndIf
         ElseIf SJ5->( DBSeek(xFilial("SJ5")+AVKey(cUnid2,"J5_DE")+AVKey(cUnid1,"J5_PARA")) )
            If SJ5->( FieldPos("J5_COD_I") ) <= 0  .Or.  Empty(SJ5->J5_COD_I)
               lCan := .T.
               Break
            EndIf
         EndIf
         DBSelectArea(cOldArea)
      Else
         lCan := .T.
      EndIf

   End Sequence


Return lCan

/*
Função..: AvTotReg
Autor...: Thiago Rinaldi Pinto - TRP
Data....: 01/05/08
Objetivo: Retornar o Numero de Registros das tabelas SW2 e EE7
*/
Function AvTotReg()
Local nTotRegSW2, nTotRegEE7, nTotQ, cCodigo, nDiasPa
Local cQuerySW2   := ""
Local cQueryEE7   := ""


cFromSW2    := RetSqlName("SW2")+" SW2 ,"+RetSqlName("SY6")+" SY6"
cFromEE7    := RetSqlName("EE7")+" EE7 ,"+RetSqlName("SY6")+" SY6"

cCodigo:= AvKey(SY6->Y6_COD,"W2_COND_PA")

nDiasPa:= AvKey(SY6->Y6_DIAS_PA,"W2_DIAS_PA")


cWhereSW2   := iIF( TcSrvType()=="AS/400"," SW2.@DELETED@ <> '*' "," SW2.D_E_L_E_T_ <> '*'" ) + " AND SW2.W2_FILIAL = '"+xFilial("SW2")+"' "+;
                                 "AND SW2.W2_COND_PA = '"+cCodigo+"' AND SW2.W2_DIAS_PA = "+alltrim(nDiasPa)

//Total de Registros SW2
cQuerySW2 := " SELECT COUNT(*) AS TOTAL FROM "+cFromSW2+" WHERE "+cWhereSW2+""

// AST 24/06/08 - Conversão da query padrão para o BD utilizado
cWhereSW2 := ChangeQuery(cQuerySW2)

dbUseArea( .t., "TopConn", TCGenQry(,,cQuerySW2), "WKSW2", .F., .F. )

nTotRegSW2:=  WKSW2->TOTAL

cCodigo:= AvKey(SY6->Y6_COD,"EE7_CONDPA")

nDiasPa:= AvKey(SY6->Y6_DIAS_PA,"EE7_DIASPA")

cWhereEE7   := iIF( TcSrvType()=="AS/400"," EE7.@DELETED@ <> '*' "," EE7.D_E_L_E_T_ <> '*'" ) + " AND EE7.EE7_FILIAL = '"+xFilial("EE7")+"' "+;
                              " AND EE7.EE7_CONDPA = '"+cCodigo+"' AND EE7.EE7_DIASPA = "+alltrim(nDiasPa)

//Total de Registros EE7
cQueryEE7 := " SELECT COUNT(*) AS TOTAL FROM "+cFromEE7+" WHERE "+cWhereEE7+""


// AST 24/06/08 - Conversão da query padrão para o BD utilizado
cQueryEE7 := ChangeQuery(cQueryEE7)

dbUseArea( .t., "TopConn", TCGenQry(,,cQueryEE7), "WKEE7", .F., .F. )

nTotRegEE7:= WKEE7->TOTAL

WKSW2->( dbCloseArea() )
WKEE7->( dbCloseArea() )

//Total de Registros SW2+EE7
nTotQ:= nTotRegSW2 + nTotRegEE7

DBSELECTAREA("SW2")

Return (nTotQ)

*--------------------*
Function AvUpdGeral()
*--------------------*
Local lRet := .T.
/* FSM - 15/07/2011
Begin Sequence

   If (Upper(AllTrim(GetRpoRelease())) <> "R1") .And. MsgYesNo("O ambiente não está atualizado. Para que o atualizador seja executado todos os usuários deverão sair do Sistema. Prosseguir?.","Atenção")
      If lRet := U_UAVP10R1(.T.)
         SetMv("MV_AVG9999","P10R12")
         Final("Atualização efetuada.")
      EndIf
   EndIf

End Sequence
*/
Return lRet

/*
Função EECLoad
Objetivo   : Carregar arquivos na abertura do módulo de exportação.
Autor      : Alexsander Martins dos Santos
Data e Hora: 26/03/2004 às 17:23.
Observação : A função EECLoad é chamada automáticamente pelo Protheus na abertura do modulo EEC.
Revisão     : Dez/15 - Controle de atualização do AvUpdate02.PRW através de parâmetro genérico x data do programa no repositório.
*/
Function EECLoad()
Local cRelease := GetRPORelease()//LRS - 03/03/2015

Begin Sequence

   ExecutaAtualizacao("UPDEEC.PRW",cRelease)

   //Filtro para retirar as rotinas de comex do Mile
   SetMileFilter()

   /* Posteriormente, condicionar atualizações executadas pelo ABREEEC(), migrando para AvUpdate02 e
      tratando atualizações necessárias para mais de um módulo. Exemplo: EasyLinkAtu(). */
   ABREEEC()

End Sequence
Return Nil

/*
Função EFFLoad
Objetivo   : Carregar arquivos na abertura do módulo de financiamento.
Autor      : Alexsander Martins dos Santos
Data e Hora: 26/03/2004 às 17:23.
Observação : A função EFFLoad é chamada automáticamente pelo Protheus na abertura do modulo EFF.
Revisão     : Dez/15 - Controle de atualização do AvUpdate02.PRW através de parâmetro genérico x data do programa no repositório.
*/
Function EFFLoad()
Local cRelease := GetRPORelease()//LRS - 03/03/2015

Begin Sequence

	ExecutaAtualizacao("UPDEFF.PRW",cRelease)

   /* Posteriormente, condicionar atualizações executadas pelo ABREEEC(), migrando para AvUpdate02 e
      tratando atualizações necessárias para mais de um módulo. Exemplo: EasyLinkAtu(). */
   ABREEEC()

   //Filtro para retirar as rotinas de comex do Mile
   SetMileFilter()
   
End Sequence
Return Nil

/*
Funcao      : EDCLoad()
Objetivos   : Função que carrega junto com o Modulo.
Autor       : Lucas Raminelli - LRS
Data/Hora   : 04/03/2015
Revisão     : Dez/15 - Controle de atualização do AvUpdate02.PRW através de parâmetro genérico x data do programa no repositório.
*/
Function EDCLoad()
Local cRelease := GetRPORelease()

Begin Sequence
	ExecutaAtualizacao("UPDEDC.PRW",cRelease)

   //Filtro para retirar as rotinas de comex do Mile
   SetMileFilter()

End Sequence

Return

/*
Funcao      : ESSLoad()
Objetivos   : Função que carrega junto com o Modulo.
Autor       : Lucas Raminelli - LRS
Data/Hora   : 04/03/2015
Revisão     : Dez/15 - Controle de atualização do AvUpdate02.PRW através de parâmetro genérico x data do programa no repositório.
*/
Function ESSLoad()
Local cRelease := GetRPORelease()

Begin Sequence

	ExecutaAtualizacao("UPDESS.PRW",cRelease)

End Sequence

Return

/*
Funcao      : EICLoad()
Objetivos   : Função que carrega junto com o Modulo.
Autor       :
Data/Hora   :
Revisão     : Dez/15 - Controle de atualização do AvUpdate02.PRW através de parâmetro genérico x data do programa no repositório.
*/
Function EICLoad()
Local cRelease   := GetRPORelease()//LRS
Local aDataFonte := GetApoInfo("EECEI300.PRW")  //LRS - 17/07/2018
Local cArquivo   := "AVG_SEQ"
Local cAvg_Seq   := "Avg_Seq"
Local oUserParams:= EASYUSERCFG():New("AVGSEQ", "AVGSEQ", Space(FWSizeFilial()))
Local lAtuAvgSeq := .T.

Begin Sequence

/*    
IF ValType(aDataFonte) == "A"
        IF aDataFonte[4] < CTOD("08/06/2018")
            EasyHelp("Para a geração da numeração automática através da função AvgNumSeq() o sistema deve ser atualizado. Favor aplicar a atualização referente ao pacote DTRADE-41.","Atenção" )//"Para a geração da numeração automática através da função AvgNumSeq() o sistema deve ser atualizado. Favor aplicar a atualização referente ao pacote DTRADE-41."
            lAtuAvgSeq := .F. 
        EndIF
    EndIF
    //Realiza a conversao do avg_seq para o banco de dados
    If File(cArquivo+GetDBExtension()) .And. lAtuAvgSeq //Nao realiza a conversao se o fonte EECEI300 estiver desatualizado
        ConverteAvgSeq(cArquivo, cAvg_Seq, oUserParams)
    EndIf*/

    ExecutaAtualizacao("UPDEIC.PRW",cRelease)

	If FindFunction("AvUpdGeral")
		AvUpdGeral()
	EndIf

   //Filtro para retirar as rotinas de comex do Mile
   SetMileFilter()

End Sequence

Return

/*
Funcao      : EICLoad()
Objetivos   : 
Autor       :
Data/Hora   :
Revisão     : 
*/
Function ECOLoad()
   //Filtro para retirar as rotinas de comex do Mile
   SetMileFilter()
Return

/*
Funcao      : EasyParamControl()
Objetivos   : Criação de parâmetro de controle do módulo - controle de atualização do AvUpdate02.PRW
Autor       : WFS
Data/Hora   : Dez/2015
*/
Static Function EasyParamControl(cParametro)
Local oUpd

Default cParametro:= "MV_" + cModulo + "9999"
Private cParSX6 := cParametro
Begin Sequence
//THTS - 25/07/2017 - O parametro foi alterado para Caracter para controlar data, hora, Minuto e Segundo
   If !EasyGParam(cParametro, .T.) .Or. ValType(EasyGParam(cParametro)) == "D"
      
        If FindFunction("AvUpdate01")
            oUpd := AVUpdate01():New()
            oUpd:aChamados := {{nModulo,{|o| UMVUPDATE(o)}}}
            oUpd:Init(,.T.)
        EndIf
        //THTS - 25/07/2017 - Ao criar o parametro, cria com o conteudo em branco para forcar a execucao da atualizacao.
        If EasyGParam(cParametro, .T.)
            PutMv(cParametro,"")
        EndIf
   EndIf
End Sequence

Return
//THTS-25/07/2016 - Altera o parametro MV_xxx9999 para Caracter, onde o xxx refere-se ao modulo do Easy
Static Function UMVUPDATE(o)
o:TableStruct("SX6",{"X6_FIL"       ,"X6_VAR" ,"X6_TIPO","X6_DESCRIC"                                               ,"X6_DESC1" ,"X6_DESC2"   ,"X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME"})
o:TableData("SX6"  ,{xFilial("SX6") ,cParSX6  ,"C"      ,"Controle de execução do AvUpdate02 - módulo " + cModulo   ,""         ,""           ,""          ,""          ,""          ,""          ,""          ,""        ,""      })
Return

/*
Funcao      : ExecutaAtualizacao()
Objetivos   : Verifica se executa a atualização
Autor       : WFS
Data/Hora   : Dez/2015
Parâmetros  : cPrograma - nome do programa de atualização
			  cRelease	- Release do ambiente em execução
         
Revisão     : adicionada, como condição, a alteração do avupdate02, devido às funções de carga de dados
*/
Static Function ExecutaAtualizacao(cPrograma,cRelease)
Local lRet:= .F.
Local cParametro:= "MV_" + cModulo + "9999"
Local dUltimaAtualizacao
Local lAvUpdErro := .F. //THTS - 22/09/2017 - Controle se ocorreu algum error log durante execucao do AvUpdate.
Local dAtualizacaoAtual
Local aFiliais := AvgSelectFil(.F.)
Local oUserParams:= EASYUSERCFG():New("EASYPARAM", "EASYPARAM", Space(FWSizeFilial()))
Local cBkpFil := cFilAnt
Local i
Local aOrd := SaveOrd({'SM0'})

Begin Sequence
//THTS - 25/07/2016 - Alterado o parametro de controle das atualizacoes para gravar data, hora, minuto e segundo.
    If Alltrim(SubSTR(cRelease,1,2)) == "12" 
      for i := 1 to Len(aFiliais)
         cFilAnt := aFiliais[i]
         dUltimaAtualizacao := oUserParams:LoadParam(aFiliais[i]+cParametro, "", Space(FWSizeFilial()), .T.)
         //EasyParamControl(cParametro)
         //If  EasyGParam(cParametro, .T.)
         //dUltimaAtualizacao:= EasyGParam(cParametro)
         dAtualizacaoAtual:= MaiorData(cPrograma, "AVUPDATE02.PRW")

         If Empty(dUltimaAtualizacao) .Or. dUltimaAtualizacao < dAtualizacaoAtual
            
            If MayIUseCode(cEmpAnt+cParametro)
               lRet:= .T.
               EasyUpd12(cRelease,cModulo)

               //If EasyGParam("AVUPDATE02",, 0) == 0 //o parâmetro avupdate02 indicará se é simulação ou execução; quando for somente simuação, não precisa atualizar o parâmetro com a data de atualização.
               //   SetMv(cParametro, dAtualizacaoAtual)//Grava data e hora no formato: dd/mm/aaaa-hh:mm:ss
               //EndIf
               oUserParams:SetParam(aFiliais[i]+cParametro, dAtualizacaoAtual, Space(FWSizeFilial()))
            
               FreeUsedCode()
            Else
               //Tem alguem executando a atualização simultaneamente na mesma empresa, aguarda a conclusão
               //Para evitar duplicidade na carga de tabelas e estouro de chave unica.
               Do While .T.
                  Sleep(1000)
                  If MayIUseCode(cEmpAnt+cParametro)
                     //Liberou
                     FreeUsedCode()
                     Exit
                  EndIf
               EndDo
            EndIf
         EndIf
         //EndIf
      Next i
   EndIf
End Sequence

cFilAnt := cBkpFil
RestOrd(aOrd,.T.)

Return lRet

/*
Funcao      : MaiorData
Parametros  : 
Retorno     : Maior data de dois programas, conforme array do getApoInfo
Objetivos   : comparar e retornar a maior data de dois programas
Autor       : wfs
Data/Hora   : abr/2018
Revisao     :
Obs.        :
*/
Static Function MaiorData(progA, progB)
Local dMaiorData
Local aInfoProgA:= GetApoInfo(progA)
Local aInfoUpd0B:= GetApoInfo(progB)

   If dTos(aInfoProgA[4])+"-"+aInfoProgA[5] < dTos(aInfoUpd0B[4])+"-"+aInfoUpd0B[5]
      dMaiorData:= dTos(aInfoUpd0B[4])+"-"+aInfoUpd0B[5]
   Else
      dMaiorData:= dTos(aInfoProgA[4])+"-"+aInfoProgA[5]
   EndIf

Return dMaiorData
/*
Funcao      : AvPreAmb
Parametros  : Parâmetros passados pelo Scheduler
Retorno     : .T.
Objetivos   : Prepara o ambiente para execução por agendamento.
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 17/12/07
Revisao     :
Obs.        :
*/
*--------------------------------------------*
Function AvPreAmb(aParam)
*--------------------------------------------*

PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] MODULO aParam[3] TABLES "SX5","ECA","ECF","EEC","EEQ"

E_INIT(.T.) //para criação de variáveis

If EMPTY(cUSUARIO)
   cUSUARIO := SPACE(06)+"JOB            "
EndIf

RETURN .T.

/*
Funcao      : AvE_Msg
Parametros  : cMsg: Mensagem, n: Tempo da mensagem para o E_MSG.
Retorno     : .T.
Objetivos   : Tratamento para mensagens em ambiente em execução por agendamento.
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 17/12/07
Revisao     :
Obs.        :
*/
*-------------------------*
Function AvE_Msg(cMsg,uInfo)
*-------------------------*

IF Type("lScheduled") == "L" .AND. lScheduled
   If ValType(uInfo) == "S"
      ConOut(uInfo+" - "+cMsg)
   Else
      ConOut(cMsg)
   EndIf

   If Type("aMessages") == "A"
      aAdd(aMessages,cMsg)
   EndIf
ElseIf ValType(uInfo) == "N"
   E_MSG(cMsg,uInfo)
ElseIf ValType(uInfo) == "U"
   E_MSG(cMsg,1)
ElseIf ValType(uInfo) == "S"
   E_MSG(cMsg,1,,uInfo)
ENDIF

RETURN .T.

/*
Funcao      : AvPAguarde
Parametros  : bProcesso: Bloco de código para execução, cMsg: Mensagem de aguarde.
Retorno     : .T.
Objetivos   : Aguarde de Processamento para ambiente em execução por agendamento.
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 17/12/07
Revisao     :
Obs.        :
*/
*-------------------------*
Function AvPAguarde(bProcesso,cMsg)
*-------------------------*

IF Type("lScheduled") == "L" .AND. lScheduled
   ConOut("["+DToC(Date()) + " " + Time()+"] "+cMsg)
   Eval(bProcesso)
ELSE
   MsAguarde(bProcesso,cMsg)
ENDIF

RETURN .T.

/*
Funcao      : AvProcessa
Parametros  : bProcesso: Bloco de código para execução, cMsg: Mensagem de aguarde.
Retorno     : .T.
Objetivos   : Processamento para ambiente em execução por agendamento.
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 17/12/07
Revisao     :
Obs.        :
*/
*-------------------------*
Function AvProcessa(bProcesso,cMsg)
*-------------------------*

IF Type("lScheduled") == "L" .AND. lScheduled
   If ValType(cMsg) == "S"
      ConOut("["+DToC(Date()) + " " + Time()+"] "+cMsg)
   EndIf
   Eval(bProcesso)
ELSE
   Processa(bProcesso,cMsg)
ENDIF

RETURN .T.

/*
Funcao      : AvSay
Parametros  : nLin: Linha a ser impressa, nCol: Coluna a ser impressa, cString: Texto a ser impresso
Retorno     : .T.
Objetivos   : Tratamento para impressão de relatório em TXT em ambiente em execução por agendamento.
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 20/12/07
Revisao     :
Obs.        : Trocar o comando @ say pelo comando abaixo:
              #Command @ <lin>,<coluna> psay <conteudo>  => AvSayImp(<lin>,<coluna>, <conteudo>)
*/
**************************************
Function AvSay(nLin, nCol, cString)
**************************************
Private cTexto := cString
Static nLinha  := 0
Static nColun  := 0

If Type("nHdl") == "N" .AND. Type("lScheduled") == "L" .AND. lScheduled
   If nLin < nLinha
      nLinha := 0
      nColun := 0
   EndIf

   Do While nLinha < nLin
      fWrite(nHdl,Chr(13)+Chr(10))
      nLinha++
      nColun := 0
   EndDo

   Do While nColun < nCol
      fWrite(nHdl," ")
      nColun++
   EndDo

   fWrite(nHdl,cTexto)
   nColun += Len(cTexto)
Else
   If Type("aDriver") == "A" .AND. cString == &(aDriver[3])
      Private aDriver := ReadDriver()

      @ 0,0 PSay &(aDriver[3])
   Else
      //TSay():New( nLin, nCol, &cTexto) //Equivalente a: @ nLin, nCol psay cTexto
      @ nLin, nCol psay cTexto
   EndIf
EndIf

Return nil
/*------------------------------------------------------------------------------------
Funcao      : getNFEImp
Parametros  : lSWN       - Indica se a tabela SWN já está posicionada no registro (integração SAP)
              pNF        - Número da nota de entrada, caso seja nota complementar, será informada a NF original
              pSerie     - Série da nota de entrada, caso seja nota complementar, será informada a Série original
              pForn      - Fornecedor da nota de entrada
              pLoja      - Loja do fornecedor da nota de entrada
              pTipoNF    - Tipo da NF de entrada, sendo 1=Primeira, 2=Complementar e 3=Única
              pPedido    - Número do pedido (utilizado p/ primeira nota ou única)
              pItem      - Sequencial que identifica o item do pedido, caso seja nota complementar, será informadado o Item original
Retorno     : Vetor com os dados para complementação da NF com os dados da Importação
Objetivos   : Fornecer dados da importação para a NF Eletrônica
Autor       : Anderson Soares Toledo
Data/Hora   : 15/10/2008 - 17h30
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Function getNFEImp(lSWN,pNF,pSerie,pForn,pLoja,pTipoNF,pPedido,pItem,pLote,cItemNF)
   Local aOrd
   Local aDados := {}
   Local cQuery := ""  // GFP - 07/02/2013
   Local cWkQry := GetNextAlias()
   Default cItemNF = ""

   aOrd := SaveOrd({"SWN","SW6","SW8","SY9"})

   SW6->(dbSetOrder(1)) // W6_FILIAL+W6_HAWB
   SW8->(dbSetOrder(6)) // W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM
   SY9->(dbSetOrder(2)) // Y9_FILIAL+Y9_SIGLA

   If lSWN // Caso a tabela esteja posicionada, os demais parametros são ignorados

      If SW8->(dbSeek(xFilial("SW8")+SWN->WN_HAWB+SWN->WN_INVOICE+SWN->WN_PO_EIC+SWN->WN_ITEM+SWN->WN_PGI_NUM)) .And. ;
         SW6->(dbSeek(xFilial("SW6")+SW8->W8_HAWB)) .And. ;
         if (!EMPTY(SW6->W6_LOCAL),SY9->(dbSeek(xFilial("SY9")+SW6->W6_LOCAL)),.T.) //Caso o W6_LOCAL esteja vazio retorna .T.

         If alltrim(SWN->WN_TIPO_NF) <> "2"
            aDados := retVetNFE("1") //Não importa se o tipo 1 ou 3, a estrutura do vetor é a mesma
         Else
            aDados := retVetNFE("2")
         EndIf

         If EasyEntryPoint("getNFEImp")
            ExecBlock("getNFEImp",.F.,.F.,{"lSWN"})
         Endif
      Else // Caso algum dbSeek retorne .F.
         aDados := {}
      EndIf
   Else //Caso não esteja posicionado na tabela SWN
      SWN->(dbSetOrder(2)) // WN_FILIAL+WN_DOC+WN_SERIE+WN_FORNECE+WN_LOJA

      pNF        := alltrim(pNF)
      pSerie     := alltrim(pSerie)
      pForn      := alltrim(pForn)
      pLoja      := alltrim(pLoja)
      pTipoNF    := alltrim(pTipoNF)
      pPedido    := alltrim(pPedido)
      pItem      := alltrim(pItem)
      pLote      := alltrim(pLote)//LRS - 08/02/2017
      cItemNF    := AllTrim(cItemNF)

      //Validação dos parâmetros, caso algum esteja incorreto, retorna um vetor vazio
      //If pTipoNF == "1" .Or. pTipoNF == "2" .Or. pTipoNF == "3".Or. pTipoNF == "5" comentado por WFS em 31/03/11
      If pTipoNF == "1" .Or. pTipoNF == "2" .Or. pTipoNF == "3".Or. pTipoNF == "5" .Or. pTipoNF == "6" //inclusão da nota filha

         //Verifica se não existe nenhum parametro em branco.
         /* na validação dos parâmetros recebidos o item da nota fiscal não é validado pq
          - quando for nota primeira única ou mãe todos o parâmetros são preenchidos
          - e quando for nota filha ou complementar o item da nf vem vazio e o item da nf 
               vem no parâmetro de item do pedido */

         If Empty(pNF) .Or. Empty(pSerie) .Or. Empty(pForn) .Or. Empty(pLoja).Or. Empty(pItem) .Or. ((pTipoNF <> "2" .And. pTipoNF <> "6") .And. Empty(pPedido))
            Alert(STR0229) //#STR0229->"Todos parametros devem ser informados."
            Return aDados := {}
         EndIf
      Else
         Alert(STR0230) //#STR0230->"Tipo da NF inválido!"
         Return aDados := {}
      EndIf

      //Nota primeira, única ou mãe
      If pTipoNF == "1" .Or. pTipoNF == "3" .Or. pTipoNF == "5"
         If SWN->(dbSeek(xFilial("SWN")+AvKey(pNF,"WN_DOC")+AvKey(pSerie,"WN_SERIE")+AvKey(pForn,"WN_FORNECE")+AvKey(pLoja,"WN_LOJA")))

            While SWN->(!EOF()) .And. (pNF == alltrim(SWN->WN_DOC) .And. pSerie == alltrim(SWN->WN_SERIE)) .And.;
                     pForn == alltrim(SWN->WN_FORNECE) .And. pLoja == alltrim(SWN->WN_LOJA)

               //WFS 06/04/11
               //Quando a nota fiscal é integrada, o EICIN100 grava os campos WN_PO_EIC e WN_PO_NUM com a mesma informação - número do PO.
			   //BHF = 08/04/2009 Troca do WN_PO_EIC por WN_PO_NUM -> O fonte FNESEFAZ passa por paramatro o Num. pedido de compra e não Num.Po EIC
               //MFR 24/10/2019 OSSME-3933
               If pTipoNF == alltrim(SWN->WN_TIPO_NF) .And. pPedido == alltrim(SWN->WN_PO_NUM) .And. pItem == If(SWN->(FIELDPOS("WN_ITEM_DA")) > 0 .AND. !EMPTY(SWN->WN_ITEM_DA) ,alltrim(SWN->WN_ITEM_DA),alltrim(SWN->WN_ITEM)) .AND.;
                  IF(EasyGParam("MV_LOTEEIC",,"N") == "S" .AND. !Empty(pLote) .and. !empty(SWN->WN_LOTECTL) ,pLote == alltrim(SWN->WN_LOTECTL),.T.) .And.; //LRS - 08/02/2017
                  (Empty(cItemNF) .Or. Val(cItemNF) == SWN->WN_LINHA)

                  If SW8->(dbSeek(xFilial("SW8")+SWN->WN_HAWB+SWN->WN_INVOICE+SWN->WN_PO_EIC+SWN->WN_ITEM+SWN->WN_PGI_NUM)) .And.;
                     SW6->(dbSeek(xFilial("SW6")+SW8->W8_HAWB))

                     SY9->(dbSeek(xFilial("SY9")+SW6->W6_LOCAL))

                     aDados := retVetNFE(pTipoNF)

                     If EasyEntryPoint("getNFEImp")
                        ExecBlock("getNFEImp",.F.,.F.,{"UNICA"})
                     Endif

                     Exit
                  Else // Caso algum dbSeek retorne .F.
                     aDados := {}
                  EndIf
               ElseIf SWN->WN_INTDESP == "S"
                  
                  //LGS - 21/06/2016 - Ajuste para posicionar corretamente no item do pedido que veio por parametro..
                  cQuery := "SELECT SWN.R_E_C_N_O_ FROM " + RetSqlName("SWN") + " SWN " 
                  cQuery += " INNER JOIN " + RetSqlName("SW2") + " SW2 "
                  cQuery += " ON  SWN.WN_FILIAL = '" + xFilial("SWN") + "' AND SWN.WN_PO_NUM = SW2.W2_PO_NUM "
                  cQuery += " WHERE SWN.D_E_L_E_T_ <> '*' AND SW2.D_E_L_E_T_ <> '*' "
                  cQuery += " AND SW2.W2_PO_SIGA = '" + pPedido + "' AND SWN.WN_ITEM = '" + pItem + "' " 
                  //MFR 24/10/2109 OSSME-3993
                  cQuery += " AND SWN.WN_DOC = '" + pNf + "' AND SWN.WN_SERIE = '" + pSerie + "' AND SWN.WN_FORNECE = '" + pForn + "' AND SWN.WN_LOJA = '" + pLoja + "' "

                  cQuery:= ChangeQuery(cQuery)
                  DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), cWkQry, .T., .T.)

                  If !((cWkQry)->(Bof()) .AND. (cWkQry)->(Eof()))
                     //LGS - 21/06/2016 - Posiona as tebelas com base no RecNo da SWN..
                     SWN->(DbGoTo((cWkQry)->R_E_C_N_O_))
                     SW6->(DBSeek(xFilial() + SWN->WN_HAWB))
                     SW8->(dbSeek(xFilial("SW8")+SWN->WN_HAWB+SWN->WN_INVOICE+SWN->WN_PO_EIC+SWN->WN_ITEM+SWN->WN_PGI_NUM))
                     SY9->(dbSeek(xFilial("SY9")+SW6->W6_LOCAL))
                     aDados:= retVetNFE(pTipoNF)
                     Exit
                                      
                  EndIf
                  (cWkQry)->(DbCloseArea())

               EndIf
               SWN->(dbSkip())
            EndDo
         Else
            RestOrd(aOrd)
            aDados := {}  //caso o processo não seja encontrado, retorna vetor vazio
         EndIf

      Else //Nota complementar ou filha
         If SWN->(dbSeek(xFilial("SWN")+AvKey(pNF,"WN_DOC")+AvKey(pSerie,"WN_SERIE")+AvKey(pForn,"WN_FORNECE")+AvKey(pLoja,"WN_LOJA")))

            While SWN->(!EOF()) .And. (pNF == alltrim(SWN->WN_DOC) .And. pSerie == alltrim(SWN->WN_SERIE)) .And.;
                  pForn == alltrim(SWN->WN_FORNECE) .And. pLoja == alltrim(SWN->WN_LOJA)

               //if pItem == if(ValType(SWN->WN_LINHA) == "N",alltrim(str(SWN->WN_LINHA)),alltrim(SWN->WN_LINHA)) comentado por WFS em 30/03/11
               if pItem == if(ValType(SWN->WN_LINHA) == "N",alltrim(StrZero(SWN->WN_LINHA, AvSx3("D1_ITEM", AV_TAMANHO))),alltrim(SWN->WN_LINHA))

                                 //W8_FILIAL    +W8_HAWB     +W8_INVOICE     +W8_PO_NUM     +W8_POSICAO  +W8_PGI_NUM
                  If SW8->(dbSeek(xFilial("SW8")+SWN->WN_HAWB+SWN->WN_INVOICE+SWN->WN_PO_EIC+SWN->WN_ITEM+SWN->WN_PGI_NUM)) .And.;
                     SW6->(dbSeek(xFilial("SW6")+SW8->W8_HAWB)) .And.;
                     if (!EMPTY(SW6->W6_LOCAL),SY9->(dbSeek(xFilial("SY9")+SW6->W6_LOCAL)),.T.)//Caso o W6_LOCAL esteja vazio retorna .T.

                     aDados := retVetNFE(pTipoNF)

                     If EasyEntryPoint("getNFEImp")
                        ExecBlock("getNFEImp",.F.,.F.,{"Complementar"})
                     Endif

                     exit
                  //WFS 01/04/11
                  ElseIf SWN->WN_INTDESP == "S" //se foi integrado pelo despachante, força a procura do item

                     SW8->(DBSeek(xFilial() + SWN->WN_HAWB))
                     While SW8->(!Eof()) .And. SW8->W8_FILIAL == SW8->(xFilial()) .And.;
                            SW8->W8_HAWB == SWN->WN_HAWB

                        If SW8->W8_PO_NUM  == SWN->WN_PO_EIC .And. SW8->W8_POSICAO == SWN->WN_ITEM

                           If SW6->(DBSeek(xFilial() + SW8->W8_HAWB)) .And.;
                           If (!Empty(SW6->W6_LOCAL), SY9->(DBSeek(xFilial() + SW6->W6_LOCAL)), .T.)

                              aDados:= retVetNFE(pTipoNF)

                              If EasyEntryPoint("getNFEImp")
                                 ExecBlock("getNFEImp",.F.,.F.,{"Complementar"})
                              Endif

                              Exit
                           EndIf
                        EndIf

                        SW8->(DBSkip())
                     EndDo

                  Else // Caso algum dbSeek retorne .F.
                     aDados := {}
                  EndIf
               EndIf
               SWN->(dbSkip())
            EndDo
         Else
            RestOrd(aOrd)
            aDados := {} //caso o processo não seja encontrado, retorna vetor vazio
         Endif
      EndIf
   EndIf

   RestOrd(aOrd)

Return aDados


/*------------------------------------------------------------------------------------
Funcao      : getNFEExp
Parametros  : pProcesso - Processo de qual deseja obter os dados da NF
              pPedido - Pedido para substituir o processo caso esteja vazio
              cProduto - código do item
              cChave - composto por nota fiscal e série
Retorno     : Vetor com os dados para complementação da NF com os dados da Exportação
Objetivos   : Fornecer dados da exportação para a NF Eletrônica
Autor       : Anderson Soares Toledo
Data/Hora   : 14/10/2008 - 11h00
Revisao     : 15/03/2011 - 15h00 - Tamires Daglio Ferreira
Obs.        : Inclusão do tratamento para número do pedido quando não houver embarque
Revisao     : Guilherme Fernandes Pilan - GFP
Data/Hora   : 28/11/2013
Objetivos   : Novo Layout NFE - (Nota técnica da NFe - 2013-005)
Revisão     : ------------------------
              WFS - 12/2014
              Ajuste no leiaute NFe 3.10, NT 2013-003 versão 1.21
              A função é chamada por item da nota fiscal, devendo retornar os dados
              apenas do item referente à nota que será transmitida.
              WFS - 21/09/2015
              Adicionados os parâmetros cPedVen e cItemPV.
              - cenários com o mesmo item repedindo duas ou mais vezes no mesmo pedido
              e mesma nota fiscal de saída.
*------------------------------------------------------------------------------------*/
Function getNFEExp(pProcesso, pPedido, cProduto, cChave, cPedVen, cItemPV, cLote)
   Local aOrd, x
   Local aDados := {}, aDadosZA01:= {}, aDadosI50:= {}, aDadosI51:= {}, aDadosI52:= {}, aAux:= {}, aExportInd:= {}, aDadosLtEx := {}
   Local lAchou:= .F.
   Local cLocDespacho:= ""
   Local cPedVenOri:= ""
   Local cItPVOri:= ""
   Local lNFIndireta:= .F. //LGS-02/02/2016
   Local lPedido:= .F., lEmbarque:= .F. //LRS
   Local cQuery := "" //LRS - 17/05/2017
   Local lRet := .F. //LRS - 17/05/2017
   Local cNF    := LEFT(cChave,AVSX3("EE9_NF",AV_TAMANHO))
   Local cSerie := Right(cChave,AVSX3("EE9_SERIE",AV_TAMANHO))
   Default cChave:= ""
   Default cProduto:= ""
   Default cPedVen:= ""
   Default cItemPV:= ""
   Default cLote:= SD2->D2_LOTECTL

Begin Sequence

   aOrd := SaveOrd({"EE7", "EE8", "EEC", "SY9", "EE9", "EYY", "SF1"})

   pProcesso := alltrim(pProcesso)
   pPedido   := alltrim(pPedido)

   If !Empty(pProcesso)

      EEC->(dbSetOrder(1)) // xFilial+EEC_PREEMB
      SY9->(dbSetOrder(2)) // xFilial+Y9_SIGLA
      EE9->(dbSetOrder(3)) // xFilial+EE9_PREEMB+EE9_SEQEMB  // GFP - 19/09/2014

      If EEC->(dbSeek(xFilial("EEC")+AvKey(pProcesso,"EEC_PREEMB"))) .And.;
         SY9->(dbSeek(xFilial("SY9")+AvKey(EEC->EEC_ORIGEM,"Y9_SIGLA"))) .And.;
         EE9->(dbSeek(xFilial("EE9")+AvKey(pProcesso,"EE9_PREEMB")))
         lAchou:= .T.
         lEmbarque := .T.
      EndIF
   ElseIf !Empty(pPedido)

      EE7->(dbSetOrder(1)) // xFilial+EE7_PEDIDO
      SY9->(dbSetOrder(2)) // xFilial+Y9_SIGLA
      EE8->(dbSetOrder(1)) // xFilial+EE8_PEDIDO

      If EE7->(dbSeek(xFilial("EE7")+AvKey(pPedido,"EE7_PEDIDO"))) .And.;
         SY9->(dbSeek(xFilial("SY9")+AvKey(EE7->EE7_ORIGEM,"Y9_SIGLA"))) .And.;
         EE8->(dbSeek(xFilial("EE8")+AvKey(pPedido,"EE8_PEDIDO")))
         lAchou:= .T.
         lPedido := .T.
      EndIF
   Else
      Alert(STR0231) //#STR0231->"Processo não informado."
      Break
   EndIf

   If lAchou

      /* Legado das versões anteriores à 3.10*/
      aAdd(aDados,{"ZA02","ufEmbarq",SY9->Y9_ESTADO})
      aAdd(aDados,{"ZA03","xLocEmbarq",SY9->Y9_DESCR})

      /* Se a chave não vier por parâmetro, os dados do item, conforme leiaute da NFe
         3.10 não serão retornados.
         O aDados retornará apenas as informações referente às versões anterioes. */
      If Empty(cProduto + cChave)
         Break
      EndIf

      /* Consiste o posicionamento da tabela EE9 */
      If Empty(pProcesso)
         EE9->(DBSetOrder(1)) //EE9_FILIAL+EE9_PEDIDO+EE9_SEQUEN+EE9_PREEMB+EE9_HOUSE
         If EE9->(DBSeek(xFilial() + AvKey(pPedido, "EE7_PEDIDO")))
            pProcesso:= EE9->EE9_PREEMB
         EndIf
         EE9->(DBSetOrder(3)) //EE9_FILIAL+EE9_PREEMB+EE9_SEQEMB
         EE9->(DBSeek(xFilial() + pProcesso))
      EndIf

      If !Empty(pProcesso) //LGS-02/02/2016
         EEC->(dbSetOrder(1)) // xFilial+EEC_PREEMB
         EEC->(dbSeek(xFilial("EEC")+AvKey(pProcesso,"EEC_PREEMB")))
         lNFIndireta := (!Empty(EEC->(EEC_EXPORT+EEC_EXLOJA)) .And. EEC->(EEC_EXPORT+EEC_EXLOJA) <> EEC->(EEC_FORN+EEC_FOLOJA) )
      EndIf


      /* Inicio do tratamento para retorno dos dados da seção 3.11 - Controle de Exportação
         por Item.
         Montagem do ID I50.
         IDs filhos: I51 e I52.
         A posição 3 do aDados será retornado com o identificador I50, ainda que não existam dados
         correspondentes ao I51 e I52.
         A relação de ocorrência dos identificadores I51 e I52 com o I50 é de  0-1, ou seja, se não houver.
         não envia; se houver, para cada ocorrência deve ser gerada uma tag I50 (detExport). */

      EYY->(DbSetOrder(3))  //EYY_FILIAL+EYY_PREEMB+EYY_PEDIDO+EYY_SEQUEN
      SF1->(DbSetOrder(1))  //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
         
      //LRS - 05/06/2017 -Alteração na forma de carregar as informacoes do EE9 para gerar o XML
      cQuery := " SELECT EE9.EE9_ATOCON,EE9.EE9_PREEMB, EE9.EE9_SEQEMB, EE9.EE9_PEDIDO, EE9.EE9_FABR, EE9.EE9_FALOJA"
      cQuery += ",EE9.EE9_SEQUEN,EE9.EE9_FORN,EE9.EE9_FOLOJA,EE9.EE9_COD_I"
      cQuery += ' FROM ' + RetSqlName("EE9") + ' EE9 '	
      cQuery += " WHERE EE9.EE9_FILIAL = '" + xFilial("EE9") + "' and "
      cQuery += " EE9.EE9_PREEMB = '"+ AvKey(pProcesso,"EE9_PREEMB") + "' and"
      cQuery += " EE9.EE9_COD_I  = '"+ AvKey(cProduto ,"EE9_COD_I" ) + "' and"
      cQuery += " EE9.EE9_NF = '"+ cNf + "' and"
      cQuery += " EE9.EE9_SERIE = '"+ cSerie + "' and"
      cQuery += iIF( TcSrvType()=="AS/400"," EE9.@DELETED@ <> '*' "," EE9.D_E_L_E_T_ <> '*'" )


      cQuery:= ChangeQuery(cQuery)
      DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "QryEE9", .T., .T.)
      
      lRet := !(QryEE9->(Eof()) .AND. QryEE9->(Bof())) 
      
      QryEE9->(DBGoTop())
    
      IF lRet
         While QryEE9->(!Eof()) 
        
                /* Verifica se o produto recebido refere-se ao mesmo item do pedido de venda considerado na nota fiscal */
                If !Empty(cPedVen)
                  If EECFlags("INTEMB")
                     cPedVenOri:= Posicione("EEC", 1, xFilial("EEC") + QryEE9->EE9_PREEMB, "EEC_PEDFAT")
                     cItPVOri:= Posicione("EE9", 3, xFilial("EE9")+ QryEE9->EE9_PREEMB + QryEE9->EE9_SEQEMB, "EE9_FATIT")
                  Else
                     cPedVenOri:= Posicione("EE7", 1, xFilial("EE7") + QryEE9->EE9_PEDIDO, "EE7_PEDFAT")
                     cItPVOri:= Posicione("EE8", 1, xFilial("EE8") + QryEE9->EE9_PEDIDO + QryEE9->EE9_SEQUEN, "EE8_FATIT")
                  EndIf

                  /* Ajuste de tamanho de campo chave */
                  cPedVenOri:= AvKey(cPedVenOri, "D2_PEDIDO")
                  cItPVOri:= AvKey(cItPVOri, "D2_ITEMPV")

                  /* Compara se o item enviado pelo NFESefaz é o mesmo posicionado no embarque */
                  If cPedVenOri + cItPVOri <> cPedVen + cItemPV
                     QryEE9->(DBSkip())
                     Loop
                  EndIf
                EndIf

                /* I51 - nDraw
                Dados do ato concessório.*/
                If !Empty(QryEE9->EE9_ATOCON)
                  AAdd(aDadosI51, {"I51", "nDraw", QryEE9->EE9_ATOCON})
                EndIf
            
            /* I52 - exportInd
            Dados da exportação indireta. */
               If (!Empty(QryEE9->(EE9_FABR+EE9_FALOJA)) .And. QryEE9->(EE9_FORN+EE9_FOLOJA) <> QryEE9->(EE9_FABR+EE9_FALOJA) ) .Or. lNFIndireta //LGS-02/02/2016 // Exportação Indireta

                  If EYY->(DBSeek(xFilial() + QryEE9->EE9_PREEMB + QryEE9->EE9_PEDIDO + QryEE9->EE9_SEQUEN))  //Localizar NFs Remessa

                     While EYY->(!Eof()) .And.;
                              EYY->EYY_FILIAL == EYY->(xFilial()) .And.;
                              EYY->EYY_PREEMB == QryEE9->EE9_PREEMB .And.;
                              EYY->EYY_PEDIDO == QryEE9->EE9_PEDIDO .And.;
                              EYY->EYY_SEQUEN == QryEE9->EE9_SEQUEN

                           /* Se a nota fiscal de saída do item for diferente da nota fiscal chamada do NFESefaz, não
                              retornaremos no array. */
                           If AvKey(EYY->EYY_NFSAI, "F2_DOC") + AvKey(EYY->EYY_SERSAI, "F2_SERIE") <> cChave
                              EYY->(DBSkip())
                              Loop
                           EndIf

                           /* Se o lote da nota fiscal de saída for diferente do lote da nota fiscal de entrada,
                              ignora o documento. */
                           If !Empty(cLote) .And. !ConfirmaLote(cLote)
                              EYY->(DBSkip())
                              Loop
                           EndIf

                           SF1->(DBSeek(xFilial("SF1") + EYY->(AvKey(EYY_NFENT , "F1_DOC") +;
                                                               AvKey(EYY_SERENT, "F1_SERIE") +;
                                                               AvKey(EYY_FORN  , "F1_FORNECE") +;
                                                               AvKey(EYY_FOLOJA, "F1_LOJA"))))  //Localizar NFs no Compras

                           /* Quando o item do embarque tiver quebra da sequencia devido ao ato concessório, os dados da
                              remessa com fins específicos de exportação não podem ser duplicados no array.
                              O array aAux é apenas para auxiliar na verificação de itens inseridos no array,
                              evitando essa duplicação. */
                           nPosInd := 0
                           aExportInd:= {}
                           If Len(aAux) == 0 .Or.;
                              !( nPosInd := AScan(aAux, {|x| x[1] == EYY->EYY_RE .And.;
                              x[2] == SF1->F1_CHVNFE} ) ) > 0 //.And.; x[3] == EYY->EYY_QUANT

                              AAdd(aAux, {EYY->EYY_RE, SF1->F1_CHVNFE, EYY->EYY_QUANT})
                           else

                              aAux[nPosInd][3] += EYY->EYY_QUANT
                           EndIf

                           EYY->(DBSkip())
                     EndDo
                  EndIf
               EndIf

               For x := 1 to len(aAux)
                  aExportInd:= {}
                  AAdd(aExportInd, {"I53", "nRE"    , aAux[x][1] }) //EYY->EYY_RE
                  AAdd(aExportInd, {"I54", "chNFe"  , aAux[x][2] }) //SF1->F1_CHVNFE
                  AAdd(aExportInd, {"I55", "qExport", aAux[x][3] }) //EYY->EYY_QUANT

                  AAdd(aDadosI52, {"I52", "exportInd", aExportInd})
               Next

               /* Igualar o tamanho dos arrays */
               AjustaTam(@aDadosI51, @aDadosI52, QryEE9->EE9_ATOCON)

                 //NCF - 10/12/2018 - Carregar as informacoes do EK6 para gerar o XML Sped
                If AVFLAGS("NOTAS_FISCAIS_SAIDA_LOTE_EXPORTACAO")

                   cQuery := " SELECT *"
                   cQuery += " FROM " + RetSqlName("EK6") + " EK6 "	
                   cQuery += " WHERE EK6.EK6_FILIAL = '" + xFilial("EK6") + "' and "
                   cQuery += " EK6.EK6_PREEMB = '"+ AvKey(QryEE9->EE9_PREEMB,"EK6_PREEMB") + "' and"
                   cQuery += " EK6.EK6_PDNFSD = '"+ AvKey(QryEE9->EE9_PEDIDO,"EK6_PDNFSD") + "' and"
                   cQuery += " EK6.EK6_SQPDNF = '"+ AvKey(QryEE9->EE9_SEQUEN,"EK6_SQPDNF") + "' and"
                   cQuery += " EK6.EK6_NFSD   = '"+ AvKey(cNF               ,"EK6_NFSD"  ) + "' and"
                   cQuery += " EK6.EK6_SENFSD = '"+ AvKey(cSerie            ,"EK6_SENFSD") + "' and"
                   cQuery += iIF( TcSrvType()=="AS/400"," EK6.@DELETED@ <> '*' "," EK6.D_E_L_E_T_ <> '*'" )

                   cQuery:= ChangeQuery(cQuery)
                   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "QryEK6", .T., .T.)
       
                   QryEK6->(DBGoTop())

                   IF !(QryEK6->(Eof()) .AND. QryEK6->(Bof()))
                       While QryEK6->(!Eof())
                          If aScan(aDadosLtEx, {|x| x[1] == QryEK6->EK6_CHVNFE } ) == 0
                             aAdd( aDadosLtEx , { QryEK6->EK6_CHVNFE } )
                          EndIf  
                          QryEK6->(DBSkip())
                       EndDO
                   EndIF

                   QryEK6->(DbCloseArea())
                   
                EndIf

            QryEE9->(DBSkip())
        EndDO
    EndIF
    QryEE9->(DbCloseArea())

    IF lPedido .And. !lEmbarque .AND. !Empty(cItemPV) .AND. EE8->(FieldPos("EE8_ATOCON")) > 0
        cQuery := " SELECT EE8.EE8_ATOCON,EE8.EE8_FATIT FROM " + RetSqlName("EE8") + " EE8 "
        cQuery += " WHERE EE8_FILIAL = '" + xFilial("EE8") + "' and "
        cQuery += " EE8.EE8_PEDIDO = '"+ AvKey(pPedido,"EE8_PEDIDO") + "' and"
        cQuery += " EE8.D_E_L_E_T_ <> '*'"
        cQuery += " AND EE8.EE8_FATIT = '" + Avkey(cItemPV,"EE8_FATIT") + "'"

        cQuery:= ChangeQuery(cQuery)
        DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "QryEE8", .T., .T.)
        
        lRet := !(QryEE8->(Eof()) .AND. QryEE8->(Bof())) 

        QryEE8->(DBGoTop())

        If lRet 
           If !Empty(QryEE8->EE8_ATOCON)
               AAdd(aDadosI51, {"I51", "nDraw", QryEE8->EE8_ATOCON})
           EndIF
        EndIf

        QryEE8->(DbCloseArea())
    EndIF

      /* Quando houver dados do ato concessório ou exportação indireta para o item,
         retorna no array a Dados atavés do aDadosI50.
         Quando o aDadosI50 estiver vazio, para o NFESefaz corresponde a não ter dados
         para envio da tag detExport.
         Para o rdmake NFESefaz, os tamanhos dos arrays aDadosI51 e aDadosI52 devem
         ser os mesmos, o que determinará a quantidade de detExport que deve ser gerada.
         A verificação do conteúdo (se preenchido ou vazio) será feito pelo NFeSefaz.*/
      If Len(aDadosI51) > 0 .Or. Len(aDadosI52) > 0

         /* Igualar o tamanho dos arrays */
         AjustaTam(@aDadosI51, @aDadosI52)

         AAdd(aDadosI50, aDadosI51)
         AAdd(aDadosI50, aDadosI52)
      EndIf

      AAdd(aDados,{"I50", "detExport", aDadosI50})

      /* Reestruturação do leiaute de retorno.
         IDs ZA02, ZA03 e ZA04 tem a tag ZA01 como pai.
         Os IDs ZA02 e ZA03 possuem relação de ocorrência 1-1, ou seja,
         informados uma vez e obrigatoriamente.
         O ID ZA04 possui relação de ocorrência 0-1; deve ser informado uma única
         vez porém não é obrigatório*/
      If !Empty(pProcesso) .AND. !Empty(EEC->EEC_URFDSP) .AND. ChkFile("SJ0") //LGS-27/03/2015
         cLocDespacho:= Posicione("SJ0", 1, xFilial("SJ0") + AvKey(EEC->EEC_URFDSP, "J0_COD"), "J0_DESC")
      EndIf

      AAdd(aDadosZA01, {"ZA02", "UFSaidaPais", SY9->Y9_ESTADO})
      AAdd(aDadosZA01, {"ZA03", "xLocExporta", SY9->Y9_DESCR})
      AAdd(aDadosZA01, {"ZA04","xLocDespacho", cLocDespacho})

      AAdd(aDados,{"ZA01","exporta", aDadosZA01})
      AAdd(aDados,{"BA02","refNFe" , aDadosLtEx})

   Else
      Alert(STR0232) //#STR0232->"Processo ou origem não localizado."
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return aDados

/*
Função      : AjustaTam
Parametros  : I51, I52
              Arrays com os dados do ato concessório e exportação indireta
              cAtoConcessorio: número do ato concessório do item
Retorno     : Nil
Objetivos   : Igualar os tamahos dos arrays, para serem tratados no Rdmake NFeSefaz
Autor       : Wilsimar Fabrício da Silva
Data/Hora   : 08/01/2015
*/
Static Function AjustaTam(I51, I52, cAtoConcessorio)
Default cAtoConcessorio:= ""

   While Len(I51) <> Len(I52)
      If Len(I51) > Len(I52)
         AAdd(I52, {"I52", "exportInd", ""})
      Else
         AAdd(I51, {"I51", "nDraw", cAtoConcessorio})
      EndIf
   EndDo
Return Nil
/*
Função      : AvGetNfRem
Parametros  : cNumNf - Nota fiscal gerada a partir do processo de exportação.
              cSerieNf - Série da nota fiscal.
              cClienteNF- Cliente utilizado na NF de saída (exportação)
              cLojaNF   - Loja do cliente na NF de saída (Exportação)
              cStrNFRem - String contendo as informações adicionais da nota de saída contendo os dados das notas de remessa
Retorno     : aRet - array contendo os dados necessários para a busca das informações
              do produto/ nota fiscal de entrada.
Objetivos   : Retornar a nota fiscal de entrada do item da nota fiscal de saída.
              Estrutura do array de retorno:
              {Item NF, {documento, série, fornecedor e loja}}
              onde as informações do registro 2 formam o índice 1 da tabela SD1.
Autor       : Wilsimar Fabrício da Silva
Data/Hora   : 22/01/2010
*/
Function AvGetNfRem(cNumNf, cSerieNf, cClienteNF, cLojaNF, cStrNFRem)
Local aRet        := {}
Local aArea       := GetArea()
Local aNCM        := {}
Local cChaveSF1   := ""
Local cNFRem
Local nI
Local nY
Local nPos
Local nPosNcm
Local nQtdUMSD1

Default cNumNf    := ""
Default cSerieNf  := ""
Default cClienteNF:= ""
Default cLojaNF   := ""
Default cStrNFRem := ""

Begin Sequence

   ChkFile("EYY")
   If Select("EYY") == 0
      Break
   EndIf

   If Empty(cNumNf + cSerieNf)
      Break
   EndIf

   cNumNf      := AvKey(AllTrim(cNumNf)    , "D2_DOC")
   cSerieNf    := AvKey(AllTrim(cSerieNf)  , "D2_SERIE")
   cClienteNF  := AvKey(AllTrim(cClienteNF), "D2_CLIENTE")
   cLojaNF     := AvKey(AllTrim(cLojaNF)   , "D2_LOJA")
   
   cNFRem      := GetNextALias()
   BeginSQL Alias cNFRem

      SELECT   F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA,F2_HAWB,
               EE9_PREEMB,EE9_PEDIDO,EE9_COD_I,EE9_POSIPI,EE9_SLDINI,EE9_UNIDAD,
               EYY_NFENT,EYY_SERENT,EYY_FORN,EYY_FOLOJA,EYY_UMDSD1,EYY_QUANT,EYY_D1ITEM,
               F1_EMISSAO,
               A2_CGC
      FROM        %Table:SF2% F2
      INNER JOIN  %Table:EE9% EE9 ON ( F2_HAWB     = EE9_PREEMB)
      INNER JOIN  %Table:EYY% EYY ON ( EE9_PREEMB  = EYY_PREEMB AND
                                       EE9_SEQEMB  = EYY_SEQEMB AND
                                       F2_DOC	   = EYY_NFSAI	 AND
                                       F2_SERIE	   = EYY_SERSAI)
      INNER JOIN %Table:SF1% F1  ON  ( EYY_NFENT	= F1_DOC	    AND
                                       EYY_SERENT	= F1_SERIE	 AND
                                       EYY_FORN	   = F1_FORNECE AND
                                       EYY_FOLOJA	= F1_LOJA)
      INNER JOIN %Table:SA2% A2  ON  ( F1_FORNECE	= A2_COD	    AND
                                       F1_LOJA		= A2_LOJA)
      WHERE F2_FILIAL= %xFilial:SF2%
      AND F2_DOC		= %Exp:cNumNf%
      AND F2_SERIE	= %Exp:cSerieNf%
      AND F2_CLIENTE	= %Exp:cClienteNF%
      AND F2_LOJA		= %Exp:cLojaNF%
      AND F2.%NotDel%
      AND EE9_FILIAL	= %xFilial:EE9%
      AND EE9.%NotDel%
      AND EYY_FILIAL	= %xFilial:EYY%
      AND EYY.%NotDel%
      AND F1_FILIAL  = %xFilial:SF1%
      AND F1.%NotDel%
      AND A2_FILIAL  = %xFilial:SA2%
      AND A2.%NotDel%
      ORDER BY EYY_NFENT,EYY_SERENT,EYY_FORN,EYY_FOLOJA,EYY_D1ITEM

   EndSQL

   While (cNFRem)->(!Eof())
      //Tratamento para continuar funcionando a versão antiga do Nfesefaz
      nQtdUMSD1 := AvTransUnid((cNFRem)->(EE9_UNIDAD),(cNFRem)->(EYY_UMDSD1),,(cNFRem)->(EYY_QUANT))
      aAdd(aRet,{(cNFRem)->(EYY_D1ITEM), {(cNFRem)->(EYY_NFENT), (cNFRem)->(EYY_SERENT), (cNFRem)->(EYY_FORN), (cNFRem)->(EYY_FOLOJA), {(cNFRem)->(EE9_COD_I), (cNFRem)->(EE9_POSIPI), nQtdUMSD1, (cNFRem)->(EYY_UMDSD1),(cNFRem)->(F1_EMISSAO),(cNFRem)->(A2_CGC)}}})

      //Tratamento para devolver a mensagem ja montada para o Nfesefaz
      If cChaveSF1 <> (cNFRem)->(EYY_NFENT) + (cNFRem)->(EYY_SERENT) + (cNFRem)->(EYY_FORN) + (cNFRem)->(EYY_FOLOJA)
         cChaveSF1 := (cNFRem)->(EYY_NFENT) + (cNFRem)->(EYY_SERENT) + (cNFRem)->(EYY_FORN) + (cNFRem)->(EYY_FOLOJA)
      EndIf

      nPos := aScan(aNCM, {|x| x[1] == cChaveSF1 })

      If nPos > 0
         If (nPosNcm := aScan(aNcm[nPos][6],{|x| x[1] == (cNFRem)->(EE9_POSIPI) .And. x[2] == (cNFRem)->(EYY_UMDSD1)})) > 0
            aNcm[nPos][6][nPosNcm][3] += nQtdUMSD1
         Else
            aAdd(aNcm[nPos][6],{(cNFRem)->(EE9_POSIPI),(cNFRem)->(EYY_UMDSD1),nQtdUMSD1})
         EndIf
      Else
         aAdd(aNCM,{cChaveSF1,(cNFRem)->(EYY_NFENT), (cNFRem)->(EYY_SERENT),SToD((cNFRem)->(F1_EMISSAO)),(cNFRem)->(A2_CGC),{{(cNFRem)->(EE9_POSIPI),(cNFRem)->(EYY_UMDSD1),nQtdUMSD1}}})
      EndIf

      (cNFRem)->(dbSkip())
   End
   (cNFRem)->(dbCloseArea())

   For nI:= 1 To Len(aNcm)
      cStrNFRem += "CNPJ-CPF Rem.: " + Transform(aNcm[nI][5],AvSX3("A2_CGC",AV_PICTURE)) + " / "
      cStrNFRem += "Numero NF: " + aNcm[nI][2] + " / Serie: " + aNcm[nI][3] + " / Data Emissao: " + StrZero(Day(aNcm[nI][4]),2) + '-' + StrZero(Month(aNcm[nI][4]),2) + '-' + StrZero(Year(aNcm[nI][4]),4)
      For nY := 1 To Len(aNcm[nI][6])
         cStrNFRem += " / NCM-SH: " + Transform(aNcm[nI][6][nY][1],AvSX3("EE9_POSIPI",AV_PICTURE)) + " / UM: " + aNcm[nI][6][nY][2] + " / Quantidade: " + AllTrim(Str(aNcm[nI][6][nY][3])) + " "
      Next
   Next

   RestArea(aArea)
End Sequence

Return aRet


/*------------------------------------------------------------------------------------
Funcao      : retVetNFE
Parametros  : cTipo - O tipo da nota, sendo 1=Primeira, 2=Complementar e 3=Única
Retorno     : Vetor com os dados de expecíficos da importação
Objetivos   : Preencher um vetor com os dados específicos da importação
Autor       : Anderson Soares Toledo
Data/Hora   : 14/10/2008 - 11h00
Revisao     : Guilherme Fernandes Pilan - GFP
Data/Hora   : 23/09/2013
Objetivos   : Novo Layout NFE - (Nota técnica da NFe - 2013-005)
*------------------------------------------------------------------------------------*/
Static Function retVetNFE(cTipo)
   Local aVet := {}
   Local aOrd
   Private cExIpi

   aOrd := SaveOrd({"SY5","SA4","SYQ","SYT"})
   SY5->(dbSetOrder(1))
   SA4->(dbSetOrder(1))
   SYQ->(dbSetOrder(1))
   SYT->(dbSetOrder(1))

   SYQ->(DbSeek(xFilial("SYQ")+SW6->W6_VIA_TRA))
   SYT->(DbSeek(xFilial("SYT")+SW6->W6_IMPORT))

   If cTipo == "1" .Or. cTipo == "3" .Or. cTipo == "5"
      aAdd(aVet,{"I04","NCM",SWN->WN_TEC}) //01
      aAdd(aVet,{"I15","vFrete",SWN->WN_FRETE}) //02
      aAdd(aVet,{"I16","vSeg",SWN->WN_SEGURO}) //03

      // FDR - 28/10/11 - Tratamento para envio do número da DIRE caso seja currier.
      If SW6->W6_CURRIER == "1" //04
         aAdd(aVet,{"I19","nDI",SW6->W6_DIRE})
      Else
         aAdd(aVet,{"I19","nDI",SW6->W6_DI_NUM})
      EndIf

      aAdd(aVet,{"I20","dDI",SW6->W6_DTREG_D}) //05

      If SW6->(FieldPos("W6_LOCALN")) > 0 //06
         aAdd(aVet,{"I21","xLocDesemb",SW6->W6_LOCALN})
      Else
         ConOut(STR0146 +"W6_LOCALN"+ STR0233 +"W6_LOCAL") //#STR0146->"Campo " ##STR0233->" nao existe, utilizando campo"
         aAdd(aVet,{"I21","xLocDesemb",SW6->W6_LOCALN})  // GFP - 06/10/2014
      EndIf

      If SW6->(FieldPos("W6_UFDESEM")) > 0 //07
         aAdd(aVet,{"I22","UFDesemb",SW6->W6_UFDESEM})
      Else
         ConOut(STR0146+"W6_UFDESEM"+ STR0233 +"Y9_ESTADO") //#STR0146->"Campo " ##STR0233->" nao existe, utilizando campo"
         aAdd(aVet,{"I22","UFDesemb",SY9->Y9_ESTADO})
      EndIf

      aAdd(aVet,{"I23","dDesemb",SW6->W6_DT_DESE}) //08
      aAdd(aVet,{"I24","cExportador",SW8->W8_FORN}) //09

      if (AvFlags("DUIMP") .And. SW6->W6_TIPOREG == '2') // se é DUIMP não gera o número da adição
         aAdd(aVet,{"I26","nAdicao",""}) //Mandando vazio não bagunça a ordem dos campos no vetor 
      else
         aAdd(aVet,{"I26","nAdicao",Val(SWN->WN_ADICAO)})
      EndIf   

      If SWN->(FieldPos("WN_SEQ_ADI")) > 0 //11
      // SVG  - 29/08/2011 - Quando DSI mandar apenas 01 para o sefaz não rejeitar
         If SW6->W6_DSI == "1" .Or. (SW6->W6_CURRIER == "1" .AND. Empty(SWN->WN_SEQ_ADI))//RRV - 03/10/2012 - Quando Courier ajusta o vetor com nSeqAdi igual a "01" para o sefaz não rejeitar.
            aAdd(aVet,{"I27","nSeqAdi",01})
         Else
            aAdd(aVet,{"I27","nSeqAdi",Val(SWN->WN_SEQ_ADI)})
         EndIf
      Else
         ConOut(STR0146+"WN_SEQ_ADI"+ STR0233 +"W8_SEQ_ADI")  //#STR0146->"Campo " ##STR0233->" nao existe, utilizando campo"
         // SVG  - 29/08/2011 - Quando DSI mandar apenas 01 para o sefaz não rejeitar
         If SW6->W6_DSI == "1" .Or. SW6->W6_CURRIER == "1" //RRV - 03/10/2012 - Quando Courier ajusta o vetor com nSeqAdi igual a "01" para o sefaz não rejeitar.
            aAdd(aVet,{"I27","nSeqAdi",01})
         Else
            aAdd(aVet,{"I27","nSeqAdi",Val(SW8->W8_SEQ_ADI)})
         EndIf
      EndIf

      aAdd(aVet,{"I28","cFabricante",SW8->W8_FABR}) //12

      If SWN->(FieldPos("WN_DESCONI")) > 0 //13
         aAdd(aVet,{"I29","vDescDI",SWN->WN_DESCONI})
      Else
         ConOut(STR0146+"WN_DESCONI"+STR0234) //#STR0146->"Campo " ##STR0234->" nao existe"
         aAdd(aVet,{"I29","vDescDI",0})  // GFP - 06/10/2014
      EndIf

      If SWN->(FieldPos("WN_PREDICM")) > 0 //14
         aAdd(aVet,{"N14","pRedBC",SWN->WN_PREDICM})
      Else
         ConOut(STR0146+"WN_PREDICM"+STR0234) //#STR0146->"Campo " ##STR0234->" nao existe"
         aAdd(aVet,{"N14","pRedBC",0})  // GFP - 06/10/2014
      EndIf

      If SWN->(FieldPos("WN_QTUIPI")) > 0 //15
         aAdd(aVet,{"O11","qUnid",SWN->WN_QTUIPI})
      Else
         ConOut(STR0146+"WN_QTUIPI"+STR0234) //#STR0146->"Campo " ##STR0234->" nao existe"
         aAdd(aVet,{"O11","qUnid",0})  // GFP - 06/10/2014
      EndIf

      If SWN->(FieldPos("WN_ALUIPI")) > 0 //16
         aAdd(aVet,{"O12","vUnid",SWN->WN_ALUIPI})
      Else
         ConOut(STR0146+"WN_ALUIPI"+STR0234) //#STR0146->"Campo " ##STR0234->" nao existe"
         aAdd(aVet,{"O12","vUnid",0})  // GFP - 06/10/2014
      EndIf

      aAdd(aVet,{"P02","vBC", SWN->WN_CIF}) //17

      If SWN->(FieldPos("WN_DESPADU")) > 0 //18
         aAdd(aVet,{"P03","vDespAdu",SWN->WN_DESPADU})
      Else
         ConOut(STR0146+"WN_DESPADU"+STR0234) //#STR0146->"Campo " ##STR0234->" nao existe"
         aAdd(aVet,{"P03","vDespAdu",0})  // GFP - 06/10/2014
      EndIf

      aAdd(aVet,{"P04","vII",SWN->WN_IIVAL}) //19

      If SWN->(FieldPos("WN_VLRIOF")) > 0 //20
         //aAdd(aVet,{"P05","vIOF",SWN->WN_QTUPIS})
         aAdd(aVet,{"P05","vIOF",SWN->WN_VLRIOF})
      Else
         ConOut(STR0146+"WN_VLRIOF"+STR0234) //#STR0146->"Campo " ##STR0234->" nao existe"
         aAdd(aVet,{"P05","vIOF",0})  // GFP - 06/10/2014
      EndIf

      If SWN->(FieldPos("WN_QTUPIS")) > 0 //21
         aAdd(aVet,{"Q10","qBCProd",SWN->WN_QTUPIS})
      Else
         ConOut(STR0146+"WN_QTUPIS"+STR0234) //#STR0146->"Campo " ##STR0234->" nao existe"
         aAdd(aVet,{"Q10","qBCProd",0})  // GFP - 06/10/2014
      EndIf

      If SWN->(FieldPos("WN_VLUPIS")) > 0 //22
         aAdd(aVet,{"Q11","vAliqProd",SWN->WN_VLUPIS})
      Else
         ConOut(STR0146+"WN_VLUPIS"+STR0234) //#STR0146->"Campo " ##STR0234->" nao existe"
         aAdd(aVet,{"Q11","vAliqProd",0})  // GFP - 06/10/2014
      EndIf

      If SWN->(FieldPos("WN_QTUCOF")) > 0 //23
         aAdd(aVet,{"S09","qBCProd",SWN->WN_QTUCOF})
      Else
         ConOut(STR0146+"WN_QTUCOF"+STR0234) //#STR0146->"Campo " ##STR0234->" nao existe"
         aAdd(aVet,{"S09","qBCProd",0})  // GFP - 06/10/2014
      EndIf

      If SWN->(FieldPos("WN_VLUCOF")) > 0 //24                        //NCF - 14/08/09 - Correção do X3_CAMPO
         aAdd(aVet,{"S10","vAliqProd",SWN->WN_VLUCOF})
      Else
         ConOut(STR0146+"WN_VLUCOF"+STR0234) //#STR0146->"Campo " ##STR0234->" nao existe"
         aAdd(aVet,{"S10","vAliqProd",0})  // GFP - 06/10/2014
      EndIf

      IF SA4->(dbSeek(xFilial("SA4")+SW6->W6_TRANS)) //25, 26, 27, 28, 29, 30
         aAdd(aVet,{"X04","CNPJ",SA4->A4_CGC}) //25
         aAdd(aVet,{"X06","xNome",SA4->A4_NOME}) //26
         aAdd(aVet,{"X07","IE",SA4->A4_INSEST}) //27
         aAdd(aVet,{"X08","xEnder",SA4->A4_END}) //28
         aAdd(aVet,{"X09","xMun",SA4->A4_MUN}) //29
         aAdd(aVet,{"X10","UF",SA4->A4_EST}) //30
      ELSE
         ConOut("Código do transportador não localizado")
         aAdd(aVet,{"X04","CNPJ",""})   // GFP - 06/10/2014
         aAdd(aVet,{"X06","xNome",""})  // GFP - 06/10/2014
         aAdd(aVet,{"X07","IE",""})     // GFP - 06/10/2014
         aAdd(aVet,{"X08","xEnder",""}) // GFP - 06/10/2014
         aAdd(aVet,{"X09","xMun",""})   // GFP - 06/10/2014
         aAdd(aVet,{"X10","UF",""})     // GFP - 06/10/2014
      ENDIF

      If SY5->(dbSeek(xFilial("SY5")+AvKey(SW6->W6_DESP,"Y5_COD"))) //31
         aAdd(aVet,{"XXX","emaildesp",SY5->Y5_EMAIL})
      Else
         ConOut("Código do despachante não localizado")
         aAdd(aVet,{"XXX","emaildesp",""})  // GFP - 06/10/2014
      EndIf

      //TRP - 23/03/2010 - Inclusão dos campos House e Código do Despachante no array.
      aAdd(aVet,{"HOU","house",SW6->W6_HOUSE}) //32
      aAdd(aVet,{"DES","cDesp",SW6->W6_DESP}) //33

      If SWN->(FieldPos("WN_AC")) # 0 //34
         aAdd(aVet,{"I29a","nDraw",SWN->WN_AC})
      Else
         ConOut(STR0146+"WN_AC"+STR0234) //#STR0146->"Campo " ##STR0234->" nao existe"
         aAdd(aVet,{"I29a","nDraw",""})  // GFP - 06/10/2014
      EndIf

      If SWN->(FieldPos("WN_NVE")) # 0 //35
         aAdd(aVet,{"105a","NVE",RetVetNVE()})  // GFP - 16/06/2014
      Else
         ConOut(STR0146+"WN_NVE"+STR0234) //#STR0146->"Campo " ##STR0234->" nao existe"
         aAdd(aVet,{"105a","NVE",{}})  // GFP - 06/10/2014
      EndIf

      aAdd(aVet,{"I23a","tpViaTransp",AvViaTrans(SYQ->YQ_COD_DI)}) //MCF - 30/01/2015 //36

      If Left(SYQ->YQ_COD_DI,1) == "1"  // Maritimo //37
         If SWN->(FieldPos("WN_AFRMM")) # 0
            aAdd(aVet,{"I23b","vAFRMM",SWN->WN_AFRMM})
         Else
            ConOut(STR0146+"WN_AFRMM"+STR0234) //#STR0146->"Campo " ##STR0234->" nao existe"
            aAdd(aVet,{"I23b","vAFRMM",0})  // GFP - 06/10/2014
         EndIf
      Else
         aAdd(aVet,{"I23b","vAFRMM",0})  // GFP - 23/10/2014
      EndIf

      If SW6->W6_IMPCO $ cSim  // Importação por Conta e Ordem //38, 39, 40
         aAdd(aVet,{"I23c","tpIntermedio",2}) //38
         aAdd(aVet,{"I23d","CNPJ",SYT->YT_CGC}) //39
         aAdd(aVet,{"I23e","UFTerceiro",Alltrim(SYT->YT_ESTADO)}) //40
      ElseIf SW6->W6_IMPENC $ cSim  // Encomenda
         aAdd(aVet,{"I23c","tpIntermedio",3})
         aAdd(aVet,{"I23d","CNPJ",SYT->YT_CGC})
         aAdd(aVet,{"I23e","UFTerceiro",Alltrim(SYT->YT_ESTADO)})
      Else
         aAdd(aVet,{"I23c","tpIntermedio",1})
         aAdd(aVet,{"I23d","CNPJ",""})        // GFP - 06/10/2014
         aAdd(aVet,{"I23e","UFTerceiro",""})  // GFP - 06/10/2014
      EndIf

      //MFR 07/07/2021 OSSME-5993 //MFR 29/09/2021 OSSME-6196
      If EIJ->(DbSeek(xFilial("EIJ")+SWN->WN_HAWB+SWN->WN_ADICAO)) .And. !Empty(EIJ->EIJ_EX_IPI) //41
         cExIPI := EIJ->EIJ_EX_IPI 
      else
         cExIPI := ""
      Endif
      
      IF EasyEntryPoint("AVGERAL")
         Execblock("AVGERAL",.F.,.F.,"GETNFEIMP") //permite atualizar o campo cExIPI
      EndIf

      aAdd(aVet,{"I06","EXTIPI",cExIPI}) 

   Else  // cTipo == "2" - NF Complementar
      aAdd(aVet,{"I04","NCM",SWN->WN_TEC})
      // FDR - 28/10/11 - Tratamento para envio do número da DIRE caso seja currier.
      If SW6->W6_CURRIER == "1"
         aAdd(aVet,{"I19","nDI",SW6->W6_DIRE})
      Else
         aAdd(aVet,{"I19","nDI",SW6->W6_DI_NUM})
      EndIf
      aAdd(aVet,{"I20","dDI",SW6->W6_DTREG_D})
      aAdd(aVet,{"I21","xLocDesemb",SW6->W6_LOCALN})
      If SW6->(FieldPos("W6_UFDESEM")) > 0
         aAdd(aVet,{"I22","UFDesemb",SW6->W6_UFDESEM})
      Else
         ConOut("Campo W6_UFDESEM não existe, utilizando campo Y9_ESTADO")
         aAdd(aVet,{"I22","UFDesemb",SY9->Y9_ESTADO})
      EndIf
      aAdd(aVet,{"I23","dDesemb",SW6->W6_DT_DESE})
      aAdd(aVet,{"I24","cExportador",SW8->W8_FORN})
      if (AvFlags("DUIMP") .And. SW6->W6_TIPOREG == '2') // se é DUIMP não gera o número da adição
         aAdd(aVet,{"I26","nAdicao",""}) //Mandando vazio não bagunça a ordem dos campos no vetor 
      else
         aAdd(aVet,{"I26","nAdicao",Val(SWN->WN_ADICAO)})
      EndIf   
      // SVG  - 29/08/2011 - Quando DSI mandar apenas 01 para o sefaz não rejeitar
      If SW6->W6_DSI == "1" .Or. (SW6->W6_CURRIER == "1" .AND. Empty(SWN->WN_SEQ_ADI))//RRV - 03/10/2012 - Quando Courier ajusta o vetor com nSeqAdi igual a "01" para o sefaz não rejeitar.
         aAdd(aVet,{"I27","nSeqAdi",01})
      Else
         aAdd(aVet,{"I27","nSeqAdi",Val(SWN->WN_SEQ_ADI)})
      EndIf
      aAdd(aVet,{"I28","cFabricante",SW8->W8_FABR})
      If SY5->(dbSeek(xFilial("SY5")+AvKey(SW6->W6_DESP,"Y5_COD")))
         aAdd(aVet,{"XXX","emaildesp",SY5->Y5_EMAIL})
      Else
         ConOut("Código do despachante não localizado")
         aAdd(aVet,{"XXX","emaildesp",""})  // GFP - 06/10/2014
      EndIf
     //TRP - 23/03/2010 - Inclusão dos campos House e Código do Despachante no array.
      aAdd(aVet,{"HOU","house",SW6->W6_HOUSE})
      aAdd(aVet,{"DES","cDesp",SW6->W6_DESP})

      If cTipo == "2"
         aAdd(aVet,{"P04","vII",0}) //TDF - 04/01/13 - Quando nota complementar o II sempre é igual a 0 e a tag de II deve sempre ser enviada ao NFESEFAZ
      Else
         aAdd(aVet,{"P04","vII",SWN->WN_IIVAL})
      EndIf

	  aAdd(aVet,{"P02","vBC", SWN->WN_CIF})
      If SWN->(FieldPos("WN_VLRIOF")) > 0
         //aAdd(aVet,{"P05","vIOF",SWN->WN_QTUPIS})
         aAdd(aVet,{"P05","vIOF",SWN->WN_VLRIOF})
      Else
         ConOut(STR0146+"WN_VLRIOF"+STR0234)
         aAdd(aVet,{"P05","vIOF",0})  // GFP - 06/10/2014
      EndIf
      If SWN->(FieldPos("WN_NVE")) # 0
         aAdd(aVet,{"105a","NVE",RetVetNVE()})  // GFP - 06/10/2014
      Else
         ConOut(STR0146+"WN_NVE"+STR0234) //#STR0146->"Campo " ##STR0234->" nao existe"
         aAdd(aVet,{"105a","NVE",{}})   // GFP - 06/10/2014
      EndIf
      aAdd(aVet,{"I23a","tpViaTransp",CTON(cValToChar(Left(SYQ->YQ_COD_DI,1)),16)}) //MCF - 29/01/2015
      If Left(SYQ->YQ_COD_DI,1) == "1"  // Maritimo
         If SWN->(FieldPos("WN_AFRMM")) # 0
            aAdd(aVet,{"I23b","vAFRMM",SWN->WN_AFRMM})
         Else
            ConOut(STR0146+"WN_AFRMM"+STR0234) //#STR0146->"Campo " ##STR0234->" nao existe"
            aAdd(aVet,{"I23b","vAFRMM",0})  // GFP - 06/10/2014
         EndIf
      Else
         aAdd(aVet,{"I23b","vAFRMM",0})  // FDR - 17/12/2014
      EndIf
      If SW6->W6_IMPCO $ cSim  // Importação por Conta e Ordem
         aAdd(aVet,{"I23c","tpIntermedio",2})
         aAdd(aVet,{"I23d","CNPJ",SYT->YT_CGC})
         aAdd(aVet,{"I23e","UFTerceiro",Alltrim(SYT->YT_ESTADO)})
      ElseIf SW6->W6_IMPENC $ cSim  // Encomenda
         aAdd(aVet,{"I23c","tpIntermedio",3})
         aAdd(aVet,{"I23d","CNPJ",SYT->YT_CGC})
         aAdd(aVet,{"I23e","UFTerceiro",Alltrim(SYT->YT_ESTADO)})
      Else
         aAdd(aVet,{"I23c","tpIntermedio",1})
         aAdd(aVet,{"I23d","CNPJ",""})         // GFP - 06/10/2014
         aAdd(aVet,{"I23e","UFTerceiro",""})   // GFP - 06/10/2014
      EndIf
      If SWN->(FieldPos("WN_AC")) # 0
         aAdd(aVet,{"I29a","nDraw",SWN->WN_AC})
      Else
         ConOut(STR0146+"WN_AC"+STR0234) //#STR0146->"Campo " ##STR0234->" nao existe"
         aAdd(aVet,{"I29a","nDraw",""})  // GFP - 06/10/2014
      EndIf
   EndIf

   RestOrd(aOrd,.T.)

return aVet

/*------------------------------------------------------------------------------------
Funcao      : AvExistHelp
Parametros  : cHelp - Nome do Help (Ex. AVG000015), lSolução - Verifica Problema ou solução, por Default verifica os dois.
Retorno     : Verdadeiro, caso exista o help. Falso, caso não exista o help.
Objetivos   : Verificar a existencia de um determinado help
Autor       : Rodrigo Mendes
Data/Hora   : 02/06/2009 - 11h00
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Function AvExistHelp(cHelp, lSolucao)

Local cArqHlp := RetHlpFile()

If ValType(lSolucao) <> "U"
   If lSolucao
      cHelp := 'S' + AllTrim(cHelp) //Soluçao
   Else
      cHelp := 'P' + AllTrim(cHelp) //Problema
   EndIf

   lRet := (SPF_SEEK(cArqHlp, cHelp, 1 ) > 0) // Procura o arquivo.
Else
   If Left(cHelp,3) == "AVG" //Help AVG (EX.AVG000015)
      lRet := (SPF_SEEK(cArqHlp, 'P' + AllTrim(cHelp), 1 ) > 0) .AND. (SPF_SEEK(cArqHlp, 'S' + AllTrim(cHelp), 1 ) > 0) // verifica tanto Problema quanto solução.
   Else                      //Help de campo
      lRet := (SPF_SEEK(cArqHlp, 'P' + AllTrim(cHelp), 1 ) > 0)
   EndIf
EndIf

Return lRet

/*
Funcao     : AvFlags(cNmRotina).
Parametros : cNmRotina - Nome da rotina.
Retorno    : .t./.f.
Objetivos  : Set da flag de controle para a rotina especificada.
Autor      : Elizabete de Oliveira Brito
Data       : 31/07/09
*/
*--------------------------*
Function AvFlags(cNmRotina)
*--------------------------*
Local lRet:=.f., aCampos
Local i:=0
Local cArea
Local nRec
Local nOrder
Local aOrd := {} //WHRS TE-4943 507360 / MTRADE-599 - Erro ao visualizar cadastro de empresa
Local aCamposFFC:={}

//Troca das statics por EasyBuffer, mantidas as variaveis apenas por compatibilidade com código existente
//Não criar novas variaveis
Local lNovoCambio  // Tratamento para nova legislação e regulamentação câmbial - AAF - 08/02/2008
Local lGradePrd    // Tratamento de grade de produtos - ER - 28/10/2009
Local lIntItau//
Local lLojaEIC     // Tratamento de loja do Fornecedor no EIC
Local lIntEFFxFIN
Local lDemurrage //FSM - Nova rotina para tratamento de demurrage por container
Local lOperEsp//Operacoes Especiais
Local lCompPrd  //Dados Complementares Produtos
Local lWorkflow  // GFP - Tratamento de Workflow
Local lCompNac   // GFP - Tratamento de Compras Nacionais em Drawback regime Isenção - EDC
Local lSeqMi  //AOM - Verifica o tratamento de sequencia siscomex para Compras Nacionais
Local lIndED9 // BAK - Verifica indice da tabela ED9
Local lIndEDD // BAK - Verifica indice da tabela EDD
Local lEECLOGIX
Local lPREPED_EECLOGIX
Local lNFS_DESVINC
Local lDiOri
Local lServVenda //RRC - Tratamento para Serviços de Venda (Pedido e Registro) baseado no Siscoserv
Local lServAquis //RRC - Tratamento para Serviços de Aquisição (Pedido e Registro) baseado no Siscoserv
Local lCadSiscsv //NCF - Tratamento para Cadastros baseados no Siscoserv
Local lIntPR
Local lIntPRE
Local lEIC_EAI
Local lESS_EAI
Local lEAI_pgant_inv_nf
Local lCambFre  // GFP - Tratamento de Cambio Frete
Local lCambSeg  // GFP - Tratamento de Cambio Seguro
Local lLibAutCred
Local lAcrDcrCam
Local lCAPMovExt
Local lIntDspCom
Local lInvAntGFI
Local lRatFrSgPO
Local lFim_Especifico_Exp
Local lAdtForEAI //THTS - 21/03/2017 - Tratamento para adiantamento de fornecedor com integracao Logix
Local lDecUniExp //NCF - 03/05/2017 - Declaração Única de Exportação
Local lDecUniEx2 //EJA - 09/02/2018 - Verifica se possui o pacote 2 da DUE
Local lDecUniEx3 //MPG - 28/03/2018 - Verifica se possui o pacote 3 da DUE
Local lDecUnEx31 //MPG - 27/11/2018 - Verifica se possui o pacote 3 da DUE
Local lDestaq     //MPG - 27/11/2018 - Verifica se possui o pacote 3 da DUE
Local lNFTBasImp //THTS - 09/01/2018 - Nota fiscal de transferência com despesas base de impostos que não compoe total da nota
Local lEICFFCEAI //THTS - 23/01/2018 - Integração da Liquidação de FFC com o LOGIX
Local lFim_Espc2
Local lSuframa
Local lNveCadProd //NCF - 08/05/2018 - N.V.E por Produto
Local lNFSLoteExp //NCF - 27/11/2018
Local lCpoDtFbLt  //NCF - 27/02/2019
Local lFECPDIEle  //NCF - 02/05/2019
Local lStatusDUE  //NCF - 07/10/2020
Local lBaseICMDIE //NCF - 21/10/2020
Local lFormLPCO   //MPG - 11/11/2020
Local lTratComis //THTS - 17/02/2021
Local lDuimp
Local lFECPDifer  //NCF - 22/09/2021

Begin Sequence

   If !OrigChamada()
      lRet:= .F.
      Break
   EndIf

   cNmRotina := Upper(AllTrim(cNmRotina))
   cArea := Select()
   nRec  := SX3->(RecNo())
   nOrder:= SX3->(IndexOrd())

   If EasyGetBuffers("AVFLAGS",cFilAnt+','+cNmRotina,@lRet)
      break
   EndIf

   Do Case
      Case cNmRotina == "INTITAU"

         If ValType(lIntItau) = "U"
            lIntItau := EasyGParam("MV_INTITAU",,.F.)

            aTabelas := { "EXL", "SYF"}
            aIndices := {}

            aCampos  := { {"EXL", "EXL_TPREM" },;
                        {"EXL", "EXL_PRACA" },;
                        {"EXL", "EXL_TPVENC"},;
                        {"EXL", "EXL_DESPBR"},;
                        {"EXL", "EXL_DESPEX"},;
                        {"EXL", "EXL_CODCOU"},;
                        {"EXL", "EXL_NOMCOU"},;
                        {"EXL", "EXL_CONCOU"},;
                        {"EXL", "EXL_SLIPCO"},;
                        {"EXL", "EXL_SLIPDT"},;
                        {"SYF", "YF_INTITAU"} ;
                        }

            aFunctions := {}

            //Verifica existencia de tabelas
            SX2->( dbSetOrder(1) )
            For i := 1 to Len(aTabelas)
               lIntItau := lIntItau .AND. SX2->(dbSeek(aTabelas[i])) .AND. ChkFile(aTabelas[i])
            Next

            //Verifica existencia de indices
            SIX->( dbSetOrder(1) )
            For i := 1 to Len(aIndices)
               lIntItau := lIntItau .AND. SIX->(dbSeek(aIndices[i][1]+aIndices[i][2]))
            Next

            //Verifica existencia de campos
            SX3->( dbSetOrder(2) )
            For i := 1 to Len(aCampos)
               lIntItau := lIntItau .AND. SX3->(dbSeek(aCampos[i][2])) .AND. ( SX3->X3_CONTEXT == "V" .OR. (aCampos[i][1])->(FieldPos(aCampos[i][2]) > 0) )
            Next

            //Verifica existencia das funções no repositório
            For i := 1 to Len(aFunctions)
               lIntItau := lIntItau .AND. FindFunction(aFunctions[i])
            Next

         End IF

         lRet := lIntItau

         SX3->(DbSetOrder(nOrder))
         SX3->(DbGoTo(nRec))
      Case cNmRotina == "LOJA-EIC"
         //Verifica todos os campos Loja necessários
         If ValType(lLojaEIC) <> "L"
            lLojaEIC := .T.
         EndIf
         lRet := lLojaEIC
      Case cNmRotina == "CAMBIO_EXT"

         If ValType(lNovoCambio) = "U"
            lNovoCambio := EasyGParam("MV_AVG0144",,.F.) .AND. !Empty(EasyGParam("MV_AVG0145",,"")) .And. !AvFlags("EIC_EAI") .And. !AvFlags("EEC_LOGIX")

            aTabelas := { "EYQ", "EYS", "EYR", "EYV", "EYT"}
            aIndices := { {"EYQ","1"}, {"EYS","1"}, {"EYR","1"}, {"EYV","1"}, {"EYT","1"}, {"EEQ","B"} }

            aCampos  := { {"EYQ","EYQ_FILIAL"},; //EYQ
                        {"EYS","EYS_FILIAL"},; //EYS
                        {"EYR","EYR_FILIAL"},; //EYR
                        {"EYV","EYV_FILIAL"},; //EYV
                        {"EYT","EYT_FILIAL"},; //EYT
                        {"SA6","A6_MOEEASY"},; //SA6
                        {"SA6","A6_CONEXP "},;
                        {"EEQ","EEQ_CONTMV"},; //EEQ
                        {"EEQ","EEQ_BCOEXT"},; // {"EEQ","EEQ_BCOCR "},; // BAK - 27/09/2012
                        {"EEQ","EEQ_AGCEXT"},; // {"EEQ","EEQ_AGCR  "},; // BAK - 27/09/2012
                        {"EEQ","EEQ_CNTEXT"},; // {"EEQ","EEQ_CCCRED"},; // BAK - 27/09/2012
                        {"EEQ","EEQ_NBCEXT"},; // {"EEQ","EEQ_NBCOCR"},; // BAK - 27/09/2012
                        {"EEQ","EEQ_INTERN"},;
                        {"SWB","WB_TIPOPAG"} } //SWB

            aFunctions := { "EECAD100", "EECAD101", "EECAD102", "EECAD103", "EECAD104", "EECAD105" }

            //Verifica existencia de tabelas
            SX2->( dbSetOrder(1) )
            For i := 1 to Len(aTabelas)
               lNovoCambio := lNovoCambio .AND. SX2->(dbSeek(aTabelas[i])) .AND. ChkFile(aTabelas[i])
            Next

            //Verifica existencia de indices
            SIX->( dbSetOrder(1) )
            For i := 1 to Len(aIndices)
               lNovoCambio := lNovoCambio .AND. SIX->(dbSeek(aIndices[i][1]+aIndices[i][2]))
            Next

            //Verifica existencia de campos
            SX3->( dbSetOrder(2) )
            For i := 1 to Len(aCampos)
               lNovoCambio := lNovoCambio .AND. SX3->(dbSeek(aCampos[i][2])) .AND. ( SX3->X3_CONTEXT == "V" .OR. (aCampos[i][1])->(FieldPos(aCampos[i][2]) > 0) )
            Next

            //Verifica existencia das funções no repositório
            For i := 1 to Len(aFunctions)
               lNovoCambio := lNovoCambio .AND. FindFunction(aFunctions[i])
            Next
         EndIf
         lRet := lNovoCambio

      Case cNmRotina == "GRADE"

         If ValType(lGradePrd) == "U"

            lGradePrd := .T.

            If !FindFunction("MaGrade")
               lGradePrd := .F.
               Break
            EndIf

            If !FindFunction("MsMatGrade")
               lGradePrd := .F.
               Break
            EndIf

            lGradePrd := MaGrade()

            If lGradePrd .and. !IsAtNewGrd()
               lGradePrd := .F.
               Break
            EndIf
         EndIf

         lRet := lGradePrd

         Case cNmRotina == "AVINT_CAMBIO_EIC" //Integracao de titulos de cambio
         aFuncoes := {"EICINTEI17"}
         aCampos  := {{'SWB','WB_TITERP' },{'SWB','WB_TITERPV'},;
                     {'SW9','W9_TITERP' },{'EW4','EW4_TITERP'}}
         lRET:= AvIsMvOn({"MV_EICFI04",.T.}) .AND. AvFlags("AVINTEG")         ;
                                             .AND. AvExisteFunc(aFuncoes)     ;
                                             .AND. AvExisteCampo(aCampos)

      Case cNmRotina == "AVINT_PRE_EIC" //Integracao de provisorios embarque
         /* Jacomo Lisa 30/06/2014 - Alterado para a nova integração do Logix
         lRet := AvIsMvOn({"MV_EICFI03",.T.}) .AND. AvFlags("AVINTEG") //.AND. AvFlags("AVINT_PR_EIC") - NOPADO POR AOM - 20/04/2012 - Os Titulos do embarque podem ser gerados independentemente do Pedido
         */
         If ValType(lIntPRE) <> "L"
            lIntPRE:= .F.
            IF AvIsMvOn({"MV_EICFI03",.T.}) .AND. AvFlags("AVINTEG")
               lIntPRE := .T.
            ELSEIF AvFlags("EIC_EAI") .AND. AvIsMvOn({"MV_EASYFDI","N"})
               lIntPRE := .T.
            ENDIF
         EndIf
         lRet:= lIntPRE

      Case cNmRotina == "AVINT_PR_EIC" //Integracao de provisorios pedido

         If ValType(lIntPR) <> "L"
            lIntPR:= .F.
            IF AvIsMvOn({"MV_EICFI02",.T.}) .AND. AvFlags("AVINTEG")
               lIntPR := .T.
            ELSEIF AvFlags("EIC_EAI") .AND. AvIsMvOn({"MV_EASYFPO","N"})
               lIntPR := .T.
            ENDIF
         EndIf
            /* Jacomo Lisa 30/06/2014 - Alterado para a nova integração do Logix
            lRet := AvIsMvOn({"MV_EICFI02",.F.}) .AND. AvFlags("AVINTEG")
            */
         lRet:= lIntPR
      Case cNmRotina == "AVINT_FINANCEIRO_EIC" //Integracao de despesas e numerario
         aFuncAvInt := {"AvIntDesp"}
         aTableAvInt := {"SWD","SYT","SYB"}
         aIndAvInt := {{"SWD","1"},{"SWD","6"},{"SYT","1"},{"SYB","1"}}
         aCposAvInt  := {{'SYB','YB_FGTITUL'},{'SYB','YB_FGDEBCC'},;
                     {'SYT','YT_BANCO'  },{'SYT','YT_AGENCIA'},{'SYT','YT_CONTA'  },;
                     {'SWD','WD_TITERP' },{'SWD','WD_FGTITUL'},{'SWD','WD_FGDEBCC'},{'SWD','WD_BANCO'  },;
                     {'SWD','WD_AGENCIA'},{'SWD','WD_CONTA'  },{'SWD','WD_VALOR_A'},{'SWD','WD_CTRLERP'},;
                     {'SWD','WD_LINHA'},{'SWD','WD_BAN_REC'  },{'SWD','WD_AGE_REC'},{'SWD','WD_CON_REC'}}
         lRet := AvFlags("AVINTEG") .AND. AvExisteFunc(aFuncAvInt) .AND. AvExisteTab(aTableAvInt) .AND. AvExisteInd(aIndAvInt) .AND. AvExisteCampo(aCposAvInt)

      Case cNmRotina == "AVINTEG"
         aFuncAvInt := {"AvIntegMan","AvIntegLog","AvIntegJob","AvIntegHis","ProcInteg","AvEmailClass"}
         aTableAvInt := {"E00","E01","E02","E03","E04","E05","E06"}
         aIndAvInt := {{"E00","1"},{"E01","1"},{"E02","1"},{"E03","1"},{"E04","1"},{"E04","2"},;
                     {"E04","3"},{"E05","1"},{"E05","2"},{"E05","3"},{"E06","1"}}

         lRet := AvExisteFunc(aFuncAvInt) .AND. AvExisteTab(aTableAvInt) .AND. AvExisteInd(aIndAvInt)

      Case cNmRotina == "SIGAEFF_SIGAFIN" //Integracao de despesas e numerario
         If ValType(lIntEFFxFIN) <> "L"

            aFuncoes := { "EFFEX400", "EFFEX401", "EFFEX101", "EFFEX102", "AVOBJECT" }

            aCampos  := { {'EF1','EF1_TITFIN'},;
                        {'EF3','EF3_TITFIN'},;
                        {'EF3','EF3_NUMTIT'},;
                        {'EF3','EF3_PARTIT'},;
                        {'EC6','EC6_NATFIN'},;
                        {'EC6','EC6_TPTIT' },;
                        {'EC6','EC6_MOTBX' },;
                        {'EF7','EF7_NATFIN'},;
                        {'EF7','EF7_NUMERA'},;
                        {'EF7','EF7_MOTBXI'},;
                        {'EF7','EF7_MOTBXP'},;
                        {'EF7','EF7_MOTBXJ'},;
                        {'EF8','EF8_FORN  '},;
                        {'EF8','EF8_LOJA  '} }

            lIntEFFxFIN := AvIsMvOn({"MV_EFF_FIN",.F.}) .AND. AvExisteCampo(aCampos) .AND. AvExisteFunc(aFuncoes)
         EndIf

         lRet := lIntEFFxFIN
      Case cNmRotina == "WORKFLOW"          // WorkFlow EIC / EEC
         If ValType(lWorkFlow) == "U"
            aCampos := {  {'EJ7', 'EJ7_COD'},;
                        {'EJ8', 'EJ8_ID' }  }    // Verifica existencia da tabela EJ7 e EJ8

            lWorkFlow := AvIsMvOn({"MV_EASYWF",.F.}) .AND. AvExisteCampo(aCampos)
         EndIf

         lRet := lWorkFlow


      Case Upper(cNmRotina) == "DEMURRAGE" //Nova rotina para tratamento de demurrage por container FSM - 21/02/11

         If ValType(lDemurrage) <> "L"

            aTable := {"EWU","EWV","EJ5","EJ6"}
            aFunc  := {"EasyDM400"}

            lDemurrage := AvIsMvOn({"MV_AVG0202",.F.}) .And. AvExisteTab(aTable) .And. AvExisteFunc(aFunc)

         EndIf

         lRet := lDemurrage

      Case cNmRotina == "OPERACAO_ESPECIAL"

         If ValType(lOperEsp) == "U"

            #IfDef TOP

               lOperEsp := !AvFlags("EEC_LOGIX") //AAF 05/08/2015 - Não é possível utilizar integracao de recebimendo do Logix (EAI) e criar work no TOP (tem transacao em aberto).
               lOperEsp := lOperEsp .And. EasyGParam("MV_OPERESP",, .F.)

            #Else

               lOperEsp := .F.     // GFP - 24/04/2012 - Operação Especial funciona em TOP pois nas verificações internas existem Query.

            #EndIf

         EndIf

         lRet :=  lOperEsp

      Case cNmRotina == "DADOS COMPL. PRODUTOS"

         If ValType(lCompPrd) == "U"
            aTable   := {"EYJ"} //AAF 25/04/2014
            lCompPrd := FindFunction("EYJCOMP") .And. AvExisteTab(aTable)//AAF 25/04/2014 AvExisteCampo(aCampos)

         EndIf


         lRet := lCompPrd
      Case cNmRotina == "CONTROLE_CADASTROS_SISCOSERV"
         If ValType(lCadSiscsv) == "U"
            aTable   := {"EL0"}
            aFunc    := {"EasyNBS"}
            lCadSiscsv := AvExisteFunc(aFunc) .And. AvExisteTab(aTable)//AAF 25/04/2014 - Não validar campos do módulo para os cadastros//FSY - 17/03/2014
         EndIf
         lRet := lCadSiscsv

      Case cNmRotina == "CONTROLE_SERVICOS_AQUISICAO"  //RRC - 17/08/2012 - Tratamento para Serviços de Aquisição (Pedido e Registro) baseado no Siscoserv

         If ValType(lServAquis) == "U"
            lServAquis := .T.
         EndIf
         lRet := lServAquis

      Case cNmRotina == "CONTROLE_SERVICOS_VENDA" //RRC - 17/08/2012 - Tratamento para Serviços de Venda (Pedido e Registro) baseado no Siscoserv

         If ValType(lServVenda) == "U"
            lServVenda := .T.
         EndIf
         lRet := lServVenda

      Case cNmRotina == "COMPRAS NACIONAIS"
         If ValType(lCompNac) == "U"
            aTable   := {"ED8"}
            aCampos  := { {"ED8", "ED8_NF"     },;
                        {"ED8", "ED8_SERIE"  },;      // Verifica existencia da tabela ED8
                        {"ED8", "ED8_FORN"   },;
                        {"ED8", "ED8_LOJA"   },;
                        {"ED8", "ED8_PEDIDO" } }

            lCompNac := AvExisteTab(aTable) .AND. AvExisteCampo(aCampos)
         EndIf

         lRet := lCompNac


      Case cNmRotina == "SEQMI"

         If ValType(lSeqMi) == "U"
            aTable   := {"ED0","ED2","ED4","ED8","EDD","EDH"}
            aCampos  := { {"ED4", "ED4_SEQMI"},;
                        {"ED8", "ED8_SEQMI"},;
                        {"EDD", "EDD_SEQMI"},;
                        {"EDH", "EDH_SEQMI"},;
                        {"ED0", "ED0_TIPINS"},;
                        {"ED2", "ED2_IMPORT"},;
                        {"ED0", "ED0_MIED4"},;
                        {"ED2", "ED2_SEQMI"},;
                        {"ED4", "ED4_IMPORT"}}

            lSeqMi := AvExisteTab(aTable) .AND. AvExisteCampo(aCampos)
         EndIf

         lRet := lSeqMi

      Case cNmRotina == "INDICEED9"

         If ValType(lIndED9) == "U"
            If ED9->(FieldPos("ED9_PEDIDO")) > 0
               aIndexNew := {{"1","ED9_FILIAL+ED9_RE+ED9_PEDIDO+ED9_POSICA"},;
                              {"3","ED9_FILIAL+ED9_AC+ED9_SEQSIS"},;
                              {"4","ED9_FILIAL+ED9_RE+ED9_POSICA"},;
                              {"5","ED9_FILIAL+ED9_PEDIDO+ED9_POSICA"}}

               SIX->(DbSetOrder(1))
               For i := 1 To Len(aIndexNew)
                  If SIX->(DbSeek("ED9"+aIndexNew[i][1]))
                     If !(aIndexNew[i][2] == AllTrim(Upper(SIX->CHAVE)))
                        MsgInfo(STR0242 + CHR(13)+CHR(10)+;//"A rotina possui os índices desatualizado."
                           STR0243+ CHR(13)+CHR(10)+;//"Favor entrar em contato com suporte da Trade-Easy."
                           STR0244,STR0245)//"Aplicar o update UDVE400()."//"Atenção"
                        lIndED9 := .F.
                        Exit
                     Else
                        lIndED9 := .T.
                     EndIf
                  EndIf
               Next
            Else
               lIndED9 := .T.
            EndIf

         EndIf
         lRet := lIndED9

      Case cNmRotina == "INDICEEDD"

         If ValType(lIndEDD) == "U"
            If ED9->(FieldPos("ED9_PEDIDO")) > 0
               If EDD->(FieldPos("EDD_CODOCO")) > 0  //RRC - 25/07/2012
                  aIndexNew := {{"2","EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQSII+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN+EDD_CODOCO" },;
                              {"4","EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQMI+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN+EDD_CODOCO" }}
               Else
                  aIndexNew := {{"1","EDD_FILIAL+EDD_AC+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN+EDD_ITEM+DTOS(EDD_DTREG)"},;
                              {"2","EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQSII+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN" },;
                              {"4","EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQMI+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN" }}
               EndIf

               SIX->(DbSetOrder(1))
               For i := 1 To Len(aIndexNew)
                  If SIX->(DbSeek("EDD"+aIndexNew[i][1]))
                     If !(aIndexNew[i][2] == AllTrim(Upper(SIX->CHAVE)))
                        If  EDD->(FieldPos("EDD_CODOCO")) > 0
                           MsgInfo(STR0242 + CHR(13)+CHR(10)+;//"A rotina possui os índices desatualizado."
                              STR0243+ CHR(13)+CHR(10)+;//"Favor entrar em contato com suporte da Trade-Easy."
                              STR0248,STR0245)//"Aplicar o update UDTFMQJ5()."//"Atenção"
                        Else
                           MsgInfo(STR0242 + CHR(13)+CHR(10)+;//"A rotina possui os índices desatualizado."
                              STR0243+ CHR(13)+CHR(10)+;//"Favor entrar em contato com suporte da Trade-Easy."
                              STR0244,STR0245)//"Aplicar o update UDVE400()."//"Atenção"
                        EndIf
                        lIndEDD := .F.
                        Exit
                     Else
                        lIndEDD := .T.
                     EndIf
                  EndIf
               Next
            Else
               lIndEDD := .T.
            EndIf

         EndIf
         lRet := lIndEDD

      Case cNmRotina == "EEC_LOGIX"
         If ValType(lEECLOGIX) == "U"
            //CHECAR CAMPOS DO UPDATE DO LOGIX
            lEECLOGIX := EasyGParam('MV_EECI010',.F.,.F.)
      EndIf
      lRet := lEECLOGIX

      Case cNmRotina == "NFS_DESVINC"
         If ValType(lNFS_DESVINC) == "U"
            //CHECAR CAMPOS DO UPDATE DA NFS
            lNFS_DESVINC := !EasyGParam("MV_EECFAT",, .F.) .And. AvFlags("EEC_LOGIX") // BAK - 18/05/2012
      EndIf
      lRet := lNFS_DESVINC
      Case cNmRotina == "CODEMB_LOGIX"  // BAK - Utilizado na integraçao do logix para cadastro de embalagem
         SIX->(DBSetOrder(1))
         lRet := EE5->(FieldPos("EE5_PRODUT")) > 0 .And. EasyGParam("MV_AVG0220",.T.) .And. Len(AllTrim(EasyGParam("MV_AVG0220",,""))) < AvSX3("EE5_CODEMB",AV_TAMANHO) .And.;
               SIX->(DbSeek("EE53"))

      Case cNmRotina == "DI_ORIGINAL"
         If ValType(lDIOri) <> "L"

            aTableAvInt := {"ED2"}
            aIndAvInt := {{"ED2","9"},{"ED8","5"}}
            aCposAvInt  := {{'ED2','ED2_PDANT'},{'ED2','ED2_SEQANT'},{'ED2','ED2_ADANT'},{'ED2','ED2_SLDANT'},{'ED2','ED2_SEQIT'},{'ED2','ED2_DI_ORI'}}
            lDIOri :=  AvExisteTab(aTableAvInt) .AND. AvExisteInd(aIndAvInt) .AND. AvExisteCampo(aCposAvInt)

         EndIf

         lRet := lDIOri

      Case cNmRotina == "EEC_LOGIX_PREPED"

         If ValType(lPREPED_EECLOGIX) == "U"
            lExistPrmt := .F.
            lPREPED_EECLOGIX:= EasyGParam("MV_EEC0012",.F.,.F.) .And. AvFlags("EEC_LOGIX")
         If lPREPED_EECLOGIX
            aPrmtAvInt := {"MV_EEC0014","MV_EEC0015","MV_EEC0016","MV_EEC0017","MV_EEC0018","MV_EEC0019","MV_EEC0020"}
            For i:=1 To Len(aPrmtAvInt)
               lExistPrmt := EasyGParam(aPrmtAvInt[i],.T.)
               If !lExistPrmt
                  Exit
               EndIf
            Next i
         EndIf
            lPREPED_EECLOGIX := lExistPrmt .And. lPREPED_EECLOGIX
         EndIf

         lRet := lPREPED_EECLOGIX

      Case cNmRotina == "EIC_EAI"
         /* Integração SIGAEIC <-> EAI via mensagem única*/

         If ValType(lEIC_EAI) <> "L"
            lEIC_EAI:= EasyGParam("MV_EIC_EAI", .F., .F.)
         EndIf

         lRet:= lEIC_EAI

      Case cNmRotina == "EAI_PGANT_INV_NF"
         /* Na integração EAI, define se a liquidação dos câmbios da invoice
            serão considerados adiantamentos quando não houver nota fiscal
            para o processo */

         If ValType(lEAI_pgant_inv_nf) <> "L"

            lEAI_pgant_inv_nf:= .F.

            If AvFlags("EIC_EAI")
               lEAI_pgant_inv_nf:= EasyGParam("MV_EIC0049", .F., .F.)
            EndIf
         EndIf

         lRet:= lEAI_pgant_inv_nf

      Case cNmRotina == "ESS_EAI"
         /* Integração SIGAESS <-> EAI via mensagem única*/

         If ValType(lESS_EAI) <> "L"
            lESS_EAI:= EasyGParam("MV_ESS_EAI", .F., .F.)
         EndIf

         lRet:= lESS_EAI

      Case cNmRotina == "GERACAO_CAMBIO_FRETE"  // GFP - 02/06/2015
         /* Geração de cambio do frete em cenarios com MV_EASYFIN habilitado */
         lCambFre := (EasyGParam("MV_EASYFIN",,"N") == "S" .OR. EasyGParam("MV_FIN_EIC",.F.,.F.) ) .AND. EasyGParam("MV_CAMBFRE",.F.,.F.) //LRS - 04/12/2017
         lRet:= lCambFre

      Case cNmRotina == "GERACAO_CAMBIO_SEGURO"  // GFP - 02/06/2015
         /* Geração de cambio do seguro em cenarios com MV_EASYFIN habilitado */
         lCambSeg := (EasyGParam("MV_EASYFIN",,"N") == "S" .OR. EasyGParam("MV_FIN_EIC",.F.,.F.) ) .AND. EasyGParam("MV_CAMBSEG",.F.,.F.) //LRS - 04/12/2017
         lRet:= lCambSeg
      Case cNmRotina == "ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP"  //NCF - 14/08/2015
         /*Tratamento Acresc./Decres./Multa/Juros/Desconto no controle de cambio SIGAEEC x SIGAFIN*/
         If ValType(lAcrDcrCam) <> "L"
            lAcrDcrCam:= EasyGParam("MV_EEC0046", .F., .F.) .And. AvIsMvOn({"MV_AVG0131",.T.})
         EndIf
         lRet:= lAcrDcrCam

      Case cNmRotina == "LIBERACAO_CREDITO_AUTO"
         /* Liberação de crédito automática */
         /* Quando integrado com outro ERP, a aprovação de crédito ocorrerá no sistema de faturamento. */
         If ValType(lLibAutCred) <> "L"
            lLibAutCred:= EasyGParam("MV_AVG0057", .F., .F.) .Or. IsIntFat() .Or. AvFlags("EEC_LOGIX")
         EndIf

         lRet:= lLibAutCred

      Case cNmRotina == "CAMBIO_EXP_MOV_EXT"  //NCF - 09/09/2015
         If ValType(lCAPMovExt) <> "L"
            aCposAvInt := {{'EEQ','EEQ_MOEBCO'},{'EEQ','EEQ_PRINBC'},{'EEQ','EEQ_VLMBCO'},{'EEQ','EEQ_BCOEXT'},;
                              {'EEQ','EEQ_AGCEXT'},{'EEQ','EEQ_CNTEXT'},{'EEQ','EEQ_NBCEXT'},{'EEQ','EEQ_MODAL'},{'EEQ','EEQ_MOTIVO'},{'EEQ','EEQ_DTCE'}}
            lCAPMovExt := AvExisteCampo(aCposAvInt)
         EndIf
         lRet := lCAPMovExt

      Case cNmRotina == "INTEG_EEC_X_ESS_DESP_E_COMISS"  //NCF - 15/10/2015
         /*Tratamento Integração de Despesas e Comissões entre SIGAEEC x SIGAESS*/
         If ValType(lIntDspCom) <> "L"
            aIndices := {{"EEB","2"}}
            aCampos  := { {"EXL","EXL_FINTFR"},;
                           {"EXL","EXL_FLOJFR"},;
                           {"EXL","EXL_SMOEFR"},;
                           {"EXL","EXL_SPARFR"},;
                           {"EXL","EXL_STAXFR"},;
                           {"EXL","EXL_SVALFR"},;
                           {"EXL","EXL_FINTSE"},;
                           {"EXL","EXL_FLOJSE"},;
                           {"EXL","EXL_SMOESE"},;
                           {"EXL","EXL_SPARSE"},;
                           {"EXL","EXL_STAXSE"},;
                           {"EXL","EXL_SVALSE"},;
                           {"EXL","EXL_FINTFA"},;
                           {"EXL","EXL_FLOJFA"},;
                           {"EXL","EXL_SMOEFA"},;
                           {"EXL","EXL_SPARFA"},;
                           {"EXL","EXL_STAXFA"},;
                           {"EXL","EXL_SVALFA"},;
                           {"EC6","EC6_PRDSIS"},;
                           {"EEQ","EEQ_EVTORI"} }

            lIntDspCom:= AvIsMvOn({"MV_ESS0014",.F.}) .and. AvExisteInd(aIndices) .and. AvExisteCampo(aCampos)
         EndIf
         lRet:= lIntDspCom

      Case cNmRotina == "TABELA_DE_PARA_FIERGS"  //LGS - 16/11/2015
         If Select ("SX2") > 0
            aOrd := SaveOrd({"EEA", "SY5"}) //WHRS TE-4943 507360 / MTRADE-599 - Erro ao visualizar cadastro de empresa
            If EEA->(DbSeek(xFilial("EEA")+AvKey("F-001","EEA_COD"))) .And.;
               SY5->(DbSeek(xFilial("SY5")+ AvKey(EasyGParam("MV_EEC0047",," "),"Y5_COD") ))

               lRet := .T.
            EndIf
            restOrd(aOrd, .T.) //WHRS TE-4943 507360 / MTRADE-599 - Erro ao visualizar cadastro de empresa
         EndIF

      Case cNmRotina == "INV_ANT_GERA_CAMB_FIN"  //NCF - 15/10/2015

         If ValType(lInvAntGFI) <> "L"

            aTable   := {"EW4","EW5"}
            aCampos  := { {"EW4", "EW4_FILIAL"}, {"EW4","EW4_HAWB"},{"EW4","EW4_INVOIC"},{"EW4","EW4_FORN"},{"EW4","EW4_FORLOJ"},;
                           {"EW5", "EW5_FILIAL"},{"EW5","EW5_PGI_NU"},{"EW5","EW5_INVOIC"},{"EW5","EW5_FORN"},{"EW5","EW5_FORLOJ"},;
                           {"EW5","EW5_PO_NUM"} ,{"EW5","EW5_POSICA"},{"SW6","W6_TITINAN"} }

            lInvAntGFI := AvExisteTab(aTable) .AND. AvExisteCampo(aCampos) .And. CHkFile("EW4") .And. Chkfile("EW5")
         EndIf
         lRet := lInvAntGFI

      Case cNmRotina == "RATEIO_DESP_PO_PLI"  // GFP - 28/01/2015

         If ValType(lRatFrSgPO) <> "L"

            aCampos  := { {"SW2", "W2_RAT_POR"}, {"SW2", "W2_SEGINC"} , {"SW3", "W2_SEGURIN"},;
                        {"SW3", "W3_FRETE"}  , {"SW3", "W3_SEGURO"} , {"SW3", "W3_INLAND"} , {"SW3", "W3_DESCONT"}, {"SW3", "W3_PACKING"},;
                        {"EW5", "EW5_FRETE"} , {"EW5", "EW5_SEGURO"}, {"EW5", "EW5_INLAND"}, {"EW5", "EW5_DESCON"}, {"EW5", "EW5_PACKIN"},;
                        {"SW5", "W5_FRETE"}  , {"SW5", "W3_SEGURO"} , {"SW5", "W5_INLAND"} , {"SW5", "W5_DESCONT"}, {"SW5", "W5_PACKING"}  }

            lRatFrSgPO := AvExisteCampo(aCampos) .And. CHkFile("SW2") .And. CHkFile("SW3") .And. CHkFile("SW4") .And. CHkFile("SW5") .And. CHkFile("EW5")
         EndIf
         lRet := lRatFrSgPO

      Case cNmRotina == "COMPLEMENTO_VALOR"  // LGS - 23/03/2016 - define o uso da rotina de complemento de custo

         If EasyGParam("MV_EIC0062",,.F.) .And. EasyGParam("MV_EASY",,"N") == "S"
            lRet := .T.
         EndIf

      Case cNmRotina == "PROVISORIO_DESPESAS"
         aCampos  := { {"SYB", "YB_GERPRO"} }
         If AvExisteCampo(aCampos)
            lRet := .T.
         EndIf
      Case cNmRotina == "FIM_ESPECIFICO_EXP"

         If ValType(lFim_Especifico_Exp) <> "L"
            lFim_Especifico_Exp:= EasyGParam("MV_AVG0174",,.F.) .And. ( IsIntFat() .Or. AvFlags("EEC_LOGIX") ) .And. !EasyGParam("MV_AVG0141",, .F.)
         EndIf
         lRet:= lFim_Especifico_Exp
      //THTS - 21/03/2017 - define o uso da rotina de adiantamento a fornecedores com integracao Logix
      Case cNmRotina == "ADTFOREAI"
         If ValType(lAdtForEAI) == "U"
            lAdtForEAI := AvFlags("EEC_LOGIX") .And. EasyFindAdpt("EECAF520") .And. avExisteInd({{"EEQ","G"}}) 
      EndIf
      lRet := lAdtForEAI

      CAse cNmRotina == "DU-E"
         If ValType(lDecUniExp) == "U"
            aTableDUE := {"ELO"}
            aCposDUE  := {{'ELO','ELO_FILIAL'},{'ELO','ELO_COD'}   ,{'ELO','ELO_DESC'}  ,{'EEC','EEC_EMFRRC'},;
                        {'EEC','EEC_RECALF'},{'EEC','EEC_STTDUE'},{'EEM','EEM_CHVNFE'},{"SYA","YA_PAISDUE"}}
            lDecUniExp := AvIsMvOn({"MV_EEC0053",.F.}) .And. FindFunction("H_DUE_CNF") .And. AvExisteTab(aTableDUE) .AND. AvExisteCampo(aCposDUE) .And. (!AvFlags("FIM_ESPECIFICO_EXP") .Or. AvFlags("ROTINA_VINC_FIM_ESPECIFICO_RP12.1.20"))
         EndIf
         lRet := lDecUniExp

      CAse cNmRotina == "DU-E2"
         If ValType(lDecUniEx2) == "U"
            aTableDUE2 := {"EVN"}
            aCposDUE2  := {{'EVN','EVN_FILIAL'},{'EVN','EVN_GRUPO'} ,{'EVN','EVN_CODIGO'},{"EVN","EVN_DESCRI"},;                       
                        {'EEC','EEC_FOREXP'},{'EEC','EEC_DESFOR'},{'EEC','EEC_OBSFOR'},{"EEC","EEC_SITESP"},;
                        {'EEC','EEC_DESSIT'},{'EEC','EEC_OBSSIT'},{'EEC','EEC_ESPTRA'},{"EEC","EEC_DESTRA"},;
                        {'EEC','EEC_OBSTRA'},{'EEC','EEC_MOTDIS'},{'EEC','EEC_DESDIS'},{"EEC","EEC_OBSDIS"},;
                        {'EEC','EEC_NRODUE'},{'EEC','EEC_NRORUC'},;
                        {'EE9','EE9_PCARGA'},{'EE9','EE9_DESPCA'},{'EE9','EE9_OBSPCA'}}
                           /*WHRS TE-6464 542022 - MTRADE-1806 - Ajustes nos dados do XML da DUE*/ 
            lDecUniEx2 := AvFlags("DU-E") .And. AvExisteTab(aTableDUE2) .AND. AvExisteCampo(aCposDUE2)
         EndIf
         lRet := lDecUniEx2

      CAse cNmRotina == "DU-E3"
         If ValType(lDecUniEx3) == "U"
            aTableDUE3  := {"EK0","EK1","EK2","EK3","EK4"}
            aCposDUE3   := {{"EK0","EK0_RETIFI"}}
            lDecUniEx3 := AvFlags("DU-E") .And. AvFlags("DU-E2") .AND. AvExisteTab(aTableDUE3) .AND. AvExisteCampo(aCposDUE3)
         EndIf
         //lDecUniEx3 := .F.
         lRet := lDecUniEx3

      CAse cNmRotina == "DU-E3.1"
         If ValType(lDecUnEx31) == "U"
            aTableDUE31  := {"EK7","EK8"}
            aCposDUE31   := {    {"EK1","EK1_RESPDE"},{"EK1","EK1_LATDES"},{"EK1","EK1_LONDES"},{"EK1","EK1_ENDDES"},{"EK1","EK1_RESPON"},{"EK1","EK1_EMAIL"},{"EK1","EK1_FONE"},{"EK1","EK1_JUSRET"},{"EK1","EK1_URFENT"},{"EK1","EK1_RECEMB"},;
            {"EK2","EK2_JUSDUE"},{"EK2","EK2_SEQED3"},{"EK2","EK2_PESNCM"},{"EK2","EK2_QTDNCM"},{"EK2","EK2_DESC"  },;
            {"EK4","EK4_DOC"   },{"EK4","EK4_SERIE" },{"EK4","EK4_CLIENT"},{"EK4","EK4_LOJACL"},{"EK4","EK4_D2ITEM"},{"EK4","EK4_D2QTD"},{"EK4","EK4_CHVNFS"},{"EK4","EK4_FATSEQ"},;
            {"EK7","EK7_PREEMB"},{"EK7","EK7_SEQEMB"},{"EK7","EK7_POSIPI"},{"EK7","EK7_CNPJ"  },{"EK7","EK7_VLSCOB"},{"EK7","EK7_VALOR"},{"EK7","EK7_QTD"   },{"EK7","EK7_ATOCON"},{"EK7","EK7_TPAC"},{"EK7","EK7_SEQED3"},{"EK7","EK7_TIPO"},{"EK7","EK7_SEQEK7"  },;
            {"EK8","EK8_PREEMB"},{"EK8","EK8_SEQEMB"},{"EK8","EK8_NF"    },{"EK8","EK8_SERIE"},{"EK8","EK8_DTNF"   },{"EK8","EK8_CHVNFE"},{"EK8","EK8_VLNF"},{"EK8","EK8_QTD"},{"EK8","EK8_ATOCON"},{"EK8","EK8_SEQED3"},{"EK8","EK8_POSIPI"},{"EK8","EK8_TIPO"},{"EK8","EK8_SEQEK8"}}
            lDecUnEx31   := AvFlags("DU-E3") .AND. AvExisteTab(aTableDUE31) .AND. AvExisteCampo(aCposDUE31)
         EndIf
         lRet := lDecUnEx31

      CAse cNmRotina == "DESTAQ"
         If ValType(lDestaq) == "U"
            aTableDestaq := {"EK5"}
            aCposDestaq  := {{"EE9","EE9_DTQNCM"}}
            lDestaq := AvFlags("DU-E") .And. AvFlags("DU-E2") .AND. AvExisteTab(aTableDestaq) .AND. AvExisteCampo(aCposDestaq)
         EndIf
         lRet := lDestaq

      Case cNmRotina == "NFT_DESP_BASE_IMP" // THTS - 09/01/2018 - Nota fiscal de transferência com despesas base de impostos que não compoe total da nota

         If ValType(lNFTBasImp) =="U"
               aCampos     := {{"SYB", "YB_BIPINFT"},{"SYB", "YB_TOTNFT" },;
                              {"EIW", "EIW_VALTOT"} ,{"EIW", "EIW_DESPCU"},;
                              {"EIW", "EIW_DBSIPI"},{"EIW", "EIW_DBSICM"}}

               lNFTBasImp  := AvExisteCampo(aCampos)
         EndIf
         lRet := lNFTBasImp

      Case cNmRotina == "DESTAQUE_QUEBRA_LI" //LRS - 18/01/18

         aCampos  := { {"EYJ", "EYJ_DESTAQ"} }
         
         If AvExisteCampo(aCampos)
            lRet := .T.
         EndIf

      Case cNmRotina == "EIC_FFC_EAI" //THTS - 23/01/2018 - TE-7758 - MTRADE-2036 - Integração da Liquidação de FFC com o LOGIX

         If ValType(lEICFFCEAI) =="U"
               aCamposFFC := {{"SWB", "WB_SEQLOTE"}}
               aIndices := {{"SWB","8"}} //WB_FILIAL, WB_NUMDUP
               lEICFFCEAI := .F.
               If AvFlags("EIC_EAI") .And. AvExisteCampo(aCamposFFC) .And. AvExisteInd(aIndices) .And. EasyFindAdpt("EICAP111") .And. EasyFindAdpt("EICAP113") .And. EasyFindAdpt("EICAP114")
                  lEICFFCEAI  := .T.
               EndIf
         EndIf
         lRet := lEICFFCEAI

      Case cNmRotina == "ROTINA_VINC_FIM_ESPECIFICO_RP12.1.20"

         If ValType(lFim_Espc2) == "U"
            aCposNew := {{"EYY","EYY_COD_I" },{"EYY","EYY_VM_DES"},{"EYY","EYY_UNIDAD"},{"EYY","EYY_POSIPI"},{"EYY","EYY_UMDSD1"}}

            aCposOld := {{"EYY","EYY_PREEMB"},{"EYY","EYY_SEQEMB"},{"EYY","EYY_RE"    },{"EYY","EYY_NFSAI" },{"EYY","EYY_SERSAI"},;
                           {"EYY","EYY_NFENT" },{"EYY","EYY_SERENT"},{"EYY","EYY_FORN"  },{"EYY","EYY_FOLOJA"},{"EYY","EYY_DESFOR"},;
                           {"EYY","EYY_PEDIDO"},{"EYY","EYY_SEQUEN"},{"EYY","EYY_FASE"  },{"EYY","EYY_QUANT" },{"EYY","EYY_NROMEX"},;
                           {"EYY","EYY_DTMEX" },{"EYY","EYY_D1ITEM"},{"EYY","EYY_D1PROD"},{"SD1","D1_SLDEXP" }}
            lFim_Espc2 := .F.
            If AvFlags("FIM_ESPECIFICO_EXP") .And. AvExisteCampo(aCposOld) .And. AvExisteCampo(aCposNew)
               lFim_Espc2 := .T.
            EndIf
            aCposNew := aCposOld := NIL
         EndIf
         lRet := lFim_Espc2

      Case cNmRotina == "SUFRAMA"
         //Nota de alteração 08/06/2018: Esta implementação visa atender a continuidade do funcionamento da importação via SUFRAMA nos clientes que já trabalham com o ambiente configurado apenas com o parâmetro MV_SUFRAMA = T.
         //                              Para os clientes que não desejam ativar os tratamentos de SUFRAMA no SIGAEIC mas que possuam tal tratamento no SIGAFIS, faz-se necessário desabilitar o parâmetro MV_EIC0069 no ambiente. 
         If ValType(lSuframa) == "U"
            lSuframa := EasyGParam("MV_SUFRAMA",,.F.) .And. EasyGParam("MV_EIC0069",,.T.)
         EndIf
         lRet := lSuframa

      CAse cNmRotina == "NVE_POR_PRODUTO"
         If ValType(lNveCadProd) == "U"
            aIndiNVEPd := {{"EIM","3"}}
            aCposNVEPd := {{'EIM','EIM_NCM'},{'EYJ','EYJ_NVE'}}
            lNveCadProd := AvIsMvOn({"MV_EIC0011",.F.}) .AND. AvExisteCampo(aCposNVEPd) .And. AvExisteInd(aIndiNVEPd)
	      EndIf
	      lRet := lNveCadProd

      CAse cNmRotina == "PAINELCAMBIO"
            aCpos := {{"EEQ","EEQ_DTEMBA"},{"EEQ","EEQ_LTBX"},{"EEQ","EEQ_LTRC"},{"EEQ","EEQ_LTPG"}}
            If AvExisteCampo(aCpos)
                lRet := .T.
            EndIf

      Case cNmRotina == "NOTAS_FISCAIS_SAIDA_LOTE_EXPORTACAO"
           If ValType(lNFSLoteExp) == "U"
              aTabNFLtEx := {"EK6"}
              aIndNFLtEx := { {"EK6","1"}, {"EK6","2"} }
              aCpoNFLtEx := { "EK6_FILIAL" , "EK6_NF"   , "EK6_SERIE" , "EK6_CLIENT" , "EK6_LOJACL" , "EK6_COD_I" , "EK6_ITEM"  , "EK6_CHVNFE" , "EK6_QUANT" , ;
                              "EK6_UMNF"   , "EK6_CFOP" , "EK6_QTUMIT", "EK6_PREEMB" , "EK6_NFSD"   , "EK6_SENFSD", "EK6_PDNFSD", "EK6_SQPDNF" , "EK6_SQFTSD","EK6_SEQEMB" }
              lNFSLoteExp := AvExisteTab( aTabNFLtEx ) .And.  AvExisteInd( aIndNFLtEx ).And. AvExisteCampo( aCpoNFLtEx )
           EndIf
           lRet := lNFSLoteExp

      Case cNmRotina == "DATA_FABRIC_LOTE_IMPORTACAO"
           If ValType(lCpoDtFbLt) == "U"
              aCpoDtFbLt := {"WV_DFABRI","WN_DFABRI","EI2_DFABRI"}
              lCpoDtFbLt := AvIsMvOn({"MV_LOTEEIC","N"}) .And. AvExisteCampo( aCpoDtFbLt )
           EndIf
           lRet := lCpoDtFbLt

      Case cNmRotina == "ICMSFECP_DI_ELETRONICA"
           If ValType(lFECPDIEle) == "U"
              aCpoFECPDE := { {"SWZ","WZ_ALFECP"} , {"SWN","WN_ALFECP"} , {"SWN","WN_VLFECP"} , {"SW8","W8_ALFECP"} , {"SW8","W8_VLFECP"} }
              lFECPDIEle := AvIsMvOn({"MV_TEM_DI",.F.}) .And. AvExisteCampo( aCpoFECPDE )
           EndIf
           lRet := lFECPDIEle

      Case cNmRotina == "STATUS_DUE"
           If ValType(lStatusDUE) == "U"
              aTabSttDUE := {"EKK"}
              aIndSttDUE := { {"EKK","1"} }
              aCpoSttDUE := { {"EKK","EKK_FILIAL"} , {"EKK","EKK_PROCES"} , {"EKK","EKK_NUMSEQ"} , {"EKK","EKK_SEQSTA"} , {"EKK","EKK_STATUS"} , {"EKK","EKK_DATAST"} , {"EKK","EKK_HORAST"} , {"EKK","EKK_DETAST"} , {"EEC","EEC_STPTUN"} }
              aFunSttDUE := {"EECDU101"}
              lStatusDUE := AvExisteTab( aTabSttDUE ) .And.  AvExisteInd( aIndSttDUE ).And. AvExisteCampo( aCpoSttDUE ) .And. AvExisteFunc(aFunSttDUE)
           EndIf
           lRet := lStatusDUE

      Case cNmRotina == "GRV_BASEICMS_DI_ELETRONICA"
           If Valtype(lBaseICMDIE) == "U"
              aCpoBICMSDI := { {"EIJ","EIJ_BASICM"} }
              lBaseICMDIE := AvExisteCampo( aCpoBICMSDI )
           EndIf
           lRet := lBaseICMDIE

      Case cNmRotina == "FORM_LPCO"
           If ValType(lFormLPCO) == "U"
              aTabFormLPCO := {"EKL"}
              aCpoFormLPCO := { "JJ_MSBLQL" }
              lFormLPCO := AvExisteTab( aTabFormLPCO ) .And. AvExisteCampo( aCpoFormLPCO )
           EndIf
           lRet := lFormLPCO
      
      Case cNmRotina == "COMISSAO_VARIOS_AGENTES"
         If ValType(lTratComis) == "U"
            lTratComis := EasyGParam("MV_AVG0077",,.F.) 
         EndIf
         lRet := lTratComis
      Case cNmRotina == "DUIMP"  
         If ValType(lDuimp) == "U" 
            aCampos := {{'SW6','W6_TIPOREG'}}
            lDuimp:=AvExisteCampo(aCampos) 
         EndIf   
         lRet := lDuimp

      Case cNmRotina == "DUIMP_12.1.2310-22.4"
         if AvFlags("DUIMP")
         
            aCampos := {}
            aAdd( aCampos, {"EIJ", "EIJ_VLCII"  } ) // II calculado: Valor Calculado do Tributo em R$ (Reais)
 
            lDuimp := AvExisteCampo(aCampos) 

         endif
         lRet := lDuimp
      Case cNmRotina == "FECP_DIFERIMENTO"
         If ValType(lFECPDifer) == "U"
            aCampos := {{'SWN','WN_FECPALD'},{'SWN','WN_FECPVLD'},{'SWN','WN_FECPREC'},{'SW8','W8_FECPALD'},{'SW8','W8_FECPVLD'},{'SW8','W8_FECPREC'}}
            lFECPDifer := AvExisteCampo(aCampos) .And. !AvFlags("EIC_EAI") .And. !AvIsMvOn({"MV_EASY","N"})
         EndIf
         lRet := lFECPDifer
      OtherWise

           If cEmpAnt == '99' .AND. ValType(GetApoInfo("EASYAUTTESTE.PRW")) == "A" .AND. Len(GetApoInfo("EASYAUTTESTE.PRW")) > 0
              UserException("Falha de AvFlags: Parametro '"+cNmRotina+"' não tratado.")
           EndIf

   End Case

   EasySetBuffers("AVFLAGS",cFilAnt+','+cNmRotina,@lRet)

   DbSelectArea(cArea)

End Sequence

Return lRet

Function EICRetLoja(cAlias, cCampo)
Local xRet   := ""
Local oModel := FWModelActive()

If AvFlags("LOJA-EIC")
	If ValType(oModel) == "O" .And. oModel:GetID() == "MATA061"  // LRS 15/10/2013 - Mudado o oModel para MATA061
		Return oModel:GetModel("MdGridSA5"):GetValue(cCampo)
	Else
		Return &(cAlias + "->" + cCampo)
	EndIf
EndIf

Return xRet
*------------------------------------------------*
Function EICSFabFor(cChave, cLojaFAB, cLojaFOR)
*------------------------------------------------*
Local aOrd		:= SaveOrd("SA5")
Local lFound	:= .F.
Local lFoundLj := .F.
Local lVldFAB	:= (ValType(cLojaFAB) == "C" .And. !Empty(cLojaFAB))
Local lVldFOR	:= (ValType(cLojaFOR) == "C" .And. !Empty(cLojaFOR))
Local bChave
Default cLojaFAB := ""
Default cLojaFOR := ""

If lVldFAB .And. lVldFOR
   bChave := {|| SA5->(A5_FALOJA+A5_LOJA) == cLojaFAB+cLojaFOR }
ElseIf lVldFAB
   bChave := {|| SA5->A5_FALOJA == cLojaFAB }
ElseIf lVldFOR
   bChave := {|| SA5->A5_LOJA == cLojaFOR }
EndIf

SA5->(DbSetOrder(3))
lFound := SA5->(MsSeek(cChave))//SA5->(DbSeek(cChave)) RMD - 26/03/19 - Utiliza MsSeek para otimizar a performance

If lVldFAB .Or. lVldFOR
   While SA5->(!Eof() .And. Left(A5_FILIAL+A5_PRODUTO+A5_FABR+A5_FORNECE, Len(cChave)) == cChave)
      If Eval(bChave)
         lFoundLj := .T.
         Exit
      EndIf
      SA5->(DbSkip())
   EndDo
   If !lFoundLj
      SA5->(DbGoBottom())
      SA5->(DbSkip())
   EndIf
Else
   lFound := SA5->(!Eof())
EndIf

RestOrd(aOrd)
Return IIF(lVldFAB .Or. lVldFOR, lFound .And. lFoundLj, lFound)

*-----------------------------------*
Function EICEmptyLJ(cAlias, cCpoLJ)
*-----------------------------------*
Local lEmpty	:= .F.
Local oModel	:= FWModelActive()

If ValType(oModel) <> "O" .Or. oModel:GetId() <> "MATA061" //NCF - 14/12/2017
   If AvFlags("LOJA-EIC")
      lEmpty := Empty(&(cAlias + "->" + cCpoLJ))
   EndIf
Else
   If oModel:GetId() == "MATA061" // LRS 15/10/2013 - trocado oModel para MATA061
      lEmpty := Empty(oModel:GetModel("MdGridSA5"):GetValue(cCpoLJ))
   EndIF
EndIf

Return lEmpty

*-------------------*
Function EICLoja()
*-------------------*
Return AvFlags("LOJA-EIC")

*--------------------------------------------*
Function EICAddWkLoja(aCampos, cCampo, cCod)
*--------------------------------------------*
Local nPos := aScan(aCampos, {|x| x[1] == cCod })
   If EICLoja()
      If nPos == 0
         nPos := Len(aCampos) + 1
      Else
         ++nPos
      EndIf

      aAdd(aCampos, Nil)
      aIns(aCampos, nPos)
      aCampos[nPos] := {cCampo, "C", AvSx3(cCampo, AV_TAMANHO), 0}
   EndIf

Return Nil

*--------------------------------------------------*
Function EICAddLoja(aCampos, cCampo, cAlias, xPos)
*--------------------------------------------------*
Local lMultiArray := .F.
   If EICLoja()
      lMultiArray := Len(aCampos) > 0 .And. ValType(aCampos[1]) == "A"

      If !lMultiArray
         nPos := AddxPos(aCampos, xPos)
         aCampos[nPos] := cCampo
      Else
         nPos := AddxPos(aCampos, xPos)
         If (ValType(cAlias) == "C") .And. !Empty(cAlias)
            aCampos[nPos] := {&("{|| " + cAlias + "->" + cCampo + " }"), "", AvSx3(cCampo, AV_TITULO)}
         Else
            aCampos[nPos] := {cCampo, "", AvSx3(cCampo, AV_TITULO)}
         EndIf
      EndIf
   EndIf
Return Nil

Static Function AddxPos(aCampos, xPos)
Local nPos, cChave
Local bScan := {|x| x/*Busca simples (array de enchoice)*/ == cChave }

   If Len(aCampos) > 0 .And. ValType(aCampos[1]) == "A"
      bScan := {|x| x[3]/*Posição do título do campo no array de MSSELECT/GETDADOS/GETDB*/ == cChave}
   EndIf

   nPos		:= If(ValType(xPos) == "N", xPos, Nil)
   cChave	:= If(ValType(xPos) == "C", xPos, "")

   If ValType(nPos) <> "N" .And. (Empty(cChave) .Or. (nPos := aScan(aCampos, bScan)) == 0)
      aAdd(aCampos, Nil)
      nPos := Len(aCampos)
   Else
      ++nPos
      aAdd(aCampos, Nil)
      aIns(aCampos, nPos)
   EndIf

Return nPos

Function EICTelaLoja(cGetCod, cGetLoja, cAlias, bValid, cTitulo)
Local bOk := {|| If(Eval(bValid), (lOk := .T., oDlg:End()), ) }
Local bCancel := {|| oDlg:End() }
Local lOk := .F.
Local nLin    := 40 //WHRS TE-4872 504312 / MTRADE-471 - Opção 'Itens/Forn' ao incluir/alterar na cotação de preço
Default bValid := {|| .T. }

   If ValType(bValid) == "C"
      bValid := &("{|| " + bValid + "}")
   EndIf

   If ValType(cTitulo) <> "C"
      If cAlias == "SA1"
         cTitulo := "Selecione o Cliente"
      ElseIf cAlias == "SA2" .OR. cAlias == "SA2A"
         cTitulo := "Selecione o Fornecedor/Fabricante"
      Else
         cTitulo := ""
      EndIf
   EndIf

   DEFINE MSDIALOG oDlg TITLE cTitulo From 0,0 To 10,50 OF oMainWnd    //0,0  7,45 //20,15  16,65

      @ nLin,5 SAY "Codigo" SIZE 70,8 PIXEL
      @ nLin,25 MSGET cGetCod F3 cAlias PICTURE "@!" VALID (ExistCpo("SA2",AvKey(cGetCod,"A2_COD")))/*FDR-02/08/11*/ SIZE 42,8 OF oDlg PIXEL

      If EICLoja()
         @ nLin,70 SAY "Loja" SIZE 70,8 PIXEL
         @ nLin,90 MSGET cGetLoja PICTURE "@!" SIZE 10,8  OF oDlg PIXEL
      EndIf

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOk, bCancel) CENTERED

Return lOk

Function AvCpo(cAlias, cChave, lMostraHelp)
Default lMostraHelp := .F.
Return ExistCpo(cAlias,cChave,,,lMostraHelp,Nil)

/*
Funcao    : AvGetImpSped
Parâmetros: cFilial - Filial do registro enviado
            cNF     - Número da nota de entrada
            cSerie  - Série da nota de entrada
            cForn   - Fornecedor da nota de entrada
            cLoja   - Loja do fornecedor da nota de entrada
Retorno   : Vetor com os dados do processo de importação ou vetor vazio quando não se refere à um processo de importação.

            Estrutura do array de retorno:

            aDados[x][1] - Registro do Layout (C120)
            aDados[x][y][z][1] - Campo identificador do Layout (COD_DOC_IMP)
            aDados[x][y][z][2][n] - Array com os registros dos campos (NUM_ACDRAW, por exemplo, com os ACs)

Objetivos : Retornar um vetor referente ao registro C120, conforme leiaute versão 2.0.0 da escrituração fiscal digital,
            ato COTEPE/ICMS nº 09, de 18 de abril de 2008, atualização: 17 de dezembro de 2009. Módulo: Importação.
Autor     : Wilsimar Fabrício da Silva
Data/Hora : 13/04/2010
Revisao   :
Obs.      : A rotina que chamará esta função poderá ser executada para a filial ou para todas a empresa, gerando uma informação
            consolidada a ser enviada para a SRF. Por esse motivo, a filial também deve ser informada no parâmetro.
*/
Function AvGetImpSped(cFilNf, cNf, cSerie, cForn, cLoja)
Local aOrd  := SaveOrd({"SF1", "SWN", "SW6", "SW8"}),;
      aDados:= {}
Local cQuery:= ""
Local nPos,;
      nPosReg

Default cFilNf := "",;
        cNf    := "",;
        cSerie := "",;
        cForn  := "",;
        cLoja  := ""

Begin Sequence

   //Caso algum parâmetro não tenha sido enviado, retorna o array vazio
   SX2->(DBSetOrder(1))
   SX2->(DBSeek("SF1"))

   If FWModeAccess("SF1",3) =="E" //LRS - 11/01/2018
      If Empty(cFilNf) .Or. Empty(cNf) .Or. Empty(cForn) .Or. Empty(cLoja)
         Break
      EndIf
   Else
      If Empty(cNf) .Or. Empty(cForn) .Or. Empty(cLoja)
         Break
      EndIf
   EndIf

	/* Registro C120 - Operações de importação
	   Guia prático EFD versão 2.0.0. Atualização: 17/12/2009

	Campo			Descrição
	-------------------------------------------------------------
	REG				Texto fixo contendo "C120"
	COD_DOC_IMP 	Documento de importação:
					0 – Declaração de Importação;
					1 – Declaração Simplificada de Importação.
	NUM_DOC__IMP	Número do documento de Importação.
	PIS_IMP 		Valor pago de PIS na importação.
	COFINS_IMP 		Valor pago de COFINS na importação.
	NUM_ACDRAW 		Número do Ato Concessório do regime Drawback.
	-------------------------------------------------------------
	*/

   AAdd(aDados, {"C120", {}})
   nPosReg:= AScan(aDados, {|x| x[1] == "C120"})

   AAdd(aDados[nPosReg][2], {"COD_DOC_IMP" , {}})
   AAdd(aDados[nPosReg][2], {"NUM_DOC__IMP", {}})
   AAdd(aDados[nPosReg][2], {"PIS_IMP"     , {}})
   AAdd(aDados[nPosReg][2], {"COFINS_IMP"  , {}})
   AAdd(aDados[nPosReg][2], {"NUM_ACDRAW"  , {}})

   cFilNf:= AvKey(cFilNf, "F1_FILIAL")
   cNf   := AvKey(cNf   , "F1_DOC")
   cSerie:= AvKey(cSerie, "F1_SERIE")
   cForn := AvKey(cForn , "F1_FORNECE")
   cLoja := AvKey(cLoja , "F1_LOJA")

   SF1->(DBSetOrder(1)) //F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO
   SWN->(DBSetOrder(2)) //WN_FILIAL + WN_DOC + WN_SERIE + WN_FORNECE + WN_LOJA
   SW6->(DBSetOrder(1)) //W6_FILIAL + W6_HAWB
   SW8->(DBSetOrder(6)) //W8_FILIAL + W8_HAWB + W8_INVOICE + W8_PO_NUM + W8_POSICAO + W8_PGI_NUM

   #IfDef TOP

      cQuery += "Select F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, W6_DSI, W6_DI_NUM, W6_CURRIER "

      If SW6->(FieldPos("W6_DIRE")) # 0  // GFP - 17/01/2014 - Verificação do campo W6_DIRE para inclusão na Query
         cQuery +=  ", W6_DIRE"
      EndIf

      cQuery +=  ", sum(WN_VLRPIS) as F1_VALPIS, sum(WN_VLRCOF) as F1_VALCOFI, W8_AC "   // GFP - 11/12/2013

      cQuery += "From " + RetSqlName("SF1") + " F1 Inner Join " + RetSqlName("SWN") + " WN "
      cQuery += "On WN_FILIAL = '"+ xFilial("SWN")+ "' And WN_DOC = F1_DOC And WN_SERIE = F1_SERIE And WN_FORNECE = F1_FORNECE And WN_LOJA = F1_LOJA "
      cQuery += "Inner Join " + RetSqlName("SW6") + " W6 "
      cQuery += "On W6_FILIAL = '"+ xFilial("SW6")+ "' And W6_HAWB = WN_HAWB "
      cQuery += "Inner Join " + RetSqlName("SW8") + " W8 "
      cQuery += "On W8_FILIAL = '"+ xFilial("SW8")+ "' And W8_HAWB = WN_HAWB And W8_INVOICE = WN_INVOICE And W8_PO_NUM = WN_PO_EIC And W8_POSICAO = WN_ITEM "
      cQuery += "Where F1.D_E_L_E_T_ <> '*' And WN.D_E_L_E_T_ <> '*' And W6.D_E_L_E_T_ <> '*' And W8.D_E_L_E_T_ <> '*' "
      cQuery += "And F1_FILIAL = '"  + cFilNf + "' " +;
                "And F1_DOC = '"     + cNf    + "' " +;
                "And F1_SERIE = '"   + cSerie + "' " +;
                "And F1_FORNECE = '" + cForn  + "' " +;
                "And F1_LOJA = '"    + cLoja  + "' " +;
                "And (W6_CURRIER = '2' OR W6_CURRIER = ' ' OR W6_CURRIER = '1' AND (W6_FOB_TOT+W6_INLAND+W6_PACKING+W6_FRETEIN+W6_SEGINV+W6_OUTDESP-W6_DESCONT) > (3000 * W6_TX_US_D)) "
      cQuery+=  "Group by W8_AC, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, W6_DSI, W6_DI_NUM, W6_CURRIER"   // GFP - 13/01/2014 - Inclusão do campo W6_CURRIER
      If SW6->(FieldPos("W6_DIRE")) # 0  // GFP - 13/01/2014 - Verificação do campo W6_DIRE para inclusão na Query
         cQuery += ", W6_DIRE"
      EndIf

      cQuery:= ChangeQuery(cQuery)
      DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "SPED", .T., .T.)

      SPED->(DBGoTop())

      //O sistema possibilita a quebra por ato concessório, conforme o conteúdo
      //do parâmetro MV_QBACMOD, evitando a exitência de uma nota com dois ou mais
      //atos.
      //O tratamento abaixo é para os casos onde esta parametrização não foi respeitada,
      //evitando a repetição de números de ato concessórios.
      While SPED->(!Eof())

         nPos:= AScan(aDados[nPosReg][2], {|x| x[1] == "NUM_ACDRAW"})
         If AScan(aDados[nPosReg][2][nPos][2], {|x| AllTrim(x) == AllTrim(SPED->W8_AC)}) == 0

            AAdd(aDados[nPosReg][2][nPos][2], SPED->W8_AC)

            nPos:= AScan(aDados[nPosReg][2], {|x| x[1] == "COD_DOC_IMP"})
            AAdd(aDados[nPosReg][2][nPos][2], If(SPED->W6_DSI == "1", "1", "0"))

            nPos:= AScan(aDados[nPosReg][2], {|x| x[1] == "NUM_DOC__IMP"})
            AAdd(aDados[nPosReg][2][nPos][2], If(SPED->W6_CURRIER == "1", SPED->W6_DIRE, SPED->W6_DI_NUM))  // GFP - 11/12/2013

            nPos:= AScan(aDados[nPosReg][2], {|x| x[1] == "PIS_IMP"})
            AAdd(aDados[nPosReg][2][nPos][2], SPED->F1_VALPIS)

            nPos:= AScan(aDados[nPosReg][2], {|x| x[1] == "COFINS_IMP"})
            AAdd(aDados[nPosReg][2][nPos][2], SPED->F1_VALCOFI)

         EndIf

         SPED->(DBSkip())
      EndDo

      SPED->(DBCloseArea())

   #Else

      //Nota fiscal de importação
      If SF1->(DBSeek(cFilNf + cNf + cSerie + cForn + cLoja)) .And.;
         SWN->(DBSeek(xFilial("SWN") + cNf + cSerie + cForn + cLoja))

         //Declaração de importação
         SW6->(DBSeek(xFilial("SW6") + SWN->WN_HAWB))
         //Ato concessório (itens da invoice)
         SW8->(DBSeek(xFilial("SW8") + SWN->(WN_HAWB + WN_INVOICE + WN_PO_EIC)))

         //O sistema possibilita a quebra por ato concessório, conforme o conteúdo
         //do parâmetro MV_QBACMOD, evitando a exitência de uma nota com dois ou mais
         //atos.
         //O tratamento abaixo é para os casos onde esta parametrização não foi respeitada,
         //evitando a repetição de números de ato concessórios.
         While SW8->(!Eof()) .And.;
               SW8->W8_FILIAL  == cFilNf .And.;
               SW8->W8_HAWB    == SWN->WN_HAWB .And.;
               SW8->W8_INVOICE == SWN->WN_INVOICE .And.;
               SW8->W8_PO_NUM  == SWN->WN_PO_EIC

            nPos:= AScan(aDados[nPosReg][2], {|x| x[1] == "NUM_ACDRAW"})
            If AScan(aDados[nPosReg][2][nPos][2], {|x| AllTrim(x) == AllTrim(SW8->W8_AC)}) == 0

               AAdd(aDados[nPosReg][2][nPos][2], SW8->W8_AC)

               nPos:= AScan(aDados[nPosReg][2], {|x| x[1] == "COD_DOC_IMP"})
               AAdd(aDados[nPosReg][2][nPos][2], If(SW6->W6_DSI == "1", "1", "0"))

               nPos:= AScan(aDados[nPosReg][2], {|x| x[1] == "NUM_DOC__IMP"})
               AAdd(aDados[nPosReg][2][nPos][2], SW6->W6_DI_NUM)

               nPos:= AScan(aDados[nPosReg][2], {|x| x[1] == "PIS_IMP"})
               AAdd(aDados[nPosReg][2][nPos][2], SF1->F1_VALPIS)

               nPos:= AScan(aDados[nPosReg][2], {|x| x[1] == "COFINS_IMP"})
               AAdd(aDados[nPosReg][2][nPos][2], SF1->F1_VALCOFI)
            Else
               nPos:= AScan(aDados[nPosReg][2], {|x| x[1] == "PIS_IMP"})
               aDados[nPosReg][2][nPos][2][1] += SW8->W8_VLRPIS

               nPos:= AScan(aDados[nPosReg][2], {|x| x[1] == "COFINS_IMP"})
               aDados[nPosReg][2][nPos][2][1] += SW8->W8_VLRCOF
            EndIf

            SW8->(DBSkip())
         EndDo
      EndIf

   #EndIf

   If Empty(aDados[1][2][1][2])
      aDados:= {}
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return aDados


/*
Funcao    : AvGetExpSped
Parâmetros: Data inicial
            Data final
            lConcFil  - informa se a filial deve ser concatenada ao código do produto
Retorno   :
Objetivos : Criar arquivos de trabalho referente aos registros 1100, 1105 e 1110, conforme leiaute versão 2.0.0 da escrituração fiscal digital,
            ato COTEPE/ICMS nº 09, de 18 de abril de 2008, atualização: 17 de dezembro de 2009. Módulo: Exportação.
            Esta função criará as works Sped1100, Sped1105 e Sped1110. A amarração entre estas tabelas será a chave composta pelos campos
            ID e PREEMB.
Autor     : Wilsimar Fabrício da Silva
Data/Hora : 16/04/2010
Revisao   : 04/06/2010
Obs.      : Este registro deve ser preenchido no mês em que se concluir a exportação direta ou indireta pelo efetivo exportador.
            Desta forma, serão listados os dados dos processos cuja data de embarque (EEC_DTEMBA) esteja contido no parâmetro enviado.
*/
Static __aTempSped:= {,,}//armazenar os dados das tabelas temporárias
Function AvGetExpSped(dDataIni, dDataFin, lConcFil)
Local aOrd      := SaveOrd({"EEC", "EE9"}),;
      aEmbarques:= {}
Local cQuery    := "",;
      cId       := "0"
Local nCont
Private lVerDtAvb := .F.

Private cAlias1100:= "SPED1100",;
        cAlias1105:= "SPED1105",;
        cAlias1110:= "SPED1110"

Default dDataIni:= dDataBase,;
        dDataFin:= dDataBase
Default lConcFil:= .T.

If ValType(dDataIni) == "C"
   dDataIni:= CtoD(dDataIni)
EndIf

If ValType(dDataFin) == "C"
   dDataFin:= CtoD(dDataFin)
EndIf

Begin Sequence

   //Criação dos arquivos de trabalhos
   If !CriaWorkSped()
      Break
   EndIf

   //Montagem do array com os embarques que estejam contidos nos parâmetro enviados (período)
   #IfDef TOP

      If EasyGParam("MV_EEC0001",,"1") == "1"  //Por Data de Embarque
         cQuery += "Select R_E_C_N_O_ as EEC_RECNO "
         cQuery += "From " + RetSqlName("EEC") + " "
         cQuery += "Where D_E_L_E_T_ <> '*' "
         cQuery += "And EEC_FILIAL = '" + EEC->(xFilial()) + "' " +;
                   "And EEC_DTEMBA >= '" + DtoS(dDataIni) + "' " +;
                   "And EEC_DTEMBA <= '" + DtoS(dDataFin) + "' "

      Else  //Por Data de Averbação

         //DFS - 18/07/13 - Inclusão de tratamento para filial e deleção dos dados da EXL
         cQuery += "Select EEC.R_E_C_N_O_ as EEC_RECNO "
         cQuery += "From " + RetSqlName("EEC") + " EEC "
         cQuery += "INNER JOIN " + RetSqlName("EXL") + " EXL "
         cQuery += "On EXL.EXL_PREEMB = EEC.EEC_PREEMB "
         cQuery += "Where EEC.D_E_L_E_T_ <> '*' And EXL.D_E_L_E_T_ <> '*' ""
         cQuery += "And EEC.EEC_FILIAL = '" + EEC->(xFilial()) + "' And EXL.EXL_FILIAL = '" + EXL->(xFilial()) + "' "
         //LGS-22/10/13 - Inclusão de tratamento para que o retorno da subqueri não gere numeros duplicados de RECNO
         cQuery += "And " + If (EXL->(FieldPos("EXL_AVRBDS")) > 0,"(","")
         cQuery += "EEC.EEC_PREEMB In (SELECT DISTINCT EE9_PREEMB "
         cQuery += "FROM " +RetSQLName("EE9") + " "
         cQuery += "Where D_E_L_E_T_ <> '*' "
         cQuery += "And EE9_FILIAL = '" + EE9->(xFilial()) + "' "
         cQuery += "And EE9_DTAVRB >= '" + DtoS(dDataIni) + "' "
         cQuery += "And EE9_DTAVRB <= '" + DtoS(dDataFin) + "' ) "
         //DFS - 09/11/2011 - Inclusão de tratamento para embarque simplificado.
         If EXL->(FieldPos("EXL_AVRBDS")) > 0 //.AND. !Empty(EXL->EXL_AVRBDS)  //DFS - 31/08/12 - Nopado, porque este tratamento já é testado na Query   //NCF - 06/12/2012
            cQuery += "OR EEC.EEC_PREEMB In (SELECT DISTINCT EXL_PREEMB "
            cQuery += "FROM " +RetSQLName("EXL") + " "
            cQuery += "Where D_E_L_E_T_ <> '*' "
            cQuery += "And EXL_FILIAL = '" + EXL->(xFilial()) + "' "
            cQuery += "And EXL_AVRBDS <> ' ' "
            cQuery += "And EXL_AVRBDS >= '" + DtoS(dDataIni) + "' "
            cQuery += "And EXL_AVRBDS <= '" + DtoS(dDataFin) + "' ) " //LGS-22/10/2013
         EndIf
         // EJA - 04/10/2018
         If EEC->(FieldPos("EEC_DUEAVR")) > 0
            cQuery += "OR EEC.EEC_PREEMB In (SELECT DISTINCT EEC_PREEMB "
            cQuery += "FROM " +RetSQLName("EEC") + " "
            cQuery += "Where D_E_L_E_T_ <> '*' "
            cQuery += "And EEC_FILIAL = '" + EEC->(xFilial()) + "' "
            cQuery += "And EEC_DUEAVR <> ' ' "
            cQuery += "And EEC_DUEAVR >= '" + DtoS(dDataIni) + "' "
            cQuery += "And EEC_DUEAVR <= '" + DtoS(dDataFin) + "' ) "            
         EndIf
         cQuery += " ) " //RNLP - OSSME-6048 - Fechamento do comando IN na query da data de averbação
      EndIf

      cQuery:= ChangeQuery(cQuery)
      DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "EMBARQ", .T., .T.)

      EMBARQ->(DBGoTop())

      While EMBARQ->(!Eof())

         AAdd(aEmbarques, EMBARQ->EEC_RECNO)

         EMBARQ->(DBSkip())
      EndDo

      EMBARQ->(DBCloseArea())
   #Else

      EEC->(DBSetOrder(12)) //EEC_FILIAL + DTOS(EEC_DTEMBA)
      EEC->(DBSeek(xFilial() + DtoS(dDataIni), .T.))

      While EEC->(!Eof()) .And.;
            EEC->EEC_DTEMBA <= dDataFin

         AAdd(aEmbarques, EEC->(RecNo()))

         EEC->(DBSkip())
      EndDo

   #EndIf

   EE9->(DBSetOrder(3)) //EE9_FILIAL + EE9_PREEMB + EE9_SEQEMB
   For nCont:= 1 To Len(aEmbarques)

      cId:= "0"
      EEC->(DBGoTo(aEmbarques[nCont]))
      EE9->(DBSeek(xFilial() + EEC->EEC_PREEMB))
      If EXL->(DBSeek(xFilial() + EEC->EEC_PREEMB))
        lVerDtAvb := (EXL->(FieldPos("EXL_AVRBDS")) > 0 .AND. !Empty(EXL->EXL_AVRBDS)) .OR. (EEC->(FieldPos("EEC_DUEAVR")) > 0 .AND. !Empty(EEC->EEC_DUEAVR))//DFS - 22/12/11 - Verificar se o campo existe e está preenchido para a variável ficar .T. //EJA - 09/10/2018 - Tratar novo campo EEC_DUEAVR
      EndIf


      While EE9->(!Eof()) .And.;
            EE9->EE9_FILIAL == EE9->(xFilial()) .And.;
            EE9->EE9_PREEMB == EEC->EEC_PREEMB

         // GFP - 11/11/2014 - Desconsiderar registro caso atender a todas as condições abaixo:
         	// Se o embarque é amostra
         	// Se o embarque é sem cobertura cambial
         	// Se o item não possui RE
         	// Se o item não possui DSE
         	// Se o valor total do item é inferior a US$ 1.000,00
         If EEC->EEC_AMOSTR == "1"   .AND.;
            EEC->EEC_MPGEXP == "006" .AND.;
            Empty(EE9->EE9_RE)       .AND.;
            Empty(EXL->EXL_DSE)
            If EEC->EEC_MOEDA == BuscaDolar()
               nTotItem := EE9->EE9_PRCTOT
            Else
               nTotItem := EE9->EE9_PRCTOT * BuscaTaxa(EEC->EEC_MOEDA, dDataBase,,.F.)
               nTotItem := nTotItem / BuscaTaxa(BuscaDolar(), dDataBase,,.F.)
            EndIf
            If nTotItem < 1000
               EE9->(DbSkip())
               Loop
            EndIf
         EndIf

         //TRP - 29/06/2011 - Desconsiderar os itens que possuírem o campo Data de Averbação não preenchido.
         If EasyGParam("MV_EEC0001",,"1") == "2"
            If Empty(EE9->EE9_DTAVRB) .AND. !lVerDtAvb //DFS - 09/11/2011 - Inclusão de tratamento para embarque simplificado.
               EE9->(DbSkip())
               Loop
            Endif
         EndIf

         cId:= EasySomaIt(cId)//DFS - 10/01/12 - Chamada da função que fará a leitura do id

         //Registro 1100
         GetReg1100Sped(EEC->EEC_PREEMB, cId)

         //Registro 1105
         GetReg1105Sped(EEC->EEC_PREEMB, cId, lConcFil)

         //Registro 1110
         ChkFile("EYY")
         If Select("EYY") > 0
            GetReg1110Sped(EEC->EEC_PREEMB, cId)
         EndIf

         EE9->(DBSkip())

      EndDo

   Next

End Sequence


RestOrd(aOrd, .T.)
Return __aTempSped



/*
Funcao    : CriaWorkSped()
Parâmetros:
Retorno   : Lógico (.T. ou .F.)
Objetivos : Criação das Works Sped1100, Sped1105 e Sped1110
Autor     : Wilsimar Fabrício da Silva
Data/Hora : 01/06/2010
Revisao   :
Obs.      :
*/

Static Function CriaWorkSped()
Local aEstrutura:= {}
Local cArq1100:= "SPED1100",;
      cArq1105:= "SPED1105",;
      cArq1110:= "SPED1110",;
      cErro   := ""
Local lRet:= .T.

Begin Sequence

   //Fechando as áreas de trabalho e apagando os arquivos, para caso haja alteração no leiaute
   //os arquivos sejam recriados com a estrutura correta.
   If Select(cAlias1100) > 0
      (cAlias1100)->(E_EraseArq(__aTempSped[1]))
      if Select(cAlias1100) > 0
         (cAlias1100)->(dbclosearea())
      endif
   EndIf

   If Select(cAlias1105) > 0
      (cAlias1105)->(E_EraseArq(__aTempSped[2]))
      if Select(cAlias1105) > 0
         (cAlias1105)->(dbclosearea())
      endif
   EndIf

   If Select(cAlias1110) > 0
      (cAlias1110)->(E_EraseArq(__aTempSped[3]))
      if Select(cAlias1110) > 0
         (cAlias1110)->(dbclosearea())
      endif
   EndIf


   //Apagando os arquivos e os índices
   If File(cArq1100 + GetDbExtension())
      If FErase(cArq1100 + GetDbExtension()) < 0
         cErro += cArq1100 + GetDbExtension() + ". " + STR0113 + AllTrim(Str(FError())) + "." + ENTER //Erro número
      EndIf

      If FErase(cArq1100 + TEOrdBagExt()) < 0
         cErro += cArq1100 + TEOrdBagExt() + ". " + STR0113 + AllTrim(Str(FError())) + "." + ENTER //Erro número
      EndIf
   EndIf

   If File(cArq1105 + GetDbExtension())
      If FErase(cArq1105 + GetDbExtension()) < 0
         cErro += cArq1105 + GetDbExtension() + ". " + STR0113 + AllTrim(Str(FError())) + "." + ENTER //Erro número
      EndIf

      If FErase(cArq1105 + TEOrdBagExt()) < 0
         cErro += cArq1105 + TEOrdBagExt() + ". " + STR0113 + AllTrim(Str(FError())) + "." + ENTER //Erro número
      EndIf
   EndIf

   If File(cArq1110 + GetDbExtension())
      If FErase(cArq1110 + GetDbExtension()) < 0
         cErro += cArq1110 + GetDbExtension() + ". " + STR0113 + AllTrim(Str(FError())) + "." + ENTER //Erro número
      EndIf

      If FErase(cArq1110 + TEOrdBagExt()) < 0
         cErro += cArq1110 + TEOrdBagExt() + ". " + STR0113 + AllTrim(Str(FError())) + "." + ENTER //Erro número
      EndIf
   EndIf


   If !Empty(cErro)
      MsgInfo(STR0142 + ENTER + cErro, STR0122) //Não foi possível criar o(s) arquivo(s) de trabalho. Verifique as informações abaixo: ##### / Atenção
      lRet:= .F.
      Break
   EndIf

   //Estrutura do arquivo de trabalho para o leiaute 1100
   aEstrutura:= {}
   AAdd(aEstrutura, {"PREEMB" , "C", 20, 0})
   AAdd(aEstrutura, {"ID"     , "C",  4, 0})
   AAdd(aEstrutura, {"REG"    , "C",  4, 0})
   AAdd(aEstrutura, {"IND_DOC", "C",  1, 0})
   AAdd(aEstrutura, {"NRO_DE" , "C", 14, 0}) //THTS - 01/03/2018 - Tamanho do campo alterado de 11 para 14 para atender processos com Numero DUE.
   AAdd(aEstrutura, {"DT_DE"  , "C",  8, 0})
   AAdd(aEstrutura, {"NAT_EXP", "C",  1, 0})
   AAdd(aEstrutura, {"NRO_RE" , "C", 12, 0})
   AAdd(aEstrutura, {"DT_RE"  , "C",  8, 0})
   AAdd(aEstrutura, {"CHC_EMB", "C", 18, 0})
   AAdd(aEstrutura, {"DT_CHC" , "C",  8, 0})
   AAdd(aEstrutura, {"DT_AVB" , "C",  8, 0})
   AAdd(aEstrutura, {"TP_CHC" , "C",  2, 0})
   AAdd(aEstrutura, {"PAIS"   , "C",  3, 0})

   cArq1100:=E_CriaTrab(,aEstrutura, cAlias1100)
   E_IndRegua(cAlias1100, cArq1100 + TEOrdBagExt(), "PREEMB + ID")
   __aTempSped[1]:= cArq1100

   //Estrutura do arquivo de trabalho para o leiaute 1105
   aEstrutura:= {}
   AAdd(aEstrutura, {"PREEMB"  , "C", 20, 0})
   AAdd(aEstrutura, {"ID"      , "C",  4, 0})
   AAdd(aEstrutura, {"REG"     , "C",  4, 0})
   AAdd(aEstrutura, {"COD_MOD" , "C",  2, 0})
   AAdd(aEstrutura, {"SERIE"   , "C",  3, 0})
   AAdd(aEstrutura, {"NUM_DOC" , "C",  9, 0})
   AAdd(aEstrutura, {"CHV_NFE" , "C", 44, 0})
   AAdd(aEstrutura, {"DT_DOC"  , "C",  8, 0})
   AAdd(aEstrutura, {"COD_ITEM", "C", 60, 0})

   //Criação do arquivo SPED1105
   cArq1105:=E_CriaTrab(,aEstrutura, cAlias1105)
   E_IndRegua(cAlias1105, cArq1105 + TEOrdBagExt(), "PREEMB + ID")
   __aTempSped[2]:= cArq1105


   //Estrutura do arquivo de trabalho para o leiaute 1110
   aEstrutura:= {}
   AAdd(aEstrutura, {"PREEMB"  , "C", 20, 0})
   AAdd(aEstrutura, {"ID"      , "C",  4, 0})
   AAdd(aEstrutura, {"REG"     , "C",  4, 0})
   AAdd(aEstrutura, {"COD_PART", "C", 60, 0})
   AAdd(aEstrutura, {"COD_MOD" , "C",  2, 0})
   AAdd(aEstrutura, {"SER"     , "C",  4, 0})
   AAdd(aEstrutura, {"NUM_DOC" , "C",  9, 0})
   AAdd(aEstrutura, {"DT_DOC"  , "C",  8, 0})
   AAdd(aEstrutura, {"CHV_NFE" , "C", 44, 0})
   AAdd(aEstrutura, {"NR_MEMO" , "C", 20, 0})
   AAdd(aEstrutura, {"QTD"     , "C", 20, 0})
   AAdd(aEstrutura, {"UNID"    , "C",  6, 0})

   //Criação do arquivo SPED1110
   cArq1110:=E_CriaTrab(,aEstrutura, cAlias1110)
   E_IndRegua(cAlias1110, cArq1110 + TEOrdBagExt(), "PREEMB + ID")
   __aTempSped[3]:= cArq1110

End Sequence


Return lRet


/*
Funcao    : GetReg1100Sped
Parâmetros: Número do processo de embarque;
            Id para amarração das works (juntamente com o número do processo).
Retorno   :
Objetivos : Dar carga no arquivo de trabalho SPED1100 com os dados referente ao registro 1100,
            conforme leiaute versão 2.0.0 da escrituração fiscal digital, ato COTEPE/ICMS nº 09,
            de 18 de abril de 2008, atualização: 17 de dezembro de 2009. Módulo: Exportação.
Autor     : Wilsimar Fabrício da Silva
Data/Hora : 27/04/2010
Revisao   : 01/05/2010
Obs.      :
*/

Static Function GetReg1100Sped(cProcesso, cId)
Local aOrd:= SaveOrd({"EXL", "SYQ"})
Local cExportador:= "",;
      cDeclExp   := "",;
      cExpDireta := "",;
      cNroDecl   := "",;
      cDataDecl  := "",;
      cPais      := ""
Local lNFsRem := .F. //LRS - 10/04/2017

Begin Sequence

	/* Registro 1100 - REGISTRO DE INFORMAÇÕES SOBRE EXPORTAÇÃO
	   Guia prático EFD versão 2.0.0. Atualização: 17/12/2009

	Campo			Descrição
	-------------------------------------------------------------
	REG		 		Texto fixo contendo “1100”
	IND_DOC			Informe o tipo de documento:
					0 – Declaração de Exportação;
					1 - Declaração Simplificada de Exportação.
	NRO_DE			Número da declaração
	DT_DE 			Data da declaração
	NAT_EXP 		Preencher com:
					0 - Exportação Direta
					1 - Exportação Indireta
	NRO_RE 			Nº do registro de Exportação
	DT_RE 			Data do Registro de Exportação
	CHC_EMB 		Nº do conhecimento de embarque
	DT_CHC 			Data do conhecimento de embarque
	DT_AVB 			Data da averbação da Declaração de exportação
	TP_CHC			Informação do tipo de conhecimento de embarque:
					01 – AWB;
					02 – MAWB;
					03 – HAWB;
					04 – COMAT;
					06 – R. EXPRESSAS;
					07 – ETIQ. REXPRESSAS;
					08 – HR. EXPRESSAS;
					09 – AV7;
					10 – BL;
					11 – MBL;
					12 – HBL;
					13 – CRT;
					14 – DSIC;
					16 – COMAT BL;
					17 – RWB;
					18 – HRWB;
					19 – TIF/DTA;
					20 – CP2;
					91 – NÂO IATA;
					92 – MNAO IATA;
					93 – HNAO IATA;
					99 – OUTROS.
	PAIS 			Código do país de destino da mercadoria (Preencher conforme tabela do SISCOMEX)
	-------------------------------------------------------------
	*/

   EXL->(DBSetOrder(1)) //EXL_FILIAL + EXL_PREEMB
   SYQ->(DBSetOrder(1)) //YQ_FILIAL + YQ_VIA
   SYA->(DBSetOrder(1))
   EYY->(DbSetOrder(3))  //EYY_FILIAL+EYY_PREEMB+EYY_PEDIDO+EYY_SEQUEN  //LRS - 10/04/2017

   EXL->(DBSeek(xFilial() + cProcesso))
   SYQ->(DBSeek(xFilial() + EEC->EEC_VIA))

   If Empty(EEC->EEC_EXPORT + EEC->EEC_EXLOJA)
      cExportador:= EEC->EEC_FORN + EEC->EEC_FOLOJA
   Else
      cExportador:= EEC->EEC_EXPORT + EEC->EEC_EXLOJA
   EndIf
   
   If EYY->(DBSeek(xFilial("EYY") + EE9->EE9_PREEMB + EE9->EE9_PEDIDO + EE9->EE9_SEQUEN))  //LRS - 10/04/2017 Localizar NFs Remessa
      lNFsRem := .T.
   EndIF

   //Exportação direta ou indireta
   If Empty(EE9->(EE9_FABR + EE9_FALOJA)) .Or. (cExportador == EE9->(EE9_FABR + EE9_FALOJA)) .OR.;
     (cExportador <> EE9->(EE9_FABR + EE9_FALOJA) .AND. !lNFsRem) //LRS - 10/04/2017
      cExpDireta:= "0" //direta
   Else
      cExpDireta:= "1" //indireta
   EndIf

   //Declaração de exportação ou declaração simplificada de exportação
   If !Empty(EE9->EE9_NRSD) .And. Empty(EXL->EXL_DSE)
      cDeclExp := "0"
      cNroDecl := EE9->EE9_NRSD
      cDataDecl:= DataSped(EE9->EE9_DTDDE)
   ElseIf Empty(EE9->EE9_NRSD) .And. !Empty(EXL->EXL_DSE)
      cDeclExp := "1"
      cNroDecl := EXL->EXL_DSE
      cDataDecl:= DataSped(EXL->EXL_DTDSE)
   ElseIf EEC->(FieldPos("EEC_NRODUE")) > 0 .And. !Empty(EEC->EEC_NRODUE) //5-Registrada DU-E ### THTS - 01/03/2018 - Se for processo DUE, envia o numero da DUE
      cDeclExp := "2"
      cNroDecl := EEC->EEC_NRODUE
      cDataDecl:= If(EEC->(FieldPos("EEC_DTDUE")) > 0, DataSped(EEC->EEC_DTDUE),DataSped(EXL->EXL_DTDSE))
   Else
      cDeclExp := ""
      cNroDecl := ""
      cDataDecl:= ""
   EndIf

   //WFS 23/02/11
   cNroDecl:= StrTran(cNroDecl, "/", "")
   cNroDecl:= StrTran(cNroDecl, "-", "")

   //TDF - 15/08/11 - Utiliza os 3 primeiros dígitos do campo YA_SISEXP para o país
   If SYA->(DBSeek(xFilial() + EEC->EEC_PAISDT)) .AND. SYA->(FieldPos("YA_SISEXP")) > 0
      cPais:= Substr(SYA->YA_SISEXP,1,3)
   Else
      cPais:= EEC->EEC_PAISDT
   EndIf

   //Inclusão de registros
   (cAlias1100)->(RecLock(cAlias1100, .T.))
   (cAlias1100)->PREEMB := EEC->EEC_PREEMB
   (cAlias1100)->ID     := cId
   (cAlias1100)->REG    := "1100"
   (cAlias1100)->IND_DOC:= cDeclExp
   (cAlias1100)->NRO_DE := cNroDecl
   (cAlias1100)->DT_DE  := cDataDecl
   (cAlias1100)->NAT_EXP:= cExpDireta
   (cAlias1100)->NRO_RE := EE9->EE9_RE
   (cAlias1100)->DT_RE  := DataSped(EE9->EE9_DTRE)
   (cAlias1100)->CHC_EMB:= EEC->EEC_NRCONH
   (cAlias1100)->DT_CHC := DataSped(EEC->EEC_DTCONH)

   If cDeclExp == "2" .And. EEC->(FieldPos("EEC_DUEAVR")) > 0 .And. !Empty(EEC->EEC_DUEAVR)
         (cAlias1100)->DT_AVB := DataSped(EEC->EEC_DUEAVR)
   Else 
        If lVerDtAvb //DFS - 22/12/11 - Inclusão de tratamento para enviar arquivos ao SPED, tanto pelos dados complementares quanto para os itens.
            (cAlias1100)->DT_AVB := DataSped(EXL->EXL_AVRBDS)
        Else
            (cAlias1100)->DT_AVB := DataSped(EE9->EE9_DTAVRB)
        EndIf
    Endif
   (cAlias1100)->TP_CHC := SYQ->YQ_TDC
   (cAlias1100)->PAIS   := cPais
   (cAlias1100)->(MsUnlock())

   If EasyEntryPoint("AVGETEXPSPED")
      ExecBlock("AVGETEXPSPED",.F.,.F.,"ALTERA_SPED_1100")
   Endif

End Sequence

RestOrd(aOrd, .T.)
Return Nil


/*
Funcao    : GetReg1105Sped
Parâmetros: Número do processo de embarque;
            Id para amarração das works (juntamente com o número do processo).
            lConcFil  - informa se a filial deve ser concatenada ao código do produto
Retorno   :
Objetivos : Dar carga no arquivo de trabalho SPED1105 com os dados referente ao registro 1105,
            conforme leiaute versão 2.0.0 da escrituração fiscal digital, ato COTEPE/ICMS nº 09,
            de 18 de abril de 2008, atualização: 17 de dezembro de 2009. Módulo: Exportação.
Autor     : Wilsimar Fabrício da Silva
Data/Hora : 28/04/2010
Revisao   : 02/06/2010
Obs.      :
*/


Static Function GetReg1105Sped(cProcesso, cId, lConcFil)
Local aOrd  := SaveOrd({"EEM", "SF2"})
Local cMod  := ""

Begin Sequence

	/* Registro 1105 - REGISTRO DE INFORMAÇÕES SOBRE EXPORTAÇÃO
	   Guia prático EFD versão 2.0.0. Atualização: 17/12/2009

	Campo			Descrição
	-------------------------------------------------------------
	REG				Texto fixo contendo "1105"
	COD_MOD			Código do modelo da NF, conforme tabela 4.1.1
	SERIE			Série da Nota Fiscal
	NUM_DOC			Número de Nota Fiscal de Exportação emitida pelo Exportador
	CHV_NFE			Chave da Nota Fiscal Eletrônica
	DT_DOC			Data da emissão da NF de exportação
	COD_ITEM		Código do item (campo 02 do Registro 0200)
	-------------------------------------------------------------
	*/

   EEM->(DBSetOrder(1)) //EEM_FILIAL + EEM_PREEMB + EEM_TIPOCA + EEM_NRNF + EEM_TIPONF
   SF2->(DBSetOrder(1)) //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL

   EEM->(DBSeek(xFilial() + AvKey(cProcesso, "EEM_PREEMB") + EEM_NF + AvKey(EE9->EE9_NF, "EEM_NRNF") + EEM_SD))
   SF2->(DBSeek(xFilial() + AvKey(EEM->EEM_NRNF, "F2_DOC") + AvKey(EEM->EEM_SERIE, "F2_SERIE") +;
                AvKey(EEC->EEC_IMPORT, "F2_CLIENTE") + AvKey(EEC->EEC_IMLOJA, "F2_LOJA")))


   //Modelo da nota fiscal
   If Empty(EEM->EEM_MODNF)
      cMod:= AModNot(SF2->F2_ESPECIE)
   Else
      cMod:= EEM->EEM_MODNF
   EndIf

   (cAlias1105)->(RecLock(cAlias1105, .T.))
   (cAlias1105)->PREEMB  := EEC->EEC_PREEMB
   (cAlias1105)->ID      := cId
   (cAlias1105)->REG     := "1105"
   (cAlias1105)->COD_MOD := cMod
   (cAlias1105)->SERIE   := EEM->EEM_SERIE
   (cAlias1105)->NUM_DOC := EEM->EEM_NRNF
   (cAlias1105)->CHV_NFE := SF2->F2_CHVNFE
   (cAlias1105)->DT_DOC  := DataSped(EEM->EEM_DTNF)
   If lConcFil
      (cAlias1105)->COD_ITEM:= EE9->EE9_COD_I + cFilAnt //SB1->(xFilial())
   Else
      (cAlias1105)->COD_ITEM:= EE9->EE9_COD_I
   EndIf
   (cAlias1105)->(MsUnlock())

End Sequence

RestOrd(aOrd, .T.)
Return


/*
Funcao    : GetReg1110Sped
Parâmetros: Número do processo de embarque;
            Id para amarração das works (juntamente com o número do processo).
Retorno   :
Objetivos : Dar carga no arquivo de trabalho SPED1105 com os dados referente ao registro 1105,
            conforme leiaute versão 2.0.0 da escrituração fiscal digital, ato COTEPE/ICMS nº 09,
            de 18 de abril de 2008, atualização: 17 de dezembro de 2009. Módulo: Exportação.
Autor     : Wilsimar Fabrício da Silva
Data/Hora : 28/04/2010
Revisao   : 02/06/2010
Obs.      :
*/


Static Function GetReg1110Sped(cProcesso, cId)
Local aOrd:= SaveOrd({"EXL", "EYY", "SF1", "SD1"})
Local cChave1, cChave2
Begin Sequence

	/* Registro 1110 - REGISTRO DE INFORMAÇÕES SOBRE EXPORTAÇÃO
	   Guia prático EFD versão 2.0.0. Atualização: 17/12/2009

	Campo			Descrição
	-------------------------------------------------------------
	REG				Texto fixo contendo "1110"
	COD_PART		Código do participante-Fornecedor da Mercadoria destinada à exportação (campo 02 do Registro 0150)
	COD_MOD			Código do documento fiscal, conforme a Tabela 4.1.1
	SER				Série do documento fiscal recebido com fins específicos de exportação
	NUM_DOC			Número do documento fiscal recebido com fins específicos de exportação
	DT_DOC			Data da emissão do documento fiscal recebido com fins específicos de exportação
	CHV_NFE			Chave da Nota Fiscal Eletrônica
	NR_MEMO			Número do Memorando de Exportação
	QTD				Quantidade do item efetivamente exportado
	UNID			Unidade do item (Campo 02 do registro 0190)
	-------------------------------------------------------------
	*/

   EXL->(DBSetOrder(1)) //EXL_FILIAL + EXL_PREEMB
   EYY->(DBSetOrder(1)) //EYY_FILIAL + EYY_PREEMB
   SF1->(DBSetOrder(1)) //F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO
   SD1->(DBSetOrder(2)) //D1_FILIAL + D1_COD + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA

   EXL->(DBSeek(xFilial() + cProcesso))

   cChave2:= EE9->EE9_PEDIDO + AvKey(AllTrim(EE9->EE9_SEQUEN), "EE9_SEQUEN")
   /* Este tratamento será realizado considerando duas situações.
      A primeira é um cenário mais recente, onde temos os campos EYY_PEDIDO, EYY_SEQUEN e EYY_QUANT. Neste
      cenário pode haver mais de um registro na tabela EYY correspondente à um item da tabela EE9. Estes
      campos devem estar preenchidos pois temos clientes onde esses campos passaram a existir quando já havia
      informação nesta tabela.
      A segunda situação, onde não há esses campos, será considerado o campo EYY_RE para localizar a nota
      fiscal de entrada vinculada ao item, porém o produto deve existir na tabela SD1. Neste cenário, a relação
      é um item da tabela EE9 para um da tabela EYY, não sendo necessário prosseguir com o laço da tabela EYY.*/

   //Somente haverá registros nesta tabela para exportação indireta
   If EYY->(DBSeek(xFilial() + AvKey(cProcesso, "EYY_PREEMB")))

      While EYY->(!Eof()) .And.;
            EYY->EYY_FILIAL == EYY->(xFilial()) .And.;
            EYY->EYY_PREEMB == cProcesso


         //Primeira situação
         If EYY->(FieldPos("EYY_PEDIDO")) > 0 .And. EYY->(FieldPos("EYY_SEQUEN")) > 0 .And.;
            !Empty(EYY->EYY_PEDIDO) .And. !Empty(EYY->EYY_SEQUEN)

			cChave1:= AvKey(EYY->EYY_PEDIDO, "EE9_PEDIDO") + AvKey(AllTrim(EYY->EYY_SEQUEN), "EE9_SEQUEN")

            //If EYY->(AllTrim(EYY_PEDIDO) + AllTrim(EYY_SEQUEN)) <> EE9->(AllTrim(EE9_PEDIDO) + AllTrim(EE9_SEQUEN))
			If cChave1 <> cChave2
               EYY->(DBSkip())
               Loop
            EndIf

            SF1->(DBSeek(xFilial() + EYY->(AvKey(EYY_NFENT , "F1_DOC") +;
                                           AvKey(EYY_SERENT, "F1_SERIE") +;
                                           AvKey(EYY_FORN  , "F1_FORNECE") +;
                                           AvKey(EYY_FOLOJA, "F1_LOJA"))))
            //Inclusão de registros
            Append1110(cId)

         //Segunda situação
         Else

            If AllTrim(EE9->EE9_RE) <> AllTrim(EYY->EYY_RE)
               EYY->(DBSkip())
               Loop
            EndIf

            //Consistindo a relação entre o produto, R.E. e nota fiscal de entrada.
            If !SD1->(DBSeek(xFilial() + AvKey(EE9->EE9_COD_I , "D1_COD") +;
                                         AvKey(EYY->EYY_NFENT , "D1_DOC") +;
                                         AvKey(EYY->EYY_SERENT, "D1_SERIE") +;
                                         AvKey(EYY->EYY_FORN  , "D1_FORNECE") +;
                                         AvKey(EYY->EYY_FOLOJA, "D1_LOJA")))
               EYY->(DBSkip())
               Loop
            EndIf

            //Inclusão de registros
            Append1110(cId)
            Exit
         EndIf

         EYY->(DBSkip())
      EndDo
   EndIf

End Sequence


RestOrd(aOrd, .T.)
Return Nil


/*
Funcao    : Append1110
Parâmetros:
Retorno   :
Objetivos : Inclusão de dados na work SPED1110
Autor     : Wilsimar Fabrício da Silva
Data/Hora : 02/06/2010
Revisao   :
Obs.      :
*/
Static Function Append1110(cId)
Local cQuantidade:= ""


Begin Sequence

   //DFS - 25/02/2013 - Alteração de ponto para vírgula nos valores passados para a variável cQuantidade
   If EYY->(FieldPos("EYY_QUANT")) > 0 .And. EYY->EYY_QUANT > 0
      cQuantidade:= StrTran(LTrim(Str(EYY->EYY_QUANT)),".",",")
   Else
      cQuantidade:= StrTran(LTrim(Str(EE9->EE9_SLDINI)),".",",")
   EndIf


   //Inclusão de registros
   (cAlias1110)->(RecLock(cAlias1110, .T.))
   (cAlias1110)->PREEMB  := EEC->EEC_PREEMB
   (cAlias1110)->ID      := cId
   (cAlias1110)->REG     := "1110"
    //Solicitado por Gustavo Garbelotti Rueda
   (cAlias1110)->COD_PART:= "SA2" + cFilAnt + EYY->(EYY_FORN + EYY_FOLOJA)
   (cAlias1110)->COD_MOD := AModNot(SF1->F1_ESPECIE)
   (cAlias1110)->SER     := EYY->EYY_SERENT
   (cAlias1110)->NUM_DOC := EYY->EYY_NFENT
   (cAlias1110)->DT_DOC  := DataSped(SF1->F1_EMISSAO)
   (cAlias1110)->CHV_NFE := SF1->F1_CHVNFE
   //NCF - 08/02/2012 - Memorando de Exportação por item
   If EYY->(FieldPos("EYY_NROMEX")) > 0 .And. !Empty(EYY->EYY_NROMEX)
      (cAlias1110)->NR_MEMO := EYY->EYY_NROMEX
   Else
      (cAlias1110)->NR_MEMO := EXL->EXL_NROMEX
   EndIf

   (cAlias1110)->QTD     := cQuantidade
   (cAlias1110)->UNID    := EE9->EE9_UNIDAD
   (cAlias1110)->(MsUnlock())

End Sequence
Return Nil


/*
Funcao    : DataSped
Parâmetros:
Retorno   : cData
Objetivos : Retornar a data no tipo caracter e formato DDMMAAAA
Autor     : Wilsimar Fabrício da Silva
Data/Hora : 02/06/2010
Revisao   :
Obs.      :
*/


Static Function DataSped(dData)
Local cData:= ""

Begin Sequence

   If Empty(dData)
      Break
   EndIf

   //Dia
   If Day(dData) < 10
      cData += "0"
   EndIf
   cData += LTrim(Str(Day(dData)))

   //Mês
   If Month(dData) < 10
      cData += "0"
   EndIf
   cData += LTrim(Str(Month(dData)))

   //Ano
   cData += LTrim(Str(Year(dData)))

End Sequence

Return cData

/*
Função      : ValidNCMProd
Parametros  : Nenhum
Retorno     : lRet - Retorno logico .t./.f.
Objetivos   : Validar o campo B1_ANUENTE do cadastro de produtos, do qual ao ser preenchido do campos B1_POSIPI(NCM)
              automaticamente preenchera o campos B1_ANUENTE com o valor do campo YD_ANUENTE do cadastro de NCM.
Autor       : André Ceccheto Balieiro
Data/Hora   : 06/05/2010
*/

Function ValidNCMProd()

local lRet := .t.

If ExistCpo("SYD",M->B1_POSIPI)
   M->B1_ANUENTE := SYD->YD_ANUENTE
Else
   lRet := .F.
EndIf

Return lRet

/*
Funcao          : AvRegOk(cAlias,cCampo)
Parametros      : cAlias   :=  Alias da tabela a ser consultada
                  cCampo   :=  Campo a ser checado, sera usado a relação do mesmo no SX9.
Retorno         : .F. caso a tabela relacionada esteja bloqueada e .T. caso não esteja.
Objetivos       : Validar o campo *ALIAS*_MSBLQL.
Autor           : AVERAGE
Data/Hora       : 08/06/10 - 15:30
Revisao         :
Obs.            : É importante que a relação entre as tabelas esteja cadastrado no SX9.
*/

Function AvRegOk(cAlias,cCampo)
Local cArea := Alias(), aOrd
Local cChaveSeek := "", cAliasSeek := ""
Local lRet := .T., i
Static cBuffer := ""
Static aBuffer := {}

DbSelectArea("SX9")

DbSetOrder(1)
If SX9->(DbSeek(cAlias))
   Begin Sequence

   DbSetOrder(2)
   If cBuffer <> cAlias
      cBuffer := cAlias
      aBuffer := {}

      SX9->(DbSeek(cAlias))
      While(SX9->X9_CDOM == cAlias)
         aAdd(aBuffer,{X9_LIGDOM,SX9->X9_EXPCDOM,Sx9->X9_USEFIL,SX9->X9_DOM})
         SX9->(DBSkip())
      EndDo
   EndIf

   For i := 1 To Len(aBuffer)
      If aBuffer[i][1] == "1"
         If AllTrim(cCampo) $ AllTrim(aBuffer[i][2])
            If aBuffer[i][3] == "S"
               cAliasSeek := aBuffer[i][4]
               cChaveSeek := xFilial(cAliasSeek) + &("M->(" + AllTrim(aBuffer[i][2]) + ")")
               Break
            Else
               cChaveSeek := &("M->(" + AllTrim(aBuffer[i][2]) + ")")
               cAliasSeek := aBuffer[i][4]
               Break
            EndIf
         EndIf
      EndIf
   Next i

   End Sequence

   If !Empty(cChaveSeek) .AND. (cAliasSeek)->(FieldPos(cAliasSeek+"_MSBLQL") > 0 .OR. FieldPos(SubStr(cAliasSeek,2,2)+"_MSBLQL") > 0)
      aOrd := SaveOrd(cAliasSeek)
      If (cAliasSeek)->(DbSeek(cChaveSeek))
         lRet := RegistroOk(SX9->X9_DOM)
      EndIf
      RestOrd(aOrd, .T.)
   EndIf
EndIf

If !Empty(cAlias)
   DbSelectArea(cAlias)
EndIf

Return lRet


/*
Função      : ValidUser
Parametros  : Nenhum
Retorno     : lRet - Retorno logico .t./.f.
Objetivos   : Validar se o usuário possui acesso para efetuar manuteção na rotina
Autor       : André Ceccheto Balieiro
Data/Hora   : 19/07/2010
*/

Function ValUserDesp(cAlias,cCampo, nOpcao)
local lRet:= .T.
local aSaveOrd := SaveOrd({cAlias})

DbSelectArea("SX3")
SX3->(DbsetOrder(2))
If SX3->(DbSeek(cCampo))
   If !(cNivel >= SX3->X3_NIVEL)
      If nOpcao ==  2         //cUserName
         MsgInfo("Usuário "+ Alltrim(cUserName) +" não possui permissão para Incluir informações nesta rotina")
         lRet:= .F.
      ElseIf nOpcao == 3
         MsgInfo("Usuário "+ Alltrim(cUserName) +" não possui permissão para Alterar informações nesta rotina")
         lRet:= .F.
      ElseIf nOpcao == 4
         MsgInfo("Usuário "+ Alltrim(cUserName) +" não possui permissão para Excluir informações nesta rotina")
         lRet:= .F.
      EndIf
   EndIf
EndIf

RestOrd(aSaveOrd, .t.)

Return lRet

/*-----------------------------------------------------------------------------
Funcao      : AddCpoUser
Parametros  : aCampos -> Array que deve receber o campo de usuário.
              cAlias  -> Alias da tabela corrente dos campos do array.
              cTipo   -> Tipo da estrutura (Enchoice/MsSelect/GetDB/GetDados.
              cAliasWk-> Alias do Arquivo Temporário
Retorno     : Array contendo os campos de usuário
Objetivos   : Adicionar campos de usuário nas Enchoices e Grids.
Autor       : Thiago Rinaldi Pinto
Data        : 27/09/2010
Hora        : 09:30
Obs.        :
Revisão     : fev/2017 - wfs
              Ordenação dos campos, conforme o dicionário de dados
-----------------------------------------------------------------------------*/
Function AddCpoUser(aCampos,cAlias,cTipo,cAliasWk, lOrdena)

Local aOrd:= {}
Local aCposOrd:= {}, nCont, nPos, xCampo

Default cAlias   := ""
Default cAliasWk := ""
Default cTipo    := ""
Default aCampos  := {}
Default lOrdena  := .F.

Private aCpos    := AClone(aCampos)

aOrd := SaveOrd("SX3",1)
SX3->(dbSeek(cAlias))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
   If (SX3->X3_PROPRI=="U"  .Or. lOrdena) .AND. X3Uso(SX3->X3_USADO) .And. (!IsBlind() .Or. SX3->X3_CONTEXT <> "V") //wfs - desconsiderar campos virutais nas rotinas automáticas
      If cTipo == "1"  //cTipo = "1" -> Enchoice/MsMGet
         If Ascan(aCpos,SX3->X3_CAMPO)==0 .And. SX3->X3_PROPRI == "U"
            AADD(aCpos,SX3->X3_CAMPO)
         Endif

         If lOrdena .And. AScan(aCpos, SX3->X3_CAMPO) > 0
            AAdd(aCposOrd, SX3->X3_CAMPO)
         EndIf

      Elseif cTipo == "2"  //cTipo = "2" -> MsSelect
         //DFS - 08/01/13 - Alteração da verificação, visto que, o array é multidimensional e não encontrava o campo.
         If Ascan(aCpos, {|x| ValType(x[1]) == "C" .And.  AllTrim(x[1]) == AllTrim(SX3->X3_CAMPO)}) == 0 .And. SX3->X3_PROPRI == "U"
            AADD(aCpos,{SX3->X3_CAMPO,,AVSX3(SX3->X3_CAMPO,AV_TITULO),AVSX3(SX3->X3_CAMPO,AV_PICTURE)})
         Endif

         If lOrdena .And. Ascan(aCpos, {|x| ValType(x[1]) == "C" .And.  AllTrim(x[1]) == AllTrim(SX3->X3_CAMPO)}) > 0
            AAdd(aCposOrd, {SX3->X3_CAMPO,, AVSX3(SX3->X3_CAMPO, AV_TITULO), AVSX3(SX3->X3_CAMPO, AV_PICTURE)})
         EndIf

      Elseif cTipo == "3"  //cTipo = "3" -> GetDB/GetDados
         If Ascan(aCpos, SX3->X3_CAMPO)==0 .And. SX3->X3_PROPRI == "U"
            AADD(aCpos,SX3->X3_CAMPO) //com fillgetdb/fillgetdados
         Endif

         If lOrdena .And. AScan(aCpos, SX3->X3_CAMPO) > 0
            AAdd(aCposOrd, SX3->X3_CAMPO)
         EndIf

      Elseif cTipo == "4"  //cTipo = "4" -> GetDB/GetDados
         If Ascan(aCpos,{|x| AllTrim(x[2]) == AllTrim(SX3->X3_CAMPO)})==0 .And. SX3->X3_PROPRI == "U"
            AADD(aCpos, {AVSX3(SX3->X3_CAMPO,5),SX3->X3_CAMPO,AVSX3(SX3->X3_CAMPO,6),AVSX3(SX3->X3_CAMPO,3),AVSX3(SX3->X3_CAMPO,4),nil,nil,AVSX3(SX3->X3_CAMPO,2),nil,nil })  //com GetDB/GetDados normal
         Endif

         If lOrdena .And. AScan(aCpos, {|x| AllTrim(x[2]) == AllTrim(SX3->X3_CAMPO)}) > 0
            AAdd(aCposOrd, {AVSX3(SX3->X3_CAMPO,5),SX3->X3_CAMPO,AVSX3(SX3->X3_CAMPO,6),AVSX3(SX3->X3_CAMPO,3),AVSX3(SX3->X3_CAMPO,4),nil,nil,AVSX3(SX3->X3_CAMPO,2),nil,nil })
         EndIf

      Elseif cTipo == "5" //cTipo = "5" -> Caso específico
         cTitulo := AVSX3(SX3->X3_CAMPO, AV_TITULO)//RMD - 08/12/17 - Melhoria de performance (não executar AVSX3 dentro do aScan)
         //DFS - 08/01/13 - Alteração da verificação, visto que, o array é multidimensional e não encontrava o campo.
         If Ascan(aCpos, {|x| x[3] == cTitulo})==0 .And. SX3->X3_PROPRI == "U"
            aAdd(aCpos,{&("{||" + cAliasWk + "->" + SX3->X3_CAMPO + " }"),"",AVSX3(SX3->X3_CAMPO,AV_TITULO),AVSX3(SX3->X3_CAMPO,AV_PICTURE)})
         Endif
         
         If lOrdena .And. AScan(aCpos, {|x| x[3] == cTitulo}) > 0
            AAdd(aCposOrd, {&("{||" + cAliasWk + "->" + SX3->X3_CAMPO + " }"),"",AVSX3(SX3->X3_CAMPO,AV_TITULO),AVSX3(SX3->X3_CAMPO,AV_PICTURE)})
         EndIf

      Endif
   EndIF
   SX3->(dbSkip())
Enddo


If lOrdena
   //Assume os campos conforme a ordem do dicionário de dados.
   aCpos:= AClone(aCposOrd)

   /* Adiciona os campos que não estão no dicionário de dados na posição mais próxima
      da implementada via programa (posição original)*/
   SX3->(DBSetOrder(2))
   nPos:= 1
   For nCont:= 1 To Len(aCampos)
      Do Case
         Case cTipo == "1" .Or. cTipo == "3"
            xCampo:= aCampos[nCont]

         Case cTipo == "2"
            xCampo:= aCampos[nCont][1]

         Case cTipo == "4"
            xCampo:= aCampos[nCont][2]

         OtherWise
            xCampo:= ""

      End Case

      If !Empty(xCampo) .And. (ValType(xCampo) <> "C" .Or. !SX3->(DBSeek(xCampo)))
         AAdd(aCpos, Nil)
         AIns(aCpos, nPos)
         aCpos[nPos]:= aCampos[nCont]
         nPos++ //ordenação de campos de usuário via dicionário de dados
      EndIf

      nPos++
      If nPos > Len(aCpos)
         nPos:= Len(aCpos)
      EndIf

   Next

EndIf

RestOrd(aOrd)

IF(EasyEntryPoint("AVGERAL"),Execblock("AVGERAL",.F.,.F.,{"CPOUSER",Procname()}),)

Return aCpos

/*-----------------------------------------------------------------------------
Funcao      : AddWkCpoUser
Parametros  : aCampos -> Array no qual será adicionado o campo de usuário
              cAlias  -> Alias da tabela corrente dos campo do array
Retorno     : Array contendo os campos de usuário
Objetivos   : Adicionar campos de usuário nas Works.
Autor       : Thiago Rinaldi Pinto
Data        : 27/09/2010
Hora        : 14:00
Obs.        :
-----------------------------------------------------------------------------*/
Function AddWkCpoUser(aCampos,cAlias)

Local aOrd:= {}

Default cAlias   := ""
Default aCampos  := {}

aOrd := SaveOrd("SX3",1)
SX3->(dbSeek(cAlias))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
   If SX3->X3_PROPRI=="U" .AND. X3Uso(SX3->X3_USADO)
      If Ascan(aCampos,SX3->X3_CAMPO)==0
         AADD(aCampos,{SX3->X3_CAMPO ,AVSX3(SX3->X3_CAMPO,AV_TIPO),AVSX3(SX3->X3_CAMPO,AV_TAMANHO),AVSX3(SX3->X3_CAMPO,AV_DECIMAL)})
      Endif
   EndIF
   SX3->(dbSkip())
Enddo
RestOrd(aOrd)

Return aCampos

/*
-----------------------------------------------------------------------------
Funcao      : GrvCpoUser
Parametros  : cAlias - Alias da Tabela no banco
              cAliasWk - Alias do Arquivo Temporário
Retorno     : Nil
Objetivos   : Gravar os campos de usuário.
Autor       : Thiago Rinaldi Pinto
Data        : 07/10/2010
Hora        : 13:50
Obs.        :
-----------------------------------------------------------------------------
*/
Function GrvCpoUser(cAlias,cAliasWk)

Local aOrd:= {}

   aOrd := SaveOrd("SX3",1)
   SX3->(dbSeek(cAlias))
   While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
      If SX3->X3_PROPRI=="U" .AND. X3Uso(SX3->X3_USADO) .and. (SX3->X3_ARQUIVO)->(FieldPos(SX3->X3_CAMPO)) > 0
         Eval(FieldWBlock(SX3->X3_CAMPO, Select(cAliasWk)),  Eval(FieldWBlock(SX3->X3_CAMPO, Select(cAlias))))
      EndIF
      SX3->(dbSkip())
   Enddo
   RestOrd(aOrd)

Return Nil


/*
aTabelas := {ALIAS,ALIAS2,...}
*/
Function AvExisteTab(aTabelas)
Local lRet := .T., lRetTab := .T.
Local i

//FDR - 18/06/13
Begin Sequence

If Select("SX2") == 0
   lRet := .F.
   Break
EndIf

If ValType(aTabelas) <> "A"
   aTabelas := {aTabelas}
EndIf

//Verifica existencia de tabelas
SX2->( dbSetOrder(1) )
For i := 1 to Len(aTabelas)
   lRetTab := SX2->(dbSeek(aTabelas[i])) .AND. ChkFile(aTabelas[i])
   lRet    := lRet .AND. lRetTab

   If !lRetTab .AND. Type("oLogFlags") == "O"
      oLogFlags:Warning("Não foi possível abrir a tabela: "+aTabelas[i])
   EndIf
Next

End Sequence

Return lRet

/*
aIndices := {{ALIAS,ORDEM},{ALIAS2,ORDEM2},...}
*/
Function AvExisteInd(aIndices)
Local lRet := .T., lRetInd := .T.
Local i

//Verifica existencia de indices
SIX->( dbSetOrder(1) )
For i := 1 to Len(aIndices)
   lRetInd := SIX->(dbSeek(aIndices[i][1]+aIndices[i][2]))
   lRet    := lRet .AND. lRetInd

   If !lRetInd .AND. Type("oLogFlags") == "O"
      oLogFlags:Warning("Indice não cadastrado: "+aIndices[i][1]+aIndices[i][2])
   EndIf
Next i

Return lRet

/*
aCampos := {{ALIAS,CAMPO},{ALIAS2,CAMPO2},...}
*/
Function AvExisteCampo(aCampos)
Local lRet := .T., lRetField := .T.
Local i
Local cCampo
local lLogFlags := IsMemVar("oLogFlags") 

//Verifica existencia de campos
SX3->( dbSetOrder(2) )
For i := 1 to Len(aCampos)
   If ValType(aCampos[i]) == "A"
      cCampo := aCampos[i][2]
   Else
      cCampo := aCampos[i]
   EndIf

   lRetField := SX3->(dbSeek(cCampo)) .AND. ( SX3->X3_CONTEXT == "V" .OR. (SX3->X3_ARQUIVO)->(ColumnPos(cCampo) > 0) )
   lRet      := lRet .AND. lRetField

   If !lRetField .and. lLogFlags
      oLogFlags:Warning("Campo não cadastrado: "+cCampo)
   EndIf
Next

Return lRet

/*
aFuncoes := {Funcao,Funcao2,...}
*/
Function AvExisteFunc(aFuncoes)
Local lRet := .T.,lRetFunc
Local i

//Verifica existencia das funções no repositório
For i := 1 to Len(aFuncoes)
   lRetFunc := FindFunction(aFuncoes[i])
   lRet := lRet .AND. lRetFunc

   If !lRetFunc .AND. Type("oLogFlags") == "O"
      oLogFlags:Warning("Função não compilada: "+aFuncoes[i])
   EndIf
Next

Return lRet

/*
aParam = {{MV_XXXXXX,uDefault},{MV_YYYYYY,uDefault2},{MV_ZZZZZZ,uDefault3},...}
*/
Function AvIsMvOn(aParam,cDefault)
Local lRet := .F.
Local i
Local xContent
Local cTipo

If ValType(aParam) == "C"
   aParam := {{aParam,cDefault}}
EndIf

If ValType(aParam[1]) == "C" .AND. Len(aParam) == 2
   aParam := {aClone(aParam)}
EndIf

For i := 1 To Len(aParam)

  If GetMv(aParam[i][1], .T.)
      xContent := EasyGParam(aParam[i][1]) 
      cTipo := ValType(xContent)
      If cTipo == "L"
         lRet := xContent
      ElseIf cTipo == "C"
         lRet := xContent $ cSim
      ElseIf cTipo == "N"
         lRet := xContent > 0
      EndIf
   EndIf

Next i

Return lRet

Function AvConvert(cTipoOri,cTipoDest,nTamDest,xValueOri)
Local xValueDest
Default cTipoOri := ValType(xValueOri)
Default nTamDest := 999

If cTipoOri == "U"
   If cTipoDest == "C"
      xValueDest := ""
   ElseIf cTipoDest == "N"
      xValueDest := 0
   ElseIf cTipoDest == "D"
      xValueDest := CTOD("  /  /  ")
   ElseIf cTipoDest == "L"
      xValueDest := .F.
   EndIf
ElseIf cTipoOri == "C"
   If cTipoDest == "C"
      xValueDest := xValueOri
   ElseIf cTipoDest == "N"
      xValueDest := Val(StrTran(xValueOri,",","."))
   ElseIf cTipoDest == "D"
      xValueDest := CTod(xValueOri)

      //Se a data convertida for vazia e a string de origem não for vazia, significa que nao foi possível converter com CToD
      If Empty(xValueDest) .AND. !Empty(xValueOri)
         xValueDest := STod(xValueOri)
      EndIf
   ElseIf cTipoDest == "L"
      xValueDest := Left(AllTrim(xValueOri),1) $ cSim
   ElseIf cTipoDest == "M"
      xValueDest := xValueOri
   EndIf
ElseIf cTipoOri == "D"
   If cTipoDest == "C"
      If nTamDest == 6
         xValueDest := StrZero(Day(xValueOri),2)+StrZero(Month(xValueOri),2)+Right(Str(Year(xValueOri)),2) //Formato DDMMAA
      Else
         xValueDest := AllTrim(Str(Day(xValueOri)))+"/"+AllTrim(Str(Month(xValueOri)))+"/"+Right(AllTrim(Str(Year(xValueOri))),2) //Formato DD/MM/AAAA
      EndIf
   ElseIf cTipoDest == "N"
      xValueDest := xValueOri-CTOD("01/01/1900") //Formato Excel
   ElseIf cTipoDest == "D"
      xValueDest := xValueOri
   ElseIf cTipoDest == "L"
      //ERRO
   ElseIf cTipoDest == "M"
      xValueDest := DToC(xValueOri)
   EndIf
ElseIf cTipoOri == "N"
   If cTipoDest == "C"
      xValueDest := AllTrim(Str(xValueOri))
   ElseIf cTipoDest == "N"
      xValueDest := xValueOri
   ElseIf cTipoDest == "D"
      xValueDest := CTOD("01/01/1900")+xValueOri //Formato Excel
   ElseIf cTipoDest == "L"
      xValueDest := xValueOri > 0
   ElseIf cTipoDest == "M"
      xValueDest := xValueOri
   EndIf
ElseIf cTipoOri == "L"
   If cTipoDest == "C"
      xValueDest := If(xValueOri,"S","N")
   ElseIf cTipoDest == "N"
      xValueDest := If(xValueOri,1,0)
   ElseIf cTipoDest == "D"
      //ERRO
   ElseIf cTipoDest == "L"
      xValueDest := xValueOri
   ElseIf cTipoDest == "M"
      xValueDest := If(xValueOri,"S","N")
   EndIf
ElseIf cTipoOri == "M"
   //Verificar
Endif

Return xValueDest

/*
Funcao      : VerLojaSX1
Parametros  : cGrupo - Grupo de perguntas do SX1
Retorno     : Nenhum
Objetivos   : Verifica se o campo loja existe no grupo informado para que seja adicionado.
Autor       : Allan Oliveira Monteiro
Data/Hora   : 04/01/2011 - 17:05
Revisao     :
Obs.        :
*/
/*

THTS - 27/07/2017 - Funcao NOPADA, pois nao podera mais utilizar RecLock nos fontes. Os fontes que chamavam esta funcao tiveram a chamada
comentada(EICAP151.PRW, EICHC150.PRW, EICTR330.PRW e EICTR600.PRW).
Todos eles estao com o campo loja digitado de forma correta no AtuSX.

*-------------------------------------------*
FUNCTION VerLojaSX1(cGrupo)
*-------------------------------------------*
Local cOrdIni,cOrdFim := "00", cHelp, cOrdem
Local nCont := 0, nInc , nRecno, nOrder
Local aAlterados:= {}, aHelp := {}, aDescr
Local aOrd := SaveOrd("SX1")
Local lLoja := .F., lDel := .F.

SX1->(DbSetOrder(1))
SX1->(Dbseek(AvKey(cGrupo,"X1_GRUPO")))
nRecno := SX1->(Recno())

While ALLTRIM(SX1->X1_GRUPO) == cGrupo

  //Procura ordem do Fornecedor para adicionar a Loja na ordem em seguida
  If "Fornecedor" $ SX1->X1_PERGUNT
     cOrdIni := SOMAIT(SX1->X1_ORDEM)
  EndIf

  //Verifica se Existe mais de um campo loja no SX1 e deleta os demais
  If "Loja" $ SX1->X1_PERGUNT
     If nCont > 0
        If SX1->(RecLock("SX1", .F.))
           SX1->(DbDelete())
        SX1->(MsUnlock())
        EndIf
        lDel := .T.
     EndIf
     nCont++
     lLoja := .T.
     If nCont > 1
        SX1->(DBSkip())
        Loop
     EndIf
  EndIf
cOrdFim := SOMAIT(cOrdFim)
If !Empty(SX1->X1_HELP)
   cHelp := SUBSTR(Ap5GetHelp(SX1->X1_HELP),1,At(".",Ap5GetHelp(SX1->X1_HELP)))
   AADD(aHelp,{SX1->X1_HELP,cHelp})
Else
   cHelp := SUBSTR(Ap5GetHelp("."+cGrupo+cOrdFim+"."),1,At(".",Ap5GetHelp("."+cGrupo+cOrdFim+".")))
   AADD(aHelp,{"."+cGrupo+cOrdFim+".",cHelp})
EndIf
SX1->(DBSkip())
EndDo

//Verifica se o campo Loja esta na posição correta
If !lLoja
   For nInc := Val(cOrdIni) To Val(cOrdFim)
      aAdd(aAlterados, {"mv_par" + StrZero(nInc, 2), "mv_par" + StrZero(nInc + 1, 2)})
   Next


   //Efetua a alteração  dos campos que estiverem  com a ordem acima do campo Loja
   nCont := 0
   SX1->(DbGoTo(nRecno))
   While ALLTRIM(SX1->X1_GRUPO) == cGrupo
      If Val(SX1->X1_ORDEM) > Val(cOrdIni) - 1
         Begin Transaction

         If SX1->(RECLOCK("SX1",.F.))
            nOrder := Val(SOMAIT(cOrdIni)) + nCont
            SX1->X1_ORDEM := If( nOrder< 10,StrZero(nOrder, 2),Str(nOrder))
            SX1->X1_VAR01 := "mv_par"+AllTrim(SX1->X1_ORDEM)
            For nInc := Len(aAlterados) To 1 Step -1
                If aAlterados[nInc][1] $ SX1->X1_VALID
                   SX1->X1_VALID := StrTran(SX1->X1_VALID, aAlterados[nInc][1], aAlterados[nInc][2])
                EndIf
            Next
            //Insere as descriçoes dos helps nos campos com as novas ordens
            For nInc := Val(cOrdIni) to Len(aHelp)
               If cGrupo+If(Val(SX1->X1_ORDEM)-1<10,StrZero(Val(SX1->X1_ORDEM)-1,2),Str(Val(SX1->X1_ORDEM)-1)) $ aHelp[nInc][1]
                  aDescr := {}
                  AADD(aDescr,aHelp[nInc][2])
                  PutHelp("P."+cGrupo+SX1->X1_ORDEM+".",aDescr,aDescr,aDescr,.T.)
                  Exit
               EndIf
            Next nInc
            nCont++
            SX1->(MsUnlock())
         EndIf

         End Transaction
      EndIf
   SX1->(DBSkip())
   EndDo

   //Adiciona o campo Loja no dicionario
   If SX1->(RECLOCK("SX1",.T.))
      SX1->X1_GRUPO   := cGrupo
      SX1->X1_ORDEM   := cOrdIni
      SX1->X1_PERGUNT := "Loja ?"
      SX1->X1_VARIAVL := "MV_CH0"
      SX1->X1_TIPO    := "C"
      SX1->X1_TAMANHO := 2
      SX1->X1_DECIMAL := 0
      SX1->X1_PRESEL  := 0
      SX1->X1_GSC     := "G"
      SX1->X1_VAR01   := "mv_par" + cOrdIni
      SX1->X1_PYME    := "N"
      SX1->(MsUnlock())
   EndIf

   aDescr := {}
   AADD(aDescr,"Loja.")
   PutHelp("P."+cGrupo+SX1->X1_ORDEM+".",aDescr,aDescr,aDescr,.T.)


ElseIf lDel

   nCont := 1
   //Efetua a ordem dos campos do SX1 do grupo EIR600 quando um ou mais campos forem deletados
   SX1->(DbGoTo(nRecno))
   While ALLTRIM(SX1->X1_GRUPO) == cGrupo
         If SX1->(RECLOCK("SX1",.F.))
            cOrdem := SX1->X1_ORDEM
            SX1->X1_ORDEM := If( nCont< 10,StrZero(nCont, 2),Str(nCont))
            SX1->X1_VAR01 := "mv_par"+AllTrim(SX1->X1_ORDEM)
            SX1->X1_VALID := StrTran(SX1->X1_VALID, "mv_par"+cOrdem,"mv_par"+SX1->X1_ORDEM)

            //Insere as descriçoes dos helps nos campos com as novas ordens
            For nInc := Val(cOrdIni) to Len(aHelp)
               If cGrupo+If(Val(SX1->X1_ORDEM)-1<10,StrZero(Val(SX1->X1_ORDEM)-1,2),Str(Val(SX1->X1_ORDEM)-1)) $ aHelp[nInc][1]
                  aDescr := {}
                  AADD(aDescr,aHelp[nInc][2])
                  PutHelp("P."+cGrupo+SX1->X1_ORDEM+".",aDescr,aDescr,aDescr,.T.)
                  Exit
               EndIf
            Next nInc
            nCont++
            SX1->(MsUnlock())
         EndIf
   SX1->(DBSkip())
   EndDo

   aDescr := {}
   AADD(aDescr,"Loja.")
   PutHelp("P."+cGrupo+cOrdIni+".",aDescr,aDescr,aDescr,.T.)
EndIf


RestOrd(aOrd)

Return Nil
*/

/*
Função      : AvRetInco(cIncoterm,cString)
Parametros  : cIncoterm := Incoterm que será testado
              cString   := Tipo de Incoterm
Retorno     : lRet - Retorno logico .t./.f.
Objetivos   : Tratamento individual para os Incoterms
Autor       : Flavio D. Ricardo
Data/Hora   : 23/12/2010 as 15:30hs
*/

Function AvRetInco(cIncoterm,cString)

Local lRet := .F.

Do Case

   Case cString == "CONTEM_FRETE"

      If cIncoterm $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP,DAT,DAP,DPU"//RMD - 02/01/20 - Adicionado o Incoterm DPU
         lRet := .T.
      EndIf

   Case cString $ "CONTEM_SEG|CONTEM_SEGURO" //LRS - 26/06/2018

      If cIncoterm $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP,DAP,DAT,DPU"//RMD - 02/01/20 - Adicionado o Incoterm DPU
         lRet := .T.
      EndIf

   Case cString == "CONTEM_FRETEN"

      If cIncoterm $ "CPT,CIP,DDU,DAP"
         lRet := .T.
      EndIf

End Case

Return lRet

/*
Função    : InsNInco()
Objetivos : Insere novos Incoterms na tabela SYJ
Parametros: -
Retorno   : Logico (True)
Autor     : Felipe S. Martinez (FSM)
Revisão   :
Data      : 28/12/2010 - 15:30
*/
Function InsNInco()
Local lRet := .T.

SYJ->(DbSetOrder(1))//YJ_FILIAL+YJ_COD

If !SYJ->(DbSeek(xFilial()+"DAT"))
   If Reclock("SYJ",.T.)
      SYJ->YJ_FILIAL  := xFilial()
      SYJ->YJ_COD     := "DAT"
      SYJ->YJ_DESCR   := "DELIVERED AT TERMINAL"
      SYJ->YJ_CLFRETE := "1"
      SYJ->YJ_CLSEGUR := "1"
      SYJ->YJ_FRPPCC  := "PP"
      SYJ->(MsUnlock())
   EndIf
EndIf

If !SYJ->(DbSeek(xFilial()+"DAP"))
   If Reclock("SYJ",.T.)
      SYJ->YJ_FILIAL  := xFilial()
      SYJ->YJ_COD     := "DAP"
      SYJ->YJ_DESCR   := "DELIVERED AT PLACE"
      SYJ->YJ_CLFRETE := "1"
      SYJ->YJ_CLSEGUR := "1"
      SYJ->YJ_FRPPCC  := "PP"
      SYJ->(MsUnlock())
   EndIf
EndIf

//RMD - 02/01/20 - Adicionado o Incoterm DPU
If !SYJ->(DbSeek(xFilial()+"DPU"))
   If Reclock("SYJ",.T.)
      SYJ->YJ_FILIAL  := xFilial()
      SYJ->YJ_COD     := "DPU"
      SYJ->YJ_DESCR   := "DELIVERED AT PLACE UNLOADED"
      SYJ->YJ_CLFRETE := "1"
      SYJ->YJ_CLSEGUR := "1"
      SYJ->YJ_FRPPCC  := "PP"
      SYJ->(MsUnlock())
   EndIf
EndIf

Return lRet

/*
Função    : EasyAsort()
Objetivos : Ordena os elementos de um vetor
Parametros: aArray   -
            nIni     -
            nLen     -
            bCompara -
Retorno   : Array
Autor     : Alessandro Alves Ferreira - AAF
Revisão   :
Data      : 23/02/11
*/
Function EasyAsort(aArray,nIni,nLen,bCompara)
Local i
Local nTam

If ValType(aArray) == "A" .AND. Len(aArray) > 0

   nTam := Int(log(Len(aArray))/log(10))+1

   For i := 1 To Len(aArray)
      aArray[i] := {aArray[i],StrZero(i,nTam)}
   Next i

   If ValType(nAux := Eval(bCompara,aArray[1][1],aArray[1][1])) == "N" .AND. nAux == 0
      aSort(aArray,nIni,nLen,{|X,Y| nAux := Eval(bCompara,X[1],Y[1]),If(nAux == 0,X[2]<Y[2],nAux > 0)})
   EndIf

   For i := 1 To Len(aArray)
      aArray[i] := aClone(aArray[i][1])
   Next i

EndIf

Return aArray
/*
Função    : ComparaPeso()
Objetivos : Efetua multiplicação do campos quantidade e peso liquido e compara com o campo de peso total, para que
            caso a quantidade totoal ultrapasse o limite do peso total não permite que continue a gravação do processo.
Parametros: nCampo1 - Campo de quantidade - a quantidade.
			nCampo2 - Campo do peso liquido.(Se vier do PO, Li ou desembaraço) - o valor
		    nCampo2 - Campo do peso total. (Se vier do recebimento de importação)
			cCampo3 - Campo do peso total a ser comparado
			lNFE - Flag que indica se o tratamento vem do recebimento de importação.
Retorno   : Logico
Autor     : André Ceccheto Balieiro
Revisão   :
Data      : 25/02/2011
*/
Function ComparaPeso(nCampo1,nCampo2,cCampo3,lNFE,lExibeMsg)

Local lRet := .T.
Local nAuxCpo1e2
Local nAuxPsTotTam := AVSX3(cCampo3, AV_TAMANHO) - (AVSX3(cCampo3, AV_DECIMAL)+1)  //Pega os inteiro do campos a ser comparado
Local nAuxTam := AVSX3(cCampo3, AV_TAMANHO)
Local nAuxDec := AVSX3(cCampo3, AV_DECIMAL)
Local cPicture:= Replicate("9", nAuxPsTotTam) + "." + Replicate("9", nAuxDec)

Default lExibeMsg := .T.
Default nCampo1:= 1
Default nCampo2:= 1

Private lMsg:= lExibeMsg

nAuxCpo1e2 := (nCampo1 * nCampo2)

If EasyEntryPoint("AVGERAL")
   ExecBlock("AVGERAL", .F., .F., "COMPARAPESO_MENSAGEM")
EndIf

//IF Log(nAuxCpo1e2)/log(10) > nAuxPsTotTam .And. lExibeMsg //Calcula os numero inteiros da multiplicação de qtde e peso liq e compara com o campo de peso total.
If nAuxCpo1e2 > Val(Transform(Replicate("9", nAuxTam), cPicture)) .And. lMsg //Calcula os numero inteiros da multiplicação de qtde e peso liq e compara com o campo de peso total.
   IF !lNFE
      //MsgInfo(STR0143 ,STR0122) //A quantidade e o peso liquido unitário informados, ao serem multiplicados, ocasionarão um estouro no valor do peso total. Favor rever os valores informados ou ajustar o tamanho do campo relacionado. - Atenção
      MsgInfo(STR0143 + AllTrim(AVSX3(cCampo3, AV_TITULO)) + " - " + AllTrim(cCampo3) + "." + ENTER +; //"A quantidade e/ ou o peso informado(s) ultrapassa(m) o valor suportado pelo campo "
              STR0145 + ENTER +; //"Por favor reveja os valores informados nos campos relacionados ou realize os ajustes de tamanho no dicionário de dados."
              STR0146 + AllTrim(AVSX3(cCampo3, AV_TITULO)) + " - " + AllTrim(cCampo3) + ENTER +; //"Campo: "
              STR0147 + cPicture + ENTER +; //"Valor suportado: "
              STR0148 + AllTrim(Str(nAuxCpo1e2)), STR0122) //"Valor enviado: "
      lRet := .F.
   Else
      MsgInfo(STR0144 + ENTER +; //"Esta nota fiscal não será gerada devido ao valor do peso total ter ultrapassando o seu limite."
              STR0145 + ENTER +; //"Por favor reveja os valores informados nos campos relacionados ou realize os ajustes de tamanho no dicionário de dados."
              STR0146 + AllTrim(AVSX3(cCampo3, AV_TITULO)) + " - " + AllTrim(cCampo3) + ENTER +; //"Campo: "
              STR0147 + cPicture + ENTER +; //"Valor suportado: "
              STR0148 + AllTrim(Str(nAuxCpo1e2)), STR0122) //"Valor enviado: "
      lRet := .F.
   EndIf
EndIf

Return lRet

/*
Função    : EasyCallMVC()
Objetivos : Verifica se a função existe na versão 11
Parametros: cFunc - Nome da Função
Retorno   : Logico (True)
Autor     : Allan Oliveira Monteiro (AOM)
Revisão   :
Data      : 14/03/2011
*/
*--------------------------*
Function EasyCallMVC(cFunc,nVer)
*--------------------------*
Local lRet := .F.

   If EasyHasMVC(nVer) .And. FindFunction(cFunc)
      &(cFunc+"()")
      lRet := .T.
   EndIf

Return lRet



/*
Função    : EasyHasMVC()
Objetivos : Verifica a versão do sistema
Parametros: -
Retorno   : Logico (True)
Autor     : Allan Oliveira Monteiro (AOM)
Revisão   :
Data      :
*/
*--------------------*
Function EasyHasMVC(nVer)
*--------------------*
Local lMVC := .T.
Default nVer := 1  //EasyGParam("MV_AVG0203",,0)

//   If EasyGParam("MV_AVG0203",,1) >= nVer  //Verifica se a versao atual é igual ou superior do MVC
//      lMVC := .T.
//   EndIf

Return lMVC

/*
Função    : EasyMVCGrava()
Objetivos : Tratar o bCommit com os campos memos no padrão MVC
Parametros: oMdl,cAlias
Retorno   : -
Autor     : Clayton Reis Fernandes (CRF)
Revisão   :
Data      : 25/03/2011
*/
Function EasyMVCGrava(oMdl,cAlias)
Local aArea			:= Getarea()
Local nOperation	:= oMdl:GetOperation()
Local bAfter		:= {|oMdl,cId,cAlias,lNewRec,nOperation|MVCGravaMemo(oMdl,cId,cAlias,aMemos)}
Local cFilAlias		:= xFilial(cAlias)

FWModelActive(oMdl)
FWFormCommit(oMdl,,bAfter)

RestArea(aArea)

Return(.T.)

/*
Função    : MVCGravaMemo()
Objetivos : Tratar a gravação do campo memo no padrão MVC
Parametros: oMd,cId,cAlias,aCampos
Retorno   : -
Autor     : Clayton Reis Fernandes (CRF)
Revisão   :
Data      : 25/03/2011
*/

//aCampos = {{real,virtual},....}
Function MVCGravaMemo(oMd,cId,cAlias,aCampos)
Local cMemo	:= ""
Local oMdl  := oMd:GetModel(cId)
Local nOperation := oMdl:GetOperation()
Local i
Default aCampos  := {} //LRS - 06/11/2017

For i := 1 To Len(aCampos)
    If SX3->(dbSetOrder(2),dbSeek(aCampos[i][1]),X3_ARQUIVO) == cAlias
	   If nOperation == 4 .Or. nOperation == 3
		  cMemo	:= oMdl:GetValue(cId,aCampos[i][2])
		  If nOperation == 4
             MSMM(&((cAlias)+"->"+(aCampos[i][1])),,,,2)
          EndIf
          MSMM(,AVSX3(aCampos[i][2],AV_TAMANHO),,cMemo,1,,,cAlias,aCampos[i][1])
       ElseIf nOperation == 5
	      If !Empty(&(cAlias+"->"+aCampos[i][1]))
		     MSMM(&((cAlias)+"->"+(aCampos[i][1])),,,,2)
          EndIf
       EndIf
    EndIf
Next i

Return(.T.)


*---------------------*
Function APE100JUROS()
*---------------------*

Local lRet := .T.

Return lRet

/*
Função    : FiltroNCM()
Objetivos : Filtro dinâmico
Retorno   : cRetFiltro
Autor     : Diogo Felipe dos Santos
Data      : 08/06/2011 - 09:45
*/

*-------------------*
Function FiltroNCM()
*-------------------*
Local cCampoBusca := ReadVar()
Local lRetFiltro  := .T.

Do Case
   Case cCampoBusca == "M->W3_EX_NCM"
      lRetFiltro := M->W3_TEC == SYD->YD_TEC
   Case cCampoBusca == "M->W3_EX_NBM"
      lRetFiltro := M->W3_TEC == SYD->YD_TEC .AND. M->W3_EX_NCM == SYD->YD_EX_NCM
   Case cCampoBusca == "M->W7_EX_NCM"
      lRetFiltro := M->W7_NCM == SYD->YD_TEC
   Case cCampoBusca == "M->W7_EX_NBM"
      lRetFiltro := M->W7_NCM == SYD->YD_TEC .AND. M->W7_EX_NCM == SYD->YD_EX_NCM
EndCase

Return lRetFiltro

/*
Função    : EasySeekAuto()
Objetivos : Funcao Seek(posicionamento) para rotinas automaticas (ExecAuto)
Parametros: cAlias
			aSeek
			nOrder
			aCorresp
			oObj
Retorno   : Nil
Autor     : Thiago Rinaldi Pinto
Revisão   : 04/01/2012 - Nilson (Integ.LOGIX)
Data      : 18/05/2011
*/
*------------------------------------------------------*
Function EasySeekAuto(cAlias,aSeek,nOrder,aCorresp,oObj,cIndexKey)
*-------------------------------------------------------*
Local nSetOrder
Local nLen
Local nAt
Local nPos,nPosC
Local ni
Local i

Local cChave := ""
Local cCampo
Local cMacro := ""
Local bMacro
Local cVar

Local aConteudo := {}

Local aSeekClone, aIndexKey

Local lRet := .T.
Local cMsg := "" //FSM - 21/05/2012

Local bLastHandler

Private lErro:= .F.

Default aCorresp:= {}
Default aSeek   := {}

//aSeekClone := aClone(aSeek)//FSM - 21/05/2012

If nOrder <> Nil
    nSetOrder := nOrder
ElseIf Type("aOrderAuto") == "A" .AND. (nPosOrder := aScan(aOrderAuto,{|X| X[1] == cAlias})) > 0
    nSetOrder := aOrderAuto[nPosOrder][2]
Else
	nSetOrder := 1
EndIf

//FSM - 21/05/2012
/*If Len(aCorresp) > 0 .AND. Len(aSeekClone) > 0
   For i:= 1 to Len(aSeekClone)
      nPosC:= aScan(aCorresp, {|x|x[1] == aSeekClone[i][1]})
      If nPosC > 0
         aSeekClone[i][1]:= aCorresp[nPosC][2]
      Endif
   Next i
Endif   */

DbSelectArea(cAlias)
DbSetOrder(nSetOrder)

If ValType(cIndexKey) <> "C"
   cIndexKey := IndexKey() // + "+" //FSM - 21/05/2012
EndIf

Begin Sequence
    //FSM - 21/05/2012
	If "_FILIAL" $ cIndexKey
       nAt := At("+",cIndexKey)
       cCampo := AllTrim(Subs(cIndexKey,1,nAt - 1))
       &("M->"+cCampo) := xFilial()
    EndIf

   If Len(aCorresp) > 0
      For i := 1 To Len(aCorresp)
          If ( nPos := aScan(aSeek, {|x| AllTrim(UPPER(x[1])) == AllTrim(UPPER(aCorresp[i][1])) }) ) > 0
              //RMD - 06/01/16 - Incluído AvKey para acertar o conteúdo, da mesma forma que é tratado quando não tem conteúdo no array aCorresp.
              //&("M->"+aCorresp[i][2]) := aSeek[nPos][2]
              If ValType(aSeek[nPos][2]) <> "C" .OR. aSeek[nPos][1] == "AUTDELETA" .OR. aSeek[nPos][1] == "AUTCANCELA"
	             &("M->"+aCorresp[i][2]) := aSeek[nPos][2]
	          Else
                 &("M->"+aCorresp[i][2]) := AvKey(aSeek[nPos][2], aSeek[nPos][1])
              EndIf
          EndIf
      Next

   Else

      For i := 1 To Len(aSeek)
         //RRC - 17/06/2013 - Acrescentada condição para verificar se o conteúdo a ser passado para AvKey é nulo, adaptação à versão P10
         //NCF - 11/09/2013 - Ajustado para não fazer Avkey em campos do tipo DATA
         If ValType(aSeek[i][2]) <> "U"
            If ValType(aSeek[i][2]) <> "C" .OR. aSeek[i][1] == "AUTDELETA" .OR. aSeek[i][1] == "AUTCANCELA"  // GFP - 10/12/2013
               &("M->"+aSeek[i][1]) := aSeek[i][2]                                                           // NCF - 05/08/2014 - Verificar também Cancelamento
            Else
               &("M->"+aSeek[i][1]) := AvKey(aSeek[i][2],aSeek[i][1])
            EndIf
         EndIf
      Next
   EndIf
   
   //RMD - 11/07/16 - Caso algum campo da chave não tenha sido informado, cria com conteúdo em branco.
   aIndexKey := StrTokArr(cIndexKey, "+")
   SX3->(DbSetOrder(2))
   aEval(aIndexKey, {|x| If(Type("M->"+x) == "U" .And. SX3->(DbSeek(x)), &("M->" + x) := CriaVar(x, .F.),Nil) })
   
   //Monta chave
   /* comentado por wfs - alterado para ErrorBlock
   TRY
      cChave := M->(&((cAlias)->(cIndexKey)))
   CATCH
      cMsg := "Erro ao montar a chave do registro da tabela "+cAlias+". Verifique se todos os campos da chave "+cIndexKey+" foram informados."
      If ValType(oObj) == "O"
         oObj:Error(cMsg)
	  Else
         EasyHelp(cMsg)
	  EndIf
      lRet := .F.
      BREAK
   ENDTRY*/

   cMsg := "Erro ao montar a chave do registro da tabela "+cAlias+". Verifique se todos os campos da chave "+cIndexKey+" foram informados."
   If ValType(oObj) == "O"
      bLastHandler := ErrorBlock({|| oObj:Error(cMsg), lErro:= .T., .F.})
   Else
      bLastHandler := ErrorBlock({|| EasyHelp(cMsg), lErro:= .T., .F.})
   EndIf

   cChave := M->(&((cAlias)->(cIndexKey)))

   ErrorBlock(bLastHandler)

   If lErro
      lRet:= .F.
      Break
   EndIf

/* //FSM - 21/05/2012
While !Empty(cIndexKey)

      If "(" $ cCampo
			nAt := At("(",cCampo)
			cCampo := Subs(cCampo,nAt+1,At(")",cCampo,nAt)-1)
		EndIf

		nPos := Ascan(aSeekClone,{|x| Upper(AllTrim(x[1])) $ cCampo})
		If nPos > 0
		   If ValType(aSeekClone[nPos][2]) == "D"
		      cMacro := "DTOS(aSeekClone[nPos][2])"
		   ElseIf ValType(aSeekClone[nPos][2]) == "N" //FSM - 21/05/2012
		      cMacro := ""
		   Else
   	          cMacro := "aSeekClone[nPos][2]"
           EndIf

		   bMacro := &("{|| " + cMacro + "}")
		   cChave += Eval(bMacro)

		   Aadd(aConteudo,cCampo + " := " + cValToChar(aSeekClone[nPos][2]))
		Else
		   //Exit
		   If ValType(oObj) == "O"
		      oObj:Error("Campo "+cCampo+" não informado entre os campos para chave única de busca ")
		      lRet := .F.
		      BREAK
           EndIf
		EndIf
	EndIf
End*/

If !DbSeek(cChave)
   lRet := .F.
EndIf

End Sequence

Return lRet


/*
Função    : AvKeyAuto()
Objetivos : Formatar a informacao contida em um array, de acordo com o SX3 - Utilizacao para rotinas automaticas;
Parametros: aAutoArray - Array que tera suas informacoes formatadas com base nos campos do SX3;
Retorno   : Lógico - .T. quando o arryay tiver sido ajustado, .F. quando a funcao nao conseguir formatar as informacoes;
Autor     : Tiago Henrique Tudisco dos Santos
Data      : 15/08/2018
*/
Function AvKeyAuto(aAutoArray)
Local aArea	:= SX3->(getArea())
Local lRet  := .T.
Local nI
Private cConteudo     := ""

If ValType(aAutoArray) == "A"
   For nI := 1 To Len(aAutoArray)
      If ValType(aAutoArray[nI][2]) == "C" .AND. ( SX3->(dbsetorder(2),dbseek(aAutoArray[nI][1])) .and. SX3->X3_TIPO # "M") //MPG-10/01/2020
         If substr( aAutoArray[nI][1], at("_",aAutoArray[nI][1]) , len(aAutoArray[nI][1])) $ "_SEQEMB|_SEQUEN"
            cConteudo := AvKey(Val(aAutoArray[nI][2]),aAutoArray[nI][1])
         Else
            cConteudo := AvKey(aAutoArray[nI][2],aAutoArray[nI][1])
         EndIf
         If !Empty(cConteudo) .And. !(cConteudo == aAutoArray[nI][2])
            If EasyEntryPoint("AVKEYAUTO")
               ExecBlock("AVKEYAUTO", .F., .F., {aAutoArray[nI][1], aAutoArray[nI][2]})
            EndIf
            aAutoArray[nI][2] := cConteudo
         EndIf
         cConteudo := ""
      EndIf
   Next
Else
   lRet := .F.
EndIf

restArea(aArea)

Return lRet


*-----------------------------------*
Function EasyHelp(cText,cTit,cSolucao)
*-----------------------------------*
Local cHelpTit
Local cHelpText := StrTran(cText,Chr(13)+Chr(10)," ")//"##"+Repl("A",10)+Repl(Chr(13)+Chr(10),20)+"##"
Local aSolucao  := {}
Default cTit := "Aviso"
Default cSolucao := ""

cHelpTit  := StrTran(cTit ,Chr(13)+Chr(10)," ")//"##TITULO##"

aSolucao := IF(!Empty(cSolucao), {cSolucao}, aSolucao := Nil     )

Help("",1,"AVG",cHelpTit,cHelpText,1,0,.F.,,,,,aSolucao)

Return Nil



/* ============================================================ *
Funcao      : EasyIsExeInstalled
Parametros  : cPrograma - (C) - Nome do programa a ser verificado
              se esta instalado.
              cFolderPath - (C) - Diretorio onde será criado o .txt
              com o retorno da verificação de instalação.
Retorno     : lRet - .T./.F.
Objetivos   : Verificar se o programa informado esta instalado na
              maquina do CLIENT para o sistema operacional Windows.
Autor       : Felipe S. Martinez
Data/Hora   : 20/10/2011
Revisao     :
Data/Hora   :
Obs.        : Caso o diretório do txt não seja informado,ele será
              craido no temp do cliente.
* ============================================================= */
Function EasyIsExeInstalled(cPrograma,cFolderPath,nOpc,cFolderExe)
Local lRet := .F.
Local cFileTxt := "\RetornoIsInstalled.txt"
Local cFileVBS := '\Isinstalled.vbs'
Local cString := ""
Local nTamArq := 0

Default cPrograma := ""
Default cFolderPath := GetTempPath()
Default nOpc := 1
Default cFolderExe := ""

Begin Sequence

   //Verificando se o ambiente é Windows:
   If GetRemoteType() == 2 //Client em Linux //IsSrvUnix() // Linux/Unix -> .T. / Windows -> .F. //FSM - 06/07/2012
      lRet := .F.
      MsgInfo(STR0238,STR0150) //#STR0238->"É recomendado utilizar a função 'EasyIsExeInstalled' somente em ambientes Windows." ##STR0150->"Atenção"
      Break
   EndIf

   If Empty(cPrograma)
      lRet := .F.
      MsgInfo(STR0239,STR0150) //#STR0239->"Programa não informado!" ##STR0150->"Atenção"
      Break
   EndIf

   If Empty(cFolderPath)
      lRet := .F.
      MsgInfo(STR0240,STR0150)//#STR0240->"Caminho para criação do .txt e .vbs não informado!" ##STR0150->"Atenção"
      Break
   Else

      //Verifica se o caminho termina com "\" se sim, ela é retirada:
      If Rat("\",cFolderPath) == Len(cFolderPath)
         cFolderPath := Substr(cFolderPath,1, Len(cFolderPath)-1)
      EndIf

   EndIf

   //Cria VBScript para verificação do programa:
   CriaVBSIsInstalled(cPrograma,cFolderPath,cFileTxt,cFileVBS,nOpc,cFolderExe)

   //Processa o VBScript para validação:
   Processa({|| lRet := WaitRun('wscript.exe "'+cFolderPath+cFileVBS+ '"')},STR0241) //#STR0241->"Verificando Programas Instalados..."

   cString := TxtRetFileRead(cFolderPath+cFileTxt)
   lRet := If(".T." $ (cString), .T., .F.)

   //Apagando o txt com o retorno da funcao:
   FErase(cFolderPath+cFileTxt)
   FErase(cFolderPath+cFileVBS)

End Sequence

Return lRet



/* ============================================================ *
Funcao      : CriaVBSIsInstalled
Parametros  : cPrograma - (C) - Nome do programa a ser verificado
              se esta instalado.
              cFolderPath - (C) - Diretorio onde será criado o .txt
              com o retorno e o .vbs de verificação de instalação.
              cFileTxt - (C) - Nome do arquivo txt + .txt
              cFileVbs - (C) - Nome do arquivo vbs + .vbs
Retorno     : lRet - .T./.F.
Objetivos   : Cria o VBScript para verificar se o programa esta instalado
Autor       : Felipe S. Martinez
Data/Hora   : 20/10/2011
Revisao     :
Data/Hora   :
Obs.        : Caso o nome do arquivo txt e do vbs não sejam
              informado, eles serão criados com o nome default.
* ============================================================= */
Static Function CriaVBSIsInstalled(cPrograma,cFolderPath,cFileTxt,cFileVbs,nOpc,cFolderExe)
Local lRet := .T.
Local cVbs := ""
Local nHandler := 0

Default cFileTxt := "\RetornoIsInstalled.txt"
Default cFileVbs := "\Isinstalled.vbs"
Default nOpc := 1
Default cFolderExe := ""

Begin Sequence


   cVbs := "On Error Resume Next" + ENTER
   cVbs += "Const HKEY_LOCAL_MACHINE = &H80000002" + ENTER
   cVbs += "Dim cLog, fso, ShowAbsolutePath, strText,ltemPrograma, strComputer, strPrograma, WshShell, oReg, strKeyPath, arrSubKeys, SubKey, strDisplayName" + ENTER
   cVbs += "ltemPrograma = false" + ENTER
   cVbs += "strComputer = " + '"."' + ENTER
   cVbs += 'strPrograma = "' + cPrograma +'"' + ENTER
   cVbs += 'strText = ".F."' + ENTER
   cVbs += 'cFolder = "' + cFolderPath + '"' + ENTER
   cVbs += 'cLog = "'  + cFolderPath+cFileTxt + '"' + ENTER

   If nOpc == 1 //Codigo para verificar se o programa esta instalado.

      cVbs += "Set WshShell = CreateObject(" + '"wscript.Shell"' + ")" + ENTER
      cVbs += "Set oReg = GetObject(" + '"'+ "winmgmts:{impersonationLevel=impersonate}!\\"+'"'+ "& strComputer &"+ ' "'+"\root\default:StdRegProv"+'"'+")" + ENTER
      cVbs += "strKeyPath =" + '"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"' + ENTER
      cVbs += "oReg.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, arrSubKeys" + ENTER
      cVbs += "For Each SubKey In arrSubKeys" + ENTER
      cVbs += "strDisplayName = WshShell.RegRead (" +'"HKLM\"' + "& strKeyPath &" + '"\"' + "& SubKey &" + '"\DisplayName"' +")" + ENTER
      cVbs += "If  strDisplayName.toUpperCase() = strPrograma.toUpperCase() Then" + ENTER
      cVbs += "ltemPrograma = true" + ENTER
      cVbs += 'strText = ".T."' + ENTER
      cVbs += "Exit For" + ENTER
      cVbs += "End If" + ENTER
      cVbs += "Next" + ENTER

   ElseIf nOpc == 2 //Codigo para verificar se o programa se encontra na pasta passada por parametro.

      cVbs += 'ltemPrograma = false' + ENTER
      cVbs += 'set fso = CreateObject("Scripting.FileSystemObject")'+ ENTER

      If Empty(cFolderExe) //o caminho do exe é considerado o SYSTEM32
         cVbs += 'ShowAbsolutePath = fso.GetSpecialFolder(1) & "\"'  + ENTER
      Else
         cVbs += 'ShowAbsolutePath = "' + cFolderExe + '"' + ENTER
      EndIf

      cVbs += 'If CreateObject("Scripting.FileSystemObject").FileExists(ShowAbsolutePath &  strPrograma) Then' + ENTER
      cVbs += 'strText = ".T."' + ENTER
      cVbs += 'End If'+ ENTER

   EndIf

   cVbs += 'With CreateObject("Scripting.FileSystemObject")' + ENTER
   cVbs += 'With CreateObject("Scripting.FileSystemObject")' + ENTER
   cVbs += 'If Not .FolderExists(cFolder) Then' + ENTER
   cVbs += '.CreateFolder(cFolder)'+ ENTER
   cVbs += 'End If'+ ENTER
   cVbs += 'End With'+ ENTER
   cVbs += 'If Not .FileExists(cLog) Then'+ ENTER
   cVbs += '.CreateTextFile(cLog)'+ ENTER
   cVbs += 'End If'+ ENTER
   cVbs += 'If Not .FileExists(cLog) Then'+ ENTER
   cVbs += 'cScript.Quit'+ ENTER
   cVbs += 'End If'+ ENTER
   cVbs += 'Set Handler = .OpenTextFile(cLog, 2, True)'+ ENTER
   cVbs += 'Handler.WriteLine(strText)'+ ENTER
   cVbs += 'Handler.Close'+ ENTER
   cVbs += 'End With'+ ENTER

   //Caso exista um arquivo antigo, exclui
   If File(cFolderPath+cFileVbs)
      FErase(cFolderPath+cFileVbs)
   EndIf

   //Cria o arquivo vbScript
   nHandler := EasyCreateFile(cFolderPath+cFileVbs)
   FWrite(nHandler, cVbs)
   FClose(nHandler)

   //FErase(cFolderPath+cFileVbs)

End Sequence

//verificação de ocorrencia de erro:
If fError() <> 0
   lRet := .F.
   MsgStop(STR0237 + str(FError(),4)) //#STR0237->"Erro na criação do VBScript : "
EndIf

Return lRet



/* ============================================================ *
Funcao      : TxtRetFileRead
Parametros  : cArquivo - (C) - Diretorio + Nome do Arquivo + extenção
Retorno     : cString - (C) - Texto com o conteudo do arquivo
Objetivos   : Abrir e ler um arquivo e retornar seu conteudo.
Autor       : Felipe S. Martinez
Data/Hora   : 20/10/2011
Revisao     :
Data/Hora   :
Obs.        :
* ============================================================= */
Static Function TxtRetFileRead(cArquivo)
Local nHandle := 0
Local nTamArq := 0
Local cString := ""
Default cArquivo := ""

Begin Sequence

   //validação para o caminho do arquivo
   If Empty(cArquivo)
      MsgStop(STR0235,STR0150) //#STR0235->"Informar o diretório e o arquivo a ser aberto." ##STR0150->"Atenção"
      Break
   EndIf

   //Manipulando o txt com o retorno da função:
   nHandle := EasyOpenFile( cArquivo ,FO_READWRITE )

   If nHandle == -1
     MsgStop(STR0236 + str(FError(),4)) //#STR0236->"Erro na abertura do txt : "
     Break
   Endif

   //Le o tamanho do arquivo e retorna seu tamanho em bytes
   nTamArq := FSeek(nHandle, 0, FS_END)
   //posiciona no inicio do pedaço a ser lido
   FSeek(nHandle, 0)
   // Lê os bytes do arquivo
   FRead( nHandle, @cString, nTamArq )

   FClose(nHandle)

End Sequence

Return cString


/*
Função    : EasySomaIt()
Objetivos : Soma itens para envio ao SPEDFISCAL
Parametros: cId
Autor     : Diogo Felipe dos Santos
Revisão   : Thiago Rinaldi Pinto
Data      : 10/01/2012
*/

Function EasySomaIt(cId)

Local cIdRet:= ""
Local nId:= 0

nId:= Val(cId)

If nId < 9999
   nId += 1
   cIdRet:= Alltrim(Str(nId))
Endif

Return cIdRet

/*
Função    : AvgAllMark()
Objetivos : Marcar e Desmarcar todos os registros da WorkFil (Chamada da função AvgMBrowseFil)
Parametros: Nenhum
Autor     : Thiago Rinaldi Pinto
Data      : 06/03/2012
*/
*---------------------------------*
Static Function AvgAllMark()
*---------------------------------*
cNewMarca := ''

IF WorkFil->WKMARCA == cMarca
   cNewMarca:=SPACE(02)
ELSE
   cNewMarca:=cMarca
ENDIF

WorkFil->(DBGOTOP())

WHILE ! WorkFil->(EOF())
   WorkFil->WKMARCA :=cNewMarca
   WorkFil->(DBSKIP())
ENDDO

WorkFil->(DbGoTop())

oMark:oBrowse:Refresh()
oMark:oBrowse:Reset()
SysRefresh()

RETURN NIL


/*
  Função..: EasySX8Seq()
  Objetivo: Verifica qual a proxima chave disponivel
  Autor...: Felipe Sales Martinez - FSM
  Data....: 05/06/2012
  Obs.....:
*/
Function EasySX8Seq(cAlias, cField, nOrd, lSaveRec)
Local cNum := GetSx8Num(cAlias,cField)
Local aOrd := SaveOrd(cAlias)
Local cId    := ""
Local cQuery := ""
Local nRecOld:= 0
Default nOrd := 1
Default lSaveRec := .F. //RRC - 02/10/2013 - Guarda o recno atual da tabela

If lSaveRec
   nRecOld := (cAlias)->(Recno())
EndIf

If Select("WKSEQ") > 0
   WKSEQ->(DbCloseArea())
EndIf

cQuery += "SELECT MAX("+cField+") AS VALOR FROM " + RetSqlName(cAlias) + " " + cAlias
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WKSEQ", .F., .F.)

cId := WKSEQ->VALOR
cId := StrZero(Val(cId),AVSX3(cField,AV_TAMANHO))

If Select("WKSEQ") > 0
   WKSEQ->(DbCloseArea())
   DbSelectArea(cAlias)
EndIf

(cAlias)->(DBSetOrder(nOrd))

Do While Val(cId) >= Val(cNum) .OR. (cAlias)->(!EOF()) .And. (cAlias)->( DBSeek( xFilial(cAlias)+cNum ) )
   ConfirmSX8()
   cNum := GetSx8Num(cAlias,cField)
EndDo

//RRC - 02/10/2013 - Retorna ao recno da tabela
If lSaveRec
   (cAlias)->(DbGoTo(nRecOld))
EndIf

RestOrd(aOrd)

Return cNum

// GFP - 20/09/2012 - Compatibilização V811
*---------------------------------------------------------*
Function AvDescProdEE2(cCodProd,cCodCad, cTipMen, cIdioma)
*---------------------------------------------------------*
Local cDesc := ""

Default cCodCad := "3"
Default cTipMen := "*"
Default cIdioma := "INGLES-INGLES"

EE2->(DbSetOrder(1))//EE2_FILIAL+EE2_CODCAD+EE2_TIPMEN+EE2_IDIOMA+EE2_COD

If !Empty(cCodProd) .And. ;
   EE2->(DbSeek(xFilial("EE2") + AVKEY(cCodCad,"EE2_CODCAD") + AVKEY(cTipMen,"EE2_TIPMEN") + AVKEY(cIdioma,"EE2_IDIOMA") + AVKEY(cCodProd,"EE2_COD") ))

  cDesc := Alltrim(MSMM(EE2->EE2_TEXTO,AvSX3("EE2_VM_TEX",AV_TAMANHO)))

EndIf

Return cDesc



/*
Função..: EasyWkQuery()
Parametros: cQuery - String da query a ser executada
            cAliasWK - Nome da work que sera criada
            aIndices - Indices que serão criados na work "cAliasWK"
            aNotCmposSX3 - Campos da query que nao existem no dicionario
                           aNotCmposSX3[n][1] = Nome do Campo
                           aNotCmposSX3[n][2] = Tipo do Campo
                           aNotCmposSX3[n][3] = Tamanho do Campo
                           aNotCmposSX3[n][4] = Decimal do Campo

Objetivo: Transforma Work criada por Query para tabela física.
Autor...: Raphael Rodrigues Ventura - RRV
Data....: 06/09/2012
Obs.....:
*/
Function EasyWkQuery(cQuery,cAliasWk,aIndices,aNotCmposSX3, bCond)
Local nInc, nPos
Local aArray   := {}
Local aFileWk  := {}
Local cWork    := E_Create(,.F.)
Local aCamposOld := {}  // GFP - 29/08/2014
Local lGeraCpos := .F.  // GFP - 29/08/2014
//Local cAlias   := ""  // GFP - 30/04/2014
Default aNotCmposSX3 := {}

If Type("aCampos") == "U"    // GFP - 19/09/2014
   aCampos := {}
EndIf

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cWork, .F.)

SX3->(DbSetOrder(2))//X3_CAMPO

If Type("cAlias") == "U" .AND. Len(aCampos) # 0 .AND. Type("aCampos[1]") == "U"   // GFP - 29/08/2014
   aCamposOld := aClone(aCampos)
   aCampos := {}
   lGeraCpos := .T.
EndIf

FOR nInc := 1 TO (cWork)->(FCount())

   If "R_E_C_N_O_" $  (cWork)->(FIELDNAME(nInc)) //FSM - 31/10/2012
      loop
   EndIf

   //If !( "R_E_C_N_O_" $  (cWork)->(FIELDNAME(nInc)) .Or. "R_E_C_D_E"  $  (cWork)->(FIELDNAME(nInc)) )
   If SX3->(DbSeek((cWork)->(FIELDNAME(nInc))))
      //TCSetField(cWork, (cWork)->(FIELDNAME(nInc)), AvSx3((cWork)->(FIELDNAME(nInc)),AV_TIPO), AvSx3((cWork)->(FIELDNAME(nInc)),AV_TAMANHO), AvSx3((cWork)->(FIELDNAME(nInc)),AV_DECIMAL) )

      AADD(aArray,{(cWork)->(FIELDNAME(nInc)), AvSx3((cWork)->(FIELDNAME(nInc)),AV_TIPO), AvSx3((cWork)->(FIELDNAME(nInc)),AV_TAMANHO), AvSx3((cWork)->(FIELDNAME(nInc)),AV_DECIMAL)})
      If lGeraCpos   // GFP - 29/08/2014
         AADD(aCampos,(cWork)->(FIELDNAME(nInc)))
      EndIf

   ElseIf (nPos:= aScan(aNotCmposSX3,{|x| AllTrim(x[1]) == AllTrim((cWork)->(FIELDNAME(nInc)))   }))  >  0

      AADD(aArray,{aNotCmposSX3[nPos][1], aNotCmposSX3[nPos][2], aNotCmposSX3[nPos][3], aNotCmposSX3[nPos][4]})

   EndIf

   If Len(aArray) > 0 .And. aArray[Len(aArray)][2] <> "C"
      TCSetField(cWork, aArray[Len(aArray)][1], aArray[Len(aArray)][2], aArray[Len(aArray)][3], aArray[Len(aArray)][4])
   EndIf

NEXT nInc

If !TETempBanco() .And. aScan(aArray,{|x|  x[1] == "R_E_C_N_O_" }) == 0
  AADD(aArray,{"R_E_C_N_O_", "N", 7, 0})
EndIf

AADD(aFileWk,E_CriaTrab(,aArray,cAliasWk))

If ValType(aIndices) <> "A"
   aIndices := {aArray[1][1]}
EndIf

For nInc := 1 To Len(aIndices)
   AADD(aFileWk,E_Create(,.F.))
   IndRegua(cAliasWk,aFileWk[1+nInc]+TEOrdBagExt(),aIndices[nInc])
Next nInc

For nInc := 1 To Len(aIndices)
   DBSETINDEX(aFileWk[1+nInc]+TEOrdBagExt())
Next nInc

(cWork)->(dbGoTop())
While (cWork)->(!EOF())
   If bCond == NIL .OR. Eval(bCond,cWork)
      (cAliasWk)->(DBAPPEND())
      AVReplace(cWork,cAliasWk)
   EndIf

   (cWork)->(dbSkip())
EndDo

If Select(cWork) > 0
   (cWork)->(DbCloseArea())
EndIf

(cAliasWk)->(dbGoTop())
aCampos := If(Len(aCamposOld) # 0,aClone(aCamposOld),aCampos)  // GFP - 29/08/2014
Return Nil

Function EasyQry(cQuery,cAlias)
Default cAlias := "ESYQRY"

If Select(cAlias) > 0
   (cAlias)->(dbCloseArea())
EndIf

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F.)

EasyTCFields(cAlias)

Return cAlias

Function EasyQryCount(cQuery)
Local nTotalReg
Local cDBMS := Upper(TCGETDB())

If RAt("ORDER BY",Upper(cQuery)) > 0
   cQuery := SubStr(cQuery,1,RAt("ORDER BY",Upper(cQuery)) - 1)
EndIf
//THTS - 21/11/2017 - Ocorria erro no Informix ao dar um Alias para a tabela
If cDBMS == 'INFORMIX'
    EasyQry(ChangeQuery("SELECT COUNT(*) TOTAL FROM ("+cQuery+")"),"TOTALREG") //LRS - 18/10/2016 - Retirado o 'AS' da Query
Else
    EasyQry(ChangeQuery("SELECT COUNT(*) TOTAL FROM ("+cQuery+") TEMP"),"TOTALREG") //LRS - 18/10/2016 - Retirado o 'AS' da Query
EndIf

nTotalReg:= TOTALREG->TOTAL

TOTALREG->( dbCloseArea() )

Return nTotalReg


/*
  Função......: EasyMascCon()
  Objetivo....: Tratamento da mascara da conta contabil
  Autor.......: Bruno Akyo Kubagawa
  Parametros..: cConta - EC6_CDBEST / EC6_CTA_CR / EC6_CDBEST / EC6_CTA_DB / EC6_CCREST / EC6_CTA_DB
                cFornec - Codigo do Fornecedor
                cImport - Codigo do Importador
                cLoja - Loja do importador ou fornecedor
                cBanMov - EF3->EF3_BANC / EF1->EF1_BAN_MO / EF1->EF1_BAN_FI / EEQ->EEQ_BANC
                cAgMov - EF3->EF3_AGEN / EF1->EF1_AGENMO / EF1->EF1_AGENFI / EEQ->EEQ_AGEN
                cCtaMov - EF3->EF3_NCON / EF1->EF1_NCONMO / EF1->EF1_NCONFI / EEQ->EEQ_NCON
                cTpModu - FIEX01 / FIEX02 / FIEX03 / EXPORT
                cEvento -  120/123/121/124/122/125
                cIncoterm - Codigo do Incoterm
  Data........: 18/07/2012
  Obs.........:
*/
Function EasyMascCon(cConta,cFornec,cLojaFor,cImport,cLojaImp,cBanMov,cAgMov,cCtaMov,cTpModu,cEvento,oObj,cIncoterm)
Local cRet := cConta
Local nTam := Len(EC6->EC6_CTA_CR)
Local aOrd := {}
Default cLojaImp := "."
Default cLojaFor := "."
Default cEvento := ""
Default oObj    := AvObject():New()
Default cIncoterm:= ""

cConta := AllTrim(cConta)

Begin Sequence

     Do Case

        //Tipo Fornecedores
        Case cConta == Replicate("9",nTam) .And. !Empty(cFornec)

             aOrd := SaveOrd({"SY5", "SA2"})
             If !Empty(cEvento) .And. cEvento $ "120/123/121/124/122/125"
                SY5->(dbsetorder(1)) //Y5_FILIAL+Y5_COD
                If SY5->(DbSeek(xFilial("SY5") + AvKey(cFornec,"Y5_COD") ))
                   cSeek := xFilial("SA2")+SY5->Y5_FORNECE + If ( SY5->(FieldPos("Y5_LOJAF")) > 0 , SY5->Y5_LOJAF , cLojaFor )
                Endif

                If Empty(SY5->Y5_FORNECE+If ( SY5->(FieldPos("Y5_LOJAF")) > 0 , SY5->Y5_LOJAF , cLojaFor ))
                   oObj:Error("Fornecedor não definido para busca da conta contabíl.")
                EndIf
             Else
                cSeek := xFilial("SA2") + AvKey(cFornec,"A2_COD") + cLojaFor

                If Empty(cFornec+cLojaFor)
                   oObj:Error("Fornecedor não definido para busca da conta contabíl.")
                EndIf
             Endif

             SA2->(DBSETORDER(1)) //A2_FILIAL+A2_COD+A2_LOJA
             If SA2->(DbSeek(cSeek))
                cRet := AllTrim(SA2->A2_CONTAB)

                If Empty(cRet)
                   oObj:Error("Conta contábil não cadastrada no fornecedor. ("+cSeek+")")
                EndIF
             Else
                oObj:Error("Fornecedor não encontrado para busca da conta contábil. ("+cSeek+")")
             Endif

        //Tipo Cliente
        Case cConta == Replicate("8",nTam) .And. !Empty(cImport)

             aOrd := SaveOrd("SA1")
             cSeek := xFilial("SA1") + AvKey(cImport,"A1_COD") + cLojaImp
             If SA1->(DbSeek(cSeek) )
                cRet := AllTrim(SA1->A1_CONTAB)

                If Empty(cRet)
                   oObj:Error("Conta contábil não cadastrada no cliente. ("+cSeek+")")
                EndIF
             Else
                oObj:Error("Cliente não encontrado para busca da conta contábil. ("+cSeek+")")
             EndIf

        //Tipo Banco
        Case SubStr(cConta,1,nTam-1) == Replicate("7",nTam-1) .And. !Empty(cBanMov)
             aOrd := SaveOrd({"SA6","ECI"})

             If Right(cConta,1) = "0"
                SA6->(DbSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
                cSeek := xFilial("SA6") + cBanMov + cAgMov + cCtaMov
                If SA6->(DbSeek(cSeek))
                   cRet := Alltrim(SA6->A6_CONTABI)
                   If Empty(cRet)
                      oObj:Error("Conta contábil não cadastrada no banco. ("+cSeek+")")
                   EndIF
                Else
                   oObj:Error("Banco não encontrado para busca da conta contábil. ("+cSeek+")")
                EndIf
             Else
                ECI->(DBSETORDER(2)) //ECI_FILIAL+ECI_BANCOD+ECI_AGENCI+ECI_NUMCON+ECI_TPMODU+ECI_TPCONT
                cSeek := xFilial("ECI") + cBanMov + cAgMov + cCtaMov + AvKey(cTpModu,"ECI_TPMODU") + Right(cConta,1)
                If ECI->(DbSeek(cSeek))
                   cRet := AllTrim(ECI->ECI_CONTAB)
                   If Empty(cRet)
                      oObj:Error("Conta contábil não definida para este banco ("+cBanMov+"), agência ("+cAgMov+"), conta ("+cCtaMov+") e tipo de conta ("+Right(cConta,1)+") neste tipo de módulo/contrato ("+cTpModu+").")
                   EndIF
                Else
                   oObj:Error("Banco não cadastrado ou conta contábil não definida para este banco, agência, conta e tipo de conta neste tipo de módulo/contrato. ("+cSeek+")")
                EndIf
             EndIf
        
        //Tipo Incoterm //THTS - 31/05/2017 - TE-5822 - Contabilização com conta contabil por Incoterm 
        Case cConta == Replicate("6",nTam) .And. !Empty(cIncoterm) .And. SYJ->(FieldPos("YJ_CONTAB")) > 0
            aOrd := SaveOrd({"SYJ"})
           
            SYJ->(dbSetOrder(1)) //YJ_FILIAL + YJ_COD
            cSeek := xFilial("SYJ") + AvKey(cIncoterm,"YJ_COD")
           
            If SYJ->(DbSeek(cSeek))
                cRet := AllTrim(SYJ->YJ_CONTAB)
                If Empty(cRet)
                    oObj:Error("Conta contábil não cadastrada no Incoterm. ("+cSeek+")")
                EndIF
            Else
                oObj:Error("Incoterm não encontrado para busca da conta contábil. ("+cSeek+")")
            EndIf

     End Case

End Sequence

If Len(aOrd) > 0
   RestOrd(aOrd)
EndIf

Return cRet

/*
Função     : EICDelForn
Objetivo   : Validação de exclusão de Fornecedores chamada no fonte MATA020.PRX
Retorno    : lRet - .T./.F.
Autor      : Guilherme Fernandes Pilan
Data/Hora  : 19/12/2012 :: 10:03
Obs.       :
*/
*------------------------*
Function EICDelForn()
*------------------------*
Local lRet := .T., lTop
Local aOrd := SaveOrd({"SW1","SW2","SY4","SY5","SYG","SYS","SYT","SYU","SYW","SA5","EJX","EJY"})
Local cCod := "", cLoja := "", cQuery := ""

#IFDEF TOP
   lTop := .T.
#ELSE
   lTop := .F.
#ENDIF

   Begin Sequence

      cCod := SA2->A2_COD
      cLoja := SA2->A2_LOJA
      /******************************************************************************************/
      /*************************************** FASE - SI ****************************************/
      /******************************************************************************************/
      If lTop // GFP - 28/08/2013
         cQuery := "SELECT W1_FILIAL, W1_SI_NUM, W1_FABR, W1_FABLOJ, W1_FORN, W1_FORLOJ "
         cQuery += " FROM " + RetSqlName("SW1")
         cQuery += " WHERE D_E_L_E_T_ <> '*' AND W1_FILIAL = '" + xFilial("SW1") + "' AND "
         cQuery += " ((W1_FABR = '" + cCod + "' AND W1_FABLOJ = '" + cLoja + "') OR ("
         cQuery += " W1_FORN = '" + cCod + "' AND W1_FORLOJ = '" + cLoja + "'))"

         cQuery := ChangeQuery(cQuery)
         DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_SW1", .T., .T.)

         If !(WK_SW1->(Eof()) .AND. WK_SW1->(Bof()))
            EasyHelp(STR0249)  //"Este registro está vinculado na fase de SI."
            lRet := .F.
            Break
         EndIf
      Else
         SW1->(DbGoTop())
         Do While SW1->(!Eof()) .AND. SW1->W1_FILIAL == xFilial("SW1")
            If (SW1->W1_FABR == cCod .AND. SW1->W1_FABLOJ == cLoja) .OR. (SW1->W1_FORN == cCod .AND. SW1->W1_FORLOJ == cLoja)
               EasyHelp(STR0249)  //"Este registro está vinculado na fase de SI."
               lRet := .F.
               Break
            EndIf
            SW1->(DbSkip())
         EndDo
      EndIf

      /******************************************************************************************/
      /*************************************** FASE - PO ****************************************/
      /******************************************************************************************/
      SW2->(DbSetOrder(2))  //W2_FILIAL+W2_FORN+W2_FORLOJ+DTOS(W2_PO_DT)
      If SW2->(DbSeek(xFilial("SW2")+AvKey(cCod,"A2_COD")+AvKey(cLoja,"A2_LOJA")))
         EasyHelp(STR0250) //"Este registro está vinculado na fase de PO."
         lRet := .F.
      EndIf

      /******************************************************************************************/
      /********************************** AGENTES EMBARCADORES **********************************/
      /******************************************************************************************/
      If lTop // GFP - 28/08/2013
         cQuery := "SELECT Y4_FILIAL, Y4_COD, Y4_FORN, Y4_LOJA "
         cQuery += " FROM " + RetSqlName("SY4")
         cQuery += " WHERE D_E_L_E_T_ <> '*' AND Y4_FILIAL = '" + xFilial("SY4") + "' AND "
         cQuery += " Y4_FORN = '" + cCod + "' AND Y4_LOJA = '" + cLoja + "' "

         If Select("WK_SY4") > 0
         	WK_SY4->(DbCloseArea())
         EndIf

         cQuery := ChangeQuery(cQuery)
         DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_SY4", .T., .T.)

         If !(WK_SY4->(Eof()) .AND. WK_SY4->(Bof()))
            EasyHelp(STR0251)  //"Este registro está vinculado em a Agente Embarcador."
            lRet := .F.
            Break
         EndIf
      Else
         SY4->(DbGoTop())
         Do While SY4->(!Eof()) .AND. SY4->Y4_FILIAL == xFilial("SY4")
            If SY4->Y4_FORN == cCod .AND. SY4->Y4_LOJA == cLoja
               EasyHelp(STR0251)  //"Este registro está vinculado em a Agente Embarcador."
               lRet := .F.
               Break
            EndIf
            SY4->(DbSkip())
         EndDo
      EndIf

      /******************************************************************************************/
      /********************************* DESPACHANTES/EMPRESAS **********************************/
      /******************************************************************************************/
      If lTop // GFP - 28/08/2013
         cQuery := "SELECT Y5_FILIAL, Y5_COD, Y5_FORNECE, Y5_LOJAF "
         cQuery += " FROM " + RetSqlName("SY5")
         cQuery += " WHERE D_E_L_E_T_ <> '*' AND Y5_FILIAL = '" + xFilial("SY5") + "' AND "
         cQuery += " Y5_FORNECE = '" + cCod + "' AND Y5_LOJAF = '" + cLoja + "' "

         cQuery := ChangeQuery(cQuery)
         DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_SY5", .T., .T.)

         If !(WK_SY5->(Eof()) .AND. WK_SY5->(Bof()))
            EasyHelp(STR0252) //"Este registro está vinculado a um Despachante/Empresa."
            lRet := .F.
            Break
         EndIf
      Else
         SY5->(DbGoTop())
         Do While SY5->(!Eof()) .AND. SY5->Y5_FILIAL == xFilial("SY5")
            If SY5->Y5_FORNECE == cCod .AND. SY5->Y5_LOJAF == cLoja
               EasyHelp(STR0252) //"Este registro está vinculado a um Despachante/Empresa."
               lRet := .F.
               Break
            EndIf
            SY5->(DbSkip())
         EndDo
      EndIf

      /******************************************************************************************/
      /********************************* REGISTRO NO MINISTERIO *********************************/
      /******************************************************************************************/
      If lTop // GFP - 28/08/2013
         cQuery := "SELECT YG_FILIAL, YG_IMPORTA, YG_FABRICA, YG_FABLOJ "
         cQuery += " FROM " + RetSqlName("SYG")
         cQuery += " WHERE D_E_L_E_T_ <> '*' AND YG_FILIAL = '" + xFilial("SYG") + "' AND "
         cQuery += " YG_FABRICA = '" + cCod + "' AND YG_FABLOJ = '" + cLoja + "' "

         cQuery := ChangeQuery(cQuery)
         DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_SYG", .T., .T.)

         If !(WK_SYG->(Eof()) .AND. WK_SYG->(Bof()))
            EasyHelp(STR0253)  //"Este registro está vinculado a um Registro no Ministerio."
            lRet := .F.
            Break
         EndIf
      Else
         SYG->(DbGoTop())
         Do While SYG->(!Eof()) .AND. SYG->YG_FILIAL == xFilial("SYG")
            If SYG->YG_FABRICA == cCod .AND. SYG->YG_FABLOJ == cLoja
               EasyHelp(STR0253)  //"Este registro está vinculado a um Registro no Ministerio."
               lRet := .F.
               Break
            EndIf
            SYG->(DbSkip())
         EndDo
      EndIf

      /******************************************************************************************/
      /***************************** PERCENTUAIS DE CENTRO DE CUSTO *****************************/
      /******************************************************************************************/
      If lTop // GFP - 28/08/2013
         cQuery := "SELECT YS_FILIAL, YS_HAWB, YS_FORN, YS_FORLOJ "
         cQuery += " FROM " + RetSqlName("SYS")
         cQuery += " WHERE D_E_L_E_T_ <> '*' AND YS_FILIAL = '" + xFilial("SYS") + "' AND "
         cQuery += " YS_FORN = '" + cCod + "' AND YS_FORLOJ = '" + cLoja + "' "

         cQuery := ChangeQuery(cQuery)
         DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_SYS", .T., .T.)

         If !(WK_SYS->(Eof()) .AND. WK_SYS->(Bof()))
            EasyHelp(STR0254)  //"Este registro está vinculado a um Centro de Custo."
            lRet := .F.
            Break
         EndIf
      Else
         SYS->(DbGoTop())
         Do While SYS->(!Eof()) .AND. SYS->YS_FILIAL == xFilial("SYS")
            If SYS->YS_FORN == cCod .AND. SYS->YS_FORLOJ == cLoja
               EasyHelp(STR0254)   //"Este registro está vinculado a um Centro de Custo."
               lRet := .F.
               Break
            EndIf
            SYS->(DbSkip())
         EndDo
      EndIf

      /******************************************************************************************/
      /****************************** IMPORTADORES / CONSIGNATARIOS *****************************/
      /******************************************************************************************/
      If lTop // GFP - 28/08/2013
         cQuery := "SELECT YT_FILIAL, YT_COD_IMP, YT_FORN, YT_LOJA "
         cQuery += " FROM " + RetSqlName("SYT")
         cQuery += " WHERE D_E_L_E_T_ <> '*' AND YT_FILIAL = '" + xFilial("SYT") + "' AND "
         cQuery += " YT_FORN = '" + cCod + "' AND YT_LOJA = '" + cLoja + "' "

         cQuery := ChangeQuery(cQuery)
         DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_SYT", .T., .T.)

         If !(WK_SYT->(Eof()) .AND. WK_SYT->(Bof()))
            EasyHelp(STR0255)   //"Este registro está vinculado a um Importador."
            lRet := .F.
            Break
         EndIf
      Else
         SYT->(DbGoTop())
         Do While SYT->(!Eof()) .AND. SYT->YT_FILIAL == xFilial("SYT")
            If SYT->YT_FORN == cCod .AND. SYT->YT_LOJA == cLoja
               EasyHelp(STR0255)    //"Este registro está vinculado a um Importador."
               lRet := .F.
               Break
            EndIf
            SYT->(DbSkip())
         EndDo
      EndIf

      /******************************************************************************************/
      /***************************** TABELA INTEGRAÇÃO EASY-GIPLITE *****************************/
      /******************************************************************************************/
      If lTop // GFP - 28/08/2013
         cQuery := "SELECT YU_FILIAL, YU_DESP, YU_EASY, YU_LOJA "
         cQuery += " FROM " + RetSqlName("SYU")
         cQuery += " WHERE D_E_L_E_T_ <> '*' AND YU_FILIAL = '" + xFilial("SYU") + "' AND "
         cQuery += " YU_EASY = '" + cCod + "' AND YU_LOJA = '" + cLoja + "' "

         cQuery := ChangeQuery(cQuery)
         DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_SYU", .T., .T.)

         If !(WK_SYU->(Eof()) .AND. WK_SYU->(Bof()))
            EasyHelp(STR0256)  //"Este registro está vinculado a uma Tabela de Integração Easy-Giplite."
            lRet := .F.
            Break
         EndIf
      Else
         SYU->(DbGoTop())
         Do While SYU->(!Eof()) .AND. SYU->YU_FILIAL == xFilial("SYU")
            If SYU->YU_EASY == cCod .AND. SYU->YU_LOJA == cLoja
               EasyHelp(STR0256) //"Este registro está vinculado a uma Tabela de Integração Easy-Giplite."
               lRet := .F.
               Break
            EndIf
            SYU->(DbSkip())
         EndDo
      EndIf

      /******************************************************************************************/
      /************************************** CORRETORES ****************************************/
      /******************************************************************************************/
      If lTop // GFP - 28/08/2013
         cQuery := "SELECT YW_FILIAL, YW_COD,  YW_FORN, YW_LOJA "
         cQuery += " FROM " + RetSqlName("SYW")
         cQuery += " WHERE D_E_L_E_T_ <> '*' AND YW_FILIAL = '" + xFilial("SYW") + "' AND "
         cQuery += " YW_FORN = '" + cCod + "' AND YW_LOJA = '" + cLoja + "' "

         cQuery := ChangeQuery(cQuery)
         DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_SYW", .T., .T.)

         If !(WK_SYW->(Eof()) .AND. WK_SYW->(Bof()))
            EasyHelp(STR0257)  //"Este registro está vinculado a um Corretor."
            lRet := .F.
            Break
         EndIf
      Else
         SYW->(DbGoTop())
         Do While SYW->(!Eof()) .AND. SYW->YW_FILIAL == xFilial("SYW")
            If SYW->YW_FORN == cCod .AND. SYW->YW_LOJA == cLoja
               EasyHelp(STR0257)   //"Este registro está vinculado a um Corretor."
               lRet := .F.
               Break
            EndIf
            SYW->(DbSkip())
         EndDo
      EndIf

      /******************************************************************************************/
      /********************************** PRODUTO X FORNECEDOR **********************************/
      /******************************************************************************************/
      cQuery := "SELECT A5_FILIAL, A5_FORNECE, A5_LOJA, A5_FABR, A5_FALOJA "
      cQuery += " FROM " + RetSqlName("SA5")
      cQuery += " WHERE D_E_L_E_T_ <> '*' AND A5_FILIAL = '" + xFilial("SA5") + "' AND "
      cQuery += " ((A5_FORNECE = '" + cCod + "' AND A5_LOJA = '" + cLoja + "') OR "
      cQuery += " (A5_FABR = '" + cCod + "' AND A5_FALOJA = '" + cLoja + "'))"

      cQuery := ChangeQuery(cQuery)
      DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_SA5", .T., .T.)

      If !(WK_SA5->(Eof()) .AND. WK_SA5->(Bof()))
         EasyHelp(STR0266)  //"Este registro está vinculado no cadastro Produtos x Fornecedores."
         lRet := .F.
         Break
      EndIf

      /******************************************************************************************/
      /************************************* FASE - PEDIDO **************************************/
      /******************************************************************************************/
      cQuery := "SELECT EJW_FILIAL, EJW_PROCES, EJW_EXPORT, EJW_LOJEXP, EJW_IMPORT, EJW_LOJIMP "
      cQuery += " FROM " + RetSqlName("EJW")
      cQuery += " WHERE D_E_L_E_T_ <> '*' AND EJW_FILIAL = '" + xFilial("EJW") + "' AND "
      cQuery += " ((EJW_EXPORT = '" + cCod + "' AND EJW_LOJEXP = '" + cLoja + "') OR "
      cQuery += " (EJW_IMPORT = '" + cCod + "' AND EJW_LOJIMP = '" + cLoja + "'))"

      cQuery := ChangeQuery(cQuery)
      DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_EJX", .T., .T.) //LRS - 5/1/2016 - Correção do alias da Work

      If !(WK_EJX->(Eof()) .AND. WK_EJX->(Bof()))
         EasyHelp(STR0267)  //"Este registro está vinculado na fase de Pedido de Aquisição/Venda de Serviço."
         lRet := .F.
         Break
      EndIf

      /******************************************************************************************/
      /************************************ FASE - RAS/RVS **************************************/
      /******************************************************************************************/
      cQuery := "SELECT EJY_FILIAL, EJY_PROCES, EJY_EXPORT, EJY_LOJEXP, EJY_IMPORT, EJY_LOJIMP "
      cQuery += " FROM " + RetSqlName("EJY")
      cQuery += " WHERE D_E_L_E_T_ <> '*' AND EJY_FILIAL = '" + xFilial("EJY") + "' AND "
      cQuery += " ((EJY_EXPORT = '" + cCod + "' AND EJY_LOJEXP = '" + cLoja + "') OR "
      cQuery += " (EJY_IMPORT = '" + cCod + "' AND EJY_LOJIMP = '" + cLoja + "'))"

      cQuery := ChangeQuery(cQuery)
      DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_EJY", .T., .T.) //LRS - 5/1/2016 - Correção do alias da Work

      If !(WK_EJY->(Eof()) .AND. WK_EJY->(Bof()))
         EasyHelp(STR0268)  //"Este registro está vinculado na fase de RAS/RVS."
         lRet := .F.
         Break
      EndIf

   End Sequence

If Select("WK_SW1") <> 0
   WK_SW1->(DbCloseArea())
EndIf
If Select("WK_SY4") <> 0  // GFP - 19/08/2013
   WK_SY4->(DbCloseArea())
EndIf
If Select("WK_SY5") <> 0
   WK_SY5->(DbCloseArea())
EndIf
If Select("WK_SYG") <> 0
   WK_SYG->(DbCloseArea())
EndIf
If Select("WK_SYS") <> 0
   WK_SYS->(DbCloseArea())
EndIf
If Select("WK_SYT") <> 0
   WK_SYT->(DbCloseArea())
EndIf
If Select("WK_SYU") <> 0
   WK_SYU->(DbCloseArea())
EndIf
If Select("WK_SYW") <> 0
   WK_SYW->(DbCloseArea())
EndIf
If Select("WK_SA5") <> 0
   WK_SA5->(DbCloseArea())
EndIf
If Select("WK_EJX") <> 0
   WK_EJX->(DbCloseArea())
EndIf
If Select("WK_EJY") <> 0
   WK_EJY->(DbCloseArea())
EndIf

RestOrd(aOrd,.T.)
Return lRet

/*
Funcao      : EasyEAutItens()
Parametros  :
Retorno     :
Objetivos   :
Autor       : Alessandro Alves Ferreira
Data/Hora   : 29/12/2011
Revisao     :
Obs.        :
*/
Function EasyEAutItens(cMainAlias, cItemAlias, aCab, aDet, cMainRelKey, cItemUniqueKey, nItemIndex, nMainRecno)
Local aDetComp := aClone(aDet)
Local aChave, i, j, nPosCpo
Local aItem := {}
Default cItemUniqueKey := Posicione("SX2",1,cItemAlias,"X2_UNICO")
Default cMainRelKey    := Posicione("SX9",2,cItemAlias+cMainAlias,"if(X9_USEFIL=='S','"+cMainAlias+"_FILIAL+','')+X9_EXPDOM")
Default nItemIndex     := EasyBuscaIndice(cItemAlias,Posicione("SX9",2,cItemAlias+cMainAlias,"if(X9_USEFIL=='S','"+cItemAlias+"_FILIAL+','')+X9_EXPCDOM"))
Default nMainRecno     := 0

//Posiciona no registro de capa na base de dados
If nMainRecno > 0 .OR. EasySeekAuto(cMainAlias, aCab)

   cChaveCapa := (cMainAlias)->(&(cMainRelKey))

   If "_FILIAL" $ cMainRelKey
      cChaveCapa := Substr(cChaveCapa,Len(xFilial())+1,Len(cChaveCapa))
   EndIF

   aChave := EasyQuebraChave(cItemUniqueKey,.F.)

   //Posiciona no 1o registro de item na base de dados
   (cItemAlias)->(dbSetOrder(nItemIndex))
   (cItemAlias)->(dbSeek(xFilial(cItemAlias) + cChaveCapa))

   //Itera entre os itens da base de dados
   Do While (cItemAlias)->(!EoF()) .AND. Left((cItemAlias)->&(IndexKey()),Len(xFilial(cItemAlias)+cChaveCapa)) == xFilial(cItemAlias)+cChaveCapa

	  lItemOk := .F.
	  For i := 1 To Len(aDet)
	     lRegOk := .T.
	     For j := 1 to Len(aChave)
	        If (nPosCpo := aScan(aDet[i],{|X| AllTrim(Upper(X[1])) == aChave[j]})) > 0
			   If !( AllTrim(aDet[i][nPosCpo][2]) == AllTrim((cItemAlias)->(&(aChave[j]))) )
			      lRegOk := .F.
				  EXIT
			   EndIf
			Else
			   EasyHelp("Campo chave '"+aChave[j]+"' não encontrado no registro "+AllTrim(Str(i))+" do alias "+cItemAlias)
			   Return {}
			EndIf
	     Next j

		 If lRegOk
		    lItemOk := .T.
			EXIT
		 EndIf
	  Next i

	  If !lItemOk
	     aItem := {}
	     For i := 1 To Len(aChave)
		    aAdd(aItem,{aChave[i],(cItemAlias)->(&(aChave[i])),NIL})
		 Next i
		 aAdd(aItem,{"AUTDELETA","S",NIL})
		 aAdd(aDetComp,aClone(aItem))
	  EndIf

	  (cItemAlias)->(dbSkip())
   EndDo
EndIf

Return aClone(aDetComp)

/*
Funcao      : EasyQuebraChave()
Parametros  :
Retorno     :
Objetivos   :
Autor       : Alessandro Alves Ferreira
Data/Hora   : 29/12/2011
Revisao     :
Obs.        :
*/
Function EasyQuebraChave(cChave,lPoeFilial)
Local nPos := 0, nPosOld := 0
Local cCampo
Local aChave := {}
Default lPoeFilial := .F.  // AAF - 28/01/2014

cChave := AllTrim(cChave)

Do While nPos <= Len(cChave)
   If (nPos := At("+",cChave,nPos+1)) == 0
      nPos := Len(cChave)+1
   EndIf

   cCampo := SubStr(cChave,nPosOld+1,nPos-nPosOld-1)

   If (nPosCp := At("(",cCampo)) > 0
      nPosOld := nPosCp
      If (nPosCp2 := At(",",cCampo,nPosCp)) > 0
         cCampo := SubStr(cCampo,nPosCp+1,nPosCp2-nPosCp-1)
      ElseIf (nPosCp2 := At(")",cCampo,nPosCp)) > 0
         cCampo := SubStr(cCampo,nPosCp+1,nPosCp2-nPosCp-1)
      EndIf
   EndIf

   If !("_FILIAL" $ cCampo) .OR. lPoeFilial  // AAF - 28/01/2014
      aAdd(aChave,AllTrim(Upper(cCampo)))
   EndIf

   nPosOld := nPos
EndDo

Return aChave

/*
Funcao      : EasyBuscaIndice()
Parametros  :
Retorno     :
Objetivos   :
Autor       : Alessandro Alves Ferreira
Data/Hora   : 29/12/2011
Revisao     :
Obs.        :
*/
Function EasyBuscaIndice(cTabela,cExpPar)
Local cExp := AllTrim(Upper(cExpPar))

SIX->(dbSetOrder(1))
SIX->(dbSeek(cTabela))
Do While SIX->(!EoF() .AND. INDICE==cTabela)
   If AllTrim(Upper(Left(SIX->CHAVE,Len(cExp)))) == cExp
      EXIT
   EndIf

   SIX->(dbSkip())
EndDo

Return Val(SIX->ORDEM)

/*
Funcao      : EasyGetOpc()
Parametros  :
Retorno     :
Objetivos   :
Autor       : Bruno Akyo Kubagawa
Data/Hora   : 29/12/2011
Revisao     :
Obs.        :
*/
Function EasyGetOpc(cCapAlias,cDetAlias,cCapChave,nCapInd,cItemUniqueKey,nItemIndex)
Local aRet := {}

Local nOrdCap := 0
Local nRecCap := 0
Local nOrdDet := 0
Local nRecDet := 0
Default nCapInd     := 1
Default nItemIndex  := EasyBuscaIndice(cDetAlias,Posicione("SX9",2,cDetAlias+cCapAlias,"if(X9_USEFIL=='S','"+cDetAlias+"_FILIAL+','')+X9_EXPCDOM"))
Default cCapChave   := ""
Default cItemUniqueKey := Posicione("SX2",1,cDetAlias,"X2_UNICO")

Begin Sequence

   If Select(cCapAlias) == 0 .Or. Select(cDetAlias) == 0
      DbSelectArea(cCapAlias)
      DbSelectArea(cDetAlias)
   EndIf

   nOrdCap := (cCapAlias)->(IndexOrd())
   nRecCap := (cCapAlias)->(Recno())

   (cCapAlias)->(DbSetOrder(nCapInd))
   If (cCapAlias)->(DbSeek(xFilial(cCapAlias)+cCapChave))

      nOrdDet := (cDetAlias)->(IndexOrd())
      nRecDet := (cDetAlias)->(Recno())

      (cDetAlias)->(dbSetOrder(nItemIndex))
      (cDetAlias)->(dbSeek(xFilial(cDetAlias) + cCapChave))
      Do While (cDetAlias)->(!EoF()) .AND. Left((cDetAlias)->&(IndexKey()),Len(xFilial(cDetAlias)+cCapChave)) == xFilial(cDetAlias)+cCapChave
         aAdd(aRet,(cDetAlias)->&(cItemUniqueKey))
         (cDetAlias)->(dbSkip())
      EndDo

      (cDetAlias)->(DbSetOrder(nOrdDet))
      (cDetAlias)->(DbGoTo(nRecDet))

   EndIf

   (cCapAlias)->(DbSetOrder(nOrdCap))
   (cCapAlias)->(DbGoTo(nRecCap))

End Sequence

Return aClone(aRet)

Function EasyGetObrig(cAlias,lUser,lUsado)
Local aObrig  := {}
Local nOldOrd
Default lUser := .F.
Default lUsado:= .F.

nOldOrd := SX3->(IndexOrd())

SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
Do While SX3->( !EoF() .AND. X3_ARQUIVO == cAlias )

   If X3Obrigat(SX3->X3_CAMPO) .AND. (lUser .OR. SX3->X3_PROPRI <> "U") .AND. !"FILIAL" $ SX3->X3_CAMPO .And. (IIF(lUsado,X3Uso(SX3->X3_USADO),.T.))
      aAdd(aObrig,SX3->X3_CAMPO)
   EndIf

   SX3->(dbSkip())
EndDo

SX3->(dbSetOrder(nOldOrd))

Return aObrig


/*
Funcao      : EasySpedRes(cProcesso, cNfe, cSerie)
Parametros  : cMes
			    cAno

Retorno     : aRes(nPos1, nPos2)-> Array com os registros de exportação referente ao processo e nota fiscal informada.
              nPos1 -> DSE ou RE
              nPos2 -> Numero do registro (DSE ou RE)
              nPos3 -> Data do registro (DSE ou RE)
Objetivos   :
Autor       : Gustavo Cunha
Data/Hora   : 22/07/2013
Revisao     : Fabrício / Flávio
Obs.        : Alteração na regra de retorno, passando a ser por período, considerando a data de emissão da GIA.
*/
Function EasySpedRes(cMes, cAno, nOpcData)
	Local aOrd      := SaveOrd("EXL")
	Local aRes      := {}
	Local cAliasRES := "WK_RES"
	Private cDtIni, cDtFim
	Private cQuery
	Default nOpcData := 1

	If Select(cAliasRES) > 0
		(cAliasRES)->(DbCloseArea())
	EndIf

	cDtIni := cAno+cMes+"01"
	If Val(cMes) <> 12
	   	cDtFim := cAno+StrZero(Val(cMes)+1, 2)+"01"
	Else
		cDtFim := StrZero(Val(cAno)+1, 4)+"0101"
	EndIf

	//Tratamento para RE
	cQuery    := "SELECT DISTINCT EE9.EE9_RE"
	cQuery    += " FROM "+RetSqlName("EE9")+" EE9 "
	cQuery    += "WHERE EE9.EE9_FILIAL = '"+xFilial("EE9")+"' AND "
	cQuery    += "EE9.EE9_RE <> '' AND "

	If nOpcData == 1 //por data do RE
	   cQuery    += "(EE9.EE9_DTRE >= '" + cDtIni + "' AND EE9.EE9_DTRE < '" + cDtFim + "' )"
	ElseIf nOpcData == 2 //por data de averbação
	
	   cQuery    += "(EE9.EE9_DTAVRB >= '" + cDtIni + "' AND EE9.EE9_DTAVRB < '" + cDtFim + "' )"
	   
	   If EXL->(FieldPos("EXL_AVRBDS")) > 0
          cQuery += " OR EE9.EE9_PREEMB In (SELECT DISTINCT EXL_PREEMB "
          cQuery += "FROM " +RetSQLName("EXL") + " "          
          cQuery += "Where D_E_L_E_T_ <> '*' "        
          cQuery += "And EXL_FILIAL = '" + EXL->(xFilial()) + "' "
          cQuery += "And EXL_AVRBDS <> ' ' "          
          cQuery += "And EXL_AVRBDS >= '" + cDtIni + "' "
          cQuery += "And EXL_AVRBDS <= '" + cDtFim + "' ) " 
       EndIf       
    EndIf

    /* RMD - 26/01/14 - Não utilizar funções no select.
	cQuery    += "Month(EE9.EE9_DTRE) = '"+cMes     +"' AND "
	If TcGetDB() == "ORACLE"  // GFP - 24/03/2014
	   cQuery    += "TO_char(EE9.EE9_DTRE,'YYYY')='"+cAno     +"' AND "
	Else
	   cQuery    += "Year(EE9.EE9_DTRE) = '"+cAno     +"' AND "
	EndIf
	cQuery    += "Month(EE9.EE9_DTRE) = '"+cMes     +"' AND "
	*/

	cQuery    += "And EE9.D_E_L_E_T_ <> '*' "

	cQuery    := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRES,.F.,.F.)

	(cAliasRES)->( DbGoTop())

	While (cAliasRES)->( !Eof())
		AAdd(aRes, { "RE" , (cAliasRES)->EE9_RE})
		(cAliasRES)->(DbSkip())
	End

	(cAliasRES)->(DbCloseArea())

	//Tratamento para DSE  // GFP - 23/01/2014 - Ajuste do campo EXL_DTDSE.
	cQuery:= "SELECT DISTINCT EXL.EXL_DSE"
	cQuery+= " From " + RetSqlName("EXL") + " EXL"
	cQuery+= "WHERE EXL.EXL_FILIAL = '"+xFilial("EXL")+"' AND "
	cQuery+= "EXL_DSE <> '' AND "

    /* RMD - 26/01/14 - Não utilizar funções no select.
	cQuery+= "Month(EXL.EXL_DTDSE) = '"+cMes     +"' AND "
	If TcGetDB() == "ORACLE"  // GFP - 24/03/2014
	   cQuery+= "TO_char(EXL.EXL_DTDSE,'YYYY')='"+cAno     +"' AND "
	Else
	   cQuery+= "Year(EXL.EXL_DTDSE) = '"+cAno     +"' AND "
	EndIf
	*/

	cQuery    += "EXL.EXL_DTDSE >= '" + cDtIni + "' AND EXL.EXL_DTDSE < '" + cDtFim + "' AND "

	cQuery+= "		EXL.D_E_L_E_T_ <> '*' "

	cQuery    := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRES,.F.,.F.)

	(cAliasRES)->(DBGoTop())

	While (cAliasRES)->(!Eof())
		AAdd(aRes, { "DSE" , (cAliasRES)->EXL_DSE})
		(cAliasRES)->(DBSkip())
	EndDo

	(cAliasRES)->(DbCloseArea())
	RestOrd(aOrd)

Return aRes

/*
Funcao      : BcoIniBrw()
Parametros  :
Retorno     :
Objetivos   : Colocar no inicializador do browse do campo do banco do exterior
Autor       : Bruno Akyo Kubagawa
Data/Hora   : 29/12/2011
Revisao     :
Obs.        :
*/
Function BcoIniBrw()
Return Posicione("SA6",1,xFilial("SA6")+EEQ->(EEQ_BCOEXT+EEQ_AGCEXT+EEQ_CNTEXT),"A6_NOME")

Function BcoExtRelacao()
Return Posicione("SA6",1,xFilial("SA6")+M->(EEQ_BCOEXT+EEQ_AGCEXT+EEQ_CNTEXT),"A6_NOME")


/*
Funcao      : EventoFiltro()
Parametros  :
Retorno     :
Objetivos   : Filtrar os eventos contaveis a partir do campo da tabela EEQ
Autor       : Bruno Akyo Kubagawa
Data/Hora   : 29/12/2011
Revisao     : WFS - 06/01/2015
              adaptação para uso no cadastro de despesas do módulo SIGAEIC
Obs.        :
*/
Function EventoFiltro()
Local lFiltro := .F.

If IsInCallStack("ESSRS400") .Or. IsInCallStack("ESSPS401")  .Or. IsInCallStack("ESSRS403");
   .Or. IsInCallStack("ESSPS500")
   lFiltro := EC6->EC6_TPMODU="SISCSV"
Else
   //If nModulo == 17 //SIGAEIC //LRS - 09/02/2018 - Nopado para filtrar somente SISCSV ou EXPORT
      //lFiltro := EC6->EC6_TPMODU == "IMPORT"
   //Else
      lFiltro := (EC6->EC6_TPMODU="EXPORT" .And. EC6->EC6_IDENTC = " ")
      If cModulo == "EEC" .And. IsInCallStack("AC100AdiMan")             //NCF - 04/07/2019
         lFiltro := (EC6->EC6_TPMODU="EXPORT" .And. EC6->EC6_ID_CAM $ "605|606" .And. EC6->EC6_IDENTC = " ")
      EndIf
   //EndIf

EndIf

Return lFiltro

Function EC6ImpExp()

Local lFiltro := .F.

If nModulo == 17
    lFiltro := EC6->EC6_TPMODU == "IMPORT"
Elseif nModulo == 29
    lFiltro := EC6->EC6_TPMODU == "EXPORT"
Endif

Return lFiltro

/*
Função     : EasyVerModal
Parâmetros :
Retorno    : Retornar SE É  movimento no exterior OU contrato de cambio
Objetivos  : Retornar de acordo com a modalidade, ou seja, movimento no exterior ou contrato de cambio.
Autor      : Bruno Akyo Kubagawa - BAK
Data/Hora  : 23/08/12 - 14:55
Revisao    :
Obs.       :
*/
Function EasyVerModal(cAlias)
Local lRet := .F.
Default cAlias := "EEQ"

If AllTrim(Upper(cAlias)) == "M"
   lRet := EEQ->(FieldPos("EEQ_MODAL")) > 0 .And. &(cAlias+"->EEQ_MODAL") == "2"
Else
   lRet := (cAlias)->(FieldPos("EEQ_MODAL")) > 0 .And. (cAlias)->EEQ_MODAL == "2"
EndIf

Return lRet
/*
Função     : EasyMSMM
Parâmetros : Idem ao parâmetros passados a função MSMM
Retorno    : Texto do campo Memo
Objetivos  : Melhorar a performance do sistema com retorno direto da descrição utilizando
             o campo real (quando este existir) evitando utilizar a função MSMM.
Autor      : Alessandro Alves Ferreira
Data/Hora  : 23/07/2013 - 14:55
Revisao    : 20/09/2013 - 10:00 - Nilson César
Obs.       :
*/
Function EasyMSMM( cChave , nTam , nLin , cString , nOpc , nTabSize , lWrap , cAlias , cCpochave , cRealAlias, lSoInclui, cValFil)
Local nPos, uRet, lLock
Static aMemoReais := NIL
Default nOpc := 3
Default cValFil := xFilial(cAlias)//LGS-06/01/2015

If aMemoReais == NIL
   Private aMemos := {{"EE8","EE8_DESC","EE8_VM_DES"},;
                      {"EE8","EE8_QUADES","EE8_DSCQUA"}}

   aMemoReais := {}
   aEval(aMemos,{|X| if((X[1])->(FieldPos(X[3])) > 0,aAdd(aMemoReais,X),)})
EndIf


If (nPos := aScan(aMemoReais,{|X| X[2] == cCpochave})) > 0

   If nOpc == 3 //Leitura
      uRet := (cAlias)->(&(aMemoReais[nPos][3]))
   Else
      If nOpc == 2 //Excluir
        cString := ""
      EndIf
      If !(lLock := (cAlias)->(IsLocked()))
         RecLock(cAlias,.F.)
      EndIf

      (cAlias)->(&(aMemoReais[nPos][3])) := cString

      If !lLock
         (cAlias)->(MsUnLock())
      EndIf
   EndIf
Else

   cFilOld := cFilAnt

   If ValType("cValFil") = "C"
      cFilAnt := cValFil
   EndIf

   //RMD - 09/04/15 - Verifica se a tabela já estava travada antes da execução
   lLock := If (!Empty(cAlias), (cAlias)->(IsLocked()), .F.) //LGS-25/04/2015 - Feito correção para nao apresentar erro fatal qdo a cAlias estiver vazio e tentar verificar o Lock.

   uRet := MSMM( cChave , nTam , nLin , cString , nOpc , nTabSize , lWrap , cAlias , cCpochave , cRealAlias, lSoInclui)

   //RMD - 09/04/15 - Caso a MSMM tenha destravado a tabela, retorna a trava (caso já estivesse travada antes da chamada).
   If lLock .And. !(cAlias)->(IsLocked())
      (cAlias)->(RecLock(cAlias, .F.))
   EndIf

   cFilAnt := cFilOld

   //Somente visualização de campos memos
   If Empty(uRet) .And. (ValType(lSoInclui) == "U"  .Or. !lSoInclui)
      If Type("Inclui") == "U"
         Inclui:= .F.
      EndIf
      uRet:= E_MSMM(cChave, nTam)
   EndIf

EndIf

Return uRet

/*
Função     : AvGetKeyID
Parâmetros : cKeyIdioma - chave do Idioma conforme o cadastro de Idiomas
Retorno    : Chave formatada para posicionamento na tabela. Se não existir no arquivo SX5, retorna chave vazia.
Objetivos  : Retornar a chave já formatada para posicionamento (Seek)
Autor      : Nilson César
Data/Hora  : 24/09/2013 - 18:00
Revisao    :
Obs.       :
*/
*-------------------------------*
 Function AvGetKeyID(cKeyIdioma)
*-------------------------------*
Local aOrdSX5 := SaveOrd("SX5")
Local cRet := ""
Default cKeyIdioma := ""

SX5->(DbSetOrder(1))
If SX5->(DbSeek(xFilial('SX5')+'ID'+AvKey(cKeyIdioma,'X5_CHAVE')))
   cRet := SX5->X5_CHAVE+'-'+SX5->X5_DESCRI
EndIf

RestOrd(aOrdSX5)
Return cRet


/*
Função     : AVGetSvLog
Parâmetros : cTit - Título da Janela de Log
             cLog - Texto de Log a ser exibido
Retorno    :
Objetivos  : Exibir janela de Log genérica que permita salvar texto do log.
Autor      : Nilson César
Data/Hora  : 26/09/2013 - 18:00
Revisao    :
Obs.       :
*/
*--------------------------------------*
Function AVGetSvLog(cTit,cLog,aTamFont)
*--------------------------------------*
Local cTexto       := ''
Local cFile        := ''
Local cMask        := 'Arquivos Texto (*.TXT) |*.txt|'
Local aButtons := {}

Default cTit       := ''
Default cLog       := ''
Default aTamFont   := {5,12}

      cTexto := cTit+CHR(13)+CHR(10)+cTexto
      __cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)

      Define FONT oFont NAME "Mono AS" Size aTamFont[1],aTamFont[2]  //5,12
      nAltMemo := 120
      
      Define MsDialog oDlgLog Title cTit From 3,0 to 340,/*417*/640 Pixel

         oPnl:= TPanel():New(0, 0, "", oDlgLog,, .F., .F.,,, 1, 1)
         oPnl:Align:= CONTROL_ALIGN_ALLCLIENT         

         @ 5,5 Get oMemo Var cLog MEMO Size /*200*/306, nAltMemo Of oPnl Pixel
         oMemo:bRClicked := {||AllwaysTrue()}
         oMemo:oFont:=oFont

         AAdd (aButtons, {'', {|| (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) }, 'Salvar' })

      Activate MsDialog oDlgLog ON INIT EnchoiceBar(oDlgLog, { || oDlgLog:End()  }, { || oDlgLog:End() }, , aButtons,,,,,.F.) CENTERED

Return

Function EasyIsClient64()
Return lIsDir(GetWinDir()+"\SYSWOW64\")


Function EasyStrSplit(cString,cSeparador)
Local aRet := {}
//Local cAux := ""
Local nPos

If ValType(cString) == "C" .AND. !Empty(cString) .AND. ValType(cSeparador) == "C"
   Do While (nPos := At(cSeparador , cString)) <> 0
      aAdd(aRet,SubStr(cString,1,nPos-1))
      cString := SubStr(cString,nPos+1,Len(cString))
   EndDo
   aAdd(aRet,cString)
EndIf

Return aRet

Function EasyTCFields(cArea)
Local i
Local aOrdX3 := SX3->({IndexOrd(),RecNo()})

SX3->(dbSetOrder(2))

If Select(cArea) > 0
   For i := 1 To (cArea)->(FCount())
      If SX3->(dbSeek((cArea)->(FieldName(i))) .AND. X3_TIPO $ 'D/L/N')
	     SX3->(TCSetField(cArea, X3_CAMPO, X3_TIPO, X3_TAMANHO, X3_DECIMAL))
	  EndIf
   Next i
EndIf

SX3->(dbSetOrder(aOrdX3[1]),dbGoTo(aOrdX3[2]))

Return Nil

/*
Função     : AvCalcPict
Parâmetros : nTam, nDec
Retorno    : Caracteres
Objetivos  : Monta picture para campos do tipo numérico
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 13/05/2014 :: 09:49
*/
*------------------------------*
Function AvCalcPict(nTam,nDec)
*------------------------------*
Local nInt := 0
Local i
Local cPict := "@E "
Local cPictInt := ""
Local cPictDec := ""
Local nDiv := 0
Default nDec := 0

If nDec == 0
   nInt := nTam
Else
   nInt := nTam - (nDec+1)
   For i := 1 To (nDec + 1)
      cPictDec += "9"
   Next
   cPictDec := Stuff(cPictDec,1,1,".")
Endif

nDiv := Int((nInt)/3)
If (nInt % 3) == 0
   nDiv := nDiv -1
Endif

For i := 1 To nInt
   cPictInt += "9"
Next

For i := 1 To nDiv
   cPictInt := Stuff(cPictInt,nInt -((i * 3)-1),0,",")
next

cPict += cPictInt + cPictDec

Return cPict

/*
Função     : RetVetNVE
Parâmetros : -
Retorno    : Array de NVEs
Objetivos  : Monta array de NVE do item em questão
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 16/05/2014 :: 09:49
*/
*------------------------------*
Static Function RetVetNVE()
*------------------------------*
Local aNVE := {}
Local aOrd := SaveOrd("EIM")
Local i := 1

Begin Sequence
   EIM->(DbSetOrder(2))
   If !EIM->(DbSeek(xFilial("EIM")+SW8->W8_HAWB+SW8->W8_NVE))
      Break
   EndIf
   Do While EIM->(!Eof()) .AND. EIM->EIM_FILIAL == xFilial("EIM") .AND. EIM->EIM_HAWB == SW8->W8_HAWB .AND. EIM->EIM_CODIGO == SW8->W8_NVE
      If i > 8  // O layout suporta até 8 códigos
         Break
      EndIf
      aadd(aNVE,{EIM->EIM_ATRIB, EIM->EIM_ESPECI})
      i++
      EIM->(DbSkip())
   EndDo
End Sequence

RestOrd(aOrd,.T.)
Return aNVE

Function TEEnchBar(xP1,xP2,xP3,xP4,xP5,xP6,xP7,xP8,xP9,xP10,xP11,xP12,xP13,xP14,xP15,xP16,xP17,xP18,xP19,xP20)
Local oJan, aTmp, xRet, i
Local cPars := "xP1,xP2,xP3,xP4,xP5,xP6,xP7,xP8,xP9,xP10,xP11,xP12,xP13,xP14,xP15,xP16,xP17,xP18,xP19,xP20"
Private oCtrl

oJan:= GetWndDefault()
aTmp:= {}

For i := 1 To Len(oJan:aControls)
   oCtrl := oJan:aControls[i]
   If Type("oCtrl:oWnd") == "O" .AND. Type("oCtrl:oParent") == "O" .AND. oCtrl:oWnd == oCtrl:oParent  // AAF - 17/11/2014
      If Type("oCtrl:align") == "N"
         aAdd(aTmp,{oCtrl,oCtrl:align})
	  ElseIf Type("oCtrl:oBox") == "O" .AND. Type("oCtrl:oBox:align") == "N"
	     aAdd(aTmp,{oCtrl:oBox,oCtrl:oBox:align})
	  EndIf
   EndIf
Next i

aEval(aTmp,{|X| X[1]:Align := 0})

xRet := Eval(&("{|"+cPars+"| EnchoiceBar("+cPars+") }"),xP1,xP2,xP3,xP4,xP5,xP6,xP7,xP8,xP9,xP10,xP11,xP12,xP13,xP14,xP15,xP16,xP17,xP18,xP19,xP20)

aEval(aTmp,{|X| X[1]:Align := X[2]})

Return xRet

//Busca binária em um array ordenado.
Function EasyAScan(aArray,xChave,bCompara)
Local nMax, nMin
Local nComp := 1

If bCompara == NIL
   If ValType(xChave) $ "C/N/D"
      bCompara := {|X,Y| if(X>Y,1,if(X<Y,-1,0)) }
   EndIf
EndIf

nMin := 1
nMax := Len(aArray)

Do While nMax >= nMin
   nPos := int((nMin+nMax)/2)
   If (nComp := Eval(bCompara,xChave,aArray[nPos])) == 0
      EXIT
   ElseIf nComp > 0
      nMin := nPos+1
   Else
      nMax := nPos-1
   EndIf
EndDo

Return if(nComp==0,nPos,0)

/*
Função     : AvViaTrans
Parâmetros : Via de Transporte do processo
Retorno    : Via de Transporte formatada
Objetivos  : Tratar Via de Transporte
Autor      : Marcos Roberto Ramos Cavini Filho - MCF
Data/Hora  : 30/01/2014 - 15:30
*/
*------------------------------*
Static Function AvViaTrans(cCodigo)
*------------------------------*
Local aViaTrans    := {}, i
Local cCodViaTrans := ""
Local cValLeft     := ""

aAdd(aViaTrans,{"A","10"})
aAdd(aViaTrans,{"B","11"})
aAdd(aViaTrans,{"C","12"})
aAdd(aViaTrans,{"D","13"})

If SubStr(Left(cCodigo,2),2,1) == "-"
   cValLeft := Left(cCodigo,1)
Else
   cValLeft := Left(cCodigo,2)
EndIf

For i:= 1 To Len(aViaTrans)
	If cValLeft == aViaTrans[i][1]
		cCodViaTrans := aViaTrans[i][2]
	Endif
Next

If Empty(cCodViaTrans)
	cCodViaTrans := cValLeft
Endif

Return cCodViaTrans

/*
Programa   :	EasyZIP()
Objetivo   :	Efetua a compactação de uma pasta no formato ZIP.
Parametros :	cNomeArq - Nome do arquivo a ser gerado (Exemplo: "Resultados.zip")
				cDirSrv - Diretório a ser compactado (Exemplo: "\comex\siscomexweb\gerados\0029\")
				cDirClient - Diretorio a ser armazenado o arquivo compactado (Exemplo: "C:\Ambientes\M11.8\Install.exe")
				oError - Objeto de armazenamento de erros.
				lDelArq - Caso .T., exclui arquivo .zip gerado no diretorio informado no na variavel cDirClient. Caso .F., mantém arquivo
Retorno    :	lRet
Autor      :	Guilherme Fernandes Pilan - GFP
Data/Hora  :	05/02/2015 :: 10:57
RevisãO    :	Alessandro Alves Ferreira - AAF
Data/Hora  :	27/03/2015
*/
*-----------------------------------------------------------------------*
Function EasyZIP(cNomeArq,cDirSrv,cDirClient,oError,lDelArq)
*-----------------------------------------------------------------------*
Local cTexto     := ""
Local cArqVbs    := "LoteZip.vbs"
Local cDirVbs    := GetTempPath(.T.) + cArqVbs
Local lRet       := .T., lExiste := .F.
Local nHandler   := 0
Local nFound, j, aFiles := {}, aFilZip := {}, i
Default lDelArq := .T.

Begin Sequence
   If !lIsDir(cDirSrv)
      oError:Error(STR0258 + cDirSrv,.F.)  //"Erro ao criar o diretório XXXXXX"
      lRet := .F.
      Break
   EndIf

   cNomeArq   := If(At(".zip",cNomeArq) == 0, AllTrim(cNomeArq)+".zip", AllTrim(cNomeArq))
   cDirClient := If(Right(cDirClient,1) <> "\",AllTrim(cDirClient)+"\",AllTrim(cDirClient))
   cDirSrv    := If(Right(cDirSrv,1) <> "\",AllTrim(cDirSrv)+"\",AllTrim(cDirSrv))

   aFiles := Directory(cDirSrv+"*.*")

   If ExistDir(cDirClient+"zip\")
      aFilZip := Directory(cDirClient+"zip\*.*")
      For i := 1 To Len(aFilZip)
         FErase(cDirClient+"zip\"+aFilZip[i][1])
      Next i
   EndIf

   If lIsDir(cDirClient) .AND. MakeDir(cDirClient+"zip") <> 0 .AND. !ExistDir(cDirClient+"zip")
      MsgInfo(STR0265, STR0005)  //"O sistema não pode criar os diretórios necessários para a integração."  ## "Atenção"
   EndIf

   For i := 1 To Len(aFiles)
	  If !AvCpyFile(cDirSrv+aFiles[i][1],cDirClient+"zip\"+aFiles[i][1],,.F.)
		  oError:Error(STR0260 + cDirClient+"zip\"+aFiles[i][1],.F.)  //"Erro ao criar o arquivo ### para compactar os arquivos solicitados."
		  lRet := .F.
		  Break
	  EndIf
   Next i

   If FindFunction("H_EASYZIP")
      cTexto := H_EASYZIP()
      cTexto := StrTran(cTexto,"#DIRORIGEM#" ,'"'+cDirClient+"zip\"+'"')
      cTexto := StrTran(cTexto,"#DIRDESTINO#",'"'+cDirClient+'"')
   Else
      oError:Error(STR0259,.F.)  //"Este ambiente não está preparado para compactar os arquivos solicitados. Favor entrar em contato com o suporte Trade-Easy."
      lRet := .F.
      Break
   EndIf

   //Exclui o arquivo VbScript caso já exista
   If File(cDirVbs)
      FErase(cDirVbs)
   EndIf

   //Cria um novo arquivo VbScript para compactar os arquivos XML
   If (nHandler := EasyCreateFile(cDirVbs)) == -1
      oError:Error(STR0260 + cArqVbs + STR0261,.F.)  //"Erro ao criar o arquivo ### para compactar os arquivos solicitados."
      lRet := .F.
      Break
   Else
      FWrite(nHandler, cTexto)
      FClose(nHandler)
      If (nFound := WaitRun('wscript.exe "'+cDirVbs+'"',SW_MINIMIZE)) == 0
         lExiste := .F.
         For j := 1 To 30
            If File(cDirClient+"Archive.zip")
               lExiste := .T.
               Exit
            EndIf
         Next j
         If lExiste .AND. FRename(cDirClient+"Archive.zip",cDirClient+cNomeArq) <> 0  // Renomeia o arquivo gerado para o nome informado na variavel cNomeArq
            oError:Error(STR0262,.F.)  //"Não foi possível renomear o arquivo .zip gerado."
         EndIf
         If !CpyT2S(cDirClient + cNomeArq, cDirSrv , .F.)
            oError:Error(STR0263 + cDirSrv,.F.)  //"Não foi possível copiar a pasta compactada dos arquivos solicitados para o diretório do seu ambiente: "
            lRet := .F.
            Break
         EndIf
      Else
         oError:Error(STR0264,.F.)  //"Erro de execução de aplicativo para gerar a pasta compactada dos arquivos solicitados."
         lRet := .F.
         Break
      EndIf
   EndIf
End Sequence

If lDelArq .AND. File(cDirClient+cNomeArq)
   FErase(cDirClient+cNomeArq)

   For i := 1 To Len(aFiles)
	  FErase(cDirClient+"zip\"+aFiles[i][1])
   Next i

   DirRemove(cDirClient+"zip")
EndIf

Return lRet

/*
Programa   :	EasyUnZip()
Objetivo   :	Efetua a descompactação de uma pasta no formato ZIP.
Parametros :	cFile - Nome do arquivo a ser gerado (Exemplo: "Resultados.zip")
				cDir - Diretório onde encontra-se o arquivo ZIP.
				cDest - Diretório a ser descompactado
				lInterface - Informa se processo é executado em primeiro plano.
Retorno    :	lRet
Autor      :	Guilherme Fernandes Pilan - GFP
Data/Hora  :	24/02/2015 :: 12:02
*/
*-----------------------------------------------------------------------*
Function EasyUnZip(cFile, cDir, cDest, lInterface, nWait, cTempPath)
*-----------------------------------------------------------------------*
Local oProcess
Local lRet := .F.
Local bAction := {|| lRet := AuxUnZipFile(cFile, cDir, cDest, lInterface, nWait, cTempPath) }
Default lInterface := Type("oMainWnd") == "O"

   If lInterface
      MsAguarde(bAction, STR0013, "Executando descompactador de arquivos.")//"Aguarde..."###
   Else
      Eval(bAction)
   EndIf

Return lRet

Static Function AuxUnZipFile(cFile, cDir, cDest, lInterface, nWait, cTempPath)
Local lRet := .T., lAVG_UNZIP :=.F.
Local cVBS := 'Set oUnzipFSO = CreateObject("Scripting.FileSystemObject")' + ENTER;
            + 'If Not oUnzipFSO.FolderExists(WScript.Arguments(1)) Then' + ENTER;
            + '   oUnzipFSO.CreateFolder(WScript.Arguments(1))' + ENTER;
            + 'End If' + ENTER;
            + 'With CreateObject("Shell.Application")' + ENTER;
            + '.NameSpace(WScript.Arguments(1)).Copyhere .NameSpace(WScript.Arguments(0)).Items' + ENTER;
            + 'End With' + ENTER
Local hFile
Local nResult, nSeconds, i
Local cNewFolder := StrTran(Upper(cFile), ".ZIP", "")
Default nWait := 3
Default cTempPath := GetTempPath()

   If !File(cDir + cFile)
      If lInterface
         MsgInfo(StrTran(STR0044, "###", cFile), STR0017)//"Arquivo '###' não foi encontrado."&&&"Atenção"
      EndIf
      lRet := .F.
   Else
      If Empty(cZipApp := EasyGParam("MV_AVG0150",, "AVG_UNZIP.VBS")) .Or. AllTrim(cZipApp) == "AVG_UNZIP.VBS"
         cZipApp := CriaTrab(, .F.) + ".VBS"
         lAVG_UNZIP := .T.
      EndIf

      If lAVG_UNZIP
         hFile := EasyCreateFile(cZipApp)
         FWrite(hFile, cVBS, Len(cVBS))
         FClose(hFile)
      EndIf

      If lAVG_UNZIP
         If AvCpyFile(cZipApp,cTempPath+cZipApp,,.F.) .AND. AvCpyFile(cDir + cFile,cTempPath+cFile,,.F.)
            nResult := WaitRun('cscript.exe  "' + cTempPath + cZipApp + '" "' + cTempPath + cFile + '" "' + cTempPath + cNewFolder + '" ')
            nSeconds := Seconds()
         EndIf
      Else
         nResult := WaitRun(cZipApp + " " + cFile + " " + cDest)
         nSeconds := Seconds()
      EndIf
      lRet := nResult == 0 .And. lIsDir(cTempPath + cNewFolder)
   EndIf

   If !lRet .And. lInterface
      MsgInfo(StrTran(STR0326, "###", cFile), STR0245 )//"Erro ao descompactar o arquivo '###'."&&&"Atenção"
   EndIf

   If lAVG_UNZIP
      FErase(cZipApp)
      FErase(cTempPath + cZipApp)
      FErase(cTempPath + cFile)
      MakeDir(cDest)

      aArquivos := {}
      //aDir(cTempPath + cNewFolder + "\*.*",aArquivos)
      aDir := Directory(cTempPath + cNewFolder + "\*.*")
      aEval(aDir, {|x| aAdd(aArquivos, x[1]) })
      If Len(aArquivos) # 0
         For i := 1 To Len(aArquivos)
            Do While .T.
               If AvCpyFile(cTempPath+cNewFolder + "\"+aArquivos[i],cDest+aArquivos[i],,.T.)
                  Exit
               EndIf
            EndDo
         Next i
      EndIf
      aDir := Directory(cTempPath + cNewFolder + "\*.*")
      aEval(aDir, {|x| FErase(cTempPath + cNewFolder + "\" + x[1]) })
      DirRemove(cTempPath + cNewFolder)
   EndIf

Return lRet

/*
Programa   :	EasyGetINI()
Objetivo   :	Efetua a leitura de um determinado arquivo INI e retorna uma String
Parametros :	cNomeArq - Nome do arquivo a ser lido (Exemplo: "C:\Arquivo.ini")
				cTag - Tag especifico a ser lido, caso não seja informado, será lido todo o arquivo (Exemplo: "[AMBIENTE]")
				lArray - Informa se retorno deve ser array, por padrão, o retorno é String.
Retorno    :	lRet
Autor      :	Guilherme Fernandes Pilan - GFP
Data/Hora  :	18/02/2015 :: 08:53
*/
*-----------------------------------------------------------------------*
Function EasyGetINI(cNomeArq, cTag, cFinal, lArray,lUpper)
*-----------------------------------------------------------------------*
Local xRet
Local cLinha := ""
Local lTag := !Empty(cTag)
Default lArray := .F.
Default cFinal := "["
Default lUpper := .F.

Begin Sequence

   If Empty(cNomeArq) .OR. !File(cNomeArq)
      Break
   EndIf

   FT_FUSE(cNomeArq)                //ABRIR
   FT_FGOTOP()                      //PONTO NO TOPO

   xRet := If(lArray,{},"")

   While !FT_FEOF()
      cLinha  := FT_FREADLN()
      If lTag
         If If(lUpper, At(Upper(cTag), Upper(cLinha)) # 0, At(cTag, cLinha) # 0)
            If lArray
               aAdd(xRet,cLinha)
            Else
               xRet += cLinha + ENTER
            EndIf
            FT_FSKIP()
            cLinha  := FT_FREADLN()
            nRecno := FT_FRECNO()
            While !FT_FEOF() .AND. !(At(cFinal, cLinha) == 1)
               If lArray
                  aAdd(xRet,cLinha)
               Else
                  xRet += cLinha + ENTER
               EndIf
               FT_FSKIP()
               cLinha  := FT_FREADLN()
            EndDo
            FT_FGoto(nRecno)
         EndIf
      Else
         If lArray
            aAdd(xRet,cLinha)
         Else
            xRet += cLinha + ENTER
         EndIf
      EndIf
      FT_FSKIP()
   EndDo

   FT_FUSE()        //FECHAR

End Sequence

Return xRet

Function AvlSX3Buffer(lValue)
lSX3Buffer := lValue
Return .T.

/*
Função     : EICDelCli
Objetivo   : Validação de exclusão de Clientes chamada no fonte MATA030.PRX
Retorno    : lRet - .T./.F.
Autor      : Guilherme Fernandes Pilan
Data/Hora  : 12/11/2015 :: 15:08
Obs.       :
*/
*------------------------*
Function EICDelCli()
*------------------------*
Local lRet := .T., lTop
Local aOrd := SaveOrd({"EJX","EJY"})
Local cCod := "", cLoja := "", cQuery := ""

   Begin Sequence

      cCod := SA1->A1_COD
      cLoja := SA1->A1_LOJA
      /******************************************************************************************/
      /*************************************** FASE - PO ****************************************/
      /******************************************************************************************/
      cQuery := "SELECT W2_FILIAL, W2_CLIENTE, W2_CLILOJ "
      cQuery += " FROM " + RetSqlName("SW2")
      cQuery += " WHERE D_E_L_E_T_ <> '*' AND W2_FILIAL = '" + xFilial("SW1") + "' AND "
      cQuery += " (W2_CLIENTE = '" + cCod + "' AND W2_CLILOJ = '" + cLoja + "') "

      cQuery := ChangeQuery(cQuery)
      DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_SW2", .T., .T.)

      If !(WK_SW2->(Eof()) .AND. WK_SW2->(Bof()))
         EasyHelp(STR0250) //"Este registro está vinculado na fase de PO."
         lRet := .F.
         Break
      EndIf

End Sequence

If Select("WK_SW2") <> 0
   WK_SW2->(DbCloseArea())
EndIf

RestOrd(aOrd,.T.)
Return lRet

/*
Função     : EICDelProd
Objetivo   : Validação de exclusão de Clientes chamada no fonte MATN030.PRX
Retorno    : lRet - .T./.F.
Autor      : Guilherme Fernandes Pilan
Data/Hora  : 12/11/2015 :: 15:08
Obs.       :
*/
*------------------------*
Function EICDelProd()
*------------------------*
Local lRet := .T., lTop
Local aOrd := SaveOrd({"SW1","SW3","SA5","EJX","EJY"})
Local cCod := "", cQuery := ""

   Begin Sequence

      cCod := SB1->B1_COD
      /******************************************************************************************/
      /*************************************** FASE - SI ****************************************/
      /******************************************************************************************/
         cQuery := "SELECT W1_FILIAL, W1_COD_I "
         cQuery += " FROM " + RetSqlName("SW1")
         cQuery += " WHERE D_E_L_E_T_ <> '*' AND W1_FILIAL = '" + xFilial("SW1") + "' AND "
         cQuery += " W1_COD_I = '" + cCod + "'"

         cQuery := ChangeQuery(cQuery)
         DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_SW1", .T., .T.)

         If !(WK_SW1->(Eof()) .AND. WK_SW1->(Bof()))
            EasyHelp(STR0249)  //"Este registro está vinculado na fase de SI."
            lRet := .F.
            Break
         EndIf

      /******************************************************************************************/
      /*************************************** FASE - PO ****************************************/
      /******************************************************************************************/
         cQuery := "SELECT W3_FILIAL, W3_COD_I "
         cQuery += " FROM " + RetSqlName("SW3")
         cQuery += " WHERE D_E_L_E_T_ <> '*' AND W3_FILIAL = '" + xFilial("SW3") + "' AND "
         cQuery += " W3_COD_I = '" + cCod + "'"

         cQuery := ChangeQuery(cQuery)
         DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_SW3", .T., .T.)

         If !(WK_SW3->(Eof()) .AND. WK_SW3->(Bof()))
            EasyHelp(STR0250) //"Este registro está vinculado na fase de PO."
            lRet := .F.
            Break
         EndIf


      /******************************************************************************************/
      /********************************** PRODUTO X FORNECEDOR **********************************/
      /******************************************************************************************/
      cQuery := "SELECT A5_FILIAL, A5_PRODUTO "
      cQuery += " FROM " + RetSqlName("SA5")
      cQuery += " WHERE D_E_L_E_T_ <> '*' AND A5_FILIAL = '" + xFilial("SA5") + "' AND "
      cQuery += " A5_PRODUTO = '" + cCod + "' "

      cQuery := ChangeQuery(cQuery)
      DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_SA5", .T., .T.)

      If !(WK_SA5->(Eof()) .AND. WK_SA5->(Bof()))
         EasyHelp(STR0266)  //"Este registro está vinculado no cadastro Produtos x Fornecedores."
         lRet := .F.
         Break
      EndIf

      /******************************************************************************************/
      /************************************* FASE - PEDIDO **************************************/
      /******************************************************************************************/
      cQuery := "SELECT EJX_FILIAL, EJX_ITEM "
      cQuery += " FROM " + RetSqlName("EJX")
      cQuery += " WHERE D_E_L_E_T_ <> '*' AND EJX_FILIAL = '" + xFilial("EJX") + "' AND "
      cQuery += " EJX_ITEM = '" + cCod + "' "

      cQuery := ChangeQuery(cQuery)
      DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_EJX", .T., .T.)

      If !(WK_EJX->(Eof()) .AND. WK_EJX->(Bof()))
         EasyHelp(STR0267)  //"Este registro está vinculado na fase de Pedido de Aquisição/Venda de Serviço."
         lRet := .F.
         Break
      EndIf

      /******************************************************************************************/
      /************************************ FASE - RAS/RVS **************************************/
      /******************************************************************************************/
      cQuery := "SELECT EJZ_FILIAL, EJZ_ITEM "
      cQuery += " FROM " + RetSqlName("EJZ")
      cQuery += " WHERE D_E_L_E_T_ <> '*' AND EJZ_FILIAL = '" + xFilial("EJZ") + "' AND "
      cQuery += " EJZ_ITEM = '" + cCod + "' "

      cQuery := ChangeQuery(cQuery)
      DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WK_EJZ", .T., .T.)

      If !(WK_EJZ->(Eof()) .AND. WK_EJZ->(Bof()))
         EasyHelp(STR0268)  //"Este registro está vinculado na fase de RAS/RVS."
         lRet := .F.
         Break
      EndIf

   End Sequence

If Select("WK_SW1") <> 0
   WK_SW1->(DbCloseArea())
EndIf
If Select("WK_SW3") <> 0
   WK_SW3->(DbCloseArea())
EndIf
If Select("WK_SA5") <> 0
   WK_SA5->(DbCloseArea())
EndIf
If Select("WK_EJX") <> 0
   WK_EJX->(DbCloseArea())
EndIf
If Select("WK_EJZ") <> 0
   WK_EJZ->(DbCloseArea())
EndIf

RestOrd(aOrd,.T.)
Return lRet

/*
Função     : EasyJava
Objetivo   : Retorna a versão corrente do Java instalado na máquina
Retorno    : cVersão - Versão atual
Autor      : Guilherme Fernandes Pilan
Data/Hora  : 26/04/2016 :: 17:43
*/
*---------------------*
Function EasyJava()
*---------------------*
Local cVersao := ""
Local cBat := ""
Local nHandler := 0

cBat += 'java -version 2>&1 | findstr "version" > javalog.txt'

nHandler := EasyCreateFile(GetTempPath(.T.)+"VersaoJava.bat")
FWrite(nHandler, cBat)
FClose(nHandler) 

WaitRun(GetTempPath(.T.)+"VersaoJava.bat")

If File(GetTempPath(.T.)+"javalog.txt")
   nHandle := EasyOpenFile(GetTempPath(.T.)+"javalog.txt" , 0)
   FRead( nHandle, cVersao, 100 )
   If !Empty(cVersao)
      cVersao := SubStr(cVersao,At('"',cVersao),100)
      cVersao := StrTran(cVersao,'"','')
   EndIf
EndIf

FErase(GetTempPath(.T.)+"VersaoJava.bat") 
FErase(GetTempPath(.T.)+"javalog.txt") 
Return cVersao
/*
Função     : EasyIsInMVC
Objetivo   : Retornar se rotina em questão encontra-se estruturada em MVC
Retorno    : cRotina
Autor      : Guilherme Fernandes Pilan
Data/Hora  : 04/05/2016 :: 16:06
*/
*-----------------------------*
Function EasyIsInMVC(cRotina)
*-----------------------------*
Return ValType(FWLoadModel(cRotina)) == "O"

/*
Funcao      : IniBrwBanco()
Parametros  : 
Retorno     : 
Objetivos   : Iniciliazador de browse campo EEQ_NBCOCR
Autor       : Marcos Roberto Ramos Cavini Filho
Data/Hora   : 16/05/2016
Revisao     :
Obs.        :
*/

Function IniBrwBanco()
Local cRet := ""

If Type("M->EEQ_BCOCR") <> "U" .And. Type("M->EEQ_AGCR") <> "U" .And. Type("M->EEQ_CCCRED") <> "U"
   cRet := Posicione("SA6", 1, xFilial("SA6")+M->(EEQ_BCOCR+EEQ_AGCR+EEQ_CCCRED),"A6_NOME")
EndIf

Return cRet

/*
Função     : EasyOrigem
Objetivo   : Retornar a validação da rotina no AvFlags chamado pelo FINA050
Retorno    : .T./.F.
Autor      : Laercio G Souza Junior
Data/Hora  : 18/05/2016 :: 15:02
*/
Function EasyOrigem(cOrigem)
Local lRet		:= .F., i
Local aCpsBloq  := {}
Local aOrdORI	:= SaveOrd({"SWD"})
Local cHelp     := If(cOrigem == "SIGAEIC", "FAORIEIC", "FAORIEEC")
Local cQry      := ""
Local lSWDExist := .F.

Begin Sequence
If !(cModulo $ "EEC/EIC/EDC/ECO/EFF/ESS")
   cQry := " SELECT R_E_C_N_O_ RECNO FROM "+RetSQLName("SWD")+"	 "
   cQry += " WHERE D_E_L_E_T_ <>'*' "
   If FwModeAccess("SE2",3) == "E"
      cQry += " AND WD_FILIAL  = '"+xFilial("SWD")+"'	 "
   EndIf
   cQry += " AND WD_PREFIXO = '"+SE2->E2_PREFIXO+"'	 "
   cQry += " AND WD_CTRFIN1 = '"+SE2->E2_NUM+"'	 "
   cQry += " AND WD_PARCELA = '"+SE2->E2_PARCELA+"'	 "
   cQry += " AND WD_TIPO	 = '"+SE2->E2_TIPO+"'	 "
   cQry += " AND WD_FORN	 = '"+SE2->E2_FORNECE+"'	 "
   cQry += " AND WD_LOJA	 = '"+SE2->E2_LOJA+"'	 "

   if select("QSWD") > 0
      QSWD->(DbCloseArea())
   endif

   cQry:=ChangeQuery(cQry)
   dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "QSWD", .F., .T.)

   QSWD->(dbGoTop())
   If QSWD->(!eof())
      lSWDExist := .T.
   endif
   QSWD->(DbCloseArea())

	// DFS - 16/03/11 - Deve-se verificar se os títulos foram gerados por módulos Trade-Easy, antes de apresentar a mensagem.
	// TDF - 26/12/11 - Acrescentado o módulo EFF para permitir liquidação
	// NCF - 25/03/13 - Acrescentado o módulo SIGAESS (Siscoserv)
	If Posicione("SA2",1,xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA),"A2_PAIS") <> "105" .AND. SE2->E2_MOEDA > 1
		HELP(" ",1,cHelp)
		lRet := .T.

	ElseIf (cOrigem == "SIGAEIC" .And. (lSWDExist .OR. (UPPER(Alltrim(SE2->E2_TIPO)) == "TX" .AND. SE2->E2_MOEDA == 1)))
      /* Quando for alteração do título a pagar, FINA050, deve permitir a alteração dos títulos, exceto dos campos restringidos no array aCpsBloq.
         Quando for liquidação ou compensação de títulos de despesas nacionais, tipo PA do despachante inclusive, o sistema deve permitir que ocorra
         diretamente no SIGAFIN, bem como deve permitir o estorno da liquidação e/ou compensação destes títulos. */
      aCpsBloq	:= {"E2_VENCREA","E2_VALOR","E2_VLCRUZ"}
      lRet		:= .T.
      lAlteraTit:= .T.

	// GFP - 07/03/2014 - Tratamento para liberar os campos que são permitidos para alteração, com exceção daqueles utilizados pelos módulos de Comercio Exterior.
	ElseIf cOrigem <> "SIGAEIC" .And. UPPER(Alltrim(SE2->E2_TIPO)) == "NF" .AND. SE2->E2_MOEDA == 1
		aCpsBloq	:= {"E2_VENCREA","E2_VALOR","E2_VLCRUZ"}
		lRet		:= .T.
		lAlteraTit	:= .T.  
	Else
		HELP(" ",1,cHelp)
		lRet := .T.
	EndIf

   /* O bloco de código abaixo se aplica apenas à manutenção do título a pagar, pelo fina050. */
   If lAlteraTit .And. IsInCallStack("FINA050")
      aCposEIC := fa050MCpo(4)
      aCpsADD := {"E2_NATUREZ","E2_ISS","E2_IRRF","E2_INSS","E2_VALJUR","E2_PORCJUR","E2_ACRESC","E2_DECRESC","E2_LINDIG"} //LRS - 26/06/2018

      IF(EasyEntryPoint("AVGERAL"),Execblock("AVGERAL",.F.,.F.,"ALTERA_TIT"),)

      For i := 1 To Len(aCpsADD)
         aAdd(aCposEIC,aCpsADD[i])
      Next


      For i := 1 To Len(aCpsBloq)
         If (nPos := aScan(aCposEIC, aCpsBloq[i])) # 0
            ADEL(aCposEIC,nPos)
            ASIZE(aCposEIC,LEN(aCposEIC)-1)
         EndIf
      Next
   EndIf

   RestOrd(aOrdORI,.T.)
EndIf
End Sequence

Return lRet

/*
Função     : EasyFinOri
Objetivo   : Retorna filtro a ser utilizado nos fontes FINA090 e FINA091 para permitir titulos do eic em baixa automatica
Retorno    : cFiltro - Retorna o filtro em formato de query
Autor      : Tiago Henrique Tudisco dos Santos
Data/Hora  : 10/01/2020
*/
Function EasyFinOri()
Local cQry := ""

cQry := "(E2_ORIGEM NOT IN ('SIGAEEC','SIGAEDC','SIGAECO','SIGAEFF','SIGAESS','SIGAEIC') OR (E2_ORIGEM = 'SIGAEIC' AND E2_NUM NOT IN("
cQry += " SELECT WB_NUMDUP FROM "+RetSQLName("SWB")+"	 "  
cQry += " WHERE D_E_L_E_T_ <>'*' "
cQry += " AND WB_FILIAL  = E2_FILIAL "
cQry += " AND WB_PREFIXO = E2_PREFIXO "
cQry += " AND WB_NUMDUP =  E2_NUM "
cQry += " AND WB_PARCELA = E2_PARCELA "
cQry += " AND WB_TIPOTIT = E2_TIPO "
cQry += " AND WB_FORN	 = E2_FORNECE "
cQry += " AND WB_LOJA	 = E2_LOJA "
cQry += "))) "

Return cQry

/*
Função     : AVConvParc
Objetivo   : Converte uma parcela expressa em números por um caracter ASCII correspontende
             quando o tamanho da parcela no destino é menor que o tamanho da mesma na origem. 
Retorno    : lRet - .T./.F.
Autor      : Nilson Cesa C. Filho
Data/Hora  : 12/05/2016 :: 15:08
Obs.       : Observar que a cadeia de caracteres gerados para a parcela de destino sempre
             será terá o tamanho: (tamanho da parcela na origem - 1) para UNCODE e
                                  (tamanho da parcela no destino + 1) para DECODE.
             Exemplo:  Codificar a parcela origem em destino:  AvConvParc( "8226" ,   , 1 , "UNCODE"  )  ==> "‰26" 
                       Decodificar parcela destino em origem:  AvConvParc(  "‰26" , 4 ,   , "DECODE"  )  ==> "8226"
                       Resultado com UNCODE (parcela destino) ->  "‰26" (3 caracteres)  
*/
Function AVConvParc( cParcOri , nLenParOri ,nLenParDes , cOpr )
 
Local   nLenParOri
Local   nParcOri
Local   cRet       := ""
   
Default nLenParDes := 1
Default cParcOri   := ""
Default cOpr       := "UNCODE"
Default nLenParOri := 0

If cParcOri <> "" .And. Val(cParcOri) <> 0  

   nLenParOri := Len(Alltrim(cParcOri))
   nParcOri   := Val(Alltrim(cParcOri))

   If cOPr == "DECODE"
      If Len(Alltrim(cParcOri)) > 1 
         cRet := ( ( Asc( Left( RetAsc(nParcOri,1,.T.), 1)  ,2,.F.) -55 ) * ( 10^(nLenParOri - 2) ) + Val(Right( RetAsc(nParcOri,1,.T.) , nLenParOri - 2 )) )
      Else
         cRet := RetAsc( nParcOri , nLenParDes , .T.)
      EndIf     
   ElseIf  cOPr == "UNCODE"
      cRet := RetAsc( nParcOri , nLenParDes , .T.)
   EndIf
   
ElseIf !Empty(cParcOri) .And. cOpr == "DECODE" .And. nLenParOri <> 0   

   cRet := ( Asc( Left( cParcOri , 1)  ,2,.F.) -55 ) * ( 10^(nLenParOri - 2) ) + Val(Right( cParcOri , nLenParOri - 2 )) 
     
EndIf 

Return cRet

/*
Função     : ConfirmaLote
Objetivo   : Retornar se o lote do item da nota fiscal de entrada corresponde ao lote do item na nota fiscal de saída
Retorno    : .T./.F.
Autor      : Wilsimar Fabricio - WFS / Flávio Danilo Ricardo - FDR
Data/Hora  : Jun/2016
*/
Static Function ConfirmaLote(cLote)
Local aOrd:= SaveOrd({"SD1"})
Local lRet:= .F.

Begin Sequence

   SD1->(DBSetOrder(2)) //D1_FILIAL+D1_COD+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
   If SD1->(DBSeek(xFilial() + AvKey(QryEE9->EE9_COD_I, "D1_COD") + AvKey(EYY->EYY_NFENT, "D1_DOC") + AvKey(EYY->EYY_SERENT, "D1_SERIE") +;
      AvKey(EYY->EYY_FORN, "D1_FORNECE") + AvKey(EYY->EYY_FOLOJA, "D1_LOJA")))

      //Pode haver vários itens com o mesmo código do produto
      While SD1->(!Eof()) .And. SD1->D1_FILIAL == SD1->(xFilial()) .And.;
            SD1->(D1_COD + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) == ;
            AvKey(QryEE9->EE9_COD_I, "D1_COD") + AvKey(EYY->EYY_NFENT, "D1_DOC") + AvKey(EYY->EYY_SERENT, "D1_SERIE") +;
            AvKey(EYY->EYY_FORN, "D1_FORNECE") + AvKey(EYY->EYY_FOLOJA, "D1_LOJA")

         If AvKey(cLote, "D1_LOTECTL") == SD1->D1_LOTECTL
            lRet:= .T. //encontrou
            Exit
         EndIf
         SD1->(DbSkip())
      EndDo

   EndIf

End Sequence

RestOrd(aOrd)
Return lRet

/*
Função     : EasyGeraProv
Objetivo   : Validar opção de geração de titulos provisorios PR e PRE conforme cadastro de despesas.
Retorno    : lRet - .T./.F.
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 25/07/2016 :: 10:41
*/
*--------------------------------------*
Function EasyGeraProv(cTipo, cDespesa)
*--------------------------------------*
Local lRet := .F.
Local aOrd := SaveOrd("SYB")

If !AvFlags("PROVISORIO_DESPESAS")
   lRet := .T.
Else
   SYB->(DbSetOrder(1))  //YB_FILIAL+YB_DESP
   If SYB->(DbSeek(xFilial("SYB")+AvKey(cDespesa,"YB_DESP")))
      If cTipo == "PR" .AND. (Empty(SYB->YB_GERPRO) .OR. SYB->YB_GERPRO == "1" .OR. SYB->YB_GERPRO == "3")
         lRet := .T.
      ElseIf cTipo == "PRE" .AND. (Empty(SYB->YB_GERPRO) .OR. SYB->YB_GERPRO == "2" .OR. SYB->YB_GERPRO == "3")
         lRet := .T.
      EndIf
   EndIf
EndIf

RestOrd(aOrd,.T.)
Return lRet

/*
Função     : EasyFindAdpt
Objetivo   : Verifica se existe adapter cadastrado
Retorno    : lRet - .T./.F.
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 22/08/2016 :: 10:20
*/
*--------------------------------------*
Function EasyFindAdpt(cAdapter)
*--------------------------------------*
 Return fwhaseai(cAdapter)

/*
Função     : EasyExecAHU
Objetivo   : Verifica se sistema deve executar arquivo .AHU (Customizado) ou .APH (Padrão)
Retorno    : cHtml
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 26/09/2016 :: 17:38
*/
*---------------------------*
Function EasyExecAHU(cAPH,lPadrao)
*---------------------------*
Local cHtml := ""
Default lPadrao := .F.
If EXISTUSRPAGE(cAPH) .And. !lPadrao
   cHtml := "L_"+cAPH
Else
   if FindFunction("H_"+cAPH)
      cHtml := "H_"+cAPH
   Else
      easyhelp("Função não encontrada " +  "H_"+cAPH)
   EndIf
EndIf
Return if(empty(cHtml),"",&(cHtml+"()"))


/*
Função     : AvIniPadVt
Objetivo   : Carregar campos virtuais de usuário quando estes possuírem
             inicializar padrão válido.
Parâmetros : cAliasTab - alias da tabela do banco de dados
             cAliasWk  - alias do arquivo temporário
Retorno    : Nenhum
Autor      : Nilson César C. Filho
Data/Hora  : 04/11/2016 :: 10:30
*/
*---------------------------*
Function AvIniPadVt(cAliasTab, cAliasWk )
*---------------------------*
Local cRelacao
Local xRet
Local nOldArea := select()
Local aOrd

If ValType(cAliasTab) == "C" .And. SELECT(cAliasTab) > 0 .And. ValType(cAliasWk) == "C" .And. SELECT(cAliasWk) > 0
   aOrd := SaveOrd("SX3",1)
   SX3->(dbSeek(cAliasTab))
   While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAliasTab

      If SX3->X3_CONTEXT == 'V' .And. !Empty(Alltrim(SX3->X3_RELACAO)) .And. (cAliasWk)->(FieldPos(SX3->X3_CAMPO)) > 0

         cRelacao := Alltrim(SX3->X3_RELACAO)
         xRet     := &(cRelacao)
         If xRet <> NIL .And. ValType(xRet) == SX3->X3_TIPO
            (cAliasWk)->&(SX3->X3_CAMPO) := xRet
         EndIf

      EndIf
      xRet := NIL
      SX3->(dbSkip())
   EndDo
EndIf

DbSelectArea(nOldArea)
RestOrd(aOrd,.T.)

Return .T.

/*
Função  : E_IndRegua
Autor   : wfs
Data    : mar/2017
Objetivo: Chamada genérica para o EECIndRegua
          O EECIndRegua() executará o IndRegua() caso o ambiente não esteja configurado para
          reaproveitamento dos arquivos temporários.
*/
Function E_IndRegua(cAlias,cNIndex,cExpress,xOrdem,cFor,cMens, nIndex)
Return EECIndRegua(cAlias,cNIndex,cExpress,xOrdem,cFor,cMens, nIndex)

/*
Funcao          : TP254Val
Parametros      : número inteiro
Retorno         : .T.
Objetivos       : Existe a chamada a esta funcao nos campos
                  B5_COMPR, B5_ESPESS e B5_LARG
                  Porém não encontarmos essa função nem na Trade  Easy e nem na Totvs
Autor           : Trade Easy/MFR
Data/Hora       : 09:03/2017
Revisao         :
Obs.            :
*/
Function TP254Val(nVal)
Return .T.

Function AvGetM0Fil()
Return Left(SM0->M0_CODFIL,FWSizeFilial())


/*------------------------------------------------------------------------------------
Funcao      : AvAltCarac
Parametros  : cFile - Nome do arquivo que será salvo
Retorno     : String com o nome do arquivo corrigido
Objetivos   : Retirar caracteres não reconhecidos pelas chamadas do Protheus
Autor       : Copiado a função AltCaracter do fonte NFEEXCEL
Data/Hora   : 25/05/2017
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
Function AvAltCarac(cFile)
   cFile := alltrim(cFile)
   cFile := strTran(cFile,"'","_")
   cFile := strTran(cFile,"/","_")
   cFile := strTran(cFile,"\","_")
   cFile := strTran(cFile,"(","_")
   cFile := strTran(cFile,")","_")
   cFile := strTran(cFile,",","_")
   cFile := strTran(cFile,";","_")
   cFile := strTran(cFile,"*","_")
   cFile := strTran(cFile,"$","_")
   cFile := strTran(cFile,"@","_")
   cFile := strTran(cFile,"!","_")
   cFile := strTran(cFile,"|","_")
   cFile := strTran(cFile,":","_")
   cFile := strTran(cFile,"?","_")
   cFile := strTran(cFile,"<","_")
   cFile := strTran(cFile,">","_")
   cFile := strTran(cFile,'"',"_")
   cFile := strTran(cFile,"-","_")
   cFile := strTran(cFile," ","_")
Return cFile

/*
Funcao          : SetMileFilter
Parametros      : 
Retorno         : 
Objetivos       : Filtrar as opções de importação de arquivo do leiaute MILE referente aos móulos de COMEX, retirando-os do aRotina
Autor           : WFS
Data/Hora       : 08/06/2017
Revisao         :
Obs.            :
*/
Static Function SetMileFilter()
Local aArea:= {}

Begin Sequence

   aArea:= GetArea()

   If Select("XXJ") == 0    
      FWOpenXXJ()
   EndIf
   If Select("XXJ") > 0
      DBSelectArea("XXJ")
      DBSetFilter({|| !(Left(XXJ_ADAPT, 3) $ 'EIC|EEC|EDC|EFF|ECO')}, "!Left(XXJ_ADAPT, 3) $ 'EIC|EEC|EDC|EFF|ECO'")
   EndIf
   
   RestArea(aArea)

End Sequence
Return

/*
Função     : AvGetCpBrw
Objetivo   : Verificar os campos que estao com x3_browse como Sim, eliminando os campos informados por parâmetro
Retorno    : Array com os campos a serem exibidos no Browse, retirando campos passados por parametro
Autor      : Tiago Henrique Tudisco dos Santos
Data/Hora  : 18/07/2017 :: 14:09
*/
Function AvGetCpBrw(cAlias,aCamposExc,lAceitaVis)
Local aRet          := {}
Local aArea         := getArea()
Local aAreaSX3      := SX3->(getArea())
Local lCampoExc     := .T.

Default aCamposExc  := {}
Default lAceitaVis  := .F.  //Aceita campos visuais e memo 

SX3->(dbSetOrder(1)) //X3_ARQUIVO + X3_ORDEM
If SX3->(dbSeek(cAlias))

    While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias

        lCampoExc := aScan(aCamposExc, {|X| X == Alltrim(SX3->X3_CAMPO)}) > 0
        If SX3->X3_BROWSE == "S" .And. !lCampoExc
            If !lAceitaVis 
            	aAdd(aRet,SX3->X3_CAMPO)
            ElseIf SX3->X3_CONTEXT <> 'V' .And. SX3->X3_TIPO <> 'M' 
            	aAdd(aRet,SX3->X3_CAMPO)
            EndIf	
        EndIf

        SX3->(dbSkip())
    End

EndIf

RestArea(aAreaSX3)
RestArea(aArea)

Return aRet

/*
Funcao      : AvFormPict
Parametros  : cCampo   : Campo do Dicionario em qual a picture sera espelhada
Retorno     : nDecimal : indica a quantidade de decimais na picture (default decimais do SX3)
Objetivos   : Montar uma picture com os decimais informado.
Autor       : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora   : 21/09/2017
*/
Function AvFormPict(cCampo,nDecimal)

Default nDecimal := AvSX3(cCampo,AV_DECIMAL)

Return FormatPict(cCampo,nDecimal)

/*
Funcao      : EasyEntryPoint()
Parametros  : ponto de entrada
Retorno     : lógico
Objetivos   : Buffer do ExistBlock
Autor       : wfs
Data/Hora   : 27/fev/2018
*/
Function EasyEntryPoint(cBlock)
Local lRet:= .F.
Local nPos:= 0

   If !EasyGetBuffers("EasyEntryPoint",cBlock,@lRet)
      lRet:= ExistBlock(cBlock)
      EasySetBuffers("EasyEntryPoint",cBlock,@lRet)
   EndIf

Return lRet

Function EasySetBuffers(cId,cChave,xSetGet)
Return EasyBuffers(@cId,BUFFER_SET,@cChave,@xSetGet)

Function EasyGetBuffers(cId,cChave,xSetGet)
Return EasyBuffers(@cId,BUFFER_GET,@cChave,@xSetGet)

Function EasyDelBuffers(cId,cChave)
Return EasyBuffers(@cId,BUFFER_DEL,@cChave)

//Static para não chamar de outros programas, usar as funções acima.
Static Function EasyBuffers(cId,nOperation,cChave,xSetGet)
Local oBuffer
Local lRet
Local cBufId

If ValType(cID) <> "C"
   UserException("Chamada invalida do EasyBuffers - ID do tipo "+ValType(cID)+' - '+ProcName(2)+' - '+cValToChar(ProcLine(2)))
EndIf
If (nOperation == BUFFER_GET .OR. nOperation == BUFFER_SET) .AND. ValType(cChave) <> "C"
   UserException("Chamada invalida do EasyBuffers - Chave do tipo "+ValType(cID)+' - '+ProcName(2)+' - '+cValToChar(ProcLine(2)))
EndIf

cBufId := Upper(allTrim(cId))

If oAllBuffers == NIL
   oAllBuffers := tHashMap():New()
   oAllBuffers:Set("EASYBUFFERS",@oAllBuffers)
   lRet := .F.
Else
   lRet := oAllBuffers:Get(cBufID,@oBuffer)
EndIf

If nOperation == BUFFER_GET
    lRet := lRet .AND. oBuffer:Get(cChave,@xSetGet)
ElseIf nOperation == BUFFER_SET
    If !lRet
        oBuffer := tHashMap():New()
        lRet := oAllBuffers:Set(cBufId,@oBuffer)
    EndIf
    lRet := lRet .AND. oBuffer:Set(cChave,@xSetGet)
ElseIf nOperation == BUFFER_DEL
    If ValType(cChave) == "C"
       lRet := !lRet .OR. oBuffer:Del(cChave)
    Else
       lRet := !lRet .OR. oBuffer:Clean()
    EndIf
ElseIf nOperation == BUFFER_LIST
    lRet := lRet .AND. oBuffer:List(@xSetGet)
EndIf

Return lRet

/*
Funcao      : EasyGParam()
Parametros  : cpara, lhelp, xdefault e cfil
              parâmetros do SuperGetMv
Retorno     : conteúdo do parâmetro
Objetivos   : Buffer do EasyGParam()
              Utilização do SuperGetMv para realização de buffer das chamadas do GetMv, melhorando a performance quando a API é executada em loop
Autor       : wfs
Data/Hora   : 27/fev/2018
*/

Function EasyGParam(cParam, lHelp, xDefault, cFil, cEmp)
   Local xRet
   //Local nPos:= 0
   Local aExceptions
   Local aValBuf
   Local oBufGParam
   //Static aBufs := {}//RMD 27/03/19 - Cria um buffer do conteúdo dos parâmetros para otimizar a performance, pois o SuperGetMv apresenta queda de performance quando o buffer fica grande
   Default lHelp:= .F.
   Default cFil:= cFilAnt
   Default cEmp:= cEmpAnt
   /*
      If (nPos:=aScan(aBufs,{|X| x[1] == cFil})) > 0
         oBufGParam := aBufs[nPos][2]
      EndIf
      nPos:= 0
   */

   If !EasyGetBuffers("EasyGParam",cEmp+cFil,@oBufGParam)//oBufGParam == Nil
      oBufGParam := tHashMap():New()
      aExceptions:= {"MV_ASSRUD1", "MV_ASSRUD2", "MV_AVG0001", "MV_AVG0025", "MV_AVG0026", "MV_AVG0027", "MV_AVG0030", "MV_AVG0032", "MV_AVG0042", "MV_AVG0048", "MV_AVG0061", "MV_AVG0098", "MV_AVG0104",;
         "MV_AVG0117", "MV_AVG0126", "MV_AVG0132", "MV_AVG0134", "MV_AVG0135", "MV_AVG0143", "MV_AVG0178", "MV_AVG0194", "MV_CTRL_DI", "MV_CTRL_WA", "MV_DAIVERS", "MV_EDC9999",;
         "MV_EEC0052", "MV_EEC9999", "MV_EECFLOG", "MV_EFF9999", "MV_EIC9999", "MV_ESS9999", "MV_GRVAMPA", "MV_GRVDNCM", "MV_IMPPRCU", "MV_INCLNCM", "MV_MENPESO", "MV_MESI", "MV_MTVERSA", "MV_NF_IN86", "MV_NIVALT",;
         "MV_NR_SUFR", "MV_NRCUSTO", "MV_ORDANE", "MV_ORDRUD", "MV_PEDATO1", "MV_PEDATO2", "MV_SEQ_LI", "MV_SEQARQ", "MV_SEQAVB", "MV_SEQAVP", "MV_SEQLOTE", "MV_SI_NUM", "MV_SPEDURL", "MV_ULT_ATZ", "AVUPDATE02","MV_EASYTMP"}
      aEval(aExceptions, {|x| oBufGParam:Set(cEmp+cFil+x, {Nil, .F.}) })
      EasySetBuffers("EasyGParam",cEmp+cFil,@oBufGParam)
      //aAdd(aBufs,{cFil,oBufGParam})
   EndIf

   If !lHelp .And. !oBufGParam:Get(cEmp+cFil+cParam, @aValBuf)
      xRet := SuperGetMv(cParam, lHelp, xDefault, cFil)
      oBufGParam:Set(cEmp+cFil+cParam, {xRet, .T.})
   ElseIf lHelp .Or. !aValBuf[2]
      xRet := GetMv(cParam, lHelp, xDefault)
   Else
      xRet := aValBuf[1]
   EndIf

Return xRet

/*
Funcao      : OrigChamada
Retorno     : lRet -> .T. se nao tiver sido chamado nem pelo menu, nem pela busca de menu
Objetivos   : Verificar se a rotina foi chamada pelo menu do sistema ou pela busca de menu
Autor       : Carlos Eduardo Olivieri
Data/Hora   : 01/03/2018
*/
Function OrigChamada()

   Local lRet := !IsInCallStack("GETMENUDEF") .And. !IsInCallStack("SEARCHMENUDEF") .And. !IsInCallStack("FWLOADMENUDEF") 

Return lRet


/*
Funcao      : AVGatilho
Retorno     : cRetorno
Objetivos   : Retronar a loja do próximo cadastro que estiver disponível
Autor       : Miguel Prado Gontijo
Data/Hora   : 21/08/2018
*/
Function AVGatilho(cCod,cAli,cTipo)
Local cRetorno:= ""
Default cTipo := ""

If upper(cAli) == "SA2"
    SA2->(DBSetOrder(1))  
    IF SA2->(MSSeek(xFilial("SA2")+cCod))
        DO While SA2->(!Eof()) .AND. SA2->A2_FILIAL == xFilial("SA2") .AND. SA2->A2_COD == cCod
            If TEVlCliFor(cCod,SA2->A2_LOJA,cAli,cTipo,.F.)
                cRetorno:= SA2->A2_LOJA
                Exit
            EndIf
            SA2->(DbSkip()) 
        EndDo
    EndIf
EndIf

If upper(cAli) == "SA1"
    SA1->(DBSetOrder(1))  
    IF SA1->(MSSeek(xFilial("SA1")+cCod))
        DO While SA1->(!Eof()) .AND. SA1->A1_FILIAL == xFilial("SA1") .AND. SA1->A1_COD == cCod
            if TEVlCliFor(cCod,SA1->A1_LOJA,cAli,cTipo,.F.)
                cRetorno:= SA1->A1_LOJA
                exit
            endif
            SA1->(DbSkip())
        EndDo
    EndIf   
EndIf

Return cRetorno

/*
Funcao      : TEVlCliFor()
Retorno     : cRetorno
Objetivos   : Retronar a loja do próximo cadastro que estiver disponível
Autor       : Miguel Prado Gontijo
Data/Hora   : 21/08/2018
*/
Function TEVlCliFor(cCod,cLoja,cAli,cTipo,lMsg)
Local lRet := .T.
Default cTipo := ""
Default lMsg := .T.

    if empty(cLoja)

        if !empty(cCod)
            lRet := (cAli)->(DBSetOrder(1),MSSeek(xFilial(cAli)+ cCod ))
        endif
    
    else //!empty(cCod) ///.and. !empty(cLoja)
        
        if lRet := existcpo(cAli,cCod+cLoja,,,lMsg)
            (cAli)->(DBSetOrder(1),MSSeek(xFilial(cAli)+cCod+cLoja))
            if !empty(cTipo)
                If upper(cAli) == "SA2"
                    lRet := left( alltrim(SA2->A2_ID_FBFN) , 1 ) $ cTipo .Or. Empty(SA2->A2_ID_FBFN) //1-Fabr;2-Forn;3-Todos;4-Exportador;5-Beneficiario
                else
                    lRet := SA1->A1_TIPCLI $ cTipo //1=Importador;2=Consignee;3=Notify;4=Todos
                endif
            endif
        else
            lMsg := .F.
        endif
    endif

if !lRet .and. lMsg
    help( " " , 1 , "REGNOIS")
endif

Return lRet


/*
Funcao      : EicAdicInd
Parâemtros  : cOrigem - Origem da chamada
              cTipo   - Tipo do Retorno desejado (1-Array| 2-string chave ISAM | 3-string para Query)
Retorno     : cIndice - Chave do Índice contendo os campos para quebra de adições conforme a Origem
Objetivos   : Retornar a chave do índice conforme a origem
Autor       : Nilson César
Data/Hora   : 17/08/2018
*/
Function EicAdicInd(cOrigem,cTipo)

Local cIndice     := ""
Local aIndice     := {}
Local lREGIPIW8   := SW8->(FIELDPOS("W8_REGIPI")) # 0
Local lAUTPCDI    := FindFunction("DI500AUTPCDI") .AND. DI500AUTPCDI()
Local lTemAdicao  := EasyGParam("MV_TEM_DI",,.F.)
Local lQbgOperaca := EIJ->(FIELDPOS("EIJ_OPERAC")) # 0 .AND. SW8->(FIELDPOS("W8_OPERACA")) # 0
Local lEIJIPIPauta:= EIJ->(FieldPos("EIJ_VLRIPI")) > 0
Local lTemNVE     := EIM->(FIELDPOS("EIM_CODIGO")) # 0 .AND.;
                     SW8->(FIELDPOS("W8_NVE"))     # 0 .AND.;
                     EIJ->(FIELDPOS("EIJ_NVE"))    # 0 .AND.;
                     SIX->(dbSeek("EIM2"))
Local lDAI        := SW8->(FieldPos("W8_CODMAT")) > 0 .And. EIJ->(FieldPos("EIJ_CODMAT")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)
Local nTipoCondP  := EasyGParam("MV_EIC0075",,1)
Default cTipo := "1"

If cOrigem == "EICADICAO_SW8"
   //"WKREGIST, WKFORN , WKFABR, WKTEC, WKEX_NCM, WKEX_NBM, WKCOND_PA,WKDIAS_PA , WKMOEDA, WKINCOTER , WKREGTRI, WKFUNREG , WKMOTADI, WKTACOII, WKACO_II , WKREGIPI , WKOPERACA, WKNVE , WKREG_PC, WKFUN_PC, WKFRB_PC , WKIPIPAUTA"
   cIndice := "WKREGIST+WKFORN" +If(EICLOJA(),"+W8_FORLOJ","") + "+WKFABR" + If(EICLOJA(),"+W8_FABLOJ","") + "+WKTEC+WKEX_NCM+WKEX_NBM"+;
              If(nTipoCondP == 1 , "+WKCOND_PA+STR(WKDIAS_PA,3,0)" , "+WKTCOB_PA" )+;
              "+WKMOEDA+WKINCOTER"+;
              "+WKREGTRI+WKFUNREG+WKMOTADI+WKTACOII+WKACO_II"+;
              IF(lREGIPIW8,"+WKREGIPI","")+"+WKOPERACA"+;
              IF(lTemNVE,"+WKNVE","")+;
              IF(lAUTPCDI,"+WKREG_PC+WKFUN_PC+WKFRB_PC","")+;
              "+STR(WKIPIPAUTA,15,5)"

ElseIf cOrigem == "EICDI500_SW8"

   cIndice := "WKREGIST+WKFORN" +If(EICLoja(),"+W8_FORLOJ","") + "+WKFABR" + If(EICLoja(),"+W8_FABLOJ","") + "+WKTEC+WKEX_NCM+WKEX_NBM"+;
              If(nTipoCondP == 1 , "+WKCOND_PA+STR(WKDIAS_PA,3,0)" , "WKTCOB_PA")+;
              "+WKMOEDA+WKINCOTER"+;
              "+WKREGTRI+WKFUNREG+WKMOTADI+WKTACOII+WKACO_II"+;
              IF(lREGIPIW8,"+WKREGIPI","")+;
              IF(lQbgOperaca,"+WKOPERACA","")+;
              IF(lTemNVE,"+WKNVE","")+;
              IF(lAUTPCDI,"+WKREG_PC+WKFUN_PC+WKFRB_PC","")+;
              If(!lTemAdicao .OR. lEIJIPIPauta ,"+STR(WKIPIPAUTA,15,5)","")+;
              If(lDAI,"+WKCODMATRI","") 

ElseIf cOrigem == "EICDI500_EIJ"

   cIndice := "EIJ_NROLI+EIJ_FORN+" +If(EicLoja(), "EIJ_FORLOJ+", "") + "EIJ_FABR+" + If(EicLoja(), "EIJ_FABLOJ+", "") + "EIJ_TEC+EIJ_EX_NCM+EIJ_EX_NBM+"+;
              If(nTipoCondP == 1 , "EIJ_CONDPG+STR(EIJ_DIASPG,3,0)" , "EIJ_TCOBPG")+;
              "+EIJ_MOEDA+EIJ_INCOTE"+;
              "+EIJ_REGTRI+EIJ_FUNREG+EIJ_MOTADI+EIJ_TACOII+EIJ_ACO_II"+;
              IF(lREGIPIW8,"+EIJ_REGIPI","")+;
              IF(lQbgOperaca,"+EIJ_OPERAC","")+;
              IF(lTemNVE,"+EIJ_NVE","")+;
              IF(lAUTPCDI,"+EIJ_REG_PC+EIJ_FUN_PC+EIJ_FRB_PC","")+;
              If(lEIJIPIPauta,"+STR(EIJ_VLRIPI,15,5)","")+;
              If(lDAI,"+EIJ_CODMAT","")

EndIf

aIndice := EasyQuebraChave(cIndice,.F.)       // Retorna o array dos campos da chave
cIndice := ""                                 // Limpa a variável

Do Case

   Case cTipo == "1" //Array
      xIndice := aClone(aIndice)

   Case cTipo == "2" //String tipo chave de índice ISAM
      aEval( aIndice, {|x| cIndice += x + "+"  } )  // Transforma array em formato caracter para Chave de índice ISAM
      xIndice := Left( cIndice, Len(cIndice)-1 )    // Retira o sinal do fim   

   Case cTipo == "3" //String tipo query
      aEval( aIndice, {|x| cIndice += "," + x  } )  // Transforma array em formato caracter para Query
      xIndice := Right( cIndice, Len(cIndice)-1 )   // Retira a vírgula do início

End Case

If EasyEntryPoint("EICADICIND")
   ExecBlock("EICADICIND", .F., .F., {cOrigem, cTipo})
EndIf


Return xIndice


/*
Funcao      : EasyEnchAuto()
Parâmetros  : cAlias    - Informe o Alias da tabela que será considerada para simulação/validação do modelo de interface 1.
              aField    - informe o array com os dados a serem simulados/validados pelo modelo de interface 1.
              uTudoOk   - Informe o bloco de código (codeblock) ou a função (string) que será responsavel pela validação da TudoOk da interface modelo 1.
              nOpc      - Informe o código do quarto elemento do aRotina a ser considerado para simulação/validação do modelo de interface 1, sendo: 3 - Inclusão; 4 - Alteração; 5 - Exclusão;
              aCpos     - Informe um array com os campos que deverão ser considerados pela interface modelo 1, mesmo que estiverem fora de uso.
              aEditaveis- Informe os campos que podem ser editados. Quando informado, somente os campos contidos nesse array poderão ser editados.
Retorno     : 
Objetivos   : Retronar a loja do próximo cadastro que estiver disponível
Autor       : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora   : 05/09/2018
*/
Function EasyEnchAuto(cAlias,aField,uTudoOk,nOpc,aCpos,aEditaveis)
Local i
Local nPos
Local aRetira   := {}
Local aFieldAuto:= aClone(aField)

Default aEditaveis  := {}
DEFAULT nOpc        := 3

//Verifica se foi enviado o array com os campos que podem ser editáveis, caso sim, retira do array aField os campos que não são editáveis
If Len(aEditaveis) > 0
    For i := 1 To Len(aFieldAuto)
        If aScan(aEditaveis, aFieldAuto[i][1]) == 0
            aAdd(aRetira, aFieldAuto[i][1])
        EndIf
    Next
    For i := 1 To Len(aRetira)
        If (nPos := aScan(aFieldAuto, {|x| AllTrim(Upper(x[1])) == AllTrim(Upper(aRetira[i])) })) > 0
            aDel(aFieldAuto, nPos)
            aSize(aFieldAuto, Len(aFieldAuto)-1)
        EndIf
    Next
EndIf

Return EnchAuto(cAlias,aFieldAuto,uTudoOk,nOpc,aCpos)


/*
Funcao      : GetFilEIM()
Parâmetros  : cFase     - Informa a fase da NVE se está em "CD" ou "LI" ou "DI"              
Retorno     : Retorna a xFilial de acordo com o critério abaixo:
1) se a tabela EIM é compartilhada, retornar o xfilial da EIM
2) se a tabela EIM é exclusiva e se o cFase for "CD", retornar o xfilial da SB1
3) se a tabela EIM é exclusiva e se o cFase for "LI", retornar o xfilial da SW5
4) se a tabela EIM é exclusiva e se o cFase for "DI", retornar o xfilial da SW8
Autor       : Mauricio Frison
Data/Hora   : 23/11/2018
*/
Function GetFilEIM(cFase)
Local cFilEim  
Local cModoAcesso

cModoAcesso :=  FWModeAccess("EIM")

If cModoAcesso = "C"  // Tabela EIM é compartilhada pega filial da EIM
    cFilEim := xFilial("EIM")  
ElseIf cModoAcesso = "E" .And. cFase = "CD" // EIM é exclusiva e cFase == "CD" pega filial da SB1
    cFilEim := xFilial("SB1") 
ElseIf cModoAcesso = "E" .And. cFase = "LI"  // EIM é exclusiva e cFase == "LI" pega filial da SW5                     
    cFilEim := xFilial("SW5") 
Else                                         // logo entra no cenário da EIM exclusiva e cFase igual a DI pega filial da SW8
    cFilEim := xFilial("SW8") 
EndIf
Return cFilEim    

/*
Funcao      : TEClearChv
Parâmetros  : cAliasArr - Alias da tabela de campos que estão no array de campos a verificar
              aCposAuto - Array de campos que serão verificados
              cAlias    - Alias da variável sob a qual será feita a limpeza
Retorno     : Nenhum
Objetivos   : Limpar as variáveis dos campos de chave composta (Ex.: Fornecedor+Loja)
Autor       : Nilson César
Data/Hora   : 29/03/2019
*/
Function TEClearChv(cAliasArr,aCposAuto,cAlias)

Local   aChavComp := {}
Local   i,j
Default aCposAuto      := {}
Default cAlias    := "M"
aAdd(aChavComp, { "EE7", { {"EE7_IMPORT","EE7_IMLOJA"} , {"EE7_CLIENT", "EE7_CLLOJA"} , {"EE7_FORN", "EE7_FOLOJA"} , {"EE7_EXPORT", "EE7_EXLOJA"} , {"EE7_CONSIG", "EE7_COLOJA"} , {"EE7_BENEF", "EE7_BELOJA"} } } )
aAdd(aChavComp, { "EE8", { {"EE8_FORN"  ,"EE8_FOLOJA"} , {"EE8_FABR"  ,"EE8_FALOJA" } } } )  

If Len(aCposAuto) > 0 .And. (nPosArr := aScan(aChavComp,{|x| x[1] == cAliasArr }) ) > 0
   For i := 1 To Len(aChavComp[nPosArr][2])        
      If Ascan(aCposAuto, {|x| x[1] == aChavComp[nPosArr][2][i][1] }) > 0
         For j := 1 To Len(aChavComp[nPosArr][2][i])
            If IsMemVar( cAlias+"->"+aChavComp[nPosArr][2][i][j] )
               &(cAlias + "->" + aChavComp[nPosArr][2][i][j] ) := ""
            EndIf
         Next j
      EndIf   
   Next i
EndIf

Return
/*
Função     : EasyOpenFile
Objetivo   : substituir fopen
Retorno    : fopen apenas 
Autor      : Mau
Data/Hora  : 
*/
Function EasyOpenFile(cPatch,nModo,xParam3,lChangeCase)
Return fOpen(cPatch,FO_SHARED,xParam3,lChangeCase)
/*
Função     : EasyCreateFile
Objetivo   : substituir fCreate
Retorno    : fopen apenas 
Autor      : Mau
Data/Hora  : 
*/
Function EasyCreateFile(cPatch,nModo,xParam3,lChangeCase)
Return fCreate(cPatch,FO_SHARED,xParam3,lChangeCase)

/*
Função     : EasyRecCount
Objetivo   : substituir Reccount
Retorno    : o núemro de registros da tabela sem considerar os registros deletados
Autor      : Mau
Data/Hora  : 08/05/2019
*/
Function EasyRecCount(cAlias)
Local cTempName, cQuery, aArea
Local nContador := 0, nOldRec
Default cAlias := alias()

    If !Empty(cAlias)
		 aArea := GetArea()
       nOldRec := (cAlias)->(RecNo())

        If !Empty(cTempName := TETempName(cAlias))
           (cAlias)->(dbGoTop())
           (cAlias)->(dbSkip())
           (cAlias)->(dbGoTop())
           
           cQuery:= ChangeQuery("SELECT COUNT(*) CONTADOR FROM " + cTempName + " WHERE D_E_L_E_T_ <> '*' ")
           MPSysOpenQuery(cQuery, "TmpCount")
           DbSelectArea("TmpCount")

           nContador := CONTADOR
           DBCloseArea()
        Else
           nContador := (cAlias)->(LastRec())
        EndIf   
		  
        (cAlias)->(dbGoTo(nOldRec))
		
      restarea(aArea)            
    EndIf

return nContador

Function EasyGetMVSeq(cMV)
Local cRet, cQuery, cAlias
   
   IF cMV == "MV_SEQ_LI"
      //Numeracao da LI automatica por filial
      cQuery := "SELECT MAX(REPLACE(W4_PGI_NUM,'*','')) AS W4_PGI_NUM "+;
                "FROM "+RetSqlName("SW4")+" WHERE '"+xFilial("SW4")+"' = W4_FILIAL and D_E_L_E_T_ = ' ' and W4_PGI_NUM like '*%*' "

      cRet := EasyGetNum("MV_SEQ_LI","SW4","W4_PGI_NUM",,8,cQuery,.T.)
   ElseIF cMV == "MV_SI_NUM"
      //Numeracao da SI automatica (cópia de PO) por filial
      cQuery := "SELECT MAX(REPLACE(W0__NUM,'*','')) AS W0__NUM "+;
                "FROM "+RetSqlName("SW0")+" WHERE '"+xFilial("SW0")+"' = W0_FILIAL and D_E_L_E_T_ = ' ' and W0__NUM like '*%' "
      
      cRet := EasyGetNum("MV_SI_NUM","SW0","W0__NUM",,AVSX3("W1_SI_NUM",3)-1,cQuery,.T.)
   ElseIf cMV == "MV_AVG0126"
      //Mantem a numeracao da FFC Exportação por empresa.
      cQuery := "SELECT MAX(EEQ_FFC) AS EEQ_FFC "+;
                "FROM "+RetSqlName("EEQ")+" WHERE D_E_L_E_T_ = ' ' "
      
      cRet := EasyGetNum(,"EEQ","EEQ_FFC","EEQ_FFC"+cEmpAnt,,cQuery,.F.)
   ElseIf cMV == "MV_CTRL_DI"
      //Mantem a numeracao da DI por empresa.
      cQuery := "SELECT MAX(W6_HAWB) AS W6_HAWB FROM "+RetSqlName("SW6")+" WHERE D_E_L_E_T_ = ' ' "
      
      cRet := EasyGetNum("MV_CTRL_DI","SW6","W6_HAWB","W6_HAWB"+cEmpAnt,15,cQuery,.T.)
   ElseIf cMV == "MV_NRCUSTO"
      //Mantem a numeracao da Custo por filial.
      cQuery := "select MAX(EI1_DOC) from "+RetSqlName("EI1")+" where D_E_L_E_T_ = ' ' and EI1_TIPO_N = '4'
      //MFR OSSME-3488 30/07/2019 
      cRet := EasyGetNum("MV_NRCUSTO","EI1","EI1_DOC",,AvSx3("EI1_DOC", AV_TAMANHO),cQuery,.T.)
   ElseIf cMV == "MV_AVG0134_SE1" .OR. cMV == "MV_AVG0134_SE2"
      //Mantem a numeracao de titulos integrados pelo EasyLink por empresa.
      cQuery := {}
      aAdd(cQuery,"SELECT MAX(EEQ_FINNUM) AS EEQ_FINNUM FROM "+RetSqlName("EEQ")+" WHERE D_E_L_E_T_ = ' ' ")
      aAdd(cQuery,"SELECT MAX(EET_FINNUM) AS EEQ_FINNUM FROM "+RetSqlName("EET")+" WHERE D_E_L_E_T_ = ' ' ")
      aAdd(cQuery,"SELECT MAX(EXL_TITFR) AS EEQ_FINNUM FROM "+RetSqlName("EXL")+" WHERE D_E_L_E_T_ = ' ' ")
      aAdd(cQuery,"SELECT MAX(EXL_TITSE) AS EEQ_FINNUM FROM "+RetSqlName("EXL")+" WHERE D_E_L_E_T_ = ' ' ")
      aAdd(cQuery,"SELECT MAX(EXL_TITFA) AS EEQ_FINNUM FROM "+RetSqlName("EXL")+" WHERE D_E_L_E_T_ = ' ' ")
      aAdd(cQuery,"SELECT MAX(EXL_TITDI) AS EEQ_FINNUM FROM "+RetSqlName("EXL")+" WHERE D_E_L_E_T_ = ' ' ")

      cRet := EasyGetNum(,"EEQ","EEQ_FINNUM","EEQ_FINNUM"+cEmpAnt,AvSx3("E1_NUM", AV_TAMANHO),cQuery,.T.)

      cAlias := RIGHT(cMV,3)
      If (cAlias)->(dbSeek(xFilial()+cModulo+cRet))
         cQuery := {}
         aAdd(cQuery,"SELECT MAX("+RIGHT(cAlias,2)+"_NUM) AS EEQ_FINNUM FROM "+RetSqlName(cAlias)+" WHERE D_E_L_E_T_ = ' ' AND "+RIGHT(cAlias,2)+"_PREFIXO = '"+cModulo+"' ")
         cRet := EasyGetNum(,"EEQ","EEQ_FINNUM","EEQ_FINNUM"+cEmpAnt,,cQuery)
      EndIf
   ElseIf cMV == "MV_CTRL_WA"
      cQuery := "SELECT MAX("+ IF(Upper(TCGetDb()) == "ORACLE","SUBSTR","SUBSTRING") +"(WA_CTRL,1,4)) WA_CTRL FROM "+RetSQLName("SWA")+" WHERE D_E_L_E_T_ = ' ' AND WA_CTRL LIKE '%"+Right(DtoC(Date()),2)+"' "
      lResetLcSrv := AtuNrLicSrv("SWA","WA_CTRL",cQuery,.T.)
      cRet   := EasyGetNum("MV_CTRL_WA","SWA","WA_CTRL",,AvSx3("WA_CTRL", AV_TAMANHO),cQuery,.T.)
      cRet   := PADL(Val(cRet),AvSx3("WA_CTRL",AV_TAMANHO)-2,"0") + RIGHT(STR(YEAR(dDataBase),4,0),2)
   ElseIf cMV == "CTRL_EV0"
      cQuery := {}
      aAdd(cQuery,"SELECT MAX(EV0_ARQUIV) AS EV0_ARQUIV FROM " + RetSqlName('EV0') + " WHERE EV0_FILIAL = '" + xFilial("EV0") + "' AND D_E_L_E_T_ = ' '")
      aAdd(cQuery,"SELECT MAX(EV1_LOTE) AS EV0_ARQUIV FROM " + RetSqlName('EV1') + " WHERE EV1_FILIAL = '" + xFilial("EV1") + "' AND D_E_L_E_T_ = ' '")
      cRet := EasyGetNum(,'EV0','EV0_ARQUIV',,AvSx3("EV0_ARQUIV", AV_TAMANHO),cQuery,.f.)  
   ElseIf cMV == "E5_PROCTRA"
      cQuery := "SELECT MAX(E5_PROCTRA) AS E5_PROCTRA FROM "+RetSqlName("SE5")+" WHERE D_E_L_E_T_ = ' ' "
      cRet := EasyGetNum(,"SE5","E5_PROCTRA","E5_PROCTRA"+cEmpAnt,AvSX3("E5_PROCTRA",AV_TAMANHO),cQuery,.T.)
   EndIf

Return cRet

Function EasyGetNum(cMV,cAlias,cCampo,cChave,nTam,cQuery,lConfirm)
Local aOrd, cInd, aStruct, cFIle, i
Local cSeq, cSeqOld, nTamCampo
Local nSeq := 0
Local aKey, nPos
Private pMVSeq,pMV,pAlias,pChave,pCampo,pTam,pQuery //Parametros private para permitir as customizações

   If !Empty(cMV)
      nSeq := EasyGParam(cMV) 
      If Valtype(nSeq) <> "N" 
         nSeq := Val(nSeq)
      EndIf
   EndIf

   //Ponto de entrada para customização de numerações.
   If EasyEntryPoint("AVGERAL")
      pMV    := cMV
      pAlias := cAlias
      pChave := cChave
      pCampo := cCampo
      pTam   := nTam
      pQuery := cQuery
      pMVSeq   := nSeq
      ExecBlock("AVGERAL",.F.,.F.,"EASYGETNUM")
      nSeq   := pMVSeq
      cMV    := pMV
      cAlias := pAlias
      cCampo := pCampo
      cChave := pChave
      nTam   := pTam
      cQuery := pQuery
   Endif
   
   If nSeq <= 1
      If ValType(cQuery) == "C" .AND. !Empty(cQuery)
         cQuery := {cQuery}
      EndIf
      
      //Se for uma nova base, utilizar GETSXENUM, usar query para criar base alternativa para inicializar a numeracao se necessário
      If len(cQuery) > 0
         If select(cAlias) > 0
            aOrd := SaveOrd({cAlias})
            (cAlias)->(dbCloseArea())
         EndIf

         nTamCampo := AvSx3(cCampo,AV_TAMANHO)
         
         For i := 1 To Len(cQuery)
            EasyQry(cQuery[i],'MVSEQ')
            MVSEQ->(cSeq := AllTrim(FieldGet(FieldPos(cCampo))),dbCloseArea())
            
            If Len(cSeq) < nTamCampo
               cSeq := replicate('0',nTamCampo-Len(cSeq))+cSeq
            ElseIf Len(cSeq) > nTamCampo
               cSeq := Right(cSeq,nTamCampo)
            EndIf

            If cSeqOld == NIL .OR. cSeqOld < cSeq
               cSeqOld := cSeq
            EndIf
         Next i
         aStruct := {{if(left(cAlias,1)=="S",right(cAlias,2),cAlias)+"_FILIAL","C",FWSizeFilial(),0},;
                     {cCampo,AvSx3(cCampo,AV_TIPO),nTamCampo,AvSx3(cCampo,AV_DECIMAL)}}

         cFile := E_CriaTrab(,aStruct,cAlias)
         IndRegua(cAlias,cFile+TEOrdBagExt(),aStruct[1][1]+'+'+aStruct[2][1])
         (cAlias)->(DBSETINDEX(cFile+TEOrdBagExt()))

         (cAlias)->(RecLock(cAlias,.T.))
         (cAlias)->(FieldPut(1,xFilial(cAlias)),FieldPut(2,cSeqOld))
         (cAlias)->(MsUnLock())
      EndIf
           
      cSeq := EasyGSNum(cSeqOld,cAlias,cCampo,cChave)

      IF lConfirm
         ConfirmSX8()
      EndIf

      If ValType(nTam) == "N" .AND. Len(cSeq) > nTam
         cSeq := Right(cSeq,nTam)
      EndIf

      If len(cQuery) > 0
         (cAlias)->(E_EraseArq(cFile))
         ChkFile(cAlias)
         If aOrd <> NIL
            restOrd(aOrd,.T.)
         EndIf
      EndIf
   Else
      cSeq := STRZERO(nSeq+1,nTam,0)
      PutMv(cMV,cSeq)
   EndIf

Return cSeq

Function EasyGSNum(cTableNum,cAlias,cCampo,cAliasSX8,nOrdem,lForceReset)
Local cSeq, nPos, aKey, nErr
Default lForceReset := .F.
//mfr traz  a sequencia errada 
cSeq := GETSXENUM(cAlias,cCampo,cAliasSX8,nOrdem)
If !Empty(cTableNum) .AND. len(cTableNum) == Len(cSeq) .AND. ( cTableNum >= cSeq  .Or. lForceReset )
   cChave := Upper(GetSrvProfString("SpecialKey",""))+if(cAliasSX8 <> NIL,cAliasSX8,xFilial(cAlias))
   //cAliasSX8
   If (nPos := aScan(aKey := GetLSKeys(),{|X| left(X[1],len(cChave)) == cChave .AND. X[2] == cSeq .AND. X[3] == cAlias .AND. X[4] == cCampo})) > 0
      If (nErr := LS_ChangeFreeNum(aKey[nPos][1],Soma1(cTableNum))) < 0
         UserException("EasyGSNum Error on "+cAlias+" ("+cValToChar(nErr)+")")
      EndIf
      cSeq := GETSXENUM(cAlias,cCampo,cAliasSX8,nOrdem)
   EndIf
EndIf

Return cSeq

/*
Função     : EasyELinkError
Objetivo   : Exibir mensagem de erro na integração do EasyLink
Retorno    : Nil
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 13/06/2019
*/
Function EasyELinkError(cAction, lTela)
Local cMsg := ""
Default lTela := .T.

    If ValType(NomeAutoLog()) == "C" .And. !Empty(cMsg := MemoRead(NomeAutoLog()))
        FErase(NomeAutoLog())
        __cFileLog := Nil
    EndIf

    If cAction == "FIN" .And. !Empty(StrTran(cMsg,ENTER,""))
        If lTela
            EECView("A gravação não ocorreu devido à impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer para maiores detalhes." + ENTER + ENTER + "Mensagem Retornada:" + ENTER + ENTER + cMsg)  // "A gravação não ocorreu devido à impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."
        Else
            EasyHelp("A gravação não ocorreu devido à impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer para maiores detalhes." + ENTER + ENTER + "Mensagem Retornada:" + ENTER + ENTER + cMsg, "Aviso")
        EndIf
    EndIf

Return Nil

/*
Função     : EasyWkLoad
Objetivo   : Carregar dados de um consulta SQL para uma Work através de um INSERT direto na Work
Retorno    : Lógico: .T. - Carga efetuada com sucesso; .F. - Carga não efetuada
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Obs        : A função espera que a Work tenha os mesmos campos que a tabela base (cAliasBase). Para outros cenários, devemos ir melhorando os tratamentos contidos nesta função.
Data/Hora  : 04/10/2019
*/
Function EasyWkLoad(cAliasBase, cAliasWk, cChave, cCampoBusca)
Local i
Local cQuery 		:= ""
Local aCamposQry 	:= EasyQuebraChave(cCampoBusca)
Local cWhere		:= ""
Local cDado			:= ""
Local nPos			:= 1
Local aEstrutura	:= (cAliasBase)->(dbStruct())
Local cCpoInsert	:= ""
Local cPrefixo		:= If(AT("_",cCampoBusca)>3,Left(cCampoBusca,3),"S"+Left(cCampoBusca,2))
Local cSelect		:= ""
//THTS - 02/10/2019 - Atualizacao para tratar via query, pois o carregamento da work estava muito lento quando a tabela EWZ possui muitos itens.
aEval(aEstrutura,{|x| cCpoInsert += x[1] + ","})
cCpoInsert := SubStr(cCpoInsert,1,Len(cCpoInsert)-1)
For i := 1 To Len(aCamposQry)
    cDado := SubStr(cChave,nPos,Len((cAliasBase)->(&(aCamposQry[i]))))
    If !Empty(cDado)
        cWhere += aCamposQry[i] + " = '" + cDado + "' AND "
    EndIf
    nPos += Len((cAliasBase)->(&(aCamposQry[i])))
Next
cWhere += " D_E_L_E_T_= ' ' "

cQuery := "INSERT INTO " + TETempName(cAliasWk) + " "
cQuery += " (" + cCpoInsert + ") "

cSelect:= "SELECT "+ cCpoInsert +" FROM " + RetSqlName(cAliasBase) + " "
cSelect+= "WHERE " + cPrefixo + "_FILIAL = '" + xFilial(cAliasBase) + "' AND " + cWhere
cSelect := ChangeQuery(cSelect)

cQuery += cSelect

If TcSQLExec(cQuery) < 0
    UserException("TCSQLError() " + TCSQLError())
EndIf
(cAliasWk)->(DbGoTop())

Return

/*
Função     : EasyEICOri
Objetivo   : Verifica se a função chamadora é do módulo EIC ou algum modulo da TradeEasy
Retorno    : Lógico: .T. - Função pertence ao EIC ou TradeEasy; .F. - Função pertence a outro modulo
Autor      : Ramon Prado
Data/Hora  : 11/02/2020
*/
Function EasyEICOri(cRotina)
Local lRet := .F.

If cRotina $ 'FI400GERPA|EICDI501|EICDI502|EICAP100' 
   lRet := .T.
EndIf

Return lRet


/*
Função     : TEWaitRun()
Parametros : cFileName - Nome do arquivo
             lEnd
             nSeconds  -Tempo máximo de aguardo para execução em segundos
             cMensagem - Mensagem para exibição
             lExclui - Exclui o arquivo gerado ou não
Retorno    : .F. se for cancelado pelo usuário ou exceder o tempo máximo
Objetivos  : AUxiliar em execução de programas externos
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora  : 10/06/2020
*/
Function TEWaitFile(cFileName,lEnd,nSeconds,cMensagem,lExclui)
Local lRet   := .T.
Local nTimeOut
Local nHandle   := 0
Local nHour
Local nMinute
Local nSecond
Default nSeconds  := 60*60
Default cMensagem := "Tempo máximo para execução"
Default lExclui := .T.
nTimeOut  := Seconds() + nSeconds
ProcRegua(nSeconds)

Begin Sequence

    nHandle := F_ERROR
    //Tenta abrir o arquivo em modo exclusivo
    While lRet .And. (!File(cFileName) .Or. (nHandle := EasyOpenFile(cFileName, FO_EXCLUSIVE)) == F_ERROR)
        // Se o cliente cancelar ou o exceder o tempo
        If lEnd .Or. nTimeOut <= Seconds()
            lRet := .F.
        Else
            nHour   := Int( nSeconds / 3600 )
            nMinute := Int( ( nSeconds - (nHour*3600) ) / 60 )
            nSecond := Int( nSeconds - (nHour*3600) - (nMinute*60) )
            IncProc(cMensagem+" ("+StrZero(nHour,2)+":"+StrZero(nMinute,2)+":"+StrZero(nSecond,2)+")")
            AvDelay(1)
            nSeconds--
        EndIf
    End

    If nHandle != F_ERROR
        FClose( nHandle )
    EndIf
    If lExclui .And. File(cFileName)
        FErase(cFileName)
    EndIF
End Sequence

Return lRet


/*
Função     : TEVldEnch()
Parametros : aAUto      - Array com os campos recebidos da ExecAuto
             aEdita     - Array com os campos que são editaveis e devem permanecer no array aAuto
             aRetira    - Array com campos específicos que se deseja retirar do array aAuto
Retorno    : aRet - Retorna o array com os campos a serem passados para a EnchAuto
Objetivos  : AUxiliar em execução de programas externos
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora  : 10/06/2020
*/
Function TEVldEnch(aAuto, aEdita, aRetira)
Local i, nPos
Local aReturn := aClone(aAuto)

Default aEdita    := {}
Default aRetira   := {}

    If !Empty(aEdita)
      For i := 1 To Len(aReturn)
         If aScan(aEdita, aReturn[i][1]) == 0
               aAdd(aRetira, aReturn[i][1])
         EndIf
      Next
	EndIf
    For i := 1 To Len(aRetira)
        If (nPos := aScan(aReturn, {|x| AllTrim(Upper(x[1])) == AllTrim(Upper(aRetira[i])) })) > 0
            aDel(aReturn, nPos)
            aSize(aReturn, Len(aReturn)-1)
        EndIf
    Next

Return aReturn

/*
Função     : EasyExRdm()
Parametros : cFunc      - caractere da função a ser executada/chamada
             p1    - parâmetro 1 da função que será executada/chamada
             p2    - parâmetro 2 da função que será executada/chamada
             ...
             p10    - parâmetro 10 da função que será executada/chamada
Retorno    : Execução do código da chamada da função passada por parametro cFunc
Objetivos  : AUxiliar em execução de programas externos
Autor      : Ramon Prado
Data/Hora  : 17/09/2020
*/
Function EasyExRdm(cFunc,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15)
Return Eval(&("{|p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15| "+alltrim(cFunc)+"(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15)}"),p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15)

/*
Função     : AtuNrLicSrv()
Parametros : Alias     - Alias da tabela que contem o campo com numeração automática
             Campo     - Alia do campo com numeração automática
             Query     - Query para buscar a maior ocorrência de chave para o campo
             lSufixAno - Se controla os 2 dígitos finais da chave com o ano corrente
Retorno    : .T. se forçou a atualização da numeração do License Server
Objetivos  : Forçar a atualização da numeração do campo no License Server se necessário
Autor      : Nilson César
Data/Hora  : 01/04/2020
*/
Static Function AtuNrLicSrv(cAlias,cCampo,cQuery,lSufixAno)

Local nTamCpo, cSeqLicSrv, cSeqTab, cSeqReset, lForcResNr := .F.
Local lRet := .F.   
Default lSufixAno := .F.

   nTamCpo    := AvSX3(cCampo,AV_TAMANHO)
   nVlrMAx    := Val(Replicate('9',nTamCpo-If(lSufixAno,2,0) ))	    
   cSeqLicSrv := GETSXENUM(cAlias,cCampo)            
   EasyQry(cQuery,'TMPMVSEQ')            
   TMPMVSEQ->(cSeqTab := AllTrim(FieldGet(FieldPos(cCampo))),dbCloseArea())	    
   If (lForcResNr := Val(cSeqTab) == 0 .Or. Val(cSeqLicSrv) > Val(cSeqTab))          	    
      cSeqTab := STRZERO( If( Val(cSeqTab) == 0 .Or. Val(cSeqTab) == nVlrMax , 0 , Val(cSeqTab) ) ,nTamCpo,0)               
      cSeqReset := EasyGSNum(cSeqTab,cAlias,cCampo,,,lForcResNr)
      RollBackSXE()
      lRet := .T.
   EndIf

Return lRet


/*/AVIndSeek
   Função pra retornar os Indices que vão aparecer na pesquisa do Browse
   @author Tiago Tudisco
   @since 21/01/2022
   @Param cAlias     - Alias a ser considerado os Indices
          nQtdIndice - Quantidade de Indice a retornar, começando do 1
   @version 1
/*/
Function AVIndSeek(cAlias,nQtdIndice)
Local aRet     := {}
Local aAux     := {}
Local aPesq    := {}
Local cPesq
Local nI
Local nX

For nI := 1 To nQtdIndice
   aAdd(aAux, StrToKArr((cAlias)->(IndexKey(nI)),"+"))
Next

For nI := 1 To Len(aAux)
   cPesq := ""
   aPesq := {}
   For nX := 1 To Len(aAux[nI])
      cPesq += AvSX3(aAux[nI][nX],AV_TITULO) + IIF(nX < Len(aAux[nI])," + ","")
      AAdd(aPesq,  {"", AvSx3(aAux[nI][nX], AV_TIPO), AvSx3(aAux[nI][nX], AV_TAMANHO), AvSx3(aAux[nI][nX], AV_DECIMAL), AvSx3(aAux[nI][nX], AV_TITULO)})
   Next nX
   aAdd(aRet,{cPesq,aClone(aPesq),nI})
Next nI

Return aRet

/*
Função   : TESimbToMoeda
Parametro: cSimbMoeda - Simbolo da moeda a ser verificada
Objetivo : Retornar o numero da moeda com base no Simbolo, base SX6
Autor    : Tiago Tudisco
Data     : 11/02/2022
*/
Function TESimbToMoeda(cSimbMoeda)
Local nMoeda := 0

   If !EasyGetBuffers("TESimbToMoeda",cSimbMoeda,@nMoeda)
      nMoeda := SimbToMoeda(cSimbMoeda)
      EasySetBuffers("TESimbToMoeda",cSimbMoeda,@nMoeda)
   EndIf

Return nMoeda

/*
Função   : TEOrigEasy
Parametro: -
Objetivo : Retornar a origem dos modulos do Easy a serem considerados na geração do Registro F100. 
           Função utilizada no fonte do Financeiro FINXSPD.PRX, localizado na pasta ADM do tfs.
Autor    : Tiago Tudisco
Data     : 18/03/2022
*/
Function TEOrigEasy()
Private cRet := "SIGAEIC|SIGAEEC|SIGAEFF|SIGAESS"

If EasyEntryPoint("AVGERAL")
   ExecBlock("AVGERAL",.F.,.F.,{"ORIGEM_EASY_F100"})
Endif

Return cRet

/*
Função     : AVgetUrl()
Objetivo   : Validar a url a ser utilizada na integração com o portal único e validar os cenários de smartclientHtml
Parâmetro  :
Retorno    : Retorna a url de teste ou produção, ou vazio para não seguir com a integração
Autor      : Maurício Frison
Data/Hora  : Abril/2022
Obs.       :
*/
function AVgetUrl()
local cUrl := ''
local cLib
local cURLTest    := EasyGParam("MV_EIC0073",.F.,"https://val.portalunico.siscomex.gov.br") // Teste integrador localhost:3001 - val.portalunico.siscomex.gov.br
local cURLProd    := EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br") // Produção - portalunico.siscomex.gov.br 
local lIntgProd   := EasyGParam("MV_EIC0074",.F.,"1") == "1"

GetRemoteType(@cLib)
If 'HTML' $ cLib
      easyhelp(STR0316,STR0317,STR0318) // "Integração com Portal Único não disponível no smartclientHtml","Utilizar o smartclient aplicativo"
else
   if !lIntgProd 
      If ! msgnoyes( STR0319 + ENTER ; // "O sistema está configurado para integração com a Base de Testes do Portal Único."
         + STR0320 + ENTER ; // "Qualquer integração para a Base de Testes não terá qualquer efeito legal e não deve ser utilizada em um ambiente de produção."
         + STR0321 + ENTER  ; //"Para integrar com a Base Oficial (Produção) do Portal Único, altere o parâmetro 'MV_EEC0054' para 1."
         + STR0322 , STR0122 ) // "Deseja Prosseguir?" // "Atenção"
      Else
         cUrl :=  cURLTest
      EndIf     
   Else       
      cUrl :=  cURLProd
   EndIf   
EndIf
return cUrl

/*/{Protheus.doc} AVAuth
   Gera o script para autenticar e consumir o serviço do portal único através do easyjs 
   @author Maurício Frison
   @since abril/2022
   @Parâmetro: cUrlAut - url de autenticação ex: "/portal/api/autenticar"
               cUrlInteg - url de integração ex: "/duimp-api/api/ext/duimp"
               cTxtJson - texto com o json a ser enviado na integraçaõ
               cTipoUrl - tipo da integraçaõ ex: "POST", "PUT", "DELTE" e etc...
               lBody - se .T. indica que tem o body se .F. não tem
   /*/
Function AVAuth(cUrlAut,cUrlInteg,cTxtJson,cTipoUrl,lBody)
   Local cVar
   Default lBody := .T.
   begincontent var cVar
      fetch( '%Exp:cUrlAut%', {
         method: 'POST',
         mode: 'cors',
         headers: { 
            'Content-Type': 'application/json',
            'Role-Type': 'IMPEXP',
         },
      })
      .then( response => {
         if (!(response.ok)) {
            throw new Error( response.statusText );
         }
         var XCSRFToken = response.headers.get('X-CSRF-Token');
         var SetToken = response.headers.get('Set-Token');
      return fetch( '%Exp:cUrlInteg%', {
            method: '%Exp:cTipoUrl%',
            mode: 'cors',
            headers: { 
               'Content-Type': 'application/json',
               "Authorization": SetToken,
               "X-CSRF-Token":  XCSRFToken,
            },
            body: '%Exp:cTxtJson%'
         })
      })
      .then( (res) => res.text() )
      .then( (res) => { retAdvpl(res) } )
      .catch((e) => { retAdvplError(e) });
   endcontent
   If !lBody
      cVar := StrTran(cVar,"body: ''",'',1,1)
   EndIf   
Return cVar

/*/{Protheus.doc} EasyVldSX9
   Realiza validações de relacionamento de tabelas SX9

   @type  Function
   @author bruno akyo kubagawa
   @since 03/06/2022
   @version 1.0
   @param cTabDom, caracter, Tabela de Domínio
          aTabCDom, vetor, [1] caracter, Tabela de Contra Domínio / [2] vetor, Filiais da tabela de contra dominio
          cMsgError, caracter, Mensagem de validação
          lMsg, lógico, Se apresenta o EasyHelp (.T.) 
   @return lRetorno, lógico, resultado da validação do relacionamento entre tabelas
   @example
      SWF - Tabela de Domínio (X9_DOM)
      SW2, SW6 - Tabela de Contra Domínio (X9_CDOM)
/*/
function EasyVldSX9( cTabDom , aTabCDom , cMsgError , lMsg )
   local lRetorno   := .T.
   local aArea      := GetArea()
   local nTab       := 0
   local aRelations := {}
   local cAliasCDOM := ""
   local aFiliais   := {}
   local cPrefixo   := ""
   local nPosRel    := 0
   local nCpo       := 0
   local aCpoDom    := {}
   local aCpoCDom   := {}
   local cCpoDOM    := ""
   local cCpoCDOM   := ""
   local cAliasQry  := ""
   local cQuery     := ""
   local cInfCpoDOM := ""
   local cType      := ""
   local nFil       := 0
   local cFiliais   := ""

   default cTabDom    := ""
   default aTabCDom   := {}
   default cMsgError  := ""
   default lMsg       := .T.

   cTabDom := alltrim(upper(cTabDom))
   cMsgError := ""
	if !empty(cTabDom) .and. (cTabDom)->(!eof()) .and.  (cTabDom)->(!bof()) 

      for nTab := 1 to len(aTabCDom)

         aSize(aRelations, 0)
         aRelations := {}
         cAliasCDOM := alltrim(upper(aTabCDom[nTab][1]))
         aFiliais := aTabCDom[nTab][2]
         cPrefixo := PrefixoCpo(cAliasCDOM)

         if FWSX9Util():SearchX9Paths( cTabDom, cAliasCDOM, @aRelations ) .and. len(aRelations) > 0
         
            nPosRel := aScan(aRelations, { |X| alltrim(upper(X[1])) == cTabDom .and. alltrim(upper(X[3])) == cAliasCDOM .and. alltrim(upper(x[5])) == "S" } )
            if nPosRel > 0

               aCpoDom := StrTokArr(aRelations[nPosRel][2] ,"+")
               aCpoCDom := StrTokArr(aRelations[nPosRel][4],"+")
               cAliasQry := GetNextAlias()

               cQuery := " SELECT COUNT(*) QTD FROM " + RetSqlName(cAliasCDOM) + " CDOM "
               cQuery += " WHERE CDOM.D_E_L_E_T_ = ' ' "

               if len(aFiliais) > 0
                  
                  cQuery += " AND " + cPrefixo + "_FILIAL "
                  
                  cFiliais := ""
                  for nFil := 1 to len(aFiliais)
                     cFiliais += "'" + aFiliais[nFil] + "'"
                     cFiliais += if(nFil==len(aFiliais), "", ", " )
                  next

                  cQuery += if( len(aFiliais) == 1 , " = " + cFiliais + " ", " IN ( " + cFiliais + " ) " ) 

               endif

               for nCpo := 1 to min( len(aCpoCDom) , len(aCpoDom) )

                  cCpoDOM := aCpoDom[nCpo]
                  cCpoCDOM := aCpoCDom[nCpo]
                  cInfCpoDOM := (cTabDom)->&(cCpoDOM)

                  // tratar os campos conforme o tipo quando necessário
                  cType := valtype((cTabDom)->&(cCpoDOM))
                  if cType == "C"
                     cQuery += " AND " + cCpoCDOM + " = '" + cInfCpoDOM + "' "
                  endif

               next

               dbUseArea(.T.,"TOPCONN",cAliasQry,TcGenQry(,,cQuery))
               if (cAliasQry)->QTD > 0
   
                  if empty(cMsgError)
                     cMsgError := STR0323 + " " + CRLF // "Validação de integradade de dados."
                     cMsgError += STR0324 + ": " + CRLF // "Foi encontrado referência da(s) tabela(s)"
                  endif
                  cMsgError += " - '" + cAliasCDOM + "' - " + STR0325 + ": '" + alltrim( RetTiTle( cCpoCDOM ) ) + "' (" + AllTrim( cCpoCDOM ) + ") " + CRLF // "Campo"

               endif
               (cAliasQry)->(dbCloseArea())

            endif

         endif

      next nTab

	endif

   restArea(aArea)

   lRetorno := empty(cMsgError)
   if lMsg .and. !lRetorno
      EasyHelp(cMsgError,"Aviso")
   endif

return lRetorno

//-----------------------------------------------------------------------------------------------------------------*
//                                   FIM DO PROGRAMA AVGERAL.PRW
//-----------------------------------------------------------------------------------------------------------------*
