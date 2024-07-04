#INCLUDE "EECAC120.ch"
#INCLUDE "DBTREE.ch"
#INCLUDE "AVERAGE.CH"
#INCLUDE 'FWMVCDef.ch'
#INCLUDE 'Protheus.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
/*                                                                                    
Programa..: EECAC120
Objetivo..: Permitir Manutencao de Produtos em varios Idiomas                                     
Autor.....: Cristiano A. Ferreira
Data/Hora.: 10/06/1999 08:59
Obs.......: 
 -LCS.23/04/2004-> INCLUSAO DO PONTO DE ENTRADA ANTES DA EXECUCAO DA ENCHOICE
 -LCS - 16/07/2002 - INCLUSAO DO CADASTRO DE 
  PRODUTOS x PAISES x CLIENTES
 -LCS - 01/08/2002 - ACERTOS NO CADASTRO DE PRODUTOS x PAISES x CLIENTES
*/
#include "EEC.CH"
#COMMAND E_RESET_AREA => SB1->(DBSETORDER(1))      
#define ENCERRAR      6 // GFP - 01/11/2013

/*
Funcao      : EECAC120
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Montar browse
Autor       : Cristiano A. Ferreira
Data/Hora   : 10/06/99 09:00
Revisao     :
Obs.        : Uso da funcao AbreArqExp e FechaArqExp quando o modulo for SIGAEDC (Drawback)
*/
Function EECAC120(xAutoCab,xAutoComp,nOpcAuto,xAutoEE2)
LOCAL cWORKEX5,aSEMSX3,cWORKEX6
Local lRet:=.T.,cOldArea:=select()
//JPM - 15/01/05 - Array de campos que não serão mostrados na enchoice
Local aNotShow := {}
Private lAltDecri:=.F. //Alcir Alves - 19-05-05 
Private cDesPro1:="" //Alcir Alves - 19-05-05  - descrição do produto em portugues antes da modificação
Private cDesPro2:="" //Alcir Alves - 19-05-05 - descrição do produto em portugues depois da modificação
Private cCadastro:=AVTITCAD("SB1") //"Atualização de Produtos"
Private cTIPMEN:=TM_GER //filtro para SXB usar mensagens para descrição genérica
PRIVATE lEX5EX6,aHEADER,aCAMPOS
Private aRotina :={}

Private aMemos:={{"EEI_DESC","EEI_VM_DES"}}
Private lNVEEEC := .F.  // GFP - 27/10/2016 - Tratamento de exclusão de NVE
// Verifica se esta no SIGAEDC
Private cFilSB1Aux:= xFilial("SB1")   

Private lNovaRotina := .f. 

// JPM - 13/12/04 - variável que indica se há o tratamento de amarração Norma X País X Produto 
Private lNormaProd := .f.  

If EX5->(FieldPos("EX5_DTINI"))  > 0 .And. EX5->(FieldPos("EX5_DTFIM")) > 0 .And.;
   EX6->(FieldPos("EX6_DTINI"))  > 0 .And. EX6->(FieldPos("EX6_DTFIM")) > 0

   lNovaRotina := .t.
EndIf

//JPM - 15/01/05 - Array de campos para enchoice
Private aCposEnchoice := {}

//FSM - 08/12/11 - ExecAuto  *** Processamento via rotina automática (MsExecAuto).
Private lExecAuto := xAutoCab <> NIL
Private aAutoCab
Private aAutoComp
Private aAutoEE2
// ***

// ** Verifica se as tabelas necessárias para a tabela de preço estão disponíveis.
SX3->(DBSETORDER(2))
lEX5EX6     := SX3->(DBSEEK("EX5_FILIAL")) .AND. SX3->(DBSEEK("EX6_FILIAL"))
M->B1_VM_P  := ""
M->B1_VM_GI := ""

//lNormaProd := SX3->(DBSEEK("EXN_FILIAL")) - RMD - 19/09/05
If Select("EXN") = 0 .and. SX2->(dbSetOrder(1), dbSeek("EXN"))
   dbSelectArea("EXN")
EndIf

If Select("EXN") > 0 
   lNormaProd := .T.
EndIf               

//TRP-30/05/2007
If EasyEntryPoint("EECAC120")                       
   ExecBlock("EECAC120",.F.,.F.,"ANTES_WORK")
EndIf
If lEX5EX6
   
   /* Cria work e respectivos índices para a work de Produtos X Países (TR5) e 
      work de Produtos X Paises X Clientes (TR6) */
   If lNovaRotina
      aSEMSX3  := {{"TR5_RECNO" ,"N",05,0},;
                   {"TR5_STATUS","C",25,0},;
                   {"TRB_ALI_WT","C",03,0},;
                   {"TRB_REC_WT","N",10,0}}

   Else
      aSEMSX3  := {{"TR5_RECNO" ,"N",05,0},;                   
                   {"TRB_ALI_WT","C",03,0},;
                   {"TRB_REC_WT","N",10,0}}
   
   EndIf
   
   aAdd(aSEMSX3,{"TR5_FILTRO","C",01,0}) //FSM - 01/08/2011
   
   IF SELECT("TR5") > 0 //JAL - 24/04/2014
      TR5->(DBCLOSEAREA())
   ENDIF
   
   
   aCAMPOS  := ARRAY(EX5->(FCOUNT()))
   aHEADER  := {}
   cWORKEX5 := E_CRIATRAB("EX5",aSEMSX3,"TR5")
   INDREGUA("TR5",cWORKEX5+TEOrdBagExt(),"EX5_PAIS","AllwayTrue()","AllwaysTrue()",STR0017) //"Gerando Arquivo Temporario p/ EX5"

   If lNovaRotina
      aSEMSX3  := {{"TR6_RECNO" ,"N",10,0},; //LGS-04/11/13
                   {"TR6_STATUS","C",25,0},;
                   {"TRB_ALI_WT","C",03,0},;
                   {"TRB_REC_WT","N",10,0}}
   
   Else
      aSEMSX3  := {{"TR6_RECNO" ,"N",10,0},; //LGS-04/11/13
                   {"TRB_ALI_WT","C",03,0},;
                   {"TRB_REC_WT","N",10,0}}
   
   EndIf
   
   aAdd(aSEMSX3, {"TR6_FILTRO","C",01,0}) // FSM - 01/08/2011
   
   aCAMPOS  := ARRAY(EX6->(FCOUNT()))
   aHEADER  := {}
   cWORKEX6 := E_CRIATRAB("EX6",aSEMSX3,"TR6")
   INDREGUA("TR6",cWORKEX6+TEOrdBagExt(),"EX6_PAIS+EX6_CLIENT+EX6_CLLOJA","AllwayTrue()","AllwaysTrue()",STR0018) //"Gerando Arquivo Temporario p/ EX6"
EndIf

If lNormaProd
   aNotShow := {AvKey("B1_CODNOR","X3_CAMPO")}
EndIf
SX3->(DbSetOrder(1))
SX3->(DbSeek("SB1"))
While SX3->(!EoF()) .And. SX3->X3_ARQUIVO == "SB1"
   If X3Uso(SX3->X3_USADO) .And. SX3->X3_NIVEL <= cNivel
      If AScan(aNotShow,SX3->X3_CAMPO) == 0
         AAdd(aCposEnchoice,SX3->X3_CAMPO)
      EndIf
   EndIf
   SX3->(DbSkip())
EndDo

IF lExecAuto//AWF - 25/04/2014
   AAdd(aCposEnchoice,"B1_VM_P")
ENDIF

If nModulo == 50 //SIGAEDC                       
   lAbriuExp := AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"  ")),cFilSB1Aux) // Abre arq. produtos de outra Empresa/Filial de acordo com os parametros.
EndIf

aRotina := MenuDef(.T., "EECAC120")

    //FSM - 08/12/11 - ExecAuto 
	If !lExecAuto
		// *** Processamento via Interface.
		mBrowse( 6, 1,22,75,"SB1")
		// ***
	Else
		// *** Processamento via rotina automática (MsExecAuto).
		aAutoCab   := xAutoCab
		aAutoComp  := If(ValType(xAutoComp) == "A", xAutoComp, {})  //NCF - 13/01/2014
		aAutoEE2   := If(ValType(xAutoEE2) == "A", xAutoEE2, {})
		MBrowseAuto(nOpcAuto, aAutoCab, "SB1",, .T.)
		If(Len(aAutoComp) # 0,AC120SB5Man(aAutoComp),)  // GFP - 09/04/2014		
	   // ***
   EndIf

// Abre novamente o arquivo de SB1(Itens)-Importação caso tenha sido aberto o SB1(Produtos)-Exportacao       
If nModulo == 50                    // Verifica se esta no SIGAEDC
   If lAbriuExp
      FechaArqExp("SB1",.T.)
   Endif   
EndIf

IF SELECT("TR5") # 0
   TR5->(E_ERASEARQ("TR5",cWORKEX5))
   TR6->(E_ERASEARQ("TR6",cWORKEX6))
ENDIF

DBSELECTAREA(cOldArea)

Return(lRet)                                                       

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya	
Data/Hora  : 17/01/07 - 16:50
*/
Static Function MenuDef(lMBrowse, cOrigem)
Local aRotAdic
Local aRotina := {}
Local cFilSB1Aux:= xFilial("SB1") //LRS - 23/05/2017

//Default cOrigem  := If(Type("cAvStaticCall") == "C", cAvStaticCall, AvMnuFnc())
Default cOrigem  := if(funname()=="CFGA530",AllTrim(M->RL__ROTINA),if(Type("cAvStaticCall")=="C",cAvStaticCall,GetStaticCallProgram()))
//Default lMBrowse := .F. - Nopado pois é necessário retornar todas as opções da rotina. Apenas o menufuncional não pode exibi-las (funcao GETMENUDEF é do menu funcional).
Default lMBrowse := OrigChamada()

Do Case

   Case cOrigem == "EECAC120"

       aRotina := { {STR0001,"AxPesqui",0,PESQUISAR},;  //"Pesquisar"
                   {STR0002,"AC120MAN",0,VISUALIZAR},; //"Visualizar"
                   {STR0003,"AC120MAN",0,INCLUIR},;    //"Incluir"
                   {STR0004,"AC120MAN",0,ALTERAR},;    //"Alterar"
                   {STR0005,"AC120MAN",0,EXCLUIR,3} }  //"Excluir" 
        
      // AOM -  05/05/2011
	  //NCF - 09/01/2012 - Adicionado tratamento para verificar AvFlags do Siscoserv Cadastros 
      //If Select("SX2") > 0 .And. (AvFlags("EEC_LOGIX") .Or. AVFLAGS("DADOS COMPL. PRODUTOS") .Or. AvFlags("CONTROLE_SERVICOS_AQUISICAO") .Or. AvFlags("CONTROLE_SERVICOS_VENDA") .OR. EasyGParam("MV_EIC_EAI",,.F.)) .Or. AvFlags("CONTROLE_CADASTROS_SISCOSERV") //RRC - 20/12/2012 - Adicionado tratamento para verificar AvFlags do Siscoserv, Aquisição ou Venda 
	  
	  //AAF 11/09/2014 - Se a tabela existe, deve exibir a opção, não importa pra que será utilizada.
	  If Select("SX2") > 0 .And. AVFLAGS("DADOS COMPL. PRODUTOS") 
         AAdd( aRotina, { "Dados Comp. de Produtos", "EYJCOMP", 0, 4 } )  //"Dados Comp. de Produtos"
      EndIf 
 
      If nModulo = 50 //SIGAEDC                
         If lMBrowse .And. lAbriuExp
            aRotina := { { STR0001, "AxPesqui"  , 0 , PESQUISAR},; //"Pesquisar"
                         { STR0002,"AC120MAN"  , 0 , VISUALIZAR}} //"Visualizar"                            
            cFilSB1Aux   := If(Empty(ALLTRIM(EasyGParam("MV_FILEXP",,"  "))), Space(02), ALLTRIM(EasyGParam("MV_FILEXP",,"  ")))
         Endif
      EndIf

   Case cOrigem == "EECTP200"
      aRotina := {{STR0001,"AxPesqui"  , 0, PESQUISAR },; //"Pesquisar"
                  {STR0002,"TabCliMan" , 0, VISUALIZAR},; //"Visualizar"
                  {STR0003,"TabCliMan" , 0, INCLUIR   },; //"Incluir"
                  {STR0004,"TabCliMan" , 0, ALTERAR   },; //"Alterar"
                  {STR0005,"TabCliMan" , 0, EXCLUIR,3 },;  //"Excluir"
                  {STR0118,"TabCliMan" , 0, ENCERRAR   }} //"Encerrar"  // GFP - 01/11/2013
              
EndCase                  

//LGS-08/09/2015 - Tabela de/Para - FIERGS
//9 - PRODUTOS
IF AvFlags("TABELA_DE_PARA_FIERGS")
   aaDD(aRotina,{STR0123, 'TE110Inclui("9",SB1->B1_COD)'  , 0 , 4}) //Tabela de/Para
EndIf

//³ P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("EAC120MNU")
	aRotAdic := ExecBlock("EAC120MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf 
                   
Return aRotina

*--------------------------------------------------------------------
/*
Funcao      : AC120MAN
Parametros  : cAlias:= alias arq.
              nReg:=num.registro
              nOpc:=opcao escolhida
Retorno     : .T.
Objetivos   : Manutencao com enchoice
Autor       : Cristiano A. Ferreira
Data/Hora   : 10/06/1999 09:03
Revisao     :
Obs.        :
*/
Function AC120MAN(cAlias,nReg,nOpc)
Local lRet:=.T.,cOldArea:=Select(),oDlg,nInc,bVal_OK
Local lGravaOK:=.T., bCancel := {|| nOpcA:=0, If(!lExecAuto, oDlg:End(),) } //FSM - 08/12/11 - ExecAuto 
Local nOpcA:=3, i
Local cNomArq2,cNomArq3,cNomArq4,cNomArq5    
// 19.mai.2009 - 719146 - Tratamento para peso Bruto menor que peso líquido - HFD
//Local bValidarPeso := {|| Iif(M->B1_PESBRU >= M->B1_PESO, .T.,(MsgInfo("Peso Liquido maior que o Peso Bruto","Aviso"),.F.)) } 
Local bValidarPeso := {|| AC120PesoVld()} 
Local bGrava
Local aCpoWkDel := {} //THTS - 31/10/2017 - Utilizado para enviar o campo DBDELETE para a Work
Local nI
Private aColsNor := {}, aHeaderNor := {}, cFilEXN := "", aNorDelete := {}
PRIVATE aButtons:={}
Private lCompEmb := EasyGParam("MV_AVG0022",,.f.)
Private aTela[0][0],aGets[0],nUsado:=0 
Private aDeletados:={}
Private aCampos := Array(EEI->(FCount())),aHeader[0],cNomArq
// ** By JBJ - 06/06/02   
Private nOpcRotina:=nOpc 
Private lYesExclui:=.f. 
Private bExec_Init := "{|| EE2Manut(nOpc,'" + MC_CPRO + "', '" + MO_MM + "', '" + AC_IN + "',{oDlg,bVal_Ok,bCancel,M->B1_COD,aButtons}) }" //DFS - CodeBlock para ser chamado no ON INIT da oDlg //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
//Private bExec_Init := "{|| ( EE2Manut(nOpc,'" + MC_CPRO + "', '" + MO_MM + "', '" + AC_IN + "',{oDlg,bVal_Ok,bCancel,M->B1_COD,aButtons}), oEnch1:oBox:Align := " + Alltrim(Str(CONTROL_ALIGN_TOP)) + " ) }" //DFS - CodeBlock para ser chamado no ON INIT da oDlg
/* by CAF 31/07/2001 16:28 Nova Tabela de Normas
Private aCampoEEI:= { {{||MemoLine(WkNor->EEI_VM_NOR,AVSX3("EEI_VM_NOR",AV_TAMANHO))},"",AVSX3("EEI_VM_NOR",5)},;
                      {{||WkNor->EEI_PAIS+"-"+BuscaPais(WkNor->EEI_PAIS)},,AVSX3("EEI_PAIS",5)},;
                      {{||WkNor->EEI_CRITOR},,AVSX3("EEI_CRITOR",5)}}
*/
Private aDeleteEE2 := {}, aDeleteEEV:={}, aDeleteEEW:={}

Private aDrwBck := {} //LRL 18/02/04

PRIVATE aDELEX5,aDELEX6
aDELEX5 := {}
aDELEX6 := {}
Begin Sequence 
   
   __lSX8:= .F.
         
      /* by CAF 31/07/2001 16:28 Nova Tabela de Normas   
      cNomArq2 := E_CriaTrab("EEI",{{"EEI_RECNO","N",7,0}},"WkNor")
      IndRegua("WkNor",cNomArq2+OrdBagExt(),"EEI_PAIS+EEI_INSNEG")
      */

      If lCompEmb //Criacao da work de Composicao de embalagem.

         aHeader := {}
         aCampos := {"EEV_ORDEM","EEV_CODEMB","EEV_EMBALA","EEV_DIMENS","EEV_PESBRU","EEV_SEQUEN"}
         aCampos := AddCpoUser(aCampos,"EEV","3")
         //THTS - 31/10/2017
         aCpoWkDel := {}
         aAdd(aCpoWkDel,{"EEV_RECNO","N",7,0})
         aAdd(aCpoWkDel,{"DBDELETE","L",1,0}) //THTS - 31/10/2017 - Este campo DBDELETE deve sempre ser o último campo da Work

         cNomArq3 := E_CriaTrab(,aCpoWkDel,"WkEmb")
         IndRegua("WkEmb",cNomArq3+TEOrdBagExt(),"EEV_ORDEM")     

         cNomArq5 := CriaTrab(,.F.)
         IndRegua("WkEmb",cNomArq5+TEOrdBagExt(),"EEV_SEQUEN")     

         Set Index To (cNomArq3+TEOrdBagExt()),(cNomArq5+TEOrdBagExt())

         aHeader := {}                  
         aCampos := Array(EEW->(FCount()))
         //THTS - 31/10/2017
         aCpoWkDel := {}
         aAdd(aCpoWkDel,{"DBDELETE","L",1,0}) //THTS - 31/10/2017 - Este campo DBDELETE deve sempre ser o último campo da Work
         cNomArq4 := E_CriaTrab("EEW",aCpoWkDel,"WkPro")
         IndRegua("WkPro",cNomArq4+TEOrdBagExt(),"EEW_SEQUEN+EEW_PROEMB")
                  
      EndIf
               
      IF nOpc == INCLUIR
         For nInc := 1 TO (cAlias)->(FCount())
            M->&((cAlias)->(FIELDNAME(nInc))) := CRIAVAR((cAlias)->(FIELDNAME(nInc)))
         Next nInc
         
         //ER - 16/08/2007
         If EECFLAGS("INTTRA")
            RegToMemory("EYJ",.T.) // Para criar os virtuais (Dados Complementares de Produtos)        

            M->EYJ_COMPER := ""
         EndIf
         bVal_OK:={||If(Obrigatorio(aGets,aTela) .AND. eval(bValidarPeso) .AND. AC120PEVALID(nOpc),(nOpcA:=1,If(!lExecAuto, oDlg:End(),)),nOpca:=0)} //FSM - 08/12/11 - ExecAuto 
      Else
         For nInc := 1 TO (cALIAS)->(FCount())
            M->&((cAlias)->(FIELDNAME(nInc))) := (cALIAS)->(FIELDGET(nInc))
         Next nInc

         //ER - 14/08/2007
         If EECFLAGS("INTTRA")
            EYJ->(DbSetOrder(1))
            If EYJ->(DbSeek(xFilial("EYJ")+M->B1_COD))
               RegToMemory("EYJ",.T.) // Para criar os virtuais
               For nInc := 1 TO EYJ->(FCount())
                   M->&(EYJ->(FieldName(nInc))) := EYJ->(FieldGet(nInc))
               Next
              
               M->EYJ_COMPER := MSMM(EYJ->EYJ_CCOMPE,AVSX3("EYJ_COMPER",AV_TAMANHO),,,LERMEMO)
            
            Else
               RegToMemory("EYJ",.T.) // Para criar os virtuais
            
               M->EYJ_COMPER := ""
            
            EndIf
         EndIf
         
         If nOpc = VISUALIZAR
            bVal_OK:={|| nOpca:=0, If(!lExecAuto, oDlg:End(), ) }        // By JPP 07/01/05 16:40 - passar a variável nOpca para zero quando se tratar de uma visualizacao. //FSM - 08/12/11 - ExecAuto 
            /* by CAF 31/07/2001 16:28 Nova Tabela de Normas
            // by OSM 20/05/2002 11:52 Composicao de Embalagens */
            AC120GRTRB(.F.)
         ElseIf nOpc==ALTERAR
            If ! SB1->(Reclock("SB1",.F.))               // By JPP - 18/04/2005 - 08:35 - Bloquear o registro durante a alteração.
               Break
            EndIf
            bVal_OK:={||If(Obrigatorio(aGets,aTela).AND. eval(bValidarPeso) .AND. AC120PEVALID(nOpc),(nOpcA:=2, If(!lExecAuto, oDlg:End(),) ),nOpca:=0)}//HFD //FSM - 08/12/11 - ExecAuto 
            /* by CAF 31/07/2001 16:28 Nova Tabela de Normas
            // by OSM 20/05/2002 11:52 Composicao de Embalagens */
            AC120GRTRB(.F.)
         ElseIf nOpc = EXCLUIR
            IF ! INTEGREF("SB1")
               BREAK
            ENDIF
            If ! SB1->(Reclock("SB1",.F.))               // By JPP - 18/04/2005 - 08:35 - Bloquear o registro durante a exclusão.
               Break
            EndIf
            bVal_OK:={||nOpca:=0,AC120MANE(), If(!lExecAuto, oDlg:End(),) } //FSM - 08/12/11 - ExecAuto 
            /* by CAF 31/07/2001 16:28 Nova Tabela de Normas
            // by OSM 20/05/2002 11:52 Composicao de Embalagens */
            AC120GRTRB(.F.)
         EndIf
      Endif
      
      // Work dos Idiomas ...
      bProc := {|| EE2Manut(nOpc,MC_CPRO,MO_MM,AC_WK,{M->B1_COD}) }
	  If !lExecAuto
         Processa(bProc)
	  Else
	     Eval(bProc)
      EndIf
	  
      /* by CAF 31/07/2001 16:28 Nova Tabela de Normas
      aButtons := {{"NOTE",{||nOpcA:=7,oDlg:End()},STR0006}} //"País X Normas"
      */
      
      // JPM - 06/12/2004
      If lNormaProd
         Aadd(aButtons,{"NORMAS",{|| If(!Empty(M->B1_COD),AC120Normas(cAlias,nOpc),;
                        MsgInfo(STR0084))},STR0097,STR0085})//"Preencha o campo 'Cód. Produto'" /"Amarracao de Produtos x Paises x Normas"/"Normas"
      
         AC120HdNor() //Constrói o aHeader da MsGetDados de Normas
         cFilEXN := xFilial("EXN")
         EXN->(DbSetOrder(1))    
         AC120ColNor() //Carrega os dados no aColsNor  
         
      EndIf   
      If nOpc == 3 .or. nOpc == 4
         Aadd(aButtons,{"S4WB005N" /*"S4WB001N"*/,{|| If(!Empty(M->B1_COD),AC120Copia(nOpc),;
                        MsgInfo(STR0084))},STR0086,STR0086/*STR0104*/})//"Preencha o campo 'Cód. Produto'" / "Copiar dados de outro produto" / "Cópia"
      Endif
      // JPM - Fim
      
      If lCompEmb
         Aadd(aButtons,{"CONTAINR",{||nOpcA:=8,oDlg:End()},STR0016,STR0109}) //"Composicao de Embalagem - Produto " / "Embalag."
      EndIf

      /* Caso o ambiente possua todas as tabelas e campos necessários para a função de tabela de
         preços, carrega as duas works e adiciona botão 'Tabela de Preços' */
      If lEX5EX6

         /* by JBJ - 13/09/04 - Nova rotina para tabela de preços. */
         //aAdd(aButtons,{"PRECO",{|| AC120TabPreco(cAlias,nReg,nOpc)},STR0019}) //"Tabela de Preços"
         aAdd(aButtons,{"TABPRICE",{|| AC120TabPreco(cAlias,nReg,nOpc)},STR0019,STR0105}) //"Tabela de Preços" / "Preços"
         //aAdd(aButtons,{"PRECO",{|| AC120PPC(cALIAS,nREG,nOPC)},STR0019}) //"Tabela de Preços"

         // GRAVA OS DADOS P/ O TEMPORARIO TR5
         DBSELECTAREA("TR5")
         TR5->(avzap()) //ZAP
         EX5->(DBSETORDER(1))
         EX5->(DBSEEK(XFILIAL("EX5")+M->B1_COD))
         DO WHILE ! EX5->(EOF()) .AND.;
            EX5->(EX5_FILIAL+EX5_COD_I) = (XFILIAL("EX5")+M->B1_COD)
            TR5->(DBAPPEND())
            AVREPLACE("EX5","TR5")
            
            If lNovaRotina
               Do Case
                  Case Empty(TR5->EX5_DTINI) .And. Empty(TR5->EX5_DTFIM)
                       If TR5->EX5_PRECO > 0
                          TR5->TR5_STATUS := STR0028 //"Aguardando Aprovação"
                       Else
                          TR5->TR5_STATUS := STR0049 //"Sem Preço"
                       Endif
                       
                  Case !Empty(TR5->EX5_DTINI) .And. Empty(TR5->EX5_DTFIM)
                       if TR5->EX5_DTAPRO >= dDatabase 
                          TR5->TR5_STATUS := STR0082 + DtoC(TR5->EX5_DTINI) //"Ativo a partir de "
                       Else
                          TR5->TR5_STATUS := STR0029 //"Ativo"
                       Endif  
                       
                  Case !Empty(TR5->EX5_DTINI) .And. !Empty(TR5->EX5_DTFIM)
                       TR5->TR5_STATUS := If(dDataBase <= TR5->EX5_DTFIM,STR0029,STR0030) //"Ativo"###"Inativo"
               EndCase
            EndIf
            
            SYA->(DBSETORDER(1))
            SYA->(DBSEEK(XFILIAL("SYA")+EX5->EX5_PAIS))
            TR5->EX5_PAISDE := SYA->YA_DESCR
            TR5->TR5_RECNO  := EX5->(RECNO())
            TR5->TRB_ALI_WT := "EX5"
            TR5->TRB_REC_WT := EX5->(Recno())
            EX5->(DBSKIP())
         ENDDO
         // GRAVA OS DADOS P/ O TEMPORARIO TR6
         DBSELECTAREA("TR6")
         TR6->(avzap()) //ZAP
         EX6->(DBSETORDER(1))
         EX6->(DBSEEK(XFILIAL("EX6")+M->B1_COD))
         DO WHILE ! EX6->(EOF()) .AND.;
            EX6->(EX6_FILIAL+EX6_COD_I) = (XFILIAL("EX6")+M->B1_COD)
            If !Empty(EX6->EX6_DTFIM) .AND. EX6->EX6_DTAPRO < dDatabase  // GFP - 01/11/2013
               EX6->(DBSKIP())
               Loop
            EndIf
            TR6->(DBAPPEND())
            AVREPLACE("EX6","TR6")
            
            If lNovaRotina
               Do Case
                  Case Empty(TR6->EX6_DTINI) .And. Empty(TR6->EX6_DTFIM)
                       TR6->TR6_STATUS := STR0028 //"Aguardando Aprovação"

                  Case !Empty(TR6->EX6_DTINI) .And. Empty(TR6->EX6_DTFIM)
                       If TR6->EX6_DTAPRO >= dDatabase
                          TR6->TR6_STATUS := STR0082 + DtoC(TR6->EX6_DTINI) //"Ativo a partir de "
                       Else   
                          TR6->TR6_STATUS := STR0029 //"Ativo"
                       Endif
                       
                  Case !Empty(TR6->EX6_DTINI) .And. !Empty(TR6->EX6_DTFIM)
                       TR6->TR6_STATUS := If(dDataBase <= TR6->EX6_DTFIM,STR0029,STR0030) //"Ativo"###"Inativo"
               EndCase
            EndIf
            
            SYA->(DBSETORDER(1))
            SYA->(DBSEEK(XFILIAL("SYA")+EX6->EX6_PAIS))
            TR6->EX6_PAISDE := SYA->YA_DESCR

            If lNovaRotina
               SA1->(DbSetOrder(1))
               SA1->(DbSeek(xFilial("SA1")+EX6->EX6_CLIENT+EX6->EX6_CLLOJA))
               TR6->EX6_CLIEDE := SA1->A1_NOME
            EndIf

            TR6->TR6_RECNO := EX6->(RECNO())
            TR6->TRB_ALI_WT:= "EX6"
            TR6->TRB_REC_WT:= EX6->(Recno())
            EX6->(DBSKIP())
         ENDDO
      ENDIF
      
      DO While ( nOpca>=3 )
         *-----------------------------------------------------------------* //LRL 18/02/04
         If nModulo == 50 //DrawBack
            Aadd(aDrwBck,"B1_COD");         Aadd(aDrwBck,"B1_DESC")
            Aadd(aDrwBck,"B1_UM");          Aadd(aDrwBck,"B1_LOCPAD")
            Aadd(aDrwBck,"B1_MSBLQL");      Aadd(aDrwBck,"B1_PESO")
            Aadd(aDrwBck,"B1_FPCOD");       Aadd(aDrwBck,"B1_VLEEFUS")
            Aadd(aDrwBck,"B1_IMPORT");      Aadd(aDrwBck,"B1_ANUENTE")
            Aadd(aDrwBck,"B1_ESPECIF");     Aadd(aDrwBck,"B1_MAT_PRI")
            Aadd(aDrwBck,"B1_QTDSER");      Aadd(aDrwBck,"B1_POSIPI")
            Aadd(aDrwBck,"B1_EX_NCM");      Aadd(aDrwBck,"B1_EX_NBM")
            Aadd(aDrwBck,"B1_PICMRET");     Aadd(aDrwBck,"B1_PICMENT")
            Aadd(aDrwBck,"B1_CONTSOC");     Aadd(aDrwBck,"B1_REDINSS") ;  Aadd(aDrwBck,"B1_VLREFUS")
            Aadd(aDrwBck,"B1_REDIRRF");     Aadd(aDrwBck,"B1_TAB_IPI")
            Aadd(aDrwBck,"B1_REDPIS");      Aadd(aDrwBck,"B1_REDCOF")
            Aadd(aDrwBck,"B1_PCSLL");       Aadd(aDrwBck,"B1_PCOFINS")
            Aadd(aDrwBck,"B1_PPIS");        Aadd(aDrwBck,"B1_QTMIDIA")
            Aadd(aDrwBck,"B1_VLRSELO");     Aadd(aDrwBck,"B1_PIS")
            Aadd(aDrwBck,"B1_COFINS");      Aadd(aDrwBck,"B1_CSLL")
            Aadd(aDrwBck,"B1_QE");          Aadd(aDrwBck,"B1_FORPRZ")
            Aadd(aDrwBck,"B1_PE");          Aadd(aDrwBck,"B1_TIPE")
            Aadd(aDrwBck,"B1_EMAX");        Aadd(aDrwBck,"B1_CODEMB")
            Aadd(aDrwBck,"B1_NALNCCA");     Aadd(aDrwBck,"B1_ALADI")
            Aadd(aDrwBck,"B1_NALSH");       Aadd(aDrwBck,"B1_PESBRU")               //NCF - 24/09/2013 - Ajuste do campo de Peso Bruto no Array de definições
            Aadd(aDrwBck,"B1_LOTVEN")  
//            Aadd(aDrwBck,"B1_VLR_IPI");     Aadd(aDrwBck,"B1_VLR_ICM")            Alcir Alves - 25-05-05 - retirado deste campo conforme solicitação do help-desk
            If !lNormaProd //JPM - 15/01/05
               Aadd(aDrwBck,"B1_CODNOR")
            EndIf
            
            If !EYJ->(FieldPos("EYJ_LEADTI")) > 0   //LRS - 11/02/2014 - Validação para o lead time dentro da tabela EYJ
            	If SB1->(FieldPos("B1_LEADTI")) > 0
            		AAdd(aDrwBck, "B1_LEADTI")
            	EndIf 
            ENDIF
            
            If !EYJ->(FieldPos("EYJ_ESTSIM")) > 0  //LRS - 11/02/2014 - Validação para o lead time dentro da tabela EYJ
            	If SB1->(FieldPos("B1_ESTSIM")) > 0
            		AAdd(aDrwBck, "B1_ESTSIM")
            	EndIf
            EndIF

            For nI := 1 To Len(aDrwBck)
                If aScan(aCposEnchoice,{|x| Alltrim(x) == Alltrim(aDrwBck[nI])}) == 0
                    aAdd(aCposEnchoice,aDrwBck[nI])
                EndIf
            Next

         EndIf
         *---------------------------------------------------------------------------*
         
         aTela := {} // Claudia
         aGets := {} // Claudia
         nOpcA := 0  // by CAF 12/01/2005
         
         IF EasyEntryPoint("EECAC120")
            IF ! EXECBLOCK("EECAC120",.F.,.F.,{"ENCHOICE"})
               BREAK
            ENDIF
         ENDIF
         
         If EECFlags("INTTRA")
            aAdd(aButtons,{"BMPTABLE",{|| EYJMAN("EYJ",nReg,nOpc)},"Dados Complementares","D.Compl"}) //"Dados Complementares"### "D.Compl"
         EndIf

		//FSM - 08/12/11 - ExecAuto          
		If !lExecAuto
         
	         DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
	             
	             oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //LRS - 19/05/2015
                oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

	            oEnch1 := MsMGet():New(cAlias, nReg, nOpc, , , ,aCposEnchoice,PosDlgUp(oPanel),,,,,oPanel,,.T.)  // ACSJ - 18/03/2004
	            oEnch1:oBox:Align:= CONTROL_ALIGN_TOP
	            // MsSelect dos Idiomas ...
	            EE2Manut(nOpc,MC_CPRO,MO_MM,AC_MS,{oPanel,M->B1_COD})
	            oEnch1:oBox:Align :=  CONTROL_ALIGN_TOP                        //NCF - 28/05/2012 - Alinhamento da Odlg de Descrição
	         ACTIVATE MSDIALOG oDlg ON INIT Eval(&(bExec_Init))

		Else

			If lRet := EnchAuto(cAlias, aAutoCab, {|| Obrigatorio(aGets, aTela) }, nOpc, aCposEnchoice)
			   If Len(aAutoEE2) > 0
			      aEval(aAutoEE2, {|x| If(!lMsErroAuto, EE2Manut(nOpc,MC_CPRO,MO_MM,"EXECAUTO", x ), ) })
			   EndIf
			   If !lMsErroAuto
			      Eval(bVal_Ok)
			   Else
			      Eval(bCancel)
			   EndIf
			Else
			   Eval(bCancel)
			EndIf

		EndIf
		
         // FJH 21/02/06
         If nOpc <> EXCLUIR .and. nOpca == 0 .and. __lSX8
            RollBackSX8()         
         Endif
		
         Do Case
            Case nOpcA==0
                 SB1->(MSUnlock()) // By JPP - 18/04/2005 - 09:10 
            Case nOpcA==1
                Begin Transaction
				   
				   bGrava := {||lGravaOk:=AC120Grava(.T.,nOpcA)}
                   If !lExecAuto
				      Processa(bGrava)
				   Else
				      Eval(bGrava)
				   EndIf

                   If !lGravaOk
                      Help(" ",1,"A110NAORE")
                   Else
                      //Processa Gatilhos
					  
                      EvalTrigger()
					  
                      If __lSX8
                         ConfirmSX8()
                      Endif
                   EndIf
				   
                End Transaction
                
             Case nOpca==2                                                                                        
             
                 SB1->(dbgoto(nReg))  //soh p/confirmar
                 bProc := {||lGravaOk:=AC120Grava(.F.,nOpcA)}
  			     If !lExecAuto
					Processa(bProc)
				 Else
				    Eval(bProc)
				 EndIf
				 
             /* by CAF 31/07/2001 16:28 Nova Tabela de Normas    
             Case nOpcA == 7 // Browse de PaisxNormas
                 AC120Normas(cAlias,nReg,nOpc)
                 nOpcA := 7
             */                 
             Case nOpcA == 8 // Composicao de Embalagens
                 AC120CompEmb(cAlias,nReg,nOpc)
                 nOpcA := 8   
                                
         EndCase
      Enddo
      SB1->(DBSETORDER(1))
    
      // Fecha Work dos Idiomas ...
      EE2Manut(nOpc,MC_CPRO,MO_MM,AC_ER)

   End Sequence

   /* by CAF 31/07/2001 16:28 Nova Tabela de Normas   
   WkNor->(E_EraseArq(cNomArq2))
   */
   If lCompEmb //Deleta os arquivos temporarios da Composicao de embalagem.
      WkEmb->(E_EraseArq(cNomArq3,cNomArq5))
      WkPro->(E_EraseArq(cNomArq4))
   EndIf
   dbselectarea(cOldArea)
   
Return lRet
*--------------------------------------------------------------------

Function EYJMAN(cAlias, nReg, nOpc)
Local lRet := .t.
Local aPos := {}
Local bOk     := {|| oDlg:End()},;
      bCancel := {|| oDlg:End()}
Local oDlg

Private cTitulo:= AvTitCad(cAlias)
Private aTela[0][0],aGets[0]

Begin Sequence

   Define MsDialog oDlg Title cTitulo From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel
      aPos:= PosDlg(oDlg)
      EnChoice(cAlias,nReg,nOpc,,,,,aPos,)
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel)

End Sequence

Return lRet

/*
Funcao      : AC120MANE(nOpc)
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Excluir Registros
Autor       : Cristiano A. Ferreira
Data/Hora   : 10/06/1999 09:20
Revisao     :
Obs.        :
*/
Static Function AC120MANE(nOpc)
Local lRet:=.T.,cFilJF:=Xfilial("EE2")
Private lValExclusao := .T., lPergConf := .T.  // By JPP - 12/03/2007 - 14:20 - Inclusão de Ponto de Entrada, conforme solicitação de analista.

If EasyEntryPoint("EECAC120") // By JPP - 12/03/2007 - 14:20 - Inclusão de Ponto de Entrada, conforme solicitação de analista.
   ExecBlock("EECAC120",.f.,.f.,"ANTES_CONFIRMA_EXCLUSAO")
EndIf

If !lValExclusao // By JPP - 12/03/2007 - 14:20 - Inclusão de Ponto de Entrada, conforme solicitação de analista.
   Return .F.
EndIf

if lExecAuto .Or. !lPergConf .Or. Msgnoyes(OemtoAnsi(STR0007),Oemtoansi(STR0008)) //"Confirma ExclusÆo?"###"Aten‡Æo" //FSM - 08/12/11 - ExecAuto 
   BEGIN SEQUENCE
      SB1->(Reclock("SB1",.F.))

      lYesExclui:=.t.

      // Eliminar descricoes em outro idioma ...
      bProc := {|| EE2Manut(nOpc,MC_CPRO,MO_MM,AC_DE,{M->B1_COD}) }
	  If !lExecAuto
         Processa(bProc)
	  Else
	     Eval(bProc)
      EndIf
	  
      If EasyEntryPoint("EECAC120")
         ExecBlock("EECAC120",.f.,.f.,"PE_EXCLUSAO")
      EndIf

      If lCompEmb // Tambem exclui os conteudo da composicao de embalagem.
         EEV->(dbSetOrder(1))
         EEW->(dbSetOrder(1))
         EEV->(dbSeek(xFilial()+SB1->B1_COD))
         DO While EEV->(!Eof() .And. EEV_FILIAL==xFilial("EEV")) .And.;
            EEV->EEV_COD_I == SB1->B1_COD
            *
            EEW->(dbSeek(xFilial()+EEV->EEV_COD_I+EEV->EEV_SEQUEN))
            DO While EEW->(!Eof() .And. EEW_FILIAL==xFilial("EEW")) .And.;
               EEW->EEW_COD_I  == EEV->EEV_COD_I .And.;
               EEW->EEW_SEQUEN == EEV->EEV_SEQUEN
               *
               RECLOCK("EEW",.F.)
               EEW->(DBDELETE())
               EEW->(DBSKIP())
            Enddo    
            RECLOCK("EEV",.F.)
            EEV->(DBDELETE())
            EEV->(DBSKIP())
         Enddo    
      EndIf
      
      IF lEX5EX6
         // EXCLUI EX5
         EX5->(DBSETORDER(1))
         EX5->(DBSEEK(XFILIAL("EX5")+SB1->B1_COD))
         DO WHILE ! EX5->(EOF()) .AND.;
            EX5->(EX5_FILIAL+EX5_COD_I) = (XFILIAL("EX5")+SB1->B1_COD)
            *
            EX5->(RECLOCK("EX5",.F.))
            EX5->(DBDELETE())
            EX5->(DBSKIP())
         ENDDO
         // EXCLUI EX6
         EX6->(DBSETORDER(1))
         EX6->(DBSEEK(XFILIAL("EX6")+SB1->B1_COD))
         DO WHILE ! EX6->(EOF()) .AND.;
            EX6->(EX6_FILIAL+EX6_COD_I) = (XFILIAL("EX6")+SB1->B1_COD)
            *
            EX6->(RECLOCK("EX6",.F.))
            EX6->(DBDELETE())
            EX6->(DBSKIP())
         ENDDO
      ENDIF            
      
      // JPM - 13/12/04 - Exclui amarrações de normas
      If lNormaProd
         EXN->(DbSeek(cFilEXN+M->B1_COD))
         While EXN->(!EoF()) .And. cFilEXN == EXN->EXN_FILIAL .And. EXN->EXN_PROD == M->B1_COD
            EXN->(RecLock("EXN",.f.))
            EXN->(DbDelete())
            EXN->(DbSkip())
         EndDo
      EndIf
      
      //Deletando informações complementares do Produto (SIGAEIC/SIGAEDC/SIGAEEC) - Trade Easy
      If AVFLAGS("DADOS COMPL. PRODUTOS")
         EYJ->(DbSetOrder(1))
		 If EYJ->(DbSeek(xFilial("EYJ") + SB1->B1_COD))
		    If EYJ->(RecLock("EYJ",.F.))
		       EYJ->(DbDelete())
		    EYJ->(MsUnlock())
		    EndIf				   
		 EndIf
	  EndIf 
      
      SB1->(DBDELETE())
   END SEQUENCE
ENDIF
Return(lRet)
*--------------------------------------------------------------------
/*
Funcao      : AC120VALSF(nTipo,nRecno)
Parametros  : nTipo := INC_DET/VIS_DET/ALT_DET/EXC_DET
              nRecno:= n.registro
Retorno     : .T. / .F.
Objetivos   : validar/aceitar exclusao
Autor       : CRISTIANO A FERREIRA
Data/Hora   : 10/06/99 09:38
Revisao     :
Obs.        :
*/
/*
Static Function AC120VALSF(nTipo,nRecno)
   Local lRet:=.T.
   
   Begin Sequence
      IF nTipo == INC_DET .OR. nTipo = ALT_DET
         lRet:=Obrigatorio(aGets,aTela)
      /* by CAF 31/07/2001 16:28 Nova Tabela de Normas
      ElseIf nTipo == EXC_DET
         WkNor->(dbGoto(nRecno))
         IF MsgNoYes(STR0009,STR0010) //'Confirma Exclusão ?'###'Atenção'
            aAdd(aDeletados,WkNor->EEI_RECNO)
            WkNor->(dbDelete())
            WkNor->(dbSkip(-1))
            IF WkNor->(Bof())
               WkNor->(dbGoTop())
            Endif
         EndIf
      ///
      EndIf
   End sequence
   
Return lRet
*/
/*
Funcao      : AC120GRTRB()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Gravar TRB
Autor       : Cristiano A. Ferreira
Data/Hora   : 10/06/1999 09:39
Revisao     : Cristiano A. Ferreira
Obs.        : 14/01/2000 Gravacao do EEI
*/      
/* by CAF 31/07/2001 16:28 Nova Tabela de Normas
// by OSM 20/05/2002 11:52 Composicao de Embalagens */
Static Function AC120GRTRB()
//   Local aOrd := SaveOrd({"EEI"})
   Local lRet:=.T. //,cFilJF:=XFILIAL("EE2")
   
   Begin Sequence
      /* by OSM 20/05/2002 11:52 Composicao de Embalagens 
      EEI->(dbSetOrder(1))
      EEI->(dbSeek(xFilial()+SB1->B1_COD))
      
      While EEI->(!Eof() .And. EEI_FILIAL == xFilial("EEI")) .And.;
            EEI->EEI_COD_I == SB1->B1_COD
         
         WkNor->(dbAppend())
         AVReplace("EEI","WkNor")
         WkNor->EEI_RECNO  := EEI->(RecNo())
         WkNor->EEI_VM_NOR := MSMM(EEI->EEI_CDNO,AVSX3("EEI_VM_NOR",AV_TAMANHO))
         
         EEI->(dbSkip())
      Enddo
      
      WkNor->(dbGoTop())
      */
      If lCompEmb // Gravacao da Works da Composicao de Embalagens

         EEV->(dbSetOrder(1))
         EEW->(dbSetOrder(1))

         EEV->(dbSeek(xFilial("EEV")+SB1->B1_COD))
                  
         While EEV->(!Eof() .And. EEV_FILIAL == xFilial("EEV")) .And.;
               EEV->EEV_COD_I == SB1->B1_COD

            EEW->(dbSeek(xFilial("EEW")+EEV->EEV_COD_I+EEV->EEV_SEQUEN))

            While EEW->(!Eof() .And. EEW_FILIAL==xFilial("EEW")) .And.;
                  EEW->EEW_COD_I  == EEV->EEV_COD_I .And.;
                  EEW->EEW_SEQUEN == EEV->EEV_SEQUEN

               WkPro->(dbAppend())
               AVReplace("EEW","WkPro")
            
               EEW->(dbSkip())

            Enddo

            WkEmb->(dbAppend())
            AVReplace("EEV","WkEmb")
            WkEmb->EEV_RECNO  := EEV->(RecNo())         
            WkEmb->EEV_EMBALA := Posicione("EE5",1,xFilial("EE5")+EEV->EEV_CODEMB,"EE5_DESC")
           
            EEV->(dbSkip())
            
         Enddo                          
               
         WkEmb->(dbGoTop())
         WkPro->(dbGoTop())      

      EndIf          
  
   End Sequence
   
//   RestOrd(aOrd)

Return lRet

/*
Funcao      : AC120Grava(lGrava)
Parametros  : lGrava:= .T. - append blank
                       .F. - replace
Retorno     : .T.
Objetivos   : Gravar Header e mensagens
Autor       : Cristiano A. Ferreira
Data/Hora   : 10/06/1999 09:45
Revisao     :
Obs.        :
*/
Static Function AC120Grava(lGrava,nOpc)
LOCAL Z,i
Local lRet:=.T.
Local nInc
Local nOrdem 
Local aItem, aBkp
Local aObrigCamp // EJA - 06/09/2017 - Será o array com o nome dos campos obrigatórios.
Local cMsgErro:= ""
Private oModel
Private aMemos := {}  //AOM - 03/12/2010
   
   Begin Sequence
      
      IncProc(STR0011+Transf(M->B1_COD,AVSX3("B1_COD",AV_PICTURE))) //"Gravando Produto: "
      
      //Alcir Alves - 18-05-05 
      if EasyGParam("MV_ENVMAIL",,.F.)==.T. //Caso parametro para enviar e-mail        
         IF EasyGParam("MV_EEC_EDC",,.F.)==.T. //CASO EXISTA INTEGRAÇÃO DRAWBACK
            IndRegua("ED1", "ED10"+TEOrdBagExt(),"ED1_FILIAL+ED1_PROD")         
            IF ED1->(DBSEEK(XFILIAL("ED1")+AVKEY(SB1->B1_COD,"ED1_PROD")))          
               cedcMAIL:=""
               IF lAltDecri //DESCRICAO EM PORTUGUES MODIFICADO 
                  cedcMAIL+=STR0111+cDesPro1+STR0112+cDesPro2+chr(13)+chr(10)//"-Campo DESCRIÇÃO DA LI modificado de "###" para "
               ENDIF
               IF SB1->B1_POSIPI#M->B1_POSIPI  //modificaçao de NCM
                  cedcMAIL+=STR0113+SB1->B1_POSIPI+STR0112+M->B1_POSIPI+chr(13)+chr(10)//"-Campo NCM do produto modificado de "###" para "
               ENDIF
               IF SB1->B1_UM#M->B1_UM  //modificaçao de UNIDADE DE MEDIDA
                  cedcMAIL+=STR0114+SB1->B1_UM+STR0112+M->B1_UM+chr(13)+chr(10)//"Alteração do produto ("###" para "
               ENDIF
               cedcSubjc:=STR0115+SB1->B1_COD+STR0116//") na integração "###"Alterações encontradas:"
               If EasyEntryPoint("EECAC120")                       
                  ExecBlock("EECAC120",.F.,.F.,"PRODUTO_MODIFICADO_EMAIL")
               EndIf
               cedcBDM:=""
               IF !empty(cedcMAIL) //caso não esteja vazio quer dizer que houve modificação em no minimo algum item
                  cedcBDM:=STR0117+chr(13)+chr(10)+cedcMAIL//"-Campo UNIDADE DE MEDIDA do produto modificado de "
                  lenv:=EICINmail(NIL,NIL,cedcSubjc,cedcBDM,NIL,NIL,NIL)
               ENDIF
            ENDIF
         ENDIF      
      Endif    

      If EasyEntryPoint("EECAC120")                       
          ExecBlock("EECAC120",.F.,.F.,"PRE_GRAVACAO_SB1")
      EndIf

      
      //AOM - 03/12/2010 - Gravação do campo memo na SB1 para função E_GRAVA
      If SB1->(FieldPos("B1_CODPROC")) > 0
         AADD(aMemos,{"B1_CODPROC","B1_VM_PROC"})
      EndIf
      If TYPE("M->B1_VM_P") = "C"//AWF - 25/04/2014
         AADD(aMemos,{"B1_DESC_P","B1_VM_P"})
      EndIf
      
      //AAF 13/01/2017 - Atualiza pelo faturamento (MATA010) para gravar a descrição na tabela AIF, se atender as regras do faturamento
      If !lGrava .AND. IsIntFat()
      
         //Backup das variaveis de memoria para garantir que nao há interferencia do MATA010
         aBkp := {}
         SX3->(dbSetOrder(1),dbSeek("SB1"))
         Do While SX3->(!Eof() .AND. X3_ARQUIVO == "SB1")
            If Type("M->"+SX3->X3_CAMPO) <> "U"
               aAdd(aBkp,{SX3->X3_CAMPO,&("M->"+SX3->X3_CAMPO)})
            EndIf
            SX3->(dbSkip())
         EndDo
         
         aItem := {}
		   aAdd(aItem,{"B1_COD"         ,M->B1_COD ,NIL})
		   aAdd(aItem,{"B1_DESC"        ,M->B1_DESC,NIL})

         // EJA - 06/09/2017 - Campos obrigatórios que não estavam sendo enviados na alteração.

         aObrigCamp := EasyGetObrig("SB1",.T.,.T.)

         For i := 1 To Len(aObrigCamp)
            If !(Alltrim(aObrigCamp[i]) $ "B1_COD|B1_DESC")
                aAdd(aItem, {aObrigCamp[i], M->&(aObrigCamp[i]), Nil})
            EndIf
         End 

         Private lMsErroAuto := .F.
         dbselectArea("SB1")
         oModel := FwLoadModel("MATA010")

         FWMVCRotAuto( oModel,"SB1",MODEL_OPERATION_UPDATE,{{"SB1MASTER", aItem}},, .T.) //sexto parâmetro para posicionar no registro
            
         If lMsErroAuto
            cMsgErro:= oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE] //MODEL_MSGERR_MESSAGE = 6
            EasyHelp(cMsgErro)
            lRet := .F.
            Break
         EndIf
         oModel:Destroy()

         //Volta o backup das variaveis de memoria
         For i := 1 To Len(aBkp)
            &("M->"+aBkp[i][1]) := aBkp[i][2]
         Next i
         
      Endif
      
      E_Grava("SB1",lGrava)
      
      //ER - 14/08/2007 - Gravação dos Dados Complementares
      If EECFLAGS("INTTRA")
         EYJ->(DbSetOrder(1))
         If EYJ->(DbSeek(xFilial("EYJ")+M->B1_COD))
            
            EYJ->(RecLock("EYJ",.F.))
              
            AvReplace("M","EYJ")
           
         Else
              
            EYJ->(RecLock("EYJ",.T.))
              
            AvReplace("M","EYJ")
            EYJ->EYJ_FILIAL := xFilial("EYJ")
            EYJ->EYJ_COD    := M->B1_COD
   
         EndIf
         
         If !lGrava
            MSMM(M->EYJ_CCOMPE,,,,EXCMEMO)
         EndIf
        
         MSMM(,AVSX3("EYJ_COMPER" ,AV_TAMANHO),,M->EYJ_COMPER ,INCMEMO,,,"EYJ","EYJ_CCOMPE")

         EYJ->(MsUnlock())
      EndIf

      If lCompEmb // Gravacao da Composicao de Embalagem.
         nOrdem := 0  
         
         //JPM - deletando dados sobrescritos pela copia de dados complementares
         EEV->(DbSetOrder(2))
         For i:= 1 to len(aDeleteEEV)
               If EEV->(DbSeek(aDeleteEEV[i]))
               RecLock("EEV",.f.)
               EEV->(DbDelete())
            Endif
         Next     
         
         EEW->(DbSetOrder(1))
         For i:= 1 to len(aDeleteEEW)
               If EEW->(DbSeek(aDeleteEEW[i]))
               RecLock("EEW",.f.)
               EEW->(DbDelete())
            Endif
         Next                                                                
         //JPM - fim
         
         WkEmb->(dbGoTop())
         While !WkEmb->(EOF())
            
            If !lGrava .AND. WkEmb->EEV_RECNO <> 0
               EEV->(dbGoTo(WkEmb->EEV_RECNO))
               RecLock("EEV",.F.)

               If WkEmb->DBDELETE
                  EEV->(dbDelete())
                  EEV->(MsUnlock())
                  WkEmb->(dbSkip())
                  Loop
               EndIf

            Else
                RecLock("EEV",.T.)
            EndIf

            If !WkEmb->DBDELETE
               nOrdem++
               AvReplace("WkEmb","EEV")
               EEV->EEV_ORDEM  := StrZero(nOrdem,AvSx3("EEV_ORDEM",AV_TAMANHO))
               EEV->EEV_COD_I  := SB1->B1_COD
               EEV->EEV_FILIAL := xFilial("EEV")
               EEV->(MsUnlock())
            EndIf   

            WkEmb->(dbSkip())

         EndDo

         bExec  := {|| RecLock("EEW",.f.),dbDelete(),MsUnlock() }
         bWhile := {|| EEW_FILIAL == xFilial("EEW") .And. ;
                       EEW_COD_I  == SB1->B1_COD  }           

         EEW->(dbSeek(xFilial("EEW")+SB1->B1_COD))                          
         EEW->(dbEval(bExec,,bWhile))            

         WkPro->(dbGoTop())
         While !WkPro->(EOF())
            
            RecLock("EEW",.T.)

            AvReplace("WkPro","EEW")
            EEW->EEW_COD_I := SB1->B1_COD
            EEW->EEW_FILIAL:= xFilial("EEW")
            EEW->(MsUnlock())

            WkPro->(dbSkip())

         EndDo
      
      EndIf 
      
      // JPM - 14/12/04 - Tratamentos para Copia de Dados Complementares - Deleta os dados que foram substituídos
      //                  "na mão"(ou seja, sem a utilização do EE2Manut) 
      If nOpc == 2
         for i = 1 to len(aDeleteEE2)
            EE2->(DbGoTo(aDeleteEE2[i]))
            RecLock("EE2",.f.)
            EE2->(DbDelete())
         Next
      Endif
      // Gravar descricoes em outro idioma ...
      EE2Manut(nOpc,MC_CPRO,MO_MM,AC_GR,{M->B1_COD})
      
      IF lEX5EX6
         // EXCLUI DO EX5
         FOR Z := 1 TO LEN(aDELEX5)
             EX5->(DBGOTO(aDELEX5[Z]))
             EX5->(RECLOCK("EX5",.F.))
             EX5->(DBDELETE())
         NEXT
         // EXCLUI DO EX6
         FOR Z := 1 TO LEN(aDELEX6)
             EX6->(DBGOTO(aDELEX6[Z]))
             EX6->(RECLOCK("EX6",.F.))
             EX6->(DBDELETE())
         NEXT
         // GRAVA O TR5 NO EX5
         TR5->(DBGOTOP())
         DO WHILE ! TR5->(EOF())
            IF ! EMPTY(TR5->TR5_RECNO)
               EX5->(DBGOTO(TR5->TR5_RECNO))
               EX5->(RECLOCK("EX5",.F.))
            ELSE
               EX5->(RECLOCK("EX5",.T.))
               //AMS - 16/10/2003 às 10:38
               EX5->EX5_FILIAL := xFilial( "EX5" )
            ENDIF
            AVREPLACE("TR5","EX5")
            TR5->(DBSKIP())
         ENDDO
         // GRAVA O TR6 NO EX6
         TR6->(DBCLEARFILTER())
         TR6->(DBGOTOP())
         DO WHILE ! TR6->(EOF())
            IF ! EMPTY(TR6->TR6_RECNO)
               EX6->(DBGOTO(TR6->TR6_RECNO))
               EX6->(RECLOCK("EX6",.F.))
            ELSE
               EX6->(RECLOCK("EX6",.T.))
               //AMS - 16/10/2003 às 10:38
               EX6->EX6_FILIAL := xFilial( "EX5" )
            ENDIF
            AVREPLACE("TR6","EX6")
            TR6->(DBSKIP())
         ENDDO
      ENDIF
      
      // JPM - 13/12/04 - gravar amarração Produtos x Países x Normas
      If lNormaProd
         
         If nOpc == 2
            for i := 1 to len(aNorDelete)                                                                                
               If EXN->(DbSeek(cFilEXN+M->B1_COD+AvKey(aNorDelete[i][1],"EXN_PAIS")+AvKey(aNorDelete[i][3],"EXN_NORMA")))         
                  EXN->(RecLock("EXN",.f.))
                  EXN->(DbDelete())
               Endif                   
            Next
         Endif
         
         If nOpc == 1 .or. nOpc == 2 
         
            For i := 1 to len(aColsNor)
               If nOpc == 1                         
            
                  EXN->(RecLock("EXN",.t.))    
                  EXN->EXN_FILIAL := cFilEXN
                  EXN->EXN_PROD   := M->B1_COD
                  EXN->EXN_PAIS   := aColsNor[i][1]
                  EXN->EXN_NORMA  := aColsNor[i][3]
                  
               ElseIf nOpc == 2                                    
               
                  If !EXN->(DbSeek(cFilEXN+M->B1_COD+AvKey(aColsNor[i][1],"EXN_PAIS")+AvKey(aColsNor[i][3],"EXN_NORMA")))
                     EXN->(RecLock("EXN",.t.)) 
                     EXN->EXN_FILIAL := cFilEXN
                     EXN->EXN_PROD   := M->B1_COD
                     EXN->EXN_PAIS   := aColsNor[i][1]
                     EXN->EXN_NORMA  := aColsNor[i][3] 
                  Endif
                  
               Endif      
            Next
         EndIf         
      EndIf

      If EasyEntryPoint("EECAC120")
         ExecBlock("EECAC120",.f.,.f.,{"PE_GRVFINAL",nOpcRotina})
      EndIf

   End Sequence

Return lRet

/*
Funcao      : AC120Normas
Parametros  : cAlias,nOpc,nReg
Retorno     : Nenhum
Objetivos   : Manutencao de ProdutosXPaisXNormas
Autor       : Cristiano A. Ferreira
Data/Hora   : 14/01/2000 10:17
Revisao     :
Obs.        :
*/      
/* by CAF 31/07/2001 16:28 Nova Tabela de Normas
Static Function AC120Normas(cAlias,nReg,nOpc)

Local oBrw
Local oDlg // claudia
Local bOk     := {|| nOpcA:=1,oDlg:End() }
Local bCancel := {|| oDlg:End() }
Private aTela:= {}  // Claudia
Private aGets:= {}  // Claudia
Private aHeader := {} // Claudia
Begin Sequence

   WkNor->(dbGoTop())
      
   While .t.
      nOpcA := 0
      aTela := {}
      aGets := {}
      
      DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
      
         EnChoice( cAlias, nReg, nOpc, , , , ,PosDlgUp(oDlg))
          
         oBrw:=MsSelect():New("WkNor",,,aCampoEEI,,,PosDlgDown(oDlg))
         oBrw:bAval := {|| IF(Str(nOpc,1) $ Str(VISUALIZAR,1)+"/"+Str(EXCLUIR,1),AC120EEIMAN(VIS_DET,oBrw),AC120EEIMAN(ALT_DET,oBrw)) }

      ACTIVATE MSDIALOG oDlg ON INIT AVBar(nOpc,oDlg,bOk,bCancel,ENCH_ADD,{|opc| AC120EEIMAN(opc,oBrw)})

      IF nOpcA == 1 .Or. nOpcA == 0
         Exit
      Endif
   Enddo

End Sequence

Return NIL
*/
/*
Funcao      : AC120EEIMAN(nTipo)
Parametros  : nTipo := VIS_DET/INC_DET/ALT_DET/EXC_DET
Retorno     : .T. 
Objetivos   : Permitir manutencao de Produto X Pais X Normas
Autor       : Cristiano A. Ferreira
Data/Hora   : 14/01/2000 10:49
Revisao     :
Obs.        :
*/        
/* by CAF 31/07/2001 16:28 Nova Tabela de Normas
Static Function AC120EEIMAN(nTipo,oBrw)
   Local nAreaOld := Select()
   Local lRet:=.T.,oDlg,nInc,nOpcA:=0,cNewtit
   Local nReg,cField
   
   Private aTela[0][0],aGets[0],nUsado:=0
   
   Begin Sequence
       
      IF nTipo # INC_DET .and. WkNor->(EOF() .AND. BOF())
         Help(" ",1,"AVG0000065")
         Break
      EndIf
      
      IF nTipo == INC_DET
         For nInc := 1 TO WkNor->(FCount())
            cField := WkNor->(FieldName(nInc))
            IF cField = "DELETE" .Or. cField = "EEI_RECNO"
               Loop
            Endif
            M->&(cField) := CriaVar(cField)
         Next nInc
         
         M->EEI_COD_I := M->B1_COD
      Else
         For nInc := 1 TO WkNor->(FCount())
             M->&(WkNor->(FIELDNAME(nInc))) := WkNor->(FIELDGET(nInc))
         Next nInc
      Endif
      
      nReg := WkNor->(RECNO())
      cNewTit:=STR0012 //"Produto X Pais X Normas"
      
      DEFINE MSDIALOG oDlg TITLE cNewTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
          
         EnChoice( "EEI", , 3, , , ,, PosDlg(oDlg),IF(Str(nTipo,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},) , 3 )

      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpcA:=1,IF(AC120VALSF(nTipo,nReg),oDlg:End(),nOpcA:=0)},{||oDlg:End()}),;
         IF(nTipo <> INC_DET,M->EEI_VM_NOR := WkNor->EEI_VM_NOR,M->EEI_VM_NOR:=''),lREFRESH:=.T.)
         
      If nOpcA # 0
         If nTipo = INC_DET
            WkNor->(DBAPPEND())
         Else
            WkNor->(DBGOTO(nReg))
         Endif
          
         If ! Str(nTipo,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1)
            AvReplace("M","WkNor")
         Endif
         
         oBrw:oBrowse:Refresh()
      EndIf
   End Sequence
   
   Select(nAreaOld) // Enchoice muda a area
   
Return lRet


/*
Funcao      : AC120CompEmb
Parametros  : cAlias,nOpc,nReg
Retorno     : Nenhum
Objetivos   : Composicao de Embalagens 
Autor       : Osman Medeiros Jr. (OMJ)
Data/Hora   : 15/05/2002 15:00
Revisao     :
Obs.        :
*/
Static Function AC120CompEmb(cAlias,nReg,nOpc)

Local oBrw
Local oDlg 
Local oGet
Local aPosGet
Local aRotOld
Local nOpcA
Local nPos
Local bOk     := {|| nOpcA:=1,oDlg:End() }
Local bCancel := {|| nOpcA:=0,oDlg:End() }
Local aButtons:={}

Local bMoveUP   := {|| AC120Move("U",oGet) }
Local bMoveDown := {|| AC120Move("D",oGet) }

Private aHeader := {}
Private aCampos := Array(0)
Private nColPos
Private aTela:= {}  
Private aGets:= {}  

Begin Sequence
   
   AC120GeraCol("EEV")
   nColPos := 1
   
   // FDR - 05/11/10 - Carregando o aHeader com campos criado pelo usuário
   aHeader := AddCpoUser(aHeader,"EEV","4")

   Aadd(aButtons,{/*"VCUP"*/"PMSSETAUP", bMoveUP   ,STR0013,STR0106  }) //"Move para Cima" / "Sobe"
   Aadd(aButtons,{/*"VCDOWN"*/"PMSSETADOWN", bMoveDown ,STR0014,STR0107  }) //"Move para Baixo" / "Desce"
   Aadd(aButtons,{"FOLDER6",{|| AC120ProEmb(cAlias,nReg,nOpc)},STR0015,STR0108}) //"Produtos na Embalagem" / "Produtos"

   nPos := nOpc
   If WkEmb->(EasyRecCount("WkEmb")) > 0 .And. nPos = INCLUIR
      nPos := ALTERAR   
   ElseIf WkEmb->(EasyRecCount("WkEmb")) == 0 .And. nPos = ALTERAR
      nPos := INCLUIR
   EndIf  
   
   If nPos = VISUALIZAR .or. nPos = EXCLUIR
      If WkEmb->(Eof()) .And. WkEmb->(Bof()) 
         WkEmb->(dbAppend())
      EndIf     
   EndIf
         
   While .t.

      nOpcA := 0
      
      dbSelectArea("WkEmb")
      WkEmb->(dbSetOrder(0))   // ACSJ - 18/06/2004 - Alterações necessarias para o funcionamento correto da função
                               // MSGetDb - Não pode ter ordem ativa na versão 811
//      WkEmb->(dbGoTop()) 
      
      DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
      
         EnChoice( cAlias, nReg, nOpc, , , , ,PosDlgUp(oDlg))
         
         aPosGet := PosDlgDown(oDlg)                
         WkEmb->(oGet:=MsGetDB():New(aPosGet[1],aPosGet[2],aPosGet[3],aPosGet[4],nPos,;
                                      "AC120LinOk('EEV')","","",.T.,,,.F.,,"WkEmb"))
         oGet:oBrowse:bwhen:={||(dbSelectArea("WkEmb"),.t.)}
         oGet:ForceRefresh()

      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

      IF nOpcA == 1 .Or. nOpcA == 0
         Break
      Endif

   Enddo

End Sequence

Return Nil


/*
Funcao      : AC120GeraCol
Parametros  : cAlias
Retorno     : Nenhum
Objetivos   : Grava nCol e aHeader do IW_MultiLine
Autor       : Osman Medeiros Jr. (OMJ)
Data/Hora   : 15/05/2002 16:20
Revisao     :
Obs.        :
*/
Static Function AC120GeraCol(cAlias)


SX3->(dbSetOrder(2))
Do Case
   Case cAlias == "EEV"
   
      If SX3->(dbSeek("EEV_ORDEM"))
         SX3->(Aadd(aHeader,{Trim(X3Titulo()),x3_Campo,x3_picture,x3_tamanho,x3_decimal,x3_valid,x3_usado,x3_tipo,x3_arquivo,x3_context}))
      EndIf
      If SX3->(dbSeek("EEV_CODEMB"))
         SX3->(Aadd(aHeader,{Trim(X3Titulo()),x3_Campo,x3_picture,x3_tamanho,x3_decimal,x3_valid,x3_usado,x3_tipo,x3_arquivo,x3_context}))
      EndIf
      If SX3->(dbSeek("EEV_EMBALA"))
         SX3->(Aadd(aHeader,{Trim(X3Titulo()),x3_Campo,x3_picture,x3_tamanho,x3_decimal,x3_valid,x3_usado,x3_tipo,x3_arquivo,x3_context}))
      EndIf
      If SX3->(dbSeek("EEV_DIMENS"))
         SX3->(Aadd(aHeader,{Trim(X3Titulo()),x3_Campo,x3_picture,x3_tamanho,x3_decimal,x3_valid,x3_usado,x3_tipo,x3_arquivo,x3_context}))
      EndIf
      If SX3->(dbSeek("EEV_PESBRU"))
         SX3->(Aadd(aHeader,{Trim(X3Titulo()),x3_Campo,x3_picture,x3_tamanho,x3_decimal,x3_valid,x3_usado,x3_tipo,x3_arquivo,x3_context}))
      EndIf
      If SX3->(dbSeek("EEV_SEQUEN"))
         SX3->(Aadd(aHeader,{Trim(X3Titulo()),x3_Campo,x3_picture,x3_tamanho,x3_decimal,x3_valid,x3_usado,x3_tipo,x3_arquivo,x3_context}))
      EndIf

   Case cAlias == "EEW"

      If SX3->(dbSeek("EEW_PROEMB"))
         SX3->(Aadd(aHeader,{Trim(X3Titulo()),x3_Campo,x3_picture,x3_tamanho,x3_decimal,x3_valid,x3_usado,x3_tipo,x3_arquivo,x3_context}))
      EndIf
      If SX3->(dbSeek("EEW_DESC"))
         SX3->(Aadd(aHeader,{Trim(X3Titulo()),x3_Campo,x3_picture,x3_tamanho,x3_decimal,x3_valid,x3_usado,x3_tipo,x3_arquivo,x3_context}))
      EndIf
      If SX3->(dbSeek("EEW_QTDE"))
         SX3->(Aadd(aHeader,{Trim(X3Titulo()),x3_Campo,x3_picture,x3_tamanho,x3_decimal,x3_valid,x3_usado,x3_tipo,x3_arquivo,x3_context}))
      EndIf
      
      If WkPro->(dbSeek(WkEmb->EEV_SEQUEN))

         Do While !WkPro->(Eof()) .And.;
                  WkPro->EEW_SEQUEN = WkEmb->EEV_SEQUEN
            
            nRecSB1 := SB1->(RecNo())
            Aadd(aCols,Array(04))
            aCols[Len(aCols),01] := WkPro->EEW_PROEMB
            aCols[Len(aCols),02] := Posicione("SB1",1,xFilial("SB1")+WkPro->EEW_PROEMB,"B1_DESC")
            aCols[Len(aCols),03] := WkPro->EEW_QTDE         
            //aCols[Len(aCols),04] := .F.
            aCols[Len(aCols),04] := WkPro->DBDELETE
            SB1->(dbGoTo(nRecSB1))
         
            WkPro->(dbSkip())
         
         EndDo
      
      Else

         Aadd(aCols,Array(04))
         aCols[Len(aCols),01] := Space(Len(EEW->EEW_PROEMB))
         aCols[Len(aCols),02] := Space(Len(SB1->B1_DESC))
         aCols[Len(aCols),03] := 0
         aCols[Len(aCols),04] := .f.

      EndIf

End Case

Return Nil

/*
Funcao      : AC120LinOk
Parametros  : 
Retorno     : lRet
Objetivos   : Consistencia da Composicao de Embalagem
Autor       : Osman Medeiros Jr. (OMJ)
Data/Hora   : 15/05/2002 16:20
Revisao     :
Obs.        :
*/

Function AC120LinOk(cAlias)
Local lRet := .T.
Local bRegBranco
Local cItem := ""
Local nInc
   
Do Case

   Case cAlias == "EEV"
      
      bRegBranco:={|| Empty(EEV_CODEMB) } 
      
      If WkEmb->DBDELETE
         Return lRet
      EndIf

      If WkEmb->(Eval(bRegBranco))
         Help(" ",1,"OBRIGAT")
        lRet := .F.
      EndIf

   Case cAlias == "EEW"

      bRegBranco:={|| Empty(aCols[n][1]) } 
      
      If aCols[n][4]
         Return lRet
      EndIf

      If WkPro->(Eval(bRegBranco))
         Help(" ",1,"OBRIGAT")
         lRet := .F.
      EndIf

	  cItem := aCols[n][1]
      
      //TRP-19/09/07
      For nInc := 1 to Len(aCols)
         If nInc <> n
            If aCols[nInc][1] == cItem
               MsgStop("Item já existe nesta embalagem!")
               lRet := .F.
            EndIf
         EndIf
      Next
End Case

Return lRet

/*
Funcao      : AC120Rela
Parametros  : 
Retorno     : cRelacao
Objetivos   : Execultada no X3_RELACAO
Autor       : Osman Medeiros Jr. (OMJ)
Data/Hora   : 16/05/2002 10:47
Revisao     :
Obs.        :
*/

Function AC120Rela(cCampo)
Local cRelacao := "" 
LocaL nOrdem, nRec

Begin Sequence   
   
   Do Case
      
      Case cCampo == "EEV_ORDEM"
         
         nOrdem   := WkEmb->(EasyRecCount("WkEmb"))
         cRelacao := StrZero(nOrdem,AvSx3("EEV_ORDEM",AV_TAMANHO))
                                                          
      Case cCampo == "EEV_SEQUEN"                         
      
         nRec     := WkEmb->(Recno())                 
                
         WkEmb->(dbSetOrder(2))        

         WkEmb->(dbGoBottom())                 
         nOrdem   := Val(WkEmb->EEV_SEQUEN) + 1

         WkEmb->(dbSetOrder(0))// ACSJ - 18/06/2004 - Alterações necessarias para o funcionamento correto da função
                               // MSGetDb - Não pode ter ordem ativa na versão 811         
         WkEmb->(dbGoTo(nRec)) 
           
         cRelacao := StrZero(nOrdem,AvSx3("EEV_SEQUEN",AV_TAMANHO))
               
   EndCase      
      
End Sequence

Return cRelacao


/*
Funcao      : AC120Move(oBrw)
Parametros  : cTipo ( "U" to UP, "D" to Down ) 
              oBrw 
Retorno     : NIL
Objetivos   : Move registro para cima ou para Baixo
Autor       : Osman Medeiros
Data/Hora   : 17/05/2002 14:30
Revisao     :
Obs.        :
*/
Static Function AC120Move(cTipo,oBrw)

Local nRec := WkEmb->(RecNo())
Local cCodEmb,cEmbala,cDimens,nPesBru,cSequen
Local cCodOld,cEmbOld,cDimOld,nPesOld,cSeqOld
    
Begin Sequence

   If WkEmb->DBDELETE         
      Break
   EndIf
   
   If cTipo == "U"

      cCodOld  := WkEmb->EEV_CODEMB
      cEmbOld  := WkEmb->EEV_EMBALA
      cDimOld  := WkEmb->EEV_DIMENS
      nPesOld  := WkEmb->EEV_PESBRU
      cSeqOld  := WkEmb->EEV_SEQUEN
      cRecnOld := WkEmb->EEV_RECNO
      
      WkEmb->(dbSkip(-1))   

      While !WkEmb->(Bof())
         If WkEmb->DBDELETE         
            WkEmb->(dbSkip(-1))   
         Else
            Exit
         EndIf      
      EndDo   

      If WkEmb->(Bof()) 
         WkEmb->(dbGoTo(nRec))
         Break
      Endif             

      cCodEmb := WkEmb->EEV_CODEMB
      cEmbala := WkEmb->EEV_EMBALA
      cDimens := WkEmb->EEV_DIMENS
      nPesBru := WkEmb->EEV_PESBRU
      cSequen := WkEmb->EEV_SEQUEN
      cRecno  := WkEmb->EEV_RECNO

      WkEmb->EEV_CODEMB := cCodOld
      WkEmb->EEV_EMBALA := cEmbOld
      WkEmb->EEV_DIMENS := cDimOld
      WkEmb->EEV_PESBRU := nPesOld
      WkEmb->EEV_SEQUEN := cSeqOld
      WkEmb->EEV_RECNO  := cRecnOld
      
      WkEmb->(dbGoTo(nRec))

      WkEmb->EEV_CODEMB := cCodEmb
      WkEmb->EEV_EMBALA := cEmbala
      WkEmb->EEV_DIMENS := cDimens
      WkEmb->EEV_PESBRU := nPesBru
      WkEmb->EEV_SEQUEN := cSequen
      WkEmb->EEV_RECNO  := cRecno

      WkEmb->(dbGoTo(nRec-1))

   ElseIf cTipo == "D"

      cCodOld  := WkEmb->EEV_CODEMB
      cEmbOld  := WkEmb->EEV_EMBALA
      cDimOld  := WkEmb->EEV_DIMENS
      nPesOld  := WkEmb->EEV_PESBRU
      cSeqOld  := WkEmb->EEV_SEQUEN
      cRecnOld := WkEmb->EEV_RECNO
      
      WkEmb->(dbSkip())   

      While !WkEmb->(Eof())
         If WkEmb->DBDELETE         
            WkEmb->(dbSkip())   
         Else
            Exit
         EndIf      
      EndDo   

      IF WkEmb->(Eof())
         WkEmb->(dbGoTo(nRec))
         Break
      Endif

      cCodEmb := WkEmb->EEV_CODEMB
      cEmbala := WkEmb->EEV_EMBALA
      cDimens := WkEmb->EEV_DIMENS
      nPesBru := WkEmb->EEV_PESBRU
      cSequen := WkEmb->EEV_SEQUEN
      cRecno  := WkEmb->EEV_RECNO

      WkEmb->EEV_CODEMB := cCodOld
      WkEmb->EEV_EMBALA := cEmbOld
      WkEmb->EEV_DIMENS := cDimOld
      WkEmb->EEV_PESBRU := nPesOld
      WkEmb->EEV_SEQUEN := cSeqOld
      WkEmb->EEV_RECNO  := cRecnOld
      
      WkEmb->(dbGoTo(nRec))

      WkEmb->EEV_CODEMB := cCodEmb
      WkEmb->EEV_EMBALA := cEmbala
      WkEmb->EEV_DIMENS := cDimens
      WkEmb->EEV_PESBRU := nPesBru
      WkEmb->EEV_SEQUEN := cSequen
      WkEmb->EEV_RECNO  := cRecno

      WkEmb->(dbGoTo(nRec+1))

   EndIf
      
   oBrw:oBrowse:Refresh()
   oBrw:Refresh()
   oBrw:ForceRefresh()
   
End Sequence

Return NIL

/*
Funcao      : AC120ProEmb()
Parametros  : 
Retorno     : NIL
Objetivos   : Controle de Produtos dentro da Embalagens
Autor       : Osman Medeiros
Data/Hora   : 18/05/2002 11:05
Revisao     :
Obs.        :
*/
Static Function AC120ProEmb(cAlias,nReg,nOpc)

Local oBrw
Local oDlg 
Local oGet2
Local aPosGet
Local aRotOld
Local nPos, nInd:=0, nI:=0
Local nOpcA
Local bOk     := {|| nOpcA:=1,oDlg:End() }
Local bCancel := {|| nOpcA:=0,oDlg:End() }
Local cCadastro := STR0016 + AllTrim(M->B1_COD)  //"Composicao de Embalagem - Produto "
Local aEnchoice := {"EEV_ORDEM","EEV_CODEMB","EEV_EMBALA","EEV_PESBRU","EEV_DIMENS"}

Private aHeader := {}
Private aCampos := Array(0)
Private nColPos
Private aTela:={},aGets:={}  
Private aCols:={}

Begin Sequence
   
   If Empty(WkEmb->EEV_EMBALA) .Or. WkEmb->(EasyRecCount("WkEmb")) == 0 .Or. WkEmb->DBDELETE
      Break
   EndIf

   AC120GeraCol("EEW")

   nColPos := 1

   nPos := nOpc
   If WkPro->(EasyRecCount("WkPro")) > 0 .And. nPos = INCLUIR
      nPos := ALTERAR   
   ElseIf WkPro->(EasyRecCount("WkPro")) == 0 .And. nPos = ALTERAR
      nPos := INCLUIR
   EndIf  

/*    M->EEV_ORDEM  := WkEmb->EEV_ORDEM
   M->EEV_CODEMB := WkEmb->EEV_CODEMB
   M->EEV_EMBALA := WkEmb->EEV_EMBALA
   M->EEV_PESBRU := WkEmb->EEV_PESBRU
   M->EEV_DIMENS := WkEmb->EEV_DIMENS
   M->EEV_TESTE  := WkEmb->EEV_TESTE*/
  
   //FDR
   For nInd:=1 To WkEmb->(Fcount())
      M->&(WkEmb->(FieldName(nInd))) := WkEmb->(FieldGet(nInd))
   Next
   
   
   While .t.

      nOpcA := 0
                                                        
    //OAP 22/10/2010 - Inclusão de um campo que venha a ser criado pelo usuário
    aEnchoice := AddCpoUser(aEnchoice,"EEV","1") 
            
      DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

         EnChoice( "EEV", ,3, , , ,aEnchoice,PosDlgUp(oDlg),{},3)       
          
         aPosGet := PosDlgDown(oDlg)                
         oGet2:=MsGetDados():New(aPosGet[1],aPosGet[2],aPosGet[3],aPosGet[4],nPos,"AC120LinOk('EEW')","","",.T.,,,.F.,,)
         oGet2:ForceRefresh()

      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel)

      If nOpcA == 1 .Or. nOpcA == 0

         If nOpcA == 1

            WkPro->(dbSeek(WkEmb->EEV_SEQUEN))                                                        
            WkPro->(dbEval(  {|| RecLock("WkPro",.f.),dbDelete(),MsUnlock()} ,, {|| EEW_SEQUEN == WkEmb->EEV_SEQUEN } ))            
            For nInd := 1 to Len(aCols)  
               If !aCols[nInd][4] .And. !Empty(aCols[nInd][1])
                                                                               
                  WkPro->(dbAppend())
                  WkPro->EEW_SEQUEN := WkEmb->EEV_SEQUEN
                  WkPro->EEW_PROEMB := aCols[nInd][1]
                  WkPro->EEW_QTDE   := aCols[nInd][3]
               
               EndIf   
            Next 

         EndIf        

         Exit

      Endif

   Enddo

End Sequence

Return Nil
*--------------------------------------------------------------------
/*
STATIC FUNCTION AC120PPC(cP_ALIAS,nP_REG,nP_OPC)
// CADASTRO DA RELACAO DE PRODUTO x PAIS x CLIENTE
LOCAL oDLG,oMSELECT,bOK,bCANCEL,nBTOP,aBUTTONS,cTITULO,aPOS,lBTALT
PRIVATE aCAMPOTR5,lINVERTE,cMARCA
*
lBTALT    := .F.
cTITULO   := STR0020  //"Tabela de Preços - Produtos X Países"
aCAMPOTR5 := ARRAYBROWSE("EX5","TR5")
lINVERTE  := .F.
cMARCA    := GETMARK()
aBUTTONS  := {}
bOK       := {|| nBTOP := 1,oDLG:END()}
bCANCEL   := {|| nBTOP := 0,oDLG:END()}
nBTOP     := 0
IF nP_OPC > 2 .AND. nP_OPC < 5
   AADD(aBUTTONS,{"EDIT"   ,{|| AC120IAE("I",cTITULO),oMSELECT:oBrowse:Refresh()},STR0003}) //"Incluir"
   AADD(aBUTTONS,{"ALT_CAD",{|| AC120IAE("A",cTITULO),oMSELECT:oBrowse:Refresh()},STR0004}) //"Alterar"
   AADD(aBUTTONS,{"EXCLUIR",{|| AC120IAE("E",cTITULO),oMSELECT:oBrowse:Refresh()},STR0005}) //"Excluir"
   lBTALT := .T.
ELSE
   AADD(aBUTTONS,{"ANALITICO",{|| AC120IAE("V",cTITULO),oMSELECT:oBrowse:Refresh()},STR0002}) //"Visualizar
ENDIF
BEGIN SEQUENCE
   TR5->(DBGOTOP())
   DBSELECTAREA("SB1")   
   DEFINE MSDIALOG oDLG TITLE cTITULO FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
      @ 25,005 SAY AVSX3("B1_COD",AV_TITULO)  PIXEL
      @ 23,040 MSGET M->B1_COD  PICTURE AVSX3("B1_COD" ,AV_PICTURE) SIZE 055,08 PIXEL OF oDLG WHEN(.F.)
      @ 25,120 SAY AVSX3("B1_DESC",AV_TITULO) PIXEL
      @ 23,155 MSGET M->B1_DESC PICTURE AVSX3("B1_DESC",AV_PICTURE) SIZE 095,08 PIXEL OF oDLG WHEN(.F.)
      *
      @ 35,005 SAY AVSX3("B1_VLREFUS",AV_TITULO)  PIXEL
      @ 33,040 MSGET M->B1_VLREFUS PICTURE AVSX3("B1_VLREFUS",AV_PICTURE) SIZE 058,08 PIXEL OF oDLG WHEN(.F.)
      *
      aPOS     := POSDLGDOWN(oDLG)
      aPOS[1]  := aPOS[1]-(aPOS[1]/2)
      oMSELECT := MSSELECT():New("TR5",,,aCAMPOTR5,@lINVERTE,@cMARCA,aPOS)
      oMSELECT:BAVAL := {|| AC120IAE(IF(lBTALT,"A","V"),cTITULO),oMSELECT:oBROWSE:REFRESH()}
   ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS)
END SEQUENCE   
RETURN(NIL)
*/
*--------------------------------------------------------------------
FUNCTION AC120V(cP_CAMPO,cP_PAR1)
// FUNCAO DE VALIDACAO DE CAMPOS. CHAMA NO DICIONARIO.
LOCAL lRET,Z,cAUX,nREG
Local aOrd:={}
Local lAux
*
cP_CAMPO := IF(cP_CAMPO=NIL,"",UPPER(cP_CAMPO))
lRET     := .T.
IF cP_CAMPO == "BOK"
   IF cP_PAR1 = "I" .OR. cP_PAR1 = "A"
      IF ! OBRIGATORIO(aGETS,aTELA)
         lRET := .F.
      ELSE
         FOR Z := 1 TO LEN(aGETS)
             cAUX := SUBSTR(aGETS[Z],9,10)  // CARREGA NO DO CAMPO NA ENCHOICE
             IF cP_PAR1 = "I" .OR. SUBSTR(cAUX,2,1) = "2"  // INCLUSAO OU CAMPO NAO É CHAVE
                SX3->(DBSETORDER(2))
                IF (SX3->(DBSEEK(cAUX))) .AND. ! EMPTY(SX3->X3_VALID)
                   cAUX := AVSX3(cAUX,AV_VALID)
                   IF ! EVAL(cAUX)
                      lRET := .F.
                   ENDIF
                ENDIF
             ENDIF
         NEXT
      ENDIF
   ENDIF
ELSEIF cP_CAMPO == "EX5_PAIS"
        IF ! EXISTCPO("SYA",M->EX5_PAIS,1)
           lRET := .F.
        ENDIF
 
        If !lNovaRotina
          nREG := TR5->(RECNO())
          TR5->(DBSETORDER(1))
          IF (TR5->(DBSEEK(M->EX5_PAIS)))
              MSGINFO(STR0021,STR0022) //"Preço já lançado para este Produto X País !"###"Atenção"
              lRET := .F.
          ENDIF
          TR5->(DBGOTO(nREG))
       EndIf
ELSEIF cP_CAMPO == "EX5_MOEDA"
       If !Empty(M->EX5_MOEDA) .And. !ExistCpo("SYF",M->EX5_MOEDA,1)
          lRet := .f.
       EndIf
ELSEIF cP_CAMPO == "EX5_PRECO"
       IF ! POSITIVO(M->EX5_PRECO)
          lRET := .F.
       ENDIF
ELSEIF cP_CAMPO == "EX6_CLIENT"
       //cAUX := IF(!EMPTY(M->EX6_CLLOJA),M->EX6_CLLOJA,"")
       //IF ! EXISTCPO("SA1",M->EX6_CLIENT+cAUX,1) 
       IF ! EXISTCPO("SA1",M->EX6_CLIENT,1)
          lRET := .F.
       ELSE
          If !lNovaRotina       
             If Type("lRotPrecoCliente") == "U" .Or. !lRotPrecoCliente
                nREG := TR6->(RECNO())
                TR6->(DBSETORDER(1))
                IF (TR6->(DBSEEK(M->EX6_PAIS+M->EX6_CLIENT+M->EX6_CLLOJA)))
                   MSGINFO(STR0023,STR0022) //"Preço já lançado para este Produto X País X Cliente !"###"Atenção"
                   lRET := .F.
                ENDIF
                TR6->(DBGOTO(nREG))
             EndIf
          EndIf

          /* Para os ambientes com a rotina antiga alguns gatilhos não irão existir, por este
             motivo os campos EX6_CLLOJA,EX6_PAIS, EX6_CLIEDE e EX6_PAISDE deverão ser alimentados
             diretamente no programa.
             ER - 12/10/2006 - O campos serão alimentados via programa, mesmo com a existencia
             dos gatilhos. Esse alteração foi realizada para corrigir o erro causado quando
             existem 2 importadores com o mesmo código e lojas diferentes.
          */

          If lRet
             aOrd:= SaveOrd({"SA1","SYA"})
             SA1->(DbSetOrder(1))

             lAux := SA1->(dbSeek(xFilial("SA1")+M->EX6_CLIENT+M->EX6_CLLOJA))

             // Verifica se o importador esta cadastrado ...
             lRet := ExistCpo("SA1",M->EX6_CLIENT+IF(lAux,M->EX6_CLLOJA,""))

             //If SA1->(DbSeek(xFilial("SA1")+M->EX6_CLIENT))
             M->EX6_CLLOJA := SA1->A1_LOJA
             M->EX6_CLIEDE := SA1->A1_NOME

             // BAK - Alteração para o tratamento do campo do país do cliente caso nao esteja cadastrado
             If !Empty(SA1->A1_PAIS)
                M->EX6_PAIS   := SA1->A1_PAIS
                SYA->(DbSetOrder(1))
                If SYA->(DbSeek(xFilial("SYA")+M->EX6_PAIS))
                   M->EX6_PAISDE := SYA->YA_DESCR
                EndIf
             Else
                lRet := .F.
                Msginfo("O cliente " + AllTrim(SA1->A1_NOME) + " não possui um país vinculado ao seu cadastro.","Atenção")
             EndIf
             
             //EndIf
             RestOrd(aOrd)
          EndIf
          //Endif
       ENDIF
ELSEIF cP_CAMPO == "EX6_CLLOJA"

       IF ! EXISTCPO("SA1",M->EX6_CLIENT+M->EX6_CLLOJA,1)
          lRET := .F.
       ELSE
          If !lNovaRotina
             If Type("lRotPrecoCliente") == "U" .Or. !lRotPrecoCliente
                nREG := TR6->(RECNO())
                TR6->(DBSETORDER(1))
                IF (TR6->(DBSEEK(M->EX6_PAIS+M->EX6_CLIENT+M->EX6_CLLOJA)))
                    MSGINFO(STR0023,STR0022) //"Preço já lançado para este Produto X País X Cliente !"###"Atenção"
                    lRET := .F.
                ENDIF
                TR6->(DBGOTO(nREG))
             EndIf
          EndIf
          
          If lRet
             aOrd:= SaveOrd({"SA1","SYA"})
             SA1->(DbSetOrder(1))
                
             lAux := SA1->(dbSeek(xFilial("SA1")+M->EX6_CLIENT+M->EX6_CLLOJA))
             
             // Verifica se o importador esta cadastrado ...
             lRet := ExistCpo("SA1",M->EX6_CLIENT+IF(lAux,M->EX6_CLLOJA,""))
                                
             M->EX6_PAIS   := SA1->A1_PAIS
             M->EX6_CLIEDE := SA1->A1_NOME

             SYA->(DbSetOrder(1))
             If SYA->(DbSeek(xFilial("SYA")+M->EX6_PAIS))
                M->EX6_PAISDE := SYA->YA_DESCR
             EndIf
             RestOrd(aOrd)
          EndIf
          
       ENDIF

ELSEIF cP_CAMPO == "EX6_MOEDA"
       
       IF !EXISTCPO("SYF",M->EX6_MOEDA,1)
          lRET := .F.
       ELSE
          If Type("lRotPrecoCliente") == "U" .Or. !lRotPrecoCliente
             If !lNovaRotina
                nREG := TR6->(RECNO())
                TR6->(DBSETORDER(1))
                IF (TR6->(DBSEEK(M->EX6_PAIS+M->EX6_CLIENT+M->EX6_CLLOJA)))
                    MSGINFO(STR0023,STR0022) //"Preço já lançado para este Produto X País X Cliente !"###"Atenção"
                    lRET := .F.
                ENDIF
                TR6->(DBGOTO(nREG))
             EndIf
          EndIf
       ENDIF

ELSEIF cP_CAMPO == "EX6_PRECO"
       IF ! POSITIVO(M->EX6_PRECO)
          lRET := .F.
       ENDIF

ElseIf cP_Campo == "EX6_COD_I"
       If !ExistCpo("SB1",M->EX6_COD_I)
          lRet := .f.
       EndIf
EndIf
RETURN(lRET)
*--------------------------------------------------------------------
FUNCTION AC120W(cP_CAMPO,cP_IAEV)
// FUNCAO DE VALIDACAO DOS WHENs DE CAMPOS. CHAMA NO DICIONARIO.
LOCAL lRET
*
cP_CAMPO := IF(cP_CAMPO=NIL,"",UPPER(cP_CAMPO))
lRET     := .T.
IF cP_CAMPO == "EX5_COD_I"
   lRET := .F.
   
ELSEIF cP_CAMPO == "EX5_PAIS"
       lRET := IF(cP_IAEV="A",.F.,.T.)
       
ELSEIF cP_CAMPO == "EX6_COD_I"
       /* Para a rotina de tabela de preço por produto+pais+cliente o código do 
          produto fica disponível para edição. */
       
       If Type("lRotPrecoCliente") == "U" .Or. !lRotPrecoCliente
          lRet := .f.
       EndIf
       
ELSEIF cP_CAMPO == "EX6_PAIS"
       lRET := .F.
ENDIF
RETURN(lRET)
*--------------------------------------------------------------------
/*
STATIC FUNCTION AC120IAE(nP_IAEV,cP_TITULO)
LOCAL cIAEV,Z,oDLG,bOK,bCANCEL,nBTOP,aBUTTONS,aEDITA,nMODOENCH,lBTALT
PRIVATE aTELA[0,0],aGETS[0],lINVERTE,cMARCA,aCAMPOTR6
*
nP_IAEV   := IF(nP_IAEV  =NIL,"V",nP_IAEV)
bOK       := {|| nBTOP := 1,IF(AC120V("bOK",nP_IAEV),oDLG:END(),nBTOP := 0)}
bCANCEL   := {|| nBTOP := 0,oDLG:END()}
aBUTTONS  := {}
aEDITA    := {}
aCAMPOTR6 := ARRAYBROWSE("EX6","TR6")
lINVERTE  := .F.
cMARCA    := GETMARK()
nBTOP     := 0
nMODOENCH := IF(nP_IAEV="A",4,3)
cIAEV     := IF(nP_IAEV="I",STR0003,; //"Incluir"
                IF(nP_IAEV="A",STR0004,; //"Alterar"
                   IF(nP_IAEV="E",STR0005,STR0002))) //"Excluir"###"Visualizar"
cP_TITULO := IF(cP_TITULO=NIL,"" ,cP_TITULO)+STR0024+cIAEV //" - "
lBTALT    := .F.
BEGIN SEQUENCE
   // VERIFICA A EXISTENCIA DE DADOS
   IF TR5->(EOF()) .AND. TR5->(BOF()) .AND. nP_IAEV # "I"
      //MSGINFO(STR0025+cIAEV+STR0026,STR0022) //"Nao há dados para "###" !"###"Atenção"
      HELP(" ",1,"AVG0000632")
      BREAK
   ELSEIF nP_IAEV = "I"
          TR5->(DBGOBOTTOM(),DBSKIP())
   ENDIF
   // CARREGA OS DADOS DO EX5 P/ MEMORIA
   FOR Z := 1 TO TR5->(FCOUNT())
       IF nP_IAEV = "I" .AND. LEFT(TR5->(FIELDNAME(Z)),3) = "EX5"
          M->&(TR5->(FIELDNAME(Z))) := CRIAVAR(TR5->(FIELDNAME(Z)))
       ELSE
          M->&(TR5->(FIELDNAME(Z))) := TR5->(FIELDGET(Z))
       ENDIF
       IF nP_IAEV = "I" .OR. nP_IAEV = "A"
          AADD(aEDITA,TR5->(FIELDNAME(Z)))
       ENDIF
   NEXT
   M->EX5_COD_I := M->B1_COD
   // CONFIGURA OS BOTOES
   IF nP_IAEV = "I" .OR. nP_IAEV = "A"
      aBUTTONS := {{"EDIT"   ,{|| AC120IAECL("I"),oMSELECT:oBrowse:Refresh()},STR0003},; //"Incluir"
                   {"ALT_CAD",{|| AC120IAECL("A"),oMSELECT:oBrowse:Refresh()},STR0004},; //"Alterar"
                   {"EXCLUIR",{|| AC120IAECL("E"),oMSELECT:oBrowse:Refresh()},STR0005}} //"Excluir"
      lBTALT   := .T. 
   ELSE
      AADD(aBUTTONS,{"ANALITICO",{|| AC120IAECL("V"),oMSELECT:oBrowse:Refresh()},STR0002}) //"Visualizar
   ENDIF
   // FILTRA OS DADOS DO TR6
   TR6->(DBSETFILTER({|| TR6->EX6_COD_I+TR6->EX6_PAIS == M->EX5_COD_I+M->EX5_PAIS},;
                        "TR6->EX6_COD_I+TR6->EX6_PAIS == M->EX5_COD_I+M->EX5_PAIS"))
   TR6->(DBGOTOP())
   DBSELECTAREA("TR5")
   DEFINE MSDIALOG oDLG TITLE cP_TITULO FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
      ENCHOICE("EX5",0,nMODOENCH,,,,,POSDLGUP(oDLG),aEDITA)
      oMSELECT := MSSELECT():New("TR6",,,aCAMPOTR6,@lINVERTE,@cMARCA,POSDLGDOWN(oDLG))
      oMSELECT:BAVAL := {|| AC120IAECL(IF(lBTALT,"A","V")),oMSELECT:oBROWSE:REFRESH()}
   ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS)
   IF nBTOP = 1
      IF nP_IAEV = "I"
         TR5->(DBAPPEND())
         AVREPLACE("M","TR5")
      ELSEIF nP_IAEV = "A"
             AVREPLACE("M","TR5")
      ELSEIF nP_IAEV = "E"
             IF ! EMPTY(TR5->TR5_RECNO)
                AADD(aDELEX5,TR5->TR5_RECNO)
             ENDIF
             TR5->(DBDELETE())
             TR6->(DBGOTOP())
             DO WHILE ! TR6->(EOF())
                IF ! EMPTY(TR6->TR6_RECNO)
                   AADD(aDELEX6,TR6->TR6_RECNO)
                ENDIF
                TR6->(DBDELETE())
                TR6->(DBSKIP())
             ENDDO
      ENDIF
   ENDIF
END SEQUENCE
TR6->(DBCLEARFILTER())
RETURN(NIL)
*/
*--------------------------------------------------------------------
/*
STATIC FUNCTION AC120IAECL(nP_IAEV)
LOCAL cIAEVCL,Z,oDLG,bOK,bCANCEL,nBTOP,aBUTTONS,cTITULO,nMODOENCH,aEDITA
PRIVATE aTELA[0,0],aGETS[0]
*
nP_IAEV   := IF(nP_IAEV  =NIL,"V",nP_IAEV)
bOK       := {|| nBTOP := 1,IF(AC120V("bOK",nP_IAEV),oDLG:END(),nBTOP := 0)}
bCANCEL   := {|| nBTOP := 0,oDLG:END()}
aBUTTONS  := {}
aEDITA    := {}
nBTOP     := 0
cIAEVCL   := IF(nP_IAEV="I",STR0003,; //"Incluir"
                IF(nP_IAEV="A",STR0004,; //"Alterar"
                   IF(nP_IAEV="E",STR0005,STR0002))) //"Excluir"###"Visualizar"
cTITULO   := STR0027+cIAEVCL //"Tabela de Preços - Produtos X Países X Clientes - "
nMODOENCH := IF(nP_IAEV="A",4,3)
BEGIN SEQUENCE
   // VERIFICA A EXISTENCIA DE DADOS
   IF TR6->(EOF()) .AND. TR6->(BOF()) .AND. nP_IAEV # "I"
      //MSGINFO(STR0025+cIAEVCL+STR0026,STR0022) //"Nao há dados para "###" !"###"Atenção"
      HELP(" ",1,"AVG0000632")
      BREAK
   ELSEIF nP_IAEV = "I"
          TR6->(DBGOBOTTOM(),DBSKIP())
   ENDIF
   // CARREGA OS DADOS DO EX6 P/ MEMORIA
   FOR Z := 1 TO TR6->(FCOUNT())
       IF nP_IAEV = "I" .AND. LEFT(TR6->(FIELDNAME(Z)),3) = "EX6"
          M->&(TR6->(FIELDNAME(Z))) := CRIAVAR(TR6->(FIELDNAME(Z)))
       ELSE
          M->&(TR6->(FIELDNAME(Z))) := TR6->(FIELDGET(Z))
       ENDIF
       IF nP_IAEV = "I" .OR. nP_IAEV = "A"
          AADD(aEDITA,TR6->(FIELDNAME(Z)))
       ENDIF
   NEXT
   M->EX6_COD_I := M->B1_COD
   M->EX6_PAIS  := M->EX5_PAIS
   DBSELECTAREA("TR6")
   DEFINE MSDIALOG oDLG TITLE cTITULO FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
      ENCHOICE("EX6",0,nMODOENCH,,,,,POSDLG(oDLG),aEDITA)
   ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS)
   IF nBTOP = 1
      IF nP_IAEV = "I"
         IF TR6->(EOF()) .AND. TR6->(BOF())
            TR6->(DBCLEARFILTER(),DBGOTOP())
            TR6->(DBAPPEND())
            AVREPLACE("M","TR6")
            Z := TR6->(RECNO())
            TR6->(DBSETFILTER({|| TR6->EX6_COD_I+TR6->EX6_PAIS == M->EX5_COD_I+M->EX5_PAIS},;
                                 "TR6->EX6_COD_I+TR6->EX6_PAIS == M->EX5_COD_I+M->EX5_PAIS"))
            TR6->(DBGOTO(Z))
         ELSE
            TR6->(DBAPPEND())
            AVREPLACE("M","TR6")
         ENDIF
      ELSEIF nP_IAEV = "A"
             AVREPLACE("M","TR6")
      ELSEIF nP_IAEV = "E"
             IF ! EMPTY(TR6->TR6_RECNO)
                AADD(aDELEX6,TR6->TR6_RECNO)
             ENDIF
             TR6->(DBDELETE())
      ENDIF
   ENDIF
END SEQUENCE
RETURN(NIL)
*/
/*
Funcao      : TabPreco()
Parametros  : nP_Preco   -> Caso o preço não seja encontrado na pesquisa, assume este valor como
                            retorno padrão.
              cP_Cod_I   -> Código do Produto.
              cP_Pais    -> Código do Pais.
              cP_Cliente -> Código+Loja do Cliente.
              cP_Moeda   -> Código da Moeda.
              dP_DtApu   -> Dt. Apuração.
Retorno     : Preço do produto.
Objetivos   : Pesquisar preço do produto de acordo com as configurações da pesquisa. (Pais/Cliente/Cad.Produto).
Autor       : Luciano Santana
Data/Hora   : 
Revisao     : Jeferson Barros Jr. 31/08/04 - 15:13.
Obs.        :
*/
*-----------------------------------------------------------------------*
Function TabPreco(nP_PRECO,cP_COD_I,cP_PAIS,cP_CLIENTE,cP_MOEDA,dP_DtApu)
*-----------------------------------------------------------------------*
Local cALIASANT := ALIAS(), aORDANT := SAVEORD({"SA1","SB1"})
Local cPesquisa, aPreco:={}, aDetalhes:={}

Private lNovaPesquisa := .f.
Private nPreco := 0

Default nP_Preco   := 0
Default cP_Cod_I   := ""
Default cP_Pais    := ""
Default cP_Cliente := ""
Default cP_Moeda   := ""
Default dP_DtApu   := dDataBase

Begin Sequence

   If Select("EX5") = 0 .And. Select("EX6") = 0
      //ER - 31/08/2006 - Verifica se existe no dicionário.
      SX2->(DbSetOrder(1))
      If SX2->(!DbSeek("EX5")) .or. SX2->(!DbSeek("EX6"))
         Break
      Else
         DbSelectArea("EX5")
         DbSelectArea("EX6")
      EndIf
   EndIf

   nPreco := nP_Preco

   /* Verifica se os campos necessários para realizacao da nova pesquisa estão
      disponíveis no ambiente. */

   If EX5->(FieldPos("EX5_DTINI"))  > 0 .And. EX5->(FieldPos("EX5_DTFIM")) > 0 .And.;
      EX6->(FieldPos("EX6_DTINI"))  > 0 .And. EX6->(FieldPos("EX6_DTFIM")) > 0 .And.;
      EasyGParam("MV_AVG0068",.t.) .And. !Empty(EasyGParam("MV_AVG0068"))

      lNovaPesquisa := .t.
      cPesquisa     := AllTrim(EasyGParam("MV_AVG0068"))

      /* O Mv deverá estar configurado de acordo com as opções default para pesquisa
         do preço do produto */
      If !(cPesquisa $ "1/2/3")
         Break
      EndIf
   EndIf

   /* Caso o código do país não tenha sido informado, considera o código do 
      país do cadastro de clientes. */

   If Empty(cP_Pais)
      SA1->(DbSetOrder(1))
      SA1->(DbSeek(xFilial("SA1")+cP_Cliente))
      cP_Pais := SA1->A1_PAIS
   EndIf

   If lNovaPesquisa
      // Pesquisa o preço de acordo com o conteúdo do MV_AVG0068.
      aPreco := FindPrice(cP_Cod_I,cP_Pais,cP_Cliente,cP_Moeda,dP_DtApu,cPesquisa)
   Else
      // Pesquisa o preço no EX6/EX5/SB1.
      aPreco := FindPrice(cP_Cod_I,cP_Pais,cP_Cliente,cP_Moeda,,"3") 
   EndIf

   If Len(aPreco) > 0
      If aPreco[2] == "SB1"
         nPreco := IF(nPreco=0, aPreco[1], nPreco)
      Else
         nPreco := aPreco[1]
      EndIf
   EndIf

   // Define as informaçõe que serão passadas como parâmetro para o ponto de entrada.
   aDetalhes := If(Len(aPreco) > 0,;
                  {"TABPRECO",nPreco,aPreco[2]},;
                  {"TABPRECO",nPreco,"DEF"})

   If EasyEntryPoint("EECAC120")
      ExecBlock("EECAC120",.f.,.f.,aDetalhes)
   EndIf

End Sequence

RestOrd(aOrdAnt)
DbSelectArea(cAliasAnt)

Return nPreco

/*
Funcao      : FindPrice()
Parametros  : cProd     -> Código do Produto.
              cPais     -> Código do Pais.
              cCliente  -> Código+Loja do Cliente.
              cMoeda    -> Código da Moeda.
              dDtApu    -> Dt. Apuração.
              cPesquisa -> "1" - Cadastro de Produtos.
                           "2" - EX6 e EX5.
                           "3" - EX6 e EX5 e Cadastro de Produtos.
Retorno     : aRet - [1] - Preço do produto.
                     [2] - Alias da tabela onde o preço foi encontrado.
Objetivos   : Auxiliar a função TabPreco().
Autor       : Jeferson Barros Jr.
Data/Hora   : 31/08/04 - 15:55
Revisao     : Jeferson Barros Jr. 
Obs.        :
*/
*---------------------------------------------------------------------*
Static Function FindPrice(cProd,cPais,cCliente,cMoeda,dDtApu,cPesquisa)
*---------------------------------------------------------------------*
Local aRet:={}, aOrd:=SaveOrd({"EX5","EX6","SB1"})
Local cPaisAux := EasyGParam("MV_AVG0070",,"999"), cKey
Local lFound:=.f.

Default dDtApu := CtoD("")

Begin Sequence

   If Empty(cProd)  .Or. Empty(cPesquisa)
      Break
   EndIf

   cPesquisa := Upper(AllTrim(cPesquisa))

   If cPesquisa $ "2/3"

      /* Pesquisa inicialmente na relação Produto X Pais X Cliente (EX6).
         Para os ambientes com a rotina nova de pesquisa a data recebida como parâmetro, será considerada para 
         validação dos intervalos de datas de aprovação existentes para o cliente. */

      EX6->(DbSetOrder(1))

      cKey   := cPais
      lFound := EX6->(DbSeek(xFilial("EX6")+AvKey(cProd,"EX6_COD_I")+AvKey(cKey,"EX6_PAIS")+cCliente))
      If !lFound
         cKey := cPaisAux
         lFound := EX6->(DbSeek(xFilial("EX6")+AvKey(cProd,"EX6_COD_I")+AvKey(cKey,"EX6_PAIS")+cCliente))
      EndIf

      If lFound
         Do While EX6->(!Eof()) .And. EX6->EX6_FILIAL == xFilial("EX6") .And.;
                                      EX6->EX6_COD_I  == AvKey(cProd,"EX6_COD_I") .And.;
                                      EX6->EX6_PAIS   == AvKey(cKey ,"EX6_PAIS")  .And.;
                                      EX6->EX6_CLIENT == SubStr(cCliente,1,Avsx3("EX6_CLIENT",AV_TAMANHO)) .And.;
                                      EX6->EX6_CLLOJA == SubStr(cCliente,Avsx3("EX6_CLIENT",AV_TAMANHO)+1)

            If EX6->EX6_MOEDA == AvKey(cMoeda,"EX6_MOEDA") .And. EX6->EX6_PRECO > 0

               If lNovaPesquisa
                  // Verifica os intervalo de aprovação.
                  If !Empty(EX6->EX6_DTINI) .And. !Empty(EX6->EX6_DTFIM)
                     If (dDtApu >= EX6->EX6_DTINI) .And. (dDtApu <= EX6->EX6_DTFIM)
                        aRet := {EX6->EX6_PRECO,"EX6"}
                        Break
                     EndIf

                  ElseIf !Empty(EX6->EX6_DTINI) .And. Empty(EX6->EX6_DTFIM)
                     If (dDtApu >= EX6->EX6_DTINI)
                        aRet := {EX6->EX6_PRECO,"EX6"}
                        Break
                     EndIf
                  EndIf
               Else
                  aRet := {EX6->EX6_PRECO,"EX6"}
                  Break
               EndIf
            EndIf
            EX6->(DbSkip())
         EndDo
      EndIf

      /* Caso o preço do produto não tenha sido encontrado anteriormente procura o preço do produto na relação
         Produto X Pais. (EX5).
         Para os ambientes com a rotina nova de pesquisa a data recebida como parâmetro, será considerada para 
         validação dos intervalos de datas de aprovação existentes para o cliente. */

      EX5->(DbSetOrder(1))

      cKey   := cPais
      lFound := EX5->(DbSeek(xFilial("EX5")+AvKey(cProd,"EX5_COD_I")+AvKey(cKey,"EX5_PAIS")))

      If !lFound
         cKey := cPaisAux
         lFound := EX5->(DbSeek(xFilial("EX5")+AvKey(cProd,"EX5_COD_I")+AvKey(cKey,"EX5_PAIS")))
      EndIf

      If lFound
         Do While  EX5->(!Eof()) .And. EX5->EX5_FILIAL == xFilial("EX5") .And.;
                                       EX5->EX5_COD_I  == AvKey(cProd,"EX5_COD_I") .And.;
                                       EX5->EX5_PAIS   == AvKey(cKey,"EX5_PAIS")

            If (EX5->EX5_MOEDA = AvKey(cMoeda,"EX5_MOEDA") .And. EX5->EX5_PRECO > 0)

               If lNovaPesquisa
                  // Verifica os intervalo de aprovação.
                  If !Empty(EX5->EX5_DTINI) .And. !Empty(EX5->EX5_DTFIM)
                     If (dDtApu >= EX5->EX5_DTINI) .And. (dDtApu <= EX5->EX5_DTFIM)
                        aRet := {EX5->EX5_PRECO,"EX5"}
                        Break
                     EndIf

                  ElseIf !Empty(EX5->EX5_DTINI) .And. Empty(EX5->EX5_DTFIM)
                     If (dDtApu >= EX5->EX5_DTINI)
                        aRet := {EX5->EX5_PRECO,"EX5"}
                        Break
                     EndIf
                  EndIf
               Else
                  aRet := {EX5->EX5_PRECO,"EX5"}
                  Break
               EndIf
            EndIf
            EX5->(DbSkip())
         EndDo
      EndIf
   EndIf

   If cPesquisa $ "1/3"
 
      // Pesquisa o preço do produto diretamente no cadastro de produtos.
      SB1->(DbSetOrder(1))
      If SB1->(DbSeek(xFilial("SB1")+AvKey(cProd,"B1_COD")))
         aRet := {SB1->B1_VLREFUS,"SB1"}
      EndIf
   EndIf

End Sequence

RestOrd(aOrd)

Return aRet

/*
Funcao      : aC120TabPreco().
Parametros  : cAlias    -> Alias.
              nReg      -> Registro.
              nOpc      -> Opcao.
Retorno     : .t./.f.
Objetivos   : Rotina de Tabela de Preco.
Autor       : Jeferson Barros Jr.
Data/Hora   : 07/09/04 - 11:32.
Revisao     : 
Obs.        :
*/
*---------------------------------------------*
Static Function AC120TabPreco(cAlias,nReg,nOpc)
*---------------------------------------------*
Local lRet := .t.
Local aTree:={}, aMenu:={}, aButtons :={}, aPos:={}, aSemSx3:={}, aCmpPais:={}, aCmpCli:={},;
      aDelBackPais:={}, aDelBackCli:={}
//Local nLink := 9999, nCod := 1, nChoice := 0, nPos:=0
Local nLink := 1, nCod := 0, nChoice := 0, nPos:=0
Local cOldPais, cOldCli, cTitulo, cLink,;
      cBackupPais := CriaTrab(,.F.),;
      cBackupCli  := CriaTrab(,.F.)
Local oDlg, oFont := TFont():New("Courier New",09,15)
Local bCancel := {|| oDlg:End()},;
      bOk     := {|| nChoice := 1, oDlg:End()}
Local cOldLoja

Private oTree, oMemo, oMsSelPais, oMsSelCli
Private cMemo, cMsg1, cMsg2

Begin Sequence

   If (nOpc == INCLUIR) .And. Empty(M->B1_COD)
      MsgInfo(STR0031+AllTrim(AvSx3("B1_COD",AV_TITULO))+STR0032,STR0033) //"O campo '"###"' deve ser informado."###"Aviso"
      lRet := .f.
      Break
   EndIf

   TR5->(DbClearFilter())
   DbSelectArea("TR5")
   DbGoTop() // JPM - 17/03/06 - Dar DbGoTop antes dos 'Copy To' para não gerar erro em CTree.
   TETempBackup(cBackupPais) // EJA - 05/10/2017 - Temporário Banco de dados
   aDelBackPais := aClone(aDelEX5)
   TR5->(dbGoTop())

   TR6->(DbClearFilter())
   DbSelectArea("TR6")
   DbGoTop() // JPM - 17/03/06 - Dar DbGoTop antes dos 'Copy To' para não gerar erro em CTree.
   TETempBackup(cBackupCli) // EJA - 05/10/2017 - Temporário Banco de dados
   aDelBackCli := aClone(aDelEX6)
   TR6->(dbGoTop())

   /* Define array com a estrutura do tree, com todos os paises e clientes que será 
      utilizado pela função AvTree() */

   aAdd(aTree,{StrZero(nCod,4),STR0083,"RAIZ","BMPTABLE" /*"TAB1"*/,"BMPTABLE" /*"TAB1"*/,StrZero(nLink,4,0)})  //"Pais/Cliente"  //"Tabela Preços - Pais/Cliente"
   //aAdd(aTree,{StrZero(nCod,4),STR0034,"RAIZ","BPMSDOC","BPMSDOC",StrZero(nLink,4,0)})  //"Pais/Cliente"
   //cCod := Str(nLink,4,0)
   cCod := aTree[1][6]

   TR6->(DbSetOrder(1))
   TR5->(DbGoTop())
   Do While TR5->(!Eof())

      If (cOldPais <> TR5->EX5_PAIS)
         cOldPais := TR5->EX5_PAIS
         nLink ++
      Else
         TR5->(DbSkip())
         Loop
      EndIf

      aAdd(aTree,{cCod,; // Cod.
                  Capital(AllTrim(Posicione("SYA",1,xFilial("SYA")+TR5->EX5_PAIS,"YA_DESCR"))),;  // Label.
                  "P"+TR5->EX5_PAIS,;   // Cargo.
                  "WEB" /*"GLOBO"*/,;             // Resource Open.
                  "WEB" /*"GLOBO"*/,;             // Resource Close.
                  StrZero(nLink,4,0)})  // Link.
     
      If TR6->(DbSeek(TR5->EX5_PAIS))
         Do While TR6->(!Eof()) .And. TR6->EX6_PAIS == TR5->EX5_PAIS
            If (cOldCli <> TR6->EX6_CLIENT .Or. cOldLoja <> TR6->EX6_CLLOJA ) // By JPP - 14/04/2005 - 10:20 - Efetuar quebra no tree por cliente+loja.
                cOldCli := TR6->EX6_CLIENT
                cOldLoja:= TR6->EX6_CLLOJA
 
                aAdd(aTree,{StrZero(nLink,4,0),; // Cod.
                             Capital(AllTrim(Posicione("SA1",1,xFilial("SA1")+TR6->EX6_CLIENT+TR6->EX6_CLLOJA,"A1_NREDUZ")))+;  
                             " / "+TR6->EX6_CLLOJA,;  // Label.
                             "C"+AvKey(TR6->EX6_PAIS,"EX6_PAIS")+AvKey(TR6->EX6_CLIENT,"EX6_CLIENT")+;
                             AvKey(TR6->EX6_CLLOJA,"EX6_CLLOJA"),; // Cargo.    // By JPP - 14/04/2005 - 10:20
                             "CLIENTE",;                      // Resource Open.
                             "CLIENTE",;                      // Resource Close.
                             ""})                             // Link.
            EndIf
            TR6->(DbSkip())
         EndDo
      EndIf
    
      TR5->(DbSkip())  
   EndDo

   cMsg1 := Space(1)+STR0035+ENTER+; //"Utilize a estrutura ao lado, para analisar os preços cadastrados"
            Space(1)+STR0036+Replic(ENTER,2)+; //"por 'pais', por 'cliente' ou por 'Pais e Cliente'."
            Space(1)+STR0037+ENTER+; //"Para realizar a manutenção dos preços, utilize os botões da barra"
            Space(1)+STR0038  +ENTER+; //"de ferramentas ou acesse as opções do menu pop-up, com o botão "
            Space(1)+STR0039 //"direito do mouse."
            
   cMsg2 := Space(1)+STR0040 //"Não há itens para seleção."
   
   cMemo := cMsg1

   If (nOpc == INCLUIR) .Or. (nOpc == ALTERAR)
      /* Define array com os botões da enchoicebar
         para visualização/inclusão/alterção e exclusão. */

      aAdd(aButtons, {"PESQUISA" ,{|| aC120Find()}         ,STR0001}) //"Pesquisar"
      aAdd(aButtons, {"BMPINCLUIR" /*"EDIT"*/,{|| aC120ChoseAdd()}     ,STR0003}) //"Incluir"
      aAdd(aButtons, {"EDIT" /*"ALT_CAD"*/   ,{|| aC120TabMan(ALT_DET)},STR0004}) //"Alterar"
      aAdd(aButtons, {"EXCLUIR"  ,{|| aC120TabMan(EXC_DET)},STR0005}) //"Excluir"
      aAdd(aButtons, {"BMPVISUAL" /*"ANALITICO"*/,{|| aC120TabMan(VIS_DET)},STR0002}) //"Visualizar

      /* Define array com as opções para o menu pop-up
         para visualização/inclusão/alteração e exclusão. */
 
      aAdd(aMenu,{STR0001 ,{|| aC120Find()}}) //"Pesquisar"
      aAdd(aMenu,{STR0002 ,{|| aC120TabMan(VIS_DET)}}) //"Visualizar"
      aAdd(aMenu,{"-",""})
      aAdd(aMenu,{STR0003 ,{|| aC120ChoseAdd()}}) //"Incluir"
      aAdd(aMenu,{STR0004 ,{|| aC120TabMan(ALT_DET)}}) //"Alterar"
      aAdd(aMenu,{"-",""})
      aAdd(aMenu,{STR0005 ,{|| aC120TabMan(EXC_DET)}}) //"Excluir"
      
   Else
      /* Define array com os botões da enchoicebar
         para visualização/inclusão/alteração e exclusão. */

      aAdd(aButtons, {"PESQUISA" ,{|| aC120Find()}         ,STR0001}) //"Pesquisar"
      aAdd(aButtons, {"BMPVISUAL" /*"ANALITICO"*/,{|| aC120TabMan(VIS_DET)},STR0002}) //"Visualizar

      /* Define array com as opções para o menu pop-up
         para visualização/inclusão/alteração e exclusão. */

      aAdd(aMenu,{STR0001 ,{|| aC120Find()}}) //"Pesquisar"
      aAdd(aMenu,{STR0002,{|| aC120TabMan(VIS_DET)}}) //"Visualizar"
   EndIf

   If lNovaRotina
      aCmpPais := {{"TR5_STATUS",TR5->TR5_STATUS,STR0041},; //"Status"
                   COLBRW("EX5_MOEDA" ,"TR5"),;
                   COLBRW("EX5_PRECO" ,"TR5"),;
                   COLBRW("EX5_DTINI" ,"TR5"),;
                   COLBRW("EX5_DTFIM" ,"TR5"),;
                   COLBRW("EX5_DTAPRO","TR5"),;
                   COLBRW("EX5_USU"   ,"TR5"),;
                   COLBRW("EX5_HORA"  ,"TR5")}

      aCmpCli := {{"TR6_STATUS",TR6->TR6_STATUS,"Status"},;
                   COLBRW("EX6_MOEDA" ,"TR6"),;
                   COLBRW("EX6_PRECO" ,"TR6"),;
                   COLBRW("EX6_DTINI" ,"TR6"),;
                   COLBRW("EX6_DTFIM" ,"TR6"),;
                   COLBRW("EX6_DTAPRO","TR6"),;
                   COLBRW("EX6_USU"   ,"TR6"),;
                   COLBRW("EX6_HORA"  ,"TR6")}
   Else
      aCmpPais := {COLBRW("EX5_MOEDA","TR5"),;
                   COLBRW("EX5_PRECO","TR5")}

      aCmpCli := { COLBRW("EX6_MOEDA","TR6"),;
                   COLBRW("EX6_PRECO","TR6")}
   EndIf

   cTitulo := STR0042+ AllTrim(Transf(M->B1_COD,AvSx3("B1_COD",AV_PICTURE))) //"Tabela Preços - Produto: "

   TR5->(DbGoTop())
   TR6->(DbGoTop())

   Define MsDialog oDlg Title cTitulo From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel
//    CRF - 05/10/2010 - 11:23
//      aCmpPais := AddCpoUser(aCmpPais,"EX5","5","TR5")
      aCmpPais := AddCpoUser(aCmpPais,"EX5","2")

//    CRF - 05/10/2010 - 11:25
      aCmpCli := AddCpoUser(aCmpCli,"EX6","2")


      aPos := PosDlg(oDlg)
      aPosMsSelect := {30,103,aPos[3],aPos[4]}

      oTree := AvTree(aTree,,aMenu,oDlg)
      oTree:nTop := 60
      oTree:bChange := {|| aC120TrataObj(oTree:GetCargo())}
     
      @ 30,103 Get oMemo Var cMemo MEMO HSCROLL SIZE aPos[4]-103,aPos[3]-15 READONLY FONT oFont COLOR CLR_HBLUE Of oDlg UPDATE Pixel
      oMemo:lWordWrap := .F.
     
//    CRF - 05/10/2010 - 11:23
//      aCmpPais := AddCpoUser(aCmpPais,"TR5","2")
      
      oMsSelPais:=MsSelect():New("TR5",,,aCmpPais,,,aPosMsSelect)

//    CRF - 05/10/2010 - 11:25
//      aCmpCli := AddCpoUser(aCmpCli,"TR6","2")

      oMsSelPais:=MsSelect():New("TR5",,,aCmpPais,,,aPosMsSelect)
      oMsSelCli :=MsSelect():New("TR6",,,aCmpCli,,,aPosMsSelect)
      
      oMsSelPais:bAval := {|| aC120TabMan(VIS_DET)}
      oMsSelCli:bAval  := {|| aC120TabMan(VIS_DET)}

      oMsSelPais:oBrowse:Hide()
      oMsSelCli:oBrowse:Hide()
      
   Activate MsDialog oDlg Centered On Init (StartTree(),EnchoiceBar(oDlg,bOk,bCancel,,aButtons))

   TR5->(DbClearFilter())
   TR6->(DbClearFilter())
   
   If nChoice = 0
      /* Restaura a work com informações do pais e a work com informações
         dos clientes, em caso de cancelamento. */
      TR5->(avzap()) // avzap()
      dbSelectArea("TR5")
      TERestBackup(cBackupPais) 
      aDelEX5 := aClone(aDelBackPais)

      TR6->(avzap()) // avzap()
      dbSelectArea("TR6")
      TERestBackup(cBackupCli)
      aDelEX6 := aClone(aDelBackCli)
   EndIf
/*
   FErase(cBackupPais+GetDBExtension())
   FErase(cBackupCli +GetDBExtension())
*/
   E_EraseArq(cBackupPais) // EJA - 05/10/2017 - Temporário Banco de dados
   E_EraseArq(cBackupCli)

End Sequence

Return lRet

/*
Funcao      : aC120TabMan(nOpc)
Parametros  : nOpc  -> Visualização/Inclusão/Alteração/Exclusão.
Retorno     : .t./.f.
Objetivos   : Rotina de Tabela de Preco.
Autor       : Jeferson Barros Jr.
Data/Hora   : 07/09/04 - 11:32.
Revisao     : 
Obs.        :
*/
*-----------------------------------------*
Static Function aC120TabMan(nOpc,cAliasAux)
*-----------------------------------------*
Local oDlg
Local lRet:=.t., lFound:=.f., lPriceClose:=.f.
Local j:=0 , nChoice := 0
Local cAliasWk, cTitulo, cOldFilter, cGalho, cOpc
Local aPos:={}, aEnchoice:={}, aOldaTela:={}, aOldaGets:={}, aAltera:={}
Local bCancel := {|| oDlg:End()}, bOk, bOldFilter 

Private lIsPais := .f.

Begin Sequence

   aOldaTela := aTela
   aOldaGets := aGets

   aTela := {}
   aGets := {}

   cOpc:= STR0002 //"visualizar"
   If nOpc == INC_DET
      cOpc:= STR0003 //"incluir"
   ElseIf nOpc == ALT_DET
      cOpc:= STR0004 //"alterar"
   ElseIf nOpc == EXC_DET
      cOpc:= STR0005 //"excluir"
   EndIf

   If nOpc = INC_DET
      If cAliasAux == "EX5"
         cAliasWk  := "TR5"
         lIsPais   := .t.
      Else
         cAliasWk  := "TR6"
         lIsPais   := .f.
      EndIf 
   Else
      cGalho := oTree:GetCargo()
      If Left(cGalho,1) == "P"
         cAliasAux := "EX5"
         cAliasWk  := "TR5"
         lIsPais   := .t.
         
      ElseIf Left(cGalho,1) == "C"
         cAliasAux := "EX6"
         cAliasWk  := "TR6"
         lIsPais   := .f.
         
      ElseIf Left(cGalho,1) == "R"
         MsgInfo(STR0043+cOpc+".",STR0022) //"Selecione o Pais ou Cliente que deseja "###"Atenção"
         Break
      EndIf
   EndIf
  
   If nOpc <> INC_DET .And. IsVazio(cAliasWk)
      Help(" ",1,"AVG0000632") // Não existem registros para a manutenção !
      Break
   EndIf

   If nOpc == ALT_DET .Or. nOpc == EXC_DET 
      If lNovaRotina      
         nRec := (cAliasWk)->(RecNo())
         (cAliasWk)->(DbGoTop())
         Do While (cAliasWk)->(!Eof())
            If Empty((cAliasWk)->&(cAliasAux+"_DTINI")) .And. Empty((cAliasWk)->&(cAliasAux+"_DTFIM"))
               lFound:=.t.
               Exit
            EndIf
            (cAliasWk)->(DbSkip())
         EndDo

         If !lFound
            MsgStop(STR0044+ENTER+; //"Problema:"
                    STR0045+Replic(ENTER,2)+; //"Exclusão não permitida."
                    STR0046+ENTER+; //"Detalhes:"
                    STR0047,STR0022) //"Não existe preço sem aprovação disponível para exclusão"###"Atenção"
            (cAliasWk)->(DbGoTo(nRec))
            lRet:=.f.
            Break
         EndIf
      EndIf
   EndIf

   cTitulo := STR0048+Capital(cOpc)+If(cAliasAux=="EX6",STR0070,STR0071) //"Manutenção de Preços - " //" (Cliente)."###" (Pais)."

   If nOpc == INC_DET
      aAltera := If(cAliasAux = "EX5",;
                   {"EX5_PAIS","EX5_MOEDA","EX5_PRECO"},;
                   {"EX6_CLIENT","EX6_CLLOJA","EX6_MOEDA","EX6_PRECO"})
   ElseIf nOpc == ALT_DET
      aAlTera := If(cAliasAux = "EX5",;
                   {"EX5_MOEDA","EX5_PRECO"},;
                   {"EX6_MOEDA","EX6_PRECO"})
   EndIf
   
   /* Carrega os campos que serão exibidos/alteraos na enchoice
      do país ou cliente. */

   Sx3->(DbSetOrder(1))
   If Sx3->(DbSeek(cAliasAux))
      Do While Sx3->(!Eof()) .And. Sx3->X3_ARQUIVO == cAliasAux
         If X3Uso(SX3->X3_USADO)
            If Sx3->X3_PROPRI <> "U"
               aAdd(aEnchoice,AllTrim(Sx3->X3_CAMPO))
            Else
               If aScan(aEnchoice,AllTrim(Sx3->X3_CAMPO)) = 0
                  aAdd(aEnchoice,AllTrim(Sx3->X3_CAMPO))
               EndIf

               If nOpc == INC_DET .or. nOpc == ALT_DET
                  If aScan(aAlTera,AllTrim(Sx3->X3_CAMPO)) = 0
                     aAdd(aAlTera ,AllTrim(Sx3->X3_CAMPO))
                  EndIf
               EndIf
            EndIf
         EndIf
         Sx3->(DbSkip())
      EndDo
   EndIf

   If (nOpc == INC_DET)
      For j := 1 TO (cAliasAux)->(FCount())
         M->&((cAliasAux)->(FieldName(j))) := CriaVar((cAliasAux)->(FieldName(j)))
      Next
      M->&(cAliasAux+"_COD_I") := M->B1_COD

      bOk := {|| If(aC120Valid("TABMAN",nOpc),(nChoice := 1, oDlg:End()),nil)}
   Else
      For j := 1 TO (cAliasWk)->(FCount())
         M->&((cAliasWk)->(FieldName(j))) := (cAliasWk)->(FieldGet(j))
      Next

      bOk := {|| If(aC120Valid("TABMAN",nOpc),(nChoice := 1, oDlg:End()),nil)}
      
      If nOpc = VIS_DET
         bOk := {|| oDlg:End(),nChoice := 1}
      EndIf
   EndIf

   Define MsDialog oDlg Title cTitulo From 9,0 To 35,80 Of oMainWnd
      aPos := PosDlg(oDlg)
      EnChoice(cAliasAux,,If(nOpc=INC_DET,3,4),,,,aEnchoice,aPos,aAltera,3)
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

   If nChoice = 1
      Do Case
         Case nOpc == INC_DET
              aC120AddGalho(lIsPais) // Adiciona novo galho/folha no tree.

              cOldFilter := (cAliasWk)->(dbFilter())
              bOldFilter := &("{|| "+if(Empty(cOldFilter),".t.",cOldFilter)+" }")

              (cAliasWk)->(DbClearFilter())
              (cAliasWk)->(DbAppend())
              AvReplace("M",cAliasWk)

              If lNovaRotina
                 If lIsPais
                    If TR5->EX5_PRECO > 0
                       (cAliasWk)->&(cAliasWk+"_STATUS") := STR0028 //"Aguardando Aprovação"
                    Else
                       (cAliasWk)->&(cAliasWk+"_STATUS") := STR0049  //"Sem Preço"
                    EndIf
                 Else
                   (cAliasWk)->&(cAliasWk+"_STATUS") := STR0028 //"Aguardando Aprovação"
                 EndIf
              EndIf

              If !Empty(cOldFilter)
                 (cAliasWk)->(DbSetFilter(bOldFilter,cOldFilter))
                 (cAliasWk)->(dbGoTop())
              EndIf

              If !lIsPais
                 cOldFilter := TR5->(dbFilter())
                 bOldFilter := &("{|| "+if(Empty(cOldFilter),".t.",cOldFilter)+" }")

                 TR5->(DbClearFilter())
                 TR5->(DbSetOrder(1))

                 // ** verifica se o país existe na work TR5.
                 If !TR5->(DbSeek(M->EX6_PAIS))
                    TR5->(DbAppend())
                    TR5->EX5_COD_I  := M->EX6_COD_I
                    TR5->EX5_PAIS   := M->EX6_PAIS
                    TR5->EX5_PAISDE := M->EX6_PAISDE

                    If lNovaRotina
                       TR5->TR5_STATUS := STR0049 //"Sem Preço"
                    EndIf
                 EndIf

                 If !Empty(cOldFilter)
                    TR5->(DbSetFilter(bOldFilter,cOldFilter))
                    TR5->(dbGoTop())
                 EndIf
              EndIf

              // Posiciona no novo galho/folha (Pais/Cliente).
              If cAliasWk = "TR5"
                 cGalho := "P"+M->EX5_PAIS
                 aC120CheckTree(cGalho)
                 aC120TrataObj(cGalho)  // By JPP - 18/10/2006 - 14:30 - Atualizar a tela após inclusão de item
              Else              
                 /* Posiciona inicialmente no pais para depois posicionar
                    no cliente */
                 cGalho := "P"+M->EX6_PAIS 
                 aC120CheckTree(cGalho)

                 cGalho := "C"+M->EX6_PAIS+M->EX6_CLIENT+M->EX6_CLLOJA     // By JPP - 14/04/2005 11:40
                 aC120CheckTree(cGalho)
                 aC120TrataObj(cGalho)   // By JPP - 18/10/2006 - 14:30 - Atualizar a tela após inclusão de item
              EndIf

         Case nOpc == ALT_DET
              AvReplace("M",cAliasWk)

              /* Tratamentos para gravação do campo de status. Para o caso de alteração
                 de pais, verifica se o preço foi informado. */

              If lNovaRotina
                 If lIsPais
                    If TR5->EX5_PRECO > 0
                       TR5->TR5_STATUS := STR0028 //"Aguardando Aprovação"
                    Else
                       TR5->TR5_STATUS := STR0049 //"Sem Preço"
                    EndIf
                 Else
                    TR6->TR6_STATUS := STR0028 //"Aguardando Aprovação"
                 EndIf
              EndIf

         Case nOpc == EXC_DET
             If lIsPais
                If !Empty(TR5->TR5_RECNO)
                   aAdd(aDelEX5,TR5->TR5_RECNO)
                EndIf

                If lNovaRotina                
                   
                   nRec := TR5->(RecNo())
                   cOldFilter := TR5->(dbFilter())
                   bOldFilter := &("{|| "+if(Empty(cOldFilter),".t.",cOldFilter)+" }")

                   TR5->(DbClearFilter())
                   TR5->(DbSetOrder(1))
                   TR5->(DbSeek(M->EX5_PAIS))

                   Do While TR5->(!Eof()) .And. TR5->EX5_PAIS == M->EX5_PAIS
                      If (!Empty(TR5->EX5_DTINI) .And. !Empty(TR5->EX5_DTFIM)) .Or.;
                         (!Empty(TR5->EX5_DTINI) .And. Empty(TR5->EX5_DTFIM))
                         lPriceClose := .t.
                         Exit
                      EndIf
                     TR5->(DbSkip())
                   EndDo

                   If !Empty(cOldFilter)
                      TR5->(DbSetFilter(bOldFilter,cOldFilter))
                   EndIf
                   TR5->(dbGoTo(nRec))
                EndIf

                // ** Deleta o pais do tree.
                If !lPriceClose
                   cGalho := "P"+TR5->EX5_PAIS
                   If aC120CheckTree(cGalho)
                      oTree:DelItem()
                      Eval(oTree:bChange)
                      oTree:Refresh()
                      oTree:SetFocus()
                   EndIf
                EndIf

                TR5->(DBDELETE())
             Else
                If !Empty(TR6->TR6_RECNO)
                   aAdd(aDelEX6,TR6->TR6_RECNO)
                EndIf
                
                If lNovaRotina 
                   nRec := TR6->(RecNo())               
                   cOldFilter := TR6->(dbFilter())
                   bOldFilter := &("{|| "+if(Empty(cOldFilter),".t.",cOldFilter)+" }")

                   TR6->(DbClearFilter())
                   TR6->(DbSetOrder(1))
                   TR6->(DbSeek(M->EX6_PAIS+M->EX6_CLIENT+M->EX6_CLLOJA))   // By JPP - 15/04/2005 15:10  - Inclusão da loja na expressão

                   Do While TR6->(!Eof()) .And. TR6->EX6_PAIS   == M->EX6_PAIS .And.;
                                                TR6->EX6_CLIENT == M->EX6_CLIENT .And.;
                                                TR6->EX6_CLLOJA == M->EX6_CLLOJA   // By JPP - 15/04/2005 15:10  - Inclusão da loja na expressão
                      If (!Empty(TR6->EX6_DTINI) .And. !Empty(TR6->EX6_DTFIM)) .Or.;
                         (!Empty(TR6->EX6_DTINI) .And. Empty(TR6->EX6_DTFIM))
                         lPriceClose := .t.
                         Exit                      
                      EndIf
                      TR6->(DbSkip())
                   EndDo

                   If !Empty(cOldFilter)
                      TR6->(DbSetFilter(bOldFilter,cOldFilter))
                   EndIf
                   TR6->(dbGoTo(nRec))
                EndIf
                
                If !lPriceClose                 
                   /* Posiciona inicialmente no pais para depois posicionar
                      no cliente */
                   cGalho := "P"+TR6->EX6_PAIS 
                   aC120CheckTree(cGalho)

                   cGalho := "C"+TR6->EX6_PAIS+TR6->EX6_CLIENT+TR6->EX6_CLLOJA  // By JPP - 15/04/2005 15:10  - Inclusão da loja na expressão  
                   If aC120CheckTree(cGalho)
                      oTree:DelItem()
                      Eval(oTree:bChange)
                      oTree:Refresh()
                      oTree:SetFocus()                      
                   EndIf
                EndIf

                TR6->(DBDELETE())
             EndIf
      EndCase

      If nOpc <> VIS_DET
         If lIsPais
            oMsSelPais:oBrowse:Refresh()
         Else
            oMsSelCli:oBrowse:Refresh()
         EndIf
      EndIf
   EndIf

End Sequence

aTela := aOldaTela
aGets := aOldaGets

Return lRet

/*
Funcao      : aC120Valid(cPtoChamada,nOpc)
Parametros  : cPtoChamada - Identificar o ponto em que a rotina foi disparada. 
                            Executa validações diversas para cada ponto distinto.
              nOpc - INC_DET/ALT_DET/EXC_DET/VIS_DET.
Retorno     : .t./.f.
Objetivos   : Validações diversas.
Autor       : Jeferson Barros Jr.
Data/Hora   : 08/09/04 - 10:35
Revisao     :                                          
Obs.        :
*/
*------------------------------------------*
Function aC120Valid(cPtoChamada,nOpc)
*------------------------------------------*
Local lRet := .t., lErro:=.f., lPriceClose := .f., lPriceOpen  := .f.
Local cMsg, cKey, cOldFilter:="", cAliasTmp, cNCM
Local bOldFilter
Local nRec:=0
Local aOrd := SaveOrd("EIM")

Begin Sequence

   cPtoChamada := Upper(AllTrim(cPtoChamada))

   Do Case
      Case cPtoChamada == "VLD_BUSCA"
         /* Validações para a tela/função de pesquisa na estrutura do tree, apartir do código do Pais ou 
            código do cliente*/

         If Empty(cPais) .And. Empty(cCliente)
            cMsg := STR0050 //"Não há informações suficientes para realizar a pesquisa."
         EndIf

         If !Empty(cCliente) .And. Empty(cPais)
            cMsg := STR0051 //"Para pesquisas a partir do 'Cód.Cliente', o 'Cód.Pais' deverá ser informado."
         EndIf

         If !Empty(cMsg)
            MsgStop(cMsg,STR0022) //"Atenção"
            lRet := .f.
            Break
         EndIf

      Case cPtoChamada == "TABMAN"
         /* Validações para a rotina completa de tabela de preços,
            fase Produto+Pais e Produto+Pais+Cliente. */

         If nOpc == EXC_DET
            If !MsgYesNo(STR0052,STR0022) //"Confirma a exclusão ?"###"Atenção"
               lRet:=.f.
               Break
            EndIf

            If lIsPais
               If lNovaRotina
                  nRec := TR5->(RecNo())
                  cOldFilter := TR5->(dbFilter())
                  bOldFilter := &("{|| "+if(Empty(cOldFilter),".t.",cOldFilter)+" }")

                  TR5->(DbClearFilter())
                  TR5->(DbSetOrder(1))
                  TR5->(DbSeek(M->EX5_PAIS))

                  Do While TR5->(!Eof()) .And. TR5->EX5_PAIS == M->EX5_PAIS
                     If (!Empty(TR5->EX5_DTINI) .And. !Empty(TR5->EX5_DTFIM)) .Or.;
                        (!Empty(TR5->EX5_DTINI) .And. Empty(TR5->EX5_DTFIM))
                        lPriceClose := .t.
                        Exit
                     EndIf
                     TR5->(DbSkip())
                  EndDo

                  If !Empty(cOldFilter)
                     TR5->(DbSetFilter(bOldFilter,cOldFilter))
                  EndIf
                  TR5->(dbGoTo(nRec))
               EndIf

               If !lPriceClose
                  nRec := TR6->(RecNo())
                  cOldFilter := TR6->(dbFilter())
                  bOldFilter := &("{|| "+if(Empty(cOldFilter),".t.",cOldFilter)+" }")

                  TR6->(DbClearFilter())
                  TR6->(DbSetOrder(1))
                  If TR6->(DbSeek(TR5->EX5_PAIS))
                     MsgStop(STR0044+ENTER+; //"Problema:"
                             STR0045+Replic(ENTER,2)+; //"Exclusão não permitida."
                             STR0046+ENTER+; //"Detalhes:"
                             STR0053+ENTER+; //"Não é possível excluir o único lançamento para o país, se o mesmo "
                             STR0054,STR0022) //"possuir cliente(s) associado(s)."###"Atenção"
                     lRet:=.f.
                  EndIf

                  If !Empty(cOldFilter)
                     TR6->(DbSetFilter(bOldFilter,cOldFilter))
                  EndIf
                  TR6->(dbGoTo(nRec))
                  Break
               EndIf
            EndIf
         EndIf

         lRet:= Obrigatorio(aGets,aTela)

         If !lRet
            Break
         EndIf

         If lIsPais
            If nOpc == INC_DET .Or. nOpc == ALT_DET
               If M->EX5_PRECO > 0 .And. Empty(M->EX5_MOEDA)
                  MsgStop(STR0044+ENTER+; //"Problema:"
                          STR0031+AllTrim(AvSx3("EX5_MOEDA",AV_TITULO))+STR0055+Replic(ENTER,2)+; //"O campo '"###"' deverá ser informado."
                          STR0046+ENTER+; //"Detalhes:"
                          STR0056,STR0022) //"Caso o preço tenha sido preenchido, a unidade monetária é obrigatória."###"Atenção"
                  lRet := .f.
                  Break
               EndIf
            EndIf
         EndIf

         /* Verifica se o Pais/Cliente já existe cadastrado no tree. Em caso positivo,
            verifica se a inclusão do preço poderá ser realizada, para isso não deverá
            existir algum preço aguardando aprovação. (Apenas para a rotina nova)*/

         If lNovaRotina .And. nOpc == INC_DET

            cAliasTmp := If(lIsPais,"TR5","TR6")

            cOldFilter := (cAliasTmp)->(dbFilter())
            bOldFilter := &("{|| "+if(Empty(cOldFilter),".t.",cOldFilter)+" }")

            (cAliasTmp)->(DbClearFilter())

            If lIsPais
               /* Validações diversas para inclusão de países. Realiza pesquisa no tree  
                  além de considerar os registros na msselect */

               cKey := "P"+M->EX5_PAIS
               If aC120CheckTree(cKey)
                  If TR5->(DbSeek(M->EX5_PAIS))
                     Do While TR5->(!Eof()) .And. TR5->EX5_PAIS == M->EX5_PAIS
                        If Empty(TR5->EX5_DTINI) .And. Empty(TR5->EX5_DTFIM)
                           lErro := .t.
                           Exit
                        EndIf
                        TR5->(DbSkip())
                     EndDo
                  EndIf
               EndIf

               If lErro
                  MsgStop(STR0057+ENTER+; //"Problema"
                          STR0058+AllTrim(M->EX5_PAIS)+STR0059+Replic(ENTER,2)+; //"O pais '"###"' não poderá ser incluido."
                          STR0046+ENTER+;  //"Detalhes:"
                          STR0060,STR0022) //"O pais já está lançado e possui preço sem aprovação."###"Atenção"
                  lRet := .f.
               EndIf
            Else
               /* Validações diversas para inclusão de clientes. Realiza pesquisa no tree
                  além de considerar os registros na msselect. 
                  - Caso o pais e o cliente já estejam cadastrados, o sistema irá verificar se já 
                    existe algum preço aguardando aprovação, se existir, não irá permitir a 
                    inclusão do novo preço por cliente. */

               cKey := AllTrim("C"+M->EX6_PAIS+M->EX6_CLIENT+M->EX6_CLLOJA)   // By JPP - 15/04/2005 - 13:30 - Inclusão da loja do cliente na expressão

               If aC120CheckTree(cKey)
                 If TR6->(DbSeek(M->EX6_PAIS+M->EX6_CLIENT+M->EX6_CLLOJA)) // By JPP - 15/04/2005 - 13:30 - Inclusão da loja do cliente na expressão
                     Do While TR6->(!Eof()) .And. TR6->EX6_PAIS   == M->EX6_PAIS .And.;
                                                  TR6->EX6_CLIENT == M->EX6_CLIENT .And.;
                                                  TR6->EX6_CLLOJA == M->EX6_CLLOJA

                        If Empty(TR6->EX6_DTINI) .And. Empty(TR6->EX6_DTFIM)
                           lErro := .t.
                           Exit
                        EndIf
                        TR6->(DbSkip())
                     EndDo
                  EndIf
               EndIf

               If lErro
                  MsgStop(STR0057+ENTER+; //"Problema"
                          STR0061+AllTrim(M->EX6_CLIENT)+STR0059+Replic(ENTER,2)+; //"O preço para o cliente '"###"' não poderá ser incluido."
                          STR0046+ENTER+;  //"Detalhes:"
                          STR0062,STR0022) //"O cliente já possui preço sem aprovação."###"Atenção"
                  lRet := .f.
               EndIf
            EndIf

            (cAliasTmp)->(DbGoTop())
            
            If !Empty(cOldFilter)
               (cAliasTmp)->(DbSetFilter(bOldFilter,cOldFilter))
               (cAliasTmp)->(dbGoTop())
            EndIf
         EndIf

      Case cPtoChamada == "TABPRECOCLI"
         /* Validações da rotina de tabela de preços reduzida somente para a fase
            de Produto+Pais+Cliente */

         If nOpc == EXCLUIR
            If !MsgYesNo(STR0052,STR0022) //"Confirma a exclusão ?"###"Atenção"
               lRet:=.f.
               Break
            EndIf
         EndIf

         lRet:= Obrigatorio(aGets,aTela)
         If !lRet
            Break
         EndIf

         If nOpc == INCLUIR
            If lNovaRotina
               // ** Verifica se ja existe preço sem aprovação para este Produto+Pais+Cliente.
               nRec := EX6->(RecNo())

               EX6->(DbSetOrder(1))
               If EX6->(DbSeek(xFilial("EX6")+M->EX6_COD_I+M->EX6_PAIS+M->EX6_CLIENT+M->EX6_CLLOJA)) // By JPP - 15/04/2005 15:10  - Inclusão da loja na expressão
                  Do While EX6->(!Eof()) .And. EX6->EX6_FILIAL == xFilial("EX6") .And.;
                                               EX6->EX6_COD_I  == M->EX6_COD_I   .And.;
                                               EX6->EX6_PAIS   == M->EX6_PAIS    .And.;
                                               EX6->EX6_CLIENT == M->EX6_CLIENT  .And.;
                                               EX6->EX6_CLLOJA == M->EX6_CLLOJA   // By JPP - 15/04/2005 15:10  - Inclusão da loja na expressão       

                     If Empty(EX6->EX6_DTINI) .And. Empty(EX6->EX6_DTFIM)
                        MsgStop(STR0044+ENTER+; //"Problema:"
                                STR0072+Replic(ENTER,2)+; //"Não será possível fazer a inclusão do preço."
                                STR0046+ENTER+; //"Detalhes:"
                                STR0073,STR0022) //"Já existe preço aguardando aprovação para este Prod.+Pais+Client."###"Atenção"
                        EX6->(DbGoTo(nRec))
                        lRet:=.f.
                        Break
                     EndIf

                     EX6->(DbSkip())
                  EndDo
               EndIf

               EX6->(DbGoTo(nRec))
            Else

               /* Para a rotina antiga as datas de aprovação não existem, o sistema 
                  testa apenas se já existe cadastrado preço para o Prod.+Pais+Cliente. */

               nRec := EX6->(RecNo())
               EX6->(DbSetOrder(1))
               If EX6->(DbSeek(xFilial("EX6")+M->EX6_COD_I+M->EX6_PAIS+M->EX6_CLIENT+M->EX6_CLLOJA)) // JPP - 14/04/2005 11:20
                  MsgStop(STR0044+ENTER+; //"Problema:"
                          STR0072+Replic(ENTER,2)+; //"Não será possível fazer a inclusão do preço."
                          STR0046+ENTER+; //"Detalhes:"
                          STR0074,STR0022) //"Já existe preço cadastrado para este Prod.+Pais+Client."###"Atenção"
                  EX6->(DbGoTo(nRec))
                  lRet:=.f.
                  Break
               EndIf
               EX6->(DbGoTo(nRec))
            EndIf
         EndIf
      
      Case cPtoChamada == "B1_POSIPI"
         If !Empty(M->B1_POSIPI) .And. !AllTrim(M->B1_POSIPI) == "00000000"
            lRet := ExistCpo("SYD",M->B1_POSIPI)
         EndIf
         If EasyGParam("MV_EIC0011",,.F.) .AND. !Empty(SB1->B1_POSIPI) .AND. SB1->B1_POSIPI # M->B1_POSIPI  // GFP - 27/10/2016 - Tratamento de exclusão de NVE
            EIM->(DbSetOrder(3))
            //MFR 23/11/2018
            //If EIM->(DbSeek(xFilial("EIM")+AvKey("CD","EIM_FASE")+AvKey(SB1->B1_COD,"EIM_HAWB")+Avkey("001","EIM_CODIGO")+AvKey(SB1->B1_POSIPI,"EIM_NCM")))            
            If EIM->(DbSeek(GetFilEIM("CD")+AvKey("CD","EIM_FASE")+AvKey(SB1->B1_COD,"EIM_HAWB")+Avkey("001","EIM_CODIGO")+AvKey(SB1->B1_POSIPI,"EIM_NCM")))
               cNCM := SB1->B1_POSIPI
               If nModulo == 17 .AND. (lRet := MsgNoYes(STR0126,STR0022))  //"Tabela de NVE vinculada ao produto será excluida, devido a modificação na NCM do produto. Deseja continuar?" ## "Atenção"
                 EasyNVEChk(.T.)  // Quando chamado pelo EIC, executa validação do MATA010
               ElseIf nModulo # 17 // Restante, exibe trava pelo EECAC120
                  Alert(STR0127)//"Produto possui tabela de NVE vinculada. Desta forma, a alteração de NCM do registro deve ser efetuada pelo módulo 'Easy Import Control' (SIGAEIC)."
                  lRet := .F.
               EndIf
               If !lRet
                  M->B1_POSIPI := cNCM
                  EasyNVEChk(.F.)
               EndIf
            EndIf
         EndIf
   EndCase

End Sequence

RestOrd(aOrd,.T.)
Return lRet

/*
Funcao      : aC120Find()
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Pesquisar Pais/Cliente.
Autor       : Jeferson Barros Jr.
Data/Hora   : 07/09/04 - 16:33
Revisao     : 
Obs.        :
*/
*-------------------------*
Static Function aC120Find()
*-------------------------*
Local lRet:=.t.
Local oCliente, oPais, oDlg
Local oPanel
Local nChose := 0, nOldArea := Select()
Local bOk := {|| If(aC120Valid("VLD_BUSCA"),(nChose:=1, oDlg:End()),nil)},;
      bCancel := {|| oDlg:End()}

Private cCliente, cPais

Begin Sequence

   cCliente := Space(AvSx3("EX6_CLIENT",AV_TAMANHO))
   cPais    := Space(AvSx3("EX5_PAIS",AV_TAMANHO))

   Define MsDialog oDlg Title STR0063 From 10,12 To 26.5,50.5 Of oMainWnd //"Pesquisar Pais/Cliente"
   
   	  oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) 
   	  oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @ 1.1, 0.5 TO 4.5,18.5 LABEL STR0064 Of oPanel //"Opções de Pesquisa"

      @ 2.3, 2.5 SAY AvSx3("EX5_PAIS",AV_TITULO) Of oPanel SIZE 35,9
      @ 2.3, 6.8 MSGET cPais SIZE 40,07  F3 "SYA" PICTURE "@!" Valid (Empty(cPais) .Or. ExistCpo("SYA")) Of oPanel

      @ 3.4, 2.5 SAY AvSx3("EX6_CLIENT",AV_TITULO) Of oPanel SIZE 35,9
      @ 3.4, 6.8 MSGET cCliente SIZE 40,07  F3 "CLI" PICTURE "@!" Valid (Empty(cCliente) .Or. ExistCpo("SA1")) Of oPanel
      
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered
   
   If nChose = 1
      dbSelectArea(oTree:cArqTree)
      dbSetOrder(4)

      cCargo := oTree:GetCargo()

      If !Empty(cPais) .And. !Empty(cCliente)
         lFound := oTree:TreeSeek("C"+AvKey(cPais,"EX6_PAIS")+cCliente)
      Else
         lFound := oTree:TreeSeek("P"+AvKey(cPais,"EX5_PAIS"))
      EndIf

      If !lFound
         MsgInfo(STR0065,STR0022) //"Pais/Cliente não encontrado."###"Atenção"
         oTree:TreeSeek(cCargo)
      Else
         Eval(oTree:bChange)
         oTree:Refresh()
      EndIf
   EndIf

End Sequence

DbSelectArea(nOldArea)

Return lRet

/*
Funcao      : aC120TrataObj(cId)
Parametros  : cId - Cargo do tree que disparou o evento.
Retorno     : .t./.f.
Objetivos   : Tratamentos com os objetos da tela.
Autor       : Jeferson Barros Jr.
Data/Hora   : 08/09/04 - 14:38.
Revisao     : 
Obs.        :
*/
*--------------------------------*
Static Function aC120TrataObj(cId)
*--------------------------------*
Local lRet:=.t.
Local cFilter
Local nPos

Begin Sequence

   cId := Upper(AllTrim(cId))

   Do Case
      Case cId == "RAIZ"
           cMemo := cMsg1
           oMemo:Show()
           oMemo:Refresh()
           oMsSelPais:oBrowse:Hide()
           oMsSelCli:oBrowse:Hide()

      Case Left(cId,1) == "P"
           oMemo:Hide()
           oMsSelPais:oBrowse:Show()
           oMsSelCli:oBrowse:Hide()

           TR5->(DbClearFilter())
           cFilter := M->B1_COD+IncSpace(SubStr(cId,2),AvSx3("EX5_PAIS",AV_TAMANHO),.f.)
           
           /* - FSM - 01/08/2011 - Alterado tratamento do filtro para ambiente cTree
           TR5->(DbSetFilter( &("{|| TR5->EX5_COD_I+TR5->EX5_PAIS == '"+cFilter+"'}"),; 
                                   "TR5->EX5_COD_I+TR5->EX5_PAIS == '"+cFilter+"'") ) */

           TR5->( DBEVAL( {|| IIf( TR5->EX5_COD_I+TR5->EX5_PAIS == cFilter,;
                                   TR5->TR5_FILTRO := "S", TR5->TR5_FILTRO := "") } ) )
           TR5->(DbSetFilter( {|| TR5->TR5_FILTRO == "S"} ,"TR5->TR5_FILTRO == 'S'"))


           TR5->(DbGoTop())

           If IsVazio("TR5")
              oMsSelPais:oBrowse:Hide()
              oMsSelCli:oBrowse:Hide()

              cMemo := cMsg2
              oMemo:Show()
              oMemo:Refresh()
           Else
              oMsSelPais:oBrowse:Refresh()
           EndIf
  
      Case Left(cId,1) == "C" 
           oMemo:Hide()
           oMsSelPais:oBrowse:Hide()
           oMsSelCli:oBrowse:Show()

           TR6->(DbClearFilter())
           nPos := AvSx3("EX6_CLIENT",AV_TAMANHO)+AvSx3("EX6_PAIS",AV_TAMANHO)+2  // By JPP - 14/04/2005 10:20  - Define a posição inicial da loja na expressão cId     
           cFilter := M->B1_COD+;
                      SubStr(cId,2,AvSx3("EX6_PAIS",AV_TAMANHO))+;
                      IncSpace(SubStr(cId,AvSx3("EX6_PAIS",AV_TAMANHO)+2),AvSx3("EX6_CLIENT",AV_TAMANHO),.F.)+; // By JPP - 14/04/2005 - 10:20 - Inclusão do campo EX6_CLLOJA no filtro.   
                      IncSpace(SubStr(cId,nPos),AvSx3("EX6_CLLOJA",AV_TAMANHO),.F.)

/* FSM - 01/08/2011 - Alterado tratamento para ambiente cTree

           TR6->(DbSetFilter(&("{|| TR6->EX6_COD_I+TR6->EX6_PAIS+TR6->EX6_CLIENT+TR6->EX6_CLLOJA == '"+cFilter+"'}"),;   // By JPP - 14/04/2005 - 10:20 - Inclusão do campo EX6_CLLOJA no filtro.
                                   "TR6->EX6_COD_I+TR6->EX6_PAIS+TR6->EX6_CLIENT+TR6->EX6_CLLOJA == '"+cFilter+"'")) 
*/
           
           TR6->( DBEVAL( {|| IIf( TR6->EX6_COD_I+TR6->EX6_PAIS+TR6->EX6_CLIENT+TR6->EX6_CLLOJA == cFilter,;
                                   TR6->TR6_FILTRO := "S", TR6->TR6_FILTRO := "") } ) )
           TR6->(DbSetFilter( {|| TR6->TR6_FILTRO == "S"} ,"TR6->TR6_FILTRO == 'S'"))

           TR6->(DbGoTop())         

           oMsSelCli:oBrowse:Refresh()
   EndCase

End Sequence

Return lRet

/*
Funcao      : aC120ChoseAdd()
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Tratamentos com os objetos da tela.
Autor       : Jeferson Barros Jr.
Data/Hora   : 08/09/04 - 18:25.
Revisao     : 
Obs.        :
*/
*-----------------------------*
Static Function aC120ChoseAdd()
*-----------------------------*
Local lRet := .t.
Local oDlg

Begin Sequence

   Define MsDialog oDlg Title STR0066 From 9,0 To 15,30 Of oMainWnd //"Inclusão"
      @ 05,005 To 42,115 LABEL STR0067 Pixel //"O que deseja incluir ?"
      @ 21,025 Button STR0068    Size 35,12 Action (aC120TabMan(INC_DET,"EX5"),oDlg:End()) Of oDlg Pixel //"Pais"
      @ 21,065 Button STR0069 Size 35,12 Action (aC120TabMan(INC_DET,"EX6"),oDlg:End()) Of oDlg Pixel //"Cliente"
   Activate MsDialog oDlg Centered

End Sequence

Return lRet

/*
Funcao      : aC120CheckTree(cCargo,lRestaura)
Parametros  : cCargo    -> Cargo a ser pesquisado.
              lRestaura -> .t. - Restaura a posição do galho/folha anterior à pesquisa no tree.
                           .f. - Deixa posicionado no galho/folha pesquisado.
Retorno     : .t./.f.
Objetivos   : Verificar se o pais/cliente já existe no tree.
Autor       : Jeferson Barros Jr.
Data/Hora   : 09/09/04 - 09:52.
Revisao     : 
Obs.        :
*/
*----------------------------------------------*
Static Function aC120CheckTree(cCargo,lRestaura)
*----------------------------------------------*
Local nOldArea := Select()
Local cOldCargo
Local lRet:=.f.

Default lRestaura := .f.

Begin Sequence

   DbSelectArea(oTree:cArqTree)
   DbGoTop()
   DbSetOrder(4)

   cOldCargo := oTree:GetCargo()
   lRet:= oTree:TreeSeek(cCargo)

   If lRestaura
      oTree:TreeSeek(cOldCargo)
   EndIf

End Sequence

DbSelectArea(nOldArea)

Return lRet

/*
Funcao      : aC120AddGalho(lIsPais)
Parametros  : lIsPais - .t. - Pais.
                        .f. - Cliente.
Retorno     : .t./.f.
Objetivos   : Caso o pais/cliente não exista no tree, faz a inclusão.
Autor       : Jeferson Barros Jr.
Data/Hora   : 09/09/04 - 10:50.
Revisao     : 
Obs.        :
*/
*------------------------------------*
Static Function aC120AddGalho(lIsPais)
*------------------------------------*
Local lRet:=.t., lFound:=.f., lAddFolhaCliente:=.f.,lAddFolhaPais:=.f.
Local cGalho

Begin Sequence

   If lIsPais
      cGalho := "P"+M->EX5_PAIS
      If !aC120CheckTree(cGalho)
          aC120CheckTree("RAIZ") // Posiciona na Raiz.

          oTree:AddItem(Capital(PadR(AllTrim(Posicione("SYA",1,xFilial("SYA")+M->EX5_PAIS,"YA_DESCR")),300)),;
    	 				PadR(AllTrim("P"+M->EX5_PAIS),300),;
		 				"GLOBO"  ,;	
		 				"GLOBO",,,;
		 				2)
          oTree:Refresh()
          oTree:SetFocus()
      EndIf
   Else
      
      // ** Verifica se o cliente e o pais já existem no tree.     
      cGalho := "P"+M->EX6_PAIS
      aC120CheckTree(cGalho)

      cGalho := "C"+M->EX6_PAIS+M->EX6_CLIENT+M->EX6_CLLOJA     // By JPP - 15/04/2005 15:10  - Inclusão da loja na expressão       
      lFound := aC120CheckTree(cGalho)

      If !lFound
         lAddFolhaCliente := .t.

         // ** Verifica se o pais já existe no tree.
         cGalho := "P"+M->EX6_PAIS
         lFound := aC120CheckTree(cGalho)

         If !lFound 
            lAddFolhaPais := .t.
         EndIf
      EndIf

      Do Case
         Case (lAddFolhaPais  .And. lAddFolhaCliente)
              aC120CheckTree("RAIZ") // Posiciona na Raiz.   
              // ** JPM - 25/10/04 - Início
              // ** Adiciona o Pais.
              /*DBADDTREE oTree PROMPT Capital(PadR(AllTrim(Posicione("SYA",1,xFilial("SYA")+M->EX6_PAIS,"YA_DESCR")),300));
                              RESOURCE "GLOBO", "GLOBO";
                              CARGO PadR(AllTrim("P"+M->EX6_PAIS),300)*/
              oTree:AddItem(Capital(PadR(AllTrim(Posicione("SYA",1,xFilial("SYA")+M->EX6_PAIS,"YA_DESCR")),300)),;
    	 				PadR(AllTrim("P"+M->EX6_PAIS),300),;
		 				"GLOBO"  ,;	
		 				"GLOBO",,,;
		 				2)
              /*DBADDITEM oTree PROMPT  Capital(PadR(AllTrim(Posicione("SA1",1,xFilial("SA1")+M->EX6_CLIENT+M->EX6_CLLOJA,"A1_NREDUZ")),300));
                              RESOURCE "CLIENTE";
                              CARGO PadR("C"+AvKey(M->EX6_PAIS,"EX6_PAIS")+AvKey(M->EX6_CLIENT,"EX6_CLIENT"),300)
              DBENDTREE oTree    */
              
                              
              aC120CheckTree("P"+M->EX6_PAIS)//posiciona no país que acabou de ser incluído
              
              // ** Adiciona o Cliente.   // By JPP - 15/04/2005 15:10  - O sistema passou a incluir Cliente + Loja   
              /* oTree:AddItem(Capital(PadR(AllTrim(Posicione("SA1",1,xFilial("SA1")+M->EX6_CLIENT+M->EX6_CLLOJA,"A1_NREDUZ")),300)),;
			 	   		  PadR("C"+AvKey(M->EX6_PAIS,"EX6_PAIS")+AvKey(M->EX6_CLIENT,"EX6_CLIENT"),300),;
			 	           "CLIENTE"  ,;	
			 			     "CLIENTE",,,;
			 		        2) */
			 	  // By JPP - 15/04/2005 - 11:30 - Adiciona cliente + loja
			 	  oTree:AddItem(Capital(PadR(AllTrim(Posicione("SA1",1,xFilial("SA1")+M->EX6_CLIENT+M->EX6_CLLOJA,"A1_NREDUZ"))+" / "+M->EX6_CLLOJA,300)),;
			 	  		  PadR("C"+AvKey(M->EX6_PAIS,"EX6_PAIS")+AvKey(M->EX6_CLIENT,"EX6_CLIENT")+AvKey(M->EX6_CLLOJA,"EX6_CLLOJA"),300),;
			 	        "CLIENTE"  ,;	
			 	        "CLIENTE",,,;
			 		     2)
              // ** JPM - 25/10/04 - Fim
              oTree:Refresh()
              oTree:SetFocus()

         Case lAddFolhaCliente
              aC120CheckTree("P"+M->EX6_PAIS) // Posiciona no pais correspondente.

              // ** Adiciona o Cliente. // By JPP - 15/04/2005 15:10  - O sistema passou a incluir Cliente + Loja         
              /* oTree:AddItem(Capital(PadR(AllTrim(Posicione("SA1",1,xFilial("SA1")+M->EX6_CLIENT+M->EX6_CLLOJA,"A1_NREDUZ")),300)),;
   	 		   	  PadR("C"+AvKey(M->EX6_PAIS,"EX6_PAIS")+AvKey(M->EX6_CLIENT,"EX6_CLIENT"),300),;
			 			  "CLIENTE"  ,;	
			 			  "CLIENTE",,,;
			 			  2) */
			 	  // By JPP - 15/04/2005 - 11:30 - Adiciona Cliente + loja		
			 	  oTree:AddItem(Capital(PadR(AllTrim(Posicione("SA1",1,xFilial("SA1")+M->EX6_CLIENT+M->EX6_CLLOJA,"A1_NREDUZ"))+" / "+M->EX6_CLLOJA,300)),;
			 	   	  PadR("C"+AvKey(M->EX6_PAIS,"EX6_PAIS")+AvKey(M->EX6_CLIENT,"EX6_CLIENT")+AvKey(M->EX6_CLLOJA,"EX6_CLLOJA"),300),;
			 			  "CLIENTE"  ,;	
			 			  "CLIENTE",,,;
			 			  2) 
			 	 	   	
      EndCase
   EndIf

End Sequence

Return lRet

/*
Funcao      : TabPrecoCli().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Rotina de Tabela de Preco por cliente. Os preços são cadastrados diretamente no EX6 sem que o
              usuário trabalhe com qualquer informação no EX5. Os controles de integridade referencial são
              realizados internamente ficando sempre transparentes ao usuário.
Autor       : Jeferson Barros Jr.
Data/Hora   : 13/09/04 - 13:38.
Revisao     :
Obs.        :
*/
*--------------------*
Function TabPrecoCli()
*--------------------*
Local lRet := .t.
Local nOldArea:=select()

Private aRotina := MenuDef(.T., "EECTP200")
                    
Private aHeader:={}, aCampos:={}

Private lNovaRotina := .f., lRotPrecoCliente := .t.
Private cCadastro := STR0019 //"Tabela de Preços"
Begin Sequence

   SX3->(DBSETORDER(2))
   If !SX3->(DbSeek("EX5_FILIAL")) .Or. !SX3->(DbSeek("EX6_FILIAL"))
      MsgStop(STR0044+ENTER+; //"Problema:"
              STR0075+Replic(ENTER,2)+; //"A tabela de preço por cliente não poderá ser utilizada."
              STR0046+ENTER+; //"Detalhes:"
              STR0076+ENTER+; //"As tabelas necessárias para utilização da tabela de preço por "
              STR0077,STR0022) //"cliente não estão disponíveis no ambiente atual."###"Atenção"
      lRet:=.f.
      Break
   EndIf

   If EX5->(FieldPos("EX5_DTINI"))  > 0 .And. EX5->(FieldPos("EX5_DTFIM")) > 0 .And.;
      EX6->(FieldPos("EX6_DTINI"))  > 0 .And. EX6->(FieldPos("EX6_DTFIM")) > 0

      lNovaRotina := .t.
   EndIf

   mBrowse(6, 1, 22, 75,"EX6")

End Sequence

DbSelectArea(nOldArea)

Return lRet

/*
Funcao      : TabCliMan
Parametros  : cAlias:= alias arq.
              nReg:=num.registro
              nOpc:=opcao escolhida
Retorno     : .t./.f.
Objetivos   : Manutencao de preços por Produto+Pais+Cliente.
Autor       : Jeferson Barros Jr
Data/Hora   : 13/09/2004 14:14.
Revisao     :
Obs.        :
*/
*----------------------------------*
Function TabCliMan(cAlias,nReg,nOpc)
*----------------------------------*
Local lRet:=.t., lDeletaPais:=.t.,oDlg
Local nChoice := 0, nRec:=0, j:=1
Local aPos:={}, aEnchoice:={},aAltera:={}
Local bCancel := {|| oDlg:End()}, bOk
Local oMsmGet

Private aTela:={}, aGets:={}

Begin Sequence

   If lNovaRotina
      If (nOpc == ALTERAR .Or. nOpc == EXCLUIR)
         If !Empty(EX6->EX6_DTINI) .Or. !Empty(EX6->EX6_DTINI)
            MsgStop(STR0044+ENTER+; //"Problema:"
                    STR0078+Replic(ENTER,2)+; //"Este item não poderá ser alterado/excluido."
                    STR0046+ENTER+; //"Detalhes:"
                    STR0079+ENTER+; //"O item selecionado já foi aprovado e não poderá sofrer alterações "
                    STR0080,STR0022) //"ou ser excluido."###"Atenção"
            lRet:=.f.
            Break
         EndIf
      EndIf
   EndIf

   If nOpc == ENCERRAR  // GFP - 01/11/2013
      If !Empty(EX6->EX6_DTAPRO)
         If !Empty(EX6->EX6_DTFIM)
             EasyHelp(STR0119,STR0033) //"Não é possível encerrar uma tabela que já possui uma data de término."  ###  "Aviso"
             lRet:=.f.
             Break
         EndIf
      Else
         EasyHelp(STR0120 + CHR(13)+CHR(10) + STR0121,STR0033)//"Não é possível encerrar uma tabela que não foi aprovada." ### "Utilize a opção 'Excluir'."  ### "Aviso" 
         lRet:=.f.
         Break
      EndIf
   EndIf  

   cTitulo := STR0048+STR0081 //"Manutenção de Preços - " //"(Produto+Pais+Cliente) "

   If (nOpc == INCLUIR)
      aAlTera := {"EX6_COD_I","EX6_CLIENT","EX6_CLLOJA","EX6_MOEDA","EX6_PRECO"}
   ElseIf (nOpc == ALTERAR)
      aAlTera := {"EX6_MOEDA","EX6_PRECO"}
   ElseIf (nOpc == ENCERRAR)  // GFP - 01/11/2013
      aAlTera := {}
   EndIf

   /* Carrega os campos que serão exibidos/alteraos na enchoice
      do preço por produto+pais+cliente. */

   Sx3->(DbSetOrder(1))                             	
   If Sx3->(DbSeek("EX6"))
      Do While Sx3->(!Eof()) .And. Sx3->X3_ARQUIVO == "EX6"
         If X3Uso(SX3->X3_USADO)
            If Sx3->X3_PROPRI <> "U"
               aAdd(aEnchoice,AllTrim(Sx3->X3_CAMPO))
            Else
               If aScan(aEnchoice,AllTrim(Sx3->X3_CAMPO)) = 0
                  aAdd(aEnchoice,AllTrim(Sx3->X3_CAMPO))
               EndIf

               If aScan(aAlTera,AllTrim(Sx3->X3_CAMPO)) = 0
                  aAdd(aAlTera ,AllTrim(Sx3->X3_CAMPO))
               EndIf
            EndIf
         EndIf
         Sx3->(DbSkip())
      EndDo
   EndIf

   If (nOpc == INCLUIR)
      For j := 1 TO EX6->(FCount())
         M->&(EX6->(FieldName(j))) := CriaVar(EX6->(FieldName(j)))
      Next

      bOk := {|| If(aC120Valid("TABPRECOCLI",nOpc),(nChoice := 1, oDlg:End()),nil)}
   Else
      For j := 1 TO EX6->(FCount())
         M->&(EX6->(FieldName(j))) := EX6->(FieldGet(j))
      Next

      bOk := {|| If(aC120Valid("TABPRECOCLI",nOpc),(nChoice := 1, oDlg:End()),nil)}

      If nOpc = VISUALIZAR
         bOk := {|| nChoice := 1, oDlg:End()}
      EndIf
   EndIf

   Define MsDialog oDlg Title cTitulo From 9,0 To /*35*/40,80 Of oMainWnd  // GFP - 24/04/2012
      aPos := PosDlg(oDlg)
      //EnChoice("EX6",,nOpc,,,,aEnchoice,aPos,aAltera,3) //comentado por wfs
      oMsmGet:= MsmGet():New("EX6",,nOpc,,,,aEnchoice,aPos,aAltera,3)
      oMsmGet:oBox:Align:= CONTROL_ALIGN_ALLCLIENT
      //OAP - 26/10/2010 - É necessário que se passe anpenas nOpc para que os campos criados pelo usuário sejam apenas visuais em nOpc = 3
      //EnChoice("EX6",,If(nOpc=INCLUIR,3,4),,,,aEnchoice,aPos,aAltera,3)
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

   If nChoice = 1
      Begin Transaction

         Do Case
            Case nOpc == INCLUIR
                 EX5->(DbSetOrder(1))
                 If !EX5->(DbSeek(xFilial("EX5")+M->EX6_COD_I+M->EX6_PAIS))
                    If EX5->(RecLock("EX5",.t.))
                       EX5->EX5_FILIAL := xFilial("EX5")
                       EX5->EX5_COD_I  := M->EX6_COD_I
                       EX5->EX5_PAIS   := M->EX6_PAIS
                       EX5->EX5_PRECO  := 0

                       If EX6->(RecLock("EX6",.t.))
                          AvReplace("M","EX6")
                          EX6->EX6_FILIAL := xFilial("EX6")
                       EndIf
                    EndIf
                 Else
                    If EX6->(RecLock("EX6",.t.))
                       AvReplace("M","EX6")
                       EX6->EX6_FILIAL := xFilial("EX6")
                    EndIf
                 EndIf

            Case nOpc == ALTERAR
                 If EX6->(RecLock("EX6",.f.))
                    AvReplace("M","EX6")
                 EndIf

            Case nOpc == EXCLUIR

                 EX5->(DbSetOrder(1))
                 If EX5->(DbSeek(xFilial("EX5")+M->EX6_COD_I+M->EX6_PAIS))
                    // Verifica se o pais possui lançamentos com preço aprovado.
                    Do While EX5->(!Eof()) .And. EX5->EX5_FILIAL == xFilial("EX5") .And.;
                                                 EX5->EX5_COD_I  == M->EX6_COD_I .And.;
                                                 EX5->EX5_PAIS   == M->EX6_PAIS
                       If EX5->EX5_PRECO > 0
                          lDeletaPais := .f.
                          Exit
                       EndIf
                       EX5->(DbSkip())
                    EndDo
                 EndIf

                 // ** Caso o pais não possuir preço aprovado, verifica se existem outros paises vinculados.
                 If lDeletaPais
                    nRec := EX6->(RecNo())
                    EX6->(DbSetOrder(1))
                    If EX6->(DbSeek(xFilial("EX6")+M->EX6_COD_I+M->EX6_PAIS))
                       Do While EX6->(!Eof()) .And. EX6->EX6_FILIAL == xFilial("EX6") .And.;
                                                    EX6->EX6_COD_I  == M->EX6_COD_I   .And.;
                                                    EX6->EX6_PAIS   == M->EX6_PAIS 
                          If EX6->(RecNo()) <> nRec
                             lDeletaPais := .f.                          
                             Exit
                          EndIf                        
                          EX6->(DbSkip())
                       EndDo

                    EX6->(DbGoTo(nRec))
                    Endif
                 Endif

                 If lDeletaPais
                    EX5->(DbSetOrder(1))
                    If EX5->(DbSeek(xFilial("EX5")+M->EX6_COD_I+M->EX6_PAIS))
                       If EX5->(RecLock("EX5",.f.))
                          EX5->(DbDelete())

                          If EX6->(RecLock("EX6",.f.))
                             EX6->(DbDelete())
                          EndIf
                       EndIf
                    EndIf
                 Else
                    If EX6->(RecLock("EX6",.f.))
                       EX6->(DbDelete())
                    EndIf
                 EndIf
            Case nOpc == ENCERRAR  // GFP - 01/11/2013
               If MsgNoYes(STR0122,STR0033)//"Deseja encerrar a tabela vigente?"  ###  "Aviso"
                  If EX6->(RecLock("EX6"))
                     EX6->EX6_DTFIM := dDataBase
                     EX6->(MsUnlock())
                  EndIf                 
               EndIf            
         EndCase

      End Transaction
   EndIf 

End Sequence

Return lRet

/*
Funcao      : StartTree
Parametros  : Nenhum.
Retorno     : nil
Objetivos   : Carregar o Tree explodido no nível da raiz.
Autor       : Jeferson Barros Jr
Data/Hora   : 08/10/2004 10:53.
Revisao     :
Obs.        :
*/
Static Function StartTree()
  oTree:TreeSeek("RAIZ")
Return nil

/*
Funcao      : AC120Normas()
Parametros  : cAlias, nOpc
Retorno     : NIL
Objetivos   : Cria MsGetDados para manutenção da amarração de Produtos x Normas
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 06/12/2004 - 14:20
Revisao     :
Obs.        :
*/
Static Function AC120Normas(cAlias,nOpc)

Local i,j,nDiferent,  nOpcao := 0        

Private aCols   := {}, aHeader := {}  ,;
        bOK     := {|| lBtOK:= .T.,oDlgNor:End() },;
        bCancel := {|| oDlgNor:End() },;
        aAltera := {}

Begin sequence             
   If SB1->(DbSeek(xFilial("SB1")+M->B1_COD)) .and. nOpc == 3
      MsgInfo(STR0087,STR0033)//"O código do produto digitado já existe."/"Aviso"
      Break                                                     
   Endif
                           
   aCols   := aClone(aColsNor)
   aHeader := aClone(aHeaderNor)  //carrega o aCols e o aHeader
   
   If nOpc == 3 .or. nOpc == 4
      AAdd(aAltera,aHeaderNor[1][2]) 
      AAdd(aAltera,aHeaderNor[3][2])  //Define quais campos poderão ser alterados
   Endif                                                                          
  
   DEFINE MSDIALOG oDlgNor TITLE STR0088 + Alltrim(M->B1_COD) FROM 10, 10 TO 500, 790 OF oMainWnd Pixel //"Vinculação de Normas para o produto "###
   
   oPanel:= TPanel():New(0, 0, "", oDlgNor,, .F., .F.,,, 90, 165) //LRS - 18/05/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
   
   oMSGet:= MSGetDados():New(13, 2, 247, 390, nOpc,"AC120NorOK",,,.T.,aAltera,,,500,,,,,oPanel)
                                                
   oMSGet:ForceRefresh()
   
   lBtOK:= .F.
  
   ACTIVATE MSDIALOG oDlgNor ON INIT EnchoiceBar(oDlgNor,{|| if(AC120NorOK(),EVAL(bOk),.F.)},bCancel) CENTERED  
   
   If lBtOK  //Se clicar em OK                 
      // Adiciona no aNorDelete os itens que foram alterados e não devem existir mais
      For i := 1 to len(aColsNor)
         nDiferent := 0
         For j := 1 to len(aCols)
            nDiferent += AScan(aCols, {|x| x[1] == aColsNor[i][1] .and. x[3] == aColsNor[i][3] } ) 
         Next
         If nDiferent <= 0
            AAdd(aNorDelete,aColsNor[i])
         Endif
      Next 
      aColsNor := {}  //reinicializa o aColsNor
      nCont := 1  
      For i := 1 to len(aCols) 
         //Adiciona os itens não deletados no aColsNor
         If !aCols[i][len(aCols[i])] .and. !Empty(aCols[i][1]) .and. !Empty(aCols[i][3]) 
            AAdd(aColsNor,aCols[i])
            nCont +=1
         Endif                           
         //Adiciona no aNorDelete os itens a serem deletados
         If aCols[i][len(aCols[i])]
            If EXN->(DbSeek(cFilEXN+M->B1_COD+AvKey(aCols[i][1],"EXN_PAIS")+AvKey(aCols[i][3],"EXN_NORMA")))  
               Aadd(aNorDelete,aCols[i])
            Endif
         Endif            
      Next
   Endif    
   
End Sequence    

Return Nil

/*
Funcao      : AC120HdNor()
Parametros  : 
Retorno     : NIL
Objetivos   : Constrói o array aHeader para a MsGetDados
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 06/12/2004 - 16:18
Revisao     :
Obs.        :
*/
Static Function AC120HdNor()     

Begin Sequence      

   aAdd(aHeaderNor,{AVSX3("EXN_PAIS"  ,AV_TITULO),"EXN_PAIS"  ,AVSX3("EXN_PAIS"  ,AV_PICTURE),;
                 AVSX3("EXN_PAIS"  ,AV_TAMANHO),AVSX3("EXN_PAIS"  ,AV_DECIMAL),'EVAL(AVSX3("EXN_PAIS"  ,7))',;
                 nil,AVSX3("EXN_PAIS"  ,AV_TIPO) ,nil,nil } )

   aAdd(aHeaderNor,{AVSX3("EXN_PAISDE",AV_TITULO),"EXN_PAISDE",AVSX3("EXN_PAISDE",AV_PICTURE),;
                 AVSX3("EXN_PAISDE",AV_TAMANHO),AVSX3("EXN_PAISDE",AV_DECIMAL),'EVAL(AVSX3("EXN_PAISDE",7))',;
                 nil,AVSX3("EXN_PAISDE",AV_TIPO) ,nil,nil } )
   
   aAdd(aHeaderNor,{AVSX3("EXN_NORMA" ,AV_TITULO),"EXN_NORMA" ,AVSX3("EXN_NORMA" ,AV_PICTURE),;
                 AVSX3("EXN_NORMA" ,AV_TAMANHO),AVSX3("EXN_NORMA" ,AV_DECIMAL),'EVAL(AVSX3("EXN_NORMA" ,7))',;
                 nil,AVSX3("EXN_NORMA" ,AV_TIPO) ,nil,nil } )
   
   aAdd(aHeaderNor,{AVSX3("EXN_NORMDE",AV_TITULO),"EXN_NORMDE",AVSX3("EXN_NORMDE",AV_PICTURE),;
                 AVSX3("EXN_NORMDE",AV_TAMANHO),AVSX3("EXN_NORMDE",AV_DECIMAL),'EVAL(AVSX3("EXN_NORMDE",7))',;
                 nil,AVSX3("EXN_NORMDE",AV_TIPO) ,nil,nil } )    
                 
End Sequence      

Return Nil                                                                         

/*
Funcao      : AC120ColNor()
Parametros  : 
Retorno     : NIL
Objetivos   : Carrega o array aCols para a MsGetDados
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 06/12/2004 - 16:31
Revisao     :
Obs.        :
*/
Static Function AC120ColNor()

Begin Sequence               
   
   //If EXN->(DBSeek(cFilEXN+M->B1_COD)) nopado por WFS em 05/01/2010 - Fiesp
   If EXN->(DBSeek(cFilEXN + M->B1_COD)) .And. !Empty(M->B1_COD) //WFS 05/01/2010
      While EXN->(!EoF()) .And. EXN->EXN_FILIAL == cFilEXN .And. EXN->EXN_PROD == M->B1_COD
         aAdd( aColsNor, Array( Len(aHeaderNor)+1 ) )
         aColsNor[len(aColsNor)][1] := EXN->EXN_PAIS   //codigo do pais 
         aColsNor[len(aColsNor)][2] := Posicione("SYA",1,xFilial("SYA")+EXN->EXN_PAIS,"YA_DESCR")//descricao do pais
         aColsNor[len(aColsNor)][3] := EXN->EXN_NORMA //codigo da norma
         aColsNor[len(aColsNor)][4] := E_MSMM(Posicione("EEI",1,xFilial("EEI")+EXN->EXN_NORMA,"EEI_DESC"),60) //descricao da norma
         aColsNor[Len(aColsNor)][Len(aHeaderNor)+1] := .F.    
         EXN->(DbSkip())
      EndDo
   Endif
   
End Sequence

Return Nil       

/*
Funcao      : AC120NorOK()
Parametros  : 
Retorno     : .t./.f.
Objetivos   : Valida a linha da MsGetDados
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 08/12/2004 - 16:47
Revisao     :
Obs.        :
*/

Function AC120NorOK()
     
Local lRet := .t., nPaisNorma := 0, i := 0

Begin Sequence      
   for i := 1 to len(aCols) //procura se existe uma linha igual à atual(inclusive a própria)
      if aCols[i,1] == aCols[n,1] .and. !aCols[i,len(aCols[i])] .and. ;
         aCols[i,3] == aCols[n,3] .and. !aCols[n,len(aCols[i])]
         nPaisNorma += 1
      Endif
   next    
   If nPaisNorma > 1 //se houver 2 ou mais linhas iguais....
      MsgInfo(STR0089,STR0033)//"Esta vinculação já existe."	/"Aviso"
      lRet := .f.
   Endif
     
End Sequence

Return lRet            

/*
Funcao      : AC120NorF3()
Parametros  : 
Retorno     : bRet
Objetivos   : Filtro para o F3 de normas para itens do pedido e do embarque
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 09/12/2004 - 15:39
Revisao     :
Obs.        :
*/

Function AC120NorF3()
     
Local bRet := "", cAlias, cAlias2, cPais := "" , cProd := ""

Begin Sequence  

      cAlias  := If(Type("EE8_COD_I")  <> "U","EE8","EE9")
      cProd   := M->&(cAlias+"_COD_I")         
      cAlias2 := If(Type("EE7_IMPORT") <> "U","EE7","EEC")         
      cPais   := M->&(cAlias2+"_PAISET")
      If Empty(cProd) .or. Empty(cPais)
         cProd := ""
         cPais := "" 
      Endif
      
End Sequence

Return cProd + cPais

/*
Funcao      : AC120NorVal()
Parametros  : 
Retorno     : .f./.t.
Objetivos   : Validação para normas do produto em pedido/embarque
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 15/12/04 - 10:00
Revisao     :
Obs.        :
*/

Function AC120NorVal(cCampo)
     
Local lRet := .t. , cProd, cPais, cNorma

Begin Sequence
   
   If cCampo == "EE8_CODNOR"
      cProd  := M->EE8_COD_I
      cPais  := M->EE7_PAISET
      cNorma := M->EE8_CODNOR
   ElseIf cCampo == "EE9_CODNOR"
      cProd  := M->EE9_COD_I
      cPais  := M->EEC_PAISET
      cNorma := M->EE9_CODNOR
   EndIf
   EXN->(DbSetOrder(1))
   If !EXN->(DbSeek(xFilial("EXN")+cProd+cPais+cNorma))     
      EEI->(DbSetOrder(1))
      If EEI->(DbSeek(xFilial("EEI")+cNorma))
         MsgStop(STR0090,STR0033)//"A Norma digitada não está vinculada a este produto."/"Aviso"
      Else
         MsgStop(STR0091,STR0033)//"A Norma digitada não está cadastrada."/"Aviso"
      Endif
      lRet := .f.
   Endif
      
End Sequence

Return lRet

/*
Funcao      : AC120Copia()
Parametros  : 
Retorno     : nil 
Objetivos   : Tela para copia de dados complementares do produto
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 13/12/2004 - 13:50
Revisao     :
Obs.        :
*/

Static Function AC120Copia(nOpc)    
Local nBtOk  := 0 

Local bOk ,bCancel, i
                     
Local nLinha := 20, nDlgLinha := 300, nColuna := 16, nRec ,oDlgCopy, oPanel
Local nTCpoProd:= AvSx3("B1_COD",AV_TAMANHO) * 3.7 //WFS 28/01/2009

Private lCopyPreco := .f., lCopyIdiomas := .f., lCopyEmbal := .f., lCopyNorma := .f., lCopyCapa := .f.  
Private cProduto := Space(AvSx3("B1_COD",AV_TAMANHO))

Begin Sequence 
   If SB1->(DbSeek(xFilial("SB1")+M->B1_COD)) .and. nOpc == 3
      MsgInfo(STR0092,STR0033)//"O código do produto digitado já existe."/"Aviso"
      Break                                                     
   Endif
   
   If !lCompEmb
      nDlgLinha -= 26
   Endif
   
   If !lNormaProd
      nDlgLinha -= 26          			
   Endif
   
   If !lEX5EX6
      nDlgLinha -= 26
   Endif
   nRec := SB1->(RecNo())
   SB1->(DbSetOrder(1))
   //DEFINE MSDIALOG oDlgCopy TITLE STR0093 FROM 1,1 TO nDlgLinha,350 OF oMainWnd Pixel //"Cópia de dados complementares"
   DEFINE MSDIALOG oDlgCopy TITLE STR0093 FROM 0,0 TO nDlgLinha,450 OF oMainWnd Pixel //"Cópia de dados complementares"
      
      AvBorda(oDlgCopy)
      oPanel:= TPanel():New(0, 0, "", oDlgCopy,, .T., ,,,0, 0,,.T.)
      
      @ nLinha,nColuna CHECKBOX lCopyCapa PROMPT STR0110 OF oPanel SIZE 90,8 PIXEL //"Dados da Capa"
      
      @ nLinha += 13,nColuna CHECKBOX lCopyIdiomas   PROMPT STR0094 OF oPanel SIZE 90,8 PIXEL //"Descrições em outros idiomas"
      
      If lEX5EX6
         @ nLinha += 13,nColuna CHECKBOX lCopyPreco  PROMPT STR0095 OF oPanel SIZE 90,8 PIXEL //"Tabela de Preços"
      Endif
      
      If lCompEmb
         @ nLinha += 13,nColuna CHECKBOX lCopyEmbal  PROMPT STR0096 OF oPanel SIZE 90,8 PIXEL //"Composição de Embalagens"
      Endif
      
      If lNormaProd
         @ nLinha += 13, nColuna CHECKBOX lCopyNorma PROMPT STR0097 OF oPanel SIZE 150,8 PIXEL //"Amarracao de Produtos x Paises x Normas"
      Endif 
      
      @ nLinha += 13,nColuna     Say STR0098 of oPanel PIXEL //"Produto:"
      //@ nLinha      ,nColuna +30 MsGet cProduto SIZE 40,8 F3 "SB1" of oDlgCopy PIXEL  WFS 28/01/2009
      @ nLinha, nColuna + 30 MsGet cProduto SIZE nTCpoProd,8 F3 "SB1" of oPanel PIXEL
      
      bOk := {|| If(Ac120ValCopy(),(nBtOk := 1, oDlgCopy:End()),nil)}
   
      bCancel   := {|| oDlgCopy:End()}

      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
      
   ACTIVATE MSDIALOG oDlgCopy ON INIT EnchoiceBar(oDlgCopy,bOk,bCancel,,,,,,,.F.) CENTERED      
  
   If nBtOk == 0
      Break
   Endif    
   
   If M->B1_COD == cProduto
      MsgInfo(STR0099,STR0033)//"Não é possível copiar dados do produto atual."/"Aviso"
      Break
   Endif
   If !MsgYesNo(STR0100 + Alltrim(cProduto) + STR0101, STR0033)
              //"Deseja copiar dados do produto "####//"? (Os dados já existentes serão apagados.)" //"Aviso"
      Break
   Endif
   
   If lCopyCapa
      
      For i := 1 To SB1->(FCount())
         IF AScan(aCposEnchoice,SB1->( FieldName(i) ) ) = 0 .Or. SB1->( FieldName(i) ) == "B1_COD"
            Loop
         Endif
          M->&(SB1->(FieldName(i))) := SB1->(FieldGet(i))
      Next i
      
      aOrd := SaveOrd("SX3",1)      
      SX3->(dbSeek("SB1"))      
      While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SB1"
         IF Upper(SX3->X3_CONTEXT) == "V"
            M->&(SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
         Endif            
         SX3->(dbSkip())
      Enddo      
      RestOrd(aOrd)
      
   EndIf
   
   If lCopyPreco 
      TR5->(DbGoTop())
      While TR5->(!EoF())
         If TR5->TR5_RECNO > 0
            AAdd(aDelEX5,TR5->TR5_RECNO)
         Endif
         TR5->(DbSkip())
      EndDo
      DbSelectArea("TR5")
      TR5->(avzap()) ///Zap
      EX5->(DBSETORDER(1))
      EX5->(DBSEEK(XFILIAL("EX5")+cProduto))
      DO WHILE ! EX5->(EOF()) .AND.;
         EX5->(EX5_FILIAL+EX5_COD_I) = (XFILIAL("EX5")+cProduto)
         TR5->(DBAPPEND())
         AVREPLACE("EX5","TR5")
         TR5->EX5_COD_I := M->B1_COD
          
         If lNovaRotina
            Do Case
               Case Empty(TR5->EX5_DTINI) .And. Empty(TR5->EX5_DTFIM)
                    If TR5->EX5_PRECO > 0
                       TR5->TR5_STATUS := STR0028 //"Aguardando Aprovação"
                    Else
                       TR5->TR5_STATUS := STR0049 //"Sem Preço"
                    Endif
                    
                Case !Empty(TR5->EX5_DTINI) .And. Empty(TR5->EX5_DTFIM)
                    if TR5->EX5_DTAPRO >= dDatabase 
                       TR5->TR5_STATUS := STR0082 + DtoC(TR5->EX5_DTINI) //"Ativo a partir de "
                    Else
                       TR5->TR5_STATUS := STR0029 //"Ativo"
                    Endif  
                 
               Case !Empty(TR5->EX5_DTINI) .And. !Empty(TR5->EX5_DTFIM)
                    TR5->TR5_STATUS := If(dDataBase <= TR5->EX5_DTFIM,STR0029,STR0030) //"Ativo"###"Inativo"
            EndCase
         EndIf
           
         SYA->(DBSETORDER(1))
         SYA->(DBSEEK(XFILIAL("SYA")+EX5->EX5_PAIS))
         TR5->EX5_PAISDE := SYA->YA_DESCR
         TR5->TR5_RECNO  := 0
         TR5->TRB_ALI_WT := "EX5"
         TR5->TRB_REC_WT := EX5->(Recno())
         EX5->(DBSKIP())
      ENDDO
      
      TR6->(DbGoTop())
      While TR6->(!EoF())
         If TR6->TR6_RECNO > 0
            AAdd(aDelEX6,TR6->TR6_RECNO)
         Endif
         TR6->(DbSkip())
      EndDo
      DbSelectArea("TR6")
      TR6->(avzap()) //ZAP
      EX6->(DbSetOrder(1))
      EX6->(DbSeek(xFilial("EX6")+cProduto))
      Do While ! EX6->(EOF()) .AND.;
         EX6->(EX6_FILIAL+EX6_COD_I) = (XFILIAL("EX6")+cProduto)
         TR6->(DBAPPEND())
         AVREPLACE("EX6","TR6")
         TR6->EX6_COD_I := M->B1_COD
                  
         If lNovaRotina
            Do Case
               Case Empty(TR6->EX6_DTINI) .And. Empty(TR6->EX6_DTFIM)
                  TR6->TR6_STATUS := STR0028 //"Aguardando Aprovação"
               Case !Empty(TR6->EX6_DTINI) .And. Empty(TR6->EX6_DTFIM)
                  If TR6->EX6_DTAPRO >= dDatabase
                     TR6->TR6_STATUS := STR0082 + DtoC(TR6->EX6_DTINI) //"Ativo a partir de "
                     Else   
                        TR6->TR6_STATUS := STR0029 //"Ativo"
                     Endif
                       
               Case !Empty(TR6->EX6_DTINI) .And. !Empty(TR6->EX6_DTFIM)
                  TR6->TR6_STATUS := If(dDataBase <= TR6->EX6_DTFIM,STR0029,STR0030) //"Ativo"###"Inativo"
            EndCase
            SA1->(DbSetOrder(1))                                          // By JPP 07/01/05 - 16:40 - O campo EX6_CLIEDE só existe se o sistema estiver rodando a rotina nova de tabela de preços.
            SA1->(DbSeek(xFilial("SA1")+EX6->EX6_CLIENT+EX6->EX6_CLLOJA))
            TR6->EX6_CLIEDE := SA1->A1_NOME
         EndIf
            
         SYA->(DBSETORDER(1))
         SYA->(DBSEEK(XFILIAL("SYA")+EX6->EX6_PAIS))
         TR6->EX6_PAISDE := SYA->YA_DESCR
        

         TR6->TR6_RECNO := 0
         TR6->TRB_ALI_WT:= "EX6"
         TR6->TRB_REC_WT:= EX6->(Recno())
         EX6->(DBSKIP())
      ENDDO   
   Endif
   
   If lCopyIdiomas
      TEMP_EE2->(DbGoTop())
      While Temp_EE2->(!EoF()) 
         IF Temp_EE2->EE2_RECNO <> 0         
            aAdd(aDeleteEE2,Temp_EE2->EE2_RECNO)
         Endif
         Temp_EE2->(DbSkip())
      EndDo  
      DbSelectArea("TEMP_EE2")
      TEMP_EE2->(avzap()) //Zap
      EE2->(DbSetOrder(2))
      If EE2->(DbSeek(xFilial("EE2")+"3"+"*"+cProduto))
         While EE2->EE2_FILIAL == xFilial("EE2") .and. EE2->EE2_CODCAD == "3" .and. ;
               AvKey(EE2->EE2_COD,"B1_COD") == AvKey(cProduto,"B1_COD") .and. EE2->(!EoF())
            Temp_EE2->(dbAppend())
            AvReplace("EE2","Temp_EE2")
            Temp_EE2->EE2_RECNO  := 0
            Temp_EE2->EE2_COD    := M->B1_COD   
            Temp_EE2->EE2_VM_TEX := MSMM(EE2->EE2_TEXTO,AVSX3("EE2_VM_TEX",AV_TAMANHO))
            Temp_EE2->TRB_ALI_WT := "EE2"
            Temp_EE2->TRB_REC_WT := EE2->(Recno())
            EE2->(dbSkip())  
         EndDo
      EndIf
          
      TEMP_EE2->(DbGoTop())
   Endif
      
   If lCopyEmbal  
      WkPro->(DbGoTop())
      WkEmb->(DbGoTop())
                        
      While WkPro->(!EoF())
         //WkPro->DELETE := .t.
         AAdd(aDeleteEEW,WkPro->(xFilial("EEW")+M->B1_COD+EEW_SEQUEN))
         WkPro->(DbSkip())
      EndDo
      
      While WkEmb->(!EoF())
         //WkEmb->DELETE := .t.
         AAdd(aDeleteEEV,WkEmb->(xFilial("EEV")+M->B1_COD+EEV_SEQUEN))
         WkEmb->(DbSkip())
      EndDo   
      
      DbSelectArea("WkPro")
      WkPro->(avzap()) //Zap
      DbSelectArea("WkEmb")
      WkEmb->(avzap()) //Zap
      
      EEV->(dbSetOrder(1))
      EEW->(dbSetOrder(1))
      EEV->(dbSeek(xFilial("EEV")+cProduto))
                  
      While EEV->(!Eof() .And. EEV_FILIAL == xFilial("EEV")) .And.;
            EEV->EEV_COD_I == cProduto

         EEW->(dbSeek(xFilial("EEW")+EEV->EEV_COD_I+EEV->EEV_SEQUEN))
         While EEW->(!Eof() .And. EEW_FILIAL==xFilial("EEW")) .And.;
               EEW->EEW_COD_I  == EEV->EEV_COD_I .And.;
               EEW->EEW_SEQUEN == EEV->EEV_SEQUEN

            WkPro->(dbAppend())
            AVReplace("EEW","WkPro")  
            WkPro->EEW_COD_I := M->B1_COD   
            
            EEW->(dbSkip())

         Enddo

         WkEmb->(dbAppend())
         AVReplace("EEV","WkEmb")        
         WkEmb->EEV_RECNO  := 0
         WkEmb->EEV_EMBALA := Posicione("EE5",1,xFilial("EE5")+EEV->EEV_CODEMB,"EE5_DESC")
        
         EEV->(dbSkip())
           
      Enddo                          
               
      WkEmb->(dbGoTop())
      WkPro->(dbGoTop())      

   Endif   
   
   If lCopyNorma                      
      For i:= 1 to len(aColsNor)
         Aadd(aNorDelete,aColsNor[i])
      Next
      aColsNor := {}
      If EXN->(DBSeek(cFilEXN+cProduto))
         While EXN->(!EoF()) .And. EXN->EXN_FILIAL == cFilEXN .And. EXN->EXN_PROD == cProduto
            aAdd( aColsNor, Array( Len(aHeaderNor)+1 ) )
            aColsNor[len(aColsNor)][1] := EXN->EXN_PAIS    
            aColsNor[len(aColsNor)][2] := Posicione("SYA",1,xFilial("SYA")+EXN->EXN_PAIS,"YA_DESCR")
            aColsNor[len(aColsNor)][3] := EXN->EXN_NORMA
            aColsNor[len(aColsNor)][4] := E_MSMM(Posicione("EEI",1,xFilial("EEI")+EXN->EXN_NORMA,"EEI_DESC"),60)
            aColsNor[Len(aColsNor)][Len(aHeaderNor)+1] := .F.    
            EXN->(DbSkip())
         EndDo
      Endif 
   
   Endif
   
   SB1->(DbGoTo(nRec))      
     
End Sequence

Return Nil               

/*
Funcao      : AC120ValCopy().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Validação para a tela de Copia de Dados Complementares
Autor       : João Pedro Macimiano Trabbold.
Data/Hora   : 13/12/04; 15:00
*/
*-----------------------------*
Static Function Ac120ValCopy()
*-----------------------------*
Local lRet:= .t.
Begin Sequence

   If !lCopyCapa .And. !lCopyPreco .and. !lCopyIdiomas .and. !lCopyEmbal .and. !lCopyNorma 
      MsgStop(STR0102,STR0033)//"Escolha os dados complementares a serem copiados."//"Aviso"
      lRet := .f.
      Break
   Endif     

   If Empty(cProduto)
      MsgStop(STR0103,STR0033)//"Preencha o campo 'Produto'."//"Aviso"
      lRet := .f.
      Break
   Endif
   
   If !SB1->(DbSeek(xFilial("SB1")+cProduto))
      Help(" ",1,"REGNOIS")
      lRet := .f.
      Break
   EndIf
   
End Sequence
Return lRet
//Alcir Alves - 25-05-05                               
//MODIFICAÇÃO NO CADASTRO DE PRODUTOS 
//em campos modificados que possam influenciar no drawback
****************************************************************8
function AC120EICMP()
****************************************************************8
      if EasyGParam("MV_ENVMAIL",,.F.)==.T. //Caso parametro para enviar e-mail        
         IF EasyGParam("MV_EIC_EDC",,.F.)==.T. //CASO EXISTA INTEGRAÇÃO DRAWBACK
            IndRegua("ED1", "ED10"+TEOrdBagExt(),"ED1_FILIAL+ED1_PROD")         
            IF ED1->(DBSEEK(XFILIAL("ED1")+AVKEY(SB1->B1_COD,"ED1_PROD")))          
               cedcMAIL:=""
               cDesc_LI:=alltrim(MSMM(SB1->B1_desc_gi,,,,3))
               IF cDesc_LI#alltrim(M->B1_VM_GI) //DESCRICAO  DA LI
                   cedcMAIL+=STR0027+cDesc_LI+STR0028+M->B1_VM_GI+chr(13)+chr(10)
               ENDIF
               IF SB1->B1_POSIPI#M->B1_POSIPI  //modificaçao de NCM
                  cedcMAIL+=STR0029+SB1->B1_POSIPI+STR0028+M->B1_POSIPI+chr(13)+chr(10)
               ENDIF
               IF SB1->B1_UM#M->B1_UM  //modificaçao de UNIDADE DE MEDIDA
                  cedcMAIL+=STR0033+SB1->B1_UM+STR0028+M->B1_UM+chr(13)+chr(10)
               ENDIF
               cedcSubjc:=STR0030+alltrim(SB1->B1_COD)+STR0031
               If EasyEntryPoint("EECAC120")                       
                  ExecBlock("EECAC120",.F.,.F.,"PRODUTO_MODIFICADO_EMAIL")
               EndIf
               cedcBDM:=""
               IF !empty(cedcMAIL) //caso não esteja vazio quer dizer que houve modificação em no minimo algum item
                  cedcBDM:=STR0032+chr(13)+chr(10)+cedcMAIL
                  lenv:=EICINmail(NIL,NIL,cedcSubjc,cedcBDM,NIL,NIL,NIL)
               ENDIF
            ENDIF
         ENDIF      
      Endif 
return .t.

Static Function AC120PesoVld()
Local lRet := .F.

If M->B1_PESBRU >= M->B1_PESO
   lRet := .T.
ElseIf Type("lExecAuto") == "L" .And. lExecAuto
   EasyHelp("Peso Liquido maior que o Peso Bruto","Aviso")
Else
   MsgInfo("Peso Liquido maior que o Peso Bruto","Aviso")
EndIf

Return lRet

/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix 
* Obs: 
* Autor: Felipe Sales Martinez - FSM
* Data: 30/11/2011
* =====================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI
Local aIntMata := {}
Local aRet     := {}

Begin Sequence
	
	If EasyFindAdpt("MATI010")                                       //NCF - 03/05/2016 - Integrar pelo Mata010 para inlcuir o B1_LOCPAD padrão TOTVS. 
	   aIntMATA := MATI010(cXml, nTypeTrans, cTypeMessage)           //                   No caso de alteração, ignorar erros devido ausência de InternalId                
	   If !aIntMata[1]                                               //                   na mensagem visto que esta informação não foi convencionada entre EEC x LOGIX.
	      If !("O código do InternalId é obrigatório!" $ aIntMATA[2]) .And.;
	         !("HELP: JAGRAVADO" $ aIntMATA[2]) 
	         aRet:= aClone(aIntMATA)
	         Break
	      EndIf
	   EndIf	   	   	
	EndIf
	
	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.000|1.001|3.001")
	oEasyIntEAI:oMessage:SetMainAlias("SB1")
	oEasyIntEAI:SetModule("EEC",29)
	
	// *** Recebimento
	oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "AC120ARECB") //RECEBIMENTO DE BUSINESS
	oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "AC120ARESB") //RESPOSTA SOBRE O RECEBIMENTO
   oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EECAC120( oEasyMessage:GetEAutoArray("SB1"), oEasyMessage:GetEAutoArray("EYJ") , oEasyMessage:GetOperation())  })  
	oEasyIntEAI:Execute()
	aRet:= oEasyIntEAI:GetResult()
	
End Sequence
	
Return aRet// oEasyIntEAI:GetResult()


/*========================================================================================
Funcao Adapter: AC120ARECB
Parametros    : "oMessage" - Objeto XML com conteúdo da tag "BusinessContent" recebida
Retorno       : aExecAuto onde:
                aExecAuto[1] = Array com os dados de capa para ExecAuto
                         [1][1] = Identificador de capa ("CAB")
                         [1][2] = Id do Formulario de Capa
                         [1][3] = Array com os registros para ExecAuto 
                aExecAuto[2] = Array com os dados de detalhe para ExecAuto
                         [2][1] = Identificador de detalhe ("DET")
                         [2][2] = Id do Formulario de Detalhe
                         [2][3] = Array com os registros para ExecAuto  
Objetivos     : Montar o Array de dados da Mensagem única para inserção via ExecAuto
Autor         : Felipe Sales Martinez - FSM
Data/Hora     : 30/11/2011 - 10:00 hs
Revisao       : 
Obs.          : 
==========================================================================================*/
*------------------------------------------------*
Function AC120ARECB(oMessage)
*------------------------------------------------* 
Local oBusinessCont := oMessage:GetMsgContent()
Local oBatch    := EBatch():New()
Local oExecAuto := EExecAuto():New()
Local oRec      := ERec():New()
Local oRecSYC
Local lObrigat := .T.
Local cTipo := EasyGetXMLinfo(, oBusinessCont, "_ObtainingType")
Local cProduto := EasyGetXMLinfo("B1_COD" ,  oBusinessCont, "_Code") //Cod. Produto
Local cCodERP   := EasyGetXMLinfo(,oBusinessCont, "_UnitOfMeasureCode")
Local nOrdSAH
Local cUniMed := ""
Local aDescProd

    /*============================================================= *
    * O tipo do produto pode ser apenas Comprado(1) ou fabricado(2) 
    * ============================================================= */
    If Upper(AllTrim(cTipo)) == "1" //Produto Comprado
       cTipo := "ME"
    Else //Produto Fabricado
       cTipo := "PA"
    EndIf


    /*
    * Campos Obrigatorios:
    */
	AddArrayXML(oRec, "B1_COD"   , oBusinessCont,"_Code" , lObrigat)  //Codigo
    
    If !Empty(EasyGetXMLinfo(, oBusinessCont, "_ShortName"))
    	AddArrayXML(oRec, "B1_DESC"  , oBusinessCont, "_ShortName" , lObrigat) //Descricao
    Else
    	AddArrayXML(oRec, "B1_DESC"  , oBusinessCont, "_Name" , lObrigat)
    EndIf
    
    oRec:SetField("B1_TIPO"       , AvKey(cTipo,"B1_TIPO") ) //Tipo do produto

    /*============================================================= *
    * O cod. armazem padrao nao esta presente no XML  
    * ============================================================= */
    //If !FindFunction("MATI010")                               //NCF - 03/05/2016 - não sobrepor informação integrada pela inclusão via MATA010
       oRec:SetField("B1_LOCPAD"    , AvKey(".","B1_LOCPAD")) //Cod. Armazem padrão
    //EndIf
    
    If !Empty(cCodERP)
       nOrdSAH    := SAH->(INDEXORD())

       SAH->(DbSetOrder(2))
       
       If SAH->(DbSeek(xFilial()+AvKey(cCodERP,"AH_CODERP")))
          cUniMed    := SAH->AH_UNIMED
       ElseIf Len(cCodERP) <= 2
          cUniMed    := cCodERP
       EndIf
        
       SAH->(DbSetOrder(nOrdSAH))
       
   EndIf
   //oRec:SetField("B1_UM" , AvKey(EasyConvCod( EasyGetXMLinfo(, oBusinessCont, "_UnitOfMeasureCode"), "SAH" )  ,"B1_UM") )
   oRec:SetField("B1_UM" , AvKey(cUniMed,"B1_UM") )
    
    //AddArrayXML(oRec,  "B1_UM"   , oBusinessCont, "_UnitOfMeasureCode" , lObrigat) //Unidade de Medida

    /*
    * Campos Não Obrigatorios:
    */
    AddArrayXML(oRec, "B1_PESO"  , oBusinessCont, "_NetWeight") //Peso Liquido
	If !Empty(EasyGetXMLinfo(, oBusinessCont, "_GrossWeight"))
       AddArrayXML(oRec, "B1_PESBRU", oBusinessCont, "_GrossWeight") //Peso Bruto
    Else
       AddArrayXML(oRec, "B1_PESBRU", oBusinessCont, "_NetWeight") // Caso o Preso bruto nao contem na mensagem utiliza como padrao o preso liquido
    EndIf
	
	/*============================================================= *
    * Ativo é true ou false, que deve ser convertido para S ou N  
    * ============================================================= */
    oRec:SetField("B1_ATIVO"  , EasyFromTo(oBusinessCont,"_Active","S/N" )) //Ativo
    
    oRec:SetField("B1_LE"      , EasyGetXMLinfo("B1_LE", oBusinessCont, "_EconomicLot") ) //Lote Economico
    
    oRec:SetField("B1_LM"      , EasyGetXMLinfo("B1_LM", oBusinessCont, "_MinimumLot") ) //Lote Minimo
    
    If IsCpoInXML(oBusinessCont, "_FiscalInformation")
	   If IsCpoInXML(oBusinessCont:_FiscalInformation:_FiscalClassification, "_FiscalClassificationCode")
          oRec:SetField("B1_POSIPI"  ,  EasyFromTo(oBusinessCont:_FiscalInformation:_FiscalClassification, "_FiscalClassificationCode", "SEM_CARACTER_ESPECIAL") ) //Pos. IPI/NCM -- JAL 28/04/14 -- ajustado a tag do campo.
	   ElseIf IsCpoInXML(oBusinessCont:_FiscalInformation:_FiscalClassification, "_Code")
	      oRec:SetField("B1_POSIPI"  ,  EasyFromTo(oBusinessCont:_FiscalInformation:_FiscalClassification, "_Code", "SEM_CARACTER_ESPECIAL") ) //Pos. IPI/NCM
	   EndIf
    EndIf
    //If EasyGetXMLinfo("EYJ_ADE", oBusinessCont, "_CostCenterCode")
    ///oRec:SetField("B1_LE"      , EasyGetXMLinfo("EYJ_ADE", oBusinessCont, "_CostCenterCode") ) //Centro de Custo
    //EndIf
	
    // Tratamento para salvar a familia do produto
	If AllTrim(Upper(oMessage:GetBsnEvent())) <> "DELETE"  .And. !Empty(EasyGetXMLinfo(, oBusinessCont, "_FamilyCode")) .And. !Empty(EasyGetXMLinfo(, oBusinessCont, "_FamilyDescription"))
	    oExecFam := EExecAuto():New()
	    oRecSYC := ERec():New()

        AddArrayXML(oRecSYC, "YC_COD"   , oBusinessCont, "_FamilyCode")	
        oRecSYC:SetField("YC_IDIOMA"    , "PORT. ")
        AddArrayXML(oRecSYC, "YC_NOME"  , oBusinessCont, "_FamilyDescription")	
        
        oExecFam:SetField("SYC",oRecSYC)
 	    
  	    oParams := ERec():New()
        oParams:SetField("cMainAlias","SYC")
	    oParams:SetField("bFunction",{|oEasyMessage| AT145FAM(oEasyMessage:GetEAutoArray("SYC"),{}, oEasyMessage:GetOperation())})
 	    oExecFam:SetField("PARAMS",oParams)
 
        oBatch:AddRec(oExecFam)
		
		AddArrayXML(oRec, "B1_FPCOD", oBusinessCont, "_FamilyCode")
    EndIf
        
    aDescProd := {}
    aAdd(aDescProd, { EasyGetXMLinfo("B1_COD", oBusinessCont,"_Code") , {{"EE2_IDIOMA",AvGetKeyID('PORT.') ,NIL} ,{"EE2_VM_TEX",EasyGetXMLinfo("",oBusinessCont,"_Name")      ,NIL}}} )
    //aAdd(aDescProd, { EasyGetXMLinfo("B1_COD", oBusinessCont,"_Code") , {{"EE2_IDIOMA",AvGetKeyID('INGLES'),NIL} ,{"EE2_VM_TEX","Descricao do Produto em Ingles para testes"  ,NIL}}} )
    //aAdd(aDescProd, { EasyGetXMLinfo("B1_COD", oBusinessCont,"_Code") , {{"EE2_IDIOMA",AvGetKeyID('ESP.')  ,NIL} ,{"EE2_VM_TEX","Descricao do Produto em Espanhol para testes",NIL}}} )

	//Average - Jacomo Lisa - 28/04/2014 - Inclusão dos novos campos para a Integração com com o Logix
	oRec:SetField("B1_VM_P"    ,EasyGetXMLinfo("B1_VM_P"    ,oBusinessCont, "_Name") ) //Descrição em portugues
	oRec:SetField("B1_ESPECIF" ,EasyGetXMLinfo("B1_ESPECIF",oBusinessCont, "_Detail") ) //Descr.Especif
           
           
    oParams := ERec():New()
    oParams:SetField("cMainAlias","SB1")
    oParams:SetField("bFunction",{|oEasyMessage| EECAC120(oEasyMessage:GetEAutoArray("SB1"), oEasyMessage:GetEAutoArray("EYJ") , oEasyMessage:GetOperation() , aDescProd )})
	oExecAuto:SetField("PARAMS",oParams)
    oExecAuto:SetField("SB1" ,oRec)
    oBatch:AddRec(oExecAuto)
    
  	If AllTrim(Upper(oMessage:GetBsnEvent())) <> "DELETE" 
		/* Tratamento para salvar o campo Centro de Custo (EYJ_CCERP) do Produto na Tabela EYJ */
	    oExecAuto := EExecAuto():New()
	    oComp     := ERec():New()
	    
	    SB1->( DBSetOrder(1) )
	    SB1->( DBSeek( xFilial("SB1") + cProduto ) )
	    
	    AddArrayXML(oComp, "EYJ_CCERP"  , oBusinessCont, "_CostCenterCode" , lObrigat) //CCERP

	    oExecAuto:SetField("SB1" ,oRec)
	    
	    oExecAuto:SetField("EYJ" ,oComp)
	    
	    oParams := ERec():New()
	    oParams:SetField("nOpc",6)
	    oParams:SetField("bFunction",{|oEasyMessage| EECAC120(oEasyMessage:GetEAutoArray("SB1"),  oEasyMessage:GetEAutoArray("EYJ")  , oEasyMessage:GetOperation())})
	    oExecAuto:SetField("PARAMS",oParams)
	    
	    oBatch:AddRec(oExecAuto)
	EndIf

Return oBatch

/* ============================================================*
* Função     : AC120ARESB
* Parametros : oMessage
* Objetivo   : Mensagem de retorno com o resultado da integracao 
* Autor      : Felipe Sales Martinez - FSM
* Data       : 06/01/2012 - 11:52 hs
* Revisao    :   
* Obs        : 
* =============================================================*/
*-------------------------------------------------*
Function AC120ARESB(oMessage) 
*-------------------------------------------------*
Local oRespond 
       
    If !oMessage:HasErrors()
        oRespond  := ENode():New() 
        oRespond:SetField('ExternalCode',SB1->B1_COD)
        oRespond:SetField('ItemCode',SB1->B1_COD)
    Else       
        oRespond := oMessage:GetContentList("RESPONSE")
    EndIf

Return oRespond

/*===================================================*
* Função     : AC120SB5Man
* Parametros : aAutoComp
* Objetivo   : Manutenção automatica da tabela SB5
* Autor      : Guilherme Fernandes Pilan - GFP
* Data       : 09/04/2014 :: 11:54
* ===================================================*/
*------------------------------*
Function AC120SB5Man(aAutoComp)
*------------------------------*
Local aOrd := SaveOrd({"SB1","SB5"})
Local i

Begin Sequence
   If Left(aAutoComp[1][1],3) # "SB5"   //NCF - 28/04/2014 - Coibir erro quando integrado campos de dados complementares de produto (EYJ)
      Break
   EndIf
   SB1->(DbSetOrder(1)) //"B1_FILIAL+B1_COD"
   If !SB1->(DbSeek(AvKey(aAutoComp[1][2],"B1_FILIAL")+AvKey(aAutoComp[2][2],"B1_COD")))
      Break
   EndIf
   
   //ChkFile("SB5",.T.) LRS-27/06/2017   
   SB5->(DbSetOrder(1)) //"B5_FILIAL+B5_COD"
   If SB5->(RecLock("SB5",!SB5->(DbSeek(AvKey(aAutoComp[1][2],"B5_FILIAL")+AvKey(aAutoComp[2][2],"B5_COD")))))   
      For i := 1 To Len(aAutoComp)
         SB5->&(aAutoComp[i][1]) := aAutoComp[i][2]
      Next
      SB5->(MsUnlock())
   EndIf
End Sequence

RestOrd(aOrd,.T.)
Return NIL

/*
Funcao       : AC120PEVALID(nOpc)
Parametros   : Nenhum
Retorno      : Nil
Objetivos    : Executar ponto de entrada no CodBlock bOK
Autor        : Lucas Raminelli LRS
Data/Hora    : 21/08/2018
*/
Function AC120PEVALID(nOpc)
Private lRetPE := .T.

IF(EasyEntryPoint("EECAC120"),Execblock("EECAC120",.F.,.F.,{"VALID_GRAVACAO",nOpc}),)

Return lRetPE
*------------------------------------------------------------------------------------------------------------------*
*                                               FIM DO PROGRAMA EECAC120                                                        *
*------------------------------------------------------------------------------------------------------------------*
