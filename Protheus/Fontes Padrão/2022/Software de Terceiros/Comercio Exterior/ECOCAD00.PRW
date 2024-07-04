#INCLUDE "PROTHEUS.CH"
#include "AVERAGE.CH"
#INCLUDE "ECOCAD00.CH"
#include "EEC.cH"
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECOA001  ³ Autor ³ VICTOR IOTTI          ³ Data ³ 25.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro B.U. / Unid. Req.                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ECOA001

Return AxCadastro("ECC",STR0001) //"B.U./Unid. Req."


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECOA002  ³ Autor ³ VICTOR IOTTI          ³ Data ³ 26.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Contas Contabeis                                ±±
±± Obs:                                                                    ±±
±± Modificado em 11/06/02 por Thomaz (TAN)                                 ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ECOA002()
Private aRotina := {}
Private cDelFunc := ".T.", cAlias:="EC6"
Private cCadastro :=  STR0002
Private cFilEC6 := xFilial("EC6")

If !EasyCallMVC("MVC_ECO002A",1) // CRF - 29/03/2011
   
   IncluiDespesa() // TDF

   aRotina := MenuDef("ECOA002")

   EC6->(dbSetOrder(1))
   mBrowse( 6, 1,40,90,"EC6") 
   Set Filter To
   EC6->(DbSetOrder(1))
EndIf   
Return  

/*
Funcao     : MenuDef()
Parametros : cFuncao
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 19/01/07 - 15:25
*/
Static Function MenuDef(cOrigem)
Local aRotAdic := {}      
Local aRotina := {}
Default cOrigem  := AvMnuFnc()
                    
cOrigem := AllTrim(Upper(cOrigem))

Begin Sequence

   Do Case

      Case cOrigem $ "ECOA002"
           aAdd(aRotina, {STR0021, "AxPesqui"  , 0, 1} ) //"Pesquisar"
           aAdd(aRotina, {STR0022, "AxVisual"  , 0, 2} ) //"Visualizar"
           aAdd(aRotina, {STR0023, "ECOManut"  , 0, 3} ) //"Incluir"
           aAdd(aRotina, {STR0024, "ECOManut"  , 0, 4} ) //"Alterar"
           aAdd(aRotina, {STR0025, "AxDeleta"  , 0, 5} ) //"Excluir"
           aAdd(aRotina, {STR0029, "U_Ecocopia", 0, 7,,.F. }) //"Copiar"

           //³ P.E. utilizado para adicionar itens no Menu da mBrowse
           If EasyEntryPoint("CA002MNU")
	          aRotAdic := ExecBlock("CA002MNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         aEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf   

      Case cOrigem $ "ECOA003"
           aAdd(aRotina, { STR0021 , "AxPesqui" , 0 , 1} ) //"Pesquisar"
           aAdd(aRotina, { STR0022 , "AxVisual" , 0 , 2} ) //"Visualizar"
           aAdd(aRotina, { STR0023 , "ECOA003Manut" , 0 , 3} ) //"Incluir"
           aAdd(aRotina, { STR0024 , "ECOA003Manut" , 0 , 4} ) //"Alterar"
           aAdd(aRotina, { STR0025 , "AxDeleta" , 0 , 5} )  //"Excluir"
      
           //³ P.E. utilizado para adicionar itens no Menu da mBrowse
           If EasyEntryPoint("CA003MNU")
	          aRotAdic := ExecBlock("CA003MNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         aEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf 
      
      OtherWise
         aRotina := StaticCall(MATXATU,MENUDEF)
   End Case    

End Sequence

Return aRotina  
                
*-------------------------------------*
Function ECOManut(cAlias,nReg,nOpc)
*-------------------------------------*
Local nSelect := Select()
Local nOrder := EC6->(INDEXORD())
Local oDlg,nInc,nOp,bCancel := {||nOp:=0,oDlg:End()}
Local bVal_OK:={||(nOp:=1,oDlg:End())}

Private aTela[0][0],aGets[0], nRecEC6
    
If nOpc == INCLUIR
   dbSelectArea(cAlias)
   For nInc := 1 TO (cAlias)->(FCount())
	     M->&(FIELDNAME(nInc)) := CRIAVAR(FIELDNAME(nInc))
   Next nInc
Else
   dbSelectArea(cAlias)              
   nRecEC6 := EC6->(RECNO())
   For nInc := 1 TO (cAlias)->(FCount())
      M->&(FIELDNAME(nInc)) := FieldGet(nInc)
   Next nInc
	      
   If nOpc = VISUALIZAR
      bVal_OK:={||oDlg:End()}
	     	  
   ElseIf nOpc = EXCLUIR
      bVal_OK:={||nOp:=0,oDlg:End()}
         
   EndIf
Endif                           

DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
         
EnChoice(cAlias, nReg, nOpc,,,,,PosDlg(oDlg))
   
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(Obrigatorio(aGets,aTela) .And. If(nOpc <> VISUALIZAR .OR. nOpc <> EXCLUIR, ECOA002VAL("TUDO",nOpc), .T.), Eval(bVal_OK), )},{||Eval(bCancel)},,)
                
If nOp=1
   MsAguarde( { || ECOGrv(nOpc)}, STR0030)
Else
  Return
EndIf
 
EC6->(dbsetorder(nOrder))

Select(nSelect)
    
Return NIL

*-------------------------------*
Function ECOA002VAL(cCampo,nOpc) // Usado pelo SX3 no alias EC6.
*-------------------------------*
Local lRet:= .T.
Default nOpc := '' // Nick 23/10/06   

//** PLB 16/05/06 - Substituicao dos Return's pela variavel lRet, para evitar desposicionamento de registro
nRec := EC6->( RecNo() )
Begin Sequence
   Do Case

      //** PLB 09/10/06 - Verifica se o Tipo de Módulo existe na tabela padrão do SX5
      Case cCampo == "EC6_TPMODU"
         If !Empty(M->EC6_TPMODU)
            lRet := ExistCpo("SX5","CJ"+M->EC6_TPMODU)
         EndIf
      //**

      Case cCampo=='EC6_ID_CAM'
           IF EMPTY(M->EC6_ID_CAM)
              Help(" ",1,"AVG0005208") //E_MSG(STR0003,1) //"Numero do campo deve ser preenchido."
//              Return .F.
              lRet := .F.
              Break
           ENDIF
        
//        nRec:= EC6->(RECNO())
//      If ! Empty(M->EC6_IDENTC)        
           EC6->(DBSEEK(xFilial('EC6')+M->EC6_TPMODU+M->EC6_ID_CAM+M->EC6_IDENTC))
           If !EC6->(EOF()) .AND. INCLUI  // Variavel do Mbrowse           
              Help(" ",1,"JAGRAVADO") //Help(" ",1,"AVG0005209") //E_MSG(STR0004,1) //"Registro ja cadastrado."
//              Return .F.
              lRet := .F.
              Break
           EndIf
//        EndIf
        If INCLUI .AND. EC6->(DBSEEK(xFilial('EC6')+M->EC6_TPMODU+M->EC6_ID_CAM))
           M->EC6_DESC:=EC6->EC6_DESC
        EndIf
//        EC6->(dbGoto(nRec))

      Case cCampo=='EC6_IDENTC'
//      IF EMPTY(M->EC6_IDENTC)
//         E_MSG(STR0005,1) //"B.U./Unid. Req. deve ser preenchida."
//         Return .F.
//      ENDIF
//        nRec:= EC6->(RECNO())
         IF !Empty(M->EC6_IDENTC) .And. !ECC->(DBSEEK(xFilial('ECC')+M->EC6_IDENTC))
            Help(" ",1,"AVG0005210") //E_MSG(STR0006,1) //"B.U./Unid. Req. nao cadastrado."
//           Return .F.
            lRet := .F.
            Break
         Else
            If !Empty(M->EC6_IDENTC)  //*** GFP 03/08/2011
               M->EC6_DESC_I := ECC->ECC_DESCR
            Endif   
         EndIf
         If !Empty(M->EC6_ID_CAM)
            If INCLUI .And. EC6->(DBSEEK(xFilial('EC6')+M->EC6_TPMODU+M->EC6_ID_CAM+M->EC6_IDENTC))
               Help(" ",1,"JAGRAVADO")
               lRet := .F.
               Break
            EndIf
         EndIf

      Case cCampo=='DESC_W'
         If !EMPTY(M->EC6_DESC) .AND. EC6->(DBSEEK(xFilial('EC6')+M->EC6_TPMODU+M->EC6_ID_CAM))
//              Return .F.
            lRet := .F.
            Break
         EndIf

      // GCC - 19/11/2013 - Ajuste na validação do campo EC6_COD_HI referente a alteração da consulta padrão de SI8 para CT8
	 Case cCampo=='EC6_COD_HI'
		IF ! Empty(M->EC6_COD_HI) .And. !CT8->(DbSeek(xFilial('CT8')+M->EC6_COD_HI))
			Help(" ",1,"AVG0005211") //E_MSG(STR0007,1) //"Historico nao cadastrado."
			//Return .F.
			lRet := .F.
			Break
		EndIf           

      Case cCampo=='EC6_DIAMES'
         If !Empty(M->EC6_DIAMES)
            EC6->(DBSEEK(xFilial('EC6')+M->EC6_TPMODU+M->EC6_ID_CAM+M->EC6_IDENTC+M->EC6_DIAMES))
            If !EC6->(EOF()) .AND. (INCLUI .Or. EC6->(Recno()) # nRec)  // Variavel do Mbrowse 
               E_MSG(STR0004,1) //"Registro j  cadastrado."
//               EC6->(DbGoto(nRec))
//               Return .F.
               lRet := .F.
               Break
            EndIf
         EndIf

      Case cCampo=='TUDO'
//         nRec:=EC6->(RecNo())
         If nOpc <> INCLUIR
            If EC6->(dbSeek(cFilEC6+M->EC6_TPMODU+M->EC6_ID_CAM+M->EC6_IDENTC))
               If EC6->(RecNo()) <> nRec
                  Help(" ",1,"JAGRAVADO")
                  lRet:= .F.
               Else
                  lRet:= .T.
               Endif
            Endif           
         Else
            If EC6->(dbSeek(cFilEC6+M->EC6_TPMODU+M->EC6_ID_CAM+M->EC6_IDENTC))
               Help(" ",1,"JAGRAVADO")
               lRet:= .F.
            Endif
         Endif             

         If lRet //HVR 02/03/2006 - Força Validação do Evento Associado caso não tenho no DIcionário de Dados a Validação para este campo
            If !Empty(M->EC6_EVE_AS)
               If EC6->( DBSeek(cFilEC6+M->EC6_TPMODU+M->EC6_EVE_AS) )
                  EC6->(DbGoTo(nRec))
                  lRet := ECOA002VAL('EC6_EVE_AS')
               Else
                  MsgStop(STR0036)  //"O Evento Associado não existe no Cadastro de Eventos Contábeis."  // PLB 09/10/06
                  lRet := .F.
               EndIf
            EndIf
         Endif  //***HVR***
        
//         Return lRet
         Break

      Case cCampo=='EC6_EVE_AS' //HVR 02/03/2006 - Validação para Evento Associado não entrar em Looping (Testa o Evento Associado, se no registro Algum Evento associado em cascata volta para o Looping
         Private cCtrl_EVE, cCtrl_EVE_AS, cCtrl_TPMODU
         cCtrl_EVE:=M->EC6_ID_CAM
         cCtrl_EVE_AS:=M->EC6_EVE_AS

         If M->EC6_EVE_AS == M->EC6_ID_CAM
            cCtrl_EVE_AS:=EC6->EC6_EVE_AS
            MsgStop("O Evento não pode ser associado a ele mesmo!")
            lRet:=.F.
         else
            Do While !Empty(cCtrl_EVE_AS) 
               EC6->(DbSetOrder(1))
               EC6->(dbSeek(M->EC6_FILIAL+M->EC6_TPMODU+cCtrl_EVE_AS))
               If EC6->EC6_EVE_AS == cCtrl_EVE
                  cCtrl_EVE_AS:=EC6->EC6_EVE_AS
                  MsgStop("O Evento: "+cCtrl_EVE_AS+" já possui associação com o Evento: "+EC6->EC6_ID_CAM)
                  lRet:=.F.
                  EXIT
               else
                  cCtrl_EVE_AS:=EC6->EC6_EVE_AS
                  lRet:=.T.
               Endif
            Enddo
         Endif

//        EC6->(dbSeek(M->EC6_FILIAL+M->EC6_TPMODU+cCtrl_EVE))
//         Return lRet //***HVR***
         Break  

   EndCase
End Sequence

EC6->( DBGoTo(nRec) )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECOA003  ³ Autor ³ VICTOR IOTTI          ³ Data ³ 26.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro Taxas de Cambio. (contabil)                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±Modificado em 03/09/03 por Thomaz (TAN)                                  ±±
±±³Descrição - Tirar do AxCadastro e colocar Manutenção(aRotina)          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ECOA003

Private lTemECBTx := .F.
Private aRotina := MenuDef("ECOA003")
Private cDelFunc := ".T.", cAlias:="ECB"
Private cCadastro:= STR0033 //"Cadastro de Taxas de Câmbio"
Private cFilECB := xFilial("ECB")

lTemECBTx := ECB->(FieldPos("ECB_TX_CTB")) > 0 .And. ECB->(FieldPos("ECB_TX_EXP")) > 0

mBrowse( 6, 1,40,90,"ECB")

ECB->(DbSetOrder(1))
Return

*---------------------------------------*
Function ECOA003Manut(cAlias,nReg,nOpc)
*---------------------------------------*
If nOpc=3
   AxInclui(cAlias,nReg,nOpc,,,,"ECOA003Valid()")
ElseIf nOpc=4
   AxAltera(cAlias,nReg,nOpc,,,,,"ECOA003Valid()")
Endif

Return nOpc

*------------------------------*
Function ECOA003Valid()
*------------------------------*
Local lRet:= .T.
If lTemECBTx
   If M->ECB_TX_CTB = 0 .and. M->ECB_TX_EXP = 0
      MsgInfo(STR0032) //"Cotação não pode ser salva sem nenhuma taxa. Informe pelo menos uma taxa para cotação."
      lRet:=.F.
   EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECOA004  ³ Autor ³ VICTOR IOTTI          ³ Data ³ 26.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro Historicos.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAECO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ECOA004

Return AxCadastro("SI8",STR0009) //"Historicos"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECOA005  ³ Autor ³ VICTOR IOTTI          ³ Data ³ 28.05.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mudanca do MES/ANO de Contabilizacao.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAECO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ECOA005(cTipo)
LOCAL nOpca
LOCAL cDtPrev:=If(cTipo == "EFF", EasyGParam("MV_DTPREV",, dDataBase), EasyGParam("MV_DT_PREV"))
LOCAL cHoPrev:=If(cTipo == "EFF", AllTrim(EasyGParam("MV_HOPREV",, Time())), AllTrim(EasyGParam("MV_HO_PREV")))
LOCAL cNrCont:=If(cTipo == "EFF", EasyGParam("MV_NRCONT",,1), EasyGParam("MV_NR_CONT"))
PRIVATE cDataNova:=If(cTipo == "EFF", AllTrim(EasyGParam("MV_MESPEXP",,StrZero(Month(dDataBase),2)+StrZero(Year(dDataBase),4))), EasyGParam("MV_MESPROC"))
Private cDataAnt:=cDataNova
DO WHILE .T.

   nOpca:=0

   // GFP - 10/11/2011 - Ajuste de tamanho de tela para que botão não seja exibido cortado.
   DEFINE MSDIALOG oDlg TITLE STR0010 FROM 0,0 TO 12,51/*46*/ OF oMainWnd //"Parƒmetros"

      @ 2.0,3.0 SAY STR0011 OF oDlg //"Mˆs/Ano Processamento"
      @ 2.0,12.0 MSGET oGet Var cDataNova PICTURE "@R 99/9999"         SIZE 30,8 OF oDlg
      @ 3.0,3.0 SAY STR0012 OF oDlg //"Data Ultima Previa"
      @ 3.0,12.0 MSGET oGet Var cDtPrev When .F. SIZE /*30*/42,8 OF oDlg  // GFP
      @ 4.0,3.0 SAY STR0013 OF oDlg //"Hora Ultima Previa"
      @ 4.0,12.0 MSGET oGet Var cHoPrev When .F. SIZE 30,8 OF oDlg
      @ 5.0,3.0 SAY STR0014 OF oDlg //"Ultima Contabilizacao"
      @ 5.0,12.0 MSGET oGet Var cNrCont When .F. SIZE 30,8 OF oDlg
      
   ACTIVATE MSDIALOG oDlg ON INIT ;
            EnchoiceBar(oDlg,{||IF(ValECOA5(),(nOpca:=1,oDlg:End()),)},;
                             {||nOpca:=0,oDlg:End()}) CENTERED

   If nOpca = 1
      If(cTipo == "EFF", AllTrim(EasyGParam("MV_MESPEXP",,StrZero(Month(dDataBase),2)+StrZero(Year(dDataBase),4))), EasyGParam("MV_MESPROC"))
     
      SETMV(If(cTipo == "EFF", "MV_MESPEXP", "MV_MESPROC"),cDataNova)

   EndIf
   EXIT
ENDDO
                           
Return Nil                           

Function ValECOA5()
   If VAL(LEFT(cDataNova,2)) < 1 .OR. VAL(LEFT(cDataNova,2)) > 12
      Help(" ",1,"AVG0005212") //E_MSG(STR0016,1)   //"O mes deve estar entre 1(janeiro) e 12(dezembro)."
      Return .F.
   EndIf
   If VAL(RIGHT(cDataNova,4)) < 1
      Help(" ",1,"AVG0005213") //E_MSG(STR0017,1)   //"O ano deve ser maior que 0."
      Return .F.
   EndIf
   IF SUBSTR(cDataNova,3,4) + SUBSTR(cDataNova,1,2) < SUBSTR(cDataAnt,3,4) + SUBSTR(cDataAnt,1,2) 
      Help(" ",1,"AVG0005214") //E_MSG(STR0018,1) //"Mes e ano invalido."
      Return .F.
   ENDIF
   If cDataNova # cDataAnt .AND. SimNao(STR0019,STR0020,,,,STR0020) # "S" //"Confirma Altera‡„o ?"###"Questao ?"
      Return .F.
   EndIf
Return .T.


*-------------------------*
User Function ECOCOPIA()
*-------------------------*
Local nOrdEC6 := EC6->(IndexOrd())
Local nRec:=EC6->(RecNo()), nOp:=0
Local cTit:= STR0031,x

//aCampos:= {} //TRP-21/01/08

//Nopado por TRP em 21/01/08. Motivo: Na enchoice do botão copiar, devem aparecer todos campos da tabela EC6, independentemente se for campo padrão ou de usuário. 
/*Aadd(aCampos,"EC6_TPMODU"); Aadd(aCampos,"EC6_ID_CAM")
Aadd(aCampos,"EC6_DESC"  ); Aadd(aCampos,"EC6_NO_CAM")
Aadd(aCampos,"EC6_IDENTC"); Aadd(aCampos,"EC6_CTA_DB")
Aadd(aCampos,"EC6_CTA_CR"); Aadd(aCampos,"EC6_COD_HI")
Aadd(aCampos,"EC6_COD_HI"); Aadd(aCampos,"EC6_FINANC")
Aadd(aCampos,"EC6_CDBEST"); Aadd(aCampos,"EC6_CCREST")
Aadd(aCampos,"EC6_DESC_I"); Aadd(aCampos,"EC6_EVE_AS")
Aadd(aCampos,"EC6_CA_EVE"); Aadd(aCampos,"EC6_CONTAB")
Aadd(aCampos,"EC6_DIAMES"); Aadd(aCampos,"EC6_DESC_H")  */

Do While .T.

   For x := 1 To EC6->(FCount())
      M->&(EC6->(FIELDNAME(x))) := EC6->(FIELDGET(x))
   Next
   M->EC6_IDENTC := Space(Len("EC6_IDENTC"))
   M->EC6_TPMODU := Space(Len("EC6_TPMODU"))
            
   aGets:={}
   aTela:={}
   nOp:= 0

   DEFINE MSDIALOG oDlg TITLE cTit;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom,oMainWnd:nRight - 10 ;
       OF oMainWnd PIXEL

   nLinha :=(oDlg:nClientHeight-4)/2

   EnChoice("EC6",nRec,3,,,,/*aCampos*/,{15,1,nLinha,COLUNA_FINAL},,3)

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(Obrigatorio(aGets,aTela),(nOp:=1,oDlg:End()), )},{||nOp:=0,oDlg:End()}) CENTERED

   If nOp=1
      EC6->(dbSetOrder(1))
      If EC6->(dbSeek(cFilEC6+Alltrim(M->EC6_TPMODU)+M->EC6_ID_CAM+M->EC6_IDENTC))
         Help(" ",1,"JAGRAVADO")         
         Loop         
      Else
         EC6->(RecLock("EC6",.T.))
         AvReplace("M","EC6")
         EC6->(MsUnlock())
      Endif
   Else
      Exit
   Endif
Enddo

EC6->(DBSETORDER(nOrdEC6))
EC6->(dbGoTo(nRec))

Return .T.

*------------------------------*
Static Function ECOGrv(nOpc)
*------------------------------* 
Local i

dbSelectArea("EC6")

EC6->(RecLock("EC6",If(nOpc=INCLUIR,.T.,.F.)))
                    
FOR i := 1 TO FCount()
   EC6->&(FIELDNAME(i)) := M->&(FIELDNAME(i))
NEXT i                                                    

EC6->EC6_FILIAL := cFilEC6

EC6->(MSUnlock())

Return .T.

*---------------*
Function ECOA006
*---------------*

ECOA005('EFF')

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECOCLI01 ³ Autor ³ Alessandro Alves Ferreira Data 21.12.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro Import./Clientes                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ECOCLI01

Return AxCadastro("SA1",STR0034) //"Import./Clientes"


/*
  Função..: ECO00GatCC()
  Objetivo: Preencher a correta marcara dos campos de de Conta de Debito e Credito
  Autor...: Felipe Sales Martinez - FSM
  Data....: 16/04/2012
  Obs.....: 
*/
Function ECO00GatCC(cCTDom, cOption)
Local cRet := ""
Local nTam := AVSX3("EC6_CTA_DB", AV_TAMANHO)
Private xDig := ""
//FSM - 24/10/2012
cCampo := "M->"+cCtDom
If Type(cCampo) == "U"
   cCampo := "EC6->"+cCtDom
EndIf

If cOption == "COMBO"
   //THTS - 31/05/2017 - TE-5822 - Contabilizacao com conta contabil por Incoterm
   If &(cCampo) == Replicate("6",nTam) //5=Incoterm
      cRet := "5"
   //FSM - 24/10/2012
   ElseIf SubStr(&(cCampo),1,nTam-1) == Replicate("7",nTam-1) //4=Banco 
      cRet := "4"
   ElseIf &(cCampo) == Replicate("9",nTam) //3=Fornecedor
      cRet := "3"
   ElseIf &(cCampo) == Replicate("8",nTam)  //2=Cliente
      cRet := "2"
   Else //1=Fixa
      cRet := "1"
   EndIf

ElseIf cOption == "CONTA"
   //THTS - 31/05/2017 - TE-5822 - Contabilizacao com conta contabil por Incoterm
   If &(cCampo) == "5" //5=Incoterm
      cRet := Replicate("6",nTam)
   
   ElseIf &(cCampo) == "4"  //4=Banco
      cRet := Replicate("7",nTam-1)

      If ConPad1(,,,"C0")
         xDig := AllTrim(SX5->X5_CHAVE)
         cRet += xDig
      EndIf
           
   ElseIf &(cCampo) == "3" //3=Fornecedor
      cRet := Replicate("9",nTam)

   ElseIf &(cCampo) == "2" //2=Cliente
      cRet :=  Replicate("8",nTam)
   Else //1=Fixa
      cRet := ""
   EndIf

EndIf

Return cRet
