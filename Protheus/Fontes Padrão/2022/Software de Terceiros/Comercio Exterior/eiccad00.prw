#INCLUDE "Eiccad00.ch"
#INCLUDE "FWBROWSE.CH"
//#include "FiveWin.ch"
#include "Average.ch"
#DEFINE CONTEINER  "5"
#DEFINE PESO       "4"
#DEFINE QUANTIDADE "3"
#DEFINE PERCENTUAL "2"
#DEFINE VALOR      "1"


#DEFINE IMPORTADOR "1"
#DEFINE FABFOR     "2"
#DEFINE AGENTES    "3"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA005  ³ Autor ³ MJBARROS/AVERAGE      ³ Data ³ 15.10.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Importadores / Consignatarios                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICA005
LOCAL cCadastro := OemtoAnsi(STR0001) //"Importadores/Consignatários"
//Local aRotAdic := {}

// BAK - Apresentacao da rotina de Matriz de Tributacao
//MFR 04/02/2020 OSSME-4372
//Controle implementado no fonte EICA005
//If FindFunction("EICMAT100") .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI",.F.)
//   aAdd(aRotAdic,{ STR0052 ,"EICMAT100", 0 , 6 }) // "Matriz de Tributação"
//EndIf

//If !EasyCallMVC("MVC_005AEIC",1) //CRF   //LRS - Nopado, a rotina Matriz de tributação deve aparecer com MVC ativo e desabilitado
   //cAux := AxCadastro("SYT",cCadastro)
   //cAux := AxCadastro("SYT",cCadastro,,,aRotAdic)
   //MFR 04/02/2020 OSSME-4372
   MVC_005AEIC()
//EndIf 
Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA010  ³ Autor ³ AVERAGE               ³ Data ³ 17/05/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Compradores                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICA010()
Private cCadastro := OemtoAnsi(STR0002) //"Compradores"
//Private aRotina := {}

//If !EasyCallMVC("MVC_010AEIC",1) //CRF
   //aRotina := MenuDef(ProcName())//FDR - 06/03/12 //AxCadastro("SY1",cCadastro)
   //mBrowse( 6, 1,22,75,"SY1")  // AAF - 17/11/2014
//EndIf
If EasyGParam("MV_EASY",, "N") == "S" //Se integrado ao compras, utiliza o cadastro de compradores do modulo de Compras
   SetFunName("COMA087")
   COMA087()
Else
   MVC_010AEIC()
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA020  ³ Autor ³ AVERAGE               ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Locais de Entrega               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICA020
//Local cAux := ""
Private cCadastro := OemtoAnsi(STR0003) //"Locais de Entrega"
Private aRotina := {}

If !EasyCallMVC("MVC_020AEIC",1) //CRF
   aRotina := MenuDef(ProcName()) //FDR - 26/03/12 //AxCadastro("SY2",cCadastro)
   mBrowse( 6, 1,22,75,"SY2")  // AAF - 17/11/2014
EndIf 

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA040  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Agentes                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICA040()
//Local cAux := ""
Private cCadastro := OemtoAnsi(STR0004) //"Agentes Embarcadores" 
Private aRotina := {}

//GFP - 20/12/2013
If !EasyCallMVC("MVC_040AEIC",1) //CRF
   aRotina := MenuDef(ProcName()) //AxCadastro("SY4",cCadastro)
   mBrowse( 6, 1,22,75,"SY4")  // AAF - 17/11/2014
EndIf 

Return .T.

FUNCTION A040VALID(cParam)   
LOCAL I, cCodigo := (ReadVar())

DO CASE
   CASE cParam=="FORN"

     //ISS - 24/09 - Alterado o gatilho para que o mesmo preencha corretamente a loja.
      IF EMPTY(M->Y4_FORN)
         M->Y4_LOJA:=""
         RETURN .T.
      ELSE
         IF !SA2->(DbSeek(xFilial("SA2")+AvKey(M->Y4_FORN,"A2_COD")+If(EICLoja() .And. !Empty(M->Y4_LOJA),AvKey(M->Y4_LOJA,"A2_LOJA"),"")))   // GFP - 11/01/2013
            MsgInfo(STR0054, STR0043) //"O fornecedor informado não existe.", "Atenção"
            RETURN .F.
         ENDIF
         /*IF !ExistCpo("SA2",M->Y4_FORN+If(EICLoja() .And. !Empty(M->Y4_LOJA), M->Y4_LOJA, ""))   // Nopado por GFP - 11/01/2013
            RETURN .F.
         ENDIF*/
         //SA2->(DBSEEK(xFilial()+M->Y4_FORN+If(EICLoja() .And. !Empty(M->Y4_LOJA), M->Y4_LOJA, "")))   // Nopado por GFP - 11/01/2013   
         
         IF SUBST(SA2->A2_ID_FBFN,1,1) = "2" .OR. SUBST(SA2->A2_ID_FBFN,1,1) = "3"
            M->Y4_LOJA:=SA2->A2_LOJA
         Else
            MsgInfo(STR0055, STR0043) //"O código escolhido não pertence ao cadastro de um fornecedor.", "Atenção")
            Return .F.            
         EndIf

      ENDIF
   
   CASE cParam=="DESPESA"    // JBS - 31/07/2003
      IF !(M->YB_BASEICM $ cSim)
         For I := 1 to SYB->(fcount())  // Cria as Variaveis de memoria para o SW2
             IF SUBSTR(SYB->(M->(FieldName(i))),1,8) == "YB_ICMS_"//Na versao 710 o campo eh YB_ICM_
                SYB->(M->&(FieldName(i))) := "2"
             ENDIF  
         Next
      ENDIF
      
ENDCASE

RETURN .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA050  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Despachantes                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICA050()
// RAD - Traducao ARG
Private cDelFunc := ".T."

PRIVATE aRotina := MenuDef(ProcName())

PRIVATE cCadastro :=  STR0056 //"Cadastro de Despachante"    

If cModulo == "EIC" 
  SY5->(DbSetFilter({||LEFT(SY5->Y5_TIPOAGE,1) == " " .OR. LEFT(SY5->Y5_TIPOAGE,1) == "6"}, "LEFT(SY5->Y5_TIPOAGE,1) == ' ' .OR. LEFT(SY5->Y5_TIPOAGE,1) == '6'"))
Endif    

mBrowse( 6, 1,40,90,"SY5")   
 
If cModulo == "EIC" 
   Set Filter To
Endif    

Return  

*----------------------------*
Function A050Valid(cParam)
*----------------------------*

DO CASE 
   CASE cParam=="BANCO"
   
      IF EMPTY(M->Y5_BANCO)
         M->Y5_AGENCIA:=""
         RETURN .T.
      ELSEIf nModulo == 29//RMD - 20/05/09 - Caso esteja no EEC, preenche o campo 'Conta'
         If EXISTCPO("SA6",M->Y5_BANCO)
            M->Y5_CONTA := Posicione("SA6", 1, xFilial("SA6")+M->(Y5_BANCO+Y5_AGENCIA+Y5_CONTA), "A6_NUMCON") //TDF - 28/12/2011
            Return .T.
         Else
            Return .F.
         EndIf
      Else
         RETURN EXISTCPO("SA6",M->Y5_BANCO)
      ENDIF         
      
   CASE cParam=="AGENCIA"
      If nModulo == 29//RMD - 20/05/09 - Caso esteja no EEC, preenche o campo 'Conta'
         If VAZIO(M->Y5_AGENCIA)
            Return .T.
         Else
            If !EMPTY(M->Y5_BANCO)
               If EXISTCPO("SA6",M->Y5_BANCO+M->Y5_AGENCIA)
                  M->Y5_CONTA := Posicione("SA6", 1, xFilial("SA6")+M->(Y5_BANCO+Y5_AGENCIA+Y5_CONTA), "A6_NUMCON")   //TDF - 28/12/2011
               Else
                  Return .F.
               EndIf
            Else
               Return .T.
            EndIf
         EndIf
      Else
         RETURN VAZIO(M->Y5_AGENCIA).OR. IF(!EMPTY(M->Y5_BANCO).AND.;
                 EXISTCPO("SA6",M->Y5_BANCO+M->Y5_AGENCIA),.T.,.F.)
      EndIf   
                
   CASE cParam=="FORNECE"

     //ISS - 24/09 - Alterado o gatilho para que o mesmo preencha corretamente a loja.   
      IF EMPTY(M->Y5_FORNECE)
         M->Y5_LOJAF:=""
         RETURN .T.
      ELSE
         IF !ExistCpo("SA2",M->Y5_FORNECE+IF(EICLoja() .And. !Empty(M->Y5_LOJAF), M->Y5_LOJAF, ""))
            RETURN .F.
         ENDIF
         SA2->(DBSEEK(xFilial()+M->Y5_FORNECE+IF(EICLoja() .And. !Empty(M->Y5_LOJAF), M->Y5_LOJAF, "")))   

         IF SUBST(SA2->A2_ID_FBFN,1,1) = "2" .OR. SUBST(SA2->A2_ID_FBFN,1,1) = "3"
            M->Y5_LOJAF:=SA2->A2_LOJA
         Else
            MsgInfo(STR0055, STR0043) //"O código escolhido não pertence ao cadastro de um fornecedor.", "Atenção"
            Return .F.            
         EndIf

      ENDIF
      
   CASE cParam=="LOJAF"
   
      RETURN EMPTY(M->Y5_FORNECE+M->Y5_LOJAF) .OR. ExistCpo("SA2",M->Y5_FORNECE+M->Y5_LOJAF)
      
   CASE cParam=="CLIENTE"
   
      IF EMPTY(M->Y5_CLIENTE)
         M->Y5_LOJACLI:=""
         RETURN .T.
      ELSE
         IF !ExistCpo("SA1",M->Y5_CLIENTE)
            RETURN .F.
         ENDIF
         SA1->(DBSEEK(xFilial()+M->Y5_CLIENTE))   
         M->Y5_LOJACLI:=SA1->A1_LOJA
      ENDIF                 
      
   CASE cParam=="LOJACLI"     
   
      RETURN EMPTY(M->Y5_CLIENTE+M->Y5_LOJACLI) .OR. ExistCpo("SA1",M->Y5_CLIENTE+M->Y5_LOJACLI)
ENDCASE


RETURN .T.


*-----------------------------------------*
User Function ManutCad00(cAlias,nReg,nOpc)
*-----------------------------------------*   
Local cClassif := ""
Local nRecSy5  := 0
Private aMemos:={{"Y5_OBS","Y5_VM_OBS"}}
   
If nOpc == 3  

   If cModulo == "EIC" 
      Set Filter To
      cClassif := Tabela('YE',"6") //POSICIONA NO SX5 - DESPACHANTE
      cClassif := Left(SX5->X5_CHAVE,1) + "-" +cClassif
   Endif               
   
   IF AxInclui(cAlias,nReg,nOpc) # 3
      SY5->(RecLock("SY5",.F.))
      SY5->Y5_TIPOAGE := cClassif 
      SY5->(MsUnLock("SY5"))  
   ENDIF         
   If cModulo == "EIC" 
      SY5->(DbSetFilter({||LEFT(SY5->Y5_TIPOAGE,1) == " " .OR. LEFT(SY5->Y5_TIPOAGE,1) == "6"}, "LEFT(SY5->Y5_TIPOAGE,1) == ' ' .OR. LEFT(SY5->Y5_TIPOAGE,1) == '6'"))
   Endif 
   RETURN .T.
Endif         

If nOpc == 4             
		
   If cModulo == "EIC" 
      nRecSy5 := SY5->(RECNO())	
      Set Filter To
      cClassif := Tabela('YE',"6") //POSICIONA NO SX5 - DESPACHANTE
      cClassif := Left(SX5->X5_CHAVE,1) + "-" +cClassif
      SY5->(DBGOTO(nRecSy5))
   Endif      
   
   AxAltera(cAlias,nReg,nOpc)
   SY5->(RecLock("SY5",.F.))
   SY5->Y5_TIPOAGE := cClassif 
   SY5->(MsUnLock("SY5"))  
           
   If cModulo == "EIC" 
      SY5->(DbSetFilter({||LEFT(SY5->Y5_TIPOAGE,1) == " " .OR. LEFT(SY5->Y5_TIPOAGE,1) == "6"}, "LEFT(SY5->Y5_TIPOAGE,1) == ' ' .OR. LEFT(SY5->Y5_TIPOAGE,1) == '6'"))
   Endif 
   RETURN .T.
Endif         

RETURN  .T.           


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA070  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Mensagens                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICA070

PRIVATE cCadastro := OemtoAnsi(STR0006) //"Mensagens"
PRIVATE aMemos:={{"Y7_TEXTO","Y7_VM_TEXT"}}
PRIVATE cDelFunc 
PRIVATE aRotina := MenuDef(ProcName())
PRIVATE cTamY7PONU:=Space(AvSX3("Y7_PO_NUM",3))
If SY7->(FieldPos("Y7_PO_NUM")) # 0   //TRP-12/06/08
   SY7->( dbSetFilter(&("{|| Y7_PO_NUM = '"+cTamY7PONU+"'}"),"Y7_PO_NUM == '"+cTamY7PONU+"'") )   
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"SY7" )
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SY7Inclui³ Autor ³ AVERAGE-Saimon Gava   ³ Data ³ 16/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para inclusão de mensagens direto da consulta     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SY7Inclui(cAlias,nReg,nOpc)
PRIVATE aMemos:={{"Y7_TEXTO","Y7_VM_TEXT"}}
axInclui(cAlias,nReg,Nopc)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SY7Inclui³ Autor ³ AVERAGE-Saimon Gava   ³ Data ³ 16/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para visualização de mensagens direto da consulta ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SY7Visual(cAlias,nReg,nOpc)
PRIVATE aMemos:={{"Y7_TEXTO","Y7_VM_TEXT"}}
axVisual(cAlias,nReg,Nopc)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA080  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao Fundamento Legal do Regime Tributa.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function EICA080
Local cAux := ""
//mjb150999 LOCAL nOldArea:=Select()
LOCAL cCadastro:=AnsitoOem(STR0012) //"Fundamento Legal do Regime de Tributação"

If !EasyCallMVC("MVC_080AEIC",1) 
   cAux := AxCadastro("SY8",cCadastro)
EndIf

//mjb150999 DbSelectArea(nOldArea) // sempre deve haver uma area selecionada
Return cAux




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA090  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Portos / Aeroportos             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICA090

Local cAux := ""
LOCAL cCadastro := STR0013 //"Portos / Aeroportos"
Local cDelOk := "A090Delet()"

If !EasyCallMVC("MVC_090AEIC",1) 
   cAux := AxCadastro("SY9",cCadastro,cDelOk)
EndIf 


Return cAux



//BHF - 30/06/2008 - Validar o campo Sigla no cadastro de portos e aeroportos para não permitir duplicidade.
Function A090VALID(cParam)
Local lRet := .T.

Do case
   Case cParam == "SIGLA"
      SY9->(DbSetOrder(2))
      If SY9->(DbSeek(xFilial()+M->Y9_SIGLA))
         Help(" ",1,"JAGRAVADO") //MsgInfo("Sigla já cadastrada!")
         lRet := .F.
      EndIf
EndCase

Return lRet 

//NCF - 17/06/2010 - Função para validar a exclusão do porto/aeroporto
Function A090Delet()

LOCAL lVerDest := .F.
Local lRet := .T.

SYR->(DbSetOrder(3))
If SYR->(DbSeek(xFilial()+SY9->Y9_SIGLA))
   MsgStop(STR0058, STR0043) //"Porto já utilizado como origem de uma ou mais Via(s) de transporte", "Atenção"
      lRet := .F.
Else
   lVerDest := .T.
EndIf
If lVerDest
   SYR->(DbSetOrder(4))
   If SYR->(DbSeek(xFilial()+SY9->Y9_SIGLA))
      MsgStop(STR0059, STR0043) //("Porto já utilizado como destino de uma ou mais Via(s) de transporte")
      lRet := .F.
   EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA100  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Paises                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICA100
Local cAux := ""
LOCAL cCadastro := OemtoAnsi(STR0014) //"Pa¡ses" 

If !EasyCallMVC("MVC_100AEIC",1) 
   cAux := AxCadastro("SYA",cCadastro,"INTEGREF ('SYA')")      //acb 12/07/2010
EndIf 


Return cAux



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EIYZ100  ³ Autor ³ AVERAGE-RS            ³ Data ³ 27/08/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de PPB - Suframa                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EIYZ100
Local cAux := ""               
LOCAL cCadastro := OemtoAnsi(STR0015) //"Produtos - Zona Franca de Manaus"
If !EasyCallMVC("MVC_EIYZ100",1) 
   cAux := AxCadastro("SYZ",cCadastro)
EndIf 

Return cAux

*--------------------*
Function EICY7_DESC()
*--------------------*
M->Y7_DESC_ME:=Tabela('Y0',M->Y7_POGI)
RETURN .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA110  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao do Cadastro de Despesas            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICA110
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cAlias:="SYB" //mjb150999 , nOldArea:=Select()

PRIVATE aRotina := MenuDef(ProcName())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0016) //"Cadastro de Despesas"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE lNaoAltera:=.T.

If(EasyEntryPoint("EICCAD00"),ExecBlock("EICCAD00",.F.,.F.,"MBROWSE_CAD_DESPESAS"),)

mBrowse( 6, 1,22,75,cAlias)
//mjb150999 DbSelectArea(nOldArea)
Return .T.
*----------------------------------------------------------------------------
Function EA110Manut(cAlias,nReg,nOpc)
*----------------------------------------------------------------------------
LOCAL aDesp:={ "MV_D_FRETE","MV_D_SEGUR","MV_D_II","MV_D_IPI","MV_D_ICMS" }, nOrdSx3 := SX3->(indexOrd())
LOCAL lAchou,cAltera:=GetNewPar("MV_ALTDESP","N"), aCpos := {} , I
Local aAltera:= {}
Local aNfDespesa:= {"YB_PRODUTO", "YB_ESPECIE"}
Local lMvEasy:= EasyGParam("MV_EASY",, "N") == "S"
Local lMvSisc:= EasyGParam("MV_ESS0014",, .F.) .Or. EasyGParam("MV_ESS0022",, .F.)  // == .T.
Private aICM_CPOS := {}
Private aCposCopy:={}, aAltRdm:= {} //Utilização em Rdmake
//-{
// JBS - 31/07/2003 : Estas alteracoes sao para o funcionamento do botao que ira acionar
//                  : o Funcao que informa os estados para a Despesa de ICMS    
SX3->(dbSetOrder(2))
 
For I := 1 to SYB->(fcount())  // Cria as Variaveis de memoria para o SYB
      If  SX3->(dbSeek(SYB->(FieldName(i)))).and. X3USO(SX3->X3_USADO)      
         If lMvEasy .Or. lMvSisc .Or. (AScan(aNfDespesa, SYB->(FieldName(i))) == 0) //os campos para a geração da nota fiscal de despesa serão exibidos quando integrado com protheus(eicdi158)  
            aadd(aCpos,SYB->(FieldName(i)))  // Campos que serao mostrados no Cadastro
         EndIf          
      ENDIF  
Next          

aAltera:= AClone(aCpos)

SX3->(dbSetOrder(nOrdSx3))
//-}     Fim

IF nOpc = 3
   AxInclui(cAlias,nReg,nOpc,aCpos,,,"EA110Valid('*')",,,)
ELSE
   IF AT(LEFT(SYB->YB_DESP,1),'129T') <> 0
      
      /*Quando o parâmetro MV_ALTDESP está desabilitado, restringe os campos que podem ser editados
      para despesas do tipo adiantamento*/
      If cAltera == "N" .And. Left(SYB->YB_DESP, 1) == "9"
         aAltera:= {"YB_DESCR", "YB_EVENT", "YB_PRODUTO", "YB_ESPECIE"}
      EndIf
      
      FOR I:=1 TO LEN(aDesp)
          lAchou:=.F.
          
          IF (SYB->YB_DESP $ "204,205,901,902,903")    
             lAchou:=.T.
             EXIT
          ENDIF
          
          IF EasyGParam(aDesp[I]) == SYB->YB_DESP
             lAchou:=.T.
             EXIT
          ENDIF
      NEXT
      
      If lAchou
         //Atualização da carga padrão para os itens com restrição de alteração
         EA110CPadr()
      EndIf
      IF ! lAchou
         IF cAltera == "S"
            lNaoAltera:=.F.            
         ELSE
            Help(" ",1,"A110TipInv")
            RETURN .F.
         ENDIF
      ENDIF
   ENDIF

   If(EasyEntryPoint("EICCAD00"),ExecBlock("EICCAD00",.F.,.F.,"ANTES_ALTERA_CAD_DESPESAS"),)
   
   If Len(aAltRdm) > 0
      aAltera:= AClone(aAltRdm)
   EndIf

   AxAltera(cAlias,nReg,nOpc,aCpos,aAltera,,,"EA110Valid('*')",,,)
   lNaoAltera:=.T.
   
   If(EasyEntryPoint("EICCAD00"),ExecBlock("EICCAD00",.F.,.F.,"DEPOIS_ALTERA_CAD_DESPESAS"),)
   
ENDIF

Return Nil
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³I110Deleta³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclusao de Despesas                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ I110Deleta(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICA110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION I110Deleta(cAlias,nReg,nOpc)
LOCAL nOpcA ,cCod 
LOCAL oDlg

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]

IF LEFT(SYB->YB_DESP,1) == "1" .OR. LEFT(SYB->YB_DESP,1) == "2" .OR. LEFT(SYB->YB_DESP,1) == "9"
   Help(" ",1,"EIC110NDES")
   Return .F.
ENDIF

SWD->(DBSETORDER(2))

If SWD->(DBSEEK(xFilial("SWD")+SYB->YB_DESP))
   HELP(" ",1,"EIC110TDES")
   SWD->(DBSETORDER(1))
   Return .F.
EndIf

SWD->(DBSETORDER(1))

While .T.
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Envia para processamento dos Gets          ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        nOpcA:=0

        RecLock(cAlias,.F.,.T.)

        DEFINE MSDIALOG oDlg TITLE cCadastro+OemToAnsi(STR0017);//" - Exclusao"
        FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
        //FROM 9,0 TO TranslateBottom(.F.,28),80 of oMainWnd
        //FROM 9,0 TO 28,80 OF oMainWnd
        
        aPos := PosDlg(oDlg)        
        oMsmget:= Msmget():New(cAlias, nReg, nOpc,,,,,aPos,,3)
        oMsmget:oBox:Align := CONTROL_ALIGN_ALLCLIENT
        nOpca:= 1
        oDlg:lMaximized := .T. //MCF - 23/07/2015
        ACTIVATE MSDIALOG oDlg ON INIT ;
        EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()},.T.)

        IF nOpcA == 2

           Begin Transaction
                (cAlias)->(dbDelete())
                (cAlias)->(MsUnlock())
           End Transaction
        Else
           (cAlias)->(MsUnlock())
        EndIf
        Exit
End

dbSelectArea(cAlias)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA120  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao do Cadastro de Familias            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function EICA120

Local cAux      := ""
LOCAL cAlias    :="SYC"
LOCAL cCadastro := AnsitoOem(STR0018) //"Família de Produtos"

If !EasyCallMVC("MVC_EICA120",1)// CRF 
   cAux := AxCadastro(cAlias,cCadastro)
EndIf

Return cAux     

//PRIVATE aMemos:={{"YC_DESC_GI","YC_DESC_GV"}}


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA130  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de NBM / TEC                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICA130(xRotAuto,nOpcAuto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Define Variaveis                                             ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cAlias:="SYD" //mjb150999, nOldArea:=Select()
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Define Array contendo as Rotinas a executar do programa      ³
  //³ ----------- Elementos contidos por dimensao ------------     ³
  //³ 1. Nome a aparecer no cabecalho                              ³
  //³ 2. Nome da Rotina associada                                  ³
  //³ 3. Usado pela rotina                                         ³
  //³ 4. Tipo de Transa‡„o a ser efetuada                          ³
  //³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
  //³    2 - Simplesmente Mostra os Campos                         ³
  //³    3 - Inclui registros no Bancos de Dados                   ³
  //³    4 - Altera o registro corrente                            ³
  //³    5 - Remove o registro corrente do Banco de Dados          ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If xRotAuto <> NIL
  MVC_EICA130(xRotAuto,nOpcAuto)
ElseIf !EasyCallMVC("MVC_EICA130",1)

  PRIVATE aMemos:={{"YD_TEXTO","YD_VM_TEXT"}} //LRL 25/05/04
  PRIVATE aRotina := MenuDef(ProcName())
  PRIVATE cDelFunc
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Define o cabecalho da tela de atualizacoes                   ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  PRIVATE cCadastro := STR0019 //"TEC / NCM"
  PRIVATE aParam:={ {|| .T. } , {|| .T. } , {|nOpc| Ax130GrvCpo(nOpc) } , {|| .T. } }//AWR - 07/02/2006
  PRIVATE lTelaContent := .F. //MCF - 26/04/2016
  PRIVATE lTelaComexQA := .F. //MCF - 26/04/2016
  IF SYD->(FIELDPOS("YD_MOT_II")) # 0 .AND. SYD->(FIELDPOS("YD_MOT_IPI")) # 0//AWR - 08/02/2006
    AADD(aMemos,{"YD_MOT_II" ,"YD_MOII_VM"})
    AADD(aMemos,{"YD_MOT_IPI","YD_MOIPIVM"})
  ENDIF

  //FDR - 29/10/2012 - PE para manipular o aRotina
  If(EasyEntryPoint("EICA130"),ExecBlock("EICA130",.F.,.F.,"MENU"),)

  mBrowse( 6, 1,22,75,cAlias)
  //mjb150999 DbSelectArea(nOldArea)
EndIf

Return .T.

*------------------------------------------------------------------------------------------
Function Ax130Inclui(cAlias,nReg,nOpc)
*------------------------------------------------------------------------------------------
Private aBotoesNCM := {}
Private lValida := .F. // LGS - 07/08/2013
// AxInclui(cAlias,nReg,nOpc,aAcho,cFunc,aCpos,cTudoOk)

// cFunc = chamado antes da execucao de AxInclui
If ChkFile("EVJ") //MCF - 26/10/2015
   AAdd(aBotoesNCM, {"NOTE",{|| Ax130ExNCM() }, STR0061})  //"Consultar EX-NCM"
Endif

If(EasyEntryPoint("EICCAD00"),ExecBlock("EICCAD00",.F.,.F.,"INCLUSAO"),)    //TRP-29/05/08-Inclusão de ponto de entrada

AxInclui(cAlias,nReg,nOpc,,,,"A130TudoOk()",,,aBotoesNCM,aParam) 

If lValida == .T. // LGS - 07/08/2013 - Ponto de Entrada após a inclusão de nova N.c.m.
	If(EasyEntryPoint("EICCAD00"),ExecBlock("EICCAD00",.F.,.F.,"VALIDA_TUDO_OK"),)  
EndIf

Return NiL

*--------------------------------------------------------*
Function Ax130Altera(cAlias,nReg,nOpc)//AWR - 07/02/2006
*--------------------------------------------------------*
Private aBotoesNCM := {}

If ChkFile("EVJ") //MCF - 26/10/2015
   AAdd(aBotoesNCM, {"NOTE",{|| Ax130ExNCM() }, STR0061})  //"Consultar EX-NCM"
Endif

If ChkFile("EVL") //MCF - 26/10/2015
   AAdd(aBotoesNCM, {"NOTE",{|| Ax130Anuen() }, STR0067})  //"Consultar Anuencias"
Endif

If(EasyEntryPoint("EICCAD00"),ExecBlock("EICCAD00",.F.,.F.,"ALTERACAO"),)  //TRP-29/05/08-Inclusão de ponto de entrada

//AxAltera(cAlias,nReg,nOpc,,,,,"Ax130Val()",,,aBotoesNCM,aParam)
AxAltera(cAlias,nReg,nOpc,,,,,,,,aBotoesNCM,aParam)

Ax130Val()

Return 

*--------------------------------------------------------*
Function Ax130Visual(cAlias,nReg,nOpc)//AWR - 07/02/2006
*--------------------------------------------------------*
Private aBotoesNCM := {}

If ChkFile("EVJ") //MCF - 26/10/2015
   AAdd(aBotoesNCM, {"NOTE",{|| Ax130ExNCM() }, STR0061})  //"Consultar EX-NCM"
Endif

If ChkFile("EVL") //MCF - 26/10/2015
   AAdd(aBotoesNCM, {"NOTE",{|| Ax130Anuen() }, STR0067})  //"Consultar Anuencias"
Endif

   AxVisual(cAlias,nReg,nOpc,,,,,aBotoesNCM)

Return
*--------------------------------------------------------*
Function Ax130Val(nOpc)//LGS - 19/07/2013
*--------------------------------------------------------*
Private lRet := .T.

If(EasyEntryPoint("EICCAD00"),ExecBlock("EICCAD00",.F.,.F.,"ALTERACAO_TUDO_OK"),)  //LGS - 19/07/2013-Inclusao de ponto de entrada

Return lRet

*--------------------------------------------------------*
Function Ax130GrvCpo(nOpc)//AWR - 07/02/2006
*--------------------------------------------------------*
IF SYD->(FIELDPOS("YD_GRVUSER")) # 0 .AND. SYD->(FIELDPOS("YD_GRVDATA")) # 0 .AND. SYD->(FIELDPOS("YD_GRVHORA")) # 0
   
   //TRP 14/08/07 - Verifica se o registro já está travado.
   If !SYD->( isLocked() )
      SYD->(RecLock("SYD",.F.))
   EndIf
   
   SYD->YD_GRVUSER:=cUserName
   SYD->YD_GRVDATA:=dDataBase
   SYD->YD_GRVHORA:=TIME()

ENDIF

If(EasyEntryPoint("EICA130"),ExecBlock("EICA130",.F.,.F.,"GRV_CPOS"),)  // GFP - 17/01/2013
RETURN .T.

*------------------------------------------------------------------------------------------
Function A130TudoOk()
*------------------------------------------------------------------------------------------

Local nLenArq:=LEN(SYD->YD_TEC),nLenMem:=LEN(M->YD_TEC)

If nLenArq>nLenMem
   M->YD_TEC:=M->YD_TEC+SPACE(nLenArq-nLenMem)
Elseif nLenArq<nLenMem
   M->YD_TEC:=M->YD_TEC+SPACE(nLenMem-nLenArq)
Endif

// GFP - 17/12/2013 - Conforme legislação vigente, é possível incluir NCMs com TEC iguais e número de destaque diferentes. 
If SYD->(DbSeek(xFilial()+M->YD_TEC+M->YD_EX_NCM+M->YD_EX_NBM+M->YD_DESTAQU))
   Help(" ",1,"JAGRAVADO")
   lValida := .F. //LGS - 07/08/2013 - Se N.c.m. já cadastrada variavel recebe valor .F.
   Return .F.
Endif

lValida := .T. //LGS - 07/08/2013 - Se cadastro ok variavel recebe valor .T.
Return .T.


*------------------------------------------------------------------------------------------
Function Ax130ExNCM()
*------------------------------------------------------------------------------------------
Local cCadastro:= STR0062  //"Relação de EX-NCM"
Local bOk 	   	 := {|| oDlg:End() }
Local bCancel	 := {|| oDlg:End() }
Local aCampos	 := {"EVJ_TEC", "EVJ_EX", "EVJ_DESC", "EVJ_ALIQ", "EVJ_DTINI", "EVJ_DTFIN", "EVJ_OBS"}
Local oBrowse
Local oDlg 
Local nInc

   DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI * 0.7, DLG_COL_INI * 0.7;
   									 TO DLG_LIN_FIM * 0.7, DLG_COL_FIM * 0.7 STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd PIXEL
	
	   DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "EVJ" OF oDlg
	 
	  	For nInc := 1 To Len(aCampos)
			ADD COLUMN oColumn DATA &("{ || Transform(" + aCampos[nInc] + ",AvSx3('" + aCampos[nInc] + "', 6)) }") TITLE AvSx3(aCampos[nInc], AV_TITULO) SIZE AvSx3(aCampos[nInc], AV_TAMANHO) OF oBrowse
		Next
	   
	   oBrowse:SetFilter("EVJ_FILIAL + EVJ_TEC ", xFilial("EVJ") + M->YD_TEC, xFilial("EVJ") + M->YD_TEC)
	
	   ACTIVATE FWBROWSE oBrowse
	   //oDlg:lMaximized := .T.

   ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) CENTERED
   
Return

*------------------------------------------------------------------------------------------
Function Ax130Anuen()
*------------------------------------------------------------------------------------------
Local cCadastro:= STR0068  //"Relação de Anuências"
Local bOk 	   	 := {|| oDlg:End() }
Local bCancel	 := {|| oDlg:End() }
Local aCampos	 := {"EVL_TEC", "EVL_EX", "EVL_DESCEX", "EVL_LI", "EVL_ORGAO", "EVL_INDIC", "EVL_TRATA", "EVL_ABRAN", "EVL_DESCME", "EVL_PAIS", "EVL_CODREG", "EVL_REGIME", "EVL_FUNCAO", "EVL_TEXTO"}
Local oBrowse
Local oDlg 
Local nInc

   DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI * 0.7, DLG_COL_INI * 0.7;
   									 TO DLG_LIN_FIM * 0.7, DLG_COL_FIM * 0.7 STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd PIXEL
	
	   DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "EVL" OF oDlg
	 
	  	For nInc := 1 To Len(aCampos)
			ADD COLUMN oColumn DATA &("{ || Transform(" + aCampos[nInc] + ",AvSx3('" + aCampos[nInc] + "', 6)) }") TITLE AvSx3(aCampos[nInc], AV_TITULO) SIZE AvSx3(aCampos[nInc], AV_TAMANHO) OF oBrowse
		Next
	   
	   oBrowse:SetFilter("EVL_FILIAL + EVL_TEC ", xFilial("EVL") + M->YD_TEC, xFilial("EVL") + M->YD_TEC)
	
	   ACTIVATE FWBROWSE oBrowse
	   //oDlg:lMaximized := .T.

   ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) CENTERED
   
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA190  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Incoterms                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICA190
Local cAux := ""
LOCAL cCadastro := STR0020 //"Incoterms"

If !EasyCallMVC("MVC_EICA190",1)// CRF 
   cAux := AxCadastro("SYJ",cCadastro)
EndIf 

Return cAux

*-----------------------*
FUNCTION TEG100FabFor()
*-----------------------*
LOCAL MResposta:="",MProximo:=0,TRECNO:=SYU->(RECNO())

MResposta:=MSGYESNO(STR0021,OemToAnsi(STR0022)) //"DESEJA GERACAO AUTOMATICA DA TABELA DE-PARA FABR/FORN (S-Sim N-Nao)"###"GERA€ÇO DA TABELA"

IF MResposta # .T.
   RETURN .F.
ENDIF

Processa({|lEnd|TEG100Proc()},STR0023) //"Lendo Cadastro de Despachantes"

SYU->(DBSEEK(xFilial("SYU")))

RETURN NIL
*--------------------*
Function TEG100Proc()
*--------------------*
//LRS - 18/06/2016 - Modificado a função para trabalhar de acordo com o filtro da function GetEmpAgen
Local aOrd := SaveOrd("SY5"),X:= 0,cCond := ""
ProcRegua(SY5->(LASTREC()))

SYU->(DBSETORDER(2))

IF lFiltro
  SY5->(DBSETORDER(3))
  SY5->(DbSeek(xFilial("SY5")+AvKey(cTipo,"Y5_TIPOAGE")+AvKey(cCod,"Y5_COD")))
  cCond := 'xFilial("SY5") == SY5->Y5_FILIAL .AND. AvKey(cTipo,"Y5_TIPOAGE") == SY5->Y5_TIPOAGE .AND. AvKey(cCod,"Y5_COD") == SY5->Y5_COD '
Else
SY5->(DBSEEK(xFilial("SY5")))
  cCond := 'xFilial("SY5") == SY5->Y5_FILIAL'
EndIF


WHILE !SY5->(EOF()) .AND. &cCond

  IncProc(STR0024+SY5->Y5_COD) //"Processando Despachante Nr. "

  SYU->(DBSETORDER(2))
  Mproximo:=0
  IF SYU->(DBSEEK(xFilial()+SY5->Y5_COD+"2"))
     SYU->(DBSEEK(xFilial()+SY5->Y5_COD+"2"+"9999",.T.))
     SYU->(DBSKIP(-1))
     IF SYU->YU_DESP # SY5->Y5_COD
        SY5->(DBSKIP())
        LOOP
     ENDIF
     Mproximo:=VAL(SYU->YU_GIP_1)
  ENDIF

  SYU->(DBSETORDER(1))
//SA2->(DBGOTOP())
  SA2->(DBSEEK(xFilial("SA2")))
  WHILE !SA2->(EOF()) .AND. xFilial("SA2") == SA2->A2_FILIAL

    *MSG("PROCESSANDO FABRICANTE/FORNECEDOR  - " +PADL(Fab_For->FBCOD,6,"0"),0 )

    IF SYU->(DBSEEK(xFilial()+SY5->Y5_COD+"2"+SA2->A2_COD))
       SA2->(DBSKIP())
       LOOP
    ENDIF

    MProximo++
    cDesp  := SY5->Y5_COD
    cTipo  := "2"
*   cEasy  := PADL(SA2->A2_COD,6,"0")
    cEasy  := SA2->A2_COD
    cLoja  := SA2->A2_LOJA //LRS
    cGip_1 := PADL(MProximo,AVSX3("YU_GIP_1",3),"0")

    TEG100GRAVA()
    X++

    SA2->(DBSKIP())
  END
  SY5->(DBSKIP())
END

IF X> 0
  MSGINFO(STR0076 + " " + cValToChar(X) +" "+ STR0077)//Processo finalizado com Sucesso. Foram criados XXX De/Para
Else
  MSGINFO(STR0078,STR0043)//Não foi localizado nenhum registro de acordo com o filtro.
EndIF

RestOrd(aOrd,.T.)
SY5->(DBSETORDER(1))

*-------------------*
Function TEG100GRAVA
*-------------------*
RecLock("SYU",.T.)
SYU->YU_FILIAL  := xFilial("SYU")
SYU->YU_DESP    := cDesp
SYU->YU_TIP_CAD := cTipo
SYU->YU_EASY    := cEasy
SYU->YU_LOJA    := cLoja //LRS
SYU->YU_GIP_1   := cGip_1
RETURN NIL

/*
*-------------------*
Function TEG100Ini()
*-------------------*
LOCAL cDesc, cAlias, cChave, bCampo
IF EMPTY(M->YU_DESP)
   RETURN SPACE(30)
ENDIF

DO CASE
   CASE M->YU_TIP_CAD == IMPORTADOR
        cAlias:="SYT"
        cChave:=xFilial()+LEFT(M->YU_EASY,2)
        bCampo:={||M->YU_DESC:=SYT->YT_NOME}

   CASE M->YU_TIP_CAD == FABFOR
        cAlias:="SA2"
        cChave:=xFilial()+M->YU_EASY
        bCampo:={||M->YU_DESC:=SA2->A2_NREDUZ}

   CASE M->YU_TIP_CAD == AGENTES
        cAlias:="SY4"
        cChave:=xFilial()+LEFT(M->YU_EASY,3)
        bCampo:={||M->YU_DESC:=SY4->Y4_NOME}
ENDCASE
(cAlias)->(DBSEEK(cChave))
EVAL(bCampo)
IF EMPTY(M->YU_DESC)
   RETURN SPACE(30)
ENDIF
lRefresh:=.T.
RETURN M->YU_DESC
*/

*----------------------------------*
Function TC210Valid(Campo,lLinOk)
*----------------------------------*
Local aValII   := {}
Local aValICMS := {}
IF TRB->WI_DESP == EasyGParam("MV_D_FOB") .AND. lLinOk==NIL // Despesa 101
   Help(" ",1,"TC210NALT")
   RETURN .F.
ENDIF

/*
IF SYB->YB_DESP != TRB->WI_DESP
   SYB->(DBSEEK(xFilial()+TRB->WI_DESP))
ENDIF*/

DO CASE
   CASE Campo == "WI_VALOR"
        IF TRB->WI_IDVL == VALOR  // FRS 28/01/10 - Campo Valor obrigatório apenas quando Tipo de Despesa = Valor.
           IF EMPTY(M->WI_VALOR)
              Help(" ",1,"TC210VBRAN")
              RETURN .F.
           ENDIF
        ELSE       // Percentual
           IF ! EMPTY(M->WI_VALOR)
              Help(" ",1,"TC210VL")
              RETURN .F.
           ENDIF
        ENDIF

   CASE Campo == "WI_PERCAPL"
        IF TRB->WI_IDVL == PERCENTUAL
           IF EMPTY(M->WI_PERCAPL)
              Help(" ",1,"TC210PBRAN")
              RETURN .F.
           ENDIF
        ELSE
           IF !EMPTY(M->WI_PERCAPL)
              Help(" ",1,"TC210PERC")
              RETURN .F.
           ENDIF
        ENDIF

        //WFS 14/09/09
        //Não permite que as alíquitas dos impostos sejam alteradas pelo usuário na tabela de pré-cálculo
        If TRB->WI_DESP $ "201202204205" .And. lLinOk == Nil
           MsgInfo(STR0041) //A alíquota deste imposto é calculada conforme o cadastro de NCM
           Return .F.
        EndIf
        
   CASE Campo == 'WI_DESPBAS'
        IF TRB->WI_IDVL == PERCENTUAL
           IF Empty(M->WI_DESPBAS)
              Help(" ",1,"EA110DESPB")
              RETURN .F.
           ENDIF
           If !EA110DespBase(M->WI_DESPBAS)
              RETURN .F.
           Endif
           If EasyGParam("MV_EIC0068",,0) > 0 .And. !(Left(TRB->WI_DESP,1) $ "129")
              aValII   := EA110RefCirc("II"  ,TRB->WI_DESP,TRB->WI_DESP,M->WI_DESPBAS,"TRB",M->WI_VIA,M->WI_TAB,.T.,.T.) //NCF - 27/12/2017
              aValICMS := EA110RefCirc("ICMS",TRB->WI_DESP,TRB->WI_DESP,M->WI_DESPBAS,"TRB",M->WI_VIA,M->WI_TAB,.T.,.T.) //NCF - 27/12/2017
              If aValII[2] .Or. aValICMS[2]
                 RETURN .F.
              EndIf
           EndIf
        ELSE
           IF !Empty(M->WI_DESPBAS)
              Help(" ",1,"EA110NVZDB")
              RETURN .F.
           ENDIF
        ENDIF

   CASE CAMPO == 'WI_MOEDA'
***     IF TRB->WI_IDVL != PERCENTUAL
           IF Empty(M->WI_MOEDA)
              Help(" ",1,"EA110NOMOE")
              RETURN .F.
           ENDIF
           IF ! ExistCpo("SYF",M->WI_MOEDA,1)  //NCF - 16/09/2016
              RETURN .F.
           ENDIF
***     ELSE
***        IF !Empty(M->WI_MOEDA)
***           Help(" ",1,"EA110NVZMO")
***           RETURN .F.
***        ENDIF
***     ENDIF

    CASE Campo == 'WI_VAL_MAX'
*       IF TRB->WI_IDVL == VALOR
           IF M->WI_VAL_MAX < TRB->WI_VAL_MIN
              Help(" ",1,"A110MXME")
              RETURN .F.
           ENDIF
***        IF !EMPTY(M->WI_VAL_MAX)
***           Help(" ",1,"A110MBRAN")
***           RETURN .F.
***        ENDIF
/*      ELSE
           IF !Empty(M->WI_VAL_MAX)
              Help(" ",1,"A110MXIN")
              RETURN .F.
           ENDIF
        ENDIF*/

    CASE Campo == 'WI_VAL_MIN'
*       IF TRB->WI_IDVL == VALOR
           IF M->WI_VAL_MIN > TRB->WI_VAL_MAX
              Help(" ",1,"A110MIMA")
              RETURN .F.
           ENDIF
***        IF !EMPTY(M->WI_VAL_MIN)
***           Help(" ",1,"A110MBRAN")
***           RETURN .F.
***        ENDIF
/*      ELSE
           IF !Empty(M->WI_VAL_MIN)
              Help(" ",1,"A110MIIN")
              RETURN .F.
           ENDIF
        ENDIF*/

    CASE Campo == 'WI_IDVL'
       IF TRB->WI_DESP == '101'
          RETURN .F.
       ENDIF
       IF M->WI_IDVL == CONTEINER
          TRB->WI_DESPBAS := Space(9)
          TRB->WI_PERCAPL := 0
          TRB->WI_VALOR   := 0
          TRB->WI_KILO1   := 0
          TRB->WI_KILO2   := 0
          TRB->WI_KILO3   := 0
          TRB->WI_KILO4   := 0
          TRB->WI_KILO5   := 0
          TRB->WI_KILO6   := 0
          TRB->WI_VALOR1  := 0
          TRB->WI_VALOR2  := 0
          TRB->WI_VALOR3  := 0
          TRB->WI_VALOR4  := 0
          TRB->WI_VALOR5  := 0
          TRB->WI_VALOR6  := 0
       ELSEIF M->WI_IDVL == VALOR
          TRB->WI_PERCAPL := 0
          TRB->WI_DESPBAS := Space(9)
          If SYB->(FieldPos("YB_CON20")) # 0 .AND. SYB->(FieldPos("YB_CON40")) # 0 .AND. SYB->(FieldPos("YB_CON40H")) # 0 .AND. SYB->(FieldPos("YB_CONOUT")) # 0 .And. ;
             TRB->(FieldPos("WI_CON20")) # 0 .AND. TRB->(FieldPos("WI_CON40")) # 0 .AND. TRB->(FieldPos("WI_CON40H")) # 0 .AND. TRB->(FieldPos("WI_CONOUT")) # 0        //NCF - 16/09/2016
             TRB->WI_CON20   := 0
             TRB->WI_CON40   := 0
             TRB->WI_CON40H  := 0
             TRB->WI_CONOUT  := 0
          EndIf
          TRB->WI_KILO1   := 0
          TRB->WI_KILO2   := 0
          TRB->WI_KILO3   := 0
          TRB->WI_KILO4   := 0
          TRB->WI_KILO5   := 0
          TRB->WI_KILO6   := 0
          TRB->WI_VALOR1  := 0
          TRB->WI_VALOR2  := 0
          TRB->WI_VALOR3  := 0
          TRB->WI_VALOR4  := 0
          TRB->WI_VALOR5  := 0
          TRB->WI_VALOR6  := 0
       ELSEIF M->WI_IDVL == PERCENTUAL
          TRB->WI_VALOR   := 0
          If SYB->(FieldPos("YB_CON20")) # 0 .AND. SYB->(FieldPos("YB_CON40")) # 0 .AND. SYB->(FieldPos("YB_CON40H")) # 0 .AND. SYB->(FieldPos("YB_CONOUT")) # 0 .And. ;
             TRB->(FieldPos("WI_CON20")) # 0 .AND. TRB->(FieldPos("WI_CON40")) # 0 .AND. TRB->(FieldPos("WI_CON40H")) # 0 .AND. TRB->(FieldPos("WI_CONOUT")) # 0        //NCF - 16/09/2016
             TRB->WI_CON20   := 0
             TRB->WI_CON40   := 0
             TRB->WI_CON40H  := 0
             TRB->WI_CONOUT  := 0
          EndIf
          TRB->WI_KILO1   := 0
          TRB->WI_KILO2   := 0
          TRB->WI_KILO3   := 0
          TRB->WI_KILO4   := 0
          TRB->WI_KILO5   := 0
          TRB->WI_KILO6   := 0
          TRB->WI_VALOR1  := 0
          TRB->WI_VALOR2  := 0
          TRB->WI_VALOR3  := 0
          TRB->WI_VALOR4  := 0
          TRB->WI_VALOR5  := 0
          TRB->WI_VALOR6  := 0
       ELSEIF M->WI_IDVL == QUANTIDADE
         TRB->WI_PERCAPL := 0
         TRB->WI_DESPBAS := Space(9)
         TRB->WI_KILO1   := 0
         TRB->WI_KILO2   := 0
         TRB->WI_KILO3   := 0
         TRB->WI_KILO4   := 0
         TRB->WI_KILO5   := 0
         TRB->WI_KILO6   := 0
         TRB->WI_VALOR1  := 0
         TRB->WI_VALOR2  := 0
         TRB->WI_VALOR3  := 0
         TRB->WI_VALOR4  := 0
         TRB->WI_VALOR5  := 0
         TRB->WI_VALOR6  := 0
         If SYB->(FieldPos("YB_CON20")) # 0 .AND. SYB->(FieldPos("YB_CON40")) # 0 .AND. SYB->(FieldPos("YB_CON40H")) # 0 .AND. SYB->(FieldPos("YB_CONOUT")) # 0 .And. ;
            TRB->(FieldPos("WI_CON20")) # 0 .AND. TRB->(FieldPos("WI_CON40")) # 0 .AND. TRB->(FieldPos("WI_CON40H")) # 0 .AND. TRB->(FieldPos("WI_CONOUT")) # 0        //NCF - 16/09/2016
             TRB->WI_CON20   := 0
             TRB->WI_CON40   := 0
             TRB->WI_CON40H  := 0
             TRB->WI_CONOUT  := 0
          EndIf
       ELSEIF M->WI_IDVL == PESO
          TRB->WI_PERCAPL := 0
          TRB->WI_VALOR   := 0
          TRB->WI_DESPBAS := Space(9)
          If SYB->(FieldPos("YB_CON20")) # 0 .AND. SYB->(FieldPos("YB_CON40")) # 0 .AND. SYB->(FieldPos("YB_CON40H")) # 0 .AND. SYB->(FieldPos("YB_CONOUT")) # 0 .And. ;
             TRB->(FieldPos("WI_CON20")) # 0 .AND. TRB->(FieldPos("WI_CON40")) # 0 .AND. TRB->(FieldPos("WI_CON40H")) # 0 .AND. TRB->(FieldPos("WI_CONOUT")) # 0        //NCF - 16/09/2016
             TRB->WI_CON20   := 0
             TRB->WI_CON40   := 0
             TRB->WI_CON40H  := 0
             TRB->WI_CONOUT  := 0
          EndIf
       ENDIF

ENDCASE

RETURN .T.

// GFP - 22/07/2016 - Tratamento de edição de campos - Cadastro de Tabela de Pre-Calculo
*---------------------------*
Function TC210WHEN(cCampo)
*---------------------------*
Local lRet := .T., cAlias := Alias()

Do Case
   Case cCampo == "WI_CON20" .OR. cCampo == "WI_CON40" .OR. cCampo == "WI_CON40H" .OR. cCampo == "WI_CONOUT"
      lRet := !((cAlias)->WI_IDVL == VALOR  .OR. (cAlias)->WI_IDVL == PERCENTUAL) 
   Case cCampo == "WI_VALOR"
      lRet := !((cAlias)->WI_IDVL == CONTEINER .OR. (cAlias)->WI_IDVL == PERCENTUAL)
   Case cCampo == "WI_PERCAPL" .OR. cCampo == "WI_DESPBAS"
      lRet := !((cAlias)->WI_IDVL == CONTEINER .OR. (cAlias)->WI_IDVL == VALOR)
End Case

Return lRet

*-------------------------------------------*
Function TC210ValMoeda(Codigo,lLinOk,cCampo)
*-------------------------------------------*
IF TRB->WI_DESP == EasyGParam("MV_D_FOB") .AND. lLinOk == NIL  // Despesa 101
   Help(" ",1,"TC210NALT")
   RETURN .F.
ENDIF

SYE->(DBSETORDER(2))
//If TRB->WA_FB_NOME = "Valor"
IF !EMPTY(Codigo) .AND. !SYE->(DbSeek(xFilial()+Codigo))
   If AllTrim(Upper(Codigo)) <> AllTrim(Upper(EasyGParam("MV_SIMB1",,"R$ "))) //ER - 17/100/2006 - Verifica se não é a Moeda 1 (Padrão) do Sistema.

      SYE->(DBSETORDER(1))
      cTitulo:=IF(cCampo==NIL,STR0025,aHeader[ASCAN(aHeader,{|aCampo| AllTrim(aCampo[2])==AllTrim(cCampo)})][1] ) //"Moeda" //wfs 17/10 - alltrim no acampo
      Help("", 1, "AVG0000223",,Codigo+ " Moeda Val.",1,33)//MsgStop(OemtoAnsi(STR0026)+Codigo,STR0027) //"NÆo h  cota‡Æo para a moeda ==> "###"Moeda Val."
      RETURN .F.
   EndIf

ENDIF
SYE->(DBSETORDER(1))
//ENDIF
RETURN .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA200  ³ Autor ³ AVERAGE-JONATO        ³ Data ³ 11/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Registro no Ministerio da Fazenda              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICA200
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cDelFunc
PRIVATE aRotina := MenuDef(ProcName())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0028) //"Cadastro de Registros no Ministerio"

mBrowse( 6, 1,22,75,"SYG")
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CA200Val ³ Autor ³ AVERAGE-JONATO        ³ Data ³ 26/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Registro no Ministerio da Fazenda              ³±±
±±³          ³ Validacao de Importador e fabricante                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CA200Val()

LOCAL cCampo:= UPPER(READVAR())

DO CASE
   CASE cCampo == "M->YG_IMPORTA"
        SYT->(DBSETORDER(1))
        IF ! SYT->(DBSEEK(xfilial("SYT")+M->YG_IMPORTA))
           Help("", 1, "AVG0000224")//MSGINFO(OemToAnsi(STR0029),OemToAnsi(STR0030)) //"Importador nÆo cadastrado"###"Informa‡Æo"
           M->YG_FABLOJ := ""
           RETURN .F.
        ENDIF

        IF SYT->YT_IMP_CON <> "1"
           Help("", 1, "AVG0000225")//MSGINFO(OemToAnsi(STR0031),OemToAnsi(STR0030)) //"O c¢digo escolhido nÆo ‚ de importador"###"Informa‡Æo"
           M->YG_FABLOJ := ""
           RETURN .F.
        ENDIF
   CASE cCampo == "M->YG_FABRICA"
        IF SA2->(DBSEEK(xFilial("SA2")+M->YG_FABRICA)) .AND. Empty(M->YG_FABLOJ)  //MCF - 03/03/2015  // GFP - 18/08/2015
   		   Do While SA2->A2_FILIAL == xFilial("SA2") .AND. SA2->A2_COD == M->YG_FABRICA  // GFP - 08/09/2015
   		      If SA2->A2_MSBLQL $ cNao
   		         M->YG_FABLOJ := EicRetLoja("SA2","A2_LOJA")
   		         Exit
   		      EndIf
   		      SA2->(DbSkip())
   		   EndDo
        EndIf
        If !ExistChav('SYG',M->YG_IMPORTA+M->YG_FABRICA+If(EICLoja(),M->YG_FABLOJ,"")+M->YG_ITEM,1)  // GFP - 06/08/2013
           RETURN .F.
        EndIf        
        SA2->(DBSETORDER(1))                              
        IF ! SA2->(DBSEEK(xfilial("SA2")+M->YG_FABRICA+If(EICLoja(),M->YG_FABLOJ,"")))    // GFP - 06/08/2013
           Help("", 1, "AVG0000226")//MSGINFO(OemToAnsi(STR0032),OemToAnsi(STR0030)) //"Fabricante nÆo cadastrado"###"Informa‡Æo"
           M->YG_FABLOJ := ""
           RETURN .F.
        ENDIF
        IF SUBST(SA2->A2_ID_FBFN,1,1) == "2"
           Help("", 1, "AVG0000227")//MSGINFO(OemToAnsi(STR0033),OemToAnsi(STR0030)) //"O c¢digo escolhido nÆo ‚ de fabricante"###"Informa‡Æo"
           M->YG_FABLOJ := ""
           RETURN .F.
        ENDIF
ENDCASE
RETURN .T.





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICA210  ³ Autor ³ AVERAGE-AWR           ³ Data ³ 02/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro  das Tabelas de Seguro                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICCA210
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//mjb150999 LOCAL cOldArea:=Select()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

PRIVATE cDelFunc
PRIVATE aRotina := MenuDef(ProcName())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0034) //"Cadastro das Tabelas de Seguro"

mBrowse( 6, 1,22,75,"SYK")

//mjb150999 DbSelectArea(cOldArea)
Return .T.

*-----------------------*
Function CA210Valid()
*-----------------------*

M->YK_TXNORMA := (M->YK_TXBASE + M->YK_TXGUE)

M->YK_TXFINAL := M->YK_TXNORMA  - (M->YK_TXNORMA * ( M->YK_TXDESCO / 100 ))

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EIWU100  ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 08/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Modelo de Pedidos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICWU100

LOCAL nOldArea:=ALIAS()
LOCAL cCadastro := OemtoAnsi(STR0035) //"Modelo de Pedidos"
PRIVATE aMemos:={{"WU_OBS","WU_VM_OBS"}}


If ! ChkFile("SWU",.F.)
   Help("", 1, "AVG0000228")//MSGINFO(OemToAnsi(STR0036),OemToAnsi(STR0030)) //"ARQUIVO DE MODELO NÇO DISPON¡VEL ..."###"Informa‡Æo"
   RETURN .F.
ENDIF
If !EasyCallMVC("MVC_EICWU100",1) // CRF 30/03/11
   AxCadastro("SWU",cCadastro)
EndIf

SWU->(dbcloseAREA())
DBSELECTAREA(nOldArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICCR100 ³ Autor ³ AVERAGE               ³ Data ³ 30/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Corretoras                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------*
Function EICCR100
*----------------*
Local cAux := ""               
LOCAL cCadastro := STR0037 //"Corretoras"
If !EasyCallMVC("MVC_RC100EIC",1)// CRF 
   cAux := AxCadastro("SYW",cCadastro,,"CR100Valid()")
EndIf 

Return cAux





*---------------------------*
FUNCTION CR100VALGAT(cParam)//FUNCAO PARA VALIDAR OS GATIHOS
*---------------------------*
DO CASE

  CASE cParam=="FORN"

     //ISS - 24/09 - Alterado o gatilho para que o mesmo preencha corretamente a loja.
     IF EMPTY(M->YW_FORN)
        M->YW_LOJA:=""
     ELSE
     
     IF EMPTY(M->YW_LOJA) //LRS - 08/10/2014 - Caso não Carregue o M->YW_LOJA, Força a carregar para achar o Fornecedor.
     	 IF SA2->(DBSEEK(xFilial()+M->YW_FORN))
     	 	M->YW_LOJA := SA2->A2_LOJA 
     	 ENDIF	
     EndIF
     
        IF !ExistCpo("SA2",M->YW_FORN+IF(EICLoja(), M->YW_LOJA, ""))
           RETURN .F.
        ENDIF                              
        
        SA2->(DBSEEK(xFilial()+M->YW_FORN+IF(EICLoja(), M->YW_LOJA, "")))
       
        IF SUBST(SA2->A2_ID_FBFN,1,1) = "2" .OR. SUBST(SA2->A2_ID_FBFN,1,1) = "3"
           M->YW_LOJA:=SA2->A2_LOJA
        Else
           MsgInfo(STR0055, STR0043) //"O código escolhido não pertence ao cadastro de um fornecedor.", "Atenção"
           Return .F.            
        EndIf

     ENDIF           
     
  CASE cParam=="LOJA"
     RETURN (EMPTY(M->YW_FORN+M->YW_LOJA)).OR.(ExistCpo("SA2",M->YW_FORN+M->YW_LOJA))
     
ENDCASE     

RETURN .T.


*------------------------*
Function EICLIST00()
*------------------------*
STATIC lContYB      
Local cCampo:=ReadVar()
LOCAL oDlg
LOCAL nL1:=18, nL2:=31, nL3:=44, nC1:=6, nC2:=144
PRIVATE cItem:=SPACE(LEN(SFB->FB_CODIGO))
PRIVATE cSel :=SPACE(10)
PRIVATE aLista:={ },oItem

IF cPaisLoc="BRA"
   RETURN .F.
ENDIF

IF EasyGParam("MV_EASYFIN",,"N") $ cNao
   RETURN .F.
ENDIF

cContem:=M->YB_IMPINS                  
IF lContYB=NIL
   lContYB=.T.
   RETURN .F.
ENDIF   

IF !(UPPER(cCampo)=="M->YB_IMPINS")
   RETURN .T.
ENDIF


While ',' $ cContem  
    
    nPos:=at(',',cContem)
    
    AADD(aLista,Subs(cContem,1,nPos -1  ))
    
    cContem:=Subs(cContem,nPos+1)

end

IF !Empty(cContem)                        
   AADD(aLista,cContem)
ENDIF   
   
oMainWnd:ReadClientCoords()

lSaida:=.T.
DO WHILE lSaida
  lSaida:=.F.
  DEFINE MSDIALOG oDlg TITLE "Agregar/Borrar Impuestos Incidentes " ;
      FROM oMainWnd:nTop+125,oMainWnd:nLeft+80 TO oMainWnd:nBottom-250,oMainWnd:nRight-200;
            OF oMainWnd PIXEL  
                                                

      @ nL1,nC1 SAY "Impuesto " SIZE 25,08 PIXEL 
      @ nL1,nC1+32 MSGET cItem F3 "SFB" VALID EVAL({|| SFB->(DBSEEK(XFILIAL("SFB")+ALLTRIM(cItem) ) ),;
                                              IF( !EMPTY(cItem) .AND. SFB->(EOF()),EVAL({|| Help("", 1, "AVG0000229"),.F.}),.T.)}) SIZE 55,8 PIXEL //MSGINFO("Impuesto no es correcto","Informacion"),.F. }),.T. ) }) SIZE 55,8 PIXEL
      @ nL1,144 SAY "Impuestos Incidentes"  PIXEL
      
      @ 33,104 BUTTON "Agregar" SIZE 34,11 FONT oDlg:oFont   ; 
         ACTION ( EVAL({ || If(!EMPTY(cItem).AND.ASCAN(aLista,ALLTRIM(cItem))=0,AADD(alista,ALLTRIM(cItem) ),),lSaida:=.T. ,oDlg:End()}) ) OF oDlg PIXEL
       
      @ 53,104 BUTTON "Borrar" SIZE 34,11 FONT oDlg:oFont ;
         ACTION ( EVAL({ || xasc:=ASCAN(aLista,cSel), If(xAsc=0,,ADEL(aLista,xAsc)),If(!(xAsc==0),ASIZE(aLista,Len(aLista)-1),),lSaida:=.T. ,oDlg:End() }) ) OF oDlg PIXEL
         
      @ 33,144 LISTBOX oItem VAR cSel ITEMS aLista SIZE 80,55 PIXEL
      
      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
                { || M->YB_IMPINS:='',AEVAL(aLista, {|xValor,nIndex| M->YB_IMPINS:=ALLTRIM(M->YB_IMPINS)+IF(!EMPTY(xValor),IF(nIndex=1,'',',')+ALLTRIM(xValor),'') }), lSaida:=.F.   ,oDlg:End()},{|| lSaida:=.F. ,oDlg:End()})
      

ENDDO
RETURN .F.

*----------------------------*
FUNCTION CR100Valid()
*----------------------------*
LOCAL nMacro, I

IF !EMPTY(M->YW_VLR_02) .AND. M->YW_VLR_02 <= M->YW_VLR_MIN
   Help(" ",1,"AVG0000108")
   RETURN .F.
ENDIF

IF !EMPTY(M->YW_VLR_03) .AND. M->YW_VLR_03 <= M->YW_VLR_02
   Help(" ",1,"AVG0000108")
   RETURN .F.
ENDIF

IF !EMPTY(M->YW_VLR_04) .AND. M->YW_VLR_04 <= M->YW_VLR_03
   Help(" ",1,"AVG0000108")
   RETURN .F.
ENDIF

IF !EMPTY(M->YW_VLR_05) .AND. M->YW_VLR_05 <= M->YW_VLR_04
   Help(" ",1,"AVG0000108")
   RETURN .F.
ENDIF

FOR I:= 4 to 2 step -1
    nMacro := Str( I,1 )
    IF ! EMPTY( M->YW_VLR_0&nMacro  )    
       IF !EMPTY(M->YW_VLR_05) .AND. M->YW_VLR_05 < M->YW_VLR_0&nMacro
          Help(" ",1,"AVG0000108")
          RETURN .F.
       ENDIF
       EXIT
    ENDIF   
NEXT

FOR I:=2 TO 5
    nMacro := Str( i,1 )
    IF (!EMPTY(M->YW_VLR_0&nMacro) .AND. EMPTY(M->YW_PERC_0&nMacro)) .OR.;
       (EMPTY(M->YW_VLR_0&nMacro) .AND. !EMPTY(M->YW_PERC_0&nMacro))
       Help(" ",1,"AVG0000109")
       RETURN .F.
    ENDIF   
NEXT

RETURN .T.

/*
Funcao     : MenuDef()
Parametros : cFuncao
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya	
Data/Hora  : 22/01/07 - 11:12
*/
Static Function MenuDef(cOrigem)
Local aRotAdic := {}
Local aRotina := {}
Local aComexContent := {}, aComexDataQA := {} // GFP - 18/03/2015 //MCF - 02/02/2016
Default cOrigem  := AvMnuFnc()

cOrigem := Upper(AllTrim(cOrigem))

Begin Sequence

   Do Case
   
      Case cOrigem $ "EICA050" //Despachantes
          Aadd(aRotina, { STR0007  , "AxPesqui"     , 0 , 1})	//"Pesquisar"
          Aadd(aRotina, { STR0008  , "AxVisual"     , 0 , 2})	//"Visualizar"
          Aadd(aRotina, { STR0009  , "U_ManutCad00" , 0 , 3})	//"Incluir"
          Aadd(aRotina, { STR0010  , "U_ManutCad00" , 0 , 4})	//"Alterar"
          Aadd(aRotina, { STR0011  , "AxDeleta"     , 0 , 5})	//"Excluir"
          Aadd(aRotina, { STR0038  , "FtContato"    , 0 , 4})   //"Contatos"

          If EasyEntryPoint("IA050MNU")
	         aRotAdic := ExecBlock("IA050MNU",.f.,.f.)
	         If ValType(aRotAdic) == "A"
		        AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	         EndIf
          EndIf


      Case cOrigem $ "EICA070" //Mensagens
           Aadd(aRotina, { STR0007, "AxPesqui"  , 0 , 1}) //"Pesquisar"
           Aadd(aRotina, { STR0008, "AxVisual"  , 0 , 2}) //"Visualizar"
           Aadd(aRotina, { STR0009, "AxInclui"  , 0 , 3}) //"Incluir"
           Aadd(aRotina, { STR0010, "AxAltera"  , 0 , 4}) //"Alterar"
           Aadd(aRotina, { STR0011, "AxDeleta"  , 0 , 5,3}) //"Excluir"
 
           If EasyEntryPoint("IA070MNU")
	          aRotAdic := ExecBlock("IA070MNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf
      

      Case cOrigem $ "EICA130" // NCM
           aAdd(aComexContent,{ STR0063 , "CD100MenuCnt" , 0 , 3})  //"Configurações" // GFP - 18/03/2015
           aAdd(aComexContent,{ STR0064 , "CD100IntNCM"  , 0 , 3})  //"TOTVS Comex Conteúdo - NCM" // GFP - 18/03/2015
           //aAdd(aComexContent,{ STR0065 , "CD100IntOrg"  , 0 , 3})  //"TOTVS Comex Conteúdo - Anuencias" // MCF - 05/02/2016

           aAdd(aComexDataQA ,{ STR0063 , "CD100MenuQA"  , 0 , 3})  //"Configurações" // MCF - 02/02/2016
           aAdd(aComexDataQA ,{ STR0066 , "CD100CDQA"    , 0 , 3})  //"Comex Data QA"

           Aadd(aRotina, { STR0007,"AxPesqui"    , 0 , 1}) //"Pesquisar"
           //Aadd(aRotina, { STR0008,"AxVisual"    , 0 , 2}) //"Visualizar"
           Aadd(aRotina, { STR0008,"Ax130Visual" , 0 , 2}) //"Visualizar"
           Aadd(aRotina, { STR0009,"Ax130Inclui" , 0 , 3}) //"Incluir"
           Aadd(aRotina, { STR0010,"Ax130Altera" , 0 , 4}) //"Alterar"
           Aadd(aRotina, { STR0011,"EasyDeleta"  , 0 , 5,3}) //"Excluir"
           If FindFunction("EICCD100") //.AND. FindFunction("EasyComexDataQA")   // GFP - 18/03/2015 //MCF - 02/02/2016
              Aadd(aRotina, { STR0060,aComexContent , 0 , 0}) //"TOTVS Comex Conteúdo"
           EndIf
           If EasyGParam("MV_EIC0061",,.F.) .And. FindFunction("EasyComexDataQA") //MCF - 03/02/2016
              Aadd(aRotina, { STR0066,aComexDataQA  , 0 , 3}) //MCF - 02/02/2016
           Endif
           
           If EasyEntryPoint("IA130MNU")
 	          aRotAdic := ExecBlock("IA130MNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf

      //FDR - 06/03/2012
      Case cOrigem $ "EICA010" // Compradores
           Aadd(aRotina, { STR0007,"AxPesqui"   , 0 , 1}) //"Pesquisar"
           Aadd(aRotina, { STR0008,"AxVisual"   , 0 , 2}) //"Visualizar"
           Aadd(aRotina, { STR0009,"AxInclui"   , 0 , 3}) //"Incluir"
           Aadd(aRotina, { STR0010,"AxAltera"   , 0 , 4}) //"Alterar"
           Aadd(aRotina, { STR0011,"EasyDeleta" , 0 , 5,3}) //"Excluir"
      
      //FDR - 26/03/2012
      Case cOrigem $ "EICA020" // Locais de entrega
           Aadd(aRotina, { STR0007,"AxPesqui"   , 0 , 1}) //"Pesquisar"
           Aadd(aRotina, { STR0008,"AxVisual"   , 0 , 2}) //"Visualizar"
           Aadd(aRotina, { STR0009,"AxInclui"   , 0 , 3}) //"Incluir"
           Aadd(aRotina, { STR0010,"AxAltera"   , 0 , 4}) //"Alterar"
           Aadd(aRotina, { STR0011,"EasyDeleta" , 0 , 5,3}) //"Excluir"     
      
      // GFP - 20/12/2013
      Case cOrigem $ "EICA040" // Agentes
           Aadd(aRotina, { STR0007,"AxPesqui"   , 0 , 1}) //"Pesquisar"
           Aadd(aRotina, { STR0008,"AxVisual"   , 0 , 2}) //"Visualizar"
           Aadd(aRotina, { STR0009,"AxInclui"   , 0 , 3}) //"Incluir"
           Aadd(aRotina, { STR0010,"AxAltera"   , 0 , 4}) //"Alterar"
           Aadd(aRotina, { STR0011,"EasyDeleta" , 0 , 5,3}) //"Excluir"   
      
      Case cOrigem $ "EICA200" // Registro Minist.
           Aadd(aRotina, { STR0007,   "AxPesqui"  , 0 , 1}) //"Pesquisar"
           Aadd(aRotina, { STR0008,   "AxVisual"  , 0 , 2}) //"Visualizar"
           Aadd(aRotina, { STR0009,   "AxInclui"  , 0 , 3}) //"Incluir"
           Aadd(aRotina, { STR0010,   "AxAltera"  , 0 , 4}) //"Alterar"
           Aadd(aRotina, { STR0011,   "AxDeleta"  , 0 , 5}) //"Excluir"
           
           If EasyEntryPoint("IA200MNU")
 	          aRotAdic := ExecBlock("IA200MNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf
      

      Case cOrigem $ "EICCA210" // Tabela de Seguros
           Aadd(aRotina, { STR0007,   "AxPesqui"  , 0 , 1}) //"Pesquisar"
           Aadd(aRotina, { STR0008,   "AxVisual"  , 0 , 2}) //"Visualizar"
           Aadd(aRotina, { STR0009,   "AxInclui"  , 0 , 3}) //"Incluir"
           Aadd(aRotina, { STR0010,   "AxAltera"  , 0 , 4}) //"Alterar"
           Aadd(aRotina, { STR0011,   "AxDeleta"  , 0 , 5}) //"Excluir"
           
           If EasyEntryPoint("ICA210MNU")
 	          aRotAdic := ExecBlock("ICA210MNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf
           
      Case cOrigem $ "EICA110" //Cadastro de Despesas
           Aadd(aRotina, { STR0007, "AxPesqui"  , 0 , 1}) //"Pesquisar"
           Aadd(aRotina, { STR0008, "AxVisual"  , 0 , 2}) //"Visualizar"
           Aadd(aRotina, { STR0009, "EA110Manut", 0 , 3}) //"Incluir"
           Aadd(aRotina, { STR0010, "EA110Manut", 0 , 4}) //"Alterar"
           Aadd(aRotina, { STR0011, "I110Deleta", 0 , 5,3}) //"Excluir"
                
           If EasyEntryPoint("IA110MNU")
 	          aRotAdic := ExecBlock("IA110MNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf

      OtherWise
         aRotina := StaticCall(MATXATU,MENUDEF)
   End Case
   
End Sequence

Return aRotina

/*
Funcao     : EasyDeleta()
Parametros : cAlias, nReg, nOpc
Retorno    : lRet
Objetivos  : Excluir processos que não estejam vinculado a outras fases
Autor      : Thiago Rinaldi - TRP
Data/Hora  : 13/02/12
*/
Function EasyDeleta(cAlias,nReg,nOpc)

Local lRet:=.T.,cOldArea:=select(),nOldorder:=indexord()
Local oDlg1,nInc,nOpc1:=0,cNewtit
Private aRotina := MenuDef(ProcName()) //LRS - 02/10/2014 - Criação do aRotina para não dar erro log com o parametro MVC ativo

Begin sequence

  Private aTela[0][0],aGets[0]

  IF nOPC == 5 .AND. ! EasyValDelEIC(cAlias) // GFP - 28/08/2013
     BREAK
  ENDIF
  (cAlias)->(DBSETORDER(1))
     
  DBSELECTAREA(cAlias)

  For nInc := 1 TO (cALIAS)->(FCount())
     M->&((cAlias)->(FIELDNAME(nInc))) := (cALIAS)->(FIELDGET(nInc))
  Next nInc

  cNewTit:=cCadastro
  bOk:={||IF(Msgnoyes(OemtoAnsi(STR0042),Oemtoansi(STR0043)),; //"Confirma Exclusão?"###"Atenção"
          (nOpc1:=1,oDlg1:End()),) }

  DEFINE MSDIALOG oDlg1 TITLE cNewTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
 
  EnChoice(cAlias, nReg, nOpc,,,,,PosDlg(oDlg1))
		
  ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,bOK,{||oDlg1:End()})
  
  If nOpc1 == 1
     (cAlias)->(DBGOTO(nReg))
     Reclock(cAlias,.F.)
     (cAlias)->(DBDELETE())
     (cAlias)->(MsUnlock())    
  EndIf
 
  dbselectarea(cOldArea)

  (cAlias)->(DBSETORDER(nOldorder))

End sequence

Return lRet

/*
Funcao     : EasyValDelEIC()
Parametros : cP_MODO
Retorno    : lRet
Objetivos  : Verifica se está vinculado a processos em outras fases
Autor      : Thiago Rinaldi - TRP	
Data/Hora  : 13/02/12
*/
*------------------------------*
FUNCTION EasyValDelEIC(cP_MODO)
*------------------------------*
// Descricao do Vetor aSEL => {MODO,{ALIAS,CONDICAO,MENSAGEM}}
LOCAL lRET := .T.
Local cOldArea:= Select()

#IFDEF TOP
   Local aSEL := {}   
   Local cQRY,nA1,nA2,cFIL,cMSG := ""
#ENDIF

Begin Sequence

#IFDEF TOP   
   
      IF cP_MODO = "SYD" &&& NCM
             AADD(aSel,{"SYD",; //MCF - 19/06/2015
                       {"SB1","B1_POSIPI = '"+SYD->YD_TEC+"'"+;
             	          "AND B1_EX_NCM = '"+SYD->YD_EX_NCM+"'"+;
             	          "AND B1_EX_NBM = '"+SYD->YD_EX_NBM+"'",STR0044},; //"Produto com N.C.M cadastrado"
                       {"SW3","W3_TEC    = '"+SYD->YD_TEC+"'"+;
             	          "AND W3_EX_NCM = '"+SYD->YD_EX_NCM+"'"+;
             	          "AND W3_EX_NBM = '"+SYD->YD_EX_NBM+"'",STR0045},; //"PO com Item Cadastrado"
                       {"SW5","W5_TEC    = '"+SYD->YD_TEC+"'"+;
                        "AND W5_EX_NCM = '"+SYD->YD_EX_NCM+"'"+;
                        "AND W5_EX_NBM = '"+SYD->YD_EX_NBM+"'",STR0046},; //"LI com item cadastrado"
                       {"SW7","W7_NCM    = '"+SYD->YD_TEC+"'"+;
             	          "AND W7_EX_NCM = '"+SYD->YD_EX_NCM+"'"+;
             	          "AND W7_EX_NBM = '"+SYD->YD_EX_NBM+"'",STR0047}}) //"Embarque com item cadastrado"
      ENDIF   
      
      //FDR - 06/03/12
      IF cP_MODO = "SY1" &&& COMPRADOR
            AADD(aSEL,{"SY1",{"SW0","W0_COMPRA = '"+SY1->Y1_COD+"'",STR0049},; //"Comprador está sendo utilizado na S.I."
                             {"SW2","W2_COMPRA = '"+SY1->Y1_COD+"'",STR0050}}) //"Comprador está sendo utilizado no P.O."
          
      ENDIF
      
      //FDR - 26/03/12
      IF cP_MODO = "SY2" &&& LOCAIS DE ENTREGA
            AADD(aSEL,{"SY2",{"SW0","W0__POLE = '"+SY2->Y2_SIGLA+"'",STR0051}})
            
      ENDIF
      
      // GFP - 20/12/2013
      IF cP_MODO = "SY4" &&& AGENTES
            AADD(aSEL,{"SY4",{"SW2","W2_AGENTE = '"+SY4->Y4_COD+"'",STR0053}})//"Agente está sendo utilizado no P.O."
            
      ENDIF
      
      cP_MODO := IF(cP_MODO=NIL,"",cP_MODO)
      IF ! EMPTY(cP_MODO)
         FOR nA1 := 1 TO LEN(aSEL)         
             FOR nA2 := 2 TO LEN(aSEL[nA1])                                  	
                // by CAF 04/04/2003 Testar se a tabela existe
                IF ! MsFile(RETSQLNAME(aSEL[nA1,nA2,1]))
                   Loop
                Endif

                cFIL := ALLTRIM(IF(LEFT(aSEL[nA1,nA2,1],1)="S",;
                                   SUBSTR(aSEL[nA1,nA2,1],2),;
                                   aSEL[nA1,nA2,1]))
                cQRY := CHANGEQUERY("SELECT COUNT(*) AS QRY_TOTAL "+;
                                    "FROM "+RETSQLNAME(aSEL[nA1,nA2,1])+" "+;
                                    "WHERE " + If(TcSrvType()<>"AS/400","D_E_L_E_T_ <> '*' ","@DELETED@ <> '*' ")+ "AND " +cFIL+; //ER - 07/04/2006 às 15:15 ////"WHERE D_E_L_E_T_ <> '*' AND "+cFIL+;
                                    "_FILIAL = '"+XFILIAL(aSEL[nA1,nA2,1])+"' AND "+;
                                    aSEL[nA1,nA2,2])
                DBUSEAREA(.T.,"TOPCONN",TCGENQRY(,,cQRY),"QRY",.T.,.T.)
                IF QRY->QRY_TOTAL > 0
                   cMSG := cMSG+aSEL[nA1,nA2,3]+", "
                ENDIF
                QRY->(DBCLOSEAREA())
             NEXT
         NEXT
         IF ! EMPTY(cMSG) .and. ! EMPTY(cP_MODO)
         // EJA - 06/07/2017
            EasyHelp(STR0048 + ENTER + ENTER + Left(cMsg, len(cMsg) - 2),STR0043) //"Exclusao Não Permitida:"###"Atenção"
            lRET := .F.
          ENDIF
      ENDIF
      //ELSE
#ENDIF
      //... DBF ...
#IFDEF TOP
      //ENDIF
#ENDIF

End Sequence

Dbselectarea(cOldArea)

RETURN(lRET)    

/*
Funcao    : EA110CPadr()
Autor     : WFS 	            
Data      : 23/09/2014 
Objetivo  : Corrigir a carga padrão das despesas que possuem restrição de campos para alteração
Retorna   : Nulo      
*/
Static Function EA110CPadr()


Begin Sequence

   SYB->(RecLock("SYB", .F.))
   
   Do Case
   
      Case SYB->YB_IDVL == "1" .And. Empty(SYB->YB_VALOR) //Valor      
         SYB->YB_VALOR:= 0.01
      
      Case SYB->YB_IDVL == "2" .And. Empty(SYB->YB_PERCAPL) //Percentual
         SYB->YB_IDVL:= "1"
         SYB->YB_VALOR:= 0.01      

   End Case
   
   If Empty(SYB->YB_MOEDA)
      SYB->YB_MOEDA:= "R$"
   EndIf
   
   SYB->(MsUnlock())

End Sequence


Return

/*
Funcao     : EICA130Valid()
Parametros : nValor
Retorno    : -
Objetivos  : Verifica aliquotas informadas na NCM.
Autor      : Marcos Roberto Ramos Cavini Filho
Data/Hora  : 29/06/2015
*/
*------------------------------*
FUNCTION EICA130Valid(nValor)
*------------------------------*
Default nValor := 0

If nValor > 100
    Help(" ",1,"EIC01004")
    Return .F.
Endif

Return .T.

/*
Funcao     : CD100MenuQA()
Parametros : cAlias, nReg, nOp
Retorno    : Nenhum
Objetivos  : Tratamento para utilização da opção 3, devido a "loop" da inserção automatica
Autor      : Marcos R. R. Cavini Filho - MCF
Data/Hora  : 26/04/2016 - 07:53
*/

Function CD100MenuQA(cAlias,nReg,nOp)
Default nOp := 0

	If lTelaComexQA
		nOp := 0
		lTelaComexQA := .F.
	EndIf

	If nOp == 1
	   CD100CFQA()
	   lTelaComexQA := .T.
	EndIf

Return

/*
Funcao     : GetEmpAgen()
Parametros : cCod,cTipo,lFiltro,aItens
Retorno    : Nenhum
Objetivos  : Tela de filtro para registro De/Para
Autor      : Lucas Raminelli 
Data/Hora  : 18/08/2016
*/

Function TEG100EmpAgen()
Local oButton1,oButton2,oGet1,oComboBo1,oSay1,oSay2
Local bEnable 
Local aItens := {STR0079,STR0080,STR0081,STR0082,STR0083} 
Private cCod := Space(AvSx3("Y5_COD",3)) 
Private cTipo := Space(AvSx3("Y5_TIPOAGE",3)) 
Private lFiltro := .T.
Static oDlg

  DEFINE MSDIALOG oDlg TITLE STR0070 FROM 000, 000  TO 180, 400 PIXEL//Selecione um filtro
  
    bEnable :={|| IF(lFiltro,(oGet1:Enable(),oComboBo1:Enable()),(oGet1:Disable(),oComboBo1:Disable()) )}
    
    @ 014, 014 CHECKBOX oCheckBo1 VAR lFiltro PROMPT STR0071 SIZE 048, 008 PIXEL ON CHANGE (EVAL(bEnable))// Usar Filtro
    
    @ 036, 015 SAY oSay1 PROMPT STR0072 SIZE 025, 007 OF oDlg  PIXEL//CODIGO Desp/Agente
    @ 034, 054 MSGET oGet1 VAR cCod F3 "SY5" SIZE 112, 010 OF oDlg  PIXEL
    
    @ 051, 015 SAY oSay2 PROMPT STR0073 SIZE 025, 007 OF oDlg  PIXEL//Tipo Desp/Agente
    @ 051, 054 MSCOMBOBOX oComboBo1 VAR cTipo ITEMS aItens SIZE 112, 010 OF oDlg  PIXEL
    
    @ 069, 054 BUTTON oButton1 PROMPT STR0074 SIZE 037, 012 OF oDlg ACTION (TEG100FabFor()) PIXEL//Confirmar
    @ 069, 102 BUTTON oButton2 PROMPT STR0075 SIZE 037, 012 OF oDlg ACTION (oDlg:End())PIXEL//Cancelar
    
    
    
  ACTIVATE MSDIALOG oDlg CENTERED

Return
