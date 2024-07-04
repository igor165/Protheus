#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWBROWSE.CH"

Function __GCPA017F
Return

CLASS GCPGrafo
 
Data nBack 		AS NUMBER HIDDEN	//Coluna que representa o falso
DATA nAtual		AS NUMBER HIDDEN	//Coluna que representa a etapa
DATA nNext 		AS NUMBER HIDDEN //Coluna que representa a verdadeiro
DATA nDesc        AS NUMBER HIDDEN //Descrição das etapas
DATA nEtapa 		AS NUMBER HIDDEN 
DATA cInicio		AS CHARACTER //Etapa inicial
DATA cMeio 		AS CHARACTER //Etapa do meio
DATA cFim 			AS CHARACTER //Etapa final
DATA lVerdade 	AS LOGICAL
DATA lFilha 		AS LOGICAL
DATA lEscape    	AS LOGICAL	//Controle de Loop	
DATA aDados		AS ARRAY	//Matriz com o dados
DATA aVerdade		AS ARRAY	//Conjunto de verdade
DATA aMentira		AS ARRAY	//Conjunto dos falsos
DATA aErro      	AS ARRAY	//Erros no fluxo
DATA aEPadrao    	AS ARRAY	//Etapas padrões
DATA aECustom    	AS ARRAY	//Etapas Customizadas
DATA aFPObrig    AS ARRAY	//Etapas obrigatórias no Fluxo Principal (Always True = aVerdade[1])
DATA aCDObrig    AS ARRAY	//Etapas obrigatórias na coluna de cadastro (::nAtual)
DATA aSrcAviso   AS ARRAY 	//Avisos do metodo SrcEtapa

METHOD NEW()				//Init
METHOD GeraGrafo()		//Recursiva do grafo
METHOD VldPEtapa()      //Valida primeiro conjunto(R)
METHOD AddPEtapa()      //Cria etapas no primeiro conjunto(R)
METHOD VldSEtapa() 		//Valida a partir etapas a partir do conjunto(R)
METHOD AddSEtapa() 		//Criar subetapas a partir do primeiro conjunto(R)
METHOD isLoop()	   		//Verifica se a função está em loop
METHOD CheckFim()			//Verifica se o conjunto de verdade chegou no final
METHOD GrvLoop(nEtapa)	//Grava o loop no conjunto de verdade
METHOD CheckFluxo()		//Valida fluxo final
METHOD PreValid()			//Pré valida o array
METHOD InitFalso()    	//Incializa a varredura do falso
METHOD AddFalso()			//Adiciona o conjunto de mentiras
METHOD LogGrafo()			//Gera log com os erros
METHOD SrcEtapa()			//Procura etapa
METHOD AuxEtapa()			//Função auxiliar para efetuar pesquisa
METHOD EnCodDebug()		//Gera arquivo para debug
METHOD DeCodDebug(cPatch)		//Gera array com baso no arquivo texto
METHOD DelLine()			//Utilize o metodo para deletar as linhas deletadas

ENDCLASS
 
//-------------------------------------------------------------------
/*/{Protheus.doc} NEW
Inicializa a classe
@author Raphael Augustos
@since 11/09/2013
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD NEW(aDados) CLASS GCPGrafo 
PARAMTYPE 0 VAR aDados		AS ARRAY OPTIONAL DEFAULT {}	
	::aDados 		:= aDados
	::aErro     	:= {}
	::aFPObrig 	:= {}
	::aCDObrig 	:= {}
	::aVerdade 	:= {}
	::aMentira  	:= {}
	::nEtapa   	:= 0 
	::nBack   		:= 3
	::nAtual   	:= 1
	::nNext   		:= 2	
	::cInicio   	:= ""
	::cMeio    	:= ""
	::cFim      	:= ""
	::lEscape     := .F.
	::aSrcAviso   := {}
	::aEPadrao		:= { "AA","AB","AD","AE","AL","AN","AP","AP","AS","AT","C2","C3","CC","CD","CH","CJ","CN","CR","CT","DA","DC","DF","DH","DI","DO","DT","EC",;
 						 "ED","EG","EH","EJ","EN","ET","EV","EX","FC","FI","FI","FO","GC","GG","HA","HC","HD","HO","HR","HS","IM","IP","IQ","JP","JU","MP",;
 						 "NA","NG","PB","PJ","PQ","PP","PX","QU","RC","RD","RE","RG","RI","RJ","RM","RT","RV","SD","TC","TP","VP"}
	::aECustom		:= {}
Return  


//-------------------------------------------------------------------
/*/{Protheus.doc} DeCodDebug
Metodo para debug da classe
@author Raphael Augustos
@since 11/09/2013
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD EnCodDebug() CLASS GCPGrafo 
Local cPasta		:= 	AllTrim(GetSrvProfString("GCPGRAFO",""))
Local cTrab		:= CriaTrab(,.F.)+".TXT"
Local nHandle     := 0
Local nX          := 1

If !Empty(cPasta )
	nHandle := MSFCREATE(cPasta+"\GCPGRAFO"+cTrab)
	If nHandle > 0
		fWrite(nHandle,"etapa" + cValToChar(::nAtual) + "-next" + cValToChar(::nNext) + "-back"+  cValToChar(::nBack)+ CRLF)
		For nX := 1 To Len(::aDados)
			fWrite(nHandle,ArrayToStr(::aDados[nX]))
			fWrite(nHandle,CRLF)
		Next nX
			fClose(nHandle)		
	EndIf
EndIf

Return  

//-------------------------------------------------------------------
/*/{Protheus.doc} EnCodDebug
Metodo para debug da classe
@author Raphael Augustos
@since 11/09/2013
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD DeCodDebug(cFile) CLASS GCPGrafo 
Local cLinha
Local aRet     := {}
DEFAULT cFile := ""

If !Empty(cFile) .And. File(cFile)
	FT_FUSE(cFile)
	FT_FGOTOP()
	While !FT_FEOF()
			cLinha	:=	FT_FREADLN()
			AAdd(aRet , Separa(cLinha,";"))
		FT_FSKIP()
	End
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DelLine
Deleta as linhas do array ::aDados quando oriundo de aCols
@author Raphael Augusto
@since 22/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD DelLine() CLASS GCPGrafo 
Local nX

If Len(::aDados)> 0
	For nX := 1 To Len(::aDados)
		If nX > Len(::aDados)
			Exit
		EndIf
		If ValType( ::aDados[nX][Len(::aDados[nX])] ) == "L"
			If ::aDados[nX][Len(::aDados[nX])] 
				aDel(::aDados,nX)
				aSize(::aDados,Len(::aDados)-1)
				nX--
			EndIf
		EndIf
	Next nX
EndIf
 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PreValid
Pré-valida o fluxo
@author Raphael Augustos
@since 11/09/2013
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD PreValid()  CLASS GCPGrafo
Local lRet 			:= .T.
Local nEtapa 		:= 0
Local nPos 			:= 0
Local aVerdadeiro	:= {}
Local aFalso		:= {}
Local nX			:= 1

If ValType(::aDados) <> "A"
	lRet := .F.
EndIf

nEtapa := Len(::aDados)
::EnCodDebug()
//----------------------------------------
// Verifica se a matriz foi preenchida
//----------------------------------------
If Len(self:aDados) == 0
	 AAdd( ::aErro , {"E001","","A matriz não possui dados para processamento"})
Else  
	aScan( ::aDados , {|x| AAdd( aVerdadeiro , x[::nNext])})
	aScan( ::aDados , {|x| AAdd( aFalso		 , x[::nBack])})
	
	//--------------------------------------------------------------------------------
	// Verifica se as etapas: cInicio, cMeio e cFim foram informadas
	//--------------------------------------------------------------------------------	
	IF aScan( ::aDados , {|x| x[::nAtual] == self:cInicio }) == 0
		 AAdd( ::aErro,{"E015","OBRIGATÓRIO" ," É obrigatório informar a etapa: ( " + ::cInicio + " ) do fluxo."} )
		 lRet := .F.
	EndIf
	IF aScan( ::aDados , {|x| x[::nAtual] == ::cMeio }) == 0
		 AAdd( ::aErro,{"E016","OBRIGATÓRIO","É obrigatório informar a etapa: ( " + ::cMeio + " ) dentro do fluxo."} )
		 lRet := .F.
	EndIf
	IF aScan( ::aDados , {|x| x[::nAtual] == ::cFim }) == 0
		 AAdd( ::aErro, {"E017", "OBRIGATÓRIO","É obrigatório informar a etapa: ( " + ::cFim + " ) dentro do fluxo."} )
		 lRet := .F.
	EndIf
	
	//--------------------------------------------------------------------------------
	// Verifica a ordem das etapas: cInicio e cFim
	//--------------------------------------------------------------------------------
	If ::aDados[1][::nAtual] <> ::cInicio
		 AAdd( ::aErro , {"E002",::cInicio,"Etapa: "+ ::cInicio+ ". Coloque a primeira etapa no começo do fluxo."})
		 lRet := .F.
	EndIf
	If ::aDados[nEtapa][::nAtual] <> ::cFim
		 AAdd( ::aErro , {"E003",::cFim,"Etapa: " + ::cFim + ".  Coloque a ultima etapa  no final do fluxo"})
		 lRet := .F.
	EndIf
	//--------------------------------------------------------------------------------
	// Valida a coluna verdadeiro(nNext) e falso (nFalso) das etapas cInicio e cFim
	//--------------------------------------------------------------------------------	
	If !Empty(::aDados[1][::nBack] )
		 AAdd( ::aErro , {"E004", ::cInicio , "Na primeira etapa a coluna falso não pode estar preenchida."})
		 lRet := .F.
	EndIf
	If !Empty(::aDados[nEtapa][::nBack] )
		 AAdd( ::aErro , {"E005",::cFim , "Na ultima etapa a coluna falso não pode estar preenchida."})
		 lRet := .F.
	EndIf
	If !Empty(::aDados[nEtapa][::nNext] )
		 AAdd( ::aErro , {"E006",::cFim , "Na ultima etapa a coluna verdadeiro não pode estar preenchida."})
		 lRet := .F.
	EndIf  
   If lRet
    	//----------------------------------------------------------------------
		// Valida as colunas verdadeiro(nNext) e falso(nBack)
		//----------------------------------------------------------------------
		For nX := 1 To Len(::aDados)
			If  ::aDados[nX][::nAtual] == ::aDados[nX][::nNext]
	  			AAdd( ::aErro , {"E008",::aDados[nX][::nAtual] ,"Etapa: " + ::aDados[nX][::nAtual] + " o conteúdo da coluna verdadeiro não pode ser ( " + ::aDados[nX][::nNext] + ")."} )
	  			lRet := .F.
	  			Exit
			EndIf					
			If  ::aDados[nX][::nAtual] == ::aDados[nX][::nBack]
	  			AAdd( ::aErro , {"E009", ::aDados[nX][::nAtual] , "Etapa: " + ::aDados[nX][::nAtual]  + " o conteúdo da coluna falso não pode ser ( " + ::aDados[nX][::nBack] + ")." })
	  			lRet := .F.
	  			Exit
			EndIf			
			If ::aDados[nX][::nAtual] <> ::cFim .And. Empty(::aDados[nX][::nNext] )
				AAdd( ::aErro , {"E010", ::aDados[nX][::nAtual], "Etapa: " +::aDados[nX][::nAtual] + " preencha a coluna verdadeiro"})
				lRet := .F.
				Exit
			EndIf
			If  Empty(AllTrim(::aDados[nX][::nAtual]))
	  			AAdd( ::aErro , {"E011","","Não é permitido deixar a coluna etapa em branco. Na linha  " + AllTrim(cValToChar(nX))+ " da aba fluxo informe uma etapa. "} )
	  			lRet := .F.
	  			Exit
			EndIf			
			If ::aDados[nX][::nAtual] <> ::cFim .And. ::aDados[nX][::nNext] == ::aDados[nX][::nBack]	
	  			AAdd( ::aErro , {"E012", ::aDados[nX][::nAtual], "Etapa: " + ::aDados[nX][::nAtual] + " o conteúdo da coluna verdadeiro e falso não pode ser identico"} )
	  			lRet := .F.
	  			Exit			
			EndIf			
		Next nX		
		
		//---------------------------------------------------------------------------------------------
		// Valida as etapas das colunas verdadeiro(nNext) e falso (nBack) de cada etapa (nAtual)
		//---------------------------------------------------------------------------------------------
		For nX := 1 To Len(aVerdadeiro) 
			If ::aDados[nX][::nAtual] == ::cFim
				Loop
			EndIf
			If aScan( ::aDados , {|x| x[::nAtual] == aVerdadeiro[nX] }) == 0
				AAdd( self:aErro , {"E013",::aDados[nX][::nAtual] ,"Etapa: " + ::aDados[nX][::nAtual] + " o valor informado na coluna verdadeiro não existe" })
				lRet := .F.
				Exit
			EndIf					
		Next nX
		
		For nX := 1 To Len(aFalso)
			If !Empty(::aDados[nX][::nBack]) .And. aScan( ::aDados , {|x| x[::nAtual] == aFalso[nX] }) == 0
				AAdd( self:aErro , {"E014",::aDados[nX][::nAtual] , "Etapa: " + ::aDados[nX][::nAtual] + " o valor informado na coluna falso não existe"}  )
				lRet := .F.
				Exit
			EndIf			
		Next nX
		//---------------------------------------------------------------------------------------------
		// Campos obrigatórios no fluxo
		//---------------------------------------------------------------------------------------------		
		For nX := 1 To Len(::aCDObrig)
			If aScan( ::aDados , {|x| x[::nAtual] == ::aCDObrig[nX] }) == 0
				AAdd( self:aErro , {"E034","OBRIGATÓRIO","É obrigatório informar a etapa " + ::aCDObrig[nX] + " no fluxo de etapas." }  )
				lRet := .F.
				Exit
			EndIf			
		Next nX		
	EndIf	
EndIf
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraGrafo
Função recursiva que gera conjuntos de verdades e mentiras (caminhos)
@author Raphael Augustos
@since 11/09/2013
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GeraGrafo(nPos, lFilha ,lVerdade)  CLASS GCPGrafo 
Local nX 	:= 1 
DEFAULT nPos 	:= 1 	    
DEFAULT lFilha		:= .F.
DEFAULT lVerdade 	:= .T.

Self:lFilha := lFilha
Self:lVerdade := lVerdade

If !lFilha 
	//----------------------------------------------------------------------
	// Pré valida a aDados
	//----------------------------------------------------------------------	
	If ::PreValid() 
		For nX := nPos To Len(::aDados)  
	   		//Adiciona Etapa
	   		::nEtapa++
	   		If ::nEtapa > 1 .And. !::aVerdade[1][2]
				AAdd(::aErro, {"E030",::cInicio, "A Partir da etapa: " + ::cInicio+ " o fluxo: " + StrTran(ArrayToStr( ::aVerdade[1][3] ),";","->")  + " não leva para etapa final :" + ::cFim } )
				Exit
			ElseIf ::nEtapa > 1 .And. aScan(::aVerdade[1][3], {|x| x == ::cMeio }) == 0
				AAdd (::aErro, {"E031", ::cInicio , "A parti da etapa: " + ::cInicio +  " o fluxo: " + StrTran(ArrayToStr( ::aVerdade[1][3] ),";","->") + " não passa pela do meio :" + ::cMeio})
				Exit
	   		End	   		     		
		  	If ::lVerdade
		 		Self:lFilha := lFilha
				Self:lVerdade := lVerdade				
				If ::nEtapa == 1
					If !::VldPEtapa()
						Return
					EndIf
				Else
					::VldSEtapa( nX , {::aDados[nX][::nAtual],::aDados[nX][::nNext]})
				EndIf  		  
				nPos := aScan( ::aDados , {|x| x[::nAtual] == ::aDados[nX][::nNext] } )  			
				If nPos > 0 
					If ::nEtapa == 1 .Or. (::nEtapa > 1 .And. Self:lEscape == .F.) 
						If !::isLoop(::aDados[nX][::nNext])
							::GeraGrafo(nPos , .T.)
						EndIf
					Else
						::lEscape := .F.
					EndIf
				EndIf
			EndIf                                                                   
		Next nX 
	EndIf
	::CheckFluxo()
Else 
	If ::lVerdade	
	    If ::nEtapa == 1
		    ::VldPEtapa(nPos)
		Else 
			::VldSEtapa( nPos , {::aDados[nPos][::nAtual],::aDados[nPos][::nNext]})
			If !self:lEscape
				nPos := aScan( Self:aDados , {|x| Self:aDados[nPos][Self:nNext] == x[::nAtual] } )
				If nPos > 0 
					If !::isLoop(::aDados[nPos][::nNext])
						::GeraGrafo(nPos , .T. , .T.)
					Else
					// Grava loop de etapas a partir do segundo Grau. Exemplo:  A->B | B->C | C->A 
						::GrvLoop(nPos)
					EndIf
				EndIf
			Else
				::lEscape := .F.
			EndIf
		EndIf
	EndIf
EndIf

Return   

//-------------------------------------------------------------------
/*/{Protheus.doc} VldSEtapa
Valida conjuntos a partir da segunda etapa
@author Raphael Augustos
@since 11/09/2013
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD VldSEtapa(nEtapa , aVerdade ) CLASS GCPGrafo 
Local nX 		:= 1
Local nPos 		:= 0
Local nPai 		:= 0
Local nFilha	:= 0
//----------------------------------------------------------------------
// Essa etapa é um conjunto de verdade
//----------------------------------------------------------------------
nPos := aScan(::aVerdade, {|x| x[1] == nEtapa} )
If nPos == 0
	//----------------------------------------------------------------------
	// Essa etapa pertence a algum sub-conjunto de verdade
	//----------------------------------------------------------------------	
	For nX := 1 To Len (self:aVerdade)
		nPos := aScan(::aVerdade[nX][4],{ |x| x == nEtapa })
		If nPos > 0
			nPai := nX
			nFilha := nPos
			Exit
		EndIf					
	Next nX 
	//----------------------------------------------------------------------
	// Se essa etapa não pertecer a nenhuma etapa ou subetapa eu crio uma recursiva dela
	//----------------------------------------------------------------------		
	If nPos == 0
		::AddSEtapa( nEtapa , aVerdade )
	Else 
		//----------------------------------------------------------------------
		// O Conjunto que essa etapa pertence conduz ao final do caminho
		//----------------------------------------------------------------------
		If Self:aVerdade[nX][2]
			nPos := aScan(::aVerdade, {|x| x[1] == ::nEtapa} )
			If nPos > 0
				::aVerdade[nPos][2] := .T.
				::aVerdade[nPos][6] := .T.
				AAdd( ::aVerdade[nPos][7], nPai)
				AAdd( ::aVerdade[nPos][7], nFilha)
				//Final da cadeia começamos a validar o falso
				::InitFalso()
			EndIf
			::lEscape := .T.
			Return
		Else
			//Grava Loop
			::aVerdade[nX][6] := .T.
			::aVerdade[nX][9] := .T.
			::lEscape := .T. 
			
			AAdd( ::aErro ,{"E032", ::aVerdade[nX][10] , "Redundância na etapa: "+ ::aVerdade[nX][10] + ". Fluxo: " + StrTran(ArrayToStr( ::aVerdade[nX][3] ),";","->")  + ". Corrija o fluxo"}) 
			
		EndIf
	EndIf	
EndIf

//-------------------------------------------------------------------
/*/{Protheus.doc} AddSEtapa
Adiciona conjunto no array aVerdade
@author Raphael Augustos
@since 11/09/2013
@version 1.0
/*/
//--------------------------------------------------------------------      
METHOD AddSEtapa( nEtapa , aVerdade ) CLASS GCPGrafo  
Local nX := 1

If ::lFilha 
	nPos := aScan(::aVerdade, {|x| x[1] == Self:nEtapa} )				
	If nPos > 0  
		::CheckFim(nPos,aVerdade)
		If aScan (::aVerdade[nPos][4], {|x| x == nEtapa  }) == 0		
			AAdd( ::aVerdade[nPos][4] ,nEtapa )
			AAdd( ::aVerdade[nPos][5] ,aVerdade )
			For nX := 2 To Len (aVerdade)
				AAdd (::aVerdade[nPos][3],aVerdade[nX])
			Next
		EndIf
	EndIf		
Else
	//----------------------------------------------------------------------
	// Cria um etapa que não esteja em nenhum conjunto de verdades
	//----------------------------------------------------------------------		
                          //    1          2   3    4    5     6    7    8     9			
    AAdd( Self:aVerdade , { self:nEtapa , .F., {} , {} , {} , .F. , {} , "" , .F. , ::aDados[::nEtapa][::nAtual] })
	AAdd( ::aVerdade[Len(::aVerdade)][4] ,nEtapa )
	AAdd( ::aVerdade[Len(::aVerdade)][5] ,aVerdade )
	For nX := 1 To Len (aVerdade)
		AAdd (::aVerdade[Len(::aVerdade)][3],aVerdade[nX])
	Next
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldPEtapa
Valida conjunto da primeira etapa
@author Raphael Augustos
@since 11/09/2013
@version 1.0
/*/
//--------------------------------------------------------------------  
METHOD VldPEtapa(nPos)  CLASS GCPGrafo
Local lRet := .T.
//-----------------------------------------------------------------------
// Processa as filhas
//-----------------------------------------------------------------------
If ::lFilha
	::AddPEtapa( nPos , {::aDados[nPos][::nAtual],::aDados[nPos][::nNext]})
	nPos := aScan( ::aDados , {|x| ::aDados[nPos][::nNext] == x[::nAtual] } )
	If nPos > 0
		::AddPEtapa( nPos , {::aDados[nPos][::nAtual],::aDados[nPos][::nNext]})
		If !::isLoop(::aDados[nPos][::nNext])
			::VldPEtapa(nPos , {::aDados[nPos][::nAtual],::aDados[nPos][::nNext]})
			//::GeraGrafo(nPos , .T. , .T.)
		Else
		Conout("LOOP")
		EndIf
	Else
	EndIf	
Else
	//-----------------------------------------------------------------------
	// Processa o pai
	//-----------------------------------------------------------------------
	If ::aDados[::nEtapa][::nAtual] <>	::cInicio 
		 AAdd( ::aErro , {"E033","Primeira etapa","A primeira etapa do fluxo deve ser: " + ::cInicio + " e a etapa informada foi " + ::aDados[::nEtapa][::nAtual] + " corrija "})
		 lRet := .F.
	EndIf
    AAdd( Self:aVerdade , { self:nEtapa , .F., {} , {} , {} , .F. , "" , "" , .F. , ::aDados[::nEtapa][::nAtual]  })
	AAdd( ::aVerdade[1][4] ,Self:nEtapa )
	AAdd (::aVerdade[1][3],::aDados[::nEtapa][::nAtual])
	AAdd (::aVerdade[1][3],::aDados[::nEtapa][::nNext])	
	AAdd( ::aVerdade[1][5] ,{::aDados[::nEtapa][::nAtual],::aDados[::nEtapa][::nNext]} )		
EndIf
Return lRet  

//-------------------------------------------------------------------
/*/{Protheus.doc} AddPEtapa
Adiciona conjunto no attay aVerdade
@author Raphael Augustos
@since 11/09/2013
@version 1.0
/*/
//--------------------------------------------------------------------  
METHOD AddPEtapa( nEtapa , aVerdade )  CLASS GCPGrafo
Local nX := 0
Local nB := 0
nPos := aScan(::aVerdade, {|x| x[1] == Self:nEtapa} )

If nPos > 0
	::CheckFim(nPos,aVerdade)
	If aScan (::aVerdade[nPos][4], {|x| x == nEtapa  }) == 0
		AAdd( ::aVerdade[nPos][4] ,nEtapa )
		AAdd( ::aVerdade[1][5] ,aVerdade )
		For nX := 2 To Len (aVerdade)
			AAdd (::aVerdade[nPos][3],aVerdade[nX])
		Next
	Else
		//----------------------------------------------------------------------
		// Final do caminho
		//----------------------------------------------------------------------	
		If self:aVerdade[nPos][2]
			//----------------------------------------------------------------------
			// Verifico a coluna falso percorrendo o caminho de trás para frete
			//----------------------------------------------------------------------					
			::InitFalso()
		EndIf
	EndIf
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} isLoop
Verifica se a função está em loop
@author Raphael Augustos
@since 11/09/2013
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD isLoop(cProximo) Class GCPGrafo
Local nEtapa   := 0
Local nPai := 0
Local lRet := .F.
	nEtapa := aScan( ::aDados , {|x| x[::nAtual] == cProximo } )
	nPai  :=  aScan( ::aVerdade , {|x| x[1] == ::nEtapa } )
	If nEtapa > 0  .And.  nPai > 0
	   If aScan(::aVerdade[nPai][4] ,{|x| x ==  nEtapa}  ) > 0
		   lRet  := .T.
	   EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckFim
Verifica se é a ultima etapa
@author Raphael Augustos
@since 11/09/2013
@version 1.0
/*/
//--------------------------------------------------------------------  
METHOD CheckFim(nPos, aVerdade)  CLASS GCPGrafo 
	If aVerdade[1] == Self:cFim
		If Valtype(Self:aVerdade[nPos]) == "A"
			::aVerdade[nPos][2] := .T.
		EndIf
	EndIf 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvLoop
Grava loop no conjunto vigente
@author Raphael Augustos
@since 11/09/2013
@version 1.0
/*/
//--------------------------------------------------------------------  
METHOD GrvLoop(nEtapa)  CLASS GCPGrafo 
Local nPos := 0
//-------------------------------------------------------------------------------------
// Se a etapa recursiva não estiver cadastrada na etapa pai eu gravo para ter o histórico
//-------------------------------------------------------------------------------------		
nPos :=  aScan( ::aVerdade , {|x| x[1] == self:nEtapa } )
If nPos > 0
	If aScan(::aVerdade[nPos][4]  , { |x| x == nEtapa }) == 0
		AAdd (::aVerdade[nPos][4] , nEtapa)
		AAdd (::aVerdade[nPos][5] , {::aDados[nEtapa][::nAtual] , ::aDados[nEtapa][::nNext] } )
	EndIf
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckFluxo
Check conjunto verdade e mentira (caminhos)
@author Raphael Augustos
@since 11/09/2013
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD CheckFluxo( )  CLASS GCPGrafo
Local nX := 1


//--------------------------------------------------------------------
// Etapas obrigatórias na coluna de cadastro (::nAtual)
//--------------------------------------------------------------------
If Len(::aCDObrig) > 0 .And. Len(::aVerdade) > 0 .And. ::aVerdade[1][2]
	For nX := 1 To Len(::aCDObrig)
		If ValType(::aCDObrig[nX]) == "C"
			If aScan( ::aVerdade[1][3] , {|x| x == ::aCDObrig[nX]}) == 0
				AAdd( ::aErro , {"E034","OBRIGATÓRIO","É obrigatório informar a etapa" + ::aCDObrig[nX] + "no fluxo de etapas." })
			EndIf
		EndIf
	Next nX
EndIf

//--------------------------------------------------------------------
// Etapas obrigatórias no fluxo principal ( seguindo o caminho da coluna TRUE)
//--------------------------------------------------------------------
If Len(::aFPObrig) > 0 .And. Len(::aVerdade) > 0 .And. ::aVerdade[1][2]
	For nX := 1 To Len(::aFPObrig)
		If ValType(::aFPObrig[nX]) == "C"
			If aScan( ::aVerdade[1][3] , {|x| x == ::aFPObrig[nX]}) == 0
				AAdd( ::aErro , {"E034","OBRIGATÓRIO","É obrigatório que a etapa " + ::aFPObrig[nX] + " esteja no fluxo da etapa " + ::cInicio })
			EndIf
		EndIf
	Next nX
EndIf


//--------------------------------------------------------------------
// Etapas custmizadas
//--------------------------------------------------------------------
If Len(::aEPadrao) > 0
	For nX := 1 To Len(::aDados)
		If !Empty(::aDados[nX][::nAtual]) // -- HOTFIX  
			If aScan( ::aEPadrao , {|x| x == ::aDados[nX][::nAtual]}) == 0
				AAdd( ::aECustom , {"E035",::aDados[nX][::nAtual],"A etapa " +::aDados[nX][::nAtual] + " e customizada" })
				//AAdd( ::aErro , {"E035",::aDados[nX][::nAtual],"A etapa " +::aDados[nX][::nAtual] + " e customizada" })
			EndIf
		EndIf
	Next nX
EndIf
//--------------------------------------------------------------------
// Opções de falso que não conduzem ao caminho final
//--------------------------------------------------------------------
If Len(::aMentira) > 0
	For nX := 1 To Len(::aMentira)
		If !::aMentira[nX][6]
			AAdd( ::aErro , {"E036",::aMentira[nX][2],"O falso da etapa: " + ::aMentira[nX][2] + " não conduz ao final do caminho. Ajuste o fluxo da etapa: " + ::aMentira[nX][3]  })
		EndIf
	Next Nx
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} InitFalso
Essa função e chamada no final de todo o conjunto de verdade
@author Raphael Augustos
@since 11/09/2013
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD InitFalso( )  CLASS GCPGrafo
Local nPos   	:= 0
Local nPai   	:= 0
Local nEtapa 	:= 0
Local nConjunto := 0
Local cFalso    := 0
Local nX		:= 0
//--------------------------------------------------------------------
//Localiza o conjunto verdade para percorrer o caminho de trás para frente
//--------------------------------------------------------------------	
	nPai := aScan(::aVerdade , {|x| x[1] == ::nEtapa})
	If nPai > 0
		For nPos := Len(::aVerdade[nPai][4]) To 1 Step -1
			nEtapa := ::aVerdade[nPai][4][nPos]
			cEtapa := ::aDados[nEtapa][::nAtual]
			cFalso := ::aDados[nEtapa][::nBack]
			//--------------------------------------------------------------------
			// Não valida a primeira e ultima etapa
			//--------------------------------------------------------------------	
			If cEtapa == ::cFim .Or. cEtapa == ::cInicio
				Loop
			EndIf
			If ::nEtapa > 1
   				For nX := 1 To Len (::aMentira)
   					If ( ::aMentira[nX][3] == ::aVerdade[nPai][10]) .And. !::aMentira[nX][6]
	   					::aMentira[nX][6] := .T.
   					EndIf
   				Next nX
			EndIf
			If !Empty(cFalso)
				::AddFalso ( nEtapa, cEtapa, cFalso , nPai , nPos   )				
			EndIf			
		Next nPos
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddFalso
Adiciona conjunto de verdade para a primeira etapa
@author Raphael Augustos
@since 11/09/2013
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD AddFalso( nEtapa, cEtapa, cFalso , nPai , nPos ) CLASS GCPGrafo
Local nX   		:= 0
Local nPosPai 	:= 0 
Local nPosFilha := 0

DEFAULT nPos 	:= 0
//--------------------------------------------------------------------
// Primeira vez que o conjunto a Mentira é chamado
//--------------------------------------------------------------------	
If Len(::aMentira) == 0
	AAdd ( ::aMentira , {nEtapa ,cEtapa, cFalso, nPai , nPos , .F. })
	If cFalso == ::cInicio .Or. cFalso == ::cFim
		::aMentira[1][6] := .T.	
	Else
		nPos := aScan(::aVerdade, {|x| x[1] == ::nEtapa} )
		If nPos > 0
			If aScan (::aVerdade[nPos][3], {|x| x == cFalso  }) > 0
				::aMentira[1][6] := .T.
			EndIf
		EndIf
	EndIf
Else
	//--------------------------------------------------------------------
	// Se a caminho falso apontar para o final ou começo é verdadeiro
	//--------------------------------------------------------------------		
	If cFalso == ::cInicio .Or. cFalso == ::cFim
		AAdd ( ::aMentira , { nEtapa , cEtapa , cFalso , nPai , nPos , .T. })
		For nX := 1 To Len(::aMentira)
			If self:aMentira[nX][3] == self:aVerdade[nPai][10]
			EndIf
		Next
	Else
	//--------------------------------------------------------------------
	// Localiza o conjunto a qual ele pertece para saber se é possivel chegar no final do caminho
	//--------------------------------------------------------------------		
		nPosPai := aScan( ::aVerdade , {|x| x[10] == cFalso})
		If nPosPai == 0
			For nX := 1 To Len (self:aVerdade)				
				nPosFilha := aScan(::aVerdade[nX][3],{ |x| x == cFalso })
				If nPosFilha > 0
					nPosPai := nX
					Exit
				EndIf							
			Next nX						
			If  nPosPai > 0 .And. ::aVerdade[nPosPai][2]
				AAdd ( ::aMentira , { nEtapa , cEtapa , cFalso , nPai , nPos , .T. })
			Else
				AAdd ( ::aMentira , { nEtapa , cEtapa , cFalso , nPai , nPos , .F. })
			EndIf
		EndIf		
	EndIf	
EndIf
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} LogGrafo
Apresenta incossitência do caminho em tela.
@author Raphael Augustos
@since 11/09/2013
@version 1.0
/*/
//--------------------------------------------------------------------
Method LogGrafo(aDados, aTitle) Class GCPGrafo
Local oBrowse
Local oColumn
Local oDlg
Local nI      := 0
Local aFields := {}
Local aList   := {}
Local aSeek   := {}

If ValType(aDados) <> "A"
	Alert("O primeiro parâmetro informado na LogGrago deve ser um array.")
Else
	aList := aDados
	If Len(aList) > 0	
		Aadd( aFields, { "ERRO","ERRO","C",120,0,""} )
		Aadd( aFields, { "ETAPA","ETAPA","C",120,0,""} )
		Aadd( aFields, { "DESCRICAO","DESCRICAO","C",120,0,""} )
		
		DEFINE MSDIALOG oDlg TITLE aTitle FROM 0,0 TO 600,800 PIXEL 
			DEFINE FWBROWSE oBrowse DATA ARRAY ARRAY aList FILTERFIELDS aFields SEEK ORDER aSeek OF oDlg
				ADD COLUMN oColumn DATA { || aList[oBrowse:At(),1] } TITLE "Cod.Erro" SIZE 20 OF oBrowse
				ADD COLUMN oColumn DATA { || aList[oBrowse:At(),2] } TITLE "Etapa" SIZE 20 OF oBrowse
				ADD COLUMN oColumn DATA { || aList[oBrowse:At(),3] } TITLE "Descrição" SIZE 20 OF oBrowse
			ACTIVATE FWBROWSE oBrowse
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} SrcEtapa
Método de procura de etapas orfãs
@author Raphael Augustos
@since 11/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------- 
METHOD SrcEtapa (cEtapa,cEtapaAnt,cEtapaDep) Class GCPGrafo
Local nX		:= 0
Local nPai		:= 0
Local nFilha	:= 0
Local aRet    := {{ .F. , {}, {} , .F. , .F.}}
Local nEtapa  	:= aScan( ::aDados ,{|x| x[::nAtual] == cEtapa} )
Local nEtapaAnt 	:= aScan( ::aDados ,{|x| x[::nAtual] == cEtapaAnt} )
Local nEtapaDep 	:= aScan( ::aDados ,{|x| x[::nAtual] == cEtapaDep} )
Local nEntFlux  	:= 0
Local nDepFlux  	:= 0
Local nPaiLig   	:= 0
Local nFilhaLig 	:= 0

PARAMTYPE 0 VAR cEtapa			AS CHARACTER OPTIONAL DEFAULT ""	
PARAMTYPE 1 VAR cEtapaAnt		AS CHARACTER OPTIONAL DEFAULT ""	
PARAMTYPE 2 VAR cEtapaDep		AS CHARACTER OPTIONAL DEFAULT ""	
//-------------------------------------------------------------------
// Retorno do aRet
// [l] L - Achou a etapa
// [2] A - Posição da pai ou filha
// [3] A - Ocorrências da etapa no conjunto falso
// [4] L - Vem antes da etapa 	cEtapaAnt
// [5] L - Vem Depois da etapa 	cEtapaDep
//-------------------------------------------------------------------

//-------------------
// Faz pesquisa somente em fluxo válido
//-------------------

If Len(::aErro) == 0.And. Len(::aVerdade) > 0
	nPai := aScan(::aVerdade , {|x| x[1] = nEtapa})
	If nPai = 0
		//-------------------------------------------------------------------
		// Procura o caminho nas filhas
		//-------------------------------------------------------------------
		For nX := 1 To Len (self:aVerdade)
			nFilha := aScan(::aVerdade[nX][4],{ |x| x == nEtapa })
			If nFilha > 0
				nPai := nX
				Exit
			EndIf					
		Next nX 
		
		If nPai == 1
					
		ElseIf nPai > 1
		
		EndIf

	Else
		//-------------------------------------------------------------------
		// Metodo de procura para caminhos novos 
		//-------------------------------------------------------------------
		If nPai > 1
			//-------------------------------------------------------------------
			// Pego o elo de ligação com a etapa principal e verifico a ordem
			//-------------------------------------------------------------------
			If !::aVerdade[nPai][9] .And. ::aVerdade[nPai][6] 
				nPaiLig   :=  ::aVerdade[nPai][7][1]
				nFilhaLig :=  ::aVerdade[nPai][7][2]				
				nEntFlux := aScan(::aVerdade[nPaiLig][4] ,  {|x| x = nEtapaAnt })
				nDepFlux := aScan(::aVerdade[nPaiLig][4] ,  {|x| x = nEtapaDep })
				If nEntFlux == 0
					AAdd(::aSrcAviso , {"","","No fluxo da etapa " + cEtapa + "  associada a etapa " + ::aVerdade[nPaiLig][3][nFilhaLig] + " a etapa " + cEtapaAnt +  " não existe. Observe o fluxo : " + StrTran(ArrayToStr( ::aVerdade[nPaiLig][3] ),";","->")})
				EndIf
				If nDepFlux == 0
					AAdd(::aSrcAviso , {"","","No fluxo da etapa " + cEtapa + "  associada a etapa " + ::aVerdade[nPaiLig][3][nFilhaLig] +  " a etapa " + cEtapaDep +  " não existe. Observe o fluxo : " + StrTran(ArrayToStr( ::aVerdade[nPaiLig][3] ),";","->")})
				EndIf
							
				If nFilhaLig < nEntFlux //Vem depois 
					AAdd(::aSrcAviso , {"","","A etapa " + cEtapa + " está associada a etapa " + ::aVerdade[nPaiLig][3][nFilhaLig] + " que vem antes da etapa "  + cEtapaAnt + " observe o fluxo : " + StrTran(ArrayToStr( ::aVerdade[nPaiLig][3] ),";","->")})
					aRet[1][4] := .T.
				EndIf				
				If nFilhaLig > nDepFlux // Vem depois
					AAdd(::aSrcAviso , {"","","A etapa " + cEtapa + " está associada a etapa " + ::aVerdade[nPaiLig][3][nFilhaLig] + " que vem depois da etapa "  + cEtapaDep + " observe o fluxo : " + StrTran(ArrayToStr( ::aVerdade[nPaiLig][3] ),";","->")})				
					aRet[1][5] := .T.
				EndIf								
			EndIf  					
			aRet[1][1] := .T.			
		EndIf	
	EndIf	
Else
	AAdd(::aSrcAviso , {"","","O fluxo não é valido por isso o metodo não está disponível"})
EndIf
Return aRet

Function GCPGrafo()

Return Nil