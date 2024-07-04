#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'GPEA644.ch'

Function GPEA644()

Local oBrw := FwMBrowse():New()
Local cFiltraRh := ""

If nModulo == 7
	cFiltraRH	:= ChkRh( "GPEA644" , "SRA" , "1" )
	oBrw:SetAlias( 'SRA' )
	oBrw:SetFilterDefault(cFiltraRH)
	oBrw:ExecuteFilter(.T.)
	GpLegend(@oBrw,.T.)
Else
	oBrw:SetAlias( 'AA1' )
EndIf
oBrw:SetMenudef( "GPEA644" )
oBrw:SetDescription( OEmToAnsi( STR0001 ) ) //"Gestão de Disciplina"

oBrw:Activate()

Return

//------------------------------------------------------------------------------
/*/ {Protheus.doc} Menudef
	Rotina para construção do menu

@sample 	Menudef() 

@since		06/09/2013  
@version 	P11.90
/*/
//------------------------------------------------------------------------------
Static Function Menudef()

Local aMenu := {}

aAdd(aMenu,{STR0002 , 'VIEWDEF.GPEA644', 0 , 2, 0, .T. } ) // 'Visualizar'

Return aMenu

//-------------------------------------------------------------------
/*/ {Protheus.doc} ModelDef
Definição do modelo de Dados

@author arthur.colado

@since 28/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel 
Local oStr1
Local oStr2 := FWFormStruct(1,'TIT')

If nModulo == 7
	oStr1:= FWFormStruct(1,'SRA',{|cCampo| AllTrim(cCampo)+"|" $ "RA_FILIAL|RA_MAT|RA_NOME|RA_ADMISSA|RA_CODFUNC|RA_TNOTRAB|RA_SEQTURN|"})
Else
	oStr1 := FWFormStruct(1,'AA1')
	oStr1:RemoveField( 'AA1_CNV' )
	oStr1:RemoveField( 'AA1_RSPTRA' )
	oStr1:RemoveField( 'AA1_RSPMNT' )
	oStr1:RemoveField( 'AA1_MPONTO' )
	oStr1:RemoveField( 'AA1_FUNFIL' )
	oStr1:RemoveField( 'AA1_CRMSIM' )
	oStr1:RemoveField( 'AA1_FTVIST' )
	oStr1:RemoveField( 'AA1_ALTVIS' )
	oStr1:RemoveField( 'AA1_CATEGO' )
	oStr1:RemoveField( 'AA1_IMPPRO' )
	oStr1:RemoveField( 'AA1_VISPRO' )
	oStr1:RemoveField( 'AA1_VISVLR' )
	oStr1:RemoveField( 'AA1_VISTOR' )
	oStr1:RemoveField( 'AA1_ACESSO' )
	oStr1:RemoveField( 'AA1_NOMFOR' )
	oStr1:RemoveField( 'AA1_LOJFOR' )
	oStr1:RemoveField( 'AA1_CODFOR' )
	oStr1:RemoveField( 'AA1_ALOCA' )
	oStr1:RemoveField( 'AA1_TIPVEN' )
	oStr1:RemoveField( 'AA1_CONTRB' )
	oStr1:RemoveField( 'AA1_CODUSR' )
	oStr1:RemoveField( 'AA1_TIPO' )
	oStr1:RemoveField( 'AA1_NOMUSU' )
	oStr1:RemoveField( 'AA1_CODVEN' )
	oStr1:RemoveField( 'AA1_DATDEM' )
	oStr1:RemoveField( 'AA1_PERQTD' )
	oStr1:RemoveField( 'AA1_DATADM' )
	oStr1:RemoveField( 'AA1_REQPEC' )
	oStr1:RemoveField( 'AA1_CATUES' )
	oStr1:RemoveField( 'AA1_DATUES' )
	oStr1:RemoveField( 'AA1_CULTES' )
	oStr1:RemoveField( 'AA1_DULTES' )
	oStr1:RemoveField( 'AA1_LOCLZF' )
	oStr1:RemoveField( 'AA1_LOCLZR' )
	oStr1:RemoveField( 'AA1_LIBOSV' )
	oStr1:RemoveField( 'AA1_LOCLZB' )
	oStr1:RemoveField( 'AA1_LOCAL' )
	oStr1:RemoveField( 'AA1_FUNPRO' )
	oStr1:RemoveField( 'AA1_CUSTO' )
	oStr1:RemoveField( 'AA1_EMINFI' )
	oStr1:RemoveField( 'AA1_RATE' )
	oStr1:RemoveField( 'AA1_VALOR' )
	oStr1:RemoveField( 'AA1_FONE' )
	oStr1:RemoveField( 'AA1_EMAIL' )
	oStr1:RemoveField( 'AA1_PAGER' )
	oStr1:RemoveField( 'AA1_CENTRA' )
	oStr1:RemoveField( 'AA1_CC' )
EndIf

oModel := MPFormModel():New('GPEA644')


oModel:addFields('Atendentes',,oStr1)

oModel:addGrid('Disciplina','Atendentes',oStr2)
If nModulo == 7
	oModel:SetRelation('Disciplina', { { 'TIT_FILIAL', 'xFilial("TIT")' }, { 'TIT_MAT', 'RA_MAT' } }, TIT->(IndexKey(1)) )
Else
	oModel:SetRelation('Disciplina', { { 'TIT_FILIAL', 'xFilial("TIT")' }, { 'TIT_CODTEC', 'AA1_CODTEC' } }, TIT->(IndexKey(1)) )
EndIf
oModel:AddCalc( 'Pontos', 'Atendentes', 'Disciplina', 'TIT_PONTOS', 'Pontos', 'SUM', /*bCondition*/, /*bInitValue*/,'Pontos' /*cTitle*/, /*bFormula*/)
oModel:AddCalc( 'Perda PLR', 'Atendentes', 'Disciplina', 'TIT_PLR', 'PLR', 'SUM', /*bCondition*/, /*bInitValue*/,'PLR' /*cTitle*/, /*bFormula*/)

Return oModel
//-------------------------------------------------------------------
/*/ {Protheus.doc} ViewDef
Definição do interface

@author arthur.colado

@since 28/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef() 
Local oStr1 
Local oStr2:= FWFormStruct(2, 'TIT') 
Local oStr3:= FWCalcStruct( oModel:GetModel('Pontos') )
Local oStr5:= FWCalcStruct( oModel:GetModel('Perda PLR') )

oView := FWFormView():New()

If nModulo == 7
	oStr1:= FWFormStruct(2,'SRA',{|cCampo| AllTrim(cCampo)+"|" $ "RA_FILIAL|RA_MAT|RA_NOME|RA_ADMISSA|RA_CODFUNC|RA_TNOTRAB|RA_SEQTURN|"})
	oStr1:SetNoFolder()
Else
	oStr1 := FWFormStruct(2,'AA1')
	oStr1:RemoveField( 'AA1_CNV' )
	oStr1:RemoveField( 'AA1_RSPTRA' )
	oStr1:RemoveField( 'AA1_RSPMNT' )
	oStr1:RemoveField( 'AA1_MPONTO' )
	oStr1:RemoveField( 'AA1_FUNFIL' )
	oStr1:RemoveField( 'AA1_CRMSIM' )
	oStr1:RemoveField( 'AA1_FTVIST' )
	oStr1:RemoveField( 'AA1_ALTVIS' )
	oStr1:RemoveField( 'AA1_CATEGO' )
	oStr1:RemoveField( 'AA1_IMPPRO' )
	oStr1:RemoveField( 'AA1_VISPRO' )
	oStr1:RemoveField( 'AA1_VISVLR' )
	oStr1:RemoveField( 'AA1_VISTOR' )
	oStr1:RemoveField( 'AA1_ACESSO' )
	oStr1:RemoveField( 'AA1_NOMFOR' )
	oStr1:RemoveField( 'AA1_LOJFOR' )
	oStr1:RemoveField( 'AA1_CODFOR' )
	oStr1:RemoveField( 'AA1_ALOCA' )
	oStr1:RemoveField( 'AA1_TIPVEN' )
	oStr1:RemoveField( 'AA1_CONTRB' )
	oStr1:RemoveField( 'AA1_CODUSR' )
	oStr1:RemoveField( 'AA1_TIPO' )
	oStr1:RemoveField( 'AA1_NOMUSU' )
	oStr1:RemoveField( 'AA1_CODVEN' )
	oStr1:RemoveField( 'AA1_DATDEM' )
	oStr1:RemoveField( 'AA1_PERQTD' )
	oStr1:RemoveField( 'AA1_DATADM' )
	oStr1:RemoveField( 'AA1_REQPEC' )
	oStr1:RemoveField( 'AA1_CATUES' )
	oStr1:RemoveField( 'AA1_DATUES' )
	oStr1:RemoveField( 'AA1_CULTES' )
	oStr1:RemoveField( 'AA1_DULTES' )
	oStr1:RemoveField( 'AA1_LOCLZF' )
	oStr1:RemoveField( 'AA1_LOCLZR' )
	oStr1:RemoveField( 'AA1_LIBOSV' )
	oStr1:RemoveField( 'AA1_LOCLZB' )
	oStr1:RemoveField( 'AA1_LOCAL' )
	oStr1:RemoveField( 'AA1_FUNPRO' )
	oStr1:RemoveField( 'AA1_CUSTO' )
	oStr1:RemoveField( 'AA1_EMINFI' )
	oStr1:RemoveField( 'AA1_RATE' )
	oStr1:RemoveField( 'AA1_VALOR' )
	oStr1:RemoveField( 'AA1_FONE' )
	oStr1:RemoveField( 'AA1_EMAIL' )
	oStr1:RemoveField( 'AA1_PAGER' )
	oStr1:RemoveField( 'AA1_CENTRA' )
	oStr1:RemoveField( 'AA1_CC' )
EndIf

oView:SetModel(oModel)
oView:DisableGoBackFolders(.F.)

oView:AddField('FORM1' , oStr1,'Atendentes' )
oView:AddGrid('FORM3' , oStr2,'Disciplina')
If nModulo <> 7
	oView:AddField('FORM7', oStr5,'Perda PLR')
EndIf
oView:AddField('FORM5', oStr3,'Pontos')  


oView:CreateHorizontalBox( 'BOXFORM1', 30)

oStr2:RemoveField( 'TIT_APLICA' )
oStr2:RemoveField( 'TIT_RESPON' )
oStr2:RemoveField( 'TIT_CODRES' )
oStr2:RemoveField( 'TIT_NOMTEC' )
oStr2:RemoveField( 'TIT_CODTEC' )
oStr2:RemoveField( 'TIT_DESCR' )
oStr2:RemoveField( 'TIT_USUARI' )
oStr2:RemoveField( 'TIT_TURNO' )
oStr2:RemoveField( 'TIT_MAT' )
oStr2:RemoveField( 'TIT_MATRES' )
If nModulo == 7
	oStr2:RemoveField( 'TIT_CODABS' )
	oStr2:RemoveField( 'TIT_NOMRES' )
	oStr2:RemoveField( 'TIT_LOCAL'  )
	oStr2:RemoveField( 'TIT_REGIAO' )
	oStr2:RemoveField( 'TIT_PLR' )
EndIf

oView:CreateHorizontalBox( 'BOXFORM3', 44)
oView:CreateHorizontalBox( 'BOXFORM5', 13)
If nModulo <> 7
	oView:CreateHorizontalBox( 'BOXFORM7', 13)
	oView:SetOwnerView('FORM7','BOXFORM7')
endIf
oView:SetOwnerView('FORM5','BOXFORM5')
oView:SetOwnerView('FORM3','BOXFORM3')
oView:SetOwnerView('FORM1','BOXFORM1')

Return oView
