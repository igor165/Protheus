#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} AGRA605
//
@author bruna.rocio
@since 20/05/2016
@version 1.0
@type function
/*/
Function AGRA605()
	Local aArea    	:= GetArea()
	Private oBrowse	:= Nil
			
	//-------------------------
	//Instancia o objeto Browse
	//-------------------------
	oBrowse := FWMBrowse():New( , , , , , , , , , ,)
	oBrowse:SetAlias('DXB')
	oBrowse:SetDescription( "Fardão X Produção" ) //"Cadastro de Fardões"
		
	oBrowse:Activate()
		
	RestArea(aArea)

Return ()

/*/{Protheus.doc} ModelDef
Retorna o modelo de visualização da rotina

@author Bruna Fagundes Rocio
@since 20/05/2016
@Uso AGRA601
@type function
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStruDXB  := FwFormStruct( 1, "DXB" ) 
	
	//-----------------------------
	// Instancia o modelo de dados
	//-----------------------------
	oModel := MpFormModel():New( "AGRA605",/*bPre*/ ,/*bPost*/ ,/*bCommit*/ , /*bCancel*/)
	oModel:SetDescription( "Fardão X Produção" ) 

	// Adiciona a field no modelo de dados
	oModel:AddFields( "AGRA605_DXB", , oStruDXB )
	oModel:GetModel( "AGRA605_DXB" ):SetDescription( "Fardão X Produção" ) 
Return (oModel)

//-----------------------------------------------------------
/*/{Protheus.doc} ViewDef
Retorna o modelo de visualização da rotina

@author Bruna Fagundes Rocio
@since 20/05/2016
@Uso AGRA601
@type function
/*/
//-----------------------------------------------------------
Static Function ViewDef()
	Local oStruDXB  := FwFormStruct( 2, "DXB" )  
	Local oModel	:= FwLoadModel( "AGRA605" )
	Local oView		:= FwFormView():New() // Instancia o modelo de dados
	
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_DXB', oStruDXB, 'AGRA605_DXB' )
	oView:CreateHorizontalBox( 'TOTAL', 100 )
	oView:SetOwnerView( 'VIEW_DXB', 'TOTAL' )

Return (oView)

//-----------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna o Menu padrão da rotina

@author Aecio Ferreira Gomes
@since 08/11/2012
@Uso AGRA601
@type function
/*/
//-----------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina Title OemToAnsi("Visualizar") Action 'VIEWDEF.AGRA605'	OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title OemToAnsi("Imprimir")	 Action 'VIEWDEF.AGRA605'	OPERATION 6 ACCESS 0 //"Imprimir"
		
Return aRotina

/*/{Protheus.doc} AGR605GRAVA
//Geração da tabela DXB
@author bruna.rocio
@since 23/05/2016
@version undefined
@param cNumOP, character, número da OP
@param cProd, character, código do produto
@param cLocal, character, código do local de estoque
@param cDoc, character, número do documento 
@type function
/*/
Function AGR605GRAVA( )
	Local aArea     := GetArea()
	Local lRet      := .T. 
	Local oModel    := FwLoadModel('AGRA605')
	Local oGridDXB	:= oModel:GetModel('AGRA605_DXB')
	
	// Seta a operação do modelo como INCLUSÃO
	oModel:SetOperation(3)
	
	If oModel:Activate()
						
			//Grava tabela de relacionamentos - DXB
			oGridDXB:LoadValue("DXB_FILIAL",FwXFilial("DXB"))
			oGridDXB:LoadValue("DXB_EMISSA",dDataBase)
			oGridDXB:LoadValue("DXB_FARDAO",M->DXL_CODIGO)
			oGridDXB:LoadValue("DXB_SAFRA" ,M->DXL_SAFRA)
			oGridDXB:LoadValue("DXB_PRDTOR",M->DXL_PRDTOR)
			oGridDXB:LoadValue("DXB_LJPRO" ,M->DXL_LJPRO)
			oGridDXB:LoadValue("DXB_FAZ"   ,M->DXL_FAZ)
			oGridDXB:LoadValue("DXB_OP"    ,PADR(SD3->D3_OP,TamSX3('DXB_OP')[1],''))
			oGridDXB:LoadValue("DXB_CODPRO",SD3->D3_COD)
			oGridDXB:LoadValue("DXB_DOC"   ,SD3->D3_DOC)
			oGridDXB:LoadValue("DXB_LOCAL" ,SD3->D3_LOCAL)
			oGridDXB:LoadValue("DXB_NUMSEQ",SD3->D3_NUMSEQ)
			oGridDXB:LoadValue("DXB_CF"    ,SD3->D3_CF)
			oGridDXB:LoadValue("DXB_TM"    ,SD3->D3_TM)	
			oGridDXB:LoadValue("DXB_ROTINA",FunName())
			If DXB->(ColumnPos("DXB_LOTCTL")) > 0 .And. DXB->(ColumnPos("DXB_NMLOT")) > 0 .And. DXB->(ColumnPos("DXB_LOCLIZ")) > 0 .And. DXB->(ColumnPos("DXB_CODUNI")) > 0 
				oGridDXB:LoadValue("DXB_LOTCTL",SD3->D3_LOTECTL)
				oGridDXB:LoadValue("DXB_NMLOT" ,SD3->D3_NUMLOTE)
				oGridDXB:LoadValue("DXB_LOCLIZ",SD3->D3_LOCALIZ)
				oGridDXB:LoadValue("DXB_CODUNI",M->DXL_CODUNI)
			EndIf
		If (lRet := oModel:VldData())
			//Efetiva gravacao dos dados na tabela
			lRet := oModel:CommitData()
		Else
			oModel:SetErrorMessage( , , , , , oModel:GetErrorMessage()[6])	
			If IsInCallStack('AGRA620EA')
					cRotEA := 'AGR605GRAVA'
					cErroEA   := oModel:GetErrorMessage()[6]
			EndIf		
		EndIf
	Endif	
	oModel:DeActivate()
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} AGR605RETDES
// Retorna o documento de desmontagem
@author bruna.rocio
@since 26/05/2016
@version undefined
@param cFardao, characters, código do fardao
@param cSafra, characters, código da safra do fardão
@param cPrdtor, characters, código do produtor do fardão
@param cLjpro, characters, código da loja do produtor
@param cFaz, characters, código da fazenda do produtor
@type function
/*/
Function AGR605RETDES(cFardao, cSafra, cPrdtor, cLjpro, cFaz)
	Local aArea  := GetArea()
	Local aArray := {}
	Local lSeek := .F.
	
	dbSelectArea('DXB')
	dbSetOrder(1)
	If dbSeek(FwXFilial('DXB')+cFardao+cSafra+cPrdtor+cLjpro+cFaz+"AGRA620") 
		lSeek := .T.
	ElseIf dbSeek(FwXFilial('DXB')+cFardao+cSafra+cPrdtor+cLjpro+cFaz+"AGRA615") //o encerramento pode ser automatico via AGRA615
		lSeek := .T.
	EndIf

	If lSeek		
		While !DXB->(Eof())                      .And. ;
		      DXB->DXB_FILIAL = FwXFilial('DXB') .And. ;
		      DXB->DXB_FARDAO = cFardao          .And. ;
		      DXB->DXB_SAFRA  = cSafra           .And. ;
		      DXB->DXB_PRDTOR = cPrdtor          .And. ;
		      DXB->DXB_LJPRO  = cLjpro           .And. ;
		      DXB->DXB_FAZ    = cFaz             .And. ;
		      Alltrim(DXB->DXB_ROTINA) $ "AGRA620|AGRA615"		 
		     		     		     
		     If Substr(DXB->DXB_CF,1,2) = "RE" //Requisição da Desmontagem
		        aArray    := { , }
		      	aArray[1] := DXB->DXB_DOC
		      	aArray[2] := DXB->DXB_NUMSEQ
		     Endif 
		     
		     DXB->(dbSkip()) 
		EndDo
	Endif
	
	RestArea(aArea)
Return aArray


/*/{Protheus.doc} AGR605DESPRO
//Retorna um array com as produções do fardão
@author bruna.rocio
@since 26/05/2016
@version undefined
@param cFardao, characters, código do fardao
@param cSafra, characters, código da safra do fardão
@param cPrdtor, characters, código do produtor do fardão
@param cLjpro, characters, código da loja do produtor
@param cFaz, characters, código da fazenda do produtor
@type function
/*/
Function AGR605DESPRO(cFardao, cSafra, cPrdtor, cLjpro, cFaz)
	Local aArea := GetArea()
	Local aProd := {}
	Local lSeek := .F.
		
	dbSelectArea('DXB')
	dbSetOrder(1)
	If dbSeek(FwXFilial('DXB')+cFardao+cSafra+cPrdtor+cLjpro+cFaz+"AGRA620") 
		lSeek := .T.
	ElseIF dbSeek(FwXFilial('DXB')+cFardao+cSafra+cPrdtor+cLjpro+cFaz+"AGRA615") //o encerramento pode ser automatico via AGRA615
		lSeek := .T.
	EndIf
		
	If lSeek
		While !DXB->(Eof())                      .And. ;
		      DXB->DXB_FILIAL = FwXFilial('DXB') .And. ;
		      DXB->DXB_FARDAO = cFardao          .And. ;
		      DXB->DXB_SAFRA  = cSafra           .And. ;
		      DXB->DXB_PRDTOR = cPrdtor          .And. ;
		      DXB->DXB_LJPRO  = cLjpro           .And. ;
		      DXB->DXB_FAZ    = cFaz             .And. ;
		      Alltrim(DXB->DXB_ROTINA) $ "AGRA620|AGRA615"
		     		     
		     If Substr(DXB->DXB_CF,1,2) = "PR" //Movimentação de Produção
		     	aAdd(aProd,{DXB->DXB_DOC, DXB->DXB_OP, DXB->DXB_CODPRO, DXB->DXB_NUMSEQ})		      	
		     Endif 
		     DXB->(dbSkip()) 
		EndDo
	Endif

	RestArea(aArea)
Return aProd


/*/{Protheus.doc} AGR605DEL
//Deleta DXB
@author bruna.rocio
@since 30/05/2016
@version undefined
@param cFardao, characters, descricao
@param cSafra, characters, descricao
@param cPrdtor, characters, descricao
@param cLjpro, characters, descricao
@param cFaz, characters, descricao
@type function
/*/
Function AGR605DEL(cFardao, cSafra, cPrdtor, cLjpro, cFaz, cRotina)
	Local aArea  := GetArea()
	Local lRet   := .t.
	Local oMdDXB := FwLoadModel('AGRA605')
	Local lSeek := .F. //se posicionou na pesquisa
	
	oMdDXB:SetOperation(5)	
		
	dbSelectArea('DXB')
	DXB->(dbSetOrder(1))
	If DXB->(dbSeek(FwXFilial('DXB')+cFardao+cSafra+cPrdtor+cLjpro+cFaz+cRotina))
		lSeek := .T.
	ElseIF Alltrim(cRotina) == "AGRA620" .and. DXB->(dbSeek(FwXFilial('DXB')+cFardao+cSafra+cPrdtor+cLjpro+cFaz+"AGRA615"))
		lSeek := .T.
		cRotina := "AGRA615" //para tratar quando o encerramento é automatico pela rotina AGRA615
	EndIF

	IF lSeek
		While 	!DXB->(Eof())                      .And. ;
				DXB->DXB_FILIAL = FwXFilial('DXB') .And. ;
				DXB->DXB_FARDAO = cFardao          .And. ;
				DXB->DXB_SAFRA  = cSafra           .And. ;
				DXB->DXB_PRDTOR = cPrdtor          .And. ;
				DXB->DXB_LJPRO  = cLjpro           .And. ;
				DXB->DXB_FAZ    = cFaz             .And. ;
				DXB->DXB_ROTINA = cRotina 
				
			oMdDXB:Activate()
			If (lRet := oMdDXB:VldData())
				oMdDXB:CommitData()
			Else
				oMdDXB:SetErrorMessage( , , , , , oMdDXB:GetErrorMessage()[6]) 
			End
			oMdDXB:DeActivate()
			
			DXB->(dbSkip())
		EndDo
	Endif	      
	
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} AGR605GRVPD
// Registro de rastreabilidade de nota fiscal e apontamento de produção relacionados a complemento de produto
@author bruna.rocio
@since 05/07/2016
@version P12
@type function
/*/
Function AGR605GRVPD( cOP, cProd, cDoc, cLocal, cNumSeq, cCF, cTM, cNumPed, nQuant )
	Local aArea     := GetArea()
	Local lRet      := .T. 
	Local oModel    := FwLoadModel('AGRA605')
	Local oGridDXB	:= oModel:GetModel('AGRA605_DXB')
	
	// Seta a operação do modelo como INCLUSÃO
	oModel:SetOperation(3)
	
	If oModel:Activate()
						
			//Grava tabela de relacionamentos - DXB
			oGridDXB:LoadValue("DXB_FILIAL",FwXFilial("DXB"))
			oGridDXB:LoadValue("DXB_EMISSA",dDataBase)
			oGridDXB:LoadValue("DXB_FARDAO",M->DXL_CODIGO)
			oGridDXB:LoadValue("DXB_SAFRA" ,M->DXL_SAFRA)
			oGridDXB:LoadValue("DXB_PRDTOR",M->DXL_PRDTOR)
			oGridDXB:LoadValue("DXB_LJPRO" ,M->DXL_LJPRO)
			oGridDXB:LoadValue("DXB_FAZ"   ,M->DXL_FAZ)
			Iif(!Empty(cOP), oGridDXB:LoadValue("DXB_OP"    ,cOP), ) 
			Iif(!Empty(cProd), oGridDXB:LoadValue("DXB_CODPRO",cProd), )
			Iif(!Empty(cDoc), oGridDXB:LoadValue("DXB_DOC"   ,cDoc), )
			Iif(!Empty(cLocal), oGridDXB:LoadValue("DXB_LOCAL" ,cLocal), )
			Iif(!Empty(cNumSeq), oGridDXB:LoadValue("DXB_NUMSEQ",cNumSeq), )
			Iif(!Empty(cCF), oGridDXB:LoadValue("DXB_CF"    ,cCF), )
			Iif(!Empty(cTM), oGridDXB:LoadValue("DXB_TM"    ,cTM), )
			Iif(!Empty(cNumPed), oGridDXB:LoadValue("DXB_NUMPED",cNumPed), )
			oGridDXB:LoadValue("DXB_QUANT" ,nQuant)
			oGridDXB:LoadValue("DXB_ROTINA","COMPLFCL")
			If DXL->(ColumnPos("DXL_CODUNI")) > 0
				oGridDXB:LoadValue("DXB_CODUNI",M->DXL_CODUNI)
			EndIf
			
		If (lRet := oModel:VldData())
			//Efetiva gravacao dos dados na tabela
			lRet := oModel:CommitData()
		Else
			oModel:SetErrorMessage( , , , , , oModel:GetErrorMessage()[6])			
		EndIf
	Endif	
	oModel:DeActivate()
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} AGR605GRVNF
// Registro de rastreabilidade de nota fiscal e apontamento de 
// produção relacionados a complemento de produto
@author bruna.rocio
@since 05/07/2016
@version undefined
@type function
/*/
Function AGR605GRVNF( cFardao, cSafra, cNF, cSerie, cRotina )
	Local aArea     := GetArea()
	Local lRet      := .T. 
	Local oModel    := FwLoadModel('AGRA605')
	Local oGridDXB	:= oModel:GetModel('AGRA605_DXB')
	
	dbSelectArea('DXB')
	dbSetOrder(2)
	If dbSeek(xFilial('DXB')+cFardao+cSafra+cRotina)
	
		// Seta a operação do modelo como ALTERAÇÃO
		oModel:SetOperation(4)
		
		If oModel:Activate()
			oGridDXB:LoadValue("DXB_DOCNF", cNF)
			oGridDXB:LoadValue("DXB_SERIE", cSerie)
							
			If (lRet := oModel:VldData())
				//Efetiva gravacao dos dados na tabela
				lRet := oModel:CommitData()
			Else
				oModel:SetErrorMessage( , , , , , oModel:GetErrorMessage()[6])			
			EndIf
		Endif	
		oModel:DeActivate()	
	Endif
		
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} AGR605VLDPR
@author bruna.rocio
@since 29/08/2016
@version undefined
@type function
/*/
Function AGR605VLDPR( oModel, cRotina, nTotProd) 
	Local aArea      := GetArea()
	Local oMdDX0     := oModel:GetModel('MdGridDX0')
	Local oMdDXM     := oModel:GetModel('MdFieldDXM')
	Local nX         := 1
	
	For nX := 1 to oMdDX0:Length()
		oMdDX0:GoLine( nX )
		
		If !oMdDX0:IsDeleted()
		
			dbSelectArea('DXB')
			dbSetOrder(2)
			If !dbSeek(fwxFilial('DXB')+oMdDX0:GetValue('DX0_FARDAO')+oMdDXM:GetValue('DXM_SAFRA')+PADR(cRotina,TamSX3('DXB_ROTINA')[1],''))
				nTotProd  += oMdDX0:GetValue('DX0_PSLIQU')
			Endif
			DXB->(DbCloseArea())	
		Endif		
	Next nX			

	RestArea(aArea)
Return .T.
