#INCLUDE "TMKXFUNB.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³TkVisita   ³ Autor ³Vendas Clientes       ³ Data 01/06/04        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Inclui/Altera um apontamento na Agenda do Vendedor               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³CALL CENTER 										   	           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkVisita(	nOpc			,oFolderTmk		,oEnchTmk		,cEncerra,;
					cMotivo			,oFolderTlv		,oEnchTlv		,cCodPagto,;
					cDescPagto		,cCodTransp		,cTransp		,cCob,;
					cEnt			,cCidadeC		,cCepC			,cUfC,;
					cBairroE		,cBairroC		,cCidadeE		,cCepE,;
					cUfE			,nLiquido		,nTxJuros		,nTxDescon,;
					nVlJur			,aParcelas		,nEntrada		,nFinanciado,;
					nNumParcelas	,nValorCC		,oCrono			,cCrono,;
					nTimeSeg		,nTimeMin		,lHabilita		,oFolderTlc,;
					oEnchTlc		,aColsTmk		,aColsTlv		,oDlg,;
					cCodAnt			,aParScript		,l380			,lMsg,;
					aSx3SUA			,cAgenda		,nValnFat		,aSx3SUC,;
					aItens			,oCodPagto		,oDescPagto		,oCodTransp,;
					oTransp			,oCob			,oEnt			,oCidadeC,;
					oUfC			,oBairroE		,oCepC			,oCidadeE,;
					oBairroC		,cCidadeE		,oCepE			,oUfE,;
					oLiquido		,nTxJuros		,oTxJuros		,oTxDescon,;
					oParcelas		,oEntrada		,oFinanciado	,oNumParcelas,;
					lTipo9			,oValNFat		,aSX3ACF		,cCliAnt,;
					lSigaCRD)
		
Local oDlgTarefa									// Tela
Local oVisita						
Local cVendedor := CRIAVAR("A3_COD",.F.) 			// Codigo do Vendedor (Tecnico)
Local cNomeVen  := ""								// Nome do Vendedor (Tecnico)
Local cUsaAgenda:= "" 								// Flag que indica se o Operador tem acesso a essa rotina ou nao
Local cCodCont  := ""               				// Codigo do Contato
Local cChave    := ""								// Codigo da Entidade (Codigo + Loja)
Local cDesc     := ""								// Descricao da Entidade 
Local cCodOper  := ""								// Codigo do Operador			
Local cContato  := ""								// Codigo do Contato
Local lRet 		:= .F.								// Retorno da funcao
Local cTmkAnt	:= ""								// Codigo do Atendimento TMK
Local cTlvAnt	:= ""								// Codigo do Atendimento TLV	
Local cTlcAnt	:= ""								// Codigo do Atendimento TLC
Local oProcesso 
Local cProcesso := CRIAVAR("AC2_PROVEN",.F.)		// Codigo do Processo (AD7)
Local cNomePro 	:= ""								// Descricao do Processo
Local oEstagio 	
Local cEstagio  := CRIAVAR("AC2_STAGE",.F.)			// Codigo do Estagio   (AD7)
Local cNomeEst	:= ""								// Descricao do Estagio	
Local nOpcA		:= 0								// Escolha de OK ou Cancela
Local aArea		:= GetArea()
Local cRetF3	:= ""
Local nOrdem 	:= SX3->(IndexOrd()) 
Local nRecno 	:= SX3->(Recno()) 
Local lProspAD7 := lProspect						// Recebe lProspect para identificar a entidade 
Local aPDFields	:= {"A3_NOME"}

FATPDLoad(Nil, Nil, aPDFields)

DEFAULT cCliAnt := ""                              //Default para a declaracao da variavel

DbSelectarea("SX3")
DbSetorder(2)
If Dbseek("UA_VEND")
	cRetF3 := SX3->X3_F3
Endif
SX3->(Dbsetorder(nOrdem))
SX3->(Dbgoto(nRecno))

If Empty(cRetF3)
	cRetF3 := "SA3"
Endif		

If (nFolder == 1)
	If (TkGetTipoAte()$ "145" ) //Telemarketing - Todos - TMK X TLV
		cCodCont  := M->UC_CODCONT
		cContato  := M->UC_DESCNT
		cChave    := M->UC_CHAVE
		cDesc     := M->UC_DESCCHA
		cCodOper  := M->UC_OPERADO
		cTmkAnt	  := M->UC_CODIGO
		
	ElseIf (TkGetTipoAte() == "2") //Televendas
		cCodCont  := M->UA_CODCONT
		cContato  := M->UA_DESCNT
		cChave    := M->UA_CLIENTE + M->UA_LOJA
		cDesc     := M->UA_DESCCLI
		cCodOper  := M->UA_OPERADO
		cTlvAnt	  := M->UA_NUM

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o cliente porque o atendimento sera gravado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCliAnt := M->UA_CLIENTE + M->UA_LOJA
				
	ElseIf (TkGetTipoAte() == "3") //Telecobranca
		cCodCont  := M->ACF_CODCON
		cContato  := M->ACF_DESCNT
		cChave    := M->ACF_CLIENT + M->ACF_LOJA
		cDesc     := M->ACF_DESC
		cCodOper  := M->ACF_OPERAD
		cTlcAnt	  := M->ACF_CODIGO
	Endif
	
ElseIf (nFolder == 2) //Televendas
	cCodCont  := M->UA_CODCONT
	cContato  := M->UA_DESCNT
	cChave    := M->UA_CLIENTE + M->UA_LOJA
	cDesc     := M->UA_DESCCLI
	cCodOper  := M->UA_OPERADO
	cTlvAnt	  := M->UA_NUM

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o cliente porque o atendimento sera gravado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCliAnt := M->UA_CLIENTE + M->UA_LOJA
	
ElseIf (nFolder == 3) //Telecobranca
	cCodCont  := M->ACF_CODCON
	cContato  := M->ACF_DESCNT
	cChave    := M->ACF_CLIENT + M->ACF_LOJA
	cDesc     := M->ACF_DESC
	cCodOper  := M->ACF_OPERAD
	cTlcAnt	  := M->ACF_CODIGO
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o operador tem direito a acessar a agenda do representante³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cUsaAgenda := TkPosto(cCodOper,"U0_USAAGEN")
If (cUsaAgenda <> "1")  //Sim
	Help(" ",1,"SEMACEAGEN") //"O Operador nao tem acesso a agenda dos representantes"
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³E necessario escolher um contato antes  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cCodCont) .AND. Empty(cContato)
	Help(" ",1,"SEMCONTVIS") //"Escolha um contato para agendar visita"
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se ja foi feita a gravacao dos dados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc == 3 .OR. nOpc == 4 ) //Inclusao ou Alteracao
	If TmkOk(STR0002,STR0003)  //"Deseja gravar o atendimento e transferir as informacoes para a agenda ?","Atencao"
		
		If ! Tk271Grava(@nOpc			,@oFolderTmk	,@nTimeSeg		,@nTimeMin		,;
						@oCrono			,@cCrono		,@oEnchTmk		,@cMotivo		,;
						@cEncerra		,@oFolderTlv	,@oEnchTlv		,@cCodPagto		,;
						@cDescPagto		,@cCodTransp	,@cTransp		,@cCob			,;
						@cEnt			,@cCidadeC		,@cCepC			,@cUfC			,;
						@cBairroE		,@cBairroC		,@cCidadeE		,@cCepE			,;
						@cUfE			,@nLiquido		,@nTxJuros		,@nTxDescon		,;
						@nVlJur			,@aParcelas		,@nEntrada		,@nFinanciado	,;
						@nNumParcelas	,@nValorCC		,@lHabilita		,@oFolderTlc	,;
						@oEnchTlc		,aColsTmk		,aColsTlv		,@oDlg			,;
						@cCodAnt		,aParScript		,l380			,@lMsg			,;
						aSx3SUA			,cAgenda		,nValNFat		,aSx3SUC		,;
						@aItens			,oCodPagto		,@oDescPagto	,@oCodTransp	,;
						@oTransp		,@oCob			,@oEnt			,@oCidadeC		,;
						@oUfC			,@oBairroE		,@oCepC			,@oCidadeE		,;
						@oBairroC		,@cCidadeE		,@oCepE			,@oUfE			,;
						@oLiquido		,@nTxJuros		,@oTxJuros		,@oTxDescon		,;
						@oParcelas		,@oEntrada		,@oFinanciado	,@oNumParcelas	,;
						@lTipo9		    ,@oValNFat		,aSX3ACF		,cCliAnt		,;
						lSigaCRD)
			Return(lRet)
		Endif

		DEFINE MSDIALOG oDlgTarefa FROM 20,25 TO 165,370 TITLE STR0004 PIXEL  //"Agenda de Visita" 

			@ 02,05 TO 55,164 LABEL STR0005 OF oDlgTarefa PIXEL  //"Tarefa"

			@ 10,08 SAY STR0006 SIZE 40,8 OF oDlgTarefa PIXEL  	 //"Vendedor" 
			@ 10,50 MSGET oVisita VAR cVendedor SIZE 40,8 OF oDlgTarefa PIXEL F3 cRetF3 PICTURE "999999" VALID TkAtuGet(cVendedor,@cNomeVen,"V",NIL,NIL)
			
			@ 10,93 SAY FATPDObfuscate(cNomeVen,"A3_NOME") SIZE 65,8 OF oDlgTarefa PIXEL PICTURE "@!" COLOR CLR_BLUE
			
			@ 25,08 SAY STR0051 SIZE 40,8 OF oDlgTarefa PIXEL  	 //"Processo" 
			@ 25,50 MSGET oProcesso VAR cProcesso SIZE 40,8 OF oDlgTarefa PIXEL F3 "AC2" PICTURE "@!" VALID TkAtuGet(cProcesso,@cNomePro,"P",cEstagio,@cNomeEst)
			@ 25,93 SAY cNomePro SIZE 65,8 OF oDlgTarefa PIXEL PICTURE "@!" COLOR CLR_BLUE
						
			@ 40,08 SAY STR0052 SIZE 40,8 OF oDlgTarefa PIXEL  	 //"Estágio"
			@ 40,50 MSGET oEstagio VAR cEstagio SIZE 40,8 OF oDlgTarefa PIXEL PICTURE "@!" VALID TkAtuGet(cProcesso+cEstagio,@cNomeEst,"E",NIL,NIL)
			@ 40,93 SAY cNomeEst SIZE 65,8 OF oDlgTarefa PIXEL PICTURE "@!" COLOR CLR_BLUE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava no AD7 uma tarefa para o vendedor³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DEFINE SBUTTON FROM 60,104 TYPE 1 ACTION ( nOpcA := 1, lRet := .T. ,oDlgTarefa:End() ) ENABLE OF oDlgTarefa
			
			DEFINE SBUTTON FROM 60,136 TYPE 2 ACTION ( nOpcA := 0, oDlgTarefa:End() ) ENABLE OF oDlgTarefa


			FATPDLogUser("TKVISITA")      
		ACTIVATE MSDIALOG oDlgTarefa CENTER
	
		If nOpcA == 1
		
			TkWork(	Alias()	,RecNo()	,nOpc		,cCodCont,;
					cChave	,cDesc		,cTmkAnt	,cTlvAnt,;
					cTlcAnt	,cVendedor	,cNomeVen	,cProcesso,;
					cEstagio,lProspAD7 )
        Endif

	Endif
Endif

FATPDUnLoad()

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³Tk271AtuGet³  Autor³Vendas Clientes       ³ Data 12/07/2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Atualiza o nome do vendedor/tecnico                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Tk271AtuVsta(ExpA1,ExpA2,ExpA2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Sigatmk  											   	      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkAtuGet(cCodigo,cDesc,cTipo,cCodigo2,cDesc2)
Local lRet  := .F.

If cTipo <> "V"  .AND. Empty(cCodigo)
	Return(lRet)
Endif	

Do Case
	Case (cTipo == "V") //Vendedor
		DbSelectArea("SA3")
		DbSetOrder(1)
		If DbSeek(xFilial("SA3") + cCodigo)
			lRet:= .T.
			cDesc := SA3->A3_NOME
		Endif
		
	Case (cTipo == "T") //Tecnico
		DbSelectArea("AA1")
		DbSetOrder(1)
		If DbSeek(xFilial("AA1") + cCodigo)
			lRet:= .T.
			cDesc := AA1->AA1_NOMTEC
		Endif

	Case (cTipo == "P") //Processo
		DbSelectArea("AC1")						// Essa consulta resulta em dois registros Processo + Estagio
		DbSetOrder(1)
		If DbSeek(xFilial("AC1") + cCodigo)
			lRet:= .T.
			cDesc := AC1->AC1_DESCRI
			
			DbSelectArea("AC2")						
			DbSetOrder(1)
			If DbSeek(xFilial("AC2") + cCodigo + cCodigo2)
				cDesc2 := AC2->AC2_DESCRI
			Endif
		Endif
		

	Case (cTipo == "E") //Estagio
		DbSelectArea("AC2")						
		DbSetOrder(1)
		If DbSeek(xFilial("AC2") + cCodigo)
			lRet:= .T.
			cDesc := AC2->AC2_DESCRI
		Endif
		
Endcase

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TkWork    ³ Autor ³Vendas Clientes        ³ Data ³ 13/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Area de Trabalho dos Representantes Comerciais              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Numero do Registro                                 ³±±
±±³          ³ ExpN2 : Opcao Selecionada                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkWork(	cAlias	,nReg		,nOpcx		,cCodCont,;
						cChave	,cDesc		,cTmkAnt	,cTlvAnt,;
						cTlcAnt	,cVendedor	,cNomeVen	,cProcesso,;
						cEstagio,lProspAD7)

Local oDlgWork          // Tela
Local oBrowse			// Agenda 
Local oColuna1			
Local oColuna2
Local oColuna3
Local oColuna4
Local oCalend           // Calendario
Local oPanel	
Local aAgenda  := {}		
Local nForeCor := 0		
Local nBackCor := 0		

DEFINE MSDIALOG oDlgWork TITLE FATPDObfuscate(SA3->A3_NOME,"A3_NOME") FROM 9,0 TO 22,080 OF oMainWnd	// Nome do vendedor
	
	@ 002,002 MSPANEL oPanel PROMPT "" SIZE 172,011 OF oDlgWork CENTERED LOWERED
	oBrowse := TSBrowse():New(012, 002, 172, 080, oDlgWork,,35,,1 )

	nForeCor := CLR_GRAY
	nBackCor := CLR_WHITE

	oColuna1 := TcColumn():New("",,,{|| nForeCor },{|| nBackCor })
	oColuna1:lNoLite := .T.
	oColuna1:nWidth := 40

	oColuna2 := TcColumn():New("",,,{|| nForeCor },{|| nBackCor })
	oColuna2:lNoLite := .T.
	oColuna2:nWidth := 120

	oBrowse:AddColumn(oColuna1)
	oBrowse:AddColumn(oColuna2)
	oBrowse:lJustific := .F.
	oBrowse:SetArray(aAgenda)

	oColuna3:= TcColumn():New("",,,{|| nForeCor },{|| nBackCor })
	oColuna3:lNoLite := .T.
	oColuna3:nWidth := 40

	oColuna4 := TcColumn():New("",,,{|| nForeCor },{|| nBackCor })
	oColuna4:lNoLite := .T.
	oColuna4:nWidth := 120

	oCalend:=MsCalend():New(002,175,oDlgWork)
	oCalend:bChangeMes := {|| TkChgMes(@oCalend) }
	oCalend:bChange    := {|| TkChgDia(@oBrowse,@oCalend,@oPanel) }

	@ 078,180 BUTTON STR0027 SIZE 040,012 ACTION ( TkAgenda(oCalend:dDiaAtu	,cCodCont	,cChave		,cDesc,; 		//"Agenda" 
											 		   		cTmkAnt			,cTlvAnt	,cTlcAnt	,cVendedor,;
											 				cNomeVen 		,cProcesso	,cEstagio	,lProspAD7),;
													Eval(oCalend:bChangeMes),Eval(oCalend:bChange)) OF oDlgWork PIXEL    

	DEFINE SBUTTON FROM 078,226  TYPE 1  ACTION oDlgWork:End() ENABLE OF oDlgWork

ACTIVATE DIALOG oDlgWork ON INIT (TkChgMes(@oCalend),TkChgDia(@oBrowse,@oCalend,@oPanel)) CENTERED

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tk271ChgDi³ Autor ³ Vendas Clientes       ³ Data ³ 13/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza o browse quando o dia eh alterado.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1: Objeto do Browse                                    ³±±
±±³          ³ ExpO2: Objeto do Calendario                                ³±±
±±³          ³ ExpO3: Objeto                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkChgDia(oBrowse,oCalend,oPanel)

Local aArea   := GetArea()
Local aAgenda := {}
Local dData   := oCalend:dDiaAtu
Local cString := ""
Local cString1:= ""
Local cString2:= ""
Local nCntFor := 0
Local nLinhas := 0

DbSelectArea("AD7")
DbSetOrder(1)
DbSeek(xFilial("AD7")+SA3->A3_COD+Dtos(dData))
While (!Eof() .AND. xFilial("AD7") 	== AD7->AD7_FILIAL .AND.;
	  SA3->A3_COD	== AD7->AD7_VEND .AND.;
      dData == AD7->AD7_DATA)
      
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona Registros.                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+AD7->AD7_CODCLI)
	
	DbSelectArea("SUS")
	DbSetOrder(1)
	DbSeek(xFilial("SUS")+AD7->AD7_PROSPE+AD7->AD7_LOJPRO)
	
	DbSelectArea("SU5")
	DbSetOrder(1)
	DbSeek(xFilial("SU5")+AD7->AD7_CONTAT)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recupera as informacoes a serem apresentadas na agenda                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem das Colunas.                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cString  := AD7->AD7_HORA1+" - "+AD7->AD7_HORA2
	cString1 := "("+AD7->AD7_TOPICO+")"+CRLF
	cString2 := AllTrim(MsMM(AD7->AD7_CODMEM))
	cString2 := StrTran(cString2,CRLF," ")
	
	For nCntFor := 1 To Len(cString2) Step 45
		cString1 += SubStr(cString2,nCntFor,45)+CRLF
		nLinhas++
	Next nCntfor	                      
	
	cString1 := SubStr(cString1,1,Len(cString1)-2)
	aadd(aAgenda, { cString , cString1 })
	
	DbSelectArea("AD7")
	DbSkip()
End 
                                             //Visualizacao
oPanel:SetText(DiaExtenso(oCalend:dDiaAtu)+" - "+DTOC(oCalend:dDiaAtu))
oBrowse:SetArray(aAgenda)
oBrowse:Refresh()
RestArea(aArea)

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Tk271ChgMe³ Autor ³ Vendas Clientes       ³ Data ³ 13/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza o array com os dias alocados.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1: Objeto do Calendario                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkChgMes(oCalend)

Local aArea    := GetArea()
Local dDataIni := FirstDay(oCalend:dDiaAtu)
Local dDataFim := LastDay(oCalend:dDiaAtu)
Local dData	   := CTOD("  /  /  ")
Local dRestri  := CTOD("  /  /  ")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analiza os dias alocados para troca de cor      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dData := dDataIni

While ( dData<=dDataFim )
	dRestri  := dData
	dData	 := DataValida(dData,.T.)
	If ( dData <> dRestri )
		oCalend:addRestri(Day(dRestri),CLR_HRED,CLR_WHITE)
	Endif
	dData := dRestri
	dData    ++
End

dData := dDataFim+1
DbSelectArea("AD7")
DbSetOrder(1)
DbSeek(xFilial("AD7")+SA3->A3_COD+Dtos(dDataIni),.T.)
While (!Eof() .AND. xFilial("AD7") == AD7->AD7_FILIAL .AND.;
	  SA3->A3_COD == AD7->AD7_VEND .AND.;
	  dDataIni <= AD7->AD7_DATA .AND.;
	  dDataFim >= AD7->AD7_DATA)
	  
	If (dData <> AD7->AD7_DATA )
		oCalend:addRestri(Day(AD7->AD7_DATA),CLR_BLUE,CLR_BLUE)
	Endif
	dData := AD7->AD7_DATA

	DbSelectArea("AD7")
	DbSkip()

End
oCalend:Refresh()

RestArea(aArea)
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TkAgenda   ³ Autor ³ Vendas Clientes      ³ Data ³13/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Manutencao da Agenda do Representante Tecnico.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD1: Data de Inicio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1: logico                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkAgenda(	dDataAtu	,cCodCont	,cChave		,cDesc,;
							cTmkAnt		,cTlvAnt	,cTlcAnt	,cVendedor,;
							cNomeVen	,cProcesso	,cEstagio	,lProspAD7)

Local aArea     := GetArea()						// Guarda a area atual
Local lGravou	:= .F.								// Indica se gravou reg.
Local nCntFor	:= 0								// Usada em lacos For..Next
Local nCntFor2	:= 0								// Usada em lacos For..Next
Local nUsado	:= 0								// Tamanho do aHeader
Local nOpcA		:= 0								// Opcao selecionada
Local nPMemo    := 0								// Posicao do campo memo no aHeader
Local cHora1    := ""								// Hora inicial 
Local cHora2    := ""								// Hora final
Local cContat   := ""								// Contato
Local cMemo     := ""								// Conteudo do campo Memo
Local aRots   	:= {}								// Copia do aRotina
Local nOpcAnt   := 0								// Opcao anterior
Local oDlg											// Obj. Dialog da Agenda
Local oGetD											// Obj. da GetDados 
Local aSaveCols		:= aClone(aCols) 				// Armazena o aCols anterior para ser restaurado.
Local aSaveHeader	:= aClone(aHeader)				// Armazena o aHeader anterior para ser restaurado.
Local nSave			:= n							// Armazena o valor de n (linha da getdados) anterior para ser restaurado.
Local aUCampos		:= {}							// Array com os campos e respectivos conteudos que retorna do ponto de entrada.
Local nI			:= 0							// Contador do loop
Local lTMKMAD7		:= ExistBlock("TMKMAD7")		// P.E. TMK
Local lTK271CPO		:= ExistBlock("TK271CPO")		// P.E. Para atualizar campos de usuario
Local nSaveSx8 		:= GetSX8Len()                  // Funcao de numeracao
Local cSeek			:= xFilial("AD7")+cVendedor+Dtos(dDataAtu)				//Expressao Seek para posicionar na tabela
Local cWhile		:= "AD7->AD7_FILIAL+AD7->AD7_VEND+DTOS(AD7->AD7_DATA)+AD7->AD7_HORA1"	//Enquanto for igual a cSeek
Local aNoFields 	:= {"AD7_VEND","AD7_NOMVEN"}							//Array com campos para nao exibir
Local bCond			:= {|| IIf(TkValidaCols(), .T., .F.) }					//Condicao para adicionar no aCols
Local oGetVend		:= Nil

PRIVATE aRegistros	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada que devera retornar um array no seguinte formato:                          ³
//³		Posicao 01 - Nome dos campos do alias AD7 que se queira inicializar com algum conteudo.³
//³		Posicao 02 - Conteudo do respectivo campo passado na posicao 01.                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTK271CPO
	aUCampos := ExecBlock( "TK271CPO", .F., .F. )
Endif

aCols	:= {}
aHeader	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega os dados do contato  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU5")
DbSetOrder(1)
If DbSeek(xFilial("SU5") + cCodCont)
	cContat:= SU5->U5_CONTAT  
	cHora1 := SU5->U5_HORAV1  
	cHora2 := SU5->U5_HORAV2  
	cMemo  := TkGeraMemo(cTmkAnt,cTlvAnt,cTlcAnt)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader e aCols usando FillGetDados                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FillGetDados(	4				,"AD7"			,1						,cSeek			,;
  				{|| &cWhile }	,bCond			,aNoFields				,/*aYesFields*/	,; 
				/*lOnlyYes*/	,/*cQuery*/		,/*bMontCols*/			,/*lEmpty*/		,;
				/*aHeaderAux*/	,/*aColsAux*/	,/*bAfterCols*/			,/*bBeforeCols*/	)

nPMemo := GDFieldPos("AD7_MEMO")
nUsado := Len(aHeader)

nLin := Len(aCols)
For nCntFor := 1 To Len(aHeader)
	Do Case
		Case (AllTrim(aHeader[nCntFor][2]) == "AD7_DATA")
			aCols[nLin][nCntFor] := dDataAtu
			
		Case (AllTrim(aHeader[nCntFor][2]) == "AD7_HORA1")
			aCols[nLin][nCntFor] := cHora1
			
		Case (AllTrim(aHeader[nCntFor][2]) == "AD7_HORA2")
			aCols[nLin][nCntFor] := cHora2
			
		Case (AllTrim(aHeader[nCntFor][2]) == "AD7_MEMO")
			aCols[nLin][nCntFor] := cMemo
			
		Case (AllTrim(aHeader[nCntFor][2]) == "AD7_CODCLI")
			aCols[nLin][nCntFor] := IIF(lProspAD7,"",SubStr(cChave,1,TamSX3("A1_COD")[1]))
			
		Case (AllTrim(aHeader[nCntFor][2]) == "AD7_LOJA")
			aCols[nLin][nCntFor] := IIF(lProspAD7,"",SubStr(cChave,TamSX3("A1_COD")[1] + 1,TamSX3("A1_LOJA")[1]))
			
		Case (AllTrim(aHeader[nCntFor][2]) == "AD7_NOMCLI")
			aCols[nLin][nCntFor] := IIF(lProspAD7,"",cDesc)
			
		Case (AllTrim(aHeader[nCntFor][2]) == "AD7_VEND")
			aCols[nLin][nCntFor] := cVendedor
			
		Case (AllTrim(aHeader[nCntFor][2]) == "AD7_NOMVEN")
			aCols[nLin][nCntFor] := cNomeVen
			
		Case (AllTrim(aHeader[nCntFor][2]) == "AD7_CONTAT")
			aCols[nLin][nCntFor] := cCodCont
			
		Case (AllTrim(aHeader[nCntFor][2]) == "AD7_NOMCON")
			aCols[nLin][nCntFor] := cContat
			
		Case (AllTrim(aHeader[nCntFor][2]) == "AD7_PROSPE")
			aCols[nLin][nCntFor] := IIF(lProspAD7,SubStr(cChave,1,TamSX3("US_COD")[1]),"")
			
		Case (AllTrim(aHeader[nCntFor][2]) == "AD7_LOJPRO")
			aCols[nLin][nCntFor] := IIF(lProspAD7,SubStr(cChave,TamSX3("US_COD")[1] + 1,TamSX3("US_LOJA")[1]),"")
			
		Case (AllTrim(aHeader[nCntFor][2]) == "AD7_NOMPRO")
			aCols[nLin][nCntFor] := IIF(lProspAD7,cDesc,"")
			
		Case IsHeadAlias( AllTrim(aHeader[nCntFor][2]) )
			aCols[nLin][nCntFor] := "AD7"

		Case IsHeadRec( AllTrim(aHeader[nCntFor][2]) )
			aCols[nLin][nCntFor] := 0
			
		OtherWise
			aCols[nLin][nCntFor] := CriaVar(aHeader[nCntFor][2])
			
			// Os valores passados pelo P.E. Sobrepoem qualquer outro valor.
			For nI := 1 To Len(aUCampos)
				If (AllTrim(aHeader[nCntFor][2]) == AllTrim(aUCampos[nI][1]))
					aCols[nLin][nCntFor] := aUCampos[nI][2]
					Exit
				EndIf
			Next nI
			
	EndCase
	
Next nCntFor

aCols[nLin][nUsado+1] := .F.

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd

	@ 015,010 SAY RetTitle("A3_NOME") 	SIZE 040,009 OF oDlg PIXEL
	@ 015,050 MSGET oGetVend Var cNomeVen SIZE 136,009 OF oDlg PIXEL WHEN .F.
	
	If FATPDActive() .And. FTPDUse(.T.)
		oGetVend:lObfuscate := FATPDIsObfuscate("A3_NOME")
	EndIf

	If Type("aRotina") =="A"
		aRots  := aClone(aRotina)
	Endif      
	
	aRotina := MenuDef() 
	nOpcAnt := nOpcA 
   	nOpcA   := 1 

	oGetd:=MsGetDados():New(030,005,138,314,nOpcA,"TkLinTarefa","AlwaysTrue","",.T.)

	If aRots<>Nil
		aRotina := aClone(aRots)
		nOpcA   := nOpcAnt 
	Endif
	
	FATPDLogUser("TKAGENDA")   
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(oGetd:TudoOk(),oDlg:End(),nOpcA:=0)},{||oDlg:End()})

If ( nOpcA == 1 )
	BEGIN TRANSACTION
		
		For nCntFor := 1 To Len(aCols)
		
			If ( !aCols[nCntFor][nUsado+1] ) .OR. (Len(Acols) <> nCntFor)
			
				If ( nCntFor > Len(aRegistros) )
					If ( !aCols[nCntFor][nUsado+1] )
						RecLock("AD7",.T.)
					Else
					   Loop 
					Endif
				Else
					AD7->(DbGoto(aRegistros[nCntFor]))
					RecLock("AD7",.F.)			
				Endif
		
				If ( aCols[nCntFor][nUsado+1] .AND. nCntFor <= Len(aRegistros) )
					AD7->(DbDelete())
					If ( !Empty(AD7->AD7_CODCLI) )
						FtUltVis(AD7->AD7_CODCLI,AD7->AD7_LOJA,.T.)
					Endif							
					MSMM(AD7->AD7_CODMEM,,,,2)
				Else
					
					For nCntFor2 := 1 To Len(aHeader)
						If ( aHeader[nCntFor2][10] <> "V" )
							FieldPut(FieldPos(aHeader[nCntFor2][2]),aCols[nCntFor][nCntFor2])
						Endif					
					Next nCntFor2
					
					Replace AD7->AD7_FILIAL With xFilial("AD7")
					Replace AD7->AD7_VEND	With cVendedor
					Replace AD7->AD7_PROVEN	With cProcesso
					Replace AD7->AD7_STAGE	With cEstagio
					Replace AD7->AD7_CODTMK	With cTmkAnt
					Replace AD7->AD7_CODTLV	With cTlvAnt 
					Replace AD7->AD7_ITTELE	With "01"
					If ( !Empty(aCols[nCntFor][nPMemo]) )
						MSMM(AD7->AD7_CODMEM,,,aCols[nCntFor][nPMemo],1,,,"AD7","AD7_CODMEM")
					Endif
				Endif	
				
				MsUnLock()		
			Endif
		Next nCntFor
		
		EvalTrigger()
		
		While (GetSx8Len() > nSaveSx8)
			ConfirmSX8()
		End	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gera a oportunidade ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Ft300GeraOpo( cProcesso, cEstagio ) 
		
	END TRANSACTION
	
Endif

While (GetSx8Len() > nSaveSx8)
	RollBackSx8()
End
MsUnLockAll()         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa o P.E. TMKMAD7³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTMKMAD7
	U_TMKMAD7(nOpcA)
Endif

RestArea(aArea)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura os dados do aCols , aHeader e N  para uso da GetDados do atendimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols	:= {}
aHeader	:= {}

aCols   := aClone(aSaveCols)
aHeader := aClone(aSaveHeader)
n       := nSave

Return(lGravou)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef	³ Autor ³ Vendas Clientes       ³ Data ³14/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef() 

Local aRotina:= { {"","", 0 , 3 , , .T.} }


				

							                                                     				
Return(ARotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK271LinTar ºAutor  ³Vendas Clientes   º Data ³  28/02/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida linha da MsGetDados da agenda do vendedor            º±±
±±º          ³no envio de tarefa                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs.      ³Nao e necessaria uma funcao para verificar a base de dados  º±±
±±º          ³pois todos os registros referentes  ao dia sao carregados   º±±
±±º          ³no aCols                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ATENDIMENTO                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkLinTarefa()
    
Local nLinha := 0  //Contador para verificacao dos dados do aCols
Local nPData := Ascan(aHeader,{|x| Alltrim(x[2]) == "AD7_DATA"})// Posicao do campo data no aCols
Local nPHora1:= Ascan(aHeader,{|x| Alltrim(x[2]) == "AD7_HORA1"})// Posicao do campo Hora1 no aCols
Local nPHora2:= Ascan(aHeader,{|x| Alltrim(x[2]) == "AD7_HORA2"})// Posicao do campo Hora2 no aCols
Local dData  := CTOD(" /  /  ")
Local cHora1 := ""
Local cHora2 := ""
Local lRet   := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega os valores da linha atual digitada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dData  := aCols[n][nPData ]
cHora1 := aCols[n][nPHora1]
cHora2 := aCols[n][nPHora2]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Percorre o restante das linhas do ACOLS procurando a mesma data e hora de agenda³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nLinha := 1 TO Len(aCols)
			
	If (dData == aCols[nLinha][nPData]) .AND. (nLinha <> n)  .AND. !aCols[n][Len(aHeader)+1]  
	    
	    If   Alltrim(cHora1) == aCols[nLinha][nPHora1] .OR. Alltrim(cHora2) == aCols[nLinha][nPHora2] 
	 		Help(" ",1,"TMKVENHDIS")//"Este vendedor já possui compromisso para o horário informado. Por favor, verifique um horário disponível."
	 		lRet := .F.
	   		Exit
	   	Endif   

	Endif   			

Next nLinha

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³Tk271GeraMemo ³Autor  ³Vendas Clientes       ³ Data 10/07/2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Agenda a visita do vendedor/tecnico                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Sigatmk  											   	         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkGeraMemo(cTmkAnt,cTlvAnt,cTlcAnt)

Local dDtAtend					// Data do atendimento
Local aItems      := {}   		// Itens do atendimento
Local cObs        := Space(40)	// Observações do atendimento
Local cMemoTmk    := ""			// Memo do atendimento do telemarketing que será retornado
Local cMemoTlc    := ""			// Memo do atendimento do telecobrança que será retornado
Local cMemoTlv    := ""			// Memo do atendimento do televendas que será retornado
Local cAtend      := ""			// Código do atendimento
Local cHoraIni    := ""			// Hora inicial do atendimento
Local cHoraFim    := ""			// Hora final do atendimento
Local cMidia      := ""			// Descrição da midia do atendimento
Local cTipo       := ""			// Descrição da comunicação do atendimento
Local cOperado    := ""			// Descrição do Operador do atendimento
Local cStatus     := ""			// Status do atendimento
Local cMotivo     := ""			// Motivo de encerramento do atendimento
Local cCampanha   := ""			// Campanha do atendimento
Local cAssunto    := ""			// Assunto do atendimento telemarketing
Local cProduto    := ""			// Produto do atendimento telemarketing
Local cOcorren    := ""			// Ocorrência do atendimento telemarketing
Local cSolucao    := ""			// Solução do atendimento telemarketing
Local cVend       := ""			// Vendedor do atendimento
Local cNF         := ""			// Número da nota fiscal do atendimento televendas
Local cSerie      := ""			// Série da nota fiscal do atendimento televendas
Local cValTot     := ""			// Valor brudo do atendimento televendas
Local cValLiq     := ""			// Valor líquido do atendimento televendas
Local cDescont    := ""			// Desconto do atendimento televendas
Local cCond       := ""			// Condição de pagamento do atendimento televendas
Local cQuant      := ""			// Quantidade do item do atendimento televendas
Local cUnit       := ""			// Unidade do item do atendimento televendas
Local cTotItem    := ""			// Total do item do atendimento televendas 
Local cCodMidia   := ""			// Midia do atendimento do atendimento telemarketing
Local cCodTipo    := ""			// Código da comunicação do atendimento telemarketing
Local cCodOperado := ""			// Código do operador do atendimento
Local cCodCampanha:= ""			// Código da campanha do atendimento televendas
Local cCodObs     := ""			// Código da observação do atendimento
Local cCodCamp    := ""			// Código da campanha do atendimento telemarketing
Local cTitulo     := ""			// Número do título do atendimento telecobrança
Local cPrefixo    := ""			// Prefixo do título do atendimento telecobrança
Local cParcela    := ""			// Parcela do título do atendimento telecobrança
Local dDtVenc     := ""			// Data de vencimento do título do atendimento telecobrança
Local nValor      := 0			// Valor do título do atendimento telecobrança
Local nCont       := 0			// Contador

If nFolder == 1 // Telemarketing ou Televendas
	If TkGetTipoAte() $ "145" // Telemarketing ou Televendas ou (Telemarketing e Televendas)
		DbSelectArea("SUC")
		DbSetOrder(1)
		If DbSeek(xFilial("SUC") + cTmkAnt)
		
			cAtend      := SUC->UC_CODIGO
			dDtAtend    := SUC->UC_DATA
			cHoraIni    := SUC->UC_INICIO
			cHoraFim    := SUC->UC_FIM
			cStatus     := SUC->UC_STATUS
			cCodMidia   := SUC->UC_MIDIA
			cCodTipo    := SUC->UC_TIPO
			cCodOperado := SUC->UC_OPERADO
			cCodCamp    := SUC->UC_CODCAMP
			cCodObs     := SUC->UC_CODOBS
			cCodMot     := SUC->UC_CODMOT
			cMidia  	:= Posicione("SUH",1,xFilial("SUH") + cCodMidia   ,"SUH->UH_DESC")
			cTipo    	:= Posicione("SUL",1,xFilial("SUL") + cCodTipo    ,"SUL->UL_DESC")
			cOperado 	:= Posicione("SU7",1,xFilial("SU7") + cCodOperado ,"SU7->U7_NREDUZ")
			cMotivo  	:= Posicione("SU9",1,xFilial("SU9") + cCodMot     ,"SU9->U9_DESC")
			cCampanha	:= Posicione("SUO",1,xFilial("SUO") + cCodCamp    ,"SUO->UO_DESC")
			cObs     	:= MSMM(SUC->UC_CODOBS,40)
		
			DbSelectArea("SUD")
			DbSetOrder(1)
			DbSeek(xFilial("SUD") + cTmkAnt)
		
			While !Eof() .AND. (xFilial("SUD") == SUD->UD_FILIAL) .AND. (cTmkAnt == SUD->UD_CODIGO)
				cAssunto := Posicione("SX5",1,xFilial("SX5") + "T1" + SUD->UD_ASSUNTO,"X5DESCRI()")
				cProduto := Posicione("SB1",1,xFilial("SB1") + SUD->UD_PRODUTO       ,"SB1->B1_DESC")
				cOcorren := Posicione("SU9",1,xFilial("SU9") + SUD->UD_OCORREN       ,"SU9->U9_DESC")
				cSolucao := Posicione("SUQ",1,xFilial("SUQ") + SUD->UD_SOLUCAO       ,"SUQ->UQ_DESC")

				Aadd(aItems,{cAssunto,cProduto,cOcorren,cSolucao})
				DbSkip()
			End

			
			cMemoTmk+= STR0028 + Chr(10)			         //"             Telemarketing              " 
			cMemoTmk+= STR0029 + cAtend + Chr(10)            //"Atendimento: "		 
			cMemoTmk+= STR0030 + Dtoc(dDtAtend) + Chr(10)   //"Data       : " 	
			cMemoTmk+= STR0031 + cHoraIni + STR0032 + cHoraFim + Chr(10)//"Inicio     : "" Fim: "
			cMemoTmk+= STR0033 + cOperado + Chr(10)	   		//"Operador   : "
			cMemoTmk+= STR0034 + cMotivo + Chr(10)		    //"Motivo     : "
			cMemoTmk+= STR0035 + cTipo + Chr(10)		    //"Tipo       : " 
			cMemoTmk+= STR0036 + cCampanha + Chr(10)		//"Campanha   : "
			cMemoTmk+= STR0037 + cStatus + Chr(10)		    //"Status     : "
		
			If (Len(aItems) > 0)
				cMemoTmk+= STR0038 + Chr(10) //"Assunto       Produto       Ocorrencia       Solucao  "		 

				For nCont:= 1 To Len(aItems)
					cMemoTmk+= SubStr(aItems[nCont][1],1,14) + SubStr(aItems[nCont][2],1,14) + SubStr(aItems[nCont][3],1,14) + SubStr(aItems[nCont][4],1,14) + Chr(10)
				Next nCont
				
			Endif

			cMemoTmk+= STR0039 + cObs + Chr(10) //"Observacao : "		 
        Endif
    ElseIf (TkGetTipoAte() == "2") //Televendas

		DbSelectArea("SUA")
		DbSetOrder(1)
		If DbSeek(xFilial("SUA") + cTlvAnt)
		
			cAtend      := SUA->UA_NUM
			cNF         := SUA->UA_DOC
			cSerie      := SUA->&(SerieNfId ("SUA",3,"UA_SERIE"))
			dDtAtend    := SUA->UA_EMISSAO
			cHoraIni    := SUA->UA_INICIO
			cHoraFim    := SUA->UA_FIM
			cStatus     := SUA->UA_STATUS
			cValTot     := Str(SUA->UA_VALBRUT,12,2)
			cDescont    := Str(SUA->UA_DESCONT,12,2)
			cValLiq     := Str(SUA->UA_VALLIQ,12,2)
			cCodMidia   := SUA->UA_MIDIA
			cCodCond    := SUA->UA_CONDPG 
			cCodOperado := SUA->UA_OPERADO
			cCodVend    := SUA->UA_VEND   
			cCodCampanha:= SUA->UA_CODCAMP
			cCodObs     := SUA->UA_CODOBS

			DbSelectArea("SUB")
			DbSetOrder(1)
			DbSeek(xFilial("SUB") + cTlvAnt)
		
			While !Eof() .AND. (xFilial("SUB") == SUB->UB_FILIAL) .AND. (cTlvAnt == SUB->UB_NUM)
				cProduto := Posicione("SB1",1,xFilial("SB1") + SUB->UB_PRODUTO       ,"SB1->B1_DESC")
				cQuant   := Str(SUB->UB_QUANT)
				cUnit    := Str(SUB->UB_VRUNIT)
				cTotItem := Str(SUB->UB_VLRITEM)

				Aadd(aItems,{cProduto,cQuant,cUnit,cTotItem})
				DbSkip()
			End


			cMemoTlv+= STR0040 + Chr(10)				 //"             Televendas                 "	 
			cMemoTlv+= STR0029 + cAtend + Chr(10)		 //"Atendimento: "		 
			cMemoTlv+= STR0030 + Dtoc(dDtAtend) + Chr(10) //"Data       : " 
			cMemoTlv+= STR0031 + cHoraIni + STR0032 + cHoraFim + Chr(10)//"Inicio     : "" Fim: "		 
			cMemoTlv+= STR0033 + cOperado + Chr(10)		//"Operador   : " 
			cMemoTlv+= STR0041 + cVend + Chr(10)		//"Vendedor   : " 
			cMemoTlv+= STR0036 + cCampanha + Chr(10)	//"Campanha   : " 
			cMemoTlv+= STR0038 + cStatus + Chr(10)		//"Status     : " 

			If (Len(aItems) > 0)
				cMemoTlv+= STR0042 + cNF     + Chr(10)	//"NF         : " 
				cMemoTlv+= STR0043 + cSerie  + Chr(10)	//"Serie      : "
				cMemoTlv+= STR0044 + cCond   + Chr(10)	//"Condicao   : "
				cMemoTlv+= STR0045 + cValTot + Chr(10)	//"Valor Total: " 
				cMemoTlv+= STR0046 + cDescont+ Chr(10)	//"Desconto   : "
				cMemoTlv+= STR0047 + cValLiq + Chr(10)	//"Liquido    : "

				cMemoTlv+= STR0048 + Chr(10)		    //"Produto       Quantidade    Unitario         Total Item" 

				For nCont:= 1 To Len(aItems)
					cMemoTlv+= SubStr(aItems[nCont][1],1,14) + SubStr(aItems[nCont][2],1,14) + SubStr(aItems[nCont][3],1,14) + SubStr(aItems[nCont][4],1,14) + Chr(10)							
				Next nCont
			Endif

			cMemoTlv+= STR0039 + cObs + Chr(10)		//"Observacao : " 
    	Endif
	
    ElseIf (TkGetTipoAte() == "3") //Telecobranca

		DbSelectArea("ACF")
		DbSetOrder(1)
		If DbSeek(xFilial("ACF") + cTlcAnt)
		
			cAtend      := ACF->ACF_CODIGO
			dDtAtend    := ACF->ACF_DATA
			cHoraIni    := ACF->ACF_INICIO
			cHoraFim    := ACF->ACF_FIM
			cCodOperado := ACF->ACF_OPERAD
			cCodObs     := ACF->ACF_CODOBS
			cObs     	:= MSMM(cCodObs,40)

			DbSelectArea("ACG")
			DbSetOrder(1)
			DbSeek(xFilial("ACG") + cTlcAnt)
		
			While !Eof() .AND. (xFilial("ACG") == ACG->ACG_FILIAL) .AND. (cTlcAnt == ACG->ACG_CODIGO)
				cTitulo  := ACG->ACG_TITULO
				cPrefixo := ACG->ACG_PREFIX
				cParcela := ACG->ACG_PARCEL
				cTipo    := ACG->ACG_TIPO
				dDtVenc  := ACG->ACG_DTREAL
				nValor   := ACG->ACG_VALOR				

				Aadd(aItems,{cTitulo,cPrefixo,cParcela,cTipo,Dtoc(dDtVenc),Str(nValor)})
				DbSkip()
			End


			cMemoTlc+= STR0049 + Chr(10)					 			//"             Telecobranca                 "	 
			cMemoTlc+= STR0029 + cAtend + Chr(10)		 				//"Atendimento: "		 
			cMemoTlc+= STR0030 + Dtoc(dDtAtend) + Chr(10) 				//"Data       : " 
			cMemoTlc+= STR0031 + cHoraIni + STR0032 + cHoraFim + Chr(10)//"Inicio     : "" Fim: "		 
			cMemoTlc+= STR0033 + cOperado + Chr(10)						//"Operador   : " 

			If (Len(aItems) > 0)

				cMemoTlc+= STR0050 + Chr(10)		    //"Titulo       Prefixo    Parcela    Tipo    Vencimento           Valor" 

				For nCont:= 1 To Len(aItems)
					cMemoTlc+= aItems[nCont][1] + Space(5) + aItems[nCont][2] + Space(5) + aItems[nCont][3] + Space(5) + aItems[nCont][4] + Space(5) + aItems[nCont][5] + Space(5) + aItems[nCont][6] + Chr(10)							
				Next nCont
			Endif

			cMemoTlc+= STR0039 + cObs + Chr(10)		//"Observacao : " 
	    Endif
	Endif
ElseIf (nFolder == 2) //Televendas
	DbSelectArea("SUA")
	DbSetOrder(1)
	If DbSeek(xFilial("SUA") + cTlvAnt)
		
		cAtend   	:= SUA->UA_NUM
		cNF      	:= SUA->UA_DOC
		cSerie   	:= SUA->&(SerieNfId ("SUA",3,"UA_SERIE"))
		dDtAtend    := SUA->UA_EMISSAO
		cHoraIni    := SUA->UA_INICIO
		cHoraFim    := SUA->UA_FIM
		cStatus     := SUA->UA_STATUS
		cValTot     := Str(SUA->UA_VALBRUT,12,2)
		cDescont    := Str(SUA->UA_DESCONT,12,2)
		cValLiq     := Str(SUA->UA_VLRLIQ,12,2)
		cCodMidia   := SUA->UA_MIDIA
		cCodCond    := SUA->UA_CONDPG 
		cCodOperado := SUA->UA_OPERADO
		cCodVend    := SUA->UA_VEND   
		cCodCampanha:= SUA->UA_CODCAMP
		cCodObs     := SUA->UA_CODOBS
		cMidia   	:= Posicione("SUH",1,xFilial("SUH") + cCodMidia   ,"SUH->UH_DESC")
		cCond    	:= Posicione("SE4",1,xFilial("SE4") + cCodCond    ,"SE4->E4_DESCRI")
		cOperado 	:= Posicione("SU7",1,xFilial("SU7") + cCodOperado ,"SU7->U7_NREDUZ")
		cVend    	:= Posicione("SA3",1,xFilial("SA3") + cCodVend    ,"SA3->A3_NREDUZ")
		cCampanha	:= Posicione("SUO",1,xFilial("SUO") + cCodCamp 	,"SUO->UO_DESC")
		cObs     	:= MSMM(cCodObs,40)

		DbSelectArea("SUB")
		DbSetOrder(1)
		DbSeek(xFilial("SUB") + cTlvAnt)
		
		While !Eof() .AND. (xFilial("SUB") == SUB->UB_FILIAL) .AND. (cTlvAnt == SUB->UB_NUM)
			cProduto := Posicione("SB1",1,xFilial("SB1") + SUB->UB_PRODUTO       ,"SB1->B1_DESC")
			cQuant   := Str(SUB->UB_QUANT)
			cUnit    := Str(SUB->UB_VRUNIT)
			cTotItem := Str(SUB->UB_VLRITEM)
        	
			Aadd(aItems,{cProduto,cQuant,cUnit,cTotItem})
			DbSkip()
		End

		cMemoTlv+= STR0040 + Chr(10)				  							      //"             Televendas                 "	 
		cMemoTlv+= STR0029 + cAtend         + Chr(10)		  					      //"Atendimento: "		 
		cMemoTlv+= STR0030 + Dtoc(dDtAtend) + Chr(10)						          //"Data       : " 
		cMemoTlv+= STR0031 + cHoraIni       + STR0032 + cHoraFim + Chr(10)//"Inicio     : "" Fim: "		 
		cMemoTlv+= STR0033 + cOperado       + Chr(10)								  //"Operador   : " 
		cMemoTlv+= STR0041 + cVend          + Chr(10)		    					  //"Vendedor   : " 
		cMemoTlv+= STR0036 + cCampanha      + Chr(10)								  //"Campanha   : " 
		cMemoTlv+= STR0037 + cStatus        + Chr(10)								  //"Status     : " 
       	
		If (Len(aItems) > 0)
			cMemoTlv+= STR0042 + cNF     + Chr(10)	//NF          : "
			cMemoTlv+= STR0043 + cSerie  + Chr(10)	//"Serie      : "
			cMemoTlv+= STR0044 + cCond   + Chr(10)	//"Condicao   : 
			cMemoTlv+= STR0045 + cValTot + Chr(10)	//"Valor Total: " 
			cMemoTlv+= STR0046 + cDescont+ Chr(10)	//"Desconto   : "
			cMemoTlv+= STR0047 + cValLiq + Chr(10)	//"Liquido    : "
			cMemoTlv+= STR0048 + Chr(10)		    //"Produto       Quantidade    Unitario         Total Item" 
           	
			For nCont:= 1 To Len(aItems)
				cMemoTlv+= SubStr(aItems[nCont][1],1,14) + SubStr(aItems[nCont][2],1,14) + SubStr(aItems[nCont][3],1,14) + SubStr(aItems[nCont][4],1,14) + Chr(10)							
			Next nCont
		Endif

		cMemoTlv+= STR0039 + cObs + Chr(10)		//"Observacao : " 
    Endif

ElseIf (nFolder == 3) //Telecobranca
	DbSelectArea("ACF")
	DbSetOrder(1)
	If DbSeek(xFilial("ACF") + cTlcAnt)
		
		cAtend      := ACF->ACF_CODIGO
		dDtAtend    := ACF->ACF_DATA
		cHoraIni    := ACF->ACF_INICIO
		cHoraFim    := ACF->ACF_FIM
		cCodOperado := ACF->ACF_OPERAD
		cCodObs     := ACF->ACF_CODOBS
		cObs     	:= MSMM(cCodObs,40)

		DbSelectArea("ACG")
		DbSetOrder(1)
		DbSeek(xFilial("ACG") + cTlcAnt)
		
		While !Eof() .AND. (xFilial("ACG") == ACG->ACG_FILIAL) .AND. (cTlcAnt == ACG->ACG_CODIGO)
			cTitulo  := ACG->ACG_TITULO
			cPrefixo := ACG->ACG_PREFIX
			cParcela := ACG->ACG_PARCEL
			cTipo    := ACG->ACG_TIPO
			dDtVenc  := ACG->ACG_DTREAL
			nValor   := ACG->ACG_VALOR				

			Aadd(aItems,{cTitulo,cPrefixo,cParcela,cTipo,Dtoc(dDtVenc),Str(nValor)})
			DbSkip()
		End

		cMemoTlc+= STR0049 + Chr(10)					 							//"             Telecobranca                 "	 
		cMemoTlc+= STR0029 + cAtend + Chr(10)		 							//"Atendimento: "		 
		cMemoTlc+= STR0030 + Dtoc(dDtAtend) + Chr(10) 							//"Data       : " 
		cMemoTlc+= STR0031 + cHoraIni + STR0032 + cHoraFim + Chr(10)	//"Inicio     : "" Fim: "		 
		cMemoTlc+= STR0033 + cOperado + Chr(10)									//"Operador   : " 

		If (Len(aItems) > 0)

			cMemoTlc+= STR0050 + Chr(10)		//"Titulo       Prefixo    Parcela    Tipo    Vencimento           Valor" 

			For nCont:= 1 To Len(aItems)
				cMemoTlc+= aItems[nCont][1] + Space(8) + aItems[nCont][2] + Space(10) + aItems[nCont][3] + Space(12) + aItems[nCont][4] + Space(8) + aItems[nCont][5] + Space(5) + aItems[nCont][6] + Chr(10)							
			Next nCont
		Endif

		cMemoTlc+= STR0039 + cObs + Chr(10)		//"Observacao : " 
    Endif
Endif

//Grava o arquivo de agendas
cMemoTmk+= cMemoTlv + cMemoTlc

Return(cMemoTmk)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271GrvCamp ³ Autor ³ Vendas Clientes    ³ Data ³ 04/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava a campanha executada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMKA271       	        						          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TkGrvCamp(aParScript)

Local cRotina	:= ""
Local cAtend	:= ""
Local cCampCod	:= ""
Local nX		:= 0
Local lPergunta	:= .T.
Local lTKMSGCAM := ExistBlock("TKMSGCAM")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso a campanha selecionada foi executada e gravada, atualiza o numero do atendimento³
//³no cabecalho da gravacao da campanha.                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aParScript) > 0
	If Type("nFolder") == "N"
		If (TkGetTipoAte() == "1") .OR. (TkGetTipoAte() == "4" .And. nFolder == 1) .OR. (TkGetTipoAte() == "5" .And. nFolder == 1) //Telemarketing
			cRotina:= "1"
			cAtend := M->UC_CODIGO	
		
		ElseIf (TkGetTipoAte() == "2") .OR. (TkGetTipoAte() == "4" .And. nFolder == 2) .OR. (TkGetTipoAte() == "5" .And. nFolder == 2)//Televendas
			cRotina:= "2"
			cAtend := M->UA_NUM
		
		ElseIf (TkGetTipoAte() == "3") .OR. (TkGetTipoAte() == "4" .And. nFolder == 3) //Telecobranca
			cRotina:= "3"
			cAtend := M->ACF_CODIGO	
		
		Endif
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para inibir a mensagem de confirmação ³
	//³ da gravação da campanha.                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTKMSGCAM
		lPergunta := ExecBlock("TKMSGCAM",.F.,.F.,{aParScript})	
		If ValType(lPergunta) <> "L"
			lPergunta := .T.
		EndIf
	EndIf
		
	DbSelectArea("ACI")			
	DbSetOrder(1)

	If Len(aParScript) > 0 .AND. IIf(lPergunta,TmkOk(STR0055),.T.) //"Confirma a gravacao da campanha ?"	
		For nX := 1 to Len(aParScript)   
		
			Tk380Grava(	aParScript[nX][1]	,aParScript[nX][2] 	, aParScript[nX][3]	,aParScript[nX][4]	,;
			            aParScript[nX][5]	,aParScript[nX][6] 	, aParScript[nX][7]	,aParScript[nX][8] 	,;
						aParScript[nX][9]	,aParScript[nX][10]	, aParScript[nX][11],aParScript[nX][12],;
						cAtend				,@cCampCOD			, .F.				)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava a rotina e o numero do atendimento de onde³
			//³foi executado a campanha.                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ACI->(DbSeek(xFilial("ACI") + cCampCod))
				RecLock("ACI",.F.)
				Replace ACI_ROTINA With cRotina
				Replace ACI_ATEND  With cAtend
				MsUnLock()
				DbCommit()
			Endif  
			
		Next nX 		
	EndIf
Endif

aParScript:= {}

Return(.T.)

/*                                                                     
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TkGrvSU4   ³ Autor ³Vendas Clientes       ³ Data ³05/04/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava uma nova ligacao para o operador                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³TMKA271											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                       
Function TKGrvSU4(	cCodCont	,cEntidade	,cChave	,cCodOper,;
					cRotina		,cCodLig	,dDataR	,cTimeR,;
					l380		,cLista)

Local aArea			:= GetArea()
Local cTipoTel		:= "1"							// Assume que o telefone utilizado sera o COMERCIAL
Local cAntList		:= ""
Local oDlgTel										// Tela para selecao dos telefones do contato	
Local oLbx1											// Listbox com a lista de telefones	
Local aTel   		:= {}           				// Array com os telefones do CONTATO
Local nTipo  		:= 1
Local lRet	 		:= .F.							// Retorno da funcao
Local cTipo			:= ""							// Tipo da Lista de acordo com o campo U4_TIPO = 1=Marketing,2=Cobranca,3=Vendas
Local lNovo			:= .T.							// Indica se sera gerada uma nova lista de contato pendente ou alteradad a lista ja gravada
Local nOk			:= 0							// Variavel de controle para janela de selecao.
Local nSaveSx8 		:= 0							// Funcao de numeracao
Local lTkSeqLista	:= ExistBlock("TKSeqLista")		// Indica se a numeracao sequencial das listas (SU4-SU6) Serao feitas por funcao customizada	            	
Local aAreaACF		:= ACF->(GetArea())				// Tabela, indice e recno atuais da tabela SU4
Local cQuery 		:= ""
Local cAlias 		:= GetNextAlias()
Local aListDDD		:= {}							// Array com as informações da AGB
Local nDDD			:= 0							// Posição da DDD no array aListDDD
Local cRegSel		:= TkPosto(TkOperador(),"U0_REGSEL")	// Regra de selecao do Operador		//MENON
Local lListaCob		:= .F.
Local lObfTel		:= .F.

Default cLista	:= ""								// Codigo da Lista

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o operador está trabalhando com a regra de seleção por lista de cobrança. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SK0")
DbSetOrder(1)
If DbSeek(xFilial("SK0")+cRegSel)
   	If SK0->K0_PRAZO == "999999"	// Trabalha com lista de cobrança
   		lListaCob := .T.
   	EndIf
EndIf    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o horario de retorno nao foi preenchido, ainda assim o³
//³agendamento deve ser feito pois a data foi preenchida.   ³
//³Portanto seu conteudo deve ser igual a '  :  '           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cTimeR)
	cTimeR	:= "  :  "
EndIf           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a data da pendencia estiver preenchida gera uma liga‡„o no SU4  ³
//³desde que a liga‡„o atual seja PENDENTE a liga‡„o sera gerada para:³
//³  - O cliente/prospect atual                                       ³
//³  - O Operador atual                                               ³
//³  - A hora indicada, ou a hora do perfil do contato                ³
//³  - Para o Contato Atual                                           ³
//³  - Com o codigo da liga‡„o atual que gerou essa liga‡„o pendente  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(dDataR) .AND. !Empty(cTimeR)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exibe uma tela com os telefones do contato para ser selecionado para a geracao de ligacao pendente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SU5")
	DbSetOrder(1)
	If DbSeek( xFilial("SU5") + cCodCont)
		//Busca Informações na AGB
		aListDDD := TkGetAGB("SU5",SU5->U5_CODCONT)
		
		If(nDDD := Ascan(aListDDD,{|x| x[5]== SU5->U5_FONE})) > 0 
			Aadd(aTel,{STR0020,ALLTRIM(SU5->U5_CODPAIS) + aListDDD[nDDD][4] + ALLTRIM(SU5->U5_FONE)})   	//"Residencial" 
		Else	
			Aadd(aTel,{STR0020,ALLTRIM(SU5->U5_CODPAIS) + ALLTRIM(SU5->U5_DDD) + ALLTRIM(SU5->U5_FONE)})   	//"Residencial" 	
		EndIf	

		If(nDDD := Ascan(aListDDD,{|x| x[5]== SU5->U5_CELULAR})) > 0 
			Aadd(aTel,{STR0021,ALLTRIM(SU5->U5_CODPAIS) + aListDDD[nDDD][4] + ALLTRIM(SU5->U5_CELULAR)})	//"Celular" 
		Else	
			Aadd(aTel,{STR0021,ALLTRIM(SU5->U5_CODPAIS) + ALLTRIM(SU5->U5_DDD) + ALLTRIM(SU5->U5_CELULAR)})	//"Celular" 	
		EndIf	

		If(nDDD := Ascan(aListDDD,{|x| x[5]== SU5->U5_FAX})) > 0  
			Aadd(aTel,{STR0009,ALLTRIM(SU5->U5_CODPAIS) + aListDDD[nDDD][4] + ALLTRIM(SU5->U5_FAX)})		//"Fax"
		Else	
			Aadd(aTel,{STR0009,ALLTRIM(SU5->U5_CODPAIS) + ALLTRIM(SU5->U5_DDD) + ALLTRIM(SU5->U5_FAX)})		//"Fax" 	
		EndIf		
		
		If(nDDD := Ascan(aListDDD,{|x| x[5]== SU5->U5_FCOM1})) > 0 
			Aadd(aTel,{STR0022,ALLTRIM(SU5->U5_CODPAIS) + aListDDD[nDDD][4] + ALLTRIM(SU5->U5_FCOM1)})	//"Comercial 1" 
		Else	
			Aadd(aTel,{STR0022,ALLTRIM(SU5->U5_CODPAIS) + ALLTRIM(SU5->U5_DDD) + ALLTRIM(SU5->U5_FCOM1)})	//"Comercial 1" 	
		EndIf	 
	
		If(nDDD := Ascan(aListDDD,{|x| x[5]== SU5->U5_FCOM2})) > 0 
			Aadd(aTel,{STR0023,ALLTRIM(SU5->U5_CODPAIS) + aListDDD[nDDD][4] + ALLTRIM(SU5->U5_FCOM2)})	//"Comercial 2" 
		Else	
			Aadd(aTel,{STR0023,ALLTRIM(SU5->U5_CODPAIS) + ALLTRIM(SU5->U5_DDD) + ALLTRIM(SU5->U5_FCOM2)})	//"Comercial 2" 	
		EndIf	
	Endif
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao estiver usando a entrada automatica³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTk271Auto 
		
		lObfTel := FATPDIsObfuscate("A1_TEL",,.T.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exibe a tela de escolha do telefone ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While nOk <> 1 .OR. Empty(aTel[nTipo][2])
			DEFINE MSDIALOG oDlgTel FROM 15,2 TO 200,347 TITLE STR0024 PIXEL //"Telefones do Contato" 
	
			    @ 002,002 TO 075,165 LABEL "" OF oDlgTel PIXEL
				@ 005,004 LISTBOX oLbx1 FIELDS ;
				HEADER ;
					STR0025,;  //"Tipo" 
					STR0026;   //"Numero" 
				SIZE 160,65 OF oDlgTel PIXEL ON CHANGE (nTipo:= oLbx1:nAt) 
				
				oLbx1:SetArray(aTel)
				oLbx1:bLine := {||{	aTel[oLbx1:nAt, 1],;
									aTel[oLbx1:nAt, 2] }}
				
				If FATPDActive() .And. FTPDUse(.T.)
					oLbx1:aObfuscatedCols := {.F.,lObfTel} 
				EndIf
								
				DEFINE SBUTTON FROM 080,140 TYPE 1 ACTION (nOk:=1,oDlgTel:End())	ENABLE OF oDlgTel

				FATPDLogUser("TKGRVSU4") 
		
			ACTIVATE MSDIALOG oDlgTel CENTERED
			
			If nOk <> 1 .OR. Empty(aTel[nTipo][2])
				Aviso(STR0053,STR0054,{"OK"}) 
			EndIf
		End	
	Endif
	
	cTipoTel := StrZero(nTipo,1)
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A funcao TkExistSU4 busca o registro valido na SU4 para    ³
	//³alteracao. Caso nao exista um registro valido, um novo sera³
	//³criado                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SU4")
	If TkExistSU4(cCodLig,@cLista, cRotina)
		If !Empty(cLista)
			DbSetOrder(1) //Pesquisa pela lista
			If DbSeek(xFilial("SU4")+cLista)
				lNovo := .F.
			EndIf
		Else
			DbSetOrder(4) //Pesquisa pelo codigo da ligacao
			If DbSeek(xFilial("SU4")+cCodLig) 
				cLista 	:= SU4->U4_LISTA
				lNovo 	:= .F.
			EndIf
		Endif
	Endif
	
	If !Empty(cLista)

		// Posiciona o cabecalho
		DbSelectArea("SU4")
		DbSetOrder(1)
		DbSeek(xFilial("SU4") + cLista)
		
		// Posiciona os itens
		DbSelectArea("SU6")
		DbSetOrder(1)
		DbSeek(xFilial("SU6") + cLista)
		
		// Ajusta a opcao para alteracao
		lNovo := .F.
	Endif

	If lNovo
		If lTkSeqLista
			cLista	:= U_TkSeqLista("SU4","U4_LISTA")
		Else
			nSaveSx8 := GetSX8Len()  // Funcao de numeracao
			cLista 	 := GetSXENum("SU4","U4_LISTA")
		Endif	
	Endif
		
	Do Case
		Case TkGetTipoAte() == "1" //Telemarketing
			cTipo := "1"	// Marketing - U4_TIPO

		Case TkGetTipoAte() == "2" //Televendas
			cTipo := "3"	// Vendas - U4_TIPO
	
		Case TkGetTipoAte() == "3" //Telecobranca
			cTipo := "2"	// Cobranca - U4_TIPO

		Otherwise
			If nFolder == 1 // TeleMarketing
				cTipo := "1"	// Marketing - U4_TIPO
			Elseif nFolder == 2 //Televendas
				cTipo := "3"	// Vendas - U4_TIPO
			Elseif nFolder == 3 //TeleCobranca
				cTipo := "2"	// Cobranca - U4_TIPO
			Endif
			 	
	Endcase

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida a existencia do conteudo da cLista³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lNovo .AND. lTkSeqLista
		DbSelectArea("SU4")
		DbSetOrder(1)
		If !DbSeek( xFilial( "SU4" ) + cLista )
			lNovo := .T.
			Conout( "TMKXFUNB - A lista " + cLista + " nao foi encontrada. Uma nova lista sera gerada no SU4" )
		Endif
	Endif
	
	aAreaSU4 := SU4->(GetArea())
	//Busca a ultima lista ativa do cliente posicionado
	cQuery 	:= "SELECT MAX(SU4.R_E_C_N_O_) AS REGSU4 " 
	cQuery 	+= "FROM "+RetSqlName("SU4")+" SU4 " 
	cQuery 	+= "WHERE "
	cQuery 	+= "    SU4.U4_CODLIG = '"+ACF->ACF_CODIGO+"' "
	cQuery 	+= "AND SU4.U4_STATUS = '2' "
	cQuery 	+= "AND SU4.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)

	If (cAlias)->(!Eof())
		While (cAlias)->(!Eof())
			SU4->(DbGoTo((cAlias)->REGSU4))
			//Se nao existir lista pai utiliza a atual
			If Empty(Alltrim(SU4->U4_ANTLST))
				cAntList := SU4->U4_LISTA            
			//Se existir lista pai utiliza a lista pai
			Else
				cAntList := SU4->U4_ANTLST
			EndIf
			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())
	EndIf
	RestArea(aAreaSU4)  
	 		
	RecLock("SU4",lNovo)	
	Replace U4_FILIAL   With xFilial("SU4")
	Replace U4_LISTA    With cLista
	Replace U4_DESC		With STR0019 + cCodLig  //"Atendimento: "
	Replace U4_DATA		With dDataR
	Replace U4_FORMA	With "5"  		// 1=Voz 2=Fax 3=Cross Posting 4=mala Direta 5=Pendencia 6=WebSite
	Replace U4_TELE		With cRotina
	Replace U4_OPERAD	With cCodOper
	Replace U4_TIPOTEL	With cTipoTel 	// 1=Residencial 2=Fax 3=Celular 4=Comercial 1 5=Comercial 2
	Replace U4_CODLIG   With cCodLig  	// Codigo do atendimento
	
	//Só altera o status da lista para 3-Em Andamento, se a chamada vier da Agenda do Operador ou do atendimento receptivo
	If lListaCob
		//Quando utiliza lista de cobrança 
		Replace U4_STATUS   With Iif(cTipo == "2" .And. ALTERA .And. (l380 .Or. FunName() == "TMKA350"),"3","1")      // Status da Lista 1=Ativa;2=Encerrada;3=Em Andamento
	Else
		//Quando utiliza o pré-atendimento
		Replace U4_STATUS   With "1"	// Status da Lista 1=Ativa;2=Encerrada;3=Em Andamento
	EndIf
	
	Replace U4_TIPO		With cTipo		// Tipo da Lista 1=Marketing 2=Vendas 3=Cobranca
	Replace U4_HORA1    With cTimeR
	Replace U4_ANTLST   With cAntList	// Numero da antiga lista ativa
	
	SU4->(MsUnlock())

	If lNovo	
		If !lTkSeqLista
			DbSelectarea("SU4")
			While (GetSx8Len() > nSaveSx8)
				ConfirmSX8()
			End	
		Endif
	Endif
    SU4->(FkCommit())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava uma nova ligacao para o contato.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SU6")
	DbSetOrder(1)
	If !lNovo
		// Se nao for possivel alterar - incluir um novo item para a Lista
		If DbSeek(xFilial("SU6")+cLista)
			cItem	:= SU6->U6_CODIGO
		Else
			lNovo	:= .T.
		EndIf
	Endif

	If lNovo
		If lTkSeqLista
			cItem	:= U_TkSeqLista("SU6","U6_CODIGO")
		Else	
			nSaveSx8:= GetSX8Len()  // Funcao de numeracao
			cItem 	:= GetSXENum("SU6","U6_CODIGO")
		Endif	
	EndIf

	RecLock("SU6",lNovo)
	Replace U6_FILIAL  With xFilial("SU6")	
	Replace U6_LISTA   With	cLista
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³se nao for inclusao o codigo do registro nao precisa ser alterado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lNovo
		Replace U6_CODIGO  With	cItem
		Replace U6_DTBASE  With	dDataBase
	EndIf
	Replace U6_FILENT  With	xFilial(cEntidade)
	Replace U6_ENTIDA  With	cEntidade
	Replace U6_CODENT  With	cChave
	Replace U6_ORIGEM  With	"3"				//1=Lista 2=Manual 3=Atendimento
	Replace U6_CONTATO With	cCodCont
	Replace U6_DATA    With	dDataR
	Replace U6_HRINI   With	cTimeR
	Replace U6_HRFIM   With	"23:59"
	Replace U6_STATUS  With	"1"    			//1=Nao Enviado 2=Enviado
	Replace U6_CODLIG  With	cCodLig
	MsUnlock()
	If lNovo
 		If lTkSeqLista
			DbSelectarea("SU6")
			While (GetSx8Len() > nSaveSx8)
				ConfirmSX8()
			End	
		Endif
	Endif
	SU6->(FkCommit())
	
	lRet := .T.

Endif  

RestArea(aAreaACF)
RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tk271Header³ Autor ³ Vendas Clientes      ³ Data ³ 29.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o array com os dados do aHeader                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk271Header(ExpC1,ExpC2,ExpA1)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                        			  ³±±
±±³          ³ ExpC1 = String com campos a ser omitido         			  ³±±
±±³          ³ ExpC2 = Array do acols                          			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TMKA271													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TkHeader(cAlias,cString,aTmpCols,aTmpHeader)

Local nUsado:= 0        //Total de colunas do aHeader
Local nPos  := 0 		//Utilizado Somente para SUB pois na atualização a ordem e uso dos campos são mantidos e com isso o nUsado não faz sentido.
Local nLinha:= 0 		//Contador de colunas do aHeader

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Estrutura do aTmpHeader:							 ³ 
³	                                                 ³
³	X3TITULO()  01                                   ³
³	X3_CAMPO 	02                                   ³ 
³	X3_PICTURE 	03									 ³
³	X3_TAMANHO  04									 ³
³	X3_DECIMAL  05									 ³
³	X3_VALID	06									 ³
³	X3_USADO	07									 ³
³	X3_TIPO		08									 ³
³	X3_ARQUIVO  09									 ³
³	X3_CONTEXT 	10								     ³
³	X3_PROPRI 	11								     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

For nLinha := 1 TO Len(aTmpHeader)
	nUsado++

	If IsHeadRec(aTmpHeader[nLinha,2])
		aTmpCols[1][nUsado] := 0
	
	ElseIF IsHeadAlias(aTmpHeader[nLinha,2])
		aTmpCols[1][nUsado] := cAlias
	
	ElseIf aTmpHeader[nLinha][8] == "C"							  //X3_TIPO		
		If TkGetX3Propri(aTmpHeader[nLinha][2]) <> "U"	// Campo padrao da Microsiga X3_PROPRI
			aTmpCols[1][nUsado] := SPACE(aTmpHeader[nLinha][4]) //X3_TAMANHO
		Else
			aTmpCols[1][nUsado] := CriaVar(ALLTRIM(aTmpHeader[nLinha][2]),.T.)  //X3_CAMPO
		Endif	

	ElseIf aTmpHeader[nLinha][8] == "M"
		aTmpCols[1][nUsado] := ""

	ElseIf aTmpHeader[nLinha][8] == "L"
		aTmpCols[1][nUsado] := .F.
		
	Else                 
		aTmpCols[1][nUsado] := CriaVar(ALLTRIM(aTmpHeader[nLinha][2]),.T.)  //X3_CAMPO
	Endif

Next nLinha

If cAlias == "SUB"		
	nPos:= Ascan(aTmpHeader,{|x| Alltrim(x[2]) == "UB_ITEM"})
	If nPos > 0 
		aTmpCols[1][nPos] := "01"
	Endif
Endif

aTmpCols[1][nUsado+1] := .F.

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |TkGetX3Propri	³ Autor ³ Vendas Clientes   ³ Data ³30/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o campo X3_Propri                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ X3_Propri                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkGetX3Propri(cField)
Local aArea		:= GetArea()	//armazena a area
Local cRet		:= ""			//Retorno da funcaoi

DbSelectArea("SX3")
DbSetOrder(2)
If DbSeek(cField)
	cRet := X3_PROPRI 
EndIf                

RestArea(aArea)
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TkValidaCols   ºAutor ³Vendas Clientes º Data ³  31/01/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Condicao para validar a montagem do aCols                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FillGetDados                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkValidaCols()
Local lRet := .F.				//Retorno da funcao

If ( SoftLock("AD7" ) )
	AAdd(aRegistros,RecNo())
	lRet := .T.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TkExistSU4 ³ Autor ³Vendas Clientes       ³ Data ³ 07/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se ha algum registro valido no SU4 para a ligacao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tk271Header(ExpC1,ExpC2)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da ligacao                                  ³±±
±±³          ³ ExpC2 = Referencia para retorno da lista                   ³±±
±±³          ³ ExpC3 = Rotina de atendimento                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TMKAXFUNB                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkExistSU4(cCodLig,cRet, cRotina)

Local aArea		:= GetArea()				// Tabela, indice e recno atuais
Local aAreaSU4	:= SU4->(GetArea())		// Tabela, indice e recno atuais da tabela SU4
Local cFilSU4	:= xFilial("SU4")			// Codigo de filial para a tabela SU4
Local cQuery	:= ""						// Query para selecao de registros da SU4
Local nQtdReg	:= 0						// Quantidade de registros validos encontrados
Local cAlias	:= "SU4"					// Alias utilizado para manipular a SU4
Local lRet		:= .F.						// Retorno da funcao (.T. registro encontrado)
Local cLista	:= ""						// Codigo da lista no SU4

#IFDEF TOP
	If TcSrvType() <> "AS/400"
		
		cAlias := "SU4T"
		
		cQuery += " SELECT U4_LISTA "
		cQuery += " FROM " + RetSqlName("SU4")
		cQuery += " WHERE U4_CODLIG = '" + cCodLig + "'"
		cQuery += " AND U4_FILIAL = '" + cFilSU4 + "' "
		cQuery += " AND U4_TELE = '" + cRotina + "' "
		cQuery += " AND (U4_STATUS = '1' OR U4_STATUS = '3') AND D_E_L_E_T_ = ' ' "	//MENON
		
		cQuery := ChangeQuery(cQuery)
		
		If Select(cAlias) > 0
			(cAlias)->(DbCloseArea())
		EndIf
		
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
		(cAlias)->(DbGoTop())
		
		While !(cAlias)->(Eof())
			nQtdReg ++
			cLista := (cAlias)->U4_LISTA
			(cAlias)->(DbSkip())
		End
		
		(cAlias)->(DbCloseArea())
		
	Else
#ENDIF

	DbSelectArea(cAlias)
	DbSetOrder(4)//U4_FILIAL+U4_CODLIG
	DbSeek( cFilSU4 + cCodLig )
	
	While !(cAlias)->(Eof())	 .AND.;
		 (cAlias)->U4_FILIAL == cFilSU4 .AND.;
		 (cAlias)->U4_CODLIG == cCodLig 

		 If (cAlias)->U4_STATUS == "1" .AND. (cAlias)->U4_TELE == cRotina
		 	nQtdReg ++
			cLista := (cAlias)->U4_LISTA
		 EndIf

		 (cAlias)->(DbSkip())
	End

#IFDEF TOP
	EndIf
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se algum registro valido foi encontrado, sera utilizado para³
//³regravacao na SU4.                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nQtdReg > 0
	lRet := .T.
	cRet := cLista
EndIf

RestArea(aAreaSU4)
RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TkGetAGB()
Busca o DDD e outras informações na tabela AGB

@author Serviços
@since 31/03/2015
@version 1.0
@return aDDD
/*/
//-------------------------------------------------------------------
Function TkGetAGB(cEnt,cCodEnt)
Local aDDD	:= {}
Local aArea := GetArea()

Default cEnt := ""
Default cCodEnt := ""

If !Empty(cEnt) .And. !Empty(cCodEnt) .And. AliasInDic("AGB")
	DbSelectArea("AGB")
	AGB->(DbSetOrder(1))
	If AGB->(DbSeek(xFilial("AGB") + cEnt + cCodEnt))
		While AGB->(!EOF()) .AND. AGB->AGB_FILIAL == xFilial("AGB") .AND. AGB->AGB_ENTIDA == cEnt .AND. AllTrim(AGB->AGB_CODENT) == cCodEnt
			Aadd(aDDD,{AGB->AGB_CODENT,AGB->AGB_TIPO,AGB->AGB_DDI,AGB->AGB_DDD,AGB->AGB_TELEFO})
			AGB->(DbSkip())
		EndDo
	EndIf	
EndIf

RestArea(aArea)

Return(aDDD)

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
