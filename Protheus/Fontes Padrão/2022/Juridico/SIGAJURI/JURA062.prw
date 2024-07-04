#INCLUDE "JURA062.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA062
Valores Atualizáveis

@author Juliana Iwayama Velho
@since 18/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA062()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 )
oBrowse:SetAlias( "NW8" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NW8" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Juliana Iwayama Velho
@since 19/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } )  //"Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA062", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA062", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA062", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA062", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.JURA062", 0, 8, 0, NIL } ) //"Imprimir"
aAdd( aRotina, { STR0012, "JA062CONFG"     , 0, 3, 0, NIL } ) // "Config. Inicial"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Valores Atualizáveis

@author Juliana Iwayama Velho
@since 19/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA062" )
Local oStruct := FWFormStruct( 2, "NW8" )

JurSetAgrp( "NW8",, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA062", oStruct, "NW8MASTER"  )
oView:CreateHorizontalBox( "NW8MASTER" , 100 )
oView:SetOwnerView( "JURA062", "NW8MASTER" )

oView:SetDescription( STR0001 )
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Valores Atualizáveis

@author Juliana Iwayama Velho
@since 19/01/10
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel  := NIL
Local oStruct := FWFormStruct( 1, "NW8" )
//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA062", /*Pre-Validacao*/, {|oX| JA002TOK(oX)}/*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NW8MASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 )

oModel:GetModel( "NW8MASTER" ):SetDescription( STR0009 )

JurSetRules( oModel, "NW8MASTER",, "NW8" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002VTipo
Valida o tipo do campo

@param 	cCampo  	Nome do campo
@param 	cTipo  		Tipo do campo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 11/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA002VTipo(cCampo,cTipo)
Local lRet := IIF(AVSX3(FwFldGet(cCampo))[2] == cTipo,.T.,.F.)

If !lRet
    JurMsgErro(STR0010)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA002TOK
Valida informações ao salvar.

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 11/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA002TOK(oModel)
Local lRet := .T.

//Se o tipo de data for juros, é necessário escolher o campo de data
If FwFldGet('NW8_DJUROS') == '4' .And. Empty(FwFldGet('NW8_CDATAJ'))
	lRet := .F.
    JurMsgErro(STR0011+Rettitle('NW8_CDATAJ'))
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA062CONFG
Realiza a carga inicial da configuração de índices
@Return lRet	 	.T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 06/03/10
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA062CONFG()
Local lRet     := .T.
Local oModel   := ModelDef()
Local aArea    := GetArea()
Local aAreaNW8 := NW8->( GetArea() )
Local aDados   := {}
Local nI       := 0

	aDados := {}

//Objetos
If !JA062EXCON('NSY','NSY_PEVLR')
	aAdd(aDados,{'01','NSY','NSY_CCOMON','NSY_PEVLR' ,'NSY_PEDATA','NSY_PEVLRA','4','NSY_DTJURO','NSY_DTULAT','NSY_PERMUL','NSY_DTMULT','NSY_MULATU','NSY_CCORPE','NSY_CJURPE','NSY_TOTPED','NSY_TOPEAT','NZ1_PEVLRA'})
EndIf
If !JA062EXCON('NSY','NSY_V1VLR')
	aAdd(aDados,{'02','NSY','NSY_CFCOR1','NSY_V1VLR' ,'NSY_V1DATA','NSY_V1VLRA','4','NSY_DTJUR1','NSY_DTULAT','NSY_PERMU1','NSY_DTMUL1','NSY_MULAT1','NSY_CCORP1','NSY_CJURP1','NSY_TOTOR1','NSY_TOTAT1','NZ1_V1VLRA'})
EndIf
If !JA062EXCON('NSY','NSY_V2VLR')
	aAdd(aDados,{'03','NSY','NSY_CFCOR2','NSY_V2VLR' ,'NSY_V2DATA','NSY_V2VLRA','4','NSY_DTJUR2','NSY_DTULAT','NSY_PERMU2','NSY_DTMUL2','NSY_MULAT2','NSY_CCORP2','NSY_CJURP2','NSY_TOTOR2','NSY_TOTAT2','NZ1_V2VLRA'})
EndIf
If !JA062EXCON('NSY','NSY_TRVLR')
	aAdd(aDados,{'04','NSY','NSY_CFCORT','NSY_TRVLR' ,'NSY_TRDATA','NSY_TRVLRA','4','NSY_DTJURT','NSY_DTULAT','NSY_PERMUT','NSY_DTMUTR','NSY_VLRMUT','NSY_CCORPT','NSY_CJURPT','NSY_TOTORT','NSY_TOTATT','NZ1_TRVLRA'})
EndIf
If !JA062EXCON('NSY','NSY_VLCONT')
	aAdd(aDados,{'05','NSY','NSY_CFCORC','NSY_VLCONT','NSY_DTCONT','NSY_VLCONA','4','NSY_DTJURC','NSY_DTULAT','NSY_PERMUC','NSY_DTMULC','NSY_MULATC','NSY_CCORPC','NSY_CJURPC','NSY_TOTORC','NSY_TOTATC','NZ1_VLCONA'})
EndIf
If !JA062EXCON('NSY','NSY_VLRMUL')
	aAdd(aDados,{'11','NSY','NSY_CFCMUL','NSY_VLRMUL','NSY_DTAMUL','NSY_MUATUA','4','NSY_DTINCM','NSY_DTULAT',''          ,''          ,''          ,'NSY_CCORMP','NSY_CJURMP','NSY_TOTPED','NSY_TOPEAT','NZ1_MUATUA'})
EndIf
If !JA062EXCON('NSY','NSY_VLRJUR')
	aAdd(aDados,{'12','NSY','NSY_FCJURO','NSY_VLRJUR','NSY_DTJURJ','NSY_JURATU','4','NSY_DTINJU','NSY_DTULAT',''          ,''          ,''          ,'NSY_CCORJP','NSY_CJURJP','NSY_TOTPED','NSY_TOPEAT','NZ1_JURATU'})
EndIf
If !JA062EXCON('NSY','NSY_VLRMU1')
	aAdd(aDados,{'13','NSY','NSY_CFJUR1','NSY_VLRMU1','NSY_DTMUT1','NSY_MUATU1','4','NSY_DTINC1','NSY_DTULAT',''          ,''          ,''          ,'NSY_CCORM1','NSY_CJURM1','NSY_TOTOR1','NSY_TOTAT1','NZ1_MUATU1'})
EndIf
If !JA062EXCON('NSY','NSY_VLRJU1')
	aAdd(aDados,{'14','NSY','NSY_FCJUR1','NSY_VLRJU1','NSY_DTJU1' ,'NSY_JUATU1','4','NSY_DTINJ1','NSY_DTULAT',''          ,''          ,''          ,'NSY_CCORJ1','NSY_CJURJ1','NSY_TOTOR1','NSY_TOTAT1','NZ1_JUATU1'})
EndIf
If !JA062EXCON('NSY','NSY_VLRMU2')
	aAdd(aDados,{'15','NSY','NSY_CFMUL2','NSY_VLRMU2','NSY_DTMUT2','NSY_MUATU2','4','NSY_DTINC2','NSY_DTULAT',''          ,''          ,''          ,'NSY_CCORM2','NSY_CJURM2','NSY_TOTOR2','NSY_TOTAT2','NZ1_MUATU2'})
EndIf
If !JA062EXCON('NSY','NSY_VLRJU2')
	aAdd(aDados,{'16','NSY','NSY_FCJUR2','NSY_VLRJU2','NSY_DTJU2' ,'NSY_JUATU2','4','NSY_DTINJ2','NSY_DTULAT',''          ,''          ,''          ,'NSY_CCORJ2','NSY_CJURJ2','NSY_TOTOR2','NSY_TOTAT2','NZ1_JUATU2'})
EndIf
If !JA062EXCON('NSY','NSY_VLRMT')
	aAdd(aDados,{'17','NSY','NSY_CFMULT','NSY_VLRMT' ,'NSY_DTMUTT','NSY_MUATT' ,'4','NSY_DTINCT','NSY_DTULAT',''          ,''          ,''          ,'NSY_CCORMT','NSY_CJURMT','NSY_TOTORC','NSY_TOTATC','NZ1_MUATT' })
EndIf
If !JA062EXCON('NSY','NSY_VLRJUT')
	aAdd(aDados,{'18','NSY','NSY_FCJURT','NSY_VLRJUT','NSY_DTJUT' ,'NSY_JUATUT','4','NSY_DTINJT','NSY_DTULAT',''          ,''          ,''          ,'NSY_CCORJT','NSY_CJURJT','NSY_TOTORT','NSY_TOTATT','NZ1_JUATUT'})
EndIf
If !JA062EXCON('NSY','NSY_VLRMUC')
	aAdd(aDados,{'19','NSY','NSY_CFMULC','NSY_VLRMUC','NSY_DTMUTC','NSY_MUATC' ,'4','NSY_DTINCC','NSY_DTULAT',''          ,''          ,''          ,'NSY_CCORMC','NSY_CJURMC','NSY_TOTORC','NSY_TOTATC','NZ1_MUATC' })
EndIf
If !JA062EXCON('NSY','NSY_CLRJUC')
	aAdd(aDados,{'20','NSY','NSY_FCJURC','NSY_CLRJUC','NSY_DTJUC' ,'NSY_JUATUC','4','NSY_DTINJC','NSY_DTULAT',''          ,''          ,''          ,'NSY_CCORJC','NSY_CJURJC','NSY_TOTORC','NSY_TOTATC','NZ1_JUATUC'})
EndIf

//Assuntos Jurídicos
If !JA062EXCON('NSZ','NSZ_VLCAUS')
	aAdd(aDados,{'06','NSZ','NSZ_CFCORR','NSZ_VLCAUS','NSZ_DTCAUS','NSZ_VACAUS','3',''          ,'NSZ_DTULAT',''          ,''          ,''          ,''          ,''          ,''          ,''          ,'NYZ_VACAUS'})
EndIf
If !JA062EXCON('NSZ','NSZ_VLENVO')
	aAdd(aDados,{'07','NSZ','NSZ_CFCORR','NSZ_VLENVO','NSZ_DTENVO','NSZ_VAENVO','3',''          ,'NSZ_DTULAT','NSZ_PERMUL',''          ,''          ,''          ,''          ,''          ,''          ,'NYZ_VAENVO'})
EndIf
If !JA062EXCON('NSZ','NSZ_VLPROV')
	aAdd(aDados,{'10','NSZ','NSZ_CFCORR','NSZ_VLPROV','NSZ_DTPROV','NSZ_VAPROV','3',''          ,'NSZ_DTULAT',''          ,''          ,''          ,'NSZ_VCPROV','NSZ_VJPROV',''          ,''          ,'NYZ_VAPROV'})
EndIf
If !JA062EXCON('NSZ','NSZ_VLHIST')
	aAdd(aDados,{'21','NSZ','NSZ_CFCORR','NSZ_VLHIST','NSZ_DTHIST','NSZ_VAHIST','3',''          ,'NSZ_DTULAT',''          ,''          ,''          ,''          ,''          ,''          ,''          ,'NYZ_VAHIST'})
EndIf

//Assuntos Jurídicos - Valores de Contrato
DbSelectArea("NSZ")
If ColumnPos('NSZ_DTCONT') > 0 .And. ColumnPos('NSZ_CMOCON') > 0 .And. ColumnPos('NSZ_VACONT') > 0
	If !JA062EXCON('NSZ','NSZ_VLCONT')
		aAdd(aDados,{GETSXENUM("NW8","NW8_COD"),'NSZ','NSZ_CFCORR','NSZ_VLCONT','NSZ_DTCONT','NSZ_VACONT','3',''          ,'NSZ_DTULAT',''         ,''          ,''          ,''          ,''          ,''          ,''          ,''})
	EndIf
EndIf

//Garantia-Alvara
If !JA062EXCON('NT2','NT2_VALOR')
	aAdd(aDados,{'09','NT2','NT2_CCOMON','NT2_VALOR' ,'NT2_DATA'  ,'NT2_VLRATU','3',''          ,'NT2_DTULAT','NT2_PERMUL','NT2_DTMULT','NT2_MULATU','NT2_VCPROV','NT2_VJPROV',''          ,''          ,'NZ0_VLRATU'})
EndIf

//Contratos - Valores de Aditivos
DbSelectArea("NXY")
If ColumnPos('NXY_DTINVI') > 0 .And. ColumnPos('NXY_DTTMVI') > 0 .And. ;
   ColumnPos('NXY_CFCORR') > 0 .And. ColumnPos('NXY_DTVLAD') > 0 .And. ColumnPos('NXY_CMOADI') > 0 .And. ;
   ColumnPos('NXY_VLADIT') > 0 .And. ColumnPos('NXY_VAADIT') > 0 .And. ColumnPos('NXY_DTULAT') > 0

	If !JA062EXCON('NXY','NXY_VLADIT')
		aAdd(aDados,{GETSXENUM("NW8","NW8_COD"),'NXY','NXY_CFCORR','NXY_VLADIT','NXY_DTVLAD','NXY_VAADIT','3',''          ,'NXY_DTULAT',''          ,''          ,''          ,''          ,''          ,''          ,''          ,''})
	EndIf
EndIf

If Len(aDados) > 0
	For nI := 1 To Len(aDados)
		RecLock('NW8', .T.)
		NW8->NW8_FILIAL := xFilial('NW8')
		NW8->NW8_COD    := aDados[nI][1]
		NW8->NW8_CTABEL := aDados[nI][2]
		NW8->NW8_CFORMA := aDados[nI][3]
		NW8->NW8_CCAMPO := aDados[nI][4]
		NW8->NW8_CDATA  := aDados[nI][5]
		NW8->NW8_CCMPAT := aDados[nI][6]
		NW8->NW8_DJUROS := aDados[nI][7]
		NW8->NW8_CDATAJ := aDados[nI][8]
		NW8->NW8_CDATAU := aDados[nI][9]
		NW8->NW8_CMULTA := aDados[nI][10]
		NW8->NW8_CDTMUL := aDados[nI][11]
		NW8->NW8_MULATU := aDados[nI][12]
		NW8->NW8_CCORRM := aDados[nI][13]
		NW8->NW8_CJUROS := aDados[nI][14]
		NW8->NW8_CTOTOR := aDados[nI][15]
		NW8->NW8_CTOTAT := aDados[nI][16]
		If NW8->(FieldPos('NW8_CAMPH')) > 0
			NW8->NW8_CAMPH  := aDados[nI][17]
		EndIf
		MsUnlock()
	Next
Else
	lRet := .F.
	JurMsgErro( STR0013 )
EndIf

RestArea(aAreaNW8)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA062EXCON
Valida se o valor atualizável já está configurada na NW8

@Param cRelat	Relatório que será validado na NQR

@Return lRet	 	.T./.F. Se a tabela existe ou não na configuração.

@author Jorge Luis Branco Martins Junior
@since 20/10/14
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA062EXCON(cTab, cCampo)
Local lRet     := .F.
Local aArea    := GetArea()
Local aAreaNW8 := NW8->( GetArea() )

dbSelectArea('NW8')
dbSetOrder(1)

If dbSeek(xFilial('NW8') + cTab + cCampo)
	lRet := .T.
Endif

RestArea(aAreaNW8)
RestArea(aArea)

Return lRet