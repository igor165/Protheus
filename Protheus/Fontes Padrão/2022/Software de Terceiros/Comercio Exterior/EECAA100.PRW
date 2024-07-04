#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EECAA100.ch"
/*
    Programa : EECAA100.PRW
    Autor    : Heder M Oliveira    
    Data     : 19/07/99 16:34
    Revisao  : 19/07/99 16:34
    Uso      : Relacao/Impressao via Crystal
*/
#include "EEC.CH"

/*
Funcao      : EECAA100()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : executar axcadastro
Autor       : Heder M Oliveira
Data/Hora   :
Revisão     : Clayton Fernandes - 29/03/2011
Obs         : Adaptação do Codigo para o padrão MVC
*/
Function EECAA100()   
Local lRet:=.T.,cOldArea:=Select()
Private aMemos:={{"EEA_CODMEM","EEA_OBS"}}
Private oUpdAtu

If !EasyCallMVC("MVC_EECAA100",1)
 
   Begin Sequence
      AxCadastro("EEA",AnsitoOem(STR0038),,"AA100ValAtv()") // By JBJ 13/08/02 - 9:09 //"Atividades/Documentos"
   End Sequence
   dbselectarea(cOldArea)

EndIf
Return lRet
/*
    Funcao   : EEA_When(cCPO)
    Autor    : MPG
    Data     : 01/06/2021
*/
Function EEA_When(cCpo)
   Local oModel      := FWModelActive()
   Local lRet        := .F.

   DO CASE
      CASE cCpo == "EEA_TIPMOD"
         if oModel:GetOperation() == 3
            lRet := .T.
         endif
   endCase

return lRet
/*
    Funcao   : EEA_VALID(cCPO)
    Autor    : CAF    
    Data     : 
    Revisao  : 
    Uso      : 
    Recebe   :
    Retorna  :

*/
Function EEA_Valid(cCpo)
Local aArquivos := {}
Local lRet := .T.
Local cProcura 
Local nCont
Local nAchou 
Local oModel := FWModelActive()
Local oModelEEA := oModel:GetModel("EECP018_EEA")
   
Begin Sequence
   DO CASE
      CASE cCpo == "EEA_ARQUIV"                                           //MFR 19/02/2021 ossme-5455
         If EEA->(FieldPos("EEA_TIPCUS")) > 0 .And. oModelEEA:GetValue("EEA_TIPCUS") == "2" //Crystal
            IF ! FILE(DirRpt01()+"\"+ALLTRIM(M->EEA_ARQUIV))
               EasyHelp(STR0002+DirRpt01()+"\"+ALLTRIM(M->EEA_ARQUIV)+STR0003,STR0004) //"Arquivo: "###" não existe !"###"Atenção"
               lRet := .F. 
            Endif
         ElseIf EEA->(FieldPos("EEA_TIPMOD")) > 0 .And. oModelEEA:GetValue("EEA_TIPMOD") == "1" //HTML APH
            If AT(".APH",UPPER(ALLTRIM(M->EEA_ARQUIV))) > 0
               EasyHelp(STR0059,STR0004) //"Não é necessário digitar a extensão do arquivo quando o Campo Tipo de Modelo é 'HTML - APH'"##"Atenção"
               lRet := .F.
            EndIf   
         EndIf   
        
         //DFS - 14/11/2008
         // Criado campo para permitir inclusão de arquivos adicionais para impressão de relatório.
         If EEA->(FieldPos("EEA_ARQADI")) > 0
            If AllTrim(M->EEA_ARQUIV) == AllTrim(M->EEA_ARQADI) // Verifica se o arquivo principal é igual ao adicional
               MsgInfo(STR0054, STR0052) //"Arquivo já informado no item adicional", "Aviso".
               lRet := .F.
               Break 
            Endif
         EndIf
      CASE cCpo == "EEA_ARQADI"
         If Empty(M->EEA_ARQUIV) //Verifica se o Arquivo principal foi digitado, para deixar anexar outros arquivos
            MsgInfo(STR0051, STR0052) //"Arquivo principal ainda não informado", "Aviso".
            lRet := .F.
            Break
         EndIf
     
      If M->EEA_ARQADI # NIL
         aArquivos := AA100Split(M->EEA_ARQADI)
      Endif
      
   For nCont := 1 to (Len (aArquivos) -1)
      cProcura := aArquivos [nCont]                
      nAchou := aScan(aArquivos, cProcura, nCont+1, (Len (aArquivos))) // Verifica se não foi repetido nenhum arquivo
     If nAchou # 0                                                     // no campo Arqs Adicional
        MsgInfo ("O Arquivo "+ cProcura+", na posição " + AllTrim(Str(nAchou));
         +" já existe na posição " + AllTrim(Str(nCont))+ ".")
        lRet := .F.
        Break
     End If
   Next
     
   For nCont := 1 to Len(aArquivos)  
         If AllTrim(M->EEA_ARQUIV) == aArquivos [nCont] //Verifica se os arquivos digitados no campo Arquivo e Arqs Ad são iguais
            MsgInfo(STR0053, STR0052) //"Arquivo já existente na aba Principal. Favor inserir um arquivo novo.", "Aviso".
            lRet := .F.
            Break 
         Endif
         IF !FILE(DirRpt01()+"\"+(aArquivos [nCont]))
         	MsgStop(STR0002+DirRpt01()+"\"+(aArquivos[nCont])+STR0003,STR0004) //"Arquivo: "###" não existe !"###"Atenção"
            lRet := .F.   
            Break
         Endif      
            
   Next        
    
      ENDCASE
End Sequence
Return lRet

/*
    Funcao   : EECAA101(cIDIOMA,cTIPDOC,cFASE,cPAIS,lMENU)
    Autor    : Heder M Oliveira    
    Data     : 19/07/99 16:40
    Revisao  : 19/07/99 16:40
    Uso      : Permitir escolha de documentos p/impressao
    Recebe   : Idioma
    Retorna  : NIL
*/
Function EECAA101(cIDIOMA,cTIPDOC,cFASE,cPAIS,lMENU,cProces)
   Local lRET:=.T.,nOldArea:=Select()
   Local oDLGID,nOpcao:=0,oIDIOMA,oTIPDOC,oFASE
   Local aBOXIDIOMA:=COMBOSX5("ID"),aBOXDOCUM:=COMBOSX5("YD",.F.),aBOXFASE:=COMBOX3BOX("EEA_FASE")
   Local nLINHA:=1.5,nLINDLG:=22//AOM - 16/07/2011 - Alterado o tamanho versao M11.5
   Local oCbxTipDoc, oCbxFase, oCbxId, oGetPais
   Local lTipDoc := Empty(cTipDoc)
   
   Local bOk := {|| nOpcao := 1,oDLGID:END()} 
   Local bCancel := {|| oDlgID:End() }
   Local cPict := ""
   Local cCodId   := UPPER(AvKey(EasyGParam("MV_AVG0035",,"PORT."),"X5_CHAVE"))
   Local oPrc
   
   DEFAULT cTIPDOC:=aBOXDOCUM[2]  //ISS - 23/10/10 - Alterado o tipo de documento padrão, de "carta" para "documento"
   DEFAULT cPAIS  :=STR0005 //"Não Definido"
   DEFAULT lMENU  := .F. //nao foi chamado diretamente do MENU
   
   DEFAULT cPROCES:=SPACE(AVSX3("EEC_PREEMB",AV_TAMANHO))
   
   Private cPROCESSO := cPROCES //EECAAF3 acessa o dado membro cPROCESSO
   Private cProcOld := cProcesso, lDocs:=.T.
   Private cSXBID := AvKey(cCodId+"-"+Tabela("ID",cCodId),"EE4_IDIOMA") //SVG - 22/03/2011 - 
   Private cIdiRel  // GFP - 29/05/2012 - Idioma do Relatório
   
   If Select("Header_p") = 0
      AbreEEC()
   EndIf
    
   DEFAULT cIDIOMA:= CSXBID //aBOXIDIOMA[1]

   IF cFASE == NIL
      cFASE := aBOXFASE[1]
   ELSEIF cFASE = OC_EM
      aBOXFASE := {aBOXFASE[3]}
      cFase := aBoxFase[1]
   ELSEIF cFASE = OC_PE
      aBOXFASE := {aBOXFASE[2]}
      cFase := aBoxFase[1]
   ENDIF
   
   IF ( lMENU )
      nLINDLG:=25//AOM - 16/07/2011 - Alterado o tamanho versao M11.5
   ENDIF

   Private oUpdAtu
   // BAK - Tratamento para carga padrão da tabela EEA - 19/08/2011
   /* MFR 14/01/2021 OSSME-5547 Retirado a carga deste fonte, ficou só no avupdate02 com controle de desativação de documentos
   If FindFunction("AvUpdate01")
      oUpdAtu := AvUpdate01():New()
   EndIf

   If ValType(oUpdAtu) == "O" .AND. &("MethIsMemberOf(oUpdAtu,'TABLEDATA')") .AND. Type("oUpdAtu:lSimula") == "L"
      If ChkFile("EEA")
         oUpdAtu:aChamados := {{nModulo,{|o| EDadosEEA(o)}}}
         oUpdAtu:Init(,.T.)
      EndIf
   EndIf
   */

   BEGIN SEQUENCE
      cPAIS += " "+POSICIONE("SYA",1,XFILIAL("SYA")+cPAIS,"YA_DESCR")
   
      nOpcao:=0
      
      DEFINE MSDIALOG oDlgID FROM 9,10 TO nLINDLG,60  TITLE STR0006 OF oMAINWND //"Seleção Para Impressão"
                      
         oPrc := TPanel():New(01,01,"",oDlgID,,,,,,oDlgID:nWidth,oDlgID:nHeight/2)
         oPrc:Align := CONTROL_ALIGN_ALLCLIENT
         		 
		 nLINHA:=0.5
         IF lMENU
            @ nLINHA,1 SAY STR0007 OF oPrc//"Processo"
            
            IF AvSx3("EE7_PEDIDO",AV_PICTURE) == AvSx3("EEC_PREEMB",AV_PICTURE)
               cPict := AvSx3("EEC_PREEMB",AV_PICTURE)
            Endif
            
            IF !Empty(cPict)
               @ nLINHA,7.2 MSGET cPROCESSO VALID AA101Val(oCbxFase,oCbxId,oGetPais,cFase,lMenu) F3 "EYC" SIZE 90,10 OF oPrc PICTURE cPict
            Else
               @ nLINHA,7.2 MSGET cPROCESSO VALID AA101Val(oCbxFase,oCbxId,oGetPais,cFase,lMenu) F3 "EYC" SIZE 90,10 OF oPrc
            Endif

            nLINHA+=1.2
         ENDIF
            
         @ nLINHA,1 SAY STR0008 OF oPrc //"Idioma"
         @ nLINHA,7.2 COMBOBOX oCbxId VAR cIDIOMA ITEMS aBOXIDIOMA SIZE 90,40 OF oPrc
         nLINHA+=1.2
            
         @ nLINHA,1 SAY STR0009  OF oPrc //"Tipo de Documento"
         @ nLINHA,7.2 COMBOBOX oCbxTipDoc VAR cTIPDOC ITEMS aBOXDOCUM SIZE 90,40 OF oPrc
         nLINHA+=1.2
            
         IF ! lTipDoc
            oCbxTipDoc:Disable()
         Endif
            
         @ nLINHA,1 SAY STR0010  OF oPrc //"Fase"
         @ nLINHA,7.2 COMBOBOX oCbxFase VAR cFASE ITEMS aBOXFASE SIZE 90,40 OF oPrc
         nLINHA+=1.2
         
         IF !Empty(cFase) .And. !lMenu
            oCbxFase:Disable()
         Endif
         
         @ nLINHA,1 SAY STR0011  OF oPrc //"País"
         @ nLINHA,7.2 MSGET oGetPais VAR cPAIS WHEN .F. SIZE 90,10 OF oPrc

      ACTIVATE MSDIALOG oDlgID CENTERED ON INIT EnchoiceBar(oDlgID,bOk,bCancel)
      
      cIdiRel := cIdioma  // GFP - 29/05/2012 - Idioma do Relatório
         
      // ** by JBJ - 23/11/2001 - 11:04
      IF nOpcao = 1
         CURSORWAIT()

         Private cChosenFase := cFase //JPM - 25/08/05 - para que a AvTelaGets possa utilizar a variável.

         Do while lDocs  
            AA101DOCS(cIDIOMA,cTIPDOC,cFASE,LEFT(cPAIS,AVSX3("YA_CODGI",AV_TAMANHO)),cPROCESSO)               
         EndDo         
         
         
         // ** by JBJ - 26/11/2001 - 17:36         
         /*
         If lMenu .Or. cTipDoc = aBOXDOCUM[3] 
            Do while lDocs  
               AA101DOCS(cIDIOMA,cTIPDOC,cFASE,LEFT(cPAIS,AVSX3("YA_CODGI",AV_TAMANHO)),cPROCESSO)               
            EndDo
         Else                          
            AA101DOCS(cIDIOMA,cTIPDOC,cFASE,LEFT(cPAIS,AVSX3("YA_CODGI",AV_TAMANHO)),cPROCESSO)
         EndIf
         */
         
         CursorArrow()
      ELSE
         BREAK
      ENDIF      
      
   END SEQUENCE
   
   CursorArrow()
   DBSELECTAREA(nOLDAREA)
   
RETURN lRET

/*
    Funcao   : AA101Val
    Autor    : Cristiano A. Ferreira
    Data     : 15/09/1999 16:39
    Uso      : Consistencias da funcao EECAA101
    Recebe   : oCbx
    Retorna  : .T./.F.
*/
Static Function AA101Val(oCbx,oCbx1,oGet,cFase,lMenu)

Local lRet := .T.
Local lAll := .F.
Local nItem := 0
Local cPais := ""

Default cFase := " "
Default lMenu := .f.

Begin Sequence
   
   IF lMenu
      IF EE7->(dbSeek(xFilial()+cProcesso)) .And. EE7->EE7_STATUS != ST_PC
         cFase := OC_PE
         IF EEC->(dbSeek(xFilial()+cProcesso)) .And. EEC->EEC_STATUS != ST_PC
            lAll := .T.
         Endif
      Else
         IF EEC->(dbSeek(xFilial()+cProcesso)) .And. EEC->EEC_STATUS != ST_PC
            cFase := OC_EM
         Else
            // Nao encontrou o processo EE7/EEC/EEL           
            Help(" ",1,"AVG0000621") // MsgStop("Processo não encontrado ou cancelado !","Aviso")
            lRet := .f.
            Break
         Endif
      Endif
   Else
      IF cFase == OC_PE
         IF ! (EE7->(dbSeek(xFilial()+cProcesso)) .And. EE7->EE7_STATUS != ST_PC)
            Help(" ",1,"AVG0000621") // MsgStop("Processo não encontrado ou cancelado !","Aviso")
            lRet := .f.
            Break
         Endif
      Elseif cFase == OC_EM
         IF ! (EEC->(dbSeek(xFilial()+cProcesso)) .And. EEC->EEC_STATUS != ST_PC)
            Help(" ",1,"AVG0000621") // MsgStop("Processo não encontrado ou cancelado !","Aviso")
            lRet := .f.
            Break
         Endif   
      Endif
   Endif
   
   IF cProcOld == cProcesso
      Break
   Endif
   
   cProcOld := cProcesso
   
   IF lMenu
      // *** ComboBox com as Fases ...
      IF lAll
         Eval(oCbx:bSetGet,Left(oCbx:aItems[1],1))
         oCbx:Refresh()
         oCbx:Enable()
      Else
         Eval(oCbx:bSetGet,Left(oCbx:aItems[IF(cFase==OC_PE,1,2)+1],1))
         oCbx:Refresh()
         oCbx:Disable()
      Endif
   Endif
   
   do Case
      Case cFase == OC_PE
         nItem := aScan(oCbx1:aItems,{|x| EE7->EE7_IDIOMA == AVKEY(x,"EE7_IDIOMA")})
         cPais := POSICIONE("SA1",1,XFILIAL("SA1")+EE7->EE7_IMPORT+EE7->EE7_IMLOJA,"A1_PAIS")
         oGet:cText(cPais+" "+BuscaPais(cPais))
         oGet:Refresh()
      Case cFase == OC_EM
         nItem := aScan(oCbx1:aItems,{|x| EEC->EEC_IDIOMA == AVKEY(x,"EEC_IDIOMA")})
         cPais := EEC->EEC_PAISET
         oGet:cText(cPais+" "+BuscaPais(cPais))
         oGet:Refresh()
   End Case

   IF nItem != 0 // ComboBox de Idiomas ...
      Eval(oCbx1:bSetGet,oCbx1:aItems[nItem])
      oCbx1:Refresh()
   Endif

End Sequence

Return lRet

/*
    Funcao   : AA101DOCS(cIDIOMA,cTIPDOC,cFASE,cPAIS)
    Autor    : Heder M Oliveira
    Data     : 20/07/99 12:30
    Revisao  : 20/07/99 12:30
    Uso      : Gerar work com documentos
    Recebe   :
    Retorna  :
*/

FUNCTION AA101DOCS(cIDIOMA,cTIPDOC,cFASE,cPAIS,cPROCES)
   LOCAL lRET:=.T.,bCONDFASE:=IF(LEFT(cFASE,1) =="1",{||.T.},{||LEFT(EEA->EEA_FASE,1) $ cSim .Or. LEFT(cFASE,1) == LEFT(EEA->EEA_FASE,1) })
   LOCAL Tb_Campos := {},lInverte := .F.,cMarca := GetMark(),cARQWORK,oDLGIM,nOLDAREA:=SELECT()
   LOCAL aSemSx3 := { { "WKFLAG" ,"C",2,0 },;
                      {"WKPAISEX","C",3,0},{"WKIDPROC","C",AVSX3("EEA_IDIOMA",AV_TAMANHO),0},;
                      {"WKIDPAIS","C",AVSX3("EEA_IDIOMA",AV_TAMANHO),0}}
   LOCAL oMARK,nINC
   LOCAL nOpcao := 0,lIMPRESSO:=.F.,bCONDDOC,aExecutar:={STR0012,STR0013,STR0014,STR0015} //"&Reimprimir"###"&Substituir"###"&Criar Novo"###"&Cancelar"
   LOCAL cINDEX2
   Local aOrdImp
   
   Local bBotao1:={||cExecutar:=aExecutar[1], nOpcao:=1, oDLGID:END()}  //reimprimir
   Local bBotao2:={||cExecutar:=aExecutar[2], nOpcao:=2, oDLGID:END()}  //substituir
   Local bBotao3:={||cExecutar:=aExecutar[3], nOpcao:=3, oDLGID:END()}  //criar novo
   Local bBotao4:={||nOpcao:=4, oDLGID:END()}                           //cancelar
   
   Local cTit:="", cFased
   Local cExecutar:=aExecutar[4]
   
   Local lVezes := .T.
 
   PRIVATE aCAMPOS:=ARRAY(EEA->(FCOUNT())),aHEADER[0]
   PRIVATE cSEQREL

   Private nIncCod := .T. // Inclusão do Código da Norma 
   Private lImpNor := .F. // Imprime norma 

   Private oUpdAtu

   // GFP - 24/09/2012 - Ajuste no registro 89 - Packing List (Modelo 3)
   If EEA->(DbSeek(xFilial("EEA")+AvKey("89","EEA_COD"))) .AND. EEA->EEA_RDMAKE <> 'EXECBLOCK("EECPEM55",.F.,.F.)'
      If EEA->(RecLock("EEA",.F.))
         EEA->EEA_RDMAKE := ""
         EEA->EEA_RDMAKE := 'EXECBLOCK("EECPEM55",.F.,.F.)'
         EEA->(MsUnlock())
      EndIf
   EndIf
   
   // GFP - 03/10/2012
   If EEA->(DbSeek(xFilial("EEA")+AvKey("28","EEA_COD")))
      Do While EEA->(!Eof()) .AND. EEA->EEA_COD == AvKey("28","EEA_COD")
         If EEA->EEA_IDIOMA <> AvKey("INGLES-INGLES","EEA_IDIOMA") .AND. EEA->(RecLock("EEA",.F.))
            EEA->(DBDELETE())
            EEA->(MsUnlock())
         EndIf
         EEA->(DbSkip())
      EndDo
   EndIf
   
   BEGIN SEQUENCE 
      
      If Select("WorkID") <> 0    // GFP - 10/10/2012
         WorkID->(DbCloseArea())
      EndIf

      cArqWork:=E_CriaTrab("EEA",aSemSX3,"WorkID")
      IndRegua("WorkID",cARQWORK+TEOrdBagExt(),"EEA_COD")
      
      cINDEX2 := CriaTrab(,.f.)
      IndRegua("WorkId",cINDEX2+TEOrdBagExt(),"EEA_TITULO")
      
      Set Index To (cARQWORK+TEOrdBagExt()),(cINDEX2+TEOrdBagExt())
      
	  dbSelectArea("EEA")
      Tb_Campos := {}
      
      // ** by JBJ - 23/11/2001 9:18
      //AADD(Tb_Campos,{"WKFLAG"  ,""," "})       
      
      AADD(Tb_Campos,{"EEA_COD" ,"",STR0016}) //"Cód. Documento"
      AADD(Tb_Campos,{"EEA_TITULO","",STR0017}) //"Documento"
      AADD(Tb_Campos,{{||BSCXBOX("EEA_FASE",WORKID->EEA_FASE)},"",STR0010}) //"Fase"
      AADD(TB_CAMPOS,{"WKPAISEX","",STR0018}) //"País Entrega Exige?"
      AADD(TB_CAMPOS,{"WKIDPROC","",STR0019}) //"Idioma Selecionado"
      AADD(TB_CAMPOS,{"WKIDPAIS","",STR0020}) //"Idioma País Entrega"
      AADD(TB_CAMPOS,{"EEA_IDIOMA","",STR0021}) //"Idioma Documento"
      AADD(TB_CAMPOS,{{|| IF(WorkId->EEA_CNTLIM $ cSim,STR0022,STR0023)},"",STR0024}) //"Sim"###"Nao"###"Controle Impressão"

      If WorkId->(FieldPos("EEA_IMPINV")) # 0 .And. EECFlags("INVOICE") // By OMJ - 14/06/2005 - Opcao de Impressao por Invoice
         AADD(TB_CAMPOS,{{|| IF(WorkId->EEA_IMPINV $ cSim,STR0022,STR0023)},"",STR0042})  //"Sim"###"Nao"###"Impr. por Invoice"
      EndIf
            
      cIDIOMA:= AVKey(cIDIOMA,"EEA_IDIOMA")
      cTIPDOC:= AVKey(cTIPDOC,"EEA_TIPDOC")
	  
      //TRP-13/12/07- Acerto na condição para busca de documentos/cartas/relatórios/atividades em determinado idioma.
      bCONDDOC:=IF(LEFT(cTIPDOC,1)=="1",; // 1=Fax; 2=Documento; 3=Relatorio; 4=Atividade
                  {||cTIPDOC == EEA->EEA_TIPDOC .AND.; // Listará apenas os registros do tipo FAX
                                cIdioma == EEA->EEA_IDIOMA},; // Listará apenas os registros no idioma selecionado
                  {||Left(cTIPDOC,1) == Left(EEA->EEA_TIPDOC,1) .AND.; // Listará apenas os registros de mesmo tipo(1,2,3 e 4)
                                cIdioma == EEA->EEA_IDIOMA}) // Listará apenas os registros no idioma selecionado

      EEA->(DBSETORDER(1))
      IF !EEA->(DBSEEK(xFilial("EEA")))
         HELP(" ",1,"AVG0000061")
      ENDIF

         //carregar work com documentos
         EE1->(DBSEEK(XFILIAL("EE1")+TR_ARQ+cPAIS))
         Do WHILE !EEA->(EOF()) .AND. EEA->EEA_FILIAL == xFilial("EEA")
            // ** By JBJ - 21/08/03 - 11:51 - (Verifica se o documento está ativo...)
            If EEA->EEA_ATIVO $ cNao
               EEA->(DbSkip())
               Loop
            EndIf

            IF ( EVAL(bCONDFASE) .AND. EVAL(bCONDDOC) )
              WorkID->(DBAPPEND())                    
               AvReplace("EEA","WorkId")
               WORKID->WKFLAG     := ""
               WORKID->WKPAISEX   := STR0025 //"Não"
               WORKID->WKIDPROC   := cIDIOMA
               WORKID->WKIDPAIS   := POSICIONE("SYA",1,XFILIAL("SYA")+cPAIS,"YA_IDIOMA")
            ENDIF
            EEA->(DBSKIP())
         ENDDO 

         //carregar work com documentos exigidos pelo pais    
         WHILE (XFILIAL("EE1")==EE1->EE1_FILIAL .AND. TR_ARQ == EE1->EE1_TIPREL .AND. cPAIS == EE1->EE1_PAIS )        
            IF ( !WORKID->(DBSEEK(EE1->EE1_DOCUM)) )
               EEA->(DBSETORDER(1))  //DOCUMENTO + TIPO + IDIOMA
               IF EEA->(DBSEEK(xFilial("EEA" )+EE1->EE1_DOCUM+cTIPDOC+AVKey(POSICIONE("SYA",1,XFILIAL("SYA")+cPAIS,"YA_IDIOMA"),;
                  "EEA_IDIOMA")))

                  If EEA->EEA_ATIVO $ cNao
                     EE1->(DbSkip())
                     Loop
                  EndIf
                  
                  IF ( EVAL(bCONDFASE) )
                     WorkID->(DBAPPEND())
                     AvReplace("EEA","WorkId")
                     WORKID->WKPAISEX   := STR0022 //"Sim"
                     WORKID->WKIDPROC   := cIDIOMA
                     WORKID->WKIDPAIS   := POSICIONE("SYA",1,XFILIAL("SYA")+cPAIS,"YA_IDIOMA")
                  ENDIF
               ENDIF
            ELSE
               WORKID->EEA_IDIOMA := cIDIOMA
               WORKID->WKPAISEX   := STR0022 //"Sim"
               WORKID->WKIDPAIS   := POSICIONE("SYA",1,XFILIAL("SYA")+cPAIS,"YA_IDIOMA")
            ENDIF
            EE1->(DBSKIP(1))
         EndDo
      
      WORKID->(DBSETORDER(2))
      WORKID->(DBGOTOP())
      
      IF WORKID->(BOF())
         HELP(" ",1,"AVG0000061")
         lRET:=.F.
         lDOCS := .F.
         BREAK
      ENDIF
      
      lDocs:=.F.           
      // DEFINE MSDIALOG oDlgIM FROM 9,10 TO 20,80  TITLE "Documentos" OF oMAINWND
      DEFINE MSDIALOG oDlgIM TITLE STR0026 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Documentos"
          
         //CRF - 01/10/10 - 16:05
         TB_Campos := AddCpoUser(TB_Campos,"EEA","2")

         oMark := MsSelect():New("WORKID",,,TB_Campos,,,PosDlg(oDlgIM))
                  
         // ** by JBJ 23/11/2001 9:40
         //oMark := MsSelect():New("WORKID","WKFLAG",,TB_Campos,@lInverte,@cMarca,PosDlg(oDlgIM))
 	     
 	     oMARK:bAVAL:={||WORKID->WKFLAG:=cMARCA,EVAL(bOK)}
         oMark:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT //wfs
         bOk := {|| nOpcao := 1, WORKID->WKFLAG:=cMARCA, oDLGIM:END(),lDocs:=.T.}
         bCancel := {|| oDlgIM:End(), lDocs:=.f.} 

         oDlgIM:lMaximized := .T.  // By JPP - 19/10/2006 - 14:00 - Para exibir a barra de rolagem horizontal
      ACTIVATE MSDIALOG oDlgIM ON INIT EnchoiceBar(oDlgIM,bOk,bCancel)           
      
      IF (nOPCAO <> 1)
         Break
      ENDIF
      
      // alterado por Cristiane C Figueiredo em 29/05/2000 ref a reimpressao
      // alterado por Cristiane C Figueiredo em 15/06/2000 ref a Fase 
      if substr(cFase,1,1) == "1"
         cFase := WORKID->EEA_FASE
      endif
      // fim da alteracao de 15/06/2000 feita por CCF
      
      Do Case 
    	 CASE substr(cFase,1,1) == "2"
    	 	cFased := "1"
    	 CASE substr(cFase,1,1) == "3"
    	 	cFased := "2"
    	 CASE substr(cFase,1,1) == "1"
    	 	cFased := "3"
    	 CASE substr(cFase,1,1) == "4"
    	 	cFased := "4"
      End Case
      
      IF ( WORKID->EEA_CNTLIM $ cSim )
         aOrdImp := saveord("SY0")
         SY0->(DBSETORDER(4))
         IF SY0->(DBSEEK(XFILIAL("SY0")+cPROCES+cFased+WORKID->EEA_COD))
            nOpcao := 0
            cTit   := AllTrim(Workid->EEA_TITULO) + " " + AllTrim(cProces)
            DEFINE MSDIALOG oDlgID FROM 9,10 TO 15,60  TITLE cTit OF oMAINWND
          
            @ 1.5,003 BUTTON aExecutar[1] SIZE 35,15 ACTION EVAL(bBotao1)
            @ 1.5,015 BUTTON aExecutar[2] SIZE 35,15 ACTION EVAL(bBotao2)
            @ 1.5,027 BUTTON aExecutar[3] SIZE 35,15 ACTION EVAL(bBotao3)
            @ 1.5,039 BUTTON aExecutar[4] SIZE 35,15 ACTION EVAL(bBotao4)
          
            ACTIVATE MSDIALOG oDlgID CENTERED
            IF nOpcao == 1 .Or. nOpcao == 2
               SY0->(dbSetOrder(5))
               SY0->(DBSeek(xFilial()+cPROCES+SY0->Y0_DOC))
            Endif
            IF (nOpcao == 1)
      	      AVRPTVIEW()
      		   BREAK
            ElseIf nOpcao == 2//Msgnoyes(OemtoAnsi("Confirma Cancelar?"),Oemtoansi("Aten‡Æo"))
               RECLOCK("SY0",.F.) 
               SY0->(DBDELETE())
               SY0->(MsUnlock())
            ELSEIF nOpcao == 4
               lRET:=.F.
               BREAK
            Endif    
         Endif
      Endif

      nIncCod := 1
      
      While lVezes == .T. //For nCont:= 1 To nVezes
         MsAguarde({|| MsProcTxt(STR0027), AA100CRW(cProces,cFased)}) //"Gerando Relatório ..." 
         
         nIncCod++         
         lVezes := lImpNor               
      EndDo
      
      //MsAguarde({|| MsProcTxt(STR0027), AA100CRW(cProces,cFased)}) //"Gerando Relatório ..." 
      
   END SEQUENCE
   
   WorkID->(E_EraseArq(cArqWork,cINDEX2))
   EEA->(DBSETORDER(1))
   DBSELECTAREA(nOLDAREA)

   CursorArrow()

RETURN lRET

/*
    Funcao   : AA100CRW
    Autor    : Cristiano A. Ferreira / Cristiane C. F.
    Data     : 14/08/2000 17:01
    Revisao  : 
    Uso      : Efetuar a chamada do Crystal
    Recebe   :
    Retorna  :

*/
Function AA100CRW(cProces,cFased)

Local aOrd2 := IF(Select("WorkDoc") > 0,SaveOrd({"WorkDoc"}),{})
Local lRet :=.t., lImpresso
Local cRpt, nInc, nRecEXB := 0
Local cPedido, cPreEmb   
Local nPos   
Local lCallCrw := .T.

Private aSeqRel := {}
Private lImprPadrao := .T.
Private c__Process := cProces
Private c__Fased :=cFased
Private lEmbarque := .T.
Private lShowTela := .T.
Private cProcesso := cProces

/* JPM - 17/08/2007 - Define se é o novo tratamento de impressão por invoice onde é feita uma chamada de Crystal para cada invoice.*/
Private lNewImpInv := EasyGParam("MV_AVG0137",,.T.)

Begin Sequence

	//MFR 16/04/2021 OSSME-5752 retirado pois o smartaclient não vai executar nem em crystal e nem em aph
	If GetRemoteType() == 5 //.And. !CAA100isAph()     //NCF - 05/10/2017 - SmarClient Html
		MsgAlert(STR0057,STR0041) //"O Documento/Carta/Relatório não pode ser emitido/impresso via acesso do usuário por SmartClient HTML."
		lRet := .F.
		Break
	EndIf

   If Select("Header_p") = 0
      AbreEEC()
   EndIf
   
   If !lEmbarque
       c__Fased   := "I"
   EndIf

   WORKID->(DBGOTOP())
   WHILE ( WORKID->(!EOF() ))
      IF ( !EMPTY(WORKID->WKFLAG))
      
         lCallCrw := AA100InvImp()
         
         If lImprPadrao
            lCallCrw := AA100ExeFunc(cProces)            
         ElseIf HEADER_P->(BoF() .And. EoF()) .And. DETAIL_P->(BoF() .And. EoF()) // JPM - 15/09/05 - para não imprimir dados em branco
            lRet := .f.
            Break
         EndIf
         
         If !lCallCrw
            lRet := .F. 
            Break         
         EndIf

         /* JPM - no velho tratamento, a impressão é feita de uma vez 
                  para todas as invoices. */
         If !lNewImpInv .Or. lImprPadrao
            // ** JPM - Efetua a chamada do Crystal
            lIMPRESSO := AA100CallCrw()
         EndIf
         
         If At(".RPT",Upper(WorkID->EEA_ARQUIV)) != 0
            cRpt := WORKID->EEA_ARQUIV
         EndIf
         
         //gravar historico de documentos
         For nPos := 1 To Len(aSeqRel)
                     
            cSeqRel := aSeqRel[nPos][1] // Grava Historico separado para cada Invoice, se for escolhida essa opcao. 
                                        // By OMJ - 13/06/05
            c__Process := aSeqRel[nPos][2]
           
            If !lEmbarque
               c__Fased   := "I"
            EndIf
            
            IF ( lIMPRESSO )
         
               If nPos > 1
                  AVDelay(1) // Pra nao gravar a mesma chave no SY0 (Data/Hora). Erro no TOP.
               EndIf

               //E_HISTDOC(,WorkId->EEA_TITULO,dDATABASE,,,cRPT,cSeqrel,cFased/*IF(cFASE=="P","1","2")*/,cPROCES,WORKID->EEA_COD)
               E_HISTDOC(,WorkId->EEA_TITULO,dDATABASE,,,cRPT,cSeqrel,c__Fased,c__Process,WORKID->EEA_COD)

               // ** By JBJ - 12/08/02 - 15:14
               // Preencher a data de emissao...
               If Select("EXB") > 0
            
                  EXB->(DbSetOrder(1))               
               
                  cPedido := IF(cFased == "2",cPROCES,AvKey("","EXB_PEDIDO"))
                  cPreEmb := IF(cFased == "2",AvKey("","EXB_PREEMB"),cPROCES)
               
                  // Procurar o registro ativo no EXB
                  EXB->(DbSeek(xFilial("EXB")+cPreEmb+cPedido+WORKID->EEA_COD+"1"))
                  
                  If !EXB->(Eof()) .And. Empty(EXB->EXB_DTREAL)                  
                     EXB->(RecLock("EXB",.f.))
                     EXB->EXB_DTREAL := dDataBase
                     EXB->EXB_USER   := cUserName
                     EXB->EXB_DATA   := dDataBase
                     WorkDoc->EXB_DTREAL := dDataBase
                     WorkDoc->EXB_USER   := cUserName
                     WorkDoc->EXB_DATA   := dDataBase
                     EXB->(MsUnlock())
                  Elseif !EXB->(Eof())
                     For nInc := 1 TO EXB->(fCount())
                         M->&(EXB->(FieldName(nInc))) := EXB->(FieldGet(nInc))
                     Next
                     EXB->(RecLock("EXB",.f.))
                     EXB->EXB_TIPO := "2" // Marcar o registro antigo como Historico
                     EXB->(MsUnlock())
                    
                     EXB->(RecLock("EXB",.T.))
                     nRecEXB := EXB->(RecNo())
                     AvReplace("M","EXB")
                     EXB->EXB_DTREAL := dDataBase
                     EXB->EXB_USER   := cUserName
                     EXB->EXB_DATA   := dDataBase
                     WorkDoc->EXB_DTREAL := dDataBase
                     WorkDoc->EXB_USER   :=cUserName
                     WorkDoc->EXB_DATA   := dDataBase
                  EndIf
               EndIf

               If nPos = Len(aSeqRel)
                  lIMPRESSO:= .F.
               Endif
               
            EndIf

         Next nPos

         if EEA->(fieldpos("EEA_TIPMOD")) > 0 .and. WORKID->EEA_TIPMOD == '1'
            if select("HEADER_P") > 0
               HEADER_P->(AVZAP())
            endif
            if select("DETAIL_P") > 0
               DETAIL_P->(AVZAP())
            endif
         endif

         Exit
      ENDIF
      WORKID->(DBSKIP(1))
   END
End Sequence
   
IF Empty(aOrd2)
   RestOrd(aOrd2)
Endif

Return lRet

/*
    Funcao   : EECPCA00(cCALLLOC,pPARAMETROS)
    Autor    : Heder M Oliveira    
    Data     : 19/08/99 17:14
    Revisao  : 19/08/99 17:14
    Uso      : Executar impressao via RPT de cadastros
    Recebe   :
    Retorna  :

*/
/*
verificar se o MV_CRYSTAL estah configurado para o mesmo diretorio 
 onde estao os RPT's

cCALLLOC := define qual cadastro estah fazendo a chamada. Este identificador
                eh definido nos programas de cadastro

cRPT:= nome do RPT que deve ser executado
pPARAMETROS:=Parametros a ser passado ao Crystal. Geralmente vem a chave
estes relatos sao dependentes de dicionario crystal EEC407.DC5
*/
FUNCTION EECPCA00(cCALLLOC,pPARAMETROS)
   DEFAULT pPARAMETROS:="X"
   DO CASE 
    CASE cCALLLOC=="EE4"
        cRPT := "EE4CAD"
    CASE cCALLLOC=="EE7"
        cRPT := "EE7CAD"
   ENDCASE
   //executar relatorio
   //CALLCRYS(cRPT,pPARAMETROS)
   AvgCrw32(cRpt,,pParametros)
RETURN NIL

/*
    Funcao   : AA100REL()
    Autor    : Heder M Oliveira    
    Data     : 08/09/99 17:00
    Revisao  : 08/09/99 17:00
    Uso      : Chamadas de Menu Para Impressoes
    Recebe   :
    Retorna  :

*/
FUNCTION AA100REL( )
   LOCAL aBOXDOCUM:=COMBOSX5("YD",.F.)
RETURN (EECAA101(,aBOXDOCUM[3],,,.f.))


/*
    Funcao   : AA100DOC()
    Autor    : Heder M Oliveira    
    Data     : 08/09/99 17:00
    Revisao  : 08/09/99 17:00
    Uso      : Chamadas de Menu Para Impressoes
    Recebe   :
    Retorna  :

*/
FUNCTION AA100DOC( )
   LOCAL aBOXDOCUM:=COMBOSX5("YD",.F.)
   Local cCodId   := UPPER(AvKey(EasyGParam("MV_AVG0035",,"PORT."),"X5_CHAVE"))
   Private cSXBID := AvKey(cCodId+"-"+Tabela("ID",cCodId),"EE4_IDIOMA")
RETURN (EECAA101(,aBOXDOCUM[2],,,.T.))

/*
    Funcao   : AA100DOC()
    Autor    : Heder M Oliveira    
    Data     : 08/09/99 17:00
    Revisao  : 08/09/99 17:00
    Uso      : Chamadas de Menu Para Impressoes
    Recebe   :
    Retorna  :

*/
FUNCTION AA100FAX( )
   LOCAL aBOXDOCUM:=COMBOSX5("YD",.F.)
RETURN (EECAA101(,aBOXDOCUM[1],,,.T.))

/*
Funcao      : EECAAF3()
Parametros  : Nenhum
Retorno     : nil
Objetivos   : Selecao de Processos/Embarques
Autor       : Cristiano A. Ferreira
Data/Hora   : 15/09/99 10:45
Revisao     : Jeferson Barros Jr. - 24/10/01 10:20
Obs.        :
*/
*-----------------*
Function EECAAF3()
*-----------------*                   

Local lRet     := .f.
Local btnPRO   := {|| nRADIO := 1,nCANCEL := 1,oDLG:END()}
Local btnEMB   := {|| nRADIO := 2,nCANCEL := 1,oDLG:END()}
Local bOk      := {|| oDlg:End()}
Local bCancel  := {|| oDlg:End()}
Local bProc    := {|| ConPad1(,,,"EE7","EE7->EE7_PEDIDO",,.F.),cRetorno:=EE7->EE7_PEDIDO,Eval(bVar,cRetorno)}
Local bEmb     := {|| ConPad1(,,,"EEC","EEC->EEC_PREEMB",,.F.),cRetorno:=EEC->EEC_PREEMB,Eval(bVar,cRetorno)}
Local cTitRpt  := STR0036 //"Seleção Processo/Embarque"
Local cTit     := STR0037 //"Pesquisar por "
Local cVar     := IIF(!Empty(__ReadVar),__ReadVar,"cProcesso")
Local bVar     := MemVarBlock(cVar)
Local nCancel  := 0 
Local cRetorno := ""
Local nRadio   := 1
Local oPrc

PRIVATE LALTERA := .F. 


Begin Sequence

   DEFINE MSDIALOG oDlg TITLE cTitRpt FROM 9,0 TO 19,49 OF oMainWnd 
      oPrc := TPanel():New(01,01,"",oDlg,,,,,,oDlg:nWidth,oDlg:nHeight/2)
      oPrc:Align := CONTROL_ALIGN_ALLCLIENT      
	  
      //@ 16,010 TO 47,110 LABEL cTit PIXEL                      
      @ 6,005 TO 43,175 LABEL cTit PIXEL OF oPrc                        
      @ 18,020 BUTTON STR0007 SIZE 35,12 ACTION EVAL(btnPRO) OF oPrc PIXEL //"Processo"
      @ 18,060 BUTTON STR0035 SIZE 35,12 ACTION EVAL(btnEMB) OF oPrc PIXEL //"Embarque"

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED   

   If nCancel # 0
      If nRadio = 1 
         Eval(bProc)
      Else 
         Eval(bEmb)
      EndIf
   EndIf  
   
   IF &cVar <> "" //LRS -24/03/2017 - Adicionado lRet para nao dar erro log no return
      lRet := .T.
   EndIF   
   
End Sequence

Return lRet

Function AA100TPDOC()
    Local lRet:=.T.,cOldArea:=select(),cX5_DESC
    Local oModel := FWModelActive()
    Local oView := FWViewActive()

    Begin sequence
       If ! EMPTY(cX5_DESC:=Tabela('YD',Left(M->EEA_TIPDOC,1)))
          M->EEA_TIPDOC:=Left(SX5->X5_CHAVE,1) + "-" + cX5_DESC
       Else
          M->EEA_TIPDOC:=SPACE(25)
          lRet:=.F.
       EndIf

       If Valtype(oModel) == "O" .And. !Empty(cX5_DESC) .And. (oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4) .And. !Empty(oModel:GetValue('EECP018_EEA',"EEA_TIPDOC"))
          oModel:SetValue("EECP018_EEA","EEA_TIPDOC", Left(oModel:GetValue('EECP018_EEA',"EEA_TIPDOC"),1) + "-" + AllTrim(cX5_DESC))
       EndIf
   
    End Sequence
    
    lRefresh:=.T.

    If ValType(oView) == "O"
       oView:Refresh()
    EndIf

    dbselectarea(cOldArea)
Return lRet

/*
Funcao          : AA100ClaDoc()
Parametros      : Nenhum
Objetivos       : Retornar descricao da Classe do Documento.
Autor           : Jeferson Barros Jr.
Data/Hora       : 02/08/02 13:44
Revisao         :
Obs             :
*/
*---------------------*
Function AA100ClaDoc()
*---------------------*
Local lRet:=.T.,cOldArea:=select(),cX5_DESC
Local oModel := FWModelActive()
Local oView := FWViewActive()

Begin sequence
   If !Empty(M->EEA_CLADOC) .And. ! EMPTY(cX5_DESC:=Tabela('CU',Left(M->EEA_CLADOC,1)))
      M->EEA_CLADOC:=Left(SX5->X5_CHAVE,1) + "-" + cX5_DESC
   Else
      M->EEA_CLADOC:=SPACE(35)
      lRet:=.F.
   EndIf

   If Valtype(oModel) == "O" .And. !Empty(cX5_DESC) .And. (oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4) .And. !Empty(oModel:GetValue('EECP018_EEA',"EEA_CLADOC"))
       oModel:SetValue("EECP018_EEA","EEA_CLADOC", Left(oModel:GetValue('EECP018_EEA',"EEA_CLADOC"),1) + "-" + AllTrim(cX5_DESC))
   EndIf

End Sequence
    
lRefresh:=.T.

If ValType(oView) == "O"
   oView:Refresh()
EndIf
    
dbselectarea(cOldArea)

Return lRet

/*
Funcao          : AA100ValAtv()
Parametros      : Nenhum
Objetivos       : Validar a inclusao de atividades/documentos.
Autor           : Jeferson Barros Jr.
Data/Hora       : 13/08/02 10:44
Revisao         :
Obs             :
*/
*--------------------*
Function AA100ValAtv()
*--------------------*
Local lRet:=.T.,cOldArea:=select(), cCampo

Begin Sequence

   If Type("M->EEA_TIPDOC") <> "U"
      If Left(M->EEA_TIPDOC,1) == "4"

         If Empty(M->EEA_CLADOC)
            cCampo:=AvSx3("EEA_CLADOC",AV_TITULO)
         ElseIf Empty(M->EEA_IDIOMA)
            cCampo:=AvSx3("EEA_IDIOMA",AV_TITULO)
         ElseIf Empty(M->EEA_ARQUIV)
            cCampo:=AvSx3("EEA_ARQUIV",AV_TITULO)
         EndIf
      Else
         Break
      EndIf

      If !Empty(cCampo)
         MsgStop(STR0039+AllTrim(cCampo)+STR0040,STR0041) //"Na manutenção de atividades, o campo "###" é de preenchimento obrigatório."###"Atenção"
         lRet:=.f.
      EndIf
   EndIf

End Sequence

Dbselectarea(cOldArea)

Return lRet

/*
Funcao          : AA100InvImp()
Parametros      : cFased
Retorno         : lRet
Objetivos       : Impressao de Documento por Invoice
Autor           : Osman Medeiros Jr. 
Data/Hora       : 09/06/05 08:44
Revisao         :
Obs             :
*/
*--------------------*
Function AA100InvImp(cFased)
*--------------------*
Local lRet := .F.
Local aOrd := saveord({"EE9"})
Local nOldArea := Select()
Local aSemSx3
Local cArqWork
Local oDlg, oMark, oBtn, nOpcao := 0
Local lInverte:=.f., cMarca := GetMark()
Local bOk     := {|| nOpcao := 1 , oDlg:End() }
Local bCancel := {|| nOpcao := 0 , oDlg:End() }
Local lFirst, lErro, lContinua
Local cArqHead, cArqDeta
Local bSet  := {|x,o| lEmbarque := x,;
                      o:Refresh(),;
                      Eval(bActive,!lEmbarque),;
                      lEmbarque }
Local aButtons:={}

//Indica se o documento pode ser impresso por Invoice
Private lDocImpInv := EECFlags("INVOICE") .And.;
                    Left(WorkId->EEA_TIPDOC,1) $ "1/2" .And.;
                    Left(WorkId->EEA_FASE,1) = "3" .And.;
                    WorkId->(FieldPos("EEA_IMPINV")) # 0 .And.;
                    WorkId->EEA_IMPINV $ cSim

/* JPM - 17/08/2007 - Define se é o novo tratamento de impressão por invoice onde é feita uma chamada de Crystal para cada invoice.*/
Private lNewImpInv := EasyGParam("MV_AVG0137",,.T.)

Private aHeader := {}
Private aCampos := Array(EXP->(FCount()))

bActive := {|x| oMark:oBrowse:lActive := x,;
                oMark:oBrowse:Refresh() } 
                
ChkFile("EXP")
ChkFile("EXR") 

//If Select("EXP") > 0 
If lDocImpInv
   aSemSx3 := { { "WKFLAG" ,"C",2,0 } } 
   cArqWork:=E_CriaTrab("EXP",aSemSX3,"WorkEXP")
   IndRegua("WorkEXP",cArqWork+TEOrdBagExt(),"EXP_NRINVO")
Else
   Return lRet
EndIf

Begin Sequence

   If Left(WorkId->EEA_TIPDOC,1) $ "1/2" .And. Left(WorkId->EEA_FASE,1) = "3" //Somente Documentos e Fax na Fase de Embarque
      If WorkId->(FieldPos("EEA_IMPINV")) # 0 .And. EECFlags("INVOICE")
         If WorkId->EEA_IMPINV $ cSim   // Se tem no Doc. Cadastrado para Ser Impresso por Invoice

            bProcessa := {|| WorkEXP->(dbAppend()) ,AvReplace("EXP","WorkEXP") }

            bWhile := {|| !EXP->(Eof()) .And.;
                          EXP->EXP_FILIAL == xFilial("EXP") .And.;
                          EXP->EXP_PREEMB == EEC->EEC_PREEMB }
               
            EXP->(dbSeek(xFilial("EXP")+EEC->EEC_PREEMB))                  
            EXP->(dbEval(bProcessa,,bWhile))

            WorkEXP->(dbGoTop())                                    
                  
            TB_Campos := {{"WKFLAG"    ,,"  "},;
                          {"EXP_NRINVO",,AvSx3("EXP_NRINVO",AV_TITULO)},;
                          {"EXP_DTINVO",,AvSx3("EXP_DTINVO",AV_TITULO)},;
                          {"EXP_TOTPED",,AvSx3("EXP_TOTPED",AV_TITULO),AvSx3("EXP_TOTPED",AV_PICTURE)}}                                                 
                                                                
            bMarca    := {|| WorkEXP->WKFLAG := If(Empty(WorkEXP->WKFLAG),cMarca,"") , oMark:oBrowse:Refresh() }

            bMarcaAll := {|| nRecWrk := WorkEXP->(RecNo()),;
                             If(Empty(WorkEXP->WKFLAG),;
                             WorkEXP->(dbEval({|| WorkEXP->WKFLAG := cMarca })),;
                             WorkEXP->(dbEval({|| WorkEXP->WKFLAG := ""     })) ) ,;
                             WorkEXP->(dbGoTo(nRecWrk)),;
                             oMark:oBrowse:Refresh() }
                             
            If WorkEXP->(Eof() .And. Bof())  // ** Nao nao tiver fatura a impressao é a normal.
               Break
            EndIf                         

            lImprPadrao := .F.
                  
            If WorkEXP->(EasyRecCount()) == 1 // FJH - 22/12/05 - não pergunta quando há uma só invoice.
               lEmbarque := .F. // //impressão por invoice
               nOpcao := 1 // Okay
               WorkEXP->(dbGoTo(1))
               WorkEXP->WKFLAG := cMarca // Marcando a nota
            Else
               If lEmbarque
                  AAdd(aButtons, {"EDIT"  , bMarcaAll, STR0046, STR0046}) ////"Marcar Todas"
               EndIf
               Define MsDialog oDlg Title STR0044; //"Configuração de Impressão de Documentos"
                      From 1,1 To 30,120 Of oMainWnd
                                                                                             
                  aPos    := PosDlg(oDlg)
                  aPos[1] := 65   //WHRS TE-3996 498681/MTRADE-128 - Tela cortada         

                  oEmb := TCheckBox():New(35,20,STR0035,{|x| If(PCount()==0, lEmbarque,Eval(bSet, x,oInv))},oDlg,50,10,,,,,,,,) //"Embarque"
                  oInv := TCheckBox():New(35,70,STR0045 ,{|x| If(PCount()==0,!lEmbarque,Eval(bSet,!x,oEmb))},oDlg,50,10,,,,,,,,) //"Invoice"

                  TB_Campos := AddCpoUser(TB_Campos,"EXP","2")
                  
                  oMark := MsSelect():New("WorkEXP","WKFLAG",,TB_Campos,@lInverte,@cMarca,aPos)
                  oMark:bAval := bMarca       
                     
                  Eval(bActive,!lEmbarque)
                                                    
               Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,, aButtons) Centered
            Endif
                  
            If nOpcao = 0 
               Break
            EndIf
            
            If lEmbarque 
               lImprPadrao := .T.
               Break
            EndIf                          
            
            lRet     := .T. 
            lFirst   := .T.             
            lErro    := .F.                   
            lContinua:= .F.

            aHeader := {}
            aCampos := {}
            
            /* JPM - para o novo tratamento não é necessário armazenar os header 
                     e detail, pois o crystal será chamado por invoice. */
            If !lNewImpInv
               cArqHead:=E_CriaTrab(,HEADER_P->(dbStruct()),"COPY_HEA")
               cArqDeta:=E_CriaTrab(,DETAIL_P->(dbStruct()),"COPY_DET")
            EndIf
            
            WorkEXP->(dbGoTop())
            Do While !WorkEXP->(Eof())

               If Empty(WorkEXP->WKFLAG)
                  WorkEXP->(dbSkip()); Loop
               EndIf
               
               If !lFirst .And. lErro .And. !lContinua
                  If MsgYesNo(STR0050,STR0004) //"Deseja continuar a Impressão das outras Invoices ? "###"Atenção"
                     lContinua := .T. 
                  Else
                     lRet := .F. 
                     Exit   
                  EndIf               
               EndIf                    

               If EECFlags("INVOICE") .and. !lEmbarque
                  AA100TempEE9("ABRIR_WORK")
               EndIf   

               lErro := !AA100ExeFunc(WorkEXP->EXP_NRINVO)   

               If EECFlags("INVOICE") .and. !lEmbarque
                  AA100TempEE9("FECHAR_WORK")
               EndIf
               
               /* JPM - no novo tratamento, a impressão é feita imediatamente. */
               If lNewImpInv .And. !lErro
                  lRet := AA100CallCrw()
               EndIf
               
               HEADER_P->(dbGoTop())
               DETAIL_P->(dbGoTop())
               
               If !lNewImpInv
                  HEADER_P->(dbEval({|| COPY_HEA->(dbAppend()), AvReplace("HEADER_P","COPY_HEA") }))
                  DETAIL_P->(dbEval({|| COPY_DET->(dbAppend()), AvReplace("DETAIL_P","COPY_DET") }))
               EndIf


               HEADER_P->(avzap())

               DETAIL_P->(avzap())
                                           
               lFirst := .F. 
               WorkEXP->(dbSkip())

            EndDo           
            
            If !lNewImpInv
               COPY_HEA->(dbGoTop())
               COPY_DET->(dbGoTop())
   
               COPY_HEA->(dbEval({|| HEADER_P->(dbAppend()), AvReplace("COPY_HEA","HEADER_P") }))
               COPY_DET->(dbEval({|| DETAIL_P->(dbAppend()), AvReplace("COPY_DET","DETAIL_P") }))
               
               COPY_HEA->(E_EraseArq(cArqHead))
               COPY_DET->(E_EraseArq(cArqDeta))
            EndIf
               
         EndIf
      EndIf
   EndIF

End Sequence

If Select("WorkEXP") > 0 
   WorkEXP->(E_EraseArq(cArqWork))
EndIf
             
RestOrd(aOrd)
dbSelectArea(nOldArea)

Return lRet

/*Chama a função do relatório, ajustando de User Function para Function*/
Static Function CallFunction(cFuncao, lOpc1, lOpc2, aParams)
Local aDePara
Local xREt :=.F.
   If ExistBlock(cFuncao)
      xRet := ExecBlock(cFuncao, lOpc1, lOpc2, aParams)
   Else
      Private PARAMIXB := aParams
      aDePara := DeParaEEA()
      cFuncao:=cFuncao+"()"
      If (nPos := aScan(aDePara, {|x| x[1] == cFuncao }))
         cFuncao := aDePara[nPos][2]
      EndIf
      If !FindFunction(cFuncao)
         MsgInfo(StrTran(STR0058, "####", left(cFuncao,len(cFuncao)-2) + " (https://tdn.totvs.com/pages/viewpage.action?pageId=559284382)")) // ("O documento/ relatório não pode ser impresso pois o ambiente não está preparado para a geração. Para a geração, é necessário compilar o programa: 
         xRet := .F.
      Else
         xRet := &cFuncao
      EndIf
   EndIf

Return xRet

/*Faz o de-para da user function com a nova function, quando houver mudança de nome*/
Static Function DeParaEEA()
Local aDePara := {}

   aAdd(aDePara, {"FUNCAO_ORIGINAL", "FUNCAO_NOVA"})

Return aDePara

/*
Funcao          : AA100ExeFunc()
Parametros      : cProces
Retorno         : lRet
Objetivos       : Chama a Funcao cadastrado no EEA se houver
Autor           : Osman Medeiros Jr. 
Data/Hora       : 09/06/05 08:44
Revisao         :
Obs             :
*/

*--------------------*
Function AA100ExeFunc(cProces)
*--------------------*
Local lRet := .T.
Local bFUNC,nAlias,aOrd
Local lbRet

Begin Sequence

   IF ( !EMPTY(WORKID->EEA_RDMAKE))
      //bFUNC:='{||'+ALLTRIM(WORKID->EEA_RDMAKE)+'}'
      //Executa a função CallFunction no lugar do Execblock, possibilitando a conversão de rdmake para function
      bFUNC:='{||'+ALLTRIM(StrTran(Upper(WORKID->EEA_RDMAKE), "EXECBLOCK", "CALLFUNCTION"))+'}'
      bFUNC:=&bFUNC
               
      // *** Salva Situacao dos Arquivos ...
      nAlias := Select()
               
      IF Select("WorkIP") > 0
         aOrd := SaveOrd("WorkIP")
      Elseif Select("WorkIt") > 0
         aOrd := SaveOrd("WorkIt")
      Endif
      // ***
               
      // *** Disapara Rotina do Cadastro de Documentos ...
      lbRet:=EVAL(bFUNC)

      // *** Restaura Situacao dos Arquivos ...
      IF !Empty(aOrd)
         RestOrd(aOrd)
      Endif

      Select(nAlias)
      // ***

      IF ( VALTYPE(lbRet)=="L" .AND. !lbRet)
         lRet:=.F.
         BREAK
      ENDIF
   ENDIF
         
   Aadd(aSeqRel,{cSeqRel,cProces})

End Sequence

Return lRet


/*
Funcao          : AA100TempEE9()
Parametros      : cTipo
Retorno         : 
Objetivos       : Fecha o EE9 e cria com os dados da Carta de Credito / Invoice ou Embarque. 
Autor           : Osman Medeiros Jr. 
Data/Hora       : 09/06/05 08:44
Revisao         : 17/08/2007 - João Pedro Macimiano Trabbold - Reabrir o EEC tb.
Obs             :
*/
*--------------------*
Function AA100TempEE9(cTipo)
*--------------------*
Local aStrEE9, nPos, aStrEEC
Local cField, cFieldEE9, bGetSetEE9, bGetSetEXR, bGetSetEXS
Local nLenInd := 0
Local aIndex:= {}

/* JPM - 17/08/2007 - Define se é o novo tratamento de impressão por invoice onde é feita uma chamada de Crystal para cada invoice.*/
Private lNewImpInv := EasyGParam("MV_AVG0137",,.T.)

Static aArqs

// ** JPM - 17/08/2007
Static aArqs2
Static nRecnoEEC  // PLB 21/08/07

Do Case   

   Case cTipo = "ABRIR_WORK"

      aStrEE9 := EE9->(dbStruct())                     

      aArqs := {} 

      Aadd(aArqs, E_CriaTrab(,aStrEE9,"Temp_EE9"))

      aIndex:= EE9->(RetIndexKeys())
      
      //A work suporta no máximo 16 índices.
      nLenInd:= 1
      For nPos:= 1 To Len(aIndex)

         Aadd(aArqs,CriaTrab(,.f.)) 
         E_IndRegua("Temp_EE9", aArqs[Len(aArqs)] + TEOrdBagExt() , aIndex[nPos])

         nLenInd++
         If nLenInd > 16
            Exit
         EndIf

      Next
      
      For nPos := 2 To Len(aArqs)
         Temp_EE9->(dbSetIndex(aArqs[nPos] + TEOrdBagExt()))
      Next


      EE9->(dbSetOrder(3))

      EXR->(dbSeek(xFilial("EXR")+EEC->EEC_PREEMB+WorkEXP->EXP_NRINVO))
      Do While !EXR->(Eof()) .And.;
               EXR->EXR_FILIAL == xFilial("EXR") .And.;
               EXR->EXR_PREEMB == EEC->EEC_PREEMB .And.;
               EXR->EXR_NRINVO == WorkEXP->EXP_NRINVO

         Temp_EE9->(dbAppend())                                       

         EE9->(dbSeek(xFilial("EE9")+EEC->EEC_PREEMB+EXR->EXR_SEQEMB))

         If EE9->(FieldPos("EE9_SEQ_LC")) > 0    // ** Se existir o controle de Carta Por Produtos

            If EXS->(dbSeek(xFilial("EXS")+EE9->EE9_LC_NUM+EE9->EE9_SEQ_LC))

               For nPos:=1 To EXS->(FCount())    // ** Busca os Dados da Carta de Credito Relacionada.
                     
                  cField     := EXS->(FieldName(nPos))
                  bGetSetEXS := FieldWBlock(cField,SELECT("EXS"))
                  cFieldEE9  := "EE9"+SubStr(AllTrim(cField),4)
                  bGetSetEE9 := FieldWBlock(cFieldEE9,SELECT("Temp_EE9"))
                  IF ( Temp_EE9->(FieldPos(cFieldEE9))#0)
                     Eval(bGetSetEE9,EVAL(bGetSetEXS))
                  Endif               

               Next 
               
               Temp_EE9->EE9_DESC := EXS->EXS_CODDES // Força a Descricao do Item da LC no Item do Embarque.

            EndIf

         EndIf
         
         For nPos:=1 To EXR->(FCount())  // ** Busca os dados dos Itens da Invoices
                     
            cField     := EXR->(FieldName(nPos))
            bGetSetEXR := FieldWBlock(cField,SELECT("EXR"))
            cFieldEE9  := "EE9"+SubStr(AllTrim(cField),4)
            bGetSetEE9 := FieldWBlock(cFieldEE9,SELECT("Temp_EE9"))
            IF ( Temp_EE9->(FieldPos(cFieldEE9))#0)
               If Empty(Eval(bGetSetEE9))
                  Eval(bGetSetEE9,EVAL(bGetSetEXR))
               EndIf   
            Endif               

         Next 
            
         For nPos:=1 To Temp_EE9->(FCount())       // ** Preenche com os Dados do EE9 o que nao for encontrado na Invoice ou LC

            cField := Temp_EE9->(FieldName(nPos))
            If Empty(Temp_EE9->(FieldGet(nPos))) .And. !(cField $ "FILIAL/DELETE") 
               Temp_EE9->(FieldPut(nPos,EE9->(FieldGet(FieldPos(cField)))))
            EndIf            

         Next
         
         //RMD - 11/02/09 - Evita que seja carregada a filial de outras tabelas (EXS ou EXR) para o EE9
         Temp_EE9->EE9_FILIAL := xFilial("EE9")

         EXR->(dbSkip())
            
      EndDo

      //Fecha e reabre a work com o nome da tabela 
      Temp_EE9->(dbCloseArea())
      EE9->(dbCloseArea())     
      TETempReopen(aArqs[1], "Temp_EE9", "EE9")

      //Refaz os índices
      EE9->(dbClearInd())
      For nPos := 2 To Len(aArqs)
         EE9->(dbSetIndex(aArqs[nPos] + TEOrdBagExt()))
      Next

      // ** JPM - 17/08/2007 - Efetua o mesmo tratamento para o EEC
      If !lNewImpInv
         Return
      EndIf
      aStrEEC := EEC->(dbStruct())                     

      aArqs2 := {} 

      Aadd(aArqs2, E_CriaTrab(,aStreec,"Temp_EEC"))

      aIndex:= EEC->(RetIndexKeys())
      
      //A work suporta no máximo 16 índices.
      nLenInd:= 1
      For nPos:= 1 To Len(aIndex)

         Aadd(aArqs2,CriaTrab(,.f.)) 
         E_IndRegua("Temp_EEC", aArqs2[Len(aArqs2)] + TEOrdBagExt() , aIndex[nPos])

         nLenInd++
         If nLenInd > 16
            Exit
         EndIf

      Next
      
      For nPos := 2 To Len(aArqs2)
         Temp_EEC->(dbSetIndex(aArqs2[nPos] + TEOrdBagExt()))
      Next
      
      EXP->(dbSeek(xFilial("EXP")+EEC->EEC_PREEMB+WorkEXP->EXP_NRINVO))

      Temp_EEC->(dbAppend())                                       

      If !Empty(EEC->EEC_LC_NUM) .And. EEL->(dbSeek(xFilial("EEL")+EEC->EEC_LC_NUM))

         For nPos:=1 To EEL->(FCount())    // ** Busca os Dados da Carta de Credito Relacionada.
                     
            cField     := EEL->(FieldName(nPos))
            bGetSetEEL := FieldWBlock(cField,SELECT("EEL"))
            cFieldEEC  := "EEC"+SubStr(AllTrim(cField),4)
            bGetSetEEC := FieldWBlock(cFieldEEC,SELECT("Temp_EEC"))
            IF ( Temp_EEC->(FieldPos(cFieldEEC))#0)
               Eval(bGetSetEEC,EVAL(bGetSetEEL))
            Endif               

         Next 
               
      EndIf

      For nPos:=1 To EXP->(FCount())  // ** Busca os dados da capa da Invoice
                     
         cField     := EXP->(FieldName(nPos))
         bGetSetEXP := FieldWBlock(cField,SELECT("EXP"))
         cFieldEEC  := "EEC"+SubStr(AllTrim(cField),4)
         bGetSetEEC := FieldWBlock(cFieldEEC,SELECT("Temp_EEC"))
         IF ( Temp_EEC->(FieldPos(cFieldEEC))#0)
            If Empty(Eval(bGetSetEEC))
               Eval(bGetSetEEC,EVAL(bGetSetEXP))
            EndIf   
         Endif               

      Next 
            
      For nPos:=1 To Temp_EEC->(FCount())       // ** Preenche com os Dados do EEC o que nao for encontrado na Invoice ou LC

         cField := Temp_EEC->(FieldName(nPos))
         If Empty(Temp_EEC->(FieldGet(nPos))) .And. !(cField $ "FILIAL/DELETE") 
            Temp_EEC->(FieldPut(nPos,EEC->(FieldGet(FieldPos(cField)))))
         EndIf            

      Next                                                    

      //RMD - 11/02/09 - Evita que seja carregada a filial de outras tabelas (EEL ou EXP) para o EEC
      Temp_EEC->EEC_FILIAL := xFilial("EEC")

      //Fecha e reabre a work com o nome da tabela
      Temp_EEC->(dbCloseArea())
      nRecnoEEC := EEC->( RecNo() )  // PLB 21/08/07
      EEC->(dbCloseArea())     
      
      TETempReopen(aArqs2[1], "Temp_EEC", "EEC")
      
      EEC->(dbClearInd())

      For nPos := 2 To Len(aArqs2)
         EEC->(dbSetIndex(aArqs2[nPos] + TEOrdBagExt()))
      Next

      // ** JPM - Fim
      
   Case cTipo = "FECHAR_WORK"

      EE9->(E_EraseArq(aArqs[1]))

      //ER - 05/03/2008 - A work suporta no máximo 16 índices.
      If Len(aArqs) > 16
         nLenInd := 16  
      Else
         nLenInd := Len(aArqs)
      EndIf
      
      For nPos := 1 To nLenInd
         If File(aArqs[nPos] + TEOrdBagExt())
            fErase(aArqs[nPos] + TEOrdBagExt())
         EndIf               
      Next
            
      If !ChkFile("EE9") // Abri a Tabela do Banco.
         MsgStop(STR0047)// "Erro ao abrir arquivo EE9"
      EndIf                                                                        

      // ** JPM - 17/08/2007 - Efetua o mesmo tratamento para o EEC
      If !lNewImpInv
         Return
      EndIf
      
      EEC->(E_EraseArq(aArqs2[1]))
       
      //ER - 05/03/2008 - A work suporta no máximo 16 índices.
      If Len(aArqs2) > 16
         nLenInd := 16  
      Else
         nLenInd := Len(aArqs2)
      EndIf
      
      For nPos := 1 To nLenInd
         If File(aArqs2[nPos] + TEOrdBagExt())
            fErase(aArqs2[nPos] + TEOrdBagExt())
         EndIf               
      Next
            
      If !ChkFile("EEC") // Abri a Tabela do Banco.
         MsgStop("Erro ao abrir arquivo EEC")
      EndIf
      EEC->( DBGoTo(nRecnoEEC) )  // PLB 21/08/07
      // ** JPM - Fim
      
End Case

Return 

/*
Funcao          : EECRetCab(cTipo)
Parametros      : cCampo
Retorno         : 
Objetivos       : Retorno o valor de Capa com os dados da Carta de Credito / Invoice ou Embarque. 
Autor           : Osman Medeiros Jr. 
Data/Hora       : 09/06/05 08:44
Revisao         :
Obs             :
*/
*--------------------*
Function EECRetCab(cCampo)
*--------------------*
Local _Ret := "", nPos 
Local aOrd := SaveOrd({"EEL"}) 
Local cAux := ""
Private lErro := .T.

Begin Sequence               

   EEL->(dbSetOrder(1))            

   If Type("lEmbarque") <> "L"
      lEmbarque := .T. 
   EndIf

   lSair := .F.
   If EasyEntryPoint("EECAA100")
      ExecBlock("EECAA100",.F.,.F.,{"EECRETCAB",cCampo})
   EndIf        
   If lSair
      Break
   EndIf

   Do Case   

      Case cCampo == "IMPORTADOR"

         cTEXT1 := cTEXT2 := cTEXT3 := cTEXT4 := ""
         cIMPCLI := ""
         If EECFlags("INVOICE") .and. !lEmbarque
            If !Empty(WorkEXP->EXP_LC_NUM) .And. EEL->(dbSeek(xFilial("EEL")+WorkEXP->EXP_LC_NUM))  
               cIMPCLI := EEL->EEL_IMPORT+EEL->EEL_IMLOJA
               cTEXT1 := AllTrim(EEL->EEL_IMPODE)               
               cTEXT2 := AllTrim(EEL->EEL_IMPEND)+" "+AllTrim(EEL->EEL_IMPEN2)
            ElseIf WorkEXP->(FieldPos("EXP_IMPORT")) > 0
               cIMPCLI := WorkEXP->EXP_IMPORT+WorkEXP->EXP_IMLOJA
               cTEXT1 := AllTrim(WorkEXP->EXP_IMPODE)
               cTEXT2 := AllTrim(WorkEXP->EXP_ENDIMP)+" "+AllTrim(WorkEXP->EXP_END2IM)
            EndIf             
         EndIf
         If lEmbarque .Or. Empty(cIMPCLI) 
            cIMPCLI := EEC->EEC_IMPORT+EEC->EEC_IMLOJA
            cTEXT1 := AllTrim(EEC->EEC_IMPODE)
            cTEXT2 := AllTrim(EEC->EEC_ENDIMP)+" "+AllTrim(EEC->EEC_END2IM)
         EndIf

         SA1->(DBSETORDER(1))
         SA1->(DBSEEK(XFILIAL("SA1")+cIMPCLI))
         SYA->(DBSETORDER(1))
         SYA->(DBSEEK(XFILIAL("SYA")+SA1->A1_PAIS))
         cTEXT3 := ""
         cTEXT4 := AllTrim(SYA->YA_DESCR)

         _Ret := {cTEXT1,cTEXT2,cTEXT3,cTEXT4,"","",""}
         lErro := .F.


      Case cCampo == "CONSIGNATARIO"
         
         cTEXT1 := cTEXT2 := cTEXT3 := cTEXT4 := ""
         cCONSIG := ""
         If EECFlags("INVOICE") .and. !lEmbarque
            If !Empty(WorkEXP->EXP_LC_NUM) .And. EEL->(dbSeek(xFilial("EEL")+WorkEXP->EXP_LC_NUM))  
               cCONSIG:= EEL->EEL_CONSIG+EEL->EEL_CONLOJ
               cTEXT1 := AllTrim(EEL->EEL_CONDES)               
               cTEXT2 := AllTrim(EEL->EEL_CONEND)+" "+AllTrim(EEL->EEL_CONEN2)
            ElseIf WorkEXP->(FieldPos("EXP_CONSIG")) > 0
               cCONSIG:= WorkEXP->EXP_CONSIG+WorkEXP->EXP_COLOJA
            EndIf             
         EndIf
         If lEmbarque .Or. Empty(cCONSIG) 
            If Empty(cCONSIG) 
               cCONSIG := EEC->EEC_CONSIG+EEC->EEC_COLOJA
            EndIf         
         EndIf

         SA1->(DBSETORDER(1))
         SA1->(DBSEEK(XFILIAL("SA1")+cCONSIG))

         SYA->(DBSETORDER(1))
         SYA->(DBSEEK(XFILIAL("SYA")+SA1->A1_PAIS))

         If Empty(cTEXT1) .And. Empty(cTEXT2)
            cTEXT1 := SA1->A1_NOME
            cTEXT2 := SYA->YA_DESCR         
         EndIf

         /*
         SYA->(DBSETORDER(1))
         SYA->(DBSEEK(XFILIAL("SYA")+SA1->A1_PAIS))
         */

         cTEXT3 := ""
         cTEXT4 := AllTrim(SYA->YA_DESCR)

         _Ret := {cTEXT1,cTEXT2,cTEXT3,cTEXT4,"","",""}
         lErro := .F.

      Case cCampo == "EXPORTADOR"

         cTEXT1 := cTEXT2 := cTEXT3 := cTEXT4 := ""
         cEXPFOR := ""

         If EECFlags("INVOICE") .and. !lEmbarque
            If !Empty(WorkEXP->EXP_LC_NUM) .And. EEL->(dbSeek(xFilial("EEL")+WorkEXP->EXP_LC_NUM))  
               cEXPFOR:= EEL->EEL_EXPORT+EEL->EEL_EXLOJA
               cTEXT1 := AllTrim(EEL->EEL_EXPODE)               
               cTEXT2 := AllTrim(EEL->EEL_EXPEND)
               cTEXT3 := AllTrim(EEL->EEL_EXPEN2)
            ElseIf WorkEXP->(FieldPos("EXP_EXPORT")) > 0
               cEXPFOR:= WorkEXP->EXP_EXPORT+WorkEXP->EXP_EXLOJA
            EndIf             
         EndIf

         If lEmbarque .Or. Empty(cEXPFOR)
            If Empty(cEXPFOR) 
               cEXPFOR := EEC->EEC_FORN+EEC->EEC_FOLOJA
            EndIf         
         EndIf
         
         SA2->(DBSETORDER(1))
         SA2->(DBSEEK(XFILIAL("SA2")+cEXPFOR))

         SYA->(DBSETORDER(1))
         SYA->(DBSEEK(XFILIAL("SYA")+SA2->A2_PAIS))

         If Empty(cTEXT1) .And. Empty(cTEXT2) .And. Empty(cTEXT3)
            cTEXT1 := ALLTRIM(SA2->A2_NOME)
            cTEXT2 := SA2->(ALLTRIM(A2_END)+"-"+ALLTRIM(A2_MUN))
            cTEXT3 := ALLTRIM(SA2->A2_EST)+"-"+ALLTRIM(SYA->YA_DESCR)
         EndIf

         /*
         SYA->(DBSETORDER(1))
         SYA->(DBSEEK(XFILIAL("SYA")+SA2->A2_PAIS))
         */

         cTEXT4 := ALLTRIM(SYA->YA_DESCR)

         _Ret := {cTEXT1,cTEXT2,cTEXT3,cTEXT4,"","",""}
         lErro := .F.

      Case cCampo == "NOTIFY"

         cTEXT1 := cTEXT2 := cTEXT3 := cTEXT4 := cTEXT5 := cTEXT6 := ""
         cNOTIFY := ""
         If EECFlags("INVOICE") .and. !lEmbarque
            If !Empty(WorkEXP->EXP_LC_NUM) .And. EEL->(dbSeek(xFilial("EEL")+WorkEXP->EXP_LC_NUM))  
               cNOTIFY:= EEL->EEL_NOTIFY+EEL->EEL_NOTLOJ
               cTEXT1 := AllTrim(EEL->EEL_NOTDES)               
               cTEXT2 := AllTrim(EEL->EEL_NOTEND)
               cTEXT3 := AllTrim(EEL->EEL_NOTEN2)
            ElseIf WorkEXP->(FieldPos("EXP_NOTIFY")) > 0
               cNOTIFY:= WorkEXP->EXP_NOTIFY+WorkEXP->EXP_NOLOJA
            EndIf             
         EndIf
         If lEmbarque .Or. Empty(cNOTIFY)
            EEN->(dbSeek(xFilial("EEN")+EEC->EEC_PREEMB+OC_EM))
            cNOTIFY:= EEN->EEN_IMPORT+EEN->EEN_IMLOJA
            cTEXT1 := EEN->EEN_IMPODE
            cTEXT2 := EEN->EEN_ENDIMP
            cTEXT3 := EEN->EEN_END2IM
         EndIf
         SA2->(DBSETORDER(1))
         SA2->(DBSEEK(XFILIAL("SA2")+cNOTIFY))
         SYA->(DBSETORDER(1))
         SYA->(DBSEEK(XFILIAL("SYA")+SA2->A2_PAIS))
         cTEXT4 := ALLTRIM(SYA->YA_DESCR)
         cTEXT5 := ALLTRIM(SA1->A1_TEL)
         cTEXT6 := ALLTRIM(SA1->A1_FAX)

         _Ret := {cTEXT1,cTEXT2,cTEXT3,cTEXT4,cTEXT5,cTEXT6,""}
         lErro := .F.

      Case cCampo == "PORTO_DE_ORIGEM"

         If EECFlags("INVOICE") .and. !lEmbarque
            If !Empty(WorkEXP->EXP_LC_NUM) .And. EEL->(dbSeek(xFilial("EEL")+WorkEXP->EXP_LC_NUM))  
               _Ret := EEL->EEL_DPTORI
            EndIf 
         EndIf
         If lEmbarque .Or. Empty(_Ret) 
            // BHF - 12/08/08 - Verific. existência do Porto interm... Se preenchido, recebe o porto interm., senão, porto de origem.
     //       cAux := SYR->YR_ORIGEM
            If EEC->(FieldPos("EEC_PTINT")) > 0 .And. !Empty(EEC->EEC_PTINT)
               cAux := EEC->EEC_PTINT
            Else
               SYR->(DBSETORDER(1))
               SYR->(DBSEEK(XFILIAL("SYR")+EEC->(EEC_VIA+EEC_ORIGEM+EEC_DEST+EEC_TIPTRA)))
               cAux := SYR->YR_ORIGEM    //Acb - 04/10/2010
            Endif
            
            SY9->(DBSETORDER(2))
            SY9->(DBSEEK(XFILIAL("SY9")+cAux))
            _Ret := SY9->Y9_DESCR

         EndIf
         lErro := .F.

      Case cCampo == "PORTO_DE_DESTINO"

         If EECFlags("INVOICE") .and. !lEmbarque
            If !Empty(WorkEXP->EXP_LC_NUM) .And. EEL->(dbSeek(xFilial("EEL")+WorkEXP->EXP_LC_NUM))  
               _Ret := EEL->EEL_DPTDST
            EndIf 
         EndIf
         If lEmbarque .Or. Empty(_Ret) 
            SYR->(DBSETORDER(1))
            SYR->(DBSEEK(XFILIAL("SYR")+EEC->(EEC_VIA+EEC_ORIGEM+EEC_DEST+EEC_TIPTRA)))
            SY9->(DBSETORDER(2))
            SY9->(DBSEEK(XFILIAL("SY9")+SYR->YR_DESTINO))
            _Ret := SY9->Y9_DESCR
         EndIf
         lErro := .F.

      Case cCampo == "COND_PAGTO"

         If EECFlags("INVOICE") .and. !lEmbarque
            If !Empty(WorkEXP->EXP_LC_NUM) .And. EEL->(dbSeek(xFilial("EEL")+WorkEXP->EXP_LC_NUM))  
               _Ret := EEL->EEL_DCONDP
            EndIf 
         EndIf
         If lEmbarque .Or. Empty(_Ret) 
            _Ret := SY6Descricao(EEC->EEC_CONDPA+Str(EEC->EEC_DIASPA,AVSX3("EEC_DIASPA",3),AVSX3("EEC_DIASPA",4)),EEC->EEC_IDIOMA,1) // Terms of Payment
         EndIf
         lErro := .F.

      Case cCampo == "FUMIGACAO"

         If EECFlags("INVOICE") .and. !lEmbarque
            If !Empty(WorkEXP->EXP_LC_NUM) .And. EEL->(dbSeek(xFilial("EEL")+WorkEXP->EXP_LC_NUM))  
               _Ret := MSMM(EEL->EEL_CODFMG,AvSx3("EEL_MEMFMG",AV_PICTURE))//EEL->EEL_MSGFMG
            EndIf 
         EndIf
         lErro := .F.

   OtherWise

      If lEmbarque

         If ( nPos := EEC->(FieldPos(cCampo)) )  # 0 
            _Ret := EEC->(FieldGet(nPos))        
            lErro := .F.
         EndIf
 
      Else
        
         If !Empty(WorkEXP->EXP_LC_NUM) .And. EEL->(dbSeek(xFilial("EEL")+WorkEXP->EXP_LC_NUM))  
            cFieldEEL  := "EEL"+SubStr(AllTrim(cCampo),4)
            IF ( nPos := EEL->(FieldPos(cFieldEEL))) #0   // Carta de Credito
               _Ret := EEL->(FieldGet(nPos))      
               lErro := .F.
            EndIf
         EndIf
   
         If Empty(_Ret) 
            cFieldEXP  := "EXP"+SubStr(AllTrim(cCampo),4)
            IF ( nPos := WorkEXP->(FieldPos(cFieldEXP))) #0   // Capa da Invoice
               _Ret := WorkEXP->(FieldGet(nPos))      
               lErro := .F.
            EndIf
         EndIf

         If Empty(_Ret) 
            If ( nPos := EEC->(FieldPos(cCampo)) )  # 0   // Capa do Embarque
               _Ret := EEC->(FieldGet(nPos))      
               lErro := .F.
             Endif               
         Endif               
   
      EndIf

   End Case

End Sequence

If lErro 
   MsgStop(STR0048 + cCampo + STR0049,STR0004)//"Campo: '"###"' não encontrado nos Arquivos(LC/Invoice/Embarque)."###"Atenção"
EndIf

RestOrd(aOrd) 
            
Return _Ret  

/*
Funcao          : AA100TPDDesc(cTipDoc,cTabela)
Parametros      : cTipDoc = Código a ser pesquisado na tabela do SX5
                  cTabela = Tabela na qual será efetuado a pesquisa
Objetivos       : Retornar descricao de tipo de documento
Autor           : Julio de Paula Paz
Data/Hora       : 19/10/2006 - 11:00
Revisao         :
Obs                     :
*/       
Function AA100TPDDesc(cTipDoc,cTabela)
    Local cRet:=Space(25),cOldArea:=select(),cX5_DESC
    
    Begin sequence
       If !Empty(cTipDoc) .And. ! EMPTY(cX5_DESC:=Tabela(cTabela,Left(cTipDoc,1)))
          cRet :=Left(SX5->X5_CHAVE,1) + "-" + cX5_DESC
       Else
          cRet := cTipDoc
       EndIf
    End Sequence
    
    dbselectarea(cOldArea)
Return cRet

/*
Funcao          : MenuDef()
Parametros      : Nenhum
Objetivos       : Inserir a funcionalidade do Menu Funcional para as rotinas que utilizam AxCadastro
Autor           : Adriane Sayuri Kamiya
Data/Hora       : 17/04/2007
Revisão         : Clayton Fernandes - 29/03/2011
Obs             : Adaptação do Codigo para o padrão MVC
*/                          
*------------------------*
 Static Function MenuDef()
*------------------------*
Local aRotina := {}
Local cStaticCall := "StaticCall(EECCAD00, MenuDef)"  
If !EasyHasMVC()
  //   aRotina := StaticCall(MATXATU,MENUDEF) 
//   aRotina := StaticCall(MATXATU,MENUDEF) 
Private cAvStaticCall := "EECAT180"
//Return StaticCall(EECCAD00, MenuDef)  
Return &cStaticCall
EndIf


//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EECAA100" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EECAA100" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EECAA100" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EECAA100" OPERATION 5 ACCESS 0 

Return aRotina




/*
Função      : AA100CallCrw()
Parâmetros  : Nenhum
Objetivos   : Efetuar a chamada do AvgCrw32, ou do executável.
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 17/08/2007 às 16:01
*/
*=====================*
Function AA100CallCrw()
*=====================*
Local lIMPRESSO :=.F.

Begin Sequence
   HEADER_P->(DBCOMMIT())
   DETAIL_P->(DBCOMMIT())
 //MFR 09/02/2021 OSSME-
   If CAA100isAph()
      EasyCallAph(rTrim(WorkId->EEA_ARQUIV),rTrim(WorkId->EEA_TITULO),rTrim(WorkId->EEA_MODELO),WorkId->EEA_EDICAO=='1',cProcesso,WORKID->EEA_COD,,WorkId->EEA_TIPCUS)
   ElseIF At(".RPT",Upper(WorkID->EEA_ARQUIV)) != 0
      cRpt := WORKID->EEA_ARQUIV
      // AvgCrw32 acrescenta o path do crystal
      IF AvgCrw32(cRpt,WorkId->EEA_TITULO,cSeqRel)
         lIMPRESSO:=.T.
      Endif
   Else
      IF At(".EXE",Upper(WorkID->EEA_ARQUIV)) != 0
         WINEXEC(ALLTRIM(EasyGParam("MV_CRYSTAL"))+WORKID->EEA_ARQUIV)
         lIMPRESSO:=.T.
      Endif
   Endif
   
End Sequence

Return lIMPRESSO

/*
Função      : CAA100isAph()
Parâmetros  : Nenhum
Objetivos   : Verifica se o relatório está no modelo aph e retorna .t. se estiver e false se não estiver
Autor       : Maurício Frison
Data/Hora   : 12/02/2021
*/

Function CAA100isAph()
Return EEA->(FieldPos("EEA_TIPCUS")) # 0 .And. EEA->(FieldPos("EEA_TIPMOD")) # 0 .And. EEA->(FieldPos("EEA_MODELO")) # 0;
      .And. ( (empty(WorkId->EEA_TipCus) .and.  WorkId->EEA_TipMod == "1") .or. (WorkId->EEA_TipCus == "1") )
   

/*
    Funcao   : AA100Split(cArqs)
    Autor    : Diogo Felipe dos Santos   
    Data     : 14/11/08 14:56
    Revisao  : 14/11/08 16:40
    Uso      : Permitir a inclusão de mais arquivos para impressão de relatório no campo Arqs Adi
    Recebe   : Variável de Memória (Digitações do Usuário)
    Retorna  : Array com os nomes dos arquivos
*/

Function AA100Split(cArqs)
Local aArqs := {} 
Local Pos

cArqs := StrTran(cArqs, ",", ";")
Pos := At(";", AllTrim(cArqs))
   While Pos # 0   
      aAdd (aArqs, AllTrim(SubStr(cArqs, 1, Pos-1)))
      cArqs := AllTrim(SubStr(cArqs, Pos+1))   
      Pos := At(";", AllTrim(cArqs))
   EndDo                                    '	
   aAdd(aArqs, AllTrim(cArqs))
   
Return aArqs

//crf
Function MVC_EECAA100()
Local oBrowse 
Local aColunas	:= AvGetCpBrw("EEA",,.T. /*desconsidera virtual*/)  
Local nX  := 0

Private aFilter   := {} 

For nX := 1 to Len(aColunas)       
   AAdd(aFilter, {AvSx3(aColunas[nX]    , AV_TITULO)  , AvSx3(aColunas[nX]    , AV_TITULO) , AvSx3(aColunas[nX]    , AV_TIPO) , AvSx3(aColunas[nX]    , AV_TAMANHO) , AvSx3(aColunas[nX]    , AV_DECIMAL), ""})      
Next nX


//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("EEA") //Informando o Alias                                             `
oBrowse:SetMenuDef("EECAA100") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Atividades/Docts
/* Filtro */	
oBrowse:SetUseFilter()
oBrowse:SetFieldFilter(aFilter)   
oBrowse:AddFilter(STR0060,"EEA->EEA_ATIVO <> '2' ",.F.,.T.) //Filtro 'Documentos Ativos'

//Habilita a exibição de visões e gráficos
oBrowse:SetAttach( .T. )
//Configura as visões padrão
oBrowse:SetViewsDefault(GetVisions())
         
//Força a exibição do botão fechar o browse para fechar a tela
oBrowse:ForceQuitButton()  

oBrowse:Activate()

Return 

//crf
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruEEA := FWFormStruct( 1, "EEA") //Monta a estrutura da tabela EEI
Local bCommit  := {|oMdl| EasyMVCGrava(oMdl,"EEA")}  
Local bPre     := {|oMdl| EECAAPRE(oMdl)}  
local bPos     := {|oMdl| EECAAPOS(oMdl)}
/*Criação do Modelo com o cID = "EXPP016", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EXPP018', bPre, bPos, bCommit, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela EEA
oModel:AddFields( 'EECP018_EEA',/*nOwner*/,oStruEEA, /*bPre*/, /*bPosValidacao*/, /*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Atividades/Docts

//Utiliza a chave primaria
//oModel:SetPrimaryKey({'EEA_FILIAL'},{'EEA_COD'},{'EEA_TIPDOC'},{'EEA_IDIOMA'})
  
  
Return oModel


//crf
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EECAA100")

// Cria a estrutura a ser usada na View
Local oStruEEI:=FWFormStruct(2,"EEA")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EECP018_EEA', oStruEEI)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EECP018_EEA') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 
/* MFR 14/01/2021 OSSME-5547 Retirado a carga deste fonte, ficou só no avupdate02 com controle de desativação de documentos
Static Function EDadosEEA(o)
*/

/*
Funcao          : AA100Idioma()
Parametros      : cCodI : Código do Item do Embarque
Retorno         : cDescricao : Descrição do Item no idioma
Objetivos       : Alterar a descrição do item para o idioma do relatorio.
Autor           : Guilherme Fernandes Pilan
Data/Hora       : 29/05/2012 - 12:25
*/
*------------------------------------------------*
Function AA100Idioma(cCodI)
*------------------------------------------------*
Local aOrd := SaveOrd("EE2")
Local cDescricao := ""     

//wfs
If Type("cIdiRel") == "U"
   cIdiRel:= WorkId->EEA_IDIOMA
EndIf

EE2->(DbSetOrder(1))  //EE2_FILIAL+EE2_CODCAD+EE2_TIPMEN+EE2_IDIOMA+EE2_COD    
If EE2->(DbSeek(xFilial("EE2")+"3*"+AVKey(cIdiRel,"EE2_IDIOMA")+AVKey(cCodI,"EE2_COD")))
   cDescricao := Alltrim(MSMM_DR(EE2->EE2_TEXTO,60)) 
Else
   MsgInfo(STR0056 + cIdiRel) //"Descrição do Item não cadastrada para o idioma "
   cDescricao := Alltrim(MSMM_DR(EE9->EE9_DESC,60))
EndIf

RestOrd(aOrd,.T.)
Return cDescricao

/***

 */
 /*
Função     : RetIndexKeys()
Objetivo   : Retorna os índices de uma tabela
Parâmetros : Nenhum
*/
Static Function RetIndexKeys()
Local aIndex := {}
Local i

If !Empty(Alias())
   
   For i := 1 To dbOrderInfo(9)//dbOrderInfo(DBOI_OrderCount)
      aAdd(aIndex,IndexKey(i))
   Next i
   
EndIf

Return aIndex

/*
Função     : GetVisions()
Objetivo   : Retorna as visões definidas para o Browse
Parâmetros : Nenhum
*/
Static Function GetVisions()
Local aVisions    := {}
Local aColunas    := AvGetCpBrw("EEA")
Local aContextos  := {"TODOS", "PROCESSO","EMBARQUE","FINANÇAS"}
Local cFiltro     := ""
Local oDSView
Local i

   If aScan(aColunas, "EEA_FILIAL") == 0
      aAdd(aColunas, "EEA_FILIAL")
   EndIf

   For i := 1 To Len(aContextos)
      cFiltro := RetFilter(aContextos[i])            
      oDSView    := FWDSView():New()
      oDSView:SetName(AllTrim(Str(i)) + "-" + RetFilter(aContextos[i], .T.))
      oDSView:SetPublic(.T.)
      oDSView:SetCollumns(aColunas)
      oDSView:SetOrder(1)
      oDSView:AddFilter(AllTrim(Str(i)) + "-" + RetFilter(aContextos[i], .T.), cFiltro)
      oDSView:SetID(AllTrim(Str(i)))
      oDsView:SetLegend(.T.)
      aAdd(aVisions, oDSView)
   Next

Return aVisions

/*
Função     : RetFilter(cTipo,lNome)
Objetivo   : Retorna a chave ou nome do filtro da tabela EEA de acordo com o contexto desejado
Parâmetros : cTipo - Código do Contexto
             lNome - Indica que deve ser retornado o nome correspondente ao filtro (default .f.)
*/
Static Function RetFilter(cTipo, lNome)
Local cRet     := ""
Default lNome  := .F.

   Do Case
      Case cTipo == "TODOS" .And. !lNome
         cRet := "EEA->EEA_FASE = '1' "
      Case cTipo == "TODOS" .And. lNome
         cRet := "TODOS" //"TODOS" "

      Case cTipo == "PROCESSO" .And. !lNome
         cRet := "EEA->EEA_FASE = '2' "
      Case cTipo == "PROCESSO" .And. lNome
         cRet := "PROCESSO" //"PROCESSO" "      

      Case cTipo == "EMBARQUE" .And. !lNome
         cRet := "EEA->EEA_FASE = '3' "
      Case cTipo == "EMBARQUE" .And. lNome
         cRet := "EMBARQUE" //"EMBARQUE" "      

      Case cTipo == "FINANÇAS" .And. !lNome
         cRet := "EEA->EEA_FASE = '4' "
      Case cTipo == "FINANÇAS" .And. lNome
         cRet := "FINANÇAS" //"FINANÇAS" "            
   EndCase

Return cRet

/*
Função     : EECAAPRE(oMdl)
Objetivo   : Função antes da abertura da tela para carga do campo EEA_TIPMOD
Parâmetros : oMdl - objeto do modelo de dados ModelDef
*/
Function EECAAPRE(oMdl)
Local oMdlEEA := oMdl:GetModel("EECP018_EEA")

If oMdlEEA:GetOperation() <> 3
   If EEA->(FieldPos("EEA_TIPMOD")) > 0 .And. Empty(oMdlEEA:GetValue("EEA_TIPMOD"))
      oMdlEEA:LoadValue("EEA_TIPMOD","2")
   EndIf
EndIf

Return .T.

/*
Função     : EECAAPOS(oMdl)
Objetivo   : Função para validação do modelo
Parâmetros : oMdl - objeto do modelo de dados ModelDef
*/
static function EECAAPOS(oMdl)
   local oMdlEEA := oMdl:GetModel("EECP018_EEA")
   local aArea   := {}
   local lRet    := .T.

   if oMdlEEA:GetOperation() == 3
      aArea := EEA->(getArea())
      EEA->(dbSetOrder(1)) // EEA_FILIAL+EEA_COD+EEA_TIPDOC+EEA_IDIOMA
      if EEA->(dbSeek( xFilial("EEA") + oMdlEEA:getValue("EEA_COD") + oMdlEEA:getValue("EEA_TIPDOC") + oMdlEEA:getValue("EEA_IDIOMA") ))
         EasyHelp( STR0066,STR0041,STR0067 ) // "Já existe um registro com essas informações.", "Atenção", "Verifique se o registro está como ativo."
         lRet := .F.
      endif
      restArea(aArea)
   endif

return lRet

/*
Função EasyCallAph
Objetivo: Gerar html e enviar para uma tela com o POUI com as opções de imprimir, fazer o download do pdf e enviar email
Parâmetros: cArqAphCus - Arquivo APH Customizado qunando houver
            cTitulo    - Título do documento
            cArqAphPdr - Arquivo APH Padrão
            lEdit - Se true indica que o arquivo no POUI será editável
            cProcesso - Número do Processo
            cCodDoc - Código do documento
            cHtml - Quando vem da visualização do histórico este campo vem preenchido com o relatório já pronto
            cTipCus - Tipo da customização (se estiver diferente de 1, usar o padrão, pois se chegou até aqui, já foi verificado que o modelo 
                      do relatório é em html), irá definir se vai usar o arquivo modelo padrão ou customizado
Author : Maurício Frison
Data   : 25/02/2021            
*/
Function EasyCallAph(cArqAphCus,cTitulo,cArqAphPdr, lEdit, cProcesso, cCodDoc, cHtml, cTipCus, lGeraHist, cArqPdf)
Local oPanel
Local lVisua := .F.
Local oUserParams	:= EASYUSERCFG():New('EECAA100') //tabela EWQ
Local cCodDocT := rtrim(cCodDoc)

Default cHtml := ""
default cArqPdf := cTitulo
Private cNomeArq := cArqPdf
Private cHtmlHist := ""
Private cPath := GetTempPath() 
Private cPathChrome := getPathChrome()
Private cPathPdf := ""
Private nLeft  := oUserParams:loadParam('M_L'+cCodDocT,1,,.t.) // true se não encontrar pega o valor padrao
Private nRight := oUserParams:loadParam('M_R'+cCodDocT,1,,.t.) 
Private nTop   := oUserParams:loadParam('M_T'+cCodDocT,1,,.t.) 
Private nBottom:= oUserParams:loadParam('M_B'+cCodDocT,1,,.t.) 
Private cPageP  := oUserParams:loadParam('C_P'+cCodDocT,"A4",,.t.) 
Private cMargin := oUserParams:loadParam('C_M'+cCodDocT,"1",,.t.) // "1" é o tipo de margem Padrão
private oEasyJS := nil
private oJson   := nil

Default lGeraHist := .T.

  If Empty(cPathChrome)
		easyhelp(STR0061,STR0052) //Não foi encontrado o Google Chrome neste computador, a operação será cancelada AVISO
		return
  EndIf
  if Empty(cHtml) 
     cHtml := if(cTipCus!="1", EasyExecAHU(cArqAphPdr,.T.) , EasyExecAHU(cArqAphCus) )
     if Select("AVGLTT") # 0
        AVGLTT->(E_EraseArq(tetempname("AVGLTT")))
     EndIf   
  Else
     lVisua := .T.   
  EndIf   
  
  If !Empty(cHtml)
      oJson := getJson(cTitulo,cProcesso,lEdit,cHtml) 
      If !Empty(oJson:getJsonText('pdf64')) 
         DEFINE MSDIALOG oDlg TITLE cTitulo FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
         oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
         oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
         oEasyJS:= EasyJS():New(oPanel)
         oEasyJS:SetApp("EASYPOAPP")
         oDlg:binit = {|| openapp(oDlg)}
         oDlg:lMaximized := .T.
         ACTIVATE MSDIALOG oDlg
      Else
         lVisua := .T.
      EndIf 
  EndIf    
  if !lVisua
     oUserParams:setParam('M_L'+cCodDocT,nLeft)
     oUserParams:setParam('M_R'+cCodDocT,nRight)    
     oUserParams:setParam('M_T'+cCodDocT,nTop)          
     oUserParams:setParam('M_B'+cCodDocT,nBottom)    
     oUserParams:setParam('C_P'+cCodDocT,cPageP)      
     oUserParams:setParam('C_M'+cCodDocT,cMargin)      
     If  lGeraHist
        geraHist(cHtmlHist)
     EndIf
  EndIf   
return

Static Function openapp(oDlg)
   oEasyJS:SetTimeOut(05)
   If oEasyJS:Activate(.T.)
		oEasyJS:runJS('AppComponent.generatePDF('+oJSON:ToJson()+');')
//		oEasyJS:runJS("AppComponent.downloadPDF = function downloadPDF(){return runAdvpl('CAA100MyPdf(args[1])',  btoa(Array.from(new Uint8Array(this.pdf.output('arraybuffer'))).map((a)=>{return String.fromCharCode(a)}).join('')))}")
		oEasyJS:runJS("AppComponent.downloadPDF = function downloadPDF(){return runAdvpl('CAA100MyPdf()')}")
		oEasyJS:runJS("AppComponent.sendEmailToProtheus = function sendEmailToProtheus(){return runAdvpl('CAA100APHEmail(args[1])', this.jEmail)}")
		oEasyJS:runJS("AppComponent.sendHtmlToProtheus  = function sendHtmlToProtheus(){return runAdvpl('CAA100HTMLPOUI(args[1],args[2],args[3],args[4],args[5],args[6],args[7])', this.htmlEdit,this.marginSuperior,this.marginInferior,this.marginDireita,this.marginEsquerda,this.tipoPagina,this.tipoMargem)}")
	EndIf
Return

/*
Função getPathChrome
Objetivo: Retornar .t. se encontrado o goole chrome na máquina.
Parâmetro: sem parâmetro
Author: Maurício Frison
Data: 12/01/2021
*/
Static Function getPathChrome()
	Local cPathArq := cPath + "PathChro.txt"
	Local cPathChrome := ""
	Local nHandle
	Local cString := ""
	Local cVarAmb:= getVarAmb(cPath+"VarAmb.txt")
	Local aVarAmb:= strtokarr(cVarAmb,',')
	Local cExec := getExec(aVarAmb,cPathArq)

	waitrun(cExec)
	nHandle := fOpen(cPathArq , 0)

	If nHandle == -1  
		easyhelp(StrTran(STR0062,'####',cPathArq) , STR0052) //Problema na abertura do arquivo ####  AVISO
	Else
		FRead( nHandle, @cString, 1024 )
		fclose(nHandle)
		cString := StrTran(cString, chr(13)+chr(10), '')
		cPathChrome := if(at('nao encontrado',cString) != 0 ,'',cString)
	EndIf
return cPathChrome


Static Function getVarAmb(cPathAmb)
	Local cVarAmb := ""
	Local cExecute := 'cmd /c Echo %ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe,%ProgramFiles%\Google\Chrome\Application\chrome.exe,%LocalAppData%\Google\Chrome\Application\chrome.exe,%userprofile%\Local Settings\Application Data\Google\Chrome\chrome.exe > "' + cPathAmb + '"'
	waitrun(cExecute)
   sleep(500)
	nHandle := fOpen(cPathAmb , 0)
	If nHandle == -1 
		easyhelp(StrTran(STR0062,'####',cPathAmb) + Str(fError(), 4) , STR0052) //Problema na abertura do arquivo AVISO
	Else
		FRead( nHandle, @cVarAmb, 1024 )
		cVarAmb := StrTran(cVarAmb, chr(13)+chr(10), '')
		fclose(nHandle)
	EndIf
return cVarAmb

Static Function getExec(aVarAmb,cPathArq)
	Local i:=0
	Local cExec:="cmd /c"
	cVarAux := ""
	for i:=1 to len(aVarAmb)
		cExec += ' dir "'+ aVarAmb[i] + '" && echo ' +  aVarAmb[i] + ' > ' + '"' + cPathArq + '"' + ' || '
	Next
	cExec += ' echo nao encontrado > ' + '"' + cPathArq + '"'
return cExec


/*
Função CAA100HTMLPOUI
Objetivo: Pegar o html alterado pelo usuário no POUI e gravar no hitórico de imrpessão documento/relatório corrente
Parâmetros: cHtml - Html alterado pelo usuário no POUI
Author : Maurício Frison
Data   : 11/03/2021            
*/
Function CAA100HTMLPOUI(cHtml,nPoTop,nPoBottom,nPoRight,nPoLeft,cPoPage,cPoMargin)  
   local cIdGlobal := "EECAA100_HTMPOUI"
   local cChave    := sha1(cHtml)
   local cRet      := ""
   local cPdf64    := ""

   nTop := nPoTop
   nBottom := nPoBottom
   nRight := nPoRight
   nLeft := nPoLeft
   cPageP := cPoPage
   cMargin := cPoMargin //Tipo da Margem

   VarSetUID(cIdGlobal, .T.)
   if( !varGetXD(cIdGlobal, cChave, @cRet) ) .or. ( valtype(cRet) == "C" .and. empty(cRet) )

      varSetXD(cIdGlobal, cChave, "1")

      cHtml := getHtmlCss(cHtml)
      cHtmlHist := cHtml
      cPdf64 := GravaHtmlTmp(cHtml)

      varSetXD(cIdGlobal, cChave, "")   
	endif

return cPdf64

Static Function geraHist(cHtmlHist)
if !Empty(cHtmlHist) 
    E_HISTDOC(,WorkId->EEA_TITULO,dDATABASE,,,,cSeqrel,c__Fased,c__Process,WORKID->EEA_COD,cHtmlHist)
EndIf
Return

Static Function convMarg(nMargin)
Return if(valType(nMargin)=="N",ltrim(Str(nMargin))+"cm",nMargin)

Static Function getHtmlCss(cHtml)
	Local iniHead := at('<style type="text/css" id="styleEasy">',cHtml) 
   Local fimHead := at("</style>",cHtml,iniHead) +8
   Local cTop,cBottom,cRight,cLeft

   cTop:=convMarg(nTop)
   cBottom:=convMarg(nBottom)
   cRight:=convMarg(nRight)
   cLeft:=convMarg(nLeft)

	if iniHead > 0 
	   cHtml := STUFF( cHtml, iniHead , fimHead - iniHead, "")
	EndIf   

	cCss := '<style type="text/css" id="styleEasy">'
	cCss += '@page {'
	cCss += 'margin-top: ' + cTop + ';'
	cCss += 'margin-bottom: ' + cBottom +';'
	cCss += 'margin-right: ' +cRight + ';'
	cCss += 'margin-left: ' + cLeft + ';'
	cCss += 'size: ' + cPageP + ';'
	cCss += '} '
	cCss +='</style>'
   cHtml := STUFF( cHtml, 1 , 0, cCss )

return cHtml

/*
Função GravaHtmlTmp
Objetivo: Pegar o html gerado no POUI, copiar em uma pasta temporária local e abrir como google chrome
Parâmetros: cHtml - Arquivo Html vindo do POUI
Author : Maurício Frison
Data   : 12/04/2021            
*/
Static Function GravaHtmlTmp(cHtml)
	Local posNomeArq := At(' ',cNomeArq)
	Local cArq := if(posNomeArq==0, cNomeArq, substr(cNomeArq,1,posNomeArq-1)  )
	Local cPathHtml := cPath + cArq +'.html' 
	Local cExecute
	Local cPdf64 :='' //pdf convertido em base 64
	Local cString
	Local aFiles := {} // O array receberá os nomes dos arquivos e do diretório
	Local aSizes := {} // O array receberá os tamanhos dos arquivos e do diretorio
   Local lErro := .F.
	cPathPdf := cPath + cArq +'.pdf'
	if file(cPathPdf)
		if FErase(cPathPdf) != 0  
			easyhelp(StrTran(STR0063,'####',cPathPdf), STR0052) // Problema na exclusão do pdf já existente, exlua manualmente o arquivo ou feche se ele já estiver aberto AVISO
         lErro := .T.
		Endif
	EndIf
   If !lErro 
      nHandle := FCreate(cPathHtml)
      FWrite(nHandle, cHtml)
      FClose(nHandle)
      cPathHtml := strTran(cPathHtml,'\','/')
      cExecute  := 'start/wait ' + '"" ' +  '"' + cPathChrome + '"' + ' --headless --print-to-pdf-no-header --print-to-pdf=' + '"' + cPathPdf + '"' + ' "file:///' + cPathHtml + '" '
      waitrun('cmd /c "' + cExecute +'"')

      ADir(cPathPdf, aFiles, aSizes)//Verifica o tamanho do arquivo, parâmetro exigido na FRead.
      nHandle := fopen(cPathPdf, 0)
      If nHandle == -1 
		   easyhelp(StrTran(STR0062,'####',cPathPdf) + Str(fError(), 4) , STR0052) //Problema na abertura do arquivo
      Else   
         cString := ""
         FRead( nHandle, cString, aSizes[1] ) //Carrega na variável cString, a string ASCII do arquivo.
         FClose(nHandle)
         cPdf64 := Encode64(cString) //Converte o arquivo para BASE64
      EndIf   
   EndIf   
return cPdf64

/*
Função CAA100MyPdf
Objetivo: Pegar o pdf gerado no POUI, copiar em uma pasta temporária local e abrir o pdf com programa padrao do windows
Parâmetros: cPdfs - Arquivo Pdf binário vindo do POUI
Author : Maurício Frison
Data   : 25/02/2021            
*/
Function CAA100MyPdf()
	ShellExecute("open",cPathPdf ,"","", 1)
return

/*
Função CAA100APHEmail
Objetivo: Pegar o Json com as informações para o envio do email, inclusive o pdf e anexos binários se houver
Parâmetros: cJson - Json com as informações para o envio do email conforme comentado acima
Author : Maurício Frison
Data   : 25/02/2021            
*/
Function CAA100APHEmail(cJson)
Local aMsg, i
Private cBodyJson,cFromJson,cSubjectJson,cCcJson,cToJson,cDirStart,cFolder
Private cAccount,cPassword,lAutentica,cUserAut,cPassAut,cServer,lRelTLS,lRelSLS,cRelPor,nTimeOut,cAttachment

   aMsg := getClientEmail(cJson) //gera as informacoes do client como destinatário, anexos, corpo do email e etc.
   if len(aMsg) > 0
      for i:=1 to len(aMsg)
          oEasyJS:runJS("AppComponent.poNotification.error('" + aMsg[i] + "');")      
      Next 
   Else      
      aMsg := getServerEmail()      //gera as configurações do sevidor de email
      if len(aMsg) > 0
         for i:=1 to len(aMsg)
             oEasyJS:runJS("AppComponent.poNotification.error('" + aMsg[i] + "');")      
         Next 
      Else
         aMsg := sendEmail()  //envia o email
         if len(aMsg) > 0
            for i:=1 to len(aMsg)
                oEasyJS:runJS("AppComponent.poNotification.error('" + aMsg[i] + "');")      
            Next 
         Else   
            oEasyJS:runJS("AppComponent.poNotification.success('E-mail enviado com sucesso');")      
         EndIf   
      EndIf   
   EndIf
return 

/*
Função geraEmail
Objetivo: Pegar o json vindo do POUI e gerar as informações do client para o envio do email, como destinatário, anexos, corpo do email e etc.
Parâmetros: cJson - json vindo do POUI contendo as informações do cliente para o envio do email
Retorno   : retorna o array de mensagens tendo ocorrências ou não
Author : Maurício Frison
Data   : 25/02/2021            
*/
Static Function getClientEmail(cJson)
Local i  
Local cBinarioTxt, cBinario, cChave 
Local oJson:=JsonObject():new()
Local aMsg := {}
cDirStart:=AllTrim(Upper(GetSrvProfString("STARTPATH","")))


   cBodyJson := cJson:getJsonText('conteudo')
   cFromJson := cJson:getJsonText('Remetente')
   cSubjectJson := cJson:getJsonText('Assunto')
   cCcJson := cJson:getJsonText('Copia')
   cToJson := cJson:getJsonText('Destinatario')

   if At("@",cFromJson) == 0
      aADD(aMsg,"Remetente: Campo obrigatório no formato de email! É preciso conter @") 
   EndIf

   if  !Empty(cCcJson) .and. cCCJson # 'null' .and. At("@",cCcJson) == 0
      aADD(aMsg,"Com cópia: Campo obrigatório no formato de email! É preciso conter @") 
   EndIf

   if At("@",cToJson) == 0
      aADD(aMsg,"Destinatário: Campo obrigatório no formato de email! É preciso conter @") 
   EndIf

   If Right(cDirStart, 1) <> "\"
      cDirStart += "\"
   EndIf
   cAttachment:=""
   if len(aMsg) == 0   
      cFolder := criaTrab(,.F.)
      MakeDir(cDirStart+cFolder)      
      oJson:FromJson(cJson:GetJsonText('anexos'))
      
      for i:= 1 to len(oJson:getNames())
         //gravar os arquivos no server         
         cChave := oJson:GetNames()[i]
         cBinarioTxt := oJson:getJsonText(cChave)
         cBinario := Decode64(cBinarioTxt)
                  
         nHandle := FCreate(cDirStart + cFolder + "\" + cChave)
         FWrite(nHandle, cBinario)
         FClose(nHandle)
         cAttachment := cAttachment + cDirStart + cFolder + "\" + cChave + ','
         
      Next
   EndIf
return aMsg


/*
Função getServerEmail
Objetivo: Pegar as configurações do server do email
Parâmetros: não tem
Author : Maurício Frison
Data   : 25/02/2021            
*/
Static Function getServerEmail()
Local aMsg := {}
cAccount  := AllTrim(EasyGParam("MV_RELACNT",,""))
cPassword := AllTrim(EasyGParam("MV_RELPSW",," "))         
lAutentica:= EasyGParam("MV_RELAUTH",,.F.)         //Determina se o Servidor de Email necessita de Autenticação
cUserAut  := Alltrim(EasyGParam("MV_RELAUSR",,cAccount))//Usuário para Autenticação no Servidor de Email  - By RGS - 18/02/05 - 09:45
cPassAut  := Alltrim(EasyGParam("MV_RELAPSW",,cPassword))//Senha para Autenticação no Servidor de Email - By RGS - 18/02/05 - 09:45
cServer   := AllTrim(EasyGParam("MV_RELSERV",,""))
lRelTLS     := EasyGParam("MV_RELTLS")
lRelSLS     := EasyGParam("MV_RELSSL")
cRelPor     := EasyGParam("MV_PORSMTP")
nTimeOut    := EasyGParam("MV_RELTIME",,120) //Tempo de Espera antes de abortar a Conexão //By RGS 18/02/04 - 09:45

IF EMPTY(cAccount)
    aADD(aMsg,STR0011) //"Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'"
ENDIF
If Empty(cServer)
   aADD(aMsg,"Servidor de email não configurado (Parâmetro MV_RELSERV)") //"Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'"
EndIf

if at(":",cServer) > 0
   if empty(cRelPor)
      cRelPor := val( Substr( cServer , at(":",cServer)+1 , len(cServer) ) )
   endif
  cServer := Substr( cServer , 1 , at(":",cServer)-1 )
endif

return aMsg

/*
Função sendEmail
Objetivo: Enviar o email configurado nas funcoes anteriores
Parâmetros: não tem
Author : Maurício Frison
Data   : 25/02/2021            
*/
Static Function sendEmail()
Local aMsg := {}
Local nErro
Local aAnexos := {}
Local i
   cToJson := AvLeGrupoEMail(cToJson)
   cCCJson := AvLeGrupoEMail(cCCJson)
   aAnexos := StrToKarr(cAttachment, ",")
   oMail := TMailManager():New()
	if lRelSLS
	  oMail:SetUseSSL( .T. )
	endif
   if lRelTLS
	  oMail:SetUseTLS( .T. )
	endif
	oMail:Init( '', cServer , cAccount , cPassword, 0 , cRelPor )
	oMail:SetSmtpTimeOut( nTimeOut )
	
	nErro := oMail:SmtpConnect()
	if nErro <> 0
     cErrorMsg := oMail:GetErrorString( nErro )   
     aADD(aMsg,"Falha na Conexao com Servidor de E-Mail :" +cErrorMsg) //"Falha na Conexao com Servidor de E-Mail: "
	Else
	  if lAutentica
	      nErro := oMail:SmtpAuth( cUserAut,cPassAut )
	      If nErro <> 0
	        cErrorMsg := oMail:GetErrorString( nErro )
	        aADD(aMsg,"Falha na Autenticacao do Usuario: "+cErrorMsg)  //"Falha na Autenticacao do Usuario: " 
	        oMail:SMTPDisconnect()
	        If nErro <> 0
	          cErrorMsg := oMail:GetErrorString( nErro )
             aADD(aMsg,"Erro na Desconexão: " + cErrorMsg) 
	        endif
	      endif
	  endif
	
	  if nErro == 0 
	    oMessage := TMailMessage():New()
	    oMessage:Clear()
	    oMessage:cFrom                  := cFromJson
	    oMessage:cTo                    := cToJson
	    oMessage:cCc                    := cCCJson
	    oMessage:cSubject               := cSubjectJson
	    oMessage:cBody                  := cBodyJson	   
	    
	    For i := 1 TO Len(aAnexos)	    
	    	//Adiciona um attach
	    	If oMessage:AttachFile( aAnexos[i] ) < 0	    
	    		cErrorMsg := oMail:GetErrorString( nErro )
            aADD(aMsg,"Falha ao Anexar Arquivo:" +aAnexos[i] + " no email: " + cErrorMsg) 
	    	EndIf
	    Next	
	
	    nErro := oMessage:Send( oMail )
	    if nErro <> 0
	      cErrorMsg := oMail:GetErrorString( nErro )
         aADD(aMsg,"Falha no Envio de E-Mail :" + cErrorMsg)  
	    EndIf
	
	    oMail:SMTPDisconnect()
	    If nErro <> 0
	      cErrorMsg := oMail:GetErrorString( nErro )
         aADD(aMsg,"Erro na Desconexão :" + cErrorMsg)  
	    endif
	
	  endif
	Endif   
   For i := 1 TO Len(aAnexos)	    
       fErase(aAnexos[i])
   Next
   DirRemove(cDirStart + cFolder)  
return aMsg

/*
Função getJson
Objetivo: Gera o json contendo as informacoes que serão exibidas na tela de email, juntamente com o html o qual será convertido em pdf pelo POUI
Parâmetros: cTitulo - Título do documento
            cProcesso - Número do processo
            lEdit - Indica se o documento poderá ser alterado no POUI (se true indica que sim)
            cHtml - html que será convertido para PDF no POUI
Author : Maurício Frison
Data   : 25/02/2021            
*/
Static Function getJson(cTitulo,cProcesso,lEdit,cHtml)
Local oJson := JsonObject():New()
Local i
Local aEmail := {}
Local aJson := {}
Local aSubJson := {}

default cTitulo   := ""
default cProcesso := ""
default lEdit     := .F.
default cHtml     := ""

      cHtml :=  getHtmlCss(cHtml)
	   cHtmlHist := cHtml
      aEmail := getEmail(cTitulo)
      Aadd(aJson,JsonObject():new())
      aJson[1]['title'] := cTitulo + ' - ' +  rtrim(cProcesso)
      aJson[1]['edit']  := lEdit 
      aJson[1]['html']  := cHtml
      aJson[1]['bodyEmail']  := aEmail[5][4]
      aJson[1]['pdf64'] := GravaHtmlTmp(cHtml)
      aJson[1]['marginSuperior'] := nTop
      aJson[1]['marginInferior'] := nBottom
      aJson[1]['marginDireita'] := nRight   
      aJson[1]['marginEsquerda'] := nLeft
      aJson[1]['tipoPagina'] := cPageP
      aJson[1]['tipoMargem'] := cMargin

      aDel(aEmail, 5)
      aSize(aEmail, Len(aEmail)-1)

      for i:= 1 to len(aEmail)
          Aadd(aSubJson,JsonObject():new())
          aSubJson[i]['property']      := aEmail[i][1]
          aSubJson[i]['label'   ]      := aEmail[i][2]
          aSubJson[i]['type']          := aEmail[i][3]
          aSubJson[i]['order']         := i
          aSubJson[i]['gridColumns']   := 12
          aSubJson[i]['gridSmColumns'] := 12 
          aSubJson[i]['value']         := aEmail[i][4]  
          aSubJson[i]['required']      := aEmail[i][5]          
          aSubJson[i]['pattern']       := aEmail[i][6]   
          aSubJson[i]['errorMessage']  := aEmail[i][7]   
          aSubJson[i]["icon"]          := aEmail[i][8]   
      next
 
      aJson[Len(aJson)]['listFields'] := aSubJson     
      oJson := JsonObject():new()
      oJson:set(aJson[1]) 

return oJson 

/*
Função getEmail
Objetivo: Prepara as informações de envio do email para enviar ao POUI
Parâmetros: não tem
Author : Maurício Frison
Data   : 25/02/2021            
*/
Static Function getEmail(cTitulo)
Local aEmail := {}
PRIVATE cFrom
PRIVATE cTo
PRIVATE cCC := ""
PRIVATE cSubject := ""
PRIVATE cBody := "Segue em anexo "+Capital(cTitulo)

      getVarsToEmail(cTitulo)
      aAdd(aEmail,{'Remetente', 'Remetente','string',cFrom,.t.,    "[a-zA-Z0-9.-_]{1,}@[a-zA-Z.-]{2,}[.]{1}[a-zA-Z]{2,}","Campo Obrigatório no formato de Email! É preciso conter @","po-icon-mail"  }) 
      aAdd(aEmail,{'Destinatario', 'Destinatario','string',cTo,.t.,"[a-zA-Z0-9.-_]{1,}@[a-zA-Z.-]{2,}[.]{1}[a-zA-Z]{2,}","Campo Obrigatório no formato de Email! É preciso conter @","po-icon-mail"})
      aAdd(aEmail,{'Copia', 'Copia','string',cCC,.f.,              "[a-zA-Z0-9.-_]{1,}@[a-zA-Z.-]{2,}[.]{1}[a-zA-Z]{2,}","","po-icon-mail"  })
      aAdd(aEmail,{'Assunto', 'Assunto','string',cSubject,.t.,"","Campo obrigatório",""  })
      aAdd(aEmail,{'Corpo', 'Corpo','string',cBody,.t.,"","Campo obrigatório",""})             
Return aEmail

/*
Função getVarsToEmail
Objetivo: Prepara as variáveis de envio do email respeitando os parâmetros, pontos de entrada e etc.
Parâmetros: não tem
Author : Maurício Frison
Data   : 25/02/2021            
*/
Static Function getVarsToEmail(cTitulo)
Local aUsuario := {}
Private cTitAux
Private cSubjectAux
Private cBodyAux
Private cToAux
Private lEmailAux  
PRIVATE cCCAux


PswOrder(1)
PswSeek(__CUSERID,.T.)
aUsuario:= PswRet()

cSubject := cTitulo

cFrom       := EasyGParam("MV_RELFROM",,"") //variável já declarada como private em outro lugar
if empty(cFrom)
   cFrom:= Alltrim(aUsuario[1,14])
endif

If EasyEntryPoint("AVCRW")  //ASK - 19/04/2007
   cTitAux := cTitulo
   cSubjectAux := cSubject
   cBodyAux := cBody
   cToAux := cTo
   cCCAux := ""
   lEmailAux := lEmail

   If ExecBlock("AVCRW",.F.,.F.,{"EMAIL",aParam})   
      cTitulo  := cTitAux
      cSubject := cSubjectAux
      cBody    := cBodyAux
      cTo      := cToAux  
      cCC      := cCCAux  
      lEmail   := lEmailAux 
   Else
      cCC  := cFrom
   EndIf
EndIf
If EasyEntryPoint("AVCRW")
   ExecBlock("AVCRW",.F.,.F.,{"AVEMAIL_CFROM"})
EndIf   
IF ! AllTrim(aUsuario[1,14]) $ cCC
      if empty(cCc)
         cCC := AllTrim(aUsuario[1,14])
      else
         cCC += ";" + AllTrim(aUsuario[1,14])
      ENDIF
   ENDIF   
return


*------------------------------------------------------------------------*
* FIM DO PROGRAMA EECAA100.PRW                                           *
*------------------------------------------------------------------------*
