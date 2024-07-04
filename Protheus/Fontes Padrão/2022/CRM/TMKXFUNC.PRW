#INCLUDE "TMKXFUNC.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "AP5MAIL.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "APWIZARD.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³TkMontaItens ³ Autor ³ Vendas e CRM       ³ Data 10/10/2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Monta a getdados dos itens do atendimento para o Historico  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpC1 - Alias, ExpC2 - Codigo da Ligacao, ExpC3 - Rotina    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CALL CENTER  									   	          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                     
Function TkMontaItens(cAlias,cCodLig,cTipo,nIndice)

Local lSaveInc	:= .F.		//Copia do INCLUI
Local cSeek		:= ""		//Expressao Seek para posicionar na tabela
Local cWhile		:= ""		//Enquanto for igual a cSeek
Local bCond		:= {|| .T. }

Default nIndice := 1

aHeader	:= {}
aCols	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz uma copia do INCLUI para depois restaura-la                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lSaveInc:= INCLUI

Do Case
	Case (cAlias == "SUB")
		cWhile	:= "SUB->UB_FILIAL + SUB->UB_NUM"
		INCLUI  := .F.

	Case (cAlias == "SUD")
		cWhile	:= 	"SUD->UD_FILIAL + SUD->UD_CODIGO"
		INCLUI  := .F.

	Case (cAlias == "ACG")
		cWhile	:= "ACG->ACG_FILIAL + ACG->ACG_CODIGO"
		INCLUI  := .F.
	
	Case cAlias == "ACC"
		cWhile	:= "ACC->ACC_FILIAL + ACC->ACC_CODOBJ"

	Case cAlias == "SU6"
		cWhile	:= "SU6->U6_FILIAL + SU6->U6_LISTA"	

	Case cAlias == "SU8"
		cWhile	:= "SU8->U8_FILIAL + SU8->U8_CRONUM"

	Case cAlias == "AB2"
		cWhile	:= "AB2->AB2_FILIAL + AB2->AB2_NRCHAM"
		
	Case cAlias == "AB7"
		cWhile	:= "AB7->AB7_FILIAL + AB7->AB7_NUMOS"
		
	Case cAlias == "SC6"
		cWhile	:= "SC6->C6_FILIAL + SC6->C6_NUM" 

	Case cAlias == "SL2"
		cWhile	:= "SL2->L2_FILIAL + SL2->L2_NUM"

	Case cAlias == "SD1"
		cWhile	:= "SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA"
	
	Case cAlias == "MEJ"
		cWhile	:= "MEJ->MEJ_FILIAL + MEJ->MEJ_CODREG"
		
	Case cAlias == "MBP"
		cWhile	:= "MBP->MBP_FILIAL + MBP->MBP_NUMCAR"		
		bCond	:= {|| If( MBP->MBP_DTVAL >= dDatabase , .T. , .F. ) }
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa FillGetDados para preencher o aHeader e aCols ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSeek  := xFilial(cAlias) + cCodLig
If Empty(cCodLig)
	
	FillGetDados(	2				,cAlias		,nIndice							,/*cSeek	  */,;
					/*{|| &cWhile}*/,{|| .T. }	,/*aNoFields*/				,/*aYesFields*/	,; 
					/*lOnlyYes*/	,/*cQuery*/	,{|| TkaColsVazio(cAlias) }	,.F.			) 
	
Else

	FillGetDados(	2				,cAlias			,nIndice							,cSeek			,;
	  				{|| &cWhile }	,bCond		,/*aNoFields*/				,/*aYesFields*/	,; 
					/*lOnlyYes*/	,/*cQuery*/		,/*bMontCols*/				,/*lEmpty*/		,;
					/*aHeaderAux*/	,/*aColsAux*/	,{|| TkxAlteraCols(cTipo) }	,/*bBeforeCols*/	)

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura o valor original do INCLUI ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
INCLUI:= lSaveInc

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271Transfer	 ³ Autor ³ Vendas e CRM          ³ Data ³ 19/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa a gravacao e seleciona o modulo para a transferencia     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso   	 ³SIGATMK - TELEMARKETING                        				   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkTransfer(nTipo			,nOpc			,oFolderTmk		,oEnchTmk	,;
					cEncerra		,cMotivo		,oFolderTlv		,oEnchTlv	,;
					cCodPagto		,cDescPagto		,cCodTransp		,cTransp	,;
					cCob			,cEnt			,cCidadeC		,cCepC		,;
					cUfC			,cBairroE		,cBairroC		,cCidadeE	,;
					cCepE			,cUfE			,nLiquido		,nTxJuros	,;
					nTxDescon		,nVlJur			,aParcelas		,nEntrada	,;
					nFinanciado		,nNumParcelas	,nValorCC		,oCrono		,;
					cCrono			,nTimeSeg		,nTimeMin		,lHabilita	,;
					oFolderTlc		,oEnchTlc		,aColsTmk		,aColsTlv	,;
					oDlg			,cCodAnt		,aParScript		,l380		,;
					lMsg			,aSx3SUA		,cAgenda		,nValNFat	,;
					aSx3SUC			,aItens			,oCodPagto		,oDescPagto	,;
					oCodTransp		,oTransp		,oCob			,oEnt		,;
					oCidadeC		,oUfC			,oBairroE		,oCepC		,;
					oCidadeE		,oBairroC		,cCidadeE		,oCepE		,;
					oUfE			,oLiquido		,nTxJuros		,oTxJuros	,;
					oTxDescon		,oParcelas		,oEntrada		,oFinanciado,;
					oNumParcelas	,lTipo9			,oValNFat		,lSigaCRD)
Local cNumTmkOri:= ""   // Numero do atendimento TeleMarketing
Local cCodOper  := ""   // Variavel para armazenar os dados do SUC
Local cChave    := ""   // Variavel para armazenar os dados do SUC
Local cCodCont  := ""   // Variavel para armazenar os dados do SUC
Local cContato  := ""   // Variavel para armazenar os dados do SUC
Local cAb1CodCli:= ""   // Codigo do cliente no Ab1 - Chamado tecnico 
Local cAb1Loja  := ""   // Codigo da loja no Ab1 - Chamado tecnico
Local cAb1Contat:= ""   // Codigo do contato no Ab1 - Chamado tecnico
Local cDescCli  := ""   // Descricao do Cliente
Local aChamado  := {}	// Array auxiliar	
Local aBkpArea  := {}	// Salva a area atual	
Local lRet      := .F.  // Retorno da funcao
Local aSaveCols := {}	// Guarda a estrutura do aCols
Local nSave     := 0	// Grauda a posição do aCols

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Avalia qual o FOLDER esta aberto. Esta rotina esta disponivel somente para TeleMarketing.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nFolder == 1 .AND. (TkGetTipoAte() == "2" .OR. TkGetTipoAte() == "3")) .OR. (nFolder <> 1) //Televendas Telecobranca
	Help( " ", 1, "TMKROTINA" ) //"Esta rotina esta dispon¡vel apenas para Telemarketing !","Aten‡„o"
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente clientes podem ter um chamado Tecnico.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->UC_ENTIDAD <> "SA1"
	Help( " ", 1, "TMKSOCLI" )
	Return (lRet)
Endif

If (nFolder == 1)
	If (TkGetTipoAte()$ "145" ) //Telemarketing - Todos - TMK X TLV
		cChave    := M->UC_CHAVE
		cCodOper  := M->UC_OPERADO
		cCodCont  := M->UC_CODCONT
		cContato  := M->UC_DESCNT
		cNumTmkOri:= M->UC_CODIGO
        cDescCli  := Posicione("SA1",1,xFilial("SA1")+SubStr(cChave,1,TamSX3("A1_COD")[1]+TamSX3("A1_LOJA")[1]),"A1_NOME")        
	Endif
Endif 

If Empty(cChave)
	Help(" ",1,"SEM CLIENT")
	Return(lRet)
ElseIf Empty(cCodCont) .AND. Empty(cContato)
	Help(" ",1,"SEM CONTAT")
	Return(lRet)
Endif

//Valida se ja foi feita a gravacao dos dados
If (nOpc == 3 .Or. nOpc == 4 ) //Inclusao ou alteracao.
	If TmkOk(STR0005,STR0006) //"Deseja gravar e tranferir o atendimento ?","Atencao"
		
		If !Tk271Grava(	@nOpc          	,@oFolderTmk	,@nTimeSeg		,@nTimeMin   	,;
						@oCrono        	,@cCrono        ,@oEnchTmk      ,@cMotivo    	,;
						@cEncerra      	,@oFolderTlv    ,@oEnchTlv      ,@cCodPagto  	,;
						@cDescPagto    	,@cCodTransp    ,@cTransp       ,@cCob       	,;
						@cEnt          	,@cCidadeC      ,@cCepC         ,@cUfC       	,;
						@cBairroE      	,@cBairroC      ,@cCidadeE      ,@cCepE      	,;
						@cUfE          	,@nLiquido      ,@nTxJuros      ,@nTxDescon  	,;
						@nVlJur        	,@aParcelas     ,@nEntrada      ,@nFinanciado	,;
						@nNumParcelas  	,@nValorCC      ,@lHabilita     ,@oFolderTlc 	,;
						@oEnchTlc      	,aColsTmk       ,aColsTlv       ,@oDlg       	,;
						@cCodAnt       	,aParScript		,l380			,@lMsg		 	,;
						aSx3SUA			,cAgenda		,nValNFat		,aSx3SUC	 	,;	
						@aItens			,oCodPagto		,@oDescPagto	,@oCodTransp 	,;
						@oTransp		,@oCob			,@oEnt			,@oCidadeC	 	,;
						@oUfC			,@oBairroE		,@oCepC			,@oCidadeE		,;
						@oBairroC		,@cCidadeE	 	,@oCepE			,@oUfE			,;
						@oLiquido		,@nTxJuros	 	,@oTxJuros		,@oTxDescon		,;
						@oParcelas		,@oEntrada	 	,@oFinanciado	,@oNumParcelas	,;
						@lTipo9			,@oValNFat		,Nil			,Nil			,;
						lSigaCRD)
			Return(lRet)
		Endif
	Else
		Return(lRet)
	Endif
Endif

If (nTipo == 1) //Integracao com SIGATEC
	lRet := .T.
	If (nOpc == 3)
	   	
		aSaveCols := aClone(aCols)
		nSave     := n

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chama a tela de inclusao do chamado tecnico³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aChamado,{"AB1_CODCLI",SubStr(cChave,1,TamSX3("A1_COD")[1])})
		Aadd(aChamado,{"AB1_LOJA"  ,SubStr(cChave,TamSX3("A1_COD")[1] + 1, TamSX3("A1_LOJA")[1])})
        Aadd(aChamado,{"AB1_NOMCLI",cDescCli})
		Aadd(aChamado,{"AB1_CONTAT",cContato})
		Aadd(aChamado,{"AB1_NUMTMK",cNumTmkOri})
	       
		aRetCham:= Teca300("At300Inclu",aChamado)
			
	ElseIf (nOpc == 4)
	   	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pesquisa os dados para alteracao.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   	 aBkpArea := GetArea()

	   	 DbSelectArea("AB1")	
	   	 DbSetOrder(5)
	   	 If DbSeek(xFilial("AB1") + cNumTmkOri )
	   	 	cAb1CodCli := AB1_CODCLI
    	 	cAb1Loja   := AB1_LOJA
	   	 	cAb1Contat := AB1_CONTAT	   	 
	   	 Endif

	   	 RestArea(aBkpArea)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso seja alteracao do atendimento Tmk mas nao ha referencia³
		//³no AB1(chamado Tecnico) para este codigo de atendimento     ³
		//³executa a inclusao de chamado do Field Service.             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aChamado,{"AB1_CODCLI",IIF(!Empty(cAb1CodCli),cAb1CodCli,SubStr(cChave,1,TamSX3("A1_COD")[1]))})
		Aadd(aChamado,{"AB1_LOJA"  ,IIF(!Empty(cAb1Loja),cAb1Loja,(SubStr(cChave,TamSX3("A1_COD")[1] + 1, TamSX3("A1_LOJA")[1])))})
	    Aadd(aChamado,{"AB1_NOMCLI",Posicione("SA1",1,xFilial("SA1")+(IIF(!Empty(cAb1CodCli),cAb1CodCli,SubStr(cChave,1,TamSX3("A1_COD")[1]))),"A1_NOME")})
		Aadd(aChamado,{"AB1_CONTAT",IIF(!Empty(cAb1Contat),cAb1Contat,cContato)})
		Aadd(aChamado,{"AB1_NUMTMK",cNumTmkOri}) 

	  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chama a tela  do chamado tecnico³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRetCham:= Teca300(IIF(Empty(cAb1CodCli),"At300Inclu","At300Alter"),aChamado)

	Endif
Endif

// Restaura o aCloes e a posicao para o atendimento do Telemarketing.
aCols   := aClone(aSaveCols)
n     	:= nSave

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TkAccount ³ Autor ³ Vendas e CRM          ³ Data ³ 26/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para a digitacao da conta e senha                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkAccount(cAccount,cPassword)
Local oDlgCont
Local oContaMail
Local oSenha
Local cContaMail := cAccount
Local cSenha     := cPassword
Local lRet       := .T.
Local nOpcao     := 0

If Empty(cAccount) .Or. Empty(cPassword)
	
	cContaMail := Space(70)
	cSenha     := Space(70)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra tela para a escolha da execucao do contato com o cliente    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgCont FROM  23,181 TO 150,486 TITLE STR0007 PIXEL  //"Dados da Conta de Email" 

		@  8,4  TO  45,149 LABEL "" OF oDlgCont PIXEL                                       
	
		@ 15,6  SAY STR0008 SIZE  70,7 OF oDlgCont PIXEL COLOR CLR_BLUE //"Conta" 
		@ 15,54 MSGET oContaMail VAR cContaMail Picture "@x" SIZE 60,8 OF oDlgCont PIXEL
	
		@ 30,6  SAY STR0009 SIZE  70,7 OF oDlgCont PIXEL COLOR CLR_BLUE //"Senha" 
		@ 30,54 MSGET oSenha VAR cSenha PASSWORD SIZE 60,8 OF oDlgCont PIXEL
	
		DEFINE SBUTTON FROM 50 ,85  TYPE 1 PIXEL ACTION (nOpcao:= 1, oDlgCont:End()) ENABLE OF oDlgCont
		DEFINE SBUTTON FROM 50 ,120 TYPE 2 PIXEL ACTION (nOpcao:= 2, oDlgCont:End()) ENABLE OF oDlgCont

	ACTIVATE MSDIALOG oDlgCont CENTER

	If (nOpcao ==1)
		cAccount := ALLTRIM(cContaMail)
		cPassword:= ALLTRIM(cSenha)
	Else
		lRet:= .F.
	Endif
Endif

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TkSendMail³ Autor ³ Vendas e CRM          ³ Data ³ 26/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para o envio de emails                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkSendMail(cAccount   ,cPassword	,cServer	,cFrom,;
					cEmailDest ,cAssunto	,cMensagem	,cAttach,;
					cEmailTo   ,cEmailCc	,cEmailCco	,lOperAuth)

Local lResult		:= .F.							// Se a conexao com o SMPT esta ok
Local cError		:= ""							// String de erro
Local lRelauth		:= SuperGetMv("MV_RELAUTH")		// Parametro que indica se existe autenticacao no e-mail
Local lRet			:= .F.							// Se tem autorizacao para o envio de e-mail
Local cConta		:= ALLTRIM(cAccount)				// Conta de acesso 
Local cSenha		:= ALLTRIM(cPassword)	        // Senha de acesso
Local nX			:= 0
Local aAttch		:= {}
Local lErrAtt		:= .F.
Local cToken		:= ""

Local oServer  									//Objeto para o TmailManager
Local oMessage									//Objeto para o TmailMessenger
Local nErr			:= 0							//Variavel para controle de erro
Local nSMTPTime		:= GetNewPar("MV_RELTIME",60)	// TIMEOUT PARA A CONEXAO
Local lSSL			:= GetNewPar("MV_RELSSL",.F.)	// VERIFICA O USO DE SSL
Local lTLS			:= GetNewPar("MV_RELTLS",.F.)	// VERIFICA O USO DE TLS
Local nSMTPPort		:= GetNewPar("MV_PORSMTP",25)	// PORTA SMTP
Local nPortAddSrv	:= 0

Default cEmailDest	:= ""
Default cEmailTo	:= ""
Default cEmailCc	:= ""
Default cEmailCco	:= ""						// E-mail de copia oculta
Default lOperAuth	:= .F.						//Será utilizado a conta/senha informadas no cadastro do operador

If Empty(cEmailTo)
	cEmailTo := cEmailDest
Else
	cEmailCc += cEmailDest
EndIf

If lSSL .Or. lTLS

	// Verificar autenticacao e retira o conteudo apos o @
	If !lOperAuth .And. lSSL .And. lRelauth .And. At("@",cConta)>0
		cConta := Subs(cConta,1,At("@",cConta)-1)
	EndIf
	
	// Objeto de Email
	oServer := TMailManager():New()
	
	// Usa SSL, TLS ou nenhum na inicializacao
	oServer:SetUseSSL(lSSL)
	oServer:SetUseTLS(lTLS)

	//Prioriza se a porta está no endereço
	nPortAddSrv := AT( ":", cServer )

	If nPortAddSrv > 0
		nSMTPPort := Val(Substr( cServer, nPortAddSrv + 1, Len( cServer ) ) )
		cServer := Substr( cServer, 0, nPortAddSrv - 1 )
	EndIf

	// Inicializacao do objeto de Email
	nErr := oServer:init("",cServer,cConta,cSenha,,nSMTPPort)
	If nErr <> 0	
		CoNout(STR0039 + oServer:getErrorString(nErr)) // "[Init SMTP] Falha ao inicializar SMTP: " 	
		Return(.F.)
	Else
		CoNout(STR0040 + oServer:getErrorString(nErr)) //"[Init SMTP] Sucesso ao inicializar SMTP "
	Endif
	
	// Define o Timeout SMTP
	nErr := oServer:SetSMTPTimeout(nSMTPTime)
	If nErr <> 0
		CoNout(STR0041 + oServer:getErrorString(nErr)) //"[SetSMTPTimeout] Falha ao definir timeout: "
		Return(.F.)
	Else
		conout( STR0042 + oServer:getErrorString(nErr)) //"[SetSMTPTimeout] Sucesso ao definir Timeout SMTP: "
	EndIf
	
	// Conecta ao servidor
	nErr := oServer:smtpConnect()
	If nErr <> 0	
		CoNout(STR0043 + oServer:getErrorString(nErr)) // "[Connect SMTP] Falha ao conectar: "		
		oServer:SMTPDisconnect()
		Help(" ",1,STR0006,,oServer:getErrorString(nErr),4,5)      //Atencao
		Return(.F.)
	Else
		CoNout(STR0044 + oServer:getErrorString(nErr)) // "[Connect SMTP] Sucesso ao conectar SMTP"
	EndIf
	
	// Realiza autenticacao no servidor
	If lRelauth
		If !lOperAuth
			cFrom := GetNewPar("MV_RELFROM","") 	// E-mail do remetente
		EndIf
		nErr := oServer:smtpAuth(cConta, cSenha)
		If nErr <> 0		
			CoNout(STR0045 + oServer:getErrorString(nErr)) // Falha ao autenticar: 
			oServer:SMTPDisconnect()
			Help(" ",1,STR0017,,oServer:getErrorString(nErr),4,5)  //"Autenticacao"
			MsgStop(STR0019,STR0018) 		 //"Erro de autenticação","Verifique a conta e a senha para envio"
			Return(.F.)
		Else
			CoNout(STR0046 + oServer:getErrorString(nErr)) //"[AUTH] Sucesso ao autenticar: "	
		EndIf
	EndIf	
	
	conout( STR0047 ) //"[MESSAGE] Criando mail message"
	
	// Cria uma nova mensagem (TMailMessage)
	oMessage := TMailMessage():New()
	oMessage:clear()
	
	oMessage:cFrom		:= cFrom
	oMessage:cTo    	:= cEmailTo
	oMessage:cCC		:= cEmailCc
	oMessage:cBCC		:= cEmailCco
	oMessage:cSubject	:= cAssunto
	oMessage:cBody 		:= cMensagem
	
	If !Empty(cAttach)
		If At(";",cAttach) > 0
			cToken := ";"
		ElseIf At(Chr(10),cAttach) > 0
			cToken := Chr(10)
		EndIf
		Conout(STR0057)	//"[Attach] Anexando arquivo(s)"
		aAttch := StrTokArr(cAttach,cToken)
		For nX := 1 To Len(aAttch)
			If At(Chr(10),aAttch[nX]) == 0
				nErr := oMessage:AttachFile(aAttch[nX])
				If nErr < 0				
					lErrAtt := .T.
					Exit
				EndIf
			EndIf
		Next nX
		If lErrAtt
			Conout(STR0048 + oServer:getErrorString(nErr)) //"[Attach] Erro ao anexar arquivo"
    		Return .F.
  		EndIf
	EndIf	
	
	conout( STR0049 ) //"[SEND] Enviando ..."
	nErr := oMessage:Send( oServer )
		  
	If nErr != 0
		conout( STR0050 ) //"[SEND] Falha ao enviar"
		conout( STR0051 + str( nErr, 6 ), oServer:GetErrorString( nErr ) ) //"[SEND][ERROR] "
		Help(" ",1,STR0006,,oServer:GetErrorString( nErr )+ " " + cEmailTo,4,5)	//Atenção
	Else
		conout( STR0052 + oServer:getErrorString(nErr) ) //"[SEND] Sucesso no envio"
		lResult := .T.
	EndIf
	
	conout( STR0053 ) //"[DISCONNECT] Desconectando SMTP "
	nErr := oServer:SmtpDisconnect()
	If nErr != 0
		conout( STR0054 ) //"[DISCONNECT] Falha ao Desconectar SMTP"
		conout( STR0055 + str( nErr, 6 ), oServer:GetErrorString( nErr ) ) //"[DISCONNECT][ERROR] "
	Else
		conout( STR0056 + oServer:getErrorString(nErr) ) //"[DISCONNECT] Sucesso ao desconectar SMTP"
	EndIf
	
Else
	
	CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cSenha RESULT lResult
	
	// Se a conexao com o SMPT esta ok
	If lResult
	
		// Se existe autenticacao para envio valida pela funcao MAILAUTH
		If lRelauth
			lRet := Mailauth(cConta,cSenha)	
		Else
			lRet := .T.	
	    Endif    
	
		If lRet
			SEND MAIL FROM cFrom ;
			TO      	cEmailTo;
			CC  	   	cEmailCc;
			BCC     	cEmailCco;
			SUBJECT 	cAssunto;
			BODY    	cMensagem;
			ATTACHMENT  cAttach  ;
			RESULT lResult
			
			If !lResult
				//Erro no envio do email
				GET MAIL ERROR cError
				Help(" ",1,STR0006,,cError+ " " + cEmailTo,4,5)	//Atenção
			Endif
	
		Else
			GET MAIL ERROR cError
			Help(" ",1,STR0017,,cError,4,5)  //"Autenticacao"
			MsgStop(STR0018,STR0019) 		 //"Erro de autenticação","Verifique a conta e a senha para envio"
		Endif
			
		DISCONNECT SMTP SERVER
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		Help(" ",1,STR0006,,cError,4,5)      //Atencao
	Endif
EndIf

Return(lResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271Acessorio³ Autor ³ Vendas e CRM        ³ Data ³ 04/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra os Acessorios do produto 		   	 	                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkAcessorio()

Local oLbx          										//Listbox
Local cDAcess    := ""                                      //Descricao do Acessorio
Local nPProd     := 0                                       //Produto
Local nPDescri   := 0										//Descricao do produto
Local aAcess     :={}										//Array com os produtos acessorios
Local oOk        := LoaDbitmap( GetResources(), "LBOK" )	//Verde
Local oNo        := LoaDbitmap( GetResources(), "LBNO" )	//Vermelho	
Local aListaAcess:={}										//Array com os produtos acessorios
Local lTMKACE    := ExistBlock("TMKACE")					//P.E. para substituir a funcao
Local cProduto   := ""										//Codigo do Produto
Local oDlgAcess												//Tela do acessorio
Local lEnabled   := .F.										//Habilita o botao de OK somente para TELEVENDAS
Local cAtend     := ""										//Codigo do atendimento TMK
Local cNum	  	 := ""										//Codigo do atendimento TLV
Local cCliente   := ""										//Codigo do cliente
Local cLoja	  	 := ""										//Codigo da Loja
Local cCodCont   := ""										//Codigo do Contato
Local cCodOper   := ""										//Codigo do Operador
Local lRet		 := .F.										//Retorno da funcao

nFolder  := IIF(nFolder == Nil,1,nFolder)
lEnabled := IIF(nFolder == 2,.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mostra mensagem para o usuario quando o campo        ³
//³UD_PRODUTO esta desabilitado, ou seja, nao permite a ³
//³utilizacao do Cadastro de Acessorios.                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nFolder == 1 // TeleMarketing
	If aScan( aHeader, { |x| Alltrim(x[2])=="UD_PRODUTO" } ) == 0
	   MsgStop(STR0020,STR0006)	// "Para utilizar o cadastro de acessórios é necessário que o campo UD_PRODUTO esteja habilitado para uso. Favor entrar em contato com o Administrador do Sistema.","Atenção"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
	   Return
	EndIf
EndIf

If lTMKACE
	cAtend    := M->UC_CODIGO
	cNum	  := M->UA_NUM	
	cCliente  := M->UA_CLIENTE
	cLoja	  := M->UA_LOJA	
	cCodCont  := M->UA_CODCONT
	cCodOper  := M->UA_OPERADO          
				 
	U_TMKACE(nFolder,oGetTlv,cAtend,cNum,cCliente,cLoja,cCodCont,cCodOper)
	Return(lRet)
Endif

If nFolder == 1 // TeleMarketing ou Televendas
	If (TkGetTipoAte()$ "145") // Telemarketing ou Televendas ou Todos
		nPProd 	:= aPosicoes[3][2]
		nPDescri:= aPosicoes[4][2]
		
	ElseIf (TkGetTipoAte() == "2")	// Televendas
		nPProd 	:= aPosicoes[1][2]
		nPDescri:= aPosicoes[2][2]
		
	ElseIf (TkGetTipoAte() == "3") //Telecobranca
		Help(" ",1,"SEM PRODUT" )
		Return(lRet)
	Endif
	
ElseIf nFolder == 2 // Televendas
	nPProd 	:= aPosicoes[1][2]
	nPDescri:= aPosicoes[2][2]
	
ElseIf (nFolder == 3) //Telecobranca
	Help(" ",1,"SEM PRODUT" )
	Return(lRet)
Endif

cProduto:=aCols[n][nPProd]

If Empty(cProduto)
	Help(" ",1,"SEM PRODUT" )
	Return(lRet)
Endif

DbSelectarea("SUG")
DbSetorder(2)
If DbSeek(xFilial("SUG") + cProduto)
	DbSelectarea("SU1")
	DbSetorder(1)
	If DbSeek(xFilial("SU1")+SUG->UG_CODACE)
		While ! Eof() .AND. U1_FILIAL == xFilial("SU1") .AND. U1_CODACE == SUG->UG_CODACE
			
			cDAcess := STR0010 //"Produto n„o encontrado" 
			DbSelectarea("SB1")
			DbSetorder(1)
			If DbSeek(xFilial("SB1")+SU1->U1_ACESSOR)
				cDAcess := B1_DESC
			Endif
			
			DbSelectarea("SU1")
			cDACess	:=	LEFT(cDAcess,TAMSX3("B1_DESC")[1])
			Aadd(aAcess,{	.F.,;							//Marca - X ou ""
							cDAcess,;						//Descricao do produto acessorio
							U1_LOCAL,;						//Local
							Transform(U1_QTD,"@E 999"),;	//Quantidade 	
							U1_OBS,;						//Observacao
							U1_KIT})						//KIT
							
			Aadd(aListaAcess,{	SU1->U1_ACESSOR,;			//Codigo do Acessorio
								SU1->U1_QTD})				//Quantidade
			SU1->(DbSkip())
		End
	Else
		Help(" ",1,"SEM ACESSO" )
		Return(lRet)
	Endif
Else
	Help(" ",1,"SEM ACESSO" )
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra dados dos Acessorios.    					         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgAcess FROM  48,130 TO 250,740 TITLE STR0011+aCols[n][nPDescri]  PIXEL //"Acess¢rios - "

	@ 3,5  TO  83,300 LABEL STR0012 OF oDlgAcess  PIXEL //"Escolha os itens:" 
	
	@ 10,8 LISTBOX oLbx FIELDS ;
		HEADER ;
			"",;
			STR0013,; //"Produto"
			STR0014,; //"Armazem"
			STR0015,; //"Qtd."
			STR0016,; //"Obs"	
			"Kit" ;
		SIZE 290,70 NOSCROLL OF oDlgAcess PIXEL;
		ON DbLCLICK (aAcess	:=	TkMarca(oLbx:nAt,aAcess),oLbx:Refresh());
	
	oLbx:SetArray(aAcess)
	oLbx:bLine:={|| {if(aAcess[oLbx:nAt,1],oOk,oNo),;		//Marca
						aAcess[oLbx:nAt,2],;				//Descricao do produto acessorio
						aAcess[oLbx:nAt,3],;                //Local
						aAcess[oLbx:nAt,4],;                //Quantidade
						aAcess[oLbx:nAt,5],;                //Observacao
						aAcess[oLbx:nAt,6]}}                //KIT
	
	DEFINE SBUTTON FROM 88,236 TYPE 1 ENABLE OF oDlgAcess ACTION (lRet:= .T.,TkItemAce(aAcess,aListaAcess),oDlgAcess:End() ) When lEnabled
	DEFINE SBUTTON FROM 88,268 TYPE 2 ENABLE OF oDlgAcess ACTION oDlgAcess:End()

ACTIVATE MSDIALOG oDlgAcess CENTER

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TkItemAce ³ Autor ³ Vendas e CRM          ³ Data ³ 13/08/00 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclui os produtos marcados na tela de acessorios          	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpA1 = Lista com os Acessorios ExpA2 - Lista com os c¢digos ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkItemAce( aAcess, aListaAcess )

Local nLinha 	:= 0					// Utilizada como auxiliar no For
Local nColuna 	:= 0 					// Utilizada como auxiliar no For
Local nAtual	:= 0					// Linha atual do aCols
Local nPProd    := aPosicoes[1][2]		// Posicao com o codigo do produto
Local nPQtd     := aPosicoes[4][2]		// Posicao com a quantidade
Local nPItem	:= aPosicoes[20][2]		// Posicao com o item
Local cItem 	:= ""					// Contem o item que eh mostrado no aCols
 
nAtual := Len( aCols )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega o conteudo o ultimo item (Valor)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cItem := aCols[nAtual][nPItem]

For nLinha := 1 to Len( aAcess )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao esta marcado, entao pula³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aAcess[nLinha][1]
		Loop
	Endif
	
	DbSelectarea( "SB1" )
	DbSetorder( 1 )
	If DbSeek( xFilial( "SB1" ) + aListaAcess[nLinha][1] )
		nAtual ++
    
		AADD(aCols,Array( Len( aHeader ) + 1 ) )              
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³x3_titulo   1³
		//³x3_campo    2³
		//³x3_picture  3³
		//³x3_tamanho  4³
		//³x3_decimal  5³
		//³x3_valid    6³
		//³x3_usado    7³
		//³x3_tipo     8³
		//³x3_arquivo  9³
		//³x3_context 10³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³Inicializa as variaveis da aCols (tratamento para    ³
	    //³campos criados pelo usu rio)							³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        For nColuna := 1 TO Len( aHeader )
        
	       If aHeader[nColuna][8]		== "C"
 	 	      aCols[nAtual][nColuna]	:= SPACE(aHeader[nColuna][4])

 		   ElseIf aHeader[nColuna][8]	== "D" 
		      aCols[nAtual][nColuna]	:= dDataBase

		   ElseIf aHeader[nColuna][8]	== "M"
		      aCols[nAtual][nColuna]	:= ""

		   ElseIf aHeader[nColuna][8]	== "N"
		  	   aCols[nAtual][nColuna]	:= 0

		   Else
		      aCols[nAtual][nColuna]	:= .F.	  
		   Endif
		   
	  	Next nColuna

		aCols[nAtual][Len( aHeader )+1]	:= .F.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza a variavel Item do aCols³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cItem					:= Soma1( cItem )
		aCols[nAtual][nPItem]	:= cItem
        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o aCols com o codigo do acessorio e a quantidade inicial para os calculos fiscais         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M->UB_PRODUTO			:= aListaAcess[nLinha][1]
		aCols[nAtual][nPProd]	:= aListaAcess[nLinha][1]

		M->UB_QUANT				:= aListaAcess[nLinha][2]
		aCols[nAtual][nPQtd]	:= aListaAcess[nLinha][2]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualizar a variavel n, pois as funcoes fiscais usam ela como referencia                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		n := nAtual
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Depois de alimentar o aCols executa as funcoes fiscais para o calculo dos impostos desse novo tem  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TKP000A(M->UB_PRODUTO,	nAtual,	NIL )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza a variavel n novamente, pois a funcao TKP000A³
		//³executa um refresh no getDados.                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		n := nAtual
		
		TKP000B(M->UB_QUANT,	nAtual )
		MaColsToFis(aHeader,	aCols,	nAtual,	"TK273",	.F. )
		Tk273Calcula("UB_PRODUTO",nAtual)                        
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza a variavel n novamente, pois a funcao Tk273Calcula³
		//³executa um refresh no getDados.                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		n := nAtual
		
		MafisRef("IT_PRODUTO",	"TK273",M->UB_PRODUTO )
	Endif
Next nLinha

oGetTlv:oBrowse:Refresh()

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkMarca     ³ Autor ³ Vendas e CRM        ³ Data ³ 09/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Seleciona um ou mais itens de acessorios                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkMarca(nAt,aArray)

aArray[nat,1] := !aArray[nat,1]

Return (aArray)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TMKLEMBRE ºAutor  ³ Vendas e CRM       º Data ³  01/22/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao utilizada para alerta de tarefas na agenda do opera- º±±
±±º          ³dor. Sua configuracao eh feita pelo Schedule do Ap8         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMKLEMBRE(aParam)
Local aArea			:= ""							//Salva Area para execucao da rotina
Local cCurrentUser 	:= STR0037			  			//Nome do usuario corrente do protheus // "Administrador"
Local cUserList		:= ""							//Usuario(s) que iram receber o aviso. Neste caso so um por lista de contatos.//Usuarios do protheus separados por ponto-e-virgula (;)
Local cSubject  	:= ""
Local cText 		:= ""
Local cPriority 	:= "0"  //( 0-Alta ; 1-Normal ; 2-Baixa )  // Se omitido, o padrao e o "1" 
Local cTipos		:= ""							//Tipos de Listas

Private nModulo    := 99    					//O listner nao conta como novo usuario
Private lRefresh   := .T.   					//Atualizacao de Tela 
Private lMSHelpAuto:= NIL   					//Atualizacao de Tela 
Private __cInterNet:= NIL   					//Indica se esta sendo utilizado pelo browser
Private cUsuario   := ""    					//Codigo + Nome do Usuario 
Private nModAnt    := 0     					//Modulo anterior (13) ou (97)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define o ambiente de trabalho			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RPCSETTYPE(3)
PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] TABLES "SU4","SU7"

aArea := GetArea()					//Salva Area para execucao da rotina.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa pendencias na base.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU4")
DbSetOrder(3)
If DbSeek(xFilial("SU4")+DTOS(Date())+"1")

	While  	!Eof() .AND.;
			SU4->U4_FILIAL==xFilial("SU4") .AND.;
			SU4->U4_DATA==Date()	 		.AND.;
			SU4->U4_STATUS=='1' 			

        	 If (SU4->U4_HORA1 <= Time()) .AND. (SU4->U4_NIVEL <> "1") //LEU
					
					DbSelectArea("SU7")
					DbSetOrder(1)
					
					If !Empty(SU4->U4_OPERAD)
						If DbSeek(xFilial("SU7") + SU4->U4_OPERAD)
							cUserList := SU7->U7_NREDUZ
						EndIf
					Else
					    DbSeek(xFilial("SU7"))
					    If SU4->U4_TIPO == '1'
					    	cTipos := "1;4;5"
					    ElseIf SU4->U4_TIPO == '2'
   					    	cTipos := "3;4"
					    ElseIf SU4->U4_TIPO == '3'
   					    	cTipos := "2;5"					    
					    EndIf
					    
					    While (!Eof())
					    	If SU7->U7_TIPOATE $ cTipos  
						    	cUserList += SU7->U7_NREDUZ+";"
						    Endif	
					    	DbSkip()
					    End
					
					EndIf
					
					cSubject:= STR0038	// "PENDENCIAS DA AGENDA DO OPERADOR."
					cText 	:= SU4->U4_DESC

					//Grava WF 
					WFMessenger( cCurrentUser, Alltrim(cUserList), cSubject, cText, cPriority )

		    		//Identifica que a tarefa ja foi lida
    	    		DbSelectArea("SU4")
    	    		RecLock("SU4", .F.)
        	 		REPLACE U4_NIVEL WITH "1"
         			MsUnlock()
        	 EndIf
	   DbSkip()
	End
EndIf

RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK271CopiaºAutor  ³ Vendas e CRM       º Data ³  26/01/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Interface para a rotina de Copia de atendimento             º±±
±±º          ³Regras:                                                     º±±
±±º          ³1) Somente as tabelas SUA,SUB e SL4 serao copiadas.         º±±
±±º          ³independente do status atual do atendimento selecionado comoº±±
±±º          ³origem.                                                     º±±
±±º          ³                                                            º±±
±±º          ³2) Campos que nao podem ser copiados de forma alguma:       º±±
±±º          ³- Numero do Pedido                                          º±±
±±º          ³- Numero do Orcamento (quando houver integracao com Loja)   º±±
±±º          ³- Numero da NF                                              º±±
±±º          ³- Serie da NF                                               º±±
±±º          ³- Emissao da NF                                             º±±
±±º          ³- Observacao do Atendimento (porque o codigo iria repetir)  º±±
±±º          ³- Observacao do Cancelamento(porque o codigo iria repetir)  º±±
±±º          ³- Codigo e Nome do Contato (porque pode nao ser o contato ) º±±
±±º          ³							 do cliente de destino)			  º±±
±±º          ³- Transportadora											  º±±
±±º          ³- Condicao de Pagamento (para obrigar a atualizacao dos     º±±
±±º          ³                        dados complementares.)              º±±
±±º          ³- Data e Hora de Retorno                                    º±±
±±º          ³                                                            º±±
±±º          ³3) Essa opcao esta disponivel somente para TELEVENDAS.      º±±
±±º          ³                                                            º±±
±±º          ³4) O atendimento sera gerado sempre como Operacao Orcamento.º±±
±±º          ³E sera obrigatorio o preenchimento dos dados complementares.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CALL CENTER                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk271Copia(cAlias,nReg,nOpc)

Local aArea		:= GetArea()					// Salva a area atual
Local lRet		:= .F.							// Retorno da funcao
Local oWizard									// Objeto do assistente (Wizard)
Local oData										// Objeto com a data
Local dData		:= CTOD("//")					// Data do novo atendimento
Local oDataEntrega								// Objeto com a data da entrega
Local dDataEntrega := CTOD("//")				// Data da entrega
Local oCodCli									// Objeto com o Codigo do novo cliente/Prospect
Local cCodCli	:= CRIAVAR("A1_COD",.F.)		// Variavel com o Codigo do novo cliente/Prospect
Local oCodLoja									// Objeto com o Codigo da Loja do novo cliente/Prospect
Local cCodLoja	:= CRIAVAR("A1_LOJA",.F.)		// Variavel com o Codigo da Loja do  novo cliente/Prospect
Local oMeter									// Objeto com a barra de progressao
Local nMeter	:= 0							// Contador com a barra de progressao
Local cSayRodape:= ""							// Conteudo do texto do rodape do Wizard
Local oSDat                                 	// Objeto data do Wizard
Local cSDat		:= ""							// Variavel data do Wizard
Local oSDatEntrega                          	// Objeto data do Wizard
Local cSDatEntrega := ""						// Variavel data do Wizard
Local oMantemDataEntrega						// Objeto Variavel com a opcao de manter ou nao manter a data da entrega do Atendimento de origem 
Local lMantemDataEntrega := .T.					// Mantem a data da entrega do Atendimento de origem
Local oOperad									// Objeto para get do novo operador
Local cOperad	:= CRIAVAR("UA_OPERADO",.F.)	// Descricao do nome do novo operador 
Local oSayOper									// Objeto com say do operador para o Wizard
Local cSayOper	:= ""							// Descricao do operador para o Wizard
Local cDesc		:= CRIAVAR("A1_NOME",.F.)		// Variavel com o Nome da empresa (Cliente ou Prospect)
Local cNovaEmp	:= CRIAVAR("A1_NOME",.F.)		// Variavel com o Nome da empresa (Cliente ou Prospect)
Local oNovaEmp									// Objeto Variavel com o Nome da empresa (Cliente ou Prospect)
Local lVldCli	:= .F.							// Valida cliente digitado na copia
Local aCmpCpy   := {}							// Recebe conteudo do ponto de entrada TMKXCPAT
Local lTMKXCPAT := ExistBlock("TMKXCPAT")       // Verifica se o ponto de entrada TMKXCPAT esta em uso.
Local lEditCmps := .T. 							// Possibilita editar os campos da wizard - Utilizada pelo ponto TMKXCPAT
Local aPDFields := {"A1_NOME","U7_NOME"}

FATPDLoad(Nil, Nil, aPDFields)

If Type("nFolder") = "U"
	Private nFolder := 2						// Variavel com o folder de Televendas para compatibilizacao com a funcao TMKPO
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da variavel lProspect pois a funcao for executada fora da tela de atendimento.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("lProspect") == "U"
	Private lProspect:= .F.
Endif 

If cAlias <> "SUA"
	Return(lRet)
Endif	

DbSelectarea(cAlias)
DbSetorder(1)
DbGoto(nReg)
If Eof()
	Help( " ", 1, "ARQVAZIO" )
	Return(lRet)
Endif
cOperad := SUA->UA_OPERADO 										// Sugere o operador do atendimento posicionado
cSayOper:= Posicione("SU7",1,xFilial("SU7")+SUA->UA_OPERADO,"U7_NOME")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for prospect, carrega os dados do SUS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SUA->UA_PROSPEC
	cDesc := Posicione("SUS",1,xFilial("SUS")+SUA->UA_CLIENTE+SUA->UA_LOJA,"US_NOME")
Else
	cDesc := Posicione("SA1",1,xFilial("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA,"A1_NOME")
Endif

If lTMKXCPAT
	aCmpCpy := ExecBlock("TMKXCPAT",.F.,.F.,{dData,cCodCli,cCodLoja,cOperad,dDataEntrega,lMantemDataEntrega,lEditCmps})
	If ValType(aCmpCpy) == "A"
		dData := IIF(ValType(aCmpCpy[1])=="D",aCmpCpy[1],dData)
		cCodCli := IIF(ValType(aCmpCpy[2])=="C",aCmpCpy[2],cCodCli)
		cCodLoja := IIF(ValType(aCmpCpy[3])=="C",aCmpCpy[3],cCodLoja)
		cOperad := IIF(ValType(aCmpCpy[4])=="C",aCmpCpy[4],cOperad)
		dDataEntrega := IIF(ValType(aCmpCpy[5])=="D",aCmpCpy[5],dDataEntrega)
		lMantemDataEntrega := IIF(ValType(aCmpCpy[6])=="L",aCmpCpy[6],lMantemDataEntrega)
		If Len(aCmpCpy) > 6 //Quantidade antiga de elementos no array do ponto de entrada
			lEditCmps := IIF(ValType(aCmpCpy[7])=="L",aCmpCpy[7],lEditCmps)
		EndIf
		// Execução necessária para possibilitar continuação do wizard.
		Tk271VldOper(@cSayOper,@cOperad,@oSayOper)
		lVldCli := TkxVldCli( cCodCli, @cCodLoja )
		cNovaEmp := TK271VldEmp(cCodCli,cCodLoja)
		cSDat := Tk_DiaSemana( dData,,0)
		cSDatEntrega := Tk_DiaSemana( dDataEntrega,,0)
	EndIf
EndIf

DEFINE WIZARD oWizard TITLE STR0021 HEADER STR0022 MESSAGE STR0023 TEXT " " ; // "Cópia de Atendimento" "CÓPIA DE ATENDIMENTO PARA TELEVENDAS" "Informe os novos dados para o novo Atendimento."
	NEXT {||IIF(!Empty(dData) .AND. !EMPTY(cDesc) .AND.;
			Tk271CpyVal(dData		, cCodCli  			, cCodLoja		, cOperad,;
						dDataEntrega, lMantemDataEntrega);
			.AND. !EMPTY(cSayOper) .AND. lVldCli,.T.,.F.) } FINISH {||.F.} PANEL NOFIRSTPANEL 
	
	//ÚÄÄÄÄÄÄÄ¿
	//³Panel 1³
	//ÀÄÄÄÄÄÄÄÙ
	oWizard:GETPANEL(1) 

	@ 05,20 SAY STR0024	OF oWizard:GETPANEL(1) PIXEL SIZE 150,9 // "Atendimento selecionado :"
	@ 05,90 SAY SUA->UA_NUM + "-" + FATPDObfuscate(cDesc,"A1_NOME") + IIF(SUA->UA_PROSPECT,STR0025,STR0026) OF oWizard:GETPANEL(1) COLOR CLR_RED PIXEL SIZE 200,9 // "(Prospect)" "(Cliente)"
	
	@ 11,20 SAY STR0027  OF oWizard:GETPANEL(1) PIXEL SIZE 150,9 // "Data do novo Atendimento:"
	@ 21,20 MSGET oData VAR dData SIZE 40,10 OF oWizard:GETPANEL(1) VALID(!EMPTY(dData),cSDat := Tk_DiaSemana( dData,,0) ,oSDat:Refresh()) PIXEL When lEditCmps 
	@ 23,65 SAY oSDat Var cSDat OF oWizard:GETPANEL(1) COLOR CLR_RED PIXEL SIZE 210,9 	// Dia da Semana

	@ 41,20 SAY STR0028 OF oWizard:GETPANEL(1) PIXEL SIZE 150,9 // "Cliente/Prospect para o novo atendimento:"
	@ 51,20 MSGET oCodCli  VAR cCodCli  SIZE 40,10 Picture "@!" F3 "CLT" OF oWizard:GETPANEL(1) VALID ( lVldCli := TkxVldCli( cCodCli, @cCodLoja ), oCodLoja:Refresh() ,cNovaEmp := TK271VldEmp(cCodCli,cCodLoja),oNovaEmp:Refresh() ) PIXEL When lEditCmps 
	@ 51,70 MSGET oCodLoja VAR cCodLoja SIZE 10,10 Picture "!!!!" OF oWizard:GETPANEL(1) VALID ( !EMPTY( cCodLoja ) ) PIXEL When .F.
	@ 53,100 SAY oNovaEmp Var FATPDObfuscate(cNovaEmp,"A1_NOME") OF oWizard:GETPANEL(1) COLOR CLR_RED PIXEL SIZE 210,9 	// Nome do Cliente/Prospect
	
	@ 71,20 SAY STR0029 OF OWizard:GETPANEL(1) PIXEL SIZE 210,9 // "Selecione o Operador para o novo Atendimento:"
	@ 81,20 MSGET oOperad VAR cOperad SIZE 10,10 F3 "SU7" OF OWizard:GETPANEL(1) VALID Tk271VldOper(@cSayOper,@cOperad,@oSayOper) PIXEL When lEditCmps    
	@ 83,60 SAY oSayOper Var FATPDObfuscate(cSayOper,"U7_NOME") OF oWizard:GETPANEL(1) COLOR CLR_RED PIXEL SIZE 210,9 	// Nome do Operador
	
	@ 101,20 SAY STR0030  OF oWizard:GETPANEL(1) PIXEL SIZE 160,9 // "Data da entrega para todos os itens do novo Atendimento:"
	@ 111,20 MSGET oDataEntrega VAR dDataEntrega SIZE 40,10 OF oWizard:GETPANEL(1) WHEN ( IIF(lMantemDataEntrega,oDataEntrega:Disable(),oDataEntrega:Enable()) ) VALID(!EMPTY(dDataEntrega),cSDatEntrega := Tk_DiaSemana( dDataEntrega,,0) ,oSDatEntrega:Refresh())PIXEL
	@ 113,65 SAY oSDatEntrega Var cSDatEntrega OF oWizard:GETPANEL(1) COLOR CLR_RED PIXEL SIZE 210,9 	// Dia da Semana
	@ 126,20 CHECKBOX oMantemDataEntrega VAR lMantemDataEntrega SIZE 160,8 PIXEL OF oWizard:GETPANEL(1) When lEditCmps ON CHANGE ( IIF(lMantemDataEntrega,oDataEntrega:Disable(),oDataEntrega:Enable()) ) PROMPT STR0031 When lEditCmps // "Manter data da entrega do Atendimento de origem"
	

	//ÚÄÄÄÄÄÄÄ¿
	//³Panel 2³
	//ÀÄÄÄÄÄÄÄÙ

	CREATE PANEL oWizard  HEADER STR0032 MESSAGE STR0033; // "Confirmação" "Os dados informados foram: "
		 BACK {||.T.};
		 NEXT {||.F.};
		 FINISH {||Tk271GrvCpy(	oMeter	,cAlias	,nReg		,dData,;
		 						cOperad	,cCodCli,cCodLoja	,dDataEntrega,;
		 						lMantemDataEntrega)} PANEL 
		 oWizard:GETPANEL(2)

	@ 10,10 TO 70,190 LABEL "" OF oWizard:GETPANEL(2)  PIXEL
	@ 20,20 SAY STR0034 + "  " + DTOC(dData) + "-" + cSDat OF oWizard:GETPANEL(2) PIXEL SIZE 150,9 // "Data do Atendimento: "
	@ 45,20 SAY STR0035 + cCodCli+"/"+cCodLoja OF oWizard:GETPANEL(2) PIXEL SIZE 250,9 // "Codigo do Cliente/Prospect: "
	
	cSayRodape := STR0036 // "Aguarde enquanto o novo Atendimento é gerado... "

	@ 80,10 SAY oSay Var cSayRodape OF oWizard:GETPANEL(2) PIXEL SIZE 250,9 
	
 	/*
 	 O "METER" Sera feito com o CONSTRUCTOR da CLASSE porque o TMKDEF.CH tem um DEFINE TOTAL que 
 	 conflita com a PROPRIEDADE TOTAL do objeto METER
 		
 	 [ <oMeter> := ] TMeter():New( 	<nRow>, <nCol>, bSETGET(<nActual>),;
								    <nTotal>, <oWnd>, <nWidth>, <nHeight>, <.update.>, ;
								    <.lPixel.>, <oFont>, <cPrompt>, <.lNoPercentage.>,;
								    <nClrPane>, <nClrText>, <nClrBar>, <nClrBText>, <.lDesign.> )
	*/
		
	oMeter	:= TMeter():New(90	,10 , bSETGET(nMeter),;
							100	,oWizard:GETPANEL(2),10,140,.T.,;
							.T.)
	oMeter:Hide()
	oSay:Hide()

	FATPDLogUser("TK271COPIA")

ACTIVATE WIZARD oWizard CENTERED  WHEN {||.T.}

FATPDUnload()
RestArea(aArea)
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK271GrvCpyºAutor  ³ Vendas e CRM       º Data ³  26/01/04  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que executa a copia dos Atendimentos de Televendas   º±±
±±º          ³Serao copiadas as tabelas:                                  º±±
±±º          ³1) SUA - Cabecalho do Televendas                            º±±
±±º          ³2) SUB - Itens do Televendas - se estiver preenchido        º±±
±±º          ³3) SL4 - Forma de Pagamento - se estiver preenchido         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CALL CENTER                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk271GrvCpy(oMeter	,cAlias	,nReg		,dData,;
							cOperad	,cCodCli,cCodLoja	,dDataEntrega,;
							lMantemDataEntrega)

Local cNumAte    := CRIAVAR("UA_NUM",.F.)	// Codigo atendimento selecionado
Local cOper		 := ""						// Operacao do atendimento 1- Faturamento, 2- Orcamento, 3- Atendimento
Local cNovoAte   := ""						// Codigo do NOVO atendimento 
Local nCampo     := 0						// Variavel para detectar o conteudo dos campos que serao gravados atraves do FieldPut
Local nRegistros := 0						// Contole de registros gravados
Local aOriSUA    := Array(1,FCount())		// Array com campos para copia do SUA
Local aOriSUB    := Array(1,FCount())		// Array com campos para copia do SUB
Local aOriSL4    := Array(1,FCount())		// Array com campos para copia do SL4
Local lRet		 := .F.						// Retorno da funcao
Local nTotal	 := 0            			// Contador para a barra de progressao
Local nTotAux	 := 0						// Contador auxiliar para o FOR
Local cCampos	 := ""						// Campos que nao podem ser gravados
Local nPosCF	 := 0						// Posicao no array do CFOP
Local cTes		 := ""						// Define a TES que foi utilizada para verificar o CFOP
Local lTK271FCPY := ExistBlock("TK271FCPY")	//P.E. acionado ao fim de cada copia de atendimento
Local lTK271NCPY := ExistBlock("TK271NCPY")	//P.E. utilizado para informar um array de campos que não serão considerados na copia do atendimento
Local i			 := 0

cCampos:= "UA_NUMSL1/UA_NUMSC5/UA_EMISNF/UA_SERIE/UA_CODOBS/UA_DOC/UA_CANC/UA_CODCANC/UA_CODCONT/UA_DESCNT/UA_TRANSP/UA_CONDPG/UA_PROXLIG/UA_HRPEND/UB_NUMPV"

If lTK271NCPY
	aRetCpos :=	ExecBlock("TK271NCPY",.F.,.F.)
	If ValType(aRetCpos) == "A"
		For i := 1 To Len(aRetCpos)
			cCampos += "/" + aRetCpos[i]
		Next i
	EndIf
EndIf

DbSelectArea( cAlias )
DbSetOrder( 1 )
DbGoto( nReg )
If nReg == Recno()
	// Pega o codigo do atendimento
	cNumAte := SUA->UA_NUM
	cOper	:= SUA->UA_OPER

	// Verifica o total de itens do atendimento
	nTotal	:= Tk271TotCpy( cNumAte )
	oMeter:SetTotal( nTotal )
	nTotal 	:= 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Le os campos do registro origem no SUA - Cabecalho do Televendas  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotAux := FCount()
	For nCampo := 1 To nTotAux
		aOriSUA[1,nCampo] := FieldGet( nCampo )
	Next nCampo
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando o atendimento estiver com a operacao = 3 (Atendimento), nao  ³
	//³e obrigatorio a existencia dos itens na tabela SUB.                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cOper == "3"	
		lRet := .T.
	Else
		lRet := .F.
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Le os campos do registro origem no SUB - Itens do Televendas      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectarea( "SUB" )
	DbSetorder( 1 )
	If DbSeek( xFilial( "SUB" ) + cNumAte )
		aOriSUB := {}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Le o conteudo do SUB    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !Eof() 							.AND.;
			(xFilial("SUB") == SUB->UB_FILIAL)	.AND.;
			(cNumAte == SUB->UB_NUM)
			
			AAdd( aOriSUB,Array( FCount() ) )
			nTotAux := FCount()

			For nCampo := 1 To nTotAux
				aOriSUB[Len( aOriSUB ),nCampo]	:= FieldGet( nCampo )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Guarda a TES do item na variavel cTes, para verificar o CFOP posteriormente³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Alltrim( FieldName( nCampo ) ) == "UB_TES"
					cTes	:= FieldGet( nCampo )
				ElseIf Alltrim( FieldName( nCampo ) ) == "UB_CF"
					nPosCF	:= nCampo
				Endif
			Next nCampo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Chama funcao TK273CFO para pegar o CFOP correto³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aOriSUB[Len( aOriSUB ), nPosCF ]:= TK273Cfo( cCodCli, cCodLoja, cTes )
			SUB->( DbSkip() )
		End

		lRet:= .T.
	Else
		aOriSUB := {}
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Le os campos do registro origem no SL4 - Forma de Pagamento       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectarea( "SL4" )
	DbSetorder( 1 )
	If DbSeek( xFilial( "SL4" ) + cNumAte + "SIGATMK " )
		aOriSL4 := {}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Le o conteudo do SL4    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !Eof() 						   .AND. ;
			(SL4->L4_FILIAL == xFilial("SL4")).AND. ;
			(SL4->L4_NUM == cNumAte)		   .AND. ;
			(Alltrim( SL4->L4_ORIGEM ) == "SIGATMK" )
			
			AAdd( aOriSL4,Array( FCount() ) )
			
			nTotAux := FCount()
			For nCampo := 1 To nTotAux
				aOriSL4[Len(aOriSL4),nCampo]:= FieldGet( nCampo )
			Next nCampo
			
			SL4->( DbSkip() )
		End
	Else
		aOriSL4 := {}
	Endif
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Comeca a gravar o novo Atendimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	
	BEGIN TRANSACTION
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava o cabecalho³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("SUA",.T.)
		nTotAux := FCount()
		For nCampo := 1 To nTotAux
			Do Case
				Case ( Field( nCampo ) == "UA_NUM" )
					cNovoAte := TkNumero("SUA","UA_NUM")
					FieldPut( nCampo, cNovoAte )
					ConfirmSx8()

				Case ( Field( nCampo ) $ "UA_CLIENTE|UA_CLIENT" )
					FieldPut( nCampo, cCodCli )
					
				Case ( Field( nCampo ) $ "UA_LOJA|UA_LOJAENT" )
					FieldPut( nCampo, cCodLoja )

				Case ( Field( nCampo ) == "UA_EMISSAO" )
					FieldPut( nCampo, dData )
					
				Case ( Field( nCampo ) == "UA_OPERADO" )
					FieldPut( nCampo, cOperad )
					
				Case ( Field( nCampo ) == "UA_OPER" )
					FieldPut( nCampo, IIF(cOper == "3",cOper,"2") )

				Case ( Field( nCampo ) == "UA_STATUS" )
					FieldPut( nCampo, "ORC" )

				Case ( Field( nCampo ) == "UA_PROSPEC" )
					FieldPut( nCampo, lProspect )

				Case ( Field( nCampo ) == "UA_INICIO" )
					FieldPut( nCampo, Time() )

				Case ( Field( nCampo ) == "UA_FIM" )
					FieldPut( nCampo, Time() )

				Case ( Field( nCampo ) == "UA_DTLIM" )	
					FieldPut( nCampo, dData + TkPosto(cOperad,"U0_VALIDAD") )
				
				Case ( Field( nCampo ) == "UA_TRANSP" )
					FieldPut( nCampo, Posicione("SA1",1,xFilial("SA1")+cCodCli+cCodLoja,"A1_TRANSP") )

				Case ( Field( nCampo ) == "UA_ENDCOB" )
					FieldPut( nCampo, Posicione("SA1",1,xFilial("SA1")+cCodCli+cCodLoja,"A1_ENDCOB") )

				Case ( Field( nCampo ) == "UA_BAIRROC" )
					FieldPut( nCampo, Posicione("SA1",1,xFilial("SA1")+cCodCli+cCodLoja,"A1_BAIRROC") )
					
				Case ( Field( nCampo ) == "UA_MUNC" )
					FieldPut( nCampo, Posicione("SA1",1,xFilial("SA1")+cCodCli+cCodLoja,"A1_MUNC") )
				
				Case ( Field( nCampo ) == "UA_CEPC" )
					FieldPut( nCampo, Posicione("SA1",1,xFilial("SA1")+cCodCli+cCodLoja,"A1_CEPC") )
				
				Case ( Field( nCampo ) == "UA_ESTC" )
					FieldPut( nCampo, Posicione("SA1",1,xFilial("SA1")+cCodCli+cCodLoja,"A1_ESTC") )
					
				Case ( Field( nCampo ) == "UA_ENDENT" )
					FieldPut( nCampo, Posicione("SA1",1,xFilial("SA1")+cCodCli+cCodLoja,"A1_ENDENT") )
				
				Case ( Field( nCampo ) == "UA_BAIRROE" )
					FieldPut( nCampo, Posicione("SA1",1,xFilial("SA1")+cCodCli+cCodLoja,"A1_BAIRROE") )  
				
				Case ( Field( nCampo ) == "UA_MUNE" )
					FieldPut( nCampo, Posicione("SA1",1,xFilial("SA1")+cCodCli+cCodLoja,"A1_MUNE") )
				
				Case ( Field( nCampo ) == "UA_CEPE" )
					FieldPut( nCampo, Posicione("SA1",1,xFilial("SA1")+cCodCli+cCodLoja,"A1_CEPE") )
				
				Case ( Field( nCampo ) == "UA_ESTE" )
					FieldPut( nCampo, Posicione("SA1",1,xFilial("SA1")+cCodCli+cCodLoja,"A1_ESTE") )
				
				OtherWise

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza apenas os campos que nao estiverem na lista dos bloqueados³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Field(nCampo) $ cCampos							
						FieldPut( nCampo, aOriSUA[1,nCampo] )
					Endif
			EndCase
		Next nCampo
		
		MsUnLock()
		DbCommit()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava o conteudo do SUB ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len( aOriSUB ) > 0 //Se existirem registros no SUB do atendimento de origem
			nTotAux := Len( aOriSUB )
			For nRegistros := 1 To nTotAux
				
				RecLock("SUB",.T.)
				For nCampo := 1 To FCount()
					If ( Field( nCampo ) == "UB_NUM" )
						FieldPut( nCampo, cNovoAte )
					ElseIf ( !lMantemDataEntrega .AND. Field( nCampo ) == "UB_DTENTRE" )
						FieldPut( nCampo, dDataEntrega )						
					Else
				   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualiza apenas os campos que nao estiverem na lista dos bloqueados³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Field(nCampo) $ cCampos												
							FieldPut( nCampo, aOriSUB[nRegistros,nCampo] )
						Endif
					EndIf
				Next nCampo
				
				MsUnLock()
				DbCommit()
				
				//Atualiza barra de progressao
				oMeter:Set( nTotal + 1 )
				oMeter:Refresh()
			Next nRegistros
	    Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava o conteudo do SL4 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len( aOriSL4 ) > 0 //Se existirem registros no SL4 com as parcelas de pagamento de origem

			nTotAux := Len( aOriSL4 )
			For nRegistros := 1 To nTotAux
				
				RecLock("SL4",.T.)
				For nCampo := 1 To FCount()
					If ( Field( nCampo ) == "L4_NUM" )
						FieldPut( nCampo, cNovoAte )
					Else
						FieldPut( nCampo, aOriSL4[nRegistros,nCampo] )
					Endif
				Next nCampo
				
				MsUnLock()
				DbCommit()
				
				//Atualiza barra de progressao
				oMeter:Set( nTotal + 1 )
				oMeter:Refresh()
			Next nRegistros
		Endif
		
	END TRANSACTION

	If lTK271FCPY
		ExecBlock("TK271FCPY", .F., .F., {cNumAte, cNovoAte})
	EndIf

Endif
	
Return ( lRet )
                                 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271CpyVal  ³  Autor  ³ Vendas e CRM          ³ Data ³25/01/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao da tela de copia de atendimento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso 	 	 ³CALL CENTER                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk271CpyVal(dData		, cCodCli  			, cCodLoja		, cOperad,;
					 		dDataEntrega, lMantemDataEntrega)

Local lRet 			:= .T.							// Retorno da funcao
Local lRetPE		:= Nil							// Retorno do ponto de entrada U_TK271COP
Local aAreaPE		:= {}							// Salva a area antes de executar o ponto de entrada
Local lTK271Copia	:= ExistBlock("TK271COP")		// Ponto de entrada para validar a copia do atendimento

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida data retroativa³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (dData < dDataBase)
	Help(" ",1,"DATA_INVAL")
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa ponto de entrada para validar a copia do atendimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. lTk271Copia
	
	aAreaPE	:= GetArea()
	
	lRetPE := U_TK271COP(	SUA->UA_NUM	, dData			, cCodCli  			, cCodLoja		,;
							cOperad		, dDataEntrega	, lMantemDataEntrega)
	
	If ValType(lRetPE) == "L"
		lRet := lRetPE
	EndIf            
	
	RestArea(aAreaPE)
	
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk271VldOperºAutor³ Vendas e CRM       º Data ³  26/01/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o operador informado, ele devera OBRIGATORIAMENTE:  º±±
±±º          ³ 1) Ser valido 											  º±±
±±º          ³ 2) Ter acesso a rotina de Televendas,Todas ou TMK x TLV    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk271VldOper(cSayOper,cOperad,oSayOper)

Local lRet  := .F.   		// Retorno da funcao
Local aArea := GetArea()	// Salva a area atual

If !Empty(cOperad)
	DbSelectArea("SU7")
	DbSetOrder(1)
	If DbSeek(xFilial("SU7")+cOperad)
		cSayOper := FATPDObfuscate(SU7->U7_NOME,"U7_NOME")
		If ValType(oSayOper) == "O"
			oSayOper:Refresh()
		EndIf
		lRet:= .T.
	Else
		Help(" ",1,"REGNOIS")
	Endif
Endif 

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK271VldEmp ºAutor  ³ Vendas e CRM       º Data ³  26/01/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Devolve o nome da empresa baseado nos parametros           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³ExpC1 - Codigo do Cliente                                   º±±
±±º          ³ExpC2 - Loja do Cliente                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK271VldEmp(cCodCli,cCodLoja)
Local cDesc := CRIAVAR("A1_NOME",.F.)

If !Empty(cCodCli) .AND. !Empty(cCodLoja)
	If lProspect
		cDesc := Posicione("SUS",1,xFilial("SUS")+cCodCli+cCodLoja,"US_NOME")
	Else
		cDesc := Posicione("SA1",1,xFilial("SA1")+cCodCli+cCodLoja,"A1_NOME")
	Endif
Endif

Return(cDesc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK271TotCpyºAutor ³ Vendas e CRM       º Data ³  27/01/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula o total de itens para exibir na barra do obj. oMeterº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CALL CENTER                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/           

Function Tk271TotCpy(cCodAte)

Local nTot  := 0 					// Variavel auxiliar com o Total 
Local aArea := GetArea()			// Salva a area atual

DbSelectArea("SUB")
DbSetOrder(1)
If DbSeek(xFilial("SUB")+cCodAte)
	While !EOF() .AND. SUB->UB_NUM == cCodAte
        nTot ++
		SUB->(DbSkip())
	End
Endif      

RestArea(aArea)
Return(nTot)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TkxVldCli  ºAutor ³ Vendas e CRM       º Data ³  29/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o cliente digitado                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CALL CENTER                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cCodCli : Codigo do Cliente; cCodLoja: Loja do cliente      º±±
±±º          ³lRet: Retorno da validacao do cliente, se encontroou ou nao º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkxVldCli( cCodCli, cCodLoja )
Local lRet := .T.					// Variavel para retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o codigo do cliente estiver em branco, nao irah permitir passar para a proxima tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( cCodCli )
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificado se o cliente é um prospect, pois se selecionado um prospect e caso depois trocado a seleção para³
//³um cliente a variavel lProspect ficava como .T. e nao achava o registro.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If(lRet .And.  !SUS->( DbSeek( xFilial( "SUS" ) + cCodCli + cCodLoja ) ) )
	lProspect := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o cliente nao estiver em branco, efetua a validacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. !lProspect
	SA1->(DbSetOrder( 1 ))
	If !( SA1->( DbSeek( xFilial( "SA1" ) + cCodCli + cCodLoja ) ) )
		If SA1->( DbSeek( xFilial( "SA1" ) + cCodCli ) )
			cCodLoja := SA1->A1_LOJA
		Else
			ExistCpo( "SA1", cCodCli )
			lRet := .F.
		Endif	
	Endif
Endif

If lRet .And. lProspect
	SUS->(DbSetOrder( 1 ))
	If !( SUS->( DbSeek( xFilial( "SUS" ) + cCodCli + cCodLoja ) ) ) 
		If SUS->( DbSeek( xFilial( "SUS" ) + cCodCli ) )
			cCodLoja := SUS->US_LOJA
	    Else
			ExistCpo( "SUS", cCodCli )
			lRet := .F.
		EndIf		
	EndIf	
EndIf    

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TkxAlteraCols  ºAutor ³Vendas Clientes º Data ³  16/01/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Altera os campos virtuais do aCols                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FillGetDados                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cTipo: Tipo (M=Telemarketing;V=Televendas;C=Telecobranca)   º±±
±±º          ³															  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkxAlteraCols( cTipo )
Local nPAssunto := 0	//Posicao do campo no aHeader
Local nPDescAss := 0	//Posicao do campo no aHeader
Local nPProd 	:= 0	//Posicao do campo no aHeader
Local nPDescPro := 0	//Posicao do campo no aHeader
Local nPOcorren	:= 0	//Posicao do campo no aHeader
Local nPDescOco	:= 0	//Posicao do campo no aHeader
Local nPAcao   	:= 0	//Posicao do campo no aHeader
Local nPDescAca	:= 0	//Posicao do campo no aHeader
Local nPCodOpe 	:= 0	//Posicao do campo no aHeader
Local nPDescOpe	:= 0	//Posicao do campo no aHeader
Local nPDescCom := 0	//Posicao do campo no aHeader
Local nUB_DESCRI:= 0  	//Posicao do campo UB_DESCRI 
Local aUser		:= {}	//Array de usuarios

If cTipo == "M" // TeleMarketing
	nPAssunto := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UD_ASSUNTO"} )
	nPDescAss := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UD_DESCASS"} )
	nPProd    := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UD_PRODUTO"} )
	nPDescPro := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UD_DESCPRO"} )
	nPOcorren := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UD_OCORREN"} )
   	nPDescOco := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UD_DESCOCO"} )
	nPCodOpe  := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UD_OPERADO"} )
	nPDescOpe := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UD_DESCOPE"} )
	nPAcao    := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UD_SOLUCAO"} )
	nPDescAca := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UD_DESCSOL"} )
	nPDescCom := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UD_OBSEXEC"} )

ElseIf cTipo == "V" // Televendas
	nPProd 	  := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_PRODUTO"} )
	nPDescPro := Ascan(aHeader, {|x| AllTrim( x[2] ) == "UB_DESCRI"} )
	nUB_DESCRI:= SUB->(FieldPos("UB_DESCRI"))
	
ElseIf cTipo == "C" // Telecobranca
	nPTipo 	 := Ascan(aHeader, {|x| AllTrim( x[2] ) == "ACG_TIPO"} )
	nPDescTp := Ascan(aHeader, {|x| AllTrim( x[2] ) == "ACG_DESCTP"} )
	nPNature := Ascan(aHeader, {|x| AllTrim( x[2] ) == "ACG_NATURE"} )
	nPDescNt := Ascan(aHeader, {|x| AllTrim( x[2] ) == "ACG_DESCNT"} )
	nPOperad := Ascan(aHeader, {|x| AllTrim( x[2] ) == "ACG_OPERAD"} )
	nPDescOp := Ascan(aHeader, {|x| AllTrim( x[2] ) == "ACG_DESCOP"} )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega as descricoes para os campos virtuais.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cTipo == "M") //Telemarketing
	aCols[Len(aCols)][nPDescAss]:= Posicione("SX5",1,xFilial("SX5") + "T1" + aCols[Len(aCols)][nPAssunto],"X5DESCRI()")
	aCols[Len(aCols)][nPDescPro]:= Posicione("SB1",1,xFilial("SB1") + aCols[Len(aCols)][nPProd],"B1_DESC")
	aCols[Len(aCols)][nPDescOco]:= Posicione("SU9",1,xFilial("SU9") + aCols[Len(aCols)][nPAssunto] + aCols[Len(aCols)][nPOcorren],"U9_DESC")
	aCols[Len(aCols)][nPDescAca]:= Posicione("SUQ",1,xFilial("SUQ") + aCols[Len(aCols)][nPAcao],"UQ_DESC")
	aCols[Len(aCols)][nPDescCom]:= MSMM(SUD->UD_CODEXEC,60)
	PswOrder(1)	// Operador
	If PswSeek( aCols[Len(aCols)][nPCodOpe] )
		aUser:= PswRet(1)
		aCols[Len(aCols)][nPDescOpe]:= aUser[1][2]
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega as descricoes para os campos virtuais.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cTipo == "V") //Televendas
	If nUB_DESCRI == 0 
		aCols[Len(aCols)][nPDescPro]:= Posicione("SB1",1,xFilial("SB1") + aCols[Len(aCols)][nPProd],"B1_DESC")
	EndIf	
EndIf

If (cTipo == "C") //Telecobranca
	aCols[Len(aCols)][nPDescTp]:= Posicione("SB1",1,xFilial("SB1") + aCols[Len(aCols)][nPTipo],"B1_DESC")
	aCols[Len(aCols)][nPDescNt]:= Posicione("SED",1,xFilial("SED") + aCols[Len(aCols)][nPNature],"ED_DESCRIC")

	PswOrder(1)	// Operador
	If PswSeek( aCols[Len(aCols)][nPOperad] )
		aUser:= PswRet(1)
		aCols[Len(aCols)][nPDescOp]:= aCols[n][nPDescOp] := aUser[1][2]
	EndIf
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TkaColsVazio   ºAutor ³Vendas Clientes º Data ³  16/01/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera uma linha no aCols (vazia)                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FillGetDados                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cAlias: Alias da tabela que aparecera no aCols			  º±±
±±º          ³															  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkaColsVazio(cAlias)

Local nUsado:= 0	//Posicao do campo no aCols
Local nPos  := 0 	//Utilizado Somente para SUB pois na atualização a ordem e uso dos campos são mantidos e com isso o nUsado não faz sentido.
Local nLinha:= 0 	//Usada como indice em laco For...Next

aCols := Array(1, Len(aHeader) + 1)

For nLinha := 1 TO Len(aHeader)
	nUsado++

	If IsHeadRec(aHeader[nLinha,2]) 
		aCols[1,nUsado]:= 0	            
	ElseIf IsHeadAlias(aHeader[nLinha,2])
		aCols[1,nUsado]:= cAlias		
	ElseIf aHeader[nLinha][8] == "C"	//X3_TIPO
		aCols[1][nUsado] := SPACE(aHeader[nLinha][4]) //X3_TAMANHO

	ElseIf aHeader[nLinha][8] == "M"
		aCols[1][nUsado] := ""

	ElseIf aHeader[nLinha][8] == "L"
		aCols[1][nUsado] := .F.
	Else
		aCols[1][nUsado] := CriaVar(AllTrim(aHeader[nLinha][2]),.T.)  //X3_CAMPO
	Endif

Next nLinha

If cAlias == "SUB"
	nPos:= aScan(aHeader,{|x| Alltrim(x[2]) == "UB_ITEM"})
	If nPos > 0 
		aCols[1][nPos] := "01"
	Endif
Endif

aCols[1][Len(aHeader)+1] := .F.

Return .T.

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
