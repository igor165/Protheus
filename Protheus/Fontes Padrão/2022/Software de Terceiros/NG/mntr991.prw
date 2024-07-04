#Include 'Protheus.ch'
#Include 'MNTR991.ch'
#DEFINE _nVERSAO 1 //Versao do fonte

//--------------------------------------------------------------
/*/{Protheus.doc} MNTR991
Relat�rio de Inconsist�ncias do Sistema ap�s convers�o de fontes
para MVC, onde � listado todos os fontes que foram convertidos e 
que utilizam campo de mem�ria(M->) em seu cadastro de clique da
direita(TQD).

@param array com as rotinas a serem verificadas

@author Pablo Servin
@since 11/04/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------
Function MNTR991( aRotMVC )
	
	Local cString    := "TQD"
	Local cDesc1     := STR0001 /* "Relat�rio de Inconsist�ncias do Sistema." */
	Local cDesc2     := ""
	Local cDesc3     := ""
	Local wnRel      := "MNTR991"
	
	Private aReturn  := { STR0002, 1,STR0003, 1, 2, 1, "",1 }  /* "Zebrado"###"Administra��o" */
	Private nLastKey := 0
	Private Titulo   := STR0001 /* "Relat�rio de Inconsist�ncias do Sistema." */
	Private Tamanho  := "M"
	Private nomeprog := "MNTR991"
	Private aRotinas := aRotMVC /* aRotinas recebe o par�metro, que cont�m as rotinas a serem verificadas. */
	
	/* Cria interface para configura��o de impress�o do relat�rio. */
	wnRel := SetPrint( cString, wnRel,, Titulo, cDesc1, cDesc2, cDesc3, .F., "")

	If ( nLastKey = 27 )
	   Set Filter To
	   dbSelectArea( "TQD" )
	   Return
	EndIf

	/* Prepara o ambiente de impress�o. */
	SetDefault( aReturn,cString )
	/* Exibe um dial�go para acompanhamento da impress�o(R�gua de Progress�o). */
	RptStatus( {|lEnd| MNTR991Imp( @lEnd, wnRel, Titulo, Tamanho)}, Titulo )
                
	Set Key VK_F9 To
	dbSelectArea( "TQD" )

Return Nil

//-----------------------------------------------------------
/*/{Protheus.doc} MNTR991Imp
Chamada de impress�o do relat�rio.

@author Pablo Servin
@since 11/04/2014
@version MP11
@return .T.
/*/
//-------------------------------------------------------------
Function MNTR991Imp( lEnd, wnRel, Titulo, Tamanho )

	/* Vari�veis padr�o do relat�rio */
	Local cRODATXT := ""
	Local nCNTIMPR := 0
	Local nMULT    := 1,xx
	
	/* Vari�veis usadas no processo */
	Local nX, nG
	Local aParam /* Usada para armazenar o retorno da fun��o StrToKArr. */
	Local cParam /* Inidca o parametro */
	Local cProg := "" /* Indica o programa da click da direita.*/
	Local cRot := "" /* Indica a rotina. */

	Private li := 80 , m_pag := 1

	nTIPO  := IIf( aReturn[4]==1,15,18 )
	CABEC1 := STR0004 /* "Inconsist�ncias no Click da Direita que devem ser corrigidas no Sistema." */
	CABEC2 := ""
	CABEC( Titulo, CABEC1, CABEC2, nomeprog, Tamanho, 15 )
	
	@LI,000 PSay STR0005
	NGSOMALI(58)
	
	/*--------------------------------------------------------------------------------------------------------------------------------------------------------//
	//------------------- TRECHO QUE IMPRIMIR� AS INCONSIST�NCIAS DO CLICK DA DIREITA DO SISTEMAS AP�S A CONVERS�O DAS ROTINAS PARA MVC ----------------------//
	//--------------------------------------------------------------------------------------------------------------------------------------------------------//
	
	
		aRotinas: Array que cont�m as rotinas a serem verificadas, � inicializada na fun��o MNTR991.	 
		aRotinas[nX][1] = Nome da Rotina
		aRotinas[nX][2] = Id do Formul�rio (ViewDef da rotina)
		aRotinas[nX][3] = C�digo do chamado.	 
	
	*/
	For nX := 1 to Len( aRotinas )

		dbSelectArea( "TQD" )
		dbSetOrder( 01 ) /* TQD_FILIAL + TQD_PROGRA + TQD_FUNCAO */

		/* Verifica se encontra o registro de acordo com a rotina que est� posicionada. */
		If ( dbSeek( xFilial( "TQD" ) + aRotinas[nX][1] ) )
			/* Lista todos os registros relacionados a rotina que est� posicionada. */
			While !Eof() .And. TQD->TQD_PROGRA = aRotinas[nX][1]
				/* Se o campo de par�metro(TQD->TQD_PARAM) contiver vari�vel de mem�ria, realiza os processos */
				If ( "M->" $ TQD->TQD_PARAM .Or. "m->" $ TQD->TQD_PARAM )

					/* Se a rotina que est� posicionada for diferente da anterior, 
					imprime o nome da rotina atual na tela */
					If aRotinas[nX][1] != cRot 
						NGSOMALI(58)
						@LI,000 PSay aRotinas[nX][3] + " - " + aRotinas[nX][1] Picture "@!"
					EndIf

					/* Transforma o conte�do do campo em array separado por uma ',' */
					aParam := StrToKArr( TQD->TQD_PARAM, "," )

					/* Percorre todo os elementos do array que foi criado a partir do retorno do StrToKArr. */
					For nG := 1 to Len( aParam )
						/* Se os elementos conterem campo de mem�ria, mostra na 
						   tela os mesmos mais a fun��o que � chamada no click da direita. */	
						If ( "M->" $ aParam[nG] .Or. "m->" $ aParam[nG] )

							@LI,023 PSay AllTrim( TQD->TQD_FUNCAO ) Picture "@!"	 /* Mostra a fun��o respectiva a rotina */					
							@LI,037 PSay AllTrim( aParam[nG] ) Picture "@!" /* Mostra o conte�do do par�metro */  							                                
							@LI,059 PSay STR0006 + AllTrim( aParam[nG] ) + STR0007 +AllTrim( aRotinas[nX][2] )+; // "Trocar de " ## " para oView:GetValue('"
							"', '" + AllTrim( SubStr( aParam[nG], 4, Len(aParam[nG]) ) ) + "')" Picture "@!" /* Mostra a solu��o respectiva a ser feita */
											  /*Substr usado para retirar o 'M->' */
							NGSOMALI(58)

						EndIf
					Next nG
					cRot := aRotinas[nX][1] /* Armazena a �ltima rotina verificada */
					cParam := TQD->TQD_PARAM	 /* Armazena o �ltimo par�metro verificado */
					cProg := TQD->TQD_FUNCAO /* Armazena  a �ltima fun��o verificada */
				EndIf
				dbSelectArea( "TQD" )
				dbSkip()
			End While
		EndIf
	Next nX	

	NGSOMALI(58)
	NGSOMALI(58)
	@LI, 000 PSay STR0008 + STR0009 /* "Para maior entendimento e detalhamento sobre como funcionam as rotinas em MVC, "
	 ## "voc� pode acessar o seguinte link: " ## */
	NGSOMALI(58)
	@LI, 000 PSay "http://tdn.totvs.com/display/public/mp/MVC+-+Model+View+Control"
	NGSOMALI(58)
	@LI, 000 PSay STR0010
	NGSOMALI(58)
	//--------------------------------------------------------------------------------------------------------------------------------------------------------//
	//---------------------------- FIM DA IMPRESS�O DAS INCONSIST�NCIAS NO CLICK DA DIREITA CAUSADAS PELA CONVERS�O PARA MVC --------------------------------//
	//--------------------------------------------------------------------------------------------------------------------------------------------------------// 
	Roda( nCntImpr, cRodaTxt, Tamanho )

	Set Filter To
	Set Device to Screen
	If ( aReturn[5] == 1 )
	   Set Printer To
	   dbCommitAll()
	   OurSpool( wnrel )
	EndIf

	MS_FLUSH()

Return .T.

//-------------------------------------------------------------
/*/{Protheus.doc} INIARRMOD
Fun��o que inicializa o array com os IDs dos formul�rios dos 
fontes que foram convertidos para MVC.

@author Pablo Servin
@since 11/04/2014
@version MP11
@return aModelos - Array bidimensional com as rotinas e IDs dos
					 fontes que foram convertidos para MVC.
/*/
//--------------------------------------------------------------
Function INIARRMOD()

	Local aModelos := {}

	/*
	   Adicionar nesse array as rotinas que foram convertidas para MVC para serem
	   verificadas. Obs.: Utilizar a fun��o aAdd para acrescentar 	novas rotinas...
	   	
	   aRotMVC[x][1] = Nome da Rotina
	   aRotMVC[x][2] = Id do Formul�rio (ViewDef da rotina)
	   aRotMVC[x][3] = C�digo do chamado.
	*/
	
	aAdd( aModelos, { "MNTA100", "MNTA100_STD", "" } )
	aAdd( aModelos, { "MNTA185", "MNTA185_TP3", "" } )
	aAdd( aModelos, { "MNTA215", "MNTA215_TP8", "" } )
	aAdd( aModelos, { "MNTA710", "MNTA710_TQY", "" } )
	aAdd( aModelos, { "MNTA025", "MNTA025_TPJ", "" } )
	aAdd( aModelos, { "MNTA065", "MNTA065_TPV", "" } )
	aAdd( aModelos, { "MNTA110", "MNTA110_STE", "" } )
	aAdd( aModelos, { "MNTA205", "MNTA205_TP7", "" } )

Return aModelos