#INCLUDE 'SFCXFUN.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
#include "TOTVS.CH"
#INCLUDE "AP5MAIL.CH"  
#INCLUDE 'FileIO.CH'
#DEFINE PULALINHA CHR(13)+CHR(10)

//----------------------------------------------------------------------
/*/{Protheus.doc} SFCXContidoRangeHoras
Função valida se um determinada hora está contida dentro de periodo informado.
Utiliar horas válidas, para isso utilizar a função SFCXCheckHour  

@param  cHoraInicial             (Obrigatório)Começo do periodo 
@param  cHoraFinal    		  	 (Obrigatório)Término do periodo(deve ser maior que o cHoraInicial) 
@param  cHoraComparacao          (Obrigatório)Hora para comparar entre o periodo informado
@param  lDesconsiderIgualdade    Desconsidera igualdade, portanto ele deve estar contido dentro do periodo porém não pode ser igual 
                                         
@sample
                SFCXContidoRangeHoras("99:99:99", "99:99:99", "99:99:99")
                
                SFCXContidoRangeHoras("99:99:99", "99:99:99", "99:99:99")

@return Retorna .F./.T. para indicar se o horário informado pertence ao periodo informado

@author Tiago Gauziski
@since 13/09/10
@version 1.0
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCXContidoRangeHoras(cHoraInicial, cHoraFinal, cHoraComparacao, lDesconsideraIgualdade)
Local lRet := .F.
Local nSegHoraInicial
Local nSegHoraFinal
Local nSegHoraComparacao

nSegHoraInicial := SFCXHourToSeg(cHoraInicial)  //retira a quantidade de segundos do horário inicial
nSegHoraFinal := SFCXHourToSeg(cHoraFinal)		//retira a quantidade de segundos do horário final
nSegHoraComparacao := SFCXHourToSeg(cHoraComparacao) //retira a quantidade de segundos do horário para comparação

If (nSegHoraFinal > nSegHoraInicial) //valida se a hora inicial é menor que a hora final
	If (lDesconsideraIgualdade)
		If (nSegHoraComparacao > nSegHoraInicial .And. nSegHoraComparacao < nSegHoraFinal)  // compara para saber se o horário está contido no periodo informado
			lRet := .T.
	    EndIf
    Else
	    If (nSegHoraComparacao >= nSegHoraInicial .And. nSegHoraComparacao <= nSegHoraFinal)  // compara para saber se o horário está contido no periodo informado
			lRet := .T.
	    EndIf
    EndIf
Else
	lRet := .T.
	If (lDesconsideraIgualdade)
		If (nSegHoraComparacao <= nSegHoraInicial .And. nSegHoraComparacao >= nSegHoraFinal)  // compara para saber se o horário está contido no periodo informado
			lRet := .F.
	    EndIf
    Else
	    If (nSegHoraComparacao < nSegHoraInicial .And. nSegHoraComparacao > nSegHoraFinal)  // compara para saber se o horário está contido no periodo informado
			lRet := .F.
	    EndIf
    EndIf
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXExpTab
Função verifica se a primeira string esta contida na segunda.
Da esquerda para direita, utilizado para buscar registro que não contenha
todas informações do indice

@param  Str1 (Obrigatório) String1 
@param  Str2 (Obrigatório) String2

@sample EstaContido("abc","abcde")

@return Retorna valor lógico informando se esta contido

@author Ezequiel Ramos
@since 20/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EstaContido(Str1,Str2)
	Local nI
	For nI := 1 To Len(Str1)
		If Substring(Str1,nI,1) != Substring(Str2,nI,1)
			Return .F.
		EndIf
	Next
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXExpTab
Função exporta uma tabela no formato CSV já apresentando uma tela para
seleção do local de destino para salvar o arquivo. 
A função faz o filtro pela filial caso a tabela esteja no modo exclusiva.

@param  cTabela (Opcional) Sigla da tabela a ser exportada 
@param  nOrder  (Opcional) Indice da tabela a ser exportada
@param  cSeek (Opcional) Buca do indice da tabela a ser exportada
@param  oTabela (Opcional) Sigla da tabela a ser exportada

@sample SFCXExpTab("CZ5",1,xFilial("CZ5")+aFiltro[10]+aFiltro[11],oCCZ5)

@return Nil

@author Ezequiel Ramos
@since 20/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCXExpTab(cTabela,nOrder,cSeek,oTabela)

	Local nHandle
	Local aArray
	Local nI		:= 1
	Local cContent	:= ""
	Local nAt := 0

	Default cTabela	:= ""
	Default cSeek	:= xFilial(cTabela)
	Default nOrder	:= 0
	
	cFile := cGetFile("CSV|*.csv",STR0057,0,"C:\",.F.,,.F.)//"Selecione um diretório para exportar o arquivo"   

	If !Empty(cFile)

		cFile += ".csv"
	
		nHandle := FCreate(cFile)
		If cTabela != ""
			dbSelectArea( cTabela )
			oTabela := ( cTabela )
			(cTabela)->( dbSetOrder( nOrder ) )
			(cTabela)->( dbGoTop() )
			(cTabela)->( dbSeek( cSeek ) )
		Else
			(oTabela)->( DbGoTop() )
		EndIf
		
		aArray := (oTabela)->(dbStruct())

		While nI <= Len(aArray) 
			If aArray[nI][1] == "R_E_C_N_O_" .Or. aArray[nI][1] == "R_E_C_D_E_L_"
				aDel(aArray,nI)
				aSize(aArray,Len(aArray)-1) 
			Else
				nI++
			EndIf
		End
		                                  
		For nI := 1 To Len(aArray)
			If nI == Len(aArray)
				cContent += aArray[nI][1]
			Else
				cContent += aArray[nI][1]+";"
			EndIf 
		Next

		FWrite(nHandle, cContent)
		cContent := ""
		
		For nI := 1 To Len(aArray)
			If nI == Len(aArray)
				cContent += GetSx3Cache(aArray[nI][1],'X3_TITULO')
			Else
				cContent += GetSx3Cache(aArray[nI][1],'X3_TITULO')+";"
			EndIf 
		Next

		FWrite(nHandle, PULALINHA + cContent)
		
		While !(oTabela)->( Eof() ) .AND. If(nOrder!=0,EstaContido(cSeek,(oTabela)->&((oTabela)->(IndexKey(nOrder)))),.T.)
			cContent := ""
			For nI := 1 To Len(aArray)
				//Adiciona ao content da linha conforme o tipo do registro
				If aArray[nI][2] == "D" //Data
					cContent += Substring(DToS( (oTabela)->&(aArray[nI][1]) ),7,2) + "/" + Substring(DToS( (oTabela)->&(aArray[nI][1]) ),5,2) + "/" + Substring(DToS( (oTabela)->&(aArray[nI][1]) ),1,4)
				ElseIf aArray[nI][2] == "C" .And. TamSX3(aArray[nI][1])[3] == "D" //Data
					cContent += Substring( (oTabela)->&(aArray[nI][1]) ,7,2) + "/" + Substring( (oTabela)->&(aArray[nI][1]) ,5,2) + "/" + Substring( (oTabela)->&(aArray[nI][1]) ,1,4)
				ElseIf aArray[nI][2] == "N" //Número
					cContent += StrTran(AllTrim(Str((oTabela)->&(aArray[nI][1]))), ".", ",")
				ElseIf aArray[nI][2] == "L" .AND. (oTabela)->&(aArray[nI][1])//Lógico Verdadeiro
					cContent += ".T."
				ElseIf aArray[nI][2] == "L"//Lógico Falso
					cContent += ".F."
				Else //Caracter
					cContent += (oTabela)->&(aArray[nI][1])
				EndIf
				//Se não for o último registro da linha, adiciona um ponto-e-virgula ";"
				If nI != Len(aArray)
					cContent += ";"
				EndIf 
			Next
			FWrite(nHandle, PULALINHA + cContent)
			(oTabela)->( dbSkip() )
		End
		
		FClose(nHandle)
	EndIf
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXHourToSeg
Função converte uma determinada hora em segundos
É apenas aceito em um unico formato: "99:99:99"

@param  cHoraParaConverter             (Obrigatório)Horário para fazer a conversão 

@sample
                SFCXHourToSeg("99:99:99")

@return Retorna um valor numérico que contem a hora informada em segundos

@author Tiago Gauziski
@since 13/09/10
@version 1.0
/*/
//------------------------------------------------------------------- 
Function SFCXHourToSeg(cHoraParaConverter)
Local nSegundos
Local nMinutos
Local nHora
Local nRetornoSegundos 

nHora := VAL(SUBSTR(cHoraParaConverter, 1, 2))     //retira o valor das horas
nMinutos := VAL(SUBSTR(cHoraParaConverter, 4, 2))  //retira o valor dos minutos
nSegundos := VAL(SUBSTR(cHoraParaConverter, 7, 2)) //retira o valor dos segundos 

nRetornoSegundos := (nHora * 3600) + (nMinutos * 60) + nSegundos //faz os cálculos para retornar os segundos

Return nRetornoSegundos 

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXCheckHour
Função converte uma determinada hora em segundos
É apenas aceito em um unico formato: "99:99:99"

@param  cHoraParaVerificar             (Obrigatório)Horário para fazer a verificação

@sample
                SFCXCheckHour("99:99:99")

@return Retorna se o horário é valido ou não...

@author Tiago Gauziski
@since 29/09/10
@version 1.0
/*/
//------------------------------------------------------------------- 
Function SFCXCheckHour(cHour)
Local nSegundos
Local nMinutos
Local nHora
Local lRet  := .T.

If cHour == '  :  :  '   
	lRet := .F.
ElseIf Len(ALLTRIM(cHour)) < 8 
	lRet := .F.
ElseIf At('-', cHour) > 0
	lRet := .F.
Else
	nHora := VAL(SUBSTR(cHour, 1, 2))     //retira o valor das horas
	nMinutos := VAL(SUBSTR(cHour, 4, 2))  //retira o valor dos minutos
	nSegundos := VAL(SUBSTR(cHour, 7, 2)) //retira o valor dos segundos
	
	If(nHora > 24)
		lRet := .F.
	ElseIf(nMinutos > 59)
   		lRet := .F.
	ElseIf(nSegundos > 59)
		lRet := .F.
	EndIf
EndIf   

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXValDate
Função valida se um determinada data está contida dentro de periodo informado

@param  dDataInicial             (Obrigatório)Começo do periodo  
@param  dDataFinal    		  	 (Obrigatório)Término do periodo
@param  dDataComparacao          (Obrigatório)Hora para comparar entre o periodo informado 
                                         
@sample
                SFCXContidoRangeHoras("DD/MM/YYYY", "DD/MM/YYYY", "DD/MM/YYYY")

@return Retorna .F./.T. para indicar se a data informada pertence ao periodo informado

@author Tiago Gauziski
@since 13/09/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCXValDate(dDataInicial, dDataFinal, dDataComparacao)
Local lRet := .F.

If (dDataInicial <= dDataFinal)
	If(dDataInicial <= dDataComparacao .And. dDataComparacao <= dDataFinal)	
		lRet := .T.	
	EndIf
EndIf
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXMenorValor
Função reponsável por retornar o menor valor entre dois

@param  nValueOne             (Obrigatório)Valor de Comparacao  
@param  nValueTwo    		  (Obrigatório)Valor de Comparacao
                                         
@sample
                SFCXMenorValor(1, 2)

@return Retorna o menor valor

@author Tiago Gauziski
@since 29/10/10
@version 1.0
/*/
//-------------------------------------------------------------------           
Function SFCXMenorValor(nValueOne, nValueTwo)

If(nValueOne > nValueTwo)
	Return nValueOne
Else
	Return nValueTwo
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXSegtoHour
Converte segundos em horas formato horário
Uso Geral.

@param 	nSeg		Hora em segundos

@Return cHora		Hora em relógico horário

@author Samantha Preima
@since 15/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCXSegtoHour ( nSeg )
Local cHora

cHora := IF(ALLTRIM(STR(INT(nSeg / 3600))) == '','00',ALLTRIM(STRZERO(INT(nSeg / 3600),2))) + ':'
nSeg  -= INT(nSeg / 3600) * 3600
cHora += IF(ALLTRIM(STR(INT(nSeg / 60))) == '','00',ALLTRIM(STRZERO(INT(nSeg / 60),2))) + ':'
nSeg  -= INT(nSeg / 60) * 60 
cHora += IF(ALLTRIM(STR(nSeg)) == '','00',ALLTRIM(STRZERO(nSeg,2)))
 
Return cHora    

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXSegtoCent
Converte segundos em horas formato centesimal
Uso Geral.

@param 	nSeg		Hora em segundos

@Return nHora		Hora em relógico centesimal

@author Samantha Preima
@since 15/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCXSegtoCent ( nSeg )
Local nHora

nHora := nSeg / 3600
 
Return nHora  

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCMsgErro
Exibe Mensagem de erro.
Uso Geral.

@param 	cMsg		Mensagem de erro
@param 	cRotina		Nome da rotina a ser exibida na janela
@param 	nTipo		Tipo mensagem de erro:
					1- Erro não cadastrado
					2- Alerta
					3- Erro cadastrado no ATUSX

@Return lRet	 	 .F. Sempre retorna .F. indicando um erro para poder
usar em gatilhos e validações onde exibira a mensagem e retornara .F.

@sample
lRetorno := IIf(nTotal > 0 , .T., SFCMsgErro( 'Total esta zerado', 'MinhaRotina' ))
                                                                                  	
@see SFCMsgOK

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCMsgErro ( cMsg, cRotina, nTipo )

ParamType 0 Var cMsg       As Character Optional Default STR0001 // "Erro ..."
ParamType 1 Var cRotina    As Character Optional Default ProcName( 1 )
ParamType 2 Var nTipo      As NUMERIC   Optional Default 1

if nTipo == 1
	Help( ,, 'HELP', cRotina, cMsg, 1, 0)
ElseIf nTipo == 2
	MsgAlert(cMsg, cRotina)
Else
	Help( ,, 'HELP', cMsg, , 1, 0)
Endif

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXMenorData
Função reponsável por retornar a menor data entre duas datas

@param  dDateOne             (Obrigatório)Data de Comparacao  
@param  dDateTwo    		 (Obrigatório)Data de Comparacao  
                                         
@sample
                SFCXMenorData(DATE(), DATE() + 1)

@return Retorna menor data

@author Tiago Gauziski
@since 29/11/10
@version 1.0
/*/
//-------------------------------------------------------------------           
Function SFCXMenorData(dDateOne, dDateTwo)

If(dDateOne > dDateTwo)
	Return dDateTwo
Else
	Return dDateOne
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXMaiorData
Função reponsável por retornar a maior data entre duas datas

@param  dDateOne             (Obrigatório)Data de Comparacao  
@param  dDateTwo    		 (Obrigatório)Data de Comparacao  
                                         
@sample
                SFCXMaiorData(DATE(), DATE() + 1)

@return Retorna maior data

@author Tiago Gauziski
@since 29/11/10
@version 1.0
/*/
//-------------------------------------------------------------------           
Function SFCXMaiorData(dDateOne, dDateTwo)

If(dDateOne > dDateTwo)
	Return dDateOne
Else
	Return dDateTwo
EndIf

Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCX000OK
Validação do botão OK ao sair da tela e se confirmas todos os dados que existem na tela são salvos nos parametros na Base

@author Jorge Matos Valcanaia	
@since 05/04/10
@version 1.0
/*///------------------------------------------------------------------------------------------------                                          
Function SFCX000OK() 

Return .T.              
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCXMOVE
Mover itens de array pelos browsers

@author Ana Carolina Tomé Klock
@since 15/12/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCXMOVE(oBrwEsq, oBrwDir, aFieldsEsq, aFieldsDir, lRemove, cChave, lInsere, cIdMePo)
    
	If lRemove = .T.      
		dbSelectArea("CY8")             
		If !Empty(Posicione("CY8",1,XFILIAL("CY8")+cValToChar(cIdMePo)+aFieldsEsq[oBrwEsq:nAt][1], "CY8_CDIN"))   	
			DBRLock(Recno()) 
			DBDelete()    
   		EndIf                                                   
	ElseIf lInsere = .T.                                        
		dbSelectArea("CYJ")
		dbSeek(xFilial("CYJ")+cChave) 
			cCdIn    := CYJ->CYJ_CDIN
	   		cCor1    := CYJ->CYJ_DSMI 
	   		cEmail1  := CYJ->CYJ_DSSIMI
	   		cDescri1 := CYJ->CYJ_DSMSMI	
	   		cCor2    := CYJ->CYJ_DSXA   
	   		cEmail2  := CYJ->CYJ_DSSIXA
	   		cDescri2 := CYJ->CYJ_DSMSXA
	   		cCor3    := CYJ->CYJ_DSMX
	   		cEmail3  := CYJ->CYJ_DSSIMX
	   		cDescri3 := CYJ->CYJ_DSMSMX 
	   		nValor1  := CYJ->CYJ_VLEDMI
	   		nValor2  := CYJ->CYJ_VLEDXA
	 	dbCloseArea() 
	 	dbSelectArea("CY8")
		RecLock("CY8",.T.)
			CY8->CY8_FILIAL := xFilial('CY8')
	    	CY8->CY8_IDMEPO := cIdMePo
	   		CY8->CY8_CDIN   := cCdIn 
	   		CY8->CY8_DSMI   := cCor1     
	   		CY8->CY8_DSSIMI := cEmail1  
	   		CY8->CY8_DSMSMI := cDescri1 
	   		CY8->CY8_DSXA   := cCor2    
	   		CY8->CY8_DSSIXA := cEmail2  
	   		CY8->CY8_DSMSXA := cDescri2  
	   		CY8->CY8_DSMX   := cCor3     
	   		CY8->CY8_DSSIMX := cEmail3  
	   		CY8->CY8_DSMSMX := cDescri3 
	   		CY8->CY8_VLPNMI := nValor1   
	   		CY8->CY8_VLPNMX := nValor2
	   		CY8->CY8_DTVDBG := DATE()
	   		CY8->CY8_DTVDED := CTOD("31/12/9999")                  
	   	MsUnlock()
	EndIf
	If( Len(aFieldsEsq) > 0 )
		AADD(aFieldsDir, aFieldsEsq[oBrwEsq:nAt])
		ADEL(aFieldsEsq, oBrwEsq:nAt)
		ASIZE(aFieldsEsq, Len(aFieldsEsq)-1)
	EndIf                                  
     
	oBrwDir:Refresh()

Return .T.
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCXALL
Mover todos os itens de array pelos browsers

@author Ana Carolina Tome Klock
@since 16/12/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCXALL(oBrwEsq, oBrwDir, aFieldsEsq, aFieldsDir, lRemove, lInsere, cIdMePo) 

	While( Len(aFieldsEsq) > 0 ) 
		If( Len(aFieldsEsq) > 0 )  
			If lRemove = .T.     
				dbSelectArea("CY8")             
				If !Empty(Posicione("CY8",1,XFILIAL("CY8")+cValToChar(cIdMePo)+aFieldsEsq[1][1], "CY8_CDIN"))   	
					DBRLock(Recno()) 
					DBDelete()  
   				EndIf   
			ElseIf lInsere = .T.  
				dbSelectArea("CYJ")
				dbSeek(xFilial("CYJ")+aFieldsEsq[1][1]) 
					cCdIn    := CYJ->CYJ_CDIN
	   				cCor1    := CYJ->CYJ_DSMI 
	   				cEmail1  := CYJ->CYJ_DSSIMI
	   				cDescri1 := CYJ->CYJ_DSMSMI	
	   				cCor2    := CYJ->CYJ_DSXA   
	   				cEmail2  := CYJ->CYJ_DSSIXA
	   				cDescri2 := CYJ->CYJ_DSMSXA
	   				cCor3    := CYJ->CYJ_DSMX
	   				cEmail3  := CYJ->CYJ_DSSIMX
	   				cDescri3 := CYJ->CYJ_DSMSMX 
	   				nValor1  := CYJ->CYJ_VLEDMI
	   				nValor2  := CYJ->CYJ_VLEDXA
	 			dbCloseArea() 
	 			dbSelectArea("CY8")
				RecLock("CY8",.T.)
					CY8->CY8_FILIAL := xFilial('CY8')
	    			CY8->CY8_IDMEPO := cValToChar(cIdMePo)
	   				CY8->CY8_CDIN   := cCdIn 
	   				CY8->CY8_DSMI   := cCor1     
	   				CY8->CY8_DSSIMI := cEmail1  
	   				CY8->CY8_DSMSMI := cDescri1 
	   				CY8->CY8_DSXA   := cCor2    
	   				CY8->CY8_DSSIXA := cEmail2  
	   				CY8->CY8_DSMSXA := cDescri2  
	   				CY8->CY8_DSMX   := cCor3     
	   				CY8->CY8_DSSIMX := cEmail3  
	   				CY8->CY8_DSMSMX := cDescri3 
	   				CY8->CY8_VLPNMI := nValor1   
	   				CY8->CY8_VLPNMX := nValor2
	   				CY8->CY8_DTVDBG := DATE()
	   				CY8->CY8_DTVDED := CTOD("31/12/9999")                  
	   			MsUnlock()
			EndIf       
			AADD(aFieldsDir, aFieldsEsq[1])
			ADEL(aFieldsEsq, 1)
			ASIZE(aFieldsEsq, Len(aFieldsEsq)-1)
		EndIf
	End     

Return .T. 
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCXMOVEUP
Mover item selecionado para cima

@author Tiago Gauziski
@since 16/12/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCXMOVEUP(oBrw, aFields)
	
	Local xTemp 

	If(oBrw:nAt > 1)
		xTemp := aFields[oBrw:nAt]
		aFields[oBrw:nAt] := aFields[oBrw:nAt - 1]
		aFields[oBrw:nAt - 1] := xTemp
		oBrw:nAt := oBrw:nAt - 1
	EndIf
               
Return .T.    
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCXMOVEDO
Mover item selecionado para baixo

@author Tiago Gauziski
@since 16/12/10
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCXMOVEDO(oBrw, aFields) 

	If(oBrw:nAt < Len(aFields))
		xTemp := aFields[oBrw:nAt]
		aFields[oBrw:nAt] := aFields[oBrw:nAt + 1]
		aFields[oBrw:nAt + 1] := xTemp
		oBrw:nAt := oBrw:nAt + 1
	EndIf

Return .T. 
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCXVALHRCENTESIMAL
Valida a hora centesimal.
Hora centesimal deve possuir o valor máximo de 24.

@param    nHora       (Obrigatorio) Hora Centesimal

@author Samantha Preima
@since 03/03/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCXVALHRCENTESIMAL (nHora)
Local lRet := .T.

if nHora > 24 
	lRet := .F.
Endif

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCXHRTOCEN
Calcular a hora centesimal, com base no relógio horário

@param    cHora       (Obrigatorio) Hora no formato character hh:mm:ss

@author Samantha Preima
@since 03/03/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCXHRTOCEN(cHora)
Local nSegundos   := if(Empty(cHora),0,SFCXHourToSeg(cHora))
Local nCentesimal := ROUND(nSegundos / 3600,4)

Return nCentesimal

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCXCENTOHR
Calcular o relógio horário com base na hora centesimal

@param    cCentesimal       (Obrigatorio) Hora no formato numérico 99.9999

@author Samantha Preima
@since 03/03/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCXCENTOHR(nCentesimal)
Local nSegundos := int(nCentesimal * 3600)
Local cHora     := SFCXSegtoHour(nSegundos)

Return cHora 

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFXCOMPMSG
Função que cria uma tela aonde se pode ser incluidos ou alterados as mensagens de cada faixa

@author Ana Carolina Tome Klock
@since 09/05/11
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFXCOMPMSG( nOption )
	Local oFont12c   := TFont():New('Arial',,-12,,.T.)
	Local cTitle1    
	Local cMensagem1 
	Local cTitle2   
	Local cMensagem2 
	Local cTitle3   
	Local cMensagem3 
	Local aFieldsSel := SFXARRACZ4()
	Default lAutoMacao := .F.
	 
	If nOption == 1
		cTitle1    := FwFldGet("CYJ_DSSIMI") 
		cMensagem1 := FwFldGet('CYJ_DSMSMI')
		cTitle2    := FwFldGet("CYJ_DSSIXA") 
		cMensagem2 := FwFldGet('CYJ_DSMSXA')
		cTitle3    := FwFldGet("CYJ_DSSIMX") 
		cMensagem3 := FwFldGet('CYJ_DSMSMX')
	Else
		cTitle1    := cTitulo1 
		cMensagem1 := cDescri1
		cTitle2    := cTitulo2
		cMensagem2 := cDescri2
		cTitle3    := cTitulo3
		cMensagem3 := cDescri3
	EndIf
	
	IF !lAutoMacao
		Define MsDialog	oDlgMessage Title STR0005 FROM 00,00 To 470,785 Pixel // 'Compor Mensagem'
		
			// Folder
			aTFolder   := { STR0006, STR0007, STR0008 } // 'Faixa 1' ### 'Faixa 2' ### 'Faixa 3'
			oTFolder   := TFolder():New( 02, 0, aTFolder, { STR0006, STR0007, STR0008 }, oDlgMessage, , RGB(225,225,225), , .T., , 400, 250 ) // 'Faixa 1' ### 'Faixa 2' ### 'Faixa 3'
			
			// Faixa 1
			TSay():New( 010, 015, { || STR0009   	}, oTFolder:aDialogs[1], , , , , , .T., CLR_BLACK, CLR_WHITE ) // 'Título Mensagem 1'
			TGet():New( 018, 015, { |u| If( Pcount()>0, cTitle1 := u, cTitle1 ) }, oTFolder:aDialogs[1], 150, 7, , {||}, , , , , , .T., , ,{||} , , ,{||}, .F., , , cTitle1 )
			TSay():New( 032, 015, { || STR0010  	}, oTFolder:aDialogs[1], , , , , , .T., CLR_BLACK, CLR_WHITE ) // 'Descrição Mensagem 1'	
			oText1 := TSimpleEditor():New( 040, 015, oTFolder:aDialogs[1], 200, 150, cMensagem1, .F., , , .T. )                     
			
			oBrwCampos := TWBrowse():New( 40, 230, 155, 175, , { STR0015 }, {30}, oDlgMessage,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) // 'Campos Disponíveis'
			oBrwCampos:SetArray(aFieldsSel)
			oBrwCampos:bLine := { || { If(Len(aFieldsSel) > 0,aFieldsSel[oBrwCampos:nAt,1], ) } }  
		
			TButton():New( 018,  217,  '<', oTFolder:aDialogs[1], {|| cTitle1   := AllTrim(cTitle1)   + " " + aFieldsSel[oBrwCampos:nAt][2] }, 10,10,,,,.T.)
			TButton():New( 040,  217,  '<', oTFolder:aDialogs[1], {|| oText1:Load( AllTrim( oText1:RetText() ) + " " + aFieldsSel[oBrwCampos:nAt][2]) }, 10,10,,,,.T.)
			
			// Faixa 2
			TSay():New( 010, 015, { || STR0011   	}, oTFolder:aDialogs[2], , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Título Mensagem 2"
			TGet():New( 018, 015, { |u| If( Pcount()>0, cTitle2 := u, cTitle2 ) }, oTFolder:aDialogs[2], 150, 7, , {||}, , , , , , .T., , ,{||} , , , {||} , .F., , , cTitle2 )
			TSay():New( 032, 015, { || STR0012  	}, oTFolder:aDialogs[2], , , , , , .T., CLR_BLACK, CLR_WHITE ) // "Descrição Mensagem 2"
			oText2 := TSimpleEditor():New( 040, 015, oTFolder:aDialogs[2], 200, 150, cMensagem2, .F., , , .T. )                               
			oText2:Load(cMensagem2)
		
			TButton():New( 018,  217,  '<', oTFolder:aDialogs[2], {|| cTitle2   := AllTrim(cTitle2)   + " " + aFieldsSel[oBrwCampos:nAt][2] }, 10,10,,,,.T.)
			TButton():New( 040,  217,  '<', oTFolder:aDialogs[2], {|| oText2:Load( AllTrim( oText2:RetText() ) + " " + aFieldsSel[oBrwCampos:nAt][2]) }, 10,10,,,,.T.)		
						
			// Faixa 3
			TSay():New( 010, 015, { || STR0013   	}, oTFolder:aDialogs[3], , , , , , .T., CLR_BLACK, CLR_WHITE )  //  "Título Mensagem 3"
			TGet():New( 018, 015, { |u| If( Pcount()>0, cTitle3 := u, cTitle3 ) }, oTFolder:aDialogs[3], 150, 7, , {||}, , , , , , .T., , ,{||} , , , {||}, .F., , , cTitle3 )
			TSay():New( 032, 015, { || STR0014  	}, oTFolder:aDialogs[3], , , , , , .T., CLR_BLACK, CLR_WHITE ) 	// "Descrição Mensagem 3"
			oText3 := TSimpleEditor():New( 040, 015, oTFolder:aDialogs[3], 200, 150, cMensagem3, .F., , , .T. )                       
			oText3:Load(cMensagem3)
		
			TButton():New( 018,  217,  '<', oTFolder:aDialogs[3], {|| cTitle3   := AllTrim(cTitle3)   + " " + aFieldsSel[oBrwCampos:nAt][2] }, 10,10,,,,.T.)
			TButton():New( 040,  217,  '<', oTFolder:aDialogs[3], {|| oText3:Load( AllTrim( oText3:RetText() ) + " " + aFieldsSel[oBrwCampos:nAt][2]) }, 10,10,,,,.T.) 
																						
		Activate MsDialog oDlgMessage Centered On Init EnchoiceBar( oDlgMessage, { || If (SFXRECDATA(cTitle1, oText1:RetText(), cTitle2, oText2:RetText(), cTitle3, oText3:RetText(), nOption), oDlgMessage:End(), NIL) }, { || oDlgMessage:End() } )
    ENDIF

Return Nil 

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFXRECDATA
Função que salva as mensagens criadas

@author Ana Carolina Tome Klock
@since 09/05/11
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFXRECDATA( cTitle1, cMensagem1, cTitle2, cMensagem2, cTitle3, cMensagem3, nOption )
    
    If nOption == 1
  		FwFldPut('CYJ_DSSIMI', AllTrim(cTitle1) )                                               
		FwFldPut('CYJ_DSMSMI', AllTrim(cMensagem1) )
		FwFldPut('CYJ_DSSIXA', AllTrim(cTitle2) ) 
		FwFldPut('CYJ_DSMSXA', AllTrim(cMensagem2) )
		FwFldPut('CYJ_DSSIMX', AllTrim(cTitle3) ) 
		FwFldPut('CYJ_DSMSMX', AllTrim(cMensagem3) )
    Else
    	cTitulo1 := AllTrim(cTitle1)
       	cDescri1 := AllTrim(cMensagem1)
    	cTitulo2 := AllTrim(cTitle2)
    	cDescri2 := AllTrim(cMensagem2)
    	cTitulo3 := AllTrim(cTitle3)
    	cDescri3 := AllTrim(cMensagem3)
    EndIf
    
Return .T.
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFXARRACZ4
Função que cria um array com os campos da tabela CZ4

@author Ana Carolina Tome Klock
@since 09/05/11
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFXARRACZ4()
	Local aArray := { }
	Local cCampo
	Local StructCZ4 := CZ4->(dbStruct())
	Local nCount
	
	For nCount := 1 to Len(StructCZ4)
	
		cCampo := StructCZ4[nCount,1]
		
		If SubStr( ALLTRIM(cCampo) ,5) != "FILIAL"
			aAdd( aArray, { ALLTRIM(GetSx3Cache(cCampo,'X3_DESCRIC')), "[" + SubStr( ALLTRIM(cCampo) ,5) + "]", StructCZ4[nCount,2] } )                              
		EndIf 
	
	Next nCount
    
Return aArray

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCCriFWTa
Criar a tabela temporária com base na estrutura informada

@param  aArrStr          (Obrigatório) Array contendo a definição da tabela
	[1] Estrutura da tabela a ser criada (array)
	[2] Indices da tabela a ser criada (string)
	
	É preciso definir a variável oTabela no programa chamador, para poder finalizar o objeto


@author Samantha Preima
@since 18/08/2016
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCCriFWTa(aArrStr)
	Local cAliasTab := GetNextAlias()
	
	oTabela := FWTemporaryTable():New( cAliasTab )		
	oTabela:SetFields( aArrStr[1] )
	oTabela:AddIndex("1", aArrStr[2] )
	oTabela:Create()
	
Return oTabela


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCDelTab
Elimina a tabela temporária e os respectivos índices

@param  cAliasTab          Alias da tabela a eliminar


@author Israel A Possoli
@since 21/03/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCDelTab(cAliasTab)
	Local cFileTab
	Local nQtdInd
	Local aFileInd := {} // Armazena os nomes completos dos arquivos de indice
	Local nI
	Local cTreePath
	Local aDelFiles

	// Valores do parâmetro de dbOrderInfo
	// 7  - Retorna o nome do arquivo de índice
	// 9  - Retorna a quantidade de índices do alias corrente
	// 20 - Retorna o nome completo (caminho e extensão) do arquivo de índices

	If cAliasTab != "" .And. Select(cAliasTab) > 0
		dbSelectArea(cAliasTab)
		cFileTab := dbInfo(DBI_FULLPATH)

		If Empty(cFileTab)
			Return .T.
		EndIf

		nQtdInd  := dbOrderInfo(9 /* DBOI_ORDERCOUNT */)

		// Em ambientes com LocalFiles=CTREE, dbOrderInfo(9) considera um índice a mais nas tabelas,
		// correspondente à ordem de inserção na tabela. Quando LocalFiles=ADS, este índice não é contado.
		// LocalFiles é uma opção do arquivo AppServer.ini, informada na sessão correspondente ao ambiente
		// que se quer utilizar.
		If ("CTREE"$RealRDD())
			nQtdInd--
		EndIf

		For nI := 1 to nQtdInd
			dbSetOrder(nI)
			aAdd(aFileInd, dbOrderInfo(20 /* DBOI_FULLPATH */))
		Next nI

		// Fecha e elimina o arquivo correspondente à tabela temporária
		USE

		cTreePath := GetSrvProfString("RootPath", "")

		If At(Lower(cTreePath), Lower(cFileTab)) > 0
			cTreePath := Substr(cFileTab, Len(cTreePath) + 1)
		EndIf

		FErase(cTreePath)

		If "CTREE" $ RealRDD()
			cTreePath := GetSrvProfString("StartPath", "") + "CTREEINT\"
			aDelFiles := Directory(cTreePath + FileNoExt(ATail(StrTokArr(cFileTab,"\"))) + "*.*")
			For nI := 1 To Len(aDelFiles)
				FErase(cTreePath + aDelFiles[nI][1])
			Next nI
		EndIf

		// Elimina os arquivos de índice da tabela temporária
		For nI := 1 to nQtdInd
			If "CTREE" $ RealRDD()
				cTreePath := GetSrvProfString("RootPath", "")

				If At(Lower(cTreePath), Lower(aFileInd[nI])) > 0
					cTreePath := Substr(aFileInd[nI], Len(cTreePath) + 1)
				EndIf

				FErase(cTreePath)
			Else
				FErase(aFileInd[nI])
			EndIf
		Next nI
	EndIf

Return .T.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCXAgrupaTab
Agrupa registros de uma temp-table com base em campos iguais e soma os valores de campos

@param  cTabFrom        (Obrigatório) Alias da tabela
@param	aCondAgr		(Obrigatório) Array com os campos da condição do agrupamento
@param	aCamposAgr		(Obrigatório) Array com os campos que serão agrupados (somados)


@author Israel A Possoli
@since 04/04/2011     
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCXAgrupaTab(cTabFrom, aCondAgr, aCamposAgr)
	Local oStruct								// Estrutura da tabela
	Local nCount
	Local cCondAgr     := ""   					// Condição do agrupamento
	Local nRecNo								// Guarda o RecNo do Loop Principal
	Local nRecNoTo                              // RecNo do Loop Secundário
	Local aDelete	   := {}					// RecNo dos registros que  
	Local lAtualiza
	
	cTabFromMS  := cTabFrom						// Usado na Macro Substituição
	aValCondAgr  := Array(Len(aCondAgr))		// Valores dos campos da condição de agrupamento (aCondAgr)
	aValoresAgru := Array(Len(aCamposAgr))		// Valores dos campos de agrupamento (aCamposAgr)
	
	// Obtem a estrutura da tabela
	dbSelectArea(cTabFrom)
	oStruct := DBStruct()
	
	// Cria a condição de agrupamento do registro atual com os valores salvos no array (aValCondAgr) do registro atual
	For nCount := 1 To Len(aCondAgr)
		If !Empty(cCondAgr)
			cCondAgr += " .AND. "
		EndIf
		cCondAgr += "(cTabFromMS)->(" + aCondAgr[nCount] + ") == aValCondAgr[" + cValToChar(nCount) + "]"
	Next nCount
	
	
	// Verifica em cada registro se há outros que coincidam com a condição de agrupamento (cCondAgr),
	// Se a condição for verdadeira, soma os valores dos campos aCamposAgr e elimina o registro que está sendo comparado
	dbGoTop()
	While( (cTabFrom)->(!EOF()) )
		nRecNo := (cTabFrom)->(RecNo())
		// Salva os valores dos campos da condição de agrupamento
		For nCount := 1 To Len(aCondAgr)
			aValCondAgr[nCount] := &("(cTabFromMS)->(" + aCondAgr[nCount] + ")")
		Next nCount
		
		// Guarda os valores dos campos de agrupamentos
		For nCount := 1 To Len(aCamposAgr)
			aValoresAgru[nCount] := &("(cTabFromMS)->(" + aCamposAgr[nCount] + ")")
		Next nCount
		
		// Pesquisa se existe um registro com as condições de agrupamento
		// Se existir, soma os valores e marca o registro para ser eliminado (somente quando não for cópia)
		lAtualiza := .F.
		dbSkip()
		While( (cTabFrom)->(!EOF()) )
			nRecNoTo := (cTabFrom)->(RecNo())
			
			If &(cCondAgr) .AND. nRecNoTo != nRecNo
				aADD(aDelete, nRecNoTo)
				lAtualiza := .T.
				For nCount := 1 To Len(aCamposAgr)
					aValoresAgru[nCount] += &("(cTabFromMS)->(" + aCamposAgr[nCount] + ")")
				Next nCount
				
			EndIf
			
			dbSelectArea(cTabFrom)
			dbGoTo(nRecNoTo)
			dbSkip()
		EndDo
		
		// Salva os campos que foram somados
		dbSelectArea(cTabFrom)
		dbGoTo(nRecNo)
		If lAtualiza
			For nCount := 1 To Len(aCamposAgr)
				&("(cTabFromMS)->(" + aCamposAgr[nCount] + ") := aValoresAgru[" + cValToChar(nCount) + "]")
			Next nCount		
		EndIf
		
		dbSkip()
	EndDo
	
	// Elimina os registros que foram agrupados
	For nCount := 1 To Len(aDelete)
		dbSelectArea(cTabFrom)
		dbGoTo(aDelete[nCount])
		dbDelete()
	Next nCount
Return   
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCXAUXCRI
Cria a estrutura do Browse baseando-se numa Temp Table

@param  oOwner           (Obrigatório) Objeto pai do browse sendo criado
@param  oAlias           (Obrigatório) Alias da Tabela Temporária
@param  cName            (Obrigatório) Nome do Alias da Tabela Temporária
@param  aStruct          (Obrigatório) Estrutura da Tabela Temporária 
@param  lActivate        Define se o Browse será ativado     
@param  lShow			 Define se exibe todos os campos
@param  lDisable 		 Define se desativa as opcoes extras do Browse

@author Ana Carolina Tome Klock
@since 31/03/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function SFCXAUXCRI( oOwner, oAlias, cName, aStruct, lActivate, lShow, lDisable )
	Default lActivate := .T.    
	Default lShow     := .T.  
	Default lDisable  := .T.   

	oBrowse := FWBrowse():New( oOwner )
	oBrowse:SetDataTable( .T. )
	oBrowse:SetAlias( oAlias )
	If ( lDisable == .T. )
		oBrowse:DisableConfig()
		oBrowse:DisableReport() 
	EndIf
	oBrowse:SetColumns( SFCXADDCOL( cName, aStruct, lShow ) )
	If ( lActivate == .T. )
		oBrowse:Activate()   
	EndIf  
		
Return oBrowse

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCXADDCOL
Adiciona as colunas ao Browse 

@param  cName            (Obrigatório) Nome da Temp Table
@param  cTab             (Obrigatório) Temp Table que preencherá o Browse
@param  lShow			 Informa se existem campos que não serão exibidos

@author Ana Carolina Tome Klock
@since 29/03/2011
@version 1.0
/*/
//------------------------------------------------------------------------------------------------
Function SFCXADDCOL( cName, cTab, lShow )
	Local aColumn := {}
	Local aFields := cTab[1]
	Local nCount 
	Default lShow := .T.  
	
	For nCount := 1 To Len(aFields) 
		If (lShow = .T.) .Or. (aFields[nCount,6] = .T. .And. lShow = .F.)
	   		oColumn := FWBrwColumn():New()
			oColumn:SetData( &( '{ || ( ' + cName + ' )->' + aFields[nCount,1]+ ' }' ) ) 
			oColumn:SetTitle( aFields[nCount,5] ) 
			oColumn:SetSize( aFields[nCount,3] )
			oColumn:SetDecimal( aFields[nCount,4] )
			oColumn:SetPicture( aFields[nCount,7] )
			aAdd(aColumn, oColumn)  
		EndIf
	Next nCount  
	
Return aColumn 
//--------------------------------------------------------------------------------------------------------------------
/* {Protheus.doc} SFCXUNIDME
Retorna o valor das unidades de medida de cada um dos indicadores
                                                                 
@param   cValor		(Obrigatório) Informa o tipo de retorno desejado (CYJ_TPIN)

@author Ana Carolina Tomé Klock
@since 02/05/2011
@version P11
*/                                                                                                                     
//--------------------------------------------------------------------------------------------------------------------
Function SFCXUNIDME( cValor )
	Local cCDUN := Posicione("CYJ",2,xFilial("CYJ")+cValor, "CYJ_CDUN")   

	cCDUN := Stuff( AllTrim(CYJ->CYJ_CDUN), 1, 1, Upper(SubStr(CYJ->CYJ_CDUN, 1, 1)) )
		
Return cCDUN
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCXFAIXA
Retorna valores das Faixas

@param		cCDIN		Nome do Indicador Pai (valor do CYJ_CDIN)
@return 	aFaixa		Retorna o valor das faixas

@author Israel A Possoli
@since 04/03/2011
@version P11
*/                                                     	
//--------------------------------------------------------------------------------------------------------------------
Function SFCXFAIXA( cCDIN )
Local aFaixa  := { .F., '', '', '', '', '', '', '', '', '', '' }  

If !Empty( cCDIN )
	dbSelectArea("CYJ")
	CYJ->( dbSetOrder(1) )
	If CYJ->( dbSeek( xFilial("CYJ")+cCDIN ) ) 
		aFaixa[01] := .T.							// Define se encontrou o indicador
		aFaixa[02] := CYJ->CYJ_CDIN					// Nome do indicador
		aFaixa[03] := CYJ->CYJ_TPIN					// Tipo do indicador
		aFaixa[04] := "0"							// Faixa 1 - Inicial
		aFaixa[05] := cValToChar(CYJ->CYJ_VLEDMI)	// Faixa 2 - Inicial
		aFaixa[06] := cValToChar(CYJ->CYJ_VLEDXA)	// Faixa 3 - Inicial
		aFaixa[07] := "100"					   		// Faixa 3 - Final
		aFaixa[08] := ALLTRIM(CYJ->CYJ_CDUN)		// Unidade de Medida
		aFaixa[09] := ALLTRIM(CYJ->CYJ_DSMI)		// Descrição Faixa 1
		aFaixa[10] := ALLTRIM(CYJ->CYJ_DSXA)		// Descrição Faixa 2
		aFaixa[11] := ALLTRIM(CYJ->CYJ_DSMX)		// Descrição Faixa 3
	EndIf
EndIf

Return aFaixa

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCXFAIXAMAQ
Retorna valores das Faixas

@param		cIDMEPO		ID da Meta de Produção  
@param		cCDIN		Código do Indicador
@return 	aFaixa		Retorna o valor das faixas

@author Israel A Possoli
@since 04/03/2011
@version P11
*/                                                     	
//--------------------------------------------------------------------------------------------------------------------
Function SFCXFAIXAMAQ( cIDMEPO, cCDIN )
Local aFaixa  := { .F., '', '', '', '', '', '', '', '', '', '' }  
Local cQuery, cTable

dbSelectArea("CY8")
cQuery := "SELECT * FROM " + RetSQLName("CY8") + " CY8 "
cQuery += "   INNER JOIN " + RetSQLName("CYJ") + " CYJ ON  "
cQuery += "	        CY8.CY8_FILIAL 	= CYJ.CYJ_FILIAL    AND "
cQuery += "			CY8.CY8_CDIN 	= CYJ.CYJ_CDIN 		AND "
cQuery += "			CYJ.D_E_L_E_T_  = ' ' 				WHERE "
cQuery += " 		CY8.CY8_IDMEPO  = '" + cIDMEPO      + "' AND "
cQuery += "    	   (CY8.CY8_DTVDBG <= '" + DTOS(Date()) + "' AND "
cQuery += "	  	    CY8.CY8_DTVDED >= '" + DTOS(Date()) + "') AND " 
cQuery += "	    	CYJ.CYJ_CDIN    = '" + cCDIN 		+ "' AND "          
cQuery += "		    CY8.D_E_L_E_T_  = ' '"                           
cTable := GetNextAlias()
dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTable, .T., .F. )   
	  
While ((cTable)->(!EOF()))
	aFaixa[01] := .T.								// Define se encontrou o indicador
	aFaixa[02] := (cTable)->CYJ_CDIN				// Nome do indicador
	aFaixa[03] := (cTable)->CYJ_TPIN				// Tipo do indicador
	aFaixa[04] := "0"								// Faixa 1 - Inicial
	aFaixa[05] := cValToChar((cTable)->CY8_VLPNMI)	// Faixa 2 - Inicial
	aFaixa[06] := cValToChar((cTable)->CY8_VLPNMX)	// Faixa 3 - Inicial
	aFaixa[07] := "100"					   			// Faixa 3 - Final
	aFaixa[08] := ALLTRIM((cTable)->CYJ_CDUN)		// Unidade de Medida
	aFaixa[09] := ALLTRIM((cTable)->CY8_DSMI)		// Descrição Faixa 1
	aFaixa[10] := ALLTRIM((cTable)->CY8_DSXA)		// Descrição Faixa 2
	aFaixa[11] := ALLTRIM((cTable)->CY8_DSMX)		// Descrição Faixa 3
	(cTable)->(dbSkip())
End        

If !aFaixa[1]
	dbSelectArea( 'CYJ' )
	CYJ->( dbSetOrder(1) )
	If CYJ->( dbSeek( xFilial('CYJ')+cCDIN ) )
		aFaixa[2] := CYJ->CYJ_CDIN
		aFaixa[3] := CYJ->CYJ_TPIN
	EndIf
EndIf

Return aFaixa

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IndToCod
Retorna o código do indicador de acordo com a descrição

@param	cIndicador		Descrição do indicador

@return TPIN 			Tipo do Indicador de acordo com o campo CYJ_TPIN

@author Israel A Possoli
@since 04/03/2011
@version P11
/*/                                                     	
//--------------------------------------------------------------------------------------------------------------------
Function IndToCod(cIndicador)
	
	Do Case
		Case cIndicador == STR0017  // 'Q'
			Return("01")
		Case cIndicador == STR0018  // 'Q_Real'
			Return("02")
		Case cIndicador == STR0019  // 'E'
			Return("03")
		Case cIndicador == STR0020  // 'U'
			Return("04")
		Case cIndicador == STR0021  // 'D_Real'
			Return("05")
		Case cIndicador == STR0022  // 'D_Planejada'
			Return("06")
		Case cIndicador == STR0023  // 'NEE'
			Return("07")
		Case cIndicador == STR0024  // 'OEE'
			Return("08")
		Case cIndicador == STR0025  // 'TEEP'
			Return("09")
		Case cIndicador == STR0027  // 'BTS_V'
			Return("10")
		Case cIndicador == STR0028  // 'BTS_M'
			Return("11")
		Case cIndicador == STR0029  // 'BTS_S'
			Return("12")
		Case cIndicador == STR0026  // 'BTS'
			Return("13")
		Case cIndicador == STR0030  // 'Tk'
			Return("14")
	EndCase

Return ("15")
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SFCXCODMETA
Busca o ID da meta pelo código da meta e máquina

@param	cCODMETA		Código da Meta
@param	cMAQ			Código da Máquina

@return IDMEPO da meta

@author Israel A Possoli
@since 04/03/2011
@version P11
/*/                                                     	
//--------------------------------------------------------------------------------------------------------------------
Function SFCXCODMETA(cCODMETA, cMAQ)
	Local lRet		:= 0
	Local aArea    	:= GetArea()
	Local aAreaCY5 	:= CY5->(GetArea())
	
	dbSelectArea("CY5")
	dbSetOrder(1)
	If dbSeek(xFilial("CY5")+cCODMETA+cMAQ) // CY5_FILIAL+CY5_CDMEPO+CY5_CDMQ
		lRet := CY5->CY5_IDMEPO
	EndIf
	
	RestArea(aArea)
	RestArea(aAreaCY5)
Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCEnvMail
Função para envio de e-mail.

@param cPara        Lista dos destinatários da mensagem
@param cAssunto		Assunto do email
@param cMensagem 	Corpo do email 
@param lMsg         Indica se mostra mensagem de erro 

@author Samantha Preima
@since 18/05/2011
@version 1.0
/*/
//------------------------------------------------------------------- 
Function SFCEnvMail(cPara, cAssunto, cMsg, lMsg)
Local lResulConn := .T.
Local lResulSend := .T.
Local lRet       := .T.
Local cError     := ""         

Local cFrom    	:= GetMV("MV_RELACNT")  // Conta do Remetente - o cliente receberá o email com este rementente - naoresponda@sfc.com.br 
Local cServer   := GetMV("MV_RELSERV")  // Servidor SMTP - artemis.jv01.local
Local cPass     := GetMV("MV_RELPSW" )  // Password do servidor - em branco
Local lAuth     := GetMV("MV_RELAUTH")  // Servidor de EMAIL necessita de Autenticacao? - .F.
Local cContAuth := GetMV("MV_RELACNT")  // Conta do Remetente - se fizer autenticação, ele precisa de uma variável a mais para o remetente para alterar.
Local cPswAuth  := GetMV("MV_RELAPSW")  // Senha para autenticacäo no servidor de e-mail - em branco

Default lMsg := .F.

if Empty(cPara)
	Return .F.
EndIf  

If lMsg
	If !lResulConn
		Get MAIL ERROR cError
		MsgStop(STR0031 + AllTrim(cError) + STR0032, STR0033 )   // "Falha na conexão com servidor ( " ### " )" ### "E-mail"
		Return  .F.
	EndIf
Endif                

If lAuth
      //
      // Primeiro tenta fazer a Autenticacao de E-mail utilizando o e-mail completo
      //
      If ! ( lRet := MailAuth( cContAuth, cPswAuth ) )
            //
            // Se nao conseguiu fazer a Autenticacao usando o E-mail completo, tenta fazer
            // a autenticacao usando apenas o nome de usuario do E-mail, sem o @...
            //
            If !lRet
                  nA        := At( '@', cContAuth )
                  cContAuth := If( nA > 0, SubStr( cContAuth, 1, nA - 1), cContAuth )

                  If !( lRet  := MailAuth( cContAuth, cPswAuth ) )
                        MsgAlert( STR0034 + cContAuth + STR0032, STR0035 )  // "Não conseguiu autenticar conta (" ### " )" ###  "Autenticação"
                        //DISCONNECT SMTP SERVER
                        Return  .F.
                  EndIf

            EndIf
      EndIf
EndIf

// Realiza o envio do e-mail
SEND MAIL FROM cFrom TO cPara SUBJECT cAssunto BODY cMsg RESULT lResulSend

If lMsg
	If !lResulSEND
		Get MAIL ERROR cError
		MsgStop( STR0036 + AllTrim( cError ) + STR0032, STR0033 ) // "Falha no Envio do e-mail ( " ### " )" ### "E-mail"		                                                                                                 
		lRet := .F.
	Else
		MsgInfo( STR0037, STR0033 ) // "E-mail enviado com sucesso" ### "E-mail"                                                                                
		
		lRet := .F.
	EndIf  
endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXTraduc
Realiza a tradução de um texto, trocando os código pelos valores 
correspondentes.

@param cMensagem 	Mensagem a ser traduzida
@param aCampos  	Array com os códigos e suas traduções

@return cMensagem	Mensagem traduzida

@author Samantha Preima
@since 20/05/2011
@version 1.0
/*/
//------------------------------------------------------------------- 
Function SFCXTraduc(cMensagem, aCampos)
Local nI 	 := 0
Local cValor := ''

For nI := 1 to Len(aCampos)
	Do Case
		Case aCampos[nI][3] == 'N'
			cValor := STR(aCampos[nI][4])
		Case aCampos[nI][3] == 'D'
			cValor := DTOC(aCampos[nI][4])
		Case aCampos[nI][3] == 'L'
			cValor := IF(aCampos[nI][4]==.T.,STR0038, STR0039) //'Sim' ### 'Não'
		Case aCampos[nI][3] == 'C'
			cValor := aCampos[nI][4]
	End Case

	cMensagem := STRTRAN(cMensagem,aCampos[nI][2],ALLTRIM(cValor))
Next

Return cMensagem
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXGeraArquivo
Abre um arquivo conforme solicitado para exibir informações
	
@param aMensagem  	Mensagens a serem exibidas

@author Ana Carolina Tomé Klock
@since 23/05/2011
@version 1.0
/*/
//------------------------------------------------------------------- 
Function SFCXGeraArquivo( aMensagem )        
	Local cData    := DTOS(date())
	Local cHora    := Stuff(Stuff( time(), 3, 1, ""), 5, 1, "") 
	Local nArquivo := FCreate("\AvisoSFC"+cData+cHora+".txt")
    Local nI
	Local lFalha   := .F.
    
   If FError() # 0
	    lFalha := .T.
  	Else
	    For nI := 1 to Len(aMensagem)
	   		FWrite(nArquivo, aMensagem[nI] + chr(13) + chr(10))
		  	If FError() # 0
	  			lFalha := .T.
	  			Exit
		  	EndIf
		Next
	Endif
	FClose( nArquivo )         
	
	If lFalha .And. MsgRetryCal(STR0040) // "Erro ao gerar arquivo. Deseja tentar novamente?"
		SFCXGeraArquivo( aMensagem )
	ElseIf !lFalha 
	    MsgInfo( STR0041 + "AvisoSFC"+cData+cHora+".txt" )
	EndIf
	
Return Nil    
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXDiaSem( )
Retorna o dia da semana solicitado
	
@param dData  	Mensagens a serem exibidas
@param nDia     Dia desejado ( 1=Domingo, 2=Segunda, ...)

@author Ana Carolina Tomé Klock
@since 09/06/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCXDiaSem( dData, nDia )

	nDia  := Dow(dData) - nDia   
	dData := dData - nDia

Return dData 
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXIndSon( )
Retorna os Indicadores Filhos para o Gráfico
	
@param cPai  	 Nome do Indicador Pai  
@param oFWChart  Objeto gráfico onde serão inseridos
@param nValores  Valores dos indicadores filhos 

@author Ana Carolina Tomé Klock
@since 14/06/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCXIndSon( cPai, oFWChart, nValores )
	Local cInd := AllTrim(cPai)
	Local nInd
	                                                   
	oFWChart:setPicture( "@E 999.99" )
	
	dbSelectArea("CY3")
	dbSeek( xFilial("CY3")+cInd )
	While  CY3->(!EOF())
		If CY3->CY3_FILIAL == xFilial('CY3') .And. AllTrim(CY3->CY3_CDIN) == cInd 
   			cTitulo := AllTrim( GetAdvfVal( "CYJ", "CYJ_CDIN", XFILIAL("CYJ")+CY3->CY3_CDINSO, 1 ) )
   			nInd    := Val( GetAdvfVal( "CYJ", "CYJ_TPIN", XFILIAL("CYJ")+CY3->CY3_CDINSO, 1 ) )  
   		    nValor  := nValores[nInd]    
   		  	oFWChart:addSerie( cTitulo, NoRound(nValor,2) )  
   		EndIf	 
   		CY3->(dbSkip())
	End           
	
Return Nil        
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXXtoS()
Converte qualquer valor para ser utilizado durante a integração com Datasul

@param xValue (Obrigatório) Valor a ser transformado

@author Ana Carolina Tomé Klock
@since 01/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------   
Function SFCXXtoS( xValue )   
	Local cReturn
	Default xValue := ""
	
	Do case          
	
		// Data
  		Case ValType(xValue) == 'D'
  			cReturn := DTOS(xValue)
  			
     	//Lógico
     	Case ValType(xValue) == 'L'
     		If xValue
     			cReturn := 'true'
     		Else
     			cReturn := 'false'
     		EndIf                 
     	
     	// Numérico
     	Case ValType(xValue) == 'N'
     		cReturn := cValToChar(xValue)  
     	
     	// Array ou Caracter
     	Case ValType(xValue) == 'A' .Or. ValType(xValue) == 'C'
     		cReturn := xValue
     		              
     	// Bloco de código, objeto ou não definido
  		Otherwise                                 
  			cReturn := ""
  		
	EndCase

Return cReturn            
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXStoX()
Converte uma string para qualquer valor para ser utilizado durante a integração com Datasul

@param xValue (Obrigatório) Valor a ser transformado
@param cType  (Obrigatório) Em que tipo será transformado

@author Ana Carolina Tomé Klock
@since 01/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------   
Function SFCXStoX( xValue, cType )   
	Local xReturn
	Default xValue := ""
	Default cType  := 'C'
	
	Do case          
	
	// Data
	Case cType == 'D'
		xValue := StrTran(SFCXXtoS(xValue), "-", "") 
		xReturn := STOD(xValue)
			
	// Datetime pra Data
	Case cType == 'DTD'
		xReturn := STOD(SFCXXtoS(SFCXDatTim(SFCXXtoS(xValue))[1]))
  		
	// Datetime pra Data (Str)
	Case cType == 'DTDS'
		xReturn := SFCXXtoS(SFCXDatTim(SFCXXtoS(xValue))[1])
  		
	// Datetime pra Data (Str)
	Case cType == 'DTTS'
		xReturn := SFCXXtoS(SFCXDatTim(SFCXXtoS(xValue))[2])
     	
	// Datetime pra Data
	Case cType == 'DTT'
		xReturn := SFCXDatTim(SFCXXtoS(xValue))[2]
			
     	//Lógico
     	Case cType == 'L'
     		If xValue == 'true'
     			xReturn := .T.
     		Else
     			xReturn := .F.
     		EndIf                 
     	
     	// Numérico
     	Case cType == 'N'
     		xReturn := Val(xValue)  
     	
     	// Array	              
     	Case ValType(xValue) == 'A'
     		xReturn := xValue
     	                                          
     	// Caracter
     	Case cType == 'C'
     	    xReturn := cValToChar(xValue)
     		
     	// Bloco de código, objeto e não definido
  		Otherwise                                 
	  		xReturn := ""
  		
	EndCase

Return xReturn

// Essa função foi colocada em comentário pois não é mais utilizada em nenhum fonte do Protheus e nem em nenhum dicionário.
// Ela foi desenvolvida para ser utilizada nos fontes de UPDATE´s da 11.8 para criação dos parâmetros do SFC, quando o módulo foi criado.
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXVLDTN()
Valida o parâmetro de Modelo Turno - MV_SFCCDTN

@author Samantha Preima
@since 08/09/2011
@version 1.0
/*/
//-------------------------------------------------------------------   
/*Function SFCXVLDTN()
Local lRet 		:= .T. 
Local aArea		:= GetArea()
Local aAreaCYM  := CYM->(GetArea())
Local cConteudo	:= "" // Conteudo atualzado
Local cParam    := "" 
Local aCampo    := TamSx3('CYM_CDTN')
Local cIdioma   := FwRetIdiom() //https://tdn.engpro.totvs.com.br/display/public/PROT/FwRetIdiom

Do case
	Case cIdioma $ "pt-br | pt-pt"
		cConteudo := "X6_CONTEUD"
	Case cIdioma $ "en | ru"
		cConteudo := "X6_CONTENG"
	Case cIdioma = "es" 
		cConteudo := "X6_CONTSPA"
EndCase

If Empty(M->&cConteudo)
	SFCMsgErro(STR0042,'SFCXFUN') // 'O Conteúdo do parâmetro deverá ser diferente de branco.'
	lRet := .F.
Else
	if Len(Alltrim(M->&cConteudo)) > aCampo[1]
		SFCMsgErro(STR0045 + Alltrim(STR(aCampo[1])),'SFCXFUN')// 'Ultrapassado o limite de caracteres para este parâmetro. Limite máximo:'
		lRet := .F.
	Else
		cParam := Substr(M->&cConteudo,1,aCampo[1])
	Endif
EndIf

If lRet
	CYM->(DbSetOrder(1))
	If !CYM->(DbSeek(xFilial("CYM")+cParam))
		SFCMsgErro(STR0043,'SFCXFUN') // 'Não encontrado registro de Modelo Turno com a chave informada'
		lRet := .F.
	Else
		if CYM->CYM_CDTN != cParam
			SFCMsgErro(STR0043,'SFCXFUN')// 'Não encontrado registro de Modelo Turno com a chave informada'
			lRet := .F.
		Endif
	Endif
EndIf

RestArea(aAreaCYM)
RestArea(aArea)

Return lRet 
*/

// Essa função foi colocada em comentário pois não é mais utilizada em nenhum fonte do Protheus e nem em nenhum dicionário.
// Ela foi desenvolvida para ser utilizada nos fontes de UPDATE´s da 11.8 para criação dos parâmetros do SFC, quando o módulo foi criado.
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXVLDCL()
Valida o parâmetro de Calendário - MV_SFCCDCL

@author Samantha Preima
@since 08/09/2011
@version 1.0
/*/
//-------------------------------------------------------------------   
/*Function SFCXVLDCL()
Local lRet 		:= .T. 
Local aArea		:= GetArea()
Local aAreaCYG  := CYG->(GetArea())
Local cConteudo	:= "" //Conteudo atualzado 
Local cParam    := "" 
Local aCampo    := TamSx3('CYG_CDCL')
Local cIdioma   := FwRetIdiom() //https://tdn.engpro.totvs.com.br/display/public/PROT/FwRetIdiom

Do case
	Case cIdioma $ "pt-br | pt-pt"
		cConteudo := "X6_CONTEUD"
	Case cIdioma $ "en | ru"
		cConteudo := "X6_CONTENG"
	Case cIdioma = "es" 
		cConteudo := "X6_CONTSPA"
EndCase

If Empty(M->&cConteudo) 
	SFCMsgErro(STR0042,'SFCXFUN') // 'O Conteúdo do parâmetro deverá ser diferente de branco.'
	lRet := .F.
Else
	if Len(Alltrim(M->&cConteudo)) > aCampo[1]
		SFCMsgErro(STR0045 + Alltrim(STR(aCampo[1])),'SFCXFUN') // 'Ultrapassado o limite de caracteres para este parâmetro. Limite máximo:'
		lRet := .F.
	Else
		cParam := Substr(M->&cConteudo,1,aCampo[1])
	Endif
EndIf

If lRet 
	CYG->(DbSetOrder(1))
	IF !CYG->(DbSeek(xFilial("CYG")+cParam))
		SFCMsgErro(STR0044,'SFCXFUN') // 'Não encontrado registro de Calendário com a chave informada'
		lRet := .F.
	Else
		if CYG->CYG_CDCL != cParam
			SFCMsgErro(STR0044,'SFCXFUN') // 'Não encontrado registro de Calendário com a chave informada'
			lRet := .F.
		Endif
	Endif
EndIf

RestArea(aAreaCYG)
RestArea(aArea)

Return lRet
*/

// Essa função foi colocada em comentário pois não é mais utilizada em nenhum fonte do Protheus e nem em nenhum dicionário.
// Ela foi desenvolvida para ser utilizada nos fontes de UPDATE´s da 11.8 para criação dos parâmetros do SFC, quando o módulo foi criado.
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCXVLDSP()
Valida o parâmetro de Parada - MV_SFCMTSP

@author Samantha Preima
@since 20/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------   
/*Function SFCXVLDSP()
Local lRet 		:= .T. 
Local aArea		:= GetArea()
Local aAreaCYN  := CYN->(GetArea())
Local cConteudo	:= "" //Conteudo atualzado 
Local cParam    := "" 
Local aCampo    := TamSx3('CYN_CDSP')
Local cIdioma   := FwRetIdiom() //https://tdn.engpro.totvs.com.br/display/public/PROT/FwRetIdiom

Do case
	Case cIdioma $ "pt-br | pt-pt"
		cConteudo := "X6_CONTEUD"
	Case cIdioma $ "en | ru"
		cConteudo := "X6_CONTENG"
	Case cIdioma = "es" 
		cConteudo := "X6_CONTSPA"
EndCase

If Empty(M->&cConteudo) 
	SFCMsgErro(STR0042,'SFCXFUN') // 'O Conteúdo do parâmetro deverá ser diferente de branco.'
	lRet := .F.
Else
	if Len(Alltrim(M->&cConteudo)) > aCampo[1]
		SFCMsgErro(STR0045 + Alltrim(STR(aCampo[1])),'SFCXFUN') // 'Ultrapassado o limite de caracteres para este parâmetro. Limite máximo:'
		lRet := .F.
	Else
		cParam := Substr(M->&cConteudo,1,aCampo[1])
	Endif
EndIf

If lRet 
	CYN->(DbSetOrder(1))
	IF !CYN->(DbSeek(xFilial("CYN")+cParam))
		SFCMsgErro(STR0047,'SFCXFUN') // 'Não encontrado registro de Motivo de Parada com a chave informada'
		lRet := .F.
	Else
		if CYN->CYN_CDSP != cParam
			SFCMsgErro(STR0047,'SFCXFUN') // 'Não encontrado registro de Motivo de Parada com a chave informada'
			lRet := .F.
		Endif
	Endif
EndIf

RestArea(aAreaCYN)
RestArea(aArea)

Return lRet 
*/          

//--------------------------------------------------------------------
/*/{Protheus.doc} SFCXDatTim()
Converte um valor AAAA-MM-DDTHH:MM:SS.000
                                         
@param 	cString		(Obrigatorio) Valor recebido no formado descrito
@return	aArray		{ Date, Time }

@author Ana Carolina Tome Klock
@since 13/01/2012
@version 1.0
/*/
//--------------------------------------------------------------------   
Function SFCXDatTim( cString )     
    Local aArray := {}
    Default cString := "9999-12-31T00:00:00.000"       
	      
	cData := SubStr(cString, 9, 2) + "/" + SubStr(cString, 6, 2) + "/" + SubStr(cString, 1, 4)          
    aAdd( aArray, CTOD(cData))
	aAdd( aArray, Substr(cString, 12, 8))

Return aArray


//--------------------------------------------------------------------
/*/{Protheus.doc} SFCXMKERR()
Cria o array de retorno de erro
                                         
@param 	oModel		Model a ser utilizado
@return	aArray		{ Boolean, String }

@author Bruno Candido Volpato da Cunha
@since 13/03/2012
@version 1.0
/*/
//--------------------------------------------------------------------   
Function SFCXMKERR( oModel )     
    Local aArray := {}
  
    aErro := oModel:GetErrorMessage()
       
    aAdd( aArray, .F.)
	aAdd( aArray, SFCXXtoS(aErro[6]) + ' (' + SFCXXtoS(aErro[4]) + ' = "' + SFCXXtoS(aErro[9]) + '") - SFCXMKERR' )

Return aArray

 
//--------------------------------------------------------------------
/*/{Protheus.doc} SFCXMREAD()
Faz a leitura de arquivo com mais que 65535 bytes
                                         
@param 	cFile		Arquivo a ser utilizado
@return	cRet		Conteudo do Arquivo

@author Bruno Candido Volpato da Cunha
@since 13/03/2012
@version 1.0
/*/
//--------------------------------------------------------------------   
Function SFCXMREAD( cFile, nBlockSize )
Local cBuffer     := ''
Local cCRLF       := Chr( 13 ) + Chr( 10 )
Local cRet        := ''
Local nBack       := 0
Local nHandleRead := 0
Local nLenght     := 0
Local nPointer    := 0
Local nPosCRLF    := 0
Local nTotal      := 0

Default nBlockSize := 1024

nHandleRead := FOpen( cFile )

//-------------------------------------------------------------------
//  Abertura do arquivo
//-------------------------------------------------------------------
If nHandleRead < 0
     Return cRet
EndIf

//-------------------------------------------------------------------
//  Tamanho maximo do arquivo
//-------------------------------------------------------------------
nLenght := FSeek( nHandleRead, 0, 2 )
nTotal  := nLenght

If nTotal > 1048575
     //ConOut( STR0064 + cFile ) // 'arquivo nao pode ser maior que 1048575 bytes '
     Return cRet
Endif

//-------------------------------------------------------------------
//  Retorna o ponteiro a posicao inicial
//-------------------------------------------------------------------
FSeek( nHandleRead, 0 )

nPointer := 0

If nLenght > nBlockSize
     nLenght := nBlockSize
EndIf

While nPointer < nTotal
     //-------------------------------------------------------------------
     //  Faz a leitura em blocos de nBlockSize bytes
     //-------------------------------------------------------------------
     cBuffer := FReadStr( nHandleRead, nLenght )
     
     //-------------------------------------------------------------------
     //  Se nao conseguiu ler nada, sai do loop
     //-------------------------------------------------------------------
     If Empty( Len( cBuffer ) )
          Exit
     EndIf
     
     //-------------------------------------------------------------------
     //  Verifica a posicao do ultimo CRLF para ajustar o tamanho da linha
     //-------------------------------------------------------------------
     If cCRLF $ cBuffer
          nPosCRLF := AT( cCRLF, cBuffer )
          nBack    := Len( cBuffer ) - nPosCRLF
          cBuffer  := Left( cBuffer, nPosCRLF )
          
          //-------------------------------------------------------------------
          //  Retrocede a posicao do ponteiro de leitura
          //-------------------------------------------------------------------
          FSeek( nHandleRead, -nBack, 1 )
     EndIf
     
     //-------------------------------------------------------------------
     //  Atualiza a variavel de ponteiro
     //-------------------------------------------------------------------
     nPointer := FSeek( nHandleRead, 0, 1 )
     
     //-------------------------------------------------------------------
     //  Monta Retorno
     //-------------------------------------------------------------------
     cRet     += cBuffer
End

FClose( nHandleRead )

Return cRet


//--------------------------------------------------------------------
/*/{Protheus.doc} SFCXCGERR()
Método chamado quando ocorre erro
                                         
@param 	oErr		Objeto de erro


@author Bruno Candido Volpato da Cunha
@since 21/03/2012
@version 1.0
/*/
//--------------------------------------------------------------------   
Function SFCXCGERR( oErr )

//ConOut(STR0065 + oErr:Description + ' - ' + oErr:ErrorStack) // '[Processamento] Ocorreu um erro inesperado: '

Return .T.


//--------------------------------------------------------------------
/*/{Protheus.doc} SFCINIHOUR()
Valida se a parada programada será alocada por
1 = Início do Turno
2 = Hora Alocada
3 = Hora Fixada no Parametro (Datasul)
                               
@param 	 cMaq		Máquina que realizará a parada
@param   cHour		Horário que será alocada
@return  cReturn	Horário que deverá ser alocada

@author Ana Carolina Tomé Klock
@since 03/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------- 
/*Function SFCINIHOUR( cMaq, cHour ) 
Local cReturn := ''
                           
	If SuperGetMV("MV_SFCMNHI",.F.,2) == 1 // Inicio do turno       
		dbSelectArea('CYL')
		dbSetOrder(1)
		If CYL->(dbSeek( xFilial('CYL')+cMaq )) // Procura o turno da máquina
			If CYL->CYL_DTVDBG <= DATE() .And. CYL->CYL_DTVDED >= DATE() // Verifica se o mesmo é válido
			    
				dbSelectArea('CYR')
				dbSetOrder(2)
				If CYR->(dbSeek( xFilial('CYR')+CYL->CYL_CDTN+cValToChar(Dow(Date())))) // Procura pela data na tabela
					While CYR->(!EOF())
						If cHour > CYR->CYR_HRBG .And. cHour < CYR->CYR_HRED .And. CYR->CYR_TPTE == '1' .And. CYR->CYR_CDTN == CYL->CYL_CDTN
							cReturn := CYR->CYR_HRBG
						EndIf                                     
				    	CYR->(dbSkip())
				    End
				EndIf
			EndIf  
		
	   	ElseIf Empty(cReturn)  
	 		dbSelectArea('CYB')
	    	dbSetOrder(1)
	     	If CYB->(dbSeek( xFilial('CYB')+cMaq )) 
	     		dbSelectArea('CYI')
	     		dbSetOrder(1)
	     		If CYI->(dbSeek( xFilial('CYI')+CYB->CYB_CDCETR ))
	     			dbSelectArea('CYA')
	     			dbSetOrder(1)
	     			If CYA->(dbSeek( xFilial('CYA')+CYI->CYI_CDARPO )) 
	     				dbSelectArea('CYR')
						dbSetOrder(2)
						If CYR->(dbSeek( xFilial('CYR')+CYL->CYL_CDTN+cValToChar(Dow(Date())))) // Procura pela data na tabela
							While CYR->(!EOF())
								If cHour > CYR->CYR_HRBG .And. cHour < CYR->CYR_HRED .And. CYR->CYR_TPTE == '1' .And. CYR->CYR_CDTN == CYL->CYL_CDTN
									cReturn := CYR->CYR_HRBG
								EndIf                                     
						    	CYR->(dbSkip())
						    End
						EndIf    
	     			EndIf
	     		EndIf
	     	EndIf
	    EndIf
	
	ElseIf SuperGetMV("MV_SFCMNHI",.F.,2) == 2 // Hora alocada
	    cReturn := cHour       
		
	ElseIf SuperGetMV("MV_SFCMNHI",.F.,2) == 3 // Hora do parâmetro
   		cReturn := SuperGetMV("MV_SFCVLHI",.F.,'00:00:00')
    EndIf   

Return cReturn    */                   

//--------------------------------------------------------------------
/*/{Protheus.doc} SFCValidR5()
Valida se o modulo SIGASFC esta sendo executado a partir do release 5.

@author Andre de Oliveira dos Anjos
@since 26/10/2011
@version 1.0
/*/
//--------------------------------------------------------------------   
Function SFCValidR5()

Return                  

//--------------------------------------------------------------------
/*/{Protheus.doc} SFCIntegra()
Valida se o modulo SIGASFC esta sendo integrado com o PCP

@author Ana Carolina Tomé Klock
@since 23/11/2012
@version 1.0
/*/
//--------------------------------------------------------------------                    
Function SFCIntegra( lConsidDPR )
Default lConsidDPR := .F.

If GetMV('MV_INTSFC',.F.,0) == 0 .And. lConsidDPR
	Return SuperGetMV('MV_INTDPR',.F.,0)
Else
	Return GetMV('MV_INTSFC',.F.,0)
EndIf

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} SFCValProg()
Valida se o modulo SIGASFC esta com o banco atualizado

@author Samantha Preima
@since 03/12/2012
@version 1.0
/*/
//--------------------------------------------------------------------   
Function SFCValProg()

Return
//--------------------------------------------------------------------
//Campos das Tabelas Manufatura - Retorna lista de campos das tabelas que são usados tanto pelo DPR quanto pelo SFC
//--------------------------------------------------------------------
Function TabCompMAN()
	Local aTabComp :=	{"CYB", "CYH", "CYI", "CZ3","SH1", "SH4", "SAH", "SB1", "SBH", "SBM", "SHB", "NNR", "CY7", "CZ9", "CZX"}
	
Return aTabComp
//--------------------------------------------------------------------
//Campos Manufatura - Retorna lista de campos que são usados tanto pelo DPR quanto pelo SFC
//--------------------------------------------------------------------
Function FldCompMAN()
	//1 - Campo Destino, 2 - Campo Origem
	Local aFldComp :=	{;
		{"CYB_CDCECS","H1_CCUSTO"}	,;
		{"CYB_CDCETR","H1_CTRAB"}	,;
		{"CYB_CDMQ","H1_CODIGO"}		,;
		{"CYB_DSMQ","H1_DESCRI"}		,;
		{"CYB_QTOEMQ","H1_MAOOBRA"}	,;
		{"CYH_CDRC","H4_CODIGO"}		,;
		{"CYH_NMRC","H4_DESCRI"}		,;
		{"CYI_CDCECS","HB_CC"}		,;
		{"CYI_CDCETR","HB_COD"}		,;
		{"CYI_DSCETR","HB_NOME"}		,;
		{"CYI_QTVMCE","HB_HRUT"}		,;
		{"CZ3_CDAC","B1_COD"}		,;
		{"CZ3_CDDP","B1_LOCPAD"}		,;
		{"CZ3_CDFA","B1_TIPO"}		,;
		{"CZ3_CDUN","B1_UM"}			,;
		{"CZ3_DSAC","B1_DESC"}		,;
		{"CY7_CDGE","BM_GRUPO"}     ,;
		{"CY7_DSGE","BM_DESC"}      ,;
		{"CZ9_CDUN","AH_UNIMED"}    ,;
		{"CZ9_DSUN","AH_UMRES"}     ,;
		{"CZX_CDDP","NNR_CODIGO"}   ,;
		{"CZX_DSDP","NNR_DESCRI"}    ;
	}	

Return aFldComp
//--------------------------------------------------------------------
//Tabelas Manufatura - Retorna lista de tabelas que é usada tanto pelo DPR quanto pelo SFC
//--------------------------------------------------------------------
Function MANTabelas()
	Local aTabelas := {;
		{'SH1','CYB','C','C','C'},;	//-- Máquinas (Recursos)
	 	{'SH4','CYH','C','C','C'},;	//-- Recursos (Ferramentas)
		{'SHB','CYI','C','C','C'},;	//-- Centros de Trabalho
		{'SB1','CZ3','C','C','C'},;	//-- Item (Produto)
		{'SX5','CY6','C','C','C'},; //-- Família
		{'SBM','CY7','C','C','C'},; //-- Grupo de Estoque
		{'SAH','CZ9','C','C','C'},; //-- Unidade de Medida
		{'NNR','CZX','C','C','C'},; //-- Depósito
		{'SG1','CZA','C','C','C'};  //-- Desenho						
	}

Return aTabelas
//--------------------------------------------------------------------
//Tabelas SFC - Retorna lista de tabelas que é usada pelo SFC
//--------------------------------------------------------------------
Static Function TabelasSFC(lErrorTab, cMsgTab)
	Local aTabelas	:= {;
		{"SC2","CY0","C","C","C"},;	//-- Apontamento de Refugo
		{"SC2","CY1","C","C","C"},;	//-- Tabela Resultado
		{"SC2","CY2","C","C","C"},;	//-- Componente Tabela Resultado
		{"SC2","CY3","C","C","C"},;	//-- Indicador Filho
		{"SC2","CY4","C","C","C"},;	//-- Histórico Componente Máquina
		{"SC2","CY5","C","C","C"},;	//-- Meta Máquina
		{"SC2","CY8","C","C","C"},;	//-- Meta Indicador
		{"SHY","CY9","C","C","C"},; //-- Operações da Ordem
		{"SC2","CYA","C","C","C"},;	//-- Área de Produção
		{"SC2","CYC","C","C","C"},;	//-- Máquina x Recurso
		{"SC2","CYD","C","C","C"},;	//-- Pert das Operações da Ordem
		{"SC2","CYE","C","C","C"},;	//-- Máquina x Item Controle
		{"SH7","CYF","C","C","C"},; //-- Turno Semana (Calendário)
		{"SH9","CYG","C","C","C"},; //-- Calendário Generico (Exceção de Calendário)
		{"SC2","CYJ","C","C","C"},;	//-- Indicador
		{"SC2","CYK","C","C","C"},;	//-- Item Controle
		{"SH1","CYL","C","C","C"},; //-- Máquina X Turno
		{"SH7","CYM","C","C","C"},;	//-- Turno (Calendário)
		{"SC2","CYN","C","C","C"},;	//-- Motivo Parada
		{"SC2","CYO","C","C","C"},;	//-- Motivo Refugo
		{"SC2","CYP","C","C","C"},;	//-- Componente da Ordem
		{"SC2","CYQ","C","C","C"},;	//-- Ordem de Produção
		{"SH7","CYR","C","C","C"},;	//-- Turno Dia (Calendário)
		{"SC2","CYS","C","C","C"},;	//-- Componente da Meta de Produção
		{"SC2","CYT","C","C","C"},;	//-- Apontamento de Item Controle
		{"SC2","CYU","C","C","C"},;	//-- Meta de Produção
		{"SH6","CYV","C","C","C"},; //-- Apontamento de Produção
		{"SC2","CYW","C","C","C"},;	//-- Apontamento de Mão de Obra
		{"SH6","CYX","C","C","C"},; //-- Apontamento de Parada
		{"SC2","CYY","C","C","C"},;	//-- Split da Operação da Ordem
		{"SH9","CYZ","C","C","C"},; //-- Calendário (Exceção de Calendário)
		{"SC2","CZ0","C","C","C"},;	//-- Apontamento Ferramenta
		{"SC2","CZ1","C","C","C"},;	//-- Equipe x Operador
		{"SC2","CZ2","C","C","C"},;	//-- Manutençaõ Programada
		{"SC2","CZ4","C","C","C"},;	//-- Dados Indicadores
		{"SC2","CZ5","C","C","C"},;	//-- Detalhes Gerenciamento
		{"SC2","CZ6","C","C","C"},;	//-- Apontamento Parada Mão de Obra
		{"SC2","CZ7","C","C","C"},;	//-- Apontamento Parada Geral
		{"SC2","CZ8","C","C","C"},;	//-- Dados Indicadores Específicos
		{"SD4","CZP","C","C","C"},;	//-- Reservas da Ordem
		{"SH6","CZW","C","C","C"};	//-- Apontamento de GGF  
	}
	//Tabelas Manufatura(Usado pelo DPR também)
	Local aTabelasM := MANTabelas()
	Local nI
	
	Default lErrorTab := .F.
	Default cMsgTab   := ""
	
	//Merge nas listas
	For nI := 1 To Len(aTabelasM)
		aAdd(aTabelas,aTabelasM[nI])
	Next	
	//Remove tabelas que não existem no SX2
	ValSX2Tabs(@aTabelas, @lErrorTab, @cMsgTab)
Return aTabelas
//--------------------------------------------------------------------
//Valida SX2 Tabelas - Valida se as tabelas existem na SX2
//--------------------------------------------------------------------
Function ValSX2Tabs(aTabelas, lErrorTab, cMsgTab)
	Local nI
	Local nJ := 0
	Local cTabela := ""
	Local cCarga	:= ""
	
	Default lErrorTab := .F.
	Default cMsgTab   := ""

	//Verifica se a tabela existe no SX2 pra validar	
	For nI := 1 To Len(aTabelas)        
		If !Empty(aTabelas[nI])	
			If !FwAliasInDic(aTabelas[nI,2]) 
				lErroTab := .T. // Utilizada no CARGADPR.
				If Empty(cTabela)
					cTabela += aTabelas[nI][2]
				Else
					cTabela += ", " + aTabelas[nI][2]
				EndIf
				aDel(aTabelas,nI)
				nI--
				nJ++
			EndIF
		EndIf
	Next
	If nJ > 0
		aSize(aTabelas,Len(aTabelas)-nJ)
		If IsInCallStack("CARGASFC") .OR. IsInCallStack("CARGADPR")
			cCarga := " " + STR0058//"Será necessário realizar uma atualização para efetuar a carga."
		EndIf
		lErrorTab := .T.
		cMsgTab := STR0059 + cCarga + " " + STR0060 + " " + cTabela //"O dicionário está desatualizado!" x "Tabela(s) não existente(s): + " x
		MsgAlert(cMsgTab) 
	EndIf
Return Nil
//--------------------------------------------------------------------
/*/{Protheus.doc} SFCExclusi()
Transforma as tabelas compartilhadas em exclusivas caso necessário

@author Ana Carolina Tomé Klock
@since 23/04/2012
@version P11
/*/
//--------------------------------------------------------------------   
Main Function SFCExclusi(lBlind)     
Local aRetorno    
Default lBlind := .F.

Processa( { || aRetorno := SFCXExclus(lBlind) }, STR0066) // "Processando..."

Return aRetorno
//--------------------------------------------------------------------
/*/{Protheus.doc} SFCXExclus()
Transforma as tabelas compartilhadas em exclusivas caso necessário

@author Ana Carolina Tomé Klock
@since 23/04/2012
@version P11
/*/
//--------------------------------------------------------------------
Function SFCXExclus(lBlind)
Local nI		:= 0 
Local lSuccess  := .T.  
Local cConvert  := STR0067 + CRLF // 'Validação de compartilhamento: '
Local lErrorTab := .F.
Local cMsgTab   := ""
Local aTabelas := TabelasSFC(@lErrorTab, @cMsgTab)

Default lBlind := .F.

If lErrorTab
	lSuccess := .F.
	cConvert += cMsgTab + PULALINHA
EndIf
If lSuccess
	// Salvando o modo de compartilhamento da tabela PCP
	For nI := 1 to len(aTabelas)
		If FwAliasInDic(aTabelas[nI,1])
			aTabelas[nI,3] := FwModeAccess(aTabelas[nI,1],3)
			aTabelas[nI,4] := FwModeAccess(aTabelas[nI,1],2)
			aTabelas[nI,5] := FwModeAccess(aTabelas[nI,1],1) 
		EndIf
	Next
	
	// Validando se as tabelas estão com compartilhamento igual
	For nI := 1 to len(aTabelas)
		If FwAliasInDic(aTabelas[nI,2])
	      if FwModeAccess(aTabelas[nI,2],3) != aTabelas[nI,3] .or.;
				 FwModeAccess(aTabelas[nI,2],2) != aTabelas[nI,4] .or.;
				 FwModeAccess(aTabelas[nI,2],1) != aTabelas[nI,5]
	
				cConvert += STR0068 + aTabelas[nI,2] + STR0069 + aTabelas[nI,1] +;
									STR0070 + aTabelas[nI,1] + ': ' + aTabelas[nI,3] + ;
									aTabelas[nI,4] + aTabelas[nI,5] + '. ' + aTabelas[nI,2] + ;
									': ' + FwModeAccess(aTabelas[nI,2],3) + FwModeAccess(aTabelas[nI,2],2) +;
									FwModeAccess(aTabelas[nI,2],1) + PULALINHA // 'Erro: Tabela ' ## ' e tabela ' ## ' possuem compartilhamento diferente. ' 
			   
			   lSuccess := .F.  
			Endif
		Endif
	Next

	If lSuccess  
		cConvert += CRLF + STR0071 + CRLF // 'Não foram encontrados erros de compartilhamento de tabelas.'
		
		// Atualiza Família 
		SFCA020LOA()
		
		cConvert += CRLF + STR0056 + CRLF // 'Atualização concluída!'
		If !lBlind
	    		Define MsDialog oDlg Title STR0055 From 3, 0 to 340, 417 Pixel // "Alterações"
			@ 5, 5 Get oMemo Var cConvert Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel
			Activate MsDialog oDlg Center
		EndIf
	EndIf   
EndIf         
                    
Return {lSuccess,cConvert}

//--------------------------------------------------------------------
/*/{Protheus.doc} SFCValInt()
Verifica se integração está ativa para avisar o usuário da necessidade
de realizar a carga de dados.

@author Samantha Preima
@since 28/05/2013
@version P11
/*/
//--------------------------------------------------------------------   
Function SFCValInt(lDPR)
Local lErro    := .F.
Local cRetorno := ''
Default lDPR   := .F.

If SuperGetMV('MV_INTSFC',.F.,0) == 0 .OR.;
  (SuperGetMV('MV_INTSFC',.F.,0) == 1 .AND. Empty(SuperGetMV('MV_SFCCDTN',.F.,'')) .AND. Empty(SuperGetMV('MV_SFCCDCL',.F.,'')))
  
	IF oApp:cModulo == 'DPR' .AND. lDPR
		cRetorno := ValidaDPR()[2]
		
		if !Empty(cRetorno)
			DPRXError( 'DPRA100', cRetorno, 3 )
			lErro := .T.
		Endif
	Else
		SFCMsgErro ( STR0052 , 'SFCXFUN', 2 ) // 'Para que o TOTVSSFC (Chão de Fábrica) funcione corretamente, é preciso executar a carga de dados (CARGASFC)'
	Endif
Endif

Return lErro

/*/{Protheus.doc} SFCIntSFC
Atualiza o status do produto no SFC para comprado ou fabricado.
@author Carlos Alexandre da Silveira
@since 28/01/2019
@version 1.0
@param 01 cProduto	- Código do produto
@param 02 cTipo		- Tipo do produto (1 - Comprado / 2 - Fabricado)
@param 03 oModel	- Modelo de dados
@return lRet
/*/
Function SFCIntSFC(cProduto,cTipo,oModel)
	Local aAreaCZ3 	:= CZ3->(GetArea())
	Local lRet 		:= .T.
	Default oModel	:= FWLoadModel("SFCC101")

	CZ3->(dbSetOrder(1))
	CZ3->(dbSeek(xFilial("CZ3")+cProduto))
	oModel:SetOperation(4)

	If !(oModel:Activate() .And. ;								//-- Ativa o modelo
		oModel:SetValue("CZ3MASTER","CZ3_TPAC",cTipo) .And. ;	//-- Seta valor para o campo
		oModel:VldData() .And. ;								//-- Valida modelo
		oModel:CommitData()	)									//-- Efetiva gravacao
		A010SFCErr(oModel)
	EndIf

	oModel:DeActivate()

	CZ3->(RestArea(aAreaCZ3))

Return lRet
