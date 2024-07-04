#include "PLSMGER.CH"
#include "PLSMLIB.CH"

#IFDEF TOP
       #include "TOPCONN.CH"
#ENDIF       

#include "PROTHEUS.CH"
#include "COLORS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLVLDCOLS ³ Autor ³ Tulio Cesar          ³ Data ³29.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Valida mesma chave em um aCols.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GetDados.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cDado   - Novo dado a ser inserido.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLVLDCOLS(cDado,aDados,aCabec,nLin)
LOCAL nInd
LOCAL lFlag   := .T.
LOCAL nColuna

DEFAULT aCabec := aHeader                  
DEFAULT aDados := aCols  
DEFAULT nLin   := n

nColuna := Ascan(aCabec,{|a| a[2] $ AllTrim(SX3->X3_CAMPO)})

For nInd := 1 To Len(aDados)
    If aDados[nInd,nColuna] == cDado .And. nLin <> nInd
       lFlag := .F.
    Endif
Next                

If ! lFlag
   Help(" ",1,"PLVLDCOLS")
Endif

Return(lFlag)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLINITCols ³ Autor ³ Tulio Cesar         ³ Data ³ 15.02.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Trata inicializadores padroes de campos no aCols           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLInitCols()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Cadastrado no Alias BF5.                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function PLInitCols(aCls,aHdr,oBrowse,nOpc)
LOCAL cBlock     
LOCAL nHeader
LOCAL cCampo,n

PRIVATE aHeader := aHdr
PRIVATE aCols   := aCls            

DEFAULT nOpc := nOpcx

If Select("BF5") > 0

   If nOpc <> K_Incluir

      For n := 1 To Len(aCols)
         For nHeader := 1 To Len(aHeader)
             BF5->(DbSetOrder(1))
             If BF5->(MsSeek(AllTrim(aHeader[nHeader,2])))
                cBlock   := AllTrim(BF5->BF5_BLOCK1)+AllTrim(BF5->BF5_BLOCK2)+AllTrim(BF5->BF5_BLOCK3)+AllTrim(BF5->BF5_BLOCK4)+AllTrim(BF5->BF5_BLOCK5)
                aCols[n,nHeader] := &cBlock
              Endif                    
         Next              
      Next
   
      If ValType(oBrowse) <> "U" 
         oBrowse:Atualiza()
      Endif   
      n := 1
 
   Endif
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ HGetDados    ³ Autor ³ Tulio Cesar       ³ Data ³ 27.03.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³                                                            ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HGetDados(oGet)
oGet:Hide()
oGet:oBrowse:Hide()
oGet:oBrowse:lDisablePaint:=.T.
Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ SGetDados    ³ Autor ³ Tulio Cesar       ³ Data ³ 27.03.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³                                                            ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SGetDados(oGet)
oGet:Show()
oGet:oBrowse:Show()
oGet:oBrowse:lDisablePaint:=.F.   
oGet:oBrowse:SetFocus()
Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLDesItem    ³ Autor ³ Tulio Cesar       ³ Data ³ 26.04.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna a descricao de um item AMB ou ESP                  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLDesItem(cCodProc)
LOCAL nOrdem  
LOCAL cDesc   := ""

nOrdem := BA8->(IndexOrd())
BA8->(DbSetOrder(1))
If BA8->(MsSeek(xFilial("BA8")+AllTrim(cCodProc)))
   cDesc := BA8->BA8_DESCRI
Endif                        
BA8->(DbSetOrder(nOrdem))
  
Return(cDesc)   
   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLDesCod     ³ Autor ³ Tulio Cesar       ³ Data ³ 26.04.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna o codigo do procedimento com mascara...            ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLDesCod(cCodProc)
Return(TransForm(cCodProc,"@R !!.!!.!!!-!!!"))
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLAcerFil    ³ Autor ³ Tulio Cesar       ³ Data ³ 26.04.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Acerta filtro montado pelo SetPrint...                     ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                  
Function PLAcerFil(cExp)

cExp := StrTran(Upper(cExp),"DTOS","")

Return(cExp)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLRetTAB     ³ Autor ³ Tulio Cesar       ³ Data ³ 26.04.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna a tabela de precos de um cred. em uma localidade   ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                  
Function PLRetTAB(cCodCre,cCodLoc,cOrdem)
LOCAL nOrdBB8  := BB8->(IndexOrd())
LOCAL cRetorno := "" 

BB8->(DbSetOrder(1))
If BB8->(MsSeek(xFilial("BB8")+cCodCre+cCodLoc+cOrdem)) 
   cRetorno := BB8->BB8_CODTAB
Endif

BB8->(DbSetOrder(nOrdBB8))

Return(cRetorno)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLRetORI     ³ Autor ³ Tulio Cesar       ³ Data ³ 26.04.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna a origem de atendimento de uma localidade          ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                  
Function PLRetORI(cCodLoc)
LOCAL nOrdBD1  := BD1->(IndexOrd())
LOCAL cRetorno := "" 

BD1->(DbSetOrder(1))
If BD1->(MsSeek(xFilial("BD1")+cCodLoc)) 
   cRetorno := BD1->BD1_CODORI
Endif

BD1->(DbSetOrder(nOrdBD1))

Return(cRetorno)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLRetFil     ³ Autor ³ Tulio Cesar       ³ Data ³ 26.04.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna a quantidade de filme...                           ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                  
Function PLRetFIL(cCodProc)
LOCAL nRet := 0

BD4->(DbSetOrder(1))
If BD4->(MsSeek(xFilial("BD4")+cCodProc))
   While ! BD4->(Eof()) .And. AllTrim(BD4->BD4_CODAMB) == AllTrim(cCodProc)
         If Subs(BD4->BD4_CODIGO,1,3) == "FIL"
            nRet := BD4->BD4_VALREF
            Exit
         Endif   
   BD4->(DbSkip())
   Enddo
Endif   

Return(nRet)



Function PLRETTIT(cMatric)       
LOCAL cNomeTit
LOCAL nOrdBA1 := BA1->(IndexOrd())
LOCAL nRecBA1 := BA1->(Recno())

BA1->(DbSetOrder(2))

If BA1->(MsSeek(xFilial("BA1")+cMatric))
   cNomeTit := BA1->BA1_NOMUSR
Else
   cNomeTit := Space(Len(BA1->BA1_NOMUSR))
Endif   

BA1->(DbGoTo(nRecBA1))
BA1->(DbSetOrder(nOrdBA1))

Return(cNomeTit)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLNOVIMP ³ Autor ³ Tulio Cesar           ³ Data ³ 23.05.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Mensagem de nova implementacao do produto plano de saude   ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLNOVIMP()

MsgStop("Disponivel em futuras atualizacoes")

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLNUMAUT ³ Autor ³ Tulio Cesar           ³ Data ³ 29.05.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna o numero da proxima autorizacao.                   ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLNUMAUT(cOpeMov,cAno,cMes,cFiltro)
LOCAL nH			:= 0
LOCAL cNum		:= ""
LOCAL lFiltrar	:= .f.
LOCAL cNumBEA 	:= StrZero(1,Len(BEA->BEA_NUMAUT))
LOCAL cNumB44 	:= StrZero(1,Len(BEA->BEA_NUMAUT))
LOCAL cNumBOW 	:= StrZero(1,Len(BEA->BEA_NUMAUT))
LOCAL cNumBE4 	:= StrZero(1,Len(BEA->BEA_NUMAUT))
LOCAL cNumBD5 	:= StrZero(1,Len(BEA->BEA_NUMAUT))
LOCAL cNumB4Q 	:= StrZero(1,Len(BEA->BEA_NUMAUT))
LOCAL cNumB4A	:= StrZero(1,Len(BEA->BEA_NUMAUT))  
LOCAL nOrdBEA 	:= BEA->(IndexOrd())
LOCAL nRecBEA 	:= BEA->(Recno())
LOCAL nOrdB44 	:= 0
LOCAL nRecB44 	:= 0
LOCAL nOrdBOW 	:= 0
LOCAL nRecBOW 	:= 0
LOCAL nOrdBE4 	:= 0
LOCAL nRecBE4 	:= 0
Local nrecBD5		:= 0
Local nOrdBD5		:= 0
LOCAL cFilBEA 	:= xFilial("BEA")
LOCAL nLenNum 	:= Len(BEA->BEA_NUMAUT)
LOCAL cAreaSlv 	:= Alias()
Local cSql			:= ""
     
DEFAULT cFiltro := ""

nH := PLSAbreSem("PLNUMAUT.SMF")

lFiltrar := !Empty(cFiltro)

DbSelectArea("BEA")

if lFiltrar
   SET FILTER TO
endIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                                     
//³ Busco o maior numero do BEA												 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
BEA->(DbSetOrder(1))
BEA->(MsSeek(cFilBEA+cOpeMov+cAno+cMes+Replicate("9",nLenNum),.T.))
BEA->(DbSkip(-1))                                                      
If BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT) <> cFilBEA+cOpeMov+cAno+cMes
   cNumBEA := StrZero(1,nLenNum)
Else
   cNumBEA := StrZero(Val(BEA->BEA_NUMAUT)+1,nLenNum)
Endif
BEA->(DbSetOrder(nOrdBEA))
BEA->(DbGoTo(nRecBEA))                         
                                    
// Agora vou buscar o maior do B44										     
If PLSALIASEXI("B44")
	nOrdB44 := B44->(IndexOrd())         
	nRecB44 := B44->(Recno())         
	B44->(DbSetOrder(1))
	B44->(MsSeek(xFilial("B44")+cOpeMov+cAno+cMes+Replicate("9",nLenNum),.T.))
	B44->(DbSkip(-1))                                                      
	If B44->(B44_FILIAL+B44_OPEMOV+B44_ANOAUT+B44_MESAUT) <> xFilial("B44")+cOpeMov+cAno+cMes
	   cNumB44 := StrZero(1,nLenNum)
	Else
	   cNumB44 := StrZero(Val(B44->B44_NUMAUT)+1,nLenNum)
	Endif
	B44->(DbSetOrder(nOrdB44))
	B44->(DbGoTo(nRecB44))                         
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                     
//³ Agora vou comparar os dois e pegar o maior							     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cNumB44 > cNumBEA 
	cNum := cNumB44
Else
	cNum := cNumBEA
EndIf         
                                    
// Agora vou buscar o maior da BOW ** Gera Guia mesmo no Protocolo
SIX->(DbSetOrder(1))
If PLSALIASEXI("BOW") .and. SIX->(msSeek("BOW6"))

	nOrdBOW := BOW->(IndexOrd())         
	nRecBOW := BOW->(Recno())         

	BOW->(DbSetOrder(6))
	BOW->(MsSeek(xFilial("BOW")+cOpeMov+cAno+cMes+Replicate("9",nLenNum),.T.))
	BOW->(DbSkip(-1))
	                                                      
	If BOW->(BOW_FILIAL+BOW_OPEMOV+BOW_ANOAUT+BOW_MESAUT) <> xFilial("BOW")+cOpeMov+cAno+cMes
	   cNumBOW := StrZero(1,nLenNum)
	Else
	   cNumBOW := StrZero(Val(BOW->BOW_NUMAUT)+1,nLenNum)
	Endif
	
	BOW->(DbSetOrder(nOrdBOW))
	BOW->(DbGoTo(nRecBOW))                         
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                     
//³ Agora vou comparar os dois e pegar o maior							     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cNumBOW > cNum 
	cNum := cNumBOW
EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                     
//³ Se  For Chamado pelo Reembolso Retorno o Ultimo numero Autorização 	     ³
//³ de Reembolso 															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If (FunName() == "PLSA001" .or.  Type("cTlmkReem") # "U")  /// variavel Chamada do Fonte plsa001 correcao Numeração autorizacao para reembolso
	PLSFechaSem(nH,"PLNUMAUT.SMF")
	Return(cNum)
Endif
                                   
// Agora vou buscar o maior do BE4										    
If PLSALIASEXI("BE4")
	nOrdBE4 := BE4->(IndexOrd())         
	nRecBE4 := BE4->(Recno())         
	BE4->(DbSetOrder(2))
	BE4->(MsSeek(xFilial("BE4")+cOpeMov+cAno+cMes+Replicate("9",nLenNum),.T.))
	BE4->(DbSkip(-1))                                                      
	If BE4->(BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT) <> xFilial("BE4")+cOpeMov+cAno+cMes
	   cNumBE4 := StrZero(1,nLenNum)
	Else
	   cNumBE4 := StrZero(Val(BE4->BE4_NUMINT)+1,nLenNum)
	Endif
	BE4->(DbSetOrder(nOrdBE4))
	BE4->(DbGoTo(nRecBE4))                         
EndIf                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                     
//³ Agora vou comparar os dois e pegar o maior							     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cNumBE4 > cNum
	cNum := cNumBE4
EndIf
                                                                                                          
// Agora vou buscar o maior do B4A
nOrdB4A := B4A->(IndexOrd())         
nRecB4A := B4A->(Recno())         
B4A->(DbSetOrder(1))
B4A->(MsSeek(xFilial("B4A")+cOpeMov+cAno+cMes+Replicate("9",nLenNum),.T.))
B4A->(DbSkip(-1))                                                      
If B4A->(B4A_FILIAL+B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT) <> xFilial("B4A")+cOpeMov+cAno+cMes
   cNumB4A := StrZero(1,nLenNum)
Else
   cNumB4A := StrZero(Val(B4A->B4A_NUMAUT)+1,nLenNum)
Endif
B4A->(DbSetOrder(nOrdB4A))
B4A->(DbGoTo(nRecB4A))

If cNumB4A > cNum
	cNum := cNumB4A
EndIf
                                   
// Agora vou buscar o maior do BD5
cSql += " Select MAX(BD5_NUMAUT) BD5_NUMAUT FROM " + RetsqlName("BD5")
cSql += " WHERE BD5_FILIAL = '" + xFilial('BD5') + "' "
cSql += " AND BD5_CODOPE = '" + cOpeMov + "' "
cSql += " AND BD5_ANOAUT = '" + cAno + "' "
cSql += " AND BD5_MESAUT = '" + cMes + "' "
cSql += " AND D_E_L_E_T_ = ' ' "
cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"MAXBD5",.F.,.T.)

If EmpTy(MAXBD5->BD5_NUMAUT)
      cNumBD5 := StrZero(1,nLenNum)
else
	cNumBD5 := StrZero(Val(MAXBD5->BD5_NUMAUT)+1,nLenNum)
EndIF
	                         
MAXBD5->(dbCloseArea())

If cNumBD5 > cNum
      cNum := cNumBD5
EndIf
                                   
// Agora vou buscar o maior do B4Q										     
If PLSALIASEXI("B4Q") 
	nOrdB4Q := B4Q->(IndexOrd())         
	nRecB4Q := B4Q->(Recno())         
	B4Q->(DbSetOrder(1))
	B4Q->(MsSeek(xFilial("B4Q")+cOpeMov+cAno+cMes+Replicate("9",nLenNum),.T.))
	B4Q->(DbSkip(-1))                                                      
	If B4Q->(B4Q_FILIAL+B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT) <> xFilial("B4Q")+cOpeMov+cAno+cMes
	   cNumB4Q := StrZero(1,nLenNum)
	Else
	   cNumB4Q := StrZero(Val(B4Q->B4Q_NUMAUT)+1,nLenNum)
	Endif
	B4Q->(DbSetOrder(nOrdB4Q))
	B4Q->(DbGoTo(nRecB4Q))                         
EndIf

If cNumB4Q > cNum
	cNum := cNumB4Q
EndIf

DbSelectArea("BEA")
if lFiltrar   	
   SET FILTER TO &cFiltro   	   
endIf	

if ! Empty(cAreaSlv)
	DbSelectArea(cAreaSlv)
endIf

PLSFechaSem(nH,"PLNUMAUT.SMF")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                     
//³ Fim da Rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(cNum)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLNUMEST ³ Autor ³ Tulio Cesar           ³ Data ³ 12.01.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna o numero da proxima Liberacao Especial             ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLNUMLES(cOpeMov,cAno,cMes)
LOCAL nNum    := 0
LOCAL nOrdBEI := BEI->(IndexOrd())
LOCAL nRecBEI := BEI->(Recno())
       
BEI->(DbSetOrder(1))
BEI->(MsSeek(xFilial("BEI")+cOpeMov+cAno+cMes+"999999",.T.))
       
BEI->(DbSkip(-1))
        
If BEI->(BEI_FILIAL+BEI_OPEMOV+BEI_ANOLES+BEI_MESLES) == xFilial("BEI")+cOpeMov+cAno+cMes
   nNum := Val(BEI->BEI_NUMLES)+1
Else
   nNum := 1
Endif                      
       
BEI->(DbGoTo(nRecBEI))
BEI->(DbSetOrder(nOrdBEI))

Return(StrZero(nNum,Len(BEI->BEI_NUMLES)))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLRETMES ³ Autor ³ Tulio Cesar           ³ Data ³ 29.05.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna o nome de um determinado mes...                    ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLRETMES(nMes,cTipo)
LOCAL aMes
LOCAL cRet                   
DEFAULT cTipo := "1"

If cTipo == "1"
   aMes := {"JANEIRO","FEVEREIRO","MARCO","ABRIL","MAIO","JUNHO","JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"}
Else
   aMes := {"Janeiro","Fevereiro","Marco","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
Endif

If nMes >= 1 .And. nMes <= 12
   cRet :=aMes[nMes]
Else
   cRet := "MES INVALIDO!!!"
Endif      

Return(cRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSELLOC ³ Autor ³ Tulio Cesar           ³ Data ³ 31.05.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Monta tela padrao para selecionar localidade de um credenc ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSELLOC(cCodCre)
LOCAL aDados := {}
LOCAL aCabec := {}
LOCAL oDlg
LOCAL cRet
LOCAL oBrwLoc
LOCAL bOK    := {|| cRet := oBrwLoc:aCols[oBrwLoc:Linha(),oBrwLoc:RetCol("BB8_CODLOC")]+"-"+;
                              oBrwLoc:aCols[oBrwLoc:Linha(),oBrwLoc:RetCol("BB8_DESLOC")]+"-"+;
                              oBrwLoc:aCols[oBrwLoc:Linha(),oBrwLoc:RetCol("BB8_END")],;
                              oDlg:End() }
LOCAL nNome

Store Header "BB8" TO aCabec For SX3->X3_ORDEM >= "03"

SA2->(DbSetOrder(1))

SA2->(MsSeek(xFilial("SA2")+cCodCre))

cNome := cCodCre+" - "+AllTrim(SA2->A2_NOME)

BB8->(DbSetOrder(1))
If BB8->(MsSeek(xFilial("BB8")+cCodCre))

   aTrb := {}

   Store COLS "BB8" TO aDados FROM aCabec VETTRAB aTrb While xFilial("BB8")+cCodCre == BB8->(BB8_FILIAL+BB8_CODCRE)
   
   DEFINE MSDIALOG oDlg TITLE "Locais de Atendimento" FROM 008.2,010.3 TO 020,100.3 OF GetWndDefault()
   
   oBrwLoc := TPLSBrw():New(022,005,345,073,nil  ,oDlg,nil    , bOK ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabec,aDados,.F.,"BB8",K_Visualizar,"Localidades do Credenciado",nil)

   @ 005,005 MSGET cNome SIZE 205,010 OF oDlg PIXEL COLOR CLR_HBLUE
   
   ACTIVATE DIALOG oDlg ON INIT PLInitCols(aDados,aCabec,oBrwLoc)
   
Else
   Help("",1,"PLSELLOC")
   cRet := "LOCALIDADE PARA O CREDENCIADO NAO EXISTE"
Endif   

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLRETCRI ³ Autor ³ Tulio Cesar           ³ Data ³ 31.05.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna a descricao da critica da autorizacao...           ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLRETCRI(cCritica)

SX5->(DbSetOrder(1))
SX5->(MsSeek(xFilial("SX5")+"B3"+cCritica))

aSX5    := FWGetSX5("B3",cCritica)

RETURN(IF(Len(aSX5) == 0," ",aSX5[1][4]))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLVALSQL ³ Autor ³ Tulio Cesar           ³ Data ³ ??.??.?? ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Converte expressoes do tipo Caracter, Data e Numerico para ³±±±
±±³          ³ um formato valido para Script em ambiente TopConnect.      ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caracter TULIO CESAR DE MELO BATISTA -> 'TULIO CESAR DE MELO BATISTA' ³
//³ Data     10/10/200                   -> '20001010'                    ³
//³ Numerico 100.95                      -> 100.95                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function PLValSQL(xFieldGet)
LOCAL cField
LOCAL cValor

DO CASE
	CASE ValType(xFieldGet) == "C"
 		  cField := Trim(xFieldGet)
		  If ("'"$cField)
		  	  cField := StrTran(cField,"'",'"')
		  EndIf
		  cValor := "'" + cField + "'"
	CASE VALTYPE(xFieldGet) == "D"
		  cValor := "'" + DTOS( xFieldGet ) + "'"
   CASE VALTYPE(xFieldGet) == "L"
	     If xFieldGet
			  cValor := "T"
		  Else
			  cValor := "F"
		  EndIf
	CASE ValType(xFieldGet) == "N"
		  cValor := AllTrim( Str( xFieldGet ) )
ENDCASE

Return cValor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLDESGRU ³ Autor ³ Tulio Cesar           ³ Data ³ 13.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna a descricao de um grupo de credenciados            ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLDESGRU(cCodGrupo)

BAG->(DbSetOrder(1))
BAG->(MsSeek(xFilial("BAG")+cCodGrupo))

Return(If(BAG->(Found()),BAG->BAG_DESCRI,""))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLRETESP ³ Autor ³ Tulio Cesar           ³ Data ³ 14.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna as especialidades de um determinado credenciado    ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLRETESP(cCodCre)
LOCAL cEspec  := ""

BB9->(DbSetOrder(1))

If BB9->(MsSeek(xFilial("BB9")+cCodCre))
   While ! BB9->(Eof()) .And. BB9->(BB9_FILIAL+BB9_CODCRE) == xFilial("BB9")+cCodCre
         BA8->(DbSetOrder(1))
         
         If BA8->(MsSeek(xFilial("BA8")+BB9->BB9_CODOPC))
            cEspec := cEspec + "   "+AllTrim(BA8->BA8_DESCRI)
         Endif
   BB9->(DbSkip())
   Enddo
Endif         
          
Return(cEspec)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLDESPRO ³ Autor ³ Tulio Cesar           ³ Data ³ 14.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna a descricao de um procedimento.                    ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLDESPRO(cCodPad,cCodPro)
LOCAL nOrdBR8 := BR8->(IndexOrd())

BR8->(DbSetOrder(1))
If BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro))
   cRet := BR8->BR8_DESCRI
Else  
   cRet := "PROCEDIMENTO NAO ENCONTRADO"
   cRet := cRet + Space(Len(BR8->BR8_DESCRI)-Len(cRet))
Endif      

BR8->(DbSetOrder(nOrdBR8))

Return(cRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLRETTPU ³ Autor ³ Tulio Cesar           ³ Data ³ 15.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorno se usuario e Titular, Depedente ou Agregado        ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLRETTPU(cTipoUsr)
LOCAL cRet

If     cTipoUsr == "D"
       cRet := STR0063//"Depedente"
ElseIf cTipoUsr == "A"
       cRet := STR0064//"Agregado"
ElseIf cTipoUsr == "T"
       cRet := STR0065//"Titular"
Else
       cRet := ""
Endif

Return(cRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLVLDUSU ³ Autor ³ Tulio Cesar           ³ Data ³ 17.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna se o usuario e valido.                             ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLVLDUSU(cMatric)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva ordens antigas...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nOrdBA1 := BA1->(IndexOrd())
LOCAL nOrdBA3 := BA3->(IndexOrd())
LOCAL nOrdSA1 := SA1->(IndexOrd())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica arquivo de usuarios...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
BA1->(DbSetOrder(2))
If ! BA1->(MsSeek(xFilial("BA1")+cMatric))
   BA1->(DbSetOrder(5))                   
   If ! BA1->(MsSeek(xFilial("BA1")+cMatric))
      BA1->(DbSetOrder(nOrdBA1))
      Help(" ",1,"PLCONTBA1")
      Return(.F.)
   Endif   
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o contrato existe...                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA3->(DbSetOrder(1))
If ! BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
   BA1->(DbSetOrder(nOrdBA1))   
   BA3->(DbSetOrder(nOrdBA3))
   Help(" ",1,"PLCONTBA3")
   Return(.F.)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o cliente existe...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BA3->BA3_COBNIV == "1"
   SA1->(DbSetOrder(1))
   If ! SA1->(MsSeek(xFilial("SA1")+BA3->BA3_CODCLI+BA3->BA3_LOJA))
      BA1->(DbSetOrder(nOrdBA1))   
      BA3->(DbSetOrder(nOrdBA3))
      SA1->(DbSetOrder(nOrdSA1))
      Help(" ",1,"PLCONTSA1")
      Return(.F.)
   Endif   
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Usuario OK...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLVERTOP ³ Autor ³ Tulio Cesar           ³ Data ³ 17.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Exibe mensagem dizendo que a rotina so funciona TopConn    ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLVERTOP()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLRETGLO ³ Autor ³ Tulio Cesar           ³ Data ³ 31.05.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna a descricao da glosa de um movimento...            ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLRETGLO(cCritica)

SX5->(DbSetOrder(1))
SX5->(MsSeek(xFilial("SX5")+"B2"+cCritica))

aSX5    := FWGetSX5("B2",cCritica)

RETURN(IF(Len(aSX5) == 0,Space(55),aSX5[1][4]))
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLProxMAT    ³ Autor ³ Tulio Cesar       ³ Data ³ 20.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna a proxima matricula para um contrato.              ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLProxMAT(cCodInt,cCodEmp, cFilBA1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cRetorno
LOCAL nH
LOCAL lRepete
LOCAL aOldArea := GetArea()

DEFAULT cFilBA1 := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aloca semaforo                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nH := PLSAbreSem("PLPROXMAT.SMF")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva posicao das tabelas                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOrdBA3 := BA3->(IndexOrd())
nRecBA3 := BA3->(Recno())
nOrdBA1 := BA1->(IndexOrd())
nRecBA1 := BA1->(Recno())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa o filtro do BA1( Usuarios )                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA1->( dbClearFilter() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula proxima matricula, verificando se existe execblock          ³
//³ onde o cliente pode configurar sua regra para determinar o          ³
//³ numero da proxima matricula                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ExistBlock("PLPROXMT")
    cRetorno := ExecBlock("PLPROXMT",.F.,.F.,{cCodInt,cCodEmp})
Else    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Verifica a proxima matricula disponivel com base no BA3             ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    BA3->(DbSetOrder(1)) 
    BA3->(MsSeek(xFilial("BA3")+cCodInt+cCodEmp+"999999",.T.))
    BA3->(DbSkip(-1))
    If  BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODEMP) == xFilial("BA3")+cCodInt+cCodEmp
        cRetorno := StrZero(Val(BA3->BA3_MATRIC)+1,6)
    Else
        cRetorno := StrZero(1,6)
    Endif                      
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Verifica se a matricula ja nao foi utilizada anteriormente          ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    While .T.
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Inicializa variavel para indicar se deve repetir a verificacao      ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       lRepete := .F.
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Verifica se existe matricula anterior com o mesmo numero            ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       BA1->(dbsetOrder(5))  // BA1_MATANT
       While .T.
          If  BA1->(MsSeek(xFilial("BA1")+cCodInt+cCodEmp+cRetorno))
              cRetorno := StrZero(Val(cRetorno)+1,6)
              lRepete  := .T.
              Loop
          Endif
          Exit
       Enddo   
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Verifica se existe matricula anterior/anterior com o mesmo numero   ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       BA1->(dbsetOrder(10))  // BA1_MATUSB
       While .T.
          If  BA1->(MsSeek(xFilial("BA1")+cCodInt+cCodEmp+cRetorno))
              cRetorno := StrZero(Val(cRetorno)+1,6)
              lRepete  := .T.
              Loop
          Endif
          Exit
       Enddo   
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Verifica se pode encerrar a verificacao                             ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If  ! lRepete
           Exit
       Endif
    Enddo
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura posicao das tabelas                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA3->(DbSetOrder(nOrdBA3))
BA3->(DbGoTo(nRecBA3))    
BA1->(DbSetOrder(nOrdBA1))
BA1->(DbGoTo(nRecBA1))                                                  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura o filtro do BA1...                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cFilBA1)
	dbSelectArea("BA1")
	SET FILTER TO &cFilBA1
Endif
                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a area de trabalho...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aOldArea)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera semaforo                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PLSFechaSem(nH,"PLPROXMAT.SMF")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da funcao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(cRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLEXCCRE  ³ Autor ³ Tulio Cesar       ³ Data ³ 27.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Valida se pode excluir um credenciado.                  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLEXCCRE(cCodCre,lHelp)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros                                                          ³
//³ cCodCre - Codigo do Credenciado (6 Digitos)                         ³
//³ lHelp   - Exibir help caso haja movimentacao                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno:                                                            ³
//³ Logico   : .T. caso exista movimentacao                             ³
//³            .F. caso nao exista movimentacao                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL lMov    := .F.              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe no arquivo de movimentacao...                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BD6->(DbSetOrder(4))

If BD6->(MsSeek(xFilial("BD6")+cCodCre))
   lMov := .T.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe no arquivo de contas a pagar...                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! lMov
   SE2->(DbSetOrder(nPlOrdSE2))

   If SE2->(MsSeek(xFilial("SE2")+cCodCre))
      lMov := .T.
   Endif
Endif      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe no arquivo de autorizacoes...                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! lMov
   BE2->(DbSetOrder(2))

   If BE2->(MsSeek(xFilial("BE2")+cCodCre))
      lMov := .T.
   Endif
Endif      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe help...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lHelp
   If lMov
      Help("",1,"PLMOVCRE")
   Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da funcao...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(lMov)      


Function PLRETLib(cCodLib)

cRet := ""

BA7->(DbSetOrder(1))

If BA7->(MsSeek(xFilial("BA7")+cCodLib))
   cRet := BA7->BA7_DESCRI
Endif

Return(cRet)   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLVALSTR ³ Autor ³ Tulio Cesar           ³ Data ³ 30.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Converte expressoes para tipo caracter.                    ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLValSTR(xValue)

LOCAL cRet := ""
 
If     ValType(xValue) == "D"
       cRet := dtoc(xValue)
ElseIf ValType(xValue) == "L"
       cRet := IF(xValue,"T","F")
ElseIf ValType(xValue) == "N"
       cRet := Str(xValue)
ElseIf ValType(xValue) == "C"
       cRet := xValue
Endif                      

Return(cRet)


Function PLRETUSR(cCodUsr)

cRet := ""

If     cCodUsr == "T"
       cRet := "TITULAR"
ElseIf cCodUsr == "D"
       cRet := "DEPEDENTE"
ElseIf cCodUsr == "A"
       cRet := "AGREGADO"       
Endif

Return(cRet)       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLOPCUSR ³ Autor ³ Tulio Cesar           ³ Data ³ 01.07.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna em uma array os opcionais de um usuario...         ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLOPCUSR(cMatric)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aRetorno := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define ordem default no arquivo de produtos...                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA2->(DbSetOrder(1))    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Navega pelos produtos...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BE7->(DbSetOrder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca os produtos vinculados a este usuario...                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BE7->(MsSeek(xFilial("BE7")+cMatric))
   While ! BE7->(Eof()) .And. BE7->(BE7_FILIAL+BE7_CODINT+BE7_CODEMP+BE7_MATRIC+BE7_TIPREG) == xFilial("BE7")+cMatric
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Caso esteja em desbloqueado OK...                                   ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         If Empty(BE7->BE7_MOTBLO)
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Posiciono no produto...                                             ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If BA2->(MsSeek(xFilial("BA2")+BE7->BE7_CODPRO))
               aadd(aRetorno,{BE7->BE7_CODPRO,BA2->BA2_DESPLA,BE7->BE7_DATA})
            Endif   
         Endif   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Acesso proximo opcional para este usuario...                        ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   BE7->(DbSkip())
   Enddo
Endif      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da funcao...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(aRetorno)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLRETOPE ³ Autor ³ Tulio Cesar           ³ Data ³ 04.07.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorno o operador do Advanced Protheus (cUserName)        ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLRETOPE()
Return(cUserName)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSLDEMP ³ Autor ³ Tulio Cesar           ³ Data ³ 11.07.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna o saldo de uma empresa.                            ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSLDEMP(cCodInt,cCodEmp,cAno,cMes)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros                                                          ³
//³ cCodEmp - Codigo da Empresa/Grupo (4 Digitos)                       ³
//³ cCodInt - Codigo da Instituicao (3 Digitos)                         ³
//³ cAno    - Ano Base do Saldo (2 Digitos)                             ³
//³ cMes    - Mes Base do Saldo (2 Digitos)                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno:                                                            ³
//³ Numerico : [1] - Valor da despesa da empresa                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nSaldo  := 0
LOCAL cSQL

cSQL := " SELECT SUM(ROUND(BD6_VLRPAG,2)) AS VALOR FROM "+RetSQLName("BD6")+" WHERE "
cSQL += " BD6_CODEMP = '"+cCodEmp+"' AND "
cSQL += " BD6_CODINT = '"+cCodInt+"' AND "
cSQL += " BD6_ANO    = '"+cAno+"' AND "
cSQL += " BD6_MES    = '"+cMes+"' AND "
cSQL += " BD6_FILIAL = '"+xFilial("BD6")+"' AND "
cSQL += " D_E_L_E_T_ = '' "

cSQL := ChangeQuery(cSQL)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSQL),"TrbEmp",.T.,.T.)

TCSETFIELD("TrbEmp","VALOR","N",nVlPrec,nVlDec)

nSaldo := TrbEmp->VALOR

TrbEmp->(DbCloseArea())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da funcao em formato numerico...                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(nSaldo)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLVALCONT³ Autor ³ Tulio Cesar           ³ Data ³ 11.07.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna o valor de um contrato.                            ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLVALCONT(cMatric,cAno,cMes,lDetalhado)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva dados...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

LOCAL nOrdBA3 := BA3->(IndexOrd())
LOCAL nRecBA3 := BA3->(Recno())
LOCAL nOrdBA1 := BA1->(IndexOrd())
LOCAL nRecBA1 := BA1->(Recno())
LOCAL nOrdBA2 := BA2->(IndexOrd())
LOCAL nRecBA2 := BA2->(Recno())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Defino variavies de retorno...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nRet   := 0
LOCAL aRet   := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao seja especificado obtem o valor na DataBase...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PUBLIC nIdade := 0
DEFAULT cAno   := PLSSTRANO(dDataBase,.T.)
DEFAULT cMes   := PLSSTRMES(dDataBase)
DEFAULT lDetalhado := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no arquivo de contratos...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA3->(DbSetOrder(1))

If ! BA3->(MsSeek(xFilial("BA3")+cMatric))
   BA3->(DbSetOrder(nOrdBA3))
   BA3->(DbGoTo(nRecBA3))
   Help("",1,"PLVALCONTBA3")
   Return(nRet)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se esta pedindo um valor de cobranca apos a inclusao contr.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cAno+cMes < Subs(dtos(BA3->BA3_DATBAS),1,6)
   BA3->(DbSetOrder(nOrdBA3))
   BA3->(DbGoTo(nRecBA3))
   MsgStop("O Mes/Ano Informado a inferior ao mes do contrato.")
   Return(nRet)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no arquivo de planos...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA2->(DbSetOrder(1))

If ! BA2->(MsSeek(xFilial("BA2")+BA3->(BA3_CODINT+BA3_CODPLA)))
   BA3->(DbSetOrder(nOrdBA3))
   BA3->(DbGoTo(nRecBA3))
   BA2->(DbSetOrder(nOrdBA2))
   BA2->(DbGoTo(nRecBA2))
   Help("",1,"PLVALCONTBA2")
   Return(nRet)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca o valor do Plano do Contrato...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nRet := PLVALPRO(cMatric,BA3->(BA3_CODINT+BA3_CODPLA),cAno,cMes,.F.,"",0,.T.,If(lDetalhado,aRet,nil))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca o valor dos produtos ligados a cada usuario...                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BE7->(DbSetOrder(1))

If BE7->(MsSeek(xFilial("BE7")+cMatric))
   While ! BE7->(Eof()) .And. BE7->(BE7_FILIAL+BE7_CODINT+BE7_CODEMP+BE7_MATRIC) == xFilial("BE7")+cMatric
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Verifico se o produto esta bloqueado...                             ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         //If ! Empty(BE7->BE7_MOTBLO)
         If ! (( Empty(BE7->BE7_MOTBLO) .Or. cAno+cMes < Subs(dtos(BE7->BE7_DATBLO),1,6) ))
            BE7->(DbSkip())
            Loop
         Endif   
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Verifico se no anomes atual o usuario ja tinha o produto...         ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         If ! (cAno+cMes >= Subs(dtos(BE7->BE7_DATA),1,6) )
            BE7->(DbSkip())
            Loop
         Endif   
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Posiciona no produto...                                             ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         BA2->(DbSetOrder(1))
         
         BA2->(MsSeek(xFilial("BA2")+BE7->BE7_CODPRO))
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Para cada produto verifico se o usuario esta ativo...               ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         BA1->(DbSetOrder(2))
         
         If BA1->(MsSeek(xFilial("BA1")+BE7->(BE7_CODINT+BE7_CODEMP+BE7_MATRIC+BE7_TIPREG)))
            //If Empty(BA1->BA1_MOTBLO)
            If ( Empty(BA1->BA1_MOTBLO) .Or. cAno+cMes < Subs(dtos(BA1->BA1_DATBLO),1,6) )
               nVlrProd := PLVALPRO(cMatric,BE7->BE7_CODPRO,cAno,cMes,.T.,BE7->BE7_TIPREG,BE7->BE7_COEFIC,.F.)
               nRet     += nVlrProd
               
               If lDetalhado
                  aadd(aRet,{BA1->(BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"-"+BA1_TIPREG),BA1->BA1_NOMUSR,BA1->BA1_COEFIC,nIdade,"BE7",BE7->BE7_CODPRO+" - "+BA2->BA2_DESPLA,nVlrProd,nRet})
               Endif   
            Endif
         Endif   
   BE7->(DbSkip())
   Enddo           
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se existe taxa de adesao para o produto...                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BA2->BA2_TXADES > 0
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Somente cobrar taxa se nao existe titulo no SE1...                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   SE1->(DbSetOrder(nPlOrdSE1))
         
   lCalc := SE1->(MsSeek(xFilial("SE1")+cMatric))

   If ! lCalc
      nQtdUsr := PLSQTDUSR(cMatric,.T.)
      nTaxa   := BA2->BA2_TXADES*nQtdUsr
      nRet    += nTaxa
         
      If lDetalhado
         aadd(aRet,{"","FAMILIA",1,0,"TAX","TAXA DE IMPLANTACAO",nTaxa,nRet})
      Endif
   Endif   
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula aumento agencia nacional de saude...                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nRet := PLREAJUS(BA3->BA3_CODEMP,BA3->BA3_DATBAS,nRet,cAno,cMes,aRet)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula desconto ou acrescimo em relacao ao contrato todo...        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nRet := PLADCON(cMatric,nRet,cAno,cMes,lDetalhado,aRet)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura dados salvados...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA1->(DbSetOrder(nOrdBA1))
BA1->(DbGoTo(nRecBA1))
BA3->(DbSetOrder(nOrdBA3))
BA3->(DbGoTo(nRecBA3))
BA2->(DbSetOrder(nOrdBA2))
BA2->(DbGoTo(nRecBA2))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(IF(lDetalhado,aRet,nRet))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLVALPRO ³ Autor ³ Tulio Cesar           ³ Data ³ 08.08.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna o valor de um produto para um contrato.            ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLVALPRO(cMatric,cCodPro,cAno,cMes,lInd,cIdent,nCoefic,lBA2,aRet)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva dados...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nOrdBA1 := BA1->(IndexOrd())
LOCAL nRecBA1 := BA1->(Recno())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL lDetalhado := (ValType(aRet)=="A")
LOCAL nRet       := 0
LOCAL nQtdAux    := 0
LOCAL nQtdDep    := 0
LOCAL nQtdMinDep
LOCAL nQtdMaxDep
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao seja especificado obtem o valor na DataBase...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT cAno    := PLSSTRANO(dDataBase,.T.)
DEFAULT cMes    := PLSSTRMES(dDataBase)             
DEFAULT lInd    := .F.
DEFAULT cMatric := ""                                              
DEFAULT nCoefic := 1
DEFAULT lBA2    := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define ordens default...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA2->(DbSetOrder(1))
BA1->(DbSetOrder(2))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Produto...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! BA2->(MsSeek(xFilial("BA2")+cCodPro))
   Return(nRet)
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona na familia...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA3->(DbSetOrder(1))

If ! BA3->(MsSeek(xFilial("BA3")+cMatric))
   Return(nRet)
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa valor fixo...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If     BA2->BA2_FIXO == "S"
       If lInd
          nRet += BA2->BA2_VALFIX*nCoefic              
       Else
          If ! lBA2
             BE7->(DbSetOrder(1))
             
             If BE7->(MsSeek(xFilial("BE7")+cMatric))
                While ! BE7->(Eof()) .And. BE7->(BE7_FILIAL+BE7_CODINT+BE7_CODEMP+BE7_MATRIC) == xFilial("BE7")+cMatric
                      BA1->(DbSetOrder(2))
                      If BA1->(MsSeek(xFilial("BA1")+BE7->(BE7_CODINT+BE7_CODEMP+BE7_MATRIC+BE7_TIPREG)))
                         //If Empty(BE7->BE7_MOTBLO)
                         
                         If cAno+cMes <= Subs(dtos(BE7->BE7_DATA),1,6)
                            BE7->(DbSkip())
                            Loop
                         Endif   
                         
                         If ( Empty(BE7->BE7_MOTBLO) .Or. cAno+cMes < Subs(dtos(BE7->BE7_DATBLO),1,6) )
                            nVal := BA2->BA2_VALFIX*BE7->BE7_COEFIC
                            nRet += nVal
                            If lDetalhado
                               aadd(aRet,{BA1->(BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"-"+BA1_TIPREG),BA1->BA1_NOMUSR,BE7->BE7_COEFIC,nIdade,"BE7",BE7->BE7_CODPRO+" - "+BA2->BA2_DESPLA,nVal,nRet})
                            Endif   
                         Endif   
                      Endif   
                BE7->(DbSkip())
                Enddo      
             Endif      
          Else
             BA1->(DbSetOrder(2))
             
             If BA1->(MsSeek(xFilial("BA1")+cMatric))
                While ! BA1->(Eof()) .And. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial("BA1")+cMatric
                      //If Empty(BA1->BA1_MOTBLO)
                      If ( Empty(BA1->BA1_MOTBLO) .Or. cAno+cMes < Subs(dtos(BA1->BA1_DATBLO),1,6) )
                         nVal := BA2->BA2_VALFIX*BA1->BA1_COEFIC
                         nRet += nVal
                         If lDetalhado
                            aadd(aRet,{BA1->(BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"-"+BA1_TIPREG),BA1->BA1_NOMUSR,BA1->BA1_COEFIC,nIdade,"BA2",BA2->BA2_CODPLA+" - "+BA2->BA2_DESPLA,nVal,nRet})
                         Endif
                      Endif   
                BA1->(DbSkip())
                Enddo      
             Endif      
          Endif  
       Endif   
ElseIf BA2->BA2_FAMILI <> "S"
       If ! lInd
          If BA1->(MsSeek(xFilial("BA1")+cMatric))
             While ! BA1->(Eof()) .And. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial("BA1")+cMatric
                   //If Empty(BA1->BA1_MOTBLO)
                   If ( Empty(BA1->BA1_MOTBLO) .Or. cAno+cMes < Subs(dtos(BA1->BA1_DATBLO),1,6) )
                      nVal := PLVLRFAI(BA1->BA1_DATNAS,BA1->BA1_TIPUSU,cCodPro,cAno,cMes,BA1->BA1_DATINC,BA1->BA1_COEFIC)
                      nRet += nVal
                      If lDetalhado
                         aadd(aRet,{BA1->(BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"-"+BA1_TIPREG),BA1->BA1_NOMUSR,BA1->BA1_COEFIC,nIdade,"BA2",BA2->BA2_CODPLA+" - "+BA2->BA2_DESPLA,nVal,nRet})
                      Endif   
                   Endif   
             BA1->(DbSkip())
             Enddo
          Endif
       Else           
           BA1->(DbSetOrder(2))
           If BA1->(MsSeek(xFilial("BA1")+cMatric+cIdent))
              //If Empty(BA1->BA1_MOTBLO)
              If ( Empty(BA1->BA1_MOTBLO) .Or. cAno+cMes < Subs(dtos(BA1->BA1_DATBLO),1,6) )
                 nVal := PLVLRFAI(BA1->BA1_DATNAS,BA1->BA1_TIPUSU,cCodPro,cAno,cMes,BA1->BA1_DATINC,nCoefic)
                 nRet += nVal
                 
                 If lDetalhado
                    aadd(aRet,{BA1->(BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"-"+BA1_TIPREG),BA1->BA1_NOMUSR,BA1->BA1_COEFIC,nIdade,"BA2",BA2->BA2_CODPLA+" - "+BA2->BA2_DESPLA,nVal,nRet})
                 Endif   
              Endif   
           Endif
       Endif   
ElseIf BA2->BA2_FAMILI == "S" 
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Plano Familiar...                                                   ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       nQtdMinDep := BA2->BA2_NMINDE
       nQtdMaxDep := BA2->BA2_NMAXDE

       nQtdDep    := PLSQTDUSR(cMatric,.F.)-1
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Menor que a quantidade minima. Pega o da faixa...                   ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If     nQtdDep < nQtdMinDep
              BA1->(MsSeek(xFilial("BA1")+cMatric))
              nVal := PLVLRFAI(BA1->BA1_DATNAS,BA1->BA1_TIPUSU,cCodPro,cAno,cMes,BA1->BA1_DATINC,BA1->BA1_COEFIC)
              nRet += nVal
              
              If lDetalhado
                 aadd(aRet,{"","FAMILIA",1,0,"BA2","PLANO FAMILIAR "+BA2->BA2_CODPLA+" - "+BA2->BA2_DESPLA,nVal,nRet})
              Endif
       ElseIf nQtdDep > nQtdMaxDep   
              nVal := BA2->BA2_VLFAMI
              nRet += nVal

              If lDetalhado
                 aadd(aRet,{"","FAMILIA",1,0,"BA2","PLANO FAMILIAR "+BA2->BA2_CODPLA+" - "+BA2->BA2_DESPLA,nVal,nRet})
              Endif

              If BA1->(MsSeek(xFilial("BA1")+cMatric))
                 BA1->(DbSkip()) // Pula o titular...
                 While ! BA1->(Eof()) .And. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial("BA1")+cMatric
                       //If Empty(BA1->BA1_MOTBLO)
                       If ( Empty(BA1->BA1_MOTBLO) .Or. cAno+cMes < Subs(dtos(BA1->BA1_DATBLO),1,6) )
                          nQtdAux ++
                       Else
                          BA1->(DbSkip())
                          Loop
                       Endif   
                       If nQtdAux > nQtdMaxDep
                          nVal := PLVLRFAI(BA1->BA1_DATNAS,BA1->BA1_TIPUSU,cCodPro,cAno,cMes,BA1->BA1_DATINC,BA1->BA1_COEFIC)         
                          nRet += nVal
                          
                          If lDetalhado
                             aadd(aRet,{"","FAMILIA",1,0,"BA2","PLANO FAMILIAR "+BA2->BA2_CODPLA+" - "+BA2->BA2_DESPLA,nVal,nRet})
                          Endif
                       Endif
                 BA1->(DbSkip())
                 Enddo
              Endif
       Else
              nVal    :=BA2->BA2_VLFAMI
              nRet    += nVal
              nQtdAgr := PLSQTDUSR(cMatric,.T.)-1

              If lDetalhado
                 aadd(aRet,{"","FAMILIA",1,0,"BA2","PLANO FAMILIAR "+BA2->BA2_CODPLA+" - "+BA2->BA2_DESPLA,nVal,nRet})
              Endif                              
              
              //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
              //³ Existe agregados que devem ser somados a parte do plano familiar... ³
              //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
              If nQtdAgr > nQtdDep 
                 If BA1->(MsSeek(xFilial("BA1")+cMatric))
                    BA1->(DbSkip()) // Pula o titular...
                    While ! BA1->(Eof()) .And. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial("BA1")+cMatric
                          //If BA1->BA1_TIPUSU <> "A" .Or. ! Empty(BA1->BA1_MOTBLO)
                          If BA1->BA1_TIPUSU <> "A" .Or. ! ( Empty(BA1->BA1_MOTBLO) .Or. cAno+cMes < Subs(dtos(BA1->BA1_DATBLO),1,6) )
                             BA1->(DbSkip())
                             Loop
                          Endif   
                          nVal := PLVLRFAI(BA1->BA1_DATNAS,BA1->BA1_TIPUSU,cCodPro,cAno,cMes,BA1->BA1_DATINC,BA1->BA1_COEFIC)         
                          nRet += nVal
                          
                          If lDetalhado
                              aadd(aRet,{BA1->(BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"-"+BA1_TIPREG),BA1->BA1_NOMUSR,BA1->BA1_COEFIC,nIdade,"BA2","USUARIO AGREGADO "+BA2->BA2_CODPLA+" - "+BA2->BA2_DESPLA,nVal,nRet})
                          Endif
                    BA1->(DbSkip())
                    Enddo
                 Endif
              Endif
       Endif
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura area do BA1...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA1->(DbSetOrder(nOrdBA1))
BA1->(DbGoTo(nRecBA1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna o valor de cobranca para este produto...                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(nRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLX7DAT  ³ Autor ³ Tulio Cesar           ³ Data ³ 24.07.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Funcao utilizada no X7_REGRA do campo BA1_DATNAS           ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLX7Dat(dDatNasc,cTipUsu,cCodPla,dDatInc,nCoefic)

nVlr := PLVLRFAI(dDatNasc,cTipUsu,cCodPla,PLSSTRANO(dDatInc),PLSSTRMES(dDatInc),dDatInc,nCoefic)

Return(nVlr)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLALTCLI ³ Autor ³ Tulio Cesar           ³ Data ³ 03.08.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Altera dados de um cliente para a matricula informada.     ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLAltCli(cMatric, lVisCli)

DEFAULT lVisCli := .F.

BA1->(DbSetOrder(2))
IF BA1->(MsSeek(xFilial("BA1")+cMatric))
   BA3->(DbSetOrder(1))
   IF BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC))) .And. BA3->BA3_COBNIV == "1"
      SA1->(DbSetOrder(1))
      IF SA1->(MsSeek(xFilial("SA1")+BA3->BA3_CODCLI+BA3->BA3_LOJA))
         cOld := cCadastro
         If lVisCli
         	cCadastro := "Visualizacao de Dados do Cliente - Usuario Selecionado "+AllTrim(BA1->BA1_NOMUSR)
         	SA1->(AxVisual("SA1",SA1->(Recno()),K_Alterar))
         Else
	        cCadastro := "Alteracao de Dados do Cliente - Usuario Selecionado "+AllTrim(BA1->BA1_NOMUSR)
         	SA1->(AxAltera("SA1",SA1->(Recno()),K_Alterar))
         EndIf
         cCadastro := cOld
      Endif
   Else
      Help("",1,"PLSALTCLI")      
   Endif
Else
   Help("",1,"PLSA090USR")
Endif               

Return   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLDATESTR ³ Autor ³ Tulio Cesar           ³ Data ³ 03.08.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Converte uma data para formato com 4 digitos no ano.        ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLDateSTR(dData)
cData := dtos(dData)
cDia  := Subs(cData,7,2)
cMes  := Subs(cData,5,2)
cAno  := Subs(cData,1,4)
cRet  := cDia+"/"+cMes+"/"+cAno
Return(cRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLVLRFAI ³ Autor ³ Tulio Cesar           ³ Data ³ 03.08.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna um valor para uma determinada faixa...             ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLVLRFAI(dNascto,cTipo,cPlano,cAno,cMes,dDataInc,nCoefic)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL dData
LOCAL nRet    := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para tratar valor da faixa etaria...               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PLVLRFAI")
   nRet := ExecBlock("PLVLRFAI",.F.,.F.)
   
   If nRet > 0
      Return(nRet)
   Endif   
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no produto...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA2->(DbSetOrder(1))
BA2->(MsSeek(xFilial("BA2")+cPlano))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Usuarios com mais de dez anos de plano permanecem na faixa quando   ³
//³ isto acontece.                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nAnosPlano := PLSDIFANOS(PLSSTRANO(dDataInc,.T.),PLSSTRMES(dDataInc),cAno,cMes,"M")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamentos para mudanca de faixa...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAnoAux := "1998"
cMesAux := "06"
dData   := ctod("01/"+cMesAux+"/"+Subs(cAnoAux,3,2))

nIdade := DateDiffYear(dData,dNascto)       

If     BA1->BA1_10ANOS == "N" .Or. nIdade < 60
       nIdade := 0
       If     BA2->BA2_MUDFAI == "N"
              If ! Empty(BA2->BA2_ANOMES)
                 cAnoNas := subs(dtos(dNascto),1,4)
                 cMesNas := subs(dtos(dNascto),5,2)
      
                 If cAnoNas+cMesNas <= BA2->BA2_ANOMES
                    dData   := ctod("01/"+Subs(BA2->BA2_ANOMES,5,2)+"/"+Subs(BA2->BA2_ANOMES,3,2))
                    nIdade  := DateDiffYear(dData,dNascto)    
                 Endif
              Else
                 nIdade  := DateDiffYear(dDataInc,dNascto)       
              Endif
       ElseIf nAnosPlano > (10*12) .And. BA2->BA2_MUDFAI ==  "S"
              cAnoAux := StrZero(val(subs(dtos(dDataInc),1,4))+10,4)
              cMesAux := PLSSTRMES(dDataInc)
   
              dData   := ctod("01/"+cMesAux+"/"+Subs(cAnoAux,3,2))
              nIdade  := DateDiffYear(dData,dNascto)
       ElseIf BA2->BA2_MUDFAI == "S" .And. BA1->BA1_10ANOS == "N"
              dData   := ctod("01/"+cMes+"/"+Subs(cAno,3,2))
              nIdade  := DateDiffYear(dData,dNascto)
       Else
              nIdade  := DateDiffYear(dDataInc,dNascto)
       Endif   
ElseIf BA1->BA1_10ANOS == "S"
       cAnoAux := StrZero(val(subs(dtos(dDataInc),1,4)),4)
       cMesAux := PLSSTRMES(dDataInc)
   
       dData   := ctod("01/"+cMesAux+"/"+Subs(cAnoAux,3,2))
       nIdade  := DateDiffYear(dData,dNascto)
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca a faixa etaria para este usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If     cTipo == "T"
       cCodAux := "1"
ElseIf cTipo == "D"  
       cCodAux := "2"
ElseIf cTipo == "A"         
       cCodAux := "3"
Endif       
       
BB3->(DbSetOrder(1))
If BB3->(MsSeek(xFilial("BB3")+cPlano+cCodAux))
   While ! BB3->(Eof()) .And. BB3->(BB3_FILIAL+BB3_CODPLA+BB3_TIPUSR) == xFilial("BB3")+cPlano+cCodAux
         If nIdade >= BB3->BB3_IDAINI .And. nIdade <= BB3->BB3_IDAFIN
             nRet := BB3->BB3_VALFAI*nCoefic
         Endif   
   BB3->(DbSkip())
   Enddo
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da funcao...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(nRet)




Function PLRETMATR(lDigito)
DEFAULT lDigito := .T.
Return(BA1->(BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"-"+BA1_TIPREG+If(lDigito,"-"+BA1_DIGITO,"")))



Function PLCData(cData)
Return(Subs(cData,7,2)+"/"+Subs(cData,5,2)+"/"+Subs(cData,3,2))

Function GeraSQL()
LOCAL nIndice := 0
LOCAL cExpSQL := Space(00)

For nIndice := 1 To FCount()
    cExpSQL := cExpSQL + FieldName(nIndice)+", "
Next

cExpSQL := Subs(cExpSQL,1,Len(cExpSQL)-2)

Return(cExpSQL)


Function PLInitPad(cA,aH,aC)
LOCAL n, SX3Order := SX3->(IndexOrd()), cArea := Alias(), cCampo

SX3->(DbSetOrder(1))

For n := 1 To Len(aH)
    cCampo := AllTrim(aH[n,2])
    If ExistIni(cCampo)
       If SX3->(MsSeek(cA))
          While SX3->X3_ARQUIVO == cA
                If AllTrim(SX3->X3_CAMPO) == cCampo
                   aC[1,n] := InitPad(SX3->X3_RELACAO)
                Endif
          SX3->(DbSkip())
          Enddo
       Endif
    Endif

Next

SX3->(DbSetOrder(SX3Order))

DbSelectArea(cArea)

Return

Function PLRETGET(cCampo,aHdr,aCls,oBrowse)
DEFAULT aHdr := aHeader            
DEFAULT aCls := aCols                     

Return(aCls[n,Ascan(aHdr,{|a| AllTrim(a[2]) = AllTrim(cCampo)})])




Function PLRETFAM()
Return(BA3->(BA3_CODINT+"."+BA3_CODEMP+"-"+BA3_MATRIC))





Function PLGERCOB()

If ! Pergunte("PLA700",.T.)
   Return
Endif
   
cAno    := mv_par01
cMes    := mv_par02
cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)

PLSA760(cMatric,cAno,cMes)

Return




Function PLCONVMAT(cMatric)
Return(Subs(cMatric,1,3)+"."+Subs(cMatric,4,4)+"-"+Subs(cMatric,8,6))



Function PLREAJUS(cCodEmp,dDataInc,nRet,cAno,cMes,aRet)

BH9->(DbSetOrder(1))

If BH9->(MsSeek(xFilial("BH9")+cCodEmp))
   While ! BH9->(Eof()) .And. BH9->(BH9_FILIAL+BH9_CODEMP) == xFilial("BH9")+cCodEmp
         
         //Primeiro tratamento...         
         cAnoFim := Subs(BH9->BH9_DATFIN,1,4)
         cMesFim := Subs(BH9->BH9_DATFIN,5,2)
         
         cAnoIni := Subs(dtos(dDataInc),1,4)
         cMesIni := Subs(dtos(dDataInc),5,2)
         
         nRes    := PLSDIFANOS(cAnoIni,cMesIni,cAnoFim,cMesFim,"M")
         
         If nRes < 12
            BH9->(DbSkip())
            Loop
         Endif   

         //Segundo tratamento...
         cAnoFim := cAno
         cMesFim := cMes
         
         cAnoIni := Subs(dtos(dDataInc),1,4)
         cMesIni := Subs(dtos(dDataInc),5,2)
         
         nRes    := PLSDIFANOS(cAnoIni,cMesIni,cAnoFim,cMesFim,"M")
         
         If nRes >= 12
            lReaj := .F.
            nRea  := 0 
          If     cAno+cMes >= BH9->BH9_DATINI .And. BH9->BH9_DATINI >= subs(dtos(BA3->BA3_DATBAS),1,6)
                   If     cAno == Subs(BH9->BH9_DATINI,1,4)                         
                          If subs(dtos(dDataInc),5,2) >= Subs(BH9->BH9_DATINI,5,2) .And. cMes >= subs(dtos(dDataInc),5,2)
                             nRea :=((nRet*BH9->BH9_PERPAD)/100)               
                             nRet := nRet + nRea
                             lReaj:= .T.
                          Endif
                   ElseIf cAno >  Subs(BH9->BH9_DATINI,1,4)
                          nAnos := Val(cAno)-Val(Subs(BH9->BH9_DATINI,1,4))
                          If     nAnos > 1
                                 nRea := ((nRet*BH9->BH9_PERPAD)/100)                                         
                                 nRet := nRet + nRea
                                 lReaj:= .T.
                          ElseIf nAnos == 0
                                 If cMes >= subs(dtos(dDataInc),5,2)
                                    nRea := ((nRet*BH9->BH9_PERPAD)/100)               
                                    nRet := nRet + nRea
                                    lReaj:= .T.
                                 Endif   
                          ElseIf nAnos == 1
                                 If (cMes >= subs(dtos(dDataInc),5,2) .Or. subs(dtos(dDataInc),5,2) > Subs(BH9->BH9_DATINI,5,2) )
                                    nRea := ((nRet*BH9->BH9_PERPAD)/100)               
                                    nRet := nRet + nRea
                                    lReaj:= .T.
                                 Endif   
                          Endif   
                   Endif
            Endif
            If lReaj .And. ValType(aRet) == "A" .And. nRea > 0
               aadd(aRet,{"","FAMILIA",1,0,"ANS","REAJUSTE ANS REF "+BH9->BH9_DATINI,nRea,nRet})
            Endif   
        Endif             
               
   BH9->(DbSkip())
   Enddo   
Endif      

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLNOMUSR ³ Autor ³ Tulio Cesar           ³ Data ³ 15.09.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna o nome de um usuario de acordo com a matricula.    ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLNOMUSR(cMatric)

BA1->(DbSetOrder(2))

BA1->(MsSeek(xFilial("BA1")+cMatric))

Return(IF(BA1->(Found()),BA1->BA1_NOMUSR,"USUARIO NAO ENCONTRADO: MATRICULA "+cMatric))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLADCON  ³ Autor ³ Tulio Cesar           ³ Data ³ 15.09.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Aplica um aumento ou desconto a um usuario...              ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLADCON(cMatric,nRet,cAno,cMes,lDetalhado,aRet)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para buscar descontos para os usuarios desta familia...  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BI2->(DbSetOrder(1))

nRetAnt := nRet
nFator  := 0
cTipo   := ""
cDif    := 0

If BI2->(MsSeek(xFilial("BI2")+cMatric))
   While ! BI2->(Eof()) .And. BI2->(BI2_FILIAL+BI2_CODINT+BI2_CODEMP+BI2_MATRIC) == xFilial("BI2")+cMatric
   
         If cAno+cMes >= BI2->(BI2_ANOINI+BI2_MESINI) .And. cAno+cMes <= BI2->(BI2_ANOFIN+BI2_MESFIN)
            // Dentro dos parametros
         Else 
            BI2->(DbSkip())
            Loop
         Endif   
         
         nPerc  := 0
         cTipo  := BI2->BI2_TIPO
         cDif   := IF(BI2->BI2_PERC>0,"P","V")
         nFator := IF(BI2->BI2_PERC>0,BI2->BI2_PERC,BI2->BI2_VALOR)
         If     BI2->BI2_PERC > 0
                nPerc := (nRet*BI2->BI2_PERC)/100
                   
                If BI2->BI2_TIPO == "D"
                   nRet  := nRet - nPerc
                Else           
                   nRet  := nRet + nPerc
                Endif   
         ElseIf BI2->BI2_VALOR > 0
                nPerc := BI2->BI2_VALOR
                If BI2->BI2_TIPO == "D"
                   nRet  := nRet - BI2->BI2_VALOR
                Else
                   nRet  := nRet + BI2->BI2_VALOR
                Endif   
         Endif       
         
         If lDetalhado
            aadd(aRet,{"","FAMILIA",nFator,0,"BI2",If(cTipo=="D","DESCONTO ","ACRESCIMO ")+IF(cDif=="P"," EM %"," EM R$"),nPerc,nRet})
         Endif   

   BI2->(DbSkip())
   Enddo
Endif   

Return(nRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLRETPOS ³ Autor ³ Tulio Cesar           ³ Data ³ 16.05.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorno posicao em um aHeader                              ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLRETPOS(cCampo,aHdr,lHelp)
LOCAL nCol
DEFAULT aHdr := aHeader
DEFAULT lHelp := .F.

nCol := Ascan(aHdr,{|a| AllTrim(a[2]) == AllTrim(cCampo)})

Return(nCol)


Function PLMontVen(nDia,cMes,cAno)

LOCAL dVencto  := ctod("")

While Empty(dVencto)
      dVencto  := ctod(StrZero(nDia,2)+"/"+cMes+"/"+Subs(cAno,3,2))
      If Empty(dVencto)
         nDia     := nDia - 1
      Endif   
Enddo    

Return(dVencto)



Function PLSRETInt(cCodTip,cCodInt)
LOCAL nOrdOld := BA0->(IndexOrd())
LOCAL nRegOld := BA0->(Recno())
LOCAL cRet    := ""

BA0->(DbSetOrder(1))
If BA0->(MsSeek(xFilial("BA0")+cCodTip+cCodInt))
   cRet := BA0->BA0_NOMINT
Else  
   cRet := Space(Len(BA0->BA0_NOMINT))
Endif      

BA0->(DbGoTo(nRegOld))
BA0->(DbSetOrder(nOrdOld))

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSQTDUSR ³ Autor ³ Tulio Cesar       ³ Data ³ 08.08.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorno a quantidade de usuarios de um contrato...     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Padua       ³01/08/02³      ³Novo para contar por tipo de usuario  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
nTipo : Define se o Tipo do Usuario ou usado como grau de Parentesco:
0 - Todos Usuarios
1 - Titular , Dependente, Agregado .. etc
2 - Filho, Filha, Esposa.. etc          
/*/
Function PLSQTDUSR(cMatric,nTipo,cTipUsr)
LOCAL nQtdUsr    := 0         
LOCAL aQtdUsr    := {}
LOCAL cSQL       := "" 
Default cTipUsr  := "" 
Default nTipo    := 0  
                      
   cSQL := " SELECT BA1_TIPUSU,BA1_GRAUPA,BA1_MOTBLO FROM "+RetSQLName("BA1")+" WHERE "
   cSQL += " BA1_FILIAL = '"+xFilial("BA1")+"' AND "
   cSQL += " BA1_CODINT = '"+Substr(cMatric,1,4)+"' AND "
   cSQL += " BA1_CODEMP = '"+Substr(cMatric,5,4)+"' AND "                                       
   cSQL += " BA1_MATRIC = '"+Substr(cMatric,9,6)+"' AND "
   cSQL += " D_E_L_E_T_= '' "
   
   cSQL := ChangeQuery(cSQL)
   DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSQL),"TrbBA1",.T.,.T.)

   While !TrbBA1->(Eof()) 
         If Empty(TrbBA1->BA1_MOTBLO)
            if nTipo <> 0
              if Upper(cTipUsr) == "VET"
                 nTemp := aScan(aQtdUsr,{|x|x[1]==if(nTipo==1,TrbBA1->BA1_TIPUSU,TrbBA1->BA1_GRAUPA)})
                 if nTemp > 0  
                     aQtdUsr[nTemp,2] := aQtdUsr[nTemp,2] + 1
                 Else
                     aadd(aQtdUsr,{if(nTipo==1,TrbBA1->BA1_TIPUSU,TrbBA1->BA1_GRAUPA),1})
                 Endif    
              Elseif if(nTipo==1,TrbBA1->BA1_TIPUSU,TrbBA1->BA1_GRAUPA) == cTipUsr
                 nQtdUsr ++
              Endif
            Else     
               nQtdUsr ++
            Endif   
         Endif   
   TrbBA1->(DbSkip())
   Enddo
   TrbBA1->(DbCloseArea())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se foi pedido um vetor, retorno o mesmo..                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Upper(cTipUsr) == "VET"
   Return(aQtdUsr)
Endif
Return(nQtdUsr)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLQTUSEMP ³ Autor ³ Antonio de Padua  ³ Data ³ 11.09.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorno a quantidade de usuarios de um sub-contrato... ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLQTUSEMP(	cCodInt,cCodEmp,cNumCon,cVerCon,;
					cSubCon,cVerSub,cForPag,cCpoForPag,;
					cMes,cAno)
					
LOCAL aQtdUsr   := {}
LOCAL cSQL      := ""
Local lPorFor 	:= cForPag <> Nil

DEFAULT cCpoForPag := "BA3_FORPAG"
DEFAULT cMes := ''
DEFAULT cAno := ''

cSQL :=	" SELECT BA1_CODINT, BA1_CODEMP, BA1_CONEMP, BA1_VERCON, BA1_SUBCON, " 
cSql += " BA1_VERSUB, BA1_TIPUSU, BA1_MATRIC, BA1_TIPREG,BA1_DIGITO, BA1_SEXO, BA3_FORPAG, BA1.R_E_C_N_O_ REG "
cSql += " FROM "+RetSqlName("BA1")+" BA1, "+RetSqlName("BA3")+" BA3 "
cSql += " WHERE BA1_FILIAL = '" + xFilial("BA1") + "' "
cSql += " AND BA1_CODINT = '" +cCodInt+"' "
cSql += " AND BA1_CODEMP = '" +cCodEmp+"' "

If ! Empty(cNumCon)
	cSQL +=	" AND BA1_CONEMP = '" + cNumCon + "' "
	cSql += " AND BA1_VERCON = '" + cVerCon + "' "
Endif
If ! Empty(cSubCon)
	cSQL += " AND BA1_SUBCON = '" + cSubCon + "' " 
	cSql += " AND BA1_VERSUB = '" + cVerSub + "' "
Endif

cSQL +=	" AND BA1.D_E_L_E_T_ = ' ' "
cSQL += " AND BA3.D_E_L_E_T_ = ' ' " 
cSQL += " AND BA3.BA3_FILIAL = BA1.BA1_FILIAL " 
cSQL +=	" AND BA3.BA3_CODINT = BA1.BA1_CODINT " 
cSQL += " AND BA3.BA3_CODEMP = BA1.BA1_CODEMP " 
cSQL += " AND BA3.BA3_MATRIC = BA1.BA1_MATRIC " 
cSQL += " AND BA3.BA3_CONEMP = BA1.BA1_CONEMP " 
cSQL += " AND BA3.BA3_VERCON = BA1.BA1_VERCON " 
cSQL += " AND BA3.BA3_SUBCON = BA1.BA1_SUBCON " 
cSQL += " AND BA3.BA3_VERSUB = BA1.BA1_VERSUB "

If lPorFor
	cSQL += " AND BA3." + cCpoForPag + " = '" + cForPag + "' "
Endif

cSQL := ChangeQuery(cSQL)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSQL),"TrbBA1",.T.,.T.)

While !TrbBA1->(Eof())
	// Posiciona o cadastro de usuarios...
	//BA1->( dbGoto(TrbBA1->REG) )
	
	// Analisa se usuario esta ativo na competencia informada...
	If 	AnalisaUsr(cAno,cMes,nil, nil,nil) [1]
		aadd( aQtdUsr,{TrbBA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),;
			TrbBA1->REG,;
			TrbBA1->BA1_SEXO,;
			TrbBA1->BA1_TIPUSU} )
	Endif
	
	TrbBA1->(DbSkip())
Enddo
TrbBA1->(DbCloseArea())

Return(aQtdUsr)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PlsVldGd  ³ Autor ³ Eduardo Motta         ³ Data ³ 13.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Controla a mudanca de linha da getdados                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PlsVldGd(oBrw,aCampo)                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±|          |oBrw = Browse onde sera feita a pesquisa                    |±±
±±|ÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|±±
±±|          |uCampo=Vetor com os campos a validar.                       |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlsVldGd(uCampos,lHelp,xaCols,lInsert,bCond,cAliVig,xaHeader)
Local aCamp 	:= {}
Local nI 		:= 0
Local nJ 		:= 0
LOCAL nPosCOL   := 0
Local aValores 	:= {}
Local lRet 		:= .T.
Local lAchou 	:= .F.
Local nStart    := 0
LOCAL nLiOld    := 0
DEFAULT lInsert := .F.
DEFAULT lHelp 	:= .T.
DEFAULT uCampos := SubStr(ReadVar(),4)
DEFAULT xaCols 	:= aCols
DEFAULT bCond	:= {||.T.}
DEFAULT cAliVig := ''
DEFAULT xaHeader := aHeader

If ValType(uCampos) == "C"
   aadd(aCamp,GdFieldPos(AllTrim(uCampos),xaHeader))
ElseIf ValType(uCampos) == "A"
   aCamp := {}
   For nI := 1 to Len(uCampos)
      aadd(aCamp,GdFieldPos(AllTrim(uCampos[nI]),xaHeader))
   Next
Else  // nao foi passado o parametro uCampos (ERRO)
   Return NIL      
EndIf
For nI := 1 to Len(aCamp)
   aadd(aValores,&("M->"+AllTrim(xaHeader[aCamp[nI],2])))
Next       
        
nLiOld := N
If lInsert .And. N <> Len(xaCols)
   N := Len(xaCols)
EndIf

nStart := 1
While .T.
   nPosCOL := 0
   nPosCOL := AScan(xaCols,{|x|CompCols(x,aCamp,aValores)},nStart)
   If nPosCOL # N
      Exit
   EndIf
   nStart := nPosCOL+1
EndDo 
If nPosCOL # 0 .And. Eval(bCond)
   lRet := .F.
EndIf

If lHelp .and. !lRet
   Help(" ",1,"JAGRAVADO")
EndIf
N := nLiOld

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CompCols  ³ Autor ³ Eduardo Motta         ³ Data ³ 25.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao auxiliar para a PlsVldGD                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CompCols(aLinha,aCampos,aValores)                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CompCols(aLinha,aCamp,aValores)
Local lRet := .T.
Local nJ   := 0
If aLinha[Len(aLinha)]  // se a linha estiver DELETADA
   Return .F.
EndIf
For nJ := 1 to Len(aCamp)
   If aLinha[aCamp[nJ]] # aValores[nJ]
      lRet := .F.
      Exit
   EndIf
Next
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSMLIB   ºAutor  ³Microsiga           º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSRelTop()
LOCAL lRet := .T.
#IFNDEF TOP
         MsgInfo("Este relatorio somente esta disponivel para ambiente TopConnect")
         lRet := .F.
#ENDIF         
Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSParSQL ºAutor  ³Tulio Cesar         º Data ³  12/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Parce entre SQL/ORACLE usada no PLSQUERY!                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSParSQL(cFilADV)

cFilADV := StrTran(Upper(cFilADV),".AND."," AND ")
cFilADV := StrTran(cFilADV,".OR."," OR ")
cFilADV := StrTran(cFilADV,"=="," = ")
cFilADV := StrTran(cFilADV,'"',"'")
cFilADV := StrTran(cFilADV,'$'," IN ")
cFilADV := StrTran(cFilADV,'ALLTRIM(',"LTRIM(")
cFilADV := StrTran(cFilADV,'DTOS(',"(")

Return(cFilADV)

Function PLSAvaSQL(cSQL)
cSql := PLSConSQL(cSQL)
Return(cSQL)

/*/{Protheus.doc} PLSCPOSSE1
@author  PLS TEAM
@version P12
@since   25/05/04
/*/
function PLSCPOSSE1(cTipo, lLegenda)

local aCabFin  := {}
local cCposE1  := allTrim(getNewPar("MV_PLCPSE1",'E1_VENCREA,E1_SALDO,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_BAIXA,E1_PLNUCOB')) + ",E1_VENCREA,E1_SALDO,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_BAIXA,E1_PLNUCOB" 
local aTrb     := StrTokArr(cCposE1, "," )
local nCont    := 0
local nPosBaixa:=0

Default lLegenda := .F.

if select("BKP") != 0
    
    SX3->(DbSetOrder(2))
    BKP->(DbSetOrder(1))
    BKP->(DbGoTop())
   
    while ! BKP->(Eof())         

         if SX3->(MsSeek(BKP->BKP_CAMPO))
            
            if cTipo == "C" .And. BKP->BKP_CONTRA == "S"

                  aadd(aCabFin,{trim(X3TITULO()),SX3->X3_CAMPO,;
                                SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
                                SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_ORDEM})
            
            elseIf cTipo == "A" .And. BKP->BKP_ATEND == "S"                

                  aadd(aCabFin,{trim(X3TITULO()),SX3->X3_CAMPO,;
                                SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
                                SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_ORDEM})

            endIf        

         endIf   

    BKP->(DbSkip())
    endDo

endIf    

SX3->(DbSetOrder(2))

//Verifica se existem campos que sao obrigatorios no browse...        
for nCont := 1 to Len(aTrb)

    if PLRETPOS(aTrb[nCont], aCabFin, .f.) == 0

       if SX3->( msSeek(aTrb[nCont]))
      
          aadd(aCabFin,{trim(X3TITULO()),SX3->X3_CAMPO,;
                         SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
                         SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_ORDEM})

        endIf

    endIf

next

//Inclusão dos dias de atraso para atender a nonos clientes
If cTipo == "A" 
   nPosBaixa:= Ascan(aCabFin,{|x| AllTrim(x[2]) == "E1_BAIXA"})
   If nPosBaixa > 0
      nOrdBaixa := StrZero(Val((aCabFin[nPosBaixa,11]))+1,2)
      aadd(aCabFin,{'Dias atraso','E1_ATRPLS','@!',5,0,'','','','','',nOrdBaixa})
   Endif
Endif

// Legenda dos Títulos
If lLegenda
   aadd(aCabFin, {"Status", "STATUS", '@BMP', 6, 0, "", "", "", "", "", "00"})
EndIf

aSort(aCabFin,,, { | x,y | x[11] < y[11] })

return(aCabFin)

Function PLSGetVer()
Return(strTran(cVer,".",""))

Function PlsSQLOrd(cOrdem)

cOrdem := STRTran(cOrdem,"+",",")
cOrdem := StrTran(cOrdem,"DTOS(","")
cOrdem := StrTran(cOrdem,")","")

Return(cOrdem)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSVERBLO ³ Autor ³ Michele Tatagiba      ³ Data ³ 29.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se o usuario esta bloqueado e se pode fazer       ³±±
±±|          |algum procedimento                                          |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function PLSVERBLO(cCodInt,cCodEmp,cMatric,cTipReg)

LOCAL lRet    := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa se o usuario/contrato esta bloqueado...                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                    
BA3->(DBSetOrder(1))
If BA3->(MsSeek(xFilial("BA3")+cCodInt+cCodEmp+cMatric))
   If Empty(BA3->BA3_MOTBLO)
      BA1->(DBSetOrder(2))
      If BA1->(MsSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+cTipReg))
         If !Empty(BA1->BA1_MOTBLO)
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Se o usaurio  estiver bloqueado, vou verificar se o codigo do bloqueio   ³
            //³ permite que o usuario utilize o plano                                    ³      
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                    
            BG3->(DBSetOrder(1))
            If BG3->(MsSeek(xFilial("BG3")+BA1->BA1_MOTBLO))
               If BG3->BG3_PERPLA == "0" //0==Nao;1==Sim
                  lRet := .F.
                  MsgStop(AllTrim(BA1->BA1_NOMUSR)+Chr(13)+Chr(13)+"USUARIO(A) BLOQUEADO(A) EM "+dtoc(BA1->BA1_DATBLO)+Chr(13)+Chr(13)+"MOTIVO : "+Posicione("BG3",1,xFilial("BG3")+BA1->BA1_MOTBLO,"BG3_DESBLO"))
               Endif
            Else
               Help("",1,"PLSVERBLO")
               lRet := .F.
            Endif             
                        
         Endif
      Endif
   Else      
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Se o contrato estiver bloqueado, vou verificar se o codigo do bloqueio   ³
      //³ permite que o usuario utilize o plano                                    ³      
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                    
      BG1->(DBSetOrder(1))
      If BG1->(MsSeek(xFilial("BG1")+BA3->BA3_MOTBLO))
         If BG1->BG1_PERPLA == "0" //0==Nao;1==Sim
            lRet := .F.
            MsgStop(" CONTRATO BLOQUEADO EM "+dtoc(BA3->BA3_DATBLO)+Chr(13)+Chr(13)+"MOTIVO : "+Posicione("BG1",1,xFilial("BG1")+BA3->BA3_MOTBLO,"BG1_DESBLO"))
         Endif
      Else
         Help("",1,"PLSVERBLO")
         lRet := .F.
      Endif
   Endif
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSBLOAUT ³ Autor ³ Michele Tatagiba      ³ Data ³ 29.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se o motivo de bloqueio do contrato e automatico  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function PLSBLOAUT(cCodBlo,nTipo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nTipo = 1  -> Bloqueio de usuario  (BG3)                        ³
//³ nTipo = 2  -> Bloqueio de contrato (BG1)                        ³      
//³ nTipo = 3  -> Bloqueio de Rede Referenciada (BAP)               ³      
//³ nTipo = 4  -> Bloqueio de Opcional					               ³      
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                    
LOCAL lRet    := .F.
LOCAL cTipBlo := "1"	//	Ativo
LOCAL cMotBlo := ""
DEFAULT nTipo := 1

If nTipo == 1
	BG3->(DBSetOrder(1))
	IF BG3->(MsSeek(xFilial() + BA1->BA1_MOTBLO))
		cTipBlo := BG3->BG3_TIPBLO	//	Status Atual do Usuário
	ENDIF
	
	If readvar() == "M->BF4_MOTBLO"
		cMotBlo := oBrwOUsu:aCols[oBrwOUsu:Linha()][PLRETPOS("BF4_MOTBLO",oBrwOUsu:aHeader)]		
		If BG3->(MsSeek(xFilial() + cMotBlo)) .And. !Empty(cMotBlo)
			cTipBlo := BG3->BG3_TIPBLO	//	Status Atual do Opcional
		Endif
	EndIf
	
	
	If BG3->(MsSeek(xFilial() + cCodBlo))	//	Formas de (Des)Bloqueio de Usuário
		If BG3->BG3_PERBLO == "1"
			IF cTipBlo <> BG3->BG3_TIPBLO
				lRet := .T.
			ENDIF
		Endif
	Endif
ElseIf nTipo == 2
		BG1->(DBSetOrder(1))
		If BG1->(MsSeek(xFilial("BG1") + cCodBlo))	//	Formas de (Des)Bloqueio de Família
			If BG1->BG1_PERBLO == "1"
				lRet := .T.
			Endif
		Endif
ElseIf nTipo == 3
	BAP->(DBSetOrder(1))
	If BAP->(MsSeek(xFilial("BAP") + cCodBlo))	//	Formas de (Des)Bloqueio de RDA
		If BAP->BAP_PERBLO == "1"
			lRet := .T.
		Endif
	Endif
ElseIf nTipo == 4
	BG3->(DBSetOrder(1))
	cMotCols := oBrwOUsu:aCols[oBrwOUsu:Linha(),oBrwOUsu:PlRetPos("BF4_MOTBLO")]
	IF !Empty(Alltrim(cMotCols)) .And. BG3->(MsSeek(xFilial("BG3") + cMotCols))
		cTipBlo := BG3->BG3_TIPBLO	//	Status Atual do Opcional
	Else
		cTipBlo := "-1" //Não encontrou
	ENDIF
	If BG3->(MsSeek(xFilial("BG3") + cCodBlo))	//	Formas de (Des)Bloqueio de Usuário
		If BG3->BG3_PERBLO == "1"
			IF cTipBlo <> BG3->BG3_TIPBLO .OR. Empty(M->BF4_TIPBLO)
				M->BF4_TIPBLO := BG3->BG3_TIPBLO
				lRet := .T.
			Endif
		Endif
	Endif

Endif
If !lRet
	IF nTipo == 1
		MSGINFO("O Usuário já está " + IIF(cTipBlo == '1', "des", "") + "bloqueado", "Código Inválido!")
	ELSEIF nTipo == 4
		MSGINFO("O Opcional já está " + IIF(cTipBlo == '1', "des", "") + "bloqueado", "Código Inválido!")
	ELSE
		Help("",1,"PLSBLOAUT")
	ENDIF
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSESPVid ºAutor  ³Geraldo Felix Juniorº Data ³  09/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza endereco do usuario de acordo com as opcoes do     º±±
±±º          ³campo BA1_ORIEND( Origem do endereco )                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSESPVid(nRegBA1,nRegBTS, lLog)
LOCAL cCpo01                                         
LOCAL cCpo02          
LOCAL cCampo
LOCAL cCpo  
LOCAL aStruBTS := BTS->(DbStruct())
LOCAL lFldOri  := BA1->( FieldPos("BA1_ORIEND") ) > 0
                    
DEFAULT lLog := .F.

BA1->(DbGoTo(nRegBA1))
BTS->(DbGoTo(nRegBTS))
     
If !lLog
	BA1->(RecLock("BA1",.F.))
Else
	RegToMemory("BA1", .F., .F. )
Endif

SX3->(DbSetOrder(1))
If SX3->(MsSeek("BA1"))
	While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == "BA1"
		cCpo := AllTrim(SX3->X3_CAMPO)

		If cCpo $ "BA1_FILIAL,BA1_ORIEND" .Or. BA1->(FieldPos(cCpo)) == 0
			SX3->(DbSkip())
			Loop
		Else
			// Trata o endereco... so leva o endereco quando o campo BA1_ORIEND existir e a origem do
			// endereco for a VIDA.
			If cCpo $ "BA1_CEPUSR, BA1_ENDERE, BA1_NR_END, BA1_COMEND, BA1_BAIRRO, BA1_MUNICI, BA1_ESTADO"
				If lFldOri
					If BA1->BA1_ORIEND <> '4'
						SX3->(DbSkip())
						Loop
					Endif
				Else
					SX3->(DbSkip())
					Loop
				Endif
			Endif

			If !lLog
				cCpo01	:= "BA1->"+cCpo
			Else
				cCpo01	:= "M->"+cCpo
			Endif
			
			cCpo02 		:= "BTS->BTS_"+Subs(cCpo,5,10)			
			cCampo 		:= "BTS_"+Subs(cCpo,5,10)

		      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    	  //³ Criada a trava de alteracoes para conteudo vazio, pois ao replicar o BTS ³
		      //³ para o BA1 ele estava zerando os campos nao preenchidos. Chamado TEJERW. ³      
		      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                    
			
			If Ascan(aStruBTS,{|x| cCampo == x[1] }) > 0 .And. IIf(! ValType(cCpo02) $ "L|N", !Empty(&cCpo02), .T.)
				&cCpo01 := &cCpo02
			Endif
		Endif
		
		SX3->(DbSkip())
	Enddo
	
	If lLog 

		PLUPTENC("BA1",4,.T.,.T.)		
	Endif
Endif    

If !lLog
	BA1->(MsUnLock())
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSVLDCOL  ³ Autor ³ Michele Tatagiba    ³ Data ³ 22.03.02 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Verifica se o conteudo do campo que esta sendo digitado    ³±±±
±±³          ³ ja existe no acols.                                        ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Parametros³ aCampos => Todos os campos que precisam ser verificados    ³±±±
±±³          ³ no acols. Ex: {"XXX","YYY","RRR"}                          ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLDCOL(aCampos,lHelp)
           
LOCAL lRet    := .T.
LOCAL nInd    := 1
LOCAL nQtd    := 0,nI

DEFAULT lHelp := .T.

For nInd := 1 To Len(aCols)
    nQtd := 0
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Analiso campos a campo do vetor para verificar a igualdade                            ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    For nI := 1 To Len(aCampos)
        If &("M->"+aCampos[nI]) == aCols[nInd,PlRetPos(aCampos[nI])] .And. !Empty(&("M->"+aCampos[nI])) .And.;
           !aCols[nInd,Len(aHeader)+1] .And. nInd <> n
           nQtd ++
        Endif
    Next
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Indico se os campos sao iguais                    ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If nQtd == Len(aCampos)
       lRet := .F.
       Exit
    Endif
Next

If !lRet .And. lHelp
   Help("",1,"PLSVLDCOL")
Endif

Return(lRet)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSSERVER  ³ Autor ³ Tulio Cesar          ³ Data ³ 28.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Verifica se o sistema esta rodando no remote ou no server.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSSERVER()
Return(.F.)



Function PLSENCBAR(oDlg,bOk,bCancel,lMessageDel,aMoreFunc)
Local oBar
Local bSet15
Local bSet24
Local lOk
Local oBtOk
Local oBtCan
Local lVolta  := .F.                   
Local nInd
Local lConLog          
DEFAULT aMoreFunc := {}

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg

For nInd := 1 To Len(aMoreFunc)
         If     nInd == 1
                DEFINE BUTTON RESOURCE aMoreFunc[1,1] OF oBar GROUP ACTION Eval(aMoreFunc[1,2])  TOOLTIP OemToAnsi(aMoreFunc[1,3])
         ElseIf nInd == 2
                DEFINE BUTTON RESOURCE aMoreFunc[2,1] OF oBar GROUP ACTION Eval(aMoreFunc[2,2])  TOOLTIP OemToAnsi(aMoreFunc[2,3])            
         ElseIf nInd == 3
                DEFINE BUTTON RESOURCE aMoreFunc[3,1] OF oBar GROUP ACTION Eval(aMoreFunc[3,2])  TOOLTIP OemToAnsi(aMoreFunc[3,3])            
         ElseIf nInd == 4
                DEFINE BUTTON RESOURCE aMoreFunc[4,1] OF oBar GROUP ACTION Eval(aMoreFunc[4,2])  TOOLTIP OemToAnsi(aMoreFunc[4,3])            
         ElseIf nInd == 5
                DEFINE BUTTON RESOURCE aMoreFunc[5,1] OF oBar GROUP ACTION Eval(aMoreFunc[5,2])  TOOLTIP OemToAnsi(aMoreFunc[5,3])            
         ElseIf nInd == 6
                DEFINE BUTTON RESOURCE aMoreFunc[6,1] OF oBar GROUP ACTION Eval(aMoreFunc[6,2])  TOOLTIP OemToAnsi(aMoreFunc[6,3])            
         ElseIf nInd == 7
                DEFINE BUTTON RESOURCE aMoreFunc[7,1] OF oBar GROUP ACTION Eval(aMoreFunc[7,2])  TOOLTIP OemToAnsi(aMoreFunc[7,3])            
         ElseIf nInd == 8
                DEFINE BUTTON RESOURCE aMoreFunc[8,1] OF oBar GROUP ACTION Eval(aMoreFunc[8,2])  TOOLTIP OemToAnsi(aMoreFunc[8,3])            
         ElseIf nInd == 9
                DEFINE BUTTON RESOURCE aMoreFunc[9,1] OF oBar GROUP ACTION Eval(aMoreFunc[9,2])  TOOLTIP OemToAnsi(aMoreFunc[9,3])            
         ElseIf nInd == 10
                DEFINE BUTTON RESOURCE aMoreFunc[10,1] OF oBar GROUP ACTION Eval(aMoreFunc[10,2])  TOOLTIP OemToAnsi(aMoreFunc[10,3])            
         ElseIf nInd == 11
                DEFINE BUTTON RESOURCE aMoreFunc[11,1] OF oBar GROUP ACTION Eval(aMoreFunc[11,2])  TOOLTIP OemToAnsi(aMoreFunc[11,3])            
         ElseIf nInd == 12
                DEFINE BUTTON RESOURCE aMoreFunc[12,1] OF oBar GROUP ACTION Eval(aMoreFunc[12,2])  TOOLTIP OemToAnsi(aMoreFunc[12,3])            
         Endif
Next              

oBar:nGroups += 6
DEFINE BUTTON oBtOk RESOURCE "Ok" OF oBar GROUP ACTION ( If(type("cTudoOk") == "U","AllwaysTrue()",cTudoOk), lLoop:=lVolta,lOk:=Eval(bOk)) TOOLTIP "Ok - <Ctrl-O>"  //"OK"###"Ok - <Ctrl-O>"
SetKEY(15,oBtOk:bAction)
oDlg:bSet15 := oBtOk:bAction
     
DEFINE BUTTON oBtCan RESOURCE "Cancel" OF oBar ACTION ( lLoop:=.f.,Eval(bCancel),ButtOff(bSet15,bSet24,.T.)) TOOLTIP "Cancelar - <Ctrl-X>"  //"CANCEL"###"Cancelar - <Ctrl-X>"
SetKEY(24,oBtCan:bAction)
oDlg:bSet24 := oBtCan:bAction

oBar:bRClicked := {|| AllwaysTrue()}

Return nil


Static Function ButtOff(bSet15,bSet24,lOk)

DEFAULT lOk := .t.

if lOk
    SetKey(15,bSet15)
    SetKey(24,bSet24)
Endif

Return .t.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSFUNCEP  ³ Autor ³ Michele Tatagiba    ³ Data ³ 14.05.02 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Verifica se o campo endereco do CEP esta preenchido        ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Parametros³ cEnd = Campo que se deseja comparar com o do Arquivo BC9,  ³±±±
±±³          ³        e campo do endereco.                                ³±±±
±±³          ³ cBC9 = Campo respectivo do BC9 respectivo ao cEnd.         ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSFUNCEP(cEnd,cBC9,lPergunt)
                   
LOCAL lPreenche := .F.
LOCAL cExpre1   := ""
LOCAL cExpre2   := ""           
LOCAL cExpre3   := ReadVar()      
LOCAL cExpre4   := "BC9->BC9_END" 
LOCAL cExpre5
LOCAL cAlias    := Subs(cExpre3,4,3)
LOCAL cAux      := ""
LOCAL nInd      := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o CEP estiver em branco, nao preciso verificar nada.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(&(cExpre3))
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Analiso o conteudo do campo cEnd separando o que e tem que ser comparado e o que e endereco ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   For nInd := 1 To Len(cEnd)
       If Subs(cEnd,nInd,1) == ","
          cExpre1 := "M->"+cAlias+"_"+cAux
          cAux    := ""
       Else
          cAux += Subs(cEnd,nInd,1) 
       Endif
   Next
                             
   cExpre2 := "M->"+cAlias+"_"+cAux
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Se e a primeira vez que se digita algum CEP, nao preciso verificar nada  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If Empty(&(cExpre2))
      Return(.T.)
   Endif

   If BC9->(MsSeek(xFilial("BC9")+&cExpre3))
      cExpre5 := "BC9->BC9_"+cBC9
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Verifico se o campo endereco do Alias e igual ao do BC9 pelo CEP que foi digitado.          ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
      If AllTrim(&cExpre2) == AllTrim(&cExpre4)
         If AllTrim(&cExpre1) <> AllTrim(&cExpre5)
            lPreenche := .T.
         Endif
      Endif
      
      If lPergunt
         lPreenche := MsgYesNo("Confirma a alteracao dos dados referentes a Endereco?")
      EndIf
   EndIf
EndIf

Return(lPreenche)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLNUMINT ³ Autor ³ Tulio Cesar           ³ Data ³ 29.05.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna o numero da proxima internacao...                  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLNUMINT(cOpeMov,cAno,cMes)
Return(PlNewNAut("BE4",cOpeMov,cAno,cMes,K_Incluir,""))
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Objeto     ³ PLSRETACOM ³ Autor ³ Michele Tatagiba     ³ Data ³ 11.09.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri??o  ³ Verifica qual a acomodacao permitida para o usuario           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Advanced Protheus 7.10                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU?AO INICIAL               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador ³ Data   ³ BOPS ³  Motivo da Altera??o                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSRETACOM(cCodInt,cCodPla,cVerPla)

LOCAL cAcomod := ""

BI3->(DBSetOrder(1))
If BI3->(MsSeek(xFilial("BI3")+cCodInt+cCodPla+cVerPla))
   cAcomod := BI3->BI3_CODACO
Endif

Return(cAcomod)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSVIGPAD  ³ Autor ³ Michele Tatagiba    ³ Data ³ 05.11.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mensagem para quando a data vigencia padrao for maios que  ³±±
±±³          ³ a data de vigencia que se quer colocar.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSVIGPAD                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀParametros³ cExpre = Expressao que vai ser comparada                   Ù±±
±±À          ³ cCadas = Nome do cadastro para a mensagem                  Ù±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVIGPAD(cExpre,cCadas)

LOCAL lRet := .T.

If !&(cExpre)
   MsgInfo("A data de vigencia padrao de "+cCadas+" e maior que a data de vigencia que esta sendo informada.")
   lRet := .F.
Endif

Return(lRet)


Function PLDIFANOS(cAnoIni,cMesini,cAnoFim,cMesFim,cModelo)

nAnos   := Val(cAnoFim)-Val(cAnoIni)
nMeses  := Val(cMesFim)-Val(cMesIni)
         
If     nMeses > 0
       nRes    := (nAnos*12)+nMeses
ElseIf nMeses < 0
       nRes    := (nAnos*12)-ABS(nMeses)
ElseIf nMeses == 0
       nRes    := nAnos*12     
Endif
Return(IF(cModelo=="M",nRes,nRes/12))


Function PLSTRMES(dData)
Return(subs(dtos(dData),5,2))

Function PLSTRANO(dData,lAno2000)
Default lAno2000 := .F.

If ! lAno2000
   cRet := subs(dtos(dData),3,2)
Else   
   cRet := subs(dtos(dData),1,4)
Endif
   
Return(cRet)

Function PLFilSRA(cCodEmp)

BG9->(DbSetOrder(1))

If ! BG9->(DbSeek(xFilial("BG9")+cCodEmp))
   Return("XX")
Endif

If BG9->BG9_FILESP == "1"
   Return(BG9->BG9_FILSRA)
Else
   Return(xFilial("SRA"))
Endif   


Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSMUDCOD  ³ Autor ³ Daher			    ³ Data ³ 25.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Dado um procedimento ele faz um de/para na tabela de precos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSMUDCOD                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀParametros³ cExpre = Expressao que vai ser comparada                   Ù±±
±±À          ³ cCadas = Nome do cadastro para a mensagem                  Ù±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSMUDCOD(cAlias)

LOCAL cCodPro := &("M->"+cAlias+"_CODPRO")
LOCAL cCodInt := PlsIntPad()
LOCAL aDadRDA := PlsGetRda()
LOCAL cCodRDA := ""                    
LOCAL cCodLoc := ""
LOCAL cCodTab := ""
    

If Len(aDadRda) >= 12
	cCodRDA := aDadRda[2]         
	cCodLoc := aDadRda[12]         
Else
	return (.T.)   
Endif
	
If SeekBB8Esp(cCodRDA,cCodInt,cCodLoc) .And. ! Empty(BB8->BB8_TABPRE)
		cCodTab := BB8->BB8_TABPRE
Endif               

BC6->(DbSetOrder(2))	
If BC6->(MsSeek(xFilial("BC6")+cCodInt+cCodRDA+cCodTab+cCodPro))
	cCodPro :=	BC6->BC6_CODPRO
Endif                    

&("M->"+cAlias+"_CODPRO") := cCodPro

return (.T.)   


Static Function SeekBB8Esp(cCodRDA,cCodInt,cCodLoc)
LOCAL lRet := .F.

lRet := BB8->(MsSeek(xFilial("BB8")+cCodRDA+cCodInt+Subs(cCodLoc,1,3)))

If ExistBlock("PLSBB8SK")
   lRet := ExecBlock("PLSBB8SK",.F.,.F.,{lRet,cCodRda,cCodInt,Subs(cCodLoc,1,3)})
Endif


Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSBIGVLD  ³ Autor ³ Totvs		     		   ³ Data ³ 25.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função Generica para validacoes de campo que nao cabem no X3_VALID³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSBIGVLD()                                                 		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 																	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBIGVLD()

LOCAL lRet := .T.

DO CASE

	CASE ReadVar() == "M->BB2_CODPSA"
		lRet := (ExistCpo("BR8",M->BB2_CODPAD+M->BB2_CODPSA,1) .And. PLSVLDGD({"BB2_CODPSA","BB2_CODPAD"},,,) .And. PLSGATNIV(M->BB2_CODPAD,M->BB2_CODPSA,"BB2"))

	CASE ReadVar() == "M->BBI_CODPRO"
		lRet := (PlsSeek("BI3",1,M->BBI_CODINT+M->BBI_CODPRO+M->BBI_VERSAO,"BBI_DESPRO","BI3_DESCRI") .and. PlsVldGd({"BBI_CODINT","BBI_CODPRO","BBI_VERSAO"}))

ENDCASE

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSAValDat ³ Autor ³ Victor Ferreira   		   ³ Data ³ 09.08.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao generica utilizada para validacao de campos de data        ³±±
±±³          ³ inicial e final. E feita uma validacao para que o sistema possa   ³±±
±±³          ³ impedir que o usuario cadastre datas finais menores que iniciais. ³±±
±±³          ³ O retorno e uma variavel de tipo logico com o valor .F.   		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSAValDat(dDatIn,dDatFin,lFunObr)                          		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ VARIAVEL		TIPO	CONTEUDO A SER INFORMADO   					 ³±±
±±³          ³																	 ³±±
±±³          ³ dDatIn		D		Memoria do campo de Data Inicial			 ³±±
±±³          ³ dDatFin		D		Memoria do campo de Data Final				 ³±±
±±³          ³ cMsg			C		Mensagem a ser apresentada no MsgInfo		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSAValDat(dDatIn,dDatFin,cMsg)

Local lRet := .T.
Local cDarFin

cDarFin := ALLTRIM(DTOS(dDatFin))

If !Empty(cDarFin) .And. dDatFin < dDatIn
	lRet := .F.
	MsgInfo(cMsg, "Atenção")
Endif
 
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CheckArray ³ Autor ³ Totvs			     ³ Data ³ 21.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Compara dois arrays											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CheckArray(a1, a2)

Local lRet	:= .T.
Local nX	:= 0

If Len(a1) <> Len(a2)
	Return .F.
EndIf

For nX := 1 To Len(a1)
	If a1[nX] <> a2[nX]
		lRet := .F.
		Exit
	EndIf
Next

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ AAddCriPLS ³ Autor ³ Totvs			     ³ Data ³ 21.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Add item em um array APENAS se ele não já não existir.		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AAddCriPLS(aDdArray, xItem)

Local lRet := .F.

If 0 == AScan(aDdArray,{|x| IIf(ValType(xItem)=="A" .And. ValType(x)=="A",CheckArray(x,xItem),x == xItem)})
	lRet := AAdd(aDdArray,xItem) 
EndIf	

Return lRet
