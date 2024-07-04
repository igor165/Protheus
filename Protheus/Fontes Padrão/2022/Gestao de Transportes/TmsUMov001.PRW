#INCLUDE "Protheus.ch"
//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSUMov001()
Executa operacoes de gravacao de flags e retorno de informacoes            
@param	cTxt     TXT contendo retorno dos arquivos.                
@Return .T.                                 
@author Caio Murakami
@since 11/09/2013  
@obs
/*/
//------------------------------------------------------------------------------------------------

Function TmsUMov001(cTxt)
Local oXMLTxt 	:= Nil
Local cError	:= ""
Local cWarning 	:= ""  
Local nKey		:= 0   
Local cKey 		:= "" 
Local nIndex	:= 1
Local cAlias	:= ""  
Local cFilKey	:= ""
Local aCharEspec:= {",",";","/","\","|"}   
Local nCont		:= 0  
Local aAreaSIX	:= {} 
Local aArea		:= {} 
Local aUniqueKey:= {} 
Local aKey		:= {} 
Local lContinua	:= .F.
Local cEvent	:= ""  
Local cFileName	:= ""
Local cIp		:= ""
Local cDir		:= ""
Local cRelatDir	:= ""   
Local cRetorno	:= ""


DEFAULT cTxt 		:= ""   
oXMLTxt := XmlParser(cTxt, "_", @cError, @cWarning)
 			
If  oXMLTxt <> Nil .And. Empty(cError) .And. Empty(cWarning)    
    
    //-- Retorno de exportacao
    If XmlChildEx(oXMLTxt,'_UMOVEXPORT') <> Nil
        
    	//*--------------------------
		//Tag Event 
		//1-Todos
		//2-Atualizacao
		//3-Exclusao
		//---------------------------*/     
	    If XmlChildEx(oXMLTxt:_UMovExport,'_EVENT') <> Nil
	    	cEvent	:= oXMLTxt:_UMovExport:_Event:Text
	    EndIf    
    
	    //-- Verifica nó do XML
	 	If XmlChildEx(oXMLTxt,'_UMOVEXPORT') <> Nil
			
		   	If XmlChildEx(oXMLTxt:_UMovExport,'_UNIQUEKEY') <> Nil 	 
			    
			    cUniqueKey := RTrim(oXMLTxt:_UMovExport:_UniqueKey:Text)		    
			    
			    //-- Retira caracteres especias e coloca de acordo com campo SX1->CHAVE
				For nCont := 1 To Len(aCharEspec)
					cUniqueKey 	:= StrTran( cUniqueKey , aCharEspec[nCont] , "+" ) 		
				Next nCont
			    
			 	aUniqueKey	:= StrToKArr(cUniqueKey,"+")
			 
				cAlias 	:= SubStr(cUniqueKey, 1, At("_",cUniqueKey)-1 ) 
			    
			    If cAlias $ "DA4/DUD/DT6"
			    	lContinua 	:= .T.
			    EndIf
			    
			    If lContinua
			    
					If ValType(oXMLTxt:_UMovExport:_ListOfKeys:_Key) <> "A"	
						XmlNode2Arr(oXMLTxt:_UMovExport:_ListOfKeys:_Key,"_Key")
					EndIf 
				
					aAreaSIX 	:= SIX->( GetArea() )    			
			   		dbSelectArea("SIX")                   
			   		dbSetOrder( 1 ) 
			   		dbSeek(cAlias)
			   		
			   		//-- Verifica qual o indice utilizado		   		
			   		While SIX->INDICE == cAlias .And. SIX->( !Eof() )     
			   		    
			   		    If cUniqueKey $ SIX->CHAVE
			   				nIndex	:= Val(SIX->ORDEM)
			   				Exit
			   			EndIf
			   	    	
			   	    	dbSkip() 
			   		EndDo  	     		  	
			   		
			   		RestArea( aAreaSIX ) 
			   		
			   		aArea	:= (cAlias)->( GetArea() ) 
			   		
			   		(cAlias)->( dbSetOrder(nIndex) ) 
			   		
			   		//-- Se na chave não tiver o campo FILIAL, acrescenta-o.
			   		If !('_FILIAL' $ cUniqueKey)
			   			cFilKey 	:= xFilial(cAlias)
			   		EndIf
			   		
			   		If cEvent == "3" //-- Exclusão
			   			//-- Deve-se desabilitar o SET DELETED para considerar tambem os registros deletados 
			   			dbSelectArea(cAlias)
			   			SET DELETED OFF
			   		EndIf
			   		
					For nKey := 1 To Len(oXMLTxt:_UMovExport:_ListOfKeys:_Key)
						
						cKey  := ""
						aKey  := StrToKArr(oXMLTxt:_UMovExport:_ListOfKeys:_Key[nKey]:Text , "|" )
					
						For nCont := 1 To Len(aKey)
							cKey += PadR( aKey[nCont] , TamSX3( aUniqueKey[nCont] )[1]  ) 						
						Next nCont
			
						cKey := cFilKey+cKey
	                    
						//-----------------------------
						//cEvent- 1=Todos
						//		- 2=Atualizacao
						//		- 3=Exclusão
						//------------------------------ 	
						
					Next nKey  	
					
					If cEvent == "3" //-- Exclusão
			   			dbSelectArea(cAlias)
			   			SET DELETED ON
			   		EndIf
					
					RestArea( aArea ) 		        
		    	EndIf		        
		    EndIf		        
		EndIf			
	
	//-- Importacao
	ElseIf  XmlChildEx(oXMLTxt,'_UMOVIMPORT') <> Nil
	    
		//-- Nome do arquivo
		If XmlChildEx(oXMLTxt:_UMovImport,'_FILENAME') <> Nil
			cFileName:= RTrim(oXMLTxt:_UMovImport:_FileName:Text)
		EndIf
		
		//-- Endereco que se encontra o arquivo
		If XmlChildEx(oXMLTxt:_UMovImport,'_IPADDRESS') <> Nil
			cIp		:= AllTrim(oXMLTxt:_UMovImport:_IPAddress:Text)
		EndIf
	    
	    //-- Diretorio que se encontra o arquivo
		If XmlChildEx(oXMLTxt:_UMovImport,'_DIRECTORY') <> Nil
			cDir	:= AllTrim(oXMLTxt:_UMovImport:_Directory:Text)
		EndIf
	    
	    //-- Diretorio relativo
		If XmlChildEx(oXMLTxt:_UMovImport,'_RELATIVEDIRECTORY') <> Nil
			cRelatDir	:= AllTrim(oXMLTxt:_UMovImport:_RelativeDirectory:Text)+"\"
		EndIf  
		
		//-- Busca arquivo .csv no caminho indicado
		ReadCsv( cRelatDir+cFileName ) 
	
	EndIf 

Else

	TmsLogMsg("INFO","Necessário rodar update TMSP11R142")
	
EndIf	

Return { .T. , cRetorno }  

 
//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReadCSV()
Leitura do arquivo .csv contendo informacoes sobre as coletas e entregas   

@param	cCaminho	Caminho completo do arquivo. Ex.: 'C:\arquivo.csv'

@Return .T.                                 
@author Caio Murakami
@since 02/10/2013  

@obs

/*/
//------------------------------------------------------------------------------------------------
Static Function ReadCSV( cCaminho ) 
Local aRet 		:= {}    
Local nCont		:= 1 
Local nX		:= 0
Local aCampos   := {} 
Local aConteudo := {} 
Local nHandle	:= Nil 
Local nBloco	:= 999999
Local cBuffer	:= Space(1026) 
Local cConteudo := ""  

DEFAULT cCaminho  := ""


If File( cCaminho )
    
    //-- Abre arquivo
	nHandle := FOPEN(cCaminho) 
    
    //-- Le arquivo e armazena na variavel cBuffer
    FREAD(nHandle,@cBuffer,nBloco)
    
    //-- Transforma arquivos em um array, considerando o separador chr(13)
	If nHandle <> -1 .And. !Empty(cBuffer)
		aConteudo 	:= StrToKArr(cBuffer,chr(13) ) 		
	EndIf	
	
	//-- Fecha área do arquivo
    FCLOSE(nHandle)
    
    If !Empty(aConteudo)
     	/*----------------------------------
     	//-- Estrutura aConteudo:
     	//-- 1ª linha - IDENTIFICADOR;DATA;HORA
     	//-- 2ª linha - CAMPOS CABEÇALHO
     	//-- 3ª linha - CONTEUDO DOS CAMPOS
     	//-- ...
     	//-- Ultima linha - FIM     	
     	-------------------------------------*/
     	
     	While nCont < Len(aConteudo)
     	 	
     	 	//-- CAMPOS CABEÇALHO
     	 	If nCont == 2   
     	    	
     	    	//-- Transforma em um array
     	    	aCampos := StrToKArr( StrTran(aConteudo[nCont],";;",";"+Space(5)+ ";" ) , ";" )
     	 	
     	 	//-- CONTEUDO CAMPOS
     	 	ElseIf nCont > 2 
     	 	      	 	 	
     	 	 	cConteudo	:=  aConteudo[nCont]
     	 	 	
     	 	 	//-- Necessário realizar busca novamente de ocorrencia ";;", pois o StrTran não elimina no caso de ';;;;'
     	 	 	//-- Necessario incrementar espaços pois ao transformar em array, se não tiver espaço entre o delimitador, o array fica com posicoes a menos
     	 	 	While At(";;",cConteudo) > 0
     	 	 		cConteudo := StrTran(cConteudo,";;",";"+Space(5)+ ";" )
     	 	 	EndDo
     	 	 	
     	 	 	//-- Transforma em um array
     	 	 	aRet	:= StrToKArr( cConteudo , ";" ) 
     	 	 	
     	 	 	//-- Lê array e acrescenta o campo correspondente X conteudo correspondente
     	 	 	For nX := 1 To Len(aRet)
     	 	   			
     	 	 		aRet[nX] := { Upper(aCampos[nX]),aRet[nX] }	
     	 	 		
     	 	 	Next nX
     	 	 	
     	 	 	//-- Leitura do array de retorno da uMov.Me
     	 	 	UMovArray(aRet)
     	 	 	
     	 	EndIf
     	 
     		nCont++
     	EndDo
 
    EndIf
Else
	Alert(cCaminho)    
EndIf

Return .T.  

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} UMovArray()
Decodifica array da uMov.me e monta array para o apontamento de ocorrencias

@param	aUMov  		Array com os campos e conteudo da uMov.Me

@Return .T.                                 
@author Caio Murakami
@since 30/09/2013  

@obs

/*/
//------------------------------------------------------------------------------------------------

Static Function UMovArray( aUMov  ) //func
Local nCont		:= 1 
Local nOpc		:= 3 
Local lEntrega	:= .F. //-- Entrega?
Local lColeta	:= .F. //-- Coleta?
Local cTpEntrega:= '1'  //-- Tipo de entrega: 1=Realizada;2=Parcial;3=Não Realizada	
Local cFilDoc	:= ""
Local cDoc		:= ""
Local cSerie	:= "" 
//Local cLogErro	:= ""  
Local cMotivo 	:= ""
Local cCodMot	:= ""
Local cRG		:= ""    
Local cRespons	:= ""  
Local cDatIni	:= ""
Local cDatFim	:= ""
Local cHorIni	:= ""
Local cHorFim	:= ""
Local cCodOco	:= ""
Local aArea	    := GetArea() 
Local aAreaDUD 	:= DUD->( GetArea() ) 
Local aAreaDT6	:= DT6->( GetArea() ) 
Local aAreaDTC	:= DTC->( GetArea() )
Local aDocsDTC	:= {} 	//-- Nf's não entregues
Local aItens	:= {} 
Local cOcorEnt  := SuperGetMv("MV_UMOVENT",,"")	//-- Ocorrencias de entrega para a uMov.Me
Local cOcorCol  := SuperGetMv("MV_UMOVCOL",,"") //-- Ocorrencias de coleta para a uMov.Me
Local aOcorEnt	:= StrToKArr(cOcorEnt,";")
Local aOcorCol	:= StrToKArr(cOcorCol,";") 
Local dDatOco	:= dDataBase
Local cHorOco	:= SubStr(StrTran(Time(),":",""),1,4) 
Local aCols		:= {}	//-- Array para montar o array NF's não entregue 
Local aNF			:= {}	//-- Array para montar o array NF's não entregue
Local nQnt 		:= 0	//-- Quantidade para ser gravada na DUA
Local nQntTotal	:= 0	//-- Quantidade total da nota
Local nQntTPen		:= 0	//-- Quantidade total que não foi entregue
Local nQntPen		:= 0	//-- Quantidade do documento que não foi entregue
Local nI			:= 0	//-- Variavel do For
Local aNDocsDTC	:= {} 	//-- Array com os numeros das NF's não entreges
Local cNumNFC	:= ""
Local cSerNFC	:= ""

Default aUMov	:= {}

Aadd( aItens , {} )

//-- Decodifica array 
For nCont := 1 To Len(aUMov)
    
    //-- Remove caracteres especiais
 	aUMov[nCont,1] := LmpAcento(aUMov[nCont,1])
 	aUMov[nCont,2] := LmpAcento(aUMov[nCont,2]) 
 
	If "TIPO REGISTRO" $ aUMov[nCont,1]	.And. !Empty(aUMov[nCont,2])
		
		If "INSERT" $ aUMov[nCont,2] 
			nOpc	:= 3 
		EndIf
		
	ElseIf "TAREFA ID PARA INTEGRA" $ aUMov[nCont,1] .And. !Empty(aUMov[nCont,2])            
		
		//-- CONTEUDO RECEBIDO PARA O LAYOUT DE TAREFA SERA: DUD_FILDOC+DUD_DOC+DUD_SERIE = ID INTEGRACAO DE TAREFAS
				
		cFilDoc	:= SubStr( aUMov[nCont,2] , 1                			, TamSX3("DUD_FILDOC")[1] ) 
		cDoc	:= SubStr( aUMov[nCont,2] , Len(cFilDoc) + 1 			, TamSX3("DUD_DOC")[1] ) 
		cSerie	:= SubStr( aUMov[nCont,2] , Len(cFilDoc + cDoc)    + 1 	, TamSX3("DUD_SERIE")[1] ) 
		
		aAdd( aItens[Len(aItens)] , { "DUA_FILDOC" 	, cFilDoc , Nil  } ) 
		aAdd( aItens[Len(aItens)] , { "DUA_DOC" 	, cDoc    , Nil  } ) 
		aAdd( aItens[Len(aItens)] , { "DUA_SERIE"	, cSerie  , Nil  } ) 
		aAdd( aItens[Len(aItens)] , { "DUA_SEQOCO" ,StrZero(Len(aItens),4)	 	, Nil  } )         
	
	ElseIf "DATA HORA INICIO EXECUCAO" $ aUMov[nCont,1]	.And. !Empty(aUMov[nCont,2])
		
		//-- FORMATO RECEBIDO AAAA-MM-DD HH:MM:SS       
		cDatIni	:= cValToChar( Transform( aUMov[nCont,2] , "9999-99-99") ) 
		cHorIni	:= Transform( SubStr( aUMov[nCont,2] , At(":",aUMov[nCont,2]) - 2 , 5 )   , "99:99")   
		
		cDatIni	:= SubStr( cDatIni , RAt('-',cDatIni) + 1 , 2 )  + "/" +  ;
					SubStr( cDatIni , At('-' , cDatIni ) + 1 , 2 ) +"/" +  ;
					SubStr(cDatIni , 1 , At('-',cDatIni)  - 1 ) 
		
		aAdd( aItens[Len(aItens)] , { "DUA_DATCHG" , cToD(cDatIni)				 	, Nil  } ) 
		aAdd( aItens[Len(aItens)] , { "DUA_HORCHG" , StrTran( cHorIni , ":" , "" ) 	, Nil  } ) 
		
	ElseIf "DATA HORA FIM EXECUCAO" $ aUMov[nCont,1] .And. !Empty(aUMov[nCont,2])  
	         
		//-- FORMATO RECEBIDO AAAA-MM-DD HH:MM:SS 	
		cDatFim	:= cValToChar( Transform( aUMov[nCont,2] , "9999-99-99") ) 
		cHorFim	:= Transform( SubStr( aUMov[nCont,2] , At(":",aUMov[nCont,2]) - 2 , 5 )   , "99:99")  
		
		cDatFim	:= SubStr( cDatFim , RAt('-',cDatFim) + 1 , 2 )  + "/" +  ;
					SubStr( cDatFim , At('-' , cDatFim ) + 1 , 2 ) +"/" +  ;
					SubStr(cDatFim , 1 , At('-',cDatFim)  - 1 ) 
		
		aAdd( aItens[Len(aItens)] , { "DUA_DATSAI" , cToD(cDatFim) 					, Nil  } ) 
		aAdd( aItens[Len(aItens)] , { "DUA_HORSAI" , StrTran( cHorFim , ":" , "" ) 	, Nil  } ) 
		
	ElseIf "LOCAL ID PARA INTEGRA" $ aUMov[nCont,1] .And. !Empty(aUMov[nCont,2])   
	      
		//-- CONTEUDO RECEBIDO PARA O LAYOUT DE TAREFA SERA: DT6_FILDOC+DT6_DOC+DT6_SERIE = ID INTEGRACAO DE LOCAIS
			    
	   	cFilDoc	:= SubStr( aUMov[nCont,2] , 1                , TamSX3("DT6_FILDOC")[1] ) 
		cDoc	:= SubStr( aUMov[nCont,2] , Len(cFilDoc) + 1 , TamSX3("DT6_DOC")[1] ) 
		cSerie	:= SubStr( aUMov[nCont,2] , Len(cFilDoc + cDoc)    + 1 , TamSX3("DT6_SERIE")[1] ) 
	   	                     
	
	ElseIf "PESSOA ID PARA INTEGRA" $ aUMov[nCont,1] .And. !("TIPO DE PESSOA" $ aUMov[nCont,1]) .And. !Empty(aUMov[nCont,2])  
	 
		//-- CONTEUDO RECEBIDO PARA O LAYOUT DE TAREFA SERA: DA4_FILIAL+DA4_COD = ID INTEGRACAO DE PESSOAS
		
		cCodMot	:= SubStr( aUMov[nCont,2] , TamSX3("DA4_FILIAL")[1] + 1 , TamSX3("DA4_COD")[1] )  
			
	ElseIf "ATIVIDADES ID PARA INTEGRA" $ aUMov[nCont,1]  .And. !Empty(aUMov[nCont,2])
		
		//-- Indica se é uma coleta ou entrega
		If "ATIV_ENTREGA" $ Upper(aUMov[nCont,2]) 
			lEntrega	:= .T.
			lColeta		:= .F. 
		Else
			lColeta		:= .T. 
			lEntrega	:= .F.
		EndIf  
	
	ElseIf ("ENTREGA_REALIZADA" $ aUMov[nCont,1] .Or. "COLETA_REALIZADA" $ aUMov[nCont,1] )  .And. !Empty(aUMov[nCont,2])         
	    
	   	//-- Tipo da entrega
		If "SIM" $ Upper(aUMov[nCont,2])
			cTpEntrega	:= '1'
		ElseIf  "PARCIALMENTE" $ Upper(aUMov[nCont,2])  
			cTpEntrega	:= '2'		
		ElseIf "NAO" $ LpCaracter(Upper(aUMov[nCont,2]))
			cTpEntrega	:= '3'
		EndIf	
	
	ElseIf "DOC_DE_CLIENTE_NAO_ENTREGUE" $ aUMov[nCont,1]   .And. !Empty(aUMov[nCont,2])
	   
		//-- Notas Fiscais não entregues
		aNDocsDTC	:= StrToKArr( aUMov[nCont,2] , "|" ) 
		aCols := {}
		aNF	   := {}
		dbSelectArea("DTC")
		dbSetOrder(7) //DTC_FILIAL+DTC_DOC+DTC_SERIE+DTC_FILDOC+DTC_NUMNFC+DTC_SERNFC                                                                           
	
		For nI :=1 to Len(aNDocsDTC)
			
			cNumNFC	:= SubStr( aNDocsDTC[nI] , 1                , TamSX3("DTC_NUMNFC")[1] ) 
			cSerNFC	:= SubStr( aNDocsDTC[nI] , Len(cNumNFC) + 1 , TamSX3("DTC_SERNFC")[1] ) 
			
			If DTC->(dbSeek(xFilial("DTC")+cDoc+cSerie+cFilDoc+cNumNFC+cSerNFC))
				nQntPen := DTC->DTC_QTDVOL
			EndIf
			AAdd(aNF,{DTC->DTC_NUMNFC, DTC->DTC_SERNFC,nQntPen,nQntPen,.F.})
			nQntTPen += nQntPen
		Next

	ElseIf "JUSTIFICATIVA" $ aUMov[nCont,1]  .And. !Empty(aUMov[nCont,2])   
	    
	    cMotivo	+= 	aUMov[nCont,1]+ ": " + aUMov[nCont,2] + CRLF //-- JUSTIFICATIVA:
	    
	ElseIf "OBSERVA" $ aUMov[nCont,1] .And. !Empty(aUMov[nCont,2])        
	   
		cMotivo	+= 	aUMov[nCont,1]+ ": " +aUMov[nCont,2] + CRLF	//-- OBSERVACAO:
			
	ElseIf "RESPONSAVEL" $ aUMov[nCont,1] .And. !Empty(aUMov[nCont,2])   
	   
		cRespons	:= 	aUMov[nCont,2] 
		Aadd( aItens[Len(aItens)] , {"DUA_RECEBE", cRespons , Nil   } )
		
	ElseIf "RG" $ aUMov[nCont,1] .And. !Empty(aUMov[nCont,2])  
		cRG	:= aUMov[nCont,2] + CRLF //-- RG: 
	EndIf
	
Next nCont

//-- Verifica qual a ocorrencia correta
If lColeta .And. Len(aOcorCol) > 0
	
	//-- Coleta Realizada    
	If cTpEntrega == '1'
	
		cCodOco	:= Padr(aOcorCol[1], TamSx3("DT2_CODOCO")[1])	 //-- Encerra processo coleta
	
	//-- Coleta nao realizada
	ElseIf cTpEntrega == '3' 
	
	   	cCodOco	:= Padr(aOcorCol[2], TamSx3("DT2_CODOCO")[1])	//-- Ocorrencia informativa  
	   	
	EndIf
	
ElseIf lEntrega	.And. Len(aOcorEnt) > 0
    
   	//-- Entrega realizada
   	If cTpEntrega == '1'
    	cCodOco	:= Padr(aOcorEnt[1], TamSx3("DT2_CODOCO")[1])
   	
   	//-- Entrega Parcial
   	ElseIf cTpEntrega == '2'
   		cCodOco	:= Padr(aOcorEnt[1], TamSx3("DT2_CODOCO")[1])
   		cCodOco2	:= Padr(aOcorEnt[2], TamSx3("DT2_CODOCO")[1])
   	
   	//-- Entrega não Realizada
   	ElseIf cTpEntrega == '3'
    	cCodOco	:= Padr(aOcorEnt[3], TamSx3("DT2_CODOCO")[1])
    	
    	cMotivo	+= RTrim( Posicione('SX3', 2, 'DTC_NUMNFC'	, 'X3Titulo()') ) + ":   " 
    	For nCont := 1 To Len(aDocsDTC)
    		cMotivo	+= aDocsDTC[nCont] + "|"
    	Next nCont	
    	
	EndIf
EndIf

//-- Inclui o RG do recebedor da mercadoria no campo DUA_MOTIVO
If !Empty(cRG)
	cMotivo	+= CRLF + RTrim( Posicione('SX3', 2, 'DUA_RECEBE'	, 'X3Titulo()') ) + " : " + cRespons + " / " 
	cMotivo	+= CRLF + RTrim( Posicione('SX3', 2, 'A1_PFISICA'	, 'X3Titulo()') )+ " : " + cRg
EndIf

If !Empty(cMotivo)
	AAdd(aItens[Len(aItens)],{"DUA_MOTIVO",cMotivo,Nil}) 
EndIf

//-- Verifica qual a data para apontar a ocorrencia, priorizando a ultima data e horario
If !Empty(cDatFim) .And. !Empty(cHorFim)
	cHorOco	:= cHorFim
	dDatOco	:= CToD(cDatFim)
ElseIf !Empty(cDatIni) .And. !Empty(cHorIni)
 	cHorOco	:= cHorIni
 	dDatOco	:= CToD(cDatIni)
EndIf

//Seleciona o valor total da ocorrencia
dbSelectArea("DT6")
dbSetOrder(1)
If DT6->(dbSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))
	nQntTotal := DT6->DT6_VOLORI
EndIf
nQnt := nQntTotal - nQntTPen // Calcula o valor da ocorrencia que sera encerrada
		
Aadd( aItens[Len(aItens)] , { "DUA_CODOCO" , cCodOco 					, Nil } ) 
aAdd( aItens[Len(aItens)] , { "DUA_DATOCO" , dDatOco					, Nil  } ) 
aAdd( aItens[Len(aItens)] , { "DUA_HOROCO" , StrTran(cHorOco,":","") 	, Nil  } ) 
aAdd( aItens[Len(aItens)] , { "DUA_QTDOCO" , nQnt							, Nil  } ) 

// Se for Ocorrencia de entrega e do tipo parcial sera gerado duas ocorrencias -> Encerra documento e entrega parcial
If lEntrega	.And. cTpEntrega == '2'
	
	//Função para incluir mais uma linha no aItens
	UmovEntParc(aItens, cFilDoc, cDoc, cSerie, cDatIni, cHorIni, cDatFim, cHorFim, cRespons, dDatOco, cHorOco, cCodOco2,nQntTPen)
	
	// Array de NF's nao entregues
	AAdd(aDocsDTC,{cFilDoc+cDoc+cSerie,aNF,{},cCodOco2,"04",cvaltochar(len(aItens))})
	
EndIf

//-- Grava ocorrencias
UMovGrvOco( cCodOco , cFilDoc , cDoc , cSerie ,  lColeta , lEntrega , , aItens , aDocsDTC , .T.  )

RestArea( aAreaDT6 ) 
RestArea( aAreaDUD ) 
RestArea( aAreaDTC ) 
RestArea( aArea    ) 

Return .T. 

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} UMovGrvOco()
Grava Ocorrencias dos documentos                              

@param	cCodOco		Codigo da ocorrencia
@param	cFilDoc 	Filial do documento
@param	cDoc		Numero do documento
@param	cSerie		Serie do documento
@param 	lColeta		É viagem de coleta?    
@param 	lEntrega	É viagem de entrega?
@param 	aCab		Array do cabeçalho DUA
@param 	aItens		Array de itens DUA    
@param 	aRetornoNF 	Array com notas fiscais
@param 	lUmovMe     Integracao uMovMe?     

@Return .T.                                 
@author Caio Murakami
@since 24/09/2013  

@todo	Painel de integração de ocorrencias

@obs

/*/
//------------------------------------------------------------------------------------------------

Static Function UMovGrvOco( cCodOco , cFilDoc , cDoc , cSerie ,  lColeta , lEntrega ,  aCab , aItens , aRetornoNF , lUMovMe , nOpc  ) //Func.
Local cAlias	:= "" 
Local cFilOri	:= ""
Local cViagem	:= ""
Local cQuery 	:= ""
Local cAliasQry := GetNextAlias()   
Local cLogErro	:= ""
Local cFilRest	:= cFilAnt 
Local aErroAuto	:= {} 
Local aViagem	:= {} 
Local nCont		:= 0 
Local nCountErr := 0  

Private	lMsErroAuto := .F. 

DEFAULT cCodOco		:= ""
DEFAULT cFilDoc		:= cFilAnt
DEFAULT cDoc		:= ""
DEFAULT cSerie		:= "" 
DEFAULT lColeta		:= .F. 
DEFAULT lEntrega	:= .F. 
DEFAULT lUMovMe 	:= .F. 
DEFAULT aCab		:= {}
DEFAULT aItens		:= {} 
DEFAULT aRetornoNF 	:= {} 
DEFAULT nOpc		:= 3

If lUMovMe
	aViagem	:= UMovRetVge( cFilDoc, cDoc , cSerie , lUMovMe ) 
	
	cFilOri	:= aViagem[1]
	cViagem	:= aViagem[2]
     
	If Len(aCab) == 0	.And. !Empty(cFilOri)
		cFilAnt	:= cFilOri
		AAdd(aCab,  {"DUA_FILORI", cFilori ,Nil})
		AAdd(aCab,  {"DUA_VIAGEM", cViagem ,Nil}) 
	EndIf

EndIf

If Len(aCab) > 0 .And. Len(aItens) > 0                       
											
	//-- Ordena array de acordo com dicionário de dadoos
	aCab	:= FWVetByDic( aCab  , "DUA", .F. ,  )
	aItens	:= FWVetByDic( aItens, "DUA", .T. ,  )
	
	//-- Inclusao da Ocorrencia			          
	MsExecAuto({|x,y,z|Tmsa360(x,y,z)},aCab,aItens,aRetornoNF,nOpc)
	
     
	If lMsErroAutoaRetornoNF
		
		MostraErro() // Mostra erro execauto	
		aErroAuto := GetAutoGRLog()  
		
		For nCountErr := 1 To Len(aErroAuto)					
			cLogErro += StrTran(StrTran(aErroAuto[nCountErr],"<",""),"-","") + (" ")
		Next nCountErr  
		
		cLogErro += " / " + CRLF 
		
		//-- INICIO TODO
		/*
		Função para gravar ocorrencia no painel		
		*/                                     
		
		//--GrvPainelOcorrencia(cCodOco,cFilDoc,cDoc,cSerie,cLogErro) 
		
		//-- FIM TODO
					
	EndIf 
	
EndIf

//-- Restaura para a filial anterior
cFilAnt := cFilRest

Return  .T. 


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} UMovRetVge()
Retorna a viagem do documento 

@param	cFilDoc	Filial do documento
@param	cDoc	Numero do documento
@param	cSerie	Serie do documento
@param 	lUMovMe	Integracao com uMov.Me?

@Return aRet - { Filial de Origem , Viagem }
@author Caio Murakami
@since 02/10/2013  

@obs

/*/
//------------------------------------------------------------------------------------------------

Static Function UMovRetVge( cFilDoc, cDoc , cSerie , lUMovMe ) 
Local cQuery 	:= ""
Local cAliasQry := GetNextAlias() 
Local cFilOri	:= ""
Local cViagem 	:= ""

DEFAULT cFilDoc := ""
DEFAULT cDoc	:= ""
DEFAULT cSerie	:= ""
DEFAULT lUMovMe	:= .T.

cQuery := " SELECT DUD_FILORI, MAX(DUD_VIAGEM) DUD_VIAGEM "+CRLF
cQuery += " FROM 	" + RetSQLName("DUD") + " DUD " +CRLF
cQuery += " WHERE DUD_FILDOC 	= '" + cFilDoc + "' " +CRLF
cQuery += "		 AND DUD_DOC   	= '" + cDoc    + "' " +CRLF
cQuery += " 	 AND DUD_SERIE 	= '" + cSerie  + "' " +CRLF
cQuery += " AND DUD.D_E_L_E_T_ = ' ' " +CRLF
cQuery += "GROUP BY DUD_FILORI, DUD_DOC"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry )

If (cAliasQry)->( !Eof() ) 	                          

	cFilOri := (cAliasQry)->DUD_FILORI
	cViagem := (cAliasQry)->DUD_VIAGEM

EndIf

(cAliasQry)->(DbCloseArea())
dbSelectArea("DUA") 	


Return { cFilOri , cViagem }  


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LmpAcento()
Remove a acentuação do texto.

@param	cTxt	Texto a ter os caracteres especiais removido

@Return cRet 	string sem acentuação.
@author TMS       
@since 	02/10/2013
/*/
//------------------------------------------------------------------------------------------------

Static Function LmpAcento(cTxt)

Local cRet	:= ""
Local nX	:= 0

For nX := 1 To Len(cTxt)
	If SubStr(cTxt,nX,1) $ "ÃÁÂÀÇÉÊÈÍÎÌÓÕÔÒÚÛÙãáâàçéêèíîìóõôòúûù"
		If SubStr(cTxt,nX,1) == "Ã"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "Á"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "Â"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "À"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "Ç"
			cRet += "C"
		ElseIf SubStr(cTxt,nX,1) == "É"
			cRet += "E"
		ElseIf SubStr(cTxt,nX,1) == "Ê"
			cRet += "E"
		ElseIf SubStr(cTxt,nX,1) == "È"
			cRet += "E"
		ElseIf SubStr(cTxt,nX,1) == "Í"
			cRet += "I"
		ElseIf SubStr(cTxt,nX,1) == "Î"
			cRet += "I"
		ElseIf SubStr(cTxt,nX,1) == "Ì"
			cRet += "I"
		ElseIf SubStr(cTxt,nX,1) == "Ó"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "Õ"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "Ô"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "Ò"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "Ú"
			cRet += "U"
		ElseIf SubStr(cTxt,nX,1) == "Û"
			cRet += "U"
		ElseIf SubStr(cTxt,nX,1) == "Ù"
			cRet += "U"
		ElseIf SubStr(cTxt,nX,1) == "ã"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "á"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "â"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "à"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "ç"
			cRet += "C"
		ElseIf SubStr(cTxt,nX,1) == "é"
			cRet += "E"
		ElseIf SubStr(cTxt,nX,1) == "ê"
			cRet += "E"
		ElseIf SubStr(cTxt,nX,1) == "è"
			cRet += "E"
		ElseIf SubStr(cTxt,nX,1) == "í"
			cRet += "I"
		ElseIf SubStr(cTxt,nX,1) == "î"
			cRet += "I"
		ElseIf SubStr(cTxt,nX,1) == "ì"
			cRet += "I"
		ElseIf SubStr(cTxt,nX,1) == "ó"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "õ"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "ô"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "ò"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "ú"
			cRet += "U"
		ElseIf SubStr(cTxt,nX,1) == "û"
			cRet += "U"
		ElseIf SubStr(cTxt,nX,1) == "ù"
			cRet += "U"
		EndIf
	Else
		cRet += SubStr(cTxt,nX,1)
	EndIf
	
Next nX

Return AllTrim(cRet)




//------------------------------------------------------------------------------------------------
/*/*{Protheus.doc} UmovEntParc()
Inclui uma ocorrencia quando é viajem de entrega e a entrega é parcial

@param	aItens		Itens do Reg de ocorrencia
@param	cFilDoc	Filial do documento
@param	cDoc		Numero do documeno
@param	cSerie		Serie do documento
@param	cDatIni	Data 
@param	cHorIni	Hora
@param	cDatFim	Data
@param	cHorFim	Hora
@param	cRespons	Responsavel pela entrega
@param	dDatOco	Data da ocorrencia
@param	cHorOco	Data da ocorrencia
@param	cCodOco	Cofigo da ocorrencia
@param	nQntTPen	Quantidade do documento pendente

@Return aItens 
@author Mayara Alves
@since 07/11/2013  

@obs

/*/
//------------------------------------------------------------------------------------------------
Static Function UmovEntParc(aItens, cFilDoc, cDoc, cSerie, cDatIni, cHorIni, cDatFim, cHorFim, cRespons, dDatOco, cHorOco, cCodOco, nQntTPen)
Local nLinha := Len(aItens)+1

aAdd( aItens , { } ) 
aAdd( aItens[nLinha] , { "DUA_FILDOC" 	, cFilDoc 							, Nil  } ) 
aAdd( aItens[nLinha] , { "DUA_DOC" 	, cDoc    							, Nil  } ) 
aAdd( aItens[nLinha] , { "DUA_SERIE"	, cSerie  							, Nil  } ) 
aAdd( aItens[nLinha] , { "DUA_SEQOCO" 	,StrZero(Len(aItens),4)	 		, Nil  } )  
aAdd( aItens[nLinha] , { "DUA_DATCHG" 	, cToD(cDatIni)				 	, Nil  } ) 
aAdd( aItens[nLinha] , { "DUA_HORCHG" 	, StrTran( cHorIni , ":" , "" )	, Nil  } ) 
aAdd( aItens[nLinha] , { "DUA_DATSAI" 	, cToD(cDatFim) 					, Nil  } ) 
aAdd( aItens[nLinha] , { "DUA_HORSAI" 	, StrTran( cHorFim , ":" , "" )	, Nil  } ) 
Aadd( aItens[nLinha] , {"DUA_RECEBE"	, cRespons 						, Nil  } )
Aadd( aItens[nLinha] , { "DUA_CODOCO" 	, cCodOco 							, Nil 	} ) 
aAdd( aItens[nLinha] , { "DUA_DATOCO" 	, dDatOco							, Nil  } ) 
aAdd( aItens[nLinha] , { "DUA_HOROCO" 	, StrTran(cHorOco,":","") 		, Nil  } ) 
aAdd( aItens[nLinha] , { "DUA_QTDOCO" 	,nQntTPen							, Nil  } ) 


Return(aItens)

//------------------------------------------------------------------------------------------------
/*{Protheus.doc} LmpCaracter()
Remove a caracteres do não.

@param	cTxt	Texto a ter os caracteres especiais removido

@Return cRet 	string sem acentuação.
@author TMS       
@since 	02/10/2013
/*/
//------------------------------------------------------------------------------------------------
Static function LpCaracter(cTxt)

Local cRet := ""
Local nX

For nX := 1 To Len(cTxt)
 If SubStr(cTxt,nX,1) $ "NAO"
 		If SubStr(cTxt,nX,1) == "N"
 			cRet += "N"
 		ElseIf SubStr(cTxt,nX,1) == "A" .Or. SubStr(cTxt,nX,1) == "Ã" 
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "O"
			cRet += "O"
		EndIf
 EndIf
Next nX
Return (cRet)
