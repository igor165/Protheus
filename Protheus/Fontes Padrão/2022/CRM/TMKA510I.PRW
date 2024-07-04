#INCLUDE "PROTHEUS.CH"        
#INCLUDE "TMKA510I.CH"

Static nPosFilial := 1           // Armazena a posicao da filial q esta sendo exibida
Static cFilAntBkp	:= cFilAnt

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510iSelGp   บAutorณVendas Clientes   บ Data ณ  26/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona as equipes de atendimento.                    	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Service Desk                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Function Tk510I()
Local lRet := .T.
Local nCount  := 0
Local aAreaSU0 	:= SU0->(GetArea())
Local oModel  := FWModelActive()
Local cString := oModel:GetModel("SUQMASTER"):GetValue("UQ_COMPSU0")  
Local aCols1	:= Tk510IMontCols(cString)   

If Tk510iSelGr(@aCols1)
	cString := ""
	For nCount := 1 To Len(aCols1)
		cString += aCols1[nCount][1]
		If Len(cString) >= 253
			Exit
		EndIf	
	Next nCount
	If !Empty(cString)
		oModel:getmodel("SUQMASTER"):LoadValue("UQ_COMPSU0",cString)
		M->UQ_SELSU0  := STR0011 // "Sim"
	EndIf
EndIf

RestArea(aAreaSU0)
Return lRet     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510IMontColsบAutorณVendas Clientes   บ Data ณ  26/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o Acols.                                          	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Service Desk                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Static Function Tk510IMontCols(cString)  
Local aCols1	:= {} 
Local nCount	:= 0

For nCount := 1 To Len(cString) Step 2
	cCodGrupo := SubStr(cString, nCount, 2)
	
	DbSelectArea("SU0")
	DbSetOrder(1)
	If !Empty(cCodGrupo) .AND. DbSeek(xFilial("SU0")+cCodGrupo)
		aAdd(aCols1, {SU0->U0_CODIGO, SU0->U0_NOME, .F.})
	EndIf
Next nCount

Return aCols1

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510iSelGp   บAutorณVendas Clientes   บ Data ณ  26/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona as equipes de atendimento.                    	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Service Desk                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Function Tk510iSelGr(aCols1)
Local lRet := .F.
Local oDlg
Local oGroup
Local cGroup := Space(TamSX3("U0_CODIGO")[1])
Local oGrpName	
Local cGrpName := Space(TamSx3("U0_NOME")[1]) 
Local oGetDados
Local aHeader1 	:= {} 
Local aSize 	:= {}
Local aObjects 	:= {}
Local aInfo 	:= {}
Local aPosObj 	:= {}	
Local aColsBkp	:= {}

Private cCadastro := ""

Default aCols1	:= {}      

aCols1 		:= aSort(aCols1)  
aColsBkp    := aClone(aCols1)

DEFINE MSDIALOG oDlg FROM 50,003 TO 400,255 TITLE STR0001 OF oMainWnd PIXEL //"Selecionar equipes"

	aSize    		:= MsAdvSize(.T.,.F.,010)
	AAdd( aObjects, { 001, 005, .T., .F. } )   
	AAdd( aObjects, { 001, 002, .T., .F. } ) 	
	AAdd( aObjects, { 001, 005, .T., .F. } )   
	AAdd( aObjects, { 001, 002, .T., .F. } ) 		
	AAdd( aObjects, { 001, 005, .T., .F. } )   
	AAdd( aObjects, { 000, 000, .T., .F. } )   
	aAdd( aObjects, { 120, 100, .F., .F. } )
	AAdd( aObjects, { 001, 002, .T., .F. } )   
	AAdd( aObjects, { 001, 005, .T., .F. } )   	
	aInfo 			:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
	aPosObj		:= MsObjSize( aInfo, aObjects )

	@ aPosObj[1,1],aPosObj[1,2]  	SAY STR0002 PIXEL SIZE 55,9 OF oDlg //"Equipe"
	@ aPosObj[1,1],aPosObj[1,2]+45 MSGET oGroup Var cGroup SIZE 55,9 PICTURE PesqPict("SU0", "U0_CODIGO") OF oDlg Pixel F3 "SU0" VALID Tk510IGetGpName(cGroup, @cGrpName, oDlg)
	@ aPosObj[3,1],aPosObj[3,2]  	SAY STR0003 PIXEL SIZE 55,9 OF oDlg //"Nome"
	@ aPosObj[3,1],aPosObj[3,2]+45 MSGET oGrpName Var cGrpName SIZE 55,9 PICTURE PesqPict("SU0", "U0_NOME") OF oDlg Pixel When .F.
	
	//AADD(Self:aHeaderADE,{"","CHECKBOX","@BMP",20,00,,,"C",,"V","",,".T."} )
	
	DbSelectArea( "SX3" )
	DbSetOrder( 2 ) //X3_CAMPO             
	DbSeek( "U0_CODIGO" )       
	Aadd(aHeader1,{ 	STR0004	,;	//1 //"Equipe"
				SX3->X3_CAMPO		,;	//2
				SX3->X3_PICTURE		,;	//3
				SX3->X3_TAMANHO		,;	//4
				SX3->X3_DECIMAL		,;	//5
				SX3->X3_VALID		,;	//6	
				SX3->X3_USADO		,;	//7
				SX3->X3_TIPO		,;	//8
				SX3->X3_ARQUIVO		,;	//9
				SX3->X3_CONTEXT		,;	//10
				X3CBox()			,;	//11		
				""					,;	//12
				".T." } )				//13	
	
	DbSeek( "U0_NOME" )       
	Aadd(aHeader1,{ 	STR0005	,;	//1 //"Nome"
				SX3->X3_CAMPO		,;	//2
				SX3->X3_PICTURE		,;	//3
				SX3->X3_TAMANHO		,;	//4
				SX3->X3_DECIMAL		,;	//5
				SX3->X3_VALID		,;	//6	
				SX3->X3_USADO		,;	//7
				SX3->X3_TIPO		,;	//8
				SX3->X3_ARQUIVO		,;	//9
				SX3->X3_CONTEXT		,;	//10
				X3CBox()			,;	//11		
				""					,;	//12
				".T." } )				//13
    
	@ aPosObj[5,1],aPosObj[5,2]	 	BUTTON STR0006	SIZE 40,12 OF oDlg PIXEL ACTION (Tk510IInclui(@cGroup, @cGrpName, aCols1, oGetDados)) //"Incluir"
	@ aPosObj[5,1],aPosObj[5,2]+45	 	BUTTON STR0007	SIZE 40,12 OF oDlg PIXEL ACTION (Tk510IExclui(aCols1, oGetDados:NAT, oGetDados))	//"Apagar"

	oGetDados := MsNewGetDados():New(	aPosObj[7,1]+15, aPosObj[7,2], aPosObj[7,3], aPosObj[7,4], ;
										0, /*"Tk510ALinOk"*/, /*"Tk510ATudOk"*/,,,,100,,,,oDlg, aHeader1/*Self:aHeaderADE*/, /*Self:aColsADE*/aCols1)	

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| (lRet:= .T.,oDlg:End())}, {|| (lRet:= .F.,oDlg:End()) },,,,,,,.F. )

If !lRet
	aCols1 := aClone(aColsBkp)
EndIf  

Return lRet   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510GetGpNameบAutorณVendas Clientes   บ Data ณ  26/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o codigo do grupo digitado pelo usuario.         	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Function Tk510IGetGpName(cGroup, cGrpName, oDlg)
Local lRet 		:= .F.	 
Local aAreaSU0 	:= SU0->(GetArea())

DbSelectArea("SU0")
DbSetOrder(1)
If !Empty(cGroup)
	If ExistCpo("SU0", cGroup) .AND. DbSeek(xFilial("SU0")+cGroup)
		cGrpName := SU0->U0_NOME
		lRet := .T.             
	EndIf
Else
	lRet := .T.
EndIf
RestArea(aAreaSU0)
Return lRet          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510IInclui  บAutorณVendas Clientes   บ Data ณ  26/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Insere um novo elemento no vetor.                       	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Static Function Tk510IInclui(cCodGrupo, cNomeGrupo, aCols1, oGetDados, oGetDadosInfo, aColsInfoFil, aColsInfo)
Local lEmpty := .T.

Default aColsInfoFil := {}

If !Empty(cCodGrupo)
	If Len(aCols1)>=1 .AND. !Empty(aCols1[1,1])
		lEmpty := .F.
	EndIf
	If aScan(aCols1, {|x|x[1]==cCodGrupo}) <= 0
		aAdd(aCols1, {cCodGrupo, cNomeGrupo, .F.})
		//aCols1 := aSort(aCols1)
		oGetDados:SetArray(aCols1, .F.)
		oGetDados:ForceRefresh() 
		If Len(aColsInfoFil)>= 1
			If lEmpty
				aColsInfoFil := {}
			Else   
				aColsInfoFil[1] := oGetDadosInfo:aCols
			EndIf		         
			nPosFilial := Len(aCols1)    
			oGetDados:nAt :=   nPosFilial             
			aAdd(aColsInfoFil, Tk510FillInfo(cCodGrupo, aColsInfo))		
			oGetDadosInfo:SetArray(aColsInfoFil[Len(aColsInfoFil)], .F.)
			oGetDadosInfo:ForceRefresh()			
		EndIf
	EndIf
	cCodGrupo 	:= Space(TamSX3("U0_CODIGO")[1])
	cNomeGrupo 	:= Space(TamSx3("U0_NOME")[1]) 
EndIf
Return .T.      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |Tk510IExclui  บAutorณVendas Clientes   บ Data ณ  26/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ elimina um elemento no vetor.  	                     	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function Tk510IExclui(aCols1, Linha, oGetDados, oGetDadosInfo, aColsInfoFil, aColsInfo)
        
Default aColsInfoFil := {}

If Len(aCols1) >= Linha 
	If TmkOK(STR0010 + AllTrim(aCols1[Linha][2]) + "?") //"Confirmar a exclusใo da Equipe "
		aCols1 := aDel(aCols1, Linha)  
		aCols1 := aSize(aCols1, Len(aCols1)-1) 
		//aCols1 := aSort(aCols1)
		oGetDados:SetArray(aCols1, .F.)
		oGetDados:ForceRefresh()	
		If Len(aColsInfoFil)>=1		
			aColsInfoFil := aDel(aColsInfoFil, Linha)  
			aColsInfoFil := aSize(aColsInfoFil, Len(aColsInfoFil)-1)
			If Len(aColsInfoFil)<=0      
				aAdd(aColsInfoFil, aColsInfo)
			EndIf       
			oGetDados:nAt := 1
			oGetDadosInfo:SetArray(aColsInfoFil[1], .F.)
			oGetDadosInfo:ForceRefresh()  
			If Len(aCols1) >= 1			
				Tk510SetBranch(oGetDados:aCols[1,1])
			EndIf
		EndIf
	EndIf
EndIf
Return .T.          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |Tk510IComp    บAutorณVendas Clientes   บ Data ณ  27/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria as replicas do chamado para as แreas selecionadas 	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function Tk510IComp(cText)       
Local cString 	:= SUQ->UQ_COMPSU0   
Local aCols1	:= Tk510IMontCols(cString)  
Local nCount 	:= 0 
Local lContinua := .F.
Local lOk		:= .F. 
Local cCodChama := ""  
Local aAreaADF	:= ADF->(GetArea())  
Local cCODSU9	:= ""
Local cCODSUQ	:= ""
Local cCodSUO	:= ADE->ADE_CODCAM
Local cCodSB1	:= ADE->ADE_CODSB1
Local cCodCat	:= ADE->ADE_CODCAT
Local cCodOri	:= ADE->ADE_CODORI
Local cCodCau	:= ADE->ADE_CODCAU
Local cCodEfe	:= ADE->ADE_CODEFE
Local cMemo		:= ""
Local cAssunt	:= ADE->ADE_ASSUNT
Local cRegSLA	:= ADE->ADE_REGSLA
Local aColsInfo := {}
Local aHeaderInfo := {}

Default cText := ""

cText += CRLF

cMemo	:= MSMM(ADF->ADF_CODOBS,TamSx3("ADF_OBS")[1])

DbSelectArea("ADF")
DbSetOrder(1)
If DbSeek( xFilial("ADF") + ADE->ADE_CODIGO )
	cCODSU9	:= ADF->ADF_CODSU9
	cCODSUQ	:= ADF->ADF_CODSUQ

EndIf
RestArea(aAreaADF)	

If SUQ->UQ_COMPART $ "1/3"
	
	While !lOk

		lContinua := Tk510iSel2Gr(@aCols1, @cAssunt, @cCODSU9, @cCODSUQ, @cMemo, @cCodSUO, @cCodSB1, @cCodCat, @cCodOri, @cCodCau, @cCodEfe, @aHeaderInfo, @aColsInfo)
	
		If lContinua 
			For nCount := 1 To Len(aCols1)    		
				cCodChama := Tk510CriaReplica(aCols1[nCount][1], aHeaderInfo, aColsInfo[nCount], cRegSLA)
				cText += STR0012 + AllTrim(cCodChama) + STR0013 + AllTrim(aCols1[nCount][2]) + CRLF //"- Foi criado o chamado: " # " para equipe "
			Next nCount
		EndIf 
		
		//Fica em loop ate o usuario cancelar ou a replica ser gerada corretamente
		If !lContinua .OR. (lContinua .AND. !Empty(cCodChama))
			lOk := .T.
		EndIf
		
	End

EndIf

Return Nil               

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |Tk510IValid   บAutorณVendas Clientes   บ Data ณ  27/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se as equipes que receberao os chamado suportam o   บฑฑ
ฑฑบ          ณAssunto selecionado.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function Tk510IValid(cCodEquipe, cAssunt) 
Local lFind  := .F.
Local aAreaSKK := SKK->(GetArea())

DbSelectArea("SKK")
DbSetOrder(1)

lFind  := .F.
SKK->( DbGoTop() )       
If DbSeek(xFilial("SKK") + cCodEquipe)
	While 	SKK->(!EOF()) .AND.;
			SKK->KK_CODSU0 == cCodEquipe
		
		If SKK->KK_CODSKQ == cAssunt
			lFind := .T.  				
			Exit
		EndIf			
		SKK->(DbSkip())
	End	
EndIf  

RestArea(aAreaSKK)
Return lFind 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |Tk510IComp    บAutorณVendas Clientes   บ Data ณ  27/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria as replicas do chamado                            	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function Tk510CriaReplica(cCodGrupo, aHeaderInfo, aColsInfo, cRegSLA)

Local aCabec	:= {}  								// Cabe็alho da rotina automแtica
Local aLinha	:= {}								// Linhas da rotina automแtica
Local cField	:= ""								// Temporแrio para armazenamento de nome de campo
Local aAreaSX3	:= SX3->(GetArea())				// Salva a แrea do SX3
Local aAreaADE	:= ADE->(GetArea())				// Salva a แrea do ADE
Local aAreaADF	:= ADF->(GetArea())				// Salva a แrea do ADF
Local aAreaSUQ	:= SUQ->(GetArea())				// Salva a แrea do SUQ
Local codChama	:= ""								// C๓digo do chamado criado
Local nCount	:= 1								// Contador temporแrio
Local aCampos	:= {}								// Campos utilizados na c๓pia de SLA
Local lMV_TMKRSL:= GetNewPar("MV_TMKRSL", .F.)		// Parโmetro que define se o chamado replicado (filho) terแ o mesmo SLA do chamado de origem (pai)
Local lTK510IREPL := ExistBlock("TK510IREPL")  		// Ponto de Entrada executado apos a gravacao do chamado filho
Local cChamaOrig  := ADE->ADE_CODIGO				// Armazena o c๓digo do chamado original, a ser enviado pelo P.E.
Local cADECampos  := ""
Local cADFCampos  := ""
Local nI		  := 0
Local cFilAntBkp  := cFilAnt
Local cFilGrupo   := cFilAnt
Local lIncSK5	  := .T.
Local cNovoSLA	  := ""  
Local nTamItem    := TamSX3("K5_ITEM")[1] 			// Tamanho do campo Item 

Private lMsErroAuto := .F.

For nI := 1 To Len(aHeaderInfo)
	If "ADE" $ AllTrim(aHeaderInfo[nI, 2])
		cADECampos += AllTrim(aHeaderInfo[nI, 2]) + "|"
	EndIf
	If "ADF" $ AllTrim(aHeaderInfo[nI, 2])
		cADFCampos += AllTrim(aHeaderInfo[nI, 2]) + "|"
	EndIf
Next nI   

cADECampos += "ADE_CODIGO|ADE_STATUS|ADE_REGSLA|ADE_CODINC|ADE_CODDEC|ADE_OPEUSO|ADE_SECUSO|ADE_CHORIG|ADE_OPERAD|ADE_GRUPO"
cADFCampos += "ADF_CODIGO|ADF_OBS|ADF_ITEM|ADF_DATA|ADF_HORA|ADF_HORAF"
        
DbSelectArea("SU0")
DbSetOrder(1)
If DbSeek( xFilial("SU0")+cCodGrupo) 
		
	If !Empty(SU0->U0_FILORI) .AND. !Empty(SU0->U0_GRPORI)
		cFilGrupo 	:= SU0->U0_FILORI 
		cCodGrupo	:= SU0->U0_GRPORI
	EndIf
EndIf	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta cabe็alhoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SX3")
DbSetOrder(1)
If DbSeek("ADE")
	While 	SX3->(!EOF()) .AND.; 
			SX3->X3_ARQUIVO == "ADE"

	   	If SX3->X3_CONTEXT <> "V" .AND. !(AllTrim(SX3->X3_CAMPO) $ cADECampos)
	   		cField := "ADE->" + SX3->X3_CAMPO
	   		aAdd(aCabec, {SX3->X3_CAMPO, &cField, Nil}) 	   	
	   	EndIf		   
		SX3->(DbSkip())
	End	   	
EndIf      
aAdd(aCabec,	{"ADE_INCIDE" 	,MSMM(ADE->ADE_CODINC,TamSx3("ADE_INCIDE")[1])	,Nil})
aAdd(aCabec,	{"ADE_STATUS" 	,"1"											,Nil})
aAdd(aCabec,	{"ADE_OPERAD" 	,""												,Nil})
aAdd(aCabec,	{"ADE_GRUPO" 	,cCodGrupo										,Nil}) 
aAdd(aCabec,	{"ADE_CHORIG" 	,ADE->ADE_CODIGO								,Nil}) 
aAdd(aCabec,	{"ADE_FILORI" 	,cFilAnt										,Nil}) 
For nI := 1 To Len(aHeaderInfo)
	If "ADE" $ AllTrim(aHeaderInfo[nI, 2])
		aAdd(aCabec, {AllTrim(aHeaderInfo[nI, 2]), aColsInfo[1, nI], Nil}) 	   
	EndIf
Next nI   

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ	Monta os itens do chamado com a 	|
//|primeira linha do chamado original   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("ADF")
DbSetOrder(1)
If DbSeek(xFilial("ADF") + ADE->ADE_CODIGO)
	DbSelectArea("SX3")
	DbSetOrder(1)
	If DbSeek("ADF")
		While 	SX3->(!EOF()) .AND.; 
				SX3->X3_ARQUIVO == "ADF"
	
		   	If SX3->X3_CONTEXT <> "V" .AND. !(SX3->X3_CAMPO $ cADFCampos)
		   		cField := "ADF->" + SX3->X3_CAMPO
		   		aAdd(aLinha, {SX3->X3_CAMPO, &cField, Nil}) 	   	
		   	EndIf		   
			SX3->(DbSkip())
		End	   
		aAdd(aLinha,	{"ADF_ITEM" 	,"001"											,Nil})	
		aAdd(aLinha,	{"ADF_CODSU7"	,TkOperador()									,Nil})	
		aAdd(aLinha,	{"ADF_DATA" 	,dDataBase										,Nil})	
		aAdd(aLinha,	{"ADF_HORA" 	,TIME()											,Nil})	
		aAdd(aLinha,	{"ADF_HORAF" 	,TIME()											,Nil})	
		aAdd(aLinha,	{"ADF_FILORI" 	,cFilAnt										,Nil}) 

		For nI := 1 To Len(aHeaderInfo)
			If "ADF" $ AllTrim(aHeaderInfo[nI, 2])        
				If AllTrim(aHeaderInfo[nI, 2]) == "ADF_CODSUQ"
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณEvita que a rotina entre em Loopณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					DbSelectArea("SUQ") 
					DbSetOrder(1)
					If !Empty(aColsInfo[1, nI]) .AND. DbSeek(xFilial("SUQ")+aColsInfo[1, nI]) .AND. SUQ->UQ_COMPART $ "1|3"
						aAdd(aLinha, {AllTrim(aHeaderInfo[nI, 2]), "", Nil}) 	   
					Else
						aAdd(aLinha, {AllTrim(aHeaderInfo[nI, 2]), aColsInfo[1, nI], Nil}) 	   
					EndIf							
				Else 
					aAdd(aLinha, {AllTrim(aHeaderInfo[nI, 2]), aColsInfo[1, nI], Nil}) 	   
				EndIf
			EndIf
		Next nI   				
	EndIf
EndIf   
               
cFilAnt := cFilGrupo
TMKA503A(aCabec,{aLinha},3, @codChama)
cFilAnt := cFilAntBkp

If lMsErroAuto .OR. Empty(codChama)  
	If lMsErroAuto
		MostraErro() 
	EndIf
	codChama := ""			
Else
	
	RecLock("ADF", .F.)	
	ADF->ADF_FILORI := cFilAnt
	ADF->(MsUnLock())
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe o parโmetro MV_TMKRSL estiver verdadeiro.      ณ
	//ณO chamado pai terแ seu SLA replicado para o filho.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lMV_TMKRSL
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณProcura o registro SLA do chamado pai.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("SK5")
		DbSetOrder(1)
		If DbSeek( xFilial("SK5") + cRegSLA )
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAcha o ๚ltimo registro SLA do pai.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			While	!SK5->(EOF())					.And.;
					K5_FILIAL == xFilial("SK5")		.And.;
					K5_CODIGO == cRegSLA
				SK5->(DbSkip())  
			End
			SK5->(DbSkip(-1))
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณFaz o cache das informa็๕es do registro SLA.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			For nCount := 1 To SK5->(FCount())
				If !(SK5->(FielDName(nCount)) $ "K5_FILIAL|K5_CODIGO|K5_ITEM")
					aAdd(aCampos, {nCount, SK5->(FieldGet(nCount))})
				EndIf
			Next
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณProcura o registro SLA do chamado filho.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cFilAnt := cFilGrupo
			
			DbSelectArea("ADE")
			DbSetOrder(1)
			DbSeek(xFilial("ADE") + codChama )
			
			DbSelectArea("SK5")
			DbSetOrder(1)
			If DbSeek( xFilial("SK5") + ADE->ADE_REGSLA )
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณAcha o ๚ltimo registro SLA do filho.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				While	!SK5->(EOF())					.And.;
						K5_FILIAL == xFilial("SK5")		.And.;
						K5_CODIGO == ADE->ADE_REGSLA
					SK5->(DbSkip())  
				End
				SK5->(DbSkip(-1))
				
				lIncSK5 := .F.
				
			EndIf
			
			If lIncSK5
				cNovoSLA := TkNumero("SK5", "K5_CODIGO")	
			EndIf
						
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณGrava as informa็๕es do registro do SLA pai no SLA filho.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			RecLock("SK5", lIncSK5)
			For nCount := 1 To Len(aCampos)
				SK5->(FieldPut(aCampos[nCount,1], aCampos[nCount,2]))
			Next
			
			If lIncSK5
				SK5->K5_FILIAL	:= xFilial("SK5")
				SK5->K5_CODIGO	:= cNovoSLA
				SK5->K5_ITEM	:= StrZero(1,nTamItem)
			EndIf
			
			MsUnLock()
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza a data e hora do chamado filho com as informa็๕es ณ
			//ณdo registro SLA.                                           ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			RecLock("ADE", .F.)
			Replace ADE->ADE_REGSLA With SK5->K5_CODIGO
			Replace ADE->ADE_DTEXPI With SK5->K5_DTEXPIR
			Replace ADE->ADE_HREXPI WIth SK5->K5_HREXPIR
			MsUnLock()
				
						
			cFilAnt := cFilAntBkp
		EndIf
	EndIf  
	
	If lTK510IREPL
		ExecBlock("TK510IREPL",.F.,.F., {cChamaOrig, codChama})
	EndIf 
	
EndIf

RestArea(aAreaSX3)
RestArea(aAreaADE)
RestArea(aAreaADF)
RestArea(aAreaSUQ)
Return codChama


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510IExbGr   บAutorณVendas Clientes   บ Data ณ  26/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe os chamados                                       	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Service Desk                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Function Tk510IExbGr(aCols1)
Local lRet := .F.
Local oDlg
Local oGroup
Local cGroup := Space(TamSX3("U0_CODIGO")[1])
Local oGrpName	
Local cGrpName := Space(TamSx3("U0_NOME")[1]) 
Local oGetDados
Local aHeader1 	:= {} 
Local aSize 	:= {}
Local aObjects 	:= {}
Local aInfo 	:= {}
Local aPosObj 	:= {}	

Default aCols1	:= {}      

//aCols1 		:= aSort(aCols1)  

DEFINE MSDIALOG oDlg FROM 50,003 TO 400,320	 TITLE STR0014 PIXEL // "Chamados compartilhados"

	aSize    		:= MsAdvSize(.T.,.F.,010)
	//AAdd( aObjects, { 000, 000, .T., .F. } ) 	
	aAdd( aObjects, { 150, 130, .F., .F. } )
	AAdd( aObjects, { 001, 010, .T., .F. } )   
	AAdd( aObjects, { 001, 005, .T., .F. } )   	
	aInfo 			:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
	aPosObj		:= MsObjSize( aInfo, aObjects )
    	
	DbSelectArea( "SX3" )	
	DbSetOrder( 2 ) //X3_CAMPO  	
	SX3->(DbGoTop())
	DbSeek( "U0_NOME" )       
	Aadd(aHeader1,{ 	STR0004	,;	//1 //"Nome"
				SX3->X3_CAMPO		,;	//2
				SX3->X3_PICTURE		,;	//3
				SX3->X3_TAMANHO		,;	//4
				SX3->X3_DECIMAL		,;	//5
				SX3->X3_VALID		,;	//6	
				SX3->X3_USADO		,;	//7
				SX3->X3_TIPO		,;	//8
				SX3->X3_ARQUIVO		,;	//9
				SX3->X3_CONTEXT		,;	//10
				X3CBox()			,;	//11		
				""					,;	//12
				".T." } )				//13

	DbSelectArea( "SX3" )
	DbSetOrder( 2 ) //X3_CAMPO 
	SX3->(DbGoTop())            
	DbSeek( "ADE_CODIGO" )       
	Aadd(aHeader1,{ 	AllTrim(X3Titulo())	,;	//1 
				SX3->X3_CAMPO		,;	//2
				SX3->X3_PICTURE		,;	//3
				SX3->X3_TAMANHO		,;	//4
				SX3->X3_DECIMAL		,;	//5
				SX3->X3_VALID		,;	//6	
				SX3->X3_USADO		,;	//7
				SX3->X3_TIPO		,;	//8
				SX3->X3_ARQUIVO		,;	//9
				SX3->X3_CONTEXT		,;	//10
				X3CBox()			,;	//11		
				""					,;	//12
				".T." } )				//13	
				
	DbSelectArea( "SX3" )
	DbSetOrder( 2 ) //X3_CAMPO 
	SX3->(DbGoTop())            
	DbSeek( "ADE_STATUS" )       
	Aadd(aHeader1,{		AllTrim(X3Titulo()) ,;	//1 
				SX3->X3_CAMPO		,;	//2
				SX3->X3_PICTURE		,;	//3
				SX3->X3_TAMANHO		,;	//4
				SX3->X3_DECIMAL		,;	//5
				SX3->X3_VALID		,;	//6	
				SX3->X3_USADO		,;	//7
				SX3->X3_TIPO		,;	//8
				SX3->X3_ARQUIVO		,;	//9
				SX3->X3_CONTEXT		,;	//10
				X3CBox()			,;	//11		
				""					,;	//12
				".T." } )				//13					
    
	oGetDados := MsNewGetDados():New(	aPosObj[1,1]+15, aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], ;
										0, /*"Tk510ALinOk"*/, /*"Tk510ATudOk"*/,,,,100,,,,oDlg, aHeader1/*Self:aHeaderADE*/, /*Self:aColsADE*/aCols1)	
	

	@ aPosObj[3,1],aPosObj[3,2]+100	 	BUTTON STR0008				SIZE 40,12 OF oDlg PIXEL ACTION (lRet:= .T.,oDlg:End()) //"OK"


ACTIVATE MSDIALOG oDlg CENTERED


Return lRet  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510IConGr   บAutorณVendas Clientes   บ Data ณ  26/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe os chamados compartilhados.                       	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Service Desk                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Function Tk510IConGr() 
Local aAreaADE := ADE->(GetArea())
Local aCols1 := {}  
Local cNumAtend := M->ADE_CODIGO
Local cNomeEquipe := ""  
Local aCBoxOption	:= TkSx3Box("ADE_STATUS")
Local cNomeStatus := ""

DbSelectArea("ADE")
DbSetOrder(21) // ADE_FILIAL + ADE_CHORIG
If DbSeek( xFilial("ADE")+cNumAtend )  
	While ADE->(!EOF()) .AND.;
		ADE->ADE_CHORIG == cNumAtend
		
		cNomeEquipe := Posicione("SU0", 1, xFilial("SU0")+ADE->ADE_GRUPO, "U0_NOME")
		cNomeStatus := ""
		If Val(ADE->ADE_STATUS) <= Len(aCBoxOption) 
			cNomeStatus := aCBoxOption[Val(ADE->ADE_STATUS)]
		EndIf
	
		aAdd(aCols1, {cNomeEquipe, ADE->ADE_CODIGO, cNomeStatus, .F.})	
		ADE->(DbSkip())
	End
EndIf   

DbSelectArea("SIX")
DbSetOrder(1) //INDICE+ORDEM  

DbSelectArea("SM0")
DbSetOrder(1)
DbSeek(cEmpAnt)

While SM0->(!Eof()) .AND. SM0->M0_CODIGO == cEmpAnt
	If SM0->M0_CODFIL <> cFilAnt
		If SIX->(DbSeek("ADEM"))
			If AllTrim(Upper(SIX->CHAVE)) == "ADE_FILIAL+ADE_FILORI+ADE_CHORIG"
				DbSelectArea("ADE")
				DbSetOrder(22) // ADE_FILIAL+ADE_FILORI+ADE_CHORIG  
				If ADE->(DbSeek(SM0->M0_CODFIL+xFilial("ADE")+cNumAtend))
					While ADE->(!EOF()) .AND. ADE->ADE_CHORIG == cNumAtend .AND. ADE->ADE_FILORI == xFilial("ADE")
						cNomeEquipe := Posicione("SU0", 1, SM0->M0_CODFIL+ADE->ADE_GRUPO, "U0_NOME")
						cNomeStatus := ""
						If Val(ADE->ADE_STATUS) <= Len(aCBoxOption) 
							cNomeStatus := aCBoxOption[Val(ADE->ADE_STATUS)]
						EndIf					
						aAdd(aCols1, {cNomeEquipe, ADE->ADE_CODIGO, cNomeStatus, .F.})
						ADE->(DbSkip())
					End
				EndIf
			EndIf
		EndIf
	EndIf
	SM0->(DbSkip())
End

If Len(aCols1) <= 0 
	aAdd(aCols1, {"", "", "", .F.})	
EndIf
Tk510IExbGr(aCols1)

RestArea(aAreaADE)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510iSel2Gp  บAutorณVendas Clientes   บ Data ณ  26/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona as equipes de atendimento.                    	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Service Desk                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Function Tk510iSel2Gr(	aCols1, 	cAssunto, 	cCODSU9, 	cCODSUQ, 	cMemo,; 
						cCodSUO, 	cCodSB1, 	cCodCat, 	cCodOri, 	cCodCau,; 
						cCodEfe, 	aHeaderInfo,aColsInfoFil)
Local lRet := .F.
Local oDlg
Local oGroup
Local cGroup := Space(TamSX3("U0_CODIGO")[1])
Local oGrpName	
Local cGrpName := Space(TamSx3("U0_NOME")[1]) 
Local oGetDados       
Local oGetDadosInfo
Local aHeader1 	:= {} 
Local aSize 	:= {}
Local aObjects 	:= {}
Local aInfo 	:= {}
Local aPosObj 	:= {}	
Local aColsBkp	:= {}      
Local cAssuntoOrg	:= cAssunto
Local cCODSU9Org	:= cCODSU9
Local cCODSUQOrg	:= cCODSUQ 
Local cCodSUOOrg	:= cCodSUO
Local cCodSB1Org	:= cCodSB1
Local cCodCatOrg	:= cCodCat
Local cCodOriOrg	:= cCodOri
Local cCodCauOrg	:= cCodCau
Local cCodEfeOrg	:= cCodEfe 
Local oTodos
Local lTodos		:= .F.
Local aColsInfo		:= {}
Local nRetorno      := 0
Local nI			:= 0    
Local lTK510ICPO	:= ExistBlock("TK510ICPO")	// Ponto de Entrada para inclusao de novos campos no get dados do novo chamado
Local cGrupoBkp		:= cCodSUO

Default aCols1	:= {}  
Default aHeaderInfo	:= {}
Default aColsInfoFil  := {}             

aCols1 		:= aSort(aCols1)  
aColsBkp    := aClone(aCols1) 
aHeaderInfo	:= {} 

Private aColsTk510 := aCols1

RegToMemory("ADE", .F.)
RegToMemory("ADF", .F.) 
ChkFile("SUD")
DbSelectArea("SUD")
RegToMemory("SUD", .F.) 

DEFINE MSDIALOG oDlg FROM 50,003 TO 580,610 TITLE STR0001 PIXEL //"Selecionar equipes"

	aSize    		:= MsAdvSize(.T.,.F.,010)
	AAdd( aObjects, { 001, 005, .T., .F. } )   
	AAdd( aObjects, { 001, 002, .T., .F. } ) 	
	AAdd( aObjects, { 001, 005, .T., .F. } )   
	AAdd( aObjects, { 001, 002, .T., .F. } ) 		
	AAdd( aObjects, { 001, 005, .T., .F. } )   
	AAdd( aObjects, { 000, 000, .T., .F. } )   
	aAdd( aObjects, { 120, 090, .F., .F. } )
	AAdd( aObjects, { 001, 002, .T., .F. } )   
	AAdd( aObjects, { 001, 005, .T., .F. } )   	
	AAdd( aObjects, { 001, 002, .T., .F. } )   
	AAdd( aObjects, { 001, 005, .T., .F. } ) 
	AAdd( aObjects, { 001, 002, .T., .F. } )   
	AAdd( aObjects, { 001, 002, .T., .F. } )   
	AAdd( aObjects, { 000, 000, .T., .F. } ) 
	aAdd( aObjects, { 300, 090, .F., .F. } )
	AAdd( aObjects, { 001, 005, .T., .F. } ) 
	AAdd( aObjects, { 001, 002, .T., .F. } ) 
	
	aInfo 			:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
	aPosObj		:= MsObjSize( aInfo, aObjects )

	@ aPosObj[1,1],aPosObj[1,2]  	SAY STR0002 PIXEL SIZE 55,9 OF oDlg //"Equipe"
	@ aPosObj[1,1],aPosObj[1,2]+45 MSGET oGroup Var cGroup SIZE 55,9 PICTURE PesqPict("SU0", "U0_CODIGO") OF oDlg Pixel F3 "SU0" VALID Tk510IGetGpName(cGroup, @cGrpName, oDlg)
	@ aPosObj[3,1],aPosObj[3,2]  	SAY STR0003 PIXEL SIZE 55,9 OF oDlg //"Nome"
	@ aPosObj[3,1],aPosObj[3,2]+45 MSGET oGrpName Var cGrpName SIZE 55,9 PICTURE PesqPict("SU0", "U0_NOME") OF oDlg Pixel When .F.
	
	DbSelectArea( "SX3" )
	DbSetOrder( 2 ) //X3_CAMPO             
	DbSeek( "U0_CODIGO" )       
	Aadd(aHeader1,{ 	STR0004	,;	//1 //"Equipe"
				SX3->X3_CAMPO		,;	//2
				SX3->X3_PICTURE		,;	//3
				SX3->X3_TAMANHO		,;	//4
				SX3->X3_DECIMAL		,;	//5
				SX3->X3_VALID		,;	//6	
				SX3->X3_USADO		,;	//7
				SX3->X3_TIPO		,;	//8
				SX3->X3_ARQUIVO		,;	//9
				SX3->X3_CONTEXT		,;	//10
				X3CBox()			,;	//11		
				""					,;	//12
				".T." } )				//13	
	
	DbSeek( "U0_NOME" )       
	Aadd(aHeader1,{ 	STR0005	,;	//1 //"Nome"
				SX3->X3_CAMPO		,;	//2
				SX3->X3_PICTURE		,;	//3
				SX3->X3_TAMANHO		,;	//4
				SX3->X3_DECIMAL		,;	//5
				SX3->X3_VALID		,;	//6	
				SX3->X3_USADO		,;	//7
				SX3->X3_TIPO		,;	//8
				SX3->X3_ARQUIVO		,;	//9
				SX3->X3_CONTEXT		,;	//10
				X3CBox()			,;	//11		
				""					,;	//12
				".T." } )				//13
    
	@ aPosObj[5,1],aPosObj[5,2]	 	BUTTON STR0006	SIZE 40,12 OF oDlg PIXEL ACTION (Tk510IInclui(@cGroup, @cGrpName, aColsTk510, oGetDados, oGetDadosInfo, aColsInfoFil, aColsInfo)) //"Incluir"
	@ aPosObj[5,1],aPosObj[5,2]+45	 	BUTTON STR0007	SIZE 40,12 OF oDlg PIXEL ACTION (Tk510IExclui(aColsTk510, oGetDados:NAT, oGetDados, oGetDadosInfo, aColsInfoFil, aColsInfo))	//"Apagar"

	oGetDados := MsNewGetDados():New(	aPosObj[7,1]+15, aPosObj[7,2], aPosObj[7,3], aPosObj[7,4], ;
										0, /*"Tk510ALinOk"*/, /*"Tk510ATudOk"*/,,,,100,,,,oDlg, aHeader1/*Self:aHeaderADE*/, /*Self:aColsADE*/aColsTk510)	
	oGetDados:bChange := {|| Tk510ChgFilial(oGetDados, oGetDadosInfo, @aColsInfoFil)}
	
	//@ aPosObj[9,1],aPosObj[9,2] CheckBox oTodos Var lTodos Size 130,9 Pixel Of oDlg Prompt "Aplicar a todos os chamados da mesma filial" /*On Change Tk040Tools(1, oFiliais, lTodos)*/ //"Marca e Desmarca Todos"
	
	@ aPosObj[13,1]-30,aPosObj[13,2]  	SAY STR0031 PIXEL SIZE 100,9 OF oDlg //"Informa็๕es do(s) novo(s) chamado(s):"	
                 
	DbSelectArea( "SX3" )
	DbSetOrder( 2 ) //X3_CAMPO             
	DbSeek( "ADE_ASSUNT" )       
	Aadd(aHeaderInfo,{ 	X3TITULO()	,;	//1 //"Equipe"
				SX3->X3_CAMPO		,;	//2
				SX3->X3_PICTURE		,;	//3
				SX3->X3_TAMANHO		,;	//4
				SX3->X3_DECIMAL		,;	//5
				SX3->X3_VALID		,;	//6	
				SX3->X3_USADO		,;	//7
				SX3->X3_TIPO		,;	//8
				SX3->X3_F3			,;	//9
				SX3->X3_CONTEXT		,;	//10
				X3CBox()			,;	//11		
				""					,;	//12
				".T." } )				//13	  

	aAdd(aColsInfo, cAssunto)				
				
	DbSelectArea( "SX3" )
	DbSetOrder( 2 ) //X3_CAMPO             
	DbSeek( "ADF_CODSU9" )       
	Aadd(aHeaderInfo,{ 	X3TITULO()	,;	//1 //"Equipe"
				SX3->X3_CAMPO		,;	//2
				SX3->X3_PICTURE		,;	//3
				SX3->X3_TAMANHO		,;	//4
				SX3->X3_DECIMAL		,;	//5
				SX3->X3_VALID		,;	//6	
				SX3->X3_USADO		,;	//7
				SX3->X3_TIPO		,;	//8
				SX3->X3_F3			,;	//9
				SX3->X3_CONTEXT		,;	//10
				X3CBox()			,;	//11		
				""					,;	//12
				".T." } )				//13					

	aAdd(aColsInfo, cCODSU9)				
	
	DbSelectArea( "SX3" )
	DbSetOrder( 2 ) //X3_CAMPO             
	DbSeek( "ADF_NMSU9" )       
	Aadd(aHeaderInfo,{ 	X3TITULO()	,;	//1 //"Equipe"
				SX3->X3_CAMPO		,;	//2
				SX3->X3_PICTURE		,;	//3
				SX3->X3_TAMANHO		,;	//4
				SX3->X3_DECIMAL		,;	//5
				SX3->X3_VALID		,;	//6	
				SX3->X3_USADO		,;	//7
				SX3->X3_TIPO		,;	//8
				SX3->X3_F3			,;	//9
				SX3->X3_CONTEXT		,;	//10
				X3CBox()			,;	//11		
				""					,;	//12
				".T." } )				//13					

	aAdd(aColsInfo, POSICIONE("SU9", 2, xFilial("SU9")+cCODSU9,"U9_DESC"))				

	DbSelectArea( "SX3" )
	DbSetOrder( 2 ) //X3_CAMPO             
	DbSeek( "ADF_CODSUQ" )       
	Aadd(aHeaderInfo,{ 	X3TITULO()	,;	//1 //"Equipe"
				SX3->X3_CAMPO		,;	//2
				SX3->X3_PICTURE		,;	//3
				SX3->X3_TAMANHO		,;	//4
				SX3->X3_DECIMAL		,;	//5
				SX3->X3_VALID		,;	//6	
				SX3->X3_USADO		,;	//7
				SX3->X3_TIPO		,;	//8
				SX3->X3_F3			,;	//9
				SX3->X3_CONTEXT		,;	//10
				X3CBox()			,;	//11		
				""					,;	//12
				".T." } )				//13  

	aAdd(aColsInfo, cCODSUQ)				

	DbSelectArea( "SX3" )
	DbSetOrder( 2 ) //X3_CAMPO             
	DbSeek( "ADF_NMSUQ" )       
	Aadd(aHeaderInfo,{ 	X3TITULO()	,;	//1 //"Equipe"
				SX3->X3_CAMPO		,;	//2
				SX3->X3_PICTURE		,;	//3
				SX3->X3_TAMANHO		,;	//4
				SX3->X3_DECIMAL		,;	//5
				SX3->X3_VALID		,;	//6	
				SX3->X3_USADO		,;	//7
				SX3->X3_TIPO		,;	//8
				SX3->X3_F3			,;	//9
				SX3->X3_CONTEXT		,;	//10
				X3CBox()			,;	//11		
				""					,;	//12
				".T." } )				//13					

	aAdd(aColsInfo, POSICIONE("SUQ", 1, xFilial("SUQ")+cCODSUQ,"UQ_DESC"))				
				
	DbSelectArea( "SX3" )
	DbSetOrder( 2 ) //X3_CAMPO             
	DbSeek( "ADE_CODCAM" )       
	Aadd(aHeaderInfo,{ 	X3TITULO()	,;	//1 //"Equipe"
				SX3->X3_CAMPO		,;	//2
				SX3->X3_PICTURE		,;	//3
				SX3->X3_TAMANHO		,;	//4
				SX3->X3_DECIMAL		,;	//5
				SX3->X3_VALID		,;	//6	
				SX3->X3_USADO		,;	//7
				SX3->X3_TIPO		,;	//8
				SX3->X3_F3			,;	//9
				SX3->X3_CONTEXT		,;	//10
				X3CBox()			,;	//11		
				""					,;	//12
				".T." } )				//13				

	aAdd(aColsInfo, cCodSUO)				
				
	DbSelectArea( "SX3" )
	DbSetOrder( 2 ) //X3_CAMPO             
	DbSeek( "ADE_CODSB1" )       
	Aadd(aHeaderInfo,{ 	X3TITULO()	,;	//1 //"Equipe"
				SX3->X3_CAMPO		,;	//2
				SX3->X3_PICTURE		,;	//3
				SX3->X3_TAMANHO		,;	//4
				SX3->X3_DECIMAL		,;	//5
				SX3->X3_VALID		,;	//6	
				SX3->X3_USADO		,;	//7
				SX3->X3_TIPO		,;	//8
				SX3->X3_F3			,;	//9
				SX3->X3_CONTEXT		,;	//10
				X3CBox()			,;	//11		
				""					,;	//12
				".T." } )				//13

	aAdd(aColsInfo, cCodSB1)				

	DbSeek( "ADE_CODCAT" )       
	Aadd(aHeaderInfo,{ 	X3TITULO()	,;	//1 //"Nome"
				SX3->X3_CAMPO		,;	//2
				SX3->X3_PICTURE		,;	//3
				SX3->X3_TAMANHO		,;	//4
				SX3->X3_DECIMAL		,;	//5
				SX3->X3_VALID		,;	//6	
				SX3->X3_USADO		,;	//7
				SX3->X3_TIPO		,;	//8
				SX3->X3_F3			,;	//9
				SX3->X3_CONTEXT		,;	//10
				X3CBox()			,;	//11		
				""					,;	//12
				".T." } )				//13 

	aAdd(aColsInfo, cCodCat)				
				
	DbSeek( "ADE_CODORI" )       
	Aadd(aHeaderInfo,{ 	X3TITULO()	,;	//1 //"Nome"
				SX3->X3_CAMPO		,;	//2
				SX3->X3_PICTURE		,;	//3
				SX3->X3_TAMANHO		,;	//4
				SX3->X3_DECIMAL		,;	//5
				SX3->X3_VALID		,;	//6	
				SX3->X3_USADO		,;	//7
				SX3->X3_TIPO		,;	//8
				SX3->X3_F3			,;	//9
				SX3->X3_CONTEXT		,;	//10
				X3CBox()			,;	//11		
				""					,;	//12
				".T." } )				//13 

	aAdd(aColsInfo, cCodOri)				
				
	DbSeek( "ADE_CODCAU" )       
	Aadd(aHeaderInfo,{ X3TITULO()	,;	//1 //"Nome"
				SX3->X3_CAMPO		,;	//2
				SX3->X3_PICTURE		,;	//3
				SX3->X3_TAMANHO		,;	//4
				SX3->X3_DECIMAL		,;	//5
				SX3->X3_VALID		,;	//6	
				SX3->X3_USADO		,;	//7
				SX3->X3_TIPO		,;	//8
				SX3->X3_F3			,;	//9
				SX3->X3_CONTEXT		,;	//10
				X3CBox()			,;	//11		
				""					,;	//12
				".T." } )				//13 

	aAdd(aColsInfo, cCodCau)				
				
	DbSeek( "ADE_CODEFE" )       
	Aadd(aHeaderInfo,{ 	X3TITULO()	,;	//1 //"Nome"
				SX3->X3_CAMPO		,;	//2
				SX3->X3_PICTURE		,;	//3
				SX3->X3_TAMANHO		,;	//4
				SX3->X3_DECIMAL		,;	//5
				SX3->X3_VALID		,;	//6	
				SX3->X3_USADO		,;	//7
				SX3->X3_TIPO		,;	//8
				SX3->X3_F3			,;	//9
				SX3->X3_CONTEXT		,;	//10
				X3CBox()			,;	//11		
				""					,;	//12
				".T." } )				//13 
				
	aAdd(aColsInfo, cCodEfe)				

	DbSelectArea( "SX3" )
	DbSetOrder( 2 ) //X3_CAMPO             
	DbSeek( "ADF_OBS" )       
	Aadd(aHeaderInfo,{ 	X3TITULO()	,;	//1 //"Equipe"
				SX3->X3_CAMPO		,;	//2
				SX3->X3_PICTURE		,;	//3
				SX3->X3_TAMANHO		,;	//4
				SX3->X3_DECIMAL		,;	//5
				SX3->X3_VALID		,;	//6	
				SX3->X3_USADO		,;	//7
				SX3->X3_TIPO		,;	//8
				SX3->X3_F3			,;	//9
				SX3->X3_CONTEXT		,;	//10
				X3CBox()			,;	//11		
				""					,;	//12
				".T." } )				//13

	aAdd(aColsInfo, "")				

	If lTK510ICPO
		aRetorno := ExecBlock("TK510ICPO", .F., .F.)
		If Type("aRetorno")=="A"                  
		
			DbSelectArea( "SX3" )
			DbSetOrder( 2 ) //X3_CAMPO             
			For nRetorno:=1 To Len(aRetorno)
				DbSeek( aRetorno[nRetorno,1] )       
				Aadd(aHeaderInfo,{ 	X3TITULO()	,;	//1 //"Equipe"
							SX3->X3_CAMPO		,;	//2
							SX3->X3_PICTURE		,;	//3
							SX3->X3_TAMANHO		,;	//4
							SX3->X3_DECIMAL		,;	//5
							SX3->X3_VALID		,;	//6	
							SX3->X3_USADO		,;	//7
							SX3->X3_TIPO		,;	//8
							SX3->X3_F3			,;	//9
							SX3->X3_CONTEXT		,;	//10
							X3CBox()			,;	//11		
							""					,;	//12
							".T." } )				//13

				aAdd(aColsInfo, aRetorno[nRetorno,2])				

			Next nRetorno	
		EndIf
	EndIf		  
	
	aAdd(aColsInfo, .F.)
	aColsInfo := {aColsInfo}  
	nPosFilial := 1
	
	If Len(aColsTk510)== 0
		aAdd(aColsInfoFil, aColsInfo) 
		aColsInfoFil[1,1,Len(aColsInfoFil[1,1])] := .F.		
	Else
		//Preeenche para todas as equipes
		For nI := 1 To Len(aColsTk510)
		        
			aAdd(aColsInfoFil, Tk510FillInfo(aColsTk510[nI, 1], aColsInfo))
			nPosFilial := nI
			oGetDados:nAt := nI
		Next nI
		
	EndIf			
	
	//Adiciona validacao no assunto para limpar os campos ocorrencia e acao caso haja alteracao
	nI := aScan(aHeaderInfo,{|x| AllTrim(x[2]) == "ADE_ASSUNT"})
	If nI > 0 
		If Len(aHeaderInfo[nI][6]) > 0
			aHeaderInfo[nI][6] += " .AND. Tk510IVAss()"
		Else
			aHeaderInfo[nI][6] += "Tk510IVAss()"
		EndIf
	EndIf

	oGetDadosInfo := MsNewGetDados():New(	aPosObj[15,1]-30, aPosObj[15,2], aPosObj[15,3]-40, aPosObj[15,4], ;
										2, /*"Tk510ALinOk"*/, /*"Tk510ATudOk"*/,,,,100,,,,oDlg, aHeaderInfo/*Self:aHeaderADE*/, /*Self:aColsADE*/aColsInfoFil[nPosFilial])	
	                                     
	oGetDadosInfo:lNewLine := .F.

	@ aPosObj[17,1]-50,aPosObj[17,2]+185	 	BUTTON STR0008				SIZE 40,12 OF oDlg PIXEL ACTION (Tk510ChgFilial(oGetDados, oGetDadosInfo, @aColsInfoFil),If(TK510IObrigat(	aHeader1, aColsTk510, aHeaderInfo, aColsInfoFil, IIf(lTK510ICPO,aRetorno,Nil) ), (lRet:=.T.,oDlg:End()), lRet:=.F.))

	@ aPosObj[17,1]-50,aPosObj[17,2]+230	 	BUTTON STR0009				SIZE 40,12 OF oDlg PIXEL ACTION (lRet:= .F.,oDlg:End())	//"Cancela"	
	
	oGetDados:GoTo(1)
	Tk510ChgFilial(oGetDados, oGetDadosInfo, @aColsInfoFil)

ACTIVATE MSDIALOG oDlg CENTERED

cFilAnt	:= cFilAntBkp
M->ADE_GRUPO := cGrupoBkp

If !lRet
	aCols1 := aClone(aColsBkp)
EndIf  

Return lRet  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510FillInfo บAutorณVendas Clientes   บ Data ณ  26/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida as informacoes para cada grupo a ser compartilhado  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Service Desk                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Static Function Tk510FillInfo(cCodSU0, aColsInfo)
Local aAreaSU0 := SU0->(GetArea())    
Local aColsRet := aClone(aColsInfo)
Local lFind    := .F.

DbSelectArea("SU0")
DbSetOrder(1)
If DbSeek( xFilial("SU0")+cCodSU0) 
	
    Tk510SetBranch(cCodSU0)  
	// Verifica se o assunto ้ atendido pela equipe
	lFind  := Tk510IValid(cCodSU0, aColsRet[1,1]) 
	If !lFind                                 
	    	aColsRet[1,1] := Space(TamSx3("ADE_ASSUNT")[1])	
	EndIf 		
	                                   
	If !lFind .OR. !Empty(SU0->U0_FILORI)
		// Filial diferente  	                           
		
	    If FWModeAccess("SU9",3) == "E"
	    	aColsRet[1,2] = Space(TamSx3("ADF_CODSU9")[1])	
	    	aColsRet[1,3] = Space(TamSx3("ADF_NMSU9")[1])	    	
	    EndIf

	    If FWModeAccess("SUQ",3) == "E"
	    	aColsRet[1,4] = Space(TamSx3("ADF_CODSUQ")[1])	
	    	aColsRet[1,5] = Space(TamSx3("ADF_NMSUQ")[1])	    	
	    EndIf

	    If FWModeAccess("SUO",3) == "E"
	    	aColsRet[1,6] = Space(TamSx3("ADE_CODCAM")[1])	
	    EndIf                               

	    If FWModeAccess("SB1",3) == "E"
	    	aColsRet[1,7] = Space(TamSx3("ADE_CODSB1")[1])	
	    EndIf                               
	    
	    If FWModeAccess("QI0",3) == "E"
	    	aColsRet[1,8] = Space(TamSx3("ADE_CODCAT")[1])	
	    	aColsRet[1,9] = Space(TamSx3("ADE_CODORI")[1])	
	    	aColsRet[1,10] = Space(TamSx3("ADE_CODCAU")[1])	
	    	aColsRet[1,11] = Space(TamSx3("ADE_CODEFE")[1])	
	    EndIf                			    			    

	EndIf
EndIf

RestArea(aAreaSU0)
Return aColsRet     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510ChgFilialบAutorณVendas Clientes   บ Data ณ  26/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida as informacoes para cada grupo a ser compartilhado  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Service Desk                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Static Function Tk510ChgFilial(oGet, oGetInfo, aColsFil)
Local nPos := oGet:nAt

If Len(aColsFil)>= nPos	
	If Len(aColsFil) >= nPosFilial
		aColsFil[nPosFilial] := oGetInfo:aCols	
	EndIf
	nPosFilial := nPos
	oGetInfo:SetArray(aColsFil[nPos], .F.)
	oGetInfo:ForceRefresh() 
	Tk510SetBranch(oGet:aCols[nPos,1])
EndIf          

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510SetBranchบAutorณVendas Clientes   บ Data ณ  26/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define a filial em que as informacoes serao lidas.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Service Desk                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function Tk510SetBranch(cCodGrupo, cGrupoDest)

Local aAreaSU0 := SU0->(GetArea())
        
cFilAnt := cFilAntBkp                  
M->ADE_GRUPO := cCodGrupo  		

DbSelectArea("SU0")
DbSetOrder(1)
If DbSeek( xFilial("SU0")+cCodGrupo)
                                     
	If !Empty(SU0->U0_FILORI) .AND. !Empty(SU0->U0_GRPORI)
	   	cFilAnt := SU0->U0_FILORI
	   	M->ADE_GRUPO := SU0->U0_GRPORI  
	Else		            
		M->ADE_GRUPO := cCodGrupo  		
	EndIf
EndIf
  

cGrupoDest := M->ADE_GRUPO

RestArea(aAreaSU0)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK510IASSU    บAutor  ณVendas CRM      บ Data ณ  07/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta padrao para selecionar o assunto do atendimento.   บฑฑ
ฑฑบ          ณpara as equipes selecionadas.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/    
Function TK510IASSU()
Local oDlgSu9														// Tela
Local oLbx1                                                         // Listbox
Local nPosLbx  := 0                                                 // Posicao do List
Local aItems   := {}                                                // Array com os itens
Local nPos     := 0                                                 // Posicao no array
Local lRet     := .F.                                               // Retorno da funcao
Local cCodSubject := ""		//Codigos de assuntos validos para o atendimento

DbSelectArea("SKK")
DbSetOrder(1)

For nPos := 1 To Len(aColsTk510)
	DbGoTop()
	DbSeek(xFilial("SKK")+aColsTk510[nPos, 1])
	While !EOF() .AND. SKK->KK_CODSU0 == aColsTk510[nPos, 1]
	   	cCodSubject += SKK->KK_CODSKQ + "/"
		DbSkip()
	End         
Next nPos
nPos := 0

DbSelectArea("SKK")
DbCloseArea()      

DbSelectArea("SX5")
DbSetOrder(1)
DbSeek(xFilial("SX5") + "T1")
While !EOF() .AND. SX5->X5_TABELA == "T1"
    If SX5->X5_CHAVE $ cCodSubject
    	aAdd(aItems, {SX5->X5_CHAVE, X5DESCRI()})
    End
	DbSkip()
End
                   
If Len(aItems) > 0 
	DEFINE MSDIALOG oDlgSu9 FROM  50,003 TO 260,500 TITLE STR0001 PIXEL  //"Assuntos"
	
		@ 03,10 LISTBOX oLbx1 VAR nPosLbx FIELDS HEADER ;
				STR0002,;	//"C๓digo"
				STR0003,;	//"Chave"
				SIZE 233,80 OF oDlgSu9 PIXEL NOSCROLL 
		oLbx1:SetArray(aItems)
	    oLbx1:bLine:={||{aItems[oLbx1:nAt,1],;
						 aItems[oLbx1:nAt,2] }}
	
	    oLbx1:BlDblClick := {||(lRet:= .T.,nPos:= oLbx1:nAt, oDlgSu9:End())}
		oLbx1:Refresh()
		
	    DEFINE SBUTTON FROM 88,175 TYPE 1 ENABLE OF oDlgSu9 ACTION (lRet:= .T.,nPos := oLbx1:nAt,oDlgSu9:End())
	    DEFINE SBUTTON FROM 88,210 TYPE 2 ENABLE OF oDlgSu9 ACTION (lRet:= .F.,oDlgSu9:End())
	
	ACTIVATE MSDIALOG oDlgSu9 CENTERED 
Else
	Help(" ",1,"ASSUNTO" )
	lRet := .F.
EndIf

If lRet
	DbSelectArea("SX5")
	DbSetOrder(1)
	lRet := DbSeek(xFilial("SX5") + "T1" + aItems[nPos,1])
EndIf

Return lRet 
     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK510IObrigat บAutorณ Vendas CRM       บ Data ณ  11/05/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica a obrigatoriedade de preenchimento dos campos  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Service Desk                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Static Function TK510IObrigat( aHeaderGroup, aColsGroup, aHeaderInfo, aColsInfo, aCposPE )    

Local lRet		:= .T.				// Retorno da fun็ใo
Local cMsg		:= ""				// Mensagem a ser exibida em caso de erro
Local nCount	:= 0				// Contador temporแrio
Local aCampos	:= {}				// { { Campos, Variแvel } } de verifica็ใo de preenchimento obrigat๓rio 
Local nPosCodGrupo := Ascan(aHeaderGroup,{|aVal| Alltrim(aVal[2])== "U0_CODIGO"})

Local nPosAssunto 	:= Ascan(aHeaderInfo,{|aVal| Alltrim(aVal[2])== "ADE_ASSUNT"})
Local nPosSU9 		:= Ascan(aHeaderInfo,{|aVal| Alltrim(aVal[2])== "ADF_CODSU9"})
Local nPosSUQ 		:= Ascan(aHeaderInfo,{|aVal| Alltrim(aVal[2])== "ADF_CODSUQ"})
Local nPosCAM 		:= Ascan(aHeaderInfo,{|aVal| Alltrim(aVal[2])== "ADE_CODCAM"})
Local nPosSB1 		:= Ascan(aHeaderInfo,{|aVal| Alltrim(aVal[2])== "ADE_CODSB1"})
Local nPosCAT 		:= Ascan(aHeaderInfo,{|aVal| Alltrim(aVal[2])== "ADE_CODCAT"})
Local nPosORI 		:= Ascan(aHeaderInfo,{|aVal| Alltrim(aVal[2])== "ADE_CODORI"})
Local nPosCAU		:= Ascan(aHeaderInfo,{|aVal| Alltrim(aVal[2])== "ADE_CODCAU"})
Local nPosEFE 		:= Ascan(aHeaderInfo,{|aVal| Alltrim(aVal[2])== "ADE_CODEFE"})
Local nGrupos		:= 0
Local cFilAntBk		:= cFilAnt
Local cGrupoDest	:= ""

Local oObj 			:= TeleServiceUserDialog():New()
Local cTeleServID	:= ""
Local nX			:= 0
Local nPosCpoPE		:= 0
Local nPCpo			:= 0

DEFAULT aCposPE		:= {}	//Campos informados no ponto de entrada "TK510ICPO"

cTeleServID := oObj:GetModel(.T.)

If !Empty(cTeleServID)
	If (oObj:service == Nil) .Or. (AllTrim(oObj:service:id) <> AllTrim(cTeleServID))
		oObj:service := TeleServicing():New() 
   		oObj:service:load(cTeleServID)
 	EndIf
EndIf

For nGrupos := 1 To Len(aColsGroup)

	Tk510SetBranch( aColsGroup[nGrupos,1], @cGrupoDest )

	aCampos	:= {	{"ADE_ASSUNT",aColsInfo[nGrupos, 1, nPosAssunto]}	,;
					{"ADF_CODSU9",aColsInfo[nGrupos, 1, nPosSU9]}	,;
					{"ADF_CODSUQ",aColsInfo[nGrupos, 1, nPosSUQ]}	,;
					{"ADE_CODCAM",aColsInfo[nGrupos, 1, nPosCAM]}	,;
					{"ADE_CODSB1",aColsInfo[nGrupos, 1, nPosSB1]}	,;
					{"ADE_CODCAT",aColsInfo[nGrupos, 1, nPosCAT]}	,;
					{"ADE_CODORI",aColsInfo[nGrupos, 1, nPosORI]}	,;
					{"ADE_CODCAU",aColsInfo[nGrupos, 1, nPosCAU]}	,;
					{"ADE_CODEFE",aColsInfo[nGrupos, 1, nPosEFE]}	}
							
	cMsg := STR0032 + AllTrim(Posicione("SU0", 1, xFilial("SU0")+cGrupoDest, "U0_NOME")) + ". " + STR0016 + CRLF	// "Equipe:" # "Os seguintes campos sใo de preenchimento obrigat๓rio:"
	
	If Len(aCposPE) > 0
		For nX := 1 To Len(aCposPE)	
			nPosCpoPE := Ascan(aHeaderInfo,{|aVal| Alltrim(aVal[2])== aCposPE[nX,1]})	
	        If nPosCpoPE > 0
	        	aAdd(aCampos, { aCposPE[nX,1], aColsInfo[nGrupos, 1, nPosCpoPE] })
	        EndIf
	    Next nX
	EndIf
	
	For nCount := 1 To Len( aCampos )
        If Len(oObj:service:tablestructureinfo:master:fields) > 0
			nPCpo := aScan(oObj:service:tablestructureinfo:master:fields,{|x| AllTrim(x:name) == aCampos[nCount][1]})
			If nPCpo > 0 .And.;
				oObj:service:tablestructureinfo:master:fields[nPCpo]:customized .And.;
				oObj:service:tablestructureinfo:master:fields[nPCpo]:required .And.;
				Empty(aCampos[nCount][2])
				DbSelectArea("SX3")
				DbSetOrder(2)
				If DbSeek(aCampos[nCount][1])
					cMsg += " - " + AllTrim(X3Titulo())
				EndIf
				lRet := .F.
			EndIf       
        ElseIf X3Obrigat(aCampos[nCount][1]) .And. Empty(aCampos[nCount][2])
			DbSelectArea("SX3")
			DbSetOrder(2)
			If DbSeek(aCampos[nCount][1])
				cMsg += " - " + AllTrim(X3Titulo())
			EndIf
			lRet := .F.
		EndIf
	Next nCount
	
	If lRet .AND. !Tk510IValid(cGrupoDest, aColsInfo[nGrupos, 1, nPosAssunto]) 
		lRet := .F.
		cMsg := STR0032 + AllTrim(Posicione("SU0", 1, xFilial("SU0")+cGrupoDest, "U0_NOME")) + ". " + STR0033 + 	aColsInfo[nGrupos, 1, nPosAssunto] + STR0034	// "O assunto " # 	" nใo foi encontrado no cadastro de Assuntos x Grupos."
	EndIf
	cMsg += CRLF   		
	//Mostra as falhas de uma equipe por vez
	If !lRet
		exit
	EndIf

Next nGrupos

If !lRet	
	Aviso(STR0015, cMsg, {"OK"}, 2)	// "Aten็ใo"
EndIf     

cFilAnt := cFilAntBK

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510IVAssบAutor  ณVendas CRM          บ Data ณ  29/06/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLimpa a ocorrencia e a acao ao alterar o assunto do chamado บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510I                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk510IVAss()

Local lRet 		:= .T.
Local nPAssunt	:= aScan(aHeader,{|x|AllTrim(x[2]) == "ADE_ASSUNT"})
Local nPOcorr	:= aScan(aHeader,{|x|AllTrim(x[2]) == "ADF_CODSU9"})
Local nPDOcorr	:= aScan(aHeader,{|x|AllTrim(x[2]) == "ADF_NMSU9"})
Local nPAcao	:= aScan(aHeader,{|x|AllTrim(x[2]) == "ADF_CODSUQ"})
Local nPDAcao	:= aScan(aHeader,{|x|AllTrim(x[2]) == "ADF_NMSUQ"})

If aCols[N][nPAssunt] <> M->ADE_ASSUNT  
	aCols[N][nPOcorr]	:= Space(aHeader[nPOcorr][4])
	aCols[N][nPDOcorr]	:= Space(aHeader[nPDOcorr][4])
	aCols[N][nPAcao]	:= Space(aHeader[nPAcao][4])
	aCols[N][nPDAcao]	:= Space(aHeader[nPDAcao][4])
EndIf

Return lRet
