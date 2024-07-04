#INCLUDE "EECCAD00.ch"
#INCLUDE "Average.ch"

#Define T_PESOS    "1" // Tela para definição de impressão de pesos.
#Define T_CAPITULO "2" // Tela para definição de impressão de capítulos.
//FSM - 08/10/2012
#define EV_EMBARQUE "600"
#define TIPO_MODULO "EXPORT"

/*
Programa : EECCAD00.PRW.
Objetivo : Agrupar todas funcoes de manipulacao de dados do SIGAEEC.
Autor    : Heder M Oliveira.
Data/Hora: 09/11/98.
Obs      :
*/
#include "EEC.CH"

Static lAddDet := .f.

/*
Funcao    : EECAT110()
Parametros: Nenhum
Objetivos : Manutencao de idiomas
Autor     : Heder M Oliveira
Data/Hora : 09/11/98 10:25
Revisao   :
Obs.      :
*/
Function EECAT110()
   Local lRet:=NIL,nOldAlias:=select()
   Private cCadastro:=AVTITCAD("EE1") //"Idiomas"
   Private aRotina := {  { STR0001,"AxPesqui"  , 0 , 1},; //"Pesquisar"
                         { STR0002,"AxVisual"  , 0 , 2},; //"Visualizar"
                         { STR0003,"AxInclui"  , 0 , 3},; //"Incluir"
                         { STR0004,"AxAltera"  , 0 , 4},; //"Alterar"
                         { STR0005,"AT110Del"  , 0 , 5,3} } //"Excluir"
   mBrowse( 6, 1,22,75,"EE1")
   dbselectarea(nOldAlias)
Return lRet

/*
Funcao    : AT110Del()
Parametros: Nenhum
Objetivos : Deletar idiomas
Autor     : Heder M Oliveira
Data/Hora : 09/11/98 10:27
Revisao   :
Obs.      : chamdada pela EECAT110()
*/
Function AT110DEL(cAlias,nReg,nOpc)
    Local lRet:=.T.,oDlg,nOpca
    Private aTELA[0][0],aGETS[0],cDELFUNC
    Begin Sequence
        EE4->(DBSETORDER(2))
        If EE4->(DBSEEK(EE1->EE1_FILIAL+EE1->EE1_IDIOMA))
            HELP(" ",1,"AVG0005016") //MSGINFO("Idioma possui lançamentos.")
            lRet:=.F.
            break
        EndIf

        nOpcA:=0

        RecLock(cAlias,.F.,.T.)

        DEFINE MSDIALOG oDlg TITLE cCadastro+STR0006 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //" - Exclusão"
            EnChoice( cAlias, nReg, nOpc,,,,,PosDlg(oDlg))
            nOpcA:= 1
        ACTIVATE MSDIALOG oDlg ON INIT ;
            EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()},.T.)

        If nOpcA == 2
            (cAlias)->(dbDelete())
            lRet:=.T.
        EndIf

        (cAlias)->(MsUnlock())

    End Sequence
    dbSelectArea(cAlias)
Return lRet

/*
Funcao    : EECAT140()
Parametros: Nenhum
Objetivos : Manutencao de cotacao de moedas
Autor     : Heder M Oliveira
Data/Hora : 10/11/98 12:00
Revisao   : 25/02/03 por TAN - Referente ao Financiamento da Exportação
Obs.      :
*/

Function EECAT140(xAutoCab,xAutoItens,nOpcExAuto)
Local lExcMVcAuto := .F.
//FSM - 04/01/2012 - *** Processamento via rotina automática (MsExecAuto).
Private lExecAuto := xAutoCab <> NIL
Private aAutoCab	:= xAutoCab
Private nOpcAuto := nOpcExAuto
// ***

If (lExcMVcAuto := !EasyCallMVC("MVC_EEC140AT",1)) .And. !lExecAuto

	Private aRotina := MenuDef(ProcName())
	Private cDelFunc := ".T.", cAlias:="SYE"
	Private cCadastro:= STR0151 //"Cadastro de Cotação de Moedas"
	Private cFilSYE := xFilial("SYE")

	// *** Processamento via rotina automática (MsExecAuto).
	lExecAuto := xAutoCab <> NIL //FSM - 09/10/2012
	//Private aAutoCab
	// ***

	SYE->(dbSetOrder(1))

	If !lExecAuto
		// *** Processamento via Interface.
		mBrowse( 6, 1,22,75,"SYE")
		// ***
	Else
		// *** Processamento via rotina automática (MsExecAuto).
		aAutoCab   := xAutoCab
		MBrowseAuto(nOpcAuto, xAutoCab, "SYE",, .T.)
        // ***
	EndIf

EndIf

Return
*---------------------------------------*
Function EECATManut(cAlias,nReg,nOpc)
*---------------------------------------*
Local nSelect := Select()
Local nOrder := SYE->(INDEXORD())
Local oDlg,nInc,nOp,bCancel := {||nOp:=0, If(!lExecAuto, oDlg:End(),) }
Local bVal_OK:={||(nOp:=1, If(!lExecAuto, oDlg:End(),) )}
Local aAlteraSye:= {}
Local aCamposSYE := {}
Local bOk := {||If(Obrigatorio(aGets,aTela) .and. EECATVAlid(nOpc), Eval(bVal_OK), )}
Local lIntERP:= IsIntEnable("001") .Or. EasyGParam("MV_EECFAT",, .F.)
Private aTela[0][0],aGets[0]
Private nOpcao := nOpc

If nOpc == INCLUIR
   dbSelectArea(cAlias)
   For nInc := 1 TO (cAlias)->(FCount())
      M->&(FIELDNAME(nInc)) := CRIAVAR(FIELDNAME(nInc))
   Next nInc
Else
   dbSelectArea(cAlias)
   For nInc := 1 TO (cAlias)->(FCount())
      M->&(FIELDNAME(nInc)) := FieldGet(nInc)
   Next nInc

   If nOpc = VISUALIZAR
      bVal_OK:={||oDlg:End()}
   EndIf
Endif

SX3->(DbSetOrder(1))
SX3->(DbSeek("SYE"))
SX3->(DbEval({|| aAdd(aCamposSYE, SX3->X3_CAMPO) },;
             {|| X3Uso(SX3->X3_USADO) },;
             {|| !Eof() .And. X3_ARQUIVO == "SYE" }))

aAlteraSye:= AClone(aCamposSYE)

If lIntErp //Integração com o SIGAFIN ou Faturamento
   aAdd(aCamposSYE, "YE_MOE_FIN")
EndIf

	If !lExecAuto

		DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

			EnChoice(cAlias,nReg,nOpc,,,,aCamposSYE,PosDlg(oDlg),aAlteraSye)

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOk,{||Eval(bCancel)},,)

	Else
		If lRet := EnchAuto(cAlias, aAutoCab, {|| Obrigatorio(aGets, aTela) }, nOpc, aCamposSYE)
		   Eval(bOk)
		Else
		   Eval(bCancel)
		EndIf
	EndIf

If nOp=1
    Begin Transaction
        If nOpc = EXCLUIR
            RecLock(cAlias,.F.,.T.)
            (cAlias)->(dbDelete())
            (cAlias)->(MsUnlock())
        ElseIf nOpc = INCLUIR  .Or. nOpc = ALTERAR
            MsAguarde( { || EECATGRV(nOpc) }, STR0152) //"Gravando Dados..."
        Endif

        If lIntERP .And. !At140GrvInt(nOpc = EXCLUIR)//Replica alterações na tabela SM2, quando integrado com o SIGAFIN ou SIGAFAT
            MsgInfo(STR0189, STR0126)//"Erro na gravação da taxa na tabela SM2."###"Aviso"
            While __lSX8
            RollBackSX8()
            Enddo
        EndIf
    End Transaction

    //ASK 16/08/2007
    If nOpc = INCLUIR .Or. nOpc = ALTERAR .Or. nOpc = EXCLUIR
        If EasyEntryPoint("EECCAD00")
            ExecBlock("EECCAD00",.F.,.F.,"APOS_GRAVA_SYE")
        Endif
    EndIf

Else
  Return
EndIf

(cAlias)->(dbsetorder(nOrder))

Select(nSelect)
Return NIL
*------------------------------*
Static Function EECATGRV(nOpc)
*------------------------------*
Local cFilECB:= xFilial("ECB"), i:=0

dbSelectArea("SYE")

ECB->(dbSetOrder(1))

SYE->(RecLock("SYE",If(nOpc=INCLUIR,.T.,.F.)))

FOR i := 1 TO FCount()
   SYE->&(FIELDNAME(i)) := M->&(FIELDNAME(i))
NEXT i

SYE->YE_FILIAL := xFilial("SYE")
SYE->(MSUnlock())

If EasyGParam("MV_ATUTX",,.F.) .and. (SYE->YE_VLCON_C+SYE->YE_TX_COMP) > 0
   If ! ECB->(dbSeek(cFilECB+DTOS(SYE->YE_DATA)+SYE->YE_MOEDA)) .or. ECB->ECB_TX_EXP = 0 .or. ECB->ECB_TX_CTB = 0
      ECB->(RecLock("ECB",ECB->(EOF())))
      ECB->ECB_FILIAL := xFilial("SYE")
      ECB->ECB_DATA   := SYE->YE_DATA
      ECB->ECB_MOEDA  := SYE->YE_MOEDA
      If ECB->ECB_TX_CTB = 0
         ECB->ECB_TX_CTB := SYE->YE_VLCON_C
      EndIF
      If ECB->ECB_TX_EXP = 0
         ECB->ECB_TX_EXP := SYE->YE_TX_COMP
      EndIf
      ECB->(MSUnlock())
   EndIF
Endif

If EasyEntryPoint("EECCAD00")
	ExecBlock("EECCAD00",.F.,.F.,"ATUALIZA_SM2")
Endif
Return .T.

*-----------------------------------------------------------------------------------------------*
Function EECATVAlid(nOpc,oMdl)
*-----------------------------------------------------------------------------------------------*
Local lRet:=.T.
Private lRetPE := .T.

Begin Sequence

    If nOpc = INCLUIR .Or. nOpc = ALTERAR .Or. nOpc = EXCLUIR
        If EasyEntryPoint("EECCAD00")
            ExecBlock("EECCAD00",.F.,.F.,{"VALID_GRV_SYE", nOpc})
        Endif

        If !lRetPE
            lRet := .F.
            Break
        EndIf

        If nOpc != EXCLUIR
            If IsInCallStack("easyautomvc") .And. ValType(oMdl) == "O"              //NCF - 20/09/2016
                If oMdl:GetModel():GetValue("EECP013_SYE", "YE_VLCON_C") = 0 .and. oMdl:GetModel():GetValue("EECP013_SYE", "YE_TX_COMP") = 0 .and. oMdl:GetModel():GetValue("EECP013_SYE", "YE_VLFISCA") = 0
                EasyHelp(STR0166)
                lRet:=.F.
                Break
                EndIf
            ElseIf M->YE_VLCON_C = 0 .and. M->YE_TX_COMP = 0 .and. M->YE_VLFISCA = 0
                MsgInfo(STR0166) //"Cotação não pode ser salva sem nenhuma taxa. Informe pelo menos uma taxa para cotação." //HELP("", 1, "AVG0005284")
                lRet:=.F.
                Break
            EndIf
            If !(lRet := At140ValInt(.T.))
                Break
            EndIf
        EndIf

    EndIf

End Sequence

Return lRet

/*
Funcao    : At140ValInt
Parametros: lGrava - Indica se a função foi chamada na gravação das taxas.
Objetivos : Validar a moeda correspondente na tabela SM2, quando o sistema estiver integrado com o módulo SIGAFIN
Autor     : Rodrigo Mendes Diaz
Data/Hora : 12/03/07
Obs.      :
*/
*---------------------------*
Function At140ValInt(lGrava)
*---------------------------*
Local lRet := .T.
Local lAutoTxMoeda := .F.
Local nTaxa:= 0
Local cEec0055 := AllTrim(EasyGParam("MV_EEC0055",,"")) //WHRS TE-4966 507485 / 506246 / MTRADE-607 - Cotação de moedas
Default lGrava     := .F.

Begin Sequence
   
   If ReadVar() == "M->YE_MOEDA"
      If !(AvgExistCpo('SYF',M->YE_MOEDA) .AND. ExistChav('SYE',DTOS(M->YE_DATA)+M->YE_MOEDA))
         lRet:= .F.
         Break
      EndIf
   EndIf

   If (nModulo == 29 .And. (IsIntEnable("001") .Or. EasyGParam("MV_EECFAT",,.F.))) .Or. (nModulo == 17 .And. (EasyGParam("MV_EASY",,"N") == "S" .Or. EasyGParam("MV_EASYFIN",,"N") == "S")) //RMD - Integração com os módulos SIGAFIN e SIGACTB //LRS - 09/09/2014
      //ISS - 22/10/10 - Incluso diversos tratamentos para inclusão e alteração da cotação de moedas.
      Do Case

         Case ReadVar() == "M->YE_MOEDA"

            //ISS - 24/02/11 - Validação para permitir a alteração da taxa da moeda cadastrada no EEC e no Financeiro.
            //DFS - 11/06/10 - Criado para preencher automaticamente o campo MOEDA no Cotação de Moedas do EEC quando houver integração com Financeiro
            //DFS - 11/06/10 - Para esta melhoria, necessário rodar o update UEMOEFIN.PRW
            M->YE_MOE_FIN := STR(Posicione("SYF", 1, xFilial("SYF") + M->YE_MOEDA, "YF_MOEFAT"), AVSX3('YE_MOE_FIN', 3))

            If Empty(Val(M->YE_MOE_FIN))
               MsgInfo(STR0195, STR0026)  //"Numero da moeda siga não cadastrado na tabela de moedas. Cadastre esta informação para prosseguir.","Aviso"
               lRet:= .F.
               Break
            EndIf

            If SM2->(DBSeek(M->YE_DATA))
               nTaxa:= RecMoeda(M->YE_DATA, M->YE_MOE_FIN)
            EndIf

            If !Empty(nTaxa)
			   lAutoTxMoeda:= (Type("lExecAuto") == "L" .And. lExecAuto) .Or. MsgYesNo(STR0204, STR0026) //Foi encontrada taxa para esta moeda no ERP. Deseja carregar esta cotação?, Aviso
			EndIf

            If lAutoTxMoeda
               M->YE_VLCON_C := nTaxa
            EndIf

         Otherwise

            M->YE_MOE_FIN := STR(Posicione("SYF", 1, xFilial("SYF") + M->YE_MOEDA, "YF_MOEFAT"), AVSX3('YE_MOE_FIN', 3))

            If (Empty(M->YE_MOE_FIN) .Or. Val(M->YE_MOE_FIN) == 0 ) .And. lGrava
               MsgInfo(STR0187, STR0026)//"Para ambientes com a integração com o módulo SigaFin habilitada é necessário informar a moeda correspondente no SigaFin."###"Aviso"
               lRet := .F.
            EndIf

            If lGrava .And. lRet
               If RecMoeda(M->YE_DATA, M->YE_MOE_FIN) <> M->YE_VLCON_C
               	if empty(cEec0055)
             			lRet:= (Type("lExecAuto") == "L" .And. lExecAuto) .Or. MsgYesNo(strtran(STR0193, "###", alltrim(Str(M->YE_VLCON_C))), STR0026) //"A taxa informada nesta cotação diverge da taxa informada no módulo financeiro. Ao confirmar esta gravação, a cotação informada no módulo financeiro será atualizada. Deseja prosseguir?"
             		elseIf Upper(cEec0055) == "S"
               		MsgInfo(STR0206,STR0026)
               	endIf
               EndIf
            EndIf

      End Case
   EndIf

End Sequence

Return lRet

/*
Funcao    : At140GrvInt
Parametros: lExclui - Indica se foi chamada a partir da exclusão de uma taxa
Objetivos : Sincronizar as taxas cadastradas na tabela SYE com as cadastradas na tabela SM2
Autor     : Rodrigo Mendes Diaz
Data/Hora : 12/03/07
Obs.      :
*/
*---------------------------*
Function At140GrvInt(lExclui)
*---------------------------*
Local lRet    := .T.
Local lAppend := .T.
Local cCpo    := ""
Local nInc
Local nTaxa   := If(EasyGParam("MV_EXP_TX",,"1") == "1", SYE->YE_VLCON_C, SYE->YE_TX_COMP)
Local cEec0055 := AllTrim(EasyGParam("MV_EEC0055",,"")) //WHRS TE-4966 507485 / 506246 / MTRADE-607 - Cotação de moedas

if(Upper(cEec0055)<>"N") //WHRS TE-4966 507485 / 506246 / MTRADE-607 - Cotação de moedas
	Begin Sequence
	   ChkFile("SM2")
	
	   If Select("SM2") == 0
	      lRet := .F.
	      Break
	   EndIf
	
	   If FieldPos("M2_MOEDA" + AllTrim(SYE->YE_MOE_FIN)) == 0
	      cCpo := "M2_MOEDA" + AllTrim(SYE->YE_MOE_FIN)
	   ElseIf FieldPos("M2_MOED" + AllTrim(SYE->YE_MOE_FIN)) == 0
	      cCpo := "M2_MOED" + AllTrim(SYE->YE_MOE_FIN)
	   EndIf
	   If Len(cCpo) == 0
	     lRet := .F.
	     Break
	   EndIf
	
	   If !SM2->(DbSeek(SYE->YE_DATA))
	      If lExclui
	         Break
	      EndIf
	   Else
	      lAppend := .F.
	   EndIf
	
	   SM2->(RecLock("SM2", lAppend))
	
	   If lExclui
	      Break
	   EndIf
	
	   SM2->M2_DATA       := SYE->YE_DATA
	   SM2->&(("SM2")->(cCpo)) := nTaxa
	   SM2->(MsUnLock())
	
	End Sequence
endIF

Return lRet

/*
Funcao    : EECAS110()
Parametros: Nenhum
Objetivos : Retornar a fun‡Æo AxCadastro("SJ7","Instituicoes Financeiras")
Autor     : Heder M Oliveira
Data/Hora : 24/09/98 11:10
Obs.      : Ver. os1117/98
*/
Function EECAS110()
    local lRet:=.T.,cOldArea:=select()
    Begin sequence
       AxCadastro("SJ7",AnsitoOem(STR0008)) //"Instituições Financeiras"
    Endsequence
    dbselectarea(cOldArea)
Return lRet

/*
Funcao    : EECAS115()
Parametros: Nenhum
Objetivos : Retornar a fun‡Æo AxCadastro("SJ6","Modalidades de Pagamento")
Autor     : Heder M Oliveira
Data/Hora : 17/09/98 09:19
Obs.      : Ver. os1075/98
*/
Function EECAS115()
    local lRet:=.T.,cOldArea:=select()
    Begin sequence
       AxCadastro("SJ6",STR0009) //"Modalidades de Pagamento"
    End sequence
    dbselectarea(cOldArea)
Return lRet

/*
Funcao    : EECAS125()
Parametros: Nenhum
Objetivos : Retornar a fun‡Æo AxCadastro("SAH","Unidades")
Autor     : Heder M Oliveira
Data/Hora : 13/11/98 11:56
Obs.      : Ver. os1075/98

Function EECAS125()
    local lRet:=.T.,cOldArea:=select()
    Begin sequence
        AxCadastro("SAH","Unidades")
    Endsequence
    dbselectarea(cOldArea)
Return lRet
*/

/*
Funcao    : EECAS130()
Parametros: Nenhum
Objetivos : Retornar a fun‡Æo AxCadastro("SJ5","Conversao de unidades")
Autor     : Heder M Oliveira
Data/Hora : 13/11/98 12:03
Obs.      : Ver. os1075/98
*/
Function EECAS130()
    local lRet:=.T.,cOldArea:=select()
    Begin sequence
       AxCadastro("SJ5",AnsitoOem(STR0010)) //"Conversão de Unidades"
    EndSequence
    dbselectarea(cOldArea)
Return lRet

/*
Funcao    : EECAS135()
Parametros: Nenhum
Objetivos : Retornar a fun‡Æo AxCadastro("SYJ","Incoterms")
Autor     : Heder M Oliveira
Data/Hora : 13/11/98 13:58
Obs.      : Ver. os1075/98
Revisão   : Clayton Fernandes - 29/03/2011
Obs       : Adaptação do Codigo para o padrão MVC
*/
Function EECAS135()
local lRet:=.T.,cOldArea:=select()
If !EasyCallMVC("MVC_AS135EEC",1) // CRF 21/03/2011
    Begin sequence
       AxCadastro("SYJ",STR0011,"INTEGREF('SYJ')") //"Incoterms"
    EndSequence
    dbselectarea(cOldArea)
EndIf
Return lRet

/*
Funcao      : AS135Desc()
Parametros  : Nenhum
Objetivos   : Retornar descricao de tipo de mensagem
Autor       : Heder M Oliveira
Data/Hora   : 13/11/98 16:15
Revisao     :
Obs         :
*/
Function AS135DCINC()
    Local lRet:=.T.,cOldArea:=select()
    Begin sequence
        M->YJ_DESCTIP:=Tabela("YA",M->YJ_TIPOINC)
    Endsequence
    dbselectarea(cOldArea)
Return lRet

/*
Funcao      : EECAS140()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Permitir manutencao em URF
Autor       : Heder M Oliveira
Data/Hora   : 03/12/98 11:14
Revisão     : Clayton Fernandes - 29/03/2011
Obs         : Adaptação do Codigo para o padrão MVC
*/
Function EECAS140()
Local lRet:=.T.,cOldArea:=select()
If !EasyCallMVC("MVC_AS140EEC",1) // CRF 21/03/2011
    Begin sequence
        AxCadastro("SJ0", STR0012, "IntegRef('SJ0')") //"U.R.F./Despacho"
    Endsequence
    dbselectarea(cOldArea)
EndIf
Return lRet


/*
Funcao          : EECAT160()
Parametros  :
Retorno     :
Objetivos   :
Autor       : Heder M Oliveira
Data/Hora   :
Revisão     : Clayton Fernandes - 29/03/2011
Obs         : Adaptação do Codigo para o padrão MVC
*/
Function EECAT160( )
Local lRet:=.T.,cOldArea:=select()

If !EasyCallMVC("MVC_EEC160AT",1) // CRF 16/03/2011
    Begin sequence
        AxCadastro("SY9",STR0013,"INTEGREF('SY9')") //"Origem/Destino"
    End sequence
    dbselectarea(cOldArea)
EndIf


Return lRet




/*
Funcao      : AT160DESC()
Parametros  : Nenhum
Objetivos   : Retornar descricao de tipo de mensagem
Autor       : Heder M Oliveira
Data/Hora   : 13/11/98 16:15
Revisao     :
Obs         :
*/
Function AT160DCTP()
    Local lRet:=.T.,cOldArea:=select()
    Begin sequence
        M->Y9_DESCLOC:=Tabela("YB",M->Y9_TIPOLOC)
    Endsequence
    dbselectarea(cOldArea)
Return lRet




/*
Funcao.....: EECAC135()
Parametros.: Nenhum
Retorno....: Nil
Objetivos..: Manutencao de Produto x Pais x Normas
Autor......: Alex Wallauer
Data/Hora..: 24/06/99 09:30
*/
/*
Function EECAC135( )

Local cOldArea:=select()
Private aMemos:={{"EEI_CDNO","EEI_VM_NOR"}}

AxCadastro("EEI",STR0014,,"AC135Valid(1)") //"N.C.M x Pais x Normas"
dbselectarea(cOldArea)

Return Nil

Function AC135Valid(cFlag)
local lRET:=.T.
IF cFlag == NIL
   IF (lRet:=NaoVazio()) .AND. (lRet:=ExistCpo("EEE",M->EEI_INSNEG,,1))
      EE1->(DBSETORDER(1))
      IF !EE1->(DBSEEK(xFilial()+"I"+M->EEI_PAIS+M->EEI_INSNEG))
         E_MSG(STR0015,1) //"Pais nÆo cadastrado para este Instrumento de Negocia‡Æo"
         // Alterado por Heder M Oliveira - 12/13/1999
         //lRET:=.F.
         //BREAK
      ENDIF
      EEE->(DBSEEK(xFilial()+M->EEI_INSNEG))
      M->EEI_INSNDE:=EEE->EEE_DCRED
      lRefresh:=.T.
   ENDIF

ELSEIF cFlag == 1

   IF (lRet:=ExistCpo("EEE",M->EEI_INSNEG,,1))
      EE1->(DBSETORDER(1))
      IF !EE1->(DBSEEK(xFilial()+"I"+M->EEI_PAIS+M->EEI_INSNEG))
         E_MSG(STR0015,1) //"Pais nÆo cadastrado para este Instrumento de Negocia‡Æo"
         // Alterado por Heder M Oliveira - 12/13/1999
         //lRET:=.F.
         //BREAK
      ENDIF
   ENDIF

ENDIF

Return lRet
*/

/*
Funcao      : EECAC170()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Manutencao de tipos de embaracoes
Autor       : Heder M Oliveira
Data/Hora   : 07/12/98 08:52
Revisao     :
Obs.        :
*/
Function EECAC170( )
    Local lRet:=.T.,cOldArea:=select()
    Private aMemos:={{"EE6_OBS","EE6_VM_OBS"}}
    Begin sequence
        AxCadastro("EE6",AnsitoOem(STR0016)) //"Embarcações"
    Endsequence
    dbselectarea(cOldArea)
Return lRet

/*
Funcao      : EECAF400
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Cadastro de Despesas
Autor       : Cristiano A. Ferreira
Data/Hora   : 23/09/1999 10:28
Revisão     : Clayton Fernandes - 29/03/2011
Obs         : Adaptação do Codigo para o padrão MVC
*/
Function EECAF400
LOCAL nOldArea:=Select()
lNAOALTERA := .T.
If !EasyCallMVC("MVC_EECAF400",1) // - CRF

PRIVATE aRotina := MenuDef(ProcName())
PRIVATE cCadastro := AVTITCAD("SYB"),; //"Cadastro de Despesas"
        lNAOALTERA := .T.
mBrowse( 6, 1,22,75,"SYB")

dbSelectArea(nOldArea)

EndIf

Return .T.

/*
Funcao      : AF400Manut
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Manutencao de Despesas (Inclusao/Aleracao)
Autor       : Cristiano A. Ferreira
Data/Hora   : 23/09/1999 10:28
Revisão     : Clayton Fernandes - 29/03/2011
Obs         : Adaptação do Codigo para o padrão MVC
*/
Function AF400Manut(cAlias,nReg,nOpc)
LOCAL aDesp:={ "MV_D_FRETE","MV_D_SEGUR","MV_D_II","MV_D_IPI","MV_D_ICMS" }
LOCAL lAchou, i:=0

IF nOpc = 3
   AxInclui(cAlias,nReg,nOpc,,,,"EA110Valid('YB_DESP')")
ELSE
   /*IF AT(LEFT(SYB->YB_DESP,1),'129T') <> 0*/
   IF AT(LEFT(SYB->YB_DESP,1),'12T') <> 0 //MCF - 27/04/2015 - Retirada validação das despesas que iniciam com 9.
      FOR I:=1 TO LEN(aDesp)
          lAchou:=.F.
          IF EasyGParam(aDesp[I]) == SYB->YB_DESP
             lAchou:=.T.
             EXIT
          ENDIF
      NEXT
      IF ! lAchou
         Help(" ",1,"A110TipInv")
         RETURN .F.
      ENDIF
   ENDIF

   AxAltera(cAlias,nReg,nOpc,,,,,"EA110Valid('YB_DESP')")
ENDIF

Return Nil

/*
Funcao      : AF400Deleta
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Manutencao de Despesas (Exclusao)
Autor       : Cristiano A. Ferreira
Data/Hora   : 23/09/1999 10:28
Revisao     :
Obs.        :
*/
FUNCTION AF400Deleta(cAlias,nReg,nOpc)
LOCAL nOpcA, oDlg

PRIVATE aTELA[0][0],aGETS[0]

/*
AMS - 05/04/2005. Consistência para Integridade Referencial.
*/
If !IntegRef("SYB")
   Return .F.
EndIf

IF LEFT(SYB->YB_DESP,1) == "1" .OR. LEFT(SYB->YB_DESP,1) == "2" .OR. LEFT(SYB->YB_DESP,1) == "9"
   Help(" ",1,"EIC110NDES")
   Return .F.
ENDIF

SWD->(dbSetOrder(2))
IF SWD->(dbSeek(xFilial()+SYB->YB_DESP))
   SWD->(dbSetOrder(1))
   Help(" ",1,"EIC110TDES")
   Return .F.
Endif
SWD->(dbSetOrder(1))

nOpcA:=0

RecLock(cAlias,.F.,.T.)

DEFINE MSDIALOG oDlg TITLE cCadastro+STR0006 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //" - Exclusão"
   oEnch1 := MsMGet():New( cAlias, nReg, nOpc,,,,,PosDlg(oDlg))
   oEnch1:oBox:Align := CONTROL_ALIGN_ALLCLIENT  //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
ACTIVATE MSDIALOG oDlg ON INIT ;
        (EnchoiceBar(oDlg,{|| nOpcA := 1,oDlg:End()},{|| nOpcA := 0,oDlg:End()})) //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

IF nOpcA == 1
   (cAlias)->(dbDelete())
   (cAlias)->(MsUnlock())
EndIf

dbSelectArea(cAlias)

Return NIL

/*
Funcao    : EECAS100()
Parametros: Nenhum
Objetivos : Manutencao de Enquadramento
Autor     : Heder M Oliveira
Data/Hora : 01/06/99 10:20
Revisao   : Clayton Fernandes - 21/03/2011
Obs.      : Inserção do If na Linda 719 para verificar se a Função para MVC está compilada
*/
Function EECAS100( )
Local lRet:=.T.,cOldArea:=select()
If !EasyCallMVC("MVC_AS100EEC",1) // - CRF
    Begin sequence
        AxCadastro("EED", AnsitoOem(STR0017), "IntegRef('EED')") //"Enquadramento da Operação"
    Endsequence
    dbselectarea(cOldArea)
EndIf
Return lRet

/*
Funcao    : EECAS101()
Parametros: Nenhum
Objetivos : Manutencao de Modalidade Pgto
Autor     : Heder M Oliveira
Data/Hora : 01/06/99 10:21
Revisão   : Clayton Fernandes - 29/03/2011
Obs       : Adaptação do Codigo para o padrão MVC
*/
Function EECAS101( )
Local lRet:=.T.,cOldArea:=select()
If !EasyCallMVC("MVC_AS101EEC",1) // - CRF
    Begin sequence
        AxCadastro("EEF", AnsitoOem(STR0018), "IntegRef('EEF')") //"Modalidade de Pagamento"
    Endsequence
    dbselectarea(cOldArea)
EndIf
Return lRet


/*
    Funcao   : EECAS150()
    Autor    : Heder M Oliveira
    Data     : 07/06/99 16:08
    Revisao  :
    Uso      : Manutencao SECEX
    Recebe   :
    Retorna  :
    Revisão  : Clayton Fernandes - 29/03/2011
    Obs      : Adaptação do Codigo para o padrão MVC

*/
Function EECAS150()
Local cAux := ""

If !EasyCallMVC("MVC_AS150EEC",1) // - CRF 22/03/2011
   cAux := AXCADASTRO("SJ9", ANSITOOEM(STR0019), "IntegRef('SJ9')" ) //"Agência SECEX"
//   Return AXCADASTRO("SJ9", ANSITOOEM(STR0019), "IntegRef('SJ9')" ) //"Agência SECEX"
EndIf

Return cAux

/*
    Funcao   : EMDES()
    Autor    : Heder M Oliveira
    Data     : 20/06/99 11:06
    Revisao  : 20/06/99 11:06
    Uso      : Evitar mensagem de erro em rotinas nao prontas
    Recebe   : VOID
    Retorna  : Mensagem

*/
Function EMDES()
   HELP(" ",1,"AVG0005012") //MSGSTOP("Rotina em desenvolvimento.","Atenção")
Return (.F.)

/*
    Funcao   : EECAS160()
    Autor    : Heder M Oliveira
    Data     : 20/06/99 18:10
    Revisao  : 20/06/99 18:10
    Uso      : Manutencao de Fundamento Legal
    Recebe   :
    Retorna  :
    Revisão  : Clayton Fernandes - 29/03/2011
    Obs      : Adaptação do Codigo para o padrão MVC

*/
Function EECAS160()
LOCAL lRET:=.T.,cOLDAREA:=ALIAS()
If !EasyCallMVC("MVC_AS160EEC",1) // - CRF 22/03/2011
   BEGIN SEQUENCE
        lRET:=AXCADASTRO("SY8",ANSITOOEM(STR0020)) //"Fundamento Legal x Regime Tributação"
    ENDSEQUENCE
    DBSELECTAREA(cOLDAREA)
EndIf
Return lRET


/*
    Funcao   : BUSCASA1IMPORT(cIMPORT,lREDUZIDO)
    Autor    : Heder M Oliveira
    Data     : 12/07/99 09:17
    Revisao  : 12/07/99 09:17
    Uso      : Descrição Importador/Cliente Exportação
    Recebe   : cIMPORT:=Cod+Loja do SA1
               lREDUZIDO:=se .T. (default) retorna nome reduzio, senao retorna nome extendido
    Retorna  : Descricao do importador/cliente no SA1
*/
Function BuscaSA1IMPORT(cIMPORT,lREDUZIDO)
    Local cRet:=STR0021 //"IMPORTADOR/CLIENTE NAO CADASTRADO"
    default lReduzido:=.T.,cIMPORT:=""
    BEGIN SEQUENCE
        SA1->( DBSETORDER(1))
        If SA1->(DBSEEK(xFilial("SA1")+cIMPORT))
            cRet:=if(lReduzido,SA1->A1_NREDUZ,SA1->A1_NOME)
        EndIf
    ENDSEQUENCE
Return cRet

/*
Funcao   : EECContato
Autor    : Cristiano A. Ferreira
Data     : 28/07/99 10:54
Uso      : SIGAEEC
Recebe   : cCadastro   := Codigo do Cadastro (EE3_CODCAD), vide EEC.CH
           cCodContato := Codigo do Contato (EE3_CONTAT)
           cCompl      := Complemento da Chave (opicional)
           cSeq        := Sequencia do contato
           nRet        := Nro do Retorno, se omitido retorna todo o array
           cContato    := Nome do Contato (opicional)
Retorna  : Retorna um array com 6 elementos:
           aRet[1] := Nome do Contato
           aRet[2] := Cargo
           aRet[3] := E-Mail
           aRet[4] := Telefone
           aRet[5] := ""
           aRet[6] := Departamento
           aRet[7] := Fax
*/
FUNCTION EECContato(cCadastro,cCodContato,cCompl,cSeq,nRet,cContato)

Local aRet[7]
Local aOrd := SaveOrd({"EE3"})
Local lFound := .f.,cALIAS,cCPORETT,cCPORETF
Local bChave := {|| "" }

Default cCompl := Space(0)
aFill(aRet,"")
cSeq := PadL(AllTrim(cSeq),AvSx3("EE3_SEQ",AV_TAMANHO),"0")

Begin Sequence

   IF Empty(cCodContato)
      Break
   Endif

   EE3->(dbSetOrder(1))

   IF ! Empty(cContato)
      EE3->(dbSeek(xFilial("EE3")+cCadastro+AVKEY(cCodContato,"EE3_CONTAT")+AVKey(cCompl,"EE3_COMPL")))

      While EE3->(!Eof() .And. EE3_FILIAL == xFilial("EE3")) .And. ;
           EE3->EE3_CONTAT+EE3->EE3_COMPL ==;
           AVKEY(cCodContato,"EE3_CONTAT")+AVKey(cCompl,"EE3_COMPL")
         IF ALLTRIM(cContato) = ALLTRIM(EE3->EE3_NOME)
            lFound := .T.
            Exit
         Endif
         EE3->(dbSkip())
      Enddo
   Endif

   IF !lFound
      lFound := EE3->(dbSeek(xFilial("EE3")+cCadastro+AVKEY(cCodContato,"EE3_CONTAT")+AVKey(cCompl,"EE3_COMPL")+AVKEY(cSeq,"EE3_SEQ")))
   Endif
   // Alterado por Heder M Oliveira - 10/27/1999
   //pesquisa fone e fax do cadastro ao qual pertence o contato se o ee3_fax
   //e/ou ee3_fone estiverem vazios

   DO CASE
      CASE cCADASTRO==CD_SA1
         cALIAS:="SA1"
         cCPORETT:="A1_TEL"
         cCPORETF:="A1_FAX"
         bChave := {|| AVKEY(cCodContato,"A1_COD")+AVKey(cCompl,"A1_LOJA") }
      CASE cCADASTRO==CD_SA2
         cALIAS:="SA2"
         cCPORETT:="A2_TEL"
         cCPORETF:="A2_FAX"
         bChave := {|| AVKEY(cCodContato,"A2_COD")+AVKey(cCompl,"A2_LOJA") }
      CASE cCADASTRO==CD_SA6
         cALIAS:="SA6"
         cCPORETT:="A6_TEL"
         cCPORETF:="A6_FAX"
         bChave := {|| AVKEY(cCodContato,"A6_COD")+AvKey(cCompl,"A6_AGENCIA") }
      CASE cCADASTRO==CD_SY5
         cALIAS:="SY5"
         cCPORETT:="Y5_FONE"
         cCPORETF:="Y5_FAX"
         bChave := {|| AVKEY(cCodContato,"Y5_COD") }
   END
   IF lFound
      aRet[1] := EE3->EE3_NOME
      aRet[2] := EE3->EE3_CARGO
      aRet[3] := EE3->EE3_EMAIL
      aRet[4] := IF(EMPTY(EE3->EE3_FONE),POSICIONE(cALIAS,1,xFilial(cAlias)+Eval(bChave),cCPORETT),;
                    EE3->EE3_FONE)
      // Alterado por Heder M Oliveira - 9/8/1999
      aRet[5] := "" //EE3->EE3_RAMAL nao existe mais este campo
      aRet[6] := EE3->EE3_DEPART
      // Alterado por Heder M Oliveira - 8/25/1999
      aRet[7] := IF(EMPTY(EE3->EE3_FAX),POSICIONE(cALIAS,1,xFilial(cAlias)+Eval(bChave),cCPORETF),;
                    EE3->EE3_FAX)
   Else
      aRet[1] := SPACE(LEN(EE3->EE3_NOME))
      aRet[2] := SPACE(LEN(EE3->EE3_CARGO))
      aRet[3] := SPACE(LEN(EE3->EE3_EMAIL))
      aRet[4] := POSICIONE(cALIAS,1,xFilial(cAlias)+Eval(bChave),cCPORETT)
      aRet[5] := "" //EE3->EE3_RAMAL nao existe mais este campo
      aRet[6] := SPACE(LEN(EE3->EE3_DEPART))
      aRet[7] := POSICIONE(cALIAS,1,xFilial(cAlias)+Eval(bChave),cCPORETF)
   Endif
End Sequence

RestOrd(aOrd)

Return if(nRet!=nil .AND. nRET<=LEN(aRET),aRet[nRet],aRet)


FUNCTION SY6Descricao(cCod,cIdioma,nLinha)

   Local nOrd := EE2->(IndexOrd()),aORD:=SAVEORD({"SY6"})
   Local nRec := EE2->(RecNo())
   Local nRet := ""
   Local cCodId   := UPPER(AvKey(EasyGParam("MV_AVG0035",,"PORT."),"X5_CHAVE"))

   DEFAULT cCod   :=""
   DEFAULT cIdioma:=""

   Private cSXBID := IncSpace(cCodId+"-"+Tabela("ID",cCodId),AVSX3("EE4_IDIOMA",AV_TAMANHO),.f.)

   EE2->(dbSetOrder(2))

   IF EE2->(dbSeek(xFilial()+MC_TCPG+TM_GER+AVKey(cCod,"EE2_COD")+AVKey(cIdioma,"EE2_IDIOMA")))
      IF nLinha == NIL
         nRet := MSMM(EE2->EE2_TEXTO,AVSX3("EE2_VM_TEX",AV_TAMANHO))
      ELSE
         nRet := MSMM(EE2->EE2_TEXTO,AVSX3("EE2_VM_TEX",AV_TAMANHO),nLinha)
      ENDIF
   ENDIF

   EE2->(dbSetOrder(nOrd))
   EE2->(dbGoTo(nRec))
   // Alterado por Heder M Oliveira - 11/11/1999
   IF ( EMPTY(nRET) .AND. cIDIOMA=cSXBID)
      SY6->(dbSetOrder(1))
      IF SY6->(dbSeek(xFilial("SY6")+cCod))
         IF nLinha == NIL
            nRet := MSMM(SY6->Y6_DESC_P,AVSX3("Y6_VM_DESP",AV_TAMANHO))
         ELSE
            nRet := MSMM(SY6->Y6_DESC_P,AVSX3("Y6_VM_DESP",AV_TAMANHO),nLinha)
         ENDIF
       ENDIF
   ENDIF
   RESTORD(aORD)
Return nRet

/*
Funcao      : ProcUsado(cProc)
Parametros  : cProc := Nro. do Processo
Retorno     : .T./.F.
Objetivos   : Verificar se o Processo foi usado em algum Embarque
Autor       : Cristiano A. Ferreira
Data/Hora   : 24/08/99 14:46
Revisao     :
Obs.        :
*/
Function ProcUsado(cProc)

Local nRecEE9 := EE9->(RecNo())
Local nOrdEE9 := EE9->(IndexOrd())
Local lUsado  := .f.

Begin Sequence

   EE9->(dbSetOrder(1))
   EE9->(dbSeek(xFilial()+cProc))

   While EE9->(!Eof()) .And. EE9->EE9_FILIAL == xFilial("EE9") .And.;
         EE9->EE9_PEDIDO == cProc


      IF EE9->EE9_STATUS != ST_PC
         lUsado := .t.
         Exit
      Endif

      EE9->(dbSkip())
      Loop
   Enddo

End Sequence

EE9->(dbSetOrder(nOrdEE9))
EE9->(dbGoTo(nRecEE9))

Return lUsado



/*
Funcao   : EEC_EXPFOR
Autor    : Cristiano A. Ferreira
Data     : 16/09/1999 09:17
Uso      : SIGAEEC
Recebe   : cProc := Numero do Processo
           cOnde := Alias para a pesquisa
Retorna  : Nome do Exportador/Fornecedor
*/
FUNCTION EEC_EXPFOR(cProc,cOnde)

Local cRet := ""
Local nOrdOld := (cOnde)->(IndexOrd())
Local nRecOld := (cOnde)->(RecNo())

Begin Sequence
   (cOnde)->(dbSetOrder(1))
   IF ! (cOnde)->(dbSeek(xFilial()+cProc))
      Break
   Endif

   IF !Empty(MemField("EXPORT",cALIAS))
      cRet := Posicione("SA2",1,xFilial("SA2")+MemField("EXPORT",cALIAS)+MemField("EXLOJA",cALIAS),"A2_NOME")
   Else
      cRet := Posicione("SA2",1,xFilial("SA2")+MemField("FORN",cALIAS)+MemField("FOLOJA",cALIAS),"A2_NOME")
   Endif
End Sequence

(cOnde)->(dbSetOrder(nOrdOld))
(cOnde)->(dbGoTo(nRecOld))

Return cRet

/*
Funcao   : EEC_IMPAGE
Autor    : Cristiano A. Ferreira
Data     : 16/09/1999 14:02
Uso      : SIGAEEC
Recebe   : cProc := Numero do Processo
           cOnde := Alias para a pesquisa
Retorna  : Nome do Agente Rec. Doc./Agente da Comissao/Importador
*/
FUNCTION EEC_IMPAGE(cProc,cOnde)

Local cRet := ""
Local nOrdOld := (cOnde)->(IndexOrd())
Local nRecOld := (cOnde)->(RecNo())
Local cId := IF(cOnde=="EE7",OC_PE,IF(cOnde=="EEC",OC_EM,""))
Local nRec := 0

Begin Sequence

   IF Empty(cId)
      Break
   Endif

   IF EEB->(dbSeek(xFilial()+cId+AVKey(cProc,"EEB_PEDIDO")))
      nRec := EEB->(RecNo())
      While EEB->(!Eof() .And. EEB_FILIAL == xFilial("EEB")) .And.;
            EEB->EEB_PEDIDO == AVKey(cProc,"EEB_PEDIDO") .And.;
            EEB->EEB_OCORRE == cId
         IF EEB->EEB_TIPOAG == CD_AGQ // Agente Recebedor Documentos
            nRec := 0
         Endif
         EEB->(dbSkip())
      Enddo

      IF !Empty(nRec)
         EEB->(dbGoTo(nRec))
         While EEB->(!Eof() .And. EEB_FILIAL == xFilial("EEB")) .And.;
            EEB->EEB_PEDIDO == AVKey(cProc,"EEB_PEDIDO") .And.;
            EEB->EEB_OCORRE == cId
            IF EEB->EEB_TIPOAG == CD_AGC // Agente Comissao
               cRec := 0
            Endif
            EEB->(dbSkip())
         Enddo
      Endif

      IF Empty(nRec)
         cRet := EEB->EEB_NOME
      Endif
   Endif

   IF Empty(cRet)
      (cOnde)->(dbSetOrder(1))
      IF ! (cOnde)->(dbSeek(xFilial()+cProc))
         Break
      Endif

      xRet := Posicione("SA1",1,xFilial("SA1")+MemField("IMPORT",cALIAS)+MemField("IMLOJA",cALIAS),"A1_NOME")
   Endif
End Sequence

(cOnde)->(dbSetOrder(nOrdOld))
(cOnde)->(dbGoTo(nRecOld))

Return cRet

/*
Funcao    : EECMENSAGEM()
Parametros:
Objetivos : Mensagens
Autor     : Alex Wallauer
Data/Hora : 01/10/99 10:15
Revisao   :
Obs.      :
*/
*----------------------------------------------------------------------------*
FUNCTION EECMensagem(cIdioma,cTipo,aPos,lComDialog,nCol,oFont,oDlgOri)
*----------------------------------------------------------------------------*
Local xRet := nil
LOCAL TB_Campos:={}, cAlias:=ALIAS(), I, oDlgMen, oMarkMen, cMensagem
LOCAL nVolta:=0, w:=0
LOCAL Struct1:= {  {"WKORDEM","C",05,0} ,;
                   {"WKOBS"  ,"M",10,0} ,;
                   {"WKOBS1" ,"C",50,0} }

Begin Sequence

   cIdioma:=ALLTRIM(cIdioma)
   lComDialog:=IF(lComDialog#NIL,lComDialog,.F.)

   If lComDialog
      Default oDlgOri := oMainWnd
   EndIf

   IF SELECT("Work_Men") = 0

      cFileMen := E_CriaTrab(, Struct1, "Work_Men")

      IF ! USED()
         HELP(" ",1,"AVG0005013") //MSGSTOP("N„o h   rea dispon¡vel para abertura do Cadastro de Work","Atençao")
         Return .F.
      ENDIF

      IndRegua("Work_Men",cFileMen+TEOrdBagExt(),"WKORDEM")

      DBSELECTAREA("EE4")
      EE4->(DBSETORDER(2))
      EE4->(DBSEEK(xFilial()+cIdioma))

      DO WHILE EE4->(!EOF()) .AND. xFilial("EE4")=EE4->EE4_FILIAL .AND. ALLTRIM(EE4->EE4_IDIOMA) = cIdioma

         IF !EMPTY(cTipo) .AND. cTipo # SUBSTR(EE4->EE4_TIPMEN,1,1)
            EE4->(DBSKIP())
            LOOP
         ENDIF

         cMensagem := MSMM(EE4->EE4_TEXTO,AVSX3("EE4_VM_TEX",AV_TAMANHO))

         Work_Men->(DBAPPEND())
         Work_Men->WKORDEM:='zzzzz'
         Work_Men->WKOBS  :=cMensagem
         Work_Men->WKOBS1 :=MEMOLINE(cMensagem,50)
         EE4->(DBSKIP())
      ENDDO

      IF WORK_MEN->(EasyReccount("WORK_MEN")) > 0 .And. nCol # Nil

         Work_Men->(DBGOTOP())

         DO WHILE !Work_Men->(EOF())
            Work_Men->(RecLock("Work_Men",.F.))
            Work_Men->WKOBS:=RTRIM(STRTRAN(Work_Men->WKOBS,CHR(13)+CHR(10)," "))
            nTotLin:=MLCOUNT(Work_Men->WKOBS,nCol)
            cMemo  :=""

            FOR W := 1 TO nTotLin
               If !EMPTY(MEMOLINE(Work_Men->WKOBS,nCol,W))
                  If W == nTotLin
                     cMemo+=MEMOLINE(Work_Men->WKOBS,nCol,W)
                  Else
                     cMemo+=AV_Justifica(MEMOLINE(Work_Men->WKOBS,nCol,W))+CHR(13)+CHR(10)
                  EndIf
               EndIf
            NEXT

            Work_Men->WKOBS:=cMemo
            Work_Men->(MsUnlock())
            Work_Men->(DBSKIP())

         ENDDO

      ENDIF

   ENDIF

   AADD(TB_Campos,{{||IF(WORK_MEN->WKORDEM='zzzzz','   ',WORK_MEN->WKORDEM)} ,,STR0022     }) //"Ordem"
   AADD(TB_Campos,{{||WORK_MEN->WKOBS1},,STR0023}) //"Observacao"

   DBSELECTAREA("Work_Men")
   DBGOTOP()

   IF lComDialog

      DO WHILE .T.

         nVolta:=0

         DEFINE MSDIALOG oDlgMen TITLE STR0024 From 7,0.5 TO 26,79.5 OF oDlgOri //"Ordem de Mensagens"

            oMarkMen:=MsSelect():New("Work_Men",,,TB_Campos,.T.,"X",{4,1,126,322})
            oMarkMen:bAval:={||nVolta:=1,oDlgMen:End()}

            DEFINE SBUTTON FROM 130,140 TYPE 1 ACTION (oDlgMen:End()) ENABLE OF oDlgMen PIXEL

         ACTIVATE MSDIALOG oDlgMen CENTERED

         IF nVolta=1
            OBSMar(oFont,oDlgMen)
            LOOP
         ENDIF
         EXIT
      ENDDO

   ELSE
       oMarkMen:=MsSelect():New("Work_Men",,,TB_CAMPOS,,,aPos,,,oDlgOri)
       oMarkMen:bAval:={||ObsMar(oFont,If(Type("oDlgOri") == "O",oDlgOri, oMainWnd)),oMarkMen:oBrowse:Refresh()}
       xRet := oMarkMen
   ENDIF
End Sequence

EE4->(DBSETORDER(1))
DBSELECTAREA(cAlias)

RETURN xRet

*----------------------------------------------------------------------------*
Static FUNCTION ObsMar(oFont,oDlgMen)
*----------------------------------------------------------------------------*
LOCAL oDlgObsMar, cOrdem:=Work_Men->WKORDEM
LOCAL nVolta:=0 , mMemo :=Work_Men->WKOBS, oFontMen
Local oBtnOk, oBtnCancel

IF cOrdem='zzzzz'
   cOrdem='     '
ENDIF

DEFINE MSDIALOG oDlgObsMar TITLE STR0024 From 7,0.5 TO 26,79.5 OF oDlgMen //"Ordem de Mensagens"

   @ 05,05 SAY STR0022       SIZE  30,10 OF oDlgObsMar PIXEL //"Ordem"
   @ 05,29 MSGET cOrdem      SIZE  35,10 OF oDlgObsMar PIXEL
   // @ 36,05 GET mMemo MEMO    SIZE 300,95 OF oDlgObsMar PIXEL HSCROLL FONT IF(oFont#NIL,oFont,oDlgObsMar:oFont)
   @ 20,05 GET mMemo MEMO    SIZE 300,105 OF oDlgObsMar PIXEL FONT IF(oFont#NIL,oFont,oDlgObsMar:oFont)

   DEFINE SBUTTON oBtnOk     FROM 130,246 TYPE 1 ACTION (nVolta:=1,oDlgObsMar:End()) ENABLE OF oDlgObsMar
   DEFINE SBUTTON oBtnCancel FROM 130,278 TYPE 2 ACTION (oDlgObsMar:End()) ENABLE OF oDlgObsMar

ACTIVATE MSDIALOG oDlgObsMar CENTERED //ON INIT ;
//         EnchoiceBar(oDlgObsMar,{||nVolta:=1,oDlgObsMar:End()},;
//                                {||oDlgObsMar:End()})

IF nVolta=1
   IF EMPTY(cOrdem)
      Work_Men->WKORDEM:='zzzzz'
   ELSE
      Work_Men->WKORDEM:=cOrdem
   ENDIF
   Work_Men->WKOBS:=mMemo
   Work_Men->WKOBS1:=MEMOLINE(mMemo,50)
ENDIF

RETURN NIL

/*
Funcao   : EEC_PAISEXIGE()
Autor    : Flavio Y. Arakaki
Data     : 08/10/1999 13:35
Uso      : SIGAEEC
Recebe   : cCodImp         : Codigo do Importador
           cLoja           : Loja do Importador
           cTipo do Acordo : Tipo do acordo a ser verificado
Retorna  : .T. se participa do acordo,.F. se nao participa
*/

FUNCTION EEC_PAISEXIGE(cCodImp,cLoja,cTipo)

Local aOrd := SaveOrd({"SA1","SYA"})
Local lRet := .F.

Begin Sequence
   SA1->(dbSetOrder(1))
   IF SA1->(dbSeek(xFilial()+AVKey(cCodImp,"A1_COD")+AVKey(cLoja,"A1_LOJA")))
      IF !EMPTY(SA1->A1_PAIS)
         SYA->(dbSetOrder(1))
         SYA->(dbSeek(xFilial()+SA1->A1_PAIS))
         Do Case
            Case cTipo = "1"
                 IF SYA->YA_MERCOSU $ cSim
                    lRet := .T.
                 ENDIF
            Case cTipo = "2"
                 IF SYA->YA_NALADI $ cSim
                    lRet := .T.
                 ENDIF
            Case cTipo = "3"
                 IF SYA->YA_ALADI $ cSim
                    lRet := .T.
                 ENDIF
            Case cTipo = "4"
                 IF SYA->YA_COMUM $ cSim
                    lRet := .T.
                 ENDIF
            Case cTipo = "5"
                 IF SYA->YA_SGPC $ cSim
                    lRet := .T.
                 ENDIF
         EndCase
      ENDIF
   ENDIF
End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao   : Pem04Val
Autor    : Cristiano A. Ferreira
Data     : 14/10/1999 15:02
Uso      : Validacao do relatorio solicitacao de inspecao
*/

FUNCTION PEM04Val(cCpo)

Local aOrd := SaveOrd("EEB",1)
Local cVar := "M->"+cCpo
Local lRet := .F., cEmpr

Begin Sequence

   IF Type(cVar) != "C"
      Break
   Endif

   cEmpr := AVKey(&cVar,"EEB_CODAGE")

   IF ! EEB->(dbSeek(xFilial()+AVKey(EEC->EEC_PREEMB,"EEB_PEDIDO")+OC_EM))
      MsgInfo(STR0025+EEC->EEC_PREEMB,STR0026) //"Não há empresa(s) cadastrada(s) para o embarque nro. "###"Aviso"
      Break
   Endif

   While EEB->(!Eof() .And. EEB_FILIAL==xFilial("EEB")) .And.;
        EEB->EEB_PEDIDO==EEC->EEC_PREEMB .And. EEB->EEB_OCORRE==OC_EM

      IF EEB->EEB_CODAGE == cEmpr
         lRet := .T.
         Exit
      Endif

      EEB->(dbSkip())
   Enddo

   IF !  lRet
      MsgInfo(STR0027+EEC->EEC_PREEMB,STR0026) //"Empresa não cadastrada para o embarque nro. "###"Aviso"
      Break
   Endif

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao   : BuscaEmpresa
Autor    : Cristiano A. Ferreira
Data     : 14/10/1999 17:01
Uso      : Pesquisa um tipo de empresa no EEB
*/
FUNCTION BuscaEmpresa(cPedido,cFase,cTipo)

Local aOrd := SaveOrd("EEB",1)
Local cRet := Space(AVSX3("EEB_NOME",AV_TAMANHO)), nRec := 0

Begin Sequence

   cPedido := AvKey(cPedido,"EEB_PEDIDO")
   cFase   := AvKey(cFase,"EEB_OCORRE")

   EEB->(dbSeek(xFilial()+cPedido+cFase))

   While EEB->(!Eof() .And. EEB_FILIAL == xFilial("EEB")) .And.;
         EEB->EEB_PEDIDO == cPedido .And. cFase == EEB->EEB_OCORRE


      IF Left(EEB->EEB_TIPOAG,1) == cTipo
         cRet := EEB->EEB_NOME
         nRec := EEB->(RecNo())
         Exit
      Endif

      EEB->(dbSkip())
   Enddo
End Sequence

RestOrd(aOrd)

IF nRec != 0 // ja deixa posicionado no EEB
   EEB->(dbGoTo(nRec))
Else
   // nao achou posiciona no fim de arquivo
   EEB->(dbGoBottom())
   EEB->(dbSkip())
Endif

Return cRet

/*
Funcao   : BuscaInst
Autor    : Cristiano A. Ferreira
Data     : 14/10/1999 17:01
Uso      : Pesquisa uma instituicao bancaria no EEJ
*/
FUNCTION BuscaInst(cPedido,cFase,cTipo)

Local aOrd := SaveOrd("EEJ",1)
Local cRet := "", nRec := 0

Begin Sequence

   cPedido := AvKey(cPedido,"EEJ_PEDIDO")
   cFase   := AvKey(cFase,"EEJ_OCORRE")

   EEJ->(dbSeek(xFilial()+cPedido+cFase))

   While EEJ->(!Eof() .And. EEJ_FILIAL == xFilial("EEJ")) .And.;
         EEJ->EEJ_PEDIDO == cPedido .And. cFase == EEJ->EEJ_OCORRE


      IF Left(EEJ->EEJ_TIPOBC,1) == cTipo
         cRet := EEJ->EEJ_NOME
         nRec := EEJ->(RecNo())
         Exit
      Endif

      EEJ->(dbSkip())
   Enddo
End Sequence

RestOrd(aOrd)

IF nRec != 0 // ja deixa posicionado no EEJ
   EEJ->(dbGoTo(nRec))
Else
   // nao achou posiciona no fim de arquivo
   EEJ->(dbGoBottom())
   EEJ->(dbSkip())
Endif

Return cRet

/*
Funcao   : RECDOCIM
Autor    : Heder M Oliveira
Data     : 27/09/99 14:22
Revisao  : 27/09/99 14:22
           Cristiano A. Ferreira 15/10/1999 07:05
Uso      : Recebedor documentos do importador
Retorna  :
// Alterado por Heder M Oliveira - 12/6/1999
*/
// Alterado por Cristiane de Campos Figueiredo - 12/29/1999
/*
FEITA SEPARACAO DE ESTADO/PAIS
*/
FUNCTION RecDocImp(cPedido,cFase,nRet)

Local aOrd := SaveOrd({"EEB","EEC","SY5","SA1"})
Local cRet, nRecEEB
Local cTo_Nome:="", cTo_Attn:="", cTo_Fax:="", cQuem:=""
Private cAlias :="", cENDER:="", cCOMPEND:=""

cFase := IF(Empty(cFase),OC_EM,Upper(cFase))
nRet  := IF(Empty(nRet),1,nRet)

IF cFase == OC_EM
   cAlias := "EEC"
Else
   cAlias := "EE7"
Endif

EEB->(dbSetOrder(1))
EEC->(dbSetOrder(1))
SY5->(dbSetOrder(1))
sa1->(dbSetOrder(1))

Begin Sequence
   //tentar 1. o agente recebedor documentos
   IF EEB->(dbSeek(xFilial("EEB")+AvKey(cPEDIDO,"EEB_PEDIDO")+AvKey(cFase,"EEB_OCORRE")))
      nRECEEB:=EEB->(RECNO())
      While EEB->(!Eof() .And. EEB_FILIAL == xFilial("EEB") .AND.;
                   EEB_PEDIDO==AvKey(cPEDIDO,"EEB_PEDIDO") .AND. EEB->EEB_OCORRE==AvKey(cFase,"EEB_OCORRE"))
         IF Left(EEB->EEB_TIPOAG,1) == "2" // Agente Recebedor Documentos
            cTO_NOME:=EEB->EEB_NOME
            cTO_ATTN:=EECCONTATO(CD_SY5,EEB->EEB_CODAGE,,"1",1) //nome do contato seq 1
            cTO_FAX :=EECCONTATO(CD_SY5,EEB->EEB_CODAGE,,"1",7) //fax do contato seq 1
            SY5->(dbSeek(xFilial()+EEB->EEB_CODAGE))
            IF Empty(cTo_Fax)
               cTo_Fax := SY5->Y5_FAX
            Endif
            cENDER  :=ALLTRIM(SY5->Y5_END)+IF(!EMPTY(SY5->Y5_BAIRRO),"-"+SY5->Y5_BAIRRO,"")
            cCOMPEND:=ALLTRIM(SY5->Y5_CIDADE)+IF(!EMPTY(SY5->Y5_EST),"-"+ALLTRIM(SY5->Y5_EST),"")+;
                      IF(!EMPTY(SY5->Y5_PAIS),"-"+POSICIONE("SYA",1,XFILIAL("SYA")+SY5->Y5_PAIS,"YA_NOIDIOM"),"")
            cQuem := "1" // Ag. Rec.Doc.
            Exit
         Endif
         EEB->(dbSkip())
      Enddo

      //se 1 falhou, 2 tentar agente comissao
      IF EMPTY(cTO_NOME)
         EEB->(DBGOTO(nRECEEB))
         While EEB->(!Eof() .And. EEB_FILIAL == xFilial("EEB") .AND.;
               EEB_PEDIDO==AvKey(cPEDIDO,"EEB_PEDIDO") .AND. EEB->EEB_OCORRE==AvKey(cFase,"EEB_OCORRE"))
            IF Left(EEB->EEB_TIPOAG,1) == "3" // Agente Comissao
               cTO_NOME:=EEB->EEB_NOME
               cTO_ATTN:=EECCONTATO(CD_SY5,EEB->EEB_CODAGE,,"1",1) //nome do contato seq 1
               cTO_FAX :=EECCONTATO(CD_SY5,EEB->EEB_CODAGE,,"1",7) //fax do contato seq 1
               SY5->(dbSeek(xFilial()+EEB->EEB_CODAGE))
               IF Empty(cTo_Fax)
                  cTo_Fax := SY5->Y5_FAX
               Endif
               cENDER  :=ALLTRIM(SY5->Y5_END)+IF(!EMPTY(SY5->Y5_BAIRRO),"-"+SY5->Y5_BAIRRO,"")
               cCOMPEND:=ALLTRIM(SY5->Y5_CIDADE)+IF(!EMPTY(SY5->Y5_EST),"-"+ALLTRIM(SY5->Y5_EST),"")+;
                         IF(!EMPTY(SY5->Y5_PAIS),"-"+POSICIONE("SYA",1,XFILIAL("SYA")+SY5->Y5_PAIS,"YA_NOIDIOM"),"")
               cQuem := "2" // Ag. Comissao
               Exit
            Endif
            EEB->(dbSkip())
         Enddo
      ENDIF
   ENDIF

   //se 2 falhou, 3 tentar importador
   IF EMPTY(cTO_NOME)
      (cAlias)->(dbSeek(xFilial()+AvKey(cPedido,IF(cFase==OC_EM,"EEC_PREEMB","EE7_PEDIDO"))))
      cTO_NOME := ArqField("IMPODE",cAlias) //nome importador no processo
      cTO_ATTN := EECCONTATO(CD_SA1,ArqField("IMPORT",cAlias),ArqField("IMLOJA",cAlias),"1",1) //nome do contato seq 1
      cTO_FAX  := EECCONTATO(CD_SA1,ArqField("IMPORT",cAlias),ArqField("IMLOJA",cAlias),"1",7) //fax do contato seq 1
      SA1->(dbSeek(xFilial()+ArqField("IMPORT",cAlias)+ArqField("IMLOJA",cAlias)))
      IF Empty(cTo_Fax)
         cTo_Fax := SA1->A1_FAX
      Endif
      cENDER  :=EECMEND("SA1",1,ArqField("IMPORT",cAlias)+ArqField("IMLOJA",cAlias),.T.,60,1)
      cCOMPEND:=EECMEND("SA1",1,ArqField("IMPORT",cAlias)+ArqField("IMLOJA",cAlias),.T.,60,2)
      cQuem := "3" // Import.
   ENDIF

   //TRP-06/06/2007
   If EasyEntryPoint("EECCAD00")
      ExecBlock("EECCAD00", .F., .F., {"ANTES_DO_CASE"})
   EndIf
   do Case
      Case nRet == 1
         cRet := cTo_Nome
      Case nRet == 2
         cRet := cTo_Attn
      Case nRet == 3
         cRet := cTo_Fax
      Case nRet == 4
         cRet := cQuem
      Case nRet == 5
         cRET := cENDER
      Case nRet == 6
         cRET := cCOMPEND
   OtherWise
      cRet := ""
   End Case

End Sequence

RestOrd(aOrd)

RETURN cRet

/*
    Funcao   : EECMARKS(cOCORRENCIA)
    Autor    : Heder M Oliveira
    Data     : 26/10/99 10:40
    Revisao  : 26/10/99 10:40
    Uso      : Gerar Marcacao
    Recebe   : cOCORRENCA:= onde ocorreu a chamada da funcao (P/E)
    Retorna  : texto da marcacao

*/
FUNCTION EECMARKS(cOCORRENCIA)
   Local cRET:="",nOLDAREA:=SELECT()
   Local aOrd := SaveOrd({"SY9","SYA","SA1","SA2"})
   Local cLoja := ""
   Private aKeyCli := {}

   IF ReadVar() == "M->EEC_CONSIG" .Or. ReadVar() == "M->EEC_COLOJA" //MCF - 21/12/2015
      aKeyCli := {"CONSIG","COLOJA"}
   Else
      aKeyCli := {"IMPORT","IMLOJA"}
   Endif

   BEGIN SEQUENCE
      cOcorrencia := Upper(cOcorrencia)
      IF ! (cOcorrencia $ OC_PE+OC_EM)
         HELP(" ",1,"AVG0005014") //MSGSTOP("Erro no parâmetro da função EECMARKS","Aviso")
         cRet := ""
         Break
      Endif
      cAlias := IF(cOcorrencia==OC_PE,"EE7","EEC")

      IF EasyEntryPoint("EECPEM38")
         aKeyCli := ExecBlock("EECPEM38",.F.,.F.)
         IF ValType(aKeyCli) <> "A" .Or. Len(aKeyCli) < 2
            aKeyCli := {"IMPORT","IMLOJA"}
         Endif
      Endif

      If !Empty( aKeyCli[1] ) //AMS - 03/09/2003 às 09:10.

         IF !Empty(MEMFIELD(aKeyCli[2],cALIAS)) //MCF - 21/12/2015
            cLoja := MEMFIELD(aKeyCli[2],cALIAS)
         Endif

         IF !Empty(MEMFIELD(aKeyCli[1],cALIAS)) /*.And. !Empty(MEMFIELD(aKeyCli[2],cALIAS))*/ .AND.;
            SA1->(DBSEEK(xFilial("SA1")+MEMFIELD(aKeyCli[1],cALIAS)+AvKey(cLoja,"A1_LOJA"))) .AND.;  //MFR 05/03/2020
            EMPTY(cRET:=MSMM(SA1->A1_CODMARC,AVSX3("A1_VM_MARC",AV_TAMANHO)))
             // Alterado por Heder M Oliveira - 10/26/1999
             SY9->(dbSetOrder(2))
             If !SY9->(dbSeek(xFilial("SY9")+MEMFIELD("DEST",cALIAS)))
                break
             EndIf   
             SYA->(dbSeek(xFilial("SYA")+SY9->Y9_PAIS)) //PORTO DO DESTINO
             
             cMemo:=""
             cMemo:=ALLTRIM(SA1->A1_NREDUZ)+CRLF
             cMemo:=cMemo+ALLTRIM(MEMFIELD("REFIMP",cALIAS))+CRLF
             cMemo:=cMemo+ALLTRIM(SY9->Y9_DESCR)+CRLF
             cMemo:=cMemo+ALLTRIM(SYA->YA_NOIDIOM)+CRLF

             IF !EMPTY(MEMFIELD("EXPORT",cALIAS))
                SA2->(DBSEEK(xFilial()+MEMFIELD("EXPORT",cALIAS)+MEMFIELD("EXLOJA",cALIAS)))
             Else
                SA2->(DBSEEK(xFilial()+MEMFIELD("FORN",cALIAS)+MEMFIELD("FOLOJA",cALIAS)))
             Endif

             SYA->(DBSEEK(xFilial()+SA2->A2_PAIS))

             cMemo:=cMemo+ALLTRIM(SYA->YA_NOIDIOM)+CRLF
             cMemo:=cMemo+ALLTRIM(SA2->A2_NREDUZ)

             //TRP - 31/08/2011 - Ponto de Entrada para limpar a variável cMemo e não gravar os campos EE7_MARCAC/EEC_MARCAC
             If EasyEntryPoint("EECCAD00")
                ExecBlock("EECCAD00",.F.,.F.,"MARKS")
             Endif

             cRET:=cMemo
         ENDIF

      EndIf

   END SEQUENCE
   RestOrd(aOrd)
   DBSELECTAREA(nOLDAREA)
RETURN cRET

/*
Funcao   : ExistEmbarq
Autor    : Cristiano A. Ferreira
Data     : 05/11/99 07:44
Revisao  :
Uso      : Verifica se o processo existe no EEC
Retorna  :
*/
FUNCTION ExistEmbarq(cPreEmb)

Local lRet := .f.
Local aOrd := SaveOrd("EEC",1)
Local nRec := 0

IF ValType(cPreEmb) = "U"
   cPreEmb := &(ReadVar())
Endif

EEC->(dbSetOrder(1))

Begin Sequence
   IF ! EEC->(dbSeek(xFilial()+AvKey(cPreEmb,"EEC_PREEMB")))
      Help(" ",1,"REGNOIS")
      Break
   Endif

   IF EEC->EEC_STATUS == ST_PC // Processo Cancelado
      Help(" ",1,"AVG0000075",,STR0028+TRANSF(DTOC(EEC->EEC_FIM_PE),"@d"),1,16) //"Cancelado em "
      Break
   Endif

   nRec := EEC->(RecNo())

   lRet := .T.
End Sequence

RestOrd(aOrd)

IF nRec > 0
   EEC->(dbGoTo(nRec))
Endif

Return lRet

/*
    Funcao   : EE3EMPRESA(cCODCAD,cCONTAT,cLOJA,cSEQ,nPOS)
    Autor    : Heder M Oliveira
    Data     : 01/12/99 17:05
    Revisao  : 01/12/99 17:05
    Uso      : Retornar vetor com nome da Empresa/Fabr/Forn...
                                  telefone
                                  fax
    Recebe   :
    Retorna  :

*/
FUNCTION EE3EMPRESA(cCODCAD,cCONTAT,cCompl,cSEQ,nPOS)
   LOCAL aRET:=ARRAY(3),nOLDAREA:=SELECT()

   DEFAULT cCODCAD := EE3->EE3_CODCAD
   DEFAULT cCONTAT := EE3->EE3_CONTAT
   DEFAULT cCompl  := EE3->EE3_COMPL
   DEFAULT cSEQ    := EE3->EE3_SEQ
   DEFAULT nPOS    := 1 //retornar nome como default

   cCODCAD := AvKey(cCODCAD,"EE3_CODCAD")
   aRET    := AFILL(aRET,"")
   BEGIN SEQUENCE
      DO CASE
         CASE cCODCAD == CD_SA1 //  "I"     //importador/distribuidor/cliente //IMP
            cCONTAT := AvKey(cCONTAT,"A1_COD")
            cCompl  := AvKey(cCompl,"A1_LOJA")
            aRET[1]:=POSICIONE("SA1",1,XFILIAL("SA1")+cCONTAT+cCompl,"A1_NOME")
            aRET[2]:=POSICIONE("SA1",1,XFILIAL("SA1")+cCONTAT+cCompl,"A1_TEL")
            aRET[3]:=POSICIONE("SA1",1,XFILIAL("SA1")+cCONTAT+cCompl,"A1_FAX")
         CASE cCODCAD == CD_SA2 // "X"     //exportador/fornecedor/fabricante
            cCONTAT := AvKey(cCONTAT,"A2_COD")
            cCompl  := AvKey(cCompl,"A2_LOJA")
            aRET[1]:=POSICIONE("SA2",1,XFILIAL("SA2")+cCONTAT+cCompl,"A2_NOME")
            aRET[2]:=POSICIONE("SA2",1,XFILIAL("SA2")+cCONTAT+cCompl,"A2_TEL")
            aRET[3]:=POSICIONE("SA2",1,XFILIAL("SA2")+cCONTAT+cCompl,"A2_FAX")
         CASE cCODCAD == CD_SA6 // "B"     //Bancos SA6 //BCO
            cCONTAT := AvKey(cCONTAT,"A6_COD")
            cCompl  := AvKey(cCompl,"A6_AGENCIA")
            aRET[1]:=POSICIONE("SA6",1,XFILIAL("SA6")+cCONTAT+cCompl,"A6_NOME")
            aRET[2]:=POSICIONE("SA6",1,XFILIAL("SA6")+cCONTAT+cCompl,"A6_TEL")
            aRET[3]:=POSICIONE("SA6",1,XFILIAL("SA6")+cCONTAT+cCompl,"A6_FAX")
         CASE cCODCAD == CD_SY5 // "E"     //EMPRESAS
            cCONTAT := AvKey(cCONTAT,"Y5_COD")
            aRET[1]:=POSICIONE("SY5",1,XFILIAL("SY5")+cCONTAT,"Y5_NOME")
            aRET[2]:=POSICIONE("SY5",1,XFILIAL("SY5")+cCONTAT,"Y5_FONE")
            aRET[3]:=POSICIONE("SY5",1,XFILIAL("SY5")+cCONTAT,"Y5_FAX")
      ENDCASE
      IF nPos != 0
         aRet := aRet[nPos]
      Endif
   END SEQUENCE
   DBSELECTAREA(nOLDAREA)
RETURN aRET


/*
    Funcao   : EECSREM(cCampo,nTam)
    Autor    : Regina H Perez
    Data     : 30/12/99 10:05
    Revisao  : 30/12/99 10:05
    Uso      : Retornar um array com linhas de um memo
    Recebe   : Nome do Campo que contem o codigo do memo , o tamanho da linha
    Retorna  : Array onde cada elemento e uma linha do campo memo
// Alterado por Heder M Oliveira - 1/4/2000
*/
FUNCTION EECSREM(cCampo,nTam)
LOCAL aObs := {}
LOCAL nLinhas, i:=0
DEFAULT cCampo := EEC->EEC_CODOBP
DEFAULT nTam := AVSX3("EEC_OBSPED",3)
nLinhas := MLCOUNT(ALLTRIM(MSMM(cCampo,ntam)))
FOR I:=1 TO nLinhas
  IF ! EMPTY(ALLTRIM(MSMM(cCampo,nTam,I)))
    AADD(aObs,ALLTRIM(MSMM(cCampo,nTam,I)))
  ENDIF
NEXT
RETURN aObs

/*
    Funcao   : DICIDMES(aDICIDMES)
    Autor    : Heder M Oliveira
    Data     : 03/01/2000
    Revisao  : 03/01/2000
    Uso      : Dicionario de meses
    Recebe   : aDICIDMES[1]=IDIOMA
               aDICIDMES[1]=DATA
               aDICIDMES[1]=LOGICAL (SE .T. RETORNA DIAMESANO, SENAO MES)
    Retorna  :

*/
FUNCTION DICIDMES(aDICIDMES)
   LOCAL cRET:=""
   LOCAL aMESESP := {"","ENERO","FEBRERO","MARZO","ABRIL","MAYO","JUNIO","JULIO","AGOSTO","SEPTIEMBRE","OCTUBRE","NOVIEMBRE","DICIEMBRE"}
   BEGIN SEQUENCE
      IF ( LEN(aDICIDMES)<2 ) //NO MINIMO DOIS PARAMETROS
         BREAK
      ENDIF
      aDICIDMES[1]:=UPPER(ALLTRIM(aDICIDMES[1])) //MELHOR PREVINIR DO QUE REMEDIAR
      DO CASE
         CASE EasyGParam("MV_AVG0037",,"INGLES") $ aDICIDMES[1]
            cRET:=cMONTH(aDICIDMES[2])
         CASE "CAST." $ aDICIDMES[1] .OR. "ESP." $ aDICIDMES[1]
            cRET:=aMESESP[MONTH(aDICIDMES[2])+1]
         CASE EasyGParam("MV_AVG0035",,"PORT.") $ aDICIDMES[1]
            cRET:=MESEXTENSO(MONTH(aDICIDMES[2]))
      END
   END SEQUENCE
RETURN cRET

/*
    Funcao   : EECPORTO(cCampo,lPais)
    Autor    : Cristiane Campos Figueiredo
    Data     : 26/04/00 09:45
    Uso      : Retornar o nome do porto e o pais
    Autor    : Cristiane
    Data/Hora: 26/04/00
    Recebe   : Nome do Campo que contem a sigla de Origem ou Destino referente ao Porto, e True ou False
               para retornar o Pais ou nao
    Retorna  : A descricao que consta no Cadastro de Portos e a Descrição do Pais se necessario

*/
// Alterado por Heder M Oliveira - 4/26/2000
FUNCTION EECPORTO(cCampo,lPais)
LOCAL cDescPor:= Alltrim(Posicione("SY9",2,xFilial("SY9")+cCampo,"Y9_DESCR"))
LOCAL cPais   := ALLTRIM(Posicione("SYA",1,xFilial("SY9")+Posicione("SY9",2,xFilial("SY9")+cCampo,"Y9_PAIS"),"YA_DESCR"))
local aOrd:=SaveOrd({"SY9","SYA"})
DEFAULT lPAIS:=.T.
BEGIN SEQUENCE
   If lPais .AND. !EMPTY(cPAIS)
      cDescPor := cDescPor + " / " + Alltrim(cPais)
   Endif
END SEQUENCE
RestOrd(aOrd,.T.)
RETURN cDescPor

/*
Funcao    : AVBAR(nOpc,oDlg,bOk,bCancel,nMODELO,bIMPR)
Parametros: nOPC := no. opcao enviado pela aRotina
            oDLG := dialogo onde que tera e enchoice bar
            bOK  := code block para o botao ok
            bCANCEL := code block para o botao cancel
            nMODELO := modelo de enchoice (ver EEC.CH)
            bManut := Visualizacao/Inclusao/Alteracao/Exclusao
            bIMPR := Impressao - se modelo for com impressao, passar code block
Retorno   : Enchoicebar com botoes extras
Objetivos : Retornar a EnchoiceBar com botoes de visualizacao ou
            alteracao,inclusao e exclusao
Uso       : SIGAEEC
Autor     : Heder M Oliveira
Data/Hora : 11/04/00 15:24
Revisao   : Cristiano A. Ferreira 19/04/2000 16:56
Obs.      :
*/
Function AVBAR(nOpc,oDlg,bOk,bCancel,nMODELO,bManut,bIMPR,aButtonsNF)
   local nRet:=VIS_DET,aBUTTONS:={}
   Private lEditButtons := .T.//RMD - 23/11/12 - Para permitir desabilitar via ponto de entrada.

   DEFAULT nMODELO:=ENCH_PDR, bManut := {||.t.}, bIMPR := {||.t.}

   //RMD - 23/11/12 - Permite desabilitar botões de manutenção.
   If EasyEntryPoint("EECCAD00")
      ExecBlock("EECCAD00",.F.,.F.,"AVBAR")
   EndIf

   If aButtonsNF <> NIL
      AEVAL(aButtonsNF,{|botao|AAdd(aButtons,botao)})
   Endif
   BEGIN SEQUENCE
      IF nMODELO==ENCH_PDI .OR.nMODELO==ENCH_ADI
         aAdd(aButtons,{"IMPRESSAO",bIMPR,STR0029}) //"Imprimir"
      ENDIF
      DO CASE
         CASE nMODELO==ENCH_ADD .OR. nMODELO==ENCH_ADI
            If STR(nOpc,1) $ STR(VISUALIZAR,1)+STR(EXCLUIR,1)
               aAdd(aButtons,{"BMPVISUAL" /*"ANALITICO"*/,{||Eval(bManut,VIS_DET)},STR0002}) //"Visualizar"
            ElseIf lEditButtons //RMD - 23/11/12
               aAdd(aButtons,{"BMPINCLUIR" /*"EDIT"*/,{||Eval(bManut,INC_DET)},STR0003})       //"Incluir"
               aAdd(aButtons,{"EDIT" /*"ALT_CAD"*/   ,{||Eval(bManut,ALT_DET)},STR0004})       //"Alterar"
               aAdd(aButtons,{"EXCLUIR",{||Eval(bManut,EXC_DET)},STR0005})       //"Excluir"
            EndIf
            EnchoiceBar(oDlg,bOk,bCancel,,aBUTTONS)
         CASE nMODELO==ENCH_PDI
            EnchoiceBar(oDlg,bOk,bCancel,,aBUTTONS)
         CASE nMODELO==ENCH_PDR
            EnchoiceBar(oDlg,bOk,bCancel)
      ENDCASE
   END SEQUENCE
RETURN nRET

/*
Funcao      : EE2Manut(nOpc,cCodCad,cModelo,cAction,aParam)
Parametros  : nOpc    := Nro. da opcao enviada pela aRotina
              cCodCad := Codigo do Cadastro no EE2
              cModelo := MO_DS - Descricao Simples
                         MO_MM - Campo Memo
                         MO_SP - Descricao no Sigular e no Plural
              cAction := AC_WK (Criar/Gravar Work)
                         AC_MS (Criar MsSelect)
                         AC_IN (Criar Botoes - on init)
                         AC_GR (Gravar dados do work no EE2)
                         AC_DE (Excluir dados do EE2)
                         AC_ER (Fecha/Apaga o Work)
              aParam  := se cAction = AC_WK
                            aParam[1] := cCod - Codigo do Registro
                         se cAction = AC_MS
                            aParam[1] := oDlg - Janela da MsSelect
                            aParam[2] := cCod
                         se cAction = AC_IN
                            (Parametros passado para a EnchoiceBar)
                            aParam[1] := oDlg
                            aParam[2] := bOk
                            aParam[3] := bCancel
                            aParam[4] := cCod
                            aParam[5] := aButtons
                         se cAction = AC_GR
                            aParam[1] := cCod - Codigo do Registro
                         se cAction = AC_DE
                            aParam[1] := cCod - Codigo do Registro
                         se cAction = AC_ER
                            Nao Usado
                         se cAction = "EXECAUTO"
                         	aParam[1] := cCod
                         	aParam[2] := aAutoCab
Retorno     : NIL
Objetivos   : Manutencao de Descricao em varios Idiomas
Autor       : Cristiano A. Ferreira
Data/Hora   : 11/04/2000 17:23
Revisao     :
Obs.        :
*/
Function EE2Manut(nOpc,cCodCad,cModelo,cAction,aParam)
Local aArea := getArea()
Local aOrd := SaveOrd("EE2",2)
Local aCpos, cCod, i := 0
Local nOrdEE2
Local nRecEE2

Private aBtn //FDR - 25/02/13

Static oBrw, aDelEE2 := {}

Begin Sequence

   dbSelectArea("EE2")

   // ** By JBJ - 03/06/03 - 15:43.
   If Type("lAbriuExp") = "U"
      lAbriuExp := .f.
   EndIf

   // *** Verificar integridade dos parametros ...
   IF cAction <> AC_WK
      IF Select("Temp_EE2") <= 0
         MsgStop(STR0030+CRLF+; //"Primeiro deve ser executada a rotina EE2Manut com (cAction = AC_WK) !"
                 STR0031+ProcName(1)+CRLF+; //"Rotina: "
                 STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
         Break
      Endif
   Else
      IF Select("Temp_EE2") > 0
         MsgStop(STR0033+CRLF+; //"Alias Temp_EE2 já esta em uso !"
                 STR0031+ProcName(1)+CRLF+; //"Rotina: "
                 STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
         Break
      Endif
   Endif

   IF cAction <> AC_ER
      IF ValType(aParam) <> "A"
         MsgStop(STR0034+CRLF+; //"Função: EE2Manut, cAction <> AC_ER"
                 STR0035+CRLF+; //"O quinto parametro (aParam) é obrigatório !"
                 STR0031+ProcName(1)+CRLF+; //"Rotina: "
                 STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
         Break
      Endif
   Endif
   // ***

   do Case
      Case cAction == AC_WK // Criar/Gravar Work

         // *** Verificar integridade dos parametros ...
         IF Len(aParam) < 1 .Or. ValType(aParam[1]) <> "C"
            MsgStop(STR0036+CRLF+; //"Função: EE2Manut, cAction = AC_WK"
                    STR0037+CRLF+; //"O quinto parametro (aParam[1] = cCod) invalido !"
                    STR0031+ProcName(1)+CRLF+; //"Rotina: "
                    STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
            Break
         Endif
         // ***

         aDelEE2 := aSize(aDelEE2,0)
         oBrw    := Nil

         // Cria Arquivo de Trabalho
         Private aCampos := Array(EE2->(FCount()))
         Private aHeader[0]
         aSemSX3:= {{"EE2_RECNO","N",7,0}}
         //TRP - 25/01/07 - Campos do WalkThru
         AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
         AADD(aSemSX3,{"TRB_REC_WT","N",10,0})

         // GFP - 05/12/2011
         AADD(aSemSX3,{"EE2_DESC_S",AvSX3("EE2_DESC_S",AV_TIPO),AvSX3("EE2_DESC_S",AV_TAMANHO),AvSX3("EE2_DESC_S",AV_DECIMAL)})
         AADD(aSemSX3,{"EE2_DESC_P",AvSX3("EE2_DESC_P",AV_TIPO),AvSX3("EE2_DESC_P",AV_TAMANHO),AvSX3("EE2_DESC_P",AV_DECIMAL)})
         AADD(aSemSX3,{"EE2_IDIOMA",AvSX3("EE2_IDIOMA",AV_TIPO),AvSX3("EE2_IDIOMA",AV_TAMANHO),AvSX3("EE2_IDIOMA",AV_DECIMAL)})

         //FDR - 21/03/13
         IF EasyEntryPoint("EECCAD00")
            EXECBLOCK("EECCAD00",.F.,.F.,{"WORK_EE2"})
         ENDIF
         aAdd(aSemSX3,{"DBDELETE","L",1,0}) //THTS - 31/10/2017 - Este campo deve sempre ser o ultimo campo da Work
         cNomArq := E_CriaTrab("EE2",aSemSX3,"Temp_EE2")
         IndRegua("Temp_EE2",cNomArq+TEOrdBagExt(),"EE2_IDIOMA")

         IF nOpc <> INCLUIR
            ProcRegua(3)
            CursorWait()
            // Carrega dados do EE2 para o Work
            cCod := AvKey(aParam[1],"EE2_COD")
            EE2->(DbSetOrder(2))
            EE2->(dbSeek(xFilial()+cCodCad+TM_GER+cCod))

            //TDF - 02/09/10
            While EE2->(!Eof()) .And.;
                  EE2->EE2_FILIAL == xFilial("EE2") .And.;
                  EE2->EE2_CODCAD == cCodCad        .And.;
                  EE2->EE2_TIPMEN == TM_GER         .And.;
                  Alltrim(EE2->EE2_COD) == Alltrim(cCod)

               IncProc()
               i++

               Temp_EE2->(dbAppend())
               AvReplace("EE2","Temp_EE2")

               Temp_EE2->EE2_RECNO := EE2->(RecNo())
               Temp_EE2->TRB_ALI_WT:= "EE2"
               Temp_EE2->TRB_REC_WT:= EE2->(Recno())

               IF cModelo == MO_MM // Campo Memo
                  Temp_EE2->EE2_VM_TEX := If(lAbriuExp, MSMM_DR(EE2->EE2_TEXTO,AVSX3("EE2_VM_TEX",AV_TAMANHO)), MSMM(EE2->EE2_TEXTO,AVSX3("EE2_VM_TEX",AV_TAMANHO))) //MSMM_RD - usado para o Drawback
               Endif

               EE2->(dbSkip())
            Enddo
            While i <= 3
               IncProc() ; i++
            Enddo
            Temp_EE2->(dbGoTop())
            CursorArrow()
         Endif

      Case cAction == AC_MS // Criar MsSelect

         // *** Verificar integridade dos parametros ...
         IF Len(aParam) < 1 .Or. ValType(aParam[1]) <> "O"
            MsgStop(STR0038+CRLF+; //"Função: EE2Manut, cAction = AC_MS"
                    STR0039+CRLF+; //"O quinto parametro (aParam[1] = oDlg) invalido !"
                    STR0031+ProcName(1)+CRLF+; //"Rotina: "
                    STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
            Break
         Endif

         IF Len(aParam) < 2 .Or. ValType(aParam[2]) <> "C"
            MsgStop(STR0038+CRLF+; //"Função: EE2Manut, cAction = AC_MS"
                    STR0040+CRLF+; //"O quinto parametro (aParam[2] = cCod) invalido !"
                    STR0031+ProcName(1)+CRLF+; //"Rotina: "
                    STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
            Break
         Endif
         // ***

         IF cModelo == MO_MM // Memo
            aCpos := { ColBrw("EE2_IDIOMA","Temp_EE2"),;
                       { {||MemoLine(Temp_EE2->EE2_VM_TEX,AVSX3("EE2_VM_TEX",AV_TAMANHO),1)},"",STR0041} } //"Descrição"
         Elseif cModelo == MO_SP // Sigular/Plural
            aCpos := { ColBrw("EE2_IDIOMA","Temp_EE2"),;
                       ColBrw("EE2_DESC_S","Temp_EE2"),;
                       ColBrw("EE2_DESC_P","Temp_EE2") }
         Else
            aCpos := { ColBrw("EE2_IDIOMA","Temp_EE2"),;
                       ColBrw("EE2_DESCMA","Temp_EE2") }
         Endif

         cCod := AvKey(aParam[2],"EE2_COD")

         oBrw:=MsSelect():New("Temp_EE2",,,aCpos,,,PosDlgDown(aParam[1]))
         oBrw:bAval:={|| IF( Str(nOpc,1) $ Str(VISUALIZAR,1)+"/"+Str(EXCLUIR,1),EE2MDet(cModelo,VIS_DET,oBrw,cCod),EE2MDet(cModelo,ALT_DET,oBrw,cCod) ) }
         oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

      Case cAction == AC_IN // Criar Botoes - on int

         // *** Verificar integridade dos parametros ...
         IF Len(aParam) < 1 .Or. ValType(aParam[1]) <> "O"
            MsgStop(STR0042+CRLF+; //"Função: EE2Manut, cAction = AC_IN"
                    STR0039+CRLF+; //"O quinto parametro (aParam[1] = oDlg) invalido !"
                    STR0031+ProcName(1)+CRLF+; //"Rotina: "
                    STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
            Break
         Endif

         IF Len(aParam) < 2 .Or. ValType(aParam[2]) <> "B"
            MsgStop(STR0042+CRLF+; //"Função: EE2Manut, cAction = AC_IN"
                    STR0043+CRLF+; //"O quinto parametro (aParam[2] = bOk) invalido !"
                    STR0031+ProcName(1)+CRLF+; //"Rotina: "
                    STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
            Break
         Endif

         IF Len(aParam) < 3 .Or. ValType(aParam[3]) <> "B"
            MsgStop(STR0042+CRLF+; //"Função: EE2Manut, cAction = AC_IN"
                    STR0044+CRLF+; //"O quinto parametro (aParam[3] = bCancel) invalido !"
                    STR0031+ProcName(1)+CRLF+; //"Rotina: "
                    STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
            Break
         Endif

         IF Len(aParam) < 4 .Or. ValType(aParam[4]) <> "C"
            MsgStop(STR0042+CRLF+; //"Função: EE2Manut, cAction = AC_IN"
                    STR0045+CRLF+; //"O quinto parametro (aParam[4] = cCod) invalido !"
                    STR0031+ProcName(1)+CRLF+; //"Rotina: "
                    STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
            Break
         Endif
         // ***

         IF Len(aParam) >= 5 .And. ValType(aParam[5]) == "A"
            aBtn := aClone(aParam[5])
         Else
            aBtn := {}
         Endif

         cCod := AvKey(aParam[4],"EE2_COD")

         If STR(nOpc,1) $ STR(VISUALIZAR,1)+STR(EXCLUIR,1)
            aAdd(aBtn,{"BMPVISUAL" /*"ANALITICO"*/,{|| EE2MDet(cModelo,VIS_DET,oBrw,cCod,       ,cCODCAD)},STR0002}) //"Visualizar"
         Else
            aAdd(aBtn,{"BMPINCLUIR" /*"EDIT"*/ ,{|| EE2MDet(cModelo,INC_DET,oBrw,cCod,       ,cCODCAD)},STR0003}) //"Incluir"
            aAdd(aBtn,{"EDIT" /*"ALT_CAD"*/    ,{|| EE2MDet(cModelo,ALT_DET,oBrw,cCod,       ,cCODCAD)},STR0004}) //"Alterar"
            aAdd(aBtn,{"EXCLUIR"  ,{|| EE2MDet(cModelo,EXC_DET,oBrw,cCod,aDelEE2,cCODCAD)},STR0005}) //"Excluir"
         Endif

         //FDR - 12/07/12
         IF EasyEntryPoint("EECCAD00")
            EXECBLOCK("EECCAD00",.F.,.F.,{"OPCOES_BOTOES"})
         ENDIF

         EnchoiceBar(aParam[1],aParam[2],aParam[3],,aBtn)

      Case cAction == AC_GR // Gravar dados do work no EE2

         // *** Verificar integridade dos parametros ...
         IF Len(aParam) < 1 .Or. ValType(aParam[1]) <> "C"
            MsgStop(STR0046+CRLF+; //"Função: EE2Manut, cAction = AC_GR"
                    STR0037+CRLF+; //"O quinto parametro (aParam[1] = cCod) invalido !"
                    STR0031+ProcName(1)+CRLF+; //"Rotina: "
                    STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
            Break
         Endif
         // ***

         ProcRegua(Temp_EE2->(EasyReccount("Temp_EE2")))
         CursorWait()

         cCod := AvKey(aParam[1],"EE2_COD")

         Temp_EE2->(dbGoTop())
         nOrdEE2 := EE2->(IndexOrd())
         nRecEE2 := EE2->(Recno())
         While ! Temp_EE2->(Eof())

            IncProc(STR0047+Temp_EE2->EE2_IDIOMA) //"Gravando descrição em "

            EE2->(DbSetOrder(1)) //MCF - 15/09/2015
            If EE2->(DbSeek(xFilial("EE2") + AvKey(cCodCad,"EE2_CODCAD") + AvKey(TM_GER,"EE2_TIPMEN") + AvKey(Temp_EE2->EE2_IDIOMA,"EE2_IDIOMA") + AvKey(cCod,"EE2_COD")))  //RCR - 24/04/2013 Chamado 099542
               EE2->(RecLock("EE2",.F.))
            ElseIf Temp_EE2->EE2_RECNO <> 0
               EE2->(dbGoTo(Temp_EE2->EE2_RECNO))
               EE2->(RecLock("EE2",.F.))
            Else
               EE2->(RecLock("EE2",.T.))
            EndIf
            //IF Temp_EE2->EE2_RECNO <> 0
            //   EE2->(dbGoTo(Temp_EE2->EE2_RECNO))
            //   EE2->(RecLock("EE2",.F.))
            //Else
            //   EE2->(RecLock("EE2",.T.))
            //Endif

            AvReplace("Temp_EE2","EE2")

            IF Temp_EE2->EE2_RECNO == 0
               EE2->EE2_FILIAL := xFilial("EE2")
               EE2->EE2_CODCAD := cCodCad
               EE2->EE2_COD    := cCod
               EE2->EE2_TIPMEN := TM_GER
            Endif

            EE2->(MsUnlock())

            IF cModelo == MO_MM // Campo Memo
               IF Temp_EE2->EE2_RECNO == 0
                  // *** Inclusao de campo memo
                  EE2->(MSMM(,AVSX3("EE2_VM_TEX")[AV_TAMANHO],,Temp_EE2->EE2_VM_TEX,INCMEMO,,,"EE2","EE2_TEXTO"))
               Else
                  // *** Alteracao de campo memo
                  EE2->(MSMM(EE2->EE2_TEXTO,AVSX3("EE2_VM_TEX")[AV_TAMANHO],,Temp_EE2->EE2_VM_TEX,INCMEMO,,,"EE2","EE2_TEXTO"))
               Endif
            Endif
            EE2->(DbSetOrder(nOrdEE2))
            EE2->(DbGoto(nRecEE2))
            Temp_EE2->(dbSkip())
         Enddo

         For i:=1 to Len(aDelEE2)
            EE2->(dbGoTo(aDelEE2[i]))
            IncProc(STR0048+EE2->EE2_IDIOMA) //"Excluindo descrição em "

            IF cModelo == MO_MM // Campo Memo
               MSMM(EE2->EE2_TEXTO,,,,EXCMEMO)
            Endif

            EE2->(RecLock("EE2",.F.))
            EE2->(dbDelete())
            EE2->(MsUnlock())

            EE2->(dbSkip())
         Next i

         CursorArrow()

      Case cAction == AC_DE // Excluir dados do EE2

         // *** Verificar integridade dos parametros ...
         IF Len(aParam) < 1 .Or. ValType(aParam[1]) <> "C"
            MsgStop(STR0049+CRLF+; //"Função: EE2Manut, cAction = AC_DE"
                    STR0037+CRLF+; //"O quinto parametro (aParam[1] = cCod) invalido !"
                    STR0031+ProcName(1)+CRLF+; //"Rotina: "
                    STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
            Break
         Endif
         // ***

         ProcRegua(3)
         CursorWait()

         cCod := AvKey(aParam[1],"EE2_COD")

         EE2->(dbSeek(xFilial()+cCodCad+TM_GER+cCod))

         While EE2->(!Eof() .And. EE2_FILIAL == xFilial("EE2")) .And.;
               EE2->EE2_CODCAD == cCodCad .And.;
               EE2->EE2_TIPMEN == TM_GER .And.;
               EE2->EE2_COD == cCod

            IncProc()
            i++

            IF cModelo == MO_MM // Campo Memo
               MSMM(EE2->EE2_TEXTO,,,,EXCMEMO)
            Endif

            EE2->(RecLock("EE2",.F.))
            EE2->(dbDelete())
            EE2->(MsUnlock())

            EE2->(dbSkip())
         Enddo
         While i <= 3
            IncProc() ; i++
         Enddo
         CursorArrow()

      Case cAction == AC_ER // Fecha e apaga o arquivo temporario

         aDelEE2 := aSize(aDelEE2,0)
         oBrw    := Nil

         Temp_EE2->(E_EraseArq(cNomArq))

      Case cAction == "EXECAUTO"
         If Len(aParam[2]) > 0
            If EasySeekAuto("TEMP_EE2", aParam[2])
            	EE2MDet(cModelo,ALT_DET,oBrw,aParam[1],       ,cCODCAD, aParam[2])
            Else
            	EE2MDet(cModelo,INC_DET,oBrw,aParam[1],       ,cCODCAD, aParam[2])
            EndIf
         EndIf
   EndCase

End Sequence

RestOrd(aOrd)
restArea(aArea)

Return NIL


/*
Funcao      : EE2MDet(cModelo,nOpc,oBrw,cCod,aDelEE2)
Parametros  : nOpc := VIS_DET,INC_DET,ALT_DET,EXC_DET
Retorno     : NIL
Objetivos   : Manutencao de Descricao em varios Idiomas
Autor       : Cristiano A. Ferreira
Data/Hora   : 12/04/2000 14:00
Revisao     :
Obs.        :
*/
Static Function EE2MDet(cModelo,nOpc,oBrw,cCod,aDelEE2,cCODCAD, aEE2Auto)

Local nAreaOld := Select()
Local oDlg, cNewTit, i
Local nOpcA := 0

Local aEnchoice

Private aTela[0][0], aGets[0]
Private aMemos := {{"EE2_TEXTO","EE2_VM_TEX"}}
Private lEE2Auto := ValType(aEE2Auto) == "A"

Begin Sequence

   If Type("lAbriuExp") = "U"
      lAbriuExp := .f.
   EndIf

   IF cModelo == MO_MM
      aEnchoice:={"EE2_IDIOMA","EE2_VM_TEX"}
   Elseif cModelo == MO_SP
      aEnchoice:={"EE2_IDIOMA","EE2_DESC_S","EE2_DESC_P"}
   Else
      aEnchoice:={"EE2_IDIOMA","EE2_DESCMA"}
   Endif

   IF nOpc == INC_DET
      lAddDet := .t.
      For i := 1 TO Temp_EE2->(FCount())
         IF Temp_EE2->(FieldName(i)) = "DBDELETE" .Or.;
            Temp_EE2->(FieldName(i)) = "EE2_RECNO" .Or.;
            Temp_EE2->(FieldName(i)) = "TRB_ALI_WT" .Or.;
            Temp_EE2->(FieldName(i)) = "TRB_REC_WT"
            Loop
         Endif
         M->&(Temp_EE2->(FieldName(i))) := CriaVar(Temp_EE2->(FieldName(i)))
      Next i
   Else
      IF Temp_EE2->(Eof() .And. Bof())
         HELP(" ",1,"AVG0005017") //MsgInfo("Não possui descrições em outros idiomas !","Aviso")
         Break
      Endif

      For i := 1 TO Temp_EE2->(FCount())
         M->&(Temp_EE2->(FieldName(i))) := Temp_EE2->(FieldGet(i))
      Next i
   Endif

   cNewTit := STR0050 //"Descrições em outros idiomas - "

   IF nOpc == VIS_DET
      cNewTit += STR0002 //"Visualizar"
   Elseif nOpc == INC_DET
      cNewTit += STR0003 //"Incluir"
   Elseif nOpc == ALT_DET
      cNewTit += STR0004 //"Alterar"
   Else
      cNewTit += STR0005 //"Excluir"
   Endif

   cNewTit += " - "+cCod

   //DEFINE MSDIALOG oDlg TITLE cNewTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL   //Nopado por GFP - 05/06/2012

   bOk     := {|| nOpcA:=1,IF(EE2MVal(nOpc,Temp_EE2->(Recno()),aDelEE2), If(!lEE2Auto, oDlg:End(), ),nOpcA:=0) }
   bCancel := {|| If(!lEE2Auto, oDlg:End(), ) }

   If !lEE2Auto
	   DEFINE MSDIALOG oDlg TITLE cNewTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

	     If lAbriuExp
	        //"Definição do Arotina para a Visualização do Drawback"
	        Private aRotina:= {{"","",0,0},{"","",0,0},{"","",0,3}}
	     Endif

	     EnChoice("EE2", , 3, , , ,aEnchoice, PosDlg(oDlg),IF(Str(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},),3)

        oDlg:lMaximized := .T.

	     // Puxar memo do work ...
	     IF(nOpc<>INC_DET .And. cModelo==MO_MM,(M->EE2_VM_TEX := Temp_EE2->EE2_VM_TEX),)

	   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel)
   Else
      If EnchAuto("EE2", aEE2Auto, {|| Obrigatorio(aGets,aTela)}, IF(nOpc=4,3,4), aEnchoice)
         Eval(bOk)
      Else
         Eval(bCancel)
         lMsErroAuto := .T.
      EndIf
   EndIf

   lAddDet := .f.

   IF nOpcA == 1
      IF nOpc == INC_DET
         Temp_EE2->(dbAppend())
      Endif

      IF ! Str(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1)
         AvReplace("M","Temp_EE2")
      Endif
      IF cCODCAD # NIL .AND. EasyEntryPoint("EE2MDET") .AND. cCODCAD = MC_CPRO .AND.;
         (nOPC = INC_DET .OR. nOPC = ALT_DET)
         *
         EXECBLOCK("EE2MDET",.F.,.F.)
      ENDIF
      If !lEE2Auto
	      oBrw:oBrowse:Refresh()
      EndIf
   Endif

End Sequence

Select(nAreaOld)

Return Nil

/*
Funcao      : EE2MVal(nOpc,nRecno,aDelEE2)
Parametros  : nOpc := VIS_DET,INC_DET,ALT_DET,EXC_DET
              nRecno := Nro. do Registro
Retorno     : .T./.F.
Objetivos   : Manutencao de Descricao em varios Idiomas
Autor       : Cristiano A. Ferreira
Data/Hora   : 12/04/2000 14:00
Revisao     :
Obs.        :
*/
Static Function EE2MVal(nOpc,nRecno,aDelEE2)

Local lRet:=.T.

Begin Sequence
   IF nOpc == INC_DET .Or. nOpc = ALT_DET
      lRet:=Obrigatorio(aGets,aTela)
   Elseif nOpc == EXC_DET
      Temp_EE2->(DBGOTO(nRecno))

      IF MsgNoYes(STR0051,STR0052) //"Confirma Exclusão ?"###"Atenção"
         IF Temp_EE2->EE2_RECNO <> 0
            aAdd(aDelEE2,Temp_EE2->EE2_RECNO)
         Endif
         Temp_EE2->EE2_VM_TEX := "" //AOM - 18/07/2011 - Ao deletar o registro inicializa a memo de descrição.
         Temp_EE2->(dbDelete())
         Temp_EE2->(dbSkip(-1))
         IF Temp_EE2->(Bof())
            Temp_EE2->(dbGotop())
         Endif
      Endif
   Endif
End Sequence

Return lRet

/*
Funcao      : EE2MValid(cCampo)
Parametros  : cCampo := "IDIOMA"
Retorno     : .T./.F.
Objetivos   : Validar campos
Autor       : Cristiano A. Ferreira
Data/Hora   : 07/06/99 14:20
Revisao     :
Obs.        :
Uso         : SX3
*/
Function EE2MValid( cCampo )
Local lRet := .T.
Local nRec := Temp_EE2->(RecNo())

Begin Sequence
   IF cCampo == "IDIOMA"
      IF Temp_EE2->(dbSeek(M->EE2_IDIOMA))
         IF lAddDet .Or. nRec <> Temp_EE2->(RecNo())
            HELP(" ",1,"AVG0005015") //MsgStop("Idioma já cadastrado !","Atenção")
            lRet := .F.
            Break
         Endif
      Endif
   Endif
End Sequence

Temp_EE2->(dbGoto(nRec))

Return (lRet)



/*
Funcao      : EE3Manut(nOpc,cCodCad,cAction,aParam)
Parametros  : nOpc    := Nro. da opcao enviada pela aRotina
              cCodCad := Codigo do Cadastro no EE3
              cAction := AC_WK (Criar/Gravar Work)
                         AC_MS (Criar MsSelect)
                         AC_IN (Criar Botoes - on init)
                         AC_GR (Gravar dados do work no EE3)
                         AC_DE (Excluir dados do EE3)
                         AC_ER (Fecha/Apaga o Work)
              aParam  := se cAction = AC_WK
                            aParam[1] := cCod - Codigo do Registro
                            aParam[2] := cCompl
                         se cAction = AC_MS
                            aParam[1] := oDlg - Janela da MsSelect
                            aParam[2] := cCod
                         se cAction = AC_IN
                            (Parametros passado para a EnchoiceBar)
                            aParam[1] := oDlg
                            aParam[2] := bOk
                            aParam[3] := bCancel
                            aParam[4] := cCod
                            aParam[5] := aButtons
                         se cAction = AC_GR
                            aParam[1] := cCod - Codigo do Registro
                            aParam[2] := cCompl
                         se cAction = AC_DE
                            aParam[1] := cCod - Codigo do Registro
                            aParam[2] := cCompl
                         se cAction = AC_ER
                            Nao Usado
                         se cAction = "EXECAUTO"
                         	aParam[1] := cCod
                         	aParam[2] := cCompl
								aParam[3] := aAutoCab
Retorno     : NIL
Objetivos   : Manutencao de Contatos
Autor       : Cristiano A. Ferreira
Data/Hora   : 13/04/2000 11:47
Revisao     :
Obs.        :
*/
Function EE3Manut(nOpc,cCodCad,cAction,aParam)

Local aOrd := SaveOrd("EE3",1)
Local aCpos, cCod, cCompl, i := 0
Local cDescCont
Local aMedidas
Local nPos
Local nPosX5
Local cTpModu
Local lSeek
Local lCpoPortador := .F.
Local nOrdEE3
Local nRecEE3

Private aBotao := {}//FDR - 28/02/2013

Static oBrw, aDelEE3 := {}, aDelECI := {}
Static aDelEIE  := {}

//AOM - 20/09/2011
If Type("lTabArm") <> "L"
  Private lTabArm := .T.
EndIf

Begin Sequence

   // *** Verificar integridade dos parametros ...
   IF cAction <> AC_WK
      IF Select("Temp_EE3") <= 0
         MsgStop(STR0053+CRLF+; //"Primeiro deve ser executada a rotina EE3Manut com (cAction = AC_WK) !"
                 STR0031+ProcName(1)+CRLF+; //"Rotina: "
                 STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
         Break
      Endif
   Else
      IF Select("Temp_EE3") > 0
         MsgStop(STR0054+CRLF+; //"Alias Temp_EE3 já esta em uso !"
                 STR0031+ProcName(1)+CRLF+; //"Rotina: "
                 STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
         Break
      Endif
   Endif

   IF cAction <> AC_ER
      IF ValType(aParam) <> "A"
         MsgStop(STR0055+CRLF+; //"Função: EE3Manut, cAction <> AC_ER"
                 STR0035+CRLF+; //"O quinto parametro (aParam) é obrigatório !"
                 STR0031+ProcName(1)+CRLF+; //"Rotina: "
                 STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
         Break
      Endif
   Endif
   // ***

   do Case
      Case cAction == AC_WK // Criar/Gravar Work

         // *** Verificar integridade dos parametros ...
         IF Len(aParam) < 1 .Or. ValType(aParam[1]) <> "C"
            MsgStop(STR0056+CRLF+; //"Função: EE3Manut, cAction = AC_WK"
                    STR0037+CRLF+; //"O quinto parametro (aParam[1] = cCod) invalido !"
                    STR0031+ProcName(1)+CRLF+; //"Rotina: "
                    STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
            Break
         Endif
         // ***

         aDelEE3 := aSize(aDelEE3,0)
         oBrw    := Nil

         // Cria Arquivo de Trabalho
         Private aCampos := Array(EE3->(FCount()))
         Private aHeader[0]
         aSemSX3:= {{"EE3_RECNO","N",7,0}}
         //TRP - 25/01/07 - Campos do WalkThru
         AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
         AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
         //FDR - 21/03/13
         IF EasyEntryPoint("EECCAD00")
            EXECBLOCK("EECCAD00",.F.,.F.,{"WORK_EE3"})
         ENDIF
         aAdd(aSemSX3,{"DBDELETE","L",1,0}) //THTS - 31/10/2017 - Este campo deve sempre ser o ultimo campo da Work
         cNomArq := E_CriaTrab("EE3",aSemSX3,"Temp_EE3")
         IndRegua("Temp_EE3",cNomArq+TEOrdBagExt(),"EE3_SEQ")

         IF nOpc <> INCLUIR
            ProcRegua(3)
            CursorWait()
            // Carrega dados do EE3 para o Work
            cCod  := AvKey(aParam[1],"EE3_CONTAT")
            cCompl:= AvKey(IF(Len(aParam)>1 .And. !Empty(aParam[2]),aParam[2],""),"EE3_COMPL")

            EE3->(dbSeek(xFilial()+cCodCad+cCod+cCompl))

            While EE3->(!Eof() .And. EE3_FILIAL == xFilial("EE3")) .And.;
                  EE3->EE3_CODCAD == cCodCad .And.;
                  EE3->EE3_CONTAT == cCod .And.;
                  EE3->EE3_COMPL == cCompl

               IncProc()
               i++

               Temp_EE3->(dbAppend())
               AvReplace("EE3","Temp_EE3")

               Temp_EE3->EE3_RECNO := EE3->(RecNo())
               Temp_EE3->TRB_ALI_WT:= "EE3"
               Temp_EE3->TRB_REC_WT:= EE3->(Recno())

               EE3->(dbSkip())
            Enddo
            While i <= 3
               IncProc() ; i++
            Enddo
            Temp_EE3->(dbGoTop())
            CursorArrow()
         Endif

         If cModulo = "EIC"

            aDelEIE := aSize(aDelEIE,0)

         	aCampos := Array(EIE->(FCount()))
            aSemSX3:= {{"EIE_RECNO","N",7,0}}
      	    //TRP - 25/01/07 - Campos do WalkThru
      	    AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
            AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
            aAdd(aSemSX3,{"DBDELETE"  ,"L",1 ,0}) //THTS - 31/10/2017 - Este campo deve sempre ser o ultimo campo da Work
      	    cNomArq2 := E_CriaTrab("EIE",aSemSX3,"Temp_EIE")
            IndRegua("Temp_EIE",cNomArq2+TEOrdBagExt(),"EIE_TIPCNT")

            IF nOpc <> INCLUIR
               ProcRegua(3)
               CursorWait()
               // Carrega dados do EIE para o Work
               EIE->(dbSeek(xFilial("EIE")+AvKey(aParam[1],"EIE_ARMAD")))
               While EIE->(!Eof() .And. EIE_FILIAL == xFilial("EIE")) .And.;
                     EIE->EIE_ARMAD == AvKey(aParam[1],"EIE_ARMAD")

                  IncProc()
                  i++

                  Temp_EIE->(dbAppend())
                  AvReplace("EIE","Temp_EIE")

                  dbSelectArea("SX5")
                  dbSeek(xFilial("SX5")+"C3"+TEMP_EIE->EIE_TIPCNT)
                  Temp_EIE->EIE_DESCNT := X5Descri()

                  Temp_EIE->EIE_RECNO  := EIE->(RecNo())
                  Temp_EIE->TRB_ALI_WT := "EIE"
                  Temp_EIE->TRB_REC_WT := EIE->(Recno())

                  EIE->(dbSkip())
               Enddo
               While i <= 3
                  IncProc() ; i++
               Enddo
               Temp_EIE->(dbGoTop())
               CursorArrow()
            Endif

         Endif


         If IsInCallStack("EECAC110") // BAK - 30/01/2012

            aDelECI := aSize(aDelECI,0)
            oBrw    := Nil

            lCpoPortador := ECI->(FieldPos("ECI_PORTAD")) > 0 .And. ECI->(FieldPos("ECI_TPPORT")) > 0

            If Select("Temp_ECI") > 0
               Temp_ECI->(DbCloseArea())
            EndIf
            ASEMSX3ECI := {}
            aAdd(aSemSX3ECI,{"ECI_BANCOD",AVSX3("ECI_BANCOD",2),AVSX3("ECI_BANCOD",3),AVSX3("ECI_BANCOD",4)})
            aAdd(aSemSX3ECI,{"ECI_AGENCI",AVSX3("ECI_AGENCI",2),AVSX3("ECI_AGENCI",3),AVSX3("ECI_AGENCI",4)})
            aAdd(aSemSX3ECI,{"ECI_NUMCON",AVSX3("ECI_NUMCON",2),AVSX3("ECI_NUMCON",3),AVSX3("ECI_NUMCON",4)})
            If lCpoPortador
               aAdd(aSemSX3ECI,{"ECI_PORTAD",AVSX3("ECI_PORTAD",2),AVSX3("ECI_PORTAD",3),AVSX3("ECI_PORTAD",4)})
               aAdd(aSemSX3ECI,{"ECI_TPPORT",AVSX3("ECI_TPPORT",2),AVSX3("ECI_TPPORT",3),AVSX3("ECI_TPPORT",4)})
            EndIf
            aAdd(aSemSX3ECI,{"ECI_TPMODU",AVSX3("ECI_TPMODU",2),AVSX3("ECI_TPMODU",3),AVSX3("ECI_TPMODU",4)})
            aAdd(aSemSX3ECI,{"ECI_TPCONT",AVSX3("ECI_TPCONT",2),AVSX3("ECI_TPCONT",3)+3+AVSX3("X5_DESCRI",3),AVSX3("ECI_TPCONT",4)})
            aAdd(aSemSX3ECI,{"ECI_RECNO" ,"N",07,0})
            aAdd(aSemSX3ECI,{"TRB_ALI_WT","C",03,0})
            aAdd(aSemSX3ECI,{"TRB_REC_WT","N",10,0})
            cNomArqECI := E_CriaTrab("ECI",aSemSX3ECI,"Temp_ECI")
            IndRegua("Temp_ECI",cNomArqECI+TEOrdBagExt(),"ECI_BANCOD+ECI_AGENCI+ECI_NUMCON+ECI_TPMODU+ECI_TPCONT")

            aTpModu := {}
            ECI->( dbSetOrder(2) )//ECI_FILIAL+ECI_BANCOD+ECI_AGENCI+ECI_NUMCON+ECI_TPMODU+ECI_TPCONT
            IF ECI->( dbSeek(xFilial("ECI") + M->A6_COD + M->A6_AGENCIA + M->A6_NUMCON ))
               ProcRegua(3)
               CursorWait()
               Do While !ECI->( EoF() ) .AND. ECI->ECI_FILIAL == xFilial("ECI") .AND. ECI->ECI_BANCOD == M->A6_COD .AND. ECI->ECI_AGENCI == M->A6_AGENCIA .AND. ECI->ECI_NUMCON == M->A6_NUMCON
                  IncProc()
                  i++
                  Temp_ECI->(dbAppend())
                  AvReplace("ECI","Temp_ECI")
                  Temp_ECI->ECI_BANCOD := M->A6_COD
                  If lCpoPortador
                     Temp_ECI->ECI_PORTAD := ECI->ECI_PORTAD
                     Temp_ECI->ECI_TPPORT := ECI->ECI_TPPORT
                  EndIf
                  aAdd(aTpModu,{ECI->ECI_TPMODU,ECI->ECI_TPCONT})
                  ECI->( DbSkip() )
               EndDo
            EndIf

            If lCpoPortador

			   If !Temp_ECI->(DbSeek(AvKey(M->A6_COD,"ECI_BANCOD")+;
                                    AvKey(M->A6_AGENCIA,"ECI_AGENCI")+;
                                    AvKey(M->A6_NUMCON,"ECI_NUMCON")+;
                                    AvKey("EXPORT","ECI_TPMODU")+;
                                    AvKey("A","ECI_TPCONT")))
			      Temp_ECI->(DbAppend())
                  Temp_ECI->ECI_BANCOD := M->A6_COD
                  Temp_ECI->ECI_AGENCI := M->A6_AGENCIA
                  Temp_ECI->ECI_NUMCON := M->A6_NUMCON
                  Temp_ECI->ECI_TPMODU := "EXPORT"
                  Temp_ECI->ECI_CONTAB := Space(AvSx3("ECI_CONTAB",AV_TAMANHO))
                  Temp_ECI->ECI_PORTAD := Space(AvSx3("ECI_PORTAD",AV_TAMANHO))
                  Temp_ECI->ECI_TPPORT := Space(AvSx3("ECI_TPPORT",AV_TAMANHO))
               EndIf

			   Temp_ECI->ECI_TPCONT := "A" + " - " + "COMP. ADIANT."

			   If !Temp_ECI->(DbSeek(AvKey(M->A6_COD,"ECI_BANCOD")+;
                                    AvKey(M->A6_AGENCIA,"ECI_AGENCI")+;
                                    AvKey(M->A6_NUMCON,"ECI_NUMCON")+;
                                    AvKey("EXPORT","ECI_TPMODU")+;
                                    AvKey("B","ECI_TPCONT")))
                  Temp_ECI->(DbAppend())
                  Temp_ECI->ECI_BANCOD := M->A6_COD
                  Temp_ECI->ECI_AGENCI := M->A6_AGENCIA
                  Temp_ECI->ECI_NUMCON := M->A6_NUMCON
                  Temp_ECI->ECI_TPMODU := "EXPORT"
                  Temp_ECI->ECI_CONTAB := Space(AvSx3("ECI_CONTAB",AV_TAMANHO))
                  Temp_ECI->ECI_PORTAD := Space(AvSx3("ECI_PORTAD",AV_TAMANHO))
                  Temp_ECI->ECI_TPPORT := Space(AvSx3("ECI_TPPORT",AV_TAMANHO))
               EndIf

			   Temp_ECI->ECI_TPCONT := "B" + " - " + "INCLUSAO ADIANT."
            EndIf

            SX5->( dbSeek(xFilial("SX5")+"CJ") )
            Do While !SX5->( EoF() ) .And. SX5->X5_FILIAL == xFilial("SX5") .And. SX5->X5_TABELA == "CJ"

               nPosX5 := SX5->( RecNo() )
               cTpModu:= SX5->X5_CHAVE

               SX5->(dbSeek(xFilial("SX5")+"C0"))
               Do While !SX5->( EoF() ) .And. SX5->X5_FILIAL == xFilial("SX5") .And. SX5->X5_TABELA == "C0"

                  /*If AllTrim(Upper(SX5->X5_CHAVE)) == "A" .And. ((!AllTrim(Upper(cTpModu)) == "EXPORT"  .And. lCpoPortador) .Or. !lCpoPortador)
                     SX5->( dbSkip() )
                     Loop
                  EndIf*/

                  If (nPos := aScan(aTpModu,{|X| AllTrim(Upper(X[1])) + AllTrim(Upper(X[2]))   == AllTrim(Upper(cTpModu)) +  Left(SX5->X5_CHAVE,1)})) == 0
                     Temp_ECI->(DbAppend())
                     Temp_ECI->ECI_BANCOD := M->A6_COD
                     Temp_ECI->ECI_AGENCI := M->A6_AGENCIA
                     Temp_ECI->ECI_NUMCON := M->A6_NUMCON
                     Temp_ECI->ECI_TPMODU := cTpModu
                     Temp_ECI->ECI_TPCONT := Left(SX5->X5_CHAVE,1) + " - " + AllTrim(SX5->X5_DESCRI)
                     Temp_ECI->ECI_CONTAB := Space(AvSx3("ECI_CONTAB",AV_TAMANHO))
                     If lCpoPortador
                        Temp_ECI->ECI_PORTAD := Space(AvSx3("ECI_PORTAD",AV_TAMANHO))
                        Temp_ECI->ECI_TPPORT := Space(AvSx3("ECI_TPPORT",AV_TAMANHO))
                     EndIf
                  Else
                     Temp_ECI->(DbSeek(AvKey(M->A6_COD,"ECI_BANCOD")+;
                                       AvKey(M->A6_AGENCIA,"ECI_AGENCI")+;
                                       AvKey(M->A6_NUMCON,"ECI_NUMCON")+;
                                       AvKey(cTpModu,"ECI_TPMODU")+;
                                       AvKey(SX5->X5_CHAVE,"ECI_TPCONT")))
                     Temp_ECI->(RecLock("Temp_ECI",.F.))
                     Temp_ECI->ECI_TPMODU := cTpModu
                     Temp_ECI->ECI_TPCONT := Left(SX5->X5_CHAVE,1) + " - " + AllTrim(SX5->X5_DESCRI)
                     Temp_ECI->(MsUNLock())
                  EndIf
                  SX5->( dbSkip() )
               EndDO

               SX5->( dbGoTo(nPosX5) )
               SX5->( dbSkip() )
            EndDo

            Temp_ECI->(dbGoTop())
            CursorArrow()

         EndIf
      Case cAction == AC_MS // Criar MsSelect

         // *** Verificar integridade dos parametros ...
         IF Len(aParam) < 1 .Or. ValType(aParam[1]) <> "O"
            MsgStop(STR0057+CRLF+; //"Função: EE3Manut, cAction = AC_MS"
                    STR0039+CRLF+; //"O quinto parametro (aParam[1] = oDlg) invalido !"
                    STR0031+ProcName(1)+CRLF+; //"Rotina: "
                    STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
            Break
         Endif

         IF Len(aParam) < 2 .Or. ValType(aParam[2]) <> "C"
            MsgStop(STR0057+CRLF+; //"Função: EE3Manut, cAction = AC_MS"
                    STR0040+CRLF+; //"O quinto parametro (aParam[2] = cCod) invalido !"
                    STR0031+ProcName(1)+CRLF+; //"Rotina: "
                    STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
            Break
         Endif
         // ***

         If cModulo = "EIC"
		     If lTabArm // Mostra o Brw dos Contatos
                 oBrw    := Nil
	    	     aCpos := ArrayBrowse("EE3","Temp_EE3")

		         cCod := AvKey(aParam[2],"EE3_CONTAT")

		         oBrw:=MsSelect():New("Temp_EE3",,,aCpos,,,PosDlgDown(aParam[1]))
	    	     oBrw:bAval:={|| IF( Str(nOpc,1) $ Str(VISUALIZAR,1)+"/"+Str(EXCLUIR,1),EE3MDet(VIS_DET,oBrw,cCod),EE3MDet(ALT_DET,oBrw,cCod) ) }
	             oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

    	     Else
                 If AvFlags("DEMURRAGE") //FSM 10/03/11 - Select
                    oBrw := Nil
                    aCpoFora := {"EWU_Y9COD","EWU_DTFINV","EWU_DESPOR","EWU_MOEDA","EWU_DES_SI"}
                    aCpos := ArrayBrowse(oTarifa:cCapAlias,"WorkEWU", aCpoFora,.T.)

                    aAdd(aCpos,{nil})
                    aIns(aCpos,2)
                    aCpos[2] := {"EWU_DESPOR",,AVSX3("EWU_DESPOR",AV_TITULO)}

                    oBrw := MsSelect():New("WorkEWU",,,aCpos,,,PosDlgDown(aParam[1]))
                    oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT


                 Else

                    oBrw    := Nil
                    aCpos := ArrayBrowse("EIE","Temp_EIE")

                    naCpos:=ASCAN(aCpos,{|x| AVSX3("EIE_DESCNT",AV_TITULO) = ALLTRIM(x[3])})
                    if naCpos # 0
         	            aCpos[naCpos,1]:= {|| TRANSF(TEMP_EIE->EIE_DESCNT, '@!') }
                    EndIf
        	         //TEMP_EIE->EIE_DESCNT
                    cCod := AvKey(aParam[2],"EIE_ARMAD")

                    oBrw:=MsSelect():New("Temp_EIE",,,aCpos,,,PosDlgDown(aParam[1]))
                    oBrw:bAval:={|| IF( Str(nOpc,1) $ Str(VISUALIZAR,1)+"/"+Str(EXCLUIR,1),DetArm(VIS_DET,oBrw,cCod),DetArm(ALT_DET,oBrw,cCod) ) }
                    oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
                 EndIf

    	     Endif

         Else

             If AvFlags("DEMURRAGE") .And. !lTabArm  //FSM 10/03/11 - Select

                oBrw := Nil
                aCpoFora := {"EWU_Y9COD","EWU_DTFINV","EWU_DESPOR","EWU_MOEDA","EWU_DES_SI"}
                aCpos := ArrayBrowse(oTarifa:cCapAlias,"WorkEWU", aCpoFora,.T.)

                aAdd(aCpos,{nil})
                aIns(aCpos,2)
                aCpos[2] := {"EWU_DESPOR",,AVSX3("EWU_DESPOR",AV_TITULO)}

                oBrw := MsSelect():New("WorkEWU",,,aCpos,,,PosDlgDown(aParam[1]))
                oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

             ElseIf IsInCallStack("EECAC110") .And. Type("lPortador") == "L" .And. lPortador

                aAdd(aHeader,{AvSX3("ECI_TPCONT",5),"ECI_TPCONT","@!",AvSX3("ECI_TPCONT",3)+3+Len(SX5->X5_DESCRI),0,nil,nil,"C",nil,nil } )
                lCpoPortador := ECI->(FieldPos("ECI_PORTAD")) > 0 .And. ECI->(FieldPos("ECI_TPPORT")) > 0

                //Colunas alteráveis
                aAdd(aAlter, "ECI_CONTAB" )
                If lCpoPortador
                   aAdd(aAlter, "ECI_PORTAD" )
                   aAdd(aAlter, "ECI_TPPORT" )
                EndIf

                If lCpoPortador
                   aYesFields := { "ECI_CONTAB" ,;
                                   "ECI_PORTAD" ,;
                                   "ECI_TPPORT" ,;
                                   "ECI_TPMODU"   }
                   aOrdHeader := { "ECI_CONTAB" ,;
                                   "ECI_PORTAD" ,;
                                   "ECI_TPPORT" ,;
                                   "ECI_TPCONT" ,;
                                   "ECI_TPMODU"  }
                Else
                   aYesFields := { "ECI_CONTAB" ,;
                                   "ECI_TPMODU"   }
                   aOrdHeader := { "ECI_CONTAB" ,;
                                   "ECI_TPCONT" ,;
                                   "ECI_TPMODU"  }
                EndIf
                FillGetDados(nOpc, "ECI", 2, /*cSeek*/,/*{||&cWhile}*/, {||.T.}, /*aNoFields*/, aYesFields,,,{|| CarregaECI(nOpc,aCols,aHeader)},,,,{|aCols| AddAcols(aCols, nTip) },,{|a| OrdHeader(@a, aOrdHeader) })

                oBrw := Nil
                cCod := AvKey(aParam[2],"ECI_BANCOD")
                //oBrw:=MsSelect():New("Temp_ECI",,,aCpos,,,)
                oBrw:= MsGetDados():New(PosDlgDown(aParam[1])[1], 0, PosDlgDown(aParam[1])[3], PosDlgDown(aParam[1])[4], nOpc,Nil,Nil,Nil,.T.,aAlter,Nil,Nil,5)
                oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

             Else

                aCpos := ArrayBrowse("EE3","Temp_EE3")

                cCod := AvKey(aParam[2],"EE3_CONTAT")

                oBrw:=MsSelect():New("Temp_EE3",,,aCpos,,,PosDlgDown(aParam[1]))
                oBrw:bAval:={|| IF( Str(nOpc,1) $ Str(VISUALIZAR,1)+"/"+Str(EXCLUIR,1),EE3MDet(VIS_DET,oBrw,cCod),EE3MDet(ALT_DET,oBrw,cCod) ) }
                oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

             EndIf

         Endif

      Case cAction == AC_IN // Criar Botoes - on int

         // *** Verificar integridade dos parametros ...
         IF Len(aParam) < 1 .Or. ValType(aParam[1]) <> "O"
            MsgStop(STR0058+CRLF+; //"Função: EE3Manut, cAction = AC_IN"
                    STR0039+CRLF+; //"O quinto parametro (aParam[1] = oDlg) invalido !"
                    STR0031+ProcName(1)+CRLF+; //"Rotina: "
                    STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
            Break
         Endif

         IF Len(aParam) < 2 .Or. ValType(aParam[2]) <> "B"
            MsgStop(STR0058+CRLF+; //"Função: EE3Manut, cAction = AC_IN"
                    STR0043+CRLF+; //"O quinto parametro (aParam[2] = bOk) invalido !"
                    STR0031+ProcName(1)+CRLF+; //"Rotina: "
                    STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
            Break
         Endif

         IF Len(aParam) < 3 .Or. ValType(aParam[3]) <> "B"
            MsgStop(STR0058+CRLF+; //"Função: EE3Manut, cAction = AC_IN"
                    STR0044+CRLF+; //"O quinto parametro (aParam[3] = bCancel) invalido !"
                    STR0031+ProcName(1)+CRLF+; //"Rotina: "
                    STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
            Break
         Endif

         IF Len(aParam) < 4 .Or. ValType(aParam[4]) <> "C"
            MsgStop(STR0058+CRLF+; //"Função: EE3Manut, cAction = AC_IN"
                    STR0045+CRLF+; //"O quinto parametro (aParam[4] = cCod) invalido !"
                    STR0031+ProcName(1)+CRLF+; //"Rotina: "
                    STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
            Break
         Endif

         // By JBJ - 03/08/2002 - 10:55
         If Len(aParam) > 4
            If ValType(aParam[5]) = "A"
               aBotao:=aParam[5]
            Else
               aBotao:={}
            EndIf
         Else
            aBotao:={}
         EndIf

         cCod := AvKey(aParam[4],"EE3_CONTAT")

	     If cModulo = "EIC"

 	         If lTabArm // Mostra o Botao p/ Tabelas do Armador e Dados p/ o Contatos

   	            //FSM 10/03/11 - Titulo da Enchoice
  	            cCadCont := " - Tabela de Tarifas do Armador"

    	        aAdd(aBotao,{"NOTE",{|| lTabArm:=.f., nOpcA := 3 ,oDlg:End()},STR0097})    //JWJ 12/09/05   //"Tabelas do Armador"
  	            If STR(nOpc,1) $ STR(VISUALIZAR,1)+STR(EXCLUIR,1)
	               aAdd(aBotao,{"BMPVISUAL" /*"ANALITICO"*/,{|| EE3MDet(VIS_DET,oBrw,cCod) },STR0002}) //"Visualizar"
	            Else
	               aAdd(aBotao,{"BMPINCLUIR" /*"EDIT"*/,{|| EE3MDet(INC_DET,oBrw,cCod) },STR0003}) //"Incluir"
	               aAdd(aBotao,{"EDIT" /*"ALT_CAD"*/   ,{|| EE3MDet(ALT_DET,oBrw,cCod) },STR0004}) //"Alterar"
	               aAdd(aBotao,{"EXCLUIR",{|| EE3MDet(EXC_DET,oBrw,cCod,aDelEE3) },STR0005}) //"Excluir"
	               aAdd(aBotao,{/*"VCUP"*/"PMSSETAUP", {|| EE3Up(oBrw) },STR0059,STR0168}) //LRL 01/03/04 "Sobe" - "Move para Cima"
	               aAdd(aBotao,{/*"VCDOWN"*/"PMSSETADOWN",{|| EE3Down(oBrw) },STR0060,STR0169}) //LRL 01/03/04 "Desce" - "Move para Baixo"
	            Endif
			 Else

                cCod := AvKey(aParam[4],"EIE_ARMAD")
	            aAdd(aBotao,{"POSCLI",{|| lTabArm:=.t., nOpcA := 3 ,oDlg:End()},STR0098})    //JWJ 12/09/05  //"Contatos"

   	            //FSM 10/03/11 - Titulo da Enchoice
 	            cCadCont := " - Contatos do Armador"

  	            If STR(nOpc,1) $ STR(VISUALIZAR,1)+STR(EXCLUIR,1)
	               aAdd(aBotao,{"BMPVISUAL" /*"ANALITICO"*/,{|| If(AvFlags("DEMURRAGE"),oTarifa:Manut(2)/*FSM - 10/03/11 */,DetArm(VIS_DET,oBrw,cCod)) }          ,STR0002}) //"Visualizar"
	            Else
	               aAdd(aBotao,{"BMPINCLUIR" /*"EDIT"*/    ,{|| If(AvFlags("DEMURRAGE"),oTarifa:Manut(3)/*FSM - 10/03/11 */, DetArm(INC_DET,oBrw,cCod)         ) },STR0003}) //"Incluir"
	               aAdd(aBotao,{"EDIT" /*"ALT_CAD"*/       ,{|| If(AvFlags("DEMURRAGE"),oTarifa:Manut(4)/*FSM - 10/03/11 */, DetArm(ALT_DET,oBrw,cCod)         ) },STR0004}) //"Alterar"
	               aAdd(aBotao,{"EXCLUIR"                  ,{|| If(AvFlags("DEMURRAGE"),oTarifa:Manut(5)/*FSM - 10/03/11 */, DetArm(EXC_DET,oBrw,cCod,aDelEIE) ) },STR0005}) //"Excluir"
	               If AvFlags("DEMURRAGE") .And. Type("oTarifa") == "O"  //FSM - 30/01/2012
                      aAdd(aBotao,{"EXCLUIR"               ,{|| (oTarifa:lCopia := .T., oTarifa:Manut(4)) },"Copiar Tab.Tarifa"}) //"Copiara Tarifa" /*FSM - 14/04/11 */
	               EndIf
	               aAdd(aBotao,{/*"VCUP"*/"PMSSETAUP"      ,{|| ArmUp(oBrw)   }                                                                                   ,STR0059,STR0168}) //LRL 01/03/04  "Sobe" - "Move para Cima"
	               aAdd(aBotao,{/*"VCDOWN"*/"PMSSETADOWN"  ,{|| ArmDown(oBrw) }                                                                                   ,STR0060,STR0169}) //LRL 01/03/04  "Desce" - "Move para Baixo"
	            Endif
	         Endif

         Else

             If AvFlags("DEMURRAGE") .And. !lTabArm /*FSM - 10/03/11 */

  	            //FSM 30/01/12 - Titulo da Enchoice
 	            cCadCont := " - Contatos do Armador"

   	            aAdd(aBotao,{"POSCLI",{|| lTabArm:=.t., nOpcA := 3 ,oDlg:End()},STR0098})  //"Contatos"
  	            If STR(nOpc,1) $ STR(VISUALIZAR,1)+STR(EXCLUIR,1)
	               aAdd(aBotao,{"BMPVISUAL" /*"ANALITICO"*/,{|| oTarifa:Manut(2) } ,STR0002}) //"Visualizar"
	            Else
	               aAdd(aBotao,{"BMPINCLUIR" /*"EDIT"*/    ,{|| oTarifa:Manut(3)},STR0003}) //"Incluir"
	               aAdd(aBotao,{"EDIT" /*"ALT_CAD"*/       ,{|| oTarifa:Manut(4)},STR0004}) //"Alterar"
	               aAdd(aBotao,{"EXCLUIR"                  ,{|| oTarifa:Manut(5) },STR0005}) //"Excluir"
	               If AvFlags("DEMURRAGE")
                      aAdd(aBotao,{"EXCLUIR"               ,{|| (oTarifa:lCopia := .T., oTarifa:Manut(4)) },"Copiar Tab.Tarifa"}) //"Copiara Tarifa"
	               EndIf
	               aAdd(aBotao,{/*"VCUP"*/"PMSSETAUP"      ,{|| ArmUp(oBrw)   } ,STR0059,STR0168}) //LRL 01/03/04  "Sobe" - "Move para Cima"
	               aAdd(aBotao,{/*"VCDOWN"*/"PMSSETADOWN"  ,{|| ArmDown(oBrw) } ,STR0060,STR0169}) //LRL 01/03/04  "Desce" - "Move para Baixo"
	            Endif

             ElseIf IsInCallStack("EECAC110") .And. Type("lPortador") == "L" .And. lPortador

   	            aAdd(aBotao,{"POSCLI",{|| lPortador := .F., lOkPortador := .T. , ECIGravaWork() ,aParam[1]:End()},STR0098})  //"Contatos"

             Else

  	            If AvFlags("DEMURRAGE") .And. Type("oTarifa") == "O" //FSM - 30/01/2012
  	            	if STR(nOpc,1) <> "3" //WHRS 06/2017  TE-5993 522706 - MTRADE-1123 - Tabela do armador
                   //DFS - 05/10/12 - Inclusão de tratamento para que, se não for armador, não seja possível abrir a tela de tabela de armadores e volte a tela inicial
                   aAdd(aBotao,{"NOTE",{|| If(!Empty(M->Y5_TIPOAGE) .AND. M->Y5_TIPOAGE <> "4-ARMADOR",;
                                                  MsgInfo(STR0198,STR0052),; //"O Tipo de Agente não é um Armador" ### "Atenção"
                                                  (lTabArm:=.f., nOpcA := 3 ,oDlg:End()))},STR0097})    //JWJ 12/09/05   //"Tabelas do Armador"
                   //aAdd(aBotao,{"NOTE",{|| lTabArm:=.f., nOpcA := 3 ,oDlg:End()},STR0097})    //JWJ 12/09/05   //"Tabelas do Armador"
                   cCadCont := " - Tabela de Tarifas do Armador" //DFS - 19/09/12 - Tratamento para trazer o titulo do campo, apenas quando clicar no botao Tabelas de Armador
                	endIf
                EndIf

                If IsInCallStack("EECAC110") .And. Type("lPortador") == "L" .And. !lPortador
                  aAC110Parm := aClone(aParam) //LGS-30/06/2016
                  aAdd(aBotao,{"NOTE",{|| lPortador := .T. , lOkPortador := .T., ECIGravaWork()  ,aAC110Parm[1]:End()},"Portadores"})
                EndIf

                If STR(nOpc,1) $ STR(VISUALIZAR,1)+STR(EXCLUIR,1)
	               aAdd(aBotao,{"BMPVISUAL" /*"ANALITICO"*/,{|| EE3MDet(VIS_DET,oBrw,cCod) },STR0002}) //"Visualizar"
                Else
	               aAdd(aBotao,{"BMPINCLUIR" /*"EDIT"*/,{|| EE3MDet(INC_DET,oBrw,cCod) },STR0003}) //"Incluir"
	               aAdd(aBotao,{"EDIT" /*"ALT_CAD"*/   ,{|| EE3MDet(ALT_DET,oBrw,cCod) },STR0004}) //"Alterar"
	               aAdd(aBotao,{"EXCLUIR",{|| EE3MDet(EXC_DET,oBrw,cCod,aDelEE3) },STR0005}) //"Excluir"
	               aAdd(aBotao,{/*"VCUP"*/"PMSSETAUP",{|| EE3Up(oBrw) }           ,STR0059,STR0168}) //LRL 01/03/04 - "Sobe" -  "Move para Cima"
	               aAdd(aBotao,{/*"VCDOWN"*/"PMSSETADOWN",{|| EE3Down(oBrw) }     ,STR0060,STR0169}) //LRL 01/03/04 - "Desce" - "Move para Baixo"
	            EndIf

	         Endif

         Endif

         //FDR - 12/07/12
         IF EasyEntryPoint("EECCAD00")
            EXECBLOCK("EECCAD00",.F.,.F.,{"BOTOES"})
         ENDIF

         EnchoiceBar(aParam[1],aParam[2],aParam[3],,aBotao)

      Case cAction == AC_GR // Gravar dados do work no EE3

         // *** Verificar integridade dos parametros ...
         IF Len(aParam) < 1 .Or. ValType(aParam[1]) <> "C"
            MsgStop(STR0061+CRLF+; //"Função: EE3Manut, cAction = AC_GR"
                    STR0037+CRLF+; //"O quinto parametro (aParam[1] = cCod) invalido !"
                    STR0031+ProcName(1)+CRLF+; //"Rotina: "
                    STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
            Break
         Endif
         // ***

         ProcRegua(Temp_EE3->(EasyReccount("Temp_EE3")))
         CursorWait()

         cCod  := AvKey(aParam[1],"EE3_CONTAT")
         cCompl:= AvKey(IF(Len(aParam)>1 .And. !Empty(aParam[2]),aParam[2],""),"EE3_COMPL")

         For i:=1 To Len(aDelEE3)
            EE3->(dbGoTo(aDelEE3[i]))
            IncProc(STR0063+Temp_EE3->EE3_NOME) //"Excluindo contato "

            EE3->(RecLock("EE3",.F.))
            EE3->(dbDelete())
            EE3->(MsUnlock())

            EE3->(dbSkip())
         Next i

         Temp_EE3->(dbGoTop())
         nOrdEE3 := EE3->(IndexOrd())
         nRecEE3 := EE3->(Recno())
         While ! Temp_EE3->(Eof())

            IncProc(STR0062+Temp_EE3->EE3_NOME) //"Gravando contato "

            /*IF Temp_EE3->EE3_RECNO <> 0
               EE3->(dbGoTo(Temp_EE3->EE3_RECNO))
               EE3->(RecLock("EE3",.F.))
            Else
               EE3->(RecLock("EE3",.T.))
            Endif*/

            EE3->(DbSetOrder(1))
            If EE3->(DbSeek(xFilial("EE3") + Temp_EE3->(EE3_CODCAD+EE3_CONTAT+EE3_COMPL+EE3_SEQ)))
               EE3->(RecLock("EE3",.F.))
            Else
               EE3->(RecLock("EE3",.T.))
            EndIf

            AvReplace("Temp_EE3","EE3")

            IF Temp_EE3->EE3_RECNO == 0
               EE3->EE3_FILIAL := xFilial("EE3")
               EE3->EE3_CODCAD := cCodCad
               EE3->EE3_CONTAT := cCod
               EE3->EE3_COMPL  := cCompl
            Endif

            EE3->(MsUnlock())

            Temp_EE3->(dbSkip())
         Enddo

         EE3->(DbSetOrder(nOrdEE3))
         EE3->(DbGoTo(nRecEE3))
         CursorArrow()

         If cModulo = "EIC"

             ProcRegua(Temp_EIE->(EasyReccount("Temp_EIE")))
             CursorWait()

             cCod  := AvKey(aParam[1],"EIE_ARMAD")

             Temp_EIE->(dbGoTop())

             While ! Temp_EIE->(Eof())

                 IncProc(STR0099+Temp_EIE->EIE_TIPCNT)  //"Gravando Container: "

                 IF Temp_EIE->EIE_RECNO <> 0
                    EIE->(dbGoTo(Temp_EIE->EIE_RECNO))
                    EIE->(RecLock("EIE",.F.))
                 Else
                    EIE->(RecLock("EIE",.T.))
                 Endif

                 AvReplace("Temp_EIE","EIE")

                 IF Temp_EIE->EIE_RECNO == 0
                    EIE->EIE_FILIAL := xFilial("EIE")
                    EIE->EIE_ARMAD  := cCod
                 Endif

                 EIE->(MsUnlock())

                 Temp_EIE->(dbSkip())
             Enddo

             For i:=1 To Len(aDelEIE)
                EIE->(dbGoTo(aDelEIE[i]))
                IncProc(STR0100+Temp_EIE->EIE_TIPCNT) //"Excluindo Container "

                EIE->(RecLock("EIE",.F.))
                EIE->(dbDelete())
                EIE->(MsUnlock())

                EIE->(dbSkip())
             Next i

             CursorArrow()

         Endif

         If IsInCallStack("EECAC110")
            lCpoPortador := ECI->(FieldPos("ECI_PORTAD")) > 0 .And. ECI->(FieldPos("ECI_TPPORT")) > 0
            For i := 1 To Len(aCols)
               ECI->(DbSetOrder(2)) // ECI_FILIAL+ECI_BANCOD+ECI_AGENCI+ECI_NUMCON+ECI_TPMODU+ECI_TPCONT
               lSeek := ECI->(DbSeek(xFilial("ECI")+AvKey(M->A6_COD,"ECI_BANCOD")+AvKey(M->A6_AGENCIA,"ECI_AGENCI")+AvKey(M->A6_NUMCON,"ECI_NUMCON")+;
                                     AvKey(GetInfAcols(aCols,aHeader,"ECI_TPMODU",i),"ECI_TPMODU")+;
                                     Left(GetInfAcols(aCols,aHeader,"ECI_TPCONT",i),1)))
               If GDDeleted(i)
                  If lSeek
                     ECI->(RecLock("ECI",.F.))
                     ECI->( DbDelete() )
                     ECI->(MsUnLock())
                  EndIf
               Else
                  ECI->(RecLock("ECI",!lSeek))
                  ECI->ECI_FILIAL := xFilial("ECI")
                  ECI->ECI_BANCOD := cCod
                  ECI->ECI_TPMODU := GetInfAcols(aCols,aHeader,"ECI_TPMODU" ,i)
                  ECI->ECI_TPCONT := Left(GetInfAcols(aCols,aHeader,"ECI_TPCONT" ,i),1)
                  ECI->ECI_CONTAB := GetInfAcols(aCols,aHeader,"ECI_CONTAB" ,i)
                  ECI->ECI_AGENCI := M->A6_AGENCIA
                  ECI->ECI_NUMCON := M->A6_NUMCON
                  If lCpoPortador
                     ECI->ECI_PORTAD := GDFieldGet("ECI_PORTAD" ,i)
                     ECI->ECI_TPPORT := GDFieldGet("ECI_TPPORT" ,i)
                  EndIf
                  ECI->(MsUnLock())
               EndIf
            Next
         EndIf

      Case cAction == AC_DE // Excluir dados do EE3

         // *** Verificar integridade dos parametros ...
         IF Len(aParam) < 1 .Or. ValType(aParam[1]) <> "C"
            MsgStop(STR0064+CRLF+; //"Função: EE3Manut, cAction = AC_DE"
                    STR0037+CRLF+; //"O quinto parametro (aParam[1] = cCod) invalido !"
                    STR0031+ProcName(1)+CRLF+; //"Rotina: "
                    STR0032+AllTrim(Str(ProcLine(1))),STR0026) //"Linha: "###"Aviso"
            Break
         Endif
         // ***

         ProcRegua(3)
         CursorWait()

         cCod  := AvKey(aParam[1],"EE3_CONTAT")
         cCompl:= AvKey(IF(Len(aParam)>1 .And. !Empty(aParam[2]),aParam[2],""),"EE3_COMPL")

         EE3->(dbSeek(xFilial()+cCodCad+cCod+cCompl))

         While EE3->(!Eof() .And. EE3_FILIAL == xFilial("EE3")) .And.;
               EE3->EE3_CODCAD == cCodCad .And.;
               EE3->EE3_CONTAT == cCod .And.;
               EE3->EE3_COMPL  == cCompl

            IncProc()
            i++

            EE3->(RecLock("EE3",.F.))
            EE3->(dbDelete())
            EE3->(MsUnlock())

            EE3->(dbSkip())
         Enddo
         While i <= 3
            IncProc() ; i++
         Enddo
         CursorArrow()

         If cModulo = "EIC"

            CursorWait()

            cCod  := AvKey(aParam[1],"EIE_ARMAD")

            EIE->(dbSeek(xFilial()+cCod))

            While EIE->(!Eof() .And. EIE_FILIAL == xFilial("EIE")) .And.;
                  EIE->EIE_ARMAD == cCod

                IncProc()
                i++

               EIE->(RecLock("EIE",.F.))
               EIE->(dbDelete())
               EIE->(MsUnlock())

               EIE->(dbSkip())
            Enddo
            While i <= 3
               IncProc() ; i++
            Enddo
            CursorArrow()

         Endif

      Case cAction == AC_ER // Fecha e apaga o arquivo temporario

           If AvFlags("DEMURRAGE") .And. Type("oTarifa") == "O" //FSM - 10/03/11
              oTarifa:ExcluiWork()

           EndIf
           aDelEE3 := aSize(aDelEE3,0)
           oBrw    := Nil

           Temp_EE3->(E_EraseArq(cNomArq))
           If cModulo = "EIC"
              aDelEIE := aSize(aDelEIE,0)
              Temp_EIE->(E_EraseArq(cNomArq2))
           Endif

           If IsInCallStack("EECAC110") .And. Select("Temp_ECI") > 0// BAK - 30/01/2012
              Temp_ECI->(E_EraseArq(cNomArqECI))
           EndIf

      Case cAction == "EXECAUTO"
         If Len(aParam[3]) > 0
            If EasySeekAuto("TEMP_EE3", aParam[3])
               If (nPos := aScan(aParam[3] ,{|X| AllTrim(Upper(X[1])) == "AUTDELETA"})) > 0 .And. aParam[3][nPos][2] $ cSim
                  EE3MDet(EXC_DET,oBrw,aParam[1],aDelEE3,aParam[3])
               Else
                  EE3MDet(ALT_DET,oBrw,aParam[1],       ,aParam[3])
               Endif
            Else
               EE3MDet(INC_DET,oBrw,aParam[1],       ,aParam[3])
            EndIf
         EndIf

   EndCase

End Sequence

RestOrd(aOrd)

Return NIL


/*
Funcao      : EE3MDet(nOpc,oBrw,cCod,aDelEE3)
Parametros  : nOpc := VIS_DET,INC_DET,ALT_DET,EXC_DET
Retorno     : NIL
Objetivos   : Manutencao de Contatos
Autor       : Cristiano A. Ferreira
Data/Hora   : 13/04/2000 12:00
Revisao     :
Obs.        :
*/
Static Function EE3MDet(nOpc,oBrw,cCod,aDelEE3,aEE3Auto)

Local nAreaOld := Select()
Local oDlg, cNewTit, i
Local nOpcA := 0

Local aEnchoice := { "EE3_NOME","EE3_CARGO","EE3_DEPART","EE3_FONE",;
                     "EE3_FAX","EE3_EMAIL"}
Private lEE3Auto := ValType(aEE3Auto) == "A"

Private aTela[0][0], aGets[0], bOk, bCancel

If EE3->(FieldPos("EE3_INTTRA")) > 0 .And. EECFlags("INTTRA")
   aAdd(aEnchoice,"EE3_INTTRA")
EndIf

Begin Sequence

   IF nOpc == INC_DET
      For i := 1 TO Temp_EE3->(FCount())
         IF Temp_EE3->(FieldName(i)) = "DBDELETE" .Or. ;
            Temp_EE3->(FieldName(i)) = "EE3_RECNO" .Or.;
            Temp_EE3->(FieldName(i)) = "TRB_ALI_WT" .Or.;
            Temp_EE3->(FieldName(i)) = "TRB_REC_WT"
            Loop
         Endif
         M->&(Temp_EE3->(FieldName(i))) := CriaVar(Temp_EE3->(FieldName(i)))
      Next i
   Else
      IF Temp_EE3->(Eof() .And. Bof())
         HELP(" ",1,"AVG0005018") //MsgInfo("Não há contatos cadastrados !","Aviso")
         Break
      Endif

      For i := 1 TO Temp_EE3->(FCount())
         M->&(Temp_EE3->(FieldName(i))) := Temp_EE3->(FieldGet(i))
      Next i
   Endif

   cNewTit := STR0065 //"Contatos - "

   IF nOpc == VIS_DET
      cNewTit += STR0002 //"Visualizar"
   Elseif nOpc == INC_DET
      cNewTit += STR0003 //"Incluir"
   Elseif nOpc == ALT_DET
      cNewTit += STR0004 //"Alterar"
   Else
      cNewTit += STR0005 //"Excluir"
   Endif

   cNewTit += " - "+cCod
   bOk     := {|| nOpcA:=1,IF(EE3MVal(nOpc,Temp_EE3->(Recno()),aDelEE3),if(!lEE3Auto,oDlg:End(),),nOpcA:=0) }
   bCancel := {|| if(!lEE3Auto,oDlg:End(),) }

   If !lEE3Auto
	   DEFINE MSDIALOG oDlg TITLE cNewTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

	     EnChoice("EE3", , 3, , , ,aEnchoice, PosDlg(oDlg),IF(Str(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},),3)

	   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel)
   Else
      If EnchAuto("EE3", aEE3Auto, {|| Obrigatorio(aGets,aTela)}, IF(nOpc=4,3,4), aEnchoice)
         Eval(bOk)
      Else
         Eval(bCancel)
         lMsErroAuto := .T.
      EndIf
   EndIf

   IF nOpcA == 1
      IF nOpc == INC_DET
         Temp_EE3->(dbAppend())
      Endif

      IF ! Str(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1)
         AvReplace("M","Temp_EE3")
         IF nOpc == INC_DET .And. !lEE3Auto // Retirada a chamada da funcao EE3NextSeq() quando executada ExecAuto (aEE3Auto) - BAK
            // Grava a proxima sequencia na inclusao de registros
            Temp_EE3->EE3_SEQ := EE3NextSeq()
         Endif
      Endif
      If !lEE3Auto
         oBrw:oBrowse:Refresh()
      EndIf
   Endif

End Sequence

Select(nAreaOld)

Return NIL

/*
Funcao      : EE3MVal(nOpc,nRecno,aDelEE3)
Parametros  : nOpc := VIS_DET,INC_DET,ALT_DET,EXC_DET
              nRecno := Nro. do Registro
Retorno     : .T./.F.
Objetivos   : Manutencao de Descricao em varios Idiomas
Autor       : Cristiano A. Ferreira
Data/Hora   : 12/04/2000 14:00
Revisao     :
Obs.        :
*/
Static Function EE3MVal(nOpc,nRecno,aDelEE3)

Local lRet:=.T.

Begin Sequence
   IF nOpc == INC_DET .Or. nOpc = ALT_DET
      lRet:=Obrigatorio(aGets,aTela)
   Elseif nOpc == EXC_DET
      Temp_EE3->(DBGOTO(nRecno))

      IF lEE3Auto .Or. MsgNoYes(STR0051,STR0052) //"Confirma Exclusão ?"###"Atenção"
         IF Temp_EE3->EE3_RECNO <> 0
            aAdd(aDelEE3,Temp_EE3->EE3_RECNO)
         Endif

         Temp_EE3->(dbDelete())
         Temp_EE3->(dbSkip(-1))
         IF Temp_EE3->(Bof())
            Temp_EE3->(dbGotop())
         Endif
      Endif
   Endif
End Sequence

Return lRet

/*
Funcao      : EE3Up(oBrw)
Parametros  : oBrw
Retorno     : NIL
Objetivos   : Move registro para cima
Autor       : Cristiano A. Ferreira
Data/Hora   : 14/04/2000 11:48
Revisao     :
Obs.        :
*/
Static Function EE3Up(oBrw)

Local nRec := Temp_EE3->(RecNo())
Local cSeq := Temp_EE3->EE3_SEQ
Local cSeqOld

Begin Sequence

   Temp_EE3->(dbSkip(-1))

   IF Temp_EE3->(Bof())
      Temp_EE3->(dbGoTo(nRec))
      Break
   Endif

   cSeqOld := Temp_EE3->EE3_SEQ

   Temp_EE3->EE3_SEQ := cSeq

   Temp_EE3->(dbGoTo(nRec))
   Temp_EE3->EE3_SEQ := cSeqOld

   oBrw:oBrowse:Refresh()

End Sequence

Return NIL

/*
Funcao      : EE3Down(oBrw)
Parametros  : oBrw
Retorno     : NIL
Objetivos   : Move registro para baixo
Autor       : Cristiano A. Ferreira
Data/Hora   : 14/04/2000 11:48
Revisao     :
Obs.        :
*/
Static Function EE3Down(oBrw)

Local nRec := Temp_EE3->(RecNo())
Local cSeq := Temp_EE3->EE3_SEQ
Local cSeqNext

Begin Sequence

   Temp_EE3->(dbSkip(1))

   IF Temp_EE3->(Eof())
      Temp_EE3->(dbGoTo(nRec))
      Break
   Endif

   cSeqNext := Temp_EE3->EE3_SEQ

   Temp_EE3->EE3_SEQ := cSeq

   Temp_EE3->(dbGoTo(nRec))
   Temp_EE3->EE3_SEQ := cSeqNext

   oBrw:oBrowse:Refresh()

End Sequence

Return NIL

/*
Funcao      : EE3NextSeq()
Parametros  : nenhum
Retorno     : cSeq, Proxima Sequencia
Objetivos   : Gravar no TRB a proxima sequencia
Autor       : Cristiano A. Ferreira
Data/Hora   : 07/06/99 17:01
Revisao     :
Obs.        :
*/
Static Function EE3NextSeq()

Local nRec := Temp_EE3->(RecNo())
Local cSeq

Begin Sequence

   Temp_EE3->(dbGoBottom())

   IF Temp_EE3->(Eof())
      cSeq := StrZero(1,AVSX3("EE3_SEQ",AV_TAMANHO))
   Else
      cSeq := StrZero(Val(Temp_EE3->EE3_SEQ)+1,AVSX3("EE3_SEQ",AV_TAMANHO))
   Endif

End Sequence

Temp_EE3->(dbGoTo(nRec))

Return cSeq

/*
Funcao      : ABREEEC()
Parametros  : nenhum
Retorno     : NIL
Objetivos   : Instanciar constantes publicas
Autor       : Cristiano A. Ferreira
Data/Hora   : 07/06/99 17:01
Revisao     :
Obs.        :
*/
Function ABREEEC()

Local cCodId  := UPPER(AvKey(EasyGParam("MV_AVG0035",,"PORT."),"X5_CHAVE"))
Local cTitulo := ""
Local nDecPrcUnit
Local nDecPrcTot
Local aCmpPrcUnit
Local aCmpPrcTot
Local nDecMinUnit
Local nDecMinTot
Local aCmpError
Local cMsgError
Local nPos, nInc, cAlias

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis padroes do sistema                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MV_RELT   := __RELDIR

// Inicializa variaveis para tratamento de datas
InitYear4()

//RMD - 23/08/12 - Tratamento específico para manter arquivos de trabalho - Vide EECAE109.
__KeepUsrFiles := .F.
EECSetKeepUsrFiles()

// Abre arquivos do Crystal para a Exportação
E_ARQCRW(.T.)

/*
AMS - 10/11/2005. Tratamento para verificar se a quantidade de casas decimais dos preços unitários e totais do pedido
                  e embarque, são maiores que os definidos nos parametros MV_AVG0109 e MV_AVG0110.
*/
If EasyGParam("MV_AVG0109", .T.) .And. EasyGParam("MV_AVG0110", .T.)

   nDecPrcUnit := EasyGParam("MV_AVG0109",, Nil)
   nDecPrcTot  := EasyGParam("MV_AVG0110",, Nil)
   nDecMinUnit := 99
   nDecMinTot  := 99

   If ValType(nDecPrcUnit) = "N" .and. ValType(nDecPrcTot) = "N"

      If nDecPrcUnit > 0 .and. nDecPrcTot > 0

         aCmpPrcUnit := { "EE8_PRECO",;
                          "EE8_PRECOI",;
                          "EE8_PRCUN",;
                          "EE9_PRECO",;
                          "EE9_PRECOI",;
                          "EE9_PRCUN" }

         aCmpPrcTot  := { "EE8_PRCTOT",;
                          "EE8_PRCINC",;
                          "EE9_PRCTOT",;
                          "EE9_PRCINC" }

         aCmpError := {}

         For nPos := 1 To Len(aCmpPrcUnit)

            If AvSX3(aCmpPrcUnit[nPos], 0,, .T.) .and. AvSX3(aCmpPrcUnit[nPos], AV_DECIMAL) < nDecPrcUnit

               If aScan(aCmpError, {|x| x[1] = "msg" .and. x[2] = "prcunit"}) = 0
                  aAdd(aCmpError, {"msg", "prcunit"})
               EndIf

               aAdd(aCmpError, { aCmpPrcUnit[nPos],;
                                 AvSX3(aCmpPrcUnit[nPos], AV_DECIMAL) })

               nDecMinUnit := Min(nDecMinUnit, aCmpError[Len(aCmpError)][2])

            EndIf

         Next

         For nPos := 1 To Len(aCmpPrcTot)

            If AvSX3(aCmpPrcTot[nPos], 0,, .T.) .and. AvSX3(aCmpPrcTot[nPos], AV_DECIMAL) < nDecPrcTot

               If aScan(aCmpError, {|x| x[1] = "msg" .and. x[2] = "prctot"}) = 0
                  aAdd(aCmpError, {"msg", "prctot"})
               EndIf

               aAdd(aCmpError, { aCmpPrcTot[nPos],;
                                 AvSX3(aCmpPrcTot[nPos], AV_DECIMAL) })

               nDecMinTot := Min(nDecMinTot, aCmpError[Len(aCmpError)][2])

            EndIf

         Next

         If Len(aCmpError) > 0

            cMsgError := STR0173 //"Configuração do número de casas decimais dos preços unitários/totais, incorreta."

            For nPos := 1 To Len(aCmpError)

               If aCmpError[nPos][1] = "msg"

                  cMsgError += Replicate(ENTER, 2)+;
                               STR0174+ENTER //"O parametro [x] está configurado em [y] casas decimais, sendo maior que no(s) seguinte(s) campo(s):"

                  If aCmpError[nPos][2] = "prcunit"
                     cMsgError := StrTran(cMsgError, "[x]", "MV_AVG0109")
                     cMsgError := StrTran(cMsgError, "[y]", LTrim(Str(nDecPrcUnit)))
                  Else
                     cMsgError := StrTran(cMsgError, "[x]", "MV_AVG0110")
                     cMsgError := StrTran(cMsgError, "[y]", LTrim(Str(nDecPrcTot)))
                  EndIf

               Else

                  cMsgError += ENTER+;
                               PadR(aCmpError[nPos][1], 10)+" = "+LTrim(Str(aCmpError[nPos][2]))+STR0175 //" decimais."

               EndIf

            Next

            cMsgError += Replicate(ENTER, 2)+;
                         STR0176 //"O(s) parâmetro(s) informado(s) acima devem possuir um número que defina as casas decimais para arredondamento e visualização de preços, podendo ser igual ou menor do definido na estrutura fisica dos campos."

            cMsgError += Replicate(ENTER, 2)+;
                         STR0177+ENTER //"Os parâmetros serão configurados para:"

            If nDecMinUnit < nDecPrcUnit
               cMsgError += ENTER+;
                            "MV_AVG0109 = " + LTrim(Str(nDecMinUnit))
            EndIf

            If nDecMinTot < nDecPrcTot
               cMsgError += ENTER+;
                            "MV_AVG0110 = " + LTrim(Str(nDecMinTot))
            EndIf

            MsgInfo(cMsgError, STR0103) //"Atenção"

            If nDecMinUnit < nDecPrcUnit
               SetMV("MV_AVG0109", nDecMinUnit)
            EndIf

            If nDecMinTot < nDecPrcTot
               SetMV("MV_AVG0110", nDecMinTot)
            EndIf

         EndIf

      Else

         MsgStop(STR0178, STR0103) //"Os parâmetros MV_AVG0109 e/ou MV_AVG0110 foram configurados com valores negativos. A configuração correta para estes parâmetros são números inteiros maiores que zero, onde irão configurar o número de casas decimais para arredondamento e visualização dos preços no pedido e embarque."###"Atenção"

      EndIf

   EndIf

EndIf

/* RMD - 08/12/17 - Melhoria de performance (mover para o RUP)
//RMD - Verifica a carga inicial da tabela EC6 quando a mesma estiver exclusiva no sistema
cAlias := "EC6"
ChkFile(cAlias)
If Select(cAlias) > 0
   (cAlias)->(DbSetOrder(1))
   If !(cAlias)->(DbSeek(xFilial()))
      If xFilial(cAlias) <> Space(FWSizeFilial()) .And. (cAlias)->(DbSeek(Space(FWSizeFilial())))
         While (cAlias)->EC6_FILIAL == Space(FWSizeFilial())
            nPos := (cAlias)->(Recno())
            For nInc := 1 TO (cAlias)->(FCount())
               M->&((cAlias)->(FIELDNAME(nInc))) := (cAlias)->(FieldGet(nInc))
            Next nInc
            M->EC6_FILIAL := xFilial(cAlias)
            (cAlias)->(RecLock(cAlias, .T.))
            AvReplace("M", cAlias)
            (cAlias)->(MsUnlock())
            (cAlias)->(DbGoTo(nPos))
            (cAlias)->(DbSkip())
         EndDo
      EndIf
   EndIf
EndIf
*/ 

//** RMD - Efetua a carga inicial das tabelas utilizadas na integração com os módulos financeiro e contábil
//EasyLinkAtu() //LRS - 20/10/2017 - Function transferida para o Avupdate02 
//**

Return Nil


/*
Funcao     : AVTITCAD(cALIAS)
Parametros : cALIAS:= alias do arquivo a ser pesquisado no SX2
Retorno    : Texto capitalizado do X2_NOME
Objetivos  : Retornar titulo para cadastro
Uso        : carregar a cCadastro com texto
Autor      : Heder M Oliveira
Data/Hora  : 28/04/00 17:35
Revisao    :
Obs        :
*/
FUNCTION AVTITCAD(cALIAS)
   LOCAL aORD:=SAVEORD({"SX2"}),cRET:=""
   BEGIN SEQUENCE
      IF SX2->(DBSEEK(cALIAS))
         cRET:=Capital(AllTrim(FWX2Nome(cAlias)))
      ENDIF
   END SEQUENCE
   RestOrd(aOrd,.T.)
RETURN cRET

/*
Funcao      : AddColMark(oMsSelect)
Parametros  : oMsSelect := Objeto da classes MSSELECT
Retorno     : Nenhum
Objetivos   : Adicionar a coluna de marca na MsSelect, usado qdo ha mais de
              uma MsSelect na mesma janela.
Autor       : Cristiano A. Ferreira
Data/Hora   : 12/05/2000 09:52
Revisao     :
Obs.        :
*/
Function AddColMark(oMsSelect,cField)

Local oCol
Local cBlock

Begin Sequence
   cBlock := "{|| IF(!Empty(Eval(FieldWBlock('"+cField+"'"
   cBlock += ","+LTrim(Str(Select(oMsSelect:oBrowse:cAlias)))+"))),MarkObj(1),MarkObj(2)) }"

   oMsSelect:oBrowse:aColumns[1]:bData := &cBlock
End Sequence

Return NIL

/*
Funcao      : MC110Integra
Parametros  : nOpc := 3, Solicitar integracao
              nOpc := 5, Cancelar integracao
Retorno     : nenhum
Objetivos   : Executar rotina para integracao do faturamento
Autor       : Cristiano A. Ferreira
Data/Hora   : 11/11/1999 15:15
Revisao     :
Obs.        :
*/
Function MC110Integra(nOpc,cTipo)

//Local cFunction := "EECFAT2"
//Local cBlockInt := "EECFAT"
Local lRet    := .F.
Local cRotina := EasyGParam("MV_AVG0064",,"")
//Local bExecBlock
Private lIntPedFat := .T. //MCF - 06/04/2015 - Variável utilizada no ponto de entrada INTEG_FAT.
Private cTipoPE := cTipo  // GFP - 03/06/2015

Begin Sequence

   /*
   AMS - 26/05/2004 às 13:56. Substituido a rotina abaixo, pq está sendo definido no MV_AVG0064,
                              qual rotina será executada para integrar os dados com faturamento.
                              Obs: Para o MV_AVG0064 pode ser definido EECFAT ou EECFAT2.

   If FindFunction(cFunction)
      lRet := EECFAT2(nOpc,cTipo)
   Else
      If EasyEntryPoint(cBlockInt)
         lRet := ExecBlock(cBlockInt,.F.,.F.,{nOpc,cTipo})
      Else
         //Help(" ",1,"AVG0000057")
         Help(" ",1,"NOTEECFAT")
      Endif
   EndIf
   */

   If(EasyEntryPoint("EECCAD00"),ExecBlock("EECCAD00", .F., .F.,"INTEG_FAT"),)

   If !lIntPedFat //MCF - 06/04/2015
      lRet := .T.
      Break
   Endif

   Do Case

      Case cRotina == "EECFAT"
         If EasyEntryPoint(cRotina)
            lRet := ExecBlock(cRotina, .F., .F., {nOpc,cTipo})
         Else
            EECMsg(STR0170, STR0109) //"A integração com o faturamento está configurada para executar a rotina EECFAT, porem o mesmo não se encontra compilado no RPO."###"Atenção"
            //Help(" ", 1, "AVG0000057")
         Endif

      Case cRotina == "EECFAT2"
         If FindFunction(cRotina)
            lRet := EECFAT2(nOpc,cTipo)
         Else
            EECMsg(STR0171, STR0109) //"A integração com o faturamento está configurada para executar a rotina EECFAT2, porem o mesmo não se encontra compilado no RPO."###"Atenção"
         EndIf

      Otherwise
         If EasyGParam("MV_AVG0064", .T.)
            EECMsg(STR0172, STR0109) //"O conteúdo do parametro MV_AVG0064 está vazio ou possui uma opção inválida. Informe como opção EECFAT ou EECFAT2 para indicar qual rotina será usada para integrar o pedido com o faturamento."###"Atenção"
         Else
            If Left(cVersao, 3) == "AP6"
               If EasyEntryPoint("EECFAT")
                  lRet := ExecBlock("EECFAT", .F., .F., {nOpc,cTipo})
               Else
                  Help(" ",1,"NOTEECFAT")
               Endif
            Else
               If FindFunction("EECFAT2")
                  lRet := EECFAT2(nOpc,cTipo)
               EndIf
            EndIf
         EndIf

   End Case

End Sequence

Return lRet

/*
Funcao      : AvGetCpo(cNomCpo,cTipo)
Parametros  : Nome do Campo com alias, tipo de variavel (C,N)
Retorno     : Conteudo ou (0/"")
Objetivos   : Verificar a existencia do campo e retornar conteudo
Autor       : Cristiane C. Figueiredo
Data/Hora   : 19/10/2000 13:48
Revisao     :
Obs.        :
*/
Function AvGetCpo(cNomCpo,cTipo)
Local cRet, nFat := 1

Default cTipo := "N"

If Type(cNomCpo) <> "U"
   IF cTipo == "N"
      cNomCpo := Upper(AllTrim(cNomCpo))

      do Case
         Case Substr(cNomCpo,At(">",cNomCpo)+1) == "EE7_DESP1"
            nFat := GetNewPar("MV_DESP1_P",1)
         Case Substr(cNomCpo,At(">",cNomCpo)+1) == "EE7_DESP2"
            nFat := GetNewPar("MV_DESP2_P",1)
         Case Substr(cNomCpo,At(">",cNomCpo)+1) == "EEC_DESP1"
            nFat := GetNewPar("MV_DESP1_E",1)
         Case Substr(cNomCpo,At(">",cNomCpo)+1) == "EEC_DESP2"
            nFat := GetNewPar("MV_DESP2_E",1)
      End Case

      cRet := (&cNomCpo)*nFat
   Else
      cRet := &cNomCpo
   Endif
Else
   If cTipo == "N"
      cRet := 0
   Else
      cRet := ""
   Endif
Endif

Return cRet

/*
Funcao      : BuscaRE(cEmb)
Parametros  : cEmb = Nro do Embarque
Retorno     : Nro da RE, exemplo (01/0000000-000 / 002)
Objetivos   : Montar o Nro da RE
Autor       : Cristiano A. Ferreira
Data/Hora   : 04/11/2000 11:09
Revisao     :
Obs.        :
*/
Function BuscaRE(cEmb)

Local cRet := "", aOrd := SaveOrd("EE9",3), cPreEmb := AvKey(cEmb,"EE9_PREEMB")
Local cMenorRE, cMaiorRE

Begin Sequence
   EE9->(dbSeek(xFilial()+cPreEmb))

   cMenorRE := cMaiorRE := EE9->EE9_RE

   While EE9->(!Eof() .And. EE9_FILIAL == xFilial("EE9")) .And. ;
          EE9->EE9_PREEMB == cPreEmb

      IF !Empty(EE9->EE9_RE)
         IF Empty(cMenorRE) .Or. cMenorRE > EE9->EE9_RE
            cMenorRE := EE9->EE9_RE
         Endif
         IF Empty(cMaiorRE) .Or. cMaiorRE < EE9->EE9_RE
            cMaiorRE := EE9->EE9_RE
         Endif
      Endif

      EE9->(dbSkip())
   Enddo

   cRet := Transf(cMenorRE,AVSX3("EE9_RE",AV_PICTURE))

   IF cMaiorRE <> cMenorRE
      cRet += " / "+Right(cMaiorRE,3)
   Endif

End Sequence

RestOrd(aOrd,.F.)

Return cRet

/*
Funcao      : EECMostOrig
Parametros  : Nenhum
Retorno     : Nacional/Importado/Sem Classif.
Objetivos   : Origem do Produto
Autor       : Cristiano A. Ferreira
Data/Hora   : 13/09/2000
Revisao     :
Obs.        :
*/
Function EECMostOrig

Local cRet := ""

IF Type("SB1->B1_CRTORG") <> "U" .And. !Empty(SB1->B1_CRTORG)
   IF SB1->B1_CRTORG == "1"
      cRet := STR0066 //"Nacional"
   Elseif SB1->B1_CRTORG == "2"
      cRet := STR0067 //"Importado"
   Else
      cRet := STR0068 //"Sem Classif."
   Endif
Else
   IF Left(SB1->B1_ORIGEM,1) == "0"
      cRet := STR0066 //"Nacional"
   Elseif Left(SB1->B1_ORIGEM,1) $ "1/2"
      cRet := STR0067 //"Importado"
   Else
      cRet := STR0068 //"Sem Classif."
   Endif
Endif

Return cRet

/*
Funcao      : BuscaUM(cCodUM,cIdioma)
Parametros  : cCodUM = Codigo da Unidade de Medida
              cIdioma = Idioma da descricao
Retorno     : Unidade de Medida
Objetivos   : Retornar a unidade de medida no idioma
Autor       : Cristiano A. Ferreira
Data/Hora   : 19/04/2001
Revisao     :
Obs.        :
*/
Function BuscaUM(cCodUM,cIdioma)
Local cRet := " ",;
      aOrd := SaveOrd({"EE2","SAH"})

Default cIdioma := " "

Begin Sequence
   EE2->(dbSetOrder(1))
   SAH->(dbSetOrder(1))

   IF EE2->(dbSeek(xFilial()+MC_TUNM+TM_GER+AvKey(cIdioma,"EE2_IDIOMA")+AvKey(cCodUM,"EE2_COD"))) .Or.;
         EE2->(dbSeek(xFilial()+MC_TUNM+TM_GER+AvKey("PORT. -PORTUGUES","EE2_IDIOMA")+AvKey(cCodUM,"EE2_COD"))) //PORT. PORTUGUES
      cRet := EE2->EE2_DESCMA
   Else
      cRet := AvKey(cCodUM,"AH_UNIMED")
   Endif
End Sequence

RestOrd(aOrd)

Return cRet
*--------------------------------------------------------------------
FUNCTION INTEGREF(cP_MODO,lP_MODO)
// Descricao do Vetor aSEL => {MODO,{ALIAS,CONDICAO,MENSAGEM}}
LOCAL lRET := .T., cCod := "" , lErro := .T.
Local cOldArea:= Select()
Local aSYD
Local lModulo := lP_MODO  //LGS-25/11/2013
#IFDEF TOP
   Local aSEL := {}
   Local cQRY,nA1,nA2,cFIL,cMSG := ""
#ENDIF

If lModulo # .T. .OR. Empty(lModulo) //LGS-25/11/2013
  lModulo := .F.
EndIf

Begin Sequence

   //Validação para os Módulos da Microsiga - ER - 07/04/2006 às 15:20
   Do Case

      Case cP_MODO = "SA1" // CADASTRO DE CLIENTES

           If EasyGParam("MV_EECFAT",,.F.)   //TRP-04/12/08
              cCod := SA1->A1_COD+SA1->A1_LOJA

              // Verifica se existe Orcamento no Televendas SUA
              If ChkFile("SUA")
                 SUA->(dbSetOrder(6))
                 If SUA->(DBSeek(xFilial("SUA")+cCod))
                    HELP(" ",1,"TMKNDELREL")
                    lRet := .F.
                    Break
                 EndIf
              EndIf

              // Verifica se existe Atendimento no Telemarketing SUC

              If ChkFile("SUC")
                 SUC->(dbSetOrder(2))
			     If SUC->(DBSeek(xFilial("SUC")+'SA1'+cCod))
                    HELP(" ",1,"TMKNDELREL")
                    lRet := .F.
                    Break
                 EndIf
              EndIf

              // Verifica se existe Pedido de Venda
              If ChkFile("SC5")
                 SC5->(dbSetOrder(3))

                 If SC5->(dbSeek(xFilial("SC5")+SA1->A1_COD))
			        While !Eof() .And. xFilial("SC5")+SA1->A1_COD == SC5->C5_FILIAL+;
                                                   SC5->C5_CLIENTE
			           If ((SA1->A1_LOJA == SC5->C5_LOJACLI) .and.;
   	                                     ! (SC5->C5_TIPO $ "BD"))

					      HELP(" ",1,"MA030TEMPV",, STR0179 + xFilial("SC5"), 3, 0) //"Filial "
				          lRet := .F.
				          Break
				       EndIf

				       If (SA1->A1_LOJA == SC5->C5_LOJAENT) .And. !SC5->C5_TIPO $ "DB"

					      HELP(" ",1,"MA030LOJEN",, STR0179 + xFilial("SC5"), 3, 0) //"Filial "
   					      lRet := .F.
				          Break
				       EndIf
				       DbSkip()
                    EndDo
		         EndIf
		      EndIf

		      //Verifica se existe Contas a Receber deste cliente

		      If ChkFile("SE1")

		         SE1->(DbSetOrder(2))

		         If SE1->(dbSeek(xFilial("SE1")+cCod))

                    HELP(" ",1,"MA030TEMCR",, STR0179 + xFilial("SE1"), 3, 0) //"Filial "
                    lRet := .F.
				    Break
			     EndIf
	          EndIf

		      //Verifica se existe Nota Fiscal de saida para este cliente

		      If ChkFile("SF2")

		         SF2->(dbSetOrder(2))

			     If SF2->(dbSeek(xFilial("SF2")+cCod))
                    While !Eof() .And. xFilial("SF2")+cCod == SF2->F2_FILIAL+SF2->F2_CLIENTE+SF2->F2_LOJA
                       If ! (SF2->F2_TIPO $ "BD")
                          HELP(" ",1,"MA030TEMNF",, STR0179 + xFilial("SF2"), 3, 0)  //"Filial: "
					      lRet := .F.
					      Break
				       EndIf
                       dbSkip()
			        EndDo
		         EndIf
		      EndIf
		      //Verifica se existe Base Instalada deste cliente

              If ChkFile("AA3")

                 AA3->( dbSetOrder( 1 ) )
			     If AA3->( dbSeek( xFilial( "AA3" ) + cCod ) )
                    Help( " ", 1, "MA030TEMBA" ) // "O cliente nao pode ser excluido pois existe base instalada para o mesmo !"
			        lRet := .F.
			        Break
			     EndIf
		      EndIf

              //Verifica se existe referencias cadastradas deste cliente

              If ChkFile("SAO")

                 SAO->(DbSetOrder(1))  // Contas a receber
                 If SAO->(dbSeek(xFilial("SAO")+cCod))
                    HELP(" ",1,"MATA030REF",, STR0179 + xFilial("SAO"), 3, 0) //"Filial "
				    lRet := .F.
				    Break
			     EndIf

		      EndIf

   		      //Verifica se existe Pontos por setor

		      If ChkFile("DA7")
		         DA7->(dbSetOrder(2))
			     If DA7->(DBSeek(xFilial("DA7")+cCod))
			        Help(" ",1,"NODELETA")
			        lRet := .F.
			        Break
			     Endif
	          Endif
           Endif

      Case cP_MODO = "SA2" // CADASTRO DE FORNECEDORES

           //Verifica a existencia de resgistros em Produto X Fornecedor
		   If ChkFile("SA5")
		      SA5->(DbSetOrder(1))
			  If SA5->(DbSeek(xFilial("SA5")+SA2->A2_COD+SA2->A2_LOJA))
                 HELP(" ",1,"E_DELFOFA1")
				 lRet := .F.
			     Break
              Else
			     SA5->(dbSetOrder(4))
                 If SA5->(DbSeek(xFilial("SA5")+SA2->A2_COD))
                    HELP(" ",1,"E_DELFOFA1")
                    lRet := .F.
          		    Break
                 EndIf
              EndIf
           EndIf

           //Verifica se existe Atendimento no Telemarketing
           If ChkFile("SUC")
              SUC->(DbSetOrder(2))
              If SUC->(DbSeek(xFilial("SUC")+"SA2"+SA2->A2_COD+SA2->A2_LOJA))
                 MsgStop(STR0180) //"Este fornecedor possui atendimento no telemarketing e nao podera ser excluido"
                 lRet := .F.
         		 Break
              EndIf
           EndIf

           //Verifica se existe Pedido de vendas com TIPO B ou D devolucao
		   If ChkFile("SC6")
              SC6->(DbSetOrder(5))
              If SC6->(DbSeek(xFilial("SC6")+SA2->A2_COD+SA2->A2_LOJA))
                 If ChkFile("SC5")
                    SC5->(DbSetOrder(1))
                    If SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM))
                       If SC5->C5_TIPO $"DB"
                          HELP(" ",1,"MA030TEMPV",, STR0179 + xFilial("SC5"), 3, 0) //"Filial "
                          lRet := .F.
                          Break
                       EndIf
                    EndIf
                 EndIf
			  EndIf
           EndIf

           //Verifica se existe Solicitacao de Compra colocada
           If ChkFile("SC1")
              SC1->(DbSetOrder(3))
			  If SC1->(DbSeek(xFilial("SC1")+SA2->A2_COD+SA2->A2_LOJA))
                 Help(" ",1,"MA020TEMSC",, STR0179 +xFilial("SC1"),3,0)//"Filial: "
                 lRet := .F.
                 Break
              EndIf
           EndIf

           //Verifica se existe Pedido de Compra colocada
   		   If ChkFile("SC7")
              SC7->(DbSetOrder(3))
              If SC7->(DbSeek(xFilial("SC7")+SA2->A2_COD+SA2->A2_LOJA))
                 Help(" ",1,"MA020TEMPC",, STR0179 + xFilial("SC7"),3,0)//"Filial: "
  				 lRet := .F.
                 Break
              EndIf
           EndIf

           //Verifica se existe Contas a Pagar para este fornecedor
           If ChkFile("SE2")
              SE2->(DbSetOrder(6))
              If SE2->(DbSeek(xFilial("SE2")+SA2->A2_COD+SA2->A2_LOJA))
                 Help(" ",1,"MA020TEMCP",,STR0179 + xFilial("SE2"),3,0)//"Filial: "
                 lRet := .F.
                 Break
              EndIf
           EndIf

           //Verifica se existe Nota Fiscal de entrada deste fornec.
           If ChkFile("SF1")
              SF1->(dbSetOrder(2))
              If SF1->(DbSeek(xFilial("SF1")+SA2->A2_COD+SA2->A2_LOJA))
                 While SF1->(!Eof()) .And. xFilial("SF1") == SF1->F1_FILIAL .And.;
                    SA2->A2_COD == SF1->F1_FORNECE .And.;
                    SA2->A2_LOJA == SF1->F1_LOJA
                 #IFNDEF SHELL
                    If ! (SF1->F1_TIPO $ "DB")
			     #ELSE
			        If ! (SF1->F1_TIPO $ "DB") .And. SF1->F1_CANCEL != "S"
                 #ENDIF
			           Help(" ",1,"MA020TEMNF",, STR0179 + xFilial("SF1"),3,0)//"Filial: "
                       lRet := .F.
                       Break
			        EndIf
                    SF1->(DbSkip())
                 EndDo
              EndIf
           EndIf

           // Verifica se existe Nota Fiscal de saida deste fornecedor³
		   If ChkFile("SF2")
              SF2->(dbSetOrder(2))
              SF2->(DbSeek(xFilial("SF2")+SA2->A2_COD+SA2->A2_LOJA))
              While SF2->(!Eof()) .And. xFilial("SF2") == SF2->F2_FILIAL .And.;
                    SA2->A2_COD == SF2->F2_CLIENTE .And.;
                    SA2->A2_LOJA == SF2->F2_LOJA
                 If (SF2->F2_TIPO $ "DB")
                    Help(" ",1,"MA020TEMNF",, STR0179 + xFilial("SF2"),3,0)//"Filial: "
                    lRet := .F.
                    Break
                 EndIf
				SF2->(dbSkip())
              EndDo
           EndIf

		   //Verifica se existe Amarracao por Grupo deste fornecedor
           If ChkFile("SAD")
              SAD->(DbSetOrder(1))
              If SAD->(DbSeek(xFilial("SAD")+SA2->A2_COD+SA2->A2_LOJA))
                 Help(" ",1,"MA020TEMAM",, STR0179+xFilial("SAD"),3,0)//"Filial: "
                 lRet := .F.
                 Break
              EndIf
           EndIf

  		   //Verifica se existe algum contrato de direito autoral com fornecedor selecionado.
           If ChkFile("AH1")
              AH1->(DbSetOrder(2))
              If AH1->(DbSeek(xFilial("AH1")+SA2->A2_COD+SA2->A2_LOJA))
                 Help(" ",1,"MA020TEMP4",,STR0179+xFilial("AH1"),3,0)//"Filial: "
                 lRet := .F.
                 Break
              EndIf
           EndIf

  		   //THTS - 22/03/2017 - Verifica se existe algum adiantamento a fornecedor cadastrado.
           If ChkFile("EEQ") .And. AvFlags("ADTFOREAI")//THTS - 27/03/2017 - Adiantamento de Fornecedores
              EEQ->(DbSetOrder(16))//EEQ_FILIAL, EEQ_PREEMB, EEQ_EVENT, EEQ_FASE, EEQ_FORN, EEQ_FOLOJA, EEQ_PARC
              If EEQ->(DbSeek(xFilial("EEQ")+AvKey(SA2->A2_COD, "EEQ_PREEMB")+"609"+"F"+AvKey(SA2->A2_COD, "EEQ_FORN")+AvKey(SA2->A2_LOJA, "EEQ_FOLOJA")))
                 Help(" ",1,STR0052,,STR0205,3,0)//Atenção //"Este Fornecedor/Fabricante possui adiantamento(s) vinculado."
                 lRet := .F.
                 Break
              EndIf
           EndIf

      Case cP_MODO = "SB1" // DESCRICAO GENERICA DO PRODUTO

           cCod := SB1->B1_COD

           If ChkFile("SB2") // saldos fisico e financeiro
              SB2->(DbSetOrder(1))
              If SB2->(dbSeek(xFilial("SB2")+cCod))
                 While SB2->(!EOF()) .And. xFilial("SB2")+cCod == SB2->B2_FILIAL + SB2->B2_COD
                    If SB2->(B2_QATU) != 0
                       HELP(" ",1,"MA0101")
                       lRet := .F.
                       Break
                    EndIf
                    SB2->(dbSkip())
                 EndDo
		      EndIf
		   EndIf

           If ChkFile("SB9") // Saldos Iniciais

              If SB9->(dbSeek(xFilial("SB9")+cCod))
			     If SB1->B1_FANTASM == "S"
                    lErro := .F.
                    While SB9->(!Eof()) .And. !lErro .And. xFilial("SB9")+cCod==SB9->B9_FILIAL+SB9->B9_COD
					   lErro := (SB9->B9_QINI # 0)
                       SB9->(dbSkip())
                    EndDo

                    If lErro
                       HELP(" ",1,"MA0101")
                       lRet := .F.
                       Break
                    Endif
                 EndIf
              Endif
	       EndIf

		   If ChkFile("SC1")  // solicitacoes de compra

              SC1->(dbSetOrder(2))  // seleciona o indice por produto
              If SC1->(dbSeek(xFilial("SC1")+cCod))
                 HELP(" ",1,"MA10SC")
				 lRet := .F.
                 Break
			  EndIf
           EndIf

		   If ChkFile("SC2")  // ordens de producao

              SC2->(dbSetOrder(2))  // seleciona o indice por produto
			  If SC2->(dbSeek(xFilial("SC2")+cCod))
                 HELP(" ",1,"MA010OP")
                 lRet := .F.
                 Break
              EndIf
           EndIf

           If ChkFile("SC4")  // previsoes de vendas

	          SC4->(DbSetOrder(1))
              If SC4->(dbSeek(xFilial("SC4")+cCod))
                 HELP(" ",1,"MA010_03")
 				 lRet := .F.
                 Break
              EndIf
           EndIf

           If ChkFile("SC6")  // itens dos pedidos de vendas

		      SC6->(dbSetOrder(2))  // seleciona o indice por produto
			  If SC6->(dbSeek(xFilial("SC6")+cCod))
                 HELP(" ",1,"MA010_04")
  				 lRet := .F.
                 Break
              EndIf
           EndIf

		   If ChkFile("SC7")  // pedido de compra

              SC7->(dbSetOrder(2))  // seleciona o indice por produto
              If SC7->(dbSeek(xFilial("SC7")+cCod))
                 HELP(" ",1,"MA10PC")
  				 lRet := .F.
                 Break
              EndIf
           EndIf

           If ChkFile("SC3")  // Autorizacao de Entrega

              SC3->(dbSetOrder(3)) // seleciona o indice por produto
              If SC3->(dbSeek(xFilial("SC3")+cCod))
                 HELP(" ",1,"A010AE")
 				 lRet := .F.
                 Break
              EndIf
           EndIf

           If ChkFile("SD1")  // itens das notas fiscais de entrada

              SD1->(dbSetOrder(2))  // seleciona o indice por produto
              If SD1->(dbSeek(xFilial("SD1")+cCod))
                 HELP(" ",1,"MA10NE")
 				 lRet := .F.
                 Break
              EndIf
		   EndIf

		   If ChkFile("SD2")  // itens das notas fiscais de saida

              SD2->(dbSetOrder(1))
              If SD2->(dbSeek(xFilial("SD2")+cCod))
                 HELP(" ",1,"MA10NE")
				 lRet := .F.
                 Break
	          EndIf
	       EndIf

           If ChkFile("SD3")  // movimentacoes internas

              SD3->(dbSetOrder(3))  // seleciona o indice por produto
			  If SD3->(dbSeek(xFilial("SD3")+cCod))
                 HELP(" ",1,"MA010MI")
 				 lRet := .F.
                 Break
              EndIf
           EndIf

           If ChkFile("SG1")  // estruturas dos produtos

	          SG1->(dbSetOrder(1))
              If SG1->(dbSeek(xFilial("SG1")+cCod))
                 HELP(" ",1,"MA010_07")
				 lRet := .F.
                 Break
              EndIf

              SG1->(dbSetOrder(2))  // seleciona o indice por componente
              If SG1->(dbSeek(xFilial("SG1")+cCod))
                 HELP(" ",1,"MA010_08")
				 lRet := .F.
                 Break
              EndIf
           EndIf

           If ChkFile("SG2")  // roteiro de fabricacao

	          SG2->(DbSetOrder(1))
              If SG2->(dbSeek(xFilial("SG2")+cCod))
                 HELP(" ",1,"MA010_09")
 				 lRet := .F.
                 Break
              EndIf
		   EndIf

           If ChkFile("SBG")      // Sugestao de Or‡amento

              SBG->(dbSetOrder(1))
              If SBG->(dbSeek(xFilial("SBG")+cCod))
                 HELP(" ",1,"MA010_10")
				 lRet := .F.
                 Break
              EndIf
	       EndIf

           If ChkFile("SBH")      // Sugestao de Or‡amento

              SBH->(dbSetOrder(1))
			  If SBH->(dbSeek(xFilial("SBH")+cCod))
                 HELP(" ",1,"MA010_10")
				 lRet := .F.
                 Break
              EndIf
           EndIf

           If ChkFile("SCK")       // Sugestao de Or‡amento

              SCK->(dbSetOrder(3))
			  If SCK->(dbSeek(xFilial("SCK")+cCod))
                 HELP(" ",1,"MA010_11")
				 lRet := .F.
                 Break
              EndIf
           EndIf


           If ChkFile("AH1")       // Contrato de Direito Autoral

              AH1->(dbSetOrder(1))
			  If AH1->(dbSeek(xFilial("AH1")+cCod))
                 HELP(" ",1,"MA010_12",,STR0181,1,0)//"O produto nao podera ser excluido pois existem contratos de direito autoral com este produto "
				 lRet := .F.
                 Break
              EndIf
           EndIf

           // Verifica se existe Tabela de precos
           If ChkFile("DA1")
              DA1->(dbSetOrder(2))
              If DA1->(DbSeek(xFilial("DA1")+cCod))
                 Help(" ",1,"NODELETA",,STR0182,2,0 )//"Motivo : Este produto esta sendo utilizado em uma tabela de precos."
				 lRet := .F.
                 Break
              Endif
           Endif

	       //Verificação no SIGAEIC
	       If ChkFile("SW1")  //Itens S.I.
	          SW1->(dbSetOrder(3))
 	          If SW1->(dbSeek(xFilial("SW1")+SB1->B1_COD))
 		         MsgInfo(STR0183)//"Produto possui Solicitacao de Importacao em andamento"
		         lRet:=.F.
                 Break
              EndIf
	       EndIf

       Case cP_MODO = "SA6" && Bancos

            cCod     := SA6->A6_COD
		    cConta   := SA6->A6_NUMCON
	 	    cAgencia := SA6->A6_AGENCIA

            If ChkFile("SE5")   && Movimentacao bancaria
			   SE5->(dbSetOrder(3))
			   If SE5->(DbSeek(xFilial("SE5")+cCod+cAgencia+cConta))
			      HELP(" ",1,"A070MOVBCO")
				  lRet:=.F.
                  Break
			   Endif
            EndIf

			If ChkFile("SE8")   && Saldos Bancarios
			   SE8->(dbSetOrder(1))
			   If SE8->(DbSeek(xFilial("SE8")+cCod+cAgencia+cConta)) .And. SE8->E8_SALATUA > 0
                  HELP(" ",1,"A070SALDO")
				  lRet:=.F.
                  Break
			   Endif
            EndIf

       Case cP_MODO = "SY6" // CONDICOES DE PAGAMENTO

            If ChkFile("SW2")  //P.O. Capa - SIGAEIC
               SW2->(DbSetOrder(3))
               If SW2->(DbSeek(xFilial("SW2")+SY6->Y6_COD))
                  While SW2->(!Eof() .And. W2_FILIAL+W2_COND_PA == xFilial("SW2")+SY6->Y6_COD)
                     If SW2->W2_DIAS_PA == SY6->Y6_DIAS_PA
                        Help(" ",1,"EIC060TPO")
                        lRet:=.F.
                        Break
                     EndIf
                     SW2->(DbSkip())
                  EndDo
               EndIf
            EndIf

       Case cP_Modo = "SYB" // Despesas

            If ChkFile("SWD")
               SWD->(DbSetOrder(2))
               If SWD->(DbSeek(xFilial("SWD")+SYB->YB_DESP))
                  Help(" ",1,"EIC110TDES")
                  lRet := .F.
                  Break
               EndIf
            EndIf

   End Case
   //Fim da Validação Microsiga - ER

   #IFDEF TOP
      //IF TCSRVTYPE() <> "AS/400" --- Nopado por ER - 07/04/2006 às 15:00
      IF cP_MODO = "SA1" // CADASTRO DE CLIENTES
         AADD(aSEL,{"SA1",{"EE7","((EE7_IMPORT = '"+SA1->A1_COD+"' AND EE7_IMLOJA = '"+SA1->A1_LOJA+"') OR "+;
                                  "(EE7_CLIENT = '"+SA1->A1_COD+"' AND EE7_CLLOJA = '"+SA1->A1_LOJA+"') OR "+;
                                  "(EE7_CONSIG = '"+SA1->A1_COD+"' AND EE7_COLOJA = '"+SA1->A1_LOJA+"'))",STR0069},; //"Processo Cadastrado"
                          {"EEC","((EEC_IMPORT = '"+SA1->A1_COD+"' AND EEC_IMLOJA = '"+SA1->A1_LOJA+"') OR "+;
                                  "(EEC_CLIENT = '"+SA1->A1_COD+"' AND EEC_CLLOJA = '"+SA1->A1_LOJA+"') OR "+;
                                  "(EEC_CONSIG = '"+SA1->A1_COD+"' AND EEC_COLOJA = '"+SA1->A1_LOJA+"'))",STR0070},; //"Embarque Cadastrado"
                          {"EEL","EEL_IMPORT   = '"+SA1->A1_COD+"' AND EEL_IMLOJA = '"+SA1->A1_LOJA+"'"  ,STR0071},; //"Carta de Credito Exportacao Cadastrado"
                          {"EEN","EEN_IMPORT   = '"+SA1->A1_COD+"' AND EEN_IMLOJA = '"+SA1->A1_LOJA+"'"  ,STR0072}}) //"Notify Cadastrado"

         //Validação para Microsiga - ER 10/04/2006 às 17:00
         If SF1->(Select()) <> 0
            AADD(aSEL,{"SA1",{"SF1","F1_FORNECE = '"+SA1->A1_COD + "' AND F1_LOJA = '"+SA1->A1_LOJA+"'  AND "+;
                                    "(F1_TIPO  = 'B' OR  F1_TIPO = 'D')" ,"Nota Fiscal de Entrada cadastrada"}})
         EndIf

      ELSEIF cP_MODO = "SA2" // CADASTRO DE FORNECEDORES
             AADD(aSEL,{"SA2",{"EE7","((EE7_FORN   = '"+SA2->A2_COD+"' AND EE7_FOLOJA = '"+SA2->A2_LOJA+"') OR "+;
                                      "(EE7_EXPORT = '"+SA2->A2_COD+"' AND EE7_EXLOJA = '"+SA2->A2_LOJA+"') OR "+;
                                      "(EE7_BENEF  = '"+SA2->A2_COD+"' AND EE7_BELOJA = '"+SA2->A2_LOJA+"'))",STR0069},; //"Processo Cadastrado"
                              {"EE8","((EE8_FORN   = '"+SA2->A2_COD+"' AND EE8_FOLOJA = '"+SA2->A2_LOJA+"') OR "+;
                                      "(EE8_FABR   = '"+SA2->A2_COD+"' AND EE8_FALOJA = '"+SA2->A2_LOJA+"'))",STR0073},; //"Processo Com Item Cadastrado"
                              {"EEC","((EEC_FORN   = '"+SA2->A2_COD+"' AND EEC_FOLOJA = '"+SA2->A2_LOJA+"') OR "+;
                                      "(EEC_EXPORT = '"+SA2->A2_COD+"' AND EEC_EXLOJA = '"+SA2->A2_LOJA+"') OR "+;
                                      "(EEC_BENEF  = '"+SA2->A2_COD+"' AND EEC_BELOJA = '"+SA2->A2_LOJA+"'))",STR0070},; //"Embarque Cadastrado"
                              {"EE9","((EE9_FORN   = '"+SA2->A2_COD+"' AND EE9_FOLOJA = '"+SA2->A2_LOJA+"') OR "+;
                                      "(EE9_FABR   = '"+SA2->A2_COD+"' AND EE9_FALOJA = '"+SA2->A2_LOJA+"'))",STR0074},; //"Embarque Com Item Cadastrado"
                              {"EEL","((EEL_EXPORT = '"+SA2->A2_COD+"' AND EEL_EXLOJA = '"+SA2->A2_LOJA+"') OR "+;
                                      "(EEL_BENEF  = '"+SA2->A2_COD+"' AND EEL_BELOJA = '"+SA2->A2_LOJA+"'))",STR0071},; //"Carta de Credito Exportacao Cadastrado"
                              {"SY5","Y5_FORNECE   = '"+SA2->A2_COD+"' AND Y5_LOJAF   = '"+SA2->A2_LOJA+"'"  ,STR0076},; //"Despachante/Empresa Cadastrado"
                              {"EJW","EJW_IMPORT   = '"+SA2->A2_COD+"' AND EJW_LOJIMP = '"+SA2->A2_LOJA+"'"  ,STR0199},; //"Despachante/Empresa Cadastrado em Pedido de Siscoserv"
                              {"EJW","EJW_EXPORT   = '"+SA2->A2_COD+"' AND EJW_LOJEXP = '"+SA2->A2_LOJA+"'"  ,STR0199}}) //"Despachante/Empresa Cadastrado em Pedido de Siscoserv"
                            /* ER - Nopado, porque a validação já é feita via Seek.
                              {"SA5","((A5_FORNECE = '"+SA2->A2_COD+"' AND A5_LOJA    = '"+SA2->A2_LOJA+"') OR "+;
                                      "(A5_FABR    = '"+SA2->A2_COD+"' AND A5_FALOJA  = '"+SA2->A2_LOJA+"'))",STR0075},; //"Produto X Fornecedor Cadastrado"

                            */
      ELSEIF cP_MODO = "SB1" // DESCRICAO GENERICA DO PRODUTO
             AADD(aSEL,{"SB1",{"EE8","EE8_COD_I    = '"+SB1->B1_COD+"'",STR0073},; //"Processo Com Item Cadastrado"
                              {"EE9","EE9_COD_I    = '"+SB1->B1_COD+"'",STR0074},; //"Embarque Com Item Cadastrado"
                              {"SA5","A5_PRODUTO   = '"+SB1->B1_COD+"'",STR0075},; //"Produto X Fornecedor Cadastrado"
                              {"EJX","EJX_ITEM     = '"+SB1->B1_COD+"'",STR0200 }}) //"Item com Pedido de Siscoserv cadastrado"
      ELSEIF cP_MODO = "SY5" // DESPACHANTES / EMPRESAS
             AADD(aSEL,{"SY5",{"EEB","EEB_CODAGE   = '"+SY5->Y5_COD+"'",STR0077},; //"Agente Cadastrado"
                              {"EEC","EEC_CODAGT   = '"+SY5->Y5_COD+"'",STR0070},; //"Embarque Cadastrado"
                              {"SA1","A1_CODAGE    = '"+SY5->Y5_COD+"'",STR0078}}) //"Cliente Cadastrado"
      ELSEIF cP_MODO = "SA6" // CADASTRO DE BANCOS
             AADD(aSEL,{"SA6",{"EEJ","EEJ_CODIGO   = '"+SA6->A6_COD+"'",STR0069},; //"Processo Cadastrado"
                              {"EEL","((EEL_BCOCON = '"+SA6->A6_COD+"' AND EEL_AGCCON = '"+SA6->A6_AGENCIA+"') OR "+;
                                      "(EEL_BCOAV  = '"+SA6->A6_COD+"' AND EEL_AGCAV  = '"+SA6->A6_AGENCIA+"') OR "+;
                                      "(EEL_BCOEM  = '"+SA6->A6_COD+"' AND EEL_AGCEM  = '"+SA6->A6_AGENCIA+"'))",STR0071},; //"Carta de Credito Exportacao Cadastrado"
                              {"SA1","(A1_BCO1     = '"+SA6->A6_COD+"' OR A1_BCO2 = '"+SA6->A6_COD+"' OR "+;
                                      "A1_BCO3     = '"+SA6->A6_COD+"' OR A1_BCO4 = '"+SA6->A6_COD+"' OR "+;
                                      "A1_BCO5     = '"+SA6->A6_COD+"')",STR0078},; //"Cliente Cadastrado"
                              {"SA2","((A2_BANCO   = '"+SA6->A6_COD+"' AND A2_AGENCIA = '"+SA6->A6_AGENCIA+"') OR "+;
                                      "(A2_REPR_BA = '"+SA6->A6_COD+"' AND A2_REPR_AG = '"+SA6->A6_AGENCIA+"'))",STR0079},; //"Fornecedor Cadastrado"
                              {"SY5","Y5_BANCO     = '"+SA6->A6_COD+"' AND Y5_AGENCIA = '"+SA6->A6_AGENCIA+"'"  ,STR0080},; //"Despachate/Empresa Cadastrado"
                              {"EEQ","((EEQ_BANC   = '"+SA6->A6_COD+"' AND EEQ_AGEN   = '"+SA6->A6_AGENCIA+"') OR "+;
                                      "(EEQ_BCOCR  = '"+SA6->A6_COD+"' AND EEQ_AGCR   = '"+SA6->A6_AGENCIA+"'))","Valor das Parcelas do Embarque"},;
                              {"EF3","((EF3_BANC   = '"+SA6->A6_COD+"' AND EF3_AGEN   = '"+SA6->A6_AGENCIA+"') OR "+;
                                      "(EF3_BC_MOV = '"+SA6->A6_COD+"' AND EF3_AG_MOV = '"+SA6->A6_AGENCIA+"') OR "+;
                                      "(EF3_BAN_FI = '"+SA6->A6_COD+"' AND EF3_AGENFI = '"+SA6->A6_AGENCIA+"'))","Eventos do Contrato"},;
                              {"EF1","((EF1_BAN_FI = '"+SA6->A6_COD+"' AND EF1_AGENFI   = '"+SA6->A6_AGENCIA+"') OR "+;
                                      "(EF1_BAN_MO = '"+SA6->A6_COD+"' AND EF1_AGENMO = '"+SA6->A6_AGENCIA+"'))","Capa do Financiamento (Exp)"}})
      ELSEIF cP_MODO = "SY6" // CONDICOES DE PAGAMENTO
             AADD(aSEL,{"SY6",{"EE7","EE7_CONDPA = '"+SY6->Y6_COD+"' AND EE7_DIASPA = " +STR(SY6->Y6_DIAS_PA,AVSX3("Y6_DIAS_PA",AV_TAMANHO),0),STR0069},; //"Processo Cadastrado"
                              {"EEC","EEC_CONDPA = '"+SY6->Y6_COD+"' AND EEC_DIASPA = " +STR(SY6->Y6_DIAS_PA,AVSX3("Y6_DIAS_PA",AV_TAMANHO),0),STR0070},; //"Embarque Cadastrado"
                              {"SA1","A1_CONDPAG = '"+SY6->Y6_COD+"' AND A1_DIASPAG = " +STR(SY6->Y6_DIAS_PA,AVSX3("Y6_DIAS_PA",AV_TAMANHO),0),STR0078}}) //"Cliente Cadastrado"
      ELSEIF cP_MODO = "SYF" // MOEDAS
             AADD(aSEL,{"SYF",{"EE7","EE7_MOEDA = '"+SYF->YF_MOEDA+"'",STR0069},; //"Processo Cadastrado"
                              {"EEC","EEC_MOEDA = '"+SYF->YF_MOEDA+"'",STR0070},; //"Embarque Cadastrado"
                              {"EEL","EEL_MOEDA = '"+SYF->YF_MOEDA+"'",STR0071},; //"Carta de Credito Exportacao Cadastrado"
                              {"SA5","A5_MOE_US = '"+SYF->YF_MOEDA+"'",STR0075},; //"Produto X Fornecedor Cadastrado"
                              {"SYE","YE_MOEDA  = '"+SYF->YF_MOEDA+"'",STR0081},; //"Taxa de Conversao Cadastrado"
                              {"SYR","YR_MOEDA  = '"+SYF->YF_MOEDA+"'",STR0082}}) //"Taxa de Frete Cadastrado"
      ELSEIF cP_MODO = "SYA" // PAISES
             AADD(aSEL,{"SYA",{"EE1"," EE1_PAIS   = '"+SYA->YA_CODGI+"'" ,STR0083},; //"Paises X Documentos Cadastrado"
                              {"EEC","(EEC_PAISDT = '"+SYA->YA_CODGI+"' OR "+;
                                      "EEC_PAISET = '"+SYA->YA_CODGI+"')",STR0070},; //"Embarque Cadastrado"
                              ;// by CAF 24/08/2001 {"EEI"," EEI_PAIS   = '"+SYA->YA_CODGI+"'" ,STR0084},; //"Produto X Pais X Normas Cadastrado"
                              {"SA1"," A1_PAIS    = '"+SYA->YA_CODGI+"'" ,STR0078},; //"Cliente Cadastrado"
                              {"SA2","(A2_PAIS    = '"+SYA->YA_CODGI+"' OR "+;
                                      "A2_REPPAIS = '"+SYA->YA_CODGI+"')",STR0079},; //"Fornecedor Cadastrado"
                              {"SA6"," A6_COD_P   = '"+SYA->YA_CODGI+"'" ,STR0085},; //"Banco Cadastrado"
                              {"SY4"," Y4_PAIS    = '"+SYA->YA_CODGI+"'" ,STR0086},; //"Agente Embarcador Cadastrado"
                              {"SY5"," Y5_PAIS    = '"+SYA->YA_CODGI+"'" ,STR0087},; //"Despachante / Empresas Cadastrado"
                              {"SY9"," Y9_PAIS    = '"+SYA->YA_CODGI+"'" ,STR0088},; //"Porto Cadastrado"
                              {"SYR","(YR_PAIS_DE = '"+SYA->YA_CODGI+"' OR "+;
                                      "YR_PAIS_OR = '"+SYA->YA_CODGI+"')",STR0082},; //"Taxa de Frete Cadastrado"
                              {"SYT"," YT_COD_P   = '"+SYA->YA_CODGI+"'" ,STR0089},; //"Importador / Consignatario Cadastrado"
                              {"SYW"," YW_PAIS    = '"+SYA->YA_CODGI+"'" ,STR0090}}) //"Corretor Cadastrado"
                              /*
                              AMS - 05/04/2005. Implementação de consistência na tabela de pedido.
                              */
                              If EE7->(FieldPos("EE7_PAISDT") > 0 .and. FieldPos("EE7_PAISET") > 0)
                                 aAdd(aSel[1], {"EE7", "(EE7_PAISDT = '"+SYA->YA_CODGI+"' OR "+;
                                                        "EE7_PAISET = '"+SYA->YA_CODGI+"')", "Pedido Cadastrado"})
                              EndIf
      ELSEIF cP_MODO = "SYQ" // VIAS DE TRANSPORTE
             AADD(aSEL,{"SYQ",{"EE7","EE7_VIA = '"+SYQ->YQ_VIA+"'",STR0069},; //"Processo Cadastrado"
                              {"EEC","EEC_VIA = '"+SYQ->YQ_VIA+"'",STR0070},; //"Embarque Cadastrado"
                              {"SYK","YK_VIA  = '"+SYQ->YQ_VIA+"'",STR0091}}) //"Seguro Cadastrado"
      ELSEIF cP_MODO = "SY9" // PORTOS
             AADD(aSEL, {"SY9", {"SYR","YR_DESTINO = '"+SY9->Y9_COD+"'",STR0082},; //"Taxa de Frete Cadastrado"
                                {"EE7","(EE7_DEST  = '"+SY9->Y9_SIGLA+"' OR "+;
                                       "EE7_ORIGEM = '"+SY9->Y9_SIGLA+"')", "Pedido Cadastrado"},;
                                {"EEC","(EEC_DEST  = '"+SY9->Y9_SIGLA+"' OR "+;
                                       "EEC_ORIGEM = '"+SY9->Y9_SIGLA+"')", "Embarque Cadastrado"}})
      ELSEIF cP_MODO = "EE5" // EMBALAGENS
             If isBlind()
                AADD(aSEL,{"EE5",{"EE7","EE7_EMBAFI = '"+EE5->EE5_CODEMB+"'",STR0069},; //"Processo Cadastrado"
                                 {"EE8","EE8_EMBAL1 = '"+EE5->EE5_CODEMB+"'",STR0073},; //"Processo Com Item Cadastrado"
                                 {"EEC","EEC_EMBAFI = '"+EE5->EE5_CODEMB+"'",STR0070},; //"Embarque Cadastrado"
                                 {"EE9","EE9_EMBAL1 = '"+EE5->EE5_CODEMB+"'",STR0074},; //"Embarque Com Item Cadastrado"
                                 {"EEO","EEO_CODEMB = '"+EE5->EE5_CODEMB+"'",STR0092},; //"Packing List Cadastrado"
                                 {"SB1","B1_CODEMB  = '"+EE5->EE5_CODEMB+"'",STR0093}}) //"Produto Cadastrado"
             Else
                AADD(aSEL,{"EE5",{"EE7","EE7_EMBAFI = '"+EE5->EE5_CODEMB+"'",STR0069},; //"Processo Cadastrado"
                                 {"EE8","EE8_EMBAL1 = '"+EE5->EE5_CODEMB+"'",STR0073},; //"Processo Com Item Cadastrado"
                                 {"EEC","EEC_EMBAFI = '"+EE5->EE5_CODEMB+"'",STR0070},; //"Embarque Cadastrado"
                                 {"EE9","EE9_EMBAL1 = '"+EE5->EE5_CODEMB+"'",STR0074},; //"Embarque Com Item Cadastrado"
                                 {"EEO","EEO_CODEMB = '"+EE5->EE5_CODEMB+"'",STR0092}}) //"Packing List Cadastrado"
             EndIf

      ELSEIF cP_MODO = "SAH" // CADASTRO DE UNIDADES DE MEDIDA
             AADD(aSEL,{"SAH",{"EE8","EE8_UNIDAD = '"+SAH->AH_UNIMED+"'" ,STR0069},; //"Processo Cadastrado"
                              {"EE9","EE9_UNIDAD = '"+SAH->AH_UNIMED+"'" ,STR0070},; //"Embarque Cadastrado"
                              {"SA5","A5_UNID    = '"+SAH->AH_UNIMED+"'" ,STR0094},; //"Amarracao Produto X Fornecedor Cadastrado"
                              {"SB1","(B1_UM     = '"+SAH->AH_UNIMED+"' OR "+;
                                      "B1_SEGUM  = '"+SAH->AH_UNIMED+"')",STR0093},; //"Produto Cadastrado"
                              {"SYD","YD_UNID    = '"+SAH->AH_UNIMED+"'" ,STR0095}}) //"NCM Cadastrado"
      ELSEIF cP_MODO = "SYJ" // INCOTERMS
             AADD(aSEL,{"SYJ",{"EE7","EE7_INCOTE = '"+SYJ->YJ_COD+"'",STR0069},; //"Processo Cadastrado"
                              {"EEC","EEC_INCOTE = '"+SYJ->YJ_COD+"'",STR0070},; //"Embarque Cadastrado"
                              {"SA5","A5_INCOTER = '"+SYJ->YJ_COD+"'",STR0094}}) //"Amarracao Produto X Fornecedor Cadastrado"
      ELSEIF cP_MODO = "SYD" // NCM
      		 aSYD := {"SYD"}
             If EE8->(FieldPos("EE8_DTQNCM")) > 0
             	aAdd(aSYD, {"EE8","EE8_POSIPI = '"+SYD->YD_TEC+"' And EE8_DTQNCM = '" + SYD->YD_DESTAQU + "'",STR0073})
             Else
             	aAdd(aSYD, {"EE8","EE8_POSIPI = '"+SYD->YD_TEC+"'",STR0073})
             EndIf

             If EE9->(FieldPos("EE9_DTQNCM")) > 0
             	aAdd(aSYD, {"EE9","EE9_POSIPI = '"+SYD->YD_TEC+"' And EE9_DTQNCM = '" + SYD->YD_DESTAQU + "'",STR0074})
             Else
             	aAdd(aSYD, {"EE9","EE9_POSIPI = '"+SYD->YD_TEC+"'",STR0074})
             EndIf

             //{"SB1","B1_POSIPI  = '"+SYD->YD_TEC+"'",STR0093} - Removido por não tratar o destaque no cadastro de produtos (inviabiliza a exclusão de NCM com EX)
             AADD(aSEL, aClone(aSYD))

      ELSEIF cP_MODO = "SJ1" // NALADI SH
             AADD(aSEL,{"SJ1",{"EE8","EE8_NALSH = '"+SJ1->J1_CODIGO+"'",STR0073},; //"Processo Com Item Cadastrado"
                              {"EE9","EE9_NALSH = '"+SJ1->J1_CODIGO+"'",STR0074},; //"Embarque Com Item Cadastrado"
                              {"SB1","B1_NALSH  = '"+SJ1->J1_CODIGO+"'",STR0093},; //"Produto Cadastrado"
                              {"SYD","YD_NAL_SH = '"+SJ1->J1_CODIGO+"'",STR0095}}) //"NCM Cadastrado"
      ElseIf cP_Modo = "EE4" // Mensagens
             aAdd(aSel,{"EE4",{"EE7","EE7_MOTSIT = '"+EE4->EE4_COD+"'","Pedido com Mensagem cadastrada"},;
                              {"EEC","EEC_MOTSIT = '"+EE4->EE4_COD+"'","Embarque com Mensagem cadastrada"}})
      ElseIf cP_Modo = "SYC" // Familia de Produtos
             aAdd(aSel,{"SYC",{"EE8","EE8_FPCOD = '"+SYC->YC_COD+"'","Item do pedido com Familia cadastrada"},;
                              {"EE9","EE9_FPCOD = '"+SYC->YC_COD+"'","Item do embarque com Familia cadastrada"}})
      ElseIf cP_Modo = "SYB" // Despesas
             aAdd(aSel,{"SYB",{"EET","EET_DESPES = '"+SYB->YB_DESP+"'","Despesas de Exportação cadastrada"}})
      ElseIf cP_Modo = "EEI" // Normas
             aAdd(aSel,{"EEI",{"EE8","EE8_CODNOR = '"+EEI->EEI_COD+"'","Item do pedido com Norma cadastrada"},;
                              {"EE9","EE9_CODNOR = '"+EEI->EEI_COD+"'","Item do embarque com Norma cadastrada"}})
      ElseIf cP_Modo = "EE6" // Disponibilidade de Navios.
             If EE7->(FieldPos("EE7_EMBARC")) > 0  // By JPP  - 19/04/2005 - 15:30 - Verificar se existe o campo EE7_EMBARC - Antes de adiciona-lo no array.
                aAdd(aSel,{"EE6",{"EE7","EE7_EMBARC = '"+EE6->EE6_COD+"'","Pedido com Navio cadastrado"},;
                                 {"EEC","EEC_EMBARC = '"+EE6->EE6_COD+"'","Embarque com Navio cadastrado"}})
             Else
                aAdd(aSel,{"EE6",{"EEC","EEC_EMBARC = '"+EE6->EE6_COD+"'","Embarque com Navio cadastrado"}})
             EndIf
      ElseIf cP_Modo = "SJ0" // U.R.F.s
             aAdd(aSel,{"SJ0",{"EEC","(EEC_URFDSP = '"+SJ0->J0_CODIGO+"' OR"+;
                                     " EEC_URFENT = '"+SJ0->J0_CODIGO+"')","Embarque com U.R.F´s cadastrada"}})
      ElseIf cP_Modo = "SJ9" // Agencia SECEX
             aAdd(aSel,{"SJ9",{"EEC","EEC_SECEX = '"+SJ9->J9_CODIGO+"'","Embarque com Agencia SECEX cadastrada"}})
      ElseIf cP_Modo = "EED" // Enquadramento
             aAdd(aSel,{"EED",{"EEC","(EEC_ENQCOD = '"+EED->EED_ENQCOD+"' OR"+;
                                     " EEC_ENQCOX = '"+EED->EED_ENQCOD+"' OR"+;
                                     " EEC_ENQCO1 = '"+EED->EED_ENQCOD+"' OR"+;
                                     " EEC_ENQCO2 = '"+EED->EED_ENQCOD+"' OR"+;
                                     " EEC_ENQCO3 = '"+EED->EED_ENQCOD+"' OR"+;
                                     " EEC_ENQCO4 = '"+EED->EED_ENQCOD+"' OR"+;
                                     " EEC_ENQCO5 = '"+EED->EED_ENQCOD+"')", "Embarque com Enquadramento cadastrado"}})
      ElseIf cP_Modo = "EEF" // Modalidade de Pagamento
             aAdd(aSel,{"EEF",{"EE7","EE7_MPGEXP = '"+EEF->EEF_COD+"'","Pedido com Modalidade de Pagamento cadastrado"},;
                              {"EEC","EEC_MPGEXP = '"+EEF->EEF_COD+"'","Embarque com Modalidade de Pagamento cadastrado"}})
      ElseIf cP_Modo = "EEE" // Instrumento de Negociação
             aAdd(aSel,{"EEE",{"EEC", "EEC_INSCOD = '"+EEE->EEE_INSCOD+"'","Embarque com Instrumento de Negociação cadastrada"}})

      //RRC - 24/09/2012 - Verifica se o código NBS foi utilizado pelo sistema
      ElseIf cP_Modo = "EL0" // Cadastro de NBS - Nomenclatura Brasileira de Serviços
             aAdd(aSel,{"EJX",{"EJX", "EJX_NBS = '"+EL0->EL0_COD+"'","Código NBS utilizado por Pedido de Serviços."}})
             aAdd(aSel,{"EJZ",{"EJZ", "EJZ_NBS = '"+EL0->EL0_COD+"'","Código NBS utilizado por Registro de Serviços"}})
             aAdd(aSel,{"SB5",{"SB5", "B5_NBS = '"+EL0->EL0_COD+"'","Código NBS utilizado nos Dados Adicionais do Produto"}})

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
                   cMSG := cMSG+aSEL[nA1,nA2,3]+ENTER
                ENDIF
                QRY->(DBCLOSEAREA())
             NEXT
         NEXT
         IF ! EMPTY(cMSG) .and. ! EMPTY(cP_MODO)
            If IsBlind() //Type("lExecAuto") == "L" .And. lExecAuto
               If !lModulo
               	 EasyHelp(STR0096+ENTER+cMSG,STR0052)
               Else
                 EasyHelp(STR0096+ENTER+STR0203,STR0052) //LGS-25/11/2013 - Banco sendo utilizado no Pedido de Exportação no Modulo de Exportação - SIGAEEC
               EndIf
            Else
               If !lModulo
               	 MSGINFO(STR0096+ENTER+cMSG,STR0052) //"Exclusao Não Permitida:"###"Atenção"
               Else
                 MSGINFO(STR0096+ENTER+STR0203,STR0052) //LGS-25/11/2013 - Banco sendo utilizado no Pedido de Exportação no Modulo de Exportação - SIGAEEC
               EndIf
            EndIf
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
*--------------------------------------------------------------------


/*
Funcao      : DetArm(nOpc,oBrw,cCod,aDelEIE)
Parametros  : nOpc := VIS_DET,INC_DET,ALT_DET,EXC_DET
Retorno     : NIL
Objetivos   : Manutencao de Tabelas do Armador
Autor       : Osman Medeiros Jr.
Data/Hora   : 19/07/2001 14:20
Revisao     :
Obs.        :
*/
Static Function DetArm(nOpc,oBrw,cCod,aDelEIE)

Local nAreaOld := Select()
Local oDlg, cNewTit, i
Local nOpcA := 0

Local aEnchoice := { "EIE_TIPCNT","EIE_DESCNT","EIE_ATE1","EIE_ATE2","EIE_ATE3",;
                     "EIE_VAL1","EIE_VAL2","EIE_VAL3","EIE_ATRASO"}

Private aTela[0][0], aGets[0], bOk, bCancel
Private nOpc2 := nOpc

Begin Sequence

   IF nOpc == INC_DET
      For i := 1 TO Temp_EIE->(FCount())
         IF Temp_EIE->(FieldName(i)) = "DBDELETE" .Or. ;
            Temp_EIE->(FieldName(i)) = "EIE_RECNO" .Or. ;
            Temp_EIE->(FieldName(i)) = "TRB_ALI_WT" .Or. ;  //TRP-29/11/2007
            Temp_EIE->(FieldName(i)) = "TRB_REC_WT"         //TRP-29/11/2007
            Loop
         Endif
         M->&(Temp_EIE->(FieldName(i))) := CriaVar(Temp_EIE->(FieldName(i)))
      Next i
   Else
      IF Temp_EIE->(Eof() .And. Bof())
         HELP(" ",1,"AVG0000666") // Não existem tabelas cadastradas
         Break
      Endif

      For i := 1 TO Temp_EIE->(FCount())
         M->&(Temp_EIE->(FieldName(i))) := Temp_EIE->(FieldGet(i))
      Next i
   Endif

   cNewTit := STR0101 //"Tabelas do Armador - "

   IF nOpc == VIS_DET
      cNewTit += STR0002 //"Visualizar"
   Elseif nOpc == INC_DET
      cNewTit += STR0003 //"Incluir"
   Elseif nOpc == ALT_DET
      cNewTit += STR0004 //"Alterar"
   Else
      cNewTit += STR0005 //"Excluir"
   Endif

   cNewTit += " - "+cCod

   DEFINE MSDIALOG oDlg TITLE cNewTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

     EnChoice("EIE", , 3, , , ,aEnchoice, PosDlg(oDlg),IF(Str(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},),3)

     bOk     := {|| nOpcA:=1,IF(ValArm(nOpc,Temp_EIE->(Recno()),aDelEIE),oDlg:End(),nOpcA:=0) }
     bCancel := {|| oDlg:End() }

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel)

   IF nOpcA == 1
      IF nOpc == INC_DET
         Temp_EIE->(dbAppend())
      Endif

      IF ! Str(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1)
         AvReplace("M","Temp_EIE")
      Endif

      oBrw:oBrowse:Refresh()
   Endif

End Sequence

Select(nAreaOld)

Return NIL

/*
Funcao      : ValArm(nOpc,nRecno,aDelEIE)
Parametros  : nOpc := VIS_DET,INC_DET,ALT_DET,EXC_DET
              nRecno := Nro. do Registro
Retorno     : .T./.F.
Objetivos   : Manutencao de Descricao em varios Idiomas
Autor       : Cristiano A. Ferreira
Data/Hora   : 12/04/2000 14:00
Revisao     :
Obs.        :
*/
Static Function ValArm(nOpc,nRecno,aDelEIE)

Local lRet:=.T.

Begin Sequence
   IF nOpc == INC_DET .Or. nOpc = ALT_DET
      lRet:=Obrigatorio(aGets,aTela)
   Elseif nOpc == EXC_DET
      Temp_EIE->(DBGOTO(nRecno))

      IF MsgNoYes(STR0051,STR0052) //"Confirma Exclusão ?"###"Atenção"
         IF Temp_EIE->EIE_RECNO <> 0
            aAdd(aDelEIE,Temp_EIE->EIE_RECNO)
         Endif

         Temp_EIE->(dbDelete())
         Temp_EIE->(dbSkip(-1))
         IF Temp_EIE->(Bof())
            Temp_EIE->(dbGotop())
         Endif
      Endif
   Endif
End Sequence

Return lRet


/*
Funcao      : ArmUp(oBrw)
Parametros  : oBrw
Retorno     : NIL
Objetivos   : Move registro para cima
Autor       : Osman Medeiros jr.
Data/Hora   : 19/07/2001 14:48
Revisao     :
Obs.        :
*/
Static Function ArmUp(oBrw)

Local nRec := Temp_EIE->(RecNo())

Begin Sequence

   Temp_EIE->(dbSkip(-1))

   IF Temp_EIE->(Bof())
      Temp_EIE->(dbGoTo(nRec))
      Break
   Endif

   oBrw:oBrowse:Refresh()

End Sequence

Return NIL

/*
Funcao      : ArmDown(oBrw)
Parametros  : oBrw
Retorno     : NIL
Objetivos   : Move registro para baixo
Autor       : Osman Medeiros Jr.
Data/Hora   : 19/07/2001 17:44
Revisao     :
Obs.        :
*/
Static Function ArmDown(oBrw)

Local nRec := Temp_EIE->(RecNo())

Begin Sequence

   Temp_EIE->(dbSkip(1))

   IF Temp_EIE->(Eof())
      Temp_EIE->(dbGoTo(nRec))
      Break
   Endif

   oBrw:oBrowse:Refresh()

End Sequence

Return NIL

/*
Funcao      : EIE_ValCampos()
Parametros  : cCampo
Retorno     : lRet
Objetivos   : Validação dos Campos do EIE
Autor       : Osman Medeiros Jr.
Data/Hora   : 20/07/2001 08:41
Revisao     :
Obs.        :
*/
*--------------------------------------*
Function EIE_ValCampos(cCampo)
*--------------------------------------*
Local LRet := .T.
Local xVar:=&(cCampo)

If SubStr(cCampo,1,10) = "M->EIE_ATE"
   If cCampo = "M->EIE_ATE1"
       xVarD := &(SubStr(cCampo,1,10)+ AllTrim(Str(Val(SubStr(cCampo,11,1))+1)))
       If xVarD > 0
          If xVar >= xVarD
             Help("", 1,"AVG0000665") // Numero de Dias menor que o Anterior, ou maior que o Proximo.
             lRet := .F.
          Endif
       Endif
   Else
       xVarA := &(SubStr(cCampo,1,10)+ AllTrim(Str(Val(SubStr(cCampo,11,1))-1)))
       cValM  := AllTrim(Str(Val(SubStr(cCampo,11,1))+1))
       cAux   := 'EIE_ATE'+ cValM
       If Type('M->'+cAux) <> "U"
           If xVar > xVarA
              xVarD := &(SubStr(cCampo,1,10)+ AllTrim(Str(Val(SubStr(cCampo,11,1))+1)))
              If xVarD > 0
                 If xVar >= xVarD
                    Help("", 1,"AVG0000665") // Numero de Dias menor que o Anterior, ou maior que o Proximo.
                    lRet := .F.
                 Endif
              Endif
           Else
              If xVar > 0
                 Help("", 1,"AVG0000665") // Numero de Dias menor que o Anterior, ou maior que o Proximo.
                 lRet := .F.
              Endif
           Endif
       Else
           If xVar > 0
              If xVar <= xVarA
                 Help("", 1,"AVG0000665") // Numero de Dias menor que o Anterior, ou maior que o Proximo.
                 lRet := .F.
              Endif
           Endif
       Endif
   Endif
Endif

If cCampo = "M->EIE_TIPCNT"
    nRecTemp_EIE := Temp_EIE->(Recno())
	Temp_EIE->(dbSetOrder(1))
	If Temp_EIE->(dbSeek(M->EIE_TIPCNT))
      If nOpc2 <> INC_DET
	    If nRecTemp_EIE <> Temp_EIE->(Recno())
   	       Help("", 1,"AVG0000667")  // Ja existe tabela deste tipo de container cadastrada para este Armador.
		   lRet := .F.
		Endif
	  Else
	    Help("", 1,"AVG0000667")  // Ja existe tabela deste tipo de container cadastrada para este Armador.
		lRet := .F.
	  EndIf
	Endif
    Temp_EIE->(dbGoto(nRecTemp_EIE))
Endif

Return lRet

/*
Funcao    : EECAT180()
Parametros: Nenhum
Objetivos : Tabela de Normas
Autor     : Cristiano A. Ferreira
Data/Hora : 31/07/2001 16:40
Revisão   : Clayton Fernandes - 29/03/2011
Obs       : Adaptação do Codigo para o padrão MVC
*/
Function EECAT180(nOpc)
Local lRet  := .T.,cOldArea:=select()

// BAK - Alteração para o consulta para de normas
Local aOrd:=SaveOrd({"SX3"})
Local aCpos := {}

//Private aMemos:={{"EEI_DESC","EEI_VM_DSC"}}
Private aMemos:={{"EEI_DESC","EEI_VM_DES"}}


If !EasyCallMVC("MVC_EECAT180",1) // - CRF

   If !(Valtype(nOpc) == "N")
      Begin Sequence
         AxCadastro("EEI", AvTitCad("EEI"), "IntegRef('EEI')")
      End Sequence
      dbselectarea(cOldArea)
   Else

      // BAK - alteração para o tratamento de inclusão para o consulta padrão de normas
      SX3->(DbSetOrder(1))
      SX3->(DBSeek(AvKey("EEI","X3_ARQUIVO")))
      While SX3->(!Eof()) .And. AvKey(SX3->X3_ARQUIVO,"X3_ARQUIVO") == AvKey("EEI","X3_ARQUIVO")
         aAdd(aCpos,SX3->X3_CAMPO)
         SX3->(DbSkip())
      EndDo
      If nOpc == 3
         AxInclui("EEI",EEI->(Recno()),nOpc,,,aCpos)
      EndIf
   EndIf

EndIf

RestOrd(aOrd)

Return lRet
*--------------------------------------------------------------------
FUNCTION COCAB()
/*
RETORNA UM VETOR COM OS DADOS P/ CABECALHO NA IMPRESSAO DOS CERTIFICADOS
ASSUME QUE JA ESTA POSICIONADO NO EEC

**** ALTERACAO
OMJ - 16/06/2005 11:12 - Tratamento de LC e Invoice

*/
LOCAL cTEXT1,cTEXT2,cTEXT3,cTEXT4,cTEXT5,cTEXT6,;
      aRET    := {},;
      aORDANT := SAVEORD({"SA2","SYA","SA1","SY9","SYR","SYQ","EE6"})


// 1.Exportador
/*
SA2->(DBSETORDER(1))
SA2->(DBSEEK(XFILIAL("SA2")+cEXPFOR))
SYA->(DBSETORDER(1))
SYA->(DBSEEK(XFILIAL("SYA")+SA2->A2_PAIS))
cTEXT1 := ALLTRIM(SA2->A2_NOME)
cTEXT2 := SA2->(ALLTRIM(A2_END)+"-"+ALLTRIM(A2_MUN))
cTEXT3 := ALLTRIM(SA2->A2_EST)+"-"+ALLTRIM(SYA->YA_DESCR)
cTEXT4 := ALLTRIM(SYA->YA_DESCR)
AADD(aRET,{cTEXT1,cTEXT2,cTEXT3,cTEXT4,"","",""})
*/
AADD(aRET,EECRetCab("EXPORTADOR"))


// 2.CLIENTE OU IMPORTADOR
/*
cIMPCLI := EECRetCab("EEC_IMPORT")+EECRetCab("EEC_IMLOJA")
SA1->(DBSETORDER(1))
SA1->(DBSEEK(XFILIAL("SA1")+cIMPCLI))
SYA->(DBSETORDER(1))
SYA->(DBSEEK(XFILIAL("SYA")+SA1->A1_PAIS))
cTEXT1 := ALLTRIM(EECRetCab("EEC_IMPODE"))
cTEXT2 := ALLTRIM(EECRetCab("EEC_ENDIMP"))+" "+ALLTRIM(EECRetCab("EEC_END2IM"))
cTEXT3 := ""
cTEXT4 := ALLTRIM(SYA->YA_DESCR)
AADD(aRET,{cTEXT1,cTEXT2,cTEXT3,cTEXT4,"","",""})
*/
AADD(aRET,EECRetCab("IMPORTADOR"))


// 3.CONSIGNATARIO
/*
cTEXT1 := cTEXT2 := cTEXT3 := ""
IF ! EMPTY(EECRetCab("EEC_CONSIG"))
   SA1->(DBSETORDER(1))
   SA1->(DBSEEK(XFILIAL("SA1")+EEC->EEC_CONSIG+EEC->EEC_COLOJA ))
   SYA->(DBSETORDER(1))
   SYA->(DBSEEK(XFILIAL("SYA")+SA1->A1_PAIS))
   cTEXT1 := SA1->A1_NOME
   cTEXT2 := SYA->YA_DESCR
ENDIF
AADD(aRET,{cTEXT1,cTEXT2,cTEXT3,"",""})
*/
AADD(aRET,EECRetCab("CONSIGNATARIO"))


// 4.PORTO OU LUGAR DE EMBARQUE PREVISTO
/*
SYR->(DBSETORDER(1))
SYR->(DBSEEK(XFILIAL("SYR")+EEC->(EEC_VIA+EEC_ORIGEM+EEC_DEST+EEC_TIPTRA)))
SY9->(DBSETORDER(2))
SY9->(DBSEEK(XFILIAL("SY9")+SYR->YR_ORIGEM))
AADD(aRET,SY9->Y9_DESCR)
*/
AADD(aRET,EECRetCab("PORTO_DE_ORIGEM"))


// 5.PAIS DE DESTINO DAS MERCADORIAS

SYA->(DBSETORDER(1))
SYA->(DBSEEK(XFILIAL("SYA")+EEC->EEC_PAISET))
AADD(aRET,SYA->YA_DESCR)


// 6.MEIO DE TRANSPORTE PREVISTO (Via de Transporte)
SYQ->(DBSETORDER(1))
SYQ->(DBSEEK(XFILIAL("SYQ")+EEC->EEC_VIA))
AADD(aRET,UPPER(TABELA("Y3",LEFT(SYQ->YQ_COD_DI,1))))


// 7.NUMERO DA FATURA COMERCIAL
/*
AADD(aRET,EEC->EEC_NRINVO)
*/
AADD(aRET,EECRetCab("EEC_NRINVO"))


// 8.DATA DA FATURA COMERCIAL
/*
AADD(aRET,DTOC(EEC->EEC_DTINVO))
*/
AADD(aRET,DTOC(EECRetCab("EEC_DTINVO")))


// 9.MEIO DE TRANSPORTE / DESTINO
SYR->(DBSETORDER(1))
SYR->(DBSEEK(XFILIAL("SYR")+EEC->(EEC_VIA+EEC_ORIGEM+EEC_DEST+EEC_TIPTRA)))
SY9->(DBSETORDER(2))
SY9->(DBSEEK(XFILIAL("SY9")+SYR->YR_ORIGEM))
SYQ->(DBSETORDER(1))
SYQ->(DBSEEK(XFILIAL("SYQ")+EEC->EEC_VIA))
cTEXT1 := "FROM:"
cTEXT2 := ALLTRIM(SYR->YR_CID_ORI)+" - "+POSICIONE("SYA",1,XFILIAL("SYA")+SYR->YR_PAIS_OR,"YA_NOIDIOM")
cTEXT3 := "TO:"
cTEXT4 := ALLTRIM(SYR->YR_CID_DES)+" - "+POSICIONE("SYA",1,XFILIAL("SYA")+SYR->YR_PAIS_DE,"YA_NOIDIOM")
cTEXT5 := IF(LEFT(SYQ->YQ_COD_DI,1)="1","VESSEL:","")
cTEXT6 := POSICIONE("EE6",1,XFILIAL("EE6")+EEC->EEC_EMBARC,"EE6_NOME")
AADD(aRET,{cTEXT1,cTEXT2,cTEXT3,cTEXT4,cTEXT5,cTEXT6})

RESTORD(aORDANT)
RETURN(aRET)
*--------------------------------------------------------------------
FUNCTION COROD(nP_TAMOBS)
/*
MONTA UM ARRAY P/ IMPRESSAO DOS RODAPES DOS CERTIFICADOS
ASSUME QUE JA ESTA POSICIONADO EM EEC
*/
LOCAL aRET := {},cTEXTO,cOBS1,cOBS2,cOBS3,cOBS4,cOBS5,cOBS6,cOBS7,cOBS8,;
      aORD    := SAVEORD({"SA2"}),;
      cEXPFOR := EEC->(IF(EMPTY(EEC_EXPORT),EEC_FORN+EEC_FOLOJA,;
                                            EEC_EXPORT+EEC_EXLOJA))
// 1.OBSERVACOES
cTEXTO := ""
cOBS1  := PADR(cTEXTO,nP_TAMOBS," ")
cOBS2  := PADR(cTEXTO,nP_TAMOBS," ")
cOBS3  := PADR(cTEXTO,nP_TAMOBS," ")
cOBS4  := PADR(cTEXTO,nP_TAMOBS," ")
cOBS5  := PADR(cTEXTO,nP_TAMOBS," ")
cOBS6  := PADR(cTEXTO,nP_TAMOBS," ")
cOBS7  := PADR(cTEXTO,nP_TAMOBS," ")
cOBS8  := PADR(cTEXTO,nP_TAMOBS," ")
AADD(aRET,{cOBS1,cOBS2,cOBS3,cOBS4,cOBS5,cOBS6,cOBS7,cOBS8})
// 2.INSTRUMENTO DE NEGOCIACAO
AADD(aRET,PEMCOINEG())
// 3.NOME DO EXPORTADOR
AADD(aRET,SA2->A2_NOME)
// 4.MUNICIPIO DO EXPORTADOR E DATA DE EMISSAO DO CERTIFICADO POR EXTENSO
SA2->(DBSETORDER(1))
SA2->(DBSEEK(XFILIAL("SA2")+cEXPFOR))
cTEXTO := ALLTRIM(SA2->A2_MUN)+", "+Str(Day(dDataBase),2)+STR0104+Upper(MesExtenso(Month(dDataBase)))+STR0104+Str(Year(dDataBase),4) //" DE "###" DE "
AADD(aRET,cTEXTO)
 // 5.DATA DA IMPRESSAO DO CERTIFICADO
AADD(aRET,DTOC(dDATABASE))
RESTORD(aORD)
RETURN(aRET)
*--------------------------------------------------------------------
FUNCTION COVERI(cP_MODO)
/*
VERIFICA A EXISTENCIA DO INSTRUMENTO DE NEGOCIACAO P/ TODOS OS CERTIFICADOS
ASSUME QUE ESTA POSICIONADO EM EEC
*/
LOCAL lRET := COMsg(cP_MODO)//FJH 15/08/05 Chama função no EECCAD01 que exibe msgs de erro. T se não ouver erros
RETURN(lRET)
*--------------------------------------------------------------------
STATIC FUNCTION PEMCOINEG()
/*
FUNCAO QUE COMPLEMENTA A FUNCAO COVERI()
*/
LOCAL cINSTNEG := SPACE(AVSX3("EEE_DCRED",AV_TAMANHO)),;
      aORDANT  := SAVEORD({"EEE"})
*
cINSTNEG := Posicione("EEE",1,XFILIAL("EEE")+EEC->EEC_INSCOD,"EEE_DCRED")
RESTORD(aORDANT)
RETURN(cINSTNEG)
*--------------------------------------------------------------------
Static Function MemoSYP(cChave,nTam,nLin,cCampoM) // By JPP 23/08/04 17:00 - Inclusão do parametro cCampoM - que será utilizado para determinar o tamanho do campo memo.
Local aOrd := SaveOrd("SYP",1)
Local cString := ""
Local cRet := ""
Local nTamCampo := AVSX3(cCampoM,AV_TAMANHO)  // By JPP  23/08/04 17:00 - Determina o tamanho do campo memo.
Default nLin := 0

Begin Sequence

   /* by jbj - 21/06/04 10:30 - A função MemoSyp() passa a utilizar a funcão Msmm()
                                para leitura padronizada das informações do SYP. */
   /*

   IF(nLin==Nil,nLin:=0,)

   SYP->(dbSeek(xFilial()+AvKey(cChave,"YP_CHAVE")))

   While SYP->(!Eof() .And. YP_FILIAL==xFilial("SYP")) .And.;
      cChave == SYP->YP_CHAVE

      cString := cString+Rtrim(StrTran(SYP->YP_TEXTO,"\13\10",CRLF))

      IF Right(cString,2) <> CRLF
         cString := cString+" "
      Endif

      IF nLin > 0
         IF MlCount(cString,nTam) > nLin
            Exit
         Endif
      Endif
      SYP->(dbSkip())
   Enddo
   */

   If Empty(cChave) .Or. Empty(nTam)
      cRet:=""
      Break
   EndIf

   cString := Msmm(cChave,nTamCampo) // By JPP 23/08/04 17:00 - Alterado para utilizar o tamanho do campo memo.
   cString := StrTran(cString,CRLF,Space(1))

   If nLin > 0
      cRet := MemoLine(cString,nTam,nLin)
   Else
      nTotLin := MlCount(cString,nTam)
      cRet    := ""
      For nLin:=1 To nTotLin
          cRet := cRet+MemoLine(cString,nTam,nLin)+CRLF
      Next nLin

      IF !Empty(cRet)
         cRet := Substr(cRet,1,Len(cRet)-2)
      Endif
   Endif

End Sequence

RestOrd(aOrd)

Return cRet
*--------------------------------------------------------------------
/*
1.aP_LENCOL  -> VETOR CONTENDO AS INFORMACOES P/ OS CAMPO DO TMP E COLUNAS DO
                BROWSE P/ OS ITENS. 1.CAMPO, 2.TAMANHO, 3.TIPO E 4.TITULO DA COLUNA
2.aP_LENCON  -> VETOR CONTENDO AS INFORMACOES P/ AS COLUNAS DO BROWSE P/ AS NORMAS
                1.
3.cP_CAMPO   -> CHAVE DE INDEXACAO/AGRUPAMENTO DO USUARIO (OBRIG)
4.nP_LINNOR  -> NUMERO DE LINHAS DISPONIVEIS POR PAGINA P/ IMPRESSAO DA NORMA
                SE ESTE VALOR FOR 0, O PRW ASSUME QUE NAO TEM NORMA
5.cP_PONTOE  -> NOME DO PONTO DE ENTRADA P/ ALTERACAO DAS LINHAS DO DETALHE
6.nP_LINDET  -> NUMERO DE LINHAS QUE
M SER IMPRESSO O DETALHE
7.lP_PONTOE  -> SE VERDADEIRO O PONTO DE ENTRADA TEM A OBRIGACAO DE INCLUIR
                OS DADOS NO TMP. SE FALSO, A ROTINA PADRAO SERA EXECUTADA
8.nP_LINDET2 -> NUMERO DE ITENS QUE SERAO IMPRESSOS A PARTIR DA SEGUNDA PAGINA
9.cP_Modelo  -> Modelo do Documento.
                1-Mercosul - Fiesp / Chile / Bolivia.
                7 - FIEP C.O. Comum
10.lP_PrintPe-> .T. = Imprime Peso, .F. = Imprime Qtde

Revisão em 03/06/2004 às 14:41 por AMS.
Descrição: Para o parametro aP_LENCOL será permitido inserir a mascara e a qtde de casas decimais para edição
           e impressão da coluna, para cada campo definido no array.
           Exemplo: {"PESO_QTDE", LENCOL4, "C", STR0004, "@E 999,999,999.999", 3}
           Onde os 2 ultimos parametros indica a picture, decimais.
           No RDM do C.O. deve ser definido a variavel aH_Item_Extend := {}, em nivel private. O ponto de entrada
           (passado como 5º parametro no CODET) deve gravar o campo no TMP sem mascara.
           Exemplo: TMP->PESO_QTDE := PadL(AllTrim(Str(TMP->TMP_PLQTDE)), LENCOL4, " ")
*/

FUNCTION CODET(aP_LENCOL,aP_LENCON,cP_CAMPO,nP_LINNOR,cP_PONTOE,nP_LINDET,lP_PONTOE,nP_LINDET2,cP_Modelo,lP_PrintPe, cNorma)

LOCAL cAX,I,Z,nPOS,cTEXTO:="",cDSCITE,nDSCITE,lDET,lNOR,lPRI,lQUEBRA,;
      nLI_ITEM,nLI_TEX,nLI_NOR,lCONT,;
      lRET     := .F.,;
      lGrvSeq  := .T.,;
      aNOR     := {},;
      aORDANT  := SAVEORD({"EE9","EEI","SYD"}),;
      cUSADO   := POSICIONE("SX3",2,"EEC_PREEMB","X3_USADO"),;
      aESTRU   := {{"TMP_ORIGEM","C",02                            ,0},;
                   {"TMP_CODNOR","C",AVSX3("EE9_CODNOR",AV_TAMANHO),0},;
                   {"TMP_PLQTDE","N",18                            ,EEC->EEC_DECPES},;
                   {"TMP_VALFOB","N",AVSX3("EE9_PRCTOT",AV_TAMANHO),AVSX3("EE9_PRCTOT",AV_DECIMAL)},;
                   {"TMP_DSCMEM","M",10                            ,0},;
                   {"TMP_SEQIMP","C",05                            ,0},;
                   {"TMP_UNIDAD","C",02                            ,0},;//AMS - 11/11/2003, Inclusão da unidade de medida p/ agrupamento com NCM.
                   {"TMP_DESCIT","M",60                            ,0}} //FJH - 22/08/05 Inclusão da descricao do item ao lado da desc. da naladi

Local cPictCap := "@R 9999", cPictSubCap := "@R 9999.99"
Local aCap :={}, aSubCap:={}
// FJH 16/08/05 Agrupamento por Unidade de Medida
Local cUnidad := ""
Local nCont:= 1
// ** By JBJ - 11/02/04 - Array com o(s) campo(s) da chave.
Local aCmpChave :={}
Local cChave, cNmCampo:="", cConteudo:="", j:=0
Local nOldAlias := Select()
Local aSemNorma := {} // AST - 14/08/08 -Vetor para armazenar os os itens sem norma

// ** By JBJ 17/07/03 - Flag para controle da impressão de capítulos.
Private lSetCapToPrint := .f.
Private lPrintCap := .f., lPrintSubCap := .f.
// FJH 22/08/05 Flag para mostrar se imprime descricao do item
Private lMostraDsc := EasyGParam("MV_AVG0100",,.f.),cAnt:=""

PRIVATE nLIN,nPAG,cFILE,cFILE2, lPrintPeso := .t.

Default cP_Modelo := ""

BEGIN SEQUENCE

   aP_LENCOL  := IF(aP_LENCOL=NIL ,{}       ,aP_LENCOL)  // VETOR DOS ITENS
   aP_LENCON  := IF(aP_LENCON=NIL ,{}       ,aP_LENCON)  // VETOR DE NORMAS
   cP_CAMPO   := IF(cP_CAMPO =NIL ,""       ,cP_CAMPO)   // CHAVE DE INDEXACAO/AGRUPAMENTO DO USUARIO (OBRIG)
   nP_LINNOR  := IF(nP_LINNOR=NIL ,0        ,nP_LINNOR)  // QUANTIDADE DE LINHAS DE NORMAS POR PAGINA
   cP_PONTOE  := IF(cP_PONTOE=NIL ,""       ,cP_PONTOE)  // NOME DO PONTO DE ENTRADA
   nP_LINDET  := IF(nP_LINDET=NIL ,14       ,nP_LINDET)  // INDICA QUANTIDADE DE LINHAS P/ DETALHES
   lP_PONTOE  := IF(lP_PONTOE=NIL ,.F.      ,lP_PONTOE)  // INDICA SE EXECUTA OU NAO A ROTINA PADRAO DE GRAVACAO DO TMP
   nP_LINDET2 := IF(nP_LINDET2=NIL,nP_LINDET,nP_LINDET2) // INDICA O NUMERO DE ITENS QUE CABE DA 2.a PAGINA EM DIANTE

   IF EMPTY(cP_CAMPO)
      MSGINFO(STR0108,STR0109) //"Campo do agrupamento nao informado"###"Atencao"
      BREAK
   ELSEIF ! EasyEntryPoint(cP_PONTOE)
          MSGINFO(STR0110,STR0109) //"Ponto de entrada nao informado"###"Atencao"
          BREAK
   ENDIF

   // ** By JBJ - 11/02/04 - Carrega os campos da chave de ordenação.
   cChave:= AllTrim(cP_CAMPO)

   For j:=1 To Len(cChave)
      If SubStr(cChave,j,1) <> "+"
         cNmCampo += SubStr(cChave,j,1)
      Else
         If EE9->(FieldPos(cNmCampo)) <> 0
            aAdd(aCmpChave,cNmCampo)
            cNmCampo:=""
         EndIf
      EndIf

      // ** Ultimo campo da chave.
      If j = Len(cChave)
         If EE9->(FieldPos(cNmCampo)) <> 0
            aAdd(aCmpChave,cNmCampo)
         EndIf
      EndIf
   Next

   // ** By JBJ - 11/02/04 - Verifica a chave ordenação...
   If Len(aCmpChave) = 0
      MsgInfo("A chave para o agrupamento é inválida","Atenção")
      Break
   EndIf

   If !lp_PontoE
      If !Empty(cP_Modelo)
         If cP_Modelo == "1" //Mercosul - Fiesp / Chile / Bolivia.
            IF ValType(lP_PrintPe) <> "L"
               If !SetImpressao(T_PESOS)
                  lRet := .f.
                  Break
               EndIf
            Else
               lPrintPeso := lP_PrintPeso
            Endif
         EndIf
      EndIf

      // ** By JBJ - 11/02/04.
      lSetCapToPrint := (EasyGParam("MV_AVG0050",,.f.) .And. (Upper(AllTrim(aCmpChave[1])) = "EE9_POSIPI"))
      //lSetCapToPrint := (EasyGParam("MV_AVG0050",,.f.) .And. (Upper(AllTrim(cp_Campo)) = "EE9_POSIPI"))

      If lSetCapToPrint
         If !SetImpressao(T_CAPITULO)
            lRet := .f.
            Break
         EndIf
      EndIf
   EndIf

   // Inclui o(s) campo(s) do agrupamento na estrutura do Tmp.
   For j:=1 to Len(aCmpChave)
      AADD(aESTRU,{aCmpChave[j],AVSX3(aCmpChave[j],AV_TIPO),AVSX3(aCmpChave[j],AV_TAMANHO),;
                                                            AVSX3(aCmpChave[j],AV_DECIMAL)})
   Next
   // AADD(aESTRU,{cP_CAMPO,AVSX3(cP_CAMPO,AV_TIPO),AVSX3(cP_CAMPO,AV_TAMANHO),AVSX3(cP_CAMPO,AV_DECIMAL)})

   // INCLUI OS CAMPOS P/ EDICAO/IMPRESSAO
   cDSCITE := ""
   nDSCITE := 0
   FOR I := 1 TO LEN(aP_LENCOL)
       IF ASCAN(aESTRU,{|Z| Z[1] = aP_LENCOL[I,1]}) # 0
          MSGSTOP(STR0111+aP_LENCOL[I,1],STR0109) //"Campo duplicado no TMP -> "###"Atencao"
          BREAK
       ELSEIF aP_LENCOL[I,3] # "C" .AND. aP_LENCOL[I,3] # "M"
              MSGINFO(STR0112+aP_LENCOL[I,1],STR0109) //"Erro na declaracao do vetor aLENCOL ->"###"Atencao"
              BREAK
       ELSEIF aP_LENCOL[I,3] = "M"
              cDSCITE := aP_LENCOL[I,1] // CAMPO
              nDSCITE := aP_LENCOL[I,2] // TAMANHO
       ENDIF
       AADD(aESTRU,{aP_LENCOL[I,1],; // CAMPO
                    aP_LENCOL[I,3],; // TIPO
                    aP_LENCOL[I,2],; // TAMANHO
                    0})              //DECIMAL
   NEXT
   cDSCITE := IF(EMPTY(cDSCITE),"TMP_DSCMEM",cDSCITE)
   nDSCITE := IF(nDSCITE=0     ,45          ,nDSCITE)

   // GERA O TMP
//   Private aCampos := {}   // By OMJ - 01/07/2005
   Private aCampos := array(len(aEstru)) // FJH 01/09/05
   Private aHeader[0]      // By OMJ - 01/07/2005

   cFILE  := E_CRIATRAB("",aESTRU,"TMP")
//   If !lPrintPeso // FJH 18/08/05 sempre vai agrupar por unidade de medida
      INDREGUA("TMP",cFILE+TEOrdBagExt(),cP_CAMPO+"+TMP_UNIDAD+TMP_CODNOR"+IF(lMostraDsc,"+TMP_DSCMEM","")) //se MV_AVG0100 == .T. tb agrupa por descricao do item
//   Else
//      INDREGUA("TMP",cFILE+OrdBagExt(),cP_CAMPO+"+TMP_CODNOR")
//   EndIf

   cFILE2 := CRIATRAB(,.F.)
   INDREGUA("TMP",cFILE2+TEOrdBagExt(),"TMP_SEQIMP")
   SET INDEX TO (cFILE+TEOrdBagExt()),(cFILE2+TEOrdBagExt())

   IF ! lP_PONTOE
      cAX  := ""

      // ** By JBJ - 11/02/04 - 14:30.
      // nPOS := EE9->(FIELDPOS(cP_CAMPO))

      EE9->(DBSETORDER(3))
      EE9->(DBSEEK(XFILIAL("EE9")+EEC->EEC_PREEMB))

      If lSetCapToPrint
         aCap :={}; aSubCap:={}
      EndIf

      DO WHILE ! EE9->(EOF()) .AND.;
         EE9->(EE9_FILIAL+EE9_PREEMB) = (XFILIAL("EE9")+EEC->EEC_PREEMB)

         //DFS - Pular os itens diferentes para impressão em p
         If cNorma <> Nil .And. Alltrim(EE9->EE9_CODNOR) <> Alltrim(cNorma)
            EE9->(dbSkip())
            Loop
         Endif

         If !lPrintPeso  // FJH 16/08/05 Grava no cUnidad a unidade de qtd ou peso.
            cUnidad := EE9->EE9_UNIDAD
         else
            cUnidad := IF(!Empty(EE9->EE9_UNPES) ,EE9->EE9_UNPES , ;
            IF(!Empty(EEC->EEC_UNIDAD),EEC->EEC_UNIDAD, ;
            EasyGParam("MV_AVG0031")))
            cUnidad:=If(Empty(cUnidad).or.cUnidad==".","",cUnidad)
         endif
         cConteudo := ""
         For j:=1 To Len(aCmpChave)
            cConteudo += AvKey(EE9->&(aCmpChave[j]),aCmpChave[j])
         Next

         IF !Empty(cConteudo) // ! EMPTY(EE9->(FIELDGET(nPOS)))
            IF nP_LINNOR > 0
               IF EMPTY(EE9->EE9_CODNOR) .OR. POSICIONE("EEI",1,XFILIAL("EEI")+EE9->EE9_CODNOR,"EEI_PROIB") $ cSIM
                  // AST - 14/08/08 - Armazena os itens sem norma
                  aAdd(aSemNorma,{EE9->EE9_PEDIDO, EE9->EE9_SEQUEN, EE9->EE9_COD_I})
                  EE9->(DBSKIP())
                  LOOP
               ENDIF
               cAX := EE9->EE9_CODNOR
            ENDIF
            //Ajusta o cTexto para dar o seek
            If lMostraDsc
               Z := ""  //FJH 21/09/05 Correção para Z não ficar nulo caso o Campo Chave não for Nalsh.
               IF aCmpChave[1] = "EE9_NALSH" // cP_CAMPO = "EE9_NALSH"
                  SJ1->(DBSETORDER(1))
                  SJ1->(DBSEEK(XFILIAL("SJ1")+EE9->(FIELDGET(EE9->(FieldPos(aCmpChave[1])))))) // SJ1->(DBSEEK(XFILIAL("SJ1")+EE9->(FIELDGET(nPOS))))
                  Z := ALLTRIM(SJ1->J1_DESC)+If(lMostraDsc," - "+alltrim(MEMOLINE(MSMM(EE9->EE9_DESC,AVSX3("EE9_VM_DES",AV_TAMANHO)),60,1)),"")
               Elseif aCmpChave[1] = "EE9_POSIPI"
                  SYD->(DBSETORDER(1))
                  SYD->(DbSeek(xFilial("SYD")+EE9->(FieldGet(EE9->(FieldPos(aCmpChave[1])))))) //SYD->(DBSEEK(XFILIAL("SYD")+EE9->(FIELDGET(nPOS))))
                  Z := MEMOSYP(SYD->YD_TEXTO,nDSCITE,,"YD_VM_TEXT") +If(lMostraDsc," - "+alltrim(MEMOLINE(MSMM(EE9->EE9_DESC,AVSX3("EE9_VM_DES",AV_TAMANHO)),60,1)),"")
               Endif
               FOR I := 1 TO MLCOUNT(Z,nDSCITE)
                  cTEXTO := cTEXTO+ALLTRIM(MEMOLINE(Z,nDSCITE,I))+ENTER
               NEXT
            Endif
            TMP->(DBSETORDER(1))
            // IF ! (TMP->(DBSEEK(EE9->(FIELDGET(nPOS))+If(!lPrintPeso, EE9->EE9_UNIDAD, "" )+cAX))) //AMS - 11/11/2003, Inclusão do EE9_UNIDAD.
            //If ! Tmp->(DbSeek(cConteudo+If(!lPrintPeso,EE9->EE9_UNIDAD,"")+cAx))

            If !Tmp->(DbSeek(cConteudo+AvKey(cUnidad,"EEC_UNIDAD")+cAx+IF(lMostraDsc,cTEXTO,""))) //FJH 16/08/05 O cUnidad contém a unidade de agrupamento por peso ou medida
               Z := cTEXTO := ""
               If aCmpChave[1] = "EE9_POSIPI" // cP_CAMPO = "EE9_POSIPI"
                  SYD->(DBSETORDER(1))
                  SYD->(DbSeek(xFilial("SYD")+EE9->(FieldGet(EE9->(FieldPos(aCmpChave[1])))))) //SYD->(DBSEEK(XFILIAL("SYD")+EE9->(FIELDGET(nPOS))))
                  Z := MEMOSYP(SYD->YD_TEXTO,nDSCITE,,"YD_VM_TEXT") ;// By JPP 23/08/04 17:00 - inclusão do parametro "YD_VM_TEXT", determina o tamanho do campo memo.
                       +If(lMostraDsc," - "+alltrim(MEMOLINE(MSMM(EE9->EE9_DESC,AVSX3("EE9_VM_DES",AV_TAMANHO)),60,1)),"") //FJH 21/09/05 Adiciona descricao se MV_AVG0100 ==.T.
               ELSEIF aCmpChave[1] = "EE9_NALSH" // cP_CAMPO = "EE9_NALSH"
                      SJ1->(DBSETORDER(1))
                      SJ1->(DBSEEK(XFILIAL("SJ1")+EE9->(FIELDGET(EE9->(FieldPos(aCmpChave[1])))))) // SJ1->(DBSEEK(XFILIAL("SJ1")+EE9->(FIELDGET(nPOS))))
                      Z := ALLTRIM(SJ1->J1_DESC)+If(lMostraDsc," - "+alltrim(MEMOLINE(MSMM(EE9->EE9_DESC,AVSX3("EE9_VM_DES",AV_TAMANHO)),60,1)),"")
               ENDIF

               //WFS 16/10/09 C.O. FIEP Comum
               //Imprimirá todos os itens com a descrição do próprio produto
               If cP_Modelo == "7"
                  Z:= Transf(EE9->EE9_SLDINI, X3Picture("EE9_SLDINI")) +;
                      " " + AllTrim(EE9->EE9_UNIDAD) + " OF " +;
                      AllTrim(MemoLine(MSMM(EE9->EE9_DESC, AvSx3("EE9_VM_DES", AV_TAMANHO)), nDSCITE, 1))
                  //Tratamento para burlar o seek e gerar sempre a descrição
                  cUnidad:= AllTrim(Str(nCont++))
               EndIf

               // ** By JBJ - 17/07/03 - 14:05 - Controles para impressao capitulo e sub-capitulo.
               If lSetCapToPrint
                  SYD->(DbSetOrder(1))

                  If lPrintCap // Flag para impressao do capitulo.
                     If SYD->(DbSeek(xFilial("SYD")+AvKey(Left(EE9->EE9_POSIPI,4),"YD_TEC")))

                        If aScan(aCap,AvKey(Left(EE9->EE9_POSIPI,4),"YD_TEC")) = 0
                           aAdd(aCap,AvKey(Left(EE9->EE9_POSIPI,4),"YD_TEC"))

                           cDescCap := MemoSyp(SYD->YD_TEXTO,nDscIte,,"YD_VM_TEXT") // By JPP 23/08/04 17:00 - inclusão do parametro "YD_VM_TEXT", determina o tamanho do campo memo.

                           TMP->(DbAppend())
                           TMP->EE9_POSIPI := Left(EE9->EE9_POSIPI,4)

                           For j:=1 TO MlCount(cDescCap,nDSCITE)
                              TMP->TMP_DSCMEM := TMP->TMP_DSCMEM+AllTrim(MemoLine(cDescCap,nDSCITE,j))+ENTER
                           Next

                           TMP->COD_NCM   := Transf(AllTrim(TMP->EE9_POSIPI),cPictCap)
                           TMP->DESCRICAO := TMP->TMP_DSCMEM
                           TMP->PESO_QTDE := ""
                           TMP->VALOR_FOB := ""

                           AADD(aRECNO,{STRZERO(TMP->(RECNO()),2,0)})
                        EndIf
                     EndIf
                  EndIf

                  If lPrintSubCap // Flag para impressao do sub-capitulo.
                     If SYD->(DbSeek(xFilial("SYD")+AvKey(Left(EE9->EE9_POSIPI,6),"YD_TEC")))

                        If aScan(aSubCap,AvKey(Left(EE9->EE9_POSIPI,6),"YD_TEC")) = 0
                           aAdd(aSubCap,AvKey(Left(EE9->EE9_POSIPI,6),"YD_TEC"))

                           cDescCap := MemoSyp(SYD->YD_TEXTO,nDscIte,,"YD_VM_TEXT")// By JPP 23/08/04 17:00 - inclusão do parametro "YD_VM_TEXT", determina o tamanho do campo memo.

                           TMP->(DbAppend())
                           TMP->EE9_POSIPI := Left(EE9->EE9_POSIPI,6)

                           For j:=1 TO MlCount(cDescCap,nDSCITE)
                              TMP->TMP_DSCMEM := TMP->TMP_DSCMEM+AllTrim(MemoLine(cDescCap,nDSCITE,j))+ENTER
                           Next

                           TMP->COD_NCM   := Transf(TMP->EE9_POSIPI,cPictSubCap)
                           TMP->DESCRICAO := TMP->TMP_DSCMEM
                           TMP->PESO_QTDE := ""
                           TMP->VALOR_FOB := ""

                           AADD(aRECNO,{STRZERO(TMP->(RECNO()),2,0)})
                        EndIf
                     EndIf
                  EndIf
               EndIf

               TMP->(DBAPPEND())
               TMP->TMP_UNIDAD := cUnidad
               TMP->TMP_CODNOR := cAX

               For j:=1 To Len(aCmpChave)
                  Tmp->(FieldPut(FieldPos(aCmpChave[j]),EE9->(FieldGet(EE9->(FieldPos(aCmpChave[j]))))))
               Next
               // TMP->(FIELDPUT(FIELDPOS(cP_CAMPO),EE9->(FIELDGET(nPOS))))

               FOR I := 1 TO MLCOUNT(Z,nDSCITE)
                   cTEXTO := cTEXTO+ALLTRIM(MEMOLINE(Z,nDSCITE,I))+ENTER
               NEXT
               TMP->TMP_DSCMEM := cTEXTO
               AADD(aRECNO,{STRZERO(TMP->(RECNO()),2,0)})
            ENDIF

            If lPrintPeso
               /* By JBJ - 26/07/04 - O sistema deve considerar o campo já calculado EE9_PSLQTO. (já convertido
                                      de acordo com a unidade da quantidade e unidade do peso).
               TMP->TMP_PLQTDE := TMP->TMP_PLQTDE+EE9->(EE9_SLDINI*EE9_PSLQUN)
               */
               TMP->TMP_PLQTDE := TMP->TMP_PLQTDE+EE9->EE9_PSLQTO
            Else //Imprime quantidade (Opcao Default)
               TMP->TMP_PLQTDE := TMP->TMP_PLQTDE+EE9->EE9_SLDINI
            EndIf

            /* By JBJ - 26/07/04 - O sistema deve considerar o campo já calculado EE9_PRCINC(já convertido
                                   de acordo com a unidade da quantidade e unidade do preço).
               TMP->TMP_VALFOB := TMP->TMP_VALFOB+EE9->(EE9_SLDINI*EE9_PRECOI)
            */
            TMP->TMP_VALFOB := TMP->TMP_VALFOB+EE9->EE9_PRCINC

            FOR I := 1 TO LEN(aRECNO)
                IF aRECNO[I,1] = STRZERO(TMP->(RECNO()),2,0)
                   AADD(aRECNO[I],EE9->(RECNO()))
                   EXIT
                ENDIF
            NEXT
         ENDIF
         EE9->(DBSKIP())
      ENDDO
      //AST - 14/08/08 - Caso exista itens sem norma e o parametro esteja ligado, exibe os itens do embarque
      //que não serão impressos devido não terem norma.
      if Len(aSemNorma) > 0
         If EasyGParam("MV_AVG0162",, .F.)
            EECView(STR0190 + ENTER +ENTER + EECMontaMsg({"EE9_PEDIDO", "EE9_SEQUEN", "EE9_COD_I"}, aSemNorma)) // Os seguintes itens do embarque não serão impressos pois não possuem norma.
         endif
      endif
   ELSE
      EXECBLOCK(cP_PONTOE,.F.,.F.)
   ENDIF
   //AJP - 09/02/06 - Ponto de Entrada para alteração dos dados do detalhe
   If EasyEntryPoint("EECCAD00")
      ExecBlock("EECCAD00",.F.,.F.,{"PE_EDITDET",cP_PONTOE})
   End If
   //AJP - FIM DO PONTO DE ENTRADA

   TMP->(DBGOTOP())
   IF TMP->(BOF() .OR. EOF())
      MSGINFO(STR0113,STR0026) //"Não há dados p/ impressão do documento."###"Aviso"
      BREAK
   ENDIF
   // GRAVA A ORDEM DE IMPRESSAO NA ORDEM DO AGRUPAMENTO
   Z := 0
   DO WHILE ! TMP->(EOF())
      If !Empty(TMP->TMP_SEQIMP) .Or. !Empty(TMP->TMP_ORIGEM)
         lGrvSeq := .F.
      EndIf
      TMP->(DBSKIP())
   ENDDO

   Z := 0
   nNorma := 0
   TMP->(DBGOTOP())
   DO WHILE ! TMP->(EOF()) .And. lGrvSeq
      Z               := Z+1
      TMP->TMP_SEQIMP := STRZERO(Z,LEN(TMP->TMP_SEQIMP),0)
      If TMP->TMP_VALFOB > 0 .And. TMP->TMP_PLQTDE > 0
         nNorma ++
         TMP->TMP_ORIGEM := StrZero(nNorma,Len(TMP->TMP_ORIGEM),0) //STRZERO(Z,LEN(TMP->TMP_ORIGEM),0)
      EndIf
      TMP->(DBSKIP())
   ENDDO
   // ITENS
   aH_ITEM := {}
   AADD(aH_ITEM,{STR0114,"WKPAGINA","99",2,0,"Eval(bRefresh,'WKPAGINA')",cUSADO,"N","ZZZ"}) //"Pagina"
   AADD(aH_ITEM,{STR0115,"WKLINHA" ,"99",2,0,"Eval(bRefresh,'WKLINHA')" ,cUSADO,"N","ZZZ"}) //"Linha"
   
   If Type("aH_Item_Extend") <> "A"
      aH_Item_Extend:= Nil
   EndIf

   FOR I := 1 TO LEN(aP_LENCOL)
       AADD(aH_ITEM,{aP_LENCOL[I,4],aP_LENCOL[I,1],"@!",aP_LENCOL[I,2],0,"",cUSADO,"C","ZZZ"})

       /*
       Rotina para incluir a mascara e nº de casas decimais para campos.
       Autor       : Alexsander Martins dos Santos
       Data e Hora : 02/06/2004 às 14:26.
       Observação  : O array aH_Item_Extend é uma extenção dependente do aH_Item, onde permite definir
                     outras caracteristicas para uma coluna.
       */
       If aH_Item_Extend <> Nil
          If Len(aP_LenCol[I]) > 4
             aAdd(aH_Item_Extend, {Len(aH_Item)   ,;
                                   aP_Lencol[I][5],;
                                   aP_Lencol[I][6]})
          EndIf
       EndIf
       //Final da rotina.

   NEXT
   // NORMAS
   aH_NORMA := {}
   AADD(aH_NORMA,{STR0114,"WKPAGINA","99",2,0,"Eval(bRefresh,'WKPAGINA')",cUSADO,"N","ZZZ"}) //"Pagina"
   AADD(aH_NORMA,{STR0115 ,"WKLINHA" ,"99",2,0,"Eval(bRefresh,'WKLINHA')" ,cUSADO,"N","ZZZ"}) //"Linha"
   FOR I := 1 TO LEN(aP_LENCON)
       AADD(aH_NORMA,{aP_LENCON[I,4],aP_LENCON[I,1],"@!",aP_LENCON[I,2],0,"",cUSADO,"C","ZZZ"})
   NEXT
   *
   // PREPARA O CERTIFICADO P/ EDICAO
   lDET     := lNOR := lPRI := .T.
   lQUEBRA  := lCONT := .F.
   aNOR     := {}
   nLI_ITEM := nLIN := nLI_TEX := nLI_NOR := Z := 0
   nPAG     := 1
   nPOS     := TMP->(FIELDPOS(cDSCITE))
   cTEXTO   := TMP->TMP_DSCMEM
   *
   TMP->(DBSETORDER(2),DBGOTOP())
   DO WHILE .T.
      IF ! TMP->(EOF())
         IF ! lP_PONTOE .AND. TMP->(RECNO()) <= LEN(aRECNO) .AND. ! lCONT .And. TMP->TMP_VALFOB > 0 .And. TMP->TMP_PLQTDE > 0
            EXECBLOCK(cP_PONTOE,.F.,.F.,aRECNO[TMP->(RECNO())])
         ENDIF
         lCONT    := .F.
         nLI_ITEM := MLCOUNT(TMP->(FIELDGET(nPOS)),nDSCITE)
         nLI_ITEM := IF(nLI_ITEM=0,1,nLI_ITEM)
         lDET     := (nLIN+nLI_ITEM) <= nP_LINDET
         *
         IF nP_LINNOR > 0 .AND. ! EMPTY(TMP->TMP_CODNOR)
            FOR I := 1 TO LEN(aNOR)
                IF aNOR[I,1] = TMP->TMP_CODNOR .AND. EMPTY(aNOR[I,3,2])
                   EXIT
                ENDIF
            NEXT
            IF I > LEN(aNOR)
               EEI->(DBSETORDER(1))
               EEI->(DBSEEK(XFILIAL("EEI")+TMP->TMP_CODNOR))
               cTEXTO  := MEMOSYP(EEI->EEI_DESC,aP_LENCON[2,2],,"EEI_VM_DES") // By JPP 23/08/04 17:00 - inclusão do parametro "EEI_VM_DES", determina o tamanho do campo memo.
               nLI_TEX := MLCOUNT(cTEXTO,aP_LENCON[2,2])
               lNOR    := (nLI_NOR+nLI_TEX) <= nP_LINNOR
            ELSEIF lDET
                   IF EMPTY(aNOR[I,3,2])
                      aNOR[I,3,2] := TMP->TMP_ORIGEM
                      lNOR        := .T.
                   ELSE
                      cTEXTO  := aNOR[I,2]
                      nLI_TEX := MLCOUNT(cTEXTO,aP_LENCON[2,2])
                      lNOR    := (nLI_NOR+nLI_TEX) <= nP_LINNOR
                      I       := LEN(aNOR)+1
                   ENDIF
            ENDIF
            IF lDET .AND. lNOR .AND. I > LEN(aNOR)
               If !Empty(TMP->TMP_ORIGEM)
                  nLI_NOR := nLI_NOR+MLCOUNT(cTEXTO,aP_LENCON[2,2])
                  AADD(aNOR,{TMP->TMP_CODNOR,cTEXTO,{TMP->TMP_ORIGEM,""}})
               EndIf
            ENDIF
         ENDIF
      ENDIF
      IF ! lDET .OR. ! lNOR .OR. TMP->(EOF())
         lQUEBRA := .T.
         *
         IF lPRI .AND. ! TMP->(EOF())
            AADD(aNOR,{TMP->TMP_CODNOR,cTEXTO,{TMP->TMP_ORIGEM,""}})
            // ACERTA DETALHE
            EC09ADDIT1(aP_LENCOL,nP_LINDET)
            // ACERTA NORMA
            nLIN := 0
            EC09ADDNO1(aP_LENCON,nP_LINNOR,aNOR)
         ELSEIF nLIN > 0
               // DETALHE
               EC09ADDIT1(aP_LENCOL,nP_LINDET-nLIN,.T.)
               // NORMA
               nLIN := 0
               EC09ADDNO1(aP_LENCON,nP_LINNOR,aNOR)
         ENDIF
         nPAG      := nPAG+1
         nP_LINDET := IF(nPAG > 1,nP_LINDET2,nP_LINDET)
      ENDIF
      IF lQUEBRA
         lQUEBRA := .F.
         aNOR    := {}
         nLI_NOR := 0
         nLIN    := 0
         IF TMP->(EOF())
            EXIT
         ELSEIF ! lPRI
                lPRI := .T.
                LOOP
         ELSEIF lPRI
                lCONT := .T.
                Z     := ""
                FOR I := nP_LINDET+1 TO MLCOUNT(TMP->(FIELDGET(nPOS)),nDSCITE)
                    Z := Z+TMP->(MEMOLINE(FIELDGET(nPOS),nDSCITE,I))+ENTER
                NEXT
                TMP->(FIELDPUT(nPOS,Z))
                EXECBLOCK(cP_PONTOE,.F.,.F.,"CONTINUACAO")
                LOOP
         ENDIF
      ELSE
         lPRI    := .F.
         EC09ADDIT1(aP_LENCOL,nLI_ITEM)
      ENDIF
      TMP->(DBSKIP())
   ENDDO
   lRET := .T.
END SEQUENCE
RESTORD(aORDANT)
IF SELECT("TMP") # 0
   TMP->(E_EraseArq(cFILE))
ENDIF
dbselectarea(nOldAlias)
RETURN(lRET)
*--------------------------------------------------------------------
STATIC FUNCTION EC2801(cP_CMP1)

Local nHPos := 0
Local nCPos := 0
Local nEPos := 0

IF cP_CMP1 = "I" .OR. cP_CMP1 = "N"
   EC2801("L")
   aHEADER := IF(cP_CMP1="I",aH_ITEM,aH_NORMA) ///aCLONE(IF(cP_CMP1="I",aH_ITEM,aH_NORMA))
   aCOLS   := IF(cP_CMP1="I",aC_ITEM,aC_NORMA) ///aCLONE(IF(cP_CMP1="I",aC_ITEM,ac_NORMA))
   N       := IF(cP_CMP1="I",nLITEM ,nLNORMA)
   lITNO   := cP_CMP1

   /*
   Rotina para inserir mascara e nº de casas decimais para colunas da pasta Itens.
   Para as colunas que serão inseridas a mascara, terão seus valores convertidos para formato númerico.
   Autor : Alexsander Martins dos Santos
   Data e Hora : 31/05/2004 às 14:14.
   */
   If Type("aH_Item_Extend") = "A" .and. cP_CMP1 = "I"

      For nEPos := 1 To Len(aH_Item_Extend)

         nHPos := aH_Item_Extend[nEPos][1]

         aHeader[nHPos][3] := aH_Item_Extend[nEPos][2]
         aHeader[nHPos][8] := "N"
         aHeader[nHPos][5] := aH_Item_Extend[nEPos][3]

         For nCPos := 1 To Len(aCols)
            aCols[nCPos][nHPos] := If(Valtype(aCols[nCPos][nHPos]) = "N", aCols[nCPos][nHPos], Val(aCols[nCPos][nHPos]))
         Next

      Next

   EndIf
   //Final da rotina.

ELSEIF cP_CMP1 = "L"

       IF lITNO = "I"
          aH_ITEM := aHEADER ///ACLONE(aHEADER)
          aC_ITEM := aCOLS   ///ACLONE(aCOLS)
          nLITEM  := N

       ELSEIF lITNO = "N"
          aH_NORMA := aHEADER ///ACLONE(aHEADER)
          aC_NORMA := aCOLS   ///ACLONE(aCOLS)
          nLNORMA  := N

       ENDIF

       aHEADER := {}
       aCOLS   := {}
       N       := 1
       lITNO   := ""

ENDIF
RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION EC09ADDIT1(aP_LENCOL,nP_QTDLIN,lP_LIMPA)
LOCAL I,Z
lP_LIMPA  := IF(lP_LIMPA =NIL,.F.,lP_LIMPA)
FOR I := 1 TO nP_QTDLIN
    nLIN := nLIN+1
    AADD(aC_ITEM,ARRAY(LEN(aH_ITEM)+1))
    aC_ITEM[Len(aC_ITEM),LEN(aH_ITEM)+1] := .f. // Deleted
    aC_ITEM[Len(aC_ITEM),1]              := nPAG
    aC_ITEM[Len(aC_ITEM),2]              := nLIN
    FOR Z := 1 TO LEN(aP_LENCOL)
        IF lP_LIMPA
           aC_ITEM[LEN(aC_ITEM),Z+2] := SPACE(aP_LENCOL[Z,2])
        ELSE
           IF aP_LENCOL[Z,3] = "C"
              IF I = 1
                 If Z==2 //FJH
                    if TMP->(FIELDGET(FIELDPOS(aP_LENCOL[Z,1])))==cAnt
                       aC_ITEM[LEN(aC_ITEM),Z+2] := SPACE(aP_LENCOL[Z,2]) // Não preenche o NalSh se for igual ao anterior
                    else
                       aC_ITEM[LEN(aC_ITEM),Z+2] := TMP->(FIELDGET(FIELDPOS(aP_LENCOL[Z,1])))
                    endif
                    cAnt:=TMP->(FIELDGET(FIELDPOS(aP_LENCOL[Z,1])))
                 Else
                    IF Z == 4
                       cA := ALLTRIM(TMP->(FIELDGET(FIELDPOS(aP_LENCOL[Z,1]))))+" "+ALLTRIM(TMP->TMP_UNIDAD)
                       aC_ITEM[LEN(aC_ITEM),Z+2] := PADL(cA,LEN(TMP->(FIELDGET(FIELDPOS(aP_LENCOL[Z,1]))))," ")
                    ELSE
                       aC_ITEM[LEN(aC_ITEM),Z+2] := TMP->(FIELDGET(FIELDPOS(aP_LENCOL[Z,1])))
                    ENDIF
                    /// LCS.09/11/2005.09:55-ACERTAR LENCOL. FALADO COM O ALEXANDER
                    ///aC_ITEM[LEN(aC_ITEM),Z+2] := TMP->(FIELDGET(FIELDPOS(aP_LENCOL[Z,1]))) + ;
                    ///if(Z==4," "+TMP->TMP_UNIDAD,"") //FJH 19/08/05 Adiciona unidade de Medida no campo unid ou qtd
                 Endif
              ELSE
                 aC_ITEM[LEN(aC_ITEM),Z+2] := SPACE(aP_LENCOL[Z,2])
              ENDIF
           ELSE
              aC_ITEM[LEN(aC_ITEM),Z+2] := PADR(TMP->(MEMOLINE(FIELDGET(FIELDPOS(aP_LENCOL[Z,1])),aP_LENCOL[Z,2],I)),aP_LENCOL[Z,2]," ")
           ENDIF
        ENDIF
    NEXT
NEXT
RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION EC09ADDNO1(aP_LENCON,nP_QTDLIN,aP_NOR)
LOCAL I,Z
BEGIN SEQUENCE
   FOR I := 1 TO LEN(aP_NOR)
       FOR Z := 1 TO MLCOUNT(aP_NOR[I,2],aP_LENCON[2,2])
           nLIN := nLIN+1
           AADD(aC_NORMA,ARRAY(LEN(aH_NORMA)+1))
           aC_NORMA[Len(aC_NORMA),LEN(aH_NORMA)+1] := .f. // Deleted
           aC_NORMA[Len(aC_NORMA),1] := nPAG
           aC_NORMA[Len(aC_NORMA),2] := nLIN
           aC_NORMA[LEN(aC_NORMA),3] := IF(Z=1,;
                                           PADR(aP_NOR[I,3,1]+IF(EMPTY(aP_NOR[I,3,2]),"","/"+aP_NOR[I,3,2]),aP_LENCON[1,2]," "),;
                                           SPACE(aP_LENCON[1,2]))
           aC_NORMA[LEN(aC_NORMA),4] := PADR(MEMOLINE(aP_NOR[I,2],aP_LENCON[2,2],Z),aP_LENCON[2,2]," ")
           IF nLIN = nP_QTDLIN
              BREAK
           ENDIF
       NEXT
   NEXT
   FOR I := nLIN+1 TO nP_QTDLIN
       nLIN := nLIN+1
       AADD(aC_NORMA,ARRAY(LEN(aH_NORMA)+1))
       aC_NORMA[Len(aC_NORMA),LEN(aH_NORMA)+1] := .f. // Deleted
       aC_NORMA[Len(aC_NORMA),1] := nPAG
       aC_NORMA[Len(aC_NORMA),2] := nLIN
       aC_NORMA[LEN(aC_NORMA),3] := SPACE(aP_LENCON[1,2])
       aC_NORMA[LEN(aC_NORMA),4] := SPACE(aP_LENCON[2,2])
   NEXT
END SEQUENCE
RETURN(NIL)
*--------------------------------------------------------------------
Static Function COATUBRW(ab_cField)
Local xOld
Begin Sequence
   IF Type("oGetIT") <> "O" .OR. TYPE("oGETNO") <> "O"
      Break
   Endif
   IF ab_cField == "WKLINHA"
      aCols[n,2] := M->WKLINHA
      aCols := aSort(aCols,,,{|x,y| Str(x[1],2)+Str(x[2],2) < Str(y[1],2)+Str(y[2],2)})
      M->WKLINHA := aCols[n,2]
   Else
      aCols[n,1] := M->WKPAGINA
      aCols := aSort(aCols,,,{|x,y| Str(x[1],2)+Str(x[2],2) < Str(y[1],2)+Str(y[2],2)})
      M->WKPAGINA := aCols[n,1]
   Endif
End Sequence
Return(.T.)
*--------------------------------------------------------------------
FUNCTION COTELAGETS(cP_TITULO,cP_MODELO,cP_CODIGO,cP_DOCTO,aP_LENCOL,aP_LENCON,cP_PROGRAMA,lFIESP)
/*
cP_TITULO   -> TITULO QUE VAI APARECER NA TELA DE GETS
cP_MODELO   -> MODELO DO DOCUMENTO.
               1-MERCOSUL - FIESP / CHILE / BOLIVIA
               2-ALADI
               3-COMUM - FIESP
               4-ARABE
               5-COMUM - ASSOCIACAO SANTOS
               6-MERCOSUL - ACS
               7-COMUM - FIEP
               8-GSTP - FIEP
               9-COMUM - FACISC  // LCS.15/11/2006
               A-MERCOSUL COLOMBIA, EQUADOR E VENEZUELA - FACISC
               B- C.O. FIEP
               B2 - C.O. FIEP ALADI e MÉXICO
               B3 - C.O. FIEP Comunidade Andina
cP_CODIGO   -> CODIGO DO PROCESSO / EMBARQUE
cP_DOCTO    -> CODIGO DO DOCUMENTO NO EEA. SE O CERTIFICADO FOR CHAMADO DO
               MENU, O CODIGO DO RELATORIO DE VE SER PASSADO NESTE PONTO
aP_LENCOL   -> VETOR COM AS COLUNAS QUE SERAO IMPRESSAS NO RELATORIO (ITENS)
aP_LENCON   -> VETOR COM AS COLUNAS QUE SERAO IMPRESSAS NO RELATORIO (NORMAS)
cP_PROGRAMA -> NOME DO PROGRAMA QUE CHAMOU A COTELAGETS
*/
LOCAL nA,nB,aBUTTONS,lVISU,oDLG,lMAISLI,nMAISDLG,nMAISFLD,nMAISOBS,;
      nMAISCHECK,nMAISEXP,nMAISIMP,nSIZE,lCONSIG4_5,nLFCONS,lMAISOBSAL,;
      bSHOW := {|nTELA,o| COTELASHOW(nTELA,o,aDLG)},;
      bHideAll := {|| Eval(bHide,aDLG[2]),EVAL(bHIDE,aDLG[3])},;
      bHIDE    := {|nTELA| COTELAHIDE(nTELA,aDLG)},;
      bOk      := {||nOpc:=1,oDlg:End()},;
      bCancel  := {||nOpc:=0,oDlg:End()},;
      LRET  := .F.,;
      XX       := "",;
      nOPC     := 0,;
      nMaisConsi:= 0
/// LCS - 29/08/2002 - VIROU FUNCAO, PORQUE ESTAVA FICANDO MUITO COMPLICADO
/// PARA LER O CODE BLOCK. COTELAHIDE() E COTELASHOW() RESPECTIVAMENTE.
///      bHIDE    := {|nTela| if(nTela=aDLG[2],oGETIT:oBrowse:Hide(),;
///                                      if(nTela=aDLG[3].AND.aDLG[3]>0,oGETNO:oBrowse:Hide(),))},;
///      bShow    := {|nTela,o| if(nTela=aDLG[2],EC2801("I"),;
///                                if(nTELA=aDLG[3],EC2801("N"),EC2801("L"))),;
///                           o := if(nTela=aDLG[2],oGETIT,oGETNO):oBrowse,;
///                             o:Show(),o:SetFocus(),o:Refresh()},;
// by CAF 29/06/2002 09:55
// Verificar se o EX0/EX1/EX2 existem no dicionario do cliente para
// habilitar a opção de salvar/abrir dados da ultima impressão
//Revisão: Fabrício e Diogo - 22/10/2009.
//         Atualização do layout para a versão 5 e padronização para quatro linhas nos campos 1.Produtor/ Exportador,
//         2.Importador e 3.Consignatário quando ativado o parâmetro MV_AVG0033.
//Local lExistEX0 := (Select("EX0") > 0 .And. Select("EX1") > 0 .And. Select("EX2") > 0)
Local lExistEX0 := .t.

Local nHPos  := 0
Local nCPos  := 0
Local nEPos  := 0
Local nValor := ""
Local oPanel
PRIVATE oGetIT,oGETNO,lITNO,nLITEM,nLNORMA,N,cNOME_EXP,cENDE_EXP,cCIDA_EXP,;
        cNOME_IMP,cENDE_IMP,cCIDA_IMP,cNOME_CON,cPAIS_CON,cPORTO,cPAISDT,;
        cVIA_TRAN,cNRINVO,dDTINVO,cOBS1,cOBS2,cOBS3,cOBS4,cINSTNEG,cDTEMIS,;
        dDTEMIS,cEXP4,cEXP5,cIMP4,cIMP5,cCONSIG3,cMEIOT1,cMEIOT2,cMEIOT3,;
        cMEIOT4,cMEIOT5,cMEIOT6,cCONSIG4,cCONSIG5,oFLD,aDLG,cDocto,;   //LCS.09/11/2006
        aHEADER  := {},aCOLS   := {},;
        bRefresh := {|cField| COATUBRW(cField), .t.},;
        cPAIS_EXP,cPAIS_IMP  // By JPP - 12/06/2006 - 15:30
Default lFIESP := .F.  // GFP - 03/12/2012
*
cEXP4    := cEXP5    := cIMP4   := cIMP5   :=  ""
cMEIOT1  := cMEIOT2  := cMEIOT3 := cMEIOT4 := cMEIOT5 := cMEIOT6 := ""
cCONSIG4 := cCONSIG5 := ""

DbSelectArea("EX0")
DbSelectArea("EX1")
DbSelectArea("EX2")

Private cDocumento := cP_MODELO //FDR - 29/08/13
Private lMAISLI //FDR - 29/08/13

cP_MODELO := If (cP_MODELO == NIL,"",cP_MODELO) //LRS - 02/12/2014 - Verificação dos tipos da variavel para não apresentar Erro Log
cP_TITULO := If (cP_TITULO == NIL,"",cP_TITULO)
cDocto    := IF (cDocto    == NIL,"",cDocto)

cDocto := (cP_TITULO+","+cP_MODELO)

IF lExistEX0
   aBUTTONS := {{"OPEN",{|| LE_EX012(cP_CODIGO,cP_DOCTO,aP_LENCOL,aP_LENCON,lMAISLI,cP_MODELO,lCONSIG4_5)},STR0144}} //"Ultima Impressão"
Else
   aButtons := nil
Endif
BEGIN SEQUENCE
   cP_TITULO  := IF(cP_TITULO  =NIL,""             ,cP_TITULO)   // INDICA O TITULO DA JANELA DOS FOLDERS
   cP_MODELO  := IF(cP_MODELO  =NIL,"1"            ,cP_MODELO)   // INDICA O MODELO DO DOCUMENTO
   If Type("lEmbarque") <> "L"
      lEmbarque := .T.
   EndIf
   If lEmbarque   // ** By OMJ 11/09/2005 - Guardar a Ultima impresso do C.O. por Invoice.
      cP_CODIGO  := IF(cP_CODIGO  =NIL,EEC->EEC_PREEMB    ,cP_CODIGO)   // INDICA O CODIGO DO PROCESSO/EMBARQUE
   Else
      If EECFlags("INVOICE")
         cP_CODIGO  := IF(cP_CODIGO  =NIL,WorkEXP->EXP_NRINVO,cP_CODIGO)   // INDICA O CODIGO DO PROCESSO/EMBARQUE
      Else
         cP_CODIGO  := IF(cP_CODIGO  =NIL,EEC->EEC_PREEMB    ,cP_CODIGO)
      EndIf
   EndIf
   cP_DOCTO   := IF(cP_DOCTO   =NIL,WORKID->EEA_COD,cP_DOCTO )   // INDICA O CODIGO DO DOCUMENTO NO HISTORICO
   nSIZE      := IF(cP_MODELO  ="4",05,08)  // INDICA A ALTURA DOS GETS
   lMAISLI    := EasyGParam("MV_AVG0033",,.F.)
   nMAISDLG   := nMAISFLD := nMAISCHECK := nMAISEXP := nMAISIMP := 0
   lCONSIG4_5 := IF(lExistEX0,EX0->(FIELDPOS("EX0_CONS4")#0.AND.FIELDPOS("EX0_CONS5")#0),.f.)
   nLFCONS    := IF(lCONSIG4_5,154,134)
   lMV_0040   := EasyGParam("MV_AVG0040",,.F.)
   nMAISOBS   := IF(lMV_0040,20,0)
   IF lMAISLI
      IF cP_MODELO = '3' // Comum
         nMAISDLG   := 44
         nMAISFLD   := 25
         nMAISCHECK := 24
         nMAISEXP   := 20  //30 5 GETS
         nMAISIMP   := 50  //60 5 GETS
      ELSEIF cP_MODELO = '1' // MERCOSUL / CHILE / BOLIVIA
             nMAISDLG   := 15
             nMAISFLD   := 09
             nMAISCHECK := 09
             nMAISEXP   := 0
             nMAISIMP   := 10
      ELSEIF cP_MODELO = "4"  // ARABE
             nMAISDLG   := 44//89
             nMAISFLD   := 25//48
             nMAISCHECK := 24//47
             nMAISEXP   := 20
             nMAISIMP   := 40
      ELSEIF cP_MODELO = "5" // COMUM - ASSOCIACAO SANTOS
             nMAISDLG   := 44
             nMAISFLD   := 25
             nMAISCHECK := 24
             nMAISEXP   := 10 // 30
             nMAISIMP   := 50 // 60
      ELSEIF cP_MODELO = "6"  // MERCOSUL - ASSOCIAO SANTOS
             nMAISDLG   := 31
             nMAISFLD   := 19
             nMAISCHECK := 19
             nMAISEXP   := 10
             nMAISIMP   := 20
      ElseIf cP_MODELO = "7"  // BY JPP - 12/06/2006 - 15:30
             nMAISDLG   := 15
             nMAISFLD   := 09
             nMAISCHECK := 09
             nMAISEXP   := 10
             nMAISIMP   := 20
      ElseIf cP_MODELO = "8"  // BY JPP - 14/06/2006 - 17:30
             nMAISDLG   := 30
             nMAISFLD   := 15
             nMAISCHECK := 09
             nMAISEXP   := 10  // 0
             nMAISIMP   := 20

      ElseIf cP_Modelo == "B"
             nMaisDlg   := 70
             nMaisFld   := 45
             nMaisCheck := 30
             nMaisExp   := 10
             nMaisImp   := 20
      ENDIF
   ELSEIF cP_MODELO = "4"  // ARABE
          nMAISDLG   := 44//89
          nMAISFLD   := 25//48
          nMAISCHECK := 24//47
   ELSEIF cP_Modelo == "B"
      If lCONSIG4_5
         nMaisDlg := 40
         nMaisFld := 30
         nMaisCheck := 10
      Else
         nMaisDlg := 20
         nMaisFld := 20
      EndIf
   ELSEIF cP_MODELO = "7" .And. lCONSIG4_5
          nMAISDLG   := 15
          nMAISFLD   := 09
          nMAISCHECK := 09
   ELSEIF cP_MODELO = "8"
      If lCONSIG4_5
         nMAISDLG   := 30
         nMAISFLD   := 15
         nMAISCHECK := 09
      Else
         nMAISDLG   := 10
         nMAISFLD   := 05
      EndIf
   ENDIF
   *
   If Type("oText") = "O"
      MsProcTxt(STR0116) //"Preparando dados. Aguarde !"
   EndIf

   // EXPORTADOR
   cNOME_EXP := PADR(aCAB[1,1],50," ")
   cENDE_EXP := PADR(aCAB[1,2],50," ")
   cCIDA_EXP := PADR(aCAB[1,3],50," ")
   cPAIS_EXP := PADR(aCAB[1,4],50," ") // By JPP - 12/06/2006 - 15:30
   // IMPORTADOR
   cNOME_IMP := PADR(aCAB[2,1],50," ")
   cENDE_IMP := PADR(MEMOLINE(aCAB[2,2],50,1),50," ")
   cCIDA_IMP := PADR(MEMOLINE(aCAB[2,2],50,2),50," ")
   cPAIS_IMP := PADR(aCAB[2,4],50," ")
   // CONSIGNATARIO
   cNOME_CON := PADR(aCAB[3,1],50," ")
   cPAIS_CON := PADR(aCAB[3,2],50," ")
   cCONSIG3  := PADR(aCAB[3,3],50," ")
   cCONSIG4  := PADR(aCAB[3,4],50," ")
   cCONSIG5  := PADR(aCAB[3,5],50," ")
   // VIA DE TRANSPORTE
   cVIA_TRAN := PADR(aCAB[6],50," ")
   // NUMERO/DATA DA INVOICE
   cNRINVO := PADR(aCAB[7],20," ")
   dDTINVO := CTOD(aCAB[8])
   // PORTO/LOCAL DE EMBARQUE
   cPORTO := PADR(aCAB[4],50," ")
   // PAIS DE DESTINO / DATA DE EMISSAO DO CERTIFICADO
   cPAISDEST := PADR(aCAB[5],50," ")
   dDTEMIS   := CTOD(aROD[5])
   // OBSERVACOES
   cOBS1 := aROD[1,1]
   cOBS2 := aROD[1,2]
   cOBS3 := aROD[1,3]
   cOBS4 := aROD[1,4]
   cOBS5 := aROD[1,5]
   cOBS6 := aROD[1,6]
   cOBS7 := aROD[1,7]
   cOBS8 := aROD[1,8]
   // INSTRUMENTO DE NEGOCIACAO
   cINSTNEG := aROD[2]
   // DATA DE EMISSAO DO CERTIFICADO POR EXTENSO
   cDTEMIS := PADR(aROD[4],50," ")
   IF lMAISLI
      // EXPORTADOR
      cEXP4 := PADR(aCAB[1,5],50," ")
      cEXP5 := PADR(aCAB[1,6],50," ")
      // IMPORTADOR
      cIMP4 := PADR(aCAB[2,5],50," ")
      cIMP5 := PADR(aCAB[2,6],50," ")
   ENDIF
   // MEIO DE TRANSPORTE / DESTINO
   cMEIOT1 := PADR(aCAB[9,1],50," ")
   cMEIOT2 := PADR(aCAB[9,2],50," ")
   cMEIOT3 := PADR(aCAB[9,3],50," ")
   cMEIOT4 := PADR(aCAB[9,4],50," ")
   cMEIOT5 := PADR(aCAB[9,5],50," ")
   cMEIOT6 := PADR(aCAB[9,6],50," ")
   *
   lVISU   := .F.
   nLNORMA := nLITEM := N := 1
   If EasyEntryPoint("EECCAD00")
        ExecBlock("EECCAD00", .F., .F., {"ALTERA_COFIG"}) //LRS 23/8/2013 - 9:21 Chamado 102462 Ponto de entrada
   EndIf
   DEFINE MSDIALOG oDlg TITLE STR0117+ALLTRIM(cP_TITULO) FROM 0,0 TO 470+nMAISDLG,688 OF oMainWnd PIXEL //"Certificado de Origem - "
      oPanel:= TPanel():New(0, 0, "",oDlg,, .F., .F.,,, 40.5, 7.5)
      IF cP_MODELO = "1" .OR. ; // MER-FIESP.CHI.BOL.
         cP_MODELO = "6" .Or. ; // MERCOSUL - ACS
         cP_MODELO = "A" .Or. ; // MERCOSUL COL,EQU E VEN (FACISC)  // LCS.16/11/2006.
         cP_MODELO == "B" .Or.; // FIEP
         cP_MODELO == ""        //LRS - 02/12/2014
         *
         oFLD := TFolder():New(15,1,{STR0118,STR0119,STR0120,STR0121},{"CAB","ITE","NOR","ROD"},oPanel,,,,.T.,.F.,351,177+nMAISFLD) //"&Cabecalho"###"&Itens"###"&Normas"###"&Rodape"
         aDLG := {1,2,3,4}
      ELSEIF cP_MODELO = "2" .Or.;
             cP_MODELO == "B2" //Fiep Aladi e México
             oFLD := TFolder():New(15,1,{STR0119,STR0120,STR0122},{"ITE","NOR","OUT"},oPanel,,,,.T.,.F.,341,177+nMAISFLD) //"&Itens"###"&Normas"###"&Outros"
             aDLG := {0,1,2,3}
      ELSEIF cP_MODELO == "B3" //Fiep Comun. Andina
             oFLD := TFolder():New(15,1,{STR0123+"/ "+STR0124,STR0119,STR0120,STR0122},{"CAB","ITE","NOR","OUT"},oPanel,,,,.T.,.F.,341,177+nMAISFLD) //Exportador/ Importador - Normas - Outros
             aDLG := {1,2,3,4}
      ELSEIF cP_MODELO = "3" .Or. ;
             cP_MODELO = "5" .Or. ; // LCS.15/11/2006
             cP_MODELO = "9"  // COMUM ACS // LCS.15/11/2006
             *
             oFLD := TFolder():New(15,1,{STR0118,STR0119,STR0122},{"CAB","ITE","OUT"},oPanel,,,,.T.,.F.,341,177+nMAISFLD) //"&Cabecalho"###"&Itens"###"&Outros"
             aDLG := {1,2,0,3}
      ELSEIF cP_MODELO = "4"  // ARABIA
             oFLD := TFolder():New(15,1,{STR0118,STR0119,STR0122},{"CAB","ITE","OUT"},oPanel,,,,.T.,.F.,341,177+nMAISFLD) //"&Cabecalho"###"&Itens"###"&Outros"###
             aDLG := {1,2,0,3}
      ElseIf cP_MODELO = "7" // Comum FIEP // By JPP - 12/06/2006 - 15:30
             oFLD := TFolder():New(15,1,{STR0118,STR0119,STR0121},{"CAB","ITE","ROD"},oPanel,,,,.T.,.F.,341,177+nMAISFLD) //"&Cabecalho"###"&Itens"###"&Normas"###"&Rodape"
             aDLG := {1,2,0,3}
      ElseIf cP_MODELO = "8" // GSTP FIEP // By JPP - 14/06/2006 - 17:20
             oFLD := TFolder():New(15,1,{STR0118,STR0119,STR0121},{"CAB","ITE","ROD"},oPanel,,,,.T.,.F.,341,187+nMAISFLD) //"&Cabecalho"###"&Itens"###"&Normas"###"&Rodape"
             aDLG := {1,2,0,3}
      ENDIF
      aEval(oFld:aControls,{|x| x:SetFont(oDlg:oFont) })
      /// POSICAO 1
      IF aDLG[1] > 0
         /// CABECALHO

         If !lMaisLi .And. (cP_MODELO = "7" .Or. cP_MODELO = "8")
              nMAISEXP += 10
              nMAISIMP += 20
         Endif

         @ 003,002 TO 045+nMAISEXP,337 LABEL STR0123 PIXEL OF oFld:aDialogs[aDLG[1]] //"Exportador"
         @ 010,005 MSGET cNOME_EXP      OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
         @ 020,005 MSGET cENDE_EXP      OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
         @ 030,005 MSGET cCIDA_EXP      OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
         IF lMAISLI .AND. (cP_MODELO = "3" .OR. cP_MODELO = "4" .Or. cP_MODELO = "5" .OR. cP_MODELO = "6" .Or. cP_Modelo == "B")
            @ 040,005 MSGET cEXP4 OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
            IF (cP_MODELO = "3" .OR. cP_MODELO = "4")
               @ 050,005 MSGET cEXP5 OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
            ENDIF
         ElseIf cP_MODELO = "7" .Or. cP_MODELO = "8" // By JPP - 12/06/2006 - 15:30
            @ 040,005 MSGET cPAIS_EXP OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
         ENDIF
         *
         IF cP_MODELO <> "8"   // BY JPP - 14/06/2006 - 17:30
            @ 047+nMAISEXP,002 TO 089+nMAISIMP,337 LABEL STR0124 PIXEL OF oFld:aDialogs[aDLG[1]] //"Importador"
            @ 054+nMAISEXP,005 MSGET cNOME_IMP      OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
            @ 064+nMAISEXP,005 MSGET cENDE_IMP      OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
            @ 074+nMAISEXP,005 MSGET cCIDA_IMP      OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
         EndIf
         IF lMAISLI
            IF cP_MODELO = "3" .OR.;  // COMUM - FIESP
               cP_MODELO = "4" .OR.;  // ARABIA
               cP_MODELO = "5"        // COMUM - ACS
               *
               @ 084+nMAISEXP,005 MSGET cIMP4 OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
               @ 094+nMAISEXP,005 MSGET cIMP5 OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
            ELSEIF cP_MODELO = "1" .OR.; // MER-FIESP.CHI.BOL.
                   cP_MODELO = "6" .Or.; // MERCOSUL-ACS
                   cP_Modelo == "B"      // Fiep
                   *
                   @ 084+nMAISEXP,005 MSGET cIMP4 OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
            ENDIF
         ENDIF
         If cP_MODELO = "7"  // COMUM FIEP // By JPP - 12/06/2006 - 15:30
            @ 084+nMAISEXP,005 MSGET cPAIS_IMP OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08

            If !lCONSIG4_5
               nMAISEXP -= 10
            Endif

            @ 091+nMAISIMP,002 TO 124+nMAISIMP+nMAISEXP,337 LABEL STR0125 PIXEL OF oFld:aDialogs[aDLG[1]] //"Consignatario"
            @ 098+nMAISIMP,005 MSGET cNOME_CON OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
            //@ 108+nMAISIMP,005 MSGET cPAIS_CON OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
            If lCONSIG4_5 //wfs 23/10/09
               @ 108+nMAISIMP,005 MSGET cConsig3 OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
               @ 118+nMAISIMP,005 MSGET cPAIS_CON OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
            Else
               @ 108+nMAISIMP,005 MSGET cPAIS_CON OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
            EndIf

            @ 130+nMAISIMP+nMAISEXP,005 SAY   STR0129    OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 030,08 //"Dt. Invoice" //012
            @ 130+nMAISIMP+nMAISEXP,037 MSGET dDTINVO    OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 035,08 PICTURE "@D"  // 042
            @ 130+nMAISIMP+nMAISEXP,083 SAY   STR0130    OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 030,08 //"Nr. Invoice"  //090
            @ 130+nMAISIMP+nMAISEXP,118 MSGET cNRINVO    OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 090,08 // 125
         EndIf
         *
         IF cP_MODELO = "8"

            //@ 047+nMAISEXP,002 TO 089+nMAISIMP,337 LABEL STR0124 PIXEL OF oFld:aDialogs[aDLG[1]] //"Importador"
            //@ 054+nMAISEXP,005 MSGET cPAIS_IMP      OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
            @ 047+nMAISEXP,002 TO 099+nMAISEXP,337 LABEL STR0125 PIXEL OF oFld:aDialogs[aDLG[1]] //"Consignatario"
            @ 054+nMAISEXP,005 MSGET cNOME_CON OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
            @ 064+nMAISEXP,005 MSGET cCONSIG3  OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
            @ 074+nMAISEXP,005 MSGET cPAIS_CON OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
            @ 084+nMAISEXP,005 MSGET cConsig4  OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08

            //@ 091+nMAISEXP,005 SAY   STR0128    OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 045,08 //"Via de Transporte"
            //@ 091+nMAISEXP,055 MSGET cVIA_TRAN  OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 042,08

            If !lMaisLi
               nMAISEXP:= 0
               cMEIOT4 := ""
            EndIf

            @ 111,002 TO 164+nMAISEXP,337 LABEL STR0147 PIXEL OF oFld:aDialogs[aDLG[1]] //Meio de Transporte/ Destino
            @ 119,005 MSGET cVIA_TRAN OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
            @ 129,005 MSGET cMEIOT1   OF oFLD:aDIALOGS[aDLG[1]] PIXEL SIZE 210,08
            @ 139,005 MSGET cMEIOT2   OF oFLD:aDIALOGS[aDLG[1]] PIXEL SIZE 210,08
            @ 149,005 MSGET cMEIOT3   OF oFLD:aDIALOGS[aDLG[1]] PIXEL SIZE 210,08

            If lMaisLi
               @ 159,005 MSGET cMEIOT4   OF oFLD:aDIALOGS[aDLG[1]] PIXEL SIZE 210,08
            EndIf
            //@ 050,005 MSGET cMEIOT5 OF oFLD:aDIALOGS[aDLG[4]] PIXEL SIZE 210,08
            //@ 060,005 MSGET cMEIOT6 OF oFLD:aDIALOGS[aDLG[4]] PIXEL SIZE 210,08
         EndIf
         *
         IF cP_MODELO = "9" // COMUM - FACISC // LCS.15/11/2006
            @ 091,002 TO 134,337 LABEL STR0125 PIXEL OF oFld:aDialogs[aDLG[1]]  //"Consignatario" // LCS.15/11/2006
            @ 098,005 MSGET cNOME_CON OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08 // LCS.15/11/2006
            @ 108,005 MSGET cCONSIG3  OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08 // LCS.15/11/2006
            @ 118,005 MSGET cPAIS_CON OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08 // LCS.15/11/2006
            * // LCS.15/11/2006
            @ 136,002 TO 160,337 LABEL "" PIXEL OF oFld:aDialogs[aDLG[1]]  // LCS.15/11/2006
            @ 143,005 SAY   STR0130             OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 030,08 //"Nr. Invoice" // LCS.15/11/2006
            @ 143,037 MSGET cNRINVO             OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 090,08 // LCS.15/11/2006
            @ 143,130 SAY   STR0129             OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 030,08 //"Dt. Invoice" // LCS.15/11/2006
            @ 143,165 MSGET dDTINVO             OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 035,08 PICTURE "@D"  // LCS.15/11/2006
         ENDIF // LCS.15/11/2006
         *
         IF cP_MODELO = "1" .OR.; // MER-FIESP.CHI.BOL
            cP_MODELO = "4" .OR.; // ARABIA
            cP_MODELO = "6" .OR.; // MERCOSUL-ACS // LCS.16/11/2006
            cP_MODELO = "A" .Or.; // MERCOSUL COL,EQU E VEN (FACISC) // LCS.16/11/2006
            cP_MODELO == "B"      // FIEP
            *
            IF cP_MODELO = "1" .OR.;  // MER-FIESP.CHI.BOL
               cP_MODELO = "6"        // MERCOSUL-ACS
               *
               @ 091+nMAISIMP,002 TO 124+nMAISIMP+nMAISEXP,337 LABEL STR0125 PIXEL OF oFld:aDialogs[aDLG[1]] //"Consignatario"
               @ 098+nMAISIMP,005 MSGET cNOME_CON OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
               @ 108+nMAISIMP,005 MSGET cPAIS_CON OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
               *
               @ 126+nMAISIMP+nMAISEXP,002 TO 158+nMAISIMP+nMAISEXP,337 PIXEL OF oFld:aDialogs[aDLG[1]]
               @ 133+nMAISIMP+nMAISEXP,005 SAY   STR0126    OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 045,08 //"Porto/L.Embarque"
               @ 132+nMAISIMP+nMAISEXP,055 MSGET cPORTO     OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 122,08
               @ 133+nMAISIMP+nMAISEXP,190 SAY   STR0127    OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 030,08 //"Pais Destino"
               @ 132+nMAISIMP+nMAISEXP,225 MSGET cPAISDEST  OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 110,08
               @ 143+nMAISIMP+nMAISEXP,005 SAY   STR0128    OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 075,08 //"Via de Transporte"
               @ 142+nMAISIMP+nMAISEXP,055 MSGET cVIA_TRAN  OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 055,08
               @ 143+nMAISIMP+nMAISEXP,112 SAY   STR0129    OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 030,08 //"Dt. Invoice"
               @ 142+nMAISIMP+nMAISEXP,142 MSGET dDTINVO    OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 035,08 PICTURE "@D"
               @ 143+nMAISIMP+nMAISEXP,190 SAY   STR0130    OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 030,08 //"Nr. Invoice"
               @ 142+nMAISIMP+nMAISEXP,225 MSGET cNRINVO    OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 090,08

            ElseIf cP_MODELO == "B" //FIEP

               If lCONSIG4_5
                  nMaisConsi:= 10
               EndIf

               @ 091+nMAISIMP,002 TO 133+nMAISIMP+nMaisConsi,337 LABEL STR0125 PIXEL OF oFld:aDialogs[aDLG[1]] //"Consignatario"
               @ 098+nMAISIMP,005 MSGET cNOME_CON OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
               @ 108+nMAISIMP,005 MSGET cPAIS_CON OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
               @ 118+nMAISIMP,005 MSGET cConsig3  OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08

               If lCONSIG4_5
                  @ 128+nMAISIMP,005 MSGET cConsig4  OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
               EndIf

               @ 138+nMAISIMP+nMaisConsi,002 TO 167+nMAISIMP+nMaisConsi,337 PIXEL OF oFld:aDialogs[aDLG[1]]
               @ 143+nMAISIMP+nMaisConsi,005 SAY   STR0126    OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 045,08 //"Porto/L.Embarque"
               @ 142+nMAISIMP+nMaisConsi,055 MSGET cPORTO     OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 122,08
               @ 143+nMAISIMP+nMaisConsi,190 SAY   STR0127    OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 030,08 //"Pais Destino"
               @ 142+nMAISIMP+nMaisConsi,225 MSGET cPAISDEST  OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 110,08
               @ 153+nMAISIMP+nMaisConsi,005 SAY   STR0128    OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 075,08 //"Via de Transporte"
               @ 152+nMAISIMP+nMaisConsi,055 MSGET cVIA_TRAN  OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 055,08
               @ 153+nMAISIMP+nMaisConsi,112 SAY   STR0129    OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 030,08 //"Dt. Invoice"
               @ 152+nMAISIMP+nMaisConsi,142 MSGET dDTINVO    OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 035,08 PICTURE "@D"
               @ 153+nMAISIMP+nMaisConsi,190 SAY   STR0130    OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 030,08 //"Nr. Invoice"
               @ 152+nMAISIMP+nMaisConsi,225 MSGET cNRINVO    OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 090,08

            ELSEIF cP_MODELO = "4"  // ARABIA
                   @ 091+nMAISIMP,002 TO nLFCONS+nMAISIMP,337 LABEL STR0125 PIXEL OF oFld:aDialogs[aDLG[1]] //"Consignatario"
                   @ 098+nMAISIMP,005 MSGET cNOME_CON OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
                   @ 118+nMAISIMP,005 MSGET cCONSIG3  OF oFLD:aDIALOGS[aDLG[1]] PIXEL SIZE 210,08
                   @ 108+nMAISIMP,005 MSGET cPAIS_CON OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 210,08
                   *
                   IF lCONSIG4_5
                      @ 128+nMAISIMP,005 MSGET cCONSIG4 OF oFLD:aDIALOGS[aDLG[1]] PIXEL SIZE 210,08
                      @ 138+nMAISIMP,005 MSGET cCONSIG5 OF oFLD:aDIALOGS[aDLG[1]] PIXEL SIZE 210,08
                   ENDIF
            ELSEIF cP_MODELO = "A" // LCS.16/11/2006.
                   @ 091,002 TO 134,337 LABEL "" PIXEL OF oFld:aDialogs[aDLG[1]] // LCS.16/11/2006.
                   @ 098,005 SAY   STR0126             OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 045,08 //"Porto/L.Embarque" // LCS.16/11/2006.
                   @ 098,055 MSGET cPORTO              OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 122,08 // LCS.16/11/2006.
                   @ 098,185 SAY   STR0127             OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 070,08 //"Pais Importador" // LCS.16/11/2006.
                   @ 098,225 MSGET cPAIS_IMP           OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 090,08 // LCS.16/11/2006.
                   *                                                                                        // LCS.16/11/2006.
                   @ 108,005 SAY   STR0128             OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 075,08 //"Via de Transporte" // LCS.16/11/2006.
                   @ 108,055 MSGET cVIA_TRAN           OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 060,08 // LCS.16/11/2006.
                   @ 108,185 SAY   STR0130             OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 030,08 //"Nr. Invoice" // LCS.16/11/2006.
                   @ 108,225 MSGET cNRINVO             OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 090,08 // LCS.16/11/2006.
                   *                                                                               // LCS.16/11/2006.
                   @ 118,005 SAY   STR0135             OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 075,08 //"Data de Emissao" // LCS.16/11/2006.
                   @ 118,055 MSGET cDTEMIS             OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 125,08 // LCS.16/11/2006.
                   @ 118,185 SAY   STR0129             OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 030,08 //"Dt. Invoice" // LCS.16/11/2006.
                   @ 118,225 MSGET dDTINVO             OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 035,08 PICTURE "@D" // LCS.16/11/2006.
            ENDIF
         ELSEIF (cP_MODELO = "3" .Or. cP_MODELO = "5")
                @ 091+nMAISIMP,002 TO 124+nMAISIMP,337 OF oFld:aDialogs[aDLG[1]] PIXEL
                @ 098+nMAISIMP,005 SAY   STR0131       OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 045,08 //"Cidade de Destino"
                @ 098+nMAISIMP,055 MSGET cPORTO        OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 122,08
                @ 108+nMAISIMP,005 SAY   STR0132       OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 045,08 //"Pais de Destino"
                @ 108+nMAISIMP,055 MSGET cPAISDEST     OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 110,08
         ELSEIF cP_MODELO == "B3" //Comunidade Andina
                @ 091,002 TO 123,337 LABEL "" PIXEL OF oFld:aDialogs[aDLG[1]]
                @ 098,005 SAY   STR0126             OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 045,08 //Porto/L.Embarque
                @ 098,055 MSGET cPORTO              OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 122,08
                @ 098,185 SAY   STR0127             OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 070,08 //Pais Importador
                @ 098,225 MSGET cPAIS_IMP           OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 090,08
                @ 108,005 SAY   STR0128             OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 075,08 //Via de Transporte
                @ 108,055 MSGET cVIA_TRAN           OF oFld:aDialogs[aDLG[1]] PIXEL SIZE 060,08
         ENDIF
      ENDIF
      /// POSICAO 2 - ITENS
      @ 05,001 GET xx OF oFld:aDialogs[aDLG[2]]
      EC2801("I")
      aPos  := PosDlg(oFld:aDialogs[aDLG[2]])
      oGetIT:= AV_MultiLine( 003,002,aPos[3],aPos[4],.T.,.T.,,,oFld:aDialogs[aDLG[2]])
      oGetIT:oBrowse:Refresh()
      // POSICAO 3 - NORMAS
      IF aDLG[3] > 0
         @ 05,001 GET xx OF oFld:aDialogs[aDLG[3]]
         EC2801("N")
         aPos  := PosDlg(oFld:aDialogs[aDLG[3]])
         oGetNO:= AV_MultiLine( 003,002,aPos[3],aPos[4],.T.,.T.,,,oFld:aDialogs[aDLG[3]])
         oGetNO:oBrowse:Refresh()
      ENDIF
      // POSICAO 4 - RODAPE OU OUTROS
      IF cP_MODELO = "1" .OR.;  // MERCOSUL-FIESP/CHILE/BOLIVIA
         cP_MODELO = "6" .Or.;  // MERCOSUL-ACS
         cP_MODELO == "B" .Or. cP_MODELO == "7" // FIEP
         *
         @ 003,002 TO 055,337 LABEL STR0133 PIXEL OF oFld:aDialogs[aDLG[4]] //"Observacoes"
         @ 010,005 MSGET cOBS1 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
         @ 020,005 MSGET cOBS2 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
         @ 030,005 MSGET cOBS3 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
         //@ 040,005 MSGET cOBS4 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08//FSY - 13/08/2013 Nopado por nao ser utilizado no relatorio PEM61,EECPEN61()

         @ 057,002 TO 077,337 PIXEL OF oFld:aDialogs[aDLG[4]]
         //WFS 16/10/09
         If cP_MODELO == "B" .Or. cP_MODELO == "7" //C.O. FIEP
            @ 064,005 SAY   STR0135    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 040,08 //"Data de Emissao"
            @ 064,055 MSGET dDTEMIS    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 065,08
         Else
            @ 064,005 SAY   STR0134    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 070,08 //"Instrumento de Negociacao"
            @ 064,075 MSGET cINSTNEG   OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 080,08

            @ 064,165 SAY   STR0135    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 040,08 //"Data de Emissao"
            @ 063,210 MSGET cDTEMIS    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 125,08
         EndIf

      ELSEIF cP_MODELO == "B2" // FIEP ALADI e MÉXICO

         @ 003, 002 To 023, 337 Pixel Of oFld:aDialogs[aDLG[4]]
         @ 009, 005 Say   STR0130   Of oFld:aDialogs[aDLG[4]] Pixel Size 030,08 //Nr. Invoice
         @ 008, 037 MsGet cNRINVO   Of oFld:aDialogs[aDLG[4]] Pixel Size 090,08
         @ 009, 185 Say   STR0127   Of oFld:aDialogs[aDLG[4]] Pixel Size 070,08 //País Destino
         @ 008, 225 MsGet cPAIS_IMP Of oFld:aDialogs[aDLG[4]] Pixel Size 090,08

         @ 028, 002 TO 050+nMAISEXP, 337 LABEL STR0123 PIXEL OF oFld:aDialogs[aDLG[4]] //"Exportador"
         @ 035, 005 MSGET cNOME_EXP OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 210,08

         @ 055, 002 TO 107+nMAISEXP,337 LABEL STR0133 PIXEL OF oFld:aDialogs[aDLG[4]] //"Observacoes"
         @ 062, 005 MSGET cOBS1 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 280,08
         @ 072, 005 MSGET cOBS2 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 280,08
         @ 082, 005 MSGET cOBS3 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 280,08
         @ 092, 005 MSGET cOBS4 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 280,08

         @ 112, 002 TO 132+nMAISEXP,337 PIXEL OF oFld:aDialogs[aDLG[4]]
         @ 118, 005 SAY   STR0135    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 040,08 //"Data de Emissao"
         @ 117, 055 MSGET dDTEMIS    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 065,08

      ElseIf cP_MODELO == "B3" //Comunidade Andina

         @ 003, 002 To 023, 337 Pixel Of oFld:aDialogs[aDLG[4]]
         @ 008, 005 Say   STR0130 Of oFld:aDialogs[aDLG[4]] Pixel Size 030,08 //Nr. Invoice
         @ 007, 037 MsGet cNRINVO Of oFld:aDialogs[aDLG[4]] Pixel Size 090,08
         @ 008, 185 Say   STR0129 Of oFld:aDialogs[aDLG[4]] Pixel Size 030,08 //Dt. Invoice
         @ 007, 225 MsGet dDTINVO Of oFld:aDialogs[aDLG[4]] Pixel Size 035,08

         @ 028,002 TO 070+nMAISEXP,337 LABEL STR0133 PIXEL OF oFld:aDialogs[aDLG[4]] //"Observacoes"
         @ 035,005 MSGET cOBS1 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 210,08
         @ 045,005 MSGET cOBS2 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 210,08
         @ 055,005 MSGET cOBS3 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 210,08

         @ 080,002 TO 100,337 PIXEL OF oFld:aDialogs[aDLG[4]]
         @ 085,005 SAY   STR0135    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 040,08 //"Data de Emissao"
         @ 085,055 MSGET dDTEMIS    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 065,08

      ELSEIF cP_MODELO = "2"  // ALADI
             @ 003,002 TO 035+nMAISOBS,337 LABEL STR0133     PIXEL OF oFld:aDialogs[aDLG[4]] //"Observacoes"
             @ 010,005 MSGET cOBS1 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
             @ 020,005 MSGET cOBS2 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
             IF lMV_0040
                @ 030,005 MSGET cOBS3 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
                @ 040,005 MSGET cOBS4 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
             ENDIF
             @ 037+nMAISOBS,002 TO 067+nMAISOBS,337 PIXEL OF oFld:aDialogs[aDLG[4]]
             @ 044+nMAISOBS,005 SAY   STR0134    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 070,08 //"Instrumento de Negociacao"
             @ 044+nMAISOBS,075 MSGET cINSTNEG   OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 080,08
             @ 044+nMAISOBS,225 SAY   STR0135    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 040,08 //"Data de Emissao"
             @ 044+nMAISOBS,270 MSGET dDTEMIS    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 035,08
             @ 054+nMAISOBS,005 SAY   STR0136    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 060,08 //"Data Por Extenso"
             @ 054+nMAISOBS,075 MSGET cDTEMIS    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 125,08
      ELSEIF cP_MODELO = "3" .Or. ; // LCS.16/11/2006.
             cP_MODELO = "5" .Or. ; // LCS.16/11/2006.
             cP_MODELO = "A" // LCS.16/11/2006.
             *
             IF cP_MODELO <> "A" .AND. !lFIESP // LCS.16/11/2006.  // GFP - 03/12/2012
                @ 003,002 TO 095,337 LABEL STR0133 PIXEL OF oFld:aDialogs[aDLG[4]] //"Observacoes" // LCS.16/11/2006.
             ELSE // LCS.16/11/2006.
                @ 003,002 TO 045,337 LABEL STR0133 PIXEL OF oFld:aDialogs[aDLG[4]] //"Observacoes" // LCS.16/11/2006.
             ENDIF // LCS.16/11/2006.
             @ 010,005 MSGET cOBS1 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
             @ 020,005 MSGET cOBS2 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
             @ 030,005 MSGET cOBS3 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
             IF cP_MODELO <> "A" .AND. !lFIESP // LCS.16/11/2006.       // GFP - 03/12/2012
                @ 040,005 MSGET cOBS4 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
                @ 050,005 MSGET cOBS5 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
                @ 060,005 MSGET cOBS6 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
                @ 070,005 MSGET cOBS7 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
                @ 080,005 MSGET cOBS8 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
             ENDIF // LCS.16/11/2006.
      ELSEIF cP_MODELO = "4"
             // MEIO DE TRANSPORTE
             @ 003,002 TO 075,337 LABEL STR0147 PIXEL OF oFld:aDialogs[aDLG[4]]
             @ 010,005 MSGET cMEIOT1 OF oFLD:aDIALOGS[aDLG[4]] PIXEL SIZE 210,08
             @ 020,005 MSGET cMEIOT2 OF oFLD:aDIALOGS[aDLG[4]] PIXEL SIZE 210,08
             @ 030,005 MSGET cMEIOT3 OF oFLD:aDIALOGS[aDLG[4]] PIXEL SIZE 210,08
             @ 040,005 MSGET cMEIOT4 OF oFLD:aDIALOGS[aDLG[4]] PIXEL SIZE 210,08
             @ 050,005 MSGET cMEIOT5 OF oFLD:aDIALOGS[aDLG[4]] PIXEL SIZE 210,08
             @ 060,005 MSGET cMEIOT6 OF oFLD:aDIALOGS[aDLG[4]] PIXEL SIZE 210,08
             // DATA DE EMISSAO
             @ 077,002 TO 099,337 LABEL STR0135 PIXEL OF oFld:aDialogs[aDLG[4]]
             @ 084,005 MSGET cDTEMIS OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 125,08
             /*

             Nopado por ER - 03/01/2007

             // OBSERVAÇÃO. AMS - 05/01/2004.
             If EX0->(FieldPos("EX0_CODOBS")) <> 0
                @ 101,002 To 210,337 Label STR0023 Pixel Of oFld:aDialogs[aDLG[4]]
                @ 108,005 Get cObs Memo Size 327,97 Of oFld:aDialogs[aDLG[4]] Pixel
             EndIf
             */
      ElseIf cP_MODELO = "7"  // By JPP - 12/06/2006 - 15:30
             @ 003,002 TO 035+nMAISOBS,337 LABEL STR0133     PIXEL OF oFld:aDialogs[aDLG[4]] //"Observacoes"
             @ 010,005 MSGET cOBS1 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
             @ 020,005 MSGET cOBS2 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
//             IF lMV_0040
//                @ 030,005 MSGET cOBS3 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
//                @ 040,005 MSGET cOBS4 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
//             ENDIF
//             @ 037+nMAISOBS,002 TO 067+nMAISOBS,337 PIXEL OF oFld:aDialogs[aDLG[4]]
//             @ 044+nMAISOBS,005 SAY   STR0134    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 070,08 //"Instrumento de Negociacao"
//             @ 044+nMAISOBS,075 MSGET cINSTNEG   OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 080,08
             //@ 044+nMAISOBS,225 SAY   STR0135    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 040,08 //"Data de Emissao"
             //@ 044+nMAISOBS,270 MSGET dDTEMIS    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 035,08
             @ 044+nMAISOBS,005 SAY   STR0136    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 060,08 //"Data Por Extenso"
             @ 044+nMAISOBS,065 MSGET cDTEMIS    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 125,08
      ElseIf cP_MODELO = "8"  // By JPP - 12/06/2006 - 15:30
             //@ 003,002 TO 035+nMAISOBS,337 LABEL STR0133     PIXEL OF oFld:aDialogs[aDLG[4]] //"Observacoes"
             //@ 010,005 MSGET cOBS1 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
             //@ 020,005 MSGET cOBS2 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
//             IF lMV_0040
//                @ 030,005 MSGET cOBS3 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
//                @ 040,005 MSGET cOBS4 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08
//             ENDIF
//             @ 037+nMAISOBS,002 TO 067+nMAISOBS,337 PIXEL OF oFld:aDialogs[aDLG[4]]
//             @ 044+nMAISOBS,005 SAY   STR0134    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 070,08 //"Instrumento de Negociacao"
//             @ 044+nMAISOBS,075 MSGET cINSTNEG   OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 080,08
             //@ 044+nMAISOBS,225 SAY   STR0135    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 040,08 //"Data de Emissao"
             //@ 044+nMAISOBS,270 MSGET dDTEMIS    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 035,08
             //@ 003,002 TO 022+nMAISOBS,337
             @ 003,002 TO 023+nMAISOBs,337 LABEL "País " + STR0124 PIXEL OF oFld:aDialogs[aDLG[4]] //"Importador"
             @ 010,005 MSGET cPAIS_IMP   OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 210,08

             @ 030+nMAISOBS,005 SAY   STR0135    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 060,08 //"Data de Emissao"
             @ 029+nMAISOBS,050 MSGET dDTEMIS    OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 75,08
      ELSEIF cP_MODELO = "9"  // COMUM (FACISC) // LCS.15/11/2006
             @ 003,002 TO 070,337 LABEL STR0133              PIXEL OF oFld:aDialogs[aDLG[4]] //"Observacoes" // LCS.15/11/2006
             @ 010,005 MSGET cOBS1 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08 // LCS.15/11/2006
             @ 020,005 MSGET cOBS2 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08 // LCS.15/11/2006
             @ 030,005 MSGET cOBS3 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08 // LCS.15/11/2006
             @ 040,005 MSGET cOBS4 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08 // LCS.15/11/2006
             @ 050,005 MSGET cOBS5 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 330,08 // LCS.15/11/2006
             * // LCS.15/11/2006
             @ 072,002 TO 92,337 LABEL ""     PIXEL OF oFld:aDialogs[aDLG[4]] // LCS.15/11/2006
             @ 079,005 SAY   STR0136                OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 060,08 //"Data Por Extenso" // LCS.15/11/2006
             @ 079,065 MSGET cDTEMIS                 OF oFld:aDialogs[aDLG[4]] PIXEL SIZE 125,08 // LCS.15/11/2006
      ENDIF
      *
      IF EasyEntryPoint("EECCAD00")  //LCS.09/11/2006
         EXECBLOCK("EECCAD00",.F.,.F.,{"COTELAGETS",cP_MODELO}) //LCS.09/11/2006
      ENDIF //LCS.09/11/2006
      *
      // GERAL
      @ 195+nMAISCHECK,005 CHECKBOX lVISU PROMPT STR0137 SIZE 90,08 OF oPanel PIXEL //"Exibir tela em modo texto"
      *
      EC2801("L")
      Eval(bHideAll)
      IF aDLG[1] = 0
         Eval(bShow,1)
      ENDIF
      oFld:bChange := { |nOption,nOldOption| Eval(bHide,nOldOption),;
                        IF(nOption=aDLG[2].OR.(nOPTION=aDLG[3]),Eval(bShow,nOption),) }

      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   ACTIVATE MSDIALOG oDLG CENTERED ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS)
   IF nOPC = 1
      lRET      := .T.
      aCAB[1,1] := cNOME_EXP ; aCAB[1,2] := cENDE_EXP
      aCAB[1,3] := cCIDA_EXP ; aCAB[1,5] := cEXP4
      aCAB[1,6] := cEXP5     ; aCAB[1,7] := ""
      aCaB[1,4] := cPAIS_EXP // By JPP - 12/06/2006 - 15:30
      aCAB[2,1] := cNOME_IMP ; aCAB[2,2] := cENDE_IMP
      aCAB[2,3] := cCIDA_IMP ; aCAB[2,5] := cIMP4
      aCAB[2,6] := cIMP5     ; aCAB[2,7] := ""
      aCAB[2,4] := cPAIS_IMP // By JPP - 12/06/2006 - 15:30
      aCAB[3,1] := cNOME_CON ; aCAB[3,2] := cPAIS_CON
      aCAB[3,3] := cCONSIG3  ; aCAB[3,4] := cCONSIG4
      aCAB[3,5] := cCONSIG5  ; aCAB[4]   := cPORTO
      aCAB[5]   := cPAISDEST ; aCAB[6]   := cVIA_TRAN
      aCAB[7]   := cNRINVO   ; aCAB[8]   := DTOC(dDTINVO)
      aCAB[9,1] := cMEIOT1   ; aCAB[9,2] := cMEIOT2
      aCAB[9,3] := cMEIOT3   ; aCAB[9,4] := cMEIOT4
      aCAB[9,5] := cMEIOT5   ; aCAB[9,6] := cMEIOT6
      *
      aROD[1,1] := cOBS1         ; aROD[1,2] := cOBS2
      aROD[1,3] := cOBS3         ; aROD[1,4] := cOBS4
      aROD[1,5] := cOBS5         ; aROD[1,6] := cOBS6
      aROD[1,7] := cOBS7         ; aROD[1,8] := cOBS8
      aROD[2]   := cINSTNEG      ; aROD[4]   := cDTEMIS
      aROD[5]   := DTOC(dDTEMIS)

      cEDITA    := IF(lVISU,"M","W")

      /*
      Rotina de conversão de valores númericos p/ string, quando houver definição de mascara p/ colunas da
      pasta Itens.
      Autor: Alexsander Martins dos Santos
      Data e Hora: 09/06/2004 às 12:21.
      */
      If Type("aH_Item_Extend") = "A"
         For nCPos := 1 To Len(aC_Item)
            For nEPos := 1 To Len(aH_Item_Extend)
               nValor := aC_Item[nCPos][aH_Item_Extend[nEPos][1]]
               aC_Item[nCPos][aH_Item_Extend[nEPos][1]] := If(!Empty(nValor), Transform(nValor, aH_Item_Extend[nEPos][2]), "")
            Next
         Next
      EndIf
      //Final da rotina.

      // GUARDA OS DADOS DA ULTIMA IMPRESSAO
      IF lExistEX0
         IF ! EMPTY(cP_CODIGO) .AND. ! EMPTY(cP_DOCTO)
            // CAPA
            EX0->(DBSETORDER(1))
            IF (EX0->(DBSEEK(XFILIAL("EX0")+cP_CODIGO+cP_DOCTO)))
               EX0->(RECLOCK("EX0",.F.))
            ELSE
               EX0->(RECLOCK("EX0",.T.))
            ENDIF
            EX0->EX0_FILIAL := XFILIAL("EX0") ; EX0->EX0_PREEMB := cP_CODIGO
            EX0->EX0_CODDOC := cP_DOCTO       ; EX0->EX0_EXPO1  := cNOME_EXP
            EX0->EX0_EXPO2  := cENDE_EXP      ; EX0->EX0_EXPO3  := cCIDA_EXP
            EX0->EX0_IMPO1  := cNOME_IMP      ; EX0->EX0_IMPO2  := cENDE_IMP
            EX0->EX0_IMPO3  := cCIDA_IMP      ; EX0->EX0_CONS1  := cNOME_CON
            EX0->EX0_CONS2  := cPAIS_CON      ; EX0->EX0_CONS3  := cCONSIG3
            EX0->EX0_ORIGEM := cPORTO         ; EX0->EX0_DEST   := cPAISDEST
            EX0->EX0_VIA    := cVIA_TRAN      ; EX0->EX0_DTINVO := dDTINVO
            EX0->EX0_NRINVO := cNRINVO        ; EX0->EX0_OBS1   := cOBS1
            EX0->EX0_OBS2   := cOBS2          ; EX0->EX0_OBS3   := cOBS3
            EX0->EX0_OBS4   := cOBS4          ; EX0->EX0_OBS5   := cOBS5
            EX0->EX0_OBS6   := cOBS6          ; EX0->EX0_OBS7   := cOBS7
            EX0->EX0_OBS8   := cOBS8          ; EX0->EX0_INSNEG := cINSTNEG
            EX0->EX0_DTEMIS := dDTEMIS        ; EX0->EX0_DTEMEX := cDTEMIS
            EX0->EX0_MEIOT1 := cMEIOT1        ; EX0->EX0_MEIOT2 := cMEIOT2
            EX0->EX0_MEIOT3 := cMEIOT3        ; EX0->EX0_MEIOT4 := cMEIOT4
            EX0->EX0_MEIOT5 := cMEIOT5        ; EX0->EX0_MEIOT6 := cMEIOT6
            IF lMAISLI
               EX0->EX0_EXPO4 := cEXP4 ; EX0->EX0_EXPO5 := cEXP5
               EX0->EX0_IMPO4 := cIMP4
               EX0->EX0_IMPO5 := cIMP5
            ENDIF

            If cP_MODELO = "7"  .or. cP_MODELO = "8" .Or. cP_MODELO == "B2"// By JPP - 12/06/2006 - 15:30
               EX0->EX0_EXPO4 := cPAIS_EXP
               EX0->EX0_IMPO4 := cPAIS_IMP
            EndIf

            IF lCONSIG4_5
               EX0->EX0_CONS4 := cCONSIG4 ; EX0->EX0_CONS5 := cCONSIG5
            ENDIF
            IF EasyEntryPoint("EECCAD00")// LCS.16/11/2006
               EXECBLOCK("EECCAD00",.F.,.F.,{"GRAVAEX0",cP_MODELO})// LCS.16/11/2006
            ENDIF// LCS.16/11/2006
            // ITENS
            nA := nB := 1
            EX1->(DBSETORDER(1))
            EX1->(DBSEEK(XFILIAL("EX1")+cP_CODIGO+cP_DOCTO))
            DO WHILE ! EX1->(EOF()) .AND.;
               EX1->(EX1_FILIAL+EX1_PREEMB+EX1_CODDOC) = (XFILIAL("EX1")+cP_CODIGO+cP_DOCTO) .AND.;
               nA <= LEN(aC_ITEM)
               *
               IF ! aC_ITEM[nA,LEN(aC_ITEM[nA])]
                  APPENDEX1(.F.,cP_CODIGO,cP_DOCTO,aC_ITEM[nA],cP_MODELO,aP_LENCOL)
               ELSE
                  EX1->(RECLOCK("EX1",.F.))
                  EX1->(DBDELETE())
                  EX1->(MSUNLOCK())
               ENDIF
               nA := nA+1
               EX1->(DBSKIP())
            ENDDO
            IF nA > LEN(aC_ITEM)
               DO WHILE ! EX1->(EOF()) .AND.;
                  EX1->(EX1_FILIAL+EX1_PREEMB+EX1_CODDOC) = (XFILIAL("EX1")+cP_CODIGO+cP_DOCTO)
                  *
                  EX1->(RECLOCK("EX1",.F.))
                  EX1->(DBDELETE())
                  EX1->(MSUNLOCK())
                  EX1->(DBSKIP())
               ENDDO
            ELSE
               FOR nB := nA TO LEN(aC_ITEM)
                  IF ! aC_ITEM[nB,LEN(aC_ITEM[nB])]
                     APPENDEX1(.T.,cP_CODIGO,cP_DOCTO,aC_ITEM[nB],cP_MODELO,aP_LENCOL)
                  ENDIF
               NEXT
            ENDIF
            // NORMAS
            nA := nB := 1
            EX2->(DBSETORDER(1))
            EX2->(DBSEEK(XFILIAL("EX2")+cP_CODIGO+cP_DOCTO))
            DO WHILE ! EX2->(EOF()) .AND.;
               EX2->(EX2_FILIAL+EX2_PREEMB+EX2_CODDOC) = (XFILIAL("EX2")+cP_CODIGO+cP_DOCTO) .AND.;
               nA <= LEN(aC_NORMA)
               *
               IF ! aC_NORMA[nA,LEN(aC_NORMA[nA])]
                  APPENDEX2(.F.,cP_CODIGO,cP_DOCTO,aC_NORMA[nA],cP_MODELO)
               ELSE
                  EX2->(RECLOCK("EX2",.F.))
                  EX2->(DBDELETE())
                  EX2->(MSUNLOCK())
               ENDIF
               nA := nA+1
               EX2->(DBSKIP())
            ENDDO
            IF nA > LEN(aC_NORMA)
               DO WHILE ! EX2->(EOF()) .AND.;
                  EX2->(EX2_FILIAL+EX2_PREEMB+EX2_CODDOC) = (XFILIAL("EX2")+cP_CODIGO+cP_DOCTO)
                  *
                  EX2->(RECLOCK("EX2",.F.))
                  EX2->(DBDELETE())
                  EX2->(MSUNLOCK())
                  EX2->(DBSKIP())
               ENDDO
            ELSE
               FOR nB := nA TO LEN(aC_NORMA)
                  IF ! aC_NORMA[nB,LEN(aC_NORMA[nB])]
                     APPENDEX2(.T.,cP_CODIGO,cP_DOCTO,aC_NORMA[nB],cP_MODELO)
                  ENDIF
               NEXT
            ENDIF
         ENDIF
      Endif
   ENDIF
END SEQUENCE
Return(lRet)
*--------------------------------------------------------------------
FUNCTION COIMP(mP_CAB,mP_ROD,cP_MARGEM,nP_SPA1,mP_COMPL,cP_PONTOE,lFIESP)
/*
1.mP_CAB    -> CONTEM O CABECARIO DO DOCUMENTO
2.mP_ROD    -> CONTEM O RODAPE DO DOCUMENTO
3.cP_MARGEM -> MARGEM DE IMPRESSAO DO DOCUMENTO
4.nP_SPA1   -> QUANTIDADE DE LINHAS QUE TEM DE ESPACO ENTRE O DETALHE E AS NORMAS
5.mP_COMPL  -> INFORMACOES COMPLEMENTARES
6.cP_PONTOE -> PONTO DE ENTRADA / ALTERACAO DO CABECARIO DE IMPRESSAO

Modificações: HFD - 20.fev.2009 - Tratamento de cP_PONTOE para evitar NIL
*/
LOCAL Z,X,Y,I,aRETPE,;
      mDET    := "",;
      lRET    := .F.,;
      nDELEIT := LEN(aH_ITEM)+1,;
      nDELENO := LEN(aH_NORMA)+1,;
      cEspaco := Space(01)

Default cP_PONTOE := "" //ASK 11/03/2008
Default lFIESP := .F.  // GFP - 03/12/2012

cP_MARGEM := IF(cP_MARGEM=NIL," ",cP_MARGEM)
nP_SPA1   := IF(nP_SPA1  =NIL,0  ,nP_SPA1)
mP_COMPL  := IF(mP_COMPL =NIL,"" ,mP_COMPL)
Z         := Y := 1
X         := 0
aRETPE    := {"",""}
//AJP 10/02/2006 - Ponto de entrada para modificação dos itens do certificado de origem
If EasyEntryPoint("EECCAD00")
   ExecBlock("EECCAD00",.F.,.F.,{"PE_ANTESCOIMP",cP_PONTOE})
End If
DO WHILE Z <= LEN(aC_ITEM)
   IF aC_ITEM[Z,nDELEIT]
      Z := Z+1
      LOOP
   ELSEIF X > 0 .AND. !Empty(cP_PONTOE) .And. ValType(cP_PONTOE)=="C" .AND. EasyEntryPoint(cP_PONTOE) //HFD - 20.fev.2009
          aRETPE   := EXECBLOCK(cP_PONTOE,.F.,.F.,Z)
          If ValType(aRETPE) == "A"
             mP_CAB   := aRETPE[1]
             mP_COMPL := aRETPE[2]
          EndIf
   ENDIF
   mDET := mDET+mP_CAB
   // ITENS
   X := aC_ITEM[Z,1]  // PAGINA
   DO WHILE Z <= LEN(aC_ITEM) .AND. X = aC_ITEM[Z,1]
      IF ! aC_ITEM[Z,nDELEIT]
         mDET := mDET+cP_MARGEM
         //AMS - 06/01/2004 às 14:30. Alterado p/ não dar espaço quando for Observação.
         //A observação é identificada pelo CHR(244) que é gravado no ac_Item.
         If ValType(aC_ITEM[Z,4]) = "C"
            If Chr(244) $ aC_ITEM[Z,4]
               aC_ITEM[Z,4] := StrTran( aC_ITEM[Z,4], Chr(244), "" )
               cEspaco := ""
            EndIf
         EndIf
         FOR I := 3 TO (nDELEIT-1)
            mDET := mDET+aC_ITEM[Z,I]+cEspaco //Space(01)
         NEXT
         mDET := mDET+ENTER
      ENDIF
      Z := Z+1
   ENDDO
   If !lFIESP    // GFP - 03/12/2012
      mDET := mDET+REPLICATE(ENTER,nP_SPA1)
   Else
      mDET := mDET+ENTER
   EndIf
   mDET := mDET+mP_COMPL
   // NORMAS
   DO WHILE Y <= LEN(aC_NORMA) .AND. X = aC_NORMA[Y,1]  // PAGINA
      IF ! aC_NORMA[Y,nDELENO]
         mDET := mDET+cP_MARGEM
         FOR I := 3 TO nDELENO-1
             mDET := mDET+aC_NORMA[Y,I]+SPACE(01)
         NEXT
         mDET := mDET+ENTER
      ENDIF
      Y := Y+1
   ENDDO
   mDET := mDET+ENTER
   // RODAPE
   mDET := mDET+mP_ROD+AVEJECT()
ENDDO
IF E_AVGLTT("G")
   //adicionar registro no AVGLTT
   AVGLTT->(DBAPPEND())
   //gravar dados a serem editados
   AVGLTT->AVG_CHAVE  := EEC->EEC_PREEMB //nr. do processo
   // LCS - 31/10/2002 - 13:27
   //AVGLTT->WK_DETALHE := mDet // Detalhes ...
   cSeqRel := GetSXENum("SY0","Y0_SEQREL")
   CONFIRMSX8()
   //executar rotina de manutencao de caixa de texto
   lRet := E_AVGLTT(cEDITA,WORKID->EEA_TITULO,,mDET)
   //lRet := E_AVGLTT(cEDITA,WORKID->EEA_TITULO)
ENDIF
RETURN(lRET)
*--------------------------------------------------------------------
STATIC FUNCTION APPENDEX1(lP_APPEND,cP_CODIGO,cP_DOCTO,aP_ITEM,cP_MODELO,aP_LENCOL)
LOCAL Z
PRIVATE lRETPONTO  // LCS.15/11/2006
*
lRETPONTO := .T.// LCS.15/11/2006
EX1->(RECLOCK("EX1",lP_APPEND))
IF lP_APPEND
   EX1->EX1_FILIAL := XFILIAL("EX1")
   EX1->EX1_PREEMB := cP_CODIGO
   EX1->EX1_CODDOC := cP_DOCTO
ENDIF
EX1->EX1_PAGINA := STR(aP_ITEM[1],LEN(EX1->EX1_PAGINA),0)
EX1->EX1_LINHA  := STR(aP_ITEM[2],LEN(EX1->EX1_LINHA),0)
IF aP_LENCOL = NIL
   // FAZ A GRAVACAO DO HISTORICO PARA CERTIFICADOS FORA DO PADRAO.
   // SE RETORNAR .T., FAZ A GRAVACAO PADRAO, SE .F. NAO FAZ A GRAVACAO PADRAO
   IF EasyEntryPoint("EECCAD00")// LCS.15/11/2006
      lRETPONTO := EXECBLOCK("EECCAD00",.F.,.F.,{"APPENDEX1",cP_MODELO,aP_ITEM})// LCS.15/11/2006
   ENDIF// LCS.15/11/2006
   IF lRETPONTO // LCS.15/11/2006
      IF cP_MODELO = "1" .OR.; // BOLIVIA / CHILE / MERCOSUL-FIESP
         cP_MODELO = "6" .OR.; // MERCOSUL-ACS
         cP_MODELO = "A" .Or.; // MERCOSUL COL,EQU,VEN (FACISC) // LCS.16/11/2006
         cP_MODELO == "B" .Or.; // Fiep
         cP_MODELO == "B3"      // Fiep Comun. Andina
         *
         EX1->EX1_ORDEM  := aP_ITEM[3]
         EX1->EX1_COD    := aP_ITEM[4]
         EX1->EX1_DESC   := aP_ITEM[5]
         EX1->EX1_PESO   := aP_ITEM[6]
         EX1->EX1_VALFOB := aP_ITEM[7]
      ELSEIF cP_MODELO = "2" .Or. cP_MODELO == "B2" // ALADI; Fiep Aladi e México
             EX1->EX1_ORDEM := aP_ITEM[3]
             EX1->EX1_COD   := aP_ITEM[4]
             EX1->EX1_DESC  := aP_ITEM[5]
      ELSEIF cP_MODELO = "3" .Or. cP_MODELO = "5"  // COMUM
             EX1->EX1_COD    := aP_ITEM[3]
             EX1->EX1_PESO   := aP_ITEM[4]
             EX1->EX1_DESC   := aP_ITEM[5]
             EX1->EX1_VALFOB := aP_ITEM[6]
      ELSEIF cP_MODELO = "4"  // ARABE
             EX1->EX1_DESC := aP_ITEM[3]
             /*
             Nopado por ER - 03/01/2007

             EX1->EX1_ORDEM  := LEFT(aP_ITEM[3],3)   // 3 PRIMEIRAS POSICOES DA MARCACAO
             EX1->EX1_COD    := SUBSTR(aP_ITEM[3],4) // 4 POSICAO EM DIANTE DA MARCACAO
             EX1->EX1_VALFOB := aP_ITEM[4]  // PACKAGE
             EX1->EX1_DESC   := aP_ITEM[5]  // DESCRICAO
             EX1->EX1_PESO   := aP_ITEM[6]  // WEIGHT
             */
      ELSEIF cP_MODELO = "7"  // COMUM FIEP // By JPP - 14/06/2006 - 11:30
             EX1->EX1_DESC   := aP_ITEM[3]  // DESCRICAO
      ELSEIF cP_MODELO = "8"  // GSTP FIEP  // By JPP - 20/06/2006 - 08:10
             EX1->EX1_ORDEM  := aP_ITEM[3]  // ORDEM
             EX1->EX1_DESC   := Padr(aP_ITEM[4],aH_ITEM[4,4]," ")+aP_ITEM[5] // PACKAGES + DESCRICAO
             EX1->EX1_COD    := aP_ITEM[6] // ORIGIN CRITERION
             EX1->EX1_PESO   := aP_ITEM[7] // WEIGHT
             EX1->EX1_VALFOB := aP_ITEM[8] // INVOICES/DATE
      ELSEIF cP_MODELO == "9"  // COMUM (FACISC)  // LCS.15/11/2006
             EX1->EX1_COD    := aP_ITEM[3]  // LCS.15/11/2006
             EX1->EX1_DESC   := aP_ITEM[4] // LCS.15/11/2006
      ENDIF
   ENDIF// LCS.15/11/2006
ELSE
   FOR Z := 1 TO LEN(aP_LENCOL)
       EX1->(FIELDPUT(FIELDPOS(aP_LENCOL[Z,5]),aP_ITEM[2+Z]))
   NEXT
ENDIF
EX1->(MSUNLOCK())
RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION APPENDEX2(lP_APPEND,cP_CODIGO,cP_DOCTO,aP_NORMA,cP_MODELO)
EX2->(RECLOCK("EX2",lP_APPEND))
IF lP_APPEND
   EX2->EX2_FILIAL := XFILIAL("EX2")
   EX2->EX2_PREEMB := cP_CODIGO
   EX2->EX2_CODDOC := cP_DOCTO
ENDIF
EX2->EX2_PAGINA := STR(aP_NORMA[1],LEN(EX2->EX2_PAGINA),0)
EX2->EX2_LINHA  := STR(aP_NORMA[2],LEN(EX2->EX2_LINHA) ,0)
EX2->EX2_ORDEM  := aP_NORMA[3]
EX2->EX2_DESC   := aP_NORMA[4]
EX2->(MSUNLOCK())
RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION LE_EX012(cP_CODIGO,cP_DOCTO,aP_LENCOL,aP_LENCON,lP_MAISLI,cP_MODELO,lP_CONS4_5)
LOCAL nLENITEM,nLENNORMA,Z,X,nOBS,nINS
*
BEGIN SEQUENCE
   EX0->(DBSETORDER(1))
   IF ! (EX0->(DBSEEK(XFILIAL("EX0")+cP_CODIGO+cP_DOCTO)))
      MSGINFO(STR0145,STR0026)  ///"Documento não tem impressão anterior registrada !"###"Aviso"
      BREAK
   ENDIF
   // CAPA
   nOBS := LEN(aROD[1,1])
   nINS := AVSX3("EEE_DCRED",AV_TAMANHO)
   EX0->(RECLOCK("EX0",.F.))
   cNOME_EXP := LEFT(EX0->EX0_EXPO1,50)    ; cENDE_EXP := LEFT(EX0->EX0_EXPO2,50)
   cCIDA_EXP := LEFT(EX0->EX0_EXPO3,50)    ; cNOME_IMP := LEFT(EX0->EX0_IMPO1,50)
   cENDE_IMP := LEFT(EX0->EX0_IMPO2,50)    ; cCIDA_IMP := LEFT(EX0->EX0_IMPO3,50)
   cNOME_CON := LEFT(EX0->EX0_CONS1,50)    ; cPAIS_CON := LEFT(EX0->EX0_CONS2,50)
   cCONSIG3  := LEFT(EX0->EX0_CONS3,50)    ; cPORTO    := LEFT(EX0->EX0_ORIGEM,50)
   cPAISDEST := LEFT(EX0->EX0_DEST,50)     ; cVIA_TRAN := LEFT(EX0->EX0_VIA,50)
   dDTINVO   := EX0->EX0_DTINVO            ; cNRINVO   := LEFT(EX0->EX0_NRINVO,20)
   cOBS1     := LEFT(EX0->EX0_OBS1,nOBS)   ; cOBS2     := LEFT(EX0->EX0_OBS2,nOBS)
   cOBS3     := LEFT(EX0->EX0_OBS3,nOBS)   ; cOBS4     := LEFT(EX0->EX0_OBS4,nOBS)
   cOBS5     := LEFT(EX0->EX0_OBS5,nOBS)   ; cOBS6     := LEFT(EX0->EX0_OBS6,nOBS)
   cOBS7     := LEFT(EX0->EX0_OBS7,nOBS)   ; cOBS8     := LEFT(EX0->EX0_OBS8,nOBS)
   cINSTNEG  := LEFT(EX0->EX0_INSNEG,nINS) ; dDTEMIS   := EX0->EX0_DTEMIS
   cDTEMIS   := LEFT(EX0->EX0_DTEMEX,50)   ; cMEIOT1   := LEFT(EX0->EX0_MEIOT1,50)
   cMEIOT2   := LEFT(EX0->EX0_MEIOT2,50)   ; cMEIOT3   := LEFT(EX0->EX0_MEIOT3,50)
   cMEIOT4   := LEFT(EX0->EX0_MEIOT4,50)   ; cMEIOT5   := LEFT(EX0->EX0_MEIOT5,50)
   cMEIOT6   := LEFT(EX0->EX0_MEIOT6,50)
   IF lP_MAISLI
      cEXP4 := LEFT(EX0->EX0_EXPO4,50) ; cEXP5 := LEFT(EX0->EX0_EXPO5,50)
      cIMP4 := LEFT(EX0->EX0_IMPO4,50) ; cIMP5 := LEFT(EX0->EX0_IMPO5,50)
   ENDIF
   IF lP_CONS4_5
      cCONSIG4 := LEFT(EX0->EX0_CONS4,50) ; cCONSIG5 := LEFT(EX0->EX0_CONS5,50)
   ENDIF
   If cP_MODELO = "7" .Or. cP_MODELO = "8" .Or. cP_MODELO == "B2"// By JPP - 14/06/2006 - 11:30
      cPAIS_EXP := LEFT(EX0->EX0_EXPO4,50)
      cPAIS_IMP := LEFT(EX0->EX0_IMPO4,50)
   EndIf
   //AMS - 06/01/2004 às 11:19. Recupera o conteudo do campo OBS.
   If EX0->(FieldPos("EX0_CODOBS")) <> 0
      //cObs := EX0->EX0_OBS
      cObs := MSMM(EX0->EX0_CODOBS, AVSX3("EX0_OBS", AV_TAMANHO),,, 3)
   EndIf
   IF EasyEntryPoint("EECCAD00")// LCS.16/11/2006
      EXECBLOCK("EECCAD00",.F.,.F.,{"LEEX0",cP_MODELO})// LCS.16/11/2006
   ENDIF// LCS.16/11/2006
   // ITENS
   nLENITEM := LEN(aC_ITEM[1])
   aC_ITEM  := {}
   EX1->(DBSETORDER(1))
   EX1->(DBSEEK(XFILIAL("EX1")+cP_CODIGO+cP_DOCTO))
   DO WHILE ! EX1->(EOF()) .AND.;
      EX1->(EX1_FILIAL+EX1_PREEMB+EX1_CODDOC) = (XFILIAL("EX1")+cP_CODIGO+cP_DOCTO)
      *
      AADD(aC_ITEM,ARRAY(nLENITEM))
      aC_ITEM[LEN(aC_ITEM),nLENITEM] := .f. // Deleted
      aC_ITEM[LEN(aC_ITEM),1]        := VAL(EX1->EX1_PAGINA)
      aC_ITEM[LEN(aC_ITEM),2]        := VAL(EX1->EX1_LINHA)
      X := 1
      IF aP_LENCOL = NIL
         IF cP_MODELO = "1" .OR.; // MERCOSUL-FIESP / BOLIVIA / CHILE
            cP_MODELO = "6" .OR.; // MERCOSUL-ACS
            cP_MODELO = "A" .Or.; // MERCOSUL COL,EQU,VEN (FACISC) // LCS.16/11/2006
            cP_MODELO == "B" .Or.; // Fiep
            cP_MODELO == "B3"      // Fiep Comun. Andina
            *
            aC_ITEM[LEN(aC_ITEM),3] := LEFT(EX1->EX1_ORDEM ,aH_ITEM[3,4])
            aC_ITEM[LEN(aC_ITEM),4] := LEFT(EX1->EX1_COD   ,aH_ITEM[4,4])
            aC_ITEM[LEN(aC_ITEM),5] := LEFT(EX1->EX1_DESC  ,aH_ITEM[5,4])
            aC_ITEM[LEN(aC_ITEM),6] := LEFT(EX1->EX1_PESO  ,aH_ITEM[6,4])
            aC_ITEM[LEN(aC_ITEM),7] := LEFT(EX1->EX1_VALFOB,aH_ITEM[7,4])
         ELSEIF cP_MODELO = "2" .Or. cP_MODELO == "B2" //ALADI - Fiep Aladi e México
                aC_ITEM[LEN(aC_ITEM),3] := LEFT(EX1->EX1_ORDEM,aH_ITEM[3,4])
                aC_ITEM[LEN(aC_ITEM),4] := LEFT(EX1->EX1_COD  ,aH_ITEM[4,4])
                aC_ITEM[LEN(aC_ITEM),5] := LEFT(EX1->EX1_DESC ,aH_ITEM[5,4])
         ELSEIF cP_MODELO = "3" .Or. cP_MODELO = "5" // COMUM
                aC_ITEM[LEN(aC_ITEM),3] := LEFT(EX1->EX1_COD   ,aH_ITEM[3,4])
                aC_ITEM[LEN(aC_ITEM),4] := LEFT(EX1->EX1_PESO  ,aH_ITEM[4,4])
                aC_ITEM[LEN(aC_ITEM),5] := LEFT(EX1->EX1_DESC  ,aH_ITEM[5,4])
                aC_ITEM[LEN(aC_ITEM),6] := LEFT(EX1->EX1_VALFOB,aH_ITEM[6,4])
         ELSEIF cP_MODELO = "4" // ARABE
                aC_ITEM[LEN(aC_ITEM),3] := LEFT(EX1->EX1_DESC,aH_ITEM[3,4])
                /*
                Nopado por ER - 03/01/2007

                aC_ITEM[LEN(aC_ITEM),3] := LEFT(EX1->(LEFT(EX1_ORDEM,3)+EX1_COD),aH_ITEM[3,4])
                aC_ITEM[LEN(aC_ITEM),4] := LEFT(EX1->EX1_VALFOB         ,aH_ITEM[4,4])
                aC_ITEM[LEN(aC_ITEM),5] := LEFT(EX1->EX1_DESC           ,aH_ITEM[5,4])
                aC_ITEM[LEN(aC_ITEM),6] := LEFT(EX1->EX1_PESO           ,aH_ITEM[6,4])
                */
         ELSEIF cP_MODELO = "7" // By JPP - 14/06/2006 - 11:30
                aC_ITEM[LEN(aC_ITEM),3] := Left(EX1->EX1_DESC           ,aH_ITEM[3,4])
         ELSEIF cP_MODELO = "8"  // By JPP - 20/06/2006 - 08:10
                aC_ITEM[LEN(aC_ITEM),3] := LEFT(EX1->EX1_ORDEM          ,aH_ITEM[3,4])
                aC_ITEM[LEN(aC_ITEM),4] := Left(EX1->EX1_DESC           ,aH_ITEM[4,4]) // Package
                aC_ITEM[LEN(aC_ITEM),5] := Substr(EX1->EX1_DESC         ,aH_ITEM[4,4]+1,aH_ITEM[5,4]) // Descrição
                aC_ITEM[LEN(aC_ITEM),6] := LEFT(EX1->EX1_COD           ,aH_ITEM[6,4]) // Origin Criterion
                aC_ITEM[LEN(aC_ITEM),7] := LEFT(EX1->EX1_PESO          ,aH_ITEM[7,4]) // Weight
                aC_ITEM[LEN(aC_ITEM),8] := LEFT(EX1->EX1_VALFOB        ,aH_ITEM[8,4]) // Invoices/Date
         ELSEIF cP_MODELO == "9"  // COMUM (FACISC)  // LCS.15/11/2006
                aC_ITEM[LEN(aC_ITEM),3] := LEFT(EX1->EX1_COD ,aH_ITEM[3,4]) // LCS.15/11/2006
                aC_ITEM[LEN(aC_ITEM),4] := LEFT(EX1->EX1_DESC,aH_ITEM[4,4]) // LCS.15/11/2006
         ENDIF
      ELSE
         FOR Z := 1 TO LEN(aP_LENCOL)
             aC_ITEM[LEN(aC_ITEM),Z+2] := PADR(EX1->(FIELDGET(FIELDPOS(aP_LENCOL[Z,5]))),aP_LENCOL[Z,2]," ")
         NEXT
      ENDIF
      EX1->(DBSKIP())
   ENDDO
   // NORMAS
   IF LEN(aC_NORMA) > 0
      nLENNORMA := LEN(aC_NORMA[1])
      aC_NORMA  := {}
      EX2->(DBSETORDER(1))
      EX2->(DBSEEK(XFILIAL("EX2")+cP_CODIGO+cP_DOCTO))
      DO WHILE ! EX2->(EOF()) .AND.;
         EX2->(EX2_FILIAL+EX2_PREEMB+EX2_CODDOC) = (XFILIAL("EX2")+cP_CODIGO+cP_DOCTO)
         *
         AADD(aC_NORMA,ARRAY(nLENNORMA))
         aC_NORMA[LEN(aC_NORMA),nLENNORMA] := .f. // Deleted
         aC_NORMA[LEN(aC_NORMA),1]         := VAL(EX2->EX2_PAGINA)
         aC_NORMA[LEN(aC_NORMA),2]         := VAL(EX2->EX2_LINHA)
         IF aP_LENCON = NIL
            IF cP_MODELO = "2" .OR.; // ALADI
               cP_MODELO = "1" .OR.; // MERCOSUL-FIESP/BOLIVIA / CHILE
               cP_MODELO = "6" .OR.; // MERCOSUL-ACS
               cP_MODELO = "A" .Or.; // MERCOSUL COL,EQU,VEN (FACISC) // LCS.16/11/2006
               cP_MODELO == "B".Or.; // Fiep
               cP_MODELO == "B2".Or.;// Fiep
               cP_MODELO == "B3"     // Fiep
               *
               aC_NORMA[LEN(aC_NORMA),3] := LEFT(EX2->EX2_ORDEM,aH_NORMA[3,4])
               aC_NORMA[LEN(aC_NORMA),4] := LEFT(EX2->EX2_DESC ,aH_NORMA[4,4])
            ENDIF
         ELSE
            FOR Z := 1 TO LEN(aP_LENCON)
                aC_NORMA[LEN(aC_NORMA),Z+2] := PADR(EX2->(FIELDGET(FIELDPOS(aP_LENCON[Z,5]))),aP_LENCON[Z,2]," ")
            NEXT
         ENDIF
         EX2->(DBSKIP())
      ENDDO
   ENDIF
   IF lITNO = "I"
      aCOLS := aC_ITEM
      oGETIT:oBrowse:REFRESH()
      N    := 1
   ELSEIF lITNO = "N"
          aCOLS := aC_NORMA
          oGETNO:oBrowse:REFRESH()
   ENDIF
END SEQUENCE
RETURN(NIL)
*--------------------------------------------------------------------
/*
Funcao    : ValidFaseDoc(cFase)
Parametros: cFase => Fase para impressão do documento. (1=Todos, 2=Pedido, 3=Embarque, 4=Financas)
Retorno   : .t./.f.
Objetivos : Validar a fase de impressão do documento.
Autor     : Jeferson Barros Jr.
Data/Hora : 11/06/02 09:02
Revisao   :
Obs.      :
*/
*---------------------------*
Function ValidFaseDoc(cFase)
*---------------------------*
Local lRet:=.t.

Begin Sequence

   If Empty(cFase)
      lRet:=.f.
      Break
   EndIf

   If cFase ==VD_TOD
      Break
   EndIf

   If Select("WorkId") > 0
      If WorkId->EEA_FASE # cFase
         MsgStop(STR0138+ENTER+; //"Problema:"
                 STR0139+Replic(ENTER,2)+; //"Fase inválida para a impressão deste documento."
                 STR0140+ENTER+; //"Solução:"
                 STR0141,STR0142) //"Altere a fase de impressão no cadastro de documentos/relatórios."###"Erro"
         lRet:=.f.
      EndIf
   Else
      MsgStop(STR0143,STR0142) //"Erro de integridade na geração de documentos."###"Erro"
      lRet:=.f.
   EndIf

End Sequence

Return lRet

/*
Funcao    : EECAT150()
Parametros: Nenhum
Objetivos : Manutencao de cotacao da bolsa
Autor     : Jeferson Barros Jr.
Data/Hora : 15/07/02 - 15:14
Alteração : Eduardo C. Romanini
Data/Hora : 07/01/06 - 14:35
Obs.      :
Revisão   : Clayton Fernandes - 29/03/2011
Obs       : Adaptação do Codigo para o padrão MVC
*/
*------------------*
Function EECAT150()
*------------------*
Local lRet:=.T.,cOldArea := Select()

/* ISS - 27-03-10 - Não é mais necessário checar os campos, na 11 eles sempre existirão no dicionário.
If EECFlags("BOLSAS") */

If !EasyCallMVC("MVC_EEC150AT",1) // CRF 16/03/2011
   Private aRotina := MenuDef(ProcName())
   Private cCadastro := STR0146 //"Cotação da Bolsa"
   Private cDelFunc := ".T.", cAlias:="EX7"
   SX7->(DbSetOrder(1))
   mBrowse( 6, 1,22,75,"EX7")
EndIf





/*
Else

   Begin sequence
      AxCadastro("EX7",STR0146) //"Cotação da Bolsa"
   End Sequence
EndIf
*/

DbSelectArea(cOldArea)

Return lRet

/*
Funcao    : AT150MesAno(cMesAno)
Parametros: cMesAno => Mes/Ano para validação.
Objetivos : Validação do mes e ano da cotação da bolsa.
Autor     : Jeferson Barros Jr.
Data/Hora : 04/09/02 - 17:47
Revisao   :
Obs.      :
*/
*---------------------------------------------*
Function AT150MesAno(cMesAno,cBolsa,nMesPeriod)
*---------------------------------------------*
Local lRet:=.T.,cOldArea:=select(), nMes:=0, nAno:=0, i

//Estrutura do array aBolsas: {"Código da Bolsa", {Mês do periodo em formato numérico,"Id. do Mês"}}
Local aBolsas := { {AvKey("NY","EX7_CODBOL"),{ {{09,10,11},"U"}, {{12,01,02},"Z"}, {{03,04},"H"}, {{05,06},"K"}, {{07,08},"N"} } },;
                   {AvKey("BMF","EX7_CODBOL"),{ {{09,10,11},"U"}, {{12,01,02},"Z"}, {{03,04},"H"}, {{05,06},"K"}, {{07,08},"N"} } },;
                   {AvKey("LON","EX7_CODBOL"),{ {{07,08},"N"}, {{09,10},"U"}, {{11,12},"X"}, {{01,02},"F"}, {{03,04},"H"}, {{05,06},"K"} } }}

Begin sequence
   If Empty(cMesAno)
      Break
   EndIf

   nMes:= Val(SubStr(cMesAno,1,2))

   If Empty(SubStr(cMesAno,3,2))
      MsgStop(STR0148,STR0026) //"Informe o ano da cotação da bolsa ! "###"Aviso"
      lRet:=.f.
      Break
   Else
      nAno:= Val(SubStr(cMesAno,3,2))
   EndIf

   If nMes < 1 .Or. nMes > 12
      MsgStop(STR0149,STR0026) //"Mês da cotação da bolsa inválido ! "###"Aviso"
      lRet:=.f.
      Break
   EndIf

   If nAno < 0
      MsgStop(STR0150,STR0026) //"Ano da cotação da bolsa inválido ! "###"Aviso"
      lRet:=.f.
   EndIf

   If ValType(cBolsa) == "C" .And. !Empty(cBolsa)
      If  (x := ASCAN( aBolsas, {|x| x[1] == cBolsa } )) == 0
         MsgInfo(STR0184,STR0026) //"Bolsa não cadastrada."
         lRet := .F.
         Break
      EndIf
      aPeriodo := aBolsas[x][2]
      y:=0
      For i := 1 to Len(aPeriodo)
         y := aSCAN(aPeriodo[i][1],nMes)
         If y > 0
            Exit
         EndIf
      Next
      If aPeriodo[i][1][y] <> nMes
         MsgInfo(STR0185,STR0026) //"Mês inválido para a Bolsa escolhida."
         lRet := .F.
         Break
      EndIf

      /* RMD - 07/02/05
      If ValType(nMesPeriod) == "N"
         If ASCAN(aPeriodo[i][1], nMesPeriod) == 0
            MsgInfo("Data inválida para o periodo escolhido.",STR0026) //"Data inválida para o periodo escolhido."
            lRet := .F.
            Break
         EndIf
      EndIf
      */

   EndIf

End Sequence

DbSelectArea(cOldArea)

Return lRet

*--------------------------------------------------------------------
STATIC FUNCTION COTELASHOW(nTELA,o,aDLG)
LOCAL lOBJ
*
lOBJ := .F.
IF nTELA = aDLG[2] .AND. TYPE("oGETIT") = "O"
   EC2801("I")
   o    := oGETIT:oBROWSE
   lOBJ := .T.
ELSEIF nTELA = aDLG[3] .AND. TYPE("oGETNO") = "O"
       EC2801("N")
       o    := oGETNO:oBROWSE
       lOBJ := .T.
ELSE
   EC2801("L")
ENDIF
IF lOBJ
   o:SHOW()
   o:SETFOCUS()
   o:REFRESH()
ENDIF
RETURN(NIL)
*--------------------------------------------------------------------
STATIC FUNCTION COTELAHIDE(nTELA,aDLG)
IF nTELA = aDLG[2] .AND. TYPE("oGETIT") = "O"
   oGETIT:oBrowse:Hide()
ELSEIF nTELA = aDLG[3] .AND. TYPE("oGETNO") = "O"
       oGETNO:oBrowse:Hide()
ENDIF
RETURN(NIL)
*--------------------------------------------------------------------

/*
Funcao    : SetImpressao(cSet)
Parametros: cSet - Define qual tela para set das informações a serem impressas deverá ser exibida.
Objetivos : Apresentar tela.
Retorno   : .t./.f.
Autor     : Jeferson Barros Jr.
Data/Hora : 18/03/03 - 13:38.
Revisao   :
Obs.      :
*/
*--------------------------------*
Static Function SetImpressao(cSet)
*--------------------------------*
Local lRet := .f., nOpca := 0
Local bOk , bCancel := {|| oDlg:End()}
Local aRadio, nRadio := 1, oRadio
Local nLin, nCol, nLinLab, nColLab
Local oPanel
Begin Sequence

   //WFS 16/10/09
   //DFS - 04/12/12 - Ajustes no tamanho da tela.
   If SetMdiChild()
      nLin:= 25
      nCol:= 61
      nLinLab:= 5.5
      nColLab:= 25
   Else
      nLin:= 25.5
      nCol:= 61
      nLinLab:= 5.5
      nColLab:= 25.5
   EndIf

   cSet := Upper(AllTrim(cSet))

   Do Case
      Case cSet == T_PESOS // Tela para definição de impressão dos pesos.

         aRadio:={STR0153,STR0154} //"Peso Liquido"###"Quantidade"
         bOk := {|| nOpcA := 1, lRet:=.t., oDlg:End()}

         Define MsDialog oDlg Title STR0155 From 08,10 TO nLin, nCol OF oMainWnd //"Definições para Impressão"
            oPanel:= TPanel():New(0, 0, "",oDlg,, .F., .F.,,, 40.5, 7.5)
            
            @ 1, 0.5 TO nLinLab, nColLab Label STR0156 Of oPanel //"Dado a ser impresso no campo 11"
            @ 28,36 Radio oRadio Var nRadio Size 45,11 Items aRadio[1],aRadio[2] Of oPanel
         
            oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

         Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

         If nOpca = 1
            If nRadio = 2
               lPrintPeso := .f.
            EndIf
         EndIf

      Case cSet == T_CAPITULO // Tela para definição de impressão de capítulos.

         bOk := {|| lRet:=.t., oDlg:End()}

         Define MsDialog oDlg Title STR0155 From 10,12 TO nLin, nCol OF oMainWnd //"Definições para Impressão"
            
            oPanel:= TPanel():New(0, 0, "",oDlg,, .F., .F.,,, 40.5, 7.5)

            @ 1.5,0.5 TO nLinLab, nColLab Label STR0157 Of oPanel //"Dados a serem impressos"
            @ 32 ,40 CheckBox lPrintCap    PROMPT STR0158     SIZE 45,07 OF oPanel Pixel //"Capítulos"
            @ 42 ,40 CheckBox lPrintSubCap PROMPT STR0159 SIZE 45,07 OF oPanel Pixel //"Sub-capítulos"

            oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

         Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

   EndCase

End Sequence

Return lRet

/*
Funcao      : VlExtEsp(Valor,Moeda)
Parametros  : Valor = Valor a ser descrito em extenso.
              Moeda = Codigo da moeda.
Retorno     : Valor por extenso.
Objetivos   : Montar descrição por extenso em espanhol.
Autor       : Jeferson Barros Jr.
Data/Hora   : 07/01/03 - 15:43
Obs.        :
*/

*-------------------------------------*
Function VlExtEsp(Valor,Moeda)
*-------------------------------------*
Local SingMoeda,PlurMoeda,SingCent,PlurCent, Extenso:="", ParteInteira,;
      VlString, Bilhoes, Milhoes, Milhares, Centenas, Centavos
Local aOrd := SaveOrd({"SYF","EE2"})
Local bRestore := {|| RestOrd(aOrd)}

cChave := "ESP.  "
cChave := cChave+"-"+Tabela("ID",cChave)

SYF->(dbSetOrder(1))
EE2->(dbSetOrder(1))

If !EE2->(DBSEEK(xFilial()+"4*"+AVKey(cChave,"EE2_IDIOMA")+AVKey(Moeda,"EE2_COD")))
   RETURN "*** DESCRICAO EM ESPANHOL NAO CADASTRADO PARA A MOEDA "+MOEDA
Else
   SingMoeda:= ALLTRIM(EE2->EE2_DESC_S)
   PlurMoeda:= ALLTRIM(EE2->EE2_DESC_P)
   SingCent := "Centavo"
   PlurCent := "Centavos"
EndIf

Eval(bRestore)

If Valor <= 0
   Return "Zero"
ElseIf Valor > 999999999999.99
   Return "*** Erro: Valor maior que 999.999.999.999,99 ***"
EndIf

VlString    := STRZERO(Valor,15,2)
ParteInteira:= VAL(SUBSTR(VlString,01,12))
Bilhoes     := SUBSTR(VlString,01,3)
Milhoes     := SUBSTR(VlString,04,3)
Milhares    := SUBSTR(VlString,07,3)
Centenas    := SUBSTR(VlString,10,3)
Centavos    := "0"+SUBSTR(VlString,14,2)

If Val(Bilhoes) # 0
   Extenso:= VlCentEsp(Bilhoes)+If(Val(Bilhoes) = 1," Billon"," Billones")
EndIf

If Val(Milhoes) # 0
   Extenso:= Extenso + If(Len(Extenso)#0," , ","") + ;
             VlCentEsp(Milhoes) + If(Val(Milhoes) = 1," Millon"," Millones")
EndIf

IF Val(Milhares) # 0
   Extenso:= Extenso + If(Len(Extenso)#0," , ","") + ;
             VlCentEsp(Milhares) + " Mil "
EndIf

If Val(Centenas) # 0
   Extenso:= Extenso +  VlCentEsp(Centenas)
EndIf

If ParteInteira # 0
   If ( Val(Bilhoes)  # 000 .OR.  Val(Milhoes)  # 000 ) .AND.;
      ( Val(Milhares) = 000 .AND. Val(Centenas) = 000 )
       Extenso:= Extenso //+ " of"
   EndIf
   Extenso:= Extenso + If(ParteInteira=1," " + SingMoeda," " + PlurMoeda)
EndIf

If Val(Centavos) # 0
   Extenso:= Extenso + If(Len(Extenso)#0," y ","") + ;
            VlCentEsp(Centavos) + IF(Val(Centavos)=1," " + SingCent," " + PlurCent)
EndIf

Return (Upper(SubStr(Extenso,1,1))+SubStr(Extenso,2))

/*
Funcao      : VlExtEsp(Numero)
Parametros  :
Retorno     : Valor por extenso.
Objetivos   : Auxiliar a funcao ExtEsp
Autor       : Jeferson Barros Jr.
Data/Hora   : 07/01/03 - 15:43
Obs.        :
*/
*-------------------------------*
Static Function VlCentEsp(Numero)
*-------------------------------*
LOCAL VlExtenso:= "", Num1:= VAL( SUBSTR(Numero,1,1) ),;
      Num2:= VAL( SUBSTR(Numero,2,1) ), Num3:= VAL( SUBSTR(Numero,3,1) )

Local Unidades := {"Uno","Dos", "Tres","Cuatro", "Cinco", "Seis", "Siete", "Ocho", "Nueve", "Diez",;
	               "Once", "Doce", "Trece", "Catorce", "Quince", "Dieciseis", "Diecisiete", "Dieciocho", "Diecinueve"}

Local Dezenas := {"Diez", "Veinte", "Treinta", "Cuarenta", "Cincuenta", "Sesenta", "Setenta", "Ochenta", "Noventa"}

Local Centenas := {"Ciento ","Doscientos ","Trescientos ","Cuatrocientos ","Quinientos ",;
                   "Seiscientos ","Setecientos ","Ochocientos ","Novecientos "}

If Num1 # 0
   If Num1 = 1 .AND. Num2 = 0 .AND. Num3 = 0
      VlExtenso:= "Cien"
   Else
      VlExtenso:= Centenas[Num1]
      If !Empty(VlExtenso)
          VlExtenso := VlExtenso +  " y "
      Endif
   EndIf
EndIf

If Num2 # 0
   If Num2 < 2
      VlExtenso:= VlExtenso+" "+Unidades[(Num2*10+Num3)]
   ElseIf Num2 = 2
      VlExtenso:= VlExtenso + If(Len(VlExtenso)#0," y ","") + If(Num3#0,"Veinti ",Dezenas[Num2])
      If Num3 # 0
        VlExtenso:= VlExtenso+Unidades[Num3]
      EndIf
   Else
        VlExtenso:= VlExtenso + Dezenas[Num2]
        If !Empty(VlExtenso)
          VlExtenso := VlExtenso +  " y "
        Endif
      If Num3 # 0
        VlExtenso:= VlExtenso+" "+Unidades[Num3]
      EndIf
   EndIf
ElseIf Num3 # 0
   VlExtenso:= VlExtenso+" "+Unidades[Num3]
EndIf

Return (VlExtenso)

/*
Funcao      : EECSelDocs(aOldDocs)
Parametros  : aOldDocs - Array com os documentos já editados.
Objetivos   : Selecao de Documentos para Impressao da Carta Remessa.
Retorno     : aRet := Array com os documentos que irão em anexo na Carta Remessa.
Autor       : Jeferson Barros Jr.
Data/Hora   : 08/12/03 - 09:57.
Obs.        :  * Considera que o EEC já está posicionado.
               * aDocs por dimensão:
                    aDocs[i][1] -> Descrição do documento.
                         [i][2] -> Quantidade de originais.
                         [i][3] -> Quantidade de cópias.
                         [i][4] -> Deletado - .t./.f.
*/
*---------------------------*
Function EECSelDocs(aOldDocs)
*---------------------------*
Local aOrd:=SaveOrd("EE1")
Local cImpPais, cCodLjImp
Local lTemDocAnexo
Local aRet:={}

Private aDocs:={}

Begin Sequence

   lTemDocAnexo := (Len(aOldDocs) > 0)

   // ** Caso já exista documentos anexados, não carrega os documentos do EE1.
   If lTemDocAnexo
      aDocs:= aOldDocs
      aRet := aDocs
   Else
      EXB->(DbSetOrder(1))
      If EXB->(DbSeek(xFilial("EXB")+EEC->EEC_PREEMB+Space(AvSx3("EE7_PEDIDO",AV_TAMANHO))))

         Do While EXB->(!Eof()) .And. EXB->EXB_FILIAL == xFilial("EXB") .And.;
            EXB->EXB_PREEMB == EEC->EEC_PREEMB .And.;
            EXB->EXB_PEDIDO == Space(AvSx3("EE7_PEDIDO",AV_TAMANHO))

            // ** Descrição do documento do "EEA".
            cDesc := AllTrim(Posicione("EEA",1,xFilial("EEA")+EXB->EXB_CODATV,"EEA_TITULO"))

            If !Empty(cDesc)
               aAdd(aDocs,{cDesc,0,0,.f.}) // array com os detalhes dos documentos.
            EndIf

            EXB->(DbSkip())
         EndDo
      Else
         // ** Carrega os documentos para o pais e importador.
         cImpPais  := Posicione("SA1",1,xFilial("SA1")+EEC->EEC_IMPORT+EEC->EEC_IMLOJA,"A1_PAIS")
         cCodLjImp := EEC->EEC_IMPORT+EEC->EEC_IMLOJA

         EE1->(DbSetOrder(3))
         If EE1->(DbSeek(xFilial("EE1")+TR_ARQ+cImpPais+cCodLjImp))

            Do While EE1->(!Eof() .And. EE1_FILIAL == xFilial("EE1")) .And.;
                                        EE1->EE1_CODCLI+EE1->EE1_CLLOJA == cCodLjImp

               // ** Tratamentos especícos para set do array aDocs.
               EECAddDoc()
               EE1->(DbSkip())
            EndDo

         ElseIf EE1->(DbSeek(xFilial("EE1")+TR_ARQ+cImpPais+Space(AvSx3("EE1_CODCLI",AV_TAMANHO))+;
                                                            Space(AvSx3("EE1_CLLOJA",AV_TAMANHO))))

            Do While EE1->(!Eof() .And. EE1_FILIAL == xFilial("EE1")) .And. cImpPais == EE1->EE1_PAIS .And.;
                     EE1->EE1_CODCLI+EE1->EE1_CLLOJA == Space(AVSX3("EE1_CODCLI",AV_TAMANHO))+Space(AVSX3("EE1_CLLOJA",AV_TAMANHO))

               // ** Tratamentos especícos para set do array aDocs.
               EECAddDoc()
               EE1->(DbSkip())
            EndDo
         EndIf
      EndIf
   EndIf

   If EECShowDocs(aDocs)
      aRet:=aDocs
   EndIf

End Sequence

RestOrd(aOrd)

Return aRet

/*
Funcao      : EECShowDocs(aDocs)
Parametros  : aDocs - Array com os documentos.
Objetivos   : Mostrar IW_Multiline para edição das informações dos documentos.
Retorno     : .t./.f.
Autor       : Jeferson Barros Jr.
Data/Hora   : 08/12/03 - 10:55.
Obs.        :
*/
*--------------------------------*
Static Function EECShowDocs(aDocs)
*--------------------------------*
Local lRet:=.t., j:=0, i:=0
Local oDlg, oGetDb
Local bOk := {|| oDlg:End()}, bCancel := {|| lRet:=.f., oDlg:End()}

Private cUsad   := Posicione("SX3",2,"EEC_PREEMB","X3_USADO")
Private aHeader:={}, aCols:={}

Begin Sequence

   // ** Carrega as informações do aCols (Serão exibidas na Iw_multiline).
   For j:=1 To Len(aDocs)
      aAdd(aCols,Array(4))
      aCols[Len(aCols)][01] := aDocs[j][1]
      aCols[Len(aCols)][02] := aDocs[j][2]
      aCols[Len(aCols)][03] := aDocs[j][3]
      aCols[Len(aCols)][04] := aDocs[j][4] // Deleted.
   Next

   aAdd(aHeader,{STR0160,"WKDOC","@!" ,60,0,"",cUsad  ,"C","ZZZ"}) //"Documentos"
   aAdd(aHeader,{STR0161  ,"WKORI","99" ,02,0,"EECValDoc()",cUsad  ,"N","ZZZ"}) //"Original"
   aAdd(aHeader,{STR0162  ,"WKCOP","99" ,02,0,"EECValDoc()",cUsad  ,"N","ZZZ"}) //"Copia   "

   Define MsDialog oDlg Title STR0163 FROM 200,1 TO 620,600 Pixel OF oMainWnd //"Documentos Anexos"
      oGetDb  := IW_MultiLine(15,3,209,297, .t., .t.)
      oGetDb:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
   Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg,bOk,bCancel)

   If lRet
      aDocs:={}
      For i:=1 To Len(aCols)
         aAdd(aDocs,{aCols[i][1],aCols[i][2],aCols[i][3],aCols[i][4]})
      Next
   EndIf

End Sequence

Return lRet

/*
Funcao      : EECAddDoc()
Parametros  : Nenhum.
Objetivos   : Auxiliar a função EECSelDocs() - Set do array aDocs{}.
Retorno     : .t./.f.
Autor       : Jeferson Barros Jr.
Data/Hora   : 08/12/03 - 10:46.
Obs.        :
*/
*-------------------------*
Static Function EECAddDoc()
*-------------------------*
Local lRet:=.t., cDesc

Begin Sequence

   // ** Apenas os documentos de fases "1 - Todas" ou "3 - Embarque".
   If !(EE1->EE1_FASE $ "13 ")
      lRet:=.f.
      Break
   EndIf

   // ** Descrição do documento do "EEA".
   cDesc := AllTrim(Posicione("EEA",1,xFilial("EEA")+EE1->EE1_DOCUM,"EEA_TITULO"))

   If !Empty(cDesc)
      aAdd(aDocs,{cDesc,0,0,.f.}) // array com os detalhes dos documentos.
   EndIf

End Sequence

Return lRet

/*
Funcao      : EECValDoc()
Parametros  : Nenhum.
Objetivos   : Validar as informações dos documentos anexos no momento da digitação.
Retorno     : .t./.f.
Autor       : Jeferson Barros Jr.
Data/Hora   : 08/12/03 - 15:18.
Obs.        :
*/
*------------------*
Function EECValDoc()
*------------------*
Local lRet:=.t.

Begin Sequence

   If Type("M->WKORI") ="N"
      If (M->WKORI < 0)
         MsgStop(STR0164,STR0103) //"Quantidade de documentos originais inválida!"###"Atenção"
         lRet:=.f.
         Break
      EndIf
   EndIf

   If Type("M->WKCOP") ="N"
      If (M->WKCOP < 0)
         MsgStop(STR0165,STR0103) //"Quantidade de originais/cópias inválida!"###"Atenção"
         lRet:=.f.
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao      : BuscaVlCot().
Parametros  : cMesAno   - Mês e Ano de Cotação da Bolsa.
              cCodBolsa - Código da Bolsa
              dDtCot    - Data da Cotação
              cUnConv   - Unidade de medida em que a cotação será retornada
Retorno     : Valor de fechamento da bolsa.
Objetivos   : Busca Valor de Fechamento da Bolsa.
Autor       : Jeferson Barros Jr.
Data/Hora   : 30/03/2004 17:32.
Revisao     :
Obs.        :
*/
*------------------------------------------------------------------*
Function BuscaVlCot(cMesAno,cCodBolsa,dDtCot,cUnConv, lNotConvMoed)
*------------------------------------------------------------------*
Local nRet:=0
Local lFound:=.f.
Local lBolsa := EECFlags("BOLSAS")
Local cDtCot, nPos
//RMD - 17/11/21 - Adiciona Avkey nos códigos de bolsa devido aumento do campo no dicionário
Local aBolsas      := {{AvKey("NY", "EX7_CODBOL"),EasyGParam("MV_AVG0062",,"")},{Avkey("BMF", "EX7_CODBOL"),EasyGParam("MV_AVG0116",,"")},{AvKey("LON", "EX7_CODBOL"),EasyGParam("MV_AVG0030",,"")}}
Local nTaxaBolsa   := "" //DFS - 11/09/12 - Inclusão de variavel para receber a taxa utilizada na bolsa
Local nTaxaDolar   := "" //DFS - 11/09/12 - Inclusão de variavel para receber a taxa referente ao dolar

Default dDtCot    := dDataBase
Default cCodBolsa := ""
Default cUnConv   := ""
Default lNotConvMoed := .F. //DFS - 11/09/12 - Variável para não converter a moeda se for US$

Begin Sequence

   If Empty(cMesAno)
      Break
   EndIf

   If ValType(dDtCot) <> "D" .And. lBolsa
      Break
   EndIf

   cMesAno   :=AvKey(cMesAno  ,"EX7_MESANO")
   If lBolsa
      cCodBolsa :=AvKey(cCodBolsa,"EX7_CODBOL")
   EndIf

   cDtCot := If(lBolsa,DtoS(dDtCot),"")

   EX7->(DbSetOrder(1))

   lFound := EX7->(DbSeek(xFilial("EX7")+cMesAno+cDtCot+cCodBolsa))

   If lFound
      nRet:= EX7->EX7_VALCOT
   Else
      // ** Caso não tenha encontrado cotação para a database, verifica qual é a última cotação para o mesmo
      // ** mes e ano.
      EX7->(DbSeek(xFilial("EX7")+cMesAno+cDtCot+cCodBolsa,.t.))
      Do While EX7->(!Bof()) .And. xFilial("EX7") == EX7->EX7_FILIAL

         If (EX7->EX7_MESANO == cMesAno .and. If(lBolsa,Val(DtoS(EX7->EX7_DATA)) <= Val(cDtCot) .And. EX7->EX7_CODBOL == cCodBolsa,.T.))
            nRet := EX7->EX7_VALCOT
            Break
         EndIf

         EX7->(DbSkip(-1))
      EndDo
   EndIf

   If nRet = 0
      MsgInfo(STR0186,STR0026)//"Não foi encontrada nenhuma cotação para o período e bolsa informados." ## "Atenção"
      Break
   EndIf

   If !Empty(cUnConv)
      If lBolsa
         nPos := ASCAN(aBolsas,{|x| x[1] == EX7->EX7_CODBOL})
         nRet := AvTransUnid(aBolsas[nPos][2],cUnConv,,nRet,.F.,.T.)
      Else
         nRet := AvTransUnid(EasyGParam("MV_AVG0062",,""),cUnConv,,nRet,.F.,.T.)
      EndIf
   EndIf

   //EJA - 03/01/2019 - Se o conteúdo do parâmetro estiver vazio, a moeda padrão deve ser definido como US$. 
   cMoedaCot := EasyGParam("MV_AVG0218",,"US$")
   If Empty(cMoedaCot)
      cMoedaCot := "US$"
   EndIf

   //DFS - 11/09/12 - Tratamento para que, possa guardar as taxas da bolsa e do dolar.
   If cMoedaCot <> "US$" .And. !lNotConvMoed
      nTaxaBolsa  := BuscaTaxa(cMoedaCot  ,dDtCot,.T.,.F.,.T.)
      nTaxaDolar  := BuscaTaxa("US$"      ,dDtCot,.T.,.F.,.T.)
      nRet        := (nRet * nTaxaBolsa) / nTaxaDolar
   EndIf

End Sequence

Return nRet

/*
Funcao      : EECView().
Parametros  : cMsg     - Msg a ser exibida na janela.
              cTitulo  - Titulo da janela.
              cLabel   - Texto para label que envolve o memo.
              aButtons - Array com botões a serem adicionados na enchoice bar
              bValid   - Bloco de código com validação a ser utilizada no botão OK
Retorno     : .t.
Objetivos   : Mostrar tela de msg ao usuário. Disponibilizar integração com o NotePad para que o usuário
              possa salvar/imprimir a msg.
Autor       : Jeferson Barros Jr.
Data/Hora   : 09/04/2004 14:45.
Revisao     :
Obs.        :
*/
*------------------------------------------------------*
Function EECView(xMsg,cTitulo,cLabel, aButtons, bValid, lQuebraLinha, lSoExibeMsg, bAction,lLarge)
*------------------------------------------------------*
/*
AMS - 18/11/2004 às 11:08. Atribuição como .F. para variavel lRet para não retornar .T. quando o usuário
                           clicar no botão "X" (padrão do windows) para fechar a janela.
Local lRet := .t.
*/
Local lRet := .F., i, j
Local oDlg, oMemo, oFont := TFont():New("Courier New",09,15)

Local bOk      := {|| If( Eval(bValid), (EECNote(.t.,cMsg),lRet:=.T.,oDlg:End()), )},;
      bCancel  := {|| EECNote(.t.,cMsg),oDlg:End()}

Local cMsg := ""   // JPM - 06/10/05
Local nQuebra := 68// JPM - 06/10/05
Local cLib
Local lLogView
Local aCoors := FWGetDialogSize( oMainWnd )

Default xMsg     := ""
Default cTitulo  := ""
Default cLabel   := ""
Default aButtons := {}
Default bValid   := {|| .T. }
Default lQuebraLinha:= .T.
Default lSoExibeMsg:= .F.
Default lLarge := .F.

Begin Sequence

   lLogView:= bAction <> Nil
   
   If lLogView
      bCancel  := {|| IIf(Eval(bValid), (EECNote(.t.,cMsg),oDlg:End()), Nil)}
   EndIf
   
   GetRemoteType(@cLib)
   If "WIN" $ cLib
      aAdd(aButtons, {"NOTE" ,{||  EECNote(.f.,cMsg,"EECView.txt")},"NotePad"})
   EndIf

   // ** JPM - 06/10/05
   If ValType(xMsg) = "C"
      cMsg := xMsg
   ElseIf ValType(xMsg) = "A"
      For i := 1 To Len(xMsg)
         If xMsg[i][2] // Posição que define se fará quebra de linha
            For j := 1 To MLCount(xMsg[i][1],nQuebra)
               cMsg += MemoLine(xMsg[i][1], nQuebra, j) + ENTER
            Next
         Else
            cMsg += xMsg[i][1]
         EndIf
      Next
   EndIf
   // **
   If lLarge
      nDlgLini := int(aCoors[1]*0.85)
      nDlgCini := int(aCoors[2]*0.85)
      nDlgLfim := int(aCoors[3]*0.85)
      nDLgCfim := int(aCoors[4]*0.85)
       
      nLblLin := int(aCoors[3]*0.38)
      nLblCol := int(aCoors[3]*0.88)

      nFntWidth :=  int(aCoors[4]*0.41) // 770
      nFntHeigth := int(aCoors[3]*0.35)  //275
   else
      nDlgLini := 9
      nDlgCini := 0
      nDlgLfim :=39
      nDlgCfim :=85

      nLblLin := 190
      nLblCol := 330

      nFntWidth := 315 
      nFntHeigth :=169

   EndIf
      oDlg := MSDialog():New(nDlgLini,nDlgCini,nDlgLfim,nDlgCfim,cTitulo,,,,,,,,,lLarge,,,,) 
      

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 15/07/2015 - Ajustes Tela P12.
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

//      @ 05,05 To nLblLin,nLblCol Label cLabel Pixel Of oPanel
      @ 15,10 Get oMemo Var cMsg MEMO HSCROLL FONT oFont Size nFntWidth,nFntHeigth READONLY Of oPanel  Pixel

      oMemo:lWordWrap := lQuebraLinha
      oMemo:EnableVScroll(.t.)
      oMemo:EnableHScroll(.t.)

      If lLogView
         oDlg:bstart:=  { || Eval( bAction, oMemo)}
      EndIf

   Activate MsDialog oDlg On Init Enchoicebar(oDlg,bOk,bCancel,,aButtons,,,,,!lSoExibeMsg,!lSoExibeMsg) Centered // BHF - 01/08/08 -> Trocado Enchoicebar por AvButtonBar

End Sequence

Return lRet

/*
Funcao      : EECNote().
Parametros  : lApaga -> .t. - Apaga arquivo temporário.
                        .f. - Abre o NotePad com a msg passada como parâmetro.
              cMsg   -> Texto a ser exibido no NotePad.
              cFile  -> Nome do arquivo a ser aberto no NotePad.
Retorno     : .t.
Objetivos   : Auxiliar a função EECView(). Abre o NotePad com o texto passado como parâmetro a fim de proporcionar
              ao usuário imprimir ou salvar para futura conferência.
              Caso o parâmetro lApaga = .t., apaga o arquivo temporário "EECView.txt".
Autor       : Jeferson Barros Jr.
Data/Hora   : 09/04/2004 14:54.
Revisao     :
Obs.        :
*/
*----------------------------------------*
Static Function EECNote(lApaga,cMsg,cFile)
*----------------------------------------*
Local lRet:=.t., cDir:=GetTempPath(),hFile

Default lApaga := .f. // Se .t. apaga arquivo temporário.
Default cFile  := "EECView.txt"

Begin Sequence

   If !lApaga
      hFile := EasyCreateFile(cDir+cFile)

      fWrite(hFile,cMsg,Len(cMsg))

      fClose(hFile)

      //WinExec("NotePad "+cDir+cFile)
      ShellExecute("open",cDir + cFile,"","", 1)
   Else
      If File(cDir+cFile)
         fErase(cDir+cFile)
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao      : EECCALCDESC(cOcorre).
Parametros  : cOcorre -> OC_PE - Pedido
                         OC_EM - Embarque
Retorno     : nRet ( O desconto dos itens do pedido somados )
Objetivos   : Calcular o desconto total do pedido quando a rotina de desconto por itens
              estiver ativa ( MV_AVG0119 == .T. )
Autor       : Fabio Hildebrand - FJH
Data/Hora   : 03/02/2006 13:45
*/

Function EECCALCDESC(cOcorre)
Local cAlias, nDescon := 0, NRecNO

   If EE8->(FieldPos("EE8_DESCON")) < 1 .or. !EasyGParam("MV_AVG0119",,.F.)
      Return .F.
   Endif

   If cOcorre == "Q"
      cAlias := "WorkIP"
   Elseif cOcorre == "P"
      cAlias := "WorkIT"
   Else
      Return .F.
   Endif

   nRecNo := &(cAlias)->(RECNO())
   &(cAlias)->(DBGoTop())

   While &(cAlias)->(!EOF())

      If cOcorre == "P" .or. ( Workip->WP_FLAG == cMarca .and. cOcorre == "Q" )
         nDescon += &( cAlias + If(cOcorre == "Q", "->EE9", "->EE8" ) + "_DESCON" )
      Endif
      &(cAlias)->(DBSkip())

   End

   &( "M" + If(cOcorre == "Q", "->EEC", "->EE7" ) + "_DESCON" ) := nDescon
   &(cAlias)->(DBGoTo(nRecNo))

Return .T.

/*
Funcao     : MenuDef()
Parametros : cFuncao
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 23/01/07 - 10:12
*/
Static Function MenuDef(cOrigem)
Local aRotAdic := {}
Local aRotina := {}
Default cOrigem  := AvMnuFnc()

cOrigem := Upper(AllTrim(cOrigem))

Begin Sequence

   Do Case

      Case cOrigem $ "EECAT140" //Cotação de Moedas
           Aadd(aRotina, { STR0001 , "AxPesqui"   , 0 , 1})  //"Pesquisar"
           Aadd(aRotina, { STR0002 , "EECATManut" , 0 , 2})  //"Visualizar"
           Aadd(aRotina, { STR0003 , "EECATManut" , 0 , 3})  //"Incluir"
           Aadd(aRotina, { STR0004 , "EECATManut" , 0 , 4})  //"Alterar"
           Aadd(aRotina, { STR0005 , "EECATManut" , 0 , 5})  //"Excluir"

           // P.E. utilizado para adicionar itens no Menu da mBrowse
           If EasyEntryPoint("EAT140MNU")
	          aRotAdic := ExecBlock("EAT140MNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf

      Case cOrigem $ "EECAT150" //Cotação da Bolsa
           Aadd(aRotina, { STR0001,  "AxPesqui", 0 , 1})  //"Pesquisar"
           Aadd(aRotina, { STR0002,  "AT150MAN", 0 , 2})   //"Visualizar"
           Aadd(aRotina, { STR0003,  "AT150MAN", 0 , 3})   //"Incluir"
           Aadd(aRotina, { STR0004,  "AT150MAN", 0 , 4})   //"Alterar"
           Aadd(aRotina, { STR0005,  "AT150MAN", 0 , 5,3}) //"Excluir"

           // P.E. utilizado para adicionar itens no Menu da mBrowse
           If EasyEntryPoint("EAT150MNU")
	          aRotAdic := ExecBlock("EAT150MNU",.f.,.f.)
	          If ValType(aRotAdic) == "A"
		         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf

      Case cOrigem $ "EECAF400" // Cadastro de Despesas
           Aadd(aRotina, { STR0001,   "AxPesqui"  , 0 , 1}) //"Pesquisar"
           Aadd(aRotina, { STR0002,   "AxVisual"  , 0 , 2}) //"Visualizar"
           Aadd(aRotina, { STR0003,   "AF400Manut", 0 , 3}) //"Incluir"
           Aadd(aRotina, { STR0004,   "AF400Manut", 0 , 4}) //"Alterar"
           Aadd(aRotina, { STR0005,  "AF400Deleta", 0 , 5,3} ) //"Excluir"

           // P.E. utilizado para adicionar itens no Menu da mBrowse
           If EasyEntryPoint("EAF400MNU")
	          aRotAdic := ExecBlock("EAF400MNU",.f.,.f.)
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
Funcao      : EECF3AGE()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Rotina externa chamada na consulta padrão EE6AGE,
              para retornar conteúdo da tabela SY4 se Módulo Importação
              ou SY5 se Módulo Exportação, no F3 do campo EE6_AGENTE.
Autor       : Thiago Rinaldi Pinto - TRP
Data/Hora   : 25/10/2007
*/

*----------------------------------------*
Function EECF3AGE()
*----------------------------------------*
Local cRetorno:= ""

If nModulo == 29  //Exportação
   cRetorno:= ConPad1(,,,'SY5',,)
Elseif nModulo == 17  //Importação
   cRetorno:= ConPad1(,,,'SY4',,)
Endif

Return cRetorno

/*
Funcao      : VALID_AGENTE()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Rotina que acerta o valid do campo EE6_AGENTE de acordo,
              com o módulo (Importação ou Exportação).
Autor       : Thiago Rinaldi Pinto - TRP
Data/Hora   : 25/10/2007
*/

*----------------------------------------*
Function VALID_AGENTE()
*----------------------------------------*
Local cRetorno:= ""

If nModulo == 29  //Exportação
   cRetorno:= ExistCpo("SY5",M->EE6_AGENTE)
Elseif nModulo == 17 //Importação
   cRetorno:= ExistCpo("SY4",M->EE6_AGENTE)
Endif

Return cRetorno


/*
Funcao      : GATILHOAGENTE()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Rotina que acerta o gatilho do campo EE6_AGENTE de acordo,
              com o módulo (Importação ou Exportação).
Autor       : Tamires Daglio Ferreira - TDF
Data/Hora   : 30/08/2010
*/

*----------------------------------------*
Function GATILHOAGENTE()
*----------------------------------------*
Local cRetorno:= ""

If nModulo == 29  //Exportação
   SY5->(DbSetOrder(1))
   SY5->(DbSeek(xFilial("SY5")+M->EE6_AGENTE))
   cRetorno:= SY5->Y5_NOME
Elseif nModulo == 17 //Importação
   SY4->(DbSetOrder(1))
   SY4->(DbSeek(xFilial("SY4")+M->EE6_AGENTE))
   cRetorno:= SY4->Y4_NOME
Endif

Return cRetorno
/*
Função      : AvCposEnc(cAlias, xForceShow, xForceNShow)
Autor       : Rodrigo Mendes Diaz
Data        : 29/10/08
Objetivo    : Montar array com campos que devem ser exibidos na enchoice para determinada tabela
Parâmetros  : cAlias      - [OBRIGATORIO] - Tabela na qual será baseada a verificação dos campos;
              xForceShow  - [OPCIONAL]    - Campos que devem obrigatoriamente ser incluídos na enchoice, do tipo Array(n campos) ou String(1 campo);
              xForceNShow - [OPCIONAL]    - Campos que não devem ser incluídos na enchoice, do tipo Array(n campos) ou String(1 campo).
Retorno     : aCampos - Array com campos que devem ser mostrados na enchoice.
Observações : Os critérios para exibição dos campos são: Todos os campos usados, mais os campos informados em xForceShow menos os campos informados em xForceNShow.
*/
Function AvCposEnc(cAlias, xForceShow, xForceNShow)
Local aOrd := SaveOrd("SX3")
Local aCampos := {}
Local nInc, nPos
Default xForceShow  := {}
Default xForceNShow := {}

   SX3->(DbSetOrder(1))
   SX3->(DbSeek(cAlias))
   While SX3->(!Eof() .And. X3_ARQUIVO == cAlias)
      If X3Uso(SX3->X3_USADO)
         aAdd(aCampos, SX3->X3_CAMPO)
      EndIf
      SX3->(DbSkip())
   EndDo

   If ValType(xForceShow) == "C"
      xForceShow := {xForceShow}
   EndIf
   If ValType(xForceNShow) == "C"
      xForceNShow := {xForceNShow}
   EndIf

   For nInc := 1 To Len(xForceShow)
      If aScan(aCampos, xForceShow[nInc]) == 0
         aAdd(aCampos, xForceShow[nInc])
      EndIf
   Next

   For nInc := 1 To Len(xForceNShow)
      If (nPos := aScan(aCampos, xForceNShow[nInc])) > 0
         aDel(aCampos, nPos)
         aSize(aCampos, Len(aCampos) - 1)
      EndIf
   Next

RestOrd(aOrd, .T.)
Return aCampos

Static Function CarregaECI(nOpc,aCols,aHeader)
   aCols := {}
   Temp_ECI->(DBGoTop())
   Do While !Temp_ECI->( EoF())
         //Adiciona o Numero da Conta Contabil encontrado no ECI
         aAdd( aCols,Array( Len(aHeader) + 1 ) )
         GDFieldPut("ECI_TPMODU", Temp_ECI->ECI_TPMODU, Len(aCols))
         GDFieldPut("ECI_TPCONT", Temp_ECI->ECI_TPCONT, Len(aCols))
         GDFieldPut("ECI_BANCOD", Temp_ECI->ECI_BANCOD, Len(aCols))
         GDFieldPut("ECI_AGENCI", Temp_ECI->ECI_AGENCI, Len(aCols))
         GDFieldPut("ECI_NUMCON", Temp_ECI->ECI_NUMCON, Len(aCols))
         GDFieldPut("ECI_CONTAB", Temp_ECI->ECI_CONTAB, Len(aCols))
         If ECI->(FieldPos("ECI_PORTAD")) > 0 .And. ECI->(FieldPos("ECI_TPPORT")) > 0
            GDFieldPut("ECI_PORTAD", Temp_ECI->ECI_PORTAD, Len(aCols))
            GDFieldPut("ECI_TPPORT", Temp_ECI->ECI_TPPORT, Len(aCols))
         EndIf
         GDFieldPut("ECI_ALI_WT", "ECI", Len(aCols))
         GDFieldPut("ECI_REC_WT", Temp_ECI->(Recno()), Len(aCols))
         aCols[Len(aCols)][Len(aHeader)+1] := .F. //Marca como não deletados
      Temp_ECI->( DbSkip() )
   EndDo

Return .T.

Static Function AddAcols(aCols, nOpc)

   aAdd(aCols[Len(aCols)], Nil)
   aIns(aCols[Len(aCols)], Len(aHeader) + 1)
   aCols[Len(aCols)][Len(aHeader) + 1] := If(nOpc <> 3 .Or. Temp_ECI->(Eof()), Temp_ECI->(Recno()), 0)

Return .T.

Static Function GetInfAcols(aCols,aHeader,cCampo,nPos)
Local xInfo
Local nPosHeader := 0

If Len(aCols) > 0
   If (nPosHeader := aScan(aHeader,{|X| AllTrim(Upper(X[2])) == AllTrim(Upper(cCampo))})) > 0
      xInfo := aCols[nPos][nPosHeader]
   EndIf
EndIf

If ValType(xInfo) == "U"
   xInfo := CriaVar(cCampo)
EndIf

Return xInfo

Static Function ECIGravaWork()
Local i
Local lCpoPortador := ECI->(FieldPos("ECI_PORTAD")) > 0 .And. ECI->(FieldPos("ECI_TPPORT")) > 0

Begin Sequence
   Temp_ECI->(DbSetOrder(1)) // ECI_BANCOD+ECI_AGENCI+ECI_NUMCON+ECI_TPMODU+ECI_TPCONT
   For i := 1 To Len(aCols)
       Temp_ECI->(DbSeek(AvKey(M->A6_COD,"ECI_BANCOD")+;
                                  AvKey(M->A6_AGENCIA,"ECI_AGENCI")+;
                                  AvKey(M->A6_NUMCON,"ECI_NUMCON")+;
                                  AvKey(GetInfAcols(aCols,aHeader,"ECI_TPMODU",i),"ECI_TPMODU")+;
                                  AvKey(GetInfAcols(aCols,aHeader,"ECI_TPCONT",i),"ECI_TPCONT")))
       If !GDDeleted(i)
          Temp_ECI->ECI_BANCOD := M->A6_COD
          Temp_ECI->ECI_TPMODU := GetInfAcols(aCols,aHeader,"ECI_TPMODU" ,i)
          Temp_ECI->ECI_TPCONT := GetInfAcols(aCols,aHeader,"ECI_TPCONT" ,i)
          Temp_ECI->ECI_CONTAB := GetInfAcols(aCols,aHeader,"ECI_CONTAB" ,i)
          Temp_ECI->ECI_AGENCI := M->A6_AGENCIA
          Temp_ECI->ECI_NUMCON := M->A6_NUMCON
          If lCpoPortador
             Temp_ECI->ECI_PORTAD := GetInfAcols(aCols,aHeader,"ECI_PORTAD" ,i)
             Temp_ECI->ECI_TPPORT := GetInfAcols(aCols,aHeader,"ECI_TPPORT" ,i)
          EndIf
       Else
          Temp_ECI->ECI_CONTAB := Space(AvSX3("ECI_CONTAB",AV_TAMANHO))
          If lCpoPortador
             Temp_ECI->ECI_PORTAD := Space(AvSX3("ECI_PORTAD",AV_TAMANHO))
             Temp_ECI->ECI_TPPORT := Space(AvSX3("ECI_TPPORT",AV_TAMANHO))
          EndIf
       EndIf
   Next
   aHeader := {}
   aCols := {}
End Sequence

Return nil

/*
Função      : EECAtuPesNF(cAlias, xForceShow, xForceNShow)
Autor       : Thiago Rinaldi Pinto
Data        : 21/06/2012
Objetivo    : Definir se os pesos líquido e bruto serão recalculados na NF de Saída.
Parâmetros  : cPedido - Pedido de Exportação.
Retorno     : lRet - .T. (Recalcula Pesos) - .F. (Não recalcula Pesos).
*/
Function EECAtuPesNF(cPedido)

Local lRet:= .F.
Local aOrdEE7:= {}

aOrdEE7:= SaveOrd({"EE7"})

EE7->(DBSETORDER(1))

If EE7->(DBSEEK(xFilial("EE7")+AvKey(cPedido,"EE7_PEDIDO")))
   If !EasyGParam("MV_AVG0063",,.F.) .And. EE7->EE7_BRUEMB $ cSim
      lRet:= .T.
   Endif
Endif

RestOrd(aOrdEE7,.T.)

Return lRet

/*
Funcao      : EasyIsVincAdiant
Objetivos   : Verifica se o adiantamento esta vinculado à um contrato de financiamento.
Autor       : Felipe Sales Martinez - FSM
Data/Hora   : 05/10/2012
*/
Function EasyIsVincAdiant(nOpc, cInvo, cParc, lMsg)
Local lRet := .F.
Local aOrd := SaveOrd({"EF3"})
Default lMsg := .T.

Begin Sequence
	If nOpc <> INCLUIR .And. nOpc <> VISUALIZAR
		EF3->(DBSetOrder(3)) //FILIAL + TPMODU + INVOIC + PARC + CODEVE
		If EF3->(DBSeek( xFilial("EF3") + AvKey("E","EF3_TPMODU") + AvKey(cInvo,"EF3_INVOIC") + AvKey(cParc,"EF3_PARC") + AvKey(EV_EMBARQUE,"EF3_CODEVE") ))
			If(lMsg, EasyHelp(STR0201+ AllTrim(cInvo)+STR0202+ AllTrim(EF3->EF3_CONTRA) + "'.", STR0026),nil) //STR0201->"Esta operação não é permitida pois o adiantamento com o número de Invoice '" //STR0202->"' presente neste processo está vinculado ao contrato de financiamento '" //"Atenção"
			lRet := .T.
		EndIf
	EndIf
End Sequence

RestOrd(aOrd)
Return lRet


/*
Funcao      : EasyGeraMovimen
Objetivos   : Verifica se o motivo de baixa do contrato de financiamento gera
			 ou não movimentação bancária.
Autor       : Felipe Sales Martinez - FSM
Data/Hora   : 15/10/2012
*/
Function EasyGeraMovimen(cSeekinfo, nOrdSeek, nOpcSeek)
Local lRet := .T.
Local aOrd := SaveOrd({"EF1","EF3","EF7"})
Local lSeek := .F.
Default nOrdSeek := 1
Default nOpcSeek := 1

Do Case
	Case nOpcSeek == 1 //Verifica o se gera movimentação atraves das informações da capa
		EF1->(DBSetOrder(nOrdSeek)) //FILIAL + TPMODU + CONTRA + BAN_FI + PRACA + SEQCNT
		If EF1->(DBSeek(cSeekinfo))
			lSeek := .T.
		EndIf

	Case nOpcSeek == 2 //Verifica o se gera movimentação atraves das informações dos itens
		EF3->(DBSetOrder(nOrdSeek)) //FILIAL + TPMODU + INVOIC + PARC + CODEVE
		If EF3->(DBSeek(cSeekinfo))
			EF1->(DBSetOrder(1))
			If EF1->(DBSeek(xFilial("EF3")+EF3->(EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA +EF3_SEQCNT)))
				lSeek := .T.
			EndIf
		EndIf
EndCase

If lSeek
	If EF7->( DBSetOrder(1), DBSeek(xFilial("EF7")+EF1->EF1_TP_FIN) )
		lRet := MovBcoBx(EF7->EF7_MOTBXI)
	EndIf
EndIf

RestOrd(aOrd)
Return lRet


/*
Funcao      : EasyLiqContAdian
Objetivos   : Liquida o contrato de financiamento vinculado ao adiantamento.
Autor       : Felipe Sales Martinez - FSM
Data/Hora   : 08/10/2012
*/
Function EasyLiqContAdian()
Local aOrd := SaveOrd({"EF1", "EF2"})
Local lOldFinan := lFinanciamento

// Variaveis privadas utilizadas no EFFEX400 e EFFEX401
Private aGetProv := {}  ,;
        lInverte := .F. ,;
        cMod     := ""  ,;
        cTX_100  := ""  ,;
        cTX_520  := ""

Private lMultiFil      := VerSenha(115) .and. Posicione("SX2",1,"EEC","X2_MODO") == "E" .and.;
                          Posicione("SX2",1,"EF1","X2_MODO") == "C"

Private lACCACE        := .T. //EasyGParam("MV_ACC_ACE",,.T.)

Private lCadFin := ChkFile("EF7")  .And.  ChkFile("EF8")  .And.  ChkFile("EF9")

// Testa se existe os campos nos arquivos  - Usada no EFFEX400
SX3->( DBSetOrder(2) )
Private lTemChave := SX3->(DBSeek("EF1_BAN_FI")) .and. SX3->(DBSeek("EF1_PRACA")) .and.;
                     SX3->(DBSeek("EF2_BAN_FI")) .and. SX3->(DBSeek("EF2_PRACA")) .and.;
                     SX3->(DBSeek("EF3_BAN_FI")) .and. SX3->(DBSeek("EF3_PRACA")) .and.;
                     SX3->(DBSeek("EF4_BAN_FI")) .and. SX3->(DBSeek("EF4_PRACA")) .and.;
                     SX3->(DBSeek("EF1_AGENFI")) .and. SX3->(DBSeek("EF1_NCONFI")) .and.;
                     SX3->(DBSeek("EF3_AGENFI")) .and. SX3->(DBSeek("EF3_NCONFI")) .and.;
                     SX3->(DBSeek("ECE_BANCO"))  .and. SX3->(DBSeek("ECE_PRACA"))  .and.;
                     SX3->(DBSeek("EF3_OBS"))   .AND. SX3->(DBSeek("EF3_NROP"))

Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0

Private lPrePag     := EF1->(FieldPos("EF1_CAREPR")) > 0 .and. EF1->(FieldPos("EF1_TPCAPR")) > 0 .and.;
                       EF1->(FieldPos("EF1_PARCPR")) > 0 .and. EF1->(FieldPos("EF1_PERIPR")) > 0 .and.;
                       EF1->(FieldPos("EF1_TPPEPR")) > 0 .and. EF1->(FieldPos("EF1_CAREJR")) > 0 .and.;
                       EF1->(FieldPos("EF1_TPCAJR")) > 0 .and. EF1->(FieldPos("EF1_PARCJR")) > 0 .and.;
                       EF1->(FieldPos("EF1_PERIJR")) > 0 .and. EF1->(FieldPos("EF1_TPPEJR")) > 0 .and.;
                       EF1->(FieldPos("EF1_PREPAG")) > 0 .and.;
                       EF1->(FieldPos("EF1_CLIENT")) > 0 .and. EF1->(FieldPos("EF1_CLLOJA")) > 0 .and.;
                       EF1->(FieldPos("EF1_ROF")) > 0    .and. EF1->(FieldPos("EF1_INI_IR")) > 0 .and.;
                       EF1->(FieldPos("EF1_FIM_IR")) > 0 .and. EF1->(FieldPos("EF1_PERCIR")) > 0 .and.;
                       EF1->(FieldPos("EF1_REAJIR")) > 0 .and. EF3->(FieldPos("EF3_SLDLIQ")) > 0 .and.;
                       EF3->(FieldPos("EF3_LIQ_RS")) > 0 .and. EF3->(FieldPos("EF3_NROP")) > 0 .and.;
                       EF3->(FieldPos("EF3_EV_VIN")) > 0 .and. EF3->(FieldPos("EF3_PARVIN")) > 0 .and.;
                       EF3->(FieldPos("EF3_SLDVIN")) > 0


lFinanciamento := lFinanciamento .And. lIntFina .and. !cFilAnt $ EasyGParam("MV_AVG0024",,"")

If lFinanciamento
   cFilEF3 := xFilial("EF3")
   cFilEF2 := xFilial("EF2")
   cFilEF1 := xFilial("EF1")
   lIsContab := .F.  //Var utilizada no EFFEX400
EndIf

If EF3->(dbSetOrder(2), dbSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+EV_EMBARQUE+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC))

	EF1->( dbSetOrder(1), dbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT))

	EC6->( DBSetOrder(1), EC6->(DbSeek(xFilial("EC6")+"FIEX"+EF1->EF1_TP_FIN+"520" )))
	cMod    := EF1->EF1_TPMODU
	cTX_100 := EC6->EC6_TXCV
	cTX_520 := EC6->EC6_TXCV

	EX400Liquida( EF1->EF1_CONTRA,;  // cContrato
	EEQ->EEQ_NRINVO            ,;  // cInvoice
	EEQ->EEQ_PARC              ,;  // cParc
	EEQ->EEQ_PREEMB            ,;  // cPreemb
	EEQ->EEQ_VL                ,;  // nValor
	EEQ->EEQ_MOEDA             ,;  // cMoeInv
	EF1->EF1_MOEDA             ,;  // cMoeCont
	"EF1"                      ,;  // cAliasEF1
	"EF3"                      ,;  // cAliasEF3
	"CAMB"                     ,;  // cChamada
	EEQ->EEQ_TX                ,;  // nTx
	EEQ->EEQ_PGT               ,;  // dData
							   ,;  // dDtLiq
	EEQ->EEQ_PGT               ,;  // dDtRealLiq
	xFilial("EEQ")             ,;  // cFilOri
							   ,;  // nVlMoeAnt
							   ,;  // nVlMoeAtu
							   ,;  // nVlReaAnt
							   ,;  // nVlReaAtu
	EEQ->EEQ_BANC              ,;  // cBanco
	EEQ->EEQ_AGEN              ,;  // cAgencia
	EF1->EF1_NCONFI            ,;  // cConta
	EF1->EF1_PRACA		       ,;  // cPraca
							   ,;  // lBxForc
	EEQ->EEQ_VL * EEQ->EEQ_TX  ,;  // nValorRea
							   ,;  // cParcAux
	EEQ->EEQ_NROP              ,;  // cNrOp
						       ,;  // nRecEF3Liq
    Left(TIPO_MODULO,1)		   ,;  // cTpModu
	EF1->EF1_SEQCNT            ,;  // cSeqCon
	"EEQ"                      ,;  // cOrigem
	EEQ->EEQ_FORN              ,;  // cForn
	EEQ->EEQ_FOLOJA            ,;  // cLojaFo
							   ,;  // cPo_Di
	                             ) // nVlMoeLiq

EndIf

RestOrd(aOrd)
lFinanciamento := lOldFinan
Return .T.


/*
Funcao      : EasyEstLiqContAdian
Objetivos   : Liquida o contrato de financiamento vinculado ao adiantamento.
Autor       : Felipe Sales Martinez - FSM
Data/Hora   : 08/10/2012
*/
Function EasyEstLiqContAdian()
Local aOrd := SaveOrd({"EF1", "EF3"})
Local lOldFinan := lFinanciamento

// Variaveis privadas utilizadas no EFFEX400 e EFFEX401
Private aGetProv := {}  ,;
        lInverte := .F. ,;
        cMod     := ""  ,;
        cTX_100  := ""  ,;
        cTX_520  := ""

Private lMultiFil      := VerSenha(115) .and. Posicione("SX2",1,"EEC","X2_MODO") == "E" .and.;
                          Posicione("SX2",1,"EF1","X2_MODO") == "C"

Private lACCACE        := .T. //EasyGParam("MV_ACC_ACE",,.T.)

Private lCadFin := ChkFile("EF7")  .And.  ChkFile("EF8")  .And.  ChkFile("EF9")

// Testa se existe os campos nos arquivos  - Usada no EFFEX400
SX3->( DBSetOrder(2) )
Private lTemChave := SX3->(DBSeek("EF1_BAN_FI")) .and. SX3->(DBSeek("EF1_PRACA")) .and.;
                     SX3->(DBSeek("EF2_BAN_FI")) .and. SX3->(DBSeek("EF2_PRACA")) .and.;
                     SX3->(DBSeek("EF3_BAN_FI")) .and. SX3->(DBSeek("EF3_PRACA")) .and.;
                     SX3->(DBSeek("EF4_BAN_FI")) .and. SX3->(DBSeek("EF4_PRACA")) .and.;
                     SX3->(DBSeek("EF1_AGENFI")) .and. SX3->(DBSeek("EF1_NCONFI")) .and.;
                     SX3->(DBSeek("EF3_AGENFI")) .and. SX3->(DBSeek("EF3_NCONFI")) .and.;
                     SX3->(DBSeek("ECE_BANCO"))  .and. SX3->(DBSeek("ECE_PRACA"))  .and.;
                     SX3->(DBSeek("EF3_OBS"))   .AND. SX3->(DBSeek("EF3_NROP"))

Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0

Private lPrePag     := EF1->(FieldPos("EF1_CAREPR")) > 0 .and. EF1->(FieldPos("EF1_TPCAPR")) > 0 .and.;
                       EF1->(FieldPos("EF1_PARCPR")) > 0 .and. EF1->(FieldPos("EF1_PERIPR")) > 0 .and.;
                       EF1->(FieldPos("EF1_TPPEPR")) > 0 .and. EF1->(FieldPos("EF1_CAREJR")) > 0 .and.;
                       EF1->(FieldPos("EF1_TPCAJR")) > 0 .and. EF1->(FieldPos("EF1_PARCJR")) > 0 .and.;
                       EF1->(FieldPos("EF1_PERIJR")) > 0 .and. EF1->(FieldPos("EF1_TPPEJR")) > 0 .and.;
                       EF1->(FieldPos("EF1_PREPAG")) > 0 .and.;
                       EF1->(FieldPos("EF1_CLIENT")) > 0 .and. EF1->(FieldPos("EF1_CLLOJA")) > 0 .and.;
                       EF1->(FieldPos("EF1_ROF")) > 0    .and. EF1->(FieldPos("EF1_INI_IR")) > 0 .and.;
                       EF1->(FieldPos("EF1_FIM_IR")) > 0 .and. EF1->(FieldPos("EF1_PERCIR")) > 0 .and.;
                       EF1->(FieldPos("EF1_REAJIR")) > 0 .and. EF3->(FieldPos("EF3_SLDLIQ")) > 0 .and.;
                       EF3->(FieldPos("EF3_LIQ_RS")) > 0 .and. EF3->(FieldPos("EF3_NROP")) > 0 .and.;
                       EF3->(FieldPos("EF3_EV_VIN")) > 0 .and. EF3->(FieldPos("EF3_PARVIN")) > 0 .and.;
                       EF3->(FieldPos("EF3_SLDVIN")) > 0

lFinanciamento := lFinanciamento .And. lIntFina .and. !cFilAnt $ EasyGParam("MV_AVG0024",,"")


If EF3->(dbSetOrder(2), dbSeek(xFilial("EF3")+Left(TIPO_MODULO,1)+"630"+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC))

	EF1->( dbSetOrder(1), dbSeek(xFilial("EF1")+Left(TIPO_MODULO,1)+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT))

	FAF2EstLiq(EF3->EF3_CONTRA,EF3->EF3_SEQ,EF3->EF3_BAN_FI,EF3->EF3_PRACA,.F.,If(lEFFTpMod,EF3->EF3_SEQCNT,""))

EndIf

RestOrd(aOrd)
lFinanciamento := lOldFinan
Return .T.


/*
Funcao      : EasyIntegAdiant
Objetivos   : Liquida o contrato de financiamento vinculado ao adiantamento.
Autor       : Felipe Sales Martinez - FSM
Data/Hora   : 08/10/2012
*/
Function EasyIntegAdiant(cOpc)
Local cRet:=""

Local lAdMvExt := AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. EasyVerModal("EEQ")  .And. !Empty(EEQ->EEQ_DTCE) .And. !Empty(EEQ->EEQ_BCOEXT) .And. !Empty(EEQ->EEQ_AGCEXT) .And. !Empty(EEQ->EEQ_CNTEXT)

cOpc := Upper(AllTrim(cOpc))

Do Case
	Case cOpc == "E1_PORTADO"
		 cRet := If( !lAdMvExt, EEQ->EEQ_BANC, EEQ->EEQ_BCOEXT )

	Case cOpc == "E1_AGEDEP"
		 cRet := If( !lAdMvExt, EEQ->EEQ_AGEN, EEQ->EEQ_AGCEXT )

	Case cOpc == "E1_CONTA"
		 cRet := If( !lAdMvExt, EEQ->EEQ_NCON, EEQ->EEQ_CNTEXT )

EndCase

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AV_MultiLine³ Autor ³ Tiago Santos       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Copia da funcao IW_MultiLine, porem passando a tela        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AV_MultiLine(nTop,nLeft,nBottom,nRight,lAlter,lDeleta,cLinhaOk,nFreeze,oTela)
Local nOpc := 3, aSavRot, lNeedRest := .f., oGetDados

DEFAULT nFreeze := 0                                                                                           

If Type("aRotina") == "A"
    lNeedRest := .t.
    aSavRot := aClone(aRotina)
EndIf

Private aRotina := { { "RDMAKE" ,"SIGAEEC", 0 , If(lAlter,3,2)}}
AADD(aRotina,aClone(aRotina[1]))
AADD(aRotina,aClone(aRotina[1]))

oGetDados := MsGetDados():New(nTop, nLeft, nBottom, nRight, nOpc, cLinhaOk,,,lDeleta,,nFreeze,,,,,,,oTela,If(nFreeze>0,.T.,.F.))

If lNeedRest
    aRotina := aClone(aSavRot)
EndIf
Return oGetDados

*--------------------------------------------------------------------------*
* FIM DO PROGRAMA EECCAD00.PRW                                             *
*--------------------------------------------------------------------------*
