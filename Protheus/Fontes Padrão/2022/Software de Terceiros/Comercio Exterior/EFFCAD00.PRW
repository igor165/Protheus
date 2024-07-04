#INCLUDE "Effcad00.ch"
#include "EFF.CH"
#include "Average.CH"
/*
Programa : EFFCAD00.PRW
Objetivo : Conjunto de funcoes p/manutencao de Tabelas e Cadastros
Autor    : Heder M Oliveira
Data/Hora: 16/09/98 12:35
Obs      : Baseado no EICCAD00.PRW do V:\ADVWIN\SIGAEIC
Alteracao: Cristiano A. Ferreira 28/03/2000 - Protheus
*/

/*
Funcao    : EFFAT110()
Parametros: Nenhum
Objetivos : Retornar a fun‡Æo AxCadastro("SJ7","Instituicoes Financeiras")
Autor     : Heder M Oliveira
Data/Hora : 24/09/98 11:10
Obs.      : Ver. os1117/98
*/
Function EFFAT110()
    Private cCADASTRO:=STR0007 //"Instituições Financeiras"
    Private aRotina := MenuDef(ProcName())
    mBrowse( 6, 1,22,75,"SJ7" )
Return .T.


/*
Funcao    : EFFAC130()
Parametros: Nenhum
Objetivos : Retornar a fun‡Æo AxCadastro("SYW","Corretoras")
Autor     : Heder M Oliveira
Data/Hora : 16/09/98 15:26
Obs.      : Copia do d:\advwin\sigaeif\eicdifi400.prw
*/
Function EFFAC130()
Private cCADASTRO:=STR0008 //"Corretoras"
Private aRotina := MenuDef(ProcName())

   mBrowse( 6, 1,22,75,"SYW" )

Return .T.

/*
Funcao    : EFFAC120()
Parametros: Nenhum
Objetivos : Retornar a fun‡Æo AxCadastro("SYT",OemtoAnsi("Importadores/Consignat rios"))
Autor     : Regina H. Perez
Data/Hora : 03/03/99 15:20
Obs.      : Ver. os189/99
*/
Function EFFAC120()
Private cCADASTRO:=OemtoAnsi(STR0010) //"Importadores/Consignat rios"
Private aRotina := MenuDef(ProcName())

   mBrowse( 6, 1,22,75,"SYT" )

Return .T.

/*
Funcao      : EFFAT140()
Parametros  :
Retorno     :
Objetivos   :
Autor       : Heder M Oliveira
Data/Hora   :
Revisao     :
Obs.        :
*/
Function EFFAT140()
/*  
    // EJSA:
    // Comentado pois a função EECAT140 possibilita fazer integração ou executar o MBrowse.
    // A ausência de parâmetros fará a rotina ser executada com o MBrowse.

    Private cCadastro := STR0011 //"Taxas de Conversão"
    Private aRotina := MenuDef(ProcName())
    mBrowse( 6, 1,22,75,"SYE")
*/


EECAT140()

Return .T.

*---------------------------------------------------------------------------*
Function EFFAT140Manut(cAlias,nReg,nOpc)
*---------------------------------------------------------------------------*
LOCAL cAliasOld := Alias(), lAbre:=.T.

IF (nOpc=3 .and. AxInclui(cAlias,nReg,nOpc,,,,"AT140Valid()") = 1 ) .or.;
   (nOpc=4 .and. AxAltera(cAlias,nReg,nOpc,,,,,"AT140Valid()") = 1)

    IF EasyGParam("MV_ATUTX")
        IF SELECT("ECB") = 0
            IF !ChkFile("ECB",.F.)
                HELP("", 1, "AVG0000163")//MSGINFO(OemToAnsi(STR0036),STR0037) //"NÆo foi poss¡vel abrir o Arquivo ECB"###"Informação"
                lAbre:=.F.
            ENDIF
        ENDIF
        IF lAbre .and. (SYE->YE_VLCON_C+SYE->YE_TX_COMP) > 0
           If !ECB->(DBSEEK(xFilial("ECB")+DTOS(SYE->YE_DATA)+SYE->YE_MOEDA)) .or. ECB->ECB_TX_CTB = 0 .or. ECB->ECB_TX_EXP = 0
              ECB->(RECLOCK("ECB",ECB->(EOF())))
              ECB->ECB_FILIAL := xFilial("ECB")
              ECB->ECB_DATA   := SYE->YE_DATA
              ECB->ECB_MOEDA  := SYE->YE_MOEDA
              If ECB->ECB_TX_CTB = 0
                 ECB->ECB_TX_CTB := SYE->YE_VLCON_C
              EndIF
              If ECB->ECB_TX_EXP = 0
                 ECB->ECB_TX_EXP := SYE->YE_TX_COMP
              EndIf
              ECB->(MSUNLOCK())
              ECB->(DbCloseArea())
           EndIf
        ENDIF
    ENDIF
    dbSelectArea(cAliasOld)

ENDIF

Return nOpc

*---------------------------------------------------------------------------------------------*
Function AT140Valid()
*---------------------------------------------------------------------------------------------*
Local lRet:=.T.

If M->YE_VLCON_C = 0 .and. M->YE_TX_COMP = 0 .and. M->YE_VLFISCA = 0
   MsgInfo(STR0090) //"Cotação não pode ser salva sem nenhuma taxa. Informe pelo menos uma taxa para cotação." //HELP("", 1, "AVG0005284")
   lRet:=.F.
EndIf

Return lRet
// *********************************
FUNCTION EFFCP110()
// By - ACSJ - A. Caetano Jr. / 24/01/2005
// Cadastro de Praças
// ********************************

AxCadastro("EF5",STR0013) //"Cadastro de Praças"

Return .T.

//Objetivos : Excluir registros com confirmacao
Function EvDeleta(cAlias,nReg,nOpc)

   If MsgYesNo(STR0085)  //"Confirma a exclusão do registro?"
      RecLock(cAlias,.F.)
      (cAlias)->( DBDelete(), MSUnLock() )
   EndIf
Return .T.
/************************* Funções retiradas devido ao novo financiamento da importação ***************************

Funcao : EFFAT100()                    Objetivos : Retornar a fun‡Æo AxCadastro("SJ6","Modalidades de Pagamento")
Funcao : AC102LTC()                    Objetivos : Chamar a fun‡Æo EFFAC102() "1", opc escolhida foi Linha de Credito
Funcao : EFFAC100()                    Objetivos : Retornar a fun‡Æo AxCadastro("SY2","Locais de Entrega")
Funcao : EFFAT150()                    Objetivos : "Feriados"
Funcao : EFFAT150Manut(cAlias,nReg,nOpc)
*******************************************************************************************************************/



//*************************************************************************************/
//* Funcao: EFFFI100  *      Autor:   Pedro Baroni         *        Data:  09/02/06   */
//*************************************************************************************/
//*Descricao: 1 - Cadastro de Financiamentos / Encargos - Cadastro para encargos por  */
//*           tipo de financiamento, assim sempre que for incluído um novo contrato de*/
//*           financiamento todos os encargos pertinentes a um tipo de financiamento  */
//*           serão inicializados.                                                    */
//************************//***********************************************************/
Function EFFFI100()
//************************//***********************************************************/
   EFFFI400("FIN")
Return .T.


//*************************************************************************************/
//* Funcao: EFFRO100  *      Autor:   Pedro Baroni         *        Data:  09/02/06   */
//*************************************************************************************/
//*           2 - Cadastro de ROF / Encargos - Cadastro das Operacoes Financeiras de  */
//*           cada Tipo de Financiamento com respectivos Encargos.                    */
//************************//***********************************************************/
Function EFFRO100()
//************************//***********************************************************/
   Private cFiltroF3Rof //Necessário declarar para o F3 do ROF.

   EFFFI400("ROF")

Return .T.

//*************************************************************************************/
Function EFFLC100()
//*************************************************************************************/
   EFFFI400("LNC")
Return .T.


//*************************************************************************************/
Function EFFFI400(cCad)
//*************************************************************************************/
	PRIVATE cCadastro := ""
	Private aHeader := {}
	Private aCols   := {}
    Private lWhen   := .T.
    Private aRotina := {}
    Private cSeek, bWhile
   oMainWnd:ReadClientCoords()

   // Verifica qual o Cadastro e Cria Variaveis e CodeBlocks
   // BAK - Tratamento para integrado com o financeiro ou o logix
   If cCad == "FIN" //.And. (AvFlags("SIGAEFF_SIGAFIN") .Or. AvFlags("EEC_LOGIX")  ) //FSY - 18/07/2013 - Nopado, pois não essas validações. Causando erro log caso o usuario tivesse os dois parametros desabilitado.
      cCadastro := STR0091  //"Tipos de Financiamento"
      cAlias := "EF7"
      cTipAl := "F"
      cChav1 := {|| xFilial("EF8")+"F"+AVKey(M->EF7_FINANC,"EF8_CHAVE")}
      cChav2 := {|| xFilial("EC6")+cTipFin+M->EF7_FINANC+&cNameField+"1000"}
      cChav3 := {|| xFilial("EC6")+cTipFin+M->EF7_FINANC+&cNameField+"    "}
      cChav4 := {|| xFilial("EC6")+cTipFin+M->EF7_FINANC+aCols[i][GDFieldPos("EF8_CODEVE")]+"1000"}
      cChav5 := {|| xFilial("EC6")+cTipFin+M->EF7_FINANC+aCols[i][GDFieldPos("EF8_CODEVE")]+"    "}
      cChav6 := {|| xFilial("EC6")+cTipFin+M->EF7_FINANC+aCols[i][GDFieldPos("EF8_CODEAS")]+"1000"}
      cChav7 := {|| xFilial("EC6")+cTipFin+M->EF7_FINANC+aCols[i][GDFieldPos("EF8_CODEAS")]+"    "}
      cChav8 := {|| xFilial("EC6")+cTipFin+M->EF7_FINANC+aCols[i][GDFieldPos("EF8_CODEBA")]+"1000"}
      cChav9 := {|| xFilial("EC6")+cTipFin+M->EF7_FINANC+aCols[i][GDFieldPos("EF8_CODEBA")]+"    "}
      //cChav10:= {|| M->EF7_FILIAL+"F"+AVKey(M->EF7_FINANC,"EF8_CHAVE")+aCols[i][GDFieldPos("EF8_CODEVE")]}
      cComp1 := {|| EF8->EF8_FILIAL == xFilial("EF8")}
      cComp2 := {|| EF8->EF8_CHAVE == AVKey(M->EF7_FINANC,"EF8_CHAVE")}
      cComp3 := {|| M->EF7_TP_FIN=="I"}
      cComp4 := {|| AVKey(EF7->EF7_FINANC,"EF8_CHAVE") == EF8->EF8_CHAVE}
      cComp5 := {|| M->EF7_TP_FIN=="E"}
      cComp6 := {|| EF8->EF8_TP_REL=="F"}
      cGrav1 := {|| EF7->&(FieldName(i)):= M->&(EF7->(FieldName(i)))}
      cGrav2 := {|| EF7->EF7_FILIAL := xFilial("EF7") }  // PLB 20/12/06
   ElseIf cCad == "ROF"
      cCadastro := STR0092  //"ROF - Registros de Operação Financeira"
      cAlias := "EF9"
      cTipAl := "R"
      cChav1 := {|| xFilial("EF8")+"R"+AVKey(M->EF9_ROF,"EF8_CHAVE")}
      cChav2 := {|| xFilial("EC6")+cTipFin+M->EF9_FINANC+&cNameField+"1000"}
      cChav3 := {|| xFilial("EC6")+cTipFin+M->EF9_FINANC+&cNameField+"    "}
      cChav4 := {|| xFilial("EC6")+cTipFin+M->EF9_FINANC+aCols[i][GDFieldPos("EF8_CODEVE")]+"1000"}
      cChav5 := {|| xFilial("EC6")+cTipFin+M->EF9_FINANC+aCols[i][GDFieldPos("EF8_CODEVE")]+"    "}
      cChav6 := {|| xFilial("EC6")+cTipFin+M->EF9_FINANC+aCols[i][GDFieldPos("EF8_CODEAS")]+"1000"}
      cChav7 := {|| xFilial("EC6")+cTipFin+M->EF9_FINANC+aCols[i][GDFieldPos("EF8_CODEAS")]+"    "}
      cChav8 := {|| xFilial("EC6")+cTipFin+M->EF9_FINANC+aCols[i][GDFieldPos("EF8_CODEBA")]+"1000"}
      cChav9 := {|| xFilial("EC6")+cTipFin+M->EF9_FINANC+aCols[i][GDFieldPos("EF8_CODEBA")]+"    "}
      //cChav10:= {|| M->EF9_FILIAL+"R"+AVKey(M->EF9_ROF,"EF8_CHAVE")+aCols[i][GDFieldPos("EF8_CODEVE")]}
      cComp1 := {|| xFilial("EF9") == EF8->EF8_FILIAL}
      cComp2 := {|| AVKey(M->EF9_ROF,"EF8_CHAVE") == EF8->EF8_CHAVE}
      cComp3 := {|| M->EF9_TP_ROF=="I"}
      cComp4 := {|| EF8->EF8_CHAVE == AVKey(EF9->EF9_ROF,"EF8_CHAVE")}
      cComp5 := {|| M->EF9_TP_ROF=="E"}
      cComp6 := {|| EF8->EF8_TP_REL=="R"}
      cGrav1 := {|| EF9->&(FieldName(i)):= M->&(EF9->(FieldName(i)))}
      cGrav2 := {|| EF9->EF9_FILIAL := xFilial("EF9") }  // PLB 20/12/06
   ElseIf cCad == "LNC"
      cCadastro := STR0093  //"Linhas de Crédito"
      cAlias := "EFA"
      cTipAl := "L"
      cChav1 := {|| xFilial("EF8")+"L"+AVKey(M->EFA_LINCRE,"EF8_CHAVE")}
      cChav2 := {|| xFilial("EC6")+cTipFin+M->EFA_TP_FIN+&cNameField+"1000"}
      cChav3 := {|| xFilial("EC6")+cTipFin+M->EFA_TP_FIN+&cNameField+"    "}
      cChav4 := {|| xFilial("EC6")+cTipFin+M->EFA_TP_FIN+aCols[i][GDFieldPos("EF8_CODEVE")]+"1000"}
      cChav5 := {|| xFilial("EC6")+cTipFin+M->EFA_TP_FIN+aCols[i][GDFieldPos("EF8_CODEVE")]+"    "}
      cChav6 := {|| xFilial("EC6")+cTipFin+M->EFA_TP_FIN+aCols[i][GDFieldPos("EF8_CODEAS")]+"1000"}
      cChav7 := {|| xFilial("EC6")+cTipFin+M->EFA_TP_FIN+aCols[i][GDFieldPos("EF8_CODEAS")]+"    "}
      cChav8 := {|| xFilial("EC6")+cTipFin+M->EFA_TP_FIN+aCols[i][GDFieldPos("EF8_CODEBA")]+"1000"}
      cChav9 := {|| xFilial("EC6")+cTipFin+M->EFA_TP_FIN+aCols[i][GDFieldPos("EF8_CODEBA")]+"    "}
      //cChav10:= {|| M->EFA_FILIAL+"L"+AVKey(M->EFA_LINCRE,"EF8_CHAVE")+aCols[i][GDFieldPos("EF8_CODEVE")]}
      cComp1 := {|| xFilial("EF8") == EF8->EF8_FILIAL}
      cComp2 := {|| AVKey(M->EFA_LINCRE,"EF8_CHAVE") == EF8->EF8_CHAVE}
      cComp3 := {|| .T.}
      cComp4 := {|| EF8->EF8_CHAVE == AVKey(EFA->EFA_LINCRE,"EF8_CHAVE")}
      cComp5 := {|| .F.}
      cComp6 := {|| EF8->EF8_TP_REL=="L"}
      cGrav1 := {|| EFA->&(FieldName(i)):= M->&(EFA->(FieldName(i)))}
      cGrav2 := {|| EFA->EFA_FILIAL := xFilial("EFA") }  // PLB 20/12/06
   EndIf

   aRotina := MenuDef(ProcName(1))

   // Verifica se o cadastro de Tipo de Financiamento está vazio
   //If cCad=="FIN" .And. EF7->( BOF() ) .And. EF7->( EOF() )
   If cCad == "FIN"
      If EF7->( !DBSeek(xFilial("EF7")) )  // PLB 20/12/06
         FI400Ini() // Inicializa o cadastro EF7
      Else
         If EF7->(FieldPos('EF7_FINPRC')) > 0     //NCF - 10/10/2014
            FI400Ini(.F.)
         EndIf
      EndIf
   EndIf
   (cAlias)->( DbSetOrder(1) )
   DbSelectArea(cAlias)
   MBrowse(0,0,455,325,cAlias)
Return .T.



//***********************//************************************************************/
Function FI400Ini(lAtu)      //   Inicializa o cadastro EF7 com registros pré-definidos   */
//***********************//************************************************************/

 Local i, j
 Local cFilEF7 := xFilial("EF7")
 Local aOrdEF7 := SaveOrd("EF7")
 Local aIniEF7 := { {cFilEF7, "01", STR0014, "E"},; // "ACC"
                    {cFilEF7, "02", STR0015, "E"},; // "ACE"
                    {cFilEF7, "03", STR0016, "E"},; // "Pré-Pagamento"
                    {cFilEF7, "04", STR0017, "E"},; // "Securitização"
                    {cFilEF7, "05", STR0018, "I"} } // "FINIMP"
Local oUpdCAD00

Default lAtu := .T.
Private aUpdSX5 := {}

   EF7->(DbSetORder(1))
   For i := 1  to  Len(aIniEF7)
      If lAtu
         EF7->(RecLock("EF7",.T.))
         For j := 1  to  Len(aIniEF7[i])
            EF7->&( FieldName(j) ) := aIniEF7[i][j]
         Next j
         If EF7->(FieldPos("EF7_FINPRC")) > 0          //NCF - 02/10/2014
            If EF7->EF7_FINANC $ '01|02'
               EF7->EF7_FINPRC := '2'
            Else
               EF7->EF7_FINPRC := '1'
            EndIf
         EndIf
         EF7->( MsUnlock() )

         //THTS - 20/07/2017 - Monta array para enviar todas as alteracoes pelo avupdate
         aAdd(aUpdSX5,{xFilial("SX5"),"CJ",IIF(EF7->EF7_TP_FIN=="I","FIIM","FIEX")+EF7->EF7_FINANC,EF7->EF7_DESCRI})

         //**
      Else //Atualiza cadastro existente
         If EF7->(DbSeek( aIniEF7[i][1]+aIniEF7[i][2] ))
            If EF7->(FieldPos('EF7_FINPRC')) > 0
                EF7->(RecLock("EF7",.F.))
                If aIniEF7[i][2] $ '01/02'//THTS - 04/02/2019 - Se tipo 01 e 02, não permite parcelamento; Caso contrario, tipos 03, 04 e 05 permitem parcelamento;
                  EF7->EF7_FINPRC := '2' 
                Else
                  EF7->EF7_FINPRC := '1'
                EndIf
                EF7->(MsUnlock())
            EndIf
         EndIf
         If Len(aOrdEF7) > 0
            RestOrd(aOrdEF7)
         EndIf
      EndIf
   Next i

If FindFunction("AvUpdate01") .And. Len(aUpdSX5) > 0
   oUpdCAD00 := AvUpdate01():New()
   oUpdCAD00:aChamados := {{nModulo,{|o| UPDX5CAD00(o)}}}
   oUpdCAD00:Init(,.T.)
EndIf

Return .T.



//****************************************//*******************************************/
Function FI400Mstr(A_alias,A_rec,A_tipo)  //   Monta e exibe Capa e Detalhe (EF8)     */
//****************************************//*******************************************/
	Local   oObj
	Local   aPos
	Local   i
   Local   lRet         := .T.
   Private lWhen2       := .T.
	Private oDlg
   Private aButtons     := {}
	Private nVolta
   Private aALTERA      := {}
	Private aTela[0][0]
	Private aGets[0]
   Private cLocal       := ""
   Private cFiltroF3Fin := ""  // Variavel utilizada no F3 do Tipo do Financiamento
   Private lEvCont      := .F. // Variavel utilizada no F3 do Tipo do Financiamento
   Private nOpcGD
   Private cTipFin := "" // Variavel utilizada para verificar TIPO DO MODULO
   Private CNameField := ""

   Begin Sequence

      aYesFields:=    {  "EF8_CODEVE" ,;     //LRS 09/09/2014 - Criando a aray e chamado o AvFlags antes da construção da tela
                         "EF8_DESEVE" ,;
                         "EF8_CODEAS" ,;
                         "EF8_DESEAS" ,;
                         "EF8_CODEBA" ,;
                         "EF8_DESEBA" ,;
                         "EF8_TIP_EV" ,;
                         "EF8_VL_PCT" ,;
                         "EF8_PCT_RJ" ,;
                         "EF8_LIQ"    ,;
                         "EF8_CARGA"  ,;
                         "EF8_TAXA"   ,;
                         "EF8_VL_RS"   }

   If AvFlags("SIGAEFF_SIGAFIN") .OR. EasyGParam("MV_EECI010",,.F.)
         aAdd(aYesFields,"EF8_FORN")
         aAdd(aYesFields,"EF8_LOJA")

         aAdd(aAltera,"EF8_FORN")
         aAdd(aAltera,"EF8_LOJA")
   EndIf


	aPos := {}
   	nVolta := 0

      // Verifica se é Visualização, Alteraçao ou Exclusao de ROF
      If cTipAl == "R" .And. (A_Tipo == 4 .Or. A_Tipo == 5) .And. !FI400AltROF(A_Tipo) //Valida Alt./Exc.
         lRet := .F.
         Break
      EndIf

      // Verifica se é Exclusao de Financiamento
      If cTipAl == "F"  .And. A_Tipo == 5
         If !FI400ExcFIN() //Valida Exc.
            lRet := .F.
            Break
         EndIf
      EndIf

      // Valida Exclusao de Linha de Credito
      EF1->( DBSetOrder(7) )
      If cTipAl == "L" .and. A_Tipo == 5 .and.  EF1->( DBSeek( xFilial("EF1")+EFA->EFA_LINCRE ) )
         MsgInfo(STR0058) // "Esta Linha de Crédito possui Contratos vinculados e não pode ser excluída."
         lRet := .F.
         Break
      EndIf


      // AAF 22/03/2010 - Botoes removidos, pois a GetDados ja permite edicao em enchoice.
      If  A_Tipo == 2  .Or.  A_Tipo == 5
         //aAdd(aButtons,{"BMPVISUAL" /*"ANALITICO"*/,{|| FI400Eve("VIS") },STR0003}) //"Visualizar"
      Else
         //aAdd(aButtons,{"BMPINCLUIR" /*"EDIT"*/,     {|| FI400Eve("INC") },STR0004}) //"Incluir"
         //aAdd(aButtons,{"EDIT" /*"ALT_CAD"*/,  {|| FI400Eve("ALT") },STR0005}) //"Alterar"
         //aAdd(aButtons,{"EXCLUIR",  {|| FI400Eve("EXC") },STR0006}) //"Excluir"
      EndIf

      If  A_Tipo == 4  .Or.  A_Tipo == 5
         &(cAlias)->( RecLock(cAlias,.F.) )
      EndIf

      IF A_Tipo!=3 // Não permite alteração de código
         lWhen:=.F.
         If cTipAl == "L"
            aAdd(aButtons,{"PROJETPMS",{|| LC100Contr()},STR0065, STR0089}) //"Contratos Vinculados" , "Contr.Vinc."
         EndIf
      EndIf

      // Verifica se é inclusão ou alteraçao para permitir alterar campos da MSGetDados
      If	A_tipo == 3 .Or. A_tipo == 4
         aALTERA := {"EF8_CODEVE","EF8_CODEAS","EF8_CODEBA","EF8_TIP_EV","EF8_VL_PCT","EF8_TAXA","EF8_VL_RS","EF8_PCT_RJ","EF8_LIQ","EF8_CARGA"}
      EndIf

	   For i := 1 to &(cAlias)->(FCount())
		   If A_tipo == 3
   			M->&(&(cAlias)->(FieldName(i))):= CriaVar(&(cAlias)->(FieldName(i)))
	   	Else
		   	M->&(&(cAlias)->(FieldName(i))):= &(cAlias)->(FieldGet(i))
   		Endif
	   Next

      If cTipAl == "F"
         //DEFINE MSDIALOG oDlg TITLE STR0019 FROM oMainWnd:nTop + 130, oMainWnd:nLeft + 1 TO oMainWnd:nHeight-150, oMainWnd:nWidth-40 OF oMainWnd PIXEL //"Tipos de Financiamento"
         DEFINE MSDIALOG oDlg TITLE STR0019 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Tipos de Financiamento"
         aPos := PosDlgUp(oDlg)//{,,65,(oDlg:nClientWidth-4)/2}
      ElseIf cTipAl == "R"
         If A_Tipo != 3
            M->EF9_VM_OBS := MSMM(EF9->EF9_OBS,AVSX3("EF9_VM_OBS",AV_TAMANHO),,,LERMEMO)
         Else
            cFiltroF3Fin := M->EF9_TP_ROF
         EndIf
         // Preenche Descricao do Financiamento antes de exibir
         EF7->( DBSetOrder(1) )
         EF7->( DBSeek(xFilial("EF7")+M->EF9_FINANC) )
         M->EF9_DESCRI := EF7->EF7_DESCRI

         DEFINE MSDIALOG oDlg TITLE STR0075 FROM oMainWnd:nTop + 100, oMainWnd:nLeft + 1 TO oMainWnd:nHeight-100, oMainWnd:nWidth-40 OF oMainWnd PIXEL  //"Registros de Operações Financeiras"
         aPos := {,,110,(oDlg:nClientWidth-4)/2}
      ElseIf cTipAl == "L"
         // Variavel para validar alteracao de Valor da Linha de Credito em LC100Val()
         If cTipAl == "L"
            nValorLin := M->EFA_VL_PRI
         EndIf

         // Inicializa campos virtuais
         If A_Tipo!=3
            M->EFA_DESCFI := LC100IniVirt("EFA_DESCFI")
            M->EFA_DESCIF := LC100IniVirt("EFA_DESCIF")
            M->EFA_DESCCC := LC100IniVirt("EFA_DESCCC")
            M->EFA_DESCRE := LC100IniVirt("EFA_DESCRE")
            M->EFA_ENDCRE := LC100IniVirt("EFA_ENDCRE")
            M->EFA_PAISCR := LC100IniVirt("EFA_PAISCR")
            M->EFA_DESPCR := LC100IniVirt("EFA_DESPCR")
            M->EFA_VM_OBS := LC100IniVirt("EFA_VM_OBS")
         EndIf

         cFiltroF3Fin := "I"

/*         // CodeBlock para zerar datas do evento
         bIniData := {|| GDFieldPut("EFB_DT_EVE",CtoD("  /  /  "),Len(aCols) ) ,;
                         GDFieldPut("EFB_DT_EST",CtoD("  /  /  "),Len(aCols) ) }

         // Code Block para copiar Banco/Agencia/Conta para os eventos
         bIniBanc := {|| IIF((!Empty(M->EFA_BANC) .And. !Empty(M->EFA_AGEN) .And.;
                         !Empty(M->EFA_NCON)), (GDFieldPut("EFB_BANC",M->EFA_BANC,Len(aCols)),;
                         GDFieldPut("EFB_AGEN",M->EFA_AGEN,Len(aCols)),;
                         GDFieldPut("EFB_NCON",M->EFA_NCON,Len(aCols))), ) }
*/



         DEFINE MSDIALOG oDlg TITLE STR0076 FROM oMainWnd:nTop + 100, oMainWnd:nLeft + 1 TO oMainWnd:nHeight-100, oMainWnd:nWidth-40 OF oMainWnd PIXEL // "Linha de Crédito"
         aPos := {,,150,(oDlg:nClientWidth-4)/2}
      EndIf

	   DBSelectArea(cAlias)
   	oEnch := MsMGet():New(cAlias,A_rec,A_tipo,nil,nil,nil,nil,aPos)
      oEnch:oBox:Align := CONTROL_ALIGN_TOP

      cLocal := "MSGETDADOS"

      If Eval(cComp3)
         cTipFin := "FIIM"
      Else
         cTipFin := "FIEX"
      EndIf

      cSeek:= EVAL(cChav1)
      cWhile:= "EF8->( EF8_FILIAL+EF8_TP_REL+EF8_CHAVE)"
      nOpcGD:= A_tipo
      FillGetDados(nOpcGD, "EF8", 1, cSeek,{||&cWhile}, {||.T.}, /*aNoFields*/, aYesFields,,,,,,,{|aCols| AddAcols(aCols), If(nOpcGD <> 3, FI400Gat(cLocal, .T.),) })

   	//FI400Cri(A_Tipo) // Inicializa arrays do MSGetDados

      oGetMS:= MsGetDados():New(66,1,150,(oDlg:nClientWidth-4)/2, 4,"FI400LinOK",;
               NIL , NIL, .T. , aAltera, NIL , NIL , 1500 ,"FI400CpoOK")
      oGetMS:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

      /*If cTipAl == "L"
         // Busca as Validacoes dos Campos no Dicionario SX3 e estancia ao Objeto
         For i := 1  to  Len(aHeader)
            oGetMS:aInfo[i][6] := Posicione("SX3",2,aHeader[i][2],"X3_VALID")
         Next i

         If A_Tipo == 4  .And.  Len(aCols) == 1  .And.  Empty(aCols[1][GDFieldPos("EFB_CODEVE")])
            Eval(bIniData)
            Eval(bIniBanc)
         EndIf
      EndIf*/

      // Verifica se é Inclusao ou Alteracao para permitir inclusa de linha na MSGetDados
      If A_Tipo==3 .Or. A_Tipo==4
         oGetMS:oBROWSE:bADD:={ || oGetMS:LCHGFIELD := .F., oGetMS:ADDLINE(), AAdd(aCols[Len(aCols)],NIL), aIns(aCols[Len(aCols)],Len(aHeader)+1), aCols[Len(aCols)][Len(aHeader)+1]:=0,aCols[Len(aCols)][Len(aHeader)+2]:=.F.}
      Else
         oGetMS:oBROWSE:bADD:={ || oGetMS:LCHGFIELD := .F.}
      EndIf

      oGetMS:oBrowse:bDelete:= {|| FI400DelOK()}

   	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela),FI400TudOK(),nVolta := 0)},{||oDlg:End()},,aButtons)

      If  A_Tipo == 4  .Or.  A_Tipo == 5
         &(cAlias)->( MSUnLock() )
      EndIf

	   If nVolta==1
		   FI400Grv(A_Tipo)  // Gravacao do Cadastro (EF7, EF9 ou EFA) e dos Eventos (EF8)
   	EndIf
      aHeader := {}
      aCols   := {}
      lWhen   := .T.

   End Sequence

Return lRet

//****************************//*******************************************************/
Function FI400Cri(A_Tipo)     // Inicializa os arrays aHeader e aCols para MSGetDados */
//****************************//*******************************************************/
//Local	i
 Private cTipFin := "" // Variavel utilizada para verificar TIPO DO MODULO
 Private CNameField := ""

  aHeader := {}
  aCols   := {}

   // Usada para Gatilhos distinguir MSGETDADOS da ENCHOICE
   cLocal := "MSGETDADOS"

   If Eval(cComp3)
      cTipFin := "FIIM"
   Else
      cTipFin := "FIEX"
   EndIf

   //AAdd(aHeader, { STR0020, "EF8_CODEVE", AVSX3("EF8_CODEVE", 06), AVSX3("EF8_CODEVE", 03) , 0                      , "" , NIL , AVSX3("EF8_CODEVE", 02) , NIL , NIL} ) // "Código do Evento"
   //AAdd(aHeader, { STR0021, "EF8_DESEVE", AVSX3("EF8_DESEVE", 06), AVSX3("EF8_DESEVE", 03) , 0                      , "" , NIL , AVSX3("EF8_DESEVE", 02) , NIL , NIL} ) // "Descrição do Evento"
   //AAdd(aHeader, { STR0022, "EF8_CODEAS", AVSX3("EF8_CODEAS", 06), AVSX3("EF8_CODEAS", 03) , 0                      , "" , NIL , AVSX3("EF8_CODEAS", 02) , NIL , NIL} ) // "Cód. Evento Associado"
   //AAdd(aHeader, { STR0023, "EF8_DESEAS", AVSX3("EF8_DESEAS", 06), AVSX3("EF8_DESEAS", 03) , 0                      , "" , NIL , AVSX3("EF8_DESEAS", 02) , NIL , NIL} ) // "Descr. Evento Associado"
   //AAdd(aHeader, { STR0024, "EF8_CODEBA", AVSX3("EF8_CODEBA", 06), AVSX3("EF8_CODEBA", 03) , 0                      , "" , NIL , AVSX3("EF8_CODEBA", 02) , NIL , NIL} ) // "Cód. Evento Base"
   //AAdd(aHeader, { STR0025, "EF8_DESEBA", AVSX3("EF8_DESEBA", 06), AVSX3("EF8_DESEBA", 03) , 0                      , "" , NIL , AVSX3("EF8_DESEBA", 02) , NIL , NIL} ) // "Descr. Evento Base"
   //AAdd(aHeader, { STR0026, "EF8_TIP_EV", AVSX3("EF8_TIP_EV", 06), AVSX3("EF8_TIP_EV", 03) , 0                      , "" , NIL , AVSX3("EF8_TIP_EV", 02) , NIL , NIL} ) // "Tipo"
   //AAdd(aHeader, { STR0027, "EF8_VL_PCT", AVSX3("EF8_VL_PCT", 06), AVSX3("EF8_VL_PCT", 03) , AVSX3("EF8_VL_PCT", 04), "" , NIL , AVSX3("EF8_VL_PCT", 02) , NIL , NIL} ) // "Valor/Percent."
   //AAdd(aHeader, { STR0028, "EF8_PCT_RJ", AVSX3("EF8_PCT_RJ", 06), AVSX3("EF8_PCT_RJ", 03) , 0                      , "" , NIL , AVSX3("EF8_PCT_RJ", 02) , NIL , NIL} ) // "Percentual Reaujstado"
   //AAdd(aHeader, { AVSX3("EF8_LIQ", 05) , "EF8_LIQ", AVSX3("EF8_LIQ", 06), AVSX3("EF8_LIQ", 03) , 0                 , "" , NIL , AVSX3("EF8_LIQ"   , 02) , NIL , NIL} ) // "Liquida Aut."
   //AAdd(aHeader, { STR0077, "EF8_CARGA" , AVSX3("EF8_CARGA", 06) , AVSX3("EF8_CARGA", 03)  , 0                      , "" , NIL , AVSX3("EF8_CARGA" , 02) , NIL , NIL} ) // "Carrega para o Contrato?"
   //AAdd(aHeader, { AVSX3("EF8_TAXA", 05), "EF8_TAXA", AVSX3("EF8_TAXA", 06), AVSX3("EF8_TAXA", 03) , 0              , "" , NIL , AVSX3("EF8_TAXA"  , 02) , NIL , NIL} )
   //AAdd(aHeader, { AVSX3("EF8_VL_RS", 05), "EF8_VL_RS", AVSX3("EF8_VL_RS", 06), AVSX3("EF8_VL_RS", 03) , 0          , "" , NIL , AVSX3("EF8_VL_RS" , 02) , NIL , NIL} )

   // Verifica se é diferente de inclusão
   /*EF8->(DBSetOrder(1))
   If A_Tipo!=3  .And.  EF8->( DBSeek( Eval(cChav1) ) )

      Do While !EF8->(EOF()) .AND. Eval(cComp1) .AND. Eval(cComp2) .And. Eval(cComp6)

          Preenche aCols com os Dados de EF8
         AAdd( aCols, Array( Len(aHeader)+2 ) )

         cNameField := "EF8->EF8_CODEVE"
         aCols[Len(aCols)][GDFieldPos("EF8_CODEVE")] := &cNameField
         FI400Gat(cLocal) // Gatilhos para descrição
         aCols[Len(aCols)][GDFieldPos("EF8_DESEVE")] := EC6->EC6_DESC

         cNameField := "EF8->EF8_CODEAS"
         aCols[Len(aCols)][GDFieldPos("EF8_CODEAS")] := &cNameField
         FI400Gat(cLocal)
         aCols[Len(aCols)][GDFieldPos("EF8_DESEAS")] := EC6->EC6_DESC

         cNameField := "EF8->EF8_CODEBA"
         aCols[Len(aCols)][GDFieldPos("EF8_CODEBA")] := &cNameField
         FI400Gat(cLocal)
         aCols[Len(aCols)][GDFieldPos("EF8_DESEBA")] := EC6->EC6_DESC

         aCols[Len(aCols)][GDFieldPos("EF8_TIP_EV")] := EF8->EF8_TIP_EV
         aCols[Len(aCols)][GDFieldPos("EF8_VL_PCT")] := EF8->EF8_VL_PCT
         aCols[Len(aCols)][GDFieldPos("EF8_TAXA")]   := EF8->EF8_TAXA
         aCols[Len(aCols)][GDFieldPos("EF8_VL_RS")]  := EF8->EF8_VL_RS
         aCols[Len(aCols)][GDFieldPos("EF8_PCT_RJ")] := EF8->EF8_PCT_RJ
         aCols[Len(aCols)][GDFieldPos("EF8_LIQ"   )] := EF8->EF8_LIQ
         aCols[Len(aCols)][GDFieldPos("EF8_CARGA" )] := EF8->EF8_CARGA

         aCols[Len(aCols)][Len(aHeader)+1] := EF8->( RecNo() )
         aCols[Len(aCols)][Len(aHeader)+2] := .F. //Marca como não deletado
	   	EF8->(DBSkip())
      EndDo
   Else
      //Cria campos em branco
      AAdd( aCols, Array( Len(aHeader)+2 ) )
      For i := 1 to Len(aHeader)
         aCols[Len(aCols)][i] := CriaVar( aHeader[i][2] )
      Next
      aCols[Len(aCols)][Len(aHeader)+1] := 0
      aCols[Len(aCols)][Len(aHeader)+2] := .F.
   EndIf*/

   cLocal := ""

Return .T.



//****************************************//*******************************************/
Function FI400Gat(cLocal, lAll)           //    Gatilhos para descrição de eventos    */
//****************************************//*******************************************/
Default lAll := .F.
   EC6->( DBSetOrder(1) )

   If !lAll
      // Verifica se o Centro de Custo é branco ou 1000
      If !EC6->( DBSeek( Eval(cChav2) ) )
         EC6->( DBSeek( Eval(cChav3) ) )
      EndIf
   Else
      n := Len(aCols)
   EndIf

   // Verifica qual é o campo e preenche a respectiva descrição
   If lAll .Or. cNameField == "M->EF8_CODEVE"
      cNameField := "M->EF8_CODEVE"
      If lAll
         cNameField := "EF8->EF8_CODEVE"
         // Verifica se o Centro de Custo é branco ou 1000
         If !EC6->( DBSeek( Eval(cChav2) ) )
            EC6->( DBSeek( Eval(cChav3) ) )
         EndIf
      EndIf
      If !Empty(&cNameField)
         IIF(cLocal=="ENCHOICE",M->EF8_DESEVE, aCols[n][GDFieldPos("EF8_DESEVE")] ) := EC6->EC6_DESC
      Else
         IIF(cLocal=="ENCHOICE",M->EF8_DESEVE, aCols[n][GDFieldPos("EF8_DESEVE")] ) := ""
      EndIf
   EndIf
   If lAll .Or. cNameField == "M->EF8_CODEAS"
      cNameField := "M->EF8_CODEAS"
      If lAll
         cNameField := "EF8->EF8_CODEAS"
         // Verifica se o Centro de Custo é branco ou 1000
         If !EC6->( DBSeek( Eval(cChav2) ) )
            EC6->( DBSeek( Eval(cChav3) ) )
         EndIf
      EndIf
      If !Empty(&cNameField)
         IIF(cLocal=="ENCHOICE",M->EF8_DESEAS, aCols[n][GDFieldPos("EF8_DESEAS")] ) := EC6->EC6_DESC
      Else
         IIF(cLocal=="ENCHOICE",M->EF8_DESEAS, aCols[n][GDFieldPos("EF8_DESEAS")] ) := ""
      EndIf
   EndIf
   If lAll .Or. cNameField == "M->EF8_CODEBA"
      cNameField := "M->EF8_CODEBA"
      If lAll
         cNameField := "EF8->EF8_CODEBA"
         // Verifica se o Centro de Custo é branco ou 1000
         If !EC6->( DBSeek( Eval(cChav2) ) )
            EC6->( DBSeek( Eval(cChav3) ) )
         EndIf
      EndIf
      If !Empty(&cNameField)
         IIF(cLocal=="ENCHOICE",M->EF8_DESEBA, aCols[n][GDFieldPos("EF8_DESEBA")] ) := EC6->EC6_DESC
      Else
         IIF(cLocal=="ENCHOICE",M->EF8_DESEBA, aCols[n][GDFieldPos("EF8_DESEBA")] ) := ""
      EndIf
   EndIf

Return .T.



//**********************************//*************************************************/
Function FI400Grv(A_Tipo)           //   Gravaçao ou Exclusao dos registros e itens   */
//**********************************//*************************************************/
   Local i//, j
	Local lTip
  Local oUpdCAD00
	//Local laColsOK := .T.

   // Verifica se há algum item em aCols
   /*
   If Len(aCols) == 1  .And.  Empty(aCols[1][1])  .And.  Empty(aCols[1][3])  .And. Empty(aCols[1][5])
      laColsOK := .F.
   EndIf
   */

   IIF( A_Tipo==3 , lTip:=.T. , lTip:=.F. )

   //Altera ou inclui os dados digitados na tabela EF7
	If A_Tipo==3 .OR. A_Tipo==4
		(cAlias)->(RecLock(cAlias,lTip))
		For i := 1 to (cAlias)->(FCount())
		   Eval(cGrav1)
		Next
      Eval(cGrav2)  // PLB 20/12/06
      (cAlias)->(MSUnlock())

      //** PLB 05/10/06 - Inclui/Altera Tipo de Módulo para Tabela de Eventos Contábeis
      If cTipAl == "F"
        //THTS - 20/07/2017
         If FindFunction("AvUpdate01")
            oUpdCAD00 := AvUpdate01():New()
            oUpdCAD00:aChamados := {{nModulo,{|o| UPDX5CAD00(o)}}}
            oUpdCAD00:Init(,.T.)
         EndIf

      EndIf
      //**

      If cTipAl == "R"
         If A_Tipo == 4
            MSMM(M->EF9_OBS,,,,EXCMEMO)
         EndIf
         MSMM(,AVSX3("EF9_VM_OBS",AV_TAMANHO),,M->EF9_VM_OBS,INCMEMO,,,"EF9","EF9_OBS")
      EndIf

      If cTipAl == "L"
         If A_Tipo == 4
            MSMM(M->EFA_OBS,,,,EXCMEMO)
         EndIf
         MSMM(,AVSX3("EFA_VM_OBS",AV_TAMANHO),,M->EFA_VM_OBS,INCMEMO,,,"EFA","EFA_OBS")
      EndIf

      // Verifica se há algum item em aCols e Altera ,Inclui ou Exclui os dados em EF8
      //If laColsOK
         EF8->( DBSetOrder(1) )

         // Apaga Deletados
         For i := 1 to Len(aCols)
            If aCols[i][Len(aCols[i])] //.And. EF8->( DBSeek( Eval(cChav10) ) )
               If aCols[i][Len(aHeader)+1] != 0
                  EF8->( DBGoTo(aCols[i][Len(aHeader)+1]) )
                  RecLock("EF8",.F.)
                  EF8->( DBDelete(), MSUnLock() )
               EndIf
            EndIf
         Next i

         // Altera/Inclui Eventos
         For i:= 1 to Len(aCols)
            If !aCols[i][Len(aCols[i])]
               If aCols[i][Len(aHeader)+1] != 0  // RecNo            //EF8->( DBSeek( Eval(cChav10) ) )
                  EF8->( DBGoTo(aCols[i][Len(aHeader)+1]) )
                  RecLock("EF8",.F.)
               Else
                  RecLock("EF8",.T.)
               Endif


               EF8->EF8_FILIAL := xFilial("EF8")
               EF8->EF8_CHAVE  := IIF(cTipAl=="F",M->EF7_FINANC,If(cTipAl=="R",M->EF9_ROF,M->EFA_LINCRE))
               EF8->EF8_CODEVE := aCols[i][GDFieldPos("EF8_CODEVE")]
               EF8->EF8_CODEAS := aCols[i][GDFieldPos("EF8_CODEAS")]
               EF8->EF8_CODEBA := aCols[i][GDFieldPos("EF8_CODEBA")]
               EF8->EF8_TIP_EV := aCols[i][GDFieldPos("EF8_TIP_EV")]
               EF8->EF8_VL_PCT := aCols[i][GDFieldPos("EF8_VL_PCT")]
               EF8->EF8_TAXA   := aCols[i][GDFieldPos("EF8_TAXA")]
               EF8->EF8_VL_RS  := aCols[i][GDFieldPos("EF8_VL_RS")]
               EF8->EF8_PCT_RJ := aCols[i][GDFieldPos("EF8_PCT_RJ")]
               EF8->EF8_LIQ    := aCols[i][GDFieldPos("EF8_LIQ")]
               EF8->EF8_CARGA  := aCols[i][GDFieldPos("EF8_CARGA")]
               EF8->EF8_TP_REL := cTipAl

               If AvFlags("SIGAEFF_SIGAFIN") .OR. EasyGParam("MV_EECI010",,.F.)
                  EF8->EF8_FORN := aCols[i][GDFieldPos("EF8_FORN")]
                  EF8->EF8_LOJA := aCols[i][GDFieldPos("EF8_LOJA")]
               EndIf

            EndIf
         Next i

      //EndIf

   ElseIf A_Tipo == 5

      //Exclui todos os itens relacionados ao Cadastro(EF7 ou EF9) em EF8
      EF8->( DBSetOrder(1) )
      EF8->( DBSeek( xFilial("EF8")+cTipAl+IIF(cTipAl=="F",M->EF7_FINANC,If(cTipAl=="R",M->EF9_ROF,M->EFA_LINCRE)) ) )
      Do While !( EF8->( EOF() ) ) .AND. Eval(cComp1) .AND. (EF8->EF8_TP_REL == cTipAl) .And. Eval(cComp4)
         EF8->( RecLock("EF8",lTip) )
         EF8->( DBDelete(), MSUnlock(), DBSkip() )
      EndDo

      // Exclui o registro do Cadastro (EF7 ou EF9)
      If cTipAl == "R"
         MSMM(M->EF9_OBS,,,,EXCMEMO)
      ElseIf cTipAl == "L"
         MSMM(M->EFA_OBS,,,,EXCMEMO)
      EndIf
      DBSelectArea(cAlias)
	   (cAlias)->( RecLock(cAlias,lTip), DBDelete(), MSUnlock() )

	EndIf

Return .T.



//******************************************//*****************************************/
Function FI400CpoOK()                       //    Validacao de campo da MSGetDados    */
//******************************************//*****************************************/
 Local   i
 Local   lRet       := .T.
// Local   cCodEve    := ""  ,;
//         cCodEAs    := ""  ,;
//         cCodEBa    := ""       // PLB 10/07/06
 Local   cTipEve    := ""
 Private cTipFin    := ""
 Private CNameField := ""
 If cLocal == NIL
    cLocal := "MSGETDADOS"
 EndIf

   Begin Sequence

      cNameField := ReadVar()

      // Verifica se o campo é Evento.
      // É necessario que Cod. e Tipo de Financiamento sejam preenchidos para validacao dos campos de evento.
      If cNameField == "M->EF8_CODEVE"  .Or.  cNameField == "M->EF8_CODEAS"  .Or.  cNameField == "M->EF8_CODEBA"
         If !Empty(&cNameField)
/*         Do Case  // PLB 10/07/06

            Case cNameField == "M->EF8_CODEVE"
               cCodEve := M->EF8_CODEVE
               If cLocal == "ENCHOICE"
                  cCodEAs := M->EF8_CODEAS
                  cCodEBa := M->EF8_CODEBA
               Else
                  cCodEAs := aCols[n][GDFieldPos("EF8_CODEAS")]
                  cCodEBa := aCols[n][GDFieldPos("EF8_CODEBA")]
               EndIf

            Case cNameField == "M->EF8_CODEAS"
               cCodEAs := M->EF8_CODEAS
               If cLocal == "ENCHOICE"
                  cCodEve := M->EF8_CODEVE
                  cCodEBa := M->EF8_CODEBA
               Else
                  cCodEve := aCols[n][GDFieldPos("EF8_CODEVE")]
                  cCodEBa := aCols[n][GDFieldPos("EF8_CODEBA")]
               EndIf

            Case cNameField == "M->EF8_CODEBA"
               cCodEBa := M->EF8_CODEBA
               If cLocal == "ENCHOICE"
                  cCodEve := M->EF8_CODEVE
                  cCodEAs := M->EF8_CODEAS
               Else
                  cCodEve := aCols[n][GDFieldPos("EF8_CODEVE")]
                  cCodEAs := aCols[n][GDFieldPos("EF8_CODEAS")]
               EndIf

         End Case
*/
            // PLB 28/07/06
            If cLocal == "ENCHOICE"
               cTipEve := M->EF8_TIP_EV
            Else
               cTipEve := aCols[n][GDFieldPos("EF8_TIP_EV")]
            EndIf

            If Empty(IIF(cTipAl=="F",M->EF7_FINANC,If(cTipAl=="M",M->EF1_TP_FIN,If(cTipAl=="R",M->EF9_FINANC,M->EFA_TP_FIN))))
               MsgInfo(STR0031) // "Preencha o campo Código do Financiamento"
               lRet := .F.
               Break
            EndIf

            If Eval(cComp3)
               cTipFin := "FIIM"
            ElseIf Eval(cComp5)
               cTipFin := "FIEX"
            ElseIf Empty(IIF(cTipAl=="F",M->EF7_TP_FIN,If(cTipAl=="M",M->EF1_TPMODU,If(cTipAl=="R",M->EF9_TP_ROF,"I"))))
               MsgInfo(STR0032) // "Preencha o campo Tipo (Exportação / Importação)."
               lRet := .F.
               Break
            EndIf

            // Verifica se o Evento está entre 300 e 499
            If cNameField == "M->EF8_CODEVE"
               If Left(&cNameField,1) != "3" .And. Left(&cNameField,1) != "4"
                  MsgStop(STR0029) // "Código Inválido. Digite um código que começe com 3 ou 4."
                  lRet := .F.
                  Break
               EndIf
            ElseIf cNameField == "M->EF8_CODEAS"  //.Or.  cNameField == "M->EF8_CODEBA" //FSM - 17/07/2012
               If Left(&cNameField,1) == "3"  .Or.  Left(&cNameField,1) == "4"
                  MsgStop(STR0074) // "Codigo Invalido. Digite um evento que nao comece com 3 ou 4."
                  lRet := .F.
                  Break
               EndIf
            EndIf

  /*       // PLB 10/07/06 - Verifica se o Evento já existe neste Cadastro
         If !Empty(cCodEve)  .And.  !Empty(cCodEAs)  .And.  !Empty(cCodEBa)  .And.  !Empty(cTipEve)
            For i:=1 to Len(aCols)
               If cCodEve == aCols[i][GDFieldPos("EF8_CODEVE")]       ;
                  .And. cCodEAs == aCols[i][GDFieldPos("EF8_CODEAS")] ;
                  .And. cCodEBa == aCols[i][GDFieldPos("EF8_CODEBA")] ;
                  .And. cTipEve == aCols[i][GDFieldPos("EF8_TIP_EV")] ;
                  .And. !aCols[i][Len(aCols[i])]                      ;
                  .And. IIF( cLocal=="ENCHOICE",.T.,n!=i)             ;
                  .And. IIF(cLocal=="MANUTENÇÃO",aCols[i][GDFieldPos("EF8_TP_REL")]=="M",.T.)
                    MsgStop(STR0030) // "Evento já existente. Digite outro."
                    lRet := .F.
                    Break
               EndIf
            Next
         EndIf
*/
            // Verifica se o Evento existe com Centro de Custo em branco ou igual a 1000
            EC6->( DBSetOrder(1) )
            If !EC6->( DBSeek( Eval(cChav2) ) ) .And. !EC6->( DBSeek( Eval(cChav3) ) )
               MsgStop(STR0033) // "Código Inválido"
               lRet := .F.
               Break
            EndIf

            If cNameField == "M->EF8_CODEBA"  .And.  IIF(cLocal=="ENCHOICE",M->EF8_TIP_EV,aCols[n][GDFieldPos("EF8_TIP_EV")]) == "1"  // Valor
               MsgInfo(STR0071) //"O Tipo e Valor e o preenchimento do campo Evento Base nao e necessario."
            EndIf
         EndIf
         FI400Gat(cLocal) // Gatilhos para descrição dos eventos

      ElseIf  cNameField == "M->EF8_VL_PCT"
         If IIF(cLocal=="ENCHOICE",M->EF8_TIP_EV,aCols[n][GDFieldPos("EF8_TIP_EV")]) == "1"
            If &(cNameField) < 0
               MsgInfo(STR0034) // "O campo Valor/Percentual deve ser maior ou igual a zero."
               lRet := .F.
               Break
            EndIf
            //** PLB 07/10/06
            If cLocal == "ENCHOICE"
               M->EF8_VL_RS := M->EF8_TAXA * &(cNameField)
            ElseIf GDFieldPos("EF8_VL_RS") > 0  .And.  GDFieldPos("EF8_TAXA") > 0
               aCols[n][GDFieldPos("EF8_VL_RS")] := aCols[n][GDFieldPos("EF8_TAXA")] * &(cNameField)
            EndIf
            //**
         ElseIf IIF(cLocal=="ENCHOICE",M->EF8_TIP_EV,aCols[n][GDFieldPos("EF8_TIP_EV")]) == "2"
            If &(cNameField) > 100
               MsgInfo(STR0040) // "O percentual deve ser no máximo 100."
               lRet := .F.
               Break
            ElseIf &(cNameField) < 0
               MsgInfo(STR0034) // "O campo Valor/Percentual deve ser maior ou igual a zero."
               lRet := .F.
               Break
            EndIf
         //Else
         //  If IIF(cLocal=="ENCHOICE",M->EF8_TIP_EV,aCols[n][GDFieldPos("EF8_TIP_EV")]) == "1"
         //      If cLocal == "ENCHOICE"
         //         M->EF8_VL_RS := M->EF8_TAXA * &cNameField
         //      Else
         //         aCols[n][GDFieldPos("EF8_VL_RS")] := aCols[n][GDFieldPos("EF8_TAXA")] * &cNameField
         //      EndIf
         //   EndIf
         EndIf

      ElseIf cNameField == "M->EF8_TAXA"
         If IIF(cLocal=="ENCHOICE",M->EF8_TIP_EV,aCols[n][GDFieldPos("EF8_TIP_EV")]) == "1"
            If cLocal == "ENCHOICE"
               M->EF8_VL_RS := M->EF8_VL_PCT * &(cNameField)
            Else
               aCols[n][GDFieldPos("EF8_VL_RS")] := aCols[n][GDFieldPos("EF8_VL_PCT")] * &(cNameField)
            EndIF
         EndIf

      //** PLB 07/10/06
      ElseIf cNameField == "M->EF8_VL_RS"
         If IIF(cLocal=="ENCHOICE",M->EF8_TIP_EV,aCols[n][GDFieldPos("EF8_TIP_EV")]) == "1"
            If cLocal == "ENCHOICE"
               M->EF8_TAXA :=  &cNameField / M->EF8_VL_PCT
            Else
               aCols[n][GDFieldPos("EF8_TAXA")] := &(cNameField) / aCols[n][GDFieldPos("EF8_VL_PCT")]
            EndIF
         EndIf
      //**

      ElseIf cNameField == "M->EF8_CARGA"
         If &(cNameField) == "1"
            If cLocal == "ENCHOICE"
               M->EF8_TAXA  := 0
               M->EF8_VL_RS := 0
            Else
               aCols[n][GDFieldPos("EF8_TAXA")]  := 0
               aCols[n][GDFieldPos("EF8_VL_RS")] := 0
            EndIf
         Endif
      EndIf

      If cTipAl == "M"
         oGetMS:oBrowse:Refresh()
      EndIf

   End Sequence

Return lRet



//*************************************************************************************/
Function FI400DelOK()         //            Valida a deleçao na MSGetDados            */
//*************************************************************************************/

 Local i
 Local lDel
 Local lRet := .T.

   Begin Sequence

      // Identifica item como deletado/nao deletado
      lDel := !( aCols[n][Len(aCols[n])] )

      If !lDel
         For i:=1 to Len(aCols)
            // Verifica se o Evento já existe
            If aCols[n][GDFieldPos("EF8_CODEVE")] == aCols[i][GDFieldPos("EF8_CODEVE")]      ;
               .And. aCols[n][GDFieldPos("EF8_CODEAS")] == aCols[i][GDFieldPos("EF8_CODEAS")] ;
               .And. aCols[n][GDFieldPos("EF8_TIP_EV")] == aCols[i][GDFieldPos("EF8_TIP_EV")] ;
               .And. IIF(aCols[n][GDFieldPos("EF8_TIP_EV")]=="2",aCols[n][GDFieldPos("EF8_CODEBA")] == aCols[i][GDFieldPos("EF8_CODEBA")],.T.) ;
               .And. !aCols[i][Len(aCols[i])]  .And.  n!=i
                 MsgStop(STR0041) // "O Evento já existe e não pode ser retornado."
                 lRet := .F.
                 Break
            EndIf
         Next
      EndIf
      aCols[n][Len(aCols[n])] := lDel
      oGetMS:oBrowse:Refresh()

   End Sequence

Return lRet



//*************************************************************************************/
Function FI400LinOK()                    //    Validacao de linha da MSGetDados       */
//*************************************************************************************/
 Local lRet := .T.
// Local laColsOK := .T.
 Local i := 1

   Begin Sequence
      /*
      // Verifica se há algum item em aCols
      If Len(aCols) == 1  .And. Len(aCols[1]) >= 5 .and. Empty(aCols[1][1])  .And.  Empty(aCols[1][3])  .And. Empty(aCols[1][5])
         laColsOK := .F.
      EndIf

      If Len(aCols) >= n .and. Len(aCols[n]) >= Len(aHeader)

         If Len(aCols) == 1 .AND. Empty(aCols[n][GDFieldPos("EF8_CODEVE")]) .And. ;
            Empty(aCols[n][GDFieldPos("EF8_CODEAS")]) .And. ;
            Empty(aCols[n][GDFieldPos("EF8_CODEBA")]) .And. ;
            aCols[n][GDFieldPos("EF8_VL_PCT")]==0

            ASize(aCols,Len(aCols)-1)
            Break
         ElseIf Len(aCols)>1 .And. n>1 .And. Empty(aCols[n-1][GDFieldPos("EF8_CODEVE")]) .And. ;
                            Empty(aCols[n-1][GDFieldPos("EF8_CODEAS")]) .And. ;
                            Empty(aCols[n-1][GDFieldPos("EF8_CODEBA")]) .And. ;
                            aCols[n-1][GDFieldPos("EF8_VL_PCT")]==0
         aCols[n-1] := aCols[n]
         ASize(aCols,Len(aCols)-1)
         n -= 1
      EndIf
      */

      // Verifica se existe registro e se não está deletado
      If  /*laColsOK  .And. */ !aCols[n][Len(aCols[n])]

         If n == Len(aCols) .and. Len(aCols[n]) >= Len(aHeader) .and. Empty(aCols[n][GDFieldPos("EF8_CODEVE")]) .AND. Empty(aCols[n][GDFieldPos("EF8_VL_PCT")]) .AND. Empty(aCols[n][GDFieldPos("EF8_CODEAS")])
            //Nao valida linha em branco. Nao sera gravada
            break
         EndIf

         If Empty(aCols[n][GDFieldPos("EF8_CODEVE")])
            MsgInfo(STR0073+AVSX3("EF8_CODEVE",5))  //"Preencha o campo "
            lRet := .F.
            Break

         ElseIf Empty(aCols[n][GDFieldPos("EF8_CODEAS")])
            MsgInfo(STR0073+AVSX3("EF8_CODEAS",5))  //"Preencha o campo "
            lRet := .F.
            Break

         ElseIf Empty(aCols[n][GDFieldPos("EF8_TIP_EV")])
            MsgInfo(STR0042) // "O Tipo não pode estar em branco. Escolha uma das opções."
            lRet := .F.
            Break

         ElseIf aCols[n][GDFieldPos("EF8_VL_PCT")] <= 0
            MsgInfo(STR0034) // "O campo Valor/Percentual deve ser maior que zero."
            lRet := .F.
            Break

         ElseIf aCols[n][GDFieldPos("EF8_TIP_EV")] == "1" .And. !Empty( aCols[n][GDFieldPos("EF8_PCT_RJ")] )
            MsgInfo(STR0043)  // "O Tipo é Valor. Deixe o campo Percentual Reajustado em Branco."
            lRet := .F.
            Break

         ElseIf aCols[n][GDFieldPos("EF8_TIP_EV")] == "2"
            If Empty(aCols[n][GDFieldPos("EF8_CODEBA")])
               MsgInfo(STR0053) // "O Tipo é Percentual. O campo Evento Base deve ser preenchido."
               lRet := .F.
               Break
            ElseIf aCols[n][GDFieldPos("EF8_VL_PCT")] > 100
               MsgInfo(STR0040)
               lRet := .F.
               Break
            ElseIf Empty(aCols[n][GDFieldPos("EF8_PCT_RJ")])
               MsgInfo(STR0044) // "O Tipo é Percentual. O campo Percentual Reajustado deve ser preenchido."
               lRet := .F.
               Break
            EndIf
         EndIf

         If !Empty(aCols[n][GDFieldPos("EF8_CODEVE")])  .And.  !Empty(aCols[n][GDFieldPos("EF8_CODEAS")])
            For i:=1 to Len(aCols)
               If aCols[n][GDFieldPos("EF8_CODEVE")] == aCols[i][GDFieldPos("EF8_CODEVE")]      ;
                  .And. aCols[n][GDFieldPos("EF8_CODEAS")] == aCols[i][GDFieldPos("EF8_CODEAS")] ;
                  .And. aCols[n][GDFieldPos("EF8_TIP_EV")] == aCols[i][GDFieldPos("EF8_TIP_EV")] ;
                  .And. IIF(aCols[n][GDFieldPos("EF8_TIP_EV")]=="2",aCols[n][GDFieldPos("EF8_CODEBA")] == aCols[i][GDFieldPos("EF8_CODEBA")],.T.) ;
                  .And. !aCols[i][Len(aCols[i])]                                                 ;
                  .And. IIF(cLocal=="ENCHOICE",.T.,n!=i)                                         ;
                  .And. IIF(cLocal=="MANUTENÇÃO",aCols[i][GDFieldPos("EF8_TP_REL")]=="M",.T.)
                    MsgStop(STR0030) // "Evento já existente. Digite outro."
                    lRet := .F.
                    Break
               EndIf
            Next
         EndIf

         If !Empty(aCols[n][GDFieldPos("EF8_CODEBA")])  .And.  aCols[n][GDFieldPos("EF8_TIP_EV")] == "1"  // Valor
            If !MsgYesNo(STR0071;                   //"O Tipo e Valor e o preenchimento do campo Evento Base nao e necessario."
                         +CHR(13)+CHR(10)+STR0072)  //"Deseja manter o Evento Base?"
               GDFieldPut("EF8_CODEBA", "   ", n)
               GDFieldPut("EF8_DESEBA", ""   , n)
            EndIf
         EndIf

         If AvFlags("SIGAEFF_SIGAFIN") .OR. EasyGParam("MV_EECI010",,.F.)
            If !Empty(aCols[n][GDFieldPos("EF8_FORN")])  .And. Empty(aCols[n][GDFieldPos("EF8_LOJA")])
               MsgStop("O campo loja do fornecedor deve ser preenchido.","Aviso")
               lRet := .F.
            EndIf

            If Empty(aCols[n][GDFieldPos("EF8_FORN")])  .And. !Empty(aCols[n][GDFieldPos("EF8_LOJA")])
               MsgStop("O campo loja de ser preenchido apenas se o fornecedor for preenchido.","Aviso")
               lRet := .F.
            EndIf

            If !Empty(aCols[n][GDFieldPos("EF8_FORN")])  .And. !Empty(aCols[n][GDFieldPos("EF8_LOJA")])
               If !SA2->(dbSetOrder(1),dbSeek(xFilial("SA2")+aCols[n][GDFieldPos("EF8_FORN")]+aCols[n][GDFieldPos("EF8_LOJA")]))
                  MsgStop("Fornecedor nao cadastrado. Escolha um fornecedor valido","Aviso")
                  lRet := .F.
               EndIf
            EndIf
         EndIf

      EndIf

   End Sequence

Return lRet



//*********************************************//**************************************/
Function FI400TudOK()                          //          Validacao Total            */
//*********************************************//**************************************/
 Local i
 Local lRet := .T.
// Local laColsOK := .T.
 Private cTipFin := ""

   Begin Sequence

      If !FI400LinOK()
         lRet := .F.
         Break
      EndIf

      // Verifica se há algum item em aCols
      /*
      If Len(aCols) == 1  .And.  Empty(aCols[1][1])  .And.  Empty(aCols[1][3])  .And. Empty(aCols[1][5])
         laColsOK := .F.
      EndIf

      If laColsOK
      */

         If Eval(cComp3)
            cTipFin := "FIIM"
         ElseIf Eval(cComp5)
            cTipFin := "FIEX"
         EndIf

         For i:=1 to Len(aCols)
            If !aCols[i][Len(aCols[i])]
               If !Empty(aCols[i][GDFieldPos("EF8_CODEVE")])
                  EC6->( DBSetOrder(1) )
                  If !EC6->( DBSeek( Eval(cChav4) ) ) ;
                     .And. !EC6->( DBSeek( Eval(cChav5) ) )
                     MsgInfo(STR0039+AllTrim(Str(i))+CHR(13)+CHR(10)+STR0035+STR0038) // "Linha: "  // "Código de Evento não compatível com o financiamento."
                     lRet := .F.
                     Break
                  Else
                     aCols[i][GDFieldPos("EF8_DESEVE")] := EC6->EC6_DESC
                  EndIf
               Endif

               If !Empty(aCols[i][GDFieldPos("EF8_CODEAS")])
                  If  !EC6->( DBSeek( Eval(cChav6) ) ) ;
                      .And. !EC6->( DBSeek( Eval( cChav7) ) )
                     MsgInfo(STR0039+AllTrim(Str(i))+CHR(13)+CHR(10)+STR0036+STR0038) // "Linha: "  // "Código do Evento Associado não compatível com o financiamento."
                     lRet := .F.
                     Break
                  Else
                     aCols[i][GDFieldPos("EF8_DESEAS")] := EC6->EC6_DESC
                  EndIf
               EndIf

               If !Empty(aCols[i][GDFieldPos("EF8_CODEBA")])
                  If  !EC6->( DBSeek( Eval(cChav8) ) ) ;
                      .And. !EC6->( DBGoTop(), DBSeek( Eval(cChav9) ) )
                     MsgInfo(STR0039+AllTrim(Str(i))+CHR(13)+CHR(10)+STR0037+STR0038) // "Linha: " // "Código do Evento Base não compatível com o financiamento."
                     lRet := .F.
                     Break
                  Else
                     aCols[i][GDFieldPos("EF8_DESEBA")] := EC6->EC6_DESC
                  EndIf
               EndIf
            EndIf
         Next

      //EndIf

      If cTipAl == "R" .or. cTipAl == "L"
         EF7->( DBSetOrder(1) )
         EF7->( DBSeek(xFilial("EF7")+If(cTipAl=="R",M->EF9_FINANC,M->EFA_TP_FIN)) )
         If EF7->EF7_TP_FIN != If(cTipAl=="R",M->EF9_TP_ROF,"I")
            MsgInfo(If(cTipAl=="R",STR0048,STR0059)) // "O Tipo do Financiamento é diferente do Tipo do ROF/Linha de Crédito. Eles devem ser iguais."
            lRet := .F.
            Break
         EndIf
         If cTipAl == "R"  .And.  !Empty(M->EF9_ROF_AN)
            nOrd := EF9->( IndexOrd() )
            nRec := EF9->( RecNo() )
            EF9->( DBSetOrder(1) )
            If EF9->( DBSeek(xFilial("EF9")+M->EF9_ROF_AN) )  .And.  EF9->EF9_TP_ROF != M->EF9_TP_ROF
               MsgStop(STR0086+BscXBox("EF9_TP_ROF",M->EF9_TP_ROF)+STR0087+AllTrim(M->EF9_ROF_AN)+STR0088+BscXBox("EF9_TP_ROF",EF9->EF9_TP_ROF)+".")  //"O ROF é do tipo " ### " e não pode substituir o ROF '" ### "' que é do tipo " ###
               lRet := .F.
            EndIf
            EF9->( DBSetOrder(nOrd) )
            EF9->( DBGoTo(nRec) )
            If !lRet
              Break
            EndIf
         EndIf
      EndIf

      nVolta:=1
      oDlg:End()

   End Sequence

Return lRet

//***************************************//********************************************/
Function FI400Eve(cTp)                   //    Monta e exibe Enchoice dos Eventos     */
//***************************************//********************************************/
   Local oObj
   Local aPos
   Local i
   Local lRet := .T.
   Local lWhen := .T.
   Private cNameField := ""
   Private oDlg2
   Private nVolta2
   Private aTela[0][0]
   Private aGets[0]

   Begin Sequence

      // Usada para Gatilho distinguir MSGETDADOS da ENCHOICE
      cLocal := "ENCHOICE"

      aPos := {}
	  nVolta2 := 0

      If !FI400WhEve()
         lRet := .F.
         Break
      EndIf

      If Len(aCols)>1 .And. n>1 .And. Empty(aCols[n-1][GDFieldPos("EF8_CODEVE")]) .And. ;
                                      Empty(aCols[n-1][GDFieldPos("EF8_CODEAS")]) .And. ;
                                      Empty(aCols[n-1][GDFieldPos("EF8_CODEBA")]) .And. ;
                                      aCols[n-1][GDFieldPos("EF8_VL_PCT")]==0
         aCols[n-1] := aCols[n]
         ASize(aCols,Len(aCols)-1)
         n -= 1
      EndIf

      If cTP == "INC"
         For i := 1 to Len(aHeader)
            If aHeader[i][2] $ "EF8_ALI_WT/EF8_REC_WT"
               Loop
            EndIf
            M->&(aHeader[i][2]) := CriaVar(aHeader[i][2])
         Next

      ElseIf Len(aCols) == 1  .And.  Empty(aCols[1][1]) .And. Empty(aCols[1][3]) .And. Empty(aCols[1][5])
         MsgStop(STR0045) // "Não existem eventos relacionados a este Financiamento."
         lRet := .F.
         Break

      Else
         For i := 1 to Len(aHeader)
            If aHeader[i][2] $ "EF8_ALI_WT/EF8_REC_WT"
               Loop
            EndIf
            M->&(aHeader[i][2]) := aCols[n][i]
         Next
         If aCols[n][Len(aCols[n])]
            If cTP == "ALT"
               MsgStop(STR0046) // "O Evento foi excluído e não pode ser alterado."
               lRet := .F.
               Break
            ElseIf cTP == "EXC"
               MsgStop(STR0047) // "O Evento já foi excluído."
               lRet := .F.
               Break
            EndIf
         ElseIf cTP != "ALT"
            lWhen2 := .F.
         EndIf
      EndIf

   	DEFINE MSDIALOG oDlg2 TITLE STR0078 FROM oMainWnd:nTop + 150, oMainWnd:nLeft + 5 TO oMainWnd:nHeight-220, oMainWnd:nWidth-150 OF oMainWnd PIXEL  //"Eventos"
    aPos := {,,120,(oDlg:nClientWidth-4)/2}
    oEnch2 := MsMGet():New("EF8",,IF(cTP=="INC",3,4),nil,nil,nil,nil,aPos)
    oEnch2:oBox:Align := CONTROL_ALIGN_TOP
    oEnch2:oBox:Align := CONTROL_ALIGN_ALLCLIENT

   	ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT EnchoiceBar(oDlg2,{|| If(Obrigatorio(aGets,aTela), IIF(cTp$"INC/ALT",ValEv(cTp),Eval({||nVolta2:=1,oDlg2:End()}))  , nVolta2 := 0 )},{||oDlg2:End()},,)

	   If nVolta2 == 1
         If cTP == "EXC"
            aCols[n][Len(aCols[n])] := .T.

         ElseIf cTP == "INC"
            If !Empty(aCols[n][1]) .Or. !Empty(aCols[n][3]) .Or. !Empty(aCols[n][5]) .Or. aCols[n][8]>0
               AAdd( aCols, Array( Len(aHeader)+2 ) )
               For  i := 1  to  Len(aHeader)
                  If aHeader[i][2] $ "EF8_ALI_WT/EF8_REC_WT"
                     Loop
                  EndIf
                  aCols[Len(aCols)][i] := M->&(aHeader[i][2])
               Next
               aCols[Len(aCols)][Len(aHeader)+1] := 0
               aCols[Len(aCols)][Len(aHeader)+2] := .F.
            Else
               For  i := 1  to  Len(aHeader)
                  If aHeader[i][2] $ "EF8_ALI_WT/EF8_REC_WT"
                     Loop
                  EndIf
                  aCols[n][i] := M->&(aHeader[i][2])
               Next
               aCols[n][Len(aHeader)+1] := 0
               aCols[n][Len(aHeader)+2] := .F.
               Eval(oGetMS:oBROWSE:bADD)
            EndIf

         ElseIf cTP == "ALT"
            For  i := 1  to  Len(aHeader)
               If aHeader[i][2] $ "EF8_ALI_WT/EF8_REC_WT"
                     Loop
               EndIf
               aCols[n][i] := M->&(aHeader[i][2])
            Next
         EndIf

	   EndIf

      cLocal := ""
      lWhen2   := .T.

   End Sequence

Return lRet

//***************************************//********************************************/
Static Function ValEv(cTp)               //      Valida Enchoice dos Eventos(EF8)      /
//***************************************//********************************************/
 Local lRet := .T.
 Local i:= 1

   Begin Sequence

      If  M->EF8_TIP_EV == "1" .And. !Empty( M->EF8_PCT_RJ)
         MsgInfo(STR0043)  // "O Tipo é Valor. Deixe o campo Percentual Reajustado em Branco."
         lRet := .F.
         Break

      ElseIf  M->EF8_TIP_EV == "2"
         If Empty(M->EF8_CODEBA)
            MsgInfo(STR0053) // "O Tipo é Percentual. O campo Evento Base deve ser preenchido."
            lRet := .F.
            Break
         ElseIf M->EF8_VL_PCT > 100
            MsgInfo(STR0040)
            lRet := .F.
            Break
         ElseIf Empty(M->EF8_PCT_RJ)
            MsgInfo(STR0044) // "O Tipo é Percentual. O campo Percentual Reajustado deve ser preenchido."
            lRet := .F.
            Break
         EndIf
      EndIf

      For i:=1 to Len(aCols)
         If M->EF8_CODEVE == aCols[i][GDFieldPos("EF8_CODEVE")]       ;
            .And. M->EF8_CODEAS == aCols[i][GDFieldPos("EF8_CODEAS")] ;
            .And. M->EF8_TIP_EV == aCols[i][GDFieldPos("EF8_TIP_EV")] ;
            .And. IIF(M->EF8_TIP_EV=="2",M->EF8_CODEBA == aCols[i][GDFieldPos("EF8_CODEBA")],.T.) ;
            .And. !aCols[i][Len(aCols[i])] .And. IIF(cTp=="ALT",n!=i,.T.)
              MsgStop(STR0030) // "Evento já existente. Digite outro."
              lRet := .F.
              Break
         EndIf
      Next

      If !Empty(M->EF8_CODEBA)  .And.  M->EF8_TIP_EV == "1"  // Valor
         If !MsgYesNo(STR0071;                   //"O Tipo e Valor e o preenchimento do campo Evento Base nao e necessario."
                      +CHR(13)+CHR(10)+STR0072)  //"Deseja manter o Evento Base?"
            M->EF8_CODEBA := "   "
            M->EF8_DESEBA := ""
         EndIf
      EndIf

      nVolta2 := 1
      oDlg2:End()

   End Sequence

Return lRet


//***************************************//********************************************/
Function FI400VlROF()                    //        Validacao dos campos do ROF        */
//***************************************//********************************************/
 Local cFieldROF := ""
 Local lRet := .T.

   Begin Sequence

      cFieldROF := ReadVar()

      Do Case
         Case cFieldROF == "M->EF9_TP_ROF"
            cFiltroF3Fin := &cFieldROF

         Case cFieldROF == "M->EF9_ROF_AN"
            nRec := EF9->( RecNo() )
            nOrd := EF9->( IndexOrd() )
            EF9->( DBSetOrder(5) )
            If !Empty(&cFieldROF) .And. EF9->( DBSeek(xFilial("EF9")+&cFieldROF) )
               MsgInfo(STR0049+AllTrim(EF9->EF9_ROF)+STR0050+STR0051) //"Este ROF foi substituído pelo ROF "###" e não pode ser "###"substituído novamente."
               lRet := .F.
            EndIf
            EF9->( DBSetOrder(nOrd) )
            EF9->( DBGoTo(nRec) )
            If !lRet
               Break
            EndIf

            If Empty(M->EF9_ROF)
               MsgInfo(STR0052) // "Preencha o Código do ROF."
               lRet := .F.
               Break
            EndIf
            FI400GtROF()

         Case cFieldROF == "M->EF9_FINANC"
            EF7->( DBSetOrder(1) )
            EF7->( DBSeek(xFilial("EF7")+M->EF9_FINANC) )
            If EF7->EF7_TP_FIN != M->EF9_TP_ROF
               MsgInfo(STR0048) // "O Tipo do Financiamento é diferente do Tipo do ROF. Eles devem ser iguais."
               lRet := .F.
               Break
            EndIf
            lWhen3 := .T.

         Case cFieldROF == "M->EF9_DT_ROF"
            If !Empty(M->EF9_ROF_AN)
               EF9->( DBSetOrder(1) )
               EF9->( DBSeek(xFilial("EF9")+M->EF9_ROF_AN) )
               If EF9->EF9_DT_ROF > M->EF9_DT_ROF
                  MsgInfo(STR0054+DTOC(EF9->EF9_DT_ROF)) // "A Data não pode ser antes da Data do ROF Anterior: "
                  lRet := .F.
                  Break
               EndIf
            EndIf
            If lRet .and. !Empty(M->EF9_DT_ROF) .and. !Empty(M->EF9_PRAZO)
               M->EF9_DT_VEN := M->EF9_DT_ROF + M->EF9_PRAZO
            EndIf

         Case cFieldROF == "M->EF9_PRAZO"
            If !Positivo(M->EF9_PRAZO)
               lRet := .F.
            ElseIf !Empty(M->EF9_DT_ROF) .and. !Empty(M->EF9_PRAZO)
               M->EF9_DT_VEN := M->EF9_DT_ROF + M->EF9_PRAZO
            EndIf

         Case cFieldROF == "M->EF9_VL_ROF"
            If !Inclui
               If (M->EF9_VL_ROF - (EF9->EF9_VL_ROF - EF9->EF9_SALDO)) < 0
                  MsgInfo(STR0070) //"Valor inválido em relação ao saldo já utilizado."
                  lRet := .F.
               Else
                  M->EF9_SALDO := M->EF9_VL_ROF - (EF9->EF9_VL_ROF - EF9->EF9_SALDO)
               Endif
            Else
               M->EF9_SALDO := M->EF9_VL_ROF
            EndIf

      EndCase

   End Sequence

Return lRet


//***************************************//********************************************/
Function FI400GtROF()                    //        Gatilhos do ROF anterior           */
//***************************************//********************************************/
 Local i
 Private cOldChav1 := cChav1
 Private cOldComp2 := cComp2

   If !Empty(M->EF9_ROF_AN) .And. MsgYesNo(STR0079+STR0080+"?",STR0080)  //"Deseja copiar os Dados do " ## "ROF Anterior"
      EF9->( DBSetOrder(1) )
      EF9->( DBSeek(xFilial("EF9")+M->EF9_ROF_AN) )
      M->EF9_TP_ROF := EF9->EF9_TP_ROF
      M->EF9_FINANC := EF9->EF9_FINANC
      M->EF9_INPI   := EF9->EF9_INPI
      M->EF9_VL_ROF := EF9->EF9_VL_ROF
      M->EF9_RES_IR := EF9->EF9_RES_IR
      M->EF9_RES_OB := EF9->EF9_RES_OB
      M->EF9_GARANT := EF9->EF9_GARANT
      M->EF9_GAR_DC := EF9->EF9_GAR_DC
      M->EF9_VM_OBS := MSMM(EF9->EF9_OBS,AVSX3("EF9_VM_OBS",AV_TAMANHO),,,LERMEMO) // EF9->EF9_OBSERV
      cChav1 := {|| xFilial("EF8")+"R"+AVKey(M->EF9_ROF_AN,"EF8_CHAVE")}
      cComp2 := {|| AVKey(M->EF9_ROF_AN,"EF8_CHAVE") == EF8->EF8_CHAVE}
      FI400Cri(4)
      cChav1 := cOldChav1
      cComp2 := cOldComp2
      If Empty(aCols)
          AAdd( aCols, Array( Len(aHeader)+2 ) )
          For i := 1 to Len(aHeader)
             aCols[Len(aCols)][i] := CriaVar( aHeader[i][2] )
          Next
          aCols[Len(aCols)][Len(aHeader)+1] := 0
          aCols[Len(aCols)][Len(aHeader)+2] := .F.
      EndIf
      oGetMS:oBrowse:Refresh()
   EndIf

Return .T.



//***************************************//********************************************/
Function FI400AltROF(A_Tipo)             //   Valida Alteracao/Exclusao de ROF        */
//***************************************//********************************************/
 Local cMens   := ""
 Local cCodROF := ""
 Local lRet    := .T.

   Begin Sequence

      cCodROF := EF9->EF9_ROF

      If A_Tipo == 5
         #IFDEF TOP
            SIX->( DBSetOrder(1) )
            If SIX->( DBSeek("EF1"+"5") )
               EF1->( DBSetOrder(5) )
               If EF1->( DBSeek(xFilial("EF1")+cCodROF+EF9->EF9_TP_ROF) )
                  MsgInfo(STR0055) // "O ROF existe em EF1 e não pode ser excluído."
                  lRet := .F.
                  Break
               EndIf
            EndIf
         #ENDIF
      EndIf

      EF9->( DBSetOrder(5) )

      If EF9->( DBSeek(xFilial("EF9")+cCodROF) )
         IIF(A_Tipo==4, cMens:=STR0081, cMens:=STR0082)  //"alterado."  ##  "excluído."
         MsgInfo(STR0049+AllTrim(EF9->EF9_ROF)+STR0050+cMens) // "Este ROF foi substituído pelo ROF "+ + " e não pode ser "
         lRet := .F.
         Break
      EndIf

      EF9->( DBSetOrder(1) )
      EF9->( DBSeek(xFilial("EF9")+cCodROF) )

   End Sequence

Return lRet



//****************************//*******************************************************/
Function FI400WhEve()         //           Validacao de Edicao de Eventos             */
//****************************//*******************************************************/
 Local lRet := .T.

   If Empty(IIF(cTipAl=="F",M->EF7_FINANC,If(cTipAl=="M",M->EF1_TP_FIN,If(cTipAl=="R",M->EF9_FINANC,M->EFA_TP_FIN))))
      MsgInfo(STR0031) // "Preencha o campo Código do Financiamento"
      lRet := .F.
   EndIf

Return lRet



//***************************************//********************************************/
Function FI400ExcFIN()                   //   Valida Exclusao de Financiamento        */
//***************************************//********************************************/
 Local lRet := .T.

   Begin Sequence

      EF9->( DBSetOrder(3) )
      If EF9->( DBSeek(xFilial("EF9")+EF7->EF7_FINANC) )
         MsgInfo(STR0056+STR0083+AllTrim(EF9->EF9_ROF)+STR0050+STR0057) // "Este Tipo de Financiamento está relacionado a"###"o ROF "###" e não pode ser excluído."
         lRet := .F.
         Break
      EndIf

      EFA->( DBSetOrder(2) )
      If EFA->( DBSeek(xFilial("EFA")+EF7->EF7_FINANC) )
         MsgInfo(STR0056+" "+STR0076+" "+AllTrim(EFA->EFA_LINCRE)+STR0050+STR0057) // "Este Tipo de Financiamento está relacionado a + " Linha de Crédito "###" e não pode ser excluído."
         lRet := .F.
         Break
      EndIf

      //** PLB 05/10/06 - Verifica se existe contrato cadastrado com este tipo de Financiamento
      EF1->( DBSetOrder(2) )
      If EF1->( DBSeek(xFilial("EF1")+EF7->EF7_FINANC+EF7->EF7_TP_FIN) )
         MsgStop(STR0084)  //"Não é possível excluir pois existe(m) contrato(s) de financiamento utilizando este Tipo de Financiamento."
         lRet := .F.
         Break
      EndIf
      //**

   End Sequence

Return lRet

//*****************************//******************************************************/
Function LC100Val(cCampo)      //      Validacao de Campos da Linha de Credito        */
//*****************************//******************************************************/
 Local   lRet       := .T. ,;
         nSaldoAnt  := 0   ,;
         nSomaCont  := 0
 Private cNameField := ""

   If cCampo = NIL
      cNameField := ReadVar()
   Else
      cNameField := cCampo
   EndIf

   Begin Sequence

      If cNameField == "M->EFA_VL_PRI"
         nSomaCont := nValorLin - M->EFA_SALDO
         If &cNameField < nSomaCont
            MsgInfo(STR0060+" ("+M->EFA_MOEDA+" "+AllTrim( Transform( nSomaCont, PesqPict("EFA","EFA_VL_PRI") ) )+").") // "O Valor da Linha de Crédito não pode ser menor que a soma dos Contratos já vinculados"
            lRet := .F.
            Break
         Else
            nSaldoAnt    := M->EFA_SALDO
            M->EFA_SALDO := &cNameField - nValorLin + nSaldoAnt
            nValorLin    := &cNameField
         EndIf

      ElseIf cNameField == "M->EFA_TP_FIN"
         EF7->( DBSetOrder(1) )
         If EF7->( DBSeek(xFilial("EF7")+&cNameField) )
            If EF7->EF7_TP_FIN != "I"
               MsgInfo(STR0063+EF7->EF7_FINANC+STR0064) // "O Tipo de Financiamento " + + " não é de Importação."
               lRet := .F.
               Break
            EndIf
         EndIf
         lWhen2 := .T. // Permite edicao do Codigo do Evento

      ElseIf cNameField == "M->EFA_CREDOR"
         If &cNameField == "1" //Banco
            M->EFA_CLIENT := Space(06)
            M->EFA_LOJCLI := Space(02)
            M->EFA_FORN   := Space(06)
            M->EFA_LOJFOR := Space(02)
            M->EFA_DESCRE := Space(40)
            M->EFA_ENDCRE := Space(40)
            M->EFA_PAISCR := Space(03)
            M->EFA_DESPCR := Space(25)

            Break
         ElseIf &cNameField == "2" // Cliente
            M->EFA_BANC   := Space(03)
            M->EFA_AGEN   := Space(05)
            M->EFA_NCON   := Space(10)
            M->EFA_FORN   := Space(06)
            M->EFA_LOJFOR := Space(02)
            M->EFA_DESCRE := Space(40)
            M->EFA_ENDCRE := Space(40)
            M->EFA_PAISCR := Space(03)
            M->EFA_DESPCR := Space(25)
            Break
         ElseIf &cNameField == "3" // Fornecedor
            M->EFA_BANC    := Space(03)
            M->EFA_AGEN    := Space(05)
            M->EFA_NCON    := Space(10)
            M->EFA_CLIENT  := Space(06)
            M->EFA_LOJCLI  := Space(02)
            M->EFA_DESCRE  := Space(40)
            M->EFA_ENDCRE  := Space(40)
            M->EFA_PAISCR  := Space(03)
            M->EFA_DESPCR  := Space(25)
            Break
         EndIf

      ElseIf cNameField == "M->EFA_NCON"
         SA6->( DBSetOrder(1) )
         SA6->( DBSeek(xFilial("SA6")+M->EFA_BANC+M->EFA_AGEN+M->EFA_NCON) )
         M->EFA_DESCRE := SA6->A6_NOME
         M->EFA_ENDCRE := SA6->A6_END
         M->EFA_PAISCR := SA6->A6_COD_P
         SYA->( DBSetOrder(1) )
         SYA->( DBSeek(xFilial("SYA")+M->EFA_PAISCR) )
         M->EFA_DESPCR := SYA->YA_DESCR
         Break

      ElseIf cNameField == "M->EFA_BANC"
         If !Empty(M->EFA_BANC) .And. !Empty(M->EFA_NCON)
            SA6->( DBSetOrder(1) )
            SA6->( DBSeek(xFilial("SA6")+M->EFA_BANC+M->EFA_AGEN+M->EFA_NCON) )
            M->EFA_DESCRE := SA6->A6_NOME
            M->EFA_ENDCRE := SA6->A6_END
            M->EFA_PAISCR := SA6->A6_COD_P
            SYA->( DBSetOrder(1) )
            SYA->( DBSeek(xFilial("SYA")+M->EFA_PAISCR) )
            M->EFA_DESPCR := SYA->YA_DESCR
            Break
         Else
            M->EFA_DESCRE := Space(40)
            M->EFA_ENDCRE := Space(40)
            M->EFA_PAISCR := Space(03)
            M->EFA_DESPCR := Space(25)
            Break
         EndIf

      ElseIf cNameField == "M->EFA_LOJCLI" .Or. ;
           (cNameField=="M->EFA_CLIENT" .And. !Empty(M->EFA_LOJCLI))
         SA1->( DBSetOrder(1) )
         SA1->( DBSeek(xFilial("SA1")+M->EFA_CLIENT+M->EFA_LOJCLI) )
         M->EFA_DESCRE := SA1->A1_NOME
         M->EFA_ENDCRE := SA1->A1_END
         M->EFA_PAISCR := SA1->A1_PAIS
         SYA->( DBSetOrder(1) )
         SYA->( DBSeek(xFilial("SYA")+M->EFA_PAISCR) )
         M->EFA_DESPCR := SYA->YA_DESCR
         Break

      ElseIf cNameField == "M->EFA_LOJFOR" .Or. ;
           (cNameField=="M->EFA_FORN" .And. !Empty(M->EFA_LOJFOR))
         SA2->( DBSetOrder(1) )
         SA2->( DBSeek(xFilial("SA2")+M->EFA_FORN+M->EFA_LOJFOR) )
         M->EFA_DESCRE := SA2->A2_NOME
         M->EFA_ENDCRE := SA2->A2_END
         M->EFA_PAISCR := SA2->A2_PAIS
         SYA->( DBSetOrder(1) )
         SYA->( DBSeek(xFilial("SYA")+M->EFA_PAISCR) )
         M->EFA_DESPCR := SYA->YA_DESCR
         Break

      // Observacoes do IR de acordo com o responsavel
      ElseIf cNameField == "M->EFA_RESP"
         If &cNameField == "1"
            M->EFA_OBSRES := EasyGParam("MV_EFF0004")
         ElseIf &cNameField == "2"
            M->EFA_OBSRES := EasyGParam("MV_EFF0005")
         EndIf
         Break

      ElseIf cNameField == "M->EFA_DT_INI"
         If !Empty(M->EFA_DT_INI) .and. !Empty(M->EFA_PRAZO)
            M->EFA_DT_VEN := M->EFA_DT_INI + M->EFA_PRAZO
         EndIf

      ElseIf cNameField == "M->EFA_PRAZO"
         If !Positivo(M->EFA_PRAZO)
            lRet := .F.
         ElseIf !Empty(M->EFA_DT_INI) .and. !Empty(M->EFA_PRAZO)
            M->EFA_DT_VEN := M->EFA_DT_INI + M->EFA_PRAZO
         EndIf

      ElseIf cNameField == "Desc_Credor" .or. cNameField == "Browse_Credor"
         cAliasAux := If(cNameField == "Desc_Credor", "M", "EFA")
         If &(cAliasAux+"->EFA_CREDOR") == "1" //Banco
            SA6->( DBSetOrder(1) )
            SA6->( DBSeek(xFilial("SA6")+&(cAliasAux+"->EFA_BANC")+&(cAliasAux+"->EFA_AGEN")+&(cAliasAux+"->EFA_NCON")) )
            If cNameField == "Browse_Credor"
               lRet := SA6->A6_NOME
            Else
               M->EFA_DESCRE := SA6->A6_NOME
               M->EFA_ENDCRE := SA6->A6_END
               M->EFA_PAISCR := SA6->A6_COD_P
               SYA->( DBSetOrder(1) )
               SYA->( DBSeek(xFilial("SYA")+M->EFA_PAISCR) )
               lRet := SYA->YA_DESCR
            Endif
         ElseIf &(cAliasAux+"->EFA_CREDOR") == "2" // Cliente
            SA1->( DBSetOrder(1) )
            SA1->( DBSeek(xFilial("SA1")+&(cAliasAux+"->EFA_CLIENT")+&(cAliasAux+"->EFA_LOJCLI")) )
            If cNameField == "Browse_Credor"
               lRet := SA1->A1_NOME
            Else
               M->EFA_DESCRE := SA1->A1_NOME
               M->EFA_ENDCRE := SA1->A1_END
               M->EFA_PAISCR := SA1->A1_PAIS
               SYA->( DBSetOrder(1) )
               SYA->( DBSeek(xFilial("SYA")+M->EFA_PAISCR) )
               lRet := SYA->YA_DESCR
            EndIf
         ElseIf &(cAliasAux+"->EFA_CREDOR") == "3" // Fornecedor
            SA2->( DBSetOrder(1) )
            SA2->( DBSeek(xFilial("SA2")+&(cAliasAux+"->EFA_FORN")+&(cAliasAux+"->EFA_LOJFOR")) )
            If cNameField == "Browse_Credor"
               lret := SA2->A2_NOME
            Else
               M->EFA_DESCRE := SA2->A2_NOME
               M->EFA_ENDCRE := SA2->A2_END
               M->EFA_PAISCR := SA2->A2_PAIS
               SYA->( DBSetOrder(1) )
               SYA->( DBSeek(xFilial("SYA")+M->EFA_PAISCR) )
               lRet := SYA->YA_DESCR
            EndIf
         EndIf

      EndIf

   End Sequence

Return lRet

//******************************//*****************************************************/
Function LC100IniVirt(cCampo)   //           Inicializa Campos Virtuais               */
//******************************//*****************************************************/
 Local cDescri := ""

   If cCampo == NIL
      cCampo := ""
   EndIf

   Do Case

      // Descricao do Financiamento
      Case cCampo == "EFA_DESCFI"
         If !Empty(M->EFA_TP_FIN)
            EF7->( DBSetOrder(1) )
            EF7->( DBSeek(xFilial("EF7")+M->EFA_TP_FIN) )
            cDescri := EF7->EF7_DESCRI
         EndIf

      // Descricao da Instituicao Financeira
      Case cCampo == "EFA_DESCIF"
         If !Empty(M->EFA_INSTFI)
            SJ7->( DBSetOrder(1) )
            SJ7->( DBSeek(xFilial("SJ7")+M->EFA_INSTFI) )
            cDescri := SJ7->J7_DESC
         EndIf

      // Descricao da Unidade Requisitante
      Case cCampo == "EFA_DESCCC"
         If !Empty(M->EFA_CC)
            SY3->( DBSetOrder(1) )
            SY3->( DBSeek(xFilial("SY3")+M->EFA_CC) )
            cDescri := SY3->Y3_DESC
         EndIf

      // Descricao do Credor  #  Endereco do Credor  #  Pais do Credor
      Case cCampo == "EFA_DESCRE"  .Or.  cCampo == "EFA_ENDCRE"  .Or.  cCampo == "EFA_PAISCR"
         If M->EFA_CREDOR == "1" // Banco
            If !Empty(M->EFA_BANC) .And. !Empty(M->EFA_AGEN) .And. !Empty(M->EFA_NCON)
               SA6->( DBSetOrder(1) )
               SA6->( DBSeek(xFilial("SA6")+M->EFA_BANC+M->EFA_AGEN+M->EFA_NCON) )
               If cCampo == "EFA_DESCRE"
                  cDescri := SA6->A6_NOME
               ElseIf cCampo == "EFA_ENDCRE"
                  cDescri := SA6->A6_END
               ElseIf cCampo == "EFA_PAISCR"
                  cDescri := SA6->A6_COD_P
               EndIf
            EndIf
         ElseIf M->EFA_CREDOR == "2" // Cliente
            If !Empty(M->EFA_CLIENT) .And. !Empty(M->EFA_LOJCLI)
               SA1->( DBSetOrder(1) )
               SA1->( DBSeek(xFilial("SA1")+M->EFA_CLIENT+M->EFA_LOJCLI) )
               If cCampo == "EFA_DESCRE"
                  cDescri := SA1->A1_NOME
               ElseIf cCampo == "EFA_ENDCRE"
                  cDescri := SA1->A1_END
               ElseIf cCampo == "EFA_PAISCR"
                  cDescri := SA1->A1_PAIS
               EndIf
            EndIf
         ElseIf M->EFA_CREDOR == "3" // Fornecedor
            If !Empty(M->EFA_FORN) .And. !Empty(M->EFA_LOJFOR)
               SA2->( DBSetOrder(1) )
               SA2->( DBSeek(xFilial("SA2")+M->EFA_FORN+M->EFA_LOJFOR) )
               If cCampo == "EFA_DESCRE"
                  cDescri := SA2->A2_NOME
               ElseIf cCampo == "EFA_ENDCRE"
                  cDescri := SA2->A2_END
               ElseIf cCampo == "EFA_PAISCR"
                  cDescri := SA2->A2_PAIS
               EndIf
            EndIf
         EndIf


      // Descricao do Pais do Credor
      Case cCampo == "EFA_DESPCR"
            If M->EFA_CREDOR == "1" // Banco
               SYA->( DBSetOrder(1) )
               If SYA->( DBSeek(xFilial("SYA")+M->EFA_PAISCR) )
                  cDescri := SYA->YA_DESCR
               EndIf
            ElseIf M->EFA_CREDOR == "2" // Cliente
               SYA->( DBSetOrder(1) )
               If SYA->( DBSeek(xFilial("SYA")+M->EFA_PAISCR) )
                  cDescri := SYA->YA_DESCR
               EndIf
            ElseIf M->EFA_CREDOR == "3" // Fornecedor
               SYA->( DBSetOrder(1) )
               If SYA->( DBSeek(xFilial("SYA")+M->EFA_PAISCR) )
                  cDescri := SYA->YA_DESCR
               EndIf
            EndIf

      // Observacoes da Linha de Credito
      Case cCampo == "EFA_VM_OBS"
         cDescri := MSMM(EFA->EFA_OBS,AVSX3("EFA_VM_OBS",AV_TAMANHO),,,LERMEMO)

   End Case

Return cDescri

//***************************************//********************************************/
//Function LC100WhBas()                    //       Validacao da Base do Evento         */
//***************************************//********************************************/
/* Local lRet := .F.

   // Trava/Destrava campos (Percentual e Valor na Moeda) de acordo com a Base escolhida

   If cLocal == "MSGETDADOS"
      If aCols[n][GDFieldPos("EFB_BASE")] == "1" // Banco
         lRet := .F.
      ElseIf aCols[n][GDFieldPos("EFB_BASE")] $ "23" // Cliente / Fornecedor
         lRet := .T.
      EndIf

   ElseIf cLocal == "ENCHOICE"
      If M->EFB_BASE == "1" // Banco
         lRet := .F.
      ElseIf M->EFB_BASE $ "23" // Cliente / Fornecedor
         lRet := .T.
      EndIf
   EndIf

Return lRet
*/

//****************************//*******************************************************/
Function LC100Contr()         //      Exibe Browse dos Contratos Vinculados           */
//****************************//*******************************************************/
 Local i
 Local nSecScan
 Local oBar
 Local lRet := .T.

   Begin Sequence

     aCabCon := {}
     aColCon := {}

      EF1->( DBSetOrder(7) )
      If !EF1->( DBSeek( xFilial("EF1")+M->EFA_LINCRE ) )
         MsgInfo(STR0062) // "Não existe Contrato Vinculado a esta Linha de Crédito."
         lRet := .F.
         Break
      EndIf

      AAdd(aCabCon, { AVSX3("EF1_CONTRA", 05), "EF1_CONTRA", AVSX3("EF1_CONTRA", 06), AVSX3("EF1_CONTRA", 03) , AVSX3("EF1_CONTRA", 04) , "" , NIL , AVSX3("EF1_CONTRA", 02) , NIL , NIL} ) // "Contrato"
      // Verifica se existe o campo Sequencia do Contrato na Manutencao de Contratos
      SX3->( DBSetOrder(2) )
      If SX3->( DBSeek("EF1_SEQCNT") )
         AAdd(aCabCon, { AVSX3("EF1_SEQCNT", 05), "EF1_SEQCNT", AVSX3("EF1_SEQCNT", 06), AVSX3("EF1_SEQCNT", 03) , AVSX3("EF1_SEQCNT", 04) , "" , NIL , AVSX3("EF1_SEQCNT", 02) , NIL , NIL} ) // "Sequencia"
      EndIf
      AAdd(aCabCon, { AVSX3("EF1_DT_CON", 05) , "EF1_DT_CON", AVSX3("EF1_DT_CON", 06), AVSX3("EF1_DT_CON", 03) , AVSX3("EF1_DT_CON", 04) , "" , NIL , AVSX3("EF1_DT_CON", 02) , NIL , NIL} ) // "Data"
      AAdd(aCabCon, { AVSX3("EF1_BAN_MO", 05) , "EF1_BAN_MO", AVSX3("EF1_BAN_MO", 06), AVSX3("EF1_BAN_MO", 03) , AVSX3("EF1_BAN_MO", 04) , "" , NIL , AVSX3("EF1_BAN_MO", 02) , NIL , NIL} ) // "Banco"
      AAdd(aCabCon, { AVSX3("EF1_AGENMO", 05) , "EF1_AGENMO", AVSX3("EF1_AGENMO", 06), AVSX3("EF1_AGENMO", 03) , AVSX3("EF1_AGENMO", 04) , "" , NIL , AVSX3("EF1_AGENMO", 02) , NIL , NIL} ) // "Agencia"
      AAdd(aCabCon, { AVSX3("EF1_NCONMO", 05) , "EF1_NCONMO", AVSX3("EF1_NCONMO", 06), AVSX3("EF1_NCONMO", 03) , AVSX3("EF1_NCONMO", 04) , "" , NIL , AVSX3("EF1_NCONMO", 02) , NIL , NIL} ) // "Conta"
      AAdd(aCabCon, { AVSX3("EF1_PRACA" , 05) , "EF1_PRACA" , AVSX3("EF1_PRACA" , 06), AVSX3("EF1_PRACA" , 03) , AVSX3("EF1_PRACA" , 04) , "" , NIL , AVSX3("EF1_PRACA" , 02) , NIL , NIL} ) // "Praca"
      AAdd(aCabCon, { AVSX3("EF1_MOEDA" , 05) , "EF1_MOEDA" , AVSX3("EF1_MOEDA" , 06), AVSX3("EF1_MOEDA" , 03) , AVSX3("EF1_MOEDA" , 04) , "" , NIL , AVSX3("EF1_MOEDA" , 02) , NIL , NIL} ) // "Moeda"
      AAdd(aCabCon, { STR0066                 , "EF3_VL_MOE", AVSX3("EF3_VL_MOE", 06), AVSX3("EF3_VL_MOE", 03) , AVSX3("EF3_VL_MOE", 04) , "" , NIL , AVSX3("EF3_VL_MOE", 02) , NIL , NIL} ) // "Valor Vinculado"
      AAdd(aCabCon, { STR0067                 , "EF3_VL_REA", AVSX3("EF3_VL_REA", 06), AVSX3("EF3_VL_REA", 03) , AVSX3("EF3_VL_REA", 04) , "" , NIL , AVSX3("EF3_VL_REA", 02) , NIL , NIL} ) // "Vl. Vinculado Reais"
      AAdd(aCabCon, { STR0068                 , "EF3_VL_MOE", AVSX3("EF3_VL_MOE", 06), AVSX3("EF3_VL_MOE", 03) , AVSX3("EF3_VL_MOE", 04) , "" , NIL , AVSX3("EF3_VL_MOE", 02) , NIL , NIL} ) // "Valor Pago"
      AAdd(aCabCon, { STR0069                 , "EF3_VL_REA", AVSX3("EF3_VL_REA", 06), AVSX3("EF3_VL_REA", 03) , AVSX3("EF3_VL_REA", 04) , "" , NIL , AVSX3("EF3_VL_REA", 02) , NIL , NIL} ) // "Vl. Pago Reais"


         Do While !EF1->(EOF()) .AND. EF1->EF1_FILIAL == xFilial("EFA") .AND. EF1->EF1_LINCRE == M->EFA_LINCRE

            AAdd( aColCon, Array( Len(aCabCon)+1 ) )

            // Contrato
            aColCon[Len(aColCon)][AScan(aCabCon,{|X|X[2]=="EF1_CONTRA"})] := EF1->EF1_CONTRA
            // Sequencia
            SX3->( DBSetOrder(2) )
            If SX3->( DBSeek("EF1_SEQCNT") )
               aColCon[Len(aColCon)][AScan(aCabCon,{|X|X[2]=="EF1_SEQCNT"})] := EF1->EF1_SEQCNT
            EndIf
            // Data do Contrato
            aColCon[Len(aColCon)][AScan(aCabCon,{|X|X[2]=="EF1_DT_CON"})] := EF1->EF1_DT_CON
            // Banco
            aColCon[Len(aColCon)][AScan(aCabCon,{|X|X[2]=="EF1_BAN_MO"})] := EF1->EF1_BAN_MO
            // Agencia
            aColCon[Len(aColCon)][AScan(aCabCon,{|X|X[2]=="EF1_AGENMO"})] := EF1->EF1_AGENMO
            // Conta
            aColCon[Len(aColCon)][AScan(aCabCon,{|X|X[2]=="EF1_NCONMO"})] := EF1->EF1_NCONMO
            // Praca
            aColCon[Len(aColCon)][AScan(aCabCon,{|X|X[2]=="EF1_PRACA"})] := EF1->EF1_PRACA
            // Moeda
            aColCon[Len(aColCon)][AScan(aCabCon,{|X|X[2]=="EF1_MOEDA"})] := EF1->EF1_MOEDA
            // Valor Já Vinculado
            nSecScan := AScan(aCabCon,{|X|X[2]=="EF3_VL_REA"})+1
            EF3->( DBSetOrder(1) )
            EF3->( DBSeek(xFilial("EF3")+EF1->EF1_TPMODU+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT) )
            Do While !EF3->( EOF() ) .And. EF3->EF3_FILIAL == EF1->EF1_FILIAL .And. EF3->EF3_TPMODU == EF1->EF1_TPMODU ;
                     .And. EF3->EF3_CONTRA == EF1->EF1_CONTRA .And. EF3->EF3_BAN_FI == EF1->EF1_BAN_FI ;
                     .And. EF3->EF3_PRACA == EF1->EF1_PRACA .And. EF3->EF3_SEQCNT == EF1->EF1_SEQCNT
               If EF3->EF3_CODEVE == "100"
                  aColCon[Len(aColCon)][AScan(aCabCon,{|X|X[2]=="EF3_VL_MOE"})] := EF3->EF3_VL_MOE
                  aColCon[Len(aColCon)][AScan(aCabCon,{|X|X[2]=="EF3_VL_REA"})] := EF3->EF3_VL_REA
               EndIf
               EF3->( DBSkip() )
            EndDo
            // Parcelas Pagas
            EF3->( DBSeek(xFilial("EF3")+EF1->EF1_TPMODU+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT) )
            aColCon[Len(aColCon)][AScan(aCabCon,{|X|X[2]=="EF3_VL_MOE"},nSecScan)] := 0
            aColCon[Len(aColCon)][AScan(aCabCon,{|X|X[2]=="EF3_VL_REA"},nSecScan)] := 0
            Do While !EF3->( EOF() ) .And. EF3->EF3_FILIAL == EF1->EF1_FILIAL .And. EF3->EF3_TPMODU == EF1->EF1_TPMODU ;
                     .And. EF3->EF3_CONTRA == EF1->EF1_CONTRA .And. EF3->EF3_BAN_FI == EF1->EF1_BAN_FI ;
                     .And. EF3->EF3_PRACA == EF1->EF1_PRACA .And. EF3->EF3_SEQCNT == EF1->EF1_SEQCNT
               If EF3->EF3_CODEVE == "700"  .And.  EF3->EF3_VL_REA > 0
                  aColCon[Len(aColCon)][AScan(aCabCon,{|X|X[2]=="EF3_VL_MOE"},nSecScan)] += EF3->EF3_VL_MOE
                  aColCon[Len(aColCon)][AScan(aCabCon,{|X|X[2]=="EF3_VL_REA"},nSecScan)] += EF3->EF3_VL_REA
               EndIf
               EF3->( DBSkip() )
            EndDo
            //Marca como não deletado
            aColCon[Len(aColCon)][Len(aCabCon)+1] := .F.

 	      	EF1->(DBSkip())
         EndDo

         DEFINE MSDIALOG oDlg3 TITLE STR0061 FROM oMainWnd:nTop + 150, oMainWnd:nLeft + 9 TO oMainWnd:nHeight-320, oMainWnd:nWidth-120 OF oMainWnd PIXEL // "Contratos Vinculados a Linha de Crédito"

         oGetMs2 := MsNewGetDados():New(66,1,150,(oDlg:nClientWidth-4)/2, 2,,,"",{},,1500,,,, oDlg3, aCabCon, aColCon)
         oGetMS2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
         oGetMS2:oBROWSE:bADD:={ || oGetMS2:LCHGFIELD := .F.}

         ACTIVATE MSDIALOG oDlg3 ON INIT EnchoiceBar(oDlg3,{||oDlg3:End()},{||oDlg3:End()},,) CENTERED

   End Sequence

Return lRet

*--------------------------------------------------------------------------------------------------------------------*
Function F3_EF8()
*--------------------------------------------------------------------------------------------------------------------*
Return (EC6_IDENTC="1000".Or.Empty(EC6_IDENTC)).And.(Type("cTipAl")=="U" .OR. Empty(cTipAl) .OR. IF(IF(cTipAl=="F",M->EF7_TP_FIN,If(cTipAl="M",cMod,If(cTipAl=="R",M->EF9_TP_ROF,"I")))=="E","FIEX","FIIM")+IF(cTipAl=="F",M->EF7_FINANC,If(cTipAl="M",M->EF1_TP_FIN,If(cTipAl=="R",M->EF9_FINANC,M->EFA_TP_FIN)))==EC6_TPMODU )

*--------------------------------------------------------------------------------------------------------------------*
Function F3_EF9()
*--------------------------------------------------------------------------------------------------------------------*
Return (AllTrim(EC6_IDENTC)=="1000" .Or. Empty(EC6_IDENTC) ) .And. ( IF(IF(cTipAl=="F",M->EF7_TP_FIN,If(cTipAl=="M",cMod,If(cTipAl=="R",M->EF9_TP_ROF,"I")))=="E","FIEX","FIIM")+IF(cTipAl=="F",M->EF7_FINANC,If(cTipAl=="M",M->EF1_TP_FIN,If(cTipAl=="R",M->EF9_FINANC,M->EFA_TP_FIN)))==EC6_TPMODU )

*--------------------------------------------------------------------------------------------------------------------*
Function FI400When(cCampo)
*--------------------------------------------------------------------------------------------------------------------*
Local lRet:=.T.

If cCampo == "EF8_TAXA" .or. cCampo == "EF8_VL_RS"
   If aCols[n][GDFieldPos("EF8_CARGA")] == "1"
      lRet := .F.
   Endif
EndIf

If cCampo == "EF8_PCT_RJ"
   If cLocal == "ENCHOICE"
      If M->EF8_TIP_EV == "1"  // Valor
         M->EF8_PCT_RJ := " "
         lRet := .F.
      EndIf
   Else
      If aCols[n][GDFieldPos("EF8_TIP_EV")] == "1"  // Valor
         aCols[n][GDFieldPos("EF8_PCT_RJ")] := " "
         oGetMS:oBrowse:Refresh()
         lRet := .F.
      EndIf
   Endif

EndIf

Return lRet

/*
Funcao     : MenuDef()
Parametros : cFuncao
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 23/01/07 - 14:48
*/
Static Function MenuDef(cOrigem)
Local aRotAdic := {}
Local aRotina := {}
Default cOrigem  := AvMnuFnc()

cOrigem := Upper(AllTrim(cOrigem))

Begin Sequence

   Do Case

      Case cOrigem $ "EFFAT110" // Inst. Financiadora
           aAdd(aRotina, { STR0002,"AxPesqui", 0 ,1}) //"Pesquisar"
           aAdd(aRotina, { STR0003,"AxVisual", 0 ,2}) //"Visualizar"
           aAdd(aRotina, { STR0004,"AxInclui", 0 ,3,1+nSUMACES}) //"Incluir"
           aAdd(aRotina, { STR0005,"AxAltera", 0 ,4,2+nSUMACES}) //"Alterar"
           aAdd(aRotina, { STR0006,"EvDeleta", 0 ,5,3+nSUMACES}) //"Excluir"

           // P.E. utilizado para adicionar itens no Menu da mBrowse
           If EasyEntryPoint("FAT110MNU")
	          aRotAdic := ExecBlock("FAT110MNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf

      Case cOrigem $ "EFFAC120" //Importador/Consg.
           aAdd(aRotina, { STR0002, "AxPesqui", 0 ,1} ) //"Pesquisar"
           aAdd(aRotina, { STR0003, "AxVisual", 0 ,2} ) //"Visualizar"
           aAdd(aRotina, { STR0004, "AxInclui", 0 ,3,36+nSUMACES} ) //"Incluir"
           aAdd(aRotina, { STR0005, "AxAltera", 0 ,4,37+nSUMACES} ) //"Alterar"
           aAdd(aRotina, { STR0006, "EvDeleta", 0 ,5,38+nSUMACES} ) //"Excluir"

           // P.E. utilizado para adicionar itens no Menu da mBrowse
           If EasyEntryPoint("FAC120MNU")
	          aRotAdic := ExecBlock("FAC120MNU",.f.,.f.)
              If ValType(aRotAdic) == "A"
		         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf

      Case cOrigem $ "EFFAC130" //Corretoras
           aAdd(aRotina, { STR0002,"AxPesqui", 0 ,1}) //"Pesquisar"
           aAdd(aRotina, { STR0003,"AxVisual", 0 ,2}) //"Visualizar"
           aAdd(aRotina, { STR0004,"AxInclui", 0 ,3,33+nSUMACES}) //"Incluir"
           aAdd(aRotina, { STR0005,"AxAltera", 0 ,4,34+nSUMACES}) //"Alterar"
           aAdd(aRotina, { STR0006,"EvDeleta", 0 ,5,35+nSUMACES}) //"Excluir"

           // P.E. utilizado para adicionar itens no Menu da mBrowse
           If EasyEntryPoint("FAC130MNU")
	          aRotAdic := ExecBlock("FAC130MNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf

      Case cOrigem $ "EFFAT140" // Cotação de Moedas
           Aadd(aRotina, { STR0002, "AxPesqui", 0 ,1}) //"Pesquisar"
           Aadd(aRotina, { STR0003, "AxVisual", 0 ,2}) //"Visualizar"
           Aadd(aRotina, { STR0004, "EFFAT140Manut", 0 ,3,30+nSUMACES}) //"Incluir"
           Aadd(aRotina, { STR0005, "EFFAT140Manut", 0 ,4,31+nSUMACES}) //"Alterar"
           Aadd(aRotina, { STR0006, "EvDeleta", 0 ,5,32+nSUMACES}) //"Excluir"

           // P.E. utilizado para adicionar itens no Menu da mBrowse
           If EasyEntryPoint("FAT140MNU")
	          aRotAdic := ExecBlock("FAT140MNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf

      Case cOrigem $ "EFFFI100" .Or. cOrigem $ "EFFRO100" .Or. cOrigem $ "EFFLC100"//Tipos de Financiamento, Rof ou Linha de Crédito
           aAdd(aRotina,{STR0002,"AxPesqui",0,1})  //"Pesquisar"
           aAdd(aRotina,{STR0003,"FI400Mstr",0,2}) //"Visualizar"
           aAdd(aRotina,{STR0004,"FI400Mstr",0,3}) //"Incluir"
           aAdd(aRotina,{STR0005,"FI400Mstr",0,4}) //"Alterar"
           aAdd(aRotina,{STR0006,"FI400Mstr",0,5}) //"Excluir"

           Do Case

              Case cOrigem == "EFFFI100"//Tipos de Financiamento
                   If EasyEntryPoint("FFI100MNU")
	                  aRotAdic := ExecBlock("FFI100MNU",.f.,.f.)
                   EndIf

              Case cOrigem == "EFFRO100"//ROF
                   If EasyEntryPoint("FRO100MNU")
	                  aRotAdic := ExecBlock("FRO100MNU",.f.,.f.)
                   EndIf

              Case cOrigem == "EFFLC100"//Linha de Crédito
                  If EasyEntryPoint("FLC100MNU")
	                 aRotAdic := ExecBlock("FLC100MNU",.f.,.f.)
	              EndIf
           End Case

           If ValType(aRotAdic) == "A"
              AEval(aRotAdic,{|x| AAdd(aRotina,x)})
           EndIf

      OtherWise
         aRotina := StaticCall(MATXATU,MENUDEF)
   End Case

End Sequence

Return aRotina


//TRP- 16/02/07 - Adiciona campos de usuário no Acols
Static Function AddAcols(aCols)

   aAdd(aCols[Len(aCols)], Nil)
   aIns(aCols[Len(aCols)], Len(aHeader) + 1)
   aCols[Len(aCols)][Len(aHeader) + 1] := If(nOpcGD == 3 .Or. EF8->( EOF() ), 0, EF8->(Recno()))

Return .T.


/*
Programa   : UPDX5CAD00()
Objetivo   : Carga para o SX5 chamada atraves do AvUpdate01
Retorno    : Nil
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora  : 20/07/2017
Revisao    :
*/
Static Function UPDX5CAD00(o)
Local nI

If IsInCallStack("FI400INI")

    o:TableStruct("SX5",{"X5_FILIAL"   ,"X5_TABELA","X5_CHAVE","X5_DESCRI"})
    For nI := 1 To Len(aUpdSX5)
      //o:TableStruct("SX5",{"X5_FILIAL"  , "X5_TABELA"   ,"X5_CHAVE"    ,"X5_DESCRI"  })
        o:TableData(  "SX5",{aUpdSX5[nI,1], aUpdSX5[nI,2] ,aUpdSX5[nI,3] ,aUpdSX5[nI,4]})
    Next

ElseIf IsInCallStack("FI400GRV")

    o:TableStruct("SX5",{"X5_FILIAL"   ,"X5_TABELA","X5_CHAVE"                                          , "X5_DESCRI"   })
    o:TableData(  "SX5",{xFilial("SX5"),"CJ"       ,IIF(M->EF7_TP_FIN=="I","FIIM","FIEX")+M->EF7_FINANC , M->EF7_DESCRI })

EndIf

Return
