#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDef.ch"
#INCLUDE "OFAGCT02.CH"

/*/{Protheus.doc} mil_ver()
		Versao do fonte modelo novo

		@author Vinicius Gati
		@since  14/06/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "4"


/*/{Protheus.doc} OFAGCT02
	Tela para configuração dos dados básicos do VMI

	@author Vinicius Gati
	@since  27/06/2017
/*/
Function OFAGCT02()
	Local oInterfHelper   := DMS_InterfaceHelper():New()
	Local oVmiPars        := OFAGVmiParametros():New()
	Local ni              := 0
	Local aObjects        := {} , aInfo := {}, aPos := {}
	Local aSizeHalf       := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
	Local nLinhas         := 9999
	Local oFont1          := TFont():New(,11,24,,.F.,,,,,,,,,,,)
	Local oOkTik          := LoadBitmap( GetResources() , "LBTIK" )
	Local oNoTik          := LoadBitmap( GetResources() , "LBNO" )
	Private aCposMSMGet   := OFAGCT02CPOS()
	Private aColsSA1      := {}
	Private aColsSA2      := {}
	Private aColsSBM1     := {}
	Private aColsSBM2     := {}
	Private aColsVEJ      := {}
	Private aListSM0      := {}
	Private aHeadSA1      := OFAGCT02HEAD("XA1")
	Private aHeadSA2      := OFAGCT02HEAD("XA2")
	Private aHeadSBM      := OFAGCT02HEAD("SBM")
	Private aHeadVEJ      := OFAGCT02HEAD("VEJ")
	Private M->VE6_CODMAR := "" // Utilizado para F3 dos VEJ (Folder 3)
	Private M->VEJ_CODMAR := "" // Utilizado para F3 dos VEJ (Folder 3)
	Private cMotivo       := "000004" //Filtro da consulta do motivo de Cancelamento - Venda Perdida
	Private cFileName     := oVmiPars:NomeArqConfig()
	For ni := 1 to len(aCposMSMGet)
		Private &("M->"+aCposMSMGet[ni,2]) := space(aCposMSMGet[ni,4])
	Next

	oInterfHelper:nOpc := 3
	oInterfHelper:SetOwnerPvt("OFAGCT02")

	OFAGCT02INI() // Carregar Configuracoes Gravadas

	aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
	aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // Tela Total
	aPos := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oOFAGCT02 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0001 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // VMI Parametros
	oOFAGCT02:lEscClose := .F.

	oFolders := TFolder():New(aPos[1,1],aPos[1,2],{STR0002,STR0003,STR0004,STR0005},{}, oOFAGCT02,,,,.t.,.f.,aPos[1,4],aPos[1,3]) // Fornecedores / Pecas / Pedidos / Outros

	////////////////////////////
	//   F O L D E R    0 1   //
	////////////////////////////

	oFWLayer1 := FWLayer():New()
	oFWLayer1:Init(oFolders:aDialogs[1],.F.)
	oFWLayer1:AddLine('CAB_TOPO',04,.F.) // Cabecalho do TOPO
	oFWLayer1:AddLine('WIN_TOPO',26,.F.) // Janela do Objeto do TOPO
	oFWLayer1:AddLine('CAB_MEIO',04,.F.) // Cabecalho do MEIO
	oFWLayer1:AddLine('WIN_MEIO',26,.F.) // Janela do Objeto do MEIO
	oFWLayer1:AddLine('CAB_BAIX',04,.F.) // Cabecalho de BAIXO
	oFWLayer1:AddLine('WIN_BAIX',26,.F.) // Janela do Objeto de BAIXO

	oCAB_TOPO1 := oFWLayer1:GetLinePanel('CAB_TOPO')
	oWIN_TOPO1 := oFWLayer1:GetLinePanel('WIN_TOPO')
	oCAB_MEIO1 := oFWLayer1:GetLinePanel('CAB_MEIO')
	oWIN_MEIO1 := oFWLayer1:GetLinePanel('WIN_MEIO')
	oCAB_BAIX1 := oFWLayer1:GetLinePanel('CAB_BAIX')
	oWIN_BAIX1 := oFWLayer1:GetLinePanel('WIN_BAIX')

	@ 01,01 SAY STR0006 SIZE 150,13 FONT oFont1 OF oCAB_TOPO1 PIXEL COLOR CLR_BLUE // Filiais AGCO
	oListSM0 := TWBrowse():New(0,0,100,100,,,,oWIN_TOPO1,,,,{ || },{ || OFAGCT02DBL() } ,,,,,,,.F.,"",.T.,,.F.,,,)
	oListSM0:SetArray(aListSM0)
	oListSM0:addColumn( TCColumn():New( ""      , { || IIf(aListSM0[oListSM0:nAt,01],oOkTik,oNoTik) }                 ,,,, "LEFT" , 05 ,.T.,.F.,,,,.F.,) )
	oListSM0:addColumn( TCColumn():New( STR0007 , { || aListSM0[oListSM0:nAt,02] }                                    ,,,, "LEFT" , 25 ,.F.,.F.,,,,.F.,) ) // Codigo
	oListSM0:addColumn( TCColumn():New( STR0008 , { || aListSM0[oListSM0:nAt,03] }                                    ,,,, "LEFT" , 70 ,.F.,.F.,,,,.F.,) ) // Nome
	oListSM0:addColumn( TCColumn():New( STR0009 , { || Transform(aListSM0[oListSM0:nAt,04],"@R 99.999.999/9999-99") } ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) ) // CNPJ
	oListSM0:addColumn( TCColumn():New( STR0018 , { || aListSM0[oListSM0:nAt,05] }                                    ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) ) // Usuario
	oListSM0:addColumn( TCColumn():New( STR0019 , { || aListSM0[oListSM0:nAt,06] }                                    ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) ) // Senha

	oListSM0:Align := CONTROL_ALIGN_ALLCLIENT

	@ 01,01 SAY STR0010 SIZE 150,15 FONT oFont1 OF oCAB_MEIO1 PIXEL COLOR CLR_BLUE // Concessionarios da Rede
	oGDSA1:= MsNewGetDados():New(0,0,100,100,GD_INSERT+GD_UPDATE+GD_DELETE,"OFAGCT02LOK('SA1')",,,{'XA1_COD','XA1_LOJA'},,nLinhas,"OFAGCT02FOK('SA1')",,,oWIN_MEIO1,aHeadSA1,aColsSA1 )
	oGDSA1:oBrowse:bChange := { || FG_MEMVAR(oGDSA1:aHeader,oGDSA1:aCols,oGDSA1:nAt) }
	oGDSA1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	@ 01,01 SAY STR0011 SIZE 150,15 FONT oFont1 OF oCAB_BAIX1 PIXEL COLOR CLR_BLUE // Fornecedores AGCO
	oGDSA2:= MsNewGetDados():New(0,0,100,100,GD_INSERT+GD_UPDATE+GD_DELETE,"OFAGCT02LOK('SA2')",,,{'XA2_COD','XA2_LOJA'},,nLinhas,"OFAGCT02FOK('SA2')",,,oWIN_BAIX1,aHeadSA2,aColsSA2 )
	oGDSA2:oBrowse:bChange := { || FG_MEMVAR(oGDSA2:aHeader,oGDSA2:aCols,oGDSA2:nAt) }
	oGDSA2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT


	////////////////////////////
	//   F O L D E R    0 2   //
	////////////////////////////

	oFWLayer2 := FWLayer():New()
	oFWLayer2:Init(oFolders:aDialogs[2],.F.)
	oFWLayer2:AddLine('CAB_TOPO',04,.F.) // Cabecalho do TOPO
	oFWLayer2:AddLine('WIN_TOPO',41,.F.) // Janela do Objeto do TOPO
	oFWLayer2:AddLine('CAB_BAIX',04,.F.) // Cabecalho de BAIXO
	oFWLayer2:AddLine('WIN_BAIX',41,.F.) // Janela do Objeto de BAIXO

	oCAB_TOPO2 := oFWLayer2:GetLinePanel('CAB_TOPO')
	oWIN_TOPO2 := oFWLayer2:GetLinePanel('WIN_TOPO')
	oCAB_BAIX2 := oFWLayer2:GetLinePanel('CAB_BAIX')
	oWIN_BAIX2 := oFWLayer2:GetLinePanel('WIN_BAIX')

	@ 01,01 SAY STR0012 SIZE 150,15 FONT oFont1 OF oCAB_TOPO2 PIXEL COLOR CLR_BLUE // Grupos Originais
	oGDSBM1:= MsNewGetDados():New(0,0,100,100,GD_INSERT+GD_UPDATE+GD_DELETE,"OFAGCT02LOK('SBM1')",,,{'XBM_GRUPO'},,nLinhas,"OFAGCT02FOK('SBM1')",,,oWIN_TOPO2,aHeadSBM,aColsSBM1 )
	oGDSBM1:oBrowse:bChange := { || FG_MEMVAR(oGDSBM1:aHeader,oGDSBM1:aCols,oGDSBM1:nAt) }
	oGDSBM1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	@ 01,01 SAY STR0013 SIZE 150,15 FONT oFont1 OF oCAB_BAIX2 PIXEL COLOR CLR_BLUE // Grupos Paralelos
	oGDSBM2:= MsNewGetDados():New(0,0,100,100,GD_INSERT+GD_UPDATE+GD_DELETE,"OFAGCT02LOK('SBM2')",,,{'XBM_GRUPO'},,nLinhas,"OFAGCT02FOK('SBM2')",,,oWIN_BAIX2,aHeadSBM,aColsSBM2 )
	oGDSBM2:oBrowse:bChange := { || FG_MEMVAR(oGDSBM2:aHeader,oGDSBM2:aCols,oGDSBM2:nAt) }
	oGDSBM2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT


	////////////////////////////
	//   F O L D E R    0 3   //
	////////////////////////////

	oFWLayer3 := FWLayer():New()
	oFWLayer3:Init(oFolders:aDialogs[3],.F.)
	oFWLayer3:AddLine('CAB_TOPO',04,.F.) // Cabecalho do TOPO
	oFWLayer3:AddLine('WIN_TOPO',86,.F.) // Janela do Objeto do TOPO

	oCAB_TOPO3 := oFWLayer3:GetLinePanel('CAB_TOPO')
	oWIN_TOPO3 := oFWLayer3:GetLinePanel('WIN_TOPO')

	@ 01,01 SAY STR0014 SIZE 150,15 FONT oFont1 OF oCAB_TOPO3 PIXEL COLOR CLR_BLUE // Tipos de Pedidos
	oGDVEJ:= MsNewGetDados():New(0,0,100,100,GD_INSERT+GD_UPDATE+GD_DELETE,"OFAGCT02LOK('VEJ')",,,{'VEJ_FILIAL','VEJ_CODMAR','VEJ_TIPMAQ','VEJ_TIPGAR','VEJ_TIPREP'},,nLinhas,"OFAGCT02FOK('VEJ')",,,oWIN_TOPO3,aHeadVEJ,aColsVEJ )
	oGDVEJ:oBrowse:bChange := { || FG_MEMVAR(oGDVEJ:aHeader,oGDVEJ:aCols,oGDVEJ:nAt) , M->VE6_CODMAR := M->VEJ_CODMAR }
	oGDVEJ:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT


	////////////////////////////
	//   F O L D E R    0 4   //
	////////////////////////////

	oFWLayer4 := FWLayer():New()
	oFWLayer4:Init(oFolders:aDialogs[4],.F.)
	oFWLayer4:AddLine('WIN_TOPO',090,.F.) // Janela do Objeto do TOPO

	oWIN_TOPO4 := oFWLayer4:GetLinePanel('WIN_TOPO')

	oCposMSMGet := MsmGet():New(,,4,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,{000,000,100,100},/*aAlterEnch*/,/*nModelo*/,;
	/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oWIN_TOPO4,/*lF3*/,/*lMemoria*/,/*lColumn*/,/*caTela*/,;
	/*lNoFolder*/,/*lProperty*/,aCposMSMGet,/*aFolder*/,/*lCreate*/,/*lNoMDIStretch*/,/*cTela*/)
	oCposMSMGet:oBox:align := CONTROL_ALIGN_ALLCLIENT


	ACTIVATE MSDIALOG oOFAGCT02 ON INIT EnchoiceBar(oOFAGCT02,{ || IIf(OFAGCT02TOK(),oOFAGCT02:End(),.t.) }, { || oOFAGCT02:End() },,)

Return .T.


/*/{Protheus.doc} OFAGCT02HEAD
	Inicializacao dos aHeaders na tela

	@author Andre Luis Almeida
	@since  03/07/2017
/*/
Function OFAGCT02HEAD(cAlias)
Local aRet    := {}
Do Case
	Case cAlias == "XA1" // Clientes SA1
      	aAdd(aRet,{ STR0007 , "XA1_COD"    , "@!"                    , TamSX3("A1_COD")[1]     , 0 , "" , "" , "C" , "SA1"    , ""  , "" , "" } ) // Codigo
      	aAdd(aRet,{ STR0028 , "XA1_LOJA"   , "@!"                    , TamSX3("A1_LOJA")[1]    , 0 , "" , "" , "C" , ""       , ""  , "" , "" } ) // Loja
      	aAdd(aRet,{ STR0008 , "XA1_NOME"   , "@!"                    , TamSX3("A1_NOME")[1]    , 0 , "" , "" , "C" , ""       , "V" , "" , "" } ) // Nome
      	aAdd(aRet,{ STR0009 , "XA1_CGC"    , "@R 99.999.999/9999-99" , TamSX3("A1_CGC")[1]     , 0 , "" , "" , "C" , ""       , "V" , "" , "" } ) // CNPJ

	Case cAlias == "XA2" // Fornecedores SA2
      	aAdd(aRet,{ STR0007 , "XA2_COD"    , "@!"                    , TamSX3("A2_COD")[1]     , 0 , "" , "" , "C" , "SA2"    , ""  , "" , "" } ) // Codigo
      	aAdd(aRet,{ STR0028 , "XA2_LOJA"   , "@!"                    , TamSX3("A2_LOJA")[1]    , 0 , "" , "" , "C" , ""       , ""  , "" , "" } ) // Loja
      	aAdd(aRet,{ STR0008 , "XA2_NOME"   , "@!"                    , TamSX3("A2_NOME")[1]    , 0 , "" , "" , "C" , ""       , "V" , "" , "" } ) // Nome
      	aAdd(aRet,{ STR0009 , "XA2_CGC"    , "@R 99.999.999/9999-99" , TamSX3("A2_CGC")[1]     , 0 , "" , "" , "C" , ""       , "V" , "" , "" } ) // CNPJ

	Case cAlias == "SBM" // Grupos SBM
      	aAdd(aRet,{ STR0029 , "XBM_GRUPO"  , "@!"                    , TamSX3("BM_GRUPO")[1]   , 0 , "" , "" , "C" , "SBM"    , ""  , "" , "" } ) // Grupo
      	aAdd(aRet,{ STR0030 , "XBM_DESC"   , "@!"                    , TamSX3("BM_DESC")[1]    , 0 , "" , "" , "C" , ""       , "V" , "" , "" } ) // descricao

	Case cAlias == "VEJ" 
      	aAdd(aRet,{ STR0031 , "VEJ_FILIAL" , "@!"                    , TamSX3("VEJ_FILIAL")[1] , 0 , "" , "" , "C" , "SM0_01" , ""  , "" , "" } ) // Filial
      	aAdd(aRet,{ STR0032 , "VEJ_CODMAR" , "@!"                    , TamSX3("VEJ_CODMAR")[1] , 0 , "" , "" , "C" , "VE1"    , ""  , "" , "" } ) // Cod.Marca
      	aAdd(aRet,{ STR0015 , "VEJ_TIPMAQ" , "@!"                    , TamSX3("VEJ_TIPPED")[1] , 0 , "" , "" , "C" , "VEJ"    , ""  , "" , "" } ) // Maq.Parada
      	aAdd(aRet,{ STR0016 , "VEJ_TIPGAR" , "@!"                    , TamSX3("VEJ_TIPPED")[1] , 0 , "" , "" , "C" , "VEJ"    , ""  , "" , "" } ) // Gatantia
		aAdd(aRet,{ STR0017 , "VEJ_TIPREP" , "@!"                    , TamSX3("VEJ_TIPPED")[1] , 0 , "" , "" , "C" , "VEJ"    , ""  , "" , "" } ) // Estq.Repos.

EndCase
Return aClone(aRet)


/*/{Protheus.doc} OFAGCT02CPOS
	Campos a serem utilizados na Enchoice da aba Outros (aCposMSMGet)

	@author Andre Luis Almeida
	@since  04/07/2017
/*/
Function OFAGCT02CPOS(cAlias)
	Local aRet := {}
	Aadd(aRet,{ STR0020 ,"TMP_MOTVDP","C",06                  ,0,"",&('{ || OFAGCT02FOK("VMI") }'),.T.,1,"","VS0"   ,"",.F.,.F.,"",Val(""),.F.,"",""}) // Mot.Vda.Perd
	Aadd(aRet,{ STR0021 ,"TMP_VDANOR","C",06                  ,0,"",&('{ || OFAGCT02FOK("VMI") }'),.T.,1,"","V09"   ,"",.F.,.F.,"",Val(""),.F.,"",""}) // Vda.Anormal
	Aadd(aRet,{ STR0022 ,"TMP_FILMAT","C",FWSizeFilial()      ,0,"",&('{ || OFAGCT02FOK("VMI") }'),.T.,1,"","SM0_01","",.F.,.F.,"",Val(""),.F.,"",""}) // Matriz
	Aadd(aRet,{ STR0026 ,"TMP_FORPAD","C",TamSX3('A2_COD')[1] ,0,"",&('{ || OFAGCT02FOK("VMI") }'),.T.,1,"","SA2"   ,"",.F.,.F.,"",Val(""),.F.,"",""}) // Fornecedor Padrão
	Aadd(aRet,{ STR0027 ,"TMP_LOJPAD","C",TamSX3('A2_LOJA')[1],0,"",&('{ || OFAGCT02FOK("VMI") }'),.T.,1,"",""      ,"",.F.,.F.,"",Val(""),.F.,"",""}) // Loja Fornec.Padrão
	Aadd(aRet,{ STR0033 ,"TMP_DIAARM","C",5                   ,0,"",&('{ || OFAGCT02FOK("VMI") }'),.T.,1,"",""      ,"",.F.,.F.,"",Val(""),.F.,"",""}) // Qtde Dias Armazenar Dados
Return aClone(aRet)


/*/{Protheus.doc} OFAGCT02INI
	Carregar as Configuracoes Gravadas no JSON

	@author Andre Luis Almeida
	@since  04/07/2017
/*/
Function OFAGCT02INI()
Local ni      := 0
Local nj      := 0
Local nAux    := 0
Local aAux    := {}
Local oUtil   := DMS_Util():New()
Local oDados  := oUtil:ParamFileOpen(cFileName)
//Local aFilAtu := FWArrFilAtu()
//Local aSM0    := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
local aSM0 := FWLoadSm0()
Local aSM0Det := {}

For ni := 1 to len(aSM0)
	aSM0Det := aSM0[ni] // Filial Origem (Filial logada)
	aAdd(aListSM0,{.f.,aSM0Det[2],aSM0Det[7],aSM0Det[18],space(20),space(30)})
Next
aAux := oDados:GetValue("FILIAIS_AGCO", {})
For ni := 1 to len(aAux)
	nAux := aScan(aListSM0,{|x| x[2] == aAux[ni]:GetValue("FILIAL") })
	If nAux > 0
		aListSM0[nAux,1] := .t.
		aListSM0[nAux,5] := padr(aAux[ni]:GetValue("CODIGO_DO_USUARIO"),20," ")
		aListSM0[nAux,6] := padr(aAux[ni]:GetValue("SENHA_DO_USUARIO"),30," ")
	EndIf
Next
//
aAux := oDados:GetValue("CONCESSIONARIOS_DA_REDE", {})
For ni := 1 to len(aAux)
	If !Empty(aAux[ni])
		DbSelectArea("SA1")
		DbGoTo(val(aAux[ni]))
		aAdd(aColsSA1,Array(len(aHeadSA1)+1))
		For nj := 1 to len(aHeadSA1)
			aColsSA1[len(aColsSA1),FG_POSVAR(aHeadSA1[nj,2],"aHeadSA1")] := &("SA1->"+substr(aHeadSA1[nj,2],2))
		Next
		aColsSA1[len(aColsSA1),len(aHeadSA1)+1] := .f.
	EndIf
Next
//
aAux := oDados:GetValue("FORNECEDORES_AGCO", {})
For ni := 1 to len(aAux)
	If !Empty(aAux[ni])
		DbSelectArea("SA2")
		DbGoTo(val(aAux[ni]))
		aAdd(aColsSA2,Array(len(aHeadSA2)+1))
		For nj := 1 to len(aHeadSA2)
			aColsSA2[len(aColsSA2),FG_POSVAR(aHeadSA2[nj,2],"aHeadSA2")] := &("SA2->"+substr(aHeadSA2[nj,2],2))
		Next
		aColsSA2[len(aColsSA2),len(aHeadSA2)+1] := .f.
	EndIf
Next
//
aAux := oDados:GetValue("GRUPOS_ORIGINAIS", {})
For ni := 1 to len(aAux)
	If !Empty(aAux[ni])
		DbSelectArea("SBM")
		DbSetOrder(1)
		DbSeek(xFilial("SBM")+aAux[ni])
		aAdd(aColsSBM1,Array(len(aHeadSBM)+1))
		For nj := 1 to len(aHeadSBM)
			aColsSBM1[len(aColsSBM1),FG_POSVAR(aHeadSBM[nj,2],"aHeadSBM")] := &("SBM->"+substr(aHeadSBM[nj,2],2))
		Next
		aColsSBM1[len(aColsSBM1),len(aHeadSBM)+1] := .f.
	EndIf
Next
//
aAux := oDados:GetValue("GRUPOS_PARALELOS", {})
For ni := 1 to len(aAux)
	If !Empty(aAux[ni])
		DbSelectArea("SBM")
		DbSetOrder(1)
		DbSeek(xFilial("SBM")+aAux[ni])
		aAdd(aColsSBM2,Array(len(aHeadSBM)+1))
		For nj := 1 to len(aHeadSBM)
			aColsSBM2[len(aColsSBM2),FG_POSVAR(aHeadSBM[nj,2],"aHeadSBM")] := &("SBM->"+substr(aHeadSBM[nj,2],2))
		Next
		aColsSBM2[len(aColsSBM2),len(aHeadSBM)+1] := .f.
	EndIf
Next
//
aAux := oDados:GetValue("TIPOS_DE_PEDIDOS", {})
For ni := 1 to len(aAux)
	aAdd(aColsVEJ,Array(len(aHeadVEJ)+1))
	aColsVEJ[len(aColsVEJ),FG_POSVAR("VEJ_FILIAL","aHeadVEJ")] := aAux[ni]:GetValue("FILIAL")
	aColsVEJ[len(aColsVEJ),FG_POSVAR("VEJ_CODMAR","aHeadVEJ")] := aAux[ni]:GetValue("MARCA")
	aColsVEJ[len(aColsVEJ),FG_POSVAR("VEJ_TIPMAQ","aHeadVEJ")] := aAux[ni]:GetValue("TIPO_MAQUINA_PARADA")
	aColsVEJ[len(aColsVEJ),FG_POSVAR("VEJ_TIPGAR","aHeadVEJ")] := aAux[ni]:GetValue("TIPO_GARANTIA")
	aColsVEJ[len(aColsVEJ),FG_POSVAR("VEJ_TIPREP","aHeadVEJ")] := aAux[ni]:GetValue("TIPO_ESTOQUE_REPOSICAO")
	aColsVEJ[len(aColsVEJ),len(aHeadVEJ)+1] := .f.
Next
//
M->TMP_MOTVDP := padr(oDados:GetValue("MOTIVO_VENDA_PERDIDA",""),06)					// MOTIVO_VENDA_PERDIDA
M->TMP_VDANOR := padr(oDados:GetValue("SITUACAO_VENDA_ANORMAL",""),06)					// SITUACAO_VENDA_ANORMAL
M->TMP_FILMAT := padr(oDados:GetValue("FILIAL_MATRIZ",""),FWSizeFilial())				// FILIAL_MATRIZ
M->TMP_FORPAD := padr(oDados:GetValue("CODIGO_FORNECEDOR_PADRAO"), TamSX3('A2_COD')[1])	// FORNECEDOR PADRAO
M->TMP_LOJPAD := padr(oDados:GetValue("LOJA_FORNECEDOR_PADRAO"), TamSX3('A2_LOJA')[1]) 	// LOJA FORNECEDOR PADRAO
M->TMP_DIAARM := padr(oDados:GetValue("QTD_DIAS_ARMAZENAR"),5)							// QTD DIAS ARMAZENAR DADOS
If M->TMP_DIAARM == Nil // Parametro Novo
	M->TMP_DIAARM := "99999"
EndIf
//
Return


/*/{Protheus.doc} OFAGCT02FOK
	Field OK das aCols

	@author Andre Luis Almeida
	@since  03/07/2017
/*/
Function OFAGCT02FOK(cAlias)
Local lRet     := .t.
Local cAX      := ""
//
Do Case

	Case cAlias == "SA1" .or. cAlias == "SA2"
		cAX := "X"+right(cAlias,2) // A1 / A2
		If ReadVar() == ('M->'+cAX+'_COD')
			If Empty(&('M->'+cAX+'_COD'))
				&('M->'+cAX+'_LOJA := oGD'+cAlias+':aCols[oGD'+cAlias+':nAt,FG_POSVAR("'+cAX+'_LOJA","aHead'+cAlias+'")] := ""')
				&('M->'+cAX+'_NOME := oGD'+cAlias+':aCols[oGD'+cAlias+':nAt,FG_POSVAR("'+cAX+'_NOME","aHead'+cAlias+'")] := ""')
				&('M->'+cAX+'_CGC  := oGD'+cAlias+':aCols[oGD'+cAlias+':nAt,FG_POSVAR("'+cAX+'_CGC" ,"aHead'+cAlias+'")] := ""')
				Return .t.
			Else
				If &(cAlias+'->'+right(cAlias,2)+'_COD == M->'+cAX+'_COD')
					&('oGD'+cAlias+':aCols[oGD'+cAlias+':nAt,FG_POSVAR("'+cAX+'_LOJA","aHead'+cAlias+'")] := '+cAlias+'->'+right(cAlias,2)+'_LOJA')
				EndIf
				DbSelectArea(cAlias)
				DbSetOrder(1)
				If !DbSeek( xFilial(cAlias) + &('M->'+cAX+'_COD + oGD'+cAlias+':aCols[oGD'+cAlias+':nAt,FG_POSVAR("'+cAX+'_LOJA","aHead'+cAlias+'")]') )
					If !DbSeek( xFilial(cAlias) + &('M->'+cAX+'_COD') )
						lRet := .f.
					EndIf
				EndIf
			EndIf
		ElseIf ReadVar() == ('M->'+cAX+'_LOJA')
			DbSelectArea(cAlias)
			DbSetOrder(1)
			If !DbSeek( xFilial(cAlias) + &('oGD'+cAlias+':aCols[oGD'+cAlias+':nAt,FG_POSVAR("'+cAX+'_COD","aHead'+cAlias+'")] + M->'+cAX+'_LOJA') )
				lRet := .f.
			EndIf
		EndIf
		If lRet
			&('M->'+cAX+'_LOJA := oGD'+cAlias+':aCols[oGD'+cAlias+':nAt,FG_POSVAR("'+cAX+'_LOJA","aHead'+cAlias+'")] := '+cAlias+'->'+right(cAlias,2)+'_LOJA')
			&('M->'+cAX+'_NOME := oGD'+cAlias+':aCols[oGD'+cAlias+':nAt,FG_POSVAR("'+cAX+'_NOME","aHead'+cAlias+'")] := '+cAlias+'->'+right(cAlias,2)+'_NOME')
			&('M->'+cAX+'_CGC  := oGD'+cAlias+':aCols[oGD'+cAlias+':nAt,FG_POSVAR("'+cAX+'_CGC" ,"aHead'+cAlias+'")] := '+cAlias+'->'+right(cAlias,2)+'_CGC')
		Else
			&('M->'+cAX+'_LOJA := oGD'+cAlias+':aCols[oGD'+cAlias+':nAt,FG_POSVAR("'+cAX+'_LOJA","aHead'+cAlias+'")] := ""')
			&('M->'+cAX+'_NOME := oGD'+cAlias+':aCols[oGD'+cAlias+':nAt,FG_POSVAR("'+cAX+'_NOME","aHead'+cAlias+'")] := ""')
			&('M->'+cAX+'_CGC  := oGD'+cAlias+':aCols[oGD'+cAlias+':nAt,FG_POSVAR("'+cAX+'_CGC" ,"aHead'+cAlias+'")] := ""')
		EndIf


	Case left(cAlias,3) == "SBM"
		If !Empty(M->XBM_GRUPO)
			DbSelectArea("SBM")
			DbSetOrder(1)
			If !DbSeek( xFilial("SBM") + M->XBM_GRUPO )
				lRet := .f.
			EndIf
		EndIf
		If lRet .and. !Empty(M->XBM_GRUPO)
			M->XBM_DESC := &('oGD'+cAlias+':aCols[oGD'+cAlias+':nAt,FG_POSVAR("XBM_DESC","aHeadSBM")]') := SBM->BM_DESC
		Else
			M->XBM_DESC := &('oGD'+cAlias+':aCols[oGD'+cAlias+':nAt,FG_POSVAR("XBM_DESC","aHeadSBM")]') := ""
		EndIf


	Case cAlias == "VEJ"
		If ReadVar() == 'M->VEJ_CODMAR'
			M->VE6_CODMAR := M->VEJ_CODMAR
		EndIf
          

	Case cAlias == "VMI"
		If ReadVar() == 'M->TMP_FORPAD'
			If !Empty(M->TMP_FORPAD)
				DbSelectArea("SA2")
				DbSetOrder(1)
				If M->TMP_FORPAD <> SA2->A2_COD
					If DbSeek( xFilial("SA2") + M->TMP_FORPAD )
						M->TMP_LOJPAD := SA2->A2_LOJA
					Else
						lRet := .f.
					EndIf
				Else
					M->TMP_LOJPAD := SA2->A2_LOJA
				EndIf
			EndIf
		ElseIf ReadVar() == 'M->TMP_LOJPAD'
			If !Empty(M->TMP_LOJPAD)
				DbSelectArea("SA2")
				DbSetOrder(1)
				If !DbSeek( xFilial("SA2") + M->TMP_FORPAD + M->TMP_LOJPAD )
					lRet := .f.
				EndIf
			EndIf
		ElseIf ReadVar() == 'M->TMP_DIAARM'
			If val(M->TMP_DIAARM) < 30 .or. val(M->TMP_DIAARM) > 99999
				lRet := .f.
			EndIf
		EndIf

EndCase
//
Return lRet



/*/{Protheus.doc} OFAGCT02LOK
	Linha OK das aCols

	@author Andre Luis Almeida
	@since  03/07/2017
/*/
Function OFAGCT02LOK(cAlias)
Local lRet := .t.
//
If oFolders:nOption == 3 // Tipos de Pedido
	If !oGDVEJ:aCols[oGDVEJ:nAt,len(oGDVEJ:aCols[oGDVEJ:nAt])]
		If 	Empty(oGDVEJ:aCols[oGDVEJ:nAt,FG_POSVAR("VEJ_TIPMAQ","oGDVEJ:aHeader")]) .or. ;
			Empty(oGDVEJ:aCols[oGDVEJ:nAt,FG_POSVAR("VEJ_TIPGAR","oGDVEJ:aHeader")]) .or. ;
			Empty(oGDVEJ:aCols[oGDVEJ:nAt,FG_POSVAR("VEJ_TIPREP","oGDVEJ:aHeader")])
			MsgStop(STR0024,STR0023) // Necessario informar todos os Tipos de Pedidos (Pasta: Pedidos) / Atencao
			lRet := .f.
		EndIf
	EndIf
EndIf
//
Return lRet



/*/{Protheus.doc} OFAGCT02TOK
	Tudo OK da rotina

	@author Andre Luis Almeida
	@since  04/07/2017
/*/
Function OFAGCT02TOK()
Local ni := 0
Local lRet := .t.
//
For ni := 1 to len(oGDVEJ:aCols)
	If !oGDVEJ:aCols[ni,len(oGDVEJ:aCols[ni])]
		If 	Empty(oGDVEJ:aCols[ni,FG_POSVAR("VEJ_TIPMAQ","aHeadVEJ")]) .or. ;
			Empty(oGDVEJ:aCols[ni,FG_POSVAR("VEJ_TIPGAR","aHeadVEJ")]) .or. ;
			Empty(oGDVEJ:aCols[ni,FG_POSVAR("VEJ_TIPREP","aHeadVEJ")])
			MsgStop(STR0024,STR0023) // Necessario informar todos os Tipos de Pedidos (Pasta: Pedidos) / Atencao
			lRet := .f.
			Exit
		EndIf
	EndIf
Next
If lRet
	For ni := 1 to len(aCposMSMGet)
		If Empty(&("M->"+aCposMSMGet[ni,2]))
			Help(" ",1,"OBRIGAT",,aCposMSMGet[ni,1]+" "+STR0025 ,4,1 ) // (Pasta: Outros)
			lRet := .f.
			Exit
		EndIf
	Next
EndIf
If lRet
	OFAGCT02GRV() // GRAVAR
EndIf
//
Return lRet



/*/{Protheus.doc} OFAGCT02GRV
	Gravacao da rotina

	@author Andre Luis Almeida
	@since  04/07/2017
/*/
Function OFAGCT02GRV()
	Local aDados := {;
				{"FILIAIS_AGCO"             , {} },;
				{"CONCESSIONARIOS_DA_REDE"  , {} },;
				{"FORNECEDORES_AGCO"        , {} },;
				{"GRUPOS_ORIGINAIS"         , {} },;
				{"GRUPOS_PARALELOS"         , {} },;
				{"TIPOS_DE_PEDIDOS"         , {} },;
				{"MOTIVO_VENDA_PERDIDA"     , "" },;
				{"SITUACAO_VENDA_ANORMAL"   , "" },;
				{"FILIAL_MATRIZ"            , "" },;
				{"CNPJ_MATRIZ"              , "" },;
				{"CODIGO_FORNECEDOR_PADRAO" , "" },;
				{"LOJA_FORNECEDOR_PADRAO"   , "" },;
				{"DOC_FORNECEDOR_PADRAO"    , "" },;
				{"QTD_DIAS_ARMAZENAR"       , "99999" } ;
				}
	Local ni        := 0
	Local aSM0Det   := {}
	Local oUtil     := DMS_Util():New()
	Local oDados
	Local oAux
	Local aFilis := {}
	// FILIAIS AGCO //
	For ni := 1 to len(aListSM0)
		If aListSM0[ni,1]
			oAux := DMS_DataContainer():NEW( {;
				{"FILIAL"                 , aListSM0[ni,2] },;
				{"CNPJ"                   , aListSM0[ni,4] },;
				{"CODIGO_DO_USUARIO"      , aListSM0[ni,5] },;
				{"SENHA_DO_USUARIO"       , aListSM0[ni,6] } ;
				} )
			aAdd(aDados[01,2],oAux)
			aAdd(aFilis,aListSM0[ni,2])
		EndIf
	Next
	// CONCESSIONARIOS DA REDE //
	For ni := 1 to len(oGDSA1:aCols)
		If !oGDSA1:aCols[ni,len(oGDSA1:aCols[ni])]
			DbSelectArea("SA1")
			DbSetOrder(1)
			If DbSeek( xFilial("SA1") + oGDSA1:aCols[ni,FG_POSVAR("XA1_COD","aHeadSA1")] + oGDSA1:aCols[ni,FG_POSVAR("XA1_LOJA","aHeadSA1")] )
				aAdd(aDados[02,2],Alltrim(str(SA1->(RecNo()))))
			EndIf
		EndIf
	Next
	// FORNECEDORES //
	For ni := 1 to len(oGDSA2:aCols)
		If !oGDSA2:aCols[ni,len(oGDSA2:aCols[ni])]
			DbSelectArea("SA2")
			DbSetOrder(1)
			If DbSeek( xFilial("SA2") + oGDSA2:aCols[ni,FG_POSVAR("XA2_COD","aHeadSA2")] + oGDSA2:aCols[ni,FG_POSVAR("XA2_LOJA","aHeadSA2")] )
				aAdd(aDados[03,2],Alltrim(str(SA2->(RecNo()))))
			EndIf
		EndIf
	Next
	// GRUPOS ORIGINAIS //
	For ni := 1 to len(oGDSBM1:aCols)
		If !oGDSBM1:aCols[ni,len(oGDSBM1:aCols[ni])]
			aAdd(aDados[04,2],oGDSBM1:aCols[ni,FG_POSVAR("XBM_GRUPO","aHeadSBM")])
		EndIf
	Next
	// GRUPOS PARALELOS //
	For ni := 1 to len(oGDSBM2:aCols)
		If !oGDSBM2:aCols[ni,len(oGDSBM2:aCols[ni])]
			aAdd(aDados[05,2],oGDSBM2:aCols[ni,FG_POSVAR("XBM_GRUPO","aHeadSBM")])
		EndIf
	Next
	// TIPOS DE PEDIDOS //
	For ni := 1 to len(oGDVEJ:aCols)
		If !oGDVEJ:aCols[ni,len(oGDVEJ:aCols[ni])]
			oAux := DMS_DataContainer():NEW( {;
				{"FILIAL"                 , oGDVEJ:aCols[ni,FG_POSVAR("VEJ_FILIAL","aHeadVEJ")] },;
				{"MARCA"                  , oGDVEJ:aCols[ni,FG_POSVAR("VEJ_CODMAR","aHeadVEJ")] },;
				{"TIPO_MAQUINA_PARADA"    , oGDVEJ:aCols[ni,FG_POSVAR("VEJ_TIPMAQ","aHeadVEJ")] },;
				{"TIPO_GARANTIA"          , oGDVEJ:aCols[ni,FG_POSVAR("VEJ_TIPGAR","aHeadVEJ")] },;
				{"TIPO_ESTOQUE_REPOSICAO" , oGDVEJ:aCols[ni,FG_POSVAR("VEJ_TIPREP","aHeadVEJ")] } ;
				} )
			aAdd(aDados[06,2],oAux)
		EndIf
	Next
	// CAMPOS //
	aDados[07,2] := M->TMP_MOTVDP // MOTIVO_VENDA_PERDIDA
	aDados[08,2] := M->TMP_VDANOR // SITUACAO_VENDA_ANORMAL
	aDados[09,2] := M->TMP_FILMAT // FILIAL_MATRIZ
	If !Empty(aDados[09,2])
		aSM0Det := FWArrFilAtu(cEmpAnt,aDados[09,2])
		If len(aSM0Det) >= 18
			aDados[10,2] := aSM0Det[18] // CNPJ_MATRIZ
		EndIf
	EndIf

	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(xFilial("SA2") + M->TMP_FORPAD + M->TMP_LOJPAD )
	aDados[11,2] := M->TMP_FORPAD // Fornecedor padrao
	aDados[12,2] := M->TMP_LOJPAD // Loja Fornecedor padrao
	aDados[13,2] := SA2->A2_CGC // CNPJ Fornecedor padrao
	aDados[14,2] := M->TMP_DIAARM // Qtde de Dias Armazenar Dados

	oDados := DMS_DataContainer():NEW( aDados )
	oUtil:ParamFileSave(cFileName,oDados)

	// Grava dados de delimitação da inicialização do VMI para separar
	oVmi := OFAGVmi():New()
	oVmi:oVmiParametros:DelimitaInit(aFilis)
Return .T.



/*/{Protheus.doc} OFAGCT02DBL
	Duplo-Clique no ListBox de Filiais ( inserir USUARIO / SENHA para acessar AGCO )

	@author Andre Luis Almeida
	@since  18/07/2019
/*/
Static Function OFAGCT02DBL()
	Local aParamBox := {}
	Local aRetParam := {}
	aListSM0[oListSM0:nAt,01] := !aListSM0[oListSM0:nAt,01]
	If aListSM0[oListSM0:nAt,01]
		AADD( aParamBox , { 1 , STR0018 , aListSM0[oListSM0:nAt,05] , "" , "" , "" , "" , 50 , .T.}) // Usuario
		AADD( aParamBox , { 1 , STR0003 , aListSM0[oListSM0:nAt,06] , "" , "" , "" , "" , 50 , .T.}) // Senha
		If ParamBox(aParamBox,aListSM0[oListSM0:nAt,02] + "-" +aListSM0[oListSM0:nAt,03],@aRetParam,,,,,,,,.f.)
			aListSM0[oListSM0:nAt,05] := aRetParam[1] // Usuario
			aListSM0[oListSM0:nAt,06] := aRetParam[2] // Senha
		Else
			aListSM0[oListSM0:nAt,01] := .f.
		EndIf
	EndIf
Return
