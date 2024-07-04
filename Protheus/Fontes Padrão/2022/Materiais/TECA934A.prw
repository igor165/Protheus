#include "TECA934A.CH"
#include "protheus.ch"
#include "fwmvcdef.ch"
#include "fwbrowse.ch"

Static nTotMark := 0


//--------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

@author Matheus Lando Raimundo
@return oModel
/*/
//--------------------------------------------------------------------
Static Function ModelDef()
Local oModel 		:= Nil
Local oStrZZZ  := FWFormModelStruct():New()
Local oStrCN9		:= FWFormStruct( 1, "CN9",{|cCampo| AllTrim(cCampo) $ "CN9_NUMERO|CN9_REVISA|CN9_DTINIC|CN9_DTFIM|CN9_VLATU|CN9_SALDO"})
Local aCampo    := {}
Local bNoInit := FwBuildFeature( STRUCT_FEATURE_INIPAD, '' )

oModel := MPFormModel():New('TECA934A',,{|oModel|At934aVld(oModel)},{|oModel|At934aCmt(oModel)})

oStrZZZ:AddTable("ZZZ",{" "}," ")
oStrCN9:SetProperty("*", MODEL_FIELD_INIT, bNoInit )  // remove todos os inicializadores padrão dos campos
oStrCN9:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)


aCampo := {STR0001, STR0001,'_OPERAC','C', 1, 0,{||.T.}, Nil, Nil, Nil, Nil, Nil, Nil, .F.}//STR0002//'Operação'
AddFieldMD(@oStrZZZ,aCampo)

aCampo := {}
aCampo := {STR0003, STR0003,'_COMPET','C', 7, 0,{||.T.}, Nil, Nil, Nil, Nil, Nil, Nil, .F.}//'competência'
AddFieldMD(@oStrZZZ,aCampo)

aCampo := {}
aCampo := {STR0014, STR0014,'_COMPANT','C', 7, 0,{||.T.}, Nil, Nil, Nil, Nil, Nil, Nil, .F.}//'Compet Apur'
AddFieldMD(@oStrZZZ,aCampo)

oStrZZZ:SetProperty("ZZZ_OPERAC", MODEL_FIELD_INIT, {|| "2" } )  // remove todos os inicializadores padrão dos campos
aCampo := {}
aCampo := {STR0015, STR0015,'_MARK','L', 1, 0,{||.T.}, Nil, Nil, .F.,Nil, Nil, Nil, .F.} //'Mark'
AddFieldMD(@oStrCN9,aCampo)

aCampo := {}
aCampo := {STR0016, STR0016,'_RECORR','C', 3, 0,{||.T.}, Nil, Nil, .F.,Nil, Nil, Nil, .F.} //'Recorrente'
AddFieldMD(@oStrCN9,aCampo)

oModel:addFields( 'ZZZMASTER', ,oStrZZZ)
oModel:AddGrid( 'CN9DETAIL', 'ZZZMASTER',oStrCN9 ,,,,,)

oModel:GetModel('ZZZMASTER'):SetOnlyQuery(.T.)
oModel:GetModel('CN9DETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('CN9DETAIL'):SetNoDeleteLine(.T.)
oModel:GetModel('CN9DETAIL'):SetOnlyQuery(.T.)

oModel:GetModel('ZZZMASTER'):SetDescription(STR0004) //'Parâmetros'
oModel:GetModel('CN9DETAIL'):SetDescription(STR0005)//'Contratos'

oModel:SetPrimaryKey({})
oModel:SetDescription(STR0006)//'Processamento em Lote'


Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} 	ViewDef()

@author Matheus Lando Raimundo
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()
Local oModel   	:= ModelDef()
Local oView    	:= FWFormView():New()		
Local oStrZZZ  	:= FWFormStruct(2,'ZZZ')
Local oStrCN9  	:= FWFormStruct(2,'CN9',{|cCampo| AllTrim(cCampo) $ "CN9_NUMERO|CN9_REVISA|CN9_DTINIC|CN9_DTFIM"})
Local aCampo    := {}
Local aCombo	:= {}
Local lInsert := IIF(FindFunction("AT934SetIL") , AT934SetIL() ,IsInCallStack('At934ILote') )
Local lEstorna := IIF(FindFunction("AT934SetEL"), AT934SetEL() ,IsInCallStack('At934ELote') )

If lInsert
	SX3->(dbSetOrder(2)) 
	If SX3->(dbSeek('ABX_OPERAC'))   
		aCombo  := StrTokArr(X3Cbox(),';')
	EndIf
ElseIf lEstorna	
	Aadd(aCombo,STR0017) //'1=Estornar medição/apuração'
EndIf

oStrCN9:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)	

//{cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,nPictVar,F3,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar				
aCampo 	:= {'_OPERAC', '00', STR0002,STR0002, Nil, 'C', '@!', Nil, '', .T., Nil, Nil, aCombo, Nil, Nil, .T.,Nil}
AddFieldVW('ZZZ',@oStrZZZ,aCampo)

aCampo 	:= {}
aCampo 	:= {'_COMPET', '01', STR0007,STR0007, Nil, 'C', '@9 99/9999', Nil, '', .T., Nil, Nil, Nil, Nil, Nil, .T.,Nil}//'Competência'
AddFieldVW('ZZZ',@oStrZZZ,aCampo)

aCampo 	:= {}
aCampo 	:= {'_COMPANT', '02', STR0014,STR0014, Nil, 'C', '@9 99/9999', Nil, '', .F., Nil, Nil, Nil, Nil, Nil, .T.,Nil}//"Compet Apur"
AddFieldVW('ZZZ',@oStrZZZ,aCampo)

aCampo 	:= {}
aCampo 	:= {'_MARK', '00', ' ',' ', Nil, 'L', Nil, Nil, '', .T., Nil, Nil, Nil, Nil, Nil, .T.,Nil}
AddFieldVW('CN9',@oStrCN9,aCampo)

aCampo 	:= {}
aCampo 	:= {'_RECORR', '05', STR0016,STR0018, Nil, 'C', Nil, Nil, '', .F., Nil, Nil, Nil, Nil, Nil, .T.,Nil} //'Recorrente'
AddFieldVW('CN9',@oStrCN9,aCampo)

oStrCN9:SetProperty( 'CN9_NUMERO' , MVC_VIEW_ORDEM, '01')
oStrCN9:SetProperty( 'CN9_REVISA' , MVC_VIEW_ORDEM, '02')

oView:SetModel(oModel)  //-- Define qual o modelo de dados será utilizado
oView:SetDescription(STR0006)

oView:AddField('VIEW_ZZZ' ,oStrZZZ, 'ZZZMASTER')
oView:AddGrid('VIEW_CN9'  ,oStrCN9, 'CN9DETAIL')

oView:CreateHorizontalBox('CIMA',30)
oView:CreateHorizontalBox('MEIO',70)

oView:SetOwnerView('VIEW_ZZZ','CIMA' )
oView:SetOwnerView('VIEW_CN9','MEIO')

oView:EnableTitleView('VIEW_ZZZ' , STR0004 ) 
oView:EnableTitleView('VIEW_CN9' , STR0005 ) 

oView:SetCloseOnOk({||.T.})
oView:SetViewProperty("VIEW_CN9", "ENABLENEWGRID")
oView:SetViewProperty("VIEW_CN9", "GRIDFILTER", {.T.})

oView:SetFieldAction( 'CN9_MARK', { |oView, cIDView, cField, xValue| At934aMark(xValue) } )
oView:SetFieldAction( 'ZZZ_OPERAC', { |oView, cIDView, cField, xValue|  At934aLdCN(oView) } )
oView:SetFieldAction( 'ZZZ_COMPET', { |oView, cIDView, cField, xValue|  At934aLdCN(oView) } )

oView:setInsertMessage(STR0006,STR0018) //'Processamento em Lote' ## 'Processamento efetuado com sucesso'


oView:AddUserButton(STR0008 ,"",{|oView| A934ViewCTR()}) //"Visualizar contrato"
oView:AddUserButton(STR0019 ,"",{|oView| A934aAll()})    //"Replicar marcação"

Return oView

//--------------------------------------------------------------------
/*/{Protheus.doc} 	At934aInit()

@author Matheus Lando Raimundo
@return lRet
/*/
//--------------------------------------------------------------------
Function At934ALoad(oView,cCompetencia,cCompAnt, lAutomato)
Local oModel := FwModelActive()
Local cAliasTemp := GetNextAlias()
Local oCN9Detail := oModel:GetModel('CN9DETAIL') 
Local aRet  	 := {}
Local oStrCN9	 := oCN9Detail:GetStruct()
Local cOperac    := oModel:GetValue('ZZZMASTER','ZZZ_OPERAC')
Local dCompet    := 0
Local nAno       := 0
Local nMes	     := 0
Local cCompetQry := ""			 
Local lEstorna	 := IIF(FindFunction("AT934SetEL"), AT934SetEL() ,IsInCallStack('At934ELote') )
Default lAutomato := .F.
CNTA300BlMd(oCN9Detail,.F.) 

nTotMark := 0
At934ClGrd(oCN9Detail)


dCompet := CTOD("01/"+cCompetencia) 
		
nAno := Year(dCompet)
nMes := Month(dCompet)
		
cCompetQry := Alltrim(Str(nAno) + StrZero(nMes,2))

oStrCN9:SetProperty('*', MVC_VIEW_CANCHANGE, .T.)
oStrCN9:SetProperty('*', MODEL_FIELD_OBRIGAT , .F.)	

If lEstorna
	BeginSQL Alias cAliasTemp
			
			SELECT CN9_NUMERO, CN9_REVISA, CN9_DTINIC, CN9_DTFIM, CN9_VLINI, CN9_VLATU, CN9_SALDO, 
			CASE 
				WHEN TFJ_CNTREC = '1'  THEN 'Sim'
				ELSE 'Não'
			END	TFJ_CNTREC
			FROM %Table:CN9% CN9			 
			INNER JOIN %Table:TFJ% TFJ ON TFJ_FILIAL = %xFilial:TFJ%
														AND TFJ_CONTRT = CN9_NUMERO
														AND TFJ_CONREV = CN9_REVISA
														AND TFJ.%NotDel%
			INNER JOIN %Table:ABX% ABX ON ABX_FILIAL = %xFilial:ABX%
									AND ABX_CONTRT = CN9.CN9_NUMERO
									AND ABX_CONREV = CN9.CN9_REVISA
									AND ABX_MESANO = %Exp:cCompetencia%
									AND ABX_CODPLA <> ''																					
									AND ABX.%NotDel%																																				
			GROUP BY CN9_NUMERO, CN9_REVISA, CN9_DTINIC, CN9_DTFIM, CN9_VLINI, CN9_VLATU, CN9_SALDO, TFJ_CNTREC
    EndSQL
Else 


	If cOperac == '1'
		BeginSQL Alias cAliasTemp	
			
			//-- TITPRO --//
			SELECT CN9_NUMERO, CN9_REVISA, CN9_DTINIC, CN9_DTFIM, CN9_VLINI, CN9_VLATU, CN9_SALDO,
			CASE 
				WHEN TFJ_CNTREC = '1'  THEN 'Sim'
				ELSE 'Não'
			END	TFJ_CNTREC
			FROM %Table:CN9% CN9			 
			INNER JOIN %Table:TFJ% TFJ ON TFJ_FILIAL = %xFilial:TFJ%
														AND TFJ_CONTRT = CN9_NUMERO
														AND TFJ_CONREV = CN9_REVISA
														AND TFJ_ANTECI = '1' 
														AND TFJ_STATUS = '1' 
														AND TFJ.%NotDel%
			WHERE CN9_FILIAL = %xFilial:CN9%	
				AND CN9.CN9_SITUAC = '05'
				AND CN9.%NotDel%
				AND EXISTS (
								SELECT 1 FROM %Table:CNF% CNF
									WHERE CNF_FILIAL = %xFilial:CNF%														
									AND CNF_CONTRA = CN9.CN9_NUMERO
									AND CNF_REVISA = CN9.CN9_REVISA
									AND CNF_COMPET = %Exp:cCompetencia%
									AND CNF_SALDO > 0													
									AND CNF.%NotDel%
							)
							OR EXISTS 
													
							(
							
								SELECT 1 FROM %Table:SE1% SE1
									WHERE E1_FILIAL = %xFilial:SE1%
									AND E1_MDCONTR = CN9.CN9_NUMERO
									AND E1_MDREVIS = CN9.CN9_REVISA							
									AND E1_TIPO    = 'PR' 
									AND SUBSTRING(E1_VENCTO,1,6) = %Exp:cCompetQry%
									AND SE1.%NotDel%		
							)
							
							
							
		EndSQL 
	ElseIf cOperac == '2'
		BeginSQL Alias cAliasTemp	
			
			SELECT CN9_NUMERO, CN9_REVISA, CN9_DTINIC, CN9_DTFIM, CN9_VLINI, CN9_VLATU, CN9_SALDO,
			CASE 
				WHEN TFJ_CNTREC = '1'  THEN 'Sim'
				ELSE 'Não'
			END	TFJ_CNTREC
			FROM %Table:CN9% CN9			 
			INNER JOIN %Table:TFJ% TFJ ON TFJ_FILIAL = %xFilial:TFJ%
														AND TFJ_CONTRT = CN9_NUMERO
														AND TFJ_CONREV = CN9_REVISA
														AND TFJ_ANTECI = '1' 
														AND TFJ_STATUS = '1' 
														AND TFJ.%NotDel%
			WHERE CN9_FILIAL = %xFilial:CN9%	
				AND CN9.CN9_SITUAC = '05'
				AND CN9.%NotDel%
				AND EXISTS (
								SELECT 1
								FROM %Table:CNF% CNF
									WHERE CNF_FILIAL = %xFilial:CNF%														
									AND CNF_CONTRA = CN9.CN9_NUMERO
									AND CNF_REVISA = CN9.CN9_REVISA
									AND CNF_COMPET = %Exp:cCompetencia%
									AND CNF_SALDO > 0													
									AND CNF.%NotDel%
							)		
								
								OR EXISTS 						
							(
							
								SELECT 1FROM %Table:SE1% SE1
								WHERE E1_FILIAL = %xFilial:SE1%
									AND E1_MDCONTR = CN9.CN9_NUMERO
									AND E1_MDREVIS = CN9.CN9_REVISA								
									AND E1_TIPO    = 'PR' 
									AND SUBSTRING(E1_VENCTO,1,6) = %Exp:cCompetQry%
									AND SE1.%NotDel%		
							)	
									
							
							OR EXISTS 
							(
								SELECT 1
								FROM %Table:ABX% ABX
									WHERE ABX_FILIAL = %xFilial:ABX%														
									AND ABX_CONTRT = CN9.CN9_NUMERO
									AND ABX_CONREV = CN9.CN9_REVISA
									AND ABX_MESANO = %Exp:cCompAnt%
									AND ABX_CODTFV = ''													
									AND ABX.%NotDel%
				
							)
						
							
		EndSQL 
	ElseIf cOperac == '3'
		BeginSQL Alias cAliasTemp	
			
			SELECT CN9_NUMERO, CN9_REVISA, CN9_DTINIC, CN9_DTFIM, CN9_VLINI, CN9_VLATU, CN9_SALDO, 
			CASE 
				WHEN TFJ_CNTREC = '1'  THEN 'Sim'
				ELSE 'Não'
			END	TFJ_CNTREC 
			FROM %Table:CN9% CN9			 
			INNER JOIN %Table:TFJ% TFJ ON TFJ_FILIAL = %xFilial:TFJ%
														AND TFJ_CONTRT = CN9_NUMERO
														AND TFJ_CONREV = CN9_REVISA
														AND TFJ_ANTECI = '1' 		
														AND TFJ_STATUS = '1' 		

														AND TFJ.%NotDel%
			WHERE CN9_FILIAL = %xFilial:CN9%	
				AND CN9.CN9_SITUAC = '05'
				AND CN9.%NotDel%
				AND EXISTS(
								SELECT 1
								FROM %Table:ABX% ABX
									WHERE ABX_FILIAL = %xFilial:ABX%														
									AND ABX_CONTRT = CN9.CN9_NUMERO
									AND ABX_CONREV = CN9.CN9_REVISA
									AND ABX_MESANO = %Exp:cCompAnt%
									AND ABX_CODTFV = ''													
									AND ABX.%NotDel%
							)
						
							
		EndSQL	
		
	EndIf
EndIf

While (cAliasTemp)->(!EOF())
	
	If ( !lEstorna .And. cOperac == "1") .Or. A93aUltMed((cAliasTemp)->(CN9_NUMERO),(cAliasTemp)->(CN9_REVISA),Iif(lEstorna,cCompetencia,cCompAnt),(cAliasTemp)->(TFJ_CNTREC) == "Sim")
	
		oCN9Detail:SetNoInsertLine(.F.)
		If !oCN9Detail:IsEmpty()
			oCN9Detail:AddLine()
		EndIf

		oCN9Detail:LoadValue('CN9_NUMERO',(cAliasTemp)->(CN9_NUMERO))
		oCN9Detail:LoadValue('CN9_REVISA',(cAliasTemp)->(CN9_REVISA))
		oCN9Detail:LoadValue('CN9_DTINIC',SToD((cAliasTemp)->(CN9_DTINIC)))
		oCN9Detail:LoadValue('CN9_DTFIM',SToD((cAliasTemp)->(CN9_DTFIM)))
		oCN9Detail:LoadValue('CN9_VLATU',(cAliasTemp)->(CN9_VLATU))
		oCN9Detail:LoadValue('CN9_SALDO',(cAliasTemp)->(CN9_SALDO))
		oCN9Detail:LoadValue('CN9_RECORR',(cAliasTemp)->(TFJ_CNTREC))
	Endif		

	(cAliasTemp)->(DbSkip())
EndDo
oCN9Detail:SetNoInsertLine(.T.)

(cAliasTemp)->(DbCloseArea())
oStrCN9:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

If !oCN9Detail:IsEmpty()
	CNTA300BlMd(oCN9Detail,,.T.)
Else
	CNTA300BlMd(oCN9Detail,.T.)
EndIf	
oCN9Detail:GoLine(1) 	
	
oStrCN9:SetProperty('CN9_MARK', MVC_VIEW_CANCHANGE, .T.)
oStrCN9:SetProperty('*', MODEL_FIELD_OBRIGAT , .F.)	

If !lAutomato
	oView:Refresh()
EndIF

Return .T.


//--------------------------------------------------------------------
/*/{Protheus.doc} 	A934ViewCTR()

@author Matheus Lando Raimundo
@return 
/*/
//--------------------------------------------------------------------
Function A934ViewCTR()
Local aArea	:= GetArea()
Local oModel	:= FwModelActive()
Local oCN9Detail := oModel:GetModel('CN9DETAIL')

CN9->(DbSetOrder(1))
If CN9->(DbSeek(xFilial('CN9')+ oCN9Detail:GetValue('CN9_NUMERO') + oCN9Detail:GetValue('CN9_REVISA')))
	FwExecView(STR0009,'VIEWDEF.CNTA301',MODEL_OPERATION_VIEW)  // 'Visualizar'//"Visualizar"
EndIf
RestArea(aArea)
Return

//--------------------------------------------------------------------
/*/{Protheus.doc} 	At934aVld()

@author Matheus Lando Raimundo
@return lRet
/*/
//--------------------------------------------------------------------
Function At934aVld(oModel)
Local lRet := .T.

If Empty(oModel:GetValue("ZZZMASTER","ZZZ_COMPET"))
  lRet := .F.
  Help(" ",1,"A934ACOMPET",,STR0010,4,1)//'Necessário informar a competência para realizar o processamento'
EndIf

If lRet .And. nTotMark == 0 
	lRet := .F.
	Help(" ",1,"A934CONTR",,STR0020,4,1)//"Necessário informar ao menos um contrato para processamento"
EndIf
 
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} 	At934aCmt()

@author Matheus Lando Raimundo
@return lRet
/*/
//--------------------------------------------------------------------
Function At934aCmt(oModel)
Local lRet := .T.
Local nI   := 1
Local oZZZMaster := oModel:GetModel('ZZZMASTER')
Local oCN9Detail := oModel:GetModel('CN9DETAIL')
Local cOper 	 := oZZZMaster:GetValue("ZZZ_OPERAC")
Local cCompet    := oZZZMaster:GetValue("ZZZ_COMPET")
Local nProc		 := 0
Local aError	 :=  {}
Local lAutomato := IIF(FindFunction("TECA934aut"), TECA934aut(), .F.)
For nI := 1 To oCN9Detail:Length()
	oCN9Detail:GoLine(nI)
	
	If oCN9Detail:GetValue('CN9_MARK')
		nProc += 1
		IF lAutomato
			lRet := At934aProc(oModel,cOper,cCompet,oCN9Detail:GetValue('CN9_NUMERO'),oCN9Detail:GetValue('CN9_REVISA'), @aError)
		Else
			MsgRun(STR0012 + Alltrim(Str(nProc)) + ' '+ STR0013 + Alltrim(Str(nTotMark)), STR0011,{|| lRet := At934aProc(oModel,cOper,cCompet,oCN9Detail:GetValue('CN9_NUMERO'),oCN9Detail:GetValue('CN9_REVISA'), @aError)})//"Processando Apurações/Mediçoes..."//"Processando contrato "//"de "
		EndIF
		If !lRet
			Exit
		Else
			oCN9Detail:LoadValue('CN9_MARK',.F.)
		EndIf
	EndIf	
Next nI

If !lRet
	If lAutomato
		Help(" ",1,"A934ACOMPET",,aError[MODEL_MSGERR_MESSAGE] + aError[MODEL_MSGERR_SOLUCTION],4,1)
	Else
		AtShowLog(Alltrim(aError[MODEL_MSGERR_MESSAGE] + CRLF + CRLF + aError[MODEL_MSGERR_SOLUCTION] ), STR0021, .T., .T., .T.,.F.)  // 'Valor de medição superior ao saldo do(s) item(ns) do contrato' ## "Processamento não concluído"
	EndIf
EndIf

FwModelActive(oModel)

Return lRet 

//--------------------------------------------------------------------
/*/{Protheus.doc} 	At934aProc()

@author Matheus Lando Raimundo
@return lRet
/*/
//--------------------------------------------------------------------
Function At934aProc(oModel,cOper,cCompet,cContrato,cRevisa,aError)
Local lRet := .T.
Local oMdl934    := Nil
Local lInsert := IIF(FindFunction("AT934SetIL") , AT934SetIL() ,IsInCallStack('At934ILote') )
Local lEstorna := IIF(FindFunction("AT934SetEL"), AT934SetEL() ,IsInCallStack('At934ELote') )
Local lEncontrou	:= .T.


If lInsert 
	oMdl934 := FwLoadModel('TECA934')
	oMdl934:SetOperation(MODEL_OPERATION_INSERT)
ElseIf lEstorna
	ABX->(dbSetOrder(6)) 
	If ABX->(dbSeek(xFilial('ABX')+cContrato+cRevisa+cCompet))
		oMdl934 := FwLoadModel('TECA934')   
		oMdl934:SetOperation(MODEL_OPERATION_DELETE)
	Else
		lEncontrou := .F.
	EndIf		
EndIf

If lEncontrou
	If oMdl934:Activate()
		If lInsert
			oMdl934:SetValue('ABXMASTER', 'ABX_OPERAC',cOper)
			oMdl934:SetValue('ABXMASTER','ABX_CONTRT',cContrato)
			oMdl934:SetValue('ABXMASTER','ABX_MESANO',cCompet)
		EndIf	
		If oMdl934:VldData() .And. oMdl934:CommitData()
			lRet := .T.
		Else
			lRet := .F.
			aError := oMdl934:GetErrorMessage()
		EndIf
		oMdl934:Destroy()	
	Else
		aError := oMdl934:GetErrorMessage()
		lRet := .F.
	EndIf	
EndIf	

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} 	At934aMark()

@author Matheus Lando Raimundo
@return 
/*/
//--------------------------------------------------------------------
Function At934aMark(xValue)

If xValue
	nTotMark := nTotMark + 1 
Else
	nTotMark := nTotMark - 1
EndIf 
Return .T. 


//--------------------------------------------------------------------
/*/{Protheus.doc}At934aLdCN()

@author Matheus Lando Raimundo
@return 
/*/
//--------------------------------------------------------------------
Function At934aLdCN(oView, lAutomato)
Local oModel := FwModelActive()
Local cCompetencia := oModel:GetValue('ZZZMASTER','ZZZ_COMPET')
Local cCompAnt	:= ""
Local cOperac := oModel:GetValue('ZZZMASTER','ZZZ_OPERAC')
Local nMes	  := 0
Local nAno	  := 0
Local dCompet := 0
Default lAutomato := .F.
If !Empty(cCompetencia) .And. !Empty(cOperac)
	dCompet := CTOD("01/"+cCompetencia)
	dCompet := MonthSub(dCompet,1)
		
	nAno := Year(dCompet)
	nMes := Month(dCompet)
			
	cCompAnt :=  StrZero(nMes,2) + '/' + Alltrim(Str(nAno)) 		
	oModel:GetModel('ZZZMASTER'):LoadValue('ZZZ_COMPANT',cCompAnt)
	
	If lAutomato
		At934ALoad( oView, cCompetencia, cCompAnt, lAutomato)
	Else
		Processa({|| At934ALoad( oView, cCompetencia, cCompAnt, lAutomato), STR0022}) //"Pesquisando contratos..."
	EndIf
EndIf	

Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc}A934aAll()
	Replicar a flag para todas as linhas.
@author Kaique Schiller
@return .T.
/*/
//--------------------------------------------------------------------
Function A934aAll(oCN9Detail)
Local oModel		:= FwModelActive()
Local aSaveLines	:= FwSaveRows()
Local nX			:= 0
Local lMark			:= oCN9Detail:GetValue("CN9_MARK")

Default oCN9Detail 	:= oModel:GetModel("CN9DETAIL")

nTotMark := 0

For nX := 1 To oCN9Detail:Length()
	oCN9Detail:Goline(nX)
	If oCN9Detail:SetValue("CN9_MARK",lMark)
		At934aMark(lMark)
	Endif
Next nX

FWRestRows(aSaveLines)

Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc}A93aUltMed()
	Verifica se é a última medição ou apuração dependendo da operação.
@author Kaique Schiller
@return lRet
/*/
//--------------------------------------------------------------------
Function A93aUltMed(cContra,cRev,cMesAno,lContRec)
Local lRet			:= .F.
Local cAliasTemp 	:= GetNextAlias()

Default cContra 	:= ""
Default cRev		:= ""
Default cMesAno 	:= ""
Default lContRec 	:= .F.

If !Empty(cContra) .And. !Empty(cMesAno)

	BeginSQL Alias cAliasTemp
		
		SELECT ABX_MESANO 
			FROM %Table:ABX% ABX
			WHERE ABX_FILIAL 	= %xFilial:ABX%
				AND ABX_CONTRT 	= %Exp:cContra%
				AND ABX_CONREV 	= %Exp:cRev%
				AND ABX_MESANO  = %Exp:cMesAno%				
				
				AND ABX.%NotDel%
		ORDER BY ABX_MESANO
	
	EndSQL
	
	If (cAliasTemp)->(!EOF())
		lRet := .T.
	Endif

	(cAliasTemp)->(DbCloseArea())

Endif

If lRet .And. lContRec
	BeginSQL Alias cAliasTemp
		
		SELECT ABX_MESANO 
			FROM %Table:ABX% ABX
			WHERE ABX_FILIAL 	= %xFilial:ABX%
				AND ABX_CONTRT 	= %Exp:cContra%
				AND ABX_CONREV 	= %Exp:cRev%
				AND ABX.%NotDel%
		ORDER BY ABX_MESANO DESC
	
	EndSQL
	
	If (cAliasTemp)->(!EOF())
		If cMesAno <> (cAliasTemp)->(ABX_MESANO)
			lRet := .F.
		Endif
	Endif
	
	(cAliasTemp)->(DbCloseArea())

Endif

Return lRet
