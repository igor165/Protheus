#INCLUDE "PROTHEUS.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIC290.CH"
/*/{Protheus.doc} OFIC290()
Consulta de Operações de Peças para Remessa

@author Andre Luis Almeida
@since 05/08/2022
@version 1.0
@return NIL
/*/
Function OFIC290(cFilOS,cNumOS)
Local aSizeAut := MsAdvSize(.f.)
Local lPodeFiltro := .t.
Private cCadastro := STR0001 // Consulta de Operações de Peças para Remessa
Private aRotina   := {} // Necessario deixar em branco para poder chamar a Consulta de outras rotinas
//
Private cFiltNOS  := Space(GetSX3Cache("VDR_NUMOSV","X3_TAMANHO"))
Private cFiltCli  := Space(GetSX3Cache("VDR_CLIENT","X3_TAMANHO"))
Private cFiltLoj  := Space(GetSX3Cache("VDR_LOJA","X3_TAMANHO"))
Private cFiltGrp  := Space(GetSX3Cache("B1_GRUPO","X3_TAMANHO"))
Private cFiltCod  := Space(GetSX3Cache("B1_CODITE","X3_TAMANHO"))
Private cFiltCSR  := "0" // Todas as Notas Fiscais ( com ou sem Retorno )
Private dFiltRmI  := dDataBase - day(dDataBase) + 1
Private dFiltRmF  := dDataBase
Private cFiltNFS  := Space(GetSX3Cache("VDR_NFSNUM","X3_TAMANHO"))
Private cFiltSrS  := Space(GetSX3Cache("VDR_NFSSER","X3_TAMANHO"))
Private dFiltRtI  := ctod("")
Private dFiltRtF  := dDataBase
Private cFiltNFE  := Space(GetSX3Cache("VDR_NFENUM","X3_TAMANHO"))
Private cFiltSrE  := Space(GetSX3Cache("VDR_NFESER","X3_TAMANHO"))
//
Private cGrpCodAnt := "" // variavel utilizada para disparar o SQL e pssibilitar filtrar o browse superior
//
Default cFilOS := ""
Default cNumOS := ""

// Tabela Temporaria NFs
oStrNFs := OFBrowseStruct():New({"VDR"})
oStrNFs:AddField( "VDR_FILIAL" )
oStrNFs:AddField( "VDR_NUMOSV" )
oStrNFs:AddField( "VDR_CLIENT" )
oStrNFs:AddField( "VDR_LOJA" )
oStrNFs:AddField( "VDR_NFSNUM" )
oStrNFs:AddField( "VDR_NFSSER" )
oStrNFs:AddField( "VDR_NFSEMI" )
oStrNFs:AddField( "VDR_NFENUM" )
oStrNFs:AddField( "VDR_NFESER" )
oStrNFs:AddField( "VDR_NEEEMI" )
oStrNFs:AddIndex( "VDR_NUMOSV" )
oStrNFs:AddIndex( "VDR_CLIENT+VDR_LOJA" )
oStrNFs:AddIndex( "VDR_NFSNUM+VDR_NFSSER" )
oStrNFs:AddIndex( "VDR_NFENUM+VDR_NFESER" )
oStrNFs:AddSeek( {"VDR_NUMOSV"} )
oStrNFs:AddSeek( {"VDR_CLIENT","VDR_LOJA"} )
oStrNFs:AddSeek( {"VDR_NFSNUM","VDR_NFSSER"} )
oStrNFs:AddSeek( {"VDR_NFENUM","VDR_NFESER"} )
oStrNFs:CriaTabTmp()

// Tabela Temporaria Itens
oStrIte := OFBrowseStruct():New({"VDR"})
oStrIte:AddField( "VDR_FILIAL" , , .f. )
oStrIte:AddField( "VDR_NUMOSV" , , .f. )
oStrIte:AddField( "VDR_CLIENT" , , .f. )
oStrIte:AddField( "VDR_LOJA"   , , .f. )
oStrIte:AddField( "VDR_NFSNUM" , , .f. )
oStrIte:AddField( "VDR_NFSSER" , , .f. )
oStrIte:AddField( "VDR_NFSEMI" , , .f. )
oStrIte:AddField( "VDR_NFENUM" , , .f. )
oStrIte:AddField( "VDR_NFESER" , , .f. )
oStrIte:AddField( "VDR_NEEEMI" , , .f. )
oStrIte:AddField( "VDR_TIPTEM" )
oStrIte:AddField( "VDR_GRUITE" )
oStrIte:AddField( "VDR_CODITE" )
oStrIte:AddField( "VDR_OPER" )
oStrIte:AddField( "VDR_CODTES" )
oStrIte:AddField( "VDR_QTDREM" )
oStrIte:AddField( "VDR_QTDUTI" )
oStrIte:AddField( "VDR_VALUNI" )
oStrIte:AddField( "VDR_LOCAL" )
oStrIte:AddIndex( "VDR_TIPTEM" )
oStrIte:AddIndex( "VDR_GRUITE+VDR_CODITE" )
oStrIte:AddSeek( {"VDR_TIPTEM"} )
oStrIte:AddSeek( {"VDR_GRUITE","VDR_CODITE"} )
oStrIte:CriaTabTmp()

OC2900011_LevantaDados(cFilOS,cNumOS) // Levanta os Dados

If !Empty(cFilOS+cNumOS)
	lPodeFiltro := .f. // Caso passou a Filial e o Nro.OS, a rotina nao habilita os Filtros F12
EndIf

If lPodeFiltro
	SetKey(VK_F12,{ || OC2900031_Filtro() }) // Possibilitar Filtros F12 somente se não consultou a OS
EndIf

oOFIC290 := MSDIALOG() :New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],cCadastro,,,,128,,,,,.t.)

// Paineis na Tela
oTPanNFs := TPanel():New(0,0,"",oOFIC290,NIL,.T.,.F.,NIL,NIL,100,(oOFIC290:nClientHeight/4)-10,.F.,.F.)
oTPanNFs:Align := CONTROL_ALIGN_TOP
oTPanIte := TPanel():New(0,0,"",oOFIC290,NIL,.T.,.F.,NIL,NIL,100,(oOFIC290:nClientHeight/4)-10,.F.,.F.)
oTPanIte:Align := CONTROL_ALIGN_BOTTOM

// Browse NFs
oBrwNFs := FWmBrowse():New()
oStrNFs:SetBrwOwner(oBrwNFs)
oBrwNFs:AddButton(STR0002,{ || OC2900021_Visualizar( 1 ) } ) // Visualiza NF de Remessa
oBrwNFs:AddButton(STR0003,{ || OC2900021_Visualizar( 2 ) } ) // Visualiza NF de Retorno
oBrwNFs:AddButton(STR0004,{ || OC2900021_Visualizar( 3 ) } ) // Visualiza Ordem de Serviço
If lPodeFiltro // Utiliza F12
	oBrwNFs:AddButton(STR0005+" (F12)",{ || OC2900031_Filtro() } ) // Filtro
EndIf
oBrwNFs:AddButton(STR0006,{ || OC2900041_Imprimir(1,cFilOS,cNumOS) } ) // Imprimir NF posicionada com Itens
oBrwNFs:AddButton(STR0007,{ || OC2900041_Imprimir(2,cFilOS,cNumOS) } ) // Imprimir todas as NFs e Itens
oBrwNFs:SetDescription(STR0008) // Notas Fiscais de Remessa
oBrwNFs:SetUseFilter()
oBrwNFs:SetMenuDef("")
oBrwNFs:SetWalkThru(.F.)
oBrwNFs:SetAmbiente(.F.)
oBrwNFs:DisableDetails()
oBrwNFs:ForceQuitButton()
oBrwNFs:AddLegend("  Empty(VDR_NFENUM) ", "WHITE"  , STR0009,,.f.) // Notas Fiscais sem Retorno
oBrwNFs:AddLegend(" !Empty(VDR_NFENUM) ", "YELLOW" , STR0010,,.f.) // Notas Fiscais com Retorno
If lPodeFiltro // Utiliza F12
	oBrwNFs:AddFilter( STR0011 , "@ VDR_NFSEMI >= '" + DtoS(dFiltRmI) + "' AND VDR_NFSEMI <= '" + DtoS(dFiltRmF) + "'",.t.,.t.,,,,"data_remessa") // Data NF Remessa
	oBrwNFs:AddFilter( STR0012 , "@ VDR_NEEEMI >= '" + DtoS(dFiltRtI) + "' AND VDR_NEEEMI <= '" + DtoS(dFiltRtF) + "'",.t.,.t.,,,,"data_retorno") // Data NF Retorno
Else // chamou a Consulta para uma determinada OS
	oBrwNFs:AddFilter( STR0013 , "@ VDR_FILIAL='"+cFilOS+"' AND VDR_NUMOSV='"+cNumOS+"'" ,.t.,.t.,,,, "nro_os" ) // Número da OS
EndIf
oBrwNFs:SetSeek(.T.,oStrNFs:GetSeek())
oBrwNFs:SetFieldFilter(oStrNFs:GetColFilter())
oBrwNFs:SetQueryIndex(oStrNFs:GetIndexes())
oStrNFs:AddBrwColumn()
oBrwNFs:SetAlias(oStrNFs:GetAlias())
oBrwNFs:SetOwner(oTPanNFs)
oBrwNFs:Activate()

// Browse Itens
oBrwIte := FWmBrowse():New()
oStrIte:SetBrwOwner(oBrwIte)
oBrwIte:SetDescription(STR0014) // Itens
oBrwIte:SetUseFilter()
oBrwIte:SetMenuDef("")
oBrwIte:SetWalkThru(.F.)
oBrwIte:SetAmbiente(.F.)
oBrwIte:DisableDetails()
oBrwIte:SetSeek(.T.,oStrIte:GetSeek())
oBrwIte:SetFieldFilter(oStrNFs:GetColFilter())
oBrwIte:SetQueryIndex(oStrNFs:GetIndexes())
oStrIte:AddBrwColumn()
oBrwIte:SetAlias(oStrIte:GetAlias())
oBrwIte:SetOwner(oTPanIte)
oBrwIte:Activate()

// Relacionamento entre os Browses NFs e Itens
oRelac:= FWBrwRelation():New()
oRelac:AddRelation( oBrwNFs , oBrwIte , { {"VDR_FILIAL","VDR_FILIAL"} , {"VDR_NUMOSV","VDR_NUMOSV"} , {"VDR_CLIENT","VDR_CLIENT"} , {"VDR_LOJA","VDR_LOJA"} , {"VDR_NFSNUM","VDR_NFSNUM"} , {"VDR_NFSSER","VDR_NFSSER"} , {"VDR_NFENUM","VDR_NFENUM"} , {"VDR_NFESER","VDR_NFESER"} } )
oRelac:Activate()

oOFIC290:Activate()

If lPodeFiltro
	SetKey(VK_F12,Nil)
EndIf

// Limpar Tabelas Temporarias
oStrNFs:DelTrabTmp()
oStrIte:DelTrabTmp()

Return

/*/{Protheus.doc} OC2900011_LevantaDados
Levanta Dados para popular os Browsers da Consulta

@author Andre Luis Almeida
@since 05/08/2022
/*/
Static Function OC2900011_LevantaDados(cFilOS,cNumOS)
Local cQuery   := ""
Local cWhere   := ""
Default cFilOS := ""
Default cNumOS := ""
//
If Empty(cFilOS+cNumOS) // Pode Filtro F12
	cWhere += " VDR_FILIAL = '"+xFilial("VDR")+"'"
	If !Empty(cFiltGrp)
		cWhere += " AND VDR_GRUITE = '"+cFiltGrp+"'"
	EndIf
	If !Empty(cFiltCod)
		cWhere += " AND VDR_CODITE = '"+cFiltCod+"'"
	EndIf
Else // Consultou apenas uma determinada OS
	cWhere += " VDR_FILIAL = '"+cFilOS+"' AND VDR_NUMOSV = '"+cNumOS+"'"
EndIf
cWhere += " AND D_E_L_E_T_ = ' '"
//
cQuery := "SELECT DISTINCT VDR_FILIAL , VDR_NUMOSV , VDR_CLIENT , VDR_LOJA , VDR_NFSNUM , VDR_NFSSER , VDR_NFSEMI , VDR_NFENUM , VDR_NFESER , VDR_NEEEMI "
cQuery += "  FROM "+RetSQLName("VDR")
cQuery += " WHERE "+cWhere
oStrNFs:LoadData( cQuery , .t. )
DbSelectArea(oStrNFs:GetAlias())
//
cQuery := "SELECT VDR_FILIAL , VDR_NUMOSV , VDR_CLIENT , VDR_LOJA , VDR_NFSNUM , VDR_NFSSER , VDR_NFSEMI , VDR_NFENUM , VDR_NFESER , VDR_NEEEMI ,"
cQuery += "       VDR_TIPTEM , VDR_GRUITE , VDR_CODITE , VDR_OPER , VDR_CODTES , VDR_QTDREM , VDR_QTDUTI , VDR_VALUNI , VDR_LOCAL "
cQuery += "  FROM "+RetSQLName("VDR")
cQuery += " WHERE "+cWhere
oStrIte:LoadData( cQuery , .t. )
DbSelectArea(oStrIte:GetAlias())
//
cGrpCodAnt := cFiltGrp+cFiltCod // Salvar o ultimo Grupo e Filtro utilizado no SQL
//
Return

/*/{Protheus.doc} OC2900021_Visualizar
Visualizar Origens - NF Remessa, NF Retorno e OS.

@author Andre Luis Almeida
@since 08/08/2022
/*/
Static Function OC2900021_Visualizar( nTp )
Local cSeek       := ""
Private nOpc      := 2   // variavel necessaria no OFIOC060 (SX3)
Private VISUALIZA := .T. // variavel necessaria no OFIOC060 (SX3)
Private INCLUI    := .F. // variavel necessaria no OFIOC060 (SX3)
Private ALTERA    := .F. // variavel necessaria no OFIOC060 (SX3)
Private EXCLUI    := .F. // variavel necessaria no OFIOC060 (SX3)
Default nTp       := 0
DbSelectArea(oStrNFs:GetAlias())
Do Case
	Case nTp == 1 // Visualiza a NF de Remessa (SAIDA)
		cSeek := VDR_FILIAL + VDR_NFSNUM + VDR_NFSSER
		If !Empty( cSeek )
			DbSelectArea("SF2")
			DbSetOrder(1)
			If DbSeek( cSeek )
				Mc090Visual("SF2",SF2->(RecNo()),2) // Consultar NF ( MATC090 )
			EndIf
		EndIf
	Case nTp == 2 // Visualiza a NF Retorno da Remessa (ENTRADA)
		If !Empty( VDR_NFENUM + VDR_NFESER )
			cSeek := VDR_FILIAL + VDR_NFENUM + VDR_NFESER
			DbSelectArea("SF1")
			DbSetOrder(1)
			If DbSeek( cSeek )
				MATA103(,,2)
			EndIf
		Else
			MsgStop(STR0043,STR0044) // Esta Nota Fiscal de Remessa não possui Retorno! / Atenção
		EndIf
	Case nTp == 3 // Visualizar OS
		cSeek := VDR_FILIAL + VDR_NUMOSV
		If !Empty( cSeek )
			DbSelectArea("VO1")
			DbSetOrder(1)
			If DbSeek( cSeek )
				OFIOC060(.t.)
			EndIf
		EndIf
EndCase
If !Empty( cSeek )
	DbSelectArea(oStrNFs:GetAlias())
EndIf
Return

/*/{Protheus.doc} OC2900031_Filtro

@author Andre Luis Almeida
@since 20/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Function OC2900031_Filtro()

	Local aParamBox := {}
	Local aRetParam := {}
	Local aNFsCSR   := {"0="+STR0020,"1="+STR0021,"2="+STR0022} // Todas / Remessa sem Retorno / Remessa com Retorno

	DbSelectArea(oStrNFs:GetAlias())
	DbGoTop()

	SetKey(VK_F12,Nil)

	aAdd(aParamBox,{1,STR0013,cFiltNOS,"@!","Vazio() .OR. FG_SEEK('VO1','MV_PAR01',1,.F.)","VO1","",50,.F.}) // Número da OS
	aAdd(aParamBox,{1,STR0015,cFiltCli,"@!","Vazio() .OR. FG_SEEK('SA1','MV_PAR02',1,.F.)","SA1","",50,.F.}) // Cliente
	aAdd(aParamBox,{1,STR0016,cFiltLoj,"@!","",""   ,"",25,.F.}) // Loja
	aAdd(aParamBox,{1,STR0017,cFiltGrp,"@!","Vazio() .OR. FG_SEEK('SBM','MV_PAR04',1,.F.)","SBM"   ,"",40,.F.}) // Grupo
	aAdd(aParamBox,{1,STR0018,cFiltCod,"@!","Vazio() .OR. FG_POSSB1('MV_PAR05','SB1->B1_CODITE','MV_PAR04')","B01P04","",90,.F.}) // Código do Item
	aAdd(aParamBox,{2,STR0019,cFiltCSR,aNFsCSR,90,"",.f.,".t."}) // Notas Fiscais
	aAdd(aParamBox,{1,STR0023,dFiltRmI,"@D","",""   ,"",50,.F.}) // Data NF Remessa - De
	aAdd(aParamBox,{1,STR0024,dFiltRmF,"@D","",""   ,"",50,.F.}) // Data NF Remessa - Ate
	aAdd(aParamBox,{1,STR0025,cFiltNFS,"@!","Vazio() .OR. FG_SEEK('SF2','MV_PAR09',1,.F.)","SF2","",50,.F.}) // Nro. NF Remessa
	aAdd(aParamBox,{1,STR0026,cFiltSrS,"@!","","","",25,.F.}) // Serie NF Remessa
	aAdd(aParamBox,{1,STR0027,dFiltRtI,"@D","",""   ,"",50,.F.}) // Data NF Retorno - De
	aAdd(aParamBox,{1,STR0028,dFiltRtF,"@D","",""   ,"",50,.F.}) // Data NF Retorno - Ate
	aAdd(aParamBox,{1,STR0029,cFiltNFE,"@!","Vazio() .OR. FG_SEEK('SF1','MV_PAR13',1,.F.)","SF1","",50,.F.}) // Nro. NF Retorno
	aAdd(aParamBox,{1,STR0030,cFiltSrE,"@!","","","",25,.F.}) // Serie NF Retorno

	If ParamBox(aParamBox,STR0005+" (F12)",@aRetParam,,,,,,,,.f.) // Filtro (F12)
		
		cFiltNOS := aRetParam[1]
		cFiltCli := aRetParam[2]
		cFiltLoj := aRetParam[3]
		cFiltGrp := aRetParam[4]
		cFiltCod := aRetParam[5]
		cFiltCSR := aRetParam[6]
		dFiltRmI := aRetParam[7]
		dFiltRmF := aRetParam[8]
		cFiltNFS := aRetParam[9]
		cFiltSrS := aRetParam[10]
		dFiltRtI := aRetParam[11]
		dFiltRtF := aRetParam[12]
		cFiltNFE := aRetParam[13]
		cFiltSrE := aRetParam[14]
		
		If cGrpCodAnt <> cFiltGrp+cFiltCod // Disparar SQL novamente se mudou o Grupo e Codigo do Item no Filtro F12
			OC2900011_LevantaDados() // Faz o levantamento SQL novamente
		EndIf
		
		oBrwNFs:DeleteFilter("data_remessa")
		oBrwNFs:DeleteFilter("data_retorno")
		oBrwNFs:DeleteFilter("nro_os")
		oBrwNFs:DeleteFilter("cliente_loja")
		oBrwNFs:DeleteFilter("nfs_csr")
		oBrwNFs:DeleteFilter("nf_remessa")
		oBrwNFs:DeleteFilter("nf_retorno")

		oBrwNFs:AddFilter( STR0011 , "@ VDR_NFSEMI >= '" + DtoS(dFiltRmI) + "' AND VDR_NFSEMI <= '" + DtoS(dFiltRmF) + "'",.t.,.t.,,,,"data_remessa") // Data NF Remessa
		oBrwNFs:AddFilter( STR0012 , "@ VDR_NEEEMI >= '" + DtoS(dFiltRtI) + "' AND VDR_NEEEMI <= '" + DtoS(dFiltRtF) + "'",.t.,.t.,,,,"data_retorno") // Data NF Retorno
		If !Empty(cFiltNOS)
			oBrwNFs:AddFilter( STR0013 , "@ VDR_NUMOSV = '"+cFiltNOS+"'",.t.,.t.,,,,"nro_os") // Número da OS
		EndIf
		Do Case
			Case !Empty(cFiltCli) .and. !Empty(cFiltLoj)
				oBrwNFs:AddFilter( STR0031 , "@ VDR_CLIENT = '"+cFiltCli+"' AND VDR_LOJA = '"+cFiltLoj+"'",.t.,.t.,,,,"cliente_loja") // Código + Loja do Cliente
			Case !Empty(cFiltCli)
				oBrwNFs:AddFilter( STR0032 , "@ VDR_CLIENT = '"+cFiltCli+"'",.t.,.t.,,,,"cliente_loja") // Código do Cliente
			Case !Empty(cFiltLoj)
				oBrwNFs:AddFilter( STR0033 , "@ VDR_LOJA = '"+cFiltLoj+"'",.t.,.t.,,,,"cliente_loja") // Loja do Cliente
		EndCase
		Do Case
			Case cFiltCSR == "1" // Notas Fiscais de Remessa sem Retorno
				oBrwNFs:AddFilter( STR0034 , "@ VDR_NFENUM = ' '",.t.,.t.,,,,"nfs_csr") // Notas Fiscais de Remessa sem Retorno
			Case cFiltCSR == "2" // Notas Fiscais de Remessa com Retorno
				oBrwNFs:AddFilter( STR0035 , "@ VDR_NFENUM <> ' '",.t.,.t.,,,,"nfs_csr") // Notas Fiscais de Remessa com Retorno
		EndCase
		Do Case
			Case !Empty(cFiltNFS) .and. !Empty(cFiltSrS)
				oBrwNFs:AddFilter( STR0036 , "@ VDR_NFSNUM = '"+cFiltNFS+"' AND VDR_NFSSER = '"+cFiltSrS+"'",.t.,.t.,,,,"nf_remessa") // Número + Série da NF Remessa
			Case !Empty(cFiltNFS)
				oBrwNFs:AddFilter( STR0037 , "@ VDR_NFSNUM = '"+cFiltNFS+"'",.t.,.t.,,,,"nf_remessa") // Número da NF Remessa
			Case !Empty(cFiltSrS)
				oBrwNFs:AddFilter( STR0038 , "@ VDR_NFSSER = '"+cFiltSrS+"'",.t.,.t.,,,,"nf_remessa") // Série da NF Remessa
		EndCase
		Do Case
			Case !Empty(cFiltNFE) .and. !Empty(cFiltSrE)
				oBrwNFs:AddFilter( STR0039 , "@ VDR_NFENUM = '"+cFiltNFE+"' AND VDR_NFESER = '"+cFiltSrE+"'",.t.,.t.,,,,"nf_retorno") // Número + Série da NF Retorno
			Case !Empty(cFiltNFE)
				oBrwNFs:AddFilter( STR0040 , "@ VDR_NFENUM = '"+cFiltNFE+"'",.t.,.t.,,,,"nf_retorno") // Número da NF Retorno
			Case !Empty(cFiltSrE)
				oBrwNFs:AddFilter( STR0041 , "@ VDR_NFESER = '"+cFiltSrE+"'",.t.,.t.,,,,"nf_retorno") // Série da NF Retorno
		EndCase

	EndIf

	oBrwNFs:SetFocus()
	oBrwNFs:ExecuteFilter(.t.)
	oBrwNFs:Refresh()

	// Relacionamento entre os Browses NFs e Itens
	oRelac:= FWBrwRelation():New()
	oRelac:AddRelation( oBrwNFs , oBrwIte , { {"VDR_FILIAL","VDR_FILIAL"} , {"VDR_NUMOSV","VDR_NUMOSV"} , {"VDR_CLIENT","VDR_CLIENT"} , {"VDR_LOJA","VDR_LOJA"} , {"VDR_NFSNUM","VDR_NFSNUM"} , {"VDR_NFSSER","VDR_NFSSER"} , {"VDR_NFENUM","VDR_NFENUM"} , {"VDR_NFESER","VDR_NFESER"} } )
	oRelac:Activate()

	oBrwIte:SetFocus()
	oBrwIte:ExecuteFilter(.t.)
	oBrwIte:Refresh()

	oBrwNFs:SetFocus() // Volta o Foco para as NFs

	SetKey(VK_F12,{ || OC2900031_Filtro() })

Return

/*/{Protheus.doc} OC2900041_Imprimir
Imprimir os Browsers da Consulta

@author Andre Luis Almeida
@since 09/08/2022
/*/
Static Function OC2900041_Imprimir( nTp , cFilOS , cNumOS )
Local oReport
oReport := ReportDef( nTp , cFilOS , cNumOS ) // Nesta função nós definimos a estrutura do relatório, por exemplo as seções, campos, totalizadores e etc.
oReport:PrintDialog()  // Essa função serve para disparar a impressão do TReport, ela que faz com que seja exibida a tela de configuração de impressora e os botões de parâmetros.
Return

/*/{Protheus.doc} ReportDef
Função para criar as celulas que serão impressas

@author Andre Luis Almeida
@since 10/08/2022
@type function
/*/
Static Function ReportDef( nTp , cFilOS , cNumOS )

oReport := TReport():New("OFIOC290",;	// Nome do Relatório
	STR0001,;							// Consulta de Operações de Peças para Remessa
	"",;							// Nome da Pergunta
	{|oReport| ReportPrint( oReport , nTp , cFilOS , cNumOS )},;	// Bloco de código que será executado na confirmação
	STR0001 )							// Consulta de Operações de Peças para Remessa

oReport:SetLandscape()
oReport:SetTotalInLine(.f.) //Define se os totalizadores serão impressos em linha ou coluna.

oSection1 := TRSection():New(oReport,STR0042,{"VDR"},,) // Operações de Peças para Remessa
oSection1:SetAutoSize(.t.)
TRCell():New(oSection1, "VDR_FILIAL" , "VDR" , RetTitle("VDR_FILIAL") , GetSX3Cache("VDR_FILIAL","X3_PICTURE") , 20 ) // Filial
TRCell():New(oSection1, "VDR_NUMOSV" , "VDR" , RetTitle("VDR_NUMOSV") , GetSX3Cache("VDR_NUMOSV","X3_PICTURE") , 20 ) // OS
TRCell():New(oSection1, "VDR_CLIENT" , "VDR" , RetTitle("VDR_CLIENT") , GetSX3Cache("VDR_CLIENT","X3_PICTURE") , 15 ) // Cliente
TRCell():New(oSection1, "VDR_LOJA"   , "VDR" , RetTitle("VDR_LOJA")   , GetSX3Cache("VDR_LOJA","X3_PICTURE")   , 10 ) // Loja
TRCell():New(oSection1, "VDR_NFSNUM" , "VDR" , RetTitle("VDR_NFSNUM") , GetSX3Cache("VDR_NFSNUM","X3_PICTURE") , 20 ) // NF Remessa
TRCell():New(oSection1, "VDR_NFSSER" , "VDR" , RetTitle("VDR_NFSSER") , GetSX3Cache("VDR_NFSSER","X3_PICTURE") , 10 ) // Serie NF Remessa
TRCell():New(oSection1, "VDR_NFSEMI" , "VDR" , RetTitle("VDR_NFSEMI") , GetSX3Cache("VDR_NFSEMI","X3_PICTURE") , 15 ) // Data NF Remessa
TRCell():New(oSection1, "VDR_NFENUM" , "VDR" , RetTitle("VDR_NFENUM") , GetSX3Cache("VDR_NFENUM","X3_PICTURE") , 20 ) // NF Retorno
TRCell():New(oSection1, "VDR_NFESER" , "VDR" , RetTitle("VDR_NFESER") , GetSX3Cache("VDR_NFESER","X3_PICTURE") , 10 ) // Serie NF Retorno
TRCell():New(oSection1, "VDR_NEEEMI" , "VDR" , RetTitle("VDR_NEEEMI") , GetSX3Cache("VDR_NEEEMI","X3_PICTURE") , 15 ) // Data NF Retorno

oSection2 := TRSection():New(oReport,STR0014,{"VDR"},,) // Itens
oSection2:SetAutoSize(.t.)
TRCell():New(oSection2, "" ,, "" , "@!", 3,, {|| space(3) },,,,) // Coluna em branco para deixar o layout melhor para visualização das quebras
TRCell():New(oSection2, "VDR_TIPTEM" , "VDR" , RetTitle("VDR_TIPTEM") , GetSX3Cache("VDR_TIPTEM","X3_PICTURE") , 10 ) // Tipo de Tempo
TRCell():New(oSection2, "VDR_GRUITE" , "VDR" , RetTitle("VDR_GRUITE") , GetSX3Cache("VDR_GRUITE","X3_PICTURE") , 15 ) // Grupo do Item
TRCell():New(oSection2, "VDR_CODITE" , "VDR" , RetTitle("VDR_CODITE") , GetSX3Cache("VDR_CODITE","X3_PICTURE") , 30 ) // Codigo do Item
TRCell():New(oSection2, "VDR_OPER"   , "VDR" , RetTitle("VDR_OPER")   , GetSX3Cache("VDR_OPER","X3_PICTURE")   , 10 ) // Operação
TRCell():New(oSection2, "VDR_CODTES" , "VDR" , RetTitle("VDR_CODTES") , GetSX3Cache("VDR_CODTES","X3_PICTURE") , 10 ) // TES
TRCell():New(oSection2, "VDR_QTDREM" , "VDR" , RetTitle("VDR_QTDREM") , GetSX3Cache("VDR_QTDREM","X3_PICTURE") , 20 ) // Qtde Remessa
TRCell():New(oSection2, "VDR_QTDUTI" , "VDR" , RetTitle("VDR_QTDUTI") , GetSX3Cache("VDR_QTDUTI","X3_PICTURE") , 20 ) // Qtde Utilizada
TRCell():New(oSection2, "VDR_VALUNI" , "VDR" , RetTitle("VDR_VALUNI") , GetSX3Cache("VDR_VALUNI","X3_PICTURE") , 20 ) // Valor Unitario
TRCell():New(oSection2, "VDR_LOCAL"  , "VDR" , RetTitle("VDR_LOCAL")  , GetSX3Cache("VDR_LOCAL","X3_PICTURE")  , 10 ) // Local

Return oReport

/*/{Protheus.doc} ReportPrint
Função para adicionar as informações que serão impressas

@author Andre Luis Almeida
@since 10/08/2022
@type function
/*/
Static Function ReportPrint( oReport , nTp , cFilOS , cNumOS )
Local oSection1 := oReport:Section(1) // VDR - Cabeça
Local oSection2 := oReport:Section(2) // VDR - Itens
Local cQuery    := ""
Local cQAlSQL   := "SQLVDR"
Local cQuebra   := ""
//
cQuery := "SELECT R_E_C_N_O_ AS RECVDR"
cQuery += "  FROM "+RetSQLName("VDR")
cQuery += " WHERE "
If nTp == 1 // Linha posicionada
	DbSelectArea(oStrNFs:GetAlias())
	cQuery += " VDR_FILIAL     = '" + VDR_FILIAL + "'"
	cQuery += " AND VDR_NUMOSV = '" + VDR_NUMOSV + "'"
	cQuery += " AND VDR_CLIENT = '" + VDR_CLIENT + "'"
	cQuery += " AND VDR_LOJA   = '" + VDR_LOJA   + "'"
	cQuery += " AND VDR_NFSNUM = '" + VDR_NFSNUM + "'"
	cQuery += " AND VDR_NFSSER = '" + VDR_NFSSER + "'"
	cQuery += " AND VDR_NFENUM = '" + VDR_NFENUM + "'"
	cQuery += " AND VDR_NFESER = '" + VDR_NFESER + "'"
Else // Todos os registros do Browse
	If Empty(cFilOS+cNumOS) // Pode Filtro F12
		cQuery += " VDR_FILIAL = '"+xFilial("VDR")+"'"
		cQuery += IIf(!Empty(cFiltNOS)," AND VDR_NUMOSV = '"+cFiltNOS+"'","")
		cQuery += IIf(!Empty(cFiltGrp)," AND VDR_GRUITE = '"+cFiltGrp+"'","")
		cQuery += IIf(!Empty(cFiltCod)," AND VDR_CODITE = '"+cFiltCod+"'","")
		cQuery += IIf(!Empty(cFiltCli)," AND VDR_CLIENT = '"+cFiltCli+"'","")
		cQuery += IIf(!Empty(cFiltLoj)," AND VDR_LOJA   = '"+cFiltLoj+"'","")
		cQuery += IIf(!Empty(cFiltNFS)," AND VDR_NFSNUM = '"+cFiltNFS+"'","")
		cQuery += IIf(!Empty(cFiltSrS)," AND VDR_NFSSER = '"+cFiltSrS+"'","")
		cQuery += IIf(!Empty(cFiltNFE)," AND VDR_NFENUM = '"+cFiltNFE+"'","")
		cQuery += IIf(!Empty(cFiltSrE)," AND VDR_NFESER = '"+cFiltSrE+"'","")
		cQuery += IIf(cFiltCSR == "1" ," AND VDR_NFENUM = ' '"           ,"")
		cQuery += IIf(cFiltCSR == "2" ," AND VDR_NFENUM <> ' '"          ,"")
		cQuery += " AND VDR_NFSEMI >= '" + DtoS(dFiltRmI) + "' AND VDR_NFSEMI <= '" + DtoS(dFiltRmF) + "'"
		cQuery += " AND VDR_NEEEMI >= '" + DtoS(dFiltRtI) + "' AND VDR_NEEEMI <= '" + DtoS(dFiltRtF) + "'"
	Else // Consultou apenas uma determinada OS
		cQuery += " VDR_FILIAL = '"+cFilOS+"' AND VDR_NUMOSV = '"+cNumOS+"'"
	EndIf
EndIf
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery += " ORDER BY VDR_FILIAL , VDR_NUMOSV , VDR_CLIENT , VDR_LOJA , VDR_NFSNUM , VDR_NFSSER , VDR_NFSEMI , VDR_NFENUM , VDR_NFESER , VDR_NEEEMI"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL, .F., .T. )
oReport:SetMeter( (cQAlSQL)->(RecCount()) )
While !(cQAlSQL)->(Eof()) .and. !oReport:Cancel()
	VDR->(DbGoto( (cQAlSQL)->RECVDR ))
	oReport:IncMeter()
	If cQuebra <> ( VDR->VDR_FILIAL+VDR->VDR_NUMOSV+VDR->VDR_CLIENT+VDR->VDR_LOJA+VDR->VDR_NFSNUM+VDR->VDR_NFSSER+VDR->VDR_NFENUM+VDR->VDR_NFESER )
		If !Empty(cQuebra)
			oSection2:Finish()
		EndIf
		oSection1:Init()
		oSection1:PrintLine() // Imprimir Cabeçalho
		oSection1:Finish()
		oSection2:Init()
		cQuebra := ( VDR->VDR_FILIAL+VDR->VDR_NUMOSV+VDR->VDR_CLIENT+VDR->VDR_LOJA+VDR->VDR_NFSNUM+VDR->VDR_NFSSER+VDR->VDR_NFENUM+VDR->VDR_NFESER )
	EndIf
	oSection2:PrintLine() // Imprimir Itens
	(cQAlSQL)->(dbSkip())
EndDo
(cQAlSQL)->(dbCloseArea())
If !Empty(cQuebra)
	oSection2:Finish()
EndIf
DbSelectArea(oStrNFs:GetAlias())
Return