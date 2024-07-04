#INCLUDE "PCOA016.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA016	บAutor  ณMicrosiga           บ Data ณ  11/26/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Projeto Orcamentario	                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA016()
	Private aRotina 	:= MenuDef()	//Menu
	Private	lPermit		:= FVldUsPJ()	//Usuario Gerenciador de projeto (.T. or .F.)
	Private cCadastro	:= STR0001 		//"Projeto Orcamentario"

	mBrowse(6,1,22,75,"AMX")

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef	บAutor  ณMicrosiga           บ Data ณ  11/26/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Menu                                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO	                                          	      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
	Local aRotina 	:= {{ STR0002		,"AxPesqui"  	,0,1},; 	//"Pesquisar"
						{ STR0003		,"AxVisual" 	,0,2} ,; 	//"Visualizar"
					   	{ STR0004	   	,"PCOA016DLG" 	,0,3} ,; 	//"Incluir"
						{ STR0005		,"PCOA016EST" 	,0,4} ,; 	//"Editar"
					   	{ STR0006		,"PCOA016DLG" 	,0,5}}   	//"Excluir"
Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFVldUsPJ	บAutor  ณMicrosiga           บ Data ณ  10/22/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica acesso de edi็ใo do projeto                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FVldUsPJ()
	Local lRet		:= .F.
	Local alUser	:= Separa(GetMv("MV_PCOPRO",,"000000"),";")
	If aScan(alUser,{|x| Alltrim(x) == __cUserId}) <> 0
		lRet := .T.
	EndIf
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA016DLGบAutor  ณJair Ribeiro        บ Data ณ  11/27/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA016DLG(cAlias,nReg,nOpc)
	Local cPlanilha := AMX->AMX_CODIGO
	Local lExclui	:= .F.
	Local bVldEx 	:= {|| lExclui := MsgNoYes(STR0007)} //"Deseja realmente excluir o Projeto Or็amentแrio? Todos seus vinculos serao excluidos!"

	If lPermit
		If nOpc == 3
	   		AxInclui(cAlias,nReg,nOpc,,"PCOA016CLS",,,,,,,,.T.,CONTROL_ALIGN_LEFT)
	 	ElseIf nOpc == 5
	    	AMY->(DbSetOrder(1))
	    	If AMY->(DbSeek(xFilial("AMY")+AMX->AMX_CODIGO))
				Aviso(STR0008,STR0009,{STR0010}) //"Aten็ใo"###"Nใo ้ possivel excluir, Projeto Or็amentแrio com unidades vinculadas"###"Ok"
			Else
				AxDeleta(cAlias,nReg,nOpc,,,,{{|| .T.},bVldEx,{|| .T.},{|| .T.}},,.T.)
				If lExclui
					DbSelectArea("AMV")
					AMV->(DbSetOrder(1))
					While 	AMV->(DbSeek(xFilial("AMV")+cPlanilha))
						RecLock("AMV",.F.,.T.)
						dbDelete()
						MsUnlock()
					EndDo
				EndIf
			EndIf
		EndIf
	Else
		Aviso(STR0008,STR0011,{STR0010}) //"Aten็ใo"###"Usuario sem permissao para cadastrar projeto"###"OK"
	EndIf
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA016CLSบAutor  ณJair Ribeiro        บ Data ณ  10/25/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo utilizada para limpar as variaveis que serใo usadas บฑฑ
ฑฑบ          ณ pelo axInclui da rotina principal                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA016CLS()
	M->AMX_DSCPLN	:= ""
	M->AMX_DTENC 	:= STOD("")
	M->AMX_TOTAL 	:= 0
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |PCOA016ESTบAutor  ณJair Ribeiro        บ Data ณ  10/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Estrutura do Projeto                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA016EST() //PCOA016FW
	Local alDmsWin		:= FWGetDialogSize(oMainWnd) 	//Dimensใo da tela - oDlgFw
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Objetos	                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local oDlgFw		:= Nil
	Local oBtnFw		:= FWButtonBar():new()
	Local oPanelI		:= Nil
	Local oPanelL1		:= Nil
	Local oSayCP		:= Nil
	Local oPanelL21		:= Nil
	Local oPanelL22		:= Nil
	Local oPanelL31		:= Nil
	Local oPanelL32		:= Nil

	Private oFWLayer	:= Nil
	Private oLayout1	:= Nil
	Private oLayout2	:= Nil
	Private oLayout3	:= Nil
	Private oEnch1		:= Nil
	Private oEnch2		:= Nil
	Private oEnch3		:= Nil
	Private oTree		:= Nil
	Private lTela		:= .T.                            	//Verifica se existe alguma Dialog aberta


	DbSelectArea("AMX")
	oDlgFw :=MSDialog():New(alDmsWin[1],alDmsWin[2],alDmsWin[3],alDmsWin[4], STR0012,,,,nOr(WS_VISIBLE,WS_POPUP),,,,oMainWnd,.T.) //"Projeto Or็amentario"
		oFWLayer:=FWLayer():new()
		oFWLayer:Init(oDlgFw,.T.)

		oFWLayer:addCollumn('CollxT',35,.F.)
		oFWLayer:addWindow('CollxT','WindxT',STR0013,97,.T.,.T.) //"Configura็๕es do Projeto"
		oPanelI:=oFWLayer:getWinPanel('CollxT','WindxT')
		oPanelI:FreeChildren()
		oFWLayer:SetColSplit('CollxT',CONTROL_ALIGN_RIGHT)

		oTree			:= xTree():New(,,,,oFWLayer:GetWinPanel('CollxT','WindxT'))
		oTree:Align		:= CONTROL_ALIGN_ALLCLIENT

		FConstTree(AMX->AMX_CODIGO)


		//Coluna que conterแ os layouts
		oFwLayer:addCollumn('CollCt',65,.T.)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณLayout 1                                                                                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oLayout1:=FWLayer():new()
		oLayout1:Init(oFWLayer:GetColPanel('CollCt'),.F.)
		oLayout1:addCollumn('CollL1',97,.T.)
		oLayout1:addWindow('CollL1','WindL1',STR0014,97,.T.,.T.) //"Detalhes"
		oPanelL1:=oLayout1:getWinPanel('CollL1','WindL1')
		oPanelL1:FreeChildren()
	   	oSayCP:= tSay():New(,,{|| FTextPro()},oLayout1:getWinPanel('CollL1','WindL1'),,oLayout1:getWinPanel('CollL1','WindL1'):oFont,,,,.T.)
   		oSayCP:lTransparent := .F.
		oSayCP:Align := CONTROL_ALIGN_ALLCLIENT
	   	oLayout1:Show()

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณLayout 2  - Projeto                                                                        ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oLayout2:=FWLayer():new()
		oLayout2:Init(oFWLayer:GetColPanel('CollCt'),.F.)
		oLayout2:addCollumn('CollL2',97,.T.)
		oLayout2:addWindow('CollL2','WindL21',STR0014,39,.T.,.T.) 	//Detalhes
		oLayout2:addWindow('CollL2','WindL22',STR0015,58,.T.,.T.) //"Projeto do Or็amento"
		oPanelL21:=oLayout2:getWinPanel('CollL2','WindL21')
		oPanelL22:=oLayout2:getWinPanel('CollL2','WindL22')
		oPanelL21:FreeChildren()
		oPanelL22:FreeChildren()
	   	oSayCP:= tSay():New(,,{|| FTextPro()},oLayout2:getWinPanel('CollL2','WindL21'),,oLayout2:getWinPanel('CollL2','WindL21'):oFont,,,,.T.)
   		oSayCP:lTransparent := .F.
		oSayCP:Align := CONTROL_ALIGN_ALLCLIENT
	   	oLayout2:Hide()
	   	RegToMemory("AMX",.T.)
		oEnch1 := Msmget():New("AMX",0,3,,,,,{015,003,365,362},{},3,,,.T.,oPanelL22,,.T.)
		oEnch1:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT


		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณLayout 3 - Unidade                                                                         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oLayout3:=FWLayer():new()
		oLayout3:Init(oFWLayer:GetColPanel('CollCt'),.F.)
		oLayout3:addCollumn('CollL3',97,.T.)
		oLayout3:addWindow('CollL3','WindL31',STR0014,39,.T.,.T.)				//Detalhes
		oLayout3:addWindow('CollL3','WindL32',STR0016,58,.T.,.T.) //"Unidade do Or็amento"
		oPanelL31:=oLayout3:getWinPanel('CollL3','WindL31')
		oPanelL32:=oLayout3:getWinPanel('CollL3','WindL32')
		oPanelL31:FreeChildren()
		oPanelL32:FreeChildren()
		oSayCP:= tSay():New(,,{|| FTextUn()},oLayout3:getWinPanel('CollL3','WindL31'),,oLayout3:getWinPanel('CollL3','WindL31'):oFont,,,,.T.)
   		oSayCP:lTransparent := .F.
		oSayCP:Align := CONTROL_ALIGN_ALLCLIENT
	   	oLayout3:Hide()
   		RegToMemory("AMF",.T.)
		oEnch2 := Msmget():New("AMF",0,3,,,,,{015,003,365,362},{},3,,,.T.,oPanelL32,,.T.)
	   	oEnch2:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT

	 	oBtnFw:Init(oPanelI,15,15,CONTROL_ALIGN_BOTTOM,.T.)
		oBtnFw:addBtnImage("FINAL.PNG"		,STR0017	,{|| oDlgFw:End()},, .T.,CONTROL_ALIGN_RIGHT) //"Sair"

		//Acrescentado por Fernando Radu Muscalu em 09/09/2011 - Mostrar os dados do Projeto
		FPanelPro(AMX->AMX_CODIGO)

	oDlgFw:Activate(,,,.T.,,,)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCO016CODPบAutor  ณMicrosiga           บ Data ณ  11/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida cadastro de projeto do orcamento                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCO016CODP()
	Local lRet := .T.
	Local Area := AMX->(GetArea())
	DbSelectArea("AMX")
	AMX->(DbSetOrder(1))
	If AMX->(DbSeek(xFilial("AMX")+M->AMX_CODIGO))
		lRet := .F.
		Aviso(STR0008,STR0018,{STR0010})//"Aten็ใo"###"Este c๓digo esta em uso em outro projeto"###"OK"
	EndIf
	RestArea(Area)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFTextPro	บAutor  ณJair Ribeiro        บ Data ณ  10/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Texto descri็ใo  projeto	                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO    	                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FTextPro()
	Local cSayHTML
	cSayHTML :=	"<H1>"
	cSayHTML += STR0019 //"Configura็ใo de Projetos"
	cSayHTML +=	"</H1>"
	cSayHTML +=	"<FONT size=+1>"
	cSayHTML +=	STR0020 //"O projeto Or็amentแrio permite aos responsแveis uma visใo gerencial do or็amento nas organiza็๕es,"
	cSayHTML +=	STR0021 //"permitindo ter a flexibilidade de realizar projetos especํficos que possam ser necessแrios no decorrer de"
	cSayHTML +=	STR0022 //"um exercํcio, ou at้ mesmo a divisใo do or็amento por suas franquias ou filiais, como um projeto"
	cSayHTML +=	STR0023 //"or็amentแrio  para aquisi็ใo de uma nova empresa, por exemplo. Tamb้m proporcionarแ aos gestores o"
	cSayHTML += STR0024 //"controle do or็amento de suas Unidades" //"controle do or็amento de suas Unidades"
	cSayHTML +=	"</FONT>"
Return cSayHTML
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FTextUn   บAutor  ณJair Ribeiro        บ Data ณ  10/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Texto descri็ใo unidade                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FTextUn()
	Local cSayHTML
	cSayHTML :=	"<H1>"
	cSayHTML += STR0025  //"Unidade Or็amentaria"
	cSayHTML +=	"</H1>"
	cSayHTML +=	"<FONT size=+1>"
	cSayHTML +=	STR0026 //"A unidade organizacional ้ usada para separar a estrutura empresarial e hierแrquica de organiza็๕es e suas filiais ou"
	cSayHTML +=	STR0027 //"franquias ้ muito utilizada para separar holdings e suas orgqniza็๕es tamb้m pode ser utilizada para escalas dentro"
	cSayHTML +=	STR0028 //"de um projeto organizacional para separar meses, separa lํderes e em diversos outros casos em que se aplicar"
	cSayHTML +=	STR0029 //"O nome da Unidade Organizacional serแ composta por seu c๓digo e descri็ใo, ex 001 - Filial Sul, uma vez amarrado "
	cSayHTML += STR0030 //"e utilizada, uma unidade organizacional nใo pode ser alterada, nem excluida."
	cSayHTML +=	"</FONT>"
Return cSayHTML
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FPanelPro บAutor  ณJair RIbeiro		 บ Data ณ  10/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Painel do Projeto                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FPanelPro(cProjeto)
	Local nlI	:= 0
	DbSelectArea("AMX")
	DbSetOrder(1)
	If DbSeek(xFilial("AMX")+cProjeto)
		RegToMemory("AMX", .F.,,, FunName())
	    For nlI := 1 To FCount()
    		M->&(FieldName(nlI)) := &("AMX->"+(FieldName(nlI)))
		Next nlI
		oEnch1:Refresh()
	    FLayout("oLayout2")
	 EndIf
	 AMM->(DbCloseArea())
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFPanelUnidบAutor  ณJair Ribeiro        บ Data ณ  10/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Painel da Unidade                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FPanelUnid(cUnidade)
	Local nlI	:= 0
   	Local nPos	:= 0
   	Local cProj	:= FRetProj()

	DbSelectArea("AMF")
	DbSetOrder(1)
	If DbSeek(xFilial("AMF")+cUnidade)
		RegToMemory("AMF", .F.,,, FunName())
	    For nlI := 1 To FCount()
    		M->&(FieldName(nlI)) := &("AMF->"+(FieldName(nlI)))
		Next nlI
		oEnch2:Refresh()
	    FLayout("oLayout3")
	 EndIf
	 AMF->(DbCloseArea())
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFLayout   บAutor  ณJair Ribeiro        บ Data ณ  10/17/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Layout a ser exibido                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FLayout(cLayout)
	Local alLayout 	:={"oLayout1","	oLayout2","oLayout3"}
    Local nlI		:= 0
	For nlI := 1 to Len(alLayout)
		&(alLayout[nlI]+":Hide()")
	Next nlI
	&(cLayout+":Show()")
Return Nil

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFunctions para contrucao da arvore e inclusใo de novos noh na arvore					 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFConstructบAutor  ณMicrosiga           บ Data ณ  10/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para inclusใo de novo noh Projeto ou Unidade	      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FConstruct(nTipo)
 	Local cPrompt	:= ""

 	If	nTipo == 1		// Inclusao de No para Novo Projeto
		If Empty(M->AMX_PLNORC)
			cPrompt := ALLTRIM(M->AMX_CODIGO) +" - "+ ALLTRIM(M->AMX_DESCRI)
		Else
		cPrompt := ALLTRIM(M->AMX_CODIGO) +" - "+ ALLTRIM(M->AMX_DESCRI)+STR0031+ ALLTRIM(M->AMX_PLNORC) +" - "+ ALLTRIM(AK1->(GetAdvFVal("AK1","AK1_DESCRI",xFilial("AK1")+M->AMX_PLNORC,1))) //" | PLN ORC: "
		EndIf

		If oTree:IsEmpty()
			oTree:AddItem(cPrompt,"P"+M->AMX_CODIGO,'FOLDER5','FOLDER6',1,{|| FPanelPro(STUFF(oTree:GetCargo(),1,1,''))},{|oTree,x,y| FPopUp(oTree,oFWLayer,1,x,y)})
		ElseIf oTree:TreeSeek(oTree:aCargo[1,1])
			oTree:AddItem(cPrompt,"P"+M->AMX_CODIGO,'FOLDER5','FOLDER6',1,{|| FPanelPro(STUFF(oTree:GetCargo(),1,1,''))},{|oTree,x,y| FPopUp(oTree,oFWLayer,1,x,y)})
		EndIf

	ElseIf nTipo == 2		// Inclusao de item para Unidade Orcamentaria.
		cPrompt	:= ALLTRIM(M->AMY_CODUNI) +" - "+ ALLTRIM(M->AMY_UNIDAD)
		oTree:AddItem(cPrompt,"U"+M->AMY_CODUNI,"MDIVISIO","MDIVISIO",2,{|| FPanelUnid(STUFF(oTree:GetCargo(),1,1,''))},{|oTree,x,y| FPopUp(oTree,oFWLayer,2,x,y)})
	EndIf
	INCLUI := .F.
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FConstTreeบAutor  ณJair Ribeiro        บ Data ณ  10/17/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta tree caso haja informa็ใo no banco                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FConstTree(cProjeto)
	Local clPrompt 		:= ""
	Local clQry 		:= ""
	Local Area			:= AMX->(GetArea())

	AMX->(DbSetOrder(1))
	//While AMX->(!EOF())
	If AMX->(DbSeek(xFilial("AMX")+cProjeto))
		If !Empty(AMX->AMX_PLNORC)
			If lPermit .or. FVldUsPln(AMX->AMX_PLNORC)
				clPrompt := ALLTRIM(AMX->AMX_CODIGO) +" - "+ ALLTRIM(AMX->AMX_DESCRI)+ STR0031+ ALLTRIM(AMX->AMX_PLNORC) +" - "+ ALLTRIM(AK1->(GetAdvFVal("AK1","AK1_DESCRI",xFilial("AK1")+AMX->AMX_PLNORC,1))) //" | PLN ORC: "
				oTree:AddTree(clPrompt,'FOLDER5','FOLDER6',"P"+AMX->AMX_CODIGO,{|| FPanelPro(STUFF(oTree:GetCargo(),1,1,''))},{|oTree,x,y| FPopUp(oTree,oFWLayer,1,x,y)})
			EndIf
		Else
			clPrompt := ALLTRIM(AMX->AMX_CODIGO) +" - "+ ALLTRIM(AMX->AMX_DESCRI)
			oTree:AddTree(clPrompt,'FOLDER5','FOLDER6',"P"+AMX->AMX_CODIGO,{|| FPanelPro(STUFF(oTree:GetCargo(),1,1,''))},{|oTree,x,y| FPopUp(oTree,oFWLayer,1,x,y)})
		EndIf
 		If Empty(AMX->AMX_PLNORC) .or. lPermit .or. FVldUsPln(AMX->AMX_PLNORC)
 			DbSelectArea("AMY")
		    AMY->(DbGoTop())
		    AMY->(DbSetOrder(1))
    		If AMY->(DbSeek(xFilial("AMY")+AMX->AMX_CODIGO))
	    		While AMY->(!EOF()) .and. AMY->AMY_CODPRO == AMX->AMX_CODIGO
	        		If Empty(AMY->AMY_CCUSTO)
		       			clPrompt 	:= ALLTRIM(AMY->AMY_CODUNI) +" - "+ ALLTRIM(AMY->AMY_UNIDAD)
						oTree:AddTree(clPrompt,'MDIVISIO','MDIVISIO',"U"+AMY->AMY_CODUNI,{|| FPanelUnid(STUFF(oTree:GetCargo(),1,1,''))},{|oTree,x,y| FPopUp(oTree,oFWLayer,2,x,y)})

							clQry:="SELECT AMY.AMY_CCUSTO"
							clQry+=" FROM "+RetSqlName("AMY")+" AMY"
							clQry+=" WHERE AMY.AMY_CODPRO = '"+AMX->AMX_CODIGO+"'"
							clQry+=" AND AMY.AMY_CODUNI = '"+AMY->AMY_CODUNI+"'"
							clQry+=" AND AMY.AMY_CCUSTO <> ''"
							clQry+=" AND AMY.AMY_CCSUP = ''"
							clQry+=" AND AMY.AMY_FILIAL = '"+ xFilial("AMY")+"'"
							clQry+=" AND AMY.D_E_L_E_T_ <> '*'"

							If Select("QAMY")>0
								DbSelectArea("QAMY")
								QAMY->(DbCloseArea())
							EndIf
							clQry := ChangeQuery(clQry)
							dbUseArea(.T.,"TOPCONN",TCGENQRY(,,clQry),"QAMY",.F.,.T.)
							DbSelectArea("QAMY")
					   		If QAMY->(!EOF())
								FConstCTT(AMX->AMX_CODIGO,AMY->AMY_CODUNI,QAMY->AMY_CCUSTO)
							EndIf
						oTree:EndTree()
					EndIf
					AMY->(DbSkip())
				EndDo
			EndIf
			oTree:EndTree()
		EndIf
	    AMX->(DbSkip())
	EndIf
	RestArea(Area)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFConstCTT บAutor  ณJair Ribeiro        บ Data ณ  10/19/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FConstCTT(cProjeto,cUnidade,cCusto)
	Local Area		:= AMY->(GetArea())
	Local clPrompt 	:= ""
	Local llUsCtt	:= .F.

	AMY->(DbSetOrder(2)) //FILIAL+PROJETO+UNIDADE+CCSUP
	If AMY->(DbSeek(xFilial("AMY")+cProjeto+cUnidade+cCusto))
		If lPermit .or. (llUsCtt:= FVldUsCTT(cCusto))
			clPrompt 	:= ALLTRIM(cCusto) +" - "+ ALLTRIM(CTT->(GetAdvFVal("CTT","CTT_DESC01",xFilial("CTT")+cCusto,1)))
   			oTree:AddTree(clPrompt,'SIMULACA','SIMULACA',"C"+cCusto,{|| },{|oTree,x,y| FPopUp(oTree,oFWLayer,3,x,y)})
   		EndIf
   			While AMY->(!EOF()) .and. cCusto == AMY->AMY_CCSUP
   				FConstCTT(cProjeto,cUnidade,AMY->AMY_CCUSTO)
		   		AMY->(DbSkip())
	   		EndDo
		If lPermit .or. llUsCtt
			oTree:EndTree()
		EndIf
 	Else
 		AMY->(DbSetOrder(1))
		If AMY->(DbSeek(xFilial("AMY")+cProjeto+cUnidade+cCusto))
			If lPermit .or. FVldUsCTT(cCusto)
		   		clPrompt 	:= ALLTRIM(cCusto) +" - "+ ALLTRIM(CTT->(GetAdvFVal("CTT","CTT_DESC01",xFilial("CTT")+cCusto,1)))
		   		oTree:AddTreeItem(clPrompt,'SIMULACA',"C"+AMY->AMY_CCUSTO,{|| },{|oTree,x,y| FPopUp(oTree,oFWLayer,3,x,y)})
		 	EndIf
		Endif
	EndIf
	RestArea(Area)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFVldUsCTT บAutor  ณJair Ribeiro        บ Data ณ  10/25/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se usuแrio tem acesso a C.Custo                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FVldUsCTT (cCusto)
	Local llRet 	:= .F.
	Local clUser	:= RetCodUsr()
	Local clCCIni	:= AKX->(GetAdvFVal("AKX","AKX_CC_INI",xFilial("AKX")+clUser,1))
	Local clCCFin	:= AKX->(GetAdvFVal("AKX","AKX_CC_FIN",xFilial("AKX")+clUser,1))

	If !Empty(clCCIni) .and. !Empty(clCCFin)
		If (ALLTRIM(cCusto) >= ALLTRIM(clCCIni)) .and. (ALLTRIM(cCusto) <= ALLTRIM(clCCFin))
			llRet	:= .T.
		EndIf
	EndIf
Return llRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFVldUsPln บAutor  ณJair Ribeiro        บ Data ณ  10/25/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se usuแrio tem acesso a Planilha	              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FVldUsPln(cPln)
	Local llRet		:= .F.
	Local clUser	:= RetCodUsr()
	Local Area		:= AKG->(GetArea())

	DbSelectArea("AKG")
	AKG->(DbSetOrder(2))
	If AKG->(DbSeek(xFilial("AKG")+cPln+clUser))
		llRet	:= .T.
	EndIf
	RestArea(Area)
Return llRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFPopUp	บAutor  ณJair Ribeiro        บ Data ณ  10/18/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Menu PopUp                                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO            	                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FPopUp(oTree,oFWLayer,cType,x,y)
   	Local oMenu		:= Nil
   	Local clPln		:= ""
   	Local xInclui	:= INCLUI

    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Blocos para Menu 1                                        		 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    Local bM1IUnd 	:= {|| AxInclui("AMY",AMY->(RECNO()),3,/*alCpoUn*/,"FPrUn",,,,,,{{||INCLUI := .T. , .T.},{|| FConstruct(2)},{|| .T.},{|| .T.}}	,,,.T.)}
	Local bM1VPln	:= {|| FVincPln()}
	Local bM1CPln	:= {|| Iif(Empty(ALLTRIM(AMX->(GetAdvFVal("AMX","AMX_PLNORC",xFilial("AMX")+STUFF(oTree:GetCargo(),1,1,''),1)))),;
							(INCLUI:=.T.,PCOA100(3)),/*AxInclui("AK1",AK1->(RECNO()),3,,,,,,,,{{|| INCLUI := .T., .T.},{|| FCreatePln()},{|| .T.},{|| .T.}},,,.T.),*/;
							Aviso(STR0008,STR0032,{STR0010})); //"Aten็ใo"###"Projeto jแ estแ vinculado a uma Planilha"###"Ok"
						}

	Local bM1EPln	:= {|| Iif(!Empty(ALLTRIM(clPln := AMX->(GetAdvFVal("AMX","AMX_PLNORC",xFilial("AMX")+STUFF(oTree:GetCargo(),1,1,''),1)))),;
						FOpenPln(clPln,"",4),;
						Aviso(STR0008,STR0033,{STR0010}) ); //"Projeto nใo estแ vinculado a planilha"
						}

	Local bM1DPln	:= {|| FDesvPln()}
	Local bM1FPln	:= {|| Iif(!Empty(ALLTRIM(clPln := AMX->(GetAdvFVal("AMX","AMX_PLNORC",xFilial("AMX")+STUFF(oTree:GetCargo(),1,1,''),1)))),;
						FAltFase(clPln),;
						Aviso(STR0008,STR0033,{STR0010}) ); //"Projeto nใo estแ vinculado a planilha"
						}

    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Blocos para Menu 2                                        		 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    Local bM2DUnd 	:= {|| FDesvUnd()}
	Local bM2VCTT	:= {|| FVincCTT(oTree)}

    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Blocos para Menu 3                                        		 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local bM3DCTT	:= {|| FDesvCTT()}
	Local bM3ECTT	:= {|| FExpCTT()}
	Local bM3VPLN	:= {|| FOpenPln(cPlan,cVPln,2)}
	Local bM3EPLN	:= {|| FOpenPln(cPlan,cVPln,4)}

	Local cProj		:= FRetProj()
	Local cPlan		:= ""
	Local cVPln		:= ""

	Local aArea		:= GetArea()


	If lTela
		Menu oMenu PopUp
			If lPermit
				If cType == 1
					MenuItem STR0034 		Block bM1IUnd //"Vincular Uni. Orc"
					MenuItem STR0035		Block bM1VPln //"Vincular Planilha"
					MenuItem STR0036		Block bM1CPln //"Criar Planilha"
					MenuItem STR0037		Block bM1EPln //Editar Planilha
					MenuItem STR0038		Block bM1DPln //"Desvincular Planilha"
					MenuItem STR0039		Block bM1FPln //"Alterar Fase Planilha"

				ElseIf cType == 2
					MenuItem STR0040 	Block bM2DUnd //"Desvincular Uni. Orc"
					MenuItem STR0041 		Block bM2VCTT //"Vincular C.Custo"

				ElseIf CTT->(POSICIONE("CTT",1,xFilial("CTT")+STUFF(oTree:GetCargo(),1,1,''),"CTT_CLASSE")) == '1'	//Centro de Custo Sintetico]
					MenuItem STR0042		Block bM3DCTT //"Desvincular C.Custo"
					MenuItem STR0043 		Block bM3ECTT //"Expandir C.Custo"

				ElseIf !Empty(cPlan:= AMX->(GetAdvFVal("AMX","AMX_PLNORC",xFilial("AMX")+cProj,1)))
					cVPln:= AK1->(GetAdvFVal("AK1","AK1_VERSAO",xFilial("AK1")+cPlan,1))
					If !Empty (AK2->(GetAdvFVal("AK2","AK2_CC",xFilial("AK2")+cPlan+cVPln+STUFF(oTree:GetCargo(),1,1,''),8)))
						MenuItem STR0042		Block bM3DCTT 	//"Desvincular C.Custo"
						MenuItem STR0043 		Block bM3ECTT	 //"Expandir C.Custo"
				   		MenuItem STR0044		Block bM3VPLN 	//"Visualizar Planilha"
			   			MenuItem STR0045		Block bM3EPLN 	//"Alterar Planilha"
					Else
						MenuItem STR0042		Block bM3DCTT 	//"Desvincular C.Custo"
						MenuItem STR0043 		Block bM3ECTT	//"Expandir C.Custo"
					EndIf
				Else
					MenuItem STR0042		Block bM3DCTT 		//"Desvincular C.Custo"
					MenuItem STR0043 		Block bM3ECTT		//"Expandir C.Custo"
				EndIf
			ElseIf cType == 3
				If CTT->(GetAdvFVal("CTT","CTT_CLASSE",xFilial("CTT")+STUFF(oTree:GetCargo(),1,1,''),1)) == '2'
					If !Empty(cPlan:= AMX->(GetAdvFVal("AMX","AMX_PLNORC",xFilial("AMX")+cProj,1)))
				   		cVPln:= AK1->(GetAdvFVal("AK1","AK1_VERSAO",xFilial("AK1")+cPlan,1))
						If !Empty (AK2->(GetAdvFVal("AK2","AK2_CC",xFilial("AK2")+cPlan+cVPln+STUFF(oTree:GetCargo(),1,1,''),8)))
					   		MenuItem STR0044		Block bM3VPLN 		//"Visualizar Planilha"
				   			MenuItem STR0045		Block bM3EPLN 	//"Alterar Planilha"
						EndIf
					EndIf
				EndIf
			EndIf
		EndMenu
		oMenu:Activate(x,y)
	EndIf

	RestArea(aArea)
	INCLUI := xInclui

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FAltFase  บAutor  ณJair 		         บ Data ณ  10/30/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo usada para alterar fase da planilha que estแ lincadaบฑฑ
ฑฑบ          ณ ao projeto                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FAltFase(clPln)
	Local Area	:= AK1->(GetArea())

	DbSelectArea("AK1")
	AK1->(DbSetOrder(1))
	If AK1->(DbSeek(xFilial("AK1")+clPln))
		PCOA100AFA()
	EndIf
  	RestArea(Area)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFPrUn		บAutor  ณJair Ribeiro	     บ Data ณ  10/18/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo utilizada para pr้ carregar valores em campos       บฑฑ
ฑฑบ          ณ usados pelo axcadastro tabela AMY                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FPrUn()
    M->AMY_CODPRO:=STUFF(oTree:GetCargo(),1,1,'')
    M->AMY_PROJET:=POSICIONE("AMX",1,xFilial("AMX")+STUFF(oTree:GetCargo(),1,1,''),"AMX_DESCRI")
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA016VldUniบAutor  ณJair Ribeiro	     บ Data ณ  10/18/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se unidade nใo esta em uso no mesmo projeto       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                    	                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A016VldUni()
	Local cProj := FRetProj()
	Local llRet := .T.
	If (llRet := EXISTCPO("AMF"))
		DbSelectArea("AMY")
		AMY->(DBSetOrder(1))
		If (DbSeek(xFilial("AMY")+cProj+M->AMY_CODUNI))
			Aviso(STR0008,STR0046,{STR0010}) //"Aten็ใo"###"Unidade jแ estแ vinculada a esse projeto"###"Ok"
			llRet := .F.
		EndIf
	EndIf
Return llRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA016VldUniบAutor  ณJair Ribeiro	     บ Data ณ  10/18/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se planilha nใo esta em uso em outro projeto      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                    	                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A016VldPln()
	Local llRet	:= .T.
	If (llRet:= ExistCpo("AK1"))
		DbSelectArea("AMX")
		AMX->(DbSetOrder(2))
		If AMX->(DbSeek(xFilial("AMX")+M->AMX_PLNORC))
			Aviso(STR0008,STR0047,{STR0010}) //"Aten็ใo"###"Planilha Vinculada a outro Projeto"###"Ok"
			llRet	:= .F.
		EndIf
	EndIf
Return llRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFRetProj	บAutor  ณJair Ribeiro	     บ Data ณ  10/18/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna c๓digo do projeto do noh corrente                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FRetProj()
   	nPos := Ascan(oTree:aNodes,{|x| alltrim(x[2])  == oTree:CurrentNodeId})
    While oTree:aNodes[nPos][1] != "0000000"
		nPos := Ascan(oTree:aNodes,{|x| alltrim(x[2])  == oTree:aNodes[nPos][1]})
    EndDo
    cProj	:= STUFF(oTree:aCargo[nPos][1],1,1,'')
Return cProj
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFDesvUnd  บAutor  ณMicrosiga           บ Data ณ  10/19/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                 	      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FDesvUnd()
	Local cProj 	:= FRetProj()
	Local bAxParam 	:= {|| .T.}
   	Local bVldExc	:= {|| oTree:TreeSeek(oTree:GetCargo()),oTree:DelItem(),.T.}
   	Local nlAx		:= 0
    Local alCpoUn 	:= {"AMY_CODPRO","AMY_PROJET","AMY_CODUNI","AMY_UNIDAD","NOUSER","NOUSER"}
    Local Area		:= GetArea("AMY")
	DbSelectArea("AMY")
	AMY->(DbSetOrder(2)) //Projeto+Unidade Orc.
	If AMY->(DbSeek(xFilial("AMY")+cProj+STUFF(oTree:GetCargo(),1,1,'')))
		While AMY->(!EOF()) .and. AMY->AMY_CODUNI == STUFF(oTree:GetCargo(),1,1,'') .and. AMY->AMY_CODPRO == cProj
			nlAx += 1
			If nlAx > 1
				Aviso(STR0008,STR0048,{STR0010}) //"Aten็ใo"###"Nใo ้ possivel desvincular unidade do projeto, por conter C.Custo vinculados"###"OK"
				Exit
			EndIf
			AMY->(DbSkip())
	   	EndDo
	EndIf
	If nlAx == 1
		If AMY->(DbSeek(xFilial("AMY")+cProj+STUFF(oTree:GetCargo(),1,1,'')))
			AxDeleta("AMY",AMY->(RECNO()),5,,alCpoUn,,{bAxParam,bVldExc,bAxParam,bAxParam},,.T.)
		EndIf
	EndIf
	RestArea(Area)
Return Nil
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFunctions para o relacionamento entre Projeto e Planilha com  validacoes necessarias	 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFCreatePlnบAutor  ณJair Ribeiro        บ Data ณ  10/20/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relacionamento PROJETO X PLANILHA Menu "Criar Planilha"	  บฑฑ
ฑฑบ			 ณ altera PROMPT                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FCreatePln()
	Local llRet	:= .F.
	DbSelectArea("AMX")
	AMX->(DbSetOrder(1))
	If AMX->(DbSeek(xFilial("AMX")+STUFF(oTree:GetCargo(),1,1,'')))
		If RecLock("AMX",.F.)
			AMX->AMX_PLNORC	:= M->AK1_CODIGO
			MsUnlock()
			oTree:ChangePrompt(oTree:GetPrompt()+STR0031+ALLTRIM(M->AK1_CODIGO) +" - "+ ALLTRIM(M->AK1_DESCRI),oTree:GetCargo()) //" | PLN ORC: "
			FPanelPro(STUFF(oTree:GetCargo(),1,1,''))
			llRet := .T.
		EndIf
	EndIf
Return llRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFVincPln  บAutor  ณJair Ribeiro        บ Data ณ  10/20/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relacionamento PROJETO X PLANILHA Menu "Vincular Planilha" บฑฑ
ฑฑบ			 ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FVincPln()
	Local alRetPq	:= {}

	If !Empty(ALLTRIM(AMX->(GetAdvFVal("AMX","AMX_PLNORC",xFilial("AMX")+STUFF(oTree:GetCargo(),1,1,''),1))))
		Aviso(STR0008,STR0032,{STR0010}) //"Aten็ใo"###"Projeto jแ estแ vinculado a uma Planilha"###"Ok"
   	Else
		alRetPq:=FWinPlan()
		If alRetPq[1,1]
			DbSelectArea("AMX")
			AMX->(DbSetOrder(1))
			If AMX->(DbSeek(xFilial("AMX")+STUFF(oTree:GetCargo(),1,1,'')))
				If RecLock("AMX",.F.)
					AMX->AMX_PLNORC	:= alRetPq[1,2]
					MsUnlock()
					oTree:ChangePrompt(oTree:GetPrompt()+STR0031+ALLTRIM(alRetPq[1,2]) +" - "+ ALLTRIM(alRetPq[1,3]),oTree:GetCargo()) //" | PLN ORC: "
					FPanelPro(STUFF(oTree:GetCargo(),1,1,''))
				EndIf
			EndIf
		EndIf
	EndIf
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFWinPlan  บAutor  ณMicrosiga           บ Data ณ  09/30/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela para vinculo entre Planilha e Projeto                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FWinPlan()
	//Objetos
	Local oDlg		:= Nil
    Local oTwPln	:= Nil
	Local oSearchCb	:= Nil
    Local oSearchBt := Nil
    Local oOkBt		:= Nil
    Local oCancelBt	:= Nil

	//Variaveis
	Local clISearch	:= ""
	Local alRet		:= {}
	Local alComb	:= {STR0049,STR0050,STR0051} //"Codigo"###"Versao"###"Descricao"
	Local llOk 		:= .F.
	Local Area		:= GetArea()

	Local aCols		:= {}
	Private clVSearch	:= Space(TamSx3("AK1_CODIGO")[1])
	lTela :=.F.
	oDlg:=MSDialog():New(000,000,360,600,STR0052,,,,,,,,,.T.) //"Planilhas Or็amentแrias"
		oTwPln	:= TWBrowse():New( 01,01,299,150,,{STR0049,STR0050,STR0053},{TamSx3("AK1_CODIGO")[1],TamSx3("AK1_VERSAO")[1] ,TamSx3("AK1_DESCRI")[1]},oDlg,,,,,{|| FRetPln(alRet,.t.,aCols, oTwPln),oDlg:End()},,,,,,,.F.,,.T.,,.F.)	     //"Codigo"###"Versao"###"Descri็ใo"
		DbSelectArea("AK1")
		AK1->(DbGoTop())
		DbSelectArea("AMX")
		AMX->(DbSetOrder(2))

		While AK1->(!EOF())
			If !AMX->(DbSeek(xFilial("AMX")+AK1->AK1_CODIGO)) .and. AK1->AK1_FASE != '003'
				AADD(aCols,{AK1->AK1_CODIGO, AK1->AK1_VERSAO,AK1->AK1_DESCRI})
			EndIf
			AK1->(DbSkip())
		EndDo

		If Len(aCols) == 0
			aCols := Array(1,3)
		EndIf

		oTwPln:SetArray(aCols)
		oTwPln:bLine := {|| {aCols[oTwPln:nAt,01],aCols[oTwPln:nAt,02],aCols[oTwPln:nAt,03]}}

       	oSearchCb	:= TComboBox():New(155,001,{|u|if(PCount()>0,clISearch:=u,clISearch)},alComb,150,20,oDlg,,{|| FChange(clISearch)},,,,.T.,,,,,,,,,'clISearch')

       	oSearchGt	:= TGet():New(168,001,{|u| if(PCount()>0,clVSearch:=u,clVSearch)}, oDlg,150,06,'@!',{||},,,,,,.T.,,,,,,,,,,'clVSearch')

       	oSearchBt	:=TButton():New(155,155,STR0054,oDlg,{|| FSearchPln(clISearch, clVSearch, @aCols, @oTwPln,alComb)}	,45,10,,,,.T.) //'Pesquisar'
       	oOkBt		:=TButton():New(155,205,STR0010		,oDlg,{|| FRetPln(@alRet, .T.,aCols,oTwPln),oDlg:End()}				,45,10,,,,.T.) //'Ok'
       	oCancelBt	:=TButton():New(155,255,STR0055	,oDlg,{|| FRetPln(@alRet, .F.)				,oDlg:End()}				,45,10,,,,.T.)       	 //'Cancelar'

	oDlg:Activate(,,,.T.,,,)
	RestArea(Area)
	If EmPty(alRet)
		AADD(alRet,{.F.,Nil})
	EndIf
	lTela := .T.
Return alRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFRetPln   บAutor  ณJair Ribeiro        บ Data ณ  09/30/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tratamento para o retorno da tela de relacionamento entre  บฑฑ
ฑฑบ          ณ Projeto e Planilha                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FRetPln(alRet,llOk,aCols,oTwPln)
	Default llOk := .F.
	If llOk
		If !Empty(aCols[oTwPln:nAt][1])
			AADD(alRet,{.T.,aCols[oTwPln:nAt][1],aCols[oTwPln:nAt][3]})
		Else
			AADD(alRet,{.F.,Nil})
		EndIf
	Else
		AADD(alRet,{.F.,Nil})
	EndIf
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FChange   บAutor  ณJair Ribeiro        บ Data ณ  09/30/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tratamento para tamanho do campo caso haja mundaca no indicบฑฑ
ฑฑบ          ณ de busca da tela de vinculo Planilha X Projeto	          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FChange(Ind)
	If Ind == STR0049 //"Codigo"
		clVSearch := space(TamSx3("AK1_CODIGO")[1])
	ElseIf Ind == STR0050 //"Versao"
		clVSearch := space(TamSx3("AK1_VERSAO")[1])
	Else
		clVSearch := space(TamSx3("AK1_DESCRI")[1])
	EndIf
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FSearchPlnบAutor  ณJair Ribeiro        บ Data ณ  09/30/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorno da pesquisa de acordo com os valores passados pelo บฑฑ
ฑฑบ          ณ usuario para tela de vinculo entre Planilha e Projeto      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSearchPln(clISearch, clVSearch, aCols, oTwPln,alComb)
	Local clQry		:= IiF(clISearch != STR0050 ,"SELECT DISTINCT AK1.AK1_CODIGO ", "SELECT DISTINCT AK1.AK1_VERSAO ") //"Versao"
	Local nlPos		:= 0

	If !Empty(clVSearch)
		clQry +=" FROM "+RetSqlName("AK1")+" AK1"
		clQry +=" INNER JOIN "+RetSqlName("AMX")+" AMX"
		clQry +=" ON("
		clQry +=" AMX.AMX_PLNORC <> AK1.AK1_CODIGO"
		clQry +=" AND AMX.AMX_FILIAL = '"+xFilial("AMX")+"'"
		clQry +=" AND AMX.D_E_L_E_T_ <> '*'"
		clQry +=" )"
		clQry +=" WHERE AK1.AK1_FASE <> '003'"
		clQry +=" AND AK1.AK1_FILIAL = '"+xFilial("ALV")+"'"
		clQry +=" AND AK1.D_E_L_E_T_ <> '*'"

		If clISearch == STR0049 //"Codigo"
			clQry +=" AND AK1.AK1_CODIGO LIKE '"+AllTrim(clVSearch)+"%'"
		ElseIf clISearch == STR0050 //"Versao"
			clQry +=" AND AK1.AK1_VERSAO LIKE '"+AllTrim(clVSearch)+"%'"
		Else
			clQry +=" AND AK1.AK1_DESCRI LIKE '"+AllTrim(clVSearch)+"%'"
		EndIf

		If Select("QPLN")>0
			DbSelectArea("QPLN")
			QPLN->(DbCloseArea())
		EndIf

		clQry := ChangeQuery(clQry)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,clQry),"QPLN",.F.,.T.)

		DbSelectArea("QPLN")
		If QPLN->(!EOF())
			If clISearch != STR0050 //"Versao" //"Versao"
				If (nlPos:= Ascan(aCols,{|aX| aX[1] == QPLN->AK1_CODIGO}))>0
				 	oTwPln:nAt:= nlPos
				EndIf
			ElseIf (nlPos:= Ascan(aCols,{|aX| aX[2] == QPLN->AK1_VERSAO}))>0
				oTwPln:nAt := nlPos
			EndIf
		EndIf
		If nlPos == 0
			Aviso(STR0008,STR0056,{STR0010}) //"Aten็ใo"###"Nใo foi encontrado valor referente a pesquisa"###"Ok"
		EndIf
		QPLN->(DbCloseArea())
	EndIf
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFDesvPln  บAutor  ณMicrosiga           บ Data ณ  10/20/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para desvincular Planilha do Projeto                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FDesvPln()
	Local Area := AMX->(Getarea())
	If !Empty(AMX->(GetAdvFVal("AMX","AMX_PLNORC",xFilial("AMX")+STUFF(oTree:GetCargo(),1,1,''),1)))
		If MsgNoYes(STR0057) //"Deseja realmente desvincular planilha desse projeto?"
			DbSelectArea("AMX")
			AMX->(DbSetOrder(1))
			If AMX->(DbSeek(xFilial("AMX")+STUFF(oTree:GetCargo(),1,1,'')))
				If RecLock("AMX",.F.)
					AMX->AMX_PLNORC	:= space(TamSx3("AMX_PLNORC")[1])
					MsUnlock()
					oTree:ChangePrompt(ALLTRIM(AMX->AMX_CODIGO) +" - "+ ALLTRIM(AMX->AMX_DESCRI),oTree:GetCargo())
					FPanelPro(STUFF(oTree:GetCargo(),1,1,''))
				EndIf
			EndIf
		EndIf
	Else
		Aviso(STR0008,STR0058,{STR0010})//Projeto nใo contem planilha vinculada
	EndIf
	RestArea(Area)
Return Nil

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFunctions para o relacionamento entre Unidade e C.Custo com  validacoes necessarias	 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFVincCTT  บAutor  ณJair Ribeiro        บ Data ณ  10/20/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FVincCTT(oTree)
	Local alRetPq	:= {}
	Local cProj	:= FRetProj(oTree)
	Local nlAx	:= 0

	DbSelectarea("AMY")
	AMY->(DbSetOrder(2))
	If AMY->(Dbseek(xFilial("AMY")+cProj+STUFF(oTree:GetCargo(),1,1,'')))
		While AMY->(!EOF()) .and. AMY->AMY_CODPRO == cProj .and. AMY->AMY_CODUNI == STUFF(oTree:GetCargo(),1,1,'')
			nlAx += 1
			If nlAx > 1
				Aviso(STR0008,STR0059,{STR0010})	 //"Aten็ใo"###"Jแ existe Centro de Custo Sintetico Relacionado a Unidade"###"Ok" //"Aten็ใo"###"Jแ existe Centro de Custo Sintetico Relacionado a Unidade"###"OK"
				Exit
			EndIf
			AMY->(DbSkip())
		EndDo
	EndIf
	If nlAx == 1
		alRetPq:=FWinCTT()
		If alRetPq[1,1]
		DbSelectArea("AMY")
			If RecLock("AMY",.T.)
				AMY->AMY_FILIAL	:= xFilial("AMY")
				AMY->AMY_CODPRO	:= cProj
				AMY->AMY_PROJET	:= AMX->(GetAdvFVal("AMX","AMX_DESCRI",xFilial("AMX")+cProj,1))
				AMY->AMY_CODUNI	:= STUFF(oTree:GetCargo(),1,1,'')
				AMY->AMY_UNIDAD	:= AMX->(GetAdvFVal("AMF","AMF_DESCRI",xFilial("AMF")+STUFF(oTree:GetCargo(),1,1,''),1))
				AMY->AMY_CCUSTO	:= alRetPq[1,2]
				MsUnlock()
				clPrompt	:= ALLTRIM(alRetPq[1,2]) +" - "+ ALLTRIM(alRetPq[1,3])
				oTree:AddItem(clPrompt,"C"+alRetPq[1,2],'SIMULACA','SIMULACA',2,{|| },{|oTree,x,y| FPopUp(oTree,oFWLayer,3,x,y)})
			EndIf
		EndIf
	EndIf
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFWinCTT   บAutor  ณJair Ribeiro        บ Data ณ  10/21/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FWinCTT()
	//Objetos
	Local oDlg		:= Nil
    Local oTwPln	:= Nil
	Local oSay		:= Nil
    Local oSearchBt := Nil
    Local oOkBt		:= Nil
    Local oCancelBt	:= Nil
	//Variaveis
	Local clISearch	:= ""
	Local alRet		:= {}
	Local llOk 		:= .F.
	Local Area		:= GetArea()
	Local cProj		:= FRetProj()

	Local aCols		:= {}
	Local clVSearch	:= Space(TamSx3("CTT_CUSTO")[1])
	lTela	:= .F.
	DbSelectArea("CTT")
	CTT->(DbGoTop())
	DbSelectArea("AMY")
	AMY->(DbSetOrder(3)) //FILIAL+PROJETO+C.CUSTO

	While CTT->(!EOF())
		If !AMY->(DbSeek(xFilial("AMY")+cProj+CTT->CTT_CUSTO)) .and. CTT->CTT_CLASSE != '2'
			AADD(aCols,{CTT->CTT_CUSTO, CTT->CTT_DESC01})
		EndIf
		CTT->(DbSkip())
	EndDo

	If Len(aCols) == 0
		HELP("   ",1,"NOCCSIN",,STR0069,3,0)//"Nใo foram encontrados Centros de Custo sint้ticos para a sele็ใo."
		AADD(alRet,{.F.,Nil})
	Else
		oDlg:=MSDialog():New(000,000,330,600,STR0060,,,,,,,,,.T.) //"Centro de Custo" //"Centro de Custo"
		oTwPln	:= TWBrowse():New( 01,01,299,150,,{STR0049,STR0053},{TamSx3("CTT_CUSTO")[1],TamSx3("CTT_DESC01")[1]},oDlg,,,,,{|| FRetCTT(alRet,.t.,aCols, oTwPln),oDlg:End()},,,,,,,.F.,,.T.,,.F.)	     //"Codigo"###"Descri็ใo" //"Codigo"###"Descri็ใo"

		oTwPln:SetArray(aCols)
		oTwPln:bLine := {|| {aCols[oTwPln:nAt,01],aCols[oTwPln:nAt,02]}}

		oSay:= tSay():New(157,005,{||STR0061},oDlg,,,,,,.T.,,,020,020) //"C.Custo" //"C.Custo"
       	oSearchGt	:= TGet():New(155,030,{|u| if(PCount()>0,clVSearch:=u,clVSearch)}, oDlg,121,06,'@!',{||},,,,,,.T.,,,,,,,,,,'clVSearch')

       	oSearchBt	:=TButton():New(155,155,STR0054,oDlg,{|| FSearchCTT(clVSearch, @aCols, @oTwPln)		}		,45,10,,,,.T.) //'Pesquisar' //'Pesquisar'
       	oOkBt		:=TButton():New(155,205,STR0010		,oDlg,{|| FRetCTT(@alRet, .T.,aCols,oTwPln),oDlg:End()	}		,45,10,,,,.T.) //'Ok' //"OK"
       	oCancelBt	:=TButton():New(155,255,STR0055	,oDlg,{|| FRetCTT(@alRet, .F.)				,oDlg:End()	}		,45,10,,,,.T.)	 //'Cancelar' //"Cancelar"
		oDlg:Activate(,,,.T.,,,)
	Endif
	If EmPty(alRet)
		AADD(alRet,{.F.,Nil})
	EndIf
	lTela := .T.
	RestArea(Area)
Return alRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFRetCTT   บAutor  ณJair Ribeiro        บ Data ณ  10/21/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Trata o Retorno da tela de pesquisa                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FRetCTT(alRet,llOk,aCols,oTwPln)
	Default llOk := .F.
	If llOk
		If !Empty(aCols[oTwPln:nAt][1])
			AADD(alRet,{.T.,aCols[oTwPln:nAt][1],aCols[oTwPln:nAt][2]})
		Else
			AADD(alRet,{.F.,Nil})
		EndIf
	Else
		AADD(alRet,{.F.,Nil})
	EndIf
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFSearchCTTบAutor  ณMicrosiga           บ Data ณ  10/21/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca atraves do codigo do C.Custo Informado pelo usuario  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSearchCTT(clVSearch, aCols, oTwPln,alComb)
	Local clQry		:= ""
	Local nlPos		:= 0

	If !Empty(clVSearch)
		clQry :=" SELECT CTT.CTT_CUSTO"
		clQry +=" FROM "+RetSqlName("CTT")+" CTT"
		clQry +=" WHERE CTT.CTT_CLASSE = '1'"
		clQry +=" AND CTT.CTT_FILIAL = '"+xFilial("ALV")+"'"
		clQry +=" AND CTT.D_E_L_E_T_ <> '*'"
		clQry +=" AND CTT.CTT_CUSTO LIKE '"+AllTrim(clVSearch)+"%'"

		If Select("QCTT")>0
			DbSelectArea("QCTT")
			QPLN->(DbCloseArea())
		EndIf

		clQry := ChangeQuery(clQry)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,clQry),"QCTT",.F.,.T.)

		DbSelectArea("QCTT")
		If QCTT->(!EOF())
			If (nlPos:= Ascan(aCols,{|aX| aX[1] == QCTT->CTT_CUSTO}))>0
			 	oTwPln:nAt:= nlPos
			EndIf
		EndIf
		If nlPos == 0
			Aviso(STR0008,STR0056,{STR0010}) //"Aten็ใo"###"Nใo foi encontrado valor referente a pesquisa"###"Ok" //"Aten็ใo"###"Nใo foi encontrado valor referente a pesquisa"###"OK"
		EndIf
		QCTT->(DbCloseArea())
	EndIf
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFExpCTT   บAutor  ณJair Ribeiro        บ Data ณ  10/21/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que incluiu C.Custo inferiores no projeto           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FExpCTT()
	Local cProj		:= FRetProj()
	Local Area		:= CTT->(Getarea())
	Local cCodUni	:= POSICIONE("AMY",3,xFilial("AMY")+cProj+STUFF(oTree:GetCargo(),1,1,''),"AMY_CODUNI")
	Local cUnidad	:= POSICIONE("AMY",3,xFilial("AMY")+cProj+STUFF(oTree:GetCargo(),1,1,''),"AMY_UNIDAD")

	DbSelectArea("AMY")
	AMY->(DbSetOrder(4))// AMY_FILIAL+AMY_CODPRO+AMY_CCSUP
	If AMY->(DbSeek(xFilial("AMY")+cProj+STUFF(oTree:GetCargo(),1,1,'')))
		Aviso(STR0008,STR0062,{STR0010})		 //"Aten็ใo"###"Essa a็ใo jแ foi executada"###"Ok" //"Aten็ใo"###"Essa a็ใo jแ foi executada"###"OK"
	Else
		DbSelectArea("CTT")
		CTT->(DbSetOrder(5))//CTT_FILIAL+CTT_CCSUP
		If CTT->(Dbseek(xFilial("CTT")+STUFF(oTree:GetCargo(),1,1,'')))
			While CTT->(!EOF()) .And. CTT->CTT_CCSUP == STUFF(oTree:GetCargo(),1,1,'')
				If !Empty(AMY->(POSICIONE("AMY",1,xFilial("AMY")+cProj+CTT->CTT_CUSTO,"AMY_CCSUP")))
					Aviso(STR0008,STR0063+CTT->CTT_CUSTO,{STR0010})			   	 //"Aten็ใo"###"Centro de Custo Invalido na Estrutura:"###"OK"
				ElseIf RecLock("AMY",.T.)
					AMY->AMY_FILIAL := xFilial("AMY")
					AMY->AMY_CODPRO	:= cProj
					AMY->AMY_PROJET	:= AMX->(GetAdvFVal("AMX","AMX_DESCRI",xFilial("AMX")+cProj,1))
					AMY->AMY_CODUNI	:= cCodUni
					AMY->AMY_UNIDAD	:= cUnidad
					AMY->AMY_CCUSTO	:= CTT->CTT_CUSTO
					AMY->AMY_CCSUP	:= CTT->CTT_CCSUP
					MsUnlock()
					clPrompt:= ALLTRIM(CTT->CTT_CUSTO) +" - "+ ALLTRIM(CTT->CTT_DESC01)
					oTree:AddItem(clPrompt,"C"+CTT->CTT_CUSTO,'SIMULACA','SIMULACA',2,{|| },{|oTree,x,y| FPopUp(oTree,oFWLayer,3,x,y)})
				EndIf
				CTT->(DbSkip())
			EndDo
		Else
			Aviso(STR0008,STR0064,{STR0010}) //"Aten็ใo"###"C.Custo nใo possui inferiores"###"Ok" //"Aten็ใo"###"C.Custo nใo possui inferiores"###"OK"
		EndIf
	EndIf
	RestArea(Area)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFDesvCTT  บAutor  ณMicrosiga           บ Data ณ  10/21/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para desvincular Centro de Custo                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FDesvCTT()
	Local cProj	:= FRetProj()
	DbSelectArea("AMY")
	AMY->(DbSetOrder(4))// AMY_FILIAL+AMY_CODPRO+AMY_CCSUP
	If AMY->(DbSeek(xFilial("AMY")+cProj+STUFF(oTree:GetCargo(),1,1,'')))
		Aviso(STR0008,STR0065,{STR0010}) //"Aten็ใo"###"C.Custo possui C.Custo Inferiores"###"Ok" //"Aten็ใo"###"C.Custo possui C.Custo Inferiores"###"OK"
	ElseIf MsgYesNo(STR0066) //"Deseja realmente desvincular C.Custo?" //"Deseja realmente desvincular C.Custo?"
		AMY->(DbSetOrder(3))// AMY_FILIAL+AMY_CODPRO+AMY_CCUSTO
		If AMY->(DbSeek(xFilial("AMY")+cProj+STUFF(oTree:GetCargo(),1,1,'')))
			If RecLock("AMY",.F.,.T.)
	   			AMY->(DbDelete())
  				MsUnLock()
  				oTree:TreeSeek(oTree:GetCargo())
  				oTree:DelItem()
  			EndIf
	    EndIf
	EndIf
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FOpenPln	บAutor  ณMicrosiga           บ Data ณ  10/22/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Abre a tela da Planilha Or็amentแria                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FOpenPln(cPln,cVpln,nOpc)
    Local Area		:= AK1->(GetArea())
    AK1->(DbSetOrder(1))
    AK1->(DbSeek(xFilial("AK1")+cPln+cVpln))
   	PCOA100(nOpc)
    RestArea(Area)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSumRange  บAutor  ณFernando Radu       บ Data ณ  10/30/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valor total da nova planilha incluida                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cOrcamento = Or็amento                                     บฑฑ
ฑฑบ          ณ cVerOrc    = Versใo do or็amento	                          บฑฑ
ฑฑบ          ณ cContaOrc  = Conta Or็amentaria                            บฑฑ
ฑฑบ          ณ dDataIni   = Data Inicial                                  บฑฑ
ฑฑบ          ณ dDataFim   = Data Final                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Valor total da conta or็amentaria/planilha                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SumRange(cOrcamento,cVerOrc,cContaOrc,dDataIni,dDataFim)
	Local nValRet  		:= 0
	Local cQry    		:= ""
	Default cOrcamento  := ""
	Default cVerOrc  	:= ""
	Default cContaOrc 	:= ""
	Default dDataIni 	:= ctod("")
	Default dDataFim 	:= ctod("31/12/49")

	cQry := "SELECT " + chr(13) + chr(10)
	cQry += " SUM(AK2_VALOR) TOTAL " + chr(13) + chr(10)
	cQry += "FROM " + chr(13) + chr(10)
	cQry += " " + RetSQLName("AK2") + chr(13) + chr(10)
	cQry += "WHERE " + chr(13) + chr(10)
	cQry += " AK2_FILIAL = '"+xFilial("AK2")+"' " + chr(13) + chr(10)
	If !Empty(cOrcamento)
		cQry += " AND " + chr(13) + chr(10)
		cQry += " AK2_ORCAME = '"+cOrcamento+"' " + chr(13) + chr(10)
	Endif
	If !Empty(cVerOrc)
		 cQry += " AND " + chr(13) + chr(10)
		 cQry += " AK2_VERSAO = '"+cVerOrc+"' " + chr(13) + chr(10)
	Endif
	If !Empty(cContaOrc)
		 cQry += " AND " + chr(13) + chr(10)
		 cQry += " AK2_CO = '"+cContaOrc+"' " + chr(13) + chr(10)
	Endif
		cQry += " AND " + chr(13) + chr(10)
		cQry += " AK2_DATAI >= '"+dtos(dDataIni)+"' " + chr(13) + chr(10)
		cQry += " AND " + chr(13) + chr(10)
		cQry += " AK2_DATAF <= '"+dtos(dDataFim)+"' " + chr(13) + chr(10)
		cQry += " AND " + chr(13) + chr(10)
		cQry += " D_E_L_E_T_ = ' ' "

	If Select("TRBSOMA") > 0
		 TRBSOMA->(DBCLOSEAREA())
	EndIf
	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBSOMA",.T.,.T.)

	nValRet := TRBSOMA->TOTAL
	TRBSOMA->(DBCLOSEAREA())
Return(nValRet)