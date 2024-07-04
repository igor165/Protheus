#INCLUDE "EECRI100.ch"
//------------------------------------------------------------------------------------//
//Empresa...: AVERAGE TECNOLOGIA
//Funcao....: EECRI100()
//Sintaxe...: #EECRI100
//Autor.....: Alex Wallauer (AWR)
//Data......: 26 de Setembro de 2005, 09:00
//Uso.......: SIGAEEC             
//Versao....: Protheus Brasil
//Descricao.: Integracao com o RIEX da Receita Federal
//WEB.......: https://www.fazenda.sp.gov.br/registroexportacaoteste/UsoGeral/Login.aspx
//Usuário...: 26943137875
//Senha.....: avg315
//Documentos: I:\EXP\Cristiano\Comércio Exterior\RIEX
//------------------------------------------------------------------------------------//
#INCLUDE "EEC.cH"
#INCLUDE "TOPCONN.CH"
*-----------------------------------------*
FUNCTION EECRI100()//Envio do RIEX
*-----------------------------------------*
PRIVATE cTitilo:=STR0001 //"Selecao de envio do RIEX"
PRIVATE aTipo  := {STR0002,STR0003,STR0004} //"1-Ambos"###"2-Nao enviados"###"3-Rejeitados"
PRIVATE cTipo  := aTipo[1]

RETURN EECRI103(.T.)

*-----------------------------------------*
FUNCTION EECRI101()//Acompanhamento do RIEX
*-----------------------------------------*
PRIVATE cTitilo:=STR0005 //"Acompanhamento dos envios do RIEX"
PRIVATE aTipo  := {STR0006,STR0007,STR0004,STR0008} //"1-Todos"###"2-Enviados"###"3-Rejeitados"###"3-Aceitos"
PRIVATE cTipo  := aTipo[2]

RETURN EECRI103(.F.)

*-----------------------------------------*
FUNCTION EECRI103(lEnvio)
*-----------------------------------------*
LOCAL cCampo:=""
SX3->(DBSETORDER(2))
IF(!SX3->(DBSEEK("EEM_RIEXST")),cCampo+=" EEM_RIEXST",) 
IF(!SX3->(DBSEEK("YA_CODRIEX")),cCampo+=" YA_CODRIEX",) 
IF(!SX3->(DBSEEK("AH_CODRIEX")),cCampo+=" AH_CODRIEX",) 
SX3->(DBSETORDER(1))

IF !EMPTY(cCampo)
   MSGINFO(STR0009+cCampo+ENTER+; //"Nao existe no dicionario os campos: "
           STR0010) //"Integracao com RIEX nao pode ser efetuada."
   RETURN .F.
ENDIF

DBSELECTAREA("EES")
IF SELECT("EES") = 0 .OR. !EES->(dbSeek(xFilial("EES")))
   MSGINFO(STR0011+; //"Nao existe itens de notas fiscais, "
           STR0010) //"integracao com RIEX nao pode ser efetuada."
   RETURN .F.
ENDIF

PRIVATE cEmbarque:= SPACE(LEN(EES->EES_PREEMB))
PRIVATE cNota    := SPACE(LEN(EES->EES_NRNF))
PRIVATE cImp     := SPACE(LEN(EEC->EEC_IMPORT))
PRIVATE cImpLoja := SPACE(LEN(EEC->EEC_IMLOJA))
PRIVATE dDtIni   := CTOD("")
PRIVATE dDtFim   := dDataBase
PRIVATE nColFim  := 390 //350       //*** GFP 05/08/2011 - Alteração de tamanho de janela - M11.5
PRIVATE nLinFim  := 250
PRIVATE bOK      := {|| IF(RIValida(), (nOpca:=1, oDlg:End()),) }
PRIVATE bCancel  := {|| nOpca:=0, oDlg:End() }
PRIVATE cFile    := ""

Do While .T.   

   nOpca:=0

   If(EasyEntryPoint("EECRI100"),ExecBlock("EECRI100",.F.,.F.,"ANTES_TELA"),)
   oMainWnd:ReadClientCoords()
   Define MsDialog oDlg Title cTitilo ;
          From 000,oMainWnd:nLeft To nLinFim+46,nColFim Of oMainWnd Pixel
           
           oPanel:= TPanel():New(0, 0, "", oDLG,, .F., .F.,,, 90, 165) //MCF - 11/09/2015
           oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
           
           nLinGet  := 20             
           nPula    := 15
           nColGet1 := 10
           nColGet2 := 60
           
           @ nLinGet,nColGet1 Say STR0012     Size 45,11 Pixel OF oPanel  //"Embarque"
           @ nLinGet,nColGet2 MsGet cEmbarque Size 75,08 F3 "EEC" Pixel OF oPanel
           nLinGet += nPula

           // IF lEnvio // FJH 04/10/05 Mostrar NF também no Acompanhamento.
           @ nLinGet,nColGet1 Say STR0013  Size 45,11 Pixel OF oPanel  //"No. Nota Fiscal"
           @ nLinGet,nColGet2 MsGet cNota  Size 75,08 Pixel OF oPanel WHEN !EMPTY(cEmbarque)
           nLinGet += nPula
           // ENDIF

           @ nLinGet,nColGet1 Say STR0014    Size 45,11 Pixel OF oPanel //"Status" 
           @ nLinGet,nColGet2 ComboBox cTipo Items aTipo Size 75,8 Pixel OF oPanel WHEN EMPTY(cNota)
           nLinGet += nPula
                                                                 
           @ nLinGet,nColGet1    Say STR0015    Size 45,11 Pixel OF oPanel //"Importador"
           @ nLinGet,nColGet2    MsGet cImp     Size 56,08 Pixel OF oPanel WHEN RIWhenImp() F3 "SA1"
           @ nLinGet,nColGet2+58 MsGet cImpLoja Size 10,08 Pixel OF oPanel WHEN RIWhenImp()
           nLinGet += nPula

           @ nLinGet,nColGet1 Say STR0016  Size 45,11 Pixel OF oPanel //"Data Inicial"
           @ nLinGet,nColGet2 MSGet dDtIni Size 56,08 Pixel OF oPanel WHEN EMPTY(cNota)
           nLinGet += nPula
           
           @ nLinGet,nColGet1 Say STR0017  Size 45,11 Pixel OF oPanel //"Data Final"
           @ nLinGet,nColGet2 MSGet dDtFim Size 56,08 Pixel OF oPanel WHEN EMPTY(cNota)
           nLinGet += nPula

          If(EasyEntryPoint("EECRI100"),ExecBlock("EECRI100",.F.,.F.,"TELA_SELECAO"),)
             
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

   If nOpca=0           
      Exit
   EndIf

   lSair:=RITelaMarca(lEnvio)

   If lSair
      Exit
   EndIf

EndDo

If Select("TRB") > 0
   TRB->(E_EraseArq(cFile))
EndIf

RETURN .T.

/*
Funcao      : RIWhenImp()
Parametros  : 
Retorno     : .T./.F.
Objetivos   : Retornar o When do importador e preenchê-lo quando o embarque estiver preenchido
Autor       : Fabio Hildebrand - FJH
Data/Hora   : 04/10/05 16:15
*/
*-----------------------------------------*
FUNCTION RIWhenImp()
*-----------------------------------------*
Local aOrd:=SaveOrd("EEC")
   If !EMPTY(cEmbarque)
      EEC->(DbSetOrder(1))
      EEC->(DbSeek(xFilial("EEC")+cEmbarque))
      cImp := EEC->EEC_IMPORT
      cImpLoja := EEC->EEC_IMLOJA
   Endif
RestOrd(aOrd)
Return (EMPTY(cNota) .AND. EMPTY(cEmbarque))

*-----------------------------------------*
FUNCTION RIValida()
*-----------------------------------------*
EEC->(DBSETORDER(1))
IF !EMPTY(cEmbarque) .AND. !EEC->(DBSEEK(xFilial()+cEmbarque))
   MSGSTOP(STR0018) //"Embarque nao encontrado."
   RETURN .F.
ENDIF

IF !EMPTY(cEmbarque)
   cImp     := SPACE(LEN(EEC->EEC_IMPORT))
   cImpLoja := SPACE(LEN(EEC->EEC_IMLOJA))
ENDIF

IF !EMPTY(cNota)
   cTipo:=aTipo[1]//Todos
ENDIF

SA1->(DBSETORDER(1))
IF !EMPTY(cImp+cImpLoja) .AND. !SA1->(DBSEEK(xFilial()+cImp+if(empty(cImpLoja),"",cImpLoja))) // FJH 04/10/05 Não procura pela loja se não estiver preenchida.
   MSGSTOP(STR0019) //"Importador nao encontrado."
   RETURN .F.
ENDIF

IF !E_Periodo_OK(dDtIni,dDtFim)
   RETURN .F.
ENDIF

RETURN .T.

*-----------------------------------------*
FUNCTION RITelaMarca(lPEnvio)
*-----------------------------------------*
Local aButtons //LRS -27/11/2017
PRIVATE lTemItens:=.F.
PRIVATE lEnvio := lPEnvio

Processa( {|| lTemItens:=RICriaTRB() } , STR0020 ) //"Lendo dados..."

IF !lTemItens
   MSGSTOP(STR0021) //"Nao existe NF's para essa selecao."
   RETURN .F.
ENDIF

PRIVATE bOk2      := {|| nOpca:=2, oDlg2:End() }
PRIVATE bCancel2  := {|| nOpca:=0, oDlg2:End() }
PRIVATE bMarca    := {|| If(!Empty(TRB->WKMARCA),TRB->WKMARCA:="",TRB->WKMARCA:=cMarca),oMark:oBrowse:Refresh() }
PRIVATE bTodos    := {|B|P:=B,Processa( {|| RIMarcaTodos(P) } , STR0022 ) } //"Des/Marcando Todos"
PRIVATE bGrava    := {|| IF(MSGYESNO(STR0023), (Processa({|| RIEX_Grava()},STR0024),nOpca:=0,oDlg2:End()),) } //"Confirma gravacao?"###"Gravando Status..."
PRIVATE nLinha    := 17
PRIVATE cMarca    := GetMark()
PRIVATE aTb_Campos:= {}
Private lExcel := .F.       //acb - 30/08/2010

Aadd(aTb_Campos,{"WKMARCA"  ,,""})
Aadd(aTb_Campos,{{|| RIEX_Status(TRB->EEM_RIEXST) },,AVSX3("EEM_RIEXST",5)})
Aadd(aTb_Campos,{"EEM_PREEMB",,AVSX3("EEM_PREEMB",5)})
Aadd(aTb_Campos,{"EEM_NRNF"  ,,AVSX3("EEM_NRNF"  ,5)})
Aadd(aTb_Campos,{{|| Transform(TRB->EEM_SERIE, AvSx3("EEM_SERIE", AV_PICTURE)) } ,,AVSX3("EEM_SERIE" ,5)}) //Aadd(aTb_Campos,{"EEM_SERIE" ,,AVSX3("EEM_SERIE" ,5)}) //RMD - 24/02/15 - Projeto Chave NF
Aadd(aTb_Campos,{"EEM_DTNF"  ,,AVSX3("EEM_DTNF"  ,5)})
Aadd(aTb_Campos,{"WKIMP"     ,,AVSX3("EEC_IMPORT",5)})
Aadd(aTb_Campos,{"WKLOJA"    ,,AVSX3("EEC_IMLOJA",5)})
Aadd(aTb_Campos,{"WKNOMEIMP" ,,AVSX3("EEC_IMPODE",5)})
Aadd(aTb_Campos,{"EEM_VLNF"  ,,AVSX3("EEM_VLNF"  ,5)})//ACB - 18/08/2010 

aButtons:={}//LRS - 27/11/2017

aAdd(aButtons, {"MARDESM", {|| (Eval(bTodos,"T")) }, STR0027}) //LRS - 27/11/2017
IF !lEnvio
   aAdd(aButtons, {"ACEITO", {|| (Eval(bTodos,"A")) }, STR0028})//LRS - 27/11/2017
   aAdd(aButtons, {"REJEIT", {|| (Eval(bTodos,"R")) }, STR0029})//LRS - 27/11/2017
ENDIF

If(EasyEntryPoint("EECRI100"),ExecBlock("EECRI100",.F.,.F.,STR0025),) //"ANTES_TELA_MARCA"

DO While .T.
   
   nOpca:=1
   
   TRB->(dbGoTop())

   Define MsDialog oDlg2 Title STR0026 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

     oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
     oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

     IF !lEnvio
        bOk2:=bGrava
     ENDIF

     If(EasyEntryPoint("EECRI100"),ExecBlock("EECRI100",.F.,.F.,"TELA_MARCA"),)

     oMark := MsSelect():New("TRB","WKMARCA",,aTb_Campos,.F.,@cMarca,PosDLG(oDlg2))
     oMark:bAval := bMarca
      
   Activate MsDialog oDlg2 On Init EnchoiceBar(oDlg2,bOk2,bCancel2,,aButtons) //LRS - 27/11/2017

   If nOpca=0           
      RETURN .F. 
   ELSEIf nOpca=1
      RETURN .T. 
   EndIf

//   cPath:=cFileXML:="" //ACB
   cPath:=cFileXML:=cFileCSV:=""
   IF RIGetPath()
      LOOP
   ENDIF

   Processa( {|| lTemItens:=RIEX_Envio() } , STR0030 ) //"Criando arquivo de envio..."

   IF !lTemItens
      LOOP
   ENDIF

   EXIT

ENDDO

RETURN .F.

*-----------------------------------------*
FUNCTION RIEX_Status(cStatus)
*-----------------------------------------*
LOCAL cDescricao:=STR0031 //"Nao enviado"
IF cStatus = "A"
   cDescricao:=STR0032 //"Aceito     "
ELSEIF cStatus = "R"
   cDescricao:=STR0033 //"Rejeitado  "
ELSEIF cStatus = "E"
   cDescricao:=STR0034 //"Enviado    "
ENDIF
RETURN cDescricao

*-----------------------------------------*
FUNCTION RICriaTRB()
*-----------------------------------------*
LOCAL cFilEEC := xFilial("EEC")
LOCAL cFilEEM := xFilial("EEM")

LOCAL cQuery:= ""
PRIVATE cCond1:= "" // TDF - 26/07/10 - Variável utilizada em ponto de entrada

If Select("TRB") = 0
   aHeader := {}
   aCampos := Array(EEM->(FCount()))
   aSemSX3 := {}
   Aadd(aSemSX3,{"WKMARCA"   ,"C",02,0})
   Aadd(aSemSX3,{"WKIMP"     ,"C",LEN(EEC->EEC_IMPORT),0})
   Aadd(aSemSX3,{"WKLOJA"    ,"C",LEN(EEC->EEC_IMLOJA),0})
   Aadd(aSemSX3,{"WKNOMEIMP" ,"C",LEN(SA1->A1_NOME)   ,0})
   Aadd(aSemSX3,{"WKRECNOEEM","N",08,0})
   Aadd(aSemSX3,{"WK_ALTEROU","L",01,0})

   //TRP - 29/01/07 - Campos do WalkThru
   AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
   AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
   
   If(EasyEntryPoint("EECRI100"),ExecBlock("EECRI100",.F.,.F.,"CRIA_TRB"),)

   cFile := E_CriaTrab("EEM",aSemSX3,"TRB")
   If !Used()
      Help(" ",1,"E_NAOHAREA")
      RETURN .F.
   EndIf
   IF lEnvio
      IndRegua("TRB",cFile+TEOrdBagExt(),"EEM_RIEXST+EEM_PREEMB+EEM_NRNF")
   ELSE
      IndRegua("TRB",cFile+TEOrdBagExt(),"EEM_PREEMB+EEM_NRNF")
   ENDIF

ELSE
   DBSelectaREA("TRB")
   AvZap()
ENDIF

If(EasyEntryPoint("EECRI100"),ExecBlock("EECRI100",.F.,.F.,"CRIA_INDICE_TRB"),)

//**TRP - 20/07/2010 - Tratamento para Envio do Riex via Query.
#IFDEF TOP

   IF Select("WK_RIEX") > 0
      WK_RIEX->(dbCloseArea())
   Endif
   
   If lEnvio
      If !Empty(cNota)
         cCond1 := " EEM.EEM_NRNF = '"+cNota+"'"
      Else 
         IF cTipo = aTipo[1] //Todos
            cCond1:= " EEM.EEM_RIEXST <> 'A'"
         ELSEIF cTipo = aTipo[2] //Nao enviados
            cCond1:= " EEM.EEM_RIEXST = ''"
         ELSEIF cTipo = aTipo[3] //Rejeitados
            cCond1:= " EEM.EEM_RIEXST = 'R'"
         ENDIF
      Endif
   Else
      If !Empty(cNota)
         cCond1 := " EEM.EEM_NRNF = '"+cNota+"'"
      Else 
         IF cTipo = aTipo[1] //Todos
            cCond1:=" EEM.EEM_RIEXST <> ''"
         ELSEIF cTipo = aTipo[2] //Nao enviados
            cCond1:=" EEM.EEM_RIEXST <> '' AND EEM.EEM_RIEXST NOT IN ('R','A')"   
         ELSEIF cTipo = aTipo[3] //Rejeitados
            cCond1:=" EEM.EEM_RIEXST <> '' AND EEM.EEM_RIEXST NOT IN ('E','A')"  
         ELSEIF cTipo = aTipo[4] //Aceitos
            cCond1:=" EEM.EEM_RIEXST <> '' AND EEM.EEM_RIEXST NOT IN ('E','R')"   
         ENDIF
      Endif
   Endif
   
   cQuery := "Select EEM.*, EEC.EEC_IMPORT, EEC.EEC_IMLOJA, EEC.EEC_IMPODE from "+RetSqlName("EEM")+" EEM JOIN "+RetSqlName("EEC") + " EEC" 
   cQuery += " ON EEM.EEM_FILIAL = EEC.EEC_FILIAL AND EEM.EEM_PREEMB = EEC.EEC_PREEMB"
   cQuery += " where EEM_FILIAL = '"+xFilial("EEM")+"'"
   cQuery += " AND "+IIF(TcSrvType()<>"AS/400","EEM.D_E_L_E_T_<>'*'","EEM.@DELETED@<>'*'") 
   cQuery += " AND "+IIF(TcSrvType()<>"AS/400","EEC.D_E_L_E_T_<>'*'","EEC.@DELETED@<>'*'") 
   If !Empty(dDtIni)
      cQuery += " AND EEM.EEM_DTNF >= '"+DTOS(dDtIni)+"'" 
   Endif
   If !Empty(dDtFim)
      cQuery += " AND EEM.EEM_DTNF <= '"+DTOS(dDtFim)+"'"
   Endif
   If !Empty(cEmbarque)
      cQuery += " AND EEM.EEM_PREEMB = '"+cEmbarque+"'" 
   Endif
   If !Empty(cImp)
      cQuery += " AND EEC.EEC_IMPORT = '"+cImp+"'" 
      cQuery += " AND EEC.EEC_IMLOJA = '"+cImpLoja+"'"    
   Endif
   
   cQuery += " AND EEM.EEM_TIPONF = '1'"
   
   // TDF - 26/07/10 - Ponto de entrada para alterar condição da query, utilizando a variável cCond1
   If(EasyEntryPoint("EECRI100"),ExecBlock("EECRI100",.F.,.F.,"QRY_CONDICAO"),)
   
   cQuery += " AND "+cCond1 
    
   cQuery := changeQuery(cQuery)        
   
   TcQuery cQuery ALIAS "WK_RIEX" NEW

   TCSetField( "WK_RIEX", "EEM_DTNF", "D", 8, 0 )
                                                                                          
   Do While !WK_RIEX->(EOF())
      
      ProcRegua(15)
      
      lLOOP:=.F.
      If(EasyEntryPoint("EECRI100"),ExecBlock("EECRI100",.F.,.F.,"LOOP_WK_RIEX"),)
      IF lLOOP
         WK_RIEX->(DBSKIP())
         LOOP
      ENDIF
      
      TRB->(DBAPPEND())
      AVREPLACE("WK_RIEX","TRB")
      TRB->WKRECNOEEM:= WK_RIEX->R_E_C_N_O_ // TDF - 26/07/10 
      TRB->WKIMP     := WK_RIEX->EEC_IMPORT
      TRB->WKLOJA    := WK_RIEX->EEC_IMLOJA
      TRB->WKNOMEIMP := WK_RIEX->EEC_IMPODE
      TRB->TRB_ALI_WT:= "EEM"
      TRB->TRB_REC_WT:= WK_RIEX->R_E_C_N_O_ // TDF - 26/07/10
      If(EasyEntryPoint("EECRI100"),ExecBlock("EECRI100",.F.,.F.,"GRAVA_TRB"),)
   
      WK_RIEX->(DbSkip())
   
   Enddo
//**TRP - 20/07/2010

#ELSE

   ProcRegua(15)
   nCont:=0
   EEC->( DBSETORDER(1) )
   EEM->( DBSETORDER(1) )//EEM_FILIAL+EEM_PREEMB+EEM_TIPOCA+EEM_NRNF+EEM_TIPONF
   EEM->( DBSEEK(cFilEEM) )
   IF !EMPTY(cEmbarque)
     EEM->( DBSEEK(cFilEEM+cEmbarque) )
   ENDIF


   DO WHILE EEM->(!EOF()) .AND. cFilEEM == EEM->EEM_FILIAL

      IF nCont > 15
         nCont:=0
         ProcRegua(15)
      ELSE
         nCont++
         IncProc(STR0035+ALLTRIM(EEM->EEM_NRNF)) //"Lendo Nota: "
      ENDIF

      IF EEM->EEM_TIPONF # "1"
         EEM->(DBSKIP())
         LOOP
      ENDIF

      IF !EMPTY(cEmbarque)
         IF RTRIM(cEmbarque) # RTRIM(EEM->EEM_PREEMB)
            EXIT
         ENDIF
      ENDIF

      IF lEnvio

         IF !EMPTY(cNota)
            IF RTRIM(cNota) # RTRIM(EEM->EEM_NRNF)
               EEM->(DBSKIP())
               LOOP
            ENDIF
         ELSE
            IF cTipo = aTipo[1]//Todos
               //IF !EMPTY(EEM->EEM_RIEXST) .AND. EEM->EEM_RIEXST $ "A,E"//Aceitos e Enviados - Nopado por WFS em 21/08/09
               //WFS 21/08/09 - Condição alterada para permitir "reenvio", considerando que o arquivo gerado
               //anteriormente pode não ter sido enviado e perdido.
               If !Empty(EEM->EEM_RIEXST) .And. EEM->EEM_RIEXST == "A" //Aceitos
                  EEM->(DBSKIP())
                  LOOP
               ENDIF
            ELSEIF cTipo = aTipo[2]//Nao enviados"
               IF !EMPTY(EEM->EEM_RIEXST)//Aceitos, Rejeitados e Enviados
                  EEM->(DBSKIP())
                  LOOP
               ENDIF
            ELSEIF cTipo = aTipo[3]//Rejeitados
               IF EEM->EEM_RIEXST # "R"//Rejeitado
                  EEM->(DBSKIP())
                  LOOP
               ENDIF
            ENDIF
         ENDIF

      ELSE
       
         IF !EMPTY(cNota) // FJH 04/10/05 Adição da NF na tela de Acompanhamento.
            IF RTRIM(cNota) # RTRIM(EEM->EEM_NRNF)
               EEM->(DBSKIP())
               LOOP
            ENDIF
         ELSE
            IF cTipo = aTipo[1]//Todos
               IF EMPTY(EEM->EEM_RIEXST)//Nao enviados"
                  EEM->(DBSKIP())
                  LOOP
               ENDIF
            ELSEIF cTipo = aTipo[2]//Enviados"
               IF EMPTY(EEM->EEM_RIEXST) .OR. EEM->EEM_RIEXST $ "R,A"//Rejeitados e Aceitos
                  EEM->(DBSKIP())
                  LOOP
               ENDIF
            ELSEIF cTipo = aTipo[3]//Rejeitados
               IF EMPTY(EEM->EEM_RIEXST) .OR. EEM->EEM_RIEXST $ "E,A"//Enviados e Aceitos
                  EEM->(DBSKIP())
                  LOOP
               ENDIF
            ELSEIF cTipo = aTipo[4]//Aceitos
               IF EMPTY(EEM->EEM_RIEXST) .OR. EEM->EEM_RIEXST $ "E,R"//Enviados e Rejeitados
                  EEM->(DBSKIP())
                  LOOP
               ENDIF
            ENDIF
         Endif
      ENDIF
   
      IF !EMPTY(dDtIni)
         IF EEM->EEM_DTNF < dDtIni
            EEM->(DBSKIP())
            LOOP
         ENDIF
      ENDIF

      IF !EMPTY(dDtFim)
         IF EEM->EEM_DTNF > dDtFim
            EEM->(DBSKIP())
            LOOP
         ENDIF
      ENDIF

      IF EEC->( DBSEEK(cFilEEC+EEM->EEM_PREEMB) )// FJH 04/10/05 Não precisa da loja para achar importador
         IF !EMPTY(cImp)
            IF RTRIM(cImp) # RTRIM(EEC->EEC_IMPORT) .OR. if(empty(cImpLoja),.F.,RTRIM(cImpLoja) # RTRIM(EEC->EEC_IMLOJA)) // FJH 04/10/05
               EEM->(DBSKIP())
               LOOP
            ENDIF
         ENDIF
      ELSE
         EEM->(DBSKIP())
         LOOP
      ENDIF

      lLOOP:=.F.
      If(EasyEntryPoint("EECRI100"),ExecBlock("EECRI100",.F.,.F.,"LOOP_TRB"),)
      IF lLOOP
         EEM->(DBSKIP())
         LOOP
      ENDIF

      TRB->(DBAPPEND())
      AVREPLACE("EEM","TRB")
      TRB->WKRECNOEEM:=EEM->(RECNO())
      TRB->WKIMP     :=EEC->EEC_IMPORT
      TRB->WKLOJA    :=EEC->EEC_IMLOJA
      TRB->WKNOMEIMP :=EEC->EEC_IMPODE
      TRB->TRB_ALI_WT:= "EEM"
      TRB->TRB_REC_WT:= EEM->(Recno())
      If(EasyEntryPoint("EECRI100"),ExecBlock("EECRI100",.F.,.F.,"GRAVA_TRB"),)

      EEM->(DBSKIP())

   ENDDO

#ENDIF

RETURN !(TRB->(EOF()) .AND. TRB->(BOF()))

*-----------------------------------------*
FUNCTION RIMarcaTodos(cExecuta)
*-----------------------------------------*
LOCAL cMarcaNew:=If(!Empty(TRB->WKMARCA),"",cMarca)
ProcRegua(TRB->(LASTREC()))

TRB->(DBGOTOP())
DO WHILE TRB->(!EOF())
   IncProc(STR0035+ALLTRIM(TRB->EEM_NRNF)) //"Lendo Nota: "

   IF cExecuta # "T" 
      IF !EMPTY(TRB->WKMARCA)
         IF cExecuta = "A"
            TRB->EEM_RIEXST:="A"
         ELSEIF cExecuta = "R"
            TRB->EEM_RIEXST:="R"
         ENDIF
         TRB->WK_ALTEROU:=.T.
      ENDIF
      cMarcaNew:=""
   ENDIF
   
   TRB->WKMARCA:=cMarcaNew
   TRB->(DBSKIP())
ENDDO
TRB->(DBGOTOP())

RETURN .T.

/* Revisão: WFS em 10/05/2010
   A informações quantidade e valor são referente à exportação.
   Alterado o tratamento visando atender as especificações do Guia 0.9 Riex. */

*-----------------------------------------*
FUNCTION RIEX_Envio()
*-----------------------------------------*
LOCAL cFilEE9 := xFilial("EE9"),RE,PA,UM
LOCAL cFilEEC := xFilial("EEC")
LOCAL cFilEES := xFilial("EES")
LOCAL cFilSA2 := xFilial("SA2")
LOCAL cFilSAH := xFilial("SAH")
LOCAL cFilSYA := xFilial("SYA")
LOCAL cFilEE2 := xFilial("EE2")
LOCAL lTemItens:= .F.
Local l7501 := .F.
Local nInc := 0, nPos := 0
Local aAuxNfEnt := {}
Local cCNPJEnt := "", cNCMEnt := ""
Local nQuant:= 0,;
      nValor:= 0 

PRIVATE cXML:= '<?xml version="1.0" encoding="ISO-8859-1"?>' +ENTER
PRIVATE cREXML:=cITEMXML:=cErroALL:=cErro:=""
PRIVATE lTemDSE:=SX2->(DBSEEK("EXL")) .AND. EXL->(FIELDPOS("EXL_DSE")) # 0
//Acb - 31/08/2010
PRIVATE cRECSV:= "",cITEMCSV := "",cDadosCsv:= ""

Private aNfEnt := {}
Private lNota7501 := .F.
Private cPais
ProcRegua(TRB->(LASTREC()))

nArq:=EasyCreateFile(cFileXML)

IF fError() <> 0
   MsgInfo(STR0036,STR0037) //"Erro na criacao do arquivo XML."###"Erro!"
   RETURN .F.
ENDIF 

//acb - 31/08/2010
If lExcel
   nArq2:=EasyCreateFile(cFileCSV)

   IF fError() <> 0
      MsgInfo("Erro na criacao do arquivo CSV.", STR0037) //"Erro!"
      RETURN .F.
   ENDIF    
EndIf


cXML+= "<RegistroExportacao>"+ENTER

EE9->(dbSetOrder(2))//EE9_FILIAL+EE9_PREEMB+EE9_PEDIDO+EE9_SEQUEN
EEC->(DBSETORDER(1))
EES->(dbSetOrder(1))//EES_FILIAL+EES_PREEMB+EES_NRNF
SAH->(DBSETORDER(1))
SYA->(DBSETORDER(1))
SX2->(DBSETORDER(1))
TRB->(DBGOTOP())
aPaises:={}
aUnidad:={}
DO WHILE TRB->(!EOF())

   IncProc(STR0035+ALLTRIM(TRB->EEM_NRNF)) //"Lendo Nota: "

   IF EMPTY(TRB->WKMARCA)
      TRB->(DBSKIP())
      LOOP
   ENDIF

   EEM->(DBGOTO(TRB->WKRECNOEEM))
   lTemREembranco:=.F.
   aREs     := {}
   aNfEnt   := {}
   nPesLiq  := 0
   lTemItens:= .T.
   l7501    := .F.

   //cProc    :=EEM->EEM_PREEMB+" "+LEFT(EEM->EEM_NRNF,11)+" "+EEM->EEM_SERIE+" "+DTOC(EEM->EEM_DTNF) //RMD - 24/02/15 - Projeto Chave NF
   cProc    :=EEM->EEM_PREEMB+" "+LEFT(EEM->EEM_NRNF,11)+" "+Transform(EEM->EEM_SERIE, AvSx3("EEM_SERIE", AV_PICTURE))+" "+DTOC(EEM->EEM_DTNF)
   
   EEC->(DBSeek(cFilEEC + EEM->EEM_PREEMB))
   
   //////////////////////////////////////////////////////////////////////////////////////////////
   //ER - 28/10/2008 - 15:00.                                                                  //
   //O sistema do RIEX valida Notas Fiscais com mais de 6 caracteres, porém o sistema padrão do//
   //Easy permite a utilização de 9 casas para Nota Fiscal (referente a rotina de Nota Fiscal  //
   //Eletronica). Nesse caso o num. da Nota será concatenado em 6 caracteres, desde que o seus //
   //primeiros dígitos sejam iguais a zero.                                                    //
   //////////////////////////////////////////////////////////////////////////////////////////////
   If Len(AllTrim(EEM->EEM_NRNF)) > 9
      cErro+=cProc+STR0061+EEM->EEM_NRNF+ENTER  //" Nota fiscal com mais de 6 caracteres: "
   Else
      If Len(AllTrim(EEM->EEM_NRNF)) == 9

         If Left(AllTrim(EEM->EEM_NRNF),3) <> "000"
            cErro+=cProc+STR0061+EEM->EEM_NRNF+ENTER  //" Nota fiscal com mais de 6 caracteres: "
         EndIf
         
      ElseIf Len(AllTrim(EEM->EEM_NRNF)) == 8

         If Left(AllTrim(EEM->EEM_NRNF),2) <> "00"
            cErro+=cProc+STR0061+EEM->EEM_NRNF+ENTER  //" Nota fiscal com mais de 6 caracteres: "
         EndIf
         
      ElseIf Len(AllTrim(EEM->EEM_NRNF)) == 7
        
         If Left(AllTrim(EEM->EEM_NRNF),1) <> "0"
            cErro+=cProc+STR0061+EEM->EEM_NRNF+ENTER  //" Nota fiscal com mais de 6 caracteres: "
         EndIf
  
      EndIf 
         
   EndIf
   
   //If EEM->(FieldPos("EEM_CF")) <> 0 .and. EEM->(Left(EEM_CF, 1) <> "7" .or. RTrim(EEM_CF) == "7501")
   //   cErro += cProc + STR0065+RTrim(EEM->EEM_CF)+STR0066+ENTER //" CFOP (Código Fiscal Operacional) "###" não permitido. NF's com o CFOP igual a 7501 ou prefixo diferente de 7 não serão aceitas no envio para o RIEX."
   //EndIf

   /* WFS 06/05/2010
      Os produtos, a quantidade e o valor informados devem ser os efetivamentes exportados,
      conforme guia 0.9 Riex. Devem ser informadas as notas fiscais de entrada para cada item
      quando tratar-se de notas fiscais com fim específico de exportação. */
    
   ////////////////////////////////////////////////////////////////////////
   //Inicia Tratamento padrão de verificação de Notas Fiscais de Entrada.//
   ////////////////////////////////////////////////////////////////////////
   If EasyGParam("MV_AVG0174",.F.,.F.) .and. EasyGParam("MV_EECFAT",.F.,.F.)
      

      //WFS 06/05/2010
      //Apenas os itens da nota fiscal com fim específico de exportação
      
      EE9->(DBSeek(xFilial() + AvKey(EEM->EEM_PREEMB,"EE9_PREEMB")))

      While EE9->(!Eof()) .And.;
            EE9->EE9_FILIAL == EE9->(xFilial()) .And.;
            EE9->EE9_PREEMB == AvKey(EEM->EEM_PREEMB,"EE9_PREEMB")

         If EE9->(AllTrim(EE9_NF) + AllTrim(EE9_SERIE)) <> EEM->(AllTrim(EEM_NRNF) + AllTrim(EEM_SERIE))
            EE9->(DBSkip())
            Loop
         EndIf

         ////////////////////////////////////////////////////////
         //Verifica se a tabela EYY está cadastrada no ambiente//
         ////////////////////////////////////////////////////////
         ChkFile("EYY")
         If Select("EYY") > 0
         
            ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //Executa o Seek na tabela EEY, para retornar as Notas de Entrada para cada item correspondente da tabela EE9//
            ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
            EYY->(DbSetOrder(1))
            If EYY->(DbSeek(xFilial("EYY")+AvKey(EEM->EEM_PREEMB,"EYY_PREEMB")))

               While EYY->(!EOF()) .and. EYY->(EYY_FILIAL + EYY_PREEMB) == xFilial("EYY")+AvKey(EEM->EEM_PREEMB,"EYY_PREEMB")

                  If (EYY->(FieldPos("EYY_PEDIDO")) > 0 .And. EYY->(FieldPos("EYY_SEQUEN")) > 0) .And.;
                     (!Empty(EYY->EYY_PEDIDO) .And. !Empty(EYY->EYY_SEQUEN))

                     If AllTrim(EE9->EE9_PEDIDO) <> AllTrim(EYY->EYY_PEDIDO) .Or.;
                        AllTrim(EE9->EE9_SEQUEN) <> AllTrim(EYY->EYY_SEQUEN) .Or.;
                        AllTrim(EE9->EE9_RE)     <> AllTrim(EYY->EYY_RE)

                        EYY->(DBSkip())
                        Loop
                     EndIf
                  Else
                     If AllTrim(EE9->EE9_RE) <> AllTrim(EYY->EYY_RE)
                        EYY->(DBSkip())
                        Loop
                     EndIf
                  EndIf

                  //////////////////////////////////////////////////////
                  //Adiciona as Notas de Entrada relacionadas ao array//
                  //////////////////////////////////////////////////////
                  If !Empty(EYY->EYY_NFENT) .And.;
                     AllTrim(EYY->EYY_NFSAI) == Alltrim(EEM->EEM_NRNF) .And. AllTrim(EYY->EYY_SERSAI) == Alltrim(EEM->EEM_SERIE)

                     SD1->(DbSetOrder(1)) //D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEM
                     If SD1->(DbSeek(xFilial("SD1")+AvKey(EYY->EYY_NFENT,"D1_DOC")+AvKey(EYY->EYY_SERENT,"D1_SERIE")+AvKey(EYY->EYY_FORN,"D1_FORNECE")+;
                        AvKey(EYY->EYY_FOLOJA,"D1_LOJA")+AvKey(EE9->EE9_COD_I, "D1_COD")))

                        /*nopado por WFS em 10/05/2010                  
                        While SD1->(!EOF()) .and. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) ==;
                              xFilial("SD1")+AvKey(EYY->EYY_NFENT,"D1_DOC")+AvKey(EYY->EYY_SERENT,"D1_SERIE")+AvKey(EYY->EYY_FORN,"D1_FORNECE")+AvKey(EYY->EYY_FOLOJA,"D1_LOJA") */
                           

                        ////////////////////////////////////
                        //Grava o CNPJ do Fornecedor da NF//
                        ////////////////////////////////////
                        SA2->(DbSetOrder(1))
                        If SA2->(DbSeek(xFilial("SA2")+AvKey(SD1->D1_FORNECE,"A2_COD")+AvKey(SD1->D1_LOJA,"A2_LOJA")))
                           cCNPJEnt := SA2->A2_CGC
                        EndIf
                        
                        If Empty(cCNPJEnt)
                           cErro+=cProc+STR0067+ENTER //"CNPJ do Fornecedor da NF de entrada nao preenchido "
                        EndIf

                        ////////////////////////////////////////
                        //Grava a NCM do item da NF de Entrada//
                        ////////////////////////////////////////
                        SB1->(DbSetOrder(1))
                        If SB1->(DbSeek(xFilial("SB1")+AvKey(SD1->D1_COD,"B1_COD")))
                           cNCMEnt:= SB1->B1_POSIPI
                        EndIf
                           
                        If Empty(cNCMEnt)
                           cErro+=cProc+STR0068+ENTER //"NCM da NF de entrada nao preenchido "
                        EndIf
                           
                        //////////////////////////////////////////////////////
                        //Grava a unidade de medida do item da NF de Entrada//
                        //////////////////////////////////////////////////////
                        If SAH->(DbSeek(cFilSAH+SD1->D1_UM))
                           cUnidade:=AllTrim(SAH->AH_CODRIEX)                        
                           If Empty(cUnidade)                        
                              If EE2->(Dbseek(cFilEE2+MC_TUNM+TM_GER+AvKey(PORTUGUES,"EE2_IDIOMA")+AvKey(SD1->D1_UM,"EE2_COD"))) // "PORT. -PORTUGUES"
                                 cUnidade:=Capital(AllTrim(EE2->EE2_DESCMA))
                                 If !Empty(cUnidade)
                                    If aScan(aUnidad,{|UM| UM[1] = SAH->(RecNo()) }) = 0
                                       aAdd(aUnidad,{SAH->(RecNo()),cUnidade})
                                    EndIf
                                 EndIf
                              EndIf
                           EndIf

                           If Empty(cUnidade)
                              cErro+=cProc+STR0060+SD1->D1_UM+ENTER //" Descricao da unidade nao preenchida, cod.: "
                           EndIf
                        Else
                           If Empty(SD1->D1_UM)
                              cErro+=cProc+STR0040+ENTER //" Codigo da unidade nao preenchido"
                           Else
                              cErro+=cProc+STR0041+SD1->D1_UM+ENTER //" Codigo da unidade nao cadastrado: "
                           EndIf
                           cUnidade:=""
                        EndIf
                           
                        /////////////////////////////////////////////////////
                        //Adiciona as informações de NF de Entrada no array//
                        /////////////////////////////////////////////////////

                        /* Nopado por WFS em 10/05/2010
                           A quantidade e o valor devem ser os efetivamente exportados 
                        If nPos == 0
                           aAdd(aNfEnt,{cCNPJEnt,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_EMISSAO,cNCMEnt,cUnidade,SD1->D1_QUANT,SD1->D1_TOTAL})
                        Else
                           aNfEnt[nPos][7] += SD1->D1_QUANT
                           aNfEnt[nPos][8] += SD1->D1_TOTAL                              
                        EndIf */

                        SD2->(DBSetOrder(3)) //D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM
                        SD2->(DBSeek(EE9->(Ap101FilNf()) + AvKey(EEM->EEM_NRNF, "D2_DOC") + AvKey(EEM->EEM_SERIE, "D2_SERIE") +;
                              AvKey(EEC->EEC_IMPORT, "D2_CLIENTE") + AvKey(EEC->EEC_IMLOJA, "D2_LOJA") + AvKey(EE9->EE9_COD_I, "D2_COD")))

                        If EYY->(FieldPos("EYY_QUANT")) > 0
                           nQuant:= EYY->EYY_QUANT
                           nValor:= nQuant * (SD2->D2_TOTAL / SD2->D2_QUANT)
                           nValor:= Round(nValor, AvSX3("D2_QUANT", AV_DECIMAL))
                        Else
                           nQuant:= SD2->D2_QUANT
                           nValor:= SD2->D2_TOTAL
                        EndIf

//                        nPos := aScan(aNfEnt,{|x| x[2]+x[3]+x[5] == SD1->D1_DOC+SD1->D1_SERIE+cNCMEnt})
                        nPos := aScan(aNfEnt,{|x| x[1]+x[2]+x[3]+x[5] == cCNPJEnt+SD1->D1_DOC+SD1->D1_SERIE+cNCMEnt})//Acb - 09/09/2010 - Tratamento para diferenciar fornecedores diferentes pelo CNPJ
                        If nPos == 0
                           aAdd(aNfEnt,{cCNPJEnt,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_EMISSAO,cNCMEnt,cUnidade,nQuant,nValor})
                        Else
                           aNfEnt[nPos][7] += nQuant
                           aNfEnt[nPos][8] += nValor
                        EndIf
                     EndIf
                  EndIf

                  nQuant:= 0
                  nValor:= 0
                  EYY->(DbSkip())
               EndDo
            EndIf
         EndIf
         
         EE9->(DBSkip())
      EndDo
   EndIf

   ///////////////////////////////////////////////////////////////
   //Verifica se será utilizado o CFOP 7501 pelo ambiente padrão//
   ///////////////////////////////////////////////////////////////
   If Len(aNfEnt) > 0 
      If EEM->(FieldPos("EEM_CF")) > 0 .and. Alltrim(EEM->EEM_CF) == "7501"
         l7501 := .T.
      EndIf
   EndIf

   ////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //ER - 23/01/2009 - 11:30.                                                                                //
   //O ponto de entrada abaixo tem como função verificar se existem notas fiscais de entrada relacionadas    //
   //as notas fiscais de saída. Nesse caso o CFOP utilizado será o 7501 referente a exportação de mercadorias//
   //recebidas anteriormente com fim específico de exportação, e com isso será utilizado um novo layout no   //
   //arquivo XML.                                                                                            //
   //O array aNfEnt deve ser preenchido com a seguinte estrutura:                                            //
   //[1] - CNPJ do Remetente (Nf de Entrada)                                                                 //
   //[2] - Nota Fiscal de Entrada                                                                            //
   //[3] - Série da Nf Entrada                                                                              //
   //[4] - Dt de Emissão da Nf Entrada                                                                       //
   //[5] - NCM do Item da Nota de Entrada                                                                    //
   //[6] - Unidade do Item da Nota de Entrada                                                                //
   //[7] - Quantidade do Item da Nota de Entrada                                                             //
   //[8] - Valor do Item da Nota de Entrada                                                                  //
   //Cada linha do array aNfEnt deverá ser preenchido com uma Nota Fiscal de Entrada relacionada a Nf de     //
   //saída. Porém caso exista mais de um item (com NCM diferentes) na mesma nota de entrada, as posições     //
   //[1], [2], [3] e [4] do array irão se repetir nas linhas do array que são gravados os itens da Nota nas  //
   //posições [5], [6], [7] e [8].                                                                           //
   //O arquivo EEM já está posicionado na Nota Fiscal de Saída a qual se deve verificar a existencia de NF de//
   //entrada relacionadas.                                                                                   //
   ////////////////////////////////////////////////////////////////////////////////////////////////////////////
   If !l7501

      aNfEnt := {}

      If EasyEntryPoint("EECRI100")
         ExecBlock("EECRI100",.F.,.F.,"NF_ENTRADA")
      EndIf
   EndIf

   //////////////////////////////////////////
   //Verifica se será utilizado o CFOP 7501//
   //////////////////////////////////////////
   If Len(aNfEnt) > 0 
      l7501 := .T.
   
      ///////////////////////////////////////////////
      //Inicia tratamento de erros no array aNfEnt.//
      ///////////////////////////////////////////////
      For nInc:=1 To Len(aNfEnt)

         If Empty(aNfEnt[nInc][1]) .or. Empty(aNfEnt[nInc][2]) .or. Empty(aNfEnt[nInc][4]) .or.;
            Empty(aNfEnt[nInc][5]) .or. Empty(aNfEnt[nInc][6]) .or. Empty(aNfEnt[nInc][7]) .or.;
            Empty(aNfEnt[nInc][8])
         
            cErro+=cProc+STR0069+ENTER //"Informações incompletas para geração do layout XML, para CFOP 7501."

         EndIf
      Next
   
   EndIf
   
   EEC->(DBSEEK(cFilEEC+TRB->EEM_PREEMB))
   
   /////////////////////////////////////////////////////////////////////////////////////
   //Inicia impressão do layout para exportação de mercadorias recebidas anteriormente//
   //com fim específico de exportação - CFOP: 7501                                    //
   /////////////////////////////////////////////////////////////////////////////////////
   If l7501
      
      aREs := {}

      EES->(DbSetOrder(1))
      If !EES->(dbSeek(cFilEES+EEM->EEM_PREEMB+EEM->EEM_NRNF))
         cErro+=cProc+STR0038+ENTER //" Nota fiscal nao possui itens"
      Endif

      Do While !EES->(Eof()) .And.; 
                EES->EES_FILIAL == cFilEES         .And.;
                EES->EES_PREEMB == EEM->EEM_PREEMB .And.;
                EES->EES_NRNF   == EEM->EEM_NRNF

         If EES->EES_SERIE <> EEM->EEM_SERIE 
            EES->(dbSkip())
            Loop
         EndIf

         If EEM->(FieldPos("EEM_CNPJ")) > 0  // By JPP - 22/03/2006 - 11:10
            If EES->EES_CNPJ # EEM->EEM_CNPJ
               EES->(dbSkip())
               Loop
            EndIf   
         EndIf
      
         If EE9->(dbSeek(cFilEE9+EES->EES_PREEMB+EES->EES_PEDIDO+EES->EES_SEQUEN))

            If Empty(EE9->EE9_NF) .or. EE9->(AllTrim(EE9_NF)+AllTrim(EE9_SERIE)) == EES->(AllTrim(EES_NRNF)+AllTrim(EES_SERIE))
               
               SA2->(DbSeek(cFilSA2+EE9->EE9_FABR+EE9->EE9_FALOJA))
               cChave:=EE9->EE9_FABR+EE9->EE9_FALOJA
               If Empty(SA2->A2_EST)
                  SA2->(DbSeek(cFilSA2+EE9->EE9_FORN+EE9->EE9_FOLOJA))
                  cChave:=EE9->EE9_FORN+EE9->EE9_FOLOJA
               EndIf
               If Empty(SA2->A2_EST)
                  SA2->(DbSeek(cFilSA2+EEC->EEC_FORN+EEC->EEC_FOLOJA))
                  cChave:=EEC->EEC_FORN+EEC->EEC_FOLOJA
               EndIf
               If Empty(SA2->A2_EST)
                  cErro+=cProc+STR0039+ALLTRIM(cChave)+ENTER //" Estado nao preenchido no cadastro do forn.: "
               EndIf
               
               If !Empty(EE9->EE9_RE)
                  If  aScan(aREs,{|x| x[1] == EE9->EE9_RE}) == 0
                     aAdd(aREs,{EE9->EE9_RE,SA2->A2_EST})
                  EndIf   
               EndIf
               
               nPesLiq += (EE9->EE9_PSLQUN*EES->EES_QTDE)
 
            EndIf
         EndIf

         EES->(DbSkip())
      EndDo
      
      aAuxNfEnt := {}
      
      //ACB - 31/08/2010
      If lExcel
         cITEMCSV:= "CNPJ" + CHR(59)
         cITEMCSV += "NF"+ CHR(59)
         cITEMCSV += "Serie"+ CHR(59)
         cITEMCSV += "Data Emissao"+ CHR(59)
         cITEMCSV += "NCM"+ CHR(59)
         cITEMCSV += "Unidade"+ CHR(59)
         cITEMCSV += "Quantidade"+ CHR(59)
         cITEMCSV += "ValorTotalItem" + ENTER
      EndIf

      For nInc:=1 To Len(aNfEnt)
         
//         nPos := aScan(aAuxNfEnt,{|x| AllTrim(x[1])==AllTrim(aNfEnt[nInc][2]) .and. AllTrim(x[2])==AllTrim(aNfEnt[nInc][3]) })
         nPos := aScan(aAuxNfEnt,{|x| AllTrim(x[1])==AllTrim(aNfEnt[nInc][1]) .and. AllTrim(x[2])==AllTrim(aNfEnt[nInc][2]) .and. Alltrim(x[3])==Alltrim(aNfEnt[nInc][3]) })//ACb - 09/09/2010 - Tratamento para diferencias fornecedores diferentes pelo CNPJ
         
         If nPos == 0
//            aAdd(aAuxNfEnt,{aNfEnt[nInc][2],aNfEnt[nInc][3]})
            aAdd(aAuxNfEnt,{aNfEnt[nInc][1], aNfEnt[nInc][2],aNfEnt[nInc][3]})//ACb - 09/09/2010 - Tratamento para diferencias fornecedores diferentes pelo CNPJ
            
            If nInc > 1
               cItemXML+='</RelacaoNf>' 
            EndIf
                        
            cItemXML+='<RelacaoNf'
            cItemXML+=' CNPJ="'        +AvgXMLEncoding(AllTrim(aNfEnt[nInc][1])) +'"' 
            cItemXML+=' NF="'          +AvgXMLEncoding(Right(AllTrim(aNfEnt[nInc][2]),6)) +'"'
            cItemXML+=' Serie="'       +AvgXMLEncoding(ALLTRIM(If(Val(aNfEnt[nInc][3])=0, "0", aNfEnt[nInc][3]))) +'"'
            cItemXML+=' DataEmissao="' +AvgXMLEncoding(RIDataC(aNfEnt[nInc][4])) +'">'+ENTER
             
            cItemXML+='<ItemNfExportacao'
            cItemXML+=' NCM="'           +AvgXMLEncoding(ALLTRIM(aNfEnt[nInc][5]))+'"'
            cItemXML+=' Unidade="'       +AvgXMLEncoding(aNfEnt[nInc][6])+'"'
            cItemXML+=' Quantidade="'    +AvgXMLEncoding(STRTRAN(TRANS(aNfEnt[nInc][7],AVSX3("EES_QTDE",6)),".",""))+'"'
            cItemXML+=' ValorTotalItem="'+AvgXMLEncoding(STRTRAN(TRANS(aNfEnt[nInc][8],AVSX3("EES_VLNF",6)),".",""))+'"/>'+ENTER

            If lExcel
               cITEMCSV+=AllTrim(aNfEnt[nInc][1]) + ';'//ACB - 31/08/2010            
               cITEMCSV+=Right(AllTrim(aNfEnt[nInc][2]),6) + ';'//ACB - 31/08/2010            
               cITEMCSV+= ALLTRIM(aNfEnt[nInc][3]) + ';'//ACB - 31/08/2010
               cITEMCSV+=RIDataC(aNfEnt[nInc][4]) + ';'//ACB - 31/08/2010
               cITEMCSV+=ALLTRIM(aNfEnt[nInc][5]) + ';'//ACB - 31/08/2010
               cITEMCSV+=aNfEnt[nInc][6] + ';'//ACB - 31/08/2010
               cITEMCSV+=TRANS(aNfEnt[nInc][7],AVSX3("EES_QTDE",6)) + ';'//ACB - 31/08/2010
               cITEMCSV+=TRANS(aNfEnt[nInc][8],AVSX3("EES_VLNF",6)) + ENTER//ACB - 31/08/2010
            EndIf
         Else
         
            cItemXML+='<ItemNfExportacao'
            cItemXML+=' NCM="'           +AvgXMLEncoding(ALLTRIM(aNfEnt[nInc][5]))+'"'
            cItemXML+=' Unidade="'       +AvgXMLEncoding(aNfEnt[nInc][6])+'"'
            cItemXML+=' Quantidade="'    +AvgXMLEncoding(STRTRAN(TRANS(aNfEnt[nInc][7],AVSX3("EES_QTDE",6)),".",""))+'"'
            cItemXML+=' ValorTotalItem="'+AvgXMLEncoding(STRTRAN(TRANS(aNfEnt[nInc][8],AVSX3("EES_VLNF",6)),".",""))+'"/>'+ENTER
         
            If lExcel
               cITEMCSV+=ALLTRIM(aNfEnt[nInc][5]) + ';'//ACB - 31/08/2010            
               cITEMCSV+=aNfEnt[nInc][6] + ';'//ACB - 31/08/2010
               cITEMCSV+=TRANS(aNfEnt[nInc][7],AVSX3("EES_QTDE",6)) + ';'//ACB - 31/08/2010
               cITEMCSV+=TRANS(aNfEnt[nInc][8],AVSX3("EES_VLNF",6)) + ENTER//ACB - 31/08/2010
            EndIf
         EndIf
         
      Next
     
      cItemXML+='</RelacaoNf>' 
   
   Else

      //ACB - 31/08/2010
      If lExcel
         cITEMCSV:="NCM;Unidade;Quantidade;Valor Total Item" + ENTER
      EndIf
   
      IF !EES->(dbSeek(cFilEES+EEM->EEM_PREEMB+EEM->EEM_NRNF))
         cErro+=cProc+STR0038+ENTER //" Nota fiscal nao possui itens"
      ENDIF
   
      Do While !EES->(Eof()) .And.; 
                EES->EES_FILIAL == cFilEES         .And.;
                EES->EES_PREEMB == EEM->EEM_PREEMB .And.;
                EES->EES_NRNF   == EEM->EEM_NRNF

         IF EES->EES_SERIE # EEM->EEM_SERIE 
            EES->(dbSkip())
            LOOP
         ENDIF 
      
         If EEM->(FieldPos("EEM_CNPJ")) > 0  // By JPP - 22/03/2006 - 11:10
            If EES->EES_CNPJ # EEM->EEM_CNPJ
               EES->(dbSkip())
               LOOP
            EndIf   
         EndIf

         IF EE9->(dbSeek(cFilEE9+EES->EES_PREEMB+EES->EES_PEDIDO+EES->EES_SEQUEN))

            IF !EMPTY(EE9->EE9_NF)
               Do While !EE9->(Eof()) .And.; 
                         EE9->EE9_FILIAL == cFilEE9         .And.;
                         EE9->EE9_PREEMB == EES->EES_PREEMB .And.;
                         EE9->EE9_PEDIDO == EES->EES_PEDIDO .And.;
                         EE9->EE9_SEQUEN == EES->EES_SEQUEN
                  IF EES->EES_NRNF # EE9->EE9_NF .OR. EES->EES_SERIE # EE9->EE9_SERIE
                     EE9->(dbSkip())
                     LOOP
                  ENDIF
                  EXIT
               ENDDO
            ENDIF
         
            SA2->(DBSEEK(cFilSA2+EE9->EE9_FABR+EE9->EE9_FALOJA))
            cChave:=EE9->EE9_FABR+EE9->EE9_FALOJA
            IF EMPTY(SA2->A2_EST)
               SA2->(DBSEEK(cFilSA2+EE9->EE9_FORN+EE9->EE9_FOLOJA))
               cChave:=EE9->EE9_FORN+EE9->EE9_FOLOJA
            ENDIF
            IF EMPTY(SA2->A2_EST)
               SA2->(DBSEEK(cFilSA2+EEC->EEC_FORN+EEC->EEC_FOLOJA))
               cChave:=EEC->EEC_FORN+EEC->EEC_FOLOJA
            ENDIF
            IF EMPTY(SA2->A2_EST)
               cErro+=cProc+STR0039+ALLTRIM(cChave)+ENTER //" Estado nao preenchido no cadastro do forn.: "
            ENDIF

            IF SAH->(DBSEEK(cFilSAH+EE9->EE9_UNIDAD))
               cUnidade:=ALLTRIM(SAH->AH_CODRIEX)
               IF EMPTY(cUnidade)
                  IF EE2->(Dbseek(cFilEE2+MC_TUNM+TM_GER+AvKey(PORTUGUES,"EE2_IDIOMA")+AvKey(EE9->EE9_UNIDAD,"EE2_COD"))) //"PORT. -PORTUGUES"
                     cUnidade:=Capital(ALLTRIM(EE2->EE2_DESCMA))
                     IF !EMPTY(cUnidade)
                        IF ASCAN(aUnidad,{|UM| UM[1] = SAH->(RECNO()) }) = 0
                           AADD(aUnidad,{SAH->(RECNO()),cUnidade})
                        ENDIF
                     ENDIF
                  ENDIF
               ENDIF
               IF EMPTY(cUnidade)
                  cErro+=cProc+STR0060+EE9->EE9_UNIDAD+ENTER //" Descricao da unidade nao preenchida, cod.: "
               ENDIF
            ELSE
               IF EMPTY(EE9->EE9_UNIDAD)
                  cErro+=cProc+STR0040+ENTER //" Codigo da unidade nao preenchido"
               ELSE
                  cErro+=cProc+STR0041+EE9->EE9_UNIDAD+ENTER //" Codigo da unidade nao cadastrado: "
               ENDIF
               cUnidade:=""
            ENDIF
         
            // FJH 05/10/05 Checa no campo EEC_TSISC o tipo de siscomex de acordo com tabela padrão TS no SX5
            If Empty(EEC->EEC_TSISC)
               cErro += cProc+STR0064+ENTER //" O Tipo Siscomex não foi preenchido no Embarque."
            Endif

            IF EMPTY(EE9->EE9_RE)
               lTemREembranco:=.T.
            ELSEIF !lTemREembranco
               //IF (nPos:=ASCAN( aREs,{|R| R[1] = EE9->EE9_RE } )) = 0
               // FJH 12/12/05 - Quando o RE E o NCM são iguais não dá o erro e adiciona
               IF (nPos:=ASCAN( aREs,{|R| R[1] = EE9->EE9_RE } )) = 0 .or. aRes[nPos,4] == AllTrim(EE9->EE9_POSIPI)
                  AADD(aREs, {EE9->EE9_RE,SA2->A2_EST,ALLTRIM(EES->EES_SEQUEN),ALLTRIM(EE9->EE9_POSIPI)} )
               ELSE
                  cErro+=cProc+" RE: "+ALLTRIM(EE9->EE9_RE)+STR0062+ALLTRIM(EES->EES_SEQUEN)+"/"+ALLTRIM(EE9->EE9_POSIPI)+ENTER //" da Seq./NCM: "
                  cErro+=SPACE(LEN(cProc))+STR0063+aREs[nPos,3]+"/"+aREs[nPos,4]+ENTER //" ja pertence a Seq./NCM: "
               ENDIF
            ENDIF
   
            IF !EMPTY(cErro)
               EES->(dbSkip())
               LOOP
            ENDIF

            cITEMXML+='<ItemNfExportacao'
            cITEMXML+=' NCM="'           +AvgXMLEncoding(ALLTRIM(EE9->EE9_POSIPI))+'"'
            cITEMXML+=' Unidade="'       +AvgXMLEncoding(cUnidade)+'"'
            cITEMXML+=' Quantidade="'    +AvgXMLEncoding(STRTRAN(TRANS(EES->EES_QTDE,AVSX3("EES_QTDE",6)),".",""))+'"'
            cITEMXML+=' ValorTotalItem="'+AvgXMLEncoding(STRTRAN(TRANS(EES->EES_VLNF,AVSX3("EES_VLNF",6)),".",""))+'"/>'+ENTER

            nPesLiq += (EE9->EE9_PSLQUN*EES->EES_QTDE)

            If lExcel
               cITEMCSV+=TRANS(EE9->EE9_POSIPI,AVSX3("EE9_POSIPI",6)) + ';'//ACB - 31/08/2010            
               cITEMCSV+=cUnidade + ';'//ACB - 31/08/2010
               cITEMCSV+=TRANS(EES->EES_QTDE,AVSX3("EES_QTDE",6)) + ';'//ACB - 31/08/2010
               cITEMCSV+=TRANS(EES->EES_VLNF,AVSX3("EES_VLNF",6)) + ';'//ACB - 31/08/2010
            EndIf
         ELSE
            cErro+=cProc+STR0042+ALLTRIM(cFilEE9+EES->EES_PREEMB+EES->EES_PEDIDO+EES->EES_SEQUEN)+STR0043+ENTER //" Chave: "###" nao encontrada nos itens do Embarque"
         ENDIF

         EES->(dbSkip())
           
      EndDo         
   EndIf

   IF SYA->(DBSEEK(cFilSYA+EEC->EEC_PAISDT))
      IF EMPTY(SYA->YA_CODRIEX)
         cPais:=Capital(ALLTRIM(SYA->YA_DESCR))
         IF ASCAN(aPaises,{|PA| PA[1] = SYA->(RECNO()) }) = 0
            AADD(aPaises,{SYA->(RECNO()),cPais})
         ENDIF
      ELSE
         cPais:=ALLTRIM(SYA->YA_CODRIEX)
      ENDIF
      IF EMPTY(cPais)
         cErro+=cProc+STR0044+EEC->EEC_PAISDT+ENTER //" Descricao do pais nao preenchida, codigo: "
      ENDIF
   ELSE
      IF EMPTY(EEC->EEC_PAISDT)
         cErro+=cProc+STR0045+ENTER //" Codigo do pais de destino nao preenchido"
      ELSE
         cErro+=cProc+STR0046+EEC->EEC_PAISDT+ENTER //" Codigo do pais nao cadastrado: "
      ENDIF
      cPais:=""
   ENDIF

   If(EasyEntryPoint("EECRI100"),ExecBlock("EECRI100",.F.,.F.,"ENVIO_ERRO"),)

   IF !EMPTY(cErro)
      cErroALL+=cErro
      cErro:=""
   ENDIF

   IF !EMPTY(cErroALL)
      TRB->(DBSKIP())
      LOOP
   ENDIF

// FJH 05/10/05 A sequencia tipo SISCOMEX é definido pelo campo EEC_TSISC.
   cTipo := EEC->EEC_TSISC

/*   IF lTemREembranco
      cTipo:="8"
   ELSE
      cTipo:="1"
   ENDIF

   IF EEC->EEC_AMOSTR $ "1YS"
      cTipo:="9"
   ENDIF

   IF lTemDSE
      EXL->(dbSetOrder(1))
      EXL->(dbSeek(xFilial()+EEC->EEC_PREEMB))
      IF !EMPTY(EXL->EXL_DSE)
         cTipo:="7"
      ENDIF
   ENDIF
*/

   If EasyEntryPoint("EECRI100")
       ExecBlock("EECRI100",.F.,.F.,"ANTES_GRAVA_XML")
   EndIf
   
   If lExcel
      cRECSV:="RE;Tipo Siscomex;UF Produtor" + ENTER
   EndIf

   IF cTipo = "1"
      FOR RE := 1 TO LEN(aREs)
          cREXML+='<RE RE="'+AvgXMLEncoding(aREs[RE,1])+'"'  
          cREXML+=' TipoSiscomex="RE"'
          cREXML+=' UFProdutor="'+AvgXMLEncoding(aREs[RE,2])+'" />'+ENTER
          
          If lExcel
             cRECSV+=TRANS(aREs[RE,1],AVSX3("EE9_RE",6)) + ';'//ACB - 31/08/2010          
             cRECSV+=' RE' + ';'//ACB - 31/08/2010
             cRECSV+=aREs[RE,2] + ENTER//ACB - 31/08/2010
          EndIf
      NEXT
   ENDIF

   // cXML+='<NfExportacao CFOP="7101"'
   //ACB - 31/08/2010
   If lExcel
      cDadosCsv:= "NfExportacao CFOP;SequenciaTipoSiscomex;NF;Serie;DataEmissao;ValorTotal;PesoLiquido;Pais" + ENTER
   EndIf

   If EEM->(FieldPos("EEM_CF")) > 0 .And. !lNota7501
      cXML+='<NfExportacao CFOP="'+AvgXMLEncoding(AllTrim(EEM->EEM_CF))+'"'
      If lExcel
         cDadosCsv+=AllTrim(EEM->EEM_CF) + ';'//ACB - 31/08/2010
      EndIf
   Else
      If l7501 .Or. lNota7501
         cXML+='<NfExportacao CFOP="7501"'
         If lExcel
            cDadosCsv+= "7501" + ';'//ACB - 31/08/2010
         EndIf
      Else
         cXML+='<NfExportacao CFOP="7101"'
         If lExcel
            cDadosCsv+="7101" + ';'//ACB - 31/08/2010
         EndIf
      EndIf  
   EndIf

   cXML   +=' SequenciaTipoSiscomex="'+AvgXMLEncoding(cTipo)+'"'
   cXML   +=' NF="'                   +AvgXMLEncoding(Right(ALLTRIM(EEM->EEM_NRNF),6)) +'"'
   
   //cXML   +=' Serie="'                +AvgXMLEncoding(ALLTRIM(If(Val(EEM->EEM_SERIE)=0, "0", EEM->EEM_SERIE)))+'"' //RMD - 24/02/15 - Projeto Chave NF
   cXML   +=' Serie="'                +AvgXMLEncoding(ALLTRIM(If(Val(EEM->EEM_SERIE)=0, "0", Transform(EEM->EEM_SERIE, AvSx3("EEM_SERIE", AV_PICTURE)))))+'"'
   
   cXML   +=' DataEmissao="'          +AvgXMLEncoding(RIDataC(EEM->EEM_DTNF)) +'"'
   cXML   +=' ValorTotal="'           +AvgXMLEncoding(STRTRAN(TRANS(EEM->EEM_VLNF,AVSX3("EEM_VLNF",6)),".",""))+'"'
   cXML   +=' PesoLiquido="'          +AvgXMLEncoding(STRTRAN(TRANS(nPesLiq,AVSX3("EEC_PESLIQ",6)),".",""))    +'"'
   cXML   +=' Pais="'                 +AvgXMLEncoding(cPais)+'" >'+ENTER

   cXML   += cREXML
   cXML   += cITEMXML
   cXML   +='</NfExportacao>'+ENTER
   
   //Acb - 31/08/2010
   IF lExcel                     
      cDadosCsv+= cTipo + ';'//ACB - 31/08/2010
      cDadosCsv+= "'" + EEM->EEM_NRNF + ';'//ACB - 31/08/2010
      
      //cDadosCsv+=ALLTRIM(If(Val(EEM->EEM_SERIE)=0, "0", EEM->EEM_SERIE)) + ';'   //RMD - 24/02/15 - Projeto Chave NF
      cDadosCsv+=ALLTRIM(If(Val(EEM->EEM_SERIE)=0, "0", Transform(EEM->EEM_SERIE, AvSx3("EEM_SERIE", AV_PICTURE)))) + ';'
      
      cDadosCsv+=RIDataC(EEM->EEM_DTNF) + ';'//ACB - 31/08/2010
      cDadosCsv+= TRANS(EEM->EEM_VLNF,AVSX3("EEM_VLNF",6)) + ';'//ACB - 31/08/2010
      cDadosCsv+=TRANS(nPesLiq,AVSX3("EEC_PESLIQ",6)) + ';'//ACB - 31/08/2010
      cDadosCsv+= cPais + ENTER + ENTER//ACB - 31/08/2010
   
      cDadosCsv += cITEMCSV + ENTER + ENTER
      cDadosCsv += cRECSV + ENTER + ENTER
   EndIF
   
   If(EasyEntryPoint("EECRI100"),ExecBlock("EECRI100",.F.,.F.,"GRAVA_XML"),)

   lNota7501 := .F.

   /*
   Nopado por ER - 22/01/2007 - A função abaixo transfomava inclusive os caracteres de abertura e fechamento de Tag.
               
   //JAP - 09/08/06 -  Não é necessário converter os caracteres do arquivo XML para o RIEX no Windows.
   IF IsSrvUnix()
      cXML := AvgXMLEncoding(cXML)
   ENDIF
   */
   
   FWRITE(nArq,cXML)
   cXML:=""
   cREXML:=""
   cITEMXML:=""
   
   //ACB - 31/08/2010
   If lExcel
      FWRITE(nArq2,cDadosCsv)
      cDadosCsv:=""
      cITEMCSV :=""
      cRECSV   :=""
   EndIF

   TRB->(DBSKIP())

ENDDO

ProcRegua(LEN(aPaises))
FOR PA := 1 TO LEN(aPaises)
   IncProc(STR0047) //"Atualizando paises..."
   SYA->(DBGOTO(aPaises[PA,1]))
   SYA->(RECLOCK("SYA",.F.))
   SYA->YA_CODRIEX:=aPaises[PA,2]
   SYA->(MSUNLOCK())
NEXT

ProcRegua(LEN(aUnidad))
FOR UM := 1 TO LEN(aUnidad)
   IncProc(STR0048) //"Atualizando unidades..."
   SAH->(DBGOTO(aUnidad[UM,1]))
   SAH->(RECLOCK("SAH",.F.))
   SAH->AH_CODRIEX:=aUnidad[UM,2]
   SAH->(MSUNLOCK())
NEXT

EE9->(dbSetOrder(1))
TRB->(DBGOTOP())

IF !EMPTY(cErroALL)

   cErroALL:=STR0049+;//"Embarque             Nota Fiscal Serie Data NF  Erros"
                  ENTER+"-------------------- ----------- ----- -------- --------------------------------------------------------"+ENTER+cErroALL

   FCLOSE(nArq)

   EECView(cErroALL,STR0050) //"Inconsistencias Encontradas"

   FERASE(cFileXML)

   RETURN .F.

ELSEIF lTemItens

   cXML+="</RegistroExportacao>"   
   FWRITE(nArq,cXML)
   FCLOSE(nArq)                 
   
   //ACB - 31/08/2010
   If lExcel
      FWRITE(nArq2,cDadosCsv)
      FCLOSE(nArq2)
   EndIf 

   
   //Acb - 31/08/2010
   If file(cPath+cFileCsv)
      FERASE(cPath+cFileCsv)
   EndIf

   If File(cPath+cFileXML) 
      fErase(cPath+cFileXML)
   EndIf   
   AvCpyFile(cFileXML,cPath+cFileXML)
   FERASE(cFileXML)
   
   //Acb - 31/08/2010
   If lExcel
      AvCpyFile(cFileCSV, cPath+cFileCSV)
      FERASE(cFileCSV)
   EndIf

   ProcRegua(TRB->(LASTREC()))
   DO WHILE TRB->(!EOF())
      IncProc(STR0051+ALLTRIM(TRB->EEM_NRNF)) //"Status Nota: "
      IF EMPTY(TRB->WKMARCA)
         TRB->(DBSKIP())
         LOOP
      ENDIF
      EEM->(DBGOTO(TRB->WKRECNOEEM))
      EEM->(RECLOCK("EEM",.F.))
      EEM->EEM_RIEXST:="E"
      EEM->(MSUNLOCK())

      TRB->(DBSKIP())

   ENDDO
   
   MsgInfo(STR0070 + AllTrim(cFileXML)) //Arquivo gerado com sucesso: ######
   
   
   //ACB - 30/08/2010
   If lExcel == .T.
      ExcelRiex()
      lExcel:= .F.
   EndIf
   
ELSEIF !lTemItens
   MSGSTOP(STR0052) //"Nao existe NF's marcadas."
ENDIF

RETURN lTemItens
*-----------------------------------------*
FUNCTION RIEX_Grava()
*-----------------------------------------*
ProcRegua(TRB->(LASTREC()))

DO WHILE TRB->(!EOF())

   IncProc(STR0051+ALLTRIM(TRB->EEM_NRNF)) //"Status Nota: "

   IF TRB->WK_ALTEROU
      EEM->(DBGOTO(TRB->WKRECNOEEM))
      EEM->(RECLOCK("EEM",.F.))
      EEM->EEM_RIEXST:=TRB->EEM_RIEXST
      EEM->(MSUNLOCK())
   ENDIF

   TRB->(DBSKIP())

ENDDO

RETURN .T.


*---------------------------------------------------------*
FUNCTION RIDataC(dDate)
*---------------------------------------------------------*
RETURN STRZERO(DAY(dDate),2)+"/"+STRZERO(MONTH(dDate),2)+"/"+STR(YEAR(dDate),4,0)

*-----*-----*-----*-----*-----*-----*
Function RIGetPath()
*-----*-----*-----*-----*-----*-----*
Local oDlg,nOpcao:= 0
Local aButtons

cPath    := EasyGParam("MV_AVG0104",,"C:\")
cFileXML := "RIEX_"+STRZERO(DAY(dDatabase),2)+STRZERO(MONTH(dDatabase),2)+RIGHT(STR(YEAR(dDatabase),4),2)+Space(20)
cFileCSV := cFileXML //"RIEX_"+STRZERO(DAY(dDatabase),2)+STRZERO(MONTH(dDatabase),2)+RIGHT(STR(YEAR(dDatabase),4),2)+Space(20)//acb - 31/08/2010

If Empty(cPath) .Or. AllTrim(cPath) == "\"
   cPath:= GetTempPath()
EndIf

aButtons:={} //LRS - 27/11/2017
aAdd(aButtons, {"EXCEL",{|| lExcel:= .T., nOpcao:= 1, oDlg:End()}, "Exportar para Excel"}) //LRS - 27/11/2017

Do While .T.
   
   nOpcao := 0
 
   oMainWnd:ReadClientCoords()
   Define MsDialog oDlg Title STR0053 From 1,1 To 180,450 Of oMainWnd Pixel //"Exportar p/ Excel"

         oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165)
         oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

         nLin := 20       
         @ nLin,10 Say STR0054  Size 50,10 OF oPanel Pixel  //"Salvar em:"
         @ nLin,75 MSGet cPath When .F. Size 115,08 OF oPanel Pixel 
         @ nLin,200 Button "..." Size 10,12 Action Eval({|| cPath := cGetFile(,OemToAnsi(STR0055),,cPath,.T.,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_RETDIRECTORY) }) OF oPanel Pixel   //"Diretório de Gravação..."

         nLin += 14 
         @ nLin,10 Say STR0056  Size 50,10 OF oPanel Pixel  //"Nome do XML:"
         @ nLin,75 MSGet cFileXML Size 115,08 OF oPanel Pixel  
         nLin += 18 
         //@ nLin,60 Button "Exportar para Excel" Action {|| lExcel:= .T., nOpcao:= 1, oDlg:End()}Size 100,10 Of oDlg Pixel //Acb - 30/08/2010
         
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{||nOpcao := 1,oDlg:End()},{||nOpcao := 0, oDlg:End()},,aButtons) Centered

      If nOpcao = 0 
         RETURN .T.
      EndIf  
            
      If Empty(cFileXML)
         MsgInfo(STR0057,STR0058) //"Preencher um nome para o XML."###"Atenção"
         Loop
      EndIf

      If Empty(cPath)
         MsgInfo(STR0059,STR0058) //"Preencher um caminho para o XML."###"Atenção"
         Loop
      EndIf

      cPath:=RTRIM(cPath)
      IF Right(cPath,1) <> "\"
         cPath += "\"
      ENDIF    

      SetMV("MV_AVG0104", AllTrim(cPath))

      If nOpcao = 1
         Exit
      EndIf                           

EndDo   

cFileXML := AllTrim(cFileXML)

//Acb - 31/08/2010
If lExcel
   cFileCsv:= If(Upper(Left(cFileXML,4)) <> ".XML", Alltrim(cFileXML) + ".CSV", cFileCsv + ".CSV")
EndIf

If(Upper(Left(cFileXML,4)) <> ".XML",cFileXML += ".XML",)


RETURN .F. 


/*
Funcao      : ExcelRiex
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Efetuar a impressão do arquivo csv com os dados do Xml no excel.
Autor       : André C. Balieiro 
Data/Hora   : 31/08/2010 11:00
*/
*---------------------------------------------*
Static Function ExcelRiex()
*---------------------------------------------*

If !ApOleClient("MSExcel")
   MsgAlert("Microsoft Excel não instalado!")
   Return
EndIf
oExcel:= MsExcel():New()
Sleep(2000)
oExcel:WorkBooks:Open(cPath+cFileCSV)
Sleep(2000)
oExcel:SetVisible(.T.)
oExcel:Destroy()

Return

//----------------------------------------------------------------------------------------------------------------//
//                                 FIM DO PROGRAMA EECRI100.PRW
//----------------------------------------------------------------------------------------------------------------//
