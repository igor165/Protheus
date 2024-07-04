/*
Programa : EECAT115.PRW
Objetivo : Agrupar todas funcoes de manutencao de mensagens
Autor    : Heder M Oliveira
Data/Hora: 09/11/98 11:29
Obs      : 
*/
#include "EEC.cH"
#INCLUDE "EECAT115.ch"
#INCLUDE "FWMVCDEF.CH"
*--------------------------------------------------------------------
Function EECAT115()
LOCAL aSEMSX3,aORD := SAVEORD({"EE4"})
//If !EasyCallMVC("MVC_EEC115AT",1) //CRF //- Nopado - FSM -29/02/2012


   Private cCadastro := AVTITCAD("EE4")
   Private aRotina := MenuDef()
   PRIVATE aCAMPOS,aHEADER
   // CRIA O TMP
   aSEMSX3   := {{"TMP_RECNO" ,"N",07,0}}
   aHEADER   := {}
   aCAMPOS   := ARRAY(EE4->(FCOUNT()))
   cWORKEE4  := E_CRIATRAB("EE4",aSEMSX3,"TMP")
   INDREGUA("TMP",cWORKEE4+TEOrdBagExt(),"EE4_IDIOMA","AllwayTrue()","AllwaysTrue()",STR0008) //"Processando Arquivo Temporario"
   DBSELECTAREA("EE4")
   MBROWSE(06,01,22,75,"EE4")
   IF SELECT("TMP") # 0
      TMP->(E_ERASEARQ(cWorkEE4))
   ENDIF
   RESTORD(aORD)
//EndIf
Return(NIL)                 

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 22/01/07 - 16:50
*/
Static Function MenuDef()
Local aRotAdic :=  {}             
Local aRotina  :=  {}

//If !EasyHasMVC()   
   aRotina :=  { { STR0001,"AxPesqui",0,PESQUISAR},;  //"Pesquisar"
                    { STR0002,"AT115MAN",0,VISUALIZAR},; //"Visualizar"
                    { STR0003,"AT115MAN",0,INCLUIR},;    //"Incluir"
                    { STR0004,"AT115MAN",0,ALTERAR},;    //"Alterar"
                    { STR0005,"AT115MAN",0,EXCLUIR}}     //"Excluir"
/*Else

   ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
   ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EECAT115" OPERATION 2 ACCESS 0
   ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EECAT115" OPERATION 3 ACCESS 0
   ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EECAT115" OPERATION 4 ACCESS 0
   ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EECAT115" OPERATION 5 ACCESS 0
EndIf*/
 
 
   // P.E. utilizado para adicionar itens no Menu da mBrowse
   If EasyEntryPoint("EAT115MNU")
	  aRotAdic := ExecBlock("EAT115MNU",.f.,.f.)
	  If ValType(aRotAdic) == "A"
         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	  EndIf
   EndIf

Return aRotina

*--------------------------------------------------------------------   
Function AT115MAN(cAlias,nReg,nOPC)
Local lRet:=.T.,nOLDREC:= EE4->(RECNO())
Local oDlg,nInc,bVal_OK, z:=0 
Local k := 0
LOCAL aENCHOICE,oMSELECT,aCAMPOTMP,aBUTTONS,bOK,bCANCEL,nBTOP,nMODO,aPOS
Private aTela[0,0],aGets[0],lINVERTE,cMARCA,aDELETADOS
*
aDELETADOS := {}
nBTOP      := 0
bOK        := {|| nBTOP := 1,IF(AT115V("BOK1"),oDLG:END(),nBTOP := 0)}
bCANCEL    := {|| nBTOP := 0,oDLG:END()}
aBUTTONS   := {}
aCAMPOTMP  := {{"EE4_IDIOMA"                      ,"",AVSX3("EE4_IDIOMA",AV_TITULO)},;
               {{||MEMOLINE(TMP->EE4_VM_TEX,75,1)},"",AVSX3("EE4_TEXTO" ,AV_TITULO)}}
cMARCA     := GETMARK()
lINVERTE   := .F.
aENCHOICE  := {"EE4_COD","EE4_TIPMEN"}
Begin sequence
   //criar variaveis
   DBSELECTAREA("TMP")
   AvZap()
   nMODO := ALTERAR
   IF nOpc == INCLUIR
      AADD(aBUTTONS,{"BMPINCLUIR" /*"EDIT"*/,{|| AT115VAE(nOPC,"I"),oMSELECT:oBROWSE:REFRESH()},STR0003}) //"Incluir"
      AADD(aBUTTONS,{"EDIT" /*"ALT_CAD"*/   ,{|| AT115VAE(nOPC,"A"),oMSELECT:oBROWSE:REFRESH()},STR0004}) //"Alterar"
      AADD(aBUTTONS,{"EXCLUIR",{|| AT115VAE(nOPC,"E"),oMSELECT:oBROWSE:REFRESH()},STR0005})  //"Excluir"
      nMODO := INCLUIR
      EE4->(DBGOBOTTOM())
      EE4->(DBSKIP())
   ELSEIF nOPC == ALTERAR
          AADD(aBUTTONS,{"BMPINCLUIR" /*"EDIT"*/ ,{|| AT115VAE(nOPC,"I"),oMSELECT:oBROWSE:REFRESH()},STR0003}) //"Incluir"
          AADD(aBUTTONS,{"EDIT" /*"ALT_CAD"*/    ,{|| AT115VAE(nOPC,"A"),oMSELECT:oBROWSE:REFRESH()},STR0004}) //"Alterar"
          AADD(aBUTTONS,{"EXCLUIR",{|| AT115VAE(nOPC,"E"),oMSELECT:oBROWSE:REFRESH()},STR0005})  //"Excluir"
   ElseIf nOpc == EXCLUIR
          If !InteGref("EE4")
             Break
          EndIf
   ENDIF
   FOR Z := 1 TO EE4->(FCOUNT())
       M->&(EE4->(FIELDNAME(Z))) := EE4->(FIELDGET(Z))
   NEXT
   IF nOPC # INCLUIR
      EE4->(DBSETORDER(1))
      EE4->(DBSEEK(XFILIAL("EE4")+M->EE4_COD+M->EE4_TIPMEN))
      EE4->(RECLOCK("EE4",.F.))
      DO WHILE ! EE4->(EOF()) .AND.;
         EE4->(EE4_FILIAL+EE4_COD+EE4_TIPMEN) = (XFILIAL("EE4")+M->EE4_COD+M->EE4_TIPMEN)
         *
         TMP->(DBAPPEND())
         AVREPLACE("EE4","TMP")
         TMP->TMP_RECNO  := EE4->(RECNO())
         TMP->EE4_VM_TEX := MSMM(EE4->EE4_TEXTO,AVSX3("EE4_VM_TEX",AV_TAMANHO))
         EE4->(DBSKIP())
      ENDDO
      TMP->(DBGOTOP())
   ENDIF
   DBSELECTAREA("TMP") 
   
   //OAP - 30/10/2010 - Inclusão de campos criados pelo usuário
   aENCHOICE := AddCpoUser(aENCHOICE,"EE4","1")
   
   IF(EasyEntryPoint("EECAT115"),Execblock("EECAT115",.F.,.F.,"GRAVA_MSG"),) //LGS-01/11/13 - Ponto de Entrada para customização no cadastro de mensagens.
   
   DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
      aPOS := POSDLGUP(oDLG)
      aPOS[3] := aPOS[3]-(aPOS[3]/2)
      ENCHOICE(cAlias,,nMODO,,,,aENCHOICE,aPOS)
      aPOS    := POSDLGDOWN(oDLG)
      aPOS[1] := aPOS[1]-(aPOS[1]/2)
      oMSELECT := MsSelect():New("TMP",,,aCampoTMP,@lInverte,@cMarca,aPOS)
      oMSELECT:BAVAL := {|| AT115VAE(nOPC,"V"),oMSELECT:oBROWSE:REFRESH()}
   ACTIVATE MSDIALOG oDlg ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS)
   IF nBTOP = 1 .AND. nOPC # VISUALIZAR
      BEGIN TRANSACTION
         TMP->(DBGOTOP())
         DO WHILE ! TMP->(EOF())
            IF nOPC == INCLUIR .OR. nOPC == ALTERAR
               IF EMPTY(TMP->TMP_RECNO)
                  EE4->(RECLOCK("EE4",.T.))
               ELSE
                  EE4->(DBGOTO(TMP->TMP_RECNO))
                  EE4->(RECLOCK("EE4",.F.))
                  MSMM(M->EE4_TEXTO,,,,EXCMEMO)  // EXCLUI MEMO ANTIGO
               ENDIF
               

		       AVREPLACE("M","EE4") //AOM - 01/02/2011
		       
               
               EE4->EE4_FILIAL := XFILIAL("EE4")
               //EE4->EE4_COD    := M->EE4_COD
               EE4->EE4_IDIOMA := TMP->EE4_IDIOMA
               //EE4->EE4_TIPMEN := M->EE4_TIPMEN
               MSMM(,AVSX3("EE4_VM_TEX",AV_TAMANHO),,TMP->EE4_VM_TEX,INCMEMO,,,"EE4","EE4_TEXTO")
            ELSEIF nOPC == EXCLUIR
                   EE4->(DBGOTO(TMP->TMP_RECNO))
                   EE4->(RECLOCK("EE4",.F.))
                   EE4->(DBDELETE())
            ENDIF
            //TRP-17/05/07
            IF EasyEntryPoint("EECAT115")
               ExecBlock("EECAT115",.F.,.F.,{"PE_GRV_MENS",nOpc})
            ENDIF
            TMP->(DBSKIP())
         ENDDO
         FOR Z := 1 TO LEN(aDELETADOS)
             EE4->(DBGOTO(aDELETADOS[Z]))
             EE4->(RECLOCK("EE4",.F.))
             MSMM(M->EE4_TEXTO,,,,EXCMEMO)  // EXCLUI MEMO ANTIGO
             EE4->(DBDELETE())
         NEXT
      END TRANSACTION
   ENDIF
End SEQUENCE
DBSELECTAREA("EE4")
EE4->(DBGOTO(nOLDREC))
RETURN(lRET)
*--------------------------------------------------------------------
Function AT115Valid(cP_ALIAS)
Local lRet:=.T.,nOLDAREA:=select(),nOLDORDEM:=INDEXORD(),nOLDREC:=RECNO()
LOCAL cSEEK:=XFILIAL("EE4")+M->EE4_COD+AVKEY(M->EE4_TIPMEN,"EE4_TIPMEN")+AVKEY(M->EE4_IDIOMA,"EE4_IDIOMA")
*
cP_ALIAS := IF(cP_ALIAS=NIL,"EE4",cP_ALIAS)
If (cP_ALIAS)->(DBSEEK(cSEEK))
   HELP(" ",1,"JAGRAVADO")
   lRet := .F.
ENDIF
RESTAREA()
Return(lRet)
*--------------------------------------------------------------------
STATIC FUNCTION AT115VAE(nP_OPC,cP_PAR2)
LOCAL oDLG,aENCHOICE,aALTERA,bOK,bCANCEL,nBTOP,aBUTTONS,Z,cTITULO,x
PRIVATE aTELA[0,0],aGETS[0],nMODO,cMODO
*
cP_PAR2       := IF(cP_PAR2=NIL,"V",cP_PAR2)
cMODO         := IF(cP_PAR2="I",STR0003,; //"Incluir"
                    IF(cP_PAR2="A",STR0004,; //"Alterar"
                       IF(cP_PAR2="E",STR0005,STR0002))) //"Excluir"###"Visualizar"
nMODO         := ALTERAR
aBUTTONS      := {}
aALTERA       := {}
nBTOP         := 0
bOK           := {|| nBTOP := 1,IF(AT115V("BOK2",cP_PAR2),oDLG:END(),nBTOP := 0)}
bCANCEL       := {|| nBTOP := 0,oDLG:END()}
aENCHOICE     := {"EE4_IDIOMA","EE4_VM_TEX"}
M->EE4_IDIOMA := SPACE(LEN(TMP->EE4_IDIOMA))
M->EE4_VM_TEX := ""
BEGIN SEQUENCE
   IF AT(cP_PAR2,"AEV") # 0
      IF TMP->(EOF()) .OR. TMP->(BOF())
         MSGINFO(STR0009+cMODO+STR0010,STR0007) //"Não a dados para "###" !"###"Atenção"
         BREAK
      ENDIF
   ENDIF
   cTITULO := cMODO+" - "+ALLTRIM(M->EE4_COD)+"-"+ALLTRIM(M->EE4_TIPMEN)
   IF cP_PAR2 = "I"  // INCLUIR NO IDIOMA
      aALTERA       := {"EE4_IDIOMA","EE4_VM_TEX"}
      nMODO         := INCLUIR
      M->EE4_IDIOMA := SPACE(LEN(TMP->EE4_IDIOMA))
      M->EE4_VM_TEX := ""
      //OAP - Alteração para que as informações da work sejam passadas para os campos de usuário na Enchoice
      For x := 1 To (Len(aENCHOICE) - Len(aALTERA))
         M->&(aENCHOICE[Len(aAltera) + x]) := TMP->&(aENCHOICE[Len(aAltera) + x])
      Next x
   ELSEIF cP_PAR2 = "A"  // ALTERAR NO IDIOMA
          aALTERA := {"EE4_VM_TEX"}
          nMODO   := ALTERAR
          M->EE4_IDIOMA := TMP->EE4_IDIOMA
          M->EE4_VM_TEX := TMP->EE4_VM_TEX
          //OAP - Alteração para que as informações da work sejam passadas para os campos de usuário na Enchoice
          For x := 1 To (Len(aENCHOICE) - Len(aALTERA))
             M->&(aENCHOICE[Len(aAltera) + x]) := TMP->&(aENCHOICE[Len(aAltera) + x])
          Next x
   ELSEIF cP_PAR2 = "E"  // EXCLUIR NO IDIOMA
          nMODO   := ALTERAR
          M->EE4_IDIOMA := TMP->EE4_IDIOMA
          M->EE4_VM_TEX := TMP->EE4_VM_TEX
   ELSEIF cP_PAR2 = "V"  // VISUALIZAR NO IDIOMA
          nMODO   := ALTERAR
          M->EE4_IDIOMA := TMP->EE4_IDIOMA
          M->EE4_VM_TEX := TMP->EE4_VM_TEX
   ENDIF
   DBSELECTAREA("TMP")
   DEFINE MSDIALOG oDlg TITLE cTITULO FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
      ENCHOICE("EE4",RECNO(),nMODO,,,,aENCHOICE,POSDLG(oDLG),aALTERA,3)
   ACTIVATE MSDIALOG oDlg ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS)
   IF nBTOP = 1
      IF cP_PAR2 = "I"  // INCLUSAO
         TMP->(DBAPPEND())
         TMP->EE4_IDIOMA  := M->EE4_IDIOMA
         TMP->EE4_VM_TEX  := M->EE4_VM_TEX
      ELSEIF cP_PAR2 = "A"
             TMP->EE4_VM_TEX  := M->EE4_VM_TEX
      ELSEIF cP_PAR2 = "E"
             IF ! EMPTY(TMP->TMP_RECNO)
                AADD(aDELETADOS,TMP->TMP_RECNO)
             ENDIF
             TMP->EE4_VM_TEX := ""
             TMP->(DBDELETE())
      ENDIF
   ENDIF
END SEQUENCE
RETURN(NIL)
*--------------------------------------------------------------------
FUNCTION AT115V(cP_CAMPO,cP_PAR2)
LOCAL lRET
*
lRET := .T.
IF cP_CAMPO == "BOK1"
   IF ! OBRIGATORIO(aGETS,aTELA)
      lRET := .F.
   ELSEIF TMP->(EOF()) .OR. TMP->(BOF())
          MSGINFO(STR0011,STR0007) //"Inclua pelo menos uma a mensagem no idioma !"###"Atenção"
          lRET := .F.
   ENDIF
ELSEIF cP_CAMPO == "BOK2"
       IF ! OBRIGATORIO(aGETS,aTELA)
          lRET := .F.
       ELSEIF cP_PAR2 = "I"
              TMP->(DBSETORDER(1))
              IF (TMP->(DBSEEK(M->EE4_IDIOMA)))
                 MSGINFO(STR0012+ALLTRIM(M->EE4_IDIOMA)+STR0010,STR0007) //"Mensagem já incluida no idioma "###" !"###"Atenção"
                 lRET := .F.
              ENDIF
       ENDIF
ELSEIF cP_CAMPO == "EE4_TIPMEN"
       IF ! AT115EE4(2)
          lRET := .F.
       ELSE
          EE4->(DBSETORDER(1))
          IF (EE4->(DBSEEK(XFILIAL("EE4")+M->EE4_COD+AVKEY(M->EE4_TIPMEN,"EE4_TIPMEN"))))
             HELP(" ",1,"JAGRAVADO")
             lRET := .F.
          ENDIF
       ENDIF
ENDIF
RETURN(lRET)
*--------------------------------------------------------------------
