#INCLUDE "PROTHEUS.CH" 
#INCLUDE "DBTREE.CH"  
#INCLUDE "FATA300.CH"    
#INCLUDE "CRMDEF.CH"
#INCLUDE "FWMVCDEF.CH"  

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA600D
Rotina de copia da função Ft300F3U5 - FATA300
Rotina de consulta de contatos da entidade utilizada na oportunidade. 
*Nota do desenvolvedor - Foi uma função totalmente copiada, pode ser melhor analisada e refatorada, não fiz por preguiça mesmo*

Achamada desse cara é no F3 adicionado no fonte GTPA600B - G6RSU5

@sample	Ft300F3U5()

@param		Nenhum

@return	ExpL - Verdadeiro / Falso

@author	Teixeira
@since		04/07/2022
@version	12             
/*/
//------------------------------------------------------------------------------
Function GTPA600D()

Local aArea			:= GetArea()
Local aAreaAC8		:= AC8->(GetArea())
Local cQuery		:= ""
Local cEntidade		:= ""
Local cCodEnt		:= ""
Local lRetorno		:= .T.
Local lObfNContat	:= .F.
Local cAliTmp		:= "SU5TMP"
Local cPesq	 		:= Space(50)
Local nRecno		:= 0
Local oDlg			:= Nil
Local oLstBx		:= Nil
Local aContato		:= {}
Local bRet			:= {|| If(!Empty(aTail(oLstBx:aArray[oLstBx:nAt])),(lRetorno := .T.,nRecno := IIf(Len(oLstBx:aArray)>=oLstBx:nAt,aTail(oLstBx:aArray[oLstBx:nAt]),0),oDlg:DeActivate()),(lRetorno := .F.,MsgInfo(STR0208,'')))}
Local bVisual		:= {|| SaveInter(),If(!Empty(aTail(oLstBx:aArray[oLstBx:nAt])),(nRecno := IIf(Len(oLstBx:aArray)>=oLstBx:nAt,aTail(oLstBx:aArray[oLstBx:nAt]),0),ALTERA := .F.,SU5->(DbGoTo(nRecno),A70Visual("SU5",nRecno,2))),Nil),RestInter()}
Local oPesq			:= Nil

cEntidade	:= "SA1"
cCodEnt	:= G6R->G6R_SA1COD+G6R->G6R_SA1LOJ

If lRetorno

	cQuery	:= "SELECT U5_CODCONT,U5_CONTAT,SU5.R_E_C_N_O_ AS RECN FROM " + RetSqlName("SU5") + " SU5 "
	cQuery	+= "INNER JOIN " + RetSqlName("AC8") + " AC8 ON AC8_FILIAL = '"+xFilial("AC8")+"' AND AC8_FILENT = '"+xFilial(cEntidade)+"' "
	cQuery	+= "AND AC8_ENTIDA = '"+cEntidade+"' AND AC8_CODENT = '"+cCodEnt+"' AND AC8_CODCON = U5_CODCONT "
	cQuery	+= "AND AC8.D_E_L_E_T_ = ' ' "
	cQuery	+= "WHERE SU5.D_E_L_E_T_ = ' '"

	cQuery	:= ChangeQuery(cQuery)

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTmp,.T.,.T.)
	DbGoTop()

	While !(cAliTmp)->(Eof())
		AAdd(aContato,{(cAliTmp)->U5_CODCONT,(cAliTmp)->U5_CONTAT,(cAliTmp)->RECN})
		(cAliTmp)->(DbSkip())
	EndDo

	(cAliTmp)->(DbCloseArea())

	If Len(aContato) == 0
		aAdd(aContato,{Nil,Nil,Nil})
	EndIf
	oDlg := FWDialogModal():New()
	oDlg:SetBackground(.F.) // .T. -> escurece o fundo da janela
	oDlg:SetTitle(STR0114)//"Consulta"
	oDlg:SetEscClose(.T.)//permite fechar a tela com o ESC
	oDlg:SetSize(210,270) //cria a tela maximizada (chamar sempre antes do CreateDialog)
	oDlg:EnableFormBar(.T.)

	oDlg:CreateDialog() //cria a janela (cria os paineis)
	oPanel := oDlg:getPanelMain()

	oDlg:createFormBar()//cria barra de botoes

	oDlg:AddButton(STR0135,{|| oDlg:Deactivate()}, STR0139, , .T., .F., .T., )//Cancelar
	oDlg:AddButton(STR0014,{|| Eval(bRet)}, STR0014, , .T., .F., .T., )//OK
	oDlg:AddButton(STR0004,{|| GT600DIncCon(cEntidade,cCodEnt,oLstBx)}, STR0004, , .T., .F., .T., )//Incluir
	oDlg:AddButton(STR0003,{|| Eval(bVisual)}, STR0003, , .T., .F., .T., )//Visualizar

	//Texto de pesquisa
	@ 003,002 MsGet oPesq Var cPesq Size 219,009 COLOR CLR_BLACK PIXEL OF oPanel

	//Interface para selecao de indice e filtro
	@ 003,228 Button STR0002 Size 037,012 PIXEL OF oPanel ACTION IF(!Empty(aTail(oLstBx:aArray[oLstBx:nAt])),Ft300LbxSCon(oLstBx,cPesq),Nil) //Pesquisar

	//ListBox      
	@ 20,03 LISTBOX oLstBx FIELDS HEADER STR0115,STR0116 SIZE 264,139 OF oPanel PIXEL //"Código"###"Nome"
	oLstBx:bLDblClick := bRet

	//Metodos da ListBox
	oLstBx:SetArray(aContato)
	oLstBx:bLine 	:= {|| {aContato[oLstBx:nAt,1],;
	                      aContato[oLstBx:nAt,2],;
	                      aContato[oLstBx:nAt,3]}}
	If FTPDUse(.T.)
		lObfNContat				:= FATPDIsObfuscate("U5_CONTAT",Nil,.T.)
		oLstBx:aObfuscatedCols	:= {.F.,lObfNContat}   
	EndIf   
	oDlg:Activate()
EndIf

If lRetorno
	DbSelectArea("SU5")
	DbGoTo(nRecno)
EndIf

If aArea[1] <> "SU5"
	RestArea(aArea)
EndIf

RestArea(aAreaAC8)
Return(lRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} GT600DIncCon
Rotina de copia da função Ft300F3U5 - FATN300
Inclui um novo contato e associa o mesmo na tabela AC8.	 

@sample		Ft300IncCon(cEntidade,cCodEnt,oLstBx)

@param		ExpC1 - Entidade
			ExpC2 - Codigo da Entidade
			ExpC3 - Objeto ListBox de Contatos

@return		Nenhum

@author	Teixeira
@since		04/07/2022
@version	12             
/*/
//------------------------------------------------------------------------------
Function GT600DIncCon(cEntidade,cCodEnt,oLstBx)

Local aAreaSU5  	:= SU5->(GetArea())	// Guarda area atual
Local aAreaAC8  	:= AC8->(GetArea())	// Guarda area atual
Local cCodCont	  	:= ""          			// Codigo do Contato
Local cContato		:= ""					// Nome do Contato                   
Local nOpcA			:= 0                   	// Confirmou a Inclusao (1=Sim, 2=Nao) 
Local nRecNo		:= 0

Private INCLUI		:= .T. 
Private cCadastro :=  STR0374  //"Contatos - INCLUIR"
SaveInter()

nOpcA 	 	:= A70INCLUI("SU5",0,3) 
cCodCont	:= SU5->U5_CODCONT
cContato	:= Alltrim(SU5->U5_CONTAT)
nRecNo		:= SU5->(RecNo())

If nOpcA == 1
	
	DbSelectArea("AC8")
	//AC8_FILIAL+AC8_CODCON+AC8_ENTIDA+AC8_FILENT+AC8_CODENT
	AC8->(DbSetOrder(1))
	
	If AC8->(!DbSeek(xFilial("AC8")+cCodCont+cEntidade+xFilial(cEntidade)+cCodEnt))
		RecLock("AC8",.T.)
		AC8->AC8_FILIAL := xFilial("AC8")
		AC8->AC8_FILENT := xFilial(cEntidade)
		AC8->AC8_ENTIDA := cEntidade
		AC8->AC8_CODENT := cCodEnt
		AC8->AC8_CODCON := cCodCont
		MsUnLock()
	
	EndIf
	
	aAdd(oLstBx:aArray,{cCodCont,cContato,nRecNo})
	oLstBx:Refresh()
	
EndIf

RestInter()

RestArea(aAreaSU5)
RestArea(aAreaAC8)  

Return Nil
