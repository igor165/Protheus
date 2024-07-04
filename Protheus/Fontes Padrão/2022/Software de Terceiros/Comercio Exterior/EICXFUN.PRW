//#include "FiveWin.ch" 
#include "AVERAGE.CH"
#include "EICXFUN.ch"
                                                                                
#DEFINE say_tit 1
#DEFINE say_det 2
#DEFINE say_rep 3
#DEFINE INCLUSAO            3
#DEFINE ALTERACAO           4
                                     
/*

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³E_CriaCampo³ Autor ³ AVERAGE-MJBARROS     ³ Data ³ 27/11/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria aCampos p/ MSSelect / Relatorio                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ E_CriaCampos(aCamposTRB)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Tabela a ser utilizada pela MSSelect / Relatorio           ³±±
±±³          ³ aCampos e aHeader devem estar definidas como PRIVATE       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function E_CriaCampos(aNewFields,lRel,nIni)

LOCAL cPict, nInd

If(lRel=NIL,lRel:=.F.,)
If(nIni=NIL,nIni:=1,)

ASize(aNewFields,0)

If ! lRel
   AAdd(aNewFields,{"XX_FLAGWIN","","    "})
Endif

For nInd:=nIni To Len(aCampos)

    If (nPos:=Ascan(aHeader,{|x| Trim(x[2]) == Trim(aCampos[nInd]) })) > 0
       cPict:=If(!Empty(aHeader[nPos,3]),Trim(aHeader[nPos,3]),)

       If ! lRel
          AAdd(aNewFields,{aCampos[nInd],"",aHeader[nPos,1],cPict})
       Else
          If aHeader[nPos,8] = "C"
             cAlinha:="E"
          Elseif aHeader[nPos,8] = "N"
             cAlinha:="D"
          Else
             cAlinha:="C"
          Endif

          If cPict=NIL
             AAdd(aNewFields,{aCampos[nInd],aHeader[nPos,1],"C"})
          Else
             AAdd(aNewFields,{"TRANSFORM("+aCampos[nInd]+",'"+cPict+"')",aHeader[nPos,1],"C"})
          Endif
       Endif

    Endif
Next
Return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³E_CriaRCamp³ Autor ³ AVERAGE-MJBARROS     ³ Data ³ 17/12/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria aRCampos p/ Relatorio                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ E_CriaCampos(TB_Campos,cAlinha)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Tabela a ser utilizada pela funcao padrao de emissao de    ³±±
±±³          ³ relatorios                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function E_CriaRCampos(TB_Campos,cAlinha,nLinha,nFim)
*----------------------------------------------------------------------------
// GFP - 19/03/2014 - Alterado o caracter para Chr(63), pois a nova versão do TDS não permite salvar os arquivos com caracteres especiais.
LOCAL aTranslate:={ {"‡","c"},{"§","o"},{" ","a"},{"Æ","a"},{"‚","e"},;
                    {"¡","i"},{"¢","o"},{"£","u"},{"ˆ","e"},{"ä","o"},;
                    {"€","C"},          {"µ","A"},{"Ç","A"},{Chr(63),"E"},;
                    {"Ö","I"},{"à","O"},{"é","U"},{"Ò","E"},{"å","O"} }, cTitulo

LOCAL aRCampos:={}, nInd, nTrans, cCaracter, cPict
If(nLinha==NIL,nLinha:=1,)
If(nFim==NIL,nFim:=Len(Tb_Campos),)
If(cAlinha=NIL,cAlinha:="E",)

For nInd:=nLinha To nFim

    cTitulo:=TB_Campos[nInd,3]

    For nTrans:=1 To Len(aTranslate)

        cCaracter:=OemToAnsi(aTranslate[nTrans,1])

        If At(cCaracter,cTitulo) # 0
           cTitulo:=StrTran(cTitulo,cCaracter,aTranslate[nTrans,2])
        Endif
    Next

    If Len(TB_Campos[nInd]) > 3 .And. (cPict:=TB_Campos[nInd,4]) # NIL .And. ;
       !Empty(cPict)

       AAdd(aRCampos,{"TRANSFORM("+TB_Campos[nInd,1]+",'"+cPict+"')",cTitulo,cAlinha})

    Else
       AAdd(aRCampos,{TB_Campos[nInd,1],cTitulo,cAlinha})
    Endif

Next

Return aRCampos

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³E_Periodo  ³ Autor ³ AVERAGE-MJBARROS     ³ Data ³ 17/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se intervalo de datas esta ok                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ E_Periodo(DataInicial,DataFinal)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Data Inicial e Data Final (opcional, assume do SX1         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION E_Periodo()

IF mv_par01 > mv_par02
   Help(" ",1,"EFUNPERI")
   RETURN .F.
ENDIF

RETURN .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EICXFUN   ºAutor  ³AVERAGE - JMS       º Data ³  01/20/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ VALIDA INTERVALO DE DATA                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ VALIDACAO DO SX1                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*-----------------------*
FUNCTION EICDATA_VAL()  //VALIDA NO SX1
*-----------------------*
IF !EMPTY(mv_par02)
   IF mv_par01 > mv_par02
      Help("", 1, "AVG0003006")//"Data Inicial Maior que Data Final",1)
      RETURN .F.
   ENDIF
ENDIF
RETURN .T.
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ E_LinOk  ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 22.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas do Orcamento. ³±±
±±³          ³ (USADA APENAS COMO COMPATIBILIZACAO COM GETDADDB)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ExpN1 = E_LinOk                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor devolvido pela fun‡„o                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function E_LinOk(o)
Local lRet := .T.
// Fazer as consistencias especiais

Return( lRet )


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³E_Valid   ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 07.08.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao de Campos antes da confirmacao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³E_Valid(aGets,bValid)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aGets = array gerada pela Enchoice c/ campos a serem       ³±±
±±³          ³         validados                                          ³±±
±±³          ³ bValid=bloco de validacao que recebe como parametro o nome ³±±
±±³          ³        do campo                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
FUNCTION E_Valid(aGets,bValid)

LOCAL nInd, nGets:=LEN(aGets)
FOR nInd:=1 TO nGets
    IF ! EVAL(bValid,ALLTRIM(SUBS(aGets[nInd],9,10)))
       RETURN .F.
    ENDIF
NEXT
RETURN .T.


*-------------------------------*
FUNCTION E_VerPrazo (PValor)
*-------------------------------*

IF PValor > 99999
   RETURN 99999
ENDIF

IF PValor < -9999
   RETURN 99998
ENDIF

RETURN PValor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³E_Report  ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 05/11/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³Relat¢rios Gen‚ricos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³E_Report(aDados,aRCampos)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Gen‚rico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function E_Report(aDados,aRCampos,lMarca,lSetPrint)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cString    := aDados[1]
LOCAL cDesc1     := aDados[2]
LOCAL cDesc2     := aDados[3]
LOCAL cDesc3     := aDados[4]
LOCAL tamanho    := aDados[5]
LOCAL limite     := aDados[6]
LOCAL cabec1     := aDados[7]
LOCAL cabec2     := aDados[8]
LOCAL wnrel      := aDados[11]

LOCAL lPermiteComprimir:=.T.

PRIVATE titulo   := aDados[9]
PRIVATE aReturn  := aDados[10]  // 1=formulario
                                // 2=no.vias
                                // 3=destinatario
                                // 4=formato (1-comprimido, 2-normal)
                                // 5=midia (1-disco, 2-impressora)
                                // 6=porta (1-lpt1, 2-lpt2, 4-com1)
                                // 7=expressao do filtro
                                // 8=ordem a ser selecionada
PRIVATE R_Funcoes:= aDados[12]
PRIVATE R_Campos := aRCampos

PRIVATE nomeprog := wnrel
PRIVATE nLastKey := 0
PRIVATE cPerg    :=NIL


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄgÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lMarca == Nil
   lMarca:= .F.
ENDIF
IF lSetPrint == NIL .OR. lSetPrint
   Wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.f.,,lPermiteComprimir,tamanho)
ENDIF
//wnrel := SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.t.)

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

RptStatus({|lEnd| E_Imprime(@lEnd,wnRel,cString,tamanho,limite,cabec1,cabec2,lMarca)},titulo)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³E_Imprime ³ Autor ³AVERAGE/MJBARROS       ³ Data ³ 05/12/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Fun‡Æo gen‚rica para impressÆo de relat¢rios                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ E_Imprime                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*-----------------------------------------------------------------------------------*
Function E_Imprime(lEnd,WnRel,cString,tamanho,limite,cabec1Loc,cabec2Loc,lMarca)
*-----------------------------------------------------------------------------------*
LOCAL aCampos := {}, nRec:=RecNo(), nAsterisco:=80
LOCAL aTam:={}, num_campos:=LEN(R_Campos),SpcCol,SpcIni
LOCAL b_pos :={|valor,ind| T_Len[ind+1,2]:=T_Len[ind,2]+T_Len[ind,1]+SpcCol}
LOCAL b_lin :={|valor,ind| F_Ler_Tab(R_Campos,ind)}
LOCAL lRodaPe:=GetNewPar("MV_LOGOREL",.T.)
PRIVATE TotLen:=0, Linha:=99, l_tag:=0, T_Len[num_campos][2]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Linha    := 80
m_pag    := 1

PRIVATE cabec1:=cabec1Loc //AWR 05/11/1998
PRIVATE cabec2:=cabec2Loc //AWR 05/11/1998
PRIVATE MConta:=MContG:=0

AEVAL(R_Campos, b_lin)
Len_Rel:= TotLen+num_campos-1
SpcCol := INT( ( Len_Rel - TotLen ) / (num_campos-1)  )
SpcCol := IF(SpcCol<1,1,SpcCol)
SpcIni := INT( ( Len_Rel - TotLen - SpcCol * ( num_campos - 1 ) ) / 2 )
SpcIni := IF( SpcIni < 1.OR.SpcIni>=2 , 1 , SpcIni )
T_Len[1,2]:=SpcIni
AEVAL(T_Len,b_pos,,num_campos-1)

DO CASE
   CASE Tamanho == "P"  ; nAsterisco:=80
   CASE Tamanho == "M"  ; nAsterisco:=132
   CASE Tamanho == "G"  ; nAsterisco:=220
ENDCASE

DO CASE
   CASE Len_Rel <= 80
        Len_Rel := 80
   CASE Len_Rel > 80 .AND. Len_Rel <= 136
        Len_Rel := 136
   CASE Len_Rel >  136
        Len_Rel := 225
ENDCASE

dbGoTop()
SetRegua(EasyRecCount(Alias()))   // Total de elementos da regua

IF VALTYPE(R_Funcoes) == "A" .AND. LEN(R_Funcoes) > 2
   EVAL(R_Funcoes[3])
ENDIF

DO While !Eof()

    IF lEnd
       @PROW()+1,001 PSAY STR0001 //"CANCELADO PELO OPERADOR"
       Exit
    Endif
 
    If lMarca
       IF R_Funcoes # NIL
          IF ! EVAL(R_Funcoes[1])
             DBSKIP() ; LOOP
          ENDIF
       ENDIF
    EndIf

    IF Linha > 55
       Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,EasyGParam("MV_COMP"))
       If Empty(cabec1) .And. Empty(cabec2)
          @ PROW()+1,T_Len[1,2]-1 PSAY REPLI('*',nAsterisco)
       Endif

       Linha:=PROW()+1 ; l_tag:=say_tit
       AEVAL(R_Campos, b_lin)
       Linha++ ; l_tag:=say_rep
       AEVAL(R_Campos, b_lin)
    Endif

    IncRegua()

    IF R_Funcoes # NIL
       IF ! EVAL(R_Funcoes[1])
          DBSKIP() ; --Linha ; LOOP
       ENDIF
    ENDIF

    Linha++ ; l_tag:=say_det
    AEVAL(R_Campos, b_lin)   ;    DBSKIP()

Enddo

IF R_Funcoes # NIL
   EVAL(R_Funcoes[2])
ENDIF

IF Linha != 80 .AND. lRodaPe
   Linha++
   roda(0,"",tamanho)
Endif
Set Device To Screen
Set Filter To

If aReturn[5] == 1
   Set Printer To
   dbCommit()
   Ourspool(wnrel)
Endif
MS_FLUSH()
DbGoto(nRec)
Return
*----------------------------------------------------------------------------
FUNCTION F_Ler_Tab(R_Campos,lin)
*----------------------------------------------------------------------------
LOCAL  valor, tipo_val, c_len, alinhamento
STATIC savevalor
PRIVATE xVal:=R_Campos[lin,1]

//valor:= IF(l_tag = say_tit, R_Campos[lin,2] , IF(R_Campos[lin,1]<>NIL,IF(,&(R_Campos[lin,1])),' ') )
valor:= IF(l_tag = say_tit, R_Campos[lin,2] , IF(xVal<>NIL,IF(ValType(xVal)#"B",&(xVal),Eval(xVal)),' ') )
savevalor:=IF(TotLen=0," ",savevalor)

IF l_tag = say_det .OR. l_tag = say_tit
   alinhamento:=R_Campos[lin,3]
   DO CASE
      CASE alinhamento = "D"
           valor:=PADL(valor,T_Len[lin,1])
      CASE alinhamento = "C"
           valor:=PADC(valor,T_Len[lin,1])
      OTHERWISE
           valor:=PADR(valor,T_Len[lin,1])
   ENDCASE

   IF l_tag = say_det .AND. AT("*",alinhamento) # 0
      IF valor == savevalor .AND. Linha # 7
         RETURN NIL
      ELSE
         savevalor:=valor
      ENDIF
   ENDIF

   @ Linha,T_Len[lin,2] PSAY valor
   RETURN NIL
ENDIF

IF l_tag = say_rep
   @ Linha,T_Len[lin,2] PSAY REPL("=",T_Len[lin,1])
   RETURN NIL
ENDIF

tipo_val:= VALTYPE(valor)

DO CASE
   CASE tipo_val = "C"
        c_len:=LEN(valor)
   CASE tipo_val = "D"
        // *** CAF 07/04/1999 - Datas com ano de 4 digitos
        IF IsYear4()
           c_len := 10
        Else
           c_len:= 8
        Endif
   CASE tipo_val = "N"
        c_len:= LEN(STR(valor))
   OTHERWISE
        c_len:= 0
ENDCASE

Totlen+= ( T_Len[lin,1]:=MAX( c_len, LEN(R_Campos[lin,2]) ) )

RETURN NIL
*----------------------------------------------------------------------------
FUNCTION TR_RelMed(PCol,PMedia)
*----------------------------------------------------------------------------
LOCAL MLin:=Linha + 2, npos

PMedia:=TRAN(PMedia, '9999')

// R_Campos, T_Len private arrays da funcao relatorio (padrao1e)

//IF (npos:=ASCAN(R_Campos,{|titulo| UPPER(LEFT(titulo[2],5)) = "PRAZO"})) # 0
IF (npos:=ASCAN(R_Campos,{|titulo| UPPER(ALLTRIM(AVSX3("W3_PRAZO",5))) $ UPPER(titulo[2]) })) # 0
   PCol:=T_Len[npos,2]
   PMedia:=IF(R_Campos[npos,3]="D",PADL(PMedia,T_Len[npos,1]),;
           IF(R_Campos[npos,3]="C",PADC(PMedia,T_Len[npos,1]),;
                                   PADR(PMedia,T_Len[npos,1])))
ENDIF

@ MLin,PCol-14 PSAY STR0002 //"Prazo Medio.: "
@ MLin,PCol    PSAY PMedia + STR0003 //" Dias"
RETURN .T.
/*------------------------------------------------------------------------------------
Funcao      : E_GetImp
Parametros  : cImportador => Cod. Importador                         (passado por referência); 
              cTitulo => Titulo                                      (passado por referência);
              cDias => Dias a considerar("Úteis" ou "Não Úteis");    (passado por referência)
              lCbxDias = valor lógico, controla a exibição ou não da escolha dos dias a considerar 
Retorno     : 
Objetivos   : 
Autor       : 
Data/Hora   : 
Revisao     : Nilson César - 01/04/09
Obs.        : Adicionado na data de revisão acima, os 2 últimos parâmetros
              Esta função é usada pelos fontes EICTR250,EICTR260 e EICTR200
*------------------------------------------------------------------------------------*/
*----------------------------------------------------------------------------
Function E_GetImp(cImportador,cTitulo,cDias,lCbxDias)
*----------------------------------------------------------------------------
LOCAL cImport:=CriaVar("YT_COD_IMP"), oDlg, nOpca:=0, lValid:=.F.
LOCAL cArqF3:="SYT", cCampoF3:="YT_COD_IMP"
LOCAL cCadastro:=STR0004//"Seleção de Importador"

LOCAL bValid:={||If(!Empty(cImport) .And. !SYT->(DbSeek(xFilial()+cImport)),;
                 Eval(bNaoExist),If(Empty(cImport),.T.,Eval(bExist))) }

LOCAL bNaoExist := {|| (Help("", 1, "AVG0003007"),.F.)}//"Código do Importador não encontrado" ### "Informação"
LOCAL bExist := {|| IF(SYT->YT_IMP_CON <> "1",MsgInfo(cMessage,"Informação"),),;
                    SYT->YT_IMP_CON == "1" } 

LOCAL cMessage := STR0007//"Registro selecionado é do tipo consignatário"
DEFAULT lCbxDias := .F.        //NCF-11/05/09

DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 23,50 OF oMainWnd

oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 21/07/2015
oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

@ 1.4,0.8  SAY OemToAnsi(STR0008) OF oPanel //"C¢digo"
@ 1.4,10.0  MSGET cImport F3 cArqF3 SIZE 20,10 VALID (lValid:=EVAL(bValid)) ;
           MESSAGE OemToAnsi(STR0009) OF oPanel //"Informe o C¢digo do Importador ou tecle F3"
IF lCbxDias                                                                            //NCF - 11/05/09           
   @ 2.8,0.8   SAY  "Dias a considerar" OF oPanel                                                                                                      
   @ 2.8,10.0  COMBOBOX cDias ITEMS {"Úteis","Não Úteis"} SIZE 30,10 OF oPanel                   
ENDIF 
                                   
ACTIVATE MSDIALOG oDlg ON INIT ;
         EnchoiceBar(oDlg,{||nOpca:=1,If(lValid .OR. EVAL(bValid),;
                             oDlg:End(),)},;
                          {||nOpca:=0,oDlg:End()}) CENTERED
cImportador:=cImport

If nOpca = 0
   Return .F.
Endif

If Empty(cImportador)
   cTitulo:=STR0010//"Geral"
Else
   cTitulo:=STR0011+cImportador//"Import "
Endif

Return .T.
*---------------------------------------------------------------------------
Function E_SayLeadT(cTit,cLeadTime,nPrazoMed,aDados,aRCampos,lMsSelect,aCamposTRB,lPrazo,bFunc)
*---------------------------------------------------------------------------
LOCAL oDlg, oGet
Local oPanel,oButton //LRL 25/03/04
If ValType(nPrazoMed) = "N"
   nPrazoMed:=Padl(nPrazoMed,4,"0")
Endif

IF(lPrazo==NIL,lPrazo:=.T.,)
IF(bFunc==NIL,bFunc:={|| E_Report(aDados,aRCampos)} ,)

oMainWnd:ReadClientCoords()

DEFINE MSDIALOG oDlg TITLE cTit ;
   FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
   OF oMainWnd PIXEL  
@ 00,00  MSPANEL oPanel Prompt "" SIZE 60,16 OF oDlg //LRL 25/03/04 - Painel para Alinamento Mdi 
If cLeadTime # NIL .AND. lPrazo
   @ 4,06  SAY   OemToAnsi(STR0012) SIZE 70,08 OF oPanel PIXEL//"Lead Time"
   @ 2,48  MSGET cLeadTime WHEN .F. SIZE 32,08 OF oPanel PIXEL
   @ 4,80  SAY   OemToAnsi(STR0013) SIZE 70,08 OF oPanel PIXEL//"Prazo M‚dio"
   @ 2,128 MSGET nPrazoMed WHEN .F. SIZE 32,08 OF oPanel PIXEL
Elseif lPrazo
   @ 4,06  SAY  OemToAnsi(STR0013)  SIZE 70,08 OF oPanel PIXEL
   @ 2,48  MSGET nPrazoMed WHEN .F. SIZE 32,10 OF oPanel PIXEL
Endif
   
DEFINE SBUTTON oButton FROM 1,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (EVAL(bFunc)) ENABLE OF oPanel

dbSelectArea("TRB")

IF lMsSelect == NIL
  TRB->(oGet:=MsGetDB():New(35,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2,2,"E_LinOk","E_TudOk","",.F., , ,.T., ,"TRB"))
  oGet:oBrowse:bwhen:={||(dbSelectArea("TRB"),.t.)}
ELSE
  oGet:= MsSelect():New("TRB",,,aCamposTRB,@lInverte,@cMarca,{35,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
ENDIF

TRB->(dbGoTop())
oGet:oBrowse:Refresh()

oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||nOpca:=0,oDlg:End()})) //LRL 25/03/04 -Alinhamento MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

Return NIL

*----------------------------------------------------------------------------
FUNCTION PesquisaClassificacao(PCC,PSI_Num,PCod_I,PPo_Num,PReg)
*----------------------------------------------------------------------------
LOCAL MChave:=MChaveSi:=xFilial("SW1")+PCC+PSI_Num+PCod_I

SW1->(DBSEEK(MChaveSi))

WHILE ! SW1->(EOF()) .AND. MChaveSi = MChave //.AND. SW1->W1_FILIAL == xFilial("SW1")

   IF PPo_Num = SW1->W1_PO_NUM .AND. PReg = SW1->W1_REG
      EXIT
   ENDIF
   SW1->(DBSKIP())
   MChave:= SW1->W1_FILIAL+SW1->W1_CC+SW1->W1_SI_NUM+SW1->W1_COD_I
ENDDo

RETURN BuscaClass(SW1->W1_CLASS)
*-----------------------------*
FUNCTION BuscaClass(PClass,lPrint)
*-----------------------------*
IF(lPrint==NIL,lPrint:=.T.,)
Return If(!Empty(PClass),Tabela('Y1',PClass,lPrint),STR0014) //"Nao Inf."
*----------------------------------------------------------------------------
Function BuscaPart_N(Chave,cForLoj,cFabLoj)
*----------------------------------------------------------------------------
SA5->(DBSETORDER(3))
//TRP - 03/05/10 - Adicionado Tratamento Loja
If(Chave=NIL,Chave:=xFilial("SA5")+Work->WKCOD_I+Work->WKFABR+Work->WKFORN,)
 
//Return (SA5->(DBSEEK(Chave)),SA5->A5_CODPRF)
Return (EICSFabFor(Chave,, cFabLoj, cForLoj), SA5->A5_CODPRF)
*----------------------------------------------------------------------------
FUNCTION E_ItFabFor(cDesc,cProd,cFase)
*----------------------------------------------------------------------------
LOCAL nOrdSYX,nRecSYX
LOCAL lAchou
DEFAULT cFase := ""
lAchou := .F.
If SB1->B1_FILIAL = xFilial() .and. SB1->B1_COD = Work->WKCOD_I
   lAchou := .T.
Else   
   lAchou := SB1->(DBSEEK(xFilial()+ Work->WKCOD_I))
EndIf
If lAchou
   //JVR - 05/01/10 - Novo tratamento para usar outras descrições.
   If cDesc = NIL
      Work->WKDESCR := MSMM( SB1->B1_DESC_GI,AVSX3("B1_VM_GI",3),1 )
   Else  
      If ValType(cDesc) == "C" .and. ValType(cDesc_PO) == "C"//Define como padrão o Ingles caso chamado a função com algum diferente do existente.
         If(!(cDesc_PO $ "I/P/GI"),cDesc := "I",)
      Else
         cDesc := "I"
      EndIf
      Work->WKDESCR := MSMM( &("SB1->B1_DESC_" + cDesc) ,,0 )
   EndIf
   /*Work->WKDESCR := IF(cDesc = NIL ,MSMM( SB1->B1_DESC_GI,36,1 ),;
                                    MSMM( SB1->B1_DESC_I ,AVSX3("B1_VM_I",3),1 ))*/
ENDIF                                   
cProd:= IF(cProd=NIL," ",cProd)
IF AvFlags("SUFRAMA") .AND. !EMPTY(cProd) 
  nOrdSYX := SYX->(INDEXORD())
  nRecSYX := SYX->(RECNO())
  SYX->(DBSETORDER(3))
  SYX->(DBSEEK(xFilial()+cProd+Work->WKCOD_I))
   Work->WKDESCR := IF(cDesc = NIL ,MEMOLINE( SYX->YX_DES_ZFM,36,1 ),;
                                    MEMOLINE( SYX->YX_DES_ZFM ,26,1 ))
  SYX->(DBSETORDER(nOrdSYX))                                  
  SYX->(DBGOTO(nRecSYX))
ENDIF
//MFR 20/09/2019
IF cFase == "PO"
   //DFS - 18/09/2012 - Trocado seek na Work porque se o código do fabricante fosse diferente da loja, a descrição resumida do fabricante ficava em branco.
   If SA2->A2_FILIAL == xFilial() .AND. SA2->A2_COD == Work->WKFABR .AND. SA2->A2_LOJA ==  WORK->W3_FABLOJ
      lAchou := .t.
   Else
      lAchou := SA2->(DBSEEK(xFilial()+ Work->WKFABR+WORK->W3_FABLOJ)) //FSM - 14/07/2011
   EndIf       
   IF lAchou
      Work->WKNOME_FAB := SA2->A2_NREDUZ
   ENDIF

   //DFS - 18/09/2012 - Trocado seek na Work porque se o código do fornecedor fosse diferente da loja, a descrição resumida do Fornecedor ficava em branco.
   If SA2->A2_FILIAL == xFilial() .And. SA2->A2_COD == Work->WKFORN .And. SA2->A2_LOJA == WORK->W3_FORLOJ
      lAchou := .t.
   else
      lAchou := SA2->(DBSEEK(xFilial()+ Work->WKFORN+WORK->W3_FORLOJ)) //FSM - 14/07/2011
   EndIf   
   IF lAchou
      Work->WKNOME_FOR := SA2->A2_NREDUZ
   ENDIF

ELSEIF cFase == "LI"   
   If SA2->A2_FILIAL == xFilial() .And. SA2->A2_COD == Work->WKFABR .And. SA2->A2_LOJA == WORK->W5_FABLOJ
      lAchou := .t.
   Else 
      lAchou := SA2->(DBSEEK(xFilial()+ Work->WKFABR+WORK->W5_FABLOJ))
   EndIF 
   If lAchou 
      Work->WKNOME_FAB := SA2->A2_NREDUZ
   ENDIF

   If SA2->A2_FILIAL == xFilial() .And. SA2->A2_COD == Work->WKFORN .And. SA2->A2_LOJA == WORK->W5_FORLOJ
      lAchou := .t.
   Else
      lAchou := SA2->(DBSEEK(xFilial()+ Work->WKFORN+WORK->W5_FORLOJ))
   EndIf
   If lAchou   
      Work->WKNOME_FOR := SA2->A2_NREDUZ
   ENDIF

ELSEIF cFase == "DI"
   If SA2->A2_FILIAL == xFilial() .And. SA2->A2_COD == Work->WKFABR .And. SA2->A2_LOJA == WORK->W7_FABLOJ
      lAchou := .t.
   Else 
      SA2->(DBSEEK(xFilial()+ Work->WKFABR+WORK->W7_FABLOJ))
   EndIf
   If lAchou 
      Work->WKNOME_FAB := SA2->A2_NREDUZ
   ENDIF

   If SA2->A2_FILIAL == xFilial() .And. SA2->A2_COD == Work->WKFORN .And. SA2->A2_LOJA == WORK->W7_FORLOJ
      lAchou := .t.
   Else 
      lAChou := SA2->(DBSEEK(xFilial()+ Work->WKFORN+WORK->W7_FORLOJ))
   EndIf
   If lAchou   
      Work->WKNOME_FOR := SA2->A2_NREDUZ
   ENDIF

ELSE
   If SA2->A2_FILIAL == xFilial() .And. SA2->A2_COD == Work->WKFABR .And. SA2->A2_LOJA == WORK->WKFABLOJ
      lAchou:=.t.
   Else 
      lAchou := SA2->(DBSEEK(xFilial()+ Work->WKFABR+WORK->WKFABLOJ))
   EndIf   
   IF lAchou
      Work->WKNOME_FAB := SA2->A2_NREDUZ
   ENDIF

   If SA2->A2_FILIAL == xFilial() .And. SA2->A2_COD == Work->WKFORN .And. SA2->A2_LOJA == WORK->WKFORLOJ
      lAchou := .t.
   Else 
      lAchou := SA2->(DBSEEK(xFilial()+ Work->WKFORN+WORK->WKFORLOJ))
   EndIf   
   IF lAchou
      Work->WKNOME_FOR := SA2->A2_NREDUZ
   ENDIF

ENDIF
Return
*----------------------------------------------------------------------------
FUNCTION BuscaAgente( PCodigo )
*----------------------------------------------------------------------------
RETURN ( SY4->( DBSEEK(xFilial()+PCodigo) ), SY4->Y4_NOME )

*----------------------------------------------------------------------------
FUNCTION BuscaDesp( PCodigo )
*----------------------------------------------------------------------------
RETURN ( SY5->( DBSEEK(xFilial()+PCodigo) ), SY5->Y5_NOME )

*----------------------------------------------------------------------------
*----------------------------------------------------------------------------
FUNCTION CalcFob_Us (PPreco_Uni,PQtde,PParidade,nRound)
*----------------------------------------------------------------------------
LOCAL MParidade:=IF(SW2->W2_PARID_U < 0, 1, SW2->W2_PARID_U) , MValor
Default nRound := 2  // GFP - 19/03/2014

IF PParidade # NIL .AND. PParidade # 0
   MParidade := PParidade
ENDIF

IF PQtde # NIL
// MValor = PPreco_Uni * PQtde / MParidade A.W.R. 13/05/98
   MValor := PPreco_Uni * PQtde * MParidade
ELSE
// MValor = PPreco_Uni / MParidade A.W.R. 13/05/98
   MValor := PPreco_Uni * MParidade
ENDIF

IF PParidade # NIL .AND. PParidade = 0
   MValor := 0
ENDIF

IF MValor > 900000000000
   MValor := 999999999999
ENDIF
RETURN ROUND( MValor,nRound)  // GFP - 19/03/2014
*----------------------------------------------------------------------------
*----------------------------------------------------------------------------
FUNCTION BuscaComprador (PComprador)
*----------------------------------------------------------------------------
RETURN IF(SY1->( DBSEEK(xFilial()+PComprador) ) , SY1->Y1_NOME,;
                                                STR0015)//"COMPRADOR NAO CADASTRADO"
*----------------------------------------------------------------------------
FUNCTION BuscaLoc(PLOCAL)
*----------------------------------------------------------------------------
RETURN IF(SY2->( DBSEEK(xFilial()+PLOCAL) ), SY2->Y2_DESC ,;
                                            STR0016)//"LOCAL DE ENTREGA NAO CADASTRADO"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³  MSCOUNT ³ Autor ³ Mario Jorge de Barros ³ Data ³ 16/01/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Contagem de linhas p/ campo MEMO da integracao SIGAEIC/Adv ³±±
±±³          ³ (AVERAGE/MICROSIGA)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MSCOUNT(ExprC1,ExprN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorna Numero de Linhas                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
FUNCTION MSCOUNT(cChave,nTam)
Local nLinhas:=0
nTam:=IF(nTam==Nil,Len(SYP->YP_TEXTO),nTam)
SYP->(DbSeek(xFilial("SYP")+cChave))
SYP->(DbEval({||++nLinhas},,{||cChave==SYP->YP_CHAVE.AND.xFilial("SYP")==SYP->YP_FILIAL}))
Return nLinhas


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Nome_Mes  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 21/02/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Retorno o nome do mes em portugues                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAEIC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION Nome_Mes(PMes)

LOCAL T_Mes:={STR0047,STR0048,STR0049,STR0050,STR0051,STR0052 ,;//'Janeiro'###'Fevereiro'###'Marco'###'Abril'###'Maio'###'Junho'
              STR0053,STR0054,STR0055,STR0056,STR0057,STR0058}//'Julho'###'Agosto'###'Setembro'###'Outubro'###'Novembro'###'Dezembro'

RETURN IF(PMes>0 .AND. PMes<13,T_Mes[PMes],'   ')

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ E_Inclui ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 26/08/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina Principal                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function E_Inclui(cAlias,nReg,nOpc,bInit,bValid,bGrava,bFinal,aButtonBar,aEmbarques, oWindow, cTitulo, aDarGets, bBtnBar,aCposMostra,cAliDet,TB_Campos)   //GFP - 02/03/2013
LOCAL nOpca := 0,lGravaOk := .T.,i
LOCAL oDlg, oGet, bOk, bCancel, lMemo:=NIL,oEnchoice
Local lRet:= .T.

DEFAULT aCposMostra := NIL         //NCF - 25/05/09 - Array com os campos que serão mostrados
DEFAULT cAliDet := "", TB_Campos := {}  // GFP - 05/03/2013

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTela[0][0],aGets[0],nNumLin:=0, MExiste:=.F., lGrava:=.F., aHeader[0]
PRIVATE aBotao:={}

aADD(aBotao,(aButtonBar))

IF nOpc = ALTERACAO .OR. (cAlias='SW2'.and.nOpc=3.and.cProg="PN")
   dbSelectArea(cAlias)
   IF Bof() .AND. Eof()
      Return (.T.)
   EndIf
   FOR i := 1 TO FCount()
       M->&(FIELDNAME(i)) := FieldGet(i)
   NEXT i
   MExiste:=.T.
Else
   MExiste:=.F.
Endif

IF ! EVAL(bInit)
   RETURN .F.
ENDIF

If Type("lPOAuto") == "U"
   lPOAuto:= .F.
EndIf
Do while .T.

   nOpca := 0

   If !lPOAuto
       bOk:={||nOpca:=1,oDlg:End()}
       bCancel:={||oDlg:End()}
       bOkPrv:=bOk
       aGets:={}
       aTela:={}

       DEFINE MSDIALOG oDlg TITLE cTitulo ; 
                FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;//+87
               TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL
   
   If !Empty(cAliDet)   //GFP - 02/03/2013
      nMeio:= INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )
      oEnChoice:=MsMget():New( cAlias, nReg, nOpc, , , ,aCposMostra,{ 15,  1, nMeio+4 , (oDlg:nClientWidth-4)/2 }, aDarGets, 3)
   Else
      oEnChoice:=MsMget():New( cAlias, nReg, nOpc, , , ,aCposMostra,{ 15,  1, (oDlg:nClientHeight-4)/2 , (oDlg:nClientWidth-3)/2 }, aDarGets, 3)
   EndIf
  
//   bButtonArray := {|| AvButtonBar(oDlg,bOk,bCancel,nOpca,,,,,aButtonBar) }
//   bButton      := {|| AvButtonBar(oDlg,bOk,bCancel,nOpca,aButtonBar[1],aButtonBar[2],aButtonBar[3],if(Len(aButtonBar)=4,aButtonBar[4],nil)) } 

   bButtonArray := {|| EnchoiceBar(oDlg,bOk,bCancel,,aButtonBar) }
   bButton      := {|| EnchoiceBar(oDlg,bOk,bCancel,,aBotao) }  
  
   oWindow:=oDlg
   oDlgPrv:=oDlg
   
   If !Empty(cAliDet)   //GFP - 02/03/2013 - Inclusão de grid
      oGet:=MSSELECT():New(cAliDet,NIL,,TB_Campos,lInverte,cMarca,{Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4),1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
      oGet:oBrowse:bWhen:={||DBSELECTAREA(cAliDet),.T.}
      oEnchoice:oBox:Align:=CONTROL_ALIGN_TOP
      oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT       
      oGet:oBrowse:Refresh()	 
   Else   
      oEnchoice:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   EndIf
   oDlg:lMaximized:=.T.
   ACTIVATE MSDIALOG oDlg ON INIT (If(aButtonBar = NIL .OR. Len(aButtonBar)==0, IF(bBtnBar = Nil,;
                                     EnchoiceBar(oDlg,bOk,bCancel), EVAL(bBtnBar) ),;
                                     if(Valtype(aButtonBar[1])=="A",Eval(bButtonArray),Eval(bButton)))) //LRL 18/03/04 Alinhamento na versão MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   If nOpcA == 1                                 
      If Obrigatorio(aGets,aTela) .And. Eval(bValid) .And. Eval(bGrava)
         If __lSX8
            RollBackSX8()
         Endif
      Else
         loop
      ENDIF
   Endif
   EXIT
      Else
         If EnchAuto(cAlias,aCabAuto,{|| Obrigatorio(aGets,aTela) .AND. Eval(bValid) .AND. Eval(bGrava) },nOpcAuto,aCposMostra) 
            nOpcA := 1
            If nOpca == 1
               If __lSX8
                  RollBackSX8()
               Endif
            Endif
         Else
            //loop         //NCF - 16/09/2016 - Nopado - Caso dê algum erro da EnchAuto, não pode ficar em loop (causa loop infinito)
            /* wfs mar/2017 - A função que chamou a gravação, via rotina automática, é que deve executar o MostraErro()
            If lMSErroAuto //NCF - 16/09/2016 - Erro é capturado aqui, na rotina o mesmo fica em branco!
               MostraErro()
            EndIf*/
            nOpca:= 0
            Exit
         EndIf
         EXIT
      Endif 
Enddo

Eval(bFinal)

dbSelectArea(cAlias)


If nOpca == 1
   lRet:= .T.
Else
   lRet:= .F.
Endif

//Return( nOpcA )
Return lRet
*----------------------------------------------------------------------------
FUNCTION ApuNextSeq(cChave,nTam)
*----------------------------------------------------------------------------
LOCAL nSeq:=0, cSeq
IF SX6->(DBSEEK(xfilial()+cChave)) //THTS - 26/07/2017 - Substituido o Reclock que havia no fonte pelo SetMv
   IF VAL(SX6->X6_CONTEUD) == VAL(STR(9,nTam))
      //SX6->X6_CONTEUD:=PADL(nSeq,nTam,'0')
      setMv(cChave,PADL(nSeq,nTam,'0'))
   ENDIF
ENDIF
cSeq:=SX6->X6_CONTEUD

//SX6->X6_CONTEUD:=STRZERO(VAL(cSeq)+1,nTam)
setMv(cChave,STRZERO(VAL(cSeq)+1,nTam))

nSeq:= VAL(SX6->X6_CONTEUD)

RETURN PADL(nSeq,nTam,'0')

*----------------------------------------------------------------------------
FUNCTION PG100Cobertura()
*----------------------------------------------------------------------------
IF SY6->Y6_TIPOCOB     = "1"
   RETU STR0026//"Com Cobertura ate 180 dias       "
ELSEIF SY6->Y6_TIPOCOB = "2"
   RETU STR0027//"Com Cobertura de 181 ate 360 dias"
ELSEIF SY6->Y6_TIPOCOB = "3"
   RETU STR0028//"Com Cobertura ate Acima 360 dias "
ELSEIF SY6->Y6_TIPOCOB = "4"
   RETU STR0029//"Sem Cobertura                    "
ENDIF

RETU SPACE(33)

*----------------------------------------------------------------------------
FUNCTION E_Periodo_OK(PDt_I,PDt_F)
*----------------------------------------------------------------------------
IF EMPTY(PDt_I)
   PDt_I := AVCTOD("01/01/"+Right(Padl(Set(_SET_EPOCH),4,"0"),2))
ENDIF

IF EMPTY(PDt_F)
   PDt_F := AVCTOD("31/12/2999")
ENDIF

IF PDt_F < PDt_I
   Help("", 1, "AVG0003008")//"DATA FINAL MENOR QUE DATA INICIAL"
   RETURN .F.
ENDIF
RETURN .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±±³Fun‡ao    ³ OBS      ³ Autor ³ VICTOR IOTTI          ³ Data ³ 28.11.97 ³±±±
±±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±±³Descri‡„o ³ Escolha da Observacao                                      ³±±±
±±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±±³Sintaxe   ³ AV_ESC_OBS()                                               ³±±±
±±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±±³ Uso      ³ SIGAEIC                                                    ³±±±
±±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------------------------------------------------------------------*
FUNCTION AV_ESC_OBS(cPesq,aObs,nCol,oFont,cMarca)
*----------------------------------------------------------------------------*
LOCAL TB_Campos:={}, cAlias:=ALIAS(), cMens_Filial:=xFilial(), I, oDlgMen, oMarkMen, cMensagem
LOCAL nVolta:=0
LOCAL Struct1:= {  {"WKORDEM","C",05,0} ,;
                   {"WKOBS"  ,"M",10,0} ,;
                   {"WKOBS1" ,"C",50,0} }
LOCAL nOpc ,W 
LOCAL bWhile  //TRP-16/06/08

PRIVATE cMarcaMen := If(cMarca=NIL .or. Empty(cMarca), GetMark(), cMarca)
PRIVATE lInverteMen := .F.
PRIVATE cPO
PRIVATE lSelecionaPO := .T.

Begin Sequence
IF SELECT("Work_Men") = 0
  
   cFileMen := E_CriaTrab(,Struct1,"Work_Men") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

   IF ! USED()
      Help("", 1, "AVG0003009")//"N„o h   rea dispon¡vel para abertura do Cadastro de Work"
      Return .F.
   ENDIF
  IndRegua("Work_Men",cFileMen+TEOrdBagExt(),"WKORDEM")

   DBSELECTAREA("SY7")
   //TRP-16/06/08- Criar tela para seleção do PO que será copiado o modelo de mensagem.
   If(EasyEntryPoint('EICXFUN'),ExecBlock('EICXFUN',.F.,.F.,'SELECIONA_PO'),)// LRS - 27/09/2013 - Ponto de entrada para manipular tela seleção PO

   	If lSelecionaPO  //LRS - 27/09/2013
      	If cModulo == "EIC" .And. SelecionaPo() == 0 //JVR - 28/03/10 - tratamento apenas para modulo EIC.
      		Work_Men->(DbCloseArea())  
      		Break
      	EndIf
	Endif   //LRS - 27/09/2013
	
	
   //TRP-16/06/08
   If Empty(cPO)
      SY7->(DBSETORDER(3))
      SY7->(DBSEEK(xFilial()+cPesq)) 
      bWhile:={||xFilial("SY7")=SY7->Y7_FILIAL .AND. SY7->Y7_POGI = cPesq} 
   Else
      SY7->(DBSETORDER(4))
      SY7->(DBSEEK(xFilial()+cPesq+cPO)) 
      bWhile:={||xFilial("SY7")=SY7->Y7_FILIAL .AND. SY7->Y7_POGI = cPesq .AND. cPO = SY7->Y7_PO_NUM}
   Endif
   
   DO WHILE SY7->(!EOF()) .AND. EVAL(bWhile)
     
      //TRP-17/06/08
      If Empty(cPO) .AND. !EMPTY(SY7->Y7_PO_NUM)
         SY7->(dbSkip())
         LOOP
      ENDIF
         
      SYP->(DBSEEK(xFILIAL()+SY7->Y7_TEXTO))
      cMensagem:=''
      //    DO WHILE ! SYP->(EOF()) .AND. xFilial("SYP")=SYP->YP_FILIAL .AND. SYP->YP_CHAVE=SY7->Y7_TEXTO
      //       cMensagem += ALLTRIM(SYP->YP_TEXTO)+CHR(13)+CHR(10)
      //       SYP->(DBSKIP())
      //    ENDDO
      cMensagem:=MSMM(SY7->Y7_TEXTO,60,,,3)
      Work_Men->(DBAPPEND())
      Work_Men->WKORDEM:='zzzzz'
      Work_Men->WKOBS  :=cMensagem
      Work_Men->WKOBS1 :=MEMOLINE(cMensagem,50)
      If EasyEntryPoint("EICXFUN")//ASR 11/01/2006
         ExecBlock("EICXFUN",.F.,.F.,"GRAVACAO_WORK_MEN")
      Endif
      SY7->(DBSKIP())
   ENDDO
  
   
   IF aObs # Nil .AND. !EMPTY(aObs) .AND. Empty(cPO) 
      FOR I=1 TO LEN(aObs)
         Work_Men->(DBAPPEND())
         IF EMPTY(aObs[I,2])
            Work_Men->WKORDEM:='zzzzz'
         ELSE
            Work_Men->WKORDEM:=STRZERO(aObs[I,2],5)
         ENDIF
         Work_Men->WKOBS  :=aObs[I,1]
         Work_Men->WKOBS1 :=MEMOLINE(aObs[I,1],50)
      NEXT
   ENDIF

   IF WORK_MEN->(Easyreccount("WORK_MEN"))=0

      Work_Men->(DBAPPEND())

   ELSEIF nCol # Nil //AWR 22/06/1999

//    nCol:=nCol-10

      Work_Men->(DBGOTOP())

      DO WHILE !Work_Men->(EOF())

         Work_Men->WKOBS:=RTRIM(STRTRAN(Work_Men->WKOBS,CHR(13)+CHR(10)," "))
         nTotLin:=MLCOUNT(Work_Men->WKOBS,nCol)
         cMemo  :=""

         FOR W := 1 TO nTotLin
            If !EMPTY(MEMOLINE(Work_Men->WKOBS,nCol,W))
               If W == nTotLin
                  cMemo+=MEMOLINE(Work_Men->WKOBS,nCol,W)
               Else
                  cMemo+=AV_Justifica(MEMOLINE(Work_Men->WKOBS,nCol,W))+CHR(13)+CHR(10)
               EndIf
            EndIf
         NEXT



         Work_Men->WKOBS:=cMemo
         Work_Men->(DBSKIP())

      ENDDO

   ENDIF

ENDIF

AADD(TB_Campos,{{||IF(Work_Men->WKORDEM='zzzzz','     ',WKORDEM)} ,"",STR0032})//"Ordem"  // RRV 17/08/2012
AADD(TB_Campos,{{||Work_Men->WKOBS1}                            ,"",STR0033})//"Observacao"

DO WHILE .T.
   nOpc := 0
   DBSELECTAREA("Work_Men")
   DBGOTOP()
   nVolta:=0

   oMainWnd:ReadClientCoors() 
   DEFINE MSDIALOG oDlgMen TITLE STR0034;//"Ordem de Mensagens"
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
          OF oMainWnd PIXEL  

      oMarkMen:=MsSelect():New("Work_Men",,,TB_Campos,@lInverteMen,@cMarcaMen,{15,1,(oDlgMen:nHeight-30)/2,(oDlgMen:nClientWidth-4)/2})
      oMarkMen:bAval:={||nVolta:=1,oDlgMen:End()}

	  oMarkMen:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   ACTIVATE MSDIALOG oDlgMen ON INIT;
         (EnchoiceBar(oDlgMen,{||If( FUNVALORDMSG("WKORDEM","Work_Men") , (nOpc :=1, oDlgMen:End()),MsgInfo(STR0070, STR0068) )},; //"Para continuar é necessário preencher a(s) ordem(ns) da(s) mensagem(ns)" "Aviso" FSY - 10/08/2012
                             {||nOpc :=0, oDlgMen:End()}))//LRL 02/04/04  //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT                 

   IF nVolta=1
      OBSMar(oFont)
      LOOP
   ENDIF
   EXIT
ENDDO

End Sequence
SY7->(DBSETORDER(1))
DBSELECTAREA(cAlias)

IF nOpc = 0
   Return .F.
Else   
   RETURN .T.
Endif   

*----------------------------------------------------------------------------*
FUNCTION ObsMar(oFont)
*----------------------------------------------------------------------------*
LOCAL oDlgObsMar, cOrdem:=Work_Men->WKORDEM
LOCAL nVolta:=0 , mMemo :=Work_Men->WKOBS, oFontMen

IF cOrdem='zzzzz'
   cOrdem='     '
ENDIF

DEFINE MSDIALOG oDlgObsMar TITLE STR0034 From 7,0.5 TO 26,79.5 OF oMainWnd

  IF(oFont#NIL,oDlgObsMar:SetFont(oFont),)

  @ 05,05 SAY STR0032       SIZE  30,10 OF oDlgObsMar PIXEL
  @ 04,29 MSGET cOrdem      SIZE  35,10 OF oDlgObsMar PIXEL
  @ 21,05 GET mMemo MEMO    SIZE 300,115 OF oDlgObsMar PIXEL //HSCROLL

  DEFINE SBUTTON FROM 04,240 TYPE 1 ACTION (nVolta:=1,oDlgObsMar:End()) ENABLE OF oDlgObsMar PIXEL
  DEFINE SBUTTON FROM 04,270 TYPE 2 ACTION (oDlgObsMar:End()) ENABLE OF oDlgObsMar PIXEL


ACTIVATE MSDIALOG oDlgObsMar CENTERED

IF nVolta=1
   IF EMPTY(cOrdem)
      Work_Men->WKORDEM:='zzzzz'
   ELSE
      Work_Men->WKORDEM:=cOrdem
   ENDIF
   Work_Men->WKOBS:=mMemo
   Work_Men->WKOBS1:=MEMOLINE(mMemo,50)
ENDIF

RETURN NIL

*-------------------------------------------------------*
FUNCTION PrintCab(oPrn,cSubject,nPag,Linha,idioma,cProg)
*-------------------------------------------------------*
#DEFINE INGLES    1
#DEFINE PORTUGUES 2

#xtranslate :TIMES_NEW_ROMAN_12            => \[1\]
#xtranslate :COURIER                       => \[2\]
#xtranslate :TIMES_NEW_ROMAN_14_BOLD       => \[3\]
#xtranslate :TIMES_NEW_ROMAN_14_UNDERLINE  => \[4\]
#xtranslate :TIMES_NEW_ROMAN_12_UNDERLINE  => \[5\]
#xtranslate :TIMES_NEW_ROMAN_12_BOLD       => \[6\]
#xtranslate :TIMES_NEW_ROMAN_18_BOLD       => \[7\]



LOCAL oFont1, oFont2, oFont3, oFont4, oFont5, oFont6, oFont7, aFontes
LOCAL cEmp,cEmp_End,cEmp_Cid,cEmp_Est,cEmp_CEP,cEmp_Emp

LOCAL cEmp_Tel := ALLTRIM(SY1->Y1_TEL)
LOCAL cEmp_Fax := ALLTRIM(SY1->Y1_FAX)
LOCAL cEmp_Fax2:= IF(EMPTY(SA2->A2_REPRES),SA2->A2_FAX,SA2->A2_REPRFAX)
***LOCAL cEmp2    := LEFT(SYT->YT_NOME,19)
***LOCAL cEmp2    := SYT->YT_NOME    // by RS
LOCAL cEmp2    := SYT->YT_NOME_RE    // by RS
//LOCAL cDepart  := "IMPORT DEPT."
LOCAL cDepart
LOCAL cNome    := LEFT(SY1->Y1_NOME,30)
LOCAL cPara    := LEFT(IF(EMPTY(SA2->A2_REPRES),SA2->A2_NOME,SA2->A2_REPRES),27)
***LOCAL cDivisao := LEFT(SA2->A2_DEPTO,17)
LOCAL cDivisao := LEFT(SA2->A2_DEPTO,25)
LOCAL cNome2   := LEFT(IF(EMPTY(SA2->A2_REPRES),SA2->A2_CONTATO,SA2->A2_REPCONT),30)
LOCAL  oFontAnt, nColFim:=2315
LOCAL  nCol1:=1550

IF(cProg==NIL,cProg:="",)

cDepart:=IF(idioma==NIL .OR. idioma==INGLES,EasyGParam("MV_DEPTO_I"),EasyGParam("MV_DEPTO_P"))
cDepart:=LEFT(cDepart,25)
IF EasyGParam("MV_ID_EMPR") $ cSim
   cEmp     := ALLTRIM(SM0->M0_NOME)
   cEmp_End := ALLTRIM(SM0->M0_ENDCOB)
   cEmp_Cid := ALLTRIM(SM0->M0_CIDCOB)
   cEmp_Est := ALLTRIM(SM0->M0_ESTCOB)
   cEmp_CEP := TRANS(ALLTRIM(SM0->M0_CEPCOB),"@R 99999-999")
ELSE
   cEmp     := ALLTRIM(SYT->YT_NOME)
   cEmp_End := ALLTRIM(SYT->YT_ENDE)
   cEmp_Cid := ALLTRIM(SYT->YT_CIDADE)
   cEmp_Est := ALLTRIM(SYT->YT_ESTADO)
   cEmp_CEP := TRANS(ALLTRIM(SYT->YT_CEP),"@R 99999-999")
ENDIF
cEmp_Emp := cEmp_Cid+" - "+cEmp_Est+" - "+cEmp_CEP

nPag:=IF(VALTYPE(nPag)="N",PADL(nPag,3,"0"),nPag)

DEFINE FONT oFont1  NAME "Times New Roman"    SIZE 0,12                  OF oPrn
DEFINE FONT oFont2  NAME "Courier"            SIZE 0,10                  OF oPrn
DEFINE FONT oFont3  NAME "Times New Roman"    SIZE 0,14  BOLD            OF oPrn
DEFINE FONT oFont4  NAME "Times New Roman"    SIZE 0,14  BOLD UNDERLINE  OF oPrn
DEFINE FONT oFont5  NAME "Times New Roman"    SIZE 0,12       UNDERLINE  OF oPrn
DEFINE FONT oFont6  NAME "Times New Roman"    SIZE 0,12  BOLD            OF oPrn
DEFINE FONT oFont7  NAME "Times New Roman"    SIZE 0,18  BOLD            OF oPrn

aFontes := { oFont1, oFont2, oFont3, oFont4, oFont5, oFont6, oFont7 }
Linha   := 100

If EasyEntryPoint("EICXFUN")
   ExecBlock("EICXFUN",.F.,.F.,"LOGOTIPO")
Endif

oFontAnt   := oPrn:oFont
oPrn:oFont := aFontes:TIMES_NEW_ROMAN_12

oPrn:Say( Linha+=20 , 1240 , cEmp     , aFontes:TIMES_NEW_ROMAN_18_BOLD,,,,2 )
oPrn:Say( Linha+=70 , 1240 , cEmp_End , aFontes:TIMES_NEW_ROMAN_14_BOLD,,,,2 )
oPrn:Say( Linha+=70 , 1240 , cEmp_Emp , aFontes:TIMES_NEW_ROMAN_14_BOLD,,,,2 )
oPrn:Say( Linha+=70 , 1240 , cEmp_Tel  + " / " + cEmp_Fax , aFontes:TIMES_NEW_ROMAN_14_BOLD,,,,2 )
oPrn:Say( Linha+=70 , 1240 , ""   , aFontes:TIMES_NEW_ROMAN_14_BOLD,,,,2 )

//oPrn:Box( Linha+=120, 110  , Linha+150, 111 )
//oPrn:Box( Linha     , 800  , Linha+150, 801 )
oPrn:Box( Linha+150 , 110  , Linha+151, 800 )
oPrn:Box( Linha     , 860  , Linha+150, 861 )
oPrn:Box( Linha     , 1160 , Linha+150, 1161)
oPrn:Box( Linha+150 , 860  , Linha+151, 1160)
oPrn:Box( Linha     , 1220 , Linha+150, 1221)
oPrn:Box( Linha     , 1910 , Linha+150, 1911)
oPrn:Box( Linha+150 , 1220 , Linha+151, 1910)
oPrn:Box( Linha     , 1970 , Linha+150, 1971)
oPrn:Box( Linha     , nColFim , Linha+150,nColFim+1)
oPrn:Box( Linha+150 , 1970 , Linha+151, nColFim)

oPrn:Say( Linha     , 910  , STR0059           ,aFontes:TIMES_NEW_ROMAN_12_BOLD )//"Data/Date"
oPrn:Say( Linha     , 1240 , STR0060           ,aFontes:TIMES_NEW_ROMAN_12_BOLD )//"Fax"
oPrn:Say( Linha     , 1990 , "Page"            ,aFontes:TIMES_NEW_ROMAN_12_BOLD )//"Pages (including" //FSY - 06/09/2013 - Alterado, pois nao é possivel calcular tatol de paginas.

Linha+= 55

oPrn:Say( Linha     , 920  , DTOC(dDataBase) ,aFontes:COURIER )
oPrn:Say( Linha     , 1250 , cEmp_Fax2  ,aFontes:COURIER )
//oPrn:Say( Linha     , 1990 , "this one)",aFontes:TIMES_NEW_ROMAN_12_BOLD )FSY - 06/09/2013 -  Alterado, pois nao é possivel calcular tatol de paginas.

oPrn:Say( Linha+=50 , 2225 , nPag,aFontes:COURIER ) //2260

IF EasyEntryPoint("IC195XF1") .AND. (cProg="EICPO552" .OR. cProg="EICPO556")
   // Rdmake para Klabin
   Private cEmp2Aux  :=cEmp2
   Private cDepartAux:=cDepart
   Private aFnt      :=aFontes
   ExecBlock("IC195XF1",.F.,.F.,Linha)
Else

   oPrn:Box( Linha+=50 , 800  , Linha+150, 801 )
   oPrn:Box( Linha+150 , 110  , Linha+151, 800 )
   oPrn:Box( Linha     , 1500 , Linha+150, 1501)
   oPrn:Box( Linha+150 , 860  , Linha+151, 1500)
   oPrn:Box( Linha     , nColFim , Linha+150,nColFim+1)
   oPrn:Box( Linha+150 , 1560 , Linha+151, nColFim)

   oPrn:Say( Linha+=50 , 120  , STR0062 ,aFontes:TIMES_NEW_ROMAN_12_BOLD )//"De/From"              
   oPrn:Say( Linha     , 880  , STR0063 ,aFontes:TIMES_NEW_ROMAN_12_BOLD )//"Departamento/Division"
   oPrn:Say( Linha     , nCol1 ,STR0064 ,aFontes:TIMES_NEW_ROMAN_12_BOLD )//"Nome/Name"            

   oPrn:Say( Linha+=50 , 120  , cEmp2  ,aFontes:COURIER )
   oPrn:Say( Linha     , 880  , cDepart,aFontes:COURIER )
   oPrn:Say( Linha     , nCol1, cNome  ,aFontes:COURIER )

EndIf

Linha+=70

oPrn:Box( Linha+=10 , 800  , Linha+150, 801 )
oPrn:Box( Linha+150 , 110  , Linha+151, 800 )
oPrn:Box( Linha     , 1500 , Linha+150, 1501)
oPrn:Box( Linha+150 , 860  , Linha+151, 1500)
oPrn:Box( Linha     , nColFim , Linha+150, nColFim+1)
oPrn:Box( Linha+150 , 1560 , Linha+151, nColFim)

oPrn:Say( Linha+=30 , 120  , STR0065  ,aFontes:TIMES_NEW_ROMAN_12_BOLD )//"Para/To"
oPrn:Say( Linha     , 880  , STR0063  ,aFontes:TIMES_NEW_ROMAN_12_BOLD )//"Departamento/Division"
oPrn:Say( Linha     , nCol1 ,STR0064  ,aFontes:TIMES_NEW_ROMAN_12_BOLD )//"Nome/Name"

oPrn:Say( Linha+=50 , 120  , cPara   ,aFontes:COURIER )
oPrn:Say( Linha     , 880  , cDivisao,aFontes:COURIER )
oPrn:Say( Linha     , nCol1 , cNome2  ,aFontes:COURIER )

oPrn:Box( Linha+=120, 110  , Linha+110, 111 )
oPrn:Box( Linha     , nColFim , Linha+110, nColFim+1)
oPrn:Box( Linha+110 , 110  , Linha+111, nColFim)

oPrn:Say( Linha     , 130  , STR0066,aFontes:TIMES_NEW_ROMAN_12_BOLD )//"Assunto/Subject: "
oPrn:Say( Linha+=010, 500  , "OUR ORDER / "+cSubject   ,aFontes:COURIER )//280

oPrn:oFont := oFontAnt

oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()
oFont5:End()
oFont6:End()
oFont7:End()

RETURN NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ E_TrocaVP³ Autor ³ Victor Iotti          ³ Data ³ 13.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Troca vigulas por pontos decimais. (padrao americano)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ E_TrocaVP(nIdioma,cPict)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nIdioma : 1 (Ingles) / 2 (Portugues)                       ³±±
±±³          ³ cPict   : Picture do Campo                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorna String contendo a Pict do campo passado sem @E     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION E_TrocaVP(nIdioma,cPict)

RETURN IF(nIdioma=1,ALLTRIM(STRTRAN(cPict,'@E','')),cPict)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ TabFre        ³ Autor    ³ Victor Iotti   ³ Data ³ 04/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³CoAutor   ³ Cristiano Ferreira                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Tabela de Frete                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*---------------------------------------------------------------------------
Function TabFre( nPeso,lAgente )
*---------------------------------------------------------------------------
LOCAL nRetorno := 0

DEFAULT lAgente := .F.

BEGIN SEQUENCE

   IF !lAgente
    
      DO CASE
         CASE SYR->YR_KILO1 >= nPeso
              nRetorno := nPeso  * SYR->YR_VALOR1
         CASE SYR->YR_KILO2 >= nPeso
              nRetorno := nPeso  * SYR->YR_VALOR2
         CASE SYR->YR_KILO3 >= nPeso
              nRetorno := nPeso  * SYR->YR_VALOR3
         CASE SYR->YR_KILO4 >= nPeso
              nRetorno := nPeso  * SYR->YR_VALOR4
         CASE SYR->YR_KILO5 >= nPeso
              nRetorno := nPeso  * SYR->YR_VALOR5
      OTHERWISE  // SYR->YR_KILO6
              nRetorno := nPeso  * SYR->YR_VALOR6
      ENDCASE
      
      nRetorno := IF(nRetorno < SYR->YR_VL_MIN, SYR->YR_VL_MIN, nRetorno)

   ELSE
      
      DO CASE
         CASE EX3->EX3_KILO1 >= nPeso
              nRetorno := nPeso  * EX3->EX3_VALOR1
         CASE EX3->EX3_KILO2 >= nPeso
              nRetorno := nPeso  * EX3->EX3_VALOR2
         CASE EX3->EX3_KILO3 >= nPeso
              nRetorno := nPeso  * EX3->EX3_VALOR3
         CASE EX3->EX3_KILO4 >= nPeso
              nRetorno := nPeso  * EX3->EX3_VALOR4
         CASE EX3->EX3_KILO5 >= nPeso
              nRetorno := nPeso  * EX3->EX3_VALOR5
      OTHERWISE  // EX3->EX3_KILO6
              nRetorno := nPeso  * EX3->EX3_VALOR6
      ENDCASE
      
      nRetorno := IF(nRetorno < EX3->EX3_VL_MIN, EX3->EX3_VL_MIN, nRetorno)

   ENDIF

END SEQUENCE

Return ( nRetorno )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ AvCombo ³ Autor ³ Luiz Claudio Barbosa    ³ Data ³ 25.10.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Retorna a descrição do combo box conforme SX3               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AvCombo(cCampo, cOpc)
Local cCombo := ""
SX3->(dbSetOrder(2))
If SX3->(dbSeek(cCampo))
                        cCombo := SX3->X3_CBOX
                        cCombo := Substr(cCombo, At(cOpc+"=",cCombo)+2, Len(cCombo))
                        nPosFim:= If(At("=",cCombo)<= 0, Len(cCombo), At("=",cCombo)-3)
                        cCombo := Substr(cCombo, 1, nPosFim)
EndIf

SX3->(dbSetOrder(1))
Return(cCombo)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ W5_PESO³ Autor ³ Regina Helena Perez     ³ Data ³ 24.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ RETORNA O PESO CORRETO , CASO ESTE TENHA SIDO MODIFICADO EM SW5³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*--------------------------------*
FUNCTION W5Peso()
*--------------------------------*
LOCAL cAreaAtual:=ALIAS()

IF !EMPTY(SW7->W7_PESO)
   If EasyGParam("MV_EIC0041",,1) == 1  // GFP - 05/02/2014
      nPesoItem := SW7->W7_PESO
   Else
      nPesoItem := Posicione("SA5",2,xFilial("SA5")+SW7->W7_COD_I+SW7->W7_FORN+SW7->W7_FORLOJ,"A5_PESO")
   EndIf
ELSE
  nPesoItem := B1Peso(SW7->W7_CC,SW7->W7_SI_NUM,SW7->W7_COD_I,SW7->W7_REG,SW7->W7_FABR,SW7->W7_FORN) // RA - 11/11/2003 - O.S. 1194/03 | 12/01/2004 - O.S. 0037/04 //Antes SB1->B1_PESO
  nRECSW5 := SW5->(RECNO())
  nOrdSW5 := SW5->(INDEXORD())
  SW5->(DBSETORDER(1))
  // PosOrd1_It_Guias(SW7->W7_PGI_NUM,SW7->W7_CC,SW7->W7_SI_NUM,SW7->W7_COD_I,SW7->W7_FABR,SW7->W7_FORN,SW7->W7_REG,0)
  If PosOrd1_It_Guias(SW7->W7_PGI_NUM,SW7->W7_CC,SW7->W7_SI_NUM,SW7->W7_COD_I,SW7->W7_FABR,SW7->W7_FORN,SW7->W7_REG,0,SW7->W7_PO_NUM) // RA - 11/11/2003 - O.S. 1194/03 // LDR 07/04/2004
     IF !EMPTY(SW5->W5_PESO)
        nPesoitem :=SW5->W5_PESO
     ENDIF
  EndIf // RA - 11/11/2003 - O.S. 1194/03  
  SW5->(DBSETORDER(nOrdSW5))
  SW5->(DBGOTO(nRecSW5))
  DBSELECTAREA(cAreaAtual)
ENDIF
RETURN nPesoItem
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³Busca_NCM Autor ³ Regina Helena Perez     ³ Data ³ 24.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Retorna a NCM correta para o item , esta ncm inicialmente colocada em
±±³ SB1 pode ser modificada no pedido, vinda da lista de engenharia, caso a
±±³ LI seja de um produto Suframa, ou modificada diretamente na LI . O fato ±± 
±±³ é que se a ncm não estiver correta, as aliquotas da nota fiscal poderão ficar 
±±³ errada 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Parametros : 
±±³ cAlias : Alias do arquivo de detalhe em que se encontra a fase do processo e 
±±³          o código do Item : SW3, SW5 ou SW7
±±³ cRetorno : Nome do campo que se quer ter de retorno  : NCM,EX_NCM ou EX_NBM, caso
±±³            cRetorno seja nil, o retorno da função será a soma dos 3 campos
±±³ lPN     : Indica se a origem da chamada pertence a um pedido de nacionalização,
±±³           já que, nesta fase, a ncm correta é a da PLI anterior se esta existir   
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*-----------------------------------------------------------*
FUNCTION Busca_NCM(cAlias,cRetorno,lNaoCarregaSB1,lRetArray)      
*-----------------------------------------------------------*
//LOCAL nSelect := SELECT()
//LOCAL nRecAlias := RECNO()
LOCAL nRecSW5 := SW5->(RECNO()), nOrdSW5:=SW5->(INDEXORD())
LOCAL nRecSW7 := SW7->(RECNO()), nOrdSW7:=SW7->(INDEXORD())
LOCAL nRecSW3 := SW3->(RECNO()), nOrdSW3:=SW3->(INDEXORD())
LOCAL cNCM    := AvKey("","YD_TEC")
LOCAL cEx_NCM := AvKey("","YD_EX_NCM")
LOCAL cEx_NBM := AvKey("","YD_EX_NBM")
LOCAL cNomecampo := SUBST(cAlias,2,2)

DEFAULT lNaoCarregaSB1 := .F.  //TRP-06/11/2007 - Define se a NCM será carregada com dados do SB1.
DEFAULT lRetArray := .F.
cChaveCampo := (cAlias)->&(cNomeCampo+"_COD_I")
cFluxo := (cAlias)->&(cNomeCampo+"_FLUXO")
cRetorno := IF( cRetorno == NIL ,SPACE(10) , cRetorno)

IF cAlias == "SW7" .AND. !EMPTY(SW7->W7_NCM)
  cNCM := SW7->W7_NCM 
  cEx_NCM := SW7->W7_EX_NCM
  cEx_NBM := SW7->W7_EX_NBM
ELSE
  IF  cAlias # "SW3" .AND. cFluxo == "1"
    IF cAlias == "SW7"
      SW5->(DBSETORDER(8))
      SW5->(DBSEEK(xFilial("SW5") + SW7->W7_PGI_NUM+SW7->W7_PO_NUM+SW7->W7_POSICAO))
    ENDIF
    SWP->(DBSEEK(xFilial("SWP")+ (cALias)->&(cNomeCampo+"_PGI_NUM")+(cALias)->&(cNomeCampo+"_SEQ_LI")))
    cNCM := SWP->WP_NCM + SPACE(2)
    cEx_NCM := SW5->W5_EX_NCM
    cEx_NBM := SW5->W5_EX_NBM
  ELSE
    IF cAlias # "SW3"
      SW3->(DBSETORDER(8))
      SW3->(DBSEEK(xFilial("SW3") + (cAlias)->&(cNomeCampo+"_PO_NUM")+(cAlias)->&(cNomeCampo+"_POSICAO")))
    ENDIF                  
    IF ! EMPTY(SW3->W3_TEC )
      cNCM := SW3->W3_TEC
      cEx_NCM := SW3->W3_EX_NCM
      cEx_NBM := SW3->W3_EX_NBM
   ENDIF
 ENDIF
ENDIF

//MFR 16/09/2021 OSSME-6184 melhoria de performance
IF !lNaoCarregaSB1 .And. Empty(cNCM)
   SB1->(DBSEEK(xFilial("SB1")+cCHavecampo))
   cNCM := SB1->B1_POSIPI
   cEx_NCM := SB1->B1_EX_NCM
   cEx_NBM := SB1->B1_EX_NBM
ENDIF

DO CASE 
 CASE cRetorno == "NCM" 
   cRet := cNCM
 CASE cRetorno == "EX_NCM"
   cRet := cEx_NCM
 CASE cRetorno == "EX_NBM"
   cRet := cEx_NBM
 OTHERWISE 
   cRet := cNCM+cEx_NCM+cEx_NBM
ENDCASE   

SW5->(DBSETORDER(nOrdSW5))
SW5->(DBGOTO(nRecSW5))
SW7->(DBSETORDER(nOrdSW7))
SW7->(DBGOTO(nRecSW7))
SW3->(DBSETORDER(nOrdSW3))
SW3->(DBGOTO(nRecSW3))
//DBSELECTAREA(nSelect)
//DBGOTO(nRecAlias)

RETURN If(!lRetArray, cRet , { cNCM , cEx_NCM , cEx_NBM } ) 

//TRP-16/06/08- Função para Seleção do PO no relatório de Shipping Instructions.
*------------------------------*
Static Function SelecionaPo()
*------------------------------* 
Local oDlg
Local _PictPO := ALLTRIM(X3PICTURE("W2_PO_NUM"))
Local bOk , bCancel
Local nOpc := 1 
Local cCons :=  "SW2" //FSY 14/08/2012

SXB->(DbSetOrder(1))
If SXB->(DbSeek("SY71"))
   cCons := "SY71"
EndIf

bOk:= {|| oDlg:End()}
bCancel := {|| If(MsgYesNo(STR0067,STR0068), , nOpc := 0 ),oDlg:End()} //"Deseja visualisar as mensagens padrão ?" //"AVISO"

DEFINE MSDIALOG oDlg TITLE STR0072 From 9,0 To 20,45 OF oMainWnd //"Seleciona PO para o modelo" FSY 17/08/2012
   
   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 17/07/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
   
   cPO := Space(15)
   
   @ 18,30 SAY "PO" SIZE 10,08 PIXEL OF oPanel //"PO"
   @ 18,123 SAY "(F3-Help)" SIZE 25,08 OF oPanel PIXEL //'(F3-Help)'  
   
   @ 18,43 MSGET cPO  SIZE 60,08 PICTURE _PictPO F3 cCons VALID ValidaPO() OF oPanel PIXEL //FSY 14/08/2012      

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

RETURN nOpc

//TRP-16/06/08- Função para validar o PO selecionado no relatório Shipping Instructions.
*-------------------------------*
Static Function ValidaPO()
*-------------------------------*
SY7->(DbSetOrder(4))

IF !EMPTY(cPO)
   IF !EXISTCPO("SW2",cPO)
      RETURN .F.
   ENDIF

   IF !SY7->(DBSEEK(xFilial()+'8'+AvKey(cPO,"W2_PO_NUM")))
      MsgAlert(STR0071)//"Não há mensagens para este PO!"
      cPO:= Space(15)
      RETURN .F.
   ENDIF
ENDIF

RETURN .T.

/*
Funcao      : FUNVALORDMSG
Parametros  : cCampo: nome do campo ou textbox, cAlias: nome da tabela
Retorno     : Logico
Objetivos   : Validação para nao incluir vazio no campo. 
Autores     : Fabio Satoru Yamamoto - FSY
Data/Hora   : 17/08/2012 
Revisao     : 
*/
Function FUNVALORDMSG(cCampo, cAlias)
Local lRet := .T.
Local nOldRec := 0
Default cAlias := ""

If !Empty(cPo)

   If UPPER(cAlias) == "WORK_MEN"
      nOldRec := (cAlias)-> (RecNo())
      (cAlias)->(dbGoTop())
      Do While !(cAlias)->(EOF())
         If Empty((cAlias)->&(cCampo)) .Or. UPPER((cAlias)->&(cCampo)) == 'ZZZZZ'
            lRet :=  .F.
         EndIf
         (cAlias)->(DbSkip())
      EndDo
     (cAlias)->(DBGoTo(nOldRec))
     
   Else
      lRet := !Empty(cCampo)
   EndIf
End If
Return lRet

*--------------------------------------------------------------------------*
*    FIM DO PROGRAMA EICXFUN.PRW                                           *
*--------------------------------------------------------------------------*
