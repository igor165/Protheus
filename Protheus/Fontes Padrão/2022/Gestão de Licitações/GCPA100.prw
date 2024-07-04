#include "GCPA100.CH"
#Include "Protheus.ch"
#Include "FWMVCDEF.CH"
#Include "FWEVENTVIEWCONSTS.CH"
#Include "GCPA100.CH" 

Static lLGPD := FindFunction("SuprLGPD") .And. SuprLGPD()

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA100()
Cadastro de Analise de Mercado.
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCPA100()
Local oBrowse	
Local aLegenda	:= {}
Local aGCP100LG	:= {}
Local nX		:= 0

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('COM')
	oBrowse:SetDescription(STR0001)//'Cadastro de Análises de Mercado'
	
	Aadd(aLegenda, {"COM_STATUS=='1'", "GREEN", STR0002}) //"Aberto"
	Aadd(aLegenda, {"COM_STATUS=='2'", "RED"  , STR0003}) //"Fechado"
	Aadd(aLegenda, {"COM_STATUS=='3'", "BLUE" , STR0004}) //"Gerado Por processo licitatório"
	
	// Ponto de Entrada para customização da legenda
	IF ExistBlock("GCP100LG")
		aGCP100LG := ExecBlock("GCP100LG",.F.,.F.,{aLegenda})
		If ValType(aGCP100LG) == "A"
			aLegenda := aGCP100LG
		EndIf
	Endif 

	For nX := 1 to len(aLegenda)
		oBrowse:AddLegend(aLegenda[nX][1], aLegenda[nX][2], aLegenda[nX][3])
	Next nX
	
	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Matheus Lando Raimundo
@since 03/07/13 
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCOM := FWFormStruct(1,'COM')
Local oStruCON := FWFormStruct(1,'CON')
Local oStruCOO := FWFormStruct(1,'COO')  
Local oStruCOP := FWFormStruct(1,'COP')                                          
Local oModel   := MPFormModel():New('GCPA100', ,{|oModel|GCPPosVld(oModel)},{|oModel|GCPCommit(oModel)})
Local bVldCalc := {|x| GCP100Calc(x) }
oModel:SetVldActivate({|oModel|VldActivate(oModel, @oStruCOM)})

oModel:AddFields('COM_MASTER', /*cOwner*/, oStruCOM) //-- Cadastro do Análises
oModel:AddGrid('CON_DETAIL', 'COM_MASTER', oStruCON) //-- Produtos
oModel:AddGrid('COO_DETAIL', 'CON_DETAIL', oStruCOO,{|oModelGrid, nLine,cAction,cField|PreValCOO(oModelGrid, nLine, cAction, cField)}) //-- Solicitações
oModel:AddGrid('COP_DETAIL', 'CON_DETAIL', oStruCOP,{|oModelGrid, nLine,cAction,cField|PreValCOP(oModelGrid, nLine, cAction, cField)}, {|oModelGrid|LinhaOkCOP(oModelGrid)}) //--Fornecedores

oModel:SetRelation('CON_DETAIL',{{'CON_FILIAL','xFilial("CON")'}, {'CON_CODIGO', 'COM_CODIGO'}},CON->(IndexKey(1)))
oModel:SetRelation('COO_DETAIL',{{'COO_FILIAL','xFilial("COO")'}, {'COO_CODIGO', 'COM_CODIGO'},{'COO_CODPRO','CON_CODPRO'} },COO->(IndexKey(1)))
oModel:SetRelation('COP_DETAIL',{{'COP_FILIAL','xFilial("COP")'}, {'COP_CODIGO', 'COM_CODIGO'},{'COP_CODPRO','CON_CODPRO'} },COP->(IndexKey(1)))

// Adiciona descricoes para as partes do modelo
oModel:SetDescription(STR0010)//"Analise de Mercado"

oModel:GetModel('COM_MASTER'):SetDescription(STR0011) //"Resumo"
oModel:GetModel('CON_DETAIL'):SetDescription(STR0012)//"Produtos"
oModel:GetModel('COO_DETAIL'):SetDescription(STR0013)//"Solicitações"
oModel:GetModel('COP_DETAIL'):SetDescription(STR0014) //"Forncedores Consultados"

oModel:SetPrimaryKey({'COM_FILIAL'},{'COM_CODIGO'})

oModel:GetModel("CON_DETAIL"):SetUniqueLine({"CON_FILIAL", "CON_CODIGO", "CON_CODPRO" })
oModel:GetModel("COP_DETAIL"):SetUniqueLine({"COP_TIPO", "COP_CODFOR" , "COP_LOJFOR" })

oModel:GetModel("COO_DETAIL"):SetOptional(.T.)
oModel:GetModel("COP_DETAIL"):SetOptional(.T.)
oModel:GetModel("COO_DETAIL"):SetNoInsertLine(.T.)
oModel:AddCalc('GCP100CALC','COM_MASTER','CON_DETAIL','CON_VALEST','CONESTTOT','SUM', bVldCalc,,'Soma')

oStruCOP:AddTrigger('COP_PRCUN','COP_VALTOT',{||.T.}, {||GCPCalcPUn()})

oModel:GetModel('CON_DETAIL'):SetMaxLine( 99999 )

oStruCOM:SetProperty("COM_MODACA",MODEL_FIELD_VALID,{|a,b,c,xoldvalue|FWInitCpo(a,b,c,xoldvalue),lRet:=GCP100VlMd(xoldvalue),FWCloseCpo(a,b,c,lRet,.T.),lRet})
oModel:SetActivate({|oModel| GCPA100Ins(oModel)})

Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel('GCPA100') 
//Definição das Estruturas, removendo a visualização de alguns campos.

Local oStruCOM := FWFormStruct(2,'COM')
Local oStruCON := FWFormStruct(2,'CON', {|cCampo| !AllTrim(cCampo) $ "CON_CODIGO, CON_LOTE , CON_REVISA"}) 
Local oStruCOP := FWFormStruct(2,'COP', {|cCampo| !AllTrim(cCampo) $ "COP_CODIGO, COP_CODPRO, COP_LOTE"})
Local oStruCOO := FWFormStruct(2,'COO', {|cCampo| !AllTrim(cCampo) $ "COO_CODIGO, COO_CODPRO, COO_LOTE"})
Local oView    := FWFormView():New()

oView:SetModel(oModel)  //-- Define qual o modelo de dados será utilizado

oView:AddField('VIEW_COM',oStruCOM, 'COM_MASTER')
oView:AddGrid('VIEW_CON' ,oStruCON, 'CON_DETAIL')
oView:AddGrid('VIEW_COO' ,oStruCOO, 'COO_DETAIL')
oView:AddGrid('VIEW_COP' ,oStruCOP, 'COP_DETAIL')

//-- Divide a tela nas partes a utilizar
oView:CreateHorizontalBox('CIMA',36)
oView:CreateHorizontalBox('MEIO',28)
oView:CreateHorizontalBox('BAIXO',36)

oView:CreateFolder("FOLDER","MEIO")                                 //-- cria uma pasta no box inferior
oView:AddSheet("FOLDER","FLDCOD1",STR0015)//"Produtos"
oView:AddSheet("FOLDER","FLDCOD2",STR0016)//"Solicitações"

oView:CreateHorizontalBox('PROD',100,,,"FOLDER","FLDCOD1")
oView:CreateHorizontalBox('SC'  ,100,,,"FOLDER","FLDCOD2")

oView:EnableTitleView('VIEW_COM')

oView:SetOwnerView('VIEW_COM','CIMA' )
oView:SetOwnerView('VIEW_CON','PROD' )
oView:SetOwnerView('VIEW_COO','SC')
oView:SetOwnerView('VIEW_COP','BAIXO')

If FunName() <> "GCPA200"
	If IsInCallStack("GCP100IncP") .Or. IsInCallStack("GCP100IncL") .Or.  IsInCallStack("GCP100Alt")
		oView:AddUserButton(STR0017, 'CLIPS', {|oView|  GCP100CaSC(oModel)})//'Solicitações'
	EndIf	
	oView:AddUserButton(STR0018, 'CLIPS', {|oView|  VisualSC(oModel)})//'Visualiza Solicitação'
Else
	oStruCOM:SetProperty('*', 	MVC_VIEW_CANCHANGE  ,.F.) //Desabilita os campos
	oStruCOM:SetProperty('COM_CODIGO', MVC_VIEW_CANCHANGE, .T.)	//Habilita este campo
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Matheus Lando Raimundo
@since 03/07/13
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
Local aRotInc := {}
Local aGCP100MN	:= {}

aAdd(aRotInc, {STR0019,'GCP100IncL', 0, 3})//'Por Lote'
aAdd(aRotInc, {STR0020,'GCP100IncP', 0, 3})//'Por Item'

ADD OPTION aRotina TITLE STR0021  	 ACTION "GCP100Vis"		 	OPERATION 2	ACCESS 0  	//'Visualizar'
ADD OPTION aRotina TITLE STR0022	 ACTION aRotInc				OPERATION 3  	ACCESS 0  	//'Incluir'
ADD OPTION aRotina TITLE STR0023	 ACTION "GCP100Alt"			OPERATION 4 	ACCESS 0  	//'Alterar'
ADD OPTION aRotina TITLE STR0024 	 ACTION "GCP100Exc"			OPERATION 5  	ACCESS 3	//'Excluir'
ADD OPTION aRotina TITLE STR0025 	 ACTION "VIEWDEF.GCPA100" 	OPERATION 8 	ACCESS 0 	//'Imprimir'
ADD OPTION aRotina TITLE STR0026	 ACTION "GCP100GEdt()"      OPERATION 9  	ACCESS 0 	//'Gerar  processo licitatório'
ADD OPTION aRotina TITLE STR0047	 ACTION "A102MANUTE"			OPERATION 4 	ACCESS 0   //'Manutenção do Lote'

// Ponto de entrada utilizado para inserir novas opcoes no array aRotina  
If ExistBlock("GCP100MN")
	If ValType(aGCP100MN := ExecBlock( "GCP100MN", .F., .F., {aRotina}) ) == "A"
		aRotina := aGCP100MN
	EndIf
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP100CaSC(oModel)
Rotina que carrega as Solicitações de Compra.

@author Matheus Lando Raimundo
@oModel = oModel
@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCP100CaSC(oModel, lAuto as Logical, aSolComp as Array, aHeader as Array)
Local aSCs			:= {}
Local lRet			:= .T.	
Local lUsaLote		:= oModel:GetId() == 'GCPA101'
Default lAuto		:= .F.
Default aSolComp	:= {}
Default aHeader   	:= {}

If	lUsaLote .And. (oModel:GetModel('COQ_DETAIL'):IsDeleted() .Or. Empty(oModel:GetModel('COQ_DETAIL'):GetValue('COQ_LOTE')))
	Help(' ', 1,'GCP101NLOT')
	If IsBlind()
		oModel:SetErrorMessage( "COQ_DETAIL", "COQ_LOTE", "", "", "GCP101NLOT", "", "")
	EndIf
	lRet:=.F.
EndIf

If lRet
	If !lAuto
		If lUsaLote
			aSCs := GCPSCS(oModel,'CON_DETAIL', 'COO_DETAIL', 'COO_NUMSC', 'COO_ITEMSC', 'COQ_DETAIL')
		Else
			aSCs := GCPSCS(oModel,'CON_DETAIL', 'COO_DETAIL', 'COO_NUMSC', 'COO_ITEMSC')
		EndIf
		aSolComp := GCPSelSC(,,,,,,aSCs, , @aHeader)		
	EndIf
	
	If Len(aSolComp) > 0
		If IsBlind()			
			GCPCadProd(@oModel, aSolComp, @aHeader,"CON","COO","COP_DETAIL","COQ")			
		Else
			FwMsgRun(Nil,{|| GCPCadProd(@oModel, aSolComp, @aHeader,"CON","COO","COP_DETAIL","COQ") },STR0013,STR0036)
		Endif
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPPosVld(oModel)
Rotina de Pós Validação do Modelo

@author Matheus Lando Raimundo
@oModel = oModel
@return = lRet - Valor Booleano que confirma a validação
@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCPPosVld(oModel)

Local lLote := (oModel:GetId() == 'GCPA101')
Local nI            := 0
Local nI2           := 0
Local nI3           := 0
Local nIAux 		:= 0
Local oCOP_DETAIL := oModel:GetModel('COP_DETAIL')
Local oCON_DETAIL := oModel:GetModel('CON_DETAIL')
Local oCOY_DETAIL
Local oCOM_MASTER := oModel:GetModel('COM_MASTER')
Local oCOQDetail  := oModel:GetModel('COQ_DETAIL') //Análise de Mercado X Lote
Local lRet 		:= .T.
Local aSaveLines 	:= FWSaveRows() 

If oModel:GetOperation() == MODEL_OPERATION_DELETE
	lRet := .T.
Else	    	
	//Validação do Tipo da modalidade
	If (lRet)
		lRet := GCP100VdTp(oCOM_MASTER:GetValue('COM_TIPO'))
	EndIf
	
	If (lRet) .And. !GCP100VlPG()
		Help(' ', 1,'GCP100PRG')
	EndIf
	
	If lRet .And. (oCOM_MASTER:GetValue('COM_MODACA') <> oCOM_MASTER:GetValue('COM_MODSUG')) .And. Empty(oCOM_MASTER:GetValue('COM_JUSMOD'))
		lRet := .F.
		Help(' ', 1,'GCP100MDSUG')	
	EndIf
	
	If lLote
        oCOY_DETAIL := oModel:GetModel('COY_DETAIL')
        For nI := 1 To oCOQDetail:Length()
            oCOQDetail:GoLine(nI)
            If !oCOQDetail:IsDeleted()
                For nI2 := 1 To oCOP_Detail:Length() 
                    oCOP_Detail:GoLine(nI2)
                    If !oCOP_DETAIL:IsDeleted()
                        If Empty(oCOP_Detail:GetValue('COP_CODFOR'))
                            lRet := .F.
                            Help(' ', 1,'GCP101NLFR')//Existe um ou mais Lotes sem Fornecedores, informe-os antes de Gerar o  processo licitatório.  
                            Exit                
                        EndIf           
                        For nI3 := 1 To oCOY_DETAIL:Length()
                            oCOY_DETAIL:GoLine(nI3)
                            If !oCOY_DETAIL:IsDeleted()                          
                                If (oCOY_DETAIL:GetValue('COY_VLRTOT') == 0)
                                    Help(' ', 1,'VALORTOT0')
                                    lRet := .F.
                                    Exit                                        
                                EndIf                                                       
                            EndIf                                                       
                        Next nI3
                    Else
	                    lRet := .F.
	                    Help(' ', 1,'GCP101NLFR')//Existe um ou mais Lotes sem Fornecedores, informe-os antes de Gerar o  processo licitatório.  
	                    Exit                    
                    EndIf
                Next nI
            EndIf
        Next nI
    Else
    	If lRet 
    		For nI := 1 To oCON_DETAIL:Length()
    			oCON_DETAIL:GoLine(nI)
    			If !oCON_DETAIL:IsDeleted()
    				For nIAux := 1 To oCOP_DETAIL:Length()
    					oCOP_DETAIL:GoLine(nIAux)
							If (Empty(oCOP_DETAIL:GetValue('COP_CODFOR')) .Or. (oCOP_DETAIL:IsDeleted()))
    							Help("",1,STR0052,,STR0053,4,1) //--"Existe um ou mais produtos sem Fornecedores"
    							lRet := .F.
    						EndIf
    				Next nIAux
    			EndIf
    		Next nI
    	EndIf
    	
    	If lRet 
    		For nI := 1 To oCON_DETAIL:Length()
    			oCON_DETAIL:GoLine(nI)
    			If !oCON_DETAIL:IsDeleted()
    				For nIAux := 1 To oCOP_DETAIL:Length()
    					oCOP_DETAIL:GoLine(nIAux)
    						If lRet .And. Empty(oCOP_DETAIL:GetValue('COP_PRCUN')) .And. (!oCOP_DETAIL:IsDeleted())
    							Help("",1,STR0052,,STR0054,4,1)
    							lRet := .F.
    						EndIf
    				Next nIAux		
    			EndIf
    		Next nI	
    	EndIf	
    EndIf
EndIf	

FWRestRows(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCalcPre(cRetorno)
Rotina que calculo o preço do Produto e refaz os demais calculos.

@author Matheus Lando Raimundo
@cRetorno = 'G' = Gatilho e 'V' = Valid
@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCPCalcPre()
Local oModel 		:= FWModelActive()
Local oCON_DETAIL := oModel:GetModel('CON_DETAIL')
Local oCOM_MASTER := oModel:GetModel('COM_MASTER')
Local nValor		:= 0
	
//Chama a função que calcula o valor de acordo com o metodo.
//Carrega o valor do Valor estimado e atualiza a modalidade sugerida       
If (oModel:GetId() == 'GCPA100') 
	nValor := GCPRetVE(oModel) 
	oCON_DETAIL:SetValue('CON_VALEST', nValor)
	oCOM_MASTER:SetValue('COM_MODSUG',  GCP100MDSug(oModel))
ElseIf (oModel:GetId() == 'GCPA101') 
	oCOM_MASTER:SetValue('COM_MODSUG',  GCP101MDSug(oModel))	
EndIf		       
   
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} MediaGlob(oCOP_DETAIL, nLinhaExc, nLinhaIns)
Rotina que calcula a média global dos valores, 
tratando linhas deletedas e que estão em 'UNDELETE'.


@author Matheus Lando Raimundo
@oCOP_DETAIL = Modelo de Fornecedores.
@nLinhaExc = Linha Excluida
@nLinhaIns = Linha que esta em 'UNDELETE'
@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function MediaGlob(oCOP_DETAIL, nLinhaExc, nLinhaIns)
Local nI		 	:= 0
Local nVlrTot 	 	:= 0
Local nPos 		:= 0
Local aSaveLines  := FWSaveRows()

Default nLinhaExc := Nil
Default nLinhaIns := Nil


For nI := 1 To oCOP_DETAIL:Length()
	oCOP_DETAIL:GoLine(nI)	
	//Se a linha estiver deletada desconsidera do calculo.
	If oCOP_DETAIL:nLine == nLinhaExc	
		Loop	    
	EndIf    	   			

	If (oCOP_DETAIL:GetValue('COP_OK') .And. (oCOP_DETAIL:nLine == nLinhaIns .Or. !oCOP_DETAIL:IsDeleted()))
		nVlrTot  := nVlrTot + oCOP_DETAIL:GetValue('COP_VALTOT')
    	nPos := nPos + 1
    EndIf		
Next nI

FWRestRows(aSaveLines)
Return (nVlrTot  / nPos)


//-------------------------------------------------------------------
/*/{Protheus.doc} MediaMaMe(oCOP_DETAIL, nLinhaExc, nLinhaIns)
Rotina que calcula a média entre o maior valor e o menor valor, 
tratando linhas deletedas e que estão em 'UNDELETE'.


@author Matheus Lando Raimundo
@oCOP_DETAIL = Modelo de Fornecedores.
@nLinhaExc = Linha Excluida
@nLinhaIns = Linha que esta em 'UNDELETE'

@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function MediaMaMe(oCOP_DETAIL, nLinhaExc, nLinhaIns)
Local nI 			:= 0
Local nMaior 		:= 0
Local nMenor 		:= 0
Local nVlrTot 		:= 0
Local lZerado 		:= .F.
Local aSaveLines 	:= FWSaveRows()
Default nLinhaExc	:= Nil
Default nLinhaIns := Nil

For nI := 1 To oCOP_DETAIL:Length()
	oCOP_DETAIL:GoLine(nI)
	
	//Se a linha estiver deletada desconsidera para calculo.
	If oCOP_DETAIL:nLine == nLinhaExc  
		Loop	
	EndIf
		
	If (oCOP_DETAIL:GetValue('COP_OK') .And. (oCOP_DETAIL:nLine == nLinhaIns .Or. !oCOP_DETAIL:IsDeleted())) 
		//Caso tenha algum valor zerado define que ele é o menor dos valores.
		If oCOP_DETAIL:GetValue('COP_VALTOT') == 0
    		nMenor := 0
    		lZerado := .T.      	
    	EndIf
    	
    	//Define o maior valor.
    	If oCOP_DETAIL:GetValue('COP_VALTOT')  > nMaior      
       		nMaior := oCOP_DETAIL:GetValue('COP_VALTOT')
       	EndIf 
        
        //Define o menor valor caso não seja 0.     
       	If nMenor == 0 .And. !lZerado
        	nMenor := oCOP_DETAIL:GetValue('COP_VALTOT')       
       	EndIf
       
       	If oCOP_DETAIL:GetValue('COP_VALTOT')  < nMenor              		
        	nMenor := oCOP_DETAIL:GetValue('COP_VALTOT')                         
       	EndIf       
	EndIf    	    				    
Next nI

nVlrTot :=  ((nMaior + nMenor )/ 2)

FWRestRows(aSaveLines)
Return nVlrTot 

//-------------------------------------------------------------------
/*/{Protheus.doc} MaiorVlr(oCOP_DETAIL, nLinhaExc, nLinhaIns)
Rotina que calcula o maior valor entre os valores,
tratando linhas deletedas e que estão em 'UNDELETE'.


@author Matheus Lando Raimundo
@oCOP_DETAIL = Modelo de Fornecedores.
@nLinhaExc = Linha Excluida
@nLinhaIns = Linha que esta em 'UNDELETE'

@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function MaiorVlr(oCOP_DETAIL, nLinhaExc, nLinhaIns)
Local nI 			:= 0
Local nMaior 		:= 0
Local aSaveLines 	:= FWSaveRows()
Default nLinhaExc	:= Nil
Default nLinhaIns	:= Nil

For nI := 1 To oCOP_DETAIL:Length()		
	oCOP_DETAIL:GoLine(nI)
	
	//Se a linha estiver deletada desconsidera para calculo.
	If oCOP_DETAIL:nLine == nLinhaExc 
		Loop	
	EndIf
	
	If (oCOP_DETAIL:GetValue('COP_OK') .And. (oCOP_DETAIL:nLine == nLinhaIns .Or. !oCOP_DETAIL:IsDeleted()))
		If oCOP_DETAIL:GetValue('COP_VALTOT')  > nMaior
        	nMaior := oCOP_DETAIL:GetValue('COP_VALTOT')			
		EndIf				
	EndIf	              
Next nI

FWRestRows(aSaveLines)

Return nMaior

//-------------------------------------------------------------------
/*/{Protheus.doc} MenorVlr(oCOP_DETAIL, nLinhaExc, nLinhaIns)
Rotina que calcula a menor valor entre os valores,
tratando linhas deletedas e que estão em 'UNDELETE'.


@author Matheus Lando Raimundo
@oCOP_DETAIL = Modelo de Fornecedores.
@nLinhaExc = Linha Excluida
@nLinhaIns = Linha que esta em 'UNDELETE'

@since 22/07/2013
@version P11
/*/
//------------------------------------------------------------------- 
Function MenorVlr(oCOP_DETAIL, nLinhaExc, nLinhaIns)
Local nI 			:= 0
Local nMenor 		:= 0
Local aSaveLines 	:= FWSaveRows()
Default nLinhaExc := Nil
Default nLinhaIns := Nil

For nI := 1 To oCOP_DETAIL:Length()
	oCOP_DETAIL:GoLine(nI)
	
	//Se a linha estiver deletada desconsidera para calculo.
	If oCOP_DETAIL:nLine == nLinhaExc
		Loop
	EndIf
	
	If (oCOP_DETAIL:GetValue('COP_OK') .And. (oCOP_DETAIL:nLine == nLinhaIns .Or. !oCOP_DETAIL:IsDeleted()))
		//Caso tenha algum valor 0, considera como o menor e sai da rotina.
		If oCOP_DETAIL:GetValue('COP_VALTOT') == 0
			nMenor := 0
			Exit		
		EndIf              
    	    
    	If nMenor == 0
       		nMenor := oCOP_DETAIL:GetValue('COP_VALTOT')       
       	EndIf
       
       	If oCOP_DETAIL:GetValue('COP_VALTOT')  < nMenor
        	nMenor := oCOP_DETAIL:GetValue('COP_VALTOT')
       	EndIf			       	       
	EndIf				    
Next nI

FWRestRows(aSaveLines)

Return nMenor 

//-------------------------------------------------------------------
/*/{Protheus.doc} VlrInter(oCOP_DETAIL, nLinhaExc, nLinhaIns)
Rotina que calcula o valor intermediario entre os valores,
tratando linhas deletedas e que estão em 'UNDELETE'.


@author Matheus Lando Raimundo
@oCOP_DETAIL = Modelo de Fornecedores.
@nLinhaExc = Linha Excluida
@nLinhaIns = Linha que esta em 'UNDELETE'

@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function VlrInter(oCOP_DETAIL, nLinhaExc, nLinhaIns)
Local nI 			:= 0
Local aVlrs 		:= {}
Local nVlrTot 		:= 0
Local nInterm 		:= 0
Local aSaveLines 	:= FWSaveRows()

Default nLinhaExc := Nil
Default nLinhaIns := Nil

	For nI := 1 To oCOP_DETAIL:Length()
		oCOP_DETAIL:GoLine(nI)
		
		//Se a linha estiver deletada desconsidera para calculo.
		If oCOP_DETAIL:nLine == nLinhaExc	
			Loop	    
		EndIf  		
		
		//Se a linha estiver em 'UNDELETE' considera para calculo.
		If (oCOP_DETAIL:GetValue('COP_OK') .And. (oCOP_DETAIL:nLine == nLinhaIns .Or. !oCOP_DETAIL:IsDeleted()))
			aAdd(aVlrs, oCOP_DETAIL:GetValue('COP_VALTOT'))         	
		EndIf
							
	Next nI

If Len(aVlrs) > 0
	aSort(aVlrs) //-- Ordena os elementos	      
	nInterm   := Round(Len(aVlrs)/2,0) //-- Obtém a posição intermediária
	//-- Obtém o valor intermediário para conjuntos pares ou impares de elementos.
		nVlrTot   := Iif((Mod(Len(aVlrs),2) == 0), Round(((aVlrs[nInterm] + aVlrs[nInterm+1]) / 2), 2), aVlrs[nInterm])
Else
	nVlrTot   := 0
EndIf	

FWRestRows(aSaveLines)

Return nVlrTot  

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP100MARKL
FWbrowser para facilitar o cadastro de lotes nos produtos
da solicitação de mercado

@author alexandre.gimenez
@param oModel Modelo de dados da Rotina 
@return Nil
@since 11/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCP100MARKL(oModel)
Local nAux
Local nAnalise  
Local aDados              := {}
Local aDados1            := {}
Local oFWBrowse
Local oDlg
Local oSize
Local oPanel
Local nOpcX                     :=    0
Local aColumns           := {}
Local aButtons                 := {}
Local bMark              := { |oBrowse| If(aDados[oFWBrowse:nAt][1],'LBOK','LBNO') }
Local bDblClickMark     := { |oBrowse| DblClickMark(oBrowse,aDados,MV_PAR02) } 
Local cLote               := space(TamSX3("CON_LOTE")[1])
Local lValid                    := .T.
Local aSaveLines         := FWSaveRows()
Local lPergunta  := .T.
       
lPergunta := Pergunte('GCPA100', .T.)            
 	For nAux := 1 To oModel:GetModel('CON_DETAIL'):Length()
 		oModel:GetModel('CON_DETAIL'):GoLine(nAux) 		
		If Empty(oModel:GetModel('CON_DETAIL'):GetValue('CON_CODPRO')) .Or. (oModel:GetModel('CON_DETAIL'):IsDeleted())			
   			Loop   		
   		End 
   		aadd(aDados, {.F.,;
        	            oModel:GetModel('CON_DETAIL'):GetValue('CON_LOTE'),;
            	        oModel:GetModel('CON_DETAIL'):GetValue('CON_CODPRO'),;
                	    oModel:GetModel('CON_DETAIL'):GetValue('CON_DESCR'),;
                    	oModel:GetModel('CON_DETAIL'):GetValue('CON_QUANT')})
    	   
Next nAux

If Len(aDados) == 0
	help("",1,"GCP100NPROD")
    lPergunta := .F.
EndIf	 
       	       
while lValid .And. lPergunta	       
	lValid := .F.
   	If MV_PAR02 == 1 // se for incluir verificar se ja existe o lote informado
    	IF ( ascan(aDados, {|x| x[2] == MV_PAR01}) > 0 )                            
        	help("",1,"GCPA100LTYES")
            lPergunta := Pergunte('GCPA100', .T.)
            lValid := .T.
        else
        	aEval(aDados,{|x|  x[1] := (alltrim(x[2]) == '') })          
        EndIf
    Else // se for Alterar ou Excluir verifica se existe o lote e marcar os itens do lote
    IF ( ascan(aDados, {|x| x[2] == MV_PAR01}) == 0 )                            
    	help("",1,"GCPA100LTNO")
  		lPergunta := Pergunte('GCPA100', .T.)
    	lValid := .T.
   	Else
  		aEval(aDados,{|x| x[1] := (x[2] == MV_PAR01)})                                          
    EndIf        
  EndIf
EndDo
       
If lPergunta
	//-- Define as colunas do Browse
 	Aadd( aColumns, {STR0032, { || aDados[oFWBrowse:nAt][2] },"C",,,TamSx3('CON_LOTE')[1],0,.F.,,.F.,})//"Lote"
   	Aadd( aColumns, {STR0055	, { || aDados[oFWBrowse:nAt][3] },"C",,,TamSx3('CON_CODPRO')[1],0,.F.,,.F.,})//"Cod. Produto"
	Aadd( aColumns, {STR0033 , { || aDados[oFWBrowse:nAt][4] },"C",,,TamSx3('CON_DESCR')[1],0,.F.,,.F.,})//"Produto"
	Aadd( aColumns, {STR0034, { || aDados[oFWBrowse:nAt][5] }, "N",PesqPict("CON", "CON_QUANT"),,TamSx3('CON_QUANT')[1],2,.F.,,.F.,})//"Quantidade"
	
       
       //configura tamanho do browse
	oSize := FwDefSize():New( .F. ) 
	oSize:lLateral := .T.  // Calculo lado a lado 
	oSize:AddObject("TELA",100, 100, .T., .T.)
	oSize:Process() // Dispara os calculos
	DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL
       
	@00,00 MSPANEL oPanel SIZE 15,15 OF oDlg
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
             
	oFWBrowse:= FWBrowse():New(oPanel)                            //-- Habilita o Browse para atualização das propriedades
	oFWBrowse:SetDataArray()                                              //-- Define que sera utilizado dados de um arquivo Texto
	oFWBrowse:AddMarkColumns(bMark,bDblClickMark)  //-- Cria coluna de Marca e Desmarca
	oFWBrowse:SetColumns(aColumns)                                        //-- Define as colunas do Browse
	oFWBrowse:SetArray(aDados)                                            //-- Define os dados do Browse
	oFWBrowse:Activate()                                                   //-- Cria o Browse
	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| (aDados1 := aclone(aDados), oDlg:End(),nOpcX:= 1  )},{||oDlg:End()},,aButtons)
       
	If nOpcX == 1            
		MsgRun( STR0035, STR0036, {|| GCP100PRLT(@oModel,aDados1,MV_PAR01,MV_PAR02,aSaveLines) } ) //"Aguarde enquanto o lote é processado."//"Processando.."
	EndIf
EndIf		       

Return NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} GCP100PRLT
Rotina de processamento dos lotes nos produtos
da solicitação de mercado

@author alexandre.gimenez
@param oModel Modelo de dados da Rotina
@param aDados Array de dados maniulados no FWBrowse
@param cLote Lote especificado
@param nOpc Numero da operação 1-Incluir,2-Alterar,3-excluir 
@param aSavelines Array com dados de restauração do oModel
@return Nil
@since 11/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCP100PRLT(oModel,aDados,cLote,nOpc,aSaveLines)
Local nAux           := 1
Local nPc            := 0
Local nSeek          := 0

For nAux := 1 To oModel:GetModel('CON_DETAIL'):Length()
	oModel:GetModel('CON_DETAIL'):GoLine(nAux)
	
	If (oModel:GetModel('CON_DETAIL'):IsDeleted())
		Loop
	
	EndIf     

       nSeek := ASCan(aDados,{|x| x[3] == oModel:GetModel('CON_DETAIL'):GetValue('CON_CODPRO') })
       
       If(   (aDados[nSeek,1]) .And.  (nOpc != 3) ) //Input inclusao e alteracao
             oModel:GetModel('CON_DETAIL'):SetValue('CON_LOTE', cLote )
             nPc++ 
       ElseIf( ( (nOpc == 2) .And. (aDados[nSeek,2] == cLote ) ) .Or. (aDados[nSeek,1])  .And.  (nOpc == 3) ) // Alteracao com lote igual ou Exclusao com flag
                    oModel:GetModel('CON_DETAIL'):SetValue('CON_LOTE','')
                    nPc++
       EndIf
                              
Next nAux


FWRestRows( aSaveLines )
Return NIL  

//-------------------------------------------------------------------
/*/{Protheus.doc} DblClickMark
Rotina acinado no duplo clique da linha, onde marca e desmarca o
dado no FWbrowse

@author alexandre.gimenez
@param oModel Modelo de dados da Rotina
@param aDados Array de dados maniulados no FWBrowse
@param nOpc Numero da operação 1-Incluir,2-Alterar,3-excluir 
@return lRet Lógico com a informação para marcar ou não registro.
@since 11/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Static Function DblClickMark(oBrowse, aDados, nOpc)
Local lRet := IIF(nOpc == 3,aDados[oBrowse:At(),1],!aDados[oBrowse:At(),1]) // Na Exclusao Não Permite Desmarcar ou Marcar Nada 

aDados[oBrowse:At(),1] := lRet

Return lRet


Function GCP100NrPr()
Local oModel := FWModelActive()

Local oCOM_MASTER := oModel:GetModel('COM_MASTER')

oCOM_MASTER:SetValue('COM_NUMPRO', Replicate( "0",15-Len(AllTrim(oCOM_MASTER:GetValue('COM_NUMPRO')))) + AllTrim(oCOM_MASTER:GetValue('COM_NUMPRO'))) 

Return .T. 


//-------------------------------------------------------------------
/*/{Protheus.doc} GCP100MDSug(oCOP_DETAIL, nLinhaExc, nLinhaIns)
Rotina que retorna o Código da modalidade Sugerida. 


@author Matheus Lando Raimundo
@oModel = oModel
@return cModSug - Código da modalidade Sugerida.

@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCP100MDSug(oModel)
Local oCON_DETAIL := oModel:GetModel('CON_DETAIL')
Local oCOM_MASTER := oModel:GetModel('COM_MASTER')
Local nI 		  := 0
Local nVlrTotal	  := 0
Local cModSug	  := ""
Local aSaveLines  := FWSaveRows()
Local cRegra	  := oCOM_MASTER:GetValue('COM_REGRA')
Local cModAcat	  := oCOM_MASTER:GetValue('COM_MODACA')
Local cEspecie	  := oCOM_MASTER:GetValue('COM_ESPECI')
Local aModSug	  := {} 

For nI := 1 to oCON_DETAIL:Length()
	oCON_DETAIL:GoLine(nI)
	If !oCON_DETAIL:IsDeleted()
		nVlrTotal := nVlrTotal + oCON_DETAIL:GetValue('CON_VALEST')
	EndIf				 
Next nI	

FWRestRows(aSaveLines)

oCOM_MASTER:SetValue('COM_VALEST', nVlrTotal)

aModSug := GCPA017Lim(cRegra,cEspecie,/*cModali*/,IIF(nVlrTotal==0,1,nVlrTotal), .F.)

If cRegra <> '002' .And. cEspecie == '3' 
	cModSug := cModAcat
Else
	If Len(aModSug) > 0
		cModSug := aModSug[1]
	Else
		//lei 8.666 concorrencia é permitido
		If cRegra+cModAcat <> '001CC' 
			Help(' ', 1,'GCP100VLRMD')
		EndIf	
		
	   //Sugere PG, exceto para lei 8.666   
	   cModSug := if( cRegra == '001','  ','PG')
	EndIf
EndIf
				
Return IIF(funname()<>'GCPA200',cModSug,oCOM_MASTER:GetValue("COM_MODACA"))

/*/{Protheus.doc} GCP100CrMS()
Rotina que valida inserção no campo CON_VALEST, de acordo com 
o Metodo
@author Matheus Lando Raimundo
@oModel = oModel
@return lRet - Valor Booleano que confirma a validação

@since 22/07/2013
@version P11
/*/
Function GCP100CrMS()
	Local oModel 		:= FWModelActive()
	Local lRet 			:= .T. 
	Local oCOM_MASTER	:= Nil
	Local oCON_DETAIL	:= Nil
	Local nVlrTotal		:= 0
	Local oCalcCON		:= Nil
	Local cCalcId		:= ""
		
	oCON_DETAIL	:= oModel:GetModel('CON_DETAIL')
	If(oCON_Detail:GetValue('CON_METODO') == "6")	
		oCOM_MASTER	:= oModel:GetModel('COM_MASTER')
		
		cCalcId	:= IIF(oModel:GetId() == "GCPA100", "GCP100CALC", "GCP101CALC")
		oCalcCON:= oModel:GetModel(cCalcId)
		
		nVlrTotal	:= oCalcCON:GetValue('CONESTTOT')
		oCOM_MASTER:SetValue('COM_VALEST', nVlrTotal)
		oCOM_MASTER:SetValue('COM_MODSUG',  GCP100MDSug(oModel))
	EndIf	
	oModel := Nil
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PreValCOP(oModelGrid, nLinha, cAcao, cCampo)
Rotina de Pre validação do modelo COP(Fornecedores)


@author Matheus Lando Raimundo

@oModelGrid = Modelo
@nLinha  = Linha corrente
@cAcao   = Ação ("DELETE", "SETVALUE", e etc)
@cCampo  = Campo atualizado

@return lRet - Valor Booleano que confirma a validação

@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Static Function PreValCOP(oModelGrid, nLinha, cAcao, cCampo)

Local oModel 		:= FWModelActive()
Local oCON_DETAIL := oModel:GetModel('CON_DETAIL')
Local oCOM_MASTER := oModel:GetModel('COM_MASTER')
Local lRet 		:= .T.

//Não permite incluir fornecedores sem antes incluir um produto para o mesmo.  
If cAcao == 'SETVALUE'				
	If Empty(oCON_DETAIL:GetValue('CON_CODPRO')) .Or. oCON_DETAIL:IsDeleted()							
		Help(' ', 1,'GCP100NPDF')					
		lRet := .F.
	EndIf
								
//Quando deletar um fornecedor refaz os calculos.	
ElseIf cAcao == 'DELETE'
	If oCON_DETAIL:GetValue('CON_METODO') <> '6'
		oCON_DETAIL:LoadValue('CON_VALEST', GCPRetVE(oModel, .T., .F.))
		oCOM_MASTER:SetValue('COM_MODSUG',  GCP100MDSug(oModel))
		lRet := .T. 
	EndIf
			
//Quando o fornecedor estiver "UNDELETE" refaz os calculos.	
ElseIf cAcao == 'UNDELETE'
	If Empty(oCON_DETAIL:GetValue('CON_CODPRO')) .Or. oCON_DETAIL:IsDeleted()
		Help(' ', 1,'GCP100NPDF')
		lRet := .F.		
	Else
		If oCON_DETAIL:GetValue('CON_METODO') <> '6'
			oCON_DETAIL:LoadValue('CON_VALEST', GCPRetVE(oModel, .F.,.T.))
			oCOM_MASTER:SetValue('COM_MODSUG',  GCP100MDSug(oModel))
			lRet	 := .T.
		EndIf
	EndIf
EndIf	
									      			        		

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPRetVE(oModel, lDelete, lInsert)
Rotina Calcula o Valor Estimado de acordo com o Metodo.
@author Matheus Lando Raimundo

@oModel = Modelo
lDelete     = Valor Booleano, caso esteja deletando um Forncedor	
lInsert     = Valor Booleano, caso o fornecedor esteja em "UNDELETE"
			 
@return nValor - Valor Estimado

@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCPRetVE(oModel, lDelete, lInsert, cModelo, cMetodo)
Local 	 oCOP_DETAIL 	:= oModel:GetModel('COP_DETAIL')
Local 	 nValor 		:= 0
Local 	 oModelo
Default lDelete 		:= Nil
Default lInsert 		:= Nil
Default cModelo  		:= 'CON_DETAIL'
Default cMetodo  		:= 'CON_METODO'

oModelo := oModel:GetModel(cModelo)
//Caso não esteja Deletando nem em "UNDELETE", calcula normalmente.
If lDelete == Nil .And. lInsert == Nil
	Do Case
		Case oModelo:GetValue(cMetodo) == '1'        
	    	nValor := MediaGlob(oCOP_DETAIL)
	   	Case oModelo:GetValue(cMetodo) == '2'        
	    	nValor :=  MediaMaMe(oCOP_DETAIL)
	   	Case oModelo:GetValue(cMetodo) == '3'        
	 		nValor := MaiorVlr(oCOP_DETAIL)
	   	Case oModelo:GetValue(cMetodo) == '4'        
	   		nValor := MenorVlr(oCOP_DETAIL) 
	   	Case oModelo:GetValue(cMetodo) == '5'        
	   		nValor :=  VlrInter(oCOP_DETAIL)                                                          
	EndCase
//Caso esteja Deletando, passo como parâmetro a linha que esta sendo deletada para que seja desconsiderada do calculo. 	
ElseIf lDelete
	Do Case
		Case oModelo:GetValue(cMetodo) == '1'        
	    	nValor := MediaGlob(oCOP_DETAIL, oCOP_DETAIL:nLine)
	   	Case oModelo:GetValue(cMetodo) == '2'        
	   		nValor :=  MediaMaMe(oCOP_DETAIL, oCOP_DETAIL:nLine)
   		Case oModelo:GetValue(cMetodo) == '3'        
 			nValor := MaiorVlr(oCOP_DETAIL, oCOP_DETAIL:nLine)
   		Case oModelo:GetValue(cMetodo) == '4'        
   			nValor := MenorVlr(oCOP_DETAIL, oCOP_DETAIL:nLine) 
   		Case oModelo:GetValue(cMetodo) == '5'        
   			nValor :=  VlrInter(oCOP_DETAIL, oCOP_DETAIL:nLine)                                                          
	EndCase
//Caso esteja em "UNDELETE", passo como parâmetro a linha para que seja considerada no calculo.	
ElseIf lInsert
	Do Case
		Case oModelo:GetValue(cMetodo) == '1'        
    		nValor := MediaGlob(oCOP_DETAIL, ,oCOP_DETAIL:nLine)
   		Case oModelo:GetValue(cMetodo) == '2'        
    	  	nValor :=  MediaMaMe(oCOP_DETAIL, ,oCOP_DETAIL:nLine)
   		Case oModelo:GetValue(cMetodo) == '3'        
 			nValor := MaiorVlr(oCOP_DETAIL, ,oCOP_DETAIL:nLine)
   		Case oModelo:GetValue(cMetodo) == '4'        
   			nValor := MenorVlr(oCOP_DETAIL, ,oCOP_DETAIL:nLine) 
   		Case oModelo:GetValue(cMetodo) == '5'        
   			nValor :=  VlrInter(oCOP_DETAIL, ,oCOP_DETAIL:nLine)                                                          
	EndCase
EndIf	

Return nValor		

//-------------------------------------------------------------------
/*/{Protheus.doc} PreValCOO(oModelGrid, nLinha, cAcao, cCampo)
Rotina de Pre validação do modelo COO(Solicitações)

@author alexandre.gimenez
@param oModelGrid Modelo
@param nLinha Linha corrente
@param cAcao  Ação ("DELETE", "SETVALUE", e etc)
@param cCampo Campo atualizado
@return lRet
@since 12/09/2013
@version 1.1
/*/
//------------------------------------------------------------------
Function PreValCOO(oModSC, nLinha, cAcao, cCampo)
Local oModel		:= oModSC:GetModel()
Local aSaveLines 	:= {}
Local oModProd 		:= Nil
Local nQtde 		:= 0
Local nQtdeSegu		:= 0
Local nX			:= 0
Local lDelAll		:= .T.
local lRet			:= .T.
Local cNumSC		:= ""

If (cAcao == 'DELETE' .Or. cAcao == 'UNDELETE')
	aSaveLines 	:= FWSaveRows()
	oModProd 	:= oModel:GetModel('CON_DETAIL')

	cNumSC := oModSC:GetValue('COO_NUMSC')
	If !Empty(cNumSC)		
		SC1->(dbSetOrder(1))
		If SC1->( dbSeek(xFilial('SC1')+cNumSC+oModSC:GetValue('COO_ITEMSC')))//Posiciona o registro na SC1 para recuperar a quantidade da SC.
			nQtde 		:= SC1->C1_QUANT
			nQtdeSegu	:= SC1->C1_QTSEGUM
		EndIf		
	EndIf

	If cAcao == 'DELETE'		
		oModProd:LoadValue('CON_QUANT', oModProd:GetValue('CON_QUANT') - nQtde)
		oModProd:LoadValue('CON_QTSEGU', oModProd:GetValue('CON_QTSEGU') - nQtdeSegu)
		For nX := 1 to oModSC:length() 
			oModSC:GoLine(nX)
			If !oModSC:IsDeleted() .And. nLinha <> nX
				lDelAll := .F.
				Exit
			EndIf
		Next nX
		If lDelAll .And. oModProd:GetValue('CON_QUANT') == 0 
			oModProd:DeleteLine()
		EndIf
	ElseIf cAcao == 'UNDELETE'
		oModProd:LoadValue('CON_QUANT', oModProd:GetValue('CON_QUANT') + nQtde)
		oModProd:LoadValue('CON_QTSEGU', oModProd:GetValue('CON_QTSEGU') + nQtdeSegu)			
		oModProd:UnDeleteLine()		
	EndIf	
EndIf

If (cAcao != "CANSETVALUE") .And. !FwIsInCallStack("GCP100CaSC")
	aSaveLines 	:= FWSaveRows()
	If (oModel:GetId() == 'GCPA101')
		GCP101CVLT()//Recalcular lote.
	EndIf	
	GCPCalcPre()//Refaz os calculo do valor estimado.	
	GCPAllForn()//Recalcula valor total dos fornecedores	
EndIf

If !Empty(aSaveLines)	
	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
EndIf
 
Return lRet

Function VldActivate(oModel, oStruCOM)
Local lRet := .T.
Local nOpc := oModel:GetOperation()

If lRet
	If (nOpc  == MODEL_OPERATION_UPDATE) .Or. (nOpc == MODEL_OPERATION_DELETE)
		lRet := (COM->COM_STATUS = '1') .Or. (Funname() == 'GCPA200' .And. (COM->COM_STATUS = '3')) 	
		If !lRet
			Help(' ', 1,'GCPA100GE')
		EndIf		       
	EndiF	
EndIf
	
Return lRet  

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPAtuaForn(oCOP_DETAIL, lUnDelete)
Rotina que atualiza o status ("DELETE", "UNDELETE") dos fornecedores.


@author Matheus Lando Raimundo
@oCOP_DETAIL = Modelo de dados dos Forncedores
@lUndelete   = Valor booleano 

@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------

Function GCPAtuaForn(oCOP_DETAIL, lUnDelete)
Local nI 		   := 0
Local aSaveLines := FWSaveRows()

For nI := 1 To oCOP_DETAIL:Length()
	If !(Empty(oCOP_DETAIL:GetValue('COP_CODFOR'))) 
		oCOP_DETAIL:GoLine(nI)	
		If lUnDelete 
			oCOP_DETAIL:UnDeleteLine()
		Else		
			oCOP_DETAIL:DeleteLine()		
		EndIf
		
	EndIf					
Next nI

FWRestRows(aSaveLines)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP100VlPG()
Validação do Campo Espécie - COM_ESPECI
@author José Eulálio
@since 23/05/2014
@version P12
/*/
//-------------------------------------------------------------------

function GCP100VlPG()
Local oModel := FWModelActive()
Local oCOM_MASTER := oModel:GetModel('COM_MASTER')
Local lRet := .T.

If !FwIsInCallStack("GCPA200") .And. (oCOM_MASTER:GetValue('COM_MODACA') == "PG") .And. (oCOM_MASTER:GetValue('COM_ESPECI') <> "2")
	lRet := .F.
    Help(' ', 1,'GCP100VLPG') // A modalidade Pregão somente é permitida para Espécie Compras e Outros
ElseIf (oCOM_MASTER:GetValue('COM_MODACA') == "RD") .And. (oCOM_MASTER:GetValue('COM_TIPO') == "MO") .And. (oCOM_MASTER:GetValue('COM_ESPECI') <> "3")
	lRet := .F.
	Help(' ', 1,'GCP100VLMO') // 'O Tipo de Modalidade Maior Oferta permite apenas a Espécie Alienação de Bens'
ElseIf (oCOM_MASTER:GetValue('COM_MODACA') == "RD") .And. (oCOM_MASTER:GetValue('COM_TIPO') <> "MO") .And. (oCOM_MASTER:GetValue('COM_ESPECI') == "3")
	lRet := .F.
	Help(' ', 1,'GCP100VLAB') // 'A Espécie Alienação de Bens não é permitida para este Tipo de Modalidade'  //'Escolha uma Espécie de  processo licitatório válida'
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCommit()
Atualiza solicitações usadas pelo  processo licitatório
@author Matheus Lando Raimundo
@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCPCommit(oModel)
Local oCON_DETAIL := oModel:GetModel('CON_DETAIL')
Local oCOO_DETAIL := oModel:GetModel('COO_DETAIL')
Local lRet 		:= .T.
Local nIAux 		:= 0
Local nI 			:= 0

SC1->(dbSetOrder(1))

For nI := 1 To oCON_DETAIL:Length() //Modelo de Produtos
	oCON_DETAIL:GoLine(nI)
	If (oCON_DETAIL:IsDeleted() .And. !oCOO_DETAIL:IsDeleted()) .And.;
		 (oCON_DETAIL:IsDeleted() .And. oCOO_DETAIL:Length() == 0)
		Loop
    EndIf
	For nIAux := 1 To oCOO_DETAIL:Length() //Modelo de Solicitação de Compras
		oCOO_DETAIL:GoLine(nIAux)
		If oCOO_DETAIL:IsDeleted() .Or. (oCON_DETAIL:IsDeleted() .And. oCOO_DETAIL:Length() > 0) 
        	If (oModel:GetOperation() == MODEL_OPERATION_UPDATE) .And. SC1->(dbSeek(xFilial("SC1")+oCOO_DETAIL:GetValue('COO_NUMSC')+oCOO_DETAIL:GetValue('COO_ITEMSC')))
        		RecLock("SC1",.F.)
				SC1->C1_COTACAO   := ''
				SC1->(MsUnLock())
        	EndIf
       	Loop
       Else
			oCOO_DETAIL:GoLine(nIAux)
			If SC1->(dbSeek(xFilial("SC1")+oCOO_DETAIL:GetValue('COO_NUMSC')+oCOO_DETAIL:GetValue('COO_ITEMSC')))
				RecLock("SC1",.F.)
				If oModel:GetOperation() == MODEL_OPERATION_DELETE
					SC1->C1_COTACAO   := ''
				Else
					SC1->C1_COTACAO   := 'ANALIS'
				EndIf
				SC1->(MsUnLock())
			EndIf     
		EndIf
    Next nIAux    
Next nI

If FwFormCommit(oModel)
	//EventViewer 057 - Analise de Mercado
	EnvAberAM(oModel)
EndIf  

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VisualSC(oModel)
Rotina para visualizar uma SC.

@author Matheus Lando Raimundo
@oModel = Modelo de dados

@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function VisualSC(oModel)
Local oCOO_DETAIL := oModel:GetModel('COO_DETAIL')

SC1->(dbSetOrder(1))
If SC1-> (dbSeek(xFilial('SC1')+oCOO_DETAIL:GetValue('COO_NUMSC')+oCOO_DETAIL:GetValue('COO_ITEMSC')))
 	A110Visual('SC1',SC1->(RecNo()),2) //Rotina do MATA110

EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA100()
Rotina para enviar WorkFlow (Inclusão, alteração ou exclusão de uma análise de mercado) via EventViewer.
@author Antenor Silva
@since 10/07/2013
@version 1.0
@return NIL
/*/
Function EnvAberAM(oModel)
Local cEventID   := 0      // Variavel usada para armazenar o ID do EventViewer	  
Local cMensagem  := " "   // Variavel para armazenar a mensagem utilizada no eventviewer
Local aForn := {}         // Variavel para armazenar os fornecedores
Local nI
  

	cEventID  := "057" // Inclusão de Análise de mercado

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		//foi aberta
		cMensagem :=STR0037 + AllTrim(COM->COM_CODIGO)+STR0038+CRLF//", ficando em aberto pelo período de 60 dias após o lançamento da primeira cotação realizada por um do(s) seguinte(s) fornecedor(es):"//"Considerando o objetivo da contratação de seus requisitos foi aberta a Análise de Mercado Nº "
			
	
			For nI:= 1 To oModel:GetModel('COP_DETAIL'):Length()
				oModel:GetModel('COP_DETAIL'):GoLine( nI )
				Aadd( aForn, { oModel:GetModel('COP_DETAIL'):GetValue('COP_CODFOR'),;
								 oModel:GetModel('COP_DETAIL'):GetValue('COP_LOJFOR'),;
								 oModel:GetModel('COP_DETAIL'):GetValue('COP_NOMFOR') }) 
			Next nI
			
						
	ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE
	    //foi alterada - "Houve alteração(ões) na Análise de Mercado Nº "
	    cMensagem := STR0039+AllTrim(COM->COM_CODIGO)+ "."//"Houve alteração(ões) na Análise de Mercado Nº "
    	    
	ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE
	    //foi excluída - "Foi excluída a Análise de Mercado Nº "
	    cMensagem := STR0040+AllTrim(COM->COM_CODIGO)+"."//"Foi excluída a Análise de Mercado Nº "
	EndIf
	
	
	For nI := 1 To Len(aForn)
		cMensagem += STR0041 + aForn[nI, 1] + STR0042 + aForn[nI, 2] + STR0043 + aForn[nI, 3]+CRLF ////////" Cód. Forn.: "//" Fornecedor: "//" Loja: "
	Next nI
	
		
	EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID,FW_EV_LEVEL_INFO,""/*cCargo*/,STR0044,cMensagem)//"Análise de Mercado"

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA100()
Rotina para trazer os dados do  processo licitatório selecionado (Cabeçalho, Produtos, Solicitações e Participantes)
@author Leonardo Quintania
@since 10/07/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCPA100Ins(oModel)
Local oModelCON	:= oModel:GetModel('CON_DETAIL') //Produtos da Análise de Mercado
Local oModelCOO	:= oModel:GetModel('COO_DETAIL') //Solicit. de Compras X Produtos  
Local oModelCOP	:= oModel:GetModel('COP_DETAIL') //Fornecedores X Produtos
Local cSeekCON	:= ""
Local cSeekCOO	:= ""
Local cSeekCOP	:= ""
Local nLinCON	:= 0
Local nLinCOO	:= 0
Local nLinCOP	:= 0
Local lRet 		:= .T.
Local lInsert	:= .F.
                 
If FunName() == "GCPA200" .And. oModel:GetOperation() == MODEL_OPERATION_INSERT                           
	//Cabeçalho da Análise de Mercado                     
    GCPA100AM(oModel)
	If !(lInsert := oModelCOO:lInsertLine )
		oModelCOO:SetNoInsertLine( .F. )
	EndIf
    
    CO2->(dbSetOrder(1)) //CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO
    If CO2->(dbSeek(cSeekCON:=xFilial("CO2")+CO1->(CO1_CODEDT+CO1_NUMPRO) ) )
    	While CO2->(!EOF()) .And. CO2->( CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO ) == cSeekCON
			nLinCON++
			If nLinCON # 1
				oModelCON:AddLine()
			EndIf
          	GCPA100Prd(oModel) //Carrega os produtos do  processo licitatório
          	
			CP4->(dbSetOrder(1)) //CP4_FILIAL+CP4_CODEDT+CP4_NUMPRO+CP4_REVISA+CP4_CODPRO+CP4_NUMSC+CP4_ITEMSC
			If CP4->(dbSeek( cSeekCOO:=xFilial("CP4")+CO1->(CO1_CODEDT+CO1_NUMPRO+CO1_REVISA)+CO2->CO2_CODPRO ) )
				nLinCOO:= 0
				While CP4->(!EOF()) .And. CP4->(CP4_FILIAL+CP4_CODEDT+CP4_NUMPRO+CP4_REVISA+CP4_CODPRO) == cSeekCOO
					If !Empty(CP4->CP4_NUMSC)                         
						nLinCOO++
						If nLinCOO # 1
							oModelCOO:AddLine()
						EndIf
						GCPA100SC(oModel) //Carrega as solicitações do produto selecionado
					EndIf
					CP4->(dbSkip())
				EndDo
				oModelCOO:Goline(1)
			EndIf
			
			CO3->(dbSetOrder(1))//CO3_FILIAL+CO3_CODEDT+CO3_NUMPRO+CO3_CODPRO+CO3_TIPO+CO3_CODIGO+CO3_LOJA 
			If CO1->CO1_GERDOC == '2'
				Help(' ', 1,'GCP100NFOR')
			ElseIf CO3->(dbSeek(cSeekCOP:=xFilial("CO3")+CO1->CO1_CODEDT+CO1->CO1_NUMPRO+CO2->CO2_CODPRO)) 
				nLinCOP:= 0
				While CO3->(!Eof() .And. CO3->CO3_FILIAL+CO3->CO3_CODEDT+CO3->CO3_NUMPRO+CO3->CO3_CODPRO == cSeekCOP)
					nLinCOP++
					If nLinCOP # 1
						oModelCOP:AddLine()
					EndIf                                    
					GCPA100For(oModel) //Carrega os fornecedores
					CO3->(dbSkip())
				EndDo
				oModelCOP:Goline(1)
			EndIf
			CO2->(dbSkip())	                                                              		
		EndDo
		oModelCON:Goline(1)
	EndIf
oModelCOO:SetNoInsertLine(!lInsert)
GCP100MDSug(oModel)
EndIf                     

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA100AM()
Rotina para montar o Cabeçalho do  processo licitatório.
@author Leonardo Quintania
@since 18/07/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCPA100AM(oModel)
Local nX 			:= 0
Local oCOMMASTER	:= oModel:GetModel('COM_MASTER')
Local aHeader 	:= oCOMMASTER:GetStruct():GetFields()
//-- Recuperar a estrutura da tabela CO1
Local oModel200  	:= FwLoadModel('GCPA200')
Local aHeader200 	:= oModel200:GetModel('CO1MASTER'):GetStruct():GetFields()
Local cCampo		:= ""

//Preenche itens
For nX := 1 To Len(aHeader)       
	If !(aHeader[nX][MODEL_FIELD_VIRTUAL]) .And. ; // Desconsidera campos virtuais
    	       	!(Alltrim(aHeader[nX][MODEL_FIELD_IDFIELD]) $ ;    	       				
    	       				"COM_CODIGO|COM_JUSMOD|COM_DATA|COM_VALEST|")// Campos que não devem ser populados
		cCampo := SubStr(aHeader[nX,MODEL_FIELD_IDFIELD],At("_",aHeader[nX,MODEL_FIELD_IDFIELD]),Len(aHeader[nX,MODEL_FIELD_IDFIELD]))
              
		If Alltrim(aHeader[nX][MODEL_FIELD_IDFIELD]) == "COM_MODSUG" //Tratamento pontual  
                    oCOMMASTER:SetValue("COM"+cCampo,CO1->CO1_MODALI)		
		ElseIf Alltrim(aHeader[nX][MODEL_FIELD_IDFIELD]) == "COM_MODACA" //Tratamento pontual  
                    oCOMMASTER:SetValue("COM"+cCampo,CO1->CO1_MODALI)
        ElseIf Alltrim(aHeader[nX][MODEL_FIELD_IDFIELD]) == "COM_STATUS"
        			oCOMMASTER:SetValue("COM_STATUS","3") //Análise gerada por meio do  processo licitatório
		ElseIf Alltrim(aHeader[nX][MODEL_FIELD_IDFIELD]) == "COM_TIPO"
        			oCOMMASTER:SetValue("COM_TIPO",CO1->CO1_TIPO) 
       ElseIf Alltrim(aHeader[nX][MODEL_FIELD_IDFIELD]) == "COM_CODEDT"
        			oCOMMASTER:LoadValue("COM_CODEDT",CO1->CO1_CODEDT) 
		ElseIf Alltrim(aHeader[nX][MODEL_FIELD_IDFIELD]) == "COM_AVAL"
			If oModel:GetId() == 'GCPA100'
        		oCOMMASTER:SetValue("COM_AVAL","1")
			ElseIf oModel:GetId() == 'GCPA101'
				oCOMMASTER:SetValue("COM_AVAL","2")
			EndIf		        				        			        				         			         			        		            			                       			                 
		//-- Verificar se o campo em questão existe na estrutura da tabela CO1
		ElseIF aScan(aHeader200, {|x| Alltrim(Substr(x[MODEL_FIELD_IDFIELD],4)) ==  AllTrim(cCampo)}) > 0 ;   
	 		.And. aScan(oCOMMASTER:GetStruct():GetFields(),{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0  
                    oCOMMASTER:SetValue("COM"+cCampo,CO1->(&("CO1"+cCampo)))
		ElseIf COM->( FieldPos(aHeader[nX][MODEL_FIELD_IDFIELD]) ) > 0 
                   oCOMMASTER:SetValue("COM"+cCampo,(CriaVar(aHeader[nX][MODEL_FIELD_IDFIELD])))
		EndIf 
									 	
	EndIf             
Next nX

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA100()
Rotina para trazer os Produtos do  processo licitatório.
@author Leonardo Quintania
@since 18/07/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCPA100Prd(oModel)
Local nX 			:= 0
Local oCONDETAIL 	:= oModel:GetModel('CON_DETAIL')
Local aHeader 	:= oCONDETAIL:GetStruct():GetFields()

//Preenche itens
For nX := 1 To Len(aHeader)       
	If !(aHeader[nX][MODEL_FIELD_VIRTUAL]) // Desconsidera campos virtuais

		cCampo := SubStr(aHeader[nX,MODEL_FIELD_IDFIELD],At("_",aHeader[nX,MODEL_FIELD_IDFIELD]),Len(aHeader[nX,MODEL_FIELD_IDFIELD]))    

	    If Alltrim(aHeader[nX][MODEL_FIELD_IDFIELD]) $ "CON_CODIGO" // Campos que não devem ser populados pelo CO2
				oCONDETAIL:LoadValue(aHeader[nX][MODEL_FIELD_IDFIELD],(CriaVar(aHeader[nX][MODEL_FIELD_IDFIELD])))
				
		ElseIf Alltrim(aHeader[nX][MODEL_FIELD_IDFIELD]) == "CON_METODO" //Tratamento pontual
				oCONDETAIL:SetValue("CON"+cCampo,"6")				
                    		                 																												
		ElseIf Alltrim(aHeader[nX][MODEL_FIELD_IDFIELD]) == "CON_CODPRO" //Tratamento pontual		
					oCONDETAIL:SetValue("CON_CODPRO",CO2->CO2_CODPRO)                  					                  	
					
		ElseIf Alltrim(aHeader[nX][MODEL_FIELD_IDFIELD]) == "CON_VALEST" //Tratamento pontual          	
				oCONDETAIL:SetValue("CON"+cCampo,CO2->(CO2_VLESTI))
							            							                    
		ElseIf  aScan(oCONDETAIL:GetStruct():GetFields(),{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0 
                    oCONDETAIL:LoadValue("CON"+cCampo,CO2->(&("CO2"+cCampo)))
             
		ElseIf CON->( FieldPos(aHeader[nX][MODEL_FIELD_IDFIELD]) ) > 0 
                   oCONDETAIL:LoadValue("CON"+cCampo,(CriaVar(aHeader[nX][MODEL_FIELD_IDFIELD])))
		EndIf 
	EndIf             
Next nX       

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA100SC()
Rotina para trazer as Solicitações do  processo licitatório.
@author Leonardo Quintania
@since 18/07/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCPA100SC(oModel)
Local nX 			:= 0
Local oCOODETAIL 	:= oModel:GetModel('COO_DETAIL')
Local aHeader 	:= oCOODETAIL:GetStruct():GetFields()

 //Preenche itens                          
For nX := 1 To Len(aHeader)       
	If !(aHeader[nX][MODEL_FIELD_VIRTUAL]) .And. ; // Desconsidera campos virtuais
									!(Alltrim(aHeader[nX][MODEL_FIELD_IDFIELD]) $ "COO_CODIGO")// Campos que não devem ser populados
   
		cCampo := SubStr(aHeader[nX,MODEL_FIELD_IDFIELD],At("_",aHeader[nX,MODEL_FIELD_IDFIELD]),Len(aHeader[nX,MODEL_FIELD_IDFIELD]))
		
		If Alltrim(aHeader[nX][MODEL_FIELD_IDFIELD]) == 'COO_CODPRO'
			oCOODETAIL:LoadValue("COO_CODPRO",CP4->CP4_CODPRO)
				
		ElseIf Alltrim(aHeader[nX][MODEL_FIELD_IDFIELD]) == 'COO_NUMSC'
			oCOODETAIL:LoadValue("COO_NUMSC",CP4->CP4_NUMSC)
				
		ElseIf Alltrim(aHeader[nX][MODEL_FIELD_IDFIELD]) == 'COO_ITEMSC'
			oCOODETAIL:LoadValue("COO_ITEMSC",CP4->CP4_ITEMSC)
					   
		ElseIf  aScan(oCOODETAIL:GetStruct():GetFields(),{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0 
			oCOODETAIL:LoadValue("COO"+cCampo,CP4->(&("CP4"+cCampo)))
				
		ElseIf COO->( FieldPos(aHeader[nX][MODEL_FIELD_IDFIELD]) ) > 0 
			oCOODETAIL:LoadValue("COO"+cCampo,(CriaVar(aHeader[nX][MODEL_FIELD_IDFIELD])))
		EndIf 
	EndIf             
Next nX

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA100For()
Rotina para trazer os Participantes/Fornecedores do  processo licitatório.
@author Leonardo Quintania
@since 18/07/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function GCPA100For(oModel)
Local nX 			:= 0
Local oCOPDETAIL 	:= oModel:GetModel('COP_DETAIL')
Local aHeader 	    := oCOPDETAIL:GetStruct():GetFields()
Local oModel_EDT  := FwLoadModel('GCPA200')
Local oCO3Detail 	:= oModel_EDT:GetModel('CO3DETAIL')
Local aHeaderCO3 	:= oCO3Detail:GetStruct():GetFields()

//Preenche itens                          
For nX := 1 To Len(aHeader)       
	If !(aHeader[nX][MODEL_FIELD_VIRTUAL]) .And. ;// Desconsidera campos virtuais
            	!(Alltrim(aHeader[nX][MODEL_FIELD_IDFIELD]) $ ;
            				"COP_NOMFOR|COP_CODIGO|COP_PRCUN|COP_VALTOT|COP_OK|COP_DATA|COP_JUSTIF")// Campos que não devem ser populados
		cCampo := SubStr(aHeader[nX,MODEL_FIELD_IDFIELD],At("_",aHeader[nX,MODEL_FIELD_IDFIELD]),Len(aHeader[nX,MODEL_FIELD_IDFIELD]))
      
		If Alltrim(aHeader[nX][MODEL_FIELD_IDFIELD]) == "COP_CODFOR" //Tratamento pontual  
                    oCOPDETAIL:SetValue("COP"+cCampo,CO3->CO3_CODIGO)
        
		ElseIf Alltrim(aHeader[nX][MODEL_FIELD_IDFIELD]) == "COP_LOJFOR" //Tratamento pontual  
                    oCOPDETAIL:SetValue("COP"+cCampo,CO3->CO3_LOJA)
                    
		ElseIf  aScan(aHeaderCO3,{|x| AllTrim(Substr(x[MODEL_FIELD_IDFIELD],4)) == AllTrim(cCampo)}) > 0 
                    oCOPDETAIL:SetValue("COP"+cCampo,CO3->(&("CO3"+cCampo)))
                                                                     
		ElseIf COP->( FieldPos(aHeader[nX][MODEL_FIELD_IDFIELD]) ) > 0 
                   oCOPDETAIL:SetValue("COP"+cCampo,(CriaVar(aHeader[nX][MODEL_FIELD_IDFIELD])))
		EndIf 
	EndIf             
Next nX

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP100INIF()
Rotina que carrega o nome do fornecedor ou do participante,
dependendo do tipo selecionado;
- 1 = Pré-Fornecedor / Participante
- 2 = Fornecedor

@author alexandre.gimenez
@return cNome Nome encontrado na busca
@since 17/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCP100INIF()
	Local oModel 	:= FWModelActive()
	Local cNome 	:= "" 
	Local cCodigo	:= ""
	Local cLoja		:= ""
	Local aArea		:= {}
		
	If (oModel:GetOperation() != MODEL_OPERATION_INSERT)		
		cCodigo	:= COP->COP_CODFOR
		If !Empty(cCodigo)			
			If (COP->COP_TIPO == "1")
				aArea := CO6->(GetArea())
				CO6->(dbsetOrder(1))
				If CO6->(dbSeek(xFilial("CO6")+cCodigo))
					cNome := If(lLGPD,RetTxtLGPD(CO6->CO6_NOME,"CO6_NOME"),CO6->CO6_NOME)			
				EndIf
			ElseIf (COP->COP_TIPO == "2")
				aArea := SA2->(GetArea())
				cLoja := COP->COP_LOJFOR
				SA2->(dbsetOrder(1))
				If SA2->(dbSeek(xFilial("SA2")+cCodigo+cLoja))
					cNome := If(lLGPD,RetTxtLGPD(SA2->A2_NOME,"A2_NOME"),SA2->A2_NOME)
				EndIf
			EndIf
			If !Empty(aArea)
				RestArea(aArea)			
			EndIf
		EndIf
	EndIf
Return cNome

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCalcOk()
"Valid" do campo "COP_OK"

@author Matheus Lando Raimundo
@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCPCalcOk()
Local oModel := FWModelActive()

Local oCON_DETAIL := oModel:GetModel('CON_DETAIL')
Local oCOM_MASTER := oModel:GetModel('COM_MASTER')
Local nValor := 0

If oModel:GetId() == 'GCPA100'
	If oCON_DETAIL:GetValue('CON_METODO') <> '6'
		nValor := GCPRetVE(oModel)       
   		oCON_DETAIL:LoadValue('CON_VALEST', nValor)
   		oCOM_MASTER:SetValue('COM_MODSUG',  GCP100MDSug(oModel))  	
	EndIf
ElseIf oModel:GetId() == 'GCPA101'
	If oModel:GetModel('COQ_DETAIL'):GetValue('COQ_METODO') <> '6'
		nValor := GCPRetVE(oModel, , ,'COQ_DETAIL', 'COQ_METODO')      
   		oModel:GetModel('COQ_DETAIL'):LoadValue('COQ_VLRTOT', nValor)
   		oCOM_MASTER:SetValue('COM_MODSUG',  GCP101MDSug(oModel))
   	EndIf														  		             	
EndIf   

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCalcPUn()
"Gatilho" do campo "COP_PRCUN"

@author Matheus Lando Raimundo
@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCPCalcPUn()
Local oModel := FWModelActive()

Local oCON_DETAIL := oModel:GetModel('CON_DETAIL')
Local oCOP_DETAIL := oModel:GetModel('COP_DETAIL')
Local nValor	  := 0

If oModel:GetId() == 'GCPA100'
	nValor :=  oCOP_DETAIL:GetValue('COP_PRCUN') *  oCON_DETAIL:GetValue('CON_QUANT')
ElseIf oModel:GetId() == 'GCPA101'
	nValor :=  oCOP_DETAIL:GetValue('COP_PRCUN')
EndIf			   	

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCalcTot
"Valid" do campo "COP_VALTOT"
@author joao.balbino
@since 09/09/2017
@version undefined

@type function
/*/
//-------------------------------------------------------------------
Function GCPCalcTot()
Local oModel 	  := FWModelActive()
Local oView  	  := FwViewActive()
Local oCON_DETAIL := oModel:GetModel('CON_DETAIL')
Local oCOM_MASTER := oModel:GetModel('COM_MASTER')
Local oCOQ_DETAIL := oModel:GetModel('COQ_DETAIL')
Local nValor	  := 0
Local nVlrTotal	  := 0
Local cModSug	  := ""
Local nX		  := 0
Local lAtu		  := .F.
Local aSaveLines  := FWSaveRows()

If oModel:GetId() == 'GCPA100'	
	If oCON_DETAIL:GetValue('CON_METODO') <> '6'
		lAtu := .T.
		nValor := GCPRetVE(oModel)      
			oCON_DETAIL:SetValue('CON_VALEST', nValor)
			cModSug := GCP100MDSug(oModel)   
			For nX := 1 to oCON_DETAIL:Length()
				oCON_DETAIL:GoLine(nX)
			If !oCON_DETAIL:IsDeleted()
				nVlrTotal := nVlrTotal + oCON_DETAIL:GetValue('CON_VALEST')
			EndIf				 
		Next nX          		    
	EndIf
ElseIf oModel:GetId() == 'GCPA101'
	If oCOQ_DETAIL:GetValue('COQ_METODO') <> '6'
		lAtu := .T.
		nValor := GCPRetVE(oModel, , ,'COQ_DETAIL', 'COQ_METODO')      
			oCOQ_DETAIL:LoadValue('COQ_VLRTOT', nValor)
			cModSug := GCP101MDSug(oModel)
			For nX := 1 to oCOQ_DETAIL:Length()
			oCOQ_DETAIL:GoLine(nX)
			If !oCOQ_DETAIL:IsDeleted()
				nVlrTotal := nVlrTotal + oCOQ_DETAIL:GetValue('COQ_VLRTOT')
			EndIf				 
		Next nX	
		EndIf	
EndIf			

FwRestRows(aSaveLines)

If lAtu
	oCOM_MASTER:SetValue('COM_MODSUG', cModSug	)
	oCOM_MASTER:SetValue('COM_VALEST', nVlrTotal)
EndIf

If oCON_DETAIL:Length() > 1 .And. Valtype(oView) == 'O'
	oView:Refresh('VIEW_COP')
EndIf	

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPAllForn()
Realiza o calculo para todos os fornecedores da grid COP_DETAIL

@author Leonardo Quintania
@since 27/09/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCPAllForn()
Local oModel 		:= FWModelActive()

Local oCON_DETAIL	:= oModel:GetModel('CON_DETAIL')
Local oCOP_DETAIL	:= oModel:GetModel('COP_DETAIL')
Local oCOM_MASTER	:= oModel:GetModel('COM_MASTER')
Local nValor		:= 0
Local nI			:= 0
Local aSaveLines 	:= FWSaveRows() 

If oModel:GetId() == 'GCPA100'
	For nI := 1 To oCOP_DETAIL:Length()
		oCOP_DETAIL:GoLine(nI)
		oCOP_DETAIL:SetValue('COP_VALTOT',  oCOP_DETAIL:GetValue('COP_PRCUN') *  oCON_DETAIL:GetValue('CON_QUANT'))
	Next nI	
	If oCON_DETAIL:GetValue('CON_METODO') <> '6'
		nValor := GCPRetVE(oModel)      
   			oCON_DETAIL:LoadValue('CON_VALEST', nValor)
   			oCOM_MASTER:SetValue('COM_MODSUG',  GCP100MDSug(oModel))    	             		    
	EndIf
ElseIf oModel:GetId() == 'GCPA101'
	For nI := 1 To oCOP_DETAIL:Length()
		oCOP_DETAIL:GoLine(nI)
		oCOP_DETAIL:SetValue('COP_VALTOT',  oCOP_DETAIL:GetValue('COP_PRCUN'))
	Next nI	
	If oModel:GetModel('COQ_DETAIL'):GetValue('COQ_METODO') <> '6'
		nValor := GCPRetVE(oModel, , ,'COQ_DETAIL', 'COQ_METODO')      
   			oModel:GetModel('COQ_DETAIL'):LoadValue('COQ_VLRTOT', nValor)
   			oCOM_MASTER:SetValue('COM_MODSUG',  GCP101MDSug(oModel))
   		EndIf												
EndIf			   	

FWRestRows(aSaveLines)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LinhaOkCOP(oModelGrid)
Linha OK do Modelo COP_DETAIL

@author Matheus Lando Raimundo
@since 26/07/2013
@version P11
/*/ 
//-------------------------------------------------------------------
Function LinhaOkCOP(oModelGrid)

Local oModel := FWModelActive()
Local oCOP_DETAIL := oModel:GetModel('COP_DETAIL')
lRet := .T.

If (!oCOP_DETAIL:GetValue('COP_OK')) .And. (Empty(AllTrim(oCOP_DETAIL:GetValue('COP_JUSTIF'))) .And. !oCOP_DETAIL:IsDeleted())
	Help(' ', 1,'GCP100JUST')                          
	lRet := .F.	 	    	          
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP100VdTp()
Realiza validação do Tipo de modalidade com modalidade

@author Leonardo Quintania
@since 23/09/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCP100VdTp(cTpMod)
Local oModel 		:= FWModelActive()
Local oMaster 	:= oModel:GetModel('COM_MASTER')
Local cMod			:= oMaster:GetValue('COM_MODACA')
Local cRegra		:= oMaster:GetValue('COM_REGRA')
Local cEspecie	:= oMaster:GetValue('COM_ESPECI')
Local aTpMd		:= {}
Local nI			:= 0
Local lRet 		:= .F.
Local cVlds		:= ""

Default cTpMod	:= &(ReadVar())


aTpMd:= A200MdTip(cMod,cRegra,cEspecie)

For nI:= 1 To Len(aTpMd)
	If cTpMod == aTpMd[nI]
		lRet:= .T.
		Exit
	Else
		If Empty(cVlds)
			cVlds := aTpMd[nI] 
		Else		
			cVlds := cVlds + ', ' + aTpMd[nI] 
		EndIf			
				
	EndIf
Next nI

If !lRet
	Help("",1,STR0030,,STR0048 + cVlds,4,1)//Atenção//'Tipo inválido para esta modalidade, utilize um dos seguintes tipos: '
EndIf		

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCalcMD

@author Matheus Lando Raimundo
@since 26/07/2013
@version P11
/*/ 
//-------------------------------------------------------------------
Function GCPCalcMD()
Local aModSug := {}
Local cModSug := ''
Local oModel := FWModelActive()
Local lRet := .T.

Local oCOM_MASTER := oModel:GetModel('COM_MASTER')

If oCOM_MASTER:GetValue('COM_REGRA') == '001' .And. oCOM_MASTER:GetValue('COM_ESPECI')== '3'
	lRet := .F.	
EndIf 
 
If !lRet
	Help(' ', 1,'GCP100REGRA')	
Else
	aModSug := GCPA017Lim(oCOM_MASTER:GetValue('COM_REGRA'),oCOM_MASTER:GetValue('COM_ESPECI'),/*cModali*/,;
								IIF(oCOM_MASTER:GetValue('COM_VALEST')==0,1,oCOM_MASTER:GetValue('COM_VALEST')), .F.)
	If Len(aModSug) > 0
		cModSug := aModSug[1]
	Else
		Help(' ', 1,'GCP100VLRMD')
		cModSug := 'PG'		
	EndIf
	oCOM_MASTER:SetValue('COM_MODSUG', cModSug) 	
EndIf	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP100Vis()
Rotina para visualizar a Análise de Mercado alterando o modelo de acordo
com o Tipo (Item ou Lote) da Análise de Mercado

@author Matheus Lando Raimundo
@since 26/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCP100Vis()
If COM->COM_AVAL = '1'	
	FWExecView (STR0021, "GCPA100", MODEL_OPERATION_VIEW ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ ,  /*bCancel*/ )
ElseIf COM->COM_AVAL = '2'
	FWExecView (STR0021, "GCPA101", MODEL_OPERATION_VIEW ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ )
EndIf	

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP100IncP()
Rotina para incluir uma Análise de Mercado por Item

@author Matheus Lando Raimundo
@since 26/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCP100IncP()		
	FWExecView (STR0022, "GCPA100", MODEL_OPERATION_INSERT ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , {||.T.}/*bCancel*/ )	
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP100IncL()
Rotina para incluir uma Análise de Mercado por Lote

@author Matheus Lando Raimundo
@since 26/07/2013
@version P11
/*/
Function GCP100IncL()		
	FWExecView (STR0022, "GCPA101", MODEL_OPERATION_INSERT,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , {||.T.}/*bCancel*/ )		
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP100Alt()
Rotina para alterar uma Análise de Mercado alterando o modelo de acordo
com o Tipo (Item ou Lote) da Análise de Mercado

@author Matheus Lando Raimundo
@since 26/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCP100Alt()
Local lRet := .F.

If (COM->COM_STATUS = '1') 
	If COM->COM_AVAL = '1'			
		FWExecView (STR0023, "GCPA100", MODEL_OPERATION_UPDATE ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , {||.T.}/*bCancel*/ )
	ElseIf COM->COM_AVAL = '2'
		FWExecView (STR0023, "GCPA101", MODEL_OPERATION_UPDATE,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , {||.T.}/*bCancel*/ )
	EndIf	
	lRet := .T.		
Else
	Help(' ', 1,'GCPA100GE')
	lRet := .F.
EndIf	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP100Exc()
Rotina para excluir uma Análise de Mercado alterando o modelo de acordo
com o Tipo (Item ou Lote) da Análise de Mercado

@author Matheus Lando Raimundo
@since 26/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCP100Exc()
If COM->COM_STATUS $ '2|3'
	Help(' ', 1,'GCPA100GE')
ElseIf (COM->COM_AVAL = '1')	
	FWExecView (STR0024, "GCPA100", MODEL_OPERATION_DELETE,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ ,{||.T.} /*bCancel*/ )
Else
	FWExecView (STR0024, "GCPA101", MODEL_OPERATION_DELETE ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , {||.T.}/*bCancel*/ )
EndIf	

Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP100InAv()
Inicializador padrão do campo COM_AVAL

@author Matheus Lando Raimundo
@since 26/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCP100InAv()
Local nRet   := 0
Local oModel := FWModelActive()

If oModel:GetId() == 'GCPA100'
	nRet := 1
ElseIf oModel:GetId() == 'GCPA101'
	nRet := 2	
EndIf	

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP100GEdt()
Geração de  processo licitatório apartir da Analise de mercado

@author Matheus Lando Raimundo
@since 26/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCP100GEdt() 
Local oModel 		:= NIL
Local oCOQDetail 	:= NIL
Local oCONDetail 	:= NIL
Local oCOPDetail 	:= NIL
Local nI			:= 0
Local lRet 		:= .T.
Local aSaveLines 	:= FWSaveRows()

If COM->COM_AVAL == '1'
	oModel := FWLoadModel('GCPA100')
ElseIf	COM->COM_AVAL == '2'
	oModel := FWLoadModel('GCPA101')
EndIf

oCOQDetail 	:= oModel:GetModel('COQ_DETAIL') //Análise de Mercado X Lote
oCONDetail 	:= oModel:GetModel('CON_DETAIL') //Produtos da Análise de Mercado
oCOPDetail 	:= oModel:GetModel('COP_DETAIL') //Fornecedores X Produtos

If  COM->COM_STATUS == '2'  
	Help('',1,'GCPA100GE')
    lRet := .F.
ElseIf COM->COM_STATUS == '3'                         
	Help('',1,'GCPA100GE')
    lRet := .F.
Else
	oModel:SetOperation(1)
	If (lRet := oModel:Activate())
		If COM->COM_AVAL == '1'
			For nI := 1 To oCONDetail:Length()
	   			oCONDetail:GoLine(nI)
	   			If Empty(oCOPDetail:GetValue('COP_CODFOR'))
	   				Help(' ', 1,'GCP100NLPR')//Existe um ou mais produtos sem Fornecedores, informe-os antes de Gerar o  processo licitatório.  	   
	   				lRet := .F.
	   				Exit	   			
	   			EndIf	   		
	   		Next nI		   
			If lRet
				FWRestRows(aSaveLines)
				FWExecView (STR0022, "GCPA200", MODEL_OPERATION_INSERT,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ ,  /*bCancel*/ )
			EndIf
		Else
			For nI := 1 To oCOQDetail:Length()
		   		oCOQDetail:GoLine(nI)
		   		If Empty(oCOPDetail:GetValue('COP_CODFOR'))
		   			lRet := .F.
		   			Help(' ', 1,'GCP101NLFR')//Existe um ou mais Lotes sem Fornecedores, informe-os antes de Gerar o  processo licitatório.  
		   			Exit	   			
		   		EndIf	   		
		   	Next nI
		   	If lRet
			   	FWRestRows(aSaveLines)
				FWExecView (STR0022, "GCPA201", MODEL_OPERATION_INSERT,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ ,  /*bCancel*/ )
			EndIf
		EndIf	
		
	EndIf					
EndIf
	
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPModSug
Rotina gatilha modalidade sugerida

@author Leonardo Quintania
@return NIL

@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCPModSug()
Local oModel 	:= FwModelActive()

If oModel:GetId() == 'GCPA100'
	FWFldPut("COM_MODSUG",  GCP100MDSug(oModel) )
Else
	FWFldPut("COM_MODSUG",  GCP101MDSug(oModel) )
EndIf

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} A100GatFor
Função para gatilhar o nome e a loja do fornecedor / pré-fornecedor

@author Maicon Galhardi
@param cCod Código do participante
@param cTip Tipo do Participante 
@param cOpc 1 = Loja e 2 = Nome 
@since 24/01/2014
@version P11.90
@return cRet
/*/
//-------------------------------------------------------------------
Function A100GatFor(cCod,cTip,cOpc)
Local aArea := GetArea()
Local cRet	:= ""

If cTip == "1" //Pré-Fornecedor	
	CO6->(dbSetOrder(1))
	If CO6->(dbSeek(xFilial("CO6")+cCod))
		If cOpc == 1
			cRet := CO6->CO6_LOJFOR
		Else
			cRet := If(lLGPD,RetTxtLGPD(CO6->CO6_NOME,"CO6_NOME"),CO6->CO6_NOME)
		Endif
	Endif
Else // 2 - Fornecedor
	SA2->(dbSetOrder(1))
	If SA2->(dbSeek(xFilial("SA2")+cCod))
		If cOpc == 1
			cRet := SA2->A2_LOJA
		Else
			cRet := Left(SA2->A2_NOME, TamSX3("COP_NOMFOR")[1])
			If(lLGPD,RetTxtLGPD(@cRet,"COP_NOMFOR"),cRet)
		EndIf
	Endif
Endif 	

RestArea( aArea )
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} A100PrdScd()
Valid para não permitir alterar um produto que tenha sido carregado
a partir uma solicitação de compra.

@author Matheus Lando Raimundo
@return lRet
/*/
//-------------------------------------------------------------------
Function A100PrdScs()
Local lRet 			:= .T.
Local oModel 		:= FWModelActive()
Local oCOODETAIL 	:= oModel:GetModel('COO_DETAIL')
Local nX			:= 0
Local oCON_DETAIL	:= oModel:GetModel('CON_DETAIL')
Local cProd			:= oCON_DETAIL:GetValue('CON_CODPRO') 
Local nQuant		:=	0
Local aSaveLines	:= FWSaveRows()

//Se eu tiver mais de uma linha não deletada (oCOODETAIL:Length(.T.) > 1) 
//ou somente uma linha preenchida (!Empty(oCOODETAIL:GetValue('COO_NUMSC')) .And. !oCOODETAIL:IsDeleted()) não deixa alterar.
//Não posso usar somente oCOODETAIL:Length(.T.) >= 1, pois, retornaria .T. tendo apenas uma linha vazia no modelo       
If (oCOODETAIL:Length(.T.) > 1) .Or. (!Empty(oCOODETAIL:GetValue('COO_NUMSC')) .And. !oCOODETAIL:IsDeleted())
	lRet := .F.
	Help(' ', 1,'A100NPRDSC')
Else
	lRet := .T.		
EndIf

//Valida duplicidade de produtos
For nX := 1 To oCON_DETAIL:Length()
	oCON_DETAIL:GoLine(nX)
	If oCON_DETAIL:GetValue('CON_CODPRO') == cProd
		nQuant++
		If nQuant > 1
			lRet := .F.
			Help(' ', 1,,'GCP100DUP',STR0049,1,0)
			Exit
		EndIf
	EndIf
Next nX

FWRestRows(aSaveLines)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A100VlRegra()
Função para digitar a regra selecionada.

@param cRegra
@author Matheus Lando Raimundo
@return lRet
/*/
//-------------------------------------------------------------------
Function A100VlRegra(cRegra)
Local lRet := .F.

lRet := GCPVMdxRg(cRegra)
If !lRet 	
	Help(' ', 1,'GCPA100NMOD')
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP100VlMd()
Função para digitar a regra selecionada.

@param cRegra
@author Filipe Gonçalves Rodrigues
@return lRet
/*/
//-------------------------------------------------------------------

Function GCP100VlMd(xoldvalue)
	Local lRet := .T.
Return lRet //Deixada a Função para legado do sistema 

/*/{Protheus.doc} GCP100Calc
	Validação para realizar ou não a soma do Calc CONESTTOT
@author philipe.pompeu
@since 05/08/2021
@return lResult, lógico, se deve ou não realizar a soma do Calc
/*/
Function GCP100Calc(oModel)
	Local lResult	:= .F.
	Local oMdlCOP	:= oModel:GetModel("COP_DETAIL")
	Local nLeng		:= oMdlCOP:Length()
	lResult := (nLeng > 1) .Or. (nLeng == 1 .And. !Empty(oMdlCOP:GetValue("COP_CODFOR")))
Return lResult
