#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

Static aDataMdl := {}

/*/-----------------------------------------------------------
{Protheus.doc} TMSOrdGrd
Realiza a Reordenação de Grid em MVC, baseado em um campo de sequencia
É recomendado o uso da mesma na propriedade oView:SetFieldAction
Uso: TMS

@sample
//oView:SetFieldAction('XPTO_SEQUEN', { |oView,cIdForm,cIdCampo,cValue| TMSOrdGrd(oView,oView:GetModel("MdGrid"),cIdForm,cIdCampo,cValue) } )

@author Paulo Henrique Corrêa Cardoso.
@since 26/06/2016
@version 1.0
-----------------------------------------------------------/*/
Function TMSOrdGrd(oView,oModelGrid,cIdForm,cIdCampo,cValue,cFuncVld,aParamVld)
Local nLine        	:= 0               	// Recebe a Linha Atual
Local nValue       	:= 0               	// Recebe o valor digitado em numerico
Local aArea        	:= GetArea()       	// Recebe a Area Ativa
Local nLineDest    	:= 0               	// Recebe a linha de Destino
Local lSobe        	:= .F.             	// Recebe a flag da direção da ordenação
Local nCount       	:= 0               	// Recebe o contador do For
Local nLoop        	:= 0               	// Recebe a quantidade de execução do laço de LineShift
Local nLineAnt     	:= 0               	// Recebe a linha anterior
Local nValueAnt    	:= 0               	// Recebe o valor numerico da linha anterior
Local cValueAtu    	:= ""              	// Recebe o valor da linha atual
Local cValueProx   	:= ""              	// Recebe o valor da proxima linha
Local cValor       	:= ""              	// Recebe o valor digitado
Local lVal         	:= .T.            	// Recebe a validação
Local lView        	:= .F.			  	// Verifica se possui View Ativa


Default oView 		:= FwViewActive()  // Recebe o objeto do View
Default oModelGrid 	:= NIL             // Recebe o objeto do modelo Grid
Default cIdForm    	:= ""              // Recebe o Id do formulario
Default cIdCampo   	:= ""              // Recebe o Id do Campo 
Default cValue     	:= ""              // Recebe o valor digitado
Default cFuncVld   	:= ""              // Recebe a função de Validação
Default aParamVld  	:= {}              // Recebe os parametros da função de validação

Private __aParametro     :={}

__aParametro := aParamVld

If ValType(oView) == "O"
	lView := .T.
EndIf

// Validação da Execução
If !Empty(cFuncVld)
	// Monta a String da função com os parametros
	cFuncVld :=  TMSFnVlOrd(cFuncVld,__aParametro,"__aParametro")
	
	// Executa a função de Validação	
	lVal := &(cFuncVld)
EndIf

//Busca os Valores de Linha atual(Origem)
nLine := oModelGrid:GetLine()

If 	lVal
	//Busca os Valores de Linha atual(Origem)
	nLine := oModelGrid:GetLine()
	
	// Acerta a Variavel cValue
	cValor := TMSOrdValD(oModelGrid,cIdCampo,cValue)
	nValue :=  Val(cValor)
	
	// Acerta o Valor da sequncia antes da digitação
	nLineAnt := LinValida(oModelGrid,nLine,.F.) 
	If nLineAnt == 0 .Or. nLine == 1
		nValueAnt := 1
	Else
		nValueAnt 	:= Val(oModelGrid:GetValue(cIdCampo,nLineAnt)) + 1				
	EndIf
	
	oModelGrid:LoadValue(cIdCampo,STRZERO( nValueAnt, TamSx3(cIdCampo)[1]) )
	
	// Busca a linha que possui o valor de destino
	oModelGrid:Goline(1) 
	If oModelGrid:SeekLine({{cIdCampo,cValor}},.F.)
		nLineDest := oModelGrid:GetLine()
	Else
		nLineDest := nLine
	EndIf 
	
	// Verifica se a Origem e o Destino são diferentes
	If nLineDest != nLine
	
		// Verifica a direção da reordenação
		If lSobe := (nLoop := (nLineDest - nLine)) < 0
			nLoop := nLoop * (-1)
		EndIf
		
		// Define a linha atual
		nLineAtu := nLine
		
		//Executa o Loop de trocas de linhas
		For nCount := 1 To nLoop
			
			If lSobe
				nProxLine := nLineAtu - 1
			Else
				nProxLine := nLineAtu + 1
			EndIf
			
			// Verifica se a Proxima linha esta deletada e caso contrario inverte os valores da Sequencia
			oModelGrid:GoLine(nProxLine)
			If !oModelGrid:IsDeleted()
				cValueAtu   := oModelGrid:GetValue(cIdCampo,nLineAtu)
				cValueProx  := oModelGrid:GetValue(cIdCampo,nProxLine)
				
				oModelGrid:GoLine(nProxLine)
				oModelGrid:LoadValue(cIdCampo,cValueAtu)
				
				oModelGrid:GoLine(nLineAtu)
				oModelGrid:LoadValue(cIdCampo,cValueProx)
	
			EndIf
					
			// Efetiva a Troca de linhas 
			If lView
				oView:LineShift(cIdForm,nLineAtu,nProxLine,.F.)
			Else
				oModelGrid:LineShift(nLineAtu,nProxLine,.F.)
			EndIf

			// Redefine a linha atual
			nLineAtu := nProxLine
			
		Next nCount
			
	EndIf
	
	If lView
		oView:GoLine(oModelGrid:getId(),nLineDest) //Posiciona na linha  
		oView:Refresh(cIdForm) //Atualiza a tela
	Else
		oModelGrid:GoLine(nLineDest)
	EndIf 
Else

	If lView	
		oView:GoLine(oModelGrid:getId(),nLineDest) //Posiciona na linha   
		oView:Refresh(cIdForm) //Atualiza a tela 
	Else
		oModelGrid:GoLine(nLineDest)
	EndIf
	
EndIf

RestArea(aArea)  

Return {nLine,nLineDest}

/*/-----------------------------------------------------------
{Protheus.doc} LinValida
Busca a linha posterior ou anterior valida

Uso: TMS

@sample
//LinValida(oModelGrid,nLinhaAtu,lProx)

@author Paulo Henrique Corrêa Cardoso.
@since 09/05/2016
@version 1.0
-----------------------------------------------------------/*/
Function LinValida(oModelGrid,nLinhaAtu,lProx)
Local nLinha       := 0             // Recebe a Linha de Retorno	
Local lDelet       := .T.           // Recebe a Variavel de Controle do For de linha deletada
Local nProx        := 0             // Recebe o Contador para a proxima linha
Local aSaveLine    := FWSaveRows()  // Salva as posições de linha do Grid

Default oModelGrid := NIL           // Recebe o Modelo do Grid
Default nLinhaAtu  := 0             // Recebe a Linha Atual
Default lProx      := .T.           // Recebe a variavel de controle de Proximo ou Anterior
	

// Verifica se a linha a ser retorndada é a Posterior ou a Anterior
If lProx
	nProx := 1
Else
	nProx := -1
EndIf

// Busca a proxima Linha Posterior ou Anteriror não deletada
While lDelet
	
	If nLinhaAtu + nProx > oModelGrid:Length() .OR. nLinhaAtu + nProx <= 0 // Caso a Proxima esteja fora do tamanho do Grid retorna linha 0 e sai da função
		oModelGrid:GoLine(nLinhaAtu)
		If oModelGrid:IsDeleted()
			nLinha := 0
		Else
			nLinha := nLinhaAtu
		EndIf
		Exit
	Else
		// Posiciona na proxima linha
		oModelGrid:GoLine(nLinhaAtu + nProx)
	
		// Caso a linha não esteja deletada retorna a linha
		If !(lDelet := oModelGrid:IsDeleted())
			nLinha := oModelGrid:GetLine()
		Else
			If lProx
				nProx += 1 
			Else
				nProx -= 1
			EndIf
		EndIf
	EndIf
EndDo
FWRestRows( aSaveLine )
Return nLinha


/*/-----------------------------------------------------------
{Protheus.doc} TMSOrdDel
Reordena as linhas do grid, após a exclusão ou recuperação
É recomendado o uso dentro da propriedade bLinePre do modelo do grid
Uso: TMS

@sample
// Comandos dentro da função do bloco bLinePre do modelo do grid
If cAction == 'DELETE' // Reordenação quando linha estiver sendo excluida

	TMSOrdDel(oView,oModelGrid,"XPTO_SEQUEN",nLine,.F.)
	
ElseIf cAction == 'UNDELETE' // Reordenação quando linha estiver sendo Recuperada

	TMSOrdDel(oView,oModelGrid,"XPTO_SEQUEN",nLine,.T.)
	
EndIf

@author Paulo Henrique Corrêa Cardoso.
@since 31/08/2016
@version 1.0
-----------------------------------------------------------/*/
Function TMSOrdDel(oView,oModelGrid,cCampo,nLine,lRecupera)
Local aArea       := GetArea()  // Recebe a Area Atual
Local lRet        := .T.        // Recebe o Retorno
Local nLinhaAtu   := 0          // Recebe a linha atual
Local nQtdGrid    := 0          // Recebe a quantidade de linhas do grid 
Local nAntLine    := 0          // Recebe a linha anterior valida
Local aRetView    := {}         // Recebe o ultimo Componente selecionado da View
Local nSeqAnt     := 0          // Recebe o valor numerico da sequencia da linha anterior
Local nLineProx   := 0          // Recebe a Proxima Linha
Local lView       := .F.        // Receve se possui View Ativa

Default oView      := FwViewActive()  // Recebe o objeto do View 
Default oModelGrid := NIL             // Recebe o objeto do Modelo do Grid 
Default nLine      := 0               // Recebe a linha 
Default lRecupera  := .F.             // Recebe se a linha esta sendo recuperada

If ValType(oView) == "O"
	lView := .T.
EndIf

If !Empty(oModelGrid) .AND. !Empty(nLine)

	// Recebe o Valor numerico da sequencia da linha atual
	nLinhaAtu := Val(oModelGrid:GetValue(cCampo,nLine))
	
	// Recebe o Tsmanho do Grid
	nQtdGrid  := oModelGrid:Length()
	
	If lView
		// Recebe o ultimo Componente selecionado da View
		aRetView := oView:GetCurrentSelect()
	EndIf

	// Caso a linha não for a primeira
	If nLine > 1
		// Pega a linha anterior valida
		nAntLine :=  LinValida(oModelGrid,nLine,.F.)
		If nAntLine > 0
			// Recebe a sequencia da linha anterior
			nSeqAnt := Val(oModelGrid:GetValue(cCampo,nAntLine))
			
			// Caso não exista proxima linha ou o valor da sequencia da linha atual seja maior que o da linha anterior 
			If LinValida(oModelGrid,nLine,.T.) == 0 .OR. nLinhaAtu > nSeqAnt
				oModelGrid:GoLine(nLine)
				
				// Preenche o valor da sequencia da linha com o valor da sequencia da linha anterior + 1 
				nLinhaAtu := nSeqAnt + 1
				oModelGrid:LoadValue(cCampo,STRZERO( nLinhaAtu, TamSx3(cCampo)[1]))
			ElseIf	nLinhaAtu == nSeqAnt  // Caso a linha atual tenha o mesmo valor da sequencia da linha anterior 
				oModelGrid:GoLine(nLine)
				
				// Soma 1 no valor da linha atual
				nLinhaAtu += 1
				oModelGrid:LoadValue(cCampo,STRZERO( nLinhaAtu, TamSx3(cCampo)[1]))
			
			ElseIf nLinhaAtu < nSeqAnt
				
				oModelGrid:GoLine(nLine)
				
				nLinhaAtu := nSeqAnt + 1
				// Caso a linha atual seja maior que a linha anterior soma 1 na sequencia da linha anterior
				oModelGrid:LoadValue(cCampo,STRZERO( nLinhaAtu, TamSx3(cCampo)[1]))
			EndIf
		Else
			// Caso não tenha linha anterior define a sequancia da linha como 1
			oModelGrid:GoLine(nLine)
			nLinhaAtu := 1
			oModelGrid:LoadValue(cCampo,STRZERO( nLinhaAtu, TamSx3(cCampo)[1]))
		EndIf
	EndIf
	
	
	nLineProx := nLine + 1
	
	// Ajusta a sequencia das proximas linhas	
	While(nLineProx <= nQtdGrid)     
		oModelGrid:GoLine(nLineProx)
		
		// Caso a proxima linha não esteja deletada ajusta sua sequencia
		If !oModelGrid:IsDeleted()
			If lRecupera
				oModelGrid:LoadValue(cCampo,STRZERO( nLinhaAtu + 1, TamSx3(cCampo)[1])) 
		 	Else
		 		oModelGrid:LoadValue(cCampo,STRZERO( nLinhaAtu , TamSx3(cCampo)[1])) 
		 	EndIf
		 	
		 	nLinhaAtu += 1
		 
		 EndIf 	
		 nLineProx += 1
	EndDo 
	
	/* Talvez comentar linha */ 
	If lView
		oView:GoLine(oModelGrid:getId(),nLine) //Posiciona na linha   

		/* Talvez comentar linhas */
		If !Empty(aRetView[1])
			oView:Refresh(aRetView[1]) //Atualiza a tela 
		EndIf
	Else
		oModelGrid:GoLine(nLine) //Posiciona na linha 
	EndIf

EndIf	

RestArea(aArea)

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSFnVlOrd
Monta string de função

Uso: TMS

@sample
//TMSFnVlOrd(cFuncVld,aParamVld,cNomParam)

@author Paulo Henrique Corrêa Cardoso.
@since 01/09/2016
@version 1.0
-----------------------------------------------------------/*/
Function TMSFnVlOrd(cFuncVld,aParamVld,cNomParam)
Local nCount       := 0               // Recebe o contador do For
Local cParams      := ""              // Recebe a string de parametros da função de validação
Local cRet         := ""              // Recebe o Retorno

Default cFuncVld   := ""              // Recebe a função de Validação
Default aParamVld  := {}              // Recebe os parametros da função de validação
Default cNomParam  := ""				   // Recebe o nome da variavel do array de parametros

If !Empty(cFuncVld)
	
	// Remove o Parenteses da função 
	If At("(",cFuncVld) > 0
		cFuncVld := Substr(cFuncVld,1, At("(",cFuncVld)-1)
	EndIf
	
	cParams += "("
	
	If Len(aParamVld) > 0
		
		//Varre o Array de parametros
		For nCount := 1 To Len (aParamVld)
			
			cParams +=  "@"+ cNomParam + "["+ cValToChar(nCount) +"]"
			
			// Adiciona a virgula
			If nCount < Len(aParamVld)
				cParams += ","
			EndIf
			
		Next nCount
		
	EndIf
	
	cParams += ")"
	
	cRet := cFuncVld + cParams
	
EndIf

Return cRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSAddLnMd
É utilizado para inserir linhas no meio do grid.
Obs.: Somente em grids com campo de sequencia. 
Uso: TMS

@sample


@author Paulo Henrique Corrêa Cardoso.
@since 27/09/2016
@version 1.0
-----------------------------------------------------------/*/
Function TMSAddLnMd(oView,oModelGrid,cIdForm,cCampoSeq,lBaixo,cValue,cFuncVld,aParamVld)
Local nLine        := 0               // Recebe a Linha Atual
Local nValue       := 0               // Recebe o valor digitado em numerico
Local aArea        := GetArea()       // Recebe a Area Ativa
Local lVal         := .T.             // Recebe a validação
Local nNewLine     := 0               // Recebe a nova linha
Local cSeqAtu      := ""              // Recebe a sequencia atual do campo 
Local aRet         := {}              // Recebe o Retorno


Default oView      := FwViewActive()  // Recebe o objeto do View
Default oModelGrid := NIL             // Recebe o objeto do modelo Grid
Default cIdForm    := ""              // Recebe o Id do formulario
Default cCampoSeq   := ""             // Recebe o Campo de sequencia do Grid 
Default lBaixo     := .T.             // Recebe se a linha sera adicionado posterior a linha atual 
Default cValue     := ""              // Recebe o Valor de sequencia  
Default cFuncVld   := ""              // Recebe a função de Validação
Default aParamVld  := {}              // Recebe os parametros da função de validação

Private __aParametro     :={}

// Validação da Execução
If !Empty(cFuncVld)

	__aParametro := aParamVld
	// Monta a String da função com os parametros
	cFuncVld :=  TMSFnVlOrd(cFuncVld,__aParametro,"__aParametro")
	
	// Executa a função de Validação	
	lVal := &(cFuncVld)
EndIf

If 	lVal
	//Busca os Valores de Linha atual(Origem)
	nLine := oModelGrid:GetLine()
	cSeqAtu := oModelGrid:GetValue(cCampoSeq,nLine) 
	
	nNewLine := oModelGrid:AddLine()
	oModelGrid:GoLine(nNewLine)
	
	// Acerta a Variavel cValue
	nValue :=  Val(cValue)
	If lBaixo
		nValue += 1
	EndIf
	cValue := STRZERO( nValue, TamSx3(cCampoSeq)[1]) 
	
	aRet := TMSOrdGrd(oView,oModelGrid,cIdForm,cCampoSeq,cValue,cFuncVld,aParamVld)
EndIf

RestArea(aArea) 

Return aRet


/*/-----------------------------------------------------------
{Protheus.doc} TMSOrdValD
Busca o Valor Real da sequencia de acordo com o grid
Uso: TMS

@sample
//TMSOrdValD(oModelGrid,cIdCampo,cValue)

@author Paulo Henrique Corrêa Cardoso.
@since 30/09/2016
@version 1.0
-----------------------------------------------------------/*/
Function TMSOrdValD(oModelGrid,cIdCampo,cValue)
Local cValor   := ""    // Recebe o Valor do Campo da sequencia
Local nValue   := 0     // Recebe o valor numerico da sequencia 


cValor := cValue
	
// Acerta a Variavel cValue
nValue :=  Val(cValor)
cValor := STRZERO( nValue, TamSx3(cIdCampo)[1]) 

//Verifica se o valor digitado é maior que a quantidade de linhas validas no Grid e define seu valor como o ultimo do grid
If oModelGrid:Length(.T.) < nValue
	cValor := STRZERO( oModelGrid:Length(.T.), TamSx3(cIdCampo)[1]) 
EndIf

// Verifica se o valor digitado é menor ou igual a zero e define seu valor como 1
If nValue <= 0 
	cValor := STRZERO( 1, TamSx3(cIdCampo)[1]) 
EndIf


Return cValor


/*/-----------------------------------------------------------
{Protheus.doc} TMSDelLnGrd
Deleta fisicamente a linha do grid
Uso: TMS

@sample
//TMSDelLnGrd(oView,oModelGrid,nLine,cFormId)

@author Paulo Henrique Corrêa Cardoso.
@since 30/09/2016
@version 1.0
-----------------------------------------------------------/*/
Function TMSDelLnGrd(oView,oModelGrid,nLine,cFormId)
Local lView          := .F.             // Recebe se Possui View Ativa

Default oView        := FwViewActive()
Default oModelGrid   := NIL
Default nLine        := 0
Default cFormId      := ""


If ValType(oView) == "O"
	lView := .T.
EndIf

If ValType( oModelGrid:aDataModel) == "A" .And. Len(oModelGrid:aDataModel) > 1

	aDataMdl := oModelGrid:aDataModel 

	If Type('aDataMdl[1,1,1,1]') <> "U" 
		//-- Deleta Linha Em Branco Da Grid
		aDel(oModelGrid:aDataModel , nLine )
		
		// Atualiza o tamanha do array
		aSize(oModelGrid:aDataModel , Len(oModelGrid:aDataModel) - 1 )
		
		If lView
			oView:Refresh(cFormId) //Atualiza a tela 
		EndIf

	EndIf
	aDataMdl := {}
EndIf

Return

/*/-----------------------------------------------------------
{Protheus.doc} TMSCopyLin
Copia uma determinada linha de um grid em MVC
Uso: TMS

@sample
//TMSCopyLin(oView,oModelGrid,nLine,nCopia,aNoFields,cFormId,lUltimo,cCampoSeq,cFuncCopy,aParamFnc)

@author Paulo Henrique Corrêa Cardoso.
@since 26/01/2017
@version 1.0
-----------------------------------------------------------/*/
Function TMSCopyLin(oView,oModelGrid,nLine,nCopia,aNoFields,cFormId,lUltimo,cCampoSeq,cFuncCopy,aParamFnc)
	Local oStrucGrd      := NIL             // Recebe a estrutura do Grid
	Local aFieldGrd		 := {}              // Recebe os campos da estrutura
	Local nNewLine       := 0               // Recebe o numero da nova linha
	Local nCntFld        := 0               // Recebe o contador de campos
	Local nCntCopy       := 0               // Recebe o contador de copias
    Local lView          := .F.             // Recebe se possui View Ativa

	Default oView        := FwViewActive()  // Recebe o View Ativo
	Default oModelGrid   := NIL             // Recebe o Modelo do Grid
	Default nLine        := 0               // Recebe o numero da linha a ser copiada
	Default nCopia       := 1               // Recebe a quantidade de copias
	Default aNoFields	 := {}				// Recebe os campos que não devem ser copiados
	Default cFormId      := ""              // Recebe o id do Formulario
	Default lUltimo      := .T.             // Recebe se a linha deve ser inseria no final do Grid
	Default cCampoSeq    := ""              // Recebe o campo de sequencia do modela para realizar a reordenação
	Default cFuncCopy    := ""              // Recebe função que será executada após a copia de cada linha
	Default aParamFnc    := {}              // Recebe os parametros da função pós copia

	Private __aParametro     :={}
	
	If ValType(oView) == "O"
		lView := .T.
	EndIf

	__aParametro := aParamFnc
	nNewLine := nLine
	// Roda a quantidade de vezes que a linha será copiada
	For nCntCopy := 1 To nCopia
		// Insere a linha
		If !lUltimo .AND. !Empty(cCampoSeq) // Insere abaixo da linha atual
			nNewLine :=  TMSAddLnMd(oView,oModelGrid,cFormId,cCampoSeq,.T.,oModelGrid:GetValue(cCampoSeq,nNewLine))[2]
		Else  // Insere por ultimo
			nNewLine := oModelGrid:AddLine() 
		EndIf

		//Recebe a Estrutura do Grid
		oStrucGrd := oModelGrid:GetStruct()

		// Recebe os campos da Estrutura
		aFieldGrd := oStrucGrd:GetFields()
		
		// Posiciona na nova linha
		oModelGrid:GoLine(nNewLine)

		// Varre os campos
		For nCntFld := 1 To Len(aFieldGrd)

			// Verifica se o campo pode ser copiado
			If aScan(aNoFields,{|x| AllTrim(x) == AllTrim( aFieldGrd[nCntFld][3] ) }) == 0
				// Preenche o campo com o valor do campo principal
				oModelGrid:LoadValue(aFieldGrd[nCntFld][3],oModelGrid:GetValue(aFieldGrd[nCntFld][3],nLine))
			EndIf
		Next nCntFld
		
		// Executa Função de tratamento após copia
		If !Empty(cFuncCopy)
			// Monta a String da função com os parametros
			cFuncCopy :=  TMSFnVlOrd(cFuncCopy,__aParametro,"__aParametro")
			
			// Executa a função de tratamento após copia
			 &(cFuncCopy)
		EndIf

	Next nCntCopy
	
	If lView
		oView:Refresh(cFormId) //Atualiza a tela 
	EndIf
	
Return 
