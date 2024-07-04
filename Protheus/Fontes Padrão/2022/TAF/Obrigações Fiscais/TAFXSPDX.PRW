#Include "Protheus.ch"
#INCLUDE "FileIO.CH"

#Define _Enter Chr(13) + Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} WrtStrTxt
Funcao responsavel pela gravacao das informacoes configuradas no array
	de depara definido na funcao "DistrCmps"

@Param	aCmps		->  Array com os campos de gravacao conforme registro
		cReg		->	Registro a ser gravadao conforme estrutura do array
		lSeek		->	Variavel para tratamento interno na MACRO casa haja necessidade de se verificar um SEEK qualquer
		aMacro		->	Array com linhas de macro execucao para ser executado na gravacao dos campos antes do input dos valores
		lGrvTabSpd -> Indica se deve gravar a tabela de geracao do Sped ou o arquivo txt
		aInfoGrv   -> Informações necessárias para serem gravadas na tabela
		cChvReg    -> Chave do registro a ser gravado
		
@Return nRet

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0

Altered by Rodrigo Aguilar 
Implementada gravação na tabela temporária de geração dos Speds ao inves de gerar o arquivo magnético
/*/
//-------------------------------------------------------------------
Function WrtStrTxt( nHandle, cString, lGrvTabSpd, aInfoGrv, cChvReg )

Local	nRet	            :=	0
Local  cAliasSpd          := "TAFSPED" + "_" + cEmpAnt //Tabela de informacoes geradas pelos SPED´s
Local  cInsert, cValues   := ""
Local cBanco	:=	Upper( AllTrim( TcGetDB() ) )

Local aBlocoSpd := {}

Default cString	  :=	Nil
Default lGrvTabSpd := .F.
Default cChvReg    := ""

If !lGrvTabSpd
	If cString != Nil .And. !Empty( cString )
		FSeek( nHandle, 0, FS_END )
		nRet	:=	FWrite( nHandle , cString , Len( cString ) )
	EndIf
	
	//Se houver erro na gravacao, nao limpo a variavel
	If nRet != -1
		cString :=	''
	EndIf
Else
	aBlocoSpd := StrToKarr( cString, _Enter )   
		
	For nRet := 1 To Len( aBlocoSpd )	
		If !Empty( aBlocoSpd[nRet] ) 
			
			cInsert := "INSERT INTO " + cAliasSpd + " ( FILIAL, PERINI, PERFIN, BLOCO, REGSEQ, REGISTRO, LINREG, CHAVE ) VALUES "
	
			//Caso não tenha sido enviado gravo a propria indicação do registro como chave
			If Empty( cChvReg )
				cChvReg := SubString( Alltrim( aBlocoSpd[nRet] ), 2, 4 )
			EndIf
					
			//Para o primeiro registro da familia devo gravar o sequencializador enviado na chamada,
			//para os demais devo somar 1 no mesmo, quando o aInfoGrv[5] == 0 eh para o bloco 0
			//deve sempre gerar o sequencializador com 0 
			If nRet > 1 .And. aInfoGrv[5] > 0 
				aInfoGrv[5]++
			EndIf
			
			//Tratamento para adicionar o Pipe ( '|' ) ao final da string de linha do texto
			//pois o comando TCSQLExec está inserindo informações sem o último caracter em ORACLE
			If cBanco == "ORACLE"
				aBlocoSpd[nRet] := Alltrim( aBlocoSpd[nRet] ) + "|"
			EndIf
			
			aBlocoSpd[nRet] := StrTran(aBlocoSpd[nRet], "'", " " )
			
			cValues := "( '" + aInfoGrv[1] + "', '" + aInfoGrv[2] + "', '" + aInfoGrv[3] + "', '" + aInfoGrv[4] + "', '" + StrZero( aInfoGrv[5], 10 ) + "', '" + SubString( Alltrim( aBlocoSpd[nRet] ), 2, 4 ) + "', '" + aBlocoSpd[nRet] + "', '" + Alltrim( cChvReg ) + "')     "                
			
			//Tratamento para quando ocorre erro na gravacao			
			If TcSqlExec( cInsert + SubStr( cValues, 1, Len( cValues ) -  2 ) ) < 0
				Conout( "Erro na gravação do registro na tabela de controle, Instrução: " + TCSQLError() + " --->" + 	cInsert + cValues ) 			
			EndIf
			
		EndIf
	Next
	
	//Limpo a variavel utilizada para grvacao das informações
	cString := ""
	
	//Apenas para que o retorno seja > 0 e nao impactar nos tratamentos no processamento na origem
	nRet := 10
EndIf

Return ( nRet )
//-------------------------------------------------------------------
/*/{Protheus.doc} SaveTxt
Realiza a Gravacao do Arquivo TXT

@param	nHandle -> Handle para gravacao
		cTxtSys -> Arquivo TXT criado pela rotina para gerar o arquivo dentro da System
		cTxtUsu -> Arquivo destino definido pelo usuario
		lArqTemp-> Arquivo .txt temporario, gerado para posterior consolidacao dos dados.
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function SaveTxt( nHandle , cTxtSys , cTxtUsu, lArqTemp )

Local	cDrive		:=	''
Local	cPath		:=	''
Local	cNewFile	:=	''
Local	cExt		:=	''
Local	lCopied		:=	.F.
Local 	cStartPath 	:= 	GetSrvProfString( "StartPath" , "" )
Local	lRet		:=	.F.
Local 	lWebApp		:= Nil 
Default lArqTemp := .f.

If nHandle >= 0
	FClose( nHandle )
Endif

If File( cTxtUsu )		
	FErase( cTxtUsu )
Endif             

SplitPath( cTxtUsu , @cDrive , @cPath , @cNewFile , @cExt )
cNewFile	:=	cNewFile + cExt

If Substr( cStartPath , Len( AllTrim( cStartPath ) ) , 1 ) <> "\"
	cStartPath += '\'
EndIf
	
lWebApp := GetRemoteType() = 5 .and. !lArqTemp
if lWebApp
	if FRename( cStartPath + cTxtSys , cStartPath + cNewFile  ) == 0
		if CpyS2TW(cStartPath + cNewFile, .t.) == 0
			FErase( cNewFile )
			lRet := .t.
		endif	
	endif
else	
	lCopied := iif ( Empty( cDrive ) , __CopyFile( cTxtSys , cDrive + cPath + cNewFile ) , CpyS2T( cStartPath + cTxtSys , cDrive + cPath , .F. ) )
	If lCopied 
		FErase( cTxtSys )
		If File( cDrive + cPath + cTxtSys )
			FRename( cDrive + cPath + cTxtSys , cTxtUsu )
			lRet	:=	.T.
		EndIf
	EndIf
endif	

Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} Val2Str
Funcao responsavel por converter o '.' do resultado do STR() em ',', separador padrao de decimal
exigido no TAF para o arquivo de importacao

@param	nValor	-> 	Valor a ser convertido
		nInt	->	Quantidade de casas inteiras
		nDec	->	Quantidade de decimais
		
@return cRet

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
//-------------------------------------------------------------------
Function Val2Str( nValor , nInt , nDec, lZerNil ) //mauro 

Local cRet := ""

Default lZerNil := .F. 

If Valtype( nValor ) == "C"
	cRet := nValor
Else
	cRet := IIf(nValor==0 .And. lZerNil, '', Alltrim( StrTran( Str( nValor , nInt , nDec ) , '.' , ',' ) )) //mauro
EndIf
	
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Dt2Caract

Funcao responsavel por converter a Data no Formato AAAMMDD para
DDMMAAAA conforme exigido pelo Layout do Sped Fiscal

@param	xData -> Data a ser convertida
		
@return cData

@author Rodrigo Aguilar
@since 14/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function Dt2Caract( xData )	     

Local cData := ""

If ValType( xData )  == "D"
	cData := dToS( xData )//StrTran( DToC( xData ), "/", "" ) 
	cData := Right( cData, 2 ) + SubStr( cData, 5, 2 ) + Left( cData, 4 )
	 
ElseIf ValType( xData )  == "C"
	cData := dToS( cToD( xData ) )
	cData := Right( xData, 2 ) + SubStr( xData, 5, 2 ) + Left( xData, 4 )
	
EndIf

cData := AllTrim( cData )
Return ( cData )

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadString
Funcao responsavel por carregar as informacoes em uma string jah no formato de gravacao do arquivo
	de saida baseado no array de depara definido na funcao "DistrCmps"

@param	cReg	->	Registro a ser gravadao conforme estrutura do array
		aCmps	->  Array com os campos de gravacao conforme registro
		cString -> 	Variavel que receberah a string montada
		cAliasQry-> Alias principal dos campos defnidos no 'aCmps'	
		lSeek	->	Variavel para tratamento interno na MACRO casa haja necessidade de se verificar um SEEK qualquer
		aMacro	->	Array com linhas de macro execucao para ser executado na gravacao dos campos antes do input dos valores
		aRegProc->  Array com as informacoes a serem processada, caso nao esteja em campos direto da tabela. Ex: Registros Consolidados
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function LoadString( cReg , aCmps , cString , cAliasQry , lSeek , aMacro , aRegProc , lFirstPos )

Local	nPos		:=	0
Local	nX			:=	0
Local	nY			:=	0
Local	cAlias		:=	''
Local	cDelimit	:=	'|'

Default	cString	:=	''
Default	lSeek	:=	.T.
Default	aMacro	:=	{}
Default	aRegProc:=	Nil

If ( nPos := aScan( aCmps , {| aX | aX[ 1 ] == cReg } ) ) > 0
	If ValType( aRegProc ) # 'U'
		If Len( aRegProc ) > 0
			
			cString	+=	cDelimit + aCmps[ nPos , 1 ] + cDelimit
			
			For nX := 1 To Len( aRegProc )
				For nY := 1 To Len( aCmps[ nPos , 2 ] )
					
					If Empty( cAliasQry )
						cString	+=	AllTrim( Eval( aCmps[ nPos , 2 , nY ] ) )
					Else
						cString	+=	AllTrim( ( cAliasQry )->( Eval( aCmps[ nPos , 2 , nY ] ) ) )
					EndIf
		
					cString	+=	cDelimit
				Next nY
			Next nX
			
			cString	+=	CRLF
		EndIf
	Else
		cString	+=	cDelimit + aCmps[ nPos , 1 ] + cDelimit
		For nX := 1 To Len( aCmps[ nPos , 2 ] )
	
			If Empty( cAliasQry )
				cString	+=	AllTrim( Eval( aCmps[ nPos , 2 , nX ] ) )
			Else
				cString	+=	AllTrim( ( cAliasQry )->( Eval( aCmps[ nPos , 2 , nX ] ) ) )
			EndIf
			
			cString	+=	cDelimit
		Next nX
		cString	+=	CRLF
	EndIf
EndIf

Return ( Nil )    

//-------------------------------------------------------------------
/*/{Protheus.doc} Bloco9

Realiza a Geracao do Bloco 9 - Controle e Encerramento do Arquivo Digital

@Param	aTotReg   -> Array com os totalizadores do Registro do Sped Fiscal
		nHdlTxt   -> Handle do Arquivo criado	
		lUtlTabSt -> Indica se o processamento utiliza a tabela temporaria
		cTabSped  -> Alias da tabela temporaria
		cFilSel   -> Filiais selecionadas para o processamento
		aWizard   -> Informações da Wizard
					
@Return ( Nil )

@author Rodrigo Aguilar
@since 10/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function Bloco9( aTotReg, nHdlTxt, lUtlTabSt, cTabSped, cFilSel, aWizard )                                    

Local cString    := "" 
Local cSelect    := ""
Local cFrom      := "" 
Local cGroupBy   := "" 
Local cOrderBy   := ""
Local cStringBc1 := ""
Local cAliasQry  := ""
    
Local cDelimit  := "|"

Local aInfoGrv := {}

Local lGer9001    := .F.
Local nContBloc9  := 3  
Local nCont9900   := 3  
Local nContSpd    := 1

Local nlI := 1  
Local nlY := 1   

Default lUtlTabSt := .F.

//Tratamento para quando o processamento nao utiliza a tabela de controle para geração do Sped			
If !lUtlTabSt				
	For nlI := 1 To Len( aTotReg )
		For nlY := 1 To Len( aTotReg[nlI] )
			If aTotReg[nlI][nlY][2] > 0
				
				If !lGer9001 
					cString += cDelimit
					cString += "9001" + cDelimit         								//01 - REG   
					cString += "0" + cDelimit  											//02 - INDMOV				
					cString	+= CRLF
					WrtStrTxt( nHdlTxt , @cString )	
					
					lGer9001 := .T.
				EndIf
				
				cString += cDelimit
				cString += "9900" + cDelimit         						   									//01 - REG   
				cString += aTotReg[nlI][nlY][1] + cDelimit  		 											//02 - REG_BLC	
				cString += Alltrim( Transform( aTotReg[nlI][nlY][2], "@E 99999999999999" ) ) + cDelimit  	    //03 - QTD_REG_BLC	
				cString	+= CRLF
				WrtStrTxt( nHdlTxt , @cString )	
						
				nContSpd += aTotReg[nlI][nlY][2]
							
				nCont9900++		
			EndIf
		Next
	Next
	
	If !lGer9001 
		cString += cDelimit
		cString += "9001" + cDelimit         						   						//01 - REG   
		cString += "1" + cDelimit  							 								//02 - INDMOV			
	Else
	
		cString += cDelimit
		cString += "9900" + cDelimit         						   				 		//01 - REG   
		cString += "9001" + cDelimit  		 										 		//02 - REG_BLC	
		cString += "1" + cDelimit  	    											 		//03 - QTD_REG_BLC	
		cString	+= CRLF
		WrtStrTxt( nHdlTxt , @cString )					
		//nCont9900++ 
		
		nContBloc9 += nCont9900	
		
		cString += cDelimit
		cString += "9900" + cDelimit         						   				 		//01 - REG   
		cString += "9900" + cDelimit  		 										 		//02 - REG_BLC	
		cString += Alltrim( Transform( nCont9900, "@E 99999999999999" ) ) + cDelimit  	    //03 - QTD_REG_BLC	
		cString	+= CRLF
		WrtStrTxt( nHdlTxt , @cString )					
						
		cString += cDelimit
		cString += "9900" + cDelimit         						   				 		//01 - REG   
		cString += "9990" + cDelimit  		 										 		//02 - REG_BLC	
		cString += "1" + cDelimit  	    											 		//03 - QTD_REG_BLC	
		cString	+= CRLF
		WrtStrTxt( nHdlTxt , @cString )					
	
		cString += cDelimit
		cString += "9900" + cDelimit         						   				 		//01 - REG   
		cString += "9999" + cDelimit  		 										 		//02 - REG_BLC	
		cString += "1" + cDelimit  	    											 		//03 - QTD_REG_BLC	
		cString	+= CRLF
		WrtStrTxt( nHdlTxt , @cString )					
		
	EndIf       
	
	cString += cDelimit
	cString += "9990" + cDelimit         						   							//01 - REG   
	cString += Alltrim( Transform( nContBloc9+1, "@E 99999999999999" ) ) + cDelimit  	    //02 - QTD_LIN_9	
	cString	+= CRLF
	WrtStrTxt( nHdlTxt , @cString )	  
	
	nContSpd += nContBloc9				                    
	
	cString += cDelimit
	cString += "9999" + cDelimit         						   							//01 - REG   
	cString += Alltrim( Transform( nContSpd, "@E 99999999999999" ) ) + cDelimit  	    	//02 - QTD_LIN_9	
	cString	+= CRLF
	WrtStrTxt( nHdlTxt , @cString )	 

//Tabela Compartilhada - Geracao do bloco 9
Else

	cAliasQry := GetNextAlias() 

	//No caso do Sped Fiscal apenas pode ser gerada uma filial por processamento, sendo assim, antes de iniciar a execução dos blocos
	//eu seto a filial onde ocorrera o processamento
	//cFilAnt := Substr( cFilSel, 2, 2 )

	//Array com as informações a serem geradas na tabela compartilhada
	//Filial + Data Inicio + Data Final + Bloco + Sequencializador
	aInfoGrv := { cFilAnt , DToS( aWizard[1,1] ), DToS( aWizard[1,2] ), "9", 0 }

	cSelect  := "% REGISTRO, COUNT(*) TOTAL %"
	cFrom    := "% " + cTabSped + " CTABSPED %"
	cWhere   := "% FILIAL = '" + cFilAnt + "' AND PERINI = '" + DToS( aWizard[1,1] ) + "' AND PERFIN = '" + DToS( aWizard[1,2] ) + "' AND CTABSPED.D_E_L_E_T_ <> '*' %"    
	cGroupBy := "% REGISTRO %" 
	cOrderBy := "% REGISTRO %"
	
	BeginSql Alias cAliasQry                
	    SELECT							
		    %Exp:cSelect%
	    FROM 
	        %Exp:cFrom% 
	    WHERE
	    	%Exp:cWhere%
		GROUP BY
			%Exp:cGroupBy%   
		ORDER BY
			%Exp:cOrderBy%		
	EndSql    
	
	//Geração do Registro 9001 na tabela compartilhada
	cString := cDelimit
	cString += "9001" + cDelimit   //01 - REG   
	cString += "0" + cDelimit  	   //02 - INDMOV				
	cString += CRLF
	
	aInfoGrv[5]++
	WrtStrTxt(  , @cString, .T., @aInfoGrv )
			
	While (cAliasQry)->( !Eof() )

		If SubStr( (cAliasQry)->REGISTRO, 1, 1 ) <> "1" 
			
			//Geração do Registro 9900 na tabela compartilhada
			cString := cDelimit
			cString += "9900" + cDelimit         						   									//01 - REG   
			cString += Alltrim( (cAliasQry)->REGISTRO ) + cDelimit  		 							//02 - REG_BLC	
			cString += Alltrim( Transform( (cAliasQry)->TOTAL, "@E 99999999999999" ) ) + cDelimit  //03 - QTD_REG_BLC	
			cString += CRLF
			
			aInfoGrv[5]++
			WrtStrTxt(  , @cString, .T., @aInfoGrv )	
		Else
		
			COnout( (cAliasQry)->REGISTRO + "2"  )
			//O bloco 1 deve ser o ultimo registro a ser gravado de acordo com a ordem do Layout
			//devido a isso eh realizado este tratamento
			cStringBc1 += cDelimit
			cStringBc1 += "9900" + cDelimit         						   									//01 - REG   
			cStringBc1 += Alltrim( (cAliasQry)->REGISTRO ) + cDelimit  			 							//02 - REG_BLC	
			cStringBc1 += Alltrim( Transform( (cAliasQry)->TOTAL, "@E 99999999999999" ) ) + cDelimit   //03 - QTD_REG_BLC	
			cStringBc1 += CRLF 
		EndIf	
		
		//Totalizador do Arquivo Magnetico Completo
		nContSpd += (cAliasQry)->TOTAL					
		
		(cAliasQry)->( DbSkip() )
	EndDo   
	(cAliasQry)->( DbCloseArea() )
	
	//Realizo a gravacao das informações de totalizadores geradas para o Bloco 1
	aInfoGrv[5]++
	WrtStrTxt(  , @cStringBc1, .T., @aInfoGrv )	
	
	//Geração do Registro 9900 na tabela compartilhada para o registro 9901
	cString := cDelimit
	cString += "9900" + cDelimit        //01 - REG   
	cString += "9001" + cDelimit  		 //02 - REG_BLC	
	cString += "1" + cDelimit  	    	//03 - QTD_REG_BLC	
	cString += CRLF
	
	aInfoGrv[5]++
	WrtStrTxt(  , @cString, .T., @aInfoGrv )
	
	//Geração do Registro 9900 na tabela compartilhada para o registro 9900
	cString := cDelimit
	cString += "9900" + cDelimit         						   				 				 //01 - REG   
	cString += "9900" + cDelimit  		 										 				 //02 - REG_BLC	
	cString += Alltrim( Transform( aInfoGrv[5] + 2, "@E 99999999999999" ) ) + cDelimit   //03 - QTD_REG_BLC	
	cString += CRLF
	
	aInfoGrv[5]++
	WrtStrTxt(  , @cString, .T., @aInfoGrv )	
	
	//Geração do Registro 9900 na tabela compartilhada para o registro 9990
	cString := cDelimit
	cString += "9900" + cDelimit         						   				 		//01 - REG   
	cString += "9990" + cDelimit  		 										 		//02 - REG_BLC	
	cString += "1" + cDelimit  	    											 		//03 - QTD_REG_BLC	
	cString += CRLF
	
	aInfoGrv[5]++
	WrtStrTxt(  , @cString, .T., @aInfoGrv )					
	
	//Geração do Registro 9900 na tabela compartilhada para o registro 9999
	cString := cDelimit
	cString += "9900" + cDelimit         						   				 		//01 - REG   
	cString += "9999" + cDelimit  		 										 		//02 - REG_BLC	
	cString += "1" + cDelimit  	    											 		//03 - QTD_REG_BLC	
	cString += CRLF
	
	aInfoGrv[5]++
	WrtStrTxt(  , @cString, .T., @aInfoGrv )		
	
	//Geração do Registro 9990 na tabela compartilhada 
	cString := cDelimit
	cString += "9990" + cDelimit         						   							   //01 - REG   
	cString += Alltrim( Transform( aInfoGrv[5] + 2, "@E 99999999999999" ) ) + cDelimit //02 - QTD_LIN_9	
	cString	+= CRLF
	
	aInfoGrv[5]++
	WrtStrTxt(  , @cString, .T., @aInfoGrv )	  
	
	//Geração do Registro 9999 na tabela compartilhada 			                    
	cString := cDelimit
	cString += "9999" + cDelimit         						   							     //01 - REG   
	cString += Alltrim( Transform( nContSpd + aInfoGrv[5], "@E 99999999999999" ) ) + cDelimit   //02 - QTD_LIN_9	
	cString += CRLF
		
	aInfoGrv[5]++
	WrtStrTxt(  , @cString, .T., @aInfoGrv )
				
Endif

				   
Return ( Nil )     

//-------------------------------------------------------------------
/*/{Protheus.doc}     

@author Fabio V. Santana
@since	22/02/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function FGerBloco(nHdlTxt,cReg,aInfo,nQtdReg)

Local 	cString		:= ""
Local 	cDelimit 	:= "|"
Local 	nCont		:= 1   
Local 	bBlock		:= {|xVar| cString += (AllTrim(xVar) + cDelimit) }

Default aInfo		:= {}  
Default nQtdReg		:= 0

cString += cDelimit
cString += cReg + cDelimit   
If !Empty(aInfo)
	aEval(aInfo,bBlock)        
EndIf 
cString += CRLF      
     
WrtStrTxt( nHdlTxt , @cString ) 
nQtdReg++

Return Nil 


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFConType 

@author Fabio V. Santana
@since	22/02/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFConType(xValor,nTam)

Local cNovo    := ""

If nTam==Nil
	xValor := AllTrim(xValor)
EndIf
DEFAULT nTam := 60
If FindFunction( "FWNoAccent" )
	cNovo := AllTrim( EnCodeUtf8( FWNoAccent( SubStr( xValor , 1 , nTam ) ) ) )
Else
	cNovo := AllTrim( EnCodeUtf8( NoAcento( SubStr( xValor , 1 , nTam ) ) ) )
Endif

//Tratamento para que quando o cliente utilize "'" em seus campos de descrição seja incluído um
//"'" a mais, pois o banco de dados considera apenas um "'" e não ocorre erro de sintaxe,
//caso ocorra problema para algum banco específico NÃO RETIRE ESSA VALIDAÇÃO mas sim analise uma
//solução alternativa 
cNovo := StrTran( cNovo, "'", "''" )

Return(cNovo)

//-------------------------------------------------------------------
/*/{Protheus.doc} VldIE 

@author Fabio V. Santana
@since	22/02/2013 
@version 1.0

/*/
//-------------------------------------------------------------------
Function VldIE(cInsc,lContr,lIsent)

Local 		cRet	:=	""
Local 		nI		:=	1
Default 	lContr  :=	.T.
Default		lIsent	:=	.T.

For nI:=1 To Len(cInsc)
	If Isdigit(Subs(cInsc,nI,1)) .Or. IsAlpha(Subs(cInsc,nI,1))
		cRet+=Subs(cInsc,nI,1)
	Endif
Next
cRet := AllTrim(cRet)

If lIsent
	If "ISENT"$Upper(cRet)
		cRet := ""
	EndIf
	If !(lContr) .And. !Empty(cRet)
		cRet := "ISENTA"
	EndIf
EndIf 

Return(cRet)  

//-------------------------------------------------------------------
/*/{Protheus.doc} ZeraTrib

@param
@return NIL

@author Fabio V. Santana
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function ZeraTrib( aTribIte )

aTribIte   := {"",;  // 01 -CST_ICMS 
		  0,;  // 02 - VL_BC_ICMS
		  0,;  // 03 - ALIQ_ICMS
		  0,;  // 04 - VL_ICMS
		  0,;  // 05 - VL_BC_ICMS_ST
		  0,;  // 06 - ALIQ_ST
		  0,;  // 07 - VL_ICMS_ST
		  "",; // 08 - CST_IPI
		  0,;  // 09 - VL_BC_IPI
		  0,;  // 10 - ALIQ_IPI
		  0,;  // 11 - VL_IPI
		  "",; // 12 - CST_PIS
		  0,;  // 13 - VL_BC_PIS
		  0,;  // 14 - ALIQ_PIS
		  0,;  // 15 - QUANT_BC_PIS
		  0,;  // 16 - ALIQ_PIS_QUANT
		  0,;  // 17 - VL_PIS
		  "",; // 18 - CST_COFINS
		  0,;  // 19 - VL_BC_COFINS
		  0,;  // 20 - ALIQ_COFINS
		  0,;  // 21 - QUANT_BC_COFINS
		  0,;  // 22 - ALIQ_COFINS_QUANT
		  0,;  // 23 - VL_COFINS   
		  0,;  // 24 - VL_ISS
		  0,;  // 25 - VL_RET_PIS
		  0,;  // 26 - VL_RET_COF
		  0,;  // 27 - VL_PIS_ST
		  0,;  // 28 - VL_COF_ST  
		  0,;  // 29 - VALOR TOTAL DOS ITENS  
		  0,;  // 30 - VALOR DO DESCONTO
		  0,;  // 31 - VALOR DO ITEM DOC. ECF - PIS/PASEP			
		  0}   // 32 - VALOR DO ITEM DOC. ECF - COFINS

Return (aTribIte)      

// ------------------------------------------------------------------
/*/{Protheus.doc} TaFContBlc

@author Fabio V. Santana
@since	22/02/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TaFContBlc(cReg,aTotReg)

Local nPos	:= 0             

If Len( aTotReg ) <= 0 .Or. ( nPos := aScan( aTotReg, { |x| x[1] == cReg } ) ) <= 0
	Aadd( aTotReg,  { cReg, 0 }  )
	nPos := Len( aTotReg )
EndIf                      	
aTotReg[nPos][2] +=1	           

Return (aTotReg)   

//-------------------------------------------------------------------
/*/{Protheus.doc} xConsSped
Realiza a busca das informaçoes na tabela de controle e realiza a geração do
arquivo magnético do Sped

@Param
aWizard    - Informações de Wizard
nHdlTxt    - Handle para gravação do arquivo texto
cFilsel    - Filiais de seleção do processamento
cTabSped   - Nome da tabela onde são gravadas as informações dos Speds
cSpedAlias - Alias da tabela onde são gravadas as informações dos Speds 

@Return ( Nil )

@author Rodrigo Aguilar
@since 25/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function xConsSped( aWizard, nHdlTxt, cFilsel, cTabSped, cSpedAlias )

Local cSelect  := ""
Local cFrom    := ""
Local cWhere   := ""
Local cOrderBy := ""

Local nI := 0

Local cAliasQry := ""

//No caso do Sped Fiscal apenas pode ser gerada uma filial por processamento, sendo assim, antes de iniciar a execução dos blocos
//eu seto a filial onde ocorrera o processamento
cFilSel := Substr( Alltrim(cFilSel), 2, Len( Alltrim(cFilSel) ) - 2 )

//Montando a query para buscar as informações de geração, os blocos 1 e 9 não são gerados neste momento devido
//a ordenação do comando OrderBy
cSelect  := "% R_E_C_N_O_ %"
cFrom    := "% " + cTabSped + " CTABSPED %"   
cOrderBy := "% BLOCO, CHAVE, REGSEQ, REGISTRO %"

//Realizo a execução da query a primeira vez para geracao de todos os blocos exceto o 1 e 9
//devido a ordenação de geração que o Sped pede, a segundo vez gero apenas o 1 e o 9
For nI := 1 To 2
	
	//Tratamento das querys
	cWhere   := "% FILIAL = '" + cFilSel + "' AND PERINI = '" + DToS( aWizard[1,1] ) + "' AND PERFIN = '" + DToS( aWizard[1,2] ) + "' "
	If nI == 1
		cWhere += " AND BLOCO <> '1' AND BLOCO <> '9' %"		
	Else
		cWhere += " AND ( BLOCO = '1' OR BLOCO = '9' ) %"
	EndIf
	
	//Execução da Query
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry                
	    SELECT							
		    %Exp:cSelect%
	    FROM 
	        %Exp:cFrom% 
		WHERE
			%Exp:cWhere%
		ORDER BY
			%Exp:cOrderBy%		
	EndSql   
	
	//Laço para geração do Arquivo Texto
	While (cAliasQry)->( !Eof() )
		
		//Posiciono no registro para geração da informação
		(cSpedAlias)->( DbGoTo( (cAliasQry)->( R_E_C_N_O_ ) ) )
				
		//Em alguns Bancos ( Oracle 11g por exemplo ) o ultimo pipe
		//não esta senodo gravado, assim, esse tratamento garante que o
		//registro sera gerado corretamente no arquivo magnético				
		cLineReg := Alltrim( (cSpedAlias)->LINREG )
		If Right( cLineReg, 1 ) <> "|"
			cLineReg += "|"
		EndIf
		
		//Gravo a informação no arquivo texto
		WrtStrTxt( nHdlTxt, cLineReg + CRLF ) 
		
		(cAliasQry)->( DbSkip() )
	EndDo
	(cAliasQry)->( DbCloseArea() )

Next
	
Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} xGerBlc0
Função Genérica para geração dos registros referentes ao bloco 0 dos Speds, 
os mesmos são gerados de acordo com o processento dos demais blocos da
obrigação

@Param
cReg     - Nome do Registro
cChave   - Chave do Registro
cFilSel  - Filial selecionada
aWizard  - Wizard de configuração
cTabSped - Alias da Tabela
cUnNF    - Unidade utiliza na nota fiscal para geração do registro 0220

@Return ( cChave )

@author Rodrigo Aguilar
@since 25/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function xGerBlc0( cReg, cChave, cFilSel, aWizard, cTabSped, cUnNF )

Local cSelect := ""
Local cFrom   := ""
Local cWhere  := ""
Local cWhere  := ""

Local lFindReg := .F.
Local aInfoGrv := {}

If !Empty( cChave )

	//No caso do Sped Fiscal apenas pode ser gerada uma filial por processamento, sendo assim, antes de iniciar a execução dos blocos
	//eu seto a filial onde ocorrera o processamento
	//cFilAnt := Substr( cFilSel, 2, 2 )
		
	cChave := Alltrim( cChave )
	cReg   := Alltrim( cReg )
	
	cSelect  := "% REGISTRO %"
	cFrom    := "% " + cTabSped + " %"
	cWhere   := "% REGISTRO ='" + cReg + "' AND CHAVE = '" + ( cReg + cChave ) + "' AND "
	cWhere   += "FILIAL = '" + cFilAnt + "' AND PERINI = '" + DToS( aWizard[1,1] ) + "' AND PERFIN = '" + DToS( aWizard[1,2] ) + "' %"
	
	cAliasQry := GetNextAlias()
	
	BeginSql Alias cAliasQry                
	    SELECT							
		    %Exp:cSelect%
	    FROM 
	        %Exp:cFrom% 		
		WHERE
			%Exp:cWhere%	        
	EndSql   
	
	lFindReg := (cAliasQry)->( Eof() )
	(cAliasQry)->( DbCloseArea() ) 
	
	If lFindReg
		
		//Array com as informações a serem geradas na tabela compartilhada
		//Filial + Data Inicio + Data Final + Bloco + Sequencializador
		aInfoGrv := { cFilAnt , DToS( aWizard[1,1] ), DToS( aWizard[1,2] ), "0",  0 }
			
		If cReg == "0150"
			
			//Geração do Registro 0150/0175
			R0150R0175( cFilSel, aWizard, cChave, aInfoGrv )
				
		ElseIf cReg == "0190"
			
			//Geração do Registro 0190
			Reg0190Spd( cFilSel, aWizard, cChave, aInfoGrv )
			
		ElseIf cReg == "0200"
			
			//Geração do Registro 0200
			R0200R0205( cFilSel, aWizard, cChave, aInfoGrv, cUnNF, cTabSped )
			
		ElseIf cReg == "0300"
			
			//Geração do Registro 0300
			R0300R0305( cFilSel, aWizard, cChave, aInfoGrv, ,cTabSped )
			
		ElseIf cReg == "0400"
			
			//Geração do Registro 0400
			Reg0400Spd( cFilSel, aWizard, cChave, aInfoGrv )				
	
		ElseIf cReg == "0450"
			
			//Geração do Registro 0450
			Reg0450Spd( cFilSel, aWizard, cChave, aInfoGrv )
	
		ElseIf cReg == "0460"
			
			//Geração do Registro 0460
			Reg0460Spd( cFilSel, aWizard, cChave, aInfoGrv )
	
		ElseIf cReg == "0500"
			
			//Geraço do Registro 0500
			Reg0500Spd( cFilSel, aWizard, cChave, aInfoGrv )	
	
		ElseIf cReg == "0600"
			
			//Geraço do Registro 0600
			Reg0600Spd( cFilSel, aWizard, cChave, aInfoGrv )
				
		EndIf
			
	EndIf	
EndIf			

Return ( cChave )

 */
//-------------------------------------------------------------------
/*/{Protheus.doc} Reg990Spd
Realiza a Emissao dos encerramentos dos blocos dos Speds

@Param		cBloco    -> Bloco a ser encerrado
			cTabSped  -> Alias da Tabela
			cFilSel   -> Filial a ser processada      
			aWizard   -> Alias da Tabela
			
@Return ( Nil )

@author Rodrigo Aguilar
@since 15/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function Reg990Spd( cBloco, cTabSped, cFilSel, aWizard )                                    

Local cSelect := ""
Local cFrom   := ""
Local cWhere  := ""
Local cWhere  += ""

Local cCodTot   := ""    
Local cStrTxt   := ""
Local cDelimit  := "|"   

Local aInfoGrv  := {}

Local cAliasQry := GetNextAlias()

//No caso do Sped Fiscal apenas pode ser gerada uma filial por processamento, sendo assim, antes de iniciar a execução dos blocos
//eu seto a filial onde ocorrera o processamento
//cFilAnt := Substr( cFilSel, 2, 2 )

//Array com as informações a serem geradas na tabela compartilhada
//Filial + Data Inicio + Data Final + Bloco + Sequencializador
aInfoGrv := { cFilAnt , DToS( aWizard[1,1] ), DToS( aWizard[1,2] ), cBloco, 0 }

cSelect  := "% COUNT( REGISTRO ) TOTAL %"
cFrom    := "% " + cTabSped + " %"
cWhere   := "% BLOCO ='" + cBloco + "' AND "
cWhere   += "FILIAL = '" + cFilAnt + "' AND PERINI = '" + DToS( aWizard[1,1] ) + "' AND PERFIN = '" + DToS( aWizard[1,2] ) + "' %"

BeginSql Alias cAliasQry                
    SELECT							
	    %Exp:cSelect%
    FROM 
        %Exp:cFrom% 		
	WHERE
		%Exp:cWhere%	        
EndSql

If 	(cAliasQry)->( !Eof() )			
	cStrTxt := cDelimit
	cStrTxt += cBloco + "990" + cDelimit                  		    	//01 - REG  		
	cStrTxt += Val2Str( (cAliasQry)->TOTAL + 1, 20, 0 )  + cDelimit   //02 - QTD_LIN_0
	cStrTxt += CRLF			

	cCodTot := cBloco + "990" 
	WrtStrTxt( , @cStrTxt, .T., aInfoGrv, cCodTot )
EndIf			
(cAliasQry)->( dbCloseArea() )
	
Return ( Nil )
//---------------------------------------------------------------------
/*/{Protheus.doc} TAFGetEnd

Retorna a estrutura do endereco passado.

@Param cEndereco -> Endereco completo
       cUF       -> UF do endereço

@Return 1 - Endereco
        2 - Numero ( N )
        3 - Numero ( C )
        4 - Complemento

@Author Felipe C. Seolin (Copiada de MATA950)
@Since 27/06/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFGetEnd( cEndereco, cUF )

Local cNumero    := ""
Local cEnderec   := ""
Local cCompl     := ""
Local cComplemen := ""
Local nVirgula   := Rat( ",", cEndereco )
Local nNumero    := 0
Local aNumStr    := {}
Local lEndNfe    := If( FunName() == "SPEDNFE", .T., .F. )
Local lExterior  := .F.

Default cUF      := ""

lExterior := ( cUF == "EX" )

cNumero    := If( !lExterior, AllTrim( SubStr( cEndereco, nVirgula + 1 ) ), Left( cEndereco, nVirgula - 1 ) )
nNumero    := NoRound( Val( cNumero ), 3 )
cCompl     := If( !lExterior, AllTrim( SubStr( cEndereco, nVirgula + 1 ) ), Left( cEndereco, nVirgula - 1 ) )
cComplemen := ""

If lEndNfe
	If nNumero <> 0
		If !lExterior
			cEnderec := PadR( SubStr( cEndereco, 1, nVirgula - 1 ), 60 )
		Else
			cEnderec := PadR( LTrim( SubStr( cEndereco, nVirgula + 1 ) ), 60 )
		EndIf
	Else
		cEnderec := PadR( cEndereco, 60 )
	EndIf
Else
	If nNumero <> 0
		If !lExterior
			cEnderec := PadR( SubStr( cEndereco, 1, nVirgula - 1 ), 34 )
		Else
			cEnderec := PadR( LTrim( SubStr( cEndereco, nVirgula + 1 ) ), 34 )
		EndIf
	Else
		cEnderec := PadR( SubStr( cEndereco, 1, nVirgula - 1 ), 34 )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando nao ha virgula no endereco procura-se o caracter branco³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nVirgula == 0 )
	nVirgula := Rat( " ", AllTrim( cEndereco ) )
	cEnderec := RTrim( cEndereco )
	cCompl   := "" //NAO TEM COMO PEGAR O COMPLEMENTO, JAH QUE UTILIZO O ULTIMO ESPACO A DIREITO PARA SEPARAR O LOGRADOURO DO NUMERO.
	cNumero  := AllTrim( SubStr( cEndereco, nVirgula + 1 ) )
	aNumStr  := RetNumTaf( cNumero )

	If Len( aNumStr[1] ) > 1
		cNumero := "S/N"
	EndIf

	nNumero := Val( cNumero )

	If lEndNfe == .F.
		lEnderec := PadR( IIf( nNumero <> 0, SubStr( cEndereco, 1, nVirgula - 1 ), cEndereco ), 34 )
	Else
		lEnderec := PadR( IIf( nNumero <> 0, SubStr( cEndereco, 1, nVirgula - 1 ), cEndereco), 60 )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando o numero é numerico, obtem-se o complemento            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nNumero <> 0
	If At( " ", AllTrim( cCompl ) ) > 0
		cComplemen := AllTrim( SubStr( cCompl, At( " ", AllTrim( cCompl ) ) + 1 ) )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para o numero caracter extrai o complemmento.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNumero := StrTran( cNumero, cComplemen, "" )

Return( { cEnderec, nNumero, cNumero, cComplemen } )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFGetTel

Retorna a estrutura do telefone passado.

@Param cTelefone -> Texto do Telefone
       cArea     -> Codigo de Area
       cPais     -> Codigo do Pais

@Return 1 - Codigo do Pais
        2 - Codigo de Area
        3 - Telefone

@Author Felipe C. Seolin (Copiada de MATA950)
@Since 27/06/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFGetTel( cTelefone, cArea, cPais )

Local nX      := 0
Local nCount  := 0
Local cAux    := ""
Local cNumero := ""
Local lFone   := .T.
Local lArea   := .F.
Local lPais   := .F.

Default cArea := ""
Default cPais := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico o que deve ser extraido do numero do telefone        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lArea     := Empty( cArea )
lPais     := Empty( cPais ) .and. lArea
cTelefone := AllTrim( cTelefone )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtenho o codigo de pais/area e telefone do Telefone          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := Len( cTelefone ) to 1 Step - 1
	nCount ++
	cAux := SubStr( cTelefone, nX, 1 )

	If cAux >= "0" .and. cAux <= "9"
		Do Case
			Case lFone
				cNumero := cAux + cNumero
			Case lArea
				cArea := cAux + cArea
			Case lPais
				cPais := cAux + cPais
		EndCase

		If nCount == 9
			lFone := .F.
		EndIf
	Else
		Do Case
			Case lFone
				If Len( cNumero ) > 5
					lFone := .F.
				EndIf
			Case lArea
				If !Empty( cArea )
					lArea := .F.
				EndIf
		EndCase
	EndIf
Next nX

Return( { Val( cPais ), Val( cArea ), Val( cNumero ) } )


//-------------------------------------------------------------------
/*/{Protheus.doc} RetNumTaf
Funcao que retorna valores numericos e strings de um texto separado.
@param	cTexto	-> Texto para separar os tipos de caracteres
@return	aRet	-> Array que possui duas posicoes:
                   1 - Conteudos Caracteres
                   2 - Conteudos numericos
@author	Denis R Oliveira
/*/
//-------------------------------------------------------------------
Static Function RetNumTaf(cTexto)

Local nX		:= 0
Local aRet		:= {"",""}
Local cVar		:= ""
Local cVarFil	:= AllTrim(cTexto)
Local nTamTxt	:= Len(cVarFil)

For nX := 1 To nTamTxt
	cVar	:= SubStr(cVarFil,1,1)
	cVarFil	:= SubStr(cVarFil,2)
	If Empty(cVar)
		Loop
	ElseIf cVar <> "0" .And. Val(cVar) = 0
		aRet[1] += cVar
	Else
		aRet[2] += cVar
	EndIf
Next

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} ConvYesNo

Converte Opções de Combo 1/2 para S/N

@Param cOpc - String com a Opção no formato 1/2

@Return String com a Opção no formato S/N

@Author Evandro dos Santos Oliveira
@Since 11/02/2015
/*/
//---------------------------------------------------------------------
Function ConvYesNo(cOpc)

	Local cRet := ""
	
	cRet := IIf(cOpc == "1","S",IIf(cOpc == "2","N",""))

Return cRet
