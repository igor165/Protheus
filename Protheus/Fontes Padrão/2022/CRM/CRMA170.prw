#include "CRMA170.CH"
#Include "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "CRMDEF.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"


#DEFINE CRLF Chr(13)+Chr(10)

//----------------------------------------------------------
/*/{Protheus.doc} CRM170GetS()

Model - Modelo de dados da atividade

@param	  ExpL1 = Indica se a rotina que está chamando essa função é automatica ou não
	     	      Caso seja automatica não mostra a tela somente carrega os dados usuario e retorna o array.
		  ExpL2 = se foi criada a thread

@return  Retorna um array contendo as informações da usuario

@author   Victor Bitencourt
@since    17/02/2014
@version  12.0
/*/
//----------------------------------------------------------
Function CRM170GetS(lSincAut,lThrd)

Local oDlgSync		:= Nil
Local oPanelDt		:= Nil
Local oPanelUsr		:= Nil
Local oAgenda       := Nil
Local oContato    	:= Nil
Local oGrpAgenda	:= Nil
Local oGrpTarefa	:= Nil
Local oGrpContato	:= Nil
Local oGrpTempo		:= Nil
Local oGrpLogin 	:= Nil
Local oSaveLogin	:= Nil
Local oHabilita		:= Nil
Local oPeriodo		:= Nil
Local oComboAge		:= Nil
Local oComboTar		:= Nil
Local oPanel        := Nil
Local dDtTarIni		:= CTOD("  /  /  ")
Local dDtTarFim		:= CTOD("  /  /  ")
Local dDtAgeIni		:= CTOD("  /  /  ")
Local dDtAgeFim		:= CTOD("  /  /  ")
Local cTipoPerAge  	:= "1"
Local cTipoPerTar  	:= "1"
Local cTimeMin		:= ""
Local cSenhaAT      := ""
Local cUser			:= Space(200)
Local cSenhaUsu		:= Space(200)
Local cEndEmail     := Space(200)

Local aAreaAO3 		:= {}
Local aArea         := GetArea()
Local cCodUsr       := IIF(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr()) 
Local lUsrCRM       := .F.

Local lBiAgenda		:= .F.
Local lBiTarefa 	:= .F.
Local lBiContato 	:= .F.
Local lAgenda		:= .F.
Local lTarefa		:= .F.
Local lContato		:= .F.
Local lHabilita		:= .F.
Local lRet          := .T.

Local cComboAge 		:= "1"
Local aItemsAge		:= {STR0005,STR0003,STR0023,STR0004,STR0031,STR0001}//"Dia Atual"//"1 Semana"//"1 Mês"//"3 Meses"//"6 Meses"//"1 Ano"

Local cComboTar 		:= "1"
Local aItemsTar		:= {STR0005,STR0003,STR0023,STR0004,STR0031,STR0001}//"Dia Atual"//"1 Semana"//"1 Mês"//"3 Meses"//"6 Meses"//"1 Ano"

Default lSincAut     := .F.
Default lThrd        := .F.

If Select("AO3") > 0
	aAreaAO3 := AO3->(GetArea())
Else
	DbSelectArea("AO3")// Usuario do CRM
EndIf
AO3->(DbSetOrder(1))//AO3_FILIAL+AO3_CODUSR

If !Empty(cCodUsr) .AND. AO3->(DbSeek(xFilial("AO3")+cCodUsr))
  	lUSrCRM := .T.
    CRM170CUSR(@lAgenda,@cComboAge,@dDtAgeIni,@dDtAgeFim,@cTipoPerAge,;
               @lTarefa,@cComboTar,@dDtTarIni,@dDtTarFim,@cTipoPerTar,;
               @lContato,@lHabilita,@cTimeMin,@cUser,@cEndEmail,@cSenhaAT,;
               @lBiAgenda,@lBiTarefa,@lBiContato)

	If Empty(AO3->AO3_SNAEXG) .AND. lHabilita
		lSincAut      := .F.
	ElseIf Empty(AO3->AO3_SNAEXG)
		cSenhaUsu		:= AO3->AO3_SNAEXG
		cEndEmail     := AO3->AO3_EXGEMA
  	EndIf
EndIf

If !lSincAut .AND. lUSrCRM .AND. !lThrd // Verifica se a rotina não é automatica e se o usuario é cadastrado no CRM

		oDlgSync := FWDialogModal():New()
		oDlgSync:SetBackground(.F.) // .T. -> escurece o fundo da janela
		oDlgSync:SetTitle(STR0011)//"Sincronismo Exchange x Protheus"
		oDlgSync:SetEscClose(.T.)//permite fechar a tela com o ESC
		oDlgSync:SetSize(195,134) //cria a tela maximizada (chamar sempre antes do CreateDialog)
		oDlgSync:EnableFormBar(.F.)

		oDlgSync:CreateDialog() //cria a janela (cria os paineis)
		oPanel := oDlgSync:getPanelMain()

		@ 000, 000 MSPANEL oPanelDt   PROMPT '' SIZE 85,95 OF oPanel //COLOR CLR_RED, CLR_RED
		@ 000, 000 MSPANEL oPanelDt   PROMPT '' SIZE 85,95 OF oPanel //COLOR CLR_RED, CLR_RED
		oPanelDt:Align := CONTROL_ALIGN_TOP

		//Compromisso
		@ 002, 002 GROUP oGrpAgenda TO 20, 130 PROMPT "" OF oPanelDt PIXEL
		@ 006,005 CHECKBOX oAgenda VAR lAgenda PROMPT STR0012 OF oPanelDt SIZE 050, 010 PIXEL ON CLICK (CRM170Click(lAgenda,oComboAge,@dDtAgeIni,@dDtAgeFim)) //"Compromisso"
		@ 006,086 MSCOMBOBOX oComboAge VAR cComboAge ITEMS aItemsAge SIZE 042, 010 OF oPanelDt PIXEL;
		ON CHANGE (CRM170UOnChange(lAgenda,oComboAge:nAt,@dDtAgeIni,@dDtAgeFim,@cTipoPerAge)) //"Agenda"

	    If lAgenda == .F.
			oComboAge:Disable()
		EndIf

		//Tarefa
		@ 023, 002 GROUP oGrpTarefa TO 42, 130 PROMPT "" OF oPanelDt PIXEL
		@ 027,005 CHECKBOX oTarefa VAR lTarefa PROMPT STR0013 OF oPanelDt SIZE 050, 010 PIXEL ON CLICK (CRM170Click(lTarefa,oComboTar,@dDtTarIni,@dDtTarFim))//"Tarefa"
		@ 027,086 MSCOMBOBOX oComboTar VAR cComboTar ITEMS aItemsTar SIZE 042, 010 OF oPanelDt PIXEL;
		ON CHANGE (CRM170UOnChange(lTarefa,oComboTar:nAt,@dDtTarIni,@dDtTarFim,@cTipoPerTar))

	   If lTarefa == .F.
			oComboTar:Disable()
		EndIf

		//Contato
		@ 045,002 GROUP oGrpContato TO 64, 130 PROMPT "" OF oPanelDt PIXEL
		@ 049,005 CHECKBOX oContato VAR lContato PROMPT STR0014 OF oPanelDt SIZE 050, 010 PIXEL//"Contato"

		//Controloando as opções de configuração conforme a rotina que chamou.
		If !IsInCallStack("CRMA180")

			oTarefa:Disable()
			oComboTar:Disable()
			oGrpTarefa:Disable()

			oComboAge:Disable()
			oAgenda:Disable()
			oGrpAgenda:Disable()

		ElseIf IsInCallStack("CRMA180")

			oContato:Disable()
			oGrpContato:Disable()

		EndIf

		//Tempo Sincronização
		@ 067,002 GROUP oGrpContato TO 95, 130 PROMPT "" OF oPanelDt PIXEL
		@ 071,006 SAY oPeriodo PROMPT STR0015  SIZE 090, 010 OF oPanelDt PIXEL //"Tempo de sincronização em minutos"
		@ 070,104 MSGET cTimeMin	SIZE 010,009 	OF oPanelDt PIXEL PICTURE "9999"
		@ 083,005 CHECKBOX oHabilita VAR lHabilita PROMPT STR0016  OF oPanelDt SIZE 100, 010 PIXEL //"Habilita Sincronização Automatica"

		//Login Exchange
		@ 000, 000 MSPANEL oPanelUsr   PROMPT '' SIZE 40, 40 OF oPanel
		oPanelUsr:Align := CONTROL_ALIGN_ALLCLIENT

		@ 002,002 GROUP oGrpTarefa TO 63, 130 PROMPT STR0017 OF oPanelUsr PIXEL  //"Login Exchange"
		@ 013,006 SAY  STR0018 		SIZE 040,009 	OF oPanelUsr PIXEL //"Usuario :"
		@ 013,033 MSGET cUser		SIZE 095,009 	OF oPanelUsr PIXEL
		@ 026,006 SAY  STR0019 		SIZE 040,009 	OF oPanelUsr PIXEL //"Senha :"
		@ 026,033 MSGET cSenhaUsu	SIZE 095,009 	OF oPanelUsr PIXEL PASSWORD
		@ 039,006 SAY  STR0020		SIZE 040,009	OF oPanelUsr PIXEL //"E-mail"
		@ 039,033 MSGET cEndEmail	SIZE 095,009	OF oPanelUsr PIXEL

		DEFINE SBUTTON oBut1 FROM 066, 76 TYPE 1 ENABLE OF oPanelUsr PIXEL ACTION ((),;
		If(SINCRONIZA(cUser,cSenhaUsu,lAgenda,dDtAgeIni,dDtAgeFim,lTarefa,dDtTarIni,dDtTarFim,cEndEmail,lContato,lHabilita,cTipoPerAge,cTipoPerTar,cTimeMin,lBiAgenda, lBiTarefa, lBiContato, lSincAut)[1],oDlgSync:Deactivate(),Nil))
		DEFINE SBUTTON oBut2 FROM 066, 104 TYPE 2 ENABLE OF oPanelUsr PIXEL ACTION {lRet:=.F.,oDlgSync:Deactivate()}

	oDlgSync:activate()

ElseIf !lSincAut .AND. !lUSrCRM

	Aviso(STR0083,STR0085,{STR0084})//"Atenção"//"Para utilizar a sincronização, é necessário ser usuario CRM !"//"OK"

EndIf

If !Empty(aAreaAO3)
	RestArea(aAreaAO3)
EndIf

RestArea(aArea)

Return({lRet,{cUser,IIf(Empty(cSenhaAT),cSenhaUsu,cSenhaAT),lAgenda,dDtAgeIni,dDtAgeFim,lTarefa,dDtTarIni,dDtTarFim,cEndEmail, lContato,lHabilita,cTipoPerAge,cTipoPerTar,cTimeMin,lBiAgenda, lBiTarefa, lBiContato},lUSrCRM})

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRM170CUSR()
Carrega configuracoes do vendedor (relacionadas à integração com exchange)

@author Vendas CRM
@since 27/02/2014
/*/
//------------------------------------------------------------------------------------------------

Function CRM170CUSR( lAgenda,cComboAge,dDtAgeIni,dDtAgeFim,cTipoPerAge,;
					 	lTarefa,cComboTar,dDtTarIni,dDtTarFim,cTipoPerTar,;
					 	lContato,lHabilita,cTimeMin,cUser,cEndEmail,cSenha,;
					 	lBiAgenda,lBiTarefa,lBiContato)

Local aArea 	 := GetArea()


Do Case
	Case AO3->AO3_PERCOM  == "1"
			cComboAge := STR0021//"1 Dia Atual"
			dDtAgeIni := dDataBase
			dDtAgeFim := dDataBase
			cTipoPerAge := "1"

	Case AO3->AO3_PERCOM  == "2"
			cComboAge := STR0022//"1 Semana"
			dDtAgeIni := dDataBase-7
			dDtAgeFim := dDataBase+7
			cTipoPerAge := "2"

	Case AO3->AO3_PERCOM  == "3"
			cComboAge := STR0023//"1 Mês"
			dDtAgeIni := dDataBase-30
			dDtAgeFim := dDataBase+30
			cTipoPerAge := "3"

	Case AO3->AO3_PERCOM  == "4"
			cComboAge := STR0024//"3 Meses"
			dDtAgeIni := dDataBase-90
			dDtAgeFim := dDataBase+90
			cTipoPerAge := "4"

	Case AO3->AO3_PERCOM  == "5"
			cComboAge := STR0025//"6 Meses"
			dDtAgeIni := dDataBase-180
			dDtAgeFim := dDataBase+180
			cTipoPerAge := "5"

	Case AO3->AO3_PERCOM  == "6"
			cComboAge := STR0026//"1 Ano"
			dDtAgeIni := dDataBase-365
			dDtAgeFim := dDataBase+365
			cTipoPerAge := "6"
EndCase

If AO3->AO3_SINCOM == "1"
	lAgenda := .T.
Else
	lAgenda := .F.
EndIf


Do Case
 	Case AO3->AO3_PERTAF  == "1"
			cComboTar := STR0027//"1 Dia Atual"
			dDtTarIni := dDataBase
			dDtTarFim := dDataBase
			cTipoPerTar := "1"

	Case AO3->AO3_PERTAF == "2"
			cComboTar := STR0028//"1 Semana"
			dDtTarIni := dDataBase-7
			dDtTarFim := dDataBase+7
			cTipoPerTar := "2"

	Case AO3->AO3_PERTAF == "3"
			cComboTar := STR0029//"1 Mês"
			dDtTarIni := dDataBase-30
			dDtTarFim := dDataBase+30
			cTipoPerTar := "3"

	Case AO3->AO3_PERTAF == "4"
			cComboTar := STR0030//"3 Meses"
			dDtTarIni := dDataBase-90
			dDtTarFim := dDataBase+90
			cTipoPerTar := "4"

	Case AO3->AO3_PERTAF == "5"
			cComboTar := STR0031//"6 Meses"
			dDtTarIni := dDataBase-180
			dDtTarFim := dDataBase+180
			cTipoPerTar := "5"

	Case AO3->AO3_PERTAF == "6"
			cComboTar := STR0032//"1 Ano"
			dDtTarIni := dDataBase-365
			dDtTarFim := dDataBase+365
			cTipoPerTar := "6"
EndCase

If AO3->AO3_SINTAF  == "1"
	lTarefa := .T.
Else
	lTarefa := .F.
EndIf


If AO3->AO3_SINCON == "1"
	lContato := .T.
Else
	lContato := .F.
EndIf

If AO3->AO3_HABSIN == "1"
	lHabilita := .T.
Else
	lHabilita := .F.
EndIf

If AO3->AO3_BICOMP == "1"
	lBiAgenda := .T.
Else
	lBiAgenda := .F.
EndIf

If AO3->AO3_BITAF  == "1"
	lBiTarefa := .T.
Else
	lBiTarefa := .F.
EndIf

If AO3->AO3_BICONT == "1"
	lBiContato := .T.
Else
	lBiContato := .F.
EndIf

cTimeMin    := AO3->AO3_SINTIM
cUser       := AO3->AO3_EXGUSR
cEndEmail   := AO3->AO3_EXGEMA

If !Empty(AO3->AO3_SNAEXG)
	cSenha      := FWAES_decrypt(Decode64(AllTrim(AO3->AO3_SNAEXG)))
Else
	cSenha := AO3->AO3_SNAEXG
EndIf

RestArea(aArea)

Return

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRM180SAT()
Sincroniza Tarefas, Compromissos e Contatos do Exchange para o protheus do usuário.

@author Vendas CRM
@since 27/02/2014
/*/
//------------------------------------------------------------------------------------------------
Function CRM170SAT(cUser,cSenhaUsu,lAgenda,dDtAgeIni,dDtAgeFim,lTarefa,dDtTarIni,;
dDtTarFim,cEndEmail,lContato,lHabilita,cTipoPerAge,cTipoPerTar,cTimeMin, lBiAgenda, lBiTarefa, lBiContato, lCompleta, lAutomatico)

Local aRet          := {.T., ""}
Local cURL          := CRM170UrlE() //retorna a url de integração com exchange
Local aInfoSinc     := ({.T.,{cUser,cSenhaUsu,lAgenda,dDtAgeIni,dDtAgeFim,lTarefa,dDtTarIni,dDtTarFim,cEndEmail}})

Default lBiAgenda   := .F.
Default lBiTarefa   := .F.
Default lBiContato  := .F.
Default lCompleta   := .T.
Default lAutomatico := .F.

If !lAgenda .and. !lTarefa .and. !lContato
	MsgAlert(STR0033) //"Favor selecionar uma opção de sincronismo."
	aRet	:= {.F., ""}
	Return aRet
EndIF

If lHabilita
	If Empty(cTimeMin) .OR. cTimeMin = "0"
		MsgAlert(STR0034) //"Favor informar o tempo em minutos a serem sincronizados."
		aRet	:= {.F., ""}
		Return aRet
	EndIf
EndIf

If aRet[1] //Valida Usuário
	If Empty(cUser) .Or.Empty(cSenhaUsu) .Or. Empty(cEndEmail)
		MsgAlert(STR0035) //"Favor informar usuario e senha."
		aRet	:= {.F., ""}
		Return aRet
	EndIf
EndIf

If lAgenda == .T. .AND. Empty(cTipoPerAge)
	cTipoPerAge := "1"
EndIf
If lTarefa == .T. .AND. Empty(cTipoPerTar)
	cTipoPerTar := "1"
EndIf

If Empty(cURL)
	aRet	:= {.F., ""}
EndIf

If lCompleta .AND. !Empty(cURL) //Integração bidirecional (Inclui registros inseridos no outlook no Protheus)
	If aRet[1]
		If FunName() == "CRMA180"
			If lBiAgenda
				FwMsgRun(,{|| aRet := CRM170ImportAtiv(TPCOMPROMISSO, cEndEmail,cSenhaUsu, dDtAgeIni, dDtAgeFim) },Nil,STR0037) //"Sincronização bidirecional de Compromissos."
			EndIf
			If lBiTarefa
				FwMsgRun(,{|| aRet := CRM170ImportAtiv(TPTAREFA, cEndEmail,cSenhaUsu, dDtTarIni, dDtTarFim) },Nil,STR0039) //"Sincronização bidirecional de Tarefas."
			EndIf
		Else
			If lContato
				FwMsgRun(,{|| aRet := Ft321SincCon(aInfoSinc, lAutomatico) },Nil,STR0041) //Sincronizando contatos
			EndIf
			If lBiContato
				FwMsgRun(,{|| aRet := FT321IncCon(cEndEmail,cSenhaUsu) },Nil,STR0043) //"Sincronização bidirecional de contatos."
			EndIf
		EndIf
	EndIf
EndIf

If aRet[1]
	GrvInfoUSR(lAgenda,dDtAgeIni,dDtAgeFim,lTarefa,dDtTarIni,dDtTarFim,lContato,lHabilita,cTipoPerAge,cTipoPerTar,cTimeMin,cUser,cEndEmail,cSenhaUsu)
EndIf

Return(aRet)


//----------------------------------------------------------
/*/{Protheus.doc} GrvInfoUSR()

Grava as informações do usuario no banco.

@return  nenhum

@author   Victor Bitencourt
@since    17/02/2014
@version  12.0
/*/
//----------------------------------------------------------
Static Function GrvInfoUSR(lAgenda,dDtAgeIni,dDtAgeFim,lTarefa,dDtTarIni,dDtTarFim,lContato,lHabilita,cTipoPerAge,cTipoPerTar,cTimeMin,cUser,cEndEmail,cSenhaUsu)

Local cCodUsr	:= IIF(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
Local aArea     := GetArea()
Local aExecAuto := {}
Local aAreaAO3  := {}

Private lMsErroAuto := .F.

If Select("AO3") > 0
	aAreaAO3 := AO3->(GetArea())
Else
	DbSelectArea("AO3") //Tabela Usuarios do CRM
EndIf
AO3->(DbSetOrder(1)) //AO3_FILIAL+AO3CODUSR

aExecAuto := {{"AO3_FILIAL",xFilial("AO3")                     ,Nil} ,;
   				{"AO3_CODUSR",cCodUsr                            ,Nil} ,;
				{"AO3_SINCOM",IIF(lAgenda   == .T.,"1","2")		,Nil} ,;
				{"AO3_SINTAF",IIF(lTarefa   == .T.,"1","2")		,Nil} ,;
				{"AO3_SINCON",IIF(lContato  == .T.,"1","2")		,Nil} ,;
				{"AO3_HABSIN",IIF(lHabilita == .T.,"1","2")		,Nil} ,;
				{"AO3_PERCOM",IIF(Empty(cTipoPerAge),"1",cTipoPerAge) ,Nil} ,;
				{"AO3_PERTAF",IIF(Empty(cTipoPerTar),"1",cTipoPerTar) ,Nil} ,;
				{"AO3_SINTIM",cTimeMin                 	    	,Nil} ,;
				{"AO3_EXGUSR",cUser          	 					,Nil} ,;
				{"AO3_EXGEMA",cEndEmail			 					,Nil}}
CRMA210( aExecAuto, 4 )

//foi necessário gravar o campo AO3_SNAEXG desta maneira, porque o campo não é "usado" por motivos de segurança..
//o execauto do mvc, não reconhece este campo, por ele não estar usado.
If !Empty(cCodUsr) .AND. AO3->(DbSeek(xFilial("AO3")+cCodUsr))//
	RecLock("AO3",.F.)
		AO3->AO3_SNAEXG := Encode64(FWAES_encrypt(AllTrim(cSenhaUsu)))
	AO3->(MsUnlock())
EndIf

If !Empty(aAreaAO3)
	RestArea(aAreaAO3)
EndIF
RestArea(aArea)

Return

//----------------------------------------------------------
/*/{Protheus.doc} CRM170ImportAtiv()

Faz a conversão dos dados indicados , para datas a serem usuadas na sincronização.

@param	  ExpC1 = Tipo de Atividade que está sendo importada (1='Tarefa',2='Compromisso')
		  ExpC2 = Usuario do exchange
          ExpC3 = Senha do exchange
          ExpD1 = Data Inicial
          ExpD2 = Data Final

@return  Array contendo os dados da sincronização

@author   Victor Bitencourt
@since    17/02/2014
@version  12.0
/*/
//----------------------------------------------------------
Static Function CRM170ImportAtiv(cTpAtiv, cUserExchange,cPassExchange, dDataIni, dDataFim)

Local cCodUsr		:= IIF(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
Local aNvlEstrut    := CRMXNvlEst(cCodUsr)
Local aRetSinc      := {.F., ""}
Local aRetDados     := {}
Local aDaDos        := {}
Local aExecAuto     := {}
Local cPrioridade   := ""
Local cStatus       := ""
Local cPercent      := ""
Local nX            := 0

Private lMsErroAuto := .F.

If cTpAtiv == TPCOMPROMISSO
	aRetSinc   := EX07_Meet4(cUserExchange,cPassExchange, dDataIni, dDataFim) //Busca os Compromissos no exchange
ElseIf cTpAtiv == TPTAREFA
	aRetSinc   := EX07_Task4(cUserExchange,cPassExchange) //Busca os Tarefas no exchange
EndIf

aRetDados  := aRetSinc[3]

If ValType(aRetDados) == "A" //Testa se recebeu alguma coisa na lista de agendamentos

	For nX := 1 to Len(aRetDados)//percorre o array retornado com os agendamentos 

		If !ExcExistEnt(aRetDados[nX][1], "AOF", 2 ) //verifica se ja existe a Atividade no protheus (busca pelo id)

			aDaDos := aRetDados[nX]
			If cTpAtiv == TPCOMPROMISSO .And. ( !Empty( aDaDos[5] ) .And. !Empty( aDaDos[6] ) ) //Se a data estiver em branco não envio para o Execauto
				If dDataIni <= ExUTCToLocal(aDaDos[5])[1] .And. dDataFim >= ExUTCToLocal(aDaDos[6])[1]

		           aExecAuto := {{"AOF_FILIAL",xFilial("AOF")				,Nil}		   				,;
						   			 {"AOF_DTCAD" ,dDatabase					,Nil}						,;
									 {"AOF_IDEXC" ,aDaDos[1]					,Nil}						,;
									 {"AOF_TIPO"  ,TPCOMPROMISSO				,Nil}						,;
									 {"AOF_CHGKEY",aDaDos[2]					,Nil}						,;
									 {"AOF_ASSUNT",SUBSTR(aDaDos[3],1,30)		,Nil}						,;
									 {"AOF_DESCRI",aDaDos[3]				   	,Nil}						,;
									 {"AOF_DTINIC",ExUTCToLocal(aDaDos[5])[1]	,Nil}						,;
									 {"AOF_HRINIC",ExUTCToLocal(aDaDos[5])[2]	,Nil}						,;
									 {"AOF_DTFIM" ,ExUTCToLocal(aDaDos[6])[1]	,Nil}						,;
									 {"AOF_HRFIM" ,ExUTCToLocal(aDaDos[6])[2]	,Nil}						,;
									 {"AOF_LOCAL" ,aDaDos[8]					,Nil}						,;
									 {"AOF_IDESTN",aNvlEstrut[1]				,Nil}						,;
									 {"AOF_NVESTN",aNvlEstrut[2] 				,Nil}						,;
									 {"AOF_PARTIC",IIF(ValType(aDaDos[9]) == "A", Upper(ArrayToStr(aDaDos[9],";" )), IIF(!Empty(aDaDos[9]),aDaDos[9],"") ) ,Nil}}

					CRMA180( aExecAuto, 3, .T. ) // Importar agenda por rotina automatica
				EndIf
			ElseIf cTpAtiv == TPTAREFA .And. ( !Empty( aDaDos[11] ) .And. !Empty( aDaDos[9] ) )   //Se a data estiver em branco não envio para o Execauto
				IF dDataIni <= ExUTCToLocal(aDaDos[11])[1] .And. dDataFim >= ExUTCToLocal(aDaDos[9])[1]

					Do Case
						Case aDaDos[12] == "NotStarted"			// Não iniciado
							cStatus := "1"
						Case aDaDos[12] == "InProgress"			// Em andamento
							cStatus := "2"
						Case aDaDos[12] == "Completed" 			// Completada
							cStatus := "3"
						Case aDaDos[12] == "WaitingOnOthers" 	// Aguardando Outros
							cStatus := "4"
						Case aDaDos[12] == "Deferred" 			// Adiada
							cStatus := "5"
					EndCase
					Do Case
						Case aDaDos[5] $ "Baixa|Low|Baja" 
							cPrioridade := "1"
						Case aDaDos[5] == "Normal"
							cPrioridade := "2"
						Case aDaDos[5] $ "Alta|High"
							cPrioridade := "3"
					EndCase
					Do Case
						Case aDaDos[10] == "0"
							cPercent := "1"
						Case aDaDos[10] == "25"
							cPercent := "2"
						Case aDaDos[10] == "50"
							cPercent := "3"
						Case aDaDos[10] == "75"
							cPercent := "4"
						Case aDaDos[10] == "100"
							cPercent := "5"
					EndCase
	
	
	              aExecAuto := {{"AOF_FILIAL",xFilial("AOF")				,Nil}		   				,;
		    			   			{"AOF_DTCAD" ,dDatabase					,Nil}						,;
									{"AOF_IDEXC" ,aDaDos[1]					,Nil}						,;
									{"AOF_TIPO"  ,TPTAREFA			    	,Nil}						,;
									{"AOF_CHGKEY",aDaDos[2]					,Nil}						,;
									{"AOF_ASSUNT",aDaDos[3]			       	,Nil}						,;
									{"AOF_DESCRI",aDaDos[4]				   	,Nil}						,;
									{"AOF_IDESTN",aNvlEstrut[1]				,Nil}						,;
									{"AOF_NVESTN",aNvlEstrut[2] 			,Nil}						,;
									{"AOF_DTINIC",IIF(!Empty(aDaDos[11]),ExUTCToLocal(aDaDos[11])[1],""),Nil} ,;
									{"AOF_DTFIM" ,IIF(!Empty(aDaDos[9]) ,ExUTCToLocal(aDaDos[9]) [1],""),Nil} ,;
									{"AOF_PERCEN",cPercent      			,Nil}						,;
									{"AOF_PRIORI",cPrioridade              	,Nil}						,;
									{"AOF_STATUS",cStatus					,Nil}			            }
	
					CRMA180( aExecAuto, 3, .T. ) // Importar Tarefa por rotina automatica
				EndIf
			EndIf
		EndIf
	Next nX
EndIf

Return aRetSinc


//----------------------------------------------------------
/*/{Protheus.doc} CRM170Click()

Faz a conversão dos dados indicados , para datas a serem usuadas na sincronização.

@param	  ExpL1 = Flag para permitir as alterações
		  ExpO1 = Objeto que está sendo manipulado
          ExpD1 = Data inicial
          ExpD2 = Data Final
          ExpC2 = Tipo do periodo que foi escolhido


@return   nenhum

@author   Victor Bitencourt
@since    21/02/2014
@version  12.0
/*/
//----------------------------------------------------------
Static Function CRM170Click(lFlag,oObj,dDtIni,dDtFim,cTipoPeriodo)

If lFlag
	oObj:Enable()
	oObj:Refresh()
Else
	oObj:Disable()
	oObj:Refresh()
EndIF

	// Feita essa validação para o caso do usuario não alterar a combo onde não caira na função
	// chamado no evento ON CHANGE e as variaveis ficaram vazias.

	If Empty(dDtIni)
		dDtIni := dDataBase
	EndIf

	If	Empty(dDtFim)
		dDtFim := dDataBase
	EndIf

	If Empty(cTipoPeriodo)
		cTipoPeriodo := "A"
	EndIf

Return

//----------------------------------------------------------
/*/{Protheus.doc} CRM170UOnChange()

Faz a conversão dos dados indicados , para datas a serem usuadas na sincronização.

@param	  ExpL1 = Flag para permitir as alterações
          ExpN1 = Posição do combo Escolhida
          ExpD1 = Data inicial
          ExpD2 = Data Final
          ExpC2 = Tipo do periodo que foi escolhido


@return   Nenhum

@author   Victor Bitencourt
@since    21/02/2014
@version  12.0
/*/
//----------------------------------------------------------
Static Function CRM170UOnChange(lFlag,nPosCom,dDtIni,dDtFim,cTpPeriodo)

Default dDtIni  		:= CTOD("  /  /  ")
Default dDtFim  		:= CTOD("  /  /  ")
Default nPosCom  		:=  1
Default cTpPeriodo   := "1"

If lFlag == .T.
	Do Case
		Case nPosCom = 1 //"Dia Atual"
			cTpPeriodo := "1"	//1=Dia Atual
			dDtIni := dDataBase
			dDtFim := dDataBase
		Case nPosCom = 2 //"1 Semana"
			cTpPeriodo := "2"	//2=1 semana
			dDtIni := dDataBase-7
			dDtFim := dDataBase+7
		Case nPosCom = 3 //"1 Mes"
			cTpPeriodo := "3"	//3=1 mes
			dDtIni := dDataBase-30
			dDtFim := dDataBase+30
		Case nPosCom = 4 //"3 Meses"
			cTpPeriodo := "4"	//4=3 meses
			dDtIni := dDataBase-90
			dDtFim := dDataBase+90
		Case nPosCom = 5 //"6 Meses"
			cTpPeriodo := "5"	//5=6 meses
			dDtIni := dDataBase-180
			dDtFim := dDataBase+180
		Case nPosCom = 6 //"1 Ano"
			cTpPeriodo := "6"	//6=1 ano
			dDtIni := dDataBase-365
			dDtFim := dDataBase+365
	EndCase
EndIf

Return


//----------------------------------------------------------
/*/{Protheus.doc} CRM170SINCAUT()

Rotina de sincronização automatica das atividade, verificação de alteração nas atividades
no exchange..

@param	  ExpA1 = Array com as informações de sincronização
          ExpL1 = Indica sé automatica

@return  aRet = Array com as informações da sincronização

@author   Victor Bitencourt
@since    21/02/2014
@version  12.0
/*/
//----------------------------------------------------------
Function CRM170SINCAUT(aInfoSinc,lAutomatico)

Local cURL      	:= CRM170UrlE() //retorna a url de integração com exchange
Local aAgendaEXG	:= {}
Local aAgendaPESQ	:= {}
Local aTarefaEXG	:= {}
Local aTarefaPESQ	:= {}
Local aRetCanc		:= {}
Local nPos	 		:= 0
Local cDescricao	:= ""
Local cNomeEml		:= ""
Local nLen			:= 0
Local nY			:= 0
Local aConvDIni		:= {}
Local aConvDFim   	:= {}
Local aConvDRem   	:= {}
Local aTasksExchange  := {}
Local aExecAuto       := {}
Local cVersaoExchange := GetMv("MV_VEREXCH",,"")
Local aRetorno		:= Nil
Local aUTC			:= {}
Local aRet			:= {.T., ""}
Local cQuery        := ""
Local cPrioridade   := ""
Local cStatus       := ""
Local cPercent      := ""
Local cCodUsr		:= IIF(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
Local aNvlEstrut	:= {}

Default lAutomatico := .F.

Private lMsErroAuto := .F.

DbSelectArea("AOF")
AOF->(DbSetOrder(1))//AOF_FILIAL+AOF_CODIGO

If !Empty(cCodUsr)
	aNvlEstrut := CRMXNvlEst(cCodUsr)
EndIf

If aInfoSinc[_PREFIXO,_Agenda]
	cQuery := "SELECT AOF_CODIGO, AOF_CODUSR, AOF_LASTMO, AOF_LOCAL, AOF_AGEREU, AOF_EMLNAM, AOF_PARTIC, R_E_C_N_O_, AOF_IDEXC, AOF_CHGKEY ,"
	cQuery += "AOF_FILIAL, AOF_DTINIC, AOF_HRINIC, AOF_DTFIM, AOF_HRFIM, AOF_ASSUNT  "
	cQuery += "FROM "+RetSqlName("AOF")+" "
	cQuery += "WHERE AOF_FILIAL='"+xFilial("AOF")+"' AND "
	cQuery += "AOF_CODUSR='"+cCodUsr+"' AND "
	cQuery += "AOF_TIPO = '2' AND "
	cQuery += "AOF_DTINIC >= '"+Dtos(aInfoSinc[_PREFIXO,_DtAgeIni])+"' AND "
	cQuery += "AOF_DTFIM  <= '"+Dtos(aInfoSinc[_PREFIXO,_DtAgeFim])+"' AND "
	cQuery += "D_E_L_E_T_=' ' "
	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery NEW ALIAS "TMPAOF"

	If Val(cVersaoExchange) >= 2007

	    aAgendaEXG := EX07_Meet4(aInfoSinc[_PREFIXO,_Usuario],aInfoSinc[_PREFIXO,_SenhaUser],;
	                             aInfoSinc[_PREFIXO,_DtAgeIni],aInfoSinc[_PREFIXO,_DtAgeFim])
	    If !Empty(aAgendaEXG) .AND. aAgendaEXG[1]

		 	While TMPAOF->(!Eof())

				If !Empty(TMPAOF->AOF_IDEXC)

					nPos := AScan(aAgendaEXG[3],{|x| AllTrim(x[1]) == AllTrim( TMPAOF->AOF_IDEXC) })

					If nPos <= 0

						aRetorno := EX07_Meet5( aInfoSinc[_PREFIXO,_Usuario],aInfoSinc[_PREFIXO,_SenhaUser], {{AllTrim( TMPAOF->AOF_IDEXC)}} )

						If aRetorno[1]
							If Len(aRetorno[3]) == 0
			     	           aExecAuto := {{"AOF_FILIAL",xFilial("AOF") 		 ,Nil},;
									   			 {"AOF_CODIGO" ,TMPAOF->AOF_CODIGO  ,Nil}}
							   CRMA180( aExecAuto, 5, .T. ) // Deletar
							Else

					           aExecAuto := {	{"AOF_FILIAL",xFilial("AOF") 							,Nil}						,;
								 		     	{"AOF_CODIGO",TMPAOF->AOF_CODIGO						,Nil}						,;
					           					{"AOF_IDEXC" ,AllTrim(aRetorno[3][1][1])				,Nil}						,;
											 	{"AOF_CHGKEY",AllTrim(aRetorno[3][1][2])				,Nil}						,;
												{"AOF_ASSUNT",aRetorno[3][1][3]							,Nil}						,;
											 	{"AOF_DESCRI",aRetorno[3][1][4]				   			,Nil}						,;
											 	{"AOF_DTINIC",ExUTCToLocal(aRetorno[3][1][5])[1]		,Nil}						,;
											 	{"AOF_HRINIC",ExUTCToLocal(aRetorno[3][1][5])[2]		,Nil}						,;
											 	{"AOF_DTFIM" ,ExUTCToLocal(aRetorno[3][1][6])[1]		,Nil}						,;
												{"AOF_HRFIM" ,ExUTCToLocal(aRetorno[3][1][6])[2]		,Nil}						,;
											 	{"AOF_LOCAL" ,AllTrim(aRetorno[3][1][8])				,Nil}						,;
											 	{"AOF_PARTIC",IIF(ValType(aRetorno[3][1][9]) == "A", Upper(ArrayToStr( aRetorno[3][1][9],";" )), IIF(!Empty(aRetorno[3][1][9]),aRetorno[3][1][9],"") ) ,Nil}}

								CRMA180( aExecAuto, 4, .T. ) // Alterar Compromisso
							EndIf
						EndIf

					Else
						If (AllTrim( TMPAOF->AOF_CHGKEY) <> AllTrim(aAgendaEXG[3][nPos][2]) )

								 aExecAuto := {	{"AOF_FILIAL" ,xFilial("AOF") 							,Nil}						,;
								 		    	{"AOF_CODIGO" ,TMPAOF->AOF_CODIGO						,Nil}						,;
								 				{"AOF_IDEXC" ,AllTrim(aAgendaEXG[3][nPos][1])			,Nil}						,;
												{"AOF_CHGKEY",AllTrim(aAgendaEXG[3][nPos][2])			,Nil}						,;
												{"AOF_ASSUNT",aAgendaEXG[3][nPos][3]					,Nil}						,;
												{"AOF_DESCRI",aAgendaEXG[3][nPos][4]					,Nil}						,;
												{"AOF_DTINIC",ExUTCToLocal(aAgendaEXG[3][nPos][5])[1]	,Nil}						,;
												{"AOF_HRINIC",ExUTCToLocal(aAgendaEXG[3][nPos][5])[2]	,Nil}						,;
												{"AOF_DTFIM" ,ExUTCToLocal(aAgendaEXG[3][nPos][6])[1]	,Nil}						,;
												{"AOF_HRFIM" ,ExUTCToLocal(aAgendaEXG[3][nPos][6])[2]	,Nil}						,;
												{"AOF_LOCAL" ,AllTrim(aAgendaEXG[3][nPos][8])			,Nil}						,;
												{"AOF_PARTIC",IIF(ValType(aAgendaEXG[3][nPos][9]) == "A", Upper(ArrayToStr( aAgendaEXG[3][nPos][9],";" )), IIF(!Empty(aAgendaEXG[3][nPos][9]),aAgendaEXG[3][nPos][9],"") ) ,Nil}}

							   CRMA180( aExecAuto, 4, .T. ) //Alterar Compromisso
						Else
							If AOF->(DbSeek(xFilial("AOF")+TMPAOF->AOF_CODIGO)) //posiciona no registro
							 		CRM170ATLZ( aInfoSinc, cURL, "A", .F. ) // envia para atualizar
							EndIF

						EndIf 

					EndIf
				EndIf
				TMPAOF->(dbSkip())
			EndDo
		TMPAOF->(DBCloseArea())
		EndIf
		If !Empty(aAgendaEXG) .AND. !aAgendaEXG[1]
			TMPAOF->(DBCloseArea())
			aRet := CRM170IntegrationInformation(STR0051,aAgendaEXG[2], lAutomatico)  //"Não foi possível efetuar a integração com exchange, tente novamente mais tarde ou se o problema persistir, contate o administrador do sistema!"
			Return aRet
		ElseIf aRetorno != Nil .And. !aRetorno[1]
			TMPAOF->(DBCloseArea())
			aRet := CRM170IntegrationInformation(STR0052,aRetorno[2], lAutomatico) //"Não foi possível efetuar a integração com exchange, tente novamente mais tarde ou se o problema persistir, contate o administrador do sistema!"
			Return aRet
		EndIf
	Else// menores que 2007

	    aAgendaEXG := ExgConsAppointment(aInfoSinc[_PREFIXO,_Usuario], aInfoSinc[_PREFIXO,_SenhaUser], cURL,aInfoSinc[_PREFIXO,_DtAgeIni],aInfoSinc[_PREFIXO,_DtAgeFim], "00:00:00", "23:59:59",,F321GetLanExg())

	    If !Empty(aAgendaEXG) .AND. aAgendaEXG[1]

		 	While TMPAOF->(!Eof())

				nPos 		:= 0
		       cDescricao	:= ""
		    	If !Empty(TMPAOF->AOF_EMLNAM)
		    		nPos := aScan(aAgendaEXG[3], { |x| UPPER(Alltrim(x[2])) == UPPER(Alltrim(TMPAOF->AOF_EMLNAM))  })
	  				cNomeEml	:= Alltrim(TMPAOF->AOF_EMLNAM)
	   			Else
	   				cNomeEml	:= ft321GeraEML()
		    	EndIf

		    	If nPos > 0 .and. Alltrim(TMPAOF->AOF_LASTMO) == Alltrim(aAgendaEXG[3,nPos,_LASTMOD])
		    		TMPAOF->(dbSkip())
		    		Loop

		    	ElseIf nPos > 0 .and. ft321CompLastMod(TMPAOF->AOF_LASTMO, aAgendaEXG[3,nPos,_LASTMOD])
					//Atualiza Protheus
                  If TMPAOF->(!EOF())
	                  aConvDIni	:= CRM170ConvUTCTime(STOD(StrTran(Substr(aAgendaEXG[3,nPos,4],1,10),"-","")),Substr(aAgendaEXG[3,nPos,4],12,8))
	                  aConvDFim := CRM170ConvUTCTime(STOD(StrTran(Substr(aAgendaEXG[3,nPos,3],1,10),"-","")),Substr(aAgendaEXG[3,nPos,3],12,8))
			           aExecAuto := {{"AOF_FILIAL" ,xFilial("AOF") 				,Nil}						,;
						 		     	{"AOF_CODIGO" ,TMPAOF->AOF_CODIGO		,Nil}						,;
			           				{"AOF_EMLNAM" ,cNomeEml                		,Nil}						,;
									 	{"AOF_LASTMO",aAgendaEXG[3,nPos,6]		,Nil}						,;
										{"AOF_ASSUNT",aAgendaEXG[3,nPos,10]		,Nil}						,;
									 	{"AOF_DESCRI",aAgendaEXG[3,nPos,9]		,Nil}						,;
									 	{"AOF_DTINIC",aConvDIni[1]				,Nil}						,;
									 	{"AOF_HRINIC",aConvDIni[2]				,Nil}						,;
									 	{"AOF_DTFIM" ,aConvDFim[1]				,Nil}						,;
										{"AOF_HRFIM" ,aConvDFim[2]				,Nil}						,;
									 	{"AOF_LOCAL" ,aAgendaEXG[3,nPos,7]		,Nil}						,;
									 	{"AOF_PARTIC",IIF(ValType(aRetorno[3][1][9]) == "A", Upper(ArrayToStr( aRetorno[3][1][9],";" )), IIF(!Empty(aRetorno[3][1][9]),aRetorno[3][1][9],"") ) ,Nil}}

						CRMA180( aExecAuto, 4, .T. ) // Alterar Compromisso
		    	    EndIf  
		      Else
					//Atualiza Exchange

	    			// Se possui data de ultima modificacao eh porque foi dele deletado no Exchange e deve ser deletado no Protheus
					If !Empty(TMPAOF->AOF_LASTMO) .and. nPos == 0

	     	          aExecAuto := {{"AOF_FILIAL",xFilial("AOF") 		 ,Nil},;
							   			{"AOF_CODIGO" ,TMPAOF->AOF_CODIGO  ,Nil}}
					   CRMA180( aExecAuto, 5, .T. ) // Deletar

	              Else
						//Incluindo pesquisa do AD7 no Exchange.
			    		If f321AtuAgeExg("A",aInfoSinc[_PREFIXO,_Usuario], aInfoSinc[_PREFIXO,_SenhaUser], cAliasAD7, lAutomatico)[1]

			    	        //Pesquisa data Lastmodified
			    	        aAgendaPESQ := ExgConsAppointment(aInfoSinc[_PREFIXO,_Usuario], aInfoSinc[_PREFIXO,_SenhaUser], cURL,,,,,cNomeEml,F321GetLanExg())

							If !(aAgendaPESQ[1])
								aRet := CRM170IntegrationInformation(aAgendaPESQ[2],"", lAutomatico)
								TMPAOF->(dbCloseArea())
								Return aRet
							EndIF


							If AOF->(!EOF()) .And. Len(aAgendaPESQ[3]) > 0 //Atualiza  agenda Protheus com o apontamento gerado no Exchange
			     	           aExecAuto := {{"AOF_FILIAL",xFilial("AOF") 		 		,Nil},;
									   			 {"AOF_CODIGO" ,TMPAOF->AOF_CODIGO  		,Nil},;
									   			 {"AOF_LASTMO",aAgendaPESQ[3,1,6] 	,Nil},;
									   			 {"AOF_EMLNAM",cNomeEml 		 				,Nil}}
							    CRMA180( aExecAuto, 4, .T. ) // Atualizar
						    EndIf

		    	        EndIF

		    		EndIf
			    EndIf

	    		//Apaga Apontamento gerado no Exchange q ja foi atualizado
	    		If nPos > 0
		       	nLen := Len(aAgendaEXG[3])
			   	    aDel(aAgendaEXG[3],nPos)
					aSize(aAgendaEXG[3],nLen-1)
				EndIf

		    	TMPAOF->(dbSkip())
			EndDo
		    TMPAOF->(dbCloseArea())


		    //Pesquisa apontamentos gerados no Exchange
		    For nY:=1 to Len(aAgendaEXG[3])

		    	dbSelectArea("AD7")
		    	dbSetOrder(8)
		    	If !dbSeek(xFilial("AOF")+aAgendaEXG[3,nY,_NOME])

		    		If Substr(aAgendaEXG[3,nY,2],1,4) == "TEXG"
						//Cancela apontamento no Exchange pois no protheus ela foi deletada.

						If !Empty(aAgendaEXG[3,nY,11])
				   			//Cancela reuniao
				   			aRetCanc :=  ExgCancMeetingFunction(	aInfoSinc[_PREFIXO,_Usuario]		,;
																	aInfoSinc[_PREFIXO,_SenhaUser]		,;
																	cURL					,;
																	aAgendaEXG[3,nY,11]	,;
																	aAgendaEXG[3,nY,12]	,;
																	aAgendaEXG[3,nY,13]	,;
																	STR0053				,;  //"Cancelamento Automatico."
																	STR0054	,; //"Cancelamento automatico do compromisso."
																	aAgendaEXG[3,nY,2]	,;
																	F321GetLanExg()			)
						Else
							aRetCanc :=  ExgDelAppointment(aInfoSinc[_PREFIXO,_Usuario], aInfoSinc[_PREFIXO,_SenhaUser], cURL, aAgendaEXG[3,nY,2],F321GetLanExg())
	                    EndIF

						If !aRetCanc[1]
							aRet := CRM170IntegrationInformation(aRetCanc[2], nil,lAutomatico)
							return aRet
						EndIf
		    		Else

		    			 aConvDIni	 := CRM170ConvUTCTime(STOD(StrTran(Substr(aAgendaEXG[3,nY,4],1,10),"-","")),Substr(aAgendaEXG[3,nY,4],12,8))
		    	    	 aConvDFim := CRM170ConvUTCTime(STOD(StrTran(Substr(aAgendaEXG[3,nY,3],1,10),"-","")),Substr(aAgendaEXG[3,nY,3],12,8))
			    		 aExecAuto := {{"AOF_FILIAL",xFilial("AOF")				,Nil}		   				,;
							   			 {"AOF_DTCAD" ,dDatabase						,Nil}						,;
										 {"AOF_EMLNAM" ,aAgendaEXG[3,nY,2]			,Nil}						,;
										 {"AOF_TIPO"  ,TPCOMPROMISSO				,Nil}						,;
										 {"AOF_ASSUNT",aAgendaEXG[3,nY,10]			,Nil}						,;
										 {"AOF_DESCRI",aAgendaEXG[3,nY,9]			,Nil}						,;
										 {"AOF_DTINIC",aConvDIni[1]					,Nil}						,;
										 {"AOF_HRINIC",aConvDIni[2]					,Nil}						,;
										 {"AOF_DTFIM" ,aConvDFim[1]					,Nil}						,;
										 {"AOF_HRFIM" ,aConvDFim[2]					,Nil}						,;
										 {"AOF_LOCAL" ,aAgendaEXG[3,nY,7]			,Nil}						,;
										 {"AOF_IDESTN",aNvlEstrut[1]				,Nil}						,;
										 {"AOF_NVESTN",aNvlEstrut[2] 				,Nil}						,;
										 {"AOF_PARTIC",IIF(ValType(aAgendaEXG[3,nY,12]) == "A", Upper(ArrayToStr(aAgendaEXG[3,nY,12],";" )), IIF(!Empty(aAgendaEXG[3,nY,12]),aAgendaEXG[3,nY,12],"") ) ,Nil}}

						CRMA180( aExecAuto, 3, .T. ) // Importar agenda por rotina automatica
		        	EndIf
		        EndIf

		    Next nY
		EndIf
		If !Empty(aAgendaEXG) .AND. !aAgendaEXG[1]
		   TMPAOF->(DBCloseArea())
			aRet := CRM170IntegrationInformation(STR0055,aAgendaEXG[2], lAutomatico)  //"Não foi possível efetuar a integração com exchange, tente novamente mais tarde ou se o problema persistir, contate o administrador do sistema!"
			Return aRet
		ElseIf aRetorno != Nil .And. !aRetorno[1]
		   TMPAOF->(DBCloseArea())
			aRet := CRM170IntegrationInformation(STR0056,aRetorno[2], lAutomatico) //"Não foi possível efetuar a integração com exchange, tente novamente mais tarde ou se o problema persistir, contate o administrador do sistema!"
			Return aRet
		EndIf
	EndIf
EndIf

If aInfoSinc[_PREFIXO,_Tarefa]

	// Verificando tarefas
	cQuery := "SELECT AOF_CODIGO, AOF_CODUSR, AOF_LASTMO, AOF_LOCAL, AOF_AGEREU, AOF_EMLNAM, AOF_PARTIC, R_E_C_N_O_, AOF_IDEXC, AOF_CHGKEY ,"
	cQuery += "AOF_FILIAL, AOF_DTINIC, AOF_HRINIC, AOF_DTFIM, AOF_HRFIM, AOF_ASSUNT, AOF_STATUS  "
	cQuery += "FROM "+RetSqlName("AOF")+" "
	cQuery += "WHERE AOF_FILIAL='"+xFilial("AOF")+"' AND "
	cQuery += "AOF_CODUSR='"+cCodUsr+"' AND "
	cQuery += "AOF_TIPO = '1' AND "
	cQuery += "AOF_DTINIC >= '"+Dtos(aInfoSinc[_PREFIXO,_DtTarIni])+"' AND "
	cQuery += "AOF_DTFIM  <= '"+Dtos(aInfoSinc[_PREFIXO,_DtTarFim])+"' AND "
	cQuery += "D_E_L_E_T_=' ' "
	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery NEW ALIAS "TMPAOF"

	If Val(cVersaoExchange) >= 2007

	    aTasksExchange := EX07_Task4(aInfoSinc[_PREFIXO,_Usuario],aInfoSinc[_PREFIXO,_SenhaUser])

	    If !Empty(aTasksExchange) .AND. aTasksExchange[1]

		 	While TMPAOF->(!Eof())

				If !Empty(TMPAOF->AOF_IDEXC)

					nPos := AScan(aTasksExchange[3],{|x| AllTrim(x[1]) == AllTrim( TMPAOF->AOF_IDEXC) })

					If nPos <= 0

		     	    	aExecAuto := {{"AOF_FILIAL",xFilial("AOF") 		 ,Nil},;
						     		  {"AOF_CODIGO" ,TMPAOF->AOF_CODIGO  ,Nil}}
						CRMA180( aExecAuto, 5, .T. ) // Deletar
					Else
						If ( AllTrim( TMPAOF->AOF_CHGKEY) <> AllTrim(aTasksExchange[3][nPos][2]) )

							Do Case
								Case aTasksExchange[3][nPos][12] == "NotStarted"		// Não iniciado
									cStatus := "1"
								Case aTasksExchange[3][nPos][12] == "InProgress"		// Em andamento
									cStatus := "2"
								Case aTasksExchange[3][nPos][12] == "Completed" 		// Completada
									cStatus := "3"
								Case aTasksExchange[3][nPos][12] == "WaitingOnOthers" 	// Aguardando Outros
									cStatus := "4"
								Case aTasksExchange[3][nPos][12] == "Deferred" 			// Adiada
									cStatus := "5"
							EndCase
							Do Case
								Case Lower(AllTrim(aTasksExchange[3][nPos][5])) == "low"
									cPrioridade := "1"
								Case Lower(AllTrim(aTasksExchange[3][nPos][5])) == "normal"
									cPrioridade := "2"
								Case Lower(AllTrim(aTasksExchange[3][nPos][5])) == "high"
									cPrioridade := "3"
							EndCase
							Do Case
								Case AllTrim(aTasksExchange[3][nPos][10]) == "0"
									cPercent := "1"
								Case AllTrim(aTasksExchange[3][nPos][10]) == "25"
									cPercent := "2"
								Case AllTrim(aTasksExchange[3][nPos][10]) == "50"
									cPercent := "3"
								Case AllTrim(aTasksExchange[3][nPos][10]) == "75"
									cPercent := "4"
								Case AllTrim(aTasksExchange[3][nPos][10]) == "100"
									cPercent := "5"
 							EndCase
 							
 							
 							// Fazendo o Tratamento do Status para não subscrever o Status 9 do protheus,
 							// que é Cancelada
 							 If TMPAOF->AOF_STATUS == "9" .AND. cStatus == "5"
 							 	 cSatus := TMPAOF->AOF_STATUS
 							 EndIf
 							
 							 aExecAuto := {{"AOF_FILIAL",xFilial("AOF")			   	,Nil}		   				,;
 							 				{"AOF_CODIGO",TMPAOF->AOF_CODIGO			,Nil}						,;
											{"AOF_IDEXC" ,aTasksExchange[3][nPos][1]	,Nil}						,;
											{"AOF_CHGKEY",aTasksExchange[3][nPos][2]	,Nil}						,;
											{"AOF_ASSUNT",aTasksExchange[3][nPos][3]	,Nil}						,;
											{"AOF_DESCRI",aTasksExchange[3][nPos][4]	,Nil}						,;
											{"AOF_DTINIC",IIF(!Empty(aTasksExchange[3][nPos][11]),ExUTCToLocal(aTasksExchange[3][nPos][11])[1],CTOD("")) ,Nil}		,;
											{"AOF_DTFIM" ,IIF(!Empty(aTasksExchange[3][nPos][9]),ExUTCToLocal(aTasksExchange[3][nPos][9])[1],"")   ,Nil} 		,;
											{"AOF_DTLEMB",IIF(!Empty(aTasksExchange[3][nPos][6]),ExUTCToLocal(aTasksExchange[3][nPos][6])[1],CTOD(""))	,Nil}		,;
											{"AOF_HRLEMB",IIF(!Empty(aTasksExchange[3][nPos][6]),ExUTCToLocal(aTasksExchange[3][nPos][6])[2],"")	,Nil}	    ,;
											{"AOF_PERCEN",cPercent      				,Nil}						,;
											{"AOF_PRIORI",cPrioridade             		,Nil}						,;
											{"AOF_STATUS",cStatus						,Nil}			            }

							 CRMA180( aExecAuto, 4, .T. ) //Alterar Tarefa
						Else
							If AOF->(DbSeek(xFilial("AOF")+TMPAOF->AOF_CODIGO)) //posiciona no registro
							 		CRM170ATLZ( aInfoSinc, cURL, "A", .F. ) // envia para atualizar
							EndIF

						EndIf

					EndIf
				EndIf
				TMPAOF->(dbSkip())
			EndDo
		TMPAOF->(DBCloseArea())

		EndIf
		If !Empty(aTasksExchange) .AND. !aTasksExchange[1]
		   TMPAOF->(DBCloseArea())
			aRet := CRM170IntegrationInformation(STR0057,aTasksExchange[2], lAutomatico)  //"Não foi possível efetuar a integração com exchange, tente novamente mais tarde ou se o problema persistir, contate o administrador do sistema!"
			Return aRet
		ElseIf aRetorno != Nil .AND. !aRetorno[1]
		   TMPAOF->(DBCloseArea())
			aRet := CRM170IntegrationInformation(STR0058,aRetorno[2], lAutomatico) //"Não foi possível efetuar a integração com exchange, tente novamente mais tarde ou se o problema persistir, contate o administrador do sistema!"
			Return aRet
		EndIf
	Else// menores que 2007
		aTarefaEXG := ExgConsTasks(aInfoSinc[_PREFIXO,_Usuario], aInfoSinc[_PREFIXO,_SenhaUser], cURL,aInfoSinc[_PREFIXO,_DtAgeIni],aInfoSinc[_PREFIXO,_DtAgeFim], "00:00:00", "23:59:59",,F321GetLanExg())

	    If !Empty(aTarefaEXG) .AND. aTarefaEXG[1]

		 	While TMPAOF->(!Eof())

				nPos 		:= 0
		       cDescricao	:= ""
		    	If !Empty(TMPAOF->AOF_EMLNAM)
		    		nPos := aScan(aTarefaEXG[3], { |x| UPPER(Alltrim(x[2])) == UPPER(Alltrim(TMPAOF->AOF_EMLNAM))  })
	  				cNomeEml	:= Alltrim(TMPAOF->AOF_EMLNAM)
	   			Else
	   				cNomeEml	:= ft321GeraEML()
		    	EndIf

		    	If nPos > 0 .and. Alltrim(TMPAOF->AOF_LASTMO) == Alltrim(aTarefaEXG[3,nPos,6])
		    		TMPAOF->(dbSkip())
		    		Loop

		    	ElseIf nPos > 0 .and. ft321CompLastMod(TMPAOF->AOF_LASTMO, aTarefaEXG[3,nPos,6])
					//Atualiza Protheus
                  If TMPAOF->(!EOF())
                  	aConvDIni	:= CRM170ConvUTCTime(STOD(StrTran(Substr(aTarefaEXG[3,nPos,_TARDTSTART],1,10),"-","")),Substr(aTarefaEXG[3,nPos,_TARDTSTART],12,8))
		    	    	aConvDFim  := CRM170ConvUTCTime(STOD(StrTran(Substr(aTarefaEXG[3,nPos,_TARDTEND],1,10),"-","")),Substr(aTarefaEXG[3,nPos,_TARDTEND],12,8))
                     aConvDRem  := CRM170ConvUTCTime(STOD(StrTran(Substr(aTarefaEXG[3,nPos,_TARDTREM],1,10),"-","")),Substr(aTarefaEXG[3,nPos,_TARDTREM],12,8))


	                  aConvDIni	:= CRM170ConvUTCTime(STOD(StrTran(Substr(aAgendaEXG[3,nPos,4],1,10),"-","")),Substr(aAgendaEXG[3,nPos,4],12,8))
	                  aConvDFim := CRM170ConvUTCTime(STOD(StrTran(Substr(aAgendaEXG[3,nPos,3],1,10),"-","")),Substr(aAgendaEXG[3,nPos,3],12,8))
			           aExecAuto := {{"AOF_FILIAL" ,xFilial("AOF") 			,Nil}						,;
						 		     	{"AOF_CODIGO" ,TMPAOF->AOF_CODIGO		,Nil}						,;
			           				{"AOF_EMLNAM" ,cNomeEml                ,Nil}						,;
									 	{"AOF_LASTMO",aTarefaEXG[3,nPos,11]	,Nil}						,;
										{"AOF_ASSUNT",aTarefaEXG[3,nPos,1]		,Nil}						,;
									 	{"AOF_DESCRI",aTarefaEXG[3,nPos,2]		,Nil}						,;
									 	{"AOF_DTINIC",aConvDIni[1]				,Nil}						,;
									 	{"AOF_HRINIC",aConvDIni[2]				,Nil}						,;
									 	{"AOF_DTFIM" ,aConvDFim[1]				,Nil}						,;
									 	{"AOF_HRFIM" ,aConvDFim[2]				,Nil}						,;
									 	{"AOF_LOCAL" ,aAgendaEXG[3,nPos,7]		,Nil}						,;
									 	{"AOF_DTLEMB" ,aConvDRem[1]				,Nil}						,;
									 	{"AOF_HRLEMB" ,aConvDRem[2]				,Nil} 	}

						CRMA180( aExecAuto, 4, .T. ) // Alterar Compromisso
		    	    EndIf
		      Else
					//Atualiza Exchange

	    			// Se possui data de ultima modificacao eh porque foi dele deletado no Exchange e deve ser deletado no Protheus
					If !Empty(TMPAOF->AOF_LASTMO) .and. nPos == 0

	     	          aExecAuto := {{"AOF_FILIAL",xFilial("AOF") 		 ,Nil},;
							   			{"AOF_CODIGO" ,TMPAOF->AOF_CODIGO  ,Nil}}
					   CRMA180( aExecAuto, 5, .T. ) // Deletar

	              Else
						//Incluindo pesquisa do AD7 no Exchange.
			    		If f321AtuTarExg("A",aInfoSinc[_PREFIXO,_Usuario], aInfoSinc[_PREFIXO,_SenhaUser],"AOF", lAutomatico)[1]

			    	        //Pesquisa data Lastmodified
			              aTarefaPESQ := ExgConsTasks(aInfoSinc[_PREFIXO,_Usuario], aInfoSinc[_PREFIXO,_SenhaUser],cURL,"", "", "", "",cNomeEml,F321GetLanExg())
							If !(aTarefaPESQ[1])
								aRet := CRM170IntegrationInformation(aTarefaPESQ[2], nil, lAutomatico)
								    TMPAOF->(dbCloseArea())
								Return aRet
							EndIF

							If AOF->(!EOF()) .And. Len(aTarefaPESQ[3]) > 0 //Atualiza  agenda Protheus com o apontamento gerado no Exchange
			     	           aExecAuto := {{"AOF_FILIAL",xFilial("AOF") 		 		,Nil},;
									   			 {"AOF_CODIGO" ,TMPAOF->AOF_CODIGO  		,Nil},;
									   			 {"AOF_LASTMO",StrTran(Alltrim(aTarefaPESQ[3,1,11])," ","%20") 			,Nil},;
									   			 {"AOF_EMLNAM",cNomeEml 		 				,Nil}}
							    CRMA180( aExecAuto, 4, .T. ) // Atualizar
						    EndIf

		    	        EndIF

		    		EndIf
			    EndIf

	    		//Apaga Apontamento gerado no Exchange q ja foi atualizado
	    		If nPos > 0
		       	 nLen := Len(aTarefaEXG[3])
			   	    aDel(aTarefaEXG[3],nPos)
					aSize(aTarefaEXG[3],nLen-1)
				EndIf

		    	TMPAOF->(dbSkip())
			EndDo
		    TMPAOF->(dbCloseArea())


		    //Pesquisa apontamentos gerados no Exchange
		    For nY:=1 to Len(aTarefaEXG[3])

		    	dbSelectArea("AOF")
		    	dbSetOrder(5)
		    	If !AOF->(dbSeek(xFilial("AOF")+aAgendaEXG[3,nY,2]))

		    		If Substr(aAgendaEXG[3,nY,2],1,4) == "TEXG"
						//Cancela apontamento no Exchange pois no protheus ela foi deletada.

						If Substr(aTarefaEXG[3,nY,10],1,4) == "TEXG"
				   			//Cancela apontamento no Exchange pois no protheus ela foi deletada.
	                    aRetCanc :=  ExgDelTasks(aInfoSinc[_PREFIXO,_Usuario], aInfoSinc[_PREFIXO,_SenhaUser], cURL, aTarefaEXG[3,nY,10], F321GetLanExg())
							If !aRetCanc[1]
								aRet := CRM170IntegrationInformation(aRetCanc[2], nil, lAutomatico)
							EndIf
						Else

							Do Case
								Case Alltrim(Str(Val(aTarefaEXG[3,nY,5])+1))  == "NotStarted"		// Não iniciado
									cStatus := "1"
								Case Alltrim(Str(Val(aTarefaEXG[3,nY,5])+1)) == "InProgress"		// Em andamento
									cStatus := "2"
								Case Alltrim(Str(Val(aTarefaEXG[3,nY,5])+1)) == "Completed" 		// Completada
									cStatus := "3"
								Case Alltrim(Str(Val(aTarefaEXG[3,nY,5])+1)) == "WaitingOnOthers" 	// Aguardando Outros
									cStatus := "4"
								Case Alltrim(Str(Val(aTarefaEXG[3,nY,5])+1)) == "Deferred" 			// Adiada
									cStatus := "5"
							EndCase
							Do Case
								Case aTarefaEXG[3,nY,4]  == "0"
									cPercent := "1"
								Case aTarefaEXG[3,nY,4]  == "25"
									cPercent := "2"
								Case aTarefaEXG[3,nY,4] == "50"
									cPercent := "3"
								Case aTarefaEXG[3,nY,4] == "75"
									cPercent := "4"
								Case aTarefaEXG[3,nY,4] == "100"
									cPercent := "5"
							EndCase


			              aExecAuto := {{"AOF_FILIAL",xFilial("AOF")						,Nil}		   						,;
					    			   		{"AOF_DTCAD" ,dDatabase								,Nil}						,;
											{"AOF_EMLNAM" ,aTarefaEXG[3,nY,10]					,Nil}						,;
											{"AOF_LASTMO" ,aTarefaEXG[3,nY,11] 				,Nil}  					,;
											{"AOF_TIPO"  ,TPTAREFA			       			,Nil}						,;
											{"AOF_IDESTN"  ,aNvlEstrut[1]	       			,Nil}						,;
											{"AOF_NVESTN "  ,aNvlEstrut[2]	       			,Nil}						,;
											{"AOF_ASSUNT",aTarefaEXG[3,nY,1]			       ,Nil}						,;
											{"AOF_DESCRI",aTarefaEXG[3,nY,2]					,Nil}						,;
											{"AOF_DTINIC",STOD(StrTran(Substr(aTarefaEXG[3,nY,_TARDTSTART],1,10),"-",""))	,Nil} ,;
											{"AOF_DTFIM" ,STOD(StrTran(Substr(aTarefaEXG[3,nY,_TARDTEND],1,10),"-",""))		,Nil} ,;
											{"AOF_DTLEMB" ,STOD(StrTran(Substr(aTarefaEXG[3,nY,_TARDTREM],1,10),"-",""))		,Nil} ,;
											{"AOF_HRLEMB" ,Substr(aTarefaEXG[3,nY,8],12,8)	,Nil} 						,;
											{"AOF_PERCEN",cPercent      						,Nil}						,;
											{"AOF_PRIORI","2"              						,Nil}						,;
											{"AOF_STATUS",cStatus								,Nil}			            }

							CRMA180( aExecAuto, 3, .T. ) // Importar Tarefa por rotina automatica
			    		EndIf
			    	EndIf
		     	EndIf
		    Next nY
		EndIf
	EndIf
EndIf

Return aRet

//----------------------------------------------------------
/*/{Protheus.doc} CRM170ATLZ()

Faz a validação dos dados e encaminha para a função de sincronismo do exchange....

@param	  ExpA1 = Array contendo as informações do exchange
          ExpC1 = URL do servidor do exchange que será utilizado
          ExpC2 = Operação que deverá ser realizada na sincronização ('A'=Alteração/Inclusão', 'D'=Delete)
          ExpL2 = Indica se deverá mostrar mensagem

@return   Nenhum

@author   Victor Bitencourt
@since    21/02/2014
@version  12.0
/*/
//----------------------------------------------------------
Function CRM170ATLZ(aInfoSinc, cURL, cOperation, lMsg)

Local aArea 		:= GetArea()
Local cAlias 		:= "AOF"   // tabela de Atividades
Local cUserExg		:= ""
Local cSenhaExg		:= ""
Local aRetExg		:= {}
Local lCompromis  	:= .F.
Local lTarefa     	:= .F.
Local lAutomatico	:= .F.

If !Empty(cAlias)
	If !Empty(cUrl) //exchange
		If Empty(cUserExg)
		    If aInfoSinc[1]
				cUserExg	:= aInfoSinc[_PREFIXO,_Usuario]
				cSenhaExg	:= aInfoSinc[_PREFIXO,_SenhaUser]
				lCompromis  := aInfoSinc[_PREFIXO,_Agenda]
				lTarefa     := aInfoSinc[_PREFIXO,_Tarefa]
				lAutomatico := aInfoSinc[_PREFIXO,_Habilita]
				If !Empty(cSenhaExg)
				   If cOperation  $ "AD"
				   		If lMsg
				   			FwMsgRun(,{|| aRetExg := CRM170AtuAtiv(cOperation,cUserExg,cSenhaExg,cAlias,lAutomatico,lCompromis,lTarefa )[1] },Nil,STR0060) //"Enviando alterações para o Exchange..."
			   			Else
			   				aRetExg := CRM170AtuAtiv(cOperation,cUserExg,cSenhaExg,cAlias,lAutomatico,lCompromis,lTarefa )[1] //"Aguarde"//"Enviando alterações para o Exchange..."
			   			EndIf
			   	   EndIf
			   	EndIf
			 EndIf
		EndIF
	EndIf
EndIf

RestArea(aArea)

Return

//----------------------------------------------------------
/*/{Protheus.doc} CRM170AtuAtiv()

Atualiza/Inclui/Deleta os registros das Atividades do Protheus para o Exchange...


@param		ExpC1 = Comando que deverá ser executado na sincronização.. ('A'=Alteração , 'D'=Delete)
            ExpC2 = usuario do echange
            ExpC3 = Senha do usuario do exchange
            ExpC4 = Alias da tabela do Protheus
            ExpL1 = Indica se asincronização é automatica
            ExpL2 = Indica se asincronização de Compromisso é automatica
            ExpL3 = Indica se asincronização de Tarefa é automatica

@Return  Array Contendo dados da sincronização..

@author  Victor Bitencourt
@since   21/02/2014
@version 12.0
/*/
//----------------------------------------------------------
Static Function CRM170AtuAtiv(cCommand,cUserEXG,cSenhaEXG,cAlias, lAutomatico, lCompromis, lTarefa, dDataIni, dDataFim )

Local aRetorno      	:= {}
Local cVersaoExchange 	:= GetMv("MV_VEREXCH",,"")
Local aRet				:= {.T., ""}
Local cPorcentagem    	:= ""
Local aEmails			 := {}

Default lAutomatico   	:= .F.
Default lCompromis		:= .F.
Default lTarefa 		:= .F.
Default dDataIni		:= dDataBase
Default dDataFim		:= dDataBase

If Val(cVersaoExchange) < 2007 //Exchange versao anterior a 2007

	aRet := CRM170VerAnt(cCommand,cUserEXG,cSenhaEXG,cAlias, lAutomatico)

Else  //Exchange 2007 e superiores

	If cCommand == "A" //Incluir ou alterar agendas no Exchange

		If Empty(AOF->AOF_IDEXC)//Inclusao de registros no Exchange

			If AOF->AOF_TIPO == TPCOMPROMISSO .AND. lCompromis .And. ( AOF->AOF_DTINIC >= dDataIni .And. AOF->AOF_DTINIC <= dDataFim ) //Inclusao de Compromisso, verifica tambem se é para ser sicronizado com exchange
 
				If !Empty( AOF->AOF_PARTIC )
					aEmails := StrTokArr( AllTrim( AOF->AOF_PARTIC ), ",;" )
				EndIf
				aRetorno := EX07_Meet1(	AllTrim(cUserEXG),;
											AllTrim(cSenhaEXG),;
											AOF->AOF_ASSUNT,;
											AOF->AOF_DESCRI,;
											AOF->AOF_DTINIC,;
											AOF->AOF_HRINIC,;
											AOF->AOF_DTFIM,;
											AOF->AOF_HRFIM,;
											AOF->AOF_LOCAL,;
											aEmails		,;
											IIF( !Empty( aEmails ),"R",""),;
											AOF->(RecNo());
										       )

		    ElseIf AOF->AOF_TIPO == TPTAREFA .AND. lTarefa .AND. AOF->AOF_DTINIC >= dDataIni  //Inclusao de Tarefa, verifica tambem se é para ser sicronizado com exchange  --     Passar data inicio fim 

				Do Case
					Case AOF->AOF_PERCEN == "1"
						cPorcentagem := "0"
					Case AOF->AOF_PERCEN == "2"
						cPorcentagem := "25"
					Case AOF->AOF_PERCEN == "3"
						cPorcentagem := "50"
					Case AOF->AOF_PERCEN == "4"
						cPorcentagem := "75"
					Case AOF->AOF_PERCEN == "5"
						cPorcentagem := "100"
					OtherWise
					  	cPorcentagem := "0"
				EndCase

				aRetorno := EX07_Task1(	Alltrim(cUserEXG),;
											ALltrim(cSenhaEXG),;
											AOF->AOF_ASSUNT,;
											AOF->AOF_DESCRI,;
											AOF->AOF_DTINIC,;
											AOF->AOF_DTFIM ,;
											AOF->AOF_HRINIC,;
											AOF->AOF_HRFIM ,;
											IIF(!Empty(AOF->AOF_STATUS),AOF->AOF_STATUS,"1"),;
											IIF(!Empty(AOF->AOF_PRIORI),AOF->AOF_PRIORI,"2"),;
											cPorcentagem   ,;
											AOF->AOF_DTLEMB ,;
											AOF->AOF_HRLEMB )

		    EndIf

			If !Empty(aRetorno) .AND. aRetorno[1] .AND. !Empty(aRetorno[3]) //Atualiza a agenda do sistema com o ID da Agenda do Exchange
				RecLock("AOF",.F.)
					AOF->AOF_IDEXC 	:= aRetorno[3]
					AOF->AOF_CHGKEY	:= aRetorno[4]
				MsUnlock()
			EndIf

		ElseIf !Empty(AOF->AOF_IDEXC)//Alteracao de registros no Exchange

			If AOF->AOF_TIPO == TPCOMPROMISSO .AND. lCompromis//Alteracao de Compromisso, verifica tambem se é para ser sicronizado com exchange

				If !Empty( AOF->AOF_PARTIC )
					aEmails := StrTokArr( AllTrim( AOF->AOF_PARTIC ), ",;" )
				EndIf	
				aRetorno := EX07_Meet2(	AllTrim(cUserEXG),;
											AllTrim(cSenhaEXG),;
											AOF->AOF_ASSUNT,;
											AOF->AOF_DESCRI,;
											AOF->AOF_DTINIC,;
											AOF->AOF_HRINIC,;
											AOF->AOF_DTFIM,;
											AOF->AOF_HRFIM,;
											AOF->AOF_LOCAL,;
											aEmails		,;
											IIF( !Empty( aEmails ),"R",""),;
											AOF->AOF_IDEXC,;
											AOF->AOF_CHGKEY )

			ElseIf AOF->AOF_TIPO == TPTAREFA .AND. lTarefa //Alteracao de Tarefa, verifica tambem se é para ser sicronizado com exchange

				Do Case
					Case AOF->AOF_PERCEN == "1"
						cPorcentagem := "0"
					Case AOF->AOF_PERCEN == "2"
						cPorcentagem := "25"
					Case AOF->AOF_PERCEN == "3"
						cPorcentagem := "50"
					Case AOF->AOF_PERCEN == "4"
						cPorcentagem := "75"
					Case AOF->AOF_PERCEN == "5"
						cPorcentagem := "100"
					OtherWise
					  	cPorcentagem := "0"
				EndCase

				aRetorno := EX07_Task3(	Alltrim(cUserEXG) ,;
											ALltrim(cSenhaEXG),;
											AOF->AOF_ASSUNT ,;
											AOF->AOF_DESCRI ,;
											AOF->AOF_DTINIC ,;
											AOF->AOF_DTFIM  ,;
											AOF->AOF_HRINIC ,;
											AOF->AOF_HRFIM  ,;
											AOF->AOF_IDEXC  ,;
											AOF->AOF_CHGKEY,;
											AOF->AOF_STATUS,;
											AOF->AOF_PRIORI,;
											cPorcentagem   ,;
											AOF->AOF_DTLEMB,;
											AOF->AOF_HRLEMB )

				If !Empty(aRetorno) .AND. aRetorno[1] .AND. !Empty(aRetorno[3]) //Atualiza o registro do sistema com o ID do Exchange
					RecLock("AOF",.F.)
						AOF->AOF_IDEXC 	:= aRetorno[3]
						AOF->AOF_CHGKEY	:= aRetorno[4]
					MsUnlock()
				EndIf

			EndIf

		EndIf

	ElseIf cCommand == "D" 	//Apagar Registros do Exchange

		If AOF->AOF_TIPO == TPCOMPROMISSO .AND. lCompromis
			aRetorno  := EX07_Meet3(AllTrim(cUserEXG),AllTrim(cSenhaEXG),AOF->AOF_IDEXC,AOF->AOF_CHGKEY)
		ElseIf AOF->AOF_TIPO == TPTAREFA .AND. lTarefa
		   aRetorno   := EX07_Task2(Alltrim(cUserEXG),ALltrim(cSenhaEXG),AOF->AOF_IDEXC,AOF->AOF_CHGKEY)
		EndIf

	EndIf

	If Len(aRetorno) > 0 .AND. !aRetorno[1]
		aRet := CRM170IntegrationInformation(STR0061,aRetorno[2],lAutomatico) // //"Não foi possível efetuar a integração com exchange, tente novamente mais tarde ou se o problema persistir, contate o administrador do sistema!"
	EndIf

EndIf

Return aRet

//----------------------------------------------------------
/*/{Protheus.doc} CRM170VerAnt()

Atualiza atividades de atividades

@param		ExpC1 = Comando que deverá ser executado na sincronização.. ('A'=Alteração , 'D'=Delete)
            ExpC2 = usuario do echange
            ExpC3 = Senha do usuario do exchange
            ExpC4 = Alias da tabela do Protheus
            ExpL1 = Indica se asincronização é automatica


@Return nil
@author Vendas CRM
@since 31/07/2013
/*/
//----------------------------------------------------------
Static Function CRM170VerAnt(cCommand,cUserEXG,cSenhaEXG,cAlias, lAutomatico)

Local cCodUsr	:= IIF(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr()) 
Local cURL		:= CRM170UrlE() //retorna a url de integração com exchange
Local aAreaAO3	:= AO3->(GetArea())
Local aExecAuto	:= {}

Private lMsErroAuto := .F.

cEmailV := Alltrim(Posicione("AO3",1,xFilial("AO3")+cCodUSR,"AO3_EXGEMA"))
If cCommand == "D"
	If AOF->AOF_AGEREU == "R"
		//Cancela reuniao
		aRetEXG :=  ExgCancMeetingFunction(cUserEXG						,;
												cSenhaEXG						,;
												cURL							,;
												cEmailV						,;
												AOF->AOF_PARTIC			   ,;
												""								,;
												STR0062		,;  //"Cancelamento Reuniao."
												STR0063 + Alltrim(AOF->AOF_ASSUNT),; //"Cancelamento automatico da Reuniao: "
												AOF->AOF_EMLNAM						,;
												F321GetLanExg()				)
	Else
		aRetEXG :=  ExgDelAppointment(cUserEXG, cSenhaEXG, cURL, AOF->AOF_EMLNAM,F321GetLanExg())
	EndIf
ElseIf cCommand == "A"
	If AOF->AOF_AGEREU == "A"
	    	aRetEXG := ExgCrtAppointment(	cUserEXG			,; 	// Usuario
											cSenhaEXG				,;	// Senha
											cURL					,;	// URL
											AOF->AOF_DTINIC			,;	// Data Inicio
											AOF->AOF_DTFIM				,;	// Data Fim
											ft321VldHora(AOF->AOF_HRINIC)	,;	// Hora Inicio
											ft321VldHora(AOF->AOF_HRFIM)	,;	// Hora Fim
											AOF->AOF_ASSUNT				,;	// Subject
											AOF->AOF_DESCRI				,;	// Descricao
											AOF->AOF_LOCAL				,;	// Local
											AOF->AOF_EMLNAM				,;	// Nome do arquivo .EML
																	,;
																	,;
																	,;
																	,;
																	,;
											F321GetLanExg()			)	// Idioma do exchange
	Else
		aRetEXG := ExgCrtMeeting(	cUserEXG			,;	// Usuario
									cSenhaEXG				,;	// Senha
									cURL					,;	// URL
									Alltrim(cEmailV )  	,;	// TO
									AOF->AOF_PARTIC				,;	// CC
									""						,;	// BCC
									AOF->AOF_DTINIC				,;	// Data Inicio
									AOF->AOF_DTFIM				,;	// Data Fim
									ft321VldHora(AOF->AOF_HRINIC)	,;	// Hora Inicio
									ft321VldHora(AOF->AOF_HRFIM)	,;	// Hora Fim
									AOF->AOF_ASSUNT				,;	// Subject
									AOF->AOF_DESCRI				,;	// Descricao
									AOF->AOF_LOCAL				,;	// Local
									AOF->AOF_EMLNAM				,;	// Nome do arquivo .EML
															,;
															,;
															,;
															,;
															,;
									F321GetLanExg()			)	// Idioma do exchange
	EndIf
EndIf

If !Empty(aRetEXG) .AND. aRetEXG[1]
    //Pesquisa data Lastmodified
	aAgendaPESQ := ExgConsAppointment(cUserEXG, cSenhaEXG, cURL,,,,,AOF->AOF_EMLNAM,F321GetLanExg())
    If (aAgendaPESQ[1]) .And. Len(aAgendaPESQ[3]) > 0
		//Atualiza  agenda Protheus com o apontamento gerado no Exchange
  	   		aExecAuto := {{"AOF_FILIAL",xFilial("AOF")                     ,Nil} ,;
   							{"AOF_CODIGO",AOF->AOF_CODIGO                    ,Nil} ,;
							{"AOF_LASTMO",aAgendaPESQ[3,1,_LASTMOD]   		,Nil} ,;
							{"AOF_EMLNAM",cNomeEml                           ,Nil}}
			CRMA180( aExecAuto, 4, .T. )
    Else
		aRet := CRM170IntegrationInformation(aAgendaPESQ[2],"",lAutomatico) 
    EndIf
EndIf
If !Empty(aRetEXG) .AND. !aRetEXG[1]
	aRet := CRM170IntegrationInformation(aRetEXG[2],"",lAutomatico)
EndIf

RestArea(aAreaAO3)

Return( aRet )


//----------------------------------------------------------
/*/{Protheus.doc} CRM170ConsEnt()

Função para  para consulta especifica, que mostra os registros conforme o alias escolhido pelo usuario e
guarda o x2 unico do registro na variavel estatica 'cChvReg'

@param		Nenhum

@return    lRetorno

@author 	Victor Bitencourt
@since 		28/02/2014
@version 	12.0
/*/
//----------------------------------------------------------
Function CRM170ConsEnt()

Local lRetorno 	:= .F.
Local cAlias 		:=  ""
Local aDadSX2 	:= {}

Local oModel      := FwModelActive()

//variavel de retorno para consulta especifica
Static cChvReg := ""

If oModel <> Nil .AND. oModel:cId == "CRMA180"
	cAlias 	:= FwFldGet("AOF_ENTIDA")
	aDadSX2 	:= CRMXGetSX2(cAlias)

	If !Empty(cAlias)
		If Conpad1(,,,cAlias)
			If Len(aDadSX2) > 0
				cChvReg := (cAlias)->&(aDadSX2[1])
				lRetorno := .T.
			EndIf
		EndIf
	Else
		MsgAlert(STR0064)//"Selecione uma entidade para vincular um registro nesta atividade!"
	EndIf
Else
	MsgAlert(STR0119)//"Model de Atividades não está ativo !"
EndIf

Return lRetorno


//----------------------------------------------------------
/*/{Protheus.doc} CRMA170RChv()

Função para retornar o valor da variavel 'cChvReg' obtido na consulta padrão (especifica) CRM170ConsEnt

@Return cChvReg

@author 	Victor Bitencourt
@since 		28/02/2014
@version 	12.0
/*/
//----------------------------------------------------------
Function CRMA170RChv()
Return (cChvReg)


//----------------------------------------------------------
/*/{Protheus.doc} CRMA170EXG()

Função que chama a sincronização com o exchange enviando os parametros ...

se o parametro aInfo for vazio, a rotina cria um array com os dados cadastrados do usuario,
caso o parametro aInfo for passado com valor  a rotina utilizará os dados o array para fazer a sicronização


@param      ExpL1 = Indica se é uma sincronização automatica
             ExpA1 = Array com os dados do usuario do exchange, se a função receber esse array
                      os dados dele que seram utlizados para fazer a sincronização


@return  Array contendo dois elementos :
                 1° elemento = contem um array com os dados do usuario do exchange
                 2° elemento = contem um array com as informações da sincronização

@author   Victor Bitencourt
@since    26/02/2014
@version  12.0
/*/
//----------------------------------------------------------
Function CRMA170EXG(lSinAut,aInfo)

Local aRetSinc  := {}
Local aInfoUser := {}

Default lSinAut := .F.

If lSinAut .AND. Empty(aInfo)
	aInfoUser := CRM170GetS(lSinAut)
ElseIf !Empty(aInfo)
   aInfoUser := aClone(aInfo)
EndIf

If aInfoUser[1]
	aRetSinc := CRM170SAT( aInfoUser[_PREFIXO][_Usuario]   ,aInfoUser[_PREFIXO][_SenhaUser] ,aInfoUser[_PREFIXO][_Agenda],;
						   	  aInfoUser[_PREFIXO][_DtAgeIni]  ,aInfoUser[_PREFIXO][_DtAgeFim]  ,aInfoUser[_PREFIXO][_Tarefa],;
                           aInfoUser[_PREFIXO][_DtTarIni]  ,aInfoUser[_PREFIXO][_DtTarFim]  ,aInfoUser[_PREFIXO][_EndEmail],;
                           aInfoUser[_PREFIXO][_Contato]   ,aInfoUser[_PREFIXO][_Habilita]  ,aInfoUser[_PREFIXO][_TipoPerAge],;
                           aInfoUser[_PREFIXO][_TipoPerTar],aInfoUser[_PREFIXO][_TimeMin]   ,aInfoUser[_PREFIXO][_BiAgenda],;
                           aInfoUser[_PREFIXO][_BiTarefa]  ,aInfoUser[_PREFIXO][_BiContato] ,.T.,.T.)

	If !aRetSinc[1]
		CRM170IntegrationInformation(STR0061,aRetSinc[2],lSinAut) 
		If '401' $ aRetSinc[2] .AND. lSinAut
			aInfoUser :=  CRM170GetS(.F.)
		EndIf
	ElseIf aRetSinc[1] .AND. ( FunName() == "CRMA180" .Or. FunName() == "CRMA290" )
		// chama essa rotina, somente se houver conexão com exchange, envia Compromisso/Tarefa
		FwMsgRun(,{|| aRetSinc := CRM170BuAtiv(aInfoUser),IIF(aRetSinc[1],aRetSinc := CRM170SINCAUT(aInfoUser,lSinAut), Nil ) },Nil,STR0068) //"Atualizando Atividades..."
	EndIf
EndIf

Return {aInfoUser,aRetSinc}


//----------------------------------------------------------
/*/{Protheus.doc} CRM170VldH()

Função para validar as datas digitadas horarios das atividades

@param	  Nenhum

@return  lRet

@author   Victor Bitencourt
@since    28/02/2014
@version  12.0
/*/
//----------------------------------------------------------
Function CRM170VldH()   

Local lRet 		:= .T.
Local dInicio   := sTod("")   
Local dFinal	:= sTod("")  
Local cHrInicio	:= ""
Local cHrFinal	:= ""    
Local cReadVar	:= ReadVar()

If Type("lCRM180Aut") == "U"
	lCRM180Aut	:= .F.
Endif

If !lCRM180Aut .Or. ( lCRM180Aut .And. cReadVar $ "AOF_DTFIM|AOF_HRFIM" )
	dInicio		:= FwFldget("AOF_DTINIC")
	dFinal      := FwFldget("AOF_DTFIM")
	cHrInicio	:= FwFldget("AOF_HRINIC")
	cHrFinal    := FwFldget("AOF_HRFIM")  
	If Empty(cHrInicio)
		cHrInicio := "00:00"	  
	EndIf
	If Empty(cHrFinal)
		cHrFinal := cHrInicio
	EndIf
	If !AtVldDiaHr( dInicio, dFinal , cHrInicio, cHrFinal )
		lRet := .F.
		Help( " ", 1, "CRM170VLDH", ,STR0121,1,1,,,,,,{STR0122} ) //"Data / Hora inválida." # "Verifique o período dos campos Data Inicial, Hora Inicial, Data Final e Hora Final estão preenchidos corretamente."
	EndIf  
EndIf 
 
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} CRM170UrlE()

Função para pegar a url e os parametros para sincronização do exchange

@param	  ExpL1 = Indica se a sincronização é automatica

@return  String contendo a url do servidor exchange que será ultilizado na sincronização

@author   Victor Bitencourt
@since    28/02/2014
@version  12.0
/*/
//----------------------------------------------------------
Function CRM170UrlE(lAutomatico)

Local cRet   := ""

Default lAutomatico := .F.

//Versoes anteriores ao Exchange 2007
If Val(SuperGetMv("MV_VEREXCH",,"")) < 2007
	cRet	:= AllTrim( SuperGetMV("MV_URLEXG",,"") )
	If Empty(cRet)
		CRM170IntegrationInformation(STR0069, Nil, lAutomatico) //"Atenção, para a utilização da versão do Exchange Anterior a 2007, é necessário informar o parâmetro MV_URLEXG com a URL do WSDL de integração."
	EndIf
Else	
	If Val( SuperGetMv("MV_VEREXCH",,"") ) == 2007
		cRet	:= SuperGetMV("MV_URLEWS",,"")
		If Empty(cRet)
			cRet	:= AllTrim( SuperGetMV("MV_EWS2007",,"") )
			If Empty( cRet )
				CRM170IntegrationInformation(STR0120, Nil, lAutomatico) //"Atenção, para a utilização da versão do Exchange 2007, é necessário informar o parâmetro MV_EWS2007 com a URL do WSDL de integração."
			EndIf 
		EndIf
	ElseIf Val( SuperGetMv("MV_VEREXCH",,"") ) >= 2010
		cRet	:= AllTrim( SuperGetMV("MV_EWS2010",,"") ) 
		If Empty(cRet)
			CRM170IntegrationInformation(STR0070, Nil, lAutomatico) //"Atenção, para a utilização da versão do Exchange maior que 2007, é necessário informar o parâmetro MV_EWS2010  com a URL do WSDL de integração."
		EndIf
	EndIf
EndIf

Return( cRet )

//----------------------------------------------------------
/*/{Protheus.doc} CRM170IntegrationInformation()

Função que retorna uma mensagem de informação de alguma ocorrencia na sincronização

@param	   ExpC1 = Mensagem da sincronização
           ExpC2 = detalhe da Sincronização
           ExpL1 = Indica se asincronização é automatica

@return   aRet - Array contendo informações da sincronização

@author   Victor Bitencourt
@since    28/02/2014
@version  12.0
/*/
//----------------------------------------------------------
Function CRM170IntegrationInformation(cMensagem, cDetalhe, lAutomatico)

Local oDlgII				:= Nil
Local oFntTit				:= Nil
Local oFntMsg				:= Nil
Local oBmp					:= Nil
Local oMsgDet				:= Nil
Local lTelaDetalhe			:= .F.
Local lExibeBotaoDetalhe	:= .T.
Local aRet					:= {}

Default lAutomatico := .F. //se for chamado por thread (sincronizacao automatica) nao exibe mensagem de erro
Default cMensagem 	:= ""
Default cDetalhe  	:= ""

aRet := { .F., cMensagem + CRLF + CRLF + cDetalhe }


If Empty(cDetalhe)
	lExibeBotaoDetalhe := .F.
EndIf

If !lAutomatico
	DEFINE MSDIALOG oDlgII TITLE STR0071 FROM 0,0 TO 130,600 PIXEL  //"Integração com Exchange"

	DEFINE FONT oFntTit NAME "Arial"  SIZE 6,16	BOLD
	DEFINE FONT oFntMsg NAME "Arial"  SIZE 5,15

	@ 0,0  BITMAP oBmp RESNAME STR0072 oF oDlgII SIZE 100,600 NOBORDER WHEN .F. PIXEL //"LOGIN"
	@05,60 TO 45,300 PROMPT STR0073 PIXEL //"Informação"
	@13,62 GET cMensagem FONT oFntMsg MULTILINE NOBORDER READONLY HSCROLL SIZE 236,30 PIXEL

	@50,200 BUTTON STR0074 PIXEL ACTION oDlgII:End() //"OK"

	If lExibeBotaoDetalhe
		@50,230 BUTTON STR0075 PIXEL ACTION If(	!lTelaDetalhe,;  //"Detalhes"
		(oDlgII:ReadClientCoors(.T.),oDlgII:Move(oDlgII:nTop,oDlgII:nLeft,oDlgII:nWidth,oDlgII:nHeight+165,,.T.),lTelaDetalhe:=.T.),;
		(oDlgII:ReadClientCoors(.T.),oDlgII:Move(oDlgII:nTop,oDlgII:nLeft,oDlgII:nWidth,oDlgII:nHeight-165,,.T.),lTelaDetalhe:=.F.))
		@ 67,60 TO 140,300 PROMPT STR0076 PIXEL  //"Detalhes da informação:"
		@ 75,62 GET oMsgDet VAR cDetalhe FONT oFntMsg MULTILINE NOBORDER READONLY HSCROLL SIZE 236,63 PIXEL
	EndIf

	ACTIVATE MSDIALOG oDlgII CENTERED

EndIf

Return aRet

//----------------------------------------------------------
/*/{Protheus.doc} CRM170BuAtiv()

Busca atividades que não puderam ser sicronizadas com exchange devido a falta de conexão,
e envia essas atividades para serem sincronizadas.

@param	  ExpA1 = Array contendo informações do usuario do exchange...

@return   aRet - Retorno do status da sincronização

@author   Victor Bitencourt
@since    26/02/2014
@version  12.0
/*/
//----------------------------------------------------------

Function CRM170BuAtiv(aInfoUser)

Local cQuery      := ""
Local aAreaAOF    := {}
Local aRet        := {.T.,""}
Local aArea       := GetArea()
Local lCompromis  := aInfoUser[_PREFIXO][_Agenda]
Local lTarefa     := aInfoUser[_PREFIXO][_Tarefa]
Local lAutomatico := aInfoUser[_PREFIXO][_Habilita]
Local dDataInic	  := aInfoUser[2][7]
Local dDataFim	  := aInfoUser[2][8]
Local cCodUsr	  := IIF(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr()) 	

If Select("AOF") > 0
	aAreaAOF := AOF->(GetArea())
Else
	DbSelectArea("AOF")
EndIf
AOF->(DbSetOrder(1))//AOF_FILIAL+AOF_CODIGO

cQuery := " SELECT AOF_CODIGO FROM " +RetSqlName("AOF")+" Where AOF_FILIAL = '"+xFilial("AOF")+"' AND AOF_CODUSR = '"+ cCodUsr +"'"
cQuery += " AND AOF_TIPO IN ('"+TPTAREFA+"','"+TPCOMPROMISSO+"') AND AOF_IDEXC = '' AND AOF_CHGKEY = '' AND D_E_L_E_T_ = '' "

If !Empty(cQuery)
	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery NEW ALIAS "TMPAOF"
	While TMPAOF->(!Eof())
		If AOF->(DbSeek(xFilial("AOF")+TMPAOF->AOF_CODIGO))
			aRet := CRM170AtuAtiv("A",aInfoUser[_PREFIXO][_Usuario],aInfoUser[_PREFIXO][_SenhaUser],"AOF",lAutomatico,lCompromis,lTarefa, dDataInic, dDataFim)
			If !Empty(aRet) .AND. !aRet[1]
				exit
			EndIf
		EndIf
		TMPAOF->(dbSkip())
	EndDo
	TMPAOF->(DBCloseArea())
EndIf

If !Empty(aAreaAOF)
	RestArea(aAreaAOF)
EndIf

RestArea(aArea)

Return aRet

//----------------------------------------------------------
/*/{Protheus.doc} CRM170INIC()

Rotina para inicializar o campo AOF_DESCRE

@param	   Nenhum

@return   cRet -  valor do Display da tabela

@author   Victor Bitencourt
@since    26/02/2014
@version  12.0
/*/
//----------------------------------------------------------
Function CRM170INIC(cAlias, cChave)

Local aAreaAl  := {}	
Local aArea    := {}
Local cDisplay := ""
Local cRet     := ""

Default cAlias := ""
Default cChave := ""

If !Empty(cAlias) .AND. !Empty(cChave)

	aAreaAl  := (cAlias)->(GetArea())
	aArea    := GetArea()
	cDisplay := CRMXGetSX2( cAlias )[2]
	
	dbSelectArea(cAlias)
	(cAlias)->(DbSetOrder(1))
	
	If (cAlias)->(Dbseek(xFilial(cAlias)+AllTrim(cChave)))
		cRet :=  (cAlias)->&(cDisplay)
	EndIf

	RestArea(aAreaAl)
	RestArea(aArea)

EndIf

Return cRet

//----------------------------------------------------------
/*/{Protheus.doc} CRM170CALPER()

Rotina para inicializar o campo

@param	   Nenhum

@return   cRet - Valor do Display da  tabela

@author   Victor Bitencourt
@since    26/02/2014
@version  12.0
/*/
//----------------------------------------------------------
Function CRM170CALPER()

Local cAlias   := FWFLDGET("AOF_ENTIDA")
Local aAreaAl  := (cAlias)->(GetArea())
Local aArea    := GetArea()
Local cDisplay := CRMXGetSX2( cAlias )[2]
Local cRet     := ""

DBSelectArea(cAlias)
(cAlias)->(DbSetOrder(1))

If (cAlias)->(Dbseek(xFilial(cAlias)+AllTrim(FWFLDGET("AOF_CHAVE"))))
	cRet :=  (cAlias)->&(cDisplay)
EndIf

RestArea(aAreaAl) 
RestArea(aArea)

Return( cRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM170CAHR
Calcula o período de duracao passando data e hora de início e data e hora de término.

@sample 	TKCalcPer(dDtIni,cHrIni,dDtFim,cHrFim)

@param		dDtIni 	Data de Início do Período
			cHrIni	Hora de Início do Período
			dDtFim	Data de Término do Período
			cHrFim Hora de Término do Período

@return	Duração em Horas

@author	Victor Bitencourt
@since		14/03/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRM170CAHR(dDtIni,cHrIni,dDtFim,cHrFim)

Local nHoras     := 0		//tempo de duracao em horas e minutos
Local oDatetime1 := Nil		//Objeto Datetime Inicial
Local oDatetime2 := Nil		//Objeto Datetime Final

If Empty(dDtFim)
	dDtFim := DDATABASE
	cHrFim := SubStr(Time(),1,5)
ElseIf !Empty(dDtFim) .AND. Empty(cHrFim)
	cHrFim := "23:59"
EndIf

If !(Empty(dDtIni) .and. Empty(cHrIni)) .and. dDtFim >= dDtIni
	//Instancia os objetos data início e data fim
	oDatetime1 := TMKDateTime():New()
	oDatetime1 := TMKDateTime():This(dDtIni,cHrIni+':00')
	oDatetime2 := TMKDateTime():New()
	oDatetime2 := TMKDateTime():This(dDtFim,cHrFim+':00')

	//Calula as horas e minutos
	nHoras := Round(oDatetime1:diffInHours(oDatetime2,.T.,.T.,.T.),2)

EndIf

Return( nHoras )

//------------------------------------------------------------------------------
/*/{Protheus.doc} SINCRONIZA()

Função para encaminhar os dados usuario Exchange para a rotina "CRMA170EXG"
assim centralizando as sincronizações..

@return	aRet - Array com as informações da sincronização

@author	Victor Bitencourt
@since		14/03/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Static Function SINCRONIZA(cUser,cSenhaUsu,lAgenda,dDtAgeIni,dDtAgeFim,lTarefa,;
           					dDtTarIni,dDtTarFim,cEndEmail,lContato,lHabilita,cTipoPerAge,cTipoPerTar,;
           					cTimeMin,lBiAgenda, lBiTarefa, lBiContato, lAutomatico)

Local aInfoUser := {}
Local aRet := {}

aInfoUser := {.T.,{cUser,AllTrim(cSenhaUsu),;
                    lAgenda,dDtAgeIni,dDtAgeFim,;
                    lTarefa,dDtTarIni,dDtTarFim,;
                    cEndEmail, lContato,lHabilita,;
                    cTipoPerAge,cTipoPerTar,cTimeMin,;
                    lBiAgenda, lBiTarefa, lBiContato}}


aRet := CRMA170EXG(lAutomatico,aInfoUser)[2]

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM170ConvUTCTime()

função para data e hora

@return	array contendo os dados da sincronização

@author	Victor Bitencourt
@since		13/03/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Static Function CRM170ConvUTCTime(dData,cHora)

Local aRet	:= {}

aRet := ExecInClient( 400, {"UTCtoLocalTime", DTOS(dData), cHora} )
If Len(aRet)>0
	aRet[1] := STOD(aRet[1])
EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} SendEmailSCH()

Função ultilizada para buscar email pendentes e reenviar .
essa função é chamada automaticamente por schedule.

@param	    Nenhum

@return	Nenhum

@author	Victor Bitencourt
@since		17/03/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Static Function SendEmailSCH()

Local cQuery      := ""
Local cUser       := ""
Local cPass       := ""
Local cRemetente  := ""
Local aAreaAOF    := {}
Local aAreaAO3    := {}

If Select("AOF") > 0
	aAreaAOF := AOF->(GetArea())
Else
	DbSelectArea("AOF") 
EndIf
If Select("AO3") > 0
	aAreaAO3 := AO3->(GetArea())
Else
	DbSelectArea("AO3")// Usuario do CRM 
EndIf

AOF->(DbSetOrder(1))//AOF_FILIAL+AOF_CODIGO
AO3->(DbSetOrder(1))//AO3_FILIAL+AO3_CODUSR

cQuery := " SELECT AOF_CODIGO FROM " +RetSqlName("AOF")+" Where AOF_TIPO = '"+TPEMAIL+"'"
cQuery += " AND AOF_STATUS = '"+STPENDENTE+"' AND D_E_L_E_T_ <> '*' "

If !Empty(cQuery)
	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery NEW ALIAS "TMPAOF"
	While TMPAOF->(!Eof())
		If AOF->(DbSeek(xFilial("AOF")+TMPAOF->AOF_CODIGO))
			If AO3->(DbSeek(xFilial("AO3")+AOF->AOF_CODUSR))
				cUser  := AO3->AO3_EXGUSR
		 		cPass  := FWAES_decrypt(Decode64(AllTrim(AO3->AO3_SNAEXG)))
  				If Empty(AOF->AOF_REMETE)
  					cRemetente := AO3->AO3_EXGEMA
  					If Empty(cRemetente)
	  					cRemetente := UsrRetMail(AOF->AOF_CODUSR)
	  				EndIf
	  			Else
	  				cRemetente := AOF->AOF_REMETE	
	  			EndIf
			EndIf
			// verificando se o email foi enviado com sucesso
			If CRMXEnvMail(cRemetente,AOF->AOF_DESTIN,AOF->AOF_PARTIC,"",AOF->AOF_ASSUNT,AOF->AOF_DESCRI,"AOF",AOF->AOF_CODIGO,.T.,cUser,cPass)
				CRM170ATLS(AOF->AOF_CODIGO,STENVIADO)// atualiza status da atividade
			EndIf
		EndIf
		TMPAOF->(dbSkip())
	EndDo
	TMPAOF->(DBCloseArea())
EndIf

If !Empty(aAreaAOF)
	RestArea(aAreaAOF)
EndIf

If !Empty(aAreaAO3)
	RestArea(aAreaAO3)
EndIf


Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM170EMAI()

Função que gera atividade para email e envia o email

@param		ExpC1 - Rementente
			ExpC2 - Destinatario
			ExpC3 - Copia
			ExpC4 - Copia Oculta
			ExpC5 - Assunto
			ExpC6 - Mensagem / Texto
			ExpC7 - Entidade da conta que está sendo processada
			ExpC8 - Codigo da conta que está sendo processada
			ExpC9 - Loja da conta que está sendo processada

@return	Nenhum

@author	Victor Bitencourt
@since		18/03/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRM170EMAI(cFrom, cTo, cCc, cBcc, cSubject, cBody, cEntida, cCodigo, cLoja)

Local aAreaAOF    := {}
Local cCodUsr	  := IIF(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr()) 	
Local aNvlEstrut  := CRMXNvlEst(cCodUsr)
Local aDadUsr     := CRM170GetS(.T.) // Retorna alguns dados do usuario do crm

Local cUser       := ""
Local cPass       := ""

Default cEntida	:= ""
Default cCodigo	:= "" 
Default cLoja		:= ""

Private lMsErroAuto := .F.

If Select("AOF") > 0
	aAreaAOF := AOF->(GetArea())
Else
	DbSelectArea("AOF")
EndIf
AOF->(DbSetOrder(4))//AOF_FILIAL+AOF_ENTIDA+AOF_CHAVE

aExecAuto := {{"AOF_FILIAL",xFilial("AOF")        ,Nil}		   				,;
	   			{"AOF_DTCAD" ,dDatabase				 ,Nil}						,;
				{"AOF_REMETE",cFrom					 ,Nil}						,;
				{"AOF_TIPO"  ,TPEMAIL      			 ,Nil}						,;
				{"AOF_ASSUNT",cSubject         		 ,Nil}						,;
				{"AOF_DESCRI",cBody			   		 ,Nil}						,;
				{"AOF_ENTIDA",AllTrim(cEntida) 		 ,Nil}						,;//Entidade do registro que está sendo processado
				{"AOF_CHAVE" ,AllTrim(cCodigo+cLoja),Nil}						,;//x2_Unico do registro que está sendo processado
				{"AOF_DESTIN",cTo                 	 ,Nil}						,;
				{"AOF_STATUS",STPENDENTE          	 ,Nil}						,;//Status de Pendente
				{"AOF_IDESTN",aNvlEstrut[1]			 ,Nil}						,;
				{"AOF_NVESTN",aNvlEstrut[2] 		 ,Nil}						,;
   				{"AOF_PARTIC",cCc ,Nil}}
MSExecAuto( {|a,b,c| CRMA180( a,b,c) } ,aExecAuto,3,.T. ) //Importar email por rotina automatica

If AOF->(DbSeek(xFilial("AOF")+cEntida+AllTrim(cCodigo+cLoja)))

	If aDadUsr[3]
		 cUser  := aDadUsr[_PREFIXO][_Usuario]
		 cPass  := aDadUsr[_PREFIXO][_SenhaUser]
	EndIf

	If CRMXEnvMail(cFrom, cTo, cCc, cBcc, cSubject, cBody, "AOF",AOF->AOF_CODIGO,.T.,cUser,cPass)

		CRM170ATLS(AOF->AOF_CODIGO,STENVIADO)// atualiza status da atividade

   	EndIf
EndIf

If !Empty(aAreaAOF)
	RestArea(aAreaAOF)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM170SCH
 Rotina de disparo de emails  pendentes atraves do Job

@param		ExpC1 - Codigo da atividade
			ExpC2 - Status que ela deverá receber

@return	Nenhum

@author	Victor Bitencourt
@since		18/03/2014
@version   12.0
/*/
//-------------------------------------------------------------------
Function CRM170SCH( aParams )

RpcSetType( 3 ) // Executa sem consumir licença
RpcSetEnv( aParams[1],aParams[2], , , "CRM")

conout(STR0077) //"Iniciando job para disparo de emails pendentes..."

SendEmailSCH()

conout(STR0078)//"Finalizado job de disparo de emails pendentes..."

RpcClearEnv()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM170ATLS

 Rotina para atualização de Status das atividades

@param		ExpC1 - Codigo da Atividade
			ExpC2 - Status que a atividade receberá

@return	Nenhum

@author	Victor Bitencourt
@since		18/03/2014
@version   12.0
/*/
//-------------------------------------------------------------------
Function CRM170ATLS(cCodigo,cStatus)

Local aExecAuto := {}
Local aAreaAOF  := {}

Private lMsErroAuto := .F.

If Select("AOF") > 0
	aAreaAOF := AOF->(GetArea())
Else
	DbSelectArea("AOF")
EndIf
AOF->(DbSetOrder(1))//AOE_FILIAL+Codigo

If AOF->(DbSeek(xFilial("AOF")+cCodigo))
	RecLock("AOF",.F.)// foi necessário atualizar dessa forma porque o mvc não enterpretava a alteração
		AOF->AOF_DTCAD  := MsDate()
		AOF->AOF_STATUS := cStatus //Status de Lido
	AOF->(MsUnlock())
EndIf

If !Empty(aAreaAOF)
	RestArea(aAreaAOF)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM170MEEM()

Rotina para interpretar os codigos no email e mesclar com os dados reais

@param		ExpC1 - Variavel contendo e corpo do email
			ExpC2 - Alais da entidade dona do modelo de email

@return	cBodyMesc - email já com a mesclagem dos campos

@author	Victor Bitencourt
@since		26/03/2014
@version   12.0
/*/
//-------------------------------------------------------------------
Function CRM170MEEM(cBodyMesc,cAlias)

	Local cAtuBody     := ""
	Local cValor       := ""
	Local uValor       := Nil
	local cFunc := ""

	Local nTamanho     := Len(cBodyMesc)

	Local aAreaTAG     := {}
	Local aAreaAOE     := {}

	Default cBodyMesc  := ""
	Default cAlias     := ""

	If Select("AOE") > 0
		aAreaAOE := AOE->(GetArea())
	Else
		DbSelectArea("AOE")
	EndIf
	AOE->(DbSetOrder(1))//AOE_FILIAL+AOE_ENTIDA+AOE_TAG

	If !Empty(cBodyMesc) .AND. !Empty(cAlias)
		Do While At( "$!", cBodyMesc ) > 0 .OR. At( "##", cBodyMesc ) > 0 .OR. At( "#!", cBodyMesc ) > 0
			nPrimeiro := At( "$!", cBodyMesc )
			If nPrimeiro > 0
				cAux      := SubStr(cBodyMesc, nPrimeiro+2, nTamanho )
				nSegundo  := At( "$!", cAux )
				cChave    := SubStr(cBodyMesc, nPrimeiro,nSegundo+3)
				uValor    := IIF(Len(AllTRim(cChave)) > 14 ,"",(cAlias)->&(StrTran(cChave,"$!","",,)))
				cValor    := TrataValor(uValor)
				cBodyMesc := StrTran(cBodyMesc,cChave,cValor,,)
			
				 ElseIf nPrimeiro := At( "##", cBodyMesc )
				If nPrimeiro > 0
					cAux    := SubStr(cBodyMesc, nPrimeiro+2, nTamanho )
					nSegundo  := At( "##", cAux )
					cChave    := SubStr(cBodyMesc, nPrimeiro,nSegundo+3)
					If AOE->(DbSeek(xFilial("AOE")+cAlias+AllTrim(StrTran(cChave,"##","",,))))
						uValor := Posicione(AOE->AOE_ENTEST,AOE->AOE_ORDEM,xFilial(AOE->AOE_ENTEST)+(AOE->AOE_ENTIDA)->&(AllTrim(AOE->AOE_CHVORI)),AOE->AOE_CAMPO)
						cValor := TrataValor(uValor)
						cBodyMesc := StrTran(cBodyMesc,cChave,cValor,,)
					EndIf
				EndIf
			   ElseIf   nPrimeiro := At( "#!", cBodyMesc )
				If nPrimeiro > 0
					cAux    := SubStr(cBodyMesc, nPrimeiro+2, nTamanho )
					nSegundo  := At( "#!", cAux )
					cChave    := SubStr(cBodyMesc, nPrimeiro,nSegundo+3)
				   If AZB->(DbSeek(xFilial("AZB")+cAlias+AllTrim(StrTran(cChave,"#!","",,))))	
					 begin sequence
					 cValor:=TrataValor(&(AZB->AZB_FUNC))
					 end sequence
					 
									 
					
					cBodyMesc := StrTran(cBodyMesc,cChave,cValor,,)
				   endif
				Endif
			EndIf
		EndDo
	EndIf
If !Empty(aAreaAOE)
      RestArea(aAreaAOE)
EndIf

Return cBodyMesc

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataValor()

Rotina para tratar o valor de um tipo aleatorio para um tipo string

@param		ExpU1 - Valor a Ser Tratado

@return	cValor - Retorno do valor em String

@author	Victor Bitencourt
@since		26/03/2014
@version   12.0
/*/
//-------------------------------------------------------------------
Static Function TrataValor(uValor)

Local cValor := ""
Default uValor := Nil

If uValor <> Nil
	Do Case
		Case ValType(uValor) == "N"
			cValor := cValToChar(uValor)
		Case ValType(uValor) == "M"
			cValor := uValor
		Case ValType(uValor) == "D"
			cValor := DTOC(uValor)
		Case ValType(uValor) == "L"
			If uValor
				cValor := STR0086 //"verdadeiro"
			Else
				cValor := STR0087 //"falso"
			EndIf
		Case ValType(uValor) == "C"
			cValor := uValor
	EndCase
EndIf

Return AllTrim(cValor)


//-------------------------------------------------------------------
/*/{Protheus.doc} CRM170READ()

Rotina que atualiza se o email para "LIDO"

@param		ExpA1 - __aCookies
			ExpA2 - __aPostParms
			ExpN1 - __nProcID
			ExpA3 - __aProcParms
			ExpC1 - __cHTTPPage

@return	Nenhum

@author	Victor Bitencourt
@since		02/04/2014
@version   12.0
/*/
//-------------------------------------------------------------------
Function CRM170READ(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)


RpcSetType( 3 ) // Executa sem consumir licença

StartJob("CRMA170Thr",GetEnvServer(),.T.,__aProcParms)


Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM170VCHV()

Rotina para validar a chave unica do registro selecionado campo do valid (AOF_CHAVE)

@param	  	Nenhum

@return   	lRet

@author	Victor Bitencourt
@since		03/04/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRM170VCHV()

Local lRet   := .T.
Local cAlias := FwFldGet("AOF_ENTIDA")
Local cUnico := FwFldGet("AOF_CHAVE")
Local oModel := FwModelActive()

If !Empty(cUnico)

	If !Empty(cAlias)
		lRet := ExistCpo(cAlias,AllTrim(cUnico),1) // Validando se o registro existe na tabela de origem
		If lRet 
			If ( cAlias ) == "AD1"
				cUnico := Alltrim( cUnico )
			EndIf
		 	lRet := CRMXLibReg( cAlias, cUnico )// validando se o usuario tem permissão para esse registro, somente quando tiver estrutura de negócio
		EndIf 
	Else
		lRet := .F.
	EndIf

Else
	oModel:GetModel("AOFMASTER"):LoadValue("AOF_DESCRE","")
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRM170AThr()

Atualiza parametros gerais entre as threads

@param		Nenhum

@return	Nenhum

@author	Victor Bitencourt
@since		15/04/2014
@version   12.0

/*/
//--------------------------------------------------------------------------------------------------------------
Function CRM170AThr() 

Local nTimeThread := 0
Local cCodUsr	  := IIF(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr()) 	
Local aInfoUser   := CRM170GetS(.T.,.T.)//busca os dados do usuario

AAdd(aInfoUser,{cEmpAnt,cFilAnt})
If aInfoUser[3]
	nTimeThread := Val(aInfoUser[_PREFIXO][_TimeMin]) * 60000
	SetSyncOptions(cValToChar(ThreadId()), "CRM170ExcS", nTimeThread, aInfoUser)
EndIf

Return

//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRM170ExcS()

chama a função que faz a sincronização e retornar o status dela.

@param		ExpA1 = Array com as dados do usuario

@return	Nenhum

@author	Victor Bitencourt
@since		15/04/2014
@version   12.0

/*/
//--------------------------------------------------------------------------------------------------------------
Function CRM170ExcS(aOpcoes)

Local aArea     := GetArea()
Local cEmp 	  := aOpcoes[4][1]
Local cFil 	  := aOpcoes[4][2]
Local aRet      := {.T., "STOPED"}

RPCSetType(3) 

RPCSetEnv( cEmp, cFil )

If aOpcoes[3] //verifica se é um usuario do CRM
	If aOpcoes[_PREFIXO][_Habilita] // verifica se existe sincronização automatica.
		aRet := CRMA170EXG(.T.,aOpcoes)[2]
	EndIf
EndIf

RestArea(aArea)

Return aRet


//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA170LMG()

Função para ler as imagens do html e vincular aos links externos.
do e-mail por um codigo.

@param		ExpC1 = Corpo do email
			ExpL1 = Indica se o email está vindo da Maquina de origem das imagens.
			ExpL2 = Indica se vai sre alterado o mapeamento

@return	Nenhum

@author	Victor Bitencourt
@since		13/06/2014
@version   12.0

/*/
//--------------------------------------------------------------------------------------------------------------
Function CRMA170LMG(cBody, lOrigem, lAltera)

Local aExt      := {}
Local aAreaAO3  := {}
Local aRetDir   := {}
Local cCodUsr	:= IIF(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr()) 	
Local nX        := 0
Local nSpace    := 0

Local cRootPath := ""
Local cDrive    := ""
Local cDir      := ""
Local cDescri   := ""
Local cExten    := ""
Local cFile     := ""
Local cBodyAux  := ""
Local cXmlImg   := ""
Local cCodRastr := ""
Local cLnkImg   := ""
Local cLinkExt  := Space(150)
Local aImagHtml := {}
Local aDirs     := {}

Local lProcessa := .F.

Local oPanel    := Nil
Local oDlg      := Nil
Local lRetorno  := Nil
Local oTitulo2  := Nil
Local oXml      := Nil
Local uXml      := Nil


Local 	 oColEnt     := Nil
Local 	 oLINEONE    := Nil
Local   oLINETWO    := Nil
Local   oBrwMark    := Nil

Default cBody   := ""
Default lOrigem := .F.
Default lAltera := .F.

If Select("AO3") > 0
	aAreaAO3 := AO3->(GetArea())
Else
	DbSelectArea("AO3")// Usuarios CRM
EndIf
AO3->(DbSetOrder(1)) //AO3_FILIAL+AO3_CODUSR

If  lOrigem .AND. !Empty(cBody)

   	//-----------------------------------------------------------------------------------------
	//	 Verificando se o html possue imagens, para não efetuar processamentos desnecessários
	//------------------------------------------------------------------------------------------

   If  (At( ".JPG", Upper(cBody) ) > 0 .OR. At( ".PNG", Upper(cBody) ) > 0 .OR. At( ".GIF", Upper(cBody) ) > 0)

	   If AO3->(DbSeek(xFilial("AO3")+cCodUsr))
			cRootPath := Upper(AllTrim(AO3->AO3_IMGPTH))
			If Empty(cRootPath)
				lProcessa := .F.
				aRetDir := CRMA170VRO()

				If aRetDir[1]
					cRootPath := Upper(aRetDir[2])
					lProcessa := aRetDir[1]
				EndIf
			Else
				lProcessa := .T.
			EndIf
	   EndIF

	   If lProcessa
	   		cBodyAux := Upper(cBody)
	   		Do While At( cRootPath, cBodyAux ) > 0
				nPrimeiro := At( cRootPath, cBodyAux )
	       	If nPrimeiro > 0

			      	//---------------------------------------------------------------
					//	 Pegando o prmeiro elemento do html seja .jpg, .png ou .gif
					//---------------------------------------------------------------
			       Asize(aExt,0)
			   		Aadd(aExt,At( ".JPG", cBodyAux ))
			   		Aadd(aExt,At( ".PNG", cBodyAux ))
			   		Aadd(aExt,At( ".GIF", cBodyAux ))
					Asort(aExt)// Ordenando vetor em ordem ascendente

					For nX := 1 to Len(aExt)//pegando o menor valor sendo maior que 0
						If aExt[nX] > 0
							nSegundo := aExt[nX]
							loop
						EndIf 
					Next nX

				    //-------------------------------------------
					//	 Guardando as imagens no array
					//--------------------------------------------
					If nSegundo > 0
				       nFim      := nSegundo - nPrimeiro
				    	cAux      := SubStr(cBodyAux, nPrimeiro, nFim+4) // Diretorio da imagem

				    	SplitPath( cAux ,@cDrive, @cDir, @cDescri, @cExten )
				    	Aadd(aImagHtml,{ cDescri+cExten, cAux, cLinkExt} )

				       cBodyAux  := StrTran(cBodyAux,cAux,"")           // Substituindo diretorio por link

				   EndIf
		       EndIf
	   		EndDo

			//------------------------------------------------------------------------------
			//		Criando Janela de confirmação para o usuario, Somente se exitir imagens
			//------------------------------------------------------------------------------

			If !Empty(aImagHtml)// verificando se o array contém imagens

				lRetorno := FWAlertYesNo(STR0102, STR0088) //"E-mail possui Imagens, Deseja incluir os Links externos ?"//"Atenção"

				//----------------------------------------------------------------------
				//		Montando tela para inclusão dos Links, caso o lRetorno seja .T.
				//----------------------------------------------------------------------
				If lRetorno

					oDlg := FWDialogModal():New()
						oDlg:SetBackground(.F.) // .T. -> escurece o fundo da janela
						oDlg:SetTitle(STR0101)//"Inclusão Mapeamento"
						oDlg:SetEscClose(.T.)//permite fechar a tela com o ESC
						oDlg:SetSize(220,500) //cria a tela maximizada (chamar sempre antes do CreateDialog)
						oDlg:EnableFormBar(.T.)

						oDlg:CreateDialog() //cria a janela (cria os paineis)
						oPanel := oDlg:getPanelMain()
						oDlg:createFormBar()//cria barra de botoes
						oDlg:addYesNoButton()

						oFwLayer := FwLayer():New()
						oFwLayer:init(oPanel,.F.)
						oFWLayer:AddLine( "LINEONE",90, .F.)
						oFWLayer:AddLine( "LINETWO",10, .F.)
						oLINEONE := oFwLayer:GetLinePanel("LINEONE")
						oLINETWO := oFwLayer:GetLinePanel("LINETWO")

				       DEFINE FWBROWSE oBrwMark DATA ARRAY ARRAY aImagHtml LINE BEGIN 1 EDITCELL { |lCancel,oBrowse| GrvLnkArray(lCancel,oBrowse,@aImagHtml) } OF oLINEONE //"Imagem x Link"
							ADD COLUMN oColEnt DATA &("{ || aImagHtml[oBrwMark:At()][1] }") TITLE STR0103  TYPE "C" SIZE 20  OF oBrwMark//"Imagem"
							ADD COLUMN oColEnt DATA &("{ || aImagHtml[oBrwMark:At()][2] }") TITLE STR0104   TYPE "C" SIZE 30  OF oBrwMark//"Local"
							ADD COLUMN oColEnt DATA &("{ || aImagHtml[oBrwMark:At()][3] }") TITLE STR0105 SIZE 150 EDIT READVAR "cLinkExt" OF oBrwMark//"Externo"
						ACTIVATE FWBROWSE oBrwMark
				 	oDlg:activate()
					If oDlg:getButtonSelected() > 0 // pegando a resposta do usuario na tela
			 			lRet := .T.
			 			cXmlImg:= GeraXmlImg(aImagHtml)
			 		Else
			 			lRet := .F.
			 			cXmlImg := GeraXmlImg(aImagHtml)
			 		EndIf
				Else
					cXmlImg:= GeraXmlImg(aImagHtml)
				EndIf
			EndIf
		EndIf
	EndIF
ElseIf Altera

	//---------------------------------------------------
	//	 Verificando a Chamda para pegar o campos certos
	//---------------------------------------------------
	If IsInCallStack("CRMA230")
	 	cCodRastr := AllTrim(SHA1(AO6->AO6_CODMOD))// Codigo rastreavel (hash do codigo da Atividade)
	 	cLnkImg   := AO6->AO6_LNKIMG
	ElseIf IsInCallStack("CRMA180")
		cCodRastr := AllTrim(SHA1(AOF->AOF_CODIGO))// Codigo rastreavel (hash do codigo da Atividade)
		cLnkImg   := AOF->AOF_LNKIMG
	EndIf

	If !Empty(cLnkImg)

		oXml := CRMA170RXM(cLnkImg)// pegando o objeto Xml da atividade posicionada.

		/* Caso queira ver a estrutura do xml, ele é montado na função "GeraXmlImg" do fonte "CRMA170"*/
		If oXml <> Nil
		   	oXml := XmlGetChild(oXML:_HTMLIMG,1)// pega o 1º elemento a partir do elemento _HTMLIMG, o conteúdo da tag "IMG"
			uXml := XmlChildEx(oXml, "_IMG")

		 	If ValType(uXml) == "A" // Trata como array quando possuir mais de um elemento
		 		For nX := 1 to Len(uXml)
		 			nSpace := (150-Len(uXml[nX]:_LinkExterno:Text))	// Tamanho do campo dever ter 150 para digitar
		 			nSpace := IIf(nSpace >0,nSpace,0)
		 			Aadd(aImagHtml,{uXml[nX]:_NomeImagem:Text,"",uXml[nX]:_LinkExterno:Text+Space(nSpace)})
		    	Next nX
		   ElseIf ValType(uXml) == "O"// trata como objeto, quando possuir apenas um elemento
		   		nSpace := (150-Len(uXml:_LinkExterno:Text))	// Tamanho do campo dever ter 150 para digitar
		 		nSpace := IIf(nSpace >0,nSpace,0)
		 		Aadd(aImagHtml,{uXml:_NomeImagem:Text,"",uXml:_LinkExterno:Text+Space(nSpace)})
		   Endif

			If !Empty(aImagHtml)
				oDlg := FWDialogModal():New()
					oDlg:SetBackground(.F.) // .T. -> escurece o fundo da janela
					oDlg:SetTitle(STR0106)//"Alteração Mapeamento"
					oDlg:SetEscClose(.T.)//permite fechar a tela com o ESC
					oDlg:SetSize(220,400) //cria a tela maximizada (chamar sempre antes do CreateDialog)
					oDlg:EnableFormBar(.T.)

					oDlg:CreateDialog() //cria a janela (cria os paineis)
					oPanel := oDlg:getPanelMain()
			    	oDlg:createFormBar()//cria barra de botoes
					oDlg:addYesNoButton()

					oFwLayer := FwLayer():New()
					oFwLayer:init(oPanel,.F.)
					oFWLayer:AddLine( "LINEONE",90, .F.)
					oFWLayer:AddLine( "LINETWO",10, .F.)
					oLINEONE := oFwLayer:GetLinePanel("LINEONE")
					oLINETWO := oFwLayer:GetLinePanel("LINETWO")

			       DEFINE FWBROWSE oBrwMark DATA ARRAY ARRAY aImagHtml LINE BEGIN 1 EDITCELL { |lCancel,oBrowse| GrvLnkArray(lCancel,oBrowse,@aImagHtml) } OF oLINEONE //"Imagem x Link"
						ADD COLUMN oColEnt DATA &("{ || aImagHtml[oBrwMark:At()][1] }") TITLE STR0103  TYPE "C" SIZE 20  OF oBrwMark//"Imagem"
						ADD COLUMN oColEnt DATA &("{ || aImagHtml[oBrwMark:At()][3] }") TITLE STR0105 SIZE 150 EDIT READVAR "cLinkExt" OF oBrwMark//"Externo"
					ACTIVATE FWBROWSE oBrwMark
			 	oDlg:activate()
			 	If oDlg:getButtonSelected() > 0 // pegando a resposta do usuario na tela
			 		lRet := .T.
			 		cXmlImg := GeraXmlImg(aImagHtml)
			 	Else
			 		lRet := .F.
			 		cXmlImg := ""
			 	EndIf
			 EndIf
		EndIf
	Else
		Aviso(STR0094,STR0107,{STR0095})//"Atenção"//"E-mail não possui Mapeamento para ser alterado !"//"Ok"
	EndIf
EndIf

Return (cXmlImg)


//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GrvLnkArray()

Função para localizar e fazer o download das imagens do e-mail em uma pasta temporaria

@param		ExpC1 = Corpo do email
			ExpC2 = Indica se o email está vindo da Maquina de origem das imagens.

@return	Nenhum

@author	Victor Bitencourt
@since		13/06/2014
@version   12.0

/*/
//--------------------------------------------------------------------------------------------------------------
Static Function GrvLnkArray(lCancel,oBrowse,aImagHtml)

Local lRet    := .T.						// Retorno da rotina.
Local cConteudo   := AllTrim(&(ReadVar()))		// Conteudo em memoria do campo.

If !lCancel
   aImagHtml[oBrowse:nAt][3] := cConteudo
EndIf

Return lRet


//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GeraXmlImg()

Função para gera o mapeamento das imagens do html em formato xml

@param		ExpA1 = Array contendo os dados das imagens do html


@return	ExpC1 = retorna o Xml Montado

@author	Victor Bitencourt
@since		27/06/2014
@version   12.0

/*/
//--------------------------------------------------------------------------------------------------------------
Static Function GeraXmlImg(aImagHtml)

Local cXML       := ""
Local nX         := 0
Local cIMG       := "IMG000"
Local cDirServer := "\\CRMIMG\"
Local cNome      := ""

Default aImagHtml := {}

If !Empty(aImagHtml)
	cXML := '<?xml version="1.0" encoding="ISO-8859-1"?>'
	cXML += "<HTMLIMG>"
	cXML += 	 "<IMAGENS>"
	For nX := 1 to Len(aImagHtml)
		cXML += 	 "<IMG>"
		cXML += 		 "<NomeImagem>"+aImagHtml[nX][1]+"</NomeImagem>" //Nome da Imagem + Extensão
		If Empty(aImagHtml[nX][3]) // Verificando se a imagem possui link externo, pois se não possuir, precisa receber um ID
			cNome := cDirServer+aImagHtml[nX][1] // Caminho raiz da imagem (system)
			cIMG  := Soma1(cIMG) // Gerando um novo ID para atribuir na imagem interna

			cXML +=          "<lExterna>.F.</lExterna>"
			cXML +=  		 "<LinkInterno>"+cNome+"</LinkInterno>" // Link Interno da Imagem
			cXML +=  		 "<cId>"+cIMG+"</cId>" // Atribuindo um ID a imagem interna
		Else
			cXML +=          "<lExterna>.T.</lExterna>"
			cXML += 		 "<LinkExterno>"+aImagHtml[nX][3]+"</LinkExterno>" // Link Externo da Imagem
		EndIf
		cXML += 	 "</IMG>"
	Next nX
	cXML += 	 "</IMAGENS>"
	cXML += "</HTMLIMG>"
EndIf

return cXML

//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA170RXM()

Função para Ler o xml e retornar a estrutura

@param		ExpC1 = Xml Montado


@return	ExpO1 = Retorna o objeto do xml

@author	Victor Bitencourt
@since		27/06/2014
@version   12.0

/*/
//--------------------------------------------------------------------------------------------------------------
Static Function CRMA170RXM(cXml)

Local oXML  := Nil

Local cErro  := ""
Local cAviso := ""

Default cXml := ""

If !Empty(cXml)
	oXml := XmlParser(cXml,"_",@cErro,@cAviso)
EndIf

return oXML


//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA170Lnk()

Função para trocar o 'src' das imagens no html original, por um codigo rastreavel.


@param		ExpC1 = Corpo do email
			ExpL1 = Indica se o email está vindo da Maquina de origem das imagens.
			ExpL2 = Indica se o email será enviado.
			ExpL3 = Indica se a chamada está vindo de uma rotina automatica.
			ExpL4 = Indica se o email está vindo de uma alteração.
			ExpL5 = Indica se o email vai ser distribuido
			ExpC1 = Codigo rastreavel da atividade Padrão criada, parametro só é válido quando for distribuição de e-mail

@return	Nenhum

@author	Victor Bitencourt
@since		13/06/2014
@version   12.0

/*/
//--------------------------------------------------------------------------------------------------------------
Function CRMA170Lnk( cBody, lGrava, lEnvia, lAuto, lDistrib, cCodRatAnt, aAnexo)

Local aExt      := {}
Local aAreaAO3  := {}
Local aRetDir   := {}
Local cCodUsr	:= IIF(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr()) 	
Local nX        := 0
Local cBodyAux  := ""
Local cRootPath := ""
Local cDrive    := ""
Local cDir      := ""
Local cDescri   := ""
Local cExten    := ""
Local cLink     := ""
Local cFile     := ""
Local cAux      := ""
Local cLnkImg   := ""
Local cCodRastr := "" //Codigo rastreavel
Local lProcessa := .F.
Local uXml      := Nil
Local lExterna  := .F.

Default aAnexo	   := {}
Default cBody      := ""
Default lGrava     := .F.
Default lEnvia     := .F.
Default lAuto      := .F.
Default lDistrib   := .F.
Default cCodRatAnt := ""

//------------------
//	 Tratando Html
//------------------
If !Empty(cBody) .AND. (lGrava .OR. lEnvia .OR. lDistrib)

	/* Copiando o HTMl original, para que não haja alterações desnecessarias no original, o html original só será alterado
		quando necessário.*/
	cBodyAux := cBody

	//--------------------------------------------------------------------------
	//	 Verificando se Existe imagens no email, que deverão ser processadas
	//--------------------------------------------------------------------------

	If  (At( ".JPG", Upper(cBodyAux) ) > 0 .OR. At( ".PNG", Upper(cBodyAux) ) > 0 .OR. At( ".GIF", Upper(cBodyAux) ) > 0)

		//--------------------------------------------------
		//	Pegando parametros, conforme a opção escolhida
		//--------------------------------------------------

		If lEnvia

		 	//---------------------------------------------------
			//	 Verificando a Chamda para pegar o campos certos
			//---------------------------------------------------
			If IsInCallStack("CRMA230")
			 	cCodRastr := AllTrim(SHA1(AO6->AO6_CODMOD))// Codigo rastreavel (hash do codigo da Atividade)
			 	cLnkImg   := AO6->AO6_LNKIMG
			ElseIf IsInCallStack("CRMA180")
				cCodRastr := AllTrim(SHA1(AOF->AOF_CODIGO))// Codigo rastreavel (hash do codigo da Atividade)
				cLnkImg   := AOF->AOF_LNKIMG
			EndIf

		ElseIf lGrava

			If IsInCallStack("CRMA230")
			 	cCodRastr := AllTrim(SHA1(FwFldGet("AO6_CODMOD")))
			ElseIf IsInCallStack("CRMA180")
				cCodRastr := AllTrim(SHA1(FwFldGet("AOF_CODIGO")))
			EndIf

			If Select("AO3") > 0
			 	aAreaAO3 := AO3->(GetArea())
			Else
				DbSelectArea("AO3")// Usuarios CRM
			EndIf
			AO3->(DbSetOrder(1)) //AO3_FILIAL+AO3_CODUSR

			If AO3->(DbSeek(xFilial("AO3")+cCodUsr))
				cRootPath := AllTrim(AO3->AO3_IMGPTH)
			EndIF

		 ElseIf lDistrib

			cCodRastr  := AllTrim(SHA1(FwFldGet("AOF_CODIGO")))//Codigo Rastreavel da Atividade Atual (sendo criada)
		 EndIf


		//------------------------------------
		//	 Fazendo o tratamento da exceções
		//------------------------------------

		Do Case
			Case Empty(cRootPath) .AND. lGrava
				lProcessa := .F.
				aRetDir := CRMA170VRO(.F.)

				If aRetDir[1]
					cRootPath := aRetDir[2]
					lProcessa := aRetDir[1]
				EndIf

			Case Empty(cCodRastr) .AND. lEnvia
				lProcessa := .F.
	   			Aviso(STR0094,STR0108,{STR0095})//"Atenção"//E-mail possui Imagens, No entanto não existe nenhum codigo rastreavel no Html !//"OK"

			OtherWise
				lProcessa := .T.

		EndCase

		/* 	******************************  Observação *****************************
		Caso a Chamada esteja lGrava := .T. , siginifica que o email está sendo montado com as imagens locais na maquina,
		então é necessario buscar com o rootpath do usuario.
		Caso a chamada não venha da origem , siginifica que essa html já possue codigos rastreaveis, é necessário pesquisar imagens
		usando o codigo rastreavel (hash do codigo da Atividade) caso já e 	*/


	   /************ Case lEnvia ***********
		 Caso seja envio confiamos que o e-mail já possue seus codigos rastreaveis e o mapeamento em xml, dessa forma somente devera
		 ser trocado pelos links caso exista. normalmente este parametro de envio virá de rotinas de envio direto como CRMXEnvMail,
		 que necessitam apenas da troca dos codigos rastreaveis pelos link. o retorno desta função será apenas enviada para o destinatario,
		 sem alterar no banco o html original cmo os codigos rastreaveis.

		*********** Case lGrava ***********
		Caso seja lGrava siginifica que o email está sendo montado com as imagens locais na maquina, ou que deverá ser atualizado as
		imagens do html o retorno desta função será gravada no banco, normalmente este parametro de origem virá de rotinas de alteração
		ou gravação como a "ModelCommit" do fonte	'CRMA180' */

		/*********** Case lDistrib ***********
		Caso seja distribuição, apenas trocamos o codigo rastreavel da atividade padrão  pelo codigo rastreavel da atividade atual
		atividade padrão é o registro pura, sem mesclagem e tags adicionadas, é utlizado para replicar a atividade para os menbros das
		listas.*/

	 	If lProcessa

	 		//--------------------------------------
			//	 Verificando se é envio ou lGrava
			//-------------------------------------
			Do Case
				Case lEnvia

					//---------------------------
					//	Tratamento do objeto Xml
					//---------------------------
					oXml := CRMA170RXM(cLnkImg)// pegando o objeto Xml da atividade posicionada.

					/* Caso queira ver a estrutura do xml, ele é montado na função "GeraXmlImg" do fonte "CRMA170"*/
					If oXml <> Nil
					   	oXml := XmlGetChild(oXML:_HTMLIMG,1)// pega o 1º elemento a partir do elemento _HTMLIMG, o conteúdo da tag "IMG"
						uXml := XmlChildEx(oXml, "_IMG")

						Do While At( Upper(cCodRastr), Upper(cBodyAux) ) > 0
							nPrimeiro := At( Upper(cCodRastr), Upper(cBodyAux) )
					       If nPrimeiro > 0

						      	//---------------------------------------------------------------
								//	 Pegando o prmeiro elemento do html seja .jpg, .png ou .gif
								//---------------------------------------------------------------
						       Asize(aExt,0)
						   		Aadd(aExt,At( ".JPG", Upper(cBodyAux) ))
						   		Aadd(aExt,At( ".PNG", Upper(cBodyAux) ))
						   		Aadd(aExt,At( ".GIF", Upper(cBodyAux) ))
								Asort(aExt)// Ordenando vetor em ordem ascendente

								For nX := 1 to Len(aExt)//pegando o menor valor sendo maior que 0
									If aExt[nX] > 0
										nSegundo := aExt[nX]
										loop
									EndIf
								Next nX

							    //-------------------------------------------
								//	 Pegando o valor completo do src no html
								//--------------------------------------------
								If nSegundo > 0
							       nFim      := nSegundo - nPrimeiro

							    	cAux      := SubStr(cBodyAux, nPrimeiro, nFim+4) // Diretorio da imagem do html original
							    	SplitPath( cAux ,@cDrive, @cDir, @cDescri, @cExten )
							    	cFile := AllTrim(cDescri+cExten) // Nome da Imagem

									//-------------------------------------------------------------
									//	 Pegando o mapeamento para cruzar com as imagens do email
									//-------------------------------------------------------------

					    			 cLink := ""
					    			 If ValType(uXml) == "A"// trata como Array, quando o Objeto possuir mais de um elemento
						    			For nX := 1 to Len(uXml)
						    				If uXml[nX]:_NomeImagem:Text == Upper(cFile)
												lExterna := uXml[nX]:_lExterna:Text
												If lExterna == ".F." // Verifica se é interna para gerar o ID
													cLink := uXml[nX]:_cId:Text
													aAdd(aAnexo,{uXml[nX]:_LinkInterno:Text,uXml[nX]:_cId:Text})
												Else
						    						cLink := uXml[nX]:_LinkExterno:Text
												EndIf
						    			Loop
						    				EndIf
						    			Next nX
					    			 ElseIf ValType(uXml) == "O"// trata como objeto, quando possuir apenas um elemento
					    				If uXml:_NomeImagem:Text == Upper(cFile)
											lExterna := uXml:_lExterna:Text
											If lExterna == ".F."
												cLink := uXml:_cId:Text
												aAdd(aAnexo,{uXml:_LinkInterno:Text,uXml:_cId:Text})
											Else
					    						cLink := uXml:_LinkExterno:Text
											EndIf
					    				EndIf
					    			 Endif

					    			 If !Empty(cLink) // substituir no cBoby original, caso exista um link correspondente a imagem
					    			 	 cBody  := StrTran(cBody,cAux,cLink)// Substituindo Cosdigo rastreavel pelo link correspondente
					    			 EndIf

							    	 cBodyAux  := StrTran(cBodyAux,cAux,"") //tirando o campo do Auxiliar para não ser pesquisado novamente

							   EndIf
					       EndIf
						EndDo
					EndIf
				Case lGrava

					/* ***************************  Atenção ****************************************
					 è utilizado o Upper toda vez que for pesquisar um valor, para não alterar as configuações
						originais do html, para quando for utlizar a função StrTran do html original, ela consiga achar
						as string correspondente já que elas devem ser exatamente iguais */

					 If !Empty(cRootPath)
						 Do While At( Upper(cRootPath), Upper(cBodyAux) ) > 0
							nPrimeiro := At( Upper(cRootPath), Upper(cBodyAux) )
					       If nPrimeiro > 0

						      	//---------------------------------------------------------------
								//	 Pegando o prmeiro elemento do html seja .jpg, .png ou .gif
								//---------------------------------------------------------------
						       Asize(aExt,0)
						   		Aadd(aExt,At( ".JPG", Upper(cBodyAux) ))
						   		Aadd(aExt,At( ".PNG", Upper(cBodyAux) ))
						   		Aadd(aExt,At( ".GIF", Upper(cBodyAux) ))
								Asort(aExt)// Ordenando vetor em ordem ascendente

								For nX := 1 to Len(aExt)//pegando o menor valor sendo maior que 0
									If aExt[nX] > 0
										nSegundo := aExt[nX]
										Loop
									EndIf
								Next nX

							    //-------------------------------------------
								//	 Pegando o valor completo do src no html
								//--------------------------------------------
								If nSegundo > 0
	                            nFim      := nSegundo - nPrimeiro

	                            cAux      := SubStr(cBodyAux, nPrimeiro, nFim+4) // Diretorio da imagem
	                            SplitPath( cAux ,@cDrive, @cDir, @cDescri, @cExten )

								UpDowImg( cDrive+cDir, AllTrim(cDescri+cExten), /*cPathDestino*/, /*lDownlaod*/, .T., lAuto)//grava imagem na pasta CRMIMG no servidor
	                            cFile := (cCodRastr+"\"+cDescri+cExten) // Caso o email venha da origem, devera ser criado o um codigo padrão e substituir pelo src original do html.

	                            cBody     := StrTran(cBody,cAux,cFile)// Substituindo diretorio por link
	                            cBodyAux  := StrTran(cBodyAux, cAux, "")//tirando o campo do Auxiliar para não ser pesquisado novamente
						        EndIf
					        EndIf
					    EndDo

					EndIf

				Case lDistrib

					If !Empty(cCodRatAnt)
                    	cBody := StrTran(cBody,cCodRatAnt,cCodRastr)//substituido cod rastreavel da atividade pardrao, pelo cod ratreavel da ativ atual
					EndIf

			EndCase
		EndIf
	EndIf
EndIf

Return (cBody)

//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA170CRG()

Função para localizar e fazer o download das imagens do e-mail para a pasta configurado pelo usuario

@param		ExpC1 = Corpo do email
			ExpC2 = Indica se o email está vindo da Maquina de origem das imagens.
			ExpL1 = Indica se a chamada , é para uma pré- visualização do e-mail

@return	Nenhum

@author	Victor Bitencourt
@since		13/06/2014
@version   12.0

/*/
//--------------------------------------------------------------------------------------------------------------
Function CRMA170CRG(cBody, lAuto, lPreVisual)

Local aRetDwn    := {}
Local aExt       := {}
Local aRetDir    := {}
Local aAreaAO3   := {}
Local cCodUsr	 := IIF(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr()) 	
Local nX         := 0
Local cBodyAux   := ""
Local cRootPath  := ""
Local cDrive     := ""
Local cDir       := ""
Local cDescri    := ""
Local cExten     := ""
Local cFile      := ""
Local cCodRastr  := ""

Local lProcessa  := .F.

Default cBody      := ""
Default lAuto      := .T.
Default lPreVisual := .F.

If !Empty(cBody)

   	cBodyAux := cBody

    //--------------------------------------------------------------------------
	//	 Verificando se Existe imagens no email, que deverão ser processadas
	//--------------------------------------------------------------------------
	If  (At( ".JPG", Upper(cBodyAux) ) > 0 .OR. At( ".PNG", Upper(cBodyAux) ) > 0 .OR. At( ".GIF", Upper(cBodyAux) ) > 0)

		If Select("AO3") > 0
			aAreaAO3 := AO3->(GetArea())
		Else
			DbSelectArea("AO3")// Usuarios CRM
		EndIf
		AO3->(DbSetOrder(1)) //AO3_FILIAL+AO3_CODUSR

		If AO3->(DbSeek(xFilial("AO3")+cCodUsr))
			cRootPath := AllTrim(AO3->AO3_IMGPTH)
			If Empty(cRootPath)
				lProcessa := .F.
				aRetDir := CRMA170VRO()

				If aRetDir[1]
					cRootPath := aRetDir[2]
					lProcessa := aRetDir[1]
				EndIf
			Else
				lProcessa := .T.
			EndIf
		EndIF


	   If lProcessa

		   //---------------------------------------------------
		   //	 Verificando a Chamda para pegar o campos certos
		   //---------------------------------------------------

		   	If IsInCallStack("CRMA230").OR. lPreVisual
			 	cCodRastr := AllTrim(SHA1(AO6->AO6_CODMOD))// Codigo rastreavel (hash do codigo da Atividade)
			ElseIf IsInCallStack("CRMA180")
				cCodRastr := AllTrim(SHA1(AOF->AOF_CODIGO))// Codigo rastreavel (hash do codigo da Atividade)
			EndIf

		   Do While At( Upper(cCodRastr), Upper(cBodyAux) ) > 0
				nPrimeiro := At( Upper(cCodRastr), Upper(cBodyAux) )
		       If nPrimeiro > 0

			       Asize(aExt,0)
			   		Aadd(aExt,At( ".JPG", Upper(cBodyAux) ))
			   		Aadd(aExt,At( ".PNG", Upper(cBodyAux) ))
			   		Aadd(aExt,At( ".GIF", Upper(cBodyAux) ))
					Asort(aExt)// Ordenando vetor em ordem ascendente

					For nX := 1 to Len(aExt)//pegando o menor valor diferente de 0
						If aExt[nX] > 0
							nSegundo := aExt[nX]
							loop
						EndIf
					Next nX

					If nSegundo > 0
				       nFim      := nSegundo - nPrimeiro
				    	cAux      := SubStr(cBodyAux, nPrimeiro, nFim+4) // Diretorio da imagem

				    	SplitPath( cAux ,@cDrive, @cDir, @cDescri, @cExten )
				       cFile := AllTrim(cDescri+cExten) // Nome do Arquivo

						aRetDwn := UpDowImg(CurDir(), AllTrim(cDescri+cExten), cRootPath , .T., /*lUpload*/, lAuto)//grava imagem na pasta CRMIMG no Pasta Local

						cBodyAux  := StrTran(cBodyAux,cAux,"")  //Substituindo diretorio por link
						If aRetDwn[1]
				       	cBody     := StrTran(cBody,cAux,aRetDwn[2]) //Substituindo diretorio por link
						EndIf
				   EndIf
		       EndIf
		   EndDo
		EndIf
	EndIf
EndIf

Return cBody


//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} UpDowImg()

Função para fazer o upload/Download da imagem, conforme o parametro passado

@param		ExpC1 = Corpo do email
			ExpC2 = Indica se o email está vindo da Maquina de origem das imagens.

@return	Nenhum

@author	Victor Bitencourt
@since		14/06/2014
@version   12.0

/*/
//--------------------------------------------------------------------------------------------------------------
Static Function UpDowImg(cPathOrigem, cFile, cPathDestino, lDownlaod, lUpload, lAuto)

Local lRetorno   := .T.
Local lExiste    := .F.
Local nret       := 0
Local cRet       := ""
Local cDirectory := "CRMIMG\"
Local cDirServer := "\CRMIMG"

Default cPathOrigem	 := ""
Default cPathDestino := ""
Default cFile		 := ""
Default lDownlaod	 := .F.
Default lUpload	  	 := .F.
Default lAuto  	  	 := .T.

Do Case
	Case lDownlaod

		If ExistDir(cPathDestino) .AND. File(cPathDestino+cFile)
			lExiste := .T.
			cRet := cPathDestino+cFile
		Else
			If  !ExistDir(GetTempPath()+cDirectory)
				nRet := MakeDir(GetTempPath()+cDirectory)
				cPathDestino := (GetTempPath()+cDirectory)
				If nRet <> 0
					If !lAuto
						Alert(STR0109 + cValToChar( FError() ) ) // "Não foi possível criar o diretório. Erro: "
						lRetorno := .F.
					EndIf
				EndIf
			Else
				cPathDestino := GetTempPath()+cDirectory
			EndIf
		EndIf

		If !lExiste
			If File(cDirServer+"\"+cFile)// verificando se existe na origem o arquivo para download
				If  !File(cPathDestino+"\"+cFile)
					lRetorno := CpyS2T( cDirServer+"\"+cFile, cPathDestino , .F. )
					If !lRetorno
						If !lAuto
							Alert(STR0110+Chr(10)+STR0111)//"Não conseguimos enviar as imagens para a pasta local."//"Por favor entre contato com Administrador do Sistema."
							lRetorno := .F.
						EndIf
	           	Else
						cRet := cPathDestino+cFile
				    EndIf
				Else
					 cRet := cPathDestino+cFile
				EndIf

			Else
				If !lAuto
					Alert(STR0113+cFile+STR0113+Chr(10)+STR0114)
					//"A Imagem "+//" não foi encontrada na pasta \crmimg no servidor, pode ter sido deletada ou nome foi alterado !"+//"Por favor entre contato com Administrador do Sistema."
					lRetorno := .F.
				EndIf
			EndIf
		EndIf

	Case lUpload

		If !ExistDir(cDirServer)
			nRet := MakeDir(cDirServer)
			If nRet <> 0 .AND. !lAuto
				Alert( STR0109 + cValToChar( FError() ) )
				lRetorno := .F.
			EndIf
		EndIf


		If !File(cDirServer+"\"+cFile)
			lRetorno := CpyT2S( cPathOrigem+cFile, cDirServer , .F. )

			If !lRetorno
				If !lAuto
					Alert(STR0116+Chr(10)+STR0117)
					//"Não conseguimos enviar as imagens para o servidor."+//"Por favor entre contato com Administrador do Sistema."
					lRetorno := .F.
				EndIf
			Else
				cRet := STR0115 //"Upload para o server efetuado com sucesso !"
			EndIf
		EndIf

EndCase

Return ({lRetorno,cRet})


//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA170ddT()

Função para fazer o download das imagens do email para pasta temporaria

@param		ExpC1 - Variavel contendo e corpo do email
			ExpC2 - Variavel contendo a Tag que deverá ser imcorporada no email

@return	cBodyMesc - email já com a Tag incluida

@author	Victor Bitencourt
@since		25/06/2014
@version   12.0

/*/
//--------------------------------------------------------------------------------------------------------------
Function CRMA170ddT(cBody, cTag)

Local nPosBody := 0
Local cBodyAux := ""

Default cBody := ""
Default cTag  := ""

If !Empty(cBody)
	cBodyAux := Upper(cBody)
	nPosBody := Rat("</BODY>",cBodyAux)

	If nPosBody > 0
		cBody := Stuff (cBody, nPosBody, 0, cTag)// Adiciona a tag no e-mail
	EndIf
EndIf

Return cBody


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA170StR()

Rotina para gravar o caminho local raiz das imagens anexadas ao e-mail

@param	  	Nenhum

@return   	cRootPath - Diretório escolhido pelo usuário

@author	Victor Bitencourt
@since		16/06/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMA170StR()

Local cRootPath := Space(100)
Local cPath     := Space(100)
Local cCodUsr	:= IIF(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr()) 	
Local aAreaAO3  := {}
Local lRet      := .F.
Local oDlg      := Nil
Local oPanel    := Nil

Private lMsErroAuto := .F.

If Select("AO3") > 0
	aAreaAO3 := AO3->(GetArea())
Else
	DbSelectArea("AO3")// Usuarios CRM
EndIf
AO3->(DbSetOrder(1)) //AO3_FILIAL+AO3_CODUSR


If AO3->(DbSeek(xFilial("AO3")+cCodUsr))
	cRootPath := AllTrim(AO3->AO3_IMGPTH)

	oDlg := FWDialogModal():New()
		oDlg:SetBackground(.F.) // .T. -> escurece o fundo da janela
		oDlg:SetTitle(STR0099)//"Caminho Raiz das Imagens"
		oDlg:SetEscClose(.T.)//permite fechar a tela com o ESC
		oDlg:SetSize(80,230) //cria a tela maximizada (chamar sempre antes do CreateDialog)
		oDlg:EnableFormBar(.T.)

		oDlg:CreateDialog() //cria a janela (cria os paineis)
		oPanel := oDlg:getPanelMain()
		oDlg:createFormBar()//cria barra de botoes
		oDlg:addYesNoButton()

		oTGet := TGet():New( 15,001,{||cRootPath},oPanel,0190,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cRootPath,,,, )

		DEFINE SBUTTON FROM 015, 198 TYPE 14 ACTION(cPath := cGetFile('*.*',,,,,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T.),IIF(Empty(cPath),"",cRootPath := cPath) , oTGet:Refresh() ) ENABLE OF oPanel
	oDlg:activate() //ACTIVATE DIALOG oDlg CENTERED

	If oDlg:getButtonSelected() > 0 // pegando a resposta do usuario na tela
		If !Empty(AllTrim(cRootPath))
			If AO3->(DbSeek(xFilial("AO3")+cCodUsr))
				RecLock("AO3",.F.)
					AO3->AO3_IMGPTH := cRootPath
				AO3->(MsUnlock())
			EndIf
		Else
			Aviso(STR0094,STR0098,{STR0095})//"Atenção"//"Selecione um diretório válido !"//"OK"
		EndIf
	EndIf
Else

	Aviso(STR0094,STR0097,{STR0095})//"Atenção"//"Para Configurar um diretório de imagem, é preciso ser usuário do CRM !"//"OK"

EndIf

If !Empty(aAreaAO3)
	RestArea(aAreaAO3)
EndIf

Return cRootPath

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA170VRO()

Rotina para Validar o diretório do usuario

@param	  	lRoot - indica se deverá mostrar a tela de cadastro de diretorio de imagem

@return   	aRet - aRet[1] (L) = se o diret´rop é valido ou não
					aRet[2] (C) = retorna o diretorio selecionado

@author	Victor Bitencourt
@since		16/06/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMA170VRO(lRoot)

Local aRet      := {Nil,Nil}
Local oTitulo2  :=  Nil
Local lResposta := .F.
Local lRetorno  := .F.
Local cRootPath := ""

Default lRoot   := .T.

If lRoot

	Aviso(STR0094,STR0096,{STR0095})//"Atenção"//"E-mail possui Imagens, No entanto nenhum diretório de imagem foi configurado para esse usuário do CRM !"//"OK"

	//-----------------------------------------------
	//		Montando tela para interação com usuario
	//-----------------------------------------------

	lResposta := FWAlertYesNo(STR0092, STR0088) //"DESEJA CADASTRAR UM DIRETÓRIO DE IMAGEM ?"//"Atenção"

	//------------------------------------------------------------------
	// caso o lResposta seja .T., chamará a tela para incluir diretório
	//------------------------------------------------------------------
	If lResposta
		cRootPath := CRMA170StR()
		If Empty(cRootPath)
			Aviso(STR0088,STR0091+CRLF+; //"Atenção"//"Não foi possivel cadastrar um diretório para este usuario do crm !"
	   			      		STR0090,{STR0089})//"Favor entrar em contato com o administrador do sistema."//"OK"
	   	Else
	   		lRetorno := .T.
		EndIf
	EndIf

	aRet[1] := lRetorno
	aRet[2] := cRootPath
Else
	Aviso(STR0094,STR0118,{STR0095})//"Atenção"//"Nenhum Diretório de Imagem foi encontrado !"//"OK"
EndIf

Return aRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA170Thr()

Rotina para processar a requisição de e-mail lido, está função sera executada por Thread
atravez da chamada da function CRM170READ

@param	  	aParam - Parametros com os dados da requisição

@return   	Nenhum

@author	Victor Bitencourt
@since		10/07/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMA170Thr(aParam)

//Local aParam    := Paramixb[1]
Local aAreaAOF  := {}
Local aExecAuto := {}
Local cChave    := ""
Local aDados    := {}

Private lMsErroAuto := .F.

cChave    := aParam[1][1]
aDados    := StrTokArr (cChave, "!" )
aDados[1] := StrTran (aDados[1],"@"," ")

RpcSetEnv(aDados[2],aDados[1])

Conout( STR0079 )//"CRM170READ, Preparando Ambiente!"

If !Empty( aDados[3] )

	If Select("AOF") > 0
		aAreaAOF := AOF->(GetArea())
	Else
		DbSelectArea("AOF")
	EndIf
	AOF->(DbSetOrder(6))//AOE_FILIAL+AOE_TOKEN

	If AOF->(DbSeek(xFilial("AOF")+aDados[3]))
		RecLock("AOF",.F.)// foi necessário atualizar dessa forma porque o mvc não enterpretava a alteração
			AOF->AOF_DTAEMA := MsDate()
			AOF->AOF_DTFIM  := MsDate()
			AOF->AOF_STATUS := STLIDO //Status de Lido
		AOF->(MsUnlock())
		Conout( STR0080 )//"CRM170READ, Atividade atualizada com sucesso !"
	Else
		Conout( STR0081 )//"CRM170READ, Atividade não encontrada !"
	EndIf
Else
	Conout( STR0082 )//"CRM170READ, Parametro obrigatório não informado !"
EndIf

If !Empty(aAreaAOF)
	RestArea(aAreaAOF)
EndIf

RpcClearEnv()

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA170GAT()

Rotina responsavel, pelo controle e execução dos gatilhos da tela de atividades

Function

@param	  	aParam - Parametros com os dados da requisição

@return   	Nenhum

@author	Victor Bitencourt
@since		10/07/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMA170GAT(cCampo)
  
Local xRet := Nil

Do Case 

	Case cCampo == "AOF_DTCONC"	
		If FwFldGet("AOF_STATUS") == "3" .OR. FwFldGet("AOF_STATUS") == "9"
          If Empty(FwFldGet("AOF_DTCONC")) 
		      	xRet :=  dDataBase
          Else
	          xRet := FwFldGet("AOF_DTCONC")
          EndIf            
		EndIf
	Case cCampo == "AOF_PERCEN"	
		
		If FwFldGet("AOF_STATUS") == "3"
              xRet := "5" 
		Else
		   If !Empty(FwFldGet("AOF_PERCEN"))
		   		xRet := FwFldGet("AOF_PERCEN")
		   	Else
		   		xRet := ""	
		   	EndIf	
		EndIf
EndCase

Return xRet
