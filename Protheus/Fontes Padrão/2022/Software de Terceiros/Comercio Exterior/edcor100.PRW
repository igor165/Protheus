#INCLUDE "EDCOR100.CH"
#INCLUDE "AVERAGE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"

#define FO_READ      0     // Open for reading (default)
#define FO_READWRITE 2     // Open for reading (default)
#define FO_EXCLUSIVE 16    // Exclusive use (other processes have no access)
#define BLOCK_READ 1024    // Blocos de leitura


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³EDCOR100  ³ Autor ³ THOMAZ                                   ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Envio de Dados ao Siscomex (Drawback)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EDCOR100()

EDCOR100R3(.T.)

If Select("TRB") > 0
   TRB->(DBCloseArea())
EndIf 

Return .t.
*-----------------------*
Function EDCOR100R3(p_R4)
*-----------------------*
Local   cTitulo     := STR0001 //"Extracao de Dados para Envio ao Siscomex"
Local   aCamposRel  :={}

Private cTitle:=""
Private cFilSB1 := xFilial("SB1")
Private cFilSB1Aux:=cFilSB1, cAliasSB1:="SB1" //Para utilizar produtos de outra Empresa/Filial
Private cDir_Or  := EasyGParam("MV_AVG0002") // Diretorio de Geração dos TxT's
Private cDir_Des := EasyGParam("MV_AVG0003") // Diretorio destino do Retorno do Siscomex
Private cFim := STR0055+CHR(13)+CHR(10) //"####eof#####"
Private aHeader[0],aCampos:={}, TB_Campos:= {}, aRCampos:={}
Private aDados :={"WorkRel",;
                  STR0018,; //"Este Relatorio irá imprimir os Pedidos de DrawBack e os A.C's"
                  STR0019,; //"de Retorno do Siscomex"
                  "",;
                  "M",;
                  132,;
                  "",;
                  "",;
                  STR0020,; //"Relatório de Retorno do Siscomex"
                  {STR0021 , 1, STR0022, 2, 2, 1, "",1 },; //"ZEBRADO"##"IMPORTAÇÃO"
                  "EDCOR100",;
                  { {|| .T.  } , { || .T. }  }  }
Private lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()

If Select("SB1EXP") = 0
   lAbriuExp := AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"")),cFilSB1,"SB1EXP") // Abre arq. produtos de outra Empresa/Filial de acordo com os parametros.
Else
   lAbriuExp := .T.
Endif

If lAbriuExp
   cAliasSB1  := "SB1EXP"
   cFilSB1Aux := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))
   If(Empty(Alltrim(cFilSB1Aux)),cFilSB1Aux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
Endif

AADD(TB_Campos,{{||WorkRel->PEDIDO  }  ,"" , STR0023 } ) //"Pedido DrawBack"
AADD(TB_Campos,{{||If(Empty(WorkRel->ATOCON),"-",WorkRel->ATOCON)}  ,"" , STR0024 } ) //"Ato Concessório"
AADD(TB_Campos,{{||WorkRel->RETORNO }  ,"" , STR0025 } ) //"Status"
AADD(TB_Campos,{{||WorkRel->MENSA   }  ,"" , STR0026 } ) //"Mensagem"

AADD(aCamposRel,{"PEDIDO"  , AVSX3("ED0_PD", 2), AVSX3("ED0_PD", 3), AVSX3("ED0_PD", 4)})
AADD(aCamposRel,{"ATOCON"  , AVSX3("ED0_AC", 2), AVSX3("ED0_AC", 3), AVSX3("ED0_AC", 4)})
AADD(aCamposRel,{"RETORNO" , "C", 05, 0})
AADD(aCamposRel,{"MENSA"   , "C", 80, 0})
                                                          	
cNomRel:= E_CriaTrab(,aCamposRel,"WorkRel")

IndRegua("WorkRel",cNomRel+TEOrdBagExt(),"RETORNO")

aRCampos:= E_CriaRCampos(TB_Campos,"C")

If lR4
   //TRP - 14/08/2006 - Relatório Personalizavel - Release 4
   //ReportDef cria os objetos.
   oReport := ReportDef()
EndIf

EdcOrMain(cTitulo)

WorkRel->(E_EraseArq(cNomRel))

Return Nil

*-----------------------------------------*
Static Function EdcOrMain(cTitulo)
*-----------------------------------------*
Local cAlias:=SELECT("ED0"), oDlg, oCbx, cTit , oPanel
Local TB_Campos:={}, aSemSx3:={}, nOpc
Local bOk:={||(nOpca:=1,If(cTipo<>0,If(EDCOR100VAL("Pedido").AND. ORI100Val("Importador"),oDlg:End(),),))}
Local bCancel:={||(nOpca:=0,oDlg:End())}
Private bMarca:={|lTodos|EDCORMarca(lTodos),oMark:oBrowse:Refresh()}
Private cQuery,lTop:=.T., cPedido, cImportador, TDt_F, TDt_I
Private aHeader[0], nOpca:=1, cParam, aStatus:= {}, cStatus
Private cMarca := GetMark(), lInverte := .F.
Private cFilED0:=xFilial("ED0"), cFilED3:=xFilial("ED3"), mMensa:= ""
Private cFilED4:=xFilial("ED4"), nArquivo:= 0, lRet:= .F., lRetorno:= .F.
Private cFilED6:=xFilial("ED6")
                   
cTit := STR0027 //"Pedidos Rejeitados"

#IFNDEF TOP
   lTop:=.F.
#ENDIF

SYT->(dbSetOrder(1))
ED0->(dbSetOrder(1))

cNomArq:=E_Create(,.F.)

ASIZE(TB_Campos,0)

AEVAL(aSemSx3,{|Campo|AADD(aCampos,Campo[1])})

AADD(TB_Campos,{"ED0_OK",,"  "})
AADD(TB_Campos,{"ED0_PD",,AVSX3("ED0_PD",05),AVSX3("ED0_PD",06)}) // Pedido de Drawback
AADD(TB_Campos,{"ED0_AC",,AVSX3("ED0_AC",05),AVSX3("ED0_AC",06)}) // Pedido de Drawback
AADD(TB_Campos,{"ED0_DT_ENV",, AVSX3("ED0_DT_ENV",05),AVSX3("ED0_DT_ENV",06)}) //"Envio ao Siscomex"
AADD(TB_Campos,{"ED0_ARQ",, AVSX3("ED0_ARQ",05),AVSX3("ED0_ARQ",06)}) //"Nome do Arquivo"
AADD(TB_Campos,{"ED0_IMPORT",,AVSX3("ED0_IMPORT",05),AVSX3("ED0_IMPORT",06) }) //"Importador"

While .T.
   TDt_I := TDt_F
   
   cPedido:=cImportador:=""
   cTipo := 0
   DbSelectArea("ED0")   //LRL 20/04/04 - Pergunte requer Area Aberta
   If !Pergunte("EDCOR1",.T.)
      Return .F.
   EndIf
   
   cPedido     :=mv_par01
   cTipo       :=mv_par02
   cImportador :=mv_par03
   lSair := lVolta := .F.

   If cTipo = 2
      Do While .T.
         If !Pergunte("EDCOR2",.T.)
            lSair := .T.
         EndIf
         
         If !E_PERIODO_OK(@TDt_I,@TDt_F)
            TRB->(dbClosearea())
            Loop
         Endif
   
         Exit
         
      EndDo
   Endif
                  
   If cTipo = 3 .And. EDCOR100VAL("RET")
   
      WorkRel->(avzap())

      lRet := EdcOr100Ret(".OK") //Retorno de Dados do Siscomex      
      
      If Select("TRB") > 0
         TRB->(DBCloseArea())
      EndIf 
      MsAguarde({||lVolta := EDCLerdados()},STR0003) //"Aguarde... Lendo Dados do Arquivo..."      
      
      //Processa({|| lRetorno := EdcOr100Ret(".ERR")})//Retorno de Dados do Siscomex

      //WFS 16/10/09 - este tratamento estava na função EDCOr100Ret, sendo executado antes da gravação do retorno.
      //Solicita a confirmação do usuário antes de conectar-se no Siscomex para retornar o Status do AC
      If MsgYesNo(STR0067, STR0035) //Deseja conectar-se ao Siscomex para verificar o status do Ato Concessório/Aviso
         If OR100GeraTxt(.T.)
            lRet:= EdcOr100Ret(".OK")
         EndIf
      ElseIf lRet
         Loop
      EndIf
                  
      If lRet = .F. .And. lRetorno = .F.
         Help(" ",1,"AVG0005192") //MsgInfo(STR0064,STR0005) //"Nao existem Registros de Retorno a serem Lidos."###"Mensagem"
         TRB->(DBCloseArea())
         Loop
      Endif
      
      If mMensa = ""
         mMensa := STR0028 //"Nenhum Pedido de Drawback Rejeitado"
      Endif

      aStatus := {STR0039, STR0040, STR0041} //"1- Aceitos "2- Rejeitados "3- Todos"
      cStatus := aStatus[1]
   
      DEFINE MSDIALOG oDlg TITLE cTit From 9,15 To 28,60 OF oMainWnd

      DEFINE SBUTTON FROM 125,110 TYPE 6 ACTION (If(lR4, oReport:PrintDialog() ,Or100Relat(aDados,aRCampos,cStatus))) Enable OF oDlg Pixel //Imprime

      @ 13,17 GET mMensa MEMO HSCROLL READONLY  SIZE 145,110 OF oDlg Pixel
      @ 127,020 SAY STR0029  OF oDlg Pixel //"Pedidos"
      @ 127,050 ComboBox oCbx Var cStatus Items aStatus SIZE 50,08 OF oDlg Pixel
      
      DEFINE SBUTTON FROM 125,145 TYPE 2 ACTION (oDlg:End(), nOpc := 2) Enable OF oDlg Pixel //Cancela

      ACTIVATE MSDIALOG oDlg CENTERED
                               
      If nOpc = 2
         lRet := .F.
         lRetorno := .F.
         TRB->(dbClosearea())
         Loop
      Else
         Exit
      Endif
   ElseIf cTipo = 3 .And. !EDCOR100VAL("RET")
      Loop
   Endif
                  
   If lSair
      Loop
   EndIf
   
   TDt_I:=mv_par01
   TDt_F:=mv_par02
   
   If Select("TRB") > 0
      TRB->(DBCloseArea())
   EndIf 
   MsAguarde({||lVolta := EDCLerdados()},STR0003) //"Aguarde... Lendo Dados do Arquivo..."
   
   If lVolta
      Loop
   EndIf
      
   If TRB->(BOF()) .AND. TRB->(EOF())
      Help(" ",1,"AVG0005193") //MsgInfo(STR0004,STR0005) //"Nao existem Registros para Envio ao Siscomex."###"Mensagem"
      TRB->(dbClosearea())
      Loop
   EndIf

   lEnvio:=.F.
   nOpca:=2
   
   Do While !lEnvio
      
      oMainWnd:ReadClientCoords()
      DEFINE MSDIALOG oDlg TITLE cTitulo ;
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
          OF oMainWnd PIXEL
      TRB->(DBGOTOP())
      @ 00,00 MsPanel oPanel prompt "" Size 60,20 of oDlg    //LRL 20/04/04 - Painel para alinhamento MDI.
      if !EasyGParam("MV_EDC0005",,.F.) // ALS - 08/01/2008 Caso Siscomex Web esteja ativo não permite selecionar mais de um ato para envio
         @4,(oDlg:nClientWidth+105)/2-130 BUTTON STR0006     SIZE 34,11   OF oPanel PIXEL ;  //"Todos"
              ACTION (EVAL(bMarca,.T.)) 
      EndIF

      @4,(oDlg:nClientWidth+105)/2-90 BUTTON STR0007     SIZE 34,11   OF oPanel PIXEL;  //"Envio"
              ACTION (nOpca:=1,lEnvio:=.T.,oDlg:End())

      oMark:=MsSelect():New("TRB","ED0_OK",,TB_Campos,@lInverte,@cMarca,{35,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
      oMark:bAval:={||EVAL(bMarca,.F.)}
      oDlg:lMaximized:=.T. //LRL 20/04/04 - Alinhamento MDI
	  
	  oPanel:Align:=CONTROL_ALIGN_TOP //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  
      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nopca:=2,oDlg:End()},{||nOpca:=2,lEnvio:=.F.,oDlg:End()})) //LRL 20/04/04 -Painel para alinhamento MDI.  //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

      If nOpca == 2
         Exit
      EndIf

      If lEnvio
         EE2->(DbSetOrder(1))
         Processa({|| lEnvio := OR100GeraTxt()}, STR0030) //"Atualizando Arquivos Txt"
         If !lEnvio
            TRB->(DBGOTOP())
            RecLock("TRB",.F.)
            TRB->(DBEVAL({||TRB->ED0_OK := Space(2)}))  // Desmarca Pedido de DrawBack
            TRB->(MsUnLock())
         Endif
      EndIf
   EndDo
     
   TRB->(dbClosearea())
   Loop
EndDo

If Select("TRB") > 0 
   TRB->(dbClosearea())
EndIf

//Volta a ordem natural
ED0->(dbSetOrder(1))
ED3->(dbSetOrder(1))
ED4->(dbSetOrder(1))

Return Nil

*----------------------------------*
Static Function EDCORMarca(lTodos)
*----------------------------------*
Local cChar:=cMarca
Local nRecno:=TRB->(RECNO())
Static nRecnoCheck := -1 //ALS - 08/01/2008 Variavel para controlar a checagem unica dos itens no caso de envio para drawback web ativo

IF TRB->ED0_OK == cMarca
   cChar:=SPACE(04)
   if EasyGParam("MV_EDC0005",,.F.) // ALS - 08/01/2008 Limpa ultimo item checado caso siscomex web esteja ativo
      nRecnoCheck := -1 
   EndIf
Elseif EasyGParam("MV_EDC0005",,.F.) .and. nRecno != nRecnoCheck .and. nRecnoCheck >= 0  // ALS - 08/01/2008 Rotina para marcar apenas um ato para envio caso siscomex web esteja ativo
   TRB->(DBGOTOP())
   TRB->(DBGOTO(nRecnoCheck))  
   RecLock("TRB",.F.)
   TRB->ED0_OK:=SPACE(04)
   TRB->(MsUnLock()) 
   TRB->(DBGOTO(nRecno))
ENDIF

IF lTodos
   TRB->(DBGOTOP())
   RecLock("TRB",.F.)
   TRB->(DBEVAL({||TRB->ED0_OK:=cChar}))
   TRB->(MsUnLock())
ELSE
   RecLock("TRB",.F.)
   TRB->ED0_OK:=cChar
   TRB->(MsUnLock())
   if EasyGParam("MV_EDC0005",,.F.) // ALS - 08/01/2008 Registra Recno do ultimo item checado caso siscomex web esteja ativo
       nRecnoCheck := TRB->(RECNO()) 
   EndIf
ENDIF

TRB->(DBGOTO(nRecno))
RETURN .T.

*----------------------------------*
Function EDCOR100VAL(cParam)
*----------------------------------*
If cParam = "PEDIDO" .Or. cParam = "RET"
   cPedido:= mv_par01
   If !Empty(cPedido)
      If !ED0->(dbSeek(xFilial()+cPedido))
         Help(" ",1,"AVG0005194") //Msginfo(STR0008, STR0005) //"Numero do Pedido nao Cadastrado"###"Mensagem"
         Return .F.
      Endif
   Endif
Endif
     
If cParam = "IMPORTADOR" .Or. cParam = "RET"
   IF !Empty(cImportador)
      If !SYT->(dbSeek(xFilial()+cImportador))
         Help(" ",1,"AVG0005195") //Msginfo(STR0009, STR0005) //"Importador nao Cadastrado"###"Mensagem"
         Return .F.
      Endif
   Endif
Endif

Return .T.

*------------------------------*
Static Function EDCLerdados()
*------------------------------*
Local cCamposED0 := ""
Local i:=0
Local cTmpBkp := CriaTrab(,.F.)
Local aCampoBkp := {}

//If lTop
   
   For i:= 1 To ED0->(FCount())
      cCamposED0 += ED0->(FieldName(i))+", "
   Next i

   cQuery:=" SELECT "+cCamposED0+" 'ED0' AS TRB_ALI_WT, ED0.R_E_C_N_O_ AS TRB_REC_WT FROM "+RetSqlName("ED0")+" ED0 WHERE "+;
   " ED0.ED0_FILIAL='"+cFilED0+"' AND ED0.ED0_MODAL = '1' AND ED0.ED0_ELETRO = '1'"
   If !Empty(cPedido)
      cQuery+= " AND ED0.ED0_PD = '"+cPedido+"'"
   EndIf
   If !Empty(cImportador)
      cQuery+= " AND ED0.ED0_IMPORT = '"+cImportador+"'"
   EndIf
   If cTipo = 2 .AND. !Empty(TDt_I) .AND. !Empty(TDt_F)
      cQuery+=" AND  ED0.ED0_DT_ENV BETWEEN '"+DTOS(TDt_I)+"' AND '"+DTOS(TDt_F)+"'"
   ElseIf cTipo = 1
      cQuery+=" AND  (ED0.ED0_DT_ENV = '' OR ED0.ED0_DT_ENV = ' ')"
   EndIf

   IF TCSRVTYPE() # "AS/400"
      cQuery+=" AND ED0.D_E_L_E_T_<>'*'"
   EndIf
   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS "TRB" NEW
   TcSetField("TRB","ED0_DT_ENV","D")
   TCSetField( "TRB", "ED0_FRETE", "N", AVSX3("ED0_FRETE",3), AVSX3("ED0_FRETE",4) )
   TCSetField( "TRB", "ED0_SEGURO", "N", AVSX3("ED0_SEGURO",3), AVSX3("ED0_SEGURO",4) )
   
   If Select("TRB") <> 0

      TETempBackup(cTmpBkp)
      
      TRB->(DBCLOSEAREA())
   EndIF
/*Else
   bFor1:={|| .T.}
   bFor2:={|| .T.}
   bFor3:={|| .T.}
   
   If !Empty(cPedido)
      bFor1:={|| ED0->ED0_PD = cPedido }
   EndIf
   If !Empty(cImportador)
      bFor2:={|| Alltrim(ED0->ED0_IMPORT) = AllTrim(cImportador) }
   EndIf
   If cTipo = 2 .AND. !Empty(TDt_I) .AND. !Empty(TDt_F)
      bFor3:={|| ED0->ED0_DT_ENV >= TDt_I .AND.  ED0->ED0_DT_ENV <= TDt_F }
   ElseIf cTipo = 1
      bFor3:={|| Empty(ED0->ED0_DT_ENV) }
   EndIf

   DBSELECTAREA("ED0")
   ED0->(dbSeek(cFilED0))
   //LRS - 19/09/2018 trecho nopado
   //COPY TO &cNomArq for Eval(bFor1) .AND. Eval(bFor2) .AND. Eval(bFor3) .AND. ED0->ED0_MODAL = '1' .AND. ED0->ED0_ELETRO = '1' .AND. ED0->ED0_FILIAL = cFilED0
EndIf*/

aCampoBkp := (cTmpBkp)->(dbStruct())
cNomArq := E_CriaTrab(,aCampoBkp,"TRB")
TERestBackup(cTmpBkp)
IF NETERR()
   MSGSTOP(STR0010,STR0011) //LRL 22/01/04 Help(" ",1,"AVG0005196")  //"Arquivo nao disponivel ..."###"Informacao"
   Return .T.
EndIf

IndRegua("TRB",cNomArq+TEOrdBagExt(),"ED0_PD+DTOS(ED0_DT_ENV)")
   
Return .F.

*-----------------------------*
Static Function OR100GeraTxt(lRetorno)
*-----------------------------*
Local nDifer, nDifer1, dData, cOpcaoAt:= ""
Local CFileOutput := "" // ALS - 08/01/2008 Armazena o nome e endereço do arquivo TXT de saida
// LOCAL cBuffer,  -- ACSJ - 01/12/2004 - Variavel não é usada.
Private nSeq:= 0, cNome:= STR0042, lGeraTxt:= .F., cOpcao := "", lSeek  //"DBTOT.AVG"
Private mDescri, mDescri1//AAF 10/11/2017

Default lRetorno := .F.

If(Right(cDir_Or,1) <> "\", cDir_Or += "\",)

IF !AvIsDir(Left(cDir_Or,Len(cDir_Or)-1)) // Path nao existe
   Help(" ",1,"AVG0005197",,cDir_Or+STR0032,1,11) //Msginfo(STR0031+cDir_Or+STR0032, STR0005) //"Diretorio "##" especificado nao foi encontrado."##"Mensagem"
   RETURN .F.
EndIf
                                                 
ProcRegua(TRB->(EasyRecCount()))
TRB->(Dbgotop())

SYT->(dbSetOrder(1))
ED3->(dbSetOrder(1))
ED4->(dbSetOrder(1))
SB1->(dbSetOrder(1))
ED6->(dbSetOrder(1))

While !TRB->(EOF())

   lSeek:= ED6->(DbSeek(xFilial("ED6")+TRB->ED0_PD))

   If TRB->ED0_MODAL == "1" .AND. TRB->ED0_ELETRO == "1"
      If lRetorno
         cOpcao := "S"
         TRB->ED0_OK := cMarca
      ElseIf Empty(TRB->ED0_OK)
         TRB->(Dbskip())
         Loop
      Else
         If !Empty(TRB->ED0_DT_ENV) .And. !Empty(TRB->ED0_ALTERA)
            cOpcao:= "A"
            TRB->ED0_OK := cMarca
         ElseIf Empty(TRB->ED0_DT_ENV) .And. Empty(TRB->ED0_AC)
            cOpcao:= "I"
            TRB->ED0_OK := cMarca
         ElseIf Empty(TRB->ED0_DT_ENV) .And. !Empty(TRB->ED0_AC)
            cOpcao:= "A"
            TRB->ED0_OK := cMarca
         ElseIf lSeek
            TRB->ED0_OK := cMarca
         ElseIf !Empty(TRB->ED0_DT_ENV) .And. EasyGParam("MV_EDC0005",,.F.)  // ALS - 08/01/2008 
         // Caso não tenha retorno mas ja foi enviado verifica se deve enviar novamente
         	If MsgYesNo(STR0066)
         	   cOpcao:= "I"
               TRB->ED0_OK := cMarca         
         	EndIf 
         Else
            TRB->(Dbskip())
            Loop
         Endif
      EndIf
   Else
      TRB->(dbSkip())
      Loop
   Endif
   
   ED0->(dbSeek(cFilED0+TRB->ED0_PD))
                                                                 
   If cOpcao == "A" .And. TRB->ED0_CDIAG == "1"
      TRB->(DBSKIP())
      Loop
   Endif

   If TRB->ED0_CDIAG == "1"
      cOpcao := "C"
      Reclock("ED0",.F.)
      ED0->ED0_CDIAG := "2" //Limpa o Flag, voltando ao default(Nao)
      ED0->(MsUnlock())
   Endif
                      
   IncProc(STR0014) //"Gerando Arquivo .TXT"
   nSeq := 1
   
   //AAF 
   If lRetorno 
      lGeraTxt := .T.
   EndIf
   
   If cOpcao $ ("I/A/S")
      If File(cDir_Or+cNome)
         nHandle := EasyOpenFile(cDir_Or+cNome,FO_READWRITE+FO_EXCLUSIVE)
         FSeek(nHandle,(-13.5),FO_READWRITE) // Segundo parametro é o deslocamento - Len(####eof#####) em Bytes
      Else
         If (nHandle := EasyCreateFile(cDir_Or + cNome, FC_NORMAL)) == -1
            MSGINFO(STR0012,STR0013) //LRL 22/01/04 Help(" ",1,"AVG0005198")  //"Arquivo Texto nao pode ser criado."###"Erro."
            Return .F.
         Endif
      Endif
      
      Do While File(cDir_Or +"DB"+StrZero(nSeq,6,0)+".INC") .OR. (nHandle1 := EasyCreateFile((cDir_Or +"DB"+StrZero(nSeq,6,0)+".INC"), FC_NORMAL)) = -1
         nSeq += 1
         CFileOutput := cDir_Or +"DB"+StrZero(nSeq,6,0)+".INC"// ALS - 19/05/2008 Armazena o endereço do arquivo de saida
      EndDo
   
      FWRITE(nHandle, ("DB"+StrZero(nSeq,6,0)+".INC")+chr(13)+chr(10)) // Para gravar os nomes dos arquivo no DBTOT.AVG
      	         
      // ALS - 13/12/2007 - Se estiver ativo o envio para Siscomex Web adicionar campo de status
      //FWRITE(nHandle1,STR0043+TRB->ED0_PD+Left(TRB->ED0_AC,11)+cOpcao+chr(13)+chr(10)) //"PED"
      FWRITE(nHandle1,STR0043+TRB->ED0_PD+Left(TRB->ED0_AC,11)+cOpcao+if(EasyGParam("MV_EDC0005",,.F.),TRB->ED0_STATUS, "")+chr(13)+chr(10)) //"PED"
   Endif

   If !lRetorno .AND. (!Empty(TRB->ED0_ALTERA) .Or. cOpcao $ "I")
      
      SYT->(DbSeek(xFilial()+TRB->ED0_IMPORT))
                                           
      FWRITE(nHandle1,STR0044+SYT->YT_CGC+If(TRB->ED0_MODAL == "1", "S", "N")+;  //"CAP"
          If(TRB->ED0_CAPITA == "1", "S", "N")+TRB->ED0_TIPOAC+;
          EDC_INTDEC(TRB->ED0_FRETE, 11, 2)+EDC_INTDEC(TRB->ED0_SEGURO, 11, 2)+;
          TRB->ED0_CNPJ1+TRB->ED0_CNPJ2+TRB->ED0_CNPJ3+TRB->ED0_CNPJ4+TRB->ED0_CNPJ5+;
          TRB->ED0_CNPJ6+TRB->ED0_CNPJ7+TRB->ED0_CNPJ8+TRB->ED0_CNPJ9+TRB->ED0_CNPJ10+;
          TRB->ED0_CNPJ11+TRB->ED0_CNPJ12+TRB->ED0_CNPJ13+TRB->ED0_CNPJ14+TRB->ED0_CNPJ15+;
          TRB->ED0_CNPJ16+TRB->ED0_CNPJ17+TRB->ED0_CNPJ18+TRB->ED0_CNPJ19+TRB->ED0_CNPJ20+;
          if(EasyGParam("MV_EDC0005",,.F.), EDC_INTDEC(AC401CalcPer("ED2",TRB->ED0_PD), 11, 2), "")+chr(13)+chr(10)) // ALS - 13/12/2007 - Se estiver ativo o envio para Siscomex Web adicionar campo de percentual sub-residuo	         
          lGeraTxt := .T.          
   Endif
                                              
   If !lRetorno .AND. ((TRB->ED0_ALTERA $ "2,3") .Or. cOpcao == "I")
       
      cPedAtu:= TRB->ED0_PD
      //ED3->(DbSeek(xFilial("ED3")+TRB->ED0_PD))
      ED3->(DbSetOrder(2))
      ED3->(DbSeek(xFilial("ED3")+TRB->ED0_AC))
   
      //Do While !ED3->(EOF()) .And. ED3->ED3_FILIAL == cFilED3 .And. ED3->ED3_PD == TRB->ED0_PD
      Do While !ED3->(EOF()) .And. ED3->ED3_FILIAL == cFilED3 .And. ED3->ED3_AC == TRB->ED0_AC
          
         If ED3->ED3_PD <> cPedAtu
            ED3->(dbSkip())
            Loop
         Endif

         If cOpcao == "A" .And. Empty(ED3->ED3_ALTERA)
            ED3->(DBSKIP())
            Loop
         Endif
                  
         /*(cAliasSB1)->(DbSeek(cFilSB1Aux+ED3->ED3_PROD))
              
         mDescri1 := MSMM(SB1->B1_DESC_GI,AVSX3("B1_VM_GI",03))
         mDescri1 := StrTran(mDescri1 , CHR(13)+CHR(10), " ")
         mDescri1 := Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" - "+mDescri1
         mDescri1 := Left(mDescri1,750)*/
         EE2->(DbSeek(xFilial("EE2")+"3*"+AVKey(IncSpace(EasyGParam("MV_AVG0035",,"PORT. "), 6, .F.)+"-PORTUGUES","EE2_IDIOMA")+AVKey(ED3->ED3_PROD,"EE2_COD")))
         If EasyGParam("MV_EDC0011",,.T.)      // GFP - 25/03/2013
            mDescri1 := Alltrim(ED3->ED3_PROD)+" - " + MSMM_DR(EE2->EE2_TEXTO,60)
         Else
            SB1->(DbSeek(xFilial("SB1")+AvKey(ED3->ED3_PROD,"B1_COD")))
            mDescri1 := Alltrim(ED3->ED3_PROD)+" - " + MSMM(SB1->B1_DESC_GI,AVSX3("B1_VM_GI",3))
            mDescri1 := StrTran(mDescri1 , CHR(13)+CHR(10), " ")
         EndIf
         
         mDescri1 := StrTran( mDescri1, CRLF , " " )
         mDescri1 := StrTran( mDescri1, Chr(13) , " " )
         Do While At("  ",mDescri1) > 0
            mDescri1 := StrTran( mDescri1, "  " , " " )
         EndDo
         mDescri1 := Left(mDescri1,750)
       
         If Len(mDescri1) < 750
            nDifer1  := 750 - Len(mDescri1)  //Calcula a diferenca entre o tamanho da descricao e o maximo permitido
            mDescri1 += Space(nDifer1)
         Endif
         
         If EasyEntryPoint("EDCOR100") //AAF 10/11/2017
			ExecBlock("EDCOR100",.F.,.F.,{"DESCRICAO_PRODUTO_EXP"})
		 Endif

		// ALS - 13/12/2007 - Se estiver ativo o envio para Siscomex Web altera a saida da linda CNE                     
         if EasyGParam("MV_EDC0005",,.F.)
             FWRITE(nHandle1,STR0045+Left(ED3->ED3_NCM, 8)+If(cOpcao == "A" .And. ED3->ED3_ALTERA == "1", "I",cOpcao)+ED3->ED3_SEQSIS+chr(13)+chr(10))//"CNE"                  
         else
             FWRITE(nHandle1,STR0045+Left(ED3->ED3_NCM, 8)+If(cOpcao == "A" .And. ED3->ED3_ALTERA == "1", "I", If(cOpcao == "A",ED3->ED3_SEQSIS+cOpcao,cOpcao))+chr(13)+chr(10))//"CNE"         
         end if
         FWRITE(nHandle1,STR0046+mDescri1+chr(13)+chr(10))//"DNE"
         FWRITE(nHandle1,STR0047+EDC_INTDEC(ED3->ED3_QTDNCM, 9, 5)+EDC_INTDEC(ED3->ED3_VAL_EM, 11, 2)+; //Qtde Ncm Int + Qtde Ncm Dec + Vl. Emb. Int + Vl. Emb. Dec ###"INE"
         EDC_INTDEC(ED3->ED3_PERCAG, 03, 2)+EDC_INTDEC(ED3->ED3_VAL_SE, 11, 2)+chr(13)+chr(10)) //Perc. do Ag. Int+ Perc. do Ag. Dec + Vl s/ Cob Int + Vl s/ Cob Dec
                  
         RecLock("ED3",.F.)
         ED3->ED3_ALTERA := " " // Limpa o Flag
         ED3->(MsUnLock())
                           
         ED3->(DBSKIP())
      Enddo
                        
      //ED4->(DbSeek(xFilial("ED4")+TRB->ED0_PD))
      ED4->(DbSetOrder(2))
      ED4->(DbSeek(xFilial("ED4")+TRB->ED0_AC))
      
      //Do While !ED4->(EOF()) .And. ED4->ED4_FILIAL == cFilED4 .And. ED4->ED4_PD == TRB->ED0_PD
      Do While !ED4->(EOF()) .And. ED4->ED4_FILIAL == cFilED4 .And. ED4->ED4_AC == TRB->ED0_AC
         
         If ED4->ED4_PD <> cPedAtu
            ED4->(dbSkip())
            Loop
         Endif
           
         If cOpcao == "A" .And. Empty(ED4->ED4_ALTERA)
            ED4->(DBSKIP())
            Loop
         Endif
         
         SB1->(DbSeek(cFilSB1+ED4->ED4_ITEM))
                
         If TRB->ED0_TIPOAC == "06"
            RecLock("ED4",.F.)
            ED4->ED4_NCM := "99999999"
            ED4->(MsUnLock())
         Endif
                        
         mDescri := MSMM(SB1->B1_DESC_GI,AVSX3("B1_VM_GI",03))
         mDescri := StrTran(mDescri , CHR(13)+CHR(10), " ")
         mDescri := Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_DESC)+" - "+mDescri
         mDescri := Left(mDescri,750)
      
         If Len(mDescri) < 750
            nDifer  := 750 - Len(mDescri)//Calcula a diferenca entre o tamanho da descricao e o maximo permitido
            mDescri += Space(nDifer)
         Endif
         
         If EasyEntryPoint("EDCOR100") //AAF 10/11/2017
			ExecBlock("EDCOR100",.F.,.F.,{"DESCRICAO_PRODUTO_IMP"})
		 Endif

         If ED4->ED4_CAMB == '1'
            If !Empty(ED4->ED4_SEQSIS)  // GFP - 11/11/11
         	// ALS - 13/12/2007 - Se estiver ativo o envio para Siscomex Web altera a saida da linda CNI                     
               if EasyGParam("MV_EDC0005",,.F.)                 
                   FWRITE(nHandle1,STR0048+Left(ED4->ED4_NCM,8)+If(cOpcao == "A" .And. ED4->ED4_ALTERA == "1", "I",cOpcao)+ED4->ED4_SEQSIS+chr(13)+chr(10)) //"CNI"
               else
                   FWRITE(nHandle1,STR0048+Left(ED4->ED4_NCM,8)+If(cOpcao == "A" .And. ED4->ED4_ALTERA == "1", "I", If(cOpcao == "A",ED4->ED4_SEQSIS+cOpcao,cOpcao))+chr(13)+chr(10)) //"CNI"
               endif
            EndIf         
            FWRITE(nHandle1,STR0049+mDescri+chr(13)+chr(10)) //"DNI"
            FWRITE(nHandle1,STR0050+If(TRB->ED0_TIPOAC == "06" .And. Empty(ED4->ED4_QTDNCM),; //"INC"
            Space(AVSX3("ED4_QTDNCM",3)), EDC_INTDEC(ED4->ED4_QTDNCM, 09, 5))+; //Qtde Ncm Int + Qtde Ncm Dec
            EDC_INTDEC(ED4->ED4_VALEMB, 11, 2)+; //Vl. Emb. Int + Vl. Emb Dec
            If(Posicione("ED2",3,xFilial("ED2")+ED4->ED4_PD+ED4->ED4_NCM,"ED2_VLCOPE") == "N",EDC_INTDEC(0, 02, 2),EDC_INTDEC(ED4->ED4_PERCPE, 02, 2))+chr(13)+chr(10)) //Perc. Per. Inte + Perc. Per. Dec  // GFP - 25/03/2013
         
         Else
            // GFP - 11/11/11
            IF !Empty(ED4->ED4_SEQSIS)
               // ALS - 13/12/2007 - Se estiver ativo o envio para Siscomex Web altera a saida da linda CNS                     
               if EasyGParam("MV_EDC0005",,.F.)                 
                   FWRITE(nHandle1,STR0051+Left(ED4->ED4_NCM,8)+If(cOpcao == "A" .And. ED4->ED4_ALTERA == "1", "I",cOpcao)+ED4->ED4_SEQSIS+chr(13)+chr(10)) //"CNS"
               else
                   FWRITE(nHandle1,STR0051+Left(ED4->ED4_NCM,8)+If(cOpcao == "A" .And. ED4->ED4_ALTERA == "1", "I", If(cOpcao == "A", ED4->ED4_SEQSIS+cOpcao,cOpcao))+chr(13)+chr(10)) //"CNS"
               end if 
            ENDIF 
            FWRITE(nHandle1,STR0052+mDescri+chr(13)+chr(10)) //"DNS"
            FWRITE(nHandle1,STR0053+If(TRB->ED0_TIPOAC == "06" .And. Empty(ED4->ED4_QTDNCM),; //"INS"
            Space(AVSX3("ED4_QTDNCM",3)),EDC_INTDEC(ED4->ED4_QTDNCM, 09, 5))+; //Qtde Ncm Int + Qtde Ncm Dec
            EDC_INTDEC(ED4->ED4_VALEMB, 11, 2)+; //Vl. Emb. Int + Vl. Emb. Dec
            If(Posicione("ED2",3,xFilial("ED2")+ED4->ED4_PD+ED4->ED4_NCM,"ED2_VLCOPE") == "N",EDC_INTDEC(0, 02, 2),EDC_INTDEC(ED4->ED4_PERCPE, 02, 2))+chr(13)+chr(10)) //  Perc. Per. Inte + Perc. Per. Dec  // GFP - 25/03/2013

         Endif
         
         RecLock("ED4",.F.)
         ED4->ED4_ALTERA := " " // Limpa o Flag
         ED4->(MsUnLock())
                                            
         ED4->(DBSKIP())
      Enddo
      lGeraTxt := .T.
   Endif
   
   If cOpcao $ ("I/A/S")
      FWRITE(nHandle,cFim)

      FCLOSE(nHandle)
      
      FWRITE(nHandle1,cFim)
         
      FCLOSE(nHandle1)
   Endif
   
   RecLock("ED0",.F.)
   ED0->ED0_ARQ    := "DB"+StrZero(nSeq,6,0)+".INC"
   ED0->ED0_DT_ENV := dDataBase
   ED0->(MsUnLock())
   
   If cOpcao = "A"
      RecLock("ED0",.F.)
      ED0->ED0_ALTERA := " "
      ED0->(MsUnLock())
   Endif

   cOpcaoAt:= cOpcao
   lPrim:= .T.
   
   If lSeek
      
      //If ED6->ED6_TIPO == "4"
      //   cOpcao := "P"
      //Else
      //   cOpcao := "E"
      //Endif
            
      Do While !ED6->(EOF()) .And. ED6->ED6_FILIAL == cFilED6 .And. ED6->ED6_PD == TRB->ED0_PD
         
         If ED6->ED6_TIPO <> "4"
            cOpcaoAt:= "E"
         Else
            cOpcaoAt:= "P"
         Endif
          
         //If cOpcaoAt <> cOpcao
	     //   lPrim:= .T.
         //Endif
         
         If lPrim
            If File(cDir_Or+cNome)
               nHandle2 := EasyOpenFile(cDir_Or+cNome,FO_READWRITE+FO_EXCLUSIVE)
               FSeek(nHandle2,(-13.5),FO_READWRITE) // Segundo parametro é o deslocamento - Len(####eof#####) em Bytes
            Else
               If (nHandle2 := EasyCreateFile(cDir_Or + cNome, FC_NORMAL)) == -1
                  MSGINFO(STR0012,STR0013)//LRL 22/01/04 Help(" ",1,"AVG0005198")  //"Arquivo Texto nao pode ser criado."###"Erro."
                  Return .F.
               Endif
            Endif
   
            Do While File(cDir_Or +"DB"+StrZero(nSeq,6,0)+".INC") .OR. (nHandle3 := EasyCreateFile((cDir_Or +"DB"+StrZero(nSeq,6,0)+".INC"), FC_NORMAL)) = -1
               nSeq += 1
               CFileOutput := cDir_Or +"DB"+StrZero(nSeq,6,0)+".INC"// ALS - 08/01/2008 Armazena o endereço do arquivo de saida
            EndDo
   
            FWRITE(nHandle2, ("DB"+StrZero(nSeq,6,0)+".INC")+chr(13)+chr(10)) // Para gravar os nomes dos arquivo no DBTOT.AVG
            
         // ALS - 13/12/2007 - Se estiver ativo o envio para Siscomex Web adicionar campo de status	                        
            FWRITE(nHandle3,STR0043+TRB->ED0_PD+Left(TRB->ED0_AC,11)+cOpcaoAt+if(EasyGParam("MV_EDC0005",,.F.),TRB->ED0_STATUS, "")+chr(13)+chr(10)) //"PED"
            
            lPrim:= .F.
         Endif
            
         //If ED6->ED6_TIPO <> "4"
         //   cOpcao:= "E"
         //Else
         //   cOpcao:= "P"
         //Endif
         
         If ED6->ED6_TIPO == "2"
            FWRITE(nHandle3,STR0045+Left(ED6->ED6_NCM, 8)+ED6->ED6_SEQSIS+cOpcaoAt+chr(13)+chr(10)) //"CNE"
         ElseIf ED6->ED6_TIPO == "3"
            If ED4->ED4_CAMB == "1"
               FWRITE(nHandle3,STR0048+Left(ED6->ED6_NCM, 8)+ED6->ED6_SEQSIS+cOpcaoAt+chr(13)+chr(10)) //"CNI"
            Else
               FWRITE(nHandle3,STR0051+Left(ED6->ED6_NCM, 8)+ED6->ED6_SEQSIS+cOpcaoAt+chr(13)+chr(10)) //"CNS"
            Endif
         ElseIf ED6->ED6_TIPO == "4"
            dData := 0
            if EasyGParam("MV_EDC0005",,.F.)    // ALS - 13/12/2007 - Se estiver ativo o envio para Siscomex Web 	          
               Do Case                 
                  Case !Empty(ED0->ED0_DT_PR3)
                     dData:= (ED0->ED0_DT_PR3 - ED0->ED0_DT_PR2)
                  Case !Empty(ED0->ED0_DT_PR2)
                     dData:= (ED0->ED0_DT_PR2 - ED0->ED0_DT_PR1)
                  Case !Empty(ED0->ED0_DT_PR1)
                     dData:= 0                  
                  Otherwise
                     dData:= 0                  
               EndCase
            else
                 Do Case
                  Case !Empty(ED0->ED0_DT_ENC)
                     dData:=(ED0->ED0_DT_ENC - dDataBase)
                  Case !Empty(ED0->ED0_DT_PR3)
                     dData:= (ED0->ED0_DT_PR3 - dDataBase)
                  Case !Empty(ED0->ED0_DT_PR2)
                     dData:= (ED0->ED0_DT_PR2 - dDataBase)
                  Case !Empty(ED0->ED0_DT_PR1)
                     dData:= (ED0->ED0_DT_PR1 - dDataBase)
                  Case !Empty(ED0->ED0_DT_VA2)
                     dData:=(ED0->ED0_DT_VA2 - dDataBase)
                  Case !Empty(ED0->ED0_DT_VA1)
                     dData:=(ED0->ED0_DT_VA1 - dDataBase)
               EndCase
            endif

            FWRITE(nHandle3,STR0054+StrZero(dData, 3,0)+chr(13)+chr(10)) //"DPR"
         Endif
                  
         RecLock("ED6",.F., .T.)
         ED6->(DBDELETE()) // Apaga o Registro
         ED6->(MsUnLock())
         
         ED6->(dbSkip())
         
         If ED6->ED6_TIPO == "4"
            cOpcao:= "P"
         Else
            cOpcao:= "E"
         Endif
         
         //If (!ED6->(EOF()) .And. cOpcaoAt <> cOpcao) .Or. ED6->(EOF())
         If (!ED6->(EOF()) .And. cOpcaoAt <> cOpcao) .Or. !ED6->(DbSeek(xFilial("ED6")+TRB->ED0_PD))
            FWRITE(nHandle2,cFim)
      
            FCLOSE(nHandle2)
    
            FWRITE(nHandle3,cFim)
  
            FCLOSE(nHandle3)
            
            lPrim:= .T.
         Endif
         
         lGeraTxt:= .T.
      EndDo
      
      /*
      FWRITE(nHandle2,cFim)
     
      FCLOSE(nHandle2)
          
      FWRITE(nHandle3,cFim)
  
      FCLOSE(nHandle3)
      */
   Endif

   TRB->(Dbskip())
Enddo

If lGeraTxt
   // ALS - 13/12/2007 - Se estiver ativo o envio para Siscomex Web altera a saida da linda CNS                     
   if EasyGParam("MV_EDC0005",,.F.)   
      RecLock("ED0",.F.)
      ED0->ED0_STATUS  := "1"
      ED0->(MsUnLock())
   endIF
   MsgInfo(STR0015, STR0005) //"A geracao de Arquivo TXT foi concluida com Sucesso"###"Mensagem" 
   If (Empty(cFileOutput), CFileOutput := cDir_Or +"DB"+StrZero(nSeq,6,0)+".INC",) //WFS 08/10/2008
   if EasyGParam("MV_EDC0005",,.F.)    // ALS - 08/01/2008 - Se estiver ativo o envio para Siscomex Web 
        WinExec(EasyGParam("MV_EDC0006",,"c:\EasyWebWriter.exe")+" "+CFileOutput+","+Or100Key())
   Endif
Else
   Help(" ",1,"AVG0005200") //MsgInfo(STR0033,STR0017) //"Nao existem Registros a serem gerados!"##"Atencao"
   Return .F.
Endif

TRB->(Dbgotop())

lRet := .T.

If lRetorno
   Processa({|lEnd| lRet := WaitReturn(cDir_Or +"DB"+StrZero(nSeq,6,0),@lEnd) },STR0068,,.T.)//"Aguardando execução do EasyWebWriter"
EndIf

Return lRet

*--------------------------------------------------*
Static Function EDC_INTDEC(xConteudo, nTam, nDec)
*--------------------------------------------------*
Local xCont, nInteiro:=0 , nDecimal:=0
// LOCAL nPos,nPos1 -- ACSJ - 01/12/2004 - Variavel não é usada.
Local cRetorno
// LOCAL nZeros := 0, -- ACSJ - 01/12/2004 - Variavel não é usada.

xCont := Alltrim(Str(xConteudo, nTam+nDec+1, nDec ))
nPos  := AT(".", xCont)

If nPos > 0
   nInteiro := Val(Left(xCont , nPos -1))
   nDecimal := Val(Right(xCont, nDec))
   cRetorno := Strzero(nInteiro, nTam) +Strzero(nDecimal, nDec)
Else
   nInteiro := Strzero(Val(xCont), nTam)
   nDecimal := Strzero(0, nDec)
   cRetorno := nInteiro + nDecimal
Endif

Return(cRetorno)

*---------------------------*
Function EdcOr100Ret(cExt)
*---------------------------*
Local cPedido:= Space(13), cAto, dData:="", nHora:="", nDiag, cRetorno, cRetTot := ""
Local cDefer, dDt_Reg, dDt_Val, Nro_Env, nRegua:=0, n, cStsRet := "", cTypeRet := ""
Local aFilesOk := {}, cDescErr := "", aFiles := {}, nIncrOk := 0, nIncrErr := 0 
Local cDesc :="", cWarn :=""

/*Nopado por WFS em 16/10/2009
If cExt == ".OK"
   IF !OR100GeraTxt(.T.)
      Return .F.
   EndIf
EndIf*/
   
//If(Right(cDir_Des,1) <> "\", cDir_Des += "\",)
If(Right(cDir_OR,1) <> "\", cDir_OR += "\",)

/*
IF ! AvIsDir(Left(cDir_Des,Len(cDir_Des)-1))  // Path nao existe
   Help(" ",1,"AVG0005201",cDir_Des+STR0032,1,11) //Msginfo(STR0031+cDir_Des+STR0032, STR0005) //"Diretorio "##" especificado nao foi encontrado."##Mensagem
   If cExt == ".OK"
      Return lRet
   Else
      Return lRetorno
   Endif
EndIf

aFilesOk  := ASORT(Directory(cDir_Des+"*.OK"),,,{|N1,N2| N1[1] < N2[1]})
aFilesErr := ASORT(Directory(cDir_Des+"*.ERR"),,,{|N1,N2| N1[1] < N2[1]})
*/

IF !AvIsDir(Left(cDir_OR,Len(cDir_OR)-1))  // Path nao existe
   Help(" ",1,"AVG0005201", ,cDir_OR+STR0032,1,11) //Msginfo(STR0031+cDir_Des+STR0032, STR0005) //"Diretorio "##" especificado nao foi encontrado."##Mensagem
   If cExt == ".OK"
      Return lRet
   Else
      Return lRetorno
   Endif
EndIf

aFilesOk  := ASORT(Directory(cDir_OR+"db*.OK"),,,{|N1,N2| N1[1] < N2[1]})
aFilesErr := ASORT(Directory(cDir_OR+"db*.ERR"),,,{|N1,N2| N1[1] < N2[1]})

If cExt == ".OK"
   nTotFile := Len(aFilesOk)
Else
   nTotFile := Len(aFilesErr)
Endif

If nTotFile == 0
   If cExt == ".OK"
      Return lRet
   Else
      Return lRetorno
   Endif
Endif

For n:= 1 to nTotFile
   
   nHandle := EasyOpenFile(cDir_OR+If(cExt==".OK",aFilesOk[n][1],aFilesErr[n][1]),FO_READ+FO_EXCLUSIVE)
   
   PROCREGUA(10)
   
   nLin := 1

   if EasyGParam("MV_EDC0005",,.F.)    // ALS - 13/12/2007 - Se estiver ativo o envio para Siscomex Web 
      While .T.
         IncProc(STR0036+cExt)//"Atualizando Dados de Retorno do Siscomex "
         cConteudo := OR100POSLINHA(nHandle,nLin)   
      
         If LEFT(cConteudo,12) == STR0055 //"####eof#####" //Fim do Arquivo
            Exit
         EndIf   
      
         cTypeRet:= SUBSTR(cConteudo,01,3)
         cPedido := Alltrim(SUBSTR(cConteudo,04,13))
         cAto    := Alltrim(SUBSTR(cConteudo,17,11))
         dData   := SUBSTR(cConteudo,34,2) + "/" + SUBSTR(cConteudo,32,2) + "/" + SUBSTR(cConteudo,28,4)
         dDt_Val := SUBSTR(cConteudo,42,2) + "/" + SUBSTR(cConteudo,40,2) + "/" + SUBSTR(cConteudo,36,4)
         cStsRet := Alltrim(SUBSTR(cConteudo,44,50))
         
         nLin+=1
         cDesc := OR100POSLINHA(nHandle,nLin)
         cDesc := Alltrim(StrTran(cDesc , "|",Chr(13)+Chr(10)))         
         
         nLin+=1
         cWarn := OR100POSLINHA(nHandle,nLin)
         cWarn := Alltrim(StrTran(cWarn , "|",Chr(13)+Chr(10)))
         
         If !Empty(cPedido) .AND. ED0->(DBSEEK(cFilED0+cPedido))
         
            RecLock("ED0",.F.)
            //ED0->ED0_PD := cPedido
            ED0->ED0_AC := cAto
             
            WorkRel->(DbAppend())
            WorkRel->PEDIDO  := Alltrim(cPedido)
            WorkRel->ATOCON  := Alltrim(cAto)
            WorkRel->RETORNO := "OK"
            WorkRel->MENSA   := STR0037 //"Pedido de DrawBack Aceito"
         
         
            If cTypeRet == "PRE" // Prediagnostico   
               ED0->ED0_STATUS  := "2"  // Digitado    
               cRetTot += STR0065+Chr(13)+Chr(10)+cDesc+Chr(13)+Chr(10)+cWarn // STR0065 "------ Mensagem ------"        
         
            elseIf cTypeRet == "CPL" .or. cTypeRet == "PST" .or. cTypeRet == "STS" // Complete Or Postpone // JWJ 18/12/09
               
               If ("DEFERIDO" $ upper(cStsRet) .and. !"INDEFERIDO" $ upper(cStsRet))   //Deferido
                  ED0->ED0_DEFERI := cTod(dData)
                  ED0->ED0_DT_REG := CtoD(dData) //WFS 19/10/2009
                  ED0->ED0_DT_VA1 := cTod(dDt_Val)
                  ED0->ED0_STATUS  := "6"  // Deferido
               
                  cRetTot := STR0056+dData+Chr(13)+Chr(10) //"Data ---------- "             
                  cRetTot += STR0058+" SIM"+Chr(13)+Chr(10) //"Deferido ------ "            
                  cRetTot += STR0065+Chr(13)+Chr(10)+cDesc+Chr(13)+Chr(10)+cWarn // STR0065 "------ Mensagem ------"
                                  
               ElseIf ("INDEFERIDO" $ upper(cStsRet))   //Indeferido 
                  ED0->ED0_STATUS  := "4"  // Indeferido
                              
                  cRetTot := STR0056+dData+Chr(13)+Chr(10) //"Data ---------- "             
                  cRetTot += STR0058+" NÃO"+Chr(13)+Chr(10) //"Deferido ------ "            
                  cRetTot += STR0065+Chr(13)+Chr(10)+cDesc+Chr(13)+Chr(10)+cWarn // STR0065 "------ Mensagem ------"

               ElseIf ("ANÁLISE" $ upper(cStsRet))   //Analise 
                  ED0->ED0_STATUS  := "3"  // Para Analise 
                  ED0->ED0_DT_VA1 := cTod(dDt_Val)  
                                                                
                  cRetTot := STR0056+dData+Chr(13)+Chr(10) //"Data ---------- "      
                  cRetTot += STR0065+Chr(13)+Chr(10)+cDesc+Chr(13)+Chr(10)+cWarn // STR0065 "------ Mensagem ------"
                    
               Else 
                  ED0->ED0_STATUS  := "2"  // Digitado
                  cRetTot += STR0065+Chr(13)+Chr(10)+cDesc+Chr(13)+Chr(10)+cWarn // STR0065 "------ Mensagem ------"   
               Endif
         
            endIf
         
            If !Empty(ED0->ED0_RET)
               cAcumRet:= MSMM(ED0->ED0_RET)             
            Else
               cAcumRet := ""
            EndIf
            cRetTot += If(!Empty(cAcumRet),cAcumRet,"") 
         
            MSMM(,60,,cRetTot,1,,,"ED0","ED0_RET")

            ED0->(MsUnLock())

         EndIf         
         nLin+=1
      EndDo
   else
      While .T.

         IncProc(STR0036+cExt)//"Atualizando Dados de Retorno do Siscomex "
  
         If nRegua > 10
            nRegua :=0
            PROCREGUA(10)
         Endif
     
         nRegua++
         cConteudo := OR100POSLINHA(nHandle,nLin)
 
         If LEFT(cConteudo,12) == STR0055 //"####eof#####" //Fim do Arquivo
            Exit
         EndIf

         If cExt == ".ERR"
            If Substr(cConteudo,16,01) == "/" .And. Substr(cConteudo,26,01) == ":" //Para identificar a Primeira linha
               cPedido  := SUBSTR(cConteudo,01,13)
               dData    := SUBSTR(cConteudo,14,10)
               nHora    := SUBSTR(cConteudo,24,05)
            Else
               cDescErr += SUBSTR(cConteudo,02,80)
            Endif
         Else
            cPedido := SUBSTR(cConteudo,01,13)
            cAto    := SUBSTR(cConteudo,14,11)
            dData   := SUBSTR(cConteudo,25,10)
            nHora   := SUBSTR(cConteudo,35,05)
            Nro_env := SUBSTR(cConteudo,40,02)
            cDefer  := SUBSTR(cConteudo,42,01)

            If cDefer == "S"   //Deferido
               dDt_Reg  := SUBSTR(cConteudo,43,10)
               dDt_Val  := SUBSTR(cConteudo,53,10)
            Else
               nDiag    := SUBSTR(cConteudo,43,03)
               cRetorno := SUBSTR(cConteudo,46,1554)
           Endif
         
         Endif
                  
         If !Empty(cPedido) .AND. ED0->(DBSEEK(cFilED0+cPedido))

            If cExt == ".OK"         
               RecLock("ED0",.F.)
               //ED0->ED0_PD := cPedido
               ED0->ED0_AC := cAto
             
               WorkRel->(DbAppend())
               WorkRel->PEDIDO  := Alltrim(cPedido)
               WorkRel->ATOCON  := Alltrim(cAto)
               WorkRel->RETORNO := "OK"
               WorkRel->MENSA   := STR0037 //"Pedido de DrawBack Aceito"

               If cDefer == "S"   //Deferido
                  ED0->ED0_DEFERI := cTod(dData)
                  ED0->ED0_DT_REG := CtoD(dData) //WFS 19/10/2009
                  cRetTot := STR0056+dData+Chr(13)+Chr(10) //"Data ---------- "
                  cRetTot += STR0057+nHora+Chr(13)+Chr(10) //"Hora ---------- "
                  //cRetTot += STR0058+cDefer //"Deferido ------ "
                  cRetTot += STR0058+" Sim" //"Deferido ------ "
               Else
                  cRetTot := STR0056+dData+Chr(13)+Chr(10) //"Data ---------- "
                  cRetTot += STR0057+nHora+Chr(13)+Chr(10) //"Hora ---------- "
                  cRetTot += STR0059+cRetorno //"Retorno ------- "
               Endif

               cAcumRet:= MSMM(ED0->ED0_RET)
             
               cRetTot += If(!Empty(cAcumRet),Chr(13)+Chr(10)+cAcumRet,"")
            
               MSMM(,60,,cRetTot,1,,,"ED0","ED0_RET")
    
               ED0->(MsUnLock())
            Else
            
               WorkRel->(DbAppend())
               WorkRel->PEDIDO  := If(Empty(cPedido), SUBSTR(cConteudo,01,13), Alltrim(cPedido))
               WorkRel->ATOCON  := "-"
               WorkRel->RETORNO := STR0060 //"ERRO"
               WorkRel->MENSA   := SUBSTR(cConteudo,02,80)
            
               If Mod(nLin,25) == 0            
                  mMensa += If(!Empty(mMensa), Chr(13)+Chr(10)+STR0061+cPedido, STR0061+cPedido)   //"Ped. - "
           
                  RecLock("ED0",.F.)
                  //ED0->ED0_PD     := cPedido
                  //ED0->ED0_DEFERI := cTod(dData) Verificar
                  cRetTot := STR0056+dData+Chr(13)+Chr(10) //"Data ---------- "
                  cRetTot += STR0057+nHora+Chr(13)+Chr(10) //"Hora ---------- "
                  cRetTot += STR0062+cDescErr  //"Descricao ----- "
                 
                  cAcumRet:= MSMM(ED0->ED0_RET)

                  cRetTot += If(!Empty(cAcumRet),Chr(13)+Chr(10)+cAcumRet,"")
                              
                  MSMM(,60,,cRetTot,1,,,"ED0","ED0_RET")
               
                  ED0->(MsUnLock())
               Endif
            Endif
         Else
            mMensa += If(!Empty(mMensa), Chr(13)+Chr(10)+STR0061+cPedido, STR0061+cPedido)
            If cExt == ".OK"
               WorkRel->(DbAppend())
               WorkRel->PEDIDO  := Alltrim(cPedido)
               WorkRel->ATOCON  := Alltrim(cAto)
               WorkRel->RETORNO := STR0060 //"ERRO"
               WorkRel->MENSA   := STR0038 //"Pedido de DrawBack não está Cadastrado"
             ElseIf Mod(nLin,25) == 0
               WorkRel->(DbAppend())
               WorkRel->PEDIDO  := Alltrim(cPedido)
               WorkRel->ATOCON  := Alltrim(cAto)
               WorkRel->RETORNO := STR0060 //"ERRO"
               WorkRel->MENSA   := STR0038 //"Pedido de DrawBack não está Cadastrado"
            Endif
         Endif
            
         nLin+=1
         
      EndDo
   EndIf
   
   FCLOSE(nHandle)
   
   // Renomeia arquivo TXT
   
   If cExt == ".OK"
      nIncrOk  += 1
   Else
      nIncrErr += 1
   Endif
      
   cConvData  := If(Substr(dData,3,1) <> "/", Right(dtos(dDataBase),2)+SubStr(dtos(dDataBase),5,2)+SubStr(dtos(dDataBase),3,2),;
                 StrTran(SubStr(dData,1,5), "/","")+StrTran(SubStr(dData,9,2), "/",""))
   cConvHora  := If(Substr(nHora,3,1) <> ":", StrTran(SUBSTR(Time(),1,5),":",""), StrTran(nHora, ":",""))
   
   cArqOr  := If(cExt = ".OK",aFilesOk[n][1],aFilesErr[n][1])
   cArqDes := cConvData+cConvHora+If(!Empty(Nro_env), StrZero(Val(Nro_env),3,0), If(cExt=".OK", StrZero(nIncrOK,3,0), StrZero(nIncrErr,3,0)))+".OLD"
      
   //FRENAME(cDir_Des+cArqOr, cDir_Des+cArqDes )
   FRENAME(cDir_OR+cArqOr, cDir_OR+cArqOr+".OLD" )
         
Next
                        
If cExt == ".OK"
   Return .T.
Else
   Return !lRetorno
Endif

*------------------------------------------------*
STATIC FUNCTION OR100POSLINHA(nArquivo,nLinha)
*------------------------------------------------*
Local cBuffer:= Space(1)
Local cTexto:=""
nCont:=0
FSEEK(nArquivo,0,0)

DO WHILE nCont<>nLinha

   FREAD(nArquivo,@cBuffer,1)
   
   IF nCont==nLinha-1
      cTexto+=cBuffer
   ENDIF
   
   IF cBuffer==CHR(13)
      FREAD(nArquivo,@cBuffer,1)
      nCont++
   ENDIF
   
ENDDO

RETURN cTexto
                                           
*--------------------------------------------------*
Static Function Or100Relat(aDados,aRCampos,cStatus)
*--------------------------------------------------*
Local nRecno:=WorkRel->(RECNO()), cFiltro
aDados[7]:= STR0020+Space(76)+STR0064+Substr(cStatus,04,Len(cStatus)) // "Relatório de Retorno do Siscomex"

If Left(cStatus,1) = "1"
   cFiltro := STR0063 //"OK"
ElseIf Left(cStatus,1) = "2"
   cFiltro := STR0060 //"ERRO"
Endif

If Left(cStatus,1) <> "3"
   WorkRel->(DbSetFilter({|| WorkRel->RETORNO = cFiltro }, " WorkRel->RETORNO = cFiltro " ))
Else
   WorkRel->(DbSetFilter({|| .T. }," .T. " ))
Endif

WorkRel->(DbGotop())

E_Report(aDados,aRCampos)

WorkRel->(DbSetFilter({|| .T. }," .T. " ))

WorkRel->(Dbgoto(nRecno))

Return .T.


//TRP - 14/08/2006 - Definições do relatório personalizável
***************************
Static Function ReportDef()
***************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"ED0","ED1","ED2","ED3","ED4"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := { }

//Cria o objeto principal de controle do relatório.
//Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("EDCOR100",STR0020,"EDCOR1",{|oReport| ReportPrint(oReport)},"")

//Define o objeto com a seção do relatório
oSecao2 := TRSection():New(oReport,"Cabeçalho",{""},aOrdem)

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"Pedidos",aTabelas,aOrdem) 

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"PEDIDO"       ,"WorkRel"   ,STR0023      ,/*Picture*/                        ,AVSX3("ED0_PD", 3)            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"ATOCON"       ,"WorkRel"   ,STR0024      ,/*Picture*/                        ,AVSX3("ED0_AC", 3)            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"RETORNO"      ,"WorkRel"   ,STR0025      ,/*Picture*/                        ,05                            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"MENSA"        ,"WorkRel"   ,STR0026      ,/*Picture*/                        ,80                            ,/*lPixel*/,/*{|| code-block de impressao }*/)

//Definição das colunas de impressão da seção 2
TRCell():New(oSecao2,"Titulo"   ,""   , ""                     ,"@!"                               ,210           ,/*lPixel*/,{||STR0020+Space(150)+STR0064+cStatus})

oReport:Section("Cabeçalho"):Cell("Titulo"):SetCellBreak()
oReport:bOnPageBreak :={||oReport:Section("Cabeçalho"):PrintLine(),oReport:FatLine()} 

//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
//Local oSection := oReport:Section("Seção 1")

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.

TRPosition():New(oReport:Section("Pedidos"),"ED0",1,{|| xFilial("ED0") + cPedido})

TRPosition():New(oReport:Section("Pedidos"),"ED1",1,{|| xFilial("ED1") + cPedido})

TRPosition():New(oReport:Section("Pedidos"),"ED2",1,{|| xFilial("ED2") + cPedido})

TRPosition():New(oReport:Section("Pedidos"),"ED3",1,{|| xFilial("ED3") + cPedido})

TRPosition():New(oReport:Section("Pedidos"),"ED4",1,{|| xFilial("ED4") + cPedido})

//oSection:Print()
oReport:SetMeter(WorkRel->(EasyRecCount()))
WorkRel->( dbGoTop() )

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Pedidos"):Init()

//Inicio da impressão da seção 2. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Cabeçalho"):Init()

//Laço principal
Do While WorkRel->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Pedidos"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   WorkRel->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section("Pedidos"):Finish()
//Fim da impressão da seção 2
oReport:Section("Cabeçalho"):Finish() 

Return .T.
//***********************************************//
//Função......: Or100Key()
//Programador.: André Luiz dos Santos - ALS
//Objetivo....: Retorna a chave de validação para
//              chamada do sistema EasyWebWriter
//Data........: 07/01/08
//***********************************************//     
Static Function Or100Key
   Local cKey :="" 
   Local p1 := 0,p2 := 0,p3 := 0,p4 := 0  
   Local iSec := val(SUBSTR(TIME(), 7, 2)) + 1
   Local cDay := str( DAY(DATE()) + val(SUBSTR(TIME(), 1, 2)) + iSec )
     
   p1 := val(("60975" + alltrim(cDay))) * iSec
   p2 := val(("58825" + alltrim(cDay))) * iSec
   p3 := val(("51235" + alltrim(str(iSec)))) * iSec
   p4 := val(("51237" + alltrim(str(iSec)))) * iSec
   
   
  cKey := Right(alltrim(str(p1)), 5) + "-" + Right(alltrim(str(p2)), 5) + "-" + Right(alltrim(str(p3)), 5) + "-" + Right(alltrim(str(p4)), 5)


Return  cKey

Static Function WaitReturn(cFileName,lEnd)

Local cMensagem := ""   ,;
    lCreate   := .T.  ,;
    nHandle   := 0    ,;
    nSeconds  := 0    ,;
    nTimeOut  := 0

cMensagem := "Tempo máximo para execução"

nSeconds := 60*20  // Define o tempo máximo que o sistema aguardará a execução do conversor.exe
nTimeOut := Seconds()+nSeconds

ProcRegua(nSeconds)

Begin Sequence

   nHandle := F_ERROR

   // Tenta abrir o arquivo em modo exclusivo
   Do While !(File(cFileName+".OK") .AND. ( nHandle := EasyOpenFile(cFileName+".OK", FO_EXCLUSIVE ) ) # F_ERROR) .AND. !( File(cFileName+".ERR") .AND. ( nHandle := EasyOpenFile(cFileName+".ERR", FO_EXCLUSIVE ) ) # F_ERROR)

      // Se o cliente cancelar ou o exceder o tempo
      If lEnd .Or.  nTimeOut <= Seconds()
         lCreate := .F.
         Break
      EndIf

      nHour   := Int( nSeconds / 3600 )
      nMinute := Int( ( nSeconds - (nHour*3600) ) / 60 )
      nSecond := Int( nSeconds - (nHour*3600) - (nMinute*60) )
      
      IncProc(cMensagem+" ("+StrZero(nHour,2)+":"+StrZero(nMinute,2)+":"+StrZero(nSecond,2)+")")
      
      AvDelay(1)
      nSeconds--
      SysRefresh()

   EndDo

   If nHandle != F_ERROR
      FClose( nHandle )
   EndIf
      
End Sequence

Return lCreate
