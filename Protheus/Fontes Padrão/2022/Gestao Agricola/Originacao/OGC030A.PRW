#Include 'Protheus.ch'
#Include 'OGC030A.ch'

sTatic cRet :=''
Static oTrbNNH  := Nil
/** {Protheus.doc} OGC030A
Consulta Padrão especifica de tipos de descontos,
que permite selecionar os tipos de descontos a retornar

@param: 	Nil
@return:	OGC030AA() -> Itens selecionados separados por (;)
@author: 	Emerson
@since: 	18/02/2015
@Uso: 		Agro (oga430)
*/

Function OGC030A()

	Local nTamH 		:= ( GetScreenRes()[1] - 600 )
	Local nTamV 		:= ( GetScreenRes()[2] - 400 )
	Local aButtons	:= {}
	Local nOpc			:= 0
//	Local cRet			:= ''
	Local nI			:= 0

// -- Vars Utilizada para Gerar TRB NNH --//rwNNH
	Private	cTrbNNH
		
	Private   aColumns		:= {}
// -- Vars Utilizada para Gerar TRB NNH --//

	Private oMrkNNH	:= Nil
	Private aMarcados	:= separa(&(readvar()), ';')
	Private nSelMax	:= 6			//Nr maximo de Itens a Marcar
	Private cMarca	:=GetMark()	//Definindo o Caracter da Marca

	Private oDlg		:= Nil

	oDlg := TDialog():New( 0, 0, nTamV, nTamH, STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //Consulta Tipos de Descontos
	oDlg:lEscClose := .f.

	fGerTrbNNH()		//-- Gerando Arquivo de Temporario --
	fObrwNNH(odlg)	//-- Gerando o Fwmarkbrowse			--

	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( oDlg, {|| nOpc := 1, oDlg:End() },{|| nOpc := 0, oDlg:End() },, @aButtons ) } )

	cRet := ''
	If nOpc > 0 .And. Len( aMarcados ) > 0
		For nI := 1 to Len( aMarcados )
			cRet+=aMarcados[nI]
			If ! nI = Len( aMarcados )
				cRet += ';'
			EndIf
		nExt nI
	Else
		cRet:= &(readvar())
	EndIf
	
    //Deletando o Arquivo Temporario
    AGRDLTPTB(oTrbNNH)

Return( .t. )


/** {Protheus.doc} fGerTrbNNH
Função que Cria o Arq. de auxilio, que será utilizado pelo
browse oMrkNNH , e tbem o Acolumns do Browse

@param: 	Nil
@return:	Acolumns e cTrbNNH (vars. Private) estarão criados
@author: 	Emerson
@since: 	18/02/2015
@Uso: 		Agro (oga430)
*/

Static Function fGerTrbNNH()
	Local  aFieldsNNH 	:= NNH->( dbStruct() )
	Local	 nX				:=0
	Local aAuxMrkdos		:= aMarcados
	
	aMarcados	:= {} // Inicializa aRRay amarcados
	
	CursorWait()

	//-- Add Campos Auxiliares --//
		
	aAdd( 	aFieldsNNH , { 'MARCAX', 		'C', 				2,					0} ) 	// -- Campo que obtera a Marca 	//

// -- verifica se temporario está aberto dou um Zap
	If Select( cTrbNNH ) > 0
		DbSelectArea( cTrbNNH )
		Zap
	Else
	cTrbNNH := GetNextAlias()
	oTrbNNH := AGRCRTPTB(cTrbNNH, {aFieldsNNH, {{"", "NNH_CODIGO"}, {"", "NNH_DESCRI,NNH_CODIGO"} } } )
	Endif

	DBSELECTAREA('NNH')
	NNH->(DbSetOrder(1))
	cFilter := " NNH->NNH_FILIAL == '" + fWxFilial( 'NNH' ) + "'"
	// .AND. NNH->NNH_CODCTR == '" + NN8->NN8_CODCTR + "' .AND. NNH->NNH_ITEMFX == '" + NN8->NN8_ITEMFX + "'"
	NNH->( DBSetFilter ( {|| &cFilter}, cFilter) )
	NNH->( DbGoTop() )

	While NNH->(! Eof() )  // -- NNH já se encontra Filtrada -- //
		
		reclock(cTRBNNH,.t. )
			
		for nX := 1 to Len( aFieldsNNH ) // -- Atribui Vrs. ao TRB --//
			
			Do Case
			Case Alltrim( aFieldsNNH[Nx , 1 ] ) == 'MARCAX'
				(cTRBNNH)->&(aFieldsNNH[Nx , 1 ] ) := ''
				
				IF aScan( aAuxMrkdos, NNH->NNH_CODIGO ) > 0 	// Verificando se devo gravar algum item como já selecionado
					(cTRBNNH)->&(aFieldsNNH[Nx , 1 ] ) := cMarca
					aAdd(aMarcados , NNH->NNH_CODIGO )			//aDiciona Item Marcado ao array aMarcados
				EndIf
			Otherwise
				(cTRBNNH)->&(aFieldsNNH[Nx , 1 ] ) := NNH->&(aFieldsNNH[Nx , 1 ] )
			EndCase
		neXt nX
				
		
		(cTRBNNH)->( msUnLock() )
		
		NNH->( DbSkip() )
		
	EndDo
	
	NNH->( DbClearFilter() )
	
	
	//Define as colunas a serem apresentadas na markbrowse
	aCposBrowse := {"NNH_CODIGO","NNH_DESCRI" }

	For nX := 1 To Len( aCposBrowse )
		nPos := AScan(aFieldsNNH, {|x| x[1] == aCposBrowse[nX] } )

		AAdd( aColumns,FWBrwColumn():New() )
		IF npos > 0
			cCampo		:= aFieldsNNH[nPos][1]
			cTipo		:= TAMSX3(aFieldsNNH[nPos][1])[3]
			cTitulo		:= X3TITULO(aFieldsNNH[nPos])
			nTamanho	:= TAMSX3(aFieldsNNH[nPos][1])[1]
			nDecimal	:= TAMSX3(aFieldsNNH[nPos][1])[2]
			cPicture 	:= X3PICTURE(aFieldsNNH[nPos][1])
		EndIF
 				
		aColumns[ Len(aColumns) ]:SetData( &("{||" +  cCampo +"}")	)
		aColumns[ Len(aColumns) ]:SetType( cTipo						)
		aColumns[ Len(aColumns) ]:SetTitle( cTitulo					)
		aColumns[ Len(aColumns) ]:SetSize(nTamanho					)
		aColumns[ Len(aColumns) ]:SetDecimal(nDecimal					)
		aColumns[ Len(aColumns) ]:SetPicture( cPicture 					)
		aColumns[ Len(aColumns) ]:SetAlign( If(TAMSX3(aFieldsNNH[nPos][1])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento

	nExt nX
	
	(cTrbNNH)->(dbSetOrder(1)) 		// -- Abre o Indice						--//	
	CursorArrow()
	
Return( nil )

/** {Protheus.doc} fObrwNNH
	Função que Cria/Atualiza o MarkBrowse da tabela de vincs.
	entre romaneios e fixação. (NNH)

@param: 	oPnd1	-> Owner do browse(onde o brose será ancorado
@return:	nil			(Atencao oMrkNNH é objeto Private )
@author: 	E.Coelho
@since: 	18/02/2015
@Uso: 		Agro (oga430)
*/
	
Static Function fObrwNNH(oOwner)
	
	Local cAliasMrk    	:= cTrbNNH
	Local aColsBRW		:= aColumns

	//------------------------------------------
	//Criação da MarkBrowse da NNH
	//------------------------------------------
	IF oMrkNNH == nil
		oMrkNNH:=FwMarkBrowse():New()

		oMrkNNH:SetDescription( STR0002 + cValtochar(nSelMax) + STR0003 ) //"Selecione até "//" Tipos de Descontos "
          
		oMrkNNH:SetFieldMark("MARCAX")
		
		oMrkNNH:SetOwner(oOwner)
		oMrkNNH:SetDataQuery(.F.)
		oMrkNNH:SetDataTable(.T.)
		oMrkNNH:SetAlias( cAliasMrk )
		oMrkNNH:cMark:=cMarca
		
		oMrkNNH:SetCustomMarkRec({|| fmarcar( oMrkNNH ) })
			
		oMrkNNH:bAllMark := { ||  }
			
		oMrkNNH:SetMenuDef("OGC030A")
		oMrkNNH:SetColumns( aColsBRW )
		oMrkNNH:DisableConfig(.t.)
		oMrkNNH:DisableReport(.t.)
		oMrkNNH:Activate()
	Else
		
		oMrkNNH:SetAlias( cAliasMrk )
		oMrkNNH:Refresh()
	EndIF
	oLegend := FWLegend():New()
	oMrkNNH:oBrowse:Setfocus()
	
	
	(oMrkNNH:Alias())->( dBGotop() )

Return
	
	
/*/{Protheus.doc} fMarcar(oMrkBrowse)
	Atualiza Marcador do FWMarkBrowse
	
	@param        ExpO     Objeto da MarkBrowse(FWMarkBrowse).
	@sample     fMarcar(oMrkBrowse)
	@return    ExpL    Verdadeiro / Falso
	@author    Agro
	@since      27/01/2015
	@version    P11
/*/
Static Function fMarcar( oMrkBrowse )

	DbSelectArea( cTrbNNH )
	
		
	If ( !oMrkBrowse:IsMark() ) .and. len(aMarcados) < 6
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->MARCAX  := oMrkBrowse:Mark()
		(oMrkBrowse:Alias())->(MsUnLock())
		aAdd(aMarcados,(oMrkBrowse:Alias())->NNH_CODIGO )
			
	Else
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->marcax  := ""
		(oMrkBrowse:Alias())->(MsUnLock())
			
		nPosItMrk := aScan(aMarcados, (oMrkBrowse:Alias())->NNH_CODIGO ) // retorno esperado
		If nPosItMrk > 0
			aDel(aMarcados, nPosItMrk)
			aSize(aMarcados,len(aMarcados)-1)
		EndIf
	EndIf
			
	
Return( .T. )


/** {Protheus.doc} OGC030AA
Função que Retorna os Itens Marcados

@param: 	Nil
@return:	cRet -> Cod. dos Tipos de Desctos Selecionados
@author: 	Emerson
@since: 	18/02/2015
@Uso: 		Agro (OGC030A)
*/

function OGC030AA()
Return(cRet)