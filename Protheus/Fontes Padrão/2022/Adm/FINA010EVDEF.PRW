#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA010.CH'

//---------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA010EVDEF
Eventos padrão do cadastro de Naturezas, as regras definidas aqui se aplicam a todos os paises.
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente. 

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type Class
 
@author Pedro Pereira Lima
@since 26/05/2017
@version P12.1.17
 
/*/
//---------------------------------------------------------------------------------------------------------------------
CLASS FINA010EVDEF From FWModelEvent
	DATA nOpc			As Numeric
	DATA lFWCodFil		As Logical
	DATA lHistFiscal	As Logical

	METHOD New() CONSTRUCTOR

	METHOD ModelPosVld()	
	METHOD DeletePosVld()	
	METHOD CheckDel()
	METHOD InTTS()	

ENDCLASS
//---------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe FINA010EVDEF

@type Method

@author Pedro Pereira Lima
@since 26/05/2017
@version 12.1.17
 
/*/
//---------------------------------------------------------------------------------------------------------------------
METHOD New() CLASS FINA010EVDEF

	::nOpc			:= 0		
	::lFWCodFil		:= .T.
	::lHistFiscal	:= HistFiscal()

Return Self
//---------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método de validação do modelo antes da gravação dos dados

@type Method

@author Pedro Pereira Lima
@since 26/05/2017
@version 12.1.17
 
/*/
//---------------------------------------------------------------------------------------------------------------------
METHOD ModelPosVld( oModel, cID ) CLASS FINA010EVDEF
Local lValid	As Logical
Local lIntPFS   As Logical

	lValid   := .T.
	lIntPFS  := SuperGetMV("MV_JURXFIN",,.F.) // Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico

	::nOpc := oModel:GetOperation()
	
	If ::nOpc == MODEL_OPERATION_DELETE
		lValid := ::DeletePosVld()
	EndIf
	
	If lValid .And. lIntPFS .And. ExistFunc("JVldFin010")
		lValid := JVldFin010(oModel) // Validações dos campos da aba Jurídico
	EndIf
	
Return lValid
//---------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DeletePosVld()
Método de validação da exclusão do modelo 

@type Method

@author Pedro Pereira Lima
@since 19/05/2017
@version 12.1.17

/*/
//---------------------------------------------------------------------------------------------------------------------
METHOD DeletePosVld() CLASS FINA010EVDEF
Local lValid	As Logical
Local aDeleta	As Array
Local nX		As Numeric
Local nRecSED	As Numeric
Local lConfDel	As Logical
Local bCampoSED As Codeblock
Local lAutomato As Logical
Local lGetParAut As Logical
Local aRetAuto As Array
	
	lGetParAut := .T.	
	lValid		:= .T.
	aDeleta		:= {}
	nX			:= 0
	nRecSED		:= 0
	lConfDel	:= .T.
	bCampoSED	:= { |x| SED->(Field(x)) } //Somente para operação de DELETE

	lAutomato	:= ExistFunc("GetParAuto")	

	If lAutomato .And. IsBlind()	
		aRetAuto	:= GetParAuto("FINA010TestCase")
		If ValType(aRetAuto) =="A" .And. Len(aRetAuto) == 1  
			If Valtype(aRetAuto[1]) == "L" 
				lGetParAut := aRetAuto[1]						
			EndIf 
		EndIf
	EndIf
	
	//----------------------------------------------------------------------
	// Antes de deletar, verificar se existe movimentação
	//----------------------------------------------------------------------
	aDeleta := ::CheckDel()
		
	If aDeleta[1]
	
		dbSelectArea( 'SED' )
		nRecSED := Recno()
	
		//----------------------------------------------------------------------
		// Antes de deletar, verificar se é pai
		//----------------------------------------------------------------------
		lNatPai := If( FwFldGet('ED_TIPO') == '1', .T., .F.) //Se natureza é Tipo 1.Sintética, então é pai
			
		If(lAutomato) .OR. IsBlind()
			lConfDel := .T.	
		ElseIf(lNatPai)
			lConfDel := MsgYesNo( STR0066, STR0062 ) // "Confirma Exclusão?"    //.T.   //Sintética sem filhos, posso excluir.  SX9 -> 'N'
		Else
			lConfDel := MsgYesNo( STR0066, STR0062 ) // "Confirma Exclusão?"
		EndIf
		
		If lConfDel	    		
			RecLock('SED',.F.,.T.)
			
			//Reordeno o array das Naturezas para excluir primeiro os filhos
			aDeleta[2] := aSort( aDeleta[2], , , { | x,y | x > y} )
			For nX := 1 to Len( aDeleta[2] )
				DbSeek( xFilial() + aDeleta[2,nX] )
				RecLock('SED',.F.)
			
				If !FKDelete()
					Help( " ", 1, "A010NAODEL" )
					lValid := .F.
				EndIf
			
				MsUnLock()
			Next nX  	
		Else
			lValid := .F.
			Help(,,STR0068,,STR0069,1,0)
		Endif
		
		//----------------------------------------------------------------------
		// Preenche o array com os campos, para gravação do Histórico.
		//----------------------------------------------------------------------
		If ::lHistFiscal 
			aCmps :=  RetCmps( "SED", bCampoSED )	
			GrvHistFis( "SED", "SS7", aCmps )
			aCmps := {} 
		EndIf											
	
	Else
		HELP(' ',,"FINA010NATCOL" ,,STR0078,1,0,,,,,,)//"Não é possivel excluir entidade com filhos ou Analíticas com Movimentos!!
		lValid := .F.
	EndIf

Return lValid
//---------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckDel()
Método que verifica se a natureza pode ser excluída, se não há movimento em nenhuma filial 

@type Method

@author Pedro Pereira Lima
@since 19/05/2017
@version 12.1.17

/*/
//---------------------------------------------------------------------------------------------------------------------
METHOD CheckDel() CLASS FINA010EVDEF
Local lDeleta		As Logical
Local aArea			As Array
Local aAreaSM0		As Array
Local cSavFil		As Character
Local cNatExc		As Character
Local aNaturezas	As Array
Local aCodPai		As Array

	lDeleta		:= .T.
	aArea		:= GetArea()
	aAreaSM0	:= SM0->(GetArea()) // Salva a area do SM0
	cSavFil		:= cFilAnt
	cNatExc		:= SED->ED_CODIGO
	aNaturezas	 := {} 
	aCodPai		:= {}
	nX			:= 0
	//----------------------------------------------------------------------
	// Monta array com todas as naturezas filhas relacionadas a solicitação de exclusão
	//-------------------------------------------------------------------------------------
	dbSelectArea( 'SED' )
	dbSetOrder( 2 )
	If SED->ED_TIPO = '2'
		// se a naturez for analitica, então, adiciono em aNaturezas para verificar se existe movimento
		AAdd( aNaturezas, cNatExc )
	Else
	  	// se não for analitica, procuro pelaS analiticas filhas para adicionar em aNaturezas 
		//Verifico se é pai de alguma natureza
		//ed_filial+ed_pai ORDER 2
		If dbSeek(xFilial("SED")+cNatExc)
			// tem filha não posso exluir
			lDeleta := .F.
		Else
			// não tem fila -> posso exluir
			lDeleta  := .T.  // Sintetica sem filhos, pode excluir
			AAdd( aNaturezas, cNatExc )
		EndIf
	  // se não for analitica, procuro pelaS analiticas filhas para adicionar em aNaturezas 
	EndIf
	
	cFilAnt := cSavFil
	SM0->( RestArea( aAreaSM0 ) )
	RestArea(aArea)
Return {lDeleta, aNaturezas}

//---------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InTTS()
Método que é chamado pelo MVC quando ocorrer as ações do commit após as gravações, porém antes do final da transação. 

@author Cristina Cintra
@since 17/01/2018
@version 12.1.17
/*/
//---------------------------------------------------------------------------------------------------------------------
Method InTTS(oSubModel, cModelId) Class FINA010EVDEF

	If ExistFunc("JInTtsSED")
		JInTtsSED(oSubModel)
	EndIf

Return 

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FilterFRN
Filtro usado na consulta padrão FRMSQ1 e FRMIN1
Esta função foi removida dos fontes FINA010COS e FINA010DOM pois estava gerando erro na compilação
pois estava repetida no rpo. 

@type Function
@author Rodrigo Oliveira
@since 01/06/2017
@version 12.1.17
@param nPesq, numérico, identificador da Pesquisa padrão
@return cRet, caracter, filtro a ser aplicado na consulta
/*/
//-------------------------------------------------------------------------------------------------------------
Function FilterFRN() As Character
Local cRet		 As Character
Local oModel	 As Object
Local oModelFRN	 As Object

	oModel		:= FwModelActivate()
	oModelFRN	:= oModel:GetModel("FRNDETAIL")
	cRet := 'FRM->FRM_COD == ' + oModelFRN:GetValue("FRN_IMPOST") + ' .And. FRM_SEQ <> "000"'

Return cRet
