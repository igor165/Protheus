#INCLUDE "PCOA011.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA011	บAutor  ณMicrosiga           บ Data ณ  11/26/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Projeto do Planejamento Or็amentแrio                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA011()
	Private aRotina 	:= MenuDef()	//Menu
	Private	lPermit		:= FVldUsPJ()	//Usuario Gerenciador de projeto (.T. or .F.)
	Private cCadastro	:= STR0001 //"Projeto do Planejamento"
	mBrowse(6,1,22,75,"AMM")
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
	Local aRotina 	:= {{ STR0002		,STR0003  	,0,1},; //"Pesquisar"###"AxPesqui"
						{ STR0065		,"AxVisual" 	,0,2} ,; // "Visualizar"
					   	{ STR0004	   		,"PCOA011DLG" 	,0,3} ,; //"Incluir"
						{ STR0005			,"PCOA011EST" 	,0,4} ,; //"Editar"
					   	{ STR0006			,"PCOA011DLG" 	,0,5}}   //"Excluir"
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
ฑฑบPrograma  ณPCOA011DLGบAutor  ณJair Ribeiro        บ Data ณ  11/27/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA011DLG(cAlias,nReg,nOpc)
	Local lExclui:= .F.
	Local bVldEx := {|| lExclui := MsgNoYes(STR0007)} //"Deseja realmente excluir planilha? Todos seus vinculos serao excluidos!"

	If lPermit
		If nOpc == 3
	   		AxInclui(cAlias,nReg,nOpc,,"PCOA011CLS",,,,,,,,.T.,CONTROL_ALIGN_LEFT)
	 	ElseIf nOpc == 5
	    	AMP->(DbSetOrder(1))
	    	If AMP->(DbSeek(xFilial("AMP")+AMM->AMM_CODIGO))
				Aviso(STR0008,STR0009,{STR0010})  //"Aten็ใo"###"Nใo ้ possivel excluir, Projeto Or็amentแrio com unidades vinculadas"###"Ok"
			Else
				AxDeleta(cAlias,nReg,nOpc,,,,{{|| .T.},bVldEx,{|| .T.},{|| .T.}},,.T.)
			   	If lExclui
			   	  //	MsgAlert("Excluido")
			   	EndIf
			EndIf
		EndIf
	Else
		Aviso(STR0008,STR0011,{STR0010}) //"Aten็ใo"###"Usuario sem permissao para cadastrar projeto"###"Ok"
	EndIf
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA011CLSบAutor  ณJair Ribeiro        บ Data ณ  10/25/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo utilizada para limpar as variaveis que serใo usadas บฑฑ
ฑฑบ          ณ pelo axInclui da rotina principal                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA011CLS()
	M->AMM_DSCPLN	:= ""
	M->AMM_DTENC 	:= STOD("")
	M->AMM_TOTAL 	:= 0
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
Function PCOA011EST() //PCOA016FW
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


	DbSelectArea("AMM")
	oDlgFw :=MSDialog():New(alDmsWin[1],alDmsWin[2],alDmsWin[3],alDmsWin[4], STR0001,,,,nOr(WS_VISIBLE,WS_POPUP),,,,oMainWnd,.T.)  //"Projeto do Planejamento"
		oFWLayer:=FWLayer():new()
		oFWLayer:Init(oDlgFw,.T.)

		oFWLayer:addCollumn('CollxT',30,.F.)
		oFWLayer:addWindow('CollxT','WindxT',STR0012,97,.T.,.T.)  //"Configura็๕es do Projeto"
		oPanelI:=oFWLayer:getWinPanel('CollxT','WindxT')
		oPanelI:FreeChildren()
		oFWLayer:SetColSplit('CollxT',CONTROL_ALIGN_RIGHT)

		oTree		:= xTree():New(,,,,oFWLayer:GetWinPanel('CollxT','WindxT'))
		oTree:Align	:= CONTROL_ALIGN_ALLCLIENT
		FConstTree(AMM->AMM_CODIGO)


		//Coluna que conterแ os layouts
		oFwLayer:addCollumn('CollCt',70,.T.)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณLayout 1                                                                                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oLayout1:=FWLayer():new()
		oLayout1:Init(oFWLayer:GetColPanel('CollCt'),.F.)
		oLayout1:addCollumn('CollL1',97,.T.)
		oLayout1:addWindow('CollL1','WindL1',STR0013,97,.T.,.T.) //"Detalhes"
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
		oLayout2:addWindow('CollL2','WindL21',STR0013,39,.T.,.T.) 				 //"Detalhes"
		oLayout2:addWindow('CollL2','WindL22',STR0001,58,.T.,.T.)  //"Projeto do Planejamento"
		oPanelL21:=oLayout2:getWinPanel('CollL2','WindL21')
		oPanelL22:=oLayout2:getWinPanel('CollL2','WindL22')
		oPanelL21:FreeChildren()
		oPanelL22:FreeChildren()
	   	oSayCP:= tSay():New(,,{|| FTextPro()},oLayout2:getWinPanel('CollL2','WindL21'),,oLayout2:getWinPanel('CollL2','WindL21'):oFont,,,,.T.)
   		oSayCP:lTransparent := .F.
		oSayCP:Align := CONTROL_ALIGN_ALLCLIENT
	   	oLayout2:Hide()
	   	RegToMemory("AMM",.T.)
		oEnch1 := Msmget():New("AMM",0,3,,,,,{015,003,365,362},{},3,,,.T.,oPanelL22,,.T.)
		oEnch1:oBox:Align	:= CONTROL_ALIGN_ALLCLIENT


		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณLayout 3 - Unidade                                                                         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oLayout3:=FWLayer():new()
		oLayout3:Init(oFWLayer:GetColPanel('CollCt'),.F.)
		oLayout3:addCollumn('CollL3',97,.T.)
		oLayout3:addWindow('CollL3','WindL31',STR0013,39,.T.,.T.) //"Detalhes"
		oLayout3:addWindow('CollL3','WindL32',STR0014,58,.T.,.T.)  //"Unidade do Or็amentaria"
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
		oBtnFw:addBtnImage("FINAL.PNG"		,STR0015	,{|| oDlgFw:End()},, .T.,CONTROL_ALIGN_RIGHT) //"Sair"

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
Function PCO011CODP()
	Local lRet := .T.
	Local Area := AMM->(GetArea())
	DbSelectArea("AMM")
	AMM->(DbSetOrder(1))
	If AMM->(DbSeek(xFilial("AMM")+M->AMM_CODIGO))
		lRet := .F.
		Aviso(STR0008,STR0016,{STR0010})  //"Aten็ใo"###"Este c๓digo esta em uso em outro projeto"###"Ok"
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
	cSayHTML += STR0017 //"Configura็ใo de Projetos"
	cSayHTML +=	"</H1>"
	cSayHTML +=	"<FONT size=+1>"
	cSayHTML += STR0018 //"O projeto de planejamento permite aos responsแveis uma visao geral do or็amento nas organiza็๕es,"
	cSayHTML += STR0019 //"tendo a flexibilidade de realizar projetos especํficos que possam ser necessแrios no decorrer de"
	cSayHTML += STR0020 //"um exercํcio, ou at้ mesmo a divisใo do or็amento por suas franquias, filiais, areas de negocio e seus departamentos."
	cSayHTML += STR0021 //"Com o uso de um projeto tem-se a facilidade de visualizar a estrutura organizacional orcamentario, isso pode auxiliar os processo de negociacao, aquisicoes e vendas,"
	cSayHTML += STR0022 //"por exemplo. Deste modo os gestores podem ter o controle do or็amento de suas Unidades como um todo, sabendo os totais de cada divisao da estrutura"
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
	cSayHTML += STR0023 //"Unidade Orcamentaria"
	cSayHTML +=	"</H1>"
	cSayHTML +=	"<FONT size=+1>"
	cSayHTML +=	STR0024 //"A unidade orcamentaria ้ usada para agrupar a estrutura de centro de custos de modo que se tenha uma visao"
	cSayHTML +=	STR0025 //"franquias ้ muito utilizada para separar holdings e suas orgqniza็๕es tamb้m pode ser utilizada para escalas dentro"
	cSayHTML +=	STR0026 //"de um projeto organizacional para separar meses, separa lํderes e em diversos outros casos em que se aplicar"
	cSayHTML +=	STR0027 //"O nome da Unidade Organizacional serแ composta por seu c๓digo e descri็ใo, ex 001 - Filial Sul, uma vez amarrado "
	cSayHTML += STR0028 //"e utilizada, uma unidade organizacional nใo pode ser alterada, nem excluida."
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
	DbSelectArea("AMM")
	DbSetOrder(1)
	If DbSeek(xFilial("AMM")+cProjeto)
		RegToMemory("AMM", .F.,,, FunName())
	    For nlI := 1 To FCount()
    		M->&(FieldName(nlI)) := &("AMM->"+(FieldName(nlI)))
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
	Local alLayout 	:={"oLayout1","	oLayout2","oLayout3"/*,"oLayout4"*/}
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
		If Empty(M->AMM_PLNORC)
			cPrompt := ALLTRIM(M->AMM_CODIGO) +" - "+ ALLTRIM(M->AMM_DESCRI)
		Else
		cPrompt := ALLTRIM(M->AMM_CODIGO) +" - "+ ALLTRIM(M->AMM_DESCRI)+STR0029+ ALLTRIM(M->AMM_PLNORC) +" - "+ ALLTRIM(ALV->(GetAdvFVal("ALV","ALV_DESCRI",xFilial("ALV")+M->AMM_PLNORC,1))) //" | PLN PLANEJ: "
		EndIf

		If oTree:IsEmpty()
			oTree:AddItem(cPrompt,"P"+M->AMM_CODIGO,'FOLDER5','FOLDER6',1,{|| FPanelPro(STUFF(oTree:GetCargo(),1,1,''))},{|oTree,x,y| FPopUp(oTree,oFWLayer,1,x,y)})
		ElseIf oTree:TreeSeek(oTree:aCargo[1,1])
			oTree:AddItem(cPrompt,"P"+M->AMM_CODIGO,'FOLDER5','FOLDER6',1,{|| FPanelPro(STUFF(oTree:GetCargo(),1,1,''))},{|oTree,x,y| FPopUp(oTree,oFWLayer,1,x,y)})
		EndIf

	ElseIf nTipo == 2		// Inclusao de item para Unidade Orcamentaria.
		cPrompt	:= ALLTRIM(M->AMP_CODUNI) +" - "+ GetAdvFVal("AMF","AMF_DESCRI",xFilial("AMF")+M->AMP_CODUNI,1)//ALLTRIM(M->AMP_UNIDAD)
		oTree:AddItem(cPrompt,"U"+M->AMP_CODUNI,"MDIVISIO","MDIVISIO",2,{|| FPanelUnid(STUFF(oTree:GetCargo(),1,1,''))},{|oTree,x,y| FPopUp(oTree,oFWLayer,2,x,y)})
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
	Local Area			:= AMM->(GetArea())

	//DbSelectArea("AMM")
	AMM->(DbSetOrder(1))
	If AMM->(DbSeek(xFilial("AMM")+cProjeto))
		If !Empty(AMM->AMM_PLNORC)
			If lPermit .or. FVldUsPln(AMM->AMM_PLNORC)
				clPrompt := ALLTRIM(AMM->AMM_CODIGO) +" - "+ ALLTRIM(AMM->AMM_DESCRI)+ STR0029+ ALLTRIM(AMM->AMM_PLNORC) +" - "+ ALLTRIM(ALV->(GetAdvFVal("ALV","ALV_DESCRI",xFilial("ALV")+AMM->AMM_PLNORC,1))) //" | PLN PLANEJ: "
				oTree:AddTree(clPrompt,'FOLDER5','FOLDER6',"P"+AMM->AMM_CODIGO,{|| FPanelPro(STUFF(oTree:GetCargo(),1,1,''))},{|oTree,x,y| FPopUp(oTree,oFWLayer,1,x,y)})
			EndIf
		Else
			clPrompt := ALLTRIM(AMM->AMM_CODIGO) +" - "+ ALLTRIM(AMM->AMM_DESCRI)
			oTree:AddTree(clPrompt,'FOLDER5','FOLDER6',"P"+AMM->AMM_CODIGO,{|| FPanelPro(STUFF(oTree:GetCargo(),1,1,''))},{|oTree,x,y| FPopUp(oTree,oFWLayer,1,x,y)})
		EndIf
 		If Empty(AMM->AMM_PLNORC) .or. lPermit .or. FVldUsPln(AMM->AMM_PLNORC)
 			DbSelectArea("AMP")
		    AMP->(DbGoTop())
		    AMP->(DbSetOrder(1))
    		If AMP->(DbSeek(xFilial("AMP")+AMM->AMM_CODIGO))
	    		While AMP->(!EOF()) .and. AMP->AMP_CODPRO == AMM->AMM_CODIGO
	        		If Empty(AMP->AMP_CCUSTO)
		       			clPrompt 	:= ALLTRIM(AMP->AMP_CODUNI) +" - "+ GetAdvFVal("AMF","AMF_DESCRI",xFilial("AMF")+AMP->AMP_CODUNI,1)//ALLTRIM(AMP->AMP_UNIDAD)
						oTree:AddTree(clPrompt,'MDIVISIO','MDIVISIO',"U"+AMP->AMP_CODUNI,{|| FPanelUnid(STUFF(oTree:GetCargo(),1,1,''))},{|oTree,x,y| FPopUp(oTree,oFWLayer,2,x,y)})

							clQry:="SELECT AMP.AMP_CCUSTO"
							clQry+=" FROM "+RetSqlName("AMP")+" AMP"
							clQry+=" WHERE AMP.AMP_CODPRO = '"+AMM->AMM_CODIGO+"'"
							clQry+=" AND AMP.AMP_CODUNI = '"+AMP->AMP_CODUNI+"'"
							clQry+=" AND AMP.AMP_CCUSTO <> ''"
							clQry+=" AND AMP.AMP_CCSUP = ''"
							clQry+=" AND AMP.AMP_FILIAL = '"+ xFilial("AMP")+"'"
							clQry+=" AND AMP.D_E_L_E_T_ <> '*'"

							If Select("QAMP")>0
								DbSelectArea("QAMP")
								QAMP->(DbCloseArea())
							EndIf
							clQry := ChangeQuery(clQry)
							dbUseArea(.T.,"TOPCONN",TCGENQRY(,,clQry),"QAMP",.F.,.T.)
							DbSelectArea("QAMP")
					   		If QAMP->(!EOF())
								FConstCTT(AMM->AMM_CODIGO,AMP->AMP_CODUNI,QAMP->AMP_CCUSTO)
							EndIf
						oTree:EndTree()
					EndIf
					AMP->(DbSkip())
				EndDo
			EndIf
			oTree:EndTree()
		EndIf
	    AMM->(DbSkip())
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
	Local Area		:= AMP->(GetArea())
	Local clPrompt 	:= ""
	Local llUsCtt	:= .F.

	AMP->(DbSetOrder(2)) //FILIAL+PROJETO+UNIDADE+CCSUP
	If AMP->(DbSeek(xFilial("AMP")+cProjeto+cUnidade+cCusto))
		If lPermit .or. (llUsCtt:= FVldUsCTT(cCusto))
			clPrompt 	:= ALLTRIM(cCusto) +" - "+ ALLTRIM(CTT->(GetAdvFVal("CTT","CTT_DESC01",xFilial("CTT")+cCusto,1)))
   			oTree:AddTree(clPrompt,'SIMULACA','SIMULACA',"C"+cCusto,{|| },{|oTree,x,y| FPopUp(oTree,oFWLayer,3,x,y)})
   		EndIf
   			While AMP->(!EOF()) .and. cCusto == AMP->AMP_CCSUP
   				FConstCTT(cProjeto,cUnidade,AMP->AMP_CCUSTO)
		   		AMP->(DbSkip())
	   		EndDo
		If lPermit .or. llUsCtt
			oTree:EndTree()
		EndIf
 	Else
 		AMP->(DbSetOrder(1)) // FILIAL+PROJETO+UNIDADE+CCUSTO
		If AMP->(DbSeek(xFilial("AMP")+cProjeto+cUnidade+cCusto))
			If lPermit .or. FVldUsCTT(cCusto)
		   		clPrompt 	:= ALLTRIM(cCusto) +" - "+ ALLTRIM(CTT->(GetAdvFVal("CTT","CTT_DESC01",xFilial("CTT")+cCusto,1)))
		   		oTree:AddTreeItem(clPrompt,'SIMULACA',"C"+AMP->AMP_CCUSTO,{|| },{|oTree,x,y| FPopUp(oTree,oFWLayer,3,x,y)})
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

	DbSelectArea("AMU")
	AMU->(DbSetOrder(1))
	If AMU->(DbSeek(xFilial("AMU")+cPln+clUser))
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

    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Blocos para Menu 1                                        		 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    Local bM1IUnd 	:= {|| AxInclui("AMP",AMP->(RECNO()),3,/*alCpoUn*/,"FPrUn",,,,,,{{||INCLUI := .T. , .T.},{|| FConstruct(2)},{|| .T.},{|| .T.}}	,,,.T.)}
	Local bM1VPln	:= {|| FVincPln()}
	Local bM1CPln	:= {|| Iif(Empty(ALLTRIM(AMM->(GetAdvFVal("AMM","AMM_PLNORC",xFilial("AMM")+STUFF(oTree:GetCargo(),1,1,''),1)))),;
							PCOA490(3),/*AxInclui("AK1",AK1->(RECNO()),3,,,,,,,,{{|| INCLUI := .T., .T.},{|| FCreatePln()},{|| .T.},{|| .T.}},,,.T.),*/;
							Aviso(STR0008,STR0030,{STR0010}));  //"Aten็ใo"###"Projeto jแ estแ vinculado a uma Planilha"###"Ok"
						}

	Local bM1EPln	:= {|| Iif(!Empty(ALLTRIM(clPln := AMM->(GetAdvFVal("AMM","AMM_PLNORC",xFilial("AMM")+STUFF(oTree:GetCargo(),1,1,''),1)))),;
						FOpenPln(clPln,"",.T.),;
						Aviso(STR0008,STR0031,{STR0010}) ); //"Aten็ใo"###"Projeto nใo estแ vinculado a planilha"###"Ok"
						}

	Local bM1DPln	:= {|| FDesvPln()}
	Local bM1FPln	:= {|| Iif(!Empty(ALLTRIM(clPln := AMM->(GetAdvFVal("AMM","AMM_PLNORC",xFilial("AMM")+STUFF(oTree:GetCargo(),1,1,''),1)))),;
						FAltFase(clPln),;
						Aviso(STR0008,STR0031,{STR0010}) );   //"Aten็ใo"###"Projeto nใo estแ vinculado a planilha"###"Ok"
						}

    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Blocos para Menu 2                                        		 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    Local bM2DUnd 	:= {|| FDesvUnd()}
	Local bM2VCTT	:= {|| FVincCTT()}

    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Blocos para Menu 3                                        		 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local bM3DCTT	:= {|| FDesvCTT()}
	Local bM3ECTT	:= {|| FExpCTT()}
	Local bM3VPLN	:= {|| FOpenPln(cPlan,cVPln,.F.)}
	Local bM3EPLN	:= {|| FOpenPln(cPlan,cVPln,.T.)}

	Local cProj		:= FRetProj()
	Local cPlan		:= ""
	Local cVPln		:= ""

	If lTela
		Menu oMenu PopUp
			If lPermit
				If cType == 1
					MenuItem STR0032	Block bM1IUnd  //"Vincular Uni. Orc"
					MenuItem STR0033	Block bM1VPln //"Vincular Planilha"
					MenuItem STR0034	Block bM1CPln  //"Criar Planilha"
					MenuItem STR0035	Block bM1EPln //"Planejar Planilha"
					MenuItem STR0036	Block bM1DPln //"Desvincular Planilha"
					MenuItem STR0037	Block bM1FPln //"Alterar Fase Planilha"

				ElseIf cType == 2
					MenuItem STR0038	Block bM2DUnd  //"Desvincular Uni. Orc"
					MenuItem STR0039	Block bM2VCTT  //"Vincular C.Custo"

				ElseIf CTT->(GetAdvFVal("CTT","CTT_CLASSE",xFilial("CTT")+STUFF(oTree:GetCargo(),1,1,''),1)) == '1'	//Centro de Custo Sintetico]
					MenuItem STR0040	Block bM3DCTT  //"Desvincular C.Custo"
					MenuItem STR0041	Block bM3ECTT  //"Expandir C.Custo"

				ElseIf !Empty(cPlan:= AMM->(GetAdvFVal("AMM","AMM_PLNORC",xFilial("AMM")+cProj,1)))
					cVPln:= ALV->(GetAdvFVal("ALV","ALV_VERSAO",xFilial("ALV")+cPlan,1))
					If !Empty (ALX->(GetAdvFVal("ALX","ALX_CC",xFilial("ALX")+cPlan+cVPln+STUFF(oTree:GetCargo(),1,1,''),5)))
						MenuItem STR0040		Block bM3DCTT  //"Desvincular C.Custo"
						MenuItem STR0041		Block bM3ECTT //"Expandir C.Custo"
				   		MenuItem STR0042		Block bM3VPLN //"Visualizar Planilha"
			   			MenuItem STR0035		Block bM3EPLN  //"Planejar Planilha"
					Else
						MenuItem STR0040		Block bM3DCTT  //"Desvincular C.Custo"
						MenuItem STR0041	   	Block bM3ECTT //"Expandir C.Custo"
					EndIf
				Else
					MenuItem STR0040	Block bM3DCTT 	 //"Desvincular C.Custo"
					MenuItem STR0041	Block bM3ECTT	 //"Expandir C.Custo"
				EndIf
			ElseIf cType == 3
				If CTT->(GetAdvFVal("CTT","CTT_CLASSE",xFilial("CTT")+STUFF(oTree:GetCargo(),1,1,''),1)) == '2'
					If !Empty(cPlan:= AMM->(GetAdvFVal("AMM","AMM_PLNORC",xFilial("AMM")+cProj,1)))
				   		cVPln:= ALV->(GetAdvFVal("ALV","ALV_VERSAO",xFilial("ALV")+cPlan,1))
						If !Empty (ALX->(GetAdvFVal("ALX","ALX_CC",xFilial("ALV")+cPlan+cVPln+STUFF(oTree:GetCargo(),1,1,''),5)))
					   		MenuItem STR0042		Block bM3VPLN 	 //"Visualizar Planilha"
				   			MenuItem STR0035		Block bM3EPLN  //"Planejar Planilha"
						EndIf
					EndIf
				EndIf
			EndIf
		EndMenu
		oMenu:Activate(x, y)
	EndIf
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
	Local Area	:= ALV->(GetArea())

	ALV->(DbSetOrder(1))
	If ALV->(DbSeek(xFilial("ALV")+clPln))
		PCO06Fase()
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
ฑฑบ          ณ usados pelo axcadastro tabela AMP                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FPrUn()
    M->AMP_CODPRO:=STUFF(oTree:GetCargo(),1,1,'')
    M->AMP_PROJET:=POSICIONE("AMM",1,xFilial("AMM")+STUFF(oTree:GetCargo(),1,1,''),"AMM_DESCRI")
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
Function A011VldUni()
	Local cProj := FRetProj()
	Local llRet := .T.
	If (llRet := EXISTCPO("AMF"))
		DbSelectArea("AMP")
		AMP->(DBSetOrder(2))
		If (DbSeek(xFilial("AMP")+cProj+M->AMP_CODUNI))
			Aviso(STR0008,STR0043,{STR0010})  //"Aten็ใo"###"Unidade jแ estแ vinculada a esse projeto"###"Ok"
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
Function A011VldPln()
	Local llRet	:= .T.
	If (llRet:= ExistCpo("ALV"))
		DbSelectArea("AMM")
		AMM->(DbSetOrder(2))
		If AMM->(DbSeek(xFilial("AMM")+M->AMM_PLNORC))
			Aviso(STR0008,STR0044,{STR0010}) //"Aten็ใo"###"Planilha Vinculada a outro Projeto"###"Ok"
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
    Local alCpoUn 	:= {"AMP_CODPRO","AMP_CODUNI","NOUSER","NOUSER"}
    Local Area		:= GetArea("AMP")
	DbSelectArea("AMP")
	AMP->(DbSetOrder(2)) //Projeto+Unidade Orc.
	If AMP->(DbSeek(xFilial("AMP")+cProj+STUFF(oTree:GetCargo(),1,1,'')))
		While AMP->(!EOF()) .and. AMP->AMP_CODUNI == STUFF(oTree:GetCargo(),1,1,'') .and. AMP->AMP_CODPRO == cProj
			nlAx += 1
			If nlAx > 1
				Aviso(STR0008,STR0045,{STR0010}) //"Aten็ใo"###"Nใo ้ possivel desvincular unidade do projeto, por conter C.Custo vinculados"###"Ok"
				Exit
			EndIf
			AMP->(DbSkip())
	   	EndDo
	EndIf
	If nlAx == 1
		If AMP->(DbSeek(xFilial("AMP")+cProj+STUFF(oTree:GetCargo(),1,1,'')))
			AxDeleta("AMP",AMP->(RECNO()),5,,alCpoUn,,{bAxParam,bVldExc,bAxParam,bAxParam},,.T.)
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
ฑฑบPrograma  ณPCOA011CPLNบAutor  ณJair Ribeiro        บ Data ณ  10/20/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relacionamento PROJETO X PLANILHA Menu "Criar Planilha"	  บฑฑ
ฑฑบ			 ณ altera PROMPT                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA011PLN()
	Local llRet	:= .F.
	AMM->(DbSetOrder(1))
	If AMM->(DbSeek(xFilial("AMM")+STUFF(oTree:GetCargo(),1,1,'')))
		If RecLock("AMM",.F.)
			AMM->AMM_PLNORC	:= M->ALV_CODIGO
			MsUnlock()
			oTree:ChangePrompt(oTree:GetPrompt()+STR0029+ALLTRIM(M->ALV_CODIGO) +" - "+ ALLTRIM(M->ALV_DESCRI),oTree:GetCargo()) //" | PLN PLANEJ: "
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

	If !Empty(ALLTRIM(AMM->(GetAdvFVal("AMM","AMM_PLNORC",xFilial("AMM")+STUFF(oTree:GetCargo(),1,1,''),1))))
		Aviso(STR0008,STR0030,{STR0010})  //"Aten็ใo"###"Projeto jแ estแ vinculado a uma Planilha"###"Ok"
   	Else
		alRetPq:=FWinPlan()
		If alRetPq[1,1]
			DbSelectArea("AMM")
			AMM->(DbSetOrder(1))
			If AMM->(DbSeek(xFilial("AMM")+STUFF(oTree:GetCargo(),1,1,'')))
				If RecLock("AMM",.F.)
					AMM->AMM_PLNORC	:= alRetPq[1,2]
					MsUnlock()
					oTree:ChangePrompt(oTree:GetPrompt()+STR0029+ALLTRIM(alRetPq[1,2]) +" - "+ ALLTRIM(alRetPq[1,3]),oTree:GetCargo())  //" | PLN PLANEJ: "
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
	Local alComb	:= {STR0046,STR0047,STR0048} //"Codigo"###"Versao"###"Descricao"
	Local llOk 		:= .F.
	Local Area		:= GetArea()

	Local aCols		:= {}
	Private clVSearch	:= Space(TamSx3("ALV_CODIGO")[1])
	lTela :=.F.
	oDlg:=MSDialog():New(000,000,360,600,STR0049,,,,,,,,,.T.) //"Planilhas Planejamento"
		oTwPln	:= TWBrowse():New( 01,01,299,150,,{STR0046,STR0047,STR0048},{TamSx3("ALV_CODIGO")[1],TamSx3("ALV_VERSAO")[1] ,TamSx3("ALV_DESCRI")[1]},oDlg,,,,,{|| FRetPln(alRet,.t.,aCols, oTwPln),oDlg:End()},,,,,,,.F.,,.T.,,.F.) //"Codigo"###"Versao"###"Descricao"
		DbSelectArea("ALV")
		ALV->(DbGoTop())
		DbSelectArea("AMM")
		AMM->(DbSetOrder(2))

		While ALV->(!EOF())
			If !AMM->(DbSeek(xFilial("AMM")+ALV->ALV_CODIGO)) .and. ALV->ALV_FASE != '03'
				AADD(aCols,{ALV->ALV_CODIGO, ALV->ALV_VERSAO,ALV->ALV_DESCRI})
			EndIf
			ALV->(DbSkip())
		EndDo

		If Len(aCols) == 0
			aCols := Array(1,3)
		EndIf

		oTwPln:SetArray(aCols)
		oTwPln:bLine := {|| {aCols[oTwPln:nAt,01],aCols[oTwPln:nAt,02],aCols[oTwPln:nAt,03]}}

       	oSearchCb	:= TComboBox():New(155,001,{|u|if(PCount()>0,clISearch:=u,clISearch)},alComb,150,20,oDlg,,{|| FChange(clISearch)},,,,.T.,,,,,,,,,'clISearch')

       	oSearchGt	:= TGet():New(168,001,{|u| if(PCount()>0,clVSearch:=u,clVSearch)}, oDlg,150,06,'@!',{||},,,,,,.T.,,,,,,,,,,'clVSearch')

       	oSearchBt	:=TButton():New(155,155,STR0050,oDlg,{|| FSearchPln(clISearch, clVSearch, @aCols, @oTwPln,alComb)}	,45,10,,,,.T.)  //'Pesquisar'
       	oOkBt		:=TButton():New(155,205,STR0051		,oDlg,{|| FRetPln(@alRet, .T.,aCols,oTwPln),oDlg:End()}				,45,10,,,,.T.) //'Ok'
       	oCancelBt	:=TButton():New(155,255,STR0052	,oDlg,{|| FRetPln(@alRet, .F.)				,oDlg:End()}				,45,10,,,,.T.) //'Cancelar'

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
	If Ind == STR0046 //"Codigo"
		clVSearch := space(TamSx3("ALV_CODIGO")[1])
	ElseIf Ind == STR0047 //"Versao"
		clVSearch := space(TamSx3("ALV_VERSAO")[1])
	Else
		clVSearch := space(TamSx3("ALV_DESCRI")[1])
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
	Local clQry		:= IiF(clISearch != STR0047,"SELECT DISTINCT ALV.ALV_CODIGO ", "SELECT DISTINCT ALV.ALV_VERSAO ")  //"Versao"
	Local nlPos		:= 0

	If !Empty(clVSearch)
		clQry +=" FROM "+RetSqlName("ALV")+" ALV"
		clQry +=" INNER JOIN "+RetSqlName("AMM")+" AMM"
		clQry +=" ON("
		clQry +=" AMM.AMM_PLNORC <> ALV.ALV_CODIGO"
		clQry +=" AND AMM.AMM_FILIAL = '"+xFilial("AMM")+"'"
		clQry +=" AND AMM.D_E_L_E_T_ <> '*'"
		clQry +=" )"
		clQry +=" WHERE ALV.ALV_FASE <> '03'"
		clQry +=" AND ALV.ALV_FILIAL = '"+xFilial("ALV")+"'"
		clQry +=" AND ALV.D_E_L_E_T_ <> '*'"

		If clISearch == "Codigo"
			clQry +=" AND ALV.ALV_CODIGO LIKE '"+AllTrim(clVSearch)+"%'"
		ElseIf clISearch == "Versao"
			clQry +=" AND ALV.ALV_VERSAO LIKE '"+AllTrim(clVSearch)+"%'"
		Else
			clQry +=" AND ALV.ALV_DESCRI LIKE '"+AllTrim(clVSearch)+"%'"
		EndIf

		If Select("QPLN")>0
			DbSelectArea("QPLN")
			QPLN->(DbCloseArea())
		EndIf

		clQry := ChangeQuery(clQry)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,clQry),"QPLN",.F.,.T.)

		DbSelectArea("QPLN")
		If QPLN->(!EOF())
			If clISearch != STR0047 //"Versao"
				If (nlPos:= Ascan(aCols,{|aX| aX[1] == QPLN->ALV_CODIGO}))>0
				 	oTwPln:nAt:= nlPos
				EndIf
			ElseIf (nlPos:= Ascan(aCols,{|aX| aX[2] == QPLN->ALV_VERSAO}))>0
				oTwPln:nAt := nlPos
			EndIf
		EndIf
		If nlPos == 0
			Aviso(STR0008,STR0053,{STR0010}) //"Aten็ใo"###"Nใo foi encontrado valor referente a pesquisa"###"Ok"
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
	Local Area := AMM->(Getarea())
	If !Empty(AMM->(GetAdvFVal("AMM","AMM_PLNORC",xFilial("AMM")+STUFF(oTree:GetCargo(),1,1,''),1)))
		If MsgNoYes(STR0054) //"Deseja realmente desvincular planilha desse projeto?"
			DbSelectArea("AMM")
			AMM->(DbSetOrder(1))
			If AMM->(DbSeek(xFilial("AMM")+STUFF(oTree:GetCargo(),1,1,'')))
				If RecLock("AMM",.F.)
					AMM->AMM_PLNORC	:= space(TamSx3("AMM_PLNORC")[1])
					MsUnlock()
					oTree:ChangePrompt(ALLTRIM(AMM->AMM_CODIGO) +" - "+ ALLTRIM(AMM->AMM_DESCRI),oTree:GetCargo())
					FPanelPro(STUFF(oTree:GetCargo(),1,1,''))
				EndIf
			EndIf
		EndIf
	Else
		Aviso(STR0008,STR0055,{STR0010}) //"Aten็ใo"###"Projeto nใo contem planilha vinculada"###"Ok"
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
Static Function FVincCTT()
	Local alRetPq	:= {}
	Local cProj	:= FRetProj()
	Local nlAx	:= 0

	DbSelectarea("AMP")
	AMP->(DbSetOrder(2))
	If AMP->(Dbseek(xFilial("AMP")+cProj+STUFF(oTree:GetCargo(),1,1,'')))
		While AMP->(!EOF()) .and. AMP->AMP_CODPRO == cProj .and. AMP->AMP_CODUNI == STUFF(oTree:GetCargo(),1,1,'')
			nlAx += 1
			If nlAx > 1
				Aviso(STR0008,STR0056,{STR0010}) //"Aten็ใo"###"Jแ existe Centro de Custo Sintetico Relacionado a Unidade"###"Ok"
				Exit
			EndIf
			AMP->(DbSkip())
		EndDo
	EndIf
	If nlAx == 1
		alRetPq:=FWinCTT()
		If alRetPq[1,1]
		DbSelectArea("AMP")
			If RecLock("AMP",.T.)
		   		AMP->AMP_FILIAL	:= xFilial("AMP")
				AMP->AMP_CODPRO	:= cProj
				AMP->AMP_CODUNI	:= STUFF(oTree:GetCargo(),1,1,'')
				AMP->AMP_CCUSTO	:= alRetPq[1,2]
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
	oDlg:=MSDialog():New(000,000,330,600,STR0057,,,,,,,,,.T.)  //"Centro de Custo"
		oTwPln	:= TWBrowse():New( 01,01,299,150,,{STR0046,STR0058},{TamSx3("CTT_CUSTO")[1],TamSx3("CTT_DESC01")[1]},oDlg,,,,,{|| FRetCTT(alRet,.t.,aCols, oTwPln),oDlg:End()},,,,,,,.F.,,.T.,,.F.) //"Codigo"###"Descri็ใo"
		DbSelectArea("CTT")
		CTT->(DbGoTop())
		DbSelectArea("AMP")
		AMP->(DbSetOrder(3)) //FILIAL+PROJETO+C.CUSTO

		While CTT->(!EOF())
			If !AMP->(DbSeek(xFilial("AMP")+cProj+CTT->CTT_CUSTO)) .and. CTT->CTT_CLASSE != '2'
				AADD(aCols,{CTT->CTT_CUSTO, CTT->CTT_DESC01})
			EndIf
			CTT->(DbSkip())
		EndDo

		If Len(aCols) == 0
			aCols := Array(1,3)
		EndIf

		oTwPln:SetArray(aCols)
		oTwPln:bLine := {|| {aCols[oTwPln:nAt,01],aCols[oTwPln:nAt,02]}}

		oSay:= tSay():New(157,005,{||STR0059},oDlg,,,,,,.T.,,,020,020)   //"C.Custo"
       	oSearchGt	:= TGet():New(155,030,{|u| if(PCount()>0,clVSearch:=u,clVSearch)}, oDlg,121,06,'@!',{||},,,,,,.T.,,,,,,,,,,'clVSearch')

       	oSearchBt	:=TButton():New(155,155,STR0050,oDlg,{|| FSearchCTT(clVSearch, @aCols, @oTwPln)		}		,45,10,,,,.T.) //'Pesquisar'
       	oOkBt		:=TButton():New(155,205,STR0051		,oDlg,{|| FRetCTT(@alRet, .T.,aCols,oTwPln),oDlg:End()	}		,45,10,,,,.T.) //'Ok'
       	oCancelBt	:=TButton():New(155,255,STR0052	,oDlg,{|| FRetCTT(@alRet, .F.)				,oDlg:End()	}		,45,10,,,,.T.) //'Cancelar'
	oDlg:Activate(,,,.T.,,,)
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
Static Function FSearchCTT(admin, aCols, oTwPln,alComb)
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
			Aviso(STR0008,STR0053,{STR0010}) //"Aten็ใo"###"Nใo foi encontrado valor referente a pesquisa"###"Ok"
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
	Local cProj	:= FRetProj()
	Local Area	:= CTT->(Getarea())

	DbSelectArea("AMP")
	AMP->(DbSetOrder(4))// AMP_FILIAL+AMP_CODPRO+AMP_CCSUP
	If AMP->(DbSeek(xFilial("AMP")+cProj+STUFF(oTree:GetCargo(),1,1,'')))
		Aviso(STR0008,STR0060,{STR0010}) //"Aten็ใo"###"Essa a็ใo jแ foi executada"###"Ok"
	Else
		DbSelectArea("CTT")
		CTT->(DbSetOrder(5))//CTT_FILIAL+CTT_CCSUP
		If CTT->(Dbseek(xFilial("CTT")+STUFF(oTree:GetCargo(),1,1,'')))
			While CTT->(!EOF()) .And. CTT->CTT_CCSUP == STUFF(oTree:GetCargo(),1,1,'')
				If (!Empty(AMP->(GetAdvFVal("AMP","AMP_CCSUP",xFilial("AMP")+cProj+CTT->CTT_CUSTO,4))))
					Aviso(STR0008,STR0061+CTT->CTT_CUSTO,{STR0010}) //"Aten็ใo"###"Centro de Custo Invalido na Estrutura: "###"Ok"
				ElseIf RecLock("AMP",.T.)
					AMP->AMP_FILIAL	:= xFilial("AMP")
					AMP->AMP_CODPRO	:= cProj
					AMP->AMP_CODUNI	:= AMP->(GetAdvFVal("AMP","AMP_CODUNI",xFilial("AMP")+cProj+STUFF(oTree:GetCargo(),1,1,''),1))
					AMP->AMP_CCUSTO	:= CTT->CTT_CUSTO
					AMP->AMP_CCSUP	:= CTT->CTT_CCSUP
					MsUnlock()
					clPrompt:= ALLTRIM(CTT->CTT_CUSTO) +" - "+ ALLTRIM(CTT->CTT_DESC01)
					oTree:AddItem(clPrompt,"C"+CTT->CTT_CUSTO,'SIMULACA','SIMULACA',2,{|| },{|oTree,x,y| FPopUp(oTree,oFWLayer,3,x,y)})
				EndIf
				CTT->(DbSkip())
			EndDo
		Else
			Aviso(STR0008,STR0062,{STR0010}) //"Aten็ใo"###"C.Custo nใo possui inferiores"###"Ok"
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
	DbSelectArea("AMP")
	AMP->(DbSetOrder(4))// AMP_FILIAL+AMP_CODPRO+AMP_CCSUP
	If AMP->(DbSeek(xFilial("AMP")+cProj+STUFF(oTree:GetCargo(),1,1,'')))
		Aviso(STR0008,STR0063,{STR0010}) //"Aten็ใo"###"C.Custo possui C.Custo Inferiores"###"Ok"
	ElseIf MsgYesNo(STR0064) //"Deseja realmente desvincular C.Custo?"
		AMP->(DbSetOrder(3))// AMP_FILIAL+AMP_CODPRO+AMP_CCUSTO
		If AMP->(DbSeek(xFilial("AMP")+cProj+STUFF(oTree:GetCargo(),1,1,'')))
			If RecLock("AMP",.F.,.T.)
	   			AMP->(DbDelete())
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
Static Function FOpenPln(cPln,cVpln,lPlanej)
    Local Area		:= ALV->(GetArea())
    ALV->(DbSetOrder(1))
    ALV->(DbSeek(xFilial("ALV")+cPln+cVpln))
   	If lPlanej
   		Pco490TpPl()
   	Else
   		AxVisual("ALV",ALV->(RECNO()),2)
   	EndIf
    RestArea(Area)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA011TOTบAutor  ณJair Ribeiro        บ Data ณ  11/25/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Total do Projeto                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA011TOT(cPlanej,cVersao)
	Local nRet 		:= 0
	Local cQry		:= ""
	Default cPlanej	:= ""
	Default cVersao := ""

	cQry:= "SELECT SUM(ALY.ALY_QUANT * ALY.ALY_VALOR) TOTAL"+chr(13)+chr(10)
	cQry+= " FROM "+RetSqlName("ALY")+" ALY"+chr(13)+chr(10)
	cQry+= " WHERE ALY.ALY_FILIAL	= '"+xFilial("ALY")+"'"+chr(13)+chr(10)
	If !Empty(cPlanej)
		cQry+= " AND ALY.ALY_PLANEJ = '"+cPlanej+"'"+chr(13)+chr(10)
	EndIf
	If !Empty(cVersao)
		cQry+= " AND ALY.ALY_VERSAO	= '"+cVersao+"'"+chr(13)+chr(10)
	EndIf
	cQry+= " AND ALY.D_E_L_E_T_ = ' '"+chr(13)+chr(10)


	If Select("TPLANEJ") > 0
		TPLANEJ->(DBCLOSEAREA())
	EndIf
	cQry := ChangeQuery(cQry)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TPLANEJ",.T.,.T.)

	nRet:= TPLANEJ->TOTAL
	TPLANEJ->(DbCloseArea())
Return nRet