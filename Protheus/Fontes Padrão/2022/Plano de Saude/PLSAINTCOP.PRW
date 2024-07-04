#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMCCR.CH"
#INCLUDE "PLSINTCO.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSINTCO ³ Autor ³ Thiago Guilherme   ³ Data ³ 171.10.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Internação x CoParticipação                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSAINTCOP()
LOCAL oBrwBRT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina   := { 	{ STR0001  , 'AxPesqui'  , 0 , 1 },; //'Pesquisar'
							{ STR0002  , 'PLSCADCTO("BRU", BRU->(Recno()), 2, BRT->BRT_CODIGO)' , 0 , 2	},; //'Visualizar'
							{ STR0003  , 'PLSCADCTO' , 0 , 3	},; //'Incluir'
							{ STR0004  , 'PLSCADCTO("BRU", BRU->(Recno()), 4, BRT->BRT_CODIGO)' , 0 , 4	},; //'Alterar'
							{ STR0005  , 'PLSEXCTAB'  , 0 , 5	}}// 'Excluir'

oBrwBRT := FWmBrowse():New()
oBrwBRT:SetAlias('BRT')
oBrwBRT:SetAmbiente(.F.)
oBrwBRT:SetWalkThru(.F.)
oBrwBRT:activate()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal                                                  ]³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSCADCTO ³ Autor ³ Thiago Guilherme	³ Data ³ 20.10.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Faixas intern. X CoPart.                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSCADCTO(cAlias, nReg, nOpc, cChaveBRU)

Local I__f		   	:= 0
Local nOpca		:= 0
LOCAL oEnchoice
LOCAL nLin
LOCAL nLin2  		:= 0
LOCAL aRecno 		:= {}
LOCAL aDel			:= {}
LOCAL lAter  		:= .F.
LOCAL nCont

LOCAL aBRUAcols
LOCAL aBRUHead
LOCAL aCabBRU
LOCAL aChave
Local aDifSize:= {,,,,35,3,,}//array com dimenções para correção de telas na versão 12

LOCAL aBRTAcols
LOCAL aBRTHead
LOCAL aVetTrab
Local nUsado   := 0
Local nX := 0
DEFAULT cChaveBRU := "0000"

STATIC oBrwBRU
/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Definicao do Dialog e todos os seus componentes.                        ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

DEFINE MSDIALOG oDlg TITLE STR0006 FROM 091,232 To 541,945 of oMainWnd PIXEL //Tabela de Custo de Internação X Co-participação

// MONTA A ENCHOICE
dbSelectArea("BRT")
dbSetOrder(1)

If dbSeek(xFilial("BRT")+cChaveBRU)
	Copy "BRT" To Memory Blank

	M->BRT_FILIAL := BRT->BRT_FILIAL
	M->BRT_CODIGO := BRT->BRT_CODIGO
	M->BRT_NOME   := BRT->BRT_NOME
	M->BRT_VIGINI := BRT->BRT_VIGINI
	M->BRT_VIGFIM := BRT->BRT_VIGFIM
Else

	Copy "BRT" To Memory Blank
Endif

@ 007,010 SAY STR0007 SIZE 400,010 PIXEL OF oDlg //Informações da Tabela

if Val(GetVersao(.F.)) >= 12 //Valida versão 12
	oEnchoice := MSMGET():New("BRT",1,nOpc,,,,,{35,010,080,350},,,,,,oDlg,,.T.,.F.)
Else
	oEnchoice := MSMGET():New("BRT",1,nOpc,,,,,{15,010,080,350},,,,,,oDlg,,.T.,.F.)
Endif



// MONTA O GRID DE FAIXAS DA TABELA

Store Header "BRU" TO aBRUHead For .T.

dbSelectArea("BRU")
dbSetOrder(1)

If dbSeek(xFilial("BRU")+cChaveBRU)

	Store COLS "BRU" TO aBRUAcols FROM aBRUHead VETTRAB aVetTrab ;
	While xFilial("BRU")+BRU->(BRU_CODIGO) == xFilial("BRU")+cChaveBRU
Else

	Store COLS Blank "BRU" TO aBRUAcols FROM aBRUHead
Endif

@ 080,010 SAY STR0008 SIZE 400,010 PIXEL OF oDlg //Faixas de Custo de Internação X Custo Operacional
if Val(GetVersao(.F.)) >= 12 //Valida versão 12
	oBrwBRU := TPLSBrw():New(88,010,350,210,.F.  ,oDlg,nil,,.T.    ,nil, .T.    ,nil  ,nil,.T.,nil,aBRUHead,aBRUAcols,.F.,"BRU",nOpc,"Itens",nil,nil,nil,aVetTrab,,,,,,,,,,,,,aDifSize)
Else
	oBrwBRU := TPLSBrw():New(095,010,350,205,.F.  ,oDlg,nil,,.T.    ,nil, .T.    ,nil  ,nil,.T.,nil,aBRUHead,aBRUAcols,.F.,"BRU",nOpc,"Itens",nil,nil,nil,aVetTrab)
Endif


If nOpc == K_Alterar

	nLin := LEN(oBrwBRU:aVetTrab)
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IF(Obrigatorio(oEnchoice:aGets,oEnchoice:aTela),Eval({|| oDlg:End()}) ,(nOpca:=0,.F.))},{|| (nOpca:=1,.F.),oDlg:End()}) CENTERED

//Salva os dados
If nOpca == 0

	//Salva Inclusão
	If nOpc == K_Incluir
		aChave := {}
				AaDd(aChave,{"BRU_VLRINI",BRU->BRU_VLRINI})
				AaDd(aChave,{"BRU_VLRFIM",BRU->BRU_VLRFIM})
				AaDd(aChave,{"BRU_CODIGO" ,M->BRT_CODIGO})
				AaDd(aChave,{"BRU_VLRCOP",BRU->BRU_VLRCOP})
				oBrwBRU:Grava(aChave)

		PLUPTENC("BRT",3)

		MsgAlert(STR0009) //Tabela salva com sucesso

	ElseIf nOpc == K_Alterar

		//Salva alteração no cabeçalho
		dbSelectArea("BRT")
		dbSetOrder(1)
		If dbSeek(xFilial("BRT")+cChaveBRU)

			If BRT->BRT_NOME != M->BRT_NOME .OR. BRT->BRT_VIGINI != M->BRT_VIGINI .OR. BRT->BRT_VIGFIM != M->BRT_VIGFIM

				BRT->(RecLock("BRT",.F.))
	   			BRT->BRT_NOME := M->BRT_NOME
		   		BRT->BRT_VIGINI := M->BRT_VIGINI
		   		BRT->BRT_VIGFIM := M->BRT_VIGFIM
		   		BRT->(MSUnlock())

		   		lAter := .T.
	   		EndIf
		EndIf

		If oBrwBRU:lAltered

			dbSelectArea("BRU")
			dbSetOrder(1)

			If dbSeek(xFilial("BRU")+cChaveBRU) .OR. BRU->(EOF())

				  //Salvar alteração nas linhas existentes
				  while xFilial("BRU")+BRU->BRU_CODIGO == xFilial("BRU")+cChaveBRU

				  	 AaDd(aRecno, BRU->(Recno()))
				  	 BRU->(dbSkip())
				  EndDo

				 For nLin := 1 To Len(aRecno)

		          	BRU->(DbGoTo(aRecno[nLin]))
				 	BRU->(RecLock("BRU",.F.))
		   			BRU->BRU_VLRINI := oBrwBRU:aCols[nLin][GdFieldPos("BRU_VLRINI",oBrwBRU:oBrowse:aHeader)]
			   		BRU->BRU_VLRFIM := oBrwBRU:aCols[nLin][GdFieldPos("BRU_VLRFIM",oBrwBRU:oBrowse:aHeader)]
			   		BRU->BRU_VLRCOP := oBrwBRU:aCols[nLin][GdFieldPos("BRU_VLRCOP",oBrwBRU:oBrowse:aHeader)]
			   		BRU->(MSUnlock())

			   		nLin2++

			   		AaDd(aDel, {oBrwBRU:aCols[nLin][4], aRecno[nLin]})
				 Next

	   			//Grava as novas linhas criadas no GRID de tabelas existentes
		   		While LEN(oBrwBRU:aCols) > nLin2

		   			nLin2++
		   			BRU->(RecLock("BRU",.T.))
		   			BRU->BRU_FILIAL := xFilial("BRU")
		   			BRU->BRU_CODIGO :=  BRT->BRT_CODIGO
			   		BRU->BRU_VLRINI := oBrwBRU:aCols[nLin2][GdFieldPos("BRU_VLRINI",oBrwBRU:oBrowse:aHeader)]
			   		BRU->BRU_VLRFIM := oBrwBRU:aCols[nLin2][GdFieldPos("BRU_VLRFIM",oBrwBRU:oBrowse:aHeader)]
			   		BRU->BRU_VLRCOP := oBrwBRU:aCols[nLin2][GdFieldPos("BRU_VLRCOP",oBrwBRU:oBrowse:aHeader)]
			   		BRU->(MSUnlock())

			   		AaDd(aDel, {oBrwBRU:aCols[nLin][4], BRU->(Recno())})
		   		EndDo

		   		//Deleta as linhas excluidas do GRID
				dbSelectArea("BRU")
				dbSetOrder(1) //BRU_FILIAL, BRU_CODIGO, BRU_VLRINI, BRU_VLRFIM, BRU_VLRCOP
				nUsado   := Len(oBrwBRU:oBrowse:aHeader)
				For nX := 1 To Len(oBrwBRU:oBrowse:aCols)
					If oBrwBRU:oBrowse:aCols[nX][nUsado+1]
			   			If BRU->(DbSeek(xFilial("BRU")+oBrwBRU:oBrowse:aCols[nX][1]+AllTrim(Str(oBrwBRU:oBrowse:aCols[nX][2]))+;
			   					Str(oBrwBRU:oBrowse:aCols[nX][3])))//+allTrim(Str(oBrwBRU:oBrowse:aCols[nX][4]))))
							BRU->(Reclock("BRU",.F.))
							BRU->(DbDelete())
							BRU->(MsUnlock())
			   			Endif
		   			Endif
	   			Next nX

				lAter := .T.

	   		EndIf
	   	EndIf

	   	If lAter
	   		MsgAlert(STR0010) //"Tabela alterada com sucesso"
	   	Else
	   		MsgAlert(STR0011) //"Não houve alteração na tabela"
	   	EndIf
	EndIf
EndIf

BRU->(dbCloseArea())
BRT->(dbCloseArea())

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSVLDTB ³ Autor ³ Thiago Guilherme	³ Data ³ 20.10.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida campos do cadastro de faixas                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLDTB(nTipVal)

LOCAL cFaixa
LOCAL nCont

If nTipVal == 1

	If !EMPTY(M->BRU_VLRFIM)
		If M->BRU_VLRINI > M->BRU_VLRFIM
			MsgAlert(STR0012) //A faixa de custo inicial é maior que a faixa de custo final
			Return .F.
		EndIf
	EndIf
	cFaixa := BRT->BRT_CODIGO+Transform(M->BRU_VLRINI, "@E 999,999.99")+Transform(M->BRU_VLRFIM, "@E 999,999.99")

	//Verifica se existe a faixa no banco de dados
	dbSelectArea("BRU")
	dbSetOrder(1)
	If dbSeek(xFilial("BRU")+cFaixa)
		MsgAlert(STR0013) //A faixa inicial e final inclusas já existe nesta tabela
		Return .F.
	EndIf

	//Verifica se existe a faixa no GRID
	For nCont := 1 To len(oBrwBRU:aVetTrab)
		If oBrwBRU:aVetTrab[nCont] == 0

			If	oBrwBRU:obrowse:acols[nCont][GdFieldPos("BRU_VLRINI",oBrwBRU:oBrowse:aHeader)] == M->BRU_VLRINI .AND. ;
				oBrwBRU:obrowse:acols[nCont][GdFieldPos("BRU_VLRFIM",oBrwBRU:oBrowse:aHeader)] == M->BRU_VLRFIM

				MsgAlert(STR0019) //A faixa inicial e final inclusas já existe nesta tabela
				Return .F.
			EndIf
		EndIf
	Next

ElseIf nTipVal == 2

	//Validação de data inicial e final
	If !EMPTY(M->BRT_VIGFIM)
		If M->BRT_VIGINI > M->BRT_VIGFIM
			MsgAlert(STR0014) //Data de vigência inicial é maior que a data de vigência final
			Return .F.
		EndIf
	EndIf
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSEXCTAB ³ Autor ³ Thiago Guilherme	³ Data ³ 20.10.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclui Tabela						                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSEXCTAB()
Local aAreaBHG	:= BHG->(GetArea())
Local aAreaBHJ	:= BHJ->(GetArea())

If  Aviso(	STR0015, ;// Inter. X CoPart.
 			STR0016, ; //Confirmar exclusão da tabela de Internação X Coparticipação?, ;
 	     { STR0017, STR0018}, 2 ) == 1 //"Sim"###"Nao"
	dbSelectArea("BHG")
	dbSetOrder(2)//BHG_FILIAL, BHG_TABCOP
	If BHG->(dbSeek(xFilial("BHG")+BRT->BRT_CODIGO))
		MsgInfo(STR0020) //"Esta tabela está vinculada ao cadastro Grp/Emp x Contrato x Co-Part. da tabela BHG"
		RestArea(aAreaBHG)
		Return
	Else
		dbSelectArea("BHJ")
		dbSetOrder(2)//BHJ_FILIAL, BHJ_TABCOP
		If BHJ->(dbSeek(xFilial("BHJ")+BRT->BRT_CODIGO))
			MsgInfo(STR0021) //"Esta tabela está vinculada ao cadastro Produtos CoParticipação da tabela BHJ"
			RestArea(aAreaBHJ)
			Return
		EndIf
	EndIf

	Begin Transaction
		While BRU->(dbSeek(xFilial("BRU")+BRT->BRT_CODIGO))
			BRU->(Reclock("BRU",.F.))
			BRU->(DbDelete())
			BRU->(MsUnlock())
		Enddo

		If BRT->(dbSeek(xFilial("BRT")+BRT->BRT_CODIGO))
			BRT->(Reclock("BRT",.F.))
			BRT->(DbDelete())
			BRT->(MsUnlock())
		EndIf
	End Transaction
EndIf

Return
