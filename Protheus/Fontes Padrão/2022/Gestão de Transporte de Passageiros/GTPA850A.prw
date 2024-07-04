#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "APWIZARD.CH"

Static c850RetFil	:= ''
/*/{Protheus.doc} GTPA850A
ROtina utilizada para o novo processo de cte-os sendo criado uma tela para 
preenchimento do percurso de forma mais simplificada, utiliado no "SXB" - "H61UFS"

@type  Function
@author user
@since 16/05/2022
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA850A()
	Local aBotoes     := {} //Botoes da tela
	Local aStructBrw  := {} //Estrutura da tela
	Local aCamposBrw  := {} //Campos que compoem a tela
	Local aColsBrw    := {} //Colunas que compoem a tela
	Local aTodos      := {}
	Local cAliasJob	  := GetNextAlias()
	
	c850RetFil	:= ALLTRIM(M->H61_UFPERC) + ';'
	lTela 		:= .F.
	
	Aadd(aCamposBrw,"AVB_FILIAL")
	Aadd(aCamposBrw,"AVB_DESC")
	
	Aadd(aStructBrw, {"MARK",       "C",   1, 0})
	Aadd(aStructBrw, {"AVB_FILIAL", "C",  TAMSX3("DL5_FILDOC")[1], 0})
	Aadd(aStructBrw, {"AVB_DESC",   "C",  50, 0})
	
	oBrwCol := FWBrwColumn():New()
	oBrwCol:SetType('C')
	oBrwCol:SetData(&("{|| AVB_FILIAL }"))
	oBrwCol:SetTitle('Código')
	oBrwCol:SetSize(TAMSX3("DL5_FILDOC")[1])
	oBrwCol:SetDecimal(0)
	oBrwCol:SetPicture("")
	oBrwCol:SetReadVar("AVB_FILIAL")
	AAdd(aColsBrw, oBrwCol)
	
	oBrwCol := FWBrwColumn():New()
	oBrwCol:SetType('C')
	oBrwCol:SetData(&("{|| AVB_DESC }"))
	oBrwCol:SetTitle('Descrição')
	oBrwCol:SetSize(50)
	oBrwCol:SetDecimal(0)
	oBrwCol:SetPicture("")
	oBrwCol:SetReadVar("AVB_DESC")
	AAdd(aColsBrw, oBrwCol)

	If Len(GetSrcArray("FWTEMPORARYTABLE.PRW")) > 0 .And. !(InTransaction())
		cAliComp := GetNextAlias()
		oTempTable := FWTemporaryTable():New("AVB")
		oTempTable:SetFields(aStructBrw)
		oTempTable:AddIndex("01",{"AVB_FILIAL"})
		oTempTable:Create()
		cAliComp := oTempTable:GetAlias()
	EndIf
	
	DbSelectArea("AVB")
	
	BeginSQL Alias cAliasJob
		SELECT SX5.X5_CHAVE, SX5.X5_DESCRI 
		FROM %Table:SX5% SX5
		WHERE SX5.X5_TABELA = '12'
		AND SX5.%NotDel%
	EndSQL

	While (cAliasJob)->(!Eof())
		("AVB")->(RecLock(("AVB"), .T.))
		("AVB")->AVB_FILIAL := ALLTRIM((cAliasJob)->(X5_CHAVE))
		("AVB")->AVB_DESC   := ALLTRIM((cAliasJob)->(X5_DESCRI))
		("AVB")->(MsUnlock())
		(cAliasJob)->(DbSkip())
	End

	(cAliasJob)->(dbCloseArea())
	
	oDlgMan := FWDialogModal():New()
	oDlgMan:SetBackground(.F.)
	oDlgMan:SetTitle("Estados")
	oDlgMan:SetEscClose(.F.)
	oDlgMan:SetSize(300, 400)
	oDlgMan:CreateDialog()

	oPnlModal := oDlgMan:GetPanelMain()

	oFWLayer := FWLayer():New()                 //-- Container
	oFWLayer:Init(oPnlModal, .F., .F.)          //-- Inicializa container

	oFWLayer:AddLine('LIN', 100, .F.)           //-- Linha
	oFWLayer:AddCollumn('COL', 100, .F., 'LIN') //-- Coluna
	oPnlObj := oFWLayer:GetColPanel('COL', 'LIN')
	
	oMarkBrw := FWMarkBrowse():New()
	oMarkBrw:SetMenuDef("GTPA850A")
	oMarkBrw:SetTemporary(.T.)
	oMarkBrw:SetColumns(aColsBrw)
	oMarkBrw:SetAlias("AVB")
	oMarkBrw:SetFieldMark("MARK")
	oMarkBrw:SetDescription("Seleciona os Estados")
	oMarkBrw:SetOwner(oPnlObj)
	oMarkBrw:SetAllMark({||.F.})
	
	bConfir := {|| gtp850aSelFil(@c850RetFil), oDlgMan:DeActivate()}

	bCancel := {|| c850RetFil := ALLTRIM(M->H61_UFPERC), oDlgMan:DeActivate()}
	    
	//-- Cria botoes de operacao
	Aadd(aBotoes, {"", 'Confirmar', bConfir, , , .T., .F.}) // 'Confirmar'
	Aadd(aBotoes, {"", 'Cancelar', bCancel, , , .T., .F.}) // 'Cancelar'
	oDlgMan:AddButtons(aBotoes)
	
	aTodos := Separa(AllTrim(ALLTRIM(M->H61_UFPERC)),';')
	If Len(aTodos) <= 0
		aadd(aTodos,"N")
	EndIf
	
	oMarkBrw:Activate()
	While AVB->(!Eof())
		If Upper(Trim(aTodos[1])) == Upper('Todos')
			oMarkBrw:MarkRec() 
		Else
			If aScan(aTodos,Trim(AVB->(AVB_FILIAL))) > 0
				oMarkBrw:MarkRec() 
			EndIf
		EndIf
		AVB->(dbSkip())
	EndDo
	oMarkBrw:Refresh(.T.)
	oMarkBrw:GoTop(.T.)
	
	oDlgMan:Activate()
	
	//-- Ao finalizar, elimina tabelas temporarias
	DbSelectArea('AVB')
	DbCloseArea()
	
Return .T.

/*/{Protheus.doc} A850SELFil
//Alimenta a variavel c850RetFil com as filiais selecionadas pelo usuario.
@author henrique.toyada
@since 24/05/2022
@version 
@return return, 
/*/
Function gtp850aSelFil(c850RetFil)
	Local aArea     := GetArea()
	Local lTodos    := .T.
	Local nX        := 1
	Local nV        := 0
	Local nTotal    := 0
	Local nFil      := 0
	Local aMarcados := {}
	Local aRetFil   := {}
	lTela := .F.
	
	//determina quantos filiais é posssivel selecionar
	nFil := 10//TAMSX3("H61_UFPERC")[1] //INT(nTamanho/(Len(aSM0[1][2])+1))
    
	If !(empty(c850RetFil))
		aRetFil := Separa(c850RetFil,';')
		For nV := 1 To Len(aRetFil)
			nTotal++
		Next
	EndIf
	DbSelectArea('AVB')
	dbGoTop()
	While !(EoF())
		If !Empty(MARK)
		    //Sistema preeche o campo Filial de documento com a quantidade maxima de filiais que o campo suporta.
			If (nTotal <= nFil)
				c850RetFil += ALLTRIM(AVB_FILIAL) + ';'
				nTotal++
			EndIf
		Else
			lTodos := .F.
		EndIf
		DbSkip()
	EndDo
	
	//Quando for selecionado todas as filiais o campo Filial de documento é preenchido com a palavra Todos.
	If lTodos
		c850RetFil := 'Todos'
	Else
		aMarcados := Separa(c850RetFil,';')
		c850RetFil := ""
		If Len(aMarcados) > 0
			For nX := 1 To Len(aMarcados)
				If !Empty(aMarcados[nX])
					c850RetFil += aMarcados[nX]
					If nX < (Len(aMarcados) - 1)
						c850RetFil += ';'
					EndIf
				EndIf
			Next
		EndIf
		
		If !(lTodos)
		     //Se a quantidade de filial selecionado for maior que o permitido o sistema avisa e limpa o campo.
			If (nTotal > nFil)
		         //"Limite de filiais exedido"  //"Utiliza opção Marcar / Desmacar para selecionar todos os filiais."
				MsgAlert('Limite do campo excedido ' +' (' + cValToChar(nFil) + '). ' + CHR(13) + "")
				c850RetFil := ""
		         //Retorna somente as filias que cabe no campo para que seja efetuado a consulta
				If Len(aMarcados) > 0
					For nX := 1 To (nTotal - 1)
						c850RetFil += aMarcados[nX]
						If nX < (nTotal - 1)
							c850RetFil += ';'
						EndIf
					Next
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aArea)

Return ( .T. )

/*/{Protheus.doc} RetPercurso
	(long_description)
	@type  Function
	@author user
	@since 24/05/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function RetPercurso()
Local cRet :=''
cRet:=	Alltrim(C850RETFIL)
Return cRet
