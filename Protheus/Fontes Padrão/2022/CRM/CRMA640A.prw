#Include 'Protheus.ch'

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA640A
Fonte que contém rotinas da estrutura da gestão de territórios

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
Rotina que obtem a estrutura de territórios pai 

@sample	CRMA640AFather(cCodTer)

@param		cCodTer, caracter, Código do território
@param		aFather, array, Parâmetro interno da função para recursividade

@return	aFather, array, Array com código dos territórios pai

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
//Posiciona no território pai
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
Rotina que obtem a estrutura de territórios filhos 

@sample	CRMA640ASon(cCodTer,aSon)

@param		cCodTer, caracter, Código do território
@param		aSun, array, Parâmetro interno da função para recursividade

@return	aSon, array, Array com código dos territórios filhos

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
//Posiciona no território
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
Rotina que obtem a estrutura de agrupadores dos territórios 

@sample	CRMA640AStru(aTerritory)

@param		aTerritory, array, Array com código dos territórios

@return	aStrucTer, array, Array com código dos territórios seus agrupadores e níveis  
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
	//Obtem os agrupadores das dimensões dos pais
	//-----------------------------------------------
	For nX := 1 To Len(aTerritory)
		aAgrup := CRMA640AgrTer( aTerritory[nX] ) 
		
		//-----------------------------------------------
		//Obtem os níveis dos agrupadores
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
Rotina que obtem a estrutura de agrupadores dos territórios

@sample	CRMA640AgrTer(aTerAgrup)

@param		cCodTer, array, Código do território 

@return	aAgrup, array, Array com código dos agrupadores do território 
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
Rotina que obtem a estrutura de níveis dos agrupadores dos territórios

@sample	CRMA640ANivAgr(cCodTer, cCodAgr)

@param		cCodTer, caracter, Código do território
@param		cCodAgr, caracter, Código do agrupador 

@return	aNiveis, array, Array com código dos níveis dos agrupadores dos territórios 
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
	//Posiciona na tabela de níveis do território
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
Função que retorna o ID inteligente do nível

@sample	CRMA640AIdInt(cCodAgr, cCodNiv)

@param		cCodAgr, caracter, Código do agrupador 
@param		cCodNiv, caracter, Código do Nível

@return	cIdIntNiv, caracter, Id inteligente do nível 
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

