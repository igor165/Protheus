#INCLUDE "FWMVCDEF.CH"                 
#Include "PROTHEUS.ch"
#Include "TMSA010.ch"

Static lTMA010His := ExistBlock("TMA010HIS")
Static l010TudOk
Static aTabINC
Static aCompTab
Static cCatTab
Static cCadDesc
Static lTRT		:= AliasInDic("DJS")
Static aCheck	:= {}

/*/-----------------------------------------------------------
{Protheus.doc} TMSA010A()
Cadastro de Tabela de Frete - MVC

Uso: SIGATMS

@sample
//TMSA010A()

@author Daniel Leme.
@since 06/09/2013
@version 1.0
-----------------------------------------------------------/*/
Function TMSA010A(nRotina, cCad, cCateg)
Local aArea	:= GetArea()
Local oBrowse	:= Nil
Local cFilUsr    := ""
Local cFilMbrow := ""

//-- Salva Ambiente anterior
SaveInter()

Private aRotina := MenuDef()

Default cCateg    := StrZero(1, Len(DTL->DTL_CATTAB)) //-- Frete a Receber
Default cCad      := STR0001 //-- "Tabela de Frete"

cCatTab  := cCateg
cCadDesc := cCad

//-- Variavel utilizada na estrutura
cCadastro := cCad

If nRotina != Nil
	FWExecView(Iif(nRotina==3,STR0004,IIf(nRotina==4,STR0005,STR0003)),"VIEWDEF.TMSA010", Iif(nRotina==3,MODEL_OPERATION_INSERT,IIf(nRotina==4,MODEL_OPERATION_UPDATE,MODEL_OPERATION_VIEW)),, { || .T. } ,,  /*nPerReducTela*/ ) //"Incluir"##"Alterar"##"Visualizar"
Else
	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias("DT0")
	oBrowse:SetDescription(cCadDesc)
	
	cFilMbrow := "DT0_FILIAL == '" + xFilial("DT0") + "' .And. DT0_CATTAB == '" + cCatTab + "'"
	If ExistBlock("TM010BRW") //-- PE - Permite ao usuario filtrar a mbrowse
		cFilUsr := ExecBlock("TM010BRW",.F.,.F.)
		If ValType(cFilUsr) == "C" .And. !Empty(cFilUsr)
			cFilMbrow += " .And. ("+cFilUsr+")"
		EndIf
	EndIf
	oBrowse:SetFilterDefault( cFilMbrow ) 

	oBrowse:SetCacheView(.F.) //-- Desabilita Cache da View, pois gera colunas dinamicamente
	oBrowse:Activate()
EndIf

RestInter()
RestArea(aArea)

Return Nil

/*/{Protheus.doc} TMSA010AInc
(long_description)
@author MOHAMED S B DJALO
@since 15/06/2016
@version P12107
@example Esta fun��o foi criada para substituir a chamada padr�o de incluir no menudef. 
         Isto porque antes quando o usu�rio clicava para incluir um novo registro, abria uma nova
         tela para selecionar as configura��es da tabela de frete. E, caso o usu�rio optar por 
		 cancelar esta tela, o sistema abria a tela de inclus�o de valores. A fun��o TMSA010AInc 
		 foi criada justamente para tratar esse erro ou seja ao clicar para cancelar a opera��o
		 de inclus�o, o sistema n�o deveria abrir a tela de inclus�o. A fun��o TMSA010AInc so 
		 permite abrir a tela de inclus�o de valores se e somente se o TMSABrowse que constroi a 
		 tela de configura��es de tabela de frete retornar verdadeiro.  
(examples)
@see (links_or_references)
/*/
Function TMSA010AInc()
	aLayOut := TMSLayOutTab(cCatTab, .T.,,{"15"})
	If TMSABrowse( aLayOut, STR0020,,,,.T., { STR0001, STR0021, STR0058 } ) //"Escolha a Configuracao desta Tabela de Frete"###"Tabela de Frete"###"Tipo"###"Descricao" 
		FWExecView('','TMSA010', MODEL_OPERATION_INSERT, , /*{ || .T. }*/, , ,/*aButtons*/ )
	EndIf
Return

/*/{Protheus.doc} ModelDef
	
@author Daniel
@since 22/11/2013
@version 1.0
		
@param ${nenhum}, ${Nil}

@return ${oModel}, ${Modelo de Dados MVC}

@description

Modelo de dados MVC

/*/
Static Function ModelDef()

Local oModel	:= Nil
Local oStruCDT0 := Nil
Local oStruIDTK := Nil
Local oStruIDVY := Nil

Local aStruIDT1 	:= {} 
Local aStruIDW1 	:= {}
Local aStruIDY1 	:= {}
Local aStruDJS		:= {}

Local nCnt
Local lTDA := .F.
Local nAuxTrt		:= 0

// Validação do Modelo
Local bPosValid := { |oModel| PosVldMdl(oModel) }

// Validacoes da Grid
Local bLnPostDT1	:= { |oModel| PosVldLine(oModel,"DT1") }
Local bLnPostDW1	:= { |oModel| PosVldLine(oModel,"DW1") }
Local bLnPostDY1	:= { |oModel| PosVldLine(oModel,"DY1") }

//-- Variáveis utilizadas para a pesquisa de regiões superiores
Local cCdrOri
Local cCdrDes
Local cTabTar
Local aMsgErr
Local aTrt		:= {}

//-- Executado a partir do Mile
Local lMile      	:= IsInCallStack("CFG600LMdl") .Or. IsInCallStack("FWMILEIMPORT") .Or. IsInCallStack("FWMILEEXPORT") .Or. IsInCallStack("MileDOperation")
Local aArea := GetArea()
Local cValorIni   := Repl('9',((TamSx3("DT1_VALATE")[1]-1)-TamSx3("DT1_VALATE")[2]))+"."+Repl('9',TamSx3("DT1_VALATE")[2])
Local cFatPes     := Repl('9',((TamSx3("DT1_FATPES")[1]-1)-TamSx3("DT1_FATPES")[2]))+"."+Repl('9',TamSx3("DT1_FATPES")[2])
Local aM5			:= {}
Local cDesTip		:= ""

Default cCatTab  := StrZero(1, Len(DTL->DTL_CATTAB)) //-- Frete a Receber
Default cCadDesc := STR0001 //-- "Tabela de Frete"


oStruCDT0 := FwFormStruct( 1, "DT0") 
oStruIDTK := FwFormStruct( 1, "DTK")
oStruIDVY := FwFormStruct( 1, "DVY")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Configuracao da Tabela          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lMile
	aTabINC 	:= {}
EndIf
aCompTab 	:= {}

If !lMile .And. !Inclui
	aCompTab := TMA010Comp( DT0->DT0_TABFRE, DT0->DT0_TIPTAB )
ElseIf !lMile
	nLoop := Ascan( aLayOut, { |aItem| aItem[1] == .T. } )
	aTabINC := { Left( aLayOut[ nLoop ][2], Len( DT0->DT0_TABFRE) ), Left( aLayOut[ nLoop ][3], Len(DT0->DT0_TIPTAB) ) }
	aCompTab := TMA010Comp( aTabINC[1], aTabINC[2] )
	aM5 := FWGetSX5("M5", aTabINC[2])
	If ValType(aM5) == "A" .And. Len(aM5) > 0
		cDesTip := aM5[1][4]
	EndIf

	oStruCDT0:SetProperty( "DT0_TABFRE", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'"+ aTabINC[1]+"'" )  )
	oStruCDT0:SetProperty( "DT0_TIPTAB", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'"+ aTabINC[2]+"'" )  )
	oStruCDT0:SetProperty( "DT0_DESTIP", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'"+ PadR(cDesTip,TamSx3("DT0_DESTIP")[1])+"'")  )
	oStruCDT0:SetProperty( "DT0_CATTAB", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'"+ cCatTab+"'" )  )
	oStruCDT0:SetProperty( "DT0_DESTAB", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'"+ Left( aLayOut[ nLoop ][4], Len( DTL->DTL_DESCRI))+"'" )  )	
ElseIf lMile .And. ValType(aTabInc) == "A" .And. Len(aTabInc) == 2
		aCompTab := TMA010Comp( aTabINC[1], aTabINC[2] )
		aM5 := FWGetSX5("M5", aTabINC[2])
		If ValType(aM5) == "A" .And. Len(aM5) > 0
			cDesTip := aM5[1][4]
		EndIf

		oStruCDT0:SetProperty( "DT0_TABFRE", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'"+ aTabINC[1]+"'" )  )
		oStruCDT0:SetProperty( "DT0_TIPTAB", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'"+ aTabINC[2]+"'" )  )
		oStruCDT0:SetProperty( "DT0_DESTIP", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'"+ PadR(cDesTip,TamSx3("DT0_DESTIP")[1])+"'")  )
		oStruCDT0:SetProperty( "DT0_CATTAB", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'"+ cCatTab+"'" )  )
		oStruCDT0:SetProperty( "DT0_DESTAB", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'"+ Left( aLayOut[ nLoop ][4], Len( DTL->DTL_DESCRI))+"'" )  )
EndIf

oModel := MPFormModel():New( "TMSA010",/*bPre*/,bPosValid/*bPos*/, {|oModel| TMA010Comm(oModel)}/*bCommit*/, /*bCancel*/ )
oModel:SetDescription(cCadDesc) 	//-- "Tabela de Frete"

//-- Cabeçalho da Tabela de Frete
oModel:AddFields( "MdFieldCDT0", /*cOwner*/, oStruCDT0,/*bPre*/,/*bPost*/,/*bLoad*/ )

//-- Complemento da Tabela de Frete
oModel:AddGrid("GdDTK", "MdFieldCDT0" /*cOwner*/, oStruIDTK , /*bLinePre*/ , /*bLinePost*/ , /*bPre*/ , /*bPost*/,  /*bLoad*/)
oModel:SetRelation( "GdDTK", {	{"DTK_FILIAL","xFilial('DTK')"  }, ;
										{"DTK_TABFRE","DT0_TABFRE"},;
										{"DTK_TIPTAB","DT0_TIPTAB"},;
										{"DTK_CDRORI","DT0_CDRORI"},;
										{"DTK_CDRDES","DT0_CDRDES"},;
										{"DTK_CODPRO","DT0_CODPRO"}}, DTK->( IndexKey( 1 ) ) )

oModel:SetOptional( "GdDTK", .T. )

oModel:GetModel("GdDTK"):SetUseOldGrid()

For nCnt := 1 To Len(aCompTab)
	DT3->(DbGoTo(aCompTab[nCnt][3]))

	lTDA := lTDA .Or. DT3->DT3_TIPFAI == StrZero(13,Len(DT3->DT3_TIPFAI))
	
	If DT3->DT3_TIPFAI == StrZero(14,Len(DT3->DT3_TIPFAI))
		Aadd( aTrt , aCompTab[nCnt] )
	EndIf
	
	aAdd(aStruIDT1,Nil)	 
	aAdd(aStruIDW1,Nil)	 
	aAdd(aStruIDY1,Nil)	 

	aStruIDT1[nCnt] := FWFormStruct(1,"DT1")
	
	aStruIDT1[nCnt]:SetProperty( "DT1_CODPAS", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'"+aCompTab[ nCnt, 1 ]+"'" )  )
	If Posicione("DT3", 1, xFilial("DT3")+aCompTab[nCnt][1], "DT3->DT3_TIPFAI" ) == '17' //Taxa Devedor por Lote 
		aStruIDT1[nCnt]:SetProperty( "DT1_VALATE", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, cValorIni   ))
		aStruIDT1[nCnt]:SetProperty( "DT1_FATPES", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, cFatPes   ))
	EndIf	
	oModel:AddGrid( "GdDT1_"+aCompTab[ nCnt, 1 ], "MdFieldCDT0" /*cOwner*/, aStruIDT1[nCnt], /*bLinePre*/ , bLnPostDT1 /*bLinePost*/ , /*bPre*/ , /*bPost*/,  /*bLoad*/) 
	oModel:SetRelation( "GdDT1_"+aCompTab[ nCnt, 1 ], {	{"DT1_FILIAL","xFilial('DT1')"}, ;
											{"DT1_TABFRE","DT0_TABFRE"},;
											{"DT1_TIPTAB","DT0_TIPTAB"},;
											{"DT1_CDRORI","DT0_CDRORI"},;
											{"DT1_CDRDES","DT0_CDRDES"},;
											{"DT1_CODPRO","DT0_CODPRO"},;
											{"DT1_CODPAS","'"+aCompTab[ nCnt, 1 ]+"'"}}, DT1->( IndexKey( 1 ) ) )
	oModel:SetOptional( "GdDT1_"+aCompTab[ nCnt, 1 ], .T. )
	
	oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):SetUseOldGrid()
	
	If !lMile .And. !Inclui .And. !Altera
		cCdrOri := DT0->DT0_CDRORI
		cCdrDes := DT0->DT0_CDRDES
		cTabTar := DT0->DT0_TABTAR
		aMsgErr := {}
		If !DT1->( MsSeek( xFilial("DT1") + DT0->(DT0_TABFRE + DT0_TIPTAB + DT0_CDRORI + DT0_CDRDES + DT0_CODPRO) + aCompTab[ nCnt, 1 ] ) ) .And. ;
			!DTG->(MsSeek(xFilial("DTG") + DT0->(DT0_TABFRE + DT0_TIPTAB + DT0_TABTAR) + aCompTab[ nCnt, 1 ]))
			// Se Nao Encontrou o Componente na Tabela Mae, procura nas Regioes Superiores.
			// Isto porque, existem componentes que, ao inves, de serem Cadastrados para todas
			// as Regioes, sao cadastrados apenas para a "Regiao Pai".Sao chamadas de Taxas Estaduais.
			If TmsTabela( aMsgErr, DT0->DT0_TABFRE, DT0->DT0_TIPTAB, , @cCdrOri, @cCdrDes , , , DT0->DT0_CODPRO, , @cTabTar, DT3->DT3_TAXA, aCompTab[ nCnt, 1 ], DT3->DT3_PSQTXA )
				oModel:SetRelation( "GdDT1_"+aCompTab[ nCnt, 1 ], {	{"DT1_FILIAL","xFilial('DT1')"}, ;
														{"DT1_TABFRE","DT0_TABFRE"},;
														{"DT1_TIPTAB","DT0_TIPTAB"},;
														{"DT1_CDRORI","'"+cCdrOri+"'"},;
														{"DT1_CDRDES","'"+cCdrDes+"'"},;
														{"DT1_CODPRO","DT0_CODPRO"},;
														{"DT1_CODPAS","'"+aCompTab[ nCnt, 1 ]+"'"}}, DT1->( IndexKey( 1 ) ) )

				oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):SetOnlyQuery( .T. )
				oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):SetNoInsertLine( .T. )
				oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):SetNoUpdateLine( .T. )
				oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):SetNoDeleteLine( .T. )
				aCompTab[ nCnt][4] := cCdrOri
				aCompTab[ nCnt][5] := cCdrDes
			EndIf

			If !Empty( aMsgErr )
				TmsMsgErr( aMsgErr )
				Loop
			EndIf
		EndIf
	EndIf
	
	//-- Qdo utilizar sub-faixa, mostra grid de sub-faixa e complemento da sub-faixa
	If !Empty(DT3->DT3_FAIXA2)
		aStruIDW1[nCnt] := FwFormStruct( 1, "DW1")
		aStruIDY1[nCnt] := FwFormStruct( 1, "DY1")

		oModel:AddGrid( "GdDW1_"+aCompTab[ nCnt, 1 ], "GdDT1_"+aCompTab[ nCnt, 1 ] /*cOwner*/, aStruIDW1[nCnt], /*bLinePre*/ ,bLnPostDW1 /*bLinePost*/ , /*bPre*/ , /*bPost*/,  /*bLoad*/) 
		//-- DW1_FILIAL+DW1_TABFRE+DW1_TIPTAB+DW1_CDRORI+DW1_CDRDES+DW1_CODPRO+DW1_CODPAS+DW1_ITEDT1+DW1_ITEM
		oModel:SetRelation( "GdDW1_"+aCompTab[ nCnt, 1 ], {	{"DW1_FILIAL","xFilial('DW1')"}, ;
												{"DW1_TABFRE","DT0_TABFRE"},;
												{"DW1_TIPTAB","DT0_TIPTAB"},;
												{"DW1_CDRORI","DT0_CDRORI"},;
												{"DW1_CDRDES","DT0_CDRDES"},;
												{"DW1_CODPRO","DT0_CODPRO"},;
												{"DW1_CODPAS","'"+aCompTab[ nCnt, 1 ]+"'"},;
												{"DW1_ITEDT1","TMA010AGet('GdDT1_"+aCompTab[ nCnt, 1 ]+"','DT1_ITEM')"}}, DW1->( IndexKey( 1 ) ) )
												//{"DW1_ITEDT1","DT1_ITEM"}}, DW1->( IndexKey( 1 ) ) )
		
		//-- Se buscou tabela de região superior, apenas consulta sub-faixa
		If !Empty(aCompTab[ nCnt][4])
			oModel:SetRelation( "GdDW1_"+aCompTab[ nCnt, 1 ], {	{"DW1_FILIAL","xFilial('DW1')"}, ;
													{"DW1_TABFRE","DT0_TABFRE"},;
													{"DW1_TIPTAB","DT0_TIPTAB"},;
													{"DW1_CDRORI","'"+cCdrOri+"'"},;
													{"DW1_CDRDES","'"+cCdrDes+"'"},;
													{"DW1_CODPRO","DT0_CODPRO"},;
													{"DW1_CODPAS","'"+aCompTab[ nCnt, 1 ]+"'"},;
													{"DW1_ITEDT1","TMA010AGet('GdDT1_"+aCompTab[ nCnt, 1 ]+"','DT1_ITEM')"}}, DW1->( IndexKey( 1 ) ) )
													//{"DW1_ITEDT1","DT1_ITEM"}}, DW1->( IndexKey( 1 ) ) )
	
			oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):SetOnlyQuery( .T. )
			oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):SetNoInsertLine( .T. )
			oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):SetNoUpdateLine( .T. )
			oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):SetNoDeleteLine( .T. )
		EndIf
		oModel:SetOptional( "GdDW1_"+aCompTab[ nCnt, 1 ], .T. )
		
		oModel:AddGrid( "GdDY1_"+aCompTab[ nCnt, 1 ], "GdDT1_"+aCompTab[ nCnt, 1 ] /*cOwner*/, aStruIDY1[nCnt], /*bLinePre*/ , bLnPostDY1/*bLinePost*/ , /*bPre*/ , /*bPost*/,  /*bLoad*/) 
		oModel:SetRelation( "GdDY1_"+aCompTab[ nCnt, 1 ], {	{"DY1_FILIAL","xFilial('DY1')"}, ;
												{"DY1_TABFRE","DT0_TABFRE"},;
												{"DY1_TIPTAB","DT0_TIPTAB"},;
												{"DY1_CDRORI","DT0_CDRORI"},;
												{"DY1_CDRDES","DT0_CDRDES"},;
												{"DY1_CODPRO","DT0_CODPRO"},;
												{"DY1_CODPAS","'"+aCompTab[ nCnt, 1 ]+"'"},;
												{"DY1_ITEDT1","TMA010AGet('GdDT1_"+aCompTab[ nCnt, 1 ]+"','DT1_ITEM')"}}, DY1->( IndexKey( 1 ) ) )

		//-- O complemento da SubFaixa permite apenas 1 linha
		oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):SetMaxLine( 1 )
		oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):SetUseOldGrid()
		
		//-- Se buscou tabela de região superior, apenas consulta complemento de sub-faixa
		If !Empty(aCompTab[ nCnt][4])
			oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):SetOnlyQuery( .T. )
			oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):SetNoInsertLine( .T. )
			oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):SetNoUpdateLine( .T. )
			oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):SetNoDeleteLine( .T. )
		EndIf
		oModel:SetOptional( "GdDY1_"+aCompTab[ nCnt, 1 ], .T. )
	EndIf
Next nCnt

//-- Base TDA
If lTDA
	oModel:AddGrid("GdDVY", "MdFieldCDT0" /*cOwner*/, oStruIDVY , /*bLinePre*/ , /*bLinePost*/ , /*bPre*/ , /*bPost*/,  /*bLoad*/)
	oModel:SetRelation( "GdDVY", {	{"DVY_FILIAL","xFilial('DVY')"  }, ;
											{"DVY_TABFRE","DT0_TABFRE"},;
											{"DVY_TIPTAB","DT0_TIPTAB"},;
											{"DVY_CDRORI","DT0_CDRORI"},;
											{"DVY_CDRDES","DT0_CDRDES"},;
											{"DVY_CODPRO","DT0_CODPRO"}}, DVY->( IndexKey( 1 ) ) )

	oModel:SetOptional( "GdDVY", .T. )
	oModel:GetModel("GdDVY"):SetUseOldGrid( )
EndIf

//-- Cria abas para TRT
If lTRT
	For nAuxTrt := 1 To Len(aTrt)	
		
		aAdd(aStruDJS ,Nil)	 
		
		aStruDJS[nAuxTrt] := FWFormStruct(1,"DJS")
		
		aStruDJS[nAuxTrt]:SetProperty( '*' , MODEL_FIELD_WHEN, {||.F.} )
		aStruDJS[nAuxTrt]:SetProperty( 'DJS_PERCEN' , MODEL_FIELD_WHEN, {||.T.} )
			
		oModel:AddGrid( "GdDJS_" +aTrt[ nAuxTrt, 1 ], "MdFieldCDT0" /*cOwner*/, aStruDJS[nAuxTrt], /*bLinePre*/ ,  /*bLinePost*/, /*bPre*/ , /*bPost*/,  /*bLoad*/) 
		oModel:SetRelation( "GdDJS_" + aTrt[ nAuxTrt, 1 ] , {	{"DJS_FILIAL","xFilial('DJS')"}, ;
														{"DJS_TABFRE","DT0_TABFRE"},;
														{"DJS_TIPTAB","DT0_TIPTAB"},;
														{"DJS_CDRORI","DT0_CDRORI"},;
														{"DJS_CDRDES","DT0_CDRDES"},;
														{"DJS_CODPRO","DT0_CODPRO"},;
														{"DJS_CODTRT","'"+aTrt[ nAuxTrt, 1 ]+"'"}}, DJS->( IndexKey( 1 ) ) )
		oModel:SetOptional( "GdDJS_" + aTrt[ nAuxTrt, 1 ] , .T. )	
		
		oModel:GetModel("GdDJS_" + aTrt[ nAuxTrt, 1 ]):SetOnlyQuery( .F. )
		oModel:GetModel("GdDJS_" + aTrt[ nAuxTrt, 1 ]):SetNoInsertLine( .F. )
		oModel:GetModel("GdDJS_" + aTrt[ nAuxTrt, 1 ]):SetNoUpdateLine( .F. )
		oModel:GetModel("GdDJS_" + aTrt[ nAuxTrt, 1 ]):SetNoDeleteLine( .T. )	
		
	Next nAuxTrt
EndIf

oModel:SetVldActivate( { | oModel | VldActiv( oModel ) } )
oModel:bActivate := {|oModel| TMA010Act(oModel,lTDA)} 
oModel:SetDeActivate( { |oModel| UnLockByName("TABMAN",.T.,.F.) /* Libera Lock */} )

RestArea(aArea)

Return oModel

/*/{Protheus.doc} ViewDef
	
@author Daniel
@since 22/11/2013
@version 1.0
		
@param ${nenhum}, ${Nil}

@return ${oModel}, ${Visão MVC}

@description

Visão de dados MVC

/*/
Static Function ViewDef()
Local oModel 	:= FwLoadModel("TMSA010")
Local oView 	:= Nil

Local oStruCDT0 	:= FwFormStruct( 2, "DT0") 
Local oStruIDTK 	:= FwFormStruct( 2, "DTK")
Local oStruIDVY 	:= FwFormStruct( 2, "DVY")

Local aStruIDT1 	:= {} 
Local aStruIDW1 	:= {}
Local aStruIDY1 	:= {}
Local aStruDJS		:= {}

Local nCnt
Local lTDA 		:= .F.
Local nAuxTrt	:= 0

Local aOpc			:= {MODEL_OPERATION_VIEW,MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE,MODEL_OPERATION_DELETE}
Local aSomaButtons
Local nCntFor

Local aNoDTK := {"DTK_TABFRE","DTK_CDRORI","DTK_CDRDES","DTK_TIPTAB","DTK_CALPAS","DTK_APLAJU"}
Local aNoDVY := {"DVY_FILIAL","DVY_TABFRE","DVY_CDRORI","DVY_CDRDES","DVY_TIPTAB","DVY_CALPAS","DVY_APLAJU","DVY_CODPRO"}

Local cFaixa  	:= ""
Local aRetBox 	:= {}
Local aTRT		:= {}
Local bAux		:= {||}

Default cCatTab  := StrZero(1, Len(DTL->DTL_CATTAB)) //-- Frete a Receber
Default cCadDesc := STR0001 //-- "Tabela de Frete"

aEval(aNoDTK,{|cCpo| oStruIDTK:RemoveField( cCpo )})
aEval(aNoDVY,{|cCpo| oStruIDVY:RemoveField( cCpo )})

oView := FwFormView():New()
oView:SetModel(oModel)

//-- Folder Superior
oView:CreateFolder( "FLD_SUP")

//-- Pasta "Tabela de Frete" - Cabeçalho da tabela mais Complemento
oView:AddSheet( "FLD_SUP", "SHT_001", cCadDesc )  //-- "Tabela de Frete"

oView:CreateHorizontalBox( 'SHT_001_SUP', 50,,, 'FLD_SUP', 'SHT_001' )  
oView:CreateHorizontalBox( 'SHT_001_INF', 50,,, 'FLD_SUP', 'SHT_001' )  

oView:AddField('VwFieldCDT0', oStruCDT0 , 'MdFieldCDT0') 
oView:EnableTitleView('VwFieldCDT0',cCadDesc) //--"Tabela de Frete"
oView:SetOwnerView("VwFieldCDT0","SHT_001_SUP")

//-- Pasta "Componentes de Frete"
oView:AddSheet( "FLD_SUP", "SHT_002", STR0061 )  //-- "Componentes de Frete"

oView:CreateHorizontalBox( 'SHT_002_FULL', 100,,, 'FLD_SUP', 'SHT_002' )  
oView:CreateFolder( "FLD_COMP","SHT_002_FULL")

For nCnt := 1 To Len(aCompTab)
	DT3->(DbGoTo(aCompTab[nCnt][3]))
	
	If DT3->DT3_TIPFAI == StrZero(14,Len(DT3->DT3_TIPFAI))
		Aadd( aTRT , aCompTab[nCnt] )		
	EndIf
	
	lTDA := lTDA .Or. DT3->DT3_TIPFAI == StrZero(13,Len(DT3->DT3_TIPFAI))
	
	aAdd(aStruIDT1,Nil)	 
	aAdd(aStruIDW1,Nil)	 
	aAdd(aStruIDY1,Nil)	 

	aStruIDT1[nCnt]:= FWFormStruct(2,"DT1")
	aStruIDT1[nCnt]:RemoveField( "DT1_TABFRE" )
	aStruIDT1[nCnt]:RemoveField( "DT1_CDRORI" )
	aStruIDT1[nCnt]:RemoveField( "DT1_CDRDES" )
	aStruIDT1[nCnt]:RemoveField( "DT1_TIPTAB" )
	aStruIDT1[nCnt]:RemoveField( "DT1_CODPAS" )

	If DT3->DT3_FAIXA <> StrZero(1, Len(DT3->DT3_FAIXA))
		aStruIDT1[nCnt]:RemoveField( "DT1_FATPES" )
	EndIf

	//-- Qdo utilizar sub-faixa, nao sera apresentado 'Valor' e 'Fracao'.
	If !Empty(DT3->DT3_FAIXA2)
		aStruIDT1[nCnt]:RemoveField( "DT1_VALOR" )
		aStruIDT1[nCnt]:RemoveField( "DT1_INTERV" )
	EndIf
	
	//-- Qdo componente 17- Taxa do Devedor por Lote, nao apresentar a "Fracao"
	If DT3->DT3_TIPFAI == StrZero(17,Len(DT3->DT3_TIPFAI))
		aStruIDT1[nCnt]:RemoveField( "DT1_INTERV" )
		aStruIDT1[nCnt]:SetProperty( "DT1_VALATE"  , MVC_VIEW_CANCHANGE ,.F.)
	EndIf

	//-- No título do campo DT1_VALATE, alterá-lo conforme faixa do componente
	If Empty(DT3->DT3_FAIXA) .Or. DT3->DT3_FAIXA == StrZero(0, Len(DT3->DT3_FAIXA))
		cFaixa := TMSValField('DT3->DT3_TIPFAI',.F.)
	Else		
		aRetBox := RetSx3Box(TMSA030BFX(),,, Len(DT3->DT3_FAIXA)) //-- Esse array contem as descricoes existentes no ComboBox do campo DT3_FAIXA 
		cFaixa := AllTrim( aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == DT3->DT3_FAIXA} ), 3 ])
	EndIf
	If DT3->DT3_TIPFAI <> StrZero(17,Len(DT3->DT3_TIPFAI))   //Taxa Devedor
		cFaixa := aStruIDT1[nCnt]:GetProperty("DT1_VALATE",3)  + Space( 10 ) + "(" +  cFaixa + ")"
	EndIf	
	aStruIDT1[nCnt]:SetProperty("DT1_VALATE",3,cFaixa)

	nAtalho := 1
	If	!Empty( DT3->DT3_ATALHO )
		nAtalho := At( DT3->DT3_ATALHO, UPPER(aCompTab[ nCnt, 2 ]) )
	EndIf

	oView:AddSheet( "FLD_COMP", "SHT_002_"+StrZero(nCnt,3), Stuff( aCompTab[ nCnt, 2 ], nAtalho, 0, '&' ) )    
	//-- Qdo utilizar sub-faixa, mostra grid de sub-faixa e complemento da sub-faixa
	If !Empty(DT3->DT3_FAIXA2)
		oView:CreateHorizontalBox( "SHT_002_"+StrZero(nCnt,3)+"_SUP", 50,,, "FLD_COMP", "SHT_002_"+StrZero(nCnt,3) )
		oView:CreateHorizontalBox( "SHT_002_"+StrZero(nCnt,3)+"_INF", 50,,, "FLD_COMP", "SHT_002_"+StrZero(nCnt,3) )
	Else
		oView:CreateHorizontalBox( "SHT_002_"+StrZero(nCnt,3)+"_SUP", 100,,, "FLD_COMP", "SHT_002_"+StrZero(nCnt,3) )
	EndIf

	oView:AddGrid(  "VGDT1_"+aCompTab[ nCnt, 1 ] , aStruIDT1[nCnt] , "GdDT1_"+aCompTab[ nCnt, 1 ] )
	oView:AddIncrementField("VGDT1_"+aCompTab[ nCnt, 1 ] , "DT1_ITEM" )     
	oView:SetOwnerView( "VGDT1_"+aCompTab[ nCnt, 1 ], "SHT_002_"+StrZero(nCnt,3)+"_SUP" )
	oView:EnableTitleView("VGDT1_"+aCompTab[ nCnt, 1 ],STR0059  + " : " + aCompTab[ nCnt, 2 ] + Iif(Empty(aCompTab[ nCnt, 4 ]),""," (* "+STR0060+")")) //-- "Tabela de Frete - Itens para o Componente" ## " * " ## "Componente herdado de região superior - apenas para visualização"

	//-- Qdo utilizar sub-faixa, mostra grid de sub-faixa e complemento da sub-faixa
	If !Empty(DT3->DT3_FAIXA2)
		aStruIDW1[nCnt] := FwFormStruct( 2, "DW1")
		aStruIDY1[nCnt] := FwFormStruct( 2, "DY1")

		aStruIDW1[nCnt]:RemoveField( "DW1_ITEDT1" )
		If DT3->DT3_FAIXA2 <> StrZero(1, Len(DT3->DT3_FAIXA2))
			aStruIDW1[nCnt]:RemoveField( "DW1_FATPES" )
		EndIf

		//-- No título do campo DW1_VALATE, alterá-lo conforme faixa do componente		
		aRetBox := RetSx3Box(TMSA030BFX(),,, Len(DT3->DT3_FAIXA2)) //-- Esse array contem as descricoes existentes no ComboBox do campo DT3_FAIXA
		cFaixa := AllTrim( aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == DT3->DT3_FAIXA2} ), 3 ])
		cFaixa := aStruIDW1[nCnt]:GetProperty("DW1_VALATE",3)  + Space( 10 ) + "(" +  cFaixa + ")" 
		aStruIDW1[nCnt]:SetProperty("DW1_VALATE",3,cFaixa)

		oView:CreateVerticalBox( "SHT_002_"+StrZero(nCnt,3)+"_INF_ESQ"	, 49,"SHT_002_"+StrZero(nCnt,3)+"_INF",, "FLD_COMP", "SHT_002_"+StrZero(nCnt,3))
		oView:CreateVerticalBox( "SHT_002_"+StrZero(nCnt,3)+"_INF_MEIO"	, 02,"SHT_002_"+StrZero(nCnt,3)+"_INF",, "FLD_COMP", "SHT_002_"+StrZero(nCnt,3))
		oView:CreateVerticalBox( "SHT_002_"+StrZero(nCnt,3)+"_INF_DIR"	, 49,"SHT_002_"+StrZero(nCnt,3)+"_INF",, "FLD_COMP", "SHT_002_"+StrZero(nCnt,3))

		oView:AddGrid(  "VGDW1_"+aCompTab[ nCnt, 1 ] , aStruIDW1[nCnt] , "GdDW1_"+aCompTab[ nCnt, 1 ] )
		oView:AddIncrementField("VGDW1_"+aCompTab[ nCnt, 1 ] , "DW1_ITEM" )     
		oView:SetOwnerView( "VGDW1_"+aCompTab[ nCnt, 1 ], "SHT_002_"+StrZero(nCnt,3)+"_INF_ESQ" )
		oView:EnableTitleView("VGDW1_"+aCompTab[ nCnt, 1 ],STR0027) //-- "Tabela de Frete - Subfaixa"


		oView:AddGrid(  "VGDY1_"+aCompTab[ nCnt, 1 ] , aStruIDY1[nCnt] , "GdDY1_"+aCompTab[ nCnt, 1 ] )
		oView:AddIncrementField("VGDY1_"+aCompTab[ nCnt, 1 ] , "DY1_ITEM" )     
		oView:SetOwnerView( "VGDY1_"+aCompTab[ nCnt, 1 ], "SHT_002_"+StrZero(nCnt,3)+"_INF_DIR" )
		oView:EnableTitleView("VGDY1_"+aCompTab[ nCnt, 1 ],STR0053) //-- "Complemento Sub-Faixa"

	EndIf
Next nCnt

oView:CreateFolder( "SHT_003_FULL","SHT_001_INF")

//-- Pasta "Complemento Tabela De Frete"
oView:AddSheet( "SHT_003_FULL", "SHT_003_001", STR0019 )  //-- "Complemento Tabela De Frete"

oView:CreateHorizontalBox( 'SHT_003_DTK', 100,,, 'SHT_003_FULL', 'SHT_003_001' )  

oView:AddGrid( 'VGDTK', oStruIDTK , 'GdDTK')
oView:EnableTitleView('VGDTK',STR0019) //-- "Complemento Tabela De Frete"
oView:SetOwnerView("VGDTK","SHT_003_DTK")

If lTda
	oView:AddSheet( "SHT_003_FULL", "SHT_003_002", STR0050 )  //-- "Base Componente Taxa de Dificil Acesso"
	oView:CreateHorizontalBox( 'SHT_003_DVY', 100,,, 'SHT_003_FULL', 'SHT_003_002' )  
	oView:AddGrid( 'VGDVY', oStruIDVY , 'GdDVY')
	oView:EnableTitleView('VGDVY',STR0050) //-- "Base Componente Taxa de Dificil Acesso"
	oView:SetOwnerView("VGDVY","SHT_003_DVY")
EndIf

//-- Cria abas para TRT
If lTRT
	For nAuxTRT := 1 To Len(aTRT)
		
		aAdd(aStruDJS ,Nil)	 
		
		aStruDJS[nAuxTrt] := FWFormStruct(2,"DJS")
		
		oView:AddSheet( "SHT_003_FULL", "SHT_003_" + aTRT[nAuxTRT,1] , STR0066 + " - " + RTrim(aTrt[nAuxTRT,2 ])  )  //-- "Base percentual total por componente"
		oView:CreateHorizontalBox( 'DJS_'+ aTRT[nAuxTRT,1], 80,,, 'SHT_003_FULL', 'SHT_003_' + aTRT[nAuxTRT,1] )  
		
		oView:AddGrid( 'VGDJS_' + aTRT[nAuxTRT,1] , aStruDJS[nAuxTrt] , 'GdDJS_' + aTRT[nAuxTRT,1] )
		
		oView:SetOwnerView("VGDJS_" + aTRT[nAuxTRT,1] ,'DJS_'+ aTRT[nAuxTRT,1] )
				
		//-- Adiciona objetos de interface
		oView:CreateHorizontalBox( 'OBJ_'+ aTRT[nAuxTRT,1], 20,,, 'SHT_003_FULL', 'SHT_003_' + aTRT[nAuxTRT,1] )
		bAux := &("{|oPanel| A010Panel( oPanel ,'"+ aTRT[nAuxTRT,1]+"'  ) }") 
		oView:AddOtherObject('OBJ_'+ aTRT[nAuxTRT,1] , bAux )
		oView:SetOwnerView('OBJ_'+ aTRT[nAuxTRT,1] ,'OBJ_'+ aTRT[nAuxTRT,1] )
		
	Next nAuxTRT
	
EndIF

//-- Botao de atalho para a rotina 'Tabela de Frete por Destinatário'                                              
oView:AddUserButton( STR0009, "FRETEDEST", {|| TMSA012Mnt(,,1,DT0->DT0_TABFRE,DT0->DT0_TIPTAB) } ,NIL,NIL, {MODEL_OPERATION_VIEW})

//-- Ponto de entrada para incluir botoes
If	ExistBlock('TM010BUT')
	For nCntFor := 1 To Len(aOpc)
		aSomaButtons:=ExecBlock('TM010BUT',.F.,.F.,{aOpc[nCntFor]})
		If	ValType(aSomaButtons) == 'A'
			AEval( aSomaButtons, { |x| oView:AddUserButton( x[3], x[1], x[2] ,NIL,NIL, {aOpc[nCntFor]}) } ) 			
		EndIf
	Next nCntFor
EndIf

oView:SetAfterViewActivate({|oView|SetAfterView(oView,aTRT)})

Return oView
                              
/*/{Protheus.doc} A010Panel
//Objeto criado no grid da aba % Base Comp. Fre
@author caio.y
@since 10/03/2017
@version undefined
@param oPanel, object, descricao
@type function
/*/
Static Function A010Panel(oPanel , cId)
Local lCheck	:= .F.

aCheck := {}

aAdd( aCheck ,{ cID , tCheckBox():New(3,3,"Repetir o percentual de ajuste",{|u|if( pcount()>0,lCheck:=u,lCheck)},oPanel,100,10,,,,,,,,.T.)  } )

Return .T.  


/*/{Protheus.doc} SetAfterView
//Ap�s valida��o da View
@author Caio Murakami
@since 28/02/2017
@version undefined
@param oView, object, View Ativa
@param aTRT, array, Array com componentes TRT
@type function
/*/
Static Function SetAfterView(oView , aTRT )
Local oModel	:= FwModelActive()
Local aArea		:= GetArea()
Local aSaveLine	:= FWSaveRows() 
Local oMdlAux	:= Nil
Local oMdlField	:= Nil
Local nAux		:= 0
Local nCount	:= 0
Local cTabFre	:= ""
Local cTipTab	:= ""
Local cCdROri	:= ""
Local cCdRDes	:= ""
Local cCodPro	:= ""
Local cCodTRT	:= ""
Local cCodPas	:= ""
Local aCompTRT

Default oView	:= FwViewActivate()
Default aTRT	:= {}

If lTRT .And. ( oModel:GetOperation() <> MODEL_OPERATION_VIEW .And. oModel:GetOperation() <> MODEL_OPERATION_DELETE )
	
	oMdlField	:= oModel:GetModel("MdFieldCDT0")
	
	cTabFre		:= oMdlField:GetValue("DT0_TABFRE")
	cTipTab		:= oMdlField:GetValue("DT0_TIPTAB")
	cCdROri		:= oMdlField:GetValue("DT0_CDRORI")
	cCdRDes		:= oMdlField:GetValue("DT0_CDRDES")
	cCodPro		:= oMdlField:GetValue("DT0_CODPRO")
		
	DJS->(dbSetOrder(1))
	For nAux := 1 To Len(aTRT)
		oMdlAux		:= oModel:GetModel("GdDJS_" + aTRT[nAux,1])
		cCodTrt		:= aTRT[nAux,1]
		aCompTRT    :=  TMA010Comp(cTabFre,cTipTab,.T.)
		For nCount := 1 To Len(aCompTRT)
			
			cCodPas		:= aCompTRT[nCount,1]
			
			If DJS->( !MsSeek( xFilial("DJS") + cTabFre + cTipTab + cCdROri	+ cCdRDes + cCodPro + cCodTRT + cCodPas ))
				
				If cCodPas <> cCodTRT				
					
					If nCount <> 1
						oMdlAux:AddLine()
					EndIf
					
					oMdlAux:LoadValue("DJS_CODPAS",cCodPas)
					oMdlAux:LoadValue("DJS_DESPAS",RTrim( Posicione("DT3",1,xFilial("DT3") + cCodPas ,"DT3_DESCRI")))
					oMdlAux:LoadValue("DJS_PERCEN",100)
									
				Else
					Exit
				EndIf	
							
			EndIf
			
		Next nCount
		FwFreeArray(aCompTRT)
		oMdlAux:GoLine(1)
		
	Next nAux
EndIf

oView:Refresh()

FWRestRows( aSaveLine )
RestArea(aArea)
Return 
/*/{Protheus.doc} VldActiv
	
@author Daniel
@since 22/11/2013
@version 1.0
		
@param ${oModel}, ${Modelo de dados}

@return ${lRet}, ${Se é possível alterar o modelo}

@description

Valida se é permitido alterar o Modelo

/*/
Static Function VldActiv(oModel)
Local lRet := .T.
Local lContHis  := GetMv("MV_CONTHIS",.F.,.T.) //-- Controla Historico da Tabela de Frete

If oModel:GetOperation() == MODEL_OPERATION_DELETE .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	//-- O Objetivo deste Ponto de Entrada, e' validar se sera' permitido Alterar/Excluir (independente
	//-- do conteudo do parametro MV_CONTHIS).
	If lTMA010His
		lRet := ExecBlock("TMA010HIS",.F.,.F.,{oModel:GetOperation(),DT0->DT0_TABFRE,DT0->DT0_TIPTAB}) 
		If ValType(lRet) <> "L"
			lRet:=.T.
		EndIf
		lContHis := lRet
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controla Historico de Tabela            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContHis
		//-- Verifica se a tabela de frete esta em uso por um CTRC, AWB ou cotacao de frete nao cancelada.
		If	TmsTabUso(DT0->DT0_TABFRE,DT0->DT0_TIPTAB,DT0->DT0_CDRORI,DT0->DT0_CDRDES,.T.,cCatTab)
			lRet := .F.
		EndIf

	EndIf
EndIf	
If oModel:GetOperation() == MODEL_OPERATION_INSERT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria a Trava com o Nome 'TABMAN'. Se algum usuario estiver incluindo Tabelas de  ³
	//³ Frete, a rotina de 'Gera Tabela de Frete' nao podera ser executada               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LockByName("TABMAN",.T.,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a rotina de 'Gera Tabela de Frete' estiver sendo executada, nao sera permitida³
	//³ a inclusao Manual de Tabela de Frete                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !LockByName("GERTAB",.T.,.F.)
		Help("",1,"TMSA01020") //A Inclusao de Tabelas nao podera ser efetuada, pois existe outro usuario gerando Tabelas de Frete
		UnLockByName("TABMAN",.T.,.F.) //-- Libera Lock
		lRet := .F.
	EndIf
	UnLockByName("GERTAB",.T.,.F.) //-- Libera Lock
EndIf
Return lRet

/*/{Protheus.doc} PosVldMdl
	
@author Daniel
@since 22/11/2013
@version 1.0
		
@param ${oModel}, ${Modelo de Dados}

@return ${lReturn}, ${Sé permitido confirmar o modelo}

@description

Tudo Ok do modelo

/*/
Static Function PosVldMdl(oModel)
Local lReturn := .T.
Local nLoop      := 0 
Local lEmpty     := .T.
Local lOk        := .F.
Local cAliasDVD  := GetNextAlias()
Local cAliasDW2  := GetNextAlias()
Local cAliasDY2  := GetNextAlias()
Local cAliasQry	 := GetNextAlias()
Local cQuery     := ''
Local lContHis   := GetMv("MV_CONTHIS",.F.,.T.)
Local nCntFor 	:= 0
Local nCntFor2 	:= 0
Local aRecnoDVD 	:= {}
Local aRecnoDW2 	:= {}
Local aRecnoDY2 	:= {}
Local lExcAjus := .F.
Local lHerdValor
Local lCompObr

If	l010TudOk ==  Nil
	l010TudOk  := If(ValType(l010TudOk)=="L",l010TudOk,ExistBlock("TMA010TOK"))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa na Inclusao a chave Duplicada                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oModel:GetOperation() == MODEL_OPERATION_INSERT
	DT0->(DbSetOrder(1)) //-- DT0_FILIAL+DT0_TABFRE+DT0_TIPTAB+DT0_CDRORI+DT0_CDRDES+CODPRO	
	If DT0->(MsSeek(xFilial("DT0")+M->DT0_TABFRE + M->DT0_TIPTAB + M->DT0_CDRORI + M->DT0_CDRDES+M->DT0_CODPRO))
		Help("",1,"JAGRAVADO") //Ja existe registro com esta informacao.
		lReturn := .F.
	EndIf
EndIf

//-- Verificação se todas as pastas estão vazias
If lReturn .And. oModel:GetOperation() != MODEL_OPERATION_DELETE
	aEval(aCompTab,{|aDadComp| lEmpty := lEmpty .And. ;
												(oModel:GetModel("GdDT1_"+aDadComp[1]):Length(.T.) == 0 .Or.;
												 (oModel:GetModel("GdDT1_"+aDadComp[1]):Length(.T.) == 1 .And. ;
												  !PosVldLine(oModel:GetModel("GdDT1_"+aDadComp[1]),"DT1") ))  })

	// Se n�o h� componentes no folder, verifica se h� componente de Herda Valor
	// Caso positivo e n�o existam outros componentes obrigat�rios, permite incluir
	If lEmpty
		lHerdValor := .F.
		lCompObr := .F.
		cQuery  := "SElECT DT3_TIPFAI, DVE_COMOBR FROM  " + RetSqlName("DVE") + " DVE "
		cQuery  += "JOIN " + RetSqlName("DT3") + " DT3 ON "
		cQuery  += "DT3_FILIAL = '" + xFilial("DT3") + "' AND DT3_CODPAS = DVE.DVE_CODPAS AND DT3.D_E_L_E_T_ = ' ' "
		cQuery  += "WHERE "
		cQuery	+= "DVE_FILIAL = '" + xFilial("DVE") + "' AND "
		cQuery	+= "DVE_TABFRE = '" + M->DT0_TABFRE + "' AND "
		cQuery	+= "DVE_TIPTAB = '" + M->DT0_TIPTAB + "' AND "
		cQuery	+= "DVE.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
		
		// Verifica se h� componentes obrigat�rios que n�o sejam do tipo herda valor
		While (cAliasQry)->( !Eof() )
			If (cAliasQry)->DT3_TIPFAI == '16' 
				lHerdValor := .T.
			ElseIf (cAliasQry)->DVE_COMOBR == '1'
				lCompObr := .T.
			EndIf
			(cAliasQry)->( DbSkip() )
		EndDo
		(cAliasQry)->(dbCloseArea())
		
		// Se possui componente de Herda Valor e n�o h� componentes obrigat�rios, permite incluir sem informa��o de componentes
		If lHerdValor .AND. !lCompObr
			lEmpty := .F.
		EndIf

	EndIf

	
	If lEmpty .And. lReturn
		Help(" ",1,"TMSA01006") //"Todas as 'Pastas' estao vazias !!"
		lReturn := .F.
	EndIf
EndIf
	
//Validacao SubFaixa
DT3->(DbSetOrder(1)) //-- DT3_FILIAL+DT3_CODPAS
For nLoop := 1 to Len(aCompTab)
	For nCntFor := 1 To oModel:GetModel("GdDT1_"+aCompTab[ nLoop, 1 ]):Length()
	   		oModel:GetModel("GdDT1_"+aCompTab[ nLoop, 1 ]):GoLine(nCntFor)		
		If DT3->(MsSeek(xFilial("DT3")+ oModel:GetValue("GdDTK","DTK_CODPAS"))) .And. !Empty(DT3->DT3_FAIXA2);
			.And. !oModel:GetModel("GdDTK"):IsDeleted()
			MsgInfo(STR0064 + " " + STR0065)
			oModel:GetModel("GdDTK"):DeleteLine()
			lReturn := .F.
		EndIf
	Next nCntFor
Next nLoop
	
//Validacao para Exclusao de Tabelas de Ajuste 
If !lContHis
	For nLoop := 1 to Len(aCompTab)
		For nCntFor := 1 To oModel:GetModel("GdDT1_"+aCompTab[ nLoop, 1 ]):Length()
	   		oModel:GetModel("GdDT1_"+aCompTab[ nLoop, 1 ]):GoLine(nCntFor)
	
			If oModel:GetModel("GdDT1_"+aCompTab[ nLoop, 1 ]):IsDeleted()
				
				cQuery := " SELECT R_E_C_N_O_ as DVD_RECNO FROM " + RetSqlName("DVD") 
				cQuery += " WHERE DVD_FILIAL = '" + xFilial("DVD")  + "' "
				cQuery += " AND DVD_TABFRE = '" + DT1->DT1_TABFRE + "' "
				cQuery += " AND DVD_TIPTAB = '" + DT1->DT1_TIPTAB + "' "
				cQuery += " AND DVD_CDRORI = '" + DT1->DT1_CDRORI + "' "
				cQuery += " AND DVD_CDRDES = '" + DT1->DT1_CDRDES + "' "
				cQuery += " AND DVD_CODPRO = '" + DT1->DT1_CODPRO + "' "
				cQuery += " AND DVD_CODPAS = '" + oModel:GetValue("GdDT1_"+aCompTab[ nLoop, 1 ], "DT1_CODPAS") + "' "
				cQuery += " AND DVD_ITEM   = '" + oModel:GetValue("GdDT1_"+aCompTab[ nLoop, 1 ], "DT1_ITEM") + "' "
				cQuery += " AND D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDVD, .F., .T.)
				
				Do While !(cAliasDVD)->(Eof())
					AAdd( aRecnoDVD,	(cAliasDVD)->DVD_RECNO )
					(cAliasDVD)->(DbSkip())
				EndDo							
				(cAliasDVD)->( DbCloseArea() )
			EndIf
		Next nCntFor
	Next nLoop
EndIf
	
If !Empty(aRecnoDVD)
	If MsgNoYes(STR0062 + Chr(13) + STR0063) //"Os registros selecionados para exclusao possuem ajustes/reajustes que tambem ser�o excluidos."
	   	For nLoop := 1 to Len(aRecnoDVD)
			DVD->(dbGoTo(aRecnoDVD[nLoop]))
			RecLock('DVD',.F.)
			DVD->(dbDelete())
			DVD->(MsUnLock())	
			lExcAjus := .T.									
		Next nLoop			
	Else
	   lReturn := .F.
	EndIf	
EndIf

If !lContHis
	For nLoop := 1 to Len(aCompTab)
		DT3->(DbGoTo(aCompTab[nLoop][3]))
		If !Empty(DT3->DT3_FAIXA2)
			For nCntFor := 1 To oModel:GetModel("GdDT1_"+aCompTab[ nLoop, 1 ]):Length()
				oModel:GetModel("GdDT1_"+aCompTab[ nLoop, 1 ]):GoLine(nCntFor)
				For nCntFor2 := 1 To oModel:GetModel("GdDW1_"+aCompTab[ nLoop, 1 ]):Length()
	   				oModel:GetModel("GdDW1_"+aCompTab[ nLoop, 1 ]):GoLine(nCntFor2)	
					If (oModel:GetModel("GdDW1_"+aCompTab[ nLoop, 1 ]):IsDeleted()) .OR.;
					   (oModel:GetModel("GdDT1_"+aCompTab[ nLoop, 1 ]):IsDeleted())
						cQuery := " SELECT R_E_C_N_O_ as DW2_RECNO FROM " + RetSqlName("DW2") 
						cQuery += " WHERE DW2_FILIAL = '" + xFilial("DW2")  + "' "
						cQuery += " AND DW2_TABFRE = '" + oModel:GetValue("GdDT1_"+aCompTab[ nLoop, 1 ], "DT1_TABFRE") + "' "
						cQuery += " AND DW2_TIPTAB = '" + oModel:GetValue("GdDT1_"+aCompTab[ nLoop, 1 ], "DT1_TIPTAB") + "' "
						cQuery += " AND DW2_CDRORI = '" + oModel:GetValue("GdDT1_"+aCompTab[ nLoop, 1 ], "DT1_CDRORI") + "' "
						cQuery += " AND DW2_CDRDES = '" + oModel:GetValue("GdDT1_"+aCompTab[ nLoop, 1 ], "DT1_CDRDES") + "' "
						cQuery += " AND DW2_CODPRO = '" + oModel:GetValue("GdDT1_"+aCompTab[ nLoop, 1 ], "DT1_CODPRO") + "' "
						cQuery += " AND DW2_CODPAS = '" + oModel:GetValue("GdDT1_"+aCompTab[ nLoop, 1 ], "DT1_CODPAS") + "' "
						cQuery += " AND DW2_ITEDVD = '" + oModel:GetValue("GdDT1_"+aCompTab[ nLoop, 1 ], "DT1_ITEM") + "' "
						cQuery += " AND DW2_ITEM   = '" + oModel:GetValue("GdDW1_"+aCompTab[ nLoop, 1 ], "DW1_ITEM") + "' "
						cQuery += " AND D_E_L_E_T_ = ' ' "
						cQuery := ChangeQuery(cQuery)
						dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDW2, .F., .T.)
				
						Do While !(cAliasDW2)->(Eof())
							AAdd( aRecnoDW2,	(cAliasDW2)->DW2_RECNO )	
							(cAliasDW2)->(DbSkip())
						EndDo							
						(cAliasDW2)->( DbCloseArea() )
					EndIf
				Next nCntFor2
			Next nCntFor
		EndIF			
	Next nLoop
EndIf

If !Empty(aRecnoDW2)
	//
	if lExcAjus == .F.
		If MsgNoYes(STR0062 + Chr(13) + STR0063) //"Os registros selecionados para exclusao possuem ajustes/reajustes que tambem serao excluidos."
			lExcAjus := .T.
		EndIF
	EndIF
	if lExcAjus == .T. 
	   	For nLoop := 1 to Len(aRecnoDW2)
			DW2->(dbGoTo(aRecnoDW2[nLoop]))
			RecLock('DW2',.F.)
			DW2->(dbDelete())
			DW2->(MsUnLock())										
		Next nLoop			
	Else
	   lReturn := .F.
	EndIf	
EndIf 

If !lContHis
	For nLoop := 1 to Len(aCompTab)
		DT3->(DbGoTo(aCompTab[nLoop][3]))
		If !Empty(DT3->DT3_FAIXA2)
			For nCntFor := 1 To oModel:GetModel("GdDT1_"+aCompTab[ nLoop, 1 ]):Length()
				oModel:GetModel("GdDT1_"+aCompTab[ nLoop, 1 ]):GoLine(nCntFor)
				For nCntFor2 := 1 To oModel:GetModel("GdDY1_"+aCompTab[ nLoop, 1 ]):Length()
	   				oModel:GetModel("GdDY1_"+aCompTab[ nLoop, 1 ]):GoLine(nCntFor2)
	
					If (oModel:GetModel("GdDY1_"+aCompTab[ nLoop, 1 ]):IsDeleted()) .OR.;
					   (oModel:GetModel("GdDT1_"+aCompTab[ nLoop, 1 ]):IsDeleted())
						cQuery := " SELECT R_E_C_N_O_ as DY2_RECNO FROM " + RetSqlName("DY2") 
						cQuery += " WHERE DY2_FILIAL = '" + xFilial("DY2")  + "' "
						cQuery += " AND DY2_TABFRE = '" + oModel:GetValue("GdDT1_"+aCompTab[ nLoop, 1 ], "DT1_TABFRE") + "' "
						cQuery += " AND DY2_TIPTAB = '" + oModel:GetValue("GdDT1_"+aCompTab[ nLoop, 1 ], "DT1_TIPTAB") + "' "
						cQuery += " AND DY2_CDRORI = '" + oModel:GetValue("GdDT1_"+aCompTab[ nLoop, 1 ], "DT1_CDRORI") + "' "
						cQuery += " AND DY2_CDRDES = '" + oModel:GetValue("GdDT1_"+aCompTab[ nLoop, 1 ], "DT1_CDRDES") + "' "
						cQuery += " AND DY2_CODPRO = '" + oModel:GetValue("GdDT1_"+aCompTab[ nLoop, 1 ], "DT1_CODPRO") + "' "
						cQuery += " AND DY2_CODPAS = '" + oModel:GetValue("GdDT1_"+aCompTab[ nLoop, 1 ], "DT1_CODPAS") + "' "
						cQuery += " AND DY2_ITEDVD = '" + oModel:GetValue("GdDT1_"+aCompTab[ nLoop, 1 ], "DT1_ITEM") + "' "
						cQuery += " AND DY2_ITEM   = '" + oModel:GetValue("GdDY1_"+aCompTab[ nLoop, 1 ], "DY1_ITEM") + "' "
						cQuery += " AND D_E_L_E_T_ = ' ' "
						cQuery := ChangeQuery(cQuery)
						dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDY2, .F., .T.)
				
						Do While !(cAliasDY2)->(Eof())
							AAdd( aRecnoDY2,	(cAliasDY2)->DY2_RECNO )	
							(cAliasDY2)->(DbSkip())
						EndDo							
						(cAliasDY2)->( DbCloseArea() )
					EndIf
				Next nCntFor2
			Next nCntFor
		EndIF			
	Next nLoop
EndIf

If !Empty(aRecnoDY2)
	if lExcAjus == .F.
		If MsgNoYes(STR0062 + Chr(13) + STR0063) //"Os registros selecionados para exclusao possuem ajustes/reajustes que tambem sera excluidos."
			lExcAjus := .T.
		EndIF
	EndIF
	if lExcAjus == .T.
		For nLoop := 1 to Len(aRecnoDY2)
			DY2->(dbGoTo(aRecnoDY2[nLoop]))
			RecLock('DY2',.F.)
			DY2->(dbDelete())
			DY2->(MsUnLock())
		Next nLoop			
	Else
	   lReturn := .F.
	EndIf	
EndIf

If lReturn .And. l010TudOk
	lReturn:=ExecBlock("TMA010TOK",.F.,.F.)
	If ValType(lReturn) # "L"
		lReturn:=.T.
	EndIf
EndIf	

Return lReturn

/*/{Protheus.doc} PosVldLine
	
@author Daniel
@since 22/11/2013
@version 1.0
		
@param ${oModelGrid}, ${Modelo de Dados do grid}

@return ${lReturn}, ${Sé permitido confirmar o modelo}

@description

Lin OK  do modelo

/*/
Static Function PosVldLine(oMdlGrid,cAlias)
Local lRet := .T.
Local nPosValAte
Local nPosFatPes
Local nValAte   
Local nValPes   
Local nPosComp := aScan(aCompTab,{|x| x[1] == Right(oMdlGrid:cId,Len(DT3->DT3_CODPAS)) } )
Local oModel := FWModelActive()
SaveInter()
n		:= oMdlGrid:GetLine() //Controle de numero da linha
aHeader:= oMdlGrid:aHeader
aCols	:= oMdlGrid:aCols

If cAlias == "DT1"
	lRet := MaCheckCols(aHeader,aCols,n)

	nPosValAte := Ascan( aHeader, { |aField| aField[2] = "DT1_VALATE" } )
	nPosFatPes := Ascan( aHeader, { |aField| aField[2] = "DT1_FATPES" } )
	nValAte    := aCols[n][nPosValAte]
	nValPes    := If(nPosFatPes > 0, aCols[n][nPosFatPes], 0)
	
	If lRet
		Do Case
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Esta deletado                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case aCols[n][Len( aHeader ) + 1]
				lRet := .T.
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Na primeira linha Valida p/ baixo  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
			Case  n = 1
				lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
										(nValAte >= aLine[nPosValAte]	.Or.;
										 IIf(nPosFatPes >0, nValPes >= aLine[nPosFatPes],.F.) )}, 2 ) = 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Na ultima linha Valida p/ cima ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
			Case  n = Len( aCols )
				lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
											(nValAte <= aLine[nPosValAte]	.Or.;
											IIf(nPosFatPes >0, nValPes <= aLine[nPosFatPes],.F.) )}, 1, Len( Acols ) - 1 ) = 0
					
			OtherWise
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Valida Acima e Abaixo ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .And. ;
											(nValAte <= aLine[nPosValAte] .Or. ;
											IIf(nPosFatPes >0, nValPes <= aLine[nPosFatPes],.F.) ) } , 1, n - 1 ) = 0
			
				lRet := lRet .And. ;
							   Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .And. ;
											(nValAte >= aLine[nPosValAte] .Or.;
											IIf(nPosFatPes >0, nValPes >= aLine[nPosFatPes],.F.) )	}, n + 1 ) = 0
		EndCase
	EndIf
	
	If !lRet
		Help(" ",1,"TMSA01007") //"Campo Ate'/Fator Peso Invalido ou ja existente"
	EndIf
	
	If lRet .And. !GDdeleted(n)
		If nPosComp > 0
			DT3->(DbGoTo(aCompTab[nPosComp][3]))
		Else
			lRet := .F.
		EndIf

		If nPosFatPes >0 .And. GDFieldGet('DT1_FATPES',n) < GDFieldGet('DT1_VALATE',n)
			Help("", 1,"TMSA01008")  //"O Fator de Peso Nao pode ser menor do que o Peso ..."
			lRet := .F.
		EndIf
		//-- Valida sub-faixa do componente.
		If lRet .And. !Empty(DT3->DT3_FAIXA2)
		
			If !GDDeleted(n) .And. (oModel:GetModel("GdDW1_"+aCompTab[nPosComp][1]):Length(.T.) == 0 .Or.;
												 (oModel:GetModel("GdDW1_"+aCompTab[nPosComp][1]):Length(.T.) == 1 .And. ;
												  !PosVldLine(oModel:GetModel("GdDW1_"+aCompTab[nPosComp][1]),"DW1")))
			
				Help("",1,"TMSA01017") //Nao foi informada a sub-faixa para o item.
				lRet := .F.
			EndIf
		EndIf
		
		//-- Valida o componente tipo TAXA  
		If lRet .And. DT3->DT3_TAXA == "1" .And. (DT1->(FieldPos('DT1_INTERV')) > 0)
			If GDFieldGet('DT1_INTERV',n) != Nil .And. GDFieldGet('DT1_INTERV',n) > 0
				Help("",1,"TMSA01023") //Componente e do tipo Taxa, nao deve ter valor de fracao
				lRet := .F.
			EndIf
		EndIf
	EndIf
ElseIf cAlias == "DW1"
	nPosValAte	:= GDFieldPos("DW1_VALATE")
	nPosFatPes	:= GDFieldPos("DW1_FATPES")
	nValAte	:= aCols[n][nPosValAte]
	nValPes	:= If(nPosFatPes > 0, aCols[n][nPosFatPes], 0)
	
	lRet := MaCheckCols(aHeader,aCols,n)
	
	//-- Valida se esta deletado
	If lRet
		If GDDeleted(n)
			lRet := .T.
		//-- Na primeira linha Valida p/ baixo
		ElseIf n == 1
			lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
											(nValAte >= aLine[nPosValAte] .Or. ;
											IIf(nPosFatPes >0, nValPes >= aLine[nPosFatPes],.F.) )}, 2 ) == 0
		//-- Na ultima linha Valida p/ cima
		ElseIf n == Len( aCols )
			lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
											(nValAte <= aLine[nPosValAte]	.Or.;
											IIf(nPosFatPes >0, nValPes <= aLine[nPosFatPes],.F.) )}, 1, Len( Acols ) - 1 ) == 0
		//-- Valida Acima e Abaixo
		Else			
			lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. ;
											(nValAte <= aLine[nPosValAte] .Or. ;
											IIf(nPosFatPes >0, nValPes <= aLine[nPosFatPes],.F.) ) } , 1, n - 1 ) == 0
			
			lRet := lRet .And. ;
					   Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .And. ;
											(nValAte >= aLine[nPosValAte] .Or.;
											IIf(nPosFatPes >0, nValPes >= aLine[nPosFatPes],.F.) )	}, n + 1 ) == 0
		EndIf
		
		If !lRet
			Help(" ",1,"TMSA01007") //"Campo Ate'/Fator Peso Invalido ou ja existente"
		EndIf
	
		If lRet .And. !GdDeleted(n) .And. nPosFatPes >0 .And. GDFieldGet('DW1_FATPES',n) < GDFieldGet('DW1_VALATE',n)
			Help("", 1,"TMSA01008")  //"O Fator de Peso Nao pode ser menor do que o Peso ..."
			lRet := .F.
		EndIf
	EndIf
ElseIf cAlias == "DY1"
	nPosExcMin := GDFieldPos("DY1_EXCMIN")
	nPosValMin := GDFieldPos("DY1_VALMIN")
	nPosValMax := GDFieldPos("DY1_VALMAX")
	nPosValor  := GDFieldPos("DY1_VALOR")
	nPosInterv := GDFieldPos("DY1_INTERV")
	
	nExcMin := 0
	nValMin := 0
	nValMax := 0
	nValor  := 0
	nInterv := 0
	
	If Len(aCols) > 0
		nExcMin := aCols[n][nPosExcMin]
		nValMin := aCols[n][nPosValMin]
		nValMax := aCols[n][nPosValMax]
		nValor 	 := aCols[n][nPosValor]
		nInterv := aCols[n][nPosInterv]
	Endif
	
	lRet := MaCheckCols(aHeader,aCols,n)
	
	//-- Valida se esta deletado
	If lRet .and. Len(aCols) > 0
		If GDDeleted(n)
			lRet := .T.
		//-- Na primeira linha Valida p/ baixo
		ElseIf n == 1
			lRet := Ascan( aCols, {|aLine| ! aLine[Len(aLine)] .And. nExcMin >= aLine[nPosExcMin] }, 2 ) == 0
		//-- Na ultima linha Valida p/ cima
		ElseIf n == Len( aCols )
			lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .And. nExcMin <= aLine[nPosExcMin]}, 1, Len( Acols ) - 1 ) == 0
		//-- Valida Acima e Abaixo
		Else
			lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.And. nExcMin <= aLine[nPosExcMin]} , 1, n - 1 ) == 0
			
			lRet := lRet .And. ;
					   Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .And. nExcMin >= aLine[nPosExcMin] }, n + 1 ) == 0
		EndIf
	
		If !lRet
			Help("",1, STR0051, , STR0055, 4, 1)// "Complemento de Sub-Faixa" ## "Valores informados Inválidos"
		EndIf
	EndIf
	
EndIf
RestInter()
Return lRet

/*/{Protheus.doc} TMA010Act
	
@author Daniel
@since 22/11/2013
@version 1.0
		
@param ${oModel,lTDA}, ${Modelo de Dados, indica se a tabela possui TDA}

@return ${Nil}, ${Não possui retorno}

@description

Ativação do Modelo - carrega-se aqui dados adicionais, como componente cadastrado em região superior

/*/
Function TMA010Act(oModel,lTDA)
Local aAreas	:= {	DT3->(GetArea()),;
						GetArea()}
Local nCnt
Local lSeekLine
Local nSavOp	:= oModel:GetOperation()
Local cSeekDTK
//-- Executado a partir do Mile
Local lMile      	:= IsInCallStack("CFG600LMdl") .Or. IsInCallStack("FWMILEIMPORT") .Or. IsInCallStack("FWMILEEXPORT") .Or. IsInCallStack("MileDOperation")

If !lMile
	//-- Manipula-se o atributo do MVC para poder carregar dados na tela
	If oModel:GetOperation() != MODEL_OPERATION_UPDATE .And. oModel:GetOperation() != MODEL_OPERATION_INSERT
		oModel:nOperation := MODEL_OPERATION_UPDATE
	EndIf
	
	//-- Carrega Complemento com todos os Componentes. Caso tenha não tenha o componente na DTK, o traz deletado no Grid
	oModel:GetModel( "GdDTK" ):SetNoInsertLine( .F. )
	If lTDA
		oModel:GetModel( "GdDVY" ):SetNoInsertLine( .F. )
	EndIf
	For nCnt  := 1 To Len(aCompTab)
		If oModel:GetModel("GdDTK"):GetLine() == 1 .And. Empty(oModel:GetValue("GdDTK","DTK_CODPAS"))
			oModel:SetValue("GdDTK", "DTK_TABFRE", DT0->DT0_TABFRE)
			oModel:SetValue("GdDTK", "DTK_TIPTAB", DT0->DT0_TIPTAB)
			oModel:SetValue("GdDTK", "DTK_CODPRO", DT0->DT0_CODPRO)
			oModel:SetValue("GdDTK", "DTK_CODPAS", aCompTab[nCnt][1])
			oModel:SetValue("GdDTK", "DTK_DESPAS", Posicione("DT3", 1, xFilial("DT3")+aCompTab[nCnt][1], "DT3->DT3_DESCRI" ))
			oModel:GetModel("GdDTK"):DeleteLine()
		Else		
			lSeekLine := oModel:GetModel("GdDTK"):SeekLine({{"DTK_CODPAS",aCompTab[nCnt][1]}})
			If !lSeekLine .And. oModel:GetModel("GdDTK"):AddLine() > 0 
				oModel:SetValue("GdDTK", "DTK_TABFRE", DT0->DT0_TABFRE)
				oModel:SetValue("GdDTK", "DTK_TIPTAB", DT0->DT0_TIPTAB)
				oModel:SetValue("GdDTK", "DTK_CODPRO", DT0->DT0_CODPRO)
				oModel:SetValue("GdDTK", "DTK_CODPAS", aCompTab[nCnt][1])
				oModel:SetValue("GdDTK", "DTK_DESPAS", Posicione("DT3", 1, xFilial("DT3") + aCompTab[nCnt][1], "DT3->DT3_DESCRI" ))
				oModel:GetModel("GdDTK"):DeleteLine()
			EndIf
		EndIf
		
		//-- Na visualização verifica se busca DTK da estrutura superior
		//-- Verificar se existe Valores Minimos (DTK) para o componente e carregar o array auxiliar. 
		//-- Se o componente for taxa, os seus valores minimos poderao estar cadastrados no estado. Neste caso,
		//-- o seek no DTK, sera' dado com as regioes origem / destino retornados pela funcao TMSTabela().
		//-- Se o componente NAO for taxa, o seek no DTK sera' dado  com as Regioes Origem / Destino,
		//-- informadas na Tabela de Frete.
		If nSavOp == MODEL_OPERATION_VIEW .And. !Empty(aCompTab[nCnt][4])
			DTK->(DbSetOrder(1)) //-- DTK_FILIAL+DTK_TABFRE+DTK_TIPTAB+DTK_CDRORI+DTK_CDRDES+DTK_CODPRO+DTK_CODPAS
			cSeekDTK := xFilial("DTK")+DT0->(DT0_TABFRE+DT0_TIPTAB+DT0_CDRORI+DT0_CDRDES+DT0_CODPRO)
			If !DTK->( MsSeek( cSeekDTK + aCompTab[nCnt][1] ) ) .Or. (Empty(DTK->DTK_VALMIN) .And. Empty(DTK->DTK_EXCMIN))
				cSeekDTK := xFilial("DTK")+DT0->DT0_TABFRE+DT0->DT0_TIPTAB+aCompTab[nCnt][4]+aCompTab[nCnt][5]+DT0->DT0_CODPRO
				DTK->( MsSeek( cSeekDTK + aCompTab[nCnt][1] ) )
			EndIf
			If !DTK->(Eof())
				If oModel:GetModel("GdDTK"):IsDeleted()
					oModel:GetModel("GdDTK"):UnDeleteLine()
				EndIf
				aEval(oModel:GetModel("GdDTK"):aHeader,{|x| Iif(x[10] != "V",;
												oModel:SetValue( "GdDTK", x[2], DTK->(FieldGet(FieldPos(x[2]))) ) ,;
												oModel:SetValue( "GdDTK", x[2], CriaVar(x[2]) ) ) })
	
				oModel:SetValue("GdDTK","DTK_DESPAS","* " + Left(Posicione("DT3", 1, xFilial("DT3")+aCompTab[nCnt][1], "DT3->DT3_DESCRI" ),Len(DT3->DT3_DESCRI)-2))
			EndIf
		EndIf
		DT3->(DbGoTo(aCompTab[nCnt][3]))
		If lTDA .And. DT3->DT3_TIPFAI != StrZero(13,Len(DT3->DT3_TIPFAI)) .And. DT3->DT3_TIPFAI != StrZero(14,Len(DT3->DT3_TIPFAI))
			If oModel:GetModel("GdDVY"):GetLine() == 1 .And. Empty(oModel:GetValue("GdDVY","DVY_CODPAS"))
				oModel:SetValue("GdDVY", "DVY_TABFRE", DT0->DT0_TABFRE)
				oModel:SetValue("GdDVY", "DVY_TIPTAB", DT0->DT0_TIPTAB)
				oModel:SetValue("GdDVY", "DVY_CODPRO", DT0->DT0_CODPRO)
				oModel:SetValue("GdDVY", "DVY_CODPAS",aCompTab[nCnt][1])
				oModel:SetValue("GdDVY", "DVY_DESPAS",Posicione("DT3", 1, xFilial("DT3")+aCompTab[nCnt][1], "DT3->DT3_DESCRI" ))
				oModel:GetModel("GdDVY"):DeleteLine()
			Else
				lSeekLine := oModel:GetModel("GdDVY"):SeekLine({{"DVY_CODPAS",aCompTab[nCnt][1]}})
				If !lSeekLine .And. oModel:GetModel("GdDVY"):AddLine() > 0 
					oModel:SetValue("GdDVY", "DVY_TABFRE", DT0->DT0_TABFRE)
				    oModel:SetValue("GdDVY", "DVY_TIPTAB", DT0->DT0_TIPTAB)
				    oModel:SetValue("GdDVY", "DVY_CODPRO", DT0->DT0_CODPRO)
					oModel:SetValue("GdDVY", "DVY_CODPAS", aCompTab[nCnt][1])
					oModel:SetValue("GdDVY", "DVY_DESPAS", Posicione("DT3", 1, xFilial("DT3")+aCompTab[nCnt][1], "DT3->DT3_DESCRI" ))
					oModel:GetModel("GdDVY"):DeleteLine()
				EndIf
			EndIf
		EndIf
	Next nCnt
	
	oModel:GetModel( "GdDTK" ):SetNoInsertLine( .T. )
	oModel:GetModel( "GdDTK" ):GoLine(1)
	If lTDA
		oModel:GetModel( "GdDVY" ):SetNoInsertLine( .T. )
		oModel:GetModel( "GdDVY" ):GoLine(1)
	EndIf
	
	//-- Verifica se é necessário carregar dados da Tabela de Tarifa
	If nSavOp != MODEL_OPERATION_INSERT .And. !Empty(DT0->DT0_TABTAR)
		M->DT0_TABTAR := DT0->DT0_TABTAR
		TMA10ATar(.T.) //-- Carrega dados de Tarifa
	EndIf
	
	//-- Depois de carregados os dados na tela, retorna os atributos MVC originais
	oModel:lModify := .F.
	If oModel:nOperation != nSavOp
		oModel:nOperation := nSavOp
	EndIf
EndIf //-- lMile
aEval(aAreas,{|xArea| RestArea(xArea)})

Return Nil


/*/{Protheus.doc} TMA010Comm
	
@author Daniel
@since 22/11/2013
@version 1.0
		
@param ${oModel}, ${Modelo de Dados}

@return ${lRet}, ${Se confirmou a gravação}

@description

Realiza a gravação do modelo

/*/
Static Function TMA010Comm(oModel)
Local lRet := .T.
Local nOpc := oModel:GetOperation()
Local lNeedDel := oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. !Empty(M->DT0_TABTAR) .And. Empty(DT0->DT0_TABTAR)

If lNeedDel
	FwFormCommit(oModel/*oModel*/,/*bBefore*/,{|oModel,cID,cAlias,lNewRecord| TMA010CmmA(oModel,cID,cAlias,lNewRecord)} /*bAfter*/,/*bAfterSTTS*/)
Else
	FwFormCommit(oModel/*oModel*/,/*bBefore*/,/*bAfter*/,/*bAfterSTTS*/)
EndIf
			
If ExistBlock("TMA010GRV")
	ExecBlock('TMA010GRV',.F.,.F.,nOpc)
Endif

Return lRet

/*/{Protheus.doc} TMA010CmmA
	
@author Daniel
@since 22/11/2013
@version 1.0
		
@param ${oModel,cID,cAlias,lNewRecord}, ${Modelo de Dados, ID, Alias, indicação de novo registro}

@return ${.T.}, ${Sempre sucesso}

@description

Complementa a gravação do modelo - Quando utiliza tarifa, não grava o(s) componente(s) da tarifa e exclui-os, se estiveram outrora gravados. 

/*/
Static Function TMA010CmmA(oModel,cID,cAlias,lNewRecord)
Local aAreas := {	DTG->(GetArea()),;
					DT1->(GetArea()),;
					DW1->(GetArea()),;
					DY1->(GetArea()),;
					GetArea()}
Local nCnt
Local cChave

If AllTrim(cID) == "MdFieldCDT0"
	//-- Percorre os componentes da tabela de Frete
	For nCnt := 1 To Len(aCompTab)
	
		//-- Se encontrar o componente de Tarifa, busca e deleta os dados deste componente nos Itens da Tabela de Frete, Sub-Faixa e Complemento da Sub-Faixa.
		DTG->(DbSetOrder(1)) //-- DTG_FILIAL+DTG_TABFRE+DTG_TIPTAB+DTG_TABTAR+DTG_CODPAS+DTG_ITEM
		If DTG->( DbSeek( xFilial("DTG") + M->DT0_TABFRE +M->DT0_TIPTAB+M->DT0_TABTAR+aCompTab[ nCnt, 1 ]) )
	
			//-- Deleta todos os Itens da Tabela de Frete do Componente que possui Tarifa
			DT1->(DbSetOrder(1)) //-- DT1_FILIAL+DT1_TABFRE+DT1_TIPTAB+DT1_CDRORI+DT1_CDRDES+DT1_CODPRO+DT1_CODPAS+DT1_ITEM
			DT1->(DbSeek( cChave := xFilial("DT1")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO+aCompTab[ nCnt, 1 ]))
			Do While DT1->(!Eof()) .And. cChave == DT1->(DT1_FILIAL+DT1_TABFRE+DT1_TIPTAB+DT1_CDRORI+DT1_CDRDES+DT1_CODPRO+DT1_CODPAS)
				RecLock("DT1",.F.)
				DT1->(DbDelete())
				DT1->(MsUnLock())
				DT1->(DbSkip())
			EndDo
		
			//-- Deleta todas as Sub-Faixas do Componente que possui Tarifa
			DW1->(DbSetOrder(1)) //-- DW1_FILIAL+DW1_TABFRE+DW1_TIPTAB+DW1_CDRORI+DW1_CDRDES+DW1_CODPRO+DW1_CODPAS+DW1_ITEDT1+DW1_ITEM
			DW1->(DbSeek( cChave := xFilial("DW1")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO+aCompTab[ nCnt, 1 ]))
			Do While DW1->(!Eof()) .And. cChave == DW1->(DW1_FILIAL+DW1_TABFRE+DW1_TIPTAB+DW1_CDRORI+DW1_CDRDES+DW1_CODPRO+DW1_CODPAS)
				RecLock("DW1",.F.)
				DW1->(DbDelete())
				DW1->(MsUnlock())
				DW1->(DbSkip())
			EndDo
		
			//-- Deleta todos os Complementos de Sub-Faixa do Componente que possui Tarifa
			DY1->(DbSetOrder(1)) //-- DY1_FILIAL+DY1_TABFRE+DY1_TIPTAB+DY1_CDRORI+DY1_CDRDES+DY1_CODPRO+DY1_CODPAS+DY1_ITEDT1+DY1_ITEM
			DY1->(DbSeek(cChave := xFilial("DY1")+M->DT0_TABFRE+M->DT0_TIPTAB+M->DT0_CDRORI+M->DT0_CDRDES+M->DT0_CODPRO+aCompTab[ nCnt, 1 ]))
			Do While DY1->(!Eof()) .And. cChave == DY1->(DY1_FILIAL+DY1_TABFRE+DY1_TIPTAB+DY1_CDRORI+DY1_CDRDES+DY1_CODPRO+DY1_CODPAS)
				RecLock("DY1",.F.)
				DY1->(DbDelete())
				MsUnlock()
				DY1->( DbSkip())
			EndDo
		EndIf
	Next nCnt
EndIf
aEval(aAreas,{|xArea| RestArea(xArea)})

Return .T.

/*/{Protheus.doc} TMA10ATar
	
@author Daniel
@since 22/11/2013
@version 1.0
		
@param ${lActivate}, ${Indica se fora chamado na Ativação do modelo}

@return ${.T.}, ${Sempre sucesso}

@description

Preenche os dados de Tarifa na tela, realizando tratamentos necessários  

/*/
Function TMA10ATar(lActivate)
Local aAreas	:= {	DTG->(GetArea()),;
						DW0->(GetArea()),;
						DY0->(GetArea()),;
						DT3->(GetArea()),;
						GetArea()}
Local oModel 	:= FwModelActive()
Local oView 	:= FwViewActive()
Local lTDA		:= .F.
Local nCnt		:= 0
Local nCntFor,nSubFx

Default lActivate := .F.

For nCnt := 1 To Len(aCompTab)
	DT3->(DbGoTo(aCompTab[nCnt][3]))
	
	lTDA := lTDA .Or. DT3->DT3_TIPFAI == StrZero(13,Len(DT3->DT3_TIPFAI))

	//-- Deve-se alterar as permissões do Grid antes de manipula-lo
	oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):SetOnlyQuery( .F. )
	oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):SetNoInsertLine( .F. )
	oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):SetNoUpdateLine( .F. )
	oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):SetNoDeleteLine( .F. )
	
	If !Empty(DT3->DT3_FAIXA2)
		oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):SetOnlyQuery( .F. )
		oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):SetNoInsertLine( .F. )
		oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):SetNoUpdateLine( .F. )
		oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):SetNoDeleteLine( .F. )
	
		oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):SetOnlyQuery( .F. )
		oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):SetNoInsertLine( .F. )
		oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):SetNoUpdateLine( .F. )
		oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):SetNoDeleteLine( .F. )
	EndIf
	
	//-- Deleta todas as linhas dos Grid's. No DT1, altera o campo DT1_TARIFA para 2-Não  
	If !lActivate
		For nCntFor := 1 To oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):Length()
			oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):GoLine(nCntFor)
	
			If oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):IsDeleted()
				oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):UnDeleteLine()
			EndIf
			oModel:SetValue("GdDT1_"+aCompTab[ nCnt, 1 ],"DT1_TARIFA","2")  
	
			//-- Se houver sub-faixa, deleta todas as linhas dos GRid's de Subfaixa e complemento da subfaixa
			If !Empty(DT3->DT3_FAIXA2)
				For nSubFx := 1 To oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):Length()
					oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):GoLine(nSubFx)
					If !oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):IsDeleted()
						oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):DeleteLine()
					EndIf
				Next nSubFx
				oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):GoLine(1)
		
				For nSubFx := 1 To oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):Length()
					oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):GoLine(nSubFx)
					If !oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):IsDeleted()
						oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):DeleteLine()
					EndIf
				Next nSubFx
				oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):GoLine(1)
			EndIf
			oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):DeleteLine()
		Next nCntFor
		oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):GoLine(1)
	EndIf
	//-- Preenche os Grids pela tabela de Tarifa
	If !Empty(M->DT0_TABTAR)
		nCntFor := 0
		DTG->(DbSetOrder(1)) //-- DTG_FILIAL+DTG_TABFRE+DTG_TIPTAB+DTG_TABTAR+DTG_CODPAS+DTG_ITEM
		DTG->( DbSeek( xFilial("DTG") + M->DT0_TABFRE +M->DT0_TIPTAB+M->DT0_TABTAR+aCompTab[ nCnt, 1 ]) )
		Do While !DTG->(Eof()) .And. DTG->(DTG_FILIAL+DTG_TABFRE+DTG_TIPTAB+DTG_TABTAR+DTG_CODPAS) == ;
											xFilial("DTG") + M->DT0_TABFRE +M->DT0_TIPTAB+M->DT0_TABTAR+aCompTab[ nCnt, 1 ]
			nCntFor++
			If oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):Length() >= nCntFor
				oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):GoLine(nCntFor)
				oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):UnDeleteLine()
			Else
				oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):AddLine()
			EndIf	
			oModel:SetValue("GdDT1_"+aCompTab[ nCnt, 1 ],"DT1_ITEM",DTG->DTG_ITEM)  
			oModel:SetValue("GdDT1_"+aCompTab[ nCnt, 1 ],"DT1_VALATE",DTG->DTG_VALATE)  
			oModel:SetValue("GdDT1_"+aCompTab[ nCnt, 1 ],"DT1_TARIFA","1")  
	
			//-- Para faixa diferente de 1, o campo DT1_FATPES não é colocado no GRID
			If DT3->DT3_FAIXA == StrZero(1, Len(DT3->DT3_FAIXA))
				oModel:SetValue("GdDT1_"+aCompTab[ nCnt, 1 ],"DT1_FATPES",DTG->DTG_FATPES)  
			EndIf
	
			//-- Para Sub-faixa, os campos DT1_VALOR e DT1_INTERV não são colocados no GRID
			If Empty(DT3->DT3_FAIXA2)
				oModel:SetValue("GdDT1_"+aCompTab[ nCnt, 1 ],"DT1_VALOR",DTG->DTG_VALOR)  
				oModel:SetValue("GdDT1_"+aCompTab[ nCnt, 1 ],"DT1_INTERV",DTG->DTG_INTERV)  
			Else
				//-- Preenche sub-faixa e complemento da sub-faixa
				nSubFx := 0
				DW0->(DbSetOrder(1)) //-- DW0_FILIAL+DW0_TABFRE+DW0_TIPTAB+DW0_TABTAR+DW0_CODPAS+DW0_ITEDTG+DW0_ITEM
				DW0->(DbSeek(	xFilial("DW0")+DTG->(DTG_TABFRE+DTG_TIPTAB+DTG_TABTAR+DTG_CODPAS+DTG_ITEM) ))
				Do While DW0->(!Eof()) .And. DW0->(DW0_FILIAL+DW0_TABFRE+DW0_TIPTAB+DW0_TABTAR+DW0_CODPAS+DW0_ITEDTG) == xFilial("DW0")+DTG->(DTG_TABFRE+DTG_TIPTAB+DTG_TABTAR+DTG_CODPAS+DTG_ITEM)

					nSubFx++
					If oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):Length() >= nSubFx
						oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):GoLine(nSubFx)
						oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):UnDeleteLine()
					Else
						oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):AddLine()
					EndIf
				
					oModel:SetValue("GdDW1_"+aCompTab[ nCnt, 1 ],"DW1_ITEM",DW0->DW0_ITEM)  
					If DT3->DT3_FAIXA2 == StrZero(1, Len(DT3->DT3_FAIXA2))
						oModel:SetValue("GdDW1_"+aCompTab[ nCnt, 1 ],"DW1_FATPES",DW0->DW0_FATPES)  
					EndIf
					
					oModel:SetValue("GdDW1_"+aCompTab[ nCnt, 1 ],"DW1_VALATE",DW0->DW0_VALATE)  
					oModel:SetValue("GdDW1_"+aCompTab[ nCnt, 1 ],"DW1_VALOR" ,DW0->DW0_VALOR)  
					oModel:SetValue("GdDW1_"+aCompTab[ nCnt, 1 ],"DW1_INTERV",DW0->DW0_INTERV)  
					DW0->(DbSkip())
				EndDo
				oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):GoLine(1)
				
				nSubFx := 0
				DY0->(DbSetOrder(1)) //-- DY0_FILIAL+DY0_TABFRE+DY0_TIPTAB+DY0_TABTAR+DY0_CODPAS+DY0_ITEDTG+DY0_ITEM
				DY0->(DbSeek(	xFilial("DY0")+DTG->(DTG_TABFRE+DTG_TIPTAB+DTG_TABTAR+DTG_CODPAS+DTG_ITEM) ))
				Do While DY0->(!Eof()) .And. DY0->(DY0_FILIAL+DY0_TABFRE+DY0_TIPTAB+DY0_TABTAR+DY0_CODPAS+DY0_ITEDTG) == xFilial("DY0")+DTG->(DTG_TABFRE+DTG_TIPTAB+DTG_TABTAR+DTG_CODPAS+DTG_ITEM)
				
					nSubFx++
					If oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):Length() >= nSubFx
						oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):GoLine(nSubFx)
						oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):UnDeleteLine()
					Else
						oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):AddLine()
					EndIf
				
					oModel:SetValue("GdDY1_"+aCompTab[ nCnt, 1 ],"DY1_ITEM" 		,DY0->DY0_ITEM)  
					oModel:SetValue("GdDY1_"+aCompTab[ nCnt, 1 ],"DY1_EXCMIN"	,DY0->DY0_EXCMIN)  
					oModel:SetValue("GdDY1_"+aCompTab[ nCnt, 1 ],"DY1_VALMIN"	,DY0->DY0_VALMIN)  
					oModel:SetValue("GdDY1_"+aCompTab[ nCnt, 1 ],"DY1_VALMAX"	,DY0->DY0_VALMAX)  
					oModel:SetValue("GdDY1_"+aCompTab[ nCnt, 1 ],"DY1_VALOR" 	,DY0->DY0_VALOR)  
					oModel:SetValue("GdDY1_"+aCompTab[ nCnt, 1 ],"DY1_INTERV"	,DY0->DY0_INTERV)  
					DY0->(DbSkip())
				EndDo
				oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):GoLine(1)
			EndIf
	
			
			DTG->(DbSkip())
		EndDo
		oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):GoLine(1)

		//-- Os grid's dos componentes de Tarifa são marcados para que não sejam gravados e tem sua edição bloqueada.
		If !Empty(nCntFor)
			oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):SetOnlyQuery( .T. )
			oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):SetNoInsertLine( .T. )
			oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):SetNoUpdateLine( .T. )
			oModel:GetModel("GdDT1_"+aCompTab[ nCnt, 1 ]):SetNoDeleteLine( .T. )
			If !Empty(DT3->DT3_FAIXA2)
				oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):SetOnlyQuery( .T. )
				oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):SetNoInsertLine( .T. )
				oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):SetNoUpdateLine( .T. )
				oModel:GetModel("GdDW1_"+aCompTab[ nCnt, 1 ]):SetNoDeleteLine( .T. )

				oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):SetOnlyQuery( .T. )
				oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):SetNoInsertLine( .T. )
				oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):SetNoUpdateLine( .T. )
				oModel:GetModel("GdDY1_"+aCompTab[ nCnt, 1 ]):SetNoDeleteLine( .T. )
			EndIf
		EndIf
	EndIf
	
Next nCnt

aEval(aAreas,{|xArea| RestArea(xArea)})
Return .T.

/*/{Protheus.doc} TMA010Comp
	
@author Daniel
@since 22/11/2013
@version 1.0
		
@param ${cTabFre,cTipTab}, ${Tabela de frete, tipo da tabela}

@return ${aReturn}, ${Array com os componentes da tabela de frete selecionada}

@description

Retorna os componentes de frete de uma dada tabela de frete e tipo

/*/
Static Function TMA010Comp( cTabFre, cTipTab, lAllTypes )
Local aArea		:= GetArea()
Local aReturn		:= {}
Local cQuery		:= ""
Local cAliasQry	:= GetNextAlias()

Default lAllTypes := .F.

cQuery := " SELECT DT3_CODPAS, DT3_DESCRI, DT3_TIPFAI, DT3_FAIXA2, DT3.R_E_C_N_O_ AS RECDT3 "
cQuery += "   FROM " + RetSqlName( "DVE" ) + " DVE "
cQuery += " INNER JOIN " + RetSqlName( "DT3" ) + " DT3 "
cQuery += "    ON DT3.DT3_FILIAL = '"+ xFilial( "DT3" ) +"' "
cQuery += "   AND DT3.DT3_CODPAS = DVE_CODPAS "

//-- Se o componente for "Praca de Pedagio" ou "Cliente Destinatario" ou "Herda Valor" ou "TDA x Regiao", nao devera aparecer no folder 
If !lAllTypes
	cQuery += "   AND DT3.DT3_TIPFAI NOT IN( '"+ StrZero(9, Len(DT3->DT3_TIPFAI))+"', '"+StrZero(15, Len(DT3->DT3_TIPFAI))+"', '"+StrZero(16, Len(DT3->DT3_TIPFAI))+"', '"+StrZero(18, Len(DT3->DT3_TIPFAI))+"')"
EndIf
cQuery += "   AND DT3.D_E_L_E_T_ = '' "
cQuery += " WHERE DVE.DVE_FILIAL = '"+ xFilial( "DVE" ) +"' "
cQuery += "   AND DVE.DVE_TABFRE = '"+ cTabFre+ "' "
cQuery += "   AND DVE.DVE_TIPTAB = '"+ cTipTab+ "' "
cQuery += "   AND DVE.D_E_L_E_T_ = ' '"

DVE->(DbSetOrder(1)) //-- DVE_FILIAL+DVE_TABFRE+TIPTAB+ITEM
cQuery += " ORDER BY "+StrTran(DVE->(IndexKey()),"+",",")

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->( !Eof() )
	

	aAdd( aReturn, { (cAliasQry)->DT3_CODPAS, (cAliasQry)->DT3_DESCRI,(cAliasQry)->RECDT3,/*cCdrOri*/,/*cCdrDes*/} )	                   
	
	/*Todo:verificar, qdo não inclusão ou alteração, se há dados a serem exibidos... deve-se?? */ 
	
	(cAliasQry)->( DbSkip() )
EndDo
     
(cAliasQry)->( DbCloseArea() )

RestArea( aArea )

Return( aReturn )

/*/{Protheus.doc} TMA010AGet
	
@author Daniel
@since 22/11/2013
@version 1.0
		
@param ${cId,cCpo}, ${Id do componente, Campo}

@return ${uRet}, ${Conteúdo do campo no componente}

@description

Função criada como contorno para o relation, que não respeita o Owner no componente  

/*/
Function TMA010AGet(cId,cCpo)
Local uRet := CriaVar(cCpo,.T.)
Local oModel := FwModelActive()
Local oMdlId

If oModel != Nil
	oMdlId := oModel:GetModel(cId)
	If oMdlId != Nil
		uRet := oMdlId:GetValue(cCpo)
	EndIf
EndIf
Return uRet

/*/{Protheus.doc} Menudef
	
@author Daniel
@since 22/11/2013
@version 1.0
		
@param $Nenhum, $Nil

@return $aRotina, $Array com os dados de menu da rotina

@description

Menu Funcional

/*/
Static Function MenuDef()
Private aRotina := {}
     
ADD OPTION aRotina TITLE STR0002 	ACTION "AxPesqui"			OPERATION 1 ACCESS 0   //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.TMSA010"	OPERATION 2 ACCESS 0   //"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION "TMSA010AInc"	    OPERATION 3 ACCESS 0   //"Incluir"
ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.TMSA010"	OPERATION 4 ACCESS 0   //"Alterar"
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.TMSA010"	OPERATION 5 ACCESS 0   //"Excluir"
ADD OPTION aRotina TITLE STR0008 	ACTION "TMSA010Cop" 		OPERATION 7 ACCESS 0   //"Copiar"
ADD OPTION aRotina TITLE STR0012 	ACTION "TMSA010Est"		OPERATION 8 ACCESS 0   //"Estrutura"

If ExistBlock("TMA010MNU")
	ExecBlock("TMA010MNU",.F.,.F.)
EndIf

Return aRotina

/*/{Protheus.doc} TMA010AGet
	
@author Daniel
@since 22/11/2013
@version 1.0
		
@param ${cTabFre,cTipTab,cCateg}, ${Tabela de frete, tipo, Categoria}

@return ${Nil}, ${Não há retorno}

@description

Função criada para permitir setar a Tabela de Frete, Tipo e categoris, permitindo configuração Mile extendendo o modelo  

/*/
Function TMSA010Set(cTabFre,cTipTab,cCateg)

aTabINC := {cTabFre,cTipTab}
cCatTab := cCateg

Return

/*/{Protheus.doc} TMSA010DJS
//Fun��o utilizada no gatilho do campo DJS_PERCEN para replicar as informa��es para o grid, de acordo com CheckBox marcado
@author caio.y
@since 13/03/2017
@version undefined

@type function
/*/
Function TMSA010DJS()
Local lCheck		:= .F. 
Local nPercen		:= FwFldGet("DJS_PERCEN")
Local oModel		:= FwModelActive()
Local oView			:= FwViewActive()
Local cCodPas		:= FwFldGet("DJS_CODPAS")
Local nPos			:= 0
Local aSaveLine		:= FWSaveRows() 
Local cId			:= ""
Local oMdlGrid		:= Nil
Local aCurrntSel 	:= oView:GetCurrentSelect() 
Local nLine			:= 1
Local lInicia		:= .F. 
Local nLineBack		:= 1

cId			:= aCurrntSel[1]
cId			:= SubStr( cId, At( "_", cId ) + 1  ) 
oMdlGrid	:= oModel:GetModel("GdDJS_" + cID )

nPos	:= aScan(aCheck, {|x|x[1] == cId  })

If nPos > 0 
	lCheck	:= eVal( aCheck[nPos][2]:bSetGet ) 
	
	If lCheck
					
		For nLine := 1 To oMdlGrid:Length()
			oMdlGrid:GoLine(nLine)
			
			If cCodPas == oMdlGrid:GetValue("DJS_CODPAS")
				lInicia		:= .T. 
				nLineBack	:= nLine
			Else
				If lInicia
					oMdlGrid:LoadValue("DJS_PERCEN",nPercen)
				EndIf	
			Endif
						
		Next nLine
		
		If lInicia
			oMdlGrid:GoLine(nLineBack)
		EndIf
		
		oView:Refresh()
	EndIf
			
EndIf
	
FWRestRows( aSaveLine )
Return nPercen
