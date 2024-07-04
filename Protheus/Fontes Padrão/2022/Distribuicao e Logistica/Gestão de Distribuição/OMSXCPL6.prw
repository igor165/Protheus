#include "PROTHEUS.CH"
#include "FWMVCDEF.CH"
#include "OMSXCPL6.CH"

Static lMarkAll  := .F. // Indicador de marca/desmarca todos...
Static oBrowse   := Nil
Static oTempTab  := Nil
Static oTempAux  := Nil
Static cAliasTMP := Nil
Static cAliasAUX := Nil
Static cOmsCplRel := "VIAGEM_OMSXCPL"

/*/{Protheus.doc} OMSXCPL6 
	Programa responsável por enviar os pedidos de venda como demanda de otimização para o Cockpit Logístico
	A execução é aceita com tela e execução agendada
@author rafael.kleestadt
@since 21/10/2016
@version 1.0
@example
OMSXCPL6()
@see Integração OMS x Neolog
/*/
Function OMSXCPL6(nOpcAuto)
Local aAreaAnt := GetArea()
Local bKeyF2   := SetKey(VK_F2)
Local bKeyF3   := SetKey(VK_F3)
Local bKeyF4   := SetKey(VK_F4)
Local bKeyF5   := SetKey(VK_F5)
Local bKeyF7   := SetKey(VK_F7)
Local bKeyF8   := SetKey(VK_F8)
Local bKeyF9   := SetKey(VK_F9)
Local bKeyF10  := SetKey(VK_F10)
Local aColsSX3 := {}
Local aBrwCols := {}
Local aFields  := {}
Local aIndex   := {}
Local aSeek    := {}
Local aArqTab  := {}
Local aTamDK3  := {}
Local aTamSC6  := {}
Local lIsBlind := IsBlind()
Local lRet     := .T.
Default nOpcAuto := 3

	//Validação para gravação da Data do fonte no LOGOMSCPL
	OsLogCpl("-----------------------------------------------------------------------------------------","DATA")
	OsLogCPL("Inspetor de Objetos CPL","DATA")
	OsLogCpl("-----------------------------------------------------------------------------------------","DATA")
	OmCPLIns()
	OsLogCpl("-----------------------------------------------------------------------------------------","DATA")

	dbSelectArea('DK0')
	dbSelectArea('DK1')
	dbSelectArea('DK3')

	PutGlbValue( "GLB_OMSLOG",GetSrvProfString("LOGCPLOMS", ".F.") )
	PutGlbValue( "GLB_OMSTIP",GetSrvProfString("LOGTIPOMS", "CONSOLE") )

	If !lIsBlind .And. !Pergunte("OMSXCPL6",.T.)
		Return
	EndIf

	//Realiza validações de integridade do dicionário antes de abrir a rotina
	If !TableInDic('DK3')
		If !lIsBlind
			MsgAlert(STR0039) //Para utilização dessa rotina é necessária a existência da tabela de sequência de integração (DK3). Para mais detalhes, consulte o documento de integração.
		EndIf
		Return .F.
	EndIf

	If !(ValType(MV_PAR22) == "N")
		If !lIsBlind
			MsgAlert(STR0040) //Para utilização dessa rotina é necessário atualizar o pergunte (SX1) do grupo OMSXCPL6. Para mais detalhes, consulte o documento de integração.
		EndIf
		Return .F.
	EndIf

	If !(xFilial("SC6") == xFilial("DK3"))
		If !lIsBlind
			MsgAlert(STR0041) //A tabela de sequência de integração (DK3) não encontra-se compartilhada com a mesma configuração da tabela de itens do pedido (SC6). Realize esse ajuste para utilizar a rotina.
		EndIf
		Return .F.
	EndIf

	//Alerta usuário para ajustar o dicionário
	aTamDK3 := TamSx3("DK3_QTDINT")
	aTamSC6 := TamSx3("C6_QTDVEN")
	If !(aTamDK3[1] == aTamSC6[1])
		If !lIsBlind
			MsgAlert(STR0062) //O campo da quantidade integrada (DK3_QTDINT) possuí tamanho diferente do campo de quantidade do pedido (C6_QTDVEN) ajuste para evitar a integração de quantidades inconsistentes.
		EndIf
	ElseIf !(aTamDK3[2] == aTamSC6[2])
		If !lIsBlind
			MsgAlert(STR0063) //O campo da quantidade integrada (DK3_QTDINT) possuí o tamanho do decimal diferente do campo de quantidade do pedido (C6_QTDVEN) ajuste o dicionário para evitar a integração de quantidades inconsistentes.
		EndIf
	EndIf

	// Validação de existência da tabela VIAGEM_OMSxCPL. Caso não exista, sua criação será efetuada.
	OsLogCPL("OMSXCPL6 -> Verifica a chamada da função OmsTabRelCria","INFO")
	If Select( cOmsCplRel ) <= 0
		If !OmsTabRelCria()
			Return .F.
		EndIf
	EndIf	

	/*
	Array contendo o objeto FWBrwColumn ou um array com a seguinte estrutura:
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Parâmetro reservado
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Parâmetro reservado
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
	//+--------------------------------------------------------------+
	//| IMPORTANTE - Não trocar a ordem dos campos no Array aArqTab, |
	//|              pois eles são na mesma ordem da query           |
	//+--------------------------------------------------------------+
	AAdd(aArqTab ,{"TMP_MARK","C",2,0})
	AAdd(aArqTab ,{"TMP_INTROT","C",1,0})
	AAdd(aArqTab ,{"TMP_SITPED","C",1,0})

	BuscarSX3("C5_FILIAL",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_FILIAL }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_FILIAL",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_FILIAL","C",aColsSX3[3],aColsSX3[4]})

	BuscarSX3("C9_PEDIDO",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_PEDIDO }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_PEDIDO",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_PEDIDO","C",aColsSX3[3],aColsSX3[4]})

	AAdd(aFields ,{"TMP_INTROT",STR0013,"C",1,0,"@!",MontOpcoes({STR0038,STR0036,STR0042,STR0037})}) // Situação CPL
	AAdd(aFields ,{"TMP_SITPED",STR0012,"C",1,0,"9",MontOpcoes({STR0031,STR0032,STR0033,STR0034,STR0035})}) // Situação Pedido

	BuscarSX3("C5_TIPO",,aColsSX3)
	AAdd(aArqTab ,{"TMP_TIPPED","C",aColsSX3[3],aColsSX3[4]})

	BuscarSX3("C5_CLIENTE",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_CLIENT }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_CLIENT",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_CLIENT","C",aColsSX3[3],aColsSX3[4]})

	BuscarSX3("C5_LOJACLI",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_LOJCLI }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_LOJCLI",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_LOJCLI","C",aColsSX3[3],aColsSX3[4]})

	BuscarSX3("A1_NOME",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_NOMCLI }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_NOMCLI",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_NOMCLI","C",aColsSX3[3],aColsSX3[4]})

	BuscarSX3("C9_DATALIB",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_DATLIB }, "D", aColsSX3[2], 0, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_DATLIB",aColsSX3[1],"D",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_DATLIB","D",aColsSX3[3],aColsSX3[4]})

	BuscarSX3("C9_DATENT",,aColsSX3)
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_DATENT }, "D", aColsSX3[2], 0, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_DATENT",aColsSX3[1],"D",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_DATENT","D",aColsSX3[3],aColsSX3[4]})

	AAdd(aArqTab ,{"TMP_RECSC5","N",10,0})

	BuscarSX3("C5_FECENT",,aColsSX3)
	AAdd(aArqTab ,{"TMP_FECENT","D",aColsSX3[3],aColsSX3[4]})

	//Criação de Novos Campos
	BuscarSX3("A1_NREDUZ",,aColsSX3) //Nome Fantasia
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_NOMFAN }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_NOMFAN",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_NOMFAN","C",aColsSX3[3],aColsSX3[4]})

	BuscarSX3("A1_CGC",,aColsSX3) //CNPJ/CPF
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_CGCCLI }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_CGCCLI",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_CGCCLI","C",aColsSX3[3],aColsSX3[4]})

	BuscarSX3("A1_INSCR",,aColsSX3) //IE -> Inscricao Estadual
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_IECLI }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_IECLI",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_IECLI","C",aColsSX3[3],aColsSX3[4]})

	//Criação de Campos referentes ao Redespachante
	BuscarSX3("C5_REDESP",,aColsSX3) //Código do Redespachante
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_REDESP }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_REDESP",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_REDESP","C",aColsSX3[3],aColsSX3[4]})	
	BuscarSX3("A4_NREDUZ",,aColsSX3) //Nome reduzido do Redespachante
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_REDNOM }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_REDNOM",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_REDNOM","C",aColsSX3[3],aColsSX3[4]})				

	BuscarSX3("A1_MUN",,aColsSX3) //Municipio do Cliente
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_MUNCLI }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_MUNCLI",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_MUNCLI","C",aColsSX3[3],aColsSX3[4]})

	BuscarSX3("A1_EST",,aColsSX3) //Estado do Cliente - UF
	Aadd(aBrwCols,{RTrim(aColsSX3[1]),{|| (cAliasTMP)->TMP_UFCLI }, "C", aColsSX3[2], 1, aColsSX3[3], aColsSX3[4], Nil, {||.T.}, .F., {||.T.}, Nil, {||.T.}, .F., .F., Nil })
	AAdd(aFields ,{"TMP_UFCLI",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"TMP_UFCLI","C",aColsSX3[3],aColsSX3[4]})

	//Filial + Pedido
	AAdd(aSeek ,{ RTrim(aBrwCols[1,1]) + ' + ' + RTrim(aBrwCols[2,1]), {;
		{"",aBrwCols[2,3], aBrwCols[2,6], aBrwCols[2,7], aBrwCols[2,1], aBrwCols[2,4]}};
	})

	//Filial + Cliente + Loja + Pedido
	AAdd(aSeek ,{ RTrim(aBrwCols[1,1]) + ' + ' + RTrim(aBrwCols[3,1]) + ' + ' + RTrim(aBrwCols[4,1]) + ' + ' + RTrim(aBrwCols[2,1]), {;
		{"",aBrwCols[3,3], aBrwCols[3,6], aBrwCols[3,7], aBrwCols[3,1], aBrwCols[3,4]},;
		{"",aBrwCols[4,3], aBrwCols[4,6], aBrwCols[4,7], aBrwCols[4,1], aBrwCols[4,4]},;
		{"",aBrwCols[2,3], aBrwCols[2,6], aBrwCols[2,7], aBrwCols[2,1], aBrwCols[2,4]};
	}})

	//Nome Fantasia
	AAdd(aSeek ,{ RTrim(aBrwCols[8,1]), {;
		{"",aBrwCols[8,3], aBrwCols[8,6], aBrwCols[8,7], aBrwCols[8,1], aBrwCols[8,4]}};
	})

	//CNPJ/CPF
	AAdd(aSeek ,{ RTrim(aBrwCols[9,1]), {;
		{"",aBrwCols[9,3], aBrwCols[9,6], aBrwCols[9,7], aBrwCols[9,1], aBrwCols[9,4]}};
	})

	//IE -> Inscricao Estadual
	AAdd(aSeek ,{ RTrim(aBrwCols[10,1]), {;
		{"",aBrwCols[10,3], aBrwCols[10,6], aBrwCols[10,7], aBrwCols[10,1], aBrwCols[10,4]}};
	})

	//Municipio do Cliente
	AAdd(aSeek ,{ RTrim(aBrwCols[11,1]), {;
		{"",aBrwCols[11,3], aBrwCols[11,6], aBrwCols[11,7], aBrwCols[11,1], aBrwCols[11,4]}};
	})

	//Estado do Cliente - UF
	AAdd(aSeek ,{ RTrim(aBrwCols[12,1]), {;
		{"",aBrwCols[12,3], aBrwCols[12,6], aBrwCols[12,7], aBrwCols[12,1], aBrwCols[12,4]}};
	})				

	aIndex := {"TMP_FILIAL+TMP_PEDIDO","TMP_FILIAL+TMP_CLIENT+TMP_LOJCLI+TMP_PEDIDO","TMP_NOMFAN","TMP_CGCCLI","TMP_IECLI","TMP_MUNCLI","TMP_UFCLI"}

	CriaTabTmp(aArqTab,aIndex,@cAliasTMP,@oTempTab)

	//Cria tabela temporária auxiliar para controlar as quantidades integradas dos itens do pedido (SC6)
	aArqTab := {}
	BuscarSX3("C6_FILIAL",,aColsSX3)
	AAdd(aArqTab ,{"C6_FILIAL","C",aColsSX3[3],aColsSX3[4]})
	BuscarSX3("C6_NUM",,aColsSX3)
	AAdd(aArqTab ,{"C6_NUM","C",aColsSX3[3],aColsSX3[4]})
	BuscarSX3("C6_ITEM",,aColsSX3)
	AAdd(aArqTab ,{"C6_ITEM","C",aColsSX3[3],aColsSX3[4]})
	BuscarSX3("C6_PRODUTO",,aColsSX3)
	AAdd(aArqTab ,{"C6_PRODUTO","C",aColsSX3[3],aColsSX3[4]})
	BuscarSX3("C6_CLI",,aColsSX3)
	AAdd(aArqTab ,{"C6_CLI","C",aColsSX3[3],aColsSX3[4]})
	BuscarSX3("C6_LOJA",,aColsSX3)
	AAdd(aArqTab ,{"C6_LOJA","C",aColsSX3[3],aColsSX3[4]})
	BuscarSX3("C6_QTDVEN",,aColsSX3)
	AAdd(aArqTab ,{"C6_QTDPED","N",aColsSX3[3],aColsSX3[4]})
	AAdd(aArqTab ,{"C6_QTDINT","N",aColsSX3[3],aColsSX3[4]})
	aIndex := {"C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO"}
	CriaTabTmp(aArqTab,aIndex,@cAliasAUX,@oTempAux)

	LoadData()

	If lIsBlind

		Do Case
			Case nOpcAuto = 1 
				lRet := Cpl6CanSel(.T.) //Desatualizar selecionado
			Case nOpcAuto = 2
				lRet := Cpl6CanOtm(.T.) //Desatualizar posicionado
			Case nOpcAuto = 3
				BatchProcess("OMSXCPL6",STR0001,,{ || lRet := Cpl6EnvBat() }) //"Envio de pedidos de venda"
			Case nOpcAuto = 4
				lRet := Cpl6CFalha(.T.) //Consultar registros de falha
			Case nOpcAuto = 5
				OMSObjTemp(oTempAux)
				(cAliasTMP)->(DbGoTop())
				SC5->(DbSetOrder(1))
				SC5->(DbSeek((cAliasTMP)->TMP_FILIAL+(cAliasTMP)->TMP_PEDIDO))
				oModel	:= FWLoadModel('OMSXCPL6A')
				oModel:SetOperation(3)
    			oModel:Activate()
				lRet := oModel:VldData()
				If lRet 
					oModel:CommitData()
				EndIf
			Case nOpcAuto = 6
				(cAliasTMP)->(DbGoTop())
				SC5->(DbSetOrder(1))
				SC5->(DbSeek((cAliasTMP)->TMP_FILIAL+(cAliasTMP)->TMP_PEDIDO))
				OMSCPL6BAT(oTempTab:oStruct:GetAlias(),.T.)
				oModel	:= FWLoadModel('OMSXCPL6B')
				oModel:SetOperation(4)
    			oModel:Activate()
				lRet := oModel:VldData()
				If lRet 
					oModel:CommitData()
				EndIf
			Case nOpcAuto = 7
				lRet := Cpl6CanDK3(.T.) //Desatualizar selecionado Usando Status da tabela DK3
			Case nOpcAuto = 8
				lRet := Cpl6CseDK3(.T.) //Desatualizar posicionado Usando Status da tabela DK3
		EndCase

	Else
		oBrowse := FWMarkBrowse():New()
		oBrowse:SetDescription(STR0001) // "Envio de Pedidos de Venda"
		oBrowse:SetMenuDef("OMSXCPL6")
		oBrowse:SetTemporary(.T.)
		oBrowse:SetAlias(cAliasTMP)

		oBrowse:AddStatusColumns({||StatusInt((cAliasTMP)->TMP_FILIAL,(cAliasTMP)->TMP_PEDIDO)}, {||OMS6Legend("INTROT")})
		oBrowse:AddStatusColumns({||StatusPed((cAliasTMP)->TMP_SITPED)}, {||OMS6Legend("SITPED")})

		oBrowse:SetFieldMark("TMP_MARK")
		oBrowse:SetAllMark({||AllMark()})

		oBrowse:SetColumns(aBrwCols)
		oBrowse:SetOnlyFields({})
		oBrowse:oBrowse:SetFieldFilter( aFields )
		oBrowse:oBrowse:SetUseFilter()

		oBrowse:DisableDetails()
		oBrowse:SetSeek(/*bSeek*/,aSeek)
		oBrowse:SetParam({|| UpdSelecao() })

		SetKey(VK_F2, {|| Cpl6CanSel() })
		SetKey(VK_F3, {|| Cpl6EnvOtm() })
		SetKey(VK_F4, {|| Cpl6CanOtm() })
		SetKey(VK_F5, {|| RefreshBrw(.T.) })
		SetKey(VK_F7, {|| Cpl6CFalha() })
		SetKey(VK_F8, {|| Cpl6VisPed() })
		SetKey(VK_F9, {|| Cpl6VisCli() })
		SetKey(VK_F10,{|| Cpl6AltQtd() })

		oBrowse:Activate()

		SetKey(VK_F2, bKeyF2)
		SetKey(VK_F3, bKeyF3)
		SetKey(VK_F4, bKeyF4)
		SetKey(VK_F5, bKeyF5)
		SetKey(VK_F7, bKeyF7)
		SetKey(VK_F8, bKeyF8)
		SetKey(VK_F9, bKeyF9)
		SetKey(VK_F10,bKeyF10)
		oBrowse := Nil
		RestArea(aAreaAnt)
	EndIf

	//Libera memória utilizada
	DelTabTmp(cAliasTMP,oTempTab)
	DelTabTmp(cAliasAUX,oTempAux)

Return lRet

/*/{Protheus.doc} MenuDef
	Monta o menu da rotina para ser usado no Browse
@author Jackson patrick Werka
@since 09/08/2018
@version 1.0
/*/
Static Function MenuDef()
Local lEstDk3  := SuperGetMV("MV_CPLCDK3",.F.,.F.) //Define de qual tabela será considerado o Status do registro para desatualizar pedido de venda int com TOL (.F. = C6_INTROT ou .T. = DK3_STATUS)
Private aRotina := {}

	Add OPTION aRotina TITLE STR0014 ACTION "StaticCall(OMSXCPL6,Cpl6EnvOtm)" OPERATION 4 ACCESS 0 // Enviar Pedidos (CPL) - F3
	//Verificar se será considerado o Status da Tabela SC6 ou DK3 para desatualizar os pedidos de venda integrados.
	If !lEstDk3
		Add OPTION aRotina TITLE STR0064 ACTION "StaticCall(OMSXCPL6,Cpl6CanOtm)" OPERATION 4 ACCESS 0 // Desatualizar Pedido Posicionado (CPL) - F4
		Add OPTION aRotina TITLE STR0065 ACTION "StaticCall(OMSXCPL6,Cpl6CanSel)" OPERATION 4 ACCESS 0 // Desatualizar Pedidos Selecionados (CPL) - F2
	Else	
		Add OPTION aRotina TITLE STR0064 ACTION "StaticCall(OMSXCPL6,Cpl6CanDK3)" OPERATION 4 ACCESS 0 // Desatualizar Pedido Posicionado (CPL) - F4
		Add OPTION aRotina TITLE STR0065 ACTION "StaticCall(OMSXCPL6,Cpl6CseDK3)" OPERATION 4 ACCESS 0 // Desatualizar Pedidos Selecionados (CPL) - F2
	EndIf
	Add OPTION aRotina TITLE STR0016 ACTION "StaticCall(OMSXCPL6,Cpl6VisPed)" OPERATION 4 ACCESS 0 // Consultar Pedido - F8
	Add OPTION aRotina TITLE STR0017 ACTION "StaticCall(OMSXCPL6,Cpl6VisCli)" OPERATION 4 ACCESS 0 // Consultar Cliente - F9
	Add OPTION aRotina TITLE STR0018 ACTION "StaticCall(OMSXCPL6,Cpl6CFalha)" OPERATION 4 ACCESS 0 // Consultar Registro de Falha - F7
	Add OPTION aRotina TITLE STR0043 ACTION "StaticCall(OMSXCPL6,Cpl6AltQtd)" OPERATION 4 ACCESS 0  // Alterar Quantidade da Integração - F10

Return aRotina

/*/{Protheus.doc} LoadData
	Efetua a carga dos dados na tebala temporária criada com base nos parâmetros do pergunte
@author Jackson patrick Werka
@since 09/08/2018
@version 1.0
/*/
Static Function LoadData()
Local cQuery := ""
	//Monta temporária para SC5
	cQuery := QryPedido()
	WmsQry2Tmp(cAliasTMP,oTempTab:oStruct:aFields,cQuery,oTempTab,,.T.)
	//Monta temporária para SC6
	cQuery := QryItens()
	WmsQry2Tmp(cAliasAUX,oTempAux:oStruct:aFields,cQuery,oTempAux,,.T.)
Return

/*/{Protheus.doc} OMS7Legend
	Esta função tem como objetivo, construir a legenda para os campos carga e a viagem.
@author Mohamed S B Djalo
@since 02/01/2017
/*/
Static Function OMS6Legend(cTipo)

Local oLegend  :=  FWLegend():New()

	If cTipo == "INTROT"
		oLegend:Add("","BR_AMARELO" , STR0038 ) // Não Integrado
		oLegend:Add("","BR_VERDE"   , STR0036 ) // Integrado
		oLegend:Add("","BR_AZUL"    , STR0042 ) // Integrado Parcial
		oLegend:Add("","BR_VERMELHO", STR0037 ) // Falha de Integração
	ElseIf cTipo == "SITPED"
		oLegend:Add("","BR_VERDE"   , STR0031 ) // Pedido em Aberto
		oLegend:Add("","BR_VERMELHO", STR0032 ) // Pedido Encerrado
		oLegend:Add("","BR_AMARELO" , STR0033 ) // Pedido Liberado
		oLegend:Add("","BR_AZUL"    , STR0034 ) // Pedido Bloqueado por Regra
		oLegend:Add("","BR_LARANJA" , STR0035 ) // Pedido Bloqueado por Verba
	EndIf

	oLegend:Activate()
	oLegend:View()
	oLegend:DeActivate()

Return

/*/{Protheus.doc} StatusPed
Retorna status do pedido
@author Mohamed S B Djalo
@since 02/01/2017
/*/
Static Function StatusPed(cStatus)
Local cRetorno := ""
	If cStatus == '1' //Pedido em Aberto
		cRetorno := "BR_VERDE"
	ElseIf cStatus == '2' //Pedido Encerrado
		cRetorno := "BR_VERMELHO"
	ElseIf cStatus == '3' //Pedido Liberado
		cRetorno := "BR_AMARELO"
	ElseIf cStatus == '4'  //Pedido Bloqueado por Regra
		cRetorno := "BR_AZUL"
	ElseIf cStatus == '5' //Pedido Bloqueado por Verba
		cRetorno := "BR_LARANJA"
	EndIf
Return cRetorno
/*/{Protheus.doc} StatusInt
Retorna status da integração
@author amanda.vieira
@since 18/10/2018
/*/
Static Function StatusInt(cFilPed,cPedido,cStatus)
Local cRetorno := ""
Local cQuery   := ""
Local cAliasSC6:= GetNextAlias()
	cQuery := " SELECT CASE WHEN C6_FALHA   IS NOT NULL THEN '1' ELSE '0' END FALHA,"
	cQuery +=        " CASE WHEN C6_PARCIAL IS NOT NULL THEN '1' ELSE '0' END PARCIAL"
	cQuery +=   " FROM "+RetSqlName("SC6")+" SC6"
	cQuery +=   " LEFT JOIN (SELECT C6_FILIAL,"
	cQuery +=                     " C6_NUM,"
	cQuery +=                     " '1' AS C6_PARCIAL"
	cQuery +=                " FROM "+RetSqlName("SC6")
	cQuery +=               " WHERE C6_FILIAL = '"+cFilPed+"'"
	cQuery +=                 " AND C6_NUM    = '"+cPedido+"'"
	cQuery +=                 " AND C6_INTROT <> '2'"
	cQuery +=                 " AND D_E_L_E_T_ = ' ') SC6A"
	cQuery +=     " ON SC6A.C6_FILIAL = SC6.C6_FILIAL"
	cQuery +=    " AND SC6A.C6_NUM    = SC6.C6_NUM"
	cQuery +=   " LEFT JOIN (SELECT C6_FILIAL,"
	cQuery +=                     " C6_NUM,"
	cQuery +=                     " '1' AS C6_FALHA"
	cQuery +=                " FROM "+RetSqlName("SC6")
	cQuery +=               " WHERE C6_FILIAL = '"+cFilPed+"'"
	cQuery +=                " AND C6_NUM    = '"+cPedido+"'"
	cQuery +=                " AND C6_INTROT = '3'"
	cQuery +=                " AND D_E_L_E_T_ = ' ') SC6C"
	cQuery +=     " ON SC6C.C6_FILIAL = SC6.C6_FILIAL"
	cQuery +=    " AND SC6C.C6_NUM    = SC6.C6_NUM"
	cQuery +=  " WHERE SC6.C6_FILIAL = '"+cFilPed+"'"
	cQuery +=    " AND SC6.C6_NUM    = '"+cPedido+"'"
	cQuery +=    " AND SC6.C6_INTROT <> '1'"
	cQuery +=    " AND SC6.D_E_L_E_T_ = ' '"
	cQuery +=  " GROUP BY SC6.C6_FILIAL,"
	cQuery +=           " SC6.C6_NUM,"
	cQuery +=           " C6_FALHA,"
	cQuery +=           " C6_PARCIAL"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSC6, .F., .T.)
	If (cAliasSC6)->(EoF())
		cRetorno := "BR_AMARELO" // Não Integrado
	ElseIf (cAliasSC6)->FALHA == "1"
		cRetorno := "BR_VERMELHO"// Falha de Integração
	ElseIf (cAliasSC6)->PARCIAL == "1"
		cRetorno := "BR_AZUL"    // Integrado Parcialmente
	Else
		cRetorno := "BR_VERDE"   // Integrado
	EndIf
	(cAliasSC6)->(DbCloseArea())
Return cRetorno

/*/{Protheus.doc} UpdSelecao
	Permite Selecionar Novamente o Intervalo
@author Jackson patrick Werka
@since 09/08/2018
@version 1.0
/*/
Static Function UpdSelecao()
	If !ExistQtdAlt() .Or. MsgYesNo(STR0044,STR0045) // Ao realizar o refresh da tela as quantidades alteradas para a integração serão descartadas. Deseja continuar? // Atenção
		lMarkAll := .F.
		If Pergunte('OMSXCPL6', .T.)
			LoadData()
			oBrowse:Refresh(.T.)
		EndIf
	EndIf
Return

/*/{Protheus.doc} UpdSelecao
	Efetua uma atualização nos dados do Browse com os mesmos parâmetros da pergunta anterior
@author Jackson patrick Werka
@since 09/08/2018
@version 1.0
/*/
Static Function RefreshBrw(lPergunta)
Default lPergunta := .F.
	If !lPergunta .Or. !ExistQtdAlt() .Or. MsgYesNo(STR0044,STR0045) // Ao realizar o refresh da tela as quantidades alteradas para a integração serão descartadas. Deseja continuar? // Atenção
		lMarkAll := .F.
		Pergunte('OMSXCPL6', .F.)
		LoadData()
		oBrowse:Refresh(.T.)
	EndIf
Return

/*/{Protheus.doc} AllMark
	Marca todos os registros da seleção no Browse
@author Jackson Patrick Werka
@since 08/08/2018
/*/
Static Function AllMark()
Local aAreaTmp  := (cAliasTMP)->(GetArea())
Local cAliasBrw := ""
Local cMark     := ""

	lMarkAll := !lMarkAll
	cMark    := Iif(lMarkAll,oBrowse:Mark(),Space(2))
	// Busca alias do próprio browse, que neste caso é cAliasTMP
	cAliasBrw := oBrowse:Alias()
	// Ao executar o comando DbGoTop(), o sistema re-executa todos os filtros e, desta forma,
	// a regra de marcação será executada apenas para os registros que o usuário vê em tela
	(cAliasBrw)->(DbGoTop())
	While (cAliasBrw)->(!Eof())
		Reclock(cAliasTMP,.F.)
		(cAliasTMP)->TMP_MARK := cMark
		(cAliasTMP)->(MsUnlock())
		(cAliasBrw)->(DbSkip())
	EndDo

RestArea(aAreaTmp)
oBrowse:Refresh()
Return

/*/{Protheus.doc} Cpl6EnvPed
	Realiza o envio de Pedidos de Venda para o cockpit logistico
@author rafael.kleestadt
@since 21/10/2016
@version 1.0
@param nModo, numeric, Operação configurada, MODEL_OPERATION_UPDATE ou MODEL_OPERATION_DELETE
@param aRec, array, Array de registros marcados e visiveis
@example
(examples)
@see (links_or_references)
/*/
Static Function Cpl6EnvPed(nModo,cAliasQry,nTot)
Local cFilBkp   := cFilAnt
Local cAliasSC6 := ""
Local cQuery    := ""
Local cSeqInt   := ""
Local cFalha    := ""
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSC6  := SC6->(GetArea())
Local aAreaTab  := {}
Local aTamSx3   := TamSX3("C6_QTDVEN")
Local aCabecalho:= {}
Local aFalhas   := {}
Local aEnviados := {}
Local aResumo   := {}
Local aRetPE    := {}
Local lIsBlind  := IsBlind()
Local lGravaData:= .F.
Local lQtdIndisp:= .F.
Local lRet      := .T.
Local nTotalReg := 0
Local nQtdFalhas:= 0
Local lOMSCPL6B := ExistBlock("OMSCPL6B")
Local lOMSTOL02	:= ExistBlock("OMSTOL02")
Local aEnvPE    := {}
Local aFalhPE   := {}
Local dDtIni    := dDatabase
Local cHrIni    := Time()

	// Deve forçar a releitura do grupo de perguntas (via job/schedule nao deve executar)
	If !lIsBlind
		Pergunte("OMSXCPL6",.F.)
	EndIf
	OsLogCPL("OMSXCPL6 -> Cpl6EnvPed -> Valores do Pergunte OMSXCPL6 para validacao de quantidade e saldo: " +;
			" Filial de ? = '" + cValToChar(MV_PAR01) + "', Filial até ? = '" + cValToChar(MV_PAR02) +;
			"', Pedido de ? = '" + cValToChar(MV_PAR03) + "', Pedido até ? = '" + cValToChar(MV_PAR04) + ;
			"', Emissão de ? = '" + cValToChar(MV_PAR05) + "', Emissão até ?= '" + cValToChar(MV_PAR06) + ;
			"', Data liberação de ? = '" + cValToChar(MV_PAR07) + "', Data liberação até ? = '" + cValToChar(MV_PAR08) + ;
			"', Cliente de ? = '" + cValToChar(MV_PAR09) + "', Loja de ? = '" + cValToChar(MV_PAR10) + ;
			"', Cliente até ? = '" + cValToChar(MV_PAR11) + "', Loja até ? = '" + cValToChar(MV_PAR12) +;
			"', Data de entrega de ? = '" + cValToChar(MV_PAR13) + "', Data de entrega até ? = '" + cValToChar(MV_PAR14) + "'","INFO")

	//Adiciona linha inicial do relatório de cancelamento
	aAdd(aCabecalho,STR0052+CRLF) // Resumo do envio da(s) sequência(s) de integração.

	SC5->(DbSetOrder(1))
	SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM

	ProcRegua(nTot)
	
	While (cAliasQry)->(!Eof())
		
		nTotalReg += 1 //Armazena total de registros
		cSeqInt   := "" //Limpa variável

		//Posiciona na SC5
		SC5->(DbGoTo((cAliasQry)->TMP_RECSC5))
		If !lIsBlind
			IncProc(cValToChar(Int(nTotalReg/nTot * 100)) + "% Enviado ")
		EndIf
			
		// Atualiza a filial corrente para a filial do pedido
		cFilAnt := SC5->C5_FILIAL

		OsLogCPL("OMSXCPL6 -> Cpl6EnvPed -> "+Replicate("-", 100),"INFO")
		OsLogCPL("OMSXCPL6 -> Cpl6EnvPed -> INICIO DE ENVIO DE PEDIDOS ","INFO")
		OsLogCPL("OMSXCPL6 -> Cpl6EnvPed -> "+Replicate("-", 100),"INFO")
		OsLogCPL("OMSXCPL6 -> Cpl6EnvPed -> Pedido ("+cValToChar(Trim(SC5->C5_FILIAL))+"-"+cValToChar(Trim(SC5->C5_NUM))+"). Iniciando Envio para o Neolog.","INFO")

		If lOMSCPL6B //Validação complementar para a integração do pedido de venda
			OsLogCPL("OMSXCPL6 -> Cpl6EnvPed -> Encontrado o Ponto de Entrada OMSCPL6B.","INFO")
			aAreaTab  := SC5->(GetArea())
			aRetPE := ExecBlock("OMSCPL6B",.F.,.F.,{SC5->C5_FILIAL,SC5->C5_NUM})
			aRetPE := If(ValType(aRetPE)=="A",aRetPE,{})
			If !Empty(aRetPE)
				If !(lRet := Iif(ValType(aRetPE[1])=="L",aRetPE[1],.T.))
					If (ValType(aRetPE[2])=="C")
						cFalha := aRetPE[2]
					EndIf
				EndIf
			EndIf
			RestArea(aAreaTab)
		Else	
			OsLogCPL("OMSXCPL6 -> Cpl6EnvPed -> Ponto de Entrada OMSCPL6B não encontrado.","INFO")
		EndIf

		If lRet
			//Valida novamente se quantidade informada para a integração ainda é valida
			lQtdIndisp := !(Cpl6VldEnv())
			If !lQtdIndisp
				//Gera nova sequência de integração para o pedido
				cSeqInt := ProxSeqInt(SC5->C5_FILIAL,SC5->C5_NUM)
			EndIf
		EndIf
		
		//Realiza envio do XML
		If lRet .And. !lQtdIndisp .And. OMSXCPLENVIA("SC5",nModo,cSeqInt,oTempAux,@cFalha,,.F.)
			//Grava resumo
			If Empty(aEnviados)
				aAdd(aEnviados,STR0053) //Registros Enviados:
			EndIf
			aAdd(aEnviados,OmsFmtMsg(STR0054,{{"[VAR01]",SC5->C5_FILIAL},{"[VAR02]",SC5->C5_NUM},{"[VAR03]",cSeqInt}})) //Filial [VAR01] | Pedido [VAR02] | Sequência Integração [VAR03].
			IIF(lOMSTOL02,aAdd(aEnvPE,{SC5->C5_FILIAL,SC5->C5_NUM,cSeqInt}),)
			//Busca itens do pedido na tabela temporária auxiliar
			cQuery := " SELECT SC6.C6_FILIAL,"
			cQuery +=        " SC6.C6_NUM,"
			cQuery +=        " SC6.C6_ITEM,"
			cQuery +=        " SC6.C6_PRODUTO,"
			cQuery +=        " SC6.C6_QTDINT"
			cQuery +=   " FROM "+oTempAux:GetRealName()+" SC6"
			cQuery +=  " WHERE SC6.C6_FILIAL = '"+SC5->C5_FILIAL+"'"
			cQuery +=    " AND SC6.C6_NUM    = '"+SC5->C5_NUM+"'"
			cQuery += " AND SC6.C6_QTDINT <> 0"
			cQuery +=    " AND SC6.D_E_L_E_T_ = ' '"
			OsLogCPL("OMSXCPL6 -> Cpl6EnvPed -> Conteúdo de cQuery 1: " + cValToChar(Trim(cQuery)),"INFO")
			cAliasSC6 := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSC6, .F., .T.)
			TCSetField(cAliasSC6,'C6_QTDINT','N',aTamSx3[1],aTamSx3[2])
			While (cAliasSC6)->(!EoF())
				//Grava sequência de integração
				RecLock("DK3",.T.)
				DK3->DK3_SEQUEN := cSeqInt
				DK3->DK3_FILIAL := (cAliasSC6)->C6_FILIAL
				DK3->DK3_PEDIDO := (cAliasSC6)->C6_NUM
				DK3->DK3_ITEMPE := (cAliasSC6)->C6_ITEM
				DK3->DK3_PRODUT := (cAliasSC6)->C6_PRODUTO
				DK3->DK3_QTDINT := (cAliasSC6)->C6_QTDINT
				DK3->DK3_STATUS := "1" //Integrado
				DK3->(MsUnLock())
				OsLogCPL("OMSXCPL6 -> Cpl6EnvPed -> Pedido gravado na DK3.","INFO")
				//Busca quantidade já integrada do pedido
				nQtdInt := Cpl6QtdInt((cAliasSC6)->C6_FILIAL,(cAliasSC6)->C6_NUM,(cAliasSC6)->C6_ITEM,(cAliasSC6)->C6_PRODUTO)
				//Busca item do pedido para alteração do status de integração
				If SC6->(DbSeek((cAliasSC6)->(C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO)))
					lGravaData := Empty(SC6->C6_DATCPL)
					RecLock('SC6',.F.)
					If QtdComp(nQtdInt) < QtdComp(SC6->C6_QTDVEN)
						SC6->C6_INTROT := '4' //Integrado parcialmente
						OsLogCPL("OMSXCPL6 -> Cpl6EnvPed -> Pedido integrado parcialmente.","INFO")
						If lGravaData
							SC6->C6_DATCPL := Date()
							SC6->C6_HORCPL := Time()
						EndIf
					Else
						SC6->C6_INTROT := '2' //Integrado
						OsLogCPL("OMSXCPL6 -> Cpl6EnvPed -> Pedido integrado totalmente.","INFO")
						If lGravaData
							SC6->C6_DATCPL := Date()
							SC6->C6_HORCPL := Time()
						EndIf
					EndIf
					SC6->(MsUnlock())
				EndIf
				(cAliasSC6)->(DbSkip())
			EndDo
			(cAliasSC6)->(DbCloseArea())
		Else
			//Grava resumo
			nQtdFalhas += 1
			If Empty(aFalhas)
				aAdd(aFalhas,STR0055) //Registros Não Enviados:
			EndIf
			IIF(lOMSTOL02,aAdd(aFalhPE,{SC5->C5_FILIAL,SC5->C5_NUM}),)
			If lQtdIndisp
				aAdd(aFalhas,OmsFmtMsg(STR0056+CRLF+STR0057,{{"[VAR01]",SC5->C5_FILIAL},{"[VAR02]",SC5->C5_NUM}})) // Filial [VAR01] | Pedido [VAR02]. // Gravado registro de falha (DJW). Motivo: Saldo indisponível para envio.
			Else
				cFalha := FwCutOff(cFalha) //Remove quebras de linha
				aAdd(aFalhas,OmsFmtMsg(STR0056+CRLF+STR0058+cFalha,{{"[VAR01]",SC5->C5_FILIAL},{"[VAR02]",SC5->C5_NUM}})) // Filial [VAR01] | Pedido [VAR02]. // Gravado registro de falha (DJW). Motivo:
			EndIf
			aAdd(aFalhas,Replicate("-",166))

			cPedido := PadR(SC5->C5_NUM,TamSx3("C6_NUM")[1])
			cQuery := " SELECT SC6.R_E_C_N_O_ RECNOSC6"
			cQuery +=   " FROM "+RetSqlName('SC6')+" SC6"
			cQuery +=  " WHERE SC6.C6_FILIAL = '"+xFilial('SC6')+"'"
			cQuery +=    " AND SC6.C6_NUM    = '"+cPedido+"'"
			cQuery +=    " AND SC6.C6_INTROT <>  '2'"
			cQuery +=    " AND SC6.D_E_L_E_T_= ' '"
			cQuery := ChangeQuery(cQuery)
			OsLogCPL("OMSXCPL6 -> Cpl6EnvPed -> Conteúdo de cQuery 2: " + cValToChar(Trim(cQuery)),"INFO")
			cAliasSC6 := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSC6, .F., .T.)
			While (cAliasSC6)->(!Eof())
				SC6->(dbGoTo((cAliasSC6)->RECNOSC6))
				RecLock('SC6',.F.)
				SC6->C6_INTROT := '3'
				SC6->C6_DATCPL := Date()
				SC6->C6_HORCPL := Time()
				SC6->(MsUnLock())
				SC6->(DbSkip())
				(cAliasSC6)->(DbSkip())
			EndDo
			(cAliasSC6)->(DbCloseArea())
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	// Restaura a filial do sistema
	cFilAnt := cFilBkp

	IF nQtdFalhas > 0
		aAdd(aCabecalho,STR0068 + cValToChar(nQtdFalhas)+CRLF) //"Registros que apresentaram falha no envio: "
	EndIF
	IF (nTotalReg - nQtdFalhas) > 0
		aAdd(aCabecalho,STR0069 + cValToChar((nTotalReg - nQtdFalhas))+CRLF)//"Registros que apresentaram sucesso no envio: "
	EndIF
	aAdd(aCabecalho, STR0070 + cValToChar(nTotalReg)+CRLF)	//"Total de registros processados: "

	//Monta array do resumo
	aEval(aCabecalho,{|x|Aadd(aResumo,x)})
	aEval(aFalhas,{|x|Aadd(aResumo,x)})
	aEval(aEnviados,{|x|Aadd(aResumo,x)})

	If lOMSTOL02
		OsLogCpl("OMSXCPL6 -> Cpl6EnvPed -> Inicio execução do Ponto de entrada OMSTOL02.","INFO")
		ExecBlock("OMSTOL02",.F.,.F.,{dDtIni,cHrIni,dDatabase,Time(),aEnvPE,aFalhPE})
	EndIf

	If !lIsBlind
		//Apresenta resumo do cancelamento
		OmsShowWng(aResumo)
	EndIf

	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
Return lRet

/*/{Protheus.doc} Cpl6EnvBat
	Responsável por enviar os pedidos ao CPL em batch
@author rafael.kleestadt
@since 21/10/2016
@version 1.0
@see (links_or_references)
/*/
Static Function Cpl6EnvBat()
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasQry := ""
Local lRet      := .F.

	cQuery := "SELECT TMP_FILIAL,"
	cQuery +=       " TMP_RECSC5"
	cQuery +=  " FROM "+ oTempTab:GetRealName()
	cQuery += " WHERE D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY TMP_FILIAL, TMP_RECSC5"
	OsLogCPL("OMSXCPL6 -> Cpl6EnvBat -> Conteúdo de cQuery: " + cValToChar(Trim(cQuery)),"INFO")
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	If (cAliasQry)->(!EoF())
		lRet := Cpl6EnvPed(MODEL_OPERATION_INSERT, cAliasQry,1)
	EndIf
	(cAliasQry)->(DbCloseArea())

RestArea(aAreaAnt)
Return lRet


/*/{Protheus.doc} Cpl6EnvOtm
	Responsável por atualizar o movimento no cockpit logístico,
	de todos os movimentos visiveis e marcados na grid.
@author rafael.kleestadt
@since 21/10/2016
@version 1.0
/*/
Static Function Cpl6EnvOtm()
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasQry := ""
Local cSelect   := ""
Local cSelectCnt:= ""
Local nTot		:= 0
Local cGroupBy  := ""	

	//Primeira Query
	cSelect := "SELECT TMP.TMP_FILIAL,"
	cSelect +=       " TMP.TMP_RECSC5"

	cSelectCnt := "SELECT COUNT(TMP_RECSC5) QTDTOTAL"

	cQuery +=  " FROM "+ oTempTab:GetRealName()+" TMP"
	cQuery += " INNER JOIN "+oTempAux:GetRealName()+" SC6"
	cQuery +=    " ON SC6.C6_FILIAL = TMP.TMP_FILIAL"
	cQuery +=   " AND SC6.C6_NUM    = TMP.TMP_PEDIDO"
	cQuery +=   " AND SC6.C6_QTDINT <> 0"
	cQuery +=   " AND SC6.D_E_L_E_T_ = ' '"
	cQuery += " WHERE TMP.TMP_MARK   = '"+oBrowse:Mark()+"'"
	cQuery +=   " AND TMP.D_E_L_E_T_ = ' '"

	cGroupBy += " GROUP BY TMP.TMP_FILIAL,"
	cGroupBy +=          " TMP.TMP_RECSC5"
	cGroupBy += " ORDER BY TMP.TMP_FILIAL,"
	cGroupBy +=          " TMP.TMP_RECSC5"

	cSelectCnt := cSelectCnt + cQuery		
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSelectCnt), cAliasQry, .F., .T.)
	nTot := (cAliasQry)->QTDTOTAL
	(cAliasQry)->(dbCloseArea())

	cSelect := cSelect + cQuery	+ cGroupBy	
	OsLogCPL("OMSXCPL6 -> Cpl6EnvOtm -> Conteúdo de cSelect: " + rTrim(cSelect) ,"INFO")
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSelect), cAliasQry, .F., .T.)	

	If (cAliasQry)->(EoF())
		MsgAlert(STR0010) // "Nenhum registro válido selecionado para o envio de pedidos!"
	Else
		Processa({||Cpl6EnvPed(MODEL_OPERATION_INSERT, cAliasQry,nTot)}, STR0002, STR0009) // Enviando Pedidos ## Enviando pedidos ao Cockpit Logístico. Aguarde...
		RefreshBrw()
	EndIf
	(cAliasQry)->(DbCloseArea())

	RestArea(aAreaAnt)
Return

/*/{Protheus.doc} Cpl6CanOtm
	Responsável por desatualizar o movimento no cockpit logístico,
	de todos os movimentos visiveis e marcados na grid.
@author siegklenes.beulke
@since 30/08/2016
@version 1.0
/*/
Static Function Cpl6CanOtm(lAutoma)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasQry := ""
Local lRet      := .F.
Default lAutoma   := .F.

	OsLogCPL("OMSXCPL6 -> Cpl6CanOtm -> "+Replicate("-", 100),"INFO")
	OsLogCPL("OMSXCPL6 -> Cpl6CanOtm -> INICIO DE DESATUALIZAÇÃO DE PEDIDO","INFO")
	OsLogCPL("OMSXCPL6 -> Cpl6CanOtm -> "+Replicate("-", 100),"INFO")

	If lAutoma
		(cAliasTMP)->(DbGoTop())
	EndIf

	cQuery := "SELECT SC6.C6_NUM"
	cQuery +=  " FROM " + RetSqlName("SC6") + " SC6 "
	cQuery += " WHERE SC6.C6_FILIAL  = '"+(cAliasTMP)->TMP_FILIAL+"'"
	cQuery +=   " AND SC6.C6_NUM     = '"+(cAliasTMP)->TMP_PEDIDO+"'"
	cQuery +=   " AND SC6.C6_INTROT IN ('2','4')" // Integrado ou Integrado Parcial
	cQuery +=   " AND SC6.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	OsLogCPL("OMSXCPL6 -> Cpl6CanOtm -> Pedido ("+cValToChar(Trim((cAliasTMP)->TMP_FILIAL))+"-"+cValToChar(Trim((cAliasTMP)->TMP_PEDIDO))+"). Conteúdo de cQuery: " + cValToChar(Trim(cQuery)),"INFO")
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	If (cAliasQry)->(EoF()) .Or. (cAliasTMP)->TMP_SITPED = '2'
		MsgAlert(STR0060) // O registro posicionado não possuí itens válidos para desatualização.
		OsLogCPL("OMSXCPL6 -> Cpl6CanOtm -> " + cValToChar(Trim(STR0060)),"INFO") 
	Else
		SC5->(DbSetOrder(1))
		SC5->(DbSeek((cAliasTMP)->TMP_FILIAL+(cAliasTMP)->TMP_PEDIDO))
		OMSCPL6BAT(oTempTab:oStruct:GetAlias(),.F.)
		If !lAutoma
			FWExecView(STR0061,"OMSXCPL6B", MODEL_OPERATION_UPDATE ,, { || .T. } ,, ) // Cancelar Integração do Pedido
			RefreshBrw()
		EndIf
		OsLogCPL("OMSXCPL6 -> Cpl6CanOtm -> " + cValToChar(Trim(STR0061)),"INFO") 
		lRet := .T.
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet
/*/{Protheus.doc} Cpl6CanOtm
Função responsável por realizar o estorno de todos os pedidos marcados.
@author amanda.vieira
@since 21/02/2019
@version 1.0
/*/
Static Function Cpl6CanSel(lAutoma)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasQry := ""
Local cMsg      := ""
Local lRet      := .F.
Default lAutoma := .F.

	OsLogCPL("OMSXCPL6 -> Cpl6CanSel -> "+Replicate("-", 100),"INFO")
	OsLogCPL("OMSXCPL6 -> Cpl6CanSel -> INICIO DE ESTORNO DE PEDIDO","INFO")
	OsLogCPL("OMSXCPL6 -> Cpl6CanSel -> "+Replicate("-", 100),"INFO")

	cQuery := "SELECT TMP.TMP_FILIAL,"
	cQuery +=       " TMP.TMP_RECSC5"
	cQuery +=  " FROM "+ oTempTab:GetRealName()+" TMP"
	cQuery += " INNER JOIN "+RetSqlName('SC6')+" SC6"
	cQuery +=    " ON SC6.C6_FILIAL = TMP.TMP_FILIAL"
	cQuery +=   " AND SC6.C6_NUM    = TMP.TMP_PEDIDO"
	cQuery +=   " AND SC6.C6_INTROT IN ('2','4')" // Integrado ou Integrado Parcial
	cQuery +=   " AND SC6.D_E_L_E_T_ = ' '"
	If !lAutoma
		cQuery += " WHERE TMP.TMP_MARK   = '"+oBrowse:Mark()+"'"
	EndIf
	cQuery +=   " AND TMP.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY TMP.TMP_FILIAL,"
	cQuery +=          " TMP.TMP_RECSC5"
	cQuery += " ORDER BY TMP.TMP_FILIAL,"
	cQuery +=          " TMP.TMP_RECSC5"
	cQuery := ChangeQuery(cQuery)
	OsLogCPL("OMSXCPL6 -> Cpl6CanSel -> Conteúdo de cQuery: " + cValToChar(Trim(cQuery)),"INFO")
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	If (cAliasQry)->(EoF()) .And. !lAutoma
		MsgAlert(STR0066) // Nenhum registro válido selecionado para o estorno da integração.
		OsLogCPL("OMSXCPL6 -> Cpl6CanSel -> " + cValToChar(Trim(STR0066)),"INFO")
	Else
		lRet := .T.
		If !lAutoma .And. OmsQuestion(STR0067,"OMSXCPL6") // Confirma o estorno de todas as sequências de integração dos pedidos selecionados?
			OsLogCPL("OMSXCPL6 -> Cpl6CanSel -> Inicio do estorno da integração." ,"INFO")
			OMSCPL6TMP(oTempTab)
			Processa({||OmsCpl6Est()})
			RefreshBrw()
		EndIf
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet
/*/{Protheus.doc} Cpl6VisCli
	Consulta o cliente e/ou fornecedor do pedido de venda
@author rafael.kleestadt
@since 21/10/2016
@version 1.0
/*/
Static Function Cpl6VisCli()
Local cFilBkp := cFilAnt

	cFilAnt := (cAliasTMP)->TMP_FILIAL
	If (cAliasTMP)->TMP_TIPPED $ 'D|B'
		SA2->(DbSetOrder(1))
		If SA2->(dbSeek(xFilial('SA2')+(cAliasTMP)->TMP_CLIENT+(cAliasTMP)->TMP_LOJCLI))
			Private lMvcMata020 := TableInDic( "G3Q", .F. )
			A020Visual("SA2", SA2->(RecNo()), 1)
		Else
			Help("",1,"OMSXCPL62") //"Registro não encontrado"
		EndIf
	Else
		SA1->(DbSetOrder(1))
		If SA1->(dbSeek(xFilial('SA1')+(cAliasTMP)->TMP_CLIENT+(cAliasTMP)->TMP_LOJCLI))
			Private aRotina   := {{STR0030, "A030Visual", 0, 2, 0, NIL}} // Visualizar
			Private cCadastro := STR0029 //"Clientes"
			A030Visual("SA1", SA1->(RecNo()), 1)
		Else
			Help("",1,"OMSXCPL62") //"Registro não encontrado"
		EndIf
	EndIf
	cFilAnt := cFilBkp
Return

/*/{Protheus.doc} Cpl6VisPed
	Realiza a consulta dos dados do Pedido de Venda posicionado na grid.
@author rafael.kleestadt
@since 21/10/2016
@version 1.0
/*/
Static Function Cpl6VisPed()
Local cFilBkp := cFilAnt

	cFilAnt := (cAliasTMP)->TMP_FILIAL
	SC5->(dbGoTo((cAliasTMP)->TMP_RECSC5))
	Private aRotina   := {;
		{STR0030, "A030Visual", 0, 2, 0, NIL},;
		{STR0030, "A030Visual", 0, 2, 0, NIL};
	} // Visualizar
	Private cCadastro := STR0027 //"Pedido de Venda"
	A410Visual("SC5",SC5->(Recno()),2)
	cFilAnt := cFilBkp

Return

/*/{Protheus.doc} Cpl6CFalha
	Consulta o registro de falha do item posicionado na grid
@author rafael.kleestadt
@since 06/12/2016
@version 1.0
/*/
Static Function Cpl6CFalha(lAutoma)
Local aAreaAnt  := DJW->(GetArea())
Local cQuery    := ""
Local cAliasDJW := GetNextAlias()
Local lRet      := .F.
Default lAutoma := .F.


	OsLogCPL("OMSXCPL6 -> Cpl6CFalha -> "+Replicate("-", 100),"INFO")
	OsLogCPL("OMSXCPL6 -> Cpl6CFalha -> INICIO DE CONSULTA DE FALHA","INFO")
	OsLogCPL("OMSXCPL6 -> Cpl6CFalha -> "+Replicate("-", 100),"INFO")

	cFilAnt := (cAliasTMP)->TMP_FILIAL

	cQuery := " SELECT MAX(R_E_C_N_O_) RECNODJW"
	cQuery +=   " FROM "+RetSqlName('DJW')
	cQuery +=  " WHERE DJW_TABELA = 'SC5'"
	cQuery +=    " AND DJW_RECTAB = '"+cValToChar((cAliasTMP)->TMP_RECSC5)+"'"
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	OsLogCPL("OMSXCPL6 -> Cpl6CFalha -> Conteúdo de cQuery: " + cValToChar(Trim(cQuery)),"INFO")
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasDJW, .T., .T. )
	If (cAliasDJW)->(!EoF())
		lRet := .T.
		DJW->(DbGoTo((cAliasDJW)->RECNODJW))
		If !lAutoma
			FwExecView(STR0028, "OMSXCPL4") // Registro de Falha
		EndIf
	EndIf
	(cAliasDJW)->(DbCloseArea())

	RestArea(aAreaAnt)
Return lRet

/*/{Protheus.doc} Scheddef
	Permite a execução agendada.
@author siegklenes.beulke
@since 30/08/2016
@version 1.0
/*/
Static Function SchedDef()
	Local aParam
	aParam := { "P",;	//Tipo R para relatorio P para processo
				"OMSXCPL6",;	 // Pergunte do relatorio, caso nao use passar ParamDef
							,;  // Alias
							,;   //Array de ordens
				STR0050} //Envio de Pedidos pendentes para o Cockpit Logístico
Return aParam

/*/{Protheus.doc} MontOpcoes
	Monta as opções para serem usada no filtro nos campos do tipo combobox
@author Jackson Patrick Werka
@since 10/08/2016
@version 1.0
/*/
Static Function MontOpcoes(aStrs)
Local aOpcoes := {}
Local nX      := 0

	For nX := 1 to Len(aStrs)
		Aadd(aOpcoes,cValToChar(nX)+"="+aStrs[nX])
	Next nX
Return aOpcoes
/*/{Protheus.doc} QryPedido
Monta query dos pedidos
@author amanda.vieria
@since 16/10/2018
@version 1.0
/*/
Static Function QryPedido()
Local aTipPed    := {}
Local aTipFre    := {}
Local cQuery     := ""
Local cRetPE     := ""
Local cTipPedIni := ""
Local cTipPedFim := ""
Local cTipPedIn  := ""
Local cTipFreIni := ""
Local cTipFreFim := ""
Local cTipFreIn  := ""
Local nPos       := 0
Local nX         := 0
Local lTipFreC   := ValType(MV_PAR21) == "C" //Variável utilizada para suavização 12.1.17
Local lOSCP6QRY  := ExistBlock("OSCP6QRY") //Ponto de entrada para incrementar a query
Local lQtdLib    := (SuperGetMv("MV_CPLPELB",.F.,"2") == "2") //Indica se permite quantidades não liberadas
	//--Bloco que controla as informações do Range do pergunte do Tipo de Pedido (MV_Par15)
	aTipPed := Iif(!Empty(mv_par15),Str2Arr(Upper(mv_par15), ";"),{})
	If Len(aTipPed) > 0
		nPos := At("-",aTipPed[1])
		If nPos > 0
			cTipPedIni := SubStr(aTipPed[1],1,(nPos-1))
			cTipPedFim := SubStr(aTipPed[1],nPos+1)
		Else
			For nX := 1 To Len(aTipPed)
				cTipPedIn +=  "'" + aTipPed[nx] + Iif(nX == Len(aTipPed),"'", "',")
			Next nX
		EndIf
	EndIf
	//--Bloco que controla as informações do Range do pergunte do Tipo de Frete (MV_PAR21)
	If lTipFreC
		aTipFre := Iif(!Empty(MV_PAR21),Str2Arr(Upper(MV_PAR21), ";"),{})
		If Len(aTipFre) > 0
			nPos := At("-",aTipFre[1])
			If nPos > 0
				cTipFreIni := SubStr(aTipFre[1],1,(nPos-1))
				cTipFreFim := SubStr(aTipFre[1],nPos+1)
			Else
				For nX := 1 To Len(aTipFre)
					cTipFreIn +=  "'" + aTipFre[nx] + Iif(nX == Len(aTipFre),"'", "',")
				Next nX
			EndIf
		EndIf
	EndIf

	cQuery := "SELECT ' ' AS TMP_MARK,"
	cQuery +=       " ' ' TMP_INTROT,"
	cQuery +=       " CASE WHEN (SC5.C5_LIBEROK = ' ' AND SC5.C5_NOTA = ' ' AND SC5.C5_BLQ = ' ') THEN '1'"
	cQuery +=            " WHEN (SC5.C5_NOTA <> ' ' OR (SC5.C5_LIBEROK = 'E' AND SC5.C5_BLQ = ' ')) THEN '2'"
	cQuery +=            " WHEN (SC5.C5_LIBEROK <> ' ' AND SC5.C5_NOTA = ' ' AND SC5.C5_BLQ = ' ') THEN '3'"
	cQuery +=            " WHEN SC5.C5_BLQ = '1' THEN '4'"
	cQuery +=            " WHEN SC5.C5_BLQ = '2' THEN '5'"
	cQuery +=        " END TMP_SITPED,"
	cQuery +=       " SC5.C5_FILIAL,"
	cQuery +=       " SC5.C5_NUM,"
	cQuery +=       " SC5.C5_TIPO,"
	cQuery +=       " SC5.C5_CLIENTE,"
	cQuery +=       " SC5.C5_LOJACLI,"
	cQuery +=       " CASE WHEN SC5.C5_TIPO IN ('B', 'D') THEN SA2.A2_NOME ELSE SA1.A1_NOME END AS TMP_NOMCLI,"
	cQuery +=       " CASE WHEN MIN(SC9.C9_DATALIB) IS NULL THEN ' ' ELSE MIN(SC9.C9_DATALIB) END TMP_DATLIB,"
	cQuery +=       " CASE WHEN SC5.C5_FECENT <> ' ' THEN SC5.C5_FECENT"
	If lQtdLib
		cQuery +=        " WHEN MIN(SC9.C9_DATENT) IS NULL THEN ' ' ELSE MIN(SC9.C9_DATENT) END TMP_DATENT, "
	Else
		cQuery +=        " WHEN MIN(SC6.C6_ENTREG) IS NULL THEN ' ' ELSE MIN(SC6.C6_ENTREG) END TMP_DATENT, "
	EndIf
	cQuery +=       " SC5.R_E_C_N_O_ SC5_RECNO,"
	cQuery +=       " SC5.C5_FECENT"
	//Inclusão de Novos Campos
	cQuery +=       " ,CASE WHEN SC5.C5_TIPO IN ('B', 'D') THEN SA2.A2_NREDUZ	ELSE SA1.A1_NREDUZ	END AS TMP_NOMFAN "	//Nome Fantasia
	cQuery +=       " ,CASE WHEN SC5.C5_TIPO IN ('B', 'D') THEN SA2.A2_CGC 		ELSE SA1.A1_CGC		END AS TMP_CGCCLI "	//CPNJ/CPF
	cQuery +=       " ,CASE WHEN SC5.C5_TIPO IN ('B', 'D') THEN SA2.A2_INSCR	ELSE SA1.A1_INSCR	END AS TMP_IECLI "	//IE

	//Inclusão de Redespacho
	cQuery +=       " ,CASE WHEN (SC5.C5_REDESP IS NULL OR SC5.C5_REDESP = '') THEN '' ELSE SC5.C5_REDESP   END AS TMP_REDESP " //Codigo do Redespachante	
	cQuery +=       " ,CASE WHEN (SC5.C5_REDESP IS NULL OR SC5.C5_REDESP = '') THEN '' ELSE SA4.A4_NREDUZ	END AS TMP_REDNOM "	//Nome do Redespachante		

	cQuery +=       " ,CASE WHEN (SC5.C5_REDESP IS NOT NULL AND SC5.C5_REDESP <> '') THEN SA4.A4_MUN WHEN (SC5.C5_REDESP IS NULL OR SC5.C5_REDESP = '') AND SC5.C5_TIPO IN ('B', 'D') THEN SA2.A2_MUN ELSE SA1.A1_MUN END AS TMP_MUNCLI " //Municipio
	cQuery +=       " ,CASE WHEN (SC5.C5_REDESP IS NOT NULL AND SC5.C5_REDESP <> '') THEN SA4.A4_EST WHEN (SC5.C5_REDESP IS NULL OR SC5.C5_REDESP = '') AND SC5.C5_TIPO IN ('B', 'D') THEN SA2.A2_EST ELSE SA1.A1_EST END AS TMP_UFCLI "  //UF

	cQuery +=  " FROM " + RetSqlName("SC5") + " SC5 "
	cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 "
	cQuery +=    " ON SC6.C6_FILIAL = SC5.C5_FILIAL"
	cQuery +=   " AND SC6.C6_NUM = SC5.C5_NUM"
	If ValType(MV_PAR20) == "N" .And. MV_PAR20 <= 4
		If MV_PAR20 == 1 .Or. IsBlind()
			cQuery += " AND SC6.C6_INTROT IN (' ', '1')" //-- Não Integrado
		ElseIf MV_PAR20 == 4
			cQuery += " AND SC6.C6_INTROT = '3'" //-- Falha de Integração
		EndIf
	EndIf
	If !lQtdLib
		cQuery += " AND (SC5.C5_FECENT <> ' ' OR SC6.C6_ENTREG  BETWEEN '" + DtoS(MV_PAR13) + "' AND '" + DtoS(MV_PAR14) + "')"
	EndIf
	cQuery +=   " AND SC6.D_E_L_E_T_ = ' '"
	If lQtdLib
		cQuery += " INNER JOIN " + RetSqlName("SC9") + " SC9 "
	Else
		cQuery += " LEFT JOIN " + RetSqlName("SC9") + " SC9 "
	EndIf
	cQuery +=    " ON SC9.C9_FILIAL = SC5.C5_FILIAL"
	cQuery +=   " AND SC9.C9_PEDIDO = SC5.C5_NUM"
	cQuery +=   " AND SC9.C9_ITEM   = SC6.C6_ITEM"
	cQuery +=   " AND SC9.C9_DATALIB BETWEEN '" + dToS(MV_PAR07) + "' AND '" + dToS(MV_PAR08) + "'"
	If lQtdLib
		cQuery += " AND (SC5.C5_FECENT <> ' ' OR SC9.C9_DATENT  BETWEEN '" + DtoS(MV_PAR13) + "' AND '" + DtoS(MV_PAR14) + "')"
	EndIf 
	//Inclusão de pedido de venda com Carga montada.
	If Type("MV_PAR23") == "N" .And. MV_PAR23 == 2
		cQuery += " AND SC9.C9_CARGA   = ' '"
	EndIf
	cQuery +=   " AND SC9.D_E_L_E_T_ = ' '"
	cQuery +=  " LEFT JOIN " + RetSqlName("SA2") + " SA2 "
	cQuery +=    " ON SA2.A2_FILIAL = '"+FwxFilial('SA2')+"' "
	cQuery +=   " AND SA2.A2_COD = SC5.C5_CLIENTE"
	cQuery +=   " AND SA2.A2_LOJA = SC5.C5_LOJACLI"
	cQuery +=   " AND SA2.D_E_L_E_T_ = ' '"
	cQuery +=  " LEFT JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery +=    " ON SA1.A1_FILIAL = '"+FwxFilial('SA1')+"' "
	cQuery +=   " AND SA1.A1_COD = SC5.C5_CLIENTE"
	cQuery +=   " AND SA1.A1_LOJA = SC5.C5_LOJACLI"
	cQuery +=   " AND SA1.D_E_L_E_T_ = ' '"
	//Inclusão de clausula para JOIN com a SA4, baseado no Redespachante
	cQuery +=  " LEFT JOIN " + RetSqlName("SA4") + " SA4 "
	cQuery +=    " ON SA4.A4_FILIAL = '"+FwxFilial('SA4')+"' "
	cQuery +=   " AND SA4.A4_COD = SC5.C5_REDESP"
	cQuery +=   " AND SA4.D_E_L_E_T_ = ' '"	
	cQuery += " WHERE SC5.C5_FILIAL  BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
	cQuery +=   " AND SC5.C5_NUM     BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
	cQuery +=   " AND SC5.C5_EMISSAO BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "'"
	cQuery +=   " AND SC5.C5_CLIENTE BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR11 + "'"
	cQuery +=   " AND SC5.C5_LOJACLI BETWEEN '" + MV_PAR10 + "' AND '" + MV_PAR12 + "'"
	cQuery +=   " AND (SC5.C5_FECENT  BETWEEN '" + DtoS(MV_PAR13) + "' AND '" + DtoS(MV_PAR14) + "'"
	cQuery +=        " OR SC5.C5_FECENT = ' ')"
	cQuery +=   " AND SC5.C5_TPCARGA = '1' "
	If ValType(MV_PAR20) == "N"
		If MV_PAR20 == 2 //- Integrado
			cQuery +=   " AND NOT EXISTS (SELECT 1"
			cQuery +=                     " FROM "+RetSqlName('SC6')+" SC6A"
			cQuery +=                    " WHERE SC6A.C6_FILIAL = SC5.C5_FILIAL"
			cQuery +=                      " AND SC6A.C6_NUM = SC5.C5_NUM"
			cQuery +=                      " AND SC6A.C6_INTROT <> '2'"
			cQuery +=                      " AND SC6A.D_E_L_E_T_ = ' ')"
		ElseIf MV_PAR20 == 3 // Parcialmente integrado
			// Os pedidos parcialmente integrados são aqueles que possuem itens com o status 4-Parcialmente Integrados ou
			// pedidos que não encontram-se com todos os itens com o status 2-Integrado
			cQuery +=   " AND ( EXISTS (SELECT 1"
			cQuery +=                 " FROM "+RetSqlName('SC6')+" SC6A"
			cQuery +=                " WHERE SC6A.C6_FILIAL = SC5.C5_FILIAL"
			cQuery +=                  " AND SC6A.C6_NUM = SC5.C5_NUM"
			cQuery +=                  " AND SC6A.C6_INTROT = '4'"
			cQuery +=                  " AND SC6A.D_E_L_E_T_ = ' ')"
			cQuery +=   " OR ( EXISTS (SELECT 1"
			cQuery +=                 " FROM "+RetSqlName('SC6')+" SC6A"
			cQuery +=                " WHERE SC6A.C6_FILIAL = SC5.C5_FILIAL"
			cQuery +=                  " AND SC6A.C6_NUM = SC5.C5_NUM"
			cQuery +=                  " AND SC6A.C6_INTROT = '2'"
			cQuery +=                  " AND SC6A.D_E_L_E_T_ = ' ')"
			cQuery +=    " AND EXISTS (SELECT 1"
			cQuery +=                  " FROM "+RetSqlName('SC6')+" SC6A"
			cQuery +=                 " WHERE SC6A.C6_FILIAL = SC5.C5_FILIAL"
			cQuery +=                   " AND SC6A.C6_NUM = SC5.C5_NUM"
			cQuery +=                   " AND SC6A.C6_INTROT = '1'"
			cQuery +=                   " AND SC6A.D_E_L_E_T_ = ' ') ) )"
		EndIf
	EndIf
	cQuery +=   " AND SC5.D_E_L_E_T_ = ' ' "
	If !Empty(aTipPed)
		If !Empty(cTipPedIn)
			cQuery += "	AND SC5.C5_TIPO IN (" + cTipPedIn + ")"
		Else
			cQuery += "	AND SC5.C5_TIPO >= '" + cTipPedIni + "' AND SC5.C5_TIPO <= '" + cTipPedFim + "'"
		EndIf
	EndIf
	If lTipFreC //Suavização 12.1.17
		If !Empty(aTipFre)
			If !Empty(cTipFreIn)
				cQuery += "	AND SC5.C5_TPFRETE IN (" + cTipFreIn + ")"
			Else
				cQuery += "	AND SC5.C5_TPFRETE >= '" + cTipFreIni + "' AND SC5.C5_TPFRETE <= '" + cTipFreFim + "'"
			EndIf
		EndIf
	Else
		If MV_PAR21 == 2
			cQuery += "	AND SC5.C5_TPFRETE = 'C' "  //-- CIF
		ElseIf MV_PAR21 == 3
			cQuery += "	AND SC5.C5_TPFRETE = 'F' " //-- FOB
		ElseIf MV_PAR21 == 4
			cQuery += "	AND SC5.C5_TPFRETE = 'T' " //-- POR CONTA DE TERCEIROS
		ElseIf MV_PAR21 == 5
			cQuery += "	AND SC5.C5_TPFRETE = 'S' " //-- SEM FRETE
		EndIf
	EndIf
	cQuery += " AND (( SC5.C5_REDESP IS NOT NULL AND SC5.C5_REDESP <> '' AND ( SA4.A4_EST IS NULL OR SA4.A4_EST BETWEEN '" + MV_PAR16 + "' AND '" + MV_PAR17 + "')"
	cQuery += " AND ( SA4.A4_COD_MUN IS NULL OR SA4.A4_COD_MUN BETWEEN '" + MV_PAR18 + "' AND '" + MV_PAR19+ "' ) )
	cQuery += " OR ( (SC5.C5_REDESP IS NULL OR SC5.C5_REDESP = '') AND SC5.C5_TIPO IN ('D','B') AND (SA2.A2_EST IS NULL OR SA2.A2_EST BETWEEN '" + MV_PAR16 + "' AND '" + MV_PAR17 + "')"
	cQuery += " AND (SA2.A2_COD_MUN IS NULL OR SA2.A2_COD_MUN BETWEEN '" + MV_PAR18 + "' AND '" + MV_PAR19+ "'))"
	cQuery += " OR ( (SC5.C5_REDESP IS NULL OR SC5.C5_REDESP = '') AND SC5.C5_TIPO NOT IN ('D','B') AND (SA1.A1_EST IS NULL OR SA1.A1_EST BETWEEN '" + MV_PAR16 + "' AND '" + MV_PAR17 + "')"
	cQuery += " AND (SA1.A1_COD_MUN IS NULL OR SA1.A1_COD_MUN BETWEEN '" + MV_PAR18 + "' AND '" + MV_PAR19+ "')))"
	//Filtra apenas por pedidos que estão complemtamente liberados
	If MV_PAR22 == 1	
		cQuery += " AND NOT EXISTS (SELECT SC6.C6_NUM"
		cQuery +=                   " FROM "+RetSqlName('SC6')+" SC6"
		cQuery +=                  " WHERE SC6.C6_FILIAL = SC5.C5_FILIAL"
		cQuery +=                    " AND SC6.C6_NUM = SC5.C5_NUM"
		cQuery +=                    " AND SC6.C6_QTDVEN > (SC6.C6_QTDEMP+SC6.C6_QTDENT)"
		cQuery +=                    " AND SC6.C6_BLQ <> 'R '"
		cQuery +=                    " AND SC6.D_E_L_E_T_ = ' ')"
		cQuery += " AND NOT EXISTS (SELECT SC9.C9_PEDIDO"
		cQuery +=                   " FROM "+RetSqlName('SC9')+" SC9"
		cQuery +=                  " WHERE SC9.C9_FILIAL = SC5.C5_FILIAL"
		cQuery +=                    " AND SC9.C9_PEDIDO = SC5.C5_NUM"
		cQuery +=                    " AND (SC9.C9_BLEST NOT IN (' ','10') OR  SC9.C9_BLCRED NOT IN (' ','10'))"
		cQuery +=                    " AND SC9.D_E_L_E_T_ = ' ')"
	EndIf
	// Permite alterar query dos pedidos que podem ser integrados com o CPL
	If lOSCP6QRY
		cRetPE := ExecBlock("OSCP6QRY",.F.,.F.)
		If(ValType(cRetPE)=="C")
			cQuery += cRetPE
		EndIf
	EndIf
	cQuery += " GROUP BY SC5.C5_FILIAL,"
	cQuery +=       " SC5.C5_NUM,"
	cQuery +=       " SC5.C5_TIPO,"
	cQuery +=       " SC5.C5_LIBEROK,"
	cQuery +=       " SC5.C5_NOTA,"
	cQuery +=       " SC5.C5_BLQ,"
	cQuery +=       " SC5.C5_CLIENTE,"
	cQuery +=       " SC5.C5_LOJACLI,"
	cQuery +=       " SC5.C5_FECENT,"
	cQuery +=       " SC5.C5_REDESP,"	
	cQuery +=       " SA4.A4_NREDUZ,"
	cQuery +=       " SA2.A2_NOME,"
	cQuery +=       " SA1.A1_NOME,"
	cQuery +=       " SA2.A2_NREDUZ,"
	cQuery +=       " SA1.A1_NREDUZ,"
	cQuery +=       " SA2.A2_CGC,"
	cQuery +=       " SA1.A1_CGC,"
	cQuery +=       " SA2.A2_INSCR,"
	cQuery +=       " SA1.A1_INSCR,"
	cQuery +=       " SA2.A2_MUN,"
	cQuery +=       " SA1.A1_MUN,"
	cQuery +=       " SA2.A2_EST,"
	cQuery +=       " SA1.A1_EST,"
	cQuery +=       " SA4.A4_MUN,"
	cQuery +=       " SA4.A4_EST,"
	cQuery +=       " SC5.R_E_C_N_O_"
	OsLogCPL("OMSXCPL6 -> QryPedido -> Conteúdo de cQuery: " + cValToChar(Trim(cQuery)),"INFO")
Return cQuery
/*/{Protheus.doc} QryItens
Monta query dos itens dos pedidos
@author amanda.vieria
@since 16/10/2018
@version 1.0
/*/
Static Function QryItens()
Local cQuery := ""
Local lQtdLib:= (SuperGetMv("MV_CPLPELB",.F.,"2") == "2") //Indica se permite quantidades não liberadas

	If lQtdLib
		OsLogCPL("OMSXCPL6 -> QryItens -> Conteúdo de lQtdLib: TRUE.","INFO")
	Else
		OsLogCPL("OMSXCPL6 -> QryItens -> Conteúdo de lQtdLib: FALSE.","INFO")
	EndIf

	cQuery := " SELECT SC6.C6_FILIAL,"
	cQuery +=        " SC6.C6_NUM,"
	cQuery +=        " SC6.C6_ITEM,"
	cQuery +=        " SC6.C6_PRODUTO,"
	cQuery +=        " SC6.C6_CLI,"
	cQuery +=        " SC6.C6_LOJA,"
	If lQtdLib
		//Se saldo da integração maior que a quantidade a integrar, então mantêm a quantidade a integrar
		//Se saldo da integração menor que a quantidade a integrar, então integra apenas a quantidade do saldo
		cQuery += " CASE WHEN (SUM(SLD.C9_QTDLIB) - SUM(SLD.C6_QTDINT)) > SC9.C9_QTDLIB THEN SC9.C9_QTDLIB ELSE (SUM(SLD.C9_QTDLIB) - SUM(SLD.C6_QTDINT)) END C6_QTDVEN, "
		cQuery += " CASE WHEN (SUM(SLD.C9_QTDLIB) - SUM(SLD.C6_QTDINT)) > SC9.C9_QTDLIB THEN SC9.C9_QTDLIB ELSE (SUM(SLD.C9_QTDLIB) - SUM(SLD.C6_QTDINT)) END C6_QTDINT "
	Else
		cQuery +=    " (SC6.C6_QTDVEN - SUM( CASE WHEN SLD.C6_QTDINT IS NULL THEN 0 ELSE SLD.C6_QTDINT END )) C6_QTDVEN,"
		cQuery +=    " (SC6.C6_QTDVEN - SUM( CASE WHEN SLD.C6_QTDINT IS NULL THEN 0 ELSE SLD.C6_QTDINT END )) C6_QTDINT "
	EndIf
	cQuery +=   " FROM "+oTempTab:GetRealName()+" TMP"
	cQuery +=  " INNER JOIN "+RetSqlName('SC6')+" SC6"
	cQuery +=     " ON SC6.C6_FILIAL  = TMP.TMP_FILIAL"
	cQuery +=    " AND SC6.C6_NUM     = TMP.TMP_PEDIDO"
	If !lQtdLib
		cQuery += " AND (TMP.TMP_FECENT <> ' ' OR SC6.C6_ENTREG  BETWEEN '" + DtoS(MV_PAR13) + "' AND '" + DtoS(MV_PAR14) + "')"
	EndIf
	cQuery +=    " AND SC6.D_E_L_E_T_ = ' '"
	If lQtdLib
		cQuery +=  " INNER JOIN ("
	Else
		cQuery +=  " LEFT JOIN ("
	EndIf
	cQuery +=              " SELECT 0 C9_QTDLIB,"
	cQuery +=                     " SUM(DK3.DK3_QTDINT) C6_QTDINT,"
	cQuery +=                     " DK3.DK3_FILIAL SLD_FILIAL,"
	cQuery +=                     " DK3.DK3_PEDIDO SLD_PEDIDO,"
	cQuery +=                     " DK3.DK3_ITEMPE SLD_ITEM"
	cQuery +=                " FROM "+oTempTab:GetRealName()+" TMP"
	cQuery +=                " LEFT JOIN "+RetSqlName('DK3')+" DK3"
	cQuery +=                  " ON DK3.DK3_FILIAL = TMP.TMP_FILIAL"
	cQuery +=                 " AND DK3.DK3_PEDIDO = TMP.TMP_PEDIDO"
	cQuery +=                 " AND DK3.DK3_STATUS IN ('1','3')" //Integrado ou Cancelado Parcial
	cQuery +=                 " AND DK3.D_E_L_E_T_ = ' '" 
	cQuery +=               " WHERE TMP.D_E_L_E_T_ = ' '"
	cQuery +=                " GROUP BY DK3.DK3_FILIAL,"
	cQuery +=                         " DK3.DK3_PEDIDO,"
	cQuery +=                         " DK3.DK3_ITEMPE"
	cQuery +=                " UNION ALL"
	cQuery +=               " SELECT SUM(SC9.C9_QTDLIB) C9_QTDLIB,"
	cQuery +=                      " 0 C6_QTDINT,"
	cQuery +=                      " SC9.C9_FILIAL SLD_FILIAL,"
	cQuery +=                      " SC9.C9_PEDIDO SLD_PEDIDO,"
	cQuery +=                      " SC9.C9_ITEM SLD_ITEM"
	cQuery +=                 " FROM "+oTempTab:GetRealName()+" TMP"
	cQuery +=                 " LEFT JOIN "+RetSqlName('SC9')+" SC9"
	cQuery +=                   " ON SC9.C9_FILIAL = TMP.TMP_FILIAL"
	cQuery +=                  " AND SC9.C9_PEDIDO = TMP.TMP_PEDIDO"
	cQuery +=                  " AND SC9.C9_BLEST   = ' '"
	cQuery +=                  " AND SC9.C9_BLCRED  = ' '"
	cQuery +=                  " AND SC9.D_E_L_E_T_ = ' '"
	cQuery +=                " WHERE TMP.D_E_L_E_T_ = ' '"
	cQuery +=                " GROUP BY SC9.C9_FILIAL,"
	cQuery +=                         " SC9.C9_PEDIDO,"
	cQuery +=                         " SC9.C9_ITEM"
	cQuery +=                " UNION ALL"
	//Busca-se o saldo da SD2 por conta do parâmetro MV_DEL_PVL que pode provocar a exclusão de SC9 liberadas
	cQuery +=               " SELECT SUM(SD2.D2_QUANT) C9_QTDLIB,"
	cQuery +=                      " 0 C6_QTDINT,"
	cQuery +=                      " SD2.D2_FILIAL SLD_FILIAL,"
	cQuery +=                      " SD2.D2_PEDIDO SLD_PEDIDO,"
	cQuery +=                      " SD2.D2_ITEMPV SLD_ITEM"
	cQuery +=                 " FROM "+oTempTab:GetRealName()+" TMP"
	cQuery +=                 " LEFT JOIN "+RetSqlName('SD2')+" SD2"
	cQuery +=                   " ON SD2.D2_FILIAL = TMP.TMP_FILIAL"
	cQuery +=                  " AND SD2.D2_PEDIDO = TMP.TMP_PEDIDO"
	cQuery +=                  " AND SD2.D_E_L_E_T_ = ' '"
	cQuery +=                " WHERE TMP.D_E_L_E_T_ = ' '"
	cQuery +=                " GROUP BY SD2.D2_FILIAL,"
	cQuery +=                         " SD2.D2_PEDIDO,"
	cQuery +=                         " SD2.D2_ITEMPV) SLD"
	cQuery +=     " ON SLD.SLD_FILIAL = SC6.C6_FILIAL"
	cQuery +=    " AND SLD.SLD_PEDIDO = SC6.C6_NUM"
	cQuery +=    " AND SLD.SLD_ITEM   = SC6.C6_ITEM"
	If lQtdLib
		cQuery +=  " INNER JOIN (SELECT SUM(SC9.C9_QTDLIB) C9_QTDLIB,"
		cQuery +=                     " SC9.C9_FILIAL,"
		cQuery +=                     " SC9.C9_PEDIDO,"
		cQuery +=                     " SC9.C9_ITEM"
		cQuery +=                " FROM "+oTempTab:GetRealName()+" TMP"
		cQuery +=               " INNER JOIN "+RetSqlName('SC9')+" SC9"
		cQuery +=                  " ON SC9.C9_FILIAL  = TMP.TMP_FILIAL"
		cQuery +=                 " AND SC9.C9_PEDIDO  = TMP.TMP_PEDIDO"
		cQuery +=                 " AND SC9.C9_CARGA   = ' '"		
		cQuery +=                 " AND SC9.C9_BLEST   = ' '"  
		cQuery +=                 " AND SC9.C9_BLCRED  = ' '" 
		cQuery +=                 " AND SC9.C9_NFISCAL = ' '"
		cQuery +=                 " AND SC9.C9_DATALIB BETWEEN '" + dToS(MV_PAR07) + "' AND '" + dToS(MV_PAR08) + "'"
		cQuery +=                 " AND (TMP.TMP_FECENT <> ' ' OR SC9.C9_DATENT  BETWEEN '" + DtoS(MV_PAR13) + "' AND '" + DtoS(MV_PAR14) + "')"
		cQuery +=                 " AND SC9.D_E_L_E_T_ = ' '"
		cQuery +=               " WHERE TMP.D_E_L_E_T_ = ' '"
		cQuery +=               " GROUP BY SC9.C9_FILIAL,"
		cQuery +=                        " SC9.C9_PEDIDO,"
		cQuery +=                        " SC9.C9_ITEM) SC9"
		cQuery +=     " ON SC9.C9_FILIAL = SC6.C6_FILIAL"
		cQuery +=    " AND SC9.C9_PEDIDO = SC6.C6_NUM"
		cQuery +=    " AND SC9.C9_ITEM   = SC6.C6_ITEM"
	EndIf
	cQuery +=  " WHERE TMP.D_E_L_E_T_ = ' '"
	cQuery +=  " GROUP BY SC6.C6_FILIAL,"
	cQuery +=          " SC6.C6_NUM,"
	cQuery +=          " SC6.C6_ITEM,"
	cQuery +=          " SC6.C6_PRODUTO,"
	cQuery +=          " SC6.C6_CLI,"
	cQuery +=          " SC6.C6_LOJA,"
	cQuery +=          " SC6.C6_QTDVEN"
	If lQtdLib
		cQuery +=          " ,SC9.C9_QTDLIB"
	EndIf
	OsLogCPL("OMSXCPL6 -> QryItens -> Conteúdo de cQuery: " + cValToChar(Trim(cQuery)),"INFO")
Return cQuery

/*/{Protheus.doc} Cpl6AltQtd
Função responsável por alterar a quantidade para a integração
@author amanda.vieira
@since 16/10/2018
@version 1.0
/*/
Static Function Cpl6AltQtd()
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasQry := ""
	SC5->(DbGoTo((cAliasTMP)->TMP_RECSC5))
	If !Empty(SC5->C5_NOTA) .Or. (SC5->C5_LIBEROK == 'E' .And. Empty(SC5->C5_BLQ))
		MsgAlert(STR0051)  // Pedidos já faturados não são válidos para envio.
		lRet := .F.
	Else
		OMSObjTemp(oTempAux)
		FWExecView(STR0047,"OMSXCPL6A", MODEL_OPERATION_INSERT ,, { || .T. } ,, ) // Alteração Quantidade Integração
		RestArea(aAreaAnt)
	EndIf
Return lRet
/*/{Protheus.doc} Cpl6QtdInt
Função responsável por retornar a quantidade integrada do item do pedido
@author amanda.vieira
@since 16/10/2018
@version 1.0
/*/
Function Cpl6QtdInt(cFilPed,cPedido,cItem,cProduto)
Local nQtdInt   := 0
Local cQuery    := ""
Local cAliasDK3 := ""
Local aTamSx3   := TamSX3("C6_QTDVEN")
	//Suavização
	If !TableInDic('DK3')
		Return 0
	EndIf
	cQuery := " SELECT SUM(DK3.DK3_QTDINT) DK3_QTDINT"
	cQuery +=   " FROM "+RetSqlName('DK3')+" DK3"
	cQuery +=  " WHERE DK3.DK3_FILIAL = '"+cFilPed+"'"
	cQuery +=    " AND DK3.DK3_PEDIDO = '"+cPedido+"'"
	If !Empty(cItem)
		cQuery +=    " AND DK3.DK3_ITEMPE = '"+cItem+"'"
	EndIf
	IF !Empty(cProduto)
		cQuery +=    " AND DK3.DK3_PRODUT = '"+cProduto+"'"
	EndIf
	cQuery +=    " AND DK3.DK3_STATUS IN ('1','3')" //Integrado ou Cancelado Parcial
	cQuery +=    " AND DK3.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	OsLogCPL("OMSXCPL6 -> Cpl6QtdInt -> Pedido ("+cValToChar(Trim(cFilPed))+"-"+cValToChar(Trim(cPedido))+"). Conteúdo de cQuery: " + cValToChar(Trim(cQuery)),"INFO")
	cAliasDK3 := GetNextAlias()
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasDK3, .F., .T.)
    TCSetField(cAliasDK3,'DK3_QTDINT','N',aTamSx3[1],aTamSx3[2])
	If (cAliasDK3)->(!EoF())
		nQtdInt := (cAliasDK3)->DK3_QTDINT
		OsLogCPL("OMSXCPL6 -> Cpl6QtdInt -> Conteúdo de nQtdInt 1: " + cValToChar(nQtdInt),"INFO")
	EndIf
	(cAliasDK3)->(DbCloseArea())
	OsLogCPL("OMSXCPL6 -> Cpl6QtdInt -> Conteúdo de nQtdInt 2: " + cValToChar(nQtdInt),"INFO")
Return nQtdInt
/*/{Protheus.doc} Cpl6AltQtd
Função responsável por retornar a próxima sequência de integração
@author amanda.vieira
@since 16/10/2018
@version 1.0
/*/
Static Function ProxSeqInt(cFilPed,cPedido)
Local cSeqInt   := SOMA1(Replicate('0',TamSX3("DK3_SEQUEN")[1]))
Local cAliasDK3 := GetNextAlias()
Local cQuery    := ""
	cQuery := " SELECT MAX(DK3_SEQUEN) DK3_SEQUEN "
	cQuery +=   " FROM "+RetSqlName('DK3')+" DK3"
	cQuery +=  " WHERE DK3.DK3_FILIAL = '"+cFilPed+"'"
	cQuery +=    " AND DK3.DK3_PEDIDO = '"+cPedido+"'"
	cQuery +=    " AND DK3.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	OsLogCPL("OMSXCPL6 -> ProxSeqInt -> Pedido ("+cValToChar(Trim(cFilPed))+"-"+cValToChar(Trim(cPedido))+"). Conteúdo de cQuery: " + cValToChar(Trim(cQuery)),"INFO")
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasDK3, .F., .T.)
	If (cAliasDK3)->(!EoF())
		cSeqInt := SOMA1((cAliasDK3)->DK3_SEQUEN)
	EndIf
	(cAliasDK3)->(DbCloseArea())
	OsLogCPL("OMSXCPL6 -> ProxSeqInt -> Conteudo de cSeqInt: " + cValToChar(Trim(cSeqInt)),"INFO")
Return cSeqInt
/*/{Protheus.doc} Cpl6VldEnv
Função responsável por revalidar a quantidade integrada do envio
@author amanda.vieira
@since 16/10/2018
@version 1.0
/*/
Static Function Cpl6VldEnv()
Local lRet      := .T.
Local lQtdLib   := (SuperGetMv("MV_CPLPELB",.F.,"2") == "2") //Indica se permite quantidades não liberadas
Local lTotalLib := MV_PAR22 == 1
Local nSaldo    := 0
Local cAliasSC6 := ""
Local cQuery    := ""
Local aTamSx3   := TamSX3("C6_QTDVEN")
Local oData     := Nil
	//Busca itens do pedido na tabela temporária auxiliar
	cQuery := " SELECT SC6.C6_FILIAL,"
	cQuery +=        " SC6.C6_NUM,"
	cQuery +=        " SC6.C6_ITEM,"
	cQuery +=        " SC6.C6_PRODUTO,"
	cQuery +=        " SC6.C6_QTDINT"
	cQuery +=   " FROM "+oTempAux:GetRealName()+" SC6"
	cQuery +=  " WHERE SC6.C6_FILIAL = '"+SC5->C5_FILIAL+"'"
	cQuery +=    " AND SC6.C6_NUM    = '"+SC5->C5_NUM+"'"
	cQuery +=    " AND SC6.C6_QTDINT <> 0"
	cQuery +=    " AND SC6.D_E_L_E_T_ = ' '"
	OsLogCPL("OMSXCPL6 -> Cpl6VldEnv -> Pedido ("+cValToChar(Trim(SC5->C5_FILIAL))+"-"+cValToChar(Trim(SC5->C5_NUM))+"). Conteúdo de cQuery: "+cValToChar(Trim(cQuery)),"INFO")
	cAliasSC6 := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSC6, .F., .T.)
	TCSetField(cAliasSC6,'C6_QTDINT','N',aTamSx3[1],aTamSx3[2])
	While (cAliasSC6)->(!EoF()) .And. lRet
		nSaldo := Cpl6SldPed(lQtdLib,lTotalLib,(cAliasSC6)->C6_FILIAL,(cAliasSC6)->C6_NUM,(cAliasSC6)->C6_ITEM,(cAliasSC6)->C6_PRODUTO,MV_PAR07,MV_PAR08,MV_PAR13,MV_PAR14)
		OsLogCPL("OMSXCPL6 -> Cpl6VldEnv -> Conteúdo de nSaldo: "+cValToChar(nSaldo),"INFO")
		OsLogCPL("OMSXCPL6 -> Cpl6VldEnv -> Conteúdo de C6_ITEM: "+cValToChar(Trim((cAliasSC6)->C6_ITEM)),"INFO")
		OsLogCPL("OMSXCPL6 -> Cpl6VldEnv -> Conteúdo de C6_PRODUTO: "+cValToChar(Trim((cAliasSC6)->C6_PRODUTO)),"INFO")
		OsLogCPL("OMSXCPL6 -> Cpl6VldEnv -> Conteúdo de C6_QTDINT: "+cValToChar((cAliasSC6)->C6_QTDINT),"INFO")
		If (cAliasSC6)->C6_QTDINT > nSaldo
			lRet := .F.
		EndIf
		(cAliasSC6)->(DbSkip())
	EndDo
	(cAliasSC6)->(DbCloseArea())
	//Grava mensagem de erro na tabela de registro de falha
	If !lRet
		cMsg := STR0048 //O pedido não foi enviado porque a quantidade para a integração de um dos itens não está mais disponível. Isso pode ocorrer por conta de alguma alteração no pedido de venda.
		OsLogCPL("OMSXCPL6 -> Cpl6VldEnv -> Conteúdo de cMsg: "+cValToChar(Trim(cMsg)),"INFO")
		If !IsBlind()
			cMsg += STR0049 // Atualize a tela e tente enviar novamente.
		EndIf
		oData := OMSXCPL3CLS():New()
		oData:lDjw := .T.
		oData:ACAO := "1"
		If IsBlind()
			oData:USRREG := "ENVBATCH POR JOB"
		EndIf
		oData:TABELA := "SC5"
		oData:CHAVE  := SC5->(C5_FILIAL+C5_NUM)
		oData:RECTAB := SC5->(RecNo())
		oData:MSGREG := cMsg
		oData:SITENV := "2"
		OMSXCPL3GRV(oData)
		FreeObj(oData)
	EndIf
Return lRet
/*/{Protheus.doc} ExistQtdAlt
Função responsável por verificar se existem pedidos que tiveram a quantidade de integração alterada
@author amanda.vieira
@since 16/10/2018
@version 1.0
/*/
Static Function ExistQtdAlt()
Local lRet       := .F.
Local cAliasTemp := GetNextAlias()
Local cQuery     := ""
	cQuery := " SELECT C6_NUM"
	cQuery +=   " FROM "+oTempAux:GetRealName()
	cQuery +=  " WHERE C6_QTDPED <> C6_QTDINT"
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)
	If (cAliasTemp)->(!EoF())
		lRet := .T.
	EndIf
	(cAliasTemp)->(DbCloseArea())
Return lRet

/*/{Protheus.doc} Cpl6CanDK3
Responsável por desatualizar o movimento no cockpit logístico,
de todos os movimentos visiveis e marcados na grid usando como base o Status da tabela DK3.
@author murilo.brandao
@since 16/08/2022
@version 1.0
/*/
Static Function Cpl6CanDK3(lAutoma)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasQry := ""
Local lRet      := .F.
Default lAutoma   := .F.

	OsLogCPL("OMSXCPL6 -> Cpl6CanDK3 -> "+Replicate("-", 100),"INFO")
	OsLogCPL("OMSXCPL6 -> Cpl6CanDK3 -> INICIO DE DESATUALIZAÇÃO DE PEDIDO","INFO")
	OsLogCPL("OMSXCPL6 -> Cpl6CanDK3 -> "+Replicate("-", 100),"INFO")

	If lAutoma
		(cAliasTMP)->(DbGoTop())
	EndIf

	cQuery := "SELECT DK3.DK3_PEDIDO"
	cQuery +=  " FROM " + RetSqlName("DK3") + " DK3 "
	cQuery += " WHERE DK3.DK3_FILIAL  = '"+(cAliasTMP)->TMP_FILIAL+"'"
	cQuery +=   " AND DK3.DK3_PEDIDO     = '"+(cAliasTMP)->TMP_PEDIDO+"'"
	cQuery +=   " AND DK3.DK3_STATUS IN ('1','3')" // Integrado ou Integrado Parcial
	cQuery +=   " AND DK3.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	OsLogCPL("OMSXCPL6 -> Cpl6CanDK3 -> Pedido ("+cValToChar(Trim((cAliasTMP)->TMP_FILIAL))+"-"+cValToChar(Trim((cAliasTMP)->TMP_PEDIDO))+"). Conteúdo de cQuery: " + cValToChar(Trim(cQuery)),"INFO")
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	If (cAliasQry)->(EoF()) .Or. (cAliasTMP)->TMP_SITPED = '2'
		MsgAlert(STR0060) // O registro posicionado não possuí itens válidos para desatualização.
		OsLogCPL("OMSXCPL6 -> Cpl6CanDK3 -> " + cValToChar(Trim(STR0060)),"INFO") 
	Else
		SC5->(DbSetOrder(1))
		SC5->(DbSeek((cAliasTMP)->TMP_FILIAL+(cAliasTMP)->TMP_PEDIDO))
		OMSCPL6BAT(oTempTab:oStruct:GetAlias(),.F.)
		If !lAutoma
			FWExecView(STR0061,"OMSXCPL6B", MODEL_OPERATION_UPDATE ,, { || .T. } ,, ) // Cancelar Integração do Pedido
			RefreshBrw()
		EndIf
		OsLogCPL("OMSXCPL6 -> Cpl6CanDK3 -> " + cValToChar(Trim(STR0061)),"INFO") 
		lRet := .T.
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet

/*/{Protheus.doc} Cpl6CseDK3
Função responsável por realizar o estorno de todos os pedidos marcados 
considerando o Status da tabela DK3.
@author murilo.brandao
@since 16/08/2022
@version 1.0
/*/
Static Function Cpl6CseDK3(lAutoma)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasQry := ""
Local cMsg      := ""
Local lRet      := .F.
Default lAutoma := .F.

	OsLogCPL("OMSXCPL6 -> Cpl6CseDK3 -> "+Replicate("-", 100),"INFO")
	OsLogCPL("OMSXCPL6 -> Cpl6CseDK3 -> INICIO DE ESTORNO DE PEDIDO","INFO")
	OsLogCPL("OMSXCPL6 -> Cpl6CseDK3 -> "+Replicate("-", 100),"INFO")

	cQuery := "SELECT TMP.TMP_FILIAL,"
	cQuery +=       " TMP.TMP_RECSC5"
	cQuery +=  " FROM "+ oTempTab:GetRealName()+" TMP"
	cQuery += " INNER JOIN "+RetSqlName('DK3')+" DK3"
	cQuery +=    " ON DK3.DK3_FILIAL = TMP.TMP_FILIAL"
	cQuery +=   " AND DK3.DK3_PEDIDO    = TMP.TMP_PEDIDO"
	cQuery +=   " AND DK3.DK3_STATUS IN ('1','3')" // Integrado ou Integrado Parcial
	cQuery +=   " AND DK3.D_E_L_E_T_ = ' '"
	If !lAutoma
		cQuery += " WHERE TMP.TMP_MARK   = '"+oBrowse:Mark()+"'"
	EndIf
	cQuery +=   " AND TMP.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY TMP.TMP_FILIAL,"
	cQuery +=          " TMP.TMP_RECSC5"
	cQuery += " ORDER BY TMP.TMP_FILIAL,"
	cQuery +=          " TMP.TMP_RECSC5"
	cQuery := ChangeQuery(cQuery)
	OsLogCPL("OMSXCPL6 -> Cpl6CseDK3 -> Conteúdo de cQuery: " + cValToChar(Trim(cQuery)),"INFO")
	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	If (cAliasQry)->(EoF()) .And. !lAutoma
		MsgAlert(STR0066) // Nenhum registro válido selecionado para o estorno da integração.
		OsLogCPL("OMSXCPL6 -> Cpl6CseDK3 -> " + cValToChar(Trim(STR0066)),"INFO")
	Else
		lRet := .T.
		If !lAutoma .And. OmsQuestion(STR0067,"OMSXCPL6") // Confirma o estorno de todas as sequências de integração dos pedidos selecionados?
			OsLogCPL("OMSXCPL6 -> Cpl6CseDK3 -> Inicio do estorno da integração." ,"INFO")
			OMSCPL6TMP(oTempTab)
			Processa({||OmsCpl6Est()})
			RefreshBrw()
		EndIf
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet
