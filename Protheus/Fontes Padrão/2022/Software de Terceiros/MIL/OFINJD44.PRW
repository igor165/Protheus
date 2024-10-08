#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'OFINJD44.ch'

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  23/03/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "2"

// Indices do grid do VQZ
#define n1VQZ_FILIAL 1
#define n1VQZ_TIPO   2
#define n1VQZ_COONUM 3
#define n1VQZ_NOMARQ 4
#define n1VQZ_DATA   5
#define n1VQZ_HORA   6
#define n1VQZ_CODIGO 7

// Indices do grid de detalhes por item VR1 e VR0
#define n2PRODUTO 1
#define n2FILORI  2
#define n2FILDES  3
#define n2ORDREF  4
#define n2ORIGEM  5
#define n2PEDFAB  6
#define n2QUANT   7
#define n2ACAO    8
#define n2STATUS  9

/*/{Protheus.doc} OFINJD44 "Consulta de Importa��es JDPRISM"

	Pontos de entrada:
		N/A
	Parametros:
		N/A

	@author Vinicius Gati
	@since  23/03/2017
/*/
Function OFINJD44()
	Private oArrHlp    := DMS_ArrayHelper():New()
	Private oSqlHlp    := DMS_SqlHelper():New()
	Private oDpm       := DMS_DPM():New()
	Private aSizeAut   := MsAdvSize(.t.)
	Private aVQZHeader := {;
		'VQZ_FILIAL', 'VQZ_TIPO', 'VQZ_COONUM', 'VQZ_NOMARQ', 'VQZ_DATA', 'VQZ_HORA', 'VQZ_CODIGO';
	}
	Private nOpc       := 1
	Private o1GetDados := Nil
	Private o2GetDados := Nil
	Private oDlg
	Private oProcImpXML
	Private oObjOrder  := DMS_DataContainer():New({;
		{'A', STR0023 /*"Inclus�o"*/ },;
		{'C', STR0024 /*"Altera��o"*/},;
		{'D', STR0025 /*"Remo��o"*/  } ;
	})
	Private aFilis     := oDpm:GetFiliais()
	Private cSqlFil    := " C7_FILIAL IN ('" + oArrHlp:Join(oArrHlp:Map(aFilis, {|aEl| aEl[1] }), "','") + "') "

	dbSelectArea('VQZ')
	dbSelectArea('VR0')
	dbSelectArea('VR1')

	oDlg := FS_UILoad()

	ACTIVATE MSDIALOG oDlg
Return NIL

/*/{Protheus.doc} FS_UILoad
	Cria tela

	@author Vinicius Gati
	@since  23/03/2017
/*/
Static Function FS_UILoad()
	Local oInterfHelper := DMS_InterfaceHelper():New()
	Local oSizePrinc, oSizeFiltro
	Local nIdx := 1
	Local oCampo1 := oCampo2 := oCampo3 := oCampo4 := oCampo5 := oCampo6 := oCampo7 := Nil



	cBox := oArrHlp:Map(aFilis, {|aEl| aEl[1]+"="+aEl[1] })
	cBox := oArrHlp:Join(cBox, ';')

	// nOpc (1 - pesquisa; 2 - visualiza��o; 3 - inclus�o; 4 - altera��o; 5 - exclus�o)
	oInterfHelper:nOpc := nOpc

	// divis�o da tela
	aDivTela := { ;
		{ "CABEC"    , 110, 070 , .T. , .F. } ,; // Cabecalho
		{ "MIDDLE"   , 100, 150 , .T. , .F. } ,; // Listbox
		{ "BOTTOM"   , 100, 100 , .T. , .T. }  ; // Listbox
	}

	// CABEC ser� dividido conforme
	aDivTela2 := { ;
		{ "ESQUERDA" , 400, 010 , .T. , .t. } ,; // mGet
		{ "DIREITA"  , 080, 050 , .F. , .t. }  ; // Botoes
	}

	// Criando a janela
	oSizePrinc := oInterfHelper:CreateDefSize(.f., aDivTela)
	oSizePrinc:Process()
	oInterfHelper:SetDefSize(oSizePrinc)
	oDlg := oInterfHelper:CreateDialog(STR0001) // "Consulta de importa��es JDPRISM"

	// FAzendo a divis�o do filtro no cabecalho
	oSizeFiltro := oInterfHelper:CreateDefSize(.f., aDivTela2, oSizePrinc:GetNextCallArea("CABEC"))
	oSizeFiltro:lLateral := .t.	// Calcula em colunas
	oSizeFiltro:Process()

	oInterfHelper:setDialog(oDlg)

	oInterfHelper:SetDefSize(oSizeFiltro, "DIREITA")

	TButton():New(;
		oSizeFiltro:GetDimension("DIREITA","LININI") + 00, ;
		oSizeFiltro:GetDimension("DIREITA","COLINI")    , ;
		STR0002 /*"Filtrar"*/, ;
		oDlg , { || o1GetDados:aArray := OFINJD4401_FiltraVQZ(), OFINJD4405_AtualizaTela()  }, ;
		oSizeFiltro:GetDimension("DIREITA","XSIZE") ;
		, 010,,,.F.,.T.,.F.,,.F.,,,.F. )

	TButton():New(;
		oSizeFiltro:GetDimension("DIREITA","LININI") + 11, ;
		oSizeFiltro:GetDimension("DIREITA","COLINI") , ;
		STR0003 /*"Reenviar Coord."*/, ;
		oDlg , { || OFINJD4407_ReenviaCoord() }, ;
		oSizeFiltro:GetDimension("DIREITA","XSIZE") ;
		, 010,,,.F.,.T.,.F.,,.F.,,,.F. )

	TButton():New(;
		oSizeFiltro:GetDimension("DIREITA","LININI") + 22, ;
		oSizeFiltro:GetDimension("DIREITA","COLINI") , ;
		STR0004 /*"Alterar Ped. F�brica"*/, ;
		oDlg , { || OFINJD4408_AlteraPedido() }, ;
		oSizeFiltro:GetDimension("DIREITA","XSIZE") ;
		, 010,,,.F.,.T.,.F.,,.F.,,,.F. )

	TButton():New(;
		oSizeFiltro:GetDimension("DIREITA","LININI") + 33, ;
		oSizeFiltro:GetDimension("DIREITA","COLINI") , ;
		STR0005 /*"Detalhes"*/, ;
		oDlg , { || OFINJD4409_VerDetalhes() }, ;
		oSizeFiltro:GetDimension("DIREITA","XSIZE") ;
		, 010,,,.F.,.T.,.F.,,.F.,,,.F. )

	TButton():New(;
		oSizeFiltro:GetDimension("DIREITA","LININI") + 44, ;
		oSizeFiltro:GetDimension("DIREITA","COLINI") , ;
		STR0038 /*"Atu. Status Ped"*/, ;
		oDlg , { || OFINJD4413_AtualizaStatusPedido() }, ;
		oSizeFiltro:GetDimension("DIREITA","XSIZE") ;
		, 010,,,.F.,.T.,.F.,,.F.,,,.F. )

	TButton():New(;
		oSizeFiltro:GetDimension("DIREITA","LININI") + 55, ;
		oSizeFiltro:GetDimension("DIREITA","COLINI") , ;
		STR0006 /*"Sair"*/, ;
		oDlg , { || oDlg:End() }, ;
		oSizeFiltro:GetDimension("DIREITA","XSIZE") ;
		, 010,,,.F.,.T.,.F.,,.F.,,,.F. )

	// Parte de cima da tela
	oInterfHelper:SetDefSize(oSizeFiltro, "ESQUERDA")

	oInterfHelper:SetOwnerPvt("OFINJD44")
	oInterfHelper:SetPrefixo("VQZ")
	oInterfHelper:AddMGet("VV1_DATPED", {;
		{'NOMECAMPO', 'VQZ_DATINI'  },;
		{'X3_TITULO', STR0043} ; // Data Inicial
	})
	oInterfHelper:AddMGet("VV1_DATPED", {;
		{'NOMECAMPO', 'VQZ_DATFIM'},;
		{'X3_TITULO', STR0044} ; // Data Final
	})
	oInterfHelper:AddMGet("VQZ_FILIAL", {;
		{'X3_CBOX'   , cBox           },;
		{'X3_TAMANHO', FWSizeFilial() } ;
	})
	oInterfHelper:AddMGet("VB8_PRODUT", {;
		{'NOMECAMPO', 'VQZ_PRODUT'},;
		{'X3_VALID' , ''},;
		{'X3_F3'    , 'SB1'} ;
	})
	oInterfHelper:AddMGet("VQZ_TIPO")
	oInterfHelper:AddMGet("VQZ_COONUM")

	oInterfHelper:AddMGet("VR0_ORDREF", {;
		{'NOMECAMPO', 'VQZ_ORDREF'},;
		{'X3_TITULO', STR0046},; // Pedido Ref.
		{'X3_VALID' , ''};
	})


	oInterfHelper:CreateMSMGet(.F.)
	M->VQZ_DATINI := ddatabase
	M->VQZ_DATFIM := ddatabase

	oInterfHelper:Clean()
	oInterfHelper:nOpc := nOpc

	// Parte do meio
	oInterfHelper:SetDefSize(oSizePrinc, "MIDDLE")
	oInterfHelper:addColLBox({{'X3', 'VQZ_FILIAL'}})
	oInterfHelper:addColLBox({{'X3', 'VQZ_TIPO'}, {'TAMANHO', 15} })
	oInterfHelper:addColLBox({{'X3', 'VQZ_COONUM'}})
	oInterfHelper:addColLBox({{'X3', 'VQZ_NOMARQ'}})
	oInterfHelper:AddColLBox({{'X3', 'VQZ_DATA'},;
		{'CODEBLOCK', "{ || STOD( NOME_OBJETO:aArray[ NOME_OBJETO:nAt, POSICAO_COLUNA ] ) }"};
	})
	oInterfHelper:addColLBox({{'X3', 'VQZ_HORA'}})
	oInterfHelper:addColLBox({{'X3', 'VQZ_CODIGO'}})

	o1GetDados := oInterfHelper:CreateLBox("o1GetDados")
	o1GetDados:bChange := {||;
		o2GetDados:SetArray( OFINJD4404_FiltrarDetalhes() ),;
		o2GetDados:Refresh() ;
	}
	o1GetDados:SetArray( OFINJD4401_FiltraVQZ() )

	// Parte de baixo
	oInterfHelper:Clean()

	oInterfHelper:SetDefSize(oSizePrinc, "BOTTOM")
	oInterfHelper:AddColLBox({;
		{'CABEC' , STR0026/*'C�digo da Pe�a'*/},;
		{'TAMANHO', 60} ;
	})
	oInterfHelper:AddColLBox({;
		{'CABEC' , STR0027/*'Fil. Origem'*/ },;
		{'TAMANHO', 40} ;
	})
	oInterfHelper:AddColLBox({;
		{'CABEC' , STR0028/*'Fil. Destino'*/},;
		{'TAMANHO', 40} ;
	})
	oInterfHelper:AddColLBox({;
		{'CABEC' , STR0029/*'C�d. Ref. (Order)'*/},;
		{'TAMANHO', 60} ;
	})
	oInterfHelper:AddColLBox({;
		{'CABEC' , STR0030/*'Num. Transf./Ped.'*/},;
		{'TAMANHO', 60} ;
	})
	oInterfHelper:AddColLBox({;
		{'CABEC' , STR0031/*'Pedido JDPOINT'*/},;
		{'TAMANHO', 50} ;
	})
	oInterfHelper:AddColLBox({;
		{'CABEC' , STR0032/*'Quantidade'/*/},;
		{'PICTURE', "@E 999,999,999.99"},;
		{'TAMANHO', 35},;
		{'ALIGN'  , 'RIGHT'};
	})
	oInterfHelper:AddColLBox({;
		{'CABEC' , STR0033/*'A��o'*/},;
		{'TAMANHO', 15   } ;
	})
	oInterfHelper:AddColLBox({;
		{'CABEC' , STR0045},; //Status Pedido
		{'TAMANHO', 15   } ;
	})
	o2GetDados := oInterfHelper:CreateLBox("o2GetDados")
	o2GetDados:aArray := {{,,,,,,,,,,}}

	o1GetDados:Refresh()

	oInterfHelper:Clean()

Return oDlg

/*/{Protheus.doc} OFINJD4401_FiltraVQZ
	Traz dados da tabela VQZ, das importa��es

	@author Vinicius Gati
	@since  11/04/2017
/*/
Static Function OFINJD4401_FiltraVQZ()
	Local cQuery := cQuery2  := ""
	Local aRet     := {}
	Local aCodsVQZ := {}
	Local aCodsVR0
	Local aCodsVR1
	Local cFilFiltro := ""


	aCodsVR0 := OFINJD4417_filtraOrderTransferVQZ("VR0")
	
	//Se estiver informando c�digo de ORDER, n�o realiza a busca de TRANSFER
	If Empty(M->VQZ_ORDREF)
		aCodsVR1 := OFINJD4417_filtraOrderTransferVQZ("VR1")
		oArrHlp:Merge(aCodsVR0, aCodsVR1)
	EndIf
	aCodsVR0 := oArrHlp:Map(aCodsVR0, {|nNum| ALLTRIM(STR(nNum)) })

	cQuery2 := " SELECT " + oArrHlp:Join(aVQZHeader, ',')
	cQuery2 += "   FROM " + RetSqlName('VQZ') + " VQZ "
	cQuery2 += "  WHERE D_E_L_E_T_ = ' ' "
	If LEN(aCodsVR0) > 0
		cQuery2 += "    AND R_E_C_N_O_ IN ("+oArrHlp:Join(aCodsVR0, ",")+") "
	else
		return {{"", "", "", "", "", "", ""}}
	EndIf
	if !Empty(M->VQZ_TIPO) .AND. M->VQZ_TIPO != "A" /* A = Todos */
		cQuery2 += "   AND VQZ_TIPO   = '" + M->VQZ_TIPO   + "' "
	end
	cQuery2 += " ORDER BY VQZ_DATA DESC "
	cQuery2 := oSqlHlp:TopFunc(cQuery2, 500)

	aRet := oSqlHlp:GetSelectArray(cQuery2, LEN(aVQZHeader))
	oArrHlp:Each(aRet, {|el|;
		el[n1VQZ_DATA] := el[n1VQZ_DATA],;
		el[n1VQZ_TIPO] := X3CBOXDESC("VQZ_TIPO", el[n1VQZ_TIPO]) ;
	})
Return aRet

/*/{Protheus.doc} OFINJD4402_DetalhesTransfer
	Traz dados da tabela VR1, das importa��es

	@author Vinicius Gati
	@since  11/04/2017
/*/
Static Function OFINJD4402_DetalhesTransfer(cVQZ_FILIAL, cVQZ_CODIGO)
	Local aRet       := {}
	Local cQuery     := ""
	Local cSQLAlias  := "SQL_VR1"
	Local cBckFilial := cFilAnt
	Local aCampos    := {;
		'VR1_PRODUT', "VR1_FILORI", "VR1_FILDES","''",'VR1_NUMORC', "''",'VR1_QUANT', "''", "''";
	}

	cFilAnt := cVQZ_FILIAL

	cQuery += " SELECT " + oArrHlp:Join(aCampos, ',')
	cQuery += "   FROM " + RetSqlName('VR1') + " VR1 "
	cQuery += "  WHERE VR1_FILIAL = '"+cVQZ_FILIAL+"' "
	cQuery += "    AND VR1_CODVQZ = '"+cVQZ_CODIGO+"' "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY VR1_NUMORC, VR1_FILDES "
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLAlias, .F., .T.)

	While !(cSQLAlias)->(Eof())
		aAdd(aRet, {                                  ;
			(cSQLAlias)->(VR1_PRODUT),                ; // 01
			oDpm:GetFilial((cSQLAlias)->(VR1_FILORI)),; // 02
			oDpm:GetFilial((cSQLAlias)->(VR1_FILDES)),; // 03
			"",                                       ; // 04
			(cSQLAlias)->(VR1_NUMORC),                ; // 05
			"",                                       ; // 06
			(cSQLAlias)->(VR1_QUANT),                 ; // 07
			"",                                       ; // 08
			""                                        ; // 09
		})

		(cSQLAlias)->(dbSkip())
	EndDo

	(cSQLAlias)->(dbCloseArea())
	DbSelectArea("VR1")

	cFilAnt := cBckFilial
Return aRet

/*/{Protheus.doc} OFINJD4403_DetalhesOrder
	Traz dados da tabela VR1, das importa��es

	@author Vinicius Gati
	@since  11/04/2017
/*/
Static Function OFINJD4403_DetalhesOrder(cVQZ_FILIAL, cVQZ_CODIGO)
	Local aRet       := {}
	Local cQuery     := ""
	Local cSQLAlias  := "SQL_VR0"
	Local cBckFilial := cFilAnt
	Local aCampos    := {;
		'VR0_PRODUT',"'' as VR0_FILIAL",'VR0_FILDES','VR0_ORDREF',;
		'VR0_NUMPED', 'C7_PEDFAB','VR0_QUANT','VR0_ACAO', 'C7_STATUS';
	}

	cFilAnt := cVQZ_FILIAL

	cQuery += "     SELECT " + oArrHlp:Join(aCampos, ',')
	cQuery += "       FROM " + RetSqlName('VR0') + " VR0 "
	cQuery += "       JOIN " + RetSqlName('VQZ') + " VQZ ON "
	cQuery += "            VQZ_FILIAL = VR0_FILIAL "
	cQuery += "        AND VQZ_CODIGO = VR0_CODVQZ "
	cQuery += "        AND VQZ.D_E_L_E_T_ = ' ' "
	cQuery += "  LEFT JOIN " + RetSqlName('SC7') + " SC7 ON "
	cQuery += cSqlFil
	cQuery += "        AND C7_NUM         = VR0_NUMPED "
	cQuery += "        AND C7_PRODUTO     = VR0_PRODUT "
	cQuery += "        AND C7_DLINORI     = VR0_ORIGID "
	cQuery += "        AND SC7.D_E_L_E_T_ = ' ' "
	cQuery += "  WHERE VR0_FILIAL = '" + cVQZ_FILIAL + "' "
	cQuery += "    AND VR0_CODVQZ = '" + cVQZ_CODIGO + "' "
	cQuery += "    AND VR0.D_E_L_E_T_ = ' ' "
	cQuery += "  ORDER BY VR0_NUMPED, VR0_FILDES "
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLAlias, .F., .T.)

	While !(cSQLAlias)->(Eof())
		aAdd(aRet, {                                        ;
			(cSQLAlias)->(VR0_PRODUT),                      ; // 01
			(cSQLAlias)->(VR0_FILIAL),                      ; // 02
			oDpm:GetFilial((cSQLAlias)->(VR0_FILDES)),      ; // 03
			(cSQLAlias)->(VR0_ORDREF),                      ; // 04
			(cSQLAlias)->(VR0_NUMPED),                      ; // 05
			(cSQLAlias)->(C7_PEDFAB),                       ; // 06
			(cSQLAlias)->(VR0_QUANT),                       ; // 07
			oObjOrder:GetValue((cSQLAlias)->(VR0_ACAO), ""),; // 08
			(cSQLAlias)->(C7_STATUS)                        ; // 09
		})

		(cSQLAlias)->(dbSkip())
	EndDo

	(cSQLAlias)->(dbCloseArea())
	DbSelectArea("VR0")

	cFilAnt := cBckFilial
Return aRet

/*/{Protheus.doc} OFINJD4404_FiltrarDetalhes
	Filtra os detalhes do registro selecionado no getDados superior do VQZ

	@author Vinicius Gati
	@since  11/04/2017
/*/
Static Function OFINJD4404_FiltrarDetalhes()
	Local aRet        := {}
	Local cVQZ_FILIAL := ''
	Local cVQZ_CODIGO := ''
	Local cVQZ_TIPO   := ''

	if LEN(o1GetDados:aArray) > 0 .AND. o1GetDados:nAt <= LEN(o1GetDados:aArray) .AND. o1GetDados:nAt > 0
		cVQZ_FILIAL := o1GetDados:aArray[o1GetDados:nAt , n1VQZ_FILIAL]
		cVQZ_CODIGO := o1GetDados:aArray[o1GetDados:nAt , n1VQZ_CODIGO]
		cVQZ_TIPO   := o1GetDados:aArray[o1GetDados:nAt , n1VQZ_TIPO]

		if LEFT(cVQZ_TIPO,1) == "T"
			aRet := OFINJD4402_DetalhesTransfer(cVQZ_FILIAL, cVQZ_CODIGO)
		else			
			aRet := OFINJD4403_DetalhesOrder(cVQZ_FILIAL, cVQZ_CODIGO)
		end
	end
	If Len(aRet) == 0
		aRet := {{"", "", "", "", "", "", "", "", ""}}
	Endif
Return aRet

/*/{Protheus.doc} OFINJD4405_AtualizaTela
	Atualiza browse dos detalhes quando filtrar os dados da VQZ

	@author Vinicius Gati
	@since  11/04/2017
/*/
Static Function OFINJD4405_AtualizaTela()
	o1GetDados:nAt := 1
	o1GetDados:Refresh()
	if o1GetDados:aArray[o1GetDados:nAt][1]+o1GetDados:aArray[o1GetDados:nAt][7] != "" // Filial + Cod VQZ
		o2GetDados:aArray := OFINJD4404_FiltrarDetalhes()
	else
		o2GetDados:aArray := {{"", "", "", "", "", "", "", "", ""}}
	end
	o2GetDados:Refresh()
Return .T.

/*/{Protheus.doc} OFINJD4407_ReenviaCoord
	Limpara flag de enviado do numero de cordena��o

	@author Vinicius Gati
	@since  12/04/2017
/*/
Static Function OFINJD4407_ReenviaCoord()
	Local cCooNum := ""
	Local cUpd    := ""

	cCooNum := o1GetDados:aArray[o1GetDados:nAt, n1VQZ_COONUM]

	If Empty(cCooNum)
		MsgAlert(STR0047, STR0011) // "Aten��o" // "N�o existem dados para consulta."
		Return .F.
	Endif

	cUpd += " UPDATE " + RetSqlName('VQL')
	cUpd += "    SET VQL_DATAF = ' ', VQL_HORAF = ' ' "
	cUpd += "  WHERE VQL_AGROUP IN ('DPMXFER_DPE', 'DPMORD_DPE') "
	cUpd += "    AND VQL_DADOS  = '" + cCooNum + "' "
	cUpd += "    AND D_E_L_E_T_ = ' ' "
	if tcSqlExec(cUpd) < 0
		MSGSTOP(STR0007 /*"Erro de sql detectado: "*/ + TCSQLError())
		Return .F.
	else
		MSGINFO(STR0008 /*"N�mero de coordena��o "*/+cCooNum+STR0009 /*" ser� reenviado John Deere"*/)
	end
Return .T.

/*/{Protheus.doc} OFINJD4408_AlteraPedido
	Alterar� os SC7 do pedido gerado para que entre em padr�o com jdpoint dpm normal

	@author Vinicius Gati
	@since  12/04/2017
/*/
Static Function OFINJD4408_AlteraPedido()
	Local cDPedFab  := SPACE(TamSX3('C7_PEDFAB')[1])
	Local aRet      := {}
	Local aParamBox := {}
	Local cSel      := ""
	Local cUpd      := ""
	Local cPedFab   := ""
	Local cFilPed   := ""
	Local cTipo     := ""
	Local cFilBck   := cFilAnt

	cTipo := o1GetDados:aArray[o1GetDados:nAt, n1VQZ_TIPO]
	if LEFT(cTipo, 1) == 'T' // Transfer
		MSGSTOP(STR0017) // "N�o � poss�vel realizar esta opera��o, uma vez que o registro posicionado se trata de um TRANSFER (transfer�ncia entre filiais)."
	else
		cFilPed     := o2GetDados:aArray[o2GetDados:nAt, n2FILDES]
		cNumPed     := o2GetDados:aArray[o2GetDados:nAt, n2ORIGEM]
		cNumJDPrism := o2GetDados:aArray[o2GetDados:nAt, n2ORDREF]
		AADD(aParamBox,{1,STR0039,cNumJDPrism,"@!","","",".F.",80,.T.}) // "Pedido JdPrism"
		AADD(aParamBox,{1,STR0018,cDPedFab,"@!","","",".T.",80,.T.}) // "Pedido de F�brica"

		// Verifica se o pedido precisa ser alterado
		cSel := " SELECT COUNT(*) "
		cSel += "   FROM " + RetSqlName('SC7')
		cSel += "  WHERE C7_FILIAL  = '" + cFilPed + "' "
		cSel += "    AND C7_NUM     = '" + cNumPed + "' "
		cSel += "    AND C7_PEDFAB  = 'JDPRISM' "
		cSel += "    AND D_E_L_E_T_ = ' ' "
		lAlterado := FM_SQL(cSel) < 1 // se n�o encontrou significa que j� alterou o pedfab

		If Empty(cFilPed + cNumPed) .OR. (cFilPed + cNumPed) = ""
			MsgAlert(STR0047, STR0011) // "Aten��o!" // "N�o existem dados para consulta."
			Return .F.
		Endif

		if lAlterado
			if ! MsgYesNo(STR0010 /*'Pedido j� alterado, gostaria de continuar com a altera��o?'*/, STR0011/*'Aten��o'*/)
				Return .F.
			end
		end

		if !ParamBox(aParamBox, STR0016,@aRet,,,,,,,,.f.) //"N�mero do Pedido de F�brica"
			Return .F.
		else
			cPedFab := aRet[2]

			if OFINJD4415_VerificaExistencia(cPedFab, cNumPed) // verifica se j� foi importado manualmente
				if MsgYesNo(STR0040, STR0011/*"Aten��o"*/) // "O pedido de f�brica digitado j� existe em outro pedido, deseja adequar o mesmo ao jdprism?"
					OFINJD4416_AdequaPedido(cNumPed, cFilPed, cPedFab)
				endif
			else
				cMsg := STR0019 + chr(13) + chr(10) // "Tem certeza que deseja alterar o pedido? "
				cMsg += STR0020 + cFilPed + chr(13) + chr(10) // "Filial: "
				cMsg += STR0021 + cNumPed + chr(13) + chr(10) //"N�mero do Pedido: "
				cMsg += chr(13) + chr(10)
				cMsg += STR0022 + aRet[2] // "Para o c�digo de f�brica n�mero: "
	
				if MsgYesNo(cMsg, STR0011)
					cUpd := " UPDATE " + RetSqlName('SC7')
					cUpd += "    SET C7_PEDFAB  = '"+cPedFab+"' "
					cUpd += "  WHERE C7_FILIAL  = '"+cFilPed+"' "
					cUpd += "    AND C7_NUM     = '"+cNumPed+"' "
					cUpd += "    AND D_E_L_E_T_ = ' ' "
					if tcSqlExec(cUpd) < 0
						MSGSTOP(STR0007 /*"Erro de sql detectado: "*/ + TCSQLError())
						Return .F.
					else
						MSGINFO(STR0014 /*"Pedido: "*/ + cNumPed + STR0013 /*" da filial: "*/ + cFilPed + STR0012 /*" foi alterado com sucesso."*/, STR0011/*"Aten��o"*/)
					end
				end
			endif
		end
	end
Return .T.

/*/{Protheus.doc} OFINJD4409_VerDetalhes
	Mostra detalhes da transferencia ou pedido

	@author Vinicius Gati
	@since  12/04/2017
/*/
Static Function OFINJD4409_VerDetalhes()
	Local cTipo := ""
	Local cFil  := ""
	Local cOri  := ""
	Local cFilO := ""

	if LEN(o1GetDados:aArray) > 0 .AND. LEN(o2GetDados:aArray) > 0

		cTipo := o1GetDados:aArray[o1GetDados:nAt, n1VQZ_TIPO]
		cFil  := o1GetDados:aArray[o1GetDados:nAt, n1VQZ_FILIAL]
		cFilO := o2GetDados:aArray[o2GetDados:nAt, n2FILDES]
		cOri  := o2GetDados:aArray[o2GetDados:nAt, n2ORIGEM]

		If Empty(cFil+cFilO) .OR. Empty(cOri)
			MsgAlert(STR0015 /*"C�digo do Pedido/Transfer�ncia n�o detectado."*/, STR0011 /*"Aten��o"*/)
			return .F.
		elseif UPPER(LEFT(cTipo, 1)) == 'O'
			OFINJD4411_VisualizarPedidoCompra(cFilO, cOri)
		else
			OFINJD4412_VisualizarTransferencia(cFil, cOri)
		end

	end
Return .T.

/*/{Protheus.doc} OFINJD4410_CoverteAcao
	Descri��o melhor para a��o do DPMORD conforme documenta��o do JDPRISM Interface

	@author Vinicius Gati
	@since  12/04/2017
/*/
Static Function OFINJD4410_CoverteAcao(cValue)
	Local oObj := DMS_DataContainer():New({;
		{'A', STR0023 /*"Inclus�o"*/ },;
		{'C', STR0024 /*"Altera��o"*/},;
		{'D', STR0025 /*"Remo��o"*/  } ;
	})
Return oObj:GetValue(cValue, "")

/*/{Protheus.doc} OFINJD4411_VisualizarPedidoCompra
	Abre mata120 em visualiza��o para que o usu�rio possa verificar detalhes do pedido

	@author Vinicius Gati
	@since  12/04/2017
/*/
Static Function OFINJD4411_VisualizarPedidoCompra(cFilPed, cNumPed)
	Local aArea     := GetArea()
	Local aAreaSC7  := SC7->(GetArea())
	Local cFilBck   := cFilAnt

	cFilAnt   := cFilPed

	dbSelectArea("SC7")
	dbSeek(xFilial('SC7') + cNumPed)
	if Found()
		Mata120(1,/*aCabec*/,/*aItens*/, 2/*Visualizar*/,.T.)
	end
	RestArea(aAreaSC7)
	RestArea(aArea)
	cFilAnt := cFilBck
Return .T.

/*/{Protheus.doc} OFINJD4412_VisualizarTransferencia
	Abre tela para visualiza��o de dados da transferencia

	@author Vinicius Gati
	@since  12/04/2017
	@type   function
/*/
Static Function OFINJD4412_VisualizarTransferencia(cFilOrc, cNumOrc)
	Local aArea   := GetArea()
	Local cFilBck := cFilAnt

	cFilAnt   := cFilOrc

	dbSelectArea("VS1")
	dbSetOrder(1)
	dbSeek( xFilial('VS1') + cNumOrc)
	if Found()
		OFIOM430(.T., 2)
	end
	RestArea(aArea)
	cFilAnt := cFilBck
Return .T.

/*/{Protheus.doc} OFINJD4413_AtualizaStatusPedido
	Abre tela para visualiza��o de dados da transferencia

	@author Vinicius Gati
	@since  12/04/2017
	@type   function
/*/
Static Function OFINJD4413_AtualizaStatusPedido()
	local cFilPed := o2GetDados:aArray[o2GetDados:nAt, n2FILDES]
	local cPedFab := o2GetDados:aArray[o2GetDados:nAt, n2PEDFAB]
	local cQuery  := "" 
	local cMarca  := FMX_RETMAR(GetNewPar("MV_MIL0006","")) // 28 da VX5
	local nPos    := 1
	local cAl     := GetNextAlias()
	local cForn
	local cLoja
	local cCondicao
	Local cTipo   := ""

	If ALLTRIM(cPedFab) == "JDPRISM"
		MsgAlert(STR0034 /*"Pedido ainda n�o foi adequado ao JDPOINT, altere o n�mero do pedido de f�brica!"*/, STR0011 /*"Aten��o"*/)
		Return
	EndIf

	If Empty(cPedFab) .AND. (!Empty(cFilPed))
		MsgAlert(STR0048, STR0011) // Aten��o // "O Pedido JDPoint � obrigat�rio!"
		Return .F.
	ElseIf Empty(cPedFab)
		MsgAlert(STR0047, STR0011) // "N�o existem dados para consulta." // "Aten��o!"
		Return .F.
	Endif

	If LEN(o1GetDados:aArray) > 0 .and. LEN(o2GetDados:aArray) > 0
		cTipo := o1GetDados:aArray[o1GetDados:nAt, n1VQZ_TIPO]
		If LEFT(cTipo, 1) == 'T' // Transfer
			MSGSTOP(STR0017) // "N�o � poss�vel realizar esta opera��o, uma vez que o registro posicionado se trata de um TRANSFER (transfer�ncia entre filiais)."                                                                                                                                                                                                                                                                                                                                                                                  
		Else
			cQuery += " SELECT C7_NUM, C7_FORNECE,	C7_LOJA, C7_COND "
			cQuery += "   FROM " + RetSqlName('SC7')
			cQuery += "  WHERE C7_FILIAL = '"+xFilial('SC7')+"' "
			cQuery += "    AND C7_PEDFAB = '"+cPedFab+"' "
			cQuery += "    AND D_E_L_E_T_ = ' ' "
			cQuery := oSqlHlp:TopFunc(cQuery, 1)
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl, .F., .T. )
			If ! (cAl)->(EOF())
				cForn     := (cAl)->C7_FORNECE
				cLoja     := (cAl)->C7_LOJA
				cCondicao := (cAl)->C7_COND

				(cAl)->(DbSkip())
			EndIf
			(cAl)->(dbCloseArea())

			lImpXml := .t.
			cFilAnt := cFilPed

			oProcImpXML := MsNewProcess():New({ |lEnd| OFINJD4414_ImportaPedido(cPedFab, cForn, cLoja, cCondicao, cMarca) }, STR0035 + " XML ...","",.f.)
			//oProcImpXML:IncRegua2( 'Aguarde...' )
			oProcImpXML:Activate()
		EndIf
	EndIf
Return .T.

/*/{Protheus.doc} OFINJD4414_ImportaPedido
	Chama ofinjd10 para atualizar o pedido
	
	@type function
	@author Vinicius Gati
	@since 04/10/2017
/*/
Static function OFINJD4414_ImportaPedido(cPedFab, cForn, cLoja, cCondicao, cMarca)
	Local lVldImp := GetNewPar("MV_MIL0161",.F.)
	aRotina := {}

	dData  := stod(o1GetDados:aArray[o1GetDados:nAt, n1VQZ_DATA])
	if dData == ddatabase .And. lVldImp
		cHora := o1GetDados:aArray[o1GetDados:nAt, n1VQZ_HORA]
		if cHora < time() .and. ElapTime(cHora, time()) < "04:00:00"
			MsgAlert(STR0042, STR0011) // "Data de importa��o muito recente, favor aguardar ao menos 4 horas para verificar o status."
			return .t.
		endif
	endif

	lOk := OFJD10I( ;
		cPedFab    ,; // cPedJD 
		cForn      ,; // cFornece 
		cLoja      ,; // cLoja 
		cCondicao  ,; // cCondicao 
		cMarca     ,; // cCodMarca 
		.T.        ,; // lImpXml 
		''         ,; // aVetPed 
		oProcImpXML)  // oProcImpXML 
	if lOk
		MsgAlert(STR0036 /*"Pedido atualizado com sucesso"*/, STR0011 /*"Aten��o"*/)
	else
		MsgAlert(STR0037/*"Um problema ocorreu na integra��o com OFINJD10, favor averiguar conex�o e log da aplica��o"*/, STR0011/*"Aten��o"*/)
	endif
Return .T.

/*/{Protheus.doc} OFINJD4415_VerificaExistencia(cC7PedFab)
	Chama ofinjd10 para atualizar o pedido
	
	@type function
	@author Vinicius Gati
	@since 20/08/2018
/*/
static function OFINJD4415_VerificaExistencia(cC7PedFab, cC7Num)
	local cQuery := "" 
	cQuery += " SELECT COUNT(*) "
	cQuery += "   FROM " + RetSqlName("SC7")
	cQuery += "  WHERE C7_PEDFAB  = '"+cC7PedFab+"' "
	cQuery += "    AND C7_NUM    != '"+cC7Num   +"' "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
return FM_SQL(cQuery) > 0

/*/{Protheus.doc} OFINJD4416_AdequaPedido
	Esta fun��o pega um pedido sc7 de jdprism e limpa o mesmo, ap�s isto ele pega 
	o novo pedido com Pedfab e adequa a importa��o VQZ VR0 e VR1 com o novo
	Foi necess�rio esse processo devido a clientes estarem dando entrada de pedidos jdprism 
	que j� existem nada base.
	
	@type function
	@author Vinicius Gati
	@since 20/08/2018
/*/
static function OFINJD4416_AdequaPedido(cNumPed, cFilPed, cPedFab)
	local cNovoPed
	local cUpd

	cFilAnt := cFilPed

	// Pegar o codigo do novo pedido
	cNovoPed := FM_SQL(" SELECT C7_NUM FROM "+RetSqlName("SC7")+" WHERE C7_FILIAL = '"+xFilial("SC7")+"' AND C7_PEDFAB = '"+cPedFab+"' AND D_E_L_E_T_ = ' ' ")

	if Empty(cNovoPed)
		MSGSTOP(STR0041) // "N�mero do pedido n�o encontrado"
		return .f.
	endif

	dbSelectArea('SC7')
	dbSetOrder(1)
	dbSeek(xFilial('SC7') + cNovoPed)

	begin transaction
		// converter arquivo importado trocando pedido n�o adequado com o novo que tem o C7_PEDFAB 
		cUpd := " UPDATE " + RetSqlName('VR0')
		cUpd += "     SET VR0_NUMPED = '"+cNovoPed+"' "
		cUpd += " WHERE "
		cUpd += "     VR0_FILIAL = '"+xFilial('SC7')+"' "
		cUpd += " AND VR0_NUMPED = '"+cNumPed+"' "
		cUpd += " AND D_E_L_E_T_ = ' ' "
		if tcSqlExec(cUpd) < 0
			conout("OFINJD44: Erro de sql detectado " + TCSQLError())
			disarmtransaction()
			return .f.
		endif

		// limpeza de residuo do pedido n�o adequado (PEDFAB = JDPRISM)
		dbSelectArea('SC7')
		dbSetOrder(1)
		dbSeek(xFilial('SC7') + cNumPed)

		MA235PC(;
			100,;
			1,;         // cTipo2: 1-Pedido, 2-Autor.Entrega, 3-Ambos
			SC7->C7_EMISSAO,;  // dPar3 : Filtrar da Data de Emissao de
			SC7->C7_EMISSAO,;  // dPar4 : Filtrar da Data de Emissao Ate
			SC7->C7_NUM,;   // cPar5 : Filtrar da Solicitacao de
			SC7->C7_NUM,;   // cPar6 : Filtrar da Solicitacao Ate
			REPL('0', TamSX3('B1_COD')[1]),;    // cPar7 : Filtrar Produto de
			REPL('Z', TamSX3('B1_COD')[1]),;    // cPar8 : Filtrar Produto Ate
			REPL('0', TamSX3('A2_COD')[1]),;    // cPar9 : Filtrar Fornecedor de
			REPL('Z', TamSX3('A2_COD')[1]),;    // cPar10: Filtrar Fornecedor Ate
			,;      // dPar11: Filtrar Data Entrega de
			,;      // dPar12: Filtrar Data Entrega de
			REPL('0', TamSX3('C7_ITEM')[1]),;  // cPar13: Filtrar Item de
			REPL('Z', TamSX3('C7_ITEM')[1]),;  // cPar14: Filtrar Item Ate
			.T.)    // lPar15: Filtra pedido de origem do EIC
	end transaction
return .t.

/*/{Protheus.doc} OFINJD4417_filtraOrderTransferVQZ
	Esta fun��o se fez necess�ria por conta da necessidade de filtrar campos especificos
	da tabela VR0 ou VR1. A fun��o realiza a busca e retorna os dados pro array da 
	fun��o OFINJD4401_FiltraVQZ que ir� tratar dos demais filtros

	@type function
	@author Matheus Silva
	@since 14/09/2020
/*/
static function OFINJD4417_filtraOrderTransferVQZ(cTabela)
	Local cQuery := ""

	If cTabela == "VR0"
		cQuery := " SELECT VQZ.R_E_C_N_O_ "
		cQuery += "   FROM "+RetSqlName('VR0')+" VR0 "
		cQuery += "   JOIN "+RetSqlName('VQZ')+" VQZ ON VQZ_FILIAL = VR0_FILIAL AND VR0_CODVQZ = VQZ_CODIGO AND VQZ.D_E_L_E_T_ = ' ' "
		cQuery += "  WHERE VR0.D_E_L_E_T_ = ' ' "
		if !Empty(M->VQZ_FILIAL)
			cFilFiltro := oDPM:GetJdCode(M->VQZ_FILIAL)
			cQuery += " AND VR0_FILDES = '" + cFilFiltro + "' "
		endif
		cQuery += " AND VQZ_DATA >= '" + DTOS(M->VQZ_DATINI) + "' "
		cQuery += " AND VQZ_DATA <= '" + DTOS(M->VQZ_DATFIM) + "' "
		if !Empty(M->VQZ_PRODUT)
			cQuery += " AND VR0_PRODUT = '"+M->VQZ_PRODUT+"' "
		endif

		if !Empty(M->VQZ_COONUM)
			cQuery += " AND VQZ_COONUM = '" +M->VQZ_COONUM + "' "
		endif

		if !Empty(M->VQZ_ORDREF)
			cQuery += " AND VR0_ORDREF = '"+M->VQZ_ORDREF+"' "
		endif
		cQuery += " GROUP BY VQZ.R_E_C_N_O_ "
		cQuery += " ORDER BY VQZ.R_E_C_N_O_ DESC "
		cQuery := oSqlHlp:TopFunc(cQuery, 500)

	ElseIf cTabela == "VR1"
	
		cQuery := " SELECT VQZ.R_E_C_N_O_ "
		cQuery += "   FROM "+RetSqlName('VR1')+" VR1 "
		cQuery += "   JOIN "+RetSqlName('VQZ')+" VQZ ON VQZ_FILIAL = VR1_FILIAL AND VR1_CODVQZ = VQZ_CODIGO AND VQZ.D_E_L_E_T_ = ' ' "
		cQuery += "  WHERE VR1.D_E_L_E_T_ = ' ' "
		if !Empty(M->VQZ_FILIAL)
			cFilFiltro := oDPM:GetJdCode(M->VQZ_FILIAL)
			cQuery += " AND VR1_FILDES = '" + cFilFiltro + "' "
		endif
		cQuery += " AND VQZ_DATA >= '" + DTOS(M->VQZ_DATINI) + "' "
		cQuery += " AND VQZ_DATA <= '" + DTOS(M->VQZ_DATFIM) + "' "
		if !Empty(M->VQZ_PRODUT)
			cQuery += " AND VR1_PRODUT = '"+M->VQZ_PRODUT+"' "
		endif

		if !Empty(M->VQZ_COONUM)
			cQuery += " AND VQZ_COONUM = '" + M->VQZ_COONUM + "' "
		endif

		cQuery += " GROUP BY VQZ.R_E_C_N_O_ "
		cQuery += " ORDER BY VQZ.R_E_C_N_O_ DESC "
		cQuery := oSqlHlp:TopFunc(cQuery, 500)
	EndIf

return oSqlHlp:GetSelectArray(cQuery)