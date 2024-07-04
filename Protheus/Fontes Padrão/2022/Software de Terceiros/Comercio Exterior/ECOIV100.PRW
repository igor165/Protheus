#INCLUDE "Ecoiv100.ch"
#INCLUDE "AVERAGE.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECOIV100 ³ Autor ³ VICTOR IOTTI          ³ Data ³ 11.12.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao de Invoices                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ECOIV100()
LOCAL nOldArea:=Select()
Private aRotina := MenuDef()
Private cCadastro := STR0006, cDelFunc:="IF(SimNao('"+STR0007+"',,,,,'"+STR0008+"')#'S',.F.,.T.)" //"Manuten‡„o de Invoices"###'Confirma `a Exclusao ? '###'Excluir'
Private cFilEC8:=xFilial('EC8'),cFilSA2:=xFilial('SA2'),cFilECB:=xFilial('ECB')
Private cFilECC:=xFilial('ECC'),cFilEC5:=xFilial('EC5')

mBrowse( 6, 1,22,75,'EC5')
DbSelectArea(nOldArea)
ECB->(DBSETORDER(1))
EC8->(DBSETORDER(1))
Return .T.
                            

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 01/02/07 - 15:05
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := { { STR0001,  "AxPesqui"  , 0 , 1},; //"Pesquisar"
                    { STR0002,  "AxVisual"  , 0 , 2},; //"Visualizar"
                    { STR0003,  "AxInclui"  , 0 , 3},; //"Incluir"
                    { STR0004,  "IV100GER"  , 0 , 4},; //"Alterar"
                    { STR0005,  "IV100GER"  , 0 , 5,3}} //"Excluir"

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("CIV100MNU")
	aRotAdic := ExecBlock("CIV100MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

*----------------------------------*
FUNCTION IV100GER(cAlias,nReg,nOpc) // Usado pelo SX3 no alias EC5.
*----------------------------------*
SA2->(DBSETORDER(1))
ECB->(DBSETORDER(2))
EC2->(DBSETORDER(1))
EC8->(DBSETORDER(2))
ECC->(DBSETORDER(1))
SYF->(DBSETORDER(1))

IF nOpc = 5
   IF EC8->(DBSEEK(xFilial('EC8')+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC+EC5->EC5_HAWB))
//      E_Msg(STR0009+ EC8->EC8_HAWB,1) //'Invoice j  alocado no Processo - ' -- By A. Caetano Jr - 15/12/2003
      Help("",1,"AVG0005319" ,, " " + EC8->EC8_HAWB)
      Return .F.
   ENDIF

   IF VAL(EC5->EC5_NR_CON) <> 0 .AND. VAL(EC5->EC5_NR_CON) <> 9999
//      E_Msg(STR0010,1) //"Invoice j  contabilizada n„o pode ser excluida." -- By A. Caetano Jr - 15/12/2003
      Help("",1,"AVG0005349")
      Return .F.
   ENDIF
   AxDeleta(cAlias,nReg,nOpc)
Else                        
   If Empty(EC5->EC5_AMOS) .Or. EC5->EC5_AMOS == "N"
   	  EC5->(RecLock("EC5",.F.))
	  EC5->EC5_AMOS := "2"   
	  EC5->(MsUnlock())
   Endif
   AxAltera(cAlias,nReg,nOpc,,,,,"IV100Val('OK')")
EndIf
Return Nil

*-------------------------*
FUNCTION IV100Val(cCodigo) // Usado pelo SX3 no alias EC5.
*-------------------------*
DO CASE
   CASE cCodigo = "MES"
        IF VAL(M->EC5_VCFMES) < 1 .OR. VAL(M->EC5_VCFMES) > 12
           Help(" ",1,"AVG0005323") //E_Msg(STR0011,1) //"Mˆs deve estar entre 1 e 12."
           RETURN .F.
        ENDIF
        
   CASE cCodigo = "DATA"

        IF EMPTY(M->EC5_DT_EMI)
           Help(" ",1,"AVG0005324") //E_Msg(STR0021,1) //"Data de emiss„o não preenchida ou inválida."
           RETURN .F.
        ENDIF

        IF M->EC5_DT_EMI > dDataBase
           Help(" ",1,"AVG0005325") //E_Msg(STR0012,1) //"Data de emiss„o maior que a data atual."
           RETURN .F.
        ENDIF

   CASE cCodigo = "FORN"
        IF ! EMPTY(ALLTRIM(M->EC5_FORN)) .AND. ! SA2->(DBSEEK(xFilial('SA2')+M->EC5_FORN))
           Help(" ",1,"AVG0005302") //E_Msg(STR0013,1) //"Fornecedor n„o cadastrado."
           RETURN .F.
        ENDIF
        M->EC5_FORNDE:=SA2->A2_NREDUZ                

        If ! EMPTY(ALLTRIM(M->EC5_INVOIC)) .AND. If(EMPTY(ALLTRIM(M->EC5_FORN)),.F.,.T.) .AND. ! EMPTY(ALLTRIM(M->EC5_IDENTC))
           nRecEC5:=EC5->(RECNO())
           If EC5->(DBSEEK(xFilial('EC5')+M->EC5_FORN+M->EC5_INVOIC+M->EC5_IDENTC)).AND.(Inclui .or. nRecEC5#EC5->(RECNO()))
              Help(" ",1,"AVG0005326") //E_Msg(STR0018,1) //"Invoice j  cadastrada."
              EC5->(DBGOTO(nRecEC5))
              RETURN .F.
           EndIf
           EC5->(DBGOTO(nRecEC5))
        EndIf        

   CASE cCodigo = "MOEDA"
        IF ! Inclui .AND. M->EC5_MOE_FO # EC5->EC5_MOE_FO .AND. EC8->(DBSEEK(xFilial('EC8')+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC+EC5->EC5_HAWB))
           // Mensagem de Advertencia. - By A. Caetano Jr - 15/12/2003
           E_Msg(STR0014,1) //'J  h  registros desta invoice no EC8, a moeda n„o pode ser alterada.'
           RETURN .F.
        Else
           ECB->(DBSETORDER(2))
           If ! ECB->(DBSEEK(xFilial('ECB')+M->EC5_MOE_FO))
              Help(" ",1,"AVG0005327") //E_Msg(STR0015,1) //"Moeda n„o cadastrada no arquivo de taxas."
              RETURN .F.
           EndIf
        ENDIF

   CASE cCodigo = "IDENTCT"
        IF ! EMPTY(ALLTRIM(M->EC5_IDENTC)) .AND. ! ECC->(DBSEEK(xFilial('ECC')+M->EC5_IDENTC))
           Help(" ",1,"AVG0005303") //E_Msg(STR0017,1) //"B.U. / Unid. Req. n„o cadastrado."
           RETURN .F.
        ENDIF
        M->EC5_DESC_I:=ECC->ECC_DESCR
        If ! EMPTY(ALLTRIM(M->EC5_INVOIC)) .AND. If(EMPTY(ALLTRIM(M->EC5_FORN)),.F.,.T.) .AND. ! EMPTY(ALLTRIM(M->EC5_IDENTC))
           nRecEC5:=EC5->(RECNO())
           If EC5->(DBSEEK(xFilial('EC5')+M->EC5_FORN+M->EC5_INVOIC+M->EC5_IDENTC)).AND.(Inclui .or. nRecEC5#EC5->(RECNO()))
              Help(" ",1,"AVG0005326") //E_Msg(STR0018,1) //"Invoice j  cadastrada."
              EC5->(DBGOTO(nRecEC5))
              RETURN .F.
           EndIf
           EC5->(DBGOTO(nRecEC5))
        Endif
        
   CASE cCodigo = "INVOICE"
        If ! EMPTY(ALLTRIM(M->EC5_INVOIC)) .AND. If(EMPTY(ALLTRIM(M->EC5_FORN)),.F.,.T.) .AND. ! EMPTY(ALLTRIM(M->EC5_IDENTC))
           nRecEC5:=EC5->(RECNO())
           If EC5->(DBSEEK(xFilial('EC5')+M->EC5_FORN+M->EC5_INVOIC+M->EC5_IDENTC)).AND.(Inclui .or. nRecEC5#EC5->(RECNO()))
              Help(" ",1,"AVG0005326") //E_Msg(STR0018,1) //"Invoice j  cadastrada."
              EC5->(DBGOTO(nRecEC5))
              RETURN .F.
           EndIf
           EC5->(DBGOTO(nRecEC5))
        EndIf
   CASE cCodigo = "OK"
        M->EC5_SIS_OR:='2'
        IF ! EMPTY(ALLTRIM(M->EC5_VCFMES+M->EC5_VCFANO)) .AND. ALLTRIM(M->EC5_VCFMES+M->EC5_VCFANO) # AllTrim(EasyGParam("MV_MESPROC"))
           Help(" ",1,"AVG0005328") //E_Msg(STR0019,1) //"Mˆs/Ano de encerramento deve ser igual ao Mˆs/Ano de Processamento."
           RETURN .F.
        ENDIF

   CASE cCodigo = "VALOR"     
        If ! Inclui .AND. M->EC5_FOB_TO # EC5->EC5_FOB_TO .AND. EC8->(DBSEEK(xFilial('EC8')+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC+EC5->EC5_HAWB))
           // Mensagem de Advertencia. - By A. Caetano Jr - 15/12/2003
           E_Msg(STR0020,1) //'J  h  registros desta invoice no EC8, alterar tamb‚m o Processo.'
        EndIf

ENDCASE
RETURN .T.

*-----------------------*
Function IV100When(cVar)
*-----------------------*
lRetWhen:=.T.
If cVar = "GERAL" .AND. VAL(M->EC5_NR_CON) > 0 .AND. VAL(M->EC5_NR_CON) < 9999
   lRetWhen:=.F.
EndIf

Return lRetWhen
