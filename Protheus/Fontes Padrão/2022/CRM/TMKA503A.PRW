#INCLUDE "TMKA503A.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "TMKDEF.CH"

#DEFINE NUMITENS 9999		//Nr. maximo de Itens na MsGetDados 
#DEFINE HASBUTTON := .F.

Static oObj 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºClasse    ³TeleServiceUserDialog ºAutor³ Vendas Clientes º Data ³  12/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     |Classe que contempla as funcionalidades da tela do atendimento do  º±± 
±±º          ³usuario.                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß     
*/
Class TeleServiceUserDialog From TeleServiceDialog 
Data oDlg
Data aCols
Data aHeader   
Data cEntValue 		//Valor da Chave de busca da entidade
Data cEntName		//Nome da entidade
Data cContValue		//Código do contato  
Data cCodLig		//Codigo da lista, utilizado quando lista de ativo
Data oHashDic		//Tabela contendo Chave e Valor dos dados passados pelo CTI. Ex: Chave: ADE_COD Valor:000001
Data lCCT			//Indica se a tela do atendimento pode ser finalizada sem o termino do atendimento.
Data nOpc			//Codigo de abertura de tela
Data aParScript		//Informacoes do script de atendimento
Data nStackSX8		//Armazena o codigo da pilha do SX8
Data lAssociating    
Data lAuto			//Indica se esta em modo automatico
Data lWereIncluded	//Se houve uma inclusão de atendimento ou não
Data lCopy			//Se deve inicializar campos por ser uma copia
Data aHeaderCopy	//Campos do cabecalho a serem copiados
Data aItemsCopy		//Campos do primeiro item a ser copiado

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Variáveis utilizadas para voltar as informações da tabela ADE³
³em caso de cancelamento de uma transferência de chamado	  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
data cGrpADEAnt //M->ADE_GRUPO
data cDesADEAnt //M->ADE_DESCGP
data cOpeADEAnt //M->ADE_OPERAD
data cNopADEAnt //M->ADE_NMOPER
data cPrdADEAnt	//M->ADE_PRDANT
data cCsbADEAnt	//M->ADE_CODSB1
data cNprADEAnt //M->ADE_NMPROD
data cAsuADEAnt //M->ADE_ASSUNT	
data cAsaADEAnt //M->ADE_ASSANT
data cCatADEAnt //M->ADE_CODCAT
data cCatDesAnt //M->ADE_NCATEG
data cOriADEAnt //M->ADE_CODORI
data cOriDesAnt //M->ADE_NORIGE
data cCauADEAnt //M->ADE_CODCAU
data cCauDesAnt //M->ADE_NCAUSA
data cEfeADEAnt //M->ADE_CODEFE	
data cEfeDesAnt //M->ADE_NEFEIT
data cCamADEAnt //M->ADE_CODCAM
data cCamDesAnt	//M->ADE_DSCCAM
data cCasADEAnt	//M->ADE_DESCAS

data aVarTrfAux

Method new() Constructor  
Method Init()
Method showDialog()
Method openBrowse()
Method bOK(oDlg, nOpc)
Method bCancel(oDlg, nOpc)
Method BuildCols(nOpc)
Method LoadButtonsLat(aBtnLat)
Method LoadSupButtons(aButtonSup)
Method GetModel(lVisFilDif)
Method Tk503ACols()
Method LoadHist()
Method ListHistMaster(aMaster, aTmpHeader, aTmpCols, aSeekHist)
Method ListHistDetail(aMaster,aDetail, oHistoryMaster, oHistoryDetail, aItHeader,aItCols)
Method SetInfo(cContact, cEntity, cEntValue)
Method SetHashDic(oHashDic)
Method SetCCT(lCCT)
Method TK503Discagem()
Method BuildHeader(cAlias)
Method CustomizeHeader()    
Method FillGetDad(aInfo, oTable, aTmpHeader, aTmpCols, aSeekHist)
Method LoadInformation(nOpc, aKeyInfo) 
Method SaveM(cAlias) 
Method RestM(aArea) 
Method Script()
Method GrvScript()
Method TmkOperador()
Method GetFields()
Method FillFields()
Method Tk503Browse()
Method LoadVarAntTrf()
Method LoadVarTrf()
Method ValTrfADE()

EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³New          ºAutor  ³ Vendas Clientes º Data ³  12/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo construtor da classe.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method new() Class TeleServiceUserDialog  
Self:Init()  
oObj := Self

Self:lWereIncluded := .F.

Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³New          ºAutor  ³ Vendas Clientes º Data ³  12/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo construtor da classe.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method Init() Class TeleServiceUserDialog  

Self:lReadOnly 		:= .F.
Self:service 		:= TeleServicing():New() 
Self:cEntValue 		:= "" 
Self:cEntName  		:= ""
Self:cContValue		:= "" 
Self:cCodLig 		:= "" 
Self:nOpc			:= 0
Self:aParScript		:= {} 
Self:nStackSX8		:= 0
Self:lAssociating	:= .F.
Self:lCCT			:= .T.
Self:lAuto			:= .F.
Self:lCopy			:= .F.
Self:aHeaderCopy	:= {}
Self:aItemsCopy		:= {}

Return Self  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMKA503A ³ Autor ³ IP - Vendas Clientes  ³ Data ³ 26/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Modelo de Teleatendimento (TeleServiceUserDialog)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MP10                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMKA503A(xAutoCab,xAutoItens,nOpcAuto,xRegCode)

Private aRecList   := {}	// vetor de recursos adicionais utilizada na funcao QAlocPMS no fonte QNCXFUN
Private lTmk503Auto:= .F.

oObj := TeleServiceUserDialog():New()

If xAutoCab <> Nil
	oObj:lAuto := .T.
	lTmk503Auto:= .T.
EndIf     

oObj:openBrowse(xAutoCab,xAutoItens,nOpcAuto,@xRegCode)
Return .T.   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³openBrowse   ºAutor  ³ Vendas Clientes º Data ³  09/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe a tela de escolha do modelo de atendimento.           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method openBrowse(xAutoCab,xAutoItens,nOpcAuto, xRegCode, aRotOpc) Class TeleServiceUserDialog

//Local aCores    	:= {	{"(.F.)" , "BR_VERMELHO" },;	//  "Pendente"
//   						    {"(.T.)" , "BR_VERDE"    }}		//  "Encerrado"


Local cAliasUser	:= "" 		// Alias da tabela Master (a partir do configurador)
Local cAt503Fil		:= ""		// Filtro fornecido pelo ponto de entrada
Local bFiltraBrw	:= {||}		// Bloco de código para execução do filtro
Local aIndex		:= {}		// Indice da tabela
Local cFiltra		:= ""		// Filtro utilizado no bloco de código executado para ativar o filtro
Local cTeleServID	:= ""		// Armazena o codigo do TeleAtendimento associado ao Grupo do Operador.
             
Default aRotOpc		:= MenuDef()	// Carrega o aRotinas padrão para tela de TeleAtendimento
Private aRotina		:= aRotOpc		// Variavel utilizada no mBrowse da tela
Private aCores 		:= {} 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega o modelo de atendimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTeleServID := Self:GetModel()
If !Empty(cTeleServID)
	If Self:service:load(cTeleServID)
		cAliasUser := Self:service:tableStructureInfo:master:alias
		 
		//Private aRotina 	:= MenuDef()	//Montagem do menu funcional (?)
		DbSelectArea(cAliasUser)  
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a existencia de Filtros na MBrowse                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (ExistBlock("TK503AFIL"))
			cAt503Fil := ExecBlock("TK503AFIL",.F.,.F.)
			If ( ValType(cAt503Fil) == "C" ) .And. !Empty(cAt503Fil)
				cFiltra := cAt503Fil
			EndIf
			bFiltraBrw 	:= {|| FilBrowse(cAliasUser,@aIndex,@cFiltra) }
			Eval(bFiltraBrw)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Endereca a funcao de BROWSE                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpcAuto == Nil
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Incluida chamada de função para atualização³
			//³do modelo de atendimento do Service Desk   ³
			//³na inicialização do TeleAtendimento        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TMKA510LOAD()


			
			DbSetOrder(1)
			DbSeek(xFilial(cAliasUser))

			MsgRun(STR0033, STR0034, {||Self:Tk503Browse(cAliasUser) }) // "Aguarde...Carregando informações" # "Teleatendimento"
			
		Else     
	
			Private lTk503Auto		:= .T.
			Private aAutoCab		:= xAutoCab
			Private aAutoItens		:= xAutoItens
			Private xRegisterCode 
			MBrowseAuto(nOpcAuto,Aclone(aAutoCab),cAliasUser)
			xRegCode := xRegisterCode	
		EndIf		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty( cFiltra ) .AND. Len( aIndex ) > 0
			EndFilBrw( cAliasUser, aIndex )
		EndIf

	EndIf
EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³GetModel     ºAutor  ³ Vendas Clientes º Data ³  12/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo responsavel por retornar o modelo de atendimento a   º±±
±±º          ³ser utilizado                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method GetModel(lVisFilDif) Class TeleServiceUserDialog

Local cModelo := ""		//Cod. do modelo de atendimento

DEFAULT lVisFilDif := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o USUARIO nao estiver cadastrado em OPERADORES e nao tiver	³
//³ um Posto de Venda associado nao entra na rotina					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Self:lAuto .AND. !TMKOPERADOR(,,lVisFilDif)
	If !IsBlind()
		Help("  ",1,"OPERADOR")
	Else
		cModelo := SU0->U0_CODSKA	
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pega o modelo no grupo de atendimento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cModelo := SU0->U0_CODSKA
EndIf

If Empty(cModelo)
	Help( " ",1,"TSOPERAD",,STR0028 + CRLF + STR0029 + CRLF + STR0030 + CRLF  + CRLF + STR0031  + CRLF + STR0032,1,1) // "- Operador relacionado a um " # "Grupo de Atendimento que não atende o " # "TeleAtendimento. " # "- Verificar as configurações do" # "Grupo de Atendimento"
EndIf
Return cModelo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³TK503AOpc    ºAutor  ³ Vendas Clientes º Data ³  09/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe a tela para configurar um novo modelo de atendimento  º±±
±±º          ³conforme a opcao selecionada.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK503AOpc(cAlias, nReg, nOpc, aCampos, aCopia)                                                       
Local lRet 			:= .F.		//Retorno da funcao
Local cTeleServID		:= ""
Local lLocalObj		:= .F.
Local lVisualiza 		:= .T. 		//Controla a visualizacao do chamado que esta em atendimento por outro usuario
Local aRegsWF 		:= {}
Local aParam			:= {}
Local nX				:= 0

Private aHeader		:= {}		//Array contendo o cabecalho dos campos
Private aCols 		:= {}		//Array com os itens do atendimento incluidos na MsGetDados   

If Type("aRotina") == "A"
	nOpc := aRotina[nOpc][4]
EndIf

DbSelectArea(cAlias)
If nOpc <> 3
	DbGoto(nReg)
EndIf

//Se for alteração verifica se o chamado está bloqueado, caso contrário faz o bloqueio.
If nOpc == 4 .And. !TK510UsrLock("L", ADE->ADE_CODIGO, TkOperador(), Nil, @lVisualiza) 
	If !( Type("lTk503Auto") <> "U" .AND. lTk503Auto ) .And. lVisualiza
		nOpc := 2	//Se não for rotina automática, abre o chamado no modo de visualização, pois está bloqueado para outro operador.
	Else
		Return .F.	//Se for rotina automática, aborta o processamento.
	EndIf
EndIf

If oObj == Nil 
	oObj := TeleServiceUserDialog():New()
	lLocalObj := .T.
EndIf

If aCopia <> Nil
	oObj:lCopy			:= .T.
	oObj:aHeaderCopy	:= aClone(aCopia[1])
	oObj:aItemsCopy		:= aClone(aCopia[2])
	aCopia := Nil	
EndIf 

cTeleServID := oObj:GetModel(IIf(nOpc==2,.T.,.F.)) 

If !Empty(cTeleServID)

	If (oObj:service == Nil) .OR. (AllTrim(oObj:service:id) <> AllTrim(cTeleServID))
		oObj:service := TeleServicing():New() 
   		oObj:service:load( cTeleServID )
 	EndIf

	If nOpc == 2 
		ALTERA:=.F.     		
		oObj:nOpc := nOpc
		oObj:lReadOnly := .T.	
		oObj:showDialog(, nOpc)	//"Visualizar" //"Visualizar"
		
	ElseIf nOpc == 3
		oObj:nOpc := nOpc
		oObj:lReadOnly := .F.
		If oObj:showDialog(, nOpc) //"Incluir" //"Incluir"
			BEGIN TRANSACTION
				BEGIN SEQUENCE
					oObj:service:tableStructureInfo:save()
					aParam := {aHeader,aCols,oObj:nOpc,aRegsWF}
					oObj:service:whenRecorded:execute(@aParam)
					lRet := .T.
				RECOVER
					DisarmTransaction()
					If !IsBlind()
						Final()
					Else
						lRet := .F.
					EndIf
				END SEQUENCE
			END TRANSACTION
		EndIf
	
	ElseIf nOpc == 4	     
		oObj:nOpc := nOpc 
		oObj:lReadOnly := .F. 
		If oObj:showDialog(, nOpc)	//"Alterar" //"Alterar"
			BEGIN TRANSACTION
				BEGIN SEQUENCE
					oObj:service:tableStructureInfo:save()
					aParam := {aHeader,aCols,oObj:nOpc,aRegsWF}
					oObj:service:whenRecorded:execute(@aParam)
					lRet := .T.
				RECOVER
					DisarmTransaction()
					If !IsBlind()
						Final()
					Else
						lRet := .F.
					EndIf
				END SEQUENCE
			END TRANSACTION
		EndIf 
	EndIf

	If lRet .And. (nOpc == 3 .Or. nOpc == 4)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa rotina de envio de workflow         |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len(aParam[4])
			Tk510WF(aParam[4][nX][1],aParam[4][nX][2],aParam[4][nX][3])
		Next nX
	EndIf
		    
	//Limpa as informacoes de cabecalho e itens armazenadas no objeto
	oObj:service:tableStructureInfo:clear() 
	
Else
	Help( " ",1,"TSOPERAD",,STR0028 + CRLF + STR0029 + CRLF + STR0030 + CRLF  + CRLF + STR0031  + CRLF + STR0032,1,1) // "- Operador relacionado a um " # "Grupo de Atendimento que não atende o " # "TeleAtendimento. " # "- Verificar as configurações do" # "Grupo de Atendimento"
EndIf

If lLocalObj 
	TMKFree( oObj )
EndIf

Return lRet  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ showDialog ³ Autor ³ IP - Vendas Clientes³ Data ³ 26/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Responsavel pela interface do usuario de TeleAtendimento   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void showDialog(ExpC1,ExpN1,ExpN2)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKA503A                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method showDialog(cAction, nOpc) Class TeleServiceUserDialog 
Local oTkSelf		:= Self
Local aPosObj   := {} 			//Array com as posicoes do objeto
Local aObjects  := {} 			//Array do objeto
Local aInfo		:= {}			//Array com as coordenadas 
Local aSize     := {}			//Array dos valores de dimensionamento da tela
Local aPosObj2	:= {}			//Array com as posicoes do objeto da Toolbar Lateral
Local nOpcA 	:= 1			//Indica a continuacao do processo
Local nButton	:= 0			//Indice do array de botoes laterais
Local nAux		:= 0			//Variavel auxiliar (contador)
Local lRet		:= .T.			//Indica retorno da funcao
Local lCheckRet	:= .F.			//Indica se deve agendar retorno de atendimento
Local oDlg		:= Nil			//Objeto Dialog principal
Local cAliasUser:= Self:service:tableStructureInfo:master:alias				//Alias da tabela cabecalho do TeleAtendimento
Local aKeyInfo	:= {}			//Campos da chave principal
Local aBtnLat	:= {}			//Array dos botoes laterais
Local aButtonSup:= {}			//Array com os botoes da Toolbar Superior
Local bOk		:= {|| nOpcA:=0,If(Type("oGetD")=="O",aCols:=oGetD:aCols,),::aVarTrfAux := aVarTrf,Tk503ALinOk(),If(lAltTransf,::ValTrfADE(),),IIf(oTkSelf:bOk(oDlg,oTkSelf:nOpc,lCheckRet,dRetorno,cHoraRet),nOpcA:=0,nOpcA:=1),TK700VldTelMail(M->ADE_DDDRET,M->ADE_TELRET,M->ADE_EMAIL)}
Local bCancel	:= {|| nOpcA:=1,oTkSelf:bCancel(oDlg,oTkSelf:nOpc) }	//CodeBlock para o botao Cancel
Local oChkRetorno:= Nil					//Objeto CheckBox p/ indicar o Retorno
Local oDataRet	:= Nil					//Objeto GET para informar a data de retorno
Local oHoraRet	:= Nil					//Objeto GET para informar a hora de retorno
Local dRetorno	:= Date()		//Variavel para informar a data de retorno
Local cHoraRet	:= "00:00"				//Variavel para informar a hora de retorno
Local nI		:= 0
Local aCfgBtn	:= {}			//Armazena os acessos na toolbar que o operador possue
Local lNotOper	:= .T.			//Indica se achou o operador associado ao usuario protheus
Local cTitle	:= ""
Local cField	:= ""                         
Local lRetAbre	 
Local nOpcAux
Local aFields	:= {}			//Campos utilizados na MsMGet
Local aFolder	:= {}			//Pastas da MsmGet
Local aAltUsr := {}			//Campos customizados retornados do ponto de entrada para possibilitar edição seguindo regra do parametro MV_TMKEDI
                             
Private aAlterADF	:= {}		//Array contendo os campos para alteracao
Private cCampo  	:= ""		//Nome do campo
Private oGetd		:= Nil		//Objeto MsGetDados
Private oEnchTk503	:= Nil		//Objeto Enchoice
Private aTela		:= {}		//Array passado na funcao Obrigatorio
Private aGets		:= {}		//Array passado na funcao Obrigatorio
Private cCadastro 	:= STR0005 	//"Atendimento" 
Private N			:= 1

Private aVarTrf		:= {}
Private aTrfAux		:= {}
Private aTrfVld		:= {}
Private lAltTransf	:= .f.

Default cAction := ""

If Type("aRotina")=="U"
	Private aRotina 
EndIf

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("ADF")
While ( !Eof() .And. SX3->X3_ARQUIVO == "ADF" )
	If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_CAMPO <> "ADF_FILIAL" )
		If SX3->X3_VISUAL <> "V"
			Aadd(aAlterADF, AllTrim(SX3->X3_CAMPO) )
		EndIf
	EndIf
	SX3->(dbSkip())
EndDo

If ExistBlock("TK503CMP")
	aAltUsr := Execblock("TK503CMP",.F.,.F.,aAlterADF)
	If ValType(aAltUsr) == "A"
		aAlterADF := aClone(aAltUsr)
	EndIf
EndIf

Self:nOpc := nOpc   
Self:aParScript:= {} 
Self:nStackSX8 := GetSX8Len()

For nI := 1 To Len(Self:service:tableStructureInfo:master:PkFields)
	aAdd(aKeyInfo, Self:service:tableStructureInfo:master:PkFields[nI]:name )
Next nI

RegToMemory(cAliasUser,.F.,,.F.)                                                   
Self:LoadInformation(nOpc, aKeyInfo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega array com os acessos que o operador ja tem configurado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU7")
DbSetOrder(4)
If MsSeek( xFilial("SU7") + RetCodUsr() )
	lNotOper := .F.
EndIf

If  !( Type("lTk503Auto") <> "U" .AND. lTk503Auto )

	If !Empty(SU7->U7_CFGBTN) .AND. !lNotOper
		For nI := 1 TO Len(SU7->U7_CFGBTN)+2	//tirar isso
			AAdd( aCfgBtn, {(SubStr(SU7->U7_CFGBTN,nI,1) == "1" .OR. Empty(SubStr(SU7->U7_CFGBTN,nI,1))),Nil} )
		Next nI
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Assume que todos os botoes estarao habilitados se ainda nao foram configurados no cadastro de operadores³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI := 1 TO 35
			AAdd(aCfgBtn,{.T.,Nil})
		Next nI
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carregar os botoes das ToolBar Lateral e Superior ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Self:LoadButtonsLat(@aBtnLat)
	Self:LoadSupButtons(@aButtonSup, aCfgBtn, @oTkSelf)   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define os valores de dimensionamento da tela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize    := MsAdvSize(.T.,.F.,400) 
	aObjects := {} 
	aAdd( aObjects, { 090, 090, .T., .T. } )
	aAdd( aObjects, { 015, 010, .F., .F. } )	
	aAdd( aObjects, { 090, 090, .T., .T. } )

	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
	If Len(aBtnLat) > 0 
		aInfo[1]+=27
	EndIf	
	aPosObj := MsObjSize( aInfo, aObjects )
	                                   
	//Consulta do historico de ligacoes 
	SetKey(VK_F10, {|| Self:LoadHist()})
	
	If !Empty(cAction)
		cTitle := " - " + Upper(cAction)
	Else
		If nOpc == 2
			cTitle := " - " + Upper(STR0001)	//"Visualizar"
		ElseIf nOpc == 3
			cTitle := " - " + Upper(STR0002)	//"Incluir"
		ElseIf nOpc == 4
			cTitle := " - " + Upper(STR0003)	//"Alterar"
		EndIf
	EndIf 
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Informa ao gerenciador de múltiplos grupos de atendimento³
	//³que a rotina teleatendimento está em execução.           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TK091Start( TELEATENDIMENTO )
		
	DEFINE MSDIALOG oDlg TITLE STR0005 + " - " + TK091Titulo(TkOperador()) + cTitle FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL //"Atendimento"
    	
	aObjects := {}
	For nButton:= 1 To Len(aBtnLat)		  			 	//"n" Botoes do usuario da toolbar lateral
		aAdd( aObjects, { 27, 27, .F., .F., .T. } )
	Next nButton 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Divide a tela verticalmente para os botoes da barra lateral  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	aSize2   := aPosObj[1]                                                                                 
	aInfo    := { aSize2[ 2 ]+4, aSize2[ 1 ]+9, aSize2[ 4 ], aSize2[ 3 ], 0, 0 } 
	aPosObj2 := MsObjSize( aInfo, aObjects, .F. , .F. )
	aFields	 := Self:GetFields(cAliasUser,Self:GetModel(IIf(nOpc==2,.T.,.F.)),Self:Service:TableStructureInfo:Master:Fields,@aFolder)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Enchoice e MsGetDados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 		
	oEnchTk503 := MsMGet():New(cAliasUser, /*nReg*/, nOpc, ,,,,aPosObj[1],,,,,,,,.T.,.F.,NIL,.F.,,aFields,aFolder) 	//"Quanto a exclusao ?"//MsMGet():New("SUC", nReg, nOpc, aAC,"AC",STR0051,,aPosObj5[1],,,,,,oFolderTmk,,.T.,.F.,NIL,.T. ) 	//"Quanto a exclusao ?"
	oGetd := 	MsNewGetDados():New(aPosObj[3,1],aPosObj[3,2],aPosObj[3,3]-15,aPosObj[3,4],IIf(!INCLUI.And.!ALTERA,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
				"Tk503ALinOk",;
				"Tk503ATudOk",;
				IIf(!Empty(Self:service:tableStructureInfo:initGDField:name),"+"+Self:service:tableStructureInfo:initGDField:name,""),;
				aAlterADF,/*nFreeze*/,999,/*cFieldOk*/,/*uSuperDel*/,/*uDelOk*/,oDlg,aHeader,aCols)

	oGetD:bDelOk := {|| Tk503ADelOk(nOpc) }
	aCols := oGetD:aCols 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa campos provenientes da copia de chamados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Self:lCopy
		Self:FillFields()
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem dos botoes da barra lateral da tela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nAux := 0
	For nButton := 1 To Len(aBtnLat)
		nAux++
		
		TBtnBmp2():New( aPosObj2[ nAux,1 ]+30, aPosObj2[ nAux,2 ], aPosObj2[ nAux,3 ], aPosObj2[ nAux,4 ],;
						aBtnLat[nButton,1],	NIL, NIL,NIL,;
						aBtnLat[nButton,2], oDlg, aBtnLat[nButton,3], NIL, NIL,NIL )
	
	Next nButton
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campos para agendamento de retorno ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aPosObj[2,1],030 CHECKBOX oChkRetorno VAR lCheckRet PROMPT STR0006 SIZE 50,17 OF oDlg PIXEL WHEN {||oDlg:Refresh()} //"Agendar retorno? "
	@ aPosObj[2,1],090 SAY STR0007 OF oDlg PIXEL //"Data:" 
	@ aPosObj[2,1],105 MSGET oDataRet VAR dRetorno Picture "@D 99/99/99" SIZE 40,08 PIXEL OF oDlg WHEN lCheckRet  
	@ aPosObj[2,1],150 SAY STR0008 OF oDlg PIXEL //"Hora:" 
	@ aPosObj[2,1],165 GET oHoraRet VAR cHoraRet Picture PesqPict('AB3','AB3_HORA') SIZE 30,08 PIXEL OF oDlg WHEN lCheckRet CENTER
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Desabilita a tecla ESC³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDlg:lEscClose := .F.
	
	Self:oDlg:=oDlg        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa P.E. na abertura da janela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRetAbre := Self:service:whenOpenWindow:execute({aHeader,aCols,Self:nOpc, oGetd, aButtonSup, aBtnLat, oEnchTk503})	
	If ValType(lRetAbre) <> "L"
		lRetAbre := .T.
	EndIf	           
	If !lRetAbre
		nOpcAux := oTkSelf:nOpc
		oTkSelf:nOpc := 2
	EndIf	
		
	//Carrega variáveis para cancelamento de transferência
	::LoadVarAntTrf()
	::LoadVarTrf()
	
	ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,bOk,bCancel,,aButtonSup,,,,.F.), IIf(!lRetAbre,Eval(bCancel),.T.) );
	VALID IIf(nOpcA==0 .OR. !lRetAbre,.T.,IIf(oTkSelf:bCancel(oDlg,oTkSelf:nOpc), (nOpcA:=1,.T.), .F.))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Informa ao gerenciador de múltiplos grupos de atendimento³
	//³que a rotina teleatendimento não está mais em execução.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TK091End( TELEATENDIMENTO )	
	
	If !lRetAbre
		oTkSelf:nOpc := nOpcAux
	EndIf		
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ao encerrar a tela : Limpa as teclas de atalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	SetKey(VK_F10,	{ || AllWaysTrue() } )

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Execucao pela rotina automatica ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If EnchAuto(cAliasUser,aAutoCab,{|| Obrigatorio(aGets,aTela)},aRotina[nOpc][4]) .AND.;
		MsGetDAuto(aAutoItens,"Tk503ALinOk",{|| Tk503ATudOk() .AND. Tk503ALinOk() },aAutoCab,aRotina[nOpc][4])
		
		nOpcA := 0
		Eval( bOk )
	Else
		nOpcA := 1
	EndIf
EndIf             
	
If nOpcA == 1                       
	lRet := .F.	
Else
	cField := AllTrim(Self:service:tableStructureInfo:registerCode:name)                                 
	If !Empty(cField)
		xRegisterCode := M->&(cField) 
	EndIf                           
EndIf

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³BuildCols ºAutor  ³ Vendas Clientes    º Data ³  11/23/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo responsavel pela construcao do aHeader e aCols da   º±±
±±º          ³ rotina                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method BuildCols(nOpc) Class TeleServiceUserDialog

Local cAliasDetail := Self:service:tableStructureInfo:detail:alias		//Alias da tab. Detail
Local bMontCols	:= {|| Self:Tk503ACols() }								//Bloco de codigo para montagem do aCols

If Len(aHeader) == 0 .AND. Len(aCols) == 0
	FillGetDados(	nOpc			,cAliasDetail	,1					,/*cSeek*/		,;
					/*{||&cWhile}*/	,{|| .T. }		,/*aNoFields*/		,/*aYesFields*/	,; 
					/*lOnlyYes*/	,/*cQuery*/		,bMontCols			,.T.			)
EndIf

Self:CustomizeHeader(aHeader)
                                                            
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³Tk503AColsºAutor  ³ Vendas Clientes    º Data ³  11/23/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo responsavel pela montagem do aCols a partir dos     º±±
±±º          ³ dados contidos no objeto (chamado a partir da FillGetdados)º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method Tk503ACols() Class TeleServiceUserDialog
Local cAliasDetail := Self:service:tableStructureInfo:detail:alias	//Alias da tabela detalhe
Local nUsado:= Len(aHeader)											//Nr. de campos no aHeader
Local nI	:= 0													//Usado em lacos For...Next
Local nLin	:= 0													//Linhas do aCols
Local aArea := GetArea()
Local nCount := 0

aCols := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Popular o aCols com as linhas de registro do Obj. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCount := 1 To Len(Self:service:tableStructureInfo:detail:rows)
	aAdd(aCols,Array(nUsado+1))
	nLin := Len(aCols)
                        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ler os campos do aHeader para montagem do aCols³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 To nUsado
		cCampo := aHeader[nI][2]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pesquisa a posicao do campo no Objeto ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nFields := aScan(Self:service:tableStructureInfo:detail:rows[nCount]:fields, { |x| Upper(x:name) == Upper(cCampo) } )
		If nFields > 0
			If ( aHeader[nI,10] <>  "V" )
				aCols[nLin][nI] := Self:service:tableStructureInfo:detail:rows[nCount]:fields[nFields]:value:value
			Else
				aCols[nLin][nI] := CriaVar(cCampo,.T.)
			EndIf
		ElseIf IsHeadRec(cCampo)	//Recno
        	aCols[nLin][nI] := Self:service:tableStructureInfo:detail:rows[nCount]:rowId
 		ElseIf IsHeadAlias(cCampo)	//Alias
			aCols[nLin][nI] := cAliasDetail	
		EndIf
	Next nI                         
	aCols[nLin][nUsado+1] := .F.
	
Next nCount

RestArea(aArea)
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³LoadButtonºAutor  ³ Vendas Clientes    º Data ³  11/23/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo responsavel por carregar os botoes da Toolbar       º±±
±±º          ³ lateral                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method LoadButtonsLat(aBtnLat) Class TeleServiceUserDialog           
Local nI := 0     				//Usado em lacos For...Next
Local cCodeBlock := ""			//Conteudo do CodeBlock (caracter) p/ o botao
Local bCodeBlock := {||.T.}		//Codeblock a ser executado p/ o botao

For nI := 1 To Len(Self:service:ToolbarSide:aButtons)
	If cNivel >= Val(Self:service:toolbarSide:aButtons[nI]:userLevel) 
		cCodeBlock := "Self:service:toolbarSide:aButtons["+StrZero(nI,3)+"]:execute()"
		bCodeBlock := (&("{|| " + cCodeBlock + "}"))
		aAdd(aBtnLat,	{	Self:service:toolbarSide:aButtons[nI]:imageName,;
							bCodeBlock,;
							Self:service:toolbarSide:aButtons[nI]:name,;
							Self:service:toolbarSide:aButtons[nI]:toolTipText })
	EndIf
Next nI

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³ bOK      ºAutor  ³ Vendas Clientes    º Data ³  11/23/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo acionado quando o usuario clicar o botao OK         º±±
±±º          ³ Efetua atualizacoes do aCols para o Objeto                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method bOk(oDlg, nOpc, lSchedule, dDateSchedule, cHourSchedule) Class TeleServiceUserDialog
Local lRet := .T.	//Indica o retorno da funcao
Local cCodUsr		//Codigo do usuário no Protheus       
Local cSeek	:= ""			//Chave de busca pelo registro do chamado, utilizado na criação da lista de pendencia
Local lWhenRecord := .T.	//Retorno do Ponto de Entrada
Local lContinua := .T.		//Indica se continua a execucao da funcao
Local nFields	:= 0
Local nCount	:= 0 
Local nObjActRow:= 0

If nOpc <> 2
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a ação escolhida envia um workflow com anexo        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !( Type("lTk503Auto") <> "U" .AND. lTk503Auto )	
		If !EMPTY(SUQ->UQ_WFTEMPL) .And. Posicione("SKY",1,xFilial("SKY")+SUQ->UQ_WFTEMPL,"KY_ANEXA") == "1"
			If !MSGYESNO(STR0070, STR0071)//"Ação escolhida enviará um Workflow. Deseja continuar a gravação?"## "Envio de WorkFlow"
	   			Return(.F.)
   			EndIf
   		EndIf
   	EndIf	 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Permite executar P.E. quando clicar OK ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lContinua := Self:service:whenPressedOKBtn:execute({aHeader,aCols,Self:nOpc,Self:aParScript})
	If ValType(lContinua)!="L"
		lContinua := .T.	
	EndIf	                                    
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacao de campos obrigatorios       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua
		If !( Type("lTk503Auto") <> "U" .AND. lTk503Auto )	
			lContinua := oGetD:TudoOk() .AND. Obrigatorio(aGets,aTela) 
		EndIf
	EndIf    
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Permite executar P.E. antes da gravacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If lContinua
		lWhenRecord := Self:service:whenRecord:execute({aHeader,aCols,Self:nOpc})
		If ValType(lWhenRecord) == "L"
			lContinua := lWhenRecord
		EndIf		
	EndIf   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacao de campos obrigatorios       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua
		If !( Type("lTk503Auto") <> "U" .AND. lTk503Auto ).AND. Procname(1)<>'TK510ATUCHAM'	
			lContinua := oDlg:End() 
		EndIf
	EndIf 	
EndIf

If lContinua .AND. nOpc <> 2
	If nOpc == 3	//INCLUSAO
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adicionar a linha e os campos no Master ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
		Self:service:tableStructureInfo:master:addrow()
		For nFields := 1 To Len(Self:service:tableStructureInfo:master:fields)
			cField := Self:service:tableStructureInfo:master:fields[nFields]
			Self:service:tableStructureInfo:master:rows[1]:addField( cField:clone() )
		Next nFields

		//Insere e preenche valor nos campos da chave
		oPkFields := Self:service:tableStructureInfo:master:PkFields
		For nFields :=1 To Len(oPkFields)
			Self:service:tableStructureInfo:master:rows[1]:addPkField( oPkFields[nFields]:clone() )
			cField := oPkFields[nFields]:name
			If !("FILIAL" $ cField)
				Self:service:tableStructureInfo:master:rows[1]:PkFields[nFields]:value:value := M->&(oPkFields[nFields]:name)
			Else
				Self:service:tableStructureInfo:master:rows[1]:PkFields[nFields]:value:value := xFilial(Self:service:tableStructureInfo:master:alias)
			EndIf
		Next nFields			
		
		Self:lWereIncluded := .T.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Transfere dados da tab. Master para o Objeto  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCount := 1 To Len(Self:service:tableStructureInfo:master:rows)
		For nFields := 1 To Len(Self:service:tableStructureInfo:master:rows[nCount]:fields)
			cField := Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:name
			If !("FILIAL" $ cField)
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := M->&(cField)
			Else
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := xFilial(Self:service:tableStructureInfo:master:alias)
			EndIf
		Next nFields
	Next nCount
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inclusao: criar as linhas no obj. igual ao nr. de linhas do aCols ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nObjRow := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Popula as linhas do objeto detail com o conteudo do aCols ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    nObjRow := Len(Self:service:tableStructureInfo:detail:rows)	//Nr. de linhas no Objeto
	For nCount := 1 To Len(aCols)
		If !aCols[nCount][Len(aHeader)+1]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se tiver nova linha no aCols         ³
			//³ Adiciona nova linha tambem no Objeto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nObjActRow := nCount
			If nCount > nObjRow
				Self:service:tableStructureInfo:detail:addrow()
				nObjRow++   
				Self:service:tableStructureInfo:detail:rows[nObjRow]:lNew := .T.
				//Adiciona os campos da linha
				For nFields := 1 To Len(Self:service:tableStructureInfo:detail:fields)
					Self:service:tableStructureInfo:detail:rows[nObjRow]:addField(Self:service:tableStructureInfo:detail:Fields[nFields]:clone())
				Next nFields
				oPkFields := Self:service:tableStructureInfo:detail:PkFields
				//Insere e preenche os valores dos campos chave (PkFields)
				For nFields := 1 To Len(oPkFields)
					Self:service:tableStructureInfo:detail:rows[nObjRow]:addPkField( oPkFields[nFields]:clone() )                                    
					cValue := GdFieldGet(oPkFields[nFields]:name, nCount)
					If !Empty(cValue)
						Self:service:tableStructureInfo:detail:rows[nObjRow]:PkFields[nFields]:value:value := cValue
					EndIf
				Next nFields
				nObjActRow := nObjRow
			EndIf       
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza a linha do Objeto com o conteudo do aCols   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nFields := 1 To Len(Self:service:tableStructureInfo:detail:rows[nObjActRow]:fields)
				cField := Self:service:tableStructureInfo:detail:rows[nObjActRow]:fields[nFields]:name
				If !("FILIAL" $ cField)
					Self:service:tableStructureInfo:detail:rows[nObjActRow]:fields[nFields]:value:value := GdFieldGet(cField, nCount)
				Else
					Self:service:tableStructureInfo:detail:rows[nObjActRow]:fields[nFields]:value:value := xFilial(Self:service:tableStructureInfo:detail:alias)
				EndIf
			Next nFields			
        
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Marca a linha tambem p/ exclusao no objeto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 	If nCount <= nObjRow
				Self:service:tableStructureInfo:detail:rows[nCount]:delete()
			EndIf			
			
		EndIf
	Next nCount 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza o agendamento da pendencia ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If lSchedule
		If !Empty(M->&(AllTrim(Self:service:tableStructureInfo:contactField:name)))
			If MsgYesNo(STR0022, STR0023) //"Confirma o reagendamento?" # "Reagendamento"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//|Verifica se há um número de telefone cadastrado para o cliente|    
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
				DbSelectArea("SU5")
				DbSetOrder(1)
				If DbSeek( xFilial("SU5") + M->&(AllTrim(Self:service:tableStructureInfo:contactField:name)))
					If 	ALLTRIM(SU5->U5_FONE) <>"" .OR.;
						ALLTRIM(SU5->U5_CELULAR) <>"" .OR.;
						ALLTRIM(SU5->U5_FAX) <>"" .OR.;
						ALLTRIM(SU5->U5_FCOM1) <>"" .OR.;
						ALLTRIM(SU5->U5_FCOM2) <>""
						 
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Pesquisa o usuario no cadastro de operadores					 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
						oPkFields := Self:service:tableStructureInfo:master:PkFields
						For nFields :=2 To Len(oPkFields)
							cSeek += M->&(oPkFields[nFields]:name)
						Next nFields			
						lTk271Auto := .F.     
						nFolder := 1
						cCodUsr := RetCodUsr()
						DbSelectArea("SU7")
					    DbSetOrder(4)
					    If DbSeek( xFilial("SU7") + cCodUsr )		
						    TKGrvSU4(	M->&(AllTrim(Self:service:tableStructureInfo:contactField:name))	,;
						    			M->&(AllTrim(Self:service:tableStructureInfo:entityName:name))		,;
						    			M->&(AllTrim(Self:service:tableStructureInfo:entityKey:name)) 		,;
						    			SU7->U7_COD,;    			
										"5",; 
										cSeek/*M->ACF_CODIGO*/,;
										dDateSchedule,;
										cHourSchedule,;
										IIf(!Empty(Self:cCodLig),.T.,.F.)/*l380*/,;
										Self:cCodLig)
					    EndIf							
					Else
						Aviso(STR0025, STR0035, {"OK"})	 // "O contato não possue telefones válidos para agendar um retorno. Corrija o cadastro do contato e tente novamente."
					EndIf					
				EndIf					
			EndIf
		Else
			Aviso(STR0025, STR0024, {"OK"}) //"Por favor, informe um contato para agendar o retorno" # "Atenção"
		EndIf
	EndIf
	                                            
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava os dados da campanha         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
	Self:GrvScript()
	
	If __lSX8
		ConfirmSX8()
	Endif 
	
	If !LockByName("TMKADE"+M->&(Self:service:tableStructureInfo:registerCode:name),.F.,.F.,.T.)
		UnLockByName("TMKADE"+M->&(Self:service:tableStructureInfo:registerCode:name),.F.,.F.,.T.)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Libera numeros reservados                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FreeUsedCode(.T.)		
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Permite executar P.E. no fechamento da janela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Self:service:whenCloseWindow:execute({aHeader,aCols,Self:nOpc})

ElseIf nOpc == 2
	If !( Type("lTk503Auto") <> "U" .AND. lTk503Auto )
		oDlg:End()
	EndIf

Else
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³ bCancel  ºAutor  ³ Vendas Clientes    º Data ³  11/23/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo acionado quando o usuario clicar o botao Cancelar   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method bCancel(oDlg, nOpc) Class TeleServiceUserDialog
Local lRet := .T.		//Indica retorno da funcao
Local lConfirm := .T.

If !Self:lCCT
	msgalert(STR0061)
	return .F.
EndIf

If nOpc<>2 .AND. !TmkOk(STR0041) //"Abandona o atendimento ?"
	lConfirm := .F.	
	lRet := .F.	
EndIf

If lConfirm
	If nOpc == 3
		lRet := Tk503ADelOk(nOpc,.T.)
	EndIf
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa P.E. no cancelamento da janela³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Self:service:whenCloseWindow:execute({aHeader,aCols,Self:nOpc})
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz o rollback da sequencia de numeros            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea(Self:service:tableStructureInfo:master:alias)
		While GetSX8Len() > Self:nStackSX8 
			RollBackSX8()
		End
		
		UnLockByName("TMKADE"+M->&(Self:service:tableStructureInfo:registerCode:name),.F.,.F.,.T.)

		Self:aParScript:= {}
	
		If !( Type("lTk503Auto") <> "U" .AND. lTk503Auto )
			oDlg:End()
		EndIf    
	EndIf    
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³LoadSupBut³ Autor ³ Vendas Clientes       ³ Data ³ 30/10/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega o array com os botoes da Toolbar Superior           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKA503A                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method LoadSupButtons(aButtonSup, aCfgBtn, oTkSelf) Class TeleServiceUserDialog
Local nI := 0					//Usado em lacos For...Next
Local cCodeBlock := ""			//Conteudo do CodeBlock (caracter) p/ o botao
Local bCodeBlock := {||.T.}		//Codeblock a ser executado p/ o botao
Local lTk503Btn  := ExistBlock("TK503Btn")
Local aButtonPE	 := {}
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os botoes padrao e os de usuario ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If aCfgBtn[13][1]
	aAdd(aButtonSup, {"SDUIMPORT",	{|| Self:LoadHist()},		STR0010 + "- <F10>", STR0009}) //"Historico"###"Historico do Atendimento"
EndIf
If aCfgBtn[11][1]
	If 	!Empty(Self:service:tableStructureInfo:registerCode:name) .AND.; 
		!Empty(Self:service:tableStructureInfo:operationCode:name).AND.;
		!Empty(Self:service:tableStructureInfo:campaignKey:name)
		
		aAdd(aButtonSup, {"PRODUTO"	 ,	{|| Self:Script()}, STR0036,		"Script"}) // "Script de Atendimento associado a Campanha"
	EndIf
EndIf
aAdd(aButtonSup, {"DISCAGEM" ,	{|| Self:TK503Discagem()}, STR0027, STR0026}) //"Telefonia" # "Comandos no telefone"

For nI := 1 To Len(Self:service:ToolbarTop:aButtons)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Durante a associacao de multiplos chamados, oculta o botao³
	//³de associacao para evitar recursividade                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Self:lAssociating .AND. AllTrim(Upper(Self:service:ToolbarTop:aButtons[nI]:CodeBlock)) == "TK510FNDCAL"
		Loop
	End
	If cNivel >= Val(Self:service:toolbarTop:aButtons[nI]:userLevel) 
		cCodeBlock := "oTkSelf:service:ToolbarTop:aButtons["+StrZero(nI,3)+"]:execute()"
		bCodeBlock := (&("{|| " + cCodeBlock + "}"))	
		aAdd(aButtonSup,{Self:service:toolbarTop:aButtons[nI]:imageName,;
						bCodeBlock,;
						AllTrim(Self:service:toolbarTop:aButtons[nI]:toolTipText),;
						AllTrim(Self:service:toolbarTop:aButtons[nI]:name) })
	EndIf
Next nI

//PE para inclusão de opçãoes customizadas
If lTk503Btn
	aButtonPE := Execblock("TK503Btn",.F.,.F.,aButtonSup)
	If ValType(aButtonPE) == "A"
		aButtonSup := aClone(aButtonPE)
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA503A  ºAutor  ³Microsiga           º Data ³  09/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method SaveM(cAlias) Class TeleServiceUserDialog

Local aRet := {}

	DbSelectArea("SX3")
	DbSetOrder(1) //X3_ARQUIVO
	DbSeek(cAlias)

	While !SX3->(EOF()) .AND. (SX3->X3_ARQUIVO == cAlias)
		AAdd(aRet, {"M->"+SX3->X3_CAMPO, &("M->"+SX3->X3_CAMPO)})		

		SX3->(DbSkip())
	End   

Return aRet

Method RestM(aArea) Class TeleServiceUserDialog
Local nI := 0

	For nI := 1 To Len(aArea)
		&(aArea[nI,1]) := aArea[nI,2]	
	Next nI

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ LoadHist ³ Autor ³ Vendas Clientes       ³ Data ³ 27/11/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega a dialog de consulta de historico                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKA503A                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method LoadHist() Class TeleServiceUserDialog
Local oDlg					//Objeto dialog 
Local oHistoryMaster		//Objeto Browse da Master
Local oHistoryDetail		//Objeto Browse da Detail
Local lRet 		:= .T.		//Indica o retorno da funcao
Local aMaster	:= {}		//Array com o conteudo da tab. Master
Local aDetail	:= {}		//Array com o conteudo da tab. Detail 
Local lHistPE	:= .T.		//Indica o resulta da chamada ao Ponto de Entrada
Local nItens	:= 0  
Local aTmpHeader	:= {} 
Local aTmpCols	:= {}     
Local aItHeader	:= {} 
Local aItCols	:= {}     
Local aColsAnt 	 := AClone(aCols)
Local aHeaderAnt := AClone(aHeader) 
Local aInfo				:={}						//Array para utilizacao do MsAdvSize
Local aPosObj			:= {}						//Array com as coordenadas para posicionamento dos objetos
Local aObjects			:={}						//Array com os objetos da tela    
Local nOpcA				:= 0						//Indica se o usuário selecionou um atendimento
Local nSelItem			:= 0						//Armazena a linha do atendimento selecionado
Local aSeekHist			:= {}						//Armazena a chave de busca para o atendimento do historico {Alias, Index, Chave de Busca}
Local aKeyInfo			:= {}                   
Local aArea				:= Self:SaveM(Self:service:tableStructureInfo:master:alias)
Local nI				:= 0  
Local aSeekAux			:= {}						//Array contendo os dados do atendimento a ser carregado
													//[1] - Alias da tabela
													//[2] - Indice de busca na tabela
													//[3] - Chave de Busca na tabela


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa P.E. na chamada da tela de Historico ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lHistPE := Self:service:whenPressedHistory:execute({@aSeekAux})
If ValType(lHistPE)!="L"
	lHistPE := .T.          
Else    
	nSelItem := 0
	If Len(aSeekAux)>0                                          
		aAdd(aSeekHist, {aSeekAux[1],aSeekAux[2],aSeekAux[3]})
		nSelItem := 1		
	EndIf		
EndIf             

If lHistPE
	aSize    := MsAdvSize(.T.,.F.,400) 
	aObjects := {} 
	aAdd( aObjects, { 100, 100, .T., .T. } )
	aAdd( aObjects, { 100, 100, .T., .T. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
	aPosObj := MsObjSize( aInfo, aObjects )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Seleciona os chamados do contato selecionado no atendimento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CursorWait()
	If !Self:ListHistMaster(@aMaster,@aTmpHeader, @aTmpCols, @aSeekHist)
		Return .F.	
	EndIf                                                     
	CursorArrow()
	
	DEFINE MSDIALOG oDlg TITLE STR0017 FROM /*aSize[7],0*/50,001 TO /*aSize[6],aSize[5]*/600,750 OF oMainWnd PIXEL //"Historico de chamados"
		aObjects := {}
		aAdd( aObjects, { 100, 350, .F., .F. } )
		AAdd( aObjects, { /*450, 130*/300,350, .F., .F. } ) 
												 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo de coordenadas dos objetos da tela de acordo com as coordenada do painel.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  		
		aInfo   := { 0, 0, oDlg:nClientHeight, oDlg:nClientWidth, 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )	 	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria Browse da tabela Master	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		        	
		oHistoryMaster	:= TCBrowse():New( 5, 10, 350, 100,;
									 		Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,,,,,,,,, .T. )		
		
		oHistoryMaster:bLDblClick 	:= 	{|| Self:ListHistDetail(aMaster, aDetail, oHistoryMaster, oHistoryDetail,;
														/*aItHeader*/,@aItCols) }
		oHistoryMaster:bChange 		:=  {|| Self:ListHistDetail(aMaster, aDetail, oHistoryMaster, oHistoryDetail,;
														/*aItHeader*/,@aItCols) }	
                                       
		oHistoryMaster:SetArray(aTmpCols)		
		oHistoryMaster:SetFocus()		 
		
		For nItens := 1 To Len(aTmpHeader)   
			oColumn := TCColumn():New( RetTitle(aTmpHeader[nItens][2]), &("{||aTmpCols[oHistoryMaster:nAt,"+AllTrim(Str(nItens))+"]}"),,,,"LEFT", 40, .F., .F.,,,, .F., )
			oHistoryMaster:AddColumn(oColumn)			
		Next nItens 									 		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria Browse da tabela Detail 	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      			     	   		
		Self:ListHistDetail(aMaster, aDetail, oHistoryMaster, oHistoryDetail,;
																aItHeader,@aItCols) //oHistoryDetail:SetArray(aITCols,.F.),	oHistoryDetail:ForceRefresh()				

		aHeader := aClone(aItHeader)
		oHistoryDetail	:= 	MSGetDados():New(110,10,250,360,2,"AlwaysTrue","AlwaysTrue","",.T.,,,.F.,300)
		
		DEFINE SBUTTON FROM 255,280	TYPE 1 ACTION (oDlg:End(), nSelItem:=oHistoryMaster:nAt, nOpcA:=1) ENABLE
		DEFINE SBUTTON FROM 255,320	TYPE 2 ACTION (oDlg:End()) ENABLE
		
	ACTIVATE MSDIALOG oDlg CENTERED 
EndIf  

aCols 	:= AClone(aColsAnt)
aHeader := AClone(aHeaderAnt)

If (nOpcA > 0 .OR. !lHistPE) .AND. nSelItem > 0      
	CursorWait()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega o atendimento historico  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	If Len(aSeekHist[nSelItem]) >= 3        
		DbSelectArea(aSeekHist[nSelItem][1])			
		RollBackSX8()                       
		DbSetOrder(aSeekHist[nSelItem][2])				
		If MsSeek(aSeekHist[nSelItem][3])	                     
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Permite executar P.E. no fechamento da janela ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Self:service:whenCloseWindow:execute({aHeader,aCols,Self:nOpc})		
			aCols 	:= {}
			aHeader := {}
			aKeyInfo:= {}
			Self:nOpc := 4			
			Self:service:tableStructureInfo:clear() 
			For nI := 1 To Len(Self:service:tableStructureInfo:master:PkFields)
				aAdd(aKeyInfo, Self:service:tableStructureInfo:master:PkFields[nI]:name )
			Next nI			
			If Self:LoadInformation(Self:nOpc, aKeyInfo) 					
/*				If nOpc == 3               
					If ValType(oEnchTk503)<>"U"					
						oEnchTk503:SetFocus()
						oEnchTk503:ResetScroll()	
					EndIf										
					Self:service:tableStructureInfo:clear() 
					Self:LoadInformation(Self:nOpc, aKeyInfo)                                                   
				EndIf			*/
				oGetd:oBrowse:Refresh()
				oGetd:Enable()     
	
				If ValType(oEnchTk503)<>"U"					
					oEnchTk503:SetFocus()
					oEnchTk503:ResetScroll()
					RunTrigger(1)	
				EndIf						
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Executa P.E. na abertura da janela ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Self:service:whenOpenWindow:execute({aHeader,aCols,Self:nOpc, oGetd, , , oEnchTk503})			
				
				lRet := .T.        
			EndIf
		EndIf
	EndIf
	CursorArrow()
Else
	Self:RestM(aArea)
EndIf     

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³LoadInformation³ Autor ³ Vendas Clientes  ³ Data ³ 28/11/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consultar o historico de chamados na tabela Master		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKA503A                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method LoadInformation(nOpc, aKeyInfo) Class TeleServiceUserDialog
Local lRet := .T.
Local nI := 0
Local nCnt := 0		//Contador do Loop
Local lCustomSrc:= Len(GetApoInfo("TMKA500Q.PRW")) > 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os dados do atendimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc <> 3) 
	If !Self:service:tableStructureInfo:load( aKeyInfo )
		//ConOut(STR0004) //"Nao localizou registro!"
		lRet := .F.
		Return lRet                                          		
	EndIf
EndIf     

If nOpc == 3
	INCLUI 	:= .T.
	ALTERA	:= .F.
ElseIf nOpc == 4
	INCLUI 	:= .F.
	ALTERA	:= .T.
EndIf         
aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Construir o aHeader baseado na estrutura definida no objeto  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len(Self:service:tableStructureInfo:master:Fields)
	cCampo := Self:service:tableStructureInfo:master:Fields[nI]:name
	DbSelectArea("SX3")
	DbSetOrder(2)
	MsSeek(cCampo)
	If nOpc == 3		//Inclusao
		If lCustomSrc
			If !Empty(Self:service:tableStructureInfo:master:Fields[nI]:defValue)
				M->&(cCampo) := CriaVar(SX3->X3_CAMPO,.F.,,.T.)
				M->&(cCampo) := InitPad(Self:service:tableStructureInfo:master:Fields[nI]:defValue)
			Else
				M->&(cCampo) := CriaVar(SX3->X3_CAMPO,.T.,,.T.)
			EndIf
		Else
			M->&(cCampo) := CriaVar(SX3->X3_CAMPO,.T.,,.T.)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se foi passado algum valor inicial  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(Self:cEntName)
			If AllTrim(cCampo) == AllTrim(Self:service:tableStructureInfo:entityName:name)  
				M->&(cCampo) := Self:cEntName				
			EndIf			
		EndIf				
		If !Empty(Self:cEntValue)
			If AllTrim(cCampo) == AllTrim(Self:service:tableStructureInfo:entityKey:name)  
				M->&(cCampo) := Self:cEntValue
			EndIf			
		EndIf
		If !Empty(Self:cContValue)
			If AllTrim(cCampo) == AllTrim(Self:service:tableStructureInfo:contactField:name)  
				M->&(cCampo) := Self:cContValue
			EndIf			
		EndIf
		If Self:oHashDic != Nil .AND. self:oHashDic:Count() > 0
			For nCnt = 1 to self:oHashDic:Count()
				If cCampo == PadR(self:oHashDic:ElementPar(nCnt):oKey, Len(SX3->X3_CAMPO))
					M->&(cCampo) := self:oHashDic:ElementPar(nCnt):oValue 
				EndIf
			Next
		EndIF				                  		
	Else
		If lCustomSrc
			If !Empty(Self:service:tableStructureInfo:master:Fields[nI]:defValue)
				M->&(cCampo) := CriaVar(SX3->X3_CAMPO, .F.,,.T.)
				M->&(cCampo) := InitPad(Self:service:tableStructureInfo:master:Fields[nI]:defValue)
			Else
				M->&(cCampo) := CriaVar(SX3->X3_CAMPO, .T.,,.T.)
			EndIf
		Else
			M->&(cCampo) := CriaVar(SX3->X3_CAMPO, .T.,,.T.)
		EndIf
		If ( SX3->X3_CONTEXT<>"V" )
			M->&(cCampo) := Self:service:tableStructureInfo:master:rows[1]:Fields[nI]:value:value
		EndIf
	EndIf
Next nI   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Construir o aCols ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Self:BuildCols(nOpc)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ListHistMa³ Autor ³ Vendas Clientes       ³ Data ³ 28/11/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consultar o historico de chamados na tabela Master		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKA503A                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method ListHistMaster(aMaster, aTmpHeader, aTmpCols, aSeekHist) Class TeleServiceUserDialog
Local cContactField := Self:service:tableStructureInfo:contactField:name		//Nome do campo de Contato 
Local cCodContact	:= M->&(cContactField)										//Codigo do contato
Local cFEntityName	:= Self:service:tableStructureInfo:entityName:name			//Nome do campo com nome da Entidade
Local cEntityName	:= M->&(cFEntityName)										//Nome da Entidade 
Local cDescEntity	:= POSICIONE('SX2',1,cEntityName,'X2NOME()')				//Descricao da entidade
Local lRet			:= .F. 														//Retorno da funcao
Local oDlg
Local nOpca := 1             
Local nArquivo  := 1											// Consulta por 1 - Contato ou por 2 - Cliente		
Local oArquivo													// Objeto radio para escolha do tipo de historico
Local aOpcoes	:= {STR0037,STR0038 + IIF(!Empty(cDescEntity),cDescEntity,STR0039)}	// "Historico por Contato" # "Historico por " # "Entidade"
 

If Empty(cCodContact)
	MsgAlert(STR0018,STR0019) //"Por favor, selecione um contato"###"Atencao"
Else 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Abre uma tela para opcao do historico 1 - Contato 2 - Cliente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg FROM  00,00 TO 100,260 TITLE STR0040 PIXEL OF oMainWnd //"Tipo de Consulta"
	
		@ 06,04 RADIO oArquivo VAR nArquivo PROMPT aOpcoes[1],aOpcoes[2] OF oDlg SIZE 80,20 DESIGN 3D PIXEL
		
		DEFINE SBUTTON FROM 05,95 TYPE 1 ENABLE OF oDlg ACTION (nOpca:= 1, oDlg:End())	//OK - Executa com a opcao selecionada
		
		DEFINE SBUTTON FROM 25,95 TYPE 2 ENABLE OF oDlg ACTION (nOpca:= 0, oDlg:End())	//Cancela nao executa a consulta 
		
	
	ACTIVATE MSDIALOG oDlg CENTERED  
    
	If nOpca == 1 
		aMaster := Self:service:loadHistory( Self:service:tableStructureInfo, nArquivo )
		If Len(aMaster) > 0
			lRet := .T. 
		Else		
			MsgAlert(STR0021,STR0019) //"Não foram encontrados chamados para este contato"###"Atencao"
		EndIf
	EndIf 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o array que devera ser exibido na tela do Historico   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := Self:FillGetDad(aMaster, Self:service:tableStructureInfo:master, @aTmpHeader, @aTmpCols, @aSeekHist) 	
EndIf     

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³BuildHeader³ Autor ³ Vendas Clientes      ³ Data ³ 28/11/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Construir o aHeader conforme o alias informado.   		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKA503A                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method BuildHeader(cAlias) Class TeleServiceUserDialog   
Local aRet := {}
Local nUsado := 0 
Local aX3CBox:= {} 
Local aTmpHeader := {}

	DbSelectArea("SX3")
	DbSetOrder(1) //X3_ARQUIVO
	DbSeek(cAlias)

	While !SX3->(EOF()) .AND. (SX3->X3_ARQUIVO == cAlias)
		
		If X3USO(SX3->X3_USADO) .AND. (cNivel >= SX3->X3_NIVEL) 
			nUsado++
			
			//Aadd(aCampos,ALLTRIM(X3_CAMPO))
			AAdd(aX3CBox, AllTrim(X3CBox()))
			
			Aadd(aTmpHeader,{	X3TITULO(),;			// 01
								X3_CAMPO,;				// 02
								X3_PICTURE,;			// 03
								X3_TAMANHO,;			// 04
								X3_DECIMAL,;			// 05
								X3_VALID,;				// 06
								X3USO(SX3->X3_USADO),;// 07
								X3_TIPO,;				// 08
								X3_ARQUIVO,;			// 09
								X3_CONTEXT,;			// 10
								X3_PROPRI} )			// 11
			
		Endif
		SX3->(DbSkip())
	End 
	aRet := {aTmpHeader, aX3CBox, nUsado}

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³FillGetDad ³ Autor ³ Vendas Clientes      ³ Data ³ 28/11/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Construir o aHeader e o aCols para GetDados       		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKA503A                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method FillGetDad(aInfo, oTable, aItHeader, aItCols, aSeekHist) Class TeleServiceUserDialog
Local nItens	:= 0
Local nItensInfo:= 0     
Local nFields := 0      
Local cValue  := ""
Local cIndex  := ""
Local lSeek	  := .F.       
Local nPosicao1 := 0
Local nPosicao2 := 0    
Local aX3CBox	:= {}
Local nUsado	:= 0
Local aArea := GetArea()  
Local lRet := .F.

Default aSeekHist := {}
     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array que devera ser exibido na tela do Historico   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aInfo) > 0
	aRet := Self:BuildHeader(oTable:alias)
	aITHeader 	:= AClone(aRet[1])
	aX3CBox		:= AClone(aRet[2])
	nUsado		:= aRet[3]
	
	If Self:nOpc == 3
		INCLUI := .F.
		ALTERA := .T.
	EndIf

	For nItens := 1 To Len(aInfo)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega a chave de busca do registro     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		cIndex := ""
		cValue := ""
		lSeek	  := .F.
		For nItensInfo := 1 To Len(oTable:pkfields)
			For nFields := 1 To Len(oTable:fields)
				cValue := ""
				If AllTrim(oTable:fields[nFields]:name) == AllTrim(oTable:pkfields[nItensInfo]:name)
					cValue := aInfo[nItens][nFields]
					Exit
				EndIf				
			Next nFields		
			cIndex += cValue
		Next nItensInfo
		
		aAdd(aSeekHist, {oTable:alias, oTable:iIDX, cIndex})
		DbSelectArea(oTable:alias)
		DbSetOrder(oTable:iIDX)				
		If DbSeek(cIndex)	   							
			Aadd(aITCols,Array(nUsado+1))
			For nItensInfo := 1 To Len(aITHeader)								
				If ( aITHeader[nItensInfo][10] <> "V" .AND. aITHeader[nItensInfo][08] <> "M")
					aITCols[Len(aITCols)][nItensInfo] := FieldGet(FieldPos(aITHeader[nItensInfo][2]))					
					If !Empty(aX3CBox[nItensInfo]) .AND. !Empty(aITCols[Len(aITCols)][nItensInfo]) //X3_CBOX		   
						nPosicao1 := 0														
						nPosicao2 := 0
						nPosicao1   := At(aITCols[Len(aITCols)][nItensInfo],aX3CBox[nItensInfo])
						aITCols[Len(aITCols)][nItensInfo]		:= SubStr(aX3CBox[nItensInfo],nPosicao1+2,Len(aX3CBox[nItensInfo]))
						nPosicao2	:= At(";",aITCols[Len(aITCols)][nItensInfo])             
						If nPosicao2 > 0							
							aITCols[Len(aITCols)][nItensInfo]		:= SubStr(aITCols[Len(aITCols)][nItensInfo], 1, nPosicao2-1)
						EndIf						
					EndIf										
				Else
					aITCols[Len(aITCols)][nItensInfo] := CriaVar(aITHeader[nItensInfo][2],.T.)
				Endif
				aITCols[Len(aITCols)][nUsado+1] := .F.										
			Next		        
		EndIf
		
	Next nItens	
	If Self:nOpc == 3
		INCLUI := .T.
		ALTERA := .F.
	EndIf	
	lRet := .T.
EndIf

RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³ListHistDe³ Autor ³ Vendas Clientes       ³ Data ³ 28/11/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consultar o historico de chamados na tabela Detail		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKA503A                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method ListHistDetail(aMaster, aDetail, oHistoryMaster, oHistoryDetail, aItHeader,aItCols) Class TeleServiceUserDialog
Local cCodMaster := aMaster[oHistoryMaster:nAt, 2]		//Codigo da tab. Master selecionado no Browse
Local lRet := .F.     

Default aItHeader 	:= {}
Default aItCols 	:= {}

aITCols	:= {}

aDetail := Self:service:loadHistDetail(Self, cCodMaster)
lRet := Self:FillGetDad(aDetail, Self:service:tableStructureInfo:detail, @aItHeader, @aItCols) 

If lRet .AND. ValType(oHistoryDetail)<>"U"
	aCols := aClone(aItCols)	
	oHistoryDetail:Refresh()
EndIf
Return lRet     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³SetInfo   ³ Autor ³ Vendas Clientes       ³ Data ³ 19/12/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Define os valores iniciais da tela de atendimento     	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKA503A                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method SetInfo(cContact, cEntity, cEntValue, cCodLig) Class TeleServiceUserDialog
Local lRet := .T.

Self:cEntValue	:= cEntValue 
Self:cEntName	:= cEntity
Self:cContValue	:= cContact                  
Self:cCodLig	:= cCodLig
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³SetHashDic³ Autor ³ Vendas CRM            ³ Data ³ 14/05/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Define os valores iniciais da tela de atendimento     	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKA503A                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method SetHashDic(oHashDic) Class TeleServiceUserDialog
	Self:oHashDic	:= oHashDic
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³SetCCT    ³ Autor ³ Vendas CRM            ³ Data ³ 20/05/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Define se o atendimento pode ou não ser finalizado.   	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKA503A                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method SetCCT(lCCT) Class TeleServiceUserDialog
	Self:lCCT	:= lCCT
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³Script       ³ Autor ³ Vendas Clientes    ³ Data ³ 30/05/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa o script de atendimento associado a campanha. 	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKA503A                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method Script() Class TeleServiceUserDialog
Private nFolder := 4

If Type("lTk271Auto") == "U"
	Private lTk271Auto := .F.
Endif 
	Tk271Script(Self:nOpc, Self:aParScript,	, , , , Self:service:tableStructureInfo)
Return Nil                                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³GrvScript    ³ Autor ³ Vendas Clientes    ³ Data ³ 30/05/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava as informacoes da campanha e script.            	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKA503A                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method GrvScript() Class TeleServiceUserDialog
Local cRotina:= ""
Local cAtend := ""
Local cCampCod := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso a campanha selecionada foi executada e gravada, atualiza o numero do atendimento³
//³no cabecalho da gravacao da campanha.                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(Self:aParScript) > 0

	cRotina:= "4"
	cAtend := M->&(Self:service:tableStructureInfo:registerCode:name)

	If (Len(Self:aParScript)>0)
		Tk380Grava(	Self:aParScript[1][1],Self:aParScript[1][2] ,Self:aParScript[1][3] ,Self:aParScript[1][4] ,;
		            Self:aParScript[1][5],Self:aParScript[1][6] ,Self:aParScript[1][7] ,Self:aParScript[1][8] ,;
					Self:aParScript[1][9],Self:aParScript[1][10],Self:aParScript[1][11],Self:aParScript[1][12],;
					cAtend,@cCampCOD)
	Endif	

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava a rotina e o numero do atendimento de onde³
	//³foi executado a campanha.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("ACI")			
	DbSetOrder(1)
	If DbSeek(xFilial("ACI") + cCampCod)
		RecLock("ACI",.F.)
		Replace ACI_ROTINA With cRotina
		Replace ACI_ATEND  With cAtend
		MsUnLock()
		DbCommit()
	Endif
Endif

Self:aParScript:= {}
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³TK503Discagem³ Autor ³ Vendas Clientes    ³ Data ³ 19/12/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe um pop-up com as funcoes de telefonia.          	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKA503A                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method TK503Discagem() Class TeleServiceUserDialog
Local cEntidade:= ""									//Alias da entidade
Local cChave   := ""									//Chave da entidade
Local cCodCont := ""		   							//Codigo do contato
Local nCol 	   := 220				 					//Numero de colunas
Local nLin 	   := 25									//Numero de linhas
Local cTipoCti := TkPosto(TkOperador(),"U0_TIPOCTI")	//Tipo da CTI
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os codigos da entidade e contato.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
cChave    := M->&(AllTrim(Self:service:tableStructureInfo:entityKey:name))
cCodCont  := M->&(AllTrim(Self:service:tableStructureInfo:contactField:name))
cEntidade := M->&(AllTrim(Self:service:tableStructureInfo:entityName:name))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual o tipo de discagem a ser realizada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipoCti == "3" // 3 - Manual  

	Tk271Tel(cCodCont,cChave,cEntidade)
	
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exibe as opcoes de discagem ativa configurados pelo parametro MV_TMKCFGR ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SGMnuAtivo(	NIL		,cEntidade	,cChave	,cCodCont	,;
				nLin	,nCol		,Self:oDlg	,NIL		,;
				NIL, 	,NIL		,NIL	,NIL		,;
				NIL, 	,NIL		,NIL	,NIL		,;
				NIL)
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk503ATudOk³ Autor ³ IP - Vendas Clientes ³ Data ³ 01/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao Geral                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void Tk503ATudOk()                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKA503A                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk503ATudOk()
	Local lRet 		:= .T.
	Local lTk503TOk := ExistBlock("TK503TOk")

	If !Empty(oObj:service:validGDItem:codeBlock)
		lRet := oObj:service:validGDItem:execute({aHeader,aCols,n})
	EndIf

	If lRet .And. lTk503TOk
		lRet := Execblock("TK503TOk",.F.,.F.,{aHeader,aCols,n})
		If ValType(lRet) <> "L"
			lRet := .T.
		EndIf
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk503ADelOk³ Autor ³ Marcelo Coutinho     ³ Data ³ 01/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de Deleção de linhas                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void Tk503ADelOk()                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKA503A                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk503ADelOk(nOpcx,lCancelar)

Local nX         := 0                                                   //Contador para validação de aCols
Local lRet       := .T.                                                 //Controle de Retorno
Local lIntTMS    := SuperGetMV('MV_INTTMS')                             //Verifica integração com o TMS
Local nPosCODSUQ := aScan(aHeader, {|x| AllTrim(x[2]) == "ADF_CODSUQ"}) //Posicao do campo na tabela
Local aArea      := GetArea()                                           //Retorno de Áreas

Default lCancelar  := .F. //Valida Cancelamento do Atendimento

If lIntTMS //Integrado ao TMS e com os campos da integração já criados
	SUQ->(DbSetOrder(1))
	If !lCancelar
		If !Empty(aCols[n][nPosCODSUQ]) .And. !aCols[n][Len(aCols[n])]
			If SUQ->(dbSeek(xFilial("SUQ")+aCols[n][nPosCODSUQ])) .And. !Empty(SUQ->UQ_ACAOTMS)
				lRet := .F.
			EndIf
		EndIf
	Else
		For nX := 1 To Len( aCols )
			If lRet
				If SUQ->(dbSeek(xFilial("SUQ")+aCols[nX][nPosCODSUQ])) .And. !Empty(SUQ->UQ_ACAOTMS)
					lRet := .F.
				EndIf
			EndIf
		Next
	EndIf
	If !lRet
		Help('',1,'TMKA503A01') //(P)Opção Inválida! Processo integrado ao módulo TMS. Existem informações no TMS, relacionadas ao Atendimento. / (S)Não é possível Excluir a linha selecionada!
	EndIf
EndIf

RestArea(aArea)
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk503ALinOk³ Autor ³ IP - Vendas Clientes ³ Data ³ 26/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da linha da GetDados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void Tk503ALinOk()                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKA503A                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk503ALinOk()	

Local aArea			:= GetArea()
Local lRet 			:= .T.
Local nFor		 	:= 1
Local nLinUteis		:= 0
Local cPred			:= ""
Local nPosCODSU9	:= aScan(aHeader, {|x| AllTrim(x[2]) == "ADF_CODSU9"})
Local nPosRecno		:= aScan(aHeader, {|x| AllTrim(x[2]) == "ADF_REC_WT"})
Local nContTrf		:= 0

If Type("oGetD")=="O"
	aCols := aClone(oGetD:aCols)
	N	  := oGetd:nAt
EndIf

If !Empty(oObj:service:validGDItem:codeBlock)
	lRet := oObj:service:validGDItem:execute({aHeader,aCols,n})
EndIf                   

If lRet .And. Empty(aCols[n][nPosCODSU9])
	Help(" ",1,"OCORRENCIA")
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida particularidades da recorrencia de chamados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. M->ADE_RECORR == "1"
	
	For nFor := 1 to Len(aCols)
		If !aTail(aCols[nFor])
			nLinUteis++
		EndIf
	Next               
	
	If nLinUteis > 1 
		MsgAlert(STR0067) //"O modelo de chamado recorrente deve conter apenas uma linha de interação"
		lRet := .F.
	EndIf
	
EndIf

If lRet

	DbSelectArea("SU9")
	DbSetOrder(1) //U9_FILIAL+U9_ASSUNTO+U9_CODIGO
	MsSeek(xFilial("SU9") + M->ADE_ASSUNT + aCols[n][nPosCODSU9])

	DbSelectArea("SUY")
	DbSetOrder(1) //Filial + Codoco + coddep

	DbSelectArea("SUX")
	DbSetOrder(1)
	
	SUY->(MsSeek(xFilial("SUY") + SU9->U9_TIPOOCO))
	While !SUY->(EOF()) .AND.  SUY->UY_FILIAL == xFilial("SUY") .AND. SUY->UY_CODOCO == SU9->U9_TIPOOCO
		SUX->(MsSeek(xFilial("SUX") + SUY->UY_CODDEP))
		If len(cPred) > 0
			cPred += ", " + AllTrim(SUX->UX_DESTOC)
		Else
			cPred := AllTrim(SUX->UX_DESTOC)
		EndIf
		SUY->(DbSkip())
	End
	SUY->(MsSeek(xFilial("SUY") + SU9->U9_TIPOOCO))
	While !SUY->(EOF()) .AND. SUY->UY_FILIAL == xFilial("SUY")
		lRet = .F.
		For nFor = 1 To len(aCols)
			If !aTail(aCols[nFor])
				If !lRet
					SU9->(MsSeek(xFilial("SU9") + M->ADE_ASSUNT + aCols[nFor,nPosCODSU9]))
					If SUY->UY_CODDEP == SU9->U9_TIPOOCO
						lRet = .T. //Encontrou uma ocorrencia predecessora
					EndIF
				EndIf
			EndIf
		Next
		If lRet
			SUY->(DbSkip())
		Else
			Exit
		EndIf
	End
	If !lRet
		msgalert(STR0042 + ": " + cPred)
	EndIf
EndIF

If ( Type("oGetD") == "O" )
	If ( lRet .and. (Type("aTrfAux") == "A") )	
		If ( Len(aTrfAux) > 0 )	
			For nFor := 1 To Len(oGetD:aCols)
				If ( AllTrim(oGetD:aCols[ nFor, nPosCODSU9 ]) == "TMK001")
					If !( oGetD:aCols[ nFor, Len(aCols[nFor]) ] ) .and. Empty(oGetD:aCols[ nFor, nPosRecno ])
						nContTrf++
						If ( nContTrf > 1 )
							lRet := .F.
							Aviso(STR0019, STR0075, {"OK"}) //"Atenção" # "Já foi solicitado a transferéncia deste chamado." 
							Exit
						Else
						
							If ( ( nPos := aScan( aTrfVld, { |x| x[12] == .T. } ) ) > 0 .and. lRet )
							
								M->ADE_GRUPO := aTrfVld[nPos,05]
								M->ADE_DESCGP := aTrfVld[nPos,01]
								
								M->ADE_OPERAD := aTrfVld[nPos,02]
								M->ADE_NMOPER := aTrfVld[nPos,15]
							
								M->ADE_ASSUNT := aTrfVld[nPos,03]
								M->ADE_ASSANT := aTrfVld[nPos,17]
							
								M->ADE_CODSB1 := aTrfVld[nPos,04]
								M->ADE_NMPROD := aTrfVld[nPos,14]
								
								M->ADE_CODCAT := aTrfVld[nPos,06]
								M->ADE_NCATEG := aTrfVld[nPos,18]
								
								M->ADE_CODORI := aTrfVld[nPos,07]
								M->ADE_NORIGE := aTrfVld[nPos,19]
								
								M->ADE_CODCAU := aTrfVld[nPos,08]
								M->ADE_NCAUSA := aTrfVld[nPos,20]
								
								M->ADE_CODEFE := aTrfVld[nPos,09]
								M->ADE_NEFEIT := aTrfVld[nPos,21]
								
								M->ADE_CODCAM := aTrfVld[nPos,10]
								M->ADE_DSCCAM := aTrfVld[nPos,22]
								
							EndIf						
						
						EndIf
					EndIf
					nPos := aScan( aTrfVld, { |x| x[11] == nFor } )
					If (nPos > 0 )
						aTrfVld[nPos, 12] := !oGetD:aCols[ nFor, Len(aCols[nFor]) ]
					EndIf					
				EndIf
			Next			
		EndIf
	EndIf
EndIf

If Type("oGetD")=="O"
	oGetD:aCols := aClone(aCols)
EndIf

RestArea(aArea)

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³_TMKA500      ºAutor  ³Vendas Clientes º Data ³  09/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao dummy apenas para o programa aparecer no inspetor de º±±
±±º          ³objetos                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function _TMKA503A()

Return Nil   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³ Vendas Cliente        ³ Data ³18/12/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef() 
Local aRotina
               
aRotina		:= {{ STR0020	,"AxPesqui"  ,0,1 },; 	// 	"Pesquisar" //"Pesquisar"
				{ STR0001 	,"TK503AOpc" ,0,2 },; 	// 	"Visualizar" //"Visualizar"
				{ STR0002	,"TK503AOpc" ,0,3 },; 	// 	"Incluir" //"Incluir"
			 	{ STR0003	,"TK503AOpc" ,0,4 },;  //	"Alterar" //"Alterar"
			 	{ STR0043	,"TK503TRsp" ,0,4 }} 	// 	"Tr. Responsavel"
Return(aRotina)


/*/                    
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TmkOperador ³ Autor ³ Vendas Clientes    ³ Data ³ 28/07/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fun‡ao para verificar se o USUARIO:                        ³±±
±±³          ³ 1) Tem um OPERADOR identico no cadastro de Operadores e se ³±±
±±³          ³ ele e VALIDO - Check pelo Nome e depois pelo Codigo        ³±±
±±³          ³                                                            ³±±
±±³          ³ 2) Atualiza o tipo de atendimento que o Operador tem acesso³±±
±±³          ³ 1-Telemarketing,2-Televendas,3-Telecobranca,4-Todos,       ³±±
±±³          ³ 5-Tmk x Tlv                                                ³±±
±±³          ³                                                            ³±±
±±³          ³ 3) Veririca se o Operador associado tem um Grupo de        ³±±
±±³          ³ Atendimento valido                                         ³±±
±±³          ³                                                            ³±±
±±³          ³ 4) Verifica se ele e SUPERVISOR na solicitacao de parametro³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CALL CENTER                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Method TmkOperador(lSuper,cCod) Class TeleServiceUserDialog

Local aSavArea 	:= GetArea()		// Salva a area atual
Local lRet 		:= .F.				// Retorno da funcao
Local lFind 	:= .F.	            // Flag para Seek no SU7 com UPPER e sem UPPER
Local cGrupo 	:= ""				// Grupo de atendimento do Operador

DEFAULT lSuper	:= .F.				// Verifica se o operador e um SUPERVISOR ou nao
DEFAULT cCod  	:= __cUserId		// Codigo do usuario logado

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna o nome completo do usuario para a verificacao do SU7 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU7")
DbSetOrder(4)
If MsSeek(xFilial("SU7")+cCod) // Nome completo
	If SU7->U7_TIPOATE == "4" .OR. SU7->U7_TIPOATE == "6"	//TODOS OU TELEATENDIMENTO
		lFind := .T.
	EndIf
Endif

If lFind 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A atualizacao da variavel _cTipoAte esta sendo feita nesse	  ³
	//³momento para ser utilizada na funcao TkGetTipoAte()            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cTipoAte := SU7->U7_TIPOATE
	cGrupo	  := SU7->U7_POSTO	

	If !Empty(_cTipoAte) .AND. !Empty(cGrupo)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o grupo de atendimento esta cadastrado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cGrupo)
			DbSelectArea("SU0")
			DbSetOrder(1)
			If MsSeek(xFilial("SU0")+SU7->U7_POSTO)
		        lRet := .T.    

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se foi solicitado avaliar se o operador tambem e um SUPERVISOR³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lSuper
				   If VAL(SU7->U7_TIPO) == SUPERVISOR
				      lRet := .T.
				   Else
				      lRet := .F.
				   Endif
		        Endif
		    Endif
		Endif        
	Endif
Endif

RestArea(aSavArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³GetFields    ³ Autor ³ Vendas Clientes    ³ Data ³ 28/10/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna os campos a serem utilizados no atendimento    	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKA503A                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method GetFields(cAlias,cModelo,aFields,aFolder) Class TeleServiceUserDialog  

Local aArea			:= GetArea()
Local aCampos 		:= {} 
Local nSk			:= 0
Local nCpo			:= 0
Local cTitle		:= ""
Local lCustomSrc	:= Len(GetApoInfo("TMKA500Q.PRW")) > 0
Local cDescFolder	:= ""
Local lChave		:= .F.
Local lNAltera		:= .F.
Local cValidCont	:= ""
Local nPosCodCon	:= 0
Local cVldX3Cont	:= ""
Local lTk503SKA		:= ExistBlock("TK503SKA")
Local cIdioma 		:= ""

DbSelectArea("SKA")
DbSetOrder(1)
If DbSeek(xFilial("SKA")+cModelo)
	cValidCont := AllTrim(KA_CONTSEL)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Lista das pastas para o alias atual³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SXA")
DbSetOrder(1)

If DbSeek(cAlias)
	aFolder := {}
	While (!Eof()) .AND. (SXA->XA_ALIAS == cAlias)
		cDescFolder := XADescric()
		AAdd(aFolder,Capital(AllTrim(cDescFolder)))
		DbSkip()
	End
Else
	aFolder := Nil
EndIf

DbSelectArea("SX3")
DbSetOrder(4) //X3_ARQUIVO+X3_FOLDER+X3_ORDEM

If DbSeek(cAlias) 
	While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == cAlias
		If X3USO(SX3->X3_USADO) .AND. cNivel >= X3_NIVEL
			
			//Busca definicoes do campo pelo objeto
			nSk := aScan(aFields,{|x|AllTrim(x:name)==AllTrim(SX3->X3_CAMPO)})

			If nSk == 0 .OR. (lCustomSrc .AND. aFields[nSk]:Use)

				lChave	:= X3Chave(SX3->X3_USADO)
				lNAltera:= X3Alteravel(SX3->X3_USADO)
				If SX3->X3_CAMPO == "ADE_CODCON"
					cVldX3Cont := SX3->X3_VALID
				EndIf	
				nCpo++
			   	Aadd( aCampos, {X3Titulo(),;
								SX3->X3_CAMPO,;
								SX3->X3_TIPO,;
								SX3->X3_TAMANHO,;
								SX3->X3_DECIMAL,;
								SX3->X3_PICTURE,;
								Iif(Empty(SX3->X3_VALID),"",&("{||" + AllTrim(SX3->X3_VALID)+ "}")),;
								X3Obrigat(SX3->X3_CAMPO),;
								SX3->X3_NIVEL,;
								SX3->X3_RELACAO,;
								SX3->X3_F3,;
								Iif(Empty(SX3->X3_WHEN),"",&("{||" + AllTrim(SX3->X3_WHEN)+ "}")),;
								SX3->X3_VISUAL=="V",;
								lChave,; 
								SX3->X3_CBOX,;
								VAL(SX3->X3_FOLDER),;
								lNAltera,;
								SX3->X3_PICTVAR,;
								SX3->X3_TRIGGER} )

				//Aplica customizacoes do campo
				If nSk > 0 .AND. lCustomSrc

					cIdioma := Upper( Left( FWRetIdiom(), 2 ) )
					Do Case
						Case cIdioma == 'ES'
							cTitle := aFields[nSk]:TitleSpa
						Case cIdioma == 'EN'
							cTitle := aFields[nSk]:TitleEng
						Otherwise
							cTitle := aFields[nSk]:TitlePor
					EndCase
					
					aCampos[nCpo][1]  := If(Empty(cTitle),aCampos[nCpo][1],cTitle)
					aCampos[nCpo][8]  := aFields[nSk]:required
					aCampos[nCpo][10] := aFields[nSk]:defValue

				EndIf

            EndIf

		Endif

		SX3->(DbSkip())
	End
Endif

nPosCodCon:= Ascan(aCampos,{|x| Alltrim(x[2])== "ADE_CODCON"})
If(nPosCodCon > 0 .And. !Empty(cValidCont))
	aCampos[nPosCodCon][7] := Iif(Empty(cVldX3Cont),"",&("{||" + AllTrim(cVldX3Cont)+ " .And. "+ cValidCont +"}"))
Endif

If lTk503SKA
	Execblock("TK503SKA",.F.,.F.)
EndIf

RestArea(aArea)

Return aCampos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Metodo    ³CustomizeHeader³ Autor ³ Vendas Clientes  ³ Data ³ 02/11/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Personaliza os campos da GetDados                      	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMKA503A                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method CustomizeHeader(aHead) Class TeleServiceUserDialog

Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())
Local nPos		:= 0
Local cTitle	:= ""
Local nX		:= 1
Local lCustomSrc:= Len(GetApoInfo("TMKA500Q.PRW")) > 0
Local cIdioma 	:= ""

DbSelectArea("SX3")
DbSetOrder(2)

While nX <= Len(aHead)
	
	SX3->(DbSeek(aHead[nX][2]))
	
	//Adiciona informacoes complementares do aHeader para a MsNewGetDados	
	aSize(aHead[nX],17)
	
	aHead[nX][11] := X3CBox()
	aHead[nX][12] := SX3->X3_RELACAO
	aHead[nX][13] := SX3->X3_WHEN
	aHead[nX][14] := SX3->X3_VISUAL
	aHead[nX][15] := SX3->X3_VLDUSER
	aHead[nX][16] := SX3->X3_PICTVAR
	aHead[nX][17] := X3Obrigat(X3_CAMPO)

	nPos := aScan(Self:service:tableStructureInfo:detail:fields,{|o| Trim(o:name) == Trim(aHead[nX][2])})
	
	//Aplica customizacoes dos campos
	If (nPos > 0) .AND. lCustomSrc .AND. Self:service:tableStructureInfo:detail:fields[nPos]:Customized
		
		If !Self:service:tableStructureInfo:detail:fields[nPos]:use
			aDel(aHead,nX)
			aSize(aHead,Len(aHead)-1)
			Loop
		EndIf

		cIdioma := Upper( Left( FWRetIdiom(), 2 ) )
		Do Case
			Case cIdioma == 'ES'
				cTitle := Self:service:tableStructureInfo:detail:fields[nPos]:TitleSpa
			Case cIdioma == 'EN'
				cTitle := Self:service:tableStructureInfo:detail:fields[nPos]:TitleEng
			Otherwise
				cTitle := Self:service:tableStructureInfo:detail:fields[nPos]:TitlePor
		EndCase
		
		aHead[nX][1]  := If(Empty(cTitle),aHead[nX][1],cTitle)
		aHead[nX][17] := Self:service:tableStructureInfo:detail:fields[nPos]:required
		aHead[nX][12] := Self:service:tableStructureInfo:detail:fields[nPos]:defValue
	
	EndIf

	nX++

End

RestArea(aAreaSX3)
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³FillFieldsºAutor  ³Vendas CRM          º Data ³  25/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicializa os campos do cabecalho e itens do atendimento de º±±
±±º          ³acordo com os campos a serem copiados de outro atendimento. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA503A                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method FillFields() Class TeleServiceUserDialog

Local nX		:= 0
Local nPos		:= 0 
Local cVarBkp	:= __ReadVar

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega cabecalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(Self:aHeaderCopy)

	If Type("M->"+Self:aHeaderCopy[nX,1]) <> "U"    
	
		&("M->"+Self:aHeaderCopy[nX,1]) := Self:aHeaderCopy[nX,2]
	
		If !Empty(Self:aHeaderCopy[nX,3])
			__ReadVar := "M->"+Self:aHeaderCopy[nX,1]
			&(Self:aHeaderCopy[nX,3])
		EndIf
	
		If ExistTrigger(Self:aHeaderCopy[nX,1])
			RunTrigger(1,nil,nil,,Self:aHeaderCopy[nX,1])
		EndIf
			
	EndIf

Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega itens³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(Self:aItemsCopy)

	nPos := aScan(aHeader,{|x|AllTrim(x[2]) == Self:aItemsCopy[nX,1] })

	If nPos > 0
	
		aCols[1][nPos] := Self:aItemsCopy[nX,2]
		&("M->"+Self:aItemsCopy[nX,1]) := Self:aItemsCopy[nX,2]
	
		If !Empty(Self:aItemsCopy[nX,3])
			__ReadVar := "M->"+Self:aItemsCopy[nX,1]
			&(Self:aItemsCopy[nX,3])
		EndIf
	
		If ExistTrigger(Self:aItemsCopy[nX,1])
			RunTrigger(2,1,nil,,Self:aHeaderCopy[nX,1])
		EndIf
		
	EndIf

Next nX 

Self:aHeaderCopy	:= {}
Self:aItemsCopy		:= {}
__ReadVar := cVarBkp

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³_ISTMKTS()    ºAutor  ³Michel W. Mosca º Data ³  09/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao dummy apenas para indicar que o TeleService existe noº±±
±±º          ³RPO. Permitido apenas para Protheus 10 R 1.3 ou superior.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                   
Function _ISTMKTS()

Local lRet 		:= .T.

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK503TRsp ºAutor  ³Vendas CRM          º Data ³  12/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Interface para selecao do contato representante a ser alte- º±±
±±º          ³rado entre chamados de um periodo.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA503A                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK503TRsp()

Local aArea		:= GetArea()
Local aPDFields	:= {"ADE_DESREP", "ADE_DCHREP", "ADE_DDDREP", "ADE_TELREP"}

Local nTamCont	:= TamSX3("U5_CODCONT")[1]
Local nTamDDD	:= TamSX3("ADE_DDDREP")[1]
Local nTamTel	:= TamSX3("ADE_TELREP")[1]
Local nStatus	:= 1

Local dDataIni	:= StoD(cValToChar(Year(Date()))+"0101")
Local dDataFim	:= StoD(cValTochar(Year(Date()))+"1231")

Local lTransf	:= .F.
Local lDesRepPD	:= .F.
Local lDesEntPD	:= .F.
Local lDDDPD	:= .F.
Local lTelPD	:= .F.

Local oContOri	:= Nil
Local oDContOri	:= Nil
Local oTabOri	:= Nil
Local oDTabOri	:= Nil
Local oEntOri	:= Nil
Local oDEntOri	:= Nil
Local oContDest	:= Nil
Local oDContDest:= Nil
Local oTabDest	:= Nil
Local oDTabDest	:= Nil
Local oEntDest	:= Nil
Local oDEntDest	:= Nil
Local oDtIni	:= Nil
Local oDtFim	:= Nil
Local oBtnOk	:= Nil
Local oBtnCanc	:= Nil  
Local oTelDest 	:= Nil
Local oDDDDest	:= Nil
Local oCmbStat	:= Nil

Local cDDDDest	:= Space(nTamDDD)
Local cTelDest	:= Space(nTamTel) 
Local cItem		:= ""

Private cContOri	:= Space(nTamCont)
Private cDContOri	:= ""
Private cTabOri		:= ""
Private cDTabOri	:= ""
Private cEntOri		:= ""
Private cDEntOri	:= ""
Private cContDest	:= Space(nTamCont)
Private cDContDest	:= ""
Private cTabDest	:= ""
Private cDTabDest	:= ""
Private cEntDest	:= ""
Private cDEntDest	:= ""

Private oDlg		:= Nil 

FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)

lDesRepPD := FATPDIsObfuscate("ADE_DESREP")
lDesEntPD := FATPDIsObfuscate("ADE_DCHREP")
lDDDPD := FATPDIsObfuscate("ADE_DDDREP")
lTelPD := FATPDIsObfuscate("ADE_TELREP")

DEFINE MSDIALOG oDlg TITLE STR0044 FROM 000, 000 TO 370, 500 PIXEL //"Transferência de responsável"
    
	//Contato responsavel original
	@ 004, 002 TO 063, 241 PROMPT STR0045 OF oDlg PIXEL //"Responsável original"
    
    @ 019, 008 SAY STR0046	SIZE 078, 010 OF oDlg PIXEL //"Contato" 
    @ 032, 008 SAY STR0047	SIZE 078, 010 OF oDlg PIXEL //"Entidade"
    @ 045, 008 SAY STR0048 	SIZE 078, 010 OF oDlg PIXEL //"Dados da entidade"
    
    @ 018, 075 MSGET oContOri 	VAR cContOri  SIZE 037, 010 OF oDlg PIXEL F3 "TMK017" Valid IIF(!Empty(cContOri),Tk503AVlCnt(cContOri,cTabOri,cEntOri),Nil)
    @ 018, 118 MSGET oDContOri 	VAR cDContOri SIZE 120, 010 OF oDlg PIXEL WHEN .F. 
    @ 031, 075 MSGET oTabOri 	VAR cTabOri 	SIZE 037, 010 OF oDlg PIXEL WHEN .F.
    @ 031, 118 MSGET oDTabOri 	VAR cDTabOri 	SIZE 120, 010 OF oDlg PIXEL WHEN .F.
    @ 044, 075 MSGET oEntOri 	VAR cEntOri 	SIZE 037, 010 OF oDlg PIXEL WHEN .F.
    @ 044, 118 MSGET oDEntOri 	VAR cDEntOri 	SIZE 120, 010 OF oDlg PIXEL WHEN .F.
	
	If FATPDActive() .And. FTPDUse(.T.)
		oDContOri:lObfuscate := lDesRepPD
		oDEntOri:lObfuscate := lDesEntPD
	Endif

	//Contato responsavel de destino
    @ 068, 003 TO 136, 241 PROMPT STR0049 OF oDlg PIXEL //"Responsável de destino"
    
    @ 083, 008 SAY STR0046	SIZE 078, 010 OF oDlg PIXEL	//"Contato"
    @ 096, 008 SAY STR0047	SIZE 078, 010 OF oDlg PIXEL //"Entidade"
    @ 109, 008 SAY STR0048	SIZE 078, 010 OF oDlg PIXEL //"Dados da entidade"
    @ 122, 008 SAY STR0050	SIZE 078, 010 OF oDlg PIXEL //"DDD + Telefone"	

    @ 082, 075 MSGET oContDest	VAR cContDest	   SIZE 037, 010 OF oDlg PIXEL F3 "TMK017" Valid IIF(!Empty(cContDest),Tk503AVlCnt(cContDest,cTabDest,cEntDest),Nil)
    @ 082, 118 MSGET oDContDest	VAR cDContDest	SIZE 120, 010 OF oDlg PIXEL WHEN .F.
    @ 095, 075 MSGET oTabDest	VAR cTabDest	SIZE 037, 010 OF oDlg PIXEL WHEN .F.
    @ 095, 118 MSGET oDTabDest 	VAR cDTabDest	SIZE 120, 010 OF oDlg PIXEL WHEN .F.
    @ 108, 075 MSGET oEntDest	VAR cEntDest	SIZE 037, 010 OF oDlg PIXEL WHEN .F.
    @ 108, 118 MSGET oDEntDest	VAR cDEntDest	SIZE 120, 010 OF oDlg PIXEL WHEN .F.    
    @ 121, 075 MSGET oDDDDest	VAR cDDDDest	SIZE 016, 010 OF oDlg PIXEL Picture PesqPict("ADE", "ADE_DDDREP") WHEN !lDDDPD
    @ 121, 095 MSGET oTelDest	VAR cTelDest	SIZE 080, 010 OF oDlg PIXEL Picture PesqPict("ADE", "ADE_TELREP") WHEN !lTelPD

	If FATPDActive() .And. FTPDUse(.T.)
		oDContDest:lObfuscate := lDesRepPD
		oDEntDest:lObfuscate := lDesEntPD
		oDDDDest:lObfuscate := lDDDPD
		oTelDest:lObfuscate := lTelPD
	Endif
	
	//Data de referencia
    @ 142, 004 SAY STR0051	SIZE 046, 008 OF oDlg PIXEL	//"Da data:"
    @ 142, 124 SAY STR0052 	SIZE 046, 008 OF oDlg PIXEL //"Até a data:"

    @ 141, 058 MSGET oDtIni VAR dDataIni SIZE 058, 010 OF oDlg PIXEL
    @ 141, 178 MSGET oDtFim VAR dDataFim SIZE 058, 010 OF oDlg PIXEL  

    @ 155, 004 SAY STR0062	SIZE 070, 008 OF oDlg PIXEL	//"Status do chamado:"
    @ 155, 058 MSCOMBOBOX oCmbStat VAR cItem ITEMS {STR0063,STR0064,STR0065,STR0066} ON CHANGE (nStatus := oCmbStat:nAt) SIZE 055, 010 OF oDlg PIXEL //"Em Aberto"###"Pendente"###"Encerrado"###"Todos"
		
	//Botoes    
    @ 160, 157 BUTTON oBtnOk	PROMPT STR0053	SIZE 036, 014 OF oDlg PIXEL Action IIF(Empty(cContOri) .AND. Empty(cContOri), MSGAlert(STR0079) ,(lTransf := .T.,oDlg:End() ) ) //"Ok"//"Existem campos sem preenchimento!"
    @ 160, 199 BUTTON oBtnCanc	PROMPT STR0054	SIZE 040, 014 OF oDlg PIXEL Action oDlg:End() //"Cancela"

	 FATPDLogUser("TK503TRSP") 

ACTIVATE MSDIALOG oDlg CENTERED

If lTransf

	If !(Tk503AVlCnt(cContOri,cTabOri,cEntOri) .AND. Tk503AVlCnt(cContDest,cTabDest,cEntDest))
		RestArea(aArea)
		Return .F.
	EndIf
	
	If cContOri == cContDest
		MsgStop(STR0055) //"Os contatos de origem e destino são idênticos"
		RestArea(aArea)
		Return .F.
	EndIf
	
	If MsgYesNo(STR0056+ FATPDObfuscate(cDContOri,"ADE_DESREP") + STR0057+ FATPDObfuscate(cDContDest,"ADE_DCHREP")+"?") //"Confirma a transferência dos chamados do contato "###" para o contato "
		Tk503ATrCnt(cContOri	, cTabOri	, cEntOri 	, cContDest	,;
					cTabDest	, cEntDest	, cDDDDest 	, cTelDest	,;
					dDataIni	, dDataFim	, nStatus	) 
	EndIf

EndIf

FATPDUnload()
aSize(aPDFields, 0)      
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk503AEnt ºAutor  ³Vendas CRM          º Data ³  12/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta especifica para acionar a tela de selecao de conta-º±±
±±º          ³tos.                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA503A                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk503AEnt()

Local lRet 			:= .F.
Local cBkReadV		:= __ReadVar      

Private N			:= 0

If !IsInCallStack("TK503TRsp")
	Return .F.
EndIf

RegToMemory("ADE",.T.,.T.,.F.)
__ReadVar := "M->ADE_CODREP"
lRet := TkSelEnt(.T.)
__ReadVar	:= cBkReadV

If lRet  
	If ReadVar() == "CCONTORI"    	
		cContOri	:= M->ADE_CODREP
		cDContori	:= M->ADE_DESREP
		cTabOri 	:= M->ADE_ENTREP
		cDTabOri 	:= M->ADE_DESENT
		cEntOri 	:= M->ADE_CHVREP
		cDEntOri 	:= M->ADE_DCHREP 		 
	Else    	
		cContDest	:= M->ADE_CODREP
		cDContDest	:= M->ADE_DESREP
		cTabDest	:= M->ADE_ENTREP
		cDTabDest	:= M->ADE_DESENT
		cEntDest	:= M->ADE_CHVREP
		cDEntDest	:= M->ADE_DCHREP 
	EndIf	
EndIf

Return lRet        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk503AVlCntºAutor  ³Vendas CRM         º Data ³  12/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao do contato selecionado                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA503A                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk503AVlCnt(cContato,cTab,cEnt)

Local lRet := ExistCpo("SU5",cContato,1)

If lRet .AND. (Empty(cTab) .OR. Empty(cEnt))
	MsgStop(STR0058) //"Utilize a consulta padrão (F3) para selecionar o contato"
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk503ATrCntºAutor  ³Vendas CRM         º Data ³  13/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a transferencia dos chamados entre representantes    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Codigo do contato original                          º±±
±±º          ³ExpC2 - Tabela da entidade original                         º±±
±±º          ³ExpC3 - Codigo da entidade original                         º±±
±±º          ³ExpC4 - Codigo do contato de destino                        º±±
±±º          ³ExpC5 - Tabela da entidade de destino                       º±±
±±º          ³ExpC6 - Codigo da entidade de destino                       º±±
±±º          ³ExpC7 - DDD da entidade de destino                          º±±
±±º          ³ExpC8 - Telefone da entidade de destino                     º±±
±±º          ³ExpD9 - Data inicial para pesquisa dos chamados             º±±
±±º          ³ExpD10- Data final para pesquisa dos chamados               º±±
±±º          ³ExpN11- Status do chamado                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA503A                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk503ATrCnt(cContOri	, cTabOri	, cEntOri	, cContDest	,;
							cTabDest	, cEntDest	, cDDDDest	, cTelDest	,;
							dDataIni	, dDataFim	, nStatus	)

Local aArea		:= GetArea()
Local aRecnos	:= {}
Local nX		:= 0  
Local cQuery	:= "" 
Local cAlias 	:= "ADE"
Local lTop		:= .F.

cContOri:= cContOri + Space(TamSX3("ADE_CODREP")[1]-Len(cContOri))
cTabOri	:= cTabOri  + Space(TamSX3("ADE_ENTREP")[1]-Len(cTabOri))
cEntOri	:= cEntOri  + Space(TamSX3("ADE_CHVREP")[1]-Len(cEntOri))

cQuery := "SELECT R_E_C_N_O_ AS NUMREG FROM " + RetSQLName("ADE")
cQuery += " WHERE ADE_CODREP = '" + cContOri + "' AND ADE_ENTREP = '" + cTabOri + "' AND ADE_CHVREP = '" + cEntOri + "'"
cQuery += " AND ADE_DATA BETWEEN '" + DtoS(dDataIni) + "' AND '" + DtoS(dDataFim) + "'"

If nStatus < 4
	cQuery += " AND ADE_STATUS = '"+cValToChar(nStatus)+"'"
EndIf

cQuery += " AND D_E_L_E_T_ = ''"

cQuery	:= ChangeQuery(cQuery)
cAlias	:= GetNextAlias()
lTop	:= .T.

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
DbGoTop()

While !(cAlias)->(Eof())
	AAdd(aRecnos,Iif(lTop,(cAlias)->NUMREG,Recno()))
	(cAlias)->(DbSkip())
End

(cAlias)->(DbCloseArea())	
	
DbSelectArea("ADE")

For nX := 1 to Len(aRecnos)
	DbGoTo(aRecnos[nX])
	RecLock("ADE",.F.)
	ADE->ADE_CODREP := cContDest
	ADE->ADE_ENTREP := cTabDest
	ADE->ADE_CHVREP	:= cEntDest 
	ADE->ADE_DDDREP	:= cDDDDest
	ADE->ADE_TELREP	:= cTelDest
	MsUnLock()
Next nX

MsgInfo(STR0059 + cValToChar(--nX) + STR0060) //"Transferencia finalizada, "###" chamados transferidos."

RestArea(aArea)

Return Nil   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³GetNumADE ³ Autor ³Vendas CRM             ³ Data ³ 14/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializa o Numero do Chamado do Help Desk                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Numero do Chamado                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lConfirma : Confirma a utilizacao do Numero                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GetNumADE(lConfirma)

Local aArea			:= GetArea()
Local aAreaADE		:= ADE->(GetArea())
Local cNumCh		:= "" 
Local nStatus		:= 0

Default lConfirma	:= .F.

cNumCh:=GetSxENum("ADE","ADE_CODIGO")

dbSelectArea("ADE")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Possiveis retornos da ChkChaveADE()                               ³
//³0 - Numero livre para utilizacao                                  ³
//³1 - Numero livre para utilizacao mas ja solicitado por outra thead³
//³2 - Numero ja utilizado, baixar no SXE/SXF                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

While (nStatus := ChkChaveADE(cNumCh)) <> 0
	If ( __lSx8 ) .AND. nStatus == 2
		ConfirmSX8()
	EndIf
	cNumCh := GetSxENum("ADE","ADE_CODIGO")
EndDo

If ( lConfirma )
	If ( __lSx8 )
		ConfirmSX8()
	EndIf
EndIf 

RestArea(aAreaADE)
RestArea(aArea)

Return(cNumCh)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ChkChaveADE³ Autor ³Edson Maricate        ³ Data ³11.12.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica a existencia do numero do pedido de Compras        ³±±
±±³          ³O numero do pedido de compras deve ser controlado no modo   ³±±
±±³          ³compartilhado devido ao controle por Filial de Entrega.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nRet:0-Numero livre para utilizacao                         ³±±
±±³          ³     1-Numero livre para utilizacao mas em uso outra thread ³±±
±±³          ³     2-Numero ja utilizado, baixar no SXE/SXF               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ChkChaveADE(cNumCh)

Local nRet		:= 0
Local aArea		:= GetArea()
Local aAreaADE	:= ADE->(GetArea())
Local aAreaSM0	:= SM0->(GetArea())
Local cQuery    := ""

If FWModeAccess("ADE",3) == "C"
	ADE->(dbSetOrder(1))
	If ADE->(MsSeek(xFilial("ADE")+cNumCh))
		nRet := 2
	EndIf
Else
	ADE->(dbSetOrder(1))
	
	cQuery := "Select COUNT(*) ADEPED"
	cQuery += "  From "+RetSqlName("ADE")+" ADE"
	cQuery += " Where ADE.ADE_CODIGO = '"+cNumCh+"'"
	cQuery += "   And ADE.D_E_L_E_T_=' '"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CHKADE",.T.,.T.)
	
	If CHKADE->ADEPED > 0
		nRet := 2
	EndIf
	dbCloseArea()
EndIf


//Verifica se o numero sugerido nao esta em uso ao mesmo tempo em outra filial (antes do confirmSX8)
If nRet == 0 .AND. !LockByName("TMKADE"+cNumCH,.F.,.F.,.T.)
	nRet := 1
EndIf

RestArea(aAreaSM0)
RestArea(aAreaADE)
RestArea(aArea) 

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk503Browseº Autor  ³Vendas CRM         º Data ³  15/12/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para a construção da FWMBROWSE                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA503A                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method Tk503Browse(cAlias) Class TeleServiceUserDialog

Local nX 	    := 0
Local aLegenda  := {}
Local lTk503Leg := ExistBlock("TK503LEG")	//Ponto de entrada para criação de leganda no browse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias(cAlias)
oBrowse:SetDescription(STR0005)

If lTk503Leg
	aLegenda := Execblock("TK503LEG",.F.,.F.)
	If ValType(aLegenda) == "A"
		For nX := 1 To Len(aLegenda)
			If ValType(aLegenda[nX][1])=="C" .And. ValType(aLegenda[nX][2])=="C" .And. ValType(aLegenda[nX][3])=="C"
				//oBrowse:AddLegend(<cRegra>,<cCor>,<cDescrição>)
				oBrowse:AddLegend(aLegenda[nX][1],aLegenda[nX][2],aLegenda[nX][3])
			EndIf
		Next nX
	EndIf
EndIf

oBrowse:Activate()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LoadVarAntTrf º Autor ³Igor Franzoi       º Data ³  09/02/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para alimentar as variáveis, p/ canc. transf. cham.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA503A                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method LoadVarAntTrf() Class TeleServiceUserDialog

::cGrpADEAnt := M->ADE_GRUPO
::cDesADEAnt := M->ADE_DESCGP
::cOpeADEAnt := M->ADE_OPERAD
::cNopADEAnt := M->ADE_NMOPER
::cPrdADEAnt := M->ADE_PRDANT
::cCsbADEAnt := M->ADE_CODSB1
::cNprADEAnt := M->ADE_NMPROD
::cAsuADEAnt := M->ADE_ASSUNT
::cAsaADEAnt := M->ADE_ASSANT
::cCatADEAnt := M->ADE_CODCAT
::cCatDesAnt := M->ADE_NCATEG
::cOriADEAnt := M->ADE_CODORI
::cOriDesAnt := M->ADE_NORIGE
::cCauADEAnt := M->ADE_CODCAU
::cCauDesAnt := M->ADE_NCAUSA
::cEfeADEAnt := M->ADE_CODEFE
::cEfeDesAnt := M->ADE_NEFEIT
::cCamADEAnt := M->ADE_CODCAM
::cCamDesAnt := M->ADE_DSCCAM
::cCasADEAnt := M->ADE_DESCAS

Return (Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LoadVarTrf º Autor ³Igor Franzoi       º Data ³  09/02/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para alimentar as variáveis, p/ canc. transf. cham.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA503A                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method LoadVarTrf() Class TeleServiceUserDialog

aAdd( aVarTrf, M->ADE_DESCGP	)
aAdd( aVarTrf, M->ADE_OPERAD	)
aAdd( aVarTrf, M->ADE_ASSUNT	)
aAdd( aVarTrf, M->ADE_CODSB1 	)
aAdd( aVarTrf, M->ADE_GRUPO		)
aAdd( aVarTrf, M->ADE_CODCAT 	)
aAdd( aVarTrf, M->ADE_CODORI 	)
aAdd( aVarTrf, M->ADE_CODCAU 	)
aAdd( aVarTrf, M->ADE_CODEFE 	)
aAdd( aVarTrf, M->ADE_CODCAM	)

Return (Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValTrfADE  º Autor ³Igor Franzoi       º Data ³  09/02/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo que valida a transf. no aCols						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA503A                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method ValTrfADE() Class TeleServiceUserDialog

Local nPos		:= 0
Local nCount 	:= 0
Local nFields	:= 0

If ( ( nPos := aScan( aTrfVld, { |x| x[12] == .T. } ) ) > 0 )

	Self:cGrpADEAnt := aTrfVld[nPos,05]
	Self:cDesADEAnt := aTrfVld[nPos,01]
	
	Self:cOpeADEAnt := aTrfVld[nPos,02]
	Self:cNopADEAnt := aTrfVld[nPos,15]

	Self:cAsuADEAnt := aTrfVld[nPos,03]
	Self:cAsaADEAnt := aTrfVld[nPos,17]

	Self:cCsbADEAnt := aTrfVld[nPos,04]
	Self:cNprADEAnt := aTrfVld[nPos,14]
	
	Self:cCatADEAnt := aTrfVld[nPos,06]
	Self:cCatDesAnt := aTrfVld[nPos,18]
	
	Self:cOriADEAnt := aTrfVld[nPos,07]
	Self:cOriDesAnt := aTrfVld[nPos,19]
	
	Self:cCauADEAnt := aTrfVld[nPos,08]
	Self:cCauDesAnt := aTrfVld[nPos,20]
	
	Self:cEfeADEAnt := aTrfVld[nPos,09]
	Self:cEfeDesAnt := aTrfVld[nPos,21]
	
	Self:cCamADEAnt := aTrfVld[nPos,10]
	Self:cCamDesAnt := aTrfVld[nPos,22]
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Transfere dados da tab. Master para o Objeto  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCount := 1 To Len(Self:service:tableStructureInfo:master:rows)
	For nFields := 1 To Len(Self:service:tableStructureInfo:master:rows[nCount]:fields)
		cField := Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:name
		If ( AllTrim(cField) == "ADE_GRUPO" .or. AllTrim(cField) == "ADE_DESCGP" )
			If ( AllTrim(cField) == "ADE_GRUPO" )
				M->ADE_GRUPO := Self:cGrpADEAnt
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := Self:cGrpADEAnt
			Else
				M->ADE_DESCGP := Self:cDesADEAnt
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := Self:cDesADEAnt
			EndIf
		ElseIf ( AllTrim(cField) == "ADE_OPERAD" .or.;
				AllTrim(cField) == "ADE_NMOPER" .or.;
				AllTrim(cField) == "ADE_ASSUNT" .or.;
				AllTrim(cField) == "ADE_ASSANT" )
			If ( AllTrim(cField) == "ADE_OPERAD" )
				M->ADE_OPERAD := Self:cOpeADEAnt
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := Self:cOpeADEAnt
			ElseIf ( AllTrim(cField) == "ADE_NMOPER" )
				M->ADE_NMOPER := Self:cNopADEAnt
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := Self:cNopADEAnt
			ElseIf ( AllTrim(cField) == "ADE_ASSUNT" )
				M->ADE_ASSUNT := Self:cAsuADEAnt
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := Self:cAsuADEAnt
			Else
				M->ADE_ASSANT := Self:cAsaADEAnt
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := Self:cAsaADEAnt
			EndIf
		ElseIf ( AllTrim(cField) == "ADE_CODSB1" .or. AllTrim(cField) == "ADE_NMPROD" )
			If ( AllTrim(cField) == "ADE_CODSB1" )
				M->ADE_CODSB1 := Self:cCsbADEAnt
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := Self:cCsbADEAnt
			Else
				M->ADE_NMPROD := Self:cNprADEAnt
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := Self:cNprADEAnt
			EndIf
		ElseIf ( AllTrim(cField) == "ADE_CODCAT" .or. AllTrim(cField) == "ADE_NCATEG" )
			If ( AllTrim(cField) == "ADE_CODCAT" )
				M->ADE_CODCAT := Self:cCatADEAnt
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := Self:cCatADEAnt
			Else
				M->ADE_NCATEG := Self:cCatDesAnt
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := Self:cCatDesAnt
			EndIf
		ElseIf ( AllTrim(cField) == "ADE_CODORI" .or. AllTrim(cField) == "ADE_NORIGE" )
			If ( AllTrim(cField) == "ADE_CODORI" )
				M->ADE_CODORI := Self:cOriADEAnt
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := Self:cOriADEAnt
			Else
				M->ADE_NORIGE := Self:cOriDesAnt
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := Self:cOriDesAnt
			EndIf
		ElseIf ( AllTrim(cField) == "ADE_CODCAU" .or. AllTrim(cField) == "ADE_NCAUSA" )
			If ( AllTrim(cField) == "ADE_CODCAU" )
				M->ADE_CODCAU := Self:cCauADEAnt
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := Self:cCauADEAnt
			Else
				M->ADE_NCAUSA := Self:cCauDesAnt
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := Self:cCauDesAnt
			EndIf
		ElseIf ( AllTrim(cField) == "ADE_CODEFE" .or. AllTrim(cField) == "ADE_NEFEIT" )
			If ( AllTrim(cField) == "ADE_CODEFE" )
				M->ADE_CODEFE := Self:cEfeADEAnt
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := Self:cEfeADEAnt
			Else
				M->ADE_NEFEIT := Self:cEfeDesAnt
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := Self:cEfeDesAnt
			EndIf
		ElseIf ( AllTrim(cField) == "ADE_CODCAM" .or. AllTrim(cField) == "ADE_DSCCAM" )
			If ( AllTrim(cField) == "ADE_CODCAM" )
				M->ADE_CODCAM := Self:cCamADEAnt
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := Self:cCamADEAnt
			Else
				M->ADE_DSCCAM := Self:cCamDesAnt
				Self:service:tableStructureInfo:master:rows[nCount]:fields[nFields]:value:value := Self:cCamDesAnt
			EndIf
		EndIf
	Next nFields
Next nCount

Return (Nil)

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuário utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serão verificados.
    @param aFields, Array, Array com todos os Campos que serão verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com proteção de dados.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive
