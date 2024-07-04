#Include 'Protheus.ch'
#Include 'APCFG230RUS.ch'
#Include 'APCFG200XRUS.ch'
#INCLUDE "FWBROWSE.CH"

#Define C_ALIAS_RUS 'BRANCH_RUS'
#Define C_TABLE_RUS 'SYS_BRANCH_L_RUS'

//-------------------------------------------------------------------
/*/{Protheus.doc} APCFG230RUS
Fonte de cadastro de filial localizado para a Rússia

@author Alvaro Camillo Neto
@since 11/04/2017
@version P12
/*/
//------------------------------------------------------------------
Function APCFG230RUS()
Local oBrowse := Nil

oBrowse := BrowseDef()

oBrowse:Activate()
oBrowse:getSeek():ChangeOrder(XX8->(IndexOrd()))
Eval(oBrowse:getSeek():bChange)

oBrowse:GetOwner():Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Definição do Browse localizado

@author Daniel Mendes
@since 11/04/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse := Nil
Local oColumn := Nil
Local aCoors  := FWGetDialogSize(oMainWnd)
	
If nModulo <> 99	
	Ap200SXB()
	Ap210SXB()
	Ap220SXB()
	//-------------------------------------------------------------------
	// Define a janela do Browse
	//-------------------------------------------------------------------
	DEFINE MSDIALOG oDlg FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL
		//-------------------------------------------------------------------
		// Define o Browse
		//-------------------------------------------------------------------
		DEFINE FWFORMBROWSE oBrowse DATA TABLE ALIAS "XX8" FILTER FILTERDEFAULT "XX8_TIPO == '3'"  DOUBLECLICK { || FWExecView('View','APCFG230', , , { || .T. }) } OF oDlg 
	
			//-------------------------------------------------------------------
			// Adiciona os botões do Browse
			//-------------------------------------------------------------------
			ADD BUTTON oButton TITLE STR0026 ACTION 'VIEWDEF.APCFG230' OPERATION 1 OF oBrowse // "Visualizar"
			ADD BUTTON oButton TITLE STR0027 ACTION 'VIEWDEF.APCFG230' OPERATION 4 OF oBrowse // "Alterar"
			ADD BUTTON oButton TITLE STR0028 ACTION "CRMA680RUS('SM0',xFilial('SM0')+XX8->XX8_GRPEMP + XX8->XX8_EMPR + XX8->XX8_UNID + XX8->XX8_CODIGO,.F.,"+"('"+STR0028 +"' + ' ' + XX8->XX8_DESCRI))" OPERATION 4 OF oBrowse // "Added button Address"
			
			//-------------------------------------------------------------------
			// Criação das colunas do Browse
			//-------------------------------------------------------------------
			ADD COLUMN oColumn DATA { || XX8->XX8_GRPEMP } TITLE STR0015 SIZE 4 OF oBrowse // "Grupo"
			//ADD COLUMN oColumn DATA { || FwSkCadFil(XX8->XX8_GRPEMP+"0","XX8_DESCRI",,{{'XX8_GRPEMP',XX8->XX8_GRPEMP}},'0') } TITLE STR0016 SIZE 10 OF oBrowse // "Desc. Grupo"
			ADD COLUMN oColumn DATA { || XX8->XX8_EMPR } TITLE STR0004 SIZE 4 OF oBrowse // "Empresa" 
			//ADD COLUMN oColumn DATA { || FwSkCadFil(XX8->(XX8_GRPEMP+XX8_EMPR)+"1","XX8_DESCRI",2,{{'XX8_GRPEMP',XX8->XX8_GRPEMP},{'XX8_EMPR',XX8->XX8_EMPR}},'1') }  TITLE STR0019 SIZE 15 OF oBrowse 
			ADD COLUMN oColumn DATA { || XX8->XX8_UNID } TITLE STR0021 SIZE 4 OF oBrowse // "Unid.Negócio"
			ADD COLUMN oColumn DATA { || FwSkCadFil(XX8->(XX8_GRPEMP+XX8_EMPR+XX8_UNID)+"2","XX8_DESCRI",3,{{'XX8_GRPEMP',XX8->XX8_GRPEMP},{'XX8_EMPR',XX8->XX8_EMPR},{'XX8_UNID',XX8->XX8_UNID}},'2') } TITLE STR0022 SIZE 20 OF oBrowse // "Desc.Unid.Neg."
	
			ADD COLUMN oColumn DATA { || XX8->XX8_CODIGO } TITLE STR0024 SIZE 4 OF oBrowse // "Código"
			ADD COLUMN oColumn DATA { || XX8->XX8_DESCRI } TITLE STR0025 SIZE 30 OF oBrowse // "Descrição"
	
			//-------------------------------------------------------------------
			// Permite o uso de filtro no Browse CODEBASE/CTREE
			//-------------------------------------------------------------------
			oBrowse:SetDBFFilter( .T. )
			oBrowse:SetCacheView( .F. )
Else
	oBrowse := FWLoadBrw( 'APCFG230' )
EndIf
SetKey(K_CTRL_A,{|| CRMA680RUS('SM0',xFilial('SM0')+XX8->XX8_GRPEMP + XX8->XX8_EMPR + XX8->XX8_UNID + XX8->XX8_CODIGO,.F.,STR0028 + ' ' + XX8->XX8_DESCRI)})

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de dados localizado

@author Daniel Mendes
@since 11/04/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel := FWLoadModel( 'APCFG230' )
Local oStrct := Nil
Local aRelation := {}

//Abre a tabela
OpenTableRUS()

//Struct
oStrct := FWFormModelStruct():New()

//Table
oStrct:AddTable( C_ALIAS_RUS , { "BR_COMPGRP", "BR_COMPEMP", "BR_COMPUNI", "BR_BRANCH" } , STR0001, { || MPSysTblPrefix() + C_TABLE_RUS } ) //'Filial' 

//Indexes
oStrct:AddIndex( 1 , '01' , 'BR_COMPGRP+BR_COMPEMP+BR_COMPUNI+BR_BRANCH' , STR0002 , '' , '' , .T. ) //'Empresa+Filial'
oStrct:AddIndex( 2 , '02' , 'BR_KPP'     , STR0003 , '' , '' , .T. ) //'KPP'

oStrct:AddField(STR0932,STR0932,'BR_COMPGRP','C',012,0,,,,,,)
oStrct:AddField(STR0933,STR0933,'BR_COMPEMP','C',012,0,,,,,,)
oStrct:AddField(STR0934,STR0934,'BR_COMPUNI','C',012,0,,,,,,)
oStrct:AddField(STR0935,STR0935,'BR_BRANCH','C',012,0,,,,,,)
oStrct:AddField(STR0936,STR0936,'BR_TIPO','C',001,0,,,,,,)
oStrct:AddField(STR0936,STR0936,'BR_TYPE','C',001,0,,,,,,)
oStrct:AddField(STR0939,STR0939,'BR_FULLNAM','C',250,0,,,,,,)
oStrct:AddField(STR0940,STR0940,'BR_SHORTNM','C',250,0,,,,,,)
oStrct:AddField(STR0941,STR0941,'BR_PHONENU','C',50,0,,,,,,)
oStrct:AddField(STR0942,STR0942,'BR_FAX','C',50,0,,,,,,)
oStrct:AddField(STR0943,STR0943,'BR_EMAIL','C',50,0,,,,,,)
oStrct:AddField(STR0973,STR0944,'BR_OKPO','C',010,0,{|oModel| VD_OKPO(oModel)},,,,,)
oStrct:AddField(STR0975,STR0945,'BR_KPP','C',009,0,,,,,,)
oStrct:AddField(STR0980,STR0946,'BR_SUBDIVI','C',001,0,,,,,,)
oStrct:AddField(STR0949,STR0950,'BR_DIGIVAT','C',005,0,,{|oModel| VD_SD(oModel)},,,,)
oStrct:AddField(STR0951,STR0951,'BR_LOCLTAX','C',004,0,,,,,,)
oStrct:AddField(STR0952,STR0952,'BR_LTAXNAM','C',254,0,,,,,,)
oStrct:AddField(STR0953,STR0954,'BR_PFRREG','C',014,0,,,,,,)
oStrct:AddField(STR0955,STR0956,'BR_FOMS','C',015,0,,,,,,)
oStrct:AddField(STR0957,STR0958,'BR_FSS','C',010,0,,,,,,)
oStrct:AddField(STR0959,STR0960,'BR_SUBORD','C',005,0,,,,,,)
oStrct:AddField(STR0979,STR0961,'BR_STATIST','C',005,0,,,,,,)
oStrct:AddField(STR0962,STR0963,'BR_OKTMO','C',011,0,,,,,,)
oStrct:AddField(STR0977,STR0927,'BR_OKATO','C',011,0,,,,,,)
oStrct:AddField(STR0964,STR0965,'BR_OKOGU','C',007,0,,,,,,)
oStrct:AddField(STR0966,STR0967,'BR_OKOPF','C',005,0,,,,,,)
oStrct:AddField(STR0968,STR0969,'BR_OKFS','C',002,0,,,,,,)
oStrct:AddField(STR0970,STR0971,'BR_OKVED','C',8,0,,,,,,)



//Add
oModel:AddFields( 'SIGAMAT_BRAN_RUS' , 'SIGAMAT_XX8' , oStrct , /*Pre-Validacao*/ , /*Pos-Validacao*/ , /*Carga*/ )

aAdd(aRelation,{ 'BR_COMPGRP' , 'XX8->XX8_GRPEMP' })
aAdd(aRelation,{ 'BR_COMPEMP' , 'XX8->XX8_EMPR'   })
aAdd(aRelation,{ 'BR_COMPUNI' , 'XX8->XX8_UNID'   })
aAdd(aRelation,{ 'BR_BRANCH'  , 'XX8->XX8_CODIGO' })

//Relation
oModel:SetRelation( 'SIGAMAT_BRAN_RUS' , aRelation , 'BR_COMPGRP+BR_COMPEMP+BR_COMPUNI+BR_BRANCH' )

//SetKey(K_CTRL_A,{|| CRMA680RUS("SM0",xFilial("SM0") + XX8->XX8_GRPEMP + XX8->XX8_EMPR + XX8->XX8_UNID + XX8->XX8_CODIGO)})

Return oModel



//-------------------------------------------------------------------
/*/{Protheus.doc} VD_SD
Wrapper to validate Subdivision on WHEN proporty of BR_DIGIVAT

@author Salov Alexander
@since 02/10/2017
@version P12
/*/
static function VD_SD (oModel)
local lRet as logical

lRet := .f.

if (oModel:GetValue("BR_SUBDIVI") = '1')
	lRet := .t.
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VD_OKPO
Wrapper to validate OKPO

@author Salov Alexander
@since 02/10/2017
@version P12
/*/
static function VD_OKPO (oModel)
local lRet as logical

lRet := RU99X01OKPO (oModel:GetValue("BR_OKPO"),oModel:GetValue("BR_TYPE"))

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Visualização da regra de negócios do arquivo de empresas

@return  oView Retorna o objeto FWFormView
@author  Alvaro Camillo Neto
@since   29/03/2017
@version 12.1.16
@protected
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruct
Local oView
Local oModel := FWLoadModel('APCFG230')
Local oStrc := Nil
Local aComboArr := Nil

//Struct
oView := FWFormView():New()
oStruct := FWFormViewStruct():New()
oStrc := FWFormViewStruct():New()

oStruct:AddField("XX8_GRPEMP","01",STR0015,STR0015,,ValType(XX8->XX8_GRPEMP),,,"XX80") // "Grupo"
oStruct:AddField("XX8_DESGRP","02",STR0016,STR0017,,"C",,,,.F.) // "Desc. Grupo" ### "Descrição do Grupo"

oStruct:AddField("XX8_EMPR"  ,"03",STR0018,STR0018,,ValType(XX8->XX8_EMPR),,,"XX81") // "Empresa" 
oStruct:AddField("XX8_DESEMP","04",STR0019,STR0020,,"C",,,,.F.) // "Desc. Empresa" ### "Descrição da Empresa" 

oStruct:AddField("XX8_UNID"  ,"05",STR0021,STR0021,,ValType(XX8->XX8_UNID),,,"XX82") // "Unid.Negócio"
oStruct:AddField("XX8_DESUN" ,"06",STR0022,STR0023,,"C",,,,.F.) // "Desc.Unid.Neg." ### "Descrição da Unidade de Negócio"

oStruct:AddField("XX8_CODIGO","07",STR0024,STR0024,,ValType(XX8->XX8_CODIGO),"@!") // "Código"
oStruct:AddField("XX8_DESCRI","08",STR0025,STR0025,,ValType(XX8->XX8_CODIGO)) // "Descrição"

oView:SetModel(oModel)
oView:AddField("SIGAMAT_XX8",oStruct)

//Fields

aComboArr = {"1=" + STR0906,"2=" + STR0907}
oStrc:AddField('BR_BRANCH',		'01', STR0935,STR0935,	{STR0935},'C')
oStrc:AddField('BR_TYPE',		'02', STR0936,STR0936,	{STR0936},'C',,,,,,,aComboArr)
oStrc:AddField('BR_FULLNAM',	'03', STR0939,STR0939,	{STR0939},'C')
oStrc:AddField('BR_SHORTNM',	'04', STR0940,STR0940,	{STR0940},'C')
oStrc:AddField('BR_PHONENU',	'05', STR0941,STR0941,	{STR0941},'C')
oStrc:AddField('BR_FAX',		'06', STR0942,STR0942,	{STR0942},'C')
oStrc:AddField('BR_EMAIL',		'07', STR0943,STR0943,	{STR0943},'C')
oStrc:AddField('BR_OKPO',		'08', STR0973,STR0973,	{STR0944},'C')
oStrc:AddField('BR_KPP',		'09', STR0975,STR0975,	{STR0945},'C')

aComboArr = {"1=" + STR0947,"2=" + STR0948}
oStrc:AddField('BR_SUBDIVI',	'10', STR0980,STR0980,	{STR0946},'C',,,,,,,aComboArr)
oStrc:AddField('BR_DIGIVAT',	'11', STR0949,STR0949,	{STR0950},'C')
oStrc:AddField('BR_LOCLTAX',	'12', STR0951,STR0951,	{STR0951},'C')
oStrc:AddField('BR_LTAXNAM',	'13', STR0952,STR0952,	{STR0952},'C')
oStrc:AddField('BR_PFRREG',	'14', STR0953,STR0953,	{STR0954},'C','999-999-999999')
oStrc:AddField('BR_FOMS',		'15', STR0955,STR0955,	{STR0956},'C')
oStrc:AddField('BR_FSS',		'16', STR0957,STR0957,	{STR0958},'C')
oStrc:AddField('BR_SUBORD',	'17', STR0959,STR0959,	{STR0960},'C')
oStrc:AddField('BR_STATIST',	'18', STR0979,STR0979,	{STR0961},'C','99-99')
oStrc:AddField('BR_OKTMO',		'19', STR0962,STR0962,	{STR0963},'C')
oStrc:AddField('BR_OKATO',		'20', STR0977,STR0977,	{STR0927},'C')
oStrc:AddField('BR_OKOGU',		'21', STR0964,STR0964,	{STR0965},'C')
oStrc:AddField('BR_OKOPF',		'22', STR0966,STR0966,	{STR0967},'C')
oStrc:AddField('BR_OKFS',		'23', STR0968,STR0968,	{STR0969},'C')
oStrc:AddField('BR_OKVED',		'24', STR0970,STR0970,	{STR0971},'C')

oView:SetContinuousForm( .T. )

oView:AddField( 'FORM_RUS' , oStrc , 'SIGAMAT_BRAN_RUS' )
oView:CreateHorizontalBox( 'BOXFORM_RUS', 00 )
oView:SetOwnerView( 'FORM_RUS' , 'BOXFORM_RUS' )
oView:AddUserButton(STR0028,'AddrButton', {|| CRMA680RUS('SM0',xFilial('SM0')+XX8->XX8_GRPEMP + XX8->XX8_EMPR + XX8->XX8_UNID + XX8->XX8_CODIGO,.F.,STR0028+ " " + XX8->XX8_DESCRI)}, /*[cToolTip]*/, K_CTRL_A) // Other Actions - address button in viewdef

//-------------------------------------------------------------------
// Indica o model ativo para o view
//-------------------------------------------------------------------
FWModelActive(oModel)


Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} OpenTableRUS
Abre a tabela de cadastro de empresas da Rússia

@author Daniel Mendes
@since 12/04/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function OpenTableRUS()
Local cAlias := ''
Local oStrct := Nil
Local oTable := Nil

If Select( C_ALIAS_RUS ) == 0 .And. TcCanOpen( MPSysTblPrefix() + C_TABLE_RUS )
	cAlias := Alias()
	oStrct := MPStruBRUS( C_ALIAS_RUS )
	oTable := FWTableDDL():New()

	oTable:SetTableStruct( oStrct )
	oTable:Activate()
	oTable:OpenTable()
	//dbUseArea( .T. , 'TOPCONN' , MPSysTblPrefix() + C_TABLE_RUS , C_ALIAS_RUS , .T. , .F. )

	If cAlias != ''
		dbSelectArea( cAlias )
	EndIf

	oStrct:DeActivate()
	oTable:DeActivate()
	oStrct := Nil
	oTable := Nil
EndIf

Return Nil
// Russia_R5
// updated 03-09-2018 for automatically patch
