#Include 'Protheus.ch'

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA640A
Fonte que cont�m rotinas da estrutura da gest�o de territ�rios

@sample	CRMA640A()

@author	Jonatas Martins
@since		23/07/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Function CRMA640A()
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA640AFather
Rotina que obtem a estrutura de territ�rios pai 

@sample	CRMA640AFather(cCodTer)

@param		cCodTer, caracter, C�digo do territ�rio
@param		aFather, array, Par�metro interno da fun��o para recursividade

@return	aFather, array, Array com c�digo dos territ�rios pai

@author	Jonatas Martins
@since		23/07/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Function CRMA640AFather(cCodTer,aFather)

Local aAreaAOY := AOY->(GetArea())

Default cCodTer	:= ""
Default aFather	:= {}

//----------------------------
//Posiciona no territ�rio pai
//----------------------------
AOY->(DbSetOrder(1)) // AOY_FILIAL + AOY_CODTER
If AOY->(DbSeek(xFilial("AOY")+cCodTer)) 	  
	If !Empty(AOY->AOY_SUBTER)
		Aadd(aFather,AOY->AOY_SUBTER)
		
		//------------------------------------
		//Recursividade para encontrar o pai
		//------------------------------------
		CRMA640AFather(AOY->AOY_SUBTER,@aFather)
	EndIf				
EndIf

RestArea(aAreaAOY)

Return (aFather)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA640ASon
Rotina que obtem a estrutura de territ�rios filhos 

@sample	CRMA640ASon(cCodTer,aSon)

@param		cCodTer, caracter, C�digo do territ�rio
@param		aSun, array, Par�metro interno da fun��o para recursividade

@return	aSon, array, Array com c�digo dos territ�rios filhos

@author	Jonatas Martins
@since		23/07/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Function CRMA640ASon(cCodTer,aSon)

Local aAreaAOY	:= AOY->( GetArea() )

Default cCodTer	:= ""
Default aSon		:= {}

//----------------------------
//Posiciona no territ�rio
//----------------------------
AOY->(DbSetOrder(2)) // AOY_FILIAL + AOY_SUBTER
If AOY->(DbSeek(xFilial("AOY")+cCodTer)) 	  
	Aadd(aSon,AOY->AOY_CODTER)
	
	//------------------------------------
	//Recursividade para encontrar o pai
	//------------------------------------
	CRMA640ASon(AOY->AOY_CODTER,@aSon)
EndIf

RestArea(aAreaAOY)

Return (aSon)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA640AStru
Rotina que obtem a estrutura de agrupadores dos territ�rios 

@sample	CRMA640AStru(aTerritory)

@param		aTerritory, array, Array com c�digo dos territ�rios

@return	aStrucTer, array, Array com c�digo dos territ�rios seus agrupadores e n�veis  
@author	Jonatas Martins
@since		23/07/2015
@version	12.1.6
/*/
//--------------------------------------------------------
Function CRMA640AStru(aTerritory)

Local aAreaAOZ	:= AOZ->(GetArea())
Local aAgrup		:= {}
Local aAgrNiv		:= {} 
Local aStrucTer	:= {}
Local nX			:= 0
Local nY			:= 0

Default aTerritory	:= {}

If !Empty(aTerritory)
	//-----------------------------------------------
	//Obtem os agrupadores das dimens�es dos pais
	//-----------------------------------------------
	For nX := 1 To Len(aTerritory)
		aAgrup := CRMA640AgrTer( aTerritory[nX] ) 
		
		//-----------------------------------------------
		//Obtem os n�veis dos agrupadores
		//-----------------------------------------------
		For nY := 1 To Len( aAgrup )		
			Aadd( aAgrNiv, { aAgrup[nY], CRMA640ANivAgr( aTerritory[nX], aAgrup[nY] ) } )
		Next nY
		
		aAdd( aStrucTer, { aTerritory[nX], aAgrNiv} )		
	Next nX
EndIf
		
RestArea(aAreaAOZ)	

Return (aStrucTer)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA640AgrTer(aTerritory[nX])
Rotina que obtem a estrutura de agrupadores dos territ�rios

@sample	CRMA640AgrTer(aTerAgrup)

@param		cCodTer, array, C�digo do territ�rio 

@return	aAgrup, array, Array com c�digo dos agrupadores do territ�rio 
@author	Jonatas Martins
@since		23/07/2015
@version	12.1.6
/*/
//--------------------------------------------------------
Function CRMA640AgrTer(cCodTer)

Local aAreaAOZ	:= AOZ->(GetArea())
Local aAgrup		:= {}

Default cCodTer := ""

AOZ->( DbSetOrder(1) )
If AOZ->( DbSeek( xFilial("AOZ") + cCodTer ) )
	While AOZ->( !EOF() ) .And. AOZ->AOZ_CODTER == cCodTer
		Aadd( aAgrup, AOZ->AOZ_CODAGR )
		AOZ->( DbSkip() ) 
	End
EndIf

RestArea( aAreaAOZ )

Return ( aAgrup )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA640ANivAgr
Rotina que obtem a estrutura de n�veis dos agrupadores dos territ�rios

@sample	CRMA640ANivAgr(cCodTer, cCodAgr)

@param		cCodTer, caracter, C�digo do territ�rio
@param		cCodAgr, caracter, C�digo do agrupador 

@return	aNiveis, array, Array com c�digo dos n�veis dos agrupadores dos territ�rios 
@author	Jonatas Martins
@since		23/07/2015
@version	12.1.6
/*/
//--------------------------------------------------------
Function CRMA640ANivAgr(cCodTer, cCodAgr)

Local aAreaA00	:= A00->(GetArea()) 
Local aNiveis		:= {}
Local nPosAgr		:= 0

Default cCodTer := ""
Default cCodAgr := ""

If !Empty(cCodAgr)
	DbSelectArea("A00")
	A00->(DbSetOrder(1))
	//--------------------------------------------
	//Posiciona na tabela de n�veis do territ�rio
	//--------------------------------------------
	If A00->(DbSeek( xFilial("A00") + cCodTer + cCodAgr ) ) // A00_FILIAL + A00_CODTER + A00_CODAGR + A00_NIVAGR
		While A00->(!EOF()) .And. A00->A00_CODTER == cCodTer .And. A00->A00_CODAGR == cCodAgr
			Aadd(aNiveis,A00->A00_NIVAGR)
			A00->(DbSkip())
		End						
	EndIf	
EndIf

RestArea(aAreaA00)

Return (aNiveis)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA640AIdInt
Fun��o que retorna o ID inteligente do n�vel

@sample	CRMA640AIdInt(cCodAgr, cCodNiv)

@param		cCodAgr, caracter, C�digo do agrupador 
@param		cCodNiv, caracter, C�digo do N�vel

@return	cIdIntNiv, caracter, Id inteligente do n�vel 
@author	Jonatas Martins
@since		23/07/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Function CRMA640AIdInt( cCodAgr, cCodNiv )

Local aAreaAOM	:= AOM->( GetArea() )
Local cIdIntNiv 	:= ""

Default cCodAgr := ""
Default cCodNiv := ""

DbSelectArea("AOM")
AOM->( DbSetOrder(1) ) // AOM_FILIAL + AOM_CODAGR + AOM_CODNIV
If AOM->( DbSeek( xFilial("AOM") + cCodAgr + cCodNiv ) )
	cIdIntNiv := AOM->AOM_IDINT
EndIf

RestArea( aAreaAOM )

Return cIdIntNiv

//------------------------------------------------------------------------------

