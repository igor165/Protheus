#Include 'Protheus.ch' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA102.CH'

/*/{Protheus.doc} GTPA102B
@GTPA102B - MODELO DE DADOS PARA CONTROLE DE GRAVAÇÃO 
DA GII - SALDO POR AGENCIA.  
@Requisito Controle de Documentos
@Rotina Transferencia
@Tabelas GII
/*/

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@sample		ModelDef()
@return		oModel 		Objeto do Model
@author		
@since		
@version	P12
/*/
Static Function ModelDef()
	
Local oModel 	:= Nil
Local oStruGII	:= FWFormStruct(1,'GII')

oModel := MPFormModel():New('GTPA102B')
oModel:AddFields('GIIMASTER',/*cOwner*/,oStruGII)
oModel:SetPrimaryKey({"GII_FILIAL","GII_TIPO","GII_SERIE","GII_SUBSER","GII_NUMCOM","GII_BILHET"})
	
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} GA102ALot
Faz atualização dos Documentos por Lote

@sample	GA102ALot(cTipo,cSerie,cSubSer,cNumCom,cNumIni,cNumFim,aUpdate)

@param	cTipo    Caracter Tipo GYA
		cSerie   Caracter Serie dos Bilhetes
		cSubSer  Caracter Subserie dos Bilhetes
		cNumCom  Caracter numero complemento dos bilhetes
		cNumIni  Caracter Numero Inicial do bilhetes
		cNumFim  Caracter Numero Final dos bilhetes
		aUpdate   - Array    - Matriz com array Primeira Posição Campo segunda Valor
		Exemplo{{'GII_VALOR',190,10},;
			   {'GII_BAIXA',10/10/15}}
@return		nil
@author		Joni Lima
@since		01/09/2015
@version	P12
/*/
Function GA102ALot(cTipo,cComple,cTipPas,cSerie,cSubSer,cNumCom,cNumIni,cNumFim,aUpdate)
	
Local aArea 	:= GetArea()
Local aAreaGII	:= GII->(GetArea())	
Local nInic		:= Val(cNumIni)
Local nFinal 	:= Val(cNumFim)
Local nTmBil 	:= TamSX3('GII_BILHET')[01]
Local cBilhete 	:= ""
Local lRet 		:= .F.	
Local i:= nInic
	
For i := nInic to nFinal
	
	cBilhete := StrZero ( i, nTmBil)
	If !( lRet := GA102AGII(cTipo,cComple,cTipPas,cSerie,cSubSer,cNumCom,cBilhete,aUpdate) )
		lRet := .F.
		Exit
	EndIf
Next i

RestArea(aAreaGII)
RestArea(aArea)
	
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GA102BVExB
Faz Validação do excesso Bagagem
@sample	GA102BVExB(cTipo,cSerie,cSubSer,cNumCom,cBilhet,cAgenc,cEmiss)

@param	cTipo    - Caracter - Tipo GYA
		cSerie   - Caracter - Serie dos Bilhetes
		cSubSer  - Caracter - Subserie dos Bilhetes
		cNumCom  - Caracter - Numero complemento dos bilhetes
		cBilhet  - Caracter - Numero Bilhete
		cAgenc   - Caracter - Agencia
		cEmiss   - Caracter - Emissor

@return		nil

@author		Joni Lima
@since		01/09/2015
@version	P12

/*/
//-------------------------------------------------------------------
Function GA102BVExB(cTipo,cComple,cTipPas,cSerie,cSubSer,cNumCom,cBilhet,cAgenc)
	
Local aArea := GetArea()
Local aAreaGII := GII->(GetArea())
Local lRet := .F.
Local aRet := {lRet,''}

dbSelectArea('GII')
GII->(dbSetOrder(1))  //"GII_FILIAL+GII_TIPO+GII_COMPLE+GII_TIPPAS+GII_SERIE+GII_SUBSER+GII_NUMCOM+GII_BILHET+GII_AGENCI"

lRet := GII->(dbSeek(xFilial('GII') + cTipo + cComple + cTipPas +cSerie + cSubSer + cNumCom + cBilhet + cAgenc  ))

If lRet
	aRet := {lRet,GII->GII_LOTREM}
EndIf

RestArea(aAreaGII)
RestArea(aArea)
	
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GA102AGII
Atualização da tabela Saldo por Agência 

@sample	GA102AGII(cTipo,cSerie,cSubSer,cNumCom,cBilhet,dBaixa,nValor)

@param	cTipo    - Caracter - Tipo GYA
		cSerie   - Caracter - Serie dos Bilhetes
		cSubSer  - Caracter - Subserie dos Bilhetes
		cNumCom  - Caracter - Numero complemento dos bilhetes
		cBilhet  - Caracter - Numero Bilhete
		aUpdate   - Array    - Matriz com array Primeira Posição Campo segunda Valor
		Exemplo{{'GII_VALOR',190,10},;
			   {'GII_BAIXA',10/10/15}}

@return		nil

@author		Joni Lima
@since		01/09/2015
@version	P12

/*/
//-------------------------------------------------------------------
Function GA102AGII(cTipo,cComple,cTipPas,cSerie,cSubSer,cNumCom,cBilhet,aUpdate)
	
Local aArea 	 := GetArea()
Local aAreaGII	 := GII->(GetArea())
Local lRet       := .F.
Local oMasterGII := Nil
Local oMod102B 	 := Nil
Local nI
	
DbSelectArea('GII')
GII->(dbSetOrder(1))   //"GII_FILIAL+GII_TIPO+GII_COMPLE+GII_TIPPAS+GII_SERIE+GII_SUBSER+GII_NUMCOM+GII_BILHET+GII_AGENCI"
	
If GII->( DbSeek(xFilial('GII') + cTipo + cComple + cTipPas + cSerie + cSubSer + cNumCom + cBilhet )) 

	oMod102B := FWLoadModel( 'GTPA102B' )
	
	oMod102B:SetOperation( MODEL_OPERATION_UPDATE )

	oMod102B:Activate()
	
	oMasterGII:= oMod102B:GetModel('GIIMASTER')
	
	For nI:= 1 to Len(aUpdate)
		If !( lRet := oMasterGII:LoadValue(aUpdate[nI,1], aUpdate[nI,2] ) )
			Exit
		EndIf
	Next nI
	
	If lRet .And. oMod102B:VldData()
		lRet := FwFormCommit(oMod102B)
		oMod102B:DeActivate()
		oMod102B:Destroy()
	Else
		lRet := .F.
		JurShowErro( oMod102B:GetModel():GetErrormessage() )
	EndIf
	
Else
	Help( ,, 'Help',STR0018, 1, 0 )// "Registro não encontrada para alteração."
	lRet := .F.
EndIf

RestArea(aAreaGII)
RestArea(aArea)
	
Return(lRet)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPVERVEN()
Verifica se o bloco de documentos escolhido está vencido.
 
@return	Lógico
 
@author	Inovação
@since		01/08/2019
@version	P12
/*/
//------------------------------------------------------------------------------------------

Function GTPVERVEN(cTpDoc, cComple, cTipPas, cSerie, cSubSer, cNumCom, cNumIni, cNumFim,cStatus, dDtEmiss)

Local lRet	:= .T.
Local dDataVenc	:= Posicione('GI8', 1, xFilial('GI8')+cTpDoc+cComple+cTipPas+cSerie+cSubSer+cNumCom+cNumIni+cNumFim, 'GI8_DTFIM')

Default dDtEmiss := dDataBase

If !Empty(dDataVenc) .And. dDtEmiss >= dDataVenc
	lRet:= .F.
EndIf

Return lRet   
