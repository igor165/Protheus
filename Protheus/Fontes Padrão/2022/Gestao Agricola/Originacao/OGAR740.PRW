#INCLUDE "TOTVS.CH"
#INCLUDE "VKEY.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "OGAR740.CH"

/*/{Protheus.doc} OGAR740
Programa de impressão do certificado de peso dos contêineres da intrução de embarque.
@type  Function
@author rafael.voltz
@since 05/01/2018
@version 1.0
@param param, param_type, param_descr
@return returno,return_type, return_description
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=318604330
/*/
Function OGAR740(cContrato, cCodNegc, cVerNegc)
	Local aAdvSize	   := {}
	Local aInfoAdvSize := {}
	Local aObjSize	   := {}
	Local aObjCoords   := {}
	Local aGDCoord	   := {}

	Private oDlg	   := NIL
	Private	cPerg	   := "OGAR740"	
	Private _cContrato := cContrato
	Private _cCodNegc  := cCodNegc 
	Private _cVerNegc  := cVerNegc	
	Private _cUnProd   := ""

	If validGer() //Externo
		//Carrega os paremetros da impressão conforme dados das perguntas(OGAR740)
		Pergunte(cPerg,.F.)

		//*===========================================================================================================================================
		//*	Monta as Dimensoes dos Objetos                					           					    					  
		//*===========================================================================================================================================
		aAdvSize	 := MsAdvSize()
		aAdvSize[5]	 := (aAdvSize[5]/100) * 60	//horizontal
		aAdvSize[6]	 := (aAdvSize[6]/100) * 40	//Vertical
		aInfoAdvSize := { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
		
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )
		aGdCoord := { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*20), (((aObjSize[1,4])/100)*59) }	//1,3 Vertical /1,4 Horizontal

		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL //"Integração Com Ms-word"
		
		@ aGdCoord[1],aGdCoord[2] TO aGdCoord[3],aGdCoord[4]   PIXEL
		@ aGdCoord[1]+10,aGdCoord[2]+10 SAY OemToAnsi(STR0002) PIXEL //"Impressão de documentos no Word."
		@ aGdCoord[1]+20,aGdCoord[2]+10 SAY OemToAnsi(STR0003) PIXEL //"O arquivo será impresso de acordo com a seleção dos parâmetros."

		@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)-95 BMPBUTTON TYPE 5 ACTION Eval( { || Pergunte(cPerg,.T.) } )
		@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)-60 BUTTON OemToAnsi(STR0027) SIZE 55,11 ACTION fVarW_Imp()	 			 //"Impr. _Variáveis"
		@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)+5  BUTTON OemToAnsi(STR0004) SIZE 55,11 ACTION Eval( { || GerBoleta()}) //"Impr. _Documento"
		@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)+70 BMPBUTTON TYPE 2 ACTION Close(oDlg)	

		ACTIVATE DIALOG oDlg CENTERED		
	EndIf

Return()

Static Function GerBoleta()

	Processa({|| WordImp()},"Aguarde. Gerando documento.")	

Return 

/*/{Protheus.doc} WordImp()
Função principal de impressão do arquivo word.
@type  Function
@author rafael.kleestadt	
@since 29/12/2017
@version 1.0
@param param, param_type, param_descr
@return return,return_type, return_description
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=318604330
/*/
Static Function WordImp()
	Local aCnts    := {}
	Local aCampos  := {}
	Local nX       := 0
	Local cArqWord := mv_par01
	Local cDestino := mv_par02
	Local cNN8Memo := ""
	Private oWord  := Nil

		If Empty(cArqWord) 
			Help( ,,STR0010,, STR0011, 1, 0 ) //"AJUDA"###" Caminho do arquivo modelo inválido. Verifique os parâmetros informados para geração da boleta.
			Return	
		ElseIf Empty(cDestino)
			Help( ,,STR0010,, STR0012, 1, 0 ) //"AJUDA"###" Caminho de destino inválido. Verifique os parâmetros informados para geração da boleta.
			Return	
		Else
			aCnts   := fNN8Macro()
 			aCampos := fCposWord()
		EndIf

		If substr(Alltrim(cDestino), -1) != "/" .or. substr(Alltrim(cDestino), -1) != "\"
			If GetRemoteType() == 3 //linux
				cDestino := alltrim(cDestino) + "/boleta_"+_cContrato + ".doc"
			Else
				cDestino := alltrim(cDestino) + "\boleta_"+_cContrato + ".doc"
			EndIf
		EndIf 

		/* Conecta ao word */
		oWord := OLE_CreateLinX()
		OLE_NewFile( oWord, cArqWord )

		/* Ajustando as Variaveis do Documento */
		
		/*
		Aeval( aCampos																								 ,;
				{ |x| OLE_SetDocumentVar( oWord, x[1]  																 ,;
											IF( Subst( AllTrim( x[3] ) , 4 , 2 )  == "->"          					 ,;
												Transform( x[2] , PesqPict( Subst( AllTrim( x[3] ) , 1 , 3 )		 ,;
																			Subst( AllTrim( x[3] )  				 ,;
																					- ( Len( AllTrim( x[3] ) ) - 5 )  ;
																				)	  	 							  ;
																			)                                         ;
														)															 ,;
														Transform( x[2] , x[3] )                                      ;
												) 														 	 		  ;
										)																			  ;
				}     																 							 	  ;
			)
			*/
		
		For nX := 1 to Len (aCampos)
			OLE_SetDocumentVar( oWord, aCampos[nx,1], aCampos[nx,2]  )
		Next 
		
		//Monta o arquivo texto que será enviado para a macro do word criar a tabela
		If !Empty(aCnts)
			For nX := 1 To Len(aCnts)
				cNN8Memo += Alltrim(aCnts[nX][1])      + "#*" //Fixation Date	   
				cNN8Memo += Alltrim(aCnts[nX][2]) + "#*" //Quantity (MT)
				cNN8Memo += Alltrim(aCnts[nX][3])      + "#*" //Portion
				cNN8Memo += Alltrim(aCnts[nX][4]) + "#*" //Ice Fixed Price US-cents/lb
				cNN8Memo += Alltrim(aCnts[nX][5]) + "#*" //Contract Price (Basis)
				cNN8Memo += Alltrim(aCnts[nX][6]) + "#*" //Fixed Price US-cents/lb
			Next nX		

			OLE_SetDocumentVar(oWord, "cParam01", cNN8Memo) 				  //Envia para a variavel de documento o conteudo completo da tabela
			OLE_SetDocumentVar(oWord, "cParam02", AllTrim(Str(Len(aCnts)+1))) //Envia para a variavel de documento a qtd de linhas da tabela
			OLE_SetDocumentVar(oWord, "cParam03", "("+_cUnProd+")") 				  //Envia para a variavel de documento Unidade de Medida do Produto
			OLE_ExecuteMacro(oWord, "tabfixacoes") 							  //Executa macro do Word que cria a tabela e insere o conteudo do cMemo
			OLE_SetDocumentVar(oWord, "cParam01", "") 						  //Limpa variavel
			OLE_SetDocumentVar(oWord, "cParam02", "") 						  //Limpa variavel
			OLE_SetDocumentVar(oWord, "cParam03", "") 						  //Limpa variavel
		EndIf  

		/* Atualizando as variaveis do documento do Word */
		OLE_UpdateFields(oWord) 

		/* Imprimindo o Documento */
		OLE_SetProperty( oWord, '208', .F. ) 

		/* Salva o arquivo de destino */
		OLE_SaveAsFile( oWord, Alltrim(cDestino) )

		/* Encerrando o LinX com o Documento */
		OLE_CloseLinX(oWord)

		/* Abre o MS Word */
		ShellExecute( "Open", Alltrim(cDestino) , " "," ", 3 )

	oDlg:End()

Return()

/** {Protheus.doc} 
Impressao das Variaveis disponiveis para uso.

@param: 	Nil
@author: 	Equipe Agroindustria	
@since: 	16/10/2019
@Uso: 		SIGAAGR
*/ 
Static Function fVarW_Imp()
	/*Define Variaveis Locais */
	Local cString		:= 'NJR'
	Local aOrd			:= {STR0019,STR0020}	//"Variável"#"Descrição Da Variável"

	/*Define Variaveis Privates Basicas*/
	Private NomeProg	:= 'OGAR740'
	Private AT_PRG		:= NomeProg
	Private aReturn		:= {STR0021, 1,STR0022, 2, 2, 1, '',1 }	 //"Código de barras"#"Administração"
	Private cDesc1		:= STR0023	//"Relatório Das Variáveis Agr_word."
	Private cDesc2		:= STR0024  //"Sera impresso de acordo com os parâmetro s solicitados pelo"                     
	Private cDesc3		:= STR0025	//"Utilizador."   	
	Private wCabec0		:= 1
	Private wCabec1		:= STR0026	//"Variáveis                      Descrição"
	Private wCabec2		:= ""
	Private wCabec3		:= ""
	Private nTamanho	:= "P"
	Private lEnd		:= .F.
	Private Titulo		:= cDesc1
	Private Li			:= 0
	Private ContFl		:= 1
	Private cBtxt		:= ""
	Private aLinha		:= {}
	Private nLastKey	:= 0

	/*Envia controle para a funcao SETPRINT*/
	WnRel := "WORD_VAR"
	WnRel := SetPrint(cString,Wnrel,"",Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho,,.F.)

	IF nLastKey == 27
		Return( NIL )
	EndIF

	SetDefault(aReturn,cString)

	IF nLastKey == 27
		Return( NIL )
	EndIF

	/*Chamada do Relatorio. */
	RptStatus( { |lEnd| fImpVar() } , Titulo )

Return

/** {Protheus.doc} 
Impressao das Variaveis disponiveis para uso.

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	16/10/2019
@Uso: 		SIGAAGR
*/ 
Static Function fImpVar()
	Local nOrdem	:= aReturn[8]
	Local aCampos	:= {}
	Local nX		:= 0
	Local cDescr	:= ""

	/*Carregando Variaveis*/
	aCampos := fCposWord()

	/*Ordena aCampos de Acordo com a Ordem Selecionada*/        
	IF nOrdem = 1
		aSort( aCampos , , , { |x,y| x[1] < y[1] } )
	Else
		aSort( aCampos , , , { |x,y| x[4] < y[4] } )
	EndIF

	/*Carrega Regua de Processamento*/        
	SetRegua( Len( aCampos ) )

	/*Impressao do Relatorio*/        
	For nX := 1 To Len( aCampos )

        /*Movimenta Regua Processamento*/        
		IncRegua()

        /*Cancela ImpresÃ†o*/
		IF lEnd
			@ Prow()+1,0 PSAY cCancel
			Exit
		EndIF

		/* Mascara do Relatorio*/
        //        10        20        30        40        50        60        70        80
        //12345678901234567890123456789012345678901234567890123456789012345678901234567890
		//Variaveis                      Descricao
		// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		
		/*Carregando Variavel de Impressao*/
		cDescr := AllTrim( aCampos[nX,4] )

      	/*Imprimindo Relatorio*/
		Impr( Padr(aCampos[nX,1],31) + Left(cDescr,50) )
        
		If Len(cDescr) > 50
			Impr( Space(31) + SubStr(cDescr,51,50) )
		Endif

		If Len(cDescr) > 100
			Impr( Space(31) + SubStr(cDescr,101,50) )
		Endif

	Next nX

	IF aReturn[5] == 1
		Set Printer To
		dbCommit()
		OurSpool(WnRel)
	EndIF

	MS_FLUSH()

Return( NIL )


/*/{Protheus.doc} OGAR740VMD()
Validação do tipo de arquivo(modelo) word a ser usado como documento de origem.
@type  Function
@author rafael.voltz	
@since 08/03/2018
@version 1.0
@param param, param_type, param_descr
@return .t., logical, true or false
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=318604330
/*/
Function OGAR740VMD()
		
	IF !Empty( mv_par01 )
		IF Len( mv_par01 ) > 99
			Help( , , STR0010, , STR0013, 1, 0, ,,,,,{STR0014} )			//A localização completa do arquivo do Word excedeu o limite de 99 caracteres.  ### Mova este arquivo para outro local ou selecione outro arquivo.
			Return .F.
		Else
			IF  Upper( Subst( AllTrim( mv_par01 ), - 3 ) ) != Upper( AllTrim( "DOT" ) )  .AND. Upper( Subst( AllTrim( mv_par01 ), - 4 ) ) != Upper( AllTrim( "DOTX" ) )
				Help( , , STR0010, , STR0015, 1, 0, ,,,,,{STR0016} )				//Tipo de arquivo inválido!  ### Selecione um arquivo com extensão .DOT ou .DOTX.
				Return .F.
			EndIf
		EndIf
	Else
		Return .F.
	EndIF
Return .T.

/*/{Protheus.doc} OGAR740VDE()
Validação do tipo de arquivo(documento) word a ser usado como documento de destino.
@type  Function
@author rafael.kleestadt	
@since 03/01/2018
@version 1.0
@param param, param_type, param_descr
@return .t., logical, true or false
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=318604330
/*/
Function OGAR740VDE()
	
	IF !Empty( mv_par02 )
		IF Len( mv_par02 ) > 99
			Help( , , STR0010, , "A localização completa do arquivo do Word excedeu o limite de 99 caracteres.", 1, 0, ,,,,,{"Mova este arquivo para outro local ou selecione outro arquivo."} )
			Return .F.
		Else
			If !ExistDir( mv_par02, , .f. )	
				Help( , , STR0010, , "Diretório não encontrado.", 1, 0, ,,,,,{"Informa um caminho de diretório válido."} )
				Return .F.				
			EndIf
		EndIf
	Else
		Return .F.
	EndIF
Return .t.

/*/{Protheus.doc} fNN8Macro()
Carrega os dados das fixações para impressão da tabela
@type  Function
@author rafael.voltz	
@since 07/03/2018
@version 1.0
@param param, param_type, param_descr
@return aReturn, array, array com os dados das fixações para impressão da tabela
@example	
@see http://tdn.totvs.com/pages/viewpage.action?pageId=318604330
/*/
Static Function fNN8Macro()
	Local aLinha   	 as array
	Local aData      as array
	Local aCompForml as array
	Local aCompon    as array
	Local cAliasQry as char
	Local dDataAnt  as date
	Local nValor    as numeric
	Local nX        as numeric
	Local nPos      as numeric
	Local nValNeg   as numeric
	Local nValBasis as numeric
	Local cMesEmbA  as char
	Local nQtdFix   as numeric
	Local nValBolsa as numeric	
	Local nTotQtd   as numeric
	Local nTotBols  as numeric
	Local nTotBas   as numeric
	Local nTotFix   as numeric
	Local nQtd      as numeric
	Local cMesEmbAux as char
	Local nValMult   as numeric
	Local cItemAnt   as char
	Local cData      as char
    LOcal nTotMBol   as numeric
    Local nTotMBas   as numeric
    Local nTotMFix   as numeric

	aLinha 		:= {}
	aCompForml  := {}
	aCompon     := {}
	aData       := {}
	cAliasQry 	:= GetNextAlias()
	nValor    	:= 0
	nX        	:= 0
	nValBolsa   := 0
	nValNeg   	:= 0
	nValBasis 	:= 0
	cMesEmbA    := ""
	nPos        := 0	
	nTotQtd     := 0	 
	nTotBols	:= 0	
	nTotBas		:= 0	
	nTotFix		:= 0	
	nQtd   		:= 0	
	cMesEmbAux  := ""
	cItemAnt    := ""
    nTotMBol    := 0
    nTotMBas    := 0
    nTotMFix    := 0

	nValMult   := Iif(mv_par03 == 0, 1, mv_par03)

	BeginSql Alias cAliasQry
		SELECT NN8_ITEMFX,
			   NKA_VLRUN1, 
			   (NN8_QTDFIX + NN8_QTDAGL) NN8_QTDFIX , 
			   NN8_DATA, 
			   NKA_CODCOM, 
			   NK7_BOLSA, 
			   NK7_CALCUL, 
			   NK7_TIPPRC, 			   
			   NNY_MESEMB,
			   NN8_CODCAD
		  FROM %table:NN8% NN8
		INNER JOIN %table:NKA% NKA ON NKA.NKA_FILIAL = NN8.NN8_FILIAL AND NKA.NKA_CODCTR = NN8.NN8_CODCTR AND NKA.NKA_ITEMFX = NN8.NN8_ITEMFX AND NKA.%NotDel%
		INNER JOIN %table:NK7% NK7 ON NK7.NK7_FILIAL = %xFilial:NK7%  AND NK7.NK7_CODCOM = NKA.NKA_CODCOM AND NK7.%NotDel%
		INNER JOIN %table:NNY% NNY ON NNY.NNY_FILIAL = NN8_FILIAL AND NNY.NNY_CODCTR = NN8.NN8_CODCTR AND NNY.NNY_ITEM = NN8.NN8_CODCAD AND NNY.%NotDel%
		WHERE NN8.NN8_FILIAL = %xFilial:NN8%
		  AND NN8.NN8_CODCTR = %Exp: _cContrato%
		  AND (NN8_QTDFIX > 0 OR NN8_QTDAGL > 0 ) 
		  AND NN8_TIPAGL != '1'
		  AND NN8.%NotDel%
		  ORDER BY NN8_DATA, NNY_MEMBAR
	EndSql
	
	While (cAliasQry)->(!Eof())
		//if ( (cAliasQry)->NN8_DATA == dDataAnt .or. Empty(dDataAnt) ) .And. ( (cAliasQry)->NNY_MESEMB == cMesEmbA .or. Empty(cMesEmbA) )
		if ( (cAliasQry)->NN8_ITEMFX == cItemAnt .or. Empty(cItemAnt) )
			If (cAliasQry)->NK7_BOLSA == "1"
				nValBolsa += (cAliasQry)->NKA_VLRUN1			
			
			ElseIf (cAliasQry)->NK7_CALCUL == "R" .AND.  (cAliasQry)->NK7_TIPPRC == "2" //NEGOCIADO

				aCompForml := CompForml((cAliasQry)->NKA_CODCOM)
				nValNeg    += (cAliasQry)->NKA_VLRUN1
			Else
				If (cAliasQry)->NK7_CALCUL != "R"
					aAdd(aCompon,{(cAliasQry)->NKA_CODCOM,(cAliasQry)->NKA_VLRUN1})
				EndIf
			EndIF

			cItemAnt    := (cAliasQry)->NN8_ITEMFX
			cMesEmbAux 	:= (cAliasQry)->NNY_MESEMB 
			dDataAnt 	:= (cAliasQry)->NN8_DATA
			cMesEmbA 	:= (cAliasQry)->NNY_MESEMB
			nQtdFix  	:= (cAliasQry)->NN8_QTDFIX			
			(cAliasQry)->(dbSkip())
		Else	
			
			For nX := 1 To Len(aCompon)				
				nPos := aScan(aCompForml, {|x| x[1] == aCompon[nX,1] })				
				
				If nPos > 0
					If aCompForml[nPos,2] == "1" //SOMA
						nValBasis += aCompon[nX,2]
					Else 
						nValBasis -= aCompon[nX,2] //SUBTRAI
					EndIf
				EndIf
			Next

			cMesEmbarq := DescEmb(cMesEmbAux) 
			aData := DataExtenso(CTOD(SUBSTR(dDataAnt,7,2)+"/"+SUBSTR(dDataAnt,5,2)+"/"+SUBSTR(dDataAnt,1,4)),,.T.)				
			cData := SUBSTR(  aData[1], 1, 3) + " " + aData[2] + ", " + aData[3]
			aAdd(aLinha, { cData, ;
						   StrTran(TRANSFORM(nQtdFix, PesqPict("N7C","N7C_QTAFIX")),",","."),;
						   cMesEmbarq,;						   
						   StrTran(TRANSFORM(nValBolsa * nValMult, PesqPict("N7C","N7C_VLRCOM")),",","."),;
						   StrTran(TRANSFORM(nValBasis * nValMult, PesqPict("N7C","N7C_VLRCOM")),",","."),;
						   StrTran(TRANSFORM(nValNeg * nValMult,   PesqPict("N7C","N7C_VLTOTC")),",","."),;						   
						 } )

            nTotQtd  += nQtdFix
			nTotBols += nValBolsa * nValMult
			nTotBas  += nValBasis * nValMult
			nTotFix  += nValNeg   * nValMult
            nTotMBol += nValBolsa * nQtdFix 
            nTotMBas += nValBasis * nQtdFix
            nTotMFix += nValNeg   * nQtdFix
			nQtd++

			cItemAnt := (cAliasQry)->NN8_ITEMFX
			dDataAnt := (cAliasQry)->NN8_DATA
			cMesEmbA := (cAliasQry)->NNY_MESEMB
			nQtdFix  := (cAliasQry)->NN8_QTDFIX			

			nValBolsa := 0						 
			nValBasis := 0
			nValNeg   := 0
			nQtdFix   := 0
			aCompon   := {}
			aCompForml := {}
		EndIf		
	EndDo

	If nValNeg > 0 .And. Len(aCompon) > 0
		For nX := 1 To Len(aCompon)				
			nPos := aScan(aCompForml, {|x| x[1] == aCompon[nX,1] })				
			
			If nPos > 0
				If aCompForml[nPos,2] == "1" //SOMA
					nValBasis += aCompon[nX,2]
				Else 
					nValBasis -= aCompon[nX,2] //SUBTRAI
				EndIf
			EndIf
		Next

		cMesEmbarq := DescEmb(cMesEmbAux)
		aData := DataExtenso(CTOD(SUBSTR(dDataAnt,7,2)+"/"+SUBSTR(dDataAnt,5,2)+"/"+SUBSTR(dDataAnt,1,4)),,.T.)				
		cData := SUBSTR(  aData[1], 1, 3) + " " + aData[2] + ", " + aData[3]
		aAdd(aLinha, { cData, ;
						   StrTran(TRANSFORM(nQtdFix, PesqPict("N7C","N7C_QTAFIX")),",","."),;
						   cMesEmbarq,;
						   StrTran(TRANSFORM(nValBolsa * nValMult,PesqPict("N7C","N7C_VLRCOM")),",","."),;
						   StrTran(TRANSFORM(nValBasis * nValMult,PesqPict("N7C","N7C_VLRCOM")),",","."),;
						   StrTran(TRANSFORM(nValNeg   * nValMult,PesqPict("N7C","N7C_VLTOTC")),",",".");
					 } )
		
		nTotQtd  += nQtdFix
		nTotBols += nValBolsa * nValMult
		nTotBas  += nValBasis * nValMult
		nTotFix  += nValNeg   * nValMult
        nTotMBol += nValBolsa * nQtdFix 
        nTotMBas += nValBasis * nQtdFix
        nTotMFix += nValNeg   * nQtdFix
		nQtd++
	EndIf

	If Len(aLinha) > 0	   
	   aAdd(aLinha, { "Total", ;
						   StrTran(TRANSFORM(nTotQtd, PesqPict("N7C","N7C_QTAFIX")),",","."),;
						   "",;
						   StrTran(TRANSFORM(nTotMBol / nTotQtd,  PesqPict("N7C","N7C_VLRCOM")),",","."),;
						   StrTran(TRANSFORM(nTotMBas / nTotQtd,  PesqPict("N7C","N7C_VLRCOM")),",","."),;
						   StrTran(TRANSFORM(nTotMFix / nTotQtd,  PesqPict("N7C","N7C_VLTOTC")),",","."),;
					 } )	
	EndIF

	(cAliasQry)->(dbCloseArea())

Return ( aLinha )

/*/{Protheus.doc} fCposWord()
Carrega os dados variaveis do cabeçalho e retorna para impressão
@type  Function
@author rafael.voltz
@since 08/03/2018
@version 1.0
@param param, param_type, param_descr
@return aExp, array, array com as informações dos campos variaveis do cabeçalho
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=318604330
/*/
Static Function fCposWord()
	Local aExp      as array
	Local nPos      as numeric
	Local aSM0		as array
	Local cEntClie  as char
	Local cEntLoja	as char
	Local cCodClie  as char
	Local cLojClie  as char
	Local cFilOrg   as char
	Local cCodCor   as char
	Local cLojCor   as char
	Local cNomeCom   as char
	Local cEndCom    as char
	Local cBairroCom as char
	Local cPaisCom	 as char
	Local cNomeVend  as char
	Local cEndVend   as char
	Local cBairrVend as char
	Local cPaisVend	 as char
	Local cNomeCorr  as char
	Local cUFCom     as char
	Local cCnpj      as char
	Local cData      as char	

	aExp       := {}
	nPos       := 0
	cData      := ""
	aSM0	   := FwLoadSM0()
	
    cEntClie   := POSICIONE('NJR',1,XFILIAL('NJR')+_cContrato,'NJR_CODENT')
	_cUnProd   := POSICIONE('NJR',1,XFILIAL('NJR')+_cContrato,'NJR_UM1PRO')	
	cEntLoja   := POSICIONE('NJR',1,XFILIAL('NJR')+_cContrato,'NJR_LOJENT')	
	cCodClie   := POSICIONE('NJ0',1,XFILIAL('NJ0')+cEntClie+cEntLoja,'NJ0_CODCLI') 
	cLojClie   := POSICIONE('NJ0',1,XFILIAL('NJ0')+cEntClie+cEntLoja,'NJ0_LOJCLI') 
	cFilOrg    := POSICIONE('N79', 1,XFILIAL('N79')+_cCodNegc + _cVerNegc,'N79_FILORG') 
	cCodCor    := POSICIONE('N79', 1,XFILIAL('N79')+_cCodNegc + _cVerNegc,'N79_CODCOR') 
	cLojCor    := POSICIONE('N79', 1,XFILIAL('N79')+_cCodNegc + _cVerNegc,'N79_LOJCOR') 	
	cCtrExterno := AllTrim(POSICIONE('NJR',1,XFILIAL('NJR')+_cContrato,'NJR->NJR_CTREXT'))	
	cNomeCom   := ""
    cEndCom    := ""
    cBairroCom := ""
    cPaisCom   := ""	
    cNomeCom   := ""
    cNomeVend  := ""
    cEndVend   := ""
    cBairrVend := ""
    cPaisVend  := ""	
    cNomeVend  := ""
    cNomeCorr  := ""
	cUFCom 	   := ""
	cCnpj      := ""

	SA1->(dbSetOrder(1))		
	If (SA1->(dbSeek(xFilial("SA1")+cCodClie+cLojClie)))		
		cNomeCom   := SA1->A1_NOME 
		cEndCom    := SA1->A1_END 
		cBairroCom := SA1->A1_BAIRRO
		cPaisCom   := POSICIONE("SYA", 1, xFilial("SYA")+SA1->A1_PAIS, "YA_DESCR")
		cUFCom 	   := SA1->A1_EST
	EndIf
	
	If (nPos := aScan(aSM0, {|x| x[1] == cEmpAnt .AND. cFilOrg $ x[2]})) > 0
		cCnpj := aSM0[nPos][18] // Posição 18 do array SM0 contem o M0_CGC que seria O cnpj		
	EndIf

	SA2->(dbSetOrder(3))
	If (SA2->(dbSeek(xFilial("SA2")+cCnpj)))		
		cNomeVend   := SA2->A2_NOME
		cEndVend    := SA2->A2_END 
		cBairrVend := SA2->A2_BAIRRO 
		cPaisVend   := POSICIONE("SYA", 1, xFilial("SYA")+SA2->A2_PAIS, "YA_DESCR")		
	EndIf

	SA2->(dbSetOrder(1))
	If (SA2->(dbSeek(xFilial("SA2")+cCodCor+cLojCor)))								
		cNomeCorr := SA2->A2_NOME
	EndIf	

	aToday := DataExtenso(date(),,.t.)				
	cData := SUBSTR(  aToday[1], 1, 3) + " " + aToday[2] + ", " + aToday[3]	

	/*=================== ============================ ====================  ================================================*/
	         /*VARIAVEL PARA WORD , VARIAVEL DE IMPRESSAO      , VARIAVEL DE PICTURE , DESCRIÇÃO VARIAVEIS		   		  		     */
	/*=================== ============================ ====================  ================================================*/ 
	aAdd( aExp, {'AGR_CONTRACT_NUMBER'	 ,cCtrExterno      		  , ""   , "NÚMERO DO CONTRATO" }) //"NOME COMPRADOR"
	aAdd( aExp, {'AGR_TODAY'	 		 ,cData      		  	  , ""    , "DATA CORRENTE" }) //"DATA ATUAL"
	aAdd( aExp, {'AGR_BUYER_NAME'	 	 ,cNomeCom       		  , ""    , "NOME COMPRADOR" }) //"NOME COMPRADOR"
	aAdd( aExp, {'AGR_BUYER_ADDRESS' 	 ,cEndCom   			  ,	""    , "ENDEREÇO COMPRADOR" }) //"ENDEREÇO COMPRADOR"
	aAdd( aExp, {'AGR_BUYER_DISTRICT'	 ,cBairroCom  			  ,	""    , "BAIRRO COMPRADOR" }) //"BAIRRO COMPRADOR"
	aAdd( aExp, {'AGR_BUYER_COUNTRY' 	 ,cPaisCom				  , ""    , "PAÍS COMPRADOR" }) //"PAÍS COMPRADOR"
   	aAdd( aExp, {'AGR_BUYER_SIGNATURE'	 ,cNomeCom                , ""    , "ASSINATURA COMPRADOR" }) //"ASSINATURA COMPRADOR"
	aAdd( aExp, {'AGR_SELLER_NAME'	     ,cNomeVend      		  , ""    , "NOME VENDEDOR" }) //"NOME COMPRADOR"
	aAdd( aExp, {'AGR_SELLER_ADDRESS' 	 ,cEndVend  			  ,	""    , "ENDEREÇO VENDEDOR" }) //"ENDEREÇO COMPRADOR"
	aAdd( aExp, {'AGR_SELLER_DISTRICT'	 ,cBairrVend 			  ,	""    , "BAIRRO VENDEDOR" }) //"BAIRRO COMPRADOR"
	aAdd( aExp, {'AGR_SELLER_COUNTRY' 	 ,cPaisVend			      , ""    , "PAÍS VENDEDOR" }) //"PAÍS COMPRADOR"
	aAdd( aExp, {'AGR_SELLER_SIGNATURE'	 ,cNomeVend 	          , ""     , "ASSINATURA VENDEDOR" }) //"ASSINATURA VENDEDOR"
	aAdd( aExp, {'AGR_AGENT_SIGNATURE'	 ,cNomeCorr     	      , ""   , "ASSINATURA CORRETOR" }) //"ASSINATURA CORRETOR"		

Return ( aExp )

//-------------------------------------------------------------------
/*/{Protheus.doc} CompForml
Função respon´savel por buscar a fórmula do componente.
@author  Rafael Voltz
@since   21/03/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function CompForml(cComp as char)
	Local cAliasCp  as char
	Local aFormula  as array

	cAliasCp := GetNextAlias()
	aFormula := {}

	BeginSql Alias cAliasCp
		SELECT N75_CODCOP,
			   N75_OPERAC		    	
		  FROM %table:N75% N75
	INNER JOIN %table:NK7% NK7 ON NK7.NK7_FILIAL = %xFilial:NK7% AND NK7.NK7_CODCOM = N75.N75_CODCOP AND NK7.%NotDel%
		 WHERE N75.N75_FILIAL = %xFilial:N75%
		   AND N75.N75_CODCOM = %Exp: cComp%
		   AND NK7.NK7_BOLSA  != '1'
		   AND N75.%NotDel%
	EndSql

	While (cAliasCp)->(!eof())
		aAdd(aFormula,{(cAliasCp)->N75_CODCOP, (cAliasCp)->N75_OPERAC})
		(cAliasCp)->(dbSkip())
	EndDo

	(cAliasCp)->(dbCloseArea())

Return aFormula

//-------------------------------------------------------------------
/*/{Protheus.doc} OGAR704DOT
Função responspavel por abrir popup para seleção de arquivo.
@author  Rafael Voltz
@since   21/03/2018
@version version
/*/
//-------------------------------------------------------------------
Function OGAR704DOT( cCPO )        
	Local cRET        := ""

	If cCPO == "MV_PAR01"
		cRET := cGetFile( STR0005,STR0006,,,, nOR(GETF_MULTISELECT,GETF_NETWORKDRIVE,GETF_LOCALHARD)) //"Selecione o arquivo *.DOT ou *.DOTX"	
	Else
		cRET := cGetFile( STR0018,STR0018,,,.T., nOR(GETF_MULTISELECT,GETF_NETWORKDRIVE,GETF_LOCALHARD, GETF_RETDIRECTORY)) //"Seleciona diretórios
	EndIf

    If !Empty(cRET)
		&(cCPO) := cRET   
	EndIf
    
Return (!Empty(cRET))


//-------------------------------------------------------------------
/*/{Protheus.doc} DescEmb
Função responsável por montar a descrição de embarque abreviada em 
inglês.
@author  Rafael Voltz
@since   21/03/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function DescEmb( cEmbar )    
    Local cEmbAux as char	
	cEmbAux := Substr(cEmbar,1,3)
	

	Do Case
		Case cEmbAux == "FEV"
			cEmbAux := "FEB"
		Case cEmbAux == "ABR"
			cEmbAux := "APR"
		Case cEmbAux == "MAI"
			cEmbAux := "MAY"
		Case cEmbAux == "SET"
			cEmbAux := "SEP"
		Case cEmbAux == "OUT"
			cEmbAux := "OCT"
		Case cEmbAux == "DEZ"
			cEmbAux := "DEC"		
	EndCase

	cEmbAux += substr(cEmbar,7,2)
    
Return cEmbAux

//-------------------------------------------------------------------
/*/{Protheus.doc} validGer
Função responsável por validar a geração da boleta.
@author  Rafael Voltz
@since   21/03/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function validGer()

	//validação removida de acordo com a tarefa DAGROCOM-5631
	//If POSICIONE('NJR',1,XFILIAL('NJR')+_cContrato,'NJR_TIPMER') != "2" //Externo
	//	Help( , , "Ajuda", , "Geração da boleta disponível somente para contratos de mercado externo.", 1, 0, ,,,,,{"Consulte o tipo de mercado do contrato."} )			
	//	Return .F.
	//EndIf

	If GetTemFix()
		MsgInfo("Não foram encontradas fixações para esse contrato.")
		Return .F.
	EndIf

Return .T.

Static Function GetTemFix()
    Local cAliasQry 	as char
	Local lRet          as logical

	cAliasQry 	:= GetNextAlias()
	lRet        := .T.

	BeginSql Alias cAliasQry
		SELECT COUNT(*) QTD
		  FROM %table:NN8% NN8
		WHERE NN8_FILIAL = %xFilial:NN8%
		  AND NN8_CODCTR = %Exp:_cContrato% 
		  AND NN8.%NotDel%
	EndSql

	If (cAliasQry)->QTD > 0
		lRet := .F.
	EndIf

	(cAliasQry)->(dbCloseArea())

Return lRet