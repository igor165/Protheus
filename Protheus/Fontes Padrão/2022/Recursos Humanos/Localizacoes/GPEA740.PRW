#INCLUDE "PROTHEUS.CH"            
#INCLUDE "PONCALEN.CH"     
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "GPEA740.CH"   

#DEFINE Confirma 1
#DEFINE Redigita 2  
#DEFINE Abandona 3  
#DEFINE Alterar  4 

/*                                             
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEA740  ³ Autor ³ Alceu Pereira         ³ Data ³ 04.07.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadasto de Exercicio de Funcao Superior                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Localizado: Argentina                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador³ Data   ³ BOPS  ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ³        ³       ³                                    	   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function Gpea740(nOpcAuto)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis locais         					     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LOCAL aIndexSRA		:= {}	   	    //Variavel Para Filtro

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis privadas       					     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local bFiltraBrw 	:= {|| Nil}		//Variavel para Filtro
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define array contendo as Rotinas a executar do programa      ³
	//³ ----------- Elementos contidos por dimensao ------------     ³
	//³ 1. Nome a aparecer no cabecalho                              ³
	//³ 2. Nome da Rotina associada                                  ³
	//³ 3. Usado pela rotina                                         ³
	//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
	//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
	//³    2 - Simplesmente Mostra os Campos                         ³
	//³    3 - Inclui registros no Bancos de Dados                   ³
	//³    4 - Altera o registro corrente                            ³
	//³    5 - Remove o registro corrente do Banco de Dados          ³
	//³    6 - Legenda das Cores do Browse                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aRotina := MenuDef() // Chamada da funcao MenuDef() que contem aRotina

	cCadastro := OemToAnsi(STR0009) //Cadastro de exercicio de cargos superiores

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Arquivo Esta Vazio                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ChkVazio("SRA")
		Return
	Endif                                
	
	If nOpcAuto <> Nil
		Do Case
			Case nOpcAuto == 3
				INCLUI := .T.
				ALTERA := .F.
			Case nOpcAuto == 4
				INCLUI := .F.
				ALTERA := .T.
			OtherWise	
				INCLUI := .F.
				ALTERA := .F.
		EndCase		
 	
		dbSelectArea('SRA')
		nPos := Ascan(aRotina,{|x| x[4]== nOpcAuto})
		If ( nPos <> 0 )
			bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPos,2 ] + "(a,b,c,d,e) }" )
			Eval( bBlock, Alias(), (Alias())->(Recno()),nPos)
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFiltraRh 	:= CHKRH("GPEA740","SRA","1")
		bFiltraBrw 	:= {|| FilBrowse("SRA",@aIndexSRA,@cFiltraRH) }
		Eval(bFiltraBrw)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Endereca a funcao de BROWSE                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SRA")
		mBrowse( 6, 1,22,75,"SRA",,,,,,fCriaCor() )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		EndFilBrw("SRA",aIndexSra)
	EndIf
Return

/*           
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp740Atu  ³ Autor ³ Alceu Pereira         ³ Data ³ 05.07.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de (Vis.,Inc.,Alt. e Del.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ gp740Atu(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA740                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function gp740Atu(cAlias,nReg,nOpcx)        

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis locais         					     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nCnt								//Armazena a quantidade de registros de um determinado funcionario. Utilizada para verificar se usuario podera "Incluir" ou "Alterar".
	Local nOpcNewGd
	Local aArea 	 	:= GetArea()
	Local aAdvSize		:= {}				// Variavel para controle de coordenadas da janela.
	Local aInfoAdvSize	:= {}				// Variavel para controle de coordenadas da janela.
	Local aObjCoords	:= {}				// Variavel para controle de coordenadas da janela.
	Local aObjSize		:= {}				// Variavel para controle de coordenadas da janela.
	Local oDlg								// Variavel do tipo objetos
	Local oFont								// Variavel do tipo objetos
	Local oGroup							// Variavel do tipo objetos
	Local cKey			:= ""				// variavel com os valores das chaves. (variavel para getdados da tabela GRL)
	Local aRGLNotFields	:= {}				// vetor com os campos que nao seria visualizados. (variavel para getdados da tabela GRL)
	Local aRGLVirtGd	:= {}				// vetor com os campos virtuais. (variavel para getdados da tabela RGL)
	Local aRGLVisualGD	:= {} 				// vetor com os campos visuais. (variavel para getdados da tabela RGL)
	Local aRGLAltFields := {} 				// vetor com os campos alteráveis. (variavel para getdados da tabela RGL)
  	Local aRGLCols		:= {}				// vetor com as colunas da GetDados. (variavel para getdados da tabela RGL)
	Local bSet15		:= { || NIL }		// Bloco com as validacoes do botao OK. (variavel da janela)
	Local bSet24		:= { || NIL }		// Bloco com as validacoes do botao Cancelar. (variavel da janela) 
	Local nPosCdFun		:= 0
	Local cPosDcFun     := ""  
	Local nPosSeq		:= 0
	Local nPosDtIni		:= 0
	Local nPosDtFim     := 0
	Local nPosSal		:= 0
	Local nPosDur		:= 0
	Local nPosDesc		:= 0
	Local nLinha		:= 0
	Local cQuery		:= ""   
	Local nOpca			:= 0   
	Local nLinha1		:= 1
	Local nMaxArray 	:= 0				// Quantidade de colunas da RGL.   
	Local ny			:= 1 
	Local cFunc 	    := ""  
	Local cDesc			:= ""  
	Local aButtons      := {}
	Local aRet			:= {} 	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis privadas       					     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cFil	 		:= SRA->RA_FILIAL  	//Armazena a filial. Utilizada como chave de pesquisa.
	Private cMat  	 		:= SRA->RA_MAT     	//Armazena a matricula. Utilizada como chave de pesquisa.
	Private aRGLColsRec		:= {}					// vetor que contem os Recnos da tabela. (variavel para getdados da tabela RGL)
	Private aHeader			:= {}						// vetor com o cabecalho da GetDados RGL. (variavel para getdados da tabela RGL)
	Private nRGLUsado		:= 0.00 				// variavel que retorna a quantidade de campos da tabela. (variavel para getdados da tabela RGL)
	Private oGet								// Variavel do tipo objetos  
	Private lExec 			:= .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Status do Empregado        					     ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
	nOpcNewGd = IF( nOpcX == 2 .or. nOpcX == 5 , 0 , GD_INSERT + GD_UPDATE + GD_DELETE)
	
	cAlias := "RGL"   
	
	DbSelectArea(cAlias)   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta as Dimensoes dos Objetos         					     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 015 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	While .T.        
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe algum dado no arquivo                     ³   
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		#IFDEF TOP
			cQuery := " SELECT COUNT(*) TOTAL " 
			cQuery += " FROM "+	RetSqlName(cAlias)
			cQuery += " WHERE "                  			
		  	cQuery += " RGL_FILIAL = '" + cFil + "' AND "
			cQuery += " RGL_MAT    = '" + cMat + "' AND "   
			
			If TcSrvType() != "AS/400"    
				cQuery += " D_E_L_E_T_ <> '*' "		
			Else
				cQuery += " @DELETED@ <> '*' "		
			EndIf		
			
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QRGL', .F., .T.)
			dbSelectArea("QRGL")
		  	nCnt := QRGL->TOTAL
	   
			dbCloseArea()
		
		#ELSE   
			dbSelectArea( cAlias )   
			dbSeek( cFil + cMat )
		    nCnt := 0
		    While !EOF() .And. RGL_FILIAL + RGL_MAT == cFil + cMat
				nCnt++
				dbSkip()
		    EndDo
		#ENDIF  
		
	 	If nCnt > 0  .And. nOpcx = 3    //--Quando Inclusao e existir Registro		
	 		MsgInfo( OEMTOANSI(STR0034), OEMTOANSI(STR0019)) //Atencao!#Ja existem funcoes cadastradas para este funcionario. Utilize a opcao 'Alterar'"
	 		Exit			
			//Help(" ",1,"A740SAFA")
	    Elseif nCnt == 0 .And. nOpcx # 3  //--Quando Nao for Inclusao e nao existir Registro
   	 		MsgInfo( OEMTOANSI(STR0020), OEMTOANSI(STR0019)) //Atencao!# E necessario realizar a inclusao para efetuar esta acao!
     	     //Help(" ",1,"A740SAFA")
	 		Exit       
	 	Endif
		     
		DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0010) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL	//
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta os Dados para a GetDados      						 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		// campos que nao serao visualizados na getdados
		aAdd( aRGLNotFields , "RGL_FILIAL" ) 
		aAdd( aRGLNotFields , "RGL_MAT"    )
		aAdd( aRGLNotFields , "RGL_NOME"   ) 
		aAdd( aRGLNotFields , "RGL_ALI_WT" ) 
		aAdd( aRGLNotFields , "RGL_REC_WT" ) 
		aAdd( aRGLNotFields , "GHOSTCOL"   ) 
		
		//campos que podem ser alterados na getdados
		aAdd( aRGLAltFields	 ,"RGL_CODFUN" ) 
		aAdd( aRGLAltFields	 ,"RGL_DTINI"  )
		aAdd( aRGLAltFields , "RGL_DIAS"   ) 
		aAdd( aRGLAltFields , "RGL_DTFIM"  )
		aAdd( aRGLAltFields , "RGL_SALARI" )
		  
		        
	   	#IFDEF TOP  
    	   		                              
		  	cQuery := "  RGL_FILIAL = '" + cFil + "'"
		  	cQuery += "  AND "
			cQuery += "   RGL_MAT = '" + cMat + "'"
			cQuery += "  AND "
			    
			If TcSrvType() != "AS/400"
				cQuery += "  D_E_L_E_T_ <> '*' "		
			Else
				cQuery += "  @DELETED@ <> '*' "						
			EndIf 
			
		#ENDIF                                
		  		
    	cKey	 	:= ( xFilial( "SRA" ) + SRA->RA_MAT )
		aRGLCols 	:= RGL->( GdMontaCols(@aHeader,;  //01 -> Array com os Campos do Cabecalho da GetDados
								  @nRGLUsado	,;	//02 -> Numero de Campos em Uso
								  @aRGLVirtGd	,;	//03 -> [@]Array com os Campos Virtuais
								  @aRGLVisualGd	,;	//04 -> [@]Array com os Campos Visuais
		                          "RGL"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
								  aRGLNotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
								  @aRGLColsRec	,;	//07 -> [@]Array unidimensional contendo os Recnos
								  "SRA"			,;	//08 -> Alias do Arquivo Pai
								  cKey			,;	//09 -> Chave para o Posicionamento no Alias Filho
								  NIL			,;	//10 -> Bloco para condicao de Loop While
								  NIL			,;	//11 -> Bloco para Skip no Loop While
		  						  NIL			,;	//12 -> Se Havera o Elemento de Delecao no aCols 
				  				  NIL			,;	//13 -> Se cria variaveis Publicas
						  		  NIL			,;	//14 -> Se Sera considerado o Inicializador Padrao
		  						  NIL			,;	//15 -> Lado para o inicializador padrao
				  				  NIL			,;	//16 -> Opcional, Carregar Todos os Campos
						  		  NIL 			,;	//17 -> Opcional, Nao Carregar os Campos Virtuais
		  						  cQuery		,;	//18 -> Opcional, Utilizacao de Query para Selecao de Dados
				  				  .F.			,;	//19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
						  		  .F.			,;	//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
								  .T.			,;	//21 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
								  NIL			,;	//22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
 								  NIL			,;	//23 -> Verifica se Deve Checar se o campo eh usado
								  NIL			,;	//24 -> Verifica se Deve Checar o nivel do usuario
								  NIL			,;	//25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
								  NIL			,;	//26 -> [@]Array que contera as chaves conforme recnos
								  NIL			,;	//27 -> [@]Se devera efetuar o Lock dos Registros
								  NIL			,;	//28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
								  NIL			,;	//29 -> Numero maximo de Locks a ser efetuado
								  .T.			 ;	//30 -> Utiliza Numeracao na GhostCol
		 						  ))
                                        
		aHeader[ GdFieldPos( "GHOSTCOL" , aHeader ) , __AHEADER_INITPAD__ ] := ""  
		
		// somente quando for inclusao, sequencia.  
		If nOpcx == 3 .AND. EMPTY(aRGLCols[1][1])
		    aRGLCols[1][1] := "001"
		EndIf   
	 
		//Ordena a GetDados por data inicial 
		nPosDtIni		:= GdFieldPos( "RGL_DTINI"	, aHeader )	
   		aSort( aRGLCols ,,, { |x,y| DTOS(x[nPosDtIni]) < DTOS(y[nPosDtIni])}) 
   		                     
   		//Realiza o preenchimento da coluna de descricao que e um campo virtual 	
   		For ny := 1 to nCnt  
			aRGLCols[ny][3] := gp740PesDes("RJ_DESC", aRGLCols[ny][2])  
		Next ny
  	   
  		@ aObjSize[1,1] , aObjSize[1,2] GROUP oGroup TO ( aObjSize[1,3] - 3 ),( ( aObjSize[1,4]/100*10 - 2 ) )				LABEL OemToAnsi(STR0011) OF oDlg PIXEL	// "Matricula:"
  		oGroup:oFont:= oFont
  		@ aObjSize[1,1] , ( ( aObjSize[1,4]/100*10 ) ) GROUP oGroup TO ( aObjSize[1,3] - 3 ),( aObjSize[1,4]/100*80 - 2 )	LABEL OemToAnsi(STR0012) OF oDlg PIXEL	// "Nome:"
  		oGroup:oFont:= oFont
  		@ aObjSize[1,1] , ( aObjSize[1,4]/100*80 ) GROUP oGroup TO ( aObjSize[1,3] - 3 ),aObjSize[1,4]						LABEL OemToAnsi(STR0014) OF oDlg PIXEL	// "Admiss„o:"
  		oGroup:oFont:= oFont
  		@ ( ( aObjSize[1,3] ) - ( ( ( aObjSize[1,3] - 3 ) - aObjSize[1,2] ) / 2 ) ) , ( aObjSize[1,2] + 5 )				SAY StrZero(Val(SRA->RA_MAT),Len(SRA->RA_MAT))	SIZE 050,10 OF oDlg PIXEL FONT oFont
  		@ ( ( aObjSize[1,3] ) - ( ( ( aObjSize[1,3] - 3 ) - aObjSize[1,2] ) / 2 ) ) , ( ( aObjSize[1,4]/100*10 ) + 5 )	SAY OemToAnsi(SRA->RA_NOME) 					SIZE 146,10 OF oDlg PIXEL FONT oFont
  		@ ( ( aObjSize[1,3] ) - ( ( ( aObjSize[1,3] - 3 ) - aObjSize[1,2] ) / 2 ) ) , ( ( aObjSize[1,4]/100*80 ) + 5 )	SAY Dtoc(SRA->RA_ADMISSA)						SIZE 050,10 OF oDlg PIXEL FONT oFont
  	  
			oGet := MsNewGetDados():New(aObjSize[2,1],;	// nTop   
									 aObjSize[2,2],;   	// nLelft
									 aObjSize[2,3],;	// nBottom
		                             aObjSize[2,4],;	// nRright
									 nOpcNewGd,;		// controle do que podera ser realizado na GetDado - nstyle
									 "gp740LinOk",;		// funcao para validar a edicao da linha - ulinhaOK
									 "gp740TudOk",;		// funcao para validar todas os registros da GetDados - uTudoOK
	  								 "+RGL_SEQ",;		// cIniCPOS
									 aRGLAltFields,;	// aAlter
									 0,; 				// nfreeze
									 99999,;  			// nMax
									 NIL,;		 		// cFieldOK     
									 NIL,;				// usuperdel
									 If(nOpcx=2.Or.nOpcx=5,Nil,.T.),;		// udelOK
									 @oDlg,;        	// objeto de dialogo - oWnd
									 @aHeader,;	   		// Vetor com Colunas - AparHeader
									 @aRGLCols;			// Vetor com Header - AparCols      
									)                  
		   						    	 
		bSet15	:= {|| lExec := .F., nOpca := (IF(nOpcx=5,2,1)), IF(oGet:TudoOk(),oDlg:End(),nOpca:=0)}
		bSet24	:= {|| lExec := .F., oDlg:End()}      
    	
	   	//aRet = gp740VerVen() //Soma os dias de exercicio de funcao    
	   	//If aRet[1][1] == .T. //Verifica se existe uma funcao exercida por 90 dias ou mais caso ok mostra botao e mensagem   
	   	//	MsgInfo(OEMTOANSI(STR0030) + Space(1) + aRet[1][2] + CRLF + ;//Atencao!#A Funcao XXX
	   	//  OEMTOANSI(STR0031) + Space(1) + CVALTOCHAR(aRet[1][3]) + Space(1) + OEMTOANSI(STR0032) + CRLF + ; //foi exercida por um periodo igual ou superior a: xx Dias
	   	//  OEMTOANSI(STR0033), OEMTOANSI(STR0019)) //para atualizar o cadastro de funcionario clique no icone funcionario"
		//  aButtons := {{"BMPUSER", {||Gpea010Alt("SRA", nReg, Alterar, cMat, NIL, NIL, NIL)}, OemToAnsi(STR0013)}} //Botao com tolltip = Funcionario  / Chamando diretamente a tela de alteracao do cadastro de funcionario
	    //Endif
	    	                                                    
	  	aButtons := {{"BMPUSER", {||Gpea010Alt("SRA", nReg, Alterar, cMat, NIL, NIL, NIL)}, OemToAnsi(STR0013)}} //Botao com tolltip = Funcionario  / Chamando diretamente a tela de alteracao do cadastro de funcionario
	  	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24, NIL, aButtons ) CENTERED 	   				 	
					  		   
		//--Se nao for Exclusao      
	    If nOpcx # 5
	        IF nOpcA == Redigita
	            LOOP
	        ELSEIF nOpcA == Confirma .And. nOpcx # 2   
	            Begin Transaction
	                //--Gravacao
	                gp740Grava(cAlias, nOpcx)
	                //--Processa Gatilhos                 
	                EvalTrigger()
	            End Transaction    
            
	        Endif
	    //--Se for Exclusao
	    Elseif nOpca == 2 .And. nOpcx == 5
	        Begin Transaction
	            gp740Dele()
	        End Transaction
	    Endif
		Exit
	EndDo
		            
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura a integridade da janela                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea( aArea )
	
 	 If nOpcx == 3                          
		MBrChgLoop(.F.)     
	EndIf	
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³                   ROTINAS DE CRITICA DE CAMPOS                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp740Grava³ Autor ³ Alceu Pereira         ³ Data ³ 22.04.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava no arquivo de Exercico de Funcoes Superiores         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gp740Grava                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function gp740Grava(cAlias, nOpc)    

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis locais         					     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local ny		:= 0.00	 								// Contador de colunas.
	Local n			:= 1									// Contador de linhas.
	Local nPosCdFun	:= 0 
	Local nTotal    := 0  	                                                                               
	  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis private para uso no ponto de entrada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aColsRGL  := (oGet:aCols)	
	Private nMaxArray := Len( aHeader  )					// Quantidade de colunas da RGL.
	Private nAcols	  := Len( aColsRGL    )					// Quantidade de linhas da RGL.
	Private nAcolsRec := Len( aRGLColsRec )
	
	nPosCdFun		  := GdFieldPos( "RGL_CODFUN"	, aHeader )	   

	If ExistBlock("GP740GRV") 
		ExecBlock("GP740GRV",.F.,.F.)
	Endif   

	dbSelectArea(cAlias)
	For n:=1 TO nAcols
	    If n <= nAcolsRec
	        dbGoto(aRGLColsRec[n])
	        RecLock(cAlias,.F.,.T.)
	        //--Verifica se esta deletado
	        If aColsRGL[n,nRGLUsado+1] == .T. 	        	
	   	        If nTotal == 0 
	   	           nTotal := gp740PesCon(cFil,cMat,aColsRGL[n,nPosCdFun]) 
   		        	If nTotal > 0 
   		        		MsgInfo( OEMTOANSI(STR0035), OEMTOANSI(STR0019)) //Atencao!#O registro que será apagado contém uma função que esta associada ao funcionário
	   	    	    Endif 
	   	    	    dbSelectArea("RGL")  
   		        	dbGoto(aRGLColsRec[n])
			        RecLock("RGL",.F.)    	    	    
	        	    dbDelete()   
	        	 Endif   
	            Loop
	        Endif     
	    Else                        
	    	//--Verifica se Nao esta Deletado no aCols
	       	If aColsRGL[n,nRGLUsado+1]  = .F.
        	   	RecLock(cAlias,.T.,.T.)
	            RGL->RGL_FILIAL	:= cFil
	            RGL->RGL_MAT	:= SRA->RA_MAT
	       	Else
	            Loop                   
	       	Endif     
	  	Endif    

		For ny := 1 To nMaxArray      
			
			IF ( AllTrim(aHeader[ny,2]) == "RGL_SEQ" )
			
				cCampo    	:= Trim(aHeader[ny][2])
    	    	xConteudo 	:= aColsRGL[n,ny]

		   	   	RGL->RGL_SEQ 		:= xConteudo  		   	  	
					
		   	ELSEIF ( AllTrim(aHeader[ny,2]) == "RGL_CODFUN" )      
			
				cCampo    	:= Trim(aHeader[ny][2])
    	      	xConteudo 	:= aColsRGL[n,ny]
						
		   	 	RGL->RGL_CODFUN 		:= 	xConteudo 
		   	 	
        	ELSEIF ( AllTrim(aHeader[ny,2]) == "RGL_DTINI" )
			                                                         
				cCampo    	:= Trim(aHeader[ny][2])
				xConteudo 	:= aColsRGL[n,ny] 	
        		
        		RGL->RGL_DTINI      := xConteudo
        		                                                   
        	ELSEIF ( AllTrim(aHeader[ny,2]) == "RGL_DIAS" )
			
				cCampo    	:= Trim(aHeader[ny][2])
    	      	xConteudo 	:= aColsRGL[n,ny]  	
        		
        		RGL->RGL_DIAS     := xConteudo 	
	

        	ELSEIF ( AllTrim(aHeader[ny,2]) == "RGL_DTFIM" )
			
				cCampo    	:= Trim(aHeader[ny][2])
				xConteudo 	:= aColsRGL[n,ny]  	
        		
        		RGL->RGL_DTFIM      := xConteudo                                    
        		
        	ELSEIF ( AllTrim(aHeader[ny,2]) == "RGL_SALARI" )
			
				cCampo    	:= Trim(aHeader[ny][2])
				xConteudo 	:= aColsRGL[n,ny]  	
        		
        		RGL->RGL_SALARI      := xConteudo                                    	
            
           	ENDIF          	
           			   	
	    Next ny   	  	
		RecLock(cAlias,.F.,.T.) 
      ( cAlias )->( MsUnlock() )
	Next n

Return( NIL )

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp740Dele ³ Autor ³ Alceu Pereira         ³ Data ³ 08.07.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Deleta os Registro                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gp740Dele                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Static Function gp740Dele()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis locais         					     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cAlias	:= "RGL"  
	Local nX		:= 0			//Quantidade de linhas da RGL.
	Local aRGLCols 	:= (oGet:aCols)
	
	nCnt := 0  

	For nx := 1 to Len(aRGLCols)
		dbSeek(RGL->RGL_FILIAL+RGL->RGL_MAT)		
	    RecLock(cAlias,.F.,.T.)
	    dbDelete( )
	    MsUnlock()
	    nCnt++
	Next nx

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp740LinOk³ Autor ³ ALCEU PEREIRA         ³ Data ³ 08.07.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica linha digitada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gp740LinOk()      
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis locais         					     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aRGLCols		:= (oGet:aCols)
	Local aCposKey	  	:= {} 
	Local lRet		  	:= .T.									
	Local aColsRGL  	:= (oGet:aCols)	
	Local nQtdLin	  	:= Len( aColsRGL )					// Quantidade de linhas da RGL.
	Local nLinha	  	:= 0  
 	Local nLinDup		:= 0    
	Local nPosSeq	   	:= GdFieldPos( "RGL_SEQ"	, aHeader )	
	Local nPosCdFun	   	:= GdFieldPos( "RGL_CODFUN"	, aHeader )		
	Local nPosDesFun	:= GdFieldPos( "RGL_DESFUN"	, aHeader )	
   	Local nPosDtIni	  	:= GdFieldPos( "RGL_DTINI"	, aHeader )	
	Local nPosDias	  	:= GdFieldPos( "RGL_DIAS"	, aHeader )	   	
   	Local nPosDtFim		:= GdFieldPos( "RGL_DTFIM"	, aHeader )	
   	Local nPosSalari	:= GdFieldPos( "RGL_SALARI"	, aHeader )	 
   	Local dDtIni		:= ""    
   	Local dDtFim		:= ""  
   	
   		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Verifica Itens Duplicados na GetDados						   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		aCposKey := {}
		aAdd( aCposKey , "RGL_DTINI"  )
		aAdd( aCposKey , "RGL_CODFUN" )  		
		aAdd( aCposKey , "RGL_CODFUN" )		
		aAdd( aCposKey , "RGL_DESFUN" )	
   		aAdd( aCposKey , "RGL_DTINI"  )	
		aAdd( aCposKey , "RGL_DIAS"	  )	   	
   		aAdd( aCposKey , "RGL_DTFIM"  )	
   		aAdd( aCposKey , "RGL_SALARI" )	  
		
		IF !( lRet := GdCheckKey( aCposKey , 4 ) )  
			If lRet == .F.
				MsgInfo( OEMTOANSI(STR0017), OEMTOANSI(STR0019)) //Atencao!#Existem dados duplicados
	    	   //Help(" ",1,"A740DTINI")  	    	   
	       	 EndIF	
		EndIF  

	    /*/               
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Verifica se todos os campos estao devidamente preenchidos     ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
         For nLinha := 1 To nQtdLin    
         
         If  (aRGLCols[nLinha,nPosDias]) > 999 
				MsgInfo( OEMTOANSI(STR0037), OEMTOANSI(STR0019)) //Atencao!#Verifique a quantidade de dias de exercicio da funcao
	       		//Help(" ",1,"A740DTINI")
	       		lRet := .F.		
	       		exit
	    	EndIf        
         
          	If (aRGLCols[nLinha,nPosDtIni]) = NIL .OR. (aRGLCols[nLinha,nPosDtFim]) = NIL
				MsgInfo( OEMTOANSI(STR0029), OEMTOANSI(STR0019)) //Atencao!#Verifique a data inicial e a data final   
	       		//Help(" ",1,"A740DTINI")
	       		lRet := .F.		
	       		exit
	    	EndIf  
	    	
	    	If Empty(aRGLCols[nLinha,nPosDtIni])
       			MsgInfo( OEMTOANSI(STR0024), OEMTOANSI(STR0019)) //Atencao!#Data Inicial em branco   
	   	    	//Help(" ",1,"A740DTINI")
	   	    	lRet := .F.
	   	    	exit
	   		EndIF  

			If Empty(aRGLCols[nLinha,nPosDtFim]) 
				MsgInfo( OEMTOANSI(STR0016), OEMTOANSI(STR0019)) //Atencao!#Exsite um registro sem data final    
	       		//Help(" ",1,"A740DTINI")
	       		lRet := .F.		
	       		exit
	    	EndIf
          
		    If (aRGLCols[nLinha,nPosDtIni] > aRGLCols[nLinha,nPosDtFim])
				MsgInfo( OEMTOANSI(STR0023), OEMTOANSI(STR0019)) //Atencao!#Data inicial maior que a Data Final   
	    	   //Help(" ",1,"A740DTINI")
		       	lRet := .F.
		       	exit 
		    EndIF                                                 
		    
		    If (aRGLCols[nLinha,nPosDtFim] < aRGLCols[nLinha,nPosDtIni])
				MsgInfo( OEMTOANSI(STR0036), OEMTOANSI(STR0019)) //Atencao!#Data Final menor que a Data Inicial   
	    	   //Help(" ",1,"A740DTINI")
		       	lRet := .F.
		       	exit 
		    EndIF                                                 


			If Empty(aRGLCols[nLinha,nPosCdFun]) 
				MsgInfo( OEMTOANSI(STR0018), OEMTOANSI(STR0019)) //Atencao!#Codigo da funcao e obrigatorio 
				lRet := .F.
				exit 
			EndIf  
			
			If Empty(aRGLCols[nLinha,nPosDesFun]) 
				MsgInfo( OEMTOANSI(STR0001), OEMTOANSI(STR0019)) //Atencao!#Descricao da funcao e obrigatorio 
				lRet := .F.	 
				exit
			Endif		    
			              
			If Empty(aRGLCols[nLinha,nPosDias]) 
				MsgInfo( OEMTOANSI(STR0021), OEMTOANSI(STR0019)) //Atencao!#Digite a quantidade de Dias de exercício da funcao 
				lRet := .F.	 
				exit 
			Endif
			
			If Empty(aRGLCols[nLinha,nPosSalari]) 
				MsgInfo( OEMTOANSI(STR0003), OEMTOANSI(STR0019)) //Atencao!#Salario da funcao e obrigatorio" 
				lRet := .F.	 
				exit 
			Endif		    
			 
			If Empty(aRGLCols[nLinha,nPosSeq]) 
				MsgInfo( OEMTOANSI(STR0002), OEMTOANSI(STR0019)) //Atencao!#Sequencia e obrigatoria" 
				lRet := .F.	 
				exit 
			Endif	 
                
			dDtIni = aRGLCols[nLinha,nPosDtIni]   
			dDtFim = aRGLCols[nLinha,nPosDtFim]    
			
	   	  	For nLinDup := 1 to nQtdLin  //Verifica se existem datas iguais para sequencias diferentes  
                
				If nLinDup != nLinha .AND. lRet != .F.
		   		
		   			If (dDtIni == aRGLCols[nLinDup,nPosDtIni])
		   				MsgInfo( OEMTOANSI(STR0025), OEMTOANSI(STR0019)) //Atencao!#Existe uma data inicial duplicada 
	    	   			//Help(" ",1,"A740DTINI")
	       				lRet := .F.  
	       				exit 
		    		EndIf
		    		
	    			If  (dDtFim == aRGLCols[nLinDup,nPosDtFim])  
						MsgInfo( OEMTOANSI(STR0026), OEMTOANSI(STR0019)) //Atencao!#Existe uma data final duplicada   
						//Help(" ",1,"A740DTINI")
	       				lRet := .F.
	       				exit
		    		EndIf   	    					     
                     
                	If (aRGLCols[nLinDup,nPosDtIni] >= dDtIni .AND. aRGLCols[nLinDup,nPosDtIni] <= dDtFim)
						MsgInfo( OEMTOANSI(STR0027), OEMTOANSI(STR0019)) //Atencao!#Uma data inical esta dentro de um perido exeistente
						//Help(" ",1,"A740DTINI")
	       				lRet := .F.
	       				exit
		    		EndIf    
		    		
                	If (aRGLCols[nLinDup,nPosDtFim] >= dDtIni .AND. aRGLCols[nLinDup,nPosDtFim] <= dDtFim)
                		MsgInfo( OEMTOANSI(STR0028), OEMTOANSI(STR0019)) //Atencao!#"Uma data final esta dentro de um perido exeistente"   
                		//Help(" ",1,"A740DTINI")  
		    			lRet := .F. 
		    	  		exit
		    		EndIf     
		    		
		        Endif
                                    
				If lRet == .F. 
					exit
				Endif
                
		    Next nLinDup  	
		    
   				If  lRet == .F.          
   	   				exit
				Endif

		Next nLinha  

Return(lRet)    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp740TudOk³ Autor ³ Alceu Pereira         ³ Data ³ 08.07.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ gp740TudOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gp740TudOk(o)

	Local lRetorna    	:= .T.
	
	lRetorna = gp740LinOk()  
	
Return( lRetorna ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | gp740PesDes | Autor ³ Alceu Pereira         ³ Data ³ 18.07.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza pesquisa e retorna descricao da Funcao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gp740PesDes(cCampo,cCodigo )

LOCAL cVar  
Local cAlias := "SRJ"

cVar := cCodigo
dbSelectArea("SRJ")
nOrdemV := IndexOrd()
dbSetOrder(1)

	dbSeek( cFilial + cVar)
	dbSetOrder(nOrdemV)
	dbSelectArea(cAlias)

Return ( RJ_DESC )    
                       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | gp740PesCon | Autor ³ Alceu Pereira         ³ Data ³ 25.07.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza pesquisa e retorna Quantidade de Registros            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function gp740PesCon(cFili,cMatr,cFunc) 

		dbCloseArea()

		#IFDEF TOP
			cQuery := " SELECT COUNT(*) TOTAL "
			cQuery += " FROM "+	RETSQLNAME( "SRA" )
			cQuery += " WHERE "                  			
		  	cQuery += " RA_FILIAL 	= '" + cFili + "' AND "
			cQuery += " RA_MAT    	= '" + cMatr + "' AND "   
			cQuery += " RA_CODFUNC  = '" + cFunc + "' AND "   		
			
			If TcSrvType() != "AS/400"
				cQuery += " D_E_L_E_T_ <> '*' "		
			Else
				cQuery += " @DELETED@ <> '*' "		
			EndIf		
			
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'RSRA', .F., .T.)
			dbSelectArea("RSRA")
		  	nCnt := RSRA->TOTAL   
	        
			( "RSRA" )->( dbCloseArea() )
		
		#ELSE   
			dbSelectArea( "SRA" )   
			dbSeek( cFili + cMatr + cFunc )
		    nCnt := 0
		    While !EOF() .And. RA_FILIAL + RA_MAT + RA_CODFUNC == cFili + cMatr + cFunc
				nCnt++
				dbSkip()
		    EndDo   
		    	dbCloseArea()
		#ENDIF 	                
		
			dbSelectArea("SRA")

Return (nCnt)   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao      ³gp740VerVen ³ Autor ³Alceu Pereira        ³ Data ³ 21.07.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao   ³Verifica se alguma funcao atingiu o limite de Dias          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³GPEA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function gp740VerVen()     
 
Local aRet			:= {} 									 //Variavel de retorno da funcao
Local nLinha 		:= 1       								 //Variavel de controle do For   
Local nLinha1		:= 1 									 //Variavel de controle do For 
Local aRGLCols		:= (oGet:aCols)							 //Valores das Colunas  
Local nQtdLin	  	:= Len( aRGLCols )			        	// Quantidade de linhas da RGL.
Local nDiasFun  	:= 0									 //Quantidade de dias na Funcao
Local cCodFun   	:= 0									 //Codigo da Funcao 
Local nPosCdFun	   	:= GdFieldPos( "RGL_CODFUN"	, aHeader )  //Posicao da Coluna do codigo da funcao no Getdados    
Local nPosDias	  	:= GdFieldPos( "RGL_DIAS"	, aHeader )  //Posicao da Coluna de Quantidades de dias na funcao no Getdados    
Local nPosDesFu		:= GdFieldPos( "RGL_DESFUN"	, aHeader )  //Posicao da Coluna de Descricao da funcao no Getdados    
Local cDesFu		:= ""

aAdd(aRet,{.F.,""}) 	 

	For nLinha := 1 to nQtdLin                          
	  	    cCodFun	:= (aRGLCols[nLinha,nPosCdFun]) 
	     	For nLinha1 := 1 to nQtdLin 
	     	   
	     		If (aRGLCols[nLinha1,nPosCdFun]) == cCodFun
					nDiasFun := nDiasFun + (aRGLCols[nLinha1,nPosDias])
					If nDiasFun >= 90
	   				   cDesFu := (aRGLCols[nLinha1,nPosDesFu])					
					Endif

	     		Endif                   
	
			Next nLinha1
			
			If nDiasFun >= 90  
				aRet := {}                     
				aAdd(aRet,{.T.,cDesFu,nDiasFun}) 
			Endif 
			
			If aRet[1][1] == .T. 
				Return aRet
			Endif
    			
	Next nLinha  

Return( aRet )
                                   
/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp740VerEdit	  ³ Autor ³ Tatiane Matias        ³ Data ³06.04.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verificar se o registro poderá ser editado. So permitira efetuar  ³±±
±±³          ³manutencao nos lancamentos que possuem a data final que nao foi   ³±±
±±³          ³computados no fechamento da folha de pagamento				    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ gp740VerEdit()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ When de todos os campos da tabela RGL SX3                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function gp740VerEdit()

Local lEdit 		:= .T.
Return (lEdit)
 
/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Alceu Pereira    ³ Data ³ 08.07.08 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA740                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   

Static Function MenuDef()     

Local aRotina :=  {}    
              
	aAdd( aRotina, { STR0004 , "PesqBrw"		, 0 , 1 } )			//"Pesquisar"
	aAdd( aRotina, { STR0005 , "gp740Atu"		, 0 , 2 } )			//"Visualizar"
	aAdd( aRotina, { STR0006 , "gp740Atu"		, 0 , 3 } )			//"Incluir"
	aAdd( aRotina, { STR0007 , "gp740Atu"		, 0 , 4 } )			//"Alterar"
	aAdd( aRotina, { STR0008 , "gp740Atu"		, 0 , 5 } )			//"Excluir"		
	aAdd( aRotina, { STR0015 , "gpLegend"		, 0 , 7, ,.F. } )	//"Legenda"
	aAdd( aRotina, { STR0022 , "GPER810"		, 0 , 8 } )			//"Imprimir"

Return aRotina  