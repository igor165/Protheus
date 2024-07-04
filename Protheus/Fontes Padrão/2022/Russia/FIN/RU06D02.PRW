#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU06D02.CH"
#INCLUDE "TOPCONN.CH"
/*/{Protheus.doc} RU06D02
Uploading Of Banks Classifier (Russia)

@author Flavio Lopes
@since 03/04/2017
@version MA3 - Russia
/*/
Function RU06D02()
Local oBrowse as object
Local oTableAtt as Object

oTableAtt:= TableAttDef()

oBrowse := BrowseDef()

//----------------------------------
// 'Select All' Button
//----------------------------------
oBrowse:SetAttach(.T.)
oBrowse:SetViewsDefault(oTableAtt:aViews)
oBrowse:SetChartsDefault(oTableAtt:aCharts)

oBrowse:Activate()

Return Nil

/*/{Protheus.doc} BrowseDef
Browse definition

@author Flavio Lopes
@since 03/04/2017
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse as object

oBrowse := FwMBrowse():New()
oBrowse:SetAlias("F45") 
oBrowse:SetDescription(STR0001)//Banks Classifier

Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu definition

@author Flavio Lopes
@since 03/04/2017
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina as array

aRotina := {}

ADD OPTION aRotina Title STR0002 	Action 'VIEWDEF.RU06D02'	OPERATION 2 ACCESS 0 //View
ADD OPTION aRotina Title STR0003 	Action 'RUBkUpload()'		OPERATION 3 ACCESS 0 //Upload
ADD OPTION aRotina Title STR0018	Action 'VIEWDEF.RU06D02'	OPERATION 3 ACCESS 0 //Added
ADD OPTION aRotina Title STR0019    Action 'RUChng()'	    	OPERATION 4 ACCESS 0 // Changed
ADD OPTION aRotina Title STR0020 	Action 'RUDel()'	        OPERATION 4 ACCESS 0 //Delete   

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de dados

@author Flavio Lopes
@since 03/04/2017
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruF45 	as object                              
Local oModel 	as object

oStruF45 	:= FWFormStruct( 1, "F45")                              
oModel 		:= MPFormModel():New("RU06D02")

oModel:AddFields("F45MASTER",, oStruF45)
oModel:GetModel("F45MASTER"):SetDescription(STR0001) 

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Flavio Lopes
@since 03/04/2017
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel	as object
Local oStruF45	as object
Local oView		as object  

oModel		:= FWLoadModel("RU06D02")
oStruF45	:= FWFormStruct(2,"F45")
oView		:= FWFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_F45",oStruF45,"F45MASTER")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} RUDel
Delete the current entry only for foreign banks

@author Marina Dubovaya
@since 01/26/2018
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Function RUDel()
local cTab    :="" 

 If F45_FOREIG<>'1'
     Help("",1,"RU06D02RuDEL118",,STR0021,1,0) // A foreign bank can only be deleted
    else
      If  RUGetDel("SA6","A6_AGENCIA") .or. RUGetDel("FIL","FIL_AGENCI") .or. RUGetDel("F4N","F4N_BIK") 
         Help("",1,"RU06D02RuDEL121",,STR0022,1,0) // Imposible to delete. Some accounts are related to this bank
        else
         RecLock("F45",.F.)
         dbDelete()
         MsUnlock()
         Help("",1,"RU06D02RuDEL126",,STR0023,1,0) //The record was delete successfully
     endif  
  endIf
Return

/*/{Protheus.doc} RUDel
Preparing to delete a record from the directory bank classifier only for foreign banks

@author Marina Dubovaya
@since 01/26/2018
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Function RUGetDel(cDat,cFld)
local cTab    :="" 
local lRet    := .F.
     cQuery := "SELECT '1' FROM "
     cQuery +=  RetSQLName(cDat)
     cQuery +=  " WHERE "+cFld+" = '"+ F45->F45_BIK +"' "
     cQuery += "AND D_E_L_E_T_ = ' ';"
     
     cTab := CriaTrab( , .F.)
     
     TcQuery cQuery NEW ALIAS ((cTab)) 
        
     If !(cTab)->(Eof())
        lRet :=.T. 
     endif  

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RUChng
Edit current entry only for foreign banks

@author Marina Dubovaya
@since 01/15/2018
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Function RUChng(oModel AS OBJECT)

 If F45_FOREIG=='1'
   FWExecView(STR0019, "RU06D02", MODEL_OPERATION_UPDATE, /* [ oDlg ] */, { || .T. } /* [ bCloseOnOK ] */, /* [ bOk ] */, /* [ nPercReducao ] */, /* [ aEnableButtons ] */, Nil, Nil, Nil, oModel /* [ oModel ] */)
 else    	    
   Help("",1,"RU06Â02RuChng168",,STR0024,1,0) //A foreign bank can only be changed
 endIf   

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RUBkUpload
Upload data from Ros Business Consulting

@author Flavio Lopes
@since 03/04/2017
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Function RUBkUpload()
Local nOpc as numeric

nOpc := Aviso(STR0004,STR0005,{STR0006,STR0007})//"Banks Classifier Upload"#"This routine will upload the Banks Classifier catalog from RBC (RosBusinessConsulting). "#"Continue"#"Cancel"
If nOpc == 1
	Processa( {||RUBkUpProc()}, STR0008 ,STR0009 , .F. )//"Banks Uploading"#"Uploading Banks Classifier Catalog..."
	Aviso(STR0010,STR0011,{STR0012})//"Banks Classifier Upload Done"#"The upload has been done."#"Ok"
Endif

Return

Function RUBkUpProc()

Local cUrl	as character
Local cPath	as character
Local cToken as character
Local cMakeDir as character
Local aMakeDir as array
Local nError as numeric
Local oUPDBCLA	:= NIL
Local oDELBCLA	:= NIL
Local cPathFiles := ""
Local cUPDBCLA		:= SuperGetMv("MV_UPDBCLA",.F.,"bnkseek_swift.txt")
Local cDELBCLA		:= SuperGetMv("MV_DELBCLA",.F.,"bnkdel.txt")
Local aLinesInc		:= {}
Local aLinesDel		:= {}
Local aData			:= {} 
Local cBuffer		:= ""
Local nX			:= 1
Local lRet			:= .T.
Local cSeek			:= ""
Local lFirstLoad	:= .F.


cUrl := SuperGetMv("MV_URLBCLA",.F.,"http://cbrates.rbc.ru/bnk/bnk.zip")
cPath := SuperGetMv("MV_PATHCLA",.F.,"\data\") + SubStr( cUrl, Rat("/",cUrl) + 01 )
cPathFiles := SuperGetMv("MV_PATHCLA",.F.,"\data\")
cMakeDir := ""
nError := 0
cToken := SubStr(alltrim(cPathFiles),Len(alltrim(cPathFiles)))

//Checking existing directory for downloading
If !ExistDir( cPathFiles)
	// Array for creation subdirectory in full path
	aMakeDir := StrToArray(cPathFiles, cToken)
	For nX := 1 to Len(aMakeDir)
		cMakeDir += cToken + aMakeDir[nX]
		If !ExistDir( cPathFiles)
			nError := MakeDir( cMakeDir )
		EndIf
	Next nX
EndIf

ProcRegua( 3 )
If nError == 0
	lRet:= BkDownload(cUrl, cPath)
	lRet:= BkUnzip(cPathFiles,cPathFiles + SubStr( cUrl, Rat("/",cUrl) + 01 ))
Else
	lRet := .F.
Endif

If lRet
	F45->(DbSetOrder(1))
	lFirstLoad := F45->(Eof()) 

	nError := FT_FUSE(cPathFiles +cToken + cUPDBCLA)

	If nError != -1
	FT_FGOTOP()  
	
	IncProc(STR0013)//"Reading Banks Catolog..."
	While !FT_FEOF()
		cBuffer := FT_FREADLN()
		AADD(aLinesInc,cBuffer)	
		FT_FSKIP()
	End
	Else
		lRet := .F.
	EndIf
	FT_FUSE()
	If lRet
	//Deleted banks
		nError := FT_FUSE(cPathFiles +cToken + cDELBCLA)
		If nError != -1
	       FT_FGOTOP()  
	       IncProc(STR0014)//"Reading Deleted Banks Catalog..."	
			While !FT_FEOF()
				cBuffer := FT_FREADLN()
				AADD(aLinesDel,cBuffer)	
				FT_FSKIP()
			End
			FT_FUSE()
		Else
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf
	
	If lRet
		ProcRegua( Len(aLinesInc) + Len(aLinesDel) )
	
		Begin Transaction
	
		For nX := 1 To Len(aLinesInc)
			aData := StrTokArr( aLinesInc[nX], Chr(9) )
			If Len(aData) > 3
	
				  cSeek	:= aData[5]
			Else
				cSeek	:= aData[3]
			Endif 
			If F45->(DbSeek(xFilial("F45")+AllTrim(cSeek)))
					RecF45(4,aData)
			Else
				RecF45(3,aData)
			Endif	
			IncProc(STR0015)//"Loading Banks..."
		Next nX
	
		//Deleted banks
		aData	:= {}
	
		For nX := 1 To Len(aLinesDel)
			aData := StrTokArr( aLinesDel[nX], Chr(9) )
			If Len(aData) >= 6
				cSeek	:= aData[6]
			Else
				cSeek	:= aData[Len(aData)]
			Endif 
			If F45->(DbSeek(xFilial("F45")+AllTrim(cSeek)))
				RecF45(4,,.T.,lFirstLoad)
			Endif
			IncProc(STR0016)//"Loading Deleted Banks..."
		Next nX
	
		End Transaction
	    IncProc(STR0025)//"Preparin synching of foreign banks..."
	    GetFrnBnk()
	Endif
Endif

If !lRet
	If !IsBlind()
		Help("",1,STR0028,,STR0029 + str(FError(),4),1,0) 	// Error during downloading ## Code:
	EndIf
Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFrnBnk

Synchronization of company accounts data (SA6) with bank classifier (F45)

@author Marina Dubovaya
@since 01/19/2018
@version MA3 - Russia
/*/
//-------------------------------------------------------------------

Function GetFrnBnk() 
local cTab    :="" 

	cQuery := "  SELECT " + CRLF
	cQuery += "  F45_FILIAL,"  + CRLF
	cQuery += "  F45_BIK," + CRLF
	cQuery += "  F45_NAME," + CRLF
	cQuery += "  F45_CORRAC," + CRLF
	cQuery += "  F45_CITY," + CRLF
	cQuery += "  F45_SWIFT," + CRLF
	cQuery += "  F45_STATUS," + CRLF
	cQuery += "  F45_FOREIG" + CRLF
	cQuery +=  " FROM " + RetSQLName("F45") + CRLF
	cQuery +=  " WHERE F45_FOREIG = '1' "  + CRLF
          
  IncProc(STR0026) //The list  for synching are preparing...
  cTab := CriaTrab( , .F.)
  TcQuery cQuery NEW ALIAS ((cTab))    
  DbSelectArea((cTab))
   cQuery := ""
   While ((cTab)->(!Eof()))
		cQuery += "  UPDATE "+ RetSQLName("SA6")+ " SET " + CRLF
		cQuery += "  A6_NOME ='"	+ alltrim((cTab)->F45_NAME) +"', "
		cQuery += "  A6_MUN  ='"	+ alltrim((cTab)->F45_CITY) +"', "
		cQuery += "  A6_SWIFT ='"	+ alltrim((cTab)->F45_SWIFT) +"' " + CRLF
		cQuery += "  WHERE A6_AGENCIA ='"+ (cTab)->F45_BIK +"' " + CRLF
		cQuery += "  AND D_E_L_E_T_ = ' ';" + CRLF
        (cTab)->(DbSkip())
   Enddo
   
   IncProc(STR0027)
   Begin Transaction
      TCSqlExec(cQuery)
   End Transaction 
   DbCloseArea((cTab))
      
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TableAttDef

@param      Nenhum
@return     Nenhum

@author     Squad CRM / FAT
@version    12.1.17 / Superior
@since            16/01/2017
/*/
//-------------------------------------------------------------------
Static Function TableAttDef()
Local oTableAtt as Object
Local lCRMBrwView as Logical

oTableAtt   := Nil
lCRMBrwView := ExistBlock("CRMBRWVIEW")   // Entrance point for views
      

      If lCRMBrwView
            oTableAtt := ExecBlock("CRMBRWVIEW", .F.,.F.,{cRotina,cAliasView})
      EndIf 
      
      If Empty( oTableAtt )
      
            oTableAtt   := FWTableAtt():New()
            oTableAtt:SetAlias("F45")
Endif

Return oTableAtt



//-------------------------------------------------------------------
/*/{Protheus.doc} BkDownload
Upload data from Ros Business Consulting

@author Flavio Lopes
@since 03/04/2017
@version MA3 - Russia
/*/
//-------------------------------------------------------------------

Function BkDownload(cUrl, cPath)
Local cHtml := ""
Local lRet 	:= .F.
Local cGet	:= ""

IncProc(STR0017)//"Uploading Banks Classifier Catalog..."
cHtml := HttpGet( cUrl,,5,,@cGet )

If !Empty(cHtml)
	lRet := MemoWrite( cPath, cHtml )
Else
	Alert(cGet)
Endif

Return lRet

Static Function BkUnzip(cPath,cFile)
Local lRet as logical
Local nRet as numeric

nRet := FUnZip(cFile,cPath)
lRet:= !(nRet != 0)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RecModel


@author Flavio Lopes
@since 04/04/2017
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function RecF45(nOper, aData, lBlock , lDel)

Local oModel	as object 
Local oModelF45	as object 
Local cName		as character
Local cCity		as character
Local cSwift	as character
Local cQuery	as character

Default lBlock	:= .F.
Default lDel	:= .F.
Default aData	:= {}

If nOper == 3
	RecLock("F45",.T.)	
Elseif nOper == 4
	cName	:= F45->F45_NAME
	cCity	:= F45->F45_CITY
	cSwift	:= F45->F45_SWIFT
	RecLock("F45",.F.)
Endif

If !lBlock
	F45->F45_FILIAL := xFilial("F45")
	If Len(aData) > 3
		F45->F45_CITY 	:= AllTrim(TypeCorr(aData[3])+" "+ aData[2])
		F45->F45_NAME 	:= AllTrim(aData[4])
		F45->F45_BIK 	:= AllTrim(aData[5]) 
		If  Len(aData) > 5
			F45->F45_CORRAC := AllTrim(aData[6])
			
			If Len(aData) > 6
				F45->F45_SWIFT 	:= AllTrim(aData[7]) 
			Endif
		Endif
	Else
		F45->F45_NAME 	:= AllTrim(aData[2])
		F45->F45_BIK 	:= AllTrim(aData[3])
	Endif
	F45->F45_STATUS := "2"
	F45->F45_FOREIG	:= "2" 
Else
	If lDel
		dbDelete()
	Else
		F45->F45_STATUS := "1"
		F45->F45_FOREIG	:= "2"
	Endif
Endif

MsUnlock()

If nOper == 4 .And. !lDel
	If lBlock .Or. (cName <> F45->F45_NAME .Or. cCity <> F45->F45_CITY .Or. cSwift <> F45->F45_SWIFT)
		
		cQuery := "UPDATE "+ RetSQLName("SA6")+ " SET " 
		If lBlock
			cQuery += "A6_BLOCKED ='1' "	
		Else
			cQuery += "A6_NOME ='"	+ F45->F45_NAME +"' , "
			cQuery += "A6_MUN  ='"	+ F45->F45_CITY +"' , "
			cQuery += "A6_SWIFT ='"	+ F45->F45_SWIFT +"' "
		Endif
		cQuery += "WHERE A6_AGENCIA = '"+ F45->F45_BIK +"' " 
		cQuery += "AND D_E_L_E_T_ = '' "			
		
		If TCSQLEXEC(cQuery) < 0
			Alert("Error During the update")
		Endif

	Endif
Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TypeCorr()


@author Flavio Lopes
@since 04/04/2017
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Function TypeCorr(cCodeType)
Local aTypes as array

aTypes := {}

aAdd(aTypes,"Ã.")
aAdd(aTypes,"Ï.")
aAdd(aTypes,"Ñ.")
aAdd(aTypes,"ÏÃÒ")
aAdd(aTypes,"ÑÒ-ÖÀ")
aAdd(aTypes,"ÀÓË")
aAdd(aTypes,"ÐÏ")

cType := aTypes[Val(cCodeType)]

Return cType

//merge branch 12.1.19
// Russia_R5
