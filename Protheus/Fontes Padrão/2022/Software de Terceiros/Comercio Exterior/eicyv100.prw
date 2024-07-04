#INCLUDE "Eicyv100.ch"
#include "AVERAGE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICYV100 ³ Autor ³AVERAGE-Regina H Perez³ Data ³ 01/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Lista de Engenharia               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function EICYV100

LOCAL cNomArq

IF ! AmIin(17) 
   Help("", 1, "AVG0003010")//"Função não autorizada para este módulo !","Aviso") 
   Return NIL
Endif

PRIVATE aRotina := MenuDef()  


PRIVATE cCadastro := OemtoAnsi(STR0006) //"Lista de Engenharia"

PRIVATE aHeader[0],aCampos:=Array(SYX->(FCOUNT()))//E_CriaTrab utiliza

cNomArq:=E_CriaTrab( "SYX" , {{"TB_RECNO","N",7,0},;
                              {"TRB_ALI_WT","C",03,0},;
                              {"TRB_REC_WT","N",10,0}})
IF !USED()
    Help(" ",1,"AVG0000029")
//   MsgiNFO(OemtoAnsi("NÆo foi poss¡vel abrir o arquivo tempor rio"))
   DBSELECTAREA("SX3")
   RETURN NIL
ENDIF

IndRegua("TRB",cNomArq+TEOrdBagExt(),"YX_COD_I")

SET INDEX TO (cNomArq+TEOrdBagExt())

PRIVATE aPos := { 15,  1, 75, 315 }

mBrowse( 6, 1,22,75,"SYV")

TRB->(E_EraseArq(cNomArq)) 

RETURN NIL                                                               

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya	
Data/Hora  : 17/01/07 - 11:55
*/
Static Function MenuDef()
Local aRotAdic
Local aRotina :=   { { STR0001      ,"AxPesqui"  , 0 , 1},;      
                     { STR0002      ,"YV100Manut", 0 , 2},;      
                     { STR0003      ,"YV100Manut", 0 , 3},;      
                     { STR0004      ,"YV100Manut", 0 , 4, 20 },; 
                     { STR0005      ,"YV100Manut", 0 , 2, 21 }}              
                      
//³ P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("IYV100MNU")
	aRotAdic := ExecBlock("IYV100MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina                


*------------------------------------*
Function YV100Manut(cAlias,nReg,nOpc)
*------------------------------------*

LOCAL cTitulo   := OemtoAnsi(STR0007) //"Cadastro Engenharia"
LOCAL I, aCamposDet,lTemItens:=.T.,aInfo
LOCAL bOk := {||nOpca:=1,If(YV100Valid("OKCAPA").And.Obrigatorio(aGets,aTela),oDlg:End(),nOpca := 0)}
LOCAL bAlterar := {|| cManut := "A", oDlg:End() }
LOCAL bIncluir := {|| IF(YV100Valid("OKITEM"),( cManut := "I", oDlg:End()),) }
LOCAL bExcluir := {|| cManut := "E", oDlg:End() } 
Local aButtons:={}
Private lInverte:= .F., cMarca:= GetMark(), aTELA[0][0], aGETS[0],aDelSYX:={}
Private oEnch //LRL 20/04/04
TRB->(avzap())
IF nOpc # 3
  Processa({||lTemItens:=YV100GrTRB()},"Processando...")	
  IF !lTemItens 
//  MSGINFO("Produto/Kit não possui Itens, exclua este Produto/Kit ou faça inclusão de itens.","Atenção")
    Help(" ",1,"EICSEMIT")
  ENDIF
ENDIF
dbSelectArea(cAlias)
        
FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := IF(nOpc#3,FieldGet(i),CriaVar(FIELDNAME(i)))
NEXT i

IF STR(nOpc,1,0) $ '2,5'//Visual,Exclui
   bOk := {|| IF(nOpc = 2 .OR. YV100Valid("EXCLUI") ,(nOpca:=1,oDlg:End()),) }
ENDIF   

aButtons:={}
IF STR(nOpc,1,0) $ "3,4"
   Aadd(aButtons,{"EDIT",bIncluir,"Inclusão"})                                          
   Aadd(aButtons,{"IC_17",bAlterar,"Alteração"})  			
   Aadd(aButtons,{"EXCLUIR",bExcluir,"Exclusão"})  			
ENDIF
                     

aCamposDet:=ArrayBrowse("SYX","TRB")

aCamposDet:= AddCpoUser(aCamposDet,"SYX","2")

TRB->(dbGoTop())

While .T.
   
   dbSelectArea("TRB")
   nOpca:=0
   cManut:=""
   aTELA:={}
   aGETS:={}
   
   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE cTitulo  ;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL                          
   
   nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )-10 
   oEnCh:=MsMGet():New( cAlias, nReg, nOpc, , , , , { 15,  1, nMeio-1 , (oDlg:nClientWidth-4)/2 },IF(nOpc=4,{"YV_REMARKS"},) , 3)//LRL 20/04/04 -Alinhamento MDI.
   
   oMSSelect:= MsSelect():New("TRB",,,aCamposDet,@lInverte,@cMarca,{nMeio,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})

   oMSSelect:oBrowse:bWhen:={||(dbSelectArea("TRB"),.t.)}
   IF(STR(nOpc,1,0)$"3,4",oMSSelect:baval:={||cManut := "A", oDlg:End()},)
   
   oEnch:oBox:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oMSSelect:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,{||nOpca:=0,oDlg:End()},,aButtons))//LRL 20/04/04 -Alinhamento MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   If !Empty(cManut)
     YV100ItemManut(cManut)
     Loop
   Endif

   IF nOpca == 1 
     Processa({||YV100Atualiza(nOpc)},"Atualizando Dados...")
   ENDIF
   
   Exit

End

dbSelectArea(cAlias)

Return( nOpc )

*---------------------------*
FUNCTION YV100GrTRB()
*---------------------------*
LOCAL lRet := .F.

IF SYV->(EOF()) .AND. SYV->(BOF())
  RETURN .T.
ENDIF  
SYX->(dbSeek(xFilial()+SYV->YV_MACHINE+SYV->YV_TYP_MOD+SYV->YV_COD_ZFM))

TRB->(avzap())

DO While SYX->(!EOF()) .AND.xFilial("SYX")  == SYX->YX_FILIAL  .AND. ;
         SYX->YX_MACHINE == SYV->YV_MACHINE .AND. ;
         SYX->YX_TYP_MOD == SYV->YV_TYP_MOD.AND.;
         SYX->YX_COD_ZFM == SYV->YV_COD_ZFM
                   

   IncProc("Lendo Item: "+ALLTRIM(SYX->YX_COD_I)) 


   TRB->(DBAPPEND())

   AvReplace("SYX","TRB")
        
   TRB->TB_RECNO := SYX->(RECNO())
   TRB->TRB_ALI_WT:= "SYX"
   TRB->TRB_REC_WT:= SYX->(Recno())
   lRet:=.T.

   SYX->(dbSkip())

EndDo

dbselectarea("TRB")

Return lRet

*------------------------------*
Function YV100Valid(nOrigem,Campo)
*-----------------------------*

DO CASE

   CASE nOrigem = "EXCLUI" // Validacao do OK  - Exclusao capa e item

        Return MSGNOYES("Confirma a Exclusão?","Exclusão")

   CASE nOrigem = "OKCAPA" // Validacao de manutencao de CAPA

     IF TRB->(BOF()).AND. TRB->(EOF()) .AND. SYV->(DBSEEK(xFilial("SYV")+M->YV_MACHINE+M->YV_TYP_MOD))
        Help(" ",1,"JAGRAVADO",,ALLTRIM(M->YV_MACHINE)+"/"+ALLTRIM(M->YV_TYP_MOD),3,9)
        RETURN .F.
      ENDIF
      SYV->(DBSETORDER(2))
      IF TRB->(BOF()).AND. TRB->(EOF()) .AND. !EMPTY(M->YV_COD_ZFM).AND. SYV->(DBSEEK(xFilial("SYV")+M->YV_COD_ZFM))
        Help(" ",1,"JAGRAVADO",,M->YV_COD_ZFM,3,9) 
        SYV->(DBSETORDER(1))
        RETURN .F.
      ENDIF
      SYV->(DBSETORDER(1))
     IF TRB->(BOF()).AND. TRB->(EOF()) // N PODE OK
       Help(" ",1,"SEMITEM") // NAO PODE GRAVAR KIT SEM ITEM
       Return .F.
     Endif

     IF EMPTY(M->YV_COD_ZFM) .AND. EMPTY(M->YV_TYP_MOD) // N PODE OK INCL
       Help(" ",1,"AVG0000113")
       RETURN .F.
     ENDIF                            
  
   CASE nOrigem = "OKITEM" // Validacao de manutencao de CAPA
    
     IF EMPTY(M->YV_COD_ZFM) .AND. EMPTY(M->YV_TYP_MOD) // N PODE OK INCL
       Help(" ",1,"AVG0000113")
       RETURN .F.
     ENDIF                            
      
     IF TRB->(EOF()) .AND. TRB->(BOF()) .AND. SYV->(DBSEEK(xFilial("SYV")+M->YV_MACHINE+M->YV_TYP_MOD)) // N PODE INCL / OK
       Help(" ",1,"JAGRAVADO",,ALLTRIM(M->YV_MACHINE)+"/"+ALLTRIM(M->YV_TYP_MOD),3,9)
       RETURN .F.
      ENDIF
      SYV->(DBSETORDER(2))
      IF TRB->(BOF()).AND. TRB->(EOF()) .AND. !EMPTY(M->YV_COD_ZFM).AND. SYV->(DBSEEK(xFilial("SYV")+M->YV_COD_ZFM))
       // N PODE INCL / OK
        Help(" ",1,"JAGRAVADO",,M->YV_COD_ZFM,3,9) 
        SYV->(DBSETORDER(1))
        RETURN .F.
      ENDIF
      SYV->(DBSETORDER(1))

    CASE nOrigem = "COD_I" .OR. nOrigem == "PRODUTO"   // Validacao de manutencao de Itens     
        cDesc:=IF(nOrigem == "PRODUTO","Produto/Kit ","Codigo do Item ")
        Campo:= IF(nOrigem == "PRODUTO",M->YV_MACHINE,M->YX_COD_I)
        IF ! EMPTY(Campo) .AND. !SB1->(DBSEEK(xFilial()+Campo))
           Help(" ",1,"AVG0000112",,AllTrim(cDesc),3,9) 
//          MsgInfo(cDesc+OemToAnsi,"NÆo encontrado no cadastro de Itens","Informação")
          RETURN .F.
        ENDIF                  
        IF nOrigem == "PRODUTO" .AND. !EMPTY(Campo) .AND. !(TRB->(BOF()).AND. TRB->(EOF())) // N PODE OK
          Help(" ",1,"SEMITEM") // NAO PODE GRAVAR SEM ITEM
          Return .F.
        Endif

        if nOrigem == "COD_I"
          IF TRB->(DBSEEK(M->YX_COD_I))
            Help(" ",1,"JAGRAVADO") // ITEM JA CADASTRADO PARA ESTE PRODUTO/KIT
            RETURN .F.
          ENDIF 
        ENDIF
   CASE nOrigem = "SERIE" // Validacao de manutencao de CAPA
        /*
     IF EMPTY(M->YV_TYP_MOD) .AND. !EMPTY(M->YV_MACHINE)
       Help(" ",1,"AVGXXXX") // MODELO/SERIE NAO PREENCHIDO
       RETURN .F.
     ENDIF*/
   CASE nOrigem = "COD_ZFM" // Validacao de manutenTencao de capa
     IF !EMPTY(M->YV_COD_ZFM) .AND. !SYZ->(DBSEEK(xFilial("SYZ")+M->YV_COD_ZFM))
       Help(" ",1,"AVG0000112",,M->YV_COD_ZFM,3,9) // CODIGO SUFRAMA NAO CADASTRADO
       RETURN .F.
     ENDIF
   Case nOrigem = "FATOR"
     IF M->YX_FATOR <= 0
       Help(" ",1,"AVG0000110") // Quantidade deve ser maior que Zero
       RETURN .F.
     ENDIF
   Case nOrigem = "TEC"
     IF !EMPTY(M->YX_TEC) .AND. !SYD->(DBSEEK(xFilial("SYD")+ M->YX_TEC))
        Help(" ",1,"AVG0000111") // ncm Nao cadastrada
       RETURN .F.
     ENDIF
      
ENDCASE   

RETURN .T.

*------------------------------*
Function YV100ItemManut(cOpcao)
*------------------------------*
LOCAL oDlg, cAlias:=Alias() , oEnch
LOCAL nOpca := 0, cTitle, i
LOCAL nRec_TRB, bOk
LOCAL aPos2 := {15,1,140,315}

dbSelectArea("TRB")
nRec_Trb := TRB->(Recno())

If (cOpcao == "E" .Or. cOpcao == "A") .And. Easyreccount("TRB") == 0
   Help("", 1, "AVG0003011")//"Não existem registros para a manutenção !","Atenção")
   Return .t.
ElseIf (cOpcao == "E" .Or. cOpcao == "A") .And. Eof()
   TRB->(dbGoBottom())
   If TRB->(Eof() .Or. Bof())
      Help("", 1, "AVG0003011")//"Não existem registros para a manutenção !","Atenção")
      Return .t.
   Endif
Elseif (cOpcao == "E" .Or. cOpcao == "A") .And. Bof()
   TRB->(dbGoTop())
   If TRB->(Eof() .Or. Bof())
      Help("", 1, "AVG0003011")//"Não existem registros para a manutenção !","Atenção")
      Return .t.
   Endif
Endif

FOR i := 1 TO TRB->(FCount())
    IF cOpcao == "I"                         
       IF !FIELDNAME(i) $ "DBDELETE,TB_RECNO,TRB_ALI_WT,TRB_REC_WT"
          M->&(TRB->(FIELDNAME(i))) := CriaVar( FIELDNAME(i) )
       ENDIF   
    ELSE   
       M->&(TRB->(FIELDNAME(i))) := TRB->( FIELDGET(i) )
    ENDIF
NEXT i


bOk := {||IF(Obrigatorio(aGets,aTela) , (nOpca:=1,oDlg:End()) , ) }

If cOpcao == "I"
   cTitle := "Produto/Kit - Inclusão de Itens"  
Elseif cOpcao == "A"
   cTitle := "Produto/Kit - Alteração de Itens"
Elseif cOpcao == "E"
   cTitle := "Produto/Kit - Exclusão de Itens"
   bOk := {||IF( .T. ,(nOpca:=1,oDlg:End()),) } 
Endif

aTELA:={}
aGETS:={}

WHILE .T.
   nOpca := 0
   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitle) ;
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-060,oMainWnd:nRight - 010 ;
     	     OF oMainWnd PIXEL                          

    aPos2[3]:=(oDlg:nClientHeight-2)/2
    aPos2[4]:=(oDlg:nClientWidth -2)/2
    oEnCh:=MsMGet():New( "SYX", nRec_TRB, IF(cOpcao=="I",3,4), , , ,, aPos2, IF(cOpcao == "E",{},if(cOpcao # "I",{"YX_FATOR","YX_INSUMO","YX_DES_ZFM","YX_TEC"},)) , 3 ) 
    
	oEnch:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,{||oDlg:End()}))//LRL 20/04/04 - Alinhamento MDI. //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   IF nOpca == 1
       
      IF cOpcao=="I"
         TRB->(DBAPPEND())
      ENDIF

      IF cOpcao # "E"
         AvReplace("M","TRB")
      ENDIF   

	  IF cOpcao=="I"
	    M->YX_COD_I := SPACE(LEN(SYX->YX_COD_I))
	    M->YX_TYP_MOD := SPACE(LEN(SYX->YX_TYP_MOD))
	    M->YX_FATOR := 1
	    M->YX_TEC   := SPACE(LEN(SYX->YX_TEC))
	    M->YX_DES_ZFM:= SPACE(LEN(SYX->YX_DES_ZFM))
	    M->YX_INSUMO := SPACE(LEN(SYX->YX_INSUMO))
        LOOP
      ELSEif cOpcao=="E"
        AADD(aDelSYX,TRB->TB_RECNO)
        TRB->(DBDELETE())
        TRB->(dbSkip(-1))
     ENDIF
    
	ENDIF

  IF nOpca == 0
     TRB->(dbGoTo(nRec_Trb))
  ENDIF

  EXIT

ENDDO

dbSelectArea(cAlias)

Return .T.
*---------------------------------*
FUNCTION YV100Atualiza(cTipoManut)
*---------------------------------*
LOCAL cMsg:=IF(cTipoManut = 5,"Excluindo ","Atualizando "),I
ProcRegua(TRB->(Easyreccount("TRB"))+LEN(aDelSYX))

DO CASE
   
   CASE cTipoManut = 2  //Visual
     Return .T.
   
   CASE cTipoManut = 3  //Inclui

     SYV->(RECLOCK("SYV",.T.))
     AvReplace("M","SYV")
     SYV->(MSUNLOCK())
   
   CASE cTipoManut = 4  //Altera
        
   	 SYV->(RECLOCK("SYV",.F.))
   	 SYV->YV_REMARKS := M->YV_REMARKS
     SYV->(MSUNLOCK())
		
  	 FOR I := 1 TO LEN(aDelSYX)
        SYX->(DBGOTO(aDelSYX[I]))
      	IncProc("Lendo Item: "+ALLTRIM(SYX->YX_COD_I)) 
        SYX->(RECLOCK("SYX",.F.))
        SYX->(DBDELETE())
        SYX->(MSUNLOCK())
   	 NEXT
   
   CASE cTipoManut = 5  //Exclui
		
     SYV->(RECLOCK("SYV",.F.))
     SYV->(DBDELETE())
     SYV->(MSUNLOCK())

ENDCASE

TRB->(DBGOTOP())

DO While TRB->(!EOF())
   
   IF !EMPTY(TRB->TB_RECNO)
      SYX->(DBGOTO(TRB->TB_RECNO))
      SYX->(RECLOCK("SYX",.F.))
   ELSEIF cTipoManut # 5  
      SYX->(RECLOCK("SYX",.T.))
   ENDIF

   IncProc(cMsg+"Item: "+ALLTRIM(TRB->YX_COD_I)) 

   IF cTipoManut # 5  
  	  AvReplace("TRB","SYX")          
  	  SYX->YX_FILIAL  := xFilial("SYX")
  	  SYX->YX_MACHINE := M->YV_MACHINE
  	  SYX->YX_TYP_MOD := M->YV_TYP_MOD 
  	  SYX->YX_COD_ZFM := M->YV_COD_ZFM
   ELSE
     SYX->(DBDELETE())
   ENDIF  
   SYX->(MSUNLOCK())
   TRB->(dbSkip())

EndDo

Return .T.

FUNCTION YV100Busca()

cCod := SPACE(LEN(TRB->YX_COD_I))
DO WHILE .T.
  
  nOpcA:=0
  
  DEFINE MSDIALOG oDlgIt TITLE STR0001 From 9,0 To 18,50 OF oMainWnd
  @ 1.8,0.8 SAY STR0010
  @ 1.8,6.0 MSGET cCOD F3 "SB1" PICTURE "@!" SIZE 60,10 

  ACTIVATE MSDIALOG oDlgIt ON INIT ;
  EnchoiceBar(oDlgIt,{||nOpca:=1,oDlgIt:End()},;
                 {||nOpca:=0,oDlgIt:End()}) CENTERED



  IF NOpca == 1
    IF !SB1->(DBSEEK(xFilial("SB1")+cCod))
      Help("", 1, "AVG0003012")//Nao encontrado no cadastro de Itens
      LOOP
    ENDIF 
    IF !TRB->(DBSEEK(cCOD))                            
      Help("", 1, "AVG0003013")//Item nao cadastrado neste Produto/Kit
      LOOP
    ENDIF        
  ENDIF
  EXIT
ENDDO  
oMSSelect:oBrowse:Refresh()
RETURN  .t.


******************************************************************************
*                        FIM DO PROGRAMA EICYV100.PRW                        *
****************************************************************************** 
