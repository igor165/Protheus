#Include 'Protheus.ch'
#Include 'ApCfg210RUS.ch'
#Include 'APCFG200XRUS.ch'
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

#Define C_ALIAS_RUS 'COMP_RUS'
#Define C_TABLE_RUS 'SYS_COMPANY_L_RUS'

//-------------------------------------------------------------------
/*/{Protheus.doc} ApCfg210RUS
Fonte de cadastro de empresas localizado para a Rússia

@author Daniel Mendes
@since 11/04/2017
@version P12
/*/
//-------------------------------------------------------------------
Function ApCfg210RUS()
Local oBrowse := Nil
Local nIdxOrd := 0

oBrowse := BrowseDef()
nIdxOrd := XX8->( IndexOrd() )

oBrowse:Activate()
oBrowse:getSeek():ChangeOrder( XX8->( IndexOrd() ) )
Eval( oBrowse:getSeek():bChange )
XX8->( dbSetOrder( nIdxOrd ) )
oBrowse:GetOwner():Activate()

oBrowse := Nil

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
	XX8->(DbSetOrder(2))
	Ap200SXB()

	//------------------------------------------------------------------
	// Define a janela do Browse
	//-------------------------------------------------------------------
	DEFINE MSDIALOG oDlg FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL
	//-------------------------------------------------------------------
	// Define o Browse
	//-------------------------------------------------------------------
	DEFINE FWFORMBROWSE oBrowse DATA TABLE ALIAS "XX8" FILTER FILTERDEFAULT "XX8_TIPO == '1'"  DOUBLECLICK { || FWExecView('View','APCFG210',MODEL_OPERATION_VIEW , , { || .T. }) } OF oDlg

		//-------------------------------------------------------------------
		// Adiciona os botões do Browse
		//-------------------------------------------------------------------
		ADD BUTTON oButton TITLE STR0041 ACTION 'VIEWDEF.APCFG210' OPERATION 1 OF oBrowse // "Visualizar"
		ADD BUTTON oButton TITLE STR0042 ACTION 'VIEWDEF.APCFG210' OPERATION 4 OF oBrowse // "Alterar"
		ADD BUTTON oButton TITLE STR0046 ACTION "CRMA680RUS('SM0',xFilial('SM0')+ XX8->XX8_GRPEMP + XX8->XX8_CODIGO + XX8->XX8_TIPO,.F.,"+"('"+STR0046 +"' + ' ' + XX8->XX8_DESCRI))" OPERATION 4 OF oBrowse // "Added button Address"		
		//-------------------------------------------------------------------
		// Criação das colunas do Browse
		//-------------------------------------------------------------------
		ADD COLUMN oColumn DATA { || XX8->XX8_GRPEMP } TITLE STR0045 SIZE 12 OF oBrowse // "Grupo"
		ADD COLUMN oColumn DATA { || FwSkCadFil(XX8->XX8_GRPEMP+"0","XX8_DESCRI",,{{'XX8_GRPEMP',XX8->XX8_GRPEMP}},'0') } TITLE STR0044 SIZE 40 OF oBrowse // "Desc. Grupo"

		ADD COLUMN oColumn DATA { || XX8->XX8_CODIGO } TITLE STR0043 SIZE 12 OF oBrowse // "Código"
		ADD COLUMN oColumn DATA { || XX8->XX8_DESCRI } TITLE STR0044 SIZE 40 OF oBrowse // "Descrição"

		//-------------------------------------------------------------------
		// Permite o uso de filtro no Browse CODEBASE/CTREE
		//-------------------------------------------------------------------
		oBrowse:SetDBFFilter( .T. )
		oBrowse:SetCacheView( .F. )
else
	oBrowse := FWLoadBrw( 'APCFG210' )
EndIf
SetKey(K_CTRL_A,{|| CRMA680RUS('SM0',xFilial('SM0')+ XX8->XX8_GRPEMP + XX8->XX8_CODIGO + XX8->XX8_TIPO,.F.,STR0046 + ' ' + XX8->XX8_DESCRI)})
Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição das opções de menu localizadas

@author Daniel Mendes
@since 11/04/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := Nil

aRotina := FWLoadMenuDef( 'APCFG210' )

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de dados localizado

@author Daniel Mendes
@since 11/04/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel := Nil
Local oStrct := Nil

//Abre a tabela
OpenTableRUS()

//Modelo
oModel := FWLoadModel( 'APCFG210')

//Struct
oStrct := FWFormModelStruct():New()

//Table
oStrct:AddTable( C_ALIAS_RUS , { 'CO_COMPGRP' , 'CO_COMPEMP' , 'CO_TIPO' } , 'Teste' , { || MPSysTblPrefix() + C_TABLE_RUS } )

//Indexes
oStrct:AddIndex( 1 , '01' , 'CO_COMPGRP+CO_TIPO'                       , STR0001 , '' , '' , .T. ) //''
oStrct:AddIndex( 1 , '02' , 'CO_COMPGRP+CO_COMPEMP+CO_TIPO'            , STR0001 , '' , '' , .T. ) //''
oStrct:AddIndex( 1 , '03' , 'CO_COMPGRP+CO_COMPEMP+CO_COMPUNI+CO_TIPO' , STR0001 , '' , '' , .T. ) //''
oStrct:AddIndex( 2 , '04' , 'CO_INN'                                   , STR0002 , '' , '' , .T. ) //'INN'
oStrct:AddIndex( 3 , '05' , 'CO_KPP'                                   , STR0003 , '' , '' , .T. ) //'KPP'

//Fields


oStrct:AddField(STR0902,STR0902,'CO_COMPGRP','C',012,0,,,,,,)
oStrct:AddField(STR0903,STR0903,'CO_COMPEMP','C',012,0,,,,,,)
oStrct:AddField(STR0904,STR0904,'CO_COMPUNI','C',012,0,,,,,,)
oStrct:AddField(STR0905,STR0905,'CO_TIPO','C',001,0,,,,,,)
oStrct:AddField(STR0905,STR0905,'CO_TYPE','C',001,0,,,,,,)
oStrct:AddField(STR0908,STR0908,'CO_FULLNAM','C',250,0,,,,,,)
oStrct:AddField(STR0909,STR0909,'CO_SHORTNM','C',250,0,,,,,,)
oStrct:AddField(STR0910,STR0910,'CO_PHONENU','C',50,0,,,,,,)
oStrct:AddField(STR0911,STR0911,'CO_FAX','C',50,0,,,,,,)
oStrct:AddField(STR0912,STR0913,'CO_EMAIL','C',50,0,,,,,,)
oStrct:AddField(STR0914,STR0915,'CO_OGRN','C',015,0,{|oModel| VD_OGRN(oModel)},,,,,)
oStrct:AddField(STR0916,STR0916,'CO_REGDATE','D',8,0,,,,,,)
oStrct:AddField(STR0973,STR0917,'CO_OKPO','C',010,0,{|oModel| VD_OKPO(oModel)},,,,,)
oStrct:AddField(STR0974,STR0918,'CO_INN','C',012,0,{|oModel| VD_INN(oModel)},,,,,)
oStrct:AddField(STR0975,STR0919,'CO_KPP','C',009,0,,,,,,)
oStrct:AddField(STR0920,STR0920,'CO_LOCLTAX','C',004,0,,,,,,)
oStrct:AddField(STR0921,STR0921,'CO_LTAXNAM','C',254,0,,,,,,)
oStrct:AddField(STR0976,STR0922,'CO_PFRREG','C',014,0,,,,,,)
oStrct:AddField(STR0955,STR0923,'CO_FOMS','C',015,0,,,,,,)
oStrct:AddField(STR0957,STR0958,'CO_FSS','C',010,0,,,,,,)
oStrct:AddField(STR0978,STR0924,'CO_SUBORD','C',005,0,,,,,,)
oStrct:AddField(STR0979,STR0925,'CO_STATIST','C',005,0,,,,,,)
oStrct:AddField(STR0962,STR0926,'CO_OKTMO','C',011,0,,,,,,)
oStrct:AddField(STR0977,STR0927,'CO_OKATO','C',011,0,,,,,,)
oStrct:AddField(STR0964,STR0928,'CO_OKOGU','C',007,0,,,,,,)
oStrct:AddField(STR0966,STR0929,'CO_OKOPF','C',005,0,,,,,,)
oStrct:AddField(STR0968,STR0930,'CO_OKFS','C',002,0,,,,,,)
oStrct:AddField(STR0970,STR0931,'CO_OKVED','C',8,0,,,,,,)


//Add
oModel:AddFields( 'SIGAMAT_COMP_RUS' , 'SIGAMAT_XX8' , oStrct , /*Pre-Validacao*/ , /*Pos-Validacao*/ , /*Carga*/ )

//Relation
oModel:SetRelation( 'SIGAMAT_COMP_RUS' , { { 'CO_COMPGRP' , 'XX8->XX8_GRPEMP' } , { 'CO_COMPEMP' , 'XX8->XX8_CODIGO' } , { 'CO_TIPO' , 'XX8->XX8_TIPO' } } , 'CO_COMPGRP+CO_COMPEMP+CO_TIPO' )

//SetKey(K_CTRL_A,{|| CRMA680RUS("SM0",xFilial("SM0") + XX8->XX8_GRPEMP + XX8->XX8_CODIGO + XX8->XX8_TIPO)})

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} VD_OGRN
Wrapper to validate OGRN

@author Salov Alexander
@since 02/10/2017
@version P12
/*/
static function VD_OGRN (oModel)
local lRet as logical

lRet := RU99X01OGRN (oModel:GetValue("CO_OGRN"),oModel:GetValue("CO_TYPE"))

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

lRet := RU99X01OKPO (oModel:GetValue("CO_OKPO"),oModel:GetValue("CO_TYPE"))

return lRet
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} VD_INN
Wrapper to validate INN

@author Salov Alexander
@since 02/10/2017
@version P12
/*/
static function VD_INN (oModel)
local lRet as logical

lRet := RU99X01INN (oModel:GetValue("CO_INN"),oModel:GetValue("CO_TYPE"))

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface localizada

@author Daniel Mendes
@since 11/04/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView := Nil
Local oStrc := Nil
Local aComboArr as array

//View
oView := FWLoadView( 'APCFG210' )

//Struct
oStrc := FWFormViewStruct():New()

//Fields


aComboArr = {"1=" + STR0906,"2=" + STR0907}
oStrc:AddField( 'CO_TYPE'     , '04' , STR0905 , STR0905 , { STR0905 } , 'C',,,,,,,aComboArr ) 
oStrc:AddField( 'CO_FULLNAM'     , '05' , STR0908 , STR0908 , { STR0908 } , 'C' ) 
oStrc:AddField( 'CO_SHORTNM'     , '06' , STR0909 , STR0909 , { STR0909 } , 'C' ) 
oStrc:AddField( 'CO_PHONENU'     , '07' , STR0910 , STR0910 , { STR0910 } , 'C' ) 
oStrc:AddField( 'CO_FAX'     , '08' , STR0911 , STR0911 , { STR0911 } , 'C' ) 
oStrc:AddField( 'CO_EMAIL'     , '09' , STR0912 , STR0912 , { STR0913 } , 'C' )
oStrc:AddField( 'CO_OGRN'     , '10' , STR0914 , STR0914 , { STR0915 } , 'C' )
oStrc:AddField( 'CO_REGDATE'     , '11' , STR0916 , STR0916 , { STR0916 } , 'D' )
oStrc:AddField( 'CO_OKPO'     , '12' , STR0973 , STR0973 , { STR0917 } , 'C' )
oStrc:AddField( 'CO_INN'     , '13' , STR0974 , STR0974 , { STR0918 } , 'C' ) 
oStrc:AddField( 'CO_KPP'     , '14' , STR0975 , STR0975 , { STR0919 } , 'C' ) 
oStrc:AddField( 'CO_LOCLTAX'     , '15' , STR0920 , STR0920 , { STR0920 } , 'C' ) 
oStrc:AddField( 'CO_LTAXNAM'     , '16' , STR0921 , STR0921 , { STR0921 } , 'C' ) 
oStrc:AddField( 'CO_PFRREG'     , '17' , STR0976 , STR0976 , { STR0922 } , 'C','999-999-999999') 
oStrc:AddField( 'CO_FOMS'     , '18' , STR0955 , STR0955 , { STR0923 } , 'C' ) 
oStrc:AddField( 'CO_FSS'     , '19' , STR0957 , STR0957 , { STR0958 } , 'C' ) 
oStrc:AddField( 'CO_SUBORD'     , '20' , STR0978 , STR0978 , { STR0924 } , 'C' ) 
oStrc:AddField( 'CO_STATIST'     , '21' , STR0979 , STR0979 , { STR0925 } , 'C','99-99' ) 
oStrc:AddField( 'CO_OKTMO'     , '22' , STR0962 , STR0962 , { STR0926 } , 'C' ) 
oStrc:AddField( 'CO_OKATO'     , '23' , STR0977 , STR0977 , { STR0927 } , 'C' ) 
oStrc:AddField( 'CO_OKOGU'     , '24' , STR0964 , STR0964 , { STR0928 } , 'C' ) 
oStrc:AddField( 'CO_OKOPF'     , '25' , STR0966 , STR0966 , { STR0929 } , 'C' ) 
oStrc:AddField( 'CO_OKFS'     , '27' , STR0968 , STR0968 , { STR0930 } , 'C' ) 
oStrc:AddField( 'CO_OKVED'     , '28' , STR0970 , STR0970 , { STR0931 } , 'C' ) 


oView:SetContinuousForm( .T. )

oView:AddField( 'FORM_RUS' , oStrc , 'SIGAMAT_COMP_RUS' )
oView:CreateHorizontalBox( 'BOXFORM_RUS', 00 )
oView:SetOwnerView( 'FORM_RUS' , 'BOXFORM_RUS' )
oView:AddUserButton(STR0046,'AddrButton', {|| CRMA680RUS('SM0',xFilial('SM0')+ XX8->XX8_GRPEMP + XX8->XX8_CODIGO + XX8->XX8_TIPO,.F.,STR0046+ " " + XX8->XX8_DESCRI)}, /*[cToolTip]*/, K_CTRL_A) // Other Actions - address button in viewdef

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} OpenTableRUS
Abre a tabela de cadastro de grupos/empresas/unidades da Rússia

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
	oStrct := MPStruCRUS( C_ALIAS_RUS )
	oTable := FWTableDDL():New()

	oTable:SetTableStruct( oStrct )
	oTable:Activate()
	oTable:OpenTable()

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
