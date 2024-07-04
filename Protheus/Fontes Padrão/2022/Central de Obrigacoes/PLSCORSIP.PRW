#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#Define TOTVS "TOTVS"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSCORSIP

Fonte criado para efetuar as correcoes de algumas criticas do SIP

@param	cTipo	1-Despesa S/ Internacao; 2-Ajusta Grp. e Reg.

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSCORSIP(cTipo,lAuto)
	Local cAliasCon	:= GetNextAlias()
	Local cAliasTmp	:= GetNextAlias()
	Local cConsulta	:= ""
	Local cMnuDef	:= "PLSCORSIP"
	Local aRetFun	:= {.F.,"Nehum registro criticado encontrado para ser corrigido.",""}//.T.-Ok / .F.-Erro;Msg;Valor de Retorno
	Private oMark	:= Nil
	Private cGrpInt	:= ""
	Private cRegInt	:= ""
	Default cTipo	:= "1"
	Default lAuto   :=.f.

	IIF(!lAuto,MsgRun("Definindo consulta de registros",TOTVS,{ || aRetFun := RetornaConsulta(cTipo) }),aRetFun := RetornaConsulta(cTipo))

	If aRetFun[1]
		IIF(!lAuto,MsgRun("Consultando registros criticados",TOTVS,{ || aRetFun := ExecutaConsulta(aRetFun[3],cAliasCon) }),aRetFun := ExecutaConsulta(aRetFun[3],cAliasCon))
	EndIf

	If aRetFun[1]
		IIF(!lAuto,MsgRun("Definindo campos do arquivo",TOTVS,{ || aRetFun := RetornaCampos(cTipo) }),aRetFun := RetornaCampos(cTipo))
	EndIf

	If aRetFun[1]
		aCampos := aRetFun[3]
		IIF(!lAuto,MsgRun("Criando arquivo de trabalho",TOTVS,{ || aRetFun := CriaTabTemp(cTipo,cAliasTmp,aCampos) }),aRetFun := CriaTabTemp(cTipo,cAliasTmp,aCampos))
	EndIf

	If aRetFun[1]
		oTmpTab := aRetFun[3]
		IIF(!lAuto,MsgRun("Carregando arquivo",TOTVS,{ || aRetFun := CarregaArqTmp(oTmpTab,cAliasCon,cAliasTmp) }),aRetFun := CarregaArqTmp(oTmpTab,cAliasCon,cAliasTmp))
	EndIf

	If aRetFun[1]
		IIF(!lAuto,MsgRun("Montando visualização dos registros",TOTVS,{ || aRetFun := CriaMarkBrowse(oMark,cAliasTmp,oTmpTab,aCampos,cTipo) }),aRetFun := CriaMarkBrowse(oMark,cAliasTmp,oTmpTab,aCampos,cTipo,lAuto))
	EndIf

	If !aRetFun[1]
		IIF(!lAuto,Help(,,'Aviso',,aRetFun[2],1,0),"")
	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaMarkBrowse

Função cria a MarkBrowse

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function CriaMarkBrowse(oMark,cAliasTmp,oTmpTab,aCampos,cTipo,lAuto)
	Local aRetFun			:= {.T.,"Não foi possível criar o browse para marcar os registros",""}
	Default cAliasTmp	:= ""
	Default oMark		:= Nil
	Default cAliasTmp	:= ""
	Default oTmpTab		:= Nil
	Default aCampos		:= {}
	Default cTipo		:= "1"
	Default lAuto       :=.F.

	If cAliasTmp <> "" .And. oTmpTab <> Nil .And. Len(aCampos) > 0

		oMark	:= FWMarkBrowse():New()
		oMark:SetDescription('Correçao de Críticas do SIP')
		oMark:SetAlias(cAliasTmp)
		oMark:SetFieldMark("B3L_OK")
		oMark:oBrowse:SetDBFFilter(.T.)
		oMark:oBrowse:SetUseFilter(.T.) //Habilita a utilização do filtro no Browse
		oMark:oBrowse:SetFixedBrowse(.T.)
		oMark:SetWalkThru(.F.)
		oMark:SetAmbiente(.T.)
		oMark:SetTemporary()
		oMark:oBrowse:SetFilterDefault("")
		IIF(!lAuto,oMark:SetAllMark({ || MarcaBrw(oMark,cAliasTmp) }),MarcaBrw(oMark,cAliasTmp,lAuto))
		/*oMark:SetMenuDef(cMnuDef)
		oMark:oBrowse:SetSeek(.T.,aSeek)
		oMark:DisableDetails()*/
		oMark:ForceQuitButton()
		oMark:SetProfileID('0')
		If cTipo == "1"
			IIF(!lAuto,oMark:AddButton("Ajustar Despesas"	, { || AjustaCritica(oMark,cAliasTmp,cTipo)},,,, .F., 2 ),AjustaCritica(oMark,cAliasTmp,cTipo,,,lAuto))
		EndIf
		If cTipo == "2"//Informar grupo e regime de internacao
			oMark:AddButton("Informar Grupo / Regime"	, { || InformaGrpReg(oMark,cAliasTmp,cTipo)},,,, .F., 2 )
		EndIf

		CarregaCampos(oMark,aCampos)

		IIF(!lAUto,oMark:Activate(),"")

	Else
		aRetFun[1] := .F.
	EndIf

Return aRetFun

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaArqTmp

Preenche o arquivo temporario com os registros criticados

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaArqTmp(oTmpTab,cAliasCon,cAliasTmp)
	Local aRetFun		:= {.F.,"Não foi possível carregar o arquivo de trabalho",""}

	While !(cAliasCon)->(Eof())

		(cAliasTmp)->(RecLock(cAliasTmp,.T.))
		(cAliasTmp)->B3L_OK := ""
		(cAliasTmp)->B3L_EVEDES := (cAliasCon)->B3L_EVEDES
		(cAliasTmp)->B3L_EVDEIN := (cAliasCon)->B3L_EVDEIN
		(cAliasTmp)->B3L_MATRIC := (cAliasCon)->B3L_MATRIC
		(cAliasTmp)->B3L_QTDEVE := (cAliasCon)->B3L_QTDEVE
		(cAliasTmp)->B3L_VLREVE := (cAliasCon)->B3L_VLREVE
		(cAliasTmp)->B3L_UF 		:= (cAliasCon)->B3L_UF
		(cAliasTmp)->B3L_CLAAMB := (cAliasCon)->B3L_CLAAMB
		(cAliasTmp)->B3L_CLAINT := (cAliasCon)->B3L_CLAINT
		(cAliasTmp)->B3L_REGINT := (cAliasCon)->B3L_REGINT
		(cAliasTmp)->B3L_GRPINT := (cAliasCon)->B3L_GRPINT
		(cAliasTmp)->B3F_CODCRI := (cAliasCon)->B3F_CODCRI
		(cAliasTmp)->B3F_DESCRI := (cAliasCon)->B3F_DESCRI
		(cAliasTmp)->B3F_SOLUCA := (cAliasCon)->B3F_SOLUCA
		(cAliasTmp)->B3LREC		:= AllTrim(Str((cAliasCon)->B3LREC))
		(cAliasTmp)->(msUnLock())
		(cAliasCon)->(dbSkip())

		If !aRetFun[1]
			aRetFun[1] := .T.
		EndIf

	EndDo

	(cAliasCon)->(dbCloseArea())

Return aRetFun

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTabTemp

Cria o arquivo temporario

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function CriaTabTemp(cTipo,cAliasTmp,aCampos)
	Local aRetFun		:= {.F.,"Não foi possível definir um arquivo de trabalho",""}
	Local oTmpTab		:= Nil
	Default aCampos		:= {}

	oTmpTab := FWTemporaryTable():New( cAliasTmp )
	oTmpTab:SetFields( aCampos )
	oTmpTab:AddIndex("01",{"B3L_EVEDES"})
	oTmpTab:AddIndex("02",{"B3L_MATRIC"})
	oTmpTab:Create()

	aRetFun[1] := .T.
	aRetFun[3] := oTmpTab

Return aRetFun

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaCampos

Retorna os campos para criar o arquivo temporario

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaCampos(cTipo)
	Local aCampos		:= {}
	Local aRetFun		:= {.F.,"Não foi possível definir os campos dos arquivo",""}
	Default cTipo		:= "1"

	aAdd(aCampos,{"B3L_EVEDES"	,"C",030,0})
	aAdd(aCampos,{"B3L_MATRIC"	,"C",018,0})
	aAdd(aCampos,{"B3L_QTDEVE"	,"N",016,2})
	aAdd(aCampos,{"B3L_VLREVE"	,"N",016,2})
	aAdd(aCampos,{"B3F_CODCRI"	,"C",004,0})
	aAdd(aCampos,{"B3F_DESCRI"	,"C",100,0})
	aAdd(aCampos,{"B3F_SOLUCA"	,"C",200,0})
	aAdd(aCampos,{"B3L_EVDEIN"	,"C",046,0})
	aAdd(aCampos,{"B3L_UF"		,"C",002,0})
	aAdd(aCampos,{"B3L_CLAAMB"	,"C",007,0})
	aAdd(aCampos,{"B3L_CLAINT"	,"C",007,0})
	aAdd(aCampos,{"B3L_REGINT"	,"C",001,0})
	aAdd(aCampos,{"B3L_GRPINT"	,"C",001,0})
	aAdd(aCampos,{"B3LREC"		,"C",016,0})
	aAdd(aCampos,{"B3L_OK"		,"C",002,0})

	If Len(aCampos) > 0
		aRetFun[1] := .T.
		aRetFun[3] := aCampos
	EndIf

Return aRetFun

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaMarkCor

Cria a markbrose de correcao das criticas

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function CriaMarkCor(cAliCor,cMnuDef)
	Private oMark		:= Nil
	Default	cAliCor	:= ""

	oMark	:= FWMarkBrowse():New()
	oMark:SetAlias(cAliCor)
	oMark:SetMenuDef(cMnuDef)
	oMark:DisableDetails()
	oMark:ForceQuitButton()
	oMark:SetProfileID('0')
	oMark:SetWalkthru( .F. )
	oMark:SetAmbiente( .F. )
	oBrowse:SetTemporary()
	oMark:SetDescription('Correçao de Críticas do SIP')
	oMark:SetFieldMark( 'B3F_OK' )
	oMark:Activate()

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaConsulta

Retorn a consulta dos registros criticados

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaConsulta(cTipo)
	Local cConsulta	:= ""
	Local aRetFun		:= {.F.,"Não foi possível definir a consulta",""}
	Default	cTipo		:= "1"

	cConsulta := "SELECT B3L_EVEDES, B3L_EVDEIN, B3L_MATRIC, B3L_QTDEVE, B3L_VLREVE, B3L_UF, B3L_CLAAMB, B3L_CLAINT, B3L_REGINT, B3L_GRPINT, B3F_CODCRI, B3F_DESCRI, B3F_SOLUCA, B3L.R_E_C_N_O_ B3LREC "
	cConsulta += "FROM " + RetSqlName("B3L") + " B3L INNER JOIN " + RetSqlName("B3F") + " B3F ON B3L_FILIAL = B3F_FILIAL AND B3L_CODOPE = B3F_CODOPE AND B3L_CODOBR = B3F_CDOBRI AND B3L_ANOCMP = B3F_ANO AND B3L_CDCOMP = B3F_CDCOMP "
	cConsulta += "AND B3F_ORICRI = 'B3L' AND B3L_CLAAMB <> 'H' "

	If cTipo == "2"
		cConsulta += "AND B3F_CODCRI = 'E037' "//Evento x Despesa classificado como internação mas não possui interanção/grupo/regime
	Else
		cConsulta += "AND B3F_CODCRI <> 'E037' "//Todas as criticas diferente de E037
	EndIf

	cConsulta += "AND B3F_CHVORI = B3L.R_E_C_N_O_ AND B3L.D_E_L_E_T_ = '' AND B3F.D_E_L_E_T_ = ''"

	If !Empty(cConsulta)
		aRetFun[1] := .T.
		aRetFun[3] := cConsulta
	EndIf

Return aRetFun

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExecutaConsulta

Executa a consulta e cria a area de trabalho

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExecutaConsulta(cConsulta,cAliasTmp)
	Local aRetFun			:= {.F.,"Nenhum registro encontrado para ser apresentado",""}
	Default cConsulta	:= ""
	Default cAliasTmp	:= ""

	If !Empty(cConsulta) .And. !Empty(cAliasTmp)

		If (Select(cAliasTmp) <> 0)
			dbSelectArea(cAliasTmp)
			(cAliasTmp)->(dbCloseArea())
		EndIf

		cConsulta := ChangeQuery(cConsulta)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cConsulta),cAliasTmp,.F.,.T.)

		If !(cAliasTmp)->(Eof())
			aRetFun[1] := .T.
		Else
			(cAliasTmp)->(dbCloseArea())
		EndIf

	EndIf

Return aRetFun

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaCampos

Carrega os campos na markbrowse

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaCampos(oMark,aCampos)
	Local nCampos		:= 0
	Local cCampo		:= ""
	Local cTitulo		:= ""
	Local nArrData		:= 0
	Local cPicture		:= ""
	Local nAlign		:= 0
	Local nSize			:= 0
	Local nDecimal		:= 0

	For nCampos := 1 TO Len(aCampos)

		cCampo	:= aCampos[nCampos,1]
		cTitulo	:= aCampos[nCampos,1]//TODO
		nArrData	:=	nCampos+1
		cPicture	:= "@!"
		nAlign	:= 1
		nSize		:= aCampos[nCampos,3]
		nDecimal	:= aCampos[nCampos,4]

		aColuna := GetColuna(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
		oMark:SetColumns(aColuna)

	Next nCampos

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetColuna

Retorna uma coluna para o markbrowse

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function GetColuna(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	Local aColuna		:= {}
	Local bData			:= {||}
	Default nAlign	:= 1
	Default nSize		:= 20
	Default nDecimal	:= 0
	Default nArrData	:= 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}")
	EndIf

	aColuna := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return {aColuna}

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MarcaBrw

Chama a funcao para marcar/desmarcar todos os registros da markbrowse

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function MarcaBrw(oMark,cAliasTmp,lAuto)
	Default oMark		:= Nil
	Default cAliasTmp	:= ""
	Default lAuto       := .F.

	IIF(!lAuto,MsgRun("Marcando / Desmarcando registros do browse",TOTVS,{ || PrcMarcaBrw(oMark,cAliasTmp) }),PrcMarcaBrw(oMark,cAliasTmp))

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PrcMarcaBrw

Marcar/desmarcar todos os registros da markbrowse

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function PrcMarcaBrw(oMark,cAliasTmp)
	Default oMark			:= Nil
	Default cAliasTmp	:= ""

	If !Empty(cAliasTmp) .And. oMark <> Nil

		(cAliasTmp)->(dbGoTop())

		While !(cAliasTmp)->(Eof())

			oMark:MarkRec()
			(cAliasTmp)->(dbSkip())

		EndDo

		oMark:oBrowse:Refresh(.T.)

	EndIf

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaCritica

Chama o processamento de corrigir as criticas do registros selecionados

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function AjustaCritica(oMark,cAliasTmp,cTipo,cGrpInt,cRegInt,lAuto)
	Default lAuto :=.f.

	If lAuto .Or. MsgYesNo("Esta ação irá transferir as despesas criticadas selecionadas para o item H-Demais Despesas Hospitalares. Confirma a execução desta ação ?")
		IIF(!lAuto,MsgRun("Ajustando registros criticados",TOTVS,{ || ProcAjusCritica(oMark,cAliasTmp,cTipo,cGrpInt,cRegInt,lAuto) } ),ProcAjusCritica(oMark,cAliasTmp,cTipo,cGrpInt,cRegInt,lAuto))
	Else
		MsgInfo("Ação cancelada pelo usuário.")
	EndIf

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcAjusCritica

Processa todos os registros selecionados

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ProcAjusCritica(oMark,cAliasTmp,cTipo,cGrpInt,cRegInt,lAuto)
	Local cMarca		:= ""
	Default oMark		:= Nil
	Default	cTipo		:= "1"
	Default cGrpInt		:= ""
	Default cRegInt		:= ""
	Default lAuto       := .f.

	If !Empty(cAliasTmp) .And. oMark <> Nil

		(cAliasTmp)->(dbGoTop())
		cMarca := IIF(!lAuto,oMark:Mark(),"  ")

		While !(cAliasTmp)->(Eof())

			If (cAliasTmp)->B3L_OK == cMarca
				TrataCritica((cAliasTmp)->B3LREC,cTipo,cGrpInt,cRegInt)
			EndIf

			(cAliasTmp)->(dbSkip())

		EndDo

		oMark:oBrowse:Refresh(.T.)

	EndIf

	IIF(!lAuto, MsgInfo("Término da atualização dos registros"),"")

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TrataCritica

Marca o registro para validação, data, hora e login do usuário

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function TrataCritica(cB3LRec,cTipo,cGrpInt,cRegInt)
	Default cB3LRec	:= ""
	Default cTipo		:= "1"
	Default cGrpInt		:= ""
	Default cRegInt		:= ""

	Conout("TrataCritica: " + cB3LRec)
	B3L->(dbGoTo(Val(cB3LRec)))
	RecLock("B3L",.F.)

	If cTipo == "1"

		B3L->B3L_CLAAMB := "H"
		B3L->B3L_CLAINT := "H"
		B3L->B3L_STATUS := "1"
		if B3L->(fieldpos("B3L_CLASSH")) > 0 //Verifica se existe o campo B3L_CLASSH
			B3L->B3L_CLASSH := "Classificação H forçada pelo usuário [" + rtrim(usrfullname(retcodusr())) + "] em [" + dtoc(ddatabase) + "]. (Caminho: 'Painel de Obrigaçoes/Obrigações/SIP/Eventos x Despesas/Outras Ações/Ajustes/Criticado p/ Demais Despesas')"
		endif

	ElseIf cTipo == "2"

		B3L->B3L_GRPINT := cGrpInt
		B3L->B3L_REGINT := cRegInt
		B3L->B3L_STATUS := "1"

	EndIf

	B3L->B3L_DTINSI := dDataBase
	B3L->B3L_HRINSI := Time()
	B3L->B3L_LOGIN := cUserName

	msUnLock()

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InformaGrpReg

Parambox para o usuario informar grupo e regime de internacao

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function InformaGrpReg(oMark,cAliasTmp,cTipo)
	Local cGrpInt := ""
	Local cRegInt := ""
	Local aPergs := {}
	Local aRet := {}
	Local lRet := .F.

	aAdd(/*01*/aPergs,{ 2,"Grupo de Internação"		,cGrpInt	,{ "1=Clinica","2=Cirurgica","3=Obstétrica","4=Pediatrica","5=Psiquiatrica" },50,/*'.T.'*/,.T. } )
	aAdd(/*02*/aPergs,{ 2,"Regime de Internação"	,cRegInt	,{ "1=Hospitalar","2=Hospital-Dia","4=Hosp. Dia p/ S. Mental","3=Domiciliar" },60,/*'.T.'*/,.T. } )

	If ParamBox( aPergs,"SIP - Grupo e Regime de Internacao",aRet,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSCORSIP',/*lCanSave*/.T.,/*lUserSave*/.T. )

		cGrpInt := aRet[1]
		cRegInt := aRet[2]
		AjustaCritica(oMark,cAliasTmp,cTipo,cGrpInt,cRegInt)

	EndIf

Return lRet