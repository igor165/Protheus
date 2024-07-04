#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    timoteo.bega
@since     01/05/2017
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oStruB8R := FWFormStruct( 1, 'B8R', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel
	
oModel := MPFormModel():New( 'MODELB8R' )
oModel:AddFields( 'MODEL_B8R',,oStruB8R )	
oModel:SetDescription( "Criticas dos Contratos" )
oModel:GetModel( 'MODEL_B8R' ):SetDescription( ".:: Monitoramento Crit. Vlr. Pree. ::." ) 
oModel:SetPrimaryKey( { "B8R_FILIAL","B8R_SUSEP","B8R_CMPLOT","B8R_NUMLOT","B8R_IDEPRE","B8R_CPFCNP","B8R_IDCOPR","B8R_CODCMP","B8R_CODERR" } )

return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef - MVC

@author    timoteo.bega
@version   1.xx
@since     01/05/2011
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= Nil
Local oModel	:= FWLoadModel( 'PLSM270B8R' )
	
oView := FWFormView():New()
oView:SetModel( oModel )

return oView

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSM270B8Q
Gravacao da tabela B8R - CRITICAS CONTR PREE MONITORAME

@author    timoteo.bega
@since     01/05/2011
/*/
//------------------------------------------------------------------------------------------
Function PLSM270B8R(aCabec,aRegRej)
Local cSusep	:= ""
Local cCmpLot	:= ""
Local cNumLot	:= ""
Local cIdePre	:= ""
Local cCpfCnp	:= ""
Local cIdCoPr	:= ""
Local cChave	:= ""
Local cChvCri	:= ""
Local cDesErr	:= ""
Local nPos		:= 0
Local nFor		:= 0
Local lRet		:= .F.
Local aCampos := {}

cSusep	:= aCabec[6,3]
cCmpLot	:= aCabec[3,3]
cNumLot	:= aCabec[2,3]
nPos		:= aScan(aRegRej,{|x| ValType(x[1]) == "C" .And. Upper(x[1]) == "IDENTIFICADOREXECUTANTE"})
cIdePre	:= Iif(nPos > 0,aRegRej[nPos,3],"")
nPos		:= aScan(aRegRej,{|x| ValType(x[1]) == "C" .And. Upper(x[1]) == "CODIGOCNPJ_CPF"})
cCpfCnp	:= Iif(nPos > 0,aRegRej[nPos,3],"")
nPos		:= aScan(aRegRej,{|x| ValType(x[1]) == "C" .And. Upper(x[1]) == "IDENTIFICACAOVALORPREESTABELECIDO"})
cIdCoPr	:= Iif(nPos > 0,aRegRej[nPos,3],"")

//Montagem da chave e escolha do indice para posicionar o contrato
cChave := xFilial("B8Q")+cSusep+cCmpLot+cNumLot
If !Empty(cCpfCnp)

	B8Q->(dbSetOrder(1))
	If !Empty(cIdePre)
		cChave += cIdePre
	Else
		If Len(cCpfCnp) < 14
			cChave += "2"
		Else
			cChave += "1"
		EndIf
	EndIf
	cChave += cCpfCnp
	cChave += cIdCoPr

Else

	B8Q->(dbSetOrder(2))
	cChave += cIdCoPr

EndIf 

//Vou marcar o contrato como criticado
If B8Q->(dbSeek(cChave)) 

	aAdd( aCampos,{ "B8Q_STATUS",		'2'					} )	// 1-Sem critica, 2-Com critica
	lRet := gravaMonit( 4,aCampos,'MODEL_B8Q','PLSM270B8Q' )

EndIf

If lRet

	BTQ->(dbSetOrder(1))//BTQ_FILIAL, BTQ_CODTAB, BTQ_CDTERM
	B8R->(dbSetOrder(1))//B8R_FILIAL+B8R_SUSEP+B8R_CMPLOT+B8R_NUMLOT+B8R_IDEPRE+B8R_CPFCNP+B8R_IDCOPR+B8R_CODCMP+B8R_CODERR
	nPos := aScan(aRegRej,{|x| ValType(x[1]) == "A"})//Pego a posicao que comecou a lista de criticas
	For nFor := 1 TO Len(aRegRej[nPos])

		aCampos := {}
		cCodCmp := aRegRej[nPos,nFor,1,3]
		cCodErr := aRegRej[nPos,nFor,2,3]
		cChvCri := xFilial("B8R")+B8Q->(B8Q_SUSEP+B8Q_CMPLOT+B8Q_NUMLOT+B8Q_IDEPRE+B8Q_CPFCNP+B8Q_IDCOPR+cCodCmp+cCodErr)

		If !B8R->(dbSeek(cChvCri))

			BTQ->(dbSeek(xFilial("BTQ")+'38'+cCodErr))
			cDesErr := AllTrim(BTQ->BTQ_DESTER)

			aAdd(aCampos,{"B8R_FIIAL",		xFilial("B8R")		})
			aAdd(aCampos,{"B8R_SUSEP",		B8Q->B8Q_SUSEP		})
			aAdd(aCampos,{"B8R_CMPLOT",	B8Q->B8Q_CMPLOT	})
			aAdd(aCampos,{"B8R_NUMLOT",	B8Q->B8Q_NUMLOT	})
			aAdd(aCampos,{"B8R_IDEPRE",	B8Q->B8Q_IDEPRE	})
			aAdd(aCampos,{"B8R_CPFCNP",	B8Q->B8Q_CPFCNP	})
			aAdd(aCampos,{"B8R_IDCOPR",	B8Q->B8Q_IDCOPR	})
			aAdd(aCampos,{"B8R_CODCMP",	cCodCmp				})
			aAdd(aCampos,{"B8R_CODERR",	cCodErr				})
			aAdd(aCampos,{"B8R_DESERR",	cDesErr				})
			
			lRet := gravaMonit( 3,aCampos,'MODEL_B8R','PLSM270B8R' )
			cCodCmp := ""
			cCodErr := ""
			cDesErr := ""
		
		EndIf

	Next nFor

EndIf

Return
