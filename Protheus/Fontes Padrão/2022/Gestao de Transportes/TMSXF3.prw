#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TMSXF3.CH'

/*-----------------------------------------------------
Para o correto funcionamento da funcao TMSXF3

Necessario declarar a variavel: cRetF3Esp := ''
como PRIVATE no fonte pai, que estara chamando o F3
multivalorado.
Ex: TMSA153.prw

Quando utilizado mais de um retorno deve existir 
mais de um MV_PAR, e a atribuicao sera feita de acordo
com a ordem que foi passado.

Filtro inicial do consulta multivalorado:
Filial = xFilial(tabela) AND D_E_L_E_T_ = ''
Ao utilizar cFiltF3 deve comecar com AND...

Caso necessario que traga os valores deletados 
habilitar o parametros lDelReg := .T.

Exemplo de consulta padrao:

Consulta padrao multivalorado tabela de veiculos
Expressao: TMSXF3('DA3',{'DA3_COD', 'DA3_DESC', 'DA3_PLACA'},{'DA3_PLACA'}, {'MV_PAR01'})

Consulta padrao multivalorado filiais
Expressao: TMSXF3('SM0',,, {'MV_PAR01'})

Variavel de retorno semre utilizar:
cRetF3Esp
-----------------------------------------------------*/

/*/{Protheus.doc} TMSXF3
//Consulta padrao multivalorado 
@author ruan.salvador
@since 20/08/2018
@version 1.0
@param cAliasEsp - Alias da tabela a ser consultada - String - Obrigatorio
@param aColunas - Colunas a serem apresentadas - Array - Nao obrigatorio
@param aRetorno - Array de campo a serem retornados - Array - Obrigatorio
@param aMVPar - Arrya de MV_PAR que devem ser atribuidos - Array - Obrigatorio
@param cFiltF3 - Filtro no padrao SQL - String - Nao obrigatorio
@Param lDelReg - Indica se sera apresentado registros deletados - Nao obrigatorio 
@type function
/*/
Function TMSXF3(cAliasEsp, aColunas, aRetorno, aMVPar, cFiltF3, lDelReg)
	Local oTabTemp := Nil
	Local oFWLayer := Nil
	Local oPnlObj := Nil
	Local oPanelF3 := Nil
	Local oDlgF3 := Nil
	
	Local aCamposBrw := {} //Campos da tela
	Local aStructBrw := {} //Estrutura da tela
	Local aColsBrw := {} //Colunas da tela
	Local aSM0Load := {} //Dados da tabela SM0
	Local aBotoes := {} //Botoes
	Local aSM0 := {} //Estrutura da tabela SM0
	Local aSeek := {} //Pesquisar da tela
	Local aSX3Prop := {} //Propriedades para a pesquisa
	Local aFieldFilter := {} 
	
	Local bConfir := {|| nOpc := 1, oDlgF3:DeActivate()} //Acao do botao confirmar
	Local bCancel := {|| nOpc := 2, oDlgF3:DeActivate()} //Acao do botao cancelar
		
	Local nOpc := 0
	Local nX := 0
	
	Local cTempTab  := GetNextAlias()
	Local cTitulo := ''
	
	Local lValid := .T.
	
	Private cTempF3 := GetNextAlias()
	Private lMarlAll := .T.
	Private oMarkBrw := Nil
	
	Default cAliasEsp := ''
	Default aColunas := {}
	Default aRetorno := {}
	Default aMVPar := {}
	Default lDelReg := .F.
	
	If cAliasEsp != 'SM0'
		lValid := TMSF3Valid(cAliasEsp, aColunas, aRetorno, aMVPar)
	Endif
	
	If lValid
		cTitulo := Iif(cAliasEsp == 'SM0', STR0002, FWX2Nome(cAliasEsp))
		//Cria objeto dialog
		oDlgF3 := FWDialogModal():New()
		oDlgF3:SetBackground(.F.)
		oDlgF3:SetTitle(STR0001 + cTitulo)  //Titulo 
		oDlgF3:SetEscClose(.F.)   //Funcao do Esc
		oDlgF3:SetSize(240, 430)  //Tamanho da tela
		oDlgF3:CreateDialog()
	
		//Recebe o Panel principal do dialog
		oPanelF3 := oDlgF3:GetPanelMain()
		
		//Cria um layer 
		oFWLayer := FWLayer():New()                 //Container
		oFWLayer:Init(oPanelF3, .F., .F.)             //Inicializa container
	
		//Adciona linhas e colunas para o layer
		oFWLayer:AddLine('LIN', 100, .F.)           //Linha
		oFWLayer:AddCollumn('COL', 100, .F., 'LIN')  //Coluna
		
		//Recebe as coordenadas que sera utilizada para fixar o markbrowse
		oPnlObj := oFWLayer:GetColPanel('COL', 'LIN')
		
		If cAliasEsp == 'SM0' //F3 de filiais
			aSize(aRetorno,0)
			aadd(aRetorno, 'M0_FILIAL')
			aSM0 := TMSF3SM0()
			
			aCamposBrw := aSM0[1]
			aStructBrw := aSM0[2]
			aColsBrw := aSM0[3][1]
			
			oTabTemp := FWTemporaryTable():New(cTempF3)
			oTabTemp:SetFields(aStructBrw)
			oTabTemp:AddIndex("01",{"M0_FILIAL"})
			oTabTemp:Create()
			
			aSM0Load   := FWLoadSM0()
			
			For nX := 1 To Len(aSM0Load)
				If aSM0Load[nX][1] == cEmpAnt
					RecLock((cTempF3), .T.)
						(cTempF3)->M0_FILIAL := aSM0Load[nX][2]
						(cTempF3)->M0_DESC   := aSM0Load[nX][7]
						(cTempF3)->M0_CNPJ   := aSM0Load[nX][18]
					MsUnlock(cTempF3)
				EndIf
			Next
			Aadd(aSeek,{'Filial', {{"", 'C',TAMSX3("A1_FILIAL")[1], 0, 'M0_FILIAL', x3Picture('A1_FILIAL')}}, 1, .T. } )
			aAdd(aFieldFilter, {'M0_FILIAL', 'Filial', 'C', TAMSX3("A1_FILIAL")[1], 0, x3Picture('A1_FILIAL')} )
		Else //Qualquer outra tabela
			aCamposBrw := TMSF3Camp(cAliasEsp, aColunas)
			aStructBrw := TMSF3Struc(cAliasEsp, aColunas, aRetorno)
			aColsBrw := TMSF3Acols(cAliasEsp, aCamposBrw)
			
			oTabTemp := FWTemporaryTable():New(cTempF3)
			oTabTemp:SetFields(aStructBrw)
			oTabTemp:AddIndex("01",{aRetorno[1]})
			oTabTemp:Create()
			 
			cTempTab := TMSF3Qry(@cTempTab, cAliasEsp, aColunas, aRetorno, cFiltF3, lDelReg)
			
			(cTempTab)->(dbGoTop())
			While (cTempTab)->(!Eof())
				RecLock((cTempF3), .T.)
					If Empty(aColunas)
						For nX := 1 To (cTempTab)->(FCount()) 
							&((cTempF3)->(FieldName(nX))) := (cTempTab)->(FieldGet(nX))				
						Next nX
					Else
						For nX := 1 To Len(aColunas) 
							&(cTempF3)->(&(aColunas[nX])) := (cTempTab)->(&(aColunas[nX]))
						Next nX
						
						For nX := 1 To Len(aRetorno)
							If aScan(aColunas,aRetorno[nX]) == 0
								&(cTempF3)->(&(aRetorno[nX])) := (cTempTab)->(&(aRetorno[nX]))
							EndIf
						Next nX
					Endif
				MsUnlock(cTempF3)
				(cTempTab)->(DbSkip())
			EndDo
			(cTempTab)->(DbCloseArea())
			
			aSX3Prop := TamSX3(aRetorno[1]) 
			Aadd(aSeek,{GetSx3Cache(aRetorno[1],'X3_TITULO'), {{"",aSX3Prop[3],aSX3Prop[1],aSX3Prop[2],aRetorno[1],x3Picture(aRetorno[1])}}, 1, .T. } )
			For nX := 1 To Len(aColunas)
				aSX3Prop := TamSX3(aColunas[nX]) 
				aAdd(aFieldFilter, {aColunas[nX], GetSx3Cache(aColunas[nX],'X3_TITULO'),aSX3Prop[3], aSX3Prop[1], aSX3Prop[2], x3Picture(aColunas[nX])} )
			Next nX
		EndIf
		
		If (cTempF3)->(!Eof())
			//Cria um browse do tipo mark
			oMarkBrw := FWMarkBrowse():New()
			oMarkBrw:SetMenuDef("TMSXF3")
			oMarkBrw:SetTemporary(.T.)
			oMarkBrw:SetColumns(aColsBrw)
			oMarkBrw:SetAlias(cTempF3)
			oMarkBrw:SetFieldMark("MARK") 
			oMarkBrw:SetOwner(oPnlObj)
			oMarkBrw:SetAllMark({||.F.})
			oMarkBrw:oBrowse:SetUseFilter(.T.)
			oMarkBrw:oBrowse:SetUseCaseFilter(.T.)
			oMarkBrw:oBrowse:SetFieldFilter(aFieldFilter)
			oMarkBrw:oBrowse:SetDBFFilter(.T.)
			oMarkBrw:SetSeek(,aSeek)
			
			//Cria botoes
			Aadd(aBotoes, {"", STR0003, bConfir, , , .T., .F.}) // 'Confirmar'
			Aadd(aBotoes, {"", STR0004, bCancel, , , .T., .F.}) // 'Cancelar'
			oDlgF3:AddButtons(aBotoes)
			
			oMarkBrw:Activate()
			TMSF3Ini(aRetorno, aMVPar)
			
			oMarkBrw:Refresh(.T.)
			oMarkBrw:GoTop(.T.)
			
			//Ativa a tela
			oDlgF3:Activate()	
			
			If nOpc == 1
				If !TMSF3Ret(cTempF3, aRetorno, aMVPar)
					cRetF3Esp := &(aMVPar[1])
				EndIf
				(cTempF3)->(DbCloseArea())
			Else
				cRetF3Esp := &(aMVPar[1])
				(cTempF3)->(DbCloseArea())
			EndIf
		Else
			Help( ,, STR0005,, STR0006, 1, 0 ) //Tabela temporaria nao trouxe registros
		EndIf
	EndIf
	
	//Libera memoria
	FwFreeObj(oTabTemp)
	FwFreeObj(oPnlObj)
	FwFreeObj(oPanelF3)
	FwFreeObj(oDlgF3)
	FwFreeObj(oMarkBrw)

	FwFreeObj(aCamposBrw)
	FwFreeObj(aStructBrw)
	FwFreeObj(aColsBrw)
	FwFreeObj(aSM0Load)
	FwFreeObj(aBotoes)
	FwFreeObj(aSM0)

Return .T.

/*/{Protheus.doc} Menudef
//Menudef da consulta padrao multivalorado 
@author ruan.salvador
@since 20/08/2018
@version 1.0
@type static function
/*/
Static Function Menudef()
	Local aRotina := {}

	aAdd(aRotina, {STR0007, 'TMSF3Mark()', 0, 3, 0, NIL}) //Botao marcar/desmarca todos

Return aRotina

/*/{Protheus.doc} TMSF3Valid
//Validacoes
@author ruan.salvador
@since 20/08/2018
@version 1.0
@type static function
/*/
Static Function TMSF3Valid(cAliasEsp, aColunas, aRetorno, aMVPar)
	Local lValid := .T.
	Local nX := 0
	
	If !Empty(cAliasEsp) .And. TableInDic(cAliasEsp)
		If !Empty(aColunas)
			If Valtype(aColunas) == 'A'
				For nX := 1 To len(aColunas)
					If !&(cAliasEsp)->(ColumnPos(aColunas[nX])) > 0
						Help( ,, STR0005,, STR0008 + aColunas[nX] + STR0009, 1, 0 ) //Help Coluna X invalida
						lValid := .F.
						exit
					EndIf
				Next nX
			Else
				Help( ,, STR0005,, STR0010, 1, 0 ) //Help aColunas deve ser do tipo array
				lValid := .F.
			EndIf
		EndIf
		
		If !Empty(aRetorno) .And. lValid 
			If Valtype(aRetorno) == 'A'
				For nX := 1 To len(aRetorno)
					If !&(cAliasEsp)->(ColumnPos(aRetorno[nX])) > 0
						Help( ,, STR0005,, STR0008 + aRetorno[nX] + STR0009, 1, 0 )//Help coluna X invalida
						lValid := .F.
						exit
					EndIf
				Next nX
			Else
				Help( ,, STR0005,, STR0011, 1, 0 ) //Help aRetorno deve ser do tipo array
				lValid := .F.
			Endif
		ElseIf lValid
			Help( ,, STR0005,, STR0012, 1, 0 )//Help Informe as coluna de retorno
			lValid := .F.
		EndIf
		
		If !Empty(aMVPar) .And. lValid
			If Valtype(aMVPar) == 'A'
				For nX := 1 To len (aMVPar)
					If Valtype(aMVPar[nX]) == 'U'
						Help( ,, STR0005,, STR0013, 1, 0 ) //Help MV_PAR invalido
						lValid := .F.
						exit
					EndIf
				Next nX
			Else
				Help( ,, STR0005,, STR0014, 1, 0 ) //Help aMVPar deve ser do tipo array
				lValid := .F.
			Endif
		ElseIf lValid
			Help( ,, STR0005,, STR0015, 1, 0 ) //Help Informe os MV_PAR de retorno
			lValid := .F.
		EndIf
		
		If Len(aRetorno) > Len(aMVPar) .And. lValid
			Help( ,, STR0005,, STR0016, 1, 0 ) //Nao pode have mais retornos do que MV_PAR
			lValid := .F.
		ElseIf Len(aRetorno) < Len(aMVPar) .And. lValid
			Help( ,, STR0005,, STR0017, 1, 0 ) //Nao pode have mais MV_PAR do que retornos
			lValid := .F.
		EndIf
	Else
		Help( ,, STR0005,, STR0018, 1, 0 ) //Help Tabela invalida
		lValid := .F.
	EndIf
	
Return lValid

/*/{Protheus.doc} TMSF3Camp
//Campos da consulta padrao 
@author ruan.salvador
@since 20/08/2018
@version 1.0
@param cAliasEsp - Alias da tabela a ser consultada - Caracteres
@param aColunas - Colunas a serem apresentadas - Array
@type static function
/*/
Static Function TMSF3Camp(cAliasEsp, aColunas)
	Local cAliasAux:= cAliasEsp
	Local aCamposBrw := {}
	
	Local nX := 0
	Local nY := 1

	While &(cAliasEsp)->(columnpos(cAliasAux+"_FILIAL")) == 0
		cAliasAux:= SubStr(cAliasAux,nY)
		nY++
	EndDo
	
	If Empty(aColunas)
		For nX := 1 To &(cAliasEsp)->(FCount())
			If &(cAliasEsp)->(FieldName(nX)) != cAliasAux+"_FILIAL"
				Aadd(aCamposBrw,&(cAliasEsp)->(FieldName(nX)))
			EndIf			
		Next nX
	Else
		For nX := 1 To Len(aColunas)
			Aadd(aCamposBrw,aColunas[nX])
		Next nX
	EndIf
	
Return aCamposBrw

/*/{Protheus.doc} TMSF3Struc
//Estrutura da consulta padrao 
@author ruan.salvador
@since 20/08/2018
@version 1.0
@param cAliasEsp - Alias da tabela a ser consultada - Caracteres
@param aColunas - Colunas a serem apresentadas - Array
@type static function
/*/
Static Function TMSF3Struc(cAliasEsp, aColunas, aRetorno)
	Local cAliasAux:= cAliasEsp
	Local aStructBrw := {}
	Local nX := 0
	Local nY := 1
	
	Local aSX3Prop := {}

	While &(cAliasEsp)->(columnpos(cAliasAux+"_FILIAL")) == 0
		cAliasAux:= SubStr(cAliasAux,nY)
		nY++
	EndDo
	
	Aadd(aStructBrw, {"MARK",  "C",   2, 0})
	
	If Empty(aColunas)
		For nX := 1 To &(cAliasEsp)->(FCount()) 
			If &(cAliasEsp)->(FieldName(nX)) != cAliasAux+"_FILIAL"
				aSX3Prop := TamSX3(&(cAliasEsp)->(FieldName(nX))) 
				Aadd(aStructBrw, {&(cAliasEsp)->(FieldName(nX)), aSX3Prop[3], aSX3Prop[1], aSX3Prop[2]})
			EndIF
		Next nX
	Else
		For nX := 1 To Len(aColunas)
			aSX3Prop := TamSX3(aColunas[nX]) 
			Aadd(aStructBrw, {aColunas[nX], aSX3Prop[3], aSX3Prop[1], aSX3Prop[2]})
		Next nX
		
		For nX := 1 To Len(aRetorno)
			If aScan(aColunas,aRetorno[nX]) == 0
				aSX3Prop := TamSX3(aRetorno[nX]) 
				Aadd(aStructBrw, {aRetorno[nX], aSX3Prop[3], aSX3Prop[1], aSX3Prop[2]})
			EndIf
		Next nX
	EndIf
	
Return aStructBrw

/*/{Protheus.doc} TMSF3Acols
//Colunas da consulta padrao 
@author ruan.salvador
@since 20/08/2018
@version 1.0
@param cAliasEsp - Alias da tabela a ser consultada - Caracteres
@param aCamposBrw - Array de campos criado na funcao TMSF3Camp - Array
@type static function
/*/
Static Function TMSF3Acols(cAliasEsp, aCamposBrw)
	Local aColsBrw := {}
	Local nX := 0
	
	Local oBrwCol := Nil
	
	Local aSX3Prop := {}
	
	For nX := 1 To Len(aCamposBrw)
		aSX3Prop := TamSX3(aCamposBrw[nX]) 
		oBrwCol := FWBrwColumn():New()
		oBrwCol:SetType(aSX3Prop[3]) //tipo
		oBrwCol:SetData(&("{|| "+aCamposBrw[nX]+" }")) 
		oBrwCol:SetTitle(GetSx3Cache(aCamposBrw[nX],'X3_TITULO')) //Titulo
		oBrwCol:SetSize(aSX3Prop[1]) //Tamanho 
		oBrwCol:SetDecimal(0)  //Decimal
		oBrwCol:SetPicture(x3Picture(aCamposBrw[nX])) //Picture
		oBrwCol:SetReadVar(aCamposBrw[nX])
		AAdd(aColsBrw, oBrwCol)
	Next nX
	
Return aColsBrw

/*/{Protheus.doc} TMSF3SM0
//Cria a estrutura da tela caso F3 desejado seja Filiais 
@author ruan.salvador
@since 20/08/2018
@version 1.0
@return aSM0 - Array contendo estrutura, colunas e campos da SM0
@type static function
/*/
Static Function TMSF3SM0()
	Local aSM0 := {}
	Local oBrwCol := {Nil,Nil,Nil}

	Aadd(aSM0,{"M0_FILIAL", "M0_DESC", "M0_CNPJ"})
	
	Aadd(aSM0,{{"MARK",      "C",   2, 0},;
             {"M0_FILIAL", "C",  TAMSX3("A1_FILIAL")[1], 0},;  
             {"M0_DESC",   "C",  50, 0},;
	          {"M0_CNPJ",   "C",  18, 0}})
	
	oBrwCol[1] := FWBrwColumn():New()
	oBrwCol[1]:SetType('C')
	oBrwCol[1]:SetData(&("{|| M0_FILIAL }"))
	oBrwCol[1]:SetTitle(STR0019) //Codigo
	oBrwCol[1]:SetSize(TAMSX3("A1_FILIAL")[1])
	oBrwCol[1]:SetDecimal(0)
	oBrwCol[1]:SetPicture("")
	oBrwCol[1]:SetReadVar("M0_FILIAL")
	
	oBrwCol[2] := FWBrwColumn():New()
	oBrwCol[2]:SetType('C')
	oBrwCol[2]:SetData(&("{|| M0_DESC }"))
	oBrwCol[2]:SetTitle(STR0020)
	oBrwCol[2]:SetSize(50)
	oBrwCol[2]:SetDecimal(0)
	oBrwCol[2]:SetPicture("")
	oBrwCol[2]:SetReadVar("M0_DESC")
	
	oBrwCol[3] := FWBrwColumn():New()
	oBrwCol[3]:SetType('N')
	oBrwCol[3]:SetData(&("{|| M0_CNPJ }"))
	oBrwCol[3]:SetTitle(STR0021)
	oBrwCol[3]:SetSize(18)
	oBrwCol[3]:SetDecimal(0)
	oBrwCol[3]:SetPicture("")
	oBrwCol[3]:SetReadVar("M0_CNPJ")
	
	AAdd(aSM0, {oBrwCol})
	
Return aSM0

/*/{Protheus.doc} TMSF3Ini
//Inicializa a marca dos registros 
@author ruan.salvador
@since 20/08/2018
@version 1.0
@type function
/*/
Static Function TMSF3Ini(aRetorno, aMVPar)
	Local aDadosMv := {}
	
	DbSelectArea(cTempF3)
	(cTempF3)->(dbGoTop())	
	If AllTrim(&(aMVPar[1])) == STR0022 //Todos
		While (cTempF3)->(!(EoF()))
			If Empty((cTempF3)->MARK)
				oMarkBrw:MarkRec()
			EndIf
			(cTempF3)->(DbSkip())
		EndDo
		lMarlAll := .F.
	Else 
		aDadosMv := Separa(AllTrim(&(aMVPar[1])), ';', .F.)
		While (cTempF3)->(!(EoF()))
			If aScan(aDadosMv,AllTrim((cTempF3)->&(aRetorno[1]))) > 0  
				oMarkBrw:MarkRec()
			EndIf
			(cTempF3)->(DbSkip())
		EndDo	
	Endif
	(cTempF3)->(dbGoTop())
Return Nil

/*/{Protheus.doc} TMSF3Qry
@author ruan.salvador
@since 20/08/2018
@version 1.0
@type function
/*/
Static Function TMSF3Qry(cTempTab, cAliasEsp, aColunas, aRetorno, cFiltF3, lDelReg)
	Local cAliasAux:= cAliasEsp
	Local cQuery := ''
	
	Local nX := 0
	Local nY := 1
	
	While &(cAliasEsp)->(columnpos(cAliasAux+"_FILIAL")) == 0
		cAliasAux:= SubStr(cAliasAux,nY)
		nY++
	EndDo
	
	cQuery:= " SELECT "
	If Len(aColunas) >= 1
		For nX := 1 To Len(aColunas)
			If nX == 1
				cQuery+= aColunas[nX]
			Else
				cQuery+= ", " + 	aColunas[nX]
			EndIf
		Next nX
	Else
		For nX := 1 To &(cAliasEsp)->(FCount()) 
			If &(cAliasEsp)->(FieldName(nX)) != cAliasAux+"_FILIAL"
				If nX == 1
					cQuery+= &(cAliasEsp)->(FieldName(nX))
				Else
					cQuery+= ", " + 	&(cAliasEsp)->(FieldName(nX))
				EndIf	
			EndIf			
		Next nX
	EndIf
	For nX := 1 To Len(aRetorno)
		If aScan(aColunas,aRetorno[nX]) == 0
			cQuery+= ", " + 	aRetorno[nX]
		EndIf
	Next nX
	cQuery+= " FROM " +RetSqlName(cAliasEsp)+ " " + cAliasEsp +  " "
	cQuery+= " WHERE "+cAliasEsp+"."+cAliasAux+"_FILIAL = '" + xFilial(cAliasEsp) + "'"
	If !lDelReg
		cQuery+= " AND "+cAliasEsp+".D_E_L_E_T_ = '' "
	EndIf
	If !Empty(cFiltF3)
		cQuery+= cFiltF3
	EndIf
		
	cQuery := ChangeQuery( cQuery )	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTempTab, .F., .T. )
	
Return cTempTab

/*/{Protheus.doc} TMSF3Mark
//Marca/Desmarca todos os registros 
@author ruan.salvador
@since 20/08/2018
@version 1.0
@type function
/*/
Function TMSF3Mark()
	DbSelectArea(cTempF3)
	(cTempF3)->(dbGoTop())

	If lMarlAll
		While (cTempF3)->(!(EoF()))
			If Empty((cTempF3)->MARK)
				oMarkBrw:MarkRec()
			EndIf
			lMarlAll := .F.
			(cTempF3)->(DbSkip())
		EndDo
	Else 
		While (cTempF3)->(!(EoF()))
			RecLock((cTempF3), .F.)
				(cTempF3)->MARK := " "
			MsUnlock(cTempF3)

			lMarlAll := .T.
			(cTempF3)->(DbSkip())
		EndDo
	Endif

	(cTempF3)->(dbGoTop())
Return Nil

/*/{Protheus.doc} TMSF3Ret
//Monta o retorno
@author ruan.salvador
@since 20/08/2018
@version 1.0
@param cTempF3 - Tabela temporaria
@param aRetorno - Array de campos a serem retornados
@type static function
/*/
Static Function TMSF3Ret(cTempF3, aRetorno, aMVPar)
	Local aTMSF3Esp := {}
	
	Local lTodos := .T.
	Local lRet := .T.
	
	Local nX := 0
	    
	DbSelectArea(cTempF3)
	
	For nX := 1 To Len(aRetorno)
		(cTempF3)->(dbGoTop())
		aadd(aTMSF3Esp, '')
		While (cTempF3)->(!(EoF()))
			If !Empty((cTempF3)->MARK)
				If Empty(aTMSF3Esp[nX])
					aTMSF3Esp[nX] := AllTrim((cTempF3)->&(aRetorno[nX]))
				Else
					aTMSF3Esp[nX] += ';' + AllTrim((cTempF3)->&(aRetorno[nX]))
				EndIf
			Else
				lTodos := .F.
			EndIf
			
			If Len(aTMSF3Esp[nX]) > 99 .And. !lTodos
				Help( ,, STR0005,, STR0023, 1, 0 ) //Os registros selecionados ultrapassam o limite de caracteres (99). Utilizar a opção marcar todos.
				lRet := .F.
				Exit
			EndIf
			(cTempF3)->(DbSkip())
		EndDo
	Next nX
	
	If lRet 
		For nX := 1 To Len(aMVPar)
			If nX == 1
				If lTodos
					cRetF3Esp := STR0022 //Todos
				Else
					cRetF3Esp := aTMSF3Esp[nX]
				EndIf
			ElseIf nX > 1
				If lTodos
					&(aMVPar[nX]) := STR0022 //Todos
				Else
					&(aMVPar[nX]) := aTMSF3Esp[nX]
				EndIf
			EndIf
		Next nX
	EndIf
	
Return lRet