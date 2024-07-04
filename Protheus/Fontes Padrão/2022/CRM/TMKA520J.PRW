#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TMKA520J.CH" 
#DEFINE WFTYPE_INFORMATION 		1
#DEFINE WFTYPE_AUTHORIZATION 	2

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWFTemplate     บAutorณVendas Cliente   บ Data ณ  19/01/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Classe auxiliar utilizado na construcao de um workflow a   บฑฑ 
ฑฑบ          ณpartir de um modelo de workflow.                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿     
*/
Class WFTemplate
Data id
Data htmlFile
Data subject
Data bodyText
Data cbTo
Data cbCC
Data cbCCO   
Data wfType
Data cbWhenReplied
Data oPersist
Data lAttachFile 
Data lSaveFile
Data KnowledgeBase
Data KBName
Data aFilesUp
Data acAnexo
Data acFileName
Data nTotalSize
Data nMaxAttSize
Data lMultiAprov
Data cMultiCon
Data nMultiVal
Data nTimeLim
Data cTimeAnwser

Method New() Constructor
Method Load(id)
Method buildWF()
Method fillFields(oWFInfo)   
Method evalCode(cText)
Method createPersist()
Method setKnowledgeBase()
Method setKBName()
Method saveKnowledgeBase() 
Method changeFile()
Method free()
Method TK520JAdicArq(oListBoxFile, oSayTam)
Method TK520JRemArq(oList, oSayTam)
Method TK520JSendFiles(aWFs)
Method getEMailsTo()   
Method authStatus()
Method getHeadWF()
Method getResume()

EndClass                     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNew          บAutor  ณVendas Cliente   บ Data ณ  19/01/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New() Class WFTemplate     

Self:htmlFile 		:= ""
Self:subject 		:= ""
Self:bodyText 		:= ""
Self:cbTo 			:= ""
Self:cbCC 			:= ""
Self:cbCCO 			:= ""
Self:wfType 		:= "1" 	
Self:cbWhenReplied 	:= ""           
Self:KnowledgeBase	:= ""
Self:KBName			:= ""
Self:lAttachFile	:= .F.
Self:lSaveFile		:= .F. 
Self:oPersist		:= Self:createPersist()
Self:acAnexo		:= {}
Self:acFileName		:= {}
Self:aFilesUp		:= {}
Self:nTotalSize		:= 0
Self:nMaxAttSize	:= SuperGetMV("MV_TKMAXKB", .F., 500)
Self:lMultiAprov	:= .F.
Self:cMultiCon		:= ""
Self:nMultiVal		:= 0
Self:nTimeLim		:= 0
Self:cTimeAnwser	:= ""

Return Self     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcreatePersist บAutor  ณVendas Cliente  บ Data ณ  19/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a classe de acesso ao banco de dados.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method createPersist() Class WFTemplate 
Local obj

#IFDEF TOP
	obj := WFTemplateTop():New()
#ELSE
	obj := WFTemplateCodebase():New()
#ENDIF
Return obj 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoad         บAutor  ณVendas Cliente   บ Data ณ  19/01/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega os dados do Modelo de WF.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ 
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Codigo do Modelo de Workflow                       ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Load(id) Class WFTemplate
Local lRet := .F.
       
Self:id := id
lRet := Self:oPersist:load(Self)

Return lRet     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณbuildWF      บAutor  ณVendas Cliente   บ Data ณ  19/01/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega um objeto WorkFlow a partir do modelo selecionado.  บฑฑ
ฑฑบ          ณ                                                            บฑฑ 
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method buildWF(cCodUser, lNoPrepare) Class WFTemplate 
Local aRet			:= {}
Local aToArray		:= {}
Local nCount		:= 0
Default lNoPrepare	:= .F. 

If Self:wfType == "1"
	aAdd(aRet, WFInformation():New())                 
	aRet[Len(aRet)]:cModelo			:= Self:id		
Else
	// Quando for multiaprova็ใo, deverแ ser retornado um workflow para cada destinatแrio que participarแ da autoriza็ใo
	If (Self:lMultiAprov)
		// Na multiaprova็ใo, ้ necessแrio pegar os destinatแrios na cria็ใo, para podermos criar n workflows para z destinatแrios
		aToArray	:= self:getEMailsTo()
		For nCount := 1 To Len(aToArray)
			aAdd( aRet, WFAuthorization():New() )
			aRet[Len(aRet)]:codeBlockWhenReplied:setCodeBlock(Self:cbWhenReplied)
			aRet[Len(aRet)]:cProcessedTo	:= aToArray[nCount]
			aRet[Len(aRet)]:cModelo			:= Self:id
		Next
	// Quando nใo for multiaprova็ใo, serแ somente criado um workflow para todos os destinatแrios
	Else
		aAdd( aRet, WFAuthorization():New() )
		aRet[Len(aRet)]:codeBlockWhenReplied:setCodeBlock(Self:cbWhenReplied)
		aRet[Len(aRet)]:cModelo			:= Self:id		
	EndIf
EndIf      

If !lNoPrepare                                                     
	Self:fillFields(Nil, cCodUser, @aRet)
EndIf

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgetEMailsTo  บAutor  ณVendas Cliente   บ Data ณ  20/02/11   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPega a lista dos destinatแrios do modelo de workflow.       บฑฑ  
ฑฑบ          ณ                                                            บฑฑ 
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method getEMailsTo() Class WFTemplate
	Local cTo	:= ""
	Local aTo	:= {}
	
	If !Empty(Self:cbTo)
		cEvalRes := NIL
		cEvalRes := Eval(&("{||" + Self:cbTo + "}"), "")
		If ValType(cEvalRes)=="C"		
			cTo := cEvalRes
		EndIf
	EndIf
	
	If !Empty(cTo)
		aTo := StrToArray( cTo, ";" )
	EndIf 
Return aTo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfillFields   บAutor  ณVendas Cliente   บ Data ณ  19/01/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza as substriuicoes nos textos a serem enviados.       บฑฑ  
ฑฑบ          ณ                                                            บฑฑ 
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method fillFields(oWF, cCodUser, aWFs) Class WFTemplate
Local cSubject		:= ""
Local cBody			:= ""
Local cHtmlFile		:= ""
Local cCC			:= "" 
Local cBCC			:= "" 
Local cReplied 		:= ""
Local cEvalRes		:= ""
Local nAttSize		:= 0
Local nPos			:= 0
Local aDirectory	:= {}
Local cFileName		:=""
Local nCount		:= 1

Local oButtonAdd
Local oButtonClose
Local oButtonConf
Local oButtonRem
Local oListBoxFile
Local nListBoxFile := 1
Local oPanelAll
Local oPanelList
Local oPanelRight
Local oPanelTop
Local oSayTam
Local oSayTop
Static oDlgAttach

Default cCodUser := RetCodUsr()

If aWFs == NIL
	aWFs := { oWF }
EndIf
	
If !Empty(AllTrim(Self:htmlFile))
	cHtmlFile := Self:htmlFile
EndIf                       

// S๓ irแ pegar o destinatแrio se nใo for multiaprova็ใo
If (!Self:lMultiAprov)	.And. Len(aWFs) == 1
	If !Empty(Self:cbTo)
		cEvalRes := NIL
		cEvalRes := Eval(&("{||" + Self:cbTo + "}"), "")
		If ValType(cEvalRes)=="C"		
			aWFs[1]:cProcessedTo := cEvalRes
		EndIf
	EndIf
EndIf              
If !Empty(Self:cbCC)
	cEvalRes := NIL
	cEvalRes := Eval(&("{||" + Self:cbCC + "}"), "")
	If ValType(cEvalRes)=="C"		
		cCC := cEvalRes
	EndIf
EndIf
If !Empty(Self:cbCCO)
	cEvalRes := NIL
	cEvalRes := Eval(&("{||" + Self:cbCCO + "}"), "")
	If ValType(cEvalRes)=="C"		
		cBCC := cEvalRes
	EndIf
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza as substituicoes no texto a ser enviadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cSubject := Self:evalCode(Self:subject)     
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSubstitui os <Enter> por c๓digo Htmlณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
nLen := At(Chr(13)+Chr(10), cSubject)
Do While nLen > 0 
	cSubject := SubStr(cSubject, 0, nLen-1) + " " + SubStr(cSubject, nLen+2, Len(cSubject))
	nLen := At(Chr(13)+Chr(10), cSubject)
End
     
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza as substituicoes no texto a ser enviadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cBody := Self:evalCode(Self:bodyText)                                                 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSubstitui os <Enter> por c๓digo Htmlณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nLen := At(Chr(13)+Chr(10), cBody)
Do While nLen > 0 
	cBody := SubStr(cBody, 0, nLen-1) + "<BR>" + SubStr(cBody, nLen+2, Len(cBody))
	nLen := At(Chr(13)+Chr(10), cBody)
End   

For nCount := 1 To Len( aWFs )
	If aWFs[nCount]:wfType==WFTYPE_AUTHORIZATION 
		aWFs[nCount]:prepare(cCodUser, 	aWFs[nCount]:cProcessedTo, cSubject, cBody, cHtmlFile, cCC, cBCC, .T.)
	Else
		aWFs[nCount]:prepare(cCodUser, aWFs[nCount]:cProcessedTo, cSubject, cBody, cHtmlFile, cCC, cBCC)
	EndIf
Next

If Self:lAttachFile .AND. !IsBlind()

	DEFINE MSDIALOG oDlgAttach TITLE STR0010 FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL //"Anexar Arquivos ao Workflow"

	@ 000, 000 MSPANEL oPanelAll SIZE 250, 150 OF oDlgAttach COLORS 0, 16777215 RAISED
	@ 000, 000 MSPANEL oPanelTop SIZE 249, 015 OF oPanelAll COLORS 0, 16777215 RAISED
	@ 002, 002 SAY oSayTop PROMPT STR0011 SIZE 196, 010 OF oPanelTop COLORS 0, 16777215 PIXEL //"Selecione os arquivos a serem enviados com o workflow"
	@ 015, 199 MSPANEL oPanelRight SIZE 050, 119 OF oPanelAll COLORS 0, 16777215 RAISED
	@ 010, 004 BUTTON oButtonAdd PROMPT STR0012 SIZE 040, 010 OF oPanelRight ACTION Self:TK520JAdicArq(@oListBoxFile, @oSayTam) PIXEL //"ADICIONAR"
	@ 024, 004 BUTTON oButtonRem PROMPT STR0013 SIZE 040, 010 OF oPanelRight ACTION Self:TK520JRemArq(@oListBoxFile, @oSayTam) PIXEL //"REMOVER"
	@ 015, 000 MSPANEL oPanelList SIZE 199, 119 OF oPanelAll COLORS 0, 16777215 RAISED
	@ 000, 000 LISTBOX oListBoxFile FIELDS HEADER STR0014, STR0015 SIZE 198,133 OF oPanelList //"Arquivo","Tamanho"
	@ 134, 000 MSPANEL oPanel1 SIZE 249, 015 OF oPanelAll COLORS 0, 16777215 RAISED
	@ 004, 001 SAY oSayTam PROMPT STR0016 SIZE 106, 007 OF oPanel1 COLORS 0, 16777215 PIXEL //"Tamanho Total:"
	@ 000, 195 BUTTON oButtonConf PROMPT STR0017 SIZE 050, 012 OF oPanel1 ACTION IIF(Self:TK520JSendFiles(aWFs),oDlgAttach:End(),) PIXEL //"CONFIRMAR"


	oListBoxFile:SetArray( Self:aFilesUp )
		
	If Len( Self:aFilesUp ) = 0
		oListBoxFile:bLine:={|| { "", "", ""} }
	Else
		oListBoxFile:bLine:={||{ Self:aFilesUp[oListBoxFile:nAt,1], Self:aFilesUp[oListBoxFile:nAt,2], Self:aFilesUp[oListBoxFile:nAt,3] }}
	EndIf
			
	// Don't change the Align Order
	oPanelAll:Align := CONTROL_ALIGN_ALLCLIENT
	oPanelTop:Align := CONTROL_ALIGN_TOP
	oPanel1:Align := CONTROL_ALIGN_BOTTOM
	oPanelRight:Align := CONTROL_ALIGN_RIGHT
	oPanelList:Align := CONTROL_ALIGN_ALLCLIENT
	oListBoxFile:Align := CONTROL_ALIGN_ALLCLIENT
				
	ACTIVATE MSDIALOG oDlgAttach CENTERED
EndIf
Return aWFs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณevalCode     บAutor  ณVendas Cliente   บ Data ณ  19/01/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAvalia o macro-codigo e retorna um texto.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ 
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method evalCode(cText) Class WFTemplate
Local lNext := .T.               
Local nInicio := 0
Local nFim	:= 0
Local cSubAux	:= ""
Local cEval		:= ""
Local cResult	:= "" 
Local cEvalRes	:= ""

cSubAux := cText                 
If At("%!", cSubAux) > 0
	Do While lNext
		nInicio := At("%!", cSubAux) 
		If nInicio > 0 
			cResult += SubStr(cSubAux, 0, nInicio-1)		
			cSubAux := SubStr(cSubAux, nInicio+2, Len(cSubAux))
			nFim := 0
			nFim := At("!%", cSubAux) 
			If nFim > 0 
				cEval := SubStr(cSubAux, 0, nFim-1)
				cEvalRes := NIL
				cEvalRes := Eval(&("{||" + cEval + "}"), "")		               
				If ValType(cEvalRes)=="C"
					cResult += cEvalRes
				EndIf
				cSubAux := SubStr(cSubAux, nFim+2, Len(cSubAux))					
			Else
				cResult += cSubAux
				lNext := .F.			
			EndIf		
		Else 
			cResult += cSubAux
			lNext := .F.
		EndIf
	End
Else
	cResult := cText
	lNext := .F.
EndIf
Return cResult

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณsetKnowledgeBaseบAutor  ณVendas CRM    บ Data ณ  03/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefine em qual base de conhecimento sera salvo o anexo do   บฑฑ
ฑฑบ          ณe-mail                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMP10                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method setKnowledgeBase(cKnowledgeBase) Class WFTemplate

Self:KnowledgeBase := cKnowledgeBase

Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณsetKBNameบAutor  ณVendas CRM           บ Data ณ  03/12/09   บฑฑ
ฑฑฬออออออออออุอออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefine o nome do item da base de conhecimento               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMP10                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method setKBName(cKBName) Class WFTemplate

Self:KBName := cKBName

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณsaveKnowledgeBaseบAutor  ณVendas CRM   บ Data ณ  03/12/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCopia o anexo para o diretorio do banco de conhecimento e   บฑฑ
ฑฑบ          ณfaz as amarracoes do mesmo.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMP10                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method saveKnowledgeBase(cAnexo, cFileName) Class WFTemplate

Local aArea		:= GetArea()
Local nPos 		:= RAt(If(IsSrvUnix(), "/", "\"), cFileName)
Local nPos2		:= 0
Local cDirDoc	:= MsDocPath()
Local cAnexoGrv	:= Upper(SubStr( cFileName , nPos+1 ))
Local nCount	:= 1

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBusca por um nome de arquivo nao utilizado, incrementando o arquivo        ณ
//ณcom um sequencial ao final do nome, exemplo: arquivo(1).txt, arquivo(2).txtณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("ACB")
DbSetOrder(2) //ACB_FILIAL+ACB_OBJETO

While DbSeek(xFilial("ACB") + AllTrim(SubStr( cAnexoGrv , nPos+1 )))
	nPos2		:= Rat(".",cAnexoGrv)
	cAnexoGrv	:= SubStr(cAnexoGrv,1,nPos2-1)+"("+cValToChar(nCount)+")"+SubStr(cAnexoGrv,nPos2,Len(cAnexoGrv))
	nCount++
End

__CopyFile(cAnexo, cDirDoc + "\" + cAnexoGrv )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInclui registro no banco de conhecimentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RecLock("ACB",.T.)
ACB->ACB_FILIAL := xFilial("ACB")
ACB->ACB_CODOBJ := GetSxeNum("ACB","ACB_CODOBJ")
ACB->ACB_OBJETO	:= Upper(cAnexoGrv)
ACB->ACB_DESCRI	:= Self:KBName
MsUnLock()

ConfirmSx8()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInclui amarra็ใo entre registro do banco e entidadeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RecLock("AC9",.T.)
AC9->AC9_FILIAL	:= xFilial("AC9")
AC9->AC9_FILENT	:= xFilial(Self:KnowledgeBase)
AC9->AC9_ENTIDA	:= Self:KnowledgeBase
AC9->AC9_CODENT	:= Self:KBName
AC9->AC9_CODOBJ	:= ACB->ACB_CODOBJ
MsUnLock()

RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcheckFileบAutor  ณVendas CRM   บ Data ณ             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 	 Apresenta tela para troca de nome de arquivo caso ja     บฑฑ
ฑฑบ          ณ   existir na pasta                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMP10                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method changeFile(cFileName) Class WFTemplate
Local cReturn	:=""
Local oDlgNome	:= Nil
Local oBold		:= Nil
Local oBmp		:= Nil
Local oGet1		:= Nil
Local oBut1		:= Nil
Local oBut2		:= Nil

If Aviso(	STR0003, STR0004 + cFileName + ; 
			STR0005 + CRLF +; //"' nao pode ser incluido pois ja existe no diretorio do banco de conhecimento."
			STR0006, { STR0007 }, 2 ) == 1   //"Atencao!"###"O arquivo '" //"Alterar seu nome."OK"
			 
	cFileName := Pad( cFileName, Len( ACB->ACB_OBJETO ) ) 
		
	oDlgNome:= MSDialog():New(0,0,180,420,STR0008,,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	oDlgNome:lCentered := .T.
	oBold	:= TFont():New("Arial",,-13,.T.)
	oBmp := TBITMAP():Create(oDlgNome)
	oBmp:cName := "oBmp"
	oBmp:cCaption := "LOGIN"
	oBmp:nLeft := 0
	oBmp:nTop := 0
	oBmp:nWidth := 80 
	oBmp:nHeight := 200
	oBmp:lStretch := .T.	  
	oBmp:lVisibleControl := .T.  
	oBmp:cResName:="LOGIN"
	oSay:= TSay():New(03,50,{||STR0008},oDlgNome,,oBold,,,,.T.)
	@12,40 TO 14 ,400 LABEL '' OF oDlgNome PIXEL
	oGet1 := TGET():Create(oDlgNome)
	oGet1:cName := "oGet1"
	oGet1:cCaption := STR0009
	oGet1:nLeft := 100
	oGet1:nTop := 50
	oGet1:nWidth := 300
	oGet1:nHeight := 20
	oGet1:lReadOnly := .F.
	oGet1:cVariable := "cFileName"
	oGet1:bSetGet := {|u| If(PCount()>0,cFileName:=u,cFileName) }
	oGet1:lVisibleControl := .T.		
	oGet1:Picture := "@S40"
	oGet1:bValid := {|| If(!Empty( cFileName ),.T.,.F.)}		
	oBut1 := SButton():New( 52,090,1,{|| oDlgNome:End() },oDlgNome,.T.,,)
	oBut2 := SButton():New( 52,130,2,{|| (cFileName:="",oDlgNome:End()) },oDlgNome,.T.,,)
	oDlgNome:Activate() 
	
EndIf
Return AllTrim(cFileName)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณfree       	บAutor  ณVendas Clientes บ Data ณ  30/06/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Libera a mem๓ria dos objetos utilizados.    			 	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method free() Class WFTemplate

TMKFree( Self:oPersist )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_TMKA520J     บAutor  ณVendas Clientes บ Data ณ  06/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao dummy apenas para o programa aparecer no inspetor de บฑฑ
ฑฑบ          ณobjetos                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                   
FUNCTION _TMKA520J()
RETURN NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK520JAdicArq บAutor  ณVendas CRM      บ Data ณ  12/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que abre a janela para que sejam selecionados os     บฑฑ
ฑฑบ          ณarquivos a serem adicionados ao worflow                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Method TK520JAdicArq( oList, oSayTam) Class WFTemplate
Local lMV_TMKSEAN	:= SuperGetMV("MV_TMKSEAN", .F., 1)
Local nVisibilidade	:= Nil 
Local cAnexo		:= ""
Local cDrive		:=""
Local cFile			:=""
Local cDir			:=""
Local cExten		:=""
Local nArrPos		:= 0
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณControle de seguran็a de visualiza็ใo dos diret๓rios do servidor e remote.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lMV_TMKSEAN == 1
		nVisibilidade := Nil													// Exibe todos os diret๓rios do servidor e do cliente
	ElseIf lMV_TMKSEAN == 2
		nVisibilidade := GETF_ONLYSERVER										// Somente exibe o diret๓rio do servidor
	ElseIf lMV_TMKSEAN == 3
		nVisibilidade := GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE	// Somente exibe o diret๓rio do cliente
	EndIf

	cAnexo := cGetFile(	STR0001,; //"Todos os Arquivos (*.*)     | *.* | "
						STR0002, 0,; //"Selecione um arquivo"
						,.T.,nVisibilidade, If(nVisibilidade==56, .F., .T.) )
						
	SplitPath( cAnexo, @cDrive, @cDir, @cFile, @cExten ) 
	cFileName := cFile+cExten
	If ExistBlock( "TK520JCH" ) 
		cFileName := ExecBlock( "TK520JCH", .F., .F.,{cFile+cExten} ) 
	Endif

	If !Empty(cAnexo)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se o diret๓rio de destino existe, se nใo existe cria.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !File( "\workflow\emp" + AllTrim(cEmpAnt) + "\temp" )
			MakeDir( "\workflow\emp" + AllTrim(cEmpAnt) + "\temp" )
		EndIf
		
		While File( MsDocPath() + "\" +cFileName) .OR. (aScan(Self:acFileName,{|cAtFileName| cAtFileName == cFileName}) > 0)
			cFileName := Self:changeFile(cFileName)
			If cFileName==""
				Return
			EndIf
		End				
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se ้ possํvel pegar a posi็ใo inicial do nome do arquivo.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nPos := RAt(If(IsSrvUnix(), "/", "\"), cAnexo)
		If nPos > 0
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAvalia se o tamanho do anexo (KB) nao excede o limite estipulado em MV_TKMAXKBณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aDirectory := Directory(cAnexo) 
			
			If (ValType(aDirectory) == "A" .AND. Len(aDirectory) == 1 )
				nAttSize := Round(aDirectory[1][2] / 1024, 0)
				Self:nTotalSize := Self:nTotalSize + nAttSize
			EndIf
			
			AADD(Self:aFilesUp,{cFileName,cValToChar(nAttSize)})
			AADD(Self:acAnexo,cAnexo)
			AADD(Self:acFileName,cFileName)
			
			oList:SetArray( Self:aFilesUp )
            oList:bLine:={||{ Self:aFilesUp[oList:nAt,1], Self:aFilesUp[oList:nAt,2] }}
			oList:Refresh()

			If (Self:nTotalSize > Self:nMaxAttSize)
				Alert(STR0020 + " " + cValToChar(Self:nMaxAttSize) + " kb " + STR0021 + "." + chr(10) + chr(13) + STR0022)
				 //"O tamanho total a ser enviado ultrapassa os" //"permitidos" //""Antes de confirmar, remova algum arquivo da lista de anexos ou selecione um arquivo menor."
			EndIf
			oSayTam:SetText(STR0016 + " " + cValToChar(Self:nTotalSize) + " kb") //"Tamanho Total:"

		EndIf
	EndIf
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK520JRemArq  บAutor  ณVendas CRM      บ Data ณ  12/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que remove da lista de arquivos anexos o arquivo     บฑฑ
ฑฑบ          ณselecionado                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Method TK520JRemArq(oList, oSayTam) Class WFTemplate

	If Len(Self:aFilesUp) > 0
		Self:nTotalSize := Self:nTotalSize - Val(Self:aFilesUp[oList:nAt][2])
	Else
		Self:nTotalSize := 0
	EndIf
	
	If oList:nLen >0
		ADEL(Self:acFileName,oList:nAt)
		ADEL(Self:acAnexo,oList:nAt)
		ADEL(Self:aFilesUp,oList:nAt)
	
		
		ASIZE(Self:acFileName,Len(Self:acFileName) - 1)
		ASIZE(Self:acAnexo,Len(Self:acAnexo) - 1)
		ASIZE(Self:aFilesUp, Len(Self:aFilesUp) -1)

		oList:SetArray(Self:aFilesUp)
	    oList:bLine:={||{ Self:aFilesUp[oList:nAt,1], Self:aFilesUp[oList:nAt,2] }}
		oList:Refresh()
	Else
		Aviso(STR0003,STR0031,{STR0007},2) //"Atencao!"##"Nใo existem arquivos a serem removidos."##"OK"
	EndIf
	
	oSayTam:SetText(STR0016 + " " + cValToChar(Self:nTotalSize) + " kb") //"Tamanho Total:"
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK520JSendFiles  บAutor  ณVendas CRM      บ Data ณ  12/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao envia os arquivos selecionados                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TK520JSendFiles(aWFs) Class WFTemplate
Local nCount := 0
Local nCount2:= 0
Local lRet	:= .T.
	If (Self:nTotalSize <= Self:nMaxAttSize)
		
		For nCount := 1 To Len(Self:aFilesUp)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณFaz a c๓pia do arquivo para o servidor.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			__CopyFile(Self:acAnexo[nCount], "\workflow\emp" + AllTrim(cEmpAnt) + "\temp\" + Self:acFileName[nCount] )
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAnexa o arquivo ao workflow.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			For nCount2 := 1 To Len( aWFs )		
				aWFs[nCount2]:attachFile("\workflow\emp" + AllTrim(cEmpAnt) + "\temp\" + Self:acFileName[nCount], .T. )
			Next
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSalva no banco de conhecimentoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If Self:lSaveFile
				Self:saveKnowledgeBase(Self:acAnexo[nCount], Self:acFileName[nCount])
			EndIf
		Next
	Else
		Alert(STR0020 + " " + cValToChar(Self:nMaxAttSize) + " kb " + STR0021 + "." + chr(10) + chr(13) + STR0022)
		 //"O tamanho total a ser enviado ultrapassa os" //"permitidos" //""Antes de confirmar, remova algum arquivo da lista de anexos ou selecione um arquivo menor."
		lRet := .F.
	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgetResume        บAutor  ณVendas CRM      บ Data ณ  20/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณPega a descri็ใo das repostas dadas pelos aprovadores.         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method getResume(cCodWF) Class WFTemplate
	Local cRet 		:= ""
	Local aResume 	:= {}
	Local nCount	:= 0
	Local aAreaSKW	:= SKW->(GetArea())
	
	cCodWF := Self:getHeadWF(cCodWF)
	
	DBSelectArea("SKW")
	DbSetOrder(1)
	
	If SKW->(DbSeek( xFilial("SKW") + cCodWF))
		If Self:lMultiAprov
			aAdd( aResume, { NIL, SKW->KW_EMAIL, SKW->KW_OBS } )
			If SKW->KW_AUTORIZ == "1"
				aResume[Len(aResume)][1] := .T.
			ElseIf SKW->KW_AUTORIZ == "2"
				aResume[Len(aResume)][1] := .F.
			EndIf
			     
			DbSelectArea("SKW")
			DbSetOrder(3)  
			SKW->(DbSeek( xFilial("SKW") + cCodWF ))
			While	SKW->KW_FILIAL == xFilial( "SKW" ) .And.;
					SKW->KW_LOTEAPR == cCodWF
				aAdd( aResume, { NIL, SKW->KW_EMAIL, SKW->KW_OBS } )
				If SKW->KW_AUTORIZ == "1"
					aResume[Len(aResume)][1] := .T.
				ElseIf SKW->KW_AUTORIZ == "2"
					aResume[Len(aResume)][1] := .F.
				EndIf
				SKW->(DbSkip())
			End
		Else			
			aAdd( aResume, { SKW->KW_AUTORIZ == "1", SKW->KW_EMAIL, SKW->KW_OBS } )
		EndIf
	EndIf
	
	For nCount := 1 To Len(aResume)
		cRet += STR0026 + " " + AllTrim(aResume[nCount][2]) // 
		If aResume[nCount][1] == Nil
			cRet += " " + STR0027 + " " // "nใo respondeu"
		ElseIf aResume[nCount][1]
			cRet += " " + STR0028 + " " // "aprovou"
		ElseIf !aResume[nCount][1]
			cRet += " " + STR0029 + " " // "reprovou"
		EndIf
		
		If aResume[nCount][1] != Nil
			cRet += STR0030 + " '" + AllTrim(aResume[nCount][3]) + "'." + Chr(13) + Chr(10) // "comentando"
		Else
			cRet += Chr(13) + Chr(10)
		EndIf
	Next
	
	SKW->(RestArea(aAreaSKW))
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgetHeadWF        บAutor  ณVendas CRM      บ Data ณ  20/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณPega o workflow que encabe็a a lista de workflows de aprova็ใo.บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method getHeadWF(cCodWF) Class WFTemplate
	Local aAreaSKW := SKW->(GetArea())
	DbSelectArea("SKW")
	DbSetOrder(1)	
	If SKW->(DbSeek( xFilial("SKW") + cCodWF))
		IF !Empty(SKW->KW_LOTEAPR)
			cCodWF := SKW->KW_LOTEAPR
		EndIf
	EndIf
	SKW->(RestArea(aAreaSKW))
Return cCodWF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณauthStatus       บAutor  ณVendas CRM      บ Data ณ  20/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณPega a status do workflow.                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method authStatus(cCodWF) Class WFTemplate
	Local nAuthStatus	:= 1
	Local nPositive		:= 0
	Local nNegative		:= 0
	Local nSendWF		:= 0
	Local aAreaSKW		:= SKW->(GetArea())
	
	// Procura pelo registro que encabe็a os workflows
	cCodWF := Self:getHeadWF( cCodWF )

	DbSelectArea("SKW")
	DbSetOrder(1)		
	If SKW->(DbSeek( xFilial("SKW") + cCodWF))		
		nSendWF++
		If SKW->KW_AUTORIZ == "1"
			nPositive++
		ElseIf SKW->KW_AUTORIZ == "2"
			nNegative++			
		EndIf
	EndIf
	
	
	DbSetOrder(3)
	SKW->(DbSeek( xFilial("SKW") + cCodWF ))
	While	SKW->KW_FILIAL == xFilial("SKW") .And.;
			SKW->KW_LOTEAPR == cCodWF
		nSendWF++
		If SKW->KW_AUTORIZ == "1"
			nPositive++
		ElseIf SKW->KW_AUTORIZ == "2"
			nNegative++
		EndIf
		SKW->(DBSkip())
	End
		
	If Self:lMultiAprov
		// Porcentagem
		If Self:cMultiCon == "1" .And. Self:nMultiVal > 0  
			If ((100 * nPositive) / nSendWF) >= Self:nMultiVal
				nAuthStatus := 1
			ElseIf ((100 * nNegative) / nSendWF) > (100-Self:nMultiVal)
				nAuthStatus := 2
			Else
				nAuthStatus := 3
			EndIf
		// Quantidade
		ElseIf Self:cMultiCon == "2"
			If nPositive >= Self:nMultiVal
				nAuthStatus := 1
			ElseIf nNegative > (nSendWF - Self:nMultiVal)
				nAuthStatus := 2
			Else
				nAuthStatus := 3
			ENdIf
		EndIf
	Else
		nAuthStatus := IF( nPositive > 0, 1, 2 )
	EndIf
	
	SKW->(RestArea(aAreaSKW))
Return nAuthStatus