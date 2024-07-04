#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA154

@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Function FISA154( cRegime, lVisualiza, cOpFinCont )
	Private oChart := FWChartBarComp():New()
	Private lVisualizando	:= lVisualiza
	Private cOpTitCont	:= cOpFinCont
	If cOpTitCont == "2"
		MV_PAR04	:= 2
	ElseIF cOpTitCont == "3"
		MV_PAR04	:= 3
	EndIF

	//Chama a View da rotina diretamente
	FWExecView('Período: ' + MesExtenso(FSA200DataApur(mv_par01)) + '/' +  Str(year(FSA200DataApur(mv_par01)),4) + ' - Matriz Centralizadora '  + ' - ' + Iif(cRegime == '1' , "Regime de Competência" , "Regime Caixa" ) ,'FISA154', MODEL_OPERATION_UPDATE,, { || .T. } , { || FSA154TIT() })
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( 'FISA154' )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local aArray		:= {}
	Local oStruABA		:= FWFormStruct( 1, 'F1A')
	Local oStruABA1		:= x001Struct(1,'ABA1') //Composição do RBT12
	Local oStruABA1A	:= x001Struct(1,'ABA1A') //Composição
	Local oStruABA2		:= x001Struct(1,'ABA2')
	Local oStruABA3A	:= x001Struct(1,'ABA3A')
	Local oStruABA3B	:= x001Struct(1,'ABA3B')
	Local oStruABA4A    := x001Struct(1,'ABA4A')
	Local oStruABA4B    := x001Struct(1,'ABA4B')
	Local bLoadABA1  	:= { || a002LdGrid('ABA1',@aArray) }
	Local bLoadABA1A  	:= { || a002LdGrid('ABA1A',@aArray) }
	Local bLoadABA2  	:= { || a002LdGrid('ABA2',@aArray) }
	Local bLoadABA3A  	:= { || a002LdGrid('ABA3A',@aArray) }
	Local bLoadABA3B  	:= { || a002LdGrid('ABA3B',@aArray) }
	Local bLoadABA4A    := { || a002LdGrid('ABA4A',@aArray) }
	Local bLoadABA4B    := { || a002LdGrid('ABA4B',@aArray) }
	
	//Local bLoadABA4B    := {}
	Local bDbCLickAtv   := { |oModelGrid, nLine, cAction, cField| DbClickAtv(oModelGrid, nLine, cAction, cField,aArray) }

	oModel	:=	MPFormModel():New('FISA154',,{|oModel| .T. },{|oModel| .T. })

	oModel:AddFields( 'MODEL_ABA' ,, oStruABA )

	oModel:AddGrid( 'MODEL_ABA1A', 'MODEL_ABA', oStruABA1A,,,,, bLoadABA1A)
	oModel:GetModel( 'MODEL_ABA1A' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'MODEL_ABA1A' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'MODEL_ABA1A' ):SetNoUpdateLine( .T. )

	oModel:AddGrid( 'MODEL_ABA1', 'MODEL_ABA', oStruABA1,,,,, bLoadABA1)
	oModel:GetModel( 'MODEL_ABA1' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'MODEL_ABA1' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'MODEL_ABA1' ):SetNoUpdateLine( .T. )

	//Montagem do grid da primeira ABA
	oModel:AddGrid( 'MODEL_ABA2', 'MODEL_ABA', oStruABA2,bDbCLickAtv,,,, bLoadABA2)
	oModel:GetModel( 'MODEL_ABA2' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'MODEL_ABA2' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'MODEL_ABA2' ):SetOptional( .T. )

	//Montagem do grid da segunda ABA
	oModel:AddGrid( 'MODEL_ABA3A' ,'MODEL_ABA', oStruABA3A,,,,, bLoadABA3A)
	oModel:GetModel( 'MODEL_ABA3A' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'MODEL_ABA3A' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'MODEL_ABA3A' ):SetNoUpdateLine( .T. )

	oModel:AddGrid( 'MODEL_ABA3B' , 'MODEL_ABA', oStruABA3B,bDbCLickAtv,,,, bLoadABA3B)
	oModel:GetModel( 'MODEL_ABA3B' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'MODEL_ABA3B' ):SetNoDeleteLine( .T. )
	//oModel:GetModel( 'MODEL_ABA3B' ):SetNoUpdateLine( .T. )

	oModel:AddGrid( 'MODEL_ABA4A' , 'MODEL_ABA', oStruABA4A,,,,, bLoadABA4A)
	oModel:GetModel( 'MODEL_ABA4A' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'MODEL_ABA4A' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'MODEL_ABA4A' ):SetNoUpdateLine( .T. )

	oModel:AddGrid( 'MODEL_ABA4B' , 'MODEL_ABA', oStruABA4B,,,,, bLoadABA4B)
	oModel:GetModel( 'MODEL_ABA4B' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'MODEL_ABA4B' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'MODEL_ABA4B' ):SetNoUpdateLine( .T. )


	oModel:SetPrimaryKey( { 'ABA1_CMP1'} )
	oModel:SetDescription( 'Simples Nacional ')
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel     	:= FWLoadModel( 'FISA154' )
Local oView        	:= FWFormView():New()
Local oStruABA1   	:= x001Struct(2, 'ABA1')
Local oStruABA1A   	:= x001Struct(2, 'ABA1A')
Local oStruABA2   	:= x001Struct(2, 'ABA2')
Local oStruABA3A   	:= x001Struct(2, 'ABA3A')
Local oStruABA3B   	:= x001Struct(2, 'ABA3B')
Local oStruABA4A    := x001Struct(2, 'ABA4A')
Local oStruABA4B    := x001Struct(2, 'ABA4B')
Local cDescr		:= 'Período:' + MesExtenso(FSA200DataApur(mv_par01)) + '/' +  Str(year(FSA200DataApur(mv_par01)),4) +' - '
Local cVersao 		:= GetVersao(.F.)

oView:SetModel( oModel )

//Cria View para cada grid
oView:AddGrid( 'VIEW_ABA1A' ,oStruABA1A  	,'MODEL_ABA1A'  )
oView:AddGrid( 'VIEW_ABA1' ,oStruABA1  		,'MODEL_ABA1'   )
oView:AddGrid( 'VIEW_ABA2' ,oStruABA2    	,'MODEL_ABA2'   )
oView:AddGrid( 'VIEW_ABA3A' ,oStruABA3A     ,'MODEL_ABA3A'  )
oView:AddGrid( 'VIEW_ABA3B' ,oStruABA3B     ,'MODEL_ABA3B'  )
oView:AddGrid( 'VIEW_ABA4A' ,oStruABA4A     ,'MODEL_ABA4A'  )
oView:AddGrid( 'VIEW_ABA4B' ,oStruABA4B     ,'MODEL_ABA4B'  )

oView:AddOtherObject( 'VIEW_CHART' ,  { |oPanel| ChartBArra( oPanel ) } )
oView:AddOtherObject( 'VIEW_LIST' ,   { |oPanel| CriaListBox( oPanel ) } )
oView:AddOtherObject( 'VIEW_CHART4',  { |oPanel| ChartRBTA( oPanel ) } )

  //Títulos das telas
oView:EnableTitleView('VIEW_ABA1A',"Receita Bruta Anual ( RBA )")
oView:EnableTitleView('VIEW_ABA1',"Receita Bruta Acumulada nos últimos 12 meses ( RBT12 )")
oView:EnableTitleView('VIEW_ABA2',"Atividades Econômicas")
oView:EnableTitleView('VIEW_ABA3A',"Totais do Período")
oView:EnableTitleView('VIEW_ABA3B',"Totais por Tributo")
oView:EnableTitleView('VIEW_ABA4A',"Status dos Tributos por Filial")
oView:EnableTitleView('VIEW_ABA4B',"Legendas")
oView:EnableTitleView('VIEW_CHART',"Limites do Simples por Filial")
oView:EnableTitleView('VIEW_CHART4',"Evolução do RBA")

//Cria a pasta
oView:CreateFolder( 'PASTAS' )

//Cria as abas
oView:AddSheet( 'PASTAS', 'ABA01', "Receita Bruta" )//'OPERAÇÕES DE SAÍDAS'
oView:AddSheet( 'PASTAS', 'ABA02', "Atividades Econômicas" )//'OPERAÇÕES DE SAÍDAS'
oView:AddSheet( 'PASTAS', 'ABA03', "Totais do Período" )//'OPERAÇÕES DE ENTRADAS'
oView:AddSheet( 'PASTAS', 'ABA04', "Status dos Tributos por Filial" )//'OPERAÇÕES DE ENTRADAS'
oView:AddSheet( 'PASTAS', 'ABA05', "Indicador de Limite por Filial" )//'OPERAÇÕES DE ENTRADAS'
oView:AddSheet( 'PASTAS', 'ABA06', "Evolução do RBA" )//

//Cria BOX
oView:CreateHorizontalBox( 'TELA1B' , 48,,, 'PASTAS', 'ABA01' )
oView:CreateHorizontalBox( 'TELA1C' , 2,,, 'PASTAS', 'ABA01' )
oView:CreateHorizontalBox( 'TELA1A' , 48,,, 'PASTAS', 'ABA01' )
oView:CreateHorizontalBox( 'TELA2', 100,,, 'PASTAS', 'ABA02' )
oView:CreateHorizontalBox( 'TELA3A', 70,,, 'PASTAS', 'ABA03' )
oView:CreateHorizontalBox( 'TELA3B', 30,,, 'PASTAS', 'ABA03' )
oView:CreateHorizontalBox( 'TELA4A', 70,,, 'PASTAS', 'ABA04' )
oView:CreateHorizontalBox( 'TELA4B', 30,,, 'PASTAS', 'ABA04' )

oView:CreateVerticalBox( 'TELA5A', 10,,, 'PASTAS', 'ABA05' )
oView:CreateVerticalBox( 'TELA5B', 90,,, 'PASTAS', 'ABA05' )
oView:CreateVerticalBox( 'TELA6', 100,,, 'PASTAS', 'ABA06' )

//Relaciona cada grid com sua respectiva aba na tela
oView:SetOwnerView( 'VIEW_ABA1A'  , 'TELA1B')
oView:SetOwnerView( 'VIEW_ABA1'  , 'TELA1A')
oView:SetOwnerView( 'VIEW_ABA2'  , 'TELA2')
oView:SetOwnerView( 'VIEW_ABA3A'  , 'TELA3A')
oView:SetOwnerView( 'VIEW_ABA3B'  , 'TELA3B')
oView:SetOwnerView( 'VIEW_ABA4A'  , 'TELA4A')
oView:SetOwnerView( 'VIEW_ABA4B'  , 'TELA4B')

oView:SetOwnerView( 'VIEW_CHART'   , 'TELA5B')
oView:SetOwnerView( 'VIEW_LIST'   , 'TELA5A')
oView:SetOwnerView( 'VIEW_CHART4'   , 'TELA6')

IF cVersao == '12'
	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty( "*", "GRIDNOORDER")
EndIF

Return oView

Static Function CriaListBox(oPanel)

Local aItems 	:= {}
Local nList 	:= 1
Local aSize 	:= MsAdvSize()
Local oList1
Local cAliasF18	:= QryF18( F1A->F1A_ID )

//Buscar todas as F18 que foram geradas por esta Apuração.
Do While !(cAliasF18)->(Eof ())

	aAdd(aItems, (cAliasF18)->F18_ESTABE  )

	(cAliasF18)->(DbSkip ())
EndDo

DbSelectArea (cAliasF18)
(cAliasF18)->(DbCloseArea())

oList1 := TListBox():New(003,001,{|u|if(Pcount()>0,nList:=u,nList)},aItems,aSize[3]*0.09,aSize[4] *0.82,;
                                 {||AtualizaGrafico( oList1, oPanel )},oPanel,,,,.T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x002Tabs

 Função que monta as propriedades de cada campo da tabela temporária
 de cada aba das telas de apuração

@param  	cTabela  - Tabela a qual serão criados os campos
@return	aCampos  - Array com as propriedades dos campos que serão criados

@author Erick G. Dias
@since 08/04/2014
@version 12117

/*/
//-------------------------------------------------------------------
Static Function a002Tabs(cTabela)

Local aCampos	:= {}

//aAdd(aCampos, {/*Título*/,/*Nome do campo*/,/*Tipo*/,/*Tamanho*/,/*Decimal*/,/*Ordem*/,/*Array com help*/,/*Picture*/,/*Campo editáveç*/})

Do Case

	Case cTabela == 'ABA'
		aAdd(aCampos, {"Operações",'ABA_CMP1' ,'C',75,0,'01',{""},'@!'				  ,.T.})//'Operações'

	Case cTabela == 'ABA1'

		aAdd(aCampos, {"Período"    			,'ABA1_CMP1','C',15,0,'01',{"Código de Atividade"} ,'@&'               ,.T.,{}})
		aAdd(aCampos, {"Receita Mercado Interno"  ,'ABA1_CMP2','N',14,2,'02',{"Valor"               },'@E 999,999,999.99',.T.,{}})
		aAdd(aCampos, {"Receita Mercado Externo"  ,'ABA1_CMP3','N',14,3,'03',{"Valor"               },'@E 999,999,999.99',.T.,{}})


	Case cTabela == 'ABA1A'

		aAdd(aCampos, {"Período"    			,'ABA1A_CMP1','C',15,0,'01',{"Código de Atividade"} ,'@&'               ,.T.,{}})
		aAdd(aCampos, {"Receita Mercado Interno"  ,'ABA1A_CMP2','N',14,2,'02',{"Valor"               },'@E 999,999,999.99',.T.,{}})
		aAdd(aCampos, {"Receita Mercado Externo"  ,'ABA1A_CMP3','N',14,3,'03',{"Valor"               },'@E 999,999,999.99',.T.,{}})

	Case cTabela == 'ABA2'
		//---------------------------------------------
		// Cria as colunas da primeira tela da apuração
		//---------------------------------------------
		aAdd(aCampos, {"Código da Atividade"    		,'ABA2_CMP1','C',05,0 ,'01',{"Código de Atividade"}     ,'@&',.T.,{}})
		aAdd(aCampos, {"Descrição da Atividade" 		,'ABA2_CMP2','C',100,2,'02',{"Descrição"}               ,'@&',.T.,{}})
		aAdd(aCampos, {"Receita Mensal por Atividade"  	,'ABA2_CMP3','N',14,2 ,'03',{"Valor"               }	,'@E 999,999,999.99',.T.,{}})
		aAdd(aCampos, {"Valor das Devoluções"    		,'ABA2_CMP4','N',14,2 ,'04',{"Valor"               }	,'@E 999,999,999.99',.T.,{}})
		aAdd(aCampos, {"Base de Cálculo"     			,'ABA2_CMP5','N',14,2 ,'05',{"Valor"               }	,'@E 999,999,999.99',.T.,{}})
		aAdd(aCampos, {"Valor dos Tributos"    			,'ABA2_CMP6','N',14,2 ,'06',{"Valor"               }	,'@E 999,999,999.99',.T.,{}})


	Case cTabela == 'ABA3A'
		//---------------------------------------------
		// Cria as colunas da segunda tela da apuração
		//---------------------------------------------
		aAdd(aCampos, {"Total" ,'ABA3A_CMP1','C',75,0,'01',{"Total"},'@&'				  ,.T.,{}})
		aAdd(aCampos, {"Valor",'ABA3A_CMP2','N',14,2,'02',{"Valor"},'@E 999,999,999.99',.T.,{}})

	Case cTabela == 'ABA3B'
		//---------------------------------------------
		// Cria as colunas da segunda tela da apuração
		//---------------------------------------------
		aAdd(aCampos, {"Total do IRPJ"   ,'ABA3B_CMP1','N',14,2,'01',{"Total do Tributo"},'@E 999,999,999.99',.T.,{}})
		aAdd(aCampos, {"Total da CSLL"   ,'ABA3B_CMP2','N',14,2,'02',{"Total do Tributo"},'@E 999,999,999.99',.T.,{}})
		aAdd(aCampos, {"Total da COFINS" ,'ABA3B_CMP3','N',14,2,'03',{"Total do Tributo"},'@E 999,999,999.99',.T.,{}})
		aAdd(aCampos, {"Total do PIS"    ,'ABA3B_CMP4','N',14,2,'04',{"Total do Tributo"},'@E 999,999,999.99',.T.,{}})
		aAdd(aCampos, {"Total da CPP"    ,'ABA3B_CMP5','N',14,2,'05',{"Total do Tributo"},'@E 999,999,999.99',.T.,{}})
		aAdd(aCampos, {"Total do IPI"    ,'ABA3B_CMP6','N',14,2,'06',{"Total do Tributo"},'@E 999,999,999.99',.T.,{}})
		aAdd(aCampos, {"Total do ICMS"   ,'ABA3B_CMP7','N',14,2,'07',{"Total do Tributo"},'@E 999,999,999.99',.T.,{}})
		aAdd(aCampos, {"Total do ISS"    ,'ABA3B_CMP8','N',14,2,'08',{"Total do Tributo"},'@E 999,999,999.99',.T.,{}})

	Case cTabela == 'ABA4A'

		aAdd(aCampos, {"Cód. Filial"         ,'ABA4A_CMP1' ,'C',FWGETTAMFILIAL,0,'01',{"Código da Filial"}    ,'@!'  ,.T.,{}})
		aAdd(aCampos, {"Filial"    	         ,'ABA4A_CMP2' ,'C',30            ,0,'02',{"Descrição da Filial"} ,'@!'  ,.T.,{}})
		aAdd(aCampos, {"Sublimite"           ,'ABA4A_CMP11','N',14            ,2,'03',{"Sublimite"},'@E 999,999,999.99',.T.,{}})
		aAdd(aCampos, {"Limite"              ,'ABA4A_CMP12','N',14            ,2,'04',{"Limite"},'@E 999,999,999.99',.T.,{}})
		aAdd(aCampos, {"Início de Atividade" ,'ABA4A_CMP13','C',10            ,0,'05',{"Data de Início de Atividade"}       ,'@!'  ,.T.,{}})
		aAdd(aCampos, {"IRPJ"                ,'ABA4A_CMP3' ,'C',10            ,0,'06',{"Status do IRPJ"}      ,'@BMP',.T.,{}})
		aAdd(aCampos, {"CSLL"                ,'ABA4A_CMP4' ,'C',10            ,0,'07',{"Status do CSLL"}      ,'@BMP',.T.,{}})
		aAdd(aCampos, {"COFINS"              ,'ABA4A_CMP5' ,'C',10            ,0,'08',{"Status do COFINS"}    ,'@BMP',.T.,{}})
		aAdd(aCampos, {"PIS"    	         ,'ABA4A_CMP6' ,'C',10            ,0,'09',{"Status do PIS"}       ,'@BMP',.T.,{}})
		aAdd(aCampos, {"CPP"    	         ,'ABA4A_CMP7' ,'C',10            ,0,'10',{"Status do CPP"}       ,'@BMP',.T.,{}})
		aAdd(aCampos, {"IPI"    	         ,'ABA4A_CMP8' ,'C',10            ,0,'11',{"Status do IPI"}       ,'@BMP',.T.,{}})
		aAdd(aCampos, {"ICMS"                ,'ABA4A_CMP9' ,'C',10            ,0,'12',{"Status do ICMS"}      ,'@BMP',.T.,{}})
		aAdd(aCampos, {"ISS"    	         ,'ABA4A_CMP10','C',10            ,0,'13',{"Status do ISS"}       ,'@BMP',.T.,{}})
		

	Case cTabela == 'ABA4B'

		aAdd(aCampos, {"Legenda"    ,'ABA4B_CMP1' ,'C',0,0,'01',{"Legenda"}  ,'@BMP',.T.,{}})
		aAdd(aCampos, {"Descrição"  ,'ABA4B_CMP2' ,'C',100,0,'02',{"Descrição"}  ,'',.T.,{}})
	
EndCase

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} a002LdGrid

 Função que irá retornar as informações para pouplar as linhas
 das tabelas temporárias de cada aba da tela de apuração.

@param  	cTabela  - Tabela a qual serão será populada
@return	aLoad   - Array com as informações e valores para popular as telas

@author Erick G. Dias
@since 08/04/2014
@version 12117

/*/
//-------------------------------------------------------------------
Static Function a002LdGrid(cTabela,aArray)

Local aLoad  		:= {}
Local aGuias		:= {}
Local nCont			:= 0
Local nX			:= 0
Local nY            := 0
Local i				:= 0
Local aDados		:= {}
Local aMesVal		:= {}
Local aMesValEx		:= {}
Local aValAtv		:= {}
Local aTributo		:= {}
Local aDet3A		:= {}
Local aDet4A        := {}
Local nPos			:= 0
Local nValAtv		:= 0
Local nValDev		:= 0
Local nBaseCalc		:= 0
Local nValTrib		:= 0
Local cAliasF18		:= ""
Local cStatusEst    := ""
Local cStatusFed    := ""

Do Case

	Case cTabela == 'ABA1'

		aMesVal		:= FSA154RBT(FSA200DataApur(MV_PAR01), '1') //Mercado Interno
		aMesValEx	:= FSA154RBT(FSA200DataApur(MV_PAR01), "2") //Mercado Externo

		//Composição da RBT12

		aAdd( aLoad, { nX++,  { aMesVal[1][1] , aMesVal[1][2] , aMesValEx[1][2]  } } )
		aAdd( aLoad, { nX++,  { aMesVal[2][1] , aMesVal[2][2] , aMesValEx[2][2]  } } )
		aAdd( aLoad, { nX++,  { aMesVal[3][1] , aMesVal[3][2] , aMesValEx[3][2]  } } )
		aAdd( aLoad, { nX++,  { aMesVal[4][1] , aMesVal[4][2] , aMesValEx[4][2]  } } )
		aAdd( aLoad, { nX++,  { aMesVal[5][1] , aMesVal[5][2] , aMesValEx[5][2]  } } )
		aAdd( aLoad, { nX++,  { aMesVal[6][1] , aMesVal[6][2] , aMesValEx[6][2]  } } )
		aAdd( aLoad, { nX++,  { aMesVal[7][1] , aMesVal[7][2] , aMesValEx[7][2]  } } )
		aAdd( aLoad, { nX++,  { aMesVal[8][1] , aMesVal[8][2] , aMesValEx[8][2]  } } )
		aAdd( aLoad, { nX++,  { aMesVal[9][1] , aMesVal[9][2] , aMesValEx[9][2]  } } )
		aAdd( aLoad, { nX++,  { aMesVal[10][1], aMesVal[10][2], aMesValEx[10][2] } } )
		aAdd( aLoad, { nX++,  { aMesVal[11][1], aMesVal[11][2], aMesValEx[11][2] } } )
		aAdd( aLoad, { nX++,  { aMesVal[12][1], aMesVal[12][2], aMesValEx[12][2] } } )
		aAdd( aLoad, { nX++,  { ""            ,               ,                  } } )
		aAdd( aLoad, { nX++,  { "TOTAL", FSA154SREC(aMesVal), FSA154SREC(aMesValEx)  } } )


	Case cTabela == 'ABA1A'
		nCont		:= Month(FSA200DataApur(MV_PAR01))
		aMesVal		:= FSA154RBT( STOD( Str( year( FSA200DataApur(MV_PAR01) ) + 1 ,4 ) + "0101" ), "1",,,nCont) //Mercado Interno
		aMesValEx	:= FSA154RBT( STOD( Str( year( FSA200DataApur(MV_PAR01) ) + 1 ,4 ) + "0101" ), "2",,,nCont) //mercado Externo

		//Composição da RBT12
		aAdd( aLoad, { nX++,  { aMesVal[12][1], aMesVal[12][2], aMesValEx[12][2] } } )
		aAdd( aLoad, { nX++,  { aMesVal[11][1], aMesVal[11][2], aMesValEx[11][2] } } )
		aAdd( aLoad, { nX++,  { aMesVal[10][1], aMesVal[10][2], aMesValEx[10][2] } } )
		aAdd( aLoad, { nX++,  { aMesVal[9][1] , aMesVal[9][2] , aMesValEx[9][2]  } } )
		aAdd( aLoad, { nX++,  { aMesVal[8][1] , aMesVal[8][2] , aMesValEx[8][2]  } } )
		aAdd( aLoad, { nX++,  { aMesVal[7][1] , aMesVal[7][2] , aMesValEx[7][2]  } } )
		aAdd( aLoad, { nX++,  { aMesVal[6][1] , aMesVal[6][2] , aMesValEx[6][2]  } } )
		aAdd( aLoad, { nX++,  { aMesVal[5][1] , aMesVal[5][2] , aMesValEx[5][2]  } } )
		aAdd( aLoad, { nX++,  { aMesVal[4][1] , aMesVal[4][2] , aMesValEx[4][2]  } } )
		aAdd( aLoad, { nX++,  { aMesVal[3][1] , aMesVal[3][2] , aMesValEx[3][2]  } } )
		aAdd( aLoad, { nX++,  { aMesVal[2][1] , aMesVal[2][2] , aMesValEx[2][2]  } } )
		aAdd( aLoad, { nX++,  { aMesVal[1][1] , aMesVal[1][2] , aMesValEx[1][2]  } } )
		aAdd( aLoad, { nX++,  { ""            ,               ,                  } } )
		aAdd( aLoad, { nX++,  { "TOTAL", FSA154SREC(aMesVal), FSA154SREC(aMesValEx)  } } )

	Case cTabela == 'ABA2'

		//Busca os valores de tributos das Atividades
		aValAtv	:= TotTribAtv( F1A->F1A_ID )

		dbSelectArea('F12')
		If	F12->( MsSeek ( xFilial('F12') ) )
			Do While !F12->(Eof ()) .AND. F12_FILIAL == xFilial("F12")

				//Procura o valor total do tributo da atividade em questão.
				nValAtv		:= 0 //Valor da receita bruta da atividade
				nValDev		:= 0 //VAlor de devolução da Atividade
				nBaseCalc	:= 0 //BAse de cálculo da Atividade
				nValTrib	:= 0 //Valor total do triuto da atividade

				nPos := ASCAN(aValAtv, {|aX| aX[1] == F12->F12_CODATV })
				If nPos > 0
					nValAtv		:= aValAtv[nPos][2]
					nValDev		:= aValAtv[nPos][3]
					nBaseCalc	:= aValAtv[nPos][4]
					nValTrib	:= aValAtv[nPos][5]
				EndIF

				//Somente adiciona na tela as atividade que tiveram receita no período
				If nValAtv > 0 .OR. nValDev > 0 .OR. nBaseCalc > 0 .OR. nValTrib > 0
					aAdd( aLoad, { nX++,  { F12->F12_CODATV, F12->F12_DESCR, nValAtv , nValDev, nBaseCalc, nValTrib    } } )
				EndIF

				F12->(DbSkip ())

			EndDo
		EndIF


	Case cTabela == 'ABA3A'
		//---------------------------------------------------------------------------------
		// Insere informações na segunda tela da apuração - Resumo das operações de entrada
		//---------------------------------------------------------------------------------
 		aDet3A	:= DetABA3A( FSA200DataApur(mv_par01) )

		aAdd( aLoad, {nX++,  { "Valor Total dos Tributos" 	                             , aDet3A[1][11]} } )
		aAdd( aLoad, {nX++,  { "Receita Bruta dos Últimos 12 Meses (RBT12) - Interno"    , aDet3A[1][1]} } )
		aAdd( aLoad, {nX++,  { "Receita Bruta dos Últimos 12 Meses (RBT12) - Exportação" , aDet3A[1][2]} } )
		aAdd( aLoad, {nX++,  { "Receita Bruta Anual (RBA)  - Interno"  		 		  	, aDet3A[1][3]} } )
        aAdd( aLoad, {nX++,  { "Receita Bruta Anual (RBA)  - Exportação"		 	 	, aDet3A[1][4]} } )
		aAdd( aLoad, {nX++,  { "Receita do Período de Apuração (RPA)  - Interno "  		 , aDet3A[1][5]} } )
        aAdd( aLoad, {nX++,  { "Receita do Período de Apuração (RPA)  - Exportação"		 , aDet3A[1][6]} } )
		aAdd( aLoad, {nX++,  { "Folha de Salário do Período de Apuração (FS12)"          , aDet3A[1][7]} } )
		aAdd( aLoad, {nX++,  { "Devoluções no Período - Mercado Interno "                , aDet3A[1][8]} } )
		aAdd( aLoad, {nX++,  { "Devoluções no Período - Mercado Externo "                , aDet3A[1][9]} } )
		aAdd( aLoad, {nX++,  { "Fator R"            		                             , aDet3A[1][10]} } )

	Case cTabela == 'ABA3B'
		//---------------------------------------------------------------------------------
		// Insere informações na segunda tela da apuração - Resumo das operações de entrada
		//---------------------------------------------------------------------------------

		aTributo	:= TotTribPer( FSA200DataApur(mv_par01) )

		aAdd( aLoad, {nX++,  { aTributo[1] , aTributo[2] ,aTributo[3] , aTributo[4] , aTributo[5] , aTributo[6] ,aTributo[7] , aTributo[8]  } } )

	Case cTabela == 'ABA4A'

		aDet4A := DetABA4A( F1A->F1A_ID )

		For nY := 1 to Len(aDet4A)

			If aDet4A[nY, 3] == "1" .And. aDet4A[nY, 5] == "1"
				cStatusEst := "BR_VERDE"
			ElseIf aDet4A[nY, 3] == "2" .Or. aDet4A[nY, 5] == "2"
				cStatusEst := "BR_AMARELO"
			ElseIf aDet4A[nY, 3] == "3" .Or. aDet4A[nY, 5] == "3"
				cStatusEst := "BR_VERMELHO"
			EndIf

			If aDet4A[nY, 4] == "1" .And. aDet4A[nY, 6] == "1"
				cStatusFed := "BR_VERDE"
			ElseIf aDet4A[nY, 4] == "2" .Or. aDet4A[nY, 6] == "2"
				cStatusFed := "BR_AMARELO"
			ElseIf aDet4A[nY, 4] == "3" .Or. aDet4A[nY, 6] == "3"
				cStatusFed := "BR_VERMELHO"
			EndIf

			aAdd( aLoad, {nX++,  { aDet4A[nY, 1] , aDet4A[nY, 2] , aDet4A[nY, 8], aDet4A[nY, 9], aDet4A[nY, 10],  cStatusFed , cStatusFed , cStatusFed , cStatusFed , cStatusFed , cStatusFed , cStatusEst , cStatusEst } } )

		Next nY	

	Case cTabela == "ABA4B"

		aAdd( aLoad, {nX++,  { "BR_VERDE"    , "Recolhimento PERMITIDO no Simples Nacional"                        } } )
		aAdd( aLoad, {nX++,  { "BR_AMARELO"  , "Recolhimento IMPEDIDO no Simples Nacional a partir do próximo ano" } } )
		aAdd( aLoad, {nX++,  { "BR_VERMELHO" , "Recolhimento IMPEDIDO no Simples Nacional a partir do próximo mês" } } )

EndCase

Return( aLoad )


//-------------------------------------------------------------------
/*/{Protheus.doc} x001Struct

Função utilizada para criação das tabelas temporárias para as abas
da apuração, já que as tabelas não estão em dicionário, deverão ser
criadas manualmente.

@param  	nOpcao  - indica se foi chamada na criação do Model ou da View.
			cTabela - Indica o alias da tabela temporária
@return	oStru  - Estrutura criada com os campos da tabela temporária qe será exibida na tela.
@author Erick G. Dias
@since 07/04/2014
@version 12117

/*/
//-------------------------------------------------------------------
Static Function x001Struct(nOpcao,cTabela)

Local aCampos	:= {}
Local nCont	:= 0
Local oStru

//Chama Função para criar os campos conforme tabela processada
aCampos:= a002Tabs(cTabela)

//Quando for chamada para criar Model
If nOpcao == 1

	oStru :=  FWFormModelStruct():New()//	FWFormStruct( 1 , '')//
	oStru:AddTable("TRB",{},"TOTVS")
	For nCont := 1 to len (aCampos)
		oStru:AddField( ; 					// Ord. Tipo Desc.
						aCampos[nCont][1] , ;// [01] C Titulo do campo
						aCampos[nCont][1] , ;// [02] C ToolTip do campo
						aCampos[nCont][2] , ;// [03] C identificador (ID) do Field
						aCampos[nCont][3] , ;// [04] C Tipo do campo
						aCampos[nCont][4] , ;// [05] N Tamanho do campo
						aCampos[nCont][5] , ;	// [06] N Decimal do campo
						NIL				,;	// [07] B Code-block de validação do campo
						NIL 				, ;	// [08] B Code-block de validação When do campo
						aCampos[nCont][10]  , ;	// [09] A Lista de valores permitido do campo
						NIL 				, ;	// [10] L Indica se o campo tem preenchimento obrigatório
						nil					, ;	// [11] B Code-block de inicializacao do campo
						NIL 				, ;	// [12] L Indica se trata de um campo chave
						.F. 				, ;	// [13] L Indica se o campo pode receber valor em uma operação de update.
						.F. ) 					// [14] L Indica se o campo é virtual
	Next nCont

//Quando for chamada para criar a View
ElseIF nOpcao == 2

	oStru := FWFormViewStruct():New()
	For nCont := 1 to len (aCampos)
		oStru:AddField( ;
		aCampos[nCont][2], ; // [01] C Nome do Campo
		aCampos[nCont][6], ;	// [02] C Ordem
		aCampos[nCont][1], ;	// [03] C Titulo do campo
		aCampos[nCont][1], ;	// [04] C Descrição do campo
	    aCampos[nCont][7], ; // [05] A Array com Help
		aCampos[nCont][3], ; 	// [06] C Tipo do campo
		aCampos[nCont][8], ; // [07] C Picture
		NIL 			   , ;	// [08] B Bloco de Picture Var
		''                 , ; 	// [09] C Consulta F3
		aCampos[nCont][9]	, ; 	// [10] L Indica se o campo é evitável
		nil				   , ; 	// [11] C Pasta do campo
		NIL                , ;	// [12] C Agrupamento do campo
		aCampos[nCont][10] , ; 	// [13] A Lista de valores permitido do campo
		NIL                , ;	// [14] N Tamanho Maximo da maior opção do combo
		NIL                , ; 	// [15] C Inicializador de Browse
		.F.                , ; 	// [16] L Indica se o campo é virtual
		NIL )
	Next nCont

EndIF

Return oStru


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA154RBT

Função que retorna o valor das receitas dos últimos 12 meses e o RBA
do ano corrente.

@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Function FSA154RBT(dPer, cOp , lPerAtu, lPosFil, nQtdMes)

Local aMesRBT12	:= {}
Local dPer12	:= dPer
Local nX		:= 0
Local nPos		:= 0
Local aRec		:= {}
Local nValor	:= 0
Local cData		:= ""
Default lPerAtu	:= .F.
Default lPosFil	:= .T.
DEfault nQtdMes	:= 12

//Chamara execução da query na tabela F15
aRec		:= TotRecBrut( dPer, cOp, lPerAtu, lPosFil )

//Indica se deverá processar as receitas do período
If lPerAtu

	For nX:= 1 to len(aRec)

		cData	:= MesExtenso(dPer) + '/' +  Str(year(dPer),4)

		aAdd(aMesRBT12, {})
		nPos := Len(aMesRBT12)
		aAdd (aMesRBT12[nPos],  cData )
		aAdd (aMesRBT12[nPos],  aRec[nX][2])

	Next nX

Else
	//Aqui indica que deverá processa as receitas dos últimos 12 mes
	For nX:= 1 to 12

		dPer12  := FirstDay(dPer12) - 1
		cData	:= MesExtenso(dPer12) + '/' +  Str(year(dPer12),4)
		nValor	:= 0
		nPos 	:= ASCAN(aRec, {|aX| aX[1] == cData  })
		IF nPos > 0 .AND. nX >=  13 - nQtdMes
			nValor	:= 	aRec[nPos][2]
		EndIF

		aAdd(aMesRBT12, {})
		nPos := Len(aMesRBT12)
		aAdd (aMesRBT12[nPos],  cData )
		aAdd (aMesRBT12[nPos],  nValor)

	Next nX

EndIF

Return aMesRBT12

//-------------------------------------------------------------------
/*/{Protheus.doc} TotTribAtv

Função que buscará na tabela F19 os valores calculados e agrupados por
subatividades.

@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function TotTribAtv( cIdApur, lIntExp )

Local aRet 		:= {}
Local cAliasF19	:= 'F19'
Local cSlctF19	:= ''
Local cFiltro	:= ''
Local cGroupBy	:= ''
Default lIntExp	:= .F.

IF lIntExp
	//Agrupará somente por interno e externo
	cSlctF19:= '% F19.F19_TPREC, SUM(F19.F19_TOTDEV) AS F19_TOTDEV%'
	cGroupBy:= '%GROUP BY F19.F19_TPREC%'
Else
	//Agrupará por código de sub atividade
	cSlctF19:= '% F19.F19_CODATV,	SUM(F19.F19_TOTAL) AS F19_TOTAL, SUM(F19.F19_TOTREC) AS F19_TOTREC , SUM(F19.F19_RECBRU) AS F19_RECBRU,  SUM(F19.F19_TOTDEV) AS F19_TOTDEV%'
	cGroupBy:= '%GROUP BY F19.F19_CODATV%'
EndIF

cFiltro := "%"
cFiltro += "F19.F19_IDAPUR = "  + ValToSQL(cIdApur)    + " AND "
cFiltro += "%"

cAliasF19	:=	GetNextAlias()
BeginSql Alias cAliasF19

	SELECT
	%Exp:cSlctF19%

	FROM
	%Table:F19% F19
	WHERE
	%Exp:cFiltro%
	F19.%NotDel%

	%Exp:cGroupBy%

EndSql
DbSelectArea (cAliasF19)
(cAliasF19)->(DbGoTop ())

Do While !(cAliasF19)->(Eof ())
	
	IF lIntExp
		aAdd( aRet, {(cAliasF19)->F19_TPREC, (cAliasF19)->F19_TOTDEV } )
	Else
		aAdd( aRet, {(cAliasF19)->F19_CODATV, (cAliasF19)->F19_RECBRU, (cAliasF19)->F19_TOTDEV, (cAliasF19)->F19_TOTREC, (cAliasF19)->F19_TOTAL } )
	EndIF

	(cAliasF19)->(DbSkip ())
EndDo
DbSelectArea (cAliasF19)
(cAliasF19)->(DbCloseArea())

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TotRecBrut


@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function TotRecBrut( dPer, cOp, lPerAtu, lPosFil )

Local aRet 		:= {}
Local cAliasF15	:= 'F15'
Local cSlctF15	:= ''
Local cFiltro	:= ''
Local cGroupBy	:= ''
Local dPerIni	:= STOD( Str( year( dPer ) - 1 ,4 ) +  Str(month(dPer),2) +  "01" )
Local nPos		:= 0
Local cData		:= ""
Local aAreaSM0 	:= SM0->(GetArea())
Local cAliasF18	:= ""
Default lPerAtu	:= .F.
Default lPosFil	:= .T.

//Quando função for chamada solicitando somente total da receita do período, dPerIni recebe dPer
If lPerAtu
	dPerIni	:= dPer
EndIF

//Busca valores da própria filial
QryF15( dPer, cOp, @aRet, dPerIni, lPerAtu )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QryF15

Função que realizar query na tabela F15

@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function QryF15( dPer, cOp, aRet, dPerIni, lPerAtu )
Local cAliasF15	:= 'F15'
Local cSlctF15	:= ''
Local cFiltro	:= ''
Local cData		:= ""
Local nPos		:= 0
Local cDataIni	:=  year2str( dPerIni )  + month2str( dPerIni )
Local cDataFim	:=  year2str( dPer )     + month2str( dPer )
Local dData

cFiltro		:= ""
cSlctF15	:= ""
cGroupBy	:= ""

cSlctF15:= '%F15.F15_VALOR,F15.F15_MES, F15.F15_ANO, F15.F15_TPREC%'
cFiltro := "%"
cFiltro += "F15.F15_FILIAL = "  + ValToSQL(xFilial("F15"))    + " AND "
cFiltro += "F15.F15_ANO || F15.F15_MES >= " + ValToSQL( cDataIni )  + " AND "
cFiltro += "F15.F15_ANO || F15.F15_MES "  + Iif(lPerAtu , "<=" , "<" ) +   " "  + ValToSQL( cDataFim )  + " AND "
cFiltro += "F15.F15_TPREC  = " + ValToSQL( cOp )   + " AND "
cFiltro += "%"

cAliasF15	:=	GetNextAlias()
BeginSql Alias cAliasF15

	SELECT
	%Exp:cSlctF15%

	FROM
	%Table:F15% F15
	WHERE
	%Exp:cFiltro%
	F15.%NotDel%

EndSql
DbSelectArea (cAliasF15)
(cAliasF15)->(DbGoTop ())
Do While !(cAliasF15)->(Eof ())

	dData	:= FSA200DataApur( (cAliasF15)->F15_MES + (cAliasF15)->F15_ANO  )
	cData	:= MesExtenso( dData ) + '/' +  Str(year( dData ),4)

	nPos := ASCAN(aRet, {|aX| aX[1] == cData  })

	If nPos == 0
		aAdd( aRet, {  cData , (cAliasF15)->F15_VALOR  })
	Else
		aRet[nPos][2] += (cAliasF15)->F15_VALOR
	EndIF


	(cAliasF15)->(DbSkip ())
EndDo
DbSelectArea (cAliasF15)
(cAliasF15)->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DbClickAtv

Esta função realiza o tratamento do duplo clique no detalhe das atividade
exibindo assim os valoes por filial e por sub atividades

@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function DbClickAtv( oModelGrid, nLinha, cAcao, cCampo )

Local cCodAtv		:= ''
Local cFiltroBrw	:= ''
Local cDescr		:= ''
Local cAlias		:= ''
Local oBrowse
Local lRet			:= .F.

//Verifica se a origem foi da segunda aba
IF substr(cCampo,1,4) == "ABA2"
	oModelGrid:GoLine( nlinha )
	cCodAtv	:= oModelgrid:GetValue('ABA2_CMP1')
	
	//Monta o filtro com o código da atividade clicado
	cFiltroBrw 	:=	'F19_IDAPUR == "' + F1A->F1A_ID + '"'
	cFiltroBrw	+=  '.AND. F19_CODATV == "' + cCodAtv + '"'
	cDescr		:=  "Atividade - " + cCodAtv + " - " + POSICIONE("F12",1,xFilial("F12")+cCodAtv ,"F12_DESCR")
	cAlias		:=  'F19'

	//Monta o Browse para exibir o detalhamento das sub atividades
	cFsa200ALS	:= cAlias
	oBrowse := FWmBrowse():New()
	oBrowse:SetDescription( cDescr)
	oBrowse:SetAlias( cAlias )
	oBrowse:SetMenuDef( 'FISA152' )
	oBrowse:DisableDetails()
	oBrowse:ForceQuitButton()
	oBrowse:SetFilterDefault( cFiltroBrw )
	oBrowse:Activate()

ElseIF substr(cCampo,1,4) == "ABA3" .AND. cAcao == "SETVALUE"
	//Esta situação ocorrerá no momento de salvar a tela, pois como se trata de um modelo 
	//com campos ´temporários, eu preciso alterar o modelo para que o MVC permita salvar a tela
	//se exibir a mensagem que "O modelo não foi alterado e não será salvo"
	lRet	:= .T.
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TotTribPer

Função que retorna um array com o total de tributos processados no período

@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function TotTribPer( dPer )

Local atributo	:= {0,0,0,0,0,0,0,0}
Local cAliasF18	:= QryF18( F1A->F1A_ID ) //Busca todas as F18 com o Id da F1A

//Buscar todas as F18 que foram geradas por esta Apuração.
Do While !(cAliasF18)->(Eof ())

	atributo[1]	+= (cAliasF18)->F18_IRPJ
	atributo[2]	+= (cAliasF18)->F18_CSLL
	atributo[3]	+= (cAliasF18)->F18_COFINS
	atributo[4]	+= (cAliasF18)->F18_PIS
	atributo[5]	+= (cAliasF18)->F18_CPP
	atributo[6]	+= (cAliasF18)->F18_IPI
	atributo[7]	+= (cAliasF18)->F18_ICMS
	atributo[8]	+= (cAliasF18)->F18_ISS	

	(cAliasF18)->(DbSkip ())
EndDo

DbSelectArea (cAliasF18)
(cAliasF18)->(DbCloseArea())

Return atributo

//-------------------------------------------------------------------
/*/{Protheus.doc} DetABA3A

Função que retorna um array com o total de tributos processados no período

@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function DetABA3A( dPer )

Local aDev 		:= {}
Local aRet  	:= {}
Local nPos		:= 0
Local aValor	:= {}
Local nX		:= 0
Local nValor	:= 0
Local nValDevI	:= 0
Local nValDevE	:= 0
local nTotTrib	:= 0
Local nFatoRR	:= 0
Local cAliasF18	:= QryF18( F1A->F1A_ID )

aAdd(aRet, {})
nPos := Len(aRet)

//Processa RBT12 - Interno
aAdd (aRet[nPos],  F1A->F1A_RBT12I )

//Processa RBT12 - Externo
aAdd (aRet[nPos],  F1A->F1A_RBT12E )

//Processa RBA - Interno
aAdd (aRet[nPos],  F1A->F1A_RBAI )

//Processa RBA - Interno
aAdd (aRet[nPos],  F1A->F1A_RBAE )

//Processa RBTM - Interno
aAdd (aRet[nPos],  F1A->F1A_RPAI )

//Processa RBTM - Externo
aAdd (aRet[nPos],  F1A->F1A_RPAE )

//Folha de salário
aAdd (aRet[nPos],  F1A->F1A_FS12 )

//Traz somente as devoluções da F19, agrupados por mercado interno e externo
aDev	:= TotTribAtv( F1A->F1A_ID , .T. )

For nX	:=1 to Len( aDev )

	If aDev[nX][1] == "1"
		//Devolução do mercado Interno
		nValDevI	:= aDev[nX][2]
	ElseIF aDev[nX][1] == "2"
		//Devolução do mercado Interno
		nValDevE	:= aDev[nX][2]
	EndIF

Next nX

//Devoluções Mercado Interno
aAdd (aRet[nPos],  nValDevI )

//Devoluções Mercado Externo
aAdd (aRet[nPos],  nValDevE )

//Buscar todas as F18 que foram geradas por esta Apuração.
Do While !(cAliasF18)->(Eof ())

	//Fator R	
	nFatoRR	:= (cAliasF18)->F18_FATORR

	//Total dos tributos
	nValor	:= (cAliasF18)->F18_IRPJ + (cAliasF18)->F18_CSLL + (cAliasF18)->F18_COFINS + (cAliasF18)->F18_PIS + (cAliasF18)->F18_CPP + (cAliasF18)->F18_IPI + (cAliasF18)->F18_ICMS + (cAliasF18)->F18_ISS
	nTotTrib	+= nValor
	

	(cAliasF18)->(DbSkip ())
EndDo

//Fator R
aAdd (aRet[nPos],  nFatoRR )

//Total dos tributos
aAdd (aRet[nPos],  nTotTrib )

DbSelectArea (cAliasF18)
(cAliasF18)->(DbCloseArea())

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA154SREC


@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Function FSA154SREC(aRec)

Local nRet	:= 0
Local nX	:= 0

For nX	:= 1 to Len(aRec)

	nRet	+= aRec[nX][2]

Next nX

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DetABA4A

Função que busca as informações do detalhamento da aba 4

@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function DetABA4A(cIDApur)

Local aRet := {}
Local nPos := 0
Local cAliasF18	:= QryF18( cIdApur )

Do While !(cAliasF18)->(Eof ())

	aAdd(aRet, {})
	nPos := Len(aRet)

	aAdd(aRet[nPos], (cAliasF18)->F18_ESTABE)
	aAdd(aRet[nPos], FWFilialName(cEmpAnt, (cAliasF18)->F18_ESTABE))
	aAdd(aRet[nPos], (cAliasF18)->F18_SUBLIM)
	aAdd(aRet[nPos], (cAliasF18)->F18_LIMITE)
	aAdd(aRet[nPos], (cAliasF18)->F18_SUBEXT)
	aAdd(aRet[nPos], (cAliasF18)->F18_LEXT)
	aAdd(aRet[nPos], (cAliasF18)->F18_LEXT)
	aAdd(aRet[nPos], (cAliasF18)->F18_VALSUB)
	aAdd(aRet[nPos], (cAliasF18)->F18_VALLIM)
	aAdd(aRet[nPos], SuperGetmv("MV_DTINISI" , .F., "  /  /    ", (cAliasF18)->F18_ESTABE))

	(cAliasF18)->(DbSkip ())

EndDo

(cAliasF18)->(DbCloseArea())

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ChartBarra

Função que monta o gráfico de barras, comparando a receita da matriz
com limites e sub limites

@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function ChartBarra( oPanel )

Local nLimite		:= 0
Local nSubLimite	:= 0
Local nRbt12Int		:= 0
Local nRbt12Exp		:= 0

//Busca as receitas
ReceitaChart( @nLimite, @nSubLimite, @nRbt12Int, @nRbt12Exp )

//Inicializa e popula o grárico
oChart:init( oPanel, .T. )
PopulaBar( "Limites do Simples", nLimite, nLimite, nSubLimite, nSubLimite, nRbt12Int, nRbt12Exp )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ChartRBTA

Gráfico de linhas, que exibe a evolução do RBA

@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function ChartRBTA( oPanel )

Local aRand 		:= {}
Local aMesVal		:= {}
Local nLimite		:= 0
Local nSubLimite	:= 0
Local nRbt12Int		:= 0
Local nRbt12Exp		:= 0
Local nValor		:= 0
Local nX			:= 0
Local nX 			:= 0
Local nValI			:= 0
Local nValE			:= 0
Local aMesInt		:= {}
Local aMesExp		:= {}
Local nCont			:= Month(FSA200DataApur(MV_PAR01))
Local nPosA
Local oModel        :=	FWModelActive()
Local oRBA 	    	:= oModel:GetModel('MODEL_ABA1A' )
Local oLinha 		:= FWChartLine():New()

oLinha:init( oPanel, .t. )
oLinha:setLegend( CONTROL_ALIGN_LEFT )
oLinha:cPicture := "@E 999,999,999,999,999.99"

aAdd (aMesInt,  { "" , 0 } )
aAdd (aMesExp,  { "" , 0 } )

//Obtem o total da receita acumulada no ano
For nX:= 1 to  nCont

	oRBA:GoLine( nX )

	nValI	+= oRBA:GetValue("ABA1A_CMP2",nx) //mercado interno
	nValE	+= oRBA:GetValue("ABA1A_CMP3",nx) //mercado externo

	aAdd (aMesInt,  { oRBA:GetValue("ABA1A_CMP1",nx) , nValI } )
	aAdd (aMesExp,  { oRBA:GetValue("ABA1A_CMP1",nx) , nValE } )


Next(nX)

oLinha:addSerie( "Receita Interna" ,  aMesInt  )
oLinha:addSerie( "Receita Externa" ,  aMesExp )

oLinha:Build()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtualizaGrafico

Função responsável por atualizar o gráfico, considerando as filiais selecionadas no list

@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function AtualizaGrafico( oList1 )

Local nPos 			:= oList1:NAT
Local nLimite		:= 0
Local nSubLimite	:= 0
Local nRbt12Int		:= 0
Local nRbt12Exp		:= 0
Local aAreaSM0 		:= SM0->(GetArea())

SM0->(DbGoTop ())
SM0->(MsSeek (cEmpAnt + oList1:aItems[nPos] , .T.))
cFilAnt := FWGETCODFILIAL

//Posiciona na Filial para buscar os valores das receitas
ReceitaChart( @nLimite, @nSubLimite, @nRbt12Int, @nRbt12Exp )
//Retornar filial logada
RestArea (aAreaSM0)
cFilAnt := FWGETCODFILIAL

PopulaBar( "Limites do Simples", nLimite, nLimite, nSubLimite, nSubLimite, nRbt12Int, nRbt12Exp )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PopulaBar

Função que popula os grárico de barras

@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function PopulaBar( cTitle, nFI, nFE, nEI, nEE, nPI, nPE )

Local cMI 	:= "Receita do Mercado Interno"
Local cME 	:= "Receita do Mercado Externo"
Local aRand	:= {}

oChart:Reset()
//oChart:SetTitle( cTitle , CONTROL_ALIGN_CENTER )
oChart:addSerie( "Limite Excedido em até 20%"				, { {cMI , nFI * 1.2 } , {cME,nFE * 1.2 }} )
oChart:addSerie( "Limite"									, { {cMI , nFI }	   , {cME,nFE  }} )
oChart:addSerie( "SubLimite Excedido em até 20%"			, { {cMI , nEI * 1.2 } , {cME,nEE * 1.2  }} )
oChart:addSerie( "SubLimite"    							, { {cMI, nEI } 	   , {cME,nEE  }} )
oChart:addSerie( "RBA (Visão Centralizada)" 			   , { {cMI, nPI } 	   , {cME,nPE  }} )
oChart:setLegend( CONTROL_ALIGN_LEFT )

oChart:cPicture := "@E 999,999,999,999,999.99"
aAdd(aRand, {"084,120,164", "007,013,017"}) //Azul Claro
aAdd(aRand, {"175,175,175", "011,011,011"}) //Cinza Claro
aAdd(aRand, {"141,225,078", "017,019,010"}) //Verde Claro
aAdd(aRand, {"166,085,082", "017,007,007"}) //Vermelho Claro
aAdd(aRand, {"207,136,077", "020,020,006"}) //Laranja Claro

oChart:oFWChartColor:aRandom := aRand
oChart:oFWChartColor:SetColor("Random")
oChart:Build()
oChart:Refresh ()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReceitaChart


@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function ReceitaChart( nLimite, nSubLimite, nRbt12Int, nRbt12Exp )

Local nValor		:= 0
Local nX 			:= 0
Local aMesVal		:= {}
Local oModel        :=	FWModelActive()
Local oRBA 	    	:= oModel:GetModel('MODEL_ABA1A' )
Local nX 			:= 0
Local cAliasF18		:= QryF18( F1A->F1A_ID, .T. )
Local nCont			:= Month(FSA200DataApur(MV_PAR01))

//Obtem o total da receita acumulada no ano
For nX := 1 to  nCont

	oRBA:GoLine( nX )
    nRbt12Int	+= oRBA:GetValue("ABA1A_CMP2",nX)
	nRbt12Exp	+= oRBA:GetValue("ABA1A_CMP3",nX)

Next(nX)

//Posicionar a F18 da filial e buscar os limites gravados nela
Do While !(cAliasF18)->(Eof ())
	nLimite	:= (cAliasF18)->F18_VALLIM
	nSubLimite	:= (cAliasF18)->F18_VALSUB

	(cAliasF18)->(DbSkip ())
EndDo

DbSelectArea (cAliasF18)
(cAliasF18)->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} QryF18

Função que realiza query na tabela F18

@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function QryF18( cIdApur, lFilial )
Local cAliasF18	:= 'F18'
Local cSlctF18	:= ''
Local cFiltro	:= ''
Default lFilial	:= .F.

cFiltro		:= ""
cSlctF18	:= ""

cSlctF18:= '%F18.*%'
cFiltro := "%"
If lFilial
	cFiltro += "F18.F18_FILIAL = "  + ValToSQL(xFilial("F18"))    + " AND "
EndIF
cFiltro += "F18.F18_IDAPUR = "  + ValToSQL(cIdApur)    + " AND "
cFiltro += "%"

cAliasF18	:=	GetNextAlias()
BeginSql Alias cAliasF18

	SELECT
	%Exp:cSlctF18%

	FROM
	%Table:F18% F18
	WHERE
	%Exp:cFiltro%
	F18.%NotDel%

EndSql
DbSelectArea (cAliasF18)
(cAliasF18)->(DbGoTop ())

Return cAliasF18

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA154TIT

Função responsável pela geração dos títulos e contabilizações.

@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Function FSA154TIT()

Local lRet 			:= .T.
Local lGeraTit		:= .F.
Local lContab		:= .F.
Local lTit 			:= .F.
Local dDtFim		:= cTod("  /  /    ")
Local dDtVenc		:= CTod("  /  /    ")
Local aRecnoTit		:= {}
Local oModel    	:=	FWModelActive()
Local oTrib	    	:= oModel:GetModel('MODEL_ABA3B' )
Local oTela  		:= oModel:GetModel('MODEL_ABA' )
lOCAL oView 		:= 	FWViewActive()
Local cLPadSim		:= ""
Local cLcPadTit		:= ""
Local cLcPadExt		:= ""
Local cNumTit		:= ""
Local cPreTit		:= ""
Local cParcTit		:= ""
Local cTipoTit		:= ""
Local cFornTit		:= ""
Local cLojaTit		:= ""
Local nValRefresh	:= 0
Local nValPagar		:= 0

//Se estiver processando apuração ou então foi selecionado em outras ações geração de título/contabilização proecssará o trecho abaixo
IF (!lVisualizando .OR. cOpTitCont $ "2/3")

	lGeraTit	:= MV_PAR04 == 2 .OR. MV_PAR04 == 3
	lContab		:= MV_PAR04 == 3
	dDtFim		:= Lastday( FSA200DataApur(mv_par01) )
	cLPadSim	:= Iif( lContab , AllTrim( GetNewPar( "MV_LPADSN" , "" ) ) , "" )
	cLcPadTit	:= Substr( cLPadSim, 1, 3 )
	cLcPadExt	:= Substr( cLPadSim, 4, 3 )
	dDtVenc		:= DataValida(dDtFim+20,.T.)

	//Busca o total dos valores da aba dos totais dos tributos
	oTrib:GoLine( 1 )
	nValPagar	:= 	oTrib:GetValue("ABA3B_CMP1",1) +  oTrib:GetValue("ABA3B_CMP2",1) + oTrib:GetValue("ABA3B_CMP3",1) + oTrib:GetValue("ABA3B_CMP4",1)  +oTrib:GetValue("ABA3B_CMP5",1) +  oTrib:GetValue("ABA3B_CMP6",1) + oTrib:GetValue("ABA3B_CMP7",1) + oTrib:GetValue("ABA3B_CMP8",1)

	lContab	:= MV_PAR04 == 3 .AND. !Empty(cLPadSim)

EndIF

If (!lVisualizando .OR. cOpTitCont $ "2/3") .AND. nValPagar > 0

	//Aqui deverá confirmar se usuário deseja gerar título
	IF lGeraTit .or. lContab
		//Gerar Título
		GravaTit(lGeraTit,; //Gera Título
				nValPagar,; //Valor do Título
				"SPN",; //Prefixo do Tìtlo
				"SN",; //
				cLcPadTit,; //Lançamento padrão para contabilizar
				FSA200DataApur(mv_par01),; //Data Inidial
				Lastday( FSA200DataApur(mv_par01) ),; //Data Final
				dDtVenc,; //Data de vencimento do título
				1,; //Moeda real
				.F.,; //indica se deve gerar guia
				,; //Mês da guia
				,; //Ano da Guia
				0,;//Valor do ICMS
				0,;//Valor do ICMS ST
				"FISA153",; //Rotina de Origem
				lContab,; //indica se deverá contabilizar 16
				,,,,,,,,,@aRecnoTit,,,,,,,,,,,,,,,,)

		//Utiliza o recno da SE2 para fazer o filtro e exibir o título no borwse
		If lGeraTit .AND. Len( aRecnoTit ) > 0 
			lTit	:= .T.
			SE2->(dbGoto( aRecnoTit[1][1]  ))

			cNumTit		:= SE2->E2_NUM
			cPreTit		:= SE2->E2_PREFIXO
			cParcTit	:= SE2->E2_PARCELA
			cTipoTit	:= SE2->E2_TIPO
			cFornTit	:= SE2->E2_FORNECEDOR
			cLojaTit	:= SE2->E2_LOJA

			VisualTitulo( SE2->E2_NUM )

		EndIF

	EndIF

EndIF
//Este trecho é necessário, pois preciso alterar o modelo para o botão confirmar fechar a tela.
//Como o modelo possui tabela temporária, preciso alterar o modelo manualmente
nValRefresh	:= oTrib:GetValue("ABA3B_CMP1",1)
oTrib:SetValue('ABA3B_CMP1', 10 )
oview:Refresh( 'VIEW_ABA3B' )
oTrib:SetValue('ABA3B_CMP1', nValRefresh )
oview:Refresh( 'VIEW_ABA3B' )

//Apenas clicou no botão OK, irei alterar a F1A para pode salvar o documento
IF (!lVisualizando .OR. cOpTitCont $ "2/3")
	RecLock('F1A',.F.)	
	F1A->F1A_NUMTIT  	:= cNumTit
	F1A->F1A_PRETIT  	:= cPreTit
	F1A->F1A_PARTIT  	:= cParcTit
	F1A->F1A_TPTIT  	:= cTipoTit
	F1A->F1A_FORTIT	 	:= cFornTit
	F1A->F1A_LOJTIT	 	:= cLojaTit

	If lTit .AND. !lContab
		//2 Gerou somente movimentação Financeira
		F1A->F1A_STATUS	:= "2"
	ElseIF lContab .AND. lTit
		//3 Gerou título e contabilização
		F1A->F1A_STATUS	:= "3"
	Else
		//1 Não gerou movimentação Financeira e Contábil
		F1A->F1A_STATUS	:= "1"
	EndIF

	F1A->(msUnlock())
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA154FSP12

Função que busca o valor da folha de salários dos últimos 12 meses.

@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Function FSA154FSP12( dPer, lPerAtu )

Local dPerIni		:= STOD( Str( year( dPer ) - 1 ,4 ) +  Str(month(dPer),2) +  "01" )
Local cAliasF1C		:= "F1C"
Local cSlctF1C		:= ""
Local cFiltro		:= ""
Local cDataIni		:= ""
Local cDataFim		:= ""
Local cData			:= ""
local aRet			:= {}
Local nPos			:= 0
Local dData

If lPerAtu
	cDataIni	:=  year2str( dPer )  + month2str( dPer )

Else
	cDataIni	:=  year2str( dPerIni )  + month2str( dPerIni )
EndIF

cDataFim	:=  year2str( dPer )  + month2str( dPer )

cFiltro		:= ""
cSlctF1C	:= ""

cSlctF1C:= '%F1C.F1C_VALOR, F1C.F1C_MES, F1C.F1C_ANO %'
cFiltro := "%"
cFiltro += "F1C.F1C_FILIAL = "  + ValToSQL(xFilial("F1C"))    + " AND "
cFiltro += "F1C.F1C_ANO || F1C.F1C_MES >= " + ValToSQL( cDataIni )  + " AND "
cFiltro += "F1C.F1C_ANO || F1C.F1C_MES "  + Iif(lPerAtu , "<=" , "<" ) +   " "  + ValToSQL( cDataFim )  + " AND "
cFiltro += "%"

cAliasF1C	:=	GetNextAlias()
BeginSql Alias cAliasF1C

	SELECT
	%Exp:cSlctF1C%

	FROM
	%Table:F1C% F1C
	WHERE
	%Exp:cFiltro%
	F1C.%NotDel%

EndSql
DbSelectArea (cAliasF1C)
(cAliasF1C)->(DbGoTop ())
Do While !(cAliasF1C)->(Eof ())

	dData	:= FSA200DataApur( (cAliasF1C)->F1C_MES + (cAliasF1C)->F1C_ANO  )
	cData	:= MesExtenso( dData ) + '/' +  Str(year( dData ),4)

	nPos := ASCAN(aRet, {|aX| aX[1] == cData  })

	If nPos == 0
		aAdd( aRet, {  cData , (cAliasF1C)->F1C_VALOR  })
	Else
		aRet[nPos][2] += (cAliasF1C)->F1C_VALOR
	EndIF

	(cAliasF1C)->(DbSkip ())
EndDo
DbSelectArea (cAliasF1C)
(cAliasF1C)->(DbCloseArea())

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VisualTitulo

Função utilizada para exibir o título gerado pela apuração.

@author Erick G. Dias
@since 27/03/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function VisualTitulo( cTitGerado )

Local oBrowse 		:= FWmBrowse():New()
Local lUnidNeg 		:= Iif( FindFunction("FWCodFil") , FWSizeFilial() > 2, .F. ) // Verifica se utiliza Gestão Corporativa
Local cFiltroBrw	:= ""

If !Empty( Iif( lUnidNeg, FWFilial("SE2") , xFilial("SE2") ) )
	cFiltroBrw 	:= "E2_FILIAL == '"  +   xFilial("SE2") + "' .AND. "
Else
	If SE2->(FieldPos("E2_MSFIL")) > 0
		cFiltroBrw 	:= "E2_MSFIL == '" + Iif(lUnidNeg,  xFilial("SE2"), cFilAnt) + "' .AND. "
	Else
		cFiltroBrw 	:= "E2_FILORIG == '" + Iif(lUnidNeg, xFilial("SE2"), cFilAnt) + "' .AND. "
	Endif
EndIf

cFiltroBrw =+ ' E2_PREFIXO == "SPN" .AND.  E2_ORIGEM == "FISA153" .AND. E2_NUM == "' +  cTitGerado + '"'

cFsa200ALS	:= "SE2"
cFsa200DESC	:= "Movimentação Financeira gerada pela Apuração do Simples Nacional"

oBrowse:SetDescription( cFsa200DESC )
oBrowse:SetAlias( cFsa200ALS )
oBrowse:SetMenuDef( 'FISA152' )
oBrowse:DisableDetails()
oBrowse:ForceQuitButton()
oBrowse:SetFilterDefault( cFiltroBrw ) 
oBrowse:Activate()

cFsa200ALS	:= ""
cFsa200DESC	:= ""

Return

