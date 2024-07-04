#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'CRMA680.CH'            
STATIC __cAliasAd
STATIC __cKeyAd
STATIC __lView

/*/{Protheus.doc} CRMA680RUS
Russian Addresses
@author Andrews.Egas
@since 24/04/2017
@version 1.0
/*/
Function CRMA680RUS(cAliasP,cKeyP,lView,cParentDescr)
Local oBrowse as object
Private lAtuali := .F.
Default lView := .F.

__cAliasAd := cAliasP
__cKeyAd 	:= cKeyP
__lView		:= lView

oBrowse := BrowseDef()

//oBrowse:AddLegend( "ZA0_TIPO=='1'", "YELLOW", "Autor"      )
//oBrowse:AddLegend( "ZA0_TIPO=='2'", "BLUE"  , "Interprete" )
If cAliasP <> NIL 
	oBrowse:AddFilter("Default","AGA_ENTIDA=='" + cAliasP + "' .And. AllTrim(AGA_CODENT)=='" +  AllTrim(cKeyP) + "'" ,,.T.)
EndIf

if (!empty(alltrim(cParentDescr)))
	oBrowse:SetDescription(cParentDescr)
endif
oBrowse:Activate()

/*If cAliasP <> NIL .And. !lView
	If !Empty(CRGetAddr(cAliasP,cKeyP))
		If cAliasP == "SA1"
			M->A1_END := CRGetAddr(cAliasP,cKeyP)
		ElseIf cAliasP == "SA2"
			M->A2_END := CRGetAddr(cAliasP,cKeyP)
		EndIf
	EndIf	
EndIf*/

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Andrews Egas
@since 24/04/2017
@version MA3 - Russia
/*/
//--------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse as object

oBrowse := FWMBrowse():New()
oBrowse := FWLoadBrw("CRMA680")
oBrowse:SetAlias('AGA')
oBrowse:SetDescription(STR0001)
oBrowse:SetMenuDef('CRMA680')
oBrowse:SetIgnoreARotina(.T.)
oBrowse:SetFilterDefault( "AGA_ENTIDA<>'RD0'" )
oBrowse:SetAttach( .T. )

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu definition

@author Andrews Egas
@since 21/03/2016
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina

If !__lView
	aRotina  :=  FWLoadMenuDef("CRMA680")
Else
	aRotina := {}
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.CRMA680' OPERATION 2 ACCESS 0 //View
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model
@author 	Andrews Egas
@since 24/04/2017
@version 	1.0
@project	MA3
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel as object
Local oCR680RUS   := CR680RUS():New()

oModel 	:= FwLoadModel('CRMA680')
oModel:InstallEvent("CR680RUS",,oCR680RUS)
oModel:SetVldActivate({|oModel| CR360ActVld(oModel)})
oModel:SetPre({|oModel| CR360Pre(oModel)})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface
@author 	Andrews Egas
@since 24/04/2017
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	as object
Local oView		as object

oView	:= FWLoadView("CRMA680")

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} CR680IniA
Initial value
@author 	Andrews Egas
@since 24/04/2017
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------
Function CR680IniA(nField)
Local cRet as char
cRet := ""
If __cAliasAd <> NIL
	If nField == 1
		cRet := __cAliasAd	
	ElseIf nField == 2
		cRet := __cKeyAd
	Else
		cRet := Posicione( __cAliasAd, 1, __cKeyAd, (__cAliasAd)->(IIF(SUBSTR(__cAliasAd,1,1)=="S",SUBSTR(__cAliasAd,2,2),__cAliasAd)+'_NOME'))
	EndIf
	
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CR360ActVld
Validation to open register without permission (update and delete)
@author 	Andrews Egas
@since 24/04/2017
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------
Function CR360ActVld(oModel)
Local lRet as Logical
Local lAlter		:= oModel:GetOperation() == MODEL_OPERATION_UPDATE 
Local lDeleta		:= oModel:GetOperation() == MODEL_OPERATION_DELETE
Local lView		:= oModel:GetOperation() == MODEL_OPERATION_VIEW
Local cField 
lRet := .T.
lAtuali := .T.
If !Empty(__cAliasAd) .And. (lAlter .Or. lDeleta)
	lRet := .F.
	If __cAliasAd == AGA->AGA_ENTIDA .AND. AllTrim(__cKeyAd) == AllTrim(AGA->AGA_CODENT)
		Help(" ",1,"CR360NOUPD")
		lRet := .T.
	EndIf
EndIf

/*If lView
	cField := AGA->AGA_ENTIDA + "ADR"
	oModel:GetModel("AGAMASTER"):GetStruct():SetProperty('AGA_CODENT',MVC_VIEW_LOOKUP,cField)
EndIf*/

If lRet .And. lAlter .And. FwViewActive() <> NIL
	If !MsgYesNo(STR0007)
		oModel:SetOperation(MODEL_OPERATION_INSERT)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CR360Pre
Pre Valid to load value for AGA_FROM
@author 	Andrews Egas
@since 24/04/2017
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------
Function CR360Pre(oModel)
Local lRet as Logical
Local oView
Local cName := ""

lRet := .T.

If oModel:IsCopy() .And. lAtuali .And. (Empty(ReadVar()) .Or. ("AGA_ENTIDA" $ ReadVar() .And. __cAliasAd <> NIL))
	oView	:= FwViewActive()
	lAtuali := .F.
	oModel:GetModel("AGAMASTER"):LoadValue("AGA_FROM",dDataBase)
	oModel:GetModel("AGAMASTER"):LoadValue("AGA_TO",CTOD(" "))
	If __cAliasAd <> NIL
		oModel:GetModel("AGAMASTER"):LoadValue("AGA_ENTIDA",__cAliasAd)
		oModel:GetModel("AGAMASTER"):LoadValue("AGA_CODENT",__cKeyAd)
		cName := SubStr(Posicione(__cAliasAd,1,__cKeyAd,(__cAliasAd)->(IIF(SUBSTR(__cAliasAd,1,1)=="S",SUBSTR(__cAliasAd,2,2),__cAliasAd)+'_NOME')),1,Len(M->AGA_NAMENT))
		oModel:GetModel("AGAMASTER"):LoadValue("AGA_NAMENT",cName)   
	EndIf
	oView:Refresh()
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CR360Pict
Change picture AGA_CEP
@author Andrews Egas
@since 24/04/2017
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------
Function CR360Pict()
Local cCampoPic as char
Local cVal := M->AGA_PAIS

If cVal == '643'
	cCampoPic := "@E 999999"
Else
	cCampoPic := "@! XXXXXXXXXX%C"
EndIf

M->AGA_CEP := Transform(M->AGA_CEP,cCampoPic)

Return cCampoPic

//-------------------------------------------------------------------
/*/{Protheus.doc} CR360Cep
Change picture AGA_CEP
@author Andrews Egas
@since 24/04/2017
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------
Function CR360Cep(cVar)
Local lRet as Logical
Local cCountr := M->AGA_PAIS
lRet := .T.

If !Empty(cVar) .And. AllTrim(cVar) <> "0" 
	If cCountr == '643'
		lRet := Len(AllTrim(cVar)) == 6
		Help(" ",1,"CR360CEPV")
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CR360KeyF3
Call F3 to AGA_CODENT
@author 	Andrews Egas
@since 24/04/2017
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------
Function CR360KeyF3()
Local lRet as logical
Local cCampo as char
Local cRet as char
Local n
Local aHeadKey as array
cRet := ""

cCampo := M->AGA_ENTIDA

lRet := cCampo $ "SA1|SA2|SM0"

If lRet .And. FwViewActive() <> NIL
	lRet := ConPad1(,,, cCampo + "ADR")
	If lRet
		If cCampo $ "SA1|SA2"
			aHeadKey := STRTOKARR((cCampo)->(IndexKey(1)),'+')
			For n := 1 to Len(aHeadKey)
				cRet += (cCampo)->&(aHeadKey[n])
			Next
			M->AGA_CODENT := cRet
			M->AGA_NAMENT := SubStr((cCampo)->&(IIF(SUBSTR(cCampo,1,1)=="S",SUBSTR(cCampo,2,2),cCampo)+'_NOME'),1,Len(M->AGA_NAMENT))
		EndIf		
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CRGetAddr
Get Addresses by date
@author 	Andrews Egas
@since 24/04/2017
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------
Function CRGetAddr(cAliasP, cKeyP, dDate)

Local cQuery 		as character
Local cRet			as char
Local aArea 		as array
Local cAliasChk := ''

Default dDate := dDatabase
Default cKeyP := ""

cAliasChk := CriaTrab(,.F.)
cRet := ""
aArea 		:= getArea()

cQuery := "SELECT AGA_END FROM " + RetSqlName("AGA") + CRLF
cQuery += " WHERE AGA_FILIAL = '"+xFilial("AGA")+"'" + CRLF
cQuery += " AND AGA_ENTIDA = '" + cAliasP + "'" + CRLF
cQuery += " AND AGA_CODENT = '" + cKeyP + "'" + CRLF
cQuery += " AND '" + DtoS(dDate) + "' BETWEEN AGA_FROM AND AGA_TO"
cQuery += " AND D_E_L_E_T_ = ' ' "

dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQuery ) , cAliasChk )

(cAliasChk)->( dbGoTop() )

If (cAliasChk)->(!EOF())
	If !Empty((cAliasChk)->AGA_END)
		cRet := (cAliasChk)->AGA_END
	EndIf
EndIf

(cAliasChk)->( dbCloseArea() )

RestArea(aArea)

Return cRet                       

//-------------------------------------------------------------------
/*/{Protheus.doc} F3XX8ADREMP
Get SX3 xx8
@author 	Andrews Egas
@since 31/10/2017
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------
Function F3XX8ADREMP()

Local aArea	:= GetArea()
Local aCpos     := {}       //Array com os dados
Local lRet      := .T. 		//Array do retorno da opcao selecionada
Local oDlgF3                  //Objeto Janela
Local oLbx                  //Objeto List box
Local aRet		:= {}
Local cRet		:= ""
Local cName 	:= ""
Local cfilter := "1"	    

DbSelectArea("XX8")
XX8->(dbSetOrder(1))
XX8->(dbGoTop())


Pergunte("CR680ADR",.T.)

If mv_par01 == 1
cfilter := "0"
ElseIf mv_par01 == 2
cfilter := "1"
ElseIf mv_par01 == 3
cfilter := "2"
ElseIf mv_par01 == 4
cfilter := "3"
EndIf


While !XX8->(Eof())
   
   If XX8_TIPO == cfilter
	   
	   If mv_par01 == 1
			aAdd( aCpos, { XX8->XX8_GRPEMP, XX8->XX8_CODIGO, XX8->XX8_EMPR, XX8->XX8_TIPO, XX8->XX8_DESCRI } )
		ElseIf mv_par01 == 2
			aAdd( aCpos, { XX8->XX8_GRPEMP, XX8->XX8_CODIGO, XX8->XX8_EMPR, XX8->XX8_TIPO, XX8->XX8_DESCRI } )
		ElseIf mv_par01 == 3
			aAdd( aCpos, { XX8->XX8_GRPEMP, XX8->XX8_CODIGO, XX8->XX8_EMPR, XX8->XX8_TIPO, XX8->XX8_DESCRI } )
		ElseIf mv_par01 == 4
			aAdd( aCpos, { XX8->XX8_GRPEMP, XX8->XX8_CODIGO, XX8->XX8_EMPR, XX8->XX8_UNID, XX8->XX8_DESCRI } )
		EndIf
   EndIf
   
   XX8->(DbSkip())
   
Enddo

If Len( aCpos ) > 0
	
	DEFINE MSDIALOG oDlgf3 TITLE STR0008 FROM 0,0 TO 240,500 PIXEL
	
	   @ 10,10 LISTBOX oLbx FIELDS HEADER STR0009, STR0010, STR0011, STR0012 ,STR0013  SIZE 230,95 OF oDlgf3 PIXEL	
	
	   oLbx:SetArray( aCpos )
	   oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3], aCpos[oLbx:nAt,4], aCpos[oLbx:nAt,5]}}
	   oLbx:bLDblClick := {|| {oDlgF3:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4],oLbx:aArray[oLbx:nAt,5]}}} 	                   

	DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlgF3:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4],oLbx:aArray[oLbx:nAt,5]})  ENABLE OF oDlgF3
	ACTIVATE MSDIALOG oDlgF3 CENTER
		
EndIf	

If lRet .And. !Empty(aRet)
	If mv_par01 == 1
			cRet := xFilial("SM0") + aRet[2] + aRet[4]
		ElseIf mv_par01 == 2
			cRet := xFilial("SM0") + aRet[1] + aRet[2] + aRet[4]
		ElseIf mv_par01 == 3
			cRet := xFilial("SM0") + aRet[1] + aRet[3] + aRet[2] + aRet[4]
		ElseIf mv_par01 == 4
			cRet := xFilial("SM0") + aRet[1] + aRet[3] + aRet[4] + aRet[2]
		EndIf
	
	M->AGA_CODENT := cRet
	M->AGA_NAMENT	:= aRet[5]
EndIf

RestArea(aArea)

Return lRet

//merge branch 12.1.19