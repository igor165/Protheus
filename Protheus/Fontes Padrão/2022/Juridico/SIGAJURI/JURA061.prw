#INCLUDE "JURA061.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA061
Forma de Correção

@author Juliana Iwayama Velho
@since 18/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA061()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 )
oBrowse:SetAlias( "NW7" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NW7" )
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
@since 18/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } )  //"Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA061", 0, 2, 0, NIL } )  //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA061", 0, 3, 0, NIL } )  //"Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA061", 0, 4, 0, NIL } )  //"Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA061", 0, 5, 0, NIL } )  //"Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.JURA061", 0, 8, 0, NIL } )  //"Imprimir"
aAdd( aRotina, { STR0010, "JA061CONFG"     , 0, 3, 0, NIL } )  // "Config. Inicial"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Forma de Correção

@author Juliana Iwayama Velho
@since 18/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( "JURA061" )
Local oStructNW7 := FWFormStruct( 2, "NW7" )
Local oStructNWS := FWFormStruct( 2, "NWS" )

oStructNWS:RemoveField( "NWS_CFCORR")
//------------------------------------------------------------------------
//Montagem do View normal se Container
//------------------------------------------------------------------------
JurSetAgrp( "NW7",, oStructNW7 )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:SetDescription( STR0001 )

oView:AddField("JURA061_VIEW", oStructNW7, "NW7MASTER" )
oView:AddGrid ("JURA061_DETAIL", oStructNWS, "NWSDETAIL" )

oView:CreateHorizontalBox( "FORMPADRAO" , 60 )
oView:CreateHorizontalBox( "FORMDETAIL" , 40 )

oView:SetOwnerView( "NW7MASTER", "FORMPADRAO" )
oView:SetOwnerView( "NWSDETAIL", "FORMDETAIL" )

oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Forma de Correção

@author Juliana Iwayama Velho
@since 18/01/10
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel  := NIL
Local oStructNW7 := FWFormStruct( 1, "NW7" )
Local oStructNWS := FWFormStruct( 1, "NWS" )

oStructNWS:RemoveField( "NWS_CFCORR" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA061", /*Pre-Validacao*/, {|oModel| JURA061TOK(oModel)}/*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:SetDescription( STR0008 )

oModel:AddFields( "NW7MASTER", NIL, oStructNW7, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid( "NWSDETAIL", "NW7MASTER" /*cOwner*/, oStructNWS, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )

oModel:GetModel( "NW7MASTER" ):SetDescription( STR0009 ) // "Cabecalho Follow-Up Padrão"
oModel:GetModel( "NWSDETAIL" ):SetDescription( STR0013 ) // "Periodicidade de Juros"

oModel:SetRelation( "NWSDETAIL", { { "NWS_FILIAL", "XFILIAL('NWS')" }, { "NWS_CFCORR", "NW7_COD" } }, NWS->( IndexKey( 1 ) ) )

oModel:GetModel( "NWSDETAIL" ):SetUniqueLine( { "NWS_PERCEN","NWS_DTINI" } )
oModel:GetModel( "NWSDETAIL" ):SetDelAllLine( .F. )

oModel:SetOptional( "NWSDETAIL" , .T. )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA061CONFG
Realiza a carga inicial da configuração de índices

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 06/03/10
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA061CONFG()
Local lRet      := .T.
Local oModel    := ModelDef()
Local aArea     := GetArea()
Local aAreaNW7  := NW7->( GetArea() )
Local aDados    := {}
Local aErro     := {}
Local nI        := 0
Local nX        := 0
Local aDadosNWS := {}
Local oModelNWS := oModel:getModel("NWSDETAIL")
Local lTipJur   := .F.
Local cFCAdic  := ""

DbSelectArea("NWS")
lTipJur := NWS->( FieldPos("NWS_TIPJUR") ) > 0

NW7->(dbGoTop())

//Inicio - alimentando o array das formulas de correções
aAdd( aDados, {'01', 'JUROS/S'   ,"(1+((FN_QTDEMESES(#DTFIM,#DTJUROS)-1)*(0.5/100)))","2"} )
aAdd( aDados, {'02', 'JUROS/M'   ,"FN_JMISTO(#DTJUROS,'20021130',#DTFIM )","2"} )
aAdd( aDados, {'03', 'JUROS/P'   ,"(1+(FN_SE_VALOR(FN_QTDEDIAS(#DTFIM,#DTJUROS)-30>0,(((FN_QTDEDIAS(#DTFIM,#DTJUROS)-30)/30)/100),0)))" ,"2"} )

If lTipJur //Se o campo não existir, mantenho a forma de correção antiga
	aAdd( aDados, {'04', 'TJ'        ,"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'01',#DTJUROS)","1"} )
	aAdd( aDados, {'05', 'TJ/JUROS/S',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'01',#DTJUROS)","1"} )
	aAdd( aDados, {'06', 'TJ/JUROS/M',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'01',#DTJUROS)","1"} )
	aAdd( aDados, {'07', 'TJ/JUROS/P',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'01',#DTJUROS)","1"} )
	aAdd( aDados, {'08', 'TST'       ,"(#VALOR*(FN_INDICEPLUS('06',#DTINI,0)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,'06',0,#DTJUROS))","1"} )
Else
	aAdd( aDados, {'04', 'TJ'        ,"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'01',0.00,'S',#DTJUROS)","1"} )
	aAdd( aDados, {'05', 'TJ/JUROS/S',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'01',0.01,'S',#DTJUROS)","1"} )
	aAdd( aDados, {'06', 'TJ/JUROS/M',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'01',0.01,'M',#DTJUROS)","1"} )
	aAdd( aDados, {'07', 'TJ/JUROS/P',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'01',0.01,'C',#DTJUROS)","1"} )
	aAdd( aDados, {'08', 'TST'       ,"(#VALOR*(FN_INDICEPLUS('06',#DTINI,0)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,0.01,'06',0,#DTJUROS))","1"} )
EndIf

aAdd( aDados, {'09', 'SELIC'     ,"FN_VALORAF(#DTINI,#VALOR,'05',#DTFIM,0,#VLRMULTA,0,AF,#DTJUROS,#DTMULTA)","1"})
aAdd( aDados, {'10', 'TRIB/FED'  ,"FN_PROV26(#DTINI,'19920101','19951231',#DTFIM,'01','04','05',#VALOR)","1"} )
aAdd( aDados, {'11', 'TRIB/EST'  ,"FN_PROV26(#DTINI,'19890401','19981231',#DTFIM,'01','07','05',#VALOR)","1"} )
aAdd( aDados, {'12', 'TRIB/MUN'  ,"FN_SE_TEXTO(#DTINI >= '20000101',#VALOR*(FN_VALORINDICE('08',#DTINI)),#VALOR)","1"} )
aAdd( aDados, {'13', 'IPCA-E  '  ,"(#VALOR*(FN_VALORINDICE('09',#DTINI)))","1"  } )
aAdd( aDados, {'14', 'Juros 1.0%',"(1+(FN_QTDEMESES(#DTFIM,#DTJUROS)*0.01))","2"} )

If lTipJur //Se o campo não existir, mantenho a forma de correção antiga
	aAdd( aDados, {'15', 'IPCA-E c/J',"{13}+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,'09',0,#DTJUROS))","1"} )
Else
	aAdd( aDados, {'15', 'IPCA-E c/J',"{13}+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,0.01,'09',0,#DTJUROS))","1"} )
EndIf

aAdd( aDados, {'16', 'AutEst-DF' ,"FN_VALORAF(#DTINI,#VALOR,'10',#DTFIM,-1,#VLRMULTA,0.01,DF,#DTJUROS,#DTMULTA)","1"} )
aAdd( aDados, {'17', 'AutEst-RJ' ,"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'22',#DTJUROS)","1" } )
aAdd( aDados, {'18', 'AutMun-SP' ,"FN_VALORAF(#DTINI,#VALOR,'23',#DTFIM,0,#VLRMULTA,0.01,SP,#DTJUROS,#DTMULTA)","1"} )

If lTipJur //Se o campo não existir, mantenho a forma de correção antiga
	aAdd( aDados, {'19', 'TR-3% a.a.',"FN_COMPOSTO(#DTINI,#VALOR,#DTFIM,'03',#DTJUROS)","1" } )
	aAdd( aDados, {'20', 'TR-6% a.a.',"FN_COMPOSTO(#DTINI,#VALOR,#DTFIM,'03',#DTJUROS)"	,"1" } )
	aAdd( aDados, {'21', 'TR-1% a.m.',"FN_COMPOSTO(#DTINI,#VALOR,#DTFIM,'03',#DTJUROS)" ,"1" } )
Else
	aAdd( aDados, {'19', 'TR-3% a.a.',"FN_COMPOSTO(#DTINI,#VALOR,#DTFIM,'03',0.25,#DTJUROS)","1" } )
	aAdd( aDados, {'20', 'TR-6% a.a.',"FN_COMPOSTO(#DTINI,#VALOR,#DTFIM,'03',0.5,#DTJUROS)"	,"1" } )
	aAdd( aDados, {'21', 'TR-1% a.m.',"FN_COMPOSTO(#DTINI,#VALOR,#DTFIM,'03',1.0,#DTJUROS)" ,"1" } )
EndIf

aAdd( aDados, {'22', 'JF-CGeral ',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'11',#DTJUROS,RJ)","1"})
aAdd( aDados, {'23', 'JF-IndTrib',"FN_VALORIND(#DTINI,#VALOR,#DTFIM,0,'13','14')","1"  } )

If lTipJur //Se o campo não existir, mantenho a forma de correção antiga
	aAdd( aDados, {'24', 'JF-Previd ',"(#VALOR*(FN_VALORINDICE('15',#DTINI)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,'15',0, #DTJUROS))","1" } )
	aAdd( aDados, {'25', 'JF-Desapro',"(#VALOR*(FN_VALORINDICE('16',#DTINI)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,'16',0, #DTJUROS))","1" } )
Else
	aAdd( aDados, {'24', 'JF-Previd ',"(#VALOR*(FN_VALORINDICE('15',#DTINI)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,0.005,'15',0, #DTJUROS))","1" } )
	aAdd( aDados, {'25', 'JF-Desapro',"(#VALOR*(FN_VALORINDICE('16',#DTINI)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,0.005,'16',0, #DTJUROS))","1" } )
EndIf

aAdd( aDados, {'26', 'JF-CGSelic',"FN_VALORCGS(#DTINI,#VALOR,#DTFIM,0.005,'12','21')","1"   } )

If lTipJur //Se o campo não existir, mantenho a forma de correção antiga
	aAdd( aDados, {'27', 'INPC/IBGE' ,"(#VALOR*(FN_INDICEPLUS('18',#DTINI,0)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,'18',0,#DTJUROS))","1"})
	aAdd( aDados, {'28', 'IGPM-Acum' ,"(#VALOR*(FN_INDICEPLUS('19',#DTINI,0)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,'19',0,#DTJUROS))","1"})
	aAdd( aDados, {'29', 'IPCA-Acum' ,"(#VALOR*(FN_INDICEPLUS('23',#DTINI,0)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,'23',0,#DTJUROS))","1"})
Else
	aAdd( aDados, {'27', 'INPC/IBGE' ,"(#VALOR*(FN_INDICEPLUS('18',#DTINI,0)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,0.01,'18',0,#DTJUROS))","1"})
	aAdd( aDados, {'28', 'IGPM-Acum' ,"(#VALOR*(FN_INDICEPLUS('19',#DTINI,0)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,0.01,'19',0,#DTJUROS))","1"})
	aAdd( aDados, {'29', 'IPCA-Acum' ,"(#VALOR*(FN_INDICEPLUS('23',#DTINI,0)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,0.01,'23',0,#DTJUROS))","1"})
EndIF

aAdd( aDados, {'30', 'AutEst-SP' ,"FN_VALORASP(#DTINI,#VALOR,#DTFIM,'25',#DTJUROS,#VLRMULTA)","1"})

If lTipJur //Se o campo não existir, mantenho a forma de correção antiga
	aAdd( aDados, {'31', 'TR' ,"FN_COMPOSTO(#DTINI,#VALOR,#DTFIM,'03',#DTJUROS)","1"})
Else
	aAdd( aDados, {'31', 'TR' ,"FN_COMPOSTO(#DTINI,#VALOR,#DTFIM,'03',0,#DTJUROS)","1"})
EndIf

aAdd( aDados, {'32', 'AutFederal',"FN_VALORAF(#DTINI,#VALOR,'05',#DTFIM,0,#VLRMULTA,0,AF,#DTJUROS,#DTMULTA)","1"})

If lTipJur //Se o campo não existir, mantenho a forma de correção antiga
	aAdd( aDados, {'33', 'JF-CondGeJ',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'11',#DTJUROS,RJ)","1"})
	aAdd( aDados, {'37', 'IGP-DI-1%' ,"(#VALOR*(FN_INDICEPLUS('27',#DTINI,0)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,'27',0,#DTJUROS))","1"})
Else
	aAdd( aDados, {'33', 'JF-CondGeJ',"(#VALOR*(FN_VALORINDICE('11',#DTINI)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,0.005,'11',0,#DTJUROS))","1"})
	aAdd( aDados, {'37', 'IGP-DI-1%' ,"(#VALOR*(FN_INDICEPLUS('27',#DTINI,0)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,0.01,'27',0,#DTJUROS))","1"})
EndIF

aAdd( aDados, {'36', 'IGP-DI' ,"(#VALOR*(FN_INDICEPLUS('27',#DTINI,0)))","1"})
aAdd( aDados, {'38', 'SELIC-MG'  ,"FN_VALORAF(#DTINI,#VALOR,'28',#DTFIM,0,#VLRMULTA,0,MG,#DTJUROS,#DTMULTA)","1"})
aAdd( aDados, {'39', 'IGP-DI-GO' ,"FN_VALORAF(#DTINI,#VALOR,'29',#DTFIM,0,#VLRMULTA,0.005,GO,#DTJUROS,#DTMULTA)","1"} )

aAdd( aDados, {'40', 'TJ MG',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'34',#DTJUROS,RJ)","1"})
aAdd( aDados, {'41', 'TJ RJ',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'40',#DTJUROS,RJ)","1"})

aAdd( aDados, {'42', 'TJ PR',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'39',#DTJUROS)","1"})

aAdd( aDados, {'43', 'TJ-MG/JR/S',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'34',#DTJUROS,RJ)","1"})
aAdd( aDados, {'44', 'TJ-MG/JR/M',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'34',#DTJUROS,RJ)","1"})
aAdd( aDados, {'45', 'TJ-MG/JR/P',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'34',#DTJUROS,RJ)","1"})

aAdd( aDados, {'46', 'TJ-RJ/JR/S',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'40',#DTJUROS,RJ)","1"})
aAdd( aDados, {'47', 'TJ-RJ/JR/M',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'40',#DTJUROS,RJ)","1"})
aAdd( aDados, {'48', 'TJ-RJ/JR/P',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'40',#DTJUROS,RJ)","1"})

aAdd( aDados, {'49', 'TJ-PR/JR/S',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'39',#DTJUROS)","1"})
aAdd( aDados, {'50', 'TJ-PR/JR/M',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'39',#DTJUROS)","1"})
aAdd( aDados, {'51', 'TJ-PR/JR/P',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'39',#DTJUROS)","1"})

aAdd( aDados, {'52', 'TJ ES',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'41',#DTJUROS,RJ)","1"})

aAdd( aDados, {'53', 'TJ-ES/JR/S',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'41',#DTJUROS,RJ)","1"})
aAdd( aDados, {'54', 'TJ-ES/JR/M',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'41',#DTJUROS,RJ)","1"})
aAdd( aDados, {'55', 'TJ-ES/JR/P',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'41',#DTJUROS,RJ)","1"})

aAdd( aDados, {'56', 'TJ DF',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'42',#DTJUROS,RJ)","1"})

aAdd( aDados, {'57', 'TJ-DF/JR/S',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'42',#DTJUROS,RJ)","1"})
aAdd( aDados, {'58', 'TJ-DF/JR/M',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'42',#DTJUROS,RJ)","1"})
aAdd( aDados, {'59', 'TJ-DF/JR/P',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'42',#DTJUROS,RJ)","1"})
aAdd( aDados, {'60', 'TR+IPCA-E' ,"(#VALOR*(FN_VALORINDICE('51',#DTINI))) + (FN_VALORPRO(#DTINI,#VALOR,#DTFIM,'51',0,#DTJUROS))","1"})

aAdd( aDados, {'61', 'TJ GO',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'50',#DTJUROS)","1"})
aAdd( aDados, {'62', 'TJ CE',"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'52',#DTJUROS)","1"})


//Fim - alimentando o array das formulas de correções

//Inicio - alimentando o array do grid das formulas de correções
If lTipJur //Se o campo não existir, mantenho a forma de correção antiga
	aAdd( aDadosNWS, {'05'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'06'/*For Corr*/,/*Percentual*/ 0.5,/*DataIni*/,CTOD('10/01/2003'),/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'06'/*For Corr*/,/*Percentual*/ 1.0,CTOD('11/01/2003'),/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'07'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"2",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'08'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )

	aAdd( aDadosNWS, {'19'/*For Corr*/,/*Percentual*/ 0.25,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"2",/*Pro-rata*/"2"} )
	aAdd( aDadosNWS, {'20'/*For Corr*/,/*Percentual*/ 0.5,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"2",/*Pro-rata*/"2"} )
	aAdd( aDadosNWS, {'21'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"2",/*Pro-rata*/"2"} )

	aAdd( aDadosNWS, {'15'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'17'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'24'/*For Corr*/,/*Percentual*/ 0.5,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'25'/*For Corr*/,/*Percentual*/ 0.5,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'27'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'28'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'29'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'33'/*For Corr*/,/*Percentual*/ 0.5,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'37'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )

	aAdd( aDadosNWS, {'43'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'44'/*For Corr*/,/*Percentual*/ 0.5,/*DataIni*/,/*DataFim*/ CTOD('10/01/2003'),/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'44'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/ CTOD('11/01/2003'),/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'45'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"2",/*Pro-rata*/"1"} )

	aAdd( aDadosNWS, {'46'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'47'/*For Corr*/,/*Percentual*/ 0.5,/*DataIni*/,/*DataFim*/ CTOD('10/01/2003'),/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'47'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/ CTOD('11/01/2003'),/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'48'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"2",/*Pro-rata*/"1"} )

	aAdd( aDadosNWS, {'49'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'50'/*For Corr*/,/*Percentual*/ 0.5,/*DataIni*/,/*DataFim*/ CTOD('10/01/2003'),/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'50'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/ CTOD('11/01/2003'),/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'51'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"2",/*Pro-rata*/"1"} )

	aAdd( aDadosNWS, {'53'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'54'/*For Corr*/,/*Percentual*/ 0.5,/*DataIni*/,/*DataFim*/ CTOD('10/01/2003'),/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'54'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/ CTOD('11/01/2003'),/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'55'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"2",/*Pro-rata*/"1"} )

	aAdd( aDadosNWS, {'57'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'58'/*For Corr*/,/*Percentual*/ 0.5,/*DataIni*/,/*DataFim*/ CTOD('10/01/2003'),/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'58'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/ CTOD('11/01/2003'),/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'59'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"2",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'60'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'61'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
	aAdd( aDadosNWS, {'62'/*For Corr*/,/*Percentual*/ 1.0,/*DataIni*/,/*DataFim*/,/*Tp Juros*/"1",/*Pro-rata*/"1"} )
EndIF
//Fim - alimentando o array do grid das formulas de correções

oModel:SetOperation( 3 )

For nI := 1 To Len( aDados )
	oModel:Activate()

	If !oModel:SetValue("NW7MASTER",'NW7_COD',aDados[nI][1]) .Or. !oModel:SetValue("NW7MASTER",'NW7_DESC',aDados[nI][2]) .Or.;
		!oModel:SetValue("NW7MASTER",'NW7_FORMUL',aDados[nI][3]) .Or. !oModel:SetValue("NW7MASTER",'NW7_VISIV', aDados[nI][4])
		lRet := .F.
	EndIf

	If lTipJur
		For nX := 1 To Len( aDadosNWS)
			If aDados[nI][1] == aDadosNWS[nX][1]
				If !oModelNWS:SetValue('NWS_PERCEN',aDadosNWS[nX][2]) .Or.;
					!oModelNWS:SetValue('NWS_DTINI',aDadosNWS[nX][3]) .Or. ;
					!oModelNWS:SetValue('NWS_DTFIM', aDadosNWS[nX][4]) .Or. ;
					!oModelNWS:SetValue('NWS_TIPJUR', aDadosNWS[nX][5]) .Or. ;
					!oModelNWS:SetValue('NWS_PRORAT', aDadosNWS[nX][6])
					lRet := .F.
				EndIf
				oModelNWS:AddLine()
			EndIf
		Next
	EndIf

	If	lRet
		If ( lRet := oModel:VldData() )
			oModel:CommitData()
			If __lSX8
				ConfirmSX8()
			EndIf
		Else
			aErro := oModel:GetErrorMessage()
			JurMsgErro(aErro[6])
		EndIf
	cFCAdic += STR0014 + ": " + aDados[nI][1] + " - " + STR0015 + ": " + aDados[nI][2] + CRLF // ST0014 - Código || STR0015 - Descrição
	Else
		lRet := .T.
	EndIf
	oModel:DeActivate()
Next

If !Empty(cFCAdic)
	MsgInfo(STR0019 + ":" + CRLF + CRLF + cFCAdic) // STR0019 - Foram adicionados as seguintes Formas de Correção
EndIf

aSize(aDados,0)
aSize(aDadosNWS,0)
RestArea(aAreaNW7)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA061ValFCorr()
Validação do campos de Forma de Correção caso seja visível(NW7_VISIV)

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Tiago Martins
@since 28/07/2011
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA061ValFCorr(cCodCorr)
Local lRet     := .T.

    If POSICIONE('NW7',1,XFILIAL('NW7')+cCodCorr,'NW7_VISIV')=='2'
	    lRet:= .F.
    EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} JURA061TOK(oModel)
Validações para que seja permitida a inclusão de registro
@author Clovis E. Teixeira dos Santos
@since 06/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA061TOK(oModel)
Local aArea      := GetArea()
Local aAreaSX2   := SX2->( GetArea() )
Local oModelGrid := oModel:GetModel( "NWSDETAIL" )
Local nOpc       := oModel:GetOperation()
Local lTudoOk    := .T.
Local nI

If (nOpc == 3 .Or. nOpc = 4)

	For nI := 1 To oModelGrid:GetQtdLine()

		If !oModelGrid:IsDeleted( nI ) .And. !oModelGrid:IsEmpty( nI )
			If !Empty(oModelGrid:GetValue( 'NWS_DTINI', nI )) .And. !Empty(oModelGrid:GetValue( 'NWS_DTFIM', nI ))
				If (oModelGrid:GetValue( 'NWS_DTINI', nI ) > oModelGrid:GetValue( 'NWS_DTFIM', nI ))
					JurMsgErro( STR0018 )  // "A data final nao pode ser superior a data inicial"
					lTudoOk := .F.
					Exit
				Endif
			EndIF
		EndIf

	Next

Endif

RestArea( aAreaSX2 )
RestArea( aArea )

Return lTudoOk 
