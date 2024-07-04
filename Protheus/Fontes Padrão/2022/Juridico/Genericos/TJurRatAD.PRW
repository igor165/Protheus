#Include "Protheus.Ch"
#Include "TJurRatAD.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} GetMark()

	Classe para ratear o Valor do Acréscimo ou Desconto aplicado à Fatura

@author David G. Fernandes
@since 25/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function __TJRATEIOAD() // Function Dummy
ApMsgInfo( 'TJRATEIOAD -> Utilizar Classe ao inves da funcao' )
Return NIL 

Class TJRATEIOAD From FWSerialize
	//
    Data	cEscrit			// Código do Escritório da Fatura
    Data	cFatura			// Número da Fatura 
    Data	cCliente		// Código do Cliente da Fatura
    Data	cLoja			// Loja do Cliente da Fatura
    Data	cRazao			// Razão social do Cliente
    Data	nVlRatFat		// Valor a Ratear da Fatura

    Data	nVlRatCon		// Valor a Ratear do Contrato
    Data	nVlRatCas		// Valor a Ratear do Caso
    Data	nVlRatPar		// Valor a Ratear do Participante


    Data	cTipoRat		// Tipo do Rateio: 1: Ratio do Desconto / 2: Rateio do Acréscimo

    Data	nTotCont		// Total Rateado para os Contratos
    Data	nTotCaso		// Total Rateado para os Casos
    Data	nTotPart
    Data	nSaldoCont		// Saldo a Ratear para os Contratos
    Data	nSaldoCaso		// Saldo a Ratear para os Casos
    Data	nSaldoPart		// Saldo a Ratear para os Participantes

    Data	cCodContr		// Código do Contrato Atual
    Data	nVlCont			// Valor do contrato Atual  
    Data  lOk         // Variavel de Controle 

    // Objetos visuais:
    Data	oDlg
    
	//Gets do Header:
    Data	oGetEscrit
    Data	oGetFatura
    Data	oGetCClien
    Data	oGetCLoja
    Data	oGetDClien
	// Objetos - Valores Rateados:
    Data	oGetVlFat
    Data	oGetVlCon
    Data	oGetVlCas
    Data	oGetVlPar
	// Objetos dos Saldos:
    Data	oGetSldCon
    Data	oGetSldCas
    Data	oGetSldPar
	// Folders:
    Data	oFldRateio
    
    //Aba de Contratos
    Data	oGetSldCtCaso
    Data	nSldCtCaso


    Data	oGetVlCont
	Data	oGetCContr

  Data	oBtnAddCt
	Data	oBtnRemCt          
  Data	oBtnOK
  Data  oBtnCancel  
	Data	oBtnSld  
                         
	// Aba de Casos
	Data	oGetTotCasos
	Data	nTotConCas
	Data	oGetCodCliCaso
	Data	cCodCliCaso
	Data	oGetCodLojCaso
	Data	cCodLojCaso
	Data	oGetCodCaso
	Data	cCodCaso
	Data	oGetVlCaso
	Data	nVlCaso
	
    Data	oBtnAddCs
	Data	oBtnRemCs

	// Aba de participantes
	Data	oGetSldCaPar	
	Data	nSldCaPar
	Data	oGetTotPart		
	Data	nTotCaPar
	Data	oGetCPart		
	Data	cCodPart
	Data	oGetCSeq		
	Data	cCodSeq
	Data	oGetVlPart		
	Data	nVlPart

	Data	oBtnAddPt
	Data	oBtnRemPt	
    
	//'Grids' dos itens
    Data	oLbxRatCon
    Data	oLbxRatCas
    Data	oLbxRatPar
    
	//Arrays para os grids:
	Data aContratos 	//Armazena os contratos incluídos no rateio
	Data aCasos     	//Armazena totos os casos incluídos no rateio
	Data aParticip  	//Armazena todos os participantes incluídos no rateio
	Data aCasosCont 	//Armazena somente os casos do contrato selecionado
	Data aPartiCaso 	//Armazena somente os participantes do caso selecionado    
	
	Method New( cEscrit, cFatura, cTipoRat ) Constructor
	// Gets / Sets:
	Method GetEscrit()
	Method SetEscrit( cEscrit )
	Method GetFatura()
	Method SetFatura( cFatura )
    
	Method GetTipoRat()
	Method GetCampoRat()
	
	Method GetCliente()
	Method GetLoja()
	Method GetQtdContr()
	Method GetQtdCaso()
	Method GetQtdPart()
	//Item Selecionado:
	Method GetSelContr()
	Method GetSelCaso()
	Method GetSelPart()
	
	Method GetGrdContr(nLinha)
	//Caso Selecionado
	Method GetGrdCaso(nLinha)
	//Participante Selecionado:


	Method GetGrdPart(nLinha)	
	
	// Ações que manipulam os dados:
	Method ZeraArray(cArray) 	
	Method SelectContr(nLinha)
	Method SelectCaso(nLinha)
	Method SelectPart(nLinha)
	Method ChContr()
	Method ChCaso()
	Method ChPart()
	Method TemContrato()
	Method TemCaso()
	Method TemPart()
	Method SetArrayContr(nLinhaGrid) 
	Method SetArrayCaso(nLinhaGrid)
	Method SetArrayPart(nLinhaGrid)
	Method AddContrato()
	Method AddCaso()
	Method AddPart()
	Method RemContrato()
	Method RemCaso()
	Method RemPart()
	
	Method InsereSaldo()
	Method GravaRateio()
	Method SomaNXD()
                        
	//Manipulação da tela
	Method Refresh()
	Method DrawScreen()
	Method ActiveScreen()

	//Validaçõese:	
	Method Confirma()
	Method Cancela()
	Method ValidaCodigos(cAlias)
	Method ValidaSaldos()
	
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New(cEscrit, cFatura, cTipoRat )
Construtor da Classe

@Params 	cEscrit		Código do Escritório da Fatura
			cFatura		Número da Fatura
			cTipoRat	Tipo de Rateio: 1 - Destondo / 2 - Acréscimo

@author David G. Fernandes
@since 18/03/10
@version 1.0
/*/
//------------------------------------------------------------------- 
Method New(cEscrit, cFatura, cTipoRat ) Class TJRATEIOAD
	// Cabeçalho - Dados da Fatura
	self:cEscrit		:= cEscrit
	self:cFatura		:= cFatura
	self:cTipoRat		:= cTipoRat

  self:cCliente	  := POSICIONE("NXA",1,xFilial("NXA")+self:GetEscrit()+self:GetFatura() , "NXA_CCLIEN" )
  self:cLoja		  := POSICIONE("NXA",1,xFilial("NXA")+self:GetEscrit()+self:GetFatura() , "NXA_CLOJA" )
  self:nVlRatFat	:= POSICIONE("NXA",1,xFilial("NXA")+self:GetEscrit()+self:GetFatura() , self:GetCampoRat() )
  self:cRazao		  := POSICIONE("SA1",1,xFilial("SA1")+self:GetCliente()+self:GetLoja() , "A1_NOME" )

	// Cabeçalho - totais
	self:nTotCont		:= 0
	self:nTotCaso		:= 0
	self:nTotPart		:= 0

  self:nSaldoCont	:= self:nVlRatFat
  self:nSaldoCaso	:= self:nVlRatFat
  self:nSaldoPart	:= self:nVlRatFat

	// Aba de contratos:
	self:cCodContr 	:= CriaVar('NXB_CCONTR')
	self:nVlCont		:= 0

	//Aba de casos:
	self:nSldCtCaso		:= 0
	self:nTotConCas		:= 0
	self:cCodCliCaso	:= CriaVar('NVE_CCLIEN')
	self:cCodLojCaso	:= CriaVar('NVE_LCLIEN')
	self:cCodCaso 		:= CriaVar('NVE_NUMCAS')
	self:nVlCaso	  	:= 0
	
	// Aba de Participantes:
	self:nSldCaPar	:= 0
	self:nTotCaPar	:= 0
	self:cCodPart	:= CriaVar('NXD_CPART')
	self:cCodSeq	:= CriaVar('NXD_CSEQ')
	self:nVlPart	:= 0
	
	self:nTotCaPar	:= 0
	
	self:ZeraArray( "aContratos"	)
	self:ZeraArray( "aCasos" 		)
	self:ZeraArray( "aParticip" 	)
	self:ZeraArray( "aCasosCont" 	)
	self:ZeraArray( "aPartiCaso" 	)

Return self 

Method GetEscrit()  Class TJRATEIOAD
Return (self:cEscrit) 

Method SetEscrit(cEscrit)  Class TJRATEIOAD
	Local aRet := {.F.,"SetEscrit"} 
	self:cEscrit := cEscrit
	aRet := {.T.,"SetEscrit"}
Return (aRet)       

Method GetFatura()  Class TJRATEIOAD
Return (self:cFatura) 

Method SetFatura(cFatura)  Class TJRATEIOAD
	Local aRet := {.F.,"SetFatura"} 
	self:cFatura := cFatura
	aRet := {.T.,"SetFatura"}
Return (aRet)  

Method GetCampoRat() Class TJRATEIOAD
	Local cReturn := ""
	If self:GetTipoRat() == "1"
		cReturn := "NXA_VLDESC"
	Else
		cReturn := "NXA_VLACRE"
	EndIF
Return ( cReturn )  


Method GetTipoRat()  Class TJRATEIOAD
return self:cTipoRat

Method GetCliente() Class TJRATEIOAD
return self:cCliente

Method GetLoja() Class TJRATEIOAD
return self:cLoja

Method GetQtdContr() Class TJRATEIOAD
	Local nRet	:= 0
	If self:TemContrato()
		nRet	:= Len(self:aContratos) 	
	Else
		nRet	:= 0
	EndIf
Return ( nRet ) 

Method GetQtdCaso() Class TJRATEIOAD
	Local nRet	:= 0
	If self:TemCaso()
		nRet	:= Len(self:aCasosCont) 	
	Else
		nRet	:= 0
	EndIf
Return ( nRet ) 

Method GetQtdPart() Class TJRATEIOAD
	Local nRet	:= 0
	If self:TemPart()
		nRet	:= Len(self:aPartiCaso) 	
	Else
		nRet	:= 0
	EndIf
Return ( nRet ) 

//Contrato Selecionado:
Method SelectContr(nLinha) Class TJRATEIOAD
	Local lRet := .F.
	self:cCodContr	:= self:aContratos[nLinha][ 2]
	self:nVlCont	:= self:aContratos[nLinha][ 4]

	self:nTotConCas 	:= self:aContratos[ self:oLbxRatCon:nAt ][5]
	self:nSldCtCaso 	:= self:aContratos[ self:oLbxRatCon:nAt ][4] - self:nTotConCas
		
	lRet := .T.
Return ( lRet )


//Caso Selecionado
Method SelectCaso(nLinha) Class TJRATEIOAD
	Local lRet := .F.
	self:cCodCliCaso	:= self:aCasosCont[nLinha][ 3]
	self:cCodLojCaso	:= self:aCasosCont[nLinha][ 4]
	self:cCodCaso		:= self:aCasosCont[nLinha][ 6]
	self:nVlCaso		:= self:aCasosCont[nLinha][ 8]

	self:nTotCaPar		:= self:aCasosCont[self:oLbxRatCas:nAt][9]
	self:nSldCaPar		:= self:aCasosCont[self:oLbxRatCas:nAt][8] - self:nTotCaPar

	lRet := .T.
Return ( lRet ) 


//Participante Selecionado:
Method SelectPart(nLinha) Class TJRATEIOAD
	Local lRet := .F.
	self:cCodPart	:= self:aPartiCaso[nLinha][06]
	self:cCodSeq	:= self:aPartiCaso[nLinha][10]
	self:nVlPart	:= self:aPartiCaso[nLinha][08]
	
	lRet := .T.
Return ( lRet )


Method GetSelContr() Class TJRATEIOAD
	Local cRetCont		:= self:aContratos[self:oLbxRatCon:nAt][ 2]
	Local nRetVal		:= self:aContratos[self:oLbxRatCon:nAt][ 4]
return ( {cRetCont , nRetVal } )

Method GetSelCaso() Class TJRATEIOAD
	Local cRetCli		:= self:aCasosCont[self:oLbxRatCas:nAt][ 3]
	Local cRetLoja		:= self:aCasosCont[self:oLbxRatCas:nAt][ 4]
	Local cRetCaso		:= self:aCasosCont[self:oLbxRatCas:nAt][ 6]
	Local nRetVal		:= self:aCasosCont[self:oLbxRatCas:nAt][ 8]
	
return ( {cRetCli, cRetLoja, cRetCaso, nRetVal } )

Method GetSelPart() Class TJRATEIOAD
return ( { self:cCodPart, self:cCodSeq, self:nVlPart } )


Method GetGrdContr(nLinha) Class TJRATEIOAD
	If nLinha <= 0 .OR. nLinha >  len(self:aContratos)
		nLinha := self:oLbxRatCon:nAt
	EndIf
return ( {self:aContratos[nLinha][ 2] ,self:aContratos[nLinha][ 4]} )


Method GetGrdCaso(nLinha) Class TJRATEIOAD
	If nLinha <= 0 .OR. nLinha > len( self:aCasosCont )
		nLinha := self:oLbxRatCas:nAt
	EndIf
	
return ( { self:aCasosCont[nLinha][ 3], self:aCasosCont[nLinha][ 4], self:aCasosCont[nLinha][ 6], self:aCasosCont[nLinha][ 8] } )

Method ChContr(  ) Class TJRATEIOAD
	Local ni    := 0

	self:Refresh()
	//self:aCasosCont := {}
	self:ZeraArray("aCasosCont")
	self:ZeraArray("aPartiCaso")
	

	// se tiver caso popula os casos do contrato selecionado	
	If self:TemContrato() .AND. len(self:aCasos) > 0
		For ni := 1 to len(self:aCasos)
			If self:aContratos[self:oLbxRatCon:nAt, 2] == self:aCasos[ni][2]
				aAdd( self:aCasosCont , self:aCasos[ni] )
			EndIf
		Next
	EndIf	
	If ascan( self:aCasosCont, { |ax| empty(ax[6]) } ) > 0
		self:aCasosCont := JaRemPos(self:aCasosCont, ascan( self:aCasosCont, { |ax| empty(ax[6])  }  ))
	EndIf

	self:SetArrayCaso()
		
    //Se tiver caso e participantes, popula os participantes do caso selecionado
	If self:TemCaso() .AND. len(self:aParticip) > 0
		For ni := 1 to len(self:aParticip)
			If self:aCasosCont[self:oLbxRatCas:nAt, 2] == self:aParticip[ni][2] .AND. ;
				self:aCasosCont[self:oLbxRatCas:nAt, 3] == self:aParticip[ni][3] .AND. ;
				self:aCasosCont[self:oLbxRatCas:nAt, 4] == self:aParticip[ni][4] .AND. ;
				self:aCasosCont[self:oLbxRatCas:nAt, 6] == self:aParticip[ni][5]
				aAdd( self:aPartiCaso , self:aParticip[ni] )
			EndIf
		Next
	EndIf    
	If ascan( self:aPartiCaso, { |ax| empty(ax[6]) } ) > 0
		self:aPartiCaso := JaRemPos(self:aPartiCaso, ascan( self:aPartiCaso, { |ax| empty(ax[6])  }  ))
	EndIf

	self:SetArrayPart()

	self:SelectContr(self:oLbxRatCon:nAt)
	
	self:Refresh()

Return (.T.)

Method ChCaso() Class TJRATEIOAD 
	Local lRet	:= .F.
	Local ni	:= 0
	
	self:ZeraArray("aPartiCaso")
	//self:Refresh()
	
    //Se tiver participantes, popula os participantes do caso selecionado
	If self:TemCaso() .AND. len(self:aParticip) > 0
		For ni := 1 to len(self:aParticip)
			If self:aCasosCont[self:oLbxRatCas:nAt, 2] == self:aParticip[ni][2] .AND. ;
				self:aCasosCont[self:oLbxRatCas:nAt, 3] == self:aParticip[ni][3] .AND. ;
				self:aCasosCont[self:oLbxRatCas:nAt, 4] == self:aParticip[ni][4] .AND. ;
				self:aCasosCont[self:oLbxRatCas:nAt, 6] == self:aParticip[ni][5]
				aAdd( self:aPartiCaso , self:aParticip[ni] )
			EndIf
		Next
	EndIf
	If ascan( self:aPartiCaso, { |ax| empty(ax[6]) } ) > 0
		self:aPartiCaso := JaRemPos(self:aPartiCaso, ascan( self:aPartiCaso, { |ax| empty(ax[6])  }  ))
	EndIf

	self:SetArrayPart()

	self:SelectCaso(self:oLbxRatCas:nAt)
	
	self:Refresh()

Return ( lRet )
           
Method ChPart() Class TJRATEIOAD 
	Local lRet	:= .F.

	self:selectPart(self:oLbxRatPar:nAt)
	
	self:Refresh()

Return ( lRet )

Method GetGrdPart(nLinha) Class TJRATEIOAD	
	If nLinha <= 0 .OR. nLinha > len(aPartiCaso)
		nLinha := self:oLbxRatPar:nAt
	EndIf
return ( { self:aPartiCaso[nLinha][ 6], self:aPartiCaso[nLinha][ 8] } )



Method ZeraArray(cArray) Class TJRATEIOAD
    Local lRet := .F.
    
	local cVarContr		:=	CriaVar("NT0_COD", .F.)
	local cVarClien		:=	CriaVar("NT0_CCLIEN", .F.)
	local cVarLoja		:=	CriaVar("NT0_CLOJA", .F.)
	local cVarCdCaso	:=	CriaVar("NVE_NUMCAS", .F.)
	local cVarCdPart	:= 	CriaVar("NUR_CPART", .F.)
	local cVarNmPart	:= 	CriaVar("RD0_NOME", .F.)
	local nVarVlItem	:=	0
	local nVarVlSoma	:=	0
	local cVarNmCli		:=	CriaVar("A1_NOME", .F.)
	local cVarNmCont	:=	CriaVar("NT0_NOME", .F.)
	local cVarMnCaso	:= 	CriaVar("NVE_TITULO", .F.)
	local cVarCdSeq		:=	CriaVar("NXD_CSEQ", .F.)
    
	If cArray == "aPartiCaso" 
		self:aPartiCaso		:= {}
		aAdd( self:aPartiCaso, 	{ "", cVarContr,  cVarClien, cVarLoja, cVarCdCaso, cVarCdPart, cVarNmPart, nVarVlItem, nVarVlSoma, cVarCdSeq } )
	EndIf
	If  cArray == "aParticip" 
		self:aParticip		:= {}
		aAdd( self:aParticip,  	{ "", cVarContr,  cVarClien, cVarLoja, cVarCdCaso, cVarCdPart, cVarNmPart, nVarVlItem, nVarVlSoma, cVarCdSeq } )
	EndIf
	If cArray == "aCasosCont" 
		self:aCasosCont		:= {}
		aAdd( self:aCasosCont, 	{ "", cVarContr,  cVarClien, cVarLoja, cVarNmCli, cVarCdCaso, cVarMnCaso, nVarVlItem, nVarVlSoma } )
	EndIf
	If cArray == "aCasos" 
		self:aCasos			:= {}
		aAdd( self:aCasos,     	{ "", cVarContr,  cVarClien, cVarLoja, cVarNmCli, cVarCdCaso, cVarMnCaso, nVarVlItem, nVarVlSoma } )
	EndIf
    if cArray == "aContratos"
		self:aContratos		:= {}
		aAdd( self:aContratos, 	{ "", cVarContr,  cVarNmCont,  nVarVlItem, nVarVlSoma } )
	EndIf
Return ( lRet )

Method TemContrato() Class TJRATEIOAD
	Local lReturn := .F.
	 lReturn := !Empty(self:aContratos) .AND. !Empty(self:aContratos[1][2])
Return ( lReturn ) 

Method TemCaso() Class TJRATEIOAD
	Local lReturn := .F.
	 lReturn := !Empty(self:aCasosCont) .AND. !Empty(self:aCasosCont[1][2]) .AND. !Empty(self:aCasosCont[1][3]) .AND. !Empty(self:aCasosCont[1][4]).AND. !Empty(self:aCasosCont[1][6])
Return ( lReturn ) 

Method TemPart() Class TJRATEIOAD
	Local lReturn := .F.
	 lReturn := !Empty(self:aPartiCaso) .AND. !Empty(self:aPartiCaso[1][2]) .AND. !Empty(self:aPartiCaso[1][3]) .AND. !Empty(self:aPartiCaso[1][4]).AND. !Empty(self:aPartiCaso[1][6])
Return ( lReturn ) 


Method SetArrayContr(nLinhaGrid) Class TJRATEIOAD
    Local lRet := .F.

	Default nLinhaGrid := 1
    
	If Empty(self:aContratos) 
		Self:ZeraArray("aContratos")
		nLinhaGrid		:= 1	
	EndIF
	    
	self:oLbxRatCon:SetArray( self:aContratos )
	self:oLbxRatCon:bLine := { || {;
	self:aContratos[self:oLbxRatCon:nAt, 1], ;
	self:aContratos[self:oLbxRatCon:nAt, 2], ;
	self:aContratos[self:oLbxRatCon:nAt, 3], ;
	Transform(self:aContratos[self:oLbxRatCon:nAt, 4], "@E 99,999,999.99") } }

    if nLinhaGrid > len(self:aContratos)
    	nLinhaGrid := len(self:aContratos)
    EndIF
	self:oLbxRatCon:nAt	:= nLinhaGrid
	
	self:oLbxRatCon:refresh()
	
	lRet := .T.
Return (lRet)

Method SetArrayCaso(nLinhaGrid) Class TJRATEIOAD
    Local lRet := .F.
    
	Default nLinhaGrid := 1

	If Empty(self:aCasosCont)
		Self:ZeraArray("aCasosCont")
		nLinhaGrid		:= 1
	EndIF
	
	self:oLbxRatCas:SetArray( self:aCasosCont )
	self:oLbxRatCas:bLine := { || {;
	self:aCasosCont[self:oLbxRatCas:nAt, 1], ;
	self:aCasosCont[self:oLbxRatCas:nAt, 3], ;
	self:aCasosCont[self:oLbxRatCas:nAt, 4], ;
	self:aCasosCont[self:oLbxRatCas:nAt, 5], ;
	self:aCasosCont[self:oLbxRatCas:nAt, 6], ;
	self:aCasosCont[self:oLbxRatCas:nAt, 7], ;
	Transform(self:aCasosCont[self:oLbxRatCas:nAt, 8], "@E 99,999,999.99")  } }

    if nLinhaGrid > len(self:aCasosCont)
    	nLinhaGrid := len(self:aCasosCont)
    EndIF
	self:oLbxRatCas:nAt	:= nLinhaGrid
	self:selectCaso(self:oLbxRatCas:nAt)
	self:oLbxRatCas:refresh()

	lRet := .T.
Return (lRet)

Method SetArrayPart(nLinhaGrid) Class TJRATEIOAD
    Local lRet := .F.

	Default nLinhaGrid := 1
 
	If Empty(self:aPartiCaso)
		Self:ZeraArray("aPartiCaso")
		nLinhaGrid		:= 1
	EndIf

	self:oLbxRatPar:SetArray( self:aPartiCaso )
	self:oLbxRatPar:bLine := { || {;
	self:aPartiCaso[self:oLbxRatPar:nAt, 01], ;
	self:aPartiCaso[self:oLbxRatPar:nAt, 06], ;
	self:aPartiCaso[self:oLbxRatPar:nAt, 07], ;
	self:aPartiCaso[self:oLbxRatPar:nAt, 10], ;
	Transform(self:aPartiCaso[self:oLbxRatPar:nAt, 08], "@E 99,999,999.99")  } }

    if nLinhaGrid > len(self:aPartiCaso)
    	nLinhaGrid := len(self:aPartiCaso)
    EndIF
    
	self:oLbxRatPar:nAt	:= nLinhaGrid
	self:selectPart(self:oLbxRatPar:nAt)
	self:oLbxRatPar:refresh()

	lRet := .T.
Return (lRet)


Method AddContrato( ) Class TJRATEIOAD
	Local lRet 			:= .T.
	Local nPosContr  	:= 0
	Local nLinhaGrid	:= 0

	if Empty( self:cCodContr )
		lRet := .F.
		JurMsgErro(STR0039)//'É preciso escolher um contrato para o rateio'
		Return lRet
	EndIf
	
	if lRet .AND. Empty( self:nVlCont )
		lRet := .F.
		JurMsgErro(STR0042)//'É preciso informar o valor para o rateio'
		Return lRet
	EndIf
	
	If lRet
		nPosContr  := aScan( self:aContratos , { |ax| ax[2] == self:cCodContr }  )
	EndIf
	
	If lRet .AND. nPosContr > 0
		If self:nVlCont > ( self:acontratos[nPosContr][4] + self:nSaldoCont )
			lRet := .F.
			ApMsgInfo(STR0043)  // Não é possivel utilizar um valor maior do que o saldo.
			Return lRet
		EndIf
	Else
		If lRet .AND. self:nVlCont > self:nSaldoCont
			lRet := .F.
			ApMsgInfo(STR0043)  // Não é possivel utilizar um valor maior do que o saldo.
			Return lRet
		EndIf
	EndIF
	
	If lRet
		
		cTitulo := Posicione('NT0',1,xFilial('NT0')+ self:cCodContr, 'NT0_NOME')
		// Elimina linhas vazias
		If ascan( self:aContratos, { |ax| empty(ax[2]) } ) > 0
			self:aContratos := JaRemPos(self:aContratos, ascan( self:aContratos, { |ax| empty(ax[2])  }  ))
		EndIf
		
		nPosContr := ascan( self:aContratos, { |ax| ax[2] == self:cCodContr } )
		//Se o contrato já está incluído, ajusta o valor, senão inclui
		If nPosContr > 0
			self:nTotCont  := self:nTotCont - self:aContratos[ nPosContr ][4] + self:nVlCont
			self:nTotConCas    := self:aContratos[ nPosContr ][5]
			self:aContratos[ nPosContr ][4] := self:nVlCont
			nLinhaGrid := nPosContr
		Else
			aAdd(self:aContratos, {"", self:cCodContr, cTitulo, self:nVlCont, 0 } )
			self:nTotCont := self:nTotCont + self:nVlCont
			nLinhaGrid := len(self:aContratos)
			self:nTotConCas := 0
		EndIf

		self:SetArrayContr(nLinhaGrid)
		
		self:nSaldoCont := self:nVlRatFat - self:nTotCont
		self:nSldCtCaso := self:aContratos[ self:oLbxRatCon:nAt ][4] - self:nTotConCas

		self:Refresh()

		self:ChContr()

	EndIf

Return ( lRet ) 

Method AddCaso( ) Class TJRATEIOAD
	Local lRet			:= .T.
	Local cNome			:= ""
	Local cTitulo		:= ""

	Local nPosCaso  	:= 0                                       
	Local nPosCasoC 	:= 0
	Local nPosContr 	:= 0 
	Local cQuery		:= ""
	Local nSomaNXD		:= 0
	Local nVlUtiPart	:= 0

	if Empty(self:cCodCliCaso) .OR. Empty(self:cCodLojCaso) .OR. Empty(self:cCodCaso)
		lRet := .F.
		JurMsgErro(STR0039)//'É preciso escolher um Caso para o rateio'
		Return lRet
	EndIf
	
	if Empty(self:nVlCaso)
		lRet := .F.
		JurMsgErro(STR0042)  //'É preciso informar o valor para o rateio'
		Return lRet
	EndIf

	nPosCaso  := ascan( self:aCasosCont    , { |ax| ax[3] == self:cCodCliCaso .AND. ax[4] == self:cCodLojCaso .AND. ax[6] == self:cCodCaso  }  )	
	
	If nPosCaso > 0
		If self:nVlCaso > (self:aCasosCont[nPosCaso][8] + self:nSldCtCaso )
			lRet := .F.
			ApMsgInfo(STR0043)  // Não é possivel utilizar um valor maior do que o saldo.
			Return lRet 
		EndIf
	Else 
		If self:nVlCaso > self:nSldCtCaso
			lRet := .F.
			ApMsgInfo(STR0043)  // Não é possivel utilizar um valor maior do que o saldo.
			Return lRet 
		EndIf
	EndIf

	If lRet
		cNome       := Posicione('SA1',1,xFilial('SA1')+self:cCodCliCaso+self:cCodLojCaso, 'A1_NOME')
		cTitulo     := Posicione('NVE',1,xFilial('NVE')+self:cCodCliCaso+self:cCodLojCaso+self:cCodCaso, 'NVE_TITULO')
		
		If ascan( self:aCasosCont, { |ax| empty(ax[6]) } ) > 0
			self:aCasosCont := JaRemPos(self:aCasosCont, ascan( self:aCasosCont, { |ax| empty(ax[6])  }  ))
		EndIf
		If ascan( self:aCasos, { |ax| empty(ax[6]) } ) > 0
			self:aCasos   := JaRemPos(self:aCasos, ascan( self:aCasos, { |ax| empty(ax[6])  }  ))
		EndIf
		
		nPosContr := aScan( self:aContratos , { |ax| ax[2] == self:cCodContr }  )
		nPosCaso  := ascan( self:aCasos    , { |ax| ax[3] == self:cCodCliCaso .AND. ax[4] == self:cCodLojCaso .AND. ax[6] == self:cCodCaso  }  )
		nPosCasoC := ascan( self:aCasosCont, { |ax| ax[3] == self:cCodCliCaso .AND. ax[4] == self:cCodLojCaso .AND. ax[6] == self:cCodCaso  }  )

		nSomaNXD := self:SomaNXD(self:cCodContr, self:cCodCliCaso, self:cCodLojCaso, self:cCodCaso )
	
		If nSomaNXD == 0
			nVlUtiPart		:= self:nVlCaso
		Else
			nVlUtiPart	:= 0
		EndIf


        //Ajusta os valores utilizados para os caso no array de contrato
		If nPosCasoC > 0
			self:nTotCaso 	:= self:nTotCaso 	- self:aCasosCont[ nPosCasoC ][8] + self:nVlCaso
			self:nSaldoCaso	:= self:nSaldoCaso	- self:aCasosCont[ nPosCasoC ][8] + self:nVlCaso
			self:nTotConCas	:= self:nTotConCas 	- self:aCasosCont[ nPosCasoC ][8] + self:nVlCaso
			self:nSldCtCaso	:= self:aContratos[nPosContr][4] - self:nTotConCas                
			
			self:nTotPart 		:= self:nTotPart 	- self:aCasosCont[ nPosCasoC ][8] + self:nVlCaso
			self:nSaldoPart		:= self:nSaldoPart 	+ self:aCasosCont[ nPosCasoC ][8] - self:nVlCaso
			self:nSldCaPar		:= self:nVlCaso 	- self:aCasos[ nPosCaso ][9]
			
			self:aCasosCont[ nPosCasoC ][8] := self:nVlCaso
			self:aCasos[ nPosCaso ][8]      := self:nVlCaso
			self:aCasosCont[ nPosCasoC ][9] := nVlUtiPart
			self:aCasos[ nPosCaso ][9]      := nVlUtiPart
		Else
			aAdd(self:aCasos    , {"", self:cCodContr,self:cCodCliCaso,self:cCodLojCaso,cNome,self:cCodCaso, cTitulo, self:nVlCaso,nVlUtiPart } )
			aAdd(self:aCasosCont, {"", self:cCodContr,self:cCodCliCaso,self:cCodLojCaso,cNome,self:cCodCaso, cTitulo, self:nVlCaso,nVlUtiPart } )
			self:nTotCaso 		:= self:nTotCaso 	+ self:nVlCaso
			self:nSaldoCaso		:= self:nSaldoCaso 	- self:nVlCaso
			self:nSldCtCaso		:= self:nSldCtCaso  - self:nVlCaso
			self:nTotConCas		:= self:nTotConCas   + self:nVlCaso
			self:nSldCaPar		:= self:nVlCaso 	- nVlUtiPart
			self:nTotPart 		:= self:nTotPart 	+ nVlUtiPart
			self:nSaldoPart		:= self:nSaldoPart	- nVlUtiPart
		EndIf
		
	
		self:aContratos[nPosContr][5] := self:nTotConCas
		
		self:SetArrayCaso()

		If nPosCasoC > 0
			self:oLbxRatCas:nAt := nPosCasoC
		Else
			self:oLbxRatCas:nAt := len(self:aCasosCont)
		EndIF
		self:oLbxRatCas:refresh()

		self:ChCaso()
	
	EndIf


/************************************************/

Return ( lRet ) 

Method AddPart()  Class TJRATEIOAD
	Local lRet 			:= .T.
	Local cNome			:= ""
	Local nPosCasoC		:= 0
	Local nPosCaso		:= 0
	Local nPosPartC		:= 0
	Local nPosPart		:= 0

/*******************************************/


	if Empty(self:cCodPart) .OR. Empty(self:cCodSeq )
		lRet := .F.
		JurMsgErro(STR0041)//'É preciso escolher um Participante para o rateio'
		Return lRet
	EndIf
	
	if Empty(self:nVlPart)
		lRet := .F.
		JurMsgErro(STR0042)//'É preciso informar o valor para o rateio'
		Return lRet
	EndIf
	
	If self:nVlPart > self:nSldCaPar
		lRet := .F.
		ApMsgInfo(STR0043)  // Não é possivel utilizar um valor maior do que o saldo.
		Return lRet
	Else
		cNome := Posicione('RD0',1,xFilial('RD0')+ self:cCodPart, 'RD0_NOME')
		
		If ascan( self:aPartiCaso, { |ax| empty(ax[6]) } ) > 0
			self:aPartiCaso := JaRemPos(self:aPartiCaso, ascan( self:aPartiCaso, { |ax| empty(ax[6])  }  ))
		EndIf
		If ascan( self:aParticip, { |ax| empty(ax[6]) } ) > 0
			self:aParticip := JaRemPos(self:aParticip, ascan( self:aParticip, { |ax| empty(ax[6])  }  ))
		EndIf
		
		nPosCasoC  := ascan( self:aCasosCont, { |ax| ax[3] == self:cCodCliCaso .AND. ax[4] == self:cCodLojCaso .AND. ax[6] == self:cCodCaso  }  )
		nPosCaso   := ascan( self:aCasos    , { |ax| ax[3] == self:cCodCliCaso .AND. ax[4] == self:cCodLojCaso .AND. ax[6] == self:cCodCaso  }  )
		nPosPartC  := ascan( self:aPartiCaso, { |ax| ax[3] == self:cCodCliCaso .AND. ax[4] == self:cCodLojCaso .AND. ax[5] == self:cCodCaso .AND. ax[6] == self:cCodPart .AND. ax[10] == self:cCodSeq  }  )
		nPosPart   := ascan( self:aParticip , { |ax| ax[3] == self:cCodCliCaso .AND. ax[4] == self:cCodLojCaso .AND. ax[5] == self:cCodCaso .AND. ax[6] == self:cCodPart .AND. ax[10] == self:cCodSeq  }  )
		
		If nPosPartC > 0
			self:nTotCaPar	:= self:nTotCaPar  - self:aPartiCaso[nPosPartC][8] + self:nVlPart
			self:nTotPart	:= self:nTotPart - self:aPartiCaso[nPosPartC][8] + self:nVlPart
			self:aPartiCaso[nPosPartC][8] := self:nVlPart
			self:aParticip[nPosPart][8]   := self:nVlPart
		Else
			Aadd(self:aPartiCaso, { "", self:GetSelContr()[1], self:GetSelCaso()[1], self:GetSelCaso()[2], self:GetSelCaso()[3], self:cCodPart, cNome, self:nVlPart, 0, self:cCodSeq } )
			Aadd(self:aParticip , { "", self:GetSelContr()[1], self:GetSelCaso()[1], self:GetSelCaso()[2], self:GetSelCaso()[3], self:cCodPart, cNome, self:nVlPart, 0, self:cCodSeq } )

			self:nTotPart	:= self:nTotPart 	+ self:nVlPart
			self:nSaldoPart	:= self:nSaldoPart	- self:nVlPart
			self:nSldCaPar	:= self:nSldCaPar 	- self:nVlPart
		EndIf
		

		self:nTotCaPar 					:= self:nTotCaPar + self:nVlPart
		self:aCasosCont[nPosCasoC][9] 	:= self:nTotCaPar
		self:aCasos[nPosCaso][9]      	:= self:nTotCaPar
		
		self:SetArrayPart()

		If nPosPartC > 0
			self:oLbxRatPar:nAt := nPosPartC
		Else
			self:oLbxRatPar:nAt := len(self:aPartiCaso)
		EndIF
		
		self:oLbxRatPar:refresh() 
		
		// J203LBCHLN('oLbxRatPar')

	EndIf

/*******************************************/
	
Return ( lRet ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} RemContrato()
Retira o Contrato selecionado do grid

@Return		lRet		Operação concluída com sucesso: .T. - Sim / .F. - Não

@author David G. Fernandes
@since 18/03/10
@version 1.0
/*/
//-------------------------------------------------------------------  	
Method RemContrato() Class TJRATEIOAD
	Local lRet := .T.
	Local nLinha := 0
	Local nI := 0
	Local nPosCont  := 0
	Local nPosCaso  := 0
	Local nPosPart  := 0
	Local nPosCasoC := 0
	Local nPosPartC := 0
	Local nSomaCont := 0
	Local nSomaCaso := 0
	Local nSomaPart := 0


	If !self:TemContrato()
		JurMsgErro(STR0044) //		"Não há itens para remover"
	Else
		
		nLinha := self:oLbxRatCon:nAt
		//Remover os Casos / Participantes do Array e ajustar o saldo
		//While self:TemCaso()
		//	self:RemCaso()
		//EndDo

		While ascan(self:aCasos, { |ax| ax[2] == self:aContratos[nLinha][2]  }  ) > 0
			nPosCaso  := ascan(self:aCasos, { |ax| ax[2] == self:aContratos[nLinha][2]  }  )
			nSomaCaso := nSomaCaso + self:aCasos[nPosCaso][8]
			nSomaPart := nSomaPart + self:aCasos[nPosCaso][9]
			self:aCasos    := JaRemPos(self:aCasos, nPosCaso  )
		End
		self:aCasosCont := {}
		
		While ascan(self:aParticip, { |ax| ax[2] == self:aContratos[nLinha][2]  }  ) > 0
			nPosPart  := ascan(self:aParticip, { |ax| ax[2] == self:aContratos[nLinha][2]  }  )
			//nSomaPart := nSomaPart + self:aParticip[nPosPart][8]
			self:aParticip := JaRemPos(self:aParticip, nPosPart  )
		End
		self:aPartiCaso := {}

		nSomaCont  := self:aContratos[nLinha][4]
		
		self:aContratos := JaRemPos(self:aContratos, nLinha )
		
	EndIf
	If len(self:aContratos) == 0
		self:ZeraArray( "aContratos"	)
		self:ZeraArray( "aCasos" 		)
		self:ZeraArray( "aParticip" 	)
		self:ZeraArray( "aCasosCont" 	)
		self:ZeraArray( "aPartiCaso" 	)
	EndIF
	
	self:SetArrayContr(nLinha)
	
	//	Desc Total Contratos
	self:nTotCont  := self:nTotCont  - nSomaCont
	
	//	Saldo Total Contratos
	self:nSaldoCont := self:nSaldoCont + nSomaCont
	
	//	Desc Total Casos
	self:nTotCaso  := self:nTotCaso  - nSomaCaso
	
	//	Saldo Total Casos
	self:nSaldoCaso := self:nSaldoCaso  + nSomaCaso
	
	//	Desc Total Participantes
	self:nTotPart :=  self:nTotPart - nSomaPart
	
	//	Saldo Total Participantes
	self:nSaldoPart := self:nSaldoPart + nSomaPart

	self:ChContr()

Return ( lRet ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} RemCaso( )
Retira o caso selecionado do grid

@Return		lRet		Operação concluída com sucesso: .T. - Sim / .F. - Não

@author David G. Fernandes
@since 18/03/10
@version 1.0
/*/
//-------------------------------------------------------------------  
Method RemCaso( ) Class TJRATEIOAD
	Local lRet 		:= .T.
	Local nLinha	:= 0
	Local nPosCont	:= 0
	Local nPosPart	:= 0
	Local nSomaCaso := 0
	Local nSomaPart := 0
	Local nSomaCont := 0
	Local ni		:= 0

	If !self:TemCaso()
		JurMsgErro(STR0044) //		"Não há itens para remover"
	Else
		nLinha 		:= self:oLbxRatCas:nAt
		//Remove os Participantes do Array e ajustar o saldo
		nSomaPart := 0

		//While self:TemPart()
		//	self:RemPart()
		//EndDo 

		While ascan(self:aParticip, { |ax| ax[2] == self:aContratos[nLinha][2]  }  ) > 0
			nPosPart  := ascan(self:aParticip, { |ax| ax[2] == self:aContratos[nLinha][2]  }  )
			//nSomaPart := nSomaPart + self:aParticip[nPosPart][8]
			self:aParticip := JaRemPos(self:aParticip, nPosPart  )
		End
		self:aPartiCaso := {}
		
		If self:aCasosCont[nLinha][9] > 0
			self:nTotPart 		:= self:nTotPart 	- self:aCasosCont[ nLinha ][9]
			self:nSaldoPart		:= self:nSaldoPart 	+ self:aCasosCont[ nLinha ][9]
		EndIf
		
		nPosCont	:= aScan(self:aContratos, { |ax| ax[2] == self:aCasosCont[nLinha][2] }  )
		nSomaCont	:= self:aContratos[nLinha][4]
		   
		nPosCaso	 :=  aScan(self:aCasos, { |ax| ax[2] == self:aCasosCont[nLinha][2] .AND.  ;
		ax[3] == self:aCasosCont[nLinha][3] .AND.  ;
		ax[4] == self:aCasosCont[nLinha][4] .AND.  ;
		ax[6] == self:aCasosCont[nLinha][6] }  )
		
		self:aCasos     := JaRemPos(self:aCasos, nPosCaso)
		
		
		nSomaCaso  := self:aCasosCont[nLinha][8]
		self:aContratos[nPosCont][5] := self:aContratos[nPosCont][5] - nSomaCaso
		
		self:aCasosCont := JaRemPos(self:aCasosCont, nLinha )
		
		If len(self:aCasosCont) == 0
			self:ZeraArray( "aCasosCont" 	)
			self:ZeraArray( "aPartiCaso" 	)
		EndIF
		
		self:setArrayCaso(nLinha)
		
		//	Saldo Total Contratos
		self:nSldCtCaso := self:nSldCtCaso + nSomaCaso
		
		//	Desc Total Casos
		self:nTotCaso  	:= self:nTotCaso  - nSomaCaso 
		//Total dos casos para o contrato
		self:nTotConCas	:= self:nTotConCas - nSomaCaso
		
		//	Saldo Total Casos
		self:nSaldoCaso := self:nSaldoCaso  + nSomaCaso
		 
		self:ChCaso()
		
	EndIf

Return ( lRet ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} RemPart()
Retira o Participante selecionado do grid

@Return		lRet		Operação concluída com sucesso: .T. - Sim / .F. - Não

@author David G. Fernandes
@since 18/03/10
@version 1.0
/*/
//-------------------------------------------------------------------  
Method RemPart() Class TJRATEIOAD
	Local lRet 		:= .F.
	Local nLinha	:= 0
	Local nSomaPart	:= 0
	Local nPosCasoC	:= 0
	
	//Remoção de um participante
	If !self:TemPart()
		JurMsgErro(STR0044) //		"Não há itens para remover"
		lRet 		:= .F.
	Else
		nLinha    := self:oLbxRatPar:nAt
		
		nPosCasoC := ascan(self:aCasos, { |ax| , ax[2] == self:aPartiCaso[nLinha][2] .AND.  ;
		ax[3] == self:aPartiCaso[nLinha][3] .AND.  ;
		ax[4] == self:aPartiCaso[nLinha][4] .AND.  ;
		ax[6] == self:aPartiCaso[nLinha][5] }  )
		
		nSomaPart                     			:= self:aPartiCaso[nLinha][8]
		self:aCasosCont[self:oLbxRatCas:nAt][9] := self:aCasosCont[self:oLbxRatCas:nAt][9] - nSomaPart
		self:aCasos[nPosCasoC][9]          		:= self:aCasosCont[self:oLbxRatCas:nAt][9]
		
		self:aParticip := JaRemPos(self:aParticip, ascan(self:aParticip, { |ax| , ax[02] == self:aPartiCaso[nLinha][02] .AND.  ;
		ax[03] == self:aPartiCaso[nLinha][03] .AND.  ;
		ax[04] == self:aPartiCaso[nLinha][04] .AND.  ;
		ax[05] == self:aPartiCaso[nLinha][05] .AND.  ;
		ax[06] == self:aPartiCaso[nLinha][06] .AND.  ;
		ax[10] == self:aPartiCaso[nLinha][10] }  )  )
		
		self:aPartiCaso := JaRemPos(self:aPartiCaso, nLinha )

		self:setArrayPart(nLinha)
/*	
		If nLinha - 1 > 0
			self:oLbxRatPar:nAt := nLinha - 1
		EndIf
*/
		self:nSldCaPar	+= nSomaPart
		self:nTotCaPar	-= nSomaPart
		lRet 		:= .T.
  	EndIf
	
Return ( lRet ) 

Method Refresh() Class TJRATEIOAD
	Local lRet := .F.
	
	self:oGetSldCtCaso:refresh()
	self:oGetTotCasos:refresh()

	self:oGetCodCliCaso:Refresh()
	self:oGetCodLojCaso:Refresh()
	self:oGetCodCaso:Refresh()
	self:oGetVlCaso:Refresh()

	self:oGetCContr:Refresh()
	self:oGetVlCont:Refresh()

	self:oGetCPart:Refresh()
	self:oGetCSeq:Refresh()
	self:oGetVlPart:Refresh()
	lRet := .F.
Return ( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} InsereSaldo()
Insere o saldo automáticamente para os Contratos / Casos e participantes da Fatura

@Return		lRet		Operação concluída com sucesso: .T. - Sim / .F. - Não

@author David G. Fernandes
@since 18/03/10
@version 1.0
/*/
//-------------------------------------------------------------------  
Method InsereSaldo() Class TJRATEIOAD
	Local lRet		:= .F. 
	            
/***************************************************************/
	Local aArea      := GetArea()
	Local cQuery     := ""
	Local cQryRes    := GetNextAlias()
	Local nNXAVLFATH := 0
	Local nNXBDESC   := 0
	Local nSomaNXB   := 0
	Local nSomaNXC   := 0
	Local nSomaNXD   := 0
	Local nResidNXB  := 0
	Local nResidNXC  := 0
	Local nResidNXD  := 0
	Local nLastPos   := 0
	Local nPos       := 0
	Local nNXB       := 0
	Local nNXC       := 0  
	Local nNXD       := 0
	Local nSaldo     := 0
	Local cNome      := ""
	Local cTitulo    := ""  
	Local cSQL       := ""
	
	If (self:nSaldoCont > 0 .OR. self:nSaldoCaso > 0 .OR. self:nSaldoPart > 0  )
		
		//Insere Saldo dos contratos:	
		cQuery := " SELECT SUM(NXB.NXB_VLFATH) SOMANXB " + CRLF
		cQuery += "   FROM " + RetSQLName("NXB") + " NXB               " + CRLF
		cQuery += "  WHERE NXB.D_E_L_E_T_ = ' '                         " + CRLF
		cQuery += "    AND NXB.NXB_FILIAL = '" + xFilial('NXB') + "'   " + CRLF
		cQuery += "    AND NXB.NXB_CESCR  = '" + self:cEscrit + "'          " + CRLF
		cQuery += "    AND NXB.NXB_CFATUR = '" + self:cFatura + "'          " + CRLF
		
		For nNXB := 1 to len(self:aContratos)
			cQuery += "  AND NOT (NXB.NXB_CCONTR = '"+self:aContratos[nNXB][2] +"' ) " 
		Next
		
		cQuery := ChangeQuery(cQuery, .F.)	
		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )		
		
		nSomaNXB  := (cQryRes)->SOMANXB
		
		(cQryRes)->(dbCloseArea())
		
		cQuery := J203QRYRAT(self:cEscrit, self:cFatura, "NXB", '3' )	
		
		cQuery := ChangeQuery(cQuery, .F.)	
		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )		
		
		If ascan( self:aContratos, { |ax| empty(ax[2]) } ) > 0 
			self:aContratos := JaRemPos(self:aContratos, ascan( self:aContratos, { |ax| empty(ax[2])  }  ))
		EndIf
		
		nResidNXB := IIf(self:nSaldoCont == 0, self:nVlRatFat, self:nSaldoCont)
		
		While !(cQryRes)->(EOF())
		
			If !Empty(self:aContratos)
				nPos := aScan(self:aContratos, {|ax| ax[2] == (cQryRes)->NXB_CCONTR} )
			Else 
				nPos := 0
			EndIf
		
			If nPos == 0
	
				If self:nSaldoCont == 0
					nNXBDESC := Round(((cQryRes)->NXB_VLFATH / nSomaNXB ) * self:nVlRatFat, 8)
				Else
					nNXBDESC := Round(((cQryRes)->NXB_VLFATH / nSomaNXB) * self:nSaldoCont, 8)
				EndIf
				
				//Calcula o residuo da divisao
				nResidNXB -= nNXBDESC
				
				aAdd(self:aContratos, {"",(cQryRes)->NXB_CCONTR, (cQryRes)->NT0_NOME, nNXBDESC, 0 } )
				self:nTotCont := self:nTotCont + nNXBDESC
				
				//Armazena a ultima posicao adicionada
				nLastPos := Len(self:aContratos)
				
			EndIf
		
			(cQryRes)->(DbSkip())
		EndDo
	
		//Soma o valor residual da divisao se houver adicao no array aContratos
		If nLastPos > 0
			self:aContratos[nLastPos][4] += nResidNXB
			self:nTotCont += nResidNXB
			nLastPos := 0
		EndIf
			
		(cQryRes)->(dbCloseArea())
		self:nSaldoCont := self:nVlRatFat - self:nTotCont
		
		For nNXB := 1 to len(self:aContratos)
		
			//Insere Saldo dos Casos:
			cQuery := " SELECT SUM(NXC.NXC_VLTS+NXC.NXC_VLTAB) SOMANXC          " + CRLF
			cQuery += "   FROM "+ RetSqlName( 'NXC' ) + " NXC                   " + CRLF
			cQuery += "  WHERE NXC.D_E_L_E_T_ = ' '                              " + CRLF
			cQuery += "    AND NXC.NXC_FILIAL = '" + xFilial('NXC') + "'        " + CRLF
			cQuery += "    AND NXC.NXC_CESCR  = '" + self:cEscrit + "'               " + CRLF
			cQuery += "    AND NXC.NXC_CFATUR = '" + self:cFatura + "'               " + CRLF
			cQuery += "    AND NXC.NXC_CCONTR = '" + self:aContratos[nNXB][2] + "' " + CRLF
			
		  	For nNXC := 1 to len(self:aCasos)
				If self:aCasos[nNXC][2] == self:aContratos[nNXB][2]
					cQuery += "  AND NOT (     NXC.NXC_CCLIEN = '"+self:aCasos[nNXC][3] +"'   " + CRLF
					cQuery += "            AND NXC.NXC_CLOJA  = '"+self:aCasos[nNXC][4] +"'   " + CRLF
					cQuery += "            AND NXC.NXC_CCASO  = '"+self:aCasos[nNXC][6] +"' ) " + CRLF
				EndIF
			Next
		
			cQuery := ChangeQuery(cQuery, .F.)	
			dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )		
		
			nSomaNXC  := (cQryRes)->SOMANXC
		
			(cQryRes)->(dbCloseArea())
		
			cQuery := J203QRYRAT(self:cEscrit, self:cFatura, "NXC", '3' )	
			cQuery += "    AND NXC.NXC_CCONTR = '" + self:aContratos[nNXB][2] + "' " + CRLF
		
		
			cQuery := ChangeQuery(cQuery, .F.)	
			dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )	
		
			If ascan( self:aCasos, { |ax| empty(ax[2]) } ) > 0 
				self:aCasos := JaRemPos(self:aCasos, ascan( self:aCasos, { |ax| empty(ax[2])  }  ))
			EndIf			
		
			nResidNXC := self:aContratos[nNXB][4] - self:aContratos[nNXB][5]
		
			self:nTotConCas := 0
			self:nSldCtCaso := 0
			While !(cQryRes)->(EOF())
			
				If !Empty(self:aCasos)
					nPos := aScan(self:aCasos, {|ax| ax[2] == (cQryRes)->NXC_CCONTR .AND. ;
					ax[3] == (cQryRes)->NXC_CCLIEN .AND. ;
					ax[4] == (cQryRes)->NXC_CLOJA  .AND. ;
					ax[6] == (cQryRes)->NXC_CCASO  } )
				Else 
					nPos := 0
				EndIf
		
				If nPos == 0
		
					If (self:aContratos[nNXB][4] - self:aContratos[nNXB][5]) > 0
						nNXCDESC :=  round( ( (cQryRes)->NXC_VLTS +(cQryRes)->NXC_VLTAB ) / nSomaNXC * (self:aContratos[nNXB][4] - self:aContratos[nNXB][5]) ,  2 )
		
						cNome       := Posicione('SA1',1,xFilial('SA1')+(cQryRes)->NXC_CCLIEN+(cQryRes)->NXC_CLOJA, 'A1_NOME')
						cTitulo     := Posicione('NVE',1,xFilial('NVE')+(cQryRes)->NXC_CCLIEN+(cQryRes)->NXC_CLOJA+(cQryRes)->NXC_CCASO, 'NVE_TITULO')
						
						//Calcula o residuo da divisao
						nResidNXC -= nNXCDESC
		
						//Verifica se o caso possui participantes:
						nSomaNXD := self:SomaNXD((cQryRes)->NXC_CCONTR, (cQryRes)->NXC_CCLIEN, (cQryRes)->NXC_CLOJA, (cQryRes)->NXC_CCASO)
					
						If nSomaNXD == 0
							nVlUtiPart		:= nNXCDESC
							self:nTotPart 	:= self:nTotPart 	+ nNXCDESC
							self:nSaldoPart := self:nSaldoPart 	- nNXCDESC
						Else
							nVlUtiPart	:= 0
						EndIf

						aAdd(self:aCasos,{"",                   ;
								  		(cQryRes)->NXC_CCONTR, ;
								  		(cQryRes)->NXC_CCLIEN, ;
								  		(cQryRes)->NXC_CLOJA,  ;
								  		cNome,                 ;
								  		(cQryRes)->NXC_CCASO,  ;
								  		cTitulo,               ;
								  		nNXCDESC,              ;
								  		nVlUtiPart             } )
		
						//Armazena a ultima posicao adicionada
						nLastPos := Len(self:aCasos)
		
						self:nTotConCas := self:nTotConCas + nNXCDESC
						self:nTotCaso := self:nTotCaso + nNXCDESC 
					EndIf
				EndIf
		
				(cQryRes)->(DbSkip())
			EndDo
			
			//Soma o valor residual da divisao se houver adicao no array aCasos
			If nLastPos > 0
				self:aCasos[nLastPos][8] += nResidNXC
				self:nTotConCas   += nResidNXC
				self:nTotCaso += nResidNXC
				nLastPos := 0
			EndIf
			
			self:aContratos[nNXB][5] := self:aContratos[nNXB][5] + self:nTotConCas
			self:nSldCtCaso := self:aContratos[nNXB][5]
		
			(cQryRes)->(dbCloseArea())
		Next
	
		self:nSaldoCaso := self:nVlRatFat - self:nTotCaso
		
		For nNXC := 1 to len(self:aCasos)
			//Insere Saldo dos Participantes:
		
			cQuery := " SELECT SUM(NXD.NXD_VLADVG) SOMANXD                " + CRLF
			cQuery += "   FROM " + RetSqlName( 'NXD' ) + " NXD            " + CRLF
			cQuery += "  WHERE NXD.D_E_L_E_T_ = ' '                        " + CRLF
			cQuery += "    AND NXD.NXD_FILIAL = '" + xFilial('NXD') + "'  " + CRLF
			cQuery += "    AND NXD.NXD_CESCR  = '" + self:cEscrit + "'         " + CRLF
			cQuery += "    AND NXD.NXD_CFATUR = '" + self:cFatura + "'         " + CRLF
			cQuery += "    AND NXD.NXD_CCLIEN = '"+self:aCasos[nNXC][3] +"'    " + CRLF
			cQuery += "    AND NXD.NXD_CLOJA  = '"+self:aCasos[nNXC][4] +"'    " + CRLF
			cQuery += "    AND NXD.NXD_CCASO  = '"+self:aCasos[nNXC][6] +"'    " + CRLF
				
		  	For nNXD := 1 to len(self:aParticip)
				If (self:aParticip[nNXD][2] == self:aCasos[nNXC][2] .AND. ;
					self:aParticip[nNXD][3] == self:aCasos[nNXC][3] .AND. ;
					self:aParticip[nNXD][4] == self:aCasos[nNXC][4] .AND. ;
					self:aParticip[nNXD][5] == self:aCasos[nNXC][5] )
					cQuery += "  AND NOT (     NXD.NXD_CPART = '"+self:aParticip[nNXD][6] +"' AND NXD.NXD_CSEQ = '" + self:aParticip[nNXD][10] + "' ) " + CRLF
				EndIF
			Next		
		
			cQuery := ChangeQuery(cQuery, .F.)	
			dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )		
		
			nSomaNXD  := (cQryRes)->SOMANXD
		
			(cQryRes)->(dbCloseArea())
		
			cQuery := J203QRYRAT(self:cEscrit, self:cFatura, "NXD", '3' )	
			cQuery += "    AND NXD.NXD_CCLIEN = '"+self:aCasos[nNXC][3] +"'    " + CRLF
			cQuery += "    AND NXD.NXD_CLOJA  = '"+self:aCasos[nNXC][4] +"'    " + CRLF
			cQuery += "    AND NXD.NXD_CCASO  = '"+self:aCasos[nNXC][6] +"'    " + CRLF
		
			cQuery := ChangeQuery(cQuery, .F.)	
			dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )	
		
			If ascan( self:aParticip, { |ax| empty(ax[2]) } ) > 0 
				self:aParticip := JaRemPos(self:aParticip, ascan( self:aParticip, { |ax| empty(ax[2])  }  ))
			EndIf	
		
			//If nSomaNXD > 0 
				nResidNXD := self:aCasos[nNXC][8] - self:aCasos[nNXC][9]
			//Else
			//	nResidNXD := 0
			//	self:aCasos[nNXC][9] 	:= self:aCasos[nNXC][8]
			//	self:nTotPart 			:= self:nTotPart + self:aCasos[nNXC][9]
			//EndIF
		
			self:nTotCaPar := 0
			self:nSldCaPar := 0
		
			While !(cQryRes)->(EOF())
				If !Empty(self:aCasos)
					nPos := aScan(self:aParticip,  {|ax| ax[02] == self:aCasos[nNXC][2]       .AND. ;
														ax[03] == (cQryRes)->NXD_CCLIEN .AND. ;
														ax[04] == (cQryRes)->NXD_CLOJA  .AND. ;
														ax[05] == (cQryRes)->NXD_CCASO  .AND. ;
														ax[06] == (cQryRes)->NXD_CPART  .AND. ;
														ax[10] == (cQryRes)->NXD_CSEQ } )
				Else 
					nPos := 0
				EndIf
		
				If nPos == 0
		
					If (self:aCasos[nNXC][8] - self:aCasos[nNXC][9]) > 0
					
						nNXDDESC := Round( (cQryRes)->NXD_VLADVG  / nSomaNXD * (self:aCasos[nNXC][8] - self:aCasos[nNXC][9]) ,  2 )
						cNome    := Posicione('RD0',1,xFilial('RD0')+(cQryRes)->NXD_CPART, 'RD0_NOME')
						
						//Calcula o residuo da divisao
						nResidNXD -= nNXDDESC
		
						aAdd(self:aParticip, {"",  ;
							self:aCasos[nNXC][2],  ;
							(cQryRes)->NXD_CCLIEN, ;
							(cQryRes)->NXD_CLOJA,  ;
							(cQryRes)->NXD_CCASO,  ;
							(cQryRes)->NXD_CPART,  ;
							cNome,                 ;
							nNXDDESC,              ;
							0,                     ;
							(cQryRes)->NXD_CSEQ  } )
										
						//Armazena a ultima posicao adicionada
						nLastPos := Len(self:aParticip)
						
						self:nTotCaPar 	:= self:nTotCaPar 	+ nNXDDESC 
						self:nTotPart 	:= self:nTotPart 	+ nNXDDESC 
						self:nSaldoPart := self:nSaldoPart	- nNXDDESC
					EndIf
				EndIf
				(cQryRes)->(DbSkip())
			EndDo
			
			//Soma o valor residual da divisao se houver adicao no array aParticip
			If nLastPos > 0
				self:aParticip[nLastPos][8] += nResidNXD
				self:nTotCaPar  += nResidNXD
				self:nTotPart 	+= nResidNXD
				nLastPos := 0
			EndIf
			
			self:aCasos[nNXC][9] := self:aCasos[nNXC][9] + self:nTotCaPar
			self:nSldCaPar := self:aCasos[nNXC][8] - self:aCasos[nNXC][9]
			(cQryRes)->(dbCloseArea())
		Next     
	
		//self:nSaldoPart := self:nVlRatFat - self:nTotPart
	
		self:SetArrayContr() 
		self:SelectContr(1)
		
		self:ChContr()
			
		self:Refresh()
	
		RestArea(aArea)
		
	EndIf
		
/****************************************************************/
	
Return ( lRet ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaRateio()
Grava o valor do rateio nas tabelas de Contratos / Casos / Participantes da Fatura

@Return		lRet		Operação concluída com sucesso: .T. - Sim / .F. - Não

@author David G. Fernandes
@since 18/03/10
@version 1.0
/*/
//-------------------------------------------------------------------   
Method GravaRateio() Class TJRATEIOAD 
	Local lRet		:= .F.  
	Local ni		:= 0
	Local cCpoNXB	:= ""
	Local cCpoNXC	:= ""
	Local cCPoNXD	:= ""
	                     
	If Self:cTipoRat == "1"
		cCpoNXB	:= "NXB_DRATF"
		cCpoNXC	:= "NXC_DRATF"
		cCPoNXD	:= "NXD_DESCTO"
	Else
		cCpoNXB	:= "NXB_ARATF"
		cCpoNXC	:= "NXC_ARATF"
		cCPoNXD	:= "NXD_ACRESC"
	EndIf


	For ni := 1 to len(self:aContratos)
		NXB->(dbSetOrder(3))
		if NXB->( DBSeek( xFilial('NXB') +  self:cEscrit + self:cFatura + self:aContratos[ni][2] ) )   //NXB_FILIAL+NXB_CESCR+NXB_CFATUR+NXB_CCONTR
			RecLock('NXB', .F.)	
			NXB->&(cCpoNXB) := self:aContratos[ni][4]
			NXB->(MsUnlock())
			NXB->(DbSkip())
			NXB->(DbGoTop())
		EndIf
	Next
	For ni := 1 to len(self:aCasos)
		NXC->(dbSetOrder(1))
		if NXC->( DBSeek( xFilial('NXC') +  self:cEscrit + self:cFatura + self:aCasos[ni][3] + self:aCasos[ni][4] + self:aCasos[ni][2] + self:aCasos[ni][6] ) )   //NXC_FILIAL+NXC_CESCR+NXC_CFATUR+NXC_CCLIEN+NXC_CLOJA+NXC_CCONTR+NXC_CCASO
			RecLock('NXC', .F.)			
			NXC->&(cCpoNXC) := self:aCasos[ni][8]
			NXC->(MsUnlock())
			NXC->(DbSkip())
			NXC->(DbGoTop())
		EndIf
	Next

	For ni := 1 to len(self:aParticip)
		NXD->(dbSetOrder(3)) //NXD_FILIAL+NXD_CFATUR+NXD_CESCR+NXD_CCONTR+NXD_CCLIEN+NXD_CLOJA+NXD_CCASO+NXD_CPART+NXD_CSEQ
		If NXD->( DBSeek( xFilial('NXD') +  self:cFatura + self:cEscrit + self:aParticip[ni][2] + self:aParticip[ni][3] + self:aParticip[ni][4] + self:aParticip[ni][5] + self:aParticip[ni][6] + self:aParticip[ni][10] ) )
			RecLock('NXD', .F.)
			NXD->&(cCpoNXD) := self:aParticip[ni][8]
			NXD->(MsUnlock())
			NXD->(DbSkip())
			NXD->(DbGoTop())
		EndIf
	Next
	lRet	:= .T.
Return (lRet)
      
//-------------------------------------------------------------------
/*/{Protheus.doc} SomaNXD(cContr, cClien, cLoja, cCaso)
Retorna o valot faturado para os participantes do caso
- 	utilizado para abater o saldo do participante se não houver participantes
	para o caso incluído
             
@Params		cContr		Código do Contrato
			cClien		Código do Cliente
			cLoja		Código da Loja
			cCaso		Código do Caso
@Return		nSoma		Valor Fatura dos Participantes

@author David G. Fernandes
@since 18/03/10
@version 1.0
/*/
//-------------------------------------------------------------------       
Method SomaNXD(cContr, cClien, cLoja, cCaso)  Class TJRATEIOAD
	Local nSoma := 0
	
	//Verifica se o caso tem participantes / se não tiver retira do saldo do part.
	cQuery := " SELECT SUM(NXD.NXD_VLADVG) SOMANXD                " + CRLF
	cQuery += "   FROM " + RetSqlName( 'NXD' ) + " NXD            " + CRLF
	cQuery += "  WHERE NXD.D_E_L_E_T_ = ' '                        " + CRLF
	cQuery += "    AND NXD.NXD_FILIAL = '" + xFilial('NXD') + "'  " + CRLF
	cQuery += "    AND NXD.NXD_CESCR  = '" + self:cEscrit + "'         " + CRLF
	cQuery += "    AND NXD.NXD_CFATUR = '" + self:cFatura + "'         " + CRLF
	cQuery += "    AND NXD.NXD_CCONTR = '" + cContr + "'         "		 + CRLF
	cQuery += "    AND NXD.NXD_CCLIEN = '" + cClien + "'    " + CRLF
	cQuery += "    AND NXD.NXD_CLOJA  = '" + cLoja + "'    " + CRLF
	cQuery += "    AND NXD.NXD_CCASO  = '" + cCaso + "'    " + CRLF
		

	  nSoma := JurSQl(cQuery, "SOMANXD")[1][1]	

Return (nSoma)

//-------------------------------------------------------------------
/*/{Protheus.doc}  DrawScreen()
Método que constrói a tela do rateio

@author David G. Fernandes
@since 18/03/10
@version 1.0
/*/
//------------------------------------------------------------------- 
Method DrawScreen() Class TJRATEIOAD

	//Objetos da Tela
  Local	OTELA
	
	Local nSizeX := 460
	Local nSizeY := 700

	//Horizontal Boxex
    Local cIdDetalhe
    Local cIdRateio
    Local cIdFooter
	//Panel
    Local oPnlDet
    Local oPnlRat
    Local oPnlFoot
    
	//Mensagens
	Local sScrTitle		:= IIf(self:cTipoRat == "1", STR0001, STR0010)	// "Rateio do Desconto"	/ "Rateio do Acréscimo"		
	Local sVlFatura		:= IIf(self:cTipoRat == "1", STR0002, STR0003)	//"Desconto Fatura"	 /	"Acréscimo Fatura"
	Local sTipoVl		:= IIf(self:cTipoRat == "1", STR0004, STR0005)	//"Desconto" / "Acréscimo"				
	Local sVlRat		:= IIf(self:cTipoRat == "1", STR0006, STR0007)	//"Vl Desc" / "Vl Acres" 				
	Local sVlContr		:= IIf(self:cTipoRat == "1", STR0008, STR0009)	//"Desc Contr" / "Acres Contr"				
	Local sVlCaso		:= IIf(self:cTipoRat == "1", STR0012, STR0013)	//"Desc Casos" / "Acres Casos"				
	Local sVlPart		:= IIf(self:cTipoRat == "1", STR0014, STR0015)	//"Desc Part" / "Acres Part"						

	Local sHdEscr 		:= STR0016 	//"Cód Escritório"		
	Local sHdFatura 	:= STR0017 	//"Número Fat"			
	Local sHdCli 		:= STR0018 	////"Cód Cliente"			

	Local sHdLoja 		:= STR0019 	//"Cód Loja"				
	Local sHdNome		:= STR0020 	//"Nome Cliente"			
	Local sSldContr		:= STR0011	//"Saldo Contr" 			
	Local sSldCaso		:= STR0021	//"Saldo Casos"			
	Local sSldPart		:= STR0022	//"Saldo Part"				
	Local sContr		:= STR0023	//"Contratos"				
	Local sCaso			:= STR0024	//"Casos"					
	Local sPart 		:= STR0025	//"Participantes"			
	Local sCdCont		:= STR0026	//"Cód Contr" 				
	Local sCodCaso		:= STR0027	//"Cód Caso"				
	Local sCodPart		:= STR0028	//"Cód Part"				
	Local sSequen		:= STR0029	//"Sequência"				
	Local sNome			:= STR0030	//"Nome" 					
	Local sTituloCt		:= STR0031	//"Título"				
	Local sAdiciona		:= STR0032	//"Adiciona"				
	Local sRetira		:= STR0033	//"Retira"					
	Local sTotCaso		:= STR0034	//"Tot Caso" 				
	Local sTotPart		:= STR0035	//"Tot Part" 				
	Local sConfirma		:= STR0036	//"Confirma"				
	Local sInsSaldo		:= STR0037	//"Insere Saldo"			
	
//	Local lOK			:= .F.
						

	DEFINE MSDIALOG self:oDlg TITLE sScrTitle FROM 0,0 TO  nSizeX, nSizeY  PIXEL //"Rateio do Desconto"
		oTela      := FWFormContainer():New( self:oDlg )
		
		cIdDetalhe := oTela:CreateHorizontalBox( 30 )
		cIdRateio  := oTela:CreateHorizontalBox( 55 )
		cIdFooter  := oTela:CreateHorizontalBox( 15 )
		oTela:Activate( self:oDlg, .F. )
		
		oPnlDet    := oTela:GeTPanel( cIdDetalhe )
		oPnlRat    := oTela:GeTPanel( cIdRateio  )
		oPnlFoot   := oTela:GeTPanel( cIdFooter  )
		
		//---------------------HEADER-------------------/
		
		@ 003,005 Say sHdEscr Size 040,008 PIXEL OF oPnlDet //"Cód Escritório"
		@ 011,005 MsGet self:oGetEscrit Var self:cEscrit Size 040,009 PIXEL OF oPnlDet HasButton
		self:oGetEscrit:Disable()
		
		@ 003,050 Say sHdFatura  Size 040,008 PIXEL OF oPnlDet //"Número Fat" 
		@ 011,050 MsGet self:oGetFatura Var self:cFatura Size 040,009 PIXEL OF oPnlDet HasButton
		self:oGetFatura:Disable()
		
		@ 003,095 Say sHdCli Size 040,008 PIXEL OF oPnlDet //"Cód Cliente"
		@ 011,095 MsGet self:oGetCClien Var self:cCliente Size 040,009 PIXEL OF oPnlDet HasButton
		self:oGetCClien:Disable()
		
		@ 003,140 Say sHdLoja Size 040,008 PIXEL OF oPnlDet //"Cód Loja"
		@ 011,140 MsGet self:oGetCLoja Var self:cLoja Size 040,009 PIXEL OF oPnlDet HasButton
		self:oGetCLoja:Disable()	
		
		@ 003,185 Say sHdNome Size 050,008 PIXEL OF oPnlDet //"Nome"
		@ 011,185 MsGet self:oGetDClien Var self:cRazao Size 155,009 PIXEL OF oPnlDet HasButton
		self:oGetDClien:Disable()
		
		//------------------------------------------------
		
		// Valores Ratear Rateados
		@ 025,005 Say sVlFatura  Size 050,008 PIXEL OF oPnlDet //"Desconto Fatura" 
		@ 033,005 MsGet self:oGetVlFat Var self:nVlRatFat Size 050,009 Picture '@E 99,999,999.99' PIXEL OF oPnlDet HasButton
		self:oGetVlFat:Disable()
		
		@ 025,180 Say sVlContr  Size 050,008 PIXEL OF oPnlDet //"Desc Contr"
		@ 033,180 MsGet self:oGetVlCon Var self:nTotCont Size 050,009 Picture '@E 99,999,999.99' PIXEL OF oPnlDet HasButton
		self:oGetVlCon:Disable()
		
		@ 025,235 Say sVlCaso Size 050,008 PIXEL OF oPnlDet //"Desc Casos"
		@ 033,235 MsGet self:oGetVlCas Var self:nTotCaso Size 050,009 Picture '@E 99,999,999.99' PIXEL OF oPnlDet HasButton
		self:oGetVlCas:Disable()
		
		@ 025,290 Say sVlPart  Size 050,008 PIXEL OF oPnlDet //"Desc Part"
		@ 033,290 MsGet self:oGetVlPar Var self:nTotPart Size 050,009 Picture '@E 99,999,999.99' PIXEL OF oPnlDet HasButton
		self:oGetVlPar:Disable()
		
		//Saldos
		@ 047,180 Say sSldContr   Size 050,008 PIXEL OF oPnlDet //"Saldo Contr" 
		@ 055,180 MsGet self:oGetSldCon Var self:nSaldoCont Size 050,009 Picture '@E 99,999,999.99' PIXEL OF oPnlDet HasButton
		self:oGetSldCon:Disable()
		
		@ 047,235 Say sSldCaso   Size 050,008 PIXEL OF oPnlDet //"Saldo Casos" 
		@ 055,235 MsGet self:oGetSldCas Var self:nSaldoCaso Size 050,009 Picture '@E 99,999,999.99' PIXEL OF oPnlDet HasButton
		self:oGetSldCas:Disable()
		
		@ 047,290 Say sSldPart   Size 050,008 PIXEL OF oPnlDet //"Saldo Part" 
		@ 055,290 MsGet self:oGetSldPar Var self:nSaldoPart Size 050,009 Picture '@E 99,999,999.99' PIXEL OF oPnlDet HasButton
		self:oGetSldPar:Disable()  
		
		Self:lOk := .T.
			
		/**************************/	
		//-------------------FIM HEADER------------------/
		nSizeX := 350
		nSizeY := 130
		
		//----------------------FOLDER------------------/
		@ 000,002 FOLDER self:oFldRateio OF oPnlRat PROMPT sContr, sCaso, sPart PIXEL SIZE nSizeX, nSizeY  //"Contratos", "Casos", "Participantes"
		
		
		
		//"Cód Contr", "Título" ,"Desconto"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Campos dos Folders - Contratos ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 003,213 Say sCdCont Size 050,008 PIXEL OF self:oFldRateio:aDialogs[1]//"Cód Contr" 
		@ 011,213 MsGet self:oGetCContr Var self:cCodContr Size 050,009 F3 'NXB001' HasButton ;
		          PIXEL OF self:oFldRateio:aDialogs[1] ;
		          VALID ( self:ValidaCodigos("NXB").OR. Empty( self:cCodContr ) )
		
		@ 003,266 Say sVlRat Size 050,008 PIXEL OF self:oFldRateio:aDialogs[1]//"Vl Desc"
		@ 011,266 MsGet self:oGetVlCont Var self:nVlCont Picture '@E 99,999,999.99' Size 050,009 HasButton PIXEL OF self:oFldRateio:aDialogs[1]
		
		//Adiciona Contrato
		@ 002,320 Button self:oBtnAddCt  Prompt sAdiciona Size 025,012 Of self:oFldRateio:aDialogs[1] Pixel ;
		          Action ( self:AddContrato( ) )
		
		//Remove Contrato
		@ 016,320 Button self:oBtnRemCt Prompt sRetira Size 025,012 Of self:oFldRateio:aDialogs[1] Pixel ;
		          Action ( self:RemContrato() )
		
		nSizeX := 345
		nSizeY := 85
		
		@ 029,001 ListBox self:oLbxRatCon Fields Header '', sCdCont, sTituloCt, sTipoVl Size nSizeX,nSizeY Of self:oFldRateio:aDialogs[1] Pixel ; 
		          ON CHANGE ( self:ChContr() )  //"Cód Contr", "Título" ,"Desconto"
		self:SetArrayContr()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Campos dos Folders - Casos ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 003,001 Say sSldContr Size 050,008 PIXEL OF self:oFldRateio:aDialogs[2]//"Saldo Contr"
		@ 011,001 MsGet self:oGetSldCtCaso Var self:nSldCtCaso Size 050,009 HasButton Picture '@E 99,999,999.99' PIXEL OF self:oFldRateio:aDialogs[2]
		self:oGetSldCtCaso:Disable()
		
		@ 003,054 Say sTotCaso Size 050,008 PIXEL OF self:oFldRateio:aDialogs[2]//"Tot Caso" 
		@ 011,054 MsGet self:oGetTotCasos Var self:nTotConCas Size 050,009  HasButton Picture '@E 99,999,999.99' PIXEL OF self:oFldRateio:aDialogs[2]
		self:oGetTotCasos:Disable()
		
		@ 003,107 Say sHdCli Size 050,008 PIXEL OF self:oFldRateio:aDialogs[2]//"Cód Cliente"
		@ 011,107 MsGet self:oGetCodCliCaso Var self:cCodCliCaso Size 050,009 F3 'NXC001' HasButton ;
		          PIXEL OF self:oFldRateio:aDialogs[2] ;
		          VALID ( self:ValidaCodigos("NXC") .OR. Empty( self:cCodCliCaso ) .OR. Empty( self:cCodLojCaso ) .OR. Empty( self:cCodCaso ) )
		
		@ 003,160 Say sHdLoja Size 050,008 PIXEL OF self:oFldRateio:aDialogs[2]//"Cód Loja"
		@ 011,160 MsGet self:oGetCodLojCaso Var self:cCodLojCaso Size 050,009  HasButton ;
		          PIXEL OF self:oFldRateio:aDialogs[2] ;
		          VALID ( self:ValidaCodigos("NXC") .OR. Empty( self:cCodCliCaso ) .OR. Empty( self:cCodLojCaso ) .OR. Empty( self:cCodCaso ) )
		
		@ 003,213 Say sCodCaso Size 050,008 PIXEL OF self:oFldRateio:aDialogs[2]//"Cód Caso"
		@ 011,213 MsGet self:oGetCodCaso Var self:cCodCaso Size 050,009  HasButton ;
		          PIXEL OF self:oFldRateio:aDialogs[2] ;
		          VALID ( self:ValidaCodigos("NXC") .OR. Empty( self:cCodCliCaso ) .OR. Empty( self:cCodLojCaso ) .OR. Empty( self:cCodCaso ) )
		
		@ 003,266 Say sVlRat Size 050,008 PIXEL OF self:oFldRateio:aDialogs[2]//"Vl Desc"
		@ 011,266 MsGet self:oGetVlCaso Var self:nVlCaso Picture '@E 99,999,999.99' Size 050,009 HasButton PIXEL OF self:oFldRateio:aDialogs[2]
		
		//Adiciona Casos
		@ 002,320 Button self:oBtnAddCs Prompt sAdiciona Size 025,012 Of self:oFldRateio:aDialogs[2] Pixel ;
		          Action ( self:AddCaso() )
		
		//Remove Casos
		@ 016,320 Button self:oBtnRemCs Prompt sRetira Size 025,012 Of self:oFldRateio:aDialogs[2] Pixel ;
		          Action ( self:RemCaso( ) )

		nSizeX := 345
		nSizeY := 85
		
		@ 029,001 ListBox self:oLbxRatCas Fields Header '',sHdCli, sHdLoja, sHdNome, sTotCaso, sTituloCt , sTipoVl  Size nSizeX,nSizeY  Of self:oFldRateio:aDialogs[2] Pixel ;
		          ON CHANGE ( self:ChCaso() )       //"Cód Cliente","Loja", "Nome Cliente", "Cód Caso", "Título" ,"Desconto"

		self:SetArrayCaso()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Campos dos Folders - Participante ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 003,001 Say sSldCaso Size 050,008 PIXEL OF self:oFldRateio:aDialogs[3]//"Saldo Caso" 
		@ 011,001 MsGet self:oGetSldCaPar Var self:nSldCaPar Size 050,009 HasButton Picture '@E 99,999,999.99' PIXEL OF self:oFldRateio:aDialogs[3]
		self:oGetSldCaPar:Disable()
		
		@ 003,054 Say sTotPart Size 050,008 PIXEL OF self:oFldRateio:aDialogs[3]//"Tot Part" 
		@ 011,054 MsGet self:oGetTotPart Var self:nTotCaPar Size 050,009  HasButton Picture '@E 99,999,999.99' PIXEL OF self:oFldRateio:aDialogs[3]
		self:oGetTotPart:Disable()
		
		@ 003,160 Say sCodPart Size 050,008 PIXEL OF self:oFldRateio:aDialogs[3]//"Cód Part"
		@ 011,160 MsGet self:oGetCPart Var self:cCodPart Size 050,009 F3 'NXD001' HasButton ;
		          PIXEL OF self:oFldRateio:aDialogs[3] ;
		          VALID ( self:ValidaCodigos("NXD") .OR.  Empty( self:cCodPart ) .OR. Empty( self:cCodSeq ) )
		          
		@ 003,213 Say sSequen Size 050,008 PIXEL OF self:oFldRateio:aDialogs[3] //"Cód Sequência"
		@ 011,213 MsGet self:oGetCSeq Var self:cCodSeq Size 050,009  HasButton ;
		          PIXEL OF self:oFldRateio:aDialogs[3] ;
		          VALID ( self:ValidaCodigos("NXD") .OR. Empty( self:cCodPart ) .OR. Empty( self:cCodSeq ) )
		
		@ 003,266 Say sVlRat Size 040,008 PIXEL OF self:oFldRateio:aDialogs[3]//"Vl Desc"
		@ 011,266 MsGet self:oGetVlPart Var self:nVlPart Picture '@E 99,999,999.99' Size 050,009 HasButton PIXEL OF self:oFldRateio:aDialogs[3]

		//Adiciona Participantes
		@ 002,320 Button self:oBtnAddPt  Prompt sAdiciona Size 025,012 Of self:oFldRateio:aDialogs[3] Pixel ;
		          Action ( self:AddPart() )
		
		//Remove Participantes
		@ 016,320 Button self:oBtnRemPt Prompt sRetira Size 025,012 Of self:oFldRateio:aDialogs[3] Pixel ;
		          Action ( self:RemPart() )

		nSizeX := 345
		nSizeY := 85
		
		@ 029,001 ListBox self:oLbxRatPar Fields Header '', sCodPart, sNome, sSequen, sTipoVl  Size nSizeX,nSizeY Of self:oFldRateio:aDialogs[3]  Pixel ; //"Sequência"
		          ON CHANGE ( self:ChPart() )  //"Cód Part", "Nome" ,"Desconto"

		self:SetArrayPart()


		//----------------------FOLDER------------------/

		//-------------------------------------------------------------------
		// Define a área dos botões
		//-------------------------------------------------------------------    
		//Confirma
		@ oPnlFoot:nTop + 05, oPnlFoot:nLeft + 005 Button self:oBtnOk  Prompt STR0036 Size 35, 12 Of oPnlFoot Pixel ;
		                                           Action ( iif(self:Confirma(), ( Self:lOk := .T., self:oDlg:End()), Self:lOk := .F.))

		//Cancela
		@ oPnlFoot:nTop + 05, oPnlFoot:nLeft + 045 Button self:oBtnCancel  Prompt STR0056 Size 35, 12 Of oPnlFoot Pixel ;
		                                           Action ( iif(!self:Cancela(), ( Self:lOk := .F., self:oDlg:End()), ))		         		
		
		//Insere Saldo
		@ oPnlFoot:nTop + 05, oPnlFoot:nLeft + 085 Button self:oBtnSld Prompt STR0037 Size 35, 12 Of oPnlFoot Pixel ;
		                                           Action ( self:InsereSaldo() )   
		                                           
Return (Self:lOk)

Method ActiveScreen() Class TJRATEIOAD

	ACTIVATE MSDIALOG self:oDlg CENTERED

Return (Self:lOk)

Method Confirma()  Class TJRATEIOAD 
Local lRet := .F. 

  if Self:lOk
			
		If self:ValidaSaldos()
			if self:GravaRateio()
				lRet := .T.
			Else
				lRet := .F.
	  			JurMsgErro(STR0053) // Erro ao Gravar o rateio na Fatura.
			EndIF
			
		EndIf
	
	Else
	  lRet := .F.
	Endif  	
	
Return (lRet)      

Method Cancela()  Class TJRATEIOAD 
Local lRet := .T. 

  If MsgYesNo(STR0055) //"Deseja realmente cancelar a Rotina Rateio?"
	  lRet := .F.		
  	JurMsgErro(STR0054) // "Rotina de Rateio cancelada pelo usuário"
  Endif	

Return (lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaCodigos(cAlias)

Verifica se os códigos digitados na inclusão de 
	 Contrato / Caso / Participante existem na fatura

@Params	cAlias		Código da tabela que será validada

@author David G. Fernandes
@since 18/03/10
@version 1.0
/*/
//------------------------------------------------------------------- 
Method ValidaCodigos(cAlias)  Class TJRATEIOAD 
	Local lRet		:= .F.  
	Local aArea := GetArea()
	Local cQuery := ""
	Local cQryRes := GetNextAlias()

	cQuery := J203QRYRAT(self:cEscrit, self:cFatura,cAlias, '1' )

	If cAlias == 'NXB'
		cQuery += "    AND NXB.NXB_CCONTR = '" + self:cCodContr  + "' " + CRLF

		cQuery := ChangeQuery(cQuery, .F.)	
		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )		
		lRet := (cQryRes)->COUNTNXB > 0

	ElseIf cAlias == 'NXC'
		cQuery += "    AND NXC.NXC_CCONTR = '" + self:cCodContr  + "' " + CRLF
		cQuery += "    AND NXC.NXC_CCLIEN = '" + self:cCodCliCaso  + "' " + CRLF
		cQuery += "    AND NXC.NXC_CLOJA  = '" + self:cCodLojCaso + "' " + CRLF
		cQuery += "    AND NXC.NXC_CCASO  = '" + self:cCodCaso   + "' " + CRLF

		cQuery := ChangeQuery(cQuery, .F.)	
		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )		

		lRet := (cQryRes)->COUNTNXC > 0	

	ElseIf cAlias = 'NXD'
		cQuery += "    AND NXD.NXD_CCLIEN = '" + self:cCodCliCaso  + "' " + CRLF
		cQuery += "    AND NXD.NXD_CLOJA  = '" + self:cCodLojCaso + "' " + CRLF
		cQuery += "    AND NXD.NXD_CCASO  = '" + self:cCodCaso   + "' " + CRLF
		cQuery += "    AND NXD.NXD_CPART  = '" + self:cCodPart   + "' " + CRLF
		cQuery += "    AND NXD.NXD_CSEQ   = '" + self:cCodSeq    + "' " + CRLF
	
		cQuery := ChangeQuery(cQuery, .F.)	
		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )		
	
		lRet := (cQryRes)->COUNTNXD > 0		
	
	EndIf
	    '
	(cQryRes)->(dbCloseArea())
	
	RestArea(aArea)

	                                        
Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaSaldos()

Verifica se os valores reteados batem com os totais para o
	 Contrato / Caso / Participante

@author David G. Fernandes
@since 18/03/10
@version 1.0
/*/
//------------------------------------------------------------------- 
Method ValidaSaldos()  Class TJRATEIOAD 
	Local lRet		:= .T.  
	Local cQuery := ""
	Local cQryRes := GetNextAlias()
	Local nNXB := 0
	Local nNXC := 0
	Local nNXD := 0
	Local nSomaNXB := 0
	Local nSomaNXC := 0
	Local nSomaNXD := 0
	Local nTotNXB := 0
	Local nTotNXC := 0
	Local cMsg := ""
	Local nCount := 0    

	cQuery := J203QRYRAT(self:cEscrit, self:cFatura, 'NXD', '1' )
	cQuery := ChangeQuery(cQuery, .F.)	
	
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )
	
	nCount := (cQryRes)->COUNTNXD
	(cQryRes)->(dbCloseArea())
	
	If lRet .AND.  (self:nSaldoCont < 0 .OR. self:nSaldoCaso < 0 .OR. (self:nSaldoPart < 0 .AND. nCount > 0 ) )
		cMsg := STR0045 //"O saldo não pode ser negativo"
		lRet := .F.
	End
	If lRet .AND. (self:nSaldoCont > 0 .OR. self:nSaldoCaso > 0 .OR. (self:nSaldoPart > 0 .AND. nCount > 0 ) )
		cMsg := STR0046 //"É preciso zerar os saldos antes de continuar"
		lRet := .F.
	End	
	
	If lRet
		For nNXB := 1 to len(self:aContratos)
			nTotNXB := self:aContratos[nNXB][4]
			nSomaNXB := nSomaNXB + self:aContratos[nNXB][4]
			nSomaNXC := 0
			
			For nNXC := 1 to len(self:aCasos)
				if self:aContratos[nNXB][2] == self:aCasos[nNXC][2]
					nTotNXC := self:aCasos[nNXC][8]
					nSomaNXC := nSomaNXC + self:aCasos[nNXC][8]
					nSomaNXD := 0
					For nNXD := 1 to len(self:aParticip)
						If 	self:aCasos[nNXC][2] == self:aParticip[nNXD][2] .AND. ;
							self:aCasos[nNXC][3] == self:aParticip[nNXD][3] .AND. ;
							self:aCasos[nNXC][4] == self:aParticip[nNXD][4] .AND. ;
							self:aCasos[nNXC][6] == self:aParticip[nNXD][5]
							nSomaNXD := nSomaNXD +  self:aParticip[nNXD][8]
						EndIf
					Next		
					If 	! (self:aCasos[nNXC][8] == self:aCasos[nNXC][9])
						If self:cTipoRat == "1"
							cMsg := STR0047 + CRLF //"O Valor do desconto rateado para os Participantes não bate com o valor do desconto para o Caso: (Cód. Contr / Cli / Loja / Caso:)"
						Else
							cMsg := STR0050 + CRLF //"O Valor do a rateado para os Participantes não bate com o valor do desconto para o Caso: (Cód. Contr / Cli / Loja / Caso:)"
						EndIf
						cMsg += self:aCasos[nNXC][2] + ' / ' + self:aCasos[nNXC][3] + ' / ' + self:aCasos[nNXC][4] + ' / ' + self:aCasos[nNXC][6]
						lRet := .F.
					EndIf
				EndIf
			Next		
		
			If lRet .AND. (nTotNXB <> nSomaNXC)
				If self:cTipoRat == "1"
					cMsg := STR0048 + CRLF //"O Valor do desconto rateado para os Casos não bate com o valor do desconto para o Contrato: (Cód. Contr :)"
				Else
					cMsg := STR0051 + CRLF  //"O Valor do acréscimo rateado para os Casos não bate com o valor do desconto para o Contrato: (Cód. Contr :)"
				EndIf
				cMsg += self:aContratos[nNXB][2] 
				lRet := .F.
			EndIf		
		
		Next
		If lRet .AND.( self:nVlRatFat <> nSomaNXB)
			If self:cTipoRat == "1"
				cMsg := STR0049 //"O Valor Rateado para os Contratos não bate com o desconto da Fatura. "
			Else
				cMsg := STR0052	//"O Valor Rateado para os Contratos não bate com o acréscimo da Fatura. "
			EndIf
			lRet := .F.
		EndIf			
	EndIf  
	  
	If !lRet
		JurMsgErro(cMsg)  
	EndIf
	
Return (lRet)
