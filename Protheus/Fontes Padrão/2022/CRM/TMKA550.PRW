#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA550.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA550   ºAutor  ³Vendas CRM          º Data ³  19/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cadastro de Itens de habilidade X Habilidade                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA550                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMKA550() 

Private aRotina := MenuDef()
Private cCadastro := STR0001 //"Habilidade x It. Habilidade"

dbSelectArea("AGN")
dbSetOrder(1)

mBrowse(,,,,"AGN")

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef   ³ Autor ³ Vendas CRM            ³ Data ³19/11/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMK                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()

Local aRotina := {	{STR0002	,"AxPesqui",0,1},;	//"Pesquisar"
		            {STR0003	,"TK550Mnt",0,2},;	//"Visualizar"
		            {STR0004	,"TK550Mnt",0,3},;	//"Incluir"
		            {STR0005	,"TK550Mnt",0,4},;	//"Alterar"
		            {STR0006	,"TK550Mnt",0,5}}	//"Excluir"
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK550Mnt  ºAutor  ³Vendas CRM          º Data ³  19/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de manutencao das habilidades X itens de habilidade  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA550                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK550Mnt(cAlias, nReg, nOpc)

Local aCoors 	:= FWGetDialogSize(oMainWnd)	// Dimensoes da tela na resolucao atual
Local aHeader	:= {}
Local aCols		:= {}

Local lConf		:= .F.							// Indica se o usuario confirmou a tela

Local oDlg		:= Nil							// Objeto contendo dialogo principal
Local oLayer	:= Nil							// Controle de paineis da dialog
Local oCabec	:= Nil							// Painel superior
Local oItens	:= Nil							// Painel inferior
Local oEnch		:= Nil							// Objeto da Enchoice

Local nOpcGd	:= 0							// Opcao de edicao da getdados
Local nX		:= 0							// Auxiliar de loop
Local cTudoOk	:= ".T."									// Validacao da tela
Local bOk		:= &("{|| "+cTudoOk+"}")					// Codeblock executado na finalizacao da tela
Local nSaveSX8	:= GetSX8Len()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a Variaveis da Enchoice.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("AGN",INCLUI,.T.)
                                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta vetores da getdados do DA1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSeek 	:= 	xFilial("AGO")+M->AGN_COD
bWhile	:=	{||AGO->AGO_FILIAL+AGO->AGO_COD}
FillGetDados(nOpc,"AGO",1,cSeek,bWhile,,,,,,,,@aHeader,@aCols,{|a,b|Tk550AfCol(a,b)})

nOpcGD 	:= IIF(!INCLUI.And.!ALTERA,0,GD_INSERT+GD_UPDATE+GD_DELETE)
nX		:=  aScan(aHeader,{|x|AllTrim(x[2]) == "AGO_ITEM"})

If (nX > 0) .AND. (Len(aCols) == 1) .AND. Empty(aCols[1][nX])
	aCols[1][nX]	:= StrZero(1,TamSX3("AGO_ITEM")[1])
EndIf

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL

oLayer := FwLayer():New()
oLayer:init(oDlg,.F.)

oLayer:addLine("CABECALHO"	, 30, .T.)
oLayer:addLine("ITENS"		, 60, .T.)

oCabec	:= oLayer:getLinePanel("CABECALHO")
oItens	:= oLayer:getLinePanel("ITENS")

oEnch := MsMGet():New("AGN",nReg,nOpc,,,,,{0,0,500,700},,3,,,cTudoOk,oCabec)

oGetD := MsNewGetDados():New(0,0,500,1000,nOpcGD,"AllWaysTrue()","AllWaysTrue()" ,"+AGO_ITEM",,,,,,,oItens,aHeader,aCols)

oEnch:oBox:Align 	:= CONTROL_ALIGN_ALLCLIENT
oGetD:oBrowse:Align	:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, {|| Iif(Obrigatorio(oEnch:aGets,oEnch:aTela),(lConf := .T.,oDlg:End()), ) }, {|| lConf := .F.,oDlg:End() } )

If lConf .AND. nOpc <> 2
	BEGIN TRANSACTION
	Tk550Grv(nOpc,@oGetD) 
	While ( GetSX8Len() > nSaveSx8 )
		ConfirmSX8()
	EndDo
	END TRANSACTION
ElseIf nOpc <> 2
	While (GetSx8Len() > nSaveSx8 )		
		RollBackSx8()
	EndDo
EndIf	

Return Nil  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk550Grv  ºAutor  ³Vendas CRM          º Data ³  19/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gravacao das tabelas AGN e AGO                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA550                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk550Grv(nOpc,oGet)

Local nCntFor
Local aAreaSX3	:=	SX3->(GetArea())
Local aRecDele	:=	{}
Local nLin		:= 0
Local nCpo		:= 0
Local nPosRecNo	:= aScan(oGet:aHeader,{|x|AllTrim(x[2])=="AGO_REC_WT"})
Local nPosChave	:= aScan(oGet:aHeader,{|x|AllTrim(x[2])=="AGO_ITHAB"})
                      
SX3->(DbSetOrder(1))
SX3->(DbSeek("AGN"))

If (nOpc==3) .OR. (nOpc==4)
                      
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualizacao do Cabecalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AGN")
	dbSetOrder(1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³RecLock considerando inclusao ou alteracao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("AGN",!DbSeek(xFilial("AGN")+M->AGN_COD))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Descarga dos campos na tabela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "AGN"
		If ( AllTrim(SX3->X3_CAMPO) =="AGN_FILIAL" )
			AGN->AGN_FILIAL := xFilial("AGN")
		ElseIf SX3->X3_CONTEXT <> "V"
			AGN->&(SX3->X3_CAMPO) := M->&(SX3->X3_CAMPO)
		EndIf  
		SX3->(DbSkip())
	End  
	
	MsUnLock()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao dos itens³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("AGO") 
	
	For nLin := 1 to Len(oGet:aCols)
		If !aTail(oGet:aCols[nLin])
			If !Empty(oGet:aCols[nLin][nPosChave])

				If oGet:aCols[nLin][nPosRecNo] > 0
					dbGoto(oGet:aCols[nLin][nPosRecNo])
					RecLock("AGO",.F.)
				Else
					RecLock("AGO",.T.)
				EndIf

				For nCpo := 1 To Len(oGet:aHeader)
					If (oGet:aHeader[nCpo][10] != "V" )
						AGO->&(oGet:aHeader[nCpo][2]) := oGet:aCols[nLin][nCpo]
					EndIf
				Next nCpo

				AGO->AGO_FILIAL	:= xFilial("AGO")
				AGO->AGO_COD	:= M->AGN_COD

				MsUnlock()

			EndIf
		Else
			If oGet:aCols[nLin][nPosRecNo] > 0
			
				dbGoto(oGet:aCols[nLin][nPosRecNo])
				RecLock("AGO",.F.,.T.)
				dbDelete()
				MsUnlock()        
				
			EndIf
		EndIf
	
	Next nLin
	
ElseIf (nOpc==5)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apaga registros do AGO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbSelectArea("AGO")
	DbSetOrder(1)
	DbSeek(xFilial("AGO")+AGO->AGO_COD)
	
	While !AGO->(Eof())						.And.;
		AGO->AGO_FILIAL	==	xFilial("AGO")	.And.;
		AGO->AGO_COD	==	AGN->AGN_COD
		
		AAdd(aRecDele,AGO->(Recno()))
		
		AGO->(DbSkip())
		
	End 
	
	For nLin := 1 to Len(aRecDele)
		
		AGO->(DbGoTo(aRecDele[nLin]))
		RecLock("AGO",.F.)
		DbDelete()
		MsUnLock()

	Next nLin
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apaga registro do AGN³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("AGN")
	RecLock("AGN",.F.)
	DbDelete()
	MsUnLock()

End
	
RestArea(aAreaSX3)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk550AfColºAutor  ³Vendas CRM          º Data ³  22/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina utilizar para inserir informacoes no acols apos sua  º±±
±±º          ³criacao                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKA550                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk550AfCol(aCols,aHeader)

Local nX  		:= 0
Local nPosItem	:= aScan(aHeader,{|x|AllTrim(x[2]) == "AGO_ITHAB" })
Local nPosDesc	:= aScan(aHeader,{|x|AllTrim(x[2]) == "AGO_DSCITE" })

If nPosItem > 0 .AND. nPosDesc > 0
	For nx := 1 to Len(aCols)
		aCols[nX][nPosDesc] := Posicione("AGM",1,xFilial("AGM")+aCols[nX][nPosItem],"AGM_DESCRI")
	Next nX
EndIf

Return .T.