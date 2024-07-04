#INCLUDE "PLSMGER.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "Fileio.ch"
#INCLUDE "PLMensView.CH"

#DEFINE GET_EMPTY "0002"
#DEFINE ROOM_STATUS {'Pendente Auditor','Pendente Prestador','Finalizado'}


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLMensView
    Funcao para gestao de mensagens PLX x HAT

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class PLMensView From PLMensCont

	Data cNome as String
	Data cCodRDA as String
	Data cNomeRDA as String
	Data cAlias as String
	Data cDescTipo as String
	Data cMatric as String
	Data cCodTipo as String
	
	Method New()

    Method openRoom()
	Method openRooBrw()
	Method openMsgBrw(aMensagem)
	Method msgFilter(aMensagens)
	Method getRoomDesc(cCodTipo)
	Method upFileBrows(cId,oListAnexo,aAnexList)
	Method vldPostMsg(cMessage,oListHist,aMensagens)
	Method attacFilter(aAnexList,cId)
	Method procFinRoom()
	Method downFileBr(aAnexList,nAtFile,lAllFiles)

EndClass

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe PLChatHAT
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method New(cNumGui) Class PLMensView

    _Super:new()

	B53->(DbSetOrder(1)) //B53_FILIAL+B53_NUMGUI+B53_ORIMOV
    if !Empty(cNumGui) .And. B53->(DbSeek(xFilial("B53")+cNumGui))
		self:cNome     := Alltrim(B53->B53_NOMUSR)
		self:cCodRDA   := B53->B53_CODRDA
		self:cNomeRDA  := Alltrim(Posicione("BAU",1,xFilial("BAU")+B53->B53_CODRDA,"BAU->BAU_NOME"))
		self:cAlias    := B53->B53_ALIMOV
		self:cDescTipo := self:getRoomDesc(B53->B53_TIPO)
		self:cMatric   := Transform(B53->B53_MATUSU, "@R 9999.9999.999999.99-9")
		self:setRoomKey(cNumGui)
	endIf

Return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} openRoom
    Funcao para gestao de mensagens PLX x HAT

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method openRoom() Class PLMensView

	Local lOpenRoom := .F.
	Local lComun    := .F.
	Local cMsgErro  := ''
	
	MsAguarde( {|| lComun := self:prGetRoom() }, STR0001 , STR0002, .F.) //'Mensageria' ## 'Carregando a sala de interações, aguarde...'
	
	if lComun
		//Sala ja existente, carrega as mensagens
		if !empty( self:getRoomId() )
			MsAguarde( {|| lComun := self:prGetMsg() }, STR0001 , STR0003, .F.)
			if lComun
				self:setStatB53(self:getRoomKey(),cValToChar(self:getStatus())) //Atualiza o status da sala
				lOpenRoom := .T.
			else
				cMsgErro := STR0004 //"Não foi possível carregar as mensagens da sala, contate o administrador do sistema."
			endIf
			
		//Nao foi encontrada a sala, deseja cria-la?
		elseIf self:getCodeErr() == GET_EMPTY
			if self:getAnalyzed()
				cMsgErro := STR0005 //"Esta guia ja foi analisada pelo auditor, não é possível abrir a sala."
			else
				if MsgNoYes(STR0006) //"Não há sala aberta para esta guia, deseja cria-la?"
					MsAguarde( {|| lComun := self:prPostRoom() }, STR0001 , STR0008, .F.) //'Criando a sala de interações, aguarde...'
					if lComun
						lOpenRoom := .T.
						self:setStatB53(self:cRoomKey,'1')
						MsAguarde( {|| self:prGetMsg() }, STR0001 , STR0003, .F.)
					else
						cMsgErro := STR0009 //"Não foi possível criar a sala de chat, contate o administrador do sistema."
					endIf
				endIf
			endIf
		endIf
	else
		cMsgErro := STR0010 //"Não foi possível carregar a sala de chat, contate o administrador do sistema."
	endif

	if lOpenRoom
		self:openRooBrw()
	elseIf !Empty(cMsgErro)
		MsgInfo(cMsgErro)
	endIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} openRooBrw
    Montagem de tela para gestao de mensagens PLX x HAT

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method openRooBrw() Class PLMensView

	Local oDlg		  := nil	
	Local aButtons 	  := {}
	Local nOpca		  := 0
	Local aMensagens  := {}
	Local nColunaIni  := 35
	Local cTitulo	  := STR0011 //"Mensageria"
	Local cMessage    := ""
	Local cDateRoom   := self:getDataMask(Substr(self:getCreaTim(),1,10))
	Local cTimeRoom   := Substr(self:getCreaTim(),12,8)
	Local cNumGui     := Transform(self:getRoomKey(), "@R 9999.9999.99.99999999")
	Local cDescTipo   := self:cDescTipo
	Local cNomeRDA    := self:cNomeRDA
	Local cCodRDA     := self:cCodRDA
	Local cNome       := self:cNome
	Local cMatric     := self:cMatric
	Local cStatusRoom := ROOM_STATUS[self:getStatus()]

	//Adiciona botoes adicionais
	aadd(aButtons,{"PEDIDO",{|| PLS790VAO('8') },STR0012, STR0012} ) //"Visualizar Guia"

	nTamVerti := 600
	nTamHoriz := 740

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO nTamVerti,nTamHoriz of oMainWnd PIXEL

	//Linha 1
	@ 035,010 SAY STR0013 SIZE 100,010 PIXEL OF oDlg //"Número Guia:"
	@ 042,010 MSGET cNumGui WHEN .F. SIZE 070,010 PIXEL OF oDlg

	@ 035,100 SAY STR0014 SIZE 100,010 PIXEL OF oDlg //"Matrícula:"
	@ 042,100 MSGET cMatric WHEN .F. SIZE 080,010 PIXEL OF oDlg

	@ 035,240 SAY STR0015 SIZE 100,010 PIXEL OF oDlg //"Nome Usuário:"
	@ 042,240 MSGET cNome WHEN .F. SIZE 120,010 PIXEL OF oDlg

	//Linha 2
	@ 060,010 SAY STR0016 SIZE 100,010 PIXEL OF oDlg //"Código RDA:"
	@ 067,010 MSGET cCodRDA WHEN .F. SIZE 050,010 PIXEL OF oDlg
	
	@ 060,100 SAY STR0017 SIZE 100,010 PIXEL OF oDlg //"Nome RDA:"
	@ 067,100 MSGET cNomeRDA WHEN .F. SIZE 120,010 PIXEL OF oDlg

	@ 060,240 SAY STR0018 SIZE 100,010 PIXEL OF oDlg //"Data Criação Sala:"
	@ 067,240 MSGET cDateRoom WHEN .F. SIZE 050,010 PIXEL OF oDlg

	@ 060,310 SAY STR0019 SIZE 100,010 PIXEL OF oDlg //"Hora Criação Sala:"
	@ 067,310 MSGET cTimeRoom WHEN .F. SIZE 050,010 PIXEL OF oDlg

	//Linha 3
	@ 085,010 SAY STR0020 SIZE 100,010 PIXEL OF oDlg //"Tipo:"
	@ 092,010 MSGET cDescTipo WHEN .F. SIZE 080,010 PIXEL OF oDlg

	//Linha 4
	@ 115,010 SAY STR0021 SIZE 100,010 PIXEL OF oDlg //"Adicionar Mensagem:"
	@ 122,010 GET cMessage Memo SIZE 210,040 PIXEL OF oDlg

	//Panel de Pendencia
	@ 115,240 SAY STR0022 SIZE 100,010 PIXEL OF oDlg //"Status Sala:"
	@ 122,240 MSGET cStatusRoom WHEN .F. SIZE 120,010 PIXEL OF oDlg
	
	//Interacoes
	@ nColunaIni + 140, 010 SAY STR0023 SIZE 100,010 PIXEL OF oDlg //"Histórico de Interações"

	oListHist := TCBROWSE():New(nColunaIni + 150, 010, nTamHoriz*0.47 ,100 ,,;
		{},{40,40},;
		oDlg,,,,, {||},, ,,,,,.F.,,.T.,,.F.,,, )

	oListHist:AddColumn(TcColumn():New(STR0024 ,{ || aMensagens[oListHist:nAt, 1] },"@C",nil,nil,nil,035,.F.,.F.,nil,nil,nil,.F.,nil)) //'Data Inter.'
	oListHist:AddColumn(TcColumn():New(STR0025 ,{ || aMensagens[oListHist:nAt, 2] },"@C",nil,nil,nil,035,.F.,.F.,nil,nil,nil,.F.,nil)) //'Hora Inter.'
	oListHist:AddColumn(TcColumn():New(STR0026 ,{ || aMensagens[oListHist:nAt, 3] },"@C",nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil)) //'Interação'
	oListHist:AddColumn(TcColumn():New(STR0027 ,{ || aMensagens[oListHist:nAt, 7] },"@C",nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil)) //'Anexos'
	oListHist:AddColumn(TcColumn():New(STR0028 ,{ || aMensagens[oListHist:nAt, 4] },"@C",nil,nil,nil,080,.F.,.F.,nil,nil,nil,.F.,nil)) //'Mensagem'

	oListHist:BLDBLCLICK := { || if( len(aMensagens) > 0, self:openMsgBrw(aMensagens[oListHist:nAt]), nil) } 
	oListHist:bChange :=  {|| oListHist:SetArray(self:msgFilter(aMensagens)), oListHist:Refresh()}
		
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg ,{|| nOpca := K_OK, self:vldPostMsg(cMessage,@oListHist,@aMensagens,@cStatusRoom),.F.}, {|| oDlg:End()},.F.,aButtons) Centered

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getRoomDesc
    Montagem de tela para gestao de mensagens PLX x HAT

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method getRoomDesc(cCodTipo) Class PLMensView

	Local cDescTipo := ''
	
	cCodTipo := Alltrim(cCodTipo)
	Do Case 
		Case cCodTipo == "1"
			cDescTipo := "Consulta"
		Case cCodTipo == "2"
			cDescTipo := "SADT"
		Case cCodTipo == "3"
			cDescTipo := "Internacao"
		Case cCodTipo == "4"
			cDescTipo := "Odontologico"
		Case cCodTipo == "5"
			cDescTipo := "Reembolso"
		Case cCodTipo == "6"
			cDescTipo := "Anexo Clinico"
		Case cCodTipo == "7"
			cDescTipo := "Outros"
		Case cCodTipo == "11"
			cDescTipo := "Prorrogacao de internacao"
	EndCase

Return cDescTipo

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} openMsgBrw
    Funcao para gestao de mensagens PLX x HAT

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method openMsgBrw(aMensagem) Class PLMensView

	Local oDlg
	Local nOpca     := 0
	Local cCadastro := STR0029 //'Visualizar Interação'
	Local aButtons  := {}
	Local aAnexList := {}
	Local lComun    := .F.
	
	Local cDate     := aMensagem[1]
	Local cTime     := aMensagem[2]
	Local cType     := aMensagem[3]
	Local cMsg      := aMensagem[4]
	Local cId       := aMensagem[5]
	Local cAnexo    := aMensagem[7]

	if cType == 'Auditor'
		aadd(aButtons,{"PEDIDO",{|| self:upFileBrows(cId,@oListAnexo,@aAnexList) },STR0030,STR0030} ) //"Adicionar Anexos"
	endIf
	aadd(aButtons,{"PEDIDO",{|| self:downFileBr(aAnexList,0,.T.) },STR0031,STR0031} ) //"Download Anexos"
	
	if !Empty(cDate) .And. !Empty(cTime) .And. !Empty(cMsg)

		if cAnexo == STR0038 .And. !empty(cId)
			MsAguarde( {|| lComun := self:prGetAttach(cId) }, STR0001 , STR0032, .F.) //'Carregando a mensagem, aguarde...'
			//Busca os anexos e seus links
			if lComun
				self:getAttach(cId)
			endIf
		endIf

		DEFINE MSDIALOG oDlg TITLE cCadastro FROM 10,0 To 600, 500 of oMainWnd PIXEL

		@ 035,010 SAY STR0033 SIZE 100,010 PIXEL OF oDlg //"Data Interação"
		@ 042,010 MSGET cDate WHEN .F. SIZE 045,010 PIXEL OF oDlg

		@ 035,080 SAY STR0034 SIZE 100,010 PIXEL OF oDlg //"Hora Interação"
		@ 042,080 MSGET cTime WHEN .F. SIZE 045,010 PIXEL OF oDlg

		@ 060,010 SAY STR0026 SIZE 100,010 PIXEL OF oDlg //"Interação"
		@ 067,010 MSGET cType WHEN .F. SIZE 100,010 PIXEL OF oDlg

		@ 090,010 SAY STR0035 SIZE 100,010 PIXEL OF oDlg //"Mensagem:"
		@ 097,010 GET cMsg Memo WHEN .F. SIZE 230,040 PIXEL OF oDlg

		//Anexos
		@ 150,010 SAY STR0036 SIZE 100,010 PIXEL OF oDlg //"Anexos:"
		oListAnexo := TCBROWSE():New(157,010,230,100 ,,;
			{},{40,40},;
			oDlg,,,,, {||},, ,,,,,.F.,,.T.,,.F.,,, )
			
		oListAnexo:AddColumn(TcColumn():New(STR0037,{ || aAnexList[oListAnexo:nAt, 1] },"@C",nil,nil,nil,080,.F.,.F.,nil,nil,nil,.F.,nil)) //'Arquivo'

		oListAnexo:BLDBLCLICK := { || if( len(aAnexList) > 0, self:downFileBr(aAnexList,oListAnexo:nAt), nil) } 
		oListAnexo:bChange :=  {|| oListAnexo:SetArray(self:attacFilter(aAnexList,cId)), oListAnexo:Refresh()}

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg ,{|| nOpca := K_OK, oDlg:End(),.F.}, {|| oDlg:End()},.F.,aButtons) Centered
		
	endIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} msgFilter
    Funcao para gestao de mensagens PLX x HAT

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method msgFilter(aMensagens) Class PLMensView

	Local oAux      := self:getMessages()
	Local nX        := 0
	Local cDate     := ""
	Local cTime     := ""
	Local cType     := ""
	Local cMsg      := ""
	Local cId       := ""
	Local cCreation := ""
	Local lAnexos   := .F.

	aMensagens := {}

	//Adiciona linha vazia
	if self:getCodeErr() == GET_EMPTY
		aadd(aMensagens, {cDate,;
							cTime,;
							cType,;
							cMsg,;
							cId,;
							cCreation,;
							iif(lAnexos,STR0038,STR0039) }) //'Sim' ## 'Nao'

	//Carrega as interacoes da sala
	else
		for nX := 1 to len(oAux['items'])
			
			cDate     := self:getDataMask(Substr(oAux['items',nX,'creationTime'],1,10))
			cTime     := Substr(oAux['items',nX,'creationTime'],12,8)
			cType     := iif(oAux['items',nX,'type']==1,'Auditor','Prestador')
			cMsg      := oAux['items',nX,'message']
			cId       := oAux['items',nX,'id']
			cCreation := oAux['items',nX,'creationTime']
			lAnexos   := oAux['items',nX,'hasAttachment']

			aadd(aMensagens, {cDate,;
							cTime,;
							cType,;
							DecodeUTF8(cMsg),;
							cId,;
							cCreation,;
							iif(lAnexos,STR0038,STR0039) })
		next
		aDadH := aSort(aMensagens,,, { |x,y| x[6] > y[6] } )
	endIf

return aMensagens


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} attacFilter
    Funcao para gestao de mensagens PLX x HAT

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method attacFilter(aAnexList,cId) Class PLMensView

	Local aAux := {}
	Local nX   := 0

	aAnexList  := {}	
	aAux := self:getAttach(cId)

	if len(aAux) > 0
 		for nX := 1 to len(aAux[3])
			aadd(aAnexList, {aAux[3,nX],;         //Arquivo
							 aAux[1]+aAux[3,nX],; //URL	
							 aAux[2] })           //Sas Token 
		next
	//Linha Vazia
	else
		aadd(aAnexList,{"","",""})
	endIf

return aAnexList


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} downFileBr
    Funcao para download de mensagens PLX x HAT

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method downFileBr(aAnexList,nAtFile,lAllFiles) Class PLMensView

	Local lHaveAnex  := .F.
	Local cMsg       := ""
	Local nX         := 0

	Default lAllFiles  := .F.

	//Verifica se os anexos com url/nome para serem baixados
	if lAllFiles
		for nX := 1 to len(aAnexList)
			lHaveAnex := !Empty(aAnexList[nX,1]) .And. !Empty(aAnexList[nX,2])
		next
	else
		lHaveAnex := !Empty(aAnexList[nAtFile,1]) .And. !Empty(aAnexList[nAtFile,2])
	endif

	if lHaveAnex
		cMsg := self:downFile(aAnexList,nAtFile,lAllFiles)
	elseIf lAllFiles
		cMsg := STR0040 //"Não foram encontrados arquivos anexados para esta mensagem."
	endIf

	if !empty(cMsg)
		Aviso(STR0007,cMsg,{ "Ok" }, 2 ) //"Atenção"
	endIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} upFileBrows
    Funcao para upload de mensagens PLX x HAT

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method upFileBrows(cId,oListAnexo,aAnexList) Class PLMensView

	Local cMsgAviso  := self:uploadFile(cId)
	
	if !empty(cMsgAviso)
		Aviso( STR0007,cMsgAviso,{ "Ok" }, 2 )
		//Atualiza Tela
		oListAnexo:SetArray(self:attacFilter(aAnexList,cId))
		oListAnexo:Refresh()
	endIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} vldPostMsg
    Faz validacoes e confirma o post de mensagem

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method vldPostMsg(cMessage,oListHist,aMensagens,cStatusRoom) Class PLMensView

	Local lRet      := .F.
	Local nStatRoom := 0
	Local cMsgRet   := ""
	Default cMessage := ""

	if Empty(cMessage)
		cMsgRet := STR0041 //"O campo 'Mensagem' é obrigatório."
	
	//elseIf Alltrim(cStatusRoom) == Alltrim(ROOM_STATUS[2])
	//	cMsgRet := "A sala está aguardando uma resposta do Prestador."

	elseIf Alltrim(cStatusRoom) == Alltrim(ROOM_STATUS[3])
		cMsgRet := STR0042 //"A sala já está finalizada."

	elseIf self:getAnalyzed()
		cMsgRet := STR0043 //"Esta guia já foi analisada pelo auditor."

	elseIf MsgYesNo(STR0044) //"Confirma a inclusão da Mensagem?"
			
		MsAguarde( {|| lRet := self:prPostMsg(cMessage,2) }, STR0001 , STR0045, .F.) //'Adicionando a mensagem, aguarde...'
		if lRet
			nStatRoom := self:getStatus()
			cStatusRoom := ROOM_STATUS[nStatRoom]
			self:setStatB53(self:getRoomKey(),cValtoChar(nStatRoom))

			MsAguarde( {|| self:prGetMsg() }, STR0001 , STR0045, .F.)
			cMsgRet := STR0046 //"Mensagem adicionada com sucesso."

			//Atualiza Tela
			oListHist:SetArray(self:msgFilter(aMensagens))
			oListHist:Refresh()
		else
			cMsgRet := STR0047 //"Não foi possível enviar a 'Mensagem' para a Mensageria."
		endIf
	endIf

	if !empty(cMsgRet)
		Aviso( STR0007,cMsgRet,{ "Ok" }, 2 )
	endIf	

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procFinRoom
    Finaliza uma sala ao realizar a auditoria

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method procFinRoom() Class PLMensView

	Local lRet    := .F.

	MsAguarde( {|| lRet := self:prGetRoom() }, STR0001 , STR0048, .F.) //'Finalizando a sala de interações, aguarde...'
	if lRet
		MsAguarde( {|| lRet := self:prPostMsg(self:getMsgEnd(),3) }, STR0001 , STR0048, .F.) //'Finalizando a sala de interações, aguarde...'
		if lRet
			self:setStatB53(self:getRoomKey(),'3')
		endIf
	endIf
	self:destroy()

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLMensageria
    Chamada mensageria

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Main Function PLMensageria(cNumGui)

	Local oMensageria := nil
	Local cMsg        := ''
	Local aRet        := {}
	Default cNumGui   := ""
	Private cCadastro := STR0001

	if Substr(cNumGui,11,1) == "9"
		B53->(DbSetOrder(1)) //B53_FILIAL+B53_NUMGUI+B53_ORIMOV
		if !Empty(cNumGui) .And. B53->(DbSeek(xFilial("B53")+cNumGui))
			oMensageria := PLMensView():New(cNumGui)
			aRet := oMensageria:vldDadAces()
			if aRet[1]
				oMensageria:openRoom()				
			else
				cMsg := aRet[2]
			endIf
		else
			cMsg := STR0049 //"Não foi encontrado o registro correspondente na auditoria (tabela B53)."
		endIf
	else
		cMsg := STR0050 //"A Mensageria está disponível somente para guias geradas no Portal Autorizador HAT."
	endIf

	if !empty(cMsg)
		MsgInfo(cMsg)
	endIf

Return